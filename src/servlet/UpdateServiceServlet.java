package servlet;

import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/UpdateServiceServlet")
public class UpdateServiceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Grab the OLD details AND the Target Plate!
        String oldDate = request.getParameter("oldDate");
        String oldType = request.getParameter("oldType");
        String targetPlate = request.getParameter("targetPlate");

        // 2. Grab the NEW details
        String newDate = request.getParameter("newDate");
        String newType = request.getParameter("newType");
        double newCost = Double.parseDouble(request.getParameter("newCost"));

        // 3. Open the server's memory
        HttpSession session = request.getSession();
        ServiceHistoryList list = (ServiceHistoryList) session.getAttribute("serviceList");

        if (list != null) {
            // 4. Use the Upgraded Magic Eraser! (Now passing targetPlate)
            list.updateRecord(oldDate, oldType, targetPlate, newDate, newType, newCost);

            list.saveToFile();
            session.setAttribute("serviceList", list);
        }

        // 5. SYNCHRONIZE BILLING RECORD DYNAMICALLY
        BillingManager bm = new BillingManager();
        bm.updateInvoiceByMetadata(targetPlate, oldDate, oldType, newDate, newType, newCost);

        response.sendRedirect("dashboard.jsp");
    }
}
