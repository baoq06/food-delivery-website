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
    private String driverName;
    private String driverPhone;
    private Timestamp createdAt;
    private boolean customerConfirmed;
    private boolean merchantConfirmed;
    private boolean shipperAccepted;
    private boolean shipperDelivered;
    private boolean merchantCompleted;
    private Review review;

    public Review getReview() { return review; }
    public void setReview(Review review) { this.review = review; }
    private List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt) {
        this(id, userId, customerName, phone, address, note, totalAmount, paymentMethod, status, driverId, createdAt, false, false, false, false, false);
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt, boolean customerConfirmed, boolean merchantConfirmed) {
        this(id, userId, customerName, phone, address, note, totalAmount, paymentMethod, status, driverId, createdAt, customerConfirmed, merchantConfirmed, false, false, merchantConfirmed);
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt, boolean customerConfirmed, boolean merchantConfirmed,
                 boolean shipperAccepted, boolean shipperDelivered, boolean merchantCompleted) {
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
        this.customerConfirmed = customerConfirmed;
        this.merchantConfirmed = merchantConfirmed;
        this.shipperAccepted = shipperAccepted;
        this.shipperDelivered = shipperDelivered;
        this.merchantCompleted = merchantCompleted;
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

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverPhone() {
        return driverPhone;
    }

    public void setDriverPhone(String driverPhone) {
        this.driverPhone = driverPhone;
    }

    public boolean isCustomerConfirmed() {
        return customerConfirmed;
    }

    public void setCustomerConfirmed(boolean customerConfirmed) {
        this.customerConfirmed = customerConfirmed;
    }

    public boolean isMerchantConfirmed() {
        return merchantConfirmed;
    }

    public void setMerchantConfirmed(boolean merchantConfirmed) {
        this.merchantConfirmed = merchantConfirmed;
    }

    public boolean isShipperAccepted() {
        return shipperAccepted;
    }

    public void setShipperAccepted(boolean shipperAccepted) {
        this.shipperAccepted = shipperAccepted;
    }

    public boolean isShipperDelivered() {
        return shipperDelivered;
    }

    public void setShipperDelivered(boolean shipperDelivered) {
        this.shipperDelivered = shipperDelivered;
    }

    public boolean isMerchantCompleted() {
        return merchantCompleted;
    }

    public void setMerchantCompleted(boolean merchantCompleted) {
        this.merchantCompleted = merchantCompleted;
    }

    public boolean isFullyConfirmed() {
        return customerConfirmed && merchantConfirmed;
    }

    /**
     * Kiểm tra đơn đã sẵn sàng để Chủ quán duyệt hoàn thành hay chưa:
     * Cần cả Shipper xác nhận đã giao VÀ Khách hàng xác nhận đã nhận món.
     */
    public boolean isReadyForMerchantComplete() {
        return shipperDelivered && customerConfirmed;
    }

    /**
     * Kiểm tra Quán có thể bắt đầu nấu & giao hay chưa:
     * Cần đã gán tài xế VÀ tài xế đó đã bấm chấp nhận giao đơn.
     */
    public boolean canStartCooking() {
        return driverId != null && driverId > 0 && shipperAccepted;
    }
}
