<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp">
    <jsp:param name="title" value="Trung Tâm Tin Nhắn - Đối Tác Quán Ăn" />
</jsp:include>

<style>
    .merchant-chat-section {
        background-color: #f8fafc;
        min-height: calc(100vh - 120px);
        padding-top: 25px;
        padding-bottom: 45px;
    }

    .chat-container-card {
        background: #ffffff;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        border: 1px solid #e2e8f0;
        overflow: hidden;
        display: flex;
        height: 720px;
    }

    /* Left Sidebar: Conversations list */
    .chat-sidebar {
        width: 360px;
        border-right: 1px solid #edf2f7;
        display: flex;
        flex-direction: column;
        background: #ffffff;
    }

    .chat-sidebar-header {
        padding: 20px 24px;
        border-bottom: 1px solid #f1f5f9;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .chat-sidebar-title {
        font-size: 1.15rem;
        font-weight: 700;
        color: #1e293b;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .chat-search-wrap {
        padding: 12px 20px;
        background: #f8fafc;
        border-bottom: 1px solid #f1f5f9;
    }

    .chat-search-input {
        width: 100%;
        padding: 9px 14px 9px 36px;
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        font-size: 0.88rem;
        background: #ffffff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%2394a3b8' viewBox='0 0 16 16'%3E%3Cpath d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z'%3E%3C/svg%3E") no-repeat 12px center;
        outline: none;
        transition: border-color 0.2s;
    }

    .chat-search-input:focus {
        border-color: #f05454;
    }

    .chat-conv-list {
        flex: 1;
        overflow-y: auto;
        list-style: none;
        margin: 0;
        padding: 0;
    }

    .chat-conv-item {
        display: flex;
        align-items: center;
        padding: 14px 20px;
        border-bottom: 1px solid #f8fafc;
        cursor: pointer;
        transition: all 0.2s;
        position: relative;
    }

    .chat-conv-item:hover {
        background-color: #f8fafc;
    }

    .chat-conv-item.active {
        background-color: #fff1f2;
        border-left: 4px solid #f05454;
    }

    .chat-avatar-wrap {
        position: relative;
        margin-right: 14px;
        flex-shrink: 0;
    }

    .chat-user-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
        background: #e2e8f0;
    }

    .online-indicator {
        width: 11px;
        height: 11px;
        background-color: #10b981;
        border: 2px solid #ffffff;
        border-radius: 50%;
        position: absolute;
        bottom: 0;
        right: 0;
    }

    .chat-conv-meta {
        flex: 1;
        min-width: 0;
    }

    .chat-conv-top {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        margin-bottom: 4px;
    }

    .chat-conv-name {
        font-weight: 600;
        font-size: 0.95rem;
        color: #1e293b;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .chat-conv-time {
        font-size: 0.75rem;
        color: #94a3b8;
        white-space: nowrap;
    }

    .chat-conv-preview {
        font-size: 0.84rem;
        color: #64748b;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .chat-unread-badge {
        background-color: #f05454;
        color: #ffffff;
        font-size: 0.7rem;
        font-weight: 700;
        padding: 2px 7px;
        border-radius: 9999px;
        margin-left: 6px;
    }

    /* Right Main Chat Area */
    .chat-main-area {
        flex: 1;
        display: flex;
        flex-direction: column;
        background: #ffffff;
    }

    .chat-header {
        padding: 16px 24px;
        border-bottom: 1px solid #edf2f7;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #ffffff;
    }

    .chat-header-user {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .chat-header-name {
        font-weight: 700;
        font-size: 1.05rem;
        color: #0f172a;
        margin: 0;
    }

    .chat-header-status {
        font-size: 0.78rem;
        color: #10b981;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .chat-messages-container {
        flex: 1;
        padding: 24px;
        overflow-y: auto;
        background: #f8fafc;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .message-row {
        display: flex;
        align-items: flex-end;
        gap: 10px;
        max-width: 75%;
    }

    .message-row.sent {
        align-self: flex-end;
        flex-direction: row-reverse;
    }

    .message-row.received {
        align-self: flex-start;
    }

    .msg-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
        background: #e2e8f0;
    }

    .msg-bubble {
        padding: 12px 18px;
        border-radius: 18px;
        font-size: 0.92rem;
        line-height: 1.45;
        position: relative;
        word-break: break-word;
    }

    .message-row.sent .msg-bubble {
        background: linear-gradient(135deg, #f05454, #dc2626);
        color: #ffffff;
        border-bottom-right-radius: 4px;
        box-shadow: 0 4px 12px rgba(240, 84, 84, 0.25);
    }

    .message-row.received .msg-bubble {
        background: #ffffff;
        color: #1e293b;
        border-bottom-left-radius: 4px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.03);
    }

    .msg-time {
        font-size: 0.7rem;
        margin-top: 4px;
        display: block;
    }

    .message-row.sent .msg-time {
        color: rgba(255, 255, 255, 0.85);
        text-align: right;
    }

    .message-row.received .msg-time {
        color: #94a3b8;
    }

    /* Recalled message style */
    .msg-bubble.recalled {
        background: #f1f5f9 !important;
        color: #94a3b8 !important;
        font-style: italic;
        border: 1px dashed #cbd5e1 !important;
        box-shadow: none !important;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Message wrapper & recall button */
    .merchant-msg-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .message-row.sent .merchant-msg-wrapper {
        flex-direction: row-reverse;
    }

    .merchant-msg-recall-btn {
        opacity: 0;
        visibility: hidden;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        color: #64748b;
        font-size: 0.75rem;
        border-radius: 50%;
        width: 28px;
        height: 28px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 2px 6px rgba(0,0,0,0.06);
        transition: all 0.2s ease;
    }

    .merchant-msg-wrapper:hover .merchant-msg-recall-btn {
        opacity: 1;
        visibility: visible;
    }

    .merchant-msg-recall-btn:hover {
        background: #fee2e2;
        color: #ef4444;
        border-color: #fca5a5;
    }

    /* Seen indicator */
    .merchant-seen-status {
        font-size: 0.72rem;
        color: #64748b;
        text-align: right;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 4px;
        margin-top: -6px;
        margin-bottom: 6px;
        padding-right: 42px;
    }

    /* Action buttons in header */
    .btn-header-read {
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        color: #334155;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 20px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.2s ease;
    }

    .btn-header-read:hover {
        background: #e2e8f0;
        color: #0f172a;
    }

    .btn-header-delete {
        background: #fee2e2;
        border: 1px solid #fecaca;
        color: #dc2626;
        font-size: 0.78rem;
        font-weight: 700;
        padding: 6px 12px;
        border-radius: 20px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.2s ease;
    }

    .btn-header-delete:hover {
        background: #dc2626;
        color: #ffffff;
    }

    .order-badge-pill {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 3px 8px;
        border-radius: 8px;
        font-size: 0.75rem;
        font-weight: 600;
        background: #e0f2fe;
        color: #0369a1;
        margin-bottom: 6px;
    }

    /* Chat Input Area */
    .chat-footer {
        padding: 16px 24px;
        border-top: 1px solid #edf2f7;
        background: #ffffff;
    }

    .chat-input-box {
        display: flex;
        align-items: center;
        gap: 12px;
        background: #f1f5f9;
        border-radius: 28px;
        padding: 6px 8px 6px 18px;
        border: 1px solid transparent;
        transition: all 0.2s;
    }

    .chat-input-box:focus-within {
        background: #ffffff;
        border-color: #f05454;
        box-shadow: 0 0 0 3px rgba(240, 84, 84, 0.12);
    }

    .chat-input {
        flex: 1;
        border: none;
        background: transparent;
        outline: none;
        font-size: 0.94rem;
        color: #1e293b;
    }

    .btn-chat-send {
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background: #f05454;
        color: #ffffff;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s;
        flex-shrink: 0;
    }

    .btn-chat-send:hover {
        background: #dc2626;
        transform: scale(1.05);
    }

    .chat-empty-view {
        flex: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #94a3b8;
        padding: 40px;
        text-align: center;
    }
</style>

<div class="merchant-portal-header">
    <jsp:include page="/WEB-INF/views/merchant/common/navbar.jsp">
        <jsp:param name="activeTab" value="chat" />
    </jsp:include>
</div>

<div class="merchant-chat-section">
    <div class="container">
        <div class="chat-container-card">
            <!-- Sidebar: Danh sách khách hàng chat -->
            <div class="chat-sidebar">
                <div class="chat-sidebar-header">
                    <h3 class="chat-sidebar-title">
                        <i class="fa-solid fa-comments text-danger"></i> Tin nhắn khách hàng
                    </h3>
                    <span class="badge bg-light text-dark border">${conversations.size()} hội thoại</span>
                </div>

                <div class="chat-search-wrap">
                    <input type="text" id="searchConvInput" class="chat-search-input" placeholder="Tìm theo tên khách hàng..." />
                </div>

                <ul class="chat-conv-list" id="convList">
                    <c:choose>
                        <c:when test="${empty conversations}">
                            <div class="p-4 text-center text-muted" style="font-size: 0.9rem;">
                                <i class="fa-regular fa-comment-dots fa-3x mb-3 text-secondary opacity-50"></i>
                                <p>Chưa có cuộc trò chuyện nào với khách hàng.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="c" items="${conversations}">
                                <li class="chat-conv-item ${c.id eq selectedConversationId ? 'active' : ''}" 
                                    data-conv-id="${c.id}" 
                                    data-user-name="${c.userName}"
                                    onclick="selectConversation(${c.id})">
                                    <div class="chat-avatar-wrap">
                                        <img src="${not empty c.userAvatar ? c.userAvatar : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}" 
                                             class="chat-user-avatar" alt="${c.userName}">
                                        <span class="online-indicator"></span>
                                    </div>
                                    <div class="chat-conv-meta">
                                        <div class="chat-conv-top">
                                            <span class="chat-conv-name">${c.userName}</span>
                                            <span class="chat-conv-time">
                                                <fmt:formatDate value="${c.lastMessageAt}" pattern="HH:mm" />
                                            </span>
                                        </div>
                                        <div class="chat-conv-preview">
                                            <span>${not empty c.lastMessage ? c.lastMessage : '...'}</span>
                                            <c:if test="${c.unreadMerchantCount > 0}">
                                                <span class="chat-unread-badge">${c.unreadMerchantCount}</span>
                                            </c:if>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>

            <!-- Khung chat chính -->
            <div class="chat-main-area">
                <div id="chatActiveContainer" style="display: none; height: 100%; flex-direction: column;">
                    <!-- Chat Header -->
                    <div class="chat-header">
                        <div class="chat-header-user">
                            <img id="activeUserAvatar" src="https://cdn-icons-png.flaticon.com/512/3177/3177440.png" class="chat-user-avatar" alt="User">
                            <div>
                                <h4 id="activeUserName" class="chat-header-name">Khách hàng</h4>
                                <span class="chat-header-status">
                                    <i class="fa-solid fa-circle" style="font-size: 0.55rem;"></i> Trực tuyến
                                </span>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span id="activeUserPhone" class="text-muted small me-2"><i class="fa-solid fa-phone"></i> ---</span>
                            <button type="button" class="btn-header-read" onclick="markMerchantChatAsRead()" title="Đánh dấu tất cả tin nhắn của khách là đã đọc">
                                <i class="fa-solid fa-check-double"></i> Đã đọc
                            </button>
                            <button type="button" class="btn-header-delete" onclick="deleteCurrentConversation()" title="Xóa hoàn toàn cuộc trò chuyện này để giao diện gọn hơn">
                                <i class="fa-solid fa-trash-can"></i> Xóa hội thoại
                            </button>
                        </div>
                    </div>

                    <!-- Chat Message Stream (Lưu toàn bộ lịch sử trò chuyện) -->
                    <div class="chat-messages-container" id="messagesStream">
                        <!-- Tin nhắn sẽ được render động qua JavaScript -->
                    </div>

                    <!-- Chat Input Footer -->
                    <div class="chat-footer">
                        <form id="merchantSendForm" onsubmit="handleSendMessage(event)">
                            <div class="chat-input-box">
                                <input type="text" id="merchantMsgInput" class="chat-input" placeholder="Nhập tin nhắn phản hồi khách hàng..." autocomplete="off">
                                <button type="submit" class="btn-chat-send" title="Gửi tin nhắn">
                                    <i class="fa-solid fa-paper-plane"></i>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Màn hình khi chưa chọn cuộc hội thoại -->
                <div id="chatPlaceholder" class="chat-empty-view">
                    <i class="fa-solid fa-comments fa-4x mb-3 text-muted opacity-50"></i>
                    <h5>Chọn một cuộc hội thoại từ danh sách bên trái</h5>
                    <p class="text-muted small">Bạn có thể trao đổi trực tiếp, tư vấn món ăn và giải đáp thắc mắc của thực khách tại đây.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    let currentConversationId = ${not empty selectedConversationId ? selectedConversationId : 'null'};
    let currentRestaurantId = ${not empty currentRestaurant ? currentRestaurant.id : 'null'};
    let lastLoadedMessageCount = 0;
    let pollTimer = null;

    document.addEventListener("DOMContentLoaded", function() {
        if (currentConversationId) {
            selectConversation(currentConversationId);
        }

        // Bắt đầu Polling 3s/lần kiểm tra tin nhắn mới
        pollTimer = setInterval(function() {
            if (currentConversationId) {
                loadMessages(currentConversationId, false);
            }
        }, 3000);

        // Lọc danh sách hội thoại
        const searchInput = document.getElementById("searchConvInput");
        if (searchInput) {
            searchInput.addEventListener("input", function() {
                const term = this.value.toLowerCase().trim();
                document.querySelectorAll(".chat-conv-item").forEach(item => {
                    const name = (item.getAttribute("data-user-name") || "").toLowerCase();
                    item.style.display = name.includes(term) ? "flex" : "none";
                });
            });
        }
    });

    function selectConversation(convId) {
        currentConversationId = convId;
        document.querySelectorAll(".chat-conv-item").forEach(el => {
            el.classList.toggle("active", el.getAttribute("data-conv-id") == convId);
        });

        // Xóa badge unread trên item vừa bấm
        const activeItem = document.querySelector(`.chat-conv-item[data-conv-id='${convId}']`);
        if (activeItem) {
            const badge = activeItem.querySelector(".chat-unread-badge");
            if (badge) badge.remove();
        }

        document.getElementById("chatPlaceholder").style.display = "none";
        const activeContainer = document.getElementById("chatActiveContainer");
        activeContainer.style.display = "flex";

        loadMessages(convId, true);
    }

    function loadMessages(convId, shouldScrollToBottom) {
        fetch("${pageContext.request.contextPath}/api/chat/messages?conversationId=" + convId)
            .then(res => res.json())
            .then(data => {
                if (!data.success) return;

                // Update Header info
                if (data.conversation) {
                    document.getElementById("activeUserName").textContent = data.conversation.userName || "Khách hàng";
                    document.getElementById("activeUserAvatar").src = data.conversation.userAvatar || "https://cdn-icons-png.flaticon.com/512/3177/3177440.png";
                    document.getElementById("activeUserPhone").innerHTML = '<i class="fa-solid fa-phone"></i> ' + (data.conversation.userPhone || 'Chưa có SĐT');
                }

                const stream = document.getElementById("messagesStream");
                const messages = data.messages || [];

                // Chỉ render lại nếu số lượng tin nhắn thay đổi hoặc tải lần đầu
                if (messages.length !== lastLoadedMessageCount || shouldScrollToBottom) {
                    lastLoadedMessageCount = messages.length;
                    stream.innerHTML = "";

                    if (messages.length === 0) {
                        stream.innerHTML = `
                            <div class="text-center text-muted my-auto py-5">
                                <i class="fa-regular fa-comments fa-3x mb-2 opacity-50"></i>
                                <p>Bắt đầu cuộc trò chuyện với khách hàng ngay bây giờ.</p>
                            </div>
                        `;
                    } else {
                        // Tìm tin nhắn cuối cùng gửi bởi SELLER để hiển thị "Đã xem" (Seen) khi khách đã đọc
                        let lastSentSellerMsgId = null;
                        let lastSentSellerIsRead = false;
                        for (let i = messages.length - 1; i >= 0; i--) {
                            if (messages[i].senderRole === 'SELLER' && !messages[i].isRecalled) {
                                lastSentSellerMsgId = messages[i].id;
                                lastSentSellerIsRead = messages[i].isRead;
                                break;
                            }
                        }

                        messages.forEach(msg => {
                            const isMe = (msg.senderRole === 'SELLER');
                            const row = document.createElement("div");
                            row.className = "message-row " + (isMe ? "sent" : "received");

                            const avatarSrc = isMe ? 
                                ("${not empty currentRestaurant.imageUrl ? currentRestaurant.imageUrl : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png'}") : 
                                (msg.senderAvatar || "https://cdn-icons-png.flaticon.com/512/3177/3177440.png");

                            const timeStr = formatMsgTime(msg.createdAt);

                            let orderBadgeHtml = '';
                            if (msg.orderId) {
                                orderBadgeHtml = `<div class="order-badge-pill"><i class="fa-solid fa-receipt"></i> Đơn hàng #FZ-\${msg.orderId}</div>`;
                            }

                            let bubbleContent = '';
                            if (msg.isRecalled) {
                                bubbleContent = `
                                    <div class="msg-bubble recalled">
                                        <i class="fa-solid fa-ban"></i>
                                        <span>Tin nhắn đã bị thu hồi</span>
                                    </div>
                                `;
                            } else {
                                let recallBtn = '';
                                if (isMe) {
                                    recallBtn = `
                                        <button type="button" class="merchant-msg-recall-btn" onclick="recallMerchantMessage(\${msg.id})" title="Gỡ tin nhắn">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    `;
                                }
                                bubbleContent = `
                                    <div class="merchant-msg-wrapper">
                                        \${recallBtn}
                                        <div class="msg-bubble">
                                            \${orderBadgeHtml}
                                            <div class="msg-text">\${escapeHtml(msg.message)}</div>
                                            <span class="msg-time">\${timeStr}</span>
                                        </div>
                                    </div>
                                `;
                            }

                            row.innerHTML = `
                                <img src="\${avatarSrc}" class="msg-avatar" alt="Avatar">
                                \${bubbleContent}
                            `;
                            stream.appendChild(row);

                            // Hiển thị trạng thái "Đã xem" dưới tin nhắn mới nhất mà khách đã đọc
                            if (isMe && msg.id === lastSentSellerMsgId && lastSentSellerIsRead) {
                                const seenDiv = document.createElement("div");
                                seenDiv.className = "merchant-seen-status";
                                seenDiv.innerHTML = `<i class="fa-solid fa-circle-check text-primary"></i> Đã xem`;
                                stream.appendChild(seenDiv);
                            }
                        });
                    }

                    if (shouldScrollToBottom || true) {
                        stream.scrollTop = stream.scrollHeight;
                    }
                }
            })
            .catch(err => console.error("Error loading chat messages:", err));
    }

    /**
     * Nút "Đã đọc" - Đánh dấu tất cả tin nhắn khách hàng gửi là đã đọc
     */
    function markMerchantChatAsRead() {
        if (!currentConversationId) return;
        fetch("${pageContext.request.contextPath}/api/chat/mark-read?conversationId=" + currentConversationId + "&readerRole=SELLER", {
            method: "POST"
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                const activeItem = document.querySelector(`.chat-conv-item[data-conv-id='\${currentConversationId}']`);
                if (activeItem) {
                    const badge = activeItem.querySelector(".chat-unread-badge");
                    if (badge) badge.remove();
                }
                loadMessages(currentConversationId, false);
            }
        })
        .catch(err => console.error("Error mark-read:", err));
    }

    /**
     * Thu hồi / Gỡ tin nhắn phía Merchant
     */
    function recallMerchantMessage(messageId) {
        if (!confirm("Bạn có chắc chắn muốn gỡ tin nhắn này đối với cả hai bên?")) return;
        fetch("${pageContext.request.contextPath}/api/chat/recall?messageId=" + messageId, {
            method: "POST"
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                loadMessages(currentConversationId, false);
            } else {
                alert(data.message || "Không thể gỡ tin nhắn!");
            }
        })
        .catch(err => console.error("Error recalling message:", err));
    }

    /**
     * Xóa hoàn toàn cuộc trò chuyện (Dành cho Merchant làm gọn danh sách)
     */
    function deleteCurrentConversation() {
        if (!currentConversationId) return;
        const restId = "${currentRestaurant.id}";
        if (!confirm("Bạn có chắc chắn muốn XÓA HOÀN TOÀN cuộc trò chuyện này? Lịch sử nhắn tin sẽ bị xóa vĩnh viễn.")) return;

        fetch("${pageContext.request.contextPath}/api/chat/delete-conversation?conversationId=" + currentConversationId + "&restaurantId=" + restId, {
            method: "POST"
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                // Xóa item khỏi danh sách bên trái
                const item = document.querySelector(`.chat-conv-item[data-conv-id='\${currentConversationId}']`);
                if (item) item.remove();

                // Đưa màn hình về trạng thái rỗng
                currentConversationId = null;
                document.getElementById("chatActiveContainer").style.display = "none";
                document.getElementById("chatPlaceholder").style.display = "flex";
            } else {
                alert(data.message || "Không thể xóa cuộc trò chuyện!");
            }
        })
        .catch(err => console.error("Error deleting conversation:", err));
    }

    function handleSendMessage(e) {
        e.preventDefault();
        const input = document.getElementById("merchantMsgInput");
        const msg = input.value.trim();
        if (!msg || !currentConversationId) return;

        input.value = "";

        fetch("${pageContext.request.contextPath}/api/chat/send", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
            },
            body: new URLSearchParams({
                conversationId: currentConversationId,
                message: msg,
                senderRole: "SELLER"
            })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                loadMessages(currentConversationId, true);
            } else {
                alert(data.message || "Không thể gửi tin nhắn!");
            }
        })
        .catch(err => {
            console.error("Lỗi khi gửi tin nhắn:", err);
        });
    }

    function formatMsgTime(dateStr) {
        if (!dateStr) return "";
        try {
            const d = new Date(dateStr);
            return d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
        } catch(e) {
            return "";
        }
    }

    function escapeHtml(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
</script>
