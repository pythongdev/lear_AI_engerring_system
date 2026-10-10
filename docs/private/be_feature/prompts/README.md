# Prompt chuyển stack backend theo cấu trúc kết hợp

Đây là bộ lời gọi cho phiên Claude bắt đầu nguội. Quyết định chủ repo duyệt 2026-10-10 nằm trong
[kế hoạch](../be-stack-migration-steps.md); owner ADR/QC được cập nhật ở bước 01. Không dùng tài liệu
mẫu hoặc đề xuất lát 0 để mở lại thiết kế đã chốt.

## Bắt đầu một phiên

Đọc AGENTS.md, CLAUDE.md, chạy `./scripts/brief.sh`; đọc task và bàn giao liên quan, nhánh và
`git status --short`. Kiểm bước trước đã **Done trong work/backlog.md**, kể cả mọi miền của nhóm;
bước 00 kiểm các task đang viết backend đã dừng/đóng. Sau đó mở prompt tương ứng dưới đây.
Done chưa commit không có trong worktree tạo từ HEAD: Claude phải xử lý base trước giao Codex.
Mỗi lượt chỉ một task; không chạy nhóm miền như một task lớn.

## Thứ tự, mức và người làm

| Bước | Prompt | Mức | Người làm |
|---|---|---|---|
| 00 | [Điều kiện trước](BE-STACK-00-dieu-kien-truoc-L2.md) | L2 | Claude |
| 01 | [Ghi quyết định](BE-STACK-01-ghi-quyet-dinh-L3.md) | L3 | Claude |
| 02 | [Công cụ và gate](BE-STACK-02-cong-cu-va-gate-L2.md) | L2 | Codex làm, Claude duyệt |
| 03 | [Nền](BE-STACK-03-nen-L2.md) | L2 | Codex làm, Claude duyệt |
| 04 | [Miền mẫu menu](BE-STACK-04-mien-menu-L2.md) | L2 | Codex làm, Claude duyệt |
| 05 | [Các miền nhỏ](BE-STACK-05-mien-nho-L2.md) | L1–L2; mẫu L2, chấm từng miền | Codex làm, Claude duyệt |
| 06 | [Đường tiền](BE-STACK-06-duong-tien-L2.md) | L2 | Codex làm, Claude duyệt |
| 07 | [sanxuat rồi don](BE-STACK-07-sanxuat-va-don-L2.md) | L2 | Codex làm, Claude duyệt |
| 08 | [Dọn](BE-STACK-08-don-dep-L1.md) | L1 | Codex làm, Claude duyệt |
| 09 | [Rà chéo](BE-STACK-09-ra-cheo-L1.md) | L1 | Claude |

Bước 05 lặp cho qr → gia → ngayban → ban → phien → vongdoi, mỗi miền một task.
Bước 06 lặp cho tratruoc → hoadon → ket, mỗi miền một task. Bước 07 chạy hai task sanxuat rồi don.
Mỗi lượt thay `<MIEN>` bằng đúng một miền, điền `<MÃ>` từ backlog và mức đã chấm; không để placeholder
trong phiếu thực gửi. Bước 00, 01, 09 Claude tự làm, không có phiếu Codex.

## Quy ước tên và giao việc

Tên file là `BE-STACK-<NN>-<tên-ngắn>-L<mức>.md`, NN hai chữ số từ 00 đến 09.
Mức trong tên là mức mẫu; riêng nhóm 05 Claude chấm L1 hoặc L2 theo từng task và ghi một mức duy nhất
trong phiếu. Không tạo bản nhớ theo công cụ; trạng thái và bàn giao nằm trong entry backlog hiện có.
Lấy số task bằng `grep -o 'T-[0-9]*' work/backlog.md | sort -Vu | tail -1`, kiểm rồi dùng số kế tiếp.
Số ADR kế tiếp tra bằng `grep -o 'ADR-[0-9]*' docs/decisions.md | sort -u | tail -1`, không ghi cứng.

Mỗi prompt có sáu khối Context/Goal/Scope/Constraints/Acceptance/Verify, Unknowns, Report và quy trình
Claude làm. Bước có Codex kèm mẫu phiếu §6.1; Claude điền từ các khối trong chính file để phiếu tự đủ.
Dùng `codex exec -m gpt-6-astra`; model gpt-6.1-sol trong cấu hình hiện tại không dùng được với tài khoản.
Claude chạy PostgreSQL thật, cài lỗi và duyệt; Codex không có Docker, không tự commit hay sửa owner.

## Điểm đã chốt khi viết bộ prompt (Claude, 2026-10-10)

Bốn chỗ Codex nêu lúc viết bộ prompt đã được Claude chốt; prompt tương ứng đã ghi lại.
apierr không import Gin: API ghi lỗi giữ `http.ResponseWriter`, handler truyền `c.Writer` (bước 03).
Luật annotation của Gate 1f chỉ áp cho miền có mục trong `be/sqlc.yaml`, miền chưa chuyển giữ luật cũ,
tới bước 08 thì mọi miền đều có mục (bước 02). `scripts/be-check.sh` có `BE_CHECK_KEEP_DB=1` để giữ
database khi đỏ, phục vụ điều tra test chập chờn (bước 00). Nếu task đăng nhập (T-143) sinh một miền mới
trước bước 08, miền ấy thành thêm một task của bước 05, cùng khuôn; Codex gặp thì báo, không tự làm.
