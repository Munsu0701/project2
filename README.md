# WorkoutProject

댓글 쓰기

~~~
package controller.comment;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.comment.CommentWriteService;
import static jmsUtil.Utils.*;

@WebServlet("/board/comment")
public class CommentController extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		try {
			CommentWriteService service = new CommentWriteService();
			service.write(req);
			
			reloadPage(resp, "parent");
		} catch (RuntimeException e) {
			e.printStackTrace();
			showAlertException(resp, e);
		}
		
	}

}

~~~
- 기능 구현 
~~~
package models.comment;

import javax.servlet.http.HttpServletRequest;

import exception.BadException;

public class CommentWriteService {
	
	public void write(HttpServletRequest request) {
		String boardId = request.getParameter("boardId");
		String gid = request.getParameter("gid");
		String userName = request.getParameter("userName");
		String content = request.getParameter("content");
		
		if(content == null || content.isBlank()) {
			throw new BadException("댓글 내용을 입력하지 않았습니다.");
		}
		
		CommentDao dao = CommentDao.getInstance();
		CommentDto dto = new CommentDto();
		dto.setBoardId(boardId);
		dto.setGid(gid);
		dto.setUserName(userName);
		dto.setContent(content);
		
		dao.register(dto);
		
	}

}
~~~

댓글 삭제(관리자 또는 작성자만 삭제 가능)
~~~
package controller.comment;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.comment.CommentDeleteService;

@WebServlet("/comment/delete")
public class CommentDeleteController extends HttpServlet{
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String gid = req.getParameter("gid");
		
		CommentDeleteService service = new CommentDeleteService();
		service.delete(req);
		
		
		resp.setContentType("text/html;charset=UTF-8");
		PrintWriter out = resp.getWriter();
		out.println("<script>this.location.replace('" + req.getContextPath() + "/board/view?gid=" + gid + "')" + "</script>");
		
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doGet(req, resp);
	}

}
~~~
- 기능 
~~~
package models.comment;

import javax.servlet.http.HttpServletRequest;

public class CommentDeleteService {
	
	public void delete(HttpServletRequest request) {
		String id = request.getParameter("id");
		
		CommentDao dao = CommentDao.getInstance();
		CommentDto dto = new CommentDto();
		dto.setId(Integer.parseInt(id));
		
		dao.delete(dto);
	}

}
~~~

댓글 수정
~~~
package controller.comment;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.comment.CommentUpdateService;
import static jmsUtil.Utils.*;

@WebServlet("/comment/update")
public class CommentUpdateController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		doPost(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("utf-8");
		
		CommentUpdateService service = new CommentUpdateService();
		service.update(req);
		
		reloadPage(resp, "parent");
	}
	
}
~~~
- 기능 
~~~
package models.comment;

import javax.servlet.http.HttpServletRequest;

public class CommentUpdateService {
	
	public void update(HttpServletRequest request) {
		
		String content = request.getParameter("content");
		String id = request.getParameter("id");
		
		CommentDao dao = CommentDao.getInstance();
		CommentDto dto = new CommentDto();
		
		dto.setContent(content);
		dto.setId(Integer.parseInt(id));
		
		dao.update(dto);
		
	}

}
~~~
