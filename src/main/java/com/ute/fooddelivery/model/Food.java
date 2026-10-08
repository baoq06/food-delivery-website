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
import java.util.List;

@Entity
@Table(name = "foods")
public class Food implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "food_id")
    private int id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @Column(name = "price", nullable = false)
    private double price;

    @Column(name = "image_url")
    private String image;

    @Column(name = "category_id", nullable = false)
    private int categoryId;

    @Transient
    private String categoryName;

    @Column(name = "restaurant_id", nullable = false)
    private int restaurantId;

    @Transient
    private String restaurantName;

    @Column(name = "is_available")
    private boolean available;

    @Column(name = "is_combo")
    private boolean isCombo;

    @Column(name = "original_price")
    private Double originalPrice;

    @Column(name = "combo_items")
    private String comboItems;

    @Transient
    private double rating;

    @Transient
    private int reviewCount;

    @Transient
    private List<Review> reviews = new ArrayList<>();

    public Food() {
    }

    public Food(int id, String name, String description, double price, String image, int categoryId, boolean available) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.image = image;
        this.categoryId = categoryId;
        this.available = available;
    }

    public Food(int id, String name, String description, double price, String image, 
                int categoryId, String categoryName, int restaurantId, String restaurantName, boolean available) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.image = image;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.restaurantId = restaurantId;
        this.restaurantName = restaurantName;
        this.available = available;
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

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getImageUrl() {
        return image;
    }

    public void setImageUrl(String image) {
        this.image = image;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getRestaurantName() {
        return restaurantName;
    }

    public void setRestaurantName(String restaurantName) {
        this.restaurantName = restaurantName;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
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

    public List<Review> getReviews() {
        return reviews;
    }

    public void setReviews(List<Review> reviews) {
        this.reviews = reviews != null ? reviews : new ArrayList<>();
    }

    public boolean isCombo() {
        return isCombo;
    }

    public void setCombo(boolean combo) {
        isCombo = combo;
    }

    public Double getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(Double originalPrice) {
        this.originalPrice = originalPrice;
    }

    public String getComboItems() {
        return comboItems;
    }

    public void setComboItems(String comboItems) {
        this.comboItems = comboItems;
    }

    public double getSavingsAmount() {
        if (originalPrice != null && originalPrice > price) {
            return originalPrice - price;
        }
        return 0.0;
    }

    public int getSavingsPercent() {
        if (originalPrice != null && originalPrice > price && originalPrice > 0) {
            return (int) Math.round(((originalPrice - price) / originalPrice) * 100);
        }
        return 0;
    }

    public List<String> getComboItemList() {
        List<String> items = new ArrayList<>();
        if (comboItems != null && !comboItems.trim().isEmpty()) {
            String[] parts = comboItems.split("[,;+]");
            for (String p : parts) {
                if (!p.trim().isEmpty()) {
                    items.add(p.trim());
                }
            }
        }
        return items;
    }
}
