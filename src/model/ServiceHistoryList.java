package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceHistoryList {
    public Node head;
    private final String filePath = Main.getFilePath("services.txt");

    public ServiceHistoryList() {
        this.head = null;
    }

    // --- SAVE TO FILE ---
    // Format: date|serviceType|cost|licensePlate|partsUsed
    public void saveToFile() {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            Node current = head;
            while (current != null) {
                String parts = (current.data.getPartsUsed() != null) ? current.data.getPartsUsed().replace("|", " ").replace("\r","").replace("\n","__NL__") : "None";
                writer.write(current.data.getDate() + "|" + current.data.getServiceType() + "|" +
                             current.data.getCost() + "|" + current.data.getLicensePlate() + "|" + parts);
                writer.newLine();
                current = current.next;
            }
            writer.flush();
        } catch (IOException e) {
            System.err.println("Could not save to services.txt: " + e.getMessage());
        }
    }

    // --- LOAD FROM FILE ---
    public void loadFromFile() {
        File file = new File(filePath);
        if (!file.exists()) return;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            this.head = null;
            while ((line = reader.readLine()) != null) {
                String[] p = line.split("\\|");
                if (p.length >= 4) {
                    try {
                        double cost = Double.parseDouble(p[2]);
                        String partsUsed = (p.length >= 5) ? p[4].replace("__NL__", "\n") : "No physical parts recorded.";
                        ServiceRecord record = new ServiceRecord(p[0], p[1], cost, p[3], partsUsed);
                        this.addRecord(record);
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid service line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Could not read from services.txt: " + e.getMessage());
        }
    }

    public void addRecord(ServiceRecord newRecord) {
        Node newCar = new Node(newRecord);
        if (this.head == null) {
            this.head = newCar;
        } else {
            Node currentCar = this.head;
            while (currentCar.next != null) {
                currentCar = currentCar.next;
            }
            currentCar.next = newCar;
        }
    }

    public void displayAll() {
        if (this.head == null) {
            System.out.println("The history is empty!");
            return;
        }
        Node current = this.head;
        while (current != null) {
            System.out.println(current.data.toString());
            current = current.next;
        }
    }

    public void updateRecord(String oldDate, String oldType, String targetPlate, String newDate, String newType, double newCost) {
        Node current = this.head;
        while (current != null) {
            boolean dateMatches = current.data.getDate().trim().equals(oldDate.trim());
            boolean typeMatches = current.data.getServiceType().trim().equalsIgnoreCase(oldType.trim());
            boolean plateMatches = current.data.getLicensePlate() != null && current.data.getLicensePlate().trim().equalsIgnoreCase(targetPlate.trim());

            if (dateMatches && typeMatches && plateMatches) {
                current.data.setDate(newDate);
                current.data.setServiceType(newType);
                current.data.setCost(newCost);
                return;
            }
            current = current.next;
        }
    }

    public void deleteRecord(String date, String serviceType, String plate) {
        if (this.head == null) return;
        
        // Check head node
        if (this.head.data.getDate().trim().equals(date.trim()) && 
            this.head.data.getServiceType().trim().equalsIgnoreCase(serviceType.trim()) &&
            (plate == null || (this.head.data.getLicensePlate() != null && this.head.data.getLicensePlate().trim().equalsIgnoreCase(plate.trim())))) {
            this.head = this.head.next;
            return;
        }

        Node current = this.head;
        Node previous = null;
        while (current != null) {
            boolean dateMatches = current.data.getDate().trim().equals(date.trim());
            boolean typeMatches = current.data.getServiceType().trim().equalsIgnoreCase(serviceType.trim());
            boolean plateMatches = (plate == null) || (current.data.getLicensePlate() != null && current.data.getLicensePlate().trim().equalsIgnoreCase(plate.trim()));

            if (dateMatches && typeMatches && plateMatches) {
                previous.next = current.next;
                return;
            }
            previous = current;
            current = current.next;
        }
    }

    public void sortHistoryByDate() {
        if (this.head == null || this.head.next == null) return;
        Node current = this.head;
        while (current != null) {
            Node newestNode = current;
            Node checker = current.next;
            while (checker != null) {
                // Sort descending (newest first)
                if (checker.data.getDate().compareTo(newestNode.data.getDate()) > 0) {
                    newestNode = checker;
                }
                checker = checker.next;
            }
            if (newestNode != current) {
                ServiceRecord tempCargo = current.data;
                current.data = newestNode.data;
                newestNode.data = tempCargo;
            }
            current = current.next;
        }
    }
}