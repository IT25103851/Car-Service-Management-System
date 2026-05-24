package model;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackManager {

    private String getFilePath() {
        return Main.getFilePath("feedback.txt");
    }

    private void saveAll(List<Feedback> list) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(getFilePath()))) {
            for (Feedback fb : list) {
                String line = encodeFeedback(fb);
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            System.err.println("CRITICAL: Could not save feedback file! " + e.getMessage());
        }
    }

    private String encodeFeedback(Feedback fb) {
        String safeMsg = fb.getMessage().replace("|", " ").replace("\r", "").replace("\n", "__NL__");
        String safeReply = (fb.getAdminReply() != null) ? fb.getAdminReply().replace("|", " ").replace("\r", "").replace("\n", "__NL__") : "none";
        String safeRef = (fb.getServiceRef() != null) ? fb.getServiceRef().replace("|", " ") : "General";
        return fb.getFeedbackId() + "|" + fb.getCustomerUsername() + "|" + safeMsg + "|" + safeReply + "|" + fb.getDateSubmitted() + "|" + fb.getRating() + "|" + safeRef + "|" + fb.isApproved();
    }

    public void saveFeedback(Feedback feedback) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(getFilePath(), true))) {
            writer.write(encodeFeedback(feedback));
            writer.newLine();
        } catch (IOException e) {
            System.err.println("Could not append feedback: " + e.getMessage());
        }
    }

    public List<Feedback> getAllFeedback() {
        List<Feedback> list = new ArrayList<>();
        File file = new File(getFilePath());
        if (!file.exists()) return list;

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length >= 5) {
                    String msg = parts[2].replace("__NL__", "\n");
                    String reply = parts[3].replace("__NL__", "\n");
                    int rating = 5;
                    String ref = "General";
                    boolean approved = true; // Default to true for backward compatibility
                    if (parts.length >= 7) {
                        try { rating = Integer.parseInt(parts[5]); } catch (Exception ignored) {}
                        ref = parts[6];
                    }
                    if (parts.length >= 8) {
                        approved = Boolean.parseBoolean(parts[7]);
                    }
                    list.add(new Feedback(parts[0], parts[1], msg, reply, parts[4], rating, ref, approved));
                }
            }
        } catch (IOException e) {
            System.err.println("Could not load feedback: " + e.getMessage());
        }
        return list;
    }

    public void approveFeedback(String feedbackId) {
        List<Feedback> list = getAllFeedback();
        boolean found = false;
        for (Feedback fb : list) {
            if (fb.getFeedbackId().equals(feedbackId)) {
                fb.setApproved(true);
                found = true;
                break;
            }
        }
        if (found) saveAll(list);
    }

    public List<Feedback> getApprovedFeedback() {
        List<Feedback> list = new ArrayList<>();
        for (Feedback fb : getAllFeedback()) {
            if (fb.isApproved()) list.add(fb);
        }
        return list;
    }

    public void updateReply(String targetFeedbackId, String newReply) {
        List<Feedback> list = getAllFeedback();
        boolean found = false;
        for (Feedback fb : list) {
            if (fb.getFeedbackId().equals(targetFeedbackId)) {
                fb.setAdminReply(newReply);
                found = true;
                break;
            }
        }
        if (found) saveAll(list);
    }

    public void updateFeedback(Feedback updatedFb) {
        List<Feedback> list = getAllFeedback();
        boolean found = false;
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).getFeedbackId().equals(updatedFb.getFeedbackId())) {
                list.set(i, updatedFb);
                found = true;
                break;
            }
        }
        if (found) saveAll(list);
    }

    public boolean deleteFeedback(String feedbackId) {
        List<Feedback> list = getAllFeedback();
        boolean removed = list.removeIf(fb -> fb.getFeedbackId().equals(feedbackId));
        if (removed) saveAll(list);
        return removed;
    }

    public Feedback getFeedbackById(String id) {
        return getAllFeedback().stream()
                .filter(fb -> fb.getFeedbackId().equals(id))
                .findFirst()
                .orElse(null);
    }
}
