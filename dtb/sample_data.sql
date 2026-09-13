-- ====================================================================
-- SCRIPT INSERT DỮ LIỆU MẪU CHO DATABASE: food_delivery_db
-- Tương thích hoàn toàn với MySQL Workbench 8.0 CE
-- Bổ sung vai trò SELLER (Chủ Quán) & Dữ liệu thống kê doanh thu thực tế
-- ====================================================================

USE `food_delivery_db`;

-- Tạm ngắt kiểm tra khóa ngoại để làm sạch dữ liệu cũ nếu chạy lại script
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE `order_items`;
TRUNCATE TABLE `orders`;
TRUNCATE TABLE `addresses`;
TRUNCATE TABLE `drivers`;
TRUNCATE TABLE `foods`;
TRUNCATE TABLE `restaurants`;
TRUNCATE TABLE `categories`;
TRUNCATE TABLE `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Thêm danh mục món ăn (categories)
INSERT INTO `categories` (`category_id`, `name`, `image_icon`, `description`) VALUES
(1, 'Cơm & Món Mặn', '🍚', 'Các món cơm tấm, cơm văn phòng, món mặn truyền thống Việt'),
(2, 'Phở & Bún Mì', '🍜', 'Phở bò gia truyền, bún bò huế, mì quảng, bún chả thơm ngon'),
(3, 'Trà Sữa & Đồ Uống', '🧋', 'Trà sữa đậm đà, trà trái cây tươi mát và cafe thơm béo'),
(4, 'Fastfood & Ăn Vặt', '🍔', 'Gà rán giòn rụm, Burger bò phô mai, pizza và khoai lắc');

-- 2. Thêm người dùng mẫu (users) - Bao gồm ADMIN, CUSTOMER và SELLER
INSERT INTO `users` (`user_id`, `username`, `password`, `name`, `email`, `phone`, `address`, `role`, `created_at`) VALUES
(1, 'admin', '123456', 'Quản Trị Viên (Admin)', 'admin@foodzone.vn', '0909123456', 'Văn phòng FoodZone, Q.1, TP. HCM', 'ADMIN', NOW()),
(2, 'customer', '123456', 'Nguyễn Văn Khách', 'khach@gmail.com', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'CUSTOMER', NOW()),
(3, 'nguyenvana', '123456', 'Nguyễn Văn A', 'nguyenvana@gmail.com', '0912345678', 'Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh', 'CUSTOMER', NOW()),
(4, 'tranthib', '123456', 'Trần Thị B', 'tranthib@gmail.com', '0987654322', 'Phường 22, Quận Bình Thạnh, TP. Hồ Chí Minh', 'CUSTOMER', NOW()),
(5, 'bepviet', '123456', 'Chủ Quán Bếp Việt', 'bepviet@foodzone.vn', '0901234567', '45 Lê Lợi, Phường Bến Nghé, Quận 1, TP. HCM', 'SELLER', NOW()),
(6, 'pho1985', '123456', 'Chủ Quán Phở 1985', 'pho1985@foodzone.vn', '0902345678', '128 Võ Văn Tần, Phường Võ Thị Sáu, Quận 3, TP. HCM', 'SELLER', NOW());

-- 3. Thêm nhà hàng / quán ăn (restaurants) - Liên kết với user_id của chủ quán
INSERT INTO `restaurants` (`restaurant_id`, `user_id`, `name`, `description`, `phone`, `address`, `status`, `image_url`) VALUES
(1, 5, 'Bếp Việt Quán', 'Chuyên các món cơm tấm, món Việt đậm đà chuẩn vị quê nhà.', '0901234567', '45 Lê Lợi, Phường Bến Nghé, Quận 1, TP. HCM', 'OPEN', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&auto=format&fit=crop&q=60'),
(2, 6, 'Phở & Bún Gia Truyền 1985', 'Nước dùng ninh xương 24h thanh ngọt, thịt tươi mỗi ngày.', '0902345678', '128 Võ Văn Tần, Phường Võ Thị Sáu, Quận 3, TP. HCM', 'OPEN', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60');

-- 4. Thêm các món ăn vào bảng foods
INSERT INTO `foods` (`food_id`, `restaurant_id`, `category_id`, `name`, `price`, `description`, `image_url`, `is_available`) VALUES
(60002, 1, 1, 'Cơm sườn nướng mật ong', 45000, 'Cơm tấm sườn nướng đậm vị mật ong thơm lừng', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80', 1),
(90002, 1, 1, 'Nem chua thanh hóa', 35000, 'Nem chua giòn sần sật chuẩn vị đặc sản', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&auto=format&fit=crop&q=80', 1),
(120002, 1, 2, 'Pho Bo Dac Biet', 55000, 'Phở bò tái nạm gia truyền nước dùng đậm đà', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700&auto=format&fit=crop&q=80', 1);

-- 5. Thêm địa chỉ nhận hàng mẫu (addresses)
INSERT INTO `addresses` (`address_id`, `user_id`, `receiver_phone`, `ward`, `district`, `city`, `is_default`) VALUES
(1, 3, '0912345678', 'Phường Bến Nghé', 'Quận 1', 'TP. Hồ Chí Minh', 1),
(2, 3, '0912345678', 'Phường Linh Chiểu', 'TP. Thủ Đức', 'TP. Hồ Chí Minh', 0),
(3, 4, '0987654322', 'Phường 22', 'Quận Bình Thạnh', 'TP. Hồ Chí Minh', 1),
(4, 2, '0987654321', 'Phường Bến Thành', 'Quận 1', 'TP. Hồ Chí Minh', 1);

-- 6. Thêm tài xế shipper mẫu
INSERT INTO `drivers` (`driver_id`, `user_id`, `name`, `phone`, `status`, `license_plate`, `vehicle_type`) VALUES
(120003, 120003, 'tran gia kiet', '0909998877', 'AVAILABLE', '59-X3 999.99', 'Honda Air Blade 160');

