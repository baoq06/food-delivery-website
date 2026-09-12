-- ====================================================================
-- CẬP NHẬT DATABASE CHO LUỒNG ĐĂNG KÝ 4 BƯỚC (VIN DELIVERY)
-- Tương thích MySQL / TiDB Cloud
-- ====================================================================

-- 1. Bổ sung ảnh đại diện cho bảng users
ALTER TABLE `users` ADD COLUMN `avatar` VARCHAR(500) DEFAULT NULL;

-- 2. Bổ sung tài liệu & ảnh nhận diện cho bảng drivers
ALTER TABLE `drivers` ADD COLUMN `id_card_front` VARCHAR(500) DEFAULT NULL;
ALTER TABLE `drivers` ADD COLUMN `id_card_back` VARCHAR(500) DEFAULT NULL;
ALTER TABLE `drivers` ADD COLUMN `vehicle_doc` VARCHAR(500) DEFAULT NULL;
ALTER TABLE `drivers` ADD COLUMN `avatar` VARCHAR(500) DEFAULT NULL;

-- 3. Bổ sung giờ mở cửa, đóng cửa cho bảng restaurants
ALTER TABLE `restaurants` ADD COLUMN `open_time` VARCHAR(10) DEFAULT '07:00';
ALTER TABLE `restaurants` ADD COLUMN `close_time` VARCHAR(10) DEFAULT '22:00';
