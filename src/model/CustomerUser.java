package model;

import java.util.ArrayList;
import java.util.List;

public class CustomerUser extends AbstractUser {
    private String email;
    private String phoneNumber;
    private String membershipTier = "BASIC";
    private List<String> vehiclePlates = new ArrayList<>();

    public CustomerUser(String username, String password, String name, String securityQuestion, String securityAnswer) {
        super(username, password, "customer", name, securityQuestion, securityAnswer, true);
    }

    public CustomerUser(String username, String password, String name, String securityQuestion, String securityAnswer, boolean active) {
        super(username, password, "customer", name, securityQuestion, securityAnswer, active);
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getMembershipTier() { return membershipTier; }
    public void setMembershipTier(String membershipTier) { this.membershipTier = membershipTier; }

    public void addVehicle(String plate) {
        vehiclePlates.add(plate);
    }

    public List<String> getVehiclePlates() {
        return vehiclePlates;
    }

    @Override
    public String getDashboardPath() {
        return "customer_dashboard.jsp";
    }

    @Override
    public double getServiceDiscount() {
        if ("VIP".equals(membershipTier)) {
            return 0.20;
        } else if ("PREMIUM".equals(membershipTier)) {
            return 0.10;
        } else {
            return 0.00;
        }
    }

    @Override
    public String getPermissions() {
        return "VIEW_OWN_VEHICLES, BOOK_SERVICE, VIEW_OWN_HISTORY, SUBMIT_FEEDBACK";
    }

    @Override
    public String getWelcomeMessage() {
        return "Welcome " + getUsername() + "! Tier: " + membershipTier + ", Discount: " + (getServiceDiscount() * 100) + "%";
    }

    public double calculateDiscountedCost(double originalCost) {
        return originalCost * (1 - getServiceDiscount());
    }
}
