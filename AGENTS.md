# Codex entry point

Read `CLAUDE.md` before starting work. It owns the shared repository rules for
both Claude Code and Codex; this file only connects Codex to those rules.

Run `./scripts/brief.sh` at session start and after context loss or a handoff,
then read only the task and owner files it points to that are relevant.
The Claude hooks in `.claude/settings.json` do not supply this step to Codex.

After changes, run `./scripts/gate.sh` and inspect its output. This direct run
does not execute the transcript-based commit checks (Gate 7/7b). Follow
`CLAUDE.md` §6.1 to check and hand over the commit block yourself.

In this repo Codex is the implementer and Claude leads (`CLAUDE.md` §7.4,
*Roles*). Work from the work order you were given: stay inside its scope, do
not decide business questions, do not edit task status, decisions, unknowns,
shop facts or invariants, do not commit, and end with the report format the
work order asks for. If a task reaches you without a work order, stop at the
first decision that belongs to the lead and ask.

For switching between tools or independent review, follow `CLAUDE.md` §7.4.
Keep task state and handoff notes in the existing backlog/task entry, not in
separate tool-specific memory files.
