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
        String query = "SELECT d.driver_id, d.user_id, d.name, d.phone, d.status, d.license_plate, d.vehicle_type, " +
                       "(SELECT COUNT(*) FROM orders o WHERE o.driver_id = d.driver_id AND o.shipper_accepted = 0 AND o.status != 'CANCELLED') AS pending_count " +
                       "FROM drivers d ORDER BY d.status ASC, d.driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Driver driver = mapResultSetToDriver(rs);
                        driver.setPendingOrderCount(rs.getInt("pending_count"));
                        list.add(driver);
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
        String query = "SELECT d.driver_id, d.user_id, d.name, d.phone, d.status, d.license_plate, d.vehicle_type, " +
                       "(SELECT COUNT(*) FROM orders o WHERE o.driver_id = d.driver_id AND o.shipper_accepted = 0 AND o.status != 'CANCELLED') AS pending_count " +
                       "FROM drivers d WHERE d.status = 'AVAILABLE' ORDER BY d.driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Driver driver = mapResultSetToDriver(rs);
                        driver.setPendingOrderCount(rs.getInt("pending_count"));
                        list.add(driver);
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

        Driver driver = new Driver(driverId, userId, name, phone, status, licensePlate, vehicleType, idCardFront, idCardBack, vehicleDoc, avatar);

        try {
            double lat = rs.getDouble("current_latitude");
            if (!rs.wasNull()) driver.setCurrentLatitude(lat);
        } catch (Exception ignored) {}
        try {
            double lng = rs.getDouble("current_longitude");
            if (!rs.wasNull()) driver.setCurrentLongitude(lng);
        } catch (Exception ignored) {}
        try {
            String addr = rs.getString("current_address");
            if (addr != null && !addr.trim().isEmpty()) driver.setCurrentAddress(addr);
        } catch (Exception ignored) {}
        try {
            driver.setLastLocationUpdated(rs.getTimestamp("last_location_updated"));
        } catch (Exception ignored) {}

        return driver;
    }

    /**
     * Cập nhật vị trí thời gian thực (GPS) của tài xế
     */
    public boolean updateLocation(int driverId, double lat, double lng, String address) {
        String query = "UPDATE drivers SET current_latitude = ?, current_longitude = ?, current_address = ?, last_location_updated = CURRENT_TIMESTAMP WHERE driver_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setDouble(1, lat);
            ps.setDouble(2, lng);
            ps.setString(3, address != null ? address : "TP. Thủ Đức, TP. Hồ Chí Minh");
            ps.setInt(4, driverId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật tọa độ tài xế #" + driverId + ": " + e.getMessage());
        }
        return false;
    }

    /**
     * Cập nhật vị trí thời gian thực theo userId
     */
    public boolean updateLocationByUserId(int userId, double lat, double lng, String address) {
        String query = "UPDATE drivers SET current_latitude = ?, current_longitude = ?, current_address = ?, last_location_updated = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setDouble(1, lat);
            ps.setDouble(2, lng);
            ps.setString(3, address != null ? address : "TP. Thủ Đức, TP. Hồ Chí Minh");
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật tọa độ tài xế qua User ID #" + userId + ": " + e.getMessage());
        }
        return false;
    }

    /**
     * Lấy danh sách tài xế đang SẴN SÀNG (AVAILABLE) và KHÔNG ĐANG GIAO ĐƠN NÀO
     */
    public List<Driver> getAvailableDriversWithoutActiveOrders() {
        List<Driver> list = new ArrayList<>();
        String query = "SELECT d.*, " +
                       "(SELECT COUNT(*) FROM orders o WHERE o.driver_id = d.driver_id AND o.shipper_accepted = 0 AND o.status != 'CANCELLED') AS pending_count " +
                       "FROM drivers d " +
                       "WHERE d.status = 'AVAILABLE' " +
                       "AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.driver_id = d.driver_id AND o.status = 'SHIPPING') " +
                       "AND NOT EXISTS (SELECT 1 FROM orders o WHERE o.driver_id = d.driver_id AND o.shipper_accepted = 1 AND o.shipper_delivered = 0 AND o.status != 'CANCELLED') " +
                       "ORDER BY d.driver_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int pendingCount = rs.getInt("pending_count");
                        if (pendingCount < 3) {
                            Driver driver = mapResultSetToDriver(rs);
                            driver.setPendingOrderCount(pendingCount);
                            list.add(driver);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách tài xế không bận giao đơn: " + e.getMessage());
        }
        return list;
    }

    /**
     * THUẬT TOÁN TÌM SHIPPER GẦN QUÁN NHẤT KHÔNG ĐANG GIAO ĐƠN NÀO:
     * 1. Lọc các tài xế AVAILABLE, không bận đơn nào khác.
     * 2. Dò đường và đo cự ly (km) từ tọa độ hiện tại của mỗi shipper đến quán ăn (Haversine + OSRM).
     * 3. Sắp xếp danh sách tài xế tăng dần theo cự ly (tài xế gần quán nhất đứng đầu tiên).
     */
    public List<Driver> findNearestDrivers(double restaurantLat, double restaurantLng) {
        List<Driver> candidates = getAvailableDriversWithoutActiveOrders();
        if (candidates.isEmpty()) {
            // Nếu không có tài xế hoàn toàn rảnh, lấy tài xế AVAILABLE có pending_count < 3
            candidates = getAvailableDrivers();
        }

        for (Driver d : candidates) {
            double dLat = d.getCurrentLatitude();
            double dLng = d.getCurrentLongitude();
            double distance = com.ute.fooddelivery.utils.GeoLocationUtils.calculateRouteDistance(dLat, dLng, restaurantLat, restaurantLng);
            d.setDistanceToTarget(distance);
        }

        // Sắp xếp tăng dần theo khoảng cách đến quán
        candidates.sort((d1, d2) -> {
            Double dist1 = d1.getDistanceToTarget() != null ? d1.getDistanceToTarget() : 999.0;
            Double dist2 = d2.getDistanceToTarget() != null ? d2.getDistanceToTarget() : 999.0;
            return dist1.compareTo(dist2);
        });

        return candidates;
    }
}

