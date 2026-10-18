package com.ute.fooddelivery;

import com.ute.fooddelivery.filter.ShipperFilter;
import com.ute.fooddelivery.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

public class ShipperFilterTest {

    @Test
    public void testUnauthenticatedWebUserRedirectsToLogin() throws Exception {
        ShipperFilter filter = new ShipperFilter();

        // Không có session đăng nhập
        HttpSession session = null;
        Map<String, Object> reqAttrs = new HashMap<>();
        String[] redirectedUrl = new String[1];
        int[] status = new int[1];

        HttpServletRequest req = createMockRequest(session, "/shipper/dashboard", null, null, reqAttrs);
        HttpServletResponse resp = createMockResponse(redirectedUrl, status, new StringWriter());

        boolean[] chainCalled = new boolean[1];
        FilterChain chain = (request, response) -> chainCalled[0] = true;

        filter.doFilter(req, resp, chain);

        assertFalse("Chưa đăng nhập thì không được gọi chain.doFilter", chainCalled[0]);
        assertNotNull("Phải chuyển hướng người dùng chưa đăng nhập", redirectedUrl[0]);
        assertTrue("Redirect URL phải chứa error=unauthorized_shipper", redirectedUrl[0].contains("unauthorized_shipper"));
    }

    @Test
    public void testUnauthenticatedApiRequestReturns401() throws Exception {
        ShipperFilter filter = new ShipperFilter();

        HttpSession session = null;
        Map<String, Object> reqAttrs = new HashMap<>();
        String[] redirectedUrl = new String[1];
        int[] status = new int[1];
        StringWriter responseBody = new StringWriter();

        HttpServletRequest req = createMockRequest(session, "/shipper/api/dispatch", null, null, reqAttrs);
        HttpServletResponse resp = createMockResponse(redirectedUrl, status, responseBody);

        boolean[] chainCalled = new boolean[1];
        FilterChain chain = (request, response) -> chainCalled[0] = true;

        filter.doFilter(req, resp, chain);

        assertFalse("Chưa đăng nhập không được qua Filter", chainCalled[0]);
        assertEquals("API request chưa đăng nhập phải trả về 401 Unauthorized", 401, status[0]);
        assertTrue("Phản hồi JSON phải chứa thông báo chưa đăng nhập", responseBody.toString().contains("Chưa đăng nhập"));
    }

    @Test
    public void testNonShipperUserBlocked() throws Exception {
        ShipperFilter filter = new ShipperFilter();

        User customer = new User(10, "customer_test", "123456", "Khách Hàng", "cust@ute.vn", "0900000000", "TP.HCM", "CUSTOMER");
        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", customer);
        HttpSession session = createMockSession(sessionData);

        Map<String, Object> reqAttrs = new HashMap<>();
        String[] redirectedUrl = new String[1];
        int[] status = new int[1];

        HttpServletRequest req = createMockRequest(session, "/shipper/dashboard", null, null, reqAttrs);
        HttpServletResponse resp = createMockResponse(redirectedUrl, status, new StringWriter());

        boolean[] chainCalled = new boolean[1];
        FilterChain chain = (request, response) -> chainCalled[0] = true;

        filter.doFilter(req, resp, chain);

        assertFalse("Khách hàng không được phép truy cập khu vực Shipper", chainCalled[0]);
        assertNotNull("Phải redirect", redirectedUrl[0]);
        assertTrue("Redirect URL phải chứa unauthorized", redirectedUrl[0].contains("unauthorized"));
    }

    @Test
    public void testShipperUserAllowedThroughChain() throws Exception {
        ShipperFilter filter = new ShipperFilter();

        User shipper = new User(20, "shipper_test", "123456", "Tài Xế", "shipper@ute.vn", "0911111111", "TP.HCM", "SHIPPER");
        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", shipper);
        HttpSession session = createMockSession(sessionData);

        Map<String, Object> reqAttrs = new HashMap<>();
        String[] redirectedUrl = new String[1];
        int[] status = new int[1];

        HttpServletRequest req = createMockRequest(session, "/shipper/dashboard", null, null, reqAttrs);
        HttpServletResponse resp = createMockResponse(redirectedUrl, status, new StringWriter());

        boolean[] chainCalled = new boolean[1];
        FilterChain chain = (request, response) -> chainCalled[0] = true;

        filter.doFilter(req, resp, chain);

        assertTrue("Tài xế hợp lệ phải được phép tiếp tục qua chain.doFilter", chainCalled[0]);
        assertNull("Không được chuyển hướng khi hợp lệ", redirectedUrl[0]);
    }

    private HttpSession createMockSession(Map<String, Object> data) {
        return (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(),
                new Class<?>[]{HttpSession.class},
                (proxy, method, args) -> {
                    String name = method.getName();
                    if ("getAttribute".equals(name) && args != null && args.length == 1) {
                        return data.get(args[0]);
                    } else if ("setAttribute".equals(name) && args != null && args.length == 2) {
                        data.put((String) args[0], args[1]);
                        return null;
                    }
                    return null;
                }
        );
    }

    private HttpServletRequest createMockRequest(HttpSession session, String uri, String queryString, String xRequestedWith, Map<String, Object> attrs) {
        return (HttpServletRequest) Proxy.newProxyInstance(
                HttpServletRequest.class.getClassLoader(),
                new Class<?>[]{HttpServletRequest.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) {
                        String name = method.getName();
                        if ("getSession".equals(name) || ("getSession".equals(name) && args != null && args.length == 1)) {
                            return session;
                        } else if ("getRequestURI".equals(name)) {
                            return uri;
                        } else if ("getServletPath".equals(name)) {
                            return uri;
                        } else if ("getPathInfo".equals(name)) {
                            return null;
                        } else if ("getQueryString".equals(name)) {
                            return queryString;
                        } else if ("getContextPath".equals(name)) {
                            return "";
                        } else if ("getHeader".equals(name) && args != null && args.length == 1) {
                            if ("X-Requested-With".equalsIgnoreCase((String) args[0])) {
                                return xRequestedWith;
                            }
                            return null;
                        } else if ("setAttribute".equals(name) && args != null && args.length == 2) {
                            attrs.put((String) args[0], args[1]);
                            return null;
                        } else if ("getAttribute".equals(name) && args != null && args.length == 1) {
                            return attrs.get(args[0]);
                        }
                        return null;
                    }
                }
        );
    }

    private HttpServletResponse createMockResponse(String[] redirectedUrl, int[] status, StringWriter writer) {
        PrintWriter pw = new PrintWriter(writer);
        return (HttpServletResponse) Proxy.newProxyInstance(
                HttpServletResponse.class.getClassLoader(),
                new Class<?>[]{HttpServletResponse.class},
                (proxy, method, args) -> {
                    String name = method.getName();
                    if ("sendRedirect".equals(name) && args != null && args.length == 1) {
                        redirectedUrl[0] = (String) args[0];
                        return null;
                    } else if ("setStatus".equals(name) && args != null && args.length == 1) {
                        status[0] = (Integer) args[0];
                        return null;
                    } else if ("getWriter".equals(name)) {
                        return pw;
                    } else if ("setContentType".equals(name)) {
                        return null;
                    }
                    return null;
                }
        );
    }
}
