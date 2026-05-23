package model;

public class ServiceRecord {
    private String date;
    private String serviceType;
    private double cost;
    private String licensePlate; // The link to the car
    private String partsUsed; // Detailed log of consumed inventory

    // The Empty Constructor (Crucial for Gson / JSON loading)
    public ServiceRecord() {
    }

    // Legacy 4-Parameter Constructor
    public ServiceRecord(String date, String serviceType, double cost, String licensePlate) {
        this.date = date;
        this.serviceType = serviceType;
        this.cost = cost;
        this.licensePlate = licensePlate;
        this.partsUsed = "No physical parts recorded.";
    }

    // The Main Constructor (5-Parameters)
    public ServiceRecord(String date, String serviceType, double cost, String licensePlate, String partsUsed) {
        this.date = date;
        this.serviceType = serviceType;
        this.cost = cost;
        this.licensePlate = licensePlate;
        this.partsUsed = partsUsed;
    }

    // --- Getters & Setters ---
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public double getCost() { return cost; }
    public void setCost(double cost) { this.cost = cost; }

    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }

    public String getPartsUsed() { return partsUsed; }
    public void setPartsUsed(String partsUsed) { this.partsUsed = partsUsed; }

    // Standard Java toString() method
    @Override
    public String toString() {
        return "Date: " + date + " | Car: " + licensePlate + " | Service: " + serviceType + " | Cost: LKR " + cost;
    }
}