package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.dao.ChatDAO;
import com.ute.fooddelivery.model.ChatConversation;
import com.ute.fooddelivery.model.Restaurant;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "MerchantChatController", urlPatterns = {"/merchant/chat"})
public class MerchantChatController extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        List<ChatConversation> conversations = chatDAO.getConversationsForMerchant(restaurant.getId());
        req.setAttribute("conversations", conversations);

        // Nếu có chọn một cuộc hội thoại cụ thể
        String selectIdStr = req.getParameter("conversationId");
        if (selectIdStr != null && !selectIdStr.isEmpty()) {
            try {
                int convId = Integer.parseInt(selectIdStr);
                req.setAttribute("selectedConversationId", convId);
            } catch (Exception ignored) {}
        } else if (!conversations.isEmpty()) {
            req.setAttribute("selectedConversationId", conversations.get(0).getId());
        }

        req.getRequestDispatcher("/WEB-INF/views/merchant/chat.jsp").forward(req, resp);
    }
}
