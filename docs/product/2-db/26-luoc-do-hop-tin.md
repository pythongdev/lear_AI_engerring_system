# Lược đồ hộp tin trạm ↔ quầy

CHAT-12 · thi công theo ADR-137 điểm 3, 6, 9; I-038. Tin báo là lời trao đổi,
không phải lệnh đổi tiến độ. Tên, kiểu và ràng buộc do
[migration](../../../db/migrations/20261103120000_hop_tin.up.sql) sở hữu.

## Chỗ cất và quyền

| Bảng | Ý định |
|---|---|
| `station_message` | Tin chỉ thêm, gửi tới một người hoặc về quầy, có thể nhắc bàn và trả lời tin trước |

Người nhận rỗng là gửi về quầy. Một người kiêm nhiều trạm vẫn nhận một tin;
nhãn việc phân biệt ngữ cảnh, không định tuyến theo vai. Liên kết chỉ tới người,
bàn và tin khác, nên không có đường ghi tiến độ, phiên, đơn hay việc giao qua tin.
Khoá mã gửi duy nhất toàn bảng chặn thêm dòng khi gửi lại; trả đúng tin cũ của
cùng người và từ chối mã của người khác thuộc cửa ghi của CHAT-13 (ADR-137 điểm 6).

Quyền SELECT/INSERT và sequence theo QC-03; thu hồi UPDATE mặc định và không cấp
DELETE. Trigger record_revision_capture giữ vết nếu chủ lược đồ sửa tay (QD-52).
Văn bản người đọc so theo tiếng Việt, mã so từng byte (QD-60/QD-61).
Không cất trạng thái tiến độ hay dấu đã đọc.

## Đối chiếu và đường lùi

Giữ nguyên db/tests/i038_station_message.sql để kiểm I-038: ca gửi/nhận/trả lời,
các từ chối, quyền chỉ thêm và nội dung mọi bảng khác trước/sau khi gửi.
Bốn câu trong db/reconcile/i038.sql đối chiếu ranh giới khoá ngoại, người gửi
khác người nhận, quyền sửa/xoá và miền nội dung/nhãn; mỗi câu có file lỗi cùng số.
Vế tin riêng chỉ người gửi, người nhận hoặc quầy đọc được là tầng 3, thuộc cửa
đọc của CHAT-13, không được suy từ quyền SELECT của vai ứng dụng.

Down khoá bảng và từ chối khi còn tin. Khi rỗng mới gỡ trigger, bảng và các
ràng buộc, sequence, quyền gắn với bảng; không gỡ hàm vết dùng chung.
Bộ db-check kiểm test xanh rồi lùi có tin bị chặn; vòng xuôi/lùi chung so ảnh
lược đồ rỗng trước và sau bước 42, gồm cả quyền.
