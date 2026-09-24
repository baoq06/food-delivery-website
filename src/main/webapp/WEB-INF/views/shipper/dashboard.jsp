<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="${activeTab eq 'history' ? 'Lịch Sử Giao Hàng - Đối Tác Tài Xế' : (activeTab eq 'income' ? 'Thu Nhập Tài Xế - Utee Express' : (activeTab eq 'violations' ? 'Điểm Vi Phạm & Tác Phong - Utee Express' : (activeTab eq 'settings' ? 'Cài Đặt Tài Xế - Utee Express' : (activeTab eq 'help' ? 'Trung Tâm Trợ Giúp Tài Xế - Utee Express' : 'Bảng Điều Khiển Tài Xế - Utee Express'))))}" />
</jsp:include>

<!-- Page Banner -->
<div class="page-banner" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: #fff; padding: 36px 0; margin-bottom: 30px;">
    <div class="container page-banner-inner" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <div class="breadcrumb" style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem; color: #94a3b8; margin-bottom: 8px;">
                <a href="${pageContext.request.contextPath}/home" style="color: #cbd5e1; text-decoration: none;"><i class="fa-solid fa-house"></i> Trang chủ</a>
                <i class="fa-solid fa-chevron-right" style="font-size: 0.75rem;"></i>
                <a href="${pageContext.request.contextPath}/shipper/dashboard" style="color: #cbd5e1; text-decoration: none;">Kênh tài xế</a>
                <i class="fa-solid fa-chevron-right" style="font-size: 0.75rem;"></i>
                <span style="color: #f05454; font-weight: 600;">
                    <c:choose>
                        <c:when test="${activeTab eq 'history'}">Lịch sử chuyến giao</c:when>
                        <c:when test="${activeTab eq 'income'}">Thu nhập tài xế</c:when>
                        <c:when test="${activeTab eq 'violations'}">Điểm vi phạm</c:when>
                        <c:when test="${activeTab eq 'settings'}">Cài đặt</c:when>
                        <c:when test="${activeTab eq 'help'}">Trung tâm trợ giúp</c:when>
                        <c:otherwise>Bảng điều khiển &amp; Nhận đơn</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <h1 class="page-title" style="margin: 0; font-size: 1.85rem; font-weight: 800; color: #fff; letter-spacing: -0.5px;">
                <i class="fa-solid 
                    <c:choose>
                        <c:when test="${activeTab eq 'history'}">fa-clock-rotate-left</c:when>
                        <c:when test="${activeTab eq 'income'}">fa-wallet</c:when>
                        <c:when test="${activeTab eq 'violations'}">fa-triangle-exclamation</c:when>
                        <c:when test="${activeTab eq 'settings'}">fa-gear</c:when>
                        <c:when test="${activeTab eq 'help'}">fa-circle-question</c:when>
                        <c:otherwise>fa-motorcycle</c:otherwise>
                    </c:choose>" style="color: #f05454; margin-right: 10px;"></i>
                <c:choose>
                    <c:when test="${activeTab eq 'history'}">Lịch Sử Chuyến Xe Giao Hàng</c:when>
                    <c:when test="${activeTab eq 'income'}">Ví Thu Nhập &amp; Thù Lao Giao Hàng</c:when>
                    <c:when test="${activeTab eq 'violations'}">Điểm Vi Phạm &amp; Hạnh Kiểm Tác Phong</c:when>
                    <c:when test="${activeTab eq 'settings'}">Cài Đặt Ứng Dụng &amp; Hồ Sơ Tài Xế</c:when>
                    <c:when test="${activeTab eq 'help'}">Trung Tâm Trợ Giúp &amp; Hỗ Trợ Đối Tác</c:when>
                    <c:otherwise>Trung Tâm Điều Phối &amp; Nhận Đơn</c:otherwise>
                </c:choose>
            </h1>
        </div>
        <div style="display: flex; align-items: center; gap: 12px;">
            <span style="padding: 8px 16px; border-radius: 50px; font-size: 0.88rem; font-weight: 700; display: inline-flex; align-items: center; gap: 8px;
                <c:choose>
                    <c:when test="${driver.status eq 'AVAILABLE'}">background: #dcfce7; color: #15803d;</c:when>
                    <c:when test="${driver.status eq 'BUSY'}">background: #fef3c7; color: #b45309;</c:when>
                    <c:otherwise>background: #f1f5f9; color: #64748b;</c:otherwise>
                </c:choose>">
                <span style="width: 10px; height: 10px; border-radius: 50%;
                    <c:choose>
                        <c:when test="${driver.status eq 'AVAILABLE'}">background: #22c55e; box-shadow: 0 0 8px #22c55e;</c:when>
                        <c:when test="${driver.status eq 'BUSY'}">background: #f59e0b; box-shadow: 0 0 8px #f59e0b;</c:when>
                        <c:otherwise>background: #94a3b8;</c:otherwise>
                    </c:choose>"></span>
                <c:choose>
                    <c:when test="${driver.status eq 'AVAILABLE'}">ĐANG TRỰC TUYẾN (BẬT)</c:when>
                    <c:when test="${driver.status eq 'BUSY'}">ĐANG GIAO ĐƠN</c:when>
                    <c:otherwise>NGOẠI TUYẾN (TẮT)</c:otherwise>
                </c:choose>
            </span>
        </div>
    </div>
</div>

<style>
    /* Shipper Dashboard Modern Styles */
    .shipper-layout { display: flex; gap: 28px; flex-wrap: wrap; margin-bottom: 60px; }
    .shipper-sidebar { flex: 0 0 310px; }
    .shipper-content { flex: 1; min-width: 0; }

    .shipper-card {
        background: #ffffff;
        border-radius: 16px;
        border: 1px solid #f1f5f9;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        margin-bottom: 24px;
        overflow: hidden;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    /* Driver Profile Card */
    .driver-hero-box {
        padding: 24px;
        background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%);
        border-bottom: 1px solid #fee2e2;
        text-align: center;
    }
    .driver-avatar-circle {
        width: 76px;
        height: 76px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f05454 0%, #ff7676 100%);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        font-weight: 800;
        margin: 0 auto 12px auto;
        box-shadow: 0 6px 16px rgba(240, 84, 84, 0.25);
        border: 3px solid #fff;
    }
    .driver-name { font-size: 1.2rem; font-weight: 800; color: #1e293b; margin-bottom: 4px; }
    .driver-meta { font-size: 0.88rem; color: #64748b; margin-bottom: 12px; display: flex; align-items: center; justify-content: center; gap: 8px; flex-wrap: wrap; }

    /* Navigation List */
    .shipper-nav { display: flex; flex-direction: column; padding: 12px; }
    .shipper-nav-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 13px 18px;
        border-radius: 12px;
        color: #475569;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.2s ease;
        margin-bottom: 5px;
    }
    .shipper-nav-item:hover {
        background: #f8fafc;
        color: #f05454;
        transform: translateX(4px);
    }
    .shipper-nav-item.active {
        background: #fff5f5;
        color: #f05454;
        border-left: 4px solid #f05454;
        font-weight: 700;
    }
    .shipper-nav-badge {
        padding: 3px 10px;
        border-radius: 50px;
        font-size: 0.75rem;
        background: #fee2e2;
        color: #dc2626;
        font-weight: 700;
    }

    /* Wallet Stats Box */
    .wallet-stat-card {
        padding: 20px;
        border-top: 1px solid #f1f5f9;
        background: #fafbfc;
    }
    .wallet-title {
        font-size: 0.8rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748b;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .wallet-stat-item {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 14px 16px;
        margin-bottom: 10px;
    }
    .wallet-stat-val { font-size: 1.35rem; font-weight: 800; line-height: 1.2; margin-bottom: 2px; }
    .wallet-stat-sub { font-size: 0.82rem; color: #64748b; margin: 0; }

    /* Driver Status Switcher Hero Box */
    .mode-toggle-banner {
        padding: 24px;
        border-radius: 16px;
        margin-bottom: 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 20px;
        box-shadow: 0 4px 14px rgba(0,0,0,0.03);
    }
    .mode-toggle-banner.available {
        background: linear-gradient(135deg, #f0fdf4 0%, #e6f9ed 100%);
        border: 1px solid #bbf7d0;
    }
    .mode-toggle-banner.busy {
        background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%);
        border: 1px solid #fde68a;
    }
    .mode-toggle-banner.offline {
        background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        border: 1px solid #e2e8f0;
    }

    /* Radar Scanning Component */
    .radar-box {
        padding: 48px 24px;
        text-align: center;
        background: linear-gradient(135deg, #f0fdf9 0%, #e6f9f4 100%);
        border: 2px dashed #99f6e4;
        border-radius: 16px;
        position: relative;
        overflow: hidden;
    }
    .radar-pulse-center {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: linear-gradient(135deg, #10ac84 0%, #2ed573 100%);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2rem;
        margin: 0 auto 20px auto;
        box-shadow: 0 0 0 0 rgba(16, 172, 132, 0.4);
        animation: radarWave 2s infinite cubic-bezier(0.4, 0, 0.2, 1);
    }
    @keyframes radarWave {
        0% { box-shadow: 0 0 0 0 rgba(16, 172, 132, 0.6); }
        70% { box-shadow: 0 0 0 35px rgba(16, 172, 132, 0); }
        100% { box-shadow: 0 0 0 0 rgba(16, 172, 132, 0); }
    }

    /* Dispatch New Order Modal / Alert Card */
    .new-order-popup {
        background: #ffffff;
        border: 2px solid #f59e0b;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 10px 30px rgba(245, 158, 11, 0.2);
        animation: popupShake 1.2s infinite alternate;
        margin-bottom: 24px;
    }
    @keyframes popupShake {
        0% { transform: scale(1); box-shadow: 0 6px 20px rgba(245, 158, 11, 0.15); }
        100% { transform: scale(1.015); box-shadow: 0 12px 30px rgba(245, 158, 11, 0.3); }
    }

    /* Trip History Card */
    .trip-card {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 22px;
        margin-bottom: 20px;
        transition: all 0.2s ease;
        box-shadow: 0 2px 8px rgba(0,0,0,0.02);
    }
    .trip-card:hover {
        border-color: #cbd5e1;
        box-shadow: 0 8px 24px rgba(0,0,0,0.06);
        transform: translateY(-2px);
    }
    .trip-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #f1f5f9;
        padding-bottom: 14px;
        margin-bottom: 16px;
        flex-wrap: wrap;
        gap: 10px;
    }
    .trip-id { font-size: 1.1rem; font-weight: 800; color: #1e293b; }
    .trip-time { font-size: 0.85rem; color: #64748b; margin-left: 8px; }
    .trip-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
    .trip-field { font-size: 0.92rem; color: #334155; margin-bottom: 8px; }
    .trip-field strong { color: #0f172a; }
    .trip-review-box {
        background: #f8fafc;
        border-radius: 12px;
        padding: 14px 18px;
        margin-top: 14px;
        border-left: 4px solid #f59e0b;
    }
    .star-rating-display { color: #f59e0b; font-size: 1rem; margin-right: 6px; }

    /* Filter Pills */
    .filter-pills { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 20px; }
    .filter-pill-btn {
        padding: 8px 18px;
        border-radius: 50px;
        font-size: 0.88rem;
        font-weight: 600;
        text-decoration: none;
        border: 1px solid #e2e8f0;
        background: #fff;
        color: #475569;
        transition: all 0.2s ease;
    }
    .filter-pill-btn:hover { background: #f8fafc; color: #f05454; }
    .filter-pill-btn.active {
        background: #f05454;
        color: #fff;
        border-color: #f05454;
        box-shadow: 0 4px 12px rgba(240, 84, 84, 0.25);
    }

    /* Common Card Headers & Utilities */
    .sec-card-header {
        padding: 20px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
    }
    .sec-card-title { font-size: 1.25rem; font-weight: 800; color: #1e293b; margin: 0; }
    .sec-card-body { padding: 24px; }
    
    /* Stat Grid */
    .income-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 24px; }
    .income-stat-card {
        background: #fff;
        border: 1px solid #e2e8f0;
        border-radius: 14px;
        padding: 20px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .income-stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(0,0,0,0.04);
    }
    
    /* Form controls in settings */
    .form-switch-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px 0;
        border-bottom: 1px solid #f1f5f9;
    }
    .form-switch-row:last-child { border-bottom: none; }
</style>

<div class="container">
    <!-- User Notice Banners -->
    <c:if test="${param.warning eq 'shipper_mode_active'}">
        <div class="alert alert-warning" style="border-radius: 14px; margin-bottom: 24px; padding: 18px 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; border-left: 5px solid #f59e0b; background: #fffbeb;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.5rem; color: #f59e0b;"></i>
                <div>
                    <h5 style="margin: 0; font-weight: 700; color: #92400e;">Chế độ Shipper đang BẬT</h5>
                    <p style="margin: 3px 0 0 0; font-size: 0.9rem; color: #b45309;">
                        Giỏ hàng và tính năng đặt món ăn tạm thời khóa để bạn tập trung làm việc. Nếu muốn tạm dừng nhận đơn, chỉ cần nhấn nút <strong>"TẮT NHẬN ĐƠN"</strong> bên dưới!
                    </p>
                </div>
            </div>
            <button type="button" class="btn-close" onclick="this.parentElement.style.display='none';" style="background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #92400e;">&times;</button>
        </div>
    </c:if>

    <c:if test="${param.error eq 'busy_cannot_toggle'}">
        <div class="alert alert-danger" style="border-radius: 14px; margin-bottom: 24px; padding: 18px 24px; display: flex; align-items: center; gap: 12px; border-left: 5px solid #ef4444; background: #fef2f2;">
            <i class="fa-solid fa-circle-exclamation" style="font-size: 1.5rem; color: #ef4444;"></i>
            <div>
                <h5 style="margin: 0; font-weight: 700; color: #991b1b;">Không thể tắt chế độ nhận đơn!</h5>
                <p style="margin: 3px 0 0 0; font-size: 0.9rem; color: #b91c1c;">
                    Bạn đang trong quá trình thực hiện cuốc xe giao hàng. Vui lòng hoàn thành giao đơn hoặc báo hủy đơn trước khi tắt chế độ shipper.
                </p>
            </div>
        </div>
    </c:if>

    <c:if test="${param.error eq 'accept_failed'}">
        <div class="alert alert-danger" style="border-radius: 14px; margin-bottom: 24px; padding: 18px 24px; display: flex; align-items: center; gap: 12px; border-left: 5px solid #ef4444; background: #fef2f2;">
            <i class="fa-solid fa-circle-exclamation" style="font-size: 1.5rem; color: #ef4444;"></i>
            <div>
                <h5 style="margin: 0; font-weight: 700; color: #991b1b;">Nhận cuốc xe không thành công</h5>
                <p style="margin: 3px 0 0 0; font-size: 0.9rem; color: #b91c1c;">
                    Đơn hàng này có thể đã được tài xế khác tiếp nhận trước hoặc hệ thống đã tự động gán cho đối tác gần hơn.
                </p>
            </div>
        </div>
    </c:if>

    <div class="shipper-layout">
        <!-- ================================================================= -->
        <!-- LEFT SIDEBAR: DRIVER PROFILE & FUNCTIONAL NAVIGATION -->
        <!-- ================================================================= -->
        <div class="shipper-sidebar">
            <div class="shipper-card">
                <!-- Driver Info Box -->
                <div class="driver-hero-box">
                    <div class="driver-avatar-circle">
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser.fullName}">
                                ${sessionScope.currentUser.fullName.substring(0, 1).toUpperCase()}
                            </c:when>
                            <c:otherwise>S</c:otherwise>
                        </c:choose>
                    </div>
                    <h3 class="driver-name">${sessionScope.currentUser.fullName}</h3>
                    <div class="driver-meta">
                        <span><i class="fa-solid fa-phone text-muted"></i> ${sessionScope.currentUser.phone}</span>
                        <span>•</span>
                        <span><i class="fa-solid fa-id-card text-muted"></i> ID: #${sessionScope.currentUser.id}</span>
                    </div>
                    <div style="background: #fff; border: 1px solid #fee2e2; border-radius: 10px; padding: 8px 12px; font-size: 0.85rem; color: #475569; display: flex; justify-content: space-around; margin-bottom: 6px;">
                        <span><i class="fa-solid fa-motorcycle text-primary"></i> ${not empty driver.licensePlate ? driver.licensePlate : '59-X3 999.99'}</span>
                        <span>|</span>
                        <span><i class="fa-solid fa-shield-halved text-success"></i> Đã xác thực</span>
                    </div>
                    <div style="background: #fff8e1; border: 1px solid #ffe082; border-radius: 10px; padding: 8px 12px; font-size: 0.85rem; color: #b45309; display: flex; align-items: center; justify-content: center; gap: 6px;">
                        <i class="fa-solid fa-star text-warning"></i>
                        <span>Đánh giá: <strong>${driverRatingStats != null ? driverRatingStats['avgRating'] : 5.0}</strong>/5.0 <small class="text-muted">(${driverRatingStats != null ? driverRatingStats['reviewCount'] : 0} lượt)</small></span>
                    </div>
                </div>

                <!-- Navigation Tabs (Danh Sách Chức Năng) -->
                <div class="shipper-nav">
                    <a href="${pageContext.request.contextPath}/shipper/dashboard" class="shipper-nav-item ${activeTab eq 'dispatch' or empty activeTab ? 'active' : ''}">
                        <span><i class="fa-solid fa-gauge-high me-2 text-primary" style="width: 22px;"></i> Nhận đơn &amp; Điều phối</span>
                        <c:if test="${not empty activeOrders}">
                            <span class="shipper-nav-badge" style="background: #2563eb; color: #fff;">${activeOrders.size()} đơn</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=income" class="shipper-nav-item ${activeTab eq 'income' ? 'active' : ''}">
                        <span><i class="fa-solid fa-wallet me-2 text-success" style="width: 22px;"></i> Thu nhập</span>
                        <c:if test="${not empty wallet and wallet.todayEarnings > 0}">
                            <span class="shipper-nav-badge" style="background: #dcfce7; color: #15803d;"><fmt:formatNumber value="${wallet.todayEarnings}" pattern="#,###" />đ</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history" class="shipper-nav-item ${activeTab eq 'history' ? 'active' : ''}">
                        <span><i class="fa-solid fa-clock-rotate-left me-2 text-info" style="width: 22px;"></i> Lịch sử chuyến giao</span>
                        <c:if test="${totalDeliveryCount > 0}">
                            <span class="shipper-nav-badge" style="background: #e2e8f0; color: #334155;">${totalDeliveryCount}</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=violations" class="shipper-nav-item ${activeTab eq 'violations' ? 'active' : ''}">
                        <span><i class="fa-solid fa-triangle-exclamation me-2 text-warning" style="width: 22px;"></i> Điểm vi phạm</span>
                        <span class="shipper-nav-badge" style="background: #ecfdf5; color: #059669;">100đ</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/notifications" class="shipper-nav-item">
                        <span><i class="fa-solid fa-bell me-2 text-warning" style="width: 22px;"></i> Thông báo của tôi</span>
                        <span class="shipper-nav-badge" id="shipperNavNotifBadge" style="display:none; background: #fee2e2; color: #dc2626;">0</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=settings" class="shipper-nav-item ${activeTab eq 'settings' ? 'active' : ''}">
                        <span><i class="fa-solid fa-gear me-2 text-secondary" style="width: 22px;"></i> Cài đặt</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=help" class="shipper-nav-item ${activeTab eq 'help' ? 'active' : ''}">
                        <span><i class="fa-solid fa-circle-question me-2 text-primary" style="width: 22px;"></i> Trung tâm trợ giúp</span>
                    </a>
                </div>

                <script>
                    document.addEventListener("DOMContentLoaded", function() {
                        function updateShipperNotifCount() {
                            fetch('${pageContext.request.contextPath}/api/notifications/unread-count')
                                .then(function(res) { return res.json(); })
                                .then(function(data) {
                                    var count = data.unreadCount || 0;
                                    var badge = document.getElementById('shipperNavNotifBadge');
                                    if (badge) {
                                        badge.innerText = count > 99 ? '99+' : count;
                                        badge.style.display = count > 0 ? 'inline-block' : 'none';
                                    }
                                })
                                .catch(function(err) {});
                        }
                        updateShipperNotifCount();
                        setInterval(updateShipperNotifCount, 5000);
                    });
                </script>

                <!-- Driver Wallet Box Quick Stats -->
                <c:if test="${not empty wallet}">
                    <div class="wallet-stat-card">
                        <div class="wallet-title">
                            <i class="fa-solid fa-wallet text-success"></i> Ví Thu Nhập Nhanh
                        </div>

                        <!-- Today Stats -->
                        <div class="wallet-stat-item" style="border-left: 4px solid #10ac84;">
                            <div class="wallet-stat-val text-success">
                                <fmt:formatNumber value="${wallet.todayEarnings}" pattern="#,###" /> đ
                            </div>
                            <p class="wallet-stat-sub">Hôm nay: <strong>${wallet.todayTrips} cuốc xe</strong> hoàn tất</p>
                        </div>

                        <!-- Total Stats -->
                        <div class="wallet-stat-item" style="border-left: 4px solid #f05454;">
                            <div class="wallet-stat-val" style="color: #f05454;">
                                <fmt:formatNumber value="${wallet.totalEarnings}" pattern="#,###" /> đ
                            </div>
                            <p class="wallet-stat-sub">Tổng tích lũy: <strong>${wallet.totalTrips} chuyến giao</strong></p>
                        </div>

                        <p style="font-size: 0.78rem; color: #94a3b8; margin: 8px 0 0 0; text-align: center;">
                            *Thù lao cố định 15.000 đ/cuốc giao thành công
                        </p>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- ================================================================= -->
        <!-- RIGHT CONTENT AREA -->
        <!-- ================================================================= -->
        <div class="shipper-content">
            <!-- 1. DRIVER MODE TOGGLE BANNER -->
            <div class="mode-toggle-banner ${driver.status eq 'AVAILABLE' ? 'available' : (driver.status eq 'BUSY' ? 'busy' : 'offline')}">
                <div style="display: flex; align-items: center; gap: 16px;">
                    <div style="width: 54px; height: 54px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.6rem;
                        <c:choose>
                            <c:when test="${driver.status eq 'AVAILABLE'}">background: #dcfce7; color: #16a34a;</c:when>
                            <c:when test="${driver.status eq 'BUSY'}">background: #fef3c7; color: #d97706;</c:when>
                            <c:otherwise>background: #e2e8f0; color: #64748b;</c:otherwise>
                        </c:choose>">
                        <i class="fa-solid ${driver.status eq 'AVAILABLE' ? 'fa-satellite-dish' : (driver.status eq 'BUSY' ? 'fa-route' : 'fa-power-off')}"></i>
                    </div>
                    <div>
                        <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;
                            <c:choose>
                                <c:when test="${driver.status eq 'AVAILABLE'}">color: #15803d;</c:when>
                                <c:when test="${driver.status eq 'BUSY'}">color: #b45309;</c:when>
                                <c:otherwise>color: #64748b;</c:otherwise>
                            </c:choose>">
                            Trạng thái tiếp nhận đơn hàng
                        </div>
                        <h3 style="margin: 2px 0 4px 0; font-weight: 800; font-size: 1.35rem; color: #0f172a;">
                            <c:choose>
                                <c:when test="${driver.status eq 'AVAILABLE'}">ĐANG BẬT NHẬN ĐƠN (TRỰC TUYẾN)</c:when>
                                <c:when test="${driver.status eq 'BUSY'}">ĐANG VẬN CHUYỂN ĐƠN HÀNG</c:when>
                                <c:otherwise>ĐANG TẮT NHẬN ĐƠN (NGOẠI TUYẾN)</c:otherwise>
                            </c:choose>
                        </h3>
                        <p style="margin: 0; font-size: 0.9rem; color: #475569; max-width: 580px;">
                            <c:choose>
                                <c:when test="${driver.status eq 'AVAILABLE'}">
                                    Hệ thống đang quét đơn quanh khu vực. Giỏ hàng và tính năng đặt món cá nhân được khóa. Bạn chỉ xem được lịch sử các đơn hàng bạn giao.
                                </c:when>
                                <c:when test="${driver.status eq 'BUSY'}">
                                    Bạn đang giao đơn hàng. Vui lòng hoàn thành chuyến đi và cập nhật lộ trình trước khi đổi trạng thái.
                                </c:when>
                                <c:otherwise>
                                    Bạn đang ngoại tuyến nhận đơn. Bật nhận đơn để bắt đầu nhận các cuốc xe giao hàng mới nhất quanh khu vực!
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- Toggle Switch Action Button -->
                <div>
                    <c:choose>
                        <c:when test="${driver.status eq 'BUSY'}">
                            <button type="button" class="btn btn-secondary" disabled style="border-radius: 50px; font-weight: 700; padding: 12px 24px; cursor: not-allowed; opacity: 0.7;">
                                <i class="fa-solid fa-lock me-1"></i> Đang bận giao đơn
                            </button>
                        </c:when>
                        <c:when test="${driver.status eq 'AVAILABLE'}">
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin: 0;">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn btn-danger" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; box-shadow: 0 4px 14px rgba(239, 68, 68, 0.3); display: flex; align-items: center; gap: 8px;">
                                    <i class="fa-solid fa-power-off"></i> TẮT NHẬN ĐƠN
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin: 0;">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.3); display: flex; align-items: center; gap: 8px;">
                                    <i class="fa-solid fa-bolt"></i> BẬT MÁY NHẬN ĐƠN NGAY
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- 2. SHIPPER GPS LOCATION WIDGET -->
            <div class="shipper-card" style="padding: 20px 24px; margin-bottom: 24px; border: 1px solid #e0e7ff; background: linear-gradient(135deg, #f8fafc 0%, #eff6ff 100%);">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 14px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 44px; height: 44px; border-radius: 12px; background: #3b82f6; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);">
                            <i class="fa-solid fa-location-crosshairs"></i>
                        </div>
                        <div>
                            <div style="font-size: 0.8rem; font-weight: 700; color: #3b82f6; text-transform: uppercase; letter-spacing: 0.5px;">Định Vị Tọa Độ &amp; Thuật Toán Điều Phối</div>
                            <h4 style="margin: 2px 0 0 0; font-size: 1.1rem; font-weight: 800; color: #1e293b;">
                                Vị Trí Hiện Tại Của Bạn:
                                <span id="currentLocDisplay" style="color: #2563eb; font-weight: 700;">
                                    ${not empty driver.currentAddress ? driver.currentAddress : 'Số 1 Võ Văn Ngân, Linh Chiểu, TP. Thủ Đức'}
                                </span>
                            </h4>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <button type="button" id="btnGetRealGps" class="btn btn-primary btn-sm" style="border-radius: 50px; font-weight: 700; padding: 8px 16px; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 8px rgba(37, 99, 235, 0.25);">
                            <i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật
                        </button>
                    </div>
                </div>

                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; padding-top: 12px; border-top: 1px dashed #cbd5e1; font-size: 0.88rem; color: #475569;">
                    <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                        <span><i class="fa-solid fa-compass text-primary"></i> Tọa độ: <code id="gpsCoordsText" style="background: #e2e8f0; padding: 3px 8px; border-radius: 6px; color: #0f172a; font-weight: 600;">${not empty driver.currentLatitude ? driver.currentLatitude : '10.850721'}, ${not empty driver.currentLongitude ? driver.currentLongitude : '106.771960'}</code></span>
                        <span>•</span>
                        <span><i class="fa-solid fa-clock-rotate-left text-muted"></i> Cập nhật: <small id="gpsUpdatedTime" class="text-muted"><fmt:formatDate value="${driver.lastLocationUpdated}" pattern="HH:mm dd/MM" /></small></span>
                    </div>

                    <!-- Giả lập vị trí nhanh quanh TP. Thủ Đức để test/demo nhiều tài xế -->
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <label for="mockLocationSelect" style="font-weight: 600; font-size: 0.84rem; color: #334155; margin: 0;">Mô phỏng vị trí:</label>
                        <select id="mockLocationSelect" class="form-select form-select-sm" style="border-radius: 8px; font-size: 0.84rem; padding: 4px 10px; max-width: 240px;">
                            <option value="10.850721,106.771960|Đại học Sư phạm Kỹ thuật TP.HCM (HCMUTE), TP. Thủ Đức" selected>HCMUTE (Võ Văn Ngân)</option>
                            <option value="10.854882,106.758476|Chợ Thủ Đức, Kha Vạn Cân, TP. Thủ Đức">Chợ Thủ Đức (Kha Vạn Cân)</option>
                            <option value="10.847153,106.775824|Vincom Plaza Lê Văn Việt, Hiệp Phú, TP. Thủ Đức">Vincom Lê Văn Việt</option>
                            <option value="10.875225,106.800725|Ký túc xá Khu A ĐHQG-HCM, Linh Trung, TP. Thủ Đức">KTX Khu A ĐHQG-HCM</option>
                            <option value="10.827618,106.721448|Gigamall Phạm Văn Đồng, Hiệp Bình Chánh, TP. Thủ Đức">Gigamall Phạm Văn Đồng</option>
                            <option value="10.793836,106.721863|Landmark 81, Vinhomes Central Park, Bình Thạnh">Landmark 81, Bình Thạnh</option>
                            <option value="10.772097,106.698317|Chợ Bến Thành, Quận 1, TP.HCM">Chợ Bến Thành, Q1</option>
                        </select>
                        <button type="button" id="btnApplyMockLocation" class="btn btn-outline-secondary btn-sm" style="border-radius: 8px; font-weight: 600; padding: 4px 10px;">
                            Đặt vị trí
                        </button>
                    </div>
                </div>
            </div>

            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    function sendLocationUpdate(lat, lng, address) {
                        const formData = new URLSearchParams();
                        formData.append('lat', lat);
                        formData.append('lng', lng);
                        formData.append('latitude', lat);
                        formData.append('longitude', lng);
                        if (address) formData.append('address', address);

                        const btnMock = document.getElementById('btnApplyMockLocation');
                        const originalBtnText = btnMock ? btnMock.innerHTML : '';
                        if (btnMock) {
                            btnMock.disabled = true;
                            btnMock.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                        }

                        fetch('${pageContext.request.contextPath}/shipper/api/location', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: formData.toString()
                        })
                        .then(r => r.json())
                        .then(data => {
                            if (btnMock) {
                                btnMock.disabled = false;
                                btnMock.innerHTML = originalBtnText;
                            }
                            if (data.status === 'success') {
                                document.getElementById('currentLocDisplay').innerText = data.address || address;
                                document.getElementById('gpsCoordsText').innerText = parseFloat(lat).toFixed(6) + ', ' + parseFloat(lng).toFixed(6);
                                document.getElementById('gpsUpdatedTime').innerText = 'Vừa xong';
                                alert('✅ Đã đặt vị trí thành công:\n' + (data.address || address) + '\n\nHệ thống sẽ dùng tọa độ này để tính khoảng cách và gán đơn gần bạn nhất!');
                            } else {
                                alert('Không thể cập nhật vị trí: ' + (data.message || 'Lỗi'));
                            }
                        })
                        .catch(err => {
                            if (btnMock) {
                                btnMock.disabled = false;
                                btnMock.innerHTML = originalBtnText;
                            }
                            console.error(err);
                            alert('Lỗi kết nối cập nhật tọa độ!');
                        });
                    }

                    // Nút GPS Thật
                    const btnGps = document.getElementById('btnGetRealGps');
                    if (btnGps) {
                        btnGps.addEventListener('click', function() {
                            if (!navigator.geolocation) {
                                alert('Trình duyệt của bạn không hỗ trợ Geolocation API.');
                                return;
                            }
                            btnGps.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang dò GPS...';
                            btnGps.disabled = true;
                            navigator.geolocation.getCurrentPosition(
                                function(pos) {
                                    btnGps.innerHTML = '<i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật';
                                    btnGps.disabled = false;
                                    const lat = pos.coords.latitude;
                                    const lng = pos.coords.longitude;
                                    sendLocationUpdate(lat, lng, 'Vị trí GPS thiết bị (' + lat.toFixed(4) + ', ' + lng.toFixed(4) + ')');
                                },
                                function(err) {
                                    btnGps.innerHTML = '<i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật';
                                    btnGps.disabled = false;
                                    alert('Không lấy được GPS (' + err.message + '). Bạn có thể dùng bộ chọn mô phỏng bên cạnh!');
                                },
                                { enableHighAccuracy: true, timeout: 8000 }
                            );
                        });
                    }

                    // Nút Mock Location
                    const btnMock = document.getElementById('btnApplyMockLocation');
                    const selMock = document.getElementById('mockLocationSelect');
                    if (btnMock && selMock) {
                        btnMock.addEventListener('click', function() {
                            const val = selMock.value;
                            const parts = val.split('|');
                            const coords = parts[0].split(',');
                            const lat = parseFloat(coords[0]);
                            const lng = parseFloat(coords[1]);
                            const addr = parts[1];
                            sendLocationUpdate(lat, lng, addr);
                        });
                    }
                });
            </script>

            <!-- ============================================================= -->
            <!-- TAB 1: NHẬN ĐƠN & ĐIỀU PHỐI (dispatch) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'dispatch' or empty activeTab}">
                <!-- DANH SÁCH ĐƠN HÀNG QUÁN VỪA CHỈ ĐỊNH (CẦN SHIPPER XÁC NHẬN NHẬN CUỐC) -->
                <c:if test="${not empty pendingAssignedOrders}">
                    <div class="mb-4">
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge rounded-pill bg-warning text-dark px-3 py-2 fw-bold" style="font-size: 0.95rem;">
                                    <i class="fa-solid fa-bell fa-shake me-1"></i> ${pendingAssignedOrders.size()} đơn quán đã gán đang chờ bạn nhận
                                </span>
                                <small class="text-muted">(Xếp theo thứ tự gán trước đến sau - tối đa 3 đơn)</small>
                            </div>
                        </div>

                        <div class="d-flex flex-column gap-3">
                            <c:forEach items="${pendingAssignedOrders}" var="pOrder" varStatus="loop">
                                <div class="shipper-card" style="border: 2px solid ${loop.first ? '#f59e0b' : '#cbd5e1'}; background: ${loop.first ? '#fffdf5' : '#ffffff'}; box-shadow: 0 6px 18px rgba(0,0,0,0.06); border-radius: 14px; overflow: hidden;">
                                    <div style="background: ${loop.first ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : '#475569'}; color: #fff; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                        <div class="d-flex align-items-center gap-2">
                                            <div style="width: 34px; height: 34px; border-radius: 50%; background: rgba(255,255,255,0.25); display: flex; align-items: center; justify-content: center; font-size: 1rem; font-weight: 800;">
                                                #${loop.index + 1}
                                            </div>
                                            <div>
                                                <h4 style="margin: 0; font-weight: 800; font-size: 1.05rem; color: #fff;">
                                                    <c:choose>
                                                        <c:when test="${loop.first}">
                                                            QUÁN CHỈ ĐỊNH ĐƠN #FZ-${pOrder.id} (Ưu tiên - Đơn đến trước)
                                                        </c:when>
                                                        <c:otherwise>
                                                            QUÁN CHỈ ĐỊNH ĐƠN #FZ-${pOrder.id}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h4>
                                                <p style="margin: 2px 0 0 0; font-size: 0.8rem; opacity: 0.95;">
                                                    Thời gian tạo: <fmt:formatDate value="${pOrder.createdAt}" pattern="HH:mm dd/MM/yyyy" />
                                                </p>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <span class="badge bg-white text-primary fw-bold px-3 py-2 rounded-pill shadow-sm" style="font-size: 0.82rem;">
                                                <i class="fa-solid fa-route me-1"></i> Cự ly: ${pOrder.distanceKm != null ? pOrder.distanceKm : 2.0} km
                                            </span>
                                            <span class="badge ${loop.first ? 'bg-white text-warning' : 'bg-light text-dark'} fw-bold px-3 py-2 rounded-pill shadow-sm" style="font-size: 0.82rem;">
                                                ⏳ Chờ bạn phản hồi
                                            </span>
                                        </div>
                                    </div>
                                    <div style="padding: 20px;">
                                        <div class="row g-3 mb-3">
                                            <div class="col-md-3 col-6">
                                                <span class="text-muted small">Mã đơn:</span>
                                                <div class="fw-bold fs-6 text-dark">#FZ-${pOrder.id}</div>
                                            </div>
                                            <div class="col-md-3 col-6">
                                                <span class="text-muted small">Khách nhận:</span>
                                                <div class="fw-bold fs-6 text-dark">${pOrder.customerName} (${pOrder.phone})</div>
                                            </div>
                                            <div class="col-md-3 col-6">
                                                <span class="text-muted small">Thu hộ COD:</span>
                                                <div class="fw-bold fs-6 text-danger"><fmt:formatNumber value="${pOrder.totalAmount}" pattern="#,###" /> đ</div>
                                            </div>
                                            <div class="col-md-3 col-6">
                                                <span class="text-muted small">Cước ship bạn nhận:</span>
                                                <div class="fw-bold fs-6 text-success">+<fmt:formatNumber value="${pOrder.shippingFee != null ? pOrder.shippingFee : 15000}" pattern="#,###" /> đ</div>
                                            </div>
                                            <div class="col-12">
                                                <span class="text-muted small">Địa chỉ giao hàng:</span>
                                                <div class="fw-semibold text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> ${pOrder.address}</div>
                                            </div>
                                            <c:if test="${not empty pOrder.note}">
                                                <div class="col-12">
                                                    <span class="text-muted small">Ghi chú của khách:</span>
                                                    <div class="small text-muted italic bg-light p-2 rounded">${pOrder.note}</div>
                                                </div>
                                            </c:if>
                                        </div>
                                        <div class="d-flex gap-3 flex-wrap">
                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="flex: 2; min-width: 200px;">
                                                <input type="hidden" name="action" value="acceptOrder">
                                                <input type="hidden" name="orderId" value="${pOrder.id}">
                                                <button type="submit" class="btn btn-success w-100 py-2 fw-bold" style="border-radius: 50px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 12px rgba(16, 172, 132, 0.25);">
                                                    <i class="fa-solid fa-check-double me-2"></i> NHẬN ĐƠN #FZ-${pOrder.id}
                                                </button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="flex: 1; min-width: 130px;" onsubmit="return confirm('Bạn có chắc muốn từ chối cuốc xe #FZ-${pOrder.id}? Quán sẽ gán tài xế khác.');">
                                                <input type="hidden" name="action" value="declineOrder">
                                                <input type="hidden" name="orderId" value="${pOrder.id}">
                                                <button type="submit" class="btn btn-outline-danger w-100 py-2 fw-semibold" style="border-radius: 50px;">
                                                    <i class="fa-solid fa-xmark me-1"></i> Từ chối
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty activeOrders}">
                        <!-- DANH SÁCH TẤT CẢ CÁC ĐƠN HÀNG ĐANG VẬN CHUYỂN (GIAO GHÉP ĐƠN) -->
                        <div class="mb-4">
                            <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge rounded-pill bg-primary px-3 py-2 fw-bold" style="font-size: 0.95rem;">
                                        <i class="fa-solid fa-motorcycle me-1"></i> ${activeOrders.size()} đơn hàng đang vận chuyển
                                    </span>
                                    <c:if test="${activeOrders.size() > 1}">
                                        <small class="text-muted fw-semibold">(Giao ghép đơn - Bấm các bước cho từng đơn tùy theo lộ trình di chuyển)</small>
                                    </c:if>
                                </div>
                                <c:if test="${activeOrders.size() > 1}">
                                    <span class="badge bg-light text-dark border px-3 py-2 rounded-pill">
                                        <i class="fa-solid fa-route text-primary me-1"></i> Tối ưu tuyến đường giao ghép
                                    </span>
                                </c:if>
                            </div>

                            <div class="d-flex flex-column gap-4">
                                <c:forEach items="${activeOrders}" var="activeOrder" varStatus="actLoop">
                                    <!-- CHI TIẾT TỪNG ĐƠN HÀNG ĐANG GIAO & VÒNG ĐỜI -->
                                    <div class="shipper-card" style="border: 2px solid ${activeOrder.shipperDelivered ? '#10ac84' : (!activeOrder.shipperPickedUp ? '#f59e0b' : '#3b82f6')}; box-shadow: 0 8px 24px rgba(0,0,0,0.06); border-radius: 16px; overflow: hidden;">
                                        <div style="background: ${activeOrder.shipperDelivered ? 'linear-gradient(135deg, #059669 0%, #10ac84 100%)' : (!activeOrder.shipperPickedUp ? 'linear-gradient(135deg, #d97706 0%, #f59e0b 100%)' : 'linear-gradient(135deg, #1e40af 0%, #3b82f6 100%)')}; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                            <div class="d-flex align-items-center gap-3">
                                                <div style="width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.25); display: flex; align-items: center; justify-content: center; font-size: 1.05rem; font-weight: 800;">
                                                    #${actLoop.index + 1}
                                                </div>
                                                <div>
                                                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.9;">
                                                        <c:choose>
                                                            <c:when test="${activeOrders.size() > 1}">Chuyến xe ghép #${actLoop.index + 1}</c:when>
                                                            <c:otherwise>Đơn hàng đang thực hiện</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <h3 style="margin: 2px 0 0 0; font-size: 1.35rem; font-weight: 800; color: #fff;">
                                                        <i class="fa-solid fa-box-open me-2"></i> Mã đơn: #FZ-${activeOrder.id}
                                                    </h3>
                                                </div>
                                            </div>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${activeOrder.shipperDelivered}">
                                                        <span style="background: rgba(255,255,255,0.25); backdrop-filter: blur(4px); padding: 6px 16px; border-radius: 50px; font-weight: 700; font-size: 0.85rem;">
                                                            <i class="fa-solid fa-circle-check me-1"></i> ĐÃ HOÀN TẤT GIAO HÀNG
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${not activeOrder.shipperPickedUp}">
                                                        <span style="background: rgba(255,255,255,0.25); backdrop-filter: blur(4px); padding: 6px 16px; border-radius: 50px; font-weight: 700; font-size: 0.85rem;">
                                                            <i class="fa-solid fa-store me-1"></i> BƯỚC 1: ĐẾN QUÁN LẤY MÓN
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="background: rgba(255,255,255,0.25); backdrop-filter: blur(4px); padding: 6px 16px; border-radius: 50px; font-weight: 700; font-size: 0.85rem;">
                                                            <i class="fa-solid fa-motorcycle me-1"></i> BƯỚC 2: ĐANG GIAO ĐẾN KHÁCH
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <div style="display: flex; flex-wrap: wrap;">
                                            <!-- Left Column: Order details & Action Buttons -->
                                            <div style="flex: 1.2; min-width: 300px; padding: 24px;">
                                                <div style="background: #f8fafc; border-radius: 12px; padding: 16px; margin-bottom: 20px; border: 1px solid #e2e8f0;">
                                                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;">
                                                        <span style="font-weight: 700; color: #1e293b; font-size: 1.05rem;">
                                                            <i class="fa-solid fa-user text-primary me-2"></i> ${activeOrder.customerName}
                                                        </span>
                                                        <a href="tel:${activeOrder.phone}" class="btn btn-outline btn-sm" style="border-radius: 50px; font-weight: 700; color: #10ac84; border-color: #10ac84;">
                                                            <i class="fa-solid fa-phone me-1"></i> Gọi khách: ${activeOrder.phone}
                                                        </a>
                                                    </div>
                                                    <div style="font-size: 0.95rem; color: #334155; margin-bottom: 8px;">
                                                        <i class="fa-solid fa-location-dot text-danger me-2"></i> <strong>Địa chỉ giao:</strong> ${activeOrder.address}
                                                    </div>
                                                    <div style="font-size: 0.9rem; color: #2563eb; margin-bottom: 8px;">
                                                        <i class="fa-solid fa-road me-2"></i> <strong>Cự ly ước tính:</strong> ${activeOrder.distanceKm != null ? activeOrder.distanceKm : 2.0} km
                                                    </div>
                                                    <c:if test="${not empty activeOrder.note}">
                                                        <div style="font-size: 0.88rem; color: #64748b; background: #fff; padding: 8px 12px; border-radius: 8px; border: 1px dashed #cbd5e1;">
                                                            <i class="fa-solid fa-note-sticky text-warning me-1"></i> <strong>Ghi chú:</strong> ${activeOrder.note}
                                                        </div>
                                                    </c:if>
                                                </div>

                                                <!-- Payment & COD Summary -->
                                                <div style="display: flex; justify-content: space-between; align-items: center; background: #fff5f5; border: 1px solid #fee2e2; border-radius: 12px; padding: 14px 20px; margin-bottom: 24px;">
                                                    <div>
                                                        <span style="font-size: 0.85rem; color: #64748b;">Phương thức: <strong>${activeOrder.paymentMethod}</strong></span>
                                                        <div style="font-size: 1.15rem; font-weight: 800; color: #1e293b;">Tiền thu hộ Khách (COD):</div>
                                                    </div>
                                                    <div style="font-size: 1.6rem; font-weight: 900; color: #dc2626;">
                                                        <fmt:formatNumber value="${activeOrder.totalAmount}" pattern="#,###" /> đ
                                                    </div>
                                                </div>

                                                <!-- Lifecycle Action Buttons theo luồng chuẩn: BƯỚC 1 (LẤY MÓN) -> BƯỚC 2 (GIAO HÀNG HOÀN TẤT) -->
                                                <div style="border-top: 1px dashed #e2e8f0; padding-top: 20px;">
                                                    <div style="font-size: 0.9rem; font-weight: 700; color: #475569; margin-bottom: 12px;">
                                                        Thao tác đơn hàng #FZ-${activeOrder.id}:
                                                    </div>
                                                    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                                                        <c:choose>
                                                            <c:when test="${activeOrder.shipperDelivered}">
                                                                <div class="alert alert-success d-flex align-items-center gap-2 mb-0 py-2 px-3 w-100" style="border-radius: 50px;">
                                                                    <i class="fa-solid fa-circle-check text-success"></i>
                                                                    <span class="fw-bold">Bạn đã giao hoàn tất đơn hàng #FZ-${activeOrder.id}! Doanh thu đã được ghi nhận vào ví.</span>
                                                                </div>
                                                            </c:when>

                                                            <%-- BƯỚC 1: NẾU CHƯA LẤY MÓN TỪ QUÁN -> NÚT XÁC NHẬN ĐÃ LẤY MÓN --%>
                                                            <c:when test="${not activeOrder.shipperPickedUp}">
                                                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin: 0; flex: 1.5; min-width: 240px;">
                                                                    <input type="hidden" name="action" value="confirmPickedUp">
                                                                    <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                    <button type="submit" class="btn btn-warning w-100" style="border-radius: 50px; font-weight: 800; padding: 12px 24px; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #fff; border: none; box-shadow: 0 4px 14px rgba(245, 158, 11, 0.35);" onclick="return confirm('Xác nhận bạn đã đến quán và nhận đủ món ăn cho đơn #FZ-${activeOrder.id}?');">
                                                                        <i class="fa-solid fa-utensils me-2"></i> 1. XÁC NHẬN ĐÃ LẤY MÓN TỪ QUÁN
                                                                    </button>
                                                                </form>
                                                            </c:when>

                                                            <%-- BƯỚC 2: ĐÃ LẤY MÓN TỪ QUÁN -> NÚT XÁC NHẬN ĐÃ GIAO CHO KHÁCH (HOÀN TẤT NGAY) --%>
                                                            <c:otherwise>
                                                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin: 0; flex: 1.5; min-width: 240px;">
                                                                    <input type="hidden" name="action" value="confirmDelivered">
                                                                    <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                    <button type="submit" class="btn btn-success w-100" style="border-radius: 50px; font-weight: 800; padding: 12px 24px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.35);" onclick="return confirm('Xác nhận bạn đã giao món ăn tận nơi cho khách #FZ-${activeOrder.id}? Đơn hàng sẽ hoàn tất ngay lập tức.');">
                                                                        <i class="fa-solid fa-circle-check me-2"></i> 2. XÁC NHẬN ĐÃ GIAO CHO KHÁCH
                                                                    </button>
                                                                </form>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Button Báo Sự Cố / Hủy Cuốc (chỉ hiện khi chưa giao) -->
                                                        <c:if test="${not activeOrder.shipperDelivered}">
                                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin: 0;" onsubmit="return confirm('Bạn có chắc muốn báo hủy / không giao được đơn #FZ-${activeOrder.id}?');">
                                                                <input type="hidden" name="action" value="updateOrder">
                                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                <input type="hidden" name="status" value="CANCELLED">
                                                                <button type="submit" class="btn btn-outline-danger" style="border-radius: 50px; font-weight: 600; padding: 12px 18px;">
                                                                    <i class="fa-solid fa-triangle-exclamation me-1"></i> Báo Sự Cố
                                                                </button>
                                                            </form>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Right Column: Simulated GPS Map and Progress -->
                                            <div style="flex: 1; min-width: 280px; background: #f8fafc; border-left: 1px solid #e2e8f0; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                                                <div>
                                                    <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 16px;">
                                                        <i class="fa-solid fa-location-crosshairs text-primary me-2"></i> Lộ Trình 2 Chặng Đơn #FZ-${activeOrder.id}
                                                    </h4>
                                                    <div style="position: relative; padding-left: 28px; margin-bottom: 24px;">
                                                        <!-- Chặng 1: Đến quán nhận món -->
                                                        <div style="position: absolute; left: 0; top: 2px; width: 16px; height: 16px; border-radius: 50%; ${activeOrder.shipperPickedUp ? 'background: #10ac84;' : 'background: #f59e0b; animation: radarWave 1.5s infinite;'}"></div>
                                                        <div style="border-left: 2px solid ${activeOrder.shipperPickedUp ? '#10ac84' : '#cbd5e1'}; position: absolute; left: 7px; top: 18px; bottom: 20px;"></div>
                                                        <div style="margin-bottom: 24px;">
                                                            <div style="font-weight: 700; font-size: 0.95rem; color: ${activeOrder.shipperPickedUp ? '#10ac84' : '#d97706'};">
                                                                ${activeOrder.shipperPickedUp ? '✓ Đã nhận món tại Quán ăn' : '⏳ Đang di chuyển đến Quán ăn'}
                                                            </div>
                                                            <div style="font-size: 0.85rem; color: #64748b;">
                                                                ${activeOrder.shipperPickedUp ? 'Món ăn đã được bàn giao cho tài xế' : 'Vui lòng đến quán và bấm xác nhận lấy món'}
                                                            </div>
                                                        </div>

                                                        <!-- Chặng 2: Giao tận tay khách -->
                                                        <div style="position: absolute; left: 0; top: 68px; width: 16px; height: 16px; border-radius: 50%; ${activeOrder.shipperDelivered ? 'background: #10ac84;' : (activeOrder.shipperPickedUp ? 'background: #3b82f6; animation: radarWave 1.5s infinite;' : 'background: #cbd5e1;')}"></div>
                                                        <div>
                                                            <div style="font-weight: 700; font-size: 0.95rem; color: ${activeOrder.shipperDelivered ? '#10ac84' : (activeOrder.shipperPickedUp ? '#3b82f6' : '#94a3b8')};">
                                                                <c:choose>
                                                                    <c:when test="${activeOrder.shipperDelivered}">✓ Đã giao tận tay cho khách</c:when>
                                                                    <c:when test="${activeOrder.shipperPickedUp}">🛵 Đang trên đường đến nhà khách</c:when>
                                                                    <c:otherwise>Chờ lấy món xong sẽ giao</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div style="font-size: 0.85rem; color: #64748b;">${activeOrder.address}</div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px; text-align: center;">
                                                    <div style="font-size: 0.82rem; color: #64748b; margin-bottom: 4px;">Thù lao cước ship bạn nhận:</div>
                                                    <div style="font-size: 1.4rem; font-weight: 800; color: #10ac84;">
                                                        +<fmt:formatNumber value="${activeOrder.shippingFee != null ? activeOrder.shippingFee : 15000}" pattern="#,###" /> đ
                                                    </div>
                                                    <div style="font-size: 0.78rem; color: #64748b; margin-top: 2px;">
                                                        Cự ly: <strong>${activeOrder.distanceKm != null ? activeOrder.distanceKm : 2.0} km</strong>
                                                    </div>
                                                    <div style="font-size: 0.74rem; color: #94a3b8; margin-top: 4px;">*Tự động cộng vào ví ngay sau khi báo giao xong</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:when>

                    <c:when test="${driver.status eq 'AVAILABLE'}">
                        <!-- ĐÀI RADAR QUÉT ĐƠN TRỰC TUYẾN TỰ ĐỘNG -->
                        <div class="shipper-card" style="padding: 30px 24px;">
                            <div style="max-width: 680px; margin: 0 auto;">
                                <div id="radarScan" class="radar-box">
                                    <div class="radar-pulse-center">
                                        <i class="fa-solid fa-motorcycle"></i>
                                    </div>
                                    <h4 style="color: #065f46; font-weight: 800; margin-bottom: 6px;">Đang dò tìm đơn hàng mới trong bán kính 5km...</h4>
                                    <p id="radarStatus" style="color: #047857; margin: 0; font-size: 0.92rem;">
                                        Bạn đang ở chế độ Trực Tuyến. Vui lòng giữ trang web mở để chuông báo rung khi có đơn mới!
                                    </p>
                                </div>

                                <!-- New Order Popup Box -->
                                <div id="orderPopup" class="new-order-popup" style="display: none;">
                                    <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 2px dashed #fcd34d; padding-bottom: 12px; margin-bottom: 16px;">
                                        <h3 style="margin: 0; font-weight: 900; color: #d97706; font-size: 1.3rem;">
                                            <i class="fa-solid fa-bell fa-shake me-2"></i> PHÁT HIỆN CUỐC XE MỚI!
                                        </h3>
                                        <span style="background: #fef3c7; color: #b45309; padding: 4px 12px; border-radius: 50px; font-weight: 800; font-size: 0.85rem;">
                                            Cần giao ngay
                                        </span>
                                    </div>

                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; margin-bottom: 20px;">
                                        <div>
                                            <span style="font-size: 0.85rem; color: #64748b;">Mã đơn hàng:</span>
                                            <div id="pOrderId" style="font-weight: 800; font-size: 1.15rem; color: #1e293b;"></div>
                                        </div>
                                        <div>
                                            <span style="font-size: 0.85rem; color: #64748b;">Khách hàng:</span>
                                            <div id="pCustomer" style="font-weight: 700; font-size: 1.05rem; color: #1e293b;"></div>
                                        </div>
                                        <div style="grid-column: 1 / -1;">
                                            <span style="font-size: 0.85rem; color: #64748b;">Địa chỉ giao:</span>
                                            <div id="pAddress" style="font-weight: 600; font-size: 1rem; color: #1e293b;"><i class="fa-solid fa-location-dot text-danger me-1"></i> </div>
                                        </div>
                                        <div>
                                            <span style="font-size: 0.85rem; color: #64748b;">Tổng tiền thu hộ (COD):</span>
                                            <div style="font-size: 1.45rem; font-weight: 900; color: #dc2626;"><span id="pAmount"></span> đ</div>
                                        </div>
                                        <div>
                                            <span style="font-size: 0.85rem; color: #64748b;">Thù lao giao hàng:</span>
                                            <div style="font-size: 1.25rem; font-weight: 800; color: #10ac84;">+15.000 đ</div>
                                        </div>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                        <input type="hidden" name="action" value="acceptOrder">
                                        <input type="hidden" name="orderId" id="fOrderId" value="">
                                        <button type="submit" class="btn btn-warning btn-lg" style="width: 100%; border-radius: 50px; font-weight: 800; font-size: 1.2rem; padding: 14px 24px; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #fff; border: none; box-shadow: 0 6px 20px rgba(245, 158, 11, 0.4);">
                                            ⚡ BẤM NHẬN CUỐC XE NGAY
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <script>
                            document.addEventListener("DOMContentLoaded", function() {
                                let isDisplayingOrder = false;
                                setInterval(function() {
                                    if (isDisplayingOrder) return;
                                    fetch('${pageContext.request.contextPath}/shipper/api/dispatch')
                                        .then(res => res.json())
                                        .then(data => {
                                            if (data && data.status === 'found') {
                                                isDisplayingOrder = true;
                                                document.getElementById('radarScan').style.display = 'none';
                                                document.getElementById('orderPopup').style.display = 'block';

                                                document.getElementById('pOrderId').innerText = '#FZ-' + data.orderId;
                                                document.getElementById('pCustomer').innerText = data.customer || 'Khách hàng Utee';
                                                document.getElementById('pAddress').innerHTML = '<i class="fa-solid fa-location-dot text-danger me-1"></i> ' + (data.address || 'Khu vực nội thành TP.HCM');
                                                document.getElementById('pAmount').innerText = new Intl.NumberFormat('vi-VN').format(data.amount || 0);
                                                document.getElementById('fOrderId').value = data.orderId;

                                                try {
                                                    let ding = new Audio('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3');
                                                    ding.play().catch(e => console.log('Audio autoplay blocked by browser policy'));
                                                } catch(e) {}
                                            }
                                        })
                                        .catch(err => console.error("Lỗi polling dispatch:", err));
                                }, 4000);
                            });
                        </script>
                    </c:when>

                    <c:otherwise>
                        <!-- KHI DRIVER STATUS EQ 'OFFLINE' -->
                        <div class="shipper-card" style="text-align: center; padding: 50px 24px;">
                            <div style="width: 80px; height: 80px; border-radius: 50%; background: #f1f5f9; color: #64748b; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 20px auto;">
                                <i class="fa-solid fa-power-off"></i>
                            </div>
                            <h3 style="font-size: 1.4rem; font-weight: 800; color: #1e293b; margin-bottom: 8px;">
                                Bạn Đang Ngoại Tuyến (Đã Tắt Nhận Đơn)
                            </h3>
                            <p style="color: #64748b; max-width: 540px; margin: 0 auto 24px auto; font-size: 0.95rem; line-height: 1.6;">
                                Bật chế độ nhận đơn để bắt đầu quét tìm các đơn hàng mới nhất xung quanh vị trí của bạn và gia tăng thu nhập mỗi ngày cùng Utee Express.
                            </p>
                            <div style="display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;">
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.3);">
                                        <i class="fa-solid fa-bolt me-1"></i> Bật nhận đơn ngay
                                    </button>
                                </form>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=income" class="btn btn-outline" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; border-color: #cbd5e1; color: #475569;">
                                    <i class="fa-solid fa-wallet me-1"></i> Xem ví thu nhập
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <!-- ============================================================= -->
            <!-- TAB 2: THU NHẬP TÀI XẾ (income) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'income'}">
                <div class="shipper-card">
                    <div class="sec-card-header">
                        <div>
                            <h3 class="sec-card-title"><i class="fa-solid fa-wallet text-success me-2"></i> Tổng Quan Ví Thu Nhập Tài Xế</h3>
                            <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Minh bạch số dư ví, tiền thù lao từng cuốc xe và lịch đối soát tự động</p>
                        </div>
                        <button type="button" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 10px 22px; background: #10ac84; border-color: #10ac84;" onclick="alert('Hệ thống Utee Express tự động đối soát và chuyển khoản vào 15:00 Thứ 2 và Thứ 5 hàng tuần. Bạn cũng có thể liên kết tài khoản ngân hàng trong Cài đặt.');">
                            <i class="fa-solid fa-money-bill-transfer me-1"></i> Yêu Cầu Rút Tiền
                        </button>
                    </div>

                    <div class="sec-card-body">
                        <!-- Stat Grid -->
                        <div class="income-grid">
                            <!-- Card 1: Today -->
                            <div class="income-stat-card" style="border-left: 4px solid #10ac84; background: #f0fdf4;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #15803d; text-transform: uppercase;">Thu Nhập Hôm Nay</div>
                                <div style="font-size: 1.8rem; font-weight: 900; color: #16a34a; margin: 6px 0;">
                                    <fmt:formatNumber value="${wallet.todayEarnings}" pattern="#,###" /> đ
                                </div>
                                <div style="font-size: 0.85rem; color: #64748b;">
                                    Đã hoàn tất: <strong>${wallet.todayTrips} chuyến giao</strong>
                                </div>
                            </div>

                            <!-- Card 2: Total Accumulation -->
                            <div class="income-stat-card" style="border-left: 4px solid #f05454; background: #fff5f5;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #dc2626; text-transform: uppercase;">Tổng Thu Nhập Tích Lũy</div>
                                <div style="font-size: 1.8rem; font-weight: 900; color: #f05454; margin: 6px 0;">
                                    <fmt:formatNumber value="${wallet.totalEarnings}" pattern="#,###" /> đ
                                </div>
                                <div style="font-size: 0.85rem; color: #64748b;">
                                    Tổng cuốc: <strong>${wallet.totalTrips} chuyến hoàn tất</strong>
                                </div>
                            </div>

                            <!-- Card 3: Bonus Tier -->
                            <div class="income-stat-card" style="border-left: 4px solid #f59e0b; background: #fffbeb;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #b45309; text-transform: uppercase;">Thưởng Mốc Hoạt Động</div>
                                <div style="font-size: 1.8rem; font-weight: 900; color: #d97706; margin: 6px 0;">
                                    +50.000 đ
                                </div>
                                <div style="font-size: 0.85rem; color: #b45309;">
                                    Mục tiêu: Đạt 10 cuốc/ngày (Tiến độ: ${wallet.todayTrips}/10)
                                </div>
                            </div>
                        </div>

                        <!-- Bank & Payout info card -->
                        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 14px; padding: 18px 22px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                            <div style="display: flex; align-items: center; gap: 14px;">
                                <div style="width: 48px; height: 48px; border-radius: 12px; background: #e0f2fe; color: #0284c7; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;">
                                    <i class="fa-solid fa-building-columns"></i>
                                </div>
                                <div>
                                    <h5 style="margin: 0; font-weight: 800; color: #1e293b;">Tài Khoản Nhận Thù Lao Mặc Định</h5>
                                    <p style="margin: 2px 0 0 0; font-size: 0.88rem; color: #64748b;">
                                        Ngân hàng: <strong>MB Bank (Quân Đội)</strong> • STK: <strong>9999****8888</strong> • Chủ TK: <strong>${sessionScope.currentUser.fullName.toUpperCase()}</strong>
                                    </p>
                                </div>
                            </div>
                            <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.82rem; padding: 6px 12px; border-radius: 50px;">
                                <i class="fa-solid fa-shield-check me-1"></i> Đã liên kết &amp; Xác thực
                            </span>
                        </div>

                        <!-- Recent Earnings Table -->
                        <h4 style="font-size: 1.1rem; font-weight: 800; color: #1e293b; margin-bottom: 14px;">
                            <i class="fa-solid fa-receipt text-primary me-2"></i> Kê Khai Thù Lao Các Chuyến Gần Nhất
                        </h4>

                        <c:choose>
                            <c:when test="${empty deliveryHistory}">
                                <div style="text-align: center; padding: 36px 20px; background: #fafbfc; border-radius: 12px; border: 1px dashed #cbd5e1;">
                                    <p style="color: #94a3b8; font-size: 0.9rem; margin: 0;">Chưa có giao dịch thu nhập phát sinh. Hãy nhận đơn để gia tăng thu nhập!</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="overflow-x: auto;">
                                    <table style="width: 100%; border-collapse: collapse; font-size: 0.92rem;">
                                        <thead>
                                            <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; text-align: left;">
                                                <th style="padding: 12px 16px; color: #475569;">Mã Cuốc Xe</th>
                                                <th style="padding: 12px 16px; color: #475569;">Thời Gian</th>
                                                <th style="padding: 12px 16px; color: #475569;">Điểm Giao</th>
                                                <th style="padding: 12px 16px; color: #475569;">COD Thu Hộ</th>
                                                <th style="padding: 12px 16px; color: #475569; text-align: right;">Thù Lao Shipper</th>
                                                <th style="padding: 12px 16px; color: #475569; text-align: center;">Trạng Thái Ví</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${deliveryHistory}">
                                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                                    <td style="padding: 12px 16px; font-weight: 800; color: #1e293b;">#FZ-${item.id}</td>
                                                    <td style="padding: 12px 16px; color: #64748b;">
                                                        <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td style="padding: 12px 16px; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                        ${item.address}
                                                    </td>
                                                    <td style="padding: 12px 16px; font-weight: 700; color: #dc2626;">
                                                        <fmt:formatNumber value="${item.totalAmount}" pattern="#,###" /> đ
                                                    </td>
                                                    <td style="padding: 12px 16px; font-weight: 800; color: #10ac84; text-align: right;">
                                                        <c:choose>
                                                            <c:when test="${item.status eq 'DELIVERED'}">+15.000 đ</c:when>
                                                            <c:otherwise><span style="color:#94a3b8;">0 đ</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="padding: 12px 16px; text-align: center;">
                                                        <c:choose>
                                                            <c:when test="${item.status eq 'DELIVERED'}">
                                                                <span class="badge" style="background: #dcfce7; color: #15803d; border-radius: 50px; padding: 4px 10px; font-size: 0.78rem;">
                                                                    <i class="fa-solid fa-check me-1"></i> Đã vào ví
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${item.status eq 'CANCELLED'}">
                                                                <span class="badge" style="background: #fee2e2; color: #dc2626; border-radius: 50px; padding: 4px 10px; font-size: 0.78rem;">
                                                                    Đã hủy
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge" style="background: #e0f2fe; color: #0284c7; border-radius: 50px; padding: 4px 10px; font-size: 0.78rem;">
                                                                    Đang xử lý
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- TAB 3: LỊCH SỬ CHUYẾN GIAO (history) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'history'}">
                <div class="shipper-card" style="padding: 24px;">
                    <!-- History Title & Metrics Summary Bar -->
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; padding-bottom: 18px; margin-bottom: 20px; flex-wrap: wrap; gap: 14px;">
                        <div>
                            <h3 style="margin: 0; font-size: 1.3rem; font-weight: 800; color: #1e293b;">
                                <i class="fa-solid fa-route text-primary me-2"></i> Lịch Sử Các Chuyến Xe Giao Hàng
                            </h3>
                            <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">
                                Danh sách toàn bộ các chuyến bạn đã tiếp nhận giao hàng cho quán ăn.
                            </p>
                        </div>
                        <div style="display: flex; gap: 12px; align-items: center;">
                            <span style="font-size: 0.9rem; color: #475569;">
                                Tổng: <strong>${totalDeliveryCount} cuốc</strong>
                            </span>
                            <span>•</span>
                            <span style="font-size: 0.9rem; color: #10ac84;">
                                Hoàn thành: <strong>${deliveredCount}</strong>
                            </span>
                            <span>•</span>
                            <span style="font-size: 0.9rem; color: #dc2626;">
                                Hủy/Bom: <strong>${cancelledCount}</strong>
                            </span>
                        </div>
                    </div>

                    <!-- Filter Pills -->
                    <div class="filter-pills">
                        <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=ALL" class="filter-pill-btn ${empty currentStatusFilter or currentStatusFilter eq 'ALL' ? 'active' : ''}">
                            Tất cả chuyến (${totalDeliveryCount})
                        </a>
                        <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=DELIVERED" class="filter-pill-btn ${currentStatusFilter eq 'DELIVERED' ? 'active' : ''}">
                            Giao thành công (${deliveredCount})
                        </a>
                        <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=SHIPPING" class="filter-pill-btn ${currentStatusFilter eq 'SHIPPING' ? 'active' : ''}">
                            Đang giao (${shippingCount})
                        </a>
                        <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=CANCELLED" class="filter-pill-btn ${currentStatusFilter eq 'CANCELLED' ? 'active' : ''}">
                            Đã hủy / Bom hàng (${cancelledCount})
                        </a>
                    </div>

                    <!-- Delivery History Order Cards List -->
                    <c:choose>
                        <c:when test="${empty deliveryHistory}">
                            <div style="text-align: center; padding: 48px 20px; background: #fafbfc; border-radius: 12px; border: 1px dashed #cbd5e1;">
                                <div style="font-size: 3rem; color: #cbd5e1; margin-bottom: 12px;">
                                    <i class="fa-solid fa-motorcycle"></i>
                                </div>
                                <h4 style="color: #475569; font-weight: 700; margin-bottom: 6px;">Chưa có chuyến xe nào trong danh mục này</h4>
                                <p style="color: #94a3b8; font-size: 0.9rem; margin: 0 0 16px 0;">
                                    Khi bạn nhận và giao đơn cho khách hàng, thông tin chuyến đi và đánh giá sao sẽ xuất hiện tại đây.
                                </p>
                                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="btn btn-primary btn-sm" style="border-radius: 50px; font-weight: 600;">
                                    <i class="fa-solid fa-satellite-dish me-1"></i> Quay lại đài nhận đơn
                                </a>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="item" items="${deliveryHistory}">
                                <div class="trip-card">
                                    <!-- Trip Header -->
                                    <div class="trip-header">
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <span class="trip-id">#FZ-${item.id}</span>
                                            <span class="trip-time">
                                                <i class="fa-regular fa-clock me-1"></i>
                                                <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </span>
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${item.status eq 'DELIVERED'}">
                                                    <span style="background: #dcfce7; color: #15803d; font-weight: 700; padding: 6px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-circle-check me-1"></i> Giao thành công
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.status eq 'SHIPPING'}">
                                                    <span style="background: #dbeafe; color: #1d4ed8; font-weight: 700; padding: 6px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-motorcycle me-1"></i> Đang giao hàng
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.status eq 'CANCELLED'}">
                                                    <span style="background: #fee2e2; color: #b91c1c; font-weight: 700; padding: 6px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-ban me-1"></i> Đã hủy / Bom hàng
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="background: #f1f5f9; color: #475569; font-weight: 700; padding: 6px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        ${item.status}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <!-- Trip Details Grid -->
                                    <div class="trip-grid">
                                        <div>
                                            <div class="trip-field"><strong>Khách hàng:</strong> ${item.customerName}</div>
                                            <div class="trip-field"><strong>Hotline khách:</strong> <a href="tel:${item.phone}" style="color: #0284c7; text-decoration: none; font-weight: 600;"><i class="fa-solid fa-phone me-1"></i>${item.phone}</a></div>
                                        </div>
                                        <div>
                                            <div class="trip-field"><strong>Điểm giao:</strong> <i class="fa-solid fa-location-dot text-danger me-1"></i> ${item.address}</div>
                                            <div class="trip-field">
                                                <strong>Tiền thu hộ COD:</strong> 
                                                <span style="color: #dc2626; font-weight: 800; font-size: 1.05rem;">
                                                    <fmt:formatNumber value="${item.totalAmount}" pattern="#,###" /> đ
                                                </span>
                                                <span style="font-size: 0.8rem; color: #64748b;">(${item.paymentMethod})</span>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="trip-field">
                                                <strong>Thù lao cuốc xe:</strong>
                                                <c:choose>
                                                    <c:when test="${item.status eq 'DELIVERED'}">
                                                        <span style="color: #10ac84; font-weight: 800;">+15.000 đ (Đã vào ví)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #94a3b8;">0 đ</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <c:if test="${not empty item.note}">
                                                <div class="trip-field" style="font-size: 0.85rem; color: #64748b;">
                                                    <strong>Ghi chú:</strong> <em>"${item.note}"</em>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Khách Hàng Đánh Giá Shipper & Món Ăn -->
                                    <div class="trip-review-box">
                                        <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
                                            <div>
                                                <span style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-right: 8px;">
                                                    <i class="fa-solid fa-star text-warning me-1"></i> Đánh giá của khách:
                                                </span>
                                                <c:choose>
                                                    <c:when test="${not empty item.review}">
                                                        <span class="star-rating-display">
                                                            <c:forEach begin="1" end="${item.review.driverRating}">
                                                                <i class="fa-solid fa-star"></i>
                                                            </c:forEach>
                                                            <c:forEach begin="${item.review.driverRating + 1}" end="5">
                                                                <i class="fa-regular fa-star" style="color: #cbd5e1;"></i>
                                                            </c:forEach>
                                                        </span>
                                                        <strong style="color: #b45309; font-size: 0.95rem;">Tài xế: ${item.review.driverRating}/5 sao</strong>
                                                        <c:if test="${not empty item.review.foodRating}">
                                                            <span style="color: #64748b; font-size: 0.85rem; margin-left: 8px;">| Món ăn: ${item.review.foodRating}/5 sao</span>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: #94a3b8; font-size: 0.85rem; font-style: italic;">Khách chưa để lại đánh giá cho cuốc này</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <c:if test="${not empty item.review and not empty item.review.createdAt}">
                                                <span style="font-size: 0.78rem; color: #94a3b8;">
                                                    <fmt:formatDate value="${item.review.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </span>
                                            </c:if>
                                        </div>

                                        <c:if test="${not empty item.review}">
                                            <c:if test="${not empty item.review.driverComment}">
                                                <p style="margin: 8px 0 0 0; font-size: 0.92rem; color: #334155; font-style: italic; background: #fff; padding: 8px 14px; border-radius: 8px; border: 1px dashed #e2e8f0;">
                                                    <strong><i class="fa-solid fa-motorcycle text-primary me-1"></i> Shipper:</strong> "${item.review.driverComment}"
                                                </p>
                                            </c:if>
                                            <c:if test="${not empty item.review.foodComment and item.review.foodComment ne item.review.driverComment}">
                                                <p style="margin: 6px 0 0 0; font-size: 0.88rem; color: #475569; font-style: italic; background: #fff; padding: 6px 14px; border-radius: 8px; border: 1px dashed #e2e8f0;">
                                                    <strong><i class="fa-solid fa-utensils text-warning me-1"></i> Món ăn:</strong> "${item.review.foodComment}"
                                                </p>
                                            </c:if>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- TAB 4: ĐIỂM VI PHẠM (violations) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'violations'}">
                <div class="shipper-card">
                    <div class="sec-card-header">
                        <div>
                            <h3 class="sec-card-title"><i class="fa-solid fa-shield-halved text-warning me-2"></i> Điểm Vi Phạm &amp; Tác Phong Hoạt Động</h3>
                            <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Theo dõi điểm hạnh kiểm, tỷ lệ hoàn thành cuốc xe và quy chế tài xế 5 sao</p>
                        </div>
                        <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.85rem; padding: 8px 16px; border-radius: 50px;">
                            <i class="fa-solid fa-circle-check me-1"></i> Tài khoản Tốt (Không có vi phạm)
                        </span>
                    </div>

                    <div class="sec-card-body">
                        <!-- Score Hero Box -->
                        <div style="background: linear-gradient(135deg, #f0fdf4 0%, #e6f9ed 100%); border: 1px solid #bbf7d0; border-radius: 16px; padding: 24px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px;">
                            <div style="display: flex; align-items: center; gap: 18px;">
                                <div style="width: 72px; height: 72px; border-radius: 50%; background: #10ac84; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; font-weight: 900; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.3);">
                                    100
                                </div>
                                <div>
                                    <div style="font-size: 0.85rem; font-weight: 700; color: #15803d; text-transform: uppercase;">Điểm Hạnh Kiểm Hiện Tại</div>
                                    <h3 style="margin: 2px 0 0 0; font-size: 1.45rem; font-weight: 900; color: #065f46;">100 / 100 Điểm (Hạng Xuất Sắc 🏆)</h3>
                                    <p style="margin: 4px 0 0 0; font-size: 0.88rem; color: #047857;">Tài khoản ưu tiên nhận các cuốc xe có giá trị cao và thưởng tuần hấp dẫn.</p>
                                </div>
                            </div>
                            <div style="text-align: right;">
                                <span style="display: inline-block; background: #fff; border: 1px solid #86efac; border-radius: 12px; padding: 8px 16px; font-weight: 700; color: #15803d; font-size: 0.9rem;">
                                    <i class="fa-solid fa-award text-warning me-1"></i> Đối Tác Gương Mẫu
                                </span>
                            </div>
                        </div>

                        <!-- 4 Service Quality Metric Cards -->
                        <div class="income-grid" style="margin-bottom: 24px;">
                            <div class="income-stat-card">
                                <div style="font-size: 0.82rem; color: #64748b; font-weight: 700;">TỶ LỆ NHẬN ĐƠN (AR)</div>
                                <div style="font-size: 1.6rem; font-weight: 900; color: #10ac84; margin: 4px 0;">98.5%</div>
                                <div style="font-size: 0.8rem; color: #15803d;">Mục tiêu duy trì: &gt;= 85%</div>
                            </div>
                            <div class="income-stat-card">
                                <div style="font-size: 0.82rem; color: #64748b; font-weight: 700;">TỶ LỆ HỦY CUỐC (CR)</div>
                                <div style="font-size: 1.6rem; font-weight: 900; color: #10ac84; margin: 4px 0;">0.0%</div>
                                <div style="font-size: 0.8rem; color: #15803d;">Mục tiêu an toàn: &lt; 5%</div>
                            </div>
                            <div class="income-stat-card">
                                <div style="font-size: 0.82rem; color: #64748b; font-weight: 700;">TỶ LỆ ĐÚNG GIỜ 30P</div>
                                <div style="font-size: 1.6rem; font-weight: 900; color: #3b82f6; margin: 4px 0;">99.2%</div>
                                <div style="font-size: 0.8rem; color: #1d4ed8;">Chuẩn cam kết Utee Express</div>
                            </div>
                            <div class="income-stat-card">
                                <div style="font-size: 0.82rem; color: #64748b; font-weight: 700;">ĐÁNH GIÁ TRUNG BÌNH</div>
                                <div style="font-size: 1.6rem; font-weight: 900; color: #f59e0b; margin: 4px 0;">
                                    ${driverRatingStats != null ? driverRatingStats['avgRating'] : 5.0} ⭐
                                </div>
                                <div style="font-size: 0.8rem; color: #b45309;">Từ thực khách &amp; Quán ăn</div>
                            </div>
                        </div>

                        <!-- Violations Rules & Regulations -->
                        <h4 style="font-size: 1.1rem; font-weight: 800; color: #1e293b; margin-bottom: 14px;">
                            <i class="fa-solid fa-book-open text-primary me-2"></i> Bảng Quy Chuẩn Xử Lý Vi Phạm Đối Tác Tài Xế
                        </h4>

                        <div style="overflow-x: auto;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 0.9rem;">
                                <thead>
                                    <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; text-align: left;">
                                        <th style="padding: 10px 14px; color: #475569;">Hành Vi Vi Phạm</th>
                                        <th style="padding: 10px 14px; color: #475569; text-align: center;">Điểm Trừ Hạnh Kiểm</th>
                                        <th style="padding: 10px 14px; color: #475569;">Biện Pháp Xử Lý</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 14px; color: #334155;">Tự ý hủy đơn sau khi đã bấm nhận cuốc (không có lý do chính đáng)</td>
                                        <td style="padding: 10px 14px; text-align: center; color: #dc2626; font-weight: 700;">-5 điểm / lần</td>
                                        <td style="padding: 10px 14px; color: #64748b;">Khóa nhận đơn 2 giờ</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 14px; color: #334155;">Giao trễ quá 45 phút không thông báo trước cho quán &amp; khách</td>
                                        <td style="padding: 10px 14px; text-align: center; color: #dc2626; font-weight: 700;">-3 điểm / lần</td>
                                        <td style="padding: 10px 14px; color: #64748b;">Nhắc nhở qua thông báo app</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 14px; color: #334155;">Thu sai tiền thu hộ COD hoặc thái độ phục vụ khiếm nhã</td>
                                        <td style="padding: 10px 14px; text-align: center; color: #dc2626; font-weight: 700;">-10 điểm / lần</td>
                                        <td style="padding: 10px 14px; color: #64748b;">Hoàn tiền &amp; Đào tạo lại tác phong</td>
                                    </tr>
                                    <tr style="border-bottom: 1px solid #f1f5f9;">
                                        <td style="padding: 10px 14px; color: #334155;">Khi điểm hạnh kiểm tích lũy dưới 70 điểm</td>
                                        <td style="padding: 10px 14px; text-align: center; color: #dc2626; font-weight: 700;">&lt; 70 điểm</td>
                                        <td style="padding: 10px 14px; color: #dc2626; font-weight: 600;">Tạm khóa tài khoản tài xế</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- TAB 5: CÀI ĐẶT TÀI XẾ (settings) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'settings'}">
                <div class="shipper-card">
                    <div class="sec-card-header">
                        <div>
                            <h3 class="sec-card-title"><i class="fa-solid fa-gear text-secondary me-2"></i> Cài Đặt Hoạt Động &amp; Hồ Sơ Phương Tiện</h3>
                            <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Tùy chỉnh khoảng cách quét đơn, âm báo chuông và thông tin xe máy</p>
                        </div>
                    </div>

                    <div class="sec-card-body">
                        <!-- Group 1: Dispatch Settings -->
                        <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px;">
                            <i class="fa-solid fa-sliders text-primary me-2"></i> Tùy Chỉnh Tiếp Nhận Đơn Hàng
                        </h4>

                        <div class="form-switch-row">
                            <div>
                                <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Tự động nhận đơn nhanh (Auto-Accept)</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Tự động tiếp nhận khi quán gần bạn phát tín hiệu gán đơn trực tiếp</div>
                            </div>
                            <div>
                                <input type="checkbox" id="autoAcceptToggle" checked style="width: 20px; height: 20px; accent-color: #10ac84; cursor: pointer;">
                            </div>
                        </div>

                        <div class="form-switch-row">
                            <div>
                                <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Bán kính radar quét đơn hàng</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Khoảng cách tối đa từ vị trí hiện tại đến quán ăn lấy hàng</div>
                            </div>
                            <div>
                                <select style="padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; font-weight: 600; color: #1e293b; outline: none;">
                                    <option value="3">Bán kính 3 km (Gần nhất)</option>
                                    <option value="5" selected>Bán kính 5 km (Tiêu chuẩn)</option>
                                    <option value="10">Bán kính 10 km (Mở rộng)</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-switch-row">
                            <div>
                                <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Âm thanh chuông báo khi có cuốc mới</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Phát chuông rung to rõ để không bỏ lỡ các chuyến xe</div>
                            </div>
                            <div style="display: flex; gap: 8px; align-items: center;">
                                <button type="button" class="btn btn-outline-secondary btn-sm" style="border-radius: 50px; font-size: 0.8rem; font-weight: 600;" onclick="try { new Audio('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3').play(); } catch(e){}">
                                    <i class="fa-solid fa-volume-high me-1"></i> Thử chuông
                                </button>
                                <input type="checkbox" checked style="width: 20px; height: 20px; accent-color: #10ac84; cursor: pointer;">
                            </div>
                        </div>

                        <!-- Group 2: Vehicle Profile -->
                        <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin: 28px 0 16px 0; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px;">
                            <i class="fa-solid fa-motorcycle text-primary me-2"></i> Thông Tin Phương Tiện &amp; Giấy Tờ Đăng Ký
                        </h4>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Biển số xe đăng ký:</label>
                                <input type="text" class="form-control" value="${not empty driver.licensePlate ? driver.licensePlate : '59-X3 999.99'}" readonly style="background: #f8fafc; font-weight: 700;">
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Loại phương tiện:</label>
                                <input type="text" class="form-control" value="${not empty driver.vehicleType ? driver.vehicleType : 'Xe máy 2 bánh'}" readonly style="background: #f8fafc;">
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Căn cước công dân (CCCD):</label>
                                <div style="display: flex; align-items: center; gap: 8px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 8px 12px; font-size: 0.88rem; color: #15803d; font-weight: 600;">
                                    <i class="fa-solid fa-circle-check"></i> Đã xác thực CCCD gắn chip
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Giấy phép lái xe (GPLX):</label>
                                <div style="display: flex; align-items: center; gap: 8px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 8px 12px; font-size: 0.88rem; color: #15803d; font-weight: 600;">
                                    <i class="fa-solid fa-circle-check"></i> Hạng A1/A2 hợp lệ
                                </div>
                            </div>
                        </div>

                        <div style="margin-top: 24px; text-align: right;">
                            <button type="button" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 10px 24px;" onclick="alert('Đã lưu cấu hình cài đặt tài xế thành công!');">
                                <i class="fa-solid fa-check me-1"></i> Lưu Cấu Hình
                            </button>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- ============================================================= -->
            <!-- TAB 6: TRUNG TÂM TRỢ GIÚP (help) -->
            <!-- ============================================================= -->
            <c:if test="${activeTab eq 'help'}">
                <div class="shipper-card">
                    <div class="sec-card-header">
                        <div>
                            <h3 class="sec-card-title"><i class="fa-solid fa-circle-question text-primary me-2"></i> Trung Tâm Trợ Giúp Đối Tác Tài Xế Utee</h3>
                            <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Kênh hỗ trợ khẩn cấp 24/7, cẩm nang xử lý sự cố và giải đáp thắc mắc</p>
                        </div>
                    </div>

                    <div class="sec-card-body">
                        <!-- Emergency Contact Grid -->
                        <div class="income-grid" style="margin-bottom: 24px;">
                            <div class="income-stat-card" style="border-left: 4px solid #f05454; background: #fff5f5;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #dc2626;"><i class="fa-solid fa-phone-volume me-1"></i> HOTLINE KHẨN CẤP ĐANG GIAO ĐƠN</div>
                                <div style="font-size: 1.5rem; font-weight: 900; color: #dc2626; margin: 6px 0;">1900 6869</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Nhấn phím 1 để gặp bộ phận Điều Phối Khẩn Cấp (24/7)</div>
                            </div>

                            <div class="income-stat-card" style="border-left: 4px solid #0284c7; background: #f0f9ff;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #0369a1;"><i class="fa-brands fa-telegram me-1"></i> KÊNH HỖ TRỢ ZALO / TELEGRAM</div>
                                <div style="font-size: 1.25rem; font-weight: 900; color: #0284c7; margin: 6px 0;">@UteeDriverSupport</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Hỗ trợ đối soát thu nhập, cập nhật biển số xe và giấy tờ</div>
                            </div>
                        </div>

                        <!-- FAQ Section -->
                        <h4 style="font-size: 1.1rem; font-weight: 800; color: #1e293b; margin-bottom: 16px;">
                            <i class="fa-solid fa-lightbulb text-warning me-2"></i> Các Tình Huống Thường Gặp &amp; Hướng Xử Lý
                        </h4>

                        <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 28px;">
                            <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 18px; cursor: pointer;">
                                <summary style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                    <i class="fa-solid fa-circle-question text-primary me-2"></i> Khách hàng không nghe máy hoặc địa chỉ giao không chính xác?
                                </summary>
                                <p style="margin: 10px 0 0 0; color: #475569; font-size: 0.9rem; line-height: 1.6;">
                                    Vui lòng gọi tối thiểu 3 cuộc cách nhau 3 phút. Nếu sau 10 phút khách không phản hồi, hãy bấm nút <strong>"Báo Sự Cố / Hủy Cuốc"</strong> trên màn hình đơn hàng và liên hệ tổng đài 1900 6869 để được hỗ trợ bồi hoàn phí ship và xử lý hoàn món về quán.
                                </p>
                            </details>

                            <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 18px; cursor: pointer;">
                                <summary style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                    <i class="fa-solid fa-circle-question text-primary me-2"></i> Khi nào tiền thù lao cuốc xe được cộng vào ví tài xế?
                                </summary>
                                <p style="margin: 10px 0 0 0; color: #475569; font-size: 0.9rem; line-height: 1.6;">
                                    Sau khi bạn bấm <strong>"Báo Đã Giao Cho Khách"</strong> và khách hàng/quán hoàn tất xác nhận, thù lao 15.000 đ/cuốc sẽ được cộng tức thì vào số dư ví của bạn.
                                </p>
                            </details>

                            <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 18px; cursor: pointer;">
                                <summary style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                    <i class="fa-solid fa-circle-question text-primary me-2"></i> Gặp sự cố hỏng xe hoặc va chạm trên đường giao hàng?
                                </summary>
                                <p style="margin: 10px 0 0 0; color: #475569; font-size: 0.9rem; line-height: 1.6;">
                                    Ưu tiên an toàn bản thân lên hàng đầu. Hãy dừng lại nơi an toàn và gọi ngay hotline 1900 6869 nhánh 1 để điều phối viên gán tài xế khác hỗ trợ giao tiếp đơn hàng mà không bị trừ điểm hạnh kiểm.
                                </p>
                            </details>
                        </div>

                        <!-- Ticket form -->
                        <div style="background: #fff; border: 1px solid #cbd5e1; border-radius: 14px; padding: 22px;">
                            <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 14px;">
                                <i class="fa-solid fa-paper-plane text-primary me-2"></i> Gửi Yêu Cầu Hỗ Trợ Trực Tuyến
                            </h4>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Loại vấn đề cần hỗ trợ:</label>
                                    <select class="form-control">
                                        <option>Đối soát thu nhập / Rút tiền ví</option>
                                        <option>Khiếu nại điểm vi phạm / Đánh giá sao</option>
                                        <option>Cập nhật biển số xe / Số điện thoại</option>
                                        <option>Vấn đề khác</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Mã cuốc xe liên quan (nếu có):</label>
                                    <input type="text" class="form-control" placeholder="Ví dụ: #FZ-12">
                                </div>
                                <div class="col-12">
                                    <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Nội dung chi tiết:</label>
                                    <textarea class="form-control" rows="3" placeholder="Mô tả sự cố bạn gặp phải để CSKH hỗ trợ nhanh nhất..."></textarea>
                                </div>
                                <div class="col-12 text-end">
                                    <button type="button" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 10px 24px;" onclick="alert('Đã gửi phiếu yêu cầu hỗ trợ! Bộ phận CSKH sẽ phản hồi trong 15 phút.');">
                                        <i class="fa-solid fa-paper-plane me-1"></i> Gửi Yêu Cầu Hỗ Trợ
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
