<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Đánh Giá Đơn Hàng #FZ-${order.id} - Utee Express" />
</jsp:include>

<style>
/* ==========================================================================
   DEDICATED ORDER REVIEW PAGE STYLING (UI/UX PRO MAX)
   ========================================================================== */
:root {
    --review-gold: #f59e0b;
    --review-gold-hover: #d97706;
    --review-gold-bg: #fffbeb;
    --review-gold-border: #fde68a;
    --review-card-bg: #ffffff;
    --review-radius: 20px;
}

.review-page-wrapper {
    background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
    min-height: 85vh;
    padding-top: 32px;
    padding-bottom: 70px;
}

/* Breadcrumb & Header */
.review-breadcrumb {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 0.88rem;
    color: #64748b;
    margin-bottom: 20px;
}
.review-breadcrumb a {
    color: #475569;
    text-decoration: none;
    transition: color 0.2s;
}
.review-breadcrumb a:hover {
    color: var(--primary-color);
}
.review-breadcrumb i {
    font-size: 0.72rem;
    color: #94a3b8;
}

.review-header-box {
    background: #ffffff;
    border-radius: var(--review-radius);
    padding: 24px 30px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    border: 1px solid #e2e8f0;
    margin-bottom: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
}

.review-header-info h1 {
    font-family: var(--font-heading);
    font-size: 1.55rem;
    font-weight: 800;
    color: #0f172a;
    margin: 0 0 6px 0;
    display: flex;
    align-items: center;
    gap: 10px;
}
.review-header-info p {
    margin: 0;
    font-size: 0.92rem;
    color: #64748b;
}
.review-order-badge {
    background: #eff6ff;
    color: #2563eb;
    padding: 6px 14px;
    border-radius: 50px;
    font-weight: 700;
    font-size: 0.85rem;
    border: 1px solid #bfdbfe;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

/* Main Two-Column Layout */
.review-layout-grid {
    display: grid;
    grid-template-columns: 1fr 1.6fr;
    gap: 28px;
    align-items: flex-start;
}

/* Left Sidebar: Order Summary Card */
.review-sidebar-card {
    background: #ffffff;
    border-radius: var(--review-radius);
    padding: 24px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    position: sticky;
    top: 90px;
}
.store-summary-header {
    display: flex;
    align-items: center;
    gap: 14px;
    padding-bottom: 18px;
    border-bottom: 1px dashed #e2e8f0;
    margin-bottom: 18px;
}
.store-avatar-wrap {
    width: 54px;
    height: 54px;
    border-radius: 14px;
    overflow: hidden;
    background: #f1f5f9;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid #e2e8f0;
}
.store-avatar-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.store-avatar-wrap i {
    font-size: 1.6rem;
    color: var(--primary-color);
}
.store-info-wrap h3 {
    font-size: 1.05rem;
    font-weight: 800;
    color: #1e293b;
    margin: 0 0 4px 0;
}
.store-info-wrap p {
    font-size: 0.82rem;
    color: #64748b;
    margin: 0;
}

.review-food-list {
    margin-bottom: 18px;
}
.review-food-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 8px 0;
    border-bottom: 1px solid #f8fafc;
}
.review-food-thumb {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    object-fit: cover;
    flex-shrink: 0;
}
.review-food-desc {
    flex: 1;
}
.review-food-name {
    font-size: 0.88rem;
    font-weight: 700;
    color: #1e293b;
    margin: 0;
}
.review-food-qty {
    font-size: 0.78rem;
    color: #64748b;
}
.review-food-price {
    font-size: 0.88rem;
    font-weight: 700;
    color: #0f172a;
}

.review-bill-summary {
    background: #f8fafc;
    border-radius: 12px;
    padding: 14px 16px;
    font-size: 0.88rem;
}
.bill-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 6px;
    color: #64748b;
}
.bill-row.total {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px dashed #cbd5e1;
    font-size: 1rem;
    font-weight: 800;
    color: var(--primary-color);
    margin-bottom: 0;
}

/* Right Content: Review Form Card */
.review-form-card {
    background: #ffffff;
    border-radius: var(--review-radius);
    padding: 32px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.04);
}

.review-section-block {
    background: #ffffff;
    border: 1.5px solid #e2e8f0;
    border-radius: 18px;
    padding: 24px;
    margin-bottom: 28px;
    transition: border-color 0.2s, box-shadow 0.2s;
}
.review-section-block:focus-within {
    border-color: #f59e0b;
    box-shadow: 0 6px 24px rgba(245, 158, 11, 0.12);
}

.section-head-title {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 18px;
}
.section-icon-badge {
    width: 42px;
    height: 42px;
    border-radius: 12px;
    background: #fff7ed;
    color: #ea580c;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
}
.section-icon-badge.driver {
    background: #eff6ff;
    color: #2563eb;
}
.section-head-title h2 {
    font-size: 1.15rem;
    font-weight: 800;
    color: #0f172a;
    margin: 0 0 3px 0;
}
.section-head-title p {
    font-size: 0.82rem;
    color: #64748b;
    margin: 0;
}

/* Interactive Star Rating Widget */
.star-rating-box {
    display: flex;
    align-items: center;
    gap: 18px;
    background: #fffbeb;
    border: 1px solid #fde68a;
    border-radius: 14px;
    padding: 16px 20px;
    margin-bottom: 18px;
}
.star-rating-icons {
    display: inline-flex;
    flex-direction: row-reverse;
    gap: 6px;
}
.star-rating-icons input[type="radio"] {
    display: none;
}
.star-rating-icons label {
    cursor: pointer;
    font-size: 2rem;
    color: #cbd5e1;
    transition: all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.star-rating-icons label:hover,
.star-rating-icons label:hover ~ label,
.star-rating-icons input[type="radio"]:checked ~ label {
    color: #f59e0b;
    transform: scale(1.15);
}
.star-rating-label {
    font-size: 0.95rem;
    font-weight: 700;
    color: #b45309;
    flex: 1;
}

/* Quick Tag Chips */
.quick-tags-title {
    font-size: 0.82rem;
    font-weight: 700;
    color: #475569;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.quick-tags-group {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 18px;
}
.quick-tag-chip {
    cursor: pointer;
    background: #f1f5f9;
    color: #334155;
    border: 1px solid #cbd5e1;
    border-radius: 50px;
    padding: 6px 14px;
    font-size: 0.84rem;
    font-weight: 600;
    transition: all 0.2s ease;
    user-select: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.quick-tag-chip input[type="checkbox"] {
    display: none;
}
.quick-tag-chip:hover {
    background: #e2e8f0;
}
.quick-tag-chip.selected {
    background: #f59e0b;
    color: #ffffff;
    border-color: #d97706;
    box-shadow: 0 2px 8px rgba(245, 158, 11, 0.35);
}

/* Review Textarea */
.review-textarea-wrap {
    position: relative;
}
.review-textarea {
    width: 100%;
    border: 1.5px solid #cbd5e1;
    border-radius: 12px;
    padding: 14px 16px;
    font-size: 0.92rem;
    color: #1e293b;
    outline: none;
    resize: vertical;
    min-height: 95px;
    font-family: inherit;
    transition: border-color 0.2s;
    background: #ffffff;
}
.review-textarea:focus {
    border-color: #f59e0b;
}

/* Photo Uploader Component */
.review-photo-upload-container {
    margin-top: 16px;
}
.photo-upload-label {
    font-size: 0.88rem;
    font-weight: 700;
    color: #334155;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
}
.photo-upload-dropzone {
    border: 2px dashed #cbd5e1;
    border-radius: 14px;
    background: #f8fafc;
    padding: 16px 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.25s ease;
}
.photo-upload-dropzone:hover {
    border-color: #f59e0b;
    background: #fffdf5;
}
.dropzone-idle-content .dropzone-icon {
    font-size: 1.8rem;
    color: #f59e0b;
    margin-bottom: 4px;
}
.dropzone-idle-content .dropzone-text {
    font-size: 0.9rem;
    color: #334155;
}
.dropzone-idle-content .dropzone-hint {
    font-size: 0.78rem;
    color: #94a3b8;
    margin-top: 3px;
}
.dropzone-preview-content {
    display: flex;
    align-items: center;
    gap: 16px;
    background: #ffffff;
    border-radius: 12px;
    padding: 10px 14px;
    border: 1px solid #e2e8f0;
    text-align: left;
}
.photo-preview-thumb {
    width: 64px;
    height: 64px;
    border-radius: 10px;
    object-fit: cover;
    border: 1px solid #e2e8f0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.preview-meta {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
}
.preview-filename {
    font-size: 0.86rem;
    font-weight: 700;
    color: #1e293b;
    word-break: break-all;
}
.btn-remove-photo {
    border: none;
    background: #fee2e2;
    color: #dc2626;
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    width: fit-content;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    transition: background 0.2s;
}
.btn-remove-photo:hover {
    background: #fecaca;
}

/* Reviewed Photo Display */
.reviewed-photo-display {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 14px 16px;
    margin-top: 14px;
}
.reviewed-photo-label {
    font-size: 0.84rem;
    font-weight: 700;
    color: #475569;
    margin-bottom: 8px;
}
.reviewed-photo-img {
    max-width: 220px;
    max-height: 180px;
    border-radius: 10px;
    object-fit: cover;
    border: 1px solid #cbd5e1;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.06);
    transition: transform 0.2s, box-shadow 0.2s;
}
.reviewed-photo-img:hover {
    transform: scale(1.02);
    box-shadow: 0 6px 18px rgba(0,0,0,0.12);
}

/* Driver Sub-card in section 2 */
.driver-preview-card {
    display: flex;
    align-items: center;
    gap: 14px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 16px;
}
.driver-avatar-circle {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #dbeafe;
    color: #2563eb;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.2rem;
    font-weight: 700;
}
.driver-info-box h4 {
    margin: 0 0 2px 0;
    font-size: 0.96rem;
    font-weight: 700;
    color: #0f172a;
}
.driver-info-box p {
    margin: 0;
    font-size: 0.8rem;
    color: #64748b;
}

/* Submit Actions Bar */
.review-actions-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    flex-wrap: wrap;
    padding-top: 10px;
}
.btn-submit-review {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    color: #ffffff;
    border: none;
    border-radius: 50px;
    padding: 14px 34px;
    font-size: 1rem;
    font-weight: 800;
    cursor: pointer;
    box-shadow: 0 6px 20px rgba(245, 158, 11, 0.35);
    display: inline-flex;
    align-items: center;
    gap: 10px;
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-submit-review:hover {
    background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(245, 158, 11, 0.45);
    color: #ffffff;
}

/* ==========================================================================
   ALREADY REVIEWED STATE STYLING
   ========================================================================== */
.reviewed-success-banner {
    background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
    border: 1.5px solid #a7f3d0;
    border-radius: 18px;
    padding: 24px;
    text-align: center;
    margin-bottom: 28px;
}
.reviewed-icon-circle {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: #10b981;
    color: #ffffff;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1.8rem;
    margin-bottom: 12px;
    box-shadow: 0 8px 20px rgba(16, 185, 129, 0.25);
}
.reviewed-success-banner h2 {
    font-size: 1.35rem;
    font-weight: 800;
    color: #065f46;
    margin: 0 0 6px 0;
}
.reviewed-success-banner p {
    font-size: 0.92rem;
    color: #047857;
    margin: 0;
}

.reviewed-box-display {
    background: #ffffff;
    border: 1.5px solid #fed7aa;
    border-radius: 16px;
    padding: 20px;
    margin-bottom: 20px;
}
.reviewed-box-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
}
.reviewed-box-head .target-title {
    font-size: 1.05rem;
    font-weight: 800;
    color: #7c2d12;
    display: flex;
    align-items: center;
    gap: 8px;
}
.reviewed-stars {
    color: #f59e0b;
    font-size: 1.25rem;
    font-weight: 800;
    display: flex;
    align-items: center;
    gap: 4px;
}
.reviewed-comment-text {
    background: #fffbeb;
    border-radius: 10px;
    padding: 14px 18px;
    color: #334155;
    font-size: 0.95rem;
    line-height: 1.6;
    border-left: 4px solid #f59e0b;
    font-style: italic;
}

@media (max-width: 992px) {
    .review-layout-grid {
        grid-template-columns: 1fr;
    }
    .review-sidebar-card {
        position: static;
    }
    .review-form-card {
        padding: 20px;
    }
}
</style>

<div class="review-page-wrapper">
    <div class="container">
        <!-- Breadcrumb navigation -->
        <div class="review-breadcrumb">
            <a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <a href="${pageContext.request.contextPath}/profile?tab=orders">Đơn hàng của tôi</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>Đánh giá đơn #FZ-${order.id}</span>
        </div>

        <!-- Header Card -->
        <div class="review-header-box">
            <div class="review-header-info">
                <h1>
                    <i class="fa-solid fa-star text-warning"></i>
                    <span>${isReviewed ? 'Chi Tiết Đánh Giá Đơn Hàng' : 'Đánh Giá Trải Nghiệm Món Ăn & Dịch Vụ'}</span>
                </h1>
                <p>Mã đơn hàng: <strong class="text-danger">#FZ-${order.id}</strong> • Thời gian đặt: <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm" /></p>
            </div>
            <div>
                <span class="review-order-badge">
                    <i class="fa-solid fa-circle-check text-success"></i> Giao hàng thành công
                </span>
            </div>
        </div>

        <!-- Success Alert Flash Message -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius: 16px; margin-bottom: 24px; padding: 16px 20px; font-weight: 600; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.15);">
                <i class="fa-solid fa-circle-check me-2"></i> ${successMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="review-layout-grid">
            <!-- Left Column: Order Summary Info -->
            <div class="review-sidebar-card">
                <div class="store-summary-header">
                    <div class="store-avatar-wrap">
                        <c:choose>
                            <c:when test="${not empty order.restaurantImage}">
                                <img src="${order.restaurantImage}" alt="${order.restaurantName}" onerror="this.src='https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&fit=crop'" />
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-store"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="store-info-wrap">
                        <h3>${not empty order.restaurantName ? order.restaurantName : 'Quán đối tác Utee'}</h3>
                        <p><i class="fa-solid fa-location-dot text-danger"></i> ${not empty order.restaurantAddress ? order.restaurantAddress : 'Địa chỉ quán đã xác thực'}</p>
                    </div>
                </div>

                <div class="review-food-list">
                    <div style="font-size: 0.82rem; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 10px; letter-spacing: 0.5px;">
                        Món ăn trong đơn (${order.items != null ? order.items.size() : 0})
                    </div>
                    <c:forEach items="${order.items}" var="item">
                        <div class="review-food-item">
                            <img src="${item.foodImage}" alt="${item.foodName}" class="review-food-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100&auto=format&fit=crop&q=60'" />
                            <div class="review-food-desc">
                                <h4 class="review-food-name">${item.foodName}</h4>
                                <span class="review-food-qty">x${item.quantity} phần</span>
                            </div>
                            <div class="review-food-price">
                                ${String.format("%,.0f", item.subtotal)} đ
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="review-bill-summary">
                    <div class="bill-row">
                        <span>Phương thức thanh toán:</span>
                        <strong>${order.paymentMethod}</strong>
                    </div>
                    <div class="bill-row">
                        <span>Địa chỉ giao hàng:</span>
                        <span style="max-width: 180px; text-align: right; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${order.address}">${order.address}</span>
                    </div>
                    <div class="bill-row total">
                        <span>Tổng tiền đã trả:</span>
                        <span>${String.format("%,.0f", order.totalAmount)} đ</span>
                    </div>
                </div>

                <div style="margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/profile?tab=orders" class="btn btn-outline w-100 d-flex align-items-center justify-content-center gap-2" style="border-radius: 50px; font-weight: 600; padding: 10px;">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại lịch sử đơn hàng
                    </a>
                </div>
            </div>

            <!-- Right Column: Review Submission or Review Details -->
            <div class="review-form-card">
                <c:choose>
                    <c:when test="${isReviewed}">
                        <!-- ==============================================
                             ĐÃ ĐÁNH GIÁ -> HIỂN THỊ CHI TIẾT
                             ============================================== -->
                        <div class="reviewed-success-banner">
                            <div class="reviewed-icon-circle">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                            <h2>Đơn hàng đã được đánh giá thành công!</h2>
                            <p>Cảm ơn bạn đã đóng góp ý kiến quý báu để nâng cao chất lượng dịch vụ của hệ thống Utee Express.</p>
                            <c:if test="${not empty review.createdAt}">
                                <div style="margin-top: 8px; font-size: 0.84rem; color: #065f46; font-weight: 600;">
                                    Thời gian gửi: <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                </div>
                            </c:if>
                        </div>

                        <!-- Đánh giá Món Ăn -->
                        <div class="reviewed-box-display">
                            <div class="reviewed-box-head">
                                <div class="target-title">
                                    <i class="fa-solid fa-utensils text-danger"></i>
                                    <span>1. Chất lượng Món ăn &amp; Quán:</span>
                                </div>
                                <div class="reviewed-stars">
                                    <c:forEach begin="1" end="${review.foodRating}"><i class="fa-solid fa-star"></i></c:forEach>
                                    <c:forEach begin="${review.foodRating + 1}" end="5"><i class="fa-regular fa-star" style="color: #cbd5e1;"></i></c:forEach>
                                    <span style="font-size: 0.95rem; margin-left: 6px; color: #b45309;">(${review.foodRating}/5)</span>
                                </div>
                            </div>
                            <c:if test="${not empty review.foodComment and review.foodComment ne 'Món ăn rất ngon, phục vụ chu đáo!'}">
                                <div class="reviewed-comment-text">
                                    "${review.foodComment}"
                                </div>
                            </c:if>
                            <c:if test="${not empty review.imageUrl}">
                                <div class="reviewed-photo-display">
                                    <div class="reviewed-photo-label"><i class="fa-solid fa-camera text-warning me-1"></i> Ảnh món ăn chụp thực tế:</div>
                                    <div class="reviewed-photo-wrap">
                                        <img src="${pageContext.request.contextPath}${review.imageUrl}" alt="Ảnh món ăn từ khách hàng" class="reviewed-photo-img" onclick="window.open(this.src, '_blank')" title="Nhấn để xem ảnh kích thước đầy đủ" />
                                    </div>
                                </div>
                            </c:if>
                        </div>

                        <!-- Đánh giá Tài Xế -->
                        <div class="reviewed-box-display">
                            <div class="reviewed-box-head">
                                <div class="target-title">
                                    <i class="fa-solid fa-motorcycle text-primary"></i>
                                    <span>2. Tốc độ &amp; Thái độ Tài xế Shipper:</span>
                                </div>
                                <div class="reviewed-stars">
                                    <c:forEach begin="1" end="${review.driverRating}"><i class="fa-solid fa-star"></i></c:forEach>
                                    <c:forEach begin="${review.driverRating + 1}" end="5"><i class="fa-regular fa-star" style="color: #cbd5e1;"></i></c:forEach>
                                    <span style="font-size: 0.95rem; margin-left: 6px; color: #b45309;">(${review.driverRating}/5)</span>
                                </div>
                            </div>
                            <c:if test="${not empty order.driverName}">
                                <div style="font-size: 0.85rem; color: #64748b; margin-bottom: 10px;">
                                    Tài xế phụ trách: <strong>${order.driverName}</strong> (${order.driverPhone})
                                </div>
                            </c:if>
                            <c:if test="${not empty review.driverComment and review.driverComment ne 'Giao hàng nhanh và thân thiện!'}">
                                <div class="reviewed-comment-text">
                                    "${review.driverComment}"
                                </div>
                            </c:if>
                        </div>

                        <div class="review-actions-bar" style="margin-top: 24px;">
                            <a href="${pageContext.request.contextPath}/profile?tab=orders" class="btn btn-outline" style="border-radius: 50px; font-weight: 600; padding: 12px 24px;">
                                <i class="fa-solid fa-receipt me-1"></i> Danh sách đơn hàng
                            </a>
                            <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary" style="border-radius: 50px; font-weight: 700; padding: 12px 28px;">
                                <i class="fa-solid fa-bowl-food me-1"></i> Khám phá thêm món ngon
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <!-- ==============================================
                             CHƯA ĐÁNH GIÁ -> FORM ĐÁNH GIÁ ĐẦY ĐỦ CAO CẤP
                             ============================================== -->
                        <form action="${pageContext.request.contextPath}/order-review" method="POST" enctype="multipart/form-data" id="orderReviewForm">
                            <input type="hidden" name="orderId" value="${order.id}">
                            <input type="hidden" name="driverId" value="${order.driverId != null ? order.driverId : 0}">

                            <!-- SECTION 1: ĐÁNH GIÁ MÓN ĂN & QUÁN -->
                            <div class="review-section-block">
                                <div class="section-head-title">
                                    <div class="section-icon-badge">
                                        <i class="fa-solid fa-utensils"></i>
                                    </div>
                                    <div>
                                        <h2>1. Đánh giá Món ăn &amp; Nhà hàng</h2>
                                        <p>Cảm nhận về hương vị, độ tươi nóng và cách đóng gói món ăn của quán</p>
                                    </div>
                                </div>

                                <!-- Star Rating Food -->
                                <div class="star-rating-box">
                                    <div class="star-rating-icons">
                                        <input type="radio" id="foodStar5" name="foodRating" value="5" checked onchange="updateStarLabel('food', 5)" />
                                        <label for="foodStar5" title="5 sao - Tuyệt vời & chuẩn vị!"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="foodStar4" name="foodRating" value="4" onchange="updateStarLabel('food', 4)" />
                                        <label for="foodStar4" title="4 sao - Món ngon, hài lòng"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="foodStar3" name="foodRating" value="3" onchange="updateStarLabel('food', 3)" />
                                        <label for="foodStar3" title="3 sao - Bình thường"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="foodStar2" name="foodRating" value="2" onchange="updateStarLabel('food', 2)" />
                                        <label for="foodStar2" title="2 sao - Chưa ngon"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="foodStar1" name="foodRating" value="1" onchange="updateStarLabel('food', 1)" />
                                        <label for="foodStar1" title="1 sao - Kém, không hài lòng"><i class="fa-solid fa-star"></i></label>
                                    </div>
                                    <div class="star-rating-label" id="foodStarLabel">
                                        5/5 ★ Tuyệt vời &amp; Chuẩn vị!
                                    </div>
                                </div>

                                <!-- Textarea Food -->
                                <div class="review-textarea-wrap">
                                    <textarea name="foodComment" id="foodCommentArea" class="review-textarea" style="min-height: 110px;" placeholder="Chia sẻ cảm nhận chi tiết về hương vị món ăn, độ nóng sốt và chất lượng đóng gói của quán..."></textarea>
                                </div>

                                <!-- Photo Upload Component -->
                                <div class="review-photo-upload-container">
                                    <div class="photo-upload-label">
                                        <i class="fa-solid fa-camera text-warning me-1"></i>
                                        <span>Thêm ảnh chụp món ăn thực tế (Tùy chọn)</span>
                                    </div>
                                    <div class="photo-upload-dropzone" id="photoDropzone" onclick="document.getElementById('reviewImageInput').click()">
                                        <input type="file" id="reviewImageInput" name="reviewImage" accept="image/*" style="display: none;" onchange="handlePhotoSelect(this)">
                                        <div class="dropzone-idle-content" id="dropzoneIdle">
                                            <div class="dropzone-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
                                            <div class="dropzone-text">
                                                <strong>Nhấn để chọn ảnh</strong> hoặc kéo thả ảnh vào đây
                                            </div>
                                            <div class="dropzone-hint">Hỗ trợ JPG, PNG, WEBP (Dung lượng tối đa 10MB)</div>
                                        </div>
                                        <div class="dropzone-preview-content" id="dropzonePreview" style="display: none;">
                                            <img id="previewImg" src="" alt="Xem trước ảnh món ăn" class="photo-preview-thumb">
                                            <div class="preview-meta">
                                                <span class="preview-filename" id="previewFilename"></span>
                                                <button type="button" class="btn-remove-photo" onclick="event.stopPropagation(); removePhoto();" title="Bỏ chọn ảnh này">
                                                    <i class="fa-solid fa-trash-can"></i> Xóa ảnh
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- SECTION 2: ĐÁNH GIÁ TÀI XẾ SHIPPER -->
                            <div class="review-section-block">
                                <div class="section-head-title">
                                    <div class="section-icon-badge driver">
                                        <i class="fa-solid fa-motorcycle"></i>
                                    </div>
                                    <div>
                                        <h2>2. Đánh giá Tài xế Shipper</h2>
                                        <p>Đánh giá về tốc độ giao hàng, thái độ phục vụ và bảo quản đơn hàng của shipper</p>
                                    </div>
                                </div>

                                <!-- Driver Preview Header -->
                                <c:if test="${not empty order.driverName}">
                                    <div class="driver-preview-card">
                                        <div class="driver-avatar-circle">
                                            <i class="fa-solid fa-user-ninja"></i>
                                        </div>
                                        <div class="driver-info-box">
                                            <h4>Tài xế: ${order.driverName}</h4>
                                            <p><i class="fa-solid fa-phone text-muted me-1"></i> ${order.driverPhone} • Đối tác vận chuyển Utee Express</p>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Star Rating Driver -->
                                <div class="star-rating-box">
                                    <div class="star-rating-icons">
                                        <input type="radio" id="driverStar5" name="driverRating" value="5" checked onchange="updateStarLabel('driver', 5)" />
                                        <label for="driverStar5" title="5 sao - Siêu tốc & rất thân thiện!"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="driverStar4" name="driverRating" value="4" onchange="updateStarLabel('driver', 4)" />
                                        <label for="driverStar4" title="4 sao - Giao đúng giờ & lịch sự"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="driverStar3" name="driverRating" value="3" onchange="updateStarLabel('driver', 3)" />
                                        <label for="driverStar3" title="3 sao - Bình thường"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="driverStar2" name="driverRating" value="2" onchange="updateStarLabel('driver', 2)" />
                                        <label for="driverStar2" title="2 sao - Giao trễ / Không hài lòng"><i class="fa-solid fa-star"></i></label>

                                        <input type="radio" id="driverStar1" name="driverRating" value="1" onchange="updateStarLabel('driver', 1)" />
                                        <label for="driverStar1" title="1 sao - Thái độ kém"><i class="fa-solid fa-star"></i></label>
                                    </div>
                                    <div class="star-rating-label" id="driverStarLabel">
                                        5/5 ★ Siêu tốc &amp; Rất thân thiện!
                                    </div>
                                </div>

                                <!-- Quick Tags Driver (Không dùng emoji) -->
                                <div class="quick-tags-title"><i class="fa-solid fa-tags text-primary me-1"></i> Gợi ý nhận xét nhanh về tài xế:</div>
                                <div class="quick-tags-group">
                                    <label class="quick-tag-chip" onclick="toggleTagChip(this)">
                                        <input type="checkbox" name="driverTags" value="Giao hàng nhanh chóng">
                                        <span>Giao hàng nhanh chóng</span>
                                    </label>
                                    <label class="quick-tag-chip" onclick="toggleTagChip(this)">
                                        <input type="checkbox" name="driverTags" value="Thái độ thân thiện, nhiệt tình">
                                        <span>Thái độ thân thiện, nhiệt tình</span>
                                    </label>
                                    <label class="quick-tag-chip" onclick="toggleTagChip(this)">
                                        <input type="checkbox" name="driverTags" value="Gọi điện trước khi đến">
                                        <span>Gọi điện trước khi đến</span>
                                    </label>
                                    <label class="quick-tag-chip" onclick="toggleTagChip(this)">
                                        <input type="checkbox" name="driverTags" value="Bảo quản đồ ăn cẩn thận">
                                        <span>Bảo quản đồ ăn cẩn thận</span>
                                    </label>
                                    <label class="quick-tag-chip" onclick="toggleTagChip(this)">
                                        <input type="checkbox" name="driverTags" value="Lái xe an toàn">
                                        <span>Lái xe an toàn</span>
                                    </label>
                                </div>

                                <!-- Textarea Driver -->
                                <div class="review-textarea-wrap">
                                    <textarea name="driverComment" id="driverCommentArea" class="review-textarea" placeholder="Nhận xét chi tiết về thái độ phục vụ và trải nghiệm giao hàng của tài xế..."></textarea>
                                </div>
                            </div>

                            <!-- Actions Bar -->
                            <div class="review-actions-bar">
                                <a href="${pageContext.request.contextPath}/profile?tab=orders" class="btn btn-outline" style="border-radius: 50px; padding: 12px 24px; font-weight: 600;">
                                    <i class="fa-solid fa-xmark me-1"></i> Để sau
                                </a>
                                <button type="submit" class="btn-submit-review">
                                    <i class="fa-solid fa-paper-plane"></i>
                                    <span>Gửi Đánh Giá Ngay</span>
                                </button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script>
const foodLabels = {
    5: "5/5 ★ Tuyệt vời & Chuẩn vị!",
    4: "4/5 ★ Món ngon, rất hài lòng",
    3: "3/5 ★ Món ăn bình thường",
    2: "2/5 ★ Chưa hợp khẩu vị",
    1: "1/5 ★ Rất không hài lòng"
};

const driverLabels = {
    5: "5/5 ★ Siêu tốc & Rất thân thiện!",
    4: "4/5 ★ Giao đúng giờ & Lịch sự",
    3: "3/5 ★ Giao hàng bình thường",
    2: "2/5 ★ Giao trễ / Chưa hài lòng",
    1: "1/5 ★ Thái độ phục vụ kém"
};

function updateStarLabel(type, starCount) {
    if (type === 'food') {
        const lbl = document.getElementById('foodStarLabel');
        if (lbl && foodLabels[starCount]) lbl.innerHTML = foodLabels[starCount];
    } else if (type === 'driver') {
        const lbl = document.getElementById('driverStarLabel');
        if (lbl && driverLabels[starCount]) lbl.innerHTML = driverLabels[starCount];
    }
}

function toggleTagChip(chipEl) {
    const cb = chipEl.querySelector('input[type="checkbox"]');
    if (!cb) return;
    setTimeout(() => {
        if (cb.checked) {
            chipEl.classList.add('selected');
        } else {
            chipEl.classList.remove('selected');
        }
    }, 10);
}

function handlePhotoSelect(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        if (!file.type.match('image.*')) {
            alert('Vui lòng chỉ chọn tệp hình ảnh (JPG, PNG, WEBP)!');
            input.value = '';
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            alert('Kích thước ảnh vượt quá giới hạn 10MB. Vui lòng chọn ảnh nhỏ hơn!');
            input.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('previewImg').src = e.target.result;
            document.getElementById('previewFilename').textContent = file.name;
            document.getElementById('dropzoneIdle').style.display = 'none';
            document.getElementById('dropzonePreview').style.display = 'flex';
        };
        reader.readAsDataURL(file);
    }
}

function removePhoto() {
    const input = document.getElementById('reviewImageInput');
    if (input) input.value = '';
    const previewImg = document.getElementById('previewImg');
    if (previewImg) previewImg.src = '';
    const previewFilename = document.getElementById('previewFilename');
    if (previewFilename) previewFilename.textContent = '';
    const dropzoneIdle = document.getElementById('dropzoneIdle');
    if (dropzoneIdle) dropzoneIdle.style.display = 'block';
    const dropzonePreview = document.getElementById('dropzonePreview');
    if (dropzonePreview) dropzonePreview.style.display = 'none';
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
