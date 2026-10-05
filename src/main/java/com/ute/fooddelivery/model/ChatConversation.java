package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ChatConversation implements Serializable {
    private int id;
    private int userId;
    private int restaurantId;
    private String lastMessage;
    private Timestamp lastMessageAt;
    private int unreadUserCount;
    private int unreadMerchantCount;
    private Timestamp createdAt;

    // Transient attributes for UI rendering
    private String userName;
    private String userAvatar;
    private String userPhone;
    private String restaurantName;
    private String restaurantAvatar;
    private String restaurantAddress;
    private String restaurantPhone;

    public ChatConversation() {
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

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public Timestamp getLastMessageAt() {
        return lastMessageAt;
    }

    public void setLastMessageAt(Timestamp lastMessageAt) {
        this.lastMessageAt = lastMessageAt;
    }

    public int getUnreadUserCount() {
        return unreadUserCount;
    }

    public void setUnreadUserCount(int unreadUserCount) {
        this.unreadUserCount = unreadUserCount;
    }

    public int getUnreadMerchantCount() {
        return unreadMerchantCount;
    }

    public void setUnreadMerchantCount(int unreadMerchantCount) {
        this.unreadMerchantCount = unreadMerchantCount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserAvatar() {
        return userAvatar;
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public String getUserPhone() {
        return userPhone;
    }

    public void setUserPhone(String userPhone) {
        this.userPhone = userPhone;
    }

    public String getRestaurantName() {
        return restaurantName;
    }

    public void setRestaurantName(String restaurantName) {
        this.restaurantName = restaurantName;
    }

    public String getRestaurantAvatar() {
        return restaurantAvatar;
    }

    public void setRestaurantAvatar(String restaurantAvatar) {
        this.restaurantAvatar = restaurantAvatar;
    }

    public String getRestaurantAddress() {
        return restaurantAddress;
    }

    public void setRestaurantAddress(String restaurantAddress) {
        this.restaurantAddress = restaurantAddress;
    }

    public String getRestaurantPhone() {
        return restaurantPhone;
    }

    public void setRestaurantPhone(String restaurantPhone) {
        this.restaurantPhone = restaurantPhone;
    }
}
