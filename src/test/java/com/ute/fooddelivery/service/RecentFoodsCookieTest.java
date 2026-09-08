package com.ute.fooddelivery.service;

import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.utils.CookieUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.junit.Assert;
import org.junit.Test;

import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RecentFoodsCookieTest {

    private HttpServletRequest createMockRequest(User user) {
        HttpSession session = null;
        if (user != null) {
            session = (HttpSession) Proxy.newProxyInstance(
                HttpSession.class.getClassLoader(),
                new Class<?>[]{HttpSession.class},
                (proxy, method, args) -> {
                    if ("getAttribute".equals(method.getName()) && args != null && "currentUser".equals(args[0])) {
                        return user;
                    }
                    return null;
                }
            );
        }

        final HttpSession finalSession = session;
        return (HttpServletRequest) Proxy.newProxyInstance(
            HttpServletRequest.class.getClassLoader(),
            new Class<?>[]{HttpServletRequest.class},
            (proxy, method, args) -> {
                if ("getSession".equals(method.getName())) {
                    return finalSession;
                }
                return null;
            }
        );
    }

    @Test
    public void testGuestRecentCookieName() {
        HttpServletRequest req = createMockRequest(null);
        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
        Assert.assertEquals("recent_foods_guest", cookieName);
    }

    @Test
    public void testCustomerRecentCookieName() {
        User customer = new User(2, "customer", "123456", "Nguyễn Văn Khách", "khach@gmail.com", "0987654321", "123 Lê Lợi", "CUSTOMER");
        HttpServletRequest req = createMockRequest(customer);

        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
        Assert.assertEquals("recent_foods_u2", cookieName);
    }

    @Test
    public void testDifferentAccountRecentCookieName() {
        User seller = new User(5, "bepviet", "123456", "Chủ Quán Bếp Việt", "bepviet@foodzone.vn", "0901234567", "45 Lê Lợi", "SELLER");
        HttpServletRequest req = createMockRequest(seller);

        String cookieName = CookieUtils.getRecentFoodsCookieName(req);
        Assert.assertEquals("recent_foods_u5", cookieName);
        Assert.assertNotEquals("recent_foods_u2", cookieName);
    }

    @Test
    public void testNewlyCreatedAccountCookieName() {
        // Tài khoản mới đăng ký tự tăng ID trong CSDL (ví dụ ID = 12)
        User newAccWithId = new User(12, "minhhoang", "123456", "Trần Minh Hoàng", "hoang@gmail.com", "0912345678", "Hà Nội", "CUSTOMER");
        HttpServletRequest req1 = createMockRequest(newAccWithId);
        Assert.assertEquals("recent_foods_u12", CookieUtils.getRecentFoodsCookieName(req1));

        // Tài khoản mới trước khi lấy ID (fallback username)
        User newAccWithoutId = new User(0, "lananh", "123456", "Lê Lan Anh", "lan@gmail.com", "0912345679", "Đà Nẵng", "CUSTOMER");
        HttpServletRequest req2 = createMockRequest(newAccWithoutId);
        Assert.assertEquals("recent_foods_u_lananh", CookieUtils.getRecentFoodsCookieName(req2));

        // Đảm bảo không trùng nhau
        Assert.assertNotEquals(CookieUtils.getRecentFoodsCookieName(req1), CookieUtils.getRecentFoodsCookieName(req2));
    }

    @Test
    public void testIdListFormattingAndParsing() {
        List<Integer> ids = new ArrayList<>(Arrays.asList(3, 1, 5));
        String formatted = CookieUtils.formatIdList(ids);
        Assert.assertEquals("3,1,5", formatted);

        List<Integer> parsed = CookieUtils.parseIdList(formatted);
        Assert.assertEquals(3, parsed.size());
        Assert.assertEquals(Integer.valueOf(3), parsed.get(0));
        Assert.assertEquals(Integer.valueOf(1), parsed.get(1));
        Assert.assertEquals(Integer.valueOf(5), parsed.get(2));
    }
}
