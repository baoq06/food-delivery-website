<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Top Info Bar -->
<div class="topbar">
    <div class="topbar-container">
        <div class="topbar-left">
            <span><i class="fa-solid fa-fire text-primary"></i> <strong>Hotline:</strong> 1900 6886 | <strong>Giao hàng:</strong> 07:00 - 23:00</span>
        </div>
        <div class="topbar-right">
            <span><i class="fa-solid fa-ticket text-primary"></i> Mã <strong>DELI15</strong> giảm 15k cho đơn từ 99k</span>
        </div>
    </div>
</div>

<!-- Main Navigation -->
<nav class="navbar">
    <div class="nav-container">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/home" class="brand-logo">
            <span class="logo-icon"><i class="fa-solid fa-utensils"></i></span>
            <span class="logo-text">Food<span>Zone</span></span>
        </a>

        <!-- Search Bar -->
        <div class="nav-search">
            <form action="${pageContext.request.contextPath}/foods" method="GET" class="search-form">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" name="search" placeholder="Tìm món ăn, trà sữa, pizza..." class="search-input" value="${param.search}">
                <button type="submit" class="search-btn">Tìm</button>
            </form>
        </div>

        <!-- Navigation Links -->
        <ul class="nav-links">
            <li>
                <a href="${pageContext.request.contextPath}/home" class="${pageContext.request.servletPath eq '' or pageContext.request.servletPath eq '/home' ? 'active' : ''}">
                    Trang chủ
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/foods" class="${pageContext.request.servletPath eq '/foods' ? 'active' : ''}">
                    Thực đơn
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/cart" class="cart-nav-link ${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                    <i class="fa-solid fa-bag-shopping"></i>
                    <span>Giỏ hàng</span>
                    <c:set var="cartCount" value="${sessionScope.cart != null ? sessionScope.cart.size() : 0}" />
                    <span class="cart-badge">${cartCount}</span>
                </a>
            </li>
        </ul>

        <!-- User Actions -->
        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <div class="user-menu">
                        <div class="user-avatar-pill">
                            <i class="fa-solid fa-circle-user"></i>
                            <span>${sessionScope.currentUser.fullName}</span>
                        </div>
                        <div class="user-dropdown">
                            <c:if test="${sessionScope.currentUser.role eq 'ADMIN'}">
                                <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line"></i> Quản trị hệ thống</a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/cart"><i class="fa-solid fa-receipt"></i> Đơn hàng của tôi</a>
                            <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất</a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/auth?action=login#register" class="btn btn-primary btn-sm">Đăng ký</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>
