package com.ute.fooddelivery.model;

import java.io.Serializable;

public class FoodOption implements Serializable {
    private String name;
    private double price;

    public FoodOption() {
    }

    public FoodOption(String name, double price) {
        this.name = name;
        this.price = price;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getFormattedPrice() {
        return String.format("%,.0f đ", price);
    }

    @Override
    public String toString() {
        return name + " (+" + getFormattedPrice() + ")";
    }
}
