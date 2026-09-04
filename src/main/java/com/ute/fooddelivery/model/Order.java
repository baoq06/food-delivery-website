package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order implements Serializable {
    private int id;
    private Integer userId;
    private String customerName;
    private String phone;
    private String address;
    private String note;
    private double totalAmount;
    private String paymentMethod;
    private String status;
    private Integer driverId;
    private Timestamp createdAt;
    private List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.customerName = customerName;
        this.phone = phone;
        this.address = address;
        this.note = note;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.driverId = driverId;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDriverId() {
        return driverId;
    }

    public void setDriverId(Integer driverId) {
        this.driverId = driverId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }
}
