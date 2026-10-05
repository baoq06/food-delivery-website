package com.ute.fooddelivery.controller;

import com.google.gson.Gson;
import com.ute.fooddelivery.dao.ChatDAO;
import com.ute.fooddelivery.dao.RestaurantDAO;
import com.ute.fooddelivery.model.ChatConversation;
import com.ute.fooddelivery.model.ChatMessage;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ChatAPI", urlPatterns = {
        "/api/chat/conversation",
        "/api/chat/messages",
        "/api/chat/send",
        "/api/chat/mark-read",
        "/api/chat/unread-count",
        "/api/chat/merchant/conversations"
})
public class ChatAPI extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Vui lòng đăng nhập")));
            return;
        }

        String servletPath = req.getServletPath();

        // 1. Lấy hoặc tạo cuộc trò chuyện giữa user hiện tại và 1 quán ăn
        if ("/api/chat/conversation".equalsIgnoreCase(servletPath)) {
            String restIdParam = req.getParameter("restaurantId");
            if (restIdParam == null || restIdParam.isEmpty()) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu restaurantId")));
                return;
            }
            try {
                int restaurantId = Integer.parseInt(restIdParam);
                ChatConversation conv = chatDAO.getOrCreateConversation(currentUser.getId(), restaurantId);
                resp.getWriter().write(gson.toJson(Map.of("success", true, "conversation", conv)));
            } catch (Exception e) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "error", e.getMessage())));
            }
            return;
        }

        // 2. Lấy toàn bộ lịch sử tin nhắn của một cuộc hội thoại
        if ("/api/chat/messages".equalsIgnoreCase(servletPath)) {
            String convIdParam = req.getParameter("conversationId");
            if (convIdParam == null || convIdParam.isEmpty()) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu conversationId")));
                return;
            }
            try {
                int convId = Integer.parseInt(convIdParam);
                ChatConversation conv = chatDAO.getConversationById(convId);
                if (conv == null) {
                    resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Không tìm thấy cuộc hội thoại")));
                    return;
                }

                // Kiểm tra quyền truy cập (Người gửi là User hoặc Chủ quán)
                boolean isUserParticipant = conv.getUserId() == currentUser.getId();
                Restaurant rest = restaurantDAO.getRestaurantById(conv.getRestaurantId());
                boolean isSellerParticipant = rest != null && rest.getUserId() != null && rest.getUserId() == currentUser.getId();

                if (!isUserParticipant && !isSellerParticipant && !currentUser.isAdmin()) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Không có quyền xem cuộc trò chuyện này")));
                    return;
                }

                // Tự động mark read cho phía đang xem
                String readerRole = isSellerParticipant ? "SELLER" : "CUSTOMER";
                chatDAO.markAsRead(convId, readerRole);

                List<ChatMessage> messages = chatDAO.getMessages(convId);
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("conversation", conv);
                result.put("messages", messages);
                result.put("currentUserId", currentUser.getId());
                result.put("currentUserRole", readerRole);

                resp.getWriter().write(gson.toJson(result));
            } catch (Exception e) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "error", e.getMessage())));
            }
            return;
        }

        // 3. Lấy số lượng tin nhắn chưa đọc
        if ("/api/chat/unread-count".equalsIgnoreCase(servletPath)) {
            int unreadCount = 0;
            String type = req.getParameter("type"); // "user" hoặc "merchant"
            if ("merchant".equalsIgnoreCase(type)) {
                String restIdParam = req.getParameter("restaurantId");
                if (restIdParam != null && !restIdParam.isEmpty()) {
                    unreadCount = chatDAO.getMerchantUnreadCount(Integer.parseInt(restIdParam));
                }
            } else {
                unreadCount = chatDAO.getUserUnreadCount(currentUser.getId());
            }
            resp.getWriter().write(gson.toJson(Map.of("success", true, "unreadCount", unreadCount)));
            return;
        }

        // 4. Danh sách hội thoại của Merchant (quán)
        if ("/api/chat/merchant/conversations".equalsIgnoreCase(servletPath)) {
            String restIdParam = req.getParameter("restaurantId");
            if (restIdParam == null || restIdParam.isEmpty()) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu restaurantId")));
                return;
            }
            int restaurantId = Integer.parseInt(restIdParam);
            List<ChatConversation> list = chatDAO.getConversationsForMerchant(restaurantId);
            resp.getWriter().write(gson.toJson(Map.of("success", true, "conversations", list)));
            return;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Vui lòng đăng nhập")));
            return;
        }

        String servletPath = req.getServletPath();

        // Gửi tin nhắn mới
        if ("/api/chat/send".equalsIgnoreCase(servletPath)) {
            // Đọc body JSON hoặc parameters
            String convIdStr = req.getParameter("conversationId");
            String message = req.getParameter("message");
            String orderIdStr = req.getParameter("orderId");
            String senderRole = req.getParameter("senderRole"); // "CUSTOMER" hoặc "SELLER"

            // Nếu rỗng, thử đọc từ request body dạng JSON
            if (convIdStr == null || message == null) {
                StringBuilder sb = new StringBuilder();
                String line;
                try (BufferedReader reader = req.getReader()) {
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }
                if (sb.length() > 0) {
                    Map map = gson.fromJson(sb.toString(), Map.class);
                    if (map != null) {
                        if (map.get("conversationId") != null) convIdStr = String.valueOf(map.get("conversationId"));
                        if (map.get("message") != null) message = (String) map.get("message");
                        if (map.get("orderId") != null) orderIdStr = String.valueOf(map.get("orderId"));
                        if (map.get("senderRole") != null) senderRole = (String) map.get("senderRole");
                    }
                }
            }

            if (convIdStr == null || message == null || message.trim().isEmpty()) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Nội dung tin nhắn không được để trống")));
                return;
            }

            try {
                int convId = (int) Double.parseDouble(convIdStr);
                ChatConversation conv = chatDAO.getConversationById(convId);
                if (conv == null) {
                    resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Không tìm thấy hội thoại")));
                    return;
                }

                Restaurant rest = restaurantDAO.getRestaurantById(conv.getRestaurantId());
                boolean isSeller = (rest != null && rest.getUserId() != null && rest.getUserId() == currentUser.getId());

                if (senderRole == null || senderRole.isEmpty()) {
                    senderRole = isSeller ? "SELLER" : "CUSTOMER";
                }

                Integer orderId = null;
                if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                    orderId = (int) Double.parseDouble(orderIdStr);
                }

                ChatMessage newMsg = chatDAO.saveMessage(convId, currentUser.getId(), senderRole, message.trim(), orderId);
                if (newMsg != null) {
                    resp.getWriter().write(gson.toJson(Map.of("success", true, "message", newMsg)));
                } else {
                    resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Gửi tin nhắn thất bại")));
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write(gson.toJson(Map.of("success", false, "error", e.getMessage())));
            }
            return;
        }

        // Đánh dấu đã đọc
        if ("/api/chat/mark-read".equalsIgnoreCase(servletPath)) {
            String convIdStr = req.getParameter("conversationId");
            String readerRole = req.getParameter("readerRole");
            if (convIdStr != null) {
                int convId = Integer.parseInt(convIdStr);
                if (readerRole == null) readerRole = "CUSTOMER";
                chatDAO.markAsRead(convId, readerRole);
                resp.getWriter().write(gson.toJson(Map.of("success", true)));
            } else {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu conversationId")));
            }
        }
    }
}
