package servlet;

import model.BillingManager;
import model.Invoice;
import model.Payment;
import model.PaymentManager;
import model.ServiceHistoryList;
import model.ServiceRecord;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/ReinstateInvoiceServlet")
public class ReinstateInvoiceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String invoiceId = request.getParameter("invoiceId");

        if (invoiceId != null && !invoiceId.trim().isEmpty()) {
            BillingManager bm = new BillingManager();
            Invoice inv = bm.getInvoiceById(invoiceId);
            
            if (inv != null && "VOID".equals(inv.getStatus())) {
                LocalDate issued = LocalDate.parse(inv.getDateIssued());
                LocalDate now = LocalDate.now();
                if (issued.plusMonths(6).isAfter(now) || issued.plusMonths(6).isEqual(now)) {
                    bm.reinstateInvoice(invoiceId);
                    
                    String paymentId = "PAY-" + (System.currentTimeMillis() % 100000);
                    Payment payment = new Payment(paymentId, invoiceId, inv.getTotalAmount(), "Cash", java.time.LocalDate.now().toString(), "Reinstated from Void");
                    PaymentManager pm = new PaymentManager();
                    pm.addPayment(payment);

                    String fullDescription = inv.getServiceDescription();
                    String abstractService = fullDescription;
                    String partsUsedLog = "No parts consumed.";

                    if (fullDescription.contains("(Parts: ")) {
                        int splitIndex = fullDescription.indexOf("(Parts: ");
                        abstractService = fullDescription.substring(0, splitIndex).trim();
                        partsUsedLog = fullDescription.substring(splitIndex + 8, fullDescription.length() - 1);
                    }

                    ServiceRecord historicalRecord = new ServiceRecord(
                        inv.getDateIssued(),
                        abstractService,
                        inv.getTotalAmount(),
                        inv.getLicensePlate(),
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
                    
                    response.sendRedirect("billing_dashboard.jsp?success=reinstated");
                    return;
                }
            }
        }
        response.sendRedirect("billing_dashboard.jsp?error=invalid_reinstate");
    }
}
