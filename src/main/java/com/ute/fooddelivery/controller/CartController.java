package com.ute.fooddelivery.controller;

import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.CartItem;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Food;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.OrderItem;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.FoodService;
import com.ute.fooddelivery.service.NotificationService;
import com.ute.fooddelivery.service.OrderService;
import com.ute.fooddelivery.service.VoucherService;
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
    private final com.ute.fooddelivery.service.VoucherService voucherService = new com.ute.fooddelivery.service.VoucherService();
    private final com.ute.fooddelivery.dao.UserVoucherDAO userVoucherDAO = new com.ute.fooddelivery.dao.UserVoucherDAO();
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

        int restaurantId = 1;
        if (session != null) {
            @SuppressWarnings("unchecked")
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            if (cart != null && !cart.isEmpty()) {
                for (CartItem ci : cart.values()) {
                    if (ci.getFood() != null && ci.getFood().getRestaurantId() > 0) {
                        restaurantId = ci.getFood().getRestaurantId();
                        break;
                    }
                }
            }
        }
        req.setAttribute("cartRestaurantId", restaurantId);

        int userId = currentUser != null ? currentUser.getId() : 0;
        if (userId > 0) {
            List<com.ute.fooddelivery.model.UserVoucher> uvList = userVoucherDAO.getUserVouchers(userId);
            req.setAttribute("userVouchers", uvList);
            req.setAttribute("availableVouchers", uvList);
        } else {
            req.setAttribute("availableVouchers", voucherService.getAllVouchers());
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
        String ajaxParam = req.getParameter("ajax");
        String xRequestedWith = req.getHeader("X-Requested-With");
        String acceptHeader = req.getHeader("Accept");
        boolean isAjax = "true".equalsIgnoreCase(ajaxParam) ||
                         "XMLHttpRequest".equals(xRequestedWith) ||
                         (acceptHeader != null && acceptHeader.contains("application/json"));

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
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(HttpServletResponse.SC_OK);
                resp.getWriter().write(String.format("{\"success\":false,\"requireLogin\":true,\"loginUrl\":\"%s/auth?action=login\",\"message\":\"Vui lòng đăng nhập để đặt món!\"}", req.getContextPath()));
                return;
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
            String addedFoodName = "";
            String addedFoodImage = "";
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
                    addedFoodName = item.getFood().getName();
                    addedFoodImage = item.getFood().getImage();
                } else {
                    Food food = foodService.getFoodById(foodId);
                    if (food != null) {
                        cart.put(foodId, new CartItem(food, quantity));
                        addedFoodName = food.getName();
                        addedFoodImage = food.getImage();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            session.setAttribute("cart", cart);

            if (isAjax) {
                int totalQuantity = 0;
                double totalPrice = 0;
                for (CartItem ci : cart.values()) {
                    totalQuantity += ci.getQuantity();
                    totalPrice += ci.getTotalPrice();
                }
                resp.setContentType("application/json;charset=UTF-8");
                String safeName = addedFoodName != null ? addedFoodName.replace("\"", "\\\"") : "";
                String safeImage = addedFoodImage != null ? addedFoodImage.replace("\"", "\\\"") : "";
                resp.getWriter().write(String.format("{\"success\":true,\"foodName\":\"%s\",\"foodImage\":\"%s\",\"cartCount\":%d,\"totalQuantity\":%d,\"totalPrice\":%.0f,\"message\":\"Đã thêm món vào giỏ hàng!\"}",
                        safeName, safeImage, cart.size(), totalQuantity, totalPrice));
                return;
            }

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

            if (isAjax) {
                int totalQuantity = 0;
                double totalPrice = 0;
                for (CartItem ci : cart.values()) {
                    totalQuantity += ci.getQuantity();
                    totalPrice += ci.getTotalPrice();
                }
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write(String.format("{\"success\":true,\"cartCount\":%d,\"totalQuantity\":%d,\"totalPrice\":%.0f}",
                        cart.size(), totalQuantity, totalPrice));
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        } else if ("checkout".equalsIgnoreCase(action)) {
            if (!cart.isEmpty()) {
                String receiverName = req.getParameter("receiverName");
                String receiverPhone = req.getParameter("receiverPhone");
                String receiverAddress = req.getParameter("receiverAddress");
                String receiverNote = req.getParameter("receiverNote");
                String paymentMethod = req.getParameter("paymentMethod");
                String shippingVoucherCode = req.getParameter("shippingVoucherCode");
                if (shippingVoucherCode == null || shippingVoucherCode.trim().isEmpty()) {
                    shippingVoucherCode = req.getParameter("freeshipCode");
                }
                String foodVoucherCode = req.getParameter("foodVoucherCode");
                if (foodVoucherCode == null || foodVoucherCode.trim().isEmpty()) {
                    foodVoucherCode = req.getParameter("foodCode");
                }
                String voucherCode = req.getParameter("voucherCode");

                Integer userId = currentUser.getId();

                // Nếu form gửi qua voucherCode (chuỗi đơn hoặc chứa dấu phẩy "FREESHIP, UTEE30")
                if ((shippingVoucherCode == null || shippingVoucherCode.trim().isEmpty()) &&
                    (foodVoucherCode == null || foodVoucherCode.trim().isEmpty()) &&
                    voucherCode != null && !voucherCode.trim().isEmpty()) {
                    String[] parts = voucherCode.split(",");
                    for (String p : parts) {
                        String clean = p.trim();
                        Voucher v = voucherService.findVoucherForUser(clean, userId);
                        if (v != null) {
                            if (v.isFreeShip() && (shippingVoucherCode == null || shippingVoucherCode.isEmpty())) {
                                shippingVoucherCode = clean;
                            } else if (!v.isFreeShip() && (foodVoucherCode == null || foodVoucherCode.isEmpty())) {
                                foodVoucherCode = clean;
                            }
                        }
                    }
                }

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
                    req.setAttribute("stickyReceiverName", receiverName);
                    req.setAttribute("stickyReceiverPhone", receiverPhone);
                    req.setAttribute("stickyReceiverAddress", receiverAddress);
                    req.setAttribute("stickyReceiverNote", receiverNote);
                    req.setAttribute("stickyPaymentMethod", paymentMethod);
                    req.setAttribute("stickyVoucherCode", voucherCode);
                    req.setAttribute("stickyShippingVoucherCode", shippingVoucherCode);
                    req.setAttribute("stickyFoodVoucherCode", foodVoucherCode);
                    req.setAttribute("userVouchers", userVoucherDAO.getUserVouchers(userId));
                    req.setAttribute("availableVouchers", userVoucherDAO.getUserVouchers(userId));
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

                int restaurantId = 1;
                for (CartItem ci : cart.values()) {
                    if (ci.getFood() != null && ci.getFood().getRestaurantId() > 0) {
                        restaurantId = ci.getFood().getRestaurantId();
                        break;
                    }
                }

                com.ute.fooddelivery.dao.RestaurantDAO restaurantDAO = new com.ute.fooddelivery.dao.RestaurantDAO();
                com.ute.fooddelivery.model.Restaurant restaurant = restaurantDAO.getRestaurantById(restaurantId);
                double restLat = restaurant != null ? restaurant.getLatitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LAT;
                double restLng = restaurant != null ? restaurant.getLongitude() : com.ute.fooddelivery.utils.GeoLocationUtils.DEFAULT_LNG;

                double[] custCoords = com.ute.fooddelivery.utils.GeoLocationUtils.getCoordinatesForAddress(receiverAddress);
                double distanceKm = com.ute.fooddelivery.utils.GeoLocationUtils.calculateRouteDistance(restLat, restLng, custCoords[0], custCoords[1]);
                double shippingFee = com.ute.fooddelivery.utils.GeoLocationUtils.calculateShippingFee(distanceKm);

                // Thẩm định áp dụng tối đa 2 mã (1 freeship + 1 food discount) độc lập trên máy chủ
                VoucherService.DualValidationResult dualResult = voucherService.validateTwoVouchers(
                        shippingVoucherCode, foodVoucherCode, subtotalBill, shippingFee, restaurantId, userId
                );

                double discountAmount = 0.0;
                String appliedVoucherCode = null;
                if (dualResult.isValid()) {
                    discountAmount = dualResult.getTotalDiscount();
                    appliedVoucherCode = dualResult.getCombinedCode();
                }

                double totalBill = Math.max(0, subtotalBill + shippingFee - discountAmount);

                Order order = new Order();
                order.setUserId(userId);
                order.setCustomerName(receiverName.trim());
                order.setPhone(receiverPhone.trim());
                order.setAddress(receiverAddress.trim());
                order.setNote(receiverNote != null ? receiverNote.trim() : "");
                order.setShippingFee(shippingFee);
                order.setDistanceKm(distanceKm);
                order.setDiscountAmount(discountAmount);
                order.setVoucherCode(appliedVoucherCode);
                order.setTotalAmount(totalBill);
                order.setPaymentMethod(paymentMethod != null ? paymentMethod : "COD");

                int orderId = orderService.createOrder(order, items);
                if (orderId > 0) {
                    // Trừ số lượng mã tương ứng trong Kho Voucher của người dùng
                    List<String> codesToDeduct = new ArrayList<>();
                    if (dualResult.getFreeshipVoucher() != null) {
                        codesToDeduct.add(dualResult.getFreeshipVoucher().getCode());
                    }
                    if (dualResult.getFoodVoucher() != null) {
                        codesToDeduct.add(dualResult.getFoodVoucher().getCode());
                    }
                    if (!codesToDeduct.isEmpty()) {
                        try {
                            userVoucherDAO.useVouchers(userId, codesToDeduct);
                        } catch (Exception e) {
                            System.err.println("Lỗi khi trừ số lượng voucher trong kho: " + e.getMessage());
                        }
                    }

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
                    req.setAttribute("successSubtotal", subtotalBill);
                    req.setAttribute("successShippingFee", shippingFee);
                    req.setAttribute("successDiscountAmount", discountAmount);
                    req.setAttribute("successShippingDiscount", dualResult.getShippingDiscount());
                    req.setAttribute("successFoodDiscount", dualResult.getFoodDiscount());
                    req.setAttribute("successVoucherCode", appliedVoucherCode);
                    req.setAttribute("successTotalAmount", totalBill);
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
