# Lược đồ lát tài khoản khách và định danh điện thoại

T-263 · 2026-10-27 · Codex thi công phiếu Claude theo ADR-131 điểm 1–7.
Tên, kiểu và ràng buộc thuộc
[`db/migrations/20261027120000_tai_khoan_khach.up.sql`](../../../db/migrations/20261027120000_tai_khoan_khach.up.sql).
File này giữ ý định và ánh xạ I-033 · I-035; cơ chế liên kết đơn theo bổ sung
phiếu của Claude ngày 2026-10-27.

## 1. Chỗ cất và lý do

| Bảng | Ý định |
|---|---|
| `account` | Thêm số điện thoại; thư và tên đăng nhập cũ trở thành tuỳ chọn, giữ giá trị và mọi CHECK cũ. Không đổi người, vai, duyệt hay phiên của người làm (ADR-131 điểm 2) |
| `customer_account` | Tài khoản khách có số hoặc thư, tên hiển thị và một bộ thông tin giao đã nhớ; không có trạng thái duyệt, không trỏ người của quán (ADR-131 điểm 3, 6) |
| `customer_password` | Mỗi lần đặt mật khẩu thêm một bản băm; bản hiện hành theo created_at DESC, id DESC như bản mật khẩu người làm. Không có người đặt hay cờ mật khẩu tạm |
| `customer_session` | Băm mã phiên, hạn và dấu kết thúc; không gắn trực quầy. Khách không cần được duyệt mới mở phiên |
| `sales_order` | customer_account_id tuỳ chọn gắn tài khoản lúc tạo đơn web; thông tin liên hệ trên đơn vẫn là bản riêng (ADR-131 điểm 5, 7) |
| `customer_password_reset` | Băm mã đặt lại có hạn, ghi lúc dùng và không được dùng lại |

Bốn bảng mới có id identity, khoá chính tên `<bảng>_pkey`, created_at bắt buộc
mặc định now() theo QD-10/34, QC-04. Mỗi bảng con có khoá ngoại
`<bảng>_account_fkey` qua customer_account_id, không xoá/cập nhật dây chuyền (QD-11/51).
Không cột nào của chúng nối tới person, counter_duty hay account.
Mốc dùng timestamptz; văn bản dùng vi-x-icu, băm mật khẩu dùng C, băm mã dùng bytea.
CHECK số áp COLLATE C tường minh, giữ đúng mẫu chữ số ASCII.

## 2. Ràng buộc và tầng bảo vệ

| Ràng buộc | Lý do và ánh xạ |
|---|---|
| `account_phone_key`, `customer_account_phone_key`, `customer_account_email_key` | Mỗi số/thư duy nhất trong một loại; hai loại được trùng nhau (I-035, ADR-131 điểm 3). Khoá email cũ của người làm giữ nguyên |
| `account_phone_check`, `customer_account_phone_check` | DB chỉ nhận số chuẩn hoá theo mẫu ADR-131 điểm 1; không tự sửa đầu +84 hay khoảng trắng (I-035/2) |
| `account_contact_check`, `customer_account_contact_check` | Có ít nhất số hoặc thư (I-035/1); NULL vẫn được phép ở từng cột |
| `customer_account_email_check` | Cùng khuôn account: chữ thường và có @; không tự ép đuôi Gmail hay thêm luật địa chỉ |
| `customer_account_display_name_check` | Tên bắt buộc, không rỗng sau btrim |
| `customer_account_delivery_name_check`, `customer_account_delivery_phone_check`, `customer_account_delivery_address_check` | Bộ giao đã nhớ tuỳ chọn; từng giá trị nếu có phải không rỗng sau btrim. Không tự buộc đủ bộ hay áp mẫu số đăng nhập cho số giao |
| `customer_password_hash_check` | Chỉ nhận tiền tố argon2id như I-033; không chứng minh băm hợp lệ hay mật khẩu đủ mạnh |
| `customer_session_token_key`, `customer_password_reset_token_key` | Băm mã duy nhất; nhận ra đúng một phiên/mã (I-033 áp cho khách, I-035) |
| `customer_session_token_hash_check`, `customer_password_reset_token_hash_check` | Đúng 32 byte; không cất mã thô theo khuôn I-033 |
| `customer_session_expiry_check` | Hạn sau lúc tạo và không quá 7 ngày |
| `customer_session_end_pair_check`, `customer_session_end_reason_check`, `customer_session_ended_at_check` | Lúc kết thúc và lý do có cùng nhau, không trước tạo; chỉ đăng xuất, đổi mật khẩu, đặt lại mật khẩu |
| `customer_password_reset_expiry_check`, `customer_password_reset_used_at_check` | Hạn sau lúc tạo, tối đa 30 phút; lúc dùng trong khoảng từ tạo tới trước hạn |
| `customer_session_ended_immutable_check` | Trigger chặn mọi sửa phiên đã kết thúc, theo khuôn login_session |
| `customer_password_reset_used_once_check` | Trigger chặn mọi sửa mã đã dùng, theo khuôn password_reset |

Ba ràng buộc của liên kết đơn: `sales_order_customer_account_fkey` trỏ tới
customer_account(id); `sales_order_customer_account_channel_check` chỉ cho liên kết
ở delivery/pickup (I-035/4); `sales_order_customer_account_immutable_check` do hàm
sales_order_customer_account_guard từ chối bằng check_violation khi OLD và NEW
khác nhau theo IS DISTINCT FROM. Trigger sales_order_customer_account_guard_trg
chạy BEFORE UPDATE OF customer_account_id, kể cả chuyển NULL sang có tài khoản
hoặc xoá liên kết về NULL; ghi lại cùng giá trị vẫn được. Không đổi grant sales_order.

Mỗi bảng mới có trigger `<bảng>_record_revision_trg` gọi record_revision_capture
(QD-52, I-018); các hàm trigger mới thu hồi quyền PUBLIC như lát tài khoản cũ.
Quyền SELECT/INSERT và sequence lấy từ mặc định QC-03; không cấp DELETE/TRUNCATE.
Thu hồi UPDATE cấp bảng rồi chỉ cho sửa tên hiển thị và bộ giao đã nhớ
(kèm delivery_updated_at), hai cột kết thúc phiên, hoặc used_at của mã đặt lại.
Bản mật khẩu chỉ thêm. Định danh và hạn không sửa qua vai ứng dụng.
Quyền của tài khoản người làm giữ nguyên như lát cũ.

## 3. Đối chiếu, đường lùi và phần chưa xong

Test hồi quy Claude viết trước: `db/tests/i035_customer_account_apart_from_staff.sql`,
giữ nguyên nội dung; test tài khoản cũ: `db/tests/i033_account_session_and_reset.sql`.
`db/reconcile/i035.sql` có bốn tập: thiếu liên hệ, số sai dạng, khoá ngoại
khách tới người của quán và đơn không phải web mang tài khoản khách; mỗi tập có lỗi cài ở `db/reconcile/proof/i035_<số>.sql`.
Câu I-033/7 thôi coi username/email NULL là sai theo ADR-131.
[09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md) ánh xạ bốn câu và cách chứng minh bằng lỗi cài.

Đường lùi ở [07-thu-tu-migration.md](07-thu-tu-migration.md) khoá bảng trước khi xét:
`account_contact_rollback_check` từ chối nếu có số đã ghi hoặc thiếu thư/tên đăng nhập;
`customer_account_rollback_check` từ chối nếu có khách. FK bảo đảm bảng khách rỗng
thì các bảng con cũng rỗng và đơn không có liên kết khách. Gỡ trigger, hàm, CHECK,
FK và cột liên kết đơn trước; rồi gỡ mã đặt lại, phiên, mật khẩu, tài khoản khách và hàm
trigger, rồi trả account về hình cũ. Không gỡ dữ liệu đã ghi.

Hợp đồng 0.51.1 ánh xạ khoá chính mới thành internal, các tên còn lại của bước xuôi
thành unreviewed theo phiếu; lát T-264 sẽ gán mã công khai.
Cookie, quyền cửa khách, chuẩn hoá đầu vào và gửi thư thuộc lát backend kế tiếp;
lát này không quyết các câu hỏi còn mở về khách ở ADR-131.
