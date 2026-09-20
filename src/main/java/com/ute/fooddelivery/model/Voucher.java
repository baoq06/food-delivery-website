package com.ute.fooddelivery.model;

import java.io.Serializable;

public class Voucher implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum DiscountType {
        FIXED,
        PERCENT
    }

    private String code;
    private String title;
    private String description;
    private DiscountType discountType;
    private double discountValue;
    private double minOrderAmount;
    private double maxDiscount;
    private boolean isFreeShip;
    private String badge;

    public Voucher() {
    }

    public Voucher(String code, String title, String description, DiscountType discountType, 
                   double discountValue, double minOrderAmount, double maxDiscount, 
                   boolean isFreeShip, String badge) {
        this.code = code;
        this.title = title;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.minOrderAmount = minOrderAmount;
        this.maxDiscount = maxDiscount;
        this.isFreeShip = isFreeShip;
        this.badge = badge;
    }

    public double calculateDiscount(double subtotal, double shippingFee) {
        if (subtotal < minOrderAmount) {
            return 0.0;
        }

        double discount = 0.0;
        if (isFreeShip) {
            discount = Math.min(shippingFee, discountValue > 0 ? discountValue : shippingFee);
        } else if (discountType == DiscountType.PERCENT) {
            discount = subtotal * (discountValue / 100.0);
            if (maxDiscount > 0 && discount > maxDiscount) {
                discount = maxDiscount;
            }
        } else {
            discount = discountValue;
        }

        // Không bao giờ giảm vượt quá tổng tiền thực tế
        double maxPossible = isFreeShip ? shippingFee : subtotal;
        return Math.min(discount, maxPossible);
    }

    public boolean isEligible(double subtotal) {
        return subtotal >= minOrderAmount;
    }

    public double getMissingAmount(double subtotal) {
        if (isEligible(subtotal)) return 0.0;
        return minOrderAmount - subtotal;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
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

    public DiscountType getDiscountType() {
        return discountType;
    }

    public void setDiscountType(DiscountType discountType) {
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
}
