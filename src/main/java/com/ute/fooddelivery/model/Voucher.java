package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.text.DecimalFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class Voucher implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum DiscountType {
        FIXED,
        PERCENT
    }

    private int id;
    private String code;
    private String title;
    private String description;
    private DiscountType discountType = DiscountType.FIXED;
    private double discountValue;
    private double minOrderAmount;
    private double maxDiscount;
    private boolean isFreeShip;
    private String badge;
    private Integer restaurantId;
    private String restaurantName;
    private int usageLimit = 0; // 0: Không giới hạn
    private int usedCount = 0;
    private int perUserLimit = 1;
    private String startDate;
    private String endDate;
    private boolean isActive = true;

    public Voucher() {
    }

    public Voucher(String code, String title, String description, DiscountType discountType, 
                   double discountValue, double minOrderAmount, double maxDiscount, 
                   boolean isFreeShip, String badge) {
        this(code, title, description, discountType, discountValue, minOrderAmount, maxDiscount, isFreeShip, badge, null, null);
    }

    public Voucher(String code, String title, String description, DiscountType discountType, 
                   double discountValue, double minOrderAmount, double maxDiscount, 
                   boolean isFreeShip, String badge, Integer restaurantId, String restaurantName) {
        this.code = code;
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
        this.isActive = true;
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

    public boolean isExpired() {
        if (endDate == null || endDate.trim().isEmpty()) {
            return false;
        }
        try {
            LocalDate end = LocalDate.parse(endDate.trim());
            return LocalDate.now().isAfter(end);
        } catch (Exception e) {
            return false;
        }
    }

    public boolean isStarted() {
        if (startDate == null || startDate.trim().isEmpty()) {
            return true;
        }
        try {
            LocalDate start = LocalDate.parse(startDate.trim());
            return !LocalDate.now().isBefore(start);
        } catch (Exception e) {
            return true;
        }
    }

    public boolean isFullyUsed() {
        return usageLimit > 0 && usedCount >= usageLimit;
    }

    public boolean isAvailable() {
        return isActive && !isExpired() && isStarted() && !isFullyUsed();
    }

    public int getRemainingUsage() {
        if (usageLimit <= 0) return -1; // Vô hạn
        return Math.max(0, usageLimit - usedCount);
    }

    public int getUsagePercentage() {
        if (usageLimit <= 0) return 0;
        return (int) Math.min(100, Math.round(((double) usedCount / usageLimit) * 100));
    }

    public String getFormattedDiscount() {
        DecimalFormat df = new DecimalFormat("#,###");
        if (isFreeShip) {
            return "Freeship " + df.format(discountValue) + " đ";
        }
        if (discountType == DiscountType.PERCENT) {
            String s = "Giảm " + df.format(discountValue) + "%";
            if (maxDiscount > 0) {
                s += " (Tối đa " + df.format(maxDiscount) + " đ)";
            }
            return s;
        }
        return "Giảm " + df.format(discountValue) + " đ";
    }

    public String getFormattedMinOrder() {
        DecimalFormat df = new DecimalFormat("#,###");
        if (minOrderAmount <= 0) return "Đơn bất kỳ";
        return "Đơn từ " + df.format(minOrderAmount) + " đ";
    }

    public String getFormattedExpiry() {
        if (endDate == null || endDate.trim().isEmpty()) {
            return "Vô thời hạn";
        }
        try {
            LocalDate end = LocalDate.parse(endDate.trim());
            return "HSD: " + end.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        } catch (Exception e) {
            return "HSD: " + endDate;
        }
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public int getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(int usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public int getPerUserLimit() {
        return perUserLimit;
    }

    public void setPerUserLimit(int perUserLimit) {
        this.perUserLimit = perUserLimit;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
