package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.utils.CsrfUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
    private final com.ute.fooddelivery.service.NotificationService notificationService = new com.ute.fooddelivery.service.NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !currentUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=unauthorized");
            return;
        }

        // Đảm bảo CSRF token luôn sẵn sàng trong session và request attribute
        String csrfToken = CsrfUtils.getOrCreateToken(session);
        req.setAttribute("csrfToken", csrfToken);

        // BẢO MẬT & CHỐNG KÍCH HOẠT NGẦM:
        // Chặn tuyệt đối mọi thao tác thay đổi dữ liệu/trạng thái qua HTTP GET
        String action = req.getParameter("action");
        if (action != null && !action.trim().isEmpty()) {
            String tab = req.getParameter("tab");
            String redirectUrl = req.getContextPath() + "/admin/dashboard?error=method_not_allowed"
                    + (tab != null && !tab.trim().isEmpty() ? "&tab=" + java.net.URLEncoder.encode(tab.trim(), "UTF-8") : "");
            resp.sendRedirect(redirectUrl);
            return;
        }

        // 1. Doanh thu của Admin: 10% giá trị món ăn của các đơn hoàn tất DELIVERED (không tính phí ship)
        double adminRevenue = orderDAO.getAdminCommissionRevenue();
        double totalFoodValue = orderDAO.getTotalDeliveredFoodValue();

        // 2. Thống kê đơn hàng thực tế
        Map<String, Integer> orderStats = orderDAO.getOrderStatusCounts();
        if (orderStats == null) {
            orderStats = new java.util.HashMap<>();
        }

        // 3. Thống kê món ăn & danh mục thực tế (an toàn null-pointer)
        List<com.ute.fooddelivery.model.Food> allFoods = foodService.getAllFoods();
        int foodCount = allFoods != null ? allFoods.size() : 0;
        List<com.ute.fooddelivery.model.Category> allCategories = categoryService.getAllCategories();
        int categoryCount = allCategories != null ? allCategories.size() : 0;

        // 4. Thống kê tài khoản người dùng thực tế
        Map<String, Integer> userStats = userDAO.getUserStats();
        if (userStats == null) {
            userStats = new java.util.HashMap<>();
        }

        // 5. Danh sách đơn đặt hàng thực tế gần đây
        List<Order> recentOrders = orderDAO.getRecentOrdersForAdmin(20);
        if (recentOrders == null) {
            recentOrders = new java.util.ArrayList<>();
        }

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

        List<com.ute.fooddelivery.model.Driver> defaultDrivers = driverDAO.getAllDrivers();
        if (defaultDrivers == null) defaultDrivers = new java.util.ArrayList<>();

        List<com.ute.fooddelivery.model.Restaurant> defaultRestaurants = restaurantDAO.getAllRestaurants();
        if (defaultRestaurants == null) defaultRestaurants = new java.util.ArrayList<>();

        List<com.ute.fooddelivery.model.User> defaultCustomers = userDAO.getCustomersForCodManagement(null);
        if (defaultCustomers == null) defaultCustomers = new java.util.ArrayList<>();

        int lockedCustomerCount = 0;
        for (User u : defaultCustomers) {
            if (u.isCodLocked()) {
                lockedCustomerCount++;
            }
        }
        req.setAttribute("lockedCustomerCount", lockedCustomerCount);

        if ("shippers".equals(tab)) {
            if (search != null && !search.trim().isEmpty()) {
                List<com.ute.fooddelivery.model.Driver> sDrivers = driverDAO.searchDrivers(search.trim());
                req.setAttribute("allDrivers", sDrivers != null ? sDrivers : new java.util.ArrayList<>());
                req.setAttribute("searchKeyword", search.trim());
            } else {
                req.setAttribute("allDrivers", defaultDrivers);
            }
            req.setAttribute("allRestaurants", defaultRestaurants);
            req.setAttribute("allCustomers", defaultCustomers);
        } else if ("restaurants".equals(tab)) {
            if (search != null && !search.trim().isEmpty()) {
                List<com.ute.fooddelivery.model.Restaurant> sRests = restaurantDAO.searchRestaurants(search.trim());
                req.setAttribute("allRestaurants", sRests != null ? sRests : new java.util.ArrayList<>());
                req.setAttribute("searchKeyword", search.trim());
            } else {
                req.setAttribute("allRestaurants", defaultRestaurants);
            }
            req.setAttribute("allDrivers", defaultDrivers);
            req.setAttribute("allCustomers", defaultCustomers);
        } else if ("customers".equals(tab)) {
            if (search != null && !search.trim().isEmpty()) {
                List<com.ute.fooddelivery.model.User> sCusts = userDAO.getCustomersForCodManagement(search.trim());
                req.setAttribute("allCustomers", sCusts != null ? sCusts : new java.util.ArrayList<>());
                req.setAttribute("searchKeyword", search.trim());
            } else {
                req.setAttribute("allCustomers", defaultCustomers);
            }
            req.setAttribute("allDrivers", defaultDrivers);
            req.setAttribute("allRestaurants", defaultRestaurants);
        } else {
            req.setAttribute("allDrivers", defaultDrivers);
            req.setAttribute("allRestaurants", defaultRestaurants);
            req.setAttribute("allCustomers", defaultCustomers);
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null || !currentUser.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=unauthorized");
            return;
        }

        // BẢO MẬT: Kiểm tra tính hợp lệ của CSRF Token
        if (!CsrfUtils.validate(req)) {
            String tab = req.getParameter("tab");
            String redirectUrl = req.getContextPath() + "/admin/dashboard?error=csrf_invalid"
                    + (tab != null && !tab.trim().isEmpty() ? "&tab=" + java.net.URLEncoder.encode(tab.trim(), "UTF-8") : "");
            resp.sendRedirect(redirectUrl);
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        if ("deleteAllOrders".equals(action)) {
            boolean ok = orderDAO.deleteAllOrders();
            if (ok) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?msg=all_orders_deleted");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=delete_orders_failed");
            }
        } else if ("approve".equals(action)) {
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
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=invalid_order");
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
        } else if ("unlockCustomerCod".equals(action)) {
            String userIdParam = req.getParameter("userId");
            String phoneParam = req.getParameter("phone");
            boolean ok = false;
            Integer targetUserId = null;

            if (userIdParam != null && !userIdParam.trim().isEmpty()) {
                try {
                    int uId = Integer.parseInt(userIdParam.trim());
                    targetUserId = uId;
                    ok = userDAO.unlockCustomerCod(uId);
                } catch (Exception ignored) {}
            } else if (phoneParam != null && !phoneParam.trim().isEmpty()) {
                phoneParam = phoneParam.trim();
                ok = userDAO.unlockCustomerCodByPhone(phoneParam);
                User targetUser = userDAO.getUserByPhone(phoneParam);
                if (targetUser != null) {
                    targetUserId = targetUser.getId();
                }
            }

            if (ok) {
                if (targetUserId != null && targetUserId > 0) {
                    notificationService.notifyCodUnlockedByAdmin(targetUserId);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=customers&msg=customer_cod_unlocked" + (phoneParam != null ? "&phone=" + java.net.URLEncoder.encode(phoneParam, "UTF-8") : ""));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=customers&error=unlock_failed");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?error=invalid_action");
        }
    }
}

