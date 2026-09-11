package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.*;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.Notification;
import com.ute.fooddelivery.model.Order;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.NotificationService;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.List;

import static org.junit.Assert.*;

public class ThreePartyOrderFlowTest {

    private OrderDAO orderDAO;
    private DriverDAO driverDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;
    private NotificationService notificationService;

    private int testOrderId = -1;
    private int testDriverId = -1;
    private int testDriverUserId = -1;
    private int testCustomerId = -1;
    private int testRestaurantId = 1;

    @Before
    public void setUp() throws Exception {
        orderDAO = new OrderDAO();
        driverDAO = new DriverDAO();
        userDAO = new UserDAO();
        notificationDAO = new NotificationDAO();
        notificationService = new NotificationService();

        // Tìm tài xế khả dụng (hoặc kaitokid)
        User kaito = userDAO.login("kaitokid", "123456");
        if (kaito != null) {
            testDriverUserId = kaito.getId();
            Driver d = driverDAO.getDriverByUserId(testDriverUserId);
            if (d != null) {
                testDriverId = d.getId();
                driverDAO.updateStatus(testDriverId, "AVAILABLE");
            }
        }

        // Tìm một khách hàng hoặc user có id hợp lệ
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM users WHERE role = 'CUSTOMER' LIMIT 1")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        testCustomerId = rs.getInt("user_id");
                    }
                }
            }
            if (testCustomerId <= 0 && kaito != null) {
                testCustomerId = kaito.getId();
            }

            // Tìm restaurantId hợp lệ
            try (PreparedStatement ps = conn.prepareStatement("SELECT restaurant_id FROM restaurants LIMIT 1")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        testRestaurantId = rs.getInt("restaurant_id");
                    }
                }
            }
        }
    }

    @After
    public void tearDown() {
        if (testOrderId > 0) {
            try (Connection conn = DBContext.getConnection()) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM order_items WHERE order_id = ?")) {
                    ps.setInt(1, testOrderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE order_id = ?")) {
                    ps.setInt(1, testOrderId);
                    ps.executeUpdate();
                }
            } catch (Exception ignored) {}
        }
        if (testDriverId > 0) {
            driverDAO.updateStatus(testDriverId, "AVAILABLE");
        }
    }

    @Test
    public void testNotificationSystem() {
        assertNotNull("NotificationDAO should initialize", notificationDAO);
        if (testDriverUserId > 0) {
            // Tạo thông báo thử nghiệm
            Notification notif = new Notification(
                    testDriverUserId,
                    null,
                    "Đơn hàng thử nghiệm 3 bên",
                    "Chi tiết thông báo thử nghiệm",
                    "ORDER_ASSIGNED",
                    "/shipper/dashboard"
            );
            boolean created = notificationDAO.createNotification(notif);
            assertTrue("Tạo thông báo thành công", created);

            // Kiểm tra số lượng thông báo chưa đọc
            int unread = notificationDAO.getUnreadCount(testDriverUserId);
            assertTrue("Số thông báo chưa đọc >= 1", unread >= 1);

            // Đọc danh sách thông báo
            List<Notification> list = notificationDAO.getNotificationsByUser(testDriverUserId, "ALL");
            assertNotNull("Danh sách thông báo không null", list);
            assertTrue("Có ít nhất 1 thông báo trong danh sách", list.size() > 0);

            // Đánh dấu đã đọc tất cả
            notificationDAO.markAllAsRead(testDriverUserId);
            assertEquals("Số chưa đọc sau khi mark all phải = 0", 0, notificationDAO.getUnreadCount(testDriverUserId));
        }
    }

    @Test
    public void testCompleteThreePartyVerificationWorkflow() throws Exception {
        assertTrue("Cần testCustomerId hợp lệ", testCustomerId > 0);
        assertTrue("Cần testDriverId hợp lệ", testDriverId > 0);

        // =========================================================================
        // BƯỚC 1: KHÁCH ĐẶT ĐƠN HÀNG MỚI
        // =========================================================================
        double testAmount = 189000.0;
        try (Connection conn = DBContext.getConnection()) {
            int foodId = 1;
            try (PreparedStatement psFood = conn.prepareStatement("SELECT food_id FROM foods WHERE restaurant_id = ? LIMIT 1")) {
                psFood.setInt(1, testRestaurantId);
                try (ResultSet rsF = psFood.executeQuery()) {
                    if (rsF.next()) {
                        foodId = rsF.getInt("food_id");
                    }
                }
            }

            String sql = "INSERT INTO orders (user_id, customer_name, total_amount, status, address, phone, payment_method, note, shipper_accepted, shipper_delivered, merchant_completed, customer_confirmed, merchant_confirmed) " +
                    "VALUES (?, 'Khách Hàng Kiểm Thử', ?, 'PENDING', '123 Đường Kiểm Thử, TP.Thủ Đức', '0912345678', 'COD', 'Đơn test 3 bên', 0, 0, 0, 0, 0)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, testCustomerId);
                ps.setDouble(2, testAmount);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        testOrderId = rs.getInt(1);
                    }
                }
            }

            if (testOrderId > 0) {
                String sqlItem = "INSERT INTO order_items (order_id, food_id, quantity, unit_price, subtotal) VALUES (?, ?, 2, ?, ?)";
                try (PreparedStatement psItem = conn.prepareStatement(sqlItem)) {
                    psItem.setInt(1, testOrderId);
                    psItem.setInt(2, foodId);
                    psItem.setDouble(3, testAmount / 2.0);
                    psItem.setDouble(4, testAmount);
                    psItem.executeUpdate();
                }
            }
        }
        assertTrue("Mã đơn hàng test phải > 0", testOrderId > 0);

        Order initialOrder = orderDAO.getOrderById(testOrderId);
        assertNotNull(initialOrder);
        assertEquals("PENDING", initialOrder.getStatus());
        assertFalse("shipper_accepted ban đầu phải = false", initialOrder.isShipperAccepted());
        assertFalse("shipper_delivered ban đầu phải = false", initialOrder.isShipperDelivered());
        assertFalse("customer_confirmed ban đầu phải = false", initialOrder.isCustomerConfirmed());
        assertFalse("merchant_completed ban đầu phải = false", initialOrder.isMerchantCompleted());
        assertFalse("Quán chưa thể bắt đầu nấu nếu chưa có shipper xác nhận", initialOrder.canStartCooking());

        // =========================================================================
        // BƯỚC 2: QUÁN GÁN TÀI XẾ SHIIPER KHẢ DỤNG
        // =========================================================================
        boolean assigned = orderDAO.assignDriver(testOrderId, testDriverId);
        assertTrue("Gán shipper cho đơn hàng thành công", assigned);

        Order assignedOrder = orderDAO.getOrderById(testOrderId);
        assertEquals((Integer) testDriverId, assignedOrder.getDriverId());
        assertFalse("Shipper chưa accept thì shipper_accepted vẫn = false", assignedOrder.isShipperAccepted());
        assertFalse("Quán vẫn chưa được nấu", assignedOrder.canStartCooking());

        // Kiểm tra radar / dispatch của driver: phải phát hiện đơn được gán
        Order pendingForDriver = orderDAO.getPendingAssignedOrderForDriver(testDriverId);
        assertNotNull("Tài xế phải nhận diện được đơn được quán chỉ định", pendingForDriver);
        assertEquals(testOrderId, pendingForDriver.getId());

        // =========================================================================
        // BƯỚC 3: SHIPPER XÁC NHẬN ĐỒNG Ý GIAO ĐƠN
        // =========================================================================
        boolean accepted = orderDAO.shipperAcceptOrder(testOrderId, testDriverId);
        assertTrue("Shipper bấm nhận đơn thành công", accepted);

        Order acceptedOrder = orderDAO.getOrderById(testOrderId);
        assertTrue("shipper_accepted lúc này phải = true", acceptedOrder.isShipperAccepted());
        assertTrue("Quán BÂY GIỜ ĐÃ ĐỦ ĐIỀU KIỆN để bắt đầu nấu & giao", acceptedOrder.canStartCooking());

        // Radar của driver không còn hiển thị đơn này là 'chờ gán' nữa vì đã nhận rồi
        Order pendingAfterAccept = orderDAO.getPendingAssignedOrderForDriver(testDriverId);
        assertNull("Đơn đã nhận thì không còn ở trạng thái pending assigned", pendingAfterAccept);

        // Tài xế chuyển sang BUSY
        Driver d = driverDAO.getDriverById(testDriverId);
        assertEquals("BUSY", d.getStatus());

        // =========================================================================
        // BƯỚC 4: QUÁN CHUYỂN SANG ĐANG CHẾ BIẾN & GIAO SHIPPER
        // =========================================================================
        boolean cooking = orderDAO.updateOrderStatus(testOrderId, "SHIPPING");
        assertTrue("Quán chuyển sang SHIPPING thành công", cooking);

        Order shippingOrder = orderDAO.getOrderById(testOrderId);
        assertEquals("SHIPPING", shippingOrder.getStatus());
        assertFalse("Chưa hoàn tất xác nhận 2 bên", shippingOrder.isReadyForMerchantComplete());

        // =========================================================================
        // BƯỚC 5: SHIPPER VÀ KHÁCH HÀNG XÁC NHẬN ĐỘC LẬP
        // =========================================================================
        // 5a. Shipper báo đã giao tới nơi
        boolean shipperDone = orderDAO.shipperConfirmDelivered(testOrderId);
        assertTrue("Shipper xác nhận giao thành công", shipperDone);

        Order afterShipperDelivered = orderDAO.getOrderById(testOrderId);
        assertTrue("shipper_delivered phải = true", afterShipperDelivered.isShipperDelivered());
        assertFalse("Khách chưa nhận nên readyForMerchantComplete vẫn phải = false", afterShipperDelivered.isReadyForMerchantComplete());

        // 5b. Khách hàng xác nhận đã nhận được món
        boolean customerDone = orderDAO.confirmCustomerOrder(testOrderId);
        assertTrue("Khách hàng bấm xác nhận nhận món thành công", customerDone);

        Order afterBothConfirmed = orderDAO.getOrderById(testOrderId);
        assertTrue("customer_confirmed phải = true", afterBothConfirmed.isCustomerConfirmed());
        assertTrue("CẢ 2 BÊN ĐÃ XÁC NHẬN -> SẴN SÀNG ĐỂ QUÁN DUYỆT HOÀN TẤT!", afterBothConfirmed.isReadyForMerchantComplete());

        // =========================================================================
        // BƯỚC 6: CHỦ QUÁN DUYỆT HOÀN THÀNH ĐƠN HÀNG -> GHI NHẬN DOANH THU
        // =========================================================================
        boolean completed = orderDAO.merchantCompleteOrder(testOrderId);
        assertTrue("Chủ quán duyệt hoàn tất đơn thành công", completed);

        Order finalOrder = orderDAO.getOrderById(testOrderId);
        assertEquals("DELIVERED", finalOrder.getStatus());
        assertTrue("merchant_completed phải = true", finalOrder.isMerchantCompleted());

        // Tài xế được tự động trả về AVAILABLE sau khi đơn hoàn tất
        Driver driverAfterFinish = driverDAO.getDriverById(testDriverId);
        assertEquals("AVAILABLE", driverAfterFinish.getStatus());
    }
}
