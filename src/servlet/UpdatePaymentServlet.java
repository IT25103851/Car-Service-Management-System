package servlet;

import model.PaymentManager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdatePaymentServlet")
public class UpdatePaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String paymentId = request.getParameter("paymentId");
        String amountStr = request.getParameter("amount");
        String paymentMethod = request.getParameter("paymentMethod");
        String referenceNote = request.getParameter("referenceNote");
        String paymentDate = request.getParameter("paymentDate");

        try {
            double amount = Double.parseDouble(amountStr);
            PaymentManager pm = new PaymentManager();
            boolean success = pm.updatePayment(paymentId, amount, paymentMethod, paymentDate, referenceNote);
            
            if (success) {
                response.sendRedirect("billing_dashboard.jsp?success=payment_updated");
            } else {
                response.sendRedirect("billing_dashboard.jsp?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("billing_dashboard.jsp?error=invalidpayment");
        }
    }
}
