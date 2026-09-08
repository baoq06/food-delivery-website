<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title != null ? param.title : "Utee - Đặt món ngon giao tận nơi trong 30 phút"}</title>
    <!-- Favicon -->
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/logo/logo-favicon.png">
    <!-- Google Fonts: Be Vietnam Pro (Font chuẩn 100% tiếng Việt từ font-weight 300 đến 900, không bị lỗi dấu hay nhảy font) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,600;1,700&display=swap" rel="stylesheet">
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Main CSS with Cache Busting -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp">
    <jsp:param name="isAuthPage" value="${param.isAuthPage}" />
</jsp:include>
<main class="main-content">
