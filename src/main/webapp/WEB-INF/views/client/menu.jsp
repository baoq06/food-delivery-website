<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Thực Đơn Đa Dạng - Utee" />
</jsp:include>

<!-- Page Header Banner -->
<div class="page-banner">
    <div class="container page-banner-inner">
        <div class="breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <i class="fa-solid fa-chevron-right"></i>
            <span>Thực đơn</span>
        </div>
        <h1 class="page-title">Khám Phá Toàn Bộ Thực Đơn</h1>
        <p class="page-desc">Hơn 100+ món ăn ngon từ ẩm thực Á - Âu, trà sữa và thức ăn nhanh giao siêu tốc 30 phút cùng Utee</p>
    </div>
</div>

<div class="container section">
    <!-- Filter & Search Controls -->
    <div class="menu-controls-wrapper">
        <div class="category-tabs">
            <a href="${pageContext.request.contextPath}/foods" class="cat-tab ${empty param.cat ? 'active' : ''}">
                <i class="fa-solid fa-utensils"></i> Tất Cả
            </a>
            <c:choose>
                <c:when test="${not empty categories}">
                    <c:forEach items="${categories}" var="cat">
                        <a href="${pageContext.request.contextPath}/foods?cat=${cat.id}" class="cat-tab ${param.cat eq cat.id ? 'active' : ''}">
                            <c:choose>
                                <c:when test="${cat.id eq 1}"><i class="fa-solid fa-bowl-rice"></i></c:when>
                                <c:when test="${cat.id eq 2}"><i class="fa-solid fa-bowl-food"></i></c:when>
                                <c:when test="${cat.id eq 3}"><i class="fa-solid fa-mug-hot"></i></c:when>
                                <c:when test="${cat.id eq 4}"><i class="fa-solid fa-burger"></i></c:when>
                                <c:otherwise><i class="fa-solid fa-utensils"></i></c:otherwise>
                            </c:choose>
                            ${cat.name}
                        </a>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/foods?cat=1" class="cat-tab ${param.cat eq '1' ? 'active' : ''}">
                        <i class="fa-solid fa-bowl-rice"></i> Cơm & Món Mặn
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=2" class="cat-tab ${param.cat eq '2' ? 'active' : ''}">
                        <i class="fa-solid fa-bowl-food"></i> Phở & Bún Mì
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=3" class="cat-tab ${param.cat eq '3' ? 'active' : ''}">
                        <i class="fa-solid fa-mug-hot"></i> Trà Sữa & Đồ Uống
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=4" class="cat-tab ${param.cat eq '4' ? 'active' : ''}">
                        <i class="fa-solid fa-burger"></i> Fastfood & Ăn Vặt
                    </a>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="menu-search-bar">
            <form action="${pageContext.request.contextPath}/foods" method="GET" class="inner-search-form">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" name="search" placeholder="Tìm kiếm món trong thực đơn..." value="${param.search}">
                <button type="submit" class="btn btn-primary btn-sm">Tìm kiếm</button>
            </form>
        </div>
    </div>

    <!-- Food Cards Grid -->
    <div class="food-grid mt-4">
        <c:choose>
            <c:when test="${not empty foods}">
                <c:forEach items="${foods}" var="food">
                    <div class="food-card">
                        <div class="food-card-img-wrap">
                            <span class="food-tag"><c:out value="${not empty food.categoryName ? food.categoryName : 'Món ngon'}" /></span>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}">
                                <img src="${food.image}" alt="${food.name}" class="food-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                            </a>
                            <div class="food-time-badge">
                                <i class="fa-solid fa-clock"></i> 20-30 phút
                            </div>
                        </div>
                        <div class="food-body">
                            <div class="food-meta">
                                <span class="food-rating"><i class="fa-solid fa-star"></i> 4.9 (100+)</span>
                                <span class="food-distance"><i class="fa-solid fa-store text-primary"></i> ${not empty food.restaurantName ? food.restaurantName : 'Quán đối tác'}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}" class="food-title-link">
                                <h3 class="food-title">${food.name}</h3>
                            </a>
                            <p class="food-desc">${food.description}</p>
                            <div class="food-footer">
                                <div class="price-box">
                                    <span class="price-label">Giá</span>
                                    <span class="food-price">${String.format("%,.0f", food.price)} đ</span>
                                </div>
                                <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="foodId" value="${food.id}">
                                    <input type="hidden" name="quantity" value="1">
                                    <button type="submit" class="btn-add-cart" title="Thêm vào giỏ">
                                        <i class="fa-solid fa-cart-plus"></i>
                                        <span>Đặt món</span>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state-card">
                    <div class="empty-state-icon"><i class="fa-solid fa-plate-wheat"></i></div>
                    <h3>Không tìm thấy món ăn nào!</h3>
                    <p>Hãy thử tìm với từ khóa khác hoặc quay lại xem toàn bộ thực đơn.</p>
                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary mt-3">Xem Tất Cả Món</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
