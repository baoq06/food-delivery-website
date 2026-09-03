package com.ute.fooddelivery.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // Không ép Content-Type text/html cho file tĩnh (css, js, ảnh)
        // để trình duyệt không chặn stylesheet theo chính sách bảo mật MIME
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
