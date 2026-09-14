package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;

@Entity
@Table(name = "notifications")
public class Notification implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private int id;

    @Column(name = "user_id", nullable = false)
    private int userId;

    @Column(name = "order_id")
    private Integer orderId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "message", nullable = false)
    private String message;

    @Column(name = "type")
    private String type; // 'ORDER_NEW', 'ORDER_ASSIGNED', 'SHIPPER_ACCEPTED', 'ORDER_SHIPPING', 'SHIPPER_DELIVERED', 'CUSTOMER_CONFIRMED', 'ORDER_COMPLETED', 'ORDER_CANCELLED', 'SYSTEM'

    @Column(name = "link")
    private String link;

    @Column(name = "is_read")
    private boolean read;

    @Column(name = "created_at")
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(int userId, Integer orderId, String title, String message, String type, String link) {
        this.userId = userId;
        this.orderId = orderId;
        this.title = title;
        this.message = message;
        this.type = type != null ? type : "ORDER";
        this.link = link;
        this.read = false;
        this.createdAt = new Timestamp(System.currentTimeMillis());
    }

    public Notification(int id, int userId, Integer orderId, String title, String message, String type, String link, boolean read, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.orderId = orderId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.link = link;
        this.read = read;
        this.createdAt = createdAt;
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

    public Integer getOrderId() {
        return orderId;
    }

    public void setOrderId(Integer orderId) {
        this.orderId = orderId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Trả về định dạng thời gian tương đối thân thiện (UI/UX Pro Max)
     */
    public String getTimeAgo() {
        if (createdAt == null) return "Vừa xong";
        Instant now = Instant.now();
        Instant notifTime = createdAt.toInstant();
        Duration duration = Duration.between(notifTime, now);

        long seconds = duration.getSeconds();
        if (seconds < 60) {
            return "Vừa xong";
        }
        long minutes = duration.toMinutes();
        if (minutes < 60) {
            return minutes + " phút trước";
        }
        long hours = duration.toHours();
        if (hours < 24) {
            return hours + " giờ trước";
        }
        long days = duration.toDays();
        if (days < 7) {
            return days + " ngày trước";
        }
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
        return sdf.format(createdAt);
    }

    /**
     * Trả về CSS Icon Class phù hợp theo loại thông báo
     */
    public String getIconClass() {
        if (type == null) return "fa-solid fa-bell";
        switch (type.toUpperCase()) {
            case "ORDER_NEW":
                return "fa-solid fa-receipt text-primary";
            case "ORDER_ASSIGNED":
                return "fa-solid fa-motorcycle text-warning";
            case "SHIPPER_ACCEPTED":
                return "fa-solid fa-handshake text-info";
            case "ORDER_SHIPPING":
                return "fa-solid fa-truck-fast text-primary";
            case "SHIPPER_DELIVERED":
                return "fa-solid fa-box-open text-success";
            case "CUSTOMER_CONFIRMED":
                return "fa-solid fa-circle-check text-success";
            case "ORDER_COMPLETED":
                return "fa-solid fa-trophy text-success";
            case "ORDER_CANCELLED":
                return "fa-solid fa-circle-xmark text-danger";
            default:
                return "fa-solid fa-bell text-primary";
        }
    }
}
