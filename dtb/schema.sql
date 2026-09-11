-- ====================================================================
-- DATABASE SCHEMA CHO HỆ THỐNG GIAO ĐỒ ĂN (FOOD DELIVERY)
-- Tương thích hoàn toàn với MySQL Workbench 8.0 CE
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `food_delivery_db`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `food_delivery_db`;

-- Tắt kiểm tra khóa ngoại tạm thời để xóa và tạo mới bảng không bị xung đột
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_reviews`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `drivers`;
DROP TABLE IF EXISTS `foods`;
DROP TABLE IF EXISTS `restaurants`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Bảng danh mục món ăn (categories)
CREATE TABLE `categories` (
    `category_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `image_icon` VARCHAR(255) DEFAULT '🍔',
    `description` VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Bảng người dùng (users)
CREATE TABLE `users` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) UNIQUE,
    `phone` VARCHAR(20),
    `address` VARCHAR(255),
    `role` VARCHAR(20) DEFAULT 'CUSTOMER', -- 'ADMIN', 'CUSTOMER', 'SELLER', 'SHIPPER'
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Bảng nhà hàng / quán ăn (restaurants)
-- Mối quan hệ: Mỗi nhà hàng do 1 chủ doanh nghiệp (user có role SELLER) quản lý
CREATE TABLE `restaurants` (
    `restaurant_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT,
    `phone` VARCHAR(20),
    `address` VARCHAR(255) DEFAULT 'TP. Hồ Chí Minh',
    `image_url` VARCHAR(500) DEFAULT NULL,
    `status` VARCHAR(20) DEFAULT 'OPEN', -- 'OPEN', 'CLOSED'
    CONSTRAINT `fk_restaurants_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Bảng địa chỉ nhận hàng của người dùng (addresses)
CREATE TABLE `addresses` (
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
CREATE TABLE `foods` (
    `food_id` INT AUTO_INCREMENT PRIMARY KEY,
    `restaurant_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `price` DOUBLE NOT NULL,
    `description` TEXT,
    `image_url` VARCHAR(500),
    `is_available` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_foods_restaurants`
        FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_foods_categories`
        FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Bảng tài xế giao hàng (drivers)
CREATE TABLE `drivers` (
    `driver_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL,
    `name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `status` VARCHAR(20) DEFAULT 'AVAILABLE', -- 'AVAILABLE', 'BUSY', 'OFFLINE'
    `license_plate` VARCHAR(30) DEFAULT '59-X3 999.99',
    `vehicle_type` VARCHAR(50) DEFAULT 'Xe máy',
    CONSTRAINT `fk_drivers_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Bảng đơn đặt hàng (orders)
-- Mối quan hệ: Khách hàng đặt đơn (users -> orders), tài xế phụ trách đơn (drivers -> orders)
CREATE TABLE `orders` (
    `order_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT DEFAULT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(20) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `note` TEXT,
    `total_amount` DOUBLE NOT NULL DEFAULT 0,
    `payment_method` VARCHAR(20) DEFAULT 'COD', -- 'COD', 'QR', 'CARD'
    `status` VARCHAR(30) DEFAULT 'PENDING', -- 'PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'CANCELLED'
    `driver_id` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `customer_confirmed` TINYINT(1) DEFAULT 0, -- Người dùng xác nhận đã nhận/đặt được hàng
    `merchant_confirmed` TINYINT(1) DEFAULT 0, -- Merchant xác nhận đã xử lý xong đơn hàng
    CONSTRAINT `fk_orders_users`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_drivers`
        FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Bảng chi tiết đơn đặt hàng (order_items)
-- Mối quan hệ: Một đơn hàng có nhiều món ăn, quan hệ N-N giữa orders và foods qua order_items
CREATE TABLE `order_items` (
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

-- 9. Bảng đánh giá và nhận xét đơn hàng / tài xế (order_reviews)
CREATE TABLE IF NOT EXISTS `order_reviews` (
    `review_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `driver_id` INT NULL,
    `restaurant_id` INT NULL,
    `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
    `comment` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_reviews_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_customers` FOREIGN KEY (`customer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviews_drivers` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_reviews_restaurants` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`restaurant_id`) ON DELETE CASCADE,
    UNIQUE (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DỮ LIỆU KHỞI TẠO MẪU CHO TÀI KHOẢN SHIPPER KAITOKID
-- ====================================================================
INSERT INTO `users` (`username`, `password`, `name`, `email`, `phone`, `address`, `role`)
VALUES ('kaitokid', '123456', 'Kaito Kid (Tài Xế Siêu Cấp)', 'kaitokid@utee.vn', '0909998877', '1 Võ Văn Ngân, TP. Thủ Đức, TP. Hồ Chí Minh', 'SHIPPER');

INSERT INTO `drivers` (`user_id`, `name`, `phone`, `status`, `license_plate`, `vehicle_type`)
SELECT `user_id`, 'Kaito Kid (Tài Xế Siêu Cấp)', '0909998877', 'AVAILABLE', '59-X3 999.99', 'Honda Air Blade 160'
FROM `users` WHERE `username` = 'kaitokid';
