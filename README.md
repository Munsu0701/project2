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
~~~
~~~
public int count() {
		
		SqlSession sqlSession = Connection.getSession();
		
		int count = sqlSession.selectOne("RequestProductMap.reqCount");
		
		return count;
	}
~~~

