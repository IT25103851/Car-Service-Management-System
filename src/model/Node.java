package model;

public class Node {

    // 1. The Cargo: This holds the actual service details (Oil change, date, etc.)
    public ServiceRecord data;

    // 2. The Hook: This points to the next Train Car in line
    public Node next;

    // This is the builder for the Train Car
    public Node(ServiceRecord data) {
        this.data = data; // Put the cargo inside
        this.next = null; // 'null' means it is not hooked to another car yet!
    }
}