# Lược đồ lát khoản chi

Pha 2 · P2A-05 · 2026-10-14 · thi công Codex, thiết kế Claude Code.
Quyết định: `docs/decisions.md` **ADR-106** (hình hai bảng) và **ADR-074** (nguồn trên loại).

Tên, kiểu và ràng buộc thuộc
[`db/migrations/20261014180000_khoan_chi.up.sql`](../../../db/migrations/20261014180000_khoan_chi.up.sql),
không thuộc file này (ADR-053). File này giữ ý định, lý do và ánh xạ.
Lời chủ quán ở `master_plan/shop-facts.md` §8.10; mệnh đề ở `quality/invariants.md` **I-029** và **I-021**;
yêu cầu **YC-33** ở `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9.

## 1. Hai bảng và nguồn tiền

| Bảng | Ý định và lý do |
|---|---|
| `expense_category` | Danh sách loại thêm được; mỗi loại khai rõ nguồn két hay không. ADR-106 giữ nguồn sau khi tạo để không viết lại két của ngày cũ. |
| `expense` | Mỗi khoản đọc đủ loại, tiền, ngày khai, người và lúc ghi; tổng khoảng ngày là phép cộng, không cất tổng. |

Dữ liệu mồi `db/seed/seed.pl` kiểm tên trong §8.10 rồi thêm điện, nước, wifi, xăng xe từ két;
marketing tiền riêng theo lời đóng U-093. Không mặc định nguồn cho loại mới.
Ngày két là ngày người ghi khai (`paid_date`, lời đóng U-072), dù lúc ghi sang ngày khác.
Hạng tử chi từ két trong `db/reconcile/prelude.sql` chỉ cộng khoản của loại mang nguồn két.

## 2. Ánh xạ và bằng chứng

| Vế | Cái giữ và phép kiểm |
|---|---|
| I-029 · YC-33: có loại, người ghi | Dấu bắt buộc và `expense_category_fkey` · `expense_person_fkey`; test i029 thử thiếu và mã lạ. |
| Số tiền dương (QD-20/21) | `expense_positive_amount_check`; test i029 thử thiếu, 0, âm; ngày mẫu có dòng để `db/reconcile/proof/qd21_so_am.sql` thử cột mới. |
| Ngày khai, lúc ghi riêng | Dấu bắt buộc; test i029 đọc lại, thử thiếu ngày và người thao tác. |
| Loại có tên và nguồn | `expense_category_name_key` · `expense_category_name_not_blank_check` và nguồn bắt buộc; test i029 thử thiếu nguồn, tên rỗng, tên trùng. |
| Sửa có vết (QD-52) | Hai trigger dùng cơ chế nghiêm hiện hành; test i029 sửa ba lần và thử thiếu lý do. |
| Quyền sửa, không xoá (QD-50) | `shop_app` chỉ sửa tên loại, hoặc loại · tiền · ngày khoản; test i029 thử đổi nguồn, đổi người/lúc ghi, xoá hai bảng. |
| I-021: khoản rời két | hàm `ket_ngay` cộng theo ngày khai; ngày mẫu có điện từ két và marketing tiền riêng, số đếm trừ điện cùng lượt. |

Test nền: `db/tests/i029_expense_names_category_amount_date_writer.sql` do Claude viết trước code;
Codex giữ nguyên. Câu `db/reconcile/i029.sql`: /1 thiếu dấu khoản, /2 loại thiếu tên/nguồn hoặc trùng tên,
/3 chuỗi vết đứt; ba lỗi cài `db/reconcile/proof/i029_1.sql`…`db/reconcile/proof/i029_3.sql` dùng khoản tiền riêng để không gây lệch két.
Ánh xạ bộ đối chiếu: [09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md).
S4.10 trong `db/scenario/s4_ngay_quan_tri.sql` ghi hai nguồn; `doc_lai.sql` đọc lại;
`yc.sql` chấm YC-33 đọc và sai. Database do Claude chạy khi tích hợp; chưa coi thiết kế phép kiểm là kết quả chạy.

## 3. Giới hạn và bước lùi

Tiền hàng và lương không thuộc khoản chi: đây là giới hạn nghiệp vụ I-029, máy không đoán nghĩa tên loại.
Không cất ghi chú, kỳ, nhà cung cấp, hay ngày bán của két (ADR-106 điểm 5).
Không dựng công thức lãi/lỗ, phân bổ tháng, thuế hay tiền mang về nhà; các việc ấy ngoài lát.
Chuỗi vết chỉ phát hiện đứt khi đã có vết, không suy được lần sửa vượt database trên dòng chưa từng có vết.
Quyền theo cột bảo vệ vai ghi; chủ bảng vẫn sửa trực tiếp được, nên không coi nó là cửa nghiệp vụ đã dựng.

Bước 28 trong [07-thu-tu-migration.md](07-thu-tu-migration.md) có file lùi:
[`db/migrations/20261014180000_khoan_chi.down.sql`](../../../db/migrations/20261014180000_khoan_chi.down.sql).
Khoá chặn kiểm cả hai bảng còn rỗng trước khi gỡ trigger và bảng khoản rồi bảng loại.
Không thêm bảng vào tham số ngoại lệ của [01-quy-uoc-du-lieu.md](01-quy-uoc-du-lieu.md).
