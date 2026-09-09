<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="merchant-portal-header">
    <div class="container">
        <!-- Compact & Modern Merchant App Bar -->
        <div class="merchant-app-bar">
            <div class="merchant-store-profile">
                <div class="merchant-store-avatar">
                    <i class="fa-solid fa-store"></i>
                </div>
                <div class="merchant-store-info">
                    <div class="merchant-store-meta-top">
                        <span class="merchant-badge-partner">
                            <i class="fa-solid fa-certificate"></i> Đối Tác Quán Utee
                        </span>
                        <span class="merchant-status-badge ${currentRestaurant.status eq 'OPEN' ? 'status-open' : 'status-closed'}">
                            <span class="dot-pulse" style="${currentRestaurant.status eq 'OPEN' ? '' : 'background: #dc2626; box-shadow: none;'}"></span>
                            <span>${currentRestaurant.status eq 'OPEN' ? 'Đang Mở Cửa' : 'Tạm Đóng Cửa'}</span>
                        </span>
                    </div>
                    <h1 class="merchant-store-title">${currentRestaurant.name}</h1>
                    <div class="merchant-store-sub">
                        <span class="merchant-sub-item">
                            <i class="fa-solid fa-location-dot text-primary"></i> ${currentRestaurant.address}
                        </span>
                        <span class="merchant-sub-item">
                            <i class="fa-solid fa-phone text-success"></i> ${currentRestaurant.phone}
                        </span>
                    </div>
                </div>
            </div>

            <div class="merchant-header-actions">
                <!-- Nút bật tắt mở quán nhanh 1-click -->
                <form action="${pageContext.request.contextPath}/merchant/profile" method="POST" style="display:inline;">
                    <input type="hidden" name="action" value="toggleStatus" />
                    <button type="submit" class="btn-merchant-quick ${currentRestaurant.status eq 'OPEN' ? 'btn-danger-outline' : ''}" 
                            title="${currentRestaurant.status eq 'OPEN' ? 'Bấm để tạm đóng cửa quán' : 'Bấm để mở cửa nhận đơn'}">
                        <i class="fa-solid ${currentRestaurant.status eq 'OPEN' ? 'fa-door-closed text-danger' : 'fa-door-open text-success'}"></i>
                        <span>${currentRestaurant.status eq 'OPEN' ? 'Tạm đóng cửa' : 'Mở cửa nhận đơn'}</span>
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/home" class="btn-merchant-quick" title="Xem trang chủ dành cho khách hàng">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i>
                    <span>Xem web khách</span>
                </a>
                <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn-merchant-quick btn-danger-outline" title="Đăng xuất khỏi tài khoản quán">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </div>

        <!-- Modern Floating Navigation Tabs Bar -->
        <div class="merchant-tabs-bar">
            <a href="${pageContext.request.contextPath}/merchant/dashboard" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/dashboard' ? 'active' : ''}">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Tổng quan</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/orders" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/orders' ? 'active' : ''}">
                <i class="fa-solid fa-receipt"></i>
                <span>Đơn hàng</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/foods" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/foods' ? 'active' : ''}">
                <i class="fa-solid fa-bowl-food"></i>
                <span>Thực đơn món</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/revenue" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/revenue' ? 'active' : ''}">
                <i class="fa-solid fa-chart-line"></i>
                <span>Doanh thu</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/shippers" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/shippers' ? 'active' : ''}">
                <i class="fa-solid fa-motorcycle"></i>
                <span>Tài xế shipper</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/profile" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/profile' ? 'active' : ''}">
                <i class="fa-solid fa-gear"></i>
                <span>Cài đặt quán</span>
            </a>
        </div>

        <!-- Flash Message Alerts -->
        <c:if test="${not empty sessionScope.flashMessage}">
            <div class="alert alert-success mt-3" style="display:flex;align-items:center;gap:10px;padding:12px 18px;background:#ecfdf5;border:1px solid #a7f3d0;color:#065f46;border-radius:12px;font-weight:600;font-size:0.9rem;box-shadow:0 2px 8px rgba(0,0,0,0.03);">
                <i class="fa-solid fa-circle-check text-success" style="font-size:1.15rem;"></i>
                <span>${sessionScope.flashMessage}</span>
            </div>
            <c:remove var="flashMessage" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger mt-3" style="display:flex;align-items:center;gap:10px;padding:12px 18px;background:#fef2f2;border:1px solid #fecdd3;color:#991b1b;border-radius:12px;font-weight:600;font-size:0.9rem;box-shadow:0 2px 8px rgba(0,0,0,0.03);">
                <i class="fa-solid fa-circle-exclamation text-danger" style="font-size:1.15rem;"></i>
                <span>${sessionScope.flashError}</span>
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>
    </div>
</div>
