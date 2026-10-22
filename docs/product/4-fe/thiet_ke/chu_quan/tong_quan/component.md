# Component của trang Tổng quan

Danh mục các khối có tên trong bản thiết kế [tong-quan.html](tong-quan.html).
Mỗi khối trong trang mang thuộc tính `data-component="<Tên>"`. Dùng đúng tên
đó khi mô tả chỗ cần sửa.

> Đây là bản thiết kế tĩnh, số liệu chỉ để minh hoạ, **không phải hợp đồng**.
> Route và component thật nằm ở
> [01-khung-fe.md](../../../01-khung-fe.md).

## Bố cục trên máy tính

Bản phác dưới đây vẽ lại trang ở màn rộng: thanh điều hướng cố định bên trái,
nội dung bên phải, thẻ số và bảng xếp lưới hai cột. Tên trên mỗi khung là tên
component; chữ bên trong là số minh hoạ lấy từ trang.

```text
┌─ KhungChuQuan ───────────────────────────────────────────────────────────────────┐
│ ┌─ ThanhDieuHuong ─────┐ ┌─ TrangTongQuan ─────────────────────────────────────┐ │
│ │ [BT] Bánh cuốn       │ │ ┌─ DauTrang ──────────────────────────────────────┐ │ │
│ │      Bà Thanh        │ │ │ TỔNG QUAN                                       │ │ │
│ │      Chủ quán        │ │ │ Ngày bán 20/10/2026 · Đọc lúc 09:42:15          │ │ │
│ │                      │ │ └─────────────────────────────────────────────────┘ │ │
│ │ ┌─ NhomDieuHuong ──┐ │ │                                                     │ │
│ │ │ HÔM NAY          │ │ │ ┌─ DaiCanDeY ─────────────────────────────────────┐ │ │
│ │ │ > Tổng quan      │ │ │ │ ! Còn thiếu gì                                  │ │ │
│ │ │   Tổng kết       │ │ │ │ Thiếu 1 người · Trứng: Nên kiểm tra             │ │ │
│ │ └──────────────────┘ │ │ └─────────────────────────────────────────────────┘ │ │
│ │                      │ │                                                     │ │
│ │ ┌─ NhomDieuHuong ──┐ │ │ ┌─ TheSo ───────────────┐ ┌─ TheSo ───────────────┐ │ │
│ │ │ THỰC ĐƠN         │ │ │ │ Tiến độ bán           │ │ Tiền bán tạm tính     │ │ │
│ │ │   Sản phẩm       │ │ │ │ 412 / 600 bánh        │ │ [GIÁ]                 │ │ │
│ │ │   Menu & giá …   │ │ │ └───────────────────────┘ └───────────────────────┘ │ │
│ │ └──────────────────┘ │ │ ┌─ TheSo ───────────────┐ ┌─ TheSo ───────────────┐ │ │
│ │                      │ │ │ Khách đang phục vụ    │ │ Người đang làm        │ │ │
│ │ ┌─ NhomDieuHuong ──┐ │ │ │ 7 bàn                 │ │ 4 người               │ │ │
│ │ │ CON NGƯỜI        │ │ │ └───────────────────────┘ └───────────────────────┘ │ │
│ │ │   Nhân viên …    │ │ │                                                     │ │
│ │ └──────────────────┘ │ │ ┌─ BangDuLieu ──────────┐ ┌─ BangDuLieu ──────────┐ │ │
│ │                      │ │ │ Còn thiếu             │ │ Đã ra                 │ │ │
│ │ ┌─ NhomDieuHuong ──┐ │ │ │ ──────────────────    │ │ ──────────────────    │ │ │
│ │ │ HÀNG & TIỀN      │ │ │ │ Bánh cuốn   36  12    │ │ Bánh cuốn  318  94    │ │ │
│ │ │   Nguyên liệu …  │ │ │ │ Trứng        5   2    │ │ Trứng       41  13    │ │ │
│ │ └──────────────────┘ │ │ └───────────────────────┘ └───────────────────────┘ │ │
│ └──────────────────────┘ │ Mốc nguồn: 09:42:10                                 │ │
│                          │                                                     │ │
│                          │ ┌─ BangDuLieu ──────────┐ ┌─ BangDuLieu ──────────┐ │ │
│                          │ │ Nguyên liệu           │ │ Món                   │ │ │
│                          │ │ ──────────────────    │ │ ──────────────────    │ │ │
│                          │ │ Trứng  4 quả          │ │ Bánh cuốn   14   9    │ │ │
│                          │ │ ┌─ HuyHieuTrangThai ┐ │ └───────────────────────┘ │ │
│                          │ │ │ Nên kiểm tra      │ │                           │ │
│                          │ │ └───────────────────┘ │                           │ │
│                          │ └───────────────────────┘                           │ │
│                          │                                                     │ │
│                          │ ┌─ FormToiThieu ──────────────────────────────────┐ │ │
│                          │ │ Số tối thiểu của ngày                           │ │ │
│                          │ │ Số bánh [ 600 ]    Số người [ 5 ]               │ │ │
│                          │ │                          [ Lưu số tối thiểu ]   │ │ │
│                          │ └─────────────────────────────────────────────────┘ │ │
│                          └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────────┘
```

Trên điện thoại (rộng ≤ 640px), `ThanhDieuHuong` chuyển xuống đáy màn hình
thành bốn nút, mỗi nút là một `NhomDieuHuong`. Mọi lưới hai cột thành một cột.

## Dùng chung

Các khối này cũng xuất hiện ở trang khác của chủ quán.

| Tên | Nó là gì |
|---|---|
| `KhungChuQuan` | Vỏ trang, nối điều hướng với nội dung quản trị. |
| `ThanhDieuHuong` | Thanh bên trên máy tính, thanh bốn nhóm ở đáy trên điện thoại. |
| `NhomDieuHuong` | Một nhóm liên kết đến các trang cùng mảng. |
| `DauTrang` | Tiêu đề trang, lời dẫn và thao tác chính. |
| `DaiCanDeY` | Dải nhắc việc cần chú ý, lấy từ dữ liệu đang xem. |
| `TheSo` | Một chỉ số được trả về, chỉ định dạng để đọc. |
| `BangDuLieu` | Bảng dữ liệu có vùng cuộn ngang riêng. |
| `HuyHieuTrangThai` | Nhãn trạng thái của một bản ghi. |

## Riêng trang này

| Tên | Nó là gì |
|---|---|
| `TrangTongQuan` | Nội dung riêng của trang Tổng quan. |
| `FormToiThieu` | Hai số tối thiểu của ngày bán và nút lưu. |
