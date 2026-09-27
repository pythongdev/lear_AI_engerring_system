# Codex entry point

Read `CLAUDE.md` before starting work. It owns the shared repository rules for
both Claude Code and Codex; this file only connects Codex to those rules.

Run `./scripts/brief.sh` at session start and after context loss or a handoff,
then read only the task and owner files it points to that are relevant.
The Claude hooks in `.claude/settings.json` do not supply this step to Codex.

After changes, run `./scripts/gate.sh` and inspect its output. This direct run
does not execute the transcript-based commit checks (Gate 7/7b). Follow
`CLAUDE.md` §6.1 to check and hand over the commit block yourself.

In this repo Codex works in one of two modes (`CLAUDE.md` §7.4, *Roles*):

- **Work order from Claude** — stay inside its scope, do not decide business
  questions, do not edit task status, decisions, unknowns, shop facts or
  invariants, do not commit, and end with the report format the work order asks
  for.
- **Small task straight from the repo owner** (L0/L1, no work order) — the repo
  owner leads, so you may also move that task's own status in
  `work/backlog.md`, write its detail entry, declare and clear
  `work/scope.txt`, add an `F-XXX` finding and add an open `U-XXX` question.
  Still never decide a business question, never edit `docs/decisions.md`,
  `master_plan/shop-facts.md` or `quality/invariants.md`, never close an
  unknown, never commit. If the task turns out L2+ or needs one of those files,
  stop and hand it back to Claude.

If you cannot tell which mode you are in, stop at the first decision that
belongs to the lead and ask.

For switching between tools or independent review, follow `CLAUDE.md` §7.4.
Keep task state and handoff notes in the existing backlog/task entry, not in
separate tool-specific memory files.
