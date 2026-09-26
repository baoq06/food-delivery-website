// ==========================================================================
// Utee - JavaScript Tương Tác Giao Diện Người Dùng (UI/UX Pro Max)
// Features Implemented:
// 1. Parabolic Curved Fly-to-Cart Animation + Navbar Badge Bounce + Web Audio Chime + Rich Toast
// 3. Instant Category Filter & Sticky Bar (0s latency on Menu & Home Page)
// ==========================================================================

document.addEventListener("DOMContentLoaded", () => {
    console.log("🚀 Utee - Hệ thống đặt đồ ăn siêu tốc đã khởi chạy thành công!");

    // Helper: Định dạng tiền tệ VNĐ
    const formatVND = (num) => {
        return new Intl.NumberFormat("vi-VN").format(num) + " đ";
    };

    // Helper: Chuẩn hóa chuỗi tiếng Việt không dấu để tìm kiếm thông minh
    const normalizeStr = (str) => {
        if (!str) return "";
        return str
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .replace(/đ/g, "d")
            .replace(/Đ/g, "D")
            .toLowerCase()
            .trim();
    };

    // ==========================================================================
    // Âm thanh thông báo thêm món thành công (Web Audio API Chime)
    // ==========================================================================
    function playCartChime() {
        try {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            const ctx = new AudioCtx();
            if (ctx.state === "suspended") {
                ctx.resume();
            }

            const now = ctx.currentTime;

            // Âm chính: E5 (659Hz) lướt lên B5 (988Hz) trong vắt
            const osc1 = ctx.createOscillator();
            const gain1 = ctx.createGain();
            osc1.type = "sine";
            osc1.frequency.setValueAtTime(659.25, now);
            osc1.frequency.exponentialRampToValueAtTime(987.77, now + 0.08);

            gain1.gain.setValueAtTime(0.28, now);
            gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.42);

            osc1.connect(gain1);
            gain1.connect(ctx.destination);
            osc1.start(now);
            osc1.stop(now + 0.42);

            // Bồi âm cao (Sparkle Overtone)
            const osc2 = ctx.createOscillator();
            const gain2 = ctx.createGain();
            osc2.type = "triangle";
            osc2.frequency.setValueAtTime(1318.5, now); // E6
            osc2.frequency.exponentialRampToValueAtTime(1975.5, now + 0.08); // B6

            gain2.gain.setValueAtTime(0.12, now);
            gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

            osc2.connect(gain2);
            gain2.connect(ctx.destination);
            osc2.start(now);
            osc2.stop(now + 0.35);
        } catch (e) {
            // Audio context an toàn với chính sách trình duyệt
        }
    }
    window.playCartChime = playCartChime;

    // ==========================================================================
    // 1. Hiệu ứng làm nổi bật Navbar khi cuộn trang
    // ==========================================================================
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

    // ==========================================================================
    // 2. Click-to-copy cho mã ưu đãi (Topbar, Bento Promo Banner, v.v.)
    // ==========================================================================
    const copyPromoCodes = document.querySelectorAll(".topbar-right strong, .promo-content strong, .btn-copy-voucher");
    copyPromoCodes.forEach(btn => {
        btn.style.cursor = "pointer";
        btn.addEventListener("click", () => {
            const codeText = btn.dataset.code || btn.innerText.trim();
            if (codeText && navigator.clipboard) {
                navigator.clipboard.writeText(codeText).then(() => {
                    if (btn.classList.contains("btn-copy-voucher")) {
                        const originalHtml = btn.innerHTML;
                        btn.classList.add("copied");
                        btn.innerHTML = '<i class="fa-solid fa-check"></i> <span>Đã chép</span>';
                        setTimeout(() => {
                            btn.classList.remove("copied");
                            btn.innerHTML = originalHtml;
                        }, 2000);
                    }
                    showToast(`✨ Đã sao chép mã <strong>${codeText}</strong>! Dán vào giỏ hàng để nhận ưu đãi.`);
                }).catch(() => {
                    showToast(`Mã ưu đãi của bạn: ${codeText}`);
                });
            }
        });
    });

    // ==========================================================================
    // 3. Hệ thống Thông Báo Toast Đa Năng (Rich Toast Notification)
    // ==========================================================================
    function showToast(message, options = {}) {
        let toastContainer = document.getElementById("vindeli-toast-container");
        if (!toastContainer) {
            toastContainer = document.createElement("div");
            toastContainer.id = "vindeli-toast-container";
            toastContainer.className = "vindeli-toast-container";
            document.body.appendChild(toastContainer);
        }

        const toast = document.createElement("div");
        toast.className = "vindeli-toast";

        if (options.image) {
            toast.innerHTML = `
                <img src="${options.image}" alt="" class="toast-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'">
                <div class="toast-content">
                    <div class="toast-msg">${message}</div>
                    ${options.subtext ? `<div class="toast-sub">${options.subtext}</div>` : ""}
                </div>
                ${options.actionUrl ? `<a href="${options.actionUrl}" class="toast-action-btn">${options.actionText || "Xem"}</a>` : ""}
            `;
        } else {
            toast.innerHTML = `<i class="fa-solid fa-bell text-primary"></i> <span>${message}</span>`;
        }

        toastContainer.appendChild(toast);

        requestAnimationFrame(() => {
            toast.classList.add("show");
        });

        const duration = options.duration || 3200;
        setTimeout(() => {
            toast.classList.remove("show");
            setTimeout(() => toast.remove(), 350);
        }, duration);
    }
    window.showToast = showToast;

    // ==========================================================================
    // 3.1. Hệ Thống Kho Voucher (Shopee-Style Voucher Wallet)
    // ==========================================================================
    const VOUCHER_WALLET_KEY = "utee_voucher_wallet";

    window.getVoucherWallet = function() {
        try {
            const stored = localStorage.getItem(VOUCHER_WALLET_KEY);
            return stored ? JSON.parse(stored) : [];
        } catch (e) {
            return [];
        }
    };

    window.isVoucherInWallet = function(code) {
        if (!code) return false;
        const wallet = window.getVoucherWallet();
        return wallet.includes(code.trim().toUpperCase());
    };

    window.saveVoucherToWallet = function(code) {
        if (!code) return;
        const upper = code.trim().toUpperCase();
        let wallet = window.getVoucherWallet();
        if (!wallet.includes(upper)) {
            wallet.push(upper);
            try {
                localStorage.setItem(VOUCHER_WALLET_KEY, JSON.stringify(wallet));
            } catch (e) {
                console.error("Lỗi khi lưu voucher:", e);
            }
        }
        window.updateVoucherSaveButtons();
        if (typeof window.showToast === "function") {
            window.showToast(`✨ Đã lưu mã <strong>${upper}</strong> vào Kho Voucher của bạn! Sẵn sàng dùng khi đặt món.`);
        }
    };

    window.removeVoucherFromWallet = function(code) {
        if (!code) return;
        const upper = code.trim().toUpperCase();
        let wallet = window.getVoucherWallet();
        wallet = wallet.filter(c => c !== upper);
        try {
            localStorage.setItem(VOUCHER_WALLET_KEY, JSON.stringify(wallet));
        } catch (e) {}
        window.updateVoucherSaveButtons();
    };

    window.updateVoucherSaveButtons = function() {
        const wallet = window.getVoucherWallet();
        document.querySelectorAll(".btn-save-voucher").forEach(btn => {
            const code = (btn.dataset.voucherCode || "").toUpperCase();
            if (code && wallet.includes(code)) {
                btn.classList.add("saved");
                btn.innerHTML = '<i class="fa-solid fa-bookmark"></i> <span>Đã lưu</span>';
                btn.title = 'Mã này đã có trong Kho Voucher của bạn';
            } else {
                btn.classList.remove("saved");
                btn.innerHTML = '<i class="fa-regular fa-bookmark"></i> <span>Lưu vào kho</span>';
                btn.title = 'Lưu vào Kho Voucher';
            }
        });
    };

    // Auto sync save buttons on load
    window.updateVoucherSaveButtons();

    // ==========================================================================
    // 4. Hỗ trợ Click Toggle cho User Menu & đóng khi click ra ngoài
    // ==========================================================================
    const userMenu = document.querySelector(".user-menu");
    if (userMenu) {
        userMenu.addEventListener("click", (e) => {
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

    // ==========================================================================
    // 5. FEATURE 3: NÂNG CẤP THỰC ĐƠN: Live Search & Multi-Filter Engine (0s latency)
    // ==========================================================================
    const foodContainer = document.getElementById("menu-food-container");
    if (foodContainer) {
        const searchInput = document.getElementById("menu-live-search");
        const clearSearchBtn = document.getElementById("menu-search-clear");
        const catButtons = document.querySelectorAll(".cat-pill-btn");
        const priceChips = document.querySelectorAll(".price-chip");
        const sortSelect = document.getElementById("menu-sort-select");
        const visibleCountEl = document.getElementById("menu-visible-count");
        const noResultsEl = document.getElementById("menu-no-results");
        const resetFiltersBtn = document.getElementById("btn-reset-filters");

        const foodCards = Array.from(foodContainer.querySelectorAll(".food-card"));

        let currentCat = "all";
        let currentPrice = "all";
        let currentKeyword = searchInput ? searchInput.value.trim() : "";
        let currentSort = "default";

        // Khởi tạo trạng thái từ URL parameters nếu có
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has("cat")) {
            const catParam = urlParams.get("cat");
            const targetBtn = Array.from(catButtons).find(b => b.dataset.catId === catParam);
            if (targetBtn) {
                catButtons.forEach(b => b.classList.remove("active"));
                targetBtn.classList.add("active");
                currentCat = catParam;
            }
        }
        if (urlParams.has("search")) {
            currentKeyword = urlParams.get("search").trim();
            if (searchInput) searchInput.value = currentKeyword;
            if (clearSearchBtn && currentKeyword) clearSearchBtn.classList.remove("d-none");
        }

        const applyFilters = () => {
            const normKeyword = normalizeStr(currentKeyword);
            let visibleCards = [];

            foodCards.forEach((card, idx) => {
                const cardName = card.dataset.name || "";
                const cardDesc = card.dataset.desc || "";
                const cardRest = card.dataset.restaurant || "";
                const cardCat = card.dataset.category || "";
                const cardPrice = parseFloat(card.dataset.price) || 0;

                // 1. Kiểm tra danh mục
                const matchCat = (currentCat === "all" || cardCat === currentCat);

                // 2. Kiểm tra khoảng giá
                let matchPrice = true;
                if (currentPrice === "under35") {
                    matchPrice = (cardPrice < 35000);
                } else if (currentPrice === "35to70") {
                    matchPrice = (cardPrice >= 35000 && cardPrice <= 70000);
                } else if (currentPrice === "over70") {
                    matchPrice = (cardPrice > 70000);
                }

                // 3. Kiểm tra từ khóa tìm kiếm (hỗ trợ cả có dấu và không dấu)
                let matchKeyword = true;
                if (normKeyword) {
                    const fullText = normalizeStr(`${cardName} ${cardDesc} ${cardRest}`);
                    matchKeyword = fullText.includes(normKeyword);
                }

                if (matchCat && matchPrice && matchKeyword) {
                    card.classList.remove("filtered-out");
                    card.classList.remove("card-fade-in");
                    void card.offsetWidth; // trigger reflow
                    card.classList.add("card-fade-in");
                    card.style.animationDelay = `${Math.min(visibleCards.length * 0.03, 0.25)}s`;
                    visibleCards.push(card);
                } else {
                    card.classList.add("filtered-out");
                    card.classList.remove("card-fade-in");
                    card.style.animationDelay = "0s";
                }
            });

            // 4. Sắp xếp danh sách hiển thị
            if (currentSort === "price-asc") {
                visibleCards.sort((a, b) => (parseFloat(a.dataset.price) || 0) - (parseFloat(b.dataset.price) || 0));
            } else if (currentSort === "price-desc") {
                visibleCards.sort((a, b) => (parseFloat(b.dataset.price) || 0) - (parseFloat(a.dataset.price) || 0));
            } else if (currentSort === "name-asc") {
                visibleCards.sort((a, b) => (a.dataset.name || "").localeCompare(b.dataset.name || "", "vi"));
            } else if (currentSort === "rating-desc") {
                visibleCards.sort((a, b) => (parseFloat(b.dataset.rating) || 0) - (parseFloat(a.dataset.rating) || 0));
            } else {
                // Mặc định: theo thứ tự gốc
                visibleCards.sort((a, b) => (parseInt(a.dataset.index) || 0) - (parseInt(b.dataset.index) || 0));
            }

            // Gắn lại vào DOM theo thứ tự đã sắp xếp
            visibleCards.forEach(card => foodContainer.appendChild(card));

            // Cập nhật số lượng món hiển thị
            if (visibleCountEl) {
                visibleCountEl.innerText = visibleCards.length;
            }

            // Hiển thị/ẩn Empty state
            if (noResultsEl) {
                if (visibleCards.length === 0) {
                    noResultsEl.style.display = "block";
                } else {
                    noResultsEl.style.display = "none";
                }
            }
        };

        // Lắng nghe sự kiện Search (Debounce 120ms)
        let searchTimeout = null;
        if (searchInput) {
            searchInput.addEventListener("input", (e) => {
                clearTimeout(searchTimeout);
                currentKeyword = e.target.value;
                if (clearSearchBtn) {
                    if (currentKeyword.trim()) {
                        clearSearchBtn.classList.remove("d-none");
                    } else {
                        clearSearchBtn.classList.add("d-none");
                    }
                }
                searchTimeout = setTimeout(applyFilters, 120);
            });
        }

        // Nút xóa tìm kiếm
        if (clearSearchBtn) {
            clearSearchBtn.addEventListener("click", () => {
                if (searchInput) {
                    searchInput.value = "";
                    searchInput.focus();
                }
                currentKeyword = "";
                clearSearchBtn.classList.add("d-none");
                applyFilters();
            });
        }

        // Chuyển tab danh mục
        catButtons.forEach(btn => {
            btn.addEventListener("click", () => {
                catButtons.forEach(b => b.classList.remove("active"));
                btn.classList.add("active");
                currentCat = btn.dataset.catId || "all";
                applyFilters();
            });
        });

        // Chuyển chip khoảng giá
        priceChips.forEach(chip => {
            chip.addEventListener("click", () => {
                priceChips.forEach(c => c.classList.remove("active"));
                chip.classList.add("active");
                currentPrice = chip.dataset.price || "all";
                applyFilters();
            });
        });

        // Chọn sắp xếp
        if (sortSelect) {
            sortSelect.addEventListener("change", (e) => {
                currentSort = e.target.value;
                applyFilters();
            });
        }

        // Nút xóa tất cả bộ lọc khi rỗng
        if (resetFiltersBtn) {
            resetFiltersBtn.addEventListener("click", () => {
                currentCat = "all";
                currentPrice = "all";
                currentKeyword = "";
                currentSort = "default";

                if (searchInput) searchInput.value = "";
                if (clearSearchBtn) clearSearchBtn.classList.add("d-none");
                if (sortSelect) sortSelect.value = "default";

                catButtons.forEach(b => b.classList.toggle("active", b.dataset.catId === "all"));
                priceChips.forEach(c => c.classList.toggle("active", c.dataset.price === "all"));

                applyFilters();
            });
        }

        // Kích hoạt lọc lần đầu
        applyFilters();
    }

    // ==========================================================================
    // 5.1. FEATURE 3: Instant Category Filter Trên Trang Chủ (Home Page)
    // ==========================================================================
    const homeFoodGrid = document.getElementById("home-food-grid");
    const homeCatCards = document.querySelectorAll(".category-section .cat-card");
    const homeFilterIndicator = document.getElementById("home-filter-indicator");
    const homeFilterCatName = document.getElementById("home-filter-cat-name");
    const homeFilterCount = document.getElementById("home-filter-count");
    const btnResetHomeFilter = document.getElementById("btn-reset-home-filter");

    if (homeFoodGrid && homeCatCards.length > 0) {
        const homeCards = Array.from(homeFoodGrid.querySelectorAll(".food-card"));

        const filterHomeByCategory = (catId, catName) => {
            let visibleCount = 0;
            homeCards.forEach((card, idx) => {
                const cardCat = card.dataset.category || "";
                if (!catId || catId === "all" || cardCat === String(catId)) {
                    card.classList.remove("filtered-out");
                    card.classList.remove("card-fade-in");
                    void card.offsetWidth;
                    card.classList.add("card-fade-in");
                    card.style.animationDelay = `${Math.min(visibleCount * 0.04, 0.3)}s`;
                    visibleCount++;
                } else {
                    card.classList.add("filtered-out");
                    card.classList.remove("card-fade-in");
                    card.style.animationDelay = "0s";
                }
            });

            if (homeFilterIndicator && homeFilterCatName && homeFilterCount) {
                if (catId && catId !== "all") {
                    homeFilterIndicator.style.display = "flex";
                    homeFilterCatName.innerText = catName || `Danh mục #${catId}`;
                    homeFilterCount.innerText = visibleCount;
                } else {
                    homeFilterIndicator.style.display = "none";
                }
            }
        };

        homeCatCards.forEach(catCard => {
            catCard.addEventListener("click", (e) => {
                e.preventDefault();
                const catId = catCard.dataset.catId;
                const catName = catCard.dataset.catName || catCard.querySelector(".cat-card-title")?.innerText.trim();

                const wasActive = catCard.classList.contains("active");
                homeCatCards.forEach(c => c.classList.remove("active"));

                if (wasActive) {
                    // Reset filter
                    filterHomeByCategory("all", "");
                } else {
                    catCard.classList.add("active");
                    filterHomeByCategory(catId, catName);

                    // Cuộn mượt mà xuống phần thực đơn đề xuất
                    const recommendSec = document.getElementById("recommend-section");
                    if (recommendSec) {
                        const navH = document.querySelector(".navbar")?.offsetHeight || 70;
                        const targetY = recommendSec.getBoundingClientRect().top + window.pageYOffset - navH - 15;
                        window.scrollTo({ top: targetY, behavior: "smooth" });
                    }
                }
            });
        });

        if (btnResetHomeFilter) {
            btnResetHomeFilter.addEventListener("click", () => {
                homeCatCards.forEach(c => c.classList.remove("active"));
                filterHomeByCategory("all", "");
            });
        }
    }

    // ==========================================================================
    // 6. NÂNG CẤP THỰC ĐƠN: Chế độ Xem Lưới / Danh Sách (Grid vs List View)
    // ==========================================================================
    const viewGridBtn = document.getElementById("view-grid-btn");
    const viewListBtn = document.getElementById("view-list-btn");
    if (viewGridBtn && viewListBtn && foodContainer) {
        const setViewMode = (mode) => {
            if (mode === "list") {
                foodContainer.classList.add("view-list");
                viewListBtn.classList.add("active");
                viewGridBtn.classList.remove("active");
            } else {
                foodContainer.classList.remove("view-list");
                viewGridBtn.classList.add("active");
                viewListBtn.classList.remove("active");
            }
            try {
                localStorage.setItem("utee_menu_view_mode", mode);
            } catch (ignored) {}
        };

        viewGridBtn.addEventListener("click", () => setViewMode("grid"));
        viewListBtn.addEventListener("click", () => setViewMode("list"));

        // Khôi phục tùy chọn đã lưu của người dùng
        const savedMode = localStorage.getItem("utee_menu_view_mode");
        if (savedMode === "list") {
            setViewMode("list");
        }
    }

    // ==========================================================================
    // 8. FEATURE 1: AJAX Add-to-Cart & Parabolic Curved Flying Animation + Audio Chime
    // ==========================================================================
    const floatingMiniCart = document.getElementById("floating-mini-cart");
    const fmcBadge = document.getElementById("fmc-badge-count");
    const fmcCount = document.getElementById("fmc-item-count");
    const fmcTotal = document.getElementById("fmc-total-price");
    const navCartBadge = document.querySelector(".cart-nav-link .cart-badge");

    function createFlyingParabolicItem(startElement, targetElement, imageSrc) {
        if (!startElement || !targetElement) return;

        const startRect = startElement.getBoundingClientRect();
        const targetRect = targetElement.getBoundingClientRect();

        const flyingImg = document.createElement("img");
        flyingImg.src = imageSrc || (startElement.tagName === "IMG" ? startElement.src : "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100");
        flyingImg.className = "flying-cart-item";
        flyingImg.style.left = `${startRect.left + startRect.width / 2 - 32}px`;
        flyingImg.style.top = `${startRect.top + startRect.height / 2 - 32}px`;
        document.body.appendChild(flyingImg);

        // Kích hoạt transition bay vòng cung parabol hướng tới Giỏ Hàng
        requestAnimationFrame(() => {
            const destX = targetRect.left + targetRect.width / 2 - 16;
            const destY = targetRect.top + targetRect.height / 2 - 16;
            const diffX = destX - (startRect.left + startRect.width / 2 - 32);
            const diffY = destY - (startRect.top + startRect.height / 2 - 32);

            flyingImg.style.transform = `translate(${diffX}px, ${diffY}px) scale(0.2) rotate(360deg)`;
            flyingImg.style.opacity = "0.2";
        });

        setTimeout(() => {
            flyingImg.remove();
            
            // Hiệu ứng rung nảy và hào quang cho Cart Badge & Nav Link
            const cartLink = document.querySelector(".cart-nav-link");
            if (cartLink) {
                cartLink.classList.remove("cart-nav-pulse");
                void cartLink.offsetWidth; // Trigger reflow
                cartLink.classList.add("cart-nav-pulse");
                setTimeout(() => cartLink.classList.remove("cart-nav-pulse"), 500);
            }

            targetElement.classList.remove("cart-badge-bounce");
            void targetElement.offsetWidth; // Trigger reflow
            targetElement.classList.add("cart-badge-bounce");
            setTimeout(() => targetElement.classList.remove("cart-badge-bounce"), 600);

            // Phát âm thanh chime chúc mừng
            playCartChime();
        }, 680);
    }

    function handleAjaxAddToCart(foodId, quantity, sourceImgEl, callback) {
        const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 1)) || "";
        const cartUrl = `${contextPath}/cart`;

        const formData = new URLSearchParams();
        formData.append("action", "add");
        formData.append("foodId", foodId);
        formData.append("quantity", quantity);
        formData.append("ajax", "true");

        fetch(cartUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest",
                "Accept": "application/json"
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.requireLogin) {
                showToast("⚠️ Vui lòng đăng nhập để thêm món vào giỏ hàng!", {
                    duration: 3500,
                    actionUrl: data.loginUrl || `${contextPath}/auth?action=login`,
                    actionText: "Đăng nhập"
                });
                setTimeout(() => {
                    window.location.href = data.loginUrl || `${contextPath}/auth?action=login`;
                }, 1400);
                return;
            }

            if (data.success) {
                // 1. Hiệu ứng bay vào giỏ hàng (bay lên Navbar icon hoặc Floating mini-cart)
                const targetCart = navCartBadge || floatingMiniCart;
                if (sourceImgEl && targetCart) {
                    createFlyingParabolicItem(sourceImgEl, targetCart, data.foodImage);
                } else {
                    // Nếu không có ảnh nguồn vẫn phát chime và rung badge
                    playCartChime();
                    if (navCartBadge) {
                        navCartBadge.classList.add("cart-badge-bounce");
                        setTimeout(() => navCartBadge.classList.remove("cart-badge-bounce"), 600);
                    }
                }

                // 2. Cập nhật số lượng trên Navbar badge và Mobile Bottom Nav
                if (navCartBadge) {
                    navCartBadge.innerText = data.cartCount;
                }
                const bottomCartBadge = document.getElementById("bottomCartBadge");
                if (bottomCartBadge) {
                    bottomCartBadge.innerText = data.cartCount;
                    if (data.cartCount > 0) bottomCartBadge.classList.remove("d-none");
                }
                const drawerBadge = document.querySelector(".drawer-badge");
                if (drawerBadge) {
                    drawerBadge.innerText = data.cartCount;
                }

                // 3. Cập nhật thanh Floating Mini-Cart ghim đáy
                if (floatingMiniCart) {
                    if (fmcBadge) fmcBadge.innerText = data.cartCount;
                    if (fmcCount) fmcCount.innerText = data.cartCount;
                    if (fmcTotal) fmcTotal.innerText = formatVND(data.totalPrice);
                    floatingMiniCart.classList.add("show");
                }

                // 3.1. Cập nhật Mini-Cart Hover Dropdown & Freeship Progress Bar trên thanh Navbar
                document.querySelectorAll(".cart-hover-dropdown").forEach(dropdown => {
                    const countEl = dropdown.querySelector(".cart-hover-count");
                    if (countEl) countEl.innerText = `(${data.cartCount} món)`;
                    const totalValEl = dropdown.querySelector(".cart-hover-total-val");
                    if (totalValEl) totalValEl.innerText = formatVND(data.totalPrice);

                    const freeshipTarget = 99000;
                    const diff = freeshipTarget - (data.totalPrice || 0);
                    const percent = Math.min(100, Math.round(((data.totalPrice || 0) / freeshipTarget) * 100));

                    const freeshipBox = dropdown.querySelector(".cart-hover-freeship-box");
                    if (freeshipBox) {
                        const bar = freeshipBox.querySelector(".freeship-progress-bar");
                        if (bar) bar.style.width = `${percent}%`;
                        const textRow = freeshipBox.querySelector(".freeship-header-row");
                        if (diff <= 0) {
                            freeshipBox.classList.add("achieved");
                            if (textRow) {
                                textRow.innerHTML = `
                                    <span class="freeship-text-achieved"><i class="fa-solid fa-circle-check text-success"></i> Bạn đã được <strong>FREESHIP 15.000 đ</strong>!</span>
                                    <i class="fa-solid fa-motorcycle freeship-bike-icon"></i>
                                `;
                            }
                        } else {
                            freeshipBox.classList.remove("achieved");
                            if (textRow) {
                                textRow.innerHTML = `
                                    <span class="freeship-text-need">Mua thêm <strong>${formatVND(diff)}</strong> để được <strong>FREESHIP</strong></span>
                                    <i class="fa-solid fa-motorcycle freeship-bike-icon"></i>
                                `;
                            }
                        }
                    }

                    const emptyEl = dropdown.querySelector(".cart-hover-empty");
                    if (emptyEl) {
                        dropdown.innerHTML = `
                            <div class="cart-hover-header">
                                <span class="cart-hover-title"><i class="fa-solid fa-bag-shopping text-primary"></i> Món ăn trong giỏ</span>
                                <span class="cart-hover-count">(${data.cartCount} món)</span>
                            </div>
                            <div class="cart-hover-freeship-box ${diff <= 0 ? 'achieved' : ''}">
                                <div class="freeship-header-row">
                                    ${diff <= 0 
                                        ? '<span class="freeship-text-achieved"><i class="fa-solid fa-circle-check text-success"></i> Bạn đã được <strong>FREESHIP 15.000 đ</strong>!</span>' 
                                        : `<span class="freeship-text-need">Mua thêm <strong>${formatVND(diff)}</strong> để được <strong>FREESHIP</strong></span>`
                                    }
                                    <i class="fa-solid fa-motorcycle freeship-bike-icon"></i>
                                </div>
                                <div class="freeship-progress-track">
                                    <div class="freeship-progress-bar" style="width: ${percent}%;"></div>
                                </div>
                            </div>
                            <div class="cart-hover-list">
                                <a href="${contextPath}/cart" class="cart-hover-item">
                                    <img src="${data.foodImage || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'}" alt="${data.foodName}" class="cart-hover-thumb" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100'">
                                    <div class="cart-hover-info">
                                        <div class="cart-hover-name">${data.foodName || 'Món ăn'}</div>
                                        <div class="cart-hover-meta">
                                            <span class="cart-hover-qty">SL: <strong>x${quantity}</strong></span>
                                            <span class="cart-hover-price">${formatVND(data.totalPrice)}</span>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="cart-hover-footer">
                                <div class="cart-hover-total-row">
                                    <span>Tổng thanh toán:</span>
                                    <strong class="cart-hover-total-val">${formatVND(data.totalPrice)}</strong>
                                </div>
                                <a href="${contextPath}/cart" class="btn btn-primary btn-sm btn-cart-hover-cta">
                                    <span>Xem Giỏ Hàng &amp; Đặt Món</span>
                                    <i class="fa-solid fa-arrow-right"></i>
                                </a>
                            </div>
                        `;
                    }
                });

                // Nếu đang ở trang giỏ hàng (/cart) mà bấm gọi thêm món upsell, reload nhẹ lại trang sau toast
                if (window.location.pathname.endsWith('/cart')) {
                    setTimeout(() => {
                        window.location.reload();
                    }, 650);
                }

                // 4. Hiển thị Rich Toast Thông báo với thumbnail và CTA
                showToast(`Đã thêm <strong>${data.foodName || "món ăn"}</strong> vào giỏ!`, {
                    image: data.foodImage,
                    subtext: `Số lượng: +${quantity} • Tổng giỏ: ${formatVND(data.totalPrice)}`,
                    actionUrl: `${contextPath}/cart`,
                    actionText: "Xem giỏ"
                });

                if (typeof callback === "function") callback(data);
            }
        })
        .catch(err => {
            console.error("Lỗi thêm món AJAX:", err);
            showToast("⚠️ Không thể thêm món vào giỏ. Vui lòng thử lại!");
        });
    }

    // Lắng nghe submit form đặt món AJAX trên thẻ món & trang chi tiết
    document.addEventListener("submit", (e) => {
        const ajaxForm = e.target.closest(".ajax-cart-form, .detail-order-form");
        if (ajaxForm) {
            e.preventDefault();
            const foodIdInput = ajaxForm.querySelector('input[name="foodId"]');
            if (!foodIdInput) return;
            const foodId = foodIdInput.value;
            const quantityInput = ajaxForm.querySelector('input[name="quantity"]');
            const quantity = (quantityInput ? quantityInput.value : 1) || 1;

            let imgEl = null;
            const card = ajaxForm.closest(".food-card");
            if (card) {
                imgEl = card.querySelector(".food-image");
            } else {
                imgEl = document.querySelector(".detail-main-img");
            }

            const btn = ajaxForm.querySelector(".btn-add-cart, .btn-add-full, button[type='submit']");
            let originalHtml = "";

            if (btn) {
                originalHtml = btn.innerHTML;
                btn.classList.add("btn-added");
                btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> <span>Đã thêm!</span>';
            }

            handleAjaxAddToCart(foodId, quantity, imgEl, () => {
                setTimeout(() => {
                    if (btn) {
                        btn.classList.remove("btn-added");
                        btn.innerHTML = originalHtml || '<i class="fa-solid fa-cart-plus"></i> <span>Đặt món</span>';
                    }
                }, 1200);
            });
        }
    });

    // ==========================================================================
    // Mobile Drawer (Offcanvas Menu) Toggle Logic
    // ==========================================================================
    const mobileMenuToggle = document.getElementById("mobileMenuToggle");
    const mobileDrawer = document.getElementById("mobileDrawer");
    const mobileDrawerBackdrop = document.getElementById("mobileDrawerBackdrop");
    const mobileDrawerClose = document.getElementById("mobileDrawerClose");

    function openMobileDrawer() {
        if (mobileDrawer && mobileDrawerBackdrop) {
            mobileDrawer.classList.add("open");
            mobileDrawerBackdrop.classList.add("open");
            document.body.classList.add("drawer-open");
        }
    }

    function closeMobileDrawer() {
        if (mobileDrawer && mobileDrawerBackdrop) {
            mobileDrawer.classList.remove("open");
            mobileDrawerBackdrop.classList.remove("open");
            document.body.classList.remove("drawer-open");
        }
    }

    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener("click", openMobileDrawer);
    }
    if (mobileDrawerClose) {
        mobileDrawerClose.addEventListener("click", closeMobileDrawer);
    }
    if (mobileDrawerBackdrop) {
        mobileDrawerBackdrop.addEventListener("click", closeMobileDrawer);
    }
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && mobileDrawer && mobileDrawer.classList.contains("open")) {
            closeMobileDrawer();
        }
    });
});
