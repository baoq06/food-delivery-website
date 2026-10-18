package com.ute.fooddelivery.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class Order implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    private int id;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "customer_name", nullable = false)
    private String customerName;

    @Column(name = "phone", nullable = false)
    private String phone;

    @Column(name = "address", nullable = false)
    private String address;

    @Column(name = "note")
    private String note;

    @Column(name = "total_amount", nullable = false)
    private double totalAmount;

    @Column(name = "payment_method")
    private String paymentMethod;

    @Column(name = "status")
    private String status;

    @Column(name = "driver_id")
    private Integer driverId;

    @Transient
    private String driverName;

    @Transient
    private String driverPhone;

    @Column(name = "created_at")
    private Timestamp createdAt;

    @Column(name = "customer_confirmed")
    private boolean customerConfirmed;

    @Column(name = "merchant_confirmed")
    private boolean merchantConfirmed;

    @Column(name = "shipping_fee")
    private double shippingFee = 15000.0;

    @Column(name = "distance_km")
    private double distanceKm = 2.0;

    @Column(name = "discount_amount")
    private double discountAmount = 0.0;

    @Column(name = "voucher_code")
    private String voucherCode;

    @Column(name = "shipper_accepted")
    private boolean shipperAccepted;

    @Column(name = "shipper_picked_up")
    private boolean shipperPickedUp;

    @Column(name = "shipper_delivered")
    private boolean shipperDelivered;

    @Column(name = "merchant_completed")
    private boolean merchantCompleted;

    @Column(name = "proof_image")
    private String proofImage;

    public String getProofImage() { return proofImage; }
    public void setProofImage(String proofImage) { this.proofImage = proofImage; }

    @Transient
    private Review review;

    @Transient
    private String foodSummary;

    @Transient
    private double foodValue;

    @Transient
    private double adminCommission;

    public Review getReview() { return review; }
    public void setReview(Review review) { this.review = review; }
    public String getFoodSummary() { return foodSummary; }
    public void setFoodSummary(String foodSummary) { this.foodSummary = foodSummary; }
    public double getFoodValue() { return foodValue; }
    public void setFoodValue(double foodValue) { this.foodValue = foodValue; }
    public double getAdminCommission() { return adminCommission; }
    public void setAdminCommission(double adminCommission) { this.adminCommission = adminCommission; }

    @Transient
    private Integer restaurantId;

    @Transient
    private String restaurantName;

    @Transient
    private String restaurantImage;

    @Transient
    private String restaurantAddress;

    @Transient
    private Double restaurantLatitude;

    @Transient
    private Double restaurantLongitude;

    @Transient
    private Double customerLatitude;

    @Transient
    private Double customerLongitude;

    @Transient
    private String restaurantBankCode = "TCB";

    @Transient
    private String restaurantBankName = "Techcombank";

    @Transient
    private String restaurantBankAccountNo = "1907 2878 4280 15";

    @Transient
    private String restaurantBankAccountName = "LE HAI DANG";

    public String getRestaurantBankCode() { return restaurantBankCode; }
    public void setRestaurantBankCode(String restaurantBankCode) { this.restaurantBankCode = restaurantBankCode; }
    public String getRestaurantBankName() { return restaurantBankName; }
    public void setRestaurantBankName(String restaurantBankName) { this.restaurantBankName = restaurantBankName; }
    public String getRestaurantBankAccountNo() { return restaurantBankAccountNo; }
    public void setRestaurantBankAccountNo(String restaurantBankAccountNo) { this.restaurantBankAccountNo = restaurantBankAccountNo; }
    public String getRestaurantBankAccountName() { return restaurantBankAccountName; }
    public void setRestaurantBankAccountName(String restaurantBankAccountName) { this.restaurantBankAccountName = restaurantBankAccountName; }

    public String getCleanRestaurantBankAccountNo() {
        return restaurantBankAccountNo != null ? restaurantBankAccountNo.replaceAll("[\\s\\-\\.]", "") : "19072878428015";
    }

    public String getVietQrUrl() {
        String code = (restaurantBankCode != null && !restaurantBankCode.trim().isEmpty()) ? restaurantBankCode.trim() : "TCB";
        String acc = getCleanRestaurantBankAccountNo();
        String name = (restaurantBankAccountName != null && !restaurantBankAccountName.trim().isEmpty()) ? restaurantBankAccountName.trim() : (restaurantName != null ? restaurantName : "LE HAI DANG");
        try {
            return "https://img.vietqr.io/image/" + code + "-" + acc + "-compact2.png?amount=" + (long) Math.round(totalAmount) + "&addInfo=DH" + id + "&accountName=" + java.net.URLEncoder.encode(name, java.nio.charset.StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "https://img.vietqr.io/image/" + code + "-" + acc + "-compact2.png?amount=" + (long) Math.round(totalAmount) + "&addInfo=DH" + id;
        }
    }

    public Integer getRestaurantId() { return restaurantId; }
    public void setRestaurantId(Integer restaurantId) { this.restaurantId = restaurantId; }
    public String getRestaurantName() { return restaurantName; }
    public void setRestaurantName(String restaurantName) { this.restaurantName = restaurantName; }
    public String getRestaurantImage() { return restaurantImage; }
    public void setRestaurantImage(String restaurantImage) { this.restaurantImage = restaurantImage; }
    public String getRestaurantAddress() { return restaurantAddress; }
    public void setRestaurantAddress(String restaurantAddress) { this.restaurantAddress = restaurantAddress; }

    public Double getRestaurantLatitude() { return restaurantLatitude; }
    public void setRestaurantLatitude(Double restaurantLatitude) { this.restaurantLatitude = restaurantLatitude; }
    public Double getRestaurantLongitude() { return restaurantLongitude; }
    public void setRestaurantLongitude(Double restaurantLongitude) { this.restaurantLongitude = restaurantLongitude; }
    public Double getCustomerLatitude() { return customerLatitude; }
    public void setCustomerLatitude(Double customerLatitude) { this.customerLatitude = customerLatitude; }
    public Double getCustomerLongitude() { return customerLongitude; }
    public void setCustomerLongitude(Double customerLongitude) { this.customerLongitude = customerLongitude; }

    @Transient
    private List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt) {
        this(id, userId, customerName, phone, address, note, totalAmount, paymentMethod, status, driverId, createdAt, false, false, false, false, false);
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt, boolean customerConfirmed, boolean merchantConfirmed) {
        this(id, userId, customerName, phone, address, note, totalAmount, paymentMethod, status, driverId, createdAt, customerConfirmed, merchantConfirmed, false, false, merchantConfirmed);
    }

    public Order(int id, Integer userId, String customerName, String phone, String address, 
                 String note, double totalAmount, String paymentMethod, String status, 
                 Integer driverId, Timestamp createdAt, boolean customerConfirmed, boolean merchantConfirmed,
                 boolean shipperAccepted, boolean shipperDelivered, boolean merchantCompleted) {
        this.id = id;
        this.userId = userId;
        this.customerName = customerName;
        this.phone = phone;
        this.address = address;
        this.note = note;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.status = status;
        this.driverId = driverId;
        this.createdAt = createdAt;
        this.customerConfirmed = customerConfirmed;
        this.merchantConfirmed = merchantConfirmed;
        this.shipperAccepted = shipperAccepted;
        this.shipperDelivered = shipperDelivered;
        this.merchantCompleted = merchantCompleted;
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

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
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

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDriverId() {
        return driverId;
    }

    public void setDriverId(Integer driverId) {
        this.driverId = driverId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverPhone() {
        return driverPhone;
    }

    public void setDriverPhone(String driverPhone) {
        this.driverPhone = driverPhone;
    }

    public boolean isCustomerConfirmed() {
        return customerConfirmed;
    }

    public void setCustomerConfirmed(boolean customerConfirmed) {
        this.customerConfirmed = customerConfirmed;
    }

    public boolean isMerchantConfirmed() {
        return merchantConfirmed;
    }

    public void setMerchantConfirmed(boolean merchantConfirmed) {
        this.merchantConfirmed = merchantConfirmed;
    }

    public boolean isShipperAccepted() {
        return shipperAccepted;
    }

    public void setShipperAccepted(boolean shipperAccepted) {
        this.shipperAccepted = shipperAccepted;
    }

    public boolean isShipperDelivered() {
        return shipperDelivered;
    }

    public void setShipperDelivered(boolean shipperDelivered) {
        this.shipperDelivered = shipperDelivered;
    }

    public boolean isMerchantCompleted() {
        return merchantCompleted;
    }

    public void setMerchantCompleted(boolean merchantCompleted) {
        this.merchantCompleted = merchantCompleted;
    }

    public boolean isFullyConfirmed() {
        return customerConfirmed && merchantConfirmed;
    }

    /**
     * Kiểm tra đơn đã sẵn sàng để hoàn thành:
     * Chỉ cần Shipper xác nhận đã giao hàng tận tay cho khách (Khách không bắt buộc phải bấm nhận món).
     */
    public boolean isReadyForMerchantComplete() {
        return shipperDelivered;
    }

    public boolean isShipperPickedUp() {
        return shipperPickedUp;
    }

    public void setShipperPickedUp(boolean shipperPickedUp) {
        this.shipperPickedUp = shipperPickedUp;
    }

    public double getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(double shippingFee) {
        this.shippingFee = shippingFee;
    }

    public double getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(double distanceKm) {
        this.distanceKm = distanceKm;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    @Column(name = "voucher_refunded")
    private boolean voucherRefunded;

    public boolean isVoucherRefunded() {
        return voucherRefunded;
    }

    public void setVoucherRefunded(boolean voucherRefunded) {
        this.voucherRefunded = voucherRefunded;
    }

    /**
     * Kiểm tra Quán có thể bắt đầu nấu hay chưa:
     * Quán có thể nấu ngay khi đơn hợp lệ (chưa bị hủy hay hoàn tất).
     */
    public boolean canStartCooking() {
        return !"CANCELLED".equalsIgnoreCase(status) && !"DELIVERED".equalsIgnoreCase(status);
    }

    /**
     * Kiểm tra Quán có thể bàn giao món cho tài xế đi giao hay chưa:
     * Cần đã gán tài xế VÀ tài xế đó đã bấm chấp nhận giao đơn.
     */
    public boolean canHandoverToShipper() {
        return driverId != null && driverId > 0 && shipperAccepted;
    }
}
