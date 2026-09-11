package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import org.junit.Test;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import static org.junit.Assert.assertTrue;

public class MigrateNotificationsAndOrderColsTest {

    @Test
    public void migrateDatabase() throws Exception {
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {

            // 1. Kiểm tra và thêm cột shipper_accepted vào orders
            try {
                stmt.executeUpdate("ALTER TABLE orders ADD COLUMN shipper_accepted TINYINT(1) DEFAULT 0");
                System.out.println(">> Đã thêm cột shipper_accepted vào bảng orders");
            } catch (Exception e) {
                System.out.println(">> Cột shipper_accepted có thể đã tồn tại: " + e.getMessage());
            }

            // 2. Kiểm tra và thêm cột shipper_delivered vào orders
            try {
                stmt.executeUpdate("ALTER TABLE orders ADD COLUMN shipper_delivered TINYINT(1) DEFAULT 0");
                System.out.println(">> Đã thêm cột shipper_delivered vào bảng orders");
            } catch (Exception e) {
                System.out.println(">> Cột shipper_delivered có thể đã tồn tại: " + e.getMessage());
            }

            // 3. Kiểm tra và thêm cột merchant_completed vào orders
            try {
                stmt.executeUpdate("ALTER TABLE orders ADD COLUMN merchant_completed TINYINT(1) DEFAULT 0");
                System.out.println(">> Đã thêm cột merchant_completed vào bảng orders");
            } catch (Exception e) {
                System.out.println(">> Cột merchant_completed có thể đã tồn tại: " + e.getMessage());
            }

            // 4. Đồng bộ dữ liệu cũ: Với các đơn đã DELIVERED và customer_confirmed = 1 & merchant_confirmed = 1, set merchant_completed = 1, shipper_delivered = 1, shipper_accepted = 1
            stmt.executeUpdate("UPDATE orders SET shipper_accepted = 1, shipper_delivered = 1, merchant_completed = 1 WHERE customer_confirmed = 1 AND merchant_confirmed = 1");

            // 5. Tạo bảng notifications
            String createNotifSql = "CREATE TABLE IF NOT EXISTS `notifications` (" +
                    " `notification_id` INT AUTO_INCREMENT PRIMARY KEY," +
                    " `user_id` INT NOT NULL," +
                    " `order_id` INT DEFAULT NULL," +
                    " `title` VARCHAR(255) NOT NULL," +
                    " `message` TEXT NOT NULL," +
                    " `type` VARCHAR(50) DEFAULT 'ORDER'," +
                    " `link` VARCHAR(255) DEFAULT NULL," +
                    " `is_read` TINYINT(1) DEFAULT 0," +
                    " `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    " CONSTRAINT `fk_notif_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
            stmt.executeUpdate(createNotifSql);
            System.out.println(">> Đã tạo bảng notifications thành công!");

            // Kiểm tra bảng notifications
            try (ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'notifications'")) {
                assertTrue("Bảng notifications phải tồn tại", rs.next());
            }

            // Kiểm tra các cột trong orders
            try (ResultSet rs = stmt.executeQuery("DESCRIBE orders")) {
                boolean hasAccepted = false, hasDelivered = false, hasCompleted = false;
                while (rs.next()) {
                    String col = rs.getString("Field");
                    if ("shipper_accepted".equalsIgnoreCase(col)) hasAccepted = true;
                    if ("shipper_delivered".equalsIgnoreCase(col)) hasDelivered = true;
                    if ("merchant_completed".equalsIgnoreCase(col)) hasCompleted = true;
                }
                assertTrue("Các cột mới phải tồn tại trong orders", hasAccepted && hasDelivered && hasCompleted);
            }

            System.out.println(">> Migration Cloud TiDB hoàn tất mỹ mãn!");
        }
    }
}
