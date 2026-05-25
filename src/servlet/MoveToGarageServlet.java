package servlet;

import model.BookingManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/MoveToGarageServlet")
public class MoveToGarageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        BookingManager manager = new BookingManager();

        boolean success = false;
        if (id != null && !id.isEmpty()) {
            success = manager.moveToGarage(id);
        } else {
            // Default behavior: move the next in queue if no ID provided
            manager.moveToGarage();
            success = true;
        }

        if (success) {
            response.sendRedirect("manage_appointments.jsp?serviceStarted=true");
        } else {
            response.sendRedirect("manage_appointments.jsp?error=moveFailed");
        }
    }
}
