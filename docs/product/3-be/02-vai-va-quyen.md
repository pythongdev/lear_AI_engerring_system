<a id="top"></a>
# Vai và quyền — mỗi cửa ghi một lớp quyền, đọc tại mốc bấm

Pha 3 · bước `P3-05` · viết 2026-10-06 (Claude Code). Vì sao thiết kế thế này và cái bị loại:
`docs/decisions.md` **ADR-085**.

**File này sở hữu:** luật đọc quyền của backend, danh sách lớp quyền, và **ma trận cửa × lớp** — mỗi
cửa ghi đúng một dòng. Cột *Lớp* ở đây và khai báo `authz.Door` trong code là hai bản của một sự thật;
**file này thắng** (cùng lý lẽ hợp đồng thắng code, **ADR-084**), Gate 1g so hai bản mọi lượt.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ** ai được làm gì — `master_plan/shop-facts.md` (§3 vai, §6 quy tắc) và
  `docs/product/1-system-design/architecture.md` §4. Mỗi dòng ma trận trỏ nguồn của nó; dòng không có
  nguồn là dòng bịa;
- **ai đứng quầy lúc nào** — dữ liệu ở bảng `counter_duty`
  ([`../2-db/06-luoc-do-nguoi-va-vet.md`](../2-db/06-luoc-do-nguoi-va-vet.md) §1); cửa mở · khép khoảng
  trực đã có ở `T-143`: `nguoi/vao_quay` · `nguoi/roi_quay`;
- **cách đăng nhập** — ADR-109: tài khoản và cookie phiên, qua `authz.Authenticator`;
- **đường gọi, mã lỗi** — [`openapi.yaml`](openapi.yaml), khuôn ở [`01-hop-dong-api.md`](01-hop-dong-api.md).

---

## 1. Luật đọc — năm câu

1. **Quyền là của cửa, không của người.** Mỗi cửa ghi khai **đúng một** lớp. Người không mang vai nào
   mở được cửa: chức vụ trả lời *người này là ai*, còn quyền hỏi *người này đang đứng đâu, lúc này*
   (`architecture.md` §4).
2. **Mốc kiểm là mốc ghi.** Lớp được kiểm **trong giao dịch của chính cửa**, tại `now()` của giao dịch
   ấy — cùng mốc mà thao tác được ghi
   ([`../1-system-design/02-thoi-gian-ngay-ban.md`](../1-system-design/02-thoi-gian-ngay-ban.md)). Người
   vừa rời quầy trước mốc ấy không qua được lớp của quầy.
3. **Hai lớp đọc độc lập, nên cộng vào nhau.** Chủ quán đứng quầy qua được cả lớp của quầy lẫn lớp của
   chủ quán; chủ quán không đứng quầy **không** qua được lớp của quầy (`YC-16`, `shop-facts.md` §6.13).
4. **Người bấm là người đã được kiểm.** Cửa khai người thao tác của giao dịch bằng **chính** người vừa
   qua lớp, rồi mới chạy thân cửa — cột *ai bấm* của mọi thao tác chạm tiền lấy đúng người ấy (`I-012`
   tầng 1). Không xác định được người ở cửa cần người ⇒ `unauthenticated`, thân cửa không chạy; nhánh khách ở câu 5 không khai người.
5. **Khách QR và khách web không phải một người của quán.** Đường QR mang **mã**, không mang bàn;
   bàn tra từ mã đang hiện hành (`I-023`). Khách web tự gửi `delivery` / `pickup`, không đọc người
   kể cả có header. Khách gửi kèm một định danh bàn ⇒ `invalid_request`, không dùng; đơn web còn
   cấm mã phiên (`I-007`). Cả hai nhánh khách không khai người thao tác (ADR-088).

Lời từ chối của quyền mang mã riêng (`01-hop-dong-api.md` §3): `unauthenticated` · `not_on_counter_duty` ·
`owner_only`; status ở hợp đồng.

Danh tính lấy từ phiên đăng nhập còn hiệu lực; `authz.RunAs` kiểm người và lớp quyền
trong giao dịch. Vai trên tài khoản chỉ chọn khung màn, không mở quyền (ADR-109).

## 2. Lớp quyền

| Lớp | Qua khi | Nguồn |
|---|---|---|
| `cong_khai` | không đòi phiên; chính cửa kiểm mật khẩu hoặc mã khi cần | ADR-109; phiếu T-190 |
| `quay` | người bấm có một khoảng `counter_duty` chứa mốc giao dịch của cửa | `architecture.md` §4 điều 1; `shop-facts.md` §3 · §6.13 · §8.8 (`C36`) |
| `quay_hoac_chu_quan` | người có thật mang cờ chủ quán hoặc đang đứng quầy; thiếu người trả unauthenticated, người thường ngoài quầy trả not_on_counter_duty | `shop-facts.md` §6.27 (*POS hoặc chủ quán*); ADR-079; khai tiền đầu két là **suy luận, ADR-089 điểm 8** |
| `chu_quan` | người bấm mang cờ chủ quán (`person.is_owner`), đứng đâu cũng được | `shop-facts.md` §3 (chủ quán là vai riêng, ngoài năm trạm); `YC-16` |
| `quay_hoac_khach` | người có thật đang đứng quầy; hoặc không có người và mang mã QR hiện hành, bàn tra từ mã trong giao dịch; hoặc khách web không người gửi delivery / pickup; khách không khai người thao tác | `02-kenh-ban.md` bảng kênh — Delivery/Pickup khách tự bấm trên web; §1 câu 5; `I-023`; ADR-087; ADR-088 |
| `nguoi_quan` | người bấm là một `person` có thật, không cần đứng đâu | `05-vong-doi.md` §5.3 dòng dọn bàn; `U-055` — **suy luận của phiên, ADR-087 điểm 7** (2026-10-06) |
| `theo_cua_goi` | không có lối vào; `authz.Run` từ chối, hàm nhận giao dịch đã kiểm quyền của cửa gọi | ADR-087 điểm 3 |

**Lớp mới** — ví dụ *quầy hoặc chủ quán* cho người nhập lại sổ giấy (`shop-facts.md` §6.11) — do lát cần
nó thêm, **cùng lượt**: một dòng ở bảng này kèm nguồn, một hằng ở `be/internal/authz/`, test từ chối qua
`authz.Run`. Không thêm lớp *cho đủ* trước khi có cửa dùng nó.

## 3. Ma trận cửa × lớp

Mỗi cửa ghi của backend — thư mục `be/internal/<gói>/sql/<cửa>/` (`QC-13`) — có **đúng một** dòng, và
mỗi dòng là một cửa có thật. Gate 1g đọc khuôn dòng ``| `<gói>/<cửa>` | `<lớp>` | <nguồn> |``.

| Cửa | Lớp | Nguồn |
|---|---|---|
| `taikhoan/dang_ky` | `cong_khai` | Phiếu T-190, ADR-109; cửa dang_ky |
| `taikhoan/dang_nhap` | `cong_khai` | Phiếu T-190, ADR-109; cửa dang_nhap |
| `taikhoan/dang_xuat` | `nguoi_quan` | Phiếu T-190, ADR-109; cửa dang_xuat |
| `taikhoan/dat_lai` | `cong_khai` | Phiếu T-190, ADR-109; cửa dat_lai |
| `taikhoan/doi_mat_khau` | `nguoi_quan` | Phiếu T-190, ADR-109; cửa doi_mat_khau |
| `taikhoan/doi_trang_thai` | `theo_cua_goi` | Phiếu T-190, ADR-109; cửa doi_trang_thai |
| `taikhoan/duyet` | `chu_quan` | Phiếu T-190, ADR-109; cửa duyet |
| `taikhoan/ghi_mat_khau` | `theo_cua_goi` | Phiếu T-190, ADR-109; cửa ghi_mat_khau |
| `taikhoan/ket_thuc_phien` | `theo_cua_goi` | Phiếu T-190, ADR-109; cửa ket_thuc_phien |
| `taikhoan/khoa` | `chu_quan` | Phiếu T-190, ADR-109; cửa khoa |
| `taikhoan/khoi_tao` | `cong_khai` | Phiếu T-190, ADR-109; cửa khoi_tao |
| `taikhoan/mo_khoa` | `chu_quan` | Phiếu T-190, ADR-109; cửa mo_khoa |
| `taikhoan/tu_choi` | `chu_quan` | Phiếu T-190, ADR-109; cửa tu_choi |
| `taikhoan/yeu_cau_dat_lai` | `cong_khai` | Phiếu T-190, ADR-109; cửa yeu_cau_dat_lai |
| `nguoi/tao_nguoi` | `theo_cua_goi` | ADR-109 — duyệt hoặc khởi tạo gọi trong giao dịch |
| `nhandon/tam_dung` | `chu_quan` | ADR-097, phiếu P3-12 (Claude, 2026-10-12) — tạm dừng cả năm kênh |
| `nhandon/tiep_tuc` | `chu_quan` | ADR-097, phiếu P3-12 (Claude, 2026-10-12) — khép khoảng tạm dừng |
| `nhandon/bao_mu` | `quay_hoac_chu_quan` | ADR-097, phiếu P3-12 (Claude, 2026-10-12) — người khai quán mù; gọi cửa ghi_mu |
| `nhandon/mo_lai` | `quay_hoac_chu_quan` | ADR-097, phiếu P3-12 (Claude, 2026-10-12) — người mở lại, kể cả khi chưa có luồng quầy |
| `nhandon/ghi_mu` | `theo_cua_goi` | ADR-097, phiếu P3-12 (Claude, 2026-10-12) — một cửa INSERT khoảng mù cho máy và người; máy gọi sau khi giao dịch đơn đã lùi |
| `nguoi/vao_quay` | `theo_cua_goi` | ADR-109 điểm 7 — đăng nhập gọi cùng giao dịch |
| `nguoi/roi_quay` | `quay` | `shop-facts.md` §8.8 (C36 · U-056); ADR-085 *Sửa đổi 2026-10-10*, phiếu T-143 — người đang đứng rời quầy |
| `nguoi/khep_quay` | `theo_cua_goi` | ADR-085 *Sửa đổi 2026-10-10*; ADR-087 điểm 3 — chủ duy nhất của ô `counter_duty.ended_at`, chạy trong giao dịch đã kiểm quyền của cửa gọi |
| `qr/doi_ma` | `chu_quan` | `shop-facts.md` §6 quy tắc 2 — **U-062** đã đóng: chỉ chủ quán đổi mã, đổi khi quán bị hack |
| `don/tao_luot_goi` | `quay_hoac_khach` | `shop-facts.md` §2 — Staff POS; §1 câu 5 và `I-023` — khách QR; `02-kenh-ban.md` bảng kênh — khách web và người nhập hotline; ADR-087; ADR-088 |
| `menu/doi_gia_thanh_phan` | `chu_quan` | `architecture.md` §6.1 · `I-012` (chủ quán đổi giá) |
| `menu/doi_phu_thu` | `chu_quan` | `architecture.md` §6.1 · `I-012` |
| `menu/sua_thanh_phan` | `chu_quan` | `architecture.md` §6.1 · `I-011` · `I-012` |
| `menu/ngung_ban` | `chu_quan` | `architecture.md` §6.1 · `03-lat-cat.md` §3.3.4 |
| `don/duyet` | `quay` | `05-vong-doi.md` §5.2 — quầy duyệt đơn chờ xác nhận |
| `don/nha_hen` | `quay` | Phiếu T-142 (thiết kế ADR-091, Claude, 2026-10-09); `shop-facts.md` §5.2 điểm 5 — máy POS nhả đơn điện thoại tới giờ nhắc |
| `don/roi_quan` | `quay` | `05-vong-doi.md` §5.2 dòng *Đang thực hiện → Đang giao*; `shop-facts.md` §6.7 (U-023) |
| `don/tu_choi` | `quay` | `05-vong-doi.md` §5.2 — quầy từ chối đơn chờ xác nhận |
| `phien/tinh_tien` | `quay` | `05-vong-doi.md` §5.3 — quầy tính tổng phiên |
| `hoadon/nhap_bu` | `quay_hoac_chu_quan` | ADR-099 và sửa đổi 2026-10-13; nhập bù sổ giấy |
| `hoadon/dong` | `quay` | `05-vong-doi.md` §5.3 — đóng phiên đã thu hoặc cho nợ |
| `ban/da_don` | `nguoi_quan` | `05-vong-doi.md` §5.3; `U-055`; suy luận của phiên, ADR-087 điểm 7 |
| `vongdoi/chuyen_don` | `theo_cua_goi` | `I-016`; ADR-087 điểm 3 |
| `vongdoi/chuyen_phien` | `theo_cua_goi` | `I-016`; ADR-087 điểm 3 |
| `hoadon/trao_tai_quay` | `quay` | ADR-089 điểm 1–2; trao hàng tại quầy |
| `hoadon/giao_xong` | `nguoi_quan` | shop-facts.md §6.7; ADR-089 điểm 1–2 — người đi giao bấm |
| `hoadon/hoan` | `quay` | shop-facts.md §6.4; ADR-089 điểm 1 |
| `hoadon/thu_no` | `quay` | shop-facts.md §6.14; ADR-075; ADR-089 điểm 1 |
| `tratruoc/nhan` | `quay` | shop-facts.md §6.3; ADR-089 điểm 1 |
| `hoadon/tra_lai` | `quay` | shop-facts.md §6.4; ADR-059; ADR-089 điểm 1 |
| `ket/khai_dau_ket` | `quay_hoac_chu_quan` | ADR-089 điểm 8 — suy luận từ shop-facts.md §8.5 |
| `ket/khai_so_giay` | `quay_hoac_chu_quan` | shop-facts.md §6 quy tắc 11 và 27; ADR-037; ADR-095 điểm 3 |
| `ket/sua_dem` | `chu_quan` | ADR-096, shop-facts.md §6.10 U-074 · U-078; sửa số đếm ngày từng ký có lý do |
| `ket/ghi_dong_dem` | `theo_cua_goi` | Claude duyệt 2026-10-12 bổ sung ADR-096: sở hữu INSERT cash_count_line, đếm và sửa gọi trong cùng giao dịch |
| `ket/dem` | `quay_hoac_chu_quan` | shop-facts.md §6.27; ADR-079; ADR-089 điểm 8 |
| `ket/doi_soat_xong` | `chu_quan` | shop-facts.md U-073; ADR-089 Sửa đổi |
| `hoadon/ghi` | `theo_cua_goi` | ADR-089 điểm 1; ADR-087 điểm 3 |
| `hoadon/ghi_hoan` | `theo_cua_goi` | ADR-089 điểm 1; ADR-087 điểm 3 |
| `tratruoc/dung` | `theo_cua_goi` | ADR-089 điểm 1; ADR-087 điểm 3 |
| `sanxuat/no_don` | `theo_cua_goi` | `05-vong-doi.md` §5.2 · §5.4; ADR-090 — nổ cùng giao dịch duyệt hoặc tạo đơn đã xác nhận |
| `sanxuat/bam_me` | `quay` | `shop-facts.md` §5.4; `05-vong-doi.md` §5.4; ADR-090 — POS bấm mẻ, bếp chỉ đọc |
| `sanxuat/lui_me` | `quay` | `shop-facts.md` §5.4; `05-vong-doi.md` §5.4; ADR-090 — quầy lùi mẻ |
| `sanxuat/ra_ban` | `quay` | `05-vong-doi.md` §5.4; `shop-facts.md` §5.4 (S-5, 2026-10-09); ADR-090 điểm 4 — số cái từng thứ cho một bàn |
| `sanxuat/chuyen` | `quay` | `shop-facts.md` §5.4; ADR-090 điểm 7 — quầy chọn đích; gồm đơn lẻ là suy luận của phiên |
| `sanxuat/ghi_lam_sai` | `quay` | `shop-facts.md` §5.4; ADR-077; ADR-090 — quầy quyết không có nơi nhận |
| `sanxuat/huy_ghi_lam_sai` | `quay` | ADR-077; ADR-090 điểm 6 — quầy huỷ ghi chú là suy luận của phiên |
| `don/huy` | `quay` | `05-vong-doi.md` §5.2; ADR-090 — huỷ đơn đã xác nhận hoặc đang thực hiện |
| `vongdoi/chuyen_viec` | `theo_cua_goi` | `05-vong-doi.md` §5.4; `I-016`; ADR-090 — một cửa sở hữu trạng thái việc |
| `nguyenlieu/them_thu` | `chu_quan` | `shop-facts.md` §8.4 — chủ quán tự nhập số liệu (2026-09-04); kế hoạch AD_BE §4; phiếu P3A-02 |
| `nguyenlieu/dat_don_vi` | `chu_quan` | `shop-facts.md` §8.4 — chủ quán tự nhập số liệu (2026-09-04); kế hoạch AD_BE §4; phiếu P3A-02 |
| `nguyenlieu/ghi_so` | `chu_quan` | `shop-facts.md` §8.4 — chủ quán tự nhập số liệu (2026-09-04); kế hoạch AD_BE §4; phiếu P3A-02 |
| `nguyenlieu/sua_so` | `chu_quan` | `shop-facts.md` §8.4 — chủ quán tự nhập số liệu (2026-09-04); kế hoạch AD_BE §4; phiếu P3A-02 |
| `khoanchi/them_loai` | `chu_quan` | `shop-facts.md` §8.10 — lời đóng U-095 (2026-10-15): chỉ chủ quán ghi khoản chi; phiếu P3A-01 |
| `khoanchi/ghi` | `chu_quan` | `shop-facts.md` §8.10 — lời đóng U-095 (2026-10-15): chỉ chủ quán ghi khoản chi; phiếu P3A-01 |
| `khoanchi/sua` | `chu_quan` | `shop-facts.md` §8.10 — lời đóng U-095 (2026-10-15): chỉ chủ quán ghi khoản chi; phiếu P3A-01 |
| `daotao/gan_huong_dan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `daotao/sua_huong_dan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `daotao/an_huong_dan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `daotao/ghi_nhan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `daotao/sua_ghi_nhan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `daotao/an_ghi_nhan` | `quay_hoac_chu_quan` | `I-031` — chủ quán hoặc POS ghi nhận xét (lời đóng `U-086` · `U-090` · `U-091`, 2026-10-14); ADR-105 điểm 1; ADR-107; phiếu P3A-04 |
| `combo/them` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); giá riêng: lời đóng `U-092`; không đổi giá giữa buổi: lời T-188; ADR-116; phiếu P3A-06 |
| `combo/doi_gia` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); giá riêng: lời đóng `U-092`; không đổi giá giữa buổi: lời T-188; ADR-116; phiếu P3A-06 |
| `combo/an` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); giá riêng: lời đóng `U-092`; không đổi giá giữa buổi: lời T-188; ADR-116; phiếu P3A-06 |
| `combo/dat_muc` | `chu_quan` | `I-034` — phụ thu trong combo chủ quán đặt theo từng món (lượt bảy, `master_plan/shop-facts.md` §8.9); khoá như giá combo, chỉ ngoài giờ bán (lượt tám, đóng `U-096`); ADR-117 điểm 6; T-194 |
| `danhmuc/them` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); ADR-105 điểm 1; ADR-115; phiếu P3A-05 |
| `danhmuc/doi_ten` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); ADR-105 điểm 1; ADR-115; phiếu P3A-05 |
| `danhmuc/an` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); ADR-105 điểm 1; ADR-115; phiếu P3A-05 |
| `danhmuc/xep_mon` | `chu_quan` | `I-032` — chủ quán tự quản lý menu (lời đóng `U-082`, 2026-10-14); ADR-105 điểm 1; ADR-115; phiếu P3A-05 |
| `giaoviec/tao` | `quay_hoac_chu_quan` | `I-030` — chủ quán và POS tạo, sửa, xoá, đánh dấu (lời đóng `U-084` · `U-089`, 2026-10-14); ADR-105 điểm 1; phiếu P3A-03 |
| `giaoviec/sua` | `quay_hoac_chu_quan` | `I-030` — chủ quán và POS tạo, sửa, xoá, đánh dấu (lời đóng `U-084` · `U-089`, 2026-10-14); ADR-105 điểm 1; phiếu P3A-03 |
| `giaoviec/an` | `quay_hoac_chu_quan` | `I-030` — chủ quán và POS tạo, sửa, xoá, đánh dấu (lời đóng `U-084` · `U-089`, 2026-10-14); ADR-105 điểm 1; phiếu P3A-03 |
| `giaoviec/danh_dau` | `quay_hoac_chu_quan` | `I-030` — chủ quán và POS tạo, sửa, xoá, đánh dấu (lời đóng `U-084` · `U-089`, 2026-10-14); ADR-105 điểm 1; phiếu P3A-03 |

**Lát sau thêm dòng thế nào:** cùng lượt dựng cửa — thư mục cửa, khai báo `authz.Door{Code, Need}` ngoài
file test, và một dòng ở đây trỏ nguồn nghiệp vụ. Thiếu một trong ba thì Gate 1g đỏ.

`nguoi/khep_quay` giữ câu SQL duy nhất sửa `counter_duty.ended_at`, không có lối vào HTTP.
Đăng nhập gọi `nguoi/vao_quay` cùng giao dịch; `nguoi/roi_quay` kiểm lớp của mình, khoá khoảng rồi gọi thân cửa khép
trong chính giao dịch ấy. Cửa khép dùng `vongdoi.CoVet` với lý do mang mã cửa gọi;
khi bấm rời, chỉ khoảng mở của chính người gọi được khép.

## 4. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **Cách đăng nhập** của nhân viên và chủ quán | Tài khoản mật khẩu riêng, cookie phiên, duyệt và đặt lại qua thư | ADR-109; T-190 |
| **Cửa lớp `quay` đầu tiên** | đã có đường gọi ở `P3-07`: duyệt, từ chối, tính tiền, đóng; tạo lượt gọi đổi sang `quay_hoac_khach` | [Luồng tại bàn](04-luong-tai-ban.md) |
| **Mở · khép khoảng trực quầy** | đăng nhập `at_counter` mở trực; `POST /counter-duty/end` rời quầy; danh sách tên cần đăng nhập | T-143; [`openapi.yaml`](openapi.yaml) |
| **Hai người dùng chung một danh tính** | máy không phân biệt được (`I-012` tầng 4) | không gỡ ở máy — đối chiếu `I-012/3` |

[↑ đầu file](#top)
