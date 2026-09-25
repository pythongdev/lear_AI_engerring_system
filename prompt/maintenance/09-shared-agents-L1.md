# T-088 — Claude Code và Codex dùng chung quy trình (L1)

Ngày 2026-09-25, chủ repo yêu cầu triển khai đề xuất tích hợp tối thiểu.

## Context

Đọc `CLAUDE.md`, `.claude/settings.json`, `scripts/gate.sh` và `quality/review-gate.md`.

## Goal

Hai công cụ nhận cùng luật, có cách lấy trạng thái hiện tại và bàn giao có bằng chứng.

## Scope

`AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/decisions.md`,
`docs/prompt-guideline.md`, `docs/project_work_flow/README.md`,
`quality/review-gate.md`, `scripts/brief.sh`, `scripts/check-links.sh`,
`scripts/check-links.test.sh`, `work/backlog.md`, `work/scope.txt` và file prompt này.

Ngoài phạm vi: nghiệp vụ, task Ready khác, cấu hình hook Claude, lõi Gate 7 và tự động hoá Codex.

## Acceptance

- AGENTS.md trỏ tới CLAUDE.md, không sao chép bộ luật; chỉ rõ brief, gate và giới hạn Gate 7.
- Tài liệu hiện hành phân biệt hook Claude và thao tác trực tiếp của Codex.
- Luật phối hợp có một người sửa trên mỗi worktree, review độc lập và bàn giao vào entry hiện có.
- Gate link phát hiện đường chết trong AGENTS.md đã track; giữ quy tắc note cho file chưa track.
- Lấy danh sách commit bao gồm file mới; không gom file có sẵn của người dùng.

## Verify

- `./scripts/gate.sh`: chạy toàn bộ test shell vì có thay đổi script.
- `./scripts/brief.sh`: hiển thị điểm vào cho cả Claude Code và Codex.
- Đọc diff đối chiếu Acceptance; kiểm tra AGENTS.md và các đường dẫn của nó trực tiếp khi chưa track.
- `git diff --check`.

## Report

Kết quả, output kiểm tra, giới hạn chưa tự động hoá và khối commit.
