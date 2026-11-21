# Lược đồ lát món yêu thích và bộ món của khách

YT-03 · 2026-11-19 · Codex thi công phiếu Claude theo ADR-145, chủ repo duyệt 2026-11-19.
Tên, kiểu và ràng buộc thuộc
[`db/migrations/20261121090000_yeu_thich.up.sql`](../../../db/migrations/20261121090000_yeu_thich.up.sql).
File này giữ ý định, lý do và ánh xạ ADR-145; hợp đồng kiểm do Claude viết trước
ở `db/tests/yt03_customer_favourite.sql`.

## 1. Chỗ cất và lý do

| Bảng | Ý định và ánh xạ ADR-145 |
|---|---|
| `customer_favourite_set` | Bộ có chủ là tài khoản khách, tên và loại rieng (Bộ món riêng) hoặc da_luu (Bộ đã lưu); hai loại dùng chung chỗ cất, không phải combo của quán (điểm 1, 3, 6) |
| `customer_favourite_line` | Dòng món hoặc combo, số lượng, bộ tuỳ chọn và cha tuỳ chọn. Dòng tim không thuộc bộ; suất con trỏ dòng combo cùng khách và cùng bộ. Chỉ giữ tham chiếu menu, không chụp giá, tên hay ảnh (điểm 2, 3, 6) |
| `customer_favourite_line_option` | Lựa chọn của dòng món, gồm cả suất con; dòng combo không có lựa chọn trực tiếp (điểm 2) |

Ba bảng có id bigint identity, khoá chính `<bảng>_pkey`, created_at bắt buộc
mặc định now() theo QD-10/34 và QC-04. Khoá ngoại dùng bigint, số lượng dùng
integer, mốc dùng timestamptz, văn bản dùng vi-x-icu. Mọi khoá ngoại giữ quy tắc
mặc định từ chối, không xoá hay cập nhật dây chuyền (QD-11/51).

## 2. Ràng buộc và tầng bảo vệ

| Ràng buộc | Lý do và ánh xạ ADR-145 |
|---|---|
| `customer_favourite_set_account_fkey`, `customer_favourite_line_account_fkey` | Bộ và dòng thuộc tài khoản khách có thật (điểm 1) |
| `customer_favourite_set_owner_key`, `customer_favourite_line_owner_key` | Khoá ghép id và chủ làm đích cho liên kết cùng khách (điểm 1, 2) |
| `customer_favourite_line_set_fkey`, `customer_favourite_line_parent_fkey` | Dòng không trỏ được vào bộ hay cha của khách khác (điểm 1, 2, 6) |
| `customer_favourite_line_menu_item_fkey`, `customer_favourite_line_menu_combo_fkey` | Món/combo phải có thật, tên và giá lấy từ menu hiện hành (điểm 2, 3) |
| `customer_favourite_set_kind_check` | Chỉ hai loại bộ đã chốt (điểm 6) |
| `customer_favourite_set_name_check` | Tên không rỗng sau btrim và không quá 60 ký tự (điểm 6) |
| `customer_favourite_line_item_xor_combo_check` | Mỗi dòng đúng một trong món hoặc combo (điểm 2) |
| `customer_favourite_line_quantity_check` | Số lượng trong 1–99 (điểm 8) |
| `customer_favourite_line_shape_check` | Khi thêm, dòng con là món; cha là combo chưa gỡ cùng bộ, kể cả cùng không thuộc bộ; combo không có cha (điểm 2, 7) |
| `customer_favourite_line_option_line_fkey`, `customer_favourite_line_option_option_fkey` | Dòng và lựa chọn có thật (điểm 2) |
| `customer_favourite_line_option_key`, `customer_favourite_line_option_item_line_check` | Không lặp lựa chọn trên một dòng; chỉ dòng món mang lựa chọn (điểm 2) |
| `customer_favourite_set_limit_check` | Tối đa 20 bộ chưa gỡ mỗi khách, tính chung hai loại (điểm 8) |
| `customer_favourite_line_limit_check` | Tối đa 50 dòng tim gốc chưa gỡ mỗi khách, 20 dòng gốc chưa gỡ mỗi bộ; dòng con không tính (điểm 8, hợp đồng test YT-03) |
| `customer_favourite_set_removed_once_check`, `customer_favourite_line_removed_once_check` | Mốc gỡ ghi một lần; không xoá hay đổi mốc đã ghi, ghi lại cùng giá trị được phép (điểm 7) |

Các tên từ chối do trigger giữ cũng là tên trigger; hàm phát check_violation
với CONSTRAINT đúng tên trên và thu hồi quyền PUBLIC. Kiểm hình dòng khi thêm
để vẫn gỡ được suất con sau khi đã gỡ cha. Cha không tồn tại hoặc khác khách
do khoá ngoại ghép từ chối bằng foreign_key_violation.

Hai phép đếm lấy khoá FOR NO KEY UPDATE trên cùng dòng customer_account trước
khi đọc số lượng, giữ khoá đến hết giao dịch. Phép lấy khoá và phép đếm là hai
câu riêng: ở READ COMMITTED, lần đang chờ thấy dữ liệu vừa commit trước khi
đếm, nên hai lần thêm cùng khách không vượt giới hạn. Khoá không thay dữ liệu
tài khoản, không xung đột với KEY SHARE của khoá ngoại; khách khác khoá dòng
khác. Quyền UPDATE không cho đổi chủ, bộ, cha, món hay loại bộ; mốc gỡ không
được bỏ, nên UPDATE không làm tăng số dòng đang được tính.

## 3. Quyền và vết

QC-03 cấp SELECT, INSERT và quyền sequence mặc định cho shop_app. Thu hồi
UPDATE cấp bảng; chỉ cấp UPDATE (name, removed_at) trên bộ và
UPDATE (quantity, removed_at) trên dòng. Bảng lựa chọn chỉ thêm, không sửa.
Không cấp DELETE/TRUNCATE (QD-50); sửa thành phần bộ là gỡ dòng cũ rồi thêm
dòng mới trong một giao dịch (ADR-145 điểm 7).

Mỗi bảng có trigger `<bảng>_record_revision_trg` AFTER UPDATE gọi
record_revision_capture(), gồm cả bảng lựa chọn chỉ thêm (QD-52).
record_revision_person_check thêm ba bảng vào miền cho phép người sửa rỗng,
giữ nguyên sáu tên trước đó: khách không phải người của quán; chủ đọc từ dòng
đích, với lựa chọn thì đi qua dòng món. Vẫn phải khai lý do sửa như cơ chế vết
hiện hành. record_revision_target_table_code_check chỉ kiểm dạng tên, không
liệt kê bảng nên không cần đổi.

## 4. Đường lùi và ranh giới lát

File down khoá ACCESS EXCLUSIVE cả ba bảng trước khi đếm; có dù một dòng,
kể cả đã gỡ, thì customer_favourite_set_rollback_check từ chối trước mọi DDL.
Khi cả ba rỗng, trả record_revision_person_check về đúng miền trước bước này
(gồm model_call), giữ nguyên record_revision_target_table_code_check, rồi gỡ
trigger, hàm và bảng theo thứ tự lựa chọn, dòng, bộ. Không gỡ dữ liệu đã ghi.
Thứ tự và phép chứng minh dựng từ số không, xuôi → lùi → xuôi lại thuộc
[07-thu-tu-migration.md](07-thu-tu-migration.md) và `scripts/db-check.sh`.

Kiểm lựa chọn thuộc món, đủ nhóm, suất khớp combo dùng lại bước kiểm hàm giá
ở cửa ghi backend (ADR-145 điểm 4). Cộng số lượng khi thả tim lại cùng hình
dòng do cửa ghi thực hiện dưới khoá theo khách, không phải khoá duy nhất
ở ba bảng (điểm 7). Xác định khách của phiên, quyền đọc/ghi của chính khách,
tính giá hiện hành và cờ không còn bán thuộc lát backend/giao diện kế tiếp
(điểm 1, 3, 5); lược đồ không tự thêm luật hay cột cho các phần ấy.
