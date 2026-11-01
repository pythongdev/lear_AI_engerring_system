# Lược đồ xác nhận Gmail khách

T-270 · 2026-10-29 · Codex thi công phiếu Claude theo ADR-133.
Tên, kiểu, ràng buộc thuộc [migration](../../../db/migrations/20261029120000_xac_nhan_gmail.up.sql).

## Chỗ cất và quyền

| Bảng | Ý định |
|---|---|
| `customer_email_verification` | Mã xác nhận Gmail khách, dùng một lần trong 24 giờ |

customer_account thêm pending_email không duy nhất, chuẩn hoá và khác email khi có giá trị.
email giữ Gmail đã xác nhận; tài khoản chỉ có pending_email vẫn hợp lệ.
customer_email_verification cất Gmail mỗi lần gửi, băm 32 byte duy nhất, hạn tối đa 24 giờ;
used_at trong thời hạn và chỉ đặt một lần. FK chỉ trỏ customer_account (I-035).
Quyền SELECT/INSERT và sequence theo QC-03; REVOKE UPDATE rồi chỉ cấp used_at.
Trigger record_revision_capture ghi vết; record_revision_person_check cho phép person_id rỗng
với bảng mới. customer_account được cập nhật email, pending_email.

## Đối chiếu và đường lùi

Giữ nguyên db/tests/i035_email_verification.sql cùng các test I-035 cũ.
I-035/1 trong db/reconcile/i035.sql nhận cả Gmail chờ; I-035/3 đã phủ bảng mới.
Down khoá cả hai bảng, từ chối khi có mã hoặc Gmail chờ; khi rỗng mới gỡ bảng,
hàm trigger, quyền mới, cột và trả hai CHECK về như trước.
