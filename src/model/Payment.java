package model;

public class Payment {
    private String paymentId;
    private String invoiceId;
    private double amount;
    private String paymentMethod;
    private String paymentDate;
    private String referenceNote;

    public Payment() {}

    public Payment(String paymentId, String invoiceId, double amount, String paymentMethod, String paymentDate, String referenceNote) {
        this.paymentId = paymentId;
        this.invoiceId = invoiceId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentDate = paymentDate;
        this.referenceNote = referenceNote;
    }

    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }

    public String getInvoiceId() { return invoiceId; }
    public void setInvoiceId(String invoiceId) { this.invoiceId = invoiceId; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String paymentDate) { this.paymentDate = paymentDate; }

    public String getReferenceNote() { return referenceNote; }
    public void setReferenceNote(String referenceNote) { this.referenceNote = referenceNote; }
}
