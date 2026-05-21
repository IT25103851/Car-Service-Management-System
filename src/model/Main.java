package model;

import java.io.File;
import java.net.URL;

public class Main {

    // --- Centralized Data File Path Resolver ---
    private static String DATA_DIR = null;

    public static synchronized String getFilePath(String fileName) {
        if (DATA_DIR == null) {
            try {
                // Find where compiled classes live
                URL classRoot = Main.class.getProtectionDomain().getCodeSource().getLocation();
                if (classRoot != null) {
                    File dir = new File(classRoot.toURI());
                    // Walk up the directory tree to find the project root
                    // (the folder that contains both "src" and "webapp")
                    for (int i = 0; i < 10 && dir != null; i++) {
                        if (new File(dir, "src").exists() && new File(dir, "webapp").exists()) {
                            DATA_DIR = dir.getAbsolutePath() + File.separator;
                            break;
                        }
                        dir = dir.getParentFile();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Fallback: use current working directory
            if (DATA_DIR == null) {
                DATA_DIR = System.getProperty("user.dir") + File.separator;
            }
            System.out.println("[Main] Data directory resolved to: " + DATA_DIR);
        }
        return DATA_DIR + fileName;
    }

    public static void main(String[] args) {

        System.out.println("--- Starting the SwiftDrive Services ---");

        // 1. We build our empty train track (The Linked List)
        ServiceHistoryList myTrain = new ServiceHistoryList();

        // 2. We create some cargo using the NEW rules!
        // (Date, Service Type, Cost, License Plate)
        ServiceRecord service1 = new ServiceRecord("2024-01-15", "Oil Change", 6500.00, "CAA-1234");
        ServiceRecord service2 = new ServiceRecord("2023-11-20", "Tire Replacement", 15000.00, "CBB-5678");
        ServiceRecord service3 = new ServiceRecord("2024-02-10", "Engine Check", 8000.00, "DCC-1546");

        // 3. We load the cargo into the train (Adding to the Linked List)
        myTrain.addRecord(service1);
        myTrain.addRecord(service2);
        myTrain.addRecord(service3);

        // 4. We ask the train to show us everything inside!
        System.out.println("\nHere is the current Service History:");
        myTrain.displayAll();

        // 5. Use Selection Sort to fix the dates!
        System.out.println("\n--- Performing Selection Sort... ---");
        myTrain.sortHistoryByDate();

        // 6. Show the sorted list!
        System.out.println("\nHere is the Sorted Service History:");
        myTrain.displayAll();
    }
}