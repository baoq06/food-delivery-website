<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Cài Đặt Quán Ăn - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container section pt-0">
        <div class="merchant-grid-split">
            <!-- Cột Trái: Form chỉnh sửa thông tin quán (admin-table-card) -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-pen-to-square text-primary"></i> Thông Tin Hồ Sơ Nhà Hàng</h3>
                        <span class="table-card-sub">Cập nhật thông tin liên hệ, địa chỉ và giờ mở cửa</span>
                    </div>
                    <!-- Nút Bật/Tắt Mở Cửa Quán -->
                    <form action="${pageContext.request.contextPath}/merchant/profile" method="POST">
                        <input type="hidden" name="action" value="toggleStatus" />
                        <button type="submit" class="btn ${currentRestaurant.status eq 'OPEN' ? 'btn-danger' : 'btn-success'} btn-sm">
                            <i class="fa-solid ${currentRestaurant.status eq 'OPEN' ? 'fa-door-closed' : 'fa-door-open'}"></i>
                            ${currentRestaurant.status eq 'OPEN' ? 'Tạm Đóng Cửa' : 'Mở Cửa Nhận Đơn'}
                        </button>
                    </form>
                </div>

                <form action="${pageContext.request.contextPath}/merchant/profile" method="POST" class="mt-3">
                    <input type="hidden" name="action" value="updateProfile" />

                    <div class="form-group mb-3">
                        <label class="form-label font-weight-bold">Tên nhà hàng / Quán ăn <span class="text-danger">*</span></label>
                        <input type="text" name="name" value="${currentRestaurant.name}" required class="form-control" />
                    </div>

                    <div class="row-fields mb-3">
                        <div class="form-group col-half">
                            <label class="form-label font-weight-bold">Số điện thoại liên hệ</label>
                            <input type="text" name="phone" value="${currentRestaurant.phone}" class="form-control" />
                        </div>
                        <div class="form-group col-half">
                            <label class="form-label font-weight-bold">Trạng thái nhận đơn</label>
                            <input type="text" value="${currentRestaurant.status eq 'OPEN' ? 'ĐANG MỞ CỬA (NHẬN ĐƠN)' : 'TẠM ĐÓNG CỬA'}" disabled class="form-control font-weight-bold" style="background: #f8f9fa; color: ${currentRestaurant.status eq 'OPEN' ? '#2ed573' : '#ff4757'};" />
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label font-weight-bold">Địa chỉ quán ăn</label>
                        <input type="text" name="address" value="${currentRestaurant.address}" class="form-control" />
                    </div>

                    <div class="form-group mb-3">
                        <label class="form-label font-weight-bold">Link ảnh đại diện / Ảnh bìa quán (URL)</label>
                        <input type="url" name="imageUrl" id="profileImageUrl" value="${currentRestaurant.imageUrl}" class="form-control" oninput="previewProfileImage(this.value)" />
                    </div>

                    <div class="form-group mb-4">
                        <label class="form-label font-weight-bold">Mô tả giới thiệu quán</label>
                        <textarea name="description" rows="4" class="form-control">${currentRestaurant.description}</textarea>
                    </div>

                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu Thay Đổi</button>
                </form>
            </div>

            <!-- Cột Phải: Xem trước thẻ quán ăn của khách -->
            <div class="admin-table-card">
                <div class="admin-table-header">
                    <div>
                        <h3 class="table-card-title"><i class="fa-solid fa-eye text-primary"></i> Xem Trước Thẻ Quán</h3>
                        <span class="table-card-sub">Cách khách hàng nhìn thấy quán trên trang chủ</span>
                    </div>
                </div>

                <div class="store-preview-card mt-2">
                    <div class="preview-banner">
                        <img id="storeBannerImg" src="${currentRestaurant.imageUrl}" alt="${currentRestaurant.name}" onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&fit=crop'" />
                        <span class="preview-status ${currentRestaurant.status eq 'OPEN' ? 'status-open' : 'status-closed'}">
                            ${currentRestaurant.status eq 'OPEN' ? 'Đang Mở Cửa' : 'Tạm Đóng Cửa'}
                        </span>
                    </div>
                    <div class="preview-content">
                        <h3 class="preview-name">${currentRestaurant.name}</h3>
                        <p class="preview-desc text-muted">${currentRestaurant.description}</p>
                        <div class="preview-meta">
                            <span><i class="fa-solid fa-location-dot text-primary"></i> ${currentRestaurant.address}</span>
                            <span><i class="fa-solid fa-phone text-success"></i> ${currentRestaurant.phone}</span>
                            <span><i class="fa-solid fa-shield-halved text-warning"></i> Quán đối tác chính thức Utee</span>
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
