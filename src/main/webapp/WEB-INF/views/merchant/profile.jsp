<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Cài Đặt Quán Ăn - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp">
        <jsp:param name="activeTab" value="profile" />
    </jsp:include>

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

                <form action="${pageContext.request.contextPath}/merchant/profile" method="POST" enctype="multipart/form-data" class="p-3">
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
                        <label class="form-label fw-bold mb-1">Địa chỉ quán ăn <span class="text-danger">*</span></label>
                        
                        <!-- Bộ chọn địa chỉ hành chính Việt Nam cho quán ăn -->
                        <div id="merchantVNAddressPicker"></div>
                        <input type="hidden" id="merchantAddress" name="address" value="<c:out value='${currentRestaurant.address}' />" required />
                    </div>

                    <!-- 1. Ảnh đại diện chủ quán -->
                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">
                            <i class="fa-solid fa-user-tie text-primary me-1"></i> Ảnh đại diện của chủ quán
                        </label>
                        <div class="merchant-upload-card" onclick="document.getElementById('ownerAvatarFileInput').click()">
                            <input type="file" id="ownerAvatarFileInput" name="ownerAvatarFile" accept="image/*" style="display: none;" onchange="previewUploadImage(this, 'ownerAvatarPrevImg')">
                            <div class="merchant-upload-circle-preview" id="ownerAvatarPrev">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.currentUser.avatar}">
                                        <img id="ownerAvatarPrevImg" src="${sessionScope.currentUser.avatar.startsWith('http') || sessionScope.currentUser.avatar.startsWith('/') ? (sessionScope.currentUser.avatar.startsWith('/') ? pageContext.request.contextPath.concat(sessionScope.currentUser.avatar) : sessionScope.currentUser.avatar) : pageContext.request.contextPath.concat('/').concat(sessionScope.currentUser.avatar)}" alt="Avatar chủ quán" />
                                    </c:when>
                                    <c:otherwise>
                                        <img id="ownerAvatarPrevImg" src="" style="display: none;" />
                                        <i class="fa-solid fa-camera"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="merchant-upload-info">
                                <strong>Chọn ảnh đại diện chủ quán</strong>
                                <span>Ảnh được lưu trong hệ thống, hiển thị trên hồ sơ cá nhân và trang quản trị</span>
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary" style="border-radius: 50px; pointer-events: none;">
                                <i class="fa-solid fa-arrow-up-from-bracket me-1"></i> Tải ảnh
                            </button>
                        </div>
                    </div>

                    <!-- 2. Logo thương hiệu quán ăn -->
                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">
                            <i class="fa-solid fa-store text-primary me-1"></i> Logo quán ăn (Hiển thị ở kênh quản lý món)
                        </label>
                        <div class="merchant-upload-card" onclick="document.getElementById('logoFileInput').click()">
                            <input type="file" id="logoFileInput" name="logoFile" accept="image/*" style="display: none;" onchange="previewUploadImage(this, 'logoPrevImg')">
                            <c:set var="curLogo" value="${not empty currentRestaurant.logoUrl ? currentRestaurant.logoUrl : currentRestaurant.imageUrl}" />
                            <div class="merchant-upload-square-preview" id="logoPrev">
                                <c:choose>
                                    <c:when test="${not empty curLogo}">
                                        <img id="logoPrevImg" src="${curLogo.startsWith('http') || curLogo.startsWith('/') ? (curLogo.startsWith('/') ? pageContext.request.contextPath.concat(curLogo) : curLogo) : pageContext.request.contextPath.concat('/').concat(curLogo)}" alt="Logo quán" />
                                    </c:when>
                                    <c:otherwise>
                                        <img id="logoPrevImg" src="" style="display: none;" />
                                        <i class="fa-solid fa-store"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="merchant-upload-info">
                                <strong>Chọn logo quán ăn</strong>
                                <span>Làm đại diện thương hiệu hiển thị trên thanh công cụ và kênh quản lý thực đơn</span>
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary" style="border-radius: 50px; pointer-events: none;">
                                <i class="fa-solid fa-arrow-up-from-bracket me-1"></i> Tải logo
                            </button>
                        </div>
                    </div>

                    <!-- 3. Banner / Bìa quán ăn -->
                    <div class="form-group mb-3">
                        <label class="form-label fw-bold mb-1">
                            <i class="fa-solid fa-image text-primary me-1"></i> Ảnh banner / bìa quán (Hiển thị ở mọi trang)
                        </label>
                        <div class="merchant-upload-card" onclick="document.getElementById('bannerFileInput').click()">
                            <input type="file" id="bannerFileInput" name="bannerFile" accept="image/*" style="display: none;" onchange="previewUploadImage(this, 'bannerPrevImg', 'storeBannerImg')">
                            <div class="merchant-upload-rect-preview" id="bannerPrev">
                                <c:choose>
                                    <c:when test="${not empty currentRestaurant.imageUrl}">
                                        <img id="bannerPrevImg" src="${currentRestaurant.imageUrl.startsWith('http') || currentRestaurant.imageUrl.startsWith('/') ? (currentRestaurant.imageUrl.startsWith('/') ? pageContext.request.contextPath.concat(currentRestaurant.imageUrl) : currentRestaurant.imageUrl) : pageContext.request.contextPath.concat('/').concat(currentRestaurant.imageUrl)}" alt="Banner quán" />
                                    </c:when>
                                    <c:otherwise>
                                        <img id="bannerPrevImg" src="" style="display: none;" />
                                        <i class="fa-regular fa-image"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="merchant-upload-info">
                                <strong>Chọn ảnh banner quán ăn</strong>
                                <span>Banner xuất hiện trên trang chủ, chi tiết quán và đề xuất khách hàng</span>
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary" style="border-radius: 50px; pointer-events: none;">
                                <i class="fa-solid fa-arrow-up-from-bracket me-1"></i> Tải banner
                            </button>
                        </div>
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

<script src="${pageContext.request.contextPath}/assets/js/vn-address-picker.js"></script>
<script>
    function previewUploadImage(input, previewImgId, secondaryImgId) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.getElementById(previewImgId);
                if (img) {
                    img.src = e.target.result;
                    img.style.display = 'block';
                    // Hide any sibling icon
                    const icon = img.parentElement ? img.parentElement.querySelector('i') : null;
                    if (icon) icon.style.display = 'none';
                }
                if (secondaryImgId) {
                    const sec = document.getElementById(secondaryImgId);
                    if (sec) sec.src = e.target.result;
                }
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        if (document.getElementById('merchantVNAddressPicker') && typeof VNAddressPicker !== 'undefined') {
            VNAddressPicker.init({
                container: 'merchantVNAddressPicker',
                targetInput: 'merchantAddress',
                initialAddress: document.getElementById('merchantAddress') ? document.getElementById('merchantAddress').value : '',
                onChange: function(res) {
                    const previewAddr = document.getElementById('previewStoreAddr');
                    if (previewAddr) {
                        previewAddr.textContent = (res && res.fullAddress && res.fullAddress.trim().length > 0) ? res.fullAddress : 'Chưa cập nhật địa chỉ';
                    }
                }
            });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
