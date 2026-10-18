package com.ute.fooddelivery;

import com.ute.fooddelivery.controller.merchant.MerchantDispatchAPI;
import com.ute.fooddelivery.controller.merchant.MerchantOrderController;
import com.ute.fooddelivery.controller.merchant.MerchantShipperController;
import com.ute.fooddelivery.dao.DriverDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class MerchantOrderSecurityTest {

    private Order createDummyOrder(int orderId, int restaurantId, String status) {
        Order order = new Order();
        order.setId(orderId);
        order.setRestaurantId(restaurantId);
        order.setStatus(status);
        order.setTotalAmount(150000);
        order.setAddress("123 Test Street");
        return order;
    }

    private Restaurant createDummyRestaurant(int restaurantId, int userId, String name) {
        Restaurant r = new Restaurant();
        r.setId(restaurantId);
        r.setUserId(userId);
        r.setName(name);
        r.setLatitude(10.85);
        r.setLongitude(106.77);
        return r;
    }

    @Test
    public void testMerchantOrderControllerBlocksForeignOrderUpdateStatus() throws Exception {
        MerchantOrderController controller = new MerchantOrderController();

        // Giả lập mock MerchantService trả về đơn hàng của Quán B (restaurantId = 2)
        MerchantService mockService = new MerchantService() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field serviceField = MerchantOrderController.class.getDeclaredField("merchantService");
        serviceField.setAccessible(true);
        serviceField.set(controller, mockService);

        // Chủ quán hiện tại là Quán A (restaurantId = 1)
        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("action", "updateStatus");
        params.put("orderId", "99");
        params.put("newStatus", "PREPARING");

        final String[] redirectedUrl = new String[1];
        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/orders");
        HttpServletResponse resp = createMockResponse(redirectedUrl, null, new int[]{200});

        Method doPostMethod = MerchantOrderController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertEquals("Bạn không có quyền thao tác trên đơn hàng của quán khác!", sessionData.get("flashError"));
    }

    @Test
    public void testMerchantOrderControllerBlocksForeignOrderComplete() throws Exception {
        MerchantOrderController controller = new MerchantOrderController();

        MerchantService mockService = new MerchantService() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "SHIPPING");
            }
        };

        Field serviceField = MerchantOrderController.class.getDeclaredField("merchantService");
        serviceField.setAccessible(true);
        serviceField.set(controller, mockService);

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("action", "completeOrder");
        params.put("orderId", "99");

        final String[] redirectedUrl = new String[1];
        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/orders");
        HttpServletResponse resp = createMockResponse(redirectedUrl, null, new int[]{200});

        Method doPostMethod = MerchantOrderController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertEquals("Bạn không có quyền thao tác trên đơn hàng của quán khác!", sessionData.get("flashError"));
    }

    @Test
    public void testMerchantOrderControllerBlocksForeignOrderAssignDriver() throws Exception {
        MerchantOrderController controller = new MerchantOrderController();

        MerchantService mockService = new MerchantService() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field serviceField = MerchantOrderController.class.getDeclaredField("merchantService");
        serviceField.setAccessible(true);
        serviceField.set(controller, mockService);

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("action", "assignDriver");
        params.put("orderId", "99");
        params.put("driverId", "5");

        final String[] redirectedUrl = new String[1];
        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/orders");
        HttpServletResponse resp = createMockResponse(redirectedUrl, null, new int[]{200});

        Method doPostMethod = MerchantOrderController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertEquals("Bạn không có quyền thao tác trên đơn hàng của quán khác!", sessionData.get("flashError"));
    }

    @Test
    public void testMerchantOrderControllerBlocksForeignOrderAutoAssignNearest() throws Exception {
        MerchantOrderController controller = new MerchantOrderController();

        MerchantService mockService = new MerchantService() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field serviceField = MerchantOrderController.class.getDeclaredField("merchantService");
        serviceField.setAccessible(true);
        serviceField.set(controller, mockService);

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("action", "autoAssignNearest");
        params.put("orderId", "99");

        final String[] redirectedUrl = new String[1];
        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/orders");
        HttpServletResponse resp = createMockResponse(redirectedUrl, null, new int[]{200});

        Method doPostMethod = MerchantOrderController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertEquals("Bạn không có quyền thao tác trên đơn hàng của quán khác!", sessionData.get("flashError"));
    }

    @Test
    public void testMerchantDispatchAPIDoGetBlocksForeignOrder() throws Exception {
        MerchantDispatchAPI api = new MerchantDispatchAPI();

        OrderDAO mockOrderDAO = new OrderDAO() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field orderDaoField = MerchantDispatchAPI.class.getDeclaredField("orderDAO");
        orderDaoField.setAccessible(true);
        orderDaoField.set(api, mockOrderDAO);

        User sellerUser = new User();
        sellerUser.setId(10);
        sellerUser.setRole("SELLER");

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", sellerUser);
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("orderId", "99");

        StringWriter outWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(outWriter);
        int[] statusCode = new int[]{200};

        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/api/dispatch");
        HttpServletResponse resp = createMockResponse(new String[1], printWriter, statusCode);

        Method doGetMethod = MerchantDispatchAPI.class.getDeclaredMethod("doGet", HttpServletRequest.class, HttpServletResponse.class);
        doGetMethod.setAccessible(true);
        doGetMethod.invoke(api, req, resp);

        assertEquals(403, statusCode[0]);
        assertTrue(outWriter.toString().contains("Bạn không có quyền thao tác trên đơn hàng của quán khác!"));
    }

    @Test
    public void testMerchantDispatchAPIDoPostBlocksForeignOrder() throws Exception {
        MerchantDispatchAPI api = new MerchantDispatchAPI();

        OrderDAO mockOrderDAO = new OrderDAO() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field orderDaoField = MerchantDispatchAPI.class.getDeclaredField("orderDAO");
        orderDaoField.setAccessible(true);
        orderDaoField.set(api, mockOrderDAO);

        User sellerUser = new User();
        sellerUser.setId(10);
        sellerUser.setRole("SELLER");

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", sellerUser);
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("orderId", "99");
        params.put("driverId", "auto");

        StringWriter outWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(outWriter);
        int[] statusCode = new int[]{200};

        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/api/dispatch");
        HttpServletResponse resp = createMockResponse(new String[1], printWriter, statusCode);

        Method doPostMethod = MerchantDispatchAPI.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(api, req, resp);

        assertEquals(403, statusCode[0]);
        assertTrue(outWriter.toString().contains("Bạn không có quyền thao tác trên đơn hàng của quán khác!"));
    }

    @Test
    public void testMerchantShipperControllerBlocksForeignOrderAssign() throws Exception {
        MerchantShipperController controller = new MerchantShipperController();

        MerchantService mockService = new MerchantService() {
            @Override
            public Order getOrderById(int orderId) {
                return createDummyOrder(orderId, 2, "CONFIRMED");
            }
        };

        Field serviceField = MerchantShipperController.class.getDeclaredField("merchantService");
        serviceField.setAccessible(true);
        serviceField.set(controller, mockService);

        Restaurant currentRestaurant = createDummyRestaurant(1, 10, "Quán A");

        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, Object> reqAttributes = new HashMap<>();
        reqAttributes.put("currentRestaurant", currentRestaurant);

        Map<String, String> params = new HashMap<>();
        params.put("action", "assign");
        params.put("orderId", "99");
        params.put("driverId", "5");

        final String[] redirectedUrl = new String[1];
        HttpServletRequest req = createMockRequest(mockSession, reqAttributes, params, "/merchant/shippers");
        HttpServletResponse resp = createMockResponse(redirectedUrl, null, new int[]{200});

        Method doPostMethod = MerchantShipperController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertEquals("Bạn không có quyền thao tác trên đơn hàng của quán khác!", sessionData.get("flashError"));
    }

    // --- Helper proxy methods ---
    private HttpSession createMockSession(Map<String, Object> sessionData) {
        return (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(),
                new Class<?>[]{HttpSession.class},
                (proxy, method, args) -> {
                    String mName = method.getName();
                    if ("getAttribute".equals(mName)) {
                        return sessionData.get((String) args[0]);
                    } else if ("setAttribute".equals(mName)) {
                        sessionData.put((String) args[0], args[1]);
                        return null;
                    } else if ("removeAttribute".equals(mName)) {
                        sessionData.remove((String) args[0]);
                        return null;
                    }
                    return null;
                }
        );
    }

    private HttpServletRequest createMockRequest(HttpSession session, Map<String, Object> attributes, Map<String, String> params, String servletPath) {
        return (HttpServletRequest) Proxy.newProxyInstance(
                HttpServletRequest.class.getClassLoader(),
                new Class<?>[]{HttpServletRequest.class},
                (proxy, method, args) -> {
                    String mName = method.getName();
                    if ("getSession".equals(mName)) {
                        return session;
                    } else if ("getParameter".equals(mName)) {
                        return params.get((String) args[0]);
                    } else if ("getAttribute".equals(mName)) {
                        return attributes != null ? attributes.get((String) args[0]) : null;
                    } else if ("setAttribute".equals(mName)) {
                        if (attributes != null) attributes.put((String) args[0], args[1]);
                        return null;
                    } else if ("getServletPath".equals(mName)) {
                        return servletPath;
                    } else if ("getContextPath".equals(mName)) {
                        return "";
                    } else if ("getRequestURI".equals(mName)) {
                        return servletPath;
                    }
                    return null;
                }
        );
    }

    private HttpServletResponse createMockResponse(String[] redirectedUrl, PrintWriter printWriter, int[] statusCode) {
        return (HttpServletResponse) Proxy.newProxyInstance(
                HttpServletResponse.class.getClassLoader(),
                new Class<?>[]{HttpServletResponse.class},
                (proxy, method, args) -> {
                    String mName = method.getName();
                    if ("sendRedirect".equals(mName)) {
                        redirectedUrl[0] = (String) args[0];
                        return null;
                    } else if ("setStatus".equals(mName)) {
                        if (statusCode != null && args.length > 0) {
                            statusCode[0] = (int) args[0];
                        }
                        return null;
                    } else if ("getWriter".equals(mName)) {
                        return printWriter;
                    }
                    return null;
                }
        );
    }
}
