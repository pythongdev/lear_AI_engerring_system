# Lược đồ lát bán combo

Pha 2 (bổ sung) · task `T-193` của `P3A-11` · 2026-10-15 · Claude Code (Codex hết hạn mức trước khi bắt đầu).
Quyết định: `docs/decisions.md` **ADR-117** điểm 1 · 2 · 3, chủ repo duyệt 2026-10-15.

**Bản nào thắng:** tên bảng, cột, kiểu và ràng buộc thuộc
[`db/migrations/20261015120000_ban_combo.up.sql`](../../../db/migrations/20261015120000_ban_combo.up.sql)
(**ADR-053** luật 2). File này giữ ý định, lý do và ánh xạ `I-034`.

Nguồn lời: `master_plan/shop-facts.md` §8.9 (lượt bảy, lượt tám); mệnh đề: `quality/invariants.md` `I-034`.
Đứng trên combo của [18-luoc-do-danh-muc-combo.md](18-luoc-do-danh-muc-combo.md), dòng đơn và ảnh chụp của
[03-luoc-do-menu-gia.md](03-luoc-do-menu-gia.md). Bước 29 và khoá chặn đường lùi ở
[07-thu-tu-migration.md](07-thu-tu-migration.md); tập phải rỗng ở [09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md).

## 1. Mức phụ thu theo món của combo — `menu_combo_item_option_surcharge`

| Bảng · cột | Giữ gì |
|---|---|
| `menu_combo_item_option_surcharge.menu_combo_item_id` · `menu_option_id` | món nào của combo nào, lựa chọn nào — mỗi cặp một dòng |
| `menu_combo_item_option_surcharge.surcharge_vnd` | mức chủ quán đặt cho **một suất** chọn lựa chọn ấy, nguyên đồng ≥ 0 |
| `menu_combo_item_option_surcharge.person_id` · `created_at` | ai đặt, lúc nào |

Không có dòng cho một cặp nghĩa là mức **0đ** (lời đóng `U-096`) — nên bỏ mức là đặt 0, không cần xoá. Lựa chọn
phải thuộc một nhóm mà món ấy mang (`menu_item_option_group`); trigger trước khi chèn từ chối bằng
`menu_combo_item_option_surcharge_option_of_item_check`, món hay lựa chọn không có thật thì để khoá ngoại nói.
Vai ghi chỉ sửa được mức; mọi lần sửa có vết (QD-52), không xoá (QD-50). Bảng tách khỏi `menu_option.surcharge_vnd`
— phụ thu của món lẻ (§4.4) — nên đổi một bên không kéo bên kia.

## 2. Combo trên đơn — hai tầng trong chính `order_line`

| Dòng | Mang gì | `unit_price_vnd` |
|---|---|---|
| **dòng combo** | `menu_combo_id`, `item_name` = tên combo đã chụp; không món, không `component_count`, không cha | giá combo tại mốc |
| **dòng suất con** | dòng món như cũ + `parent_order_line_id` → dòng combo cùng đơn, cùng dấu đem về | tổng mức của các lựa chọn của **một** suất |

`quantity` của dòng combo là số combo; của dòng con là số suất cùng tổ hợp. `order_line_option.surcharge_vnd` của dòng
con chụp **mức combo đã áp**, nên `I-034/5` so được tiền suất với ảnh chụp. Vì tiền nằm hết trên dòng, tổng đơn vẫn là
Σ `line_total_vnd` — hoá đơn, phiên, két cộng đúng mà không đổi câu nào. Bếp sinh việc từ thành phần của dòng con như
mọi dòng; dòng combo không thành phần nên không sinh việc.

Ràng buộc: đúng một trong `menu_item_id` · `menu_combo_id` (`order_line_item_xor_combo_check`); dòng món có số thành
phần (`order_line_item_has_component_count_check`); dòng combo không số thành phần, không cha
(`order_line_combo_line_shape_check`) — nên khoá ngoại hoãn sẵn có của ảnh chụp thành phần từ chối mọi thành phần trên
nó. Khoá ngoại `order_line_combo_parent_fkey` trỏ bốn cột về `order_line_combo_parent_key` — `(id, sales_order_id,
is_combo_line, is_takeaway)` — với hai cột sinh ra `is_combo_line` · `parent_is_combo_line`, nên cha phải là dòng combo,
cùng đơn, cùng dấu đem về; dòng không cha thì khoá ngoại không xét. Trigger hoãn `order_line_combo_has_child_check`
đòi mỗi dòng combo có ít nhất một dòng con lúc giao dịch kết thúc (chép khuôn `menu_combo_has_item_check`). Trigger
`order_line_option_item_line_check` chặn lựa chọn trên dòng combo.

## 3. Database không xét — tầng 3

**Đủ suất** (số suất mỗi món = số phần × số combo), **mức đã chụp khớp bảng mức tại mốc**, **giá combo tại mốc**,
**khoá trong giờ bán** và **combo đã ẩn** đều đọc combo và đồng hồ tại một mốc — cửa đặt mức (`T-194`), hàm giá
(`T-195`) và cửa ghi đơn (`T-196`) xét; phép đối chiếu `I-034/4` · `I-034/5` · `I-034/6` bắt phần để lại dữ liệu. Test
`db/tests/i034_combo_on_order.sql` nói thẳng database nhận combo thiếu suất.
