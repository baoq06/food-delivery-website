package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.io.Serializable;
import java.sql.Timestamp;

@Entity
@Table(name = "order_reviews")
public class Review implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "review_id")
    private int reviewId;

    @Column(name = "order_id", nullable = false)
    private int orderId;

    @Column(name = "customer_id", nullable = false)
    private int customerId;

    @Column(name = "driver_id")
    private Integer driverId;

    @Column(name = "restaurant_id")
    private Integer restaurantId;

    @Column(name = "rating", nullable = false)
    private int rating;

    @Column(name = "comment")
    private String comment;

    @Column(name = "food_rating")
    private Integer foodRating;

    @Column(name = "food_comment")
    private String foodComment;

    @Column(name = "driver_rating")
    private Integer driverRating;

    @Column(name = "driver_comment")
    private String driverComment;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "created_at")
    private Timestamp createdAt;

    @Transient
    private String customerName;

    @Transient
    private String customerAvatar;

    @Transient
    private String orderedFoods;

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
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getCustomerName() {
        return (customerName != null && !customerName.trim().isEmpty()) ? customerName : "Khách hàng Utee";
    }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerAvatar() { return customerAvatar; }
    public void setCustomerAvatar(String customerAvatar) { this.customerAvatar = customerAvatar; }

    public String getOrderedFoods() { return orderedFoods; }
    public void setOrderedFoods(String orderedFoods) { this.orderedFoods = orderedFoods; }

    public String getCustomerInitial() {
        String name = getCustomerName();
        if (name == null || name.trim().isEmpty()) return "U";
        String[] words = name.trim().split("\\s+");
        String lastWord = words[words.length - 1];
        return lastWord.substring(0, 1).toUpperCase();
    }
}
