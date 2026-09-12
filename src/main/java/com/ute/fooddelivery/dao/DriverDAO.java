package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DriverDAO {

    public List<Driver> getAllDrivers() {
        List<Driver> list = new ArrayList<>();
        String query = "SELECT driver_id, user_id, name, phone, status, license_plate, vehicle_type FROM drivers ORDER BY status ASC, driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToDriver(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách tài xế: " + e.getMessage());
        }
        return list;
    }

    public List<Driver> getAvailableDrivers() {
        List<Driver> list = new ArrayList<>();
        String query = "SELECT driver_id, user_id, name, phone, status, license_plate, vehicle_type FROM drivers WHERE status = 'AVAILABLE' ORDER BY driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToDriver(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách tài xế khả dụng: " + e.getMessage());
        }
        return list;
    }

    public Driver getDriverById(int id) {
        String query = "SELECT driver_id, user_id, name, phone, status, license_plate, vehicle_type FROM drivers WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToDriver(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm tài xế theo ID: " + e.getMessage());
        }
        return null;
    }

    public Driver getDriverByUserId(int userId) {
        String query = "SELECT driver_id, user_id, name, phone, status, license_plate, vehicle_type FROM drivers WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapResultSetToDriver(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tìm tài xế theo User ID: " + e.getMessage());
        }
        return null;
    }

    public Driver getOrCreateDriverForUser(User user) {
        if (user == null) return null;
        Driver driver = getDriverByUserId(user.getId());
        if (driver != null) return driver;

        String insertSql = "INSERT INTO drivers (user_id, name, phone, status, license_plate, vehicle_type) VALUES (?, ?, ?, 'AVAILABLE', '59-X3 999.99', 'Xe máy')";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, user.getId());
                    ps.setString(2, user.getFullName());
                    ps.setString(3, user.getPhone());
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi tự động tạo tài xế cho user " + user.getId() + ": " + e.getMessage());
        }
        return getDriverByUserId(user.getId());
    }

    public boolean updateStatusByUserId(int userId, String status) {
        String query = "UPDATE drivers SET status = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, status);
                    ps.setInt(2, userId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái tài xế qua User ID: " + e.getMessage());
        }
        return false;
    }

    public boolean updateStatus(int driverId, String status) {
        String query = "UPDATE drivers SET status = ? WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, status);
                    ps.setInt(2, driverId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật trạng thái tài xế: " + e.getMessage());
        }
        return false;
    }

    public boolean recordDriverPayment(int restaurantId, int driverId, Integer orderId, double amount, String paymentMethod, String note) {
        String query = "INSERT INTO driver_payments (restaurant_id, driver_id, order_id, amount, payment_method, note) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    ps.setInt(2, driverId);
                    if (orderId != null && orderId > 0) {
                        ps.setInt(3, orderId);
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    ps.setDouble(4, amount);
                    ps.setString(5, paymentMethod != null ? paymentMethod : "CASH");
                    ps.setString(6, note);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi ghi nhận thanh toán phí shipper: " + e.getMessage());
        }
        return false;
    }

    public double getTotalPaidToDrivers(int restaurantId) {
        String query = "SELECT COALESCE(SUM(amount), 0) FROM driver_payments WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, restaurantId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return rs.getDouble(1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi tính tổng phí đã trả shipper: " + e.getMessage());
        }
        return 0.0;
    }

    private Driver mapResultSetToDriver(ResultSet rs) throws Exception {
        int driverId = rs.getInt("driver_id");
        String name = rs.getString("name");
        String phone = rs.getString("phone");
        String status = rs.getString("status");

        Integer userId = null;
        String licensePlate = "59-X3 999.99";
        String vehicleType = "Xe máy";
        try {
            int uid = rs.getInt("user_id");
            if (!rs.wasNull()) userId = uid;
        } catch (Exception ignored) {}
        try {
            String lp = rs.getString("license_plate");
            if (lp != null && !lp.trim().isEmpty()) licensePlate = lp;
        } catch (Exception ignored) {}
        try {
            String vt = rs.getString("vehicle_type");
            if (vt != null && !vt.trim().isEmpty()) vehicleType = vt;
        } catch (Exception ignored) {}

        String idCardFront = null;
        String idCardBack = null;
        String vehicleDoc = null;
        String avatar = null;
        try {
            idCardFront = rs.getString("id_card_front");
        } catch (Exception ignored) {}
        try {
            idCardBack = rs.getString("id_card_back");
        } catch (Exception ignored) {}
        try {
            vehicleDoc = rs.getString("vehicle_doc");
        } catch (Exception ignored) {}
        try {
            avatar = rs.getString("avatar");
        } catch (Exception ignored) {}

        return new Driver(driverId, userId, name, phone, status, licensePlate, vehicleType, idCardFront, idCardBack, vehicleDoc, avatar);
    }
}

