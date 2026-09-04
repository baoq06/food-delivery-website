<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="404 - Không Tìm Thấy Trang | FoodZone" />
</jsp:include>

<div class="error-page-wrapper">
    <div class="error-card">
        <div class="error-illustration">🍽️🔍</div>
        <div class="error-code-num">404</div>
        <h1 class="error-title">Không Tìm Thấy Trang Món Ngon!</h1>
        <p class="error-desc">
            Trang bạn đang tìm kiếm có thể đã bị đổi tên, bị gỡ bỏ hoặc đường dẫn không chính xác. Đừng lo lắng, hãy để FoodZone dẫn bạn đến những món ngon nóng hổi khác!
        </p>

        <div class="error-actions-group">
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary btn-lg">
                <i class="fa-solid fa-house"></i> Về Trang Chủ
            </a>
            <a href="${pageContext.request.contextPath}/foods" class="btn btn-outline btn-lg">
                <i class="fa-solid fa-utensils"></i> Khám Phá Thực Đơn
            </a>
        </div>

        <div class="error-support-info">
            <span>Cần trợ giúp đặt món? Gọi ngay Hotline: <a href="tel:19006886">1900 6886</a> (Hỗ trợ 24/7)</span>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
