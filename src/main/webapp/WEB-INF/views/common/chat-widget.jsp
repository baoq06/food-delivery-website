<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* Floating Customer Chat Widget */
    .utee-chat-widget {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 99999;
        font-family: inherit;
    }

    .utee-chat-bubble-btn {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f05454, #e02424);
        color: #ffffff;
        box-shadow: 0 8px 24px rgba(240, 84, 84, 0.35);
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        position: relative;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border: none;
    }

    .utee-chat-bubble-btn:hover {
        transform: translateY(-4px) scale(1.05);
        box-shadow: 0 12px 28px rgba(240, 84, 84, 0.45);
    }

    .utee-chat-bubble-btn i {
        font-size: 1.5rem;
    }

    .utee-chat-badge {
        position: absolute;
        top: -3px;
        right: -3px;
        background: #10b981;
        color: #ffffff;
        font-size: 0.72rem;
        font-weight: 800;
        min-width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #ffffff;
    }

    /* Popup Box */
    .utee-chat-popup {
        position: absolute;
        bottom: 74px;
        right: 0;
        width: 380px;
        height: 520px;
        background: #ffffff;
        border-radius: 20px;
        box-shadow: 0 15px 40px rgba(0, 0, 0, 0.16);
        border: 1px solid #e2e8f0;
        display: none;
        flex-direction: column;
        overflow: hidden;
        animation: chatSlideUp 0.25s ease-out;
    }

    @keyframes chatSlideUp {
        from { opacity: 0; transform: translateY(15px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .utee-chat-header {
        background: linear-gradient(135deg, #f05454, #dc2626);
        color: #ffffff;
        padding: 14px 18px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .utee-chat-header-info {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .utee-chat-header-avatar {
        width: 38px;
        height: 38px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid rgba(255, 255, 255, 0.8);
        background: #fff;
    }

    .utee-chat-header-name {
        font-weight: 700;
        font-size: 0.96rem;
        margin: 0;
        color: #ffffff;
        max-width: 190px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .utee-chat-header-sub {
        font-size: 0.72rem;
        color: rgba(255, 255, 255, 0.85);
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .utee-chat-header-close {
        background: none;
        border: none;
        color: #ffffff;
        font-size: 1.2rem;
        cursor: pointer;
        opacity: 0.85;
        transition: opacity 0.2s;
        padding: 4px;
    }

    .utee-chat-header-close:hover {
        opacity: 1;
    }

    .utee-chat-body {
        flex: 1;
        padding: 16px;
        overflow-y: auto;
        background: #f8fafc;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .u-msg-row {
        display: flex;
        align-items: flex-end;
        gap: 8px;
        max-width: 80%;
    }

    .u-msg-row.sent {
        align-self: flex-end;
        flex-direction: row-reverse;
    }

    .u-msg-row.received {
        align-self: flex-start;
    }

    .u-msg-bubble {
        padding: 10px 14px;
        border-radius: 16px;
        font-size: 0.88rem;
        line-height: 1.4;
        word-break: break-word;
    }

    .u-msg-row.sent .u-msg-bubble {
        background: #f05454;
        color: #ffffff;
        border-bottom-right-radius: 4px;
    }

    .u-msg-row.received .u-msg-bubble {
        background: #ffffff;
        color: #1e293b;
        border: 1px solid #e2e8f0;
        border-bottom-left-radius: 4px;
    }

    .u-msg-time {
        font-size: 0.65rem;
        display: block;
        margin-top: 3px;
    }

    .u-msg-row.sent .u-msg-time {
        color: rgba(255, 255, 255, 0.8);
        text-align: right;
    }

    .u-msg-row.received .u-msg-time {
        color: #94a3b8;
    }

    .utee-chat-input-area {
        padding: 12px 14px;
        background: #ffffff;
        border-top: 1px solid #edf2f7;
    }

    .utee-chat-form {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .utee-chat-text-input {
        flex: 1;
        padding: 8px 14px;
        border-radius: 20px;
        border: 1px solid #e2e8f0;
        font-size: 0.88rem;
        outline: none;
    }

    .utee-chat-text-input:focus {
        border-color: #f05454;
    }

    .utee-chat-send-btn {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: #f05454;
        color: #ffffff;
        border: none;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: transform 0.2s;
    }

    .utee-chat-send-btn:hover {
        transform: scale(1.08);
    }

    .u-order-ref {
        background: #f0fdf4;
        color: #166534;
        padding: 3px 8px;
        border-radius: 6px;
        font-size: 0.72rem;
        font-weight: 600;
        margin-bottom: 4px;
        display: inline-block;
    }

    /* Recalled message styles */
    .u-msg-bubble.recalled {
        background: #f1f5f9 !important;
        color: #94a3b8 !important;
        font-style: italic;
        border: 1px dashed #cbd5e1 !important;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    /* Recall action trigger */
    .u-msg-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .u-msg-row.sent .u-msg-wrapper {
        flex-direction: row-reverse;
    }

    .u-msg-recall-btn {
        opacity: 0;
        visibility: hidden;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        color: #64748b;
        font-size: 0.75rem;
        border-radius: 50%;
        width: 26px;
        height: 26px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 2px 6px rgba(0,0,0,0.06);
        transition: all 0.2s ease;
    }

    .u-msg-wrapper:hover .u-msg-recall-btn {
        opacity: 1;
        visibility: visible;
    }

    .u-msg-recall-btn:hover {
        background: #fee2e2;
        color: #ef4444;
        border-color: #fca5a5;
    }

    /* Seen indicator */
    .u-seen-status {
        font-size: 0.7rem;
        color: #64748b;
        text-align: right;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 4px;
        margin-top: -4px;
        margin-bottom: 4px;
        padding-right: 4px;
    }

    /* Header mark-read button */
    .utee-btn-header-read {
        background: rgba(255, 255, 255, 0.2);
        border: 1px solid rgba(255, 255, 255, 0.4);
        color: #ffffff;
        font-size: 0.72rem;
        font-weight: 600;
        padding: 4px 10px;
        border-radius: 20px;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.2s;
    }

    .utee-btn-header-read:hover {
        background: #ffffff;
        color: #f05454;
    }

    @media (max-width: 480px) {
        .utee-chat-popup {
            width: calc(100vw - 32px);
            right: -8px;
            bottom: 68px;
            height: 480px;
        }
    }
</style>

<!-- Floating Widget HTML -->
<div class="utee-chat-widget" id="uteeChatWidget" style="display: none;">
    <!-- Nút tròn mở chat -->
    <button class="utee-chat-bubble-btn" id="uteeChatToggleBtn" onclick="toggleChatPopup()" title="Chat với quán ăn">
        <i class="fa-solid fa-comments"></i>
        <span class="utee-chat-badge" id="clientChatBadge" style="display: none;">0</span>
    </button>

    <!-- Hộp thoại chat popup -->
    <div class="utee-chat-popup" id="uteeChatPopup">
        <div class="utee-chat-header">
            <div class="utee-chat-header-info">
                <img id="popupRestAvatar" src="https://cdn-icons-png.flaticon.com/512/3177/3177440.png" class="utee-chat-header-avatar" alt="Quán ăn" />
                <div>
                    <h5 id="popupRestName" class="utee-chat-header-name">Quán Ăn</h5>
                    <span class="utee-chat-header-sub">
                        <i class="fa-solid fa-circle text-success" style="font-size: 0.45rem;"></i> Đang phục vụ trực tuyến
                    </span>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="utee-btn-header-read" onclick="markClientChatAsRead()" title="Đánh dấu tất cả tin nhắn từ quán là đã đọc">
                    <i class="fa-solid fa-check-double"></i> Đã đọc
                </button>
                <button class="utee-chat-header-close" onclick="toggleChatPopup()" title="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        </div>

        <!-- Khung xem toàn bộ lịch sử tin nhắn -->
        <div class="utee-chat-body" id="popupMessagesBody">
            <!-- Tin nhắn sẽ được render tại đây -->
        </div>

        <div class="utee-chat-input-area">
            <form class="utee-chat-form" onsubmit="sendClientMessage(event)">
                <input type="text" id="clientMsgInput" class="utee-chat-text-input" placeholder="Nhập tin nhắn cho quán..." autocomplete="off" />
                <button type="submit" class="utee-chat-send-btn" title="Gửi">
                    <i class="fa-solid fa-paper-plane" style="font-size: 0.85rem;"></i>
                </button>
            </form>
        </div>
    </div>
</div>

<script>
    let activeClientConvId = null;
    let activeClientRestId = null;
    let pendingOrderId = null;
    let clientPollTimer = null;
    let isChatOpen = false;
    let clientLastMsgCount = 0;

    const currentLoggedInUser = ${not empty sessionScope.currentUser ? sessionScope.currentUser.id : 'null'};

    /**
     * Mở hộp chat với quán chỉ định
     * @param restaurantId: ID của nhà hàng
     * @param restaurantName: Tên nhà hàng
     * @param orderId: Mã đơn hàng (tùy chọn)
     */
    function openChatWithRestaurant(restaurantId, restaurantName, orderId) {
        if (!currentLoggedInUser) {
            alert("Vui lòng đăng nhập để bắt đầu trò chuyện với nhà hàng!");
            window.location.href = "${pageContext.request.contextPath}/auth?action=login&redirect=" + encodeURIComponent(window.location.pathname + window.location.search);
            return;
        }

        activeClientRestId = restaurantId;
        if (orderId) pendingOrderId = orderId;

        document.getElementById("uteeChatWidget").style.display = "block";
        document.getElementById("uteeChatPopup").style.display = "flex";
        isChatOpen = true;

        if (restaurantName) {
            document.getElementById("popupRestName").textContent = restaurantName;
        }

        // Lấy hoặc tạo mới cuộc hội thoại với quán
        fetch("${pageContext.request.contextPath}/api/chat/conversation?restaurantId=" + restaurantId)
            .then(res => res.json())
            .then(data => {
                if (data.success && data.conversation) {
                    activeClientConvId = data.conversation.id;
                    if (data.conversation.restaurantName) {
                        document.getElementById("popupRestName").textContent = data.conversation.restaurantName;
                    }
                    if (data.conversation.restaurantAvatar) {
                        document.getElementById("popupRestAvatar").src = data.conversation.restaurantAvatar;
                    }
                    loadClientMessages(true);
                    startClientPolling();
                }
            })
            .catch(err => console.error("Error opening chat conversation:", err));
    }

    function toggleChatPopup() {
        const popup = document.getElementById("uteeChatPopup");
        isChatOpen = !isChatOpen;
        if (isChatOpen) {
            popup.style.display = "flex";
            if (activeClientConvId) {
                loadClientMessages(true);
            }
        } else {
            popup.style.display = "none";
        }
    }

    function startClientPolling() {
        if (clientPollTimer) clearInterval(clientPollTimer);
        clientPollTimer = setInterval(() => {
            if (activeClientConvId && isChatOpen) {
                loadClientMessages(false);
            }
        }, 3000);
    }

    function loadClientMessages(shouldScroll) {
        if (!activeClientConvId) return;

        fetch("${pageContext.request.contextPath}/api/chat/messages?conversationId=" + activeClientConvId)
            .then(res => res.json())
            .then(data => {
                if (!data.success) return;
                const messages = data.messages || [];
                const body = document.getElementById("popupMessagesBody");

                if (messages.length !== clientLastMsgCount || shouldScroll) {
                    clientLastMsgCount = messages.length;
                    body.innerHTML = "";

                    if (messages.length === 0) {
                        body.innerHTML = `
                            <div class="text-center text-muted my-auto py-4" style="font-size: 0.85rem;">
                                <i class="fa-regular fa-comment-dots fa-2x mb-2 text-secondary opacity-50"></i>
                                <p>Hãy nhắn tin để hỏi quán về món ăn, ghi chú hoặc đơn hàng của bạn nhé!</p>
                            </div>
                        `;
                    } else {
                        // Tìm tin nhắn cuối cùng gửi bởi CUSTOMER để hiển thị "Đã xem" (Seen)
                        let lastSentCustomerMsgId = null;
                        let lastSentCustomerIsRead = false;
                        for (let i = messages.length - 1; i >= 0; i--) {
                            if (messages[i].senderRole === 'CUSTOMER' && !messages[i].isRecalled) {
                                lastSentCustomerMsgId = messages[i].id;
                                lastSentCustomerIsRead = messages[i].isRead;
                                break;
                            }
                        }

                        messages.forEach(msg => {
                            const isMe = (msg.senderRole === 'CUSTOMER');
                            const row = document.createElement("div");
                            row.className = "u-msg-row " + (isMe ? "sent" : "received");

                            const timeStr = formatTimeShort(msg.createdAt);
                            let orderTag = msg.orderId ? `<div class="u-order-ref"><i class="fa-solid fa-receipt"></i> Đơn #FZ-\${msg.orderId}</div>` : '';

                            let bubbleContent = '';
                            if (msg.isRecalled) {
                                bubbleContent = `
                                    <div class="u-msg-bubble recalled">
                                        <i class="fa-solid fa-ban"></i>
                                        <span>Tin nhắn đã bị thu hồi</span>
                                    </div>
                                `;
                            } else {
                                let recallBtn = '';
                                if (isMe) {
                                    recallBtn = `
                                        <button type="button" class="u-msg-recall-btn" onclick="recallClientMessage(\${msg.id})" title="Gỡ tin nhắn">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    `;
                                }
                                bubbleContent = `
                                    <div class="u-msg-wrapper">
                                        \${recallBtn}
                                        <div class="u-msg-bubble">
                                            \${orderTag}
                                            <div class="u-msg-text">\${escapeHtmlClient(msg.message)}</div>
                                            <span class="u-msg-time">\${timeStr}</span>
                                        </div>
                                    </div>
                                `;
                            }

                            row.innerHTML = bubbleContent;
                            body.appendChild(row);

                            // Hiển thị trạng thái "Đã xem" dưới tin nhắn mới nhất mà quán đã đọc
                            if (isMe && msg.id === lastSentCustomerMsgId && lastSentCustomerIsRead) {
                                const seenDiv = document.createElement("div");
                                seenDiv.className = "u-seen-status";
                                seenDiv.innerHTML = `<i class="fa-solid fa-circle-check text-primary"></i> Đã xem`;
                                body.appendChild(seenDiv);
                            }
                        });
                    }

                    body.scrollTop = body.scrollHeight;
                }
            })
            .catch(err => console.error("Error loading client messages:", err));
    }

    /**
     * Nút "Đã đọc" trên khung chat khách hàng
     */
    function markClientChatAsRead() {
        if (!activeClientConvId) return;
        fetch("${pageContext.request.contextPath}/api/chat/mark-read?conversationId=" + activeClientConvId + "&readerRole=CUSTOMER", {
            method: "POST"
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                const badge = document.getElementById("clientChatBadge");
                if (badge) badge.style.display = "none";
                loadClientMessages(false);
            }
        })
        .catch(err => console.error("Error mark-read:", err));
    }

    /**
     * Gỡ tin nhắn (Messenger style)
     */
    function recallClientMessage(messageId) {
        if (!confirm("Bạn có chắc chắn muốn gỡ tin nhắn này đối với mọi người?")) return;
        fetch("${pageContext.request.contextPath}/api/chat/recall?messageId=" + messageId, {
            method: "POST"
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                loadClientMessages(false);
            } else {
                alert(data.message || "Không thể gỡ tin nhắn!");
            }
        })
        .catch(err => console.error("Error recalling message:", err));
    }

    function sendClientMessage(e) {
        e.preventDefault();
        const input = document.getElementById("clientMsgInput");
        const msg = input.value.trim();
        if (!msg || !activeClientConvId) return;

        input.value = "";

        const params = new URLSearchParams({
            conversationId: activeClientConvId,
            message: msg,
            senderRole: "CUSTOMER"
        });

        if (pendingOrderId) {
            params.append("orderId", pendingOrderId);
            pendingOrderId = null; // chỉ đính kèm ở tin đầu tiên của ngữ cảnh đơn hàng
        }

        fetch("${pageContext.request.contextPath}/api/chat/send", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
            },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                loadClientMessages(true);
            }
        })
        .catch(err => console.error("Error sending client message:", err));
    }

    function formatTimeShort(dateStr) {
        if (!dateStr) return "";
        try {
            const d = new Date(dateStr);
            return d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
        } catch(e) {
            return "";
        }
    }

    function escapeHtmlClient(text) {
        if (!text) return "";
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Tự động kiểm tra nếu có cuộc hội thoại gần nhất và số tin nhắn chưa đọc
    document.addEventListener("DOMContentLoaded", function() {
        if (currentLoggedInUser) {
            fetch("${pageContext.request.contextPath}/api/chat/unread-count?type=user")
                .then(res => res.json())
                .then(data => {
                    if (data.success && data.unreadCount > 0) {
                        const badge = document.getElementById("clientChatBadge");
                        if (badge) {
                            badge.textContent = data.unreadCount;
                            badge.style.display = "flex";
                        }
                        const widget = document.getElementById("uteeChatWidget");
                        if (widget) widget.style.display = "block";
                    }
                })
                .catch(err => console.error("Error checking user unread chat:", err));
        }
    });
</script>
