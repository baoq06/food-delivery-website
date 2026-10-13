package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.Category;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.service.RestaurantService;
import com.ute.fooddelivery.utils.CookieUtils;
import com.ute.fooddelivery.utils.GeoLocationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "HomeController", urlPatterns = {"", "/home", "/nearby"})
public class HomeController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final CategoryService categoryService = new CategoryService();
    private final RestaurantService restaurantService = new RestaurantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String servletPath = req.getServletPath();
        String tab = req.getParameter("tab");
        if ("/nearby".equals(servletPath)) {
            tab = "nearby";
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) 
                ? (User) session.getAttribute("currentUser") 
                : null;
        boolean isGuest = (currentUser == null || currentUser.getId() <= 0);

        if (tab == null || tab.trim().isEmpty()) {
            tab = isGuest ? "bestseller" : "foryou";
        } else if (isGuest && "foryou".equalsIgnoreCase(tab)) {
            tab = "bestseller";
        }

        // Xác định địa chỉ người dùng để tính khoảng cách tới các quán ăn
        String userAddress = null;
        if (currentUser != null && currentUser.getAddress() != null && !currentUser.getAddress().trim().isEmpty()) {
            userAddress = currentUser.getAddress().trim();
        }
        if (userAddress == null || userAddress.isEmpty()) {
            String sessionAddr = (session != null) ? (String) session.getAttribute("deli_address") : null;
            if (sessionAddr != null && !sessionAddr.trim().isEmpty()) {
                userAddress = sessionAddr.trim();
            } else {
                String cookieAddr = CookieUtils.getCookieValue(req, "deli_address");
                if (cookieAddr != null && !cookieAddr.trim().isEmpty()) {
                    userAddress = cookieAddr.trim();
                }
            }
        }
        if (userAddress == null || userAddress.isEmpty()) {
            userAddress = "1 Võ Văn Ngân, Linh Chiểu, Thủ Đức, TP. Hồ Chí Minh";
        }
        double[] userCoords = GeoLocationUtils.getCoordinatesForAddress(userAddress);

        List<Food> tabFoods;
        List<Restaurant> tabRestaurants;

        if ("nearby".equalsIgnoreCase(tab)) {
            // Tab 'Gần đây':
            // - Tính khoảng cách giữa địa chỉ người dùng và địa chỉ quán qua OSRM API bên ngoài
            // - Quán nào càng gần thì càng xuất hiện đầu
            // - Trong cùng 1 quán thì món nào có nhiều người mua hơn thì xuất hiện trước
            tab = "nearby";
            tabFoods = foodService.getNearbyFoods(userCoords[0], userCoords[1], 16);
            tabRestaurants = restaurantService.getNearbyRestaurants(userCoords[0], userCoords[1], 9);
        } else if ("toprated".equalsIgnoreCase(tab)) {
            // Tab 'Đánh giá cao': Lấy các món ăn và quán ăn có rating cao nhất từ dữ liệu thật
            tabFoods = foodService.getTopRatedFoods(12);
            tabRestaurants = restaurantService.getTopRatedRestaurants(9);
        } else if ("bestseller".equalsIgnoreCase(tab)) {
            // Tab 'Bán chạy': Lấy các món ăn và quán ăn bán chạy nhất từ dữ liệu thật
            tabFoods = foodService.getBestSellingFoods(12);
            tabRestaurants = restaurantService.getBestSellingRestaurants(9);
        } else {
            // Tab 'Cho bạn' (mặc định):
            // - Các món ban đầu dựa vào các món khách đó đặt gần nhất (ví dụ: gần nhất khách đặt cơm sườn -> ra các món cơm)
            // - Các món tiếp theo dựa vào các món khách đặt gần nhì, ba...
            tab = "foryou";
            tabFoods = java.util.Collections.emptyList();


            if (currentUser != null && currentUser.getId() > 0) {
                tabFoods = foodService.getRecommendedFoodsForUser(currentUser.getId(), 12);
            }

            // Nếu người dùng chưa có đơn hàng hoặc chưa đăng nhập, thử gợi ý dựa trên món xem gần đây (cookie)
            if (tabFoods == null || tabFoods.isEmpty()) {
                String cookieName = CookieUtils.getRecentFoodsCookieName(req);
                String recentCookie = CookieUtils.getCookieValue(req, cookieName);
                List<Integer> idList = CookieUtils.parseIdList(recentCookie);
                if (!idList.isEmpty()) {
                    tabFoods = foodService.getRecommendedFoodsByRecentIds(idList, 12);
                }
            }

            if (tabFoods == null) {
                tabFoods = java.util.Collections.emptyList();
            }

            if (!tabFoods.isEmpty()) {
                tabRestaurants = restaurantService.getTopRatedRestaurants(9);
            } else {
                tabRestaurants = java.util.Collections.emptyList();
            }
        }

        req.setAttribute("activeTab", tab);
        req.setAttribute("tabFoods", tabFoods);
        req.setAttribute("tabRestaurants", tabRestaurants);
        req.setAttribute("userAddress", userAddress);
        List<Category> allCategories = categoryService.getAllCategories();
        List<Category> mainCategories = (allCategories != null)
                ? allCategories.stream()
                    .filter(c -> c.getName() != null && !c.getName().toLowerCase().contains("combo") && c.getId() != 60002)
                    .collect(Collectors.toList())
                : java.util.Collections.emptyList();
        req.setAttribute("categories", mainCategories);

        // Dọn dẹp cookie dùng chung cũ nếu còn sót
        CookieUtils.cleanLegacyRecentFoods(req, resp);

        // Lấy danh sách món vừa xem gần đây theo từng tài khoản (hoặc khách vãng lai riêng)
        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
        String recentCookie = CookieUtils.getCookieValue(req, cookieName);
        List<Integer> idList = CookieUtils.parseIdList(recentCookie);
        if (!idList.isEmpty()) {
            List<Food> recentFoods = foodService.getFoodsByIds(idList);
            req.setAttribute("recentFoods", recentFoods);
        }

        req.getRequestDispatcher("/WEB-INF/views/client/home.jsp").forward(req, resp);
    }
}
