package com.ute.fooddelivery.utils;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class CookieUtils {

    /**
     * Thêm hoặc cập nhật một Cookie với mã hóa UTF-8 và đường dẫn toàn site (/)
     */
    public static void addCookie(HttpServletResponse resp, String name, String value, int maxAgeInSeconds) {
        try {
            String encodedValue = URLEncoder.encode(value != null ? value : "", StandardCharsets.UTF_8);
            Cookie cookie = new Cookie(name, encodedValue);
            cookie.setMaxAge(maxAgeInSeconds);
            cookie.setPath("/");
            cookie.setHttpOnly(false); // Cho phép tương thích tốt
            resp.addCookie(cookie);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy giá trị của Cookie theo tên, tự động giải mã UTF-8
     */
    public static String getCookieValue(HttpServletRequest req, String name) {
        if (req == null || name == null) return null;
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if (name.equals(c.getName())) {
                    try {
                        return URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8);
                    } catch (Exception e) {
                        return c.getValue();
                    }
                }
            }
        }
        return null;
    }

    /**
     * Xóa một Cookie bằng cách đặt maxAge = 0
     */
    public static void deleteCookie(HttpServletResponse resp, String name) {
        if (resp == null || name == null) return;
        Cookie cookie = new Cookie(name, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        resp.addCookie(cookie);
    }

    /**
     * Chuyển chuỗi các ID cách nhau bằng dấu phẩy thành danh sách Integer
     * Ví dụ: "3,1,5" -> [3, 1, 5]
     */
    public static List<Integer> parseIdList(String idStr) {
        List<Integer> list = new ArrayList<>();
        if (idStr == null || idStr.trim().isEmpty()) return list;
        String[] parts = idStr.split(",");
        for (String p : parts) {
            try {
                int id = Integer.parseInt(p.trim());
                if (!list.contains(id)) {
                    list.add(id);
                }
            } catch (NumberFormatException ignored) {
            }
        }
        return list;
    }

    /**
     * Chuyển danh sách Integer thành chuỗi cách nhau bằng dấu phẩy
     */
    public static String formatIdList(List<Integer> list) {
        if (list == null || list.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < list.size(); i++) {
            sb.append(list.get(i));
            if (i < list.size() - 1) {
                sb.append(",");
            }
        }
        return sb.toString();
    }
}
