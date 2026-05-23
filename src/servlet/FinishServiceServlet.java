package servlet;

import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/FinishServiceServlet")
public class FinishServiceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String appId = request.getParameter("appId");
        String licensePlate = request.getParameter("licensePlate");
        String customerUsername = request.getParameter("customerUsername");
        String serviceName = request.getParameter("serviceName");

        InventoryManager im = new InventoryManager();
        List<InventoryItem> allParts = im.getAllItems();
        double partsCost = 0.0;
        StringBuilder partsConsumed = new StringBuilder();

        // 1. Loop through ALL inputs checking if the admin logged quantity for that specific part!
        for (InventoryItem part : allParts) {
            String qtyStr = request.getParameter("qty_" + part.getItemId());
            if (qtyStr != null && !qtyStr.isEmpty()) {
                int consumedQty = Integer.parseInt(qtyStr);
                if (consumedQty > 0) {
                    // Update the remaining physical inventory natively
                    int newRemainingStock = part.getQuantity() - consumedQty;
                    im.updateItem(part.getItemId(), part.getItemName(), part.getCategory(), newRemainingStock, part.getPrice(), part.getIconName(), part.getApplicableService());
                    
                    partsCost += (consumedQty * part.getPrice());
                    partsConsumed.append(consumedQty).append("x ").append(part.getItemName()).append(", ");
                }
            }
        }

        // Clean up formatting of parts list
        String partsDescr = partsConsumed.toString();
        if (partsDescr.endsWith(", ")) {
            partsDescr = partsDescr.substring(0, partsDescr.length() - 2);
        }

        // 2. Read the directly inputted labor cost from the form!
        double laborCost = 0.0;
        String laborCostStr = request.getParameter("laborCost");
        if (laborCostStr != null && !laborCostStr.trim().isEmpty()) {
            laborCost = Double.parseDouble(laborCostStr);
        }

        // 3. Generate the Invoice (Random ID formulation)
        String invoiceId = "INV-" + System.currentTimeMillis() % 10000;
        
        // Optionally bind parts to the invoice description for the customer to see
        String fullDescription = serviceName;
        if (!partsDescr.isEmpty()) fullDescription += " (Parts: " + partsDescr + ")";

        Invoice newBill = new Invoice(invoiceId, customerUsername, licensePlate, fullDescription, partsCost, laborCost);
        
        BillingManager bm = new BillingManager();
        bm.generateInvoice(newBill);

        // 4. Create a Service History record for the customer's dashboard
        String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
        ServiceRecord record = new ServiceRecord(today, serviceName, partsCost + laborCost, licensePlate, partsDescr.isEmpty() ? "No physical parts recorded." : partsDescr);
        ServiceHistoryList historyList = new ServiceHistoryList();
        historyList.loadFromFile();
        historyList.addRecord(record);
        historyList.saveToFile();

        // 5. Migrate the vehicle out of the active garage queue inherently pushing it to Completed status
        BookingManager bookingManager = new BookingManager();
        bookingManager.moveFromGarageToCompleted(appId);

        // Return admin to the checkout lane!
        response.sendRedirect("billing_dashboard.jsp?success=billed");
    }
}
