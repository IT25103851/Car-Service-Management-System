package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryManager {
    private List<InventoryItem> inventoryList;
    private final String FILE_PATH = Main.getFilePath("inventory.txt");

    public InventoryManager() {
        this.inventoryList = new ArrayList<>();
        loadFromFile();
        
        // Auto-bootstrap default inventory linked to the abstract service nodes
        if (inventoryList.isEmpty()) {
            // Sedan
            this.inventoryList.add(new InventoryItem("SED-OIL", "Sedan Synthetic Motor Oil", "Fluids", 24, 6500.00, "fa-oil-can", "Standard Sedan Service"));
            this.inventoryList.add(new InventoryItem("SED-FIL", "Standard Air Filter", "Engine", 15, 2500.00, "fa-gear", "Standard Sedan Service"));
            
            // SUV
            this.inventoryList.add(new InventoryItem("SUV-SHK", "Heavy Duty Shocks", "Suspension", 8, 45000.00, "fa-wrench", "SUV Heavy Duty Maintenance"));
            this.inventoryList.add(new InventoryItem("SUV-BRK", "Off-Road Brake Pads", "Brakes", 20, 12000.00, "fa-compact-disc", "SUV Heavy Duty Maintenance"));
            
            // Hybrid
            this.inventoryList.add(new InventoryItem("HYB-COL", "Hybrid Battery Coolant", "Fluids", 12, 8500.00, "fa-oil-can", "Hybrid System Check & Maintenance"));
            this.inventoryList.add(new InventoryItem("HYB-INV", "Inverter Assembly", "Electrical", 3, 145000.00, "fa-car-battery", "Hybrid System Check & Maintenance"));
            
            // Sports
            this.inventoryList.add(new InventoryItem("SPT-EXH", "Performance Exhaust Kit", "Engine", 4, 180000.00, "fa-wrench", "Sports Car Performance Tuning"));
            this.inventoryList.add(new InventoryItem("SPT-TRP", "Track Performance Tires", "Suspension", 16, 85000.00, "fa-gear", "Sports Car Performance Tuning"));
            
            // EV
            this.inventoryList.add(new InventoryItem("EV-HVC", "High Voltage Cable Set", "Electrical", 10, 32000.00, "fa-car-battery", "EV Powertrain Diagnostics"));
            this.inventoryList.add(new InventoryItem("EV-BMS", "Battery Mgt System Sensor", "Electrical", 5, 28000.00, "fa-gear", "EV Powertrain Diagnostics"));
            
            // Crossover
            this.inventoryList.add(new InventoryItem("CRS-STR", "Crossover Strut Assembly", "Suspension", 10, 24000.00, "fa-wrench", "Crossover Suspension Overhaul"));
            this.inventoryList.add(new InventoryItem("CRS-AXL", "CV Axle Shaft", "Engine", 6, 38000.00, "fa-gear", "Crossover Suspension Overhaul"));
            
            saveToFile();
        }
    }

    // 1. READ ALL ITEMS
    public List<InventoryItem> getAllItems() {
        return inventoryList;
    }

    // 2. ADD A NEW ITEM
    public void addItem(InventoryItem newItem) {
        inventoryList.add(newItem);
        saveToFile();
    }

    // 3. DELETE AN ITEM
    public void deleteItem(String targetId) {
        inventoryList.removeIf(item -> item.getItemId().trim().equalsIgnoreCase(targetId.trim()));
        saveToFile();
    }

    // 4. FIND AN ITEM BY ID
    public InventoryItem getItemById(String targetId) {
        for (InventoryItem item : inventoryList) {
            if (item.getItemId().trim().equalsIgnoreCase(targetId.trim())) {
                return item;
            }
        }
        return null;
    }

    // 5. UPDATE AN ITEM'S STOCK OR PRICE (NEWLY ADDED!)
    public void updateItem(String targetId, String itemName, String category, int newQuantity, double newPrice, String iconName, String applicableService) {
        for (InventoryItem item : inventoryList) {
            if (item.getItemId().trim().equalsIgnoreCase(targetId.trim())) {
                if (itemName != null) item.setItemName(itemName);
                if (category != null) item.setCategory(category);
                item.setQuantity(newQuantity);
                item.setPrice(newPrice);
                if (iconName != null) item.setIconName(iconName);
                if (applicableService != null) item.setApplicableService(applicableService);
                break; // Stop searching once we find it!
            }
        }
        saveToFile(); // Save the new numbers to the TXT file
    }

    // --- SAVE TO FILE ---
    // Format: itemId|itemName|category|quantity|price|iconName|applicableService
    public void saveToFile() {
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH));
            for (InventoryItem item : inventoryList) {
                writer.write(item.getItemId() + "|" + item.getItemName() + "|" + item.getCategory() + "|" +
                             item.getQuantity() + "|" + item.getPrice() + "|" + item.getIconName() + "|" +
                             item.getApplicableService());
                writer.newLine();
            }
            writer.flush();
            writer.close();
        } catch (IOException e) {
            System.out.println("Error saving inventory: " + e.getMessage());
        }
    }

    // --- LOAD FROM FILE ---
    public void loadFromFile() {
        File file = new File(FILE_PATH);
        if (!file.exists()) {
            System.out.println("No inventory file found. Starting fresh!");
            return;
        }

        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            String line;
            this.inventoryList = new ArrayList<>();
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 7) {
                    try {
                        int quantity = Integer.parseInt(parts[3]);
                        double price = Double.parseDouble(parts[4]);
                        InventoryItem item = new InventoryItem(parts[0], parts[1], parts[2], quantity, price, parts[5], parts[6]);
                        inventoryList.add(item);
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid inventory line: " + line);
                    }
                }
            }
            reader.close();
        } catch (IOException e) {
            System.out.println("Error loading inventory: " + e.getMessage());
        }
    }
}