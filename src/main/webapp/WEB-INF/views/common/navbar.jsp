<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="isAuth" value="${param.isAuthPage eq 'true' or pageContext.request.servletPath eq '/auth'}" />
<c:set var="isShipper" value="${not empty sessionScope.currentUser and sessionScope.currentUser.shipper}" />

<c:if test="${not isAuth}">
    <!-- Top Info Bar -->
    <div class="topbar">
        <div class="topbar-container">
            <div class="topbar-left">
                <c:choose>
                    <c:when test="${isShipper}">
                        <span><i class="fa-solid fa-motorcycle text-primary"></i> <strong>Kênh Tài Xế:</strong> Giao hàng siêu tốc cùng Utee</span>
                    </c:when>
                    <c:otherwise>
                        <span><i class="fa-solid fa-bolt text-primary"></i> <strong>Hotline:</strong> 1900 6868 | <strong>Giao siêu tốc:</strong> 07:00 - 23:00</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="topbar-right">
                <c:choose>
                    <c:when test="${isShipper}">
                        <span><i class="fa-solid fa-headset text-primary"></i> Hotline hỗ trợ tài xế: <strong>1900 6869</strong> (24/7)</span>
                    </c:when>
                    <c:otherwise>
                        <span><i class="fa-solid fa-ticket text-primary"></i> Mã <strong>UTEE15</strong> giảm 15k cho đơn từ 99k</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<!-- Main Navigation -->
<nav class="navbar ${isAuth ? 'navbar-auth' : ''}">
    <div class="nav-container ${isAuth ? 'nav-container-auth' : ''}">
        <!-- Logo -->
        <a href="${pageContext.request.contextPath}/home" class="brand-logo" title="Utee - Đặt món ngon giao tận nơi">
            <img src="${pageContext.request.contextPath}/assets/images/logo/logo-dark-transparent.png" alt="Utee" class="brand-logo-img">
            <c:choose>
                <c:when test="${isAuth}">
                    <span class="brand-badge"><i class="fa-solid fa-shield-halved"></i> Đăng Nhập & Đăng Ký</span>
                </c:when>
                <c:otherwise>
                    <span class="brand-badge"><i class="fa-solid fa-bolt"></i> 30m Express</span>
                </c:otherwise>
            </c:choose>
        </a>

        <c:choose>
            <c:when test="${isAuth}">
                <!-- Simplified Auth Top Navigation: Chỉ giữ nút điều hướng về trang chủ -->
                <div class="nav-auth-actions">
                    <a href="${pageContext.request.contextPath}/home" class="btn-auth-back">
                        <i class="fa-solid fa-arrow-left"></i>
                        <span>Về trang chủ</span>
                    </a>
                </div>
            </c:when>
            <c:otherwise>
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
                    <c:if test="${isShipper}">
                        <li>
                            <a href="${pageContext.request.contextPath}/shipper/dashboard" class="${pageContext.request.servletPath eq '/shipper/dashboard' ? 'active' : ''}">
                                Kênh Tài Xế
                            </a>
                        </li>
                    </c:if>
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
                                    <i class="fa-solid fa-chevron-down user-caret"></i>
                                </div>
                                <div class="user-dropdown">
                                    <c:choose>
                                        <c:when test="${sessionScope.currentUser.role eq 'ADMIN'}">
                                            <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line"></i> Quản trị hệ thống</a>
                                        </c:when>
                                        <c:when test="${isShipper}">
                                            <a href="${pageContext.request.contextPath}/shipper/dashboard" class="text-primary font-weight-bold"><i class="fa-solid fa-motorcycle"></i> Bảng điều khiển tài xế</a>
                                            <a href="${pageContext.request.contextPath}/shipper/history"><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử giao hàng</a>
                                        </c:when>
                                    </c:choose>
                                    <c:if test="${sessionScope.currentUser.seller}">
                                        <a href="${pageContext.request.contextPath}/merchant/dashboard" class="text-primary font-weight-bold"><i class="fa-solid fa-store"></i> Kênh Quản Lý Quán Ăn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/foods"><i class="fa-solid fa-bowl-food"></i> Thực đơn món ăn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/revenue"><i class="fa-solid fa-chart-line"></i> Báo cáo doanh thu</a>
                                        <a href="${pageContext.request.contextPath}/merchant/shippers"><i class="fa-solid fa-motorcycle"></i> Danh sách shipper</a>
                                        <a href="${pageContext.request.contextPath}/merchant/orders"><i class="fa-solid fa-receipt"></i> Đơn hàng của quán</a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/client/orders"><i class="fa-solid fa-receipt"></i> Đơn hàng của tôi</a>
                                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất</a>
                                </div>
                            </div>
                            <c:if test="${sessionScope.currentUser.seller}">
                                <a href="${pageContext.request.contextPath}/merchant/dashboard" class="btn btn-primary btn-sm btn-nav-auth" title="Vào Kênh Quản Lý Quán Ăn">
                                    <i class="fa-solid fa-store"></i> Kênh Quán Ăn
                                </a>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm btn-nav-auth">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/auth?action=login#register" class="btn btn-primary btn-sm btn-nav-auth">Đăng ký</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</nav>
