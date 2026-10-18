<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Theo Dõi Trực Tiếp Đơn Hàng #FZ-${order.id} - Utee Express" />
</jsp:include>

<!-- Leaflet CSS & JS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

<style>
    .tracking-page-container {
        padding: 30px 15px 60px;
        background: #f8fafc;
        min-height: 85vh;
    }
    .tracking-card {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        border: 1px solid #e2e8f0;
        overflow: hidden;
    }
    .tracking-header {
        padding: 20px 24px;
        background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
        color: #ffffff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
    }
    .tracking-header h3 {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 700;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .live-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 4px 12px;
        border-radius: 50px;
        background: rgba(239, 68, 68, 0.2);
        color: #ef4444;
        font-size: 0.8rem;
        font-weight: 700;
        border: 1px solid rgba(239, 68, 68, 0.4);
    }
    .live-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #ef4444;
        animation: pulseDot 1.5s infinite;
    }
    @keyframes pulseDot {
        0% { transform: scale(0.9); opacity: 1; }
        50% { transform: scale(1.4); opacity: 0.5; }
        100% { transform: scale(0.9); opacity: 1; }
    }

    /* Live Map Container */
    #liveMap {
        width: 100%;
        height: 480px;
        background: #e5e7eb;
        z-index: 1;
    }

    /* Simulation Control Overlay */
    .sim-control-panel {
        background: #ffffff;
        padding: 16px 20px;
        border-top: 1px solid #e2e8f0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
    }
    .sim-speed-btn {
        padding: 4px 12px;
        border-radius: 6px;
        font-size: 0.8rem;
        border: 1px solid #cbd5e1;
        background: #fff;
        color: #475569;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.2s;
    }
    .sim-speed-btn.active {
        background: #f05454;
        color: #fff;
        border-color: #f05454;
    }

    /* Custom Leaflet Pulsing Markers */
    .pulse-marker-shop {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #10b981;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.3);
        font-size: 16px;
    }
    .pulse-marker-home {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #ef4444;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.3);
        font-size: 16px;
    }
    .pulse-marker-shipper {
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: #3b82f6;
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 0 6px rgba(59, 130, 246, 0.4);
        font-size: 20px;
        transition: transform 0.3s ease;
    }

    /* Step Timeline in Tracking Card */
    .tracking-status-bar {
        padding: 20px 24px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
    }
    .status-steps {
        display: flex;
        justify-content: space-between;
        position: relative;
    }
    .status-steps::before {
        content: '';
        position: absolute;
        top: 18px;
        left: 10%;
        right: 10%;
        height: 4px;
        background: #e2e8f0;
        z-index: 1;
    }
    .status-progress-fill {
        position: absolute;
        top: 18px;
        left: 10%;
        height: 4px;
        background: #10b981;
        z-index: 2;
        transition: width 0.5s ease;
    }
    .status-step-node {
        position: relative;
        z-index: 3;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        width: 25%;
    }
    .step-circle {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e2e8f0;
        color: #94a3b8;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        margin-bottom: 8px;
        border: 4px solid #fff;
        box-shadow: 0 2px 6px rgba(0,0,0,0.06);
    }
    .status-step-node.active .step-circle {
        background: #10b981;
        color: #fff;
    }
    .status-step-node.current .step-circle {
        background: #3b82f6;
        color: #fff;
        animation: pulseCircle 1.8s infinite;
    }
    @keyframes pulseCircle {
        0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
        70% { box-shadow: 0 0 0 10px rgba(59, 130, 246, 0); }
        100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
    }
    .step-label {
        font-size: 0.82rem;
        font-weight: 700;
        color: #475569;
    }
    .status-step-node.active .step-label {
        color: #0f172a;
    }

    /* Driver info bar */
    .driver-info-box {
        padding: 16px 20px;
        background: #f0f9ff;
        border-radius: 12px;
        border: 1px solid #bae6fd;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 20px;
    }

    /* ETA big badge */
    .eta-box {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 18px;
        background: #ecfdf5;
        border-radius: 12px;
        border: 1px solid #a7f3d0;
    }
    .eta-time {
        font-size: 1.6rem;
        font-weight: 900;
        color: #059669;
        line-height: 1;
    }
</style>

<div class="tracking-page-container">
    <div class="container">
        <!-- Breadcrumb & Back -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <a href="${pageContext.request.contextPath}/client/orders" class="text-decoration-none text-muted fw-semibold">
                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại lịch sử đơn hàng
                </a>
            </div>
            <div>
                <span class="text-muted small">Mã tra cứu:</span> 
                <strong class="text-danger">#FZ-${order.id}</strong>
            </div>
        </div>

        <c:if test="${param.success eq 'confirmed'}">
            <!-- Alert Banner chúc mừng giao hàng thành công -->
            <div class="alert alert-success d-flex align-items-center justify-content-between p-3 rounded-4 mb-4 shadow-sm" style="background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%); border: 1px solid #10b981; color: #065f46;">
                <div class="d-flex align-items-center gap-3">
                    <div style="width: 44px; height: 44px; border-radius: 50%; background: #10b981; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; flex-shrink: 0;">
                        <i class="fa-solid fa-check"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-1" style="color: #065f46;">Giao Hàng Hoàn Tất!</h5>
                        <p class="mb-0 small" style="color: #047857;">Cảm ơn bạn đã xác nhận đã nhận đủ món. Chúc bạn có một bữa ăn ngon miệng!</p>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/order-review?orderId=${order.id}" class="btn btn-success fw-bold px-3 py-2 rounded-pill shadow-sm" style="white-space: nowrap; background: #059669; border: none;">
                        <i class="fa-solid fa-star text-warning me-1"></i> Viết đánh giá
                    </a>
                </div>
            </div>

            <!-- Popup Modal Chúc Mừng & Mời Đánh Giá Đơn Hàng -->
            <div id="deliveredSuccessModal" class="modal-overlay active" onclick="if(event.target===this) this.classList.remove('active');">
                <div class="modal-content" style="border-radius: 24px; padding: 32px 28px; max-width: 480px; box-shadow: 0 20px 40px rgba(0,0,0,0.2);">
                    <div class="success-icon-wrap" style="color: #10b981; font-size: 4rem; margin-bottom: 12px;">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <h3 class="fw-bold text-dark mb-2">Đã Nhận Món Thành Công!</h3>
                    <p class="modal-sub mb-3" style="font-size: 0.95rem; color: #64748b;">
                        Đơn hàng <strong>#FZ-${order.id}</strong> đã được giao tận tay bạn. Chúc bạn có một bữa ăn thật ngon miệng cùng Utee!
                    </p>

                    <div class="p-3 rounded-4 mb-4 text-start" style="background: #f8fafc; border: 1px solid #e2e8f0;">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted small">Quán ăn:</span>
                            <strong class="text-dark small">${not empty order.restaurantName ? order.restaurantName : 'Nhà hàng Utee Store'}</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span class="text-muted small">Tài xế giao hàng:</span>
                            <strong class="text-dark small">${not empty order.driverName ? order.driverName : 'Shipper Utee'}</strong>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span class="text-muted small">Tổng thanh toán:</span>
                            <strong class="text-danger small"><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0" /></strong>
                        </div>
                    </div>

                    <div class="d-flex flex-column gap-2">
                        <a href="${pageContext.request.contextPath}/order-review?orderId=${order.id}" class="btn btn-danger fw-bold py-2 rounded-pill shadow-sm" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); border: none;">
                            <i class="fa-solid fa-star text-warning me-1"></i> Viết Đánh Giá Ngay (Tặng Voucher)
                        </a>
                        <button type="button" class="btn btn-light rounded-pill py-2 fw-semibold text-muted" onclick="document.getElementById('deliveredSuccessModal').classList.remove('active');">
                            Xem Bản Đồ Lộ Trình / Đóng
                        </button>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${param.error eq 'wait_shipper_pickup' or param.error eq 'wait_shipper_delivery' or param.error eq 'shipper_not_delivered' or param.error eq 'confirm_failed'}">
            <div class="alert alert-warning alert-dismissible fade show mb-4 shadow-sm" role="alert" style="border-radius: 12px; border-left: 5px solid #f59e0b; background: #fffbeb;">
                <div class="d-flex align-items-center gap-3">
                    <i class="fa-solid fa-triangle-exclamation text-warning fs-4"></i>
                    <div>
                        <strong class="d-block text-dark">Chưa thể xác nhận đơn hàng!</strong>
                        <small class="text-secondary">
                            <c:choose>
                                <c:when test="${param.error eq 'wait_shipper_pickup'}">
                                    Tài xế shipper chưa lấy món từ quán. Bạn chỉ có thể xác nhận sau khi shipper đã lấy món từ quán!
                                </c:when>
                                <c:otherwise>
                                    Không thể thực hiện xác nhận vào lúc này. Vui lòng kiểm tra lại trạng thái đơn hàng của bạn.
                                </c:otherwise>
                            </c:choose>
                        </small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="row g-4">
            <!-- Left Column: Live Map + Simulation Controller -->
            <div class="col-lg-8">
                <div class="tracking-card">
                    <div class="tracking-header">
                        <div>
                            <h3><i class="fa-solid fa-map-location-dot text-danger"></i> Bản Đồ Hành Trình Shipper</h3>
                            <small class="text-white-50">Lộ trình OpenStreetMap &amp; Mô phỏng GPS thời gian thực</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="live-badge">
                                <span class="live-dot"></span> LIVE GPS SIMULATOR
                            </span>
                        </div>
                    </div>

                    <!-- Map Container -->
                    <div id="liveMap"></div>

                    <!-- Simulator Controls -->
                    <div class="sim-control-panel">
                        <div class="d-flex align-items-center gap-2">
                            <button id="btnPlayPause" class="btn btn-sm btn-outline-danger fw-bold" onclick="toggleSimulation()">
                                <i class="fa-solid fa-pause me-1"></i> Tạm Dừng
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="restartSimulation()" title="Mô phỏng lại từ đầu">
                                <i class="fa-solid fa-rotate-left"></i> Chạy Lại
                            </button>
                            <span class="text-muted small ms-2 d-none d-sm-inline">Tốc độ chạy:</span>
                            <div class="btn-group btn-group-sm">
                                <button type="button" class="sim-speed-btn" onclick="setSpeed(1, this)">1x</button>
                                <button type="button" class="sim-speed-btn active" onclick="setSpeed(3, this)">3x</button>
                                <button type="button" class="sim-speed-btn" onclick="setSpeed(6, this)">6x</button>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3">
                            <span class="text-muted small">
                                Đã đi: <strong id="simProgressText" class="text-primary">0%</strong>
                            </span>
                            <span class="text-muted small">
                                Vận tốc: <strong id="simSpeedKmh" class="text-success">35 km/h</strong>
                            </span>
                        </div>
                    </div>

                    <!-- Timeline Progress -->
                    <div class="tracking-status-bar">
                        <div class="status-steps">
                            <div class="status-progress-fill" id="statusProgressFill" style="width: ${order.status eq 'DELIVERED' or order.customerConfirmed ? '100%' : '66%'};"></div>

                            <div class="status-step-node active" id="step1">
                                <div class="step-circle"><i class="fa-solid fa-receipt"></i></div>
                                <span class="step-label">Đã Nhận Đơn</span>
                            </div>
                            <div class="status-step-node active" id="step2">
                                <div class="step-circle"><i class="fa-solid fa-utensils"></i></div>
                                <span class="step-label">Quán Chuẩn Bị</span>
                            </div>
                            <div class="status-step-node ${order.status eq 'DELIVERED' or order.customerConfirmed ? 'active' : 'current'}" id="step3">
                                <div class="step-circle"><i class="fa-solid fa-motorcycle"></i></div>
                                <span class="step-label" id="step3Label">${order.status eq 'DELIVERED' or order.customerConfirmed ? 'Đã Giao Tới' : 'Đang Giao Tới Bạn'}</span>
                            </div>
                            <div class="status-step-node ${order.status eq 'DELIVERED' or order.customerConfirmed ? 'active' : ''}" id="step4">
                                <div class="step-circle"><i class="fa-solid fa-box-check"></i></div>
                                <span class="step-label">Giao Thành Công</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Driver Details + Route Summary + Order Details -->
            <div class="col-lg-4">
                <!-- Driver Info Card -->
                <div class="tracking-card p-3 mb-3">
                    <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
                        <span class="fw-bold text-dark"><i class="fa-solid fa-id-badge text-primary me-2"></i>Tài Xế Giao Hàng</span>
                        <c:choose>
                            <c:when test="${order.status eq 'DELIVERED' or order.customerConfirmed}">
                                <span class="badge bg-success text-white px-2 py-1 rounded-pill"><i class="fa-solid fa-circle-check me-1"></i>Đã giao thành công</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-success-subtle text-success px-2 py-1 rounded-pill">Đang di chuyển</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="d-flex align-items-center gap-3">
                        <div style="width: 52px; height: 52px; border-radius: 50%; background: linear-gradient(135deg, #3b82f6, #1d4ed8); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; font-weight: 800; flex-shrink: 0;">
                            <i class="fa-solid fa-user-ninja"></i>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="mb-0 fw-bold text-dark">${not empty order.driverName ? order.driverName : 'Nguyễn Văn Tài (Shipper Utee)'}</h6>
                            <small class="text-muted d-block"><i class="fa-solid fa-phone text-success me-1"></i>${not empty order.driverPhone ? order.driverPhone : '0912 345 678'}</small>
                            <small class="text-warning"><i class="fa-solid fa-star"></i> 4.9 (420+ chuyến xe)</small>
                        </div>
                        <div>
                            <a href="tel:${not empty order.driverPhone ? order.driverPhone : '0912345678'}" class="btn btn-outline-success btn-sm rounded-circle p-2" title="Gọi điện">
                                <i class="fa-solid fa-phone-volume"></i>
                            </a>
                        </div>
                    </div>

                    <div class="eta-box mt-3">
                        <div style="font-size: 1.8rem; color: #059669;"><i class="fa-solid fa-stopwatch"></i></div>
                        <div>
                            <small class="text-muted text-uppercase fw-bold" style="font-size: 0.72rem;">Thời gian dự kiến còn</small>
                            <div class="eta-time" id="etaTimeDisplay">${order.status eq 'DELIVERED' or order.customerConfirmed ? 'Đã đến nơi!' : '8 - 12 phút'}</div>
                        </div>
                    </div>
                </div>

                <!-- Locations & Route Info -->
                <div class="tracking-card p-3 mb-3">
                    <h6 class="fw-bold mb-3 pb-2 border-bottom text-dark">
                        <i class="fa-solid fa-route text-danger me-2"></i>Hành Trình Giao Hàng
                    </h6>
                    
                    <!-- Point A: Restaurant -->
                    <div class="d-flex align-items-start gap-3 mb-3">
                        <div style="width: 28px; height: 28px; border-radius: 50%; background: #d1fae5; color: #059669; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 0.85rem; font-weight: 700;">
                            A
                        </div>
                        <div>
                            <strong class="text-dark d-block" style="font-size: 0.95rem;">${not empty order.restaurantName ? order.restaurantName : 'Quán Ăn Utee Store'}</strong>
                            <small class="text-muted">${not empty order.restaurantAddress ? order.restaurantAddress : 'Số 01 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức'}</small>
                        </div>
                    </div>

                    <!-- Route connector dots -->
                    <div style="border-left: 2px dashed #cbd5e1; margin-left: 13px; height: 20px;"></div>

                    <!-- Point B: Customer Home -->
                    <div class="d-flex align-items-start gap-3 mt-1">
                        <div style="width: 28px; height: 28px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 0.85rem; font-weight: 700;">
                            B
                        </div>
                        <div>
                            <strong class="text-dark d-block" style="font-size: 0.95rem;">Giao đến: ${order.customerName}</strong>
                            <small class="text-muted">${order.address}</small>
                            <small class="text-primary d-block mt-1">
                                <i class="fa-solid fa-signs-post me-1"></i> Cự ly: <strong>${order.distanceKm != null ? order.distanceKm : 2.0} km</strong>
                            </small>
                        </div>
                    </div>
                </div>

                <!-- Action Confirmation -->
                <div class="tracking-card p-3">
                    <h6 class="fw-bold mb-2 text-dark">Trạng Thái Đơn Hàng</h6>
                    <p class="text-muted small mb-3">
                        Khi shipper giao đến nơi và bạn đã nhận đầy đủ món ăn, hãy bấm xác nhận để hoàn tất đơn hàng.
                    </p>

                    <c:choose>
                        <c:when test="${order.customerConfirmed}">
                            <div class="p-2 text-center bg-success-subtle text-success rounded-3 fw-bold mb-2">
                                <i class="fa-solid fa-circle-check me-1"></i> Bạn đã nhận món thành công!
                            </div>
                            <a href="${pageContext.request.contextPath}/order-review?orderId=${order.id}" class="btn btn-outline-danger w-100 btn-sm fw-bold">
                                <i class="fa-solid fa-star me-1"></i> Viết đánh giá quán &amp; shipper
                            </a>
                        </c:when>
                        <c:when test="${order.status ne 'CANCELLED' and (order.shipperPickedUp or order.shipperDelivered or order.status eq 'DELIVERED')}">
                            <c:choose>
                                <c:when test="${order.shipperDelivered or order.status eq 'DELIVERED'}">
                                    <div class="p-2 text-center bg-warning-subtle text-dark rounded-3 small fw-semibold mb-3 border border-warning">
                                        <i class="fa-solid fa-bell text-warning me-1"></i> Shipper đã giao món đến nơi! Vui lòng kiểm tra món và bấm xác nhận bên dưới.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="p-2 text-center bg-light text-muted rounded-3 small mb-3 border">
                                        <i class="fa-solid fa-motorcycle text-primary me-1"></i> Shipper đã lấy món từ quán và đang trên đường giao đến bạn. Khi nhận được món, hãy bấm xác nhận bên dưới.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <form action="${pageContext.request.contextPath}/order/tracking" method="POST" id="confirmReceivedForm">
                                <input type="hidden" name="action" value="confirm_received">
                                <input type="hidden" name="orderId" value="${order.id}">
                                <button type="submit" class="btn btn-success w-100 fw-bold py-2 shadow-sm" id="btnConfirmReceived" title="Xác nhận bạn đã nhận được món ăn từ shipper">
                                    <i class="fa-solid fa-hand-holding-heart me-1"></i> Đã Nhận Được Món Ăn
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div class="p-3 text-center bg-light rounded-3 text-muted mb-2 border">
                                <div class="mb-1 text-secondary fw-bold">
                                    <i class="fa-solid fa-clock me-1"></i>
                                    <c:choose>
                                        <c:when test="${not empty order.driverName}">
                                            Shipper đang di chuyển đến quán lấy món
                                        </c:when>
                                        <c:otherwise>
                                            Đơn hàng đang được xử lý
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <small class="text-secondary d-block">
                                    <c:choose>
                                        <c:when test="${not empty order.driverName}">
                                            Tài xế <strong>${order.driverName}</strong> đang đến quán. Bạn chỉ có thể xác nhận sau khi shipper đã lấy món từ quán.
                                        </c:when>
                                        <c:otherwise>
                                            Vui lòng đợi nhà hàng tiếp nhận và bàn giao món cho tài xế.
                                        </c:otherwise>
                                    </c:choose>
                                </small>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<!-- MAP SIMULATION SCRIPT -->
<script>
    // 1. Tọa độ Quán ăn (Điểm A) & Khách hàng (Điểm B)
    const restaurantCoords = [
        ${order.restaurantLatitude != null ? order.restaurantLatitude : 10.8505},
        ${order.restaurantLongitude != null ? order.restaurantLongitude : 106.7719}
    ];
    const customerCoords = [
        ${order.customerLatitude != null ? order.customerLatitude : 10.8546},
        ${order.customerLongitude != null ? order.customerLongitude : 106.7583}
    ];

    // Trạng thái đơn ban đầu từ server
    const isOrderAlreadyDelivered = ${order.status eq 'DELIVERED' or order.customerConfirmed};

    // 2. Khởi tạo Leaflet Map
    const map = L.map('liveMap', {
        zoomControl: true,
        scrollWheelZoom: true
    }).setView(restaurantCoords, 14);

    // Sử dụng OpenStreetMap tiles miễn phí
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    // 3. Custom HTML Icons
    const shopIcon = L.divIcon({
        className: 'custom-map-icon',
        html: '<div class="pulse-marker-shop"><i class="fa-solid fa-store"></i></div>',
        iconSize: [36, 36],
        iconAnchor: [18, 18]
    });

    const homeIcon = L.divIcon({
        className: 'custom-map-icon',
        html: '<div class="pulse-marker-home"><i class="fa-solid fa-location-dot"></i></div>',
        iconSize: [36, 36],
        iconAnchor: [18, 18]
    });

    const shipperIcon = L.divIcon({
        className: 'custom-map-icon',
        html: '<div class="pulse-marker-shipper" id="shipperPinIcon"><i class="fa-solid fa-motorcycle"></i></div>',
        iconSize: [44, 44],
        iconAnchor: [22, 22]
    });

    // Thêm Marker Quán & Nhà Khách
    const markerShop = L.marker(restaurantCoords, { icon: shopIcon }).addTo(map)
        .bindPopup('<b>Quán ăn:</b> ${not empty order.restaurantName ? order.restaurantName : "Cửa hàng Utee"}<br>${order.restaurantAddress}');
    
    const markerHome = L.marker(customerCoords, { icon: homeIcon }).addTo(map)
        .bindPopup('<b>Giao đến:</b> ${order.customerName}<br>${order.address}');

    // Marker Shipper
    let markerShipper = L.marker(restaurantCoords, { icon: shipperIcon, zIndexOffset: 1000 }).addTo(map)
        .bindPopup('<b>Shipper Utee:</b> ${not empty order.driverName ? order.driverName : "Nguyễn Văn Tài"}<br>Đang vận chuyển');

    // Tự động căn góc nhìn bao quát cả quán và nhà khách
    const bounds = L.latLngBounds([restaurantCoords, customerCoords]);
    map.fitBounds(bounds, { padding: [50, 50] });

    // 4. Biến điều khiển Simulation
    let routeCoords = []; // Danh sách tọa độ các khúc cua OSRM
    let routePolyline = null;
    let traveledPolyline = null; // Đoạn đường shipper đã đi qua
    let currentStepIndex = 0;
    let simInterval = null;
    let isPlaying = true;
    let simSpeedMultiplier = 3; // 3x
    const stepDurationMs = 500; // Mỗi 500ms nhảy 1 bước

    // 5. Gọi OSRM Routing API để lấy lộ trình đường đi thực tế
    async function fetchRoutingOSRM() {
        // OSRM format: lng,lat;lng,lat
        const url = `https://router.project-osrm.org/route/v1/driving/` +
                    `${restaurantCoords[1]},${restaurantCoords[0]};${customerCoords[1]},${customerCoords[0]}` +
                    `?overview=full&geometries=geojson`;

        try {
            const resp = await fetch(url);
            const data = await resp.json();
            if (data.code === 'Ok' && data.routes && data.routes.length > 0) {
                // GeoJSON trả về [lng, lat], Leaflet cần [lat, lng]
                const rawCoords = data.routes[0].geometry.coordinates.map(c => [c[1], c[0]]);
                // Làm mịn mượt các đoạn đường thẳng bằng nội suy
                routeCoords = interpolateRoute(rawCoords, 80);
            } else {
                fallbackLinearRoute();
            }
        } catch (err) {
            console.warn('Lỗi gọi OSRM, kích hoạt chế độ fallback đường thẳng:', err);
            fallbackLinearRoute();
        }

        setupRouteAndStart();
    }

    // Fallback nếu mất mạng ngoài không gọi được OSRM
    function fallbackLinearRoute() {
        const steps = 60;
        routeCoords = [];
        for (let i = 0; i <= steps; i++) {
            const t = i / steps;
            const lat = restaurantCoords[0] + (customerCoords[0] - restaurantCoords[0]) * t;
            const lng = restaurantCoords[1] + (customerCoords[1] - restaurantCoords[1]) * t;
            routeCoords.push([lat, lng]);
        }
    }

    // Hàm nội suy (interpolation) để xe di chuyển siêu mượt, không bị giật
    function interpolateRoute(points, totalSteps) {
        if (points.length < 2) return points;
        const result = [];
        const segSteps = Math.max(1, Math.floor(totalSteps / (points.length - 1)));
        
        for (let i = 0; i < points.length - 1; i++) {
            const p1 = points[i];
            const p2 = points[i + 1];
            for (let s = 0; s < segSteps; s++) {
                const t = s / segSteps;
                result.push([
                    p1[0] + (p2[0] - p1[0]) * t,
                    p1[1] + (p2[1] - p1[1]) * t
                ]);
            }
        }
        result.push(points[points.length - 1]);
        return result;
    }

    // 6. Vẽ đường đi và bắt đầu mô phỏng
    function setupRouteAndStart() {
        // Vẽ toàn bộ tuyến đường (màu xám / viền xanh)
        routePolyline = L.polyline(routeCoords, {
            color: '#3b82f6',
            weight: 5,
            opacity: 0.5,
            dashArray: '8, 8'
        }).addTo(map);

        // Vẽ đoạn đường shipper đã đi (màu xanh lá đậm)
        traveledPolyline = L.polyline([], {
            color: '#10b981',
            weight: 6,
            opacity: 0.9
        }).addTo(map);

        if (isOrderAlreadyDelivered) {
            // Nếu đơn đã hoàn thành trước đó: đặt shipper ở ngay đích
            currentStepIndex = routeCoords.length - 1;
            markerShipper.setLatLng(customerCoords);
            traveledPolyline.setLatLngs(routeCoords);
            updateUIOnArrive();
        } else {
            startSimulation();
        }
    }

    function startSimulation() {
        if (simInterval) clearInterval(simInterval);
        isPlaying = true;
        document.getElementById('btnPlayPause').innerHTML = '<i class="fa-solid fa-pause me-1"></i> Tạm Dừng';

        const intervalTime = Math.max(80, Math.floor(stepDurationMs / simSpeedMultiplier));

        simInterval = setInterval(() => {
            if (currentStepIndex >= routeCoords.length - 1) {
                clearInterval(simInterval);
                updateUIOnArrive();
                return;
            }

            currentStepIndex++;
            const currentPos = routeCoords[currentStepIndex];
            const prevPos = routeCoords[currentStepIndex - 1];

            // Di chuyển marker shipper
            markerShipper.setLatLng(currentPos);

            // Cập nhật góc quay icon theo hướng di chuyển
            const angle = getBearingAngle(prevPos, currentPos);
            const pinIcon = document.getElementById('shipperPinIcon');
            if (pinIcon) {
                // Xoay nhẹ góc phương tiện nếu muốn
                // pinIcon.style.transform = `rotate(${angle}deg)`;
            }

            // Vẽ tiếp vệt đường màu xanh lá đã đi qua
            traveledPolyline.setLatLngs(routeCoords.slice(0, currentStepIndex + 1));

            // Tính toán % tiến độ
            const percent = Math.round((currentStepIndex / (routeCoords.length - 1)) * 100);
            document.getElementById('simProgressText').innerText = percent + '%';

            // Tính thời gian ETA ước tính còn lại
            const remainingSteps = routeCoords.length - 1 - currentStepIndex;
            const etaMinutes = Math.max(1, Math.round((remainingSteps / routeCoords.length) * 12));
            document.getElementById('etaTimeDisplay').innerText = etaMinutes + ' phút';

        }, intervalTime);
    }

    // Tính góc xoay giữa 2 điểm
    function getBearingAngle(start, end) {
        const lat1 = start[0] * Math.PI / 180;
        const lat2 = end[0] * Math.PI / 180;
        const dLng = (end[1] - start[1]) * Math.PI / 180;
        const y = Math.sin(dLng) * Math.cos(lat2);
        const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLng);
        const brng = Math.atan2(y, x) * 180 / Math.PI;
        return (brng + 360) % 360;
    }

    function toggleSimulation() {
        if (isPlaying) {
            clearInterval(simInterval);
            isPlaying = false;
            document.getElementById('btnPlayPause').innerHTML = '<i class="fa-solid fa-play me-1"></i> Tiếp Tục';
        } else {
            if (currentStepIndex >= routeCoords.length - 1) {
                restartSimulation();
            } else {
                startSimulation();
            }
        }
    }

    function restartSimulation() {
        clearInterval(simInterval);
        currentStepIndex = 0;
        markerShipper.setLatLng(routeCoords[0]);
        traveledPolyline.setLatLngs([]);
        document.getElementById('simProgressText').innerText = '0%';
        document.getElementById('etaTimeDisplay').innerText = '12 phút';
        document.getElementById('statusProgressFill').style.width = '66%';
        document.getElementById('step3').classList.add('current');
        document.getElementById('step4').classList.remove('active');
        document.getElementById('step3Label').innerText = 'Đang Giao Tới Bạn';
        startSimulation();
    }

    function setSpeed(speed, btnElement) {
        simSpeedMultiplier = speed;
        document.querySelectorAll('.sim-speed-btn').forEach(b => b.classList.remove('active'));
        btnElement.classList.add('active');
        document.getElementById('simSpeedKmh').innerText = (speed * 15 + 15) + ' km/h';
        if (isPlaying) {
            startSimulation();
        }
    }

    // Khi shipper đã chạm đích (nhà khách hàng)
    function updateUIOnArrive() {
        document.getElementById('simProgressText').innerText = '100%';
        document.getElementById('etaTimeDisplay').innerText = 'Đã đến nơi!';
        document.getElementById('statusProgressFill').style.width = '100%';
        document.getElementById('step3').classList.remove('current');
        document.getElementById('step3').classList.add('active');
        document.getElementById('step4').classList.add('active');
        document.getElementById('step3Label').innerText = 'Đã Giao Tới';
        
        markerShipper.bindPopup('<b>Shipper đã đến!</b><br>Vui lòng nhận món và kiểm tra đơn.').openPopup();

        // Rung nhẹ nút xác nhận nhận món để gây chú ý
        const btnConfirm = document.getElementById('btnConfirmReceived');
        if (btnConfirm) {
            btnConfirm.classList.add('btn-lg');
            btnConfirm.style.animation = 'pulseCircle 1s infinite';
        }
    }

    // Kích hoạt nạp route khi trang load xong
    document.addEventListener('DOMContentLoaded', fetchRoutingOSRM);
</script>
