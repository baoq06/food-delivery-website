// ==========================================================================
// Utee - JavaScript Tương Tác Giao Diện Người Dùng
// Design Intelligence: ui-ux-pro-max (Micro-interactions, Fast Feedback)
// ==========================================================================

document.addEventListener("DOMContentLoaded", () => {
    console.log("🚀 Utee - Hệ thống đặt đồ ăn siêu tốc đã khởi chạy thành công!");

    // 1. Hiệu ứng làm nổi bật Navbar khi cuộn trang
    const navbar = document.querySelector(".navbar");
    if (navbar) {
        const handleScroll = () => {
            if (window.scrollY > 20) {
                navbar.classList.add("navbar-scrolled");
            } else {
                navbar.classList.remove("navbar-scrolled");
            }
        };
        window.addEventListener("scroll", handleScroll, { passive: true });
        handleScroll();
    }

    // 2. Click-to-copy cho mã ưu đãi trên Topbar & Promo Banner
    const copyPromoCodes = document.querySelectorAll(".topbar-right strong, .promo-content strong");
    copyPromoCodes.forEach(codeEl => {
        codeEl.style.cursor = "pointer";
        codeEl.setAttribute("title", "Bấm để sao chép mã ưu đãi này!");
        codeEl.addEventListener("click", () => {
            const codeText = codeEl.innerText.trim();
            if (codeText && navigator.clipboard) {
                navigator.clipboard.writeText(codeText).then(() => {
                    showToast(`✨ Đã sao chép mã ${codeText}! Dán vào giỏ hàng để nhận ưu đãi.`);
                }).catch(() => {
                    showToast(`Mã ưu đãi của bạn: ${codeText}`);
                });
            }
        });
    });

    // 3. Phản hồi trực quan khi bấm đặt món (Add to Cart)
    const addCartForms = document.querySelectorAll(".add-cart-form");
    addCartForms.forEach(form => {
        form.addEventListener("submit", (e) => {
            const btn = form.querySelector(".btn-add-cart");
            if (btn) {
                btn.classList.add("btn-added");
                btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> <span>Đã chọn</span>';
                setTimeout(() => {
                    btn.classList.remove("btn-added");
                }, 1200);
            }
        });
    });

    // 4. Toast Notification Container & Function
    function showToast(message) {
        let toastContainer = document.getElementById("vindeli-toast-container");
        if (!toastContainer) {
            toastContainer = document.createElement("div");
            toastContainer.id = "vindeli-toast-container";
            toastContainer.className = "vindeli-toast-container";
            document.body.appendChild(toastContainer);
        }

        const toast = document.createElement("div");
        toast.className = "vindeli-toast";
        toast.innerHTML = `<i class="fa-solid fa-bell text-primary"></i> <span>${message}</span>`;
        toastContainer.appendChild(toast);

        // Kích hoạt animation hiện ra
        requestAnimationFrame(() => {
            toast.classList.add("show");
        });

        // Tự động biến mất sau 3.2s
        setTimeout(() => {
            toast.classList.remove("show");
            setTimeout(() => toast.remove(), 300);
        }, 3200);
    }
    
    // Gán hàm showToast ra window để các trang JSP khác có thể gọi nếu cần
    window.showToast = showToast;

    // 5. Hỗ trợ Click Toggle cho User Menu & đóng khi click ra ngoài
    const userMenu = document.querySelector(".user-menu");
    if (userMenu) {
        userMenu.addEventListener("click", (e) => {
            // Không can thiệp nếu click vào các liên kết bên trong dropdown
            if (!e.target.closest(".user-dropdown a")) {
                userMenu.classList.toggle("open");
            }
        });

        document.addEventListener("click", (e) => {
            if (!userMenu.contains(e.target)) {
                userMenu.classList.remove("open");
            }
        });
    }
});
