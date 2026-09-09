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
            <div>
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

<!-- Modal Thêm / Chỉnh Sửa Món Ăn -->
<div id="foodModal" class="merchant-modal-backdrop" style="display: none;">
    <div class="merchant-modal-box">
        <div class="merchant-modal-header">
            <h3 class="merchant-modal-title" id="modalTitle">
                <i class="fa-solid fa-plus-circle text-primary"></i> Đăng Món Ăn Mới
            </h3>
            <button type="button" class="merchant-modal-close" onclick="closeFoodModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" id="foodForm">
            <input type="hidden" name="action" id="formAction" value="add" />
            <input type="hidden" name="foodId" id="foodId" value="" />

            <div class="merchant-modal-body">
                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Tên món ăn <span class="text-danger">*</span></label>
                    <input type="text" name="name" id="foodName" required placeholder="Ví dụ: Cơm sườn nướng mật ong" class="form-control" style="border-radius: 10px;" />
                </div>

                <div class="row mb-3">
                    <div class="col-md-6 form-group">
                        <label class="form-label fw-bold mb-1">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" name="price" id="foodPrice" required min="1000" step="1000" placeholder="Ví dụ: 55000" class="form-control" style="border-radius: 10px;" />
                    </div>
                    <div class="col-md-6 form-group">
                        <label class="form-label fw-bold mb-1">Danh mục món <span class="text-danger">*</span></label>
                        <select name="categoryId" id="foodCategoryId" class="form-select form-control" required style="border-radius: 10px; height: 44px;">
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}">${cat.imageIcon} ${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Link hình ảnh món ăn (URL)</label>
                    <input type="url" name="imageUrl" id="foodImageUrl" placeholder="https://..." class="form-control" oninput="previewImage(this.value)" style="border-radius: 10px;" />
                    <div class="image-preview-box mt-2" id="imagePreviewContainer" style="display: none;">
                        <img id="imagePreview" src="" alt="Xem trước ảnh" style="max-height: 120px; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 2px 6px rgba(0,0,0,0.05);" />
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label fw-bold mb-1">Mô tả món ăn</label>
                    <textarea name="description" id="foodDescription" rows="3" placeholder="Thành phần dinh dưỡng, hương vị đặc trưng..." class="form-control" style="border-radius: 10px;"></textarea>
                </div>

                <div class="form-check d-flex align-items-center gap-2 p-2 rounded-2" style="background: var(--surface-light); border: 1px solid var(--border-color);">
                    <input type="checkbox" name="isAvailable" id="foodIsAvailable" value="true" checked class="form-check-input ms-1" />
                    <label for="foodIsAvailable" class="form-check-label fw-medium text-dark cursor-pointer mb-0" style="font-size: 0.88rem;">
                        Mở bán món ăn ngay sau khi lưu
                    </label>
                </div>
            </div>

            <div class="merchant-modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeFoodModal()">Hủy bỏ</button>
                <button type="submit" class="btn btn-primary d-inline-flex align-items-center gap-1" id="btnSubmitForm">
                    <i class="fa-solid fa-check"></i> Lưu Món Ăn
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddFoodModal() {
        document.getElementById('modalTitle').innerHTML = '<i class="fa-solid fa-plus-circle text-primary"></i> Đăng Món Ăn Mới';
        document.getElementById('formAction').value = 'add';
        document.getElementById('foodId').value = '';
        document.getElementById('foodName').value = '';
        document.getElementById('foodPrice').value = '';
        document.getElementById('foodImageUrl').value = '';
        document.getElementById('foodDescription').value = '';
        document.getElementById('foodIsAvailable').checked = true;
        document.getElementById('imagePreviewContainer').style.display = 'none';
        document.getElementById('btnSubmitForm').innerHTML = '<i class="fa-solid fa-plus"></i> Đăng Món Mới';
        document.getElementById('foodModal').style.display = 'flex';
    }

    function openEditFoodModal(id, name, price, categoryId, imageUrl, desc, isAvailable) {
        document.getElementById('modalTitle').innerHTML = '<i class="fa-solid fa-pen-to-square text-primary"></i> Chỉnh Sửa Món Ăn';
        document.getElementById('formAction').value = 'update';
        document.getElementById('foodId').value = id;
        document.getElementById('foodName').value = name;
        document.getElementById('foodPrice').value = price;
        document.getElementById('foodCategoryId').value = categoryId;
        document.getElementById('foodImageUrl').value = imageUrl;
        document.getElementById('foodDescription').value = desc;
        document.getElementById('foodIsAvailable').checked = isAvailable;
        previewImage(imageUrl);
        document.getElementById('btnSubmitForm').innerHTML = '<i class="fa-solid fa-check"></i> Cập Nhật Món';
        document.getElementById('foodModal').style.display = 'flex';
    }

    function closeFoodModal() {
        document.getElementById('foodModal').style.display = 'none';
    }

    function previewImage(url) {
        const previewContainer = document.getElementById('imagePreviewContainer');
        const img = document.getElementById('imagePreview');
        if (url && url.trim().length > 5) {
            img.src = url.trim();
            previewContainer.style.display = 'block';
        } else {
            previewContainer.style.display = 'none';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('action') === 'add') {
            openAddFoodModal();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
