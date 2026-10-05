<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Trung Tâm Thông Báo - Utee Express" />
</jsp:include>

<style>
    /* Notifications Pro Max Styles */
    .notif-hero-banner {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        color: #ffffff;
        padding: 36px 0 32px 0;
        margin-bottom: 30px;
    }
    .notif-breadcrumb {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.88rem;
        color: #94a3b8;
        margin-bottom: 8px;
    }
    .notif-breadcrumb a {
        color: #cbd5e1;
        text-decoration: none;
        transition: color 0.2s ease;
    }
    .notif-breadcrumb a:hover {
        color: #f05454;
    }
    .notif-page-title {
        font-size: 1.85rem;
        font-weight: 800;
        margin: 0;
        letter-spacing: -0.5px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    /* Container & Filter Bar */
    .notif-main-container {
        max-width: 960px;
        margin: 0 auto 60px auto;
    }
    .notif-toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 16px;
        margin-bottom: 24px;
        background: #ffffff;
        padding: 16px 20px;
        border-radius: 16px;
        border: 1px solid #f1f5f9;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
    }
    .notif-filter-pills {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .notif-pill {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 50px;
        font-size: 0.88rem;
        font-weight: 600;
        text-decoration: none;
        color: #64748b;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        transition: all 0.2s ease;
    }
    .notif-pill:hover {
        background: #fff5f5;
        color: #f05454;
        border-color: #fecaca;
    }
    .notif-pill.active {
        background: #f05454;
        color: #ffffff;
        border-color: #f05454;
        box-shadow: 0 4px 12px rgba(240, 84, 84, 0.25);
    }
    .notif-actions-right {
        display: flex;
        align-items: center;
        gap: 10px;
    }
    .btn-mark-all-read {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 50px;
        font-size: 0.85rem;
        font-weight: 700;
        background: #f1f5f9;
        color: #334155;
        border: none;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .btn-mark-all-read:hover {
        background: #e2e8f0;
        color: #0f172a;
        transform: translateY(-1px);
    }

    /* Notification List & Item Cards */
    .notif-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .notif-card {
        display: flex;
        align-items: center;
        gap: 16px;
        background: #ffffff;
        border-radius: 16px;
        padding: 16px 20px;
        border: 1px solid #f1f5f9;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        cursor: pointer;
    }
    .notif-card:hover {
        border-color: #fca5a5;
        box-shadow: 0 8px 24px rgba(240, 84, 84, 0.09);
        transform: translateY(-2px);
    }
    .notif-card.unread {
        background: #fffafa;
        border-color: #fee2e2;
        border-left: 5px solid #f05454;
    }
    .notif-card.unread:hover {
        background: #fff5f5;
        border-color: #f87171;
    }
    .notif-icon-circle {
        width: 46px;
        height: 46px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.3rem;
        flex-shrink: 0;
        background: #f8fafc;
        border: 1px solid #f1f5f9;
    }
    .notif-card.unread .notif-icon-circle {
        background: #ffffff;
        box-shadow: 0 4px 12px rgba(240, 84, 84, 0.15);
    }
    .notif-body {
        flex: 1;
        min-width: 0;
    }
    .notif-title-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        margin-bottom: 4px;
    }
    .notif-title {
        font-size: 0.98rem;
        font-weight: 800;
        color: #1e293b;
        margin: 0;
        line-height: 1.35;
    }
    .notif-time {
        font-size: 0.8rem;
        color: #94a3b8;
        font-weight: 500;
        white-space: nowrap;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    .notif-message {
        font-size: 0.9rem;
        color: #475569;
        line-height: 1.5;
        margin: 0;
    }
    .notif-card-actions {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-left: 8px;
        flex-shrink: 0;
    }
    .btn-notif-delete-circle {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        color: #94a3b8;
        font-size: 0.95rem;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        flex-shrink: 0;
    }
    .btn-notif-delete-circle:hover {
        background: #fee2e2;
        border-color: #fca5a5;
        color: #ef4444;
        transform: scale(1.08);
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
    }
    .btn-notif-delete-circle:active {
        transform: scale(0.95);
    }
    .unread-indicator-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #f05454;
        display: inline-block;
        margin-left: 6px;
    }

    /* Empty State */
    .notif-empty-box {
        text-align: center;
        padding: 60px 20px;
        background: #ffffff;
        border-radius: 20px;
        border: 1px dashed #cbd5e1;
    }
    .notif-empty-icon {
        font-size: 3.5rem;
        color: #cbd5e1;
        margin-bottom: 16px;
    }
</style>

<!-- Hero Banner -->
<div class="notif-hero-banner">
    <div class="container">
        <div class="notif-breadcrumb">
            <a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Trang chủ</a>
            <i class="fa-solid fa-chevron-right" style="font-size: 0.72rem;"></i>
            <span>Thông báo</span>
        </div>
        <h1 class="notif-page-title">
            <i class="fa-solid fa-bell" style="color: #f05454;"></i>
            <span>Trung Tâm Thông Báo</span>
            <c:if test="${unreadCount > 0}">
                <span class="badge" style="font-size: 0.85rem; background: #fee2e2; color: #dc2626; border-radius: 50px; padding: 4px 12px;">
                    ${unreadCount} chưa đọc
                </span>
            </c:if>
        </h1>
    </div>
</div>

<div class="container notif-main-container">
    <!-- Feedback Alerts -->
    <c:if test="${not empty sessionScope.flashMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius: 12px; margin-bottom: 20px;">
            <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.flashMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
        <c:remove var="flashMessage" scope="session" />
    </c:if>

    <!-- Toolbar: Filters & Actions -->
    <div class="notif-toolbar">
        <div class="notif-filter-pills">
            <a href="${pageContext.request.contextPath}/notifications?filter=ALL" class="notif-pill ${currentFilter eq 'ALL' ? 'active' : ''}">
                <i class="fa-solid fa-layer-group"></i> Tất cả
            </a>
            <a href="${pageContext.request.contextPath}/notifications?filter=UNREAD" class="notif-pill ${currentFilter eq 'UNREAD' ? 'active' : ''}">
                <i class="fa-solid fa-envelope"></i> Chưa đọc
                <c:if test="${unreadCount > 0}">
                    <span style="background: rgba(255,255,255,0.3); padding: 1px 6px; border-radius: 10px; font-size: 0.75rem;">${unreadCount}</span>
                </c:if>
            </a>
            <a href="${pageContext.request.contextPath}/notifications?filter=ORDER" class="notif-pill ${currentFilter eq 'ORDER' ? 'active' : ''}">
                <i class="fa-solid fa-receipt"></i> Đơn hàng
            </a>
            <a href="${pageContext.request.contextPath}/notifications?filter=SYSTEM" class="notif-pill ${currentFilter eq 'SYSTEM' ? 'active' : ''}">
                <i class="fa-solid fa-circle-info"></i> Hệ thống
            </a>
        </div>

        <div class="notif-actions-right">
            <c:if test="${unreadCount > 0}">
                <form action="${pageContext.request.contextPath}/notifications" method="POST" style="margin: 0;">
                    <input type="hidden" name="action" value="markAllAsRead" />
                    <button type="submit" class="btn-mark-all-read">
                        <i class="fa-solid fa-check-double text-success"></i> Đánh dấu đã đọc tất cả
                    </button>
                </form>
            </c:if>
        </div>
    </div>

    <!-- Notifications List -->
    <c:choose>
        <c:when test="${not empty notifications}">
            <div class="notif-list">
                <c:forEach var="n" items="${notifications}">
                    <c:set var="targetLink" value="" />
                    <c:if test="${not empty n.link}">
                        <c:choose>
                            <c:when test="${n.link.startsWith('/')}">
                                <c:set var="targetLink" value="${pageContext.request.contextPath}${n.link}" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="targetLink" value="${pageContext.request.contextPath}/${n.link}" />
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                    <div class="notif-card ${n.read ? 'read' : 'unread'}"
                         data-id="${n.id}"
                         data-link="${targetLink}"
                         data-read="${n.read}"
                         onclick="handleNotifCardClick(this)"
                         role="button"
                         tabindex="0"
                         title="Nhấn để xem chi tiết">
                        <!-- Icon Circle -->
                        <div class="notif-icon-circle">
                            <i class="${n.iconClass}"></i>
                        </div>

                        <!-- Content Body -->
                        <div class="notif-body">
                            <div class="notif-title-row">
                                <h3 class="notif-title">
                                    ${n.title}
                                    <c:if test="${not n.read}">
                                        <span class="unread-indicator-dot" title="Chưa đọc"></span>
                                    </c:if>
                                </h3>
                                <span class="notif-time">
                                    <i class="fa-regular fa-clock"></i> ${n.timeAgo}
                                </span>
                            </div>

                            <p class="notif-message">${n.message}</p>
                        </div>

                        <!-- Delete Button (Circular Icon) on the right -->
                        <div class="notif-card-actions">
                            <form action="${pageContext.request.contextPath}/notifications" method="POST" style="display:inline; margin:0;" onsubmit="return confirm('Bạn có chắc muốn xóa thông báo này?');" onclick="event.stopPropagation();">
                                <input type="hidden" name="action" value="delete" />
                                <input type="hidden" name="id" value="${n.id}" />
                                <button type="submit" class="btn-notif-delete-circle" title="Xóa thông báo" onclick="event.stopPropagation();">
                                    <i class="fa-regular fa-trash-can"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>

        <c:otherwise>
            <div class="notif-empty-box">
                <div class="notif-empty-icon">
                    <i class="fa-regular fa-bell-slash"></i>
                </div>
                <h4 style="font-weight: 800; color: #1e293b; margin-bottom: 8px;">Không có thông báo nào</h4>
                <p style="color: #64748b; font-size: 0.95rem; margin-bottom: 20px;">
                    <c:choose>
                        <c:when test="${currentFilter eq 'UNREAD'}">Bạn đã đọc hết tất cả thông báo rồi!</c:when>
                        <c:otherwise>Tất cả các thông báo liên quan đến đơn hàng và tài xế sẽ xuất hiện tại đây.</c:otherwise>
                    </c:choose>
                </p>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-primary" style="border-radius: 50px; padding: 10px 24px; font-weight: 700;">
                    <i class="fa-solid fa-house me-1"></i> Về trang chủ
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
function handleNotifCardClick(cardEl) {
    var notifId = cardEl.getAttribute('data-id');
    var linkUrl = cardEl.getAttribute('data-link');
    var isRead = cardEl.getAttribute('data-read') === 'true';

    if (!isRead && notifId) {
        // Gửi request mark-read trong background
        fetch('${pageContext.request.contextPath}/api/notifications/mark-read?id=' + notifId)
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.success) {
                    var count = data.unreadCount || 0;
                    var badge = document.getElementById('navNotifBadge');
                    var dropBadge = document.getElementById('dropdownNotifBadge');
                    var popBadge = document.getElementById('popoverUnreadBadge');
                    [badge, dropBadge, popBadge].forEach(function(el) {
                        if (el) {
                            if (count > 0) {
                                el.innerText = count > 99 ? '99+' : count;
                                el.style.display = 'inline-flex';
                            } else {
                                el.style.display = 'none';
                                el.classList.remove('has-unread');
                            }
                        }
                    });
                }
            })
            .catch(function(err) {});
    }

    if (linkUrl && linkUrl.trim() !== '') {
        window.location.href = linkUrl;
    } else {
        cardEl.classList.remove('unread');
        cardEl.classList.add('read');
        cardEl.setAttribute('data-read', 'true');
        var dot = cardEl.querySelector('.unread-indicator-dot');
        if (dot) dot.remove();
    }
}
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
