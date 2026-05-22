package servlet;

import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteServiceServlet")
public class DeleteServiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Find out which record the user clicked "Delete" on
        String date = request.getParameter("date");
        String type = request.getParameter("type");
        String plate = request.getParameter("plate"); // <-- NEW ARGUMENT

        // 2. Open the server's memory (Session)
        HttpSession session = request.getSession();
        ServiceHistoryList list = (ServiceHistoryList) session.getAttribute("serviceList");

        // 3. If the list exists, delete the specific record
        if (list != null && date != null && type != null) {
            list.deleteRecord(date, type, plate);

            // ---> THIS IS THE NEW MAGIC MEMORY LINE! <---
            // This saves the train (with the deleted car removed) to your services.json file permanently.
            list.saveToFile();

            session.setAttribute("serviceList", list); // Save the updated list back to memory
        }

        // 4. SYNCHRONIZE BILLING (Wipe identical invoice securely)
        if (plate != null && date != null && type != null) {
            BillingManager bm = new BillingManager();
            bm.deleteInvoiceByMetadata(plate, date, type);
        }

        // 5. Send the user back to the dashboard
        response.sendRedirect("dashboard.jsp");
    }
}
