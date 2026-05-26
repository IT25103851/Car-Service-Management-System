package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/UpdateInventoryServlet")
public class UpdateInventoryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Catch the target ID and all potential fields
        String targetId = request.getParameter("itemId");
        String itemName = request.getParameter("itemName");
        String category = request.getParameter("category");
        String iconName = request.getParameter("iconName");
        String applicableService = request.getParameter("applicableService");
        
        String qtyStr = request.getParameter("newQuantity");
        if (qtyStr == null) qtyStr = request.getParameter("quantity");
        
        String priceStr = request.getParameter("newPrice");
        if (priceStr == null) priceStr = request.getParameter("price");

        InventoryManager manager = new InventoryManager();
        InventoryItem existingItem = manager.getItemById(targetId);

        if (existingItem != null) {
            // Use provided values safely or fall back to existing ones
            int newQuantity = existingItem.getQuantity();
            if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                try {
                    newQuantity = Integer.parseInt(qtyStr);
                } catch (NumberFormatException e) {
                    // Keep existing
                }
            }
            double newPrice = existingItem.getPrice();
            if (priceStr != null && !priceStr.trim().isEmpty()) {
                try {
                    newPrice = Double.parseDouble(priceStr);
                } catch (NumberFormatException e) {
                    // Keep existing
                }
            }
            
            if (itemName == null) itemName = existingItem.getItemName();
            if (category == null) category = existingItem.getCategory();
            if (iconName == null) iconName = existingItem.getIconName();
            if (applicableService == null) applicableService = existingItem.getApplicableService();

            // 2. Hand the updates to the manager
            manager.updateItem(targetId, itemName, category, newQuantity, newPrice, iconName, applicableService);
        }

        // 3. Detect AJAX calls (from inline +/- buttons) vs form submissions
        String fetchDest = request.getHeader("Sec-Fetch-Dest");
        if ("empty".equals(fetchDest)) {
            // AJAX/fetch call - just respond OK, no redirect
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            // Standard form submission - redirect back
            response.sendRedirect("inventory.jsp");
        }
    }
}
