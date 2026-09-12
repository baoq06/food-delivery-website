package com.ute.fooddelivery.model;

import java.io.Serializable;

public class Driver implements Serializable {
    private int id;
    private String name;
    private String phone;
    private String status; // "AVAILABLE", "BUSY", "OFFLINE"

    private Integer userId;
    private String licensePlate;
    private String vehicleType;

    public Driver() {
    }

    public Driver(int id, String name, String phone, String status) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.status = status;
    }

    public Driver(int id, Integer userId, String name, String phone, String status, String licensePlate, String vehicleType) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.phone = phone;
        this.status = status;
        this.licensePlate = licensePlate;
        this.vehicleType = vehicleType;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }

    public boolean isAvailable() {
        return "AVAILABLE".equalsIgnoreCase(this.status);
    }
}
