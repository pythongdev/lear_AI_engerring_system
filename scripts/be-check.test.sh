#!/usr/bin/env bash
# Test cho phép kiểm QC-17 trong scripts/be-check.sh (F-061, T-148).
#
# Chạy tay:  ./scripts/be-check.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng một repo git tạm chứa be-check.sh, owner QC-17
# (docs/product/2-db/10-quy-uoc-code.md) và quality/invariants.md thật, cùng một be/ giả,
# rồi chạy "be-check.sh --names-only" — không Docker, không đụng cây thật. Tên sai
# phải đỏ (phép chấm chưa bao giờ đỏ là phép chấm chưa được chứng minh), tên đúng phải im.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

mkrepo() { # mkrepo <thư mục> — repo tạm với script và hai owner thật
  local d="$1"
  mkdir -p "$d/scripts" "$d/docs/product/2-db" "$d/quality" "$d/be/internal/x"
  cp "$ROOT/scripts/be-check.sh" "$d/scripts/"
  cp "$ROOT/docs/product/2-db/10-quy-uoc-code.md" "$d/docs/product/2-db/"
  cp "$ROOT/quality/invariants.md" "$d/quality/"
  git -C "$d" init -q
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có> <thư mục>
  local name="$1" want_rc="$2" want_txt="$3" d="$4" out rc
  out="$(cd "$d" && ./scripts/be-check.sh --names-only 2>&1)"
  rc=$?
  out="$(printf '%s' "$out" | tr '\n' ' ')"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

d="$TMPROOT/dung"; mkrepo "$d"
printf 'package x\nfunc TestMain(m *testing.M) {}\nfunc TestI020_HopLe(t *testing.T) {}\nfunc TestQC17_HopLe(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "tên mang mã ⇒ xanh" 0 "PASS be-check QC-17" "$d"

d="$TMPROOT/saiten"; mkrepo "$d"
printf 'package x\nfunc TestSaiTen(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "TestSaiTen ⇒ đỏ, nêu tên" 1 "TestSaiTen" "$d"

d="$TMPROOT/khongco"; mkrepo "$d"
printf 'package x\nfunc TestI999_KhongCoMenhDe(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
check "mã I không có ở invariants ⇒ đỏ" 1 "không có I-999" "$d"

d="$TMPROOT/mattaiLieu"; mkrepo "$d"
printf '# rỗng\n' > "$d/docs/product/2-db/10-quy-uoc-code.md"
check "owner mất khối QC-17 ⇒ đỏ, không im" 1 "không đọc được khối phép kiểm QC-17" "$d"

# Chạy riêng cleanup_on_exit trong subshell: nhánh giữ không gọi Docker.
run_keep_cleanup() { # run_keep_cleanup <repo tạm> <project>
  (
    cd "$1" || exit 1
    eval "$(sed -n '/^cleanup_on_exit() {$/,/^}$/p' "$ROOT/scripts/be-check.sh")"
    PROJECT="$2"
    keep_db=1
    BANHCUON_TEST_OWNER_DSN=owner-test
    BANHCUON_TEST_APP_DSN=app-test
    false
    cleanup_on_exit
  ) 2>&1
}

project=banhcuon_check_123_be_1700000000_42
d="$TMPROOT/giulai"; mkdir -p "$d"; git -C "$d" init -q
out="$(run_keep_cleanup "$d" "$project")"; rc=$?
marker="$d/.git/lean-ai-kept-db/$project"
if [ "$rc" = 1 ] && [ -f "$marker" ] && [ ! -s "$marker" ] &&
   [[ "$out" == *"rm -f -- .git/lean-ai-kept-db/$project"* ]]; then
  echo "  ok   giữ database ⇒ tạo dấu rỗng và in lệnh dọn (exit $rc)"
else
  echo "  FAIL giữ database — exit $rc, dấu: $marker, output: $out"
  fails=$((fails + 1))
fi

d="$TMPROOT/khongtaodau"; mkdir -p "$d"; git -C "$d" init -q
: > "$d/.git/lean-ai-kept-db"
out="$(run_keep_cleanup "$d" "$project")"; rc=$?
if [ "$rc" = 1 ] && [[ "$out" == *"NOTE be-check — không tạo được dấu giữ"* ]] &&
   [[ "$out" == *"BE_CHECK_KEEP_DB=1, giữ database lúc đỏ"* ]]; then
  echo "  ok   không tạo được dấu ⇒ báo NOTE và vẫn giữ database (exit $rc)"
else
  echo "  FAIL không tạo được dấu — exit $rc, output: $out"
  fails=$((fails + 1))
fi

# --- T-323 lát 2 (ADR-144): mỗi gói test một database riêng ---------------------------------
# Test hồi quy Claude viết TRƯỚC khi sửa be-check.sh; nó đỏ với bản chạy `go test ./...` trên một
# database chung. Không Docker, không Go thật: `docker` và `go` giả ghi lại lời gọi.
# Hợp đồng mà be-check.sh phải giữ:
#   - `go list …` (đối số đầu là `list`) in mỗi dòng một gói CÓ test; mỗi dòng được truyền nguyên
#     văn làm đối số cuối của một lệnh `go test` riêng;
#   - trước mỗi lệnh ấy có một lời gọi docker mang `CREATE DATABASE` + tên database của gói +
#     `TEMPLATE banhcuon`;
#   - hai DSN của một gói cùng trỏ database của gói; không gói nào dùng chung tên, không gói nào
#     dùng `banhcuon`; không còn lệnh `go test … ./...`;
#   - một gói đỏ không làm các gói sau bị bỏ chạy, và be-check thoát khác 0, nêu tên gói đỏ.
mkrepo_goi() { # mkrepo_goi <thư mục> <gói phải đỏ, hoặc rỗng>
  local d="$1" bad="$2"
  mkrepo "$d"
  printf 'package x\nfunc TestQC16_HopLe(t *testing.T) {}\n' > "$d/be/internal/x/x_test.go"
  mkdir -p "$d/master_plan" "$d/bin"
  printf '| Múi giờ | `Asia/Ho_Chi_Minh` |\n' > "$d/master_plan/shop-facts.md"
  cat > "$d/bin/docker" <<'EOS'
#!/usr/bin/env bash
printf 'docker %s\n' "$*" >> "$FAKE_LOG"
case "$*" in
  *"port db 5432"*) echo "127.0.0.1:55432" ;;
  # `docker compose exec` thật đọc đầu vào chuẩn. Bản giả cũng phải đọc, nếu không test này
  # không bắt được lỗi vòng lặp bị ăn mất danh sách gói (đo 2026-11-12 trên Docker thật:
  # chỉ 1/32 gói chạy mà be-check vẫn báo PASS).
  *" exec "*) cat >/dev/null ;;
esac
exit 0
EOS
  cat > "$d/bin/go" <<EOS
#!/usr/bin/env bash
case "\$1" in
  list) printf '%s\\n' banhcuon/be/internal/a banhcuon/be/internal/b banhcuon/be/internal/c ;;
  test)
    cat >/dev/null   # lệnh go test thật cũng có thể đọc đầu vào chuẩn (xem chú thích ở docker giả)
    pkg="\${@: -1}"
    printf 'gotest app=%s owner=%s pkg=%s\\n' "\$BANHCUON_TEST_APP_DSN" "\$BANHCUON_TEST_OWNER_DSN" "\$pkg" >> "\$FAKE_LOG"
    if [ "\$pkg" = "$bad" ]; then echo "FAIL \$pkg"; exit 1; fi
    echo "ok  \$pkg" ;;
esac
exit 0
EOS
  chmod +x "$d/bin/docker" "$d/bin/go"
}

run_goi() { # run_goi <thư mục> → in output, trả mã thoát của be-check.sh
  ( cd "$1" && FAKE_LOG="$1/fake.log" PATH="$1/bin:$PATH" ./scripts/be-check.sh 2>&1 )
}

dbname() { sed -E 's#^.*@[^/]*/([^?]*).*$#\1#'; } # tên database trong một DSN

d="$TMPROOT/moigoi"; mkrepo_goi "$d" ""
out="$(run_goi "$d")"; rc=$?
log="$(cat "$d/fake.log" 2>/dev/null)"
ntest="$(printf '%s\n' "$log" | grep -c '^gotest ')"
if [ "$rc" = 0 ] && [ "$ntest" = 3 ]; then
  echo "  ok   ba gói có test ⇒ ba lệnh go test riêng (exit $rc)"
else
  echo "  FAIL mong exit 0 và 3 lệnh go test, nhận exit $rc và $ntest lệnh: $(printf '%s' "$out" | tail -3 | tr '\n' ' ')"
  fails=$((fails + 1))
fi
if printf '%s\n' "$log" | grep '^gotest ' | grep -q 'pkg=\./\.\.\.'; then
  echo "  FAIL vẫn còn lệnh go test ./... trên một database chung"; fails=$((fails + 1))
else
  echo "  ok   không còn lệnh go test ./..."
fi
names=""; bad_pair=0; missing_create=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  app="$(printf '%s' "$line" | sed -E 's/^gotest app=([^ ]*) .*/\1/' | dbname)"
  own="$(printf '%s' "$line" | sed -E 's/^.* owner=([^ ]*) .*/\1/' | dbname)"
  [ "$app" = "$own" ] || bad_pair=1
  names="$names$app"$'\n'
  printf '%s\n' "$log" | grep '^docker ' | grep 'CREATE DATABASE' | grep -F -- "$app" | grep -q 'TEMPLATE banhcuon' || missing_create=1
done < <(printf '%s\n' "$log" | grep '^gotest ')
uniq_n="$(printf '%s' "$names" | grep -v '^$' | sort -u | grep -c .)"
if [ "$uniq_n" = 3 ] && ! printf '%s' "$names" | grep -qx 'banhcuon'; then
  echo "  ok   ba gói ba database khác nhau, không gói nào dùng database mẫu"
else
  echo "  FAIL database của các gói: $(printf '%s' "$names" | tr '\n' ' ')"; fails=$((fails + 1))
fi
if [ "$bad_pair" = 0 ]; then echo "  ok   hai DSN của một gói cùng trỏ một database"
else echo "  FAIL DSN app và DSN chủ của một gói trỏ hai database"; fails=$((fails + 1)); fi
if [ "$missing_create" = 0 ] && [ "$ntest" = 3 ]; then echo "  ok   mỗi database của gói được sao từ database mẫu (CREATE DATABASE … TEMPLATE banhcuon)"
else echo "  FAIL thiếu lệnh CREATE DATABASE … TEMPLATE banhcuon cho ít nhất một gói"; fails=$((fails + 1)); fi

d="$TMPROOT/goido"; mkrepo_goi "$d" "banhcuon/be/internal/b"
out="$(run_goi "$d")"; rc=$?
log="$(cat "$d/fake.log" 2>/dev/null)"
if [ "$rc" != 0 ] && printf '%s\n' "$log" | grep -q '^gotest .*pkg=banhcuon/be/internal/c$' &&
   [[ "$out" == *"be-check: FAIL"* ]] && [[ "$out" == *"banhcuon/be/internal/b"* ]]; then
  echo "  ok   một gói đỏ ⇒ gói sau vẫn chạy, be-check đỏ và nêu tên gói (exit $rc)"
else
  echo "  FAIL gói đỏ — exit $rc; gói c $(printf '%s\n' "$log" | grep -q 'pkg=banhcuon/be/internal/c$' && echo 'có chạy' || echo 'KHÔNG chạy'); output: $(printf '%s' "$out" | tail -3 | tr '\n' ' ')"
  fails=$((fails + 1))
fi

if [ "$fails" -eq 0 ]; then
  echo "be-check.test: PASS"
else
  echo "be-check.test: FAIL — $fails ca"
  exit 1
fi
