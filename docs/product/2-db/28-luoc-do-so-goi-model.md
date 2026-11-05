# Lược đồ sổ gọi model — giữ chỗ trước, chốt một lần

CHAT-35 · 2026-11-04 · thi công Codex theo ADR-139 điểm 5, 6, 11; I-040.
Lời thuộc `master_plan/shop-facts.md` §8.11 điểm 5. Tên, kiểu và ràng buộc do
[migration](../../../db/migrations/20261104180000_so_goi_model.up.sql) sở hữu;
file này giữ ý định và ánh xạ, không phải hợp đồng cột.

## Chỗ cất và quyền

| Bảng | Ý định |
|---|---|
| `model_call` | Một dòng mỗi lần gọi model, giữ tiền dự kiến trước khi gọi và phần chốt sau lần gọi |

Chi phí là số nguyên phần triệu USD theo QD-03, không phải tiền bán hàng.
Không cất nội dung, người hay phiên; không có khoá ngoại. Tháng và ngày lấy
từ mốc giữ chỗ theo giờ Asia/Ho_Chi_Minh. Dòng treo tiếp tục chiếm ngân sách
bằng tiền giữ chỗ kể cả khi server khởi động lại.

QC-03 giữ SELECT và quyền sequence mặc định cho shop_app; thu hồi INSERT,
UPDATE toàn bảng và DELETE. Chỉ thêm nhà cung cấp, model, tiền giữ chỗ; chỉ
sửa mốc chốt, hai số token, chi phí. Mốc giữ chỗ do database cấp. Trigger
`record_revision_capture` giữ vết UPDATE theo QD-52, dùng chế độ nghiêm hiện có. Chốt do máy ghi, không có người của quán, nên `record_revision_person_check` nhận `model_call` vào danh sách bảng có vết người rỗng (như các bảng khách); đường lùi trả danh sách về bước 43. *Claude thêm khi duyệt, 2026-11-04.*

## Mệnh đề và tầng bảo vệ

| Vế của I-040 / ADR-139 | Tầng | Cái giữ và bằng chứng |
|---|:--:|---|
| Điểm 5: một dòng một lần gọi, tiền phần triệu USD, mã hợp lệ, không nội dung/người/phiên | 1 | Identity, NOT NULL, CHECK miền; test I-040 so đúng chín cột và không FK |
| Điểm 5: thông tin giữ chỗ không đổi, chốt một lần, không xoá | 1 | Trigger BEFORE UPDATE, quyền theo cột; test sửa giữ chỗ, dời mốc, chốt lại, xoá trắng và DELETE |
| Điểm 5: phần chốt đủ đôi, số token chỉ có khi chốt, số không âm, chốt không trước giữ chỗ | 1 | CHECK; test ca lẻ đôi, token khi chưa chốt, số âm, mốc ngược |
| Điểm 6: trước khi nhận giữ chỗ mới, tổng tháng không vượt 10 USD, tổng ngày không vượt một phần mười | 1 | Trigger BEFORE INSERT lấy khoá giao dịch trước khi cộng; hai trần hằng trong hàm, vai ghi không nâng được; test vượt/chạm trần và biên tháng Việt Nam |
| Điểm 6: dòng chưa chốt tính bằng giữ chỗ, không mở lại ngân sách khi khởi động lại | 1 | Tổng đọc từ sổ bền vững bằng chi phí nếu có, nếu không bằng giữ chỗ; test dòng treo và chốt thấp mở lại phần dư |
| Điểm 5, 11: không lần gọi nào thiếu giữ chỗ | 3 | Backend CHAT-03 phải ghi giữ chỗ thành công trước khi gọi nhà cung cấp |
| Điểm 5, 6: tiền giữ chỗ tính từ bảng giá cấu hình; thiếu bảng giá thì không gọi | 3 | Backend CHAT-03 tính đầu vào ước tính và 800 token đầu ra theo ADR-139 |
| Điểm 6: chốt bằng tiền giữ chỗ khi không biết mức dùng; cấu hình chỉ hạ trần, hết ngân sách trả suy giảm | 3 | Backend CHAT-03; database không đọc cấu hình hoặc biến phiên để nâng trần |

Khoá cố định dùng chung toàn sổ, nên các lượt giữ chỗ đợi nhau trước khi cộng.
Hàm trigger mặc định VOLATILE đọc ảnh mới sau khi đợi khoá ở READ COMMITTED
của ứng dụng. Chốt cao hơn giữ chỗ vẫn được ghi để giữ sự thật theo test Claude;
kiểm trần áp khi giữ chỗ mới, không từ chối phần chốt. Phép đối chiếu báo tháng
vượt trần nếu chi phí chốt làm vượt. Không tuyên bố CHECK chặn được chi phí
ngoài dự kiến của nhà cung cấp.

## Đối chiếu và đường lùi

Giữ nguyên `db/tests/i040_model_call_budget.sql`. Bốn câu trong
`db/reconcile/i040.sql` đọc tổng tháng vượt trần, FK, quyền vượt danh sách,
và chốt thiếu chi phí hoặc trước mốc giữ chỗ. Mỗi câu có một file lỗi cùng
số ở `db/reconcile/proof/`, tập kêu phải đúng tập khai. Trần ngày, biên thời gian
và dấu một lần được test hồi quy giữ; phép đọc tĩnh không chứng minh thứ tự
backend gọi nhà cung cấp.

Down khoá sổ, từ chối khi còn bất kỳ dòng nào, kể cả đã chốt. Rỗng mới gỡ
trigger luật/vết, hàm riêng và bảng cùng sequence/quyền; giữ hàm vết chung.
Khối CHAT-35 của db-check kiểm I-040 xanh rồi down có dòng phải bị từ chối;
vòng xuôi/lùi chung so ảnh lược đồ rỗng về bước 43, gồm quyền.
