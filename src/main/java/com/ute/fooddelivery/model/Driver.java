package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "drivers")
public class Driver implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "driver_id")
    private int id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "phone", nullable = false)
    private String phone;

    @Column(name = "status")
    private String status; // "AVAILABLE", "BUSY", "OFFLINE"

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "license_plate")
    private String licensePlate;

    @Column(name = "vehicle_type")
    private String vehicleType;

    @Column(name = "id_card_front")
    private String idCardFront;

    @Column(name = "id_card_back")
    private String idCardBack;

    @Column(name = "vehicle_doc")
    private String vehicleDoc;

    @Column(name = "avatar")
    private String avatar;

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

    public Driver(int id, Integer userId, String name, String phone, String status, String licensePlate, String vehicleType, String idCardFront, String idCardBack, String vehicleDoc, String avatar) {
        this.id = id;
        this.userId = userId;
        this.name = name;
        this.phone = phone;
        this.status = status;
        this.licensePlate = licensePlate;
        this.vehicleType = vehicleType;
        this.idCardFront = idCardFront;
        this.idCardBack = idCardBack;
        this.vehicleDoc = vehicleDoc;
        this.avatar = avatar;
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

    public String getIdCardFront() {
        return idCardFront;
    }

    public void setIdCardFront(String idCardFront) {
        this.idCardFront = idCardFront;
    }

    public String getIdCardBack() {
        return idCardBack;
    }

    public void setIdCardBack(String idCardBack) {
        this.idCardBack = idCardBack;
    }

    public String getVehicleDoc() {
        return vehicleDoc;
    }

    public void setVehicleDoc(String vehicleDoc) {
        this.vehicleDoc = vehicleDoc;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    private int pendingOrderCount = 0;

    public int getPendingOrderCount() {
        return pendingOrderCount;
    }

    public void setPendingOrderCount(int pendingOrderCount) {
        this.pendingOrderCount = pendingOrderCount;
    }

    public boolean isAvailable() {
        return "AVAILABLE".equalsIgnoreCase(this.status);
    }
}
