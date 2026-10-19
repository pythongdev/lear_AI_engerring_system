// Danh sách DUY NHẤT các trang của khung chủ quán (P4A-01). Mỗi bước thêm mục của mình cùng lượt dựng trang;
// test chu-quan.test.tsx đỏ khi một mục trỏ tới route chưa có page.tsx.
export const mucChuQuan = [
  { nhan: "Tổng quan", route: "/chu-quan" },
  { nhan: "Tổng kết", route: "/chu-quan/tong-ket" },
  { nhan: "Sản phẩm", route: "/chu-quan/san-pham" },
  { nhan: "Danh mục", route: "/chu-quan/danh-muc" },
  { nhan: "Combo", route: "/chu-quan/combo" },
  { nhan: "Topping", route: "/chu-quan/topping" },
  { nhan: "Nhân viên", route: "/chu-quan/nhan-vien" },
  { nhan: "Giao việc", route: "/chu-quan/giao-viec" },
  { nhan: "Nguyên liệu", route: "/chu-quan/nguyen-lieu" },
  { nhan: "Kho", route: "/chu-quan/kho" },
  { nhan: "Khoản chi", route: "/chu-quan/khoan-chi" },
  { nhan: "Đào tạo", route: "/chu-quan/dao-tao" },
] as const;
