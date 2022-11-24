# WorkoutProject

관리자 페이지 구현

- 메인 (현재 판매 신청 상품, Q&A 질문 갯수 확인)
~~~
package controller.admin;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.admin.AdminService;

@WebServlet("/admin")
public class AdminController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		AdminService service = new AdminService();
		
		service.service(req);
		
		req.setAttribute("addCss", new String[] {"admin/admin"});
		
		RequestDispatcher rd = req.getRequestDispatcher("/admin/admin.jsp");
		rd.forward(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doGet(req, resp);
	}
	
}

~~~

- 기능 부분 
~~~
package models.admin;

import javax.servlet.http.HttpServletRequest;

import models.qAnda.QAndADao;
import models.seller.SellerDao;

public class AdminService {
	
	public void service(HttpServletRequest request) {
		
		int qna = QAndADao.getInstance().count();
		
		int product = SellerDao.getInstance().count();
		
		request.setAttribute("QnA", qna);
		request.setAttribute("product", product);
		
	}

}

~~~

- DAO
~~~
public int count() {
		SqlSession sqlSession = Connection.getSession();
		
		int count = sqlSession.selectOne("QAndAMapper.reqCount");
		
		return count;
	}
<!-- QnA 답변 미등록 개수 -->
	<select id="reqCount" resultType="int">
		SELECT COUNT(*) FROM QAndA WHERE isAnswer=0;
	</select>
~~~
~~~
public int count() {
		
		SqlSession sqlSession = Connection.getSession();
		
		int count = sqlSession.selectOne("RequestProductMap.reqCount");
		
		return count;
	}
<!-- 미승인 상품 총 개수 -->
<select id="reqCount" resultType="int">
	SELECT COUNT(*) FROM RequestProduct WHERE status="req";
</select>
~~~

관리자 게시판 관리 페이지

- 게시판을 추가 및 수정, 삭제 기능
~~~
package controller.admin.boardConfig;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.admin.board.BoardConfigDao;
import models.admin.board.BoardConfigDto;
import models.admin.board.BoardConfigRegisterService;

import static jmsUtil.Utils.*;

@WebServlet("/admin/board")
public class BoardConfigController extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		List<BoardConfigDto> list = BoardConfigDao.getInstance().gets();
		
		req.setAttribute("list", list);
		
		req.setAttribute("addCss", new String[] {"admin/list", "admin/admin"});
		req.setAttribute("addJs", new String[] {"admin/list"});
		
		RequestDispatcher rd = req.getRequestDispatcher("/admin/board/board.jsp");
		rd.forward(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		resp.setCharacterEncoding("utf-8");
		req.setCharacterEncoding("utf-8");
		try {
			BoardConfigRegisterService service = new BoardConfigRegisterService();
			service.register(req);
			
			reloadPage(resp, "parent");
		} catch(RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}

}
~~~
 - 게시판 수정 및 삭제
~~~
package controller.admin.boardConfig;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.admin.board.BoardConfigDeleteService;
import models.admin.board.BoardConfigUpdateService;

import static jmsUtil.Utils.*;

@WebServlet("/admin/boards")
public class BoardController extends HttpServlet{
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		try {
			String mode = req.getParameter("mode");
			if(mode.equals("update")) {
				BoardConfigUpdateService service = new BoardConfigUpdateService();
				service.update(req);
			} else {
				BoardConfigDeleteService service = new BoardConfigDeleteService();
				service.delete(req);
			}
			
			reloadPage(resp, "parent");
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}

}

~~~

- 수정 기능
~~~
package models.admin.board;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;


public class BoardConfigUpdateService {
	
	public void update(HttpServletRequest request) {
		/** 유효성 검사 S */
		String[] boardIds = request.getParameterValues("boardId");
		if(boardIds == null || boardIds.length == 0) {
			throw new BadException("수정할 게시판을 선택하세요.");
		}
		
		for(String id : boardIds) {
			String boardNm = request.getParameter("boardName_" + id);
			if(boardNm == null || boardNm.isBlank()) {
				throw new BadException("게시판 이름을 입력해주세요.");
			}
		}
		/** 유효성 검사 E */
		
		/** 수정 처리 S */
		BoardConfigDao dao = BoardConfigDao.getInstance();
		for(String id : boardIds) {
			BoardConfigDto dto = new BoardConfigDto();
			String noOfRows = request.getParameter("noOfRows_" + id);
			if(noOfRows == null || noOfRows.isBlank()) {
				noOfRows = "20";
			}
			dto.setBoardId(id);
			dto.setBoardName(request.getParameter("boardName_" + id));
			dto.setNoOfRows(Integer.parseInt(noOfRows));
			dto.setIsUse(Integer.parseInt(request.getParameter("isUse_" + id)));
			dto.setIsMemberOnly(Integer.parseInt(request.getParameter("isMemberOnly_" + id)));
			dto.setUseComment(Integer.parseInt(request.getParameter("useComment_" + id)));
			
			boolean result = dao.update(dto);
			if(!result) {
				throw new BadException("오류가 발생하였습니다. 다시 시도해주세요.");
			}
		}
		/** 수정 처리 E */
		
		
	}

}

~~~

- 삭제 기능
~~~
package models.admin.board;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;

public class BoardConfigDeleteService {
	
	public void delete(HttpServletRequest request) {
		/** 유효성 검사 S */
		String[] boardIds = request.getParameterValues("boardId");
		if(boardIds == null || boardIds.length == 0) {
			throw new BadException("삭제할 게시판을 선택하세요.");
		}
		/** 유효성 검사 E */
		
		/** 삭제 처리 S */
		BoardConfigDao dao = BoardConfigDao.getInstance();
		for(String id : boardIds) {
			BoardConfigDto board = new BoardConfigDto();
			board.setBoardId(id);
			dao.delete(board);
		}
		/** 삭제 처리 E */
	}

}

~~~
관리자 유저 관리

- 유저 목록 및 수정 삭제(검색)
~~~
package controller.admin;

import static jmsUtil.Utils.reloadPage;
import static jmsUtil.Utils.showAlertException;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.UserDto;
import models.admin.UserManageService;

@WebServlet("/admin/user")
public class AdminMemberController extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		UserManageService service = new UserManageService();
		List<UserDto> members = service.service(req);
		
		req.setAttribute("userInfoList", members);
		
		req.setAttribute("addCss", new String[] { "admin/product", "admin/admin"});
		
		RequestDispatcher rd = req.getRequestDispatcher("/admin/adminUserManage.jsp");
		rd.forward(req, resp);
		
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		UserManageService service = new UserManageService();
		
		req.setCharacterEncoding("utf-8");
		
		try {
			String mode = req.getParameter("mode");
			if(mode.equals("update")) {
				service.userUpdate(req);
			} else {
				service.delete(req);
			}
			
			reloadPage(resp, "parent");
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}
}
~~~

- 기능 
~~~
package models.admin;

import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.ibatis.session.SqlSession;

import dto.UserDto;
import models.member.UserDao;
import mybatis.Connection;

public class UserManageService {

	UserDao dao = UserDao.getInstance();
	
	public List<UserDto> service(HttpServletRequest request) {

		String select = request.getParameter("select");
		String text = request.getParameter("str");

		if (select == null || select.isBlank()) {
			select = "name";
		}

		if (text == null || text.isBlank()) {
			text = "";
		}

		UserDto param = new UserDto();

		switch (select) {
		case "name":
			param.setName("%" + text + "%");
			break;
		case "fakeName":
			param.setFakeName("%" + text + "%");
			break;
		case "sex":
			param.setSex("%" + text + "%");
			break;
		case "id":
			param.setId("%" + text + "%");
			break;
		case "userType":
			param.setUserType("%" + text + "%");
			break;
		}

		List<UserDto> members = adminUserGets(param);

		return members;

	}

	public List<UserDto> adminUserGets(UserDto param) {
		SqlSession sqlSession = Connection.getSession();

		List<UserDto> members = sqlSession.selectList("userInfoMapper.adminUser", param);

		return members;
	}

	public void memberGets() {
		SqlSession sqlSession = Connection.getSession();

		UserDto param = new UserDto();
		UserDto list = (UserDto) sqlSession.selectList("userInfoMapper.list", param);

		System.out.println(list);

		sqlSession.close();

	}

	public UserDto memberGet(HttpServletRequest req) {
		SqlSession sqlSession = Connection.getSession();

		UserDto user = sqlSession.selectOne("userInfoMapper.user", req);

		System.out.println(user);

		sqlSession.close();

		return user;
	}

	public void userUpdate(HttpServletRequest req) {
		String[] userIds = req.getParameterValues("userNo");

		for (String userId : userIds) {
			UserDto dto = new UserDto();

			dto.setNum(Integer.parseInt(userId));
			dto.setUserType(req.getParameter("userType_" + userId));

			dao.typeUpdate(dto);
		}
	}

	public void delete(HttpServletRequest req) {
		String[] userIds = req.getParameterValues("userNo");
		for (String userId : userIds) {
			dao.userDelete(Integer.parseInt(userId));
		}

	}

}
~~~

판매자 판매 상품 관리자에게 승인 요청한 상품 목록(검색)

~~~
package controller.admin;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.admin.ProductSearchService;
import models.seller.ProductDto;

@WebServlet("/admin/product")
public class AdminProductController extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

		ProductSearchService service = new ProductSearchService();
		List<ProductDto> products = service.search(req);
		req.setAttribute("products", products);

		String[] addCss = { "admin/product", "admin/admin" };
		String[] addJs = { "admin/product" };

		req.setAttribute("addCss", addCss);
		req.setAttribute("addJs", addJs);

		RequestDispatcher rd = req.getRequestDispatcher("/admin/adminProduct.jsp");
		rd.forward(req, resp);
	}

}
~~~

- 검색 기능
~~~
package models.admin;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;
import models.seller.ProductDto;
import models.seller.SellerDao;

public class ProductSearchService {
	
	public List<ProductDto> search(HttpServletRequest request) {
		String select = request.getParameter("select");
		String str = request.getParameter("str");
		
		if(select == null) {
			select = "seller";
		}
		
		if(str == null) {
			str = "";
		}
		
		SellerDao dao = SellerDao.getInstance();
		int limit = 10;
		String _page = request.getParameter("page");
		int page = (_page == null || _page.isBlank()) ? 1 : Integer.parseInt(_page);
		
		int total = dao.total(select, str);
		
		List<ProductDto> products = dao.searchReq(select, str, page, limit);
		if(products == null) {
			throw new BadException("해당 검색 데이터는 없습니다.");
		}
		
		request.setAttribute("page", page);
		request.setAttribute("total", total);
		request.setAttribute("products", products);
		request.setAttribute("limit", limit);
		
		return products;
	}

}
~~~

- 판매자 상품 승인/미승인 처리

~~~
package controller.admin;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.admin.ProductUpdateService;

import static jmsUtil.Utils.*;

@WebServlet("/admin/update")
public class ProductUpdateController extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		resp.setContentType("text/html; charset=utf-8");
		
		try {
			ProductUpdateService service = new ProductUpdateService();
			service.update(req);
			
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
		
	}

}
~~~

- 기능 
~~~
package models.admin;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;
import models.seller.SellerDao;

public class ProductUpdateService {

	/**
	 * 승인/미승인 처리 업데이트
	 * @param request
	 */
	public void update(HttpServletRequest request) {
		// 유효성 검사
		String id = request.getParameter("id");
		String status = request.getParameter("status");
		
		if(id == null || id.isBlank()) {
			throw new BadException("잘못된 접근 입니다.");
		}
		if(status == null || status.isBlank()) {
			throw new BadException("잘못된 접근 입니다.");
		}
		
		try {
			Integer.parseInt(id);
		} catch (Exception e) {
			throw new BadException("잘못된 접근 입니다.");
		}
		
		// 승인/미승인 업데이트 처리
		SellerDao dao = SellerDao.getInstance();
		boolean result = dao.updateReq(Integer.parseInt(id), status);
		if(!result) {
			throw new BadException("오류가 발생했습니다.");
		}
		
		
		
		
	}
	
}
~~~
