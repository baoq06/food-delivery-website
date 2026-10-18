package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import org.junit.Test;

import static org.junit.Assert.*;

public class DatabaseSecurityConfigTest {

    @Test
    public void testResolvePropertyPlainString() {
        String val = "com.mysql.cj.jdbc.Driver";
        String resolved = DBContext.resolveProperty(val);
        assertEquals("Chuỗi thông thường không chứa biến môi trường phải giữ nguyên", val, resolved);
    }

    @Test
    public void testResolvePropertyWithDefaultValue() {
        String val = "${NON_EXISTENT_ENV_VAR_TEST_12345:default_secret_value}";
        String resolved = DBContext.resolveProperty(val);
        assertEquals("Biến môi trường không tồn tại phải fallback về giá trị mặc định", "default_secret_value", resolved);
    }

    @Test
    public void testResolvePropertyWithoutDefaultValueReturnsEmpty() {
        String val = "${NON_EXISTENT_ENV_VAR_NO_DEFAULT_99999}";
        String resolved = DBContext.resolveProperty(val);
        assertEquals("Biến môi trường không tồn tại và không có default phải trả về rỗng", "", resolved);
    }

    @Test
    public void testResolvePropertyHandlesNull() {
        assertNull("Tham số null phải trả về null an toàn", DBContext.resolveProperty(null));
    }
}
