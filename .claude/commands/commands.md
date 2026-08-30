---
description: Liệt kê mọi lệnh chạy được trong repo (scripts + hook) để đối chiếu
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*)
---

# Lệnh của hệ thống

File script thực tế đang có trong `scripts/`:

!`ls -1 scripts/*.sh 2>/dev/null || echo "(không có scripts/*.sh)"`

Hook đang khai báo trong `.claude/settings.json`:

!`grep -o '"command": "[^"]*"' .claude/settings.json 2>/dev/null || echo "(không có settings.json)"`

## Việc của bạn

In ra nguyên văn bảng dưới đây cho người dùng, rồi đối chiếu với hai kết quả ở
trên. Nếu có script trong `scripts/` mà bảng không nhắc tới, hoặc bảng nhắc tới
một script không còn tồn tại, nói rõ chỗ lệch đó ra — đừng im lặng in bảng cũ.

| Lệnh | Làm gì | Khi nào chạy |
|---|---|---|
| `./scripts/brief.sh` | In trạng thái sống của hệ thống: task In Progress, scope đang khai, task Ready kế tiếp, finding/unknown còn Open, ADR mới nhất, commit gần đây, ngày sửa cuối của từng file owner (CLAUDE.md §2), việc chưa commit. Chỉ **trỏ**, không bao giờ chép lại dữ kiện nghiệp vụ. Không bao giờ chặn: mọi nhánh lỗi đều exit 0. | Tự chạy ở `SessionStart` (khởi động, `/clear`, resume, compaction). Chạy tay khi nghi trạng thái đã đổi dưới chân mình. |
| `./scripts/gate.sh` | Cổng chất lượng. Chạy Gate 3 (`check-scope.sh`) rồi Gate 1 (`verify.sh`). Bỏ qua `verify.sh` khi thay đổi chỉ chạm tài liệu (`docs/`, `work/`, `quality/`, `*.md`). Lỗi → in báo cáo ra stderr, exit 2. | Sau **mỗi** thay đổi (CLAUDE.md §5). Cũng dùng được trong CI. |
| `./scripts/gate.sh --hook` | Cùng một cổng, ở chế độ hook: đọc JSON hook từ stdin và thoát sớm nếu `stop_hook_active: true` để không chặn lại một lượt đã đang tiếp tục. | Tự chạy ở `Stop` hook. Không gọi tay. |
| `./scripts/check-scope.sh` | Gate 3 — so mọi file đang đổi trong cây làm việc với pattern trong `work/scope.txt`. File **git đang theo dõi** nằm ngoài scope → FAIL. File chưa track nằm ngoài scope → chỉ in dòng `note:`, exit 0 (ADR-003). Không có `work/scope.txt`, hoặc file không có pattern nào → coi như chưa khai scope, bỏ qua. | `gate.sh` gọi. Chạy tay khi muốn kiểm scope mà chưa muốn chạy build/test. |
| `SCOPE_FILE=<path> ./scripts/check-scope.sh` | Như trên nhưng đọc scope từ file khác. Mặc định là `work/scope.txt`. | Thử một bộ pattern trước khi ghi đè `work/scope.txt`. |
| `./scripts/verify.sh` | Gate 1 — Go: `gofmt -l` phải rỗng, `go build ./...`, `go test ./...` (khi có `go.mod`). Node: `npm test` / `lint` / `build` với `--if-present` (khi có `package.json`). Repo hiện chưa có `go.mod` lẫn `package.json`, nên nó chỉ in `Verification passed.`. | `gate.sh` gọi khi có thay đổi ngoài tài liệu. |

Bảng này chỉ nói về lệnh. Quy tắc làm việc, mức rủi ro L0–L3, và Definition of
Done nằm ở `CLAUDE.md`; các cổng review còn lại nằm ở `quality/review-gate.md`.
