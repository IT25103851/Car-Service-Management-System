package model;

public class ServiceType {
    private String serviceName;
    private String category;
    private double defaultBasePrice;

    public ServiceType() {}

    public ServiceType(String serviceName, String category, double defaultBasePrice) {
        this.serviceName = serviceName;
        this.category = category;
        this.defaultBasePrice = defaultBasePrice;
    }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public double getDefaultBasePrice() { return defaultBasePrice; }
    public void setDefaultBasePrice(double defaultBasePrice) { this.defaultBasePrice = defaultBasePrice; }
}
