package com.ute.fooddelivery;

import com.ute.fooddelivery.utils.CsrfUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.junit.Test;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

public class CsrfUtilsTest {

    @Test
    public void testGetOrCreateToken() {
        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        // 1. Lần đầu gọi -> Token phải được sinh ra và lưu vào session
        String token1 = CsrfUtils.getOrCreateToken(mockSession);
        assertNotNull(token1);
        assertFalse(token1.trim().isEmpty());
        assertEquals(token1, sessionData.get(CsrfUtils.CSRF_TOKEN_ATTR));

        // 2. Lần thứ hai gọi -> Phải trả về đúng token cũ, không tạo mới
        String token2 = CsrfUtils.getOrCreateToken(mockSession);
        assertEquals(token1, token2);
    }

    @Test
    public void testRefreshToken() {
        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);

        String token1 = CsrfUtils.getOrCreateToken(mockSession);
        String token2 = CsrfUtils.refreshToken(mockSession);

        assertNotNull(token2);
        assertNotEquals(token1, token2);
        assertEquals(token2, sessionData.get(CsrfUtils.CSRF_TOKEN_ATTR));
    }

    @Test
    public void testValidateWithValidParameter() {
        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);
        String token = CsrfUtils.getOrCreateToken(mockSession);

        Map<String, String> params = new HashMap<>();
        params.put(CsrfUtils.CSRF_PARAM, token);
        Map<String, String> headers = new HashMap<>();

        HttpServletRequest req = createMockRequest(mockSession, params, headers);
        assertTrue("Validate phải trả về true khi parameter trùng khớp", CsrfUtils.validate(req));
    }

    @Test
    public void testValidateWithValidHeader() {
        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);
        String token = CsrfUtils.getOrCreateToken(mockSession);

        Map<String, String> params = new HashMap<>();
        Map<String, String> headers = new HashMap<>();
        headers.put(CsrfUtils.CSRF_HEADER, token);

        HttpServletRequest req = createMockRequest(mockSession, params, headers);
        assertTrue("Validate phải trả về true khi header X-CSRF-TOKEN trùng khớp", CsrfUtils.validate(req));
    }

    @Test
    public void testValidateWithInvalidOrMissingToken() {
        Map<String, Object> sessionData = new HashMap<>();
        HttpSession mockSession = createMockSession(sessionData);
        CsrfUtils.getOrCreateToken(mockSession);

        // Thiếu token
        HttpServletRequest reqNoToken = createMockRequest(mockSession, new HashMap<>(), new HashMap<>());
        assertFalse("Validate phải trả về false khi thiếu token", CsrfUtils.validate(reqNoToken));

        // Token không khớp
        Map<String, String> badParams = new HashMap<>();
        badParams.put(CsrfUtils.CSRF_PARAM, "fake_attacker_token_xyz");
        HttpServletRequest reqBadToken = createMockRequest(mockSession, badParams, new HashMap<>());
        assertFalse("Validate phải trả về false khi token sai lệch", CsrfUtils.validate(reqBadToken));

        // Không có session
        HttpServletRequest reqNoSession = createMockRequest(null, badParams, new HashMap<>());
        assertFalse("Validate phải trả về false khi không có session", CsrfUtils.validate(reqNoSession));
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

    private HttpServletRequest createMockRequest(HttpSession session, Map<String, String> params, Map<String, String> headers) {
        return (HttpServletRequest) Proxy.newProxyInstance(
                HttpServletRequest.class.getClassLoader(),
                new Class<?>[]{HttpServletRequest.class},
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) {
                        String name = method.getName();
                        if ("getSession".equals(name)) {
                            return session;
                        } else if ("getParameter".equals(name) && args != null && args.length == 1) {
                            return params.get(args[0]);
                        } else if ("getHeader".equals(name) && args != null && args.length == 1) {
                            return headers.get(args[0]);
                        }
                        return null;
                    }
                }
        );
    }
}
