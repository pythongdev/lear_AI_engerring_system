# Component của trang Sản phẩm

Danh mục các khối có tên trong bản thiết kế [san-pham.html](san-pham.html).
Mỗi khối mang `data-component="<Tên>"`; công tắc “Hiện tên component” và
bảng “Chú giải component” cuối trang dùng cùng tên để mô tả chỗ cần sửa.

> Bản thiết kế tĩnh · số liệu minh hoạ, **không phải hợp đồng**.
> Route đề xuất: `/chu-quan/san-pham`. Route và component thật thuộc
> [01-khung-fe.md](../../../01-khung-fe.md).

## Bố cục trên máy tính

```text
KhungChuQuan
├─ ThanhDieuHuong              TrangSanPham
│  BT · Bánh cuốn Bà Thanh     DauTrang
│  NhomDieuHuong × 4           Sản phẩm · 3 món      [Đọc lại danh sách] [Thêm món]
│  Hôm nay                    Bản thiết kế tĩnh · số liệu minh hoạ, không phải hợp đồng
│  Thực đơn                   BangDuLieu · [DANH MỤC]
│    > Sản phẩm               Món                                  Thao tác
│  Con người                  Bánh cuốn                            [Đổi tên]
│  Hàng & tiền                Trứng                                [Đổi tên]
│                             Giò · Ngừng bán                       [Đổi tên]
│                             NhomChuaXep → TrangThaiTrong
│                             Trạng thái minh hoạ (mở/thu)
└──────────────────────────────────────────────────────────────────────────
Chú giải component

Bấm Thêm món → drawer chứa FormThemMon
Bấm Đổi tên  → HopThoaiSuaCoLyDo chứa FormDoiTenMon
               Tên mới · Lý do · [Lưu tên] [Huỷ]
```

## Trên điện thoại

Ở chiều rộng ≤ 640px, `ThanhDieuHuong` xuống đáy với bốn `NhomDieuHuong`.
Bấm tên nhóm để mở liên kết phía trên thanh đáy. Nội dung và các ví dụ trạng
thái thành một cột. Ở ≤ 480px, gutter nội dung, thanh công cụ và chú giải là
10px; tiêu đề 19px. Bảng món co theo màn hình để nút “Đổi tên” luôn thấy; chú giải rộng tối thiểu
680px; cả hai nằm trong vùng cuộn ngang riêng nhận được focus, không kéo ngang cả trang.
Drawer rộng tối đa 380px, giới hạn trong viewport, cuộn dọc khi form dài.

## Danh mục component

| Tên | Nó là gì | Phạm vi |
|---|---|---|
| `BangDuLieu` | Bảng dữ liệu có vùng cuộn ngang riêng. | dùng chung |
| `DauTrang` | Tiêu đề trang, lời dẫn và thao tác chính. | dùng chung |
| `FormDoiTenMon` | Tên mới của món và lý do thay đổi. | riêng trang |
| `FormThemMon` | Tên món, danh mục và các thành phần để thêm món. | riêng trang |
| `HopThoaiSuaCoLyDo` | Ngăn bên phải để sửa dữ liệu và nhập lý do. | dùng chung |
| `KhungChuQuan` | Vỏ trang nối điều hướng với nội dung quản trị. | dùng chung |
| `NhomChuaXep` | Các món chưa xếp danh mục. | riêng trang |
| `NhomDieuHuong` | Một nhóm liên kết đến các trang cùng mảng. | dùng chung |
| `ThanhDieuHuong` | Thanh bên trên máy tính và thanh bốn nhóm ở đáy điện thoại. | dùng chung |
| `TrangSanPham` | Nội dung riêng của trang Sản phẩm. | riêng trang |
| `TrangThaiTrong` | Lời giải thích khi danh sách chưa có dữ liệu. | dùng chung |

Không thêm tên component mới. Drawer thêm món là vỏ dialog của `FormThemMon`;
`HopThoaiSuaCoLyDo` chỉ dùng cho đổi tên có lý do.

## Nội dung và nguồn

Ngày 2026-10-23, thực hiện theo phiếu việc do Claude Code dẫn và duyệt.
Tên component, trường nhập và ba tên món Bánh cuốn, Trứng, Giò lấy từ
[bản T-215](../san-pham.html). Danh mục dùng `[DANH MỤC]`, giá gốc thành phần
trong form dùng `[GIÁ]`, không điền dữ kiện quán.

Nhãn trạng thái và trường form được đối chiếu với `san-pham.tsx`,
`form-them-mon.tsx`, `form-doi-ten-mon.tsx`, `du-lieu-san-pham.ts` trong
`fe/src/app/chu-quan/_components/`. Giá không xuất hiện trên bảng món;
ô giá gốc thành phần trong form thêm món giữ nguyên nguồn. Nhãn “Ngừng bán”
chỉ để đọc; không có thao tác thay đổi trạng thái.

Phong cách lấy từ `docs/product/4-fe/thiet_ke/styke/style.md` của MAIN,
đã đọc đủ §1–§8. Khối CSS §3 được chép nguyên trước phần CSS mở rộng;
các selector không dùng của khối gốc không tạo thêm giao diện.
Bố cục điều hướng theo tiền lệ `van_hanh/van-hanh-copy.html`.
Các tài liệu tham khảo từ dự án khác chỉ gợi ý đầu trang có số món, bảng gọn,
form trong dialog và cách tách trạng thái; không dùng dữ kiện hay luồng của chúng.

## Tương tác minh hoạ

Theme mặc định tối, chuyển bằng `data-theme=light` trên `html`; chỉ lựa chọn
theme được nhớ bằng `menu-theme` như nguồn. Không nạp font hay thư viện ngoài;
Be Vietnam Pro chỉ hiển thị nếu máy đã có, sau đó dùng system-ui/sans-serif.
Công tắc tên component điều khiển cả trang và hai drawer.

Nút “Thêm món” và từng nút “Đổi tên” mở drawer tương ứng; Huỷ hoặc Escape đóng
và trả focus về đúng nút gọi. Dialog giữ focus, khoá cuộn nền; hiệu ứng drawer
tắt khi người xem yêu cầu giảm chuyển động. Thêm/bỏ thành phần chỉ thay form
trong bộ nhớ, giữ ít nhất một thành phần như mã thật. Lưu tên và Thêm món
trong form chỉ đóng drawer, hiện lời nhắc không ghi dữ liệu; không sửa bảng,
không báo thành công nghiệp vụ và không gọi API. Đọc lại danh sách chỉ hiện
thông báo minh hoạ, không mô phỏng kết quả đọc thành công.

## Giả định của bản thiết kế

Tất cả mục sau là đề xuất trình bày để Claude duyệt, không quyết luật kinh doanh:

- Số 3 đếm ba dòng minh hoạ, gồm cả dòng Giò gắn nhãn “Ngừng bán”. Việc gắn
  nhãn cho Giò là ví dụ tự chọn, không xác nhận trạng thái món thật hay quy tắc đếm.
- Một nhóm `[DANH MỤC]` chứa ba món và nhóm chưa xếp đang trống chỉ để minh hoạ.
- Đưa form vào drawer bên phải thay vị trí form luôn hiện trong bản T-215;
  nút thêm món đặt bên phải đầu trang, bảng mỗi món một hàng với hai cột gốc.
- Sidebar 232px, vùng nội dung tối đa 1200px, breakpoint 640px, khoảng trống
  đáy 150px, chú giải tối thiểu 680px, kích thước nhãn và các quy tắc form,
  disabled, trạng thái là mở rộng. Toàn bộ CSS mở rộng được đánh dấu bằng
  `/* đề xuất — không có trong nguồn style.md */`; không thêm token màu.
- Khối “Trạng thái minh hoạ” mở/thu là công cụ duyệt thiết kế. Các ví dụ đang
  đọc, lỗi, bản đọc trước, trống và thiếu danh mục độc lập với bảng phía trên,
  không phải những trạng thái đang đồng thời xảy ra. Ví dụ thiếu danh mục chỉ
  có lời nhắc; form mở từ đầu trang thuộc ví dụ đã có danh mục.
- Ba câu lỗi theo đúng mã thật: không có dữ liệu cũ thì “Chưa đọc được danh sách
  món. Hãy thử lại.”, có dữ liệu cũ thì “Chưa đọc được danh sách món. Đang hiện
  bản đọc trước.”. Bản thiết kế không đổi câu chữ hay xác lập hợp đồng mới.
- Thông báo khi bấm lưu/đọc lại và cách đóng drawer là hành vi demo. Không
  bổ sung quy tắc kiểm tra dữ liệu, quyền, xác nhận lưu hoặc thời gian tải.
- Điều hướng điện thoại chỉ mở một nhóm tại một thời điểm và đóng bằng Escape.
  Các liên kết giữ đường đến bản thiết kế cũ, riêng Sản phẩm trỏ trang mới;
  nhóm Thực đơn giữ đủ Sản phẩm, Menu & giá, Danh mục, Combo, Topping như bản T-215.
