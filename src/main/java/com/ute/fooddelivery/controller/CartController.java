package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.CartItem;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.service.NotificationService;
import com.ute.fooddelivery.service.OrderService;
import com.ute.fooddelivery.utils.CookieUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {
    private final FoodService foodService = new FoodService();
    private final OrderService orderService = new OrderService();
    private final OrderDAO orderDAO = new OrderDAO();
    private final NotificationService notificationService = new NotificationService();
    private final DriverDAO driverDAO = new DriverDAO();
    private static final int DELI_COOKIE_AGE = 60 * 60 * 24 * 30; // 30 ngày

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser != null && currentUser.isSeller()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/error/404.jsp").forward(req, resp);
            return;
        }

        // Chặn shipper đang BẬT chế độ nhận đơn (không thể đặt hàng)
        if (currentUser != null && currentUser.isShipper()) {
            Driver driver = driverDAO.getOrCreateDriverForUser(currentUser);
            boolean isShipperActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
            if (session != null) {
                session.setAttribute("shipperActive", isShipperActive);
                session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
            }
            if (isShipperActive) {
                if (session != null) {
                    session.removeAttribute("cart");
                }
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?warning=shipper_mode_active");
                return;
            }
        }

        // Bắt buộc đăng nhập khi xem giỏ hàng / thông tin đặt hàng
        if (currentUser == null) {
            // Xóa triệt để các cookie thông tin giao hàng cũ trên trình duyệt nếu có
            CookieUtils.deleteCookie(resp, "deli_name");
            CookieUtils.deleteCookie(resp, "deli_phone");
            CookieUtils.deleteCookie(resp, "deli_address");
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/client/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser != null && currentUser.isSeller()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/error/404.jsp").forward(req, resp);
            return;
        }

        // Chặn shipper đang BẬT chế độ nhận đơn thêm món hoặc đặt hàng
        if (currentUser != null && currentUser.isShipper()) {
            Driver driver = driverDAO.getOrCreateDriverForUser(currentUser);
            boolean isShipperActive = (driver != null && !"OFFLINE".equalsIgnoreCase(driver.getStatus()));
            if (session != null) {
                session.setAttribute("shipperActive", isShipperActive);
                session.setAttribute("driverStatus", driver != null ? driver.getStatus() : "OFFLINE");
            }
            if (isShipperActive) {
                if (session != null) {
                    session.removeAttribute("cart");
                }
                resp.sendRedirect(req.getContextPath() + "/shipper/dashboard?warning=shipper_mode_active");
                return;
            }
        }

        String action = req.getParameter("action");

        // Nếu chưa đăng nhập: chặn mọi thao tác liên quan tới đơn hàng và yêu cầu đăng nhập/đăng ký
        if (currentUser == null) {
            session = req.getSession(true);
            if ("add".equalsIgnoreCase(action)) {
                try {
                    int foodId = Integer.parseInt(req.getParameter("foodId"));
                    int quantity = 1;
                    String qtyParam = req.getParameter("quantity");
                    if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                        quantity = Integer.parseInt(qtyParam.trim());
                    }
                    session.setAttribute("pendingFoodId", foodId);
                    session.setAttribute("pendingQuantity", quantity);
                } catch (Exception ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }
        session = req.getSession();

        @SuppressWarnings("unchecked")
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        if ("add".equalsIgnoreCase(action)) {
            try {
                int foodId = Integer.parseInt(req.getParameter("foodId"));
                int quantity = 1;
                String qtyParam = req.getParameter("quantity");
                if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                    quantity = Integer.parseInt(qtyParam.trim());
                }

                if (cart.containsKey(foodId)) {
                    CartItem item = cart.get(foodId);
                    item.setQuantity(item.getQuantity() + quantity);
                } else {
                    Food food = foodService.getFoodById(foodId);
                    if (food != null) {
                        cart.put(foodId, new CartItem(food, quantity));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            session.setAttribute("cart", cart);
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        } else if ("remove".equalsIgnoreCase(action)) {
            try {
                int foodId = Integer.parseInt(req.getParameter("foodId"));
                cart.remove(foodId);
            } catch (Exception e) {
                e.printStackTrace();
            }
            session.setAttribute("cart", cart);
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        } else if ("checkout".equalsIgnoreCase(action)) {
            if (!cart.isEmpty()) {
                String receiverName = req.getParameter("receiverName");
                String receiverPhone = req.getParameter("receiverPhone");
                String receiverAddress = req.getParameter("receiverAddress");
                String receiverNote = req.getParameter("receiverNote");
                String paymentMethod = req.getParameter("paymentMethod");

                // Sticky Form Validation
                String validationError = null;
                if (receiverName == null || receiverName.trim().isEmpty() ||
                    receiverPhone == null || receiverPhone.trim().isEmpty() ||
                    receiverAddress == null || receiverAddress.trim().isEmpty()) {
                    validationError = "Vui lòng nhập đầy đủ: Họ tên, Số điện thoại và Địa chỉ giao hàng!";
                } else if (!receiverPhone.trim().matches("^0[0-9]{9,10}$")) {
                    validationError = "Số điện thoại nhận hàng không hợp lệ! Vui lòng nhập số điện thoại Việt Nam (10-11 chữ số bắt đầu bằng số 0).";
                }

                if (validationError != null) {
                    req.setAttribute("checkoutError", validationError);
                    // Giữ lại dữ liệu vừa nhập (Sticky Form)
                    req.setAttribute("stickyReceiverName", receiverName);
                    req.setAttribute("stickyReceiverPhone", receiverPhone);
                    req.setAttribute("stickyReceiverAddress", receiverAddress);
                    req.setAttribute("stickyReceiverNote", receiverNote);
                    req.setAttribute("stickyPaymentMethod", paymentMethod);
                    req.getRequestDispatcher("/WEB-INF/views/client/cart.jsp").forward(req, resp);
                    return;
                }

                double subtotalBill = 0;
                List<OrderItem> items = new ArrayList<>();
                for (CartItem ci : cart.values()) {
                    subtotalBill += ci.getTotalPrice();
                    items.add(new OrderItem(
                        ci.getFood().getId(),
                        ci.getFood().getName(),
                        ci.getFood().getImage(),
                        ci.getQuantity(),
                        ci.getFood().getPrice(),
                        ci.getTotalPrice()
                    ));
                }

                double shippingFee = 15000;
                double totalBill = subtotalBill + shippingFee;

                Integer userId = currentUser.getId();

                Order order = new Order();
                order.setUserId(userId);
                order.setCustomerName(receiverName.trim());
                order.setPhone(receiverPhone.trim());
                order.setAddress(receiverAddress.trim());
                order.setNote(receiverNote != null ? receiverNote.trim() : "");
                order.setTotalAmount(totalBill);
                order.setPaymentMethod(paymentMethod != null ? paymentMethod : "COD");

                int orderId = orderService.createOrder(order, items);
                if (orderId > 0) {
                    // Tự động gửi thông báo tức thì đến Chủ quán ăn (Merchant)
                    try {
                        Integer merchantUserId = orderDAO.getMerchantUserIdByOrderId(orderId);
                        if (merchantUserId != null) {
                            notificationService.notifyNewOrderToMerchant(merchantUserId, orderId, order.getCustomerName(), order.getTotalAmount());
                        }
                    } catch (Exception e) {
                        System.err.println("Lỗi khi gửi thông báo đơn mới đến chủ quán: " + e.getMessage());
                    }

                    // Xóa các cookie giao hàng cũ (nếu có) để bảo mật thông tin tài khoản
                    CookieUtils.deleteCookie(resp, "deli_name");
                    CookieUtils.deleteCookie(resp, "deli_phone");
                    CookieUtils.deleteCookie(resp, "deli_address");

                    session.removeAttribute("cart");
                    req.setAttribute("placedOrderId", "#DH-" + orderId);
                    req.setAttribute("orderSuccess", true);
                    req.getRequestDispatcher("/WEB-INF/views/client/cart.jsp").forward(req, resp);
                    return;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}
