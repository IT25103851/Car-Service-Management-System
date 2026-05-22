package servlet;

import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AddServiceTypeServlet")
public class AddServiceTypeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String serviceName = request.getParameter("name");
        String category = request.getParameter("category");
        double basePrice = Double.parseDouble(request.getParameter("price"));

        ServiceTypeManager stm = new ServiceTypeManager();
        
        if ("edit".equals(action)) {
            stm.updateServiceType(serviceName, serviceName, category, basePrice);
            response.sendRedirect("manage_services.jsp?success=updated");
        } else {
            stm.addServiceType(new ServiceType(serviceName, category, basePrice));
            response.sendRedirect("manage_services.jsp?success=added");
        }
    }
}
