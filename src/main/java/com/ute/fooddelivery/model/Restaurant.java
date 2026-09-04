package com.ute.fooddelivery.model;

import java.io.Serializable;

public class Restaurant implements Serializable {
    private int id;
    private Integer userId; // ID chủ quán (user role SELLER)
    private String name;
    private String description;
    private String phone;
    private String address;
    private String imageUrl;
    private String status;

    public Restaurant() {
    }

    public Restaurant(int id, String name, String description, String phone, String address, String imageUrl, String status) {
        this(id, null, name, description, phone, address, imageUrl, status);
    }

    public Restaurant(int id, Integer userId, String name, String description, String phone, String address, String imageUrl, String status) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.description = description;
        this.phone = phone;
        this.address = address;
        this.imageUrl = imageUrl;
        this.status = status;
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
}
