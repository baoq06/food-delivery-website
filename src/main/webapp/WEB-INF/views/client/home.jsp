<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Trang chủ - Food Delivery" />
</jsp:include>

<section class="hero-section">
    <div class="hero-content">
        <h1>Giao Món Ngon Tận Cửa Trong 30 Phút</h1>
        <p>Hàng ngàn món ăn nóng hổi, đa dạng từ các nhà hàng uy tín đang chờ đón bạn.</p>
        <a href="${pageContext.request.contextPath}/foods" class="btn btn-primary btn-lg">Khám phá thực đơn ngay</a>
    </div>
</section>

<section class="container section">
    <h2 class="section-title">Món Ăn Nổi Bật</h2>
    <div class="food-grid">
        <c:choose>
            <c:when test="${not empty featuredFoods}">
                <c:forEach items="${featuredFoods}" var="food">
                    <div class="food-card">
                        <img src="${food.image}" alt="${food.name}" class="food-image">
                        <div class="food-body">
                            <h3 class="food-title">${food.name}</h3>
                            <p class="food-desc">${food.description}</p>
                            <div class="food-footer">
                                <span class="food-price">${food.price} đ</span>
                                <form action="${pageContext.request.contextPath}/cart" method="POST">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="foodId" value="${food.id}">
                                    <input type="hidden" name="quantity" value="1">
                                    <button type="submit" class="btn btn-sm btn-accent">+ Giỏ hàng</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <p>Chưa có món ăn nào được tải từ database. Hãy cấu hình CSDL trong <code>db.properties</code>!</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
