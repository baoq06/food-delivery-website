package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.NotificationDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Notification;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.NotificationService;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class CodUnlockAndAutoRecoveryTest {

    private UserDAO userDAO;
    private NotificationDAO notificationDAO;
    private NotificationService notificationService;

    @Before
    public void setUp() {
        userDAO = new UserDAO();
        notificationDAO = new NotificationDAO();
        notificationService = new NotificationService();
        UserDAO.ensureBoomSupport();
    }

    @Test
    public void testAutoRecoveryAfter3DeliveredOrders() {
        int testUserId = 2; // Khách hàng mẫu (customer)

        // 1. Giả lập khách hàng bị bom hàng và khóa COD
        boolean recorded = userDAO.recordCustomerBoom(testUserId, "Khách không nhận đơn test");
        assertTrue("Ghi nhận bom hàng phải thành công", recorded);

        assertTrue("Khách hàng phải bị khóa COD", userDAO.isCustomerCodLocked(testUserId));
        assertEquals("Tiến độ đơn uy tín ban đầu phải là 0", 0, userDAO.getCodTrustOrders(testUserId));

        // 2. Khách hoàn thành đơn thứ 1
        boolean unlocked1 = userDAO.recordCompletedOrderForCodProgress(testUserId);
        assertFalse("Đơn thứ 1 chưa đủ điều kiện mở lại COD", unlocked1);
        assertTrue("Sau đơn 1 vẫn còn bị khóa COD", userDAO.isCustomerCodLocked(testUserId));
        assertEquals("Tiến độ sau đơn 1 phải là 1", 1, userDAO.getCodTrustOrders(testUserId));

        // 3. Khách hoàn thành đơn thứ 2
        boolean unlocked2 = userDAO.recordCompletedOrderForCodProgress(testUserId);
        assertFalse("Đơn thứ 2 chưa đủ điều kiện mở lại COD", unlocked2);
        assertTrue("Sau đơn 2 vẫn còn bị khóa COD", userDAO.isCustomerCodLocked(testUserId));
        assertEquals("Tiến độ sau đơn 2 phải là 2", 2, userDAO.getCodTrustOrders(testUserId));

        // 4. Khách hoàn thành đơn thứ 3 -> Tự động mở khóa COD thành công!
        boolean unlocked3 = userDAO.recordCompletedOrderForCodProgress(testUserId);
        assertTrue("Đơn thứ 3 phải kích hoạt tự động mở khóa COD thành công", unlocked3);
        assertFalse("Khách hàng không còn bị khóa COD nữa", userDAO.isCustomerCodLocked(testUserId));
        assertEquals("Tiến độ phải được reset về 0 sau khi mở khóa", 0, userDAO.getCodTrustOrders(testUserId));
    }

    @Test
    public void testManualUnlockCodByAdmin() {
        int testUserId = 2;

        // Khóa COD
        userDAO.recordCustomerBoom(testUserId, "Test khóa để Admin mở");
        assertTrue(userDAO.isCustomerCodLocked(testUserId));

        // Admin mở khóa thủ công
        boolean unlocked = userDAO.unlockCustomerCod(testUserId);
        assertTrue("Admin mở khóa thủ công phải thành công", unlocked);
        assertFalse("Sau khi Admin mở, khách không còn bị khóa COD", userDAO.isCustomerCodLocked(testUserId));
        assertEquals("Tiến độ phải là 0", 0, userDAO.getCodTrustOrders(testUserId));
    }

    @Test
    public void testNotificationOnCodUnlock() {
        int testUserId = 2;
        int testOrderId = 88888;

        // 1. Kiểm tra thông báo khi Admin mở thủ công
        notificationService.notifyCodUnlockedByAdmin(testUserId);
        List<Notification> notifsAdmin = notificationDAO.getNotificationsByUser(testUserId, "ALL");
        assertNotNull(notifsAdmin);
        boolean foundAdminUnlock = false;
        for (Notification n : notifsAdmin) {
            if (n.getTitle() != null && n.getTitle().contains("Thanh toán Tiền mặt (COD) đã được mở lại")) {
                foundAdminUnlock = true;
                break;
            }
        }
        assertTrue("Phải có thông báo Admin mở lại COD cho khách", foundAdminUnlock);

        // 2. Kiểm tra thông báo khi tự động mở sau 3 đơn
        notificationService.notifyCodAutoUnlocked(testUserId, testOrderId);
        List<Notification> notifsAuto = notificationDAO.getNotificationsByUser(testUserId, "ALL");
        assertNotNull(notifsAuto);
        boolean foundAutoUnlock = false;
        for (Notification n : notifsAuto) {
            if (n.getMessage() != null && n.getMessage().contains("3 đơn hàng")) {
                foundAutoUnlock = true;
                break;
            }
        }
        assertTrue("Phải có thông báo hoàn thành 3 đơn tự động mở COD", foundAutoUnlock);
    }

    @Test
    public void testGetCustomersForCodManagement() {
        List<User> customers = userDAO.getCustomersForCodManagement(null);
        assertNotNull("Danh sách khách hàng không được null", customers);
        assertFalse("Danh sách khách hàng phải có dữ liệu", customers.isEmpty());

        for (User u : customers) {
            assertTrue("Role phải là CUSTOMER", u.isCustomer() || u.getRole() == null || "CUSTOMER".equalsIgnoreCase(u.getRole()));
        }
    }
}
