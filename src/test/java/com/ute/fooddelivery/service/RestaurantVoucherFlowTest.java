package com.ute.fooddelivery.service;

import com.ute.fooddelivery.dao.VoucherDAO;
import com.ute.fooddelivery.model.Voucher;
import com.ute.fooddelivery.service.VoucherService.ValidationResult;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.junit.Assert.*;

public class RestaurantVoucherFlowTest {

    private VoucherDAO voucherDAO;
    private VoucherService voucherService;

    private static final String TEST_CODE_FIXED = "TEST_REST1_20K";
    private static final String TEST_CODE_PERCENT = "TEST_REST1_15PCT";
    private static final int TEST_REST_ID = 1;

    @Before
    public void setUp() {
        voucherDAO = new VoucherDAO();
        voucherService = new VoucherService();
        cleanTestData();
    }

    @After
    public void tearDown() {
        cleanTestData();
    }

    private void cleanTestData() {
        Voucher v1 = voucherDAO.getVoucherByCode(TEST_CODE_FIXED);
        if (v1 != null) {
            voucherDAO.deleteVoucher(v1.getId(), TEST_REST_ID);
        }
        Voucher v2 = voucherDAO.getVoucherByCode(TEST_CODE_PERCENT);
        if (v2 != null) {
            voucherDAO.deleteVoucher(v2.getId(), TEST_REST_ID);
        }
    }

    @Test
    public void testCreateAndRetrieveRestaurantVoucher() {
        Voucher v = new Voucher();
        v.setRestaurantId(TEST_REST_ID);
        v.setCode(TEST_CODE_FIXED);
        v.setTitle("Giảm 20K đơn từ 70K tại Bếp Việt");
        v.setDescription("Test khuyến mãi của quán");
        v.setDiscountType(Voucher.DiscountType.FIXED);
        v.setDiscountValue(20000.0);
        v.setMinOrderAmount(70000.0);
        v.setMaxDiscount(0.0);
        v.setUsageLimit(50);
        v.setUsedCount(0);
        v.setPerUserLimit(1);
        v.setStartDate("2026-01-01");
        v.setEndDate("2026-12-31");
        v.setActive(true);
        v.setBadge("🔥 HOT DEAL");

        boolean created = voucherDAO.insertVoucher(v);
        assertTrue("Tạo voucher quán ăn phải thành công", created);

        Voucher retrieved = voucherDAO.getVoucherByCode(TEST_CODE_FIXED);
        assertNotNull("Phải tìm thấy voucher theo mã", retrieved);
        assertEquals(TEST_CODE_FIXED, retrieved.getCode());
        assertEquals(20000.0, retrieved.getDiscountValue(), 0.01);
        assertEquals(70000.0, retrieved.getMinOrderAmount(), 0.01);
        assertEquals(50, retrieved.getUsageLimit());
        assertTrue(retrieved.isAvailable());

        // Lấy danh sách active vouchers của quán
        List<Voucher> activeList = voucherDAO.getActiveVouchersByRestaurant(TEST_REST_ID);
        assertTrue("Danh sách voucher hoạt động của quán phải chứa mã vừa tạo",
                activeList.stream().anyMatch(item -> TEST_CODE_FIXED.equals(item.getCode())));
    }

    @Test
    public void testValidateRestaurantMatchingAndMinOrder() {
        Voucher v = new Voucher();
        v.setRestaurantId(TEST_REST_ID);
        v.setCode(TEST_CODE_PERCENT);
        v.setTitle("Giảm 15% tối đa 30K");
        v.setDiscountType(Voucher.DiscountType.PERCENT);
        v.setDiscountValue(15.0);
        v.setMinOrderAmount(100000.0);
        v.setMaxDiscount(30000.0);
        v.setUsageLimit(100);
        v.setUsedCount(0);
        v.setActive(true);
        voucherDAO.insertVoucher(v);

        // 1. Áp dụng đúng quán (cartRestaurantId = 1) và đủ đơn (150.000 đ) -> Giảm 15% = 22.500 đ
        ValidationResult resSuccess = voucherService.validateAndCalculate(TEST_CODE_PERCENT, 150000, 15000, TEST_REST_ID, 0);
        assertTrue("Phải áp dụng thành công khi đúng quán và đủ điều kiện", resSuccess.isValid());
        assertEquals(22500.0, resSuccess.getDiscountAmount(), 0.01);

        // 2. Áp dụng khác quán (cartRestaurantId = 2) -> Phải bị từ chối
        ValidationResult resWrongRest = voucherService.validateAndCalculate(TEST_CODE_PERCENT, 150000, 15000, 2, 0);
        assertFalse("Phải từ chối khi mã áp dụng cho quán khác", resWrongRest.isValid());

        // 3. Áp dụng đúng quán nhưng chưa đủ đơn tối thiểu (50.000 < 100.000) -> Phải báo thiếu tiền
        ValidationResult resUnderMin = voucherService.validateAndCalculate(TEST_CODE_PERCENT, 50000, 15000, TEST_REST_ID, 0);
        assertFalse("Phải từ chối khi chưa đạt giá trị đơn tối thiểu", resUnderMin.isValid());
        assertTrue(resUnderMin.getMessage().contains("yêu cầu đơn từ"));
    }

    @Test
    public void testUsageLimitAndIncrement() {
        Voucher v = new Voucher();
        v.setRestaurantId(TEST_REST_ID);
        v.setCode(TEST_CODE_FIXED);
        v.setTitle("Giới hạn 2 lượt");
        v.setDiscountType(Voucher.DiscountType.FIXED);
        v.setDiscountValue(20000.0);
        v.setMinOrderAmount(0.0);
        v.setUsageLimit(2);
        v.setUsedCount(1);
        v.setActive(true);
        voucherDAO.insertVoucher(v);

        // Lượt thứ 2: vẫn hợp lệ
        Voucher vBefore = voucherDAO.getVoucherByCode(TEST_CODE_FIXED);
        assertFalse("Voucher chưa đạt giới hạn khi usedCount=1, limit=2", vBefore.isFullyUsed());

        // Tăng used_count lên 2
        voucherDAO.incrementUsedCount(TEST_CODE_FIXED);

        Voucher vAfter = voucherDAO.getVoucherByCode(TEST_CODE_FIXED);
        assertEquals(2, vAfter.getUsedCount());
        assertTrue("Voucher phải hết lượt khi usedCount=2, limit=2", vAfter.isFullyUsed());

        // Thẩm định khi hết lượt -> phải bị từ chối
        ValidationResult res = voucherService.validateAndCalculate(TEST_CODE_FIXED, 100000, 15000, TEST_REST_ID, 0);
        assertFalse("Voucher hết lượt dùng phải bị từ chối", res.isValid());
        assertTrue(res.getMessage().contains("giới hạn số lần sử dụng"));
    }
}
