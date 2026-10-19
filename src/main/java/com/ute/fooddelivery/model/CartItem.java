package com.ute.fooddelivery.model;

import java.io.Serializable;

public class CartItem implements Serializable {
    private Food food;
    private int quantity;
    private String selectedOptions;
    private double unitPrice;

    public CartItem() {
    }

    public CartItem(Food food, int quantity) {
        this.food = food;
        this.quantity = quantity;
        this.unitPrice = food != null ? food.getPrice() : 0.0;
    }

    public CartItem(Food food, int quantity, String selectedOptions, double unitPrice) {
        this.food = food;
        this.quantity = quantity;
        this.selectedOptions = selectedOptions;
        this.unitPrice = unitPrice > 0 ? unitPrice : (food != null ? food.getPrice() : 0.0);
    }

    public Food getFood() {
        return food;
    }

    public void setFood(Food food) {
        this.food = food;
        if (this.unitPrice <= 0 && food != null) {
            this.unitPrice = food.getPrice();
        }
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getSelectedOptions() {
        return selectedOptions;
    }

    public void setSelectedOptions(String selectedOptions) {
        this.selectedOptions = selectedOptions;
    }

    public double getUnitPrice() {
        return unitPrice > 0 ? unitPrice : (food != null ? food.getPrice() : 0.0);
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public double getTotalPrice() {
        return getUnitPrice() * quantity;
    }
}
