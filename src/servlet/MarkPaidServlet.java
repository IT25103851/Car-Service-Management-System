package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/MarkPaidServlet")
public class MarkPaidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String targetInvoiceId = request.getParameter("invoiceId");

        // Mark invoice as PAID and persist to file
        BillingManager bm = new BillingManager();
        bm.markAsPaid(targetInvoiceId);

        // Also push a record into the service history linked list
        Invoice targeted = null;
        for (Invoice inv : bm.getAllInvoices()) {
            if (inv.getInvoiceId().equals(targetInvoiceId)) {
                targeted = inv;
                break;
            }
        }

        if (targeted != null) {
            // Auto-create Payment Record
            String paymentId = "PAY-" + (System.currentTimeMillis() % 100000);
            Payment payment = new Payment(paymentId, targetInvoiceId, targeted.getTotalAmount(), "Cash", java.time.LocalDate.now().toString(), "Auto-generated on Mark Paid");
            PaymentManager pm = new PaymentManager();
            pm.addPayment(payment);

            String fullDescription = targeted.getServiceDescription();
            String abstractService = fullDescription;
            String partsUsedLog = "No parts consumed.";

            if (fullDescription.contains("(Parts: ")) {
                int splitIndex = fullDescription.indexOf("(Parts: ");
                abstractService = fullDescription.substring(0, splitIndex).trim();
                partsUsedLog = fullDescription.substring(splitIndex + 8, fullDescription.length() - 1);
            }

            ServiceRecord historicalRecord = new ServiceRecord(
                targeted.getDateIssued(),
                abstractService,
                targeted.getTotalAmount(),
                targeted.getLicensePlate(),
                partsUsedLog
            );

            HttpSession session = request.getSession();
            ServiceHistoryList historyEngine = (ServiceHistoryList) session.getAttribute("serviceList");

            if (historyEngine == null) {
                historyEngine = new ServiceHistoryList();
                historyEngine.loadFromFile();
            }

            historyEngine.addRecord(historicalRecord);
            historyEngine.saveToFile();
            session.setAttribute("serviceList", historyEngine);
        }

        // Always redirect back to dashboard with success toast
        response.sendRedirect("billing_dashboard.jsp?success=paid");
    }
}
