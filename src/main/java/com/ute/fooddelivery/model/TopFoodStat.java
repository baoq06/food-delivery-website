package com.ute.fooddelivery.model;

import java.io.Serializable;

public class TopFoodStat implements Serializable {
    private int foodId;
    private String foodName;
    private String imageUrl;
    private double price;
    private int totalQuantitySold;
    private double totalRevenue;

    public TopFoodStat() {
    }

    public TopFoodStat(int foodId, String foodName, String imageUrl, double price, int totalQuantitySold, double totalRevenue) {
        this.foodId = foodId;
        this.foodName = foodName;
        this.imageUrl = imageUrl;
        this.price = price;
        this.totalQuantitySold = totalQuantitySold;
        this.totalRevenue = totalRevenue;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getTotalQuantitySold() {
        return totalQuantitySold;
    }

    public void setTotalQuantitySold(int totalQuantitySold) {
        this.totalQuantitySold = totalQuantitySold;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }
}
