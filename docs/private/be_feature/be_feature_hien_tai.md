# BE Features (code hiện tại) — Danh Sách Tính Năng & Function Theo Domain

> Liệt kê **toàn bộ tính năng backend đang có trong `be/`** và các function thực hiện chúng, chia theo
> domain và theo tầng `handler → service → repository`.
> Route lấy từ `Routes()` trong `be/internal/<gói>/handler.go`; lớp quyền lấy từ `authz.Door` trong service.
> Hợp đồng máy đọc: `docs/product/3-be/openapi.yaml` · ma trận quyền: `docs/product/3-be/02-vai-va-quyen.md`
> (hai file đó thắng file này khi lệch).
> Snapshot code ngày 2026-10-13. Bản so sánh với dự án cũ: `be_feature.md` cùng thư mục.

**Stack:** Go + Gin · PostgreSQL (pgx) · sqlc · realtime trong tiến trình (SSE). Không Redis, không JWT,
không cổng thanh toán.

**Danh tính:** không đăng nhập, không mật khẩu — người của quán **chọn tên**, máy gửi `X-Person-Id`
(`authz.ChonTen`, U-075 đã đóng). Khách QR / web không cần danh tính.

**Ký hiệu quyền** (lớp của **cửa**, không phải vai của người — đọc tại mốc giao dịch của cửa, ADR-085):

| Ký hiệu | `authz.Need…` | Nghĩa |
|---|---|---|
| `Public` | — | không kiểm người (cửa đọc công khai) |
| `Người quán` | `NeedPerson` | một người có thật của quán, đứng đâu cũng được |
| `Quầy` | `NeedCounter` | người bấm đang có khoảng `counter_duty` chứa mốc giao dịch |
| `Chủ quán` | `NeedOwner` | người bấm mang cờ `is_owner` |
| `Quầy/Chủ` | `NeedCounterOrOwner` | đang đứng quầy **hoặc** là chủ quán |
| `Quầy/Khách` | `NeedCounterOrCustomer` | đang đứng quầy, **hoặc** khách QR / web không người |
| `Theo cửa gọi` | `NeedCallingDoor` | cửa nội bộ, không có route — chạy trong giao dịch của cửa gọi nó |

Mỗi **cửa ghi** = một thư mục `be/internal/<gói>/sql/<cửa>/` + một `authz.Door{Code: "<gói>/<cửa>"}`.
File `.sql` lẻ trong `sql/` là câu đọc / khoá dùng chung.

---

## Mục Lục

| # | Domain (gói) | Số endpoint | Ghi chú |
|---|---|---|---|
| 1 | [Người & quầy](#1-người--quầy-nguoi) (`nguoi`) | 4 | Chọn tên, vào / rời quầy |
| 2 | [Menu & giá](#2-menu--giá-gia-menu) (`gia`, `menu`) | 6 | Đọc menu, tính thử, chủ quán đổi giá |
| 3 | [Bàn & mã QR](#3-bàn--mã-qr-ban-qr) (`ban`, `qr`) | 4 | Danh sách bàn, đã dọn, đổi mã QR |
| 4 | [Đơn](#4-đơn-don) (`don`) | 10 | Năm kênh tạo đơn, duyệt, huỷ, rời quán, đặt hẹn |
| 5 | [Nhận đơn ở quầy](#5-nhận-đơn-ở-quầy-nhandon) (`nhandon`) | 6 | Hàng chờ, tạm dừng, quán mù, SSE quầy |
| 6 | [Phiên bàn](#6-phiên-bàn-phien) (`phien`) | 1 | Khách yêu cầu tính tiền |
| 7 | [Sản xuất (bếp)](#7-sản-xuất-bếp-sanxuat) (`sanxuat`) | 9 | Bảng trạm, mẻ, ra bàn, chuyển việc, làm sai |
| 8 | [Trả trước](#8-trả-trước-tratruoc) (`tratruoc`) | 1 | Nhận tiền trả trước |
| 9 | [Hoá đơn & tiền](#9-hoá-đơn--tiền-hoadon) (`hoadon`) | 8 | Đóng phiên, trao, giao xong, hoàn, nợ, nhập bù |
| 10 | [Két & đối soát](#10-két--đối-soát-ngày-ket) (`ket`) | 6 | Đầu két, đếm, sổ giấy, ký đối soát |
| 11 | [Gói dùng chung không có route](#11-gói-dùng-chung-không-có-route) | — | `vongdoi`, `ngayban`, `authz`, `apierr`, `middleware`, `platform` |

Tổng: **55 endpoint**.

---

## 1. Người & quầy (`nguoi`)

**Tính năng:** danh sách người để chọn tên; xem ai đang đứng quầy; một người vào quầy (một quầy chỉ một
người — người vào sau khép khoảng của người trước); người đang đứng quầy rời quầy. Khoảng `counter_duty`
là thứ mở lớp `Quầy` cho phần lớn thao tác bán hàng.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `GET /people` | Public | `danhSach` | `DanhSach` | — |
| `GET /counter-duty/current` | Public | `hienTai` | `HienTai` | — |
| `POST /counter-duty` | Người quán | `vaoQuay` | `VaoQuay` | `nguoi/vao_quay` (+ `nguoi/khep_quay`) |
| `POST /counter-duty/end` | Quầy | `roiQuay` | `RoiQuay` | `nguoi/roi_quay` |

Service private: `khepQuay`.
**Repository:** `danhSach` · `hienTai` · `khoaQuay` · `themKhoang` · `khoaNguoi` · `khepKhoang`

---

## 2. Menu & giá (`gia`, `menu`)

**Tính năng:** đọc món đang bán kèm giá mọi tổ hợp hợp lệ; tính thử giá một đơn bằng **hàm giá duy nhất**
(bỏ qua mọi giá client gửi lên, P3-06). Chủ quán đổi giá gốc thành phần, đổi phụ thu lựa chọn, đổi số
lượng thành phần trong suất — mỗi lần đổi bắt buộc có lý do; ngừng bán món (ngừng lần nữa giữ mốc cũ).

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `GET /menu` | Public | `gia.docMenu` | `gia.DocMenu` | — |
| `POST /price-quotes` | Public | `gia.tinhThu` | `gia.TinhThu` | — |
| `PUT /menu-components/:menu_component_id/base-price` | Chủ quán | `menu.doiGiaThanhPhan` | `DoiGiaThanhPhan` | `menu/doi_gia_thanh_phan` |
| `PUT /menu-options/:menu_option_id/surcharge` | Chủ quán | `menu.doiPhuThu` | `DoiPhuThu` | `menu/doi_phu_thu` |
| `PUT /menu-items/:menu_item_id/components/:menu_component_id` | Chủ quán | `menu.suaThanhPhan` | `SuaThanhPhan` | `menu/sua_thanh_phan` |
| `POST /menu-items/:menu_item_id/discontinuation` | Chủ quán | `menu.ngungBan` | `NgungBan` | `menu/ngung_ban` |

**Service `gia` — function phục vụ domain khác:**

| Function | Mô tả |
|---|---|
| `Tinh` | Hàm giá duy nhất — `don` (tạo đơn), `hoadon` (nhập bù) và `TinhThu` cùng gọi. |
| *(private)* `cong`, `nhan`, `keGia` | Cộng / nhân tiền, kê giá mọi tổ hợp cho `DocMenu`. |

Service `menu` private: `khongThay`.
**Repository `gia`:** `docMon` · `docNhom` · `docMonDangBan`
**Repository `menu`:** `khaiLyDo` · `khoaThanhPhan` · `khoaLuaChon` · `timMon` · `timThanhPhan` · `khoaMonThanhPhan` · `khoaMonNgungBan` · `doiGia` · `doiPhuThu` · `suaSoLuong` · `ngungBan`

---

## 3. Bàn & mã QR (`ban`, `qr`)

**Tính năng:** danh sách bàn kèm trạng thái phiên; đánh dấu bàn đã dọn; từ mã QR đọc ra bàn mà mã
**hiện hành** chỉ tới; chủ quán cấp mã QR mới cho bàn — mã cũ hết hiện hành cùng mốc.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `GET /dining-tables` | Public | `ban.danhSach` | `ban.DanhSach` | — |
| `POST /dining-tables/:dining_table_id/cleaning` | Người quán | `ban.daDon` | `ban.DaDon` | `ban/da_don` |
| `GET /qr-codes/:code` | Public | `qr.banCuaKhach` | `qr.BanCuaKhach` | — |
| `POST /dining-tables/:dining_table_id/qr-code` | Chủ quán | `qr.doiMa` | `qr.DoiMa` | `qr/doi_ma` |

Function phục vụ domain khác: `ban.Doc` (đọc một bàn) · `qr.CurrentTable` (mã → bàn hiện hành, dùng khi khách QR tạo đơn).
**Repository `ban`:** `docBan` · `docCacBan` · `khoaChoDon` · `don` · `sessionID` · `sessionStatus`
**Repository `qr`:** `capMa` · `docMaVuaCap`

---

## 4. Đơn (`don`)

**Tính năng:** tạo một lượt gọi qua **năm kênh** — tại bàn do quầy nhập (`staff_pos`), khách quét QR
(`qr_table`), online giao / tự lấy (`delivery` / `pickup`), đặt qua điện thoại (`phone_preorder`). Hai
kênh gắn bàn gộp vào **một phiên bàn**; ba kênh còn lại mang thông tin liên hệ. Quầy duyệt / từ chối đơn
chờ xác nhận, huỷ đơn, đánh dấu đơn rời quán (người giao mang đi). Đơn hẹn: nhắc trước mốc khách cần,
nhả đơn hẹn xuống bếp. Tạo đơn bị chặn khi quán đang tạm dừng nhận đơn, quán mù, hoặc ngoài giờ.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `POST /table-orders` | Quầy/Khách | `taoTaiQuay` → `taoHTTP` | `Tao` | `don/tao_luot_goi` |
| `POST /qr-codes/:code/orders` | Quầy/Khách | `taoQR` → `taoHTTP` | `Tao` | `don/tao_luot_goi` |
| `POST /online-orders` | Quầy/Khách | `taoOnline` → `taoNgoaiBan` | `Tao` | `don/tao_luot_goi` |
| `POST /phone-orders` | Quầy/Khách | `taoPhone` → `taoNgoaiBan` | `Tao` | `don/tao_luot_goi` |
| `POST /orders/:sales_order_id/approval` | Quầy | `duyet` → `chuyen` | `Chuyen` | `don/duyet` |
| `POST /orders/:sales_order_id/rejection` | Quầy | `tuChoi` → `chuyen` | `Chuyen` | `don/tu_choi` |
| `POST /orders/:sales_order_id/cancellation` | Quầy | `huy` | `HuyDon` | `don/huy` |
| `POST /orders/:sales_order_id/departure` | Quầy | `roiQuan` | `RoiQuanDon` | `don/roi_quan` |
| `GET /preorder-reminders` | Public | `nhacHen` | `DocNhacHen` | — |
| `POST /preorder-releases` | Quầy | `nhaHen` | `NhaHenDon` | `don/nha_hen` |

**Function phục vụ domain khác:**

| Function | Dùng bởi | Mô tả |
|---|---|---|
| `GhiNhapBu` (`nhap_bu.go`) | `hoadon` | Ghi phiên + dòng của một lượt bán nhập bù từ sổ giấy. |
| `KiemHinhDong` | `hoadon` | Kiểm hình dạng dòng món trong request (dùng chung với nhập bù). |
| *(private)* `canThuLai`, `xetNhanDon`, `cungDong`, `cungChu`, `cungLienHe`, `kiemHinhDong`, `docNgoaiBan` | | Thử lại khi xung đột, xét chặn nhận đơn, gộp dòng trùng, so liên hệ. |

**Repository:** `dongHo` · `tamDung` · `ngoaiGio` · `quanMu` · `docDon` · `khoaPhien` · `themPhien` · `themBan` · `themDon` · `themDong` · `themDongTaiMoc` · `themThanhPhan` · `themLuaChon` · `docPhienDon` · `khoaPhienDon` · `khoaDon` · `huyDocPhien` · `nhaHenKhoaDon` · `nhacHen` · `roiQuanKhoaDon` · `roiQuanDocViec` · `themPhienGiay` · `themDongGiay`

---

## 5. Nhận đơn ở quầy (`nhandon`)

**Tính năng:** quầy xem hàng đơn chờ xác nhận kèm trạng thái nhận đơn, nhận tín hiệu đọc lại qua SSE.
Chủ quán tạm dừng / tiếp tục nhận đơn. Quầy hoặc chủ quán khai **quán mù** (mất khả năng theo dõi) và
mở lại.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `GET /counter/queue` | Quầy | `hangCho` | `HangCho` | — (`authz.Read`) |
| `GET /counter/events` | Quầy | `events` | `MoLuong` / `Moc` | — (SSE) |
| `POST /order-intake/pause` | Chủ quán | `bam(TamDung)` | `Bam` | `nhandon/tam_dung` |
| `POST /order-intake/resume` | Chủ quán | `bam(TiepTuc)` | `Bam` | `nhandon/tiep_tuc` |
| `POST /shop-blind/declaration` | Quầy/Chủ | `bam(BaoMu)` | `Bam` → `GhiMu` | `nhandon/bao_mu` (+ `nhandon/ghi_mu`) |
| `POST /shop-blind/reopening` | Quầy/Chủ | `bam(MoLai)` | `Bam` | `nhandon/mo_lai` |

**Repository:** `khoa` · `daMu` · `dongHo` · `ghiMu` · `tamDung` · `tiepTuc` · `moLai` · `hangCho`

---

## 6. Phiên bàn (`phien`)

**Tính năng:** yêu cầu tính tiền cho một phiên bàn (mọi lượt gọi của bàn đã gộp vào phiên).

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `POST /table-sessions/:table_session_id/bill-request` | Quầy | `tinhTien` | `TinhTien` | `phien/tinh_tien` |

Function phục vụ domain khác: `TongTien` (tổng tiền phiên).
**Repository:** `khoa` · `tongTien`

---

## 7. Sản xuất (bếp) (`sanxuat`)

**Tính năng:** bảng việc theo trạm kèm tín hiệu SSE; bấm một **mẻ** (một mẻ có thể phủ nhiều đơn) và
lùi mẻ vừa bấm; đánh dấu món đã ra bàn; chuyển việc sang trạm / người khác (kèm danh sách ứng viên
nhận); ghi chú bánh làm sai và huỷ ghi chú đó. Việc của bếp được nợ (sinh) theo thành phần và nước chấm
của đơn.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `GET /production-board` | Public | `bang` | `DocGom` | — |
| `GET /production-board/events` | Public | `events` | `Moc` | — (SSE) |
| `GET /station-jobs/:id/transfer-candidates` | Public | `ungVien` | `DocGom` | — |
| `POST /production-batches` | Quầy | `bamMe` | `BamMe` | `sanxuat/bam_me` |
| `POST /production-batches/:id/rollback` | Quầy | `luiMe` | `LuiMe` | `sanxuat/lui_me` |
| `POST /served-marks` | Quầy | `raBan` | `RaBan` | `sanxuat/ra_ban` |
| `POST /station-job-transfers` | Quầy | `chuyen` | `Chuyen` | `sanxuat/chuyen` |
| `POST /wrong-make-notes` | Quầy | `ghiLamSai` | `GhiLamSai` | `sanxuat/ghi_lam_sai` |
| `POST /wrong-make-notes/:id/cancellation` | Quầy | `huyGhiLamSai` | `HuyGhiLamSai` | `sanxuat/huy_ghi_lam_sai` |

**Function phục vụ domain khác:**

| Function | Dùng bởi | Mô tả |
|---|---|---|
| `NoDon` | `don` | Sinh việc trạm cho đơn mới — cửa `sanxuat/no_don` (Theo cửa gọi). |
| `WithRealtime` | `router.go` | Gắn broker realtime để phát tín hiệu đọc lại. |
| *(private)* `khoaTap`, `donCuaPhan`, `UnmarshalJSON` | | |

**Repository:** `conTro` · `gom` · `khoaPhienCuaViec` · `khoaDonCuaViec` · `khoaViec` · `khoaMeNguon` · `khoaPhanSong` · `khoaMe` · `viecCuaMe` · `khoaGhiLamSai` · `coBan` · `donDangLamCuaBan` · `banCuaDon` · `khoaPhienCuaDon` · `khoaDonDangLam` · `chonDaLam` · `daRaHet` · `themMe` · `themPhanMe` · `luiMe` · `luiPhanMe` · `themChuyen` · `doiChu` · `themLamSai` · `huyLamSai` · `noThanhPhan` · `noNuocCham`

---

## 8. Trả trước (`tratruoc`)

**Tính năng:** nhận tiền trả trước cho một đơn (tiền mặt / VietQR tĩnh); số dư trả trước được trừ khi
ra hoá đơn.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `POST /orders/:sales_order_id/prepayment` | Quầy | `nhan` | `NhanTien` | `tratruoc/nhan` |

**Function phục vụ domain khác:** `KiemSoDu` (kiểm số dư) · `Dung` — cửa `tratruoc/dung` (Theo cửa gọi,
`hoadon` gọi khi trừ trả trước vào hoá đơn) · `Kiem`.
**Repository:** `khoaDon` · `themKhoan` · `khoaKhoan` · `docDu` · `themMat`

---

## 9. Hoá đơn & tiền (`hoadon`)

**Tính năng:** đóng phiên bàn ra hoá đơn; trao đơn mang đi tại quầy; xác nhận giao xong đơn giao hàng;
hoàn tiền một hoá đơn; trả lại tiền trả trước; danh sách nợ và thu nợ; chủ quán giảm giá cả đơn kèm tên
khách (T-175); nhập bù một lượt bán đã ghi trên sổ giấy (T-174). Thanh toán chỉ **tiền mặt** và
**chuyển khoản VietQR tĩnh**.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `POST /table-sessions/:table_session_id/closing` | Quầy | `dong` | `DongPhien` | `hoadon/dong` (+ `hoadon/ghi`) |
| `POST /orders/:sales_order_id/handover` | Quầy | `traoTaiQuay` → `trao` | `Trao` | `hoadon/trao_tai_quay` |
| `POST /orders/:sales_order_id/delivered` | Người quán | `giaoXong` → `trao` | `Trao` | `hoadon/giao_xong` |
| `POST /bills/:bill_id/refunds` | Quầy | `hoan` | `HoanTien` | `hoadon/hoan` (+ `hoadon/ghi_hoan`) |
| `POST /prepayments/:prepayment_id/returns` | Quầy | `traLai` | `TraLaiTraTruoc` | `hoadon/tra_lai` |
| `GET /debts` | Public | `docNo` | `DanhSachNo` | — |
| `POST /bills/:bill_id/debt-collections` | Quầy | `thuNo` | `ThuNoHoaDon` | `hoadon/thu_no` |
| `POST /sale-days/:sale_date/paper-entries` | Quầy/Chủ | `nhapBu` | `NhapGiay` | `hoadon/nhap_bu` |

Service khác: `Ghi` · `GhiHoan` (cửa nội bộ ghi hoá đơn / ghi hoàn) · *(private)* `kiemTenGiam`,
`kiemChuGiam`, `phuongThuc`, `sai`, `docNhapBu`, `loiItems`.
**Repository:** `khoaPhien` · `khoaDonCuaPhien` · `khoaKhoanTraTruoc` · `themHoaDon` · `themHoan` · `khoaDon` · `tongDon` · `conViecChuaRaBan` · `khoaHoaDonHoan` · `khoaKhoanTraLai` · `khoaHoaDonNo` · `conNo` · `themThuNo` · `danhSachNo` · `chuQuanGiamGia` · `docSoNhapBu` · `trungViTriGiay` · `mocNhapBu` · `banNhapBu`

---

## 10. Két & đối soát ngày (`ket`)

**Tính năng:** khai tiền lẻ đầu két; khai số liệu sổ giấy của ngày bán; đếm két (mỗi dòng đếm là một
cửa nội bộ); chủ quán sửa số đếm và ký đối soát ngày — ngày đã ký thì khoá sổ đếm; đọc bảng đối soát
tiền của một ngày bán.

| Endpoint | Quyền | Handler | Service | Cửa |
|---|---|---|---|---|
| `POST /opening-floats` | Quầy/Chủ | `khai` → `ghiSo` | `GhiSo` | `ket/khai_dau_ket` |
| `POST /cash-counts` | Quầy/Chủ | `dem` → `ghiSo` | `GhiSo` | `ket/dem` (+ `ket/ghi_dong_dem`) |
| `PUT /sale-days/:sale_date/cash-count` | Chủ quán | `suaDem` | `SuaSoDem` | `ket/sua_dem` |
| `POST /sale-days/:sale_date/paper-ledger` | Quầy/Chủ | `khaiGiay` | `KhaiGiay` | `ket/khai_so_giay` |
| `POST /sale-days/:sale_date/reconciliation` | Chủ quán | `ky` | `KyNgay` | `ket/doi_soat_xong` |
| `GET /sale-days/:sale_date/cash-reconciliation` | Public | `doc` | `DocSo` | — |

Service private: `docSo`, `ghiDongDem`, `Kiem`.
**Repository:** `ghiSo` · `ketNgay` · `soGiay` · `ngayTuongLai` · `themSoGiay` · `themKyNgay` · `docDau` · `themDongDem` · `moLai` · `docDem` · `docXap` · `datSo`

---

## 11. Gói dùng chung không có route

| Gói | Function chính | Việc làm |
|---|---|---|
| `vongdoi` | `CapDon` · `CapPhien` · `CapViec` · `KiemChuyenDon` · `KiemChuyenPhien` · `KiemChuyenViec` · `ChuyenDon` · `ChuyenPhien` · `ChuyenViec` · `LuiViecCuaMe` · `NhaNguonChuyen` · `TrangThaiDauDon` · `CoVet` | Vòng đời trạng thái đơn / phiên / việc trạm — cửa `vongdoi/chuyen_don`, `chuyen_phien`, `chuyen_viec` (Theo cửa gọi), ghi vết chuyển kèm lý do. |
| `ngayban` | `Khoa` · `DaKy` · `ChoGhi` | Quy mốc → **ngày bán** theo đồng hồ quán, khoá ngày bán chung / riêng, chặn ghi vào ngày đã ký đối soát. |
| `authz` | `Run` · `Read` · `ChonTen` · `Door` · `Need…` | Chạy một cửa ghi sau khi kiểm quyền **trong cùng giao dịch** (ADR-085); đọc có kiểm quyền. |
| `apierr` | `Error` · `Code…` · bảng mã → HTTP status | Tên từ chối của database (trigger / ràng buộc) → mã lỗi API thống nhất. |
| `middleware` | `GanNguoi` · `Nguoi` · `Realtime` | Gắn người (từ `X-Person-Id`) và broker realtime vào context; **không** kiểm quyền. |
| `platform/postgres` | `Open` · bounded · notify | Mở pool pgx với múi giờ quán (`BANHCUON_SHOP_TZ`), giới hạn truy vấn, LISTEN/NOTIFY. |
| `platform/realtime` | `New` · `HeadContext` | Phát **tín hiệu đọc lại** trong một tiến trình (ADR-097) — không giữ dữ liệu nghiệp vụ. |
| `testhelper` | | Dựng database thử cho test tích hợp. |

**Hệ thống:** `be/cmd/server/main.go` đọc `BANHCUON_DATABASE_URL`, `BANHCUON_SHOP_TZ`, `BANHCUON_ADDR`
(mặc định `:8080`); `router.go` đăng ký mọi gói, trả 405 kèm `Allow` khi sai phương thức, HEAD chạy như
GET bỏ thân. Không có `/health`, `/metrics`, job nền hay tool CLI.

---

## 12. Chưa có trong code (đã có bảng database hoặc cần cho quán)

| Mảng | Tình trạng |
|---|---|
| Nguyên liệu | Bảng có (migration `so_nguyen_lieu`), chưa có API. |
| Chấm công | Bảng có (migration `cham_cong`), chưa có API; T-141 đang Ready. |
| Khoản của người | Bảng có (migration `khoan_cua_nguoi`), chưa có API. |
| Khoản chi ngoài | Chưa có bảng — P2A-05 chờ duyệt ADR-074. |
| Quản lý menu đầy đủ | Chưa thêm món / nhóm / lựa chọn, chưa mở bán lại. |
| Quản lý người | Chưa thêm / sửa / khoá người qua API. |
| Đọc đơn | Chưa có chi tiết một đơn cho khách, chưa có lịch sử đơn trong ngày. |
| Báo cáo | Chưa có doanh thu theo ngày bán, món bán chạy. |
| Health check | Chưa có `/health`. |
