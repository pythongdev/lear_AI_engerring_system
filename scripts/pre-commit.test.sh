#!/usr/bin/env bash
# Test cho Gate 9 (scripts/hooks/pre-commit, F-025, T-208).
#
# Chạy tay:  ./scripts/pre-commit.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Dựng một repo git tạm có scripts/check-scope.sh thật và vài file work/scope/*.txt, stage từng tổ hợp
# file rồi gọi hook; ca cuối cài hook bằng install-hooks.sh và `git commit` thật.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

R="$TMPROOT/repo"
mkdir -p "$R/scripts/hooks" "$R/work/scope" "$R/a" "$R/b"
cp "$HERE/check-scope.sh" "$R/scripts/"
cp "$HERE/hooks/pre-commit" "$HERE/hooks/commit-msg" "$R/scripts/hooks/"
cp "$HERE/install-hooks.sh" "$R/scripts/"
cd "$R" || exit 1
git init -q && git config user.email t@t && git config user.name t
printf 'work/scope/\n' > .gitignore
echo 1 > a/x.txt; echo 1 > b/y.txt; echo 1 > c.txt
git add -A && git commit -q -m "nền của test pre-commit" --no-verify

ca() { # ca <exit mong đợi> <tên ca> <file stage…>
  local want="$1" name="$2"; shift 2
  git reset -q
  local f; for f in "$@"; do echo "$RANDOM" >> "$f"; git add "$f"; done
  local out rc; out="$(scripts/hooks/pre-commit 2>&1)"; rc=$?
  if [ "$rc" = "$want" ]; then echo "  ok   $name (exit $rc)"
  else echo "  FAIL $name — mong đợi exit $want, nhận $rc: $(printf '%s' "$out" | tr '\n' ' ')"; fails=$((fails + 1)); fi
  git checkout -q -- . 2>/dev/null; git reset -q
}

echo "[test] hooks/pre-commit"
ca 0 "không file scope nào ⇒ không chặn" a/x.txt b/y.txt
printf 'a/\n' > work/scope/T-1.txt
printf 'b/\n# chỉ chú thích ở dưới\n' > work/scope/T-2.txt
printf '# chỉ chú thích\n' > work/scope/T-3.txt
ca 0 "không file nào staged ⇒ không chặn"
ca 0 "mọi file trong scope một task" a/x.txt
ca 1 "F-025: file của hai task trong một commit" a/x.txt b/y.txt
ca 1 "file không thuộc task nào" c.txt
printf 'a/\nb/\n' > work/scope/T-4.txt
ca 0 "một task khai cả hai thư mục" a/x.txt b/y.txt
printf 'a/\n!a/x.txt\n' > work/scope/T-4.txt
ca 1 "dòng ! của task chặn chính nó" a/x.txt b/y.txt
out="$(git reset -q; echo z >> a/x.txt; echo z >> b/y.txt; git add a/x.txt b/y.txt; scripts/hooks/pre-commit 2>&1)"
if printf '%s' "$out" | grep -qE 'a/x.txt  ← T-1|b/y.txt  ← T-2'; then
  echo "  ok   lời từ chối nêu task của file ngoài scope"
else echo "  FAIL lời từ chối không nêu task của file ngoài scope: $out"; fails=$((fails + 1)); fi
git checkout -q -- .; git reset -q

# T-241: ba file, task gần nhất phủ hai — chỉ file thừa được nêu, kèm đúng lệnh gỡ.
printf 'a/\nc.txt\n' > work/scope/T-5.txt
out="$(git reset -q; echo v >> a/x.txt; echo v >> b/y.txt; echo v >> c.txt; git add a/x.txt b/y.txt c.txt; scripts/hooks/pre-commit 2>&1)"
if printf '%s' "$out" | grep -q 'Gần nhất là T-5: 2/3' \
   && printf '%s' "$out" | grep -qx '  Commit cho T-5: git restore --staged b/y.txt' \
   && ! printf '%s' "$out" | grep -q 'a/x.txt  ←'; then
  echo "  ok   lời từ chối chỉ nêu file ngoài task gần nhất và lệnh gỡ"
else echo "  FAIL lời từ chối không chỉ thẳng file thừa: $out"; fails=$((fails + 1)); fi
git checkout -q -- .; git reset -q; rm -f work/scope/T-5.txt

# Tầng thật: cài hook rồi git commit.
./scripts/install-hooks.sh >/dev/null 2>&1
echo w >> a/x.txt; echo w >> b/y.txt; git add a/x.txt b/y.txt
if git commit -q -m "gộp hai task vào một commit" >/dev/null 2>&1; then
  echo "  FAIL git commit thật nhặt file hai task mà không bị chặn"; fails=$((fails + 1))
else echo "  ok   git commit thật bị chặn"; fi
if git commit -q --no-verify -m "gộp có chủ ý, đi qua lối thoát" >/dev/null 2>&1; then
  echo "  ok   --no-verify đi qua"
else echo "  FAIL --no-verify không đi qua"; fails=$((fails + 1)); fi

if [ "$fails" -eq 0 ]; then echo "pre-commit.test: PASS"; exit 0; fi
echo "pre-commit.test: FAIL — $fails ca"; exit 1
