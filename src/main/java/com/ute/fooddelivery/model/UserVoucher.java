package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class UserVoucher implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String voucherCode;
    private String title;
    private String description;
    private Voucher.DiscountType discountType;
    private double discountValue;
    private double minOrderAmount;
    private double maxDiscount;
    private boolean isFreeShip;
    private String badge;
    private Integer restaurantId; // null nếu áp dụng toàn sàn, > 0 nếu áp dụng riêng cho quán
    private String restaurantName;
    private int quantity;
    private Timestamp createdAt;
    private Timestamp lastAwardedAt;

    public UserVoucher() {
    }

    public UserVoucher(int userId, String voucherCode, String title, String description,
                       Voucher.DiscountType discountType, double discountValue, double minOrderAmount,
                       double maxDiscount, boolean isFreeShip, String badge,
                       Integer restaurantId, String restaurantName, int quantity) {
        this.userId = userId;
        this.voucherCode = voucherCode;
        this.title = title;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.minOrderAmount = minOrderAmount;
        this.maxDiscount = maxDiscount;
        this.isFreeShip = isFreeShip;
        this.badge = badge;
        this.restaurantId = restaurantId;
        this.restaurantName = restaurantName;
        this.quantity = quantity;
    }

    public double calculateDiscount(double subtotal, double shippingFee) {
        if (subtotal < minOrderAmount) {
            return 0.0;
        }

        double discount = 0.0;
        if (isFreeShip) {
            discount = Math.min(shippingFee, discountValue > 0 ? discountValue : shippingFee);
        } else if (discountType == Voucher.DiscountType.PERCENT) {
            discount = subtotal * (discountValue / 100.0);
            if (maxDiscount > 0 && discount > maxDiscount) {
                discount = maxDiscount;
            }
        } else {
            discount = discountValue;
        }

        double maxPossible = isFreeShip ? shippingFee : subtotal;
        return Math.min(discount, maxPossible);
    }

    public boolean isEligibleForRestaurant(int cartRestaurantId) {
        if (restaurantId == null || restaurantId <= 0) {
            return true; // Áp dụng cho mọi quán
        }
        return restaurantId == cartRestaurantId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public String getCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Voucher.DiscountType getDiscountType() {
        return discountType;
    }

    public void setDiscountType(Voucher.DiscountType discountType) {
        this.discountType = discountType;
    }

    public double getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(double discountValue) {
        this.discountValue = discountValue;
    }

    public double getMinOrderAmount() {
        return minOrderAmount;
    }

    public void setMinOrderAmount(double minOrderAmount) {
        this.minOrderAmount = minOrderAmount;
    }

    public double getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(double maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public boolean isFreeShip() {
        return isFreeShip;
    }

    public void setFreeShip(boolean freeShip) {
        isFreeShip = freeShip;
    }

    public String getBadge() {
        return badge;
    }

    public void setBadge(String badge) {
        this.badge = badge;
    }

    public Integer getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(Integer restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getRestaurantName() {
        return restaurantName;
    }

    public void setRestaurantName(String restaurantName) {
        this.restaurantName = restaurantName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getLastAwardedAt() {
        return lastAwardedAt;
    }

    public void setLastAwardedAt(Timestamp lastAwardedAt) {
        this.lastAwardedAt = lastAwardedAt;
    }
}
