<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="FoodZone - Đặt món ngon giao tận nơi trong 30 phút" />
</jsp:include>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container hero-wrapper">
        <div class="hero-text">
            <span class="hero-badge"><i class="fa-solid fa-sparkles"></i> Siêu Ứng Dụng Đặt Món Số 1</span>
            <h1 class="hero-title">
                Thèm Món Ngon Gì, <br>
                <span class="highlight-text">FoodZone Giao Tận Cửa!</span>
            </h1>
            <p class="hero-subtitle">
                Thưởng thức hàng trăm món ăn nóng hổi, chuẩn vị từ các nhà hàng uy tín. Giao siêu tốc chỉ từ 20-30 phút với ngập tràn ưu đãi mỗi ngày.
            </p>

            <!-- Search box in hero -->
            <form action="${pageContext.request.contextPath}/foods" method="GET" class="hero-search-box">
                <i class="fa-solid fa-location-dot hero-search-icon"></i>
                <input type="text" name="search" placeholder="Bạn muốn ăn món gì hôm nay? (Burger, Pizza, Trà sữa...)" class="hero-search-input">
                <button type="submit" class="btn btn-primary btn-hero">Tìm Món Ngay</button>
            </form>

            <!-- Key Features Pills -->
            <div class="hero-stats">
                <div class="stat-pill">
                    <i class="fa-solid fa-bolt text-primary"></i>
                    <div>
                        <strong>Giao 25-30 phút</strong>
                        <span>Món luôn nóng hổi</span>
                    </div>
                </div>
                <div class="stat-pill">
                    <i class="fa-solid fa-truck-fast text-primary"></i>
                    <div>
                        <strong>Freeship từ 99k</strong>
                        <span>Mã giảm mỗi ngày</span>
                    </div>
                </div>
                <div class="stat-pill">
                    <i class="fa-solid fa-shield-halved text-primary"></i>
                    <div>
                        <strong>An toàn 100%</strong>
                        <span>Chuẩn vệ sinh ATTP</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="hero-image-wrap">
            <div class="hero-circle-bg"></div>
            <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80" alt="Món ngon FoodZone" class="hero-main-img">
            
            <!-- Floating Floating Card 1 -->
            <div class="floating-badge badge-review">
                <div class="star-rating">
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                </div>
                <strong>4.9/5 Đánh giá</strong>
                <span>từ hơn 15.000 thực khách</span>
            </div>

            <!-- Floating Card 2 -->
            <div class="floating-badge badge-promo">
                <i class="fa-solid fa-percent promo-icon"></i>
                <div>
                    <strong>Giảm 30% Đơn Đầu</strong>
                    <span>Nhập mã: WELCOME</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Category Selection -->
<section class="section category-section">
    <div class="container">
        <div class="section-header text-center">
            <span class="sub-heading">Khám Phá Hương Vị</span>
            <h2 class="section-title">Danh Mục Món Ăn Nổi Bật</h2>
            <p class="section-desc">Lựa chọn các hương vị hấp dẫn phù hợp với sở thích của bạn</p>
        </div>

        <div class="category-grid">
            <a href="${pageContext.request.contextPath}/foods?cat=1" class="cat-card">
                <div class="cat-icon-box">🍔</div>
                <h3>Burger & Bánh Mì</h3>
                <span>12+ món</span>
            </a>
            <a href="${pageContext.request.contextPath}/foods?cat=1" class="cat-card">
                <div class="cat-icon-box">🍕</div>
                <h3>Pizza Nướng Củi</h3>
                <span>8+ món</span>
            </a>
            <a href="${pageContext.request.contextPath}/foods?cat=2" class="cat-card">
                <div class="cat-icon-box">🍗</div>
                <h3>Gà Rán Giòn Cay</h3>
                <span>10+ món</span>
            </a>
            <a href="${pageContext.request.contextPath}/foods?cat=1" class="cat-card">
                <div class="cat-icon-box">🍝</div>
                <h3>Mì Ý & Pasta</h3>
                <span>6+ món</span>
            </a>
            <a href="${pageContext.request.contextPath}/foods?cat=3" class="cat-card">
                <div class="cat-icon-box">🧋</div>
                <h3>Trà Sữa & Cafe</h3>
                <span>15+ món</span>
            </a>
            <a href="${pageContext.request.contextPath}/foods?cat=4" class="cat-card">
                <div class="cat-icon-box">🍚</div>
                <h3>Cơm & Phở Nóng</h3>
                <span>14+ món</span>
            </a>
        </div>
    </div>
</section>

<!-- Featured Foods Section -->
<section class="section bg-light-soft">
    <div class="container">
        <div class="section-header-flex">
            <div>
                <span class="sub-heading">Thực Đơn Đề Xuất</span>
                <h2 class="section-title">Món Ngon Bán Chạy Nhất</h2>
            </div>
            <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline">Xem tất cả món <i class="fa-solid fa-arrow-right"></i></a>
        </div>

        <div class="food-grid">
            <c:forEach items="${featuredFoods}" var="food">
                <div class="food-card">
                    <div class="food-card-img-wrap">
                        <span class="food-tag">Bán chạy</span>
                        <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}">
                            <img src="${food.image}" alt="${food.name}" class="food-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                        </a>
                        <div class="food-time-badge">
                            <i class="fa-solid fa-clock"></i> 20-25 phút
                        </div>
                    </div>
                    <div class="food-body">
                        <div class="food-meta">
                            <span class="food-rating"><i class="fa-solid fa-star"></i> 4.9 (120+)</span>
                            <span class="food-distance"><i class="fa-solid fa-motorcycle"></i> Giao nhanh</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/food-detail?id=${food.id}" class="food-title-link">
                            <h3 class="food-title">${food.name}</h3>
                        </a>
                        <p class="food-desc">${food.description}</p>
                        <div class="food-footer">
                            <div class="price-box">
                                <span class="price-label">Giá chỉ</span>
                                <span class="food-price">${String.format("%,.0f", food.price)} đ</span>
                            </div>
                            <form action="${pageContext.request.contextPath}/cart" method="POST" class="add-cart-form">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="foodId" value="${food.id}">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="btn-add-cart" title="Thêm vào giỏ hàng">
                                    <i class="fa-solid fa-cart-plus"></i>
                                    <span>Đặt món</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Promotional Banner -->
<section class="section">
    <div class="container">
        <div class="promo-banner">
            <div class="promo-content">
                <span class="promo-pill"><i class="fa-solid fa-gift"></i> Khuyến Mãi Trong Tuần</span>
                <h2>Giảm Ngay 30.000đ Cho Đơn Hàng Từ 150.000đ</h2>
                <p>Nhập mã ưu đãi <strong>FOODZONE30</strong> khi thanh toán để được trừ trực tiếp vào hóa đơn của bạn.</p>
                <div class="promo-action">
                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-lg">Khám Phá Món Ngon Ngay</a>
                </div>
            </div>
            <div class="promo-graphic">
                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80" alt="Ưu đãi pizza" class="promo-img">
            </div>
        </div>
    </div>
</section>

<!-- Why Choose Us -->
<section class="section bg-light-soft">
    <div class="container">
        <div class="section-header text-center">
            <span class="sub-heading">Cam Kết Chất Lượng</span>
            <h2 class="section-title">Tại Sao Nên Chọn FoodZone?</h2>
            <p class="section-desc">Chúng tôi nỗ lực mỗi ngày để đem đến trải nghiệm ẩm thực trọn vẹn nhất</p>
        </div>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fa-solid fa-bolt-lightning"></i>
                </div>
                <h3>Giao Hàng Siêu Tốc 30 Phút</h3>
                <p>Đội ngũ tài xế đông đảo cam kết giao món trong thời gian ngắn nhất, giữ trọn độ nóng sốt và hương vị.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fa-solid fa-kitchen-set"></i>
                </div>
                <h3>Đầu Bếp Tuyển Chọn</h3>
                <p>Liên kết cùng những nhà hàng và quán ăn được kiểm duyệt nghiêm ngặt về quy trình nấu nướng chuẩn vị.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fa-solid fa-shield-heart"></i>
                </div>
                <h3>100% Thực Phẩm Sạch</h3>
                <p>Nguyên liệu tươi mới mỗi ngày, bảo đảm an toàn vệ sinh thực phẩm theo quy chuẩn y tế nghiêm ngặt.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">
                    <i class="fa-solid fa-headset"></i>
                </div>
                <h3>Hỗ Trợ Tận Tâm 24/7</h3>
                <p>Đội ngũ chăm sóc khách hàng luôn sẵn sàng lắng nghe, giải quyết khiếu nại hoặc đổi món tức thì.</p>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
