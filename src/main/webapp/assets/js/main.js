// FoodZone - JavaScript tương tác giao diện người dùng
document.addEventListener("DOMContentLoaded", () => {
    console.log("FoodZone - Web App Loaded Successfully!");

    // Hiệu ứng shadow cho Navbar khi cuộn trang
    const navbar = document.querySelector(".navbar");
    window.addEventListener("scroll", () => {
        if (window.scrollY > 30) {
            navbar.style.boxShadow = "0 4px 20px rgba(0, 0, 0, 0.08)";
        } else {
            navbar.style.boxShadow = "var(--shadow-sm)";
        }
    });

    // Thông báo Toast nhỏ khi thêm vào giỏ hàng
    const addCartForms = document.querySelectorAll(".add-cart-form");
    addCartForms.forEach(form => {
        form.addEventListener("submit", (e) => {
            // Cho phép form submit bình thường và hiển thị hiệu ứng bấm
            const btn = form.querySelector(".btn-add-cart");
            if (btn) {
                btn.innerHTML = '<i class="fa-solid fa-check"></i> Đã thêm';
                btn.style.background = "#10ac84";
            }
        });
    });
});
