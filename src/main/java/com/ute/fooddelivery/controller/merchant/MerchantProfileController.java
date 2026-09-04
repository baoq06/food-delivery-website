package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MerchantProfileController", urlPatterns = {"/merchant/profile"})
public class MerchantProfileController extends HttpServlet {
    private final MerchantService merchantService = new MerchantService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/merchant/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Restaurant restaurant = (Restaurant) req.getAttribute("currentRestaurant");
        if (restaurant == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("toggleStatus".equalsIgnoreCase(action)) {
                String newStatus = "OPEN".equalsIgnoreCase(restaurant.getStatus()) ? "CLOSED" : "OPEN";
                merchantService.updateRestaurantStatus(restaurant.getId(), newStatus);
                restaurant.setStatus(newStatus);
                req.getSession().setAttribute("flashMessage", "Đã cập nhật trạng thái quán: " + ("OPEN".equals(newStatus) ? "Đang Mở Cửa" : "Tạm Đóng Cửa"));
            } else {
                String name = req.getParameter("name");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address");
                String description = req.getParameter("description");
                String imageUrl = req.getParameter("imageUrl");

                if (name != null && !name.trim().isEmpty()) {
                    restaurant.setName(name.trim());
                    restaurant.setPhone(phone != null ? phone.trim() : "");
                    restaurant.setAddress(address != null ? address.trim() : "");
                    restaurant.setDescription(description != null ? description.trim() : "");
                    restaurant.setImageUrl(imageUrl != null ? imageUrl.trim() : "");

                    boolean success = merchantService.updateRestaurantProfile(restaurant);
                    if (success) {
                        req.getSession().setAttribute("flashMessage", "Đã cập nhật thông tin quán thành công!");
                    } else {
                        req.getSession().setAttribute("flashError", "Cập nhật thông tin thất bại!");
                    }
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Có lỗi xảy ra: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/profile");
    }
}
