package model;

public class Vehicle {
    private String licensePlate; // This is our unique ID!
    private String make;         // e.g., Toyota
    private String model;        // e.g., Prius
    private int year;            // e.g., 2018
    private int mileage;         // e.g., 55000
    private String ownerUsername; // THIS links the car to the specific customer!

    // The Empty Constructor (Good for standard Java rules)
    public Vehicle() {}

    // The Builder Constructor
    public Vehicle(String licensePlate, String make, String model, int year, int mileage, String ownerUsername) {
        this.licensePlate = licensePlate;
        this.make = make;
        this.model = model;
        this.year = year;
        this.mileage = mileage;
        this.ownerUsername = ownerUsername;
    }

    // --- GETTERS ---
    public String getLicensePlate() { return licensePlate; }
    public String getMake() { return make; }
    public String getModel() { return model; }
    public int getYear() { return year; }
    public int getMileage() { return mileage; }
    public String getOwnerUsername() { return ownerUsername; }

    // --- SETTERS ---
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }
    public void setMake(String make) { this.make = make; }
    public void setModel(String model) { this.model = model; }
    public void setYear(int year) { this.year = year; }
    public void setMileage(int mileage) { this.mileage = mileage; }
    public void setOwnerUsername(String ownerUsername) { this.ownerUsername = ownerUsername; }
}