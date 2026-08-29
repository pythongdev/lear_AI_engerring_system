#!/usr/bin/env bash
# Quality gate — runs Gate 3 (scope) then Gate 1 (verify).
#
# Wired as a Stop hook in .claude/settings.json, which calls it as
#   ./scripts/gate.sh --hook
# so it runs when Claude finishes a turn. Exit 2 blocks the stop and feeds the
# failure back to Claude to fix.
# Also runnable by hand or from CI: ./scripts/gate.sh
#
# verify.sh is skipped when only documentation changed, so doc turns stay fast.

set -uo pipefail

# Hook input (JSON) arrives on stdin, but ONLY in hook mode. Every other caller
# leaves stdin alone: a script or CI job inherits a stdin that may never reach
# EOF, and reading it there hangs the gate forever instead of running it.
# Never re-block a turn that is already continuing because of this hook.
if [ "${1:-}" = "--hook" ] && [ ! -t 0 ]; then
  input="$(cat)"
  if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    exit 0
  fi
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$ROOT" || exit 0

report=""
failed=0

if out="$(./scripts/check-scope.sh 2>&1)"; then
  :
else
  failed=1
fi
report="$out"

code_changed=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  case "$path" in
    docs/*|work/*|quality/*|*.md) ;;
    *) code_changed=1; break ;;
  esac
done < <(git -c core.quotepath=false status --porcelain --untracked-files=all)

if [ "$code_changed" -eq 1 ]; then
  if out="$(./scripts/verify.sh 2>&1)"; then
    report="$report"$'\n'"$out"
  else
    report="$report"$'\n'"$out"
    failed=1
  fi
else
  report="$report"$'\n'"verify: skipped — only documentation changed."
fi

if [ "$failed" -ne 0 ]; then
  printf 'Quality gate FAILED. Fix this before finishing:\n%s\n' "$report" >&2
  exit 2
fi

printf '%s\n' "$report"
