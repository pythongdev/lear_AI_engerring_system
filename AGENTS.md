# Codex entry point

Read `CLAUDE.md` before starting work. It owns the shared repository rules for
both Claude Code and Codex; this file only connects Codex to those rules.

Run `./scripts/brief.sh` at session start and after context loss or a handoff,
then read only the task and owner files it points to that are relevant.
The Claude hooks in `.claude/settings.json` do not supply this step to Codex.

After changes, run `./scripts/gate.sh` and inspect its output. This direct run
does not execute the transcript-based commit checks (Gate 7/7b). Follow
`CLAUDE.md` §6.1 to check and hand over the commit block yourself.

For switching between tools or independent review, follow `CLAUDE.md` §7.4.
Keep task state and handoff notes in the existing backlog/task entry, not in
separate tool-specific memory files.
