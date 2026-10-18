-- Cập nhật cơ sở dữ liệu: Thêm thông tin tài khoản ngân hàng thụ hưởng cho bảng restaurants
-- Phục vụ tính năng thanh toán chuyển khoản qua mã VietQR động

ALTER TABLE `restaurants` 
ADD COLUMN IF NOT EXISTS `bank_code` VARCHAR(50) DEFAULT 'TCB',
ADD COLUMN IF NOT EXISTS `bank_name` VARCHAR(100) DEFAULT 'Techcombank',
ADD COLUMN IF NOT EXISTS `bank_account_no` VARCHAR(50) DEFAULT '1907 2878 4280 15',
ADD COLUMN IF NOT EXISTS `bank_account_name` VARCHAR(150) DEFAULT 'LE HAI DANG';

-- Cập nhật tài khoản mặc định (Techcombank của tác giả) cho các nhà hàng hiện hữu nếu trường còn trống
UPDATE `restaurants` 
SET `bank_code` = 'TCB',
    `bank_name` = 'Techcombank',
    `bank_account_no` = '1907 2878 4280 15',
    `bank_account_name` = COALESCE(NULLIF(name, ''), 'LE HAI DANG')
WHERE `bank_account_no` IS NULL OR `bank_account_no` = '';
