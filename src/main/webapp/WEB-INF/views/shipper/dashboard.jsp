<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="${activeTab eq 'history' ? 'Lịch Sử Chuyến Xe - Đối Tác Tài Xế Utee' : (activeTab eq 'income' ? 'Thu Nhập & Ví Tiền - Đối Tác Tài Xế Utee' : (activeTab eq 'violations' ? 'Điểm Vi Phạm & Tác Phong - Utee Express' : (activeTab eq 'settings' ? 'Cài Đặt Hoạt Động - Utee Express' : (activeTab eq 'help' ? 'Trung Tâm Trợ Giúp Tài Xế - Utee Express' : 'Bảng Điều Khiển Tài Xế - Utee Express'))))}" />
</jsp:include>

<div class="admin-dashboard-container shipper-portal-container"
     id="shipperPortalRoot"
     data-driver-status="${driver.status}"
     data-csrf-token="${sessionScope.csrfToken}"
     data-context-path="${pageContext.request.contextPath}">
    <!-- ================================================================= -->
    <!-- 1. TOP SHIPPER PORTAL HEADER (ĐỒNG BỘ VỚI MERCHANT & TOÀN WEB)   -->
    <!-- ================================================================= -->
    <div class="shipper-portal-header">
        <div class="container">
            <!-- App Bar: Hồ Sơ Tài Xế & Nút Bật/Tắt Nhận Đơn -->
            <div class="shipper-app-bar">
                <div class="shipper-profile-wrap">
                    <div class="shipper-avatar-wrap">
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser.avatar}">
                                <img src="${sessionScope.currentUser.avatar.startsWith('http') || sessionScope.currentUser.avatar.startsWith('/') ? (sessionScope.currentUser.avatar.startsWith('/') ? pageContext.request.contextPath.concat(sessionScope.currentUser.avatar) : sessionScope.currentUser.avatar) : pageContext.request.contextPath.concat('/').concat(sessionScope.currentUser.avatar)}" 
                                     alt="${sessionScope.currentUser.fullName}" 
                                     class="shipper-avatar-img"
                                     onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='inline-flex';" />
                                <span style="display: none;">${sessionScope.currentUser.fullName.substring(0, 1).toUpperCase()}</span>
                            </c:when>
                            <c:when test="${not empty sessionScope.currentUser.fullName}">
                                <span>${sessionScope.currentUser.fullName.substring(0, 1).toUpperCase()}</span>
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-motorcycle"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="shipper-info-box">
                        <div class="shipper-meta-top">
                            <span class="shipper-badge-partner">
                                <i class="fa-solid fa-certificate"></i> Đối Tác Tài Xế Utee
                            </span>
                            <c:choose>
                                <c:when test="${driver.status eq 'AVAILABLE'}">
                                    <span class="shipper-status-badge status-online">
                                        <span class="dot-pulse"></span>
                                        <span>Đang Trực Tuyến</span>
                                    </span>
                                </c:when>
                                <c:when test="${driver.status eq 'BUSY'}">
                                    <span class="shipper-status-badge status-busy">
                                        <span class="dot-pulse" style="background: #f59e0b; box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.7);"></span>
                                        <span>Đang Giao Hàng</span>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="shipper-status-badge status-offline">
                                        <span class="dot-pulse" style="background: #94a3b8; box-shadow: none;"></span>
                                        <span>Đang Ngoại Tuyến</span>
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <h1 class="shipper-name-title">
                            <span>${sessionScope.currentUser.fullName}</span>
                            <span class="badge" style="background: #fff8e1; border: 1px solid #ffe082; color: #b45309; font-size: 0.8rem; font-weight: 700; padding: 3px 10px; border-radius: 20px;">
                                <i class="fa-solid fa-star text-warning"></i> ${driverRatingStats != null ? driverRatingStats['avgRating'] : 5.0} / 5.0
                            </span>
                        </h1>

                        <div class="shipper-meta-sub">
                            <span class="shipper-sub-item">
                                <i class="fa-solid fa-phone text-muted"></i> ${sessionScope.currentUser.phone}
                            </span>
                            <span class="shipper-sub-item">
                                <i class="fa-solid fa-id-card text-muted"></i> ID: #${sessionScope.currentUser.id}
                            </span>
                            <span class="shipper-sub-item">
                                <i class="fa-solid fa-motorcycle text-primary"></i> ${not empty driver.licensePlate ? driver.licensePlate : '59-X3 999.99'}
                            </span>
                            <span class="shipper-sub-item text-success font-weight-bold">
                                <i class="fa-solid fa-shield-check"></i> Đã xác thực
                            </span>
                        </div>
                    </div>
                </div>

                <div class="shipper-header-actions">
                    <button type="button" onclick="window.location.reload();" class="btn btn-outline-secondary" style="border-radius: 12px; font-weight: 700; padding: 10px 16px; border: 1px solid #cbd5e1; background: #fff;" title="Cập nhật nhanh dữ liệu">
                        <i class="fa-solid fa-rotate-right"></i>
                    </button>

                    <c:choose>
                        <c:when test="${driver.status eq 'BUSY'}">
                            <button type="button" class="btn-shipper-status-toggle status-toggle-busy" disabled title="Bạn đang giao đơn hàng, hoàn thành đơn trước khi tắt nhận đơn">
                                <i class="fa-solid fa-lock"></i>
                                <span>Đang Bận Giao Đơn</span>
                            </button>
                        </c:when>
                        <c:when test="${driver.status eq 'AVAILABLE'}">
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn-shipper-status-toggle status-toggle-close" title="Bấm để tắt nhận đơn và chuyển sang ngoại tuyến">
                                    <i class="fa-solid fa-power-off"></i>
                                    <span>Tắt Nhận Đơn</span>
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn-shipper-status-toggle status-toggle-open" title="Bấm để bật chế độ nhận đơn quanh khu vực">
                                    <i class="fa-solid fa-bolt"></i>
                                    <span>Bật Nhận Đơn Ngay</span>
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Modern Floating Navigation Tabs Bar (6 Balanced Tabs) -->
            <div class="shipper-tabs-bar">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="shipper-tab-btn ${activeTab eq 'dispatch' or empty activeTab ? 'active' : ''}">
                    <i class="fa-solid fa-gauge-high"></i>
                    <span>Nhận đơn</span>
                    <c:if test="${not empty activeOrders}">
                        <span class="shipper-tab-badge" style="background: #2563eb; color: #fff;">${activeOrders.size()} đang giao</span>
                    </c:if>
                    <c:if test="${empty activeOrders and not empty pendingAssignedOrders}">
                        <span class="shipper-tab-badge" style="background: #f59e0b; color: #fff;">${pendingAssignedOrders.size()} chờ</span>
                    </c:if>
                </a>

                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=income" class="shipper-tab-btn ${activeTab eq 'income' ? 'active' : ''}">
                    <i class="fa-solid fa-wallet"></i>
                    <span>Thu nhập &amp; Ví</span>
                    <c:if test="${not empty earnings and earnings.todayEarnings > 0}">
                        <span class="shipper-tab-badge" style="background: #dcfce7; color: #15803d;"><fmt:formatNumber value="${earnings.todayEarnings}" pattern="#,###" />đ</span>
                    </c:if>
                </a>

                <a href="${pageContext.request.contextPath}/shipper/history" class="shipper-tab-btn ${activeTab eq 'history' ? 'active' : ''}">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    <span>Lịch sử chuyến</span>
                    <c:if test="${totalDeliveryCount > 0}">
                        <span class="shipper-tab-badge">${totalDeliveryCount}</span>
                    </c:if>
                </a>

                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=violations" class="shipper-tab-btn ${activeTab eq 'violations' ? 'active' : ''}">
                    <i class="fa-solid fa-shield-halved"></i>
                    <span>Điểm vi phạm</span>
                    <span class="shipper-tab-badge" style="background: #ecfdf5; color: #059669;">100đ</span>
                </a>

                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=settings" class="shipper-tab-btn ${activeTab eq 'settings' ? 'active' : ''}">
                    <i class="fa-solid fa-gear"></i>
                    <span>Cài đặt</span>
                </a>

                <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=help" class="shipper-tab-btn ${activeTab eq 'help' ? 'active' : ''}">
                    <i class="fa-solid fa-circle-question"></i>
                    <span>Trợ giúp</span>
                </a>
            </div>
        </div>
    </div>

    <!-- ================================================================= -->
    <!-- 2. MAIN CONTAINER: 4 KPI METRIC STAT CARDS & FEEDBACK NOTICES     -->
    <!-- ================================================================= -->
    <div class="container pb-5" style="margin-top: 18px;">
        <!-- Feedback Alert Messages -->
        <c:if test="${param.warning eq 'shipper_mode_active'}">
            <div class="alert alert-warning" style="border-radius: 14px; margin-bottom: 20px; padding: 16px 20px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; border-left: 5px solid #f59e0b; background: #fffbeb;">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.5rem; color: #f59e0b;"></i>
                    <div>
                        <h5 style="margin: 0; font-weight: 700; color: #92400e;">Chế độ Shipper đang BẬT</h5>
                        <p style="margin: 3px 0 0 0; font-size: 0.9rem; color: #b45309;">
                            Giỏ hàng và tính năng đặt món ăn tạm thời khóa để bạn tập trung làm việc. Bấm <strong>"Tắt nhận đơn"</strong> ở góc trên khi bạn muốn nghỉ ngơi!
                        </p>
                    </div>
                </div>
                <button type="button" class="btn-close" onclick="this.parentElement.style.display='none';" style="background: none; border: none; font-size: 1.3rem; cursor: pointer; color: #92400e;">&times;</button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger d-flex align-items-center gap-3 mb-4 py-3 px-4 shadow-sm" style="border-radius: 14px; border-left: 5px solid #ef4444; background: #fef2f2;">
                <i class="fa-solid fa-circle-exclamation fs-4 text-danger"></i>
                <div style="font-size: 0.92rem;">
                    <c:choose>
                        <c:when test="${param.error eq 'method_not_allowed'}">
                            <strong>Cảnh báo bảo mật:</strong> Thao tác thay đổi trạng thái bị từ chối do gửi qua phương thức HTTP GET không an toàn.
                        </c:when>
                        <c:when test="${param.error eq 'csrf_invalid'}">
                            <strong>Lỗi bảo mật (CSRF):</strong> Phiên làm việc hoặc mã xác thực không hợp lệ. Vui lòng tải lại trang và thử lại.
                        </c:when>
                        <c:when test="${param.error eq 'banned'}">
                            <strong>Tài khoản bị khóa:</strong> Bạn không thể nhận đơn do tài khoản tài xế đang bị tạm khóa.
                        </c:when>
                        <c:when test="${param.error eq 'busy_cannot_toggle'}">
                            <strong>Không thể đổi trạng thái:</strong> Bạn đang có chuyến xe đang giao. Vui lòng hoàn tất đơn trước khi tắt nhận đơn.
                        </c:when>
                        <c:when test="${param.error eq 'accept_failed'}">
                            <strong>Không thể nhận đơn:</strong> Đơn hàng đã có tài xế khác nhận hoặc đã được hệ thống điều phối lại.
                        </c:when>
                        <c:otherwise>
                            <strong>Thông báo:</strong> Thao tác không thể hoàn tất (${param.error}).
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty param.msg}">
            <div class="alert alert-success d-flex align-items-center gap-3 mb-4 py-3 px-4 shadow-sm" style="border-radius: 14px; border-left: 5px solid #10ac84; background: #ecfdf5;">
                <i class="fa-solid fa-circle-check fs-4 text-success"></i>
                <div style="font-size: 0.92rem;">
                    <c:choose>
                        <c:when test="${param.msg eq 'boom_reported'}">
                            <strong>Đã ghi nhận:</strong> Báo cáo giao thất bại / bom hàng kèm bằng chứng đã được ghi nhận và gửi tới Ban Quản Trị để đối soát bảo vệ quyền lợi tài xế.
                        </c:when>
                        <c:otherwise>
                            <strong>Thành công:</strong> Thao tác của bạn đã hoàn tất!
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success d-flex align-items-center gap-3 mb-4 py-3 px-4 shadow-sm" style="border-radius: 14px; border-left: 5px solid #10ac84; background: #ecfdf5; font-weight: 600;">
                <i class="fa-solid fa-circle-check fs-4 text-success"></i>
                <div>${sessionScope.flashSuccess}</div>
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger d-flex align-items-center gap-3 mb-4 py-3 px-4 shadow-sm" style="border-radius: 14px; border-left: 5px solid #ef4444; background: #fef2f2; font-weight: 600;">
                <i class="fa-solid fa-triangle-exclamation fs-4 text-danger"></i>
                <div>${sessionScope.flashError}</div>
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashWarning}">
            <div class="alert alert-warning d-flex align-items-center gap-3 mb-4 py-3 px-4 shadow-sm" style="border-radius: 14px; border-left: 5px solid #f59e0b; background: #fffbeb; font-weight: 600;">
                <i class="fa-solid fa-triangle-exclamation fs-4 text-warning"></i>
                <div>${sessionScope.flashWarning}</div>
            </div>
            <c:remove var="flashWarning" scope="session" />
        </c:if>

        <!-- 4 Metric KPI Stat Cards (Đồng Bộ Tuyệt Đối Với merchant/dashboard) -->
        <div class="admin-stats-grid" style="margin-bottom: 24px;">
            <!-- KPI 1: Số Dư Ví Khả Dụng -->
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-blue">
                    <i class="fa-solid fa-wallet"></i>
                </div>
                <div class="stat-info" style="flex: 1;">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span class="stat-title">Số Dư Ví Hoạt Động</span>
                        <c:choose>
                            <c:when test="${walletBalance >= 50000}">
                                <span style="font-size: 0.72rem; font-weight: 700; color: #15803d; background: #dcfce7; padding: 2px 8px; border-radius: 20px;">
                                    <i class="fa-solid fa-circle-check"></i> Sẵn sàng COD
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span style="font-size: 0.72rem; font-weight: 700; color: #dc2626; background: #fee2e2; padding: 2px 8px; border-radius: 20px;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Cần nạp thêm
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <h3 class="stat-val" style="color: #1e3a8a;"><fmt:formatNumber value="${walletBalance}" pattern="#,###" /> đ</h3>
                    <div style="display: flex; gap: 8px; margin-top: 4px;">
                        <button type="button" onclick="openTopupModal()" class="text-primary font-weight-bold" style="background: none; border: none; padding: 0; font-size: 0.82rem; cursor: pointer;">
                            <i class="fa-solid fa-plus-circle"></i> Nạp ví
                        </button>
                        <span class="text-muted">•</span>
                        <button type="button" onclick="openWithdrawModal()" class="text-success font-weight-bold" style="background: none; border: none; padding: 0; font-size: 0.82rem; cursor: pointer;">
                            <i class="fa-solid fa-money-bill-transfer"></i> Rút tiền
                        </button>
                    </div>
                </div>
            </div>

            <!-- KPI 2: Thu Nhập Hôm Nay -->
            <div class="admin-stat-card card-revenue">
                <div class="stat-icon-wrap icon-green">
                    <i class="fa-solid fa-sack-dollar"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Thu Nhập Hôm Nay</span>
                    <h3 class="stat-val text-success"><fmt:formatNumber value="${earnings.todayEarnings}" pattern="#,###" /> đ</h3>
                    <span class="stat-sub text-success">
                        <i class="fa-solid fa-circle-check"></i> Hoàn thành: <strong>${earnings.todayTrips} cuốc xe</strong>
                    </span>
                </div>
            </div>

            <!-- KPI 3: Trạng Thái Đơn Hàng & Điều Phối -->
            <div class="admin-stat-card card-pending">
                <div class="stat-icon-wrap icon-orange">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Trạng Thái Chuyến Xe</span>
                    <c:choose>
                        <c:when test="${not empty activeOrders}">
                            <h3 class="stat-val" style="color: #2563eb;">${activeOrders.size()} đơn đang giao</h3>
                            <span class="stat-sub text-primary font-weight-bold">
                                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="text-primary">Tiến trình vận chuyển &rarr;</a>
                            </span>
                        </c:when>
                        <c:when test="${not empty pendingAssignedOrders}">
                            <h3 class="stat-val" style="color: #d97706;">${pendingAssignedOrders.size()} đơn chờ nhận</h3>
                            <span class="stat-sub text-warning font-weight-bold">
                                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="text-warning">Xem đơn quán gán &rarr;</a>
                            </span>
                        </c:when>
                        <c:when test="${driver.status eq 'AVAILABLE'}">
                            <h3 class="stat-val text-success" style="font-size: 1.35rem;">Đang quét tìm đơn</h3>
                            <span class="stat-sub text-success"><i class="fa-solid fa-satellite-dish"></i> Bán kính 5km</span>
                        </c:when>
                        <c:otherwise>
                            <h3 class="stat-val text-muted" style="font-size: 1.35rem;">Đang ngoại tuyến</h3>
                            <span class="stat-sub text-muted">Bật nhận đơn để nhận cuốc</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- KPI 4: Đánh Giá & Điểm Hạnh Kiểm -->
            <div class="admin-stat-card card-shippers">
                <div class="stat-icon-wrap icon-red">
                    <i class="fa-solid fa-award"></i>
                </div>
                <div class="stat-info">
                    <span class="stat-title">Điểm Hạnh Kiểm &amp; Sao</span>
                    <h3 class="stat-val text-primary">100đ • ${driverRatingStats != null ? driverRatingStats['avgRating'] : 5.0} ⭐</h3>
                    <span class="stat-sub text-success">
                        <i class="fa-solid fa-circle-check"></i> Hạng Xuất Sắc 🏆 (${driverRatingStats != null ? driverRatingStats['reviewCount'] : 0} đánh giá)
                    </span>
                </div>
            </div>
        </div>

        <!-- ================================================================= -->
        <!-- TAB 1: NHẬN ĐƠN & ĐIỀU PHỐI (dispatch)                            -->
        <!-- ================================================================= -->
        <c:if test="${activeTab eq 'dispatch' or empty activeTab}">
            <!-- GPS & Algorithmic Dispatch Widget -->
            <div class="shipper-card" style="padding: 18px 24px; border: 1px solid #e0e7ff; background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 12px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                            <i class="fa-solid fa-location-crosshairs"></i>
                        </div>
                        <div>
                            <div style="font-size: 0.78rem; font-weight: 700; color: #3b82f6; text-transform: uppercase; letter-spacing: 0.5px;">Định Vị Tọa Độ GPS &amp; Điều Phối Thông Minh</div>
                            <h4 style="margin: 2px 0 0 0; font-size: 1.05rem; font-weight: 800; color: #1e293b;">
                                Vị Trí Hiện Tại: 
                                <span id="currentLocDisplay" style="color: #2563eb; font-weight: 700;">
                                    ${not empty driver.currentAddress ? driver.currentAddress : 'Số 1 Võ Văn Ngân, Linh Chiểu, TP. Thủ Đức'}
                                </span>
                            </h4>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <button type="button" id="btnGetRealGps" class="btn btn-primary btn-sm" style="border-radius: 50px; font-weight: 700; padding: 8px 16px; display: inline-flex; align-items: center; gap: 6px;">
                            <i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật
                        </button>
                    </div>
                </div>

                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; padding-top: 12px; border-top: 1px dashed #e2e8f0; font-size: 0.86rem; color: #475569;">
                    <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                        <span><i class="fa-solid fa-compass text-primary"></i> Tọa độ: <code id="gpsCoordsText" style="background: #f1f5f9; padding: 3px 8px; border-radius: 6px; color: #0f172a; font-weight: 600;">${not empty driver.currentLatitude ? driver.currentLatitude : '10.850721'}, ${not empty driver.currentLongitude ? driver.currentLongitude : '106.771960'}</code></span>
                        <span>•</span>
                        <span><i class="fa-solid fa-clock text-muted"></i> Cập nhật: <small id="gpsUpdatedTime" class="text-muted"><fmt:formatDate value="${driver.lastLocationUpdated}" pattern="HH:mm dd/MM" /></small></span>
                    </div>

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

            <!-- DANH SÁCH ĐƠN HÀNG QUÁN VỪA CHỈ ĐỊNH (CẦN SHIPPER XÁC NHẬN) -->
            <c:if test="${not empty pendingAssignedOrders}">
                <div class="mb-4">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill bg-warning text-dark px-3 py-2 fw-bold" style="font-size: 0.95rem;">
                                <i class="fa-solid fa-bell fa-shake me-1"></i> ${pendingAssignedOrders.size()} đơn quán đã gán đang chờ bạn nhận
                            </span>
                            <small class="text-muted">(Ưu tiên nhận đơn theo thứ tự xuất hiện)</small>
                        </div>
                    </div>

                    <div class="d-flex flex-column gap-3">
                        <c:forEach items="${pendingAssignedOrders}" var="pOrder" varStatus="loop">
                            <div class="shipper-card ${loop.first ? 'pending-order-priority' : ''}">
                                <div class="${loop.first ? 'pending-banner-priority' : 'pending-banner-normal'}" style="color: #fff; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                    <div class="d-flex align-items-center gap-2">
                                        <div style="width: 32px; height: 32px; border-radius: 50%; background: rgba(255,255,255,0.25); display: flex; align-items: center; justify-content: center; font-size: 0.95rem; font-weight: 800;">
                                            #${loop.index + 1}
                                        </div>
                                        <div>
                                            <h4 style="margin: 0; font-weight: 800; font-size: 1.05rem; color: #fff;">
                                                QUÁN CHỈ ĐỊNH ĐƠN #FZ-${pOrder.id} ${loop.first ? '(Ưu tiên cao)' : ''}
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
                                            <span class="text-muted small">Cước ship nhận:</span>
                                            <div class="fw-bold fs-6 text-success">+<fmt:formatNumber value="${pOrder.shippingFee != null ? pOrder.shippingFee : 15000}" pattern="#,###" /> đ</div>
                                        </div>
                                        <div class="col-12">
                                            <span class="text-muted small">Địa chỉ giao hàng:</span>
                                            <div class="fw-semibold text-dark"><i class="fa-solid fa-location-dot text-danger me-1"></i> ${pOrder.address}</div>
                                        </div>
                                        <c:if test="${not empty pOrder.note}">
                                            <div class="col-12">
                                                <span class="text-muted small">Ghi chú của khách:</span>
                                                <div class="small text-muted italic bg-light p-2 rounded order-note-container">${pOrder.note}</div>
                                            </div>
                                        </c:if>
                                    </div>

                                    <div class="d-flex gap-3 flex-wrap">
                                        <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="flex: 2; min-width: 200px; margin: 0;">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <input type="hidden" name="action" value="acceptOrder">
                                            <input type="hidden" name="orderId" value="${pOrder.id}">
                                            <button type="submit" class="btn btn-success w-100 py-2 fw-bold" style="border-radius: 50px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 12px rgba(16, 172, 132, 0.25);">
                                                <i class="fa-solid fa-check-double me-2"></i> NHẬN ĐƠN #FZ-${pOrder.id}
                                            </button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="flex: 1; min-width: 130px; margin: 0;" onsubmit="return confirm('Bạn có chắc muốn từ chối cuốc xe #FZ-${pOrder.id}? Quán sẽ gán cho tài xế khác.');">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
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

            <!-- DANH SÁCH ĐƠN HÀNG ĐANG VẬN CHUYỂN -->
            <c:choose>
                <c:when test="${not empty activeOrders}">
                    <div class="mb-4">
                        <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge rounded-pill bg-primary px-3 py-2 fw-bold" style="font-size: 0.95rem;">
                                    <i class="fa-solid fa-motorcycle me-1"></i> ${activeOrders.size()} đơn hàng đang vận chuyển
                                </span>
                                <c:if test="${activeOrders.size() > 1}">
                                    <small class="text-muted fw-semibold">(Giao ghép đơn đa điểm - Cập nhật trạng thái từng đơn theo lộ trình)</small>
                                </c:if>
                            </div>
                        </div>

                        <div class="d-flex flex-column gap-4">
                            <c:forEach items="${activeOrders}" var="activeOrder" varStatus="actLoop">
                                <div class="shipper-card ${activeOrder.shipperDelivered ? 'active-order-delivered' : (!activeOrder.shipperPickedUp ? 'active-order-pickup' : 'active-order-shipping')}">
                                    <div class="${activeOrder.shipperDelivered ? 'active-banner-delivered' : (!activeOrder.shipperPickedUp ? 'active-banner-pickup' : 'active-banner-shipping')}" style="color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
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
                                        <!-- Cột Trái: Chi tiết khách hàng & Thao tác vòng đời -->
                                        <div style="flex: 1.2; min-width: 300px; padding: 24px;">
                                            <div style="background: #f8fafc; border-radius: 12px; padding: 16px; margin-bottom: 20px; border: 1px solid #e2e8f0;">
                                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; flex-wrap: wrap; gap: 8px;">
                                                    <span style="font-weight: 700; color: #1e293b; font-size: 1.05rem;">
                                                        <i class="fa-solid fa-user text-primary me-2"></i> ${activeOrder.customerName}
                                                    </span>
                                                    <a href="tel:${activeOrder.phone}" class="btn btn-outline-success btn-sm" style="border-radius: 50px; font-weight: 700; padding: 4px 14px;">
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
                                                    <div class="order-note-container" style="font-size: 0.88rem; color: #64748b; background: #fff; padding: 8px 12px; border-radius: 8px; border: 1px dashed #cbd5e1;">
                                                        <i class="fa-solid fa-note-sticky text-warning me-1"></i> <strong>Ghi chú:</strong> <span>${activeOrder.note}</span>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <!-- COD Summary -->
                                            <div style="display: flex; justify-content: space-between; align-items: center; background: #fff5f5; border: 1px solid #fee2e2; border-radius: 12px; padding: 14px 20px; margin-bottom: 24px;">
                                                <div>
                                                    <span style="font-size: 0.85rem; color: #64748b;">Phương thức: <strong>${activeOrder.paymentMethod}</strong></span>
                                                    <div style="font-size: 1.15rem; font-weight: 800; color: #1e293b;">Tiền thu hộ Khách (COD):</div>
                                                </div>
                                                <div style="font-size: 1.6rem; font-weight: 900; color: #dc2626;">
                                                    <fmt:formatNumber value="${activeOrder.totalAmount}" pattern="#,###" /> đ
                                                </div>
                                            </div>

                                            <!-- Nút Hành Động Theo Vòng Đời -->
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

                                                        <%-- BƯỚC 1: LẤY MÓN TỪ QUÁN --%>
                                                        <c:when test="${not activeOrder.shipperPickedUp}">
                                                            <c:choose>
                                                                <%-- Quán chưa chế biến --%>
                                                                <c:when test="${activeOrder.status eq 'PENDING' and not activeOrder.merchantConfirmed}">
                                                                    <div style="flex: 1 1 100%; margin-bottom: 8px;">
                                                                        <div class="alert alert-warning d-flex align-items-center gap-2 mb-0 py-2 px-3 w-100" style="border-radius: 12px; font-size: 0.88rem; background: #fffbeb; border: 1px solid #fde68a; color: #92400e;">
                                                                            <i class="fa-solid fa-hourglass-half fa-spin text-warning fs-5"></i>
                                                                            <div>
                                                                                <strong>Quán chưa bấm xác nhận chế biến món!</strong>
                                                                                <div class="small">Vui lòng đợi quán chuẩn bị món ăn trước khi bấm xác nhận lấy món.</div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <button type="button" class="btn btn-secondary w-100" disabled style="border-radius: 50px; font-weight: 700; padding: 12px 24px; opacity: 0.65; cursor: not-allowed;">
                                                                        <i class="fa-solid fa-fire-burner me-2"></i> ĐỢI QUÁN CHẾ BIẾN XONG ĐỂ LẤY MÓN
                                                                    </button>
                                                                </c:when>

                                                                <%-- Quán đã chế biến -> Shipper lấy món --%>
                                                                <c:otherwise>
                                                                    <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0; flex: 1.5; min-width: 240px;">
                                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                        <input type="hidden" name="action" value="confirmPickedUp">
                                                                        <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                        <button type="submit" class="btn btn-warning w-100" style="border-radius: 50px; font-weight: 800; padding: 12px 24px; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #fff; border: none; box-shadow: 0 4px 14px rgba(245, 158, 11, 0.35);" onclick="return confirm('Xác nhận bạn đã đến quán và nhận đủ món ăn cho đơn #FZ-${activeOrder.id}?');">
                                                                            <i class="fa-solid fa-utensils me-2"></i> 1. XÁC NHẬN ĐÃ LẤY MÓN TỪ QUÁN
                                                                        </button>
                                                                    </form>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>

                                                        <%-- BƯỚC 2: GIAO CHO KHÁCH --%>
                                                        <c:otherwise>
                                                            <c:if test="${activeOrder.customerConfirmed}">
                                                                <div style="flex: 1 1 100%; margin-bottom: 8px;">
                                                                    <div class="alert alert-success d-flex align-items-center gap-2 mb-0 py-2 px-3 w-100" style="border-radius: 12px; font-size: 0.88rem; background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46;">
                                                                        <i class="fa-solid fa-circle-check text-success fs-5"></i>
                                                                        <div>
                                                                            <strong>Khách hàng đã bấm xác nhận đã nhận món!</strong>
                                                                            <div class="small">Bấm nút bên dưới để xác nhận hoàn tất giao hàng và ghi nhận doanh thu vào ví.</div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0; flex: 1.5; min-width: 240px;">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                <input type="hidden" name="action" value="confirmDelivered">
                                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                <button type="submit" class="btn btn-success w-100" style="border-radius: 50px; font-weight: 800; padding: 12px 24px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.35);" onclick="return confirm('Xác nhận bạn đã giao món ăn tận nơi cho khách #FZ-${activeOrder.id}? Đơn hàng sẽ hoàn tất ngay lập tức.');">
                                                                    <i class="fa-solid fa-circle-check me-2"></i> 2. XÁC NHẬN ĐÃ GIAO CHO KHÁCH
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Nhóm Nút Báo Sự Cố Trả Đơn / Bom Hàng -->
                                                    <c:if test="${not activeOrder.shipperDelivered}">
                                                        <div style="margin-top: 14px; padding: 14px; background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 14px; width: 100%; box-sizing: border-box;">
                                                            <div style="font-size: 0.8rem; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 10px; display: flex; align-items: center; gap: 6px;">
                                                                <i class="fa-solid fa-triangle-exclamation text-warning"></i>
                                                                <span>Sự cố chuyến xe &amp; Hủy đơn</span>
                                                            </div>

                                                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0 0 10px 0;" onsubmit="if(!this.cancelReason.value) { alert('Vui lòng chọn lý do sự cố trước khi trả đơn!'); return false; } return confirm('Bạn có chắc muốn báo trả cuốc đơn #FZ-${activeOrder.id}? Hệ thống sẽ giải phóng cuốc để tài xế khác tiếp nhận.');">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                <input type="hidden" name="action" value="updateOrder">
                                                                <input type="hidden" name="orderId" value="${activeOrder.id}">
                                                                <input type="hidden" name="status" value="CANCELLED">
                                                                
                                                                <div style="display: flex; gap: 8px; align-items: center; width: 100%;">
                                                                    <select name="cancelReason" class="form-select" style="flex: 1; min-width: 0; height: 42px; border-radius: 10px; font-size: 0.88rem; font-weight: 500; border: 1.5px solid #cbd5e1; background-color: #fff; color: #1e293b; padding: 0 34px 0 12px; line-height: normal; box-sizing: border-box;">
                                                                        <option value="">-- Sự cố quán / Trả đơn --</option>
                                                                        <option value="Xe bị hỏng / Tai nạn giữa đường">🔧 Xe bị hỏng / Sự cố giao thông (Trả đơn)</option>
                                                                        <option value="Quán ăn đóng cửa / Hết món">🏪 Quán đóng cửa / Hết món (Hủy &amp; hoàn voucher)</option>
                                                                        <option value="Khách đổi địa chỉ quá xa">📍 Khách đổi địa chỉ quá xa</option>
                                                                        <option value="Lý do cá nhân khác">⚠️ Lý do cá nhân khác</option>
                                                                    </select>

                                                                    <button type="submit" class="btn btn-outline-secondary" style="height: 42px; border-radius: 10px; font-weight: 700; padding: 0 16px; font-size: 0.85rem; white-space: nowrap; border: 1.5px solid #cbd5e1; background: #fff; color: #475569; display: inline-flex; align-items: center; justify-content: center; gap: 6px; flex-shrink: 0;">
                                                                        <i class="fa-solid fa-arrow-rotate-left"></i>
                                                                        <span>Trả Cuốc</span>
                                                                    </button>
                                                                </div>
                                                            </form>

                                                            <button type="button" class="btn btn-outline-danger w-100" onclick="openReportFailedModal('${activeOrder.id}', '${activeOrder.customerName}')" style="height: 42px; border-radius: 10px; font-weight: 700; font-size: 0.88rem; border: 1.5px solid #ef4444; color: #dc2626; background: #fff; display: flex; align-items: center; justify-content: center; gap: 8px; transition: all 0.2s;">
                                                                <i class="fa-solid fa-triangle-exclamation"></i>
                                                                <span>Báo Giao Thất Bại / Bom Hàng</span>
                                                            </button>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Cột Phải: Lộ trình 2 chặng & Thù lao -->
                                        <div style="flex: 1; min-width: 280px; background: #f8fafc; border-left: 1px solid #e2e8f0; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                                            <div>
                                                <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 16px;">
                                                    <i class="fa-solid fa-location-crosshairs text-primary me-2"></i> Lộ Trình 2 Chặng Đơn #FZ-${activeOrder.id}
                                                </h4>
                                                <div style="position: relative; padding-left: 28px; margin-bottom: 24px;">
                                                    <!-- Chặng 1 -->
                                                    <div class="route-node ${activeOrder.shipperPickedUp ? 'route-node-picked' : 'route-node-picking'}" style="position: absolute; left: 0; top: 2px; width: 16px; height: 16px; border-radius: 50%;"></div>
                                                    <div class="${activeOrder.shipperPickedUp ? 'route-line-picked' : 'route-line-pending'}" style="position: absolute; left: 7px; top: 18px; bottom: 20px;"></div>
                                                    <div style="margin-bottom: 24px;">
                                                        <div class="${activeOrder.shipperPickedUp ? 'text-stage-success' : 'text-stage-warning'}" style="font-weight: 700; font-size: 0.95rem;">
                                                            ${activeOrder.shipperPickedUp ? '✓ Đã nhận món tại Quán ăn' : '⏳ Đang di chuyển đến Quán ăn'}
                                                        </div>
                                                        <div style="font-size: 0.85rem; color: #64748b;">
                                                            ${activeOrder.shipperPickedUp ? 'Món ăn đã được bàn giao cho tài xế' : 'Vui lòng đến quán và bấm xác nhận lấy món'}
                                                        </div>
                                                    </div>

                                                    <!-- Chặng 2 -->
                                                    <div class="route-node ${activeOrder.shipperDelivered ? 'route-node-delivered' : (activeOrder.shipperPickedUp ? 'route-node-delivering' : 'route-node-waiting')}" style="position: absolute; left: 0; top: 68px; width: 16px; height: 16px; border-radius: 50%;"></div>
                                                    <div>
                                                        <div class="${activeOrder.shipperDelivered ? 'text-stage-success' : (activeOrder.shipperPickedUp ? 'text-stage-info' : 'text-stage-muted')}" style="font-weight: 700; font-size: 0.95rem;">
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

                <%-- KHI TRỰC TUYẾN QUÉT ĐƠN --%>
                <c:when test="${driver.status eq 'AVAILABLE'}">
                    <div class="shipper-card" style="padding: 40px 24px; text-align: center;">
                        <div style="max-width: 680px; margin: 0 auto;">
                            <div id="radarScan">
                                <div class="radar-pulse-center">
                                    <i class="fa-solid fa-motorcycle"></i>
                                </div>
                                <h3 style="color: #065f46; font-weight: 800; margin-bottom: 8px;">Đang dò tìm đơn hàng mới trong bán kính 5km...</h3>
                                <p id="radarStatus" style="color: #047857; margin: 0; font-size: 0.95rem;">
                                    Bạn đang ở chế độ Trực Tuyến. Vui lòng giữ trang web mở để chuông báo rung khi có đơn mới!
                                </p>
                            </div>

                            <!-- Popup khi phát hiện cuốc xe mới -->
                            <div id="orderPopup" style="display: none; background: #ffffff; border-radius: 18px; padding: 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.12); border: 2px solid #f59e0b; text-align: left;">
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

                                <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0;">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <input type="hidden" name="action" value="acceptOrder">
                                    <input type="hidden" name="orderId" id="fOrderId" value="">
                                    <button type="submit" class="btn btn-warning btn-lg" style="width: 100%; border-radius: 50px; font-weight: 800; font-size: 1.15rem; padding: 14px 24px; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #fff; border: none; box-shadow: 0 6px 20px rgba(245, 158, 11, 0.4);">
                                        ⚡ BẤM NHẬN CUỐC XE NGAY
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:when>

                <%-- KHI BỊ KẸT Ở TRẠNG THÁI BUSY MÀ KHÔNG CÓ ĐƠN --%>
                <c:when test="${driver.status eq 'BUSY'}">
                    <div class="shipper-card" style="text-align: center; padding: 50px 24px; border: 2px dashed #f59e0b; background: #fffbeb;">
                        <div style="width: 80px; height: 80px; border-radius: 50%; background: #fef3c7; color: #d97706; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin: 0 auto 20px auto;">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                        <h3 style="font-size: 1.4rem; font-weight: 800; color: #92400e; margin-bottom: 8px;">
                            Lỗi Đồng Bộ: Trạng Thái Kẹt
                        </h3>
                        <p style="color: #b45309; max-width: 540px; margin: 0 auto 24px auto; font-size: 0.95rem; line-height: 1.6;">
                            Hệ thống ghi nhận bạn đang giao hàng nhưng không tìm thấy dữ liệu đơn hàng nào. Hãy bấm nút dưới đây để hoàn thành ép buộc và mở lại quét đơn.
                        </p>
                        <div style="display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;">
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn btn-warning" style="border-radius: 50px; font-weight: 800; padding: 12px 28px; box-shadow: 0 4px 14px rgba(245, 158, 11, 0.3);">
                                    <i class="fa-solid fa-screwdriver-wrench me-2"></i> Fix Lỗi &amp; Hoàn Thành Ảo
                                </button>
                            </form>
                        </div>
                    </div>
                </c:when>

                <%-- KHI DRIVER STATUS EQ 'OFFLINE' --%>
                <c:otherwise>
                    <div class="shipper-card" style="text-align: center; padding: 60px 24px;">
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
                            <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" style="margin: 0;">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="action" value="toggleStatus">
                                <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; background: #10ac84; border-color: #10ac84; box-shadow: 0 4px 14px rgba(16, 172, 132, 0.3);">
                                    <i class="fa-solid fa-bolt me-1"></i> Bật nhận đơn ngay
                                </button>
                            </form>
                            <a href="${pageContext.request.contextPath}/shipper/dashboard?tab=income" class="btn btn-outline-secondary" style="border-radius: 50px; font-weight: 700; padding: 12px 28px; border-color: #cbd5e1; color: #475569;">
                                <i class="fa-solid fa-wallet me-1"></i> Xem ví thu nhập
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:if>

        <!-- ============================================================= -->
        <!-- TAB 2: THU NHẬP & VÍ TIỀN (income)                            -->
        <!-- ============================================================= -->
        <c:if test="${activeTab eq 'income'}">
            <div class="shipper-card">
                <div class="shipper-card-header">
                    <div>
                        <h3 class="shipper-card-title"><i class="fa-solid fa-wallet text-primary"></i> Thu Nhập &amp; Ví Hoạt Động Tài Xế</h3>
                        <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Phân định minh bạch giữa <strong>Số dư ví hoạt động</strong> (ký quỹ COD) và <strong>Thu nhập thực nhận</strong> (thù lao giao hàng)</p>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button type="button" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 10px 20px;" onclick="openTopupModal()">
                            <i class="fa-solid fa-plus-circle me-1"></i> Nạp Ví Hoạt Động
                        </button>
                        <button type="button" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 10px 22px; background: #10ac84; border-color: #10ac84;" onclick="openWithdrawModal()">
                            <i class="fa-solid fa-money-bill-transfer me-1"></i> Rút Tiền Về Ngân Hàng
                        </button>
                    </div>
                </div>

                <div class="shipper-card-body">
                    <!-- Banner Ví Hoạt Động -->
                    <div style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #1e3a8a 100%); color: #fff; border-radius: 20px; padding: 26px 28px; margin-bottom: 24px; box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.4); position: relative; overflow: hidden;">
                        <div style="position: absolute; right: 20px; bottom: -15px; opacity: 0.08; font-size: 10rem; pointer-events: none;">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 20px; position: relative; z-index: 1;">
                            <div>
                                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                                    <span style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #94a3b8;">
                                        <i class="fa-solid fa-credit-card me-1 text-primary"></i> VÍ HOẠT ĐỘNG SHIPPER
                                    </span>
                                    <c:choose>
                                        <c:when test="${walletBalance >= 50000}">
                                            <span style="font-size: 0.75rem; font-weight: 700; color: #34d399; background: rgba(16, 185, 129, 0.18); border: 1px solid rgba(52, 211, 153, 0.35); padding: 3px 10px; border-radius: 20px;">
                                                <i class="fa-solid fa-circle-check me-1"></i> Đủ điều kiện nhận đơn COD
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-size: 0.75rem; font-weight: 700; color: #f87171; background: rgba(239, 68, 68, 0.18); border: 1px solid rgba(248, 113, 113, 0.35); padding: 3px 10px; border-radius: 20px;">
                                                <i class="fa-solid fa-triangle-exclamation me-1"></i> Số dư dưới 50.000 đ - Cần nạp thêm
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div style="font-size: 2.5rem; font-weight: 900; color: #ffffff; letter-spacing: -0.5px; margin: 4px 0 10px 0;">
                                    <fmt:formatNumber value="${walletBalance}" pattern="#,###" /> <span style="font-size: 1.5rem; font-weight: 700; color: #60a5fa;">đ</span>
                                </div>
                                <div style="font-size: 0.86rem; color: #cbd5e1; max-width: 620px; line-height: 1.5;">
                                    Số dư ví hoạt động dùng để ký quỹ nhận các đơn hàng giao đồ ăn thu tiền mặt (COD). Bạn có thể nạp tiền bất cứ lúc nào qua QR hoặc rút về tài khoản ngân hàng.
                                </div>
                            </div>
                            <div style="display: flex; flex-direction: column; gap: 10px; min-width: 180px;">
                                <button type="button" class="btn btn-primary" onclick="openTopupModal()" style="border-radius: 12px; font-weight: 700; padding: 12px 20px; box-shadow: 0 4px 14px rgba(37, 99, 235, 0.4);">
                                    <i class="fa-solid fa-plus-circle me-2"></i> Nạp Ví Hoạt Động
                                </button>
                                <button type="button" class="btn btn-outline-light" onclick="openWithdrawModal()" style="border-radius: 12px; font-weight: 700; padding: 12px 20px; background: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.25);">
                                    <i class="fa-solid fa-money-bill-transfer me-2"></i> Rút Về Ngân Hàng
                                </button>
                            </div>
                        </div>

                        <!-- Cơ chế COD vs Online -->
                        <div style="margin-top: 20px; padding-top: 18px; border-top: 1px solid rgba(255, 255, 255, 0.12); display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px;">
                            <div style="background: rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 12px 16px; border-left: 3px solid #f87171;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #fca5a5; margin-bottom: 4px;">
                                    <i class="fa-solid fa-hand-holding-dollar me-1"></i> ĐƠN HÀNG COD (TIỀN MẶT)
                                </div>
                                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                                    Khách trả shipper tiền mặt (món + ship). Hệ thống tự động <strong>trừ tiền COD thu khách vào ví</strong> (thu hộ nhà hàng) và <strong>cộng thù lao giao hàng vào ví</strong>. Đồng thời thù lao được tính vào mục Thu nhập.
                                </div>
                            </div>
                            <div style="background: rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 12px 16px; border-left: 3px solid #34d399;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #86efac; margin-bottom: 4px;">
                                    <i class="fa-solid fa-qrcode me-1"></i> ĐƠN HÀNG ONLINE (VNPAY / THẺ)
                                </div>
                                <div style="font-size: 0.8rem; color: #cbd5e1; line-height: 1.45;">
                                    Khách đã thanh toán trực tuyến, shipper <strong>không thu tiền mặt</strong> và không bị trừ COD. Hệ thống <strong>cộng trực tiếp thù lao giao hàng vào ví</strong> và tổng thu nhập của bạn.
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 4 Thẻ Thống Kê Thu Nhập -->
                    <div style="margin-bottom: 24px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 8px;">
                            <h4 style="font-size: 1.15rem; font-weight: 800; color: #1e293b; margin: 0;">
                                <i class="fa-solid fa-chart-pie text-success me-2"></i> Tổng Thu Nhập Theo Thời Gian
                            </h4>
                            <span style="font-size: 0.85rem; color: #64748b;">Tổng thù lao nhận được từ các chuyến giao thành công</span>
                        </div>
                        <div class="admin-stats-grid">
                            <div class="admin-stat-card" style="border-left: 4px solid #10ac84;">
                                <div class="stat-info">
                                    <span class="stat-title">Thu Nhập Hôm Nay</span>
                                    <h3 class="stat-val text-success"><fmt:formatNumber value="${earnings.todayEarnings}" pattern="#,###" /> đ</h3>
                                    <span class="stat-sub">Đã hoàn tất: <strong>${earnings.todayTrips} chuyến</strong></span>
                                </div>
                            </div>
                            <div class="admin-stat-card" style="border-left: 4px solid #2563eb;">
                                <div class="stat-info">
                                    <span class="stat-title">Thu Nhập Tuần Này</span>
                                    <h3 class="stat-val" style="color: #2563eb;"><fmt:formatNumber value="${earnings.weekEarnings}" pattern="#,###" /> đ</h3>
                                    <span class="stat-sub">Đã hoàn tất: <strong>${earnings.weekTrips} chuyến</strong></span>
                                </div>
                            </div>
                            <div class="admin-stat-card" style="border-left: 4px solid #8b5cf6;">
                                <div class="stat-info">
                                    <span class="stat-title">Thu Nhập Tháng Này</span>
                                    <h3 class="stat-val" style="color: #7c3aed;"><fmt:formatNumber value="${earnings.monthEarnings}" pattern="#,###" /> đ</h3>
                                    <span class="stat-sub">Đã hoàn tất: <strong>${earnings.monthTrips} chuyến</strong></span>
                                </div>
                            </div>
                            <div class="admin-stat-card" style="border-left: 4px solid #f05454;">
                                <div class="stat-info">
                                    <span class="stat-title">Tổng Thu Nhập Tích Lũy</span>
                                    <h3 class="stat-val text-primary"><fmt:formatNumber value="${earnings.totalEarnings}" pattern="#,###" /> đ</h3>
                                    <span class="stat-sub">Tổng cộng: <strong>${earnings.totalTrips} chuyến hoàn tất</strong></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Biểu đồ 7 ngày gần nhất -->
                    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px 24px; margin-bottom: 24px; box-shadow: 0 4px 14px rgba(0,0,0,0.03);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; margin-bottom: 20px;">
                            <div>
                                <h4 style="font-size: 1.15rem; font-weight: 800; color: #1e293b; margin: 0 0 6px 0;">
                                    <i class="fa-solid fa-chart-line text-primary me-2"></i> Xu Hướng Thu Nhập 7 Ngày Gần Nhất
                                </h4>
                                <div style="font-size: 0.9rem; color: #64748b;">Biểu đồ thù lao kiếm được theo từng ngày hoạt động thực tế</div>
                            </div>
                            <div style="background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 12px; padding: 8px 16px; text-align: center;">
                                <div style="font-size: 0.75rem; font-weight: 700; color: #059669; margin-bottom: 2px;">TỔNG THÁNG NÀY</div>
                                <div style="font-size: 1.25rem; font-weight: 800; color: #059669;">
                                    <fmt:formatNumber value="${earnings.monthEarnings}" pattern="#,###" /> đ
                                </div>
                            </div>
                        </div>

                        <div style="position: relative; height: 260px; width: 100%;">
                            <canvas id="revenueChart"
                                    data-labels='<c:out value="${not empty earnings.chartLabelsJson ? earnings.chartLabelsJson : '[\"T2\", \"T3\", \"T4\", \"T5\", \"T6\", \"T7\", \"CN\"]'}" />'
                                    data-values='<c:out value="${not empty earnings.chartDataJson ? earnings.chartDataJson : '[0, 0, 0, 0, 0, 0, 0]'}" />'></canvas>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            const ctx = document.getElementById('revenueChart');
                            if (ctx) {
                                let chartLabels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                                let chartData = [0, 0, 0, 0, 0, 0, 0];
                                try {
                                    const rawLabels = ctx.getAttribute('data-labels');
                                    const rawValues = ctx.getAttribute('data-values');
                                    if (rawLabels) chartLabels = JSON.parse(rawLabels);
                                    if (rawValues) chartData = JSON.parse(rawValues);
                                } catch(e) {
                                    console.error("Lỗi đọc dữ liệu biểu đồ:", e);
                                }

                                new Chart(ctx, {
                                    type: 'line',
                                    data: {
                                        labels: chartLabels,
                                        datasets: [{
                                            label: 'Thu nhập (VNĐ)',
                                            data: chartData,
                                            borderColor: '#f05454',
                                            backgroundColor: 'rgba(240, 84, 84, 0.08)',
                                            borderWidth: 3,
                                            fill: true,
                                            tension: 0.35,
                                            pointBackgroundColor: '#fff',
                                            pointBorderColor: '#f05454',
                                            pointBorderWidth: 2,
                                            pointRadius: 5,
                                            pointHoverRadius: 7
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: { display: false },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        let label = context.dataset.label || '';
                                                        if (label) { label += ': '; }
                                                        if (context.parsed.y !== null) {
                                                            label += new Intl.NumberFormat('vi-VN').format(context.parsed.y) + ' đ';
                                                        }
                                                        return label;
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                grid: { color: '#f1f5f9', drawBorder: false },
                                                ticks: {
                                                    callback: function(value) { return (value / 1000) + 'k'; },
                                                    color: '#94a3b8', font: { size: 11, weight: '600' }
                                                }
                                            },
                                            x: {
                                                grid: { display: false, drawBorder: false },
                                                ticks: { color: '#64748b', font: { size: 12, weight: 'bold' } }
                                            }
                                        }
                                    }
                                });
                            }
                        });
                    </script>

                    <!-- LỊCH SỬ BIẾN ĐỘNG SỐ DƯ VÍ -->
                    <div class="admin-table-card" style="padding: 24px;">
                        <div class="admin-table-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 10px;">
                            <div>
                                <h4 class="table-card-title" style="margin: 0 0 4px 0;">
                                    <i class="fa-solid fa-list-check text-primary me-2"></i> Lịch Sử Biến Động Số Dư Ví (Đối Soát Chi Tiết)
                                </h4>
                                <span class="table-card-sub">Ghi nhận các khoản trừ COD thu khách, cộng thù lao giao hàng, nạp và rút tiền ví</span>
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary" onclick="openTopupModal()" style="border-radius: 50px; font-weight: 600; padding: 6px 16px;">
                                <i class="fa-solid fa-plus me-1"></i> Nạp thêm ví
                            </button>
                        </div>

                        <c:choose>
                            <c:when test="${empty walletTransactions}">
                                <div style="text-align: center; padding: 36px 20px; background: #fafbfc; border-radius: 12px; border: 1px dashed #cbd5e1;">
                                    <i class="fa-solid fa-wallet text-muted mb-2" style="font-size: 2rem;"></i>
                                    <p style="color: #64748b; font-size: 0.9rem; margin: 0;">Chưa có biến động số dư nào trong ví. Lịch sử giao dịch sẽ tự động hiển thị tại đây.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="admin-data-table">
                                        <thead>
                                            <tr>
                                                <th>Thời Gian</th>
                                                <th>Loại Giao Dịch</th>
                                                <th>Nội Dung Diễn Giải</th>
                                                <th style="text-align: right;">Số Tiền</th>
                                                <th style="text-align: right;">Số Dư Sau GD</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${walletTransactions}" var="tx">
                                                <tr>
                                                    <td style="color: #64748b; font-size: 0.85rem;">
                                                        <fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${tx.type eq 'TOPUP'}">
                                                                <span class="badge" style="background: #dbeafe; color: #1e40af; font-weight: 700; border-radius: 50px; padding: 4px 10px;">
                                                                    <i class="fa-solid fa-arrow-down me-1"></i> Nạp tiền ví
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${tx.type eq 'WITHDRAW'}">
                                                                <span class="badge" style="background: #fef3c7; color: #92400e; font-weight: 700; border-radius: 50px; padding: 4px 10px;">
                                                                    <i class="fa-solid fa-arrow-up me-1"></i> Rút về NH
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${tx.type eq 'SHIPPING_EARNING' || tx.type eq 'SHIPPING_FEE'}">
                                                                <span class="badge" style="background: #dcfce7; color: #15803d; font-weight: 700; border-radius: 50px; padding: 4px 10px;">
                                                                    <i class="fa-solid fa-plus me-1"></i> Cước giao hàng
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${tx.type eq 'COD_DEDUCTION'}">
                                                                <span class="badge" style="background: #fee2e2; color: #991b1b; font-weight: 700; border-radius: 50px; padding: 4px 10px;">
                                                                    <i class="fa-solid fa-minus me-1"></i> Trừ COD thu khách
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge" style="background: #f1f5f9; color: #475569; font-weight: 700; border-radius: 50px; padding: 4px 10px;">
                                                                    ${not empty tx.typeDisplay ? tx.typeDisplay : tx.type}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="color: #334155; font-weight: 500;">
                                                        ${tx.description}
                                                        <c:if test="${tx.orderId != null}">
                                                            <span style="color: #2563eb; font-weight: 700;">#FZ-${tx.orderId}</span>
                                                        </c:if>
                                                    </td>
                                                    <td style="text-align: right; font-weight: 800;">
                                                        <c:choose>
                                                            <c:when test="${tx.amount >= 0}">
                                                                <span style="color: #10ac84;">+<fmt:formatNumber value="${tx.amount}" pattern="#,###" /> đ</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color: #dc2626;"><fmt:formatNumber value="${tx.amount}" pattern="#,###" /> đ</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: right; font-weight: 700; color: #1e293b;">
                                                        <fmt:formatNumber value="${tx.balanceAfter}" pattern="#,###" /> đ
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
            </div>
        </c:if>

        <!-- ============================================================= -->
        <!-- TAB 3: LỊCH SỬ CHUYẾN GIAO (history)                          -->
        <!-- ============================================================= -->
        <c:if test="${activeTab eq 'history'}">
            <div class="shipper-card" style="padding: 24px;">
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
                <div class="merchant-filter-group" style="margin-bottom: 20px;">
                    <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=ALL" class="merchant-filter-pill ${empty currentStatusFilter or currentStatusFilter eq 'ALL' ? 'active' : ''}">
                        Tất cả chuyến (${totalDeliveryCount})
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=DELIVERED" class="merchant-filter-pill ${currentStatusFilter eq 'DELIVERED' ? 'active' : ''}">
                        Giao thành công (${deliveredCount})
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=SHIPPING" class="merchant-filter-pill ${currentStatusFilter eq 'SHIPPING' ? 'active' : ''}">
                        Đang giao (${shippingCount})
                    </a>
                    <a href="${pageContext.request.contextPath}/shipper/history?statusFilter=CANCELLED" class="merchant-filter-pill ${currentStatusFilter eq 'CANCELLED' ? 'active' : ''}">
                        Đã hủy / Bom hàng (${cancelledCount})
                    </a>
                </div>

                <!-- Delivery History List -->
                <c:choose>
                    <c:when test="${empty deliveryHistory}">
                        <div style="text-align: center; padding: 48px 20px; background: #fafbfc; border-radius: 14px; border: 1px dashed #cbd5e1;">
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
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="item" items="${deliveryHistory}">
                                <div class="shipper-card" style="margin-bottom: 0;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px dashed #e2e8f0; padding: 14px 20px; flex-wrap: wrap; gap: 8px;">
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <span style="font-size: 1.1rem; font-weight: 800; color: #1e293b;">#FZ-${item.id}</span>
                                            <span class="text-muted" style="font-size: 0.85rem;">
                                                <i class="fa-regular fa-clock me-1"></i>
                                                <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </span>
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${item.status eq 'DELIVERED'}">
                                                    <span style="background: #dcfce7; color: #15803d; font-weight: 700; padding: 4px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-circle-check me-1"></i> Giao thành công
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.status eq 'SHIPPING'}">
                                                    <span style="background: #dbeafe; color: #1d4ed8; font-weight: 700; padding: 4px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-motorcycle me-1"></i> Đang giao hàng
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.status eq 'CANCELLED'}">
                                                    <span style="background: #fee2e2; color: #b91c1c; font-weight: 700; padding: 4px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        <i class="fa-solid fa-ban me-1"></i> Đã hủy / Bom hàng
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="background: #f1f5f9; color: #475569; font-weight: 700; padding: 4px 14px; border-radius: 50px; font-size: 0.85rem;">
                                                        ${item.status}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div style="padding: 18px 20px;">
                                        <div class="row g-3">
                                            <div class="col-md-4 col-sm-6">
                                                <div style="font-size: 0.82rem; color: #64748b;">Khách hàng:</div>
                                                <div style="font-weight: 700; color: #1e293b;">${item.customerName}</div>
                                                <div style="font-size: 0.85rem; margin-top: 2px;">
                                                    <a href="tel:${item.phone}" style="color: #0284c7; text-decoration: none; font-weight: 600;"><i class="fa-solid fa-phone me-1"></i>${item.phone}</a>
                                                </div>
                                            </div>
                                            <div class="col-md-5 col-sm-6">
                                                <div style="font-size: 0.82rem; color: #64748b;">Địa chỉ giao:</div>
                                                <div style="font-weight: 600; color: #1e293b; font-size: 0.9rem;">
                                                    <i class="fa-solid fa-location-dot text-danger me-1"></i> ${item.address}
                                                </div>
                                                <c:if test="${not empty item.note}">
                                                    <div style="font-size: 0.82rem; color: #64748b; margin-top: 4px;">
                                                        <strong>Ghi chú:</strong> <em>"${item.note}"</em>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="col-md-3 col-sm-12 text-md-end">
                                                <div style="font-size: 0.82rem; color: #64748b;">Tiền thu hộ COD:</div>
                                                <div style="color: #dc2626; font-weight: 800; font-size: 1.15rem;">
                                                    <fmt:formatNumber value="${item.totalAmount}" pattern="#,###" /> đ
                                                </div>
                                                <div style="font-size: 0.85rem; color: #10ac84; font-weight: 700; margin-top: 2px;">
                                                    <c:choose>
                                                        <c:when test="${item.status eq 'DELIVERED'}">
                                                            +15.000 đ (Đã vào ví)
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #94a3b8;">0 đ</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <c:if test="${not empty item.proofImage}">
                                                <div class="col-12" style="border-top: 1px dashed #f1f5f9; padding-top: 8px;">
                                                    <span style="font-size: 0.85rem; color: #dc2626; font-weight: 600;">
                                                        <i class="fa-solid fa-image me-1"></i> Bằng chứng giao thất bại:
                                                    </span>
                                                    <a href="${pageContext.request.contextPath}${item.proofImage}" target="_blank" style="color: #dc2626; font-weight: 700; text-decoration: underline; margin-left: 6px;">
                                                        Xem ảnh chụp bằng chứng
                                                    </a>
                                                </div>
                                            </c:if>
                                        </div>

                                        <c:if test="${not empty item.review}">
                                            <div style="margin-top: 12px; padding-top: 10px; border-top: 1px solid #f8fafc; display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                                <span style="font-size: 0.82rem; font-weight: 700; color: #475569;">
                                                    <i class="fa-solid fa-star text-warning me-1"></i> Đánh giá của khách:
                                                </span>
                                                <span style="color: #f59e0b;">
                                                    <c:forEach begin="1" end="${item.review.driverRating}">
                                                        <i class="fa-solid fa-star"></i>
                                                    </c:forEach>
                                                    <c:forEach begin="${item.review.driverRating + 1}" end="5">
                                                        <i class="fa-regular fa-star" style="color: #cbd5e1;"></i>
                                                    </c:forEach>
                                                </span>
                                                <strong style="color: #b45309; font-size: 0.9rem;">Tài xế: ${item.review.driverRating}/5 sao</strong>
                                                <c:if test="${not empty item.review.comment}">
                                                    <span style="color: #64748b; font-size: 0.85rem;">- "${item.review.comment}"</span>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <!-- ============================================================= -->
        <!-- TAB 4: ĐIỂM VI PHẠM (violations)                              -->
        <!-- ============================================================= -->
        <c:if test="${activeTab eq 'violations'}">
            <div class="shipper-card">
                <div class="shipper-card-header">
                    <div>
                        <h3 class="shipper-card-title"><i class="fa-solid fa-shield-halved text-warning"></i> Điểm Vi Phạm &amp; Tác Phong Hoạt Động</h3>
                        <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Theo dõi điểm hạnh kiểm, tỷ lệ hoàn thành cuốc xe và quy chế tài xế 5 sao</p>
                    </div>
                    <span class="badge" style="background: #dcfce7; color: #15803d; font-size: 0.85rem; padding: 8px 16px; border-radius: 50px;">
                        <i class="fa-solid fa-circle-check me-1"></i> Tài khoản Tốt (Không có vi phạm)
                    </span>
                </div>

                <div class="shipper-card-body">
                    <!-- Hero Score Box -->
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
                        <div>
                            <span style="display: inline-block; background: #fff; border: 1px solid #86efac; border-radius: 12px; padding: 8px 16px; font-weight: 700; color: #15803d; font-size: 0.9rem;">
                                <i class="fa-solid fa-award text-warning me-1"></i> Đối Tác Gương Mẫu
                            </span>
                        </div>
                    </div>

                    <!-- 4 Service Quality Metric Cards -->
                    <div class="admin-stats-grid" style="margin-bottom: 24px;">
                        <div class="admin-stat-card">
                            <div class="stat-info">
                                <span class="stat-title">TỶ LỆ NHẬN ĐƠN (AR)</span>
                                <h3 class="stat-val text-success">98.5%</h3>
                                <span class="stat-sub text-success">Mục tiêu duy trì: &ge; 85%</span>
                            </div>
                        </div>
                        <div class="admin-stat-card">
                            <div class="stat-info">
                                <span class="stat-title">TỶ LỆ HỦY CUỐC (CR)</span>
                                <h3 class="stat-val text-success">0.0%</h3>
                                <span class="stat-sub text-success">Mục tiêu an toàn: &lt; 5%</span>
                            </div>
                        </div>
                        <div class="admin-stat-card">
                            <div class="stat-info">
                                <span class="stat-title">TỶ LỆ ĐÚNG GIỜ 30P</span>
                                <h3 class="stat-val" style="color: #3b82f6;">99.2%</h3>
                                <span class="stat-sub">Chuẩn cam kết Utee Express</span>
                            </div>
                        </div>
                        <div class="admin-stat-card">
                            <div class="stat-info">
                                <span class="stat-title">ĐÁNH GIÁ TRUNG BÌNH</span>
                                <h3 class="stat-val" style="color: #f59e0b;">${driverRatingStats != null ? driverRatingStats['avgRating'] : 5.0} ⭐</h3>
                                <span class="stat-sub">Từ thực khách &amp; Quán ăn</span>
                            </div>
                        </div>
                    </div>

                    <!-- Violations Regulations Table -->
                    <h4 style="font-size: 1.1rem; font-weight: 800; color: #1e293b; margin-bottom: 14px;">
                        <i class="fa-solid fa-book-open text-primary me-2"></i> Bảng Quy Chuẩn Xử Lý Vi Phạm Đối Tác Tài Xế
                    </h4>

                    <div class="table-responsive">
                        <table class="admin-data-table">
                            <thead>
                                <tr>
                                    <th>Hành Vi Vi Phạm</th>
                                    <th style="text-align: center;">Điểm Trừ Hạnh Kiểm</th>
                                    <th>Biện Pháp Xử Lý</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Tự ý hủy đơn sau khi đã bấm nhận cuốc (không có lý do chính đáng)</td>
                                    <td style="text-align: center; color: #dc2626; font-weight: 700;">-5 điểm / lần</td>
                                    <td style="color: #64748b;">Khóa nhận đơn 2 giờ</td>
                                </tr>
                                <tr>
                                    <td>Giao trễ quá 45 phút không thông báo trước cho quán &amp; khách</td>
                                    <td style="text-align: center; color: #dc2626; font-weight: 700;">-3 điểm / lần</td>
                                    <td style="color: #64748b;">Nhắc nhở qua thông báo app</td>
                                </tr>
                                <tr>
                                    <td>Thu sai tiền thu hộ COD hoặc thái độ phục vụ khiếm nhã</td>
                                    <td style="text-align: center; color: #dc2626; font-weight: 700;">-10 điểm / lần</td>
                                    <td style="color: #64748b;">Hoàn tiền &amp; Đào tạo lại tác phong</td>
                                </tr>
                                <tr>
                                    <td>Khi điểm hạnh kiểm tích lũy dưới 70 điểm</td>
                                    <td style="text-align: center; color: #dc2626; font-weight: 700;">&lt; 70 điểm</td>
                                    <td style="color: #dc2626; font-weight: 600;">Tạm khóa tài khoản tài xế</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- ============================================================= -->
        <!-- TAB 5: CÀI ĐẶT HOẠT ĐỘNG (settings)                           -->
        <!-- ============================================================= -->
        <c:if test="${activeTab eq 'settings'}">
            <div class="shipper-card">
                <div class="shipper-card-header">
                    <div>
                        <h3 class="shipper-card-title"><i class="fa-solid fa-gear text-secondary"></i> Cài Đặt Hoạt Động &amp; Hồ Sơ Phương Tiện</h3>
                        <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Tùy chỉnh khoảng cách quét đơn, âm báo chuông và thông tin xe máy</p>
                    </div>
                </div>

                <div class="shipper-card-body">
                    <!-- Tùy chỉnh Tiếp Nhận -->
                    <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px;">
                        <i class="fa-solid fa-sliders text-primary me-2"></i> Tùy Chỉnh Tiếp Nhận Đơn Hàng
                    </h4>

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px dashed #e2e8f0;">
                        <div>
                            <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Tự động nhận đơn nhanh (Auto-Accept)</div>
                            <div style="font-size: 0.85rem; color: #64748b;">Tự động tiếp nhận khi quán gần bạn phát tín hiệu gán đơn trực tiếp</div>
                        </div>
                        <div>
                            <input type="checkbox" id="autoAcceptToggle" checked style="width: 22px; height: 22px; accent-color: #10ac84; cursor: pointer;">
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px dashed #e2e8f0;">
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

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px dashed #e2e8f0;">
                        <div>
                            <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Âm thanh chuông báo khi có cuốc mới</div>
                            <div style="font-size: 0.85rem; color: #64748b;">Phát chuông rung to rõ để không bỏ lỡ các chuyến xe</div>
                        </div>
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <button type="button" class="btn btn-outline-secondary btn-sm" style="border-radius: 50px; font-size: 0.8rem; font-weight: 600;" onclick="try { new Audio('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3').play(); } catch(e){}">
                                <i class="fa-solid fa-volume-high me-1"></i> Thử chuông
                            </button>
                            <input type="checkbox" checked style="width: 22px; height: 22px; accent-color: #10ac84; cursor: pointer;">
                        </div>
                    </div>

                    <!-- Bản Đồ & Điều Hướng -->
                    <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin: 30px 0 16px 0; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px;">
                        <i class="fa-solid fa-map-location-dot text-primary me-2"></i> Bản Đồ &amp; Điều Hướng
                    </h4>

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px dashed #e2e8f0;">
                        <div>
                            <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Ứng dụng dẫn đường mặc định</div>
                            <div style="font-size: 0.85rem; color: #64748b;">Mở bản đồ chỉ đường khi bấm nút điều hướng</div>
                        </div>
                        <div>
                            <select style="padding: 8px 14px; border-radius: 8px; border: 1px solid #cbd5e1; font-weight: 600; color: #1e293b; outline: none;">
                                <option value="gmaps" selected>Google Maps</option>
                                <option value="amaps">Apple Maps</option>
                                <option value="inapp">Bản đồ Utee</option>
                            </select>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px dashed #e2e8f0;">
                        <div>
                            <div style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">Giao ghép đơn (Batching)</div>
                            <div style="font-size: 0.85rem; color: #64748b;">Tự động nhận ghép đơn cùng tuyến đường để tăng tối đa thu nhập</div>
                        </div>
                        <div>
                            <input type="checkbox" checked style="width: 22px; height: 22px; accent-color: #10ac84; cursor: pointer;">
                        </div>
                    </div>

                    <!-- Thông Tin Xe & Giấy Tờ -->
                    <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin: 30px 0 16px 0; border-bottom: 1px solid #f1f5f9; padding-bottom: 8px;">
                        <i class="fa-solid fa-motorcycle text-primary me-2"></i> Thông Tin Phương Tiện &amp; Giấy Tờ Đăng Ký
                    </h4>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Biển số xe đăng ký:</label>
                            <input type="text" class="form-control" value="${not empty driver.licensePlate ? driver.licensePlate : '59-X3 999.99'}" readonly style="background: #f8fafc; font-weight: 700; border-radius: 10px;">
                        </div>
                        <div class="col-md-6">
                            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Loại phương tiện:</label>
                            <input type="text" class="form-control" value="${not empty driver.vehicleType ? driver.vehicleType : 'Xe máy 2 bánh'}" readonly style="background: #f8fafc; border-radius: 10px;">
                        </div>
                        <div class="col-md-6">
                            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Căn cước công dân (CCCD):</label>
                            <div style="display: flex; align-items: center; gap: 8px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 10px 14px; font-size: 0.88rem; color: #15803d; font-weight: 600;">
                                <i class="fa-solid fa-circle-check"></i> Đã xác thực CCCD gắn chip
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Giấy phép lái xe (GPLX):</label>
                            <div style="display: flex; align-items: center; gap: 8px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 10px 14px; font-size: 0.88rem; color: #15803d; font-weight: 600;">
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
        <!-- TAB 6: TRUNG TÂM TRỢ GIÚP (help)                              -->
        <!-- ============================================================= -->
        <c:if test="${activeTab eq 'help'}">
            <div class="shipper-card">
                <div class="shipper-card-header">
                    <div>
                        <h3 class="shipper-card-title"><i class="fa-solid fa-circle-question text-primary"></i> Trung Tâm Trợ Giúp Đối Tác Tài Xế Utee</h3>
                        <p style="margin: 4px 0 0 0; color: #64748b; font-size: 0.88rem;">Kênh hỗ trợ khẩn cấp 24/7, cẩm nang xử lý sự cố và giải đáp thắc mắc</p>
                    </div>
                </div>

                <div class="shipper-card-body">
                    <!-- Hotline Cards -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div style="border-left: 4px solid #f05454; background: #fff5f5; border-radius: 14px; padding: 18px 20px; border: 1px solid #fee2e2;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #dc2626;"><i class="fa-solid fa-phone-volume me-1"></i> HOTLINE KHẨN CẤP ĐANG GIAO ĐƠN</div>
                                <div style="font-size: 1.6rem; font-weight: 900; color: #dc2626; margin: 4px 0;">1900 6869</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Nhấn phím 1 để gặp bộ phận Điều Phối Khẩn Cấp (24/7)</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div style="border-left: 4px solid #0284c7; background: #f0f9ff; border-radius: 14px; padding: 18px 20px; border: 1px solid #e0f2fe;">
                                <div style="font-size: 0.82rem; font-weight: 700; color: #0369a1;"><i class="fa-brands fa-telegram me-1"></i> KÊNH HỖ TRỢ ZALO / TELEGRAM</div>
                                <div style="font-size: 1.3rem; font-weight: 900; color: #0284c7; margin: 4px 0;">@UteeDriverSupport</div>
                                <div style="font-size: 0.85rem; color: #64748b;">Hỗ trợ đối soát thu nhập, cập nhật biển số xe và giấy tờ</div>
                            </div>
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
                                Vui lòng gọi tối thiểu 3 cuộc cách nhau 3 phút. Nếu sau 10 phút khách không phản hồi, hãy bấm nút <strong>"Báo Giao Thất Bại / Bom Hàng"</strong> trên màn hình đơn hàng và liên hệ tổng đài 1900 6869 để được hỗ trợ đối soát bồi hoàn phí ship và xử lý hoàn món.
                            </p>
                        </details>

                        <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 18px; cursor: pointer;">
                            <summary style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                <i class="fa-solid fa-circle-question text-primary me-2"></i> Khi nào tiền thù lao cuốc xe được cộng vào ví tài xế?
                            </summary>
                            <p style="margin: 10px 0 0 0; color: #475569; font-size: 0.9rem; line-height: 1.6;">
                                Sau khi bạn bấm <strong>"Xác nhận đã giao cho khách"</strong> và đơn hàng hoàn tất, thù lao 15.000 đ/cuốc sẽ được cộng tức thì vào số dư ví hoạt động của bạn.
                            </p>
                        </details>

                        <details style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 18px; cursor: pointer;">
                            <summary style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                <i class="fa-solid fa-circle-question text-primary me-2"></i> Gặp sự cố hỏng xe hoặc va chạm trên đường giao hàng?
                            </summary>
                            <p style="margin: 10px 0 0 0; color: #475569; font-size: 0.9rem; line-height: 1.6;">
                                Ưu tiên an toàn bản thân lên hàng đầu. Hãy dừng lại nơi an toàn và chọn mục <strong>"Trả Cuốc"</strong> với lý do "Xe hỏng", hoặc gọi ngay hotline 1900 6869 nhánh 1 để điều phối viên gán tài xế khác hỗ trợ mà không bị trừ điểm hạnh kiểm.
                            </p>
                        </details>
                    </div>

                    <!-- Online Ticket Form -->
                    <div style="background: #fff; border: 1px solid #cbd5e1; border-radius: 14px; padding: 22px;">
                        <h4 style="font-size: 1.05rem; font-weight: 800; color: #1e293b; margin-bottom: 14px;">
                            <i class="fa-solid fa-paper-plane text-primary me-2"></i> Gửi Yêu Cầu Hỗ Trợ Trực Tuyến
                        </h4>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Loại vấn đề cần hỗ trợ:</label>
                                <select class="form-control" style="border-radius: 10px;">
                                    <option>Đối soát thu nhập / Rút tiền ví</option>
                                    <option>Khiếu nại điểm vi phạm / Đánh giá sao</option>
                                    <option>Cập nhật biển số xe / Số điện thoại</option>
                                    <option>Vấn đề khác</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Mã cuốc xe liên quan (nếu có):</label>
                                <input type="text" class="form-control" placeholder="Ví dụ: #FZ-12" style="border-radius: 10px;">
                            </div>
                            <div class="col-12">
                                <label style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 4px; display: block;">Nội dung chi tiết:</label>
                                <textarea class="form-control" rows="3" placeholder="Mô tả sự cố bạn gặp phải để CSKH hỗ trợ nhanh nhất..." style="border-radius: 10px;"></textarea>
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

<!-- ===================================================================== -->
<!-- 3. MODALS: NẠP VÍ, RÚT TIỀN, BÁO GIAO THẤT BẠI (BOM HÀNG)             -->
<!-- ===================================================================== -->

<!-- Modal Nạp Tiền Vào Ví Hoạt Động -->
<div id="topupWalletModal" class="modal-overlay" onclick="if(event.target===this) closeTopupModal();" style="display: none;">
    <div class="modal-content">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                    <i class="fa-solid fa-plus-circle"></i>
                </div>
                <div>
                    <h3 style="font-size: 1.2rem; font-weight: 800; color: #1e293b; margin: 0;">Nạp Tiền Vào Ví Hoạt Động</h3>
                    <div style="font-size: 0.82rem; color: #64748b;">
                        Số dư hiện tại: <strong class="text-primary"><fmt:formatNumber value="${walletBalance}" pattern="#,###" /> đ</strong>
                    </div>
                </div>
            </div>
            <button type="button" onclick="closeTopupModal()" style="background: transparent; border: none; font-size: 1.4rem; color: #94a3b8; cursor: pointer; padding: 4px 8px; border-radius: 8px;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="topupWallet">

            <div style="margin-bottom: 16px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 8px;">
                    Chọn nhanh mệnh giá nạp
                </label>
                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
                    <button type="button" class="btn btn-outline-primary topup-preset-btn" onclick="selectTopupPreset(50000)" style="font-weight: 700; border-radius: 10px; padding: 10px;">
                        50.000 đ
                    </button>
                    <button type="button" class="btn btn-outline-primary topup-preset-btn" onclick="selectTopupPreset(100000)" style="font-weight: 700; border-radius: 10px; padding: 10px;">
                        100.000 đ
                    </button>
                    <button type="button" class="btn btn-outline-primary topup-preset-btn active" onclick="selectTopupPreset(200000)" style="font-weight: 700; border-radius: 10px; padding: 10px;">
                        200.000 đ
                    </button>
                    <button type="button" class="btn btn-outline-primary topup-preset-btn" onclick="selectTopupPreset(500000)" style="font-weight: 700; border-radius: 10px; padding: 10px;">
                        500.000 đ
                    </button>
                </div>
            </div>

            <div style="margin-bottom: 18px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 6px;">
                    Hoặc nhập số tiền khác (VNĐ) <span style="color: #dc2626;">*</span>
                </label>
                <div style="position: relative;">
                    <input type="number" name="amount" id="topupAmountInput" class="form-control" min="10000" step="5000" value="200000" required style="border-radius: 10px; padding: 12px 45px 12px 14px; font-size: 1.15rem; font-weight: 800; color: #1e3a8a;">
                    <span style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); font-weight: 700; color: #94a3b8;">đ</span>
                </div>
                <small style="color: #64748b; font-size: 0.78rem; display: block; margin-top: 4px;">
                    <i class="fa-solid fa-circle-info me-1"></i> Tối thiểu 10.000 đ. Số dư ví dùng để ký quỹ đơn COD và nhận đơn liên tục.
                </small>
            </div>

            <div style="margin-bottom: 22px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 8px;">
                    Phương thức thanh toán
                </label>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <label style="display: flex; align-items: center; gap: 12px; padding: 10px 14px; border: 1.5px solid #2563eb; background: #eff6ff; border-radius: 10px; cursor: pointer;">
                        <input type="radio" name="paymentMethod" value="Chuyển khoản VietQR" checked style="accent-color: #2563eb;">
                        <i class="fa-solid fa-qrcode text-primary" style="font-size: 1.3rem;"></i>
                        <div style="flex: 1;">
                            <div style="font-weight: 700; font-size: 0.9rem; color: #1e293b;">Chuyển khoản nhanh VietQR 24/7</div>
                            <div style="font-size: 0.75rem; color: #64748b;">Quét mã QR từ mọi ứng dụng ngân hàng, tiền vào ví tức thì</div>
                        </div>
                    </label>
                    <label style="display: flex; align-items: center; gap: 12px; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 10px; cursor: pointer;">
                        <input type="radio" name="paymentMethod" value="Ví điện tử MoMo" style="accent-color: #2563eb;">
                        <i class="fa-solid fa-wallet text-danger" style="font-size: 1.3rem;"></i>
                        <div style="flex: 1;">
                            <div style="font-weight: 700; font-size: 0.9rem; color: #1e293b;">Ví MoMo / VNPay</div>
                            <div style="font-size: 0.75rem; color: #64748b;">Xác thực tiện lợi qua ứng dụng ví điện tử</div>
                        </div>
                    </label>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                <button type="button" onclick="closeTopupModal()" class="btn btn-light" style="border-radius: 50px; font-weight: 600; padding: 10px 20px; border: 1px solid #cbd5e1; color: #475569;">
                    Hủy bỏ
                </button>
                <button type="submit" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 10px 24px;">
                    <i class="fa-solid fa-check me-2"></i> Xác Nhận Nạp Tiền
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Rút Tiền Về Ngân Hàng -->
<div id="withdrawWalletModal" class="modal-overlay" onclick="if(event.target===this) closeWithdrawModal();" style="display: none;">
    <div class="modal-content">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #ecfdf5; color: #10ac84; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                    <i class="fa-solid fa-money-bill-transfer"></i>
                </div>
                <div>
                    <h3 style="font-size: 1.2rem; font-weight: 800; color: #1e293b; margin: 0;">Rút Tiền Về Ngân Hàng</h3>
                    <div style="font-size: 0.82rem; color: #64748b;">
                        Khả dụng: <strong class="text-success"><fmt:formatNumber value="${walletBalance}" pattern="#,###" /> đ</strong>
                    </div>
                </div>
            </div>
            <button type="button" onclick="closeWithdrawModal()" style="background: transparent; border: none; font-size: 1.4rem; color: #94a3b8; cursor: pointer; padding: 4px 8px; border-radius: 8px;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/shipper/dashboard" method="POST">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="withdrawWallet">

            <!-- Thông tin tài khoản nhận tiền -->
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px 16px; margin-bottom: 18px;">
                <div style="font-size: 0.78rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 4px;">Tài khoản nhận tiền</div>
                <div style="font-size: 0.95rem; font-weight: 800; color: #1e293b;">
                    MB Bank (Quân Đội) • 9999****8888
                </div>
                <div style="font-size: 0.85rem; color: #475569; margin-top: 2px;">
                    Chủ tài khoản: <strong>${sessionScope.currentUser.fullName.toUpperCase()}</strong>
                </div>
                <input type="hidden" name="bankName" value="MB Bank">
                <input type="hidden" name="accountNumber" value="99998888">
                <input type="hidden" name="accountName" value="${sessionScope.currentUser.fullName}">
            </div>

            <!-- Mốc tiền rút nhanh -->
            <div style="margin-bottom: 16px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 8px;">
                    Mốc tiền rút nhanh
                </label>
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;">
                    <button type="button" class="btn btn-outline-success withdraw-preset-btn" onclick="selectWithdrawPreset(100000)" style="font-weight: 700; border-radius: 10px; padding: 8px; font-size: 0.88rem;">
                        100.000 đ
                    </button>
                    <button type="button" class="btn btn-outline-success withdraw-preset-btn active" onclick="selectWithdrawPreset(200000)" style="font-weight: 700; border-radius: 10px; padding: 8px; font-size: 0.88rem;">
                        200.000 đ
                    </button>
                    <c:set var="maxWithdrawable" value="${walletBalance > 50000 ? walletBalance - 50000 : 50000}" />
                    <button type="button" class="btn btn-outline-success withdraw-preset-btn" onclick="selectWithdrawPreset(${maxWithdrawable})" style="font-weight: 700; border-radius: 10px; padding: 8px; font-size: 0.88rem;">
                        Rút tối đa
                    </button>
                </div>
            </div>

            <!-- Nhập số tiền rút -->
            <div style="margin-bottom: 18px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 6px;">
                    Số tiền cần rút (VNĐ) <span style="color: #dc2626;">*</span>
                </label>
                <div style="position: relative;">
                    <input type="number" name="amount" id="withdrawAmountInput" class="form-control" min="50000" max="${walletBalance}" step="10000" value="200000" required style="border-radius: 10px; padding: 12px 45px 12px 14px; font-size: 1.15rem; font-weight: 800; color: #15803d;">
                    <span style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); font-weight: 700; color: #94a3b8;">đ</span>
                </div>
                <small style="color: #64748b; font-size: 0.78rem; display: block; margin-top: 4px;">
                    <i class="fa-solid fa-shield-halved me-1"></i> Tối thiểu 50.000 đ. Khuyến nghị duy trì số dư ví 50.000 đ để tiếp tục nhận đơn COD.
                </small>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                <button type="button" onclick="closeWithdrawModal()" class="btn btn-light" style="border-radius: 50px; font-weight: 600; padding: 10px 20px; border: 1px solid #cbd5e1; color: #475569;">
                    Hủy bỏ
                </button>
                <button type="submit" class="btn btn-success" style="border-radius: 50px; font-weight: 700; padding: 10px 24px; background: #10ac84; border-color: #10ac84;">
                    <i class="fa-solid fa-paper-plane me-2"></i> Xác Nhận Rút Tiền
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Báo Cáo Giao Thất Bại / Bom Hàng Kèm Bằng Chứng -->
<div id="reportFailedModal" class="modal-overlay" onclick="if(event.target===this) closeReportFailedModal();" style="display: none;">
    <div class="modal-content" style="max-width: 560px;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; padding-bottom: 16px; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 1.3rem;">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>
                <div>
                    <h3 style="font-size: 1.2rem; font-weight: 800; color: #1e293b; margin: 0;">Báo Cáo Giao Thất Bại / Bom Hàng</h3>
                    <div style="font-size: 0.82rem; color: #64748b;">
                        Mã đơn: <strong class="text-danger" id="reportFailedOrderBadge">#FZ-${not empty activeOrder ? activeOrder.id : '---'}</strong> • Khách: <strong id="reportFailedCustomerName">${not empty activeOrder ? activeOrder.customerName : 'Khách hàng'}</strong>
                    </div>
                </div>
            </div>
            <button type="button" onclick="closeReportFailedModal()" style="background: transparent; border: none; font-size: 1.4rem; color: #94a3b8; cursor: pointer; padding: 4px 8px; border-radius: 8px;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div style="background: #fffbeb; border: 1px solid #fef3c7; border-left: 4px solid #f59e0b; border-radius: 10px; padding: 14px 16px; margin-bottom: 20px;">
            <div style="font-weight: 700; color: #b45309; font-size: 0.92rem; margin-bottom: 4px;">
                <i class="fa-solid fa-shield-halved me-1"></i> CẢNH BÁO QUAN TRỌNG:
            </div>
            <p style="font-size: 0.84rem; color: #78350f; margin: 0; line-height: 1.5;">
                Hành động này sẽ <strong>hạn chế phương thức thanh toán tiền mặt (COD)</strong> của khách hàng và gửi hồ sơ đối soát đến <strong>Ban Quản Trị</strong>. Vui lòng cung cấp hình ảnh chụp cuộc gọi nhỡ (tối thiểu 3 cuộc) hoặc ảnh chụp tại địa chỉ giao hàng để bảo vệ quyền lợi tài xế.
            </p>
        </div>

        <form id="reportFailedForm" action="${pageContext.request.contextPath}/shipper/dashboard" method="POST" enctype="multipart/form-data" onsubmit="return validateReportFailedForm(this);">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="action" value="updateOrder">
            <input type="hidden" name="status" value="FAILED_DELIVERY">
            <input type="hidden" name="orderId" id="reportFailedOrderId" value="${not empty activeOrder ? activeOrder.id : ''}">

            <div style="margin-bottom: 18px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 6px;">
                    Lý do giao thất bại <span style="color: #dc2626;">*</span>
                </label>
                <select name="cancelReason" id="reportFailedReason" class="form-select" required style="width: 100%; height: 44px; border-radius: 10px; border: 1.5px solid #cbd5e1; font-size: 0.9rem; font-weight: 500; background-color: #fff; color: #1e293b; padding: 0 38px 0 14px; line-height: normal; box-sizing: border-box;">
                    <option value="">-- Chọn lý do cụ thể --</option>
                    <option value="Khách hàng không nghe máy (đã gọi nhiều cuộc)">📞 Khách không nghe máy (đã gọi tối thiểu 3 cuộc)</option>
                    <option value="Khách từ chối nhận món / hủy ngang khi shipper đến">🚫 Khách từ chối nhận món / hủy ngang khi đã đến nơi</option>
                    <option value="Sai địa chỉ / Không thể tìm thấy người nhận">📍 Sai địa chỉ / Không có người nhận tại địa chỉ</option>
                    <option value="Khách hẹn dời giờ giao quá lâu (trên 30 phút)">⏳ Khách hẹn dời giờ giao quá lâu (không thể chờ)</option>
                    <option value="Khách không đủ tiền mặt / không thanh toán COD">💵 Khách không đủ tiền mặt / không chịu thanh toán COD</option>
                    <option value="Lý do bất khả kháng khác từ phía khách">⚠️ Lý do khác từ phía khách hàng</option>
                </select>
            </div>

            <div style="margin-bottom: 18px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 6px;">
                    Ghi chú chi tiết &amp; Lịch sử liên hệ <span style="color: #dc2626;">*</span>
                </label>
                <textarea name="shipperNote" id="reportFailedNote" rows="3" class="form-control" required placeholder="Ví dụ: Đã đến địa chỉ lúc 11:30. Đã gọi 3 cuộc lúc 11:30, 11:36, 11:42 khách đều tắt máy hoặc không nghe..." style="width: 100%; border-radius: 10px; padding: 10px 14px; border: 1.5px solid #cbd5e1; font-size: 0.88rem;"></textarea>
                <small style="color: #64748b; font-size: 0.78rem; display: block; margin-top: 4px;">
                    <i class="fa-solid fa-circle-info me-1"></i> Ghi chi tiết mốc thời gian gọi điện để làm bằng chứng đối soát khi khách khiếu nại.
                </small>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; font-weight: 700; font-size: 0.9rem; color: #334155; margin-bottom: 6px;">
                    Hình ảnh bằng chứng (Ảnh cuộc gọi nhỡ / Ảnh địa chỉ)
                </label>
                <div style="border: 2px dashed #cbd5e1; border-radius: 12px; padding: 16px; text-align: center; background: #f8fafc; cursor: pointer;" onclick="document.getElementById('proofImageInput').click();">
                    <input type="file" name="proofImage" id="proofImageInput" accept="image/*" capture="environment" style="display: none;" onchange="previewProofImage(this);">
                    <div id="proofPlaceholder">
                        <i class="fa-solid fa-camera text-primary" style="font-size: 2rem; margin-bottom: 8px;"></i>
                        <div style="font-weight: 600; font-size: 0.9rem; color: #334155;">Bấm để chụp ảnh hoặc tải ảnh lên</div>
                        <div style="font-size: 0.78rem; color: #64748b; margin-top: 4px;">Ảnh màn hình cuộc gọi nhỡ (khuyến nghị) hoặc ảnh mặt tiền nhà/địa chỉ (JPG, PNG - Tối đa 10MB)</div>
                    </div>
                    <div id="proofPreviewContainer" style="display: none; margin-top: 8px; position: relative;">
                        <img id="proofPreviewImg" src="" alt="Bằng chứng" style="max-height: 180px; max-width: 100%; border-radius: 8px; border: 1px solid #cbd5e1; object-fit: contain;">
                        <div style="margin-top: 8px;">
                            <span id="proofFileName" style="font-size: 0.8rem; font-weight: 600; color: #16a34a;"></span>
                            <button type="button" class="btn btn-sm btn-link text-danger ms-2" onclick="removeProofImage(event)" style="font-size: 0.8rem; text-decoration: none;">
                                <i class="fa-solid fa-trash me-1"></i> Xóa ảnh
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div style="margin-bottom: 22px; background: #f1f5f9; border-radius: 10px; padding: 10px 14px;">
                <label style="display: flex; align-items: flex-start; gap: 8px; font-size: 0.82rem; color: #334155; margin: 0; cursor: pointer;">
                    <input type="checkbox" id="confirmCommitment" required style="margin-top: 3px; cursor: pointer;">
                    <span>Tôi cam kết thông tin và bằng chứng cung cấp là hoàn toàn chính xác, trung thực. Tôi chịu trách nhiệm trước quy chế tài xế nếu báo cáo sai lệch.</span>
                </label>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                <button type="button" onclick="closeReportFailedModal()" class="btn btn-light" style="border-radius: 50px; font-weight: 600; padding: 10px 20px; border: 1px solid #cbd5e1; color: #475569;">
                    Hủy bỏ
                </button>
                <button type="submit" class="btn btn-danger" style="border-radius: 50px; font-weight: 700; padding: 10px 24px; background: #dc2626; border-color: #dc2626; box-shadow: 0 4px 14px rgba(220, 38, 38, 0.35);">
                    <i class="fa-solid fa-cloud-arrow-up me-2"></i> Gửi Bằng Chứng &amp; Báo Hỏng
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================================================================== -->
<!-- 4. SCRIPTS & LOGIC (GPS, POLLING, MODALS, NOTES)                      -->
<!-- ===================================================================== -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const portalRoot = document.getElementById('shipperPortalRoot');
        const driverStatus = portalRoot ? (portalRoot.getAttribute('data-driver-status') || '') : '';
        const csrfToken = portalRoot ? (portalRoot.getAttribute('data-csrf-token') || '') : '';
        const contextPath = portalRoot ? (portalRoot.getAttribute('data-context-path') || '') : '';

        // Phục hồi vị trí mô phỏng lưu trong localStorage
        const savedLat = localStorage.getItem('shipper_mock_lat');
        const savedLng = localStorage.getItem('shipper_mock_lng');
        const savedAddr = localStorage.getItem('shipper_mock_address');
        if (savedLat && savedLng && savedAddr) {
            const locDisp = document.getElementById('currentLocDisplay');
            const coordsDisp = document.getElementById('gpsCoordsText');
            if (locDisp) locDisp.innerText = savedAddr;
            if (coordsDisp) coordsDisp.innerText = parseFloat(savedLat).toFixed(6) + ', ' + parseFloat(savedLng).toFixed(6);
        }

        function sendLocationUpdate(lat, lng, address) {
            const formData = new URLSearchParams();
            formData.append('latitude', lat);
            formData.append('longitude', lng);
            if (address) formData.append('address', address);
            if (csrfToken) formData.append('csrfToken', csrfToken);

            fetch(contextPath + '/shipper/api/location', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data && data.status === 'success') {
                    const locDisp = document.getElementById('currentLocDisplay');
                    const coordsDisp = document.getElementById('gpsCoordsText');
                    const updatedDisp = document.getElementById('gpsUpdatedTime');
                    if (locDisp && data.address) locDisp.innerText = data.address;
                    if (coordsDisp) coordsDisp.innerText = lat.toFixed(6) + ', ' + lng.toFixed(6);
                    if (updatedDisp) {
                        const now = new Date();
                        updatedDisp.innerText = (now.getHours() < 10 ? '0' : '') + now.getHours() + ':' + (now.getMinutes() < 10 ? '0' : '') + now.getMinutes() + ' ' + (now.getDate() < 10 ? '0' : '') + now.getDate() + '/' + (now.getMonth() + 1);
                    }
                }
            })
            .catch(err => console.error("Lỗi cập nhật GPS:", err));
        }

        // Bấm nút GPS thật
        const btnRealGps = document.getElementById('btnGetRealGps');
        if (btnRealGps) {
            btnRealGps.addEventListener('click', function() {
                if ("geolocation" in navigator) {
                    btnRealGps.disabled = true;
                    btnRealGps.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang bắt GPS...';
                    navigator.geolocation.getCurrentPosition(
                        function(position) {
                            btnRealGps.disabled = false;
                            btnRealGps.innerHTML = '<i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật';
                            const lat = position.coords.latitude;
                            const lng = position.coords.longitude;
                            sendLocationUpdate(lat, lng, null);
                        },
                        function(error) {
                            btnRealGps.disabled = false;
                            btnRealGps.innerHTML = '<i class="fa-solid fa-satellite-dish"></i> Bật GPS Máy Thật';
                            alert('Không thể lấy tọa độ GPS từ trình duyệt: ' + error.message + '\nBạn có thể sử dụng dropdown mô phỏng vị trí nhanh bên dưới.');
                        },
                        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
                    );
                } else {
                    alert('Trình duyệt của bạn không hỗ trợ định vị Geolocation!');
                }
            });
        }

        // Bấm nút đặt vị trí mô phỏng
        const btnApplyMock = document.getElementById('btnApplyMockLocation');
        const selectMock = document.getElementById('mockLocationSelect');
        if (btnApplyMock && selectMock) {
            btnApplyMock.addEventListener('click', function() {
                const val = selectMock.value;
                const parts = val.split('|');
                const coords = parts[0].split(',');
                const lat = parseFloat(coords[0]);
                const lng = parseFloat(coords[1]);
                const addr = parts[1];

                localStorage.setItem('shipper_mock_lat', lat);
                localStorage.setItem('shipper_mock_lng', lng);
                localStorage.setItem('shipper_mock_address', addr);

                sendLocationUpdate(lat, lng, addr);
            });
        }

        // Polling quét đơn tự động (khi AVAILABLE)
        if (driverStatus === 'AVAILABLE') {
            let isDisplayingOrder = false;
            setInterval(function() {
                if (isDisplayingOrder) return;
                fetch(contextPath + '/shipper/api/dispatch')
                    .then(res => res.json())
                    .then(data => {
                        if (data && data.status === 'found') {
                            isDisplayingOrder = true;
                            const rScan = document.getElementById('radarScan');
                            const oPop = document.getElementById('orderPopup');
                            if (rScan) rScan.style.display = 'none';
                            if (oPop) oPop.style.display = 'block';

                            const pOId = document.getElementById('pOrderId');
                            const pCust = document.getElementById('pCustomer');
                            const pAddr = document.getElementById('pAddress');
                            const pAmt = document.getElementById('pAmount');
                            const fOId = document.getElementById('fOrderId');

                            if (pOId) pOId.innerText = '#FZ-' + data.orderId;
                            if (pCust) pCust.innerText = data.customer || 'Khách hàng Utee';
                            if (pAddr) pAddr.innerHTML = '<i class="fa-solid fa-location-dot text-danger me-1"></i> ' + (data.address || 'Khu vực nội thành TP.HCM');
                            if (pAmt) pAmt.innerText = new Intl.NumberFormat('vi-VN').format(data.amount || 0);
                            if (fOId) fOId.value = data.orderId;

                            try {
                                let ding = new Audio('https://www.myinstants.com/media/sounds/ding-sound-effect_2.mp3');
                                ding.play().catch(e => console.log('Audio autoplay blocked by browser'));
                            } catch(e) {}
                        }
                    })
                    .catch(err => console.error("Lỗi polling dispatch:", err));
            }, 4000);
        }

        // Format order notes
        document.querySelectorAll('.order-note-container').forEach(el => {
            let html = el.innerHTML;
            const regex = /\[Shipper Trả Đơn:\s*(.*?)\]/g;
            if (regex.test(html)) {
                html = html.replace(regex, '<br><span class="badge bg-danger text-white mt-1" style="font-size: 0.8rem; border-radius: 6px;"><i class="fa-solid fa-triangle-exclamation"></i> Chú ý: Shipper trước báo hủy - $1</span>');
            }
            const boomRegex = /\[(BOM HÀNG|BOM HÀNG \/ GIAO THẤT BẠI):\s*(.*?)\]/g;
            if (boomRegex.test(html)) {
                html = html.replace(boomRegex, '<br><span class="badge bg-dark text-warning mt-1" style="font-size: 0.8rem; border-radius: 6px;"><i class="fa-solid fa-triangle-exclamation"></i> Giao thất bại: $2</span>');
            }
            el.innerHTML = html;
        });
    });

    // Modal Handlers
    function openReportFailedModal(orderId, customerName) {
        const modal = document.getElementById('reportFailedModal');
        if (!modal) return;
        if (orderId) {
            const inputEl = document.getElementById('reportFailedOrderId');
            if (inputEl) inputEl.value = orderId;
            const badgeEl = document.getElementById('reportFailedOrderBadge');
            if (badgeEl) badgeEl.innerText = '#FZ-' + orderId;
        }
        if (customerName) {
            const custEl = document.getElementById('reportFailedCustomerName');
            if (custEl) custEl.innerText = customerName;
        }
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeReportFailedModal() {
        const modal = document.getElementById('reportFailedModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }
    }

    function openTopupModal() {
        const modal = document.getElementById('topupWalletModal');
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }

    function closeTopupModal() {
        const modal = document.getElementById('topupWalletModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }
    }

    function selectTopupPreset(amount) {
        const input = document.getElementById('topupAmountInput');
        if (input) input.value = amount;
        document.querySelectorAll('.topup-preset-btn').forEach(btn => btn.classList.remove('active'));
        if (event && event.target) event.target.classList.add('active');
    }

    function openWithdrawModal() {
        const modal = document.getElementById('withdrawWalletModal');
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }

    function closeWithdrawModal() {
        const modal = document.getElementById('withdrawWalletModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }
    }

    function selectWithdrawPreset(amount) {
        const input = document.getElementById('withdrawAmountInput');
        if (input) input.value = Math.max(50000, Math.round(amount));
        document.querySelectorAll('.withdraw-preset-btn').forEach(btn => btn.classList.remove('active'));
        if (event && event.target) event.target.classList.add('active');
    }

    function previewProofImage(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            if (file.size > 10 * 1024 * 1024) {
                alert('Dung lượng ảnh vượt quá 10MB. Vui lòng chọn ảnh nhỏ hơn!');
                input.value = '';
                return;
            }
            const reader = new FileReader();
            reader.onload = function(e) {
                const previewImg = document.getElementById('proofPreviewImg');
                const previewContainer = document.getElementById('proofPreviewContainer');
                const placeholder = document.getElementById('proofPlaceholder');
                const fileName = document.getElementById('proofFileName');
                if (previewImg && previewContainer && placeholder) {
                    previewImg.src = e.target.result;
                    previewContainer.style.display = 'block';
                    placeholder.style.display = 'none';
                    if (fileName) fileName.innerText = '✓ ' + file.name;
                }
            };
            reader.readAsDataURL(file);
        }
    }

    function removeProofImage(event) {
        if (event) event.stopPropagation();
        const input = document.getElementById('proofImageInput');
        const previewContainer = document.getElementById('proofPreviewContainer');
        const placeholder = document.getElementById('proofPlaceholder');
        const previewImg = document.getElementById('proofPreviewImg');
        const fileName = document.getElementById('proofFileName');
        if (input) input.value = '';
        if (previewImg) previewImg.src = '';
        if (fileName) fileName.innerText = '';
        if (previewContainer) previewContainer.style.display = 'none';
        if (placeholder) placeholder.style.display = 'block';
    }

    function validateReportFailedForm(form) {
        const reason = form.cancelReason.value;
        if (!reason || !reason.trim()) {
            alert('Vui lòng chọn lý do giao thất bại!');
            form.cancelReason.focus();
            return false;
        }
        const note = form.shipperNote.value;
        if (!note || note.trim().length < 5) {
            alert('Vui lòng nhập ghi chú chi tiết (tối thiểu 5 ký tự)!');
            form.shipperNote.focus();
            return false;
        }
        const fileInput = document.getElementById('proofImageInput');
        if (!fileInput || !fileInput.files || fileInput.files.length === 0) {
            const proceed = confirm('⚠️ CẢNH BÁO: BẠN CHƯA ĐÍNH KÈM ẢNH BẰNG CHỨNG (Lịch sử cuộc gọi / ảnh địa chỉ)!\n\nNếu khách hàng khiếu nại và tài xế không có bằng chứng, tài xế có thể bị xử lý kỷ luật.\n\nBạn có chắc muốn tiếp tục gửi báo cáo mà không có ảnh bằng chứng?');
            if (!proceed) return false;
        }
        const commitment = document.getElementById('confirmCommitment');
        if (commitment && !commitment.checked) {
            alert('Vui lòng tích vào ô cam kết trước khi gửi báo cáo!');
            commitment.focus();
            return false;
        }
        const orderIdVal = document.getElementById('reportFailedOrderId') ? document.getElementById('reportFailedOrderId').value : '';
        return confirm('⚠️ XÁC NHẬN BÁO CÁO GIAO THẤT BẠI CHO ĐƠN #FZ-' + orderIdVal + '?\n\nHành động này sẽ tạm khóa quyền thanh toán COD của khách và gửi hồ sơ đến Ban Quản Trị.');
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
