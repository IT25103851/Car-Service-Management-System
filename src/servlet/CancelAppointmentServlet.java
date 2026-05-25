package servlet;

import model.BookingManager;
import model.Appointment;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/CancelAppointmentServlet")
public class CancelAppointmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionUser = (String) session.getAttribute("username");
        String appointmentId = request.getParameter("appointmentId");
        
        if (appointmentId != null && !appointmentId.isEmpty()) {
            BookingManager manager = new BookingManager();

            // Security: verify the appointment belongs to this customer
            boolean isOwner = false;
            List<Appointment> allApps = manager.getAllAppointmentsNatively();
            for (Appointment app : allApps) {
                if (app.getAppointmentId().equals(appointmentId) && app.getCustomerUsername().equals(sessionUser)) {
                    isOwner = true;
                    break;
                }
            }

            if (!isOwner) {
                response.sendRedirect("customer_dashboard.jsp?error=cancelFailed");
                return;
            }

            boolean success = manager.removeAppointment(appointmentId);
            
            if (success) {
                response.sendRedirect("customer_dashboard.jsp?cancelSuccess=true");
            } else {
                response.sendRedirect("customer_dashboard.jsp?error=cancelFailed");
            }
        } else {
            response.sendRedirect("customer_dashboard.jsp?error=invalidId");
        }
    }
}
