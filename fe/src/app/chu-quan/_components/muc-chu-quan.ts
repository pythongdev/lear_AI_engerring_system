// Danh sách DUY NHẤT các trang và nhóm điều hướng của khung chủ quán (P4A-01, T-335). Mỗi bước thêm mục của mình cùng lượt dựng trang;
// test chu-quan.test.tsx đỏ khi một mục trỏ tới route chưa có page.tsx.
export const mucChuQuan = [
  { nhan: "Tổng quan", route: "/chu-quan", nhom: "truc_tiep" },
  { nhan: "Vận hành", route: "/chu-quan/van-hanh", nhom: "truc_tiep" },
  { nhan: "Tổng kết", route: "/chu-quan/tong-ket", nhom: "truc_tiep" },
  { nhan: "Sản phẩm", route: "/chu-quan/san-pham", nhom: "ban_hang" },
  { nhan: "Menu & giá", route: "/chu-quan/menu-gia", nhom: "ban_hang" },
  { nhan: "Danh mục", route: "/chu-quan/danh-muc", nhom: "ban_hang" },
  { nhan: "Combo", route: "/chu-quan/combo", nhom: "ban_hang" },
  { nhan: "Topping", route: "/chu-quan/topping", nhom: "ban_hang" },
  { nhan: "Nhân viên", route: "/chu-quan/nhan-vien", nhom: "nhan_su" },
  { nhan: "Giao việc", route: "/chu-quan/giao-viec", nhom: "nhan_su" },
  { nhan: "Khoản chi", route: "/chu-quan/khoan-chi", nhom: "kho_chi" },
  { nhan: "Đào tạo", route: "/chu-quan/dao-tao", nhom: "nhan_su" },
] as const;
