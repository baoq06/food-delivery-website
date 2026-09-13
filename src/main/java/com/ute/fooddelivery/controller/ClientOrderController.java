package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.ReviewDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Review;
import com.ute.fooddelivery.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/client/orders")
public class ClientOrderController extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        // Nếu là shipper và đang BẬT chế độ nhận đơn: chỉ xem lịch sử những đơn người đó giao
        if (currentUser.isShipper()) {
            com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
            com.ute.fooddelivery.model.Driver driver = driverDAO.getOrCreateDriverForUser(currentUser);
            boolean isShipperActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
            session.setAttribute("shipperActive", isShipperActive);
            session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
            if (isShipperActive) {
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?tab=history");
                return;
            }
        }

        List<Order> orders = orderDAO.getOrdersByUserId(currentUser.getId());
        req.setAttribute("orders", orders);

        req.getRequestDispatcher("/WEB-INF/views/client/order-history.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        if ("rate".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String dIdStr = req.getParameter("driverId");
                Integer driverId = (dIdStr != null && !dIdStr.trim().isEmpty() && !"0".equals(dIdStr.trim())) ? Integer.parseInt(dIdStr.trim()) : null;
                
                String foodRStr = req.getParameter("foodRating");
                String driverRStr = req.getParameter("driverRating");
                String overallRStr = req.getParameter("rating");

                int foodRating = (foodRStr != null && !foodRStr.isEmpty()) ? Integer.parseInt(foodRStr) : ((overallRStr != null && !overallRStr.isEmpty()) ? Integer.parseInt(overallRStr) : 5);
                int driverRating = (driverRStr != null && !driverRStr.isEmpty()) ? Integer.parseInt(driverRStr) : ((overallRStr != null && !overallRStr.isEmpty()) ? Integer.parseInt(overallRStr) : 5);

                String foodComment = req.getParameter("foodComment");
                String driverComment = req.getParameter("driverComment");
                String comment = req.getParameter("comment");

                if (foodComment == null || foodComment.trim().isEmpty()) foodComment = comment;
                if (driverComment == null || driverComment.trim().isEmpty()) driverComment = comment;

                Review review = new Review();
                review.setOrderId(orderId);
                review.setCustomerId(currentUser.getId());
                review.setDriverId(driverId);
                review.setFoodRating(foodRating);
                review.setFoodComment(foodComment);
                review.setDriverRating(driverRating);
                review.setDriverComment(driverComment);
                review.setRating((foodRating + driverRating) / 2);
                review.setComment(foodComment != null ? foodComment : driverComment);

                reviewDAO.addReview(review);
            } catch (Exception e) {
                e.printStackTrace();
            }
            resp.sendRedirect(req.getContextPath() + "/client/orders");
            return;
        }
        
        resp.sendRedirect(req.getContextPath() + "/client/orders");
    }
}
