# Component của trang Danh mục

Danh mục khối của [danh-muc.html](danh-muc.html), viết ngày 2026-10-23 theo phiếu việc do Claude dẫn và duyệt.

> Bản thiết kế tĩnh · số liệu minh hoạ, không phải hợp đồng.
> Route đề xuất: `/chu-quan/danh-muc`. Route và component thật thuộc
> [01-khung-fe.md](../../../01-khung-fe.md).

## Bố cục máy tính

```text
KhungChuQuan
├─ ThanhDieuHuong                TrangDanhMuc
│  BT · Bánh cuốn Bà Thanh       DauTrang: Danh mục · 2 danh mục
│  NhomDieuHuong × 4             [Đọc lại danh sách] [Thêm danh mục]
│  Hôm nay                      NhomDanhMuc: Bánh cuốn [Đổi tên] [Ẩn]
│  Thực đơn > Danh mục           BangDuLieu: Món | Thao tác
│  Con người                      Bánh cuốn trứng [Chuyển danh mục]
│  Hàng & tiền                    Bánh cuốn thịt · Ngừng bán [Chuyển danh mục]
│                               NhomDanhMuc: Đồ uống [Đổi tên] [Ẩn]
│                                 TrangThaiTrong: Chưa có món
│                               NhomDanhMuc: Chưa xếp danh mục
│                                 BangDuLieu: Chả quế [Xếp danh mục]
│                               Trạng thái minh hoạ (mở/thu)
└───────────────────────────────────────────────────────────────────
Chú giải component
Thêm → dialog / FormMenu / OMenu (Tên danh mục)
Đổi tên, ẩn, xếp/chuyển → HopThoaiSuaCoLyDo / FormMenu / OMenu
```

## Điện thoại

Ở ≤640px, thanh điều hướng xuống đáy với bốn nhóm như trang Sản phẩm;
bấm nhóm mở liên kết phía trên, Escape đóng. Trạng thái thành một cột.
Ở ≤480px, gutter còn 10px, tiêu đề 19px. Bảng món co theo màn hình để nút
“Chuyển danh mục” luôn thấy; bảng chú giải 680px cuộn trong vùng riêng có focus. Các cột khung dùng minmax(0,1fr)
và các khối có min-width:0 để không đẩy rộng trang 360px. Drawer tối đa 380px,
không vượt viewport và cuộn dọc. Công tắc “Hiện tên component” áp dụng cả dialog.

## Danh mục component

| Tên | Nó là gì | Phạm vi |
|---|---|---|
| `BangDuLieu` | Bảng món với vùng cuộn ngang riêng. | dùng chung |
| `DauTrang` | Tiêu đề, số đếm minh hoạ và thao tác chính. | dùng chung |
| `FormMenu` | Khuôn form thêm, đổi tên, ẩn và xếp món. | dùng chung |
| `HopThoaiSuaCoLyDo` | Ngăn sửa dữ liệu có ô lý do. | dùng chung |
| `KhungChuQuan` | Vỏ trang nối điều hướng với nội dung. | dùng chung |
| `NhomDanhMuc` | Danh mục và món; gồm nhóm chưa xếp không có thao tác quản lý nhóm. | riêng trang |
| `NhomDieuHuong` | Nhóm liên kết cùng mảng. | dùng chung |
| `OMenu` | Trường nhập hoặc chọn và lỗi gắn ô. | dùng chung |
| `ThanhDieuHuong` | Thanh bên máy tính và điều hướng đáy điện thoại. | dùng chung |
| `TrangDanhMuc` | Nội dung Danh mục và các mẫu trạng thái đọc. | riêng trang |
| `TrangThaiTrong` | Lời giải thích khi chưa có danh mục hoặc món. | dùng chung |

Không thêm tên mới: dùng lại tên trong bản T-215 và TrangThaiTrong của tiền lệ Sản phẩm.

## Nguồn hành vi và giới hạn

Nguồn là `fe/src/app/chu-quan/_components/danh-muc.tsx` và
`fe/src/app/chu-quan/danh-muc/danh-muc.test.tsx`; tên nhóm và món minh hoạ lấy
nguyên thứ tự bộ dữ liệu test, không khẳng định dữ kiện quán. Giữ cả món ngừng bán.
Nhóm Chưa xếp danh mục không đổi tên và không ẩn được.

Thêm chỉ có tên; tên trắng đánh dấu ô và không tiếp tục. Ví dụ tên trùng giữ
chữ đã nhập và lỗi gắn ô; đây là phản hồi backend, không kiểm trùng cục bộ.
Đổi tên điền sẵn tên cũ, tên và lý do không được trắng. Ẩn bắt buộc lý do và
nói rõ món sẽ về Chưa xếp danh mục. Xếp/chuyển phải chọn đích; danh sách đích
giữ thứ tự đọc, loại danh mục hiện tại. Chuyển từ danh mục hiện tại bắt buộc
lý do. Xếp món chưa xếp luôn có ô lý do, không bắt buộc ở frontend; để trắng
thì mã thật không gửi trường lý do. Nếu món từng thuộc danh mục đã ẩn, backend
có thể đòi lý do và lỗi phải gắn ô đó. Bản tĩnh không suy đoán lịch sử này.

Các trạng thái đang đọc, chờ kết nối, đọc lỗi, đọc lại, chưa có danh mục và
đang gửi là các tình huống độc lập để duyệt. Lỗi chưa có dữ liệu không bày form;
lỗi có dữ liệu cũ giữ bản đọc trước, có mốc giờ minh hoạ và lời báo chưa cập nhật
sau khi ghi. Chưa có danh mục vẫn có nhóm chưa xếp và thao tác thêm. Nút đọc lại
mang đúng tên của component thật, làm nhiệm vụ thử lại. Không tự tạo nhóm khi trống.

## Bố cục mượn và phần loại bỏ

Từ `admin_categories.md`: mượn đầu trang có số đếm và nút chính, bảng gọn,
form trong hộp thoại. Bỏ route admin, phân vai, thao tác xoá, xác nhận trình duyệt,
lỗi xoá 409, toast, sắp theo sort_order, ô Thứ tự hiển thị, cột Số món,
mô tả, is_active và giới hạn tên 100 ký tự của dự án đó.

Từ `admin_categories_loading.md`: mượn cách tách tình huống đang tải, lỗi có
nút thử lại, trống và nút lưu bị khoá khi đang gửi. Không mượn AuthGuard,
RoleGuard, màn hình trắng, spinner cấp route, staleTime, cache hoặc luồng xoá.

Từ `admin_categories_crosspage_dataflow.md`: không mượn hành vi hay khối giao
diện nào; tài liệu mô tả luồng hệ thống khác. Không đưa Redis, TanStack query key,
TTL, đồng bộ thiết bị, menu/POS, phân vai hoặc hợp đồng API của nó vào bản thiết kế.

## Đề xuất trình bày và tương tác minh hoạ

Theo tiền lệ [Sản phẩm](../san_pham/san-pham.html), dùng nền, màu, thẻ, viền,
cam nhấn và hai theme từ [style.md](../../styke/style.md); CSS nhúng tự mang style.
Không nạp Tailwind CDN, như trang Sản phẩm: lớp reset của nó xoá đệm nút và cỡ tiêu đề.
Font Be Vietnam Pro chỉ dùng nếu có sẵn, rồi fallback system-ui/sans-serif.

Sidebar 232px, nội dung tối đa 1200px, breakpoint 640px/480px, bảng chú giải tối thiểu
680px, nhãn component và lỗi viền cam là đề xuất bố cục, không thêm token màu.
Số đếm 2 chỉ đếm hai danh mục ví dụ, không đếm nhóm Chưa xếp danh mục. Drawer thay
vị trí form trong dòng của mã thật; nút thêm đặt ở đầu trang thuộc mẫu đã đọc được
dữ liệu. Theme mặc định tối, có chuyển sáng và nhớ riêng lựa chọn theme.

Dialog giữ focus, khoá cuộn nền, Huỷ/Escape đóng và trả focus; giảm chuyển động
được tôn trọng. Gửi form chỉ kiểm các ô bắt buộc rồi hiện lời nhắc ngay trong form,
không gọi API, không sửa danh sách, không báo thành công nghiệp vụ, không toast.
Đang gửi và tên trùng là mẫu cố định trong khu vực trạng thái. Mở/thu trạng thái,
hiện tên khối, điều hướng và đổi theme là công cụ duyệt bản thiết kế.
