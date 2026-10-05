package com.ute.fooddelivery.dao;

import com.ute.fooddelivery.model.ChatConversation;
import com.ute.fooddelivery.model.ChatMessage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    /**
     * Lấy hoặc tạo mới cuộc hội thoại giữa User và Restaurant
     */
    public ChatConversation getOrCreateConversation(int userId, int restaurantId) {
        String selectSql = "SELECT c.*, u.name AS user_name, u.avatar AS user_avatar, u.phone AS user_phone, " +
                "r.name AS rest_name, r.image_url AS rest_avatar, r.address AS rest_address, r.phone AS rest_phone " +
                "FROM chat_conversations c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "JOIN restaurants r ON c.restaurant_id = r.restaurant_id " +
                "WHERE c.user_id = ? AND c.restaurant_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapConversation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Nếu chưa có, tạo mới
        String insertSql = "INSERT INTO chat_conversations (user_id, restaurant_id, last_message, unread_user_count, unread_merchant_count) " +
                "VALUES (?, ?, 'Bắt đầu cuộc trò chuyện', 0, 0)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, restaurantId);
            ps.executeUpdate();
            
            // Query lại cuộc trò chuyện vừa tạo
            return getOrCreateConversation(userId, restaurantId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy cuộc hội thoại theo ID
     */
    public ChatConversation getConversationById(int conversationId) {
        String sql = "SELECT c.*, u.name AS user_name, u.avatar AS user_avatar, u.phone AS user_phone, " +
                "r.name AS rest_name, r.image_url AS rest_avatar, r.address AS rest_address, r.phone AS rest_phone " +
                "FROM chat_conversations c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "JOIN restaurants r ON c.restaurant_id = r.restaurant_id " +
                "WHERE c.conversation_id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapConversation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Danh sách hội thoại cho Khách hàng
     */
    public List<ChatConversation> getConversationsForUser(int userId) {
        List<ChatConversation> list = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS user_name, u.avatar AS user_avatar, u.phone AS user_phone, " +
                "r.name AS rest_name, r.image_url AS rest_avatar, r.address AS rest_address, r.phone AS rest_phone " +
                "FROM chat_conversations c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "JOIN restaurants r ON c.restaurant_id = r.restaurant_id " +
                "WHERE c.user_id = ? " +
                "ORDER BY c.last_message_at DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapConversation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Danh sách hội thoại cho Quán ăn / Chủ quán
     */
    public List<ChatConversation> getConversationsForMerchant(int restaurantId) {
        List<ChatConversation> list = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS user_name, u.avatar AS user_avatar, u.phone AS user_phone, " +
                "r.name AS rest_name, r.image_url AS rest_avatar, r.address AS rest_address, r.phone AS rest_phone " +
                "FROM chat_conversations c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "JOIN restaurants r ON c.restaurant_id = r.restaurant_id " +
                "WHERE c.restaurant_id = ? " +
                "ORDER BY c.last_message_at DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapConversation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy toàn bộ lịch sử tin nhắn của một cuộc hội thoại (sắp xếp tăng dần theo thời gian)
     */
    public List<ChatMessage> getMessages(int conversationId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT m.*, u.name AS sender_name, u.avatar AS sender_avatar " +
                "FROM chat_messages m " +
                "JOIN users u ON m.sender_id = u.user_id " +
                "WHERE m.conversation_id = ? " +
                "ORDER BY m.created_at ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMessage(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lưu tin nhắn mới vào database và cập nhật last_message của conversation
     */
    public ChatMessage saveMessage(int conversationId, int senderId, String senderRole, String message, Integer orderId) {
        String insertMsg = "INSERT INTO chat_messages (conversation_id, sender_id, sender_role, message, order_id, is_read) " +
                "VALUES (?, ?, ?, ?, ?, 0)";

        String updateConv = "CUSTOMER".equalsIgnoreCase(senderRole) ?
                "UPDATE chat_conversations SET last_message = ?, unread_merchant_count = unread_merchant_count + 1 WHERE conversation_id = ?" :
                "UPDATE chat_conversations SET last_message = ?, unread_user_count = unread_user_count + 1 WHERE conversation_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            int msgId = 0;
            try (PreparedStatement ps = conn.prepareStatement(insertMsg, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, conversationId);
                ps.setInt(2, senderId);
                ps.setString(3, senderRole);
                ps.setString(4, message);
                if (orderId != null && orderId > 0) {
                    ps.setInt(5, orderId);
                } else {
                    ps.setNull(5, Types.INTEGER);
                }
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        msgId = rs.getInt(1);
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateConv)) {
                ps.setString(1, message);
                ps.setInt(2, conversationId);
                ps.executeUpdate();
            }

            conn.commit();

            if (msgId > 0) {
                return getMessageById(msgId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy 1 tin nhắn theo ID
     */
    public ChatMessage getMessageById(int messageId) {
        String sql = "SELECT m.*, u.name AS sender_name, u.avatar AS sender_avatar " +
                "FROM chat_messages m " +
                "JOIN users u ON m.sender_id = u.user_id " +
                "WHERE m.message_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMessage(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Đánh dấu đã đọc cho phía người xem
     * readerRole: "CUSTOMER" (user đọc tin nhắn quán gửi) hoặc "SELLER" (quán đọc tin nhắn khách gửi)
     */
    public void markAsRead(int conversationId, String readerRole) {
        String updateMsgSql = "UPDATE chat_messages SET is_read = 1 WHERE conversation_id = ? AND sender_role != ?";
        String updateConvSql = "CUSTOMER".equalsIgnoreCase(readerRole) ?
                "UPDATE chat_conversations SET unread_user_count = 0 WHERE conversation_id = ?" :
                "UPDATE chat_conversations SET unread_merchant_count = 0 WHERE conversation_id = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(updateMsgSql)) {
                ps.setInt(1, conversationId);
                ps.setString(2, readerRole);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(updateConvSql)) {
                ps.setInt(1, conversationId);
                ps.executeUpdate();
            }
            conn.commit();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy tổng số tin nhắn chưa đọc của Khách hàng
     */
    public int getUserUnreadCount(int userId) {
        String sql = "SELECT COALESCE(SUM(unread_user_count), 0) FROM chat_conversations WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy tổng số tin nhắn chưa đọc của Chủ quán
     */
    public int getMerchantUnreadCount(int restaurantId) {
        String sql = "SELECT COALESCE(SUM(unread_merchant_count), 0) FROM chat_conversations WHERE restaurant_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private ChatConversation mapConversation(ResultSet rs) throws SQLException {
        ChatConversation c = new ChatConversation();
        c.setId(rs.getInt("conversation_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setRestaurantId(rs.getInt("restaurant_id"));
        c.setLastMessage(rs.getString("last_message"));
        c.setLastMessageAt(rs.getTimestamp("last_message_at"));
        c.setUnreadUserCount(rs.getInt("unread_user_count"));
        c.setUnreadMerchantCount(rs.getInt("unread_merchant_count"));
        c.setCreatedAt(rs.getTimestamp("created_at"));

        c.setUserName(rs.getString("user_name"));
        c.setUserAvatar(rs.getString("user_avatar"));
        c.setUserPhone(rs.getString("user_phone"));
        c.setRestaurantName(rs.getString("rest_name"));
        c.setRestaurantAvatar(rs.getString("rest_avatar"));
        c.setRestaurantAddress(rs.getString("rest_address"));
        c.setRestaurantPhone(rs.getString("rest_phone"));
        return c;
    }

    private ChatMessage mapMessage(ResultSet rs) throws SQLException {
        ChatMessage m = new ChatMessage();
        m.setId(rs.getInt("message_id"));
        m.setConversationId(rs.getInt("conversation_id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setSenderRole(rs.getString("sender_role"));
        m.setMessage(rs.getString("message"));
        m.setOrderId((Integer) rs.getObject("order_id"));
        m.setRead(rs.getBoolean("is_read"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setSenderName(rs.getString("sender_name"));
        m.setSenderAvatar(rs.getString("sender_avatar"));
        return m;
    }
}
