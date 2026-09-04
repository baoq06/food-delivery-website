package com.ute.fooddelivery.model;

import java.io.Serializable;

public class RevenueStat implements Serializable {
    private String label;      // Nhãn hiển thị (ví dụ: "Ngày 05", "Tháng 09", "2026")
    private int periodKey;     // Khóa thời gian (ngày: 1-31, tháng: 1-12, năm: 2026)
    private double revenue;    // Tổng doanh thu thực tế
    private int orderCount;    // Số lượng đơn hàng
    private int itemCount;     // Số lượng món bán được

    public RevenueStat() {
    }

    public RevenueStat(String label, int periodKey, double revenue, int orderCount, int itemCount) {
        this.label = label;
        this.periodKey = periodKey;
        this.revenue = revenue;
        this.orderCount = orderCount;
        this.itemCount = itemCount;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public int getPeriodKey() {
        return periodKey;
    }

    public void setPeriodKey(int periodKey) {
        this.periodKey = periodKey;
    }

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) {
        this.orderCount = orderCount;
    }

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }
}
