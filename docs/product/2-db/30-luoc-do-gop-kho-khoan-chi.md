# Lược đồ lát gộp Kho và Nguyên liệu vào Khoản chi

KC-02 · 2026-11-22 · Codex thi công phiếu Claude theo ADR-147 (chủ repo duyệt 2026-11-22); Claude làm nốt sqlc,
đường lùi và tài liệu này khi Codex hết hạn mức. Tên, kiểu và ràng buộc thuộc
[`db/migrations/20261122120000_gop_kho_khoan_chi.up.sql`](../../../db/migrations/20261122120000_gop_kho_khoan_chi.up.sql).
File này giữ ý định, lý do và ánh xạ ADR-147; hợp đồng kiểm do Claude viết trước ở
`db/tests/kc02_supply_expense_link.sql`. Lát không thêm bảng: nó thêm cột vào bốn bảng của hai lát cũ
([`12-luoc-do-nguyen-lieu.md`](12-luoc-do-nguyen-lieu.md), [`15-luoc-do-khoan-chi.md`](15-luoc-do-khoan-chi.md)).

## 1. Cột thêm và lý do

| Bảng · cột | Ý định và ánh xạ ADR-147 |
|---|---|
| `expense_category.tracks_supply` | Mục chi có theo dõi lượng hay không; chủ quán khai lúc tạo, không sửa được — không cấp UPDATE (điểm 1). `DEFAULT false` giữ tạm cho backend cũ; API bắt khai ở KC-06 |
| `expense_item.tracks_supply` | Bản chép cờ của mục, để khoá ngoại ghép giữ khoản con cùng cờ với mục (điểm 2) |
| `expense_item.supply_item_id` | Thứ trong sổ nguyên liệu mà khoản con *là* (điểm 2); trống với khoản con của mục thường |
| `supply_item.deleted_at` · `deleted_by_person_id` | Dấu ngừng dùng có người, khuôn xoá mềm T-248; gỡ dấu là mở lại (điểm 4) |
| `expense.received_date` | Ngày nhập hàng, trống được, không ràng thứ tự với ngày chi (điểm 5) |

## 2. Ràng buộc và tầng bảo vệ

| Ràng buộc | Lý do và ánh xạ ADR-147 |
|---|---|
| `expense_category_id_tracks_supply_key` | Đích của khoá ngoại ghép (mục, cờ) (điểm 2) |
| `expense_item_category_tracks_supply_fkey` | Khoản con mang đúng cờ của mục; chuyển sang mục khác cờ bị từ chối (điểm 2, 12) |
| `expense_item_supply_link_check` | Mục theo dõi ⇔ có nối; mục thường ⇔ không nối (điểm 2) |
| `expense_item_supply_item_fkey`, `expense_item_supply_item_key` | Nối tới thứ có thật; một thứ dưới nhiều nhất một khoản con — một thứ một mục (điểm 2, lời (a)) |
| `expense_item_supply_name_match_check` (trigger kiểm hoãn) | Khoản con nối và thứ trong sổ cùng một tên; đổi tên phải đổi cả hai trong một giao dịch (điểm 3) |
| `expense_item_supply_stopped_match_check` (trigger kiểm hoãn) | Hai bên cùng ngừng hoặc cùng đang dùng (điểm 4) |
| `supply_item_deleted_pair_check`, `supply_item_deleted_by_person_fkey` | Dấu ngừng luôn có người (QD-52, khuôn T-248) |
| `supply_day_entry_supply_item_stopped_check` (trigger trước ghi) | Thứ đã ngừng: không ghi con số mới, không sửa con số cũ, không dời con số ra khỏi nó (điểm 4, lời (c)) |
| `expense_item_fkey` dựng lại `DEFERRABLE INITIALLY DEFERRED` | Chuyển mục đổi khoản con và các khoản chi của nó trong cùng giao dịch; QD-51 cấm dây chuyền nên không `CASCADE`, chỉ hoãn lúc kiểm (điểm 12) |

Hai trigger kiểm cặp đọc bản hiện hành lúc sự kiện hoãn chạy và khoá dòng của thứ trong sổ trước khi đọc, nên hai giao
dịch đổi tên chen nhau không lọt. Trigger khoá sổ lượng khoá cả thứ cũ lẫn thứ mới theo mã tăng dần.

## 3. Quyền

`shop_app` được UPDATE `expense_item.expense_category_id` (chuyển mục), `supply_item.deleted_at` · `deleted_by_person_id`
(ngừng, mở lại) và `expense.received_date`; tên của `supply_item` vẫn theo quyền sẵn có. Không cấp UPDATE
`tracks_supply` hay `supply_item_id`, không cấp DELETE (QD-50).

## 4. Bất biến và đối chiếu

`I-025` đọc lược đồ: danh sách cột `supply_item` thêm đúng hai cột dấu ngừng (ADR-147 sửa ADR-071 điểm 4); khoá ngoại
`expense_item_supply_item_fkey` và hai hàm kiểm cặp/khoá sổ là danh sách cho phép, không mở đường ghi lượng từ bán hàng.
Mệnh đề mới của lát là `I-046` (`quality/invariants.md`), dòng của nó ở
[`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md).

## 5. Đường lùi

Down khoá bốn bảng, từ chối khi có mục bật cờ, khoản con nối, dấu ngừng hay ngày nhập đã ghi (ADR-065 luật 2); cờ mặc
định false không tính là dữ liệu. Lùi trả `expense_item_fkey` về dạng không hoãn của T-248.
