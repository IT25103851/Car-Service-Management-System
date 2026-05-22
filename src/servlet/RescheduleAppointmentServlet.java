package servlet;

import model.BookingManager;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/RescheduleAppointmentServlet")
public class RescheduleAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String appointmentId = request.getParameter("appointmentId");
        String newDate = request.getParameter("preferredDate");
        String newTime = request.getParameter("preferredTime");
        
        if (appointmentId != null && !appointmentId.isEmpty() && newDate != null && newTime != null) {
            BookingManager manager = new BookingManager();
            boolean success = manager.updateAppointment(appointmentId, newDate, newTime);
            
            if (success) {
                response.sendRedirect("customer_dashboard.jsp?rescheduleSuccess=true");
            } else {
                response.sendRedirect("customer_dashboard.jsp?error=rescheduleFailed");
            }
        } else {
            response.sendRedirect("customer_dashboard.jsp?error=invalidData");
        }
    }
}
