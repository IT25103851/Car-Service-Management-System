package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/GenerateBillServlet")
public class GenerateBillServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Generate a random Invoice ID
        String invoiceId = "INV-" + (System.currentTimeMillis() % 100000);

        // 2. Catch the data from the form
        String customerUsername = request.getParameter("customerUsername");
        String licensePlate = request.getParameter("licensePlate").toUpperCase();
        String serviceDescription = request.getParameter("serviceDescription");

        double partsCost = Double.parseDouble(request.getParameter("partsCost"));
        double laborCost = Double.parseDouble(request.getParameter("laborCost"));

        // 3. Create the Invoice (The Blueprint calculates the total automatically!)
        Invoice newInvoice = new Invoice(invoiceId, customerUsername, licensePlate, serviceDescription, partsCost, laborCost);

        // 4. Push it onto the BillingManager's STACK
        BillingManager bm = new BillingManager();
        bm.generateInvoice(newInvoice);

        // 5. Go back to the dashboard to see the new bill at the TOP of the pile
        response.sendRedirect("billing_dashboard.jsp");
    }
}
