<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Utee - Đặt món ngon giao tận nơi trong 30 phút" />
</jsp:include>

<!-- Hero Section -->
<section class="hero-section">
    <div class="hero-ambient-glow"></div>
    <div class="container hero-wrapper">
        <div class="hero-text">
            <div class="hero-badge-wrap">
                <span class="hero-badge"><i class="fa-solid fa-fire-flame-curved"></i> Siêu Ứng Dụng Đặt Món Số 1 • Giao Siêu Tốc 30 Phút</span>
            </div>
            <h1 class="hero-title">
                Thèm Món Ngon Gì, <br>
                <span class="hero-gradient-text">Utee</span> Giao Nóng Tận Cửa!
            </h1>
            <p class="hero-subtitle">
                Thưởng thức hàng trăm món ăn nóng hổi, chuẩn vị từ các nhà hàng uy tín hàng đầu. Giao siêu tốc 20-30 phút, bảo đảm chất lượng với ngập tràn ưu đãi mỗi ngày.
            </p>

            <!-- Search box in hero -->
            <form action="${pageContext.request.contextPath}/foods" method="GET" class="hero-search-box">
                <div class="search-loc-pill">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>TP. Thủ Đức</span>
                </div>
                <div class="search-divider"></div>
                <input type="text" name="search" placeholder="Bạn muốn ăn món gì hôm nay?" class="hero-search-input">
                <button type="submit" class="btn btn-primary btn-hero">
                    <span>Tìm Món</span>
                    <i class="fa-solid fa-arrow-right"></i>
                </button>
            </form>

            <!-- Quick Suggestion Tags -->
            <div class="hero-quick-tags">
                <span class="quick-label"><i class="fa-solid fa-fire text-primary"></i> Đang hot:</span>
                <a href="${pageContext.request.contextPath}/foods?search=cơm" class="quick-chip">Cơm sườn</a>
                <a href="${pageContext.request.contextPath}/foods?search=phở" class="quick-chip">Phở bò</a>
                <a href="${pageContext.request.contextPath}/foods?search=trà+sữa" class="quick-chip">Trà sữa</a>
                <a href="${pageContext.request.contextPath}/foods?search=burger" class="quick-chip">Burger giòn</a>
                <a href="${pageContext.request.contextPath}/foods?search=pizza" class="quick-chip">Pizza</a>
            </div>

            <!-- Key Features Pills -->
            <div class="hero-stats">
                <div class="stat-pill">
                    <div class="stat-icon-circle">
                        <i class="fa-solid fa-bolt text-primary"></i>
                    </div>
                    <div>
                        <strong>Giao 20-30 phút</strong>
                        <span>Món luôn nóng hổi</span>
                    </div>
                </div>
                <div class="stat-pill">
                    <div class="stat-icon-circle">
                        <i class="fa-solid fa-truck-fast text-primary"></i>
                    </div>
                    <div>
                        <strong>Freeship từ 99k</strong>
                        <span>Mã giảm mỗi ngày</span>
                    </div>
                </div>
                <div class="stat-pill">
                    <div class="stat-icon-circle">
                        <i class="fa-solid fa-shield-halved text-primary"></i>
                    </div>
                    <div>
                        <strong>An toàn 100%</strong>
                        <span>Chuẩn vệ sinh ATTP</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="hero-image-wrap">
            <div class="hero-circle-bg"></div>
            <div class="hero-img-container">
                <img src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80" alt="Món ngon Utee" class="hero-main-img">
            </div>
            
            <!-- Floating Driver Tracker Card -->
            <div class="floating-badge badge-tracker">
                <div class="pulsing-radar">
                    <span class="radar-dot"></span>
                </div>
                <div class="tracker-info">
                    <strong>Tài xế đang giao...</strong>
                    <span>Dự kiến: 18 phút • Nóng hổi</span>
                </div>
                <div class="tracker-icon">
                    <i class="fa-solid fa-motorcycle"></i>
                </div>
            </div>

            <!-- Floating Review Card -->
            <div class="floating-badge badge-review">
                <div class="star-rating">
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                </div>
                <strong>4.9/5 Đánh giá</strong>
                <span>từ 25.000+ thực khách</span>
            </div>

            <!-- Floating Promo Card -->
            <div class="floating-badge badge-promo">
                <div class="promo-icon"><i class="fa-solid fa-ticket"></i></div>
                <div>
                    <strong>Giảm 30K Đơn Đầu</strong>
                    <span>Nhập mã: <strong>VINDELI30</strong></span>
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
            <c:choose>
                <c:when test="${not empty categories}">
                    <c:forEach items="${categories}" var="cat">
                        <a href="${pageContext.request.contextPath}/foods?cat=${cat.id}" class="cat-card">
                            <div class="cat-icon-box">
                                <c:choose>
                                    <c:when test="${cat.id eq 1}"><i class="fa-solid fa-bowl-rice"></i></c:when>
                                    <c:when test="${cat.id eq 2}"><i class="fa-solid fa-bowl-food"></i></c:when>
                                    <c:when test="${cat.id eq 3}"><i class="fa-solid fa-mug-hot"></i></c:when>
                                    <c:when test="${cat.id eq 4}"><i class="fa-solid fa-burger"></i></c:when>
                                    <c:otherwise><i class="fa-solid fa-utensils"></i></c:otherwise>
                                </c:choose>
                            </div>
                            <h3>${cat.name}</h3>
                            <span>${not empty cat.description ? cat.description : 'Món ngon nổi bật'}</span>
                        </a>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/foods?cat=1" class="cat-card">
                        <div class="cat-icon-box"><i class="fa-solid fa-bowl-rice"></i></div>
                        <h3>Cơm & Món Mặn</h3>
                        <span>Món Việt chuẩn vị</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=2" class="cat-card">
                        <div class="cat-icon-box"><i class="fa-solid fa-bowl-food"></i></div>
                        <h3>Phở & Bún Mì</h3>
                        <span>Hương vị truyền thống</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=3" class="cat-card">
                        <div class="cat-icon-box"><i class="fa-solid fa-mug-hot"></i></div>
                        <h3>Trà Sữa & Đồ Uống</h3>
                        <span>Tươi mát sảng khoái</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/foods?cat=4" class="cat-card">
                        <div class="cat-icon-box"><i class="fa-solid fa-burger"></i></div>
                        <h3>Fastfood & Ăn Vặt</h3>
                        <span>Giòn ngon hấp dẫn</span>
                    </a>
                </c:otherwise>
            </c:choose>
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
                        <span class="food-tag"><c:out value="${not empty food.categoryName ? food.categoryName : 'Bán chạy'}" /></span>
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
                            <span class="food-distance"><i class="fa-solid fa-store text-primary"></i> ${not empty food.restaurantName ? food.restaurantName : 'Quán đối tác'}</span>
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

<!-- Recently Viewed Section -->
<c:if test="${not empty recentFoods}">
    <section class="section">
        <div class="container">
            <div class="section-header-flex">
                <div>
                    <span class="sub-heading"><i class="fa-solid fa-clock-rotate-left"></i> Dành Riêng Cho Bạn</span>
                    <h2 class="section-title">Món Bạn Đã Xem Gần Đây</h2>
                </div>
            </div>

            <div class="food-grid">
                <c:forEach items="${recentFoods}" var="rFood">
                    <div class="food-card">
                        <div class="food-card-img-wrap">
                            <span class="food-tag">${not empty rFood.categoryName ? rFood.categoryName : 'Vừa xem'}</span>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}">
                                <img src="${rFood.image}" alt="${rFood.name}" class="food-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'">
                            </a>
                        </div>
                        <div class="food-body">
                            <div class="food-meta">
                                <span class="food-rating"><i class="fa-solid fa-star"></i> 4.9</span>
                                <span class="food-distance"><i class="fa-solid fa-store text-primary"></i> ${not empty rFood.restaurantName ? rFood.restaurantName : 'Quán đối tác'}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}" class="food-title-link">
                                <h3 class="food-title">${rFood.name}</h3>
                            </a>
                            <div class="food-footer">
                                <div class="price-box">
                                    <span class="price-label">Giá</span>
                                    <span class="food-price">${String.format("%,.0f", rFood.price)} đ</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/food-detail?id=${rFood.id}" class="btn btn-outline btn-sm">Xem lại</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>
</c:if>

<!-- Promotional Banner -->
<section class="section">
    <div class="container">
        <div class="promo-banner">
            <div class="promo-content">
                <span class="promo-pill"><i class="fa-solid fa-gift"></i> ƯU ĐÃI ĐỘC QUYỀN UTEE</span>
                <h2>Giảm Ngay 30.000đ Cho Đơn Hàng Từ 150.000đ</h2>
                <p>Thỏa sức đặt món ngon Á - Âu nóng hổi mỗi ngày. Nhập mã voucher độc quyền bên dưới khi thanh toán để được giảm ngay 30K!</p>
                
                <div class="voucher-copy-card">
                    <div class="voucher-code-tag">
                        <i class="fa-solid fa-ticket"></i>
                        <span id="voucherHomeCode">UTEE30</span>
                    </div>
                    <button type="button" class="btn-copy-voucher" onclick="navigator.clipboard.writeText('UTEE30'); window.showToast('✨ Đã sao chép mã UTEE30! Dán vào giỏ hàng ngay.');">
                        <i class="fa-regular fa-copy"></i> Sao Chép Mã
                    </button>
                </div>

                <div class="promo-action mt-3">
                    <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-lg">Khám Phá Món Ngon Ngay <i class="fa-solid fa-arrow-right"></i></a>
                </div>
            </div>
            <div class="promo-graphic">
                <img src="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80" alt="Ưu đãi pizza Utee" class="promo-img">
            </div>
        </div>
    </div>
</section>

<!-- Why Choose Us -->
<section class="section bg-light-soft">
    <div class="container">
        <div class="section-header text-center">
            <span class="sub-heading">Cam Kết Chất Lượng</span>
            <h2 class="section-title">Tại Sao Nên Chọn Utee?</h2>
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
