package model;

public class InventoryItem {
    private String itemId;      // e.g., "PART-001"
    private String itemName;    // e.g., "Brake Pads"
    private String category;    // e.g., "Brakes", "Engine", "Suspension"
    private int quantity;       // e.g., 15 (If 0, it's Out of Stock!)
    private double price;       // e.g., 4500.00
    private String iconName;    // We will use FontAwesome icons instead of complex image uploads! e.g., "fa-compact-disc"
    private String applicableService; // The specific abstract Service this part binds to!

    // 1. The Empty Constructor (Crucial for JSON saving)
    public InventoryItem() {
    }

    // 2. The Main Constructor
    public InventoryItem(String itemId, String itemName, String category, int quantity, double price, String iconName, String applicableService) {
        this.itemId = itemId;
        this.itemName = itemName;
        this.category = category;
        this.quantity = quantity;
        this.price = price;
        this.iconName = iconName;
        this.applicableService = applicableService;
    }

    // --- Getters & Setters ---
    public String getItemId() { return itemId; }
    public void setItemId(String itemId) { this.itemId = itemId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getIconName() { return iconName; }
    public void setIconName(String iconName) { this.iconName = iconName; }

    public String getApplicableService() { return applicableService; }
    public void setApplicableService(String applicableService) { this.applicableService = applicableService; }

    // This is a "Smart Helper" method for the dashboard badges!
    public String getStockStatus() {
        if (quantity <= 0) {
            return "Out of Stock";
        } else if (quantity <= 5) {
            return "Low Stock";
        } else {
            return "In Stock";
        }
    }
}