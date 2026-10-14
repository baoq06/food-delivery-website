package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.FoodDAO;
import com.ute.fooddelivery.dao.UserVoucherDAO;
import com.ute.fooddelivery.dao.VoucherDAO;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.model.UserVoucher;
import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.RestaurantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@WebServlet(name = "RestaurantController", urlPatterns = {"/restaurant-detail", "/restaurant"})
public class RestaurantController extends HttpServlet {
    private final RestaurantService restaurantService = new RestaurantService();
    private final FoodDAO foodDAO = new FoodDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();
    private final UserVoucherDAO userVoucherDAO = new UserVoucherDAO();

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
                    List<Food> comboFoods = new ArrayList<>();
                    List<Food> regularFoods = new ArrayList<>();
                    for (Food f : foods) {
                        if (f.isCombo()) {
                            comboFoods.add(f);
                        } else {
                            regularFoods.add(f);
                        }
                    }
                    req.setAttribute("restaurant", restaurant);
                    req.setAttribute("foods", foods);
                    req.setAttribute("comboFoods", comboFoods);
                    req.setAttribute("regularFoods", regularFoods);

                    // Lấy danh sách voucher khuyến mãi đang hoạt động của quán ăn
                    List<Voucher> restaurantVouchers = voucherDAO.getActiveVouchersByRestaurant(id);
                    req.setAttribute("restaurantVouchers", restaurantVouchers);

                    // Kiểm tra các voucher người dùng đã lưu vào ví
                    HttpSession session = req.getSession(false);
                    User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
                    Set<String> claimedVoucherCodes = new HashSet<>();

                    if (currentUser != null && currentUser.getId() > 0) {
                        try {
                            List<UserVoucher> userVouchers = userVoucherDAO.getUserVouchers(currentUser.getId());
                            for (UserVoucher uv : userVouchers) {
                                if (uv.getQuantity() > 0) {
                                    claimedVoucherCodes.add(uv.getVoucherCode().toUpperCase(Locale.ROOT));
                                }
                            }
                        } catch (Exception e) {
                            System.err.println("Lỗi khi kiểm tra voucher đã lưu: " + e.getMessage());
                        }
                    }

                    req.setAttribute("claimedVoucherCodes", claimedVoucherCodes);

                    req.getRequestDispatcher("/WEB-INF/views/client/restaurant-detail.jsp").forward(req, resp);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
