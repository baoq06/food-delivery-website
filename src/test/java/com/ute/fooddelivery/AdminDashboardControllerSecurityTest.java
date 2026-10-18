package com.ute.fooddelivery;

import com.ute.fooddelivery.controller.AdminDashboardController;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.utils.CsrfUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

public class AdminDashboardControllerSecurityTest {

    @Test
    public void testDoGetBlocksStateModifyingActions() throws Exception {
        AdminDashboardController controller = new AdminDashboardController();

        User admin = new User(1, "admin", "123456", "Administrator", "admin@ute.vn", "0912345678", "TP.HCM", "ADMIN");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", admin);
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "deleteAllOrders"); // Hành vi xóa đơn nguy hiểm gửi qua GET

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/admin/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doGetMethod = AdminDashboardController.class.getDeclaredMethod("doGet", HttpServletRequest.class, HttpServletResponse.class);
        doGetMethod.setAccessible(true);
        doGetMethod.invoke(controller, req, resp);

        assertNotNull("GET với tham số action phải bị chặn và chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=method_not_allowed", redirectedUrl[0].contains("error=method_not_allowed"));
    }

    @Test
    public void testDoPostRejectsMissingCsrfToken() throws Exception {
        AdminDashboardController controller = new AdminDashboardController();

        User admin = new User(1, "admin", "123456", "Administrator", "admin@ute.vn", "0912345678", "TP.HCM", "ADMIN");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", admin);
        sessionData.put(CsrfUtils.CSRF_TOKEN_ATTR, "secret_admin_token_999");
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "deleteAllOrders");
        // Không truyền csrfToken

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/admin/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doPostMethod = AdminDashboardController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertNotNull("POST thiếu CSRF token phải bị chặn và chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=csrf_invalid", redirectedUrl[0].contains("error=csrf_invalid"));
    }

    @Test
    public void testDoPostRejectsInvalidCsrfToken() throws Exception {
        AdminDashboardController controller = new AdminDashboardController();

        User admin = new User(1, "admin", "123456", "Administrator", "admin@ute.vn", "0912345678", "TP.HCM", "ADMIN");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", admin);
        sessionData.put(CsrfUtils.CSRF_TOKEN_ATTR, "correct_token_123");
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "banDriver");
        params.put("phone", "0901234567");
        params.put("csrfToken", "attacker_tampered_token"); // Token sai

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/admin/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doPostMethod = AdminDashboardController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertNotNull("POST sai CSRF token phải bị chặn và chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=csrf_invalid", redirectedUrl[0].contains("error=csrf_invalid"));
    }

    @Test
    public void testDoPostRejectsNonAdminUser() throws Exception {
        AdminDashboardController controller = new AdminDashboardController();

        // User thường (ROLE: CUSTOMER)
        User customer = new User(5, "customer", "123456", "Khách Hàng", "cust@ute.vn", "0909999999", "TP.HCM", "CUSTOMER");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", customer);
        sessionData.put(CsrfUtils.CSRF_TOKEN_ATTR, "some_token");
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "deleteAllOrders");
        params.put("csrfToken", "some_token");

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/admin/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doPostMethod = AdminDashboardController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertNotNull("User không phải Admin phải bị chặn chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=unauthorized hoặc login", redirectedUrl[0].contains("unauthorized") || redirectedUrl[0].contains("login"));
    }

    private HttpSession createMockSession(Map<String, Object> data) {
        return (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(),
                new Class<?>[]{HttpSession.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) {
                        String name = method.getName();
                        if ("getAttribute".equals(name) && args != null && args.length == 1) {
                            return data.get(args[0]);
                        } else if ("setAttribute".equals(name) && args != null && args.length == 2) {
                            data.put((String) args[0], args[1]);
                            return null;
                        } else if ("removeAttribute".equals(name) && args != null && args.length == 1) {
                            return data.remove(args[0]);
                        }
                        return null;
                    }
                }
        );
    }

    private HttpServletRequest createMockRequest(HttpSession session, Map<String, String> params, String servletPath) {
        return (HttpServletRequest) Proxy.newProxyInstance(
                HttpServletRequest.class.getClassLoader(),
                new Class<?>[]{HttpServletRequest.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) {
                        String name = method.getName();
                        if ("getSession".equals(name) || "getSession".equals(name) && args != null && args.length == 1) {
                            return session;
                        } else if ("getContextPath".equals(name)) {
                            return "";
                        } else if ("getServletPath".equals(name)) {
                            return servletPath;
                        } else if ("getParameter".equals(name) && args != null && args.length == 1) {
                            return params.get(args[0]);
                        } else if ("getHeader".equals(name)) {
                            return null;
                        } else if ("setCharacterEncoding".equals(name)) {
                            return null;
                        } else if ("setAttribute".equals(name)) {
                            return null;
                        }
                        return null;
                    }
                }
        );
    }

    private HttpServletResponse createMockResponse(String[] redirectedUrl) {
        return (HttpServletResponse) Proxy.newProxyInstance(
                HttpServletResponse.class.getClassLoader(),
                new Class<?>[]{HttpServletResponse.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) {
                        String name = method.getName();
                        if ("sendRedirect".equals(name) && args != null && args.length == 1) {
                            redirectedUrl[0] = (String) args[0];
                            return null;
                        }
                        return null;
                    }
                }
        );
    }
}
