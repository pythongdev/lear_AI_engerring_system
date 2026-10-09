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
  trực là của `P3-11`;
- **cách một người chứng minh mình là ai** — câu của chủ quán, **U-075**, chưa có lời
  ([`../99-unknowns.md`](../99-unknowns.md));
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

## 2. Lớp quyền

| Lớp | Qua khi | Nguồn |
|---|---|---|
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
| `qr/doi_ma` | `chu_quan` | `shop-facts.md` §6 quy tắc 2 — **U-062** đã đóng: chỉ chủ quán đổi mã, đổi khi quán bị hack |
| `don/tao_luot_goi` | `quay_hoac_khach` | `shop-facts.md` §2 — Staff POS; §1 câu 5 và `I-023` — khách QR; `02-kenh-ban.md` bảng kênh — khách web và người nhập hotline; ADR-087; ADR-088 |
| `menu/doi_gia_thanh_phan` | `chu_quan` | `architecture.md` §6.1 · `I-012` (chủ quán đổi giá) |
| `menu/doi_phu_thu` | `chu_quan` | `architecture.md` §6.1 · `I-012` |
| `menu/sua_thanh_phan` | `chu_quan` | `architecture.md` §6.1 · `I-011` · `I-012` |
| `menu/ngung_ban` | `chu_quan` | `architecture.md` §6.1 · `03-lat-cat.md` §3.3.4 |
| `don/duyet` | `quay` | `05-vong-doi.md` §5.2 — quầy duyệt đơn chờ xác nhận |
| `don/roi_quan` | `quay` | `05-vong-doi.md` §5.2 dòng *Đang thực hiện → Đang giao*; `shop-facts.md` §6.7 (U-023) |
| `don/tu_choi` | `quay` | `05-vong-doi.md` §5.2 — quầy từ chối đơn chờ xác nhận |
| `phien/tinh_tien` | `quay` | `05-vong-doi.md` §5.3 — quầy tính tổng phiên |
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
| `ket/dem` | `quay_hoac_chu_quan` | shop-facts.md §6.27; ADR-079; ADR-089 điểm 8 |
| `ket/doi_soat_xong` | `quay_hoac_chu_quan` | shop-facts.md §6.27; ADR-079; ADR-089 điểm 5, 8 |
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

**Lát sau thêm dòng thế nào:** cùng lượt dựng cửa — thư mục cửa, khai báo `authz.Door{Code, Need}` ngoài
file test, và một dòng ở đây trỏ nguồn nghiệp vụ. Thiếu một trong ba thì Gate 1g đỏ.

## 4. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **Cách đăng nhập** của nhân viên và chủ quán | cửa nhận người qua giao diện `authz.Authenticator`; chưa có bản thật, chưa có chương trình chạy | chủ quán — **U-075** |
| **Cửa lớp `quay` đầu tiên** | đã có đường gọi ở `P3-07`: duyệt, từ chối, tính tiền, đóng; tạo lượt gọi đổi sang `quay_hoac_khach` | [Luồng tại bàn](04-luong-tai-ban.md) |
| **Mở · khép khoảng trực quầy** | khoảng trực chỉ ghi được bằng tay ở database | `P3-11` |
| **Hai người dùng chung một danh tính** | máy không phân biệt được (`I-012` tầng 4) | không gỡ ở máy — đối chiếu `I-012/3` |

[↑ đầu file](#top)
