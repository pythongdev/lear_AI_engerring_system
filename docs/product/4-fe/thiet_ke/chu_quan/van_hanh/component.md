# Component của trang Vận hành

Danh mục các khối có tên trong bản thiết kế [van-hanh.html](van-hanh.html).
Mỗi khối mang `data-component="<Tên>"`; công tắc “Hiện tên component” và
bảng chú giải cuối trang dùng cùng tên để mô tả chỗ cần sửa.

> Đây là bản thiết kế tĩnh, số liệu chỉ để minh hoạ, **không phải hợp đồng**.
> Route đề xuất: `/chu-quan/van-hanh`. Route và component thật nằm ở
> [01-khung-fe.md](../../../01-khung-fe.md).

## Bố cục trên máy tính

```text
┌─ KhungChuQuan ───────────────────────────────────────────────────────────┐
│ ThanhDieuHuong        │ TrangVanHanh                                    │
│ [BT] Bánh cuốn        │ ┌─ DauTrang ───────────────────────────────────┐ │
│      Bà Thanh        │ │ VẬN HÀNH · Ngày bán · Giờ đọc · Minh hoạ     │ │
│ NhomDieuHuong        │ └─────────────────────────────────────────────┘ │
│ HÔM NAY              │ TheTrangThaiBan · HuyHieuTrangThai              │
│   Tổng quan          │ [TheSo: 6 phục vụ] [3 sắp phục vụ] [6 trống]    │
│ > Vận hành           │ SoDoBan: 01 02 03 04 05                         │
│   Tổng kết           │          06 07 08 09 10                         │
│ NhomDieuHuong        │          11 12 13 14 15                         │
│ THỰC ĐƠN             │ KhoiBanDangPhucVu · HuyHieuTrangThai            │
│   Sản phẩm …         │ 6 tổng bàn đang phục vụ [Xem từng bàn]         │
│ NhomDieuHuong        │ └─ BangDuLieu: từng bàn + tổng (mở/đóng)        │
│ CON NGƯỜI            │ BangTongConThieu · HuyHieuTrangThai             │
│   Nhân viên …        │ └─ BangDuLieu: phục vụ / sắp phục vụ / toàn quán│
│ NhomDieuHuong        │ CongThuGhepDon · HuyHieuTrangThai               │
│ HÀNG & TIỀN          │ [ ] Bàn 07    │ BangDuLieu                     │
│   Nguyên liệu …      │ [ ] Bàn 08    │ Hiện tại / Cộng thêm / Sau ghép│
│                      │ [ ] Bàn 09    │ từng nhân · canh · tiền        │
│                      │ [Bỏ chọn hết] │                                │
│                      │ Giả định của bản thiết kế · CHỜ xác nhận       │
└────────────────────────────────────────────────────────────────────────┘
Chú giải component (dùng chung / riêng trang)
```

Trên điện thoại (rộng ≤ 640px), `ThanhDieuHuong` chuyển xuống đáy thành bốn
`NhomDieuHuong`; lưới thẻ số và cộng thử thành một cột, sơ đồ bàn thành ba
cột. Bảng cuộn trong vùng riêng có thể nhận tiêu điểm, không kéo ngang trang.

## Dùng chung

| Tên | Nó là gì |
|---|---|
| `KhungChuQuan` | Vỏ trang nối điều hướng với nội dung quản trị. |
| `ThanhDieuHuong` | Thanh bên trên máy tính, thanh bốn nhóm ở đáy điện thoại. |
| `NhomDieuHuong` | Một nhóm liên kết đến các trang cùng mảng. |
| `DauTrang` | Tiêu đề trang, ngày bán và giờ đọc minh hoạ. |
| `TheSo` | Một chỉ số minh hoạ, chỉ định dạng để đọc. |
| `BangDuLieu` | Bảng dữ liệu có vùng cuộn ngang riêng. |
| `HuyHieuTrangThai` | Nhãn chỉ rõ phần đề xuất chưa có trong hợp đồng. |

## Riêng trang này

| Tên | Nó là gì |
|---|---|
| `TrangVanHanh` | Nội dung trang Vận hành, route đề xuất /chu-quan/van-hanh. |
| `TheTrangThaiBan` | Ba thẻ số: 6 đang phục vụ, 3 sắp phục vụ, 6 còn trống. |
| `SoDoBan` | Lưới bàn 1–15; màu và chữ cùng chỉ trạng thái, không mô tả vị trí thật. |
| `KhoiBanDangPhucVu` | Tổng bàn đang phục vụ; nút mở/đóng bảng từng bàn có dòng tổng. |
| `BangTongConThieu` | Tổng còn thiếu và tiền: tách đang phục vụ, sắp phục vụ, toàn quán. |
| `CongThuGhepDon` | Tick bàn sắp phục vụ để cộng thử trên màn hình; không ghi dữ liệu. |

## Dữ liệu minh hoạ và nguồn

Ngày 20/10/2026, theo phiếu Claude giao T-219. Tổng 15 bàn lấy từ
`master_plan/shop-facts.md` §1; giá từ §4.2 và §4.4: Chay 3.000đ,
Thịt 4.000đ, Thịt + mộc nhĩ 4.000đ/bánh ở lượng nhân thường; canh 0đ.
Mẫu chỉ chọn bánh cuốn lẻ và canh, không có món khác hay nhiều nhân.
Các lượng đặt, đã ra và canh là số tự chọn để minh hoạ, không phải số vận hành.

Bàn 1–6 đang phục vụ, 7–9 sắp phục vụ, 10–15 trống. Cột nhân trong bảng từng
bàn ghi đặt / đã ra. Tổng đang phục vụ: đặt 55 bánh (14 / 22 / 19), đã ra 31
(8 / 12 / 11), thiếu 24 (6 / 10 / 8); canh 16 đặt / 9 đã lấy, thiếu 7.
Tiền đơn 206.000đ; tiền bánh đã ra 116.000đ. Ba bàn sắp phục vụ đặt 25 bánh
(6 / 10 / 9), 7 canh, 94.000đ, chưa ra món. Toàn quán còn thiếu 49 bánh
(12 / 20 / 17), 14 canh; tổng tiền 300.000đ, tiền bánh đã ra 116.000đ.

“Hiện tại” trong cộng thử = lượng đặt và tiền ở dòng tổng 6 bàn đang phục vụ;
“Cộng thêm” = tổng các bàn đã tick; “Sau khi ghép” = hai cột trước cộng nhau.
Bỏ chọn hết đưa phần cộng thêm về 0. Nút Xem từng bàn cập nhật `aria-expanded`
và thuộc tính `hidden` của vùng bảng; không thay dữ liệu.
**Cộng thử — chỉ tính trên màn, không ghi gì.** Không gọi API, không lưu trình duyệt.

Đối chiếu `docs/product/3-be/openapi.yaml`: `GET /dining-tables` có trạng thái
`empty / in_session / needs_cleaning`, không trả đủ ba nhóm đề xuất trên;
`GET /counter/queue` có định danh bàn và đơn chờ nhưng không có dòng món hay
số bánh theo nhân. `GET /owner-overview` có tổng đã ra/còn thiếu nhưng không
có bảng từng bàn và phép cộng thử này. Không coi các đường đọc đó là nguồn
đủ cho thiết kế. Cả bốn khối TheTrangThaiBan, KhoiBanDangPhucVu,
BangTongConThieu và CongThuGhepDon mang HuyHieuTrangThai
“đề xuất — chưa có trong hợp đồng”.

## Giả định của bản thiết kế

Bốn cách hiểu của Claude trong phiếu T-219 ngày 20/10/2026, **CHỜ chủ repo
xác nhận**, không phải luật nghiệp vụ đã chốt:

- Bàn còn dư = bàn trống.
- Sắp phục vụ = bàn đã gửi lượt gọi mà chưa có món ra bàn.
- Đã lấy ra = đã ra bàn.
- Nhân = số bánh theo loại nhân.

Chủ repo cần xác nhận bốn cách hiểu này trước khi triển khai hành vi thật.
