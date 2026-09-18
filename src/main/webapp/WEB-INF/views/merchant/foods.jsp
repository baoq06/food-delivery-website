<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Thực Đơn Món Ăn - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container pb-5">
        <!-- Toolbar Tìm Kiếm, Lọc Danh Mục & Nút Đăng Món Mới -->
        <div class="merchant-food-toolbar">
            <form action="${pageContext.request.contextPath}/merchant/foods" method="GET" class="merchant-food-search-form">
                <div class="merchant-search-input-wrap">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo tên món hoặc mô tả món ăn..." />
                </div>
                <div class="merchant-category-select-wrap">
                    <select name="categoryId" onchange="this.form.submit()">
                        <option value="ALL">-- Tất cả danh mục --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${selectedCategoryId == cat.id ? 'selected' : ''}>${cat.imageIcon} ${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="merchant-filter-submit-btn">
                    <i class="fa-solid fa-filter"></i> <span>Lọc Món</span>
                </button>
                <c:if test="${not empty keyword || not empty selectedCategoryId}">
                    <a href="${pageContext.request.contextPath}/merchant/foods" class="merchant-filter-clear-btn" title="Xóa bộ lọc tìm kiếm">
                        <i class="fa-solid fa-xmark"></i> <span>Xóa lọc</span>
                    </a>
                </c:if>
            </form>
            <div style="display: flex; gap: 10px; align-items: center;">
                <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline" style="border-radius: 10px; font-weight: 700; font-size: 0.88rem; padding: 8px 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 7px;" title="Xem toàn bộ thực đơn trên hệ thống Utee">
                    <i class="fa-solid fa-utensils"></i> <span>Xem Thực Đơn Chung</span>
                </a>
                <button type="button" class="merchant-add-food-btn" onclick="openAddFoodModal()">
                    <i class="fa-solid fa-plus"></i> <span>Đăng Món Mới</span>
                </button>
            </div>
        </div>

        <!-- Bảng Món Ăn (admin-table-card) -->
        <div class="admin-table-card">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-bowl-food text-primary"></i> Danh Sách Món Ăn Của Quán</h3>
                    <span class="table-card-sub">Tổng cộng có <strong>${empty foods ? 0 : foods.size()}</strong> món ăn trong thực đơn của quán</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th style="width: 80px;">Hình Ảnh</th>
                            <th>Tên Món Ăn &amp; Mô Tả</th>
                            <th style="width: 170px;">Danh Mục</th>
                            <th style="width: 140px;">Giá Bán</th>
                            <th style="width: 140px;">Trạng Thái</th>
                            <th class="text-end" style="width: 130px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty foods}">
                                <c:forEach var="food" items="${foods}">
                                    <tr>
                                        <td>
                                            <img src="${food.imageUrl}" alt="${food.name}" style="width: 56px; height: 56px; object-fit: cover; border-radius: 12px; border: 1px solid #f1f5f9; box-shadow: 0 2px 6px rgba(0,0,0,0.06);" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&fit=crop'" />
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark" style="font-size: 0.98rem;">${food.name}</div>
                                            <small class="text-muted mt-1" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; max-width: 360px; line-height: 1.35;">
                                                ${empty food.description ? 'Chưa có mô tả chi tiết' : food.description}
                                            </small>
                                        </td>
                                        <td>
                                            <span class="badge badge-cod" style="font-size: 0.8rem;">
                                                <i class="fa-solid fa-tag me-1 text-muted"></i> ${food.categoryName}
                                            </span>
                                        </td>
                                        <td>
                                            <span class="fw-bold text-primary" style="font-size: 1.05rem;">
                                                <fmt:formatNumber value="${food.price}" type="number" /> đ
                                            </span>
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="toggle" />
                                                <input type="hidden" name="foodId" value="${food.id}" />
                                                <input type="hidden" name="status" value="${!food.available}" />
                                                <button type="submit" class="btn btn-sm ${food.available ? 'btn-outline border-success text-success' : 'btn-outline border-secondary text-muted'}" style="border-radius: 20px; font-weight: 600; padding: 4px 12px; font-size: 0.8rem;" title="Bấm để chuyển trạng thái còn món / hết món">
                                                    <i class="fa-solid ${food.available ? 'fa-circle-check text-success' : 'fa-circle-xmark text-danger'} me-1"></i>
                                                    ${food.available ? 'Đang Bán' : 'Tạm Hết'}
                                                </button>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2 align-items-center">
                                                <button type="button" class="btn btn-outline-primary btn-sm" style="border-radius: 8px;"
                                                        onclick="openEditFoodModal(${food.id}, '${food.name}', ${food.price}, ${food.categoryId}, '${food.imageUrl}', '${food.description}', ${food.available})"
                                                        title="Chỉnh sửa món">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </button>
                                                <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa món này khỏi thực đơn?');">
                                                    <input type="hidden" name="action" value="delete" />
                                                    <input type="hidden" name="foodId" value="${food.id}" />
                                                    <button type="submit" class="btn btn-outline-danger btn-sm" style="border-radius: 8px;" title="Xóa món ăn">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <div style="font-size: 2.5rem; margin-bottom: 12px; color: #bdc3c7;">
                                            <i class="fa-solid fa-utensils"></i>
                                        </div>
                                        <c:choose>
                                            <c:when test="${not empty keyword || not empty selectedCategoryId}">
                                                <div class="fw-bold fs-6 text-dark mb-1">Không tìm thấy món ăn nào phù hợp với bộ lọc!</div>
                                                <p class="text-muted small">Thử thay đổi từ khóa tìm kiếm hoặc chọn danh mục khác.</p>
                                                <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-outline btn-sm mt-2">Xóa bộ lọc</a>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="fw-bold fs-6 text-dark mb-1">Thực đơn của quán hiện đang trống</div>
                                                <p class="text-muted small">Hãy thêm các món ăn thơm ngon đầu tiên của quán để bắt đầu phục vụ thực khách.</p>
                                                <button class="btn btn-primary btn-sm mt-2" onclick="openAddFoodModal()">
                                                    <i class="fa-solid fa-plus"></i> Đăng Món Đầu Tiên
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
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

<!-- Modal Thêm / Chỉnh Sửa Món Ăn (Thiết Kế Mới Chuẩn UI/UX Pro Max) -->
<div id="foodModal" class="merchant-food-modal-backdrop" style="display: none;" onclick="if(event.target === this) closeFoodModal();">
    <div class="merchant-food-modal-container">
        <!-- Modal Header -->
        <div class="merchant-food-modal-header">
            <div class="mf-header-brand">
                <div class="mf-header-icon" id="modalHeaderIcon">
                    <i class="fa-solid fa-bowl-food"></i>
                </div>
                <div>
                    <h3 class="mf-header-title" id="modalTitle">Đăng Món Ăn Mới</h3>
                    <p class="mf-header-subtitle" id="modalSubtitle">Thêm món ngon vào thực đơn quán để khách hàng bắt đầu đặt món ngay</p>
                </div>
            </div>
            <button type="button" class="mf-close-btn" onclick="closeFoodModal()" title="Đóng cửa sổ (Esc)">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- Form Đăng / Sửa Món -->
        <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" enctype="multipart/form-data" id="foodForm" onsubmit="return handleFormSubmit();">
            <input type="hidden" name="action" id="formAction" value="add" />
            <input type="hidden" name="foodId" id="foodId" value="" />

            <div class="merchant-food-modal-body">
                <div class="mf-modal-grid">
                    <!-- CỘT TRÁI: THÔNG TIN CHI TIẾT MÓN ĂN -->
                    <div class="mf-grid-left">
                        <!-- Tên món ăn -->
                        <div class="mf-field-group">
                            <label class="mf-field-label" for="foodName">
                                <span>Tên món ăn <span class="required">*</span></span>
                                <span class="mf-field-hint" id="foodNameCount">0/60</span>
                            </label>
                            <div class="mf-input-wrapper">
                                <i class="fa-solid fa-utensils mf-input-icon"></i>
                                <input type="text" name="name" id="foodName" required maxlength="60"
                                       placeholder="Ví dụ: Cơm sườn bì chả đặc biệt, Trà đào cam sả..." 
                                       class="mf-control" oninput="handleNameInput(this.value)" />
                            </div>
                        </div>

                        <!-- 2 Cột: Giá bán & Danh mục -->
                        <div class="row g-3 mb-3">
                            <!-- Giá bán -->
                            <div class="col-md-6">
                                <label class="mf-field-label" for="foodPrice">
                                    <span>Giá bán (VNĐ) <span class="required">*</span></span>
                                </label>
                                <div class="mf-input-wrapper">
                                    <i class="fa-solid fa-coins mf-input-icon"></i>
                                    <input type="number" name="price" id="foodPrice" required min="1000" step="1000" 
                                           placeholder="Ví dụ: 55000" class="mf-control" 
                                           oninput="handlePriceInput(this.value)" />
                                </div>
                                <div id="priceFormattedBadge" class="mf-price-preview-badge" style="display: none;">
                                    <i class="fa-solid fa-tag"></i> <span id="priceFormattedText">0 đ</span>
                                </div>
                                <!-- Quick chips -->
                                <div class="mf-price-chips">
                                    <button type="button" class="mf-chip" onclick="setQuickPrice(35000)">35k</button>
                                    <button type="button" class="mf-chip" onclick="setQuickPrice(45000)">45k</button>
                                    <button type="button" class="mf-chip" onclick="setQuickPrice(55000)">55k</button>
                                    <button type="button" class="mf-chip" onclick="adjustPrice(5000)">+5k</button>
                                    <button type="button" class="mf-chip" onclick="adjustPrice(10000)">+10k</button>
                                </div>
                            </div>

                            <!-- Danh mục -->
                            <div class="col-md-6">
                                <label class="mf-field-label" for="foodCategoryId">
                                    <span>Danh mục món <span class="required">*</span></span>
                                </label>
                                <div class="mf-input-wrapper">
                                    <i class="fa-solid fa-layer-group mf-input-icon"></i>
                                    <select name="categoryId" id="foodCategoryId" class="mf-control form-select" required onchange="handleCategoryChange(this)">
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}" data-icon="${cat.imageIcon}" data-name="${cat.name}">
                                                ${cat.imageIcon} ${cat.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Mô tả món ăn -->
                        <div class="mf-field-group">
                            <label class="mf-field-label" for="foodDescription">
                                <span>Mô tả & Thành phần món</span>
                                <span class="mf-field-hint" id="foodDescCount">0/200</span>
                            </label>
                            <div class="mf-input-wrapper">
                                <i class="fa-solid fa-feather-pointed mf-input-icon" style="top: 14px;"></i>
                                <textarea name="description" id="foodDescription" rows="3" maxlength="200"
                                          placeholder="Hương vị đặc trưng, nguyên liệu tươi ngon, khẩu phần hoặc hướng dẫn dùng kèm..." 
                                          class="mf-control mf-textarea" oninput="handleDescInput(this.value)"></textarea>
                            </div>
                        </div>

                        <!-- Trạng thái mở bán (Interactive Card Switch) -->
                        <div class="mf-field-group mb-0">
                            <label class="mf-field-label">Trạng thái kinh doanh</label>
                            <div class="mf-switch-card is-active" id="availabilityCard" onclick="toggleAvailability()">
                                <div class="mf-switch-info">
                                    <div class="mf-switch-icon-box" id="switchIconBox">
                                        <i class="fa-solid fa-circle-check"></i>
                                    </div>
                                    <div>
                                        <div class="mf-switch-title" id="switchTitle">Mở bán ngay lập tức</div>
                                        <div class="mf-switch-sub" id="switchSubtitle">Khách hàng có thể tìm thấy và đặt món này trên ứng dụng</div>
                                    </div>
                                </div>
                                <div class="mf-toggle"></div>
                                <input type="checkbox" name="isAvailable" id="foodIsAvailable" value="true" checked style="display: none;" />
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: HÌNH ẢNH & LIVE PREVIEW TRÊN APP -->
                    <div class="mf-grid-right">
                        <!-- Quản lý ảnh -->
                        <div class="mf-field-group mb-2">
                            <label class="mf-field-label">
                                <span>Hình ảnh món ăn <span class="required">*</span></span>
                                <span class="mf-field-hint">Ảnh đẹp tăng 65% lượt gọi món</span>
                            </label>

                            <!-- Tab chọn nguồn ảnh -->
                            <div class="mf-image-tabs">
                                <button type="button" class="mf-image-tab-btn active" id="tabUploadBtn" onclick="switchImageTab('upload')">
                                    <i class="fa-solid fa-cloud-arrow-up"></i> Tải ảnh từ máy
                                </button>
                                <button type="button" class="mf-image-tab-btn" id="tabUrlBtn" onclick="switchImageTab('url')">
                                    <i class="fa-solid fa-link"></i> Nhập link URL
                                </button>
                            </div>

                            <!-- Tab 1: Upload Drag & Drop Zone -->
                            <div id="imageUploadPane" class="mf-dropzone" onclick="document.getElementById('foodImageFile').click()" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleFileDrop(event)">
                                <input type="file" name="imageFile" id="foodImageFile" accept="image/*" style="display: none;" onchange="handleFileSelect(event)" />
                                <div class="mf-dropzone-icon">
                                    <i class="fa-solid fa-camera"></i>
                                </div>
                                <div class="mf-dropzone-text" id="dropzoneText">Kéo thả ảnh hoặc bấm để chọn file</div>
                                <div class="mf-dropzone-sub">Hỗ trợ JPG, PNG, WEBP (tối đa 10MB)</div>
                            </div>

                            <!-- Tab 2: URL Input -->
                            <div id="imageUrlPane" style="display: none;">
                                <div class="mf-input-wrapper">
                                    <i class="fa-solid fa-image mf-input-icon"></i>
                                    <input type="url" name="imageUrl" id="foodImageUrl" placeholder="https://images.unsplash.com/..." 
                                           class="mf-control" oninput="handleUrlInput(this.value)" />
                                </div>
                            </div>

                            <!-- Gợi ý ảnh đẹp có sẵn (Presets) -->
                            <div class="mf-preset-box">
                                <div class="mf-preset-title">
                                    <i class="fa-solid fa-wand-magic-sparkles text-warning"></i> Hoặc chọn nhanh ảnh mẫu chất lượng cao:
                                </div>
                                <div class="mf-preset-grid">
                                    <div class="mf-preset-item" onclick="applyPreset('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80')">
                                        <img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=160&auto=format&fit=crop&q=60" alt="Cơm" />
                                        <span>Cơm/Món mặn</span>
                                    </div>
                                    <div class="mf-preset-item" onclick="applyPreset('https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=700&auto=format&fit=crop&q=80')">
                                        <img src="https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=160&auto=format&fit=crop&q=60" alt="Phở" />
                                        <span>Phở / Bún</span>
                                    </div>
                                    <div class="mf-preset-item" onclick="applyPreset('https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=700&auto=format&fit=crop&q=80')">
                                        <img src="https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=160&auto=format&fit=crop&q=60" alt="Đồ uống" />
                                        <span>Đồ uống</span>
                                    </div>
                                    <div class="mf-preset-item" onclick="applyPreset('https://images.unsplash.com/photo-1509722747041-616f39b57569?w=700&auto=format&fit=crop&q=80')">
                                        <img src="https://images.unsplash.com/photo-1509722747041-616f39b57569?w=160&auto=format&fit=crop&q=60" alt="Bánh ngọt" />
                                        <span>Ăn vặt</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- LIVE MENU CARD PREVIEW (MÔ PHỎNG THỰC TẾ TRÊN APP KHÁCH HÀNG) -->
                        <div class="mf-preview-container">
                            <div class="mf-preview-header">
                                <span class="mf-preview-tag">
                                    <i class="fa-solid fa-mobile-screen-button"></i> Xem trước hiển thị trên App
                                </span>
                                <small class="text-muted" style="font-size: 0.72rem;">Thời gian thực</small>
                            </div>

                            <div class="mf-live-card">
                                <div class="mf-live-card-img-wrap">
                                    <img id="liveCardImg" src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80" alt="Ảnh món ăn" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80';" />
                                    <span class="mf-live-card-cat-badge" id="liveCardCategory">🍛 Cơm & Món Mặn</span>
                                    <span class="mf-live-card-status-badge bg-success text-white" id="liveCardStatus">
                                        <i class="fa-solid fa-check me-1"></i> Đang bán
                                    </span>
                                </div>
                                <div class="mf-live-card-body">
                                    <h4 class="mf-live-card-name" id="liveCardName">Tên món ăn của bạn</h4>
                                    <p class="mf-live-card-desc" id="liveCardDesc">Mô tả món ăn thơm ngon, tươi mới, chuẩn vị truyền thống...</p>
                                    <div class="mf-live-card-footer">
                                        <div class="mf-live-card-price" id="liveCardPrice">55.000 đ</div>
                                        <div class="mf-live-card-btn" title="Thêm vào giỏ">
                                            <i class="fa-solid fa-plus"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal Footer -->
            <div class="merchant-food-modal-footer">
                <div class="mf-footer-hint">
                    <i class="fa-solid fa-shield-halved text-success"></i>
                    <span>Món ăn sau khi lưu sẽ đồng bộ ngay lập tức trên hệ thống Utee</span>
                </div>
                <div class="mf-footer-actions">
                    <button type="button" class="mf-btn-cancel" onclick="closeFoodModal()">Hủy bỏ</button>
                    <button type="submit" class="mf-btn-submit" id="btnSubmitForm">
                        <i class="fa-solid fa-plus"></i> <span>Đăng Món Mới</span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    const DEFAULT_FOOD_IMG = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=700&auto=format&fit=crop&q=80";

    function openAddFoodModal() {
        document.getElementById('modalTitle').innerHTML = 'Đăng Món Ăn Mới';
        document.getElementById('modalSubtitle').innerText = 'Thêm món ngon vào thực đơn quán để khách hàng bắt đầu đặt món ngay';
        document.getElementById('modalHeaderIcon').innerHTML = '<i class="fa-solid fa-plus text-primary"></i>';
        document.getElementById('formAction').value = 'add';
        document.getElementById('foodId').value = '';
        document.getElementById('foodName').value = '';
        document.getElementById('foodPrice').value = '';
        document.getElementById('foodImageUrl').value = '';
        document.getElementById('foodDescription').value = '';
        document.getElementById('foodImageFile').value = '';
        
        // Availability reset
        setAvailability(true);

        // Preview reset
        document.getElementById('foodNameCount').innerText = '0/60';
        document.getElementById('foodDescCount').innerText = '0/200';
        document.getElementById('priceFormattedBadge').style.display = 'none';
        document.getElementById('dropzoneText').innerText = 'Kéo thả ảnh hoặc bấm để chọn file';
        
        document.getElementById('liveCardImg').src = DEFAULT_FOOD_IMG;
        document.getElementById('liveCardName').innerText = 'Tên món ăn của bạn';
        document.getElementById('liveCardDesc').innerText = 'Mô tả món ăn thơm ngon, tươi mới, chuẩn vị truyền thống...';
        document.getElementById('liveCardPrice').innerText = '0 đ';

        // Update category preview from first select option
        const catSelect = document.getElementById('foodCategoryId');
        if (catSelect && catSelect.options.length > 0) {
            const opt = catSelect.options[catSelect.selectedIndex || 0];
            document.getElementById('liveCardCategory').innerText = opt.text;
        }

        switchImageTab('upload');
        document.getElementById('btnSubmitForm').innerHTML = '<i class="fa-solid fa-plus"></i> <span>Đăng Món Mới</span>';
        
        const modal = document.getElementById('foodModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('active'), 10);
        document.getElementById('foodName').focus();
    }

    function openEditFoodModal(id, name, price, categoryId, imageUrl, desc, isAvailable) {
        document.getElementById('modalTitle').innerHTML = 'Chỉnh Sửa Món Ăn';
        document.getElementById('modalSubtitle').innerText = 'Cập nhật thông tin, giá bán và hình ảnh cho món #' + id;
        document.getElementById('modalHeaderIcon').innerHTML = '<i class="fa-solid fa-pen-to-square text-primary"></i>';
        document.getElementById('formAction').value = 'update';
        document.getElementById('foodId').value = id;
        document.getElementById('foodName').value = name || '';
        document.getElementById('foodPrice').value = price || '';
        document.getElementById('foodCategoryId').value = categoryId;
        document.getElementById('foodImageUrl').value = imageUrl || '';
        document.getElementById('foodDescription').value = desc || '';
        document.getElementById('foodImageFile').value = '';
        
        // Availability
        setAvailability(isAvailable !== false && isAvailable !== 'false');

        // Counters & Badges
        handleNameInput(name || '');
        handlePriceInput(price || '');
        handleDescInput(desc || '');

        if (imageUrl && imageUrl.trim().length > 5) {
            document.getElementById('liveCardImg').src = imageUrl.trim();
            switchImageTab('url');
        } else {
            document.getElementById('liveCardImg').src = DEFAULT_FOOD_IMG;
            switchImageTab('upload');
        }

        // Category
        const catSelect = document.getElementById('foodCategoryId');
        const opt = catSelect.options[catSelect.selectedIndex];
        if (opt) {
            document.getElementById('liveCardCategory').innerText = opt.text;
        }

        document.getElementById('btnSubmitForm').innerHTML = '<i class="fa-solid fa-check"></i> <span>Cập Nhật Món</span>';
        
        const modal = document.getElementById('foodModal');
        modal.style.display = 'flex';
        setTimeout(() => modal.classList.add('active'), 10);
        document.getElementById('foodName').focus();
    }

    function closeFoodModal() {
        const modal = document.getElementById('foodModal');
        modal.classList.remove('active');
        modal.style.display = 'none';
    }

    // Input Handlers
    function handleNameInput(val) {
        const count = val ? val.length : 0;
        document.getElementById('foodNameCount').innerText = count + '/60';
        document.getElementById('liveCardName').innerText = val && val.trim().length > 0 ? val : 'Tên món ăn của bạn';
    }

    function handlePriceInput(val) {
        const num = parseFloat(val) || 0;
        const badge = document.getElementById('priceFormattedBadge');
        const badgeText = document.getElementById('priceFormattedText');
        const livePrice = document.getElementById('liveCardPrice');
        
        if (num > 0) {
            const formatted = new Intl.NumberFormat('vi-VN').format(num) + ' đ';
            badgeText.innerText = '👉 Giá hiển thị: ' + formatted;
            badge.style.display = 'inline-flex';
            livePrice.innerText = formatted;
        } else {
            badge.style.display = 'none';
            livePrice.innerText = '0 đ';
        }
    }

    function setQuickPrice(val) {
        const input = document.getElementById('foodPrice');
        input.value = val;
        handlePriceInput(val);
    }

    function adjustPrice(delta) {
        const input = document.getElementById('foodPrice');
        let cur = parseFloat(input.value) || 0;
        cur = Math.max(1000, cur + delta);
        input.value = cur;
        handlePriceInput(cur);
    }

    function handleCategoryChange(selectEl) {
        const opt = selectEl.options[selectEl.selectedIndex];
        if (opt) {
            document.getElementById('liveCardCategory').innerText = opt.text;
        }
    }

    function handleDescInput(val) {
        const count = val ? val.length : 0;
        document.getElementById('foodDescCount').innerText = count + '/200';
        document.getElementById('liveCardDesc').innerText = val && val.trim().length > 0 
            ? val 
            : 'Mô tả món ăn thơm ngon, tươi mới, chuẩn vị truyền thống...';
    }

    // Toggle Availability
    function toggleAvailability() {
        const chk = document.getElementById('foodIsAvailable');
        setAvailability(!chk.checked);
    }

    function setAvailability(active) {
        const card = document.getElementById('availabilityCard');
        const chk = document.getElementById('foodIsAvailable');
        const iconBox = document.getElementById('switchIconBox');
        const title = document.getElementById('switchTitle');
        const sub = document.getElementById('switchSubtitle');
        const liveStatus = document.getElementById('liveCardStatus');

        chk.checked = active;
        if (active) {
            card.classList.add('is-active');
            iconBox.innerHTML = '<i class="fa-solid fa-circle-check"></i>';
            title.innerText = 'Mở bán ngay lập tức';
            sub.innerText = 'Khách hàng có thể tìm thấy và đặt món này trên ứng dụng';
            liveStatus.className = 'mf-live-card-status-badge bg-success text-white';
            liveStatus.innerHTML = '<i class="fa-solid fa-check me-1"></i> Đang bán';
        } else {
            card.classList.remove('is-active');
            iconBox.innerHTML = '<i class="fa-solid fa-eye-slash"></i>';
            title.innerText = 'Tạm ẩn / Hết món';
            sub.innerText = 'Món ăn sẽ tạm thời không cho phép khách hàng đặt';
            liveStatus.className = 'mf-live-card-status-badge bg-secondary text-white';
            liveStatus.innerHTML = '<i class="fa-solid fa-pause me-1"></i> Tạm ngưng';
        }
    }

    // Image Tabs & Handling
    function switchImageTab(tab) {
        const tabUpload = document.getElementById('tabUploadBtn');
        const tabUrl = document.getElementById('tabUrlBtn');
        const paneUpload = document.getElementById('imageUploadPane');
        const paneUrl = document.getElementById('imageUrlPane');

        if (tab === 'upload') {
            tabUpload.classList.add('active');
            tabUrl.classList.remove('active');
            paneUpload.style.display = 'block';
            paneUrl.style.display = 'none';
        } else {
            tabUrl.classList.add('active');
            tabUpload.classList.remove('active');
            paneUrl.style.display = 'block';
            paneUpload.style.display = 'none';
        }
    }

    function handleUrlInput(val) {
        const img = document.getElementById('liveCardImg');
        if (val && val.trim().length > 5) {
            img.src = val.trim();
        } else {
            img.src = DEFAULT_FOOD_IMG;
        }
    }

    function applyPreset(url) {
        switchImageTab('url');
        document.getElementById('foodImageUrl').value = url;
        handleUrlInput(url);
    }

    function handleFileSelect(e) {
        const file = e.target.files && e.target.files[0];
        if (file) {
            processSelectedFile(file);
        }
    }

    function processSelectedFile(file) {
        if (!file.type.match('image.*')) {
            alert('Vui lòng chọn một tệp hình ảnh hợp lệ (PNG, JPG, WEBP)!');
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            alert('Kích thước ảnh tối đa là 10MB!');
            return;
        }
        
        document.getElementById('dropzoneText').innerHTML = '✅ Đã chọn: <strong>' + file.name + '</strong>';
        
        const reader = new FileReader();
        reader.onload = function(evt) {
            document.getElementById('liveCardImg').src = evt.target.result;
        };
        reader.readAsDataURL(file);
    }

    function handleDragOver(e) {
        e.preventDefault();
        e.stopPropagation();
        document.getElementById('imageUploadPane').classList.add('dragover');
    }

    function handleDragLeave(e) {
        e.preventDefault();
        e.stopPropagation();
        document.getElementById('imageUploadPane').classList.remove('dragover');
    }

    function handleFileDrop(e) {
        e.preventDefault();
        e.stopPropagation();
        document.getElementById('imageUploadPane').classList.remove('dragover');
        const files = e.dataTransfer.files;
        if (files && files.length > 0) {
            const input = document.getElementById('foodImageFile');
            input.files = files;
            processSelectedFile(files[0]);
        }
    }

    function handleFormSubmit() {
        const name = document.getElementById('foodName').value;
        const price = document.getElementById('foodPrice').value;
        if (!name || name.trim().length === 0) {
            alert('Vui lòng nhập tên món ăn!');
            document.getElementById('foodName').focus();
            return false;
        }
        if (!price || parseFloat(price) <= 0) {
            alert('Vui lòng nhập giá bán hợp lệ lớn hơn 0!');
            document.getElementById('foodPrice').focus();
            return false;
        }

        const btn = document.getElementById('btnSubmitForm');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> <span>Đang lưu...</span>';
        return true;
    }

    // Keyboard Shortcuts (Esc to close)
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const modal = document.getElementById('foodModal');
            if (modal && modal.style.display !== 'none') {
                closeFoodModal();
            }
        }
    });

    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('action') === 'add') {
            openAddFoodModal();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
