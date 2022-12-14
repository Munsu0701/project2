package controllers.seller;

import java.io.IOException;
import static jmsUtil.Utils.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import models.seller.ProductRemoveService;

@WebServlet ("/seller/ReqRemove")
public class ReqProductRemoveController extends HttpServlet {
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		try {
			ProductRemoveService service=new ProductRemoveService();
			service.productRemoveProcess(req);
		} catch (Exception e) {
			e.printStackTrace();
		}
		reloadPage(resp, "parent");
	}
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// TODO Auto-generated method stub
		super.doPost(req, resp);
	}

}
