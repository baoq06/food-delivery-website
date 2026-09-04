package com.ute.fooddelivery.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet dùng để kích hoạt thử nghiệm lỗi 500 (Internal Server Error)
 * giúp kiểm tra cơ chế bắt lỗi và giao diện 500.jsp trong web.xml
 */
@WebServlet(name = "TestErrorServlet", urlPatterns = {"/test-500"})
public class TestErrorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Cố tình ném ra ngoại lệ máy chủ để kích hoạt trang lỗi 500
        throw new RuntimeException("Thử nghiệm lỗi hệ thống 500: Ngoại lệ máy chủ chưa được xử lý!");
    }
}
