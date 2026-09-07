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
(2, 6, 'Phở & Bún Gia Truyền 1985', 'Nước dùng ninh xương 24h thanh ngọt, thịt tươi mỗi ngày.', '0902345678', '128 Võ Văn Tần, Phường Võ Thị Sáu, Quận 3, TP. HCM', 'OPEN', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60'),
(3, NULL, 'Trà Sữa & Topping Quán', 'Trà sữa đậm vị trà, trân châu dẻo dai nấu mới liên tục.', '0903456789', '88 Sư Vạn Hạnh, Phường 12, Quận 10, TP. HCM', 'OPEN', 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500&auto=format&fit=crop&q=60'),
(4, NULL, 'FastFood King & Snacks', 'Gà rán giòn rụm, Burger phô mai kéo sợi thơm lừng.', '0904567890', '215 Nguyễn Thị Minh Khai, Phường Cầu Ông Lãnh, Quận 1, TP. HCM', 'OPEN', 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&auto=format&fit=crop&q=60');

-- 4. Thêm các món ăn vào bảng foods (chỉ giữ món thuộc nhà hàng mẫu độc lập)
INSERT INTO `foods` (`food_id`, `restaurant_id`, `category_id`, `name`, `price`, `description`, `image_url`, `is_available`) VALUES
-- Nhà hàng 3: Trà Sữa & Topping Quán (Đồ Uống - Danh mục 3)
(9, 3, 3, 'Trà Sữa Trân Châu Đường Đen', 35000, 
 'Sữa tươi Đà Lạt thanh mát kết hợp trân châu thủ công dẻo quánh nấu đẫm cùng mật mía đường đen cô đặc.', 
 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=700&auto=format&fit=crop&q=80', 1),

(10, 3, 3, 'Trà Đào Cam Sả Tươi Mát', 40000, 
 'Hương sả nồng ấm kết hợp nước cốt cam tươi mọng nước và từng miếng đào ngâm vàng giòn sảng khoái ngày hè.', 
 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=700&auto=format&fit=crop&q=80', 1),

(11, 3, 3, 'Trà Ô Long Macchiato Phô Mai', 45000, 
 'Nước cốt trà Ô Long nướng đậm hương gỗ thảo mộc phủ lớp kem cheese muối biển béo ngậy mằn mặn khó cưỡng.', 
 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=700&auto=format&fit=crop&q=80', 1),

(12, 3, 3, 'Matcha Latte Đậu Đỏ', 42000, 
 'Bột trà xanh Uji Nhật Bản nguyên chất hoà quyện cùng sữa tươi béo thơm và lớp đậu đỏ ngào đường dẻo bùi.', 
 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=700&auto=format&fit=crop&q=80', 1),

-- Nhà hàng 4: FastFood King & Snacks (Fastfood & Ăn Vặt - Danh mục 4)
(13, 4, 4, 'Burger Bò Phô Mai Double Cheese', 55000, 
 'Bò Úc nướng mềm mọng nước, 2 lớp phô mai Cheddar béo ngậy tan chảy cùng sốt mayonnaise tiêu đen đặc chế.', 
 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700&auto=format&fit=crop&q=80', 1),

(14, 4, 4, 'Combo Gà Rán Giòn Cay Sốt Hàn', 79000, 
 'Miếng gà tươi chiên giòn rụm bên ngoài mọng nước bên trong, phủ đẫm sốt cay ngọt cay tê lưỡi chuẩn vị Seoul.', 
 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=700&auto=format&fit=crop&q=80', 1),

(15, 4, 4, 'Pizza Hải Sản Sốt Pesto (Size M)', 129000, 
 'Tôm sú tươi giòn, mực tươi Phan Thiết, phô mai Mozzarella kéo sợi trên nền sốt lá húng quế Pesto Ý độc đáo.', 
 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700&auto=format&fit=crop&q=80', 1),

(16, 4, 4, 'Khoai Tây Chiên Lắc Phô Mai', 35000, 
 'Khoai tây cọng nhập khẩu chiên nóng hổi vàng ươm, lắc đều cùng bột phô mai truyền thống thơm lừng béo ngậy.', 
 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=700&auto=format&fit=crop&q=80', 1);

-- 5. Thêm địa chỉ nhận hàng mẫu (addresses)
INSERT INTO `addresses` (`address_id`, `user_id`, `receiver_phone`, `ward`, `district`, `city`, `is_default`) VALUES
(1, 3, '0912345678', 'Phường Bến Nghé', 'Quận 1', 'TP. Hồ Chí Minh', 1),
(2, 3, '0912345678', 'Phường Linh Chiểu', 'TP. Thủ Đức', 'TP. Hồ Chí Minh', 0),
(3, 4, '0987654322', 'Phường 22', 'Quận Bình Thạnh', 'TP. Hồ Chí Minh', 1),
(4, 2, '0987654321', 'Phường Bến Thành', 'Quận 1', 'TP. Hồ Chí Minh', 1);

-- Lưu ý: Không gán trước drivers, orders và foods cho tài khoản merchant (bepviet, pho1985)
-- để đảm bảo tính toàn vẹn khi người dùng thiết lập thực tế.
