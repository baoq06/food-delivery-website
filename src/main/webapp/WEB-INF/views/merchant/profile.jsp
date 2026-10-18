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

                    <!-- 4. Cài đặt Tài Khoản Ngân Hàng Thụ Hưởng (VietQR) -->
                    <div class="card mb-3 p-3 border-0" style="background: #f8fafc; border: 1px solid #e2e8f0 !important; border-radius: 12px;">
                        <div class="d-flex align-items-center justify-content-between mb-2">
                            <div>
                                <h5 class="mb-0 fw-bold" style="font-size: 0.98rem; color: #1e293b;">
                                    <i class="fa-solid fa-building-columns text-primary me-2"></i>Tài Khoản Ngân Hàng Thụ Hưởng (VietQR)
                                </h5>
                                <span class="text-muted" style="font-size: 0.8rem;">
                                    Khi khách chọn thanh toán qua VietQR, mã QR và thông tin này sẽ được sinh động để khách quét trả tiền trực tiếp.
                                </span>
                            </div>
                            <span class="badge bg-success" style="font-size: 0.72rem; padding: 4px 8px; border-radius: 6px;">
                                <i class="fa-solid fa-qrcode me-1"></i> VietQR Auto
                            </span>
                        </div>

                        <div class="row g-2 mt-1">
                            <div class="col-md-5 form-group">
                                <label class="form-label fw-bold mb-1" style="font-size: 0.85rem;">Ngân hàng thụ hưởng <span class="text-danger">*</span></label>
                                <input type="hidden" id="merchantBankName" name="bankName" value="${not empty currentRestaurant.bankName ? currentRestaurant.bankName : 'Techcombank'}" />
                                <select id="merchantBankSelect" name="bankCode" class="form-select form-control" style="border-radius: 8px; font-size: 0.88rem;" onchange="handleBankSelectChange(this)">
                                    <option value="TCB" data-name="Techcombank" ${empty currentRestaurant.bankCode || currentRestaurant.bankCode eq 'TCB' ? 'selected' : ''}>TCB - Techcombank (Kỹ Thương)</option>
                                    <option value="VCB" data-name="Vietcombank" ${currentRestaurant.bankCode eq 'VCB' ? 'selected' : ''}>VCB - Vietcombank (Ngoại Thương)</option>
                                    <option value="MB" data-name="MBBank" ${currentRestaurant.bankCode eq 'MB' ? 'selected' : ''}>MB - MBBank (Quân Đội)</option>
                                    <option value="ICB" data-name="VietinBank" ${currentRestaurant.bankCode eq 'ICB' ? 'selected' : ''}>ICB - VietinBank (Công Thương)</option>
                                    <option value="BIDV" data-name="BIDV" ${currentRestaurant.bankCode eq 'BIDV' ? 'selected' : ''}>BIDV - BIDV (Đầu Tư &amp; Phát Triển)</option>
                                    <option value="ACB" data-name="ACB" ${currentRestaurant.bankCode eq 'ACB' ? 'selected' : ''}>ACB - Á Châu</option>
                                    <option value="TPB" data-name="TPBank" ${currentRestaurant.bankCode eq 'TPB' ? 'selected' : ''}>TPB - TPBank (Tiên Phong)</option>
                                    <option value="VPB" data-name="VPBank" ${currentRestaurant.bankCode eq 'VPB' ? 'selected' : ''}>VPB - VPBank (Việt Nam Thịnh Vượng)</option>
                                    <option value="STB" data-name="Sacombank" ${currentRestaurant.bankCode eq 'STB' ? 'selected' : ''}>STB - Sacombank (Sài Gòn Thương Tín)</option>
                                    <option value="HDB" data-name="HDBank" ${currentRestaurant.bankCode eq 'HDB' ? 'selected' : ''}>HDB - HDBank (Phát Triển TP.HCM)</option>
                                    <option value="VIB" data-name="VIB" ${currentRestaurant.bankCode eq 'VIB' ? 'selected' : ''}>VIB - Quốc Tế (VIB)</option>
                                    <option value="MSB" data-name="MSB" ${currentRestaurant.bankCode eq 'MSB' ? 'selected' : ''}>MSB - Hàng Hải Việt Nam</option>
                                </select>
                            </div>
                            <div class="col-md-7 form-group">
                                <label class="form-label fw-bold mb-1" style="font-size: 0.85rem;">Số tài khoản ngân hàng <span class="text-danger">*</span></label>
                                <input type="text" id="merchantBankAccNo" name="bankAccountNo" 
                                       value="${not empty currentRestaurant.bankAccountNo ? currentRestaurant.bankAccountNo : '1907 2878 4280 15'}" 
                                       required class="form-control" style="border-radius: 8px; font-size: 0.88rem; font-weight: 600; letter-spacing: 0.5px;" 
                                       placeholder="1907 2878 4280 15" oninput="updateMerchantVietQrPreview()" />
                            </div>
                        </div>

                        <div class="row g-2 mt-2">
                            <div class="col-md-7 form-group">
                                <label class="form-label fw-bold mb-1" style="font-size: 0.85rem;">Tên chủ tài khoản (Viết hoa không dấu) <span class="text-danger">*</span></label>
                                <input type="text" id="merchantBankAccName" name="bankAccountName" 
                                       value="${not empty currentRestaurant.bankAccountName ? currentRestaurant.bankAccountName : 'LE HAI DANG'}" 
                                       required class="form-control" style="border-radius: 8px; font-size: 0.88rem; text-transform: uppercase;" 
                                       placeholder="LE HAI DANG" oninput="updateMerchantVietQrPreview()" />
                            </div>
                            <div class="col-md-5 d-flex align-items-end">
                                <button type="button" class="btn btn-outline-secondary w-100" style="border-radius: 8px; font-size: 0.82rem; height: 38px;" onclick="toggleMerchantQrPreviewBox()">
                                    <i class="fa-solid fa-qrcode me-1"></i> <span id="toggleQrPreviewText">Xem mã QR mẫu</span>
                                </button>
                            </div>
                        </div>

                        <!-- Khung xem trước mã VietQR của quán -->
                        <div id="merchantQrPreviewBox" class="mt-3 p-3 text-center bg-white rounded border" style="display: none;">
                            <span class="text-muted d-block mb-2" style="font-size: 0.8rem;">
                                <i class="fa-solid fa-wand-magic-sparkles text-warning me-1"></i> Mã VietQR thực tế khách hàng sẽ thấy (Demo thanh toán 50.000 đ)
                            </span>
                            <img id="merchantPreviewQrImg" src="" alt="VietQR Preview" style="max-width: 190px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.06);" />
                            <div class="mt-2 text-muted" style="font-size: 0.8rem;">
                                Ngân hàng: <strong id="lblPreviewBankName" class="text-dark">Techcombank</strong> | STK: <strong id="lblPreviewAccNo" class="text-danger">1907 2878 4280 15</strong>
                            </div>
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

    function handleBankSelectChange(select) {
        const opt = select.options[select.selectedIndex];
        const bankName = opt ? opt.getAttribute('data-name') : 'Techcombank';
        const hiddenBankName = document.getElementById('merchantBankName');
        if (hiddenBankName) hiddenBankName.value = bankName;
        updateMerchantVietQrPreview();
    }

    function updateMerchantVietQrPreview() {
        const bankSel = document.getElementById('merchantBankSelect');
        const bankCode = bankSel ? bankSel.value : 'TCB';
        const opt = bankSel ? bankSel.options[bankSel.selectedIndex] : null;
        const bankName = opt ? opt.getAttribute('data-name') : 'Techcombank';
        const rawAcc = document.getElementById('merchantBankAccNo') ? document.getElementById('merchantBankAccNo').value.trim() : '1907 2878 4280 15';
        const cleanAcc = rawAcc.replace(/[\s\-\.]/g, '');
        const accName = document.getElementById('merchantBankAccName') ? document.getElementById('merchantBankAccName').value.trim().toUpperCase() : 'LE HAI DANG';

        const lblBank = document.getElementById('lblPreviewBankName');
        const lblAcc = document.getElementById('lblPreviewAccNo');
        if (lblBank) lblBank.textContent = bankName;
        if (lblAcc) lblAcc.textContent = rawAcc;

        const qrImg = document.getElementById('merchantPreviewQrImg');
        if (qrImg && cleanAcc.length > 0) {
            const encodedName = encodeURIComponent(accName);
            qrImg.src = 'https://img.vietqr.io/image/' + bankCode + '-' + cleanAcc + '-compact2.png?amount=50000&addInfo=DEMO&accountName=' + encodedName;
        }
    }

    function toggleMerchantQrPreviewBox() {
        const box = document.getElementById('merchantQrPreviewBox');
        const txt = document.getElementById('toggleQrPreviewText');
        if (!box) return;
        if (box.style.display === 'none' || box.style.display === '') {
            updateMerchantVietQrPreview();
            box.style.display = 'block';
            if (txt) txt.textContent = 'Ẩn mã QR mẫu';
        } else {
            box.style.display = 'none';
            if (txt) txt.textContent = 'Xem mã QR mẫu';
        }
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
