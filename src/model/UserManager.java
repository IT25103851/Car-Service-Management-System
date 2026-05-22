package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class UserManager {

    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasLetter = false;
        boolean hasNumber = false;
        boolean hasSymbol = false;
        for (char c : password.toCharArray()) {
            if (Character.isLetter(c)) {
                hasLetter = true;
            } else if (Character.isDigit(c)) {
                hasNumber = true;
            } else if (!Character.isWhitespace(c)) {
                hasSymbol = true;
            }
        }
        return hasLetter && hasNumber && hasSymbol;
    }

    public UserManager() {
        // --- ADMIN BOOTSTRAPPER ---
        // If the database is empty or running for the very first time, create the Master Admin account.
        if (!userExists("Admin")) {
            registerUser(new AdminUser("Admin", "admin1234@", "System Administrator", "What was your first car?", "Swift"));
        }
    }

    // 0. CHECK IF USER EXISTS
    public boolean userExists(String username) {
        File f = new File(Main.getFilePath("users.txt"));
        if (!f.exists()) return false;

        try (BufferedReader reader = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 1 && parts[0].equals(username)) {
                    return true;
                }
            }
        } catch (IOException e) {
            // File might not exist yet, which is fine
        }
        return false;
    }

    // 1. REGISTER THE USER
    public boolean registerUser(AbstractUser newUser) {
        if (userExists(newUser.getUsername())) {
            return false; // Username is already taken!
        }
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(Main.getFilePath("users.txt"), true))) {
            writer.write(newUser.toString());
            writer.newLine();
            writer.flush();
            System.out.println("[UserManager] Saved user '" + newUser.getUsername() + "' to: " + Main.getFilePath("users.txt"));
            return true;
        } catch (IOException error) {
            System.out.println("Oops! Could not save the user: " + error.getMessage());
            return false;
        }
    }

    // 2. LOGIN THE USER (Your existing crash-proof code)
    public AbstractUser loginUser(String searchUsername, String searchPassword) {
        File f = new File(Main.getFilePath("users.txt"));
        if (!f.exists()) return null;

        try (BufferedReader reader = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 3) {
                    if (parts[0].equals(searchUsername) && parts[1].equals(searchPassword)) {
                        String name = (parts.length >= 4) ? parts[3] : parts[0];
                        String sq = (parts.length >= 5) ? parts[4] : "None";
                        String sa = (parts.length >= 6) ? parts[5] : "None";
                        boolean active = (parts.length >= 7) ? Boolean.parseBoolean(parts[6]) : true;
                        if ("admin".equals(parts[2])) {
                            return new AdminUser(parts[0], parts[1], name, sq, sa, active);
                        } else if ("customer".equals(parts[2])) {
                            return new CustomerUser(parts[0], parts[1], name, sq, sa, active);
                        }
                    }
                }
            }
        } catch (IOException error) {
            System.out.println("Oops! Could not read the file.");
        }
        return null;
    }

    // --- NEW POWER 1: GET ALL USERS (For the Admin Table) ---
    public List<AbstractUser> getAllUsers() {
        List<AbstractUser> userList = new ArrayList<>();
        File f = new File(Main.getFilePath("users.txt"));
        if (!f.exists()) return userList;

        try (BufferedReader reader = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                // If the line is healthy, build a User and add them to the list!
                if (parts.length >= 3) {
                    String name = (parts.length >= 4) ? parts[3] : parts[0];
                    String sq = (parts.length >= 5) ? parts[4] : "None";
                    String sa = (parts.length >= 6) ? parts[5] : "None";
                    boolean active = (parts.length >= 7) ? Boolean.parseBoolean(parts[6]) : true;
                    if ("admin".equals(parts[2])) {
                        userList.add(new AdminUser(parts[0], parts[1], name, sq, sa, active));
                    } else if ("customer".equals(parts[2])) {
                        userList.add(new CustomerUser(parts[0], parts[1], name, sq, sa, active));
                    }
                }
            }
        } catch (IOException e) {
            System.out.println("Could not load users for the table!");
        }
        return userList;
    }

    // --- NEW POWER 2: DELETE A USER (Admin power) ---
    public void deleteUser(String targetUsername) {
        // First, get everyone currently in the system
        List<AbstractUser> allUsers = getAllUsers();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(Main.getFilePath("users.txt")))) {
            for (AbstractUser u : allUsers) {
                // If this is NOT the person we want to delete, write them back into the file!
                if (!u.getUsername().equals(targetUsername)) {
                    writer.write(u.toString());
                    writer.newLine();
                }
            }
            writer.flush();
        } catch (IOException e) {
            System.out.println("Could not delete the user!");
        }
    }

    // --- NEW POWER 3: UPDATE A USER (Role or Password) ---
    public void updateUser(String targetUsername, String newName, String newRole, String newPassword) {
        List<AbstractUser> allUsers = getAllUsers();

        try (BufferedWriter writer = new BufferedWriter(new FileWriter(Main.getFilePath("users.txt")))) {
            for (AbstractUser u : allUsers) {
                if (u.getUsername().equals(targetUsername)) {
                    String pwd = (newPassword != null && !newPassword.trim().isEmpty()) ? newPassword : u.getPassword();
                    String rl = (newRole != null && !newRole.trim().isEmpty()) ? newRole : u.getRole();
                    String nm = (newName != null && !newName.trim().isEmpty()) ? newName : u.getName();
                    u.setPassword(pwd);
                    u.setName(nm);
                    // Note: setRole doesn't exist, we'd need to create a new object or add it.
                    // For now let's just write manually if role changes, but usually role shouldn't change easily.
                    writer.write(u.getUsername() + "," + pwd + "," + rl + "," + nm + "," + u.getSecurityQuestion() + "," + u.getSecurityAnswer() + "," + u.isActive());
                } else {
                    writer.write(u.toString());
                }
                writer.newLine();
            }
            writer.flush();
        } catch (IOException e) {
            System.out.println("Could not update the user!");
        }
    }

    // --- NEW POWER 4: GET USER BY USERNAME ---
    public AbstractUser getUserByUsername(String username) {
        List<AbstractUser> all = getAllUsers();
        for (AbstractUser u : all) {
            if (u.getUsername().equalsIgnoreCase(username)) return u;
        }
        return null;
    }

    // --- NEW POWER 5: SET ACTIVE STATUS ---
    public void setUserActiveStatus(String username, boolean status) {
        List<AbstractUser> allUsers = getAllUsers();
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(Main.getFilePath("users.txt")))) {
            for (AbstractUser u : allUsers) {
                if (u.getUsername().equalsIgnoreCase(username)) {
                    u.setActive(status);
                }
                writer.write(u.toString());
                writer.newLine();
            }
            writer.flush();
        } catch (IOException e) {
            System.out.println("Could not update user status!");
        }
    }
}