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
                // Dọn sạch các đơn treo cũ của driver test để không bị tính là đang giao đơn khác
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement psClean = conn.prepareStatement("UPDATE orders SET status = 'DELIVERED', shipper_delivered = 1 WHERE driver_id = ? AND status = 'SHIPPING'")) {
                    psClean.setInt(1, testDriverId);
                    psClean.executeUpdate();
                } catch (Exception ignored) {}
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
        // BƯỚC 1: KHÁCH ĐẶT ĐƠN HÀNG MỚI (KÈM TÍNH PHÍ SHIP THEO KM)
        // =========================================================================
        double testDistance = 3.5; // 3.5 km
        double calculatedShippingFee = com.ute.fooddelivery.utils.GeoLocationUtils.calculateShippingFee(testDistance);
        assertEquals("Phí ship cho 3.5km (làm tròn lên 4km) phải là 25.000đ", 25000.0, calculatedShippingFee, 0.01);

        double testAmount = 189000.0 + calculatedShippingFee;
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

            String sql = "INSERT INTO orders (user_id, customer_name, total_amount, status, address, phone, payment_method, note, shipper_accepted, shipper_delivered, merchant_completed, customer_confirmed, merchant_confirmed, shipping_fee, distance_km, shipper_picked_up) " +
                    "VALUES (?, 'Khách Hàng Kiểm Thử', ?, 'PENDING', '123 Đường Kiểm Thử, TP.Thủ Đức', '0912345678', 'COD', 'Đơn test 3 bên', 0, 0, 0, 0, 0, ?, ?, 0)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, testCustomerId);
                ps.setDouble(2, testAmount);
                ps.setDouble(3, calculatedShippingFee);
                ps.setDouble(4, testDistance);
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
                    psItem.setDouble(3, 189000.0 / 2.0);
                    psItem.setDouble(4, 189000.0);
                    psItem.executeUpdate();
                }
            }
        }
        assertTrue("Mã đơn hàng test phải > 0", testOrderId > 0);

        Order initialOrder = orderDAO.getOrderById(testOrderId);
        assertNotNull(initialOrder);
        assertEquals("PENDING", initialOrder.getStatus());
        assertEquals(25000.0, initialOrder.getShippingFee(), 0.01);
        assertEquals(3.5, initialOrder.getDistanceKm(), 0.01);
        assertFalse("shipper_accepted ban đầu phải = false", initialOrder.isShipperAccepted());
        assertFalse("shipper_picked_up ban đầu phải = false", initialOrder.isShipperPickedUp());
        assertFalse("shipper_delivered ban đầu phải = false", initialOrder.isShipperDelivered());
        assertFalse("customer_confirmed ban đầu phải = false", initialOrder.isCustomerConfirmed());
        assertFalse("merchant_completed ban đầu phải = false", initialOrder.isMerchantCompleted());
        assertFalse("Quán chưa thể bắt đầu nấu nếu chưa có shipper xác nhận", initialOrder.canStartCooking());

        // =========================================================================
        // BƯỚC 2: QUÁN GÁN TÀI XẾ SHIPPER THEO THUẬT TOÁN CỰ LY
        // =========================================================================
        // Cập nhật vị trí test cho driver
        driverDAO.updateLocation(testDriverId, 10.850721, 106.771960, "HCMUTE, Võ Văn Ngân, TP. Thủ Đức");
        List<Driver> nearestList = driverDAO.findNearestDrivers(10.850000, 106.770000);
        assertNotNull("Danh sách tài xế gần quán", nearestList);

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
        assertTrue("Quán BÂY GIỜ ĐÃ ĐỦ ĐIỀU KIỆN để bắt đầu nấu", acceptedOrder.canStartCooking());

        // Radar của driver không còn hiển thị đơn này là 'chờ gán' nữa vì đã nhận rồi
        Order pendingAfterAccept = orderDAO.getPendingAssignedOrderForDriver(testDriverId);
        assertNull("Đơn đã nhận thì không còn ở trạng thái pending assigned", pendingAfterAccept);

        // Tài xế chuyển sang BUSY
        Driver d = driverDAO.getDriverById(testDriverId);
        assertEquals("BUSY", d.getStatus());

        // =========================================================================
        // BƯỚC 4: QUÁN XÁC NHẬN MÓN ĂN & BÀN GIAO
        // =========================================================================
        boolean cooking = orderDAO.updateOrderStatus(testOrderId, "CONFIRMED");
        assertTrue("Quán xác nhận đơn", cooking);

        // =========================================================================
        // BƯỚC 5: SHIPPER ĐẾN QUÁN & XÁC NHẬN ĐÃ LẤY MÓN TỪ QUÁN (BƯỚC MỚI)
        // =========================================================================
        boolean pickedUp = orderDAO.shipperConfirmPickedUp(testOrderId, testDriverId);
        assertTrue("Shipper xác nhận đã lấy món từ quán thành công", pickedUp);

        Order afterPickedUpOrder = orderDAO.getOrderById(testOrderId);
        assertTrue("shipper_picked_up phải = true", afterPickedUpOrder.isShipperPickedUp());
        assertEquals("SHIPPING", afterPickedUpOrder.getStatus());

        // =========================================================================
        // BƯỚC 6: SHIPPER BÁO ĐÃ GIAO XONG CHO KHÁCH -> ĐƠN HOÀN TẤT NGAY LẬP TỨC
        // =========================================================================
        boolean shipperDone = orderDAO.shipperConfirmDelivered(testOrderId, testDriverId);
        assertTrue("Shipper xác nhận giao thành công", shipperDone);

        Order finalDeliveredOrder = orderDAO.getOrderById(testOrderId);
        assertTrue("shipper_delivered phải = true", finalDeliveredOrder.isShipperDelivered());
        assertEquals("Đơn hàng hoàn tất ngay lập tức thành DELIVERED không cần đợi khách", "DELIVERED", finalDeliveredOrder.getStatus());
        assertTrue("merchant_completed tự động set = true để tính doanh thu", finalDeliveredOrder.isMerchantCompleted());

        // Tài xế được tự động giải phóng về AVAILABLE sau khi hoàn thành đơn
        Driver driverAfterFinish = driverDAO.getDriverById(testDriverId);
        assertEquals("Tài xế sẵn sàng nhận đơn mới", "AVAILABLE", driverAfterFinish.getStatus());

        // =========================================================================
        // BƯỚC 7: KHÁCH VẪN CÓ THỂ XÁC NHẬN ĐÃ NHẬN MÓN & ĐÁNH GIÁ (TÙY CHỌN, KHÔNG BẮT BUỘC)
        // =========================================================================
        boolean customerDone = orderDAO.confirmCustomerOrder(testOrderId);
        assertTrue("Khách bấm xác nhận nhận món", customerDone);

        Order finalCustomerConfirmed = orderDAO.getOrderById(testOrderId);
        assertTrue("customer_confirmed = true", finalCustomerConfirmed.isCustomerConfirmed());
        assertEquals("DELIVERED", finalCustomerConfirmed.getStatus());
    }
}
