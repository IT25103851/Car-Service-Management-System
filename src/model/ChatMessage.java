package model;

import java.util.UUID;

public class ChatMessage {
    private String messageId;
    private String appointmentId;
    private String senderRole; // "admin" or "customer"
    private String senderUsername;
    private String message;
    private String timestamp;

    public ChatMessage(String appointmentId, String senderRole, String senderUsername, String message, String timestamp) {
        this.messageId = UUID.randomUUID().toString();
        this.appointmentId = appointmentId;
        this.senderRole = senderRole;
        this.senderUsername = senderUsername;
        this.message = message;
        this.timestamp = timestamp;
    }

    public ChatMessage(String messageId, String appointmentId, String senderRole, String senderUsername, String message, String timestamp) {
        this.messageId = messageId;
        this.appointmentId = appointmentId;
        this.senderRole = senderRole;
        this.senderUsername = senderUsername;
        this.message = message;
        this.timestamp = timestamp;
    }

    public String getMessageId() { return messageId; }
    public String getAppointmentId() { return appointmentId; }
    public String getSenderRole() { return senderRole; }
    public String getSenderUsername() { return senderUsername; }
    public String getMessage() { return message; }
    public String getTimestamp() { return timestamp; }
}
