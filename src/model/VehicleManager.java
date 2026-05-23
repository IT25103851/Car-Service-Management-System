package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleManager {
    private List<Vehicle> vehicleList;
    private final String FILE_PATH = Main.getFilePath("vehicles.txt");

    public VehicleManager() {
        this.vehicleList = new ArrayList<>();
        loadFromFile();
    }

    private void saveToFile() {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (Vehicle v : vehicleList) {
                writer.write(v.getLicensePlate() + "|" + v.getMake() + "|" + v.getModel() + "|" +
                             v.getYear() + "|" + v.getMileage() + "|" + v.getOwnerUsername());
                writer.newLine();
            }
            writer.flush();
        } catch (IOException e) {
            System.err.println("Could not save to vehicles.txt: " + e.getMessage());
        }
    }

    private void loadFromFile() {
        File file = new File(FILE_PATH);
        if (!file.exists()) return;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 6) {
                    try {
                        int year = Integer.parseInt(parts[3]);
                        int mileage = Integer.parseInt(parts[4]);
                        Vehicle v = new Vehicle(parts[0], parts[1], parts[2], year, mileage, parts[5]);
                        vehicleList.add(v);
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid vehicle line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Could not read from vehicles.txt: " + e.getMessage());
        }
    }

    public void addVehicle(Vehicle newVehicle) {
        vehicleList.add(newVehicle);
        saveToFile();
    }

    public List<Vehicle> getAllVehicles() {
        return vehicleList;
    }

    public List<Vehicle> getVehiclesByOwner(String username) {
        List<Vehicle> customerCars = new ArrayList<>();
        for (Vehicle v : vehicleList) {
            if (v.getOwnerUsername().equals(username)) {
                customerCars.add(v);
            }
        }
        return customerCars;
    }

    public void updateVehicle(String targetPlate, String make, String model, int year, int mileage) {
        for (Vehicle v : vehicleList) {
            if (v.getLicensePlate().equals(targetPlate)) {
                v.setMake(make);
                v.setModel(model);
                v.setYear(year);
                v.setMileage(mileage);
                saveToFile();
                return;
            }
        }
    }

    public void deleteVehicle(String targetPlate) {
        vehicleList.removeIf(v -> v.getLicensePlate().equals(targetPlate));
        saveToFile();
    }

    public boolean vehicleExists(String targetPlate) {
        for (Vehicle v : vehicleList) {
            if (v.getLicensePlate().equalsIgnoreCase(targetPlate)) {
                return true;
            }
        }
        return false;
    }
}