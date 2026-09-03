<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar">
    <div class="nav-container">
        <a href="${pageContext.request.contextPath}/home" class="brand-logo">
            🍔 Food<span>Delivery</span>
        </a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/home">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/foods">Thực đơn</a></li>
            <li><a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a></li>
        </ul>
        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.currentUser}">
                    <span class="user-greeting">Xin chào, <strong>${sessionScope.currentUser.fullName}</strong></span>
                    <c:if test="${sessionScope.currentUser.role eq 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-sm btn-outline">Quản trị</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-sm btn-danger">Đăng xuất</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-sm btn-primary">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>
