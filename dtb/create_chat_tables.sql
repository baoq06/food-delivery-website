-- ====================================================================
-- TẠO CÁC BẢNG LƯU TRỮ TIN NHẮN VÀ LỊCH SỬ HỘI THOẠI GIỮA KHÁCH HÀNG & CHỦ QUÁN
-- ====================================================================

-- 1. Bảng cuộc trò chuyện (chat_conversations)
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

-- 2. Bảng tin nhắn (chat_messages) lưu toàn bộ lịch sử trò chuyện
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
