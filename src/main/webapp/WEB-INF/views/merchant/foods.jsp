<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Thực Đơn Món Ăn - Utee Merchant" />
</jsp:include>

<div class="admin-dashboard-container">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp" />

    <div class="container section pt-0">
        <!-- Toolbar Tìm Kiếm & Nút Đăng Món Mới -->
        <div class="admin-header-box mb-3 py-3">
            <form action="${pageContext.request.contextPath}/merchant/foods" method="GET" class="d-flex align-items-center gap-3 flex-wrap flex-grow-1">
                <div style="position: relative; flex: 1; min-width: 240px;">
                    <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 14px; top: 12px; color: #999;"></i>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo tên món hoặc mô tả..." class="form-control" style="padding-left: 38px;" />
                </div>
                <div style="min-width: 200px;">
                    <select name="categoryId" class="form-select" onchange="this.form.submit()">
                        <option value="ALL">-- Tất cả danh mục --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${selectedCategoryId == cat.id ? 'selected' : ''}>${cat.imageIcon} ${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-filter"></i> Lọc Món</button>
                <c:if test="${not empty keyword || not empty selectedCategoryId}">
                    <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-outline btn-sm">Xóa Lọc</a>
                </c:if>
            </form>
            <div>
                <button type="button" class="btn btn-primary" onclick="openAddFoodModal()">
                    <i class="fa-solid fa-plus-circle"></i> <span>+ Đăng Món Mới</span>
                </button>
            </div>
        </div>

        <!-- Bảng Món Ăn (admin-table-card) -->
        <div class="admin-table-card">
            <div class="admin-table-header">
                <div>
                    <h3 class="table-card-title"><i class="fa-solid fa-bowl-food text-primary"></i> Danh Sách Món Ăn Của Quán</h3>
                    <span class="table-card-sub">Tổng cộng có <strong>${empty foods ? 0 : foods.size()}</strong> món ăn trong thực đơn</span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="admin-data-table">
                    <thead>
                        <tr>
                            <th>Ảnh</th>
                            <th>Tên Món Ăn</th>
                            <th>Danh Mục</th>
                            <th>Giá Bán</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty foods}">
                                <c:forEach var="food" items="${foods}">
                                    <tr>
                                        <td style="width: 70px;">
                                            <img src="${food.imageUrl}" alt="${food.name}" style="width: 54px; height: 54px; object-fit: cover; border-radius: 8px; border: 1px solid #eee;" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&fit=crop'" />
                                        </td>
                                        <td>
                                            <strong style="font-size: 1rem; display: block;">${food.name}</strong>
                                            <small class="text-muted" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; max-width: 320px;">
                                                ${food.description}
                                            </small>
                                        </td>
                                        <td>
                                            <span class="badge badge-cod">${food.categoryName}</span>
                                        </td>
                                        <td class="font-weight-bold text-primary fs-6">
                                            <fmt:formatNumber value="${food.price}" type="number" /> đ
                                        </td>
                                        <td>
                                            <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="toggle" />
                                                <input type="hidden" name="foodId" value="${food.id}" />
                                                <input type="hidden" name="status" value="${!food.available}" />
                                                <button type="submit" class="btn btn-sm ${food.available ? 'btn-outline border-success text-success' : 'btn-outline border-warning text-warning'}" style="border-radius: 20px; font-weight: 600; padding: 4px 12px;" title="Bấm để bật/tắt còn món">
                                                    <i class="fa-solid ${food.available ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
                                                    ${food.available ? 'Đang Bán' : 'Tạm Hết'}
                                                </button>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2">
                                                <button type="button" class="btn btn-outline btn-sm" 
                                                        onclick="openEditFoodModal(${food.id}, '${food.name}', ${food.price}, ${food.categoryId}, '${food.imageUrl}', '${food.description}', ${food.available})">
                                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                </button>
                                                <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa món này không?');">
                                                    <input type="hidden" name="action" value="delete" />
                                                    <input type="hidden" name="foodId" value="${food.id}" />
                                                    <button type="submit" class="btn btn-danger btn-sm"><i class="fa-solid fa-trash"></i></button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <div style="font-size: 2.5rem; margin-bottom: 12px;">🍲</div>
                                            <c:choose>
                                                <c:when test="${not empty keyword || not empty selectedCategoryId}">
                                                    <h4 style="font-size: 1.1rem; color: #444; margin-bottom: 6px;">Không tìm thấy món ăn nào phù hợp với bộ lọc!</h4>
                                                    <p class="text-muted small">Thử thay đổi từ khóa tìm kiếm hoặc chọn danh mục khác.</p>
                                                    <a href="${pageContext.request.contextPath}/merchant/foods" class="btn btn-outline btn-sm mt-2">Xóa bộ lọc</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <h4 style="font-size: 1.15rem; color: #444; margin-bottom: 6px;">Thực đơn của quán hiện đang trống!</h4>
                                                    <p class="text-muted small">Hãy thêm các món ăn thơm ngon đầu tiên của quán để bắt đầu phục vụ khách hàng.</p>
                                                    <button class="btn btn-primary btn-sm mt-2" onclick="openAddFoodModal()">
                                                        <i class="fa-solid fa-plus-circle"></i> + Đăng Món Đầu Tiên
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
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fa-solid fa-plus-circle text-primary"></i> Đăng Món Ăn Mới</h3>
            <button type="button" class="modal-close-btn" onclick="closeFoodModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/merchant/foods" method="POST" id="foodForm">
            <input type="hidden" name="action" id="formAction" value="add" />
            <input type="hidden" name="foodId" id="foodId" value="" />

            <div class="modal-body">
                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Tên món ăn <span class="text-danger">*</span></label>
                    <input type="text" name="name" id="foodName" required placeholder="Ví dụ: Cơm sườn nướng mật ong" class="form-control" />
                </div>

                <div class="row-fields mb-3">
                    <div class="form-group col-half">
                        <label class="form-label font-weight-bold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                        <input type="number" name="price" id="foodPrice" required min="1000" step="1000" placeholder="Ví dụ: 55000" class="form-control" />
                    </div>
                    <div class="form-group col-half">
                        <label class="form-label font-weight-bold">Danh mục ẩm thực <span class="text-danger">*</span></label>
                        <select name="categoryId" id="foodCategoryId" class="form-select" required>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}">${cat.imageIcon} ${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Link hình ảnh món ăn (URL)</label>
                    <input type="url" name="imageUrl" id="foodImageUrl" placeholder="https://..." class="form-control" oninput="previewImage(this.value)" />
                    <div class="image-preview-box mt-2" id="imagePreviewContainer" style="display: none;">
                        <img id="imagePreview" src="" alt="Xem trước ảnh" style="max-height: 120px; border-radius: 8px; border: 1px solid #ddd;" />
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label class="form-label font-weight-bold">Mô tả món ăn</label>
                    <textarea name="description" id="foodDescription" rows="3" placeholder="Thành phần, hương vị đặc trưng..." class="form-control"></textarea>
                </div>

                <div class="form-check">
                    <input type="checkbox" name="isAvailable" id="foodIsAvailable" value="true" checked class="form-check-input" />
                    <label for="foodIsAvailable" class="form-check-label">Mở bán món ăn ngay sau khi lưu</label>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeFoodModal()">Hủy bỏ</button>
                <button type="submit" class="btn btn-primary" id="btnSubmitForm">Lưu Món Ăn</button>
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
        document.getElementById('btnSubmitForm').innerText = 'Đăng Món Mới';
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
        document.getElementById('btnSubmitForm').innerText = 'Cập Nhật Món';
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
