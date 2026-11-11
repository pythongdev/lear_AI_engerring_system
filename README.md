# Lean AI Engineering System

A lightweight AI-assisted development operating system inspired by the strongest ideas in `llm_study`, while reducing ceremony.

## Core principles

1. One fact, one owner.
2. One task, one outcome.
3. Every meaningful change has acceptance criteria.
4. Every meaningful change is verified.
5. AI never invents business truth.
6. Ceremony follows risk.

## Structure

```text
.claude/                 (cấu hình Claude Code)
  settings.json          (hook phiên và gate)
AGENTS.md                (lối vào Codex)
CLAUDE.md                (quy tắc chung và bảng owner)
README.md                (mức rủi ro và triết lý repo)
Makefile                 (lệnh phát triển)
compose.yaml             (dịch vụ chạy tại máy)
be/                      (mã backend)
db/                      (dữ liệu và phép kiểm database)
  migrations/            (schema có hiệu lực)
docs/                    (tài liệu hệ thống)
  decisions.md           (quyết định kiến trúc)
  product.md             (bản lưu trước khi tách)
  prompt-guideline.md    (cách viết phiếu việc)
  product/               (quy tắc sản phẩm)
    00-index.md          (chỉ mục owner sản phẩm)
    1-system-design/     (thiết kế hệ thống)
      architecture.md    (kiến trúc)
    2-db/                (quy ước và lược đồ dữ liệu)
    3-be/                (hợp đồng backend)
      openapi.yaml       (hợp đồng API)
    4-fe/                (route và component)
      01-khung-fe.md     (khung giao diện)
    99-unknowns.md       (câu hỏi nghiệp vụ đang mở)
fe/                      (mã giao diện)
master_plan/             (kế hoạch các pha)
  shop-facts.md          (dữ kiện của quán)
prompt/                  (bộ prompt)
  BA/                    (prompt phân tích nghiệp vụ)
  maintenance/           (prompt bảo trì)
quality/                 (bất biến và thước review)
  invariants.md          (bất biến nghiệp vụ)
  review-gate.md         (thước review)
scripts/                 (gate và phép kiểm)
  brief.sh               (trạng thái phiên hiện tại)
  gate.sh                (cổng kiểm chung)
  verify.sh              (kiểm code và test)
tools/                   (công cụ hỗ trợ)
work/                    (task và finding)
  backlog.md             (trạng thái task)
  findings.md            (vấn đề và bài học)
  scope/                 (scope từng task, git bỏ qua)
```

## Risk-based ceremony

### Level 0 — Trivial
Formatting, typo, mechanical rename.

Change → verify → done.

### Level 1 — Small
Small bug fix or isolated feature.

Task + acceptance + verification.

### Level 2 — Significant
New API, database change, or business behavior.

Task + acceptance + invariants + verification. Add a decision when needed.

### Level 3 — Architectural
New subsystem, major architecture, authentication, payment, or risky migration.

Design + decision + task breakdown + invariants + verification + review.

## Context loading

Claude Code reads `CLAUDE.md`; Codex enters through `AGENTS.md` and reads the same
shared rules. `scripts/brief.sh` provides current task state and open items.
Claude receives it through the configured `SessionStart` hook; Codex runs
`./scripts/brief.sh` directly. Load only sources relevant to the task.

After changes, run `./scripts/gate.sh`. Claude also has a Stop hook. Direct runs
do not check the report's commit block (Gate 7/7b); follow `CLAUDE.md` §6.1.
For switching tools, independent review and worktree ownership, see §7.4 there.

Do not read the entire repository by default.

The brief points at owners; it never copies a fact out of one. See `CLAUDE.md` §7.

## Findings

A finding is not a bug diary. Record only problems or lessons with future value.

## Evolution

Do not add framework rules preemptively. Add automation or documentation when the project encounters a real recurring problem.