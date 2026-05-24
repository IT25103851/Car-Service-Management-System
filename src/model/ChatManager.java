package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

public class ChatManager {
    private final String FILE_PATH = Main.getFilePath("chat_messages.txt");

    public static boolean isChatWindowOpen(String completedDate, int windowDays) {
        if (completedDate == null || completedDate.trim().isEmpty() || "none".equalsIgnoreCase(completedDate)) {
            return true; // Not completed yet
        }
        try {
            LocalDate compDate = LocalDate.parse(completedDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            LocalDate today = LocalDate.now();
            long daysPassed = ChronoUnit.DAYS.between(compDate, today);
            return daysPassed <= windowDays;
        } catch (DateTimeParseException e) {
            return true; // Fallback if parse error
        }
    }
    
    public static long getRemainingDays(String completedDate, int windowDays) {
        if (completedDate == null || completedDate.trim().isEmpty() || "none".equalsIgnoreCase(completedDate)) {
            return windowDays;
        }
        try {
            LocalDate compDate = LocalDate.parse(completedDate, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            LocalDate today = LocalDate.now();
            long daysPassed = ChronoUnit.DAYS.between(compDate, today);
            long remaining = windowDays - daysPassed;
            return remaining < 0 ? 0 : remaining;
        } catch (DateTimeParseException e) {
            return 0;
        }
    }

    public void sendMessage(ChatMessage msg) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH, true))) {
            writer.write(encodeMessage(msg));
            writer.newLine();
        } catch (IOException e) {
            System.err.println("Error saving chat message: " + e.getMessage());
        }
    }

    public List<ChatMessage> getMessagesByAppointmentId(String appId) {
        return getAllMessages().stream()
                .filter(m -> m.getAppointmentId().equals(appId))
                .collect(Collectors.toList());
    }

    public int getUnreadCountForUser(String appId, String role) {
        List<ChatMessage> messages = getMessagesByAppointmentId(appId);
        int unread = 0;
        // Count messages from the other party since the user's last reply
        for (int i = messages.size() - 1; i >= 0; i--) {
            if (messages.get(i).getSenderRole().equals(role)) {
                break;
            } else {
                if (!"__READ__".equals(messages.get(i).getMessage())) {
                    unread++;
                }
            }
        }
        return unread;
    }

    private List<ChatMessage> getAllMessages() {
        List<ChatMessage> list = new ArrayList<>();
        File file = new File(FILE_PATH);
        if (!file.exists()) return list;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 6) {
                    String msgText = parts[4].replace("__NL__", "\n");
                    list.add(new ChatMessage(parts[0], parts[1], parts[2], parts[3], msgText, parts[5]));
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading chat messages: " + e.getMessage());
        }
        return list;
    }

    private String encodeMessage(ChatMessage m) {
        String safeMsg = m.getMessage().replace("|", " ").replace("\r", "").replace("\n", "__NL__");
        return m.getMessageId() + "|" + m.getAppointmentId() + "|" + m.getSenderRole() + "|" + m.getSenderUsername() + "|" + safeMsg + "|" + m.getTimestamp();
    }

    private void saveAll(List<ChatMessage> list) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FILE_PATH))) {
            for (ChatMessage msg : list) {
                writer.write(encodeMessage(msg));
                writer.newLine();
            }
        } catch (IOException e) {
            System.err.println("Error saving chat messages: " + e.getMessage());
        }
    }

    public void updateMessage(String messageId, String newText, String currentUser) {
        List<ChatMessage> list = getAllMessages();
        boolean found = false;
        for (int i = 0; i < list.size(); i++) {
            ChatMessage msg = list.get(i);
            if (msg.getMessageId().equals(messageId) && msg.getSenderUsername().equals(currentUser)) {
                String editedText = newText.trim();
                if (!editedText.endsWith("(edited)")) {
                    editedText += " <span class='text-[8px] opacity-60'>(edited)</span>";
                }
                list.set(i, new ChatMessage(msg.getMessageId(), msg.getAppointmentId(), msg.getSenderRole(), msg.getSenderUsername(), editedText, msg.getTimestamp()));
                found = true;
                break;
            }
        }
        if (found) saveAll(list);
    }

    public boolean deleteMessage(String messageId, String currentUser) {
        List<ChatMessage> list = getAllMessages();
        boolean removed = list.removeIf(m -> m.getMessageId().equals(messageId) && m.getSenderUsername().equals(currentUser));
        if (removed) saveAll(list);
        return removed;
    }
}
