<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*, java.util.*" %>
<%
    out.println("<h3>Initiating Hard Reset using JVM Abstract Paths...</h3>");

    // 1. Reset Services
    ServiceTypeManager stm = new ServiceTypeManager();
    // Clear out every single service using the Manager's native context
    List<ServiceType> services = stm.getAllServices();
    services.clear();
    
    // Inject brand new ones
    stm.addServiceType(new ServiceType("Standard Sedan Service", 8500.00));
    stm.addServiceType(new ServiceType("SUV Heavy Duty Maintenance", 18000.00));
    stm.addServiceType(new ServiceType("Hybrid System Check & Maintenance", 12500.00));
    stm.addServiceType(new ServiceType("Sports Car Performance Tuning", 35000.00));
    stm.addServiceType(new ServiceType("EV Powertrain Diagnostics", 22000.00));
    stm.addServiceType(new ServiceType("Crossover Suspension Overhaul", 16000.00));

    out.println("<p>Finished resetting Service Models. Proceeding to Inventory...</p>");

    // 2. Reset Inventory
    InventoryManager im = new InventoryManager();
    List<InventoryItem> items = im.getAllItems();
    items.clear();
    
    im.addItem(new InventoryItem("SED-OIL", "Sedan Synthetic Motor Oil", "Fluids", 24, 6500.00, "fa-oil-can", "Standard Sedan Service"));
    im.addItem(new InventoryItem("SED-FIL", "Standard Air Filter", "Engine", 15, 2500.00, "fa-gear", "Standard Sedan Service"));
    im.addItem(new InventoryItem("SUV-SHK", "Heavy Duty Shocks", "Suspension", 8, 45000.00, "fa-wrench", "SUV Heavy Duty Maintenance"));
    im.addItem(new InventoryItem("SUV-BRK", "Off-Road Brake Pads", "Brakes", 20, 12000.00, "fa-compact-disc", "SUV Heavy Duty Maintenance"));
    im.addItem(new InventoryItem("HYB-COL", "Hybrid Battery Coolant", "Fluids", 12, 8500.00, "fa-oil-can", "Hybrid System Check & Maintenance"));
    im.addItem(new InventoryItem("HYB-INV", "Inverter Assembly", "Electrical", 3, 145000.00, "fa-car-battery", "Hybrid System Check & Maintenance"));
    im.addItem(new InventoryItem("SPT-EXH", "Performance Exhaust Kit", "Engine", 4, 180000.00, "fa-wrench", "Sports Car Performance Tuning"));
    im.addItem(new InventoryItem("SPT-TRP", "Track Performance Tires", "Suspension", 16, 85000.00, "fa-gear", "Sports Car Performance Tuning"));
    im.addItem(new InventoryItem("EV-HVC", "High Voltage Cable Set", "Electrical", 10, 32000.00, "fa-car-battery", "EV Powertrain Diagnostics"));
    im.addItem(new InventoryItem("EV-BMS", "Battery Mgt System Sensor", "Electrical", 5, 28000.00, "fa-gear", "EV Powertrain Diagnostics"));
    im.addItem(new InventoryItem("CRS-STR", "Crossover Strut Assembly", "Suspension", 10, 24000.00, "fa-wrench", "Crossover Suspension Overhaul"));
    im.addItem(new InventoryItem("CRS-AXL", "CV Axle Shaft", "Engine", 6, 38000.00, "fa-gear", "Crossover Suspension Overhaul"));

    // Force flush the writes relying on the Java memory to push into Tomcat's hidden runtime folder
    im.saveToFile();

    out.println("<p style='color:green;'><b>DATABASE RESET COMPLETED SUCESSFULLY!</b></p>");
    out.println("<a href='inventory.jsp'>Return to Inventory</a>");
%>
