package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.*;
import com.ute.fooddelivery.model.Driver;
import com.ute.fooddelivery.model.DriverWalletTransaction;
import com.ute.fooddelivery.model.Order;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

import static org.junit.Assert.*;

public class ShipperCodWalletWorkflowTest {

    private OrderDAO orderDAO;
    private DriverDAO driverDAO;

    private int testOrderId = -1;
    private int testDriverId = -1;
    private int testCustomerId = -1;
    private double initialBalance = 0.0;

    @Before
    public void setUp() throws Exception {
        orderDAO = new OrderDAO();
        driverDAO = new DriverDAO();

        // 1. Tìm tài xế kiểm thử (ưu tiên tài xế có tên 'kiet' hoặc bất kỳ shipper active nào)
        try (Connection conn = DBContext.getConnection()) {
            String driverSql = "SELECT d.driver_id, d.wallet_balance FROM drivers d JOIN users u ON d.user_id = u.user_id WHERE u.name LIKE '%kiet%' OR u.role = 'SHIPPER' LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(driverSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    testDriverId = rs.getInt("driver_id");
                }
            }

            // 2. Tìm một khách hàng hợp lệ
            try (PreparedStatement ps = conn.prepareStatement("SELECT user_id FROM users WHERE role = 'CUSTOMER' LIMIT 1");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    testCustomerId = rs.getInt("user_id");
                }
            }
            if (testCustomerId <= 0) {
                testCustomerId = 1;
            }
        }

        assertTrue("Phải tìm thấy tài xế để thử nghiệm", testDriverId > 0);
        initialBalance = 350000.0;
        driverDAO.updateWalletBalance(testDriverId, initialBalance);
        driverDAO.updateStatus(testDriverId, "AVAILABLE");
    }

    @Test
    public void testCodOrderDeliveryAndWalletSettlement() throws Exception {
        double orderFoodAmount = 120000.0;
        double shippingFee = 25000.0;
        double totalCodAmount = orderFoodAmount + shippingFee; // 145.000 đ thu khách

        // BƯỚC 1: Tạo đơn hàng COD mới
        try (Connection conn = DBContext.getConnection()) {
            String sql = "INSERT INTO orders (user_id, customer_name, total_amount, status, address, phone, payment_method, note, shipper_accepted, shipper_delivered, merchant_completed, customer_confirmed, merchant_confirmed, shipping_fee, distance_km, shipper_picked_up) " +
                    "VALUES (?, 'Khách Hàng Test COD', ?, 'PENDING', 'Số 1 Võ Văn Ngân, TP. Thủ Đức', '0909123456', 'COD', 'Đơn test ví COD shipper', 0, 0, 0, 0, 0, ?, 3.5, 0)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, testCustomerId);
                ps.setDouble(2, totalCodAmount);
                ps.setDouble(3, shippingFee);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        testOrderId = rs.getInt(1);
                    }
                }
            }
        }
        assertTrue("Tạo đơn hàng COD thành công", testOrderId > 0);

        // BƯỚC 2: Quán chỉ định tài xế
        boolean assigned = orderDAO.assignDriver(testOrderId, testDriverId);
        assertTrue("Quán chỉ định shipper cho đơn hàng", assigned);

        // BƯỚC 3: Shipper bấm chấp nhận đơn hàng
        boolean accepted = orderDAO.shipperAcceptOrder(testOrderId, testDriverId);
        assertTrue("Shipper bấm nhận đơn thành công", accepted);

        Driver busyDriver = driverDAO.getDriverById(testDriverId);
        assertEquals("Tài xế chuyển sang BUSY", "BUSY", busyDriver.getStatus());

        // BƯỚC 4: Quán xác nhận đã làm xong món (CONFIRMED)
        orderDAO.updateOrderStatus(testOrderId, "CONFIRMED");

        // BƯỚC 5: Shipper đến quán lấy món thành công
        boolean pickedUp = orderDAO.shipperConfirmPickedUp(testOrderId, testDriverId);
        assertTrue("Shipper xác nhận đã lấy món từ quán", pickedUp);

        Order inShipping = orderDAO.getOrderById(testOrderId);
        assertEquals("Trạng thái đơn hàng chuyển sang SHIPPING", "SHIPPING", inShipping.getStatus());

        // BƯỚC 6: Shipper bấm xác nhận đã giao hàng thành công cho khách & thu tiền mặt
        boolean delivered = orderDAO.shipperConfirmDelivered(testOrderId, testDriverId);
        assertTrue("Shipper bấm xác nhận đã giao hàng", delivered);

        // BƯỚC 7: Kiểm tra trạng thái đơn hàng & tài xế
        Order finalOrder = orderDAO.getOrderById(testOrderId);
        assertEquals("Đơn hàng chính thức hoàn tất (DELIVERED)", "DELIVERED", finalOrder.getStatus());
        assertTrue("shipper_delivered = true", finalOrder.isShipperDelivered());
        assertTrue("merchant_completed = true", finalOrder.isMerchantCompleted());

        Driver availableDriver = driverDAO.getDriverById(testDriverId);
        assertEquals("Tài xế tự động giải phóng về AVAILABLE", "AVAILABLE", availableDriver.getStatus());

        // BƯỚC 8: KIỂM TRA QUYẾT TOÁN VÍ VÀ SỐ DƯ TÀI XẾ
        double finalBalance = driverDAO.getWalletBalance(testDriverId);
        double expectedBalance = initialBalance - totalCodAmount + shippingFee; // Ban đầu - tiền COD thu hộ + tiền thù lao ship
        assertEquals("Số dư ví phải khớp tuyệt đối: Ban đầu - Tiền COD thu khách + Thù lao giao hàng",
                expectedBalance, finalBalance, 0.01);

        // BƯỚC 9: KIỂM TRA DANH SÁCH GIAO DỊCH VÍ & CÁC PROPERTY CỦA MODEL
        List<DriverWalletTransaction> txList = driverDAO.getWalletTransactions(testDriverId, 10);
        assertNotNull("Danh sách giao dịch không được null", txList);
        assertTrue("Phải có ít nhất 2 giao dịch vừa tạo cho đơn này", txList.size() >= 2);

        DriverWalletTransaction latestTx1 = txList.get(0); // Giao dịch gần nhất (SHIPPING_EARNING)
        DriverWalletTransaction latestTx2 = txList.get(1); // Giao dịch trước đó (COD_DEDUCTION)

        // Kiểm tra giao dịch nhận thù lao
        assertEquals("SHIPPING_EARNING", latestTx1.getType());
        assertEquals("SHIPPING_EARNING", latestTx1.getTransactionType());
        assertEquals(shippingFee, latestTx1.getAmount(), 0.01);
        assertEquals("Thù lao giao hàng", latestTx1.getTypeDisplay());
        assertEquals("#15803d", latestTx1.getTypeBadgeColor());

        // Kiểm tra giao dịch trừ tiền COD thu khách
        assertEquals("COD_DEDUCTION", latestTx2.getType());
        assertEquals("COD_DEDUCTION", latestTx2.getTransactionType());
        assertEquals(-totalCodAmount, latestTx2.getAmount(), 0.01);
        assertEquals("Trừ tiền COD thu khách", latestTx2.getTypeDisplay());
        assertEquals("#dc2626", latestTx2.getTypeBadgeColor());

        System.out.println("==================================================================");
        System.out.println(">>> KIỂM THỬ LUỒNG HOẠT ĐỘNG COD & VÍ SHIPPER HOÀN TOÀN THÀNH CÔNG <<<");
        System.out.println("Tài xế ID: #" + testDriverId);
        System.out.println("Đơn hàng COD: #FZ-" + testOrderId);
        System.out.println("Số dư ví ban đầu: " + String.format("%,.0f", initialBalance) + " đ");
        System.out.println("1. Tiền mặt COD thu khách (Trừ ví shipper): -" + String.format("%,.0f", totalCodAmount) + " đ");
        System.out.println("2. Thù lao giao hàng (Cộng ví shipper): +" + String.format("%,.0f", shippingFee) + " đ");
        System.out.println("Số dư ví thực tế sau khi quyết toán: " + String.format("%,.0f", finalBalance) + " đ");
        System.out.println("Giao dịch 1: [" + latestTx2.getType() + "] " + latestTx2.getTypeDisplay() + " | " + latestTx2.getDescription());
        System.out.println("Giao dịch 2: [" + latestTx1.getType() + "] " + latestTx1.getTypeDisplay() + " | " + latestTx1.getDescription());
        System.out.println("==================================================================");
    }

    @After
    public void tearDown() {
        // Giữ lại đơn hàng test và các bản ghi giao dịch trong CSDL để người dùng có thể F5 xem trực tiếp trên giao diện ví
        System.out.println("Đã lưu trữ đơn hàng #" + testOrderId + " cùng giao dịch ví vào hệ thống để kiểm tra trực quan trên trình duyệt.");
    }
}
