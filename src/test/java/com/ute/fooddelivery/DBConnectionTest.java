package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import org.junit.Test;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import static org.junit.Assert.*;

public class DBConnectionTest {

    @Test
    public void testDatabaseConnection() {
        try (Connection conn = DBContext.getConnection()) {
            assertNotNull("Connection should not be null", conn);
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT count(*) FROM foods")) {
                assertTrue(rs.next());
                int count = rs.getInt(1);
                assertTrue(count >= 0);
            }
        } catch (Exception e) {
            e.printStackTrace();
            fail("Database connection failed: " + e.getMessage());
        }
    }
}
