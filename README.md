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
AGENTS.md             (Codex entry → shared rules in CLAUDE.md)
CLAUDE.md
docs/
  product.md
  architecture.md
  decisions.md
  prompt-guideline.md
work/
  backlog.md
  findings.md
  scope.txt
quality/
  invariants.md
  review-gate.md
master_plan/
  shop-facts.md        (mọi dữ kiện của dự án hiện tại — CLAUDE.md §2)
prompt/
  BA/ maintenance/     (bộ prompt dựng từ master_plan/)
scripts/
  verify.sh
  check-scope.sh
  check-links.sh
  check-links.ignore
  check-links.test.sh
  check-commit-block.sh
  check-commit-block.test.sh
  gate.sh
  brief.sh
.claude/
  settings.json
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