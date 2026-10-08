package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.Voucher;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class VoucherDAO extends DBContext {

    public VoucherDAO() {
        ensureVoucherTable();
    }

    public void ensureVoucherTable() {
        String sql = "CREATE TABLE IF NOT EXISTS `vouchers` (" +
                "`id` INT AUTO_INCREMENT PRIMARY KEY, " +
                "`restaurant_id` INT DEFAULT NULL, " +
                "`code` VARCHAR(50) NOT NULL UNIQUE, " +
                "`title` VARCHAR(255) NOT NULL, " +
                "`description` TEXT DEFAULT NULL, " +
                "`discount_type` VARCHAR(20) NOT NULL DEFAULT 'FIXED', " +
                "`discount_value` DOUBLE NOT NULL DEFAULT 0, " +
                "`min_order_amount` DOUBLE NOT NULL DEFAULT 0, " +
                "`max_discount` DOUBLE NOT NULL DEFAULT 0, " +
                "`is_free_ship` TINYINT(1) NOT NULL DEFAULT 0, " +
                "`usage_limit` INT NOT NULL DEFAULT 0, " +
                "`used_count` INT NOT NULL DEFAULT 0, " +
                "`per_user_limit` INT NOT NULL DEFAULT 1, " +
                "`start_date` VARCHAR(20) DEFAULT NULL, " +
                "`end_date` VARCHAR(20) DEFAULT NULL, " +
                "`is_active` TINYINT(1) NOT NULL DEFAULT 1, " +
                "`badge` VARCHAR(50) DEFAULT '🔥 ƯU ĐÃI', " +
                "`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "`updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                "KEY `idx_v_rest` (`restaurant_id`), " +
                "KEY `idx_v_code` (`code`)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try (Connection conn = getConnection(); Statement st = conn.createStatement()) {
            st.execute(sql);
            seedInitialRestaurantVouchers(conn);
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] ensureVoucherTable warning: " + e.getMessage());
        }
    }

    private void seedInitialRestaurantVouchers(Connection conn) {
        String countSql = "SELECT COUNT(*) FROM `vouchers`";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(countSql)) {
            if (rs.next() && rs.getInt(1) == 0) {
                // Seed mẫu một số voucher cho Quán 1 và Quán 2
                String insertSql = "INSERT INTO `vouchers` (" +
                        "`restaurant_id`, `code`, `title`, `description`, `discount_type`, `discount_value`, " +
                        "`min_order_amount`, `max_discount`, `is_free_ship`, `usage_limit`, `used_count`, " +
                        "`per_user_limit`, `start_date`, `end_date`, `is_active`, `badge`" +
                        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    // Voucher 1 cho Bếp Việt (ID 1): Giảm 20K đơn từ 80K, giới hạn 50 lượt
                    ps.setInt(1, 1);
                    ps.setString(2, "BEPVIET20K");
                    ps.setString(3, "Giảm 20.000 đ cho đơn từ 80K");
                    ps.setString(4, "Khuyến mãi chào đón thực khách mới ghé Bếp Việt Quán");
                    ps.setString(5, "FIXED");
                    ps.setDouble(6, 20000.0);
                    ps.setDouble(7, 80000.0);
                    ps.setDouble(8, 0.0);
                    ps.setBoolean(9, false);
                    ps.setInt(10, 50);
                    ps.setInt(11, 4);
                    ps.setInt(12, 1);
                    ps.setString(13, "2026-01-01");
                    ps.setString(14, "2026-12-31");
                    ps.setBoolean(15, true);
                    ps.setString(16, "🔥 HOT DEAL");
                    ps.addBatch();

                    // Voucher 2 cho Bếp Việt (ID 1): Giảm 15% tối đa 35K đơn từ 120K
                    ps.setInt(1, 1);
                    ps.setString(2, "BEPVIET15");
                    ps.setString(3, "Giảm 15% tối đa 35.000 đ");
                    ps.setString(4, "Ưu đãi tiệc ngon đặt theo nhóm hoặc combo cơm tấm");
                    ps.setString(5, "PERCENT");
                    ps.setDouble(6, 15.0);
                    ps.setDouble(7, 120000.0);
                    ps.setDouble(8, 35000.0);
                    ps.setBoolean(9, false);
                    ps.setInt(10, 100);
                    ps.setInt(11, 12);
                    ps.setInt(12, 2);
                    ps.setString(13, "2026-01-01");
                    ps.setString(14, "2026-12-31");
                    ps.setBoolean(15, true);
                    ps.setString(16, "⭐ GIẢM 15%");
                    ps.addBatch();

                    // Voucher 3 cho Phở 1985 (ID 2): Giảm 25K đơn từ 90K
                    ps.setInt(1, 2);
                    ps.setString(2, "PHO1985_25K");
                    ps.setString(3, "Giảm 25.000 đ cho đơn từ 90K");
                    ps.setString(4, "Thưởng thức phở bò tái nạm gia truyền đậm vị thơm ngon");
                    ps.setString(5, "FIXED");
                    ps.setDouble(6, 25000.0);
                    ps.setDouble(7, 90000.0);
                    ps.setDouble(8, 0.0);
                    ps.setBoolean(9, false);
                    ps.setInt(10, 60);
                    ps.setInt(11, 8);
                    ps.setInt(12, 1);
                    ps.setString(13, "2026-01-01");
                    ps.setString(14, "2026-12-31");
                    ps.setBoolean(15, true);
                    ps.setString(16, "🍜 GIA TRUYỀN");
                    ps.addBatch();

                    ps.executeBatch();
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] seedInitialRestaurantVouchers error: " + e.getMessage());
        }
    }

    public List<Voucher> getVouchersByRestaurant(int restaurantId) {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT v.*, r.name as rest_name FROM `vouchers` v " +
                "LEFT JOIN `restaurants` r ON v.restaurant_id = r.restaurant_id " +
                "WHERE v.restaurant_id = ? " +
                "ORDER BY v.is_active DESC, v.id DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToVoucher(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] getVouchersByRestaurant error: " + e.getMessage());
        }
        return list;
    }

    public List<Voucher> getActiveVouchersByRestaurant(int restaurantId) {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT v.*, r.name as rest_name FROM `vouchers` v " +
                "LEFT JOIN `restaurants` r ON v.restaurant_id = r.restaurant_id " +
                "WHERE v.restaurant_id = ? AND v.is_active = 1 " +
                "ORDER BY v.discount_value DESC, v.id ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Voucher v = mapResultSetToVoucher(rs);
                    // Lọc chỉ lấy voucher còn hiệu lực (chưa hết hạn và chưa vượt limit)
                    if (!v.isExpired()) {
                        list.add(v);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] getActiveVouchersByRestaurant error: " + e.getMessage());
        }
        return list;
    }

    public Voucher getVoucherById(int id) {
        String sql = "SELECT v.*, r.name as rest_name FROM `vouchers` v " +
                "LEFT JOIN `restaurants` r ON v.restaurant_id = r.restaurant_id " +
                "WHERE v.id = ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] getVoucherById error: " + e.getMessage());
        }
        return null;
    }

    public Voucher getVoucherByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        String cleanCode = code.trim().toUpperCase(Locale.ROOT);
        String sql = "SELECT v.*, r.name as rest_name FROM `vouchers` v " +
                "LEFT JOIN `restaurants` r ON v.restaurant_id = r.restaurant_id " +
                "WHERE UPPER(v.code) = ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cleanCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVoucher(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] getVoucherByCode error: " + e.getMessage());
        }
        return null;
    }

    public boolean isCodeExists(String code, Integer excludeId) {
        if (code == null || code.trim().isEmpty()) return false;
        String cleanCode = code.trim().toUpperCase(Locale.ROOT);
        String sql = "SELECT COUNT(*) FROM `vouchers` WHERE UPPER(code) = ?" + (excludeId != null && excludeId > 0 ? " AND id != ?" : "");
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cleanCode);
            if (excludeId != null && excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] isCodeExists error: " + e.getMessage());
        }
        return false;
    }

    public boolean insertVoucher(Voucher v) {
        if (v == null || v.getCode() == null) return false;
        String sql = "INSERT INTO `vouchers` (" +
                "`restaurant_id`, `code`, `title`, `description`, `discount_type`, `discount_value`, " +
                "`min_order_amount`, `max_discount`, `is_free_ship`, `usage_limit`, `used_count`, " +
                "`per_user_limit`, `start_date`, `end_date`, `is_active`, `badge`" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (v.getRestaurantId() != null && v.getRestaurantId() > 0) {
                ps.setInt(1, v.getRestaurantId());
            } else {
                ps.setNull(1, java.sql.Types.INTEGER);
            }
            ps.setString(2, v.getCode().trim().toUpperCase(Locale.ROOT));
            ps.setString(3, v.getTitle() != null ? v.getTitle().trim() : "");
            ps.setString(4, v.getDescription() != null ? v.getDescription().trim() : "");
            ps.setString(5, v.getDiscountType() != null ? v.getDiscountType().name() : "FIXED");
            ps.setDouble(6, v.getDiscountValue());
            ps.setDouble(7, v.getMinOrderAmount());
            ps.setDouble(8, v.getMaxDiscount());
            ps.setBoolean(9, v.isFreeShip());
            ps.setInt(10, Math.max(0, v.getUsageLimit()));
            ps.setInt(11, Math.max(0, v.getUsedCount()));
            ps.setInt(12, Math.max(1, v.getPerUserLimit()));
            ps.setString(13, v.getStartDate());
            ps.setString(14, v.getEndDate());
            ps.setBoolean(15, v.isActive());
            ps.setString(16, v.getBadge() != null ? v.getBadge().trim() : "🔥 ƯU ĐÃI");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] insertVoucher error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateVoucher(Voucher v) {
        if (v == null || v.getId() <= 0) return false;
        String sql = "UPDATE `vouchers` SET " +
                "`code` = ?, `title` = ?, `description` = ?, `discount_type` = ?, `discount_value` = ?, " +
                "`min_order_amount` = ?, `max_discount` = ?, `is_free_ship` = ?, `usage_limit` = ?, " +
                "`per_user_limit` = ?, `start_date` = ?, `end_date` = ?, `is_active` = ?, `badge` = ? " +
                "WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getCode().trim().toUpperCase(Locale.ROOT));
            ps.setString(2, v.getTitle() != null ? v.getTitle().trim() : "");
            ps.setString(3, v.getDescription() != null ? v.getDescription().trim() : "");
            ps.setString(4, v.getDiscountType() != null ? v.getDiscountType().name() : "FIXED");
            ps.setDouble(5, v.getDiscountValue());
            ps.setDouble(6, v.getMinOrderAmount());
            ps.setDouble(7, v.getMaxDiscount());
            ps.setBoolean(8, v.isFreeShip());
            ps.setInt(9, Math.max(0, v.getUsageLimit()));
            ps.setInt(10, Math.max(1, v.getPerUserLimit()));
            ps.setString(11, v.getStartDate());
            ps.setString(12, v.getEndDate());
            ps.setBoolean(13, v.isActive());
            ps.setString(14, v.getBadge() != null ? v.getBadge().trim() : "🔥 ƯU ĐÃI");
            ps.setInt(15, v.getId());
            ps.setInt(16, v.getRestaurantId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] updateVoucher error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteVoucher(int id, int restaurantId) {
        String sql = "DELETE FROM `vouchers` WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] deleteVoucher error: " + e.getMessage());
            return false;
        }
    }

    public boolean toggleVoucherStatus(int id, int restaurantId) {
        String sql = "UPDATE `vouchers` SET `is_active` = NOT `is_active` WHERE `id` = ? AND `restaurant_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, restaurantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] toggleVoucherStatus error: " + e.getMessage());
            return false;
        }
    }

    public boolean incrementUsedCount(String code) {
        if (code == null || code.trim().isEmpty()) return false;
        String cleanCode = code.trim().toUpperCase(Locale.ROOT);
        String sql = "UPDATE `vouchers` SET `used_count` = `used_count` + 1 WHERE UPPER(`code`) = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cleanCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[VoucherDAO] incrementUsedCount error: " + e.getMessage());
            return false;
        }
    }

    public int countVouchersByRestaurant(int restaurantId) {
        String sql = "SELECT COUNT(*) FROM `vouchers` WHERE `restaurant_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ignored) {}
        return 0;
    }

    public int countActiveVouchersByRestaurant(int restaurantId) {
        String sql = "SELECT COUNT(*) FROM `vouchers` WHERE `restaurant_id` = ? AND `is_active` = 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ignored) {}
        return 0;
    }

    public int getTotalUsedCountByRestaurant(int restaurantId) {
        String sql = "SELECT SUM(`used_count`) FROM `vouchers` WHERE `restaurant_id` = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ignored) {}
        return 0;
    }

    private Voucher mapResultSetToVoucher(ResultSet rs) throws SQLException {
        Voucher v = new Voucher();
        v.setId(rs.getInt("id"));

        int rId = rs.getInt("restaurant_id");
        if (!rs.wasNull() && rId > 0) {
            v.setRestaurantId(rId);
        } else {
            v.setRestaurantId(null);
        }

        try {
            v.setRestaurantName(rs.getString("rest_name"));
        } catch (SQLException ignored) {}

        v.setCode(rs.getString("code"));
        v.setTitle(rs.getString("title"));
        v.setDescription(rs.getString("description"));

        String typeStr = rs.getString("discount_type");
        try {
            v.setDiscountType(Voucher.DiscountType.valueOf(typeStr != null ? typeStr.toUpperCase(Locale.ROOT) : "FIXED"));
        } catch (Exception e) {
            v.setDiscountType(Voucher.DiscountType.FIXED);
        }

        v.setDiscountValue(rs.getDouble("discount_value"));
        v.setMinOrderAmount(rs.getDouble("min_order_amount"));
        v.setMaxDiscount(rs.getDouble("max_discount"));
        v.setFreeShip(rs.getBoolean("is_free_ship"));
        v.setUsageLimit(rs.getInt("usage_limit"));
        v.setUsedCount(rs.getInt("used_count"));
        v.setPerUserLimit(rs.getInt("per_user_limit"));
        v.setStartDate(rs.getString("start_date"));
        v.setEndDate(rs.getString("end_date"));
        v.setActive(rs.getBoolean("is_active"));
        v.setBadge(rs.getString("badge"));

        return v;
    }
}
