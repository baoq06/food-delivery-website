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
                driver = resolveProperty(prop.getProperty("db.driver"));
                url = resolveProperty(prop.getProperty("db.url"));
                user = resolveProperty(prop.getProperty("db.username"));
                password = resolveProperty(prop.getProperty("db.password"));
                Class.forName(driver);
            } else {
                // Fallback nếu không tìm thấy file cấu hình
                driver = "com.mysql.cj.jdbc.Driver";
                url = "jdbc:mysql://localhost:3306/food_delivery_db";
                user = "root";
                password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "";
                Class.forName(driver);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String resolveProperty(String val) {
        if (val == null) {
            return null;
        }
        val = val.trim();
        if (val.startsWith("${") && val.endsWith("}")) {
            String content = val.substring(2, val.length() - 1).trim();
            String defaultValue = null;
            String varName = content;
            if (content.contains(":")) {
                int colonIdx = content.indexOf(':');
                varName = content.substring(0, colonIdx).trim();
                defaultValue = content.substring(colonIdx + 1);
            }
            String envVal = System.getenv(varName);
            if (envVal != null) {
                return envVal;
            }
            String sysProp = System.getProperty(varName);
            if (sysProp != null) {
                return sysProp;
            }
            return defaultValue != null ? defaultValue : "";
        }
        return val;
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
