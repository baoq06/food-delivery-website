<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="${activeTab eq 'history' ? 'Lịch Sử Giao Hàng - Đối Tác Tài Xế' : 'Bảng Điều Khiển Tài Xế - Utee Express'}" />
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
                <span style="color: #f05454; font-weight: 600;">${activeTab eq 'history' ? 'Lịch sử chuyến giao' : 'Bảng điều khiển & Nhận đơn'}</span>
            </div>
            <h1 class="page-title" style="margin: 0; font-size: 1.85rem; font-weight: 800; color: #fff; letter-spacing: -0.5px;">
                <i class="fa-solid ${activeTab eq 'history' ? 'fa-clock-rotate-left' : 'fa-motorcycle'}" style="color: #f05454; margin-right: 10px;"></i>
                ${activeTab eq 'history' ? 'Lịch Sử Chuyến Xe Giao Hàng' : 'Trung Tâm Điều Phối & Nhận Đơn'}
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
        padding: 14px 18px;
        border-radius: 12px;
        color: #475569;
        font-weight: 600;
        text-decoration: none;
        transition: all 0.2s ease;
        margin-bottom: 6px;
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
                        Giỏ hàng và tính năng đặt món ăn tạm thời khóa để bạn tập trung làm việc. Nếu muốn đặt đồ ăn, chỉ cần nhấn nút <strong>"TẮT CHẾ ĐỘ NHẬN ĐƠN"</strong> bên dưới!
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
        <!-- LEFT SIDEBAR: DRIVER PROFILE & WALLET STATS -->
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
                    <div style="background: #fff; border: 1px solid #fee2e2; border-radius: 10px; padding: 8px 12px; font-size: 0.85rem; color: #475569; display: flex; justify-content: space-around;">
                        <span><i class="fa-solid fa-motorcycle text-primary"></i> ${not empty driver.licensePlate ? driver.licensePlate : 'Xe máy'}</span>
                        <span>|</span>
                        <span><i class="fa-solid fa-shield-halved text-success"></i> Đã xác thực</span>
                    </div>
                </div>

                <!-- Navigation Tabs -->
                <div class="shipper-nav">
                    <a href="${pageContext.request.contextPath}/shipper/dashboard" class="shipper-nav-item ${activeTab ne 'history' ? 'active' : ''}">
                        <span><i class="fa-solid fa-gauge-high me-2" style="width: 22px;"></i> Nhận đơn & Điều phối</span>
                        <c:if test="${not empty activeOrder}">
                            <span class="shipper-nav-badge">1 đơn</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history" class="shipper-nav-item ${activeTab eq 'history' ? 'active' : ''}">
                        <span><i class="fa-solid fa-clock-rotate-left me-2" style="width: 22px;"></i> Lịch sử chuyến giao</span>
                        <c:if test="${totalDeliveryCount > 0}">
                            <span class="shipper-nav-badge" style="background: #e2e8f0; color: #334155;">${totalDeliveryCount}</span>
                        </c:if>
                    </a>
                    <c:if test="${driver.status eq 'OFFLINE'}">
                        <!-- Quick switch to food menu when offline -->
                        <a href="${pageContext.request.contextPath}/foods" class="shipper-nav-item" style="color: #10ac84; background: #f0fdf4;">
                            <span><i class="fa-solid fa-utensils me-2" style="width: 22px;"></i> Xem thực đơn (Làm khách)</span>
                            <span class="shipper-nav-badge" style="background: #dcfce7; color: #16a34a;">Đặt món</span>
                        </a>
                    </c:if>
                </div>

                <!-- Driver Wallet Box -->
                <c:if test="${not empty wallet}">
                    <div class="wallet-stat-card">
                        <div class="wallet-title">
                            <i class="fa-solid fa-wallet text-success"></i> Ví Thu Nhập Tài Xế
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
        <!-- RIGHT CONTENT: STATUS SWITCHER + (DISPATCH / HISTORY) -->
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
                                <c:otherwise>ĐANG TẮT NHẬN ĐƠN (CHẾ ĐỘ KHÁCH HÀNG)</c:otherwise>
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
                                    Bạn đang ngoại tuyến nhận đơn. Lúc này bạn có thể duyệt menu, thêm vào giỏ hàng và đặt đồ ăn như một khách hàng thông thường!
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
                                    <i class="fa-solid fa-power-off"></i> TẮT NHẬN ĐƠN (Làm khách)
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

            <!-- ============================================================= -->
            <!-- CONDITIONAL TAB 1: DISPATCH & ACTIVE ORDER (activeTab ne 'history') -->
            <!-- ============================================================= -->
            <c:if test="${activeTab ne 'history'}">
                <!-- ĐƠN HÀNG QUÁN VỪA CHỈ ĐỊNH (CẦN SHIPPER XÁC NHẬN NHẬN CUỐC) -->
                <c:if test="${not empty pendingAssignedOrder}">
                    <div class="shipper-card mb-4" style="border: 2px solid #f59e0b; background: #fffdf5; box-shadow: 0 10px 25px rgba(245, 158, 11, 0.15);">
                        <div style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                            <div class="d-flex align-items-center gap-2">
                                <div style="width: 40px; height: 40px; border-radius: 50%; background: rgba(255,255,255,0.25); display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                                    <i class="fa-solid fa-bell fa-shake"></i>
                                </div>
                                <div>
                                    <h4 style="margin: 0; font-weight: 800; font-size: 1.15rem; color: #fff;">QUÁN VỪA CHỈ ĐỊNH BẠN GIAO ĐƠN!</h4>
                                    <p style="margin: 2px 0 0 0; font-size: 0.82rem; opacity: 0.95;">Quán đang đợi bạn bấm đồng ý nhận để bắt đầu chế biến món ăn.</p>
                                </div>
                            </div>
                            <span class="badge bg-white text-warning fw-bold px-3 py-2 rounded-pill shadow-sm" style="font-size: 0.85rem;">
                                ⏳ Chờ bạn phản hồi
                            </span>
                        </div>
                        <div style="padding: 24px;">
                            <div class="row g-3 mb-3">
                                <div class="col-md-4">
                                    <span class="text-muted small">Mã đơn hàng:</span>
                                    <div class="fw-bold fs-6 text-dark">#FZ-${pendingAssignedOrder.id}</div>
                                </div>
                                <div class="col-md-4">
                                    <span class="text-muted small">Khách nhận:</span>
                                    <div class="fw-bold fs-6 text-dark">${pendingAssignedOrder.customerName} (${pendingAssignedOrder.phone})</div>
                                </div>
                                <div class="col-md-4">
                                    <span class="text-muted small">Thu hộ COD:</span>
                                    <div class="fw-bold fs-5 text-danger"><fmt:formatNumber value="${pendingAssignedOrder.totalAmount}" pattern="#,###" /> đ</div>
                                </div>
                                <div class="col-12">
                                    <span class="text-muted small">Địa chỉ giao hàng:</span>
                                    <div class="fw-semibold text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> ${pendingAssignedOrder.address}</div>
                                </div>
                            </div>
                            <div class="d-flex gap-3 flex-wrap">
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="flex: 2; min-width: 220px;">
                                    <input type="hidden" name="action" value="acceptOrder">
                                    <input type="hidden" name="orderId" value="${pendingAssignedOrder.id}">
                                    <button type="submit" class="btn btn-success btn-lg w-100 py-3" style="border-radius: 50px; font-weight: 800; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.3);">
                                        <i class="fa-solid fa-check-double me-2"></i> ĐỒNG Ý NHẬN GIAO ĐƠN NÀY
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="flex: 1; min-width: 150px;" onsubmit="return confirm('Bạn có chắc muốn từ chối cuốc xe này? Quán sẽ gán tài xế khác.');">
                                    <input type="hidden" name="action" value="declineOrder">
                                    <input type="hidden" name="orderId" value="${pendingAssignedOrder.id}">
                                    <button type="submit" class="btn btn-outline-danger btn-lg w-100 py-3" style="border-radius: 50px; font-weight: 700;">
                                        <i class="fa-solid fa-xmark me-1"></i> Từ chối
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty activeOrder}">
                        <!-- CHI TIẾT ĐƠN HÀNG ĐANG GIAO & VÒNG ĐỜI -->
                        <div class="shipper-card" style="border: 2px solid #3b82f6;">
                            <div style="background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%); color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                <div>
                                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.9;">Đơn hàng đang thực hiện</span>
                                    <h3 style="margin: 2px 0 0 0; font-size: 1.35rem; font-weight: 800; color: #fff;">
                                        <i class="fa-solid fa-box-open me-2"></i> Mã đơn: #FZ-${activeOrder.id}
                                    </h3>
                                </div>
                                <div>
                                    <span style="background: rgba(255,255,255,0.25); backdrop-filter: blur(4px); padding: 6px 14px; border-radius: 50px; font-weight: 700; font-size: 0.85rem;">
                                        <i class="fa-solid fa-motorcycle me-1"></i> Đang vận chuyển
                                    </span>
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

                                    <!-- Lifecycle Action Buttons -->
                                    <div style="border-top: 1px dashed #e2e8f0; padding-top: 20px;">
                                        <div style="font-size: 0.9rem; font-weight: 700; color: #475569; margin-bottom: 12px;">
                                            <i class="fa-solid fa-list-check me-1"></i> Cập nhật tiến độ giao hàng:
                                        </div>
                                        <div style="display: flex; gap: 12px; flex-wrap: wrap; align-items: center;">
                                            <c:choose>
                                                <c:when test="${activeOrder.shipperDelivered}">
                                                    <div class="alert alert-success d-flex align-items-center gap-2 mb-0 w-100" style="border-radius: 12px; padding: 12px 18px;">
                                                        <i class="fa-solid fa-circle-check text-success fs-4"></i>
                                                        <div>
                                                            <div class="fw-bold">Bạn đã xác nhận giao hàng thành công!</div>
                                                            <div class="small text-muted">Đang chờ khách hàng xác nhận nhận món và chủ quán duyệt hoàn tất đơn. Tiền ship sẽ cập nhật vào ví khi hoàn tất.</div>
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <!-- Button 1: Đã lấy món -->
                                                    <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                                        <input type="hidden" name="action" value="updateOrder">
                                                        <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                        <input type="hidden" name="status" value="SHIPPING">
                                                        <button type="submit" class="btn btn-outline" style="border-radius: 50px; font-weight: 700; padding: 10px 20px;" onclick="alert('Đã cập nhật trạng thái: Đã lấy món từ quán và đang trên đường giao!');">
                                                            <i class="fa-solid fa-box text-primary me-1"></i> Đã lấy món
                                                        </button>
                                                    </form>

                                                    <!-- Button 2: Giao thành công & Xác nhận -->
                                                    <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                                        <input type="hidden" name="action" value="confirmDelivered">
                                                        <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                        <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 10px 24px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 12px rgba(16, 172, 132, 0.3);" onclick="return confirm('Xác nhận bạn đã giao món ăn tận nơi cho khách?');">
                                                            <i class="fa-solid fa-circle-check me-1"></i> Tôi Đã Giao Hàng Thành Công
                                                        </button>
                                                    </form>

                                                    <!-- Button 3: Khách boom hàng / Hủy -->
                                                    <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                                        <input type="hidden" name="action" value="updateOrder">
                                                        <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                        <input type="hidden" name="status" value="CANCELLED">
                                                        <button type="submit" class="btn btn-danger" style="border-radius: 50px; font-weight: 700; padding: 10px 20px; background: #fff; color: #dc2626; border-color: #fca5a5;" onclick="return confirm('Bạn xác nhận báo cáo đơn hàng này bị bom/hủy?');">
                                                            <i class="fa-solid fa-ban me-1"></i> Báo Hủy Đơn
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right Column: Leaflet GPS Map Navigation -->
                                <div style="flex: 1; min-width: 300px; padding: 24px; border-left: 1px solid #f1f5f9; background: #fafbfc;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                        <h4 style="margin: 0; font-size: 1rem; font-weight: 700; color: #1e293b;">
                                            <i class="fa-solid fa-location-crosshairs text-danger me-1"></i> Định vị lộ trình (GPS)
                                        </h4>
                                        <span id="gpsStatus" style="font-size: 0.75rem; color: #10ac84; font-weight: 600;"><i class="fa-solid fa-circle-notch fa-spin"></i> Đang tải GPS...</span>
                                    </div>

                                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                                    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

                                    <div id="mapTracker" style="width: 100%; height: 260px; border-radius: 12px; background: #e2e8f0; border: 1px solid #cbd5e1; position: relative;">
                                        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: #64748b; font-size: 0.88rem;">
                                            <i class="fa-solid fa-map-location-dot" style="font-size: 2rem; margin-bottom: 8px;"></i><br>
                                            Đang đồng bộ bản đồ vệ tinh...
                                        </div>
                                    </div>

                                    <script>
                                        setTimeout(function() {
                                            try {
                                                var map = L.map('mapTracker').setView([10.762622, 106.660172], 13);
                                                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                    attribution: '© Utee Express Map'
                                                }).addTo(map);

                                                var driverMarker = null;
                                                if (navigator.geolocation) {
                                                    navigator.geolocation.watchPosition(function(position) {
                                                        var lat = position.coords.latitude;
                                                        var lng = position.coords.longitude;
                                                        var gpsEl = document.getElementById('gpsStatus');
                                                        if (gpsEl) gpsEl.innerHTML = '<i class="fa-solid fa-signal text-success"></i> Tín hiệu GPS tốt';

                                                        if (!driverMarker) {
                                                            var shipperIcon = L.icon({
                                                                iconUrl: 'https://cdn-icons-png.flaticon.com/512/7592/7592236.png',
                                                                iconSize: [38, 38],
                                                                iconAnchor: [19, 19]
                                                            });
                                                            driverMarker = L.marker([lat, lng], {icon: shipperIcon}).addTo(map);
                                                            driverMarker.bindPopup("<b>Vị trí của bạn (Shipper)</b><br>Đang di chuyển...").openPopup();
                                                            map.setView([lat, lng], 15);
                                                        } else {
                                                            driverMarker.setLatLng([lat, lng]);
                                                        }
                                                    }, function(err) {
                                                        var gpsEl = document.getElementById('gpsStatus');
                                                        if (gpsEl) gpsEl.innerHTML = '<span class="text-muted">Chưa bật GPS</span>';
                                                    }, { enableHighAccuracy: true });
                                                }
                                            } catch(e) {
                                                console.error("Lỗi khởi tạo Leaflet map:", e);
                                            }
                                        }, 400);
                                    </script>
                                    <p style="font-size: 0.8rem; color: #94a3b8; margin: 10px 0 0 0; text-align: center;">
                                        *Hệ thống tự động đồng bộ vị trí của bạn với khách hàng qua GPS
                                    </p>
                                </div>
                            </div>
                        </div>
                    </c:when>

                    <c:when test="${driver.status eq 'AVAILABLE'}">
                        <!-- TÌM ĐƠN HÀNG MỚI (RADAR QUÉT ĐƠN) -->
                        <div class="shipper-card">
                            <div style="padding: 24px 24px 0 24px;">
                                <h3 style="margin: 0 0 6px 0; font-size: 1.25rem; font-weight: 800; color: #1e293b;">
                                    <i class="fa-solid fa-satellite-dish text-success me-2"></i> Trạm Điều Phối Tự Động
                                </h3>
                                <p style="margin: 0 0 20px 0; color: #64748b; font-size: 0.92rem;">
                                    Hệ thống phát tín hiệu radar liên tục 4 giây/lần để ghép đơn quanh vị trí của bạn.
                                </p>
                            </div>

                            <div style="padding: 0 24px 24px 24px;">
                                <!-- Radar Scanning Animation Box -->
                                <div id="radarScan" class="radar-box">
                                    <div class="radar-pulse-center">
                                        <i class="fa-solid fa-motorcycle"></i>
                                    </div>
                                    <h4 style="color: #065f46; font-weight: 800; margin-bottom: 6px;">Đang dò tìm đơn hàng mới trong bán kính 5km...</h4>
                                    <p id="radarStatus" style="color: #047857; margin: 0; font-size: 0.92rem;">
                                        Bạn đang ở chế độ Trực Tuyến. Vui lòng giữ trang web mở để chuông báo rung khi có đơn mới!
                                    </p>
                                </div>

                                <!-- New Order Popup Box (Hidden default, appears when dispatch found) -->
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
                        <!-- KHI DRIVER STATUS EQ 'OFFLINE' (CHẾ ĐỘ KHÁCH HÀNG) -->
                        <div class="shipper-card" style="text-align: center; padding: 50px 24px;">
                            <div style="width: 80px; height: 80px; border-radius: 50%; background: #f1f5f9; color: #64748b; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 20px auto;">
                                <i class="fa-solid fa-mug-hot"></i>
                            </div>
                            <h3 style="font-size: 1.4rem; font-weight: 800; color: #1e293b; margin-bottom: 8px;">
                                Bạn Đang Ngoại Tuyến (Chế Độ Khách Hàng)
                            </h3>
                            <p style="color: #64748b; max-width: 540px; margin: 0 auto 24px auto; font-size: 0.95rem; line-height: 1.6;">
                                Trong chế độ này, bạn không nhận đơn giao mà có thể thỏa thích dạo quanh thực đơn, thêm đồ ăn vào giỏ hàng và đặt món như một khách hàng bình thường.
                            </p>
                            <div style="display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;">
                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="GET" style="margin:0;">
                                    <input type="hidden" name="action" value="toggleStatus">
                                    <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; background: #10ac84; border-color: #10ac84;">
                                        <i class="fa-solid fa-power-off me-1"></i> Bật nhận đơn tài xế
                                    </button>
                                </form>
                                <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 12px 28px;">
                                    <i class="fa-solid fa-utensils me-1"></i> Khám phá món ngon ngay
                                </a>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <!-- ============================================================= -->
            <!-- CONDITIONAL TAB 2: DELIVERY HISTORY (activeTab eq 'history') -->
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
                                Danh sách các đơn bạn đã tiếp nhận giao (không bao gồm đơn bạn tự đặt ăn).
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

                                    <!-- Khách Hàng Đánh Giá Shipper (Review & Rating) -->
                                    <div class="trip-review-box">
                                        <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;">
                                            <div>
                                                <span style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-right: 8px;">
                                                    <i class="fa-solid fa-star text-warning me-1"></i> Đánh giá từ khách hàng:
                                                </span>
                                                <c:choose>
                                                    <c:when test="${not empty item.review}">
                                                        <span class="star-rating-display">
                                                            <c:forEach begin="1" end="${item.review.rating}">
                                                                <i class="fa-solid fa-star"></i>
                                                            </c:forEach>
                                                            <c:forEach begin="${item.review.rating + 1}" end="5">
                                                                <i class="fa-regular fa-star" style="color: #cbd5e1;"></i>
                                                            </c:forEach>
                                                        </span>
                                                        <strong style="color: #b45309; font-size: 0.95rem;">${item.review.rating}/5 sao</strong>
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

                                        <c:if test="${not empty item.review and not empty item.review.comment}">
                                            <p style="margin: 8px 0 0 0; font-size: 0.92rem; color: #334155; font-style: italic; background: #fff; padding: 8px 14px; border-radius: 8px; border: 1px dashed #e2e8f0;">
                                                <i class="fa-solid fa-quote-left text-muted me-1" style="font-size: 0.75rem;"></i>
                                                ${item.review.comment}
                                                <i class="fa-solid fa-quote-right text-muted ms-1" style="font-size: 0.75rem;"></i>
                                            </p>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
