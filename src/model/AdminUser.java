package model;

public class AdminUser extends AbstractUser {
    private String adminLevel;
    private String lastLoginIP;

    public AdminUser(String username, String password, String name, String securityQuestion, String securityAnswer) {
        super(username, password, "admin", name, securityQuestion, securityAnswer, true);
    }

    public AdminUser(String username, String password, String name, String securityQuestion, String securityAnswer, boolean active) {
        super(username, password, "admin", name, securityQuestion, securityAnswer, active);
    }

    public String getAdminLevel() { return adminLevel; }
    public void setAdminLevel(String adminLevel) { this.adminLevel = adminLevel; }

    public String getLastLoginIP() { return lastLoginIP; }
    public void setLastLoginIP(String lastLoginIP) { this.lastLoginIP = lastLoginIP; }

    @Override
    public String getDashboardPath() {
        return "dashboard.jsp";
    }

    @Override
    public double getServiceDiscount() {
        return 0.0;
    }

    @Override
    public String getPermissions() {
        return "FULL_ACCESS, MANAGE_USERS, MANAGE_INVENTORY, VIEW_ALL, DELETE_ANY";
    }

    @Override
    public String getWelcomeMessage() {
        return "Welcome ADMIN " + getUsername() + "! You have " + getPermissions();
    }
}
