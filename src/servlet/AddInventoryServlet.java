package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/AddInventoryServlet")
public class AddInventoryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. CATCH THE DATA from the HTML form
        String itemId = request.getParameter("itemId");
        String itemName = request.getParameter("itemName");
        String category = request.getParameter("category");
        String iconName = request.getParameter("iconName");
        String applicableService = request.getParameter("applicableService");

        // Basic sanity checks
        if (itemId == null || itemId.trim().isEmpty() || itemName == null || itemName.trim().isEmpty()) {
            response.sendRedirect("add_inventory.jsp?error=emptyFields");
            return;
        }

        itemId = itemId.trim().toUpperCase();

        // Translate the text inputs into math numbers safely
        int quantity = 0;
        double price = 0.0;
        try {
            String qtyStr = request.getParameter("quantity");
            if (qtyStr != null && !qtyStr.isEmpty()) quantity = Integer.parseInt(qtyStr);
            String priceStr = request.getParameter("price");
            if (priceStr != null && !priceStr.isEmpty()) price = Double.parseDouble(priceStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("add_inventory.jsp?error=invalidNumeric");
            return;
        }

        InventoryManager manager = new InventoryManager();
        
        // Check for duplicates
        if (manager.getItemById(itemId) != null) {
            response.sendRedirect("add_inventory.jsp?error=duplicateId&id=" + itemId);
            return;
        }

        // 2. BOX IT UP into our Inventory Blueprint
        InventoryItem newItem = new InventoryItem(itemId, itemName, category, quantity, price, iconName, applicableService);

        // 3. HAND IT TO THE MANAGER to save permanently
        manager.addItem(newItem);

        // 4. SEND THE BOSS BACK TO THE DASHBOARD with success toast
        response.sendRedirect("inventory.jsp?addSuccess=true");
    }
}
