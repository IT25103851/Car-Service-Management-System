package servlet;

import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/AddPaymentServlet")
public class AddPaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String invoiceId = request.getParameter("invoiceId");
        String amountStr = request.getParameter("amount");
        String paymentMethod = request.getParameter("paymentMethod");
        String referenceNote = request.getParameter("referenceNote");
        String paymentDate = request.getParameter("paymentDate");
        String redirect = request.getParameter("redirect");

        if (paymentDate == null || paymentDate.isEmpty()) {
            paymentDate = LocalDate.now().toString();
        }

        try {
            double amount = Double.parseDouble(amountStr);
            String paymentId = "PAY-" + (System.currentTimeMillis() % 100000);
            
            Payment payment = new Payment(paymentId, invoiceId, amount, paymentMethod, paymentDate, referenceNote);
            PaymentManager pm = new PaymentManager();
            pm.addPayment(payment);

            // Check if invoice is now fully paid
            BillingManager bm = new BillingManager();
            Invoice inv = bm.getInvoiceById(invoiceId);
            if (inv != null) {
                List<Payment> payments = pm.getPaymentsByInvoiceId(invoiceId);
                double totalPaid = 0;
                for (Payment p : payments) {
                    totalPaid += p.getAmount();
                }
                if (totalPaid >= inv.getTotalAmount()) {
                    bm.markAsPaid(invoiceId);
                }
            }
            
            if (redirect != null && !redirect.isEmpty()) {
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect("billing_dashboard.jsp?success=payment_added");
            }
        } catch (NumberFormatException e) {
            if (redirect != null && !redirect.isEmpty()) {
                response.sendRedirect(redirect.contains("?") ? redirect + "&error=invalidpayment" : redirect + "?error=invalidpayment");
            } else {
                response.sendRedirect("billing_dashboard.jsp?error=invalidpayment");
            }
        }
    }
}
