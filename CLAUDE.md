# Lean AI Engineering System

## 1. Overview

**Product:** hệ thống bán hàng + quản trị cho một quán ăn duy nhất — bán tại
quầy, giao hàng, mang đi, đặt trước qua điện thoại — qua năm kênh bán, phục vụ
cả luồng bán hàng và ba mảng quản trị (nguyên liệu, con người, tài chính). Dữ
kiện đầy đủ: `master_plan/shop-facts.md`.

This repository is an AI-assisted development operating system: a small set of
canonical documents, a task backlog, and shell gates that make every change
verifiable. This file owns the shared rules for Claude Code and Codex (Codex
enters through `AGENTS.md`, which points here). Read it every session. It holds
**rules and pointers only**: where facts live, how to work, what "done" means.
How a gate works lives in that script's header comment; why a rule exists lives
in its ADR in `docs/decisions.md` (ADR-064). This file loads into every session,
so every extra line is fixed tax.

**Ngôn ngữ trả lời** (2026-09-27, chủ repo, T-105): người dùng dùng tiếng Việt.
**Mọi điều** Claude Code hay Codex truyền đạt cho người dùng — câu trả lời, cập
nhật giữa chừng, câu hỏi cần người dùng quyết, báo cáo cuối task và cuối phiên
(§7.3, §8), báo cáo Codex gửi lại sau một phiếu việc (§7.4), ghi chú bàn giao
người dùng sẽ đọc — viết bằng tiếng Việt, dạng văn xuôi dễ hiểu: câu hoàn
chỉnh, nối nhau bằng lý do và hệ quả (đã làm gì, vì sao, còn gì chưa xong,
người dùng cần làm gì tiếp), không phải chuỗi gạch đầu dòng cụt, bảng, hay mã
định danh đứng trơ. Chỉ dùng danh sách khi nội dung thật sự là danh sách (ví
dụ các bước theo thứ tự). Thứ có dạng bắt buộc riêng giữ dạng ấy — khối commit
(§6.1), lệnh cần chạy, output gate làm bằng chứng, link tới câu hỏi mở (§7.3),
bảng Acceptance → bằng chứng của phiếu việc (`docs/prompt-guideline.md` §6) —
nhưng câu dẫn trước và sau chúng vẫn là văn xuôi, và mỗi mã `U-XXX`, `F-XXX`,
`T-XXX` được nhắc tới phải kèm một câu nói nó là gì. Luật này chỉ áp cho lời
gửi người dùng — không đổi ngôn ngữ hay văn phong của tài liệu, code, tên biến,
hay nội dung nào có owner riêng ở §2.

**Giải thích một vấn đề: ngắn trước, dài khi được hỏi** (2026-09-27, chủ repo):
**vấn đề** → **nguyên nhân** → **mức độ ảnh hưởng** → **context ngắn** (vài
câu, đủ hiểu). Không kể hết chi tiết; người dùng sẽ hỏi thêm. Ngắn vẫn là văn
xuôi, không phải gạch đầu dòng cụt.

Ceremony scales with risk (L0–L3): levels in `README.md`, their cost here in §3,
prompts per level in `docs/prompt-guideline.md`. The repository keeps growing; a
session's memory does not — §7 hands each session the state as it is **today**.

## 2. Source of Truth

One fact, one owner. If two files disagree, the owner below wins and the other
is a bug to fix now.

| Fact | Owner |
|---|---|
| Shared AI working rules and cross-tool handoff | `CLAUDE.md` (Codex entry point: `AGENTS.md`) |
| Business rules, product behavior | `docs/product/` |
| Open business questions (unknowns) | `docs/product/99-unknowns.md` |
| Architecture | `docs/product/1-system-design/architecture.md` |
| Architecture decisions (ADR) | `docs/decisions.md` |
| Business invariants | `quality/invariants.md` |
| Tầng bảo vệ của từng invariant + phép đối chiếu | `docs/product/1-system-design/` — pha 1, sinh ra ở P1-04…P1-06 (ADR-035) |
| Phụ thuộc ngoài của hệ thống + đường suy giảm của từng cái | `docs/product/1-system-design/01-ranh-gioi-he-thong.md` — pha 1, sinh ra ở P1-02 |
| Định nghĩa **một ngày bán** cho phép cộng tiền + mốc tính tiền + nguồn thời gian | `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` — pha 1, sinh ra ở P1-03 |
| Quy ước dữ liệu: tiền, mốc và múi giờ, khoá, đặt tên, trạng thái, không xoá cứng, văn bản và định danh — mỗi quy ước một mã `QD-XX` và một phép kiểm | `docs/product/2-db/01-quy-uoc-du-lieu.md` — pha 2, sinh ra ở P2-03 (ADR-035, ADR-053 luật 3) |
| Schema: tên bảng, tên cột, kiểu, ràng buộc, khoá ngoại | **file migration thắng** — `db/migrations/` (ADR-053 luật 2). Ý định, lý do và ánh xạ `I-0xx`/`YC-xx` của từng lát: `docs/product/2-db/02-luoc-do-ban-hang.md` (P2-04) · `03-luoc-do-menu-gia.md` (P2-05) · `04-luoc-do-duong-tien.md` (P2-06) · `05-luoc-do-san-xuat.md` (P2-07) · `06-luoc-do-nguoi-va-vet.md` (P2-08); các lát sau **thêm** file, không ghi đè. Hai bản lệch ⇒ `F-XXX`. Thứ tự việc, mức và cổng của pha 2: `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` (ADR-049) |
| Quy ước code: DBMS + phiên bản, cách chạy database, migration, khung test, cấu trúc thư mục, stack, tên ràng buộc — mỗi quy ước một mã `QC-XX` và một phép kiểm | `docs/product/2-db/10-quy-uoc-code.md` — pha 2, sinh ra ở P2-12 (ADR-035, ADR-039, ADR-055) |
| Thứ tự migration, đường lùi của từng bước (khoá chặn), cách gỡ một lệnh migration hỏng, dựng lại từ số không | `docs/product/2-db/07-thu-tu-migration.md` — pha 2, sinh ra ở P2-09 (ADR-065) |
| Hợp đồng API: endpoint, quyền theo vai, chữ ký | **chưa có owner** — sinh ra ở **pha 3**, cùng `docs/product/3-be/` (ADR-035) |
| Route, component | **chưa có owner** — sinh ra ở **pha 4**, cùng `docs/product/4-fe/` (ADR-035) |
| Tasks — trạng thái của **mọi** task (`Ready`/`In Progress`/`Done`) | `work/backlog.md` |
| Tasks — mô tả dài của việc **đã xong** (lưu trữ, chỉ thêm, không cập nhật) | `work/backlog_archive.md` (T-086) |
| Tasks — mô tả dài của **pha 1**, `P1-01`…`P1-14` | `work/backlog_SD.md` |
| Tasks — mô tả dài của **pha 2**, `P2-01`…`P2-14` | `work/backlog_DB.md` |
| Tasks — mô tả dài của **mảng admin**, `ADM-01`…`ADM-53` | `work/backlog_AD.md` |
| Câu hỏi cho chủ quán về mảng admin, và chỗ chủ quán trả lời | `work/admin-questions.md` §3 |
| Scope of each task in flight | `work/scope/<ID>.txt` — one file per task, ignored by git (ADR-063) |
| Recurring problems, lessons | `work/findings.md` |
| How to write a prompt/task | `docs/prompt-guideline.md` |
| How to check LLM output | `quality/review-gate.md` |
| Risk levels, repo philosophy | `README.md` |
| Shop facts: scope, channels, prices, flows, business rules | `master_plan/shop-facts.md` |
| Proposals about this system that were **not** adopted | `work/proposals/` |

**Phase ownership boundary** (ADR-035). A row saying *chưa có owner* says so on
purpose: a phase's folder is created with that phase's first line of content,
and the row changes to the real file name **in the same change**. Until a row
has its owner, no document may name what it owns — a phase writing what a later
phase owns is a bug even when every gate is green. The moment the *Schema* and
*Quy ước code* rows changed follows the phase-2 plan's reading (its §5), which
still awaits the repo owner's confirmation. Gate 1d (§5) catches common shapes;
P1-12, P2-14 and human eyes remain the last layer.

Other owners, one line each. Which `docs/product/` file owns which section:
`docs/product/00-index.md` (owns no fact itself). `docs/product.md` is the
pre-split archive — it owns nothing and no session reads a fact from it.
**`master_plan/shop-facts.md` is the single owner of every shop fact** and is
self-contained; `master_plan/00-scope.md` is a redirect stub. The BA prompt set
lives in `prompt/BA/`. `work/proposals/` holds advice that was **not** adopted:
nothing points at it, each file's banner names the rows of this table it
contradicts, and **this table wins**; a proposal taken up becomes a task.

## 3. Working Rules

Ceremony follows risk. Pick the level by what breaks if the change is wrong, not
by the size of the diff (levels: `README.md`). **Most changes are L0 or L1.**

| Obligation | L0 | L1 | L2 | L3 | Enforced by |
|---|:--:|:--:|:--:|:--:|---|
| `./scripts/gate.sh` passes | ✓ | ✓ | ✓ | ✓ | Claude Stop hook; Codex runs directly |
| Entry in `work/backlog.md` | — | ✓ | ✓ | ✓, split into L1/L2 | *self-discipline* |
| `work/scope/<ID>.txt` declared | — | ✓ | ✓ | ✓ | Gate 3 (partial) |
| Acceptance written *before* the change | — | ✓ | ✓ | ✓ | *self-discipline* |
| Regression test for the related invariant | — | — | ✓ | ✓ | Gate 1, if the test exists |
| ADR in `docs/decisions.md` | — | — | if a design choice was made | ✓ | *self-discipline* |
| Design reviewed before any code | — | — | — | ✓ | *self-discipline* |

The last column matters most: a scripted obligation will be reported; a
*self-discipline* one is what gets dropped first when context is full and the
task is long. Re-read that column before starting an L2+ task.

L0 is a real level, not a loophole: a typo, a formatting run, a mechanical rename
is *change → gate → done*. A change is L1+ once it alters behavior, a contract,
or data. Escalate when "what breaks if this is wrong" reaches money, stored
data, or a published contract — not to feel safe.

Then, at every level:

1. **Context** — start from the session brief (§7.1), then load only what the
   task needs: its entry in `work/backlog.md`, the patterns in its scope file,
   the §2 owners it touches, and the code and tests under those patterns. Do not
   read the repository by default.
2. **Focus** — one task at a time, finished before the next is started.
3. **Priority** (L1+) — take the top unchecked item in `work/backlog.md` →
   *Ready* unless the user names another. An Open finding in `work/findings.md`
   that blocks a Ready task is done first. Move the item to *In Progress* when
   you start.
4. **Scope** (L1+) — declare `work/scope/<ID>.txt` (task ID as file name,
   ignored by git — ADR-063) before the first edit, matching the prompt's Scope
   section, and stay inside it. Never edit another task's scope file. One
   pattern per line:

   ```text
   order/          everything under order/
   docs/x.md       exactly this file
   !order/db.go    denied, even if an allow line above matches
   ```

   If the task genuinely needs more, update your scope file and say so. Keep it
   through *Done* (Gate 7b reads it) and delete it once the task is committed.
5. **Never invent business truth** — if a business rule is unclear, stop and ask.
   If you cannot ask, record it and leave the behavior undecided (§4). This rule
   has no L0.
6. **Verify** — run `./scripts/gate.sh` after every change (§5).
7. **Record durable facts** — a rule, decision, or invariant discovered while
   working goes into its §2 owner, in that file's template, in the same change
   that discovered it (how: §7.2).
8. **No ceremony documents** — do not create a `.md` file nobody asked for. Add a
   rule, a hook, or a test only after the same problem has cost you twice
   (`quality/review-gate.md` → *Vòng phản hồi*).

## 4. Handling Unknowns

Never let implementation silently decide an open question. Route it:

| Kind | Where | Format |
|---|---|---|
| Open business question | `docs/product/99-unknowns.md` | one bullet under `### Đang mở`: `U-XXX — question, who can answer, what is blocked` |
| Recurring problem or lesson | `work/findings.md` | `F-XXX` template in that file |
| Choice between viable designs | `docs/decisions.md` | `ADR-XXX` template in that file |

Record only what has future value; a one-off imperfection is not a finding. An
open question is only routed if the brief can find it: `scripts/brief.sh` reads
**one bullet under `### Đang mở` = one open question**, so a question written as
a paragraph or under another heading is never seen. Full shape contract:
`docs/product/99-unknowns.md` → *Cách viết một câu ở đây* (ADR-007, F-008).

## 5. Verification

```bash
./scripts/gate.sh
```

It runs, in order — each script's header is the owner of how it works:

1. `scripts/check-scope.sh` (Gate 3) — every changed **tracked** file must be
   allowed by some scope file. An untracked file outside scope prints a `NOTE`
   and does not fail (ADR-003): if it is a file *your* task created, put it in
   scope or delete it — nothing else will stop you.
2. `scripts/check-links.sh` (Gate 1b) — every path a pointer document names must
   open. Runs on every turn, docs-only included (ADR-005).
3. `scripts/check-doc-status.sh` (Gate 1c) — one ID, two places, two states
   (closed `U-XXX` quoted as open, a valid lifecycle transition denied, a
   `GĐ-XXX` table row disagreeing with its body). Every turn (ADR-032).
4. `scripts/check-phase-boundary.sh` (Gate 1d) — a phase document naming what a
   later phase owns (§2; ADR-035, ADR-039). Every turn; conservative.
5. `scripts/check-schema-names.sh` (Gate 1e) — every table name the
   `docs/product/2-db/` files name exists in `db/migrations/`, and the reverse
   (ADR-053 luật 2, ADR-065). Every turn; reads files only.
6. `scripts/verify.sh` (Gate 1) — build, tests, `scripts/db-check.sh` when the
   database side changed, every `scripts/*.test.sh`. Skipped for docs-only
   turns.
7. `scripts/check-commit-block.sh` (Gate 7/7b) — **Claude hook mode only**, once
   1–6 are green: the turn must hand over the §6.1 block, and the block's
   file list must fit the scope of the task its subject names (ADR-006,
   ADR-063). Speaks at most once per tree state.

Gates 1b, 1c and 1d each take a deliberate exception in their own
`scripts/*.ignore` file, with a reason; an ignore line that stops matching turns
the gate red until removed. `work/` (and the folders each header names) is not
checked by 1b or 1c — a dead path or broken sentence quoted there is evidence.

Codex runs the gate directly: that runs steps 1–6, **not** Gate 7/7b, so Codex
checks the commit block against §6.1 by hand — file list, scope, and the real
staged index. A green direct gate does not prove the block was checked.

Every gate line at column 0 carries one label: `PASS` ran and passed · `FAIL`
ran and failed · `SKIP` did **not** run · `NOTE` does not block, read it. A
`SKIP` is not a pass. Gate output is the only evidence a change works; "I tested
it" is not evidence. The remaining gates — acceptance→evidence, diff red flags,
per-level review, cold-context review — are in `quality/review-gate.md`.

## 6. Git

- Work on a branch off `main`; never commit directly to `main`.
- Commit or push only when the user asks.
- One task per commit. Subject: `T-XXX: what changed` (imperative, ≤ 72 chars).
- Scope is session state and never reaches a commit: `work/scope/` is ignored by
  git and `work/scope.txt` is a comment-only stub (F-020, ADR-063).

### 6.1 Hand over the commit, ready to paste

You do not run `git commit`; you **write** it. Only the session knows which task
this was, which files it touched, and what the gate printed. So the closing
report of **every task**, and of **every session** for whatever is still
uncommitted, ends with:

```bash
# get the candidate list from git, don't reconstruct it from memory:
git diff --name-only HEAD
git ls-files --others --exclude-standard

git add CLAUDE.md work/backlog.md
git commit -m "T-XXX: what changed" -m "Why it changed.
Verified: ./scripts/gate.sh green."
```

- **List the files one by one, read off the two commands above** — never
  `git add -A`, never `.`, never from memory. Include only this task's files.
  Check `git diff --cached --name-only`: if someone else's files are staged,
  report them and do not hand over a block that would commit them; do not alter
  another person's index without authorization.
- **A scope file never belongs in the block** (Gate 7b names it if you list it).
- **Subject follows §6**, in the language the change is written in. An L0 change
  with no task ID drops the `T-XXX:` prefix.
- **Body: one to three lines** — why, plus the evidence it works. Skip it when
  the subject says everything.
- **One task per block.** Two tasks finished in one session are two blocks, in
  commit order.
- **Uncommitted work that is not yours is not folded in.** Name it, say it is not
  in your block, leave it to whoever made it.

Give the block whether or not the user asks — asking to commit is a separate
request (§6). In Claude hook mode Gate 7 checks for it; in Codex it is manual.

### 6.2 Gate 8 — git itself refuses a subject that says nothing

`scripts/hooks/commit-msg` is a **git** hook, so it guards commits typed in a
terminal, which never pass through a session turn (F-011). Its header owns the
rule; in short it refuses a subject that, after an optional `T-XXX: ` prefix,
is under 2 words or 8 characters, or repeats a subject already reachable from
`HEAD` (ADR-062); over 72 characters only warns. Escape hatch:
`git commit --no-verify`. It never writes the message for you (ADR-004).

```bash
./scripts/install-hooks.sh          # once per clone — sets core.hooksPath
./scripts/install-hooks.sh --check  # exit 1 = not installed here
```

`.git/` does not travel with a clone, so run it in every fresh clone; the brief
warns while it is not installed (ADR-010).

## 7. Keeping the System Current

Every session starts cold and acts on whatever it is handed, so it must be
handed the state of **today**. The loop is: **load the brief → record as you go
→ hand off.** Claude loads the brief through its hook, Codex runs it; recording
is a responsibility in both tools.

### 7.1 Start of session — load the live brief

`scripts/brief.sh` prints the live state: task In Progress, declared scope, next
Ready, Open findings, Open unknowns, newest ADRs, recent commits, last-changed
date of every §2 owner, uncommitted work. Claude gets it from a `SessionStart`
hook (`.claude/settings.json`, which also wires the gate as the Stop hook);
Codex runs it at session start, after context loss and on handoff. Either
tool reruns it whenever the state may have moved:

```bash
./scripts/brief.sh
```

- **It points, never copies** — file names, IDs, dates, headings; never a price
  or rule text (F-001). Read facts from their §2 owner.
- **It never blocks** — every failure path exits 0.
- **It says when it cut a list** (`→ ĐÃ CẮT`, F-012). A capped list is a pointer,
  not an answer: open the file it names before deciding anything.
- **It warns about a scope file whose task is not In Progress.** Delete it only
  if that task is committed; Done-but-uncommitted keeps it until the commit; if
  you are mid-task, put the task back in *In Progress* (ADR-063, F-010).

When a brief line contradicts what you believe, the brief's dates come from git:
**the brief wins**, re-read that owner before touching anything.

### 7.2 During the session — record so the next session can trust it

Record at the moment of discovery, in the same change, in the §2 owner — never
in a note "to file later". Four rules make a recorded fact usable:

- **Date and attribution.** Every new or changed fact carries `YYYY-MM-DD` and
  who decided it. An undated fact can never be aged out.
- **What you were told ≠ what you inferred.** ("Owner" here is the person who
  decides.) When the answer is shorter than the decision you need, the gap is
  your inference and goes in the inference section, never in the log of what was
  confirmed (F-004).
- **"Exactly N" only when N is a decision, not your summary.** The owner's
  "exactly five channels" may be written as exact; your own count must be dated
  and invite the next one (F-003).
- **Follow the pointers.** After changing a fact, `grep -rn` for what referred to
  it. A pointer left aimed at a moved fact is a bug in the same change.

Where each kind of fact goes is §4. Do not create a file for it (§3.8). A
genuinely new **category** of fact gets a §2 row in the change that creates its
owner.

### 7.3 End of session — hand off

Before finishing, backlog, scope files and owners match reality, and every task
finished — plus anything else uncommitted — has its §6.1 block (checklist: §8).
The final report says what is **still unresolved**, in the words the next
session needs, and **every open thing it names links to the line where it is
written**, not just its ID: `U-XXX`, `GĐ-XXX`, `ADR-XXX`, `F-XXX`, `S-X`
(`master_plan/shop-facts.md` §7.2), a blocked task. Get the line with `grep -n`
in the same turn (lines drift), and link the §2 owner, never a copy:

```markdown
**U-022** — [docs/product/99-unknowns.md:61](docs/product/99-unknowns.md#L61)
```

### 7.4 Claude Code / Codex handoff and independent review

Adopted 2026-09-25 at the repo owner's request (ADR-052). Both tools use the
same owners (§2), task state and acceptance.

- One writer per working tree. The other tool may review without editing once
  the writer pauses at a stable diff. Concurrent implementation uses separate
  branches and worktrees, separate tasks, and a named integrator; shared
  backlog and owner-file changes are still reconciled at integration.
- When receiving a task or switching tools, read the brief, task entry, current
  branch, `git status` and diff — existing changes may belong to someone else.
- Handoff lives in the existing task detail entry (§2): implementing tool,
  reviewer (or "not yet reviewed"), branch and commit/base, changed files,
  checks actually run and their results, remaining work, next action, links to
  owners. Status lives only in `work/backlog.md`; no per-tool task log or memory.
- Independent review starts from acceptance, the relevant owners and the exact
  diff; findings carry location and evidence. The implementer resolves valid
  ones and reruns affected checks. A review opinion does not change business
  truth — route decisions through §4.
- A chat session without repository access gets a snapshot (task, excerpts,
  diff); its output is a proposal until a repository session applies and
  verifies it, and it cannot claim gate results.

**Roles — Claude leads, Codex implements** (2026-09-27, repo owner; ADR-054).
Claude owns every step where a mistake costs money or invents business truth:
picking the task and moving its status, the level, Acceptance, the scope file,
design, ADRs, unknowns, `master_plan/shop-facts.md`, `quality/invariants.md`,
recording the shop owner's answers, reviewing, integrating, and the §6.1 block.
Codex implements a work order inside its own worktree and scope, runs the gate,
and reports with evidence; it never decides a business question, never edits
task status or those owners, never commits — an unclear rule stops that part and
goes into the report. Claude integrates by re-reading the real diff and rerunning
the gate: Codex's report is a claim, not evidence (§5). `git commit` stays the
repo owner's (§6). Procedure and work-order template: `docs/prompt-guideline.md`
§6.

**Small tasks without Claude** (2026-09-27, repo owner; ADR-054 *Sửa đổi*). An
L0/L1 task the repo owner hands Codex directly, with no work order, has the repo
owner as lead. Codex may then also move that task's status in `work/backlog.md`,
write its detail entry, declare and delete its scope file, add an `F-XXX` and add
an open `U-XXX`. It still never decides a business question, never edits
`docs/decisions.md`, `master_plan/shop-facts.md` or `quality/invariants.md`,
never closes an unknown, never commits. A task that turns out L2+ or needs one
of those owners goes back to Claude.

## 8. Definition of Done

Tiered like §3 — an L0 change is done after four lines, not eleven.

**L0 — four lines**

- [ ] `./scripts/gate.sh` passes (§5).
- [ ] You read your own diff.
- [ ] Any durable fact you hit (if any) is recorded in its owner (§2, §4, §7.2).
- [ ] Commit content handed over as a paste-ready block (§6.1).

**L1 and up, additionally**

- [ ] Every Acceptance line maps to a named test, or to a manual run with real
      output pasted (`quality/review-gate.md` Gate 2).
- [ ] Diff checked against the red-flag table in Gate 4.
- [ ] Task moved to *Done* in `work/backlog.md`; `work/scope/<ID>.txt` kept
      until the commit, deleted after it.
- [ ] Handed off: backlog and `work/scope/<ID>.txt` match reality (§7.3).
- [ ] Report: what changed, how it was verified (with command output), what is
      still unresolved — each open question named there carries a link to the
      line it is written on, grepped in this turn (§7.3).

**L2 and up, additionally**

- [ ] The related invariant in `quality/invariants.md` has a regression test, and
      you ran it yourself.
