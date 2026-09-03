<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Bảng Quản Trị Admin" />
</jsp:include>

<div class="container section">
    <h1>Bảng Điều Khiển Quản Trị</h1>
    <p>Chào mừng Admin: <strong>${sessionScope.currentUser.fullName}</strong></p>
    
    <div class="admin-grid">
        <div class="stat-card">
            <h3>Tổng Món Ăn</h3>
            <p class="stat-number">24</p>
        </div>
        <div class="stat-card">
            <h3>Đơn Hàng Mới</h3>
            <p class="stat-number">8</p>
        </div>
        <div class="stat-card">
            <h3>Người Dùng</h3>
            <p class="stat-number">150</p>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
