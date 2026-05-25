package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/BookAppointmentServlet")
public class BookAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");

        // Generate a random ID for the ticket (e.g., APP-16928374)
        String appointmentId = "APP-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String licensePlate = request.getParameter("licensePlate");
        String date = request.getParameter("preferredDate");
        String time = request.getParameter("preferredTime");
        String issue = request.getParameter("issueDescription");

        // Create the new appointment object
        Appointment newApp = new Appointment(appointmentId, username, licensePlate, date, time, issue);

        // Add to the Queue!
        BookingManager manager = new BookingManager();
        manager.addAppointment(newApp);

        // Send customer back to their dashboard
        response.sendRedirect("customer_dashboard.jsp");
    }
}
