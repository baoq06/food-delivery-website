package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.UserDAO;
import com.ute.fooddelivery.model.User;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

public class CustomerBoomAndCodLockTest {

    private UserDAO userDAO;
    private static final int TEST_CUSTOMER_ID = 2; // customer (Nguyễn Văn Khách)

    @Before
    public void setUp() {
        userDAO = new UserDAO();
        UserDAO.ensureBoomSupport();
        // Reset ban đầu về 0
        userDAO.unlockCustomerCod(TEST_CUSTOMER_ID);
    }

    @After
    public void tearDown() {
        // Khôi phục trạng thái cho test customer
        userDAO.unlockCustomerCod(TEST_CUSTOMER_ID);
    }

    @Test
    public void testRecordBoomAndCodLockFlow() {
        // 1. Ban đầu: không bị khóa COD
        assertFalse("Ban đầu khách không bị khóa COD", userDAO.isCustomerCodLocked(TEST_CUSTOMER_ID));

        int initialBoom = userDAO.getCustomerBoomCount(TEST_CUSTOMER_ID);

        // 2. Ghi nhận bom hàng lần 1
        boolean recorded = userDAO.recordCustomerBoom(TEST_CUSTOMER_ID, "Test bom hàng - gọi 3 cuộc không nghe máy");
        assertTrue("Ghi nhận bom hàng phải thành công", recorded);

        // 3. Kiểm tra cờ is_cod_locked và boom_count
        assertTrue("Sau khi bom hàng, cờ is_cod_locked phải là TRUE", userDAO.isCustomerCodLocked(TEST_CUSTOMER_ID));
        assertEquals("Số lần bom hàng phải tăng lên 1", initialBoom + 1, userDAO.getCustomerBoomCount(TEST_CUSTOMER_ID));

        // 4. Kiểm tra User entity lấy qua getUserById
        User user = userDAO.getUserById(TEST_CUSTOMER_ID);
        assertNotNull(user);
        assertTrue("User entity phải có isCodLocked = true", user.isCodLocked());

        // 5. Mở khóa COD (khi admin duyệt hoặc hoàn thành điều kiện phục hồi)
        boolean unlocked = userDAO.unlockCustomerCod(TEST_CUSTOMER_ID);
        assertTrue("Mở khóa COD phải thành công", unlocked);
        assertFalse("Sau khi mở khóa, cờ is_cod_locked phải là FALSE", userDAO.isCustomerCodLocked(TEST_CUSTOMER_ID));
    }
}
