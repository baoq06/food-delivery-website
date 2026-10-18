package com.ute.fooddelivery.utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Tiện ích quản lý và kiểm tra CSRF (Cross-Site Request Forgery) Token
 * nhằm bảo vệ các thao tác nhạy cảm trên hệ thống (đặc biệt là các nghiệp vụ Shipper, Merchant, Admin).
 */
public class CsrfUtils {
    public static final String CSRF_TOKEN_ATTR = "csrfToken";
    public static final String CSRF_PARAM = "csrfToken";
    public static final String CSRF_HEADER = "X-CSRF-TOKEN";

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    /**
     * Lấy token hiện tại trong session hoặc tạo mới nếu chưa có.
     *
     * @param session HttpSession của người dùng
     * @return Mã token CSRF bảo mật
     */
    public static String getOrCreateToken(HttpSession session) {
        if (session == null) {
            return null;
        }
        String token = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (token == null || token.trim().isEmpty()) {
            token = generateNewToken();
            session.setAttribute(CSRF_TOKEN_ATTR, token);
        }
        return token;
    }

    /**
     * Tạo một chuỗi token ngẫu nhiên bảo mật bằng SecureRandom
     */
    public static String generateNewToken() {
        byte[] bytes = new byte[32];
        SECURE_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /**
     * Làm mới token trong session (chống session fixation / sau khi login)
     */
    public static String refreshToken(HttpSession session) {
        if (session == null) {
            return null;
        }
        String newToken = generateNewToken();
        session.setAttribute(CSRF_TOKEN_ATTR, newToken);
        return newToken;
    }

    /**
     * Xác thực CSRF token từ HttpServletRequest gửi lên (qua tham số form hoặc header HTTP)
     *
     * @param request HttpServletRequest
     * @return true nếu token hợp lệ và trùng khớp với session, false nếu không hợp lệ
     */
    public static boolean validate(HttpServletRequest request) {
        if (request == null) {
            return false;
        }
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        String expectedToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (expectedToken == null || expectedToken.trim().isEmpty()) {
            return false;
        }

        // 1. Kiểm tra tham số từ request parameter (form POST)
        String actualToken = request.getParameter(CSRF_PARAM);

        // 2. Nếu không có ở parameter, kiểm tra HTTP header (X-CSRF-TOKEN dùng cho fetch/ajax)
        if (actualToken == null || actualToken.trim().isEmpty()) {
            actualToken = request.getHeader(CSRF_HEADER);
        }

        if (actualToken == null || actualToken.trim().isEmpty()) {
            return false;
        }

        // So sánh chuỗi an toàn chống timing attack
        return safeEquals(expectedToken.trim(), actualToken.trim());
    }

    /**
     * So sánh 2 chuỗi với thời gian hằng số để ngăn chặn tấn công timing attack
     */
    private static boolean safeEquals(String a, String b) {
        byte[] aBytes = a.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] bBytes = b.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        if (aBytes.length != bBytes.length) {
            return false;
        }
        int result = 0;
        for (int i = 0; i < aBytes.length; i++) {
            result |= aBytes[i] ^ bBytes[i];
        }
        return result == 0;
    }
}
