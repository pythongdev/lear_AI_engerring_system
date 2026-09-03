# Lean AI Engineering System

## 1. Overview

This repository is an AI-assisted development operating system: a small set of
canonical documents, a task backlog, and three shell gates that make every
change verifiable.

This file is the entry point for any AI session working in this repo. Read it
first, every session, before touching anything else. It says where facts live,
how to work, and what "done" means. It does not repeat those facts — it points
at their single owner.

Ceremony scales with risk (L0–L3): most changes owe almost nothing, a few owe a
lot. The levels are defined in `README.md`, what each one costs here is §3, and
how to write a prompt at each level is in `docs/prompt-guideline.md`.

The repository keeps growing; a session's memory does not. §7 is how the system
hands each new session the state as it is **today** — read it before you trust
anything you think you already know about this project.

## 2. Source of Truth

One fact, one owner. If two files disagree, the owner below wins and the other
is a bug to fix now.

| Fact | Owner |
|---|---|
| Business rules, product behavior | `docs/product/` |
| Open business questions (unknowns) | `docs/product/99-unknowns.md` |
| Architecture | `docs/product/1-system-design/architecture.md` |
| Architecture decisions (ADR) | `docs/decisions.md` |
| Business invariants | `quality/invariants.md` |
| Tasks | `work/backlog.md` |
| Scope of the task in progress | `work/scope.txt` |
| Recurring problems, lessons | `work/findings.md` |
| How to write a prompt/task | `docs/prompt-guideline.md` |
| How to check LLM output | `quality/review-gate.md` |
| Risk levels, repo philosophy | `README.md` |
| Shop facts: scope, channels, prices, flows, business rules | `master_plan/shop-facts.md` |
| Proposals about this system that were **not** adopted | `work/proposals/` |

Behavior is cut by phase under `docs/product/`; which file owns which section is
in `docs/product/00-index.md`, which owns no fact itself. `docs/product.md` is the
pre-split archive: it owns nothing, nothing points at it, and no session reads a
fact from it.

Domain material for the current project lives in `master_plan/` and the BA prompt
set in `prompt/BA/`. **`master_plan/shop-facts.md` is the single owner of every
shop fact** — selling scope, channels, prices, surcharges, portion composition,
operating flows, business rules. It is deliberately self-contained and link-free:
it points nowhere, everything points at it. `master_plan/00-scope.md` is a
redirect stub kept only so older links resolve; it owns nothing.

`work/proposals/` holds documents that say what this repo *should* look like —
outside advice, blueprints, redesigns — none of it adopted. Nothing in there is a
fact and nothing points at it: if a proposal is ever taken up, it becomes a task
in `work/backlog.md`, and the fact lands in its owner above. Each file opens with
a banner giving its date, its status, and the rows of this table it contradicts —
where they disagree, **this table wins**. It lives under `work/` on purpose: the
paths such a document names describe a structure that does not exist, and `work/`
is where Gate 1b does not check links (§5).

```text
CLAUDE.md          this file — read first
docs/              product/ → 00-index.md, 0-ba/… (behavior), 1-system-design/
                   (architecture), 99-unknowns.md — all by phase;
                   decisions, prompt guideline
work/              backlog.md, scope.txt, findings.md;
                   proposals/ — not adopted, owns nothing
quality/           invariants.md, review-gate.md
scripts/           gate.sh → check-scope.sh + check-links.sh
                   + check-doc-status.sh + verify.sh + check-commit-block.sh;
                   brief.sh (§7);
                   hooks/ → commit-msg (Gate 8, §6.2), install-hooks.sh
master_plan/       domain facts for the current project
prompt/            prompt sets built from master_plan/
.claude/           settings.json (SessionStart → brief.sh, Stop → gate.sh)
```

## 3. Working Rules

Ceremony follows risk. Pick the level by what breaks if the change is wrong, not
by the size of the diff (levels: `README.md`). **Most changes are L0 or L1.**

| Obligation | L0 | L1 | L2 | L3 |
|---|:--:|:--:|:--:|:--:|
| `./scripts/gate.sh` passes | ✓ | ✓ | ✓ | ✓ |
| Entry in `work/backlog.md` | — | ✓ | ✓ | ✓, split into L1/L2 |
| `work/scope.txt` declared | — | ✓ | ✓ | ✓ |
| Acceptance written *before* the change | — | ✓ | ✓ | ✓ |
| Regression test for the related invariant | — | — | ✓ | ✓ |
| ADR in `docs/decisions.md` | — | — | if a design choice was made | ✓ |
| Design reviewed before any code | — | — | — | ✓ |

L0 is a real level, not a loophole: a typo, a formatting run, a mechanical rename
is *change → gate → done*, no paperwork. A change is L1+ once it alters behavior,
a contract, or data. Escalate only when the answer to "what breaks if this is
wrong" reaches money, stored data, or a published contract — not to feel safe.

Then, at every level:

1. **Context** — start from the session brief (§7.1), which arrives on its own
   and tells you what moved since last time. Then load only what the task needs:
   the task entry in `work/backlog.md`, the patterns in `work/scope.txt`, the
   owners in §2 that the task actually touches, and the code and tests under
   those patterns. Do not read the repository by default.
2. **Focus** — one task at a time, finished before the next is started.
3. **Priority** (L1+) — take the top unchecked item in `work/backlog.md` →
   *Ready* unless the user names another. An Open finding in `work/findings.md`
   that blocks a Ready task is done first. Move the item to *In Progress* when
   you start.
4. **Scope** (L1+) — declare `work/scope.txt` before the first edit, matching the
   Scope section of the prompt, and stay inside it. One pattern per line:

   ```text
   order/          everything under order/
   docs/x.md       exactly this file
   !order/db.go    denied, even if an allow line above matches
   ```

   If the task genuinely needs more, update `work/scope.txt` and say so — do not
   edit outside it silently. Clear the patterns when the task is done.
5. **Never invent business truth** — if a business rule is unclear, stop and ask.
   If you cannot ask, record it and leave the behavior undecided (§4). This rule
   has no L0.
6. **Verify** — run `./scripts/gate.sh` after every change (§5).
7. **Record durable facts** — a rule, decision, or invariant discovered while
   working goes into its owner from §2, in that file's own template, in the same
   change that discovered it. How to write it so the next session can trust it:
   §7.2.
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

Record only what has future value. A one-off imperfection is not a finding.

An open question is only routed if the brief can find it. `scripts/brief.sh` pushes
the open list into every new session (§7.1), and it reads the *Unknowns* section by
**structure**: the open region is the top of the section plus every block under a
`### Đang mở` heading, and inside it **one bullet is one open question** — the
`U-XXX` may sit anywhere in that bullet, bold or not, wrapped over as many lines as
it needs. Prose there is prose, and anything under a different `###` heading is not
read. So a question written as a paragraph, or filed under the answered heading, is
a question the next session never sees. The full contract lives with the section it
governs, in `docs/product/99-unknowns.md` → *Cách viết một câu ở đây*
(`docs/decisions.md` ADR-007, `work/findings.md` F-008).

## 5. Verification

```bash
./scripts/gate.sh
```

It runs, in order:

1. `scripts/check-scope.sh` (Gate 3) — every changed file **git already tracks**
   must match `work/scope.txt`. Catches the correct change that touches
   unauthorized files. An untracked file outside scope is printed as a `note:`
   and does **not** fail the gate — git cannot tell whether it predates the task
   (ADR-003). If the note lists a file *your* task created, put it in scope or
   delete it; nothing else will stop you.
2. `scripts/check-links.sh` (Gate 1b) — every path a **pointer document** names
   must open. Runs on **every** turn, including documentation-only ones: docs are
   what this repo produces, and step 3 is skipped for exactly those turns
   (ADR-005). `work/` and `prompt/maintenance/` are not checked — a dead path
   quoted there is evidence, not a bug. A path that deliberately does not exist
   goes in `scripts/check-links.ignore` with its owner; an ignore line that stops
   matching turns the gate red until it is removed.
3. `scripts/check-doc-status.sh` (Gate 1c) — **một mã định danh, hai chỗ, hai
   trạng thái**. Also runs on **every** turn, and for the same reason as step 2:
   this defect is *born* in documentation-only turns — closing an unknown edits
   `.md` files and nothing else — so a check living in `verify.sh` would sleep
   through exactly the turn that creates it (ADR-032). Three comparisons: a
   **closed** `U-XXX` quoted as still open · a transition the §5 lifecycle
   tables list as **valid** being denied right beside it · a `GĐ-XXX` row in the
   `docs/decisions.md` summary table disagreeing with `Trạng thái:` in the body
   it points at. It reads **blocks, not lines** — the documents wrap every
   paragraph, and a line-based filter is blind to a keyword split across two
   lines (`work/findings.md` F-015). `work/` and `prompt/` are not checked: a
   broken sentence quoted there is evidence. A deliberate quote goes in
   `scripts/check-doc-status.ignore` with its reason, and an ignore line that
   stops matching turns the gate red until it is removed.
4. `scripts/verify.sh` (Gate 1) — Go: `gofmt` check, `go build`, `go test`;
   Node: `npm test` / `lint` / `build` when present, then every
   `scripts/*.test.sh`. Skipped when the change touches documentation only.
5. `scripts/check-commit-block.sh` (Gate 7) — **hook mode only**, and only once
   the four above are green: tracked changes are waiting to be committed, so the
   turn must hand over the commit block (§6.1). Untracked files and
   `work/scope.txt` never trigger it, and it asks once per state of the tree.
   It then asks a second question — **what is in that block** (Gate 7b,
   ADR-006): it reads the block's `git add` lines, plus the real index when
   something is staged, and names any file outside `work/scope.txt`, any
   `git add -A` / `git add .`, and `work/scope.txt` itself if it appears there.
   It judges the file list you deliberately chose, never the working tree, so
   ADR-003 stands: an untracked file inside scope stays silent. Scope not
   declared ⇒ silent. Like the rest of Gate 7, it speaks at most once per state
   of the tree, and what it sends back is the *report text* to rewrite — not the
   change, which is already green by then.

The gate is also wired as a Stop hook in `.claude/settings.json`, so it runs when
a turn ends; a failure blocks the turn and returns the output to be fixed.

Gate output is the only evidence a change works. "I tested it" is not evidence.
The remaining gates — acceptance→evidence mapping, diff red flags, per-level
review, cold-context review — are in `quality/review-gate.md`.

## 6. Git

- Work on a branch off `main`; never commit directly to `main`.
- Commit or push only when the user asks.
- One task per commit. Subject: `T-XXX: what changed` (imperative, ≤ 72 chars).
- `work/scope.txt` is working state, not a deliverable — do not commit patterns.

### 6.1 Hand over the commit, ready to paste

You do not run `git commit`; you **write** it. The session is the only place that
still knows which task this was, which files it touched, and what the gate
printed — that knowledge has to leave the session in a form the user can paste.
So the closing report of **every task**, and of **every session** for whatever is
still uncommitted, ends with:

```bash
git add CLAUDE.md work/backlog.md
git commit -m "T-XXX: what changed" -m "Why it changed.
Verified: ./scripts/gate.sh green."
```

- **List the files, one by one.** Never `git add -A`, never `.` — the block must
  stage this task's files and nothing that happened to be lying around.
- **`work/scope.txt` is never in the block** (§6 above; the two times it was
  committed are `work/backlog.md` T-016).
- **Subject follows §6:** `T-XXX: what changed`, imperative, ≤ 72 chars, written
  in the language the change itself is written in. An L0 change with no task ID
  drops the `T-XXX:` prefix.
- **Body: one to three lines** — why, plus the evidence that it works. Skip the
  body when the subject already says everything (a typo, a rename).
- **One task per block.** Two tasks finished in one session are two blocks, in
  the order they should be committed (§6: one task per commit).
- **Uncommitted work that is not yours is not folded in.** Name it, say it is
  not in your block, and leave it to whoever made it.

Give the block whether or not the user asks for it — asking to commit is a
separate request (§6), and the answer to it is already written by then.

This one is enforced, not remembered: `scripts/check-commit-block.sh` (Gate 7,
§5) blocks the end of a turn that leaves tracked changes uncommitted without a
`git commit -m` block in its report.

### 6.2 Gate 8 — git itself refuses a subject that says nothing

Gate 7 lives inside the lifetime of **a session turn**. Someone typing
`git commit -m` in a terminal never passes through a turn, and five commits
reached this repo that way under the names `ádg`, `sdgf`, `sdfg`, `dsfg`, `adg`
(`work/findings.md` F-011). `scripts/hooks/commit-msg` is the gate that stands
where Gate 7 cannot: a **git** hook, so it runs for every commit on this clone,
whoever writes it.

```bash
./scripts/install-hooks.sh          # once per clone — sets core.hooksPath
./scripts/install-hooks.sh --check  # exit 1 = not installed here
```

- **Run it in every fresh clone.** `.git/` does not travel with `git clone`, so
  the hook file is in the repo but not running until this command points
  `core.hooksPath` at `scripts/hooks/` (`docs/decisions.md` ADR-010). The session
  brief (§7.1) prints a warning while it is not installed, so nobody has to
  remember — but nothing can *force* it, and that limit is part of the decision.
- **What it refuses:** strip an optional `T-XXX: ` prefix, and what is left must
  be at least 2 words and 8 characters. That is the whole rule. `Fix typo` passes;
  `adg` does not.
- **What it only warns about:** a subject over 72 characters. It still says what
  it changed, and red for the wrong reason teaches people to remove the hook.
- **Escape hatch, printed in the refusal itself:** `git commit --no-verify`.
- **It never writes the message for you.** §6 keeps the commit as the user's
  decision (`docs/decisions.md` ADR-004); a machine-written subject would have
  exactly the quality of `ádg`.

## 7. Keeping the System Current

The repo grows; a session's memory does not survive it. Every session starts
cold and will act on whatever it is handed — so it must be handed the state of
**today**, not the state of the day the documents were written.

The loop is: **the brief arrives → you record as you go → you hand off.**
Only the middle step is discipline, and that is deliberate — `work/findings.md`
F-001 is the record of what happens when a rule relies on someone remembering.

### 7.1 Start of session — the brief arrives on its own

`scripts/brief.sh` prints the live state: the task In Progress, the declared
scope, the next Ready task, Open findings, Open unknowns, the newest ADRs,
recent commits, the last-changed date of every owner file in §2, and any
uncommitted work.

It also warns about one state it can see and you cannot: `work/scope.txt` still
holding patterns while **no** task sits in *In Progress* — the scope of a
finished task nobody cleared (§7.3). Clear it before starting anything, or Gate 3
will judge your change by someone else's scope; if you are mid-task, put the task
back in *In Progress* rather than deleting the scope. Patterns **with** a task in
*In Progress* are normal and stay silent (ADR-006, F-010).

It is a `SessionStart` hook in `.claude/settings.json`, so it runs on startup,
`/clear`, resume and compaction, and its output is in context before the first
instruction. Nobody has to remember to read it. Run it by hand whenever the
state may have moved under you:

```bash
./scripts/brief.sh
```

Three rules keep it honest:

- **It points, it never copies.** File names, IDs, dates, headings — never a
  price, a rule text, or a channel list. A brief carrying facts would be the
  second copy F-001 was written about. Read facts from their owner in §2.
- **It never blocks.** Every failure path exits 0. A broken brief must not cost
  you a session.
- **It says when it cut a list.** Every list is capped — six items for In
  Progress, Ready and Open findings, twelve for Open unknowns, which get their
  own threshold because §3.5 can only stop a session that *knows* what it is
  missing. When a list is longer than its cap, the brief prints `→ ĐÃ CẮT` with
  how many it showed, how many are left, and where to read all of them. Silence
  is only ever "that is the whole list": a seven-item list that printed six of
  them silently is what made U-011 invisible from the day it was written
  (`work/findings.md` F-012, fixed by T-027). So a capped list is a pointer, not
  an answer — open the file it names before you decide anything.

When a brief line contradicts what you believe: the brief's dates come from
git, so **the brief wins** and you re-read that owner before touching anything.

### 7.2 During the session — record so the next session can trust it

Record at the moment of discovery, in the same change, in the owner from §2 —
never in a note "to file later". A fact you learned and did not write down dies
when the session ends, and the next session re-derives it wrong.

Four rules make a recorded fact usable by someone who was not there:

- **Date and attribution.** Every new or changed fact carries `YYYY-MM-DD` and
  who decided it. An undated fact can never be aged out, so it is believed
  forever.
- **What you were told ≠ what you inferred.** ("Owner" below means the person
  who decides — the business owner, the user — not the file owners of §2.) When
  the answer you got is shorter than the decision you need, the gap is your
  inference: it goes in the inference section, never in the log of what was
  confirmed (F-004).
- **"Exactly N" only when N is a decision, not your summary.** The owner saying
  "exactly five channels, there is no sixth" may be written as exact — adding a
  sixth then needs their permission. Your own count — "differs in three places"
  — may not: date it and invite the fourth (F-003).
- **Follow the pointers.** After changing a fact, `grep -rn` for what referred
  to it. A pointer left aimed at a fact that moved is a bug in the same change,
  not a follow-up task.

Where each kind of fact goes is §4. Do not create a file for it (§3.8): a new
fact belongs in an existing owner. If a genuinely new **category** of fact
appears, §2's table gains a row in the same change that creates its owner —
an owner that §2 does not list is an owner nobody will find.

### 7.3 End of session — hand off

Anything true only inside your head is lost. Before finishing:

- The task in `work/backlog.md` reflects reality — moved to *Done*, or left in
  *In Progress* with what remains written into the entry.
- `work/scope.txt` is cleared when the task is done, or left declared and
  accurate when it is not.
- Every rule, decision, invariant and unknown you hit is in its owner (§2, §4).
- Every task finished this session has its paste-ready commit block in the
  report (§6.1), plus one for anything else left uncommitted.
- The final report says what is **still unresolved**, in the same words the
  next session would need to pick it up — and **every open question it names
  carries a link to the question itself**, not just its ID.

  A report saying *"U-022 is still open"* makes the reader go hunting for U-022;
  the ID is an index entry, not an answer. So each one gets a clickable link to
  the line where the question is actually written:

  ```markdown
  **U-022** — [docs/product/99-unknowns.md:61](docs/product/99-unknowns.md#L61)
  **GĐ-04** — [docs/decisions.md:844](docs/decisions.md#L844)
  ```

  - **Applies to every kind of open thing you name:** `U-XXX`
    (`docs/product/99-unknowns.md`), `GĐ-XXX` and `ADR-XXX`
    (`docs/decisions.md`), `F-XXX` (`work/findings.md`), `S-X`
    (`master_plan/shop-facts.md` §7.2), and a blocked task in
    `work/backlog.md`.
  - **Get the line number at report time**, with `grep -n`, in the same turn you
    write the report. Line numbers drift as documents grow; one copied from
    memory or from an earlier turn points at the wrong line.
  - **Link the owner from §2, never a copy.** The link is a pointer, not a place
    to restate the question — same reason the brief points and never copies
    (§7.1, `work/findings.md` F-001).

## 8. Definition of Done

Tiered like §3 — an L0 change is done after four lines, not eleven.

**Every level**

- [ ] `./scripts/gate.sh` passes (§5).
- [ ] You read your own diff.
- [ ] Any rule, decision, invariant, or unknown you hit is recorded in its owner
      (§2, §4), written so the next session can trust it (§7.2).
- [ ] Handed off: backlog and `work/scope.txt` match reality (§7.3).
- [ ] Commit content handed over as a paste-ready block (§6.1).
- [ ] Report: what changed, how it was verified (with command output), what is
      still unresolved — each open question named there carries a link to the
      line it is written on, grepped in this turn (§7.3).

**L1 and up, additionally**

- [ ] Every Acceptance line maps to a named test, or to a manual run with real
      output pasted (`quality/review-gate.md` Gate 2).
- [ ] Diff checked against the red-flag table in Gate 4.
- [ ] Task moved to *Done* in `work/backlog.md`; `work/scope.txt` cleared.

**L2 and up, additionally**

- [ ] The related invariant in `quality/invariants.md` has a regression test, and
      you ran it yourself.
