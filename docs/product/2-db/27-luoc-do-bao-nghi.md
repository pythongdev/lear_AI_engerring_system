# Lược đồ báo nghỉ — một người nghỉ một ngày

CHAT-30 · 2026-11-04 · thi công Codex theo ADR-138 điểm 1, 2, 3, 4, 5, 8;
I-039. Lời thuộc `master_plan/shop-facts.md` §8.11 điểm 7, kể cả lời thêm
2026-11-04. Tên, kiểu và ràng buộc do
[migration](../../../db/migrations/20261104120000_bao_nghi.up.sql) sở hữu;
file này giữ ý định và ánh xạ, không phải hợp đồng cột.

## Chỗ cất và quyền

| Bảng | Ý định |
|---|---|
| `leave_notice` | Một lần báo của một người cho một ngày; giữ dấu chủ quán đã biết và dấu huỷ để đọc lại |

Nghỉ nhiều ngày là nhiều dòng. Huỷ giữ dòng cũ; báo lại tạo dòng mới.
Mã gửi duy nhất theo người, so từng byte theo QD-61. Không cất loại nghỉ,
lý do, trạng thái hay tiền. Liên kết chỉ tới `person`; không có hàm hay view
đưa báo nghỉ sang tiền, lương, khoản của người, két hoặc đơn.

Quyền SELECT/INSERT và sequence dùng mặc định QC-03; thu hồi UPDATE toàn bảng,
chỉ cấp sửa hai cặp dấu; không DELETE (QD-50). Trigger
`record_revision_capture` giữ vết theo QD-52, dùng chế độ nghiêm hiện có.

## Mệnh đề và tầng bảo vệ

| Vế của I-039 / ADR-138 | Tầng | Cái giữ và bằng chứng |
|---|:--:|---|
| Điểm 1: một người, một ngày, mã gửi theo người, hai cặp dấu đủ đôi | 1 | NOT NULL, FK về người, CHECK đôi và khoá mã gửi; test I-039 đọc lại, ca thiếu người, người lạ, mã trùng và dấu lẻ |
| Điểm 1: người báo là người của phiên, không ghi hộ | 3 | Mặc định lấy người thao tác không ngăn INSERT chỉ định người khác; cửa CHAT-31 phải lấy người từ phiên |
| Điểm 2: không cất loại báo trước / đột xuất | 1 / 3 | Test I-039 so tập cột; backend suy loại theo ngày lịch Việt Nam và ngưỡng ở ADR-138, thuộc CHAT-31 |
| Điểm 3: một báo nghỉ còn hiệu lực cho một người một ngày; không báo ngày đã qua | 1 | Khoá duy nhất một phần và trigger theo ngày lịch Việt Nam; test I-039 ca trùng ngày và ngày đã qua |
| Điểm 3: chủ quán ghi đã biết; chủ quán huỷ hoặc chính người nghỉ huỷ trước ngày nghỉ | 1 | Trigger đọc cờ chủ quán khi đặt người của cặp dấu; test I-039 ca người thường, người khác huỷ, huỷ muộn và ca hợp lệ |
| Điểm 3: dấu ghi một lần, thông tin gốc bất biến; không xoá | 1 | Trigger và quyền theo cột; test I-039 đổi người, ngày, xoá dòng và xoá dấu |
| Điểm 4, 8: không vừa có ô còn hiệu lực vừa có báo nghỉ còn hiệu lực | 1 | Trigger BEFORE ở cả hai bảng lấy cùng khoá giao dịch theo người/ngày trước khi đọc bảng kia; test I-039 tick, báo nghỉ và làm sống lại ô |
| Điểm 5, 8: báo nghỉ không đổi ô chấm công, không chạm tiền | 3 | Cấu trúc và hàm chỉ đọc người/ô/báo nghỉ; test I-039 so nội dung bảng khác, đối chiếu ranh giới FK; không công thức lương hay khoản trừ |
| Điểm 6, 7: cửa và mẫu giao diện | 3 | Ngoài lát này, CHAT-31/32 thực hiện; quyền SELECT của vai ứng dụng không thay quyền đọc theo phiên |

Công thức khoá chỉ nằm ở `leave_notice_day_lock_key`; cả hai trigger gọi
`pg_advisory_xact_lock` với kết quả ấy. Hàm trigger mặc định VOLATILE để câu
đọc sau khi đợi khoá lấy ảnh mới ở mức READ COMMITTED của ứng dụng. Va chạm
băm chỉ làm các cặp khác nhau đợi nhau. Không sửa ô công khi thêm báo nghỉ;
người dùng phải huỷ ô trước theo luật chấm công hiện có.

## Đối chiếu và đường lùi

Giữ nguyên `db/tests/i039_leave_notice.sql`. Bốn câu trong
`db/reconcile/i039.sql` kiểm ngày có cả hai sự thật, FK ngoài người, quyền
sửa/xoá vượt giới hạn và người ghi dấu sai quyền. Mỗi câu có một file lỗi cùng
số ở `db/reconcile/proof/`; tầng 1 được gỡ trước khi cài lỗi.
Câu thứ tư đọc cờ chủ quán hiện hành, không tái dựng cờ trong quá khứ và không
kiểm thời điểm tự huỷ; luật thời điểm được test hồi quy giữ.

Down khoá bảng báo nghỉ, từ chối nếu có bất kỳ dòng nào, kể cả đã huỷ.
Bảng rỗng mới gỡ trigger trên ô công, các hàm riêng, trigger vết và bảng cùng
sequence/quyền; giữ nguyên hàm vết dùng chung. Khối CHAT-30 của db-check kiểm
I-039 xanh rồi down có dữ liệu bị từ chối; vòng xuôi/lùi chung so ảnh lược đồ
rỗng về bước 42, gồm quyền.
