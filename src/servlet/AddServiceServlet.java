package servlet;

import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/AddServiceServlet")
public class AddServiceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. CATCH THE COMMON DATA
        String customerMode = request.getParameter("customerMode");
        String date = request.getParameter("date");
        String serviceType = request.getParameter("serviceType");
        
        String costStr = request.getParameter("cost");
        double partsCost = (costStr != null && !costStr.trim().isEmpty()) ? Double.parseDouble(costStr) : 0.0;
        
        String laborCostStr = request.getParameter("laborCost");
        double laborCost = (laborCostStr != null && !laborCostStr.trim().isEmpty()) ? Double.parseDouble(laborCostStr) : 0.0;
        
        double totalCost = partsCost + laborCost;
        
        String licensePlate = "";
        String targetCustomer = "";

        // WAKE UP THE MANAGERS
        HttpSession session = request.getSession();
        VehicleManager vm = (VehicleManager) session.getAttribute("vehicleManager");
        if (vm == null) {
            vm = new VehicleManager();
            session.setAttribute("vehicleManager", vm);
        }

        if ("registered".equals(customerMode)) {
            licensePlate = request.getParameter("licensePlate");
            targetCustomer = request.getParameter("selectedUsername");
            
            // Create a virtual appointment for chat
            String virtualAppId = "MAN" + (System.currentTimeMillis() % 100000);
            String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            Appointment virtualApp = new Appointment(virtualAppId, targetCustomer, licensePlate, date, "Walk-in", serviceType);
            virtualApp.setStatus("Completed");
            virtualApp.setCompletedDate(today);
            BookingManager bookingMgr = new BookingManager();
            bookingMgr.addCompletedAppointment(virtualApp);
            
        } else if ("walkin".equals(customerMode)) {
            licensePlate = request.getParameter("walkInPlate");
            String make = request.getParameter("walkInMake");
            String model = request.getParameter("walkInModel");
            int year = Integer.parseInt(request.getParameter("walkInYear"));
            
            String mileageStr = request.getParameter("walkInMileage");
            int mileage = (mileageStr != null && !mileageStr.trim().isEmpty()) ? Integer.parseInt(mileageStr) : 0;
            
            String walkInName = request.getParameter("walkInName");
            if (walkInName == null || walkInName.trim().isEmpty()) {
                walkInName = "Walk-in Customer";
            }
            
            // Create a pseudo-username for the walk-in
            targetCustomer = "WALKIN_" + walkInName.replaceAll("[^a-zA-Z0-9]", "");
            if (targetCustomer.equals("WALKIN_")) {
                targetCustomer = "WALKIN_GUEST";
            }

            // Auto-register the vehicle if it doesn't exist
            if (!vm.vehicleExists(licensePlate)) {
                Vehicle walkInCar = new Vehicle(licensePlate, make, model, year, mileage, targetCustomer);
                vm.addVehicle(walkInCar);
            } else {
                // If the car exists but it's a walk-in, we just use the existing owner
                for (Vehicle v : vm.getAllVehicles()) {
                    if (v.getLicensePlate().equalsIgnoreCase(licensePlate)) {
                        targetCustomer = v.getOwnerUsername();
                        break;
                    }
                }
            }
        } else {
            // Fallback for older forms if needed
            licensePlate = request.getParameter("licensePlate");
            targetCustomer = "MANUAL_ENTRY";
            for (Vehicle v : vm.getAllVehicles()) {
                if (v.getLicensePlate() != null && v.getLicensePlate().equals(licensePlate)) {
                    targetCustomer = v.getOwnerUsername();
                    break;
                }
            }
        }

        // 2. BOX IT UP (Date, Type, Cost, Plate)
        ServiceRecord newRecord = new ServiceRecord(date, serviceType, totalCost, licensePlate);

        // 3. WAKE UP THE MEMORY
        ServiceHistoryList list = (ServiceHistoryList) session.getAttribute("serviceList");

        if (list == null) {
            list = new ServiceHistoryList();
            list.loadFromFile();
        }

        // 4. ADD & SAVE PERMANENTLY
        list.addRecord(newRecord);
        list.saveToFile();

        session.setAttribute("serviceList", list);

        // 5. SYNCHRONIZE WITH BILLING STACK
        String autoInvId = "INV" + (System.currentTimeMillis() % 100000);
        Invoice autoSyncBill = new Invoice(autoInvId, targetCustomer, licensePlate, serviceType, partsCost, laborCost);
        autoSyncBill.setDateIssued(date);
        
        if ("registered".equals(customerMode)) {
            autoSyncBill.setStatus("UNPAID");
        } else {
            autoSyncBill.setStatus("PAID"); // It's manual entry, assuming it's already reconciled physically
        }
        
        BillingManager bm = new BillingManager();
        bm.generateInvoice(autoSyncBill);

        // 6. GO BACK TO DASHBOARD
        response.sendRedirect("dashboard.jsp");
    }
}
