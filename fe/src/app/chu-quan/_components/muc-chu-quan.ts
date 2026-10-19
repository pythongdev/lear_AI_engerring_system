// Danh sách DUY NHẤT các trang của khung chủ quán (P4A-01). Mỗi bước thêm mục của mình cùng lượt dựng trang;
// test chu-quan.test.tsx đỏ khi một mục trỏ tới route chưa có page.tsx.
export const mucChuQuan = [
  { nhan: "Tổng quan", route: "/chu-quan" },
  { nhan: "Tổng kết", route: "/chu-quan/tong-ket" },
  { nhan: "Sản phẩm", route: "/chu-quan/san-pham" },
] as const;
