package model;

import java.io.*;
import java.util.LinkedList;
import java.util.Queue;
import java.util.List;
import java.util.ArrayList;

public class BookingManager {
    
    // NATIVE LINKED-LIST QUEUES
    private Queue<Appointment> appointmentQueue; // Pending Queue
    private Queue<Appointment> inGarageQueue;    // Under Maintenance
    private Queue<Appointment> completedQueue;   // Completed Jobs waiting for payment

    private final String FILE_PATH = Main.getFilePath("appointments.txt");

    public BookingManager() {
        this.appointmentQueue = new LinkedList<>();
        this.inGarageQueue = new LinkedList<>();
        this.completedQueue = new LinkedList<>();
        loadFromFile();
    }

    // --- ENQUEUE: Join the queue (from Customer perspective) ---
    public void addAppointment(Appointment app) {
        app.setStatus("Pending");
        appointmentQueue.add(app);
        saveToFile();
    }

    public boolean removeAppointment(String targetAppointmentId) {
        Appointment found = null;
        for (Appointment app : appointmentQueue) {
            if (app.getAppointmentId().equals(targetAppointmentId)) {
                found = app;
                break;
            }
        }
        if (found != null) {
            appointmentQueue.remove(found);
            saveToFile();
            return true;
        }
        return false;
    }

    public boolean updateAppointment(String targetAppointmentId, String newDate, String newTime) {
        for (Appointment app : appointmentQueue) {
            if (app.getAppointmentId().equals(targetAppointmentId)) {
                app.setPreferredDate(newDate);
                app.setPreferredTime(newTime);
                saveToFile();
                return true;
            }
        }
        return false;
    }

    // --- DEQUEUE + TRANSFER: Move to Garage (Mechanic claims it) ---
    public void moveToGarage() {
        if (!appointmentQueue.isEmpty()) {
            Appointment next = appointmentQueue.poll();
            next.setStatus("Under Maintenance");
            inGarageQueue.add(next);
            saveToFile();
        }
    }

    public boolean moveToGarage(String targetId) {
        Appointment found = null;
        for (Appointment app : appointmentQueue) {
            if (app.getAppointmentId().equals(targetId)) {
                found = app;
                break;
            }
        }
        if (found != null) {
            appointmentQueue.remove(found);
            found.setStatus("Under Maintenance");
            inGarageQueue.add(found);
            saveToFile();
            return true;
        }
        return false;
    }

    // --- DIRECT COMPLETED: Add directly to completed queue ---
    public void addCompletedAppointment(Appointment app) {
        app.setStatus("Completed");
        completedQueue.add(app);
        saveToFile();
    }

    // --- DEQUEUE + TRANSFER: Finish repair (Mechanic completes it) ---
    public Appointment moveFromGarageToCompleted(String targetAppointmentId) {
        // We iterate specifically because we might pull a specific car from the Garage list
        Appointment found = null;
        for (Appointment app : inGarageQueue) {
            if (app.getAppointmentId().equals(targetAppointmentId)) {
                found = app;
                break;
            }
        }
        if (found != null) {
            inGarageQueue.remove(found);
            found.setStatus("Completed");
            String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
            found.setCompletedDate(today);
            completedQueue.add(found);
            saveToFile();
        }
        return found;
    }

    // Extractors for front-end rendering
    public List<Appointment> getPendingAppointments() {
        return new ArrayList<>(appointmentQueue);
    }

    public List<Appointment> getInGarageAppointments() {
        return new ArrayList<>(inGarageQueue);
    }

    public List<Appointment> getCompletedAppointments() {
        return new ArrayList<>(completedQueue);
    }

    public List<Appointment> getAllAppointmentsNatively() {
        // Master view spanning all states natively for specific dashboards
        List<Appointment> all = new ArrayList<>();
        all.addAll(appointmentQueue);
        all.addAll(inGarageQueue);
        all.addAll(completedQueue);
        return all;
    }

    // Search helper for specific tasks
    public Appointment getAppointmentById(String id) {
        for (Appointment a : getAllAppointmentsNatively()) {
            if (a.getAppointmentId().equals(id)) return a;
        }
        return null;
    }

    // --- TXT File Save ---
    // Format: appointmentId|customerUsername|licensePlate|preferredDate|preferredTime|issueDescription|status
    private void saveToFile() {
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH));
            // Save all appointments from all three queues
            for (Appointment app : appointmentQueue) {
                writer.write(formatAppointment(app));
                writer.newLine();
            }
            for (Appointment app : inGarageQueue) {
                writer.write(formatAppointment(app));
                writer.newLine();
            }
            for (Appointment app : completedQueue) {
                writer.write(formatAppointment(app));
                writer.newLine();
            }
            writer.flush();
            writer.close();
        } catch (IOException e) {
            System.out.println("Error saving appointments: " + e.getMessage());
        }
    }

    private String formatAppointment(Appointment app) {
        String desc = (app.getIssueDescription() != null) ? app.getIssueDescription().replace("|", " ").replace("\r", "").replace("\n", "__NL__") : "None";
        String compDate = (app.getCompletedDate() != null) ? app.getCompletedDate() : "none";
        return app.getAppointmentId() + "|" + app.getCustomerUsername() + "|" + app.getLicensePlate() + "|" +
               app.getPreferredDate() + "|" + app.getPreferredTime() + "|" + desc + "|" + app.getStatus() + "|" + compDate;
    }

    // --- TXT File Load ---
    private void loadFromFile() {
        try {
            File f = new File(FILE_PATH);
            if (!f.exists()) {
                System.out.println("No booking file found. Starting fresh!");
                return;
            }

            BufferedReader reader = new BufferedReader(new FileReader(f));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 7) {
                    String desc = parts[5].replace("__NL__", "\n");
                    Appointment app = new Appointment(parts[0], parts[1], parts[2], parts[3], parts[4], desc);
                    app.setStatus(parts[6]);
                    
                    if (parts.length >= 8) {
                        app.setCompletedDate(parts[7]);
                    } else {
                        app.setCompletedDate("none");
                    }

                    // Route to the correct queue based on status
                    if ("Pending".equals(parts[6])) {
                        appointmentQueue.add(app);
                    } else if ("Under Maintenance".equals(parts[6])) {
                        inGarageQueue.add(app);
                    } else if ("Completed".equals(parts[6])) {
                        completedQueue.add(app);
                    } else {
                        appointmentQueue.add(app); // Default fallback
                    }
                }
            }
            reader.close();
        } catch (IOException e) {
            System.out.println("Error loading appointments: " + e.getMessage());
        }
    }
}