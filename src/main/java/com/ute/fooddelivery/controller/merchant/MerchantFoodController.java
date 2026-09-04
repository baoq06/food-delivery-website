package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Category;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.CategoryService;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "MerchantFoodController", urlPatterns = {"/merchant/foods"})
public class MerchantFoodController extends HttpServlet {
    private final MerchantService merchantService = new MerchantService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        int restaurantId = restaurant.getId();
        List<Food> foods = merchantService.getFoods(restaurantId);

        // Lọc theo từ khóa tìm kiếm nếu có
        String keyword = req.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            String lower = keyword.trim().toLowerCase();
            foods = foods.stream()
                .filter(f -> f.getName().toLowerCase().contains(lower) || 
                             (f.getDescription() != null && f.getDescription().toLowerCase().contains(lower)))
                .collect(Collectors.toList());
            req.setAttribute("keyword", keyword.trim());
        }

        // Lọc theo danh mục nếu có
        String catIdParam = req.getParameter("categoryId");
        if (catIdParam != null && !catIdParam.trim().isEmpty() && !"ALL".equalsIgnoreCase(catIdParam)) {
            try {
                int catId = Integer.parseInt(catIdParam.trim());
                foods = foods.stream().filter(f -> f.getCategoryId() == catId).collect(Collectors.toList());
                req.setAttribute("selectedCategoryId", catId);
            } catch (Exception ignored) {}
        }

        List<Category> categories = categoryService.getAllCategories();
        req.setAttribute("foods", foods);
        req.setAttribute("categories", categories);

        req.getRequestDispatcher("/WEB-INF/views/merchant/foods.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        int restaurantId = restaurant.getId();
        String action = req.getParameter("action");

        try {
            if ("add".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String priceStr = req.getParameter("price");
                String catIdStr = req.getParameter("categoryId");
                String description = req.getParameter("description");
                String imageUrl = req.getParameter("imageUrl");
                boolean isAvailable = req.getParameter("isAvailable") != null;

                if (name != null && !name.trim().isEmpty() && priceStr != null && catIdStr != null) {
                    double price = Double.parseDouble(priceStr.trim());
                    int categoryId = Integer.parseInt(catIdStr.trim());

                    if (imageUrl == null || imageUrl.trim().isEmpty()) {
                        imageUrl = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80";
                    }

                    Food newFood = new Food(
                        0,
                        name.trim(),
                        description != null ? description.trim() : "",
                        price,
                        imageUrl.trim(),
                        categoryId,
                        "",
                        restaurantId,
                        restaurant.getName(),
                        isAvailable
                    );

                    boolean success = merchantService.addFood(newFood);
                    if (success) {
                        req.getSession().setAttribute("flashMessage", "Đã đăng món ăn '" + name.trim() + "' thành công!");
                    } else {
                        req.getSession().setAttribute("flashError", "Không thể thêm món ăn, vui lòng thử lại!");
                    }
                }
            } else if ("update".equalsIgnoreCase(action)) {
                int foodId = Integer.parseInt(req.getParameter("foodId"));
                String name = req.getParameter("name");
                double price = Double.parseDouble(req.getParameter("price"));
                int categoryId = Integer.parseInt(req.getParameter("categoryId"));
                String description = req.getParameter("description");
                String imageUrl = req.getParameter("imageUrl");
                boolean isAvailable = req.getParameter("isAvailable") != null;

                Food food = new Food(
                    foodId,
                    name.trim(),
                    description != null ? description.trim() : "",
                    price,
                    imageUrl != null ? imageUrl.trim() : "",
                    categoryId,
                    "",
                    restaurantId,
                    restaurant.getName(),
                    isAvailable
                );

                boolean success = merchantService.updateFood(food);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã cập nhật món '" + name.trim() + "' thành công!");
                } else {
                    req.getSession().setAttribute("flashError", "Cập nhật thất bại, vui lòng thử lại!");
                }
            } else if ("delete".equalsIgnoreCase(action)) {
                int foodId = Integer.parseInt(req.getParameter("foodId"));
                boolean success = merchantService.deleteFood(foodId, restaurantId);
                if (success) {
                    req.getSession().setAttribute("flashMessage", "Đã xóa / tạm dừng hiển thị món thành công!");
                } else {
                    req.getSession().setAttribute("flashError", "Không thể xóa món này!");
                }
            } else if ("toggle".equalsIgnoreCase(action)) {
                int foodId = Integer.parseInt(req.getParameter("foodId"));
                boolean newStatus = Boolean.parseBoolean(req.getParameter("status"));
                merchantService.toggleFoodAvailability(foodId, restaurantId, newStatus);
                req.getSession().setAttribute("flashMessage", "Đã đổi trạng thái món sang: " + (newStatus ? "Còn món" : "Tạm hết món"));
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/foods");
    }
}
