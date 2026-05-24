package servlet;

import model.BillingManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/VoidInvoiceServlet")
public class VoidInvoiceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String invoiceId = request.getParameter("invoiceId");
        String voidReason = request.getParameter("voidReason");
        if (voidReason == null || voidReason.isEmpty()) voidReason = "Admin Voided";

        if (invoiceId != null && !invoiceId.trim().isEmpty()) {
            BillingManager bm = new BillingManager();
            bm.voidInvoice(invoiceId, voidReason);
        }

        // Always redirect back to dashboard with success toast
        response.sendRedirect("billing_dashboard.jsp?success=voided");
    }
}
