#!/usr/bin/env bash
# Gate 3 — scope drift check.
#
# Compares the files changed in the working tree against the scope declared in
# work/scope.txt. Catches the failure test cannot catch: the change is correct
# but touches files the task never authorised.
#
# work/scope.txt format (one pattern per line, # starts a comment):
#   order/*        allow anything under order/
#   docs/x.md      allow exactly this file
#   !order/db.go   deny, even if an allow pattern above matches it
#
# A pattern ending in / is treated as "everything under this directory".
# Note: * matches across / (order/* also matches order/sub/a.go).
#
# No work/scope.txt, or one with no active patterns → scope not declared, skip.

set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "check-scope: not a git repository, skipping"
  exit 0
}
cd "$ROOT" || exit 0

SCOPE_FILE="${SCOPE_FILE:-work/scope.txt}"

[ -f "$SCOPE_FILE" ] || {
  echo "check-scope: no $SCOPE_FILE — scope not declared, skipping"
  exit 0
}

allow=()
deny=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  [ -n "$line" ] || continue
  case "$line" in
    !*) pat="${line#!}"; [ "${pat%/}" != "$pat" ] && pat="${pat}*"; deny+=("$pat") ;;
    *)  pat="$line";     [ "${pat%/}" != "$pat" ] && pat="${pat}*"; allow+=("$pat") ;;
  esac
done < "$SCOPE_FILE"

if [ ${#allow[@]} -eq 0 ] && [ ${#deny[@]} -eq 0 ]; then
  echo "check-scope: $SCOPE_FILE has no patterns — scope not declared, skipping"
  exit 0
fi

matches() {
  local path="$1"; shift
  local pat
  for pat in "$@"; do
    # shellcheck disable=SC2254 # pattern must stay unquoted to glob
    case "$path" in $pat) return 0 ;; esac
  done
  return 1
}

violations=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  path="${line:3}"
  case "$path" in *" -> "*) path="${path##* -> }" ;; esac
  [ -n "$path" ] || continue
  if [ ${#deny[@]} -gt 0 ] && matches "$path" "${deny[@]}"; then
    violations+=("$path (matches a ! deny pattern)")
    continue
  fi
  if [ ${#allow[@]} -eq 0 ] || ! matches "$path" "${allow[@]}"; then
    violations+=("$path")
  fi
done < <(git -c core.quotepath=false status --porcelain --untracked-files=all)

if [ ${#violations[@]} -gt 0 ]; then
  echo "check-scope: FAIL — files changed outside the scope declared in $SCOPE_FILE:"
  printf '  - %s\n' "${violations[@]}"
  echo "Revert them, or update $SCOPE_FILE if the task scope genuinely changed."
  exit 1
fi

echo "check-scope: OK — all changes within declared scope."
