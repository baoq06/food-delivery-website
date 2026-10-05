<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="merchant-portal-header">
    <div class="container">
        <!-- Compact & Modern Merchant App Bar -->
        <div class="merchant-app-bar">
            <div class="merchant-store-profile">
                <div class="merchant-store-avatar" title="${currentRestaurant.name}">
                    <c:set var="mStoreLogo" value="${not empty currentRestaurant.logoUrl ? currentRestaurant.logoUrl : currentRestaurant.imageUrl}" />
                    <c:choose>
                        <c:when test="${not empty mStoreLogo}">
                            <img src="${mStoreLogo.startsWith('http') || mStoreLogo.startsWith('/') ? (mStoreLogo.startsWith('/') ? pageContext.request.contextPath.concat(mStoreLogo) : mStoreLogo) : pageContext.request.contextPath.concat('/').concat(mStoreLogo)}" 
                                 alt="${currentRestaurant.name}" 
                                 class="merchant-store-avatar-img"
                                 onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='inline-flex';" />
                            <i class="fa-solid fa-store" style="display: none;"></i>
                        </c:when>
                        <c:otherwise>
                            <i class="fa-solid fa-store"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="merchant-store-info">
                    <div class="merchant-store-meta-top">
                        <span class="merchant-badge-partner">
                            <i class="fa-solid fa-certificate"></i> Đối Tác Quán Utee
                        </span>
                        <c:choose>
                            <c:when test="${currentRestaurant.status eq 'BANNED'}">
                                <span class="merchant-status-badge" style="background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 4px 12px; border-radius: 20px; font-weight: 700;">
                                    <i class="fa-solid fa-ban"></i>
                                    <span>ĐÃ BỊ CẤM HOẠT ĐỘNG</span>
                                </span>
                            </c:when>
                            <c:when test="${currentRestaurant.status eq 'OPEN'}">
                                <span class="merchant-status-badge status-open">
                                    <span class="dot-pulse"></span>
                                    <span>Đang Mở Cửa</span>
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="merchant-status-badge status-closed">
                                    <span class="dot-pulse" style="background: #dc2626; box-shadow: none;"></span>
                                    <span>Tạm Đóng Cửa</span>
                                </span>
                            </c:otherwise>
                        </c:choose>
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
                <c:choose>
                    <c:when test="${currentRestaurant.status eq 'BANNED'}">
                        <div style="background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; padding: 8px 16px; border-radius: 20px; font-weight: 700; font-size: 0.85rem; display: inline-flex; align-items: center; gap: 6px;">
                            <i class="fa-solid fa-lock"></i> Đã bị khóa bởi Admin
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- Nút bật tắt mở quán nhanh 1-click -->
                        <form action="${pageContext.request.contextPath}/merchant/profile" method="POST" style="display:inline; margin: 0;">
                            <input type="hidden" name="action" value="toggleStatus" />
                            <button type="submit" class="btn-merchant-status-toggle ${currentRestaurant.status eq 'OPEN' ? 'status-toggle-close' : 'status-toggle-open'}" 
                                    title="${currentRestaurant.status eq 'OPEN' ? 'Bấm để tạm đóng cửa quán' : 'Bấm để mở cửa nhận đơn'}">
                                <i class="fa-solid ${currentRestaurant.status eq 'OPEN' ? 'fa-door-closed' : 'fa-door-open'}"></i>
                                <span>${currentRestaurant.status eq 'OPEN' ? 'Tạm đóng cửa' : 'Mở cửa nhận đơn'}</span>
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Active Tab Determination (via param.activeTab or URI fallback) -->
        <c:set var="curActive" value="${param.activeTab}" />
        <c:if test="${empty curActive}">
            <c:set var="reqUri" value="${pageContext.request.requestURI}" />
            <c:choose>
                <c:when test="${reqUri.endsWith('/merchant/dashboard') or reqUri.contains('/dashboard.jsp')}"><c:set var="curActive" value="dashboard" /></c:when>
                <c:when test="${reqUri.endsWith('/merchant/orders') or reqUri.contains('/orders.jsp')}"><c:set var="curActive" value="orders" /></c:when>
                <c:when test="${reqUri.endsWith('/merchant/foods') or reqUri.contains('/foods.jsp')}"><c:set var="curActive" value="foods" /></c:when>
                <c:when test="${reqUri.endsWith('/merchant/chat') or reqUri.contains('/chat.jsp')}"><c:set var="curActive" value="chat" /></c:when>
                <c:when test="${reqUri.endsWith('/merchant/revenue') or reqUri.contains('/revenue.jsp')}"><c:set var="curActive" value="revenue" /></c:when>
                <c:when test="${reqUri.endsWith('/merchant/profile') or reqUri.contains('/profile.jsp')}"><c:set var="curActive" value="profile" /></c:when>
            </c:choose>
        </c:if>

        <!-- Modern Floating Navigation Tabs Bar (6 Balanced Tabs) -->
        <div class="merchant-tabs-bar">
            <a href="${pageContext.request.contextPath}/merchant/dashboard" class="merchant-tab-btn ${curActive eq 'dashboard' ? 'active' : ''}">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Tổng quan</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/orders" class="merchant-tab-btn ${curActive eq 'orders' ? 'active' : ''}">
                <i class="fa-solid fa-receipt"></i>
                <span>Đơn hàng</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/foods" class="merchant-tab-btn ${curActive eq 'foods' ? 'active' : ''}">
                <i class="fa-solid fa-bowl-food"></i>
                <span>Thực đơn món</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/chat" class="merchant-tab-btn ${curActive eq 'chat' ? 'active' : ''}">
                <i class="fa-solid fa-comments"></i>
                <span>Tin nhắn</span>
                <span id="merchantNavChatBadge" class="badge bg-danger rounded-pill ms-1" style="display:none; font-size: 0.72rem; padding: 2px 6px;"></span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/revenue" class="merchant-tab-btn ${curActive eq 'revenue' ? 'active' : ''}">
                <i class="fa-solid fa-chart-line"></i>
                <span>Doanh thu</span>
            </a>
            <a href="${pageContext.request.contextPath}/merchant/profile" class="merchant-tab-btn ${curActive eq 'profile' ? 'active' : ''}">
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
