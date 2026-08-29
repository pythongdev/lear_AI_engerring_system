# Lean AI Engineering System

## 1. Overview

This repository is an AI-assisted development operating system: a small set of
canonical documents, a task backlog, and three shell gates that make every
change verifiable.

This file is the entry point for any AI session working in this repo. Read it
first, every session, before touching anything else. It says where facts live,
how to work, and what "done" means. It does not repeat those facts — it points
at their single owner.

Ceremony scales with risk (L0–L3). The levels are defined in `README.md`; how to
write a prompt at each level is in `docs/prompt-guideline.md`.

## 2. Source of Truth

One fact, one owner. If two files disagree, the owner below wins and the other
is a bug to fix now.

| Fact | Owner |
|---|---|
| Business rules, product behavior | `docs/product.md` |
| Open business questions (unknowns) | `docs/product.md` → *Unknowns* |
| Architecture | `docs/architecture.md` |
| Architecture decisions (ADR) | `docs/decisions.md` |
| Business invariants | `quality/invariants.md` |
| Tasks | `work/backlog.md` |
| Scope of the task in progress | `work/scope.txt` |
| Recurring problems, lessons | `work/findings.md` |
| How to write a prompt/task | `docs/prompt-guideline.md` |
| How to check LLM output | `quality/review-gate.md` |
| Risk levels, repo philosophy | `README.md` |

Domain material for the current project lives in `master_plan/` (`00-scope.md`
owns selling scope and prices; `shop-facts.md` owns operating rules and
deliberately keeps no copy of the numbers) and the BA prompt set in `prompt/BA/`.

```text
CLAUDE.md          this file — read first
docs/              product, architecture, decisions, prompt guideline
work/              backlog.md, scope.txt, findings.md
quality/           invariants.md, review-gate.md
scripts/           gate.sh → check-scope.sh + verify.sh
master_plan/       domain facts for the current project
prompt/            prompt sets built from master_plan/
.claude/           settings.json (Stop hook runs the gate)
```

## 3. Working Rules

1. **Context** — load only what the task needs: the task entry in
   `work/backlog.md`, the patterns in `work/scope.txt`, the owners in §2 that
   the task actually touches, and the code and tests under those patterns. Do
   not read the repository by default.
2. **Focus** — one meaningful task at a time. A meaningful change alters
   behavior, contracts, or data (a bug fix, a new endpoint, a price rule);
   formatting and mechanical renames are L0 and need no task entry.
3. **Priority** — take the top unchecked item in `work/backlog.md` → *Ready*
   unless the user names another. An Open finding in `work/findings.md` that
   blocks a Ready task is done first. Move the item to *In Progress* when you
   start.
4. **Scope** — declare `work/scope.txt` before the first edit, matching the
   Scope section of the prompt, and stay inside it. One pattern per line:

   ```text
   order/          everything under order/
   docs/x.md       exactly this file
   !order/db.go    denied, even if an allow line above matches
   ```

   If the task genuinely needs more, update `work/scope.txt` and say so — do not
   edit outside it silently. Clear the patterns when the task is done.
5. **Never invent business truth** — if a business rule is unclear, stop and ask.
   If you cannot ask, record it and leave the behavior undecided (§4).
6. **Verify** — run `./scripts/gate.sh` after every meaningful change (§5).
7. **Record durable facts** — a rule, decision, or invariant discovered while
   working goes into its owner from §2, in that file's own template, in the same
   change that discovered it.
8. **No ceremony documents** — do not create a `.md` file nobody asked for. Add
   a rule, a hook, or a test only after a real problem has recurred.

## 4. Handling Unknowns

Never let implementation silently decide an open question. Route it:

| Kind | Where | Format |
|---|---|---|
| Open business question | `docs/product.md` → *Unknowns* | `U-XXX — question, who can answer, what is blocked` |
| Recurring problem or lesson | `work/findings.md` | `F-XXX` template in that file |
| Choice between viable designs | `docs/decisions.md` | `ADR-XXX` template in that file |

Record only what has future value. A one-off imperfection is not a finding.

## 5. Verification

```bash
./scripts/gate.sh
```

It runs, in order:

1. `scripts/check-scope.sh` (Gate 3) — every changed file must match
   `work/scope.txt`. Catches the correct change that touches unauthorized files.
2. `scripts/verify.sh` (Gate 1) — Go: `gofmt` check, `go build`, `go test`;
   Node: `npm test` / `lint` / `build` when present. Skipped when the change
   touches documentation only.

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

## 7. Definition of Done

- [ ] `./scripts/gate.sh` passes (§5).
- [ ] Every Acceptance line in the task maps to a named test or a manual run with
      real output pasted (`quality/review-gate.md` Gate 2).
- [ ] Diff checked against the red-flag table in `quality/review-gate.md` Gate 4.
- [ ] L2+ only: the related invariant in `quality/invariants.md` has a regression
      test.
- [ ] New rules, decisions, invariants, unknowns recorded in their owner (§2, §4).
- [ ] Task moved to *Done* in `work/backlog.md`; `work/scope.txt` cleared.
- [ ] Report: what changed, how it was verified (with command output), what is
      still unresolved.
