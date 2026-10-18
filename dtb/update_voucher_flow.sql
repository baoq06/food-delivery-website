-- ====================================================================
-- CẬP NHẬT DATABASE CHO LUỒNG DISCOUNT / VOUCHER KHI ĐẶT HÀNG
-- ====================================================================

USE `food_delivery_db`;

-- 1. Bổ sung cột discount_amount, voucher_code và voucher_refunded vào bảng orders
ALTER TABLE `orders`
    ADD COLUMN `discount_amount` DOUBLE NOT NULL DEFAULT 0 AFTER `distance_km`,
    ADD COLUMN `voucher_code` VARCHAR(50) DEFAULT NULL AFTER `discount_amount`,
    ADD COLUMN `voucher_refunded` TINYINT(1) DEFAULT 0 AFTER `voucher_code`;
