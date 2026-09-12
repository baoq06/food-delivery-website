package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import org.junit.Test;
import java.sql.Connection;
import java.sql.Statement;

public class MigrateRegistrationFlowTest {

    @Test
    public void runMigration() {
        System.out.println(">> Bắt đầu thực thi migration cho Registration Flow...");
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {

            // 1. Thêm avatar vào users
            try {
                stmt.executeUpdate("ALTER TABLE `users` ADD COLUMN `avatar` VARCHAR(500) DEFAULT NULL");
                System.out.println(">> [OK] Đã thêm cột avatar vào bảng users");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột avatar trong users: " + e.getMessage());
            }

            // 2. Thêm id_card_front vào drivers
            try {
                stmt.executeUpdate("ALTER TABLE `drivers` ADD COLUMN `id_card_front` VARCHAR(500) DEFAULT NULL");
                System.out.println(">> [OK] Đã thêm cột id_card_front vào bảng drivers");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột id_card_front trong drivers: " + e.getMessage());
            }

            // 3. Thêm id_card_back vào drivers
            try {
                stmt.executeUpdate("ALTER TABLE `drivers` ADD COLUMN `id_card_back` VARCHAR(500) DEFAULT NULL");
                System.out.println(">> [OK] Đã thêm cột id_card_back vào bảng drivers");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột id_card_back trong drivers: " + e.getMessage());
            }

            // 4. Thêm vehicle_doc vào drivers
            try {
                stmt.executeUpdate("ALTER TABLE `drivers` ADD COLUMN `vehicle_doc` VARCHAR(500) DEFAULT NULL");
                System.out.println(">> [OK] Đã thêm cột vehicle_doc vào bảng drivers");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột vehicle_doc trong drivers: " + e.getMessage());
            }

            // 5. Thêm avatar vào drivers
            try {
                stmt.executeUpdate("ALTER TABLE `drivers` ADD COLUMN `avatar` VARCHAR(500) DEFAULT NULL");
                System.out.println(">> [OK] Đã thêm cột avatar vào bảng drivers");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột avatar trong drivers: " + e.getMessage());
            }

            // 6. Thêm open_time vào restaurants
            try {
                stmt.executeUpdate("ALTER TABLE `restaurants` ADD COLUMN `open_time` VARCHAR(10) DEFAULT '07:00'");
                System.out.println(">> [OK] Đã thêm cột open_time vào bảng restaurants");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột open_time trong restaurants: " + e.getMessage());
            }

            // 7. Thêm close_time vào restaurants
            try {
                stmt.executeUpdate("ALTER TABLE `restaurants` ADD COLUMN `close_time` VARCHAR(10) DEFAULT '22:00'");
                System.out.println(">> [OK] Đã thêm cột close_time vào bảng restaurants");
            } catch (Exception e) {
                System.out.println(">> [INFO] Cột close_time trong restaurants: " + e.getMessage());
            }

            System.out.println(">> Hoàn tất migration Registration Flow thành công!");
        } catch (Exception e) {
            System.err.println(">> Lỗi kết nối CSDL khi migration: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
