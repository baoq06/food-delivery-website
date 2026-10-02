<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="isAuth" value="${param.isAuthPage eq 'true' or pageContext.request.servletPath eq '/auth'}" />
<c:set var="isSeller" value="${not empty sessionScope.currentUser and sessionScope.currentUser.seller}" />
<c:set var="isShipper" value="${not empty sessionScope.currentUser and sessionScope.currentUser.shipper}" />
<c:set var="isShipperActive" value="${isShipper and (sessionScope.shipperActive eq true or (not empty sessionScope.driverStatus and sessionScope.driverStatus ne 'OFFLINE'))}" />

<style>
    /* Shipper Topbar Quick Toggle */
    .topbar-toggle-shipper-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 3px 10px;
        border-radius: 9999px;
        font-size: 0.8rem;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.2s ease;
        border: 1px solid transparent;
    }
    .topbar-toggle-shipper-btn.online {
        background: #e6f9ed;
        color: #10ac84;
        border-color: #a3e9b9;
    }
    .topbar-toggle-shipper-btn.online:hover {
        background: #d1f4dc;
        transform: translateY(-1px);
    }
    .topbar-toggle-shipper-btn.offline {
        background: #f1f5f9;
        color: #64748b;
        border-color: #cbd5e1;
    }
    .topbar-toggle-shipper-btn.offline:hover {
        background: #e2e8f0;
        color: #334155;
        transform: translateY(-1px);
    }
    .shipper-pulse-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        display: inline-block;
    }
    .topbar-toggle-shipper-btn.online .shipper-pulse-dot {
        background: #10ac84;
        box-shadow: 0 0 0 0 rgba(16, 172, 132, 0.7);
        animation: pulseGreen 1.8s infinite;
    }
    .topbar-toggle-shipper-btn.offline .shipper-pulse-dot {
        background: #94a3b8;
    }
    /* Notification Bell UI/UX Pro Max & Popover Preview */
    .nav-notif-dropdown-wrapper {
        position: relative;
        display: inline-flex;
        align-items: center;
        margin-right: 6px;
        padding: 4px 0;
    }
    .nav-notif-btn {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 38px;
        height: 38px;
        border-radius: 50%;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        color: #475569;
        font-size: 1.1rem;
        text-decoration: none;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .nav-notif-btn:hover {
        background: #fff5f5;
        border-color: #fca5a5;
        color: #f05454;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(240, 84, 84, 0.2);
    }
    .nav-notif-badge {
        position: absolute;
        top: -3px;
        right: -3px;
        background: #f05454;
        color: #ffffff;
        font-size: 0.68rem;
        font-weight: 800;
        min-width: 18px;
        height: 18px;
        border-radius: 9999px;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0 4px;
        border: 2px solid #ffffff;
        box-shadow: 0 2px 6px rgba(240, 84, 84, 0.4);
    }
    .nav-notif-badge.has-unread {
        animation: bellShake 2.8s infinite;
    }
    @keyframes bellShake {
        0%, 100% { transform: rotate(0); }
        10%, 30% { transform: rotate(-12deg) scale(1.08); }
        20%, 40% { transform: rotate(12deg) scale(1.08); }
        50% { transform: rotate(0); }
    }

    /* Notification Popover Dropdown */
    .nav-notif-popover {
        position: absolute;
        top: calc(100% + 4px);
        right: -8px;
        width: 360px;
        max-width: calc(100vw - 24px);
        background: #ffffff;
        border: 1px solid #fee2e2;
        border-radius: 18px;
        box-shadow: 0 16px 40px rgba(15, 23, 42, 0.12), 0 4px 12px rgba(240, 84, 84, 0.06);
        z-index: 10000;
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
        transform: translateY(8px) scale(0.98);
        transition: opacity 0.22s cubic-bezier(0.16, 1, 0.3, 1),
                    transform 0.22s cubic-bezier(0.16, 1, 0.3, 1),
                    visibility 0.22s cubic-bezier(0.16, 1, 0.3, 1);
        display: flex;
        flex-direction: column;
    }
    /* Invisible Hover Bridge: Phủ kín khoảng cách giữa nút chuông và menu chống mất hover */
    .nav-notif-popover::before {
        content: '';
        position: absolute;
        top: -18px;
        left: -12px;
        right: -12px;
        height: 22px;
        background: transparent;
    }
    .nav-notif-dropdown-wrapper:hover .nav-notif-popover,
    .nav-notif-dropdown-wrapper.is-open .nav-notif-popover {
        opacity: 1;
        visibility: visible;
        pointer-events: auto;
        transform: translateY(0) scale(1);
    }
    .nav-notif-popover-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 13px 16px;
        background: #fffafa;
        border-bottom: 1px solid #f1f5f9;
        border-radius: 18px 18px 0 0;
    }
    .notif-popover-title {
        font-size: 0.92rem;
        font-weight: 800;
        color: #1e293b;
        display: flex;
        align-items: center;
        gap: 7px;
    }
    .notif-popover-badge {
        font-size: 0.72rem;
        background: #fee2e2;
        color: #dc2626;
        padding: 2px 8px;
        border-radius: 50px;
        font-weight: 700;
    }
    .btn-popover-mark-all {
        font-size: 0.76rem;
        font-weight: 600;
        color: #64748b;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 50px;
        padding: 3px 9px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s ease;
    }
    .btn-popover-mark-all:hover {
        background: #e6f9ed;
        color: #10ac84;
        border-color: #a3e9b9;
    }
    .nav-notif-popover-body {
        max-height: 330px;
        overflow-y: auto;
        overscroll-behavior: contain;
    }
    .nav-notif-popover-body::-webkit-scrollbar {
        width: 4px;
    }
    .nav-notif-popover-body::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 4px;
    }
    .popover-notif-item {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 12px 16px;
        border-bottom: 1px solid #f8fafc;
        text-decoration: none;
        color: inherit;
        transition: background 0.18s ease;
        cursor: pointer;
        position: relative;
    }
    .popover-notif-item:last-child {
        border-bottom: none;
    }
    .popover-notif-item:hover {
        background: #fff5f5;
    }
    .popover-notif-item.unread {
        background: #fffafa;
        border-left: 3px solid #f05454;
    }
    .popover-item-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f8fafc;
        border: 1px solid #f1f5f9;
        font-size: 1rem;
        flex-shrink: 0;
    }
    .popover-notif-item.unread .popover-item-icon {
        background: #ffffff;
        box-shadow: 0 2px 8px rgba(240, 84, 84, 0.12);
    }
    .popover-item-content {
        flex: 1;
        min-width: 0;
    }
    .popover-item-title {
        font-size: 0.85rem;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 2px;
        line-height: 1.35;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 6px;
    }
    .popover-item-desc {
        font-size: 0.78rem;
        color: #64748b;
        line-height: 1.4;
        margin: 0 0 4px 0;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }
    .popover-item-time {
        font-size: 0.72rem;
        color: #94a3b8;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .popover-unread-dot {
        width: 6px;
        height: 6px;
        border-radius: 50%;
        background: #f05454;
        display: inline-block;
        flex-shrink: 0;
    }
    .notif-popover-loading,
    .notif-popover-empty {
        padding: 30px 16px;
        text-align: center;
        color: #94a3b8;
        font-size: 0.85rem;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
    }
    .notif-popover-empty i {
        font-size: 2.2rem;
        color: #cbd5e1;
    }
    .nav-notif-popover-footer {
        padding: 10px 16px;
        text-align: center;
        background: #f8fafc;
        border-top: 1px solid #f1f5f9;
    }
    .btn-popover-view-all {
        font-size: 0.82rem;
        font-weight: 700;
        color: #f05454;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: gap 0.2s ease, color 0.2s ease;
    }
    .btn-popover-view-all:hover {
        color: #de3b3b;
        gap: 9px;
    }
</style>

<c:if test="${not isAuth}">
    <!-- Top Info Bar -->
    <div class="topbar">
        <div class="topbar-container">
            <div class="topbar-left">
                <c:choose>
                    <c:when test="${isSeller}">
                        <span><i class="fa-solid fa-store text-primary"></i> <strong>Kênh Quán Ăn:</strong> Cổng quản trị &amp; vận hành quán ăn Utee Partner</span>
                    </c:when>
                    <c:when test="${isShipper}">
                        <c:choose>
                            <c:when test="${isShipperActive}">
                                <span><i class="fa-solid fa-motorcycle text-success"></i> <strong>Kênh Tài Xế:</strong> <span class="badge" style="background:#e6f9ed;color:#10ac84;border:1px solid #a3e9b9;border-radius:12px;padding:2px 8px;font-size:0.75rem;">🟢 ĐANG BẬT NHẬN ĐƠN</span></span>
                            </c:when>
                            <c:otherwise>
                                <span><i class="fa-solid fa-power-off text-secondary"></i> <strong>Kênh Tài Xế:</strong> <span class="badge" style="background:#f1f5f9;color:#64748b;border:1px solid #cbd5e1;border-radius:12px;padding:2px 8px;font-size:0.75rem;">⚪ TẮT NHẬN ĐƠN</span></span>
                            </c:otherwise>
                        </c:choose>
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
                    <c:when test="${isShipper}">
                        <div style="display: inline-flex; align-items: center; gap: 10px;">
                            <span><i class="fa-solid fa-headset text-primary"></i> Hotline tài xế: <strong>1900 6869</strong></span>
                            <a href="${pageContext.request.contextPath}/shipper/dashboard?action=toggleStatus&redirect=${pageContext.request.requestURI}" 
                               class="topbar-toggle-shipper-btn ${isShipperActive ? 'online' : 'offline'}"
                               title="${isShipperActive ? 'Bấm để TẮT nhận đơn và chuyển sang chế độ Khách đặt món' : 'Bấm để BẬT chế độ nhận đơn'}">
                                <span class="shipper-pulse-dot"></span>
                                <span>${isShipperActive ? 'Đang Nhận Đơn' : 'Đang Nghỉ'}</span>
                                <i class="fa-solid fa-power-off"></i>
                            </a>
                        </div>
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
                    <span class="brand-badge"><i class="fa-solid fa-shield-halved"></i> Đăng Nhập &amp; Đăng Ký</span>
                </c:when>
                <c:when test="${isSeller}">
                    <span class="brand-badge" style="background:#e6f9ed;color:#1e7e34;border-color:#a3e9b9;"><i class="fa-solid fa-store"></i> Đối Tác Quán</span>
                </c:when>
                <c:when test="${isShipper}">
                    <c:choose>
                        <c:when test="${isShipperActive}">
                            <span class="brand-badge" style="background:#e6f9ed;color:#10ac84;border-color:#a3e9b9;"><i class="fa-solid fa-motorcycle"></i> Shipper Online</span>
                        </c:when>
                        <c:otherwise>
                            <span class="brand-badge" style="background:#f1f5f9;color:#64748b;border-color:#cbd5e1;"><i class="fa-solid fa-power-off"></i> Shipper Nghỉ</span>
                        </c:otherwise>
                    </c:choose>
                </c:when>
            </c:choose>
        </a>

        <c:if test="${not isAuth}">
            <a href="${pageContext.request.contextPath}/foods" class="nav-mobile-location-pill" title="Địa điểm giao hàng">
                <i class="fa-solid fa-location-dot"></i>
                <span>TP. Thủ Đức</span>
            </a>
        </c:if>

        <c:choose>
            <c:when test="${isAuth}">
                <!-- Simplified Auth Top Navigation -->
                <div class="nav-auth-actions">
                    <a href="${pageContext.request.contextPath}/home" class="btn-auth-back">
                        <i class="fa-solid fa-arrow-left"></i>
                        <span>Về trang chủ</span>
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Search Bar (Ẩn với merchant và shipper đang BẬT nhận đơn) -->
                <c:if test="${not isSeller and not isShipperActive}">
                    <div class="nav-search">
                        <form action="${pageContext.request.contextPath}/foods" method="GET" class="search-form">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" name="search" placeholder="Tìm quán ăn, món ăn &amp; đồ uống" class="search-input" value="${param.search}">
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
                            <li><a href="${pageContext.request.contextPath}/foods" class="${pageContext.request.servletPath eq '/foods' or pageContext.request.servletPath eq '/food-detail' ? 'active' : ''}">Thực đơn</a></li>
                            <li><a href="${pageContext.request.contextPath}/merchant/dashboard" class="${pageContext.request.servletPath.startsWith('/merchant') ? 'active' : ''}">Kênh Quán Ăn</a></li>
                        </c:when>
                        <c:when test="${isShipper and isShipperActive}">
                            <!-- Khi BẬT chế độ nhận đơn: Shipper KHÔNG THỂ ĐẶT HÀNG (Ẩn giỏ hàng, chỉ nhận đơn và xem lịch sử giao) -->
                            <li>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="${pageContext.request.servletPath eq '/shipper/dashboard' and (empty param.tab or param.tab ne 'history') ? 'active' : ''}">
                                    <i class="fa-solid fa-gauge-high"></i> Nhận đơn giao
                                </a>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=history" class="${pageContext.request.servletPath eq '/shipper/history' or param.tab eq 'history' ? 'active' : ''}">
                                    <i class="fa-solid fa-clock-rotate-left"></i> Lịch sử chuyến giao
                                </a>
                            </li>
                        </c:when>
                        <c:when test="${isShipper and not isShipperActive}">
                            <!-- Khi TẮT chế độ nhận đơn: Shipper có thể đặt hàng như 1 khách thông thường -->
                            <li>
                                <a href="${pageContext.request.contextPath}/foods" class="${pageContext.request.servletPath eq '/foods' ? 'active' : ''}">
                                    Thực đơn
                                </a>
                            </li>
                            <li class="nav-cart-item-dropdown">
                                <a href="${pageContext.request.contextPath}/cart" class="cart-nav-link ${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                                    <i class="fa-solid fa-bag-shopping"></i>
                                    <span>Giỏ hàng</span>
                                    <c:set var="cartCount" value="${sessionScope.cart != null ? sessionScope.cart.size() : 0}" />
                                    <span class="cart-badge">${cartCount}</span>
                                </a>

                                <!-- Mini Cart Hover Preview Dropdown -->
                                <div class="cart-hover-dropdown">
                                    <div class="cart-hover-header">
                                        <span class="cart-hover-title">
                                            <i class="fa-solid fa-bag-shopping text-primary"></i> Món ăn trong giỏ
                                        </span>
                                        <span class="cart-hover-count">(${cartCount} món)</span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.cart and sessionScope.cart.size() > 0}">
                                            <c:set var="navCartTotal" value="0" />
                                            <c:forEach items="${sessionScope.cart.values()}" var="item">
                                                <c:set var="navCartTotal" value="${navCartTotal + item.totalPrice}" />
                                            </c:forEach>
                                            <c:set var="freeshipTarget" value="99000" />
                                            <c:set var="freeshipDiff" value="${freeshipTarget - navCartTotal}" />
                                            <c:set var="freeshipPercent" value="${(navCartTotal / freeshipTarget) * 100}" />
                                            <c:if test="${freeshipPercent > 100}">
                                                <c:set var="freeshipPercent" value="100" />
                                            </c:if>

                                            <!-- Smart Freeship Progress Bar -->
                                            <div class="cart-hover-freeship-box ${freeshipDiff <= 0 ? 'achieved' : ''}">
                                                <div class="freeship-header-row">
                                                    <c:choose>
                                                        <c:when test="${freeshipDiff <= 0}">
                                                            <span class="freeship-text-achieved"><i class="fa-solid fa-circle-check text-success"></i> Bạn đã được <strong>FREESHIP 15.000 đ</strong>!</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="freeship-text-need">Mua thêm <strong>${String.format("%,.0f", freeshipDiff)} đ</strong> để được <strong>FREESHIP</strong></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <i class="fa-solid fa-motorcycle freeship-bike-icon"></i>
                                                </div>
                                                <div class="freeship-progress-track">
                                                    <div class="freeship-progress-bar" style="width: ${freeshipPercent}%;"></div>
                                                </div>
                                            </div>

                                            <div class="cart-hover-list">
                                                <c:forEach items="${sessionScope.cart.values()}" var="item">
                                                    <a href="${pageContext.request.contextPath}/food-detail?id=${item.food.id}" class="cart-hover-item">
                                                        <img src="${item.food.image}" alt="${item.food.name}" class="cart-hover-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'">
                                                        <div class="cart-hover-info">
                                                            <div class="cart-hover-name" title="${item.food.name}">${item.food.name}</div>
                                                            <div class="cart-hover-meta">
                                                                <span class="cart-hover-qty">x${item.quantity}</span>
                                                                <span class="cart-hover-price">${String.format("%,.0f", item.totalPrice)} đ</span>
                                                            </div>
                                                        </div>
                                                    </a>
                                                </c:forEach>
                                            </div>
                                            <div class="cart-hover-footer">
                                                <div class="cart-hover-total-row">
                                                    <span>Tổng thanh toán:</span>
                                                    <strong class="cart-hover-total-val">${String.format("%,.0f", navCartTotal)} đ</strong>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary btn-sm btn-cart-hover-cta">
                                                    <span>Xem Giỏ Hàng &amp; Đặt Món</span>
                                                    <i class="fa-solid fa-arrow-right"></i>
                                                </a>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="cart-hover-empty">
                                                <div class="cart-hover-empty-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                                                <p>Chưa có món ăn nào trong giỏ hàng</p>
                                                <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline btn-sm btn-cart-empty-go">
                                                    Khám phá thực đơn ngay
                                                </a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </li>
                            <li>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="${pageContext.request.servletPath eq '/shipper/dashboard' ? 'active' : ''}">
                                    <i class="fa-solid fa-motorcycle"></i> Kênh Tài Xế
                                </a>
                            </li>
                        </c:when>
                        <c:otherwise>
                            <li>
                                <a href="${pageContext.request.contextPath}/foods" class="${pageContext.request.servletPath eq '/foods' ? 'active' : ''}">
                                    Thực đơn
                                </a>
                            </li>
                            <li class="nav-cart-item-dropdown">
                                <a href="${pageContext.request.contextPath}/cart" class="cart-nav-link ${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                                    <i class="fa-solid fa-bag-shopping"></i>
                                    <span>Giỏ hàng</span>
                                    <c:set var="cartCount" value="${sessionScope.cart != null ? sessionScope.cart.size() : 0}" />
                                    <span class="cart-badge">${cartCount}</span>
                                </a>

                                <!-- Mini Cart Hover Preview Dropdown -->
                                <div class="cart-hover-dropdown">
                                    <div class="cart-hover-header">
                                        <span class="cart-hover-title">
                                            <i class="fa-solid fa-bag-shopping text-primary"></i> Món ăn trong giỏ
                                        </span>
                                        <span class="cart-hover-count">(${cartCount} món)</span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.cart and sessionScope.cart.size() > 0}">
                                            <c:set var="navCartTotal" value="0" />
                                            <c:forEach items="${sessionScope.cart.values()}" var="item">
                                                <c:set var="navCartTotal" value="${navCartTotal + item.totalPrice}" />
                                            </c:forEach>
                                            <c:set var="freeshipTarget" value="99000" />
                                            <c:set var="freeshipDiff" value="${freeshipTarget - navCartTotal}" />
                                            <c:set var="freeshipPercent" value="${(navCartTotal / freeshipTarget) * 100}" />
                                            <c:if test="${freeshipPercent > 100}">
                                                <c:set var="freeshipPercent" value="100" />
                                            </c:if>

                                            <!-- Smart Freeship Progress Bar -->
                                            <div class="cart-hover-freeship-box ${freeshipDiff <= 0 ? 'achieved' : ''}">
                                                <div class="freeship-header-row">
                                                    <c:choose>
                                                        <c:when test="${freeshipDiff <= 0}">
                                                            <span class="freeship-text-achieved"><i class="fa-solid fa-circle-check text-success"></i> Bạn đã được <strong>FREESHIP 15.000 đ</strong>!</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="freeship-text-need">Mua thêm <strong>${String.format("%,.0f", freeshipDiff)} đ</strong> để được <strong>FREESHIP</strong></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <i class="fa-solid fa-motorcycle freeship-bike-icon"></i>
                                                </div>
                                                <div class="freeship-progress-track">
                                                    <div class="freeship-progress-bar" style="width: ${freeshipPercent}%;"></div>
                                                </div>
                                            </div>

                                            <div class="cart-hover-list">
                                                <c:forEach items="${sessionScope.cart.values()}" var="item">
                                                    <a href="${pageContext.request.contextPath}/food-detail?id=${item.food.id}" class="cart-hover-item">
                                                        <img src="${item.food.image}" alt="${item.food.name}" class="cart-hover-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'">
                                                        <div class="cart-hover-info">
                                                            <div class="cart-hover-name" title="${item.food.name}">${item.food.name}</div>
                                                            <div class="cart-hover-meta">
                                                                <span class="cart-hover-qty">x${item.quantity}</span>
                                                                <span class="cart-hover-price">${String.format("%,.0f", item.totalPrice)} đ</span>
                                                            </div>
                                                        </div>
                                                    </a>
                                                </c:forEach>
                                            </div>
                                            <div class="cart-hover-footer">
                                                <div class="cart-hover-total-row">
                                                    <span>Tổng thanh toán:</span>
                                                    <strong class="cart-hover-total-val">${String.format("%,.0f", navCartTotal)} đ</strong>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary btn-sm btn-cart-hover-cta">
                                                    <span>Xem Giỏ Hàng &amp; Đặt Món</span>
                                                    <i class="fa-solid fa-arrow-right"></i>
                                                </a>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="cart-hover-empty">
                                                <div class="cart-hover-empty-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                                                <p>Chưa có món ăn nào trong giỏ hàng</p>
                                                <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline btn-sm btn-cart-empty-go">
                                                    Khám phá thực đơn ngay
                                                </a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </li>
                        </c:otherwise>
                    </c:choose>
                </ul>

                <!-- User Actions -->
                <div class="nav-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <!-- Chuông thông báo Realtime & Popover List Preview -->
                            <div class="nav-notif-dropdown-wrapper" id="navNotifDropdownWrapper">
                                <a href="${pageContext.request.contextPath}/notifications" class="nav-notif-btn" id="navNotifBtn" title="Xem thông báo của bạn" aria-haspopup="true" aria-expanded="false">
                                    <i class="fa-solid fa-bell"></i>
                                    <span class="nav-notif-badge" id="navNotifBadge" style="display: none;">0</span>
                                </a>

                                <!-- Notification Popover Preview -->
                                <div class="nav-notif-popover" id="navNotifPopover">
                                    <div class="nav-notif-popover-header">
                                        <div class="notif-popover-title">
                                            <i class="fa-solid fa-bell text-primary"></i>
                                            <span>Thông báo</span>
                                            <span class="notif-popover-badge" id="popoverUnreadBadge" style="display: none;">0</span>
                                        </div>
                                        <button type="button" class="btn-popover-mark-all" id="btnPopoverMarkAll" onclick="markAllNavNotifsRead(event)">
                                            <i class="fa-solid fa-check-double text-success"></i> Đã đọc tất cả
                                        </button>
                                    </div>

                                    <div class="nav-notif-popover-body" id="navNotifList">
                                        <div class="notif-popover-loading">
                                            <i class="fa-solid fa-circle-notch fa-spin text-primary"></i>
                                            <span>Đang tải thông báo...</span>
                                        </div>
                                    </div>

                                    <div class="nav-notif-popover-footer">
                                        <a href="${pageContext.request.contextPath}/notifications" class="btn-popover-view-all">
                                            <span>Xem tất cả thông báo</span>
                                            <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>

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
                                                <c:when test="${isShipper}">
                                                    <span class="role-badge" style="background:${isShipperActive ? '#e6f9ed' : '#f1f5f9'};color:${isShipperActive ? '#10ac84' : '#64748b'};">
                                                        <i class="fa-solid fa-motorcycle"></i> ${isShipperActive ? 'Shipper (Đang nhận đơn)' : 'Shipper (Ngoại tuyến)'}
                                                    </span>
                                                </c:when>
                                                <c:otherwise><span class="role-badge role-customer"><i class="fa-solid fa-crown"></i> Khách hàng thân thiết</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </a>
                                    <div class="dropdown-divider"></div>

                                    <c:if test="${isShipper}">
                                        <!-- Công tắc Bật/Tắt chế độ Shipper trực quan trong Menu -->
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard?action=toggleStatus&redirect=${pageContext.request.requestURI}" 
                                           style="background:${isShipperActive ? '#fff5f5' : '#f0fff4'}; font-weight: 600; display: flex; align-items: center; justify-content: space-between; border-radius: 8px; margin: 4px 8px; padding: 10px 14px; text-decoration: none;">
                                            <span><i class="fa-solid fa-power-off ${isShipperActive ? 'text-danger' : 'text-success'}"></i> ${isShipperActive ? 'Tắt Nhận Đơn' : 'Bật Nhận Đơn'}</span>
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 6px; background:${isShipperActive ? '#fee2e2' : '#dcfce7'}; color:${isShipperActive ? '#dc2626' : '#16a34a'}; font-weight: bold;">${isShipperActive ? 'BẬT' : 'TẮT'}</span>
                                        </a>
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="text-primary font-weight-bold">
                                            <i class="fa-solid fa-gauge-high"></i> Bảng điều khiển tài xế
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=income">
                                            <i class="fa-solid fa-wallet text-success"></i> Thu nhập tài xế
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=history">
                                            <i class="fa-solid fa-clock-rotate-left text-info"></i> Lịch sử chuyến giao
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=violations">
                                            <i class="fa-solid fa-triangle-exclamation text-warning"></i> Điểm vi phạm
                                        </a>
                                    </c:if>

                                    <!-- Link tới Trang Thông Báo Chung -->
                                    <a href="${pageContext.request.contextPath}/notifications" class="${pageContext.request.servletPath eq '/notifications' ? 'active-link' : ''}">
                                        <i class="fa-solid fa-bell text-warning"></i> Thông báo
                                        <span class="badge bg-danger ms-auto" id="dropdownNotifBadge" style="display:none; font-size: 0.7rem; border-radius: 50px;">0</span>
                                    </a>

                                    <a href="${pageContext.request.contextPath}/profile" class="${pageContext.request.servletPath eq '/profile' and (empty param.tab or param.tab eq 'profile') ? 'active-link' : ''}">
                                        <i class="fa-solid fa-id-card text-primary"></i> Tài khoản của tôi
                                    </a>

                                    <!-- Đơn hàng đã đặt & Kho Voucher: ẨN hoàn toàn khi shipper đang BẬT nhận đơn; HIỆN khi shipper TẮT nhận đơn hoặc là khách thường -->
                                    <c:if test="${not isSeller and not isShipperActive}">
                                        <a href="${pageContext.request.contextPath}/profile?tab=orders" class="${pageContext.request.servletPath eq '/profile' and param.tab eq 'orders' ? 'active-link' : ''}">
                                            <i class="fa-solid fa-clock-rotate-left text-secondary"></i> Đơn hàng đã đặt
                                        </a>
                                        <a href="${pageContext.request.contextPath}/profile?tab=vouchers" class="${pageContext.request.servletPath eq '/profile' and param.tab eq 'vouchers' ? 'active-link' : ''}">
                                            <i class="fa-solid fa-ticket text-danger"></i> Voucher của tôi
                                        </a>
                                    </c:if>

                                    <c:if test="${sessionScope.currentUser.role eq 'ADMIN'}">
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-chart-line text-warning"></i> Quản trị hệ thống</a>
                                    </c:if>

                                    <c:if test="${sessionScope.currentUser.seller}">
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/foods"><i class="fa-solid fa-utensils text-success"></i> Xem thực đơn toàn sàn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/dashboard" class="text-primary font-weight-bold"><i class="fa-solid fa-store"></i> Kênh Quản Lý Quán Ăn</a>
                                        <a href="${pageContext.request.contextPath}/merchant/foods"><i class="fa-solid fa-bowl-food"></i> Món ăn của quán tôi</a>
                                        <a href="${pageContext.request.contextPath}/merchant/revenue"><i class="fa-solid fa-chart-line"></i> Báo cáo doanh thu</a>
                                        <a href="${pageContext.request.contextPath}/merchant/shippers"><i class="fa-solid fa-motorcycle"></i> Danh sách shipper</a>
                                        <a href="${pageContext.request.contextPath}/merchant/orders"><i class="fa-solid fa-receipt"></i> Đơn hàng của quán</a>
                                        <a href="${pageContext.request.contextPath}/merchant/profile"><i class="fa-solid fa-gear"></i> Cài đặt quán ăn</a>
                                    </c:if>

                                    <div class="dropdown-divider"></div>
                                    
                                    <!-- Chế độ giao diện Sáng / Tối / Tự động -->
                                    <div class="user-dropdown-theme-section">
                                        <div class="dropdown-theme-header">
                                            <span class="dropdown-theme-label"><i class="fa-solid fa-circle-half-stroke text-primary"></i> Chế độ giao diện</span>
                                            <span class="dropdown-theme-hint" id="dropdownThemeHint">Tự động</span>
                                        </div>
                                        <div class="dropdown-theme-options" role="radiogroup" aria-label="Giao diện hiển thị">
                                            <button type="button" class="dropdown-theme-btn" data-theme-choice="light" onclick="setAppTheme('light')" title="Giao diện Sáng">
                                                <i class="fa-solid fa-sun text-warning"></i>
                                                <span>Sáng</span>
                                            </button>
                                            <button type="button" class="dropdown-theme-btn" data-theme-choice="dark" onclick="setAppTheme('dark')" title="Giao diện Tối">
                                                <i class="fa-solid fa-moon text-primary"></i>
                                                <span>Tối</span>
                                            </button>
                                            <button type="button" class="dropdown-theme-btn" data-theme-choice="system" onclick="setAppTheme('system')" title="Theo giao diện thiết bị">
                                                <i class="fa-solid fa-desktop text-info"></i>
                                                <span>Tự động</span>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="dropdown-divider"></div>
                                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất</a>
                                </div>
                            </div>

                            <script>
                                var navNotifCache = null;
                                var lastNavNotifFetch = 0;
                                var isFetchingNavNotif = false;

                                function updateUnreadNotifBadge() {
                                    fetch('${pageContext.request.contextPath}/api/notifications/unread-count')
                                        .then(function(res) { return res.json(); })
                                        .then(function(data) {
                                            syncNotifBadges(data.unreadCount || 0);
                                        })
                                        .catch(function(err) {});
                                }

                                function syncNotifBadges(count) {
                                    var badge = document.getElementById('navNotifBadge');
                                    var dropBadge = document.getElementById('dropdownNotifBadge');
                                    var popBadge = document.getElementById('popoverUnreadBadge');
                                    if (badge) {
                                        if (count > 0) {
                                            badge.innerText = count > 99 ? '99+' : count;
                                            badge.style.display = 'flex';
                                            badge.classList.add('has-unread');
                                        } else {
                                            badge.style.display = 'none';
                                            badge.classList.remove('has-unread');
                                        }
                                    }
                                    if (dropBadge) {
                                        if (count > 0) {
                                            dropBadge.innerText = count;
                                            dropBadge.style.display = 'inline-block';
                                        } else {
                                            dropBadge.style.display = 'none';
                                        }
                                    }
                                    if (popBadge) {
                                        if (count > 0) {
                                            popBadge.innerText = count + ' mới';
                                            popBadge.style.display = 'inline-block';
                                        } else {
                                            popBadge.style.display = 'none';
                                        }
                                    }
                                }

                                function loadRecentNavNotifications(force) {
                                    var now = Date.now();
                                    if (!force && navNotifCache && (now - lastNavNotifFetch < 12000)) {
                                        renderNavNotifications(navNotifCache);
                                        return;
                                    }
                                    if (isFetchingNavNotif) return;
                                    isFetchingNavNotif = true;

                                    fetch('${pageContext.request.contextPath}/api/notifications/recent')
                                        .then(function(res) { return res.json(); })
                                        .then(function(data) {
                                            isFetchingNavNotif = false;
                                            if (data.success) {
                                                navNotifCache = data;
                                                lastNavNotifFetch = Date.now();
                                                renderNavNotifications(data);
                                                syncNotifBadges(data.unreadCount || 0);
                                            }
                                        })
                                        .catch(function(err) {
                                            isFetchingNavNotif = false;
                                            var listEl = document.getElementById('navNotifList');
                                            if (listEl) {
                                                listEl.innerHTML = '<div class="notif-popover-empty"><i class="fa-regular fa-bell-slash"></i><span>Không thể tải thông báo</span></div>';
                                            }
                                        });
                                }

                                function escapeNotifHtml(str) {
                                    if (!str) return '';
                                    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
                                }

                                function renderNavNotifications(data) {
                                    var listEl = document.getElementById('navNotifList');
                                    if (!listEl) return;
                                    var notifs = data.notifications || [];
                                    if (notifs.length === 0) {
                                        listEl.innerHTML = '<div class="notif-popover-empty"><i class="fa-regular fa-bell-slash"></i><span>Bạn không có thông báo nào</span></div>';
                                        return;
                                    }

                                    var html = '';
                                    notifs.forEach(function(n) {
                                        var unreadCls = n.read ? '' : 'unread';
                                        var rawLink = n.link || '';
                                        var linkUrl = '';
                                        if (rawLink) {
                                            linkUrl = rawLink.startsWith('/') ? ('${pageContext.request.contextPath}' + rawLink) : ('${pageContext.request.contextPath}/' + rawLink);
                                        } else {
                                            linkUrl = '${pageContext.request.contextPath}/notifications';
                                        }

                                        html += '<div class="popover-notif-item ' + unreadCls + '" onclick="handleNavNotifItemClick(' + n.id + ', \'' + escapeNotifHtml(linkUrl) + '\', ' + n.read + ', event)">';
                                        html += '  <div class="popover-item-icon"><i class="' + escapeNotifHtml(n.iconClass) + '"></i></div>';
                                        html += '  <div class="popover-item-content">';
                                        html += '    <div class="popover-item-title">';
                                        html += '      <span>' + escapeNotifHtml(n.title) + '</span>';
                                        if (!n.read) {
                                            html += '      <span class="popover-unread-dot" title="Chưa đọc"></span>';
                                        }
                                        html += '    </div>';
                                        html += '    <p class="popover-item-desc">' + escapeNotifHtml(n.message) + '</p>';
                                        html += '    <span class="popover-item-time"><i class="fa-regular fa-clock"></i> ' + escapeNotifHtml(n.timeAgo) + '</span>';
                                        html += '  </div>';
                                        html += '</div>';
                                    });

                                    listEl.innerHTML = html;
                                }

                                function handleNavNotifItemClick(id, linkUrl, isRead, event) {
                                    if (event) event.preventDefault();
                                    if (!isRead && id) {
                                        fetch('${pageContext.request.contextPath}/api/notifications/mark-read?id=' + id)
                                            .catch(function(err){});
                                    }
                                    window.location.href = linkUrl;
                                }

                                function markAllNavNotifsRead(event) {
                                    if (event) event.stopPropagation();
                                    fetch('${pageContext.request.contextPath}/api/notifications/mark-all-read')
                                        .then(function(res) { return res.json(); })
                                        .then(function(data) {
                                            if (data.success) {
                                                if (navNotifCache && navNotifCache.notifications) {
                                                    navNotifCache.notifications.forEach(function(n) { n.read = true; });
                                                    navNotifCache.unreadCount = 0;
                                                    renderNavNotifications(navNotifCache);
                                                }
                                                syncNotifBadges(0);
                                            }
                                        })
                                        .catch(function(err) {});
                                }

                                document.addEventListener("DOMContentLoaded", function() {
                                    updateUnreadNotifBadge();
                                    setInterval(updateUnreadNotifBadge, 8000);

                                    var wrapper = document.getElementById('navNotifDropdownWrapper');
                                    var notifCloseTimeout = null;

                                    if (wrapper) {
                                        wrapper.addEventListener('mouseenter', function() {
                                            if (notifCloseTimeout) {
                                                clearTimeout(notifCloseTimeout);
                                                notifCloseTimeout = null;
                                            }
                                            wrapper.classList.add('is-open');
                                            loadRecentNavNotifications(false);
                                        });

                                        wrapper.addEventListener('mouseleave', function() {
                                            if (notifCloseTimeout) {
                                                clearTimeout(notifCloseTimeout);
                                            }
                                            notifCloseTimeout = setTimeout(function() {
                                                wrapper.classList.remove('is-open');
                                            }, 280);
                                        });
                                    }
                                });
                            </script>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn-guest-theme-toggle" onclick="setAppTheme(document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark')" title="Đổi giao diện Sáng / Tối" aria-label="Đổi giao diện">
                                <i class="fa-solid fa-moon guest-icon-moon"></i>
                                <i class="fa-solid fa-sun guest-icon-sun"></i>
                            </button>
                            <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-outline btn-sm btn-nav-auth">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/auth?action=login#register" class="btn btn-primary btn-sm btn-nav-auth">Đăng ký</a>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Hamburger Button for Mobile -->
                <button type="button" class="btn-hamburger" id="mobileMenuToggle" aria-label="Mở menu">
                    <span class="hamburger-line"></span>
                    <span class="hamburger-line"></span>
                    <span class="hamburger-line"></span>
                </button>
            </c:otherwise>
        </c:choose>
    </div>
</nav>

<c:if test="${not isAuth}">
    <!-- Mobile Drawer Backdrop -->
    <div class="mobile-drawer-backdrop" id="mobileDrawerBackdrop"></div>

    <!-- Mobile Drawer Menu -->
    <div class="mobile-drawer" id="mobileDrawer">
        <div class="mobile-drawer-header">
            <a href="${pageContext.request.contextPath}/home" class="mobile-drawer-brand">
                <img src="${pageContext.request.contextPath}/assets/images/logo/logo-dark-transparent.png" alt="Utee" class="mobile-drawer-logo">
            </a>
            <button type="button" class="mobile-drawer-close" id="mobileDrawerClose" aria-label="Đóng menu">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="mobile-drawer-body">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <div class="mobile-user-card">
                        <div class="mobile-user-avatar">
                            <i class="fa-solid fa-circle-user"></i>
                        </div>
                        <div class="mobile-user-info">
                            <strong class="mobile-user-name">${sessionScope.currentUser.fullName}</strong>
                            <span class="mobile-user-phone">${sessionScope.currentUser.phone != null ? sessionScope.currentUser.phone : sessionScope.currentUser.email}</span>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mobile-auth-box">
                        <p>Đăng nhập để nhận ưu đãi đến 50K!</p>
                        <div class="mobile-auth-btns">
                            <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-primary btn-sm w-100">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/auth?action=login#register" class="btn btn-outline btn-sm w-100">Đăng ký</a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Mobile Quick Search Form -->
            <form action="${pageContext.request.contextPath}/foods" method="GET" class="mobile-drawer-search">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" name="search" placeholder="Tìm món ăn, trà sữa, pizza..." value="${param.search}">
                <button type="submit">Tìm</button>
            </form>

            <div class="mobile-drawer-nav-group">
                <div class="drawer-group-title">Khám Phá</div>
                <ul class="mobile-drawer-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/home" class="${pageContext.request.servletPath eq '' or pageContext.request.servletPath eq '/home' ? 'active' : ''}">
                            <i class="fa-solid fa-house text-primary"></i> Trang chủ
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/foods" class="${pageContext.request.servletPath eq '/foods' ? 'active' : ''}">
                            <i class="fa-solid fa-utensils text-success"></i> Thực đơn đa dạng
                        </a>
                    </li>
                    <c:if test="${not isSeller and not isShipperActive}">
                        <li>
                            <a href="${pageContext.request.contextPath}/cart" class="${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                                <i class="fa-solid fa-bag-shopping text-warning"></i> Giỏ hàng của bạn
                                <span class="drawer-badge">${sessionScope.cart != null ? sessionScope.cart.size() : 0}</span>
                            </a>
                        </li>
                    </c:if>
                    <li>
                        <a href="${pageContext.request.contextPath}/notifications" class="${pageContext.request.servletPath eq '/notifications' ? 'active' : ''}">
                            <i class="fa-solid fa-bell text-warning"></i> Thông báo
                        </a>
                    </li>
                </ul>
            </div>

            <c:if test="${not empty sessionScope.currentUser}">
                <div class="mobile-drawer-nav-group">
                    <div class="drawer-group-title">Tài Khoản</div>
                    <ul class="mobile-drawer-links">
                        <li>
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="fa-solid fa-id-card text-primary"></i> Thông tin cá nhân
                            </a>
                        </li>
                        <c:if test="${not isSeller and not isShipperActive}">
                            <li>
                                <a href="${pageContext.request.contextPath}/profile?tab=orders">
                                    <i class="fa-solid fa-clock-rotate-left text-info"></i> Đơn hàng đã đặt
                                </a>
                            </li>
                        </c:if>
                        <c:if test="${sessionScope.currentUser.seller}">
                            <li>
                                <a href="${pageContext.request.contextPath}/merchant/dashboard">
                                    <i class="fa-solid fa-store text-success"></i> Kênh Quán Ăn
                                </a>
                            </li>
                        </c:if>
                        <c:if test="${isShipper}">
                            <li>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard">
                                    <i class="fa-solid fa-motorcycle text-success"></i> Bảng điều khiển tài xế
                                </a>
                            </li>
                        </c:if>
                        <c:if test="${sessionScope.currentUser.role eq 'ADMIN'}">
                            <li>
                                <a href="${pageContext.request.contextPath}/admin/dashboard">
                                    <i class="fa-solid fa-shield-halved text-danger"></i> Quản trị hệ thống
                                </a>
                            </li>
                        </c:if>
                        <li>
                            <a href="${pageContext.request.contextPath}/auth?action=logout" class="text-danger">
                                <i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất
                            </a>
                        </li>
                    </ul>
                </div>
            </c:if>

            <!-- Giao diện hiển thị trên Mobile Drawer -->
            <div class="mobile-drawer-nav-group">
                <div class="drawer-group-title">Giao Diện Ứng Dụng</div>
                <div class="mobile-theme-options" role="radiogroup" aria-label="Giao diện hiển thị">
                    <button type="button" class="mobile-theme-btn" data-theme-choice="light" onclick="setAppTheme('light')">
                        <i class="fa-solid fa-sun text-warning"></i>
                        <span>Sáng</span>
                    </button>
                    <button type="button" class="mobile-theme-btn" data-theme-choice="dark" onclick="setAppTheme('dark')">
                        <i class="fa-solid fa-moon text-primary"></i>
                        <span>Tối</span>
                    </button>
                    <button type="button" class="mobile-theme-btn" data-theme-choice="system" onclick="setAppTheme('system')">
                        <i class="fa-solid fa-desktop text-info"></i>
                        <span>Tự động</span>
                    </button>
                </div>
            </div>

            <div class="mobile-drawer-footer">
                <div class="drawer-hotline">
                    <i class="fa-solid fa-headset text-primary"></i>
                    <span>Tổng đài CSKH: <strong>1900 6868</strong></span>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Bottom Navigation Bar (Fixed Bottom) -->
    <nav class="mobile-bottom-nav">
        <a href="${pageContext.request.contextPath}/home" class="bottom-nav-item ${pageContext.request.servletPath eq '' or pageContext.request.servletPath eq '/home' ? 'active' : ''}">
            <i class="fa-solid fa-house"></i>
            <span>Trang chủ</span>
        </a>
        <a href="${pageContext.request.contextPath}/foods" class="bottom-nav-item ${pageContext.request.servletPath eq '/foods' ? 'active' : ''}">
            <i class="fa-solid fa-utensils"></i>
            <span>Thực đơn</span>
        </a>
        <c:choose>
            <c:when test="${isSeller}">
                <a href="${pageContext.request.contextPath}/merchant/dashboard" class="bottom-nav-item ${pageContext.request.servletPath.startsWith('/merchant') ? 'active' : ''}">
                    <i class="fa-solid fa-store"></i>
                    <span>Kênh Quán</span>
                </a>
            </c:when>
            <c:when test="${isShipper and isShipperActive}">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="bottom-nav-item ${pageContext.request.servletPath.startsWith('/shipper') ? 'active' : ''}">
                    <i class="fa-solid fa-motorcycle"></i>
                    <span>Nhận Đơn</span>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/cart" class="bottom-nav-item ${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                    <div class="bottom-nav-icon-wrap">
                        <i class="fa-solid fa-bag-shopping"></i>
                        <c:set var="cartCount" value="${sessionScope.cart != null ? sessionScope.cart.size() : 0}" />
                        <span class="bottom-cart-badge ${cartCount > 0 ? '' : 'd-none'}" id="bottomCartBadge">${cartCount}</span>
                    </div>
                    <span>Giỏ hàng</span>
                </a>
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${not empty sessionScope.currentUser}">
                <a href="${pageContext.request.contextPath}/profile" class="bottom-nav-item ${pageContext.request.servletPath eq '/profile' ? 'active' : ''}">
                    <i class="fa-solid fa-circle-user"></i>
                    <span>Tài khoản</span>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/auth?action=login" class="bottom-nav-item ${pageContext.request.servletPath eq '/auth' ? 'active' : ''}">
                    <i class="fa-solid fa-arrow-right-to-bracket"></i>
                    <span>Đăng nhập</span>
                </a>
            </c:otherwise>
        </c:choose>
    </nav>
</c:if>
