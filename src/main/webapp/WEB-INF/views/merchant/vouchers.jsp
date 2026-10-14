<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Khuyến Mãi & Voucher - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp">
        <jsp:param name="activeTab" value="vouchers" />
    </jsp:include>

    <div class="container pb-5">
        <!-- KPI Cards Summary -->
        <div class="row g-3 mb-4">
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="merchant-kpi-card" style="background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%); border: 1px solid #bfdbfe; border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 12px rgba(37,99,235,0.06);">
                    <div style="width: 52px; height: 52px; border-radius: 14px; background: #2563eb; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; flex-shrink: 0;">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div>
                        <span style="font-size: 0.85rem; color: #1e40af; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Tổng Số Voucher</span>
                        <div style="font-size: 1.75rem; font-weight: 800; color: #1e3a8a; line-height: 1.2;">${totalVouchers} <span style="font-size: 0.95rem; font-weight: 600; color: #3b82f6;">chương trình</span></div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-4">
                <div class="merchant-kpi-card" style="background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%); border: 1px solid #a7f3d0; border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 12px rgba(16,185,129,0.06);">
                    <div style="width: 52px; height: 52px; border-radius: 14px; background: #10b981; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; flex-shrink: 0;">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div>
                        <span style="font-size: 0.85rem; color: #065f46; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Đang Hoạt Động</span>
                        <div style="font-size: 1.75rem; font-weight: 800; color: #064e3b; line-height: 1.2;">${activeVouchers} <span style="font-size: 0.95rem; font-weight: 600; color: #10b981;">mã sẵn sàng</span></div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-4">
                <div class="merchant-kpi-card" style="background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%); border: 1px solid #fed7aa; border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 16px; box-shadow: 0 4px 12px rgba(249,115,22,0.06);">
                    <div style="width: 52px; height: 52px; border-radius: 14px; background: #f97316; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; flex-shrink: 0;">
                        <i class="fa-solid fa-fire"></i>
                    </div>
                    <div>
                        <span style="font-size: 0.85rem; color: #9a3412; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Lượt Khách Đã Dùng</span>
                        <div style="font-size: 1.75rem; font-weight: 800; color: #7c2d12; line-height: 1.2;">${totalUsedCount} <span style="font-size: 0.95rem; font-weight: 600; color: #ea580c;">lượt đặt</span></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Toolbar & Filter -->
        <div class="merchant-food-toolbar mb-4">
            <form action="${pageContext.request.contextPath}/merchant/vouchers" method="GET" class="merchant-food-search-form">
                <div class="merchant-search-input-wrap">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo mã voucher hoặc tiêu đề..." />
                </div>
                <div class="merchant-category-select-wrap">
                    <select name="status" onchange="this.form.submit()">
                        <option value="ALL">-- Tất cả trạng thái --</option>
                        <option value="ACTIVE" ${selectedStatus eq 'ACTIVE' ? 'selected' : ''}>🟢 Đang hoạt động</option>
                        <option value="INACTIVE" ${selectedStatus eq 'INACTIVE' ? 'selected' : ''}>⏸️ Tạm ngưng</option>
                        <option value="EXPIRED" ${selectedStatus eq 'EXPIRED' ? 'selected' : ''}>⌛ Hết hạn</option>
                    </select>
                </div>
                <button type="submit" class="merchant-filter-submit-btn">
                    <i class="fa-solid fa-filter"></i> <span>Lọc Voucher</span>
                </button>
                <c:if test="${not empty keyword || not empty selectedStatus}">
                    <a href="${pageContext.request.contextPath}/merchant/vouchers" class="merchant-filter-clear-btn" title="Xóa bộ lọc tìm kiếm">
                        <i class="fa-solid fa-xmark"></i> <span>Xóa lọc</span>
                    </a>
                </c:if>
            </form>

            <div style="display: flex; gap: 10px; align-items: center;">
                <a href="${pageContext.request.contextPath}/restaurant-detail?id=${currentRestaurant.id}" target="_blank" class="btn btn-outline" style="border-radius: 10px; font-weight: 700; font-size: 0.88rem; padding: 8px 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 7px;" title="Xem hiển thị voucher trên trang quán ăn thực tế">
                    <i class="fa-solid fa-eye text-primary"></i> <span>Xem Trang Quán</span>
                </a>
                <button type="button" class="merchant-add-food-btn" onclick="openAddVoucherModal()" style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);">
                    <i class="fa-solid fa-plus"></i> <span>Tạo Voucher Mới</span>
                </button>
            </div>
        </div>

        <!-- Voucher Table Card -->
        <div class="admin-table-card">
            <div class="admin-table-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-tags text-primary"></i> Danh Sách Voucher Khuyến Mãi Của Quán</h3>
                    <span class="table-card-sub">Voucher sẽ tự động xuất hiện nổi bật ở <strong>đầu trang quán ăn</strong> khi khách hàng vào xem</span>
                </div>
                <span class="badge" style="background: #f8fafc; color: #475569; border: 1px solid #e2e8f0; font-weight: 700; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem;">
                    ${empty vouchers ? 0 : vouchers.size()} voucher
                </span>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th style="width: 140px;">Mã Voucher</th>
                            <th>Tiêu Đề &amp; Mức Giảm</th>
                            <th style="width: 150px;">Đơn Tối Thiểu</th>
                            <th style="width: 180px;">Giới Hạn Lượt Dùng</th>
                            <th style="width: 150px;">Thời Gian Áp Dụng</th>
                            <th style="width: 130px;">Trạng Thái</th>
                            <th class="text-end" style="width: 130px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty vouchers}">
                                <c:forEach var="v" items="${vouchers}">
                                    <tr>
                                        <!-- Mã Voucher & Badge -->
                                        <td>
                                            <div style="display: flex; flex-direction: column; gap: 4px; align-items: flex-start;">
                                                <span class="badge" style="background: #fff7ed; color: #ea580c; border: 1px solid #fed7aa; font-weight: 800; font-size: 0.72rem; padding: 2px 7px;">
                                                    ${v.badge}
                                                </span>
                                                <div style="display: flex; align-items: center; gap: 6px;">
                                                    <strong class="text-primary font-monospace" style="font-size: 1.05rem; letter-spacing: 0.5px;">${v.code}</strong>
                                                    <button type="button" class="btn btn-sm btn-light p-1 border-0" onclick="copyVoucherCode('${v.code}')" title="Sao chép mã" style="font-size: 0.75rem; color: #64748b;">
                                                        <i class="fa-regular fa-copy"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </td>

                                        <!-- Tiêu Đề & Mức Giảm -->
                                        <td>
                                            <div class="fw-bold text-dark" style="font-size: 0.98rem; margin-bottom: 2px;">
                                                ${v.title}
                                            </div>
                                            <div style="font-size: 0.85rem; font-weight: 700; color: #dc2626;">
                                                <c:choose>
                                                    <c:when test="${v.discountType eq 'PERCENT'}">
                                                        <i class="fa-solid fa-percent me-1"></i> Giảm ${v.discountValue}%
                                                        <c:if test="${v.maxDiscount > 0}">
                                                            <span class="text-muted fw-normal" style="font-size: 0.8rem;">(Tối đa <fmt:formatNumber value="${v.maxDiscount}" type="number" /> đ)</span>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fa-solid fa-coins me-1"></i> Giảm <fmt:formatNumber value="${v.discountValue}" type="number" /> đ
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <c:if test="${not empty v.description}">
                                                <small class="text-muted" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; max-width: 320px; line-height: 1.35; margin-top: 2px;">
                                                    ${v.description}
                                                </small>
                                            </c:if>
                                        </td>

                                        <!-- Đơn Tối Thiểu -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.minOrderAmount > 0}">
                                                    <span class="fw-bold text-dark" style="font-size: 0.92rem;">
                                                        <fmt:formatNumber value="${v.minOrderAmount}" type="number" /> đ
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-secondary border" style="font-size: 0.78rem;">Đơn bất kỳ</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Giới Hạn & Tiến Độ Sử Dụng -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.usageLimit > 0}">
                                                    <div style="font-size: 0.82rem; margin-bottom: 4px; display: flex; justify-content: space-between;">
                                                        <span>Đã dùng: <strong>${v.usedCount}</strong>/${v.usageLimit}</span>
                                                        <span class="text-muted">${v.usagePercentage}%</span>
                                                    </div>
                                                    <div class="progress" style="height: 6px; border-radius: 4px; background: #e2e8f0; margin-bottom: 4px;">
                                                        <div class="progress-bar ${v.usagePercentage >= 90 ? 'bg-danger' : (v.usagePercentage >= 60 ? 'bg-warning' : 'bg-success')}" 
                                                             role="progressbar" style="width: ${v.usagePercentage}%;"></div>
                                                    </div>
                                                    <small class="text-muted" style="font-size: 0.76rem;">
                                                        <i class="fa-solid fa-user-check me-1"></i> Tối đa ${v.perUserLimit} lần/khách
                                                    </small>
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="font-size: 0.84rem; font-weight: 600; color: #059669;">
                                                        <i class="fa-solid fa-infinity me-1"></i> Không giới hạn lượt
                                                    </div>
                                                    <small class="text-muted" style="font-size: 0.76rem;">
                                                        Đã dùng: <strong>${v.usedCount}</strong> lượt
                                                    </small>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Thời Gian Hiệu Lực -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty v.endDate}">
                                                    <div style="font-size: 0.84rem; font-weight: 600; color: ${v.expired ? '#dc2626' : '#334155'};">
                                                        <i class="fa-regular fa-calendar me-1"></i> ${v.formattedExpiry}
                                                    </div>
                                                    <c:if test="${not empty v.startDate}">
                                                        <small class="text-muted" style="font-size: 0.76rem;">Bắt đầu: ${v.startDate}</small>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-muted border" style="font-size: 0.78rem;">Vô thời hạn</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Trạng Thái -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.expired}">
                                                    <span class="badge bg-danger" style="font-size: 0.78rem; padding: 4px 8px; border-radius: 6px;">
                                                        <i class="fa-solid fa-hourglass-end me-1"></i> Hết hạn
                                                    </span>
                                                </c:when>
                                                <c:when test="${v.fullyUsed}">
                                                    <span class="badge bg-secondary" style="font-size: 0.78rem; padding: 4px 8px; border-radius: 6px;">
                                                        <i class="fa-solid fa-ban me-1"></i> Hết lượt
                                                    </span>
                                                </c:when>
                                                <c:when test="${v.active}">
                                                    <form action="${pageContext.request.contextPath}/merchant/vouchers" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggle" />
                                                        <input type="hidden" name="id" value="${v.id}" />
                                                        <button type="submit" class="btn btn-sm btn-outline border-success text-success" style="border-radius: 20px; font-weight: 600; padding: 3px 10px; font-size: 0.78rem;" title="Bấm để tạm dừng voucher">
                                                            <i class="fa-solid fa-circle-check text-success me-1"></i> Đang Bật
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/merchant/vouchers" method="POST" style="display:inline;">
                                                        <input type="hidden" name="action" value="toggle" />
                                                        <input type="hidden" name="id" value="${v.id}" />
                                                        <button type="submit" class="btn btn-sm btn-outline border-secondary text-muted" style="border-radius: 20px; font-weight: 600; padding: 3px 10px; font-size: 0.78rem;" title="Bấm để kích hoạt lại voucher">
                                                            <i class="fa-solid fa-pause text-secondary me-1"></i> Tạm Dừng
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Thao Tác -->
                                        <td class="text-end">
                                            <div style="display: inline-flex; gap: 6px;">
                                                <button type="button" class="btn btn-sm btn-outline-primary" style="border-radius: 8px; padding: 5px 9px;" 
                                                        onclick="openEditVoucherModal(${v.id}, '${v.code}', '<c:out value="${v.title}" escapeXml="true"/>', '<c:out value="${v.description}" escapeXml="true"/>', '${v.discountType}', ${v.discountValue}, ${v.minOrderAmount}, ${v.maxDiscount}, ${v.usageLimit}, ${v.perUserLimit}, '${v.startDate}', '${v.endDate}', '${v.badge}', ${v.active})"
                                                        title="Chỉnh sửa voucher">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </button>
                                                <button type="button" class="btn btn-sm btn-outline-danger" style="border-radius: 8px; padding: 5px 9px;" 
                                                        onclick="confirmDeleteVoucher(${v.id}, '${v.code}')"
                                                        title="Xóa voucher">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5">
                                        <div style="max-width: 420px; margin: 0 auto; color: #64748b;">
                                            <i class="fa-solid fa-ticket" style="font-size: 3.5rem; color: #cbd5e1; margin-bottom: 16px;"></i>
                                            <h4 style="font-weight: 700; color: #334155;">Chưa Có Voucher Khuyến Mãi Nào</h4>
                                            <p style="font-size: 0.9rem; color: #64748b; margin-bottom: 20px;">
                                                Tạo voucher giảm giá để kích cầu, thu hút khách hàng mới và tăng doanh số đơn hàng cho quán ăn của bạn!
                                            </p>
                                            <button type="button" class="btn btn-primary rounded-pill px-4 py-2 font-weight-bold" onclick="openAddVoucherModal()">
                                                <i class="fa-solid fa-plus me-1"></i> Tạo Voucher Đầu Tiên
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- ====================================================================
     MODAL POPUP: TẠO VOUCHER MỚI / CHỈNH SỬA VOUCHER (CĂN GIỮA MÀN HÌNH)
     ==================================================================== -->
<div id="voucherModal" class="merchant-modal-backdrop" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.72); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 999999; align-items: center; justify-content: center; padding: 20px; overflow-y: auto;" onclick="if(event.target === this) closeVoucherModal();">
    <div class="merchant-modal-container" style="background: #ffffff; width: 100%; max-width: 960px; max-height: 90vh; border-radius: 20px; box-shadow: 0 30px 60px -15px rgba(15, 23, 42, 0.4), 0 0 0 1px rgba(226, 232, 240, 0.85); overflow: hidden; display: flex; flex-direction: column; margin: auto; position: relative;" onclick="event.stopPropagation();">
        <!-- Header -->
        <div class="merchant-modal-header">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(255,255,255,0.2); display: flex; align-items: center; justify-content: center; font-size: 1.25rem;">
                    <i class="fa-solid fa-ticket"></i>
                </div>
                <div>
                    <h4 style="margin: 0; font-weight: 800; font-size: 1.2rem; color: #fff;" id="voucherModalTitle">Tạo Voucher Khuyến Mãi Mới</h4>
                    <p style="margin: 0; font-size: 0.8rem; color: rgba(255,255,255,0.9);">Thiết lập mã giảm giá để hiển thị ngay ở đầu trang quán ăn</p>
                </div>
            </div>
            <button type="button" class="merchant-modal-close-btn" onclick="closeVoucherModal()" title="Đóng cửa sổ">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- Form -->
        <form action="${pageContext.request.contextPath}/merchant/vouchers" method="POST" id="voucherForm" style="display: flex; flex-direction: column; flex: 1; min-height: 0; margin: 0;">
            <input type="hidden" name="action" id="modalVoucherAction" value="add" />
            <input type="hidden" name="id" id="modalVoucherId" value="" />

            <!-- Body (Cuộn mượt mà) -->
            <div class="merchant-modal-body">
                <div class="row g-3">
                    <!-- CỘT TRÁI: CÁC TRƯỜNG THIẾT LẬP -->
                    <div class="col-12 col-lg-7">
                        <div class="row g-3">
                            <!-- Mã Voucher -->
                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-barcode text-primary me-1"></i> Mã Voucher <span class="text-danger">*</span>
                                </label>
                                <input type="text" name="code" id="modalVoucherCode" class="form-control font-monospace text-uppercase" placeholder="VD: BEPVIET20K" required style="font-weight: 700; letter-spacing: 0.5px;" oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9_-]/g, ''); updateLivePreview();" />
                                <small class="text-muted" style="font-size: 0.75rem;">Viết hoa, không dấu (3-20 ký tự).</small>
                            </div>

                            <!-- Huy hiệu / Tag -->
                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-tag text-warning me-1"></i> Huy hiệu Tag
                                </label>
                                <input type="text" name="badge" id="modalVoucherBadge" class="form-control" placeholder="VD: 🔥 HOT DEAL" value="🔥 HOT DEAL" oninput="updateLivePreview()" />
                            </div>

                            <!-- Tiêu đề -->
                            <div class="col-12">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-heading text-primary me-1"></i> Tiêu đề khuyến mãi <span class="text-danger">*</span>
                                </label>
                                <input type="text" name="title" id="modalVoucherTitle" class="form-control" placeholder="VD: Giảm 20.000 đ cho đơn từ 80K" required oninput="updateLivePreview()" />
                            </div>

                            <!-- Mô tả -->
                            <div class="col-12">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-align-left text-muted me-1"></i> Mô tả chi tiết (Tùy chọn)
                                </label>
                                <textarea name="description" id="modalVoucherDesc" class="form-control" rows="2" placeholder="VD: Áp dụng cho mọi món ăn tại quán khi đặt qua Utee..." oninput="updateLivePreview()"></textarea>
                            </div>

                            <!-- Loại Giảm Giá & Mức Giảm -->
                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-calculator text-primary me-1"></i> Loại giảm giá
                                </label>
                                <select name="discountType" id="modalDiscountType" class="form-select" onchange="toggleDiscountType(this.value); updateLivePreview();">
                                    <option value="FIXED">Giảm số tiền cố định (VNĐ)</option>
                                    <option value="PERCENT">Giảm theo phần trăm (%)</option>
                                </select>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-money-bill-wave text-success me-1"></i> Mức giảm <span class="text-danger">*</span>
                                </label>
                                <div class="input-group">
                                    <input type="number" name="discountValue" id="modalDiscountValue" class="form-control" placeholder="VD: 20000" min="1" required oninput="updateLivePreview()" />
                                    <span class="input-group-text font-weight-bold" id="discountUnit">đ</span>
                                </div>
                            </div>

                            <!-- Giảm tối đa & Đơn tối thiểu -->
                            <div class="col-12 col-md-6" id="maxDiscountGroup" style="display: none;">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-shield text-danger me-1"></i> Giảm tối đa (VNĐ)
                                </label>
                                <div class="input-group">
                                    <input type="number" name="maxDiscount" id="modalMaxDiscount" class="form-control" placeholder="VD: 35000" min="0" oninput="updateLivePreview()" />
                                    <span class="input-group-text">đ</span>
                                </div>
                                <small class="text-muted" style="font-size: 0.72rem;">0 = Không giới hạn mức giảm</small>
                            </div>

                            <div class="col-12 col-md-6" id="minOrderGroup">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-cart-shopping text-primary me-1"></i> Đơn hàng tối thiểu
                                </label>
                                <div class="input-group">
                                    <input type="number" name="minOrderAmount" id="modalMinOrder" class="form-control" placeholder="VD: 80000" min="0" value="0" oninput="updateLivePreview()" />
                                    <span class="input-group-text">đ</span>
                                </div>
                                <small class="text-muted" style="font-size: 0.72rem;">0 = Áp dụng đơn bất kỳ</small>
                            </div>

                            <!-- Giới Hạn Sử Dụng -->
                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-list-ol text-warning me-1"></i> Tổng số lượt dùng tối đa
                                </label>
                                <div class="input-group">
                                    <input type="number" name="usageLimit" id="modalUsageLimit" class="form-control" placeholder="0 = Không giới hạn" min="0" value="0" oninput="updateLivePreview()" />
                                    <span class="input-group-text">lượt</span>
                                </div>
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-solid fa-user text-info me-1"></i> Giới hạn mỗi khách
                                </label>
                                <div class="input-group">
                                    <input type="number" name="perUserLimit" id="modalPerUserLimit" class="form-control" min="1" value="1" />
                                    <span class="input-group-text">lần/khách</span>
                                </div>
                            </div>

                            <!-- Thời Gian Hiệu Lực -->
                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-regular fa-calendar-check text-success me-1"></i> Ngày bắt đầu
                                </label>
                                <input type="date" name="startDate" id="modalStartDate" class="form-control" />
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label fw-bold" style="font-size: 0.88rem;">
                                    <i class="fa-regular fa-calendar-xmark text-danger me-1"></i> Ngày hết hạn
                                </label>
                                <input type="date" name="endDate" id="modalEndDate" class="form-control" onchange="updateLivePreview()" />
                            </div>

                            <!-- Kích Hoạt Ngay -->
                            <div class="col-12">
                                <div class="form-check form-switch mt-1">
                                    <input class="form-check-input" type="checkbox" name="isActive" id="modalIsActive" checked style="cursor: pointer;" />
                                    <label class="form-check-label fw-bold" for="modalIsActive" style="cursor: pointer;">
                                        Kích hoạt ngay (Hiển thị ngay trên đầu trang quán ăn)
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: LIVE TICKET PREVIEW TRỰC QUAN -->
                    <div class="col-12 col-lg-5">
                        <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; padding: 18px; position: sticky; top: 0;">
                            <div style="font-size: 0.85rem; font-weight: 700; color: #475569; margin-bottom: 12px; display: flex; align-items: center; gap: 6px;">
                                <i class="fa-solid fa-mobile-screen-button text-primary"></i> Xem trước hiển thị trên trang quán
                            </div>

                            <!-- Live Ticket Card Mockup -->
                            <div style="display: flex; background: #ffffff; border-radius: 14px; border: 1px solid #fed7aa; overflow: hidden; box-shadow: 0 4px 14px rgba(234,88,12,0.1); position: relative;">
                                <div style="width: 95px; min-width: 95px; background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); color: #ffffff; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 12px 6px; text-align: center; border-right: 2px dashed #fed7aa; position: relative;">
                                    <div id="previewBadge" style="font-size: 0.62rem; background: rgba(255,255,255,0.22); border-radius: 20px; padding: 2px 6px; margin-bottom: 4px; font-weight: 700; white-space: nowrap;">🔥 HOT DEAL</div>
                                    <div style="line-height: 1; margin-bottom: 2px;">
                                        <span id="previewDiscountVal" style="font-size: 1.5rem; font-weight: 800;">20</span><span id="previewDiscountUnit" style="font-size: 0.9rem; font-weight: 700;">K</span>
                                    </div>
                                    <div style="font-size: 0.6rem; font-weight: 800; letter-spacing: 0.5px; opacity: 0.9;">GIẢM NGAY</div>
                                </div>
                                <div style="flex: 1; padding: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                                    <div>
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                            <span id="previewCode" style="background: #fff7ed; border: 1px dashed #fdba74; border-radius: 6px; padding: 1px 6px; font-family: monospace; font-weight: 800; color: #ea580c; font-size: 0.85rem;">BEPVIET20K</span>
                                            <span style="font-size: 0.72rem; color: #64748b;"><i class="fa-solid fa-circle-info"></i> Chi tiết</span>
                                        </div>
                                        <h5 id="previewTitle" style="font-size: 0.88rem; font-weight: 700; color: #0f172a; margin: 2px 0 4px 0; line-height: 1.3;">Giảm 20.000 đ cho đơn từ 80K</h5>
                                        <div style="font-size: 0.75rem; color: #64748b; display: flex; flex-wrap: wrap; gap: 6px;">
                                            <span id="previewMinOrder"><i class="fa-solid fa-basket-shopping"></i> Đơn từ 80K</span>
                                            <span id="previewExpiry"><i class="fa-regular fa-calendar"></i> Vô thời hạn</span>
                                        </div>
                                    </div>
                                    <div style="margin-top: 8px;">
                                        <div style="width: 100%; padding: 6px; border-radius: 8px; font-weight: 700; font-size: 0.8rem; background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); color: #fff; text-align: center;">
                                            <i class="fa-solid fa-bookmark me-1"></i> Lưu Mã Ưu Đãi
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div style="margin-top: 14px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 10px 12px; font-size: 0.78rem; color: #1e40af;">
                                <i class="fa-solid fa-lightbulb text-warning me-1"></i> <strong>Mẹo:</strong> Đặt mã ngắn gọn, dễ nhớ kèm đơn tối thiểu hợp lý sẽ giúp tăng tới 40% tỷ lệ đặt đơn!
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-light rounded-pill px-4" onclick="closeVoucherModal()">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold" id="btnSubmitVoucherModal" style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); border: none;">
                    <i class="fa-solid fa-check me-1"></i> Lưu Voucher Khuyến Mãi
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ====================================================================
     MODAL POPUP: XÁC NHẬN XÓA VOUCHER (CĂN GIỮA MÀN HÌNH)
     ==================================================================== -->
<div id="deleteVoucherModal" class="merchant-modal-backdrop" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.72); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); z-index: 999999; align-items: center; justify-content: center; padding: 20px; overflow-y: auto;" onclick="if(event.target === this) closeDeleteModal();">
    <div class="merchant-modal-container merchant-modal-sm" style="background: #ffffff; width: 100%; max-width: 440px; border-radius: 20px; box-shadow: 0 30px 60px -15px rgba(15, 23, 42, 0.4); overflow: hidden; display: flex; flex-direction: column; margin: auto; position: relative;" onclick="event.stopPropagation();">
        <div style="padding: 24px; text-align: center;">
            <div style="width: 60px; height: 60px; border-radius: 50%; background: #fee2e2; color: #dc2626; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; margin: 0 auto 16px auto;">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <h5 style="font-weight: 800; color: #0f172a; margin-bottom: 8px;">Xác Nhận Xóa Voucher?</h5>
            <p style="font-size: 0.88rem; color: #64748b; margin-bottom: 24px;">
                Bạn có chắc chắn muốn xóa mã voucher <strong id="delVoucherCodeDisplay" class="text-danger"></strong>? Khách hàng sẽ không thể thấy hoặc lưu mã này nữa.
            </p>
            <form action="${pageContext.request.contextPath}/merchant/vouchers" method="POST">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="id" id="deleteVoucherId" value="" />
                <div style="display: flex; gap: 10px; justify-content: center;">
                    <button type="button" class="btn btn-light rounded-pill px-4" onclick="closeDeleteModal()">Hủy</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4 fw-bold">Xóa Ngay</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ====================================================================
     CSS MODAL BACKDROP & CENTERED CONTAINER
     ==================================================================== -->
<style>
.merchant-modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(15, 23, 42, 0.72);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 999999;
    padding: 20px;
    overflow-y: auto;
    animation: mfFadeIn 0.2s ease-out;
}

@keyframes mfFadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes modalSpring {
    0% { transform: scale(0.92); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
}

.merchant-modal-container {
    background: #ffffff;
    width: 100%;
    max-width: 960px;
    max-height: 90vh;
    border-radius: 20px;
    box-shadow: 0 30px 60px -15px rgba(15, 23, 42, 0.4), 0 0 0 1px rgba(226, 232, 240, 0.85);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    margin: auto;
    position: relative;
    animation: modalSpring 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

.merchant-modal-container.merchant-modal-sm {
    max-width: 440px;
}

.merchant-modal-header {
    padding: 16px 24px;
    background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
}

.merchant-modal-close-btn {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: rgba(255,255,255,0.2);
    border: none;
    color: #ffffff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
    cursor: pointer;
    transition: background 0.15s ease;
}

.merchant-modal-close-btn:hover {
    background: rgba(255,255,255,0.35);
}

.merchant-modal-body {
    padding: 24px;
    overflow-y: auto;
    background: #fafafa;
    flex: 1;
}

.merchant-modal-footer {
    padding: 16px 24px;
    background: #ffffff;
    border-top: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
}
</style>

<script>
function toggleDiscountType(type) {
    const maxGroup = document.getElementById('maxDiscountGroup');
    const unit = document.getElementById('discountUnit');
    if (type === 'PERCENT') {
        maxGroup.style.display = 'block';
        unit.textContent = '%';
    } else {
        maxGroup.style.display = 'none';
        unit.textContent = 'đ';
    }
}

function updateLivePreview() {
    const code = document.getElementById('modalVoucherCode').value || 'BEPVIET20K';
    const badge = document.getElementById('modalVoucherBadge').value || '🔥 HOT DEAL';
    const title = document.getElementById('modalVoucherTitle').value || 'Giảm 20.000 đ cho đơn từ 80K';
    const type = document.getElementById('modalDiscountType').value;
    const val = parseFloat(document.getElementById('modalDiscountValue').value) || 20000;
    const minOrder = parseFloat(document.getElementById('modalMinOrder').value) || 0;
    const endDate = document.getElementById('modalEndDate').value;

    document.getElementById('previewCode').textContent = code;
    document.getElementById('previewBadge').textContent = badge;
    document.getElementById('previewTitle').textContent = title;

    if (type === 'PERCENT') {
        document.getElementById('previewDiscountVal').textContent = val;
        document.getElementById('previewDiscountUnit').textContent = '%';
    } else {
        const kVal = val >= 1000 ? Math.round(val / 1000) : val;
        document.getElementById('previewDiscountVal').textContent = kVal;
        document.getElementById('previewDiscountUnit').textContent = 'K';
    }

    document.getElementById('previewMinOrder').innerHTML = minOrder > 0 
        ? '<i class="fa-solid fa-basket-shopping"></i> Đơn từ ' + (minOrder >= 1000 ? (Math.round(minOrder/1000) + 'K') : (minOrder + 'đ'))
        : '<i class="fa-solid fa-basket-shopping"></i> Đơn bất kỳ';

    document.getElementById('previewExpiry').innerHTML = endDate 
        ? ('<i class="fa-regular fa-calendar"></i> HSD: ' + endDate)
        : '<i class="fa-regular fa-calendar"></i> Vô thời hạn';
}

function openAddVoucherModal() {
    document.getElementById('voucherForm').reset();
    document.getElementById('modalVoucherAction').value = 'add';
    document.getElementById('modalVoucherId').value = '';
    document.getElementById('voucherModalTitle').innerText = 'Tạo Voucher Khuyến Mãi Mới';
    document.getElementById('btnSubmitVoucherModal').innerHTML = '<i class="fa-solid fa-plus me-1"></i> Tạo Voucher Ngay';
    document.getElementById('modalIsActive').checked = true;
    document.getElementById('modalVoucherBadge').value = '🔥 HOT DEAL';
    document.getElementById('modalPerUserLimit').value = '1';
    document.getElementById('modalUsageLimit').value = '0';
    document.getElementById('modalMinOrder').value = '0';
    document.getElementById('modalDiscountType').value = 'FIXED';
    document.getElementById('modalDiscountValue').value = '20000';
    document.getElementById('modalMaxDiscount').value = '0';
    
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('modalStartDate').value = today;
    document.getElementById('modalEndDate').value = '';
    
    toggleDiscountType('FIXED');
    updateLivePreview();

    document.getElementById('voucherModal').style.display = 'flex';
}

function openEditVoucherModal(id, code, title, desc, type, discountVal, minOrder, maxDiscount, usageLimit, perUserLimit, startDate, endDate, badge, isActive) {
    document.getElementById('voucherForm').reset();
    document.getElementById('modalVoucherAction').value = 'edit';
    document.getElementById('modalVoucherId').value = id;
    document.getElementById('voucherModalTitle').innerText = 'Chỉnh Sửa Voucher: ' + code;
    document.getElementById('btnSubmitVoucherModal').innerHTML = '<i class="fa-solid fa-check me-1"></i> Cập Nhật Voucher';

    document.getElementById('modalVoucherCode').value = code || '';
    document.getElementById('modalVoucherTitle').value = title || '';
    document.getElementById('modalVoucherDesc').value = desc || '';
    document.getElementById('modalDiscountType').value = type || 'FIXED';
    document.getElementById('modalDiscountValue').value = discountVal || 0;
    document.getElementById('modalMinOrder').value = minOrder || 0;
    document.getElementById('modalMaxDiscount').value = maxDiscount || 0;
    document.getElementById('modalUsageLimit').value = usageLimit || 0;
    document.getElementById('modalPerUserLimit').value = perUserLimit || 1;
    document.getElementById('modalStartDate').value = startDate || '';
    document.getElementById('modalEndDate').value = endDate || '';
    document.getElementById('modalVoucherBadge').value = badge || '🔥 ƯU ĐÃI QUÁN';
    document.getElementById('modalIsActive').checked = (isActive === true || isActive === 'true');

    toggleDiscountType(type);
    updateLivePreview();

    document.getElementById('voucherModal').style.display = 'flex';
}

function closeVoucherModal() {
    document.getElementById('voucherModal').style.display = 'none';
}

function confirmDeleteVoucher(id, code) {
    document.getElementById('deleteVoucherId').value = id;
    document.getElementById('delVoucherCodeDisplay').textContent = code;
    document.getElementById('deleteVoucherModal').style.display = 'flex';
}

function closeDeleteModal() {
    document.getElementById('deleteVoucherModal').style.display = 'none';
}

function copyVoucherCode(code) {
    if (!code) return;
    navigator.clipboard.writeText(code).then(() => {
        alert('Đã sao chép mã voucher: ' + code);
    }).catch(() => {
        prompt('Sao chép mã voucher bên dưới:', code);
    });
}

// Lắng nghe phím Escape để đóng modal
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeVoucherModal();
        closeDeleteModal();
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
