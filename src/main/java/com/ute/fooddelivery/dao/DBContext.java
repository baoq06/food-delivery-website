package com.ute.fooddelivery.dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBContext {
    private static String url;
    private static String user;
    private static String password;
    private static String driver;

    static {
        try (InputStream input = DBContext.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                driver = prop.getProperty("db.driver");
                url = prop.getProperty("db.url");
                user = prop.getProperty("db.username");
                password = prop.getProperty("db.password");
                Class.forName(driver);
            } else {
                // Fallback nếu không tìm thấy file cấu hình
                driver = "com.mysql.cj.jdbc.Driver";
                url = "jdbc:mysql://localhost:3306/food_delivery_db";
                user = "root";
                password = "";
                Class.forName(driver);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(url, user, password);
        } catch (Exception e) {
            System.err.println("Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            return null;
        }
    }
}
