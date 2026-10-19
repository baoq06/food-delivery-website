-- ====================================================================
-- DATABASE SCHEMA CHO HỆ THỐNG GIAO ĐỒ ĂN (FOOD DELIVERY)
-- Tương thích hoàn toàn với MySQL 8.0+ / TiDB Cloud / MySQL Workbench
-- Lưu ý an toàn: Sử dụng CREATE TABLE IF NOT EXISTS để bảo vệ toàn vẹn dữ liệu hiện có.
-- Tuyệt đối không xóa bảng (DROP) để tránh làm mất mát dữ liệu đang vận hành.
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `food_delivery_db`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `food_delivery_db`;

-- 1. Bảng danh mục món ăn (categories)
CREATE TABLE IF NOT EXISTS `categories` (
    `category_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `image_icon` VARCHAR(255) DEFAULT '🍔',
    `description` VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Bảng người dùng (users)
CREATE TABLE IF NOT EXISTS `users` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) UNIQUE,
    `phone` VARCHAR(20),
    `address` VARCHAR(255),
    `role` VARCHAR(20) DEFAULT 'CUSTOMER', -- 'ADMIN', 'CUSTOMER', 'SELLER', 'SHIPPER'
    `avatar` VARCHAR(500) DEFAULT NULL,
    `is_cod_locked` TINYINT(1) DEFAULT 0,
    `boom_count` INT DEFAULT 0,
    `cod_trust_orders` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Bảng nhà hàng / quán ăn (restaurants)
-- Mối quan hệ: Mỗi nhà hàng do 1 chủ doanh nghiệp (user có role SELLER) quản lý
CREATE TABLE IF NOT EXISTS `restaurants` (
    `restaurant_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT,
    `phone` VARCHAR(20),
    `address` VARCHAR(255) DEFAULT 'TP. Hồ Chí Minh',
    `image_url` VARCHAR(500) DEFAULT NULL,
    `logo_url` VARCHAR(500) DEFAULT NULL,
    `open_time` VARCHAR(10) DEFAULT '07:00',
    `close_time` VARCHAR(10) DEFAULT '22:00',
    `status` VARCHAR(20) DEFAULT 'OPEN', -- 'OPEN', 'CLOSED', 'BANNED'
    `latitude` DOUBLE DEFAULT 10.8505,
    `longitude` DOUBLE DEFAULT 106.7719,
    `bank_code` VARCHAR(50) DEFAULT 'TCB',
    `bank_name` VARCHAR(100) DEFAULT 'Techcombank',
    `bank_account_no` VARCHAR(50) DEFAULT '1907 2878 4280 15',
    `bank_account_name` VARCHAR(150) DEFAULT 'LE HAI DANG',
    CONSTRAINT `fk_restaurants_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Bảng địa chỉ nhận hàng của người dùng (addresses)
CREATE TABLE IF NOT EXISTS `addresses` (
    `address_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `receiver_phone` VARCHAR(20),
    `ward` VARCHAR(100),
    `district` VARCHAR(100),
    `city` VARCHAR(100),
    `is_default` TINYINT(1) DEFAULT 0,
    CONSTRAINT `fk_addresses_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Bảng món ăn (foods)
-- Mối quan hệ: Nhiều món ăn thuộc về 1 nhà hàng (N-1), nhiều món ăn thuộc về 1 danh mục (N-1)
CREATE TABLE IF NOT EXISTS `foods` (
    `food_id` INT AUTO_INCREMENT PRIMARY KEY,
    `restaurant_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `price` DOUBLE NOT NULL,
    `description` TEXT,
    `image_url` VARCHAR(500),
    `is_available` TINYINT(1) DEFAULT 1,
    `is_combo` TINYINT(1) DEFAULT 0,
    `original_price` DOUBLE DEFAULT NULL,
    `combo_items` TEXT DEFAULT NULL,
    `options_json` TEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_foods_restaurants`
        FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_foods_categories`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Bảng tài xế giao hàng (drivers)
CREATE TABLE IF NOT EXISTS `drivers` (
    `driver_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'AVAILABLE', -- 'AVAILABLE', 'BUSY', 'OFFLINE', 'BANNED'
    `license_plate` VARCHAR(30) DEFAULT '59-X3 999.99',
    `vehicle_type` VARCHAR(50) DEFAULT 'Xe máy',
    `wallet_balance` DOUBLE NOT NULL DEFAULT 500000.0,
    `current_latitude` DOUBLE DEFAULT 10.8510,
    `current_longitude` DOUBLE DEFAULT 106.7725,
    `current_address` VARCHAR(255) DEFAULT '1 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh',
    `avatar` VARCHAR(500) DEFAULT NULL,
    `id_card_front` VARCHAR(500) DEFAULT NULL,
    `id_card_back` VARCHAR(500) DEFAULT NULL,
    `vehicle_doc` VARCHAR(500) DEFAULT NULL,
    `last_location_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_drivers_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Bảng đơn đặt hàng (orders)
-- Mối quan hệ: Khách hàng đặt đơn (users -> orders), tài xế phụ trách đơn (drivers -> orders)
CREATE TABLE IF NOT EXISTS `orders` (
    `order_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `note` TEXT,
    `proof_image` VARCHAR(500) DEFAULT NULL,
    `total_amount` DOUBLE NOT NULL DEFAULT 0,
    `shipping_fee` DOUBLE NOT NULL DEFAULT 15000,
    `distance_km` DOUBLE NOT NULL DEFAULT 2.0,
    `discount_amount` DOUBLE NOT NULL DEFAULT 0,
    `voucher_code` VARCHAR(50) DEFAULT NULL,
    `voucher_refunded` TINYINT(1) DEFAULT 0,
    `payment_method` VARCHAR(20) DEFAULT 'COD', -- 'COD', 'QR', 'CARD'
    `status` VARCHAR(30) DEFAULT 'PENDING', -- 'PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'CANCELLED'
    `driver_id` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `customer_confirmed` TINYINT(1) DEFAULT 0, -- Khách hàng xác nhận đã nhận được món
    `merchant_confirmed` TINYINT(1) DEFAULT 0, -- Merchant xác nhận đã xử lý đơn
    `shipper_accepted` TINYINT(1) DEFAULT 0,   -- Shipper xác nhận nhận giao đơn
    `shipper_picked_up` TINYINT(1) DEFAULT 0,  -- Shipper xác nhận đã lấy món ăn từ quán
    `shipper_delivered` TINYINT(1) DEFAULT 0,  -- Shipper xác nhận đã giao tận tay khách
    `merchant_completed` TINYINT(1) DEFAULT 0, -- Merchant duyệt hoàn thành đơn cuối cùng (để tính doanh thu)
    CONSTRAINT `fk_orders_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_drivers`
        FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Bảng chi tiết đơn đặt hàng (order_items)
-- Mối quan hệ: Một đơn hàng có nhiều món ăn, quan hệ N-N giữa orders và foods qua order_items
CREATE TABLE IF NOT EXISTS `order_items` (
    `order_item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `food_id` INT NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `unit_price` DOUBLE NOT NULL,
    `subtotal` DOUBLE NOT NULL,
    CONSTRAINT `fk_order_items_orders`
        FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_order_items_foods`
        FOREIGN KEY (`food_id`) REFERENCES `foods` (`food_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Bảng đánh giá và nhận xét đơn hàng / tài xế / món ăn (order_reviews)
CREATE TABLE IF NOT EXISTS `order_reviews` (
    `review_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `driver_id` INT NULL,
    `restaurant_id` INT NULL,
    `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
    `comment` TEXT,
    `food_rating` INT DEFAULT NULL,
    `food_comment` TEXT DEFAULT NULL,
    `driver_rating` INT DEFAULT NULL,
    `driver_comment` TEXT DEFAULT NULL,
    `image_url` VARCHAR(500) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_reviews_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_customers` FOREIGN KEY (`customer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_drivers` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_reviews_restaurants` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`) ON DELETE CASCADE,
    UNIQUE (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Bảng thông báo chung cho cả 3 vai trò (notifications)
CREATE TABLE IF NOT EXISTS `notifications` (
    `notification_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `order_id` INT DEFAULT NULL,
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `type` VARCHAR(50) DEFAULT 'ORDER', -- 'ORDER_NEW', 'ORDER_ASSIGNED', 'SHIPPER_ACCEPTED', 'ORDER_SHIPPING', 'SHIPPER_DELIVERED', 'CUSTOMER_CONFIRMED', 'ORDER_COMPLETED', 'ORDER_CANCELLED'
    `link` VARCHAR(255) DEFAULT NULL,
    `is_read` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notif_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Bảng mã giảm giá / Voucher (vouchers)
CREATE TABLE IF NOT EXISTS `vouchers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `restaurant_id` INT DEFAULT NULL,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `discount_type` VARCHAR(20) NOT NULL DEFAULT 'FIXED',
    `discount_value` DOUBLE NOT NULL DEFAULT 0,
    `min_order_amount` DOUBLE NOT NULL DEFAULT 0,
    `max_discount` DOUBLE NOT NULL DEFAULT 0,
    `is_free_ship` TINYINT(1) NOT NULL DEFAULT 0,
    `usage_limit` INT NOT NULL DEFAULT 0,
    `used_count` INT NOT NULL DEFAULT 0,
    `per_user_limit` INT NOT NULL DEFAULT 1,
    `start_date` VARCHAR(20) DEFAULT NULL,
    `end_date` VARCHAR(20) DEFAULT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `badge` VARCHAR(50) DEFAULT '🔥 ƯU ĐÃI',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY `idx_v_rest` (`restaurant_id`),
    KEY `idx_v_code` (`code`),
    CONSTRAINT `fk_vouchers_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Bảng kho voucher người dùng (user_vouchers)
CREATE TABLE IF NOT EXISTS `user_vouchers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `voucher_code` VARCHAR(50) NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `discount_type` VARCHAR(20) DEFAULT 'FIXED',
    `discount_value` DOUBLE DEFAULT 0,
    `min_order_amount` DOUBLE DEFAULT 0,
    `max_discount` DOUBLE DEFAULT 0,
    `is_free_ship` TINYINT(1) DEFAULT 0,
    `badge` VARCHAR(50) DEFAULT 'ƯU ĐÃI',
    `restaurant_id` INT DEFAULT NULL,
    `restaurant_name` VARCHAR(255) DEFAULT NULL,
    `quantity` INT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_awarded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY `idx_uv_user` (`user_id`),
    KEY `idx_uv_code` (`voucher_code`),
    CONSTRAINT `fk_user_vouchers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Bảng lịch sử biến động ví tài xế (driver_wallet_transactions)
CREATE TABLE IF NOT EXISTS `driver_wallet_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `driver_id` INT NOT NULL,
    `order_id` INT DEFAULT NULL,
    `type` VARCHAR(30) NOT NULL,
    `amount` DOUBLE NOT NULL,
    `balance_after` DOUBLE NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY `idx_dwt_driver` (`driver_id`),
    KEY `idx_dwt_order` (`order_id`),
    KEY `idx_dwt_created` (`created_at`),
    CONSTRAINT `fk_dwt_driver` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Bảng hội thoại chat trực tiếp (chat_conversations)
CREATE TABLE IF NOT EXISTS `chat_conversations` (
    `conversation_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `restaurant_id` INT NOT NULL,
    `last_message` TEXT DEFAULT NULL,
    `last_message_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `unread_user_count` INT DEFAULT 0,
    `unread_merchant_count` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_user_restaurant` (`user_id`, `restaurant_id`),
    CONSTRAINT `fk_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_chat_restaurant` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Bảng tin nhắn trò chuyện (chat_messages)
CREATE TABLE IF NOT EXISTS `chat_messages` (
    `message_id` INT AUTO_INCREMENT PRIMARY KEY,
    `conversation_id` INT NOT NULL,
    `sender_id` INT NOT NULL,
    `sender_role` VARCHAR(20) NOT NULL, -- 'CUSTOMER' hoặc 'SELLER'
    `message` TEXT NOT NULL,
    `order_id` INT DEFAULT NULL,
    `is_read` TINYINT(1) DEFAULT 0,
    `is_recalled` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_chat_msg_conv` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`conversation_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_chat_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    INDEX `idx_conv_created` (`conversation_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DỮ LIỆU KHỞI TẠO MẪU CHO TÀI KHOẢN SHIPPER KAITOKID (AN TOÀN CHO DATA ĐÃ CÓ)
-- ====================================================================
INSERT IGNORE INTO `users` (`username`, `password`, `name`, `email`, `phone`, `address`, `role`)
VALUES ('kaitokid', '123456', 'tran gia kiet', 'kaitokid@utee.vn', '0909998877', '1 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh', 'SHIPPER');

INSERT INTO `drivers` (`user_id`, `name`, `phone`, `status`, `license_plate`, `vehicle_type`)
SELECT `user_id`, 'tran gia kiet', '0909998877', 'AVAILABLE', '59-X3 999.99', 'Honda Air Blade 160'
FROM `users` WHERE `username` = 'kaitokid'
ON DUPLICATE KEY UPDATE `status` = VALUES(`status`);
