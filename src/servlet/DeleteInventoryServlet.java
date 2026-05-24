package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/DeleteInventoryServlet")
public class DeleteInventoryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String deleteId = request.getParameter("deleteId");

        if (deleteId != null && !deleteId.isEmpty()) {
            InventoryManager manager = new InventoryManager();
            manager.deleteItem(deleteId);
        }

        // For fetch() calls, just send 200 OK (no redirect needed)
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
