#!/usr/bin/env bash
# Session brief — prints the CURRENT state of the system, not the state of the
# day the documents were written.
#
# Wired as a SessionStart hook in .claude/settings.json, so it runs on startup,
# /clear, resume and compaction, and its stdout lands in the session's context
# before the first instruction. That is the point: a session cannot forget to
# read something that arrives on its own.
# Also runnable by hand whenever the state may have moved under you:
#   ./scripts/brief.sh
#
# HARD RULE — this script is a POINTER, never a COPY.
# It may print file names, IDs (T-/F-/U-/ADR-), dates and headings. It must
# never restate a business fact: no price, no rule text, no channel list. A
# brief that carried the prices would be the second copy that work/findings.md
# F-001 was written about. Owners in CLAUDE.md §2 stay the only place to read.
#
# Never blocks a session: every failure path still exits 0.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "brief: not a git repository — no state to report."
  exit 0
}
cd "$ROOT" || exit 0

MAX_LIST=6   # keep the brief small; it is injected into every session

section() { printf '\n%s\n' "$1"; }
none()    { printf '  (none)\n'; }

# Lines of a "## Heading" block in a markdown file, up to the next "## ".
block() {
  local file="$1" heading="$2"
  [ -f "$file" ] || return 0
  awk -v h="$heading" '
    $0 == h { inblk = 1; next }
    inblk && /^## / { exit }
    inblk { print }
  ' "$file"
}

printf '=== Lean AI Engineering — session brief (%s) ===\n' "$(date +%F)"
printf 'Read CLAUDE.md first. This brief points; the owners in §2 hold the facts.\n'

# --- What is being worked on -------------------------------------------------
section "IN PROGRESS (work/backlog.md)"
inprog="$(block work/backlog.md '## In Progress' | grep -E '^- \[' | head -n "$MAX_LIST")"
if [ -n "$inprog" ]; then printf '%s\n' "$inprog" | sed 's/^/  /'; else none; fi

section "DECLARED SCOPE (work/scope.txt)"
if [ -f work/scope.txt ]; then
  # No cap here. A scope line hidden by truncation is a scope line nobody
  # honours, and Gate 3 would then reject a file the brief said nothing about.
  scope="$(grep -vE '^\s*(#|$)' work/scope.txt)"
  if [ -n "$scope" ]; then
    printf '%s\n' "$scope" | sed 's/^/  /'
    printf '  → a task is open. Finish or hand it off before starting another.\n'
  else
    printf '  (not declared — no task in flight, or an L0 change)\n'
  fi
else
  printf '  (no work/scope.txt)\n'
fi

section "NEXT READY (work/backlog.md)"
ready="$(block work/backlog.md '## Ready' | grep -E '^- \[ \]' | head -n "$MAX_LIST")"
if [ -n "$ready" ]; then printf '%s\n' "$ready" | sed 's/^/  /'; else none; fi

# --- What is unresolved ------------------------------------------------------
# An Open finding that blocks a Ready task is done first (CLAUDE.md §3.3).
section "OPEN FINDINGS (work/findings.md)"
openf="$(awk '
  /^### F-/ { title = $0; sub(/^### /, "", title); status = "" ; next }
  /^\*\*Status:\*\*/ { getline s; gsub(/^[ \t]+|[ \t]+$/, "", s);
                       if (s == "Open" && title != "") print title; title = "" }
' work/findings.md 2>/dev/null | head -n "$MAX_LIST")"
if [ -n "$openf" ]; then printf '%s\n' "$openf" | sed 's/^/  /'; else none; fi

section "OPEN UNKNOWNS (docs/product.md → Unknowns)"
openu="$(block docs/product.md '## Unknowns' | grep -E '^\s*[-*]?\s*U-[0-9]' | head -n "$MAX_LIST")"
if [ -n "$openu" ]; then printf '%s\n' "$openu" | sed 's/^/  /'; else none; fi

# --- What was decided --------------------------------------------------------
section "LATEST DECISIONS (docs/decisions.md)"
adr="$(grep -E '^### ADR-' docs/decisions.md 2>/dev/null | grep -v ' — Title$' | tail -n 3)"
if [ -n "$adr" ]; then printf '%s\n' "$adr" | sed 's/^### /  /'; else none; fi

# --- What moved since last time ----------------------------------------------
section "RECENT COMMITS"
git log -n 5 --format='  %h %ad %s' --date=short 2>/dev/null || none

section "OWNER FILES — last changed (CLAUDE.md §2)"
# Re-read any owner whose date is newer than the fact you are carrying in your
# head. Dates come from git, so they cannot go stale the way a hand-typed
# "last updated" line does.
for f in \
  docs/product.md docs/architecture.md docs/decisions.md \
  quality/invariants.md work/backlog.md work/findings.md \
  master_plan/shop-facts.md CLAUDE.md
do
  [ -f "$f" ] || continue
  d="$(git log -1 --format=%ad --date=short -- "$f" 2>/dev/null)"
  [ -n "$d" ] || d="uncommitted"
  printf '  %-30s %s\n' "$f" "$d"
done

section "UNCOMMITTED"
dirty="$(git -c core.quotepath=false status --porcelain --untracked-files=all 2>/dev/null | head -n 10)"
if [ -n "$dirty" ]; then
  printf '%s\n' "$dirty" | sed 's/^/  /'
  printf '  → someone was mid-change. Understand it before editing on top of it.\n'
else
  printf '  (clean)\n'
fi

printf '\n'
exit 0
