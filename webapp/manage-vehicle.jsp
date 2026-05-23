<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.VehicleManager, model.Vehicle, java.util.List" %>
<%-- Navbar moved --%>

<%
    // SECURITY Bouncer: Only the Admin (Shop Boss) is allowed in this room!
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Vehicles - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style> body { background: #f9fafc; } </style>
</head>
<body class="antialiased text-gray-900">
<%@ include file="navbar.jsp" %>
<div class="pt-24">

<div class="max-w-7xl mx-auto py-10 px-4 sm:px-6 lg:px-8">

    <div class="mb-8">
        <h1 class="text-3xl font-extrabold text-indigo-900"><i class="fa-solid fa-car-side mr-3"></i>Vehicle Management Center</h1>
        <p class="mt-2 text-sm text-gray-600">Register new vehicles and link them to their owners here.</p>
    </div>


    <div class="bg-white shadow-xl rounded-2xl border border-gray-100 overflow-hidden overflow-x-auto w-full">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-indigo-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">License Plate</th>
                    <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Car Details</th>
                    <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Mileage</th>
                    <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Owner Username</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200 bg-white">
                <%
                    VehicleManager vManager = (VehicleManager) session.getAttribute("vehicleManager");
                    if (vManager == null) {
                        vManager = new VehicleManager();
                        session.setAttribute("vehicleManager", vManager);
                    }

                    List<Vehicle> allCars = vManager.getAllVehicles();

                    if (allCars.isEmpty()) {
                %>
                        <tr><td colspan="4" class="px-6 py-8 text-center text-gray-500 italic">No vehicles registered yet.</td></tr>
                <%
                    } else {
                        for (Vehicle car : allCars) {
                %>
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-indigo-600"><%= car.getLicensePlate() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= car.getYear() %> <%= car.getMake() %> <%= car.getModel() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= car.getMileage() %> km</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs"><%= car.getOwnerUsername() %></span></td>
                        </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>