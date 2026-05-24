package servlet;

import model.VehicleManager;
import model.Vehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/UpdateMileageServlet")
public class UpdateMileageServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String plate = request.getParameter("plate");
        String mileageStr = request.getParameter("mileage");

        if (plate != null && mileageStr != null) {
            try {
                int newMileage = Integer.parseInt(mileageStr);
                VehicleManager manager = new VehicleManager();

                for (Vehicle v : manager.getAllVehicles()) {
                    if (v.getLicensePlate().equals(plate)) {
                        manager.updateVehicle(plate, v.getMake(), v.getModel(), v.getYear(), newMileage);
                        break;
                    }
                }

                response.sendRedirect("customer_dashboard.jsp?mileageUpdated=true");
                return;
            } catch (NumberFormatException e) {
                // fall through to redirect
            }
        }

        response.sendRedirect("customer_dashboard.jsp");
    }
}
