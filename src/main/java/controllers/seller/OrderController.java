package controllers.seller;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.mysql.cj.x.protobuf.MysqlxCrud.Limit;

import dto.UserDto;
import models.bookshop.BookPaymentDto;
import models.bookshop.BookProgress;
import models.seller.BookPaymentLimitDto;
import models.seller.OrderService;
import static jmsUtil.Utils.*;

@WebServlet("/seller/order")
public class OrderController extends HttpServlet{
	private int offset=10;
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String[] addCss = new String[] { "/seller/order" };
		req.setAttribute("addCss", addCss);
		OrderService orderService=new OrderService(req,resp);

		UserDto loginUser=getLoginUser(req);
		
		RequestDispatcher rd=req.getRequestDispatcher("/jmsPage/order.jsp");
		String progress=(String) req.getParameter("progress");
		int num=Integer.parseInt(req.getParameter("num")); 
		
		
		System.out.println(progress);
		try {
			PaymentDao dao=PaymentDao.getInstance();
			BookPaymentLimitDto bookPaymentDto=new BookPaymentLimitDto();
			if (progress!=null&&!progress.isBlank()) {
				bookPaymentDto.setProgress(progress);
				System.out.println("스킵");
			}
			bookPaymentDto.setSeller(loginUser.getId());
			bookPaymentDto.setOffset(offset);
			bookPaymentDto.setStart(offset*(num-1));
			double total= orderService.setOrderProcessTotalCount(bookPaymentDto);
			int totalPage=(int)Math.ceil(total/offset) ;
			req.setAttribute("totalPage",totalPage);
			
			req.setAttribute("list", dao.gets(bookPaymentDto));
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		rd.forward(req, resp);
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		OrderService service=new OrderService(req,resp);
		try {
			service.setOrderProcess();
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		
		reloadPage(resp, "parent");
	}
}
