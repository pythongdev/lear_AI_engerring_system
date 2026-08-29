# Lean AI Engineering System

## Mission

Build and maintain the project with small, verifiable changes.

## Source of Truth

- Business rules → `docs/product.md`
- Architecture → `docs/architecture.md`
- Architecture decisions → `docs/decisions.md`
- Work → `work/backlog.md`
- Known recurring problems → `work/findings.md`
- Business invariants → `quality/invariants.md`
- How to write a prompt/task → `docs/prompt-guideline.md`
- How to check LLM output → `quality/review-gate.md`

## Working Rules

1. Read only context relevant to the current task.
2. Work on one meaningful task at a time.
3. Keep changes within the task scope declared in `work/scope.txt`.
4. Never invent business rules; ask or record an unknown.
5. Verify every meaningful change by running `./scripts/gate.sh`.
6. If a durable rule or decision is discovered, record it in its canonical source.
7. Do not create documentation merely to satisfy process.

## Before Finishing

- Run `./scripts/gate.sh`. It must pass.
- Check the change against `quality/review-gate.md`.
- Report what changed.
- Report how it was verified.
- Report unresolved issues, if any.
