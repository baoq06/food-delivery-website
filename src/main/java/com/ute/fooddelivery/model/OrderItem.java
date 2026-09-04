package com.ute.fooddelivery.model;

import java.io.Serializable;

public class OrderItem implements Serializable {
    private int id;
    private int orderId;
    private int foodId;
    private String foodName;
    private String foodImage;
    private int quantity;
    private double unitPrice;
    private double subtotal;

    public OrderItem() {
    }

    public OrderItem(int id, int orderId, int foodId, int quantity, double unitPrice, double subtotal) {
        this.id = id;
        this.orderId = orderId;
        this.foodId = foodId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.subtotal = subtotal;
    }

    public OrderItem(int foodId, String foodName, String foodImage, int quantity, double unitPrice, double subtotal) {
        this.foodId = foodId;
        this.foodName = foodName;
        this.foodImage = foodImage;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.subtotal = subtotal;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getFoodId() {
        return foodId;
    }

    public void setFoodId(int foodId) {
        this.foodId = foodId;
    }

    public String getFoodName() {
        return foodName;
    }

    public void setFoodName(String foodName) {
        this.foodName = foodName;
    }

    public String getFoodImage() {
        return foodImage;
    }

    public void setFoodImage(String foodImage) {
        this.foodImage = foodImage;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }
}
