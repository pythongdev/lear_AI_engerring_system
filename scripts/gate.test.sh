#!/usr/bin/env bash
# Test cho nhãn của scripts/gate.sh (T-084).
#
# Chạy tay:  ./scripts/gate.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng một repo git tạm, chép gate.sh THẬT vào, và thay chín script con
# bằng bản giả in đúng chữ và thoát đúng mã mà ca cần. Nhờ vậy test không bao
# giờ gọi lại gate.sh hay verify.sh thật (không đệ quy), và chứng minh điều T-084
# hứa: nhãn chỉ ĐỌC output của cổng con — exit code và điều kiện đạt/đỏ giữ
# nguyên.

set -uo pipefail

GATE="$(cd "$(dirname "$0")" && pwd)/gate.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

newrepo() { # newrepo <tên> → repo tạm, mọi cổng giả đều xanh và im như thật
  local d="$TMPROOT/$1"
  mkdir -p "$d/scripts" "$d/docs"
  git -C "$d" init -q
  git -C "$d" config user.email t@t
  git -C "$d" config user.name t
  echo "# a" > "$d/docs/a.md"
  echo "x" > "$d/code.txt"
  cp "$GATE" "$d/scripts/gate.sh"
  stub "$d" check-scope.sh 0 "check-scope: work/scope.txt has no patterns — scope not declared, skipping"
  stub "$d" check-links.sh 0 "check-links: OK — mọi đường dẫn trong tài liệu chỉ đường đều mở được."
  stub "$d" check-doc-status.sh 0 "check-doc-status: xanh — 10 khối, 2 mã U-XXX, 1 chuyển tiếp hợp lệ."
  stub "$d" check-phase-boundary.sh 0 "check-phase-boundary: không file .md nào đổi ở a hay b, skipping"
  stub "$d" check-schema-names.sh 0 "check-schema-names: PASS — 2 bảng ở migration, 2 bảng tài liệu nhắc, comm -3 rỗng"
  stub "$d" check-write-paths.sh 0 "check-write-paths: PASS — 0 ô ghi, 0 cửa, 0 file đã soát"
  stub "$d" check-api-contract.sh 0 "check-api-contract: PASS — hợp đồng 0.1.0; 0 đường gọi ở hợp đồng, 0 ở code"
  stub "$d" check-gin-imports.sh 0 "check-gin-imports: PASS"
  stub "$d" verify.sh 0 "=== Lean AI Engineering Verification ===
[db] skipped — nothing under db/ changed
[time] be-static 2s
[test] /abs/scripts/x.test.sh
[test] x.sh
  ok   ca 1
x.test: OK
[time] test:x.test.sh 3s
Verification passed."
  stub "$d" check-commit-block.sh 0 ""
  git -C "$d" add -A >/dev/null 2>&1 && git -C "$d" commit -qm init >/dev/null 2>&1
  printf '%s' "$d"
}

stub() { # stub <repo> <script> <exit> <output>
  printf '#!/usr/bin/env bash\ncat <<'"'"'__OUT__'"'"'\n%s\n__OUT__\nexit %s\n' "$4" "$3" > "$1/scripts/$2"
  chmod +x "$1/scripts/$2"
}

OUT="" ERR="" RC=0
run() { # run <repo> [--hook] — gom stdout+stderr vào $OUT, exit vào $RC
  local r="$1" stdout="$TMPROOT/stdout" stderr="$TMPROOT/stderr"; shift
  if [ "${1:-}" = "--hook" ]; then
    (cd "$r" && printf '{"transcript_path":"x"}' | ./scripts/gate.sh --hook >"$stdout" 2>"$stderr")
  else
    (cd "$r" && ./scripts/gate.sh </dev/null >"$stdout" 2>"$stderr")
  fi
  RC=$?
  OUT="$(cat "$stdout" "$stderr")"
  ERR="$(cat "$stderr")"
}

ok()   { echo "  ok   $1"; }
bad()  { echo "  FAIL $1"; printf '%s\n' "$OUT" | sed 's/^/       | /'; fails=$((fails + 1)); }
has()  { if printf '%s\n' "$OUT" | grep -qF -- "$2"; then ok "$1"; else bad "$1 — thiếu: $2"; fi; }
hasnt(){ if printf '%s\n' "$OUT" | grep -qF -- "$2"; then bad "$1 — không được có: $2"; else ok "$1"; fi; }
haserr(){ if printf '%s\n' "$ERR" | grep -qF -- "$2"; then ok "$1"; else bad "$1 — thiếu trên stderr: $2"; fi; }
matches(){ if printf '%s\n' "$OUT" | grep -Eq -- "$2"; then ok "$1"; else bad "$1 — thiếu mẫu: $2"; fi; }
rc()   { if [ "$RC" = "$2" ]; then ok "$1 (exit $RC)"; else bad "$1 — mong exit $2, nhận $RC"; fi; }

# Mọi dòng ở cột 0 mang ĐÚNG MỘT nhãn; không dòng nào mở đầu bằng chữ trạng
# thái cũ; dòng thụt lề là chi tiết.
labels() { # labels <tên ca>
  local badl
  badl="$(printf '%s\n' "$OUT" | grep -v '^[[:space:]]' | grep -v '^$' |
    grep -Ev '^(PASS|FAIL|SKIP|NOTE)  [^ ]' || true)"
  local twice
  twice="$(printf '%s\n' "$OUT" | grep -E '^(PASS|FAIL|SKIP|NOTE)  +[^ ]+( [0-9a-z]+)? +(PASS|FAIL|SKIP|NOTE)\b' || true)"
  if [ -z "$badl" ] && [ -z "$twice" ]; then ok "$1: mọi dòng cột 0 mang đúng một nhãn"
  else bad "$1: dòng không nhãn hoặc hai nhãn: $badl$twice"; fi
}

echo "[test] gate.sh — nhãn PASS · FAIL · SKIP · NOTE"

# 1 — chỉ tài liệu đổi, mọi cổng xanh: cổng không chạy là SKIP, không là PASS.
r="$(newrepo docs)"
echo "# b" >> "$r/docs/a.md"
run "$r"
rc "1 chỉ tài liệu đổi" 0
labels "1"
has   "1 scope chưa khai là SKIP"       "SKIP  Gate 3   check-scope — work/scope.txt has no patterns — scope not declared"
has   "1 links đạt là PASS"             "PASS  Gate 1b  check-links — mọi đường dẫn"
has   "1 doc-status đạt là PASS"        "PASS  Gate 1c  check-doc-status — 10 khối"
has   "1 Gate 1d không file là SKIP"    "SKIP  Gate 1d  check-phase-boundary"
has   "1 verify bỏ qua là SKIP"         "SKIP  Gate 1   verify — chỉ tài liệu đổi"
has   "1 dòng tổng là PASS"             "PASS  gate     không cổng nào đỏ"
matches "1 thời gian đủ tám cổng"       '^    thời gian [0-9]+s — Gate 3 [0-9]+s · Gate 1b [0-9]+s · Gate 1c [0-9]+s · Gate 1d [0-9]+s · Gate 1e [0-9]+s · Gate 1f [0-9]+s · Gate 1g [0-9]+s · Gate 1h [0-9]+s$'
hasnt "1 không có thời gian Gate 1"      "    Gate 1:"
hasnt "1 không còn chữ skipping"        "skipping"
hasnt "1 không còn chữ xanh —"          "xanh —"
hasnt "1 không còn chữ OK —"            ": OK —"

# 2 — code đổi, verify đạt nhưng db-check bỏ qua: hai cổng, hai nhãn khác nhau.
r="$(newrepo code)"
echo "y" >> "$r/code.txt"
run "$r"
rc "2 code đổi, verify đạt" 0
labels "2"
has   "2 db-check bỏ qua là SKIP"       "SKIP  Gate 1   db — nothing under db/ changed"
has   "2 verify đạt là PASS, đếm test"  "PASS  Gate 1   verify — 1 file scripts/*.test.sh chạy, đều qua"
matches "2 thời gian có Gate 1"        '^    thời gian [0-9]+s — .* · Gate 1 [0-9]+s$'
has   "2 bước Gate 1 và test"           "    Gate 1: be-static 2s · test 3s (1 file)"
has   "2 test chậm nhất"                "    test chậm nhất: x.test.sh 3s"
has   "2 chi tiết ẩn có đếm và chỗ xem" "dòng chi tiết ẩn — chạy ./scripts/verify.sh để xem)"
hasnt "2 chi tiết test không lộ"        "ok   ca 1"

# 3 — lời nhắc không chặn: NOTE, chi tiết của nó vẫn hiện, gate vẫn đạt.
r="$(newrepo note)"
stub "$r" check-scope.sh 0 "check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):
  ? tmp/x.md
  Nếu file nào trong số này do chính task vừa tạo ra: đưa vào scope, hoặc xoá đi.
check-scope: OK — all tracked changes within declared scope."
echo "# b" >> "$r/docs/a.md"
run "$r"
rc "3 note không chặn" 0
labels "3"
has   "3 note là NOTE"                  "NOTE  Gate 3   check-scope — file chưa được git theo dõi"
has   "3 chi tiết của NOTE hiện"        "      ? tmp/x.md"
has   "3 cùng cổng vẫn có PASS"         "PASS  Gate 3   check-scope — all tracked changes within declared scope."

# 4 — cổng đỏ tự in FAIL: FAIL, chi tiết đủ, exit 2 như cũ.
r="$(newrepo fail)"
stub "$r" check-scope.sh 1 "check-scope: FAIL — files changed outside the scope declared in work/scope.txt:
  - code.txt
Revert them, or update work/scope.txt if the task scope genuinely changed."
echo "# b" >> "$r/docs/a.md"
run "$r"
rc "4 cổng đỏ giữ exit 2" 2
labels "4"
has   "4 dòng đầu là FAIL tổng"         "FAIL  gate     có cổng đỏ"
has   "4 cổng đỏ là FAIL"               "FAIL  Gate 3   check-scope — files changed outside"
has   "4 chi tiết của FAIL hiện"        "    Revert them, or update work/scope.txt"
has   "4 cổng khác vẫn chạy và in"      "PASS  Gate 1b  check-links"
haserr "4 thời gian gate đỏ trên stderr" "    thời gian "

# 5 — cổng đỏ không in dòng trạng thái nào (dạng của Gate 1d): FAIL chung + chi tiết.
r="$(newrepo pb)"
stub "$r" check-phase-boundary.sh 1 "Gate 1d — một pha đang đặt tên thứ pha sau sở hữu:
docs/x.md:3:CREATE TABLE t"
echo "# b" >> "$r/docs/a.md"
run "$r"
rc "5 Gate 1d đỏ" 2
labels "5"
has   "5 FAIL chung kèm mã thoát"       "FAIL  Gate 1d  check-phase-boundary.sh — thoát mã 1"
has   "5 chi tiết hiện"                 "    docs/x.md:3:CREATE TABLE t"

# 6 — nhãn theo EXIT, không theo chữ: in "OK" mà thoát 1 vẫn là FAIL.
r="$(newrepo liar)"
stub "$r" check-links.sh 1 "check-links: OK — mọi đường dẫn trong tài liệu chỉ đường đều mở được."
echo "# b" >> "$r/docs/a.md"
run "$r"
rc "6 exit 1 thắng chữ OK" 2
labels "6"
has   "6 là FAIL"                       "FAIL  Gate 1b  check-links — mọi đường dẫn"
hasnt "6 không PASS nào cho cổng ấy"    "PASS  Gate 1b"

# 7 — verify đỏ: FAIL, toàn bộ output hiện (không ẩn gì).
r="$(newrepo vfail)"
stub "$r" verify.sh 1 "=== Lean AI Engineering Verification ===
[test] /abs/scripts/x.test.sh
  FAIL ca 2 — sai
[time] test:x.test.sh 4s"
echo "y" >> "$r/code.txt"
run "$r"
rc "7 verify đỏ" 2
labels "7"
has   "7 FAIL chung"                    "FAIL  Gate 1   verify.sh — thoát mã 1"
has   "7 chi tiết đỏ hiện"              "      FAIL ca 2 — sai"
hasnt "7 không nói ẩn chi tiết"         "chi tiết ẩn"
haserr "7 thời gian Gate 1 trên stderr" "    Gate 1: test 4s (1 file)"
haserr "7 test chậm nhất trên stderr"   "    test chậm nhất: x.test.sh 4s"

# 8 — Gate 7 (hook) chặn: FAIL trên stderr, exit giữ nguyên.
r="$(newrepo g7)"
stub "$r" check-commit-block.sh 2 "commit-block: turn này chưa giao nội dung commit (CLAUDE.md §6.1).
Đang có thay đổi git theo dõi mà chưa commit:
   M docs/a.md"
echo "# b" >> "$r/docs/a.md"
run "$r" --hook
rc "8 Gate 7 giữ exit 2" 2
labels "8"
has   "8 Gate 7 là FAIL"                "FAIL  Gate 7   commit-block — turn này chưa giao nội dung commit"
has   "8 chi tiết hiện"                 "    Đang có thay đổi git theo dõi mà chưa commit:"

# 9 — Gate 7 im (đã giao khối): gate đạt, không dòng Gate 7 nào.
r="$(newrepo g7ok)"
echo "# b" >> "$r/docs/a.md"
run "$r" --hook
rc "9 Gate 7 im" 0
hasnt "9 không dòng Gate 7"             "Gate 7"

# 10 — chỉ lấy ba file test chậm nhất, cộng đủ thời gian và giữ số file verify đếm.
r="$(newrepo slow)"
stub "$r" verify.sh 0 "[time] be-static 20s
[time] fe-rules 1s
[time] fe-check 150s
[test] /abs/scripts/a.test.sh
[time] test:a.test.sh 9s
[test] /abs/scripts/b.test.sh
[time] test:b.test.sh 20s
[test] /abs/scripts/c.test.sh
[time] test:c.test.sh 1s
[test] /abs/scripts/d.test.sh
[time] test:d.test.sh 10s
Verification passed."
echo "y" >> "$r/code.txt"
run "$r"
rc "10 bốn file test, gate xanh" 0
labels "10"
has "10 số file đếm như trước" "PASS  Gate 1   verify — 4 file scripts/*.test.sh chạy, đều qua"
has "10 tổng bước Gate 1" "    Gate 1: be-static 20s · fe-rules 1s · fe-check 150s · test 40s (4 file)"
has "10 đúng ba test chậm nhất theo thứ tự" "    test chậm nhất: b.test.sh 20s · d.test.sh 10s · a.test.sh 9s"
hasnt "10 test thứ tư không vào top" "c.test.sh 1s"

# 11 — verify chạy nhưng bộ test script bỏ qua: SKIP riêng, PASS verify đúng sự thật.
r="$(newrepo test_skip)"
stub "$r" verify.sh 0 "[time] be-static 2s
[test] skipped — 6 file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi
Verification passed."
echo "y" >> "$r/code.txt"
run "$r"
rc "11 verify xanh, test bỏ qua" 0
labels "11"
has "11 nhãn SKIP của test" "SKIP  Gate 1   test — 6 file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi"
has "11 PASS verify không đếm test" "PASS  Gate 1   verify — các bước đã chạy đều qua"
hasnt "11 không nói test đã chạy" "file scripts/*.test.sh chạy"
has "11 giữ thời gian bước đã chạy" "    Gate 1: be-static 2s"
hasnt "11 không có test chậm nhất" "test chậm nhất:"

# 11b — một test chạy, các test khác bỏ qua: vẫn đếm đúng và hiện SKIP.
r="$(newrepo test_partial)"
stub "$r" verify.sh 0 "[test] skipped — 5 file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi
[test] /abs/scripts/fe-check.test.sh
[time] test:fe-check.test.sh 1s
Verification passed."
echo "y" >> "$r/code.txt"
run "$r"
rc "11b verify xanh, một test chạy" 0
labels "11b"
has "11b nhãn SKIP đếm năm file" "SKIP  Gate 1   test — 5 file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi"
has "11b PASS verify đếm một file" "PASS  Gate 1   verify — 1 file scripts/*.test.sh chạy, đều qua"
has "11b thời gian chỉ test đã chạy" "    Gate 1: test 1s (1 file)"

# 12 — verify.sh thật trong repo tạm: toàn bộ script, một test riêng, hoặc không test.
newverifyrepo() {
  local d="$TMPROOT/$1"
  mkdir -p "$d/scripts/hooks" "$d/quality"
  git -C "$d" init -q
  git -C "$d" config user.email t@t
  git -C "$d" config user.name t
  cp "$(dirname "$GATE")/verify.sh" "$d/scripts/verify.sh"
  local test_name
  for test_name in fe-check.test.sh check-write-paths.test.sh check-sqlcgen.test.sh reconcile.test.sh be-check.test.sh probe.test.sh; do
    printf '#!/usr/bin/env bash\necho "[probe] %s ran"\n' "$test_name" > "$d/scripts/$test_name"
    chmod +x "$d/scripts/$test_name"
  done
  echo base > "$d/code.txt"
  echo base > "$d/quality/invariants.md"
  git -C "$d" add -A && git -C "$d" commit -qm init
  printf '%s' "$d"
}
runverify() {
  local d="$1"
  VOUT="$(cd "$d" && ./scripts/verify.sh 2>&1)"
  VRC=$?
}
r="$(newverifyrepo verify_triggers)"
echo changed >> "$r/code.txt"
runverify "$r"
if [ "$VRC" = 0 ] && [[ "$VOUT" == *'[test] skipped — 6 file: không có gì dưới scripts/ đổi và đầu vào riêng của chúng không đổi'* ]] && [[ "$VOUT" != *'[probe] '* ]]; then
  ok "12 ngoài mọi danh sách: không test nào chạy, skipped đếm 6"
else bad "12 code ngoài danh sách phải bỏ qua test"; printf '%s\n' "$VOUT" | sed 's/^/       | verify: /'; fi
r="$(newverifyrepo verify_scripts)"
echo '# changed' >> "$r/scripts/verify.sh"
runverify "$r"
count="$(printf '%s\n' "$VOUT" | grep -c '^\[test\] /' || true)"
if [ "$VRC" = 0 ] && [ "$count" = 6 ] && [[ "$VOUT" == *'[probe] probe.test.sh ran'* ]] && [[ "$VOUT" != *'[test] skipped'* ]]; then
  ok "12 scripts/ đổi: cả 6 test chạy, không skipped"
else bad "12 scripts/ đổi phải chạy cả 6 test"; fi
r="$(newverifyrepo verify_hook)"
echo hook > "$r/scripts/hooks/new-hook"
runverify "$r"
count="$(printf '%s\n' "$VOUT" | grep -c '^\[test\] /' || true)"
if [ "$VRC" = 0 ] && [ "$count" = 6 ] && [[ "$VOUT" != *'[test] skipped'* ]]; then
  ok "12 hook mới: cả 6 test chạy"
else bad "12 hook mới phải chạy cả 6 test"; fi
r="$(newverifyrepo verify_fe)"
mkdir -p "$r/fe/src"; echo changed > "$r/fe/src/a.ts"
runverify "$r"
count="$(printf '%s\n' "$VOUT" | grep -c '^\[test\] /' || true)"
if [ "$VRC" = 0 ] && [ "$count" = 1 ] && [[ "$VOUT" == *'[probe] fe-check.test.sh ran'* ]] && [[ "$VOUT" == *'[test] skipped — 5 file:'* ]]; then
  ok "12 chỉ fe/: chỉ fe-check chạy, skipped đếm 5"
else bad "12 chỉ fe/ phải chạy riêng fe-check"; fi
r="$(newverifyrepo verify_owner)"
echo changed >> "$r/quality/invariants.md"
runverify "$r"
count="$(printf '%s\n' "$VOUT" | grep -c '^\[test\] /' || true)"
if [ "$VRC" = 0 ] && [ "$count" = 1 ] && [[ "$VOUT" == *'[probe] be-check.test.sh ran'* ]] && [[ "$VOUT" == *'[test] skipped — 5 file:'* ]]; then
  ok "12 chỉ quality/invariants.md: chỉ be-check chạy, skipped đếm 5"
else bad "12 chỉ quality/invariants.md phải chạy riêng be-check"; fi

echo
if [ "$fails" -eq 0 ]; then
  echo "gate.test: tất cả ca đều qua."
else
  echo "gate.test: $fails ca FAIL."
  exit 1
fi
