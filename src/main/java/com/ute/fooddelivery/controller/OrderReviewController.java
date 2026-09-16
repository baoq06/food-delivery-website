package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.ReviewDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Review;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.utils.UploadUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet(name = "OrderReviewController", urlPatterns = {"/order-review", "/review"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 20
)
public class OrderReviewController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            String redirectUrl = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&redirect=" + java.net.URLEncoder.encode(redirectUrl, "UTF-8"));
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders");
            return;
        }

        Order order = orderDAO.getCustomerOrderForReview(orderId, currentUser.getId());
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=order_not_found");
            return;
        }

        // Chỉ cho phép đánh giá khi đơn hàng đã hoàn tất hoặc khách đã xác nhận nhận món
        boolean isEligible = "DELIVERED".equalsIgnoreCase(order.getStatus()) || 
                             order.isCustomerConfirmed() || 
                             order.isShipperDelivered();

        if (!isEligible) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=order_not_completed");
            return;
        }

        req.setAttribute("order", order);
        req.setAttribute("review", order.getReview());
        req.setAttribute("isReviewed", order.getReview() != null);

        // Flash message nếu vừa đánh giá thành công
        String success = req.getParameter("success");
        if ("review_submitted".equals(success)) {
            req.setAttribute("successMessage", "🎉 Cảm ơn bạn! Đánh giá đã được ghi nhận và gửi đến Quán ăn & Tài xế.");
        }

        req.getRequestDispatcher("/WEB-INF/views/client/order-review.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders");
            return;
        }

        Order order = orderDAO.getCustomerOrderForReview(orderId, currentUser.getId());
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/profile?tab=orders&error=order_not_found");
            return;
        }

        // Kiểm tra xem đơn đã được đánh giá chưa
        if (order.getReview() != null) {
            resp.sendRedirect(req.getContextPath() + "/order-review?orderId=" + orderId);
            return;
        }

        try {
            // Đọc số sao đánh giá món ăn (1-5)
            int foodRating = 5;
            try {
                String foodRStr = req.getParameter("foodRating");
                if (foodRStr != null && !foodRStr.trim().isEmpty()) {
                    foodRating = Math.max(1, Math.min(5, Integer.parseInt(foodRStr.trim())));
                }
            } catch (Exception ignored) {}

            // Đọc số sao đánh giá tài xế (1-5)
            int driverRating = 5;
            try {
                String driverRStr = req.getParameter("driverRating");
                if (driverRStr != null && !driverRStr.trim().isEmpty()) {
                    driverRating = Math.max(1, Math.min(5, Integer.parseInt(driverRStr.trim())));
                }
            } catch (Exception ignored) {}

            // Đọc nhận xét
            String foodComment = req.getParameter("foodComment");
            String driverComment = req.getParameter("driverComment");
            
            // Đọc các tag gợi ý chọn nhanh
            String[] foodTags = req.getParameterValues("foodTags");
            String[] driverTags = req.getParameterValues("driverTags");

            StringBuilder fullFoodComment = new StringBuilder();
            if (foodTags != null && foodTags.length > 0) {
                fullFoodComment.append("[").append(String.join(", ", foodTags)).append("] ");
            }
            if (foodComment != null && !foodComment.trim().isEmpty()) {
                fullFoodComment.append(foodComment.trim());
            }

            StringBuilder fullDriverComment = new StringBuilder();
            if (driverTags != null && driverTags.length > 0) {
                fullDriverComment.append("[").append(String.join(", ", driverTags)).append("] ");
            }
            if (driverComment != null && !driverComment.trim().isEmpty()) {
                fullDriverComment.append(driverComment.trim());
            }

            // Xử lý upload ảnh chụp món ăn (nếu khách hàng đính kèm)
            String imageUrl = null;
            try {
                Part reviewImagePart = req.getPart("reviewImage");
                if (reviewImagePart != null && reviewImagePart.getSize() > 0) {
                    imageUrl = UploadUtils.saveUploadedFile(reviewImagePart, "reviews", req);
                }
            } catch (Exception imgEx) {
                System.err.println("Lưu ý khi xử lý file upload ảnh review: " + imgEx.getMessage());
            }

            String finalFoodComment = fullFoodComment.toString().trim();
            String finalDriverComment = fullDriverComment.toString().trim();

            Review review = new Review();
            review.setOrderId(orderId);
            review.setCustomerId(currentUser.getId());
            review.setDriverId(order.getDriverId());
            review.setRestaurantId(order.getRestaurantId());
            review.setFoodRating(foodRating);
            review.setFoodComment(finalFoodComment);
            review.setDriverRating(driverRating);
            review.setDriverComment(finalDriverComment);
            review.setRating((foodRating + driverRating) / 2);
            review.setComment(finalFoodComment);
            review.setImageUrl(imageUrl);

            boolean success = reviewDAO.addReview(review);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/order-review?orderId=" + orderId + "&success=review_submitted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/order-review?orderId=" + orderId + "&error=save_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/order-review?orderId=" + orderId + "&error=save_failed");
        }
    }
}
