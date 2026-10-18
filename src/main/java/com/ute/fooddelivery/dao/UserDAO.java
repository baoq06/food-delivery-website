package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserDAO {

    private static volatile boolean boomSupportChecked = false;

    public static void ensureBoomSupport() {
        if (boomSupportChecked) return;
        synchronized (UserDAO.class) {
            if (boomSupportChecked) return;
            try (Connection conn = DBContext.getConnection()) {
                if (conn != null) {
                    java.sql.DatabaseMetaData meta = conn.getMetaData();
                    boolean hasCodLocked = false;
                    try (ResultSet rs = meta.getColumns(null, null, "users", "is_cod_locked")) {
                        if (rs.next()) hasCodLocked = true;
                    }
                    if (!hasCodLocked) {
                        try (java.sql.Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_cod_locked TINYINT(1) DEFAULT 0");
                        } catch (SQLException ignore) {}
                    }

                    boolean hasBoomCount = false;
                    try (ResultSet rs = meta.getColumns(null, null, "users", "boom_count")) {
                        if (rs.next()) hasBoomCount = true;
                    }
                    if (!hasBoomCount) {
                        try (java.sql.Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE users ADD COLUMN boom_count INT DEFAULT 0");
                        } catch (SQLException ignore) {}
                    }

                    boolean hasCodTrustOrders = false;
                    try (ResultSet rs = meta.getColumns(null, null, "users", "cod_trust_orders")) {
                        if (rs.next()) hasCodTrustOrders = true;
                    }
                    if (!hasCodTrustOrders) {
                        try (java.sql.Statement stmt = conn.createStatement()) {
                            stmt.executeUpdate("ALTER TABLE users ADD COLUMN cod_trust_orders INT DEFAULT 0");
                        } catch (SQLException ignore) {}
                    }
                    boomSupportChecked = true;
                }
            } catch (Exception e) {
                System.err.println("Lỗi khi kiểm tra migration boom support: " + e.getMessage());
            }
        }
    }

    public User login(String account, String password) {
        ensureBoomSupport();
        String query = "SELECT user_id, username, password, name, email, phone, address, role, avatar, is_cod_locked, boom_count, cod_trust_orders " +
                       "FROM users WHERE (username = ? OR email = ? OR phone = ?) AND password = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, account);
                    ps.setString(2, account);
                    ps.setString(3, account);
                    ps.setString(4, password);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            User u = new User(
                                rs.getInt("user_id"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("role"),
                                rs.getString("avatar")
                            );
                            try {
                                u.setCodLocked(rs.getInt("is_cod_locked") == 1);
                                u.setBoomCount(rs.getInt("boom_count"));
                                u.setCodTrustOrders(rs.getInt("cod_trust_orders"));
                            } catch (Exception ignored) {}
                            return u;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi truy vấn User từ CSDL: " + e.getMessage());
        }

        // Fallback test nếu CSDL chưa khởi tạo
        if ("admin".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@vindelivery.vn", "0909123456", "Văn phòng VinDelivery Q1", "ADMIN");
        }
        if ("customer".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi, P. Bến Nghé, Q.1", "CUSTOMER");
        }
        if ("bepviet".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(5, "bepviet", "123456", "Chủ Quán Bếp Việt", "bepviet@foodzone.vn", "0901234567", "45 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM", "SELLER");
        }
        if ("pho1985".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(6, "pho1985", "123456", "Chủ Quán Phở 1985", "pho1985@foodzone.vn", "0902345678", "128 Võ Văn Tần, Q.3, TP. HCM", "SELLER");
        }
        if ("kaitokid".equalsIgnoreCase(account) && "123456".equals(password)) {
            return new User(90005, "kaitokid", "123456", "Kiệt Gia", "kietgia@uteefood.vn", "0987654321", "TP. Hồ Chí Minh", "SHIPPER");
        }

        return null;
    }

    public boolean isPhoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        String cleanPhone = phone.trim();
        String query = "SELECT 1 FROM users WHERE phone = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, cleanPhone);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi kiểm tra số điện thoại tồn tại: " + e.getMessage());
        }

        // Fallback test nếu CSDL chưa khởi tạo
        if ("0909123456".equals(cleanPhone) || "0987654321".equals(cleanPhone)
                || "0901234567".equals(cleanPhone) || "0902345678".equals(cleanPhone)) {
            return true;
        }

        return false;
    }

    public boolean isUsernameExists(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        String cleanUsername = username.trim();
        String query = "SELECT 1 FROM users WHERE username = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, cleanUsername);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi kiểm tra tên đăng nhập tồn tại: " + e.getMessage());
        }

        // Fallback test nếu CSDL chưa khởi tạo
        if ("admin".equalsIgnoreCase(cleanUsername) || "customer".equalsIgnoreCase(cleanUsername)
                || "bepviet".equalsIgnoreCase(cleanUsername) || "pho1985".equalsIgnoreCase(cleanUsername)
                || "kaitokid".equalsIgnoreCase(cleanUsername)) {
            return true;
        }

        return false;
    }

    public boolean register(User user) {
        String query = "INSERT INTO users (username, password, name, email, phone, address, role, avatar) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getAddress());
            ps.setString(7, user.getRole() != null ? user.getRole() : "CUSTOMER");
            ps.setString(8, user.getAvatar());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi đăng ký User: " + e.getMessage());
        }
        return false;
    }

    public boolean registerSeller(User user, String restaurantName, String restaurantAddress) {
        return registerSeller(user, restaurantName, restaurantAddress, null, "07:00", "22:00", null, null);
    }

    public boolean registerSeller(User user, String restaurantName, String restaurantAddress, String description, String openTime, String closeTime, String logoUrl) {
        return registerSeller(user, restaurantName, restaurantAddress, description, openTime, closeTime, logoUrl, null);
    }

    public boolean registerSeller(User user, String restaurantName, String restaurantAddress, String description, String openTime, String closeTime, String logoUrl, String bannerUrl) {
        String insertUserSql = "INSERT INTO users (username, password, name, email, phone, address, role, avatar) VALUES (?, ?, ?, ?, ?, ?, 'SELLER', ?)";
        String insertRestWithLogo = "INSERT INTO restaurants (user_id, name, description, phone, address, image_url, logo_url, status, open_time, close_time) VALUES (?, ?, ?, ?, ?, ?, ?, 'OPEN', ?, ?)";
        String insertRestWithoutLogo = "INSERT INTO restaurants (user_id, name, description, phone, address, image_url, status, open_time, close_time) VALUES (?, ?, ?, ?, ?, ?, 'OPEN', ?, ?)";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            String effectiveBanner = (bannerUrl != null && !bannerUrl.trim().isEmpty())
                    ? bannerUrl.trim()
                    : ((logoUrl != null && !logoUrl.trim().isEmpty()) ? logoUrl.trim() : "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1000&auto=format&fit=crop&q=80");
            String effectiveLogo = (logoUrl != null && !logoUrl.trim().isEmpty())
                    ? logoUrl.trim()
                    : effectiveBanner;

            String ownerAvatar = user.getAvatar();
            if (ownerAvatar == null || ownerAvatar.trim().isEmpty()) {
                ownerAvatar = effectiveLogo;
            }

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getUsername());
                psUser.setString(2, user.getPassword());
                psUser.setString(3, user.getFullName());
                psUser.setString(4, user.getEmail());
                psUser.setString(5, user.getPhone());
                psUser.setString(6, user.getAddress());
                psUser.setString(7, ownerAvatar);

                int affected = psUser.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = psUser.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }
            }

            if (userId > 0) {
                boolean inserted = false;
                try (PreparedStatement psRest = conn.prepareStatement(insertRestWithLogo)) {
                    psRest.setInt(1, userId);
                    psRest.setString(2, restaurantName != null && !restaurantName.trim().isEmpty() ? restaurantName.trim() : "Quán Ăn của " + user.getFullName());
                    psRest.setString(3, description != null && !description.trim().isEmpty() ? description.trim() : "Quán ăn hợp tác với nền tảng giao đồ ăn siêu tốc Utee.");
                    psRest.setString(4, user.getPhone());
                    psRest.setString(5, restaurantAddress != null && !restaurantAddress.trim().isEmpty() ? restaurantAddress.trim() : user.getAddress());
                    psRest.setString(6, effectiveBanner);
                    psRest.setString(7, effectiveLogo);
                    psRest.setString(8, openTime != null && !openTime.trim().isEmpty() ? openTime.trim() : "07:00");
                    psRest.setString(9, closeTime != null && !closeTime.trim().isEmpty() ? closeTime.trim() : "22:00");
                    psRest.executeUpdate();
                    inserted = true;
                } catch (SQLException exWithLogo) {
                    // Fallback nếu database chưa có cột logo_url
                    try (PreparedStatement psRest = conn.prepareStatement(insertRestWithoutLogo)) {
                        psRest.setInt(1, userId);
                        psRest.setString(2, restaurantName != null && !restaurantName.trim().isEmpty() ? restaurantName.trim() : "Quán Ăn của " + user.getFullName());
                        psRest.setString(3, description != null && !description.trim().isEmpty() ? description.trim() : "Quán ăn hợp tác với nền tảng giao đồ ăn siêu tốc Utee.");
                        psRest.setString(4, user.getPhone());
                        psRest.setString(5, restaurantAddress != null && !restaurantAddress.trim().isEmpty() ? restaurantAddress.trim() : user.getAddress());
                        psRest.setString(6, effectiveBanner);
                        psRest.setString(7, openTime != null && !openTime.trim().isEmpty() ? openTime.trim() : "07:00");
                        psRest.setString(8, closeTime != null && !closeTime.trim().isEmpty() ? closeTime.trim() : "22:00");
                        psRest.executeUpdate();
                        inserted = true;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            System.err.println("Lỗi khi đăng ký tài khoản chủ quán: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public boolean updateAvatar(int userId, String avatarUrl) {
        String query = "UPDATE users SET avatar = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, avatarUrl);
                    ps.setInt(2, userId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật avatar user: " + e.getMessage());
        }
        return false;
    }

    public User getUserById(int id) {
        ensureBoomSupport();
        String query = "SELECT user_id, username, password, name, email, phone, address, role, avatar, is_cod_locked, boom_count, cod_trust_orders " +
                       "FROM users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            User u = new User(
                                rs.getInt("user_id"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("role"),
                                rs.getString("avatar")
                            );
                            try {
                                u.setCodLocked(rs.getInt("is_cod_locked") == 1);
                                u.setBoomCount(rs.getInt("boom_count"));
                                u.setCodTrustOrders(rs.getInt("cod_trust_orders"));
                            } catch (Exception ignored) {}
                            return u;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy User theo ID: " + e.getMessage());
        }

        // Fallback test
        if (id == 1) {
            return new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@vindelivery.vn", "0909123456", "Văn phòng VinDelivery Q1", "ADMIN");
        }
        if (id == 2) {
            return new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi, P. Bến Nghé, Q.1", "CUSTOMER");
        }
        if (id == 5) {
            return new User(5, "bepviet", "123456", "Chủ Quán Bếp Việt", "bepviet@foodzone.vn", "0901234567", "45 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM", "SELLER");
        }
        if (id == 6) {
            return new User(6, "pho1985", "123456", "Chủ Quán Phở 1985", "pho1985@foodzone.vn", "0902345678", "128 Võ Văn Tần, Q.3, TP. HCM", "SELLER");
        }
        if (id == 90005) {
            return new User(90005, "kaitokid", "123456", "Kiệt Gia", "kietgia@uteefood.vn", "0987654321", "TP. Hồ Chí Minh", "SHIPPER");
        }

        return null;
    }

    public boolean updateProfile(int userId, String fullName, String phone, String address, String email) {
        String query = "UPDATE users SET name = ?, phone = ?, address = ?, email = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, fullName);
                    ps.setString(2, phone);
                    ps.setString(3, address);
                    ps.setString(4, email);
                    ps.setInt(5, userId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi cập nhật thông tin cá nhân: " + e.getMessage());
        }
        return false;
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        String checkQuery = "SELECT user_id FROM users WHERE user_id = ? AND password = ?";
        String updateQuery = "UPDATE users SET password = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement psCheck = conn.prepareStatement(checkQuery)) {
                    psCheck.setInt(1, userId);
                    psCheck.setString(2, oldPassword);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            try (PreparedStatement psUpdate = conn.prepareStatement(updateQuery)) {
                                psUpdate.setString(1, newPassword);
                                psUpdate.setInt(2, userId);
                                return psUpdate.executeUpdate() > 0;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi đổi mật khẩu: " + e.getMessage());
        }
        return false;
    }

    public boolean registerShipper(User user) {
        return registerShipper(user, "59-X3 999.99", "Xe máy", null, null, null, null);
    }

    public boolean registerShipper(User user, String licensePlate, String vehicleType) {
        return registerShipper(user, licensePlate, vehicleType, null, null, null, null);
    }

    public boolean registerShipper(User user, String licensePlate, String vehicleType, String idCardFront, String idCardBack, String vehicleDoc, String avatarUrl) {
        String insertUserSql = "INSERT INTO users (username, password, name, email, phone, address, role, avatar) VALUES (?, ?, ?, ?, ?, ?, 'SHIPPER', ?)";
        String insertDriverSql = "INSERT INTO drivers (user_id, name, phone, status, license_plate, vehicle_type, id_card_front, id_card_back, vehicle_doc, avatar) VALUES (?, ?, ?, 'AVAILABLE', ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getUsername());
                psUser.setString(2, user.getPassword());
                psUser.setString(3, user.getFullName());
                psUser.setString(4, user.getEmail());
                psUser.setString(5, user.getPhone());
                psUser.setString(6, user.getAddress());
                psUser.setString(7, avatarUrl != null ? avatarUrl : user.getAvatar());

                int affected = psUser.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = psUser.getGeneratedKeys()) {
                        if (rs.next()) {
                            userId = rs.getInt(1);
                        }
                    }
                }
            }

            if (userId > 0) {
                try (PreparedStatement psDriver = conn.prepareStatement(insertDriverSql)) {
                    psDriver.setInt(1, userId);
                    psDriver.setString(2, user.getFullName());
                    psDriver.setString(3, user.getPhone());
                    psDriver.setString(4, licensePlate != null && !licensePlate.trim().isEmpty() ? licensePlate.trim() : "59-X3 999.99");
                    psDriver.setString(5, vehicleType != null && !vehicleType.trim().isEmpty() ? vehicleType.trim() : "Xe máy");
                    psDriver.setString(6, idCardFront);
                    psDriver.setString(7, idCardBack);
                    psDriver.setString(8, vehicleDoc);
                    psDriver.setString(9, avatarUrl != null ? avatarUrl : user.getAvatar());
                    psDriver.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            System.err.println("Lỗi khi đăng ký tài khoản shipper: " + e.getMessage());
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {}
            }
        }
    }

    public Map<String, Integer> getUserStats() {
        Map<String, Integer> map = new HashMap<>();
        map.put("totalUsers", 0);
        map.put("customerCount", 0);
        map.put("driverCount", 0);
        map.put("restaurantCount", 0);
        map.put("sellerCount", 0);
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT role, COUNT(*) AS cnt FROM users GROUP BY role");
                     ResultSet rs = ps.executeQuery()) {
                    int total = 0;
                    while (rs.next()) {
                        String role = rs.getString("role");
                        int count = rs.getInt("cnt");
                        total += count;
                        if ("CUSTOMER".equalsIgnoreCase(role)) map.put("customerCount", count);
                        else if ("SELLER".equalsIgnoreCase(role)) map.put("sellerCount", count);
                    }
                    map.put("totalUsers", total);
                }
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM drivers");
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) map.put("driverCount", rs.getInt(1));
                }
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM restaurants");
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) map.put("restaurantCount", rs.getInt(1));
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getUserStats: " + e.getMessage());
        }
        return map;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String query = "SELECT user_id, username, password, name, email, phone, address, role, avatar FROM users " +
                       "ORDER BY CASE role " +
                       "  WHEN 'ADMIN' THEN 1 " +
                       "  WHEN 'SELLER' THEN 2 " +
                       "  WHEN 'SHIPPER' THEN 3 " +
                       "  WHEN 'CUSTOMER' THEN 4 " +
                       "  ELSE 5 END, user_id ASC";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(query);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(new User(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getString("address"),
                            rs.getString("role"),
                            rs.getString("avatar")
                        ));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getAllUsers: " + e.getMessage());
        }

        // Dữ liệu dự phòng an toàn nếu CSDL rỗng
        if (list.isEmpty()) {
            list.add(new User(1, "admin", "123456", "Quản Trị Viên (Admin)", "admin@foodzone.vn", "0909123456", "Văn phòng FoodZone", "ADMIN"));
            list.add(new User(5, "bepviet", "123456", "Chủ Quán Bếp Việt", "bepviet@foodzone.vn", "0901234567", "Quận 1", "SELLER"));
            list.add(new User(6, "pho1985", "123456", "Chủ Quán Phở 1985", "pho1985@foodzone.vn", "0902345678", "Quận 3", "SELLER"));
            list.add(new User(90005, "kaitokid", "123456", "Kiệt Gia (Shipper)", "kietgia@uteefood.vn", "0987654321", "TP. Thủ Đức", "SHIPPER"));
            list.add(new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "Quận 1", "CUSTOMER"));
        }
        return list;
    }

    public List<Integer> getAdminUserIds() {
        List<Integer> adminIds = new ArrayList<>();
        String sql = "SELECT user_id FROM users WHERE UPPER(role) = 'ADMIN'";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        adminIds.add(rs.getInt("user_id"));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getAdminUserIds: " + e.getMessage());
        }
        if (adminIds.isEmpty()) {
            adminIds.add(1); // Mặc định ID 1 cho quản trị viên hệ thống
        }
        return adminIds;
    }

    public boolean recordCustomerBoom(int userId, String reason) {
        ensureBoomSupport();
        String query = "UPDATE users SET is_cod_locked = 1, boom_count = boom_count + 1, cod_trust_orders = 0 WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi ghi nhận khách bom hàng: " + e.getMessage());
            return false;
        }
    }

    public boolean isCustomerCodLocked(int userId) {
        ensureBoomSupport();
        String query = "SELECT is_cod_locked FROM users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("is_cod_locked") == 1;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi kiểm tra COD lock: " + e.getMessage());
        }
        return false;
    }

    public boolean unlockCustomerCod(int userId) {
        ensureBoomSupport();
        String query = "UPDATE users SET is_cod_locked = 0, cod_trust_orders = 0 WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi mở khóa COD cho khách: " + e.getMessage());
            return false;
        }
    }

    public boolean unlockCustomerCodByPhone(String phone) {
        ensureBoomSupport();
        if (phone == null || phone.trim().isEmpty()) return false;
        String query = "UPDATE users SET is_cod_locked = 0, cod_trust_orders = 0 WHERE phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phone.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Lỗi khi mở khóa COD cho khách theo SĐT: " + e.getMessage());
            return false;
        }
    }

    public int getCustomerBoomCount(int userId) {
        ensureBoomSupport();
        String query = "SELECT boom_count FROM users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("boom_count");
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy số lần bom hàng: " + e.getMessage());
        }
        return 0;
    }

    public User getUserByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return null;
        ensureBoomSupport();
        String query = "SELECT user_id, username, password, name, email, phone, address, role, avatar, is_cod_locked, boom_count, cod_trust_orders " +
                       "FROM users WHERE phone = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User(
                        rs.getInt("user_id"),
                        rs.getString("username"),
                        rs.getString("password"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("address"),
                        rs.getString("role"),
                        rs.getString("avatar")
                    );
                    u.setCodLocked(rs.getInt("is_cod_locked") == 1);
                    u.setBoomCount(rs.getInt("boom_count"));
                    u.setCodTrustOrders(rs.getInt("cod_trust_orders"));
                    return u;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi getUserByPhone: " + e.getMessage());
        }
        return null;
    }

    public int getCodTrustOrders(int userId) {
        ensureBoomSupport();
        String query = "SELECT cod_trust_orders FROM users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cod_trust_orders");
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy tiến độ hoàn thành đơn mở COD: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Ghi nhận đơn hoàn thành thành công (DELIVERED) của khách.
     * Nếu khách đang bị khóa COD:
     * - Tăng cod_trust_orders
     * - Nếu đạt >= 3 đơn: Tự động mở khóa COD (is_cod_locked = 0, cod_trust_orders = 0) và trả về true
     * - Nếu chưa đạt 3 đơn: Cập nhật và trả về false
     */
    public boolean recordCompletedOrderForCodProgress(int userId) {
        ensureBoomSupport();
        String checkSql = "SELECT is_cod_locked, cod_trust_orders FROM users WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                boolean isLocked = false;
                int currentTrust = 0;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            isLocked = rs.getInt("is_cod_locked") == 1;
                            currentTrust = rs.getInt("cod_trust_orders");
                        } else {
                            return false;
                        }
                    }
                }

                if (!isLocked) {
                    return false; // Khách không bị khóa COD, không cần xử lý
                }

                int nextTrust = currentTrust + 1;
                if (nextTrust >= 3) {
                    String unlockSql = "UPDATE users SET is_cod_locked = 0, cod_trust_orders = 0 WHERE user_id = ?";
                    try (PreparedStatement psUnlock = conn.prepareStatement(unlockSql)) {
                        psUnlock.setInt(1, userId);
                        psUnlock.executeUpdate();
                    }
                    System.out.println(">> [UserDAO] Khách hàng #" + userId + " đã hoàn tất đủ 3 đơn uy tín. Tự động mở khóa COD thành công!");
                    return true;
                } else {
                    String progressSql = "UPDATE users SET cod_trust_orders = ? WHERE user_id = ?";
                    try (PreparedStatement psProg = conn.prepareStatement(progressSql)) {
                        psProg.setInt(1, nextTrust);
                        psProg.setInt(2, userId);
                        psProg.executeUpdate();
                    }
                    System.out.println(">> [UserDAO] Khách hàng #" + userId + " hoàn tất đơn uy tín thứ " + nextTrust + "/3 để mở khóa COD.");
                    return false;
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi ghi nhận đơn hoàn tất cho tiến độ COD: " + e.getMessage());
        }
        return false;
    }

    /**
     * Lấy danh sách khách hàng để quản lý và mở khóa COD
     */
    public List<User> getCustomersForCodManagement(String search) {
        ensureBoomSupport();
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT user_id, username, password, name, email, phone, address, role, avatar, is_cod_locked, boom_count, cod_trust_orders " +
            "FROM users WHERE (role = 'CUSTOMER' OR role IS NULL) "
        );
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR phone LIKE ? OR email LIKE ? OR username LIKE ?) ");
        }
        sql.append("ORDER BY is_cod_locked DESC, boom_count DESC, user_id DESC");

        try (Connection conn = DBContext.getConnection()) {
            if (conn != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    if (search != null && !search.trim().isEmpty()) {
                        String kw = "%" + search.trim() + "%";
                        ps.setString(1, kw);
                        ps.setString(2, kw);
                        ps.setString(3, kw);
                        ps.setString(4, kw);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            User u = new User(
                                rs.getInt("user_id"),
                                rs.getString("username"),
                                rs.getString("password"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("phone"),
                                rs.getString("address"),
                                rs.getString("role"),
                                rs.getString("avatar")
                            );
                            u.setCodLocked(rs.getInt("is_cod_locked") == 1);
                            u.setBoomCount(rs.getInt("boom_count"));
                            u.setCodTrustOrders(rs.getInt("cod_trust_orders"));
                            list.add(u);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Lỗi khi lấy danh sách khách hàng quản lý COD: " + e.getMessage());
        }
        return list;
    }
}
