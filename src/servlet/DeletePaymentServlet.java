package servlet;

import model.PaymentManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/DeletePaymentServlet")
public class DeletePaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String paymentId = request.getParameter("paymentId");

        if (paymentId != null && !paymentId.isEmpty()) {
            PaymentManager pm = new PaymentManager();
            pm.deletePayment(paymentId);
        }

        response.sendRedirect("billing_dashboard.jsp?success=payment_deleted");
    }
}
