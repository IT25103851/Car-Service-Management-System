package servlet;
import model.*;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/DeleteVehicleServlet")
public class DeleteVehicleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionUser = (String) session.getAttribute("username");
        String sessionRole = (String) session.getAttribute("userRole");

        // Try getting plate from both parameter names
        String targetPlate = request.getParameter("plate");
        if (targetPlate == null || targetPlate.trim().isEmpty()) {
            targetPlate = request.getParameter("licensePlate");
        }

        String from = request.getParameter("from");
        String redirectUrl = "admin".equals(from) ? "manage_vehicles.jsp" : "customer_vehicles.jsp";

        if (targetPlate != null && !targetPlate.trim().isEmpty()) {
            VehicleManager vManager = new VehicleManager();

            // Security: verify the vehicle belongs to this customer OR user is admin
            boolean isAuthorized = "admin".equals(sessionRole);
            if (!isAuthorized) {
                for (Vehicle v : vManager.getAllVehicles()) {
                    if (v.getLicensePlate().equals(targetPlate) && v.getOwnerUsername().equals(sessionUser)) {
                        isAuthorized = true;
                        break;
                    }
                }
            }

            if (!isAuthorized) {
                response.sendRedirect(redirectUrl + "?error=unauthorized");
                return;
            }

            vManager.deleteVehicle(targetPlate);
            response.sendRedirect(redirectUrl + "?success=deleted");
        } else {
            response.sendRedirect(redirectUrl);
        }
    }
}
