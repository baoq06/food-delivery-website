USE `food_delivery_db`;

-- Bước 1: Thêm trường user_id vào bảng drivers trước (không có chữ UNIQUE)
ALTER TABLE `drivers` ADD COLUMN `user_id` INT DEFAULT NULL AFTER `driver_id`;

-- Bước 2: Thêm UNIQUE constraint cho cột user_id vừa tạo
ALTER TABLE `drivers` ADD UNIQUE INDEX `idx_driver_user_id` (`user_id`);

-- Bước 3: Tạo mối quan hệ (khóa ngoại) giữa bảng drivers và users
ALTER TABLE `drivers` ADD CONSTRAINT `fk_drivers_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Bước 4: Chỉnh cột status
ALTER TABLE `drivers` ALTER COLUMN `status` SET DEFAULT 'OFFLINE';
