// ==========================================================================
// Utee - JavaScript Tương Tác Giao Diện Người Dùng
// Design Intelligence: UI/UX Pro Max
// (Live Search, Smart Filters, Grid/List Switcher, Quick View Modal,
//  AJAX Add-to-Cart with Flying Parabolic Animation, Floating Mini-Cart)
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
                <img src="${options.image}" alt="" class="toast-thumb" onerror="this.style.display='none'">
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
            setTimeout(() => toast.remove(), 300);
        }, duration);
    }
    window.showToast = showToast;

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
    // 5. NÂNG CẤP THỰC ĐƠN: Live Search & Multi-Filter Engine
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

            foodCards.forEach(card => {
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
                    visibleCards.push(card);
                } else {
                    card.classList.add("filtered-out");
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

        // Lắng nghe sự kiện Search (Debounce 150ms)
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
                searchTimeout = setTimeout(applyFilters, 150);
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
    // 7. NÂNG CẤP THỰC ĐƠN: Quick View Modal (Xem Nhanh Món Ăn)
    // ==========================================================================
    const qvModal = document.getElementById("quick-view-modal");
    if (qvModal) {
        const qvCloseBtn = document.getElementById("qv-close-btn");
        const qvImg = document.getElementById("qv-food-image");
        const qvTag = document.getElementById("qv-food-tag");
        const qvStore = document.getElementById("qv-food-store");
        const qvTitle = document.getElementById("qv-modal-title");
        const qvDesc = document.getElementById("qv-food-desc");
        const qvPrice = document.getElementById("qv-food-price");
        const qvQtyInput = document.getElementById("qv-qty-input");
        const qvQtyMinus = document.getElementById("qv-qty-minus");
        const qvQtyPlus = document.getElementById("qv-qty-plus");
        const qvSubtotal = document.getElementById("qv-subtotal-price");
        const qvAddBtn = document.getElementById("qv-add-cart-btn");
        const qvDetailLink = document.getElementById("qv-detail-link");

        let activeFoodId = null;
        let activeFoodPrice = 0;
        let activeFoodName = "";
        let activeFoodImg = "";

        const updateQvSubtotal = () => {
            const qty = parseInt(qvQtyInput.value) || 1;
            const subtotal = activeFoodPrice * qty;
            qvSubtotal.innerText = formatVND(subtotal);
        };

        const openQuickView = (card) => {
            activeFoodId = card.dataset.id;
            activeFoodPrice = parseFloat(card.dataset.price) || 0;
            activeFoodName = card.dataset.name || "Món ngon";
            activeFoodImg = card.dataset.image || "";

            const foodDesc = card.dataset.desc || "Món ăn thơm ngon, bổ dưỡng chuẩn vị Utee.";
            const foodStore = card.dataset.restaurant || "Quán đối tác Utee";
            const foodTag = card.querySelector(".food-tag") ? card.querySelector(".food-tag").innerText : "Món ngon";

            if (qvImg) {
                qvImg.src = activeFoodImg;
                qvImg.alt = activeFoodName;
            }
            if (qvTag) qvTag.innerText = foodTag;
            if (qvStore) qvStore.innerText = foodStore;
            if (qvTitle) qvTitle.innerText = activeFoodName;
            if (qvDesc) qvDesc.innerText = foodDesc;
            if (qvPrice) qvPrice.innerText = formatVND(activeFoodPrice);
            if (qvQtyInput) qvQtyInput.value = 1;
            if (qvDetailLink) {
                const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 1)) || "";
                qvDetailLink.href = `${contextPath}/food-detail?id=${activeFoodId}`;
            }

            updateQvSubtotal();
            qvModal.classList.add("open");
            qvModal.setAttribute("aria-hidden", "false");
            document.body.style.overflow = "hidden";
        };

        const closeQuickView = () => {
            qvModal.classList.remove("open");
            qvModal.setAttribute("aria-hidden", "true");
            document.body.style.overflow = "";
        };

        // Bắt sự kiện click vào nút "Xem nhanh" trên thẻ món
        document.addEventListener("click", (e) => {
            const qvBtn = e.target.closest(".btn-quick-view");
            if (qvBtn) {
                e.preventDefault();
                e.stopPropagation();
                const card = qvBtn.closest(".food-card");
                if (card) openQuickView(card);
            }
        });

        if (qvCloseBtn) qvCloseBtn.addEventListener("click", closeQuickView);

        qvModal.addEventListener("click", (e) => {
            if (e.target === qvModal) closeQuickView();
        });

        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape" && qvModal.classList.contains("open")) {
                closeQuickView();
            }
        });

        if (qvQtyMinus) {
            qvQtyMinus.addEventListener("click", () => {
                let qty = parseInt(qvQtyInput.value) || 1;
                if (qty > 1) {
                    qvQtyInput.value = qty - 1;
                    updateQvSubtotal();
                }
            });
        }

        if (qvQtyPlus) {
            qvQtyPlus.addEventListener("click", () => {
                let qty = parseInt(qvQtyInput.value) || 1;
                if (qty < 99) {
                    qvQtyInput.value = qty + 1;
                    updateQvSubtotal();
                }
            });
        }

        // Đặt món từ Quick View Modal
        if (qvAddBtn) {
            qvAddBtn.addEventListener("click", () => {
                if (!activeFoodId) return;
                const qty = parseInt(qvQtyInput.value) || 1;
                handleAjaxAddToCart(activeFoodId, qty, qvImg, () => {
                    closeQuickView();
                });
            });
        }
    }

    // ==========================================================================
    // 8. NÂNG CẤP THỰC ĐƠN: AJAX Add-to-Cart & Hiệu Ứng Bay Vào Giỏ Hàng
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
        flyingImg.src = imageSrc || "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100";
        flyingImg.className = "flying-cart-item";
        flyingImg.style.left = `${startRect.left + startRect.width / 2 - 32}px`;
        flyingImg.style.top = `${startRect.top + startRect.height / 2 - 32}px`;
        document.body.appendChild(flyingImg);

        // Kích hoạt transition bay vòng cung parabol
        requestAnimationFrame(() => {
            const destX = targetRect.left + targetRect.width / 2 - 16;
            const destY = targetRect.top + targetRect.height / 2 - 16;
            const diffX = destX - (startRect.left + startRect.width / 2 - 32);
            const diffY = destY - (startRect.top + startRect.height / 2 - 32);

            flyingImg.style.transform = `translate(${diffX}px, ${diffY}px) scale(0.3) rotate(360deg)`;
            flyingImg.style.opacity = "0.2";
        });

        setTimeout(() => {
            flyingImg.remove();
            // Hiệu ứng nảy nhẹ của icon giỏ hàng khi đón nhận món
            targetElement.classList.add("cart-badge-bounce");
            setTimeout(() => targetElement.classList.remove("cart-badge-bounce"), 400);
        }, 720);
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
                }

                // 2. Cập nhật số lượng trên Navbar badge
                if (navCartBadge) {
                    navCartBadge.innerText = data.cartCount;
                }

                // 3. Cập nhật thanh Floating Mini-Cart ghim đáy
                if (floatingMiniCart) {
                    if (fmcBadge) fmcBadge.innerText = data.cartCount;
                    if (fmcCount) fmcCount.innerText = data.cartCount;
                    if (fmcTotal) fmcTotal.innerText = formatVND(data.totalPrice);
                    floatingMiniCart.classList.add("show");
                }

                // 4. Hiển thị Rich Toast Thông báo
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

    // Lắng nghe submit form đặt món AJAX trên các thẻ món
    document.addEventListener("submit", (e) => {
        const ajaxForm = e.target.closest(".ajax-cart-form");
        if (ajaxForm) {
            e.preventDefault();
            const foodId = ajaxForm.querySelector('input[name="foodId"]').value;
            const quantity = (ajaxForm.querySelector('input[name="quantity"]') ? ajaxForm.querySelector('input[name="quantity"]').value : 1) || 1;
            const card = ajaxForm.closest(".food-card");
            const imgEl = card ? card.querySelector(".food-image") : null;
            const btn = ajaxForm.querySelector(".btn-add-cart");

            if (btn) {
                btn.classList.add("btn-added");
                btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> <span>Đã thêm</span>';
            }

            handleAjaxAddToCart(foodId, quantity, imgEl, () => {
                setTimeout(() => {
                    if (btn) {
                        btn.classList.remove("btn-added");
                        btn.innerHTML = '<i class="fa-solid fa-cart-plus"></i> <span>Đặt món</span>';
                    }
                }, 1000);
            });
        }
    });
});
