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
    /* Notification Bell UI/UX Pro Max */
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
        margin-right: 6px;
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
                                <span><i class="fa-solid fa-person-walking-luggage text-secondary"></i> <strong>Kênh Tài Xế:</strong> <span class="badge" style="background:#f1f5f9;color:#64748b;border:1px solid #cbd5e1;border-radius:12px;padding:2px 8px;font-size:0.75rem;">⚪ TẮT NHẬN ĐƠN (Chế độ Khách)</span></span>
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
                <c:otherwise>
                    <span class="brand-badge"><i class="fa-solid fa-bolt"></i> 30m Express</span>
                </c:otherwise>
            </c:choose>
        </a>

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
                            <li><a href="${pageContext.request.contextPath}/merchant/dashboard" class="${pageContext.request.servletPath eq '/merchant/dashboard' ? 'active' : ''}">Kênh Quán Ăn</a></li>
                            <li><a href="${pageContext.request.contextPath}/merchant/foods" class="${pageContext.request.servletPath eq '/merchant/foods' ? 'active' : ''}">Thực đơn món</a></li>
                            <li><a href="${pageContext.request.contextPath}/merchant/orders" class="${pageContext.request.servletPath eq '/merchant/orders' ? 'active' : ''}">Đơn hàng</a></li>
                            <li><a href="${pageContext.request.contextPath}/merchant/revenue" class="${pageContext.request.servletPath eq '/merchant/revenue' ? 'active' : ''}">Doanh thu</a></li>
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
                            <li>
                                <a href="${pageContext.request.contextPath}/cart" class="cart-nav-link ${pageContext.request.servletPath eq '/cart' ? 'active' : ''}">
                                    <i class="fa-solid fa-bag-shopping"></i>
                                    <span>Giỏ hàng</span>
                                    <c:set var="cartCount" value="${sessionScope.cart != null ? sessionScope.cart.size() : 0}" />
                                    <span class="cart-badge">${cartCount}</span>
                                </a>
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
                            <!-- Chuông thông báo Realtime cho cả 3 vai trò -->
                            <a href="${pageContext.request.contextPath}/notifications" class="nav-notif-btn" id="navNotifBtn" title="Xem thông báo của bạn">
                                <i class="fa-solid fa-bell"></i>
                                <span class="nav-notif-badge" id="navNotifBadge" style="display: none;">0</span>
                            </a>

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
                                                        <i class="fa-solid fa-motorcycle"></i> ${isShipperActive ? 'Shipper (Đang nhận đơn)' : 'Shipper (Ngoại tuyến - Khách)'}
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
                                            <span><i class="fa-solid fa-power-off ${isShipperActive ? 'text-danger' : 'text-success'}"></i> ${isShipperActive ? 'Tắt Nhận Đơn (Chế độ Khách)' : 'Bật Nhận Đơn (Chế độ Shipper)'}</span>
                                            <span style="font-size: 0.75rem; padding: 2px 8px; border-radius: 6px; background:${isShipperActive ? '#fee2e2' : '#dcfce7'}; color:${isShipperActive ? '#dc2626' : '#16a34a'}; font-weight: bold;">${isShipperActive ? 'BẬT' : 'TẮT'}</span>
                                        </a>
                                        <div class="dropdown-divider"></div>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard" class="text-primary font-weight-bold">
                                            <i class="fa-solid fa-gauge-high"></i> Bảng điều khiển tài xế
                                        </a>
                                        <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=history">
                                            <i class="fa-solid fa-clock-rotate-left text-info"></i> Lịch sử chuyến giao
                                        </a>
                                    </c:if>

                                    <!-- Link tới Trang Thông Báo Chung -->
                                    <a href="${pageContext.request.contextPath}/notifications" class="${pageContext.request.servletPath eq '/notifications' ? 'active-link' : ''}">
                                        <i class="fa-solid fa-bell text-warning"></i> Thông báo của tôi
                                        <span class="badge bg-danger ms-auto" id="dropdownNotifBadge" style="display:none; font-size: 0.7rem; border-radius: 50px;">0</span>
                                    </a>

                                    <a href="${pageContext.request.contextPath}/profile" class="${pageContext.request.servletPath eq '/profile' and (empty param.tab or param.tab eq 'profile') ? 'active-link' : ''}">
                                        <i class="fa-solid fa-id-card text-primary"></i> Tài khoản của tôi
                                    </a>

                                    <!-- Đơn hàng đã đặt & Giỏ hàng: ẨN hoàn toàn khi shipper đang BẬT nhận đơn; HIỆN khi shipper TẮT nhận đơn hoặc là khách thường -->
                                    <c:if test="${not isSeller and not isShipperActive}">
                                        <a href="${pageContext.request.contextPath}/profile?tab=orders" class="${pageContext.request.servletPath eq '/profile' and param.tab eq 'orders' ? 'active-link' : ''}">
                                            <i class="fa-solid fa-clock-rotate-left text-secondary"></i> Đơn hàng đã đặt
                                        </a>
                                        <a href="${pageContext.request.contextPath}/client/orders">
                                            <i class="fa-solid fa-receipt text-success"></i> Đánh giá đơn đã đặt
                                        </a>
                                        <a href="${pageContext.request.contextPath}/cart">
                                            <i class="fa-solid fa-bag-shopping text-warning"></i> Giỏ hàng hiện tại
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

                                    <div class="dropdown-divider"></div>
                                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="dropdown-logout"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng xuất</a>
                                </div>
                            </div>

                            <script>
                                document.addEventListener("DOMContentLoaded", function() {
                                    function updateUnreadNotifBadge() {
                                        fetch('${pageContext.request.contextPath}/api/notifications/unread-count')
                                            .then(function(res) { return res.json(); })
                                            .then(function(data) {
                                                var count = data.unreadCount || 0;
                                                var badge = document.getElementById('navNotifBadge');
                                                var dropBadge = document.getElementById('dropdownNotifBadge');
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
                                            })
                                            .catch(function(err) {});
                                    }
                                    updateUnreadNotifBadge();
                                    setInterval(updateUnreadNotifBadge, 5000);
                                });
                            </script>
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
