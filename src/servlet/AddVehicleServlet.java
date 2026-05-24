package servlet;
import model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AddVehicleServlet")
public class AddVehicleServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. CATCH THE DATA!
        String plate = request.getParameter("licensePlate");
        String make = request.getParameter("make");
        String model = request.getParameter("model");
        int year = Integer.parseInt(request.getParameter("year"));
        int mileage = Integer.parseInt(request.getParameter("mileage"));
        String owner = request.getParameter("ownerUsername");

        // 2. Check if this is an EDIT or a NEW registration
        String editMode = request.getParameter("editMode");

        HttpSession session = request.getSession();
        VehicleManager vManager = (VehicleManager) session.getAttribute("vehicleManager");
        if (vManager == null) {
            vManager = new VehicleManager();
        }

        if ("true".equals(editMode)) {
            // EDIT MODE: Update existing vehicle via its original plate
            String originalPlate = request.getParameter("originalPlate");
            if (originalPlate != null) {
                vManager.updateVehicle(originalPlate, make, model, year, mileage);
            }
            session.setAttribute("vehicleManager", vManager);

            String target = request.getParameter("redirect");
            if (target == null || target.trim().isEmpty()) {
                target = "manage_vehicles.jsp?success=updated";
            }
            response.sendRedirect(target);
        } else {
            // ADD MODE: Create and save a new vehicle
            Vehicle newCar = new Vehicle(plate, make, model, year, mileage, owner);
            vManager.addVehicle(newCar);
            session.setAttribute("vehicleManager", vManager);

            String target = request.getParameter("redirect");
            if (target == null || target.trim().isEmpty()) {
                target = "manage_vehicles.jsp?success=added";
            }
            response.sendRedirect(target);
        }
    }
}
