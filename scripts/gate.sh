#!/usr/bin/env bash
# Quality gate — runs Gate 3 (scope), Gate 1b (links), Gate 1c (doc status),
# Gate 1d (phase boundary), Gate 1e (schema names), Gate 1 (verify), then Gate 7
# (commit).
#
# Wired as a Stop hook in .claude/settings.json, which calls it as
#   ./scripts/gate.sh --hook
# so it runs when Claude finishes a turn. Exit 2 blocks the stop and feeds the
# failure back to Claude to fix.
# Also runnable by hand or from CI: ./scripts/gate.sh
#
# verify.sh is skipped when only documentation changed, so doc turns stay fast.
# check-links.sh và check-doc-status.sh KHÔNG bị bỏ qua: tài liệu là thứ repo này
# sản xuất, nên lượt chỉ đổi tài liệu là lượt duy nhất trước đây không bị máy chấm
# gì cả (ADR-005) — và cũng đúng là lượt sinh ra lỗi mà Gate 1c bắt (ADR-032).
# check-phase-boundary.sh (Gate 1d, CLAUDE.md §2, ADR-039) runs right after
# doc-status for the same reason: it only reads docs/product/1-system-design/ and
# docs/product/2-db/, and would sleep through a documentation-only turn if it sat
# in verify.sh. check-schema-names.sh (Gate 1e, ADR-053 luật 2, P2-09) sits next
# to it for the same reason: a slice document can name a table the migrations
# never create in a documentation-only turn, and it needs no database to notice.
# check-commit-block.sh runs only in hook mode (it needs the transcript) and only
# after the gate is green: no point asking for a commit message for a red change.
#
# NHÃN (T-084, 2026-09-28): mọi dòng gate in ở cột 0 mở đầu bằng ĐÚNG MỘT nhãn —
#   PASS  cổng đã chạy và đạt        SKIP  cổng KHÔNG chạy (không có gì để kiểm)
#   FAIL  cổng đã chạy và đỏ         NOTE  lời nhắc không chặn — phải đọc
# Dòng thụt lề là chi tiết của dòng có nhãn ngay trên nó. Trước đây các script
# con in lẫn "OK" · "xanh" · "skipping" · "note:", nên "đã kiểm và đạt" trông
# giống hệt "không kiểm". Nhãn chỉ ĐỌC output của script con (label() bên dưới),
# không đổi điều kiện đạt/đỏ và exit code của cổng nào. Chi tiết của cổng PASS ·
# SKIP bị ẩn và đếm (chạy lại chính script đó để xem); chi tiết của FAIL · NOTE
# luôn in đủ. Test: scripts/gate.test.sh.

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

# label <cổng> <tên dòng trạng thái> <script> <exit> <output>
# In output của một script con thành các dòng có nhãn. Dòng trạng thái là dòng
# ở cột 0 mở đầu bằng "<tên>: " (tên có thể là "a|b"), dòng "[x] skipped — …",
# dòng "Verification passed." hoặc dòng đã mang sẵn nhãn NOTE/FAIL; mọi dòng
# khác là chi tiết. Exit khác 0 mà script không in dòng đỏ nào ⇒ thêm một dòng
# FAIL ở đầu, để cổng đỏ không bao giờ trông như đạt.
label() {
  printf '%s\n' "$5" | awk -v gate="$1" -v names="$2" -v script="$3" -v rc="$4" '
    function add(lab, name, text) {
      n++; lab_[n] = lab; name_[n] = name; text_[n] = text
      cur = n; if (lab == "FAIL") hadfail = 1
      if (lab == "PASS" || lab == "SKIP") last = n
    }
    BEGIN { cur = 0 }   # chi tiết trước dòng trạng thái đầu nằm ở det[0]
    function strip(t) { sub(/^[[:space:]]*(—|-|:)[[:space:]]*/, "", t); return t }
    /^[[:space:]]*$/ { next }
    /^Verification passed\.?$/ { add("PASS", "verify", (tests + 0) " file scripts/*.test.sh chạy, đều qua"); next }
    /^\[test\] \// { tests++ }   # dòng verify.sh in (đường dẫn tuyệt đối), không dòng test tự in
    /^\[[A-Za-z0-9._-]+\] skipped/ {
      nm = $0; sub(/^\[/, "", nm); sub(/\].*/, "", nm)
      t = $0; sub(/^\[[^]]*\] skipped[[:space:]]*/, "", t); add("SKIP", nm, strip(t)); next
    }
    /^(NOTE|FAIL) / { add(substr($0, 1, 4), "", substr($0, 6)); next }
    match($0, "^(" names "): ") {
      nm = substr($0, 1, RLENGTH - 2); t = substr($0, RLENGTH + 1)
      if (t ~ /^(FAIL|ĐỎ)([[:space:]]|$)/)       { sub(/^(FAIL|ĐỎ)/, "", t); add("FAIL", nm, strip(t)) }
      else if (t ~ /^note([[:space:]]|:|$)/)     { sub(/^note/, "", t); add("NOTE", nm, strip(t)) }
      else if (t ~ /skipping\.?$/)               { sub(/,?[[:space:]]*skipping\.?$/, "", t); add("SKIP", nm, t) }
      else if (t ~ /^(OK|xanh|PASS)([[:space:]]|$)/) { sub(/^(OK|xanh|PASS)/, "", t); add(rc == 0 ? "PASS" : "FAIL", nm, strip(t)) }
      else add(rc == 0 ? "PASS" : "FAIL", nm, t)
      next
    }
    {
      # chi tiết: hiện dưới FAIL · NOTE, hoặc khi cả cổng đỏ; còn lại ẩn và đếm
      if (rc != 0 || (cur && (lab_[cur] == "FAIL" || lab_[cur] == "NOTE"))) {
        det[cur] = det[cur] "    " $0 "\n"
      } else hidden++
    }
    END {
      if (rc != 0 && !hadfail) {
        printf "%-4s  %-8s %s — thoát mã %s\n", "FAIL", gate, script, rc
        printf "%s", det[0]; det[0] = ""
      }
      if (n == 0 && rc == 0) { add("PASS", script, ""); last = n }
      if (hidden > 0) {
        if (!last) { add("PASS", script, ""); last = n }
        text_[last] = text_[last] (text_[last] == "" ? "" : " ") "(" hidden " dòng chi tiết ẩn — chạy ./scripts/" script " để xem)"
      }
      for (i = 1; i <= n; i++) {
        nm = (name_[i] == "" ? "" : name_[i] (text_[i] == "" ? "" : " — "))
        printf "%-4s  %-8s %s%s\n", lab_[i], gate, nm, text_[i]
        if (i == 1) printf "%s", det[0]   # chi tiết in trước dòng trạng thái đầu
        printf "%s", det[i]
      }
    }'
}

report=""
failed=0

step() { # step <cổng> <tên dòng trạng thái> <script> — chạy script, gom output có nhãn
  local out rc
  out="$("./scripts/$3" 2>&1)"
  rc=$?
  [ "$rc" -ne 0 ] && failed=1
  report="$report$(label "$1" "$2" "$3" "$rc" "$out")"$'\n'
}

step "Gate 3"  "check-scope"          check-scope.sh
step "Gate 1b" "check-links"          check-links.sh
step "Gate 1c" "check-doc-status"     check-doc-status.sh
step "Gate 1d" "check-phase-boundary" check-phase-boundary.sh
step "Gate 1e" "check-schema-names"   check-schema-names.sh

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
  step "Gate 1" "db-check" verify.sh
else
  report="$report$(printf '%-4s  %-8s %s' SKIP "Gate 1" "verify — chỉ tài liệu đổi, không chạy verify.sh")"$'\n'
fi

if [ "$failed" -ne 0 ]; then
  printf '%-4s  %-8s %s\n%s' FAIL gate "có cổng đỏ — sửa trước khi kết thúc:" "$report" >&2
  exit 2
fi

printf '%s' "$report"
printf '%-4s  %-8s %s\n' PASS gate "không cổng nào đỏ (SKIP ở trên là cổng không chạy, không phải cổng đạt)"

# Gate 7 — CLAUDE.md §6.1: the turn hands over the commit content.
if [ "${1:-}" = "--hook" ] && [ -n "${input:-}" ]; then
  out="$(printf '%s' "$input" | ./scripts/check-commit-block.sh --hook 2>&1)"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    label "Gate 7" "commit-block" check-commit-block.sh "$rc" "$out" >&2
    exit "$rc"
  fi
  [ -n "$out" ] && label "Gate 7" "commit-block" check-commit-block.sh 0 "$out"
fi
exit 0
