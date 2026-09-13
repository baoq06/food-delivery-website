package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("approve".equals(action)) {
            String orderIdParam = req.getParameter("orderId");
            if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
                try {
                    int orderId = Integer.parseInt(orderIdParam.trim());
                    orderDAO.updateOrderStatus(orderId, "CONFIRMED");
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard?msg=approved");
                    return;
                } catch (NumberFormatException e) {
                    System.err.println("Mã đơn không hợp lệ: " + orderIdParam);
                }
            }
        }

        // 1. Doanh thu thực tế (các đơn đã hoàn thành DELIVERED)
        double totalRevenue = orderDAO.getTotalDeliveredRevenue();

        // 2. Thống kê đơn hàng thực tế
        Map<String, Integer> orderStats = orderDAO.getOrderStatusCounts();

        // 3. Thống kê món ăn & danh mục thực tế
        int foodCount = foodService.getAllFoods().size();
        int categoryCount = categoryService.getAllCategories().size();

        // 4. Thống kê tài khoản người dùng thực tế
        Map<String, Integer> userStats = userDAO.getUserStats();

        // 5. Danh sách đơn đặt hàng thực tế gần đây
        List<Order> recentOrders = orderDAO.getRecentOrdersForAdmin(20);

        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("orderStats", orderStats);
        req.setAttribute("foodCount", foodCount);
        req.setAttribute("categoryCount", categoryCount);
        req.setAttribute("userStats", userStats);
        req.setAttribute("recentOrders", recentOrders);

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}

