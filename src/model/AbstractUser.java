package model;

public abstract class AbstractUser {
    private String username;
    private String password;
    private String role;
    private String name;
    private String securityQuestion;
    private String securityAnswer;
    private boolean active = true;

    public AbstractUser(String username, String password, String role, String name, String securityQuestion, String securityAnswer, boolean active) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.name = name;
        this.securityQuestion = securityQuestion;
        this.securityAnswer = securityAnswer;
        this.active = active;
    }

    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getRole() { return role; }
    public String getName() { return name; }
    public String getSecurityQuestion() { return securityQuestion; }
    public String getSecurityAnswer() { return securityAnswer; }
    public boolean isActive() { return active; }

    public void setPassword(String password) { this.password = password; }
    public void setName(String name) { this.name = name; }
    public void setSecurityQuestion(String securityQuestion) { this.securityQuestion = securityQuestion; }
    public void setSecurityAnswer(String securityAnswer) { this.securityAnswer = securityAnswer; }
    public void setActive(boolean active) { this.active = active; }

    public abstract String getDashboardPath();
    public abstract double getServiceDiscount();
    public abstract String getPermissions();

    public String getWelcomeMessage() {
        return "Welcome " + name + " (" + username + ")!";
    }

    @Override
    public String toString() {
        return username + "," + password + "," + role + "," + name + "," + securityQuestion + "," + securityAnswer + "," + active;
    }
}
