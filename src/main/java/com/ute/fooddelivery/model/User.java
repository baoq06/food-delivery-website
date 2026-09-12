package com.ute.fooddelivery.model;

import java.io.Serializable;

public class User implements Serializable {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private String role; // "ADMIN" hoặc "CUSTOMER"
    private String avatar;

    public User() {
    }

    public User(int id, String username, String password, String fullName, String email, String phone, String address, String role) {
        this(id, username, password, fullName, email, phone, address, role, null);
    }

    public User(int id, String username, String password, String fullName, String email, String phone, String address, String role, String avatar) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.role = role;
        this.avatar = avatar;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(this.role);
    }

    public boolean isSeller() {
        return "SELLER".equalsIgnoreCase(this.role) || "MERCHANT".equalsIgnoreCase(this.role) || "RESTAURANT_OWNER".equalsIgnoreCase(this.role);
    }

    public boolean isCustomer() {
        return "CUSTOMER".equalsIgnoreCase(this.role);
    }

    public boolean isShipper() {
        return "SHIPPER".equalsIgnoreCase(this.role) || "DRIVER".equalsIgnoreCase(this.role);
    }
}
