package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();
<<<<<<< Updated upstream
=======
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();
    private final com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
    private final com.ute.fooddelivery.dao.RestaurantDAO restaurantDAO = new com.ute.fooddelivery.dao.RestaurantDAO();
>>>>>>> Stashed changes

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
<<<<<<< Updated upstream
        req.setAttribute("foodCount", foodService.getAllFoods().size());
        req.setAttribute("categoryCount", categoryService.getAllCategories().size());
=======
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

        // 1. Doanh thu của Admin: 10% giá trị món ăn của các đơn hoàn tất DELIVERED (không tính phí ship)
        double adminRevenue = orderDAO.getAdminCommissionRevenue();
        double totalFoodValue = orderDAO.getTotalDeliveredFoodValue();

        // 2. Thống kê đơn hàng thực tế
        Map<String, Integer> orderStats = orderDAO.getOrderStatusCounts();

        // 3. Thống kê món ăn & danh mục thực tế
        int foodCount = foodService.getAllFoods().size();
        int categoryCount = categoryService.getAllCategories().size();

        // 4. Thống kê tài khoản người dùng thực tế
        Map<String, Integer> userStats = userDAO.getUserStats();

        // 5. Danh sách đơn đặt hàng thực tế gần đây
        List<Order> recentOrders = orderDAO.getRecentOrdersForAdmin(20);

        req.setAttribute("adminRevenue", adminRevenue);
        req.setAttribute("totalRevenue", adminRevenue);
        req.setAttribute("totalFoodValue", totalFoodValue);
        req.setAttribute("orderStats", orderStats);
        req.setAttribute("foodCount", foodCount);
        req.setAttribute("categoryCount", categoryCount);
        req.setAttribute("userStats", userStats);
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("allDrivers", driverDAO.getAllDrivers());
        req.setAttribute("allRestaurants", restaurantDAO.getAllRestaurants());

>>>>>>> Stashed changes
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
