# Lược đồ lát tài khoản đăng nhập

Pha 2 · P2A-14 · 2026-10-14 · Codex thi công hình Claude Code giao theo ADR-109, gồm mục Sửa đổi.
Tên bảng, cột, kiểu và ràng buộc thuộc
[`db/migrations/20261014170000_tai_khoan.up.sql`](../../../db/migrations/20261014170000_tai_khoan.up.sql).
File này giữ ý định và ánh xạ I-033 · YC-38; không mở cửa backend.

## 1. Bốn bảng

| Bảng | Giữ gì và lý do |
|---|---|
| `account` | tên đăng nhập và email duy nhất, chữ thường; tên hiển thị khai ban đầu; trạng thái, người, vai, ai quyết và lúc quyết. Chờ duyệt chưa thuộc tập người; hoạt động hoặc khoá phải có đủ người, vai và quyết định |
| `account_password` | từng bản băm argon2id, người đặt khi là mật khẩu tạm, cờ buộc đổi; bản hiện hành theo `created_at DESC, id DESC`, bản cũ không mất |
| `login_session` | băm mã 32 byte duy nhất, lúc tạo, hạn tối đa 7 ngày, lúc kết thúc và lý do; trực quầy nullable và duy nhất, trỏ khoảng của chính người đăng nhập |
| `password_reset` | băm mã 32 byte duy nhất, lúc tạo, hạn tối đa 30 phút, lúc dùng trong khoảng từ lúc tạo đến trước hạn; chỉ dùng một lần |

Mỗi bảng có khoá identity và lúc tạo do database cấp. Không có cột đếm lần sai hay số thư.
Vai `owner` theo Sửa đổi ADR-109; quyền vẫn đọc cờ chủ quán, không từ vai tài khoản.
Email chỉ kiểm chữ thường và có `@`, không ép đuôi Gmail hay tự bổ sung chuẩn địa chỉ.
Mật khẩu kiểm tiền tố `$argon2id$`, không chứng minh nội dung là băm argon2id hợp lệ.
Mã băm dùng `bytea` theo hình giao việc; QC-04 bổ sung kiểu này cho cột băm, QD-61 so từng byte.
Tên đăng nhập, email, lý do kết thúc dùng cách so văn bản QD-60; mã trạng thái, vai và băm mật khẩu so `C`.

| Cột | Mã | Tên ở owner ADR-109 điểm 2 |
|---|---|---|
| `account.status` | `cho_duyet` | chờ duyệt |
| `account.status` | `hoat_dong` | hoạt động |
| `account.status` | `khoa` | khoá |
| `account.status` | `tu_choi` | từ chối |

## 2. Mệnh đề, tầng và phép kiểm

Owner mệnh đề: `quality/invariants.md` I-033. Tầng và tập phải rỗng:
`docs/product/1-system-design/03-bao-ve-invariant.md` §5; yêu cầu:
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, YC-38.
Test viết trước của Claude: `db/tests/i033_account_session_and_reset.sql`.

| Vế | Cái giữ và phép đối chiếu |
|---|---|
| Hình trạng thái, người, vai, quyết định | tầng 1: CHECK, FK và UNIQUE; `I-033/1` |
| Tên đăng nhập và email | tầng 1: CHECK chuẩn hoá, UNIQUE; `I-033/7` |
| Mật khẩu chỉ thêm, băm, dấu người đặt | tầng 1: CHECK tiền tố và cờ, FK, không quyền sửa/xoá; bản hiện hành sai băm `I-033/4`, dấu bản `I-033/8`, hoạt động thiếu bản `I-033/6` |
| Mở phiên khi hoạt động | tầng 1: trigger có tên `login_session_active_account_check`; khoá dòng tài khoản khi xét. `I-033/2` tìm phiên chưa kết thúc, chưa hết hạn của tài khoản không hoạt động |
| Phiên gắn đúng người trực quầy | tầng 1: trigger `login_session_duty_person_check`, FK và UNIQUE; `I-033/3` |
| Băm và hạn, kết thúc có lý do | tầng 1: CHECK; `I-033/9` và `I-033/10` |
| Phiên kết thúc không sửa, mã dùng không dùng lại | tầng 1: trigger `login_session_ended_immutable_check`, `password_reset_used_once_check`; `I-033/11` và `I-033/12` đọc vết có bản trước đã kết thúc/đã dùng |
| Vai owner đúng người có cờ chủ quán | cửa khởi tạo theo ADR-109; đối chiếu `I-033/5`, đọc cờ hiện hành |
| Khoá kết thúc mọi phiên trong cùng giao dịch | tầng 2 ở cửa backend, chưa dựng ở lát này; phép `I-033/2` bắt trạng thái còn sót |
| Số lần sai và số thư một giờ | tầng 3 ở backend; không có cột cho hai bộ đếm |
| Cập nhật có vết, không xoá | cả bốn bảng mang trigger chung QD-52, không cấp DELETE theo QD-50; câu chung `I-018/1` |

Ba trigger nghiệp vụ: một xét tài khoản và người trực; một chặn mọi UPDATE lên phiên đã kết thúc;
một chặn mọi UPDATE lên mã đã dùng. Tên từ chối ánh xạ `unreviewed` trong hợp đồng 0.22.0,
khoá chính là `internal`; chưa có cửa để xét mã công khai.

Vai ứng dụng chỉ sửa năm cột quyết định của tài khoản, hai cột kết thúc phiên, và lúc dùng mã.
Không sửa tên đăng nhập, email, hạn phiên hay bản mật khẩu. Quyền SELECT/INSERT theo mặc định QC-03.
Bốn trigger vết vẫn chụp sửa tay của chủ lược đồ; các trigger nghiệp vụ có tên không thay trigger vết.

## 3. Chạy và giới hạn

`db/reconcile/i033.sql` có mỗi câu một lỗi cài `db/reconcile/proof/i033_<số>.sql`.
Lỗi tự dựng tài khoản và mật khẩu hợp lệ trước khi phá riêng vế cần kiểm; không chờ dữ liệu ngày quản trị.
`db/scenario/yc.sql` có dòng đọc YC-38 (duyệt, bản mật khẩu, phiên và mã đã dùng) và dòng sai (mở lại phiên).
[09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md) ánh xạ các câu.

Đường lùi [07-thu-tu-migration.md](07-thu-tu-migration.md) khoá chặn nếu bất kỳ bảng nào có dòng;
gỡ mã đặt lại và phiên trước, mật khẩu rồi tài khoản, sau cùng hàm trigger. Không gỡ dữ liệu đã ghi.
Lát không thêm ngoại lệ bảng kỹ thuật hay bảng nhiều cột tiền.

Không tự suy ra người bấm hộ trên máy đang mở; không chứng minh băm là mật khẩu mạnh.
Lịch sử đã bị xoá ngoài quyền ứng dụng không còn tập để đối chiếu; kiểm bằng quyền và test giữ bản.
Đối chiếu vết sửa chỉ phát hiện lần sửa có vết; giới hạn chung I-018 vẫn áp dụng.
Backend còn phải xét ai được duyệt, khởi tạo owner, đổi mật khẩu và kết thúc mọi phiên trong cùng giao dịch,
đăng nhập quầy gọi logic vào quầy, cookie và giới hạn gửi thư theo ADR-109.
