package com.ute.fooddelivery;

import com.ute.fooddelivery.controller.shipper.ShipperDashboardController;
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

public class ShipperDashboardControllerSecurityTest {

    @Test
    public void testDoGetBlocksStateModifyingActions() throws Exception {
        ShipperDashboardController controller = new ShipperDashboardController();

        User shipper = new User(10, "test_shipper", "123456", "Test Shipper", "shipper@ute.vn", "0900000000", "TP.HCM", "SHIPPER");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", shipper);
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "toggleStatus"); // Hành vi thay đổi trạng thái qua GET

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/shipper/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doGetMethod = ShipperDashboardController.class.getDeclaredMethod("doGet", HttpServletRequest.class, HttpServletResponse.class);
        doGetMethod.setAccessible(true);
        doGetMethod.invoke(controller, req, resp);

        assertNotNull("GET với tham số action phải bị chặn và chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=method_not_allowed", redirectedUrl[0].contains("error=method_not_allowed"));
    }

    @Test
    public void testDoPostRejectsMissingCsrfToken() throws Exception {
        ShipperDashboardController controller = new ShipperDashboardController();

        User shipper = new User(10, "test_shipper", "123456", "Test Shipper", "shipper@ute.vn", "0900000000", "TP.HCM", "SHIPPER");

        Map<String, Object> sessionData = new HashMap<>();
        sessionData.put("currentUser", shipper);
        sessionData.put(CsrfUtils.CSRF_TOKEN_ATTR, "valid_token_123");
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "toggleStatus");
        // Không truyền csrfToken

        final String[] redirectedUrl = new String[1];

        HttpServletRequest req = createMockRequest(mockSession, params, "/shipper/dashboard");
        HttpServletResponse resp = createMockResponse(redirectedUrl);

        Method doPostMethod = ShipperDashboardController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPostMethod.setAccessible(true);
        doPostMethod.invoke(controller, req, resp);

        assertNotNull("POST thiếu CSRF token phải bị chặn và chuyển hướng", redirectedUrl[0]);
        assertTrue("Chuyển hướng phải chứa error=csrf_invalid", redirectedUrl[0].contains("error=csrf_invalid"));
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
                        if ("getSession".equals(name)) {
                            return session;
                        } else if ("getContextPath".equals(name)) {
                            return "";
                        } else if ("getServletPath".equals(name)) {
                            return servletPath;
                        } else if ("getParameter".equals(name) && args != null && args.length == 1) {
                            return params.get(args[0]);
                        } else if ("getHeader".equals(name)) {
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
