package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.RestaurantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RestaurantController", urlPatterns = {"/restaurant-detail", "/restaurant"})
public class RestaurantController extends HttpServlet {
    private final RestaurantService restaurantService = new RestaurantService();
    private final FoodDAO foodDAO = new FoodDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Restaurant restaurant = restaurantService.getRestaurantById(id);
                if (restaurant != null) {
                    List<Food> foods = foodDAO.getFoodsByRestaurantId(id);
                    req.setAttribute("restaurant", restaurant);
                    req.setAttribute("foods", foods);

                    // Tặng mã giảm giá riêng của quán ăn khi khách hàng lần đầu (hoặc sau 7 ngày) ghé thăm
                    jakarta.servlet.http.HttpSession session = req.getSession(false);
                    com.ute.fooddelivery.model.User currentUser = session != null ? (com.ute.fooddelivery.model.User) session.getAttribute("currentUser") : null;
                    if (currentUser != null && currentUser.getId() > 0) {
                        try {
                            com.ute.fooddelivery.dao.UserVoucherDAO userVoucherDAO = new com.ute.fooddelivery.dao.UserVoucherDAO();
                            com.ute.fooddelivery.model.UserVoucher grantedVoucher = userVoucherDAO.grantRestaurantVoucherIfEligible(currentUser.getId(), restaurant);
                            if (grantedVoucher != null) {
                                req.setAttribute("grantedRestaurantVoucher", grantedVoucher);
                            }
                        } catch (Exception e) {
                            System.err.println("Lỗi khi tặng voucher quán ăn: " + e.getMessage());
                        }
                    } else {
                        // Khách chưa đăng nhập: gửi thông tin voucher ưu đãi của quán để hiển thị banner mời gọi
                        req.setAttribute("guestRestaurantPromoCode", "QUAN" + restaurant.getId() + "_20K");
                    }

                    req.getRequestDispatcher("/WEB-INF/views/client/restaurant-detail.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
