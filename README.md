# WorkoutProject

QnA 고객센터 구현(페이지 네이션 구현)

~~~
package controller.qAnda;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.qAnda.QAndAListService;

@WebServlet("/Q&A")
public class QAndAController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		QAndAListService service = new QAndAListService();
		service.list(req);
		
		req.setAttribute("addCss", new String[] {"qAnda/style"});
		
		RequestDispatcher rd = req.getRequestDispatcher("/q&a/list.jsp");
		rd.forward(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		doGet(req, resp);
		
	}
	
}
~~~
- 기능 
~~~
package models.qAnda;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

public class QAndAListService {
	
	public void list(HttpServletRequest request) {
		QAndADao dao = QAndADao.getInstance();
		
		int limit = 10;
		String _page = request.getParameter("page");
		int page = (_page == null || _page.isBlank()) ? 1 : Integer.parseInt(_page);
		
		int total = dao.total();
		
		List<QAndADto> dtos = dao.gets(page, limit);
		
		request.setAttribute("page", page);
		request.setAttribute("total", total);
		request.setAttribute("list", dtos);
		request.setAttribute("limit", limit);
		
	}

}
~~~

QnA 고객센터 삭제(문의글 삭제)
~~~
package controller.qAnda;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.qAnda.QAndADeleteService;

import static jmsUtil.Utils.*;

@WebServlet("/Q&A/delete")
public class QAndADeleteController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		
		try {
			
			QAndADeleteService service = new QAndADeleteService();
			service.delete(req);
			
			replacePage(resp, req.getContextPath() + "/Q&A", "parent");
		}catch(RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}
}
~~~

- 기능
~~~
package models.qAnda;

import javax.servlet.http.HttpServletRequest;

import dto.UserDto;
import exception.BadException;

public class QAndADeleteService {
	
	public void delete(HttpServletRequest request) {
		UserDto user = (UserDto) request.getSession().getAttribute("member");
		
		if(!user.getUserType().equals("admin")) {
			throw new BadException("삭제 권한이 없습니다.");
		}
		
		QAndADao dao = QAndADao.getInstance();
		
		String _id = request.getParameter("id");
		
		QAndADto dto = new QAndADto();
		dto.setId(Integer.parseInt(_id));
		
		
		boolean result = dao.delete(dto);
		if(!result) {
			throw new BadException("오류가 발생하였습니다.");
		}
	}

}
~~~

QnA 문의글 보기 및 답변(작성자 또는 관리자만 확인 가능)

~~~
package controller.qAnda;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.qAnda.QAndAAdminViewService;
import models.qAnda.QAndAViewService;

import static jmsUtil.Utils.*;

@WebServlet("/Q&A/view")
public class QAndAViewController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setAttribute("addCss", new String[] {"qAnda/style"});
		resp.setContentType("text/html;charset=UTF-8");
		PrintWriter out = resp.getWriter();
		try {
			QAndAAdminViewService service = new QAndAAdminViewService();
			service.view(req);
			
			RequestDispatcher rd = req.getRequestDispatcher("/q&a/view.jsp");
			rd.forward(req, resp);
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
			out.println("<script>history.back();</script>");
		}
		
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		try {
			
			QAndAViewService service = new QAndAViewService();
			service.view(req);
			
			replacePage(resp, req.getContextPath() + "/Q&A", "parent");
		} catch(RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}
	
}
~~~

- 문의글 보기 기능
~~~
package models.qAnda;

import javax.servlet.http.HttpServletRequest;

import dto.UserDto;
import exception.BadException;

public class QAndAAdminViewService {

	public void view(HttpServletRequest request) {
		UserDto user = (UserDto) request.getSession().getAttribute("member");

		QAndADao dao = QAndADao.getInstance();
		QAndADto dto = dao.get(Integer.parseInt(request.getParameter("id")));
		if (user == null) {
			if (dto.getFix() != 1) {
				throw new BadException("로그인 후 이용해주세요.");
			}
		} else {
			if (!user.getId().equals(dto.getMemId())) {
				if (dto.getFix() != 1) {
					if (!user.getUserType().equals("admin")) {
						throw new BadException("본인 글이 아닙니다.");
					}
				}
			}
		}
		request.setAttribute("question", dto);
	}

}
~~~

- 문의글 답변 기능
~~~
package models.qAnda;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;

public class QAndAViewService {
	
	public void view(HttpServletRequest request) {
		
		String id = request.getParameter("id");
		String answer = request.getParameter("answer");
		if(answer == null || answer.isBlank()) {
			throw new BadException("답변을 입력해주세요.");
		}
		
		QAndADto dto = new QAndADto();
		dto.setAnswer(answer);
		dto.setId(Integer.parseInt(id));
		
		QAndADao dao = QAndADao.getInstance();
		boolean result = dao.update(dto);
		if(!result) {
			throw new BadException("답변 작성 중 오류가 발생하였습니다.");
		}
	}

}
~~~

문의글 작성
~~~
package controller.qAnda;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dto.UserDto;
import exception.BadException;
import models.qAnda.QAndAWriteService;

import static jmsUtil.Utils.*;

@WebServlet("/Q&A/write")
public class QAndAWritercontroller extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setAttribute("addCss", new String[] {"qAnda/style"});
		resp.setContentType("text/html;charset=UTF-8");
		PrintWriter out = resp.getWriter();
		try {
			UserDto user = (UserDto) req.getSession().getAttribute("member");
			if(user == null) {
				throw new BadException("로그인 후 이용해주세요.");
			}
			RequestDispatcher rd = req.getRequestDispatcher("/q&a/write.jsp");
			rd.forward(req, resp);
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
			out.println("<script>history.back();</script>");
		}
		
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		
		try {
			QAndAWriteService service = new QAndAWriteService();
			service.register(req);
			replacePage(resp, req.getContextPath() + "/Q&A", "parent");
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
	}
	
}
~~~

- 기능
~~~
package models.qAnda;

import javax.servlet.http.HttpServletRequest;

import dto.UserDto;
import exception.BadException;

public class QAndAWriteService {
	
	public void register(HttpServletRequest request) {
		String memId = request.getParameter("memId");
		String subject = request.getParameter("subject");
		String question = request.getParameter("question");
		
		if(subject == null || subject.isBlank()) {
			throw new BadException("질문 제목을 입력해주세요.");
		}
		
		if(question == null || question.isBlank()) {
			throw new BadException("질문 내용을 입력해주세요.");
		}
		
		UserDto user = (UserDto)request.getSession().getAttribute("member");
		
		QAndADto dto = new QAndADto();
		dto.setMemId(memId);
		dto.setSubject(subject);
		dto.setQuestion(question);
		QAndADao dao = QAndADao.getInstance();
		
		boolean result = false;
		
		if(user.getUserType().equals("admin")) {
			dto.setFix(1);
			result = dao.registerAdmin(dto);
		} else {
			result = dao.register(dto);
		}
		
		if(!result) {
			throw new BadException("등록 중에 오류가 발생하였습니다.");
		}
		
		
	}

}
~~~
