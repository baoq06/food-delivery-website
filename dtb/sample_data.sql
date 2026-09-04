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

-- 4. Thêm các món ăn vào bảng foods (kèm ảnh và mô tả để giao diện hiển thị đẹp)
INSERT INTO `foods` (`food_id`, `restaurant_id`, `category_id`, `name`, `price`, `description`, `image_url`, `is_available`) VALUES
-- Nhà hàng 1: Bếp Việt Quán (Cơm & Món Mặn - Danh mục 1)
(1, 1, 1, 'Cơm Tấm Sườn Nướng Mật Ong', 55000, 
 'Sườn non tẩm ướp mật ong nướng than hoa thơm lừng, ăn kèm mỡ hành, chả trứng và đồ chua giòn giòn.', 
 'https://images.unsplash.com/photo-1544025162-d76694265947?w=700&auto=format&fit=crop&q=80', 1),

(2, 1, 1, 'Cơm Gà Xối Mỡ Da Giòn', 60000, 
 'Gà thả vườn chiên xối mỡ vàng ươm, lớp da giòn rụm mọng nước, ăn kèm cơm hạt sen thơm dẻo và nước mắm chua ngọt.', 
 'https://images.unsplash.com/photo-1562967914-608f82629710?w=700&auto=format&fit=crop&q=80', 1),

(3, 1, 1, 'Cơm Bò Xào Lúc Lắc', 70000, 
 'Thịt thăn bò mềm ngọt xào cùng ớt chuông, hành tây đậm vị sốt tiêu đen, kèm cơm trắng dẻo thơm.', 
 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80', 1),

(4, 1, 1, 'Cơm Thịt Kho Trứng Nước Dừa', 50000, 
 'Thịt ba chỉ rút sườn kho mềm rục với nước dừa xiêm bến tre, trứng vịt thấm đẫm hương vị béo bùi.', 
 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&auto=format&fit=crop&q=80', 1),

-- Nhà hàng 2: Phở & Bún Gia Truyền 1985 (Phở & Bún Mì - Danh mục 2)
(5, 2, 2, 'Phở Bò Tái Nạm Đặc Biệt', 75000, 
 'Nước dùng hầm xương ống 24 tiếng ngọt thanh chuẩn vị Hà Nội, thịt bò tái nạm tươi mềm thơm nức mùi hoa hồi.', 
 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=700&auto=format&fit=crop&q=80', 1),

(6, 2, 2, 'Bún Bò Huế Chả Cua Đầy Đủ', 65000, 
 'Sợi bún to mềm, bắp bò hoa giòn sần sật quyện nước dùng ruốc sả cay nồng, chả cua biển nguyên chất đậm đà.', 
 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&auto=format&fit=crop&q=80', 1),

(7, 2, 2, 'Mì Quảng Tôm Thịt Trứng Cút', 60000, 
 'Mì vàng sợi dai nghệ tươi, tôm sông rim mặn ngọt, thịt ba chỉ thơm nức cùng bánh tráng mè nướng giòn tan.', 
 'https://images.unsplash.com/photo-1621996346565-e3d5d6281691?w=700&auto=format&fit=crop&q=80', 1),

(8, 2, 2, 'Bún Chả Hà Nội Nướng Than', 65000, 
 'Chả miếng và chả viên nướng xém cạnh trên than hoa, nước chấm đu đủ cà rốt pha khéo vừa chua thanh vừa ngọt dịu.', 
 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&auto=format&fit=crop&q=80', 1),

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

-- 6. Thêm tài xế giao hàng (drivers)
INSERT INTO `drivers` (`driver_id`, `name`, `phone`, `status`) VALUES
(1, 'Tài xế Lê Văn Hùng', '0933112233', 'AVAILABLE'),
(2, 'Tài xế Phạm Tuấn Kiệt', '0933445566', 'AVAILABLE'),
(3, 'Tài xế Nguyễn Văn Long', '0933778899', 'BUSY'),
(4, 'Tài xế Trần Minh Trí', '0933221100', 'OFFLINE');

-- 7. Thêm đơn hàng mẫu (orders) - Trải đều qua các ngày & tháng để test doanh thu Ngày/Tháng/Năm
INSERT INTO `orders` (`order_id`, `user_id`, `customer_name`, `phone`, `address`, `note`, `total_amount`, `payment_method`, `status`, `driver_id`, `created_at`) VALUES
-- Đơn hôm nay (Today)
(1, 3, 'Nguyễn Văn A', '0912345678', '45 Lê Duẩn, P. Bến Nghé, Q.1, TP. HCM', 'Giao sảnh lễ tân, ít cay', 110000, 'COD', 'DELIVERED', 1, NOW()),
(2, 4, 'Trần Thị B', '0987654322', '12 Điện Biên Phủ, P.22, Q. Bình Thạnh', 'Gọi trước khi tới 5p', 120000, 'QR', 'DELIVERED', 2, NOW()),
(3, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'Cơm thêm mỡ hành', 125000, 'COD', 'SHIPPING', 3, NOW()),
(4, 3, 'Nguyễn Văn A', '0912345678', '45 Lê Duẩn, P. Bến Nghé, Q.1, TP. HCM', 'Quán làm nhanh giúp', 70000, 'COD', 'CONFIRMED', NULL, NOW()),
(5, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'Khách vừa đặt món', 55000, 'COD', 'PENDING', NULL, NOW()),

-- Đơn hôm qua (Yesterday)
(6, 3, 'Nguyễn Văn A', '0912345678', '45 Lê Duẩn, P. Bến Nghé, Q.1, TP. HCM', 'Giao tận cửa', 175000, 'CARD', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(7, 4, 'Trần Thị B', '0987654322', '12 Điện Biên Phủ, P.22, Q. Bình Thạnh', 'Giao đúng giờ trưa', 240000, 'QR', 'DELIVERED', 2, DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- Đơn 2 ngày trước
(8, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'Không lấy canh', 130000, 'COD', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- Đơn các tuần trước trong tháng này
(9, 3, 'Nguyễn Văn A', '0912345678', '45 Lê Duẩn, P. Bến Nghé, Q.1, TP. HCM', 'Đơn đặt tiệc trưa', 330000, 'QR', 'DELIVERED', 2, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(10, 4, 'Trần Thị B', '0987654322', '12 Điện Biên Phủ, P.22, Q. Bình Thạnh', 'Giao chiều', 185000, 'COD', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 12 DAY)),

-- Đơn tháng trước (Last Month)
(11, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'Giao giờ trưa', 420000, 'QR', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 1 MONTH)),
(12, 3, 'Nguyễn Văn A', '0912345678', '45 Lê Duẩn, P. Bến Nghé, Q.1, TP. HCM', 'Đặt nhiều', 510000, 'CARD', 'DELIVERED', 2, DATE_SUB(NOW(), INTERVAL 1 MONTH)),

-- Đơn 2 tháng trước
(13, 4, 'Trần Thị B', '0987654322', '12 Điện Biên Phủ, P.22, Q. Bình Thạnh', 'Đơn gia đình', 380000, 'COD', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 2 MONTH)),

-- Đơn năm ngoái (Last Year)
(14, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, P. Bến Nghé, Q.1, TP. HCM', 'Đơn năm cũ', 650000, 'QR', 'DELIVERED', 1, DATE_SUB(NOW(), INTERVAL 1 YEAR));

-- 8. Thêm chi tiết đơn hàng mẫu (order_items)
INSERT INTO `order_items` (`order_item_id`, `order_id`, `food_id`, `quantity`, `unit_price`, `subtotal`) VALUES
-- Đơn 1: 2 Cơm Tấm Sườn (Quán 1 - Bếp Việt)
(1, 1, 1, 2, 55000, 110000),

-- Đơn 2: 2 Cơm Gà Xối Mỡ (Quán 1 - Bếp Việt)
(2, 2, 2, 2, 60000, 120000),

-- Đơn 3: 1 Cơm Tấm Sườn + 1 Cơm Bò Lúc Lắc (Quán 1 - Bếp Việt)
(3, 3, 1, 1, 55000, 55000),
(4, 3, 3, 1, 70000, 70000),

-- Đơn 4: 1 Cơm Bò Lúc Lắc (Quán 1 - Bếp Việt)
(5, 4, 3, 1, 70000, 70000),

-- Đơn 5: 1 Cơm Tấm Sườn (Quán 1 - Bếp Việt)
(6, 5, 1, 1, 55000, 55000),

-- Đơn 6 (Hôm qua): 1 Cơm Tấm Sườn + 2 Cơm Gà (Quán 1 - Bếp Việt)
(7, 6, 1, 1, 55000, 55000),
(8, 6, 2, 2, 60000, 120000),

-- Đơn 7 (Hôm qua): 4 Cơm Gà Xối Mỡ (Quán 1 - Bếp Việt)
(9, 7, 2, 4, 60000, 240000),

-- Đơn 8 (2 ngày trước): 1 Cơm Gà + 1 Cơm Bò Lúc Lắc (Quán 1 - Bếp Việt)
(10, 8, 2, 1, 60000, 60000),
(11, 8, 3, 1, 70000, 70000),

-- Đơn 9 (Tuần trước): 6 Cơm Tấm Sườn (Quán 1 - Bếp Việt)
(12, 9, 1, 6, 55000, 330000),

-- Đơn 10: 1 Cơm Tấm + 1 Cơm Bò Lúc Lắc + 1 Cơm Gà (Quán 1)
(13, 10, 1, 1, 55000, 55000),
(14, 10, 2, 1, 60000, 60000),
(15, 10, 3, 1, 70000, 70000),

-- Đơn 11 (Tháng trước): 7 Cơm Gà Xối Mỡ
(16, 11, 2, 7, 60000, 420000),

-- Đơn 12 (Tháng trước): 6 Cơm Tấm + 3 Cơm Gà
(17, 12, 1, 6, 55000, 330000),
(18, 12, 2, 3, 60000, 180000),

-- Đơn 13 (2 tháng trước): 4 Cơm Bò Lúc Lắc + 2 Cơm Thịt Kho
(19, 13, 3, 4, 70000, 280000),
(20, 13, 4, 2, 50000, 100000),

-- Đơn 14 (Năm ngoái): 10 Cơm Tấm + 2 Cơm Thịt Kho
(21, 14, 1, 10, 55000, 550000),
(22, 14, 4, 2, 50000, 100000);
