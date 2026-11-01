# Lược đồ lát đăng nhập Google của khách

T-267 · 2026-10-28 · Codex thi công phiếu Claude theo ADR-132.
Tên, kiểu và ràng buộc thuộc
[`db/migrations/20261028120000_khach_google.up.sql`](../../../db/migrations/20261028120000_khach_google.up.sql).

## 1. Chỗ cất và lý do

| Bảng | Ý định |
|---|---|
| `customer_google_identity` | Nối định danh Google ổn định với tài khoản khách; chỉ thêm, không nối bằng thư, không trỏ tới người của quán (I-035, ADR-132 điểm 4–5) |

Mỗi tài khoản khách có nhiều nhất một liên kết; mỗi sub chỉ thuộc một tài khoản.
Sub dùng collation C để so chính xác; CHECK từ chối chuỗi trống sau btrim hoặc dài quá 255 ký tự.
Khoá ngoại chỉ tới customer_account. Không tạo customer_password khi đăng ký bằng Google.

## 2. Quyền và vết

SELECT/INSERT và sequence theo mặc định QC-03; thu hồi UPDATE của shop_app,
không cấp DELETE/TRUNCATE. Trigger vết theo khuôn customer_password, không mở rộng
record_revision_person_check: ứng dụng không được sửa liên kết này.

## 3. Đối chiếu và đường lùi

Test Claude viết trước: `db/tests/i035_google_identity.sql`; test nền:
`db/tests/i035_customer_account_apart_from_staff.sql`. Không sửa hai test.
Phép đối chiếu `db/reconcile/i035.sql` mục I-035/3 đã phủ mọi bảng customer_* nên
phủ cả liên kết Google, không cần thêm câu hoặc lỗi cài.

Đường lùi khoá bảng trước khi xét; customer_google_identity_rollback_check từ chối
khi đã có dòng. Bảng rỗng mới gỡ; thứ tự và phép kiểm ở
[07-thu-tu-migration.md](07-thu-tu-migration.md).
