package com.ute.fooddelivery;

import com.ute.fooddelivery.controller.AuthController;
import jakarta.servlet.RequestDispatcher;
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

public class AuthOtpVerificationTest {

    @Test
    public void testRegisterWithoutOtpVerificationFails() throws Exception {
        AuthController controller = new AuthController();

        Map<String, Object> sessionData = new HashMap<>();
        // KHÔNG có phoneVerified trong session
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "register");
        params.put("fullName", "Nguyen Van Test");
        params.put("username", "testuser_otp_1");
        params.put("password", "123456");
        params.put("confirmPassword", "123456");
        params.put("phone", "0901234567");
        params.put("address", "1 Võ Văn Ngân, Thủ Đức");
        params.put("accountType", "CUSTOMER");

        Map<String, Object> reqAttrs = new HashMap<>();
        HttpServletRequest req = createMockRequest(mockSession, params, reqAttrs);
        HttpServletResponse resp = createMockResponse();

        Method doPost = AuthController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPost.setAccessible(true);
        doPost.invoke(controller, req, resp);

        // Kiểm tra kết quả: Bắt buộc phải có lỗi thông báo chưa xác thực OTP
        String errorMessage = (String) reqAttrs.get("errorMessage");
        assertNotNull("Bắt buộc phải trả về errorMessage khi chưa xác thực OTP", errorMessage);
        assertTrue("Thông báo lỗi phải nhắc nhở xác thực OTP", errorMessage.contains("xác thực mã OTP") || errorMessage.contains("OTP"));
        assertEquals("currentStep phải được đưa về step 2 để nhập/xác thực OTP", 2, reqAttrs.get("currentStep"));
    }

    @Test
    public void testRegisterWithMismatchedPhoneFails() throws Exception {
        AuthController controller = new AuthController();

        Map<String, Object> sessionData = new HashMap<>();
        // Đã verify số 0901111111
        sessionData.put("phoneVerified", true);
        sessionData.put("regPhone", "0901111111");
        HttpSession mockSession = createMockSession(sessionData);

        Map<String, String> params = new HashMap<>();
        params.put("action", "register");
        params.put("fullName", "Nguyen Van Test");
        params.put("username", "testuser_otp_2");
        params.put("password", "123456");
        params.put("confirmPassword", "123456");
        params.put("phone", "0909999999"); // Số khác với số đã verify
        params.put("address", "1 Võ Văn Ngân, Thủ Đức");
        params.put("accountType", "CUSTOMER");

        Map<String, Object> reqAttrs = new HashMap<>();
        HttpServletRequest req = createMockRequest(mockSession, params, reqAttrs);
        HttpServletResponse resp = createMockResponse();

        Method doPost = AuthController.class.getDeclaredMethod("doPost", HttpServletRequest.class, HttpServletResponse.class);
        doPost.setAccessible(true);
        doPost.invoke(controller, req, resp);

        // Kiểm tra kết quả: Bắt buộc báo lỗi không khớp số điện thoại
        String errorMessage = (String) reqAttrs.get("errorMessage");
        assertNotNull("Bắt buộc phải trả về errorMessage khi số điện thoại không khớp OTP", errorMessage);
        assertTrue("Thông báo lỗi phải nêu rõ số điện thoại không trùng khớp", errorMessage.contains("không trùng khớp") || errorMessage.contains("không khớp"));
        assertEquals("currentStep phải được đưa về step 2 để nhập/xác thực lại", 2, reqAttrs.get("currentStep"));
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

    private HttpServletRequest createMockRequest(HttpSession session, Map<String, String> params, Map<String, Object> attrs) {
        RequestDispatcher dispatcher = (RequestDispatcher) Proxy.newProxyInstance(
                RequestDispatcher.class.getClassLoader(),
                new Class<?>[]{RequestDispatcher.class},
                (proxy, method, args) -> null
        );

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
                        } else if ("getParameter".equals(name) && args != null && args.length == 1) {
                            return params.get(args[0]);
                        } else if ("setAttribute".equals(name) && args != null && args.length == 2) {
                            attrs.put((String) args[0], args[1]);
                            return null;
                        } else if ("getAttribute".equals(name) && args != null && args.length == 1) {
                            return attrs.get(args[0]);
                        } else if ("getPart".equals(name)) {
                            return null;
                        } else if ("getRequestDispatcher".equals(name)) {
                            return dispatcher;
                        }
                        return null;
                    }
                }
        );
    }

    private HttpServletResponse createMockResponse() {
        return (HttpServletResponse) Proxy.newProxyInstance(
                HttpServletResponse.class.getClassLoader(),
                new Class<?>[]{HttpServletResponse.class},
                (proxy, method, args) -> null
        );
    }
}
