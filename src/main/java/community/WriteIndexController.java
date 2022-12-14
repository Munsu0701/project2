package community;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import community.dto.CommunityDto;

@WebServlet("/writeIndex")
public class WriteIndexController extends HttpServlet{

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
		}catch (RuntimeException e) {
			e.printStackTrace();
		}
		String [] addJs = {"ckeditor/ckeditor", "board/writeIndex"};
		req.setAttribute("addJs", addJs);
		RequestDispatcher rd = req.getRequestDispatcher("/community/writeIndex.jsp");
		rd.forward(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			String type = req.getParameter("type");
			String poster = req.getParameter("poster");
			
			System.out.println(type);
			
			
			
	}
}
