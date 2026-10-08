package com.ute.fooddelivery.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class ChatMessage implements Serializable {
    private int id;
    private int conversationId;
    private int senderId;
    private String senderRole; // "CUSTOMER" hoặc "SELLER"
    private String senderName;
    private String senderAvatar;
    private String message;
    private Integer orderId;
    private boolean isRead;
    private boolean isRecalled; // Tin nhắn đã được người gửi thu hồi/gỡ
    private Timestamp createdAt;

    public ChatMessage() {
    }

    public ChatMessage(int id, int conversationId, int senderId, String senderRole, String message, Integer orderId, boolean isRead, boolean isRecalled, Timestamp createdAt) {
        this.id = id;
        this.conversationId = conversationId;
        this.senderId = senderId;
        this.senderRole = senderRole;
        this.message = message;
        this.orderId = orderId;
        this.isRead = isRead;
        this.isRecalled = isRecalled;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getConversationId() {
        return conversationId;
    }

    public void setConversationId(int conversationId) {
        this.conversationId = conversationId;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getSenderAvatar() {
        return senderAvatar;
    }

    public void setSenderAvatar(String senderAvatar) {
        this.senderAvatar = senderAvatar;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public boolean isRecalled() {
        return isRecalled;
    }

    public void setRecalled(boolean recalled) {
        isRecalled = recalled;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
