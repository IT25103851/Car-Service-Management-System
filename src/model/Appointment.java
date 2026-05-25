package model;

public class Appointment {
    private String appointmentId;
    private String customerUsername;
    private String licensePlate;
    private String preferredDate;
    private String preferredTime;
    private String issueDescription;
    private String status; // "Pending", "Confirmed", "Completed"
    private String completedDate;

    public Appointment() {
    }

    public Appointment(String appointmentId, String customerUsername, String licensePlate,
                       String preferredDate, String preferredTime, String issueDescription) {
        this.appointmentId = appointmentId;
        this.customerUsername = customerUsername;
        this.licensePlate = licensePlate;
        this.preferredDate = preferredDate;
        this.preferredTime = preferredTime;
        this.issueDescription = issueDescription;
        this.status = "Pending";
        this.completedDate = "none";
    }

    // Getters and Setters
    public String getAppointmentId() {
        return appointmentId;
    }

    public String getCustomerUsername() {
        return customerUsername;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public String getPreferredDate() {
        return preferredDate;
    }

    public String getPreferredTime() {
        return preferredTime;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public String getStatus() {
        return status;
    }

    public String getCompletedDate() {
        return completedDate;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setCompletedDate(String completedDate) {
        this.completedDate = completedDate;
    }

    public void setPreferredDate(String preferredDate) {
        this.preferredDate = preferredDate;
    }

    public void setPreferredTime(String preferredTime) {
        this.preferredTime = preferredTime;
    }
}

