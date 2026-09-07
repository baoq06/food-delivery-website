<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Danh Sách Tài Xế Shipper - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container section pt-0">
        <!-- Toolbar Bộ Lọc Shipper -->
        <div class="admin-header-box mb-4 py-3">
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <span class="text-muted font-weight-bold" style="font-size: 0.9rem;">Lọc trạng thái:</span>
                <a href="${pageContext.request.contextPath}/merchant/shippers?status=ALL" class="btn btn-sm ${selectedStatus eq 'ALL' ? 'btn-primary' : 'btn-outline'}">
                    Tất cả (${availableCount + busyCount + offlineCount})
                </a>
                <a href="${pageContext.request.contextPath}/merchant/shippers?status=AVAILABLE" class="btn btn-sm ${selectedStatus eq 'AVAILABLE' ? 'btn-primary' : 'btn-outline'}">
                    <span class="dot-pulse"></span> Sẵn sàng nhận đơn (${availableCount})
                </a>
                <a href="${pageContext.request.contextPath}/merchant/shippers?status=BUSY" class="btn btn-sm ${selectedStatus eq 'BUSY' ? 'btn-primary' : 'btn-outline'}">
                    <i class="fa-solid fa-road"></i> Đang giao hàng (${busyCount})
                </a>
                <a href="${pageContext.request.contextPath}/merchant/shippers?status=OFFLINE" class="btn btn-sm ${selectedStatus eq 'OFFLINE' ? 'btn-primary' : 'btn-outline'}">
                    <i class="fa-solid fa-moon"></i> Ngoại tuyến (${offlineCount})
                </a>
            </div>

            <div class="d-flex align-items-center gap-2">
                <span class="badge badge-done" style="font-size: 0.88rem; padding: 6px 14px;">
                    <i class="fa-solid fa-motorcycle"></i> ${availableCount} tài xế sẵn sàng nhận đơn
                </span>
                <span class="badge bg-light text-dark border" style="font-size: 0.88rem; padding: 6px 14px;">
                    <i class="fa-solid fa-receipt text-success"></i> Đã trả shipper: <strong class="text-success"><fmt:formatNumber value="${totalPaidFees}" type="number" /> đ</strong>
                </span>
            </div>
        </div>

        <!-- Bảng Danh Sách Tài Xế Shipper (admin-table-card) -->
        <div class="admin-table-card">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-motorcycle text-primary"></i> Đội Ngũ Tài Xế Giao Vận Khả Dụng</h3>
                    <span class="table-card-sub">Theo dõi danh sách tài xế trực tuyến, điều phối đơn hàng và thanh toán phí giao hàng</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th>Mã Tài Xế</th>
                            <th>Họ &amp; Tên</th>
                            <th>Số Điện Thoại</th>
                            <th>Khu Vực Hoạt Động</th>
                            <th>Trạng Thái</th>
                            <th>Đánh Giá</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty drivers}">
                                <c:forEach var="driver" items="${drivers}">
                                    <tr>
                                        <td><strong>#TX-${driver.id}</strong></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div style="width: 36px; height: 36px; border-radius: 8px; background: #ffebee; color: #ff4757; display: flex; align-items: center; justify-content: center; font-size: 1rem;">
                                                    <i class="fa-solid fa-helmet-safety"></i>
                                                </div>
                                                <strong style="font-size: 0.95rem;">${driver.name}</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <span>${driver.phone}</span>
                                                <a href="tel:${driver.phone}" class="btn btn-sm btn-outline text-success border-success" style="padding: 2px 8px; border-radius: 20px;" title="Gọi điện">
                                                    <i class="fa-solid fa-phone"></i> Gọi
                                                </a>
                                            </div>
                                        </td>
                                        <td>TP. Hồ Chí Minh (Q.1, Q.3, Bình Thạnh)</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${driver.status eq 'AVAILABLE'}">
                                                    <span class="badge badge-done"><span class="dot-pulse"></span> Sẵn Sàng</span>
                                                </c:when>
                                                <c:when test="${driver.status eq 'BUSY'}">
                                                    <span class="badge badge-shipping"><i class="fa-solid fa-clock"></i> Đang Bận Giao</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-cod"><i class="fa-solid fa-moon"></i> Nghỉ</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="text-warning font-weight-bold">
                                                <i class="fa-solid fa-star"></i> 4.9
                                            </span>
                                            <small class="text-muted">(120+ đơn)</small>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2">
                                                <c:if test="${driver.status eq 'AVAILABLE'}">
                                                    <c:choose>
                                                        <c:when test="${not empty unassignedOrders}">
                                                            <button type="button" class="btn btn-primary btn-sm" onclick="openDispatchModal(${driver.id}, '${driver.name}')">
                                                                <i class="fa-solid fa-paper-plane"></i> Giao Đơn
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;"><i class="fa-solid fa-check text-success"></i> Hết đơn chờ</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                                <button type="button" class="btn btn-outline-success btn-sm" onclick="openPayModal(${driver.id}, '${driver.name}')">
                                                    <i class="fa-solid fa-money-bill-wave"></i> Trả Phí
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.2rem; margin-bottom: 8px;">🛵</div>
                                        <strong style="color: #666;">Hiện tại chưa có tài xế nào trực tuyến trong hệ thống!</strong>
                                        <p class="small text-muted mb-0 mt-1">Danh sách tài xế sẽ tự động cập nhật ngay khi shipper đăng nhập và bật trạng thái nhận đơn.</p>
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

<!-- Modal Điều Phối Đơn Hàng Cho Tài Xế -->
<div id="dispatchModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="modal-header">
            <h3><i class="fa-solid fa-paper-plane text-primary"></i> Điều Phối Đơn Cho Tài Xế</h3>
            <button type="button" class="modal-close-btn" onclick="closeDispatchModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/shippers" method="POST">
            <input type="hidden" name="action" value="assign" />
            <input type="hidden" name="driverId" id="dispatchDriverId" value="" />

            <div class="modal-body">
                <p>Bạn đang gán đơn hàng cho tài xế: <strong id="dispatchDriverName" class="text-primary fs-5"></strong></p>

                <div class="form-group mt-3">
                    <label class="form-label font-weight-bold">Chọn đơn hàng chờ giao của quán:</label>
                    <select name="orderId" class="form-select" required>
                        <c:forEach var="ord" items="${unassignedOrders}">
                            <option value="${ord.id}">
                                #DH-${ord.id} - ${ord.customerName} (${ord.phone}) - <fmt:formatNumber value="${ord.totalAmount}" type="number" /> đ
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="alert alert-info mt-3 p-2" style="font-size: 0.9rem;">
                    <i class="fa-solid fa-circle-info"></i> Sau khi gán, tài xế sẽ chuyển sang trạng thái <strong>ĐANG BẬN</strong> và đơn hàng chuyển sang <strong>ĐANG GIAO</strong>.
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeDispatchModal()">Đóng</button>
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Xác Nhận Giao Đơn</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Trả Phí Cho Tài Xế Shipper -->
<div id="payModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="modal-header">
            <h3><i class="fa-solid fa-money-bill-wave text-success"></i> Trả Phí Giao Vận Cho Shipper</h3>
            <button type="button" class="modal-close-btn" onclick="closePayModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/shippers" method="POST">
            <input type="hidden" name="action" value="payShipper" />
            <input type="hidden" name="driverId" id="payDriverId" value="" />

            <div class="modal-body">
                <p>Thanh toán chi phí vận chuyển cho tài xế: <strong id="payDriverName" class="text-primary fs-5"></strong></p>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Số tiền thanh toán (VNĐ): <span class="text-danger">*</span></label>
                    <input type="number" name="amount" class="form-control" value="25000" min="1000" step="1000" required />
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Hình thức thanh toán:</label>
                    <select name="paymentMethod" class="form-select">
                        <option value="CASH">Tiền mặt trực tiếp (Cash)</option>
                        <option value="BANK_TRANSFER">Chuyển khoản nhanh VietQR</option>
                    </select>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Gắn với đơn hàng (tùy chọn):</label>
                    <select name="orderId" class="form-select">
                        <option value="">-- Không gắn cụ thể (Thanh toán chung) --</option>
                        <c:forEach var="ord" items="${unassignedOrders}">
                            <option value="${ord.id}">Đơn #${ord.id} - ${ord.customerName} (<fmt:formatNumber value="${ord.totalAmount}" type="number" /> đ)</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Ghi chú giao dịch:</label>
                    <input type="text" name="note" class="form-control" placeholder="VD: Trả phí giao hàng theo cuốc, phụ phí giờ cao điểm..." />
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closePayModal()">Đóng</button>
                <button type="submit" class="btn btn-success"><i class="fa-solid fa-paper-plane"></i> Hoàn Tất Thanh Toán</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openDispatchModal(driverId, driverName) {
        document.getElementById('dispatchDriverId').value = driverId;
        document.getElementById('dispatchDriverName').innerText = driverName;
        document.getElementById('dispatchModal').style.display = 'flex';
    }

    function closeDispatchModal() {
        document.getElementById('dispatchModal').style.display = 'none';
    }

    function openPayModal(driverId, driverName) {
        document.getElementById('payDriverId').value = driverId;
        document.getElementById('payDriverName').innerText = driverName;
        document.getElementById('payModal').style.display = 'flex';
    }

    function closePayModal() {
        document.getElementById('payModal').style.display = 'none';
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
