package model;

import java.io.*;
import java.util.Stack;

public class BillingManager {
    private Stack<Invoice> invoiceStack;
    private final String FILE_PATH = Main.getFilePath("invoices.txt");

    public BillingManager() {
        this.invoiceStack = new Stack<>();
        loadFromFile();
    }

    public void generateInvoice(Invoice newInvoice) {
        invoiceStack.push(newInvoice);
        saveToFile();
    }

    public Stack<Invoice> getAllInvoices() { return invoiceStack; }

    public Invoice getInvoiceById(String id) {
        for (Invoice inv : invoiceStack) {
            if (inv.getInvoiceId().equals(id)) return inv;
        }
        return null;
    }

    public void markAsPaid(String targetInvoiceId) {
        for (Invoice inv : invoiceStack) {
            if (inv.getInvoiceId().equals(targetInvoiceId)) {
                inv.setStatus("PAID");
                break;
            }
        }
        saveToFile();
    }

    public void voidInvoice(String targetInvoiceId, String reason) {
        for (Invoice inv : invoiceStack) {
            if (inv.getInvoiceId().equals(targetInvoiceId)) {
                inv.setStatus("VOID");
                inv.setVoidedDate(java.time.LocalDate.now().toString());
                inv.setVoidReason(reason);
                break;
            }
        }
        saveToFile();
    }

    public void reinstateInvoice(String targetInvoiceId) {
        for (Invoice inv : invoiceStack) {
            if (inv.getInvoiceId().equals(targetInvoiceId)) {
                inv.setStatus("PAID");
                inv.setVoidedDate(null);
                inv.setVoidReason(null);
                break;
            }
        }
        saveToFile();
    }

    public boolean deleteInvoiceByMetadata(String plate, String date, String type) {
        for (Invoice inv : invoiceStack) {
            boolean plateMatch = inv.getLicensePlate() != null && inv.getLicensePlate().trim().equalsIgnoreCase(plate.trim());
            boolean dateMatch = inv.getDateIssued() != null && inv.getDateIssued().trim().equals(date.trim());
            
            String invDesc = inv.getServiceDescription() != null ? inv.getServiceDescription().trim().toLowerCase() : "";
            String targetType = type != null ? type.trim().toLowerCase() : "";
            boolean typeMatch = invDesc.startsWith(targetType);

            if (plateMatch && dateMatch && typeMatch) {
                invoiceStack.remove(inv);
                saveToFile();
                return true;
            }
        }
        return false;
    }

    public boolean updateInvoice(String id, String description, double partsCost, double laborCost) {
        for (Invoice inv : invoiceStack) {
            if (inv.getInvoiceId().equals(id)) {
                inv.setServiceDescription(description);
                inv.setPartsCost(partsCost);
                inv.setLaborCost(laborCost);
                inv.setTotalAmount(partsCost + laborCost);
                saveToFile();
                return true;
            }
        }
        return false;
    }

    public boolean updateInvoiceByMetadata(String plate, String oldDate, String oldType, String newDate, String newType, double newCost) {
        for (Invoice inv : invoiceStack) {
            boolean plateMatch = inv.getLicensePlate() != null && inv.getLicensePlate().trim().equalsIgnoreCase(plate.trim());
            boolean dateMatch = inv.getDateIssued() != null && inv.getDateIssued().trim().equals(oldDate.trim());
            
            String invDesc = inv.getServiceDescription() != null ? inv.getServiceDescription().trim().toLowerCase() : "";
            String targetType = oldType != null ? oldType.trim().toLowerCase() : "";
            boolean typeMatch = invDesc.startsWith(targetType);

            if (plateMatch && dateMatch && typeMatch) {
                inv.setDateIssued(newDate);
                if (inv.getServiceDescription().contains(" (Parts:")) {
                    String partsPart = inv.getServiceDescription().substring(inv.getServiceDescription().indexOf(" (Parts:"));
                    inv.setServiceDescription(newType + partsPart);
                } else {
                    inv.setServiceDescription(newType);
                }
                inv.setTotalAmount(newCost);
                saveToFile();
                return true;
            }
        }
        return false;
    }

    private void saveToFile() {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (Invoice inv : invoiceStack) {
                String desc = (inv.getServiceDescription() != null) ? inv.getServiceDescription().replace("|", " ") : "N/A";
                String voidDate = (inv.getVoidedDate() != null) ? inv.getVoidedDate() : "N/A";
                String voidReason = (inv.getVoidReason() != null) ? inv.getVoidReason().replace("|", " ") : "N/A";
                writer.write(inv.getInvoiceId() + "|" + inv.getCustomerUsername() + "|" + inv.getLicensePlate() + "|" +
                             desc + "|" + inv.getPartsCost() + "|" + inv.getLaborCost() + "|" +
                             inv.getTotalAmount() + "|" + inv.getDateIssued() + "|" + inv.getStatus() + "|" +
                             voidDate + "|" + voidReason);
                writer.newLine();
            }
            writer.flush();
        } catch (IOException e) {
            System.err.println("Error saving invoices: " + e.getMessage());
        }
    }

    private void loadFromFile() {
        File file = new File(FILE_PATH);
        if (!file.exists()) return;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 9) {
                    try {
                        double partsCost = Double.parseDouble(parts[4]);
                        double laborCost = Double.parseDouble(parts[5]);
                        Invoice inv = new Invoice(parts[0], parts[1], parts[2], parts[3], partsCost, laborCost);
                        inv.setTotalAmount(Double.parseDouble(parts[6]));
                        inv.setDateIssued(parts[7]);
                        inv.setStatus(parts[8]);
                        if (parts.length >= 11) {
                            inv.setVoidedDate("N/A".equals(parts[9]) ? null : parts[9]);
                            inv.setVoidReason("N/A".equals(parts[10]) ? null : parts[10]);
                        }
                        invoiceStack.push(inv);
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid invoice line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading invoices: " + e.getMessage());
        }
    }
}