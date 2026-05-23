package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceTypeManager {
    private List<ServiceType> serviceTypes;
    private final String FILE_PATH = Main.getFilePath("service_types.txt");

    public ServiceTypeManager() {
        this.serviceTypes = new ArrayList<>();
        loadFromFile();
        
        // Check for legacy data
        boolean hasLegacy = false;
        for (ServiceType st : serviceTypes) {
            if (st.getServiceName().equals("Standard Wash")) {
                hasLegacy = true; 
                break;
            }
        }

        // Auto-bootstrap default physical service nodes if database misses initialization or holds old data!
        if (serviceTypes.isEmpty() || hasLegacy) {
            this.serviceTypes.clear();
            this.serviceTypes.add(new ServiceType("Standard Sedan Service", "Maintenance", 8500.00));
            this.serviceTypes.add(new ServiceType("SUV Heavy Duty Maintenance", "Maintenance", 18000.00));
            this.serviceTypes.add(new ServiceType("Hybrid System Check & Maintenance", "Diagnostic", 12500.00));
            this.serviceTypes.add(new ServiceType("Sports Car Performance Tuning", "Repair", 35000.00));
            this.serviceTypes.add(new ServiceType("EV Powertrain Diagnostics", "Diagnostic", 22000.00));
            this.serviceTypes.add(new ServiceType("Crossover Suspension Overhaul", "Repair", 16000.00));
            saveToFile();
        }
    }

    public List<ServiceType> getAllServices() {
        return serviceTypes;
    }

    public void addServiceType(ServiceType st) {
        serviceTypes.add(st);
        saveToFile();
    }
    
    public void deleteServiceType(String serviceName) {
        serviceTypes.removeIf(st -> st.getServiceName().trim().equalsIgnoreCase(serviceName.trim()));
        saveToFile();
    }

    public void updateServiceType(String targetName, String newName, String newCategory, double newPrice) {
        for (ServiceType st : serviceTypes) {
            if (st.getServiceName().trim().equalsIgnoreCase(targetName.trim())) {
                st.setServiceName(newName);
                st.setCategory(newCategory);
                st.setDefaultBasePrice(newPrice);
                break;
            }
        }
        saveToFile();
    }

    // Format: serviceName|defaultBasePrice
    private void saveToFile() {
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH));
            for (ServiceType st : serviceTypes) {
                writer.write(st.getServiceName() + "|" + st.getCategory() + "|" + st.getDefaultBasePrice());
                writer.newLine();
            }
            writer.flush();
            writer.close();
        } catch (IOException e) {
            System.out.println("Error saving service types: " + e.getMessage());
        }
    }

    private void loadFromFile() {
        File file = new File(FILE_PATH);
        if (!file.exists()) return;

        try {
            BufferedReader reader = new BufferedReader(new FileReader(file));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 2) {
                    try {
                        String name = parts[0];
                        String category = (parts.length >= 3) ? parts[1] : "General";
                        double price = Double.parseDouble((parts.length >= 3) ? parts[2] : parts[1]);
                        serviceTypes.add(new ServiceType(name, category, price));
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid service type line: " + line);
                    }
                }
            }
            reader.close();
        } catch (IOException e) {
            System.out.println("Error loading service types: " + e.getMessage());
        }
    }
}
