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
        <h1 class="page-title">Tài Khoản & Hồ Sơ Khách Hàng</h1>
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
            </div>

            <!-- Right Form Column -->
            <div class="profile-main-card">
                <div class="profile-card-header">
                    <h3 class="profile-card-title"><i class="fa-solid fa-pen-to-square text-primary"></i> Cập nhật thông tin nhận hàng</h3>
                    <p class="profile-card-subtitle">Thông tin sẽ được tự động điền khi bạn đặt đồ ăn tại VinDelivery</p>
                </div>

                <form action="${pageContext.request.contextPath}/profile" method="POST" class="profile-form">
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
                            <label class="form-label" for="phone">Số điện thoại nhận hàng <span class="required-star">*</span></label>
                            <div class="input-icon-wrap">
                                <i class="fa-solid fa-phone input-icon"></i>
                                <input type="tel" id="phone" name="phone" class="form-control" value="${not empty stickyPhone ? stickyPhone : user.phone}" required pattern="^0[0-9]{9,10}$" placeholder="Ví dụ: 0987654321">
                            </div>
                            <span class="form-help-text">Tài xế sẽ gọi vào số này khi giao món</span>
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
                        <label class="form-label" for="address">Địa chỉ giao hàng mặc định <span class="required-star">*</span></label>
                        <div class="input-icon-wrap">
                            <i class="fa-solid fa-location-dot input-icon input-icon-textarea"></i>
                            <textarea id="address" name="address" class="form-control textarea-address" rows="3" required placeholder="Nhập số nhà, tên đường, phường/xã, quận/huyện...">${not empty stickyAddress ? stickyAddress : user.address}</textarea>
                        </div>
                        <span class="form-help-text">Địa chỉ giao hàng chính xác giúp tài xế tìm đường nhanh hơn</span>
                    </div>

                    <div class="profile-form-actions">
                        <button type="submit" class="btn btn-primary btn-save-profile">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        </button>
                        <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline">
                            <i class="fa-solid fa-rotate-left"></i> Khôi phục ban đầu
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Tab 2: Lịch sử đơn hàng -->
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
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

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
                                <i class="fa-solid fa-shield-keyhole input-icon"></i>
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
    const btn = Array.from(document.querySelectorAll('.profile-tab-btn')).find(b => b.getAttribute('onclick').includes(tabId));
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
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
