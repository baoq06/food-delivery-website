<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="merchant-portal-header">
    <div class="container">
        <!-- Header Box đồng bộ giao diện Admin / Portal -->
        <div class="admin-header-box merchant-header-box">
            <div>
                <span class="admin-badge"><i class="fa-solid fa-store"></i> Kênh Quản Lý Quán Ăn • Đối Tác Utee</span>
                <h1 class="admin-main-title">${currentRestaurant.name}</h1>
                <p class="admin-sub">
                    <i class="fa-solid fa-location-dot text-primary"></i> ${currentRestaurant.address}
                    &nbsp;•&nbsp; <i class="fa-solid fa-phone text-success"></i> ${currentRestaurant.phone}
                    &nbsp;•&nbsp; Trạng thái: 
                    <span class="badge ${currentRestaurant.status eq 'OPEN' ? 'badge-done' : 'badge-pending'}">
                        ${currentRestaurant.status eq 'OPEN' ? 'Đang Mở Cửa' : 'Tạm Đóng Cửa'}
                    </span>
                </p>
            </div>
            <div class="admin-actions">
                <a href="${pageContext.request.contextPath}/merchant/profile" class="btn btn-outline btn-sm">
                    <i class="fa-solid fa-store"></i> Thiết Lập Quán
                </a>
                <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-danger btn-sm">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng Xuất
                </a>
            </div>
        </div>

        <!-- Merchant Sub-Navigation Tabs Bar -->
        <div class="merchant-tabs-bar">
            <a href="${pageContext.request.contextPath}/merchant/dashboard" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/dashboard' ? 'active' : ''}">
                <i class="fa-solid fa-chart-pie"></i> <span>Tổng quan</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/foods" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/foods' ? 'active' : ''}">
                <i class="fa-solid fa-bowl-food"></i> <span>Thực đơn món</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/revenue" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/revenue' ? 'active' : ''}">
                <i class="fa-solid fa-chart-line"></i> <span>Doanh thu</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/shippers" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/shippers' ? 'active' : ''}">
                <i class="fa-solid fa-motorcycle"></i> <span>Tài xế shipper</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/orders" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/orders' ? 'active' : ''}">
                <i class="fa-solid fa-receipt"></i> <span>Đơn hàng</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/profile" class="merchant-tab-btn ${pageContext.request.servletPath eq '/merchant/profile' ? 'active' : ''}">
                <i class="fa-solid fa-gear"></i> <span>Cài đặt quán</span>
            </a>
        </div>

        <!-- Flash Message Alerts -->
        <c:if test="${not empty sessionScope.flashMessage}">
            <div class="alert alert-success mt-3" style="display:flex;align-items:center;gap:10px;padding:12px 18px;background:#e6f9ed;border:1px solid #a3e9b9;color:#1e7e34;border-radius:10px;">
                <i class="fa-solid fa-circle-check" style="font-size:1.2rem;"></i>
                <span>${sessionScope.flashMessage}</span>
            </div>
            <c:remove var="flashMessage" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger mt-3" style="display:flex;align-items:center;gap:10px;padding:12px 18px;background:#ffebee;border:1px solid #ffcdd2;color:#c62828;border-radius:10px;">
                <i class="fa-solid fa-circle-exclamation" style="font-size:1.2rem;"></i>
                <span>${sessionScope.flashError}</span>
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>
    </div>
</div>
