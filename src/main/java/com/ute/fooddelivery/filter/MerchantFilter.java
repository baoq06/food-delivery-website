package com.ute.fooddelivery.filter;

import com.ute.fooddelivery.model.Restaurant;
import com.ute.fooddelivery.model.User;
import com.ute.fooddelivery.service.MerchantService;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "MerchantFilter", urlPatterns = {"/merchant/*"})
public class MerchantFilter implements Filter {
    private final MerchantService merchantService = new MerchantService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!currentUser.isSeller() && !currentUser.isAdmin())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login&error=unauthorized_merchant");
            return;
        }

        // Tự động gắn thông tin quán ăn của chủ quán vào request
        Restaurant restaurant = merchantService.getRestaurantForUser(currentUser.getId());
        req.setAttribute("currentRestaurant", restaurant);

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
