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

        // Đảm bảo session hiện có luôn có CSRF token để các view JSP có thể dùng
        if (request instanceof jakarta.servlet.http.HttpServletRequest) {
            jakarta.servlet.http.HttpServletRequest req = (jakarta.servlet.http.HttpServletRequest) request;
            jakarta.servlet.http.HttpSession session = req.getSession(false);
            if (session != null) {
                com.ute.fooddelivery.utils.CsrfUtils.getOrCreateToken(session);
            }
        }
        
        // Không ép Content-Type text/html cho file tĩnh (css, js, ảnh)
        // để trình duyệt không chặn stylesheet theo chính sách bảo mật MIME
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
