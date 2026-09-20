package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.UserVoucher;
import com.ute.fooddelivery.model.Voucher;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class UserVoucherDAO extends DBContext {

    public UserVoucherDAO() {
        ensureUserVoucherTable();
    }

    public void ensureUserVoucherTable() {
        String sql = "CREATE TABLE IF NOT EXISTS `user_vouchers` (" +
                "`id` INT AUTO_INCREMENT PRIMARY KEY, " +
                "`user_id` INT NOT NULL, " +
                "`voucher_code` VARCHAR(50) NOT NULL, " +
                "`title` VARCHAR(255) NOT NULL, " +
                "`description` VARCHAR(255) DEFAULT NULL, " +
                "`discount_type` VARCHAR(20) DEFAULT 'FIXED', " +
                "`discount_value` DOUBLE DEFAULT 0, " +
                "`min_order_amount` DOUBLE DEFAULT 0, " +
                "`max_discount` DOUBLE DEFAULT 0, " +
                "`is_free_ship` TINYINT(1) DEFAULT 0, " +
                "`badge` VARCHAR(50) DEFAULT 'ƯU ĐÃI', " +
                "`restaurant_id` INT DEFAULT NULL, " +
                "`restaurant_name` VARCHAR(255) DEFAULT NULL, " +
                "`quantity` INT DEFAULT 1, " +
                "`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "`last_awarded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "KEY `idx_uv_user` (`user_id`), " +
                "KEY `idx_uv_code` (`voucher_code`)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try (Connection conn = getConnection(); Statement st = conn.createStatement()) {
            st.execute(sql);
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] ensureUserVoucherTable warning: " + e.getMessage());
        }
    }

    public void grantWelcomeVouchers(int userId) {
        if (userId <= 0) return;

        // Kiểm tra xem user đã từng được cấp gói chào mừng hay chưa (kiểm tra mã UTEE30)
        String checkSql = "SELECT COUNT(*) FROM `user_vouchers` WHERE `user_id` = ? AND `voucher_code` = 'UTEE30'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return; // Đã nhận gói chào mừng trước đó
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] grantWelcomeVouchers check error: " + e.getMessage());
        }

        // Cấp gói chào mừng: UTEE30 (x1), UTEE20 (x2), FREESHIP (x3), WELCOME (x1), UTEE15 (x2)
        addOrIncrementVoucher(userId, "UTEE30", "Giảm 30.000 đ", "Ưu đãi độc quyền Utee cho mọi đơn món ngon",
                Voucher.DiscountType.FIXED, 30000.0, 0.0, 0.0, false, "🔥 HOT DEAL", null, null, 1);

        addOrIncrementVoucher(userId, "UTEE20", "Giảm 20.000 đ", "Áp dụng cho mọi đơn đặt món tại Utee",
                Voucher.DiscountType.FIXED, 20000.0, 0.0, 0.0, false, "⭐ ƯU ĐÃI THỰC ĐƠN", null, null, 2);

        addOrIncrementVoucher(userId, "FREESHIP", "Freeship 15.000 đ", "Giảm 15.000 đ phí giao hàng cho mọi đơn",
                Voucher.DiscountType.FIXED, 15000.0, 0.0, 0.0, true, "🛵 FREESHIP", null, null, 3);

        addOrIncrementVoucher(userId, "WELCOME", "Giảm 20% (tối đa 25K)", "Ưu đãi chào đón khách hàng mới",
                Voucher.DiscountType.PERCENT, 20.0, 0.0, 25000.0, false, "🎁 BẠN MỚI", null, null, 1);

        addOrIncrementVoucher(userId, "UTEE15", "Giảm 15.000 đ", "Giảm ngay 15K cho mọi đơn đặt món",
                Voucher.DiscountType.FIXED, 15000.0, 0.0, 0.0, false, "⚡ MỖI NGÀY", null, null, 2);
    }

    public UserVoucher grantRestaurantVoucherIfEligible(int userId, Restaurant restaurant) {
        if (userId <= 0 || restaurant == null || restaurant.getId() <= 0) {
            return null;
        }

        int restId = restaurant.getId();
        String code = "QUAN" + restId + "_20K";

        // Kiểm tra xem user đã nhận mã của quán này trong vòng 7 ngày qua chưa
        String checkSql = "SELECT `quantity`, `last_awarded_at` FROM `user_vouchers` WHERE `user_id` = ? AND `restaurant_id` = ? ORDER BY `last_awarded_at` DESC LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, restId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Timestamp lastAwarded = rs.getTimestamp("last_awarded_at");
                    int currentQty = rs.getInt("quantity");
                    if (lastAwarded != null) {
                        long diffDays = (System.currentTimeMillis() - lastAwarded.getTime()) / (1000 * 60 * 60 * 24);
                        if (diffDays < 7 && currentQty > 0) {
                            return null; // Đã nhận trong vòng 7 ngày và vẫn còn mã
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] grantRestaurantVoucherIfEligible check error: " + e.getMessage());
        }

        // Tặng mã giảm 20.000 đ riêng cho quán
        String title = "Giảm 20.000 đ tại " + restaurant.getName();
        String desc = "Ưu đãi tri ân dành riêng khi đặt món tại quán " + restaurant.getName();
        addOrIncrementVoucher(userId, code, title, desc, Voucher.DiscountType.FIXED, 20000.0, 0.0, 0.0,
                false, "🎁 QUÀ TẶNG QUÁN", restId, restaurant.getName(), 1);

        return getUserVoucher(userId, code);
    }

    public void addOrIncrementVoucher(int userId, String code, String title, String desc,
                                     Voucher.DiscountType type, double value, double minOrder,
                                     double maxDiscount, boolean isFreeShip, String badge,
                                     Integer restaurantId, String restaurantName, int qty) {
        if (userId <= 0 || code == null || code.trim().isEmpty() || qty <= 0) return;
        String cleanCode = code.trim().toUpperCase(Locale.ROOT);

        String findSql = "SELECT `id`, `quantity` FROM `user_vouchers` WHERE `user_id` = ? AND `voucher_code` = ?";
        try (Connection conn = getConnection()) {
            Integer existingId = null;
            int existingQty = 0;

            try (PreparedStatement psFind = conn.prepareStatement(findSql)) {
                psFind.setInt(1, userId);
                psFind.setString(2, cleanCode);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt("id");
                        existingQty = rs.getInt("quantity");
                    }
                }
            }

            if (existingId != null) {
                String updateSql = "UPDATE `user_vouchers` SET `quantity` = `quantity` + ?, `last_awarded_at` = NOW() WHERE `id` = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateSql)) {
                    psUp.setInt(1, qty);
                    psUp.setInt(2, existingId);
                    psUp.executeUpdate();
                }
            } else {
                String insertSql = "INSERT INTO `user_vouchers` (" +
                        "`user_id`, `voucher_code`, `title`, `description`, `discount_type`, " +
                        "`discount_value`, `min_order_amount`, `max_discount`, `is_free_ship`, " +
                        "`badge`, `restaurant_id`, `restaurant_name`, `quantity`, `last_awarded_at`" +
                        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    psIns.setInt(1, userId);
                    psIns.setString(2, cleanCode);
                    psIns.setString(3, title);
                    psIns.setString(4, desc);
                    psIns.setString(5, type != null ? type.name() : "FIXED");
                    psIns.setDouble(6, value);
                    psIns.setDouble(7, minOrder);
                    psIns.setDouble(8, maxDiscount);
                    psIns.setBoolean(9, isFreeShip);
                    psIns.setString(10, badge != null ? badge : "ƯU ĐÃI");
                    if (restaurantId != null && restaurantId > 0) {
                        psIns.setInt(11, restaurantId);
                    } else {
                        psIns.setNull(11, java.sql.Types.INTEGER);
                    }
                    psIns.setString(12, restaurantName);
                    psIns.setInt(13, qty);
                    psIns.executeUpdate();
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] addOrIncrementVoucher error: " + e.getMessage());
        }
    }

    public List<UserVoucher> getUserVouchers(int userId) {
        List<UserVoucher> list = new ArrayList<>();
        if (userId <= 0) return list;

        // Auto-seed welcome vouchers nếu user chưa có bất kỳ voucher nào
        ensureUserHasInitialVouchers(userId);

        String sql = "SELECT * FROM `user_vouchers` WHERE `user_id` = ? AND `quantity` > 0 ORDER BY `is_free_ship` DESC, `id` ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUserVoucher(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] getUserVouchers error: " + e.getMessage());
        }
        return list;
    }

    private void ensureUserHasInitialVouchers(int userId) {
        String countSql = "SELECT COUNT(*) FROM `user_vouchers` WHERE `user_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) {
                    grantWelcomeVouchers(userId);
                }
            }
        } catch (SQLException ignored) {}
    }

    public UserVoucher getUserVoucher(int userId, String code) {
        if (userId <= 0 || code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT * FROM `user_vouchers` WHERE `user_id` = ? AND UPPER(`voucher_code`) = UPPER(?) AND `quantity` > 0 LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUserVoucher(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] getUserVoucher error: " + e.getMessage());
        }
        return null;
    }

    public UserVoucher getUserVoucherRecord(int userId, String code) {
        if (userId <= 0 || code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT * FROM `user_vouchers` WHERE `user_id` = ? AND UPPER(`voucher_code`) = UPPER(?) LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUserVoucher(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] getUserVoucherRecord error: " + e.getMessage());
        }
        return null;
    }

    public boolean useVoucher(int userId, String code) {
        if (userId <= 0 || code == null || code.trim().isEmpty()) return false;
        String sql = "UPDATE `user_vouchers` SET `quantity` = `quantity` - 1 WHERE `user_id` = ? AND UPPER(`voucher_code`) = UPPER(?) AND `quantity` > 0";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, code.trim());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserVoucherDAO] useVoucher error: " + e.getMessage());
            return false;
        }
    }

    public boolean useVouchers(int userId, List<String> codes) {
        if (userId <= 0 || codes == null || codes.isEmpty()) return false;
        boolean allSuccess = true;
        for (String code : codes) {
            if (code != null && !code.trim().isEmpty()) {
                boolean ok = useVoucher(userId, code.trim());
                if (!ok) allSuccess = false;
            }
        }
        return allSuccess;
    }

    private UserVoucher mapResultSetToUserVoucher(ResultSet rs) throws SQLException {
        UserVoucher uv = new UserVoucher();
        uv.setId(rs.getInt("id"));
        uv.setUserId(rs.getInt("user_id"));
        uv.setVoucherCode(rs.getString("voucher_code"));
        uv.setTitle(rs.getString("title"));
        uv.setDescription(rs.getString("description"));

        String typeStr = rs.getString("discount_type");
        try {
            uv.setDiscountType(Voucher.DiscountType.valueOf(typeStr != null ? typeStr.toUpperCase(Locale.ROOT) : "FIXED"));
        } catch (Exception e) {
            uv.setDiscountType(Voucher.DiscountType.FIXED);
        }

        uv.setDiscountValue(rs.getDouble("discount_value"));
        uv.setMinOrderAmount(rs.getDouble("min_order_amount"));
        uv.setMaxDiscount(rs.getDouble("max_discount"));
        uv.setFreeShip(rs.getBoolean("is_free_ship"));
        uv.setBadge(rs.getString("badge"));

        int restId = rs.getInt("restaurant_id");
        if (!rs.wasNull() && restId > 0) {
            uv.setRestaurantId(restId);
        } else {
            uv.setRestaurantId(null);
        }

        uv.setRestaurantName(rs.getString("restaurant_name"));
        uv.setQuantity(rs.getInt("quantity"));
        uv.setCreatedAt(rs.getTimestamp("created_at"));
        uv.setLastAwardedAt(rs.getTimestamp("last_awarded_at"));
        return uv;
    }
}
