package servlet;

import model.ServiceTypeManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteServiceTypeServlet")
public class DeleteServiceTypeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name = request.getParameter("name");
        if (name != null && !name.trim().isEmpty()) {
            ServiceTypeManager stm = new ServiceTypeManager();
            stm.deleteServiceType(name);
        }

        response.sendRedirect("manage_services.jsp?success=deleted");
    }
}
