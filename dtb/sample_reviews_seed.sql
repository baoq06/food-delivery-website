-- ====================================================================
-- SEED DỮ LIỆU ĐƠN HÀNG VÀ ĐÁNH GIÁ THỰC TẾ (ORDER_REVIEWS)
-- Đảm bảo tính toán rating thật và danh sách comment chân thực
-- ====================================================================

USE `food_delivery_db`;

-- Cập nhật cả 2 quán thành OPEN để khách hàng trải nghiệm tốt nhất
UPDATE `restaurants` SET `status` = 'OPEN' WHERE `restaurant_id` IN (1, 2);

-- Bổ sung thêm món phở gia truyền cho quán 2 (Phở 1985) nếu chưa có món phở
INSERT IGNORE INTO `foods` (`food_id`, `restaurant_id`, `category_id`, `name`, `price`, `description`, `image_url`, `is_available`)
VALUES 
(200001, 2, 2, 'Phở Bò Tái Nạm 1985', 62000, 'Nước dùng ninh xương bò 24h gia truyền thơm béo đậm đà, thịt bò tươi mềm ngọt', 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=700&auto=format&fit=crop&q=80', 1),
(200002, 2, 2, 'Bún Bò Huế Chả Cua Đặc Biệt', 65000, 'Bún bò chuẩn vị cố đô, chả cua giòn ngọt, giò heo thơm phức mắm ruốc', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&auto=format&fit=crop&q=80', 1),
(200003, 1, 3, 'Trà Đào Cam Sả Tươi Mát', 32000, 'Trà đào thanh ngọt tự nhiên, cam vàng mọng nước cùng hương sả thơm lừng', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=700&auto=format&fit=crop&q=80', 1);

-- 1. Thêm các đơn hàng DELIVERED mẫu liên quan đến các món và quán
INSERT IGNORE INTO `orders` (`order_id`, `user_id`, `customer_name`, `phone`, `address`, `note`, `total_amount`, `payment_method`, `status`, `customer_confirmed`, `shipper_delivered`, `merchant_completed`, `created_at`)
VALUES
(70001, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, Q.1, TP. HCM', 'Giao tầng 3 giúp mình', 116000, 'COD', 'DELIVERED', 1, 1, 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(70002, 3, 'Nguyễn Văn A', '0912345678', 'Phường Bến Nghé, Q.1, TP. HCM', 'Không lấy ớt', 72000, 'COD', 'DELIVERED', 1, 1, 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(70003, 4, 'Trần Thị B', '0987654322', 'Phường 22, Q. Bình Thạnh, TP. HCM', 'Cho thêm nước mắm tỏi ớt', 174000, 'COD', 'DELIVERED', 1, 1, 1, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(70004, 2, 'Nguyễn Văn Khách', '0987654321', '123 Lê Lợi, Q.1, TP. HCM', 'Lấy nhiều rau thơm', 124000, 'COD', 'DELIVERED', 1, 1, 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(70005, 3, 'Nguyễn Văn A', '0912345678', 'Phường Bến Nghé, Q.1, TP. HCM', 'Giao trước 12h trưa', 65000, 'COD', 'DELIVERED', 1, 1, 1, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(70006, 4, 'Trần Thị B', '0987654322', 'Phường 22, Q. Bình Thạnh, TP. HCM', 'Phở nóng nhiều hành lá', 130000, 'COD', 'DELIVERED', 1, 1, 1, NOW());

-- 2. Thêm chi tiết đơn hàng (order_items) liên kết với món ăn
INSERT IGNORE INTO `order_items` (`order_item_id`, `order_id`, `food_id`, `quantity`, `unit_price`, `subtotal`)
VALUES
(80001, 70001, 60002, 2, 58000, 116000), -- 2 Cơm sườn (Quán 1)
(80002, 70002, 90002, 2, 36000, 72000),  -- 2 Nem chua (Quán 1)
(80003, 70003, 60002, 3, 58000, 174000), -- 3 Cơm sườn (Quán 1)
(80004, 70004, 200001, 2, 62000, 124000), -- 2 Phở bò tái nạm 1985 (Quán 2)
(80005, 70005, 200002, 1, 65000, 65000),  -- 1 Bún bò huế (Quán 2)
(80006, 70006, 200001, 1, 62000, 62000),  -- 1 Phở bò tái nạm 1985 (Quán 2)
(80007, 70006, 200002, 1, 65000, 65000);  -- 1 Bún bò huế (Quán 2)

-- 3. Thêm các đánh giá thực tế (order_reviews)
INSERT IGNORE INTO `order_reviews` (`review_id`, `order_id`, `customer_id`, `driver_id`, `restaurant_id`, `rating`, `comment`, `food_rating`, `food_comment`, `driver_rating`, `driver_comment`, `created_at`)
VALUES
(90001, 70001, 2, 120003, 1, 5, 'Cơm sườn nướng mật ong thơm lừng, sườn mềm mọng nước không bị khô, nước mắm pha kẹo rất vừa miệng!', 5, 'Cơm sườn nướng mật ong thơm lừng, sườn mềm mọng nước không bị khô, nước mắm pha kẹo rất vừa miệng!', 5, 'Tài xế giao nhanh nhiệt tình', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(90002, 70002, 3, 120003, 1, 5, 'Nem chua rán giòn rụm, tương ớt cay nồng ăn kèm rất dính, đóng gói cẩn thận sạch sẽ!', 5, 'Nem chua rán giòn rụm, tương ớt cay nồng ăn kèm rất dính, đóng gói cẩn thận sạch sẽ!', 5, 'Giao đúng giờ', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(90003, 70003, 4, 120003, 1, 4, 'Món cơm sườn rất ngon, canh ăn kèm nóng hổi, quán cho nhiều đồ chua giòn ngon. Sẽ ủng hộ tiếp!', 4, 'Món cơm sườn rất ngon, canh ăn kèm nóng hổi, quán cho nhiều đồ chua giòn ngon. Sẽ ủng hộ tiếp!', 5, 'Anh shipper dễ thương', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(90004, 70004, 2, 120003, 2, 5, 'Phở bò 1985 đúng chuẩn gia truyền! Nước dùng thanh ngọt tự nhiên từ xương, thịt bò tái mềm tươi rói.', 5, 'Phở bò 1985 đúng chuẩn gia truyền! Nước dùng thanh ngọt tự nhiên từ xương, thịt bò tái mềm tươi rói.', 5, 'Giao hàng siêu tốc còn bốc khói', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(90005, 70005, 3, 120003, 2, 5, 'Tô bún bò huế đầy đặn, chả cua đậm vị ngọt béo, nước lèo cay cay the the rất hợp gu mình.', 5, 'Tô bún bò huế đầy đặn, chả cua đậm vị ngọt béo, nước lèo cay cay the the rất hợp gu mình.', 5, 'Shipper thân thiện', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(90006, 70006, 4, 120003, 2, 5, 'Cả phở và bún bò đều xuất sắc 10/10! Quán đóng hộp giấy giữ nhiệt sạch sẽ và thân thiện môi trường.', 5, 'Cả phở và bún bò đều xuất sắc 10/10! Quán đóng hộp giấy giữ nhiệt sạch sẽ và thân thiện môi trường.', 5, 'Rất hài lòng', NOW());
