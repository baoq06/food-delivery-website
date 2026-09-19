package com.ute.fooddelivery;

import com.ute.fooddelivery.utils.GeoLocationUtils;
import org.junit.Test;

import static org.junit.Assert.*;

public class GeoLocationUtilsTest {

    @Test
    public void testCalculateShippingFee() {
        // Dưới 2km: Phí chuẩn 15.000đ
        assertEquals(15000.0, GeoLocationUtils.calculateShippingFee(0.5), 0.01);
        assertEquals(15000.0, GeoLocationUtils.calculateShippingFee(1.99), 0.01);
        assertEquals(15000.0, GeoLocationUtils.calculateShippingFee(2.0), 0.01);

        // Trên 2km: +5.000đ/km
        // 3km -> 15.000 + 1 * 5.000 = 20.000đ
        assertEquals(20000.0, GeoLocationUtils.calculateShippingFee(3.0), 0.01);

        // 3.5km -> extraKm = ceil(1.5) = 2 -> 15.000 + 2 * 5.000 = 25.000đ
        assertEquals(25000.0, GeoLocationUtils.calculateShippingFee(3.5), 0.01);

        // 5km -> extraKm = ceil(3.0) = 3 -> 15.000 + 3 * 5.000 = 30.000đ
        assertEquals(30000.0, GeoLocationUtils.calculateShippingFee(5.0), 0.01);
    }

    @Test
    public void testHaversineDistance() {
        // Tọa độ HCMUTE (10.850721, 106.771960) đến Chợ Thủ Đức (10.854882, 106.758476)
        double distKm = GeoLocationUtils.calculateHaversineDistance(10.850721, 106.771960, 10.854882, 106.758476);
        assertTrue("Cự ly HCMUTE đến Chợ Thủ Đức trong khoảng 1.0 - 2.5 km", distKm > 1.0 && distKm < 2.5);
    }

    @Test
    public void testEstimateDeliveryMinutes() {
        int minsShort = GeoLocationUtils.estimateDeliveryMinutes(1.5);
        assertEquals("15 phút chuẩn bị + 5 phút di chuyển = 20 phút", 20, minsShort);

        int minsLong = GeoLocationUtils.estimateDeliveryMinutes(5.0);
        assertTrue("5km ước tính > 20 phút", minsLong >= 20);
    }

    @Test
    public void testCoordinateDictionary() {
        double[] utCoords = GeoLocationUtils.getCoordinatesForAddress("Đại học Sư phạm Kỹ thuật TP.HCM");
        assertNotNull(utCoords);
        assertEquals(10.850721, utCoords[0], 0.001);
        assertEquals(106.771960, utCoords[1], 0.001);
    }
}
