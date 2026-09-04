package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.model.CartItem;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.FoodService;
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
    private static final int DELI_COOKIE_AGE = 60 * 60 * 24 * 30; // 30 ngày

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Đọc thông tin nhận hàng đã lưu từ Cookie (nếu có)
        String deliName = CookieUtils.getCookieValue(req, "deli_name");
        String deliPhone = CookieUtils.getCookieValue(req, "deli_phone");
        String deliAddress = CookieUtils.getCookieValue(req, "deli_address");

        if (deliName != null) req.setAttribute("cookieDeliName", deliName);
        if (deliPhone != null) req.setAttribute("cookieDeliPhone", deliPhone);
        if (deliAddress != null) req.setAttribute("cookieDeliAddress", deliAddress);

        req.getRequestDispatcher("/WEB-INF/views/client/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

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

                User currentUser = (User) session.getAttribute("currentUser");
                Integer userId = (currentUser != null) ? currentUser.getId() : null;

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
                    // Lưu thông tin nhận hàng vào Cookie (30 ngày) để lần sau tự điền
                    CookieUtils.addCookie(resp, "deli_name", receiverName.trim(), DELI_COOKIE_AGE);
                    CookieUtils.addCookie(resp, "deli_phone", receiverPhone.trim(), DELI_COOKIE_AGE);
                    CookieUtils.addCookie(resp, "deli_address", receiverAddress.trim(), DELI_COOKIE_AGE);

                    session.removeAttribute("cart");
                    req.setAttribute("placedOrderId", "#FZ-" + orderId);
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
