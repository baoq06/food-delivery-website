package com.ute.fooddelivery.controller.merchant;

import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.MerchantService;
import com.ute.fooddelivery.utils.UploadUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;

@WebServlet(name = "MerchantProfileController", urlPatterns = {"/merchant/profile"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class MerchantProfileController extends HttpServlet {
    private final MerchantService merchantService = new MerchantService();
    private final UserDAO userDAO = new UserDAO();

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

                // 1. Tải lên ảnh đại diện của chủ quán (lưu vào project folder)
                try {
                    Part ownerAvatarPart = req.getPart("ownerAvatarFile");
                    if (ownerAvatarPart != null && ownerAvatarPart.getSize() > 0) {
                        String uploadedAvatar = UploadUtils.saveUploadedFile(ownerAvatarPart, "avatars", req);
                        if (uploadedAvatar != null) {
                            User currentUser = (User) req.getSession().getAttribute("currentUser");
                            if (currentUser != null) {
                                currentUser.setAvatar(uploadedAvatar);
                                req.getSession().setAttribute("currentUser", currentUser);
                                userDAO.updateAvatar(currentUser.getId(), uploadedAvatar);
                            }
                        }
                    }
                } catch (Exception ignored) {}

                // 2. Tải lên logo của quán ăn (lưu vào project folder)
                try {
                    Part logoPart = req.getPart("logoFile");
                    if (logoPart != null && logoPart.getSize() > 0) {
                        String uploadedLogo = UploadUtils.saveUploadedFile(logoPart, "restaurants", req);
                        if (uploadedLogo != null) {
                            restaurant.setLogoUrl(uploadedLogo);
                        }
                    }
                } catch (Exception ignored) {}

                // 3. Tải lên ảnh banner quán ăn (lưu vào project folder)
                try {
                    Part bannerPart = req.getPart("bannerFile");
                    if (bannerPart != null && bannerPart.getSize() > 0) {
                        String uploadedBanner = UploadUtils.saveUploadedFile(bannerPart, "restaurants", req);
                        if (uploadedBanner != null) {
                            restaurant.setImageUrl(uploadedBanner);
                        }
                    }
                } catch (Exception ignored) {}

                if (name != null && !name.trim().isEmpty()) {
                    restaurant.setName(name.trim());
                    restaurant.setPhone(phone != null ? phone.trim() : "");
                    restaurant.setAddress(address != null ? address.trim() : "");
                    restaurant.setDescription(description != null ? description.trim() : "");

                    boolean success = merchantService.updateRestaurantProfile(restaurant);
                    if (success) {
                        req.getSession().setAttribute("flashMessage", "Đã cập nhật thông tin và hình ảnh quán thành công!");
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
