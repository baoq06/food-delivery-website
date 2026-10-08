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
    private final com.ute.fooddelivery.dao.DriverDAO driverDAO = new com.ute.fooddelivery.dao.DriverDAO();
    private final com.ute.fooddelivery.dao.RestaurantDAO restaurantDAO = new com.ute.fooddelivery.dao.RestaurantDAO();

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
        } else if ("banDriver".equals(action)) {
            String phone = req.getParameter("phone");
            String idParam = req.getParameter("driverId");
            boolean ok = false;
            if (phone != null && !phone.trim().isEmpty()) {
                ok = driverDAO.banDriverByPhone(phone.trim());
            } else if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int dId = Integer.parseInt(idParam.trim());
                    ok = driverDAO.updateStatus(dId, "BANNED");
                } catch (Exception ignored) {}
            }
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=shippers&msg=banned_driver" + (phone != null ? "&phone=" + java.net.URLEncoder.encode(phone.trim(), "UTF-8") : ""));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=shippers&error=ban_failed");
            }
            return;
        } else if ("unbanDriver".equals(action)) {
            String phone = req.getParameter("phone");
            String idParam = req.getParameter("driverId");
            boolean ok = false;
            if (phone != null && !phone.trim().isEmpty()) {
                ok = driverDAO.unbanDriverByPhone(phone.trim());
            } else if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int dId = Integer.parseInt(idParam.trim());
                    ok = driverDAO.updateStatus(dId, "OFFLINE");
                } catch (Exception ignored) {}
            }
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=shippers&msg=unbanned_driver" + (phone != null ? "&phone=" + java.net.URLEncoder.encode(phone.trim(), "UTF-8") : ""));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=shippers&error=unban_failed");
            }
            return;
        } else if ("banRestaurant".equals(action)) {
            String phone = req.getParameter("phone");
            String idParam = req.getParameter("restaurantId");
            boolean ok = false;
            if (phone != null && !phone.trim().isEmpty()) {
                ok = restaurantDAO.banRestaurantByPhone(phone.trim());
            } else if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int rId = Integer.parseInt(idParam.trim());
                    ok = restaurantDAO.updateStatus(rId, "BANNED");
                } catch (Exception ignored) {}
            }
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=restaurants&msg=banned_restaurant" + (phone != null ? "&phone=" + java.net.URLEncoder.encode(phone.trim(), "UTF-8") : ""));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=restaurants&error=ban_failed");
            }
            return;
        } else if ("unbanRestaurant".equals(action)) {
            String phone = req.getParameter("phone");
            String idParam = req.getParameter("restaurantId");
            boolean ok = false;
            if (phone != null && !phone.trim().isEmpty()) {
                ok = restaurantDAO.unbanRestaurantByPhone(phone.trim());
            } else if (idParam != null && !idParam.trim().isEmpty()) {
                try {
                    int rId = Integer.parseInt(idParam.trim());
                    ok = restaurantDAO.updateStatus(rId, "OPEN");
                } catch (Exception ignored) {}
            }
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=restaurants&msg=unbanned_restaurant" + (phone != null ? "&phone=" + java.net.URLEncoder.encode(phone.trim(), "UTF-8") : ""));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=restaurants&error=unban_failed");
            }
            return;
        } else if ("banByPhone".equals(action)) {
            String targetType = req.getParameter("targetType");
            String phone = req.getParameter("phone");
            String banAction = req.getParameter("banAction");
            String tab = "SHIPPER".equalsIgnoreCase(targetType) ? "shippers" : "restaurants";

            if (phone == null || phone.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=" + tab + "&error=empty_phone");
                return;
            }
            phone = phone.trim();
            boolean isBan = !"UNBAN".equalsIgnoreCase(banAction);

            boolean success = false;
            if ("SHIPPER".equalsIgnoreCase(targetType)) {
                success = isBan ? driverDAO.banDriverByPhone(phone) : driverDAO.unbanDriverByPhone(phone);
            } else {
                success = isBan ? restaurantDAO.banRestaurantByPhone(phone) : restaurantDAO.unbanRestaurantByPhone(phone);
            }

            if (success) {
                String msgKey = (isBan ? "banned_" : "unbanned_") + ("SHIPPER".equalsIgnoreCase(targetType) ? "driver" : "restaurant");
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=" + tab + "&msg=" + msgKey + "&phone=" + java.net.URLEncoder.encode(phone, "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=" + tab + "&error=phone_not_found&phone=" + java.net.URLEncoder.encode(phone, "UTF-8"));
            }
            return;
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

        // Xử lý tìm kiếm theo tab
        String tab = req.getParameter("tab");
        String search = req.getParameter("search");
        if (search == null || search.trim().isEmpty()) {
            search = req.getParameter("q"); // Hỗ trợ cả param q
        }

        if ("shippers".equals(tab)) {
            if (search != null && !search.trim().isEmpty()) {
                req.setAttribute("allDrivers", driverDAO.searchDrivers(search.trim()));
                req.setAttribute("searchKeyword", search.trim());
            } else {
                req.setAttribute("allDrivers", driverDAO.getAllDrivers());
            }
            req.setAttribute("allRestaurants", restaurantDAO.getAllRestaurants());
        } else if ("restaurants".equals(tab)) {
            if (search != null && !search.trim().isEmpty()) {
                req.setAttribute("allRestaurants", restaurantDAO.searchRestaurants(search.trim()));
                req.setAttribute("searchKeyword", search.trim());
            } else {
                req.setAttribute("allRestaurants", restaurantDAO.getAllRestaurants());
            }
            req.setAttribute("allDrivers", driverDAO.getAllDrivers());
        } else {
            req.setAttribute("allDrivers", driverDAO.getAllDrivers());
            req.setAttribute("allRestaurants", restaurantDAO.getAllRestaurants());
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        doGet(req, resp);
    }
}

