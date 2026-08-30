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
scripts/
  verify.sh
  check-scope.sh
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

`scripts/brief.sh` runs as a `SessionStart` hook and hands every session the current state: what is in progress, what is open, what changed. Start with it and `CLAUDE.md`, then load only the product, architecture, decisions, code, and tests relevant to the current task.

Do not read the entire repository by default.

The brief points at owners; it never copies a fact out of one. See `CLAUDE.md` §7.

## Findings

A finding is not a bug diary. Record only problems or lessons with future value.

## Evolution

Do not add framework rules preemptively. Add automation or documentation when the project encounters a real recurring problem.
# lear_AI_engerring_system
