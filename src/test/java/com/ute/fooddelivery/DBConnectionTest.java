package com.ute.fooddelivery;

import com.ute.fooddelivery.dao.DBContext;
import com.ute.fooddelivery.dao.OrderDAO;
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
                 ResultSet rs = stmt.executeQuery("SELECT order_id, user_id, status, driver_id, customer_confirmed, merchant_confirmed FROM orders ORDER BY order_id DESC LIMIT 5")) {
                while (rs.next()) {
                    System.out.println("ORDER #" + rs.getInt("order_id") + 
                                       " | User: " + rs.getInt("user_id") + 
                                       " | Status: " + rs.getString("status") + 
                                       " | Driver: " + rs.getInt("driver_id") + 
                                       " | CustConfirmed: " + rs.getBoolean("customer_confirmed") + 
                                       " | MerchConfirmed: " + rs.getBoolean("merchant_confirmed"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            fail("Database connection failed: " + e.getMessage());
        }
    }
}
