package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentManager {
    private List<Payment> paymentList;
    private final String FILE_PATH = Main.getFilePath("payments.txt");

    public PaymentManager() {
        this.paymentList = new ArrayList<>();
        loadFromFile();
    }

    public void addPayment(Payment newPayment) {
        paymentList.add(newPayment);
        saveToFile();
    }

    public List<Payment> getAllPayments() {
        return paymentList;
    }

    public List<Payment> getPaymentsByInvoiceId(String invoiceId) {
        List<Payment> filtered = new ArrayList<>();
        for (Payment p : paymentList) {
            if (p.getInvoiceId().equals(invoiceId)) {
                filtered.add(p);
            }
        }
        return filtered;
    }

    public Payment getPaymentById(String paymentId) {
        for (Payment p : paymentList) {
            if (p.getPaymentId().equals(paymentId)) {
                return p;
            }
        }
        return null;
    }

    public boolean updatePayment(String paymentId, double amount, String paymentMethod, String paymentDate, String referenceNote) {
        for (Payment p : paymentList) {
            if (p.getPaymentId().equals(paymentId)) {
                p.setAmount(amount);
                p.setPaymentMethod(paymentMethod);
                p.setPaymentDate(paymentDate);
                p.setReferenceNote(referenceNote);
                saveToFile();
                return true;
            }
        }
        return false;
    }

    public boolean deletePayment(String paymentId) {
        boolean removed = paymentList.removeIf(p -> p.getPaymentId().equals(paymentId));
        if (removed) {
            saveToFile();
        }
        return removed;
    }

    private void saveToFile() {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (Payment p : paymentList) {
                String ref = (p.getReferenceNote() == null || p.getReferenceNote().trim().isEmpty()) ? "N/A" : p.getReferenceNote().replace("|", " ");
                writer.write(p.getPaymentId() + "|" + p.getInvoiceId() + "|" + p.getAmount() + "|" +
                             p.getPaymentMethod() + "|" + p.getPaymentDate() + "|" + ref);
                writer.newLine();
            }
            writer.flush();
        } catch (IOException e) {
            System.err.println("Error saving payments: " + e.getMessage());
        }
    }

    private void loadFromFile() {
        File file = new File(FILE_PATH);
        if (!file.exists()) return;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 6) {
                    try {
                        double amount = Double.parseDouble(parts[2]);
                        String ref = "N/A".equals(parts[5]) ? "" : parts[5];
                        Payment p = new Payment(parts[0], parts[1], amount, parts[3], parts[4], ref);
                        paymentList.add(p);
                    } catch (NumberFormatException e) {
                        System.out.println("Skipping invalid payment line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading payments: " + e.getMessage());
        }
    }
}
