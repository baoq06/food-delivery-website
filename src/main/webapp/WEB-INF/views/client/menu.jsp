<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Thực Đơn Đa Dạng - Utee" />
</jsp:include>

<!-- Page Header & Bento Promo Banner -->
<div class="page-banner menu-page-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>Thực đơn</span>
        </div>

        <div class="menu-hero-bento">
            <div class="menu-hero-text">
                <div class="menu-hero-badge">
                    <i class="fa-solid fa-fire-flame-curved"></i> Thực Đơn Tuyển Chọn Utee
                </div>
                <h1 class="page-title">Khám Phá Món Ngon Hấp Dẫn</h1>
                <p class="page-desc">Hơn 100+ món ăn phong phú từ ẩm thực Á - Âu, trà sữa và ăn vặt giao siêu tốc trong 30 phút.</p>
            </div>

            <div class="menu-voucher-card">
                <div class="voucher-decor"><i class="fa-solid fa-ticket"></i></div>
                <div class="voucher-info">
                    <span class="voucher-tag">Ưu Đãi Đặc Biệt</span>
                    <div class="voucher-title">Giảm <strong>20.000 đ</strong> đơn từ 100K</div>
                    <div class="voucher-code-wrap">
                        <span class="voucher-code" id="menu-voucher-code">UTEE20</span>
                        <button type="button" class="btn-copy-voucher" data-code="UTEE20" title="Sao chép mã">
                            <i class="fa-solid fa-copy"></i> <span>Sao chép</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container section menu-section">
    <!-- Sticky Category Navigation Bar -->
    <div class="menu-category-sticky-wrap" id="menu-cat-sticky">
        <div class="menu-category-scroll">
            <button type="button" class="cat-pill-btn active" data-cat-id="all">
                <i class="fa-solid fa-utensils"></i>
                <span>Tất Cả Món</span>
            </button>
            <c:choose>
                <c:when test="${not empty categories}">
                    <c:forEach items="${categories}" var="cat">
                        <button type="button" class="cat-pill-btn ${param.cat eq cat.id ? 'active' : ''}" data-cat-id="${cat.id}">
                            <c:choose>
                                <c:when test="${cat.id eq 1}"><i class="fa-solid fa-bowl-rice"></i></c:when>
                                <c:when test="${cat.id eq 2}"><i class="fa-solid fa-bowl-food"></i></c:when>
                                <c:when test="${cat.id eq 3}"><i class="fa-solid fa-mug-hot"></i></c:when>
                                <c:when test="${cat.id eq 4}"><i class="fa-solid fa-burger"></i></c:when>
                                <c:otherwise><i class="fa-solid fa-utensils"></i></c:otherwise>
                            </c:choose>
                            <span>${cat.name}</span>
                        </button>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <button type="button" class="cat-pill-btn ${param.cat eq '1' ? 'active' : ''}" data-cat-id="1">
                        <i class="fa-solid fa-bowl-rice"></i> <span>Cơm &amp; Món Mặn</span>
                    </button>
                    <button type="button" class="cat-pill-btn ${param.cat eq '2' ? 'active' : ''}" data-cat-id="2">
                        <i class="fa-solid fa-bowl-food"></i> <span>Phở &amp; Bún Mì</span>
                    </button>
                    <button type="button" class="cat-pill-btn ${param.cat eq '3' ? 'active' : ''}" data-cat-id="3">
                        <i class="fa-solid fa-mug-hot"></i> <span>Trà Sữa &amp; Đồ Uống</span>
                    </button>
                    <button type="button" class="cat-pill-btn ${param.cat eq '4' ? 'active' : ''}" data-cat-id="4">
                        <i class="fa-solid fa-burger"></i> <span>Fastfood &amp; Ăn Vặt</span>
                    </button>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Smart Filter & Control Toolbar -->
    <div class="menu-toolbar-card mt-3">
        <div class="toolbar-top">
            <!-- Live Search Bar -->
            <div class="live-search-box">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="menu-live-search" placeholder="Tìm theo tên món ăn, quán ăn hoặc mô tả..." value="${param.search}" autocomplete="off">
                <button type="button" id="menu-search-clear" class="search-clear-btn ${empty param.search ? 'd-none' : ''}" title="Xóa tìm kiếm">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <!-- Sort Controls & View Switcher -->
            <div class="toolbar-actions">
                <div class="sort-select-wrap">
                    <label for="menu-sort-select"><i class="fa-solid fa-arrow-down-wide-short"></i> Sắp xếp:</label>
                    <select id="menu-sort-select" class="form-select-sm">
                        <option value="default">Phổ biến nhất</option>
                        <option value="price-asc">Giá: Thấp đến Cao</option>
                        <option value="price-desc">Giá: Cao đến Thấp</option>
                        <option value="name-asc">Tên món: A - Z</option>
                        <option value="rating-desc">Đánh giá cao nhất</option>
                    </select>
                </div>

                <div class="view-mode-switch" role="group" aria-label="Chế độ hiển thị">
                    <button type="button" class="view-btn active" id="view-grid-btn" data-view="grid" title="Chế độ xem lưới (Grid)">
                        <i class="fa-solid fa-grip"></i>
                    </button>
                    <button type="button" class="view-btn" id="view-list-btn" data-view="list" title="Chế độ xem danh sách (List)">
                        <i class="fa-solid fa-list-ul"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Price Range Chips -->
        <div class="toolbar-bottom">
            <span class="price-chip-label"><i class="fa-solid fa-filter"></i> Khoảng giá:</span>
            <div class="price-chips-list">
                <button type="button" class="price-chip active" data-price="all">Tất cả giá</button>
                <button type="button" class="price-chip" data-price="under35">&lt; 35.000 đ</button>
                <button type="button" class="price-chip" data-price="35to70">35.000 đ - 70.000 đ</button>
                <button type="button" class="price-chip" data-price="over70">&gt; 70.000 đ</button>
            </div>
            <div class="menu-stats-summary">
                <span id="menu-stats-text">Hiển thị <strong id="menu-visible-count">0</strong> món</span>
            </div>
        </div>
    </div>

    <!-- Food Cards Container -->
    <div class="food-grid mt-4" id="menu-food-container">
        <c:set var="displayFoods" value="${not empty allFoods ? allFoods : foods}" />
        <c:choose>
            <c:when test="${not empty displayFoods}">
                <c:forEach items="${displayFoods}" var="food" varStatus="status">
                    <div class="food-card"
                         data-id="${food.id}"
                         data-name="${food.name}"
                         data-category="${food.categoryId}"
                         data-price="${food.price}"
                         data-restaurant="${not empty food.restaurantName ? food.restaurantName : 'Quán đối tác Utee'}"
                         data-image="${food.image}"
                         data-desc="${food.description}"
                         data-rating="4.9"
                         data-index="${status.index}">

                        <div class="food-card-img-wrap">
                            <span class="food-tag"><c:out value="${not empty food.categoryName ? food.categoryName : 'Món ngon'}" /></span>
                            
                            <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}" class="food-img-link" title="Xem chi tiết ${food.name}">
                                <img src="${food.image}" alt="${food.name}" class="food-image" loading="lazy" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                            </a>

                            <div class="food-time-badge">
                                <i class="fa-solid fa-bolt text-warning"></i> 20-30 phút
                            </div>

                            <!-- Quick View Overlay Button -->
                            <button type="button" class="btn-quick-view" data-food-id="${food.id}" title="Xem nhanh món này">
                                <i class="fa-solid fa-eye"></i> Xem nhanh
                            </button>
                        </div>

                        <div class="food-body">
                            <div class="food-meta">
                                <span class="food-cat-badge"><c:out value="${not empty food.categoryName ? food.categoryName : 'Món ngon'}" /></span>
                                <span class="food-rating"><i class="fa-solid fa-star"></i> 4.9 (120+)</span>
                                <span class="food-distance" title="${not empty food.restaurantName ? food.restaurantName : 'Quán đối tác'}">
                                    <i class="fa-solid fa-store text-primary"></i> ${not empty food.restaurantName ? food.restaurantName : 'Quán đối tác'}
                                </span>
                            </div>

                            <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}" class="food-title-link">
                                <h3 class="food-title">${food.name}</h3>
                            </a>

                            <p class="food-desc">${food.description}</p>

                            <div class="food-footer">
                                <div class="price-box">
                                    <span class="price-label">Giá bán</span>
                                    <span class="food-price">${String.format("%,.0f", food.price)} đ</span>
                                </div>

                                <div class="food-actions-wrap">
                                    <!-- Direct AJAX Add to Cart Button -->
                                    <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form ajax-cart-form" data-food-id="${food.id}">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="foodId" value="${food.id}">
                                        <input type="hidden" name="quantity" value="1">
                                        <button type="submit" class="btn-add-cart btn-ajax-add" title="Thêm món này vào giỏ hàng">
                                            <i class="fa-solid fa-cart-plus"></i>
                                            <span>Đặt món</span>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state-card">
                    <div class="empty-state-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                    <h3>Chưa có món ăn nào trong thực đơn!</h3>
                    <p>Vui lòng quay lại sau hoặc liên hệ hỗ trợ.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Client-side Empty State for Filters -->
    <div id="menu-no-results" class="empty-state-card mt-4" style="display: none;">
        <div class="empty-state-icon"><i class="fa-solid fa-magnifying-glass-minus"></i></div>
        <h3>Không tìm thấy món ăn phù hợp!</h3>
        <p>Hãy thử thay đổi từ khóa tìm kiếm, chọn danh mục khác hoặc nới lỏng khoảng giá.</p>
        <button type="button" id="btn-reset-filters" class="btn btn-primary mt-3">
            <i class="fa-solid fa-rotate-left"></i> Xóa Tất Cả Bộ Lọc
        </button>
    </div>
</div>

<!-- Quick View Modal (Popup xem nhanh thông minh) -->
<div id="quick-view-modal" class="qv-modal-overlay" aria-hidden="true">
    <div class="qv-modal-card" role="dialog" aria-modal="true" aria-labelledby="qv-modal-title">
        <button type="button" class="qv-modal-close" id="qv-close-btn" aria-label="Đóng cửa sổ">
            <i class="fa-solid fa-xmark"></i>
        </button>

        <div class="qv-modal-grid">
            <div class="qv-image-side">
                <img id="qv-food-image" src="" alt="Food Preview" class="qv-main-img">
                <span id="qv-food-tag" class="qv-badge-tag">Món Ngon</span>
                <div class="qv-img-badge">
                    <i class="fa-solid fa-clock"></i> Giao 20-30 phút
                </div>
            </div>

            <div class="qv-content-side">
                <div class="qv-meta-top">
                    <span class="qv-store-name"><i class="fa-solid fa-store text-primary"></i> <span id="qv-food-store">Quán đối tác</span></span>
                    <span class="qv-rating"><i class="fa-solid fa-star"></i> 4.9 (120+ đánh giá)</span>
                </div>

                <h2 id="qv-modal-title" class="qv-food-title">Tên món ăn</h2>

                <p id="qv-food-desc" class="qv-food-desc">Mô tả chi tiết món ăn...</p>

                <div class="qv-price-row">
                    <div class="qv-price-wrap">
                        <span class="qv-price-label">Đơn giá:</span>
                        <span id="qv-food-price" class="qv-price-value">0 đ</span>
                    </div>
                    <div class="qv-badge-fresh">
                        <i class="fa-solid fa-shield-halved"></i> Đảm bảo tươi nóng
                    </div>
                </div>

                <div class="qv-qty-row">
                    <span class="qv-qty-label">Chọn số lượng:</span>
                    <div class="qv-qty-stepper">
                        <button type="button" id="qv-qty-minus" class="qty-btn" aria-label="Giảm"><i class="fa-solid fa-minus"></i></button>
                        <input type="number" id="qv-qty-input" value="1" min="1" max="99" readonly>
                        <button type="button" id="qv-qty-plus" class="qty-btn" aria-label="Tăng"><i class="fa-solid fa-plus"></i></button>
                    </div>
                </div>

                <div class="qv-subtotal-box">
                    <span>Tổng tiền tạm tính:</span>
                    <strong id="qv-subtotal-price">0 đ</strong>
                </div>

                <div class="qv-actions">
                    <button type="button" id="qv-add-cart-btn" class="btn btn-primary btn-qv-add">
                        <i class="fa-solid fa-cart-plus"></i>
                        <span>Thêm Vào Giỏ Hàng</span>
                    </button>
                    <a id="qv-detail-link" href="#" class="btn btn-outline btn-qv-detail">
                        <span>Chi tiết đầy đủ</span>
                        <i class="fa-solid fa-arrow-up-right-from-square"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Floating Bottom Mini-Cart Bar (Ghim đáy màn hình khi có món) -->
<c:set var="hasCart" value="${not empty sessionScope.cart and sessionScope.cart.size() > 0}" />
<div id="floating-mini-cart" class="floating-mini-cart ${hasCart ? 'show' : ''}">
    <div class="container floating-mini-cart-inner">
        <div class="fmc-left">
            <div class="fmc-icon-wrap">
                <i class="fa-solid fa-bag-shopping"></i>
                <span class="fmc-badge" id="fmc-badge-count">
                    <c:choose>
                        <c:when test="${hasCart}">${sessionScope.cart.size()}</c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="fmc-info">
                <div class="fmc-title">Giỏ hàng của bạn (<span id="fmc-item-count">${hasCart ? sessionScope.cart.size() : 0}</span> món)</div>
                <div class="fmc-subtext">Đã sẵn sàng giao siêu tốc tận nơi</div>
            </div>
        </div>

        <div class="fmc-right">
            <div class="fmc-total-wrap">
                <span class="fmc-total-label">Tổng thanh toán:</span>
                <strong class="fmc-total-amount" id="fmc-total-price">
                    <c:choose>
                        <c:when test="${hasCart}">
                            <c:set var="cartTotal" value="0" />
                            <c:forEach items="${sessionScope.cart.values()}" var="item">
                                <c:set var="cartTotal" value="${cartTotal + item.totalPrice}" />
                            </c:forEach>
                            ${String.format("%,.0f", cartTotal)} đ
                        </c:when>
                        <c:otherwise>0 đ</c:otherwise>
                    </c:choose>
                </strong>
            </div>
            <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary fmc-btn-checkout">
                <span>Xem Giỏ &amp; Đặt Hàng</span>
                <i class="fa-solid fa-arrow-right"></i>
            </a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
