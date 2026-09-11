<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="isAuth" value="${param.isAuthPage eq 'true' or pageContext.request.servletPath eq '/auth'}" />
<c:set var="isSeller" value="${not empty sessionScope.currentUser and sessionScope.currentUser.seller}" />

<c:if test="${not isAuth}">
    <!-- Top Info Bar -->
    <div class="topbar">
        <div class="topbar-container">
            <div class="topbar-left">
                <c:choose>
                    <c:when test="${isSeller}">
                        <span><i class="fa-solid fa-store text-primary"></i> <strong>Kênh Quán Ăn:</strong> Cổng quản trị &amp; vận hành quán ăn Utee Partner</span>
                    </c:when>
                    <c:otherwise>
                        <span><i class="fa-solid fa-bolt text-primary"></i> <strong>Hotline:</strong> 1900 6868 | <strong>Giao siêu tốc:</strong> 07:00 - 23:00</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="topbar-right">
                <c:choose>
                    <c:when test="${isSeller}">
                        <span><i class="fa-solid fa-headset text-primary"></i> Hotline hỗ trợ đối tác: <strong>1900 6868</strong> (24/7)</span>
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
                <c:when test="${isSeller}">
                    <span class="brand-badge" style="background:#e6f9ed;color:#1e7e34;border-color:#a3e9b9;"><i class="fa-solid fa-store"></i> Đối Tác Quán</span>
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
                <!-- Search Bar (Ẩn đối với merchant để tránh thừa thãi tìm kiếm thực đơn khách) -->
                <c:if test="${not isSeller}">
                    <div class="nav-search">
                        <form action="${pageContext.request.contextPath}/foods" method="GET" class="search-form">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" name="search" placeholder="Tìm món ăn, trà sữa, pizza..." class="search-input" value="${param.search}">
                            <button type="submit" class="search-btn">Tìm</button>
                        </form>
                    </div>
                </c:if>

                <!-- Navigation Links -->
                <ul class="nav-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/home" class="${pageContext.request.servletPath eq '' or pageContext.request.servletPath eq '/home' ? 'active' : ''}">
                            Trang chủ
                        </a>
                    </li>
                    <c:choose>
                        <c:when test="${isSeller}">
                            <li>
                                <a href="${pageContext.request.contextPath}/merchant/dashboard" class="${pageContext.request.servletPath eq '/merchant/dashboard' ? 'active' : ''}">
                                    Kênh Quán Ăn
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/merchant/foods" class="${pageContext.request.servletPath eq '/merchant/foods' ? 'active' : ''}">
                                    Thực đơn món
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/merchant/orders" class="${pageContext.request.servletPath eq '/merchant/orders' ? 'active' : ''}">
                                    Đơn hàng
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/merchant/revenue" class="${pageContext.request.servletPath eq '/merchant/revenue' ? 'active' : ''}">
                                    Doanh thu
                                </a>
                            </li>
                        </c:when>
                        <c:otherwise>
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
                        </c:otherwise>
                    </c:choose>
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
                                    <a href="${pageContext.request.contextPath}/profile" class="user-dropdown-header-link">
                                        <div class="user-dropdown-name">${sessionScope.currentUser.fullName}</div>
                                        <div class="user-dropdown-role">
                                            <c:choose>
                                                <c:when test="${sessionScope.currentUser.role eq 'ADMIN'}"><span class="role-badge role-admin"><i class="fa-solid fa-shield-halved"></i> Quản trị viên</span></c:when>
                                                <c:when test="${sessionScope.currentUser.seller}"><span class="role-badge role-seller"><i class="fa-solid fa-store"></i> Đối tác Quán ăn</span></c:when>
                                                <c:when test="${sessionScope.currentUser.role eq 'SHIPPER' or sessionScope.currentUser.shipper}"><span class="role-badge role-shipper"><i class="fa-solid fa-motorcycle"></i> Tài xế Shipper</span></c:when>
                                                <c:otherwise><span class="role-badge role-customer"><i class="fa-solid fa-crown"></i> Khách hàng thân thiết</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </a>
                                    <div class="dropdown-divider"></div>
                                    <a href="${pageContext.request.contextPath}/profile" class="${pageContext.request.servletPath eq '/profile' and (empty param.tab or param.tab eq 'profile') ? 'active-link' : ''}">
                                        <i class="fa-solid fa-id-card text-primary"></i> Tài khoản của tôi
                                    </a>
                                    <c:if test="${not isSeller}">
                                        <a href="${pageContext.request.contextPath}/profile?tab=orders" class="${pageContext.request.servletPath eq '/profile' and param.tab eq 'orders' ? 'active-link' : ''}">
                                            <i class="fa-solid fa-clock-rotate-left text-info"></i> Lịch sử đơn hàng
                                        </a>
                                    </c:if>
                                    <c:if test="${sessionScope.currentUser.role eq 'ADMIN'}">
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line text-warning"></i> Quản trị hệ thống</a>
                                    </c:if>
                                    <c:if test="${sessionScope.currentUser.seller}">
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/merchant/dashboard" class="text-primary font-weight-bold"><i class="fa-solid fa-store"></i> Kênh Quản Lý Quán Ăn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/foods"><i class="fa-solid fa-bowl-food"></i> Thực đơn món ăn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/revenue"><i class="fa-solid fa-chart-line"></i> Báo cáo doanh thu</a>
                                        <a href="${pageContext.request.contextPath}/merchant/shippers"><i class="fa-solid fa-motorcycle"></i> Danh sách shipper</a>
                                        <a href="${pageContext.request.contextPath}/merchant/orders"><i class="fa-solid fa-receipt"></i> Đơn hàng của quán</a>
                                        <a href="${pageContext.request.contextPath}/merchant/profile"><i class="fa-solid fa-gear"></i> Cài đặt quán ăn</a>
                                    </c:if>
                                    <c:if test="${not isSeller}">
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/cart"><i class="fa-solid fa-bag-shopping"></i> Giỏ hàng hiện tại</a>
                                    </c:if>
                                    <div class="dropdown-divider"></div>
                                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất</a>
                                </div>
                            </div>
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
