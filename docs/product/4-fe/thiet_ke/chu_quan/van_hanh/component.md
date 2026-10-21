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
│ HÔM NAY              │ BangThieuTheoBan                                │
│   Tổng quan          │ Bàn · Thịt · Mộc nhĩ · Trứng · Chay · Canh      │
│ > Vận hành           │ Bàn 01 … Bàn 05 · hàng Tổng                     │
│   Tổng kết           │                                                 │
│ NhomDieuHuong        │ CongThuGhepDon · HuyHieuTrangThai               │
│ THỰC ĐƠN             │ [ ] Bàn 07    │ Đã chọn n bàn …                 │
│   Sản phẩm …         │ [ ] Bàn 08    │ bàn tick → hàng đỏ ở            │
│ NhomDieuHuong        │ [ ] Bàn 09    │ BangThieuTheoBan, tổng +n đỏ    │
│ CON NGƯỜI            │ [Bỏ chọn hết] │                                 │
│   Nhân viên …        │                                                 │
│ NhomDieuHuong        │ KhoiBanDangPhucVu · HuyHieuTrangThai            │
│ HÀNG & TIỀN          │ 6 tổng bàn đang phục vụ [Chi tiết]              │
│   Nguyên liệu …      │ từng bàn theo cột · BangDuLieu đầy đủ (mở/đóng) │
│                      │ SoDoBan: 01–15 (5 × 3)                          │
│                      │ LichSuDemRa: đem ra [Hiện] · theo bàn [Hiện]    │
│                      │ Giả định của bản thiết kế · CHỜ xác nhận       │
└────────────────────────────────────────────────────────────────────────┘
Chú giải component (dùng chung / riêng trang)
```

Trên điện thoại (rộng ≤ 640px), `ThanhDieuHuong` chuyển xuống đáy thành bốn
`NhomDieuHuong`; cộng thử thành một cột, sơ đồ bàn thành ba
cột. Riêng `BangDuLieu` từng bàn hiển thị mỗi bàn và dòng tổng thành thẻ,
với nhãn bên trái và giá trị bên phải. Bảng cuộn trong vùng riêng có thể nhận tiêu điểm, không kéo ngang trang.

## Dùng chung

| Tên | Nó là gì |
|---|---|
| `KhungChuQuan` | Vỏ trang nối điều hướng với nội dung quản trị. |
| `ThanhDieuHuong` | Thanh bên trên máy tính, thanh bốn nhóm ở đáy điện thoại. |
| `NhomDieuHuong` | Một nhóm liên kết đến các trang cùng mảng. |
| `DauTrang` | Tiêu đề trang, ngày bán và giờ đọc minh hoạ. |
| `BangDuLieu` | Bảng dữ liệu có vùng cuộn ngang riêng. |
| `HuyHieuTrangThai` | Nhãn chỉ rõ phần đề xuất chưa có trong hợp đồng. |

## Riêng trang này

| Tên | Nó là gì |
|---|---|
| `TrangVanHanh` | Nội dung trang Vận hành, route đề xuất /chu-quan/van-hanh. |
| `SoDoBan` | Lưới bàn 1–15; màu và chữ cùng chỉ trạng thái, không mô tả vị trí thật. |
| `LichSuDemRa` | Lịch sử đem ra theo giờ và lịch sử theo bàn; mỗi phần có nút Hiện/Ẩn, mặc định ẩn. |
| `BangThieuTheoBan` | Số còn thiếu từng bàn theo Thịt, Mộc nhĩ, Trứng (tách tái / chín), Chay, Canh, có hàng tổng. |
| `KhoiBanDangPhucVu` | Tổng bàn đang phục vụ; nút mở/đóng bảng từng bàn có dòng tổng. |
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

Tick một bàn sắp phục vụ ở cộng thử thì `BangThieuTheoBan` thêm một hàng nền
đỏ cho bàn đó và hàng Tổng hiện phần cộng thêm màu đỏ (ví dụ 8+4); Bỏ chọn hết
gỡ các hàng đỏ. Bấm tên bàn ở `BangThieuTheoBan` trượt mở chi tiết dạng cột
ngay dưới hàng đó. Nút Chi tiết cập nhật `aria-expanded` và thuộc tính `hidden`
của bảng đầy đủ; không thay dữ liệu.
**Cộng thử — chỉ tính trên màn, không ghi gì.** Không gọi API, không lưu trình duyệt.

Đối chiếu `docs/product/3-be/openapi.yaml`: `GET /dining-tables` có trạng thái
`empty / in_session / needs_cleaning`, không trả đủ ba nhóm đề xuất trên;
`GET /counter/queue` có định danh bàn và đơn chờ nhưng không có dòng món hay
số bánh theo nhân. `GET /owner-overview` có tổng đã ra/còn thiếu nhưng không
có bảng từng bàn và phép cộng thử này. Không coi các đường đọc đó là nguồn
đủ cho thiết kế. Hai khối KhoiBanDangPhucVu
và CongThuGhepDon mang HuyHieuTrangThai
“đề xuất — chưa có trong hợp đồng”.

## Giả định của bản thiết kế

Chủ repo chốt thiết kế ngày 2026-10-21 (`work/backlog.md` T-224) và xác nhận
trong hội thoại: **sắp phục vụ** = bàn đã gửi lượt gọi mà chưa có phần nào ra
bàn; **đã đem ra** = đã ra bàn (`master_plan/shop-facts.md` §5.4); bấm đem ra
**vẫn là người đứng quầy**; thanh toán **chỉ thu tiền phần đã ra**
(`shop-facts.md` §6.1, vế còn hở ở `docs/product/99-unknowns.md` U-103).

Còn là cách hiểu của Claude, chưa xác nhận: cột Thịt · Mộc nhĩ · Chay đếm số
bánh theo loại nhân. "Bàn còn dư" không còn trên trang. Số trên trang là minh hoạ.
