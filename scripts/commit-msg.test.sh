#!/usr/bin/env bash
# Test cho Gate 8 (scripts/hooks/commit-msg) và scripts/install-hooks.sh.
#
# Chạy tay:  ./scripts/commit-msg.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Hai tầng:
#   A. gọi hook trực tiếp với một file nội dung — chấm đúng luật của nó;
#   B. dựng một repo git tạm, cài hook bằng install-hooks.sh, rồi `git commit`
#      thật — chấm rằng nó thật sự đứng giữa người gõ tay và git (F-011).

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/hooks/commit-msg"
INSTALL="$HERE/install-hooks.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0
n=0

# Tầng A chạy NGOÀI mọi repo git: luật 4 (F-031) so subject với lịch sử của repo
# ở thư mục hiện tại, và ca của tầng A không được đỏ chỉ vì lịch sử thật của repo
# này tình cờ có cùng một subject.
cd "$TMPROOT" || exit 1
DIR="$TMPROOT"

# --- tầng A — gọi hook trực tiếp --------------------------------------------
msg() { # msg <exit mong đợi> <tên ca> <nội dung commit…>   (chạy trong $DIR)
  local want="$1" name="$2"; shift 2
  n=$((n + 1))
  local f="$TMPROOT/msg.$n"
  printf '%s\n' "$@" > "$f"
  local out rc
  out="$(cd "$DIR" && "$HOOK" "$f" 2>&1)"; rc=$?
  if [ "$rc" = "$want" ]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want, nhận $rc: $(printf '%s' "$out" | tr '\n' ' ')"
    fails=$((fails + 1))
  fi
}

echo "[test] hooks/commit-msg"

# Năm subject thật đã vào repo này (work/findings.md F-011) — tất cả phải chết.
msg 1 "F-011: dsfg"  "dsfg"
msg 1 "F-011: adg"   "adg"
msg 1 "ADR-004: ádg" "ádg"
msg 1 "ADR-004: sdgf" "sdgf"
msg 1 "ADR-004: sdfg" "sdfg"

# Rỗng nghĩa ở các hình dạng khác.
msg 1 "một từ dài"        "asdfghjklqwerty"
msg 1 "mã task + một từ"  "T-025: adg"
msg 1 "chỉ có mã task"    "T-025:"

# Subject hợp lệ.
msg 0 "L1 có mã task"     "T-025: chặn subject rỗng nghĩa bằng commit-msg hook"
msg 0 "L0 hai từ tối thiểu" "Fix typo"
msg 0 "L0 không mã task"  "Sửa chính tả trong README"
msg 0 "mã task hai chữ số" "T-25: sửa chính tả"

# Nội dung git tự sinh — không chấm.
msg 0 "merge commit"  "Merge branch 'main' into merge_first_time"
msg 0 "revert commit" "Revert \"T-025: chặn subject rỗng nghĩa\""
msg 0 "fixup!"        "fixup! T-025: chặn subject"

# Comment và dòng trống ở đầu không được nhận nhầm là subject.
msg 0 "bỏ qua comment ở đầu" "# lời nhắc của git" "" "T-025: chặn subject rỗng nghĩa"
msg 1 "subject nằm sau comment vẫn bị chấm" "# lời nhắc của git" "adg"

# Nội dung toàn comment: git tự huỷ commit, hook không nói thêm.
msg 0 "toàn comment" "# nothing here"

# Subject > 72 ký tự: NHẮC, không chặn (ADR-003 — không đỏ vì lý do sai).
long="T-025: chặn subject rỗng nghĩa bằng một commit-msg hook của git, cài qua core.hooksPath"
n=$((n + 1)); f="$TMPROOT/msg.long"; printf '%s\n' "$long" > "$f"
out="$("$HOOK" "$f" 2>&1)"; rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'nhắc, KHÔNG chặn'; then
  echo "  ok   subject dài chỉ bị nhắc (exit 0)"
else
  echo "  FAIL subject dài — mong đợi exit 0 + lời nhắc, nhận exit $rc: $out"
  fails=$((fails + 1))
fi

# Thông báo lỗi PHẢI nói ra đường thoát, nếu không hook bị gỡ chứ không được sửa.
n=$((n + 1)); f="$TMPROOT/msg.esc"; printf 'adg\n' > "$f"
out="$("$HOOK" "$f" 2>&1)"
if printf '%s' "$out" | grep -q -- '--no-verify' && printf '%s' "$out" | grep -q 'F-011'; then
  echo "  ok   thông báo lỗi nêu --no-verify và F-011"
else
  echo "  FAIL thông báo lỗi thiếu --no-verify hoặc F-011: $out"
  fails=$((fails + 1))
fi

# File nội dung không đọc được ⇒ không chặn.
out="$("$HOOK" "$TMPROOT/khong-ton-tai" 2>&1)"; rc=$?
if [ "$rc" = 0 ]; then echo "  ok   thiếu file nội dung ⇒ không chặn"
else echo "  FAIL thiếu file nội dung — mong đợi exit 0, nhận $rc"; fails=$((fails + 1)); fi

# Luật 4 — subject trùng một commit đã có (work/findings.md F-031, ADR-062).
# Dựng một repo tạm có ba commit, rồi gọi hook trong đó.
hist="$TMPROOT/hist"
mkdir -p "$hist"
git -C "$hist" init -q
git -C "$hist" config user.email t@t
git -C "$hist" config user.name t
DIR="$hist"
msg 0 "repo chưa có commit nào ⇒ không so" "T-020: đơn mang đi được trả trước"
for s in "T-020: đơn mang đi được trả trước" "BA-09: chốt phạm vi MVP" "T-030: thêm một dòng nữa"; do
  git -C "$hist" commit -q --allow-empty --no-verify -m "$s"
done
msg 1 "F-031: trùng subject của HEAD"          "T-030: thêm một dòng nữa"
msg 1 "F-031: trùng subject của commit cũ"     "T-020: đơn mang đi được trả trước"
msg 1 "F-031: subject không mã task cũng so"   "BA-09: chốt phạm vi MVP"
msg 1 "F-031: khoảng trắng ở hai đầu không cứu" "  T-030: thêm một dòng nữa  "
msg 0 "chỉ trùng một phần ⇒ qua"               "T-030: thêm một dòng nữa, lần này khác"
msg 0 "cùng mã task, khác mô tả ⇒ qua"         "T-020: sửa lời nhắc trả trước"
msg 0 "revert của chính commit ấy ⇒ không so"  "Revert \"T-030: thêm một dòng nữa\""
n=$((n + 1)); f="$TMPROOT/msg.dup"; printf 'T-020: đơn mang đi được trả trước\n' > "$f"
out="$(cd "$hist" && "$HOOK" "$f" 2>&1)"
want_hash="$(git -C "$hist" log --format=%h --reverse | head -1)"
if printf '%s' "$out" | grep -q "$want_hash" && printf '%s' "$out" | grep -q 'F-031' \
   && printf '%s' "$out" | grep -q -- '--no-verify'; then
  echo "  ok   lời từ chối nêu hash commit cũ, F-031 và --no-verify"
else
  echo "  FAIL lời từ chối thiếu hash cũ ($want_hash), F-031 hoặc --no-verify: $out"
  fails=$((fails + 1))
fi
DIR="$TMPROOT"

# --- tầng B — commit thật qua install-hooks.sh -------------------------------
echo "[test] install-hooks.sh + git commit thật"

repo="$TMPROOT/repo"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" config user.email t@t
git -C "$repo" config user.name t
mkdir -p "$repo/scripts/hooks"
cp "$HOOK" "$repo/scripts/hooks/commit-msg"
cp "$INSTALL" "$repo/scripts/install-hooks.sh"
chmod +x "$repo/scripts/hooks/commit-msg" "$repo/scripts/install-hooks.sh"

# Chưa cài: --check phải đỏ.
( cd "$repo" && ./scripts/install-hooks.sh --check >/dev/null 2>&1 )
if [ $? -ne 0 ]; then echo "  ok   --check đỏ khi chưa cài"
else echo "  FAIL --check xanh khi chưa cài"; fails=$((fails + 1)); fi

( cd "$repo" && ./scripts/install-hooks.sh >/dev/null 2>&1 ) || {
  echo "  FAIL install-hooks.sh chạy lỗi"; fails=$((fails + 1)); }

( cd "$repo" && ./scripts/install-hooks.sh --check >/dev/null 2>&1 )
if [ $? -eq 0 ]; then echo "  ok   --check xanh sau khi cài"
else echo "  FAIL --check vẫn đỏ sau khi cài"; fails=$((fails + 1)); fi

echo hi > "$repo/a.txt"
git -C "$repo" add a.txt

# Đây là ca thật sự của F-011: người gõ tay, không đi qua lượt nào của phiên.
if git -C "$repo" commit -m "dsfg" >/dev/null 2>&1; then
  echo "  FAIL 'git commit -m dsfg' vẫn vào được repo"
  fails=$((fails + 1))
else
  echo "  ok   'git commit -m dsfg' bị git từ chối"
fi

if git -C "$repo" commit -m "T-025: thêm file a.txt để thử cổng" >/dev/null 2>&1; then
  echo "  ok   subject hợp lệ commit được"
else
  echo "  FAIL subject hợp lệ vẫn bị chặn"
  fails=$((fails + 1))
fi

# `core.hooksPath` là đường dẫn TƯƠNG ĐỐI. Nếu git giải nó theo thư mục hiện tại
# thay vì theo gốc cây làm việc thì hook im lặng biến mất khi ai đó commit từ một
# thư mục con — đúng kiểu hỏng không ai phát hiện cho tới lần thứ sáu.
mkdir -p "$repo/sub"
echo hi > "$repo/sub/c.txt"
git -C "$repo" add sub/c.txt
if ( cd "$repo/sub" && git commit -m "adg" >/dev/null 2>&1 ); then
  echo "  FAIL commit 'adg' từ thư mục con vẫn vào được"
  fails=$((fails + 1))
else
  echo "  ok   commit 'adg' từ thư mục con cũng bị chặn"
fi
if ( cd "$repo/sub" && git commit -m "T-025: thêm c.txt từ thư mục con" >/dev/null 2>&1 ); then
  echo "  ok   subject hợp lệ commit được từ thư mục con"
else
  echo "  FAIL subject hợp lệ bị chặn khi commit từ thư mục con"
  fails=$((fails + 1))
fi

# F-031 bằng commit thật: chép subject của commit vừa làm là ca phổ biến nhất
# (bốn trong năm nhóm trùng của repo này nằm sát nhau, cách vài phút).
echo hi3 > "$repo/d.txt"
git -C "$repo" add d.txt
if git -C "$repo" commit -m "T-025: thêm c.txt từ thư mục con" >/dev/null 2>&1; then
  echo "  FAIL commit chép subject của HEAD vẫn vào được"
  fails=$((fails + 1))
else
  echo "  ok   commit chép subject của HEAD bị git từ chối"
fi
if git -C "$repo" commit -m "T-025: thêm d.txt để thử luật trùng" >/dev/null 2>&1; then
  echo "  ok   subject mới commit được"
else
  echo "  FAIL subject mới vẫn bị chặn"
  fails=$((fails + 1))
fi

# --amend THAY HEAD chứ không thêm commit đứng cạnh nó: giữ subject phải qua.
echo hi4 >> "$repo/d.txt"
git -C "$repo" add d.txt
if git -C "$repo" commit --amend -m "T-025: thêm d.txt để thử luật trùng" >/dev/null 2>&1; then
  echo "  ok   --amend giữ nguyên subject của HEAD vẫn qua"
else
  echo "  FAIL --amend giữ nguyên subject của HEAD bị chặn"
  fails=$((fails + 1))
fi
if ( cd "$repo" && git commit --amend --no-edit >/dev/null 2>&1 ); then
  echo "  ok   --amend --no-edit vẫn qua"
else
  echo "  FAIL --amend --no-edit bị chặn"
  fails=$((fails + 1))
fi
# …nhưng amend thành subject của một commit CŨ HƠN vẫn là trùng.
if git -C "$repo" commit --amend -m "T-025: thêm file a.txt để thử cổng" >/dev/null 2>&1; then
  echo "  FAIL --amend thành subject của commit cũ hơn vẫn vào được"
  fails=$((fails + 1))
else
  echo "  ok   --amend thành subject của commit cũ hơn bị chặn"
fi

echo hi2 > "$repo/b.txt"
git -C "$repo" add b.txt
if git -C "$repo" commit --no-verify -m "dsfg" >/dev/null 2>&1; then
  echo "  ok   --no-verify vẫn là đường thoát"
else
  echo "  FAIL --no-verify không đi qua được"
  fails=$((fails + 1))
fi

if [ "$fails" -eq 0 ]; then
  echo "[test] commit-msg: tất cả ca đều đạt"
  exit 0
fi
echo "[test] commit-msg: $fails ca hỏng"
exit 1
