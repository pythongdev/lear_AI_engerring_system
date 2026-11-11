#!/usr/bin/env bash
# T-320: fixture và lịch sử git thật đều ở repo tạm; không áp dụng vào backlog thật.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)" || exit 1
trap 'rm -rf -- "$tmp"' EXIT
repo="$tmp/repo"
mkdir -p "$repo/scripts" "$repo/work"
cp "$here/archive-done.sh" "$repo/scripts/"
cd "$repo" || exit 1
git init -q
git config user.name Test
git config user.email test@example.test
echo base > marker
git add marker
git -c core.hooksPath=/dev/null commit -qm 'nền cho archive-done'
for id in T-1 CHAT-17 T-4 T-5; do
  echo "$id" >> marker
  git add marker
  git -c core.hooksPath=/dev/null commit -qm "$id: ghi thay đổi của task"
done
cat > work/backlog.md <<'EOF'
<a id="ready"></a>
## Ready

- [ ] T-9 còn chờ

## In Progress

- [x] T-1 đã xong · [chi tiết](#t-1)
- [x] T-2 chưa commit
- [ ] T-3 chưa tick
- [x] CHAT-17 chỉ có dòng · [mô tả](#chat-17)
- [x] T-4 trùng Done
- [x] T-5 trùng khối
ghi chú In Progress: [khối chuyển](#t-8), [neo chết cũ](#khong-co)

## Done

- [x] T-4 dòng Done thứ nhất
- [x] T-4 dòng Done thứ hai
- [x] T-6 neo trùng · [chi tiết](#t-6)
- [x] T-8 khối lạc · [chi tiết](#t-8)

## Chi tiết — việc cần làm

<a id="t-1"></a>
### T-1 — Khối chính

Đến [khối cũ](backlog_archive.md#arc), [khối mới](#t-8), [khối giữ](#t-7).

<a id="t-5"></a>
### T-5 — Khối thứ nhất

Không chuyển: [khối chuyển](#t-1), [neo chết cũ](#khong-co).

<a id="t-5-b"></a>
### T-5 — Khối thứ hai

Không chuyển.

<a id="t-6"></a>
### T-6 — Neo đã ở archive

Không chuyển.

<a id="t-7"></a>
### T-7 — Không có dòng Done

Không chuyển.

## Task Detail Template

Khuôn giữ từng byte.

<a id="t-8"></a>
### T-8 — Khối nằm lạc

Chuyển cả khi nằm dưới template.

EOF
cat > work/backlog_archive.md <<'EOF'
# Archive cũ

<a id="chi-tiet-da-xong"></a>
## Chi tiết — việc đã xong

<a id="arc"></a>
### ARC — Giữ nguyên

Một dòng cũ.

<a id="t-6"></a>
### T-6 — Neo có sẵn

Một dòng cũ nữa.
EOF
cp work/backlog.md "$tmp/backlog.before"
cp work/backlog_archive.md "$tmp/archive.before"
fails=0
check() {
  local name="$1"; shift
  if "$@"; then printf '  ok   %s\n' "$name"
  else printf '  FAIL %s\n' "$name"; fails=$((fails + 1)); fi
}
has() { printf '%s\n' "$output" | grep -Fq -- "$1"; }

output="$(./scripts/archive-done.sh)"; rc=$?
check 'dry-run: thoát 0' test "$rc" -eq 0
check 'dry-run: danh sách sẽ chuyển nêu dòng và khối' has 'T-1 — dòng, khối mô tả'
check 'dry-run: mã chỉ có dòng' has 'CHAT-17 — dòng'
check 'dry-run: khối lạc vẫn được liệt kê' has 'T-8 — khối mô tả'
check 'dry-run: danh sách bị giữ nêu chưa commit' has 'T-2 — chưa có commit mang mã'
check 'dry-run: danh sách bị giữ nêu trùng Done' has 'T-4 — mã có hai dòng Done'
check 'dry-run: danh sách bị giữ nêu trùng khối' has 'T-5 — mã có hai khối mô tả'
check 'dry-run: danh sách bị giữ nêu neo trùng' has 'T-6 — neo đã tồn tại trong archive'
check 'dry-run: danh sách bị giữ nêu không có Done' has 'T-7 — khối không có dòng của mã ở Done'
check 'dry-run: backlog không đổi byte' cmp -s work/backlog.md "$tmp/backlog.before"
check 'dry-run: archive không đổi byte' cmp -s work/backlog_archive.md "$tmp/archive.before"

cat > "$tmp/backlog.want" <<'EOF'
<a id="ready"></a>
## Ready

- [ ] T-9 còn chờ

## In Progress

- [x] T-2 chưa commit
- [ ] T-3 chưa tick
- [x] T-4 trùng Done
- [x] T-5 trùng khối
ghi chú In Progress: [khối chuyển](backlog_archive.md#t-8), [neo chết cũ](#khong-co)

## Done

- [x] T-1 đã xong · [chi tiết](backlog_archive.md#t-1)
- [x] CHAT-17 chỉ có dòng · [mô tả](#chat-17)
- [x] T-4 dòng Done thứ nhất
- [x] T-4 dòng Done thứ hai
- [x] T-6 neo trùng · [chi tiết](#t-6)
- [x] T-8 khối lạc · [chi tiết](backlog_archive.md#t-8)

## Chi tiết — việc cần làm

<a id="t-5"></a>
### T-5 — Khối thứ nhất

Không chuyển: [khối chuyển](backlog_archive.md#t-1), [neo chết cũ](#khong-co).

<a id="t-5-b"></a>
### T-5 — Khối thứ hai

Không chuyển.

<a id="t-6"></a>
### T-6 — Neo đã ở archive

Không chuyển.

<a id="t-7"></a>
### T-7 — Không có dòng Done

Không chuyển.

## Task Detail Template

Khuôn giữ từng byte.

EOF
cat > "$tmp/archive.want" <<'EOF'
# Archive cũ

<a id="chi-tiet-da-xong"></a>
<a id="t-1"></a>
### T-1 — Khối chính

Đến [khối cũ](#arc), [khối mới](#t-8), [khối giữ](backlog.md#t-7).

<a id="t-8"></a>
### T-8 — Khối nằm lạc

Chuyển cả khi nằm dưới template.

## Chi tiết — việc đã xong

<a id="arc"></a>
### ARC — Giữ nguyên

Một dòng cũ.

<a id="t-6"></a>
### T-6 — Neo có sẵn

Một dòng cũ nữa.
EOF
output="$(./scripts/archive-done.sh --apply)"; rc=$?
check 'apply: thoát 0 và tóm tắt hai dòng, hai khối, byte trước sau' \
  sh -c 'test "$1" -eq 0 && printf "%s" "$2" | grep -Eq "2 dòng, 2 khối đã chuyển; work/backlog.md: [0-9]+ → [0-9]+ byte"' sh "$rc" "$output"
check 'phép 1: thứ tự dòng, dòng chưa commit và chưa tick, Done cũ không rút ngắn' \
  cmp -s work/backlog.md "$tmp/backlog.want"
check 'phép 2: khối lạc, nguyên văn và viết lại ba kiểu link, archive cũ giữ nguyên' \
  cmp -s work/backlog_archive.md "$tmp/archive.want"
check 'link trong khối ở lại trỏ archive, link chết cũ giữ nguyên' \
  grep -Fq 'Không chuyển: [khối chuyển](backlog_archive.md#t-1), [neo chết cũ](#khong-co).' work/backlog.md
check 'link ngoài khối ở lại trỏ archive, link chết cũ giữ nguyên' \
  grep -Fq 'ghi chú In Progress: [khối chuyển](backlog_archive.md#t-8), [neo chết cũ](#khong-co)' work/backlog.md
if ! cmp -s work/backlog.md "$tmp/backlog.want"; then diff -u "$tmp/backlog.want" work/backlog.md || true; fi
if ! cmp -s work/backlog_archive.md "$tmp/archive.want"; then diff -u "$tmp/archive.want" work/backlog_archive.md || true; fi
cp work/backlog.md "$tmp/backlog.once"
cp work/backlog_archive.md "$tmp/archive.once"
output="$(./scripts/archive-done.sh --apply)"; rc=$?
check 'apply lần hai: thoát 0 và không chuyển gì' \
  sh -c 'test "$1" -eq 0 && printf "%s" "$2" | grep -Fq "0 dòng, 0 khối đã chuyển"' sh "$rc" "$output"
check 'apply lần hai: hai file không đổi byte' \
  sh -c 'cmp -s work/backlog.md "$1" && cmp -s work/backlog_archive.md "$2"' sh "$tmp/backlog.once" "$tmp/archive.once"

for missing in progress done anchor; do
  cp "$tmp/backlog.once" work/backlog.md
  cp "$tmp/archive.once" work/backlog_archive.md
  case "$missing" in
    progress) sed 's/^## In Progress$/## Đã thiếu In Progress/' work/backlog.md > "$tmp/invalid"; mv "$tmp/invalid" work/backlog.md ;;
    done) sed 's/^## Done$/## Đã thiếu Done/' work/backlog.md > "$tmp/invalid"; mv "$tmp/invalid" work/backlog.md ;;
    anchor) sed 's/^<a id="chi-tiet-da-xong"><\/a>$/<a id="đã-thiếu"><\/a>/' work/backlog_archive.md > "$tmp/invalid"; mv "$tmp/invalid" work/backlog_archive.md ;;
  esac
  cp work/backlog.md "$tmp/bad.backlog"
  cp work/backlog_archive.md "$tmp/bad.archive"
  output="$(./scripts/archive-done.sh --apply 2>&1)"; rc=$?
  check "thiếu $missing: thoát khác 0 và báo lỗi" \
    sh -c 'test "$1" -ne 0 && printf "%s" "$2" | grep -Fq "archive-done: thiếu mục"' sh "$rc" "$output"
  check "thiếu $missing: không ghi file nào" \
    sh -c 'cmp -s work/backlog.md "$1" && cmp -s work/backlog_archive.md "$2"' sh "$tmp/bad.backlog" "$tmp/bad.archive"
done

# Ranh giới thật: neo của mục ## kế tiếp đứng sau link ↑ và một dòng trống.
boundary="$tmp/boundary"
mkdir -p "$boundary/work" "$boundary/scripts"
cp "$here/archive-done.sh" "$boundary/scripts/"
cd "$boundary" || exit 1
git init -q
git config user.name Test
git config user.email test@example.test
echo commit > marker
git add marker
git -c core.hooksPath=/dev/null commit -qm 'T-1: hoàn tất khối trước mục kế tiếp'
cat > work/backlog.md <<'EOF'
<a id="top"></a>
## In Progress

- [x] T-1 xong · [chi tiết](#t-1)

## Done

## Chi tiết — việc cần làm

[Xem vòng chạy](#vong-chay)

<a id="t-1"></a>
### T-1 — Khối cuối mục

Nội dung khối.

[↑ đầu file](#top)

<a id="vong-chay"></a>
## Vòng chạy một task L1 — mười bước

[Đọc lại vòng chạy](#vong-chay)
EOF
cat > work/backlog_archive.md <<'EOF'
<a id="chi-tiet-da-xong"></a>
## Chi tiết — việc đã xong
EOF
output="$(./scripts/archive-done.sh --apply)"; rc=$?
check 'ranh giới neo mục kế tiếp: apply thoát 0' test "$rc" -eq 0
check 'ranh giới neo mục kế tiếp: neo còn nguyên trong backlog' \
  grep -Fxq '<a id="vong-chay"></a>' work/backlog.md
check 'ranh giới neo mục kế tiếp: hai link nội bộ còn mở được' \
  sh -c 'test "$(grep -Fc "](#vong-chay)" work/backlog.md)" -eq 2'
check 'ranh giới neo mục kế tiếp: neo không bị chuyển sang archive' \
  sh -c '! grep -Fq '\''<a id="vong-chay"></a>'\'' work/backlog_archive.md'

# Neo lệch mã và tiêu đề task thiếu neo (hình thật ở work/backlog.md 2026-11-11: neo t-259 đứng
# trước `### T-260`, còn `### T-259` — việc đang mở — không có neo). Khối T-260 phải bị giữ lại, và
# khối của việc đang mở không bao giờ bị cuốn theo khối đứng trước nó.
echo neo-lech >> marker
git add marker
git -c core.hooksPath=/dev/null commit -qm 'T-260: xong việc có neo đặt lệch'
git -c core.hooksPath=/dev/null commit -q --allow-empty -m 'T-261: xong việc đứng trước khối thiếu neo'
cat > work/backlog.md <<'EOF'
## In Progress

- [ ] T-259 đang mở · [chi tiết](#t-259)

## Done

- [x] T-260 đã xong · [chi tiết](#t-260)
- [x] T-261 đã xong · [chi tiết](#t-261)

## Chi tiết — việc cần làm

<a id="t-261"></a>
### T-261 — Khối chuyển được, đứng trước khối thiếu neo

Nội dung T-261.

### T-262 — Khối thiếu neo của việc không có dòng

Nội dung T-262.

<a id="t-259"></a>
### T-260 — Khối mang neo của mã khác

Nội dung T-260.

### T-259 — Khối của việc đang mở, thiếu neo

Nội dung T-259.
EOF
cat > work/backlog_archive.md <<'EOF'
<a id="chi-tiet-da-xong"></a>
## Chi tiết — việc đã xong
EOF
output="$(./scripts/archive-done.sh)"
check 'neo lệch mã: chạy thử nêu lý do giữ T-260' \
  sh -c 'printf "%s\n" "$1" | grep -Fq "T-260 — neo t-259 không khớp mã"' sh "$output"
output="$(./scripts/archive-done.sh --apply)"; rc=$?
check 'neo lệch mã: apply thoát 0' test "$rc" -eq 0
check 'neo lệch mã: khối T-260 ở lại backlog' grep -Fxq 'Nội dung T-260.' work/backlog.md
check 'neo lệch mã: khối của việc đang mở T-259 ở lại backlog' grep -Fxq 'Nội dung T-259.' work/backlog.md
check 'neo lệch mã: link của dòng T-259 không đổi' grep -Fq '](#t-259)' work/backlog.md
check 'tiêu đề thiếu neo: khối T-261 đã sang archive' grep -Fxq 'Nội dung T-261.' work/backlog_archive.md
check 'tiêu đề thiếu neo: khối T-262 không bị cuốn theo' grep -Fxq 'Nội dung T-262.' work/backlog.md
check 'tiêu đề thiếu neo: archive không có T-262 hay T-259' \
  sh -c '! grep -Eq "Nội dung T-(262|259)\\." work/backlog_archive.md'

if [ "$fails" -eq 0 ]; then echo 'archive-done.test: PASS'; exit 0; fi
echo "archive-done.test: FAIL — $fails ca"; exit 1
