package servlet;

import model.BillingManager;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdateInvoiceServlet")
public class UpdateInvoiceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String invoiceId = request.getParameter("invoiceId");
        String serviceDescription = request.getParameter("serviceDescription");
        String partsCostStr = request.getParameter("partsCost");
        String laborCostStr = request.getParameter("laborCost");

        try {
            double partsCost = Double.parseDouble(partsCostStr);
            double laborCost = Double.parseDouble(laborCostStr);

            BillingManager manager = new BillingManager();
            boolean success = manager.updateInvoice(invoiceId, serviceDescription, partsCost, laborCost);

            if (success) {
                response.sendRedirect("billing_dashboard.jsp?success=updated");
            } else {
                response.sendRedirect("billing_dashboard.jsp?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("billing_dashboard.jsp?error=invaliddata");
        }
    }
}
