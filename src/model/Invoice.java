package model;

import java.time.LocalDate;

public class Invoice {
    private String invoiceId;
    private String customerUsername;
    private String licensePlate;
    private String serviceDescription;
    private double partsCost;
    private double laborCost;
    private double totalAmount;
    private String dateIssued;
    private String status; // "UNPAID" or "PAID"
    private String voidedDate;
    private String voidReason;

    // Empty constructor for JSON
    public Invoice() {}

    public Invoice(String invoiceId, String customerUsername, String licensePlate,
                   String serviceDescription, double partsCost, double laborCost) {
        this.invoiceId = invoiceId;
        this.customerUsername = customerUsername;
        this.licensePlate = licensePlate;
        this.serviceDescription = serviceDescription;
        this.partsCost = partsCost;
        this.laborCost = laborCost;
        this.totalAmount = partsCost + laborCost;
        this.dateIssued = LocalDate.now().toString(); // Automatically grabs today's date!
        this.status = "UNPAID";
    }

    // --- Getters & Setters ---
    public String getInvoiceId() { return invoiceId; }
    public String getCustomerUsername() { return customerUsername; }
    public String getLicensePlate() { return licensePlate; }
    public String getServiceDescription() { return serviceDescription; }
    public double getPartsCost() { return partsCost; }
    public double getLaborCost() { return laborCost; }
    public double getTotalAmount() { return totalAmount; }
    public String getDateIssued() { return dateIssued; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getVoidedDate() { return voidedDate; }
    public void setVoidedDate(String voidedDate) { this.voidedDate = voidedDate; }

    public String getVoidReason() { return voidReason; }
    public void setVoidReason(String voidReason) { this.voidReason = voidReason; }

    public void setDateIssued(String date) { this.dateIssued = date; }
    public void setServiceDescription(String desc) { this.serviceDescription = desc; }
    public void setTotalAmount(double amount) { this.totalAmount = amount; }
    public void setPartsCost(double cost) { this.partsCost = cost; }
    public void setLaborCost(double cost) { this.laborCost = cost; }
}