<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Cài Đặt Quán Ăn - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
        <div class="merchant-grid-split" style="margin-top: 18px;">
            <!-- Cột Trái: Form chỉnh sửa thông tin quán (admin-table-card) -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-store text-primary"></i> Thông Tin Hồ Sơ Nhà Hàng</h3>
                        <span class="table-card-sub">Cập nhật thông tin liên hệ, địa chỉ và giờ mở cửa</span>
                    </div>
                    <!-- Nút Bật/Tắt Mở Cửa Quán -->
                    <form action="${pageContext.request.contextPath}/merchant/profile" method="POST">
                        <input type="hidden" name="action" value="toggleStatus" />
                        <button type="submit" class="btn ${currentRestaurant.status eq 'OPEN' ? 'btn-outline-danger' : 'btn-success'} btn-sm d-inline-flex align-items-center gap-1" style="border-radius: 20px; padding: 6px 14px;">
                            <i class="fa-solid ${currentRestaurant.status eq 'OPEN' ? 'fa-door-closed' : 'fa-door-open'}"></i>
                            <span>${currentRestaurant.status eq 'OPEN' ? 'Tạm Đóng Quán' : 'Mở Cửa Nhận Đơn'}</span>
                        </button>
                    </form>
                </div>

                <form action="${pageContext.request.contextPath}/merchant/profile" method="POST" class="p-3">
                    <input type="hidden" name="action" value="updateProfile" />

                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">Tên nhà hàng / Quán ăn <span class="text-danger">*</span></label>
                        <input type="text" name="name" value="${currentRestaurant.name}" required class="form-control" style="border-radius: 10px;" />
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6 form-group">
                            <label class="form-label fw-bold mb-1">Số điện thoại liên hệ</label>
                            <input type="text" name="phone" value="${currentRestaurant.phone}" class="form-control" style="border-radius: 10px;" />
                        </div>
                        <div class="col-md-6 form-group">
                            <label class="form-label fw-bold mb-1">Trạng thái nhận đơn</label>
                            <div class="p-2 rounded-2 d-flex align-items-center gap-2" style="background: var(--surface-light); border: 1px solid var(--border-color); height: 44px;">
                                <span class="merchant-status-dot ${currentRestaurant.status eq 'OPEN' ? 'status-open' : 'status-closed'}"></span>
                                <span class="fw-bold" style="font-size: 0.88rem; color: ${currentRestaurant.status eq 'OPEN' ? '#00b894' : '#ff4757'};">
                                    ${currentRestaurant.status eq 'OPEN' ? 'ĐANG MỞ CỬA (NHẬN ĐƠN)' : 'TẠM ĐÓNG CỬA'}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">Địa chỉ quán ăn</label>
                        <input type="text" name="address" value="${currentRestaurant.address}" class="form-control" style="border-radius: 10px;" />
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">Link ảnh đại diện / Bìa quán (URL)</label>
                        <input type="url" name="imageUrl" id="profileImageUrl" value="${currentRestaurant.imageUrl}" class="form-control" oninput="previewProfileImage(this.value)" style="border-radius: 10px;" />
                    </div>

                    <div class="form-group mb-4">
                        <label class="form-label fw-bold mb-1">Mô tả giới thiệu quán</label>
                        <textarea name="description" rows="4" class="form-control" style="border-radius: 10px;" placeholder="Giới thiệu về thực đơn, phong cách ẩm thực, cam kết vệ sinh...">${currentRestaurant.description}</textarea>
                    </div>

                    <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-2" style="border-radius: 10px; padding: 10px 22px;">
                        <i class="fa-solid fa-floppy-disk"></i> <span>Lưu Thay Đổi Hồ Sơ</span>
                    </button>
                </form>
            </div>

            <!-- Cột Phải: Xem trước thẻ quán ăn của khách -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-eye text-primary"></i> Xem Trước Thẻ Quán</h3>
                        <span class="table-card-sub">Cách khách hàng nhìn thấy quán trên ứng dụng</span>
                    </div>
                </div>

                <div class="p-3">
                    <div class="store-preview-card">
                        <div class="preview-banner">
                            <img id="storeBannerImg" src="${currentRestaurant.imageUrl}" alt="${currentRestaurant.name}" onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&fit=crop'" />
                            <span class="preview-status ${currentRestaurant.status eq 'OPEN' ? 'badge-done' : 'badge-cod'}" style="position: absolute; top: 12px; right: 12px;">
                                <i class="fa-solid ${currentRestaurant.status eq 'OPEN' ? 'fa-door-open' : 'fa-door-closed'} me-1"></i>
                                ${currentRestaurant.status eq 'OPEN' ? 'Đang Mở Cửa' : 'Tạm Đóng Cửa'}
                            </span>
                        </div>
                        <div class="preview-content">
                            <h3 class="preview-name" id="previewStoreName">${currentRestaurant.name}</h3>
                            <p class="preview-desc text-muted" id="previewStoreDesc">${empty currentRestaurant.description ? 'Chưa có mô tả giới thiệu quán ăn.' : currentRestaurant.description}</p>
                            <div class="preview-meta">
                                <span class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-location-dot text-danger" style="width: 16px;"></i>
                                    <span id="previewStoreAddr">${empty currentRestaurant.address ? 'Chưa cập nhật địa chỉ' : currentRestaurant.address}</span>
                                </span>
                                <span class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-phone text-success" style="width: 16px;"></i>
                                    <span id="previewStorePhone">${empty currentRestaurant.phone ? 'Chưa cập nhật số điện thoại' : currentRestaurant.phone}</span>
                                </span>
                                <span class="d-flex align-items-center gap-2 text-primary fw-medium">
                                    <i class="fa-solid fa-shield-halved" style="width: 16px;"></i> Quán đối tác chính thức Utee
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function previewProfileImage(url) {
        const img = document.getElementById('storeBannerImg');
        if (url && url.trim().length > 5) {
            img.src = url.trim();
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
