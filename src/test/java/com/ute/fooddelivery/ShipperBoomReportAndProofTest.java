package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.NotificationDAO;
import com.ute.fooddelivery.dao.OrderDAO;
import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.Notification;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.service.NotificationService;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class ShipperBoomReportAndProofTest {

    private UserDAO userDAO;
    private OrderDAO orderDAO;
    private NotificationDAO notificationDAO;
    private NotificationService notificationService;

    @Before
    public void setUp() {
        userDAO = new UserDAO();
        orderDAO = new OrderDAO();
        notificationDAO = new NotificationDAO();
        notificationService = new NotificationService();
        UserDAO.ensureBoomSupport();
        OrderDAO.ensureOrderDiscountColumns();
    }

    @Test
    public void testGetAdminUserIdsReturnsValidList() {
        List<Integer> adminIds = userDAO.getAdminUserIds();
        assertNotNull("Danh sách ID Admin không được null", adminIds);
        assertFalse("Danh sách ID Admin không được rỗng", adminIds.isEmpty());
        assertTrue("Admin ID mặc định tối thiểu phải chứa ID 1 hoặc admin thực tế", adminIds.contains(1) || adminIds.get(0) > 0);
    }

    @Test
    public void testNotificationServiceNotifyBoomReportedToAllParties() {
        int testCustomerUserId = 2; // customer
        int testMerchantUserId = 5; // bepviet
        int testOrderId = 99999;
        String reason = "Khách không nghe máy sau 3 cuộc gọi";
        String note = "Gọi lúc 12:00, 12:06, 12:12 không bắt máy. Đã đợi 15 phút tại cổng.";
        String proofUrl = "/assets/uploads/proofs/call_log_evidence_123.jpg";

        // Thực thi gửi thông báo
        notificationService.notifyBoomReported(testCustomerUserId, testMerchantUserId, testOrderId, reason, note, proofUrl);

        // Kiểm tra thông báo của Khách hàng
        List<Notification> customerNotifs = notificationDAO.getNotificationsByUser(testCustomerUserId, "ALL");
        assertNotNull(customerNotifs);
        boolean foundCustomerNotif = false;
        for (Notification n : customerNotifs) {
            if (n.getOrderId() != null && n.getOrderId() == testOrderId) {
                foundCustomerNotif = true;
                assertTrue("Thông báo khách phải chứa cảnh báo khóa COD", n.getTitle().contains("Khóa COD") || n.getMessage().contains("khóa"));
                assertTrue("Thông báo khách phải chứa ghi chú hoặc lý do", n.getMessage().contains(reason) || n.getMessage().contains(note));
                break;
            }
        }
        assertTrue("Phải tạo thông báo gửi đến Khách hàng", foundCustomerNotif);

        // Kiểm tra thông báo gửi đến Admin
        List<Integer> adminIds = userDAO.getAdminUserIds();
        boolean foundAdminNotif = false;
        for (Integer adminId : adminIds) {
            List<Notification> adminNotifs = notificationDAO.getNotificationsByUser(adminId, "ALL");
            if (adminNotifs != null) {
                for (Notification n : adminNotifs) {
                    if (n.getOrderId() != null && n.getOrderId() == testOrderId) {
                        foundAdminNotif = true;
                        assertTrue("Thông báo Admin phải chứa cảnh báo kiểm tra", n.getTitle().contains("Kiểm tra") || n.getTitle().contains("Bom hàng"));
                        assertTrue("Thông báo Admin phải chứa link bằng chứng", n.getMessage().contains(proofUrl) || n.getMessage().contains("Bằng chứng"));
                        break;
                    }
                }
            }
            if (foundAdminNotif) break;
        }
        assertTrue("Phải tạo thông báo gửi đến Ban Quản Trị (Admin)", foundAdminNotif);
    }

    @Test
    public void testOrderModelProofImageGetterSetter() {
        Order order = new Order();
        assertNull(order.getProofImage());
        String proofPath = "/assets/uploads/proofs/test_proof.jpg";
        order.setProofImage(proofPath);
        assertEquals(proofPath, order.getProofImage());
    }
}
