<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Tài Khoản Của Tôi - Utee Express" />
</jsp:include>

<!-- Page Banner -->
<div class="page-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>Tài khoản của tôi</span>
        </div>
        <h1 class="page-title">
            <c:choose>
                <c:when test="${user.seller or user.role eq 'SELLER'}">Hồ Sơ Đối Tác Quán Ăn</c:when>
                <c:when test="${user.isShipper()}">Hồ Sơ Tài Xế Giao Hàng</c:when>
                <c:otherwise>Tài Khoản &amp; Hồ Sơ Khách Hàng</c:otherwise>
            </c:choose>
        </h1>
    </div>
</div>

<div class="container section profile-page-container">
    <!-- User Notification Banners -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible" role="alert">
            <div class="alert-content">
                <i class="fa-solid fa-circle-check alert-icon"></i>
                <span>${successMessage}</span>
            </div>
            <button type="button" class="alert-close" onclick="this.parentElement.style.display='none';">&times;</button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible" role="alert">
            <div class="alert-content">
                <i class="fa-solid fa-circle-exclamation alert-icon"></i>
                <span>${errorMessage}</span>
            </div>
            <button type="button" class="alert-close" onclick="this.parentElement.style.display='none';">&times;</button>
        </div>
    </c:if>

    <!-- Merchant Mode Status Banner -->
    <c:if test="${user.seller or user.role eq 'SELLER'}">
        <div class="alert alert-info" style="border-radius: 14px; margin-bottom: 24px; padding: 18px 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; box-shadow: 0 4px 14px rgba(0,0,0,0.04); border-left: 5px solid var(--primary-color); background: #fff5f5;">
            <div style="display: flex; align-items: center; gap: 14px;">
                <div style="width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: rgba(240, 84, 84, 0.12); color: var(--primary-color); font-size: 1.3rem;">
                    <i class="fa-solid fa-store"></i>
                </div>
                <div>
                    <h5 style="margin: 0; font-weight: 700; font-size: 1.05rem; color: #1e293b;">
                        Tài khoản Đối Tác Quán Ăn: <strong>${not empty currentRestaurant.name ? currentRestaurant.name : 'Utee Merchant'}</strong>
                    </h5>
                    <p style="margin: 3px 0 0 0; font-size: 0.88rem; color: var(--text-muted);">
                        Quán ăn quản lý thực đơn, nhận và xử lý đơn hàng của khách tại Kênh Quán Ăn (tài khoản quán không đặt đồ ăn).
                    </p>
                </div>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <a href="${pageContext.request.contextPath}/merchant/dashboard" class="btn btn-primary btn-sm" style="border-radius: 50px; font-weight: 600; padding: 8px 18px;">
                    <i class="fa-solid fa-gauge-high me-1"></i> Kênh Quán Ăn
                </a>
                <a href="${pageContext.request.contextPath}/merchant/orders" class="btn btn-outline btn-sm" style="border-radius: 50px; font-weight: 600; padding: 8px 18px;">
                    <i class="fa-solid fa-receipt me-1"></i> Đơn hàng của quán
                </a>
            </div>
        </div>
    </c:if>

    <!-- Shipper Mode Status Banner -->
    <c:if test="${user.isShipper()}">
        <div class="alert ${sessionScope.shipperActive ? 'alert-success' : 'alert-info'}" style="border-radius: 14px; margin-bottom: 24px; padding: 18px 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 14px; box-shadow: 0 4px 14px rgba(0,0,0,0.04); border-left: 5px solid ${sessionScope.shipperActive ? '#10ac84' : '#ff9f43'};">
            <div style="display: flex; align-items: center; gap: 14px;">
                <div style="width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; background: ${sessionScope.shipperActive ? '#e6f9ed' : '#f1f5f9'}; color: ${sessionScope.shipperActive ? '#10ac84' : '#64748b'}; font-size: 1.3rem;">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
                <div>
                    <h5 style="margin: 0; font-weight: 700; font-size: 1.05rem;">
                        ${sessionScope.shipperActive ? 'Chế độ Shipper: ĐANG BẬT (Trực Tuyến)' : 'Chế độ Shipper: ĐANG TẮT (Ngoại Tuyến / Khách Hàng)'}
                    </h5>
                    <p style="margin: 3px 0 0 0; font-size: 0.88rem; color: var(--text-muted);">
                        ${sessionScope.shipperActive ? 'Bạn đang trong ca trực sẵn sàng nhận cuốc xe. Giỏ hàng và tính năng đặt đồ ăn được tạm khóa để ưu tiên giao đơn.' : 'Bạn đang ngoại tuyến nhận đơn. Lúc này bạn có thể lướt thực đơn, đặt món ăn và xem lịch sử đơn đã đặt như khách bình thường.'}
                    </p>
                </div>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <c:choose>
                    <c:when test="${sessionScope.shipperActive}">
                        <a href="${pageContext.request.contextPath}/shipper/history" class="btn btn-outline btn-sm" style="border-radius: 50px; font-weight: 600;">
                            <i class="fa-solid fa-clock-rotate-left"></i> Chuyến xe đã giao
                        </a>
                        <a href="${pageContext.request.contextPath}/shipper/dashboard?action=toggleStatus&redirect=/profile" class="btn btn-danger btn-sm" style="border-radius: 50px; font-weight: 600;">
                            <i class="fa-solid fa-power-off"></i> Tắt nhận đơn (Làm khách)
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/shipper/dashboard?action=toggleStatus&redirect=/profile" class="btn btn-success btn-sm" style="border-radius: 50px; font-weight: 600;">
                            <i class="fa-solid fa-power-off"></i> Bật nhận đơn ngay
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:if>

    <!-- Profile Hero Card -->
    <div class="profile-hero-card">
        <div class="profile-hero-main">
            <div class="profile-avatar-box">
                <div class="profile-avatar-circle">
                    <span class="avatar-initials">
                        <c:choose>
                            <c:when test="${not empty user.fullName}">
                                ${user.fullName.substring(0, 1).toUpperCase()}
                            </c:when>
                            <c:otherwise>U</c:otherwise>
                        </c:choose>
                    </span>
                    <span class="avatar-status-dot" title="Tài khoản đang hoạt động"></span>
                </div>
            </div>
            <div class="profile-hero-info">
                <div class="profile-name-row">
                    <h2 class="profile-name">${user.fullName}</h2>
                    <c:choose>
                        <c:when test="${user.role eq 'ADMIN'}">
                            <span class="profile-badge badge-admin"><i class="fa-solid fa-shield-halved"></i> Quản Trị Viên</span>
                        </c:when>
                        <c:when test="${user.seller}">
                            <span class="profile-badge badge-seller"><i class="fa-solid fa-store"></i> Đối Tác Quán Ăn</span>
                        </c:when>
                        <c:when test="${user.isShipper()}">
                            <span class="profile-badge badge-shipper" style="background: ${sessionScope.shipperActive ? '#10ac84' : '#64748b'}; color: #fff;">
                                <i class="fa-solid fa-motorcycle"></i> ${sessionScope.shipperActive ? 'Shipper Trực Tuyến' : 'Shipper Ngoại Tuyến'}
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="profile-badge badge-customer"><i class="fa-solid fa-crown"></i> Khách Hàng Thân Thiết</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="profile-meta-list">
                    <span class="profile-meta-item"><i class="fa-solid fa-at text-muted"></i> <strong>Tên đăng nhập:</strong> ${user.username}</span>
                    <span class="profile-meta-item"><i class="fa-solid fa-phone text-muted"></i> <strong>SĐT:</strong> ${user.phone}</span>
                    <span class="profile-meta-item"><i class="fa-solid fa-envelope text-muted"></i> <strong>Email:</strong> ${user.email}</span>
                </div>
            </div>
        </div>

        <!-- KPI Stats Grid: Linh hoạt theo chế độ Shipper hay Khách hàng -->
        <c:choose>
            <c:when test="${user.isShipper() and sessionScope.shipperActive}">
                <div class="profile-stats-grid">
                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-success">
                            <i class="fa-solid fa-motorcycle"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${driverWallet.todayTrips != null ? driverWallet.todayTrips : 0} cuốc</div>
                            <div class="stat-label">Chuyến giao hôm nay</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-primary">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value"><fmt:formatNumber value="${driverWallet.todayEarnings != null ? driverWallet.todayEarnings : 0}" pattern="#,###" /> đ</div>
                            <div class="stat-label">Thu nhập hôm nay</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-info">
                            <i class="fa-solid fa-route"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${driverWallet.totalTrips != null ? driverWallet.totalTrips : 0} cuốc</div>
                            <div class="stat-label">Tổng chuyến hoàn thành</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-warning">
                            <i class="fa-solid fa-sack-dollar"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value"><fmt:formatNumber value="${driverWallet.totalEarnings != null ? driverWallet.totalEarnings : 0}" pattern="#,###" /> đ</div>
                            <div class="stat-label">Tổng thu nhập tích lũy</div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:when test="${user.seller or user.role eq 'SELLER'}">
                <div class="profile-stats-grid">
                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-primary">
                            <i class="fa-solid fa-store"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value" style="font-size: 1.15rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 150px;" title="${currentRestaurant.name != null ? currentRestaurant.name : 'Quán của tôi'}">
                                ${currentRestaurant.name != null ? currentRestaurant.name : 'Đối Tác Quán'}
                            </div>
                            <div class="stat-label">
                                <span class="badge ${currentRestaurant.status eq 'OPEN' ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}" style="font-size: 0.72rem; font-weight: 700;">
                                    ${currentRestaurant.status eq 'OPEN' ? 'Đang mở cửa' : 'Tạm đóng cửa'}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-warning">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${merchantKpis.todayOrders != null ? merchantKpis.todayOrders : 0}</div>
                            <div class="stat-label">Đơn nhận hôm nay</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-info">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${merchantKpis.activeOrders != null ? merchantKpis.activeOrders : 0}</div>
                            <div class="stat-label">Đơn quán đang xử lý</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-success">
                            <i class="fa-solid fa-sack-dollar"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">
                                <fmt:formatNumber value="${merchantKpis.todayRevenue != null ? merchantKpis.todayRevenue : 0}" pattern="#,###" /> đ
                            </div>
                            <div class="stat-label">Doanh thu hôm nay</div>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="profile-stats-grid">
                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-primary">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${totalOrders}</div>
                            <div class="stat-label">Tổng đơn đã đặt</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-warning">
                            <i class="fa-solid fa-motorcycle"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${activeOrders}</div>
                            <div class="stat-label">Đơn đang xử lý / giao</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-success">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${completedOrders}</div>
                            <div class="stat-label">Đơn đã hoàn tất</div>
                        </div>
                    </div>

                    <div class="profile-stat-box">
                        <div class="stat-icon-wrap stat-icon-info">
                            <i class="fa-solid fa-coins"></i>
                        </div>
                        <div class="stat-content">
                            <div class="stat-value">${String.format("%,.0f", totalSpent)} đ</div>
                            <div class="stat-label">Tổng chi tiêu</div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Navigation Tabs -->
    <div class="profile-tabs-wrapper">
        <div class="profile-tabs" role="tablist">
            <button type="button" class="profile-tab-btn ${activeTab eq 'profile' ? 'active' : ''}" onclick="switchTab('profile')">
                <i class="fa-solid fa-id-card"></i>
                <span>Thông tin cá nhân & Địa chỉ</span>
            </button>
            <c:choose>
                <c:when test="${user.isShipper() and sessionScope.shipperActive}">
                    <a href="${pageContext.request.contextPath}/shipper/history" class="profile-tab-btn" style="text-decoration: none;">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                        <span>Lịch sử chuyến giao (Tài xế)</span>
                        <span class="tab-count-badge" style="background:#10ac84; color:#fff;">Shipper</span>
                    </a>
                </c:when>
                <c:when test="${user.seller or user.role eq 'SELLER'}">
                    <!-- Quán ăn không được đặt đồ ăn: Không hiển thị tab Lịch sử đơn hàng đã đặt -->
                </c:when>
                <c:otherwise>
                    <button type="button" class="profile-tab-btn ${activeTab eq 'orders' ? 'active' : ''}" onclick="switchTab('orders')">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                        <span>Lịch sử đơn hàng đã đặt</span>
                        <span class="tab-count-badge">${totalOrders}</span>
                    </button>
                </c:otherwise>
            </c:choose>
            <button type="button" class="profile-tab-btn ${activeTab eq 'security' ? 'active' : ''}" onclick="switchTab('security')">
                <i class="fa-solid fa-shield-halved"></i>
                <span>Đổi mật khẩu & Bảo mật</span>
            </button>
            <button type="button" class="profile-tab-btn ${activeTab eq 'appearance' or param.tab eq 'appearance' ? 'active' : ''}" onclick="switchTab('appearance')">
                <i class="fa-solid fa-wand-magic-sparkles"></i>
                <span>Giao diện &amp; Chủ đề</span>
                <span class="tab-count-badge" style="background:var(--primary-color); color:#fff; font-size: 0.7rem;">Mới</span>
            </button>
        </div>
    </div>

    <!-- Tab 1: Thông tin cá nhân -->
    <div id="tab-profile" class="profile-tab-pane ${activeTab eq 'profile' ? 'active' : ''}">
        <div class="profile-grid">
            <!-- Left Info Column -->
            <div class="profile-sidebar-card">
                <div class="profile-card-header">
                    <h3 class="profile-card-title"><i class="fa-solid fa-circle-info text-primary"></i> Quyền lợi thành viên</h3>
                </div>
                <div class="profile-benefits-list">
                    <div class="benefit-item">
                        <div class="benefit-icon"><i class="fa-solid fa-bolt text-warning"></i></div>
                        <div class="benefit-text">
                            <strong>Giao siêu tốc 30 phút</strong>
                            <p>Đơn hàng được ưu tiên ghép tài xế gần quán ăn nhất</p>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <div class="benefit-icon"><i class="fa-solid fa-ticket text-primary"></i></div>
                        <div class="benefit-text">
                            <strong>Voucher tích lũy</strong>
                            <p>Tận hưởng mã giảm giá UTEE15 cho mọi đơn trên 99k</p>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <div class="benefit-icon"><i class="fa-solid fa-shield-check text-success"></i></div>
                        <div class="benefit-text">
                            <strong>Đảm bảo an toàn món ăn</strong>
                            <p>Đồ ăn đóng gói niêm phong cẩn thận trước khi giao</p>
                        </div>
                    </div>
                </div>

                <div class="profile-account-meta">
                    <div class="account-meta-row">
                        <span>Vai trò tài khoản:</span>
                        <strong>${user.role}</strong>
                    </div>
                    <div class="account-meta-row">
                        <span>Trạng thái bảo mật:</span>
                        <strong class="text-success"><i class="fa-solid fa-lock"></i> Đã xác thực</strong>
                    </div>
                </div>

                <c:if test="${user.seller or user.role eq 'SELLER'}">
                    <div style="margin-top: 18px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                        <a href="${pageContext.request.contextPath}/merchant/dashboard" class="btn btn-primary w-100 d-flex align-items-center justify-content-center gap-2" style="border-radius: 12px; font-weight: 700; padding: 11px;">
                            <i class="fa-solid fa-store"></i>
                            <span>Vào Kênh Quán Ăn</span>
                        </a>
                    </div>
                </c:if>
            </div>

            <!-- Right Form Column -->
            <div class="profile-main-card">
                <div class="profile-card-header">
                    <h3 class="profile-card-title"><i class="fa-solid fa-pen-to-square text-primary"></i> Cập nhật thông tin tài khoản</h3>
                    <p class="profile-card-subtitle">
                        <c:choose>
                            <c:when test="${user.seller or user.role eq 'SELLER'}">Thông tin người đại diện tài khoản đối tác quán ăn</c:when>
                            <c:otherwise>Thông tin sẽ được tự động điền khi bạn đặt đồ ăn tại VinDelivery</c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="POST" class="profile-form" id="updateProfileForm">
                    <input type="hidden" name="action" value="update_profile">

                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label" for="usernameField">Tên đăng nhập (Username)</label>
                            <div class="input-icon-wrap input-disabled">
                                <i class="fa-solid fa-user-lock input-icon"></i>
                                <input type="text" id="usernameField" class="form-control" value="${user.username}" readonly disabled>
                            </div>
                            <span class="form-help-text">Tên đăng nhập dùng cố định để định danh tài khoản</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="fullName">Họ và tên của bạn <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-user input-icon"></i>
                                <input type="text" id="fullName" name="fullName" class="form-control" value="${not empty stickyFullName ? stickyFullName : user.fullName}" required placeholder="Nhập họ và tên đầy đủ">
                            </div>
                        </div>
                    </div>

                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label" for="phone">${(user.seller or user.role eq 'SELLER') ? 'Số điện thoại liên hệ chủ quán' : 'Số điện thoại nhận hàng'} <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-phone input-icon"></i>
                                <input type="tel" id="phone" name="phone" class="form-control" value="${not empty stickyPhone ? stickyPhone : user.phone}" required pattern="^0[0-9]{9,10}$" placeholder="Ví dụ: 0987654321">
                            </div>
                            <span class="form-help-text">${(user.seller or user.role eq 'SELLER') ? 'Số điện thoại liên hệ quản trị và CSKH' : 'Tài xế sẽ gọi vào số này khi giao món'}</span>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="email">Địa chỉ Email <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-envelope input-icon"></i>
                                <input type="email" id="email" name="email" class="form-control" value="${not empty stickyEmail ? stickyEmail : user.email}" required placeholder="name@example.com">
                            </div>
                            <span class="form-help-text">Dùng để nhận hóa đơn và thông báo ưu đãi</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="address">${(user.seller or user.role eq 'SELLER') ? 'Địa chỉ liên hệ cá nhân' : 'Địa chỉ giao hàng mặc định'} <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="fa-solid fa-location-dot input-icon input-icon-textarea"></i>
                            <textarea id="address" name="address" class="form-control textarea-address" rows="3" required placeholder="Nhập số nhà, tên đường, phường/xã, quận/huyện...">${not empty stickyAddress ? stickyAddress : user.address}</textarea>
                        </div>
                        <span class="form-help-text">${(user.seller or user.role eq 'SELLER') ? 'Địa chỉ cá nhân của chủ tài khoản' : 'Địa chỉ giao hàng chính xác giúp tài xế tìm đường nhanh hơn'}</span>
                    </div>

                    <div class="profile-form-actions">
                        <button type="submit" id="btnSaveProfile" class="btn btn-primary btn-save-profile" disabled title="Chưa có thay đổi nào để lưu">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Tab 2: Lịch sử đơn hàng (Chỉ hiển thị cho khách hàng & Shipper - Quán ăn không đặt đồ ăn) -->
    <c:if test="${not user.seller and user.role ne 'SELLER'}">
    <div id="tab-orders" class="profile-tab-pane ${activeTab eq 'orders' ? 'active' : ''}">
        <!-- Orders Filter Bar -->
        <div class="orders-filter-bar">
            <div class="filter-pills">
                <button type="button" class="filter-pill active" onclick="filterOrders('ALL', this)">
                    Tất cả đơn (${orders != null ? orders.size() : 0})
                </button>
                <button type="button" class="filter-pill" onclick="filterOrders('PENDING', this)">
                    Chờ xác nhận
                </button>
                <button type="button" class="filter-pill" onclick="filterOrders('SHIPPING', this)">
                    Đang giao hàng
                </button>
                <button type="button" class="filter-pill" onclick="filterOrders('DELIVERED', this)">
                    Đã hoàn tất
                </button>
                <button type="button" class="filter-pill" onclick="filterOrders('CANCELLED', this)">
                    Đã hủy
                </button>
            </div>
        </div>

        <c:choose>
            <c:when test="${user.isShipper() and sessionScope.shipperActive}">
                <!-- Shipper Active Notice in Orders Tab -->
                <div class="empty-orders-card" style="border: 2px dashed #10ac84; background: #f0fdf9; padding: 48px 24px;">
                    <div class="empty-icon-wrap" style="background: #e6f9ed; color: #10ac84;">
                        <i class="fa-solid fa-motorcycle"></i>
                    </div>
                    <h3 class="empty-title" style="color: #065f46;">Chế độ Shipper đang BẬT</h3>
                    <p class="empty-desc" style="max-width: 520px; margin: 0 auto 24px auto;">
                        Bạn đang trực tuyến nhận đơn giao hàng. Lịch sử đơn đặt món cá nhân tạm ẩn. Bạn chỉ có thể xem <strong>lịch sử các cuốc xe bạn đi giao</strong> hoặc tắt chế độ shipper để xem đơn đặt.
                    </p>
                    <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/shipper/history" class="btn btn-primary btn-order-now" style="background: #10ac84; border-color: #10ac84;">
                            <i class="fa-solid fa-clock-rotate-left"></i> Xem lịch sử các chuyến giao
                        </a>
                        <a href="${pageContext.request.contextPath}/shipper/dashboard?action=toggleStatus&redirect=/profile?tab=orders" class="btn btn-outline" style="border-radius: 50px; padding: 12px 24px; font-weight: 600;">
                            <i class="fa-solid fa-power-off"></i> Tắt chế độ shipper để xem đơn đặt
                        </a>
                    </div>
                </div>
            </c:when>
            <c:when test="${empty orders or orders.size() eq 0}">
                <!-- Empty State -->
                <div class="empty-orders-card">
                    <div class="empty-icon-wrap">
                        <i class="fa-solid fa-bowl-food"></i>
                    </div>
                    <h3 class="empty-title">Bạn chưa có đơn hàng nào</h3>
                    <p class="empty-desc">Hãy khám phá ngay thực đơn phong phú với hàng trăm món ngon nóng hổi từ các quán ăn uy tín trên Utee Express!</p>
                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-order-now">
                        <i class="fa-solid fa-magnifying-glass"></i> Khám phá món ngon ngay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Orders List -->
                <div class="orders-list">
                    <c:forEach items="${orders}" var="order">
                        <div class="order-card" data-status="${order.status}">
                            <!-- Order Card Header -->
                            <div class="order-card-header">
                                <div class="order-id-group">
                                    <span class="order-code">#FZ-${order.id}</span>
                                    <span class="order-date"><i class="fa-regular fa-calendar-days"></i> ${order.createdAt}</span>
                                </div>
                                <div class="order-status-group">
                                    <c:choose>
                                        <c:when test="${order.status eq 'PENDING'}">
                                            <span class="order-status-badge status-pending">
                                                <i class="fa-solid fa-hourglass-half"></i> Chờ quán xác nhận
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'CONFIRMED'}">
                                            <span class="order-status-badge status-confirmed">
                                                <i class="fa-solid fa-circle-check"></i> Quán đã nhận đơn
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'SHIPPING'}">
                                            <span class="order-status-badge status-shipping">
                                                <i class="fa-solid fa-motorcycle fa-bounce"></i> Đang giao hàng
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'DELIVERED'}">
                                            <span class="order-status-badge status-delivered">
                                                <i class="fa-solid fa-circle-check"></i> Đã hoàn tất
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'CANCELLED'}">
                                            <span class="order-status-badge status-cancelled">
                                                <i class="fa-solid fa-circle-xmark"></i> Đã hủy đơn
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="order-status-badge">${order.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${order.status ne 'CANCELLED'}">
                                        <div style="font-size: 0.78rem; margin-top: 4px; text-align: right;">
                                            <c:choose>
                                                <c:when test="${order.customerConfirmed}">
                                                    <span class="text-success fw-bold">
                                                        <i class="fa-solid fa-circle-check"></i> Bạn đã nhận hàng thành công
                                                    </span>
                                                </c:when>
                                                <c:when test="${order.shipperDelivered}">
                                                    <span class="badge bg-danger-subtle text-danger border border-danger-subtle fw-bold" style="font-size: 0.76rem;">
                                                        <i class="fa-solid fa-bell fa-shake me-1"></i> Shipper đã đến nơi - Vui lòng xác nhận nhận món!
                                                    </span>
                                                </c:when>
                                                <c:when test="${order.status eq 'SHIPPING'}">
                                                    <span class="text-warning fw-bold">
                                                        <i class="fa-solid fa-motorcycle"></i> Shipper đang trên đường giao tới bạn
                                                    </span>
                                                </c:when>
                                                <c:when test="${order.shipperAccepted}">
                                                    <span class="text-info fw-bold">
                                                        <i class="fa-solid fa-fire-burner"></i> Shipper đã nhận đơn - Quán đang nấu
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">
                                                        <i class="fa-solid fa-clock"></i> Đang chờ quán tiếp nhận &amp; chọn shipper
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Driver Info (nếu có tài xế nhận giao) -->
                            <c:if test="${not empty order.driverName}">
                                <div class="order-driver-banner ${(order.customerConfirmed or order.status eq 'DELIVERED') ? 'banner-delivered' : ''}">
                                    <div class="driver-banner-left">
                                        <i class="fa-solid ${(order.customerConfirmed or order.status eq 'DELIVERED') ? 'fa-circle-check text-success' : 'fa-helmet-safety text-primary'}"></i>
                                        <span>Tài xế phụ trách: <strong>${order.driverName}</strong></span>
                                        <c:if test="${not empty order.driverPhone}">
                                            <a href="tel:${order.driverPhone}" class="driver-phone-link" title="Gọi cho tài xế">
                                                <i class="fa-solid fa-phone"></i> ${order.driverPhone}
                                            </a>
                                        </c:if>
                                    </div>
                                    <c:choose>
                                        <c:when test="${order.customerConfirmed or order.status eq 'DELIVERED'}">
                                            <span class="driver-banner-tag" style="color: #16a34a;">
                                                <i class="fa-solid fa-circle-check"></i> Đã giao thành công
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'CANCELLED'}">
                                            <span class="driver-banner-tag text-muted">
                                                <i class="fa-solid fa-ban"></i> Đơn đã hủy
                                            </span>
                                        </c:when>
                                        <c:when test="${order.status eq 'SHIPPING'}">
                                            <span class="driver-banner-tag" style="color: var(--primary-color);">
                                                <i class="fa-solid fa-location-dot"></i> Đang di chuyển giao hàng
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="driver-banner-tag" style="color: #0284c7;">
                                                <i class="fa-solid fa-motorcycle"></i> Đã nhận đơn
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:if>

                            <!-- Receiver & Address Summary -->
                            <div class="order-delivery-info">
                                <div class="delivery-info-item">
                                    <i class="fa-solid fa-location-dot text-danger"></i>
                                    <span><strong>Giao đến:</strong> ${order.address}</span>
                                </div>
                                <div class="delivery-info-item">
                                    <i class="fa-solid fa-user text-muted"></i>
                                    <span><strong>Người nhận:</strong> ${order.customerName} (${order.phone})</span>
                                </div>
                                <c:if test="${not empty order.note}">
                                    <div class="delivery-info-item delivery-note">
                                        <i class="fa-solid fa-comment-dots text-warning"></i>
                                        <span><strong>Ghi chú:</strong> "${order.note}"</span>
                                    </div>
                                </c:if>
                            </div>

                            <!-- Order Items List -->
                            <div class="order-items-list">
                                <c:forEach items="${order.items}" var="item">
                                    <div class="order-item-row">
                                        <img src="${item.foodImage}" alt="${item.foodName}" class="order-item-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&auto=format&fit=crop&q=60'">
                                        <div class="order-item-details">
                                            <h4 class="order-item-title">${item.foodName}</h4>
                                            <div class="order-item-pricing">
                                                <span class="order-item-qty">x${item.quantity} phần</span>
                                                <span class="order-item-unit">${String.format("%,.0f", item.unitPrice)} đ</span>
                                            </div>
                                        </div>
                                        <div class="order-item-subtotal">
                                            ${String.format("%,.0f", item.subtotal)} đ
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- Order Card Footer -->
                            <div class="order-card-footer">
                                <div class="order-payment-info">
                                    <span class="payment-badge">
                                        <c:choose>
                                            <c:when test="${order.paymentMethod eq 'COD'}">
                                                <i class="fa-solid fa-money-bill-wave text-success"></i> Tiền mặt khi nhận (COD)
                                            </c:when>
                                            <c:when test="${order.paymentMethod eq 'QR'}">
                                                <i class="fa-solid fa-qrcode text-primary"></i> Quét mã QR MoMo/Ngân hàng
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-credit-card text-info"></i> ${order.paymentMethod}
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="order-total-action-group">
                                    <div class="order-total-block">
                                        <span class="total-label">Tổng thanh toán:</span>
                                        <span class="total-amount">${String.format("%,.0f", order.totalAmount)} đ</span>
                                    </div>

                                    <div class="order-actions">
                                        <c:if test="${not order.customerConfirmed and order.status ne 'CANCELLED' and (order.status eq 'DELIVERED' or order.status eq 'SHIPPING' or order.shipperDelivered or (order.status eq 'CONFIRMED' and not empty order.driverName) or order.merchantConfirmed)}">
                                            <form action="${pageContext.request.contextPath}/profile" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="confirm_received">
                                                <input type="hidden" name="orderId" value="${order.id}">
                                                <button type="submit" class="btn btn-success btn-sm ${order.shipperDelivered ? 'shadow-sm' : ''}" style="border-radius: 50px; font-weight: 700; padding: 6px 16px; ${order.shipperDelivered ? 'background: #10ac84; border-color: #10ac84;' : ''}" title="Xác nhận bạn đã nhận được món ăn từ shipper">
                                                    <i class="fa-solid fa-circle-check me-1"></i> ${order.shipperDelivered ? 'Xác Nhận Đã Nhận Món' : 'Đã nhận được hàng'}
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${order.status eq 'PENDING'}">
                                            <form action="${pageContext.request.contextPath}/profile" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng #FZ-${order.id} không?');" style="display:inline;">
                                                <input type="hidden" name="action" value="cancel_order">
                                                <input type="hidden" name="orderId" value="${order.id}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm">
                                                    <i class="fa-solid fa-ban"></i> Hủy đơn
                                                </button>
                                            </form>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-sm">
                                            <i class="fa-solid fa-cart-plus"></i> Đặt lại món
                                        </a>
                                    </div>
                                </div>

                                <!-- Dual Rating Section (Món ăn & Shipper) -->
                                <c:if test="${order.status eq 'DELIVERED' or order.customerConfirmed}">
                                    <div style="margin-top: 16px; border-top: 1px dashed #e2e8f0; padding-top: 14px;">
                                        <c:choose>
                                            <c:when test="${not empty order.review}">
                                                <!-- Đã đánh giá -->
                                                <div style="background: #fffdf5; border: 1px solid #fde68a; border-radius: 12px; padding: 14px 18px;">
                                                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
                                                        <span style="font-weight: 700; color: #b45309; font-size: 0.92rem;">
                                                            <i class="fa-solid fa-star text-warning me-1"></i> Đánh giá của bạn cho đơn hàng này:
                                                        </span>
                                                        <c:if test="${not empty order.review.createdAt}">
                                                            <span style="font-size: 0.78rem; color: #94a3b8;">
                                                                <fmt:formatDate value="${order.review.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                    <div class="row g-2" style="font-size: 0.88rem;">
                                                        <div class="col-md-6">
                                                            <div style="background: #fff; padding: 10px 14px; border-radius: 8px; border: 1px solid #fef3c7;">
                                                                <div style="font-weight: 700; color: #d97706; margin-bottom: 2px;">
                                                                    <i class="fa-solid fa-utensils me-1"></i> Món ăn &amp; Quán: ⭐ ${order.review.foodRating}/5 sao
                                                                </div>
                                                                <div style="color: #475569; font-style: italic;">"${order.review.foodComment}"</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div style="background: #fff; padding: 10px 14px; border-radius: 8px; border: 1px solid #fef3c7;">
                                                                <div style="font-weight: 700; color: #d97706; margin-bottom: 2px;">
                                                                    <i class="fa-solid fa-motorcycle me-1"></i> Tài xế Shipper: ⭐ ${order.review.driverRating}/5 sao
                                                                </div>
                                                                <div style="color: #475569; font-style: italic;">"${order.review.driverComment}"</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:when>

                                            <c:otherwise>
                                                <!-- Chưa đánh giá -> Hiển thị form đánh giá kép -->
                                                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px;">
                                                    <div style="display: flex; justify-content: space-between; align-items: center; cursor: pointer;" onclick="document.getElementById('reviewForm-${order.id}').style.display = (document.getElementById('reviewForm-${order.id}').style.display === 'none' ? 'block' : 'none');">
                                                        <span style="font-weight: 700; color: #1e293b; font-size: 0.95rem;">
                                                            <i class="fa-solid fa-star text-warning me-1"></i> Đánh giá trải nghiệm Món ăn &amp; Tài xế
                                                        </span>
                                                        <button type="button" class="btn btn-warning btn-sm" style="border-radius: 50px; font-weight: 700;">
                                                            <i class="fa-solid fa-pen-to-square me-1"></i> Viết đánh giá
                                                        </button>
                                                    </div>

                                                    <form id="reviewForm-${order.id}" action="${pageContext.request.contextPath}/profile" method="POST" style="display: none; margin-top: 16px; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                                                        <input type="hidden" name="action" value="rate" />
                                                        <input type="hidden" name="orderId" value="${order.id}" />
                                                        <input type="hidden" name="driverId" value="${order.driverId != null ? order.driverId : 0}" />

                                                        <div class="row g-3">
                                                            <!-- Section 1: Đánh giá món ăn -->
                                                            <div class="col-md-6">
                                                                <div style="background: #fff; padding: 14px; border-radius: 10px; border: 1px solid #cbd5e1;">
                                                                    <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.9rem;">
                                                                        <i class="fa-solid fa-utensils text-danger me-1"></i> 1. Đánh giá Món ăn &amp; Quán:
                                                                    </label>
                                                                    <div class="d-flex align-items-center gap-2 mb-2">
                                                                        <select name="foodRating" class="form-select form-select-sm" style="width: 150px; font-weight: 700; color: #b45309;" required>
                                                                            <option value="5" selected>⭐⭐⭐⭐⭐ (5 sao)</option>
                                                                            <option value="4">⭐⭐⭐⭐ (4 sao)</option>
                                                                            <option value="3">⭐⭐⭐ (3 sao)</option>
                                                                            <option value="2">⭐⭐ (2 sao)</option>
                                                                            <option value="1">⭐ (1 sao)</option>
                                                                        </select>
                                                                    </div>
                                                                    <textarea name="foodComment" class="form-control form-control-sm" rows="2" placeholder="Cảm nhận về chất lượng món ăn, hương vị, đóng gói..." required></textarea>
                                                                </div>
                                                            </div>

                                                            <!-- Section 2: Đánh giá tài xế -->
                                                            <div class="col-md-6">
                                                                <div style="background: #fff; padding: 14px; border-radius: 10px; border: 1px solid #cbd5e1;">
                                                                    <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.9rem;">
                                                                        <i class="fa-solid fa-motorcycle text-primary me-1"></i> 2. Thái độ &amp; Tốc độ Tài xế:
                                                                    </label>
                                                                    <div class="d-flex align-items-center gap-2 mb-2">
                                                                        <select name="driverRating" class="form-select form-select-sm" style="width: 150px; font-weight: 700; color: #b45309;" required>
                                                                            <option value="5" selected>⭐⭐⭐⭐⭐ (5 sao)</option>
                                                                            <option value="4">⭐⭐⭐⭐ (4 sao)</option>
                                                                            <option value="3">⭐⭐⭐ (3 sao)</option>
                                                                            <option value="2">⭐⭐ (2 sao)</option>
                                                                            <option value="1">⭐ (1 sao)</option>
                                                                        </select>
                                                                    </div>
                                                                    <textarea name="driverComment" class="form-control form-control-sm" rows="2" placeholder="Tốc độ giao hàng, sự thân thiện của tài xế..." required></textarea>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="text-end mt-3">
                                                            <button type="submit" class="btn btn-warning px-4" style="border-radius: 50px; font-weight: 800;">
                                                                <i class="fa-solid fa-paper-plane me-1"></i> Gửi Đánh Giá Ngay
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
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

    <!-- Tab 3: Đổi mật khẩu & Bảo mật -->
    <div id="tab-security" class="profile-tab-pane ${activeTab eq 'security' ? 'active' : ''}">
        <div class="profile-grid">
            <div class="profile-sidebar-card">
                <div class="profile-card-header">
                    <h3 class="profile-card-title"><i class="fa-solid fa-shield-halved text-primary"></i> Mẹo bảo mật</h3>
                </div>
                <div class="security-tips-list">
                    <div class="security-tip-item">
                        <i class="fa-solid fa-check text-success"></i>
                        <span>Sử dụng mật khẩu có ít nhất 6 ký tự.</span>
                    </div>
                    <div class="security-tip-item">
                        <i class="fa-solid fa-check text-success"></i>
                        <span>Nên kết hợp chữ cái, số và ký tự đặc biệt (!@#$).</span>
                    </div>
                    <div class="security-tip-item">
                        <i class="fa-solid fa-check text-success"></i>
                        <span>Không chia sẻ mật khẩu đăng nhập với người khác.</span>
                    </div>
                    <div class="security-tip-item">
                        <i class="fa-solid fa-check text-success"></i>
                        <span>Đăng xuất khỏi thiết bị công cộng sau khi sử dụng.</span>
                    </div>
                </div>
            </div>

            <div class="profile-main-card">
                <div class="profile-card-header">
                    <h3 class="profile-card-title"><i class="fa-solid fa-key text-primary"></i> Đổi mật khẩu đăng nhập</h3>
                    <p class="profile-card-subtitle">Để bảo vệ tài khoản, vui lòng không chia sẻ mật khẩu cho bất kỳ ai</p>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="POST" class="profile-form" id="changePasswordForm">
                    <input type="hidden" name="action" value="change_password">

                    <div class="form-group">
                        <label class="form-label" for="currentPassword">Mật khẩu hiện tại <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="fa-solid fa-lock input-icon"></i>
                            <input type="password" id="currentPassword" name="currentPassword" class="form-control" required placeholder="Nhập mật khẩu hiện tại">
                            <button type="button" class="btn-toggle-pwd" onclick="togglePasswordVisibility('currentPassword', this)">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label" for="newPassword">Mật khẩu mới <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-key input-icon"></i>
                                <input type="password" id="newPassword" name="newPassword" class="form-control" required minlength="6" placeholder="Tối thiểu 6 ký tự">
                                <button type="button" class="btn-toggle-pwd" onclick="togglePasswordVisibility('newPassword', this)">
                                    <i class="fa-regular fa-eye"></i>
                                </button>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="confirmPassword">Xác nhận mật khẩu mới <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-check-double input-icon"></i>
                                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                                <button type="button" class="btn-toggle-pwd" onclick="togglePasswordVisibility('confirmPassword', this)">
                                    <i class="fa-regular fa-eye"></i>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="profile-form-actions">
                        <button type="submit" class="btn btn-primary btn-save-pwd">
                            <i class="fa-solid fa-shield-check"></i> Cập nhật mật khẩu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Tab 4: Giao diện & Chủ đề cá nhân hóa (Appearance) -->
    <div id="tab-appearance" class="profile-tab-pane ${activeTab eq 'appearance' or param.tab eq 'appearance' ? 'active' : ''}">
        <div class="appearance-layout-grid">
            <!-- Cột Cấu Hình (Settings) -->
            <div class="appearance-settings-col">
                <!-- Card 1: Chế độ hiển thị -->
                <div class="appearance-card">
                    <div class="appearance-card-header">
                        <div class="app-card-title-group">
                            <div class="app-card-icon"><i class="fa-solid fa-circle-half-stroke"></i></div>
                            <div>
                                <h3 class="appearance-card-title">Chế độ hiển thị (Display Mode)</h3>
                                <p class="appearance-card-desc">Tùy biến chế độ sáng/tối để phù hợp với môi trường làm việc ngày và đêm.</p>
                            </div>
                        </div>
                    </div>
                    <div class="appearance-mode-options">
                        <label class="app-mode-card" data-mode="light">
                            <input type="radio" name="profileThemeMode" value="light">
                            <div class="app-mode-preview light-preview">
                                <div class="preview-header"></div>
                                <div class="preview-content">
                                    <div class="preview-line-1"></div>
                                    <div class="preview-line-2"></div>
                                </div>
                            </div>
                            <div class="app-mode-info">
                                <div class="app-mode-name"><i class="fa-solid fa-sun text-warning"></i> Sáng (Light)</div>
                                <div class="app-mode-sub">Rõ ràng, tràn đầy năng lượng</div>
                            </div>
                        </label>

                        <label class="app-mode-card" data-mode="dark">
                            <input type="radio" name="profileThemeMode" value="dark">
                            <div class="app-mode-preview dark-preview">
                                <div class="preview-header"></div>
                                <div class="preview-content">
                                    <div class="preview-line-1"></div>
                                    <div class="preview-line-2"></div>
                                </div>
                            </div>
                            <div class="app-mode-info">
                                <div class="app-mode-name"><i class="fa-solid fa-moon text-info"></i> Tối (Dark)</div>
                                <div class="app-mode-sub">Dịu mắt khi đặt món đêm</div>
                            </div>
                        </label>

                        <label class="app-mode-card" data-mode="system">
                            <input type="radio" name="profileThemeMode" value="system">
                            <div class="app-mode-preview system-preview">
                                <div class="preview-split-left"></div>
                                <div class="preview-split-right"></div>
                            </div>
                            <div class="app-mode-info">
                                <div class="app-mode-name"><i class="fa-solid fa-laptop text-primary"></i> Tự động (Auto)</div>
                                <div class="app-mode-sub">Đồng bộ theo thiết bị</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Card 2: Bảng màu ẩm thực tuyển chọn -->
                <div class="appearance-card">
                    <div class="appearance-card-header">
                        <div class="app-card-title-group">
                            <div class="app-card-icon"><i class="fa-solid fa-palette"></i></div>
                            <div>
                                <h3 class="appearance-card-title">Tông màu ẩm thực (Food Palettes)</h3>
                                <p class="appearance-card-desc">Chọn phong cách màu sắc kích thích thị giác món ăn theo sở thích của bạn.</p>
                            </div>
                        </div>
                    </div>
                    <div class="appearance-color-list">
                        <button type="button" class="app-color-item" data-color="coral">
                            <span class="app-color-circle" style="background: linear-gradient(135deg, #f05454 0%, #ff7676 100%);"></span>
                            <div class="app-color-details">
                                <div class="app-color-name">Đỏ San Hô Utee (Mặc định)</div>
                                <div class="app-color-tagline">Rực rỡ, ấm cúng và tôn vinh mọi món ngon chuẩn vị</div>
                            </div>
                            <i class="fa-solid fa-circle-check app-color-check-icon"></i>
                        </button>

                        <button type="button" class="app-color-item" data-color="orange">
                            <span class="app-color-circle" style="background: linear-gradient(135deg, #ff7a00 0%, #ff9f43 100%);"></span>
                            <div class="app-color-details">
                                <div class="app-color-name">Cam Năng Động (Fastfood &amp; Snack)</div>
                                <div class="app-color-tagline">Tràn trề năng lượng, kích thích sự thèm ăn tuyệt đối</div>
                            </div>
                            <i class="fa-solid fa-circle-check app-color-check-icon"></i>
                        </button>

                        <button type="button" class="app-color-item" data-color="emerald">
                            <span class="app-color-circle" style="background: linear-gradient(135deg, #10b981 0%, #34d399 100%);"></span>
                            <div class="app-color-details">
                                <div class="app-color-name">Xanh Healthy (Món Chay &amp; Eat Clean)</div>
                                <div class="app-color-tagline">Tươi mát, thanh lọc tự nhiên và bảo vệ sức khỏe</div>
                            </div>
                            <i class="fa-solid fa-circle-check app-color-check-icon"></i>
                        </button>

                        <button type="button" class="app-color-item" data-color="royal">
                            <span class="app-color-circle" style="background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);"></span>
                            <div class="app-color-details">
                                <div class="app-color-name">Tím Trà Sữa (Bánh Ngọt &amp; Trendy)</div>
                                <div class="app-color-tagline">Ngọt ngào, trẻ trung và chuẩn phong cách Gen Z</div>
                            </div>
                            <i class="fa-solid fa-circle-check app-color-check-icon"></i>
                        </button>

                        <button type="button" class="app-color-item" data-color="ocean">
                            <span class="app-color-circle" style="background: linear-gradient(135deg, #0284c7 0%, #38bdf8 100%);"></span>
                            <div class="app-color-details">
                                <div class="app-color-name">Xanh Biển Tươi (Hải Sản &amp; Nước Ép)</div>
                                <div class="app-color-tagline">Sảng khoái, phóng khoáng và ngập tràn hương vị biển cả</div>
                            </div>
                            <i class="fa-solid fa-circle-check app-color-check-icon"></i>
                        </button>
                    </div>
                </div>

                <!-- Reset Button -->
                <div class="appearance-footer-actions">
                    <button type="button" class="btn btn-outline" id="btnResetThemeProfile">
                        <i class="fa-solid fa-rotate-left"></i> Khôi phục giao diện mặc định
                    </button>
                </div>
            </div>

            <!-- Cột Xem Trước Thời Gian Thực (Live Preview) -->
            <div class="appearance-preview-col">
                <div class="appearance-preview-sticky">
                    <div class="app-preview-card">
                        <div class="app-preview-header">
                            <div class="app-preview-dots">
                                <span class="dot dot-red"></span>
                                <span class="dot dot-yellow"></span>
                                <span class="dot dot-green"></span>
                            </div>
                            <div class="app-preview-badge"><i class="fa-solid fa-wand-magic-sparkles text-primary"></i> Xem trước thời gian thực</div>
                        </div>
                        <div class="app-preview-body">
                            <!-- Mock Top Navigation -->
                            <div class="mock-nav-bar">
                                <div class="mock-nav-brand"><i class="fa-solid fa-utensils"></i> Utee Express</div>
                                <div class="mock-nav-right">
                                    <span class="mock-nav-pill"><i class="fa-solid fa-bolt"></i> 30p</span>
                                    <span class="mock-nav-cart"><i class="fa-solid fa-bag-shopping"></i> 1</span>
                                </div>
                            </div>

                            <!-- Mock Food Card -->
                            <div class="mock-food-item">
                                <div class="mock-food-banner">
                                    <span class="mock-food-badge"><i class="fa-solid fa-fire"></i> Best Seller</span>
                                </div>
                                <div class="mock-food-content">
                                    <h4 class="mock-food-title">Cơm Gà Xối Mỡ Sốt Mắm Tỏi Giòn Rụm</h4>
                                    <p class="mock-food-snippet">Đùi gà vàng ươm thơm lừng kèm cơm chiên hoàng kim và canh súp nóng hổi.</p>
                                    <div class="mock-food-row">
                                        <div class="mock-food-price">48.000 đ</div>
                                        <button type="button" class="mock-order-btn">
                                            <i class="fa-solid fa-plus"></i> Đặt món
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Mock Toast Message -->
                            <div class="mock-toast-box">
                                <i class="fa-solid fa-circle-check text-success"></i>
                                <span>Giao diện đang áp dụng theo lựa chọn của bạn!</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function switchTab(tabId) {
    // Ẩn tất cả panes
    document.querySelectorAll('.profile-tab-pane').forEach(el => el.classList.remove('active'));
    // Bỏ active buttons
    document.querySelectorAll('.profile-tab-btn').forEach(el => el.classList.remove('active'));

    // Bật pane tương ứng
    const targetPane = document.getElementById('tab-' + tabId);
    if (targetPane) {
        targetPane.classList.add('active');
    }

    // Bật button tương ứng
    const btn = Array.from(document.querySelectorAll('.profile-tab-btn')).find(b => b.getAttribute('onclick') && b.getAttribute('onclick').includes(tabId));
    if (btn) {
        btn.classList.add('active');
    }

    // Cập nhật URL mà không reload trang
    const newUrl = new URL(window.location);
    newUrl.searchParams.set('tab', tabId);
    window.history.replaceState({}, '', newUrl);
}

function filterOrders(status, btn) {
    document.querySelectorAll('.filter-pill').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    const cards = document.querySelectorAll('.order-card');
    cards.forEach(card => {
        if (status === 'ALL') {
            card.style.display = 'block';
        } else {
            const cardStatus = card.getAttribute('data-status');
            if (cardStatus === status) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        }
    });
}

function togglePasswordVisibility(fieldId, btn) {
    const input = document.getElementById(fieldId);
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}

// Theo dõi thay đổi thông tin khách hàng: chỉ kích hoạt nút "Lưu thay đổi" khi có sửa đổi
document.addEventListener('DOMContentLoaded', function() {
    const profileForm = document.getElementById('updateProfileForm');
    const saveBtn = document.getElementById('btnSaveProfile');
    if (!profileForm || !saveBtn) return;

    const fields = ['fullName', 'phone', 'email', 'address'];
    const initialValues = {};

    fields.forEach(function(id) {
        const el = document.getElementById(id);
        if (el) {
            initialValues[id] = el.value.trim();
        }
    });

    function checkProfileChanges() {
        let hasChanged = false;
        for (let i = 0; i < fields.length; i++) {
            const el = document.getElementById(fields[i]);
            if (el) {
                if (el.value.trim() !== initialValues[fields[i]]) {
                    hasChanged = true;
                    break;
                }
            }
        }
        saveBtn.disabled = !hasChanged;
        if (hasChanged) {
            saveBtn.removeAttribute('title');
        } else {
            saveBtn.setAttribute('title', 'Chưa có thay đổi nào để lưu');
        }
    }

    fields.forEach(function(id) {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('input', checkProfileChanges);
            el.addEventListener('change', checkProfileChanges);
        }
    });

    checkProfileChanges();

    // Khởi tạo tab từ URL parameter hoặc hash
    const urlParams = new URLSearchParams(window.location.search);
    const initialTab = urlParams.get('tab') || window.location.hash.replace('#', '');
    if (initialTab && document.getElementById('tab-' + initialTab)) {
        switchTab(initialTab);
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
