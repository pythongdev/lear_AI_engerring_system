> **ĐỀ XUẤT — CHƯA ÁP DỤNG. KHÔNG PHẢI SỰ THẬT CỦA REPO NÀY.**
>
> - **Là gì:** bản tư vấn "blueprint v2" cho chính hệ thống engineering, do một cố vấn ngoài
>   viết. Nó nói repo *nên* trông thế nào, không nói repo *đang* thế nào.
> - **Vào repo ngày:** 2026-08-30, bị commit nhầm trong `0b3a337` — commit đó mang subject của
>   T-020 nhưng nội dung là ba file `docs/` chưa track (`work/findings.md` **F-009**).
> - **Chuyển ra khỏi `docs/` ngày:** 2026-08-31 (T-023, quyết định của chủ repo). `docs/` chỉ
>   chứa owner của CLAUDE.md §2; file này không sở hữu fact nào. Thân bài giữ **nguyên văn**,
>   không chiết, không sửa một dòng.
> - **Trái CLAUDE.md §2 ở hai chỗ — §2 thắng:**
>   - §1 và §5 đề xuất `docs/facts/{scope,domain,business-rules}.md` làm nhà của dữ kiện nghiệp
>     vụ. **Không đúng ở repo này:** nhà duy nhất là `master_plan/shop-facts.md` (ADR-001).
>   - §10 đề xuất `work/tasks/<task-XXX>.md`, mỗi task một file. **Không đúng ở repo này:** task
>     sống trong `work/backlog.md`, prompt sống trong `prompt/`.
> - **Phần lớn phần còn lại đã được làm rồi**, không cần đọc lại như việc phải làm: L0–L3
>   (`README.md`), vòng findings (`work/findings.md`), luật "do not overbuild" (CLAUDE.md §3.8),
>   invariants (`quality/invariants.md`), `scripts/verify.sh`.
> - **Đường dẫn bên trong file này phần lớn không mở được** — chúng mô tả cấu trúc đề xuất, không
>   phải cấu trúc thật. Đó là lý do file nằm dưới `work/`, nơi Gate 1b không chấm link
>   (CLAUDE.md §5).
>
> Muốn dùng ý nào trong đây thì mở một task trong `work/backlog.md` cho ý đó, đừng sửa repo theo
> file này.

---

Đúng. Nếu mục tiêu của bạn là biến repo hiện tại thành một **Lean AI Engineering System thực sự dùng được cho nhiều dự án**, mình khuyên **không xây thêm nhiều agent**, mà nâng cấp theo hướng:

> **Canonical Facts → Risk-based Workflow → Implementation → Deterministic Verification**

Dưới đây là cấu trúc tổng quan mình đề xuất. Đây nên được xem như **blueprint v2** để bạn phát triển dần, không phải tất cả đều phải tạo ngay.

---

# 1. Cấu trúc tổng quan đề xuất

```text
project/
│
├── CLAUDE.md
│
├── docs/
│   ├── product.md
│   ├── architecture.md
│   ├── decisions.md
│   │
│   └── facts/
│       ├── scope.md
│       ├── domain.md
│       ├── business-rules.md
│       └── ...
│
├── work/
│   ├── backlog.md
│   ├── findings.md
│   │
│   └── tasks/
│       ├── <task-001>.md
│       ├── <task-002>.md
│       └── ...
│
├── quality/
│   ├── invariants.md
│   └── ...
│
├── scripts/
│   ├── verify.sh
│   └── ...
│
└── [source code]
```

Nhưng điểm quan trọng không phải là folder.

Điểm quan trọng là **mỗi folder có một trách nhiệm duy nhất**.

---

# 2. Kiến trúc tư duy

Tôi đề xuất hệ thống có 6 layer:

```text
┌──────────────────────────────────────────┐
│              HUMAN INTENT                │
│          User request / requirement      │
└────────────────────┬─────────────────────┘
                     ↓
┌──────────────────────────────────────────┐
│             CANONICAL TRUTH              │
│   Product / Scope / Domain / Business    │
└────────────────────┬─────────────────────┘
                     ↓
┌──────────────────────────────────────────┐
│              WORK CONTROL                │
│       Backlog / Task / Acceptance        │
└────────────────────┬─────────────────────┘
                     ↓
┌──────────────────────────────────────────┐
│             ENGINEERING                 │
│      Architecture / Decisions / Code     │
└────────────────────┬─────────────────────┘
                     ↓
┌──────────────────────────────────────────┐
│               QUALITY                    │
│     Invariants / Tests / Verification    │
└────────────────────┬─────────────────────┘
                     ↓
┌──────────────────────────────────────────┐
│                FEEDBACK                  │
│          Findings / Lessons / Rules      │
└────────────────────┴─────────────────────┘
```

Đây mới là **AI Engineering Operating System**.

---

# 3. `CLAUDE.md` — Identity & Navigation

### Đã có → giữ nguyên

```text
CLAUDE.md
```

### Vai trò

Đây **không phải nơi chứa knowledge**.

Nó chỉ là:

```text
WHO
WHERE
HOW
DONE
```

Ví dụ:

```text
You are the engineering agent for this repository.

Truth lives in:
  docs/facts/
  docs/product.md
  docs/architecture.md
  docs/decisions.md

Work lives in:
  work/

Quality rules live in:
  quality/

Before changing code:
  classify task L0-L3

Never invent business facts.

Every change must pass appropriate verification.
```

### Guideline

**Không quá ~120 dòng.**

Nếu một rule có thể nằm ở file khác:

> Không đưa rule đó vào CLAUDE.md.

---

# 4. `docs/` — Knowledge Layer

Đây là layer **AI đọc để hiểu project**.

```text
docs/
├── product.md
├── architecture.md
├── decisions.md
└── facts/
```

---

## 4.1 `product.md`

### Owner

Product definition.

### Chứa

```text
Product purpose
Target users
Core capabilities
Product boundaries
High-level behavior
```

### Không chứa

```text
database schema
API implementation
specific prices
temporary tasks
bugs
```

Nguyên tắc:

> Product describes **what the product is**, not how the code works.

---

# 5. `docs/facts/` — phần tôi khuyên thêm

Đây là nâng cấp quan trọng nhất.

```text
docs/
└── facts/
    ├── scope.md
    ├── domain.md
    ├── business-rules.md
    └── ...
```

Mục tiêu:

> **AI không được tự suy đoán business truth.**

Ví dụ restaurant:

```text
facts/
├── selling-scope.md
├── pricing.md
├── menu.md
├── ordering.md
└── fulfillment.md
```

---

## Guideline cho Fact

Mỗi file phải có:

```text
# Identity

What fact does this file own?

# Rules

...

# Examples

...

# Constraints

...

# Source

Where did this fact come from?
```

Quan trọng nhất:

> **Một fact chỉ có một canonical owner.**

Ví dụ:

```text
pricing.md
```

là nơi duy nhất quyết định giá.

Không được copy giá vào:

```text
product.md
README.md
CLAUDE.md
API.md
```

Các file khác chỉ **reference** nó.

---

# 6. `architecture.md`

### Đã có → giữ

Owner của:

```text
system structure
components
dependencies
data flow
technical boundaries
```

Ví dụ:

```text
Frontend
   ↓
API
   ↓
Service
   ↓
Repository
   ↓
MySQL
```

Không chứa:

```text
current bugs
task list
business prices
implementation TODO
```

---

# 7. `decisions.md`

### Đã có → giữ

Đây là **Decision Log**.

Mỗi decision:

```text
## D-001 — Redis is not source of truth

Status: Accepted
Date: 2026-08-30

Context:
...

Decision:
...

Reason:
...

Consequences:
...
```

Rule:

> Decision giải thích **why**, architecture giải thích **what/how**.

---

# 8. `work/` — Execution Layer

```text
work/
├── backlog.md
├── findings.md
└── tasks/
```

Đây là layer AI **đang làm gì**.

---

# 9. `backlog.md`

### Đã có → giữ

Nhưng nên xem nó là:

> **Index của work**, không phải toàn bộ work database.

Ví dụ:

```text
# Backlog

## Ready

- [ ] T-001 Customer menu
- [ ] T-002 Create order

## In Progress

- [ ] T-003 Pricing

## Done

- [x] T-000 Project bootstrap
```

Chi tiết nằm ở:

```text
work/tasks/
```

---

# 10. `work/tasks/` — phần nên thêm

Đây là một trong những thay đổi quan trọng nhất.

```text
work/tasks/
```

Không phải task nào cũng cần file.

### L0

```text
edit
→ verify
```

Không cần task file.

### L1+

Có thể có:

```text
work/tasks/T-003-pricing.md
```

Template:

```text
# T-003 — Pricing

## Level

L2

## Context

Why this task exists.

## Goal

What must become true.

## Scope

### In

...

### Out

...

## References

- docs/facts/pricing.md
- docs/architecture.md

## Acceptance

- [ ] ...
- [ ] ...

## Verification

- [ ] ...
- [ ] ...

## Status

Ready
```

---

# 11. `quality/` — Quality Layer

Đã có:

```text
quality/invariants.md
```

Tôi khuyên giữ rất lean:

```text
quality/
├── invariants.md
└── ...
```

---

# 12. `invariants.md`

Đây là:

> **những điều không được phép sai.**

Ví dụ:

```text
INV-001

Order total must equal the sum of order items.

INV-002

Paid orders cannot transition back to pending.

INV-003

Redis is never a source of truth.

INV-004

Deleted products must not appear in customer-facing queries.
```

Mỗi invariant nên có:

```text
ID
Statement
Reason
Scope
Verification
```

Ví dụ:

```text
## INV-001

Statement:
Order total equals sum(order_items).

Reason:
Prevents financial inconsistency.

Verification:
Test: order_total_test
```

Đây là nơi AI có thể biết:

> "Tôi được phép thay implementation, nhưng không được phá invariant."

---

# 13. `scripts/verify.sh`

### Đã có → giữ và phát triển

Đây là **gatekeeper**.

```text
change
   ↓
verify.sh
   ↓
PASS / FAIL
```

Không để AI tự tuyên bố:

```text
"Implementation completed successfully."
```

Thay vào đó:

```text
Implementation
      ↓
Verification
      ↓
Evidence
      ↓
Done
```

---

# 14. Tôi khuyên phát triển `verify.sh` thành nhiều level

Ví dụ:

```text
./scripts/verify.sh
```

hoặc:

```text
./scripts/verify.sh L0
./scripts/verify.sh L1
./scripts/verify.sh L2
./scripts/verify.sh L3
```

Nhưng **không nhất thiết phải làm ngay**.

Concept:

```text
L0
→ syntax / formatting

L1
→ unit tests / targeted checks

L2
→ integration / contract / invariant checks

L3
→ full verification / architecture checks
```

Điều này giúp ceremony tương ứng với risk.

---

# 15. `findings.md` — Feedback Layer

Đã có → giữ.

Nhưng định nghĩa rất rõ:

> Finding chỉ được ghi khi nó tạo ra knowledge có giá trị tương lai.

Không:

```text
2026-08-30
AI forgot to run tests.
```

Mà:

```text
## F-007 — Verification was skipped after schema change

Observation:
...

Root cause:
...

Lesson:
Schema changes require migration verification.

Action:
Add migration check to L2 verification.
```

Quan trọng:

```text
Finding
   ↓
Recurring?
   ↓
YES
   ↓
Change system
```

Nếu lỗi chỉ xảy ra một lần:

> Không cần tạo framework rule.

---

# 16. L0–L3 nên trở thành "control system"

Tôi khuyên định nghĩa chính thức như sau:

| Level | Risk    | Process                                                  |
| ----- | ------- | -------------------------------------------------------- |
| L0    | trivial | Change → Verify                                          |
| L1    | low     | Task → Implement → Verify                                |
| L2    | medium  | Context → Goal → Scope → Acceptance → Implement → Verify |
| L3    | high    | Design → Decision → Task → Implement → Verify → Review   |

---

# 17. Prompt cũng nên tuân theo level

Đây là phần rất quan trọng với hệ thống bạn đang xây.

### L0

```text
Context
Goal
Verify
```

### L1

```text
Context
Goal
Scope
Constraints
Verify
```

### L2

```text
Context
Goal
Scope
Constraints
Acceptance
Verify
```

### L3

```text
Context
Goal
Scope
Constraints
Architecture
Decision
Acceptance
Verify
Review
```

Như vậy prompt không phải là một template cố định cho mọi task.

---

# 18. Workflow hoàn chỉnh

Sau khi nâng cấp, AI session sẽ hoạt động như sau:

```text
USER REQUEST
     │
     ▼
CLASSIFY L0-L3
     │
     ▼
LOAD ONLY RELEVANT FACTS
     │
     ▼
CHECK EXISTING DECISIONS
     │
     ▼
CREATE/UPDATE TASK
     │
     ▼
IMPLEMENT
     │
     ▼
RUN VERIFICATION
     │
     ├── FAIL → FIX
     │
     ▼
PASS
     │
     ▼
UPDATE WORK STATE
     │
     ▼
DONE
```

Và khi phát hiện vấn đề:

```text
Problem
   ↓
Finding
   ↓
Recurring?
   ├── No → record lesson
   │
   └── Yes
        ↓
   Improve system
        ↓
   rule / invariant / verify / docs
```

Đây chính là vòng lặp làm cho system **tự cải thiện theo thời gian**.

---

# 19. Nguyên tắc cực kỳ quan trọng: "Do not overbuild"

Tôi đề xuất bạn đặt một rule ngay trong system:

```text
The engineering system must evolve from real problems.

Do not add:
- agents
- documents
- ceremonies
- scripts
- rules
- abstractions

unless a real recurring problem justifies them.
```

Nói cách khác:

```text
Problem
   ↓
Evidence
   ↓
Rule
   ↓
Automation
```

Không:

```text
Idea
 ↓
Framework
 ↓
20 files
 ↓
Không ai dùng
```

---

# 20. Roadmap phát triển

Tôi sẽ **không làm tất cả cùng lúc**.

### Phase 1 — Foundation

Giữ:

```text
CLAUDE.md
docs/
work/
quality/
scripts/
```

và chuẩn hóa ownership.

### Phase 2 — Canonical Facts

Thêm:

```text
docs/facts/
```

Đây là ưu tiên cao nhất.

### Phase 3 — Task system

Thêm:

```text
work/tasks/
```

và L0–L3.

### Phase 4 — Verification

Phát triển:

```text
scripts/verify.sh
```

thành các gate theo risk.

### Phase 5 — Feedback loop

Chuẩn hóa:

```text
findings.md
```

→ recurring problem → system improvement.

### Phase 6 — Automation

**Chỉ khi có evidence** mới thêm:

```text
hooks
CI gates
agent skills
automated context loading
task automation
```

---

# 21. Kiến trúc cuối cùng tôi khuyên bạn theo đuổi

```text
                         HUMAN
                           │
                           ▼
                       REQUEST
                           │
                           ▼
                     ┌───────────┐
                     │  L0–L3    │
                     │  RISK     │
                     └─────┬─────┘
                           │
                           ▼
              ┌────────────────────────┐
              │    CANONICAL TRUTH     │
              │                        │
              │ product                │
              │ architecture           │
              │ facts                  │
              │ decisions              │
              └───────────┬────────────┘
                          │
                          ▼
              ┌────────────────────────┐
              │       WORK             │
              │                        │
              │ backlog                │
              │ tasks                  │
              │ acceptance             │
              └───────────┬────────────┘
                          │
                          ▼
                     IMPLEMENT
                          │
                          ▼
              ┌────────────────────────┐
              │       QUALITY          │
              │                        │
              │ invariants             │
              │ tests                  │
              │ verification           │
              └───────────┬────────────┘
                          │
                    ┌─────┴─────┐
                    │           │
                   FAIL        PASS
                    │           │
                    ▼           ▼
                   FIX         DONE
                                │
                                ▼
                          FINDINGS
                                │
                                ▼
                       SYSTEM IMPROVEMENT
```

## Quan điểm quan trọng nhất

Tôi nghĩ **đừng biến hệ thống này thành "AI framework"**.

Hãy biến nó thành:

> **một hệ thống quản lý sự thật, rủi ro, công việc và bằng chứng.**

AI chỉ là **worker**.

```text
Human
  ↓
Intent

Canonical docs
  ↓
Truth

L0-L3
  ↓
Risk

Task
  ↓
Work

AI
  ↓
Implementation

Verify
  ↓
Evidence

Finding
  ↓
Learning
```

Nếu làm được như vậy, hệ thống này có thể dùng chung cho **restaurant, e-commerce, SaaS, internal tool...** mà không phụ thuộc vào Claude/Codex/Gemini hay một model cụ thể.

Và đặc biệt, nó giải quyết đúng vấn đề bạn từng lo: **"report quá nặng nhưng vẫn cần kiểm soát và báo cáo được."** Với kiến trúc này, **L0 gần như không có report, L1 rất nhẹ, L2 đủ evidence, L3 mới có full traceability**. Đây là hướng mình khuyên bạn phát triển.
