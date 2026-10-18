package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class DriverWalletTransaction implements Serializable {
    private int id;
    private int driverId;
    private Integer orderId;
    private String type; // 'COD_DEDUCTION', 'SHIPPING_EARNING', 'TOPUP', 'WITHDRAW'
    private double amount;
    private double balanceAfter;
    private String description;
    private Timestamp createdAt;

    public DriverWalletTransaction() {
    }

    public DriverWalletTransaction(int id, int driverId, Integer orderId, String type, double amount, double balanceAfter, String description, Timestamp createdAt) {
        this.id = id;
        this.driverId = driverId;
        this.orderId = orderId;
        this.type = type;
        this.amount = amount;
        this.balanceAfter = balanceAfter;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
        this.driverId = driverId;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTransactionType() {
        return type;
    }

    public void setTransactionType(String transactionType) {
        this.type = transactionType;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public double getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(double balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isPositive() {
        return amount > 0;
    }

    public String getTypeDisplay() {
        if ("COD_DEDUCTION".equalsIgnoreCase(type)) {
            return "Trừ tiền COD thu khách";
        } else if ("SHIPPING_EARNING".equalsIgnoreCase(type)) {
            return "Thù lao giao hàng";
        } else if ("TOPUP".equalsIgnoreCase(type)) {
            return "Nạp ví hoạt động";
        } else if ("WITHDRAW".equalsIgnoreCase(type)) {
            return "Rút tiền về ngân hàng";
        }
        return type != null ? type : "";
    }

    public String getTypeBadgeColor() {
        if ("COD_DEDUCTION".equalsIgnoreCase(type)) {
            return "#dc2626";
        } else if ("SHIPPING_EARNING".equalsIgnoreCase(type)) {
            return "#15803d";
        } else if ("TOPUP".equalsIgnoreCase(type)) {
            return "#1d4ed8";
        } else if ("WITHDRAW".equalsIgnoreCase(type)) {
            return "#b45309";
        }
        return "#475569";
    }

    public String getTypeBadgeBg() {
        if ("COD_DEDUCTION".equalsIgnoreCase(type)) {
            return "#fee2e2";
        } else if ("SHIPPING_EARNING".equalsIgnoreCase(type)) {
            return "#dcfce7";
        } else if ("TOPUP".equalsIgnoreCase(type)) {
            return "#dbeafe";
        } else if ("WITHDRAW".equalsIgnoreCase(type)) {
            return "#fef3c7";
        }
        return "#f1f5f9";
    }
}
