package com.ute.fooddelivery.model;

import java.sql.Timestamp;

public class Review {
    private int reviewId;
    private int orderId;
    private int customerId;
    private Integer driverId;
    private Integer restaurantId;
    private int rating;
    private String comment;
    private Integer foodRating;
    private String foodComment;
    private Integer driverRating;
    private String driverComment;
    private Timestamp createdAt;

    // Getters and setters
    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }
    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public Integer getDriverId() { return driverId; }
    public void setDriverId(Integer driverId) { this.driverId = driverId; }
    public Integer getRestaurantId() { return restaurantId; }
    public void setRestaurantId(Integer restaurantId) { this.restaurantId = restaurantId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public Integer getFoodRating() { return foodRating != null ? foodRating : rating; }
    public void setFoodRating(Integer foodRating) { this.foodRating = foodRating; }
    public String getFoodComment() { return foodComment != null ? foodComment : comment; }
    public void setFoodComment(String foodComment) { this.foodComment = foodComment; }
    public Integer getDriverRating() { return driverRating != null ? driverRating : rating; }
    public void setDriverRating(Integer driverRating) { this.driverRating = driverRating; }
    public String getDriverComment() { return driverComment != null ? driverComment : comment; }
    public void setDriverComment(String driverComment) { this.driverComment = driverComment; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
