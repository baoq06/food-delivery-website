package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "restaurants")
public class Restaurant implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "restaurant_id")
    private int id;

    @Column(name = "user_id")
    private Integer userId; // ID chủ quán (user role SELLER)

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "phone")
    private String phone;

    @Column(name = "address")
    private String address;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "status")
    private String status;

    @Column(name = "open_time")
    private String openTime;  // Ví dụ: '07:00'

    @Column(name = "close_time")
    private String closeTime; // Ví dụ: '22:00'

    @Transient
    private double rating;

    @Transient
    private int reviewCount;

    @Transient
    private Map<Integer, Integer> ratingBreakdown = new HashMap<>();

    @Transient
    private List<Review> reviews = new ArrayList<>();

    @Transient
    private int totalOrders;

    public Restaurant() {
    }

    public Restaurant(int id, String name, String description, String phone, String address, String imageUrl, String status) {
        this(id, null, name, description, phone, address, imageUrl, status, "07:00", "22:00");
    }

    public Restaurant(int id, Integer userId, String name, String description, String phone, String address, String imageUrl, String status) {
        this(id, userId, name, description, phone, address, imageUrl, status, "07:00", "22:00");
    }

    public Restaurant(int id, Integer userId, String name, String description, String phone, String address, String imageUrl, String status, String openTime, String closeTime) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.description = description;
        this.phone = phone;
        this.address = address;
        this.imageUrl = imageUrl;
        this.status = status;
        this.openTime = openTime != null ? openTime : "07:00";
        this.closeTime = closeTime != null ? closeTime : "22:00";
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getOpenTime() {
        return openTime;
    }

    public void setOpenTime(String openTime) {
        this.openTime = openTime;
    }

    public String getCloseTime() {
        return closeTime;
    }

    public void setCloseTime(String closeTime) {
        this.closeTime = closeTime;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public Map<Integer, Integer> getRatingBreakdown() {
        return ratingBreakdown;
    }

    public void setRatingBreakdown(Map<Integer, Integer> ratingBreakdown) {
        this.ratingBreakdown = ratingBreakdown != null ? ratingBreakdown : new HashMap<>();
    }

    public List<Review> getReviews() {
        return reviews;
    }

    public void setReviews(List<Review> reviews) {
        this.reviews = reviews != null ? reviews : new ArrayList<>();
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public int getStarPercentage(int star) {
        if (reviewCount <= 0 || ratingBreakdown == null) return 0;
        int count = ratingBreakdown.getOrDefault(star, 0);
        return (int) Math.round(((double) count / reviewCount) * 100);
    }
}
