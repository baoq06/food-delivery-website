<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Bảng Điều Khiển Quản Trị - Utee Admin" />
</jsp:include>

<div class="admin-dashboard-container">
    <div class="container section">
        <!-- Feedback Alerts -->
        <c:if test="${param.msg eq 'approved'}">
            <div style="background: #ecfdf5; border: 1px solid #10b981; color: #065f46; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-circle-check text-success" style="font-size: 1.2rem;"></i>
                <span>Đã duyệt đơn hàng thành công! Đơn đã được chuyển cho nhà bếp và tài xế.</span>
            </div>
        </c:if>
        <c:if test="${param.msg eq 'banned_driver'}">
            <div style="background: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-ban text-danger" style="font-size: 1.2rem;"></i>
                <span>Đã cấm tài xế có số điện thoại <strong><c:out value="${param.phone}" /></strong> hoạt động thành công!</span>
            </div>
        </c:if>
        <c:if test="${param.msg eq 'unbanned_driver'}">
            <div style="background: #ecfdf5; border: 1px solid #10b981; color: #065f46; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-circle-check text-success" style="font-size: 1.2rem;"></i>
                <span>Đã gỡ cấm (mở khóa) cho tài xế có số điện thoại <strong><c:out value="${param.phone}" /></strong> thành công!</span>
            </div>
        </c:if>
        <c:if test="${param.msg eq 'banned_restaurant'}">
            <div style="background: #fee2e2; border: 1px solid #ef4444; color: #991b1b; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-ban text-danger" style="font-size: 1.2rem;"></i>
                <span>Đã cấm quán ăn có số điện thoại <strong><c:out value="${param.phone}" /></strong> hoạt động thành công!</span>
            </div>
        </c:if>
        <c:if test="${param.msg eq 'unbanned_restaurant'}">
            <div style="background: #ecfdf5; border: 1px solid #10b981; color: #065f46; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-circle-check text-success" style="font-size: 1.2rem;"></i>
                <span>Đã gỡ cấm (mở khóa) cho quán ăn có số điện thoại <strong><c:out value="${param.phone}" /></strong> thành công!</span>
            </div>
        </c:if>
        <c:if test="${param.error eq 'phone_not_found'}">
            <div style="background: #fff1f2; border: 1px solid #f43f5e; color: #be123c; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.2rem;"></i>
                <span>Không tìm thấy đối tác nào tương ứng với số điện thoại: <strong><c:out value="${param.phone}" /></strong>!</span>
            </div>
        </c:if>
        <c:if test="${param.error eq 'empty_phone'}">
            <div style="background: #fff1f2; border: 1px solid #f43f5e; color: #be123c; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.2rem;"></i>
                <span>Vui lòng nhập số điện thoại hợp lệ để thực hiện thao tác cấm/mở khóa!</span>
            </div>
        </c:if>
        <c:if test="${param.error eq 'ban_failed' or param.error eq 'unban_failed'}">
            <div style="background: #fff1f2; border: 1px solid #f43f5e; color: #be123c; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; font-weight: 600;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size: 1.2rem;"></i>
                <span>Không thể thực hiện thao tác. Vui lòng kiểm tra lại thông tin hoặc thử lại sau!</span>
            </div>
        </c:if>

        <!-- Admin Header -->
        <div class="admin-header-box">
            <div>
                <span class="admin-badge"><i class="fa-solid fa-shield-halved"></i> Hệ Thống Quản Trị Trung Tâm</span>
                <h1 class="admin-main-title">Bảng Điều Khiển & Giám Sát Đơn Hàng</h1>
                <p class="admin-sub">Xin chào, <strong>${sessionScope.currentUser != null ? sessionScope.currentUser.fullName : 'Quản trị viên'}</strong>! Chúc bạn một ngày làm việc hiệu quả.</p>
            </div>
            <div class="admin-actions">
                <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline"><i class="fa-solid fa-eye"></i> Xem Website Khách</a>
                <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-danger"><i class="fa-solid fa-arrow-right-from-bracket"></i> Đăng Xuất</a>
            </div>
        </div>

        <div class="nav-tabs-admin" style="margin-bottom: 24px; border-bottom: 2px solid #e2e8f0; display: flex; gap: 4px;">
            <a href="${pageContext.request.contextPath}/admin/dashboard" style="padding: 12px 24px; text-decoration: none; font-weight: 600; border-radius: 8px 8px 0 0; color: ${empty param.tab or param.tab eq 'dashboard' ? '#fff' : '#64748b'}; background: ${empty param.tab or param.tab eq 'dashboard' ? '#2563eb' : 'transparent'}; border-bottom: ${empty param.tab or param.tab eq 'dashboard' ? 'none' : '2px solid transparent'};"><i class="fa-solid fa-chart-pie"></i> Thống Kê Tổng Quan</a>
            <a href="${pageContext.request.contextPath}/admin/dashboard?tab=shippers" style="padding: 12px 24px; text-decoration: none; font-weight: 600; border-radius: 8px 8px 0 0; color: ${param.tab eq 'shippers' ? '#fff' : '#64748b'}; background: ${param.tab eq 'shippers' ? '#10ac84' : 'transparent'}; border-bottom: ${param.tab eq 'shippers' ? 'none' : '2px solid transparent'};"><i class="fa-solid fa-motorcycle"></i> Quản Lý Tài Xế</a>
            <a href="${pageContext.request.contextPath}/admin/dashboard?tab=restaurants" style="padding: 12px 24px; text-decoration: none; font-weight: 600; border-radius: 8px 8px 0 0; color: ${param.tab eq 'restaurants' ? '#fff' : '#64748b'}; background: ${param.tab eq 'restaurants' ? '#f59e0b' : 'transparent'}; border-bottom: ${param.tab eq 'restaurants' ? 'none' : '2px solid transparent'};"><i class="fa-solid fa-store"></i> Quản Lý Quán Ăn</a>
        </div>

        <c:choose>
            <c:when test="${param.tab eq 'shippers'}">
                <!-- 1. Cấm / Gỡ Cấm Tài Xế Bằng Số Điện Thoại -->
                <div class="admin-ban-control-card">
                    <div class="admin-ban-control-header">
                        <div class="admin-ban-title">
                            <i class="fa-solid fa-shield-halved" style="color: #ef4444; font-size: 1.25rem;"></i>
                            <span>Kiểm Soát &amp; Cấm Tài Xế Qua Số Điện Thoại</span>
                        </div>
                        <span style="font-size: 0.85rem; color: #64748b;">
                            <i class="fa-solid fa-circle-info"></i> Nhập số điện thoại tài xế để cấm hoặc mở khóa hoạt động tức thì
                        </span>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="admin-ban-form-grid">
                        <input type="hidden" name="action" value="banByPhone" />
                        <input type="hidden" name="targetType" value="SHIPPER" />
                        <div class="admin-phone-input-wrap">
                            <i class="fa-solid fa-phone"></i>
                            <input type="text" name="phone" id="quickBanDriverPhone" class="admin-phone-input" placeholder="Nhập số điện thoại tài xế (ví dụ: 0901234567)..." required />
                        </div>
                        <select name="banAction" class="admin-select-action">
                            <option value="BAN">🔴 Cấm hoạt động (Khóa tài khoản)</option>
                            <option value="UNBAN">🟢 Mở khóa (Gỡ cấm)</option>
                        </select>
                        <button type="submit" class="btn btn-danger" style="padding: 10px 20px; font-weight: 700; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;" onclick="return confirm('Bạn có chắc chắn muốn thực hiện thao tác cấm/mở khóa đối với số điện thoại này?');">
                            <i class="fa-solid fa-gavel"></i> Thực thi
                        </button>
                    </form>
                </div>

                <!-- 2. Bảng Danh Sách Tài Xế & Thanh Tìm Kiếm -->
                <div class="admin-table-card mt-2">
                    <div class="admin-table-header" style="flex-direction: column; align-items: stretch; gap: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                            <div>
                                <h3 class="table-card-title"><i class="fa-solid fa-motorcycle text-primary"></i> Quản Lý Đối Tác Tài Xế (Shipper)</h3>
                                <span class="table-card-sub">Giám sát, tìm kiếm và kiểm soát trạng thái hoạt động của đối tác giao vận</span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <span id="driverCountBadge" class="badge" style="background: #e0f2fe; color: #0284c7; font-size: 0.9rem; padding: 8px 16px; border-radius: 20px; font-weight: 700;">
                                    <i class="fa-solid fa-motorcycle"></i> Hiển thị: <strong id="driverVisibleCount">${allDrivers.size()}</strong> tài xế
                                </span>
                                <c:if test="${not empty searchKeyword}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard?tab=shippers" class="btn btn-outline btn-sm" style="border-radius: 20px;">
                                        <i class="fa-solid fa-rotate-left"></i> Xem tất cả
                                    </a>
                                </c:if>
                            </div>
                        </div>

                        <!-- Toolbar Search -->
                        <div class="admin-toolbar-row" style="margin-bottom: 0;">
                            <form action="${pageContext.request.contextPath}/admin/dashboard" method="GET" style="display: flex; gap: 10px; flex: 1; max-width: 540px;" onsubmit="return true;">
                                <input type="hidden" name="tab" value="shippers" />
                                <div class="admin-search-wrapper">
                                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                    <input type="text" name="search" id="driverSearchInput" class="admin-search-input" value="<c:out value='${searchKeyword}' />" placeholder="Tìm kiếm tên shipper, số điện thoại, biển số..." autocomplete="off" />
                                    <button type="button" id="clearDriverSearch" class="admin-search-clear" title="Xóa tìm kiếm"><i class="fa-solid fa-circle-xmark"></i></button>
                                </div>
                                <button type="submit" class="btn btn-primary" style="padding: 0 20px; border-radius: 12px; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-magnifying-glass"></i> Tìm
                                </button>
                            </form>
                            <span style="font-size: 0.85rem; color: #64748b;">
                                <i class="fa-solid fa-bolt text-warning"></i> Hỗ trợ tìm kiếm nhanh theo tên hoặc số điện thoại theo thời gian thực
                            </span>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="admin-data-table" id="driverTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tài Xế</th>
                                    <th>Số Điện Thoại</th>
                                    <th>Khu Vực Giao Hàng</th>
                                    <th>Phương Tiện &amp; Biển Số</th>
                                    <th>Trạng Thái</th>
                                    <th>Hành Động</th>
                                </tr>
                            </thead>
                            <tbody id="driverTableBody">
                                <c:choose>
                                    <c:when test="${not empty allDrivers}">
                                        <c:forEach items="${allDrivers}" var="drv">
                                            <tr class="driver-row" data-name="${drv.name.toLowerCase()}" data-phone="${drv.phone}" data-plate="${drv.licensePlate != null ? drv.licensePlate.toLowerCase() : ''}" data-status="${drv.status}">
                                                <td><strong>#${drv.id}</strong></td>
                                                <td>
                                                    <div style="display: flex; align-items: center; gap: 12px;">
                                                        <c:choose>
                                                            <c:when test="${not empty drv.avatar}">
                                                                <img src="${drv.avatar.startsWith('http') ? drv.avatar : pageContext.request.contextPath.concat(drv.avatar)}" alt="${drv.name}" class="admin-avatar-circle" style="border-radius: 50%;" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="admin-avatar-circle" style="background: linear-gradient(135deg, #10ac84 0%, #1dd1a1 100%); color: #fff;">
                                                                    <i class="fa-solid fa-motorcycle"></i>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <div style="font-weight: 700; color: #1e293b;"><c:out value="${drv.name}" /></div>
                                                            <div style="font-size: 0.8rem; color: #94a3b8;">User ID: #${drv.userId != null ? drv.userId : 'N/A'}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="admin-phone-pill copy-phone-btn" data-phone="${drv.phone}" title="Bấm để đưa SĐT vào ô cấm nhanh">
                                                        <i class="fa-solid fa-phone text-primary" style="font-size: 0.78rem;"></i>
                                                        <span><c:out value="${drv.phone}" /></span>
                                                        <i class="fa-regular fa-copy" style="font-size: 0.75rem; color: #94a3b8;"></i>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span title="${drv.currentAddress}" style="display: inline-block; max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #475569;">
                                                        <i class="fa-solid fa-location-dot text-danger" style="margin-right: 4px;"></i>
                                                        <c:out value="${drv.currentAddress != null ? drv.currentAddress : 'Chưa cập nhật'}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <div>
                                                        <span style="font-weight: 600; color: #334155;"><c:out value="${drv.licensePlate != null ? drv.licensePlate : 'N/A'}" /></span>
                                                        <div style="font-size: 0.8rem; color: #94a3b8;"><c:out value="${drv.vehicleType != null ? drv.vehicleType : 'Xe máy'}" /></div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${drv.status eq 'BANNED'}">
                                                            <span class="badge-status-banned">
                                                                <i class="fa-solid fa-ban"></i> ĐÃ BỊ CẤM
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${drv.status eq 'AVAILABLE'}">
                                                            <span class="badge-status-available">
                                                                <i class="fa-solid fa-circle-check"></i> Sẵn sàng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${drv.status eq 'BUSY'}">
                                                            <span class="badge-status-busy">
                                                                <i class="fa-solid fa-route"></i> Đang giao
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status-offline">
                                                                <i class="fa-solid fa-moon"></i> Ngoại tuyến
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${drv.status eq 'BANNED'}">
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard?action=unbanDriver&phone=${drv.phone}&driverId=${drv.id}" 
                                                               class="btn-action-unban"
                                                               onclick="return confirm('Bạn có chắc chắn muốn GỠ CẤM (mở khóa) cho tài xế ${drv.name} (SĐT: ${drv.phone})?');">
                                                                <i class="fa-solid fa-lock-open"></i> Gỡ cấm
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard?action=banDriver&phone=${drv.phone}&driverId=${drv.id}" 
                                                               class="btn-action-ban"
                                                               onclick="return confirm('CẢNH BÁO: Bạn có chắc chắn muốn CẤM tài xế ${drv.name} (SĐT: ${drv.phone}) hoạt động?');">
                                                                <i class="fa-solid fa-ban"></i> Cấm tài xế
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr id="emptyDriverRow">
                                            <td colspan="7" style="text-align: center; padding: 40px 20px; color: #64748b;">
                                                <i class="fa-solid fa-motorcycle" style="font-size: 2.2rem; margin-bottom: 12px; display: block; color: #cbd5e1;"></i>
                                                Không tìm thấy tài xế nào trong hệ thống${not empty searchKeyword ? ' với từ khóa: ' .concat(searchKeyword) : ''}.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                <tr id="noMatchDriverRow" style="display: none;">
                                    <td colspan="7" style="text-align: center; padding: 36px 20px; color: #64748b;">
                                        <i class="fa-solid fa-magnifying-glass" style="font-size: 2rem; margin-bottom: 10px; display: block; color: #cbd5e1;"></i>
                                        Không tìm thấy tài xế nào khớp với từ khóa tìm kiếm.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:when>

            <c:when test="${param.tab eq 'restaurants'}">
                <!-- 1. Cấm / Gỡ Cấm Quán Ăn Bằng Số Điện Thoại -->
                <div class="admin-ban-control-card">
                    <div class="admin-ban-control-header">
                        <div class="admin-ban-title">
                            <i class="fa-solid fa-store-slash" style="color: #ef4444; font-size: 1.25rem;"></i>
                            <span>Kiểm Soát &amp; Cấm Quán Ăn Qua Số Điện Thoại</span>
                        </div>
                        <span style="font-size: 0.85rem; color: #64748b;">
                            <i class="fa-solid fa-circle-info"></i> Nhập số điện thoại quán ăn hoặc chủ quán để cấm hoặc mở khóa hoạt động tức thì
                        </span>
                    </div>
                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="admin-ban-form-grid">
                        <input type="hidden" name="action" value="banByPhone" />
                        <input type="hidden" name="targetType" value="RESTAURANT" />
                        <div class="admin-phone-input-wrap">
                            <i class="fa-solid fa-phone"></i>
                            <input type="text" name="phone" id="quickBanRestPhone" class="admin-phone-input" placeholder="Nhập số điện thoại quán ăn (ví dụ: 0901234567)..." required />
                        </div>
                        <select name="banAction" class="admin-select-action">
                            <option value="BAN">🔴 Cấm hoạt động (Đóng &amp; Khóa quán)</option>
                            <option value="UNBAN">🟢 Mở khóa (Gỡ cấm)</option>
                        </select>
                        <button type="submit" class="btn btn-danger" style="padding: 10px 20px; font-weight: 700; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;" onclick="return confirm('Bạn có chắc chắn muốn thực hiện thao tác cấm/mở khóa đối với số điện thoại này?');">
                            <i class="fa-solid fa-gavel"></i> Thực thi
                        </button>
                    </form>
                </div>

                <!-- 2. Bảng Danh Sách Quán Ăn & Thanh Tìm Kiếm -->
                <div class="admin-table-card mt-2">
                    <div class="admin-table-header" style="flex-direction: column; align-items: stretch; gap: 16px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                            <div>
                                <h3 class="table-card-title"><i class="fa-solid fa-store text-warning"></i> Quản Lý Đối Tác Quán Ăn (Nhà Hàng)</h3>
                                <span class="table-card-sub">Giám sát, tìm kiếm và kiểm soát trạng thái hoạt động của đối tác ẩm thực</span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <span id="restaurantCountBadge" class="badge" style="background: #fef3c7; color: #b45309; font-size: 0.9rem; padding: 8px 16px; border-radius: 20px; font-weight: 700;">
                                    <i class="fa-solid fa-store"></i> Hiển thị: <strong id="restaurantVisibleCount">${allRestaurants.size()}</strong> quán ăn
                                </span>
                                <c:if test="${not empty searchKeyword}">
                                    <a href="${pageContext.request.contextPath}/admin/dashboard?tab=restaurants" class="btn btn-outline btn-sm" style="border-radius: 20px;">
                                        <i class="fa-solid fa-rotate-left"></i> Xem tất cả
                                    </a>
                                </c:if>
                            </div>
                        </div>

                        <!-- Toolbar Search -->
                        <div class="admin-toolbar-row" style="margin-bottom: 0;">
                            <form action="${pageContext.request.contextPath}/admin/dashboard" method="GET" style="display: flex; gap: 10px; flex: 1; max-width: 540px;" onsubmit="return true;">
                                <input type="hidden" name="tab" value="restaurants" />
                                <div class="admin-search-wrapper">
                                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                    <input type="text" name="search" id="restaurantSearchInput" class="admin-search-input" value="<c:out value='${searchKeyword}' />" placeholder="Tìm kiếm tên quán ăn, số điện thoại, địa chỉ..." autocomplete="off" />
                                    <button type="button" id="clearRestSearch" class="admin-search-clear" title="Xóa tìm kiếm"><i class="fa-solid fa-circle-xmark"></i></button>
                                </div>
                                <button type="submit" class="btn btn-warning text-white" style="padding: 0 20px; border-radius: 12px; font-weight: 700; background: #f59e0b; display: inline-flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-magnifying-glass"></i> Tìm
                                </button>
                            </form>
                            <span style="font-size: 0.85rem; color: #64748b;">
                                <i class="fa-solid fa-bolt text-warning"></i> Hỗ trợ tìm kiếm nhanh theo tên quán hoặc số điện thoại theo thời gian thực
                            </span>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="admin-data-table" id="restaurantTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Quán Ăn / Thương Hiệu</th>
                                    <th>SĐT Liên Hệ</th>
                                    <th>Đánh Giá</th>
                                    <th>Địa Chỉ</th>
                                    <th>Trạng Thái</th>
                                    <th>Hành Động</th>
                                </tr>
                            </thead>
                            <tbody id="restaurantTableBody">
                                <c:choose>
                                    <c:when test="${not empty allRestaurants}">
                                        <c:forEach items="${allRestaurants}" var="rest">
                                            <tr class="rest-row" data-name="${rest.name.toLowerCase()}" data-phone="${rest.phone}" data-address="${rest.address != null ? rest.address.toLowerCase() : ''}" data-status="${rest.status}">
                                                <td><strong>#${rest.id}</strong></td>
                                                <td>
                                                    <div style="display: flex; align-items: center; gap: 12px;">
                                                        <c:set var="logoSrc" value="${not empty rest.displayLogo ? rest.displayLogo : rest.imageUrl}" />
                                                        <img src="${logoSrc.startsWith('http') ? logoSrc : pageContext.request.contextPath.concat(logoSrc)}" 
                                                             alt="${rest.name}" 
                                                             style="width: 48px; height: 48px; border-radius: 12px; object-fit: cover; border: 1.5px solid #e2e8f0; box-shadow: 0 2px 6px rgba(0,0,0,0.06);"
                                                             onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=100&auto=format&fit=crop&q=60';" />
                                                        <div>
                                                            <a href="${pageContext.request.contextPath}/restaurant-detail?id=${rest.id}" target="_blank" style="font-weight: 700; color: #1e293b; text-decoration: none;" title="Xem trang quán">
                                                                <c:out value="${rest.name}" /> <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 0.72rem; color: #94a3b8;"></i>
                                                            </a>
                                                            <div style="font-size: 0.8rem; color: #94a3b8;">Chủ quán ID: #${rest.userId != null ? rest.userId : 'N/A'}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="admin-phone-pill copy-phone-btn" data-phone="${rest.phone}" title="Bấm để đưa SĐT vào ô cấm nhanh">
                                                        <i class="fa-solid fa-phone text-warning" style="font-size: 0.78rem;"></i>
                                                        <span><c:out value="${rest.phone}" /></span>
                                                        <i class="fa-regular fa-copy" style="font-size: 0.75rem; color: #94a3b8;"></i>
                                                    </span>
                                                </td>
                                                <td>
                                                    <div style="display: flex; align-items: center; gap: 6px;">
                                                        <i class="fa-solid fa-star text-warning"></i> 
                                                        <strong style="color: #1e293b;">${rest.rating}</strong> 
                                                        <span style="font-size: 0.82rem; color: #94a3b8;">(${rest.reviewCount})</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span title="${rest.address}" style="display: inline-block; max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #475569;">
                                                        <i class="fa-solid fa-location-dot text-danger" style="margin-right: 4px;"></i>
                                                        <c:out value="${rest.address}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${rest.status eq 'BANNED'}">
                                                            <span class="badge-status-banned">
                                                                <i class="fa-solid fa-ban"></i> ĐÃ BỊ CẤM
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${rest.status eq 'OPEN'}">
                                                            <span class="badge-status-available">
                                                                <i class="fa-solid fa-door-open"></i> Đang mở cửa
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status-offline">
                                                                <i class="fa-solid fa-door-closed"></i> Tạm đóng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${rest.status eq 'BANNED'}">
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard?action=unbanRestaurant&phone=${rest.phone}&restaurantId=${rest.id}" 
                                                               class="btn-action-unban"
                                                               onclick="return confirm('Bạn có chắc chắn muốn GỠ CẤM (mở khóa) cho quán ăn ${rest.name} (SĐT: ${rest.phone})?');">
                                                                <i class="fa-solid fa-lock-open"></i> Gỡ cấm
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard?action=banRestaurant&phone=${rest.phone}&restaurantId=${rest.id}" 
                                                               class="btn-action-ban"
                                                               onclick="return confirm('CẢNH BÁO: Bạn có chắc chắn muốn CẤM quán ăn ${rest.name} (SĐT: ${rest.phone}) hoạt động?');">
                                                                <i class="fa-solid fa-ban"></i> Cấm quán
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr id="emptyRestRow">
                                            <td colspan="7" style="text-align: center; padding: 40px 20px; color: #64748b;">
                                                <i class="fa-solid fa-store" style="font-size: 2.2rem; margin-bottom: 12px; display: block; color: #cbd5e1;"></i>
                                                Không tìm thấy quán ăn nào trong hệ thống${not empty searchKeyword ? ' với từ khóa: ' .concat(searchKeyword) : ''}.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                <tr id="noMatchRestRow" style="display: none;">
                                    <td colspan="7" style="text-align: center; padding: 36px 20px; color: #64748b;">
                                        <i class="fa-solid fa-magnifying-glass" style="font-size: 2rem; margin-bottom: 10px; display: block; color: #cbd5e1;"></i>
                                        Không tìm thấy quán ăn nào khớp với từ khóa tìm kiếm.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <!-- Metric Stat Cards (Real Database Data) -->
                <div class="admin-stats-grid">
                    <div class="admin-stat-card card-revenue">
                        <div class="stat-icon-wrap icon-red">
                            <i class="fa-solid fa-sack-dollar"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-title">Doanh Thu Admin (10%)</span>
                            <h3 class="stat-val"><fmt:formatNumber value="${adminRevenue}" pattern="#,##0" /> đ</h3>
                            <span class="stat-sub"><i class="fa-solid fa-circle-check text-success"></i> 10% giá trị món giao (${orderStats['DELIVERED'] != null ? orderStats['DELIVERED'] : 0} đơn, trừ ship)</span>
                        </div>
                    </div>

                    <div class="admin-stat-card card-orders">
                        <div class="stat-icon-wrap icon-orange">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-title">Tổng Đơn Hàng</span>
                            <h3 class="stat-val">${orderStats['TOTAL'] != null ? orderStats['TOTAL'] : 0} đơn</h3>
                            <span class="stat-sub">${orderStats['PENDING'] != null ? orderStats['PENDING'] : 0} chờ duyệt • ${orderStats['SHIPPING'] != null ? orderStats['SHIPPING'] : 0} đang giao</span>
                        </div>
                    </div>

                    <div class="admin-stat-card card-foods">
                        <div class="stat-icon-wrap icon-green">
                            <i class="fa-solid fa-bowl-food"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-title">Món Ăn Hoạt Động</span>
                            <h3 class="stat-val">${foodCount} món</h3>
                            <span class="stat-sub">Phân bố trên ${categoryCount} danh mục</span>
                        </div>
                    </div>

                    <div class="admin-stat-card card-users">
                        <div class="stat-icon-wrap icon-blue">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <span class="stat-title">Tổng Người Dùng</span>
                            <h3 class="stat-val">${userStats['totalUsers'] != null ? userStats['totalUsers'] : 0} thành viên</h3>
                            <span class="stat-sub">${userStats['customerCount'] != null ? userStats['customerCount'] : 0} khách • ${userStats['driverCount'] != null ? userStats['driverCount'] : 0} shipper • ${userStats['restaurantCount'] != null ? userStats['restaurantCount'] : 0} quán</span>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders Table (Real Database Data) -->
                <div class="admin-table-card mt-4">
                    <div class="admin-table-header">
                        <div>
                            <h3 class="table-card-title"><i class="fa-solid fa-clock-rotate-left text-primary"></i> Đơn Đặt Hàng Gần Đây Cần Xử Lý</h3>
                            <span class="table-card-sub">Dữ liệu được cập nhật trực tiếp từ cơ sở dữ liệu</span>
                        </div>
                        <button class="btn btn-primary btn-sm" onclick="window.location.href='${pageContext.request.contextPath}/admin/dashboard'"><i class="fa-solid fa-rotate"></i> Làm mới</button>
                    </div>

                    <div class="table-responsive">
                        <table class="admin-data-table">
                            <thead>
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th>Khách Hàng</th>
                                    <th>Quán & Tài Xế</th>
                                    <th>Món Đặt</th>
                                    <th>Tổng Tiền</th>
                                    <th>Thanh Toán</th>
                                    <th>Trạng Thái</th>
                                    <th>Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty recentOrders}">
                                        <c:forEach items="${recentOrders}" var="order">
                                            <tr>
                                                <td><strong>#${order.id}</strong></td>
                                                <td>
                                                    <c:out value="${order.customerName}" />
                                                    <div style="font-size: 0.85rem; color: #64748b;"><c:out value="${order.phone}" /></div>
                                                </td>
                                                <td>
                                                    <div style="margin-bottom: 4px;">
                                                        <i class="fa-solid fa-store text-warning" style="width: 16px;"></i> 
                                                        <span style="font-weight: 500;"><c:out value="${not empty order.restaurantName ? order.restaurantName : 'N/A'}" /></span>
                                                    </div>
                                                    <div style="font-size: 0.85rem; color: #64748b;">
                                                        <i class="fa-solid fa-motorcycle text-primary" style="width: 16px;"></i> 
                                                        <c:choose>
                                                            <c:when test="${not empty order.driverName}">
                                                                <c:out value="${order.driverName}" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <em>Chưa nhận</em>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span title="<c:out value='${not empty order.foodSummary ? order.foodSummary : \"Đơn đặt món\"}' />">
                                                        <c:out value="${not empty order.foodSummary ? order.foodSummary : 'Đơn đặt món'}" />
                                                    </span>
                                                </td>
                                                <td class="font-weight-bold text-primary">
                                                    <fmt:formatNumber value="${order.totalAmount}" pattern="#,##0" /> đ
                                                    <c:if test="${order.adminCommission > 0}">
                                                        <div style="font-size: 0.78rem; color: #059669; font-weight: 600;" title="Hoa hồng Admin 10% giá trị món ăn">
                                                            +<fmt:formatNumber value="${order.adminCommission}" pattern="#,##0" /> đ (10%)
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <span class="badge ${order.paymentMethod eq 'COD' ? 'badge-cod' : 'badge-qr'}">
                                                        <c:out value="${order.paymentMethod != null ? order.paymentMethod : 'COD'}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <span class="badge badge-pending">Chờ xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'CONFIRMED'}">
                                                            <span class="badge" style="background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd;">Đã xác nhận</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'SHIPPING'}">
                                                            <span class="badge badge-shipping">Đang giao hàng</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'DELIVERED'}">
                                                            <span class="badge badge-done">Đã hoàn thành</span>
                                                        </c:when>
                                                        <c:when test="${order.status eq 'CANCELLED'}">
                                                            <span class="badge" style="background: #fee2e2; color: #991b1b; border: 1px solid #fecaca;">Đã hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-secondary">${order.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${order.status eq 'PENDING'}">
                                                            <a href="${pageContext.request.contextPath}/admin/dashboard?action=approve&orderId=${order.id}"
                                                               class="btn-action btn-approve"
                                                               onclick="return confirm('Bạn có chắc chắn muốn duyệt đơn #${order.id}?');">
                                                                <i class="fa-solid fa-check"></i> Duyệt
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;"><i class="fa-solid fa-circle-check text-success"></i> Đã xử lý</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" style="text-align: center; padding: 40px 20px; color: #64748b;">
                                                <i class="fa-solid fa-inbox" style="font-size: 2rem; margin-bottom: 10px; display: block; color: #94a3b8;"></i>
                                                Hiện tại chưa có đơn đặt hàng nào trong hệ thống.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // 1. Click phone pill to auto-fill quick ban input
    document.querySelectorAll('.copy-phone-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var phone = this.getAttribute('data-phone');
            if (!phone) return;
            
            var driverPhoneInput = document.getElementById('quickBanDriverPhone');
            var restPhoneInput = document.getElementById('quickBanRestPhone');
            
            if (driverPhoneInput) {
                driverPhoneInput.value = phone.trim();
                driverPhoneInput.focus();
                driverPhoneInput.style.backgroundColor = '#fef2f2';
                driverPhoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                setTimeout(function() { driverPhoneInput.style.backgroundColor = '#ffffff'; }, 800);
            } else if (restPhoneInput) {
                restPhoneInput.value = phone.trim();
                restPhoneInput.focus();
                restPhoneInput.style.backgroundColor = '#fef2f2';
                restPhoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                setTimeout(function() { restPhoneInput.style.backgroundColor = '#ffffff'; }, 800);
            }
        });
    });

    // 2. Real-time Live Filter for Driver Table
    var driverInput = document.getElementById('driverSearchInput');
    var clearDriverBtn = document.getElementById('clearDriverSearch');
    if (driverInput) {
        function filterDrivers() {
            var q = driverInput.value.trim().toLowerCase();
            if (clearDriverBtn) {
                clearDriverBtn.style.display = q.length > 0 ? 'block' : 'none';
            }
            var rows = document.querySelectorAll('#driverTableBody .driver-row');
            var visible = 0;
            rows.forEach(function(row) {
                var text = (row.getAttribute('data-name') || '') + ' ' + 
                           (row.getAttribute('data-phone') || '') + ' ' + 
                           (row.getAttribute('data-plate') || '') + ' ' +
                           row.textContent.toLowerCase();
                if (!q || text.indexOf(q) !== -1) {
                    row.style.display = '';
                    visible++;
                } else {
                    row.style.display = 'none';
                }
            });
            var noMatch = document.getElementById('noMatchDriverRow');
            if (noMatch) {
                noMatch.style.display = (visible === 0 && rows.length > 0) ? '' : 'none';
            }
            var countEl = document.getElementById('driverVisibleCount');
            if (countEl) countEl.textContent = visible;
        }

        driverInput.addEventListener('input', filterDrivers);
        if (driverInput.value) filterDrivers();

        if (clearDriverBtn) {
            clearDriverBtn.addEventListener('click', function() {
                driverInput.value = '';
                filterDrivers();
                driverInput.focus();
            });
        }
    }

    // 3. Real-time Live Filter for Restaurant Table
    var restInput = document.getElementById('restaurantSearchInput');
    var clearRestBtn = document.getElementById('clearRestSearch');
    if (restInput) {
        function filterRestaurants() {
            var q = restInput.value.trim().toLowerCase();
            if (clearRestBtn) {
                clearRestBtn.style.display = q.length > 0 ? 'block' : 'none';
            }
            var rows = document.querySelectorAll('#restaurantTableBody .rest-row');
            var visible = 0;
            rows.forEach(function(row) {
                var text = (row.getAttribute('data-name') || '') + ' ' + 
                           (row.getAttribute('data-phone') || '') + ' ' + 
                           (row.getAttribute('data-address') || '') + ' ' +
                           row.textContent.toLowerCase();
                if (!q || text.indexOf(q) !== -1) {
                    row.style.display = '';
                    visible++;
                } else {
                    row.style.display = 'none';
                }
            });
            var noMatch = document.getElementById('noMatchRestRow');
            if (noMatch) {
                noMatch.style.display = (visible === 0 && rows.length > 0) ? '' : 'none';
            }
            var countEl = document.getElementById('restaurantVisibleCount');
            if (countEl) countEl.textContent = visible;
        }

        restInput.addEventListener('input', filterRestaurants);
        if (restInput.value) filterRestaurants();

        if (clearRestBtn) {
            clearRestBtn.addEventListener('click', function() {
                restInput.value = '';
                filterRestaurants();
                restInput.focus();
            });
        }
    }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

