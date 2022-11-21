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
 - 수정 및 
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
