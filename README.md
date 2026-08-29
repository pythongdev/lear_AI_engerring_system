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
work/
  backlog.md
  findings.md
quality/
  invariants.md
scripts/
  verify.sh
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

Start with `CLAUDE.md`, then load only the product, architecture, decisions, code, and tests relevant to the current task.

Do not read the entire repository by default.

## Findings

A finding is not a bug diary. Record only problems or lessons with future value.

## Evolution

Do not add framework rules preemptively. Add automation or documentation when the project encounters a real recurring problem.
# lear_AI_engerring_system
