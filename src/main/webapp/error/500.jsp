<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="500 - Đã Xảy Ra Lỗi Hệ Thống | FoodZone" />
</jsp:include>

<div class="error-page-wrapper">
    <div class="error-card">
        <div class="error-illustration">🍲⚠️</div>
        <div class="error-code-num">500</div>
        <h1 class="error-title">Rất Tiếc, Đã Xảy Ra Lỗi Máy Chủ!</h1>
        <p class="error-desc">
            Hệ thống FoodZone đang gặp trục trặc kỹ thuật tạm thời trong quá trình xử lý yêu cầu của bạn. Đội ngũ kỹ thuật đang nỗ lực khắc phục trong thời gian sớm nhất.
        </p>

        <div class="error-actions-group">
            <button type="button" onclick="location.reload()" class="btn btn-primary btn-lg">
                <i class="fa-solid fa-rotate-right"></i> Tải Lại Trang
            </button>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-outline btn-lg">
                <i class="fa-solid fa-house"></i> Về Trang Chủ
            </a>
        </div>

        <c:if test="${not empty pageContext.errorData.throwable or not empty pageContext.errorData.requestURI}">
            <details class="error-debug-details">
                <summary class="error-debug-summary"><i class="fa-solid fa-bug"></i> Thông tin kỹ thuật (Dành cho nhà phát triển)</summary>
                <div class="error-debug-content">
                    <p><strong>Status Code:</strong> ${pageContext.errorData.statusCode}</p>
                    <p><strong>Request URI:</strong> ${pageContext.errorData.requestURI}</p>
                    <c:if test="${not empty pageContext.errorData.throwable}">
                        <p><strong>Exception:</strong> ${pageContext.errorData.throwable.class.name}: ${pageContext.errorData.throwable.message}</p>
                    </c:if>
                </div>
            </details>
        </c:if>

        <div class="error-support-info">
            <span>Sự cố vẫn tiếp diễn? Liên hệ kỹ thuật viên qua Hotline: <a href="tel:19006886">1900 6886</a></span>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
