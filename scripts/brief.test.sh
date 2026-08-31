#!/usr/bin/env bash
# Test cho scripts/brief.sh — phần CẢNH BÁO "scope chưa dọn" (T-016 · ADR-006).
#
# Chạy tay:  ./scripts/brief.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Hai trạng thái phải phân biệt được, nếu không thì cảnh báo là tiếng ồn:
#   scope đã khai + CÓ task In Progress    → bình thường, im
#   scope đã khai + KHÔNG có task nào      → scope của task đã xong chưa dọn, kêu
# Và một luật không được vi phạm ở bất kỳ ca nào: brief luôn exit 0 (CLAUDE.md §7.1).
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/brief.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

MARK="CẢNH BÁO"

# newrepo <tên> <in-progress: yes|no>
newrepo() {
  local d="$TMPROOT/$1"
  mkdir -p "$d/work" && git -C "$d" init -q
  git -C "$d" config user.email t@t && git -C "$d" config user.name t
  {
    echo "# Backlog"
    echo
    echo "## Ready"
    echo
    echo "- [ ] T-002 việc kế tiếp"
    echo
    echo "## In Progress"
    echo
    [ "$2" = "yes" ] && echo "- [ ] T-001 đang chạy"
    echo
    echo "## Done"
  } > "$d/work/backlog.md"
  echo "# scope" > "$d/work/scope.txt"
  mkdir -p "$d/docs"
  : > "$d/docs/product.md"
  git -C "$d" add -A >/dev/null 2>&1
  git -C "$d" commit -qm init >/dev/null 2>&1
  printf '%s' "$d"
}

# setscope <repo> <pattern>...
setscope() {
  local d="$1"; shift
  { echo "# scope"; printf '%s\n' "$@"; } > "$d/work/scope.txt"
}

# brief <repo> — chạy brief.sh, đặt $rc và $out.
# Không dùng out="$(brief …)": lệnh thay thế chạy trong subshell, $rc mất theo nó.
BOUT="$TMPROOT/out.txt"
rc=0
out=""
brief() {
  ( cd "$1" && "$SCRIPT" 2>/dev/null ) > "$BOUT"
  rc=$?
  out="$(cat "$BOUT")"
}

want() { # want <tên ca> <yes|no có MARK> <output>
  case "$3" in
    *"$MARK"*) got=yes ;;
    *) got=no ;;
  esac
  if [ "$got" = "$2" ]; then
    echo "  ok   $1 (cảnh báo=$got)"
  else
    echo "  FAIL $1 — mong đợi cảnh báo=$2, nhận $got"; fails=$((fails + 1))
  fi
}

exit0() { # exit0 <tên ca> <rc>
  if [ "$2" = "0" ]; then
    echo "  ok   $1 exit 0"
  else
    echo "  FAIL $1 — brief phải luôn exit 0, nhận $2"; fails=$((fails + 1))
  fi
}

echo "=== brief.sh — cảnh báo scope chưa dọn ==="

# B1. scope còn pattern + KHÔNG có task In Progress → kêu, nêu đích danh và số pattern
r="$(newrepo b1 no)"; setscope "$r" "docs/x.md" "scripts/"
brief "$r"
want "B1 scope bẩn, không có In Progress" yes "$out"
exit0 "B1" "$rc"
case "$out" in
  *"work/scope.txt còn 2 pattern"*) echo "  ok   B1 nêu đích danh file và đếm đúng 2 pattern" ;;
  *) echo "  FAIL B1 — không nêu 'work/scope.txt còn 2 pattern'"; fails=$((fails + 1)) ;;
esac

# B2. cùng scope đó + CÓ task In Progress → im, và giữ nguyên dòng cũ
r="$(newrepo b2 yes)"; setscope "$r" "docs/x.md" "scripts/"
brief "$r"
want "B2 scope bẩn, có In Progress" no "$out"
exit0 "B2" "$rc"
case "$out" in
  *"a task is open"*) echo "  ok   B2 vẫn in dòng 'a task is open'" ;;
  *) echo "  FAIL B2 — mất dòng 'a task is open'"; fails=$((fails + 1)) ;;
esac

# B3. scope rỗng (chỉ comment) → im ở CẢ HAI trạng thái backlog
r="$(newrepo b3a no)"
brief "$r"; want "B3 scope rỗng, không có In Progress" no "$out"; exit0 "B3a" "$rc"
r="$(newrepo b3b yes)"
brief "$r"; want "B3 scope rỗng, có In Progress" no "$out"; exit0 "B3b" "$rc"

# B4. brief không bao giờ chặn, kể cả khi backlog.md biến mất
r="$(newrepo b4 no)"; setscope "$r" "docs/x.md"
rm -f "$r/work/backlog.md"
brief "$r"
exit0 "B4 mất work/backlog.md" "$rc"

# B5. không phải repo git → vẫn exit 0
d="$TMPROOT/b5"; mkdir -p "$d"
( cd "$d" && "$SCRIPT" >/dev/null 2>&1 ); exit0 "B5 ngoài repo git" "$?"

# --- OPEN UNKNOWNS: đọc cấu trúc, không đọc hình dạng dòng (T-021 · ADR-007) ---
#
# F-008 hỏng HAI chiều cùng lúc, nên phải có ca cho cả hai:
#   giấu câu đang mở  — một dấu `*` chen giữa gạch đầu dòng và định danh;
#   khoe câu đã đóng  — một dòng văn xuôi tình cờ bắt đầu bằng `U-004`.
# Ca nào cũng đòi brief exit 0 (CLAUDE.md §7.1).

# unknowns <repo> <nội dung mục Unknowns…> — ghi docs/product.md rồi chạy brief.
unknowns() {
  local d="$1"; shift
  { echo "# Product"; echo; echo "## Unknowns"; echo; printf '%s\n' "$@"; } > "$d/docs/product.md"
  brief "$d"
  # Chỉ lấy phần thân mục OPEN UNKNOWNS, không lấy dòng tiêu đề mục.
  u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
}

has() { # has <tên ca> <chuỗi phải CÓ trong mục Unknowns>
  case "$u" in
    *"$2"*) echo "  ok   $1" ;;
    *) echo "  FAIL $1 — mong đợi thấy '$2', nhận:"; printf '%s\n' "$u" | sed 's/^/         /'
       fails=$((fails + 1)) ;;
  esac
}

hasnt() { # hasnt <tên ca> <chuỗi KHÔNG được có>
  case "$u" in
    *"$2"*) echo "  FAIL $1 — không được thấy '$2', nhận:"; printf '%s\n' "$u" | sed 's/^/         /'
            fails=$((fails + 1)) ;;
    *) echo "  ok   $1" ;;
  esac
}

echo "=== brief.sh — OPEN UNKNOWNS đọc theo cấu trúc ==="

r="$(newrepo u1 yes)"

# U1. Chiều "giấu câu đang mở": in đậm chen vào giữa `- ` và định danh.
#     Đây đúng là hình dạng đã giấu U-005 suốt nhiều phiên.
unknowns "$r" "### Đang mở" "" "- **U-005 — ai xác nhận đã nhận tiền?**"
has   "U1 in đậm chen trước định danh vẫn thấy U-005" "U-005"
exit0 "U1" "$rc"

# U2. Chiều "khoe câu đã đóng": văn xuôi dưới một tiêu đề ### khác.
unknowns "$r" "### Đang mở" "" "- U-005 — câu đang mở" "" \
  "### Đã có lời giải" "" "U-004 — câu này đã đóng từ lâu, chỉ đang kể lại."
has   "U2 vẫn thấy câu đang mở" "U-005"
hasnt "U2 KHÔNG thấy câu đã đóng ở vùng khác" "U-004"
exit0 "U2" "$rc"

# U3. Văn xuôi ngay trong vùng mở: không gạch đầu dòng thì không phải unknown.
unknowns "$r" "### Đang mở" "" "- U-005 — câu đang mở" "" \
  "U-006 — câu này chỉ được nhắc trong văn xuôi, chưa mở."
has   "U3 vẫn thấy U-005" "U-005"
hasnt "U3 văn xuôi không sinh ra unknown" "U-006"
exit0 "U3" "$rc"

# U3b. Gạch đầu dòng dưới một tiêu đề ### khác — chỗ docs/product.md để hợp đồng.
unknowns "$r" "### Đang mở" "" "- U-005 — câu đang mở" "" \
  "### Cách viết một câu ở đây" "" "- Ví dụ: viết \`U-009\` ở đây cũng không sao."
has   "U3b vẫn thấy U-005" "U-005"
hasnt "U3b gạch đầu dòng ở tiêu đề khác không được đọc" "U-009"
exit0 "U3b" "$rc"

# U4. Vắt dòng + tiêu đề dài: nối lại thành MỘT mục, và cắt ở ranh giới từ.
#     substr() ở đây đếm byte, nên cắt sai là xẻ đôi một chữ tiếng Việt — bản
#     đầu của T-021 chết đúng chỗ này ("towc: multibyte conversion failure").
unknowns "$r" "### Đang mở" "" \
  "- U-005 — **đơn khách trả trước thì trả bằng gì, ai bấm xác nhận đã nhận tiền," \
  "  và vào lúc nào?** Đơn thu lúc trao hàng thì người trao hàng bấm, còn đơn trả" \
  "  trước thì không có nhân viên nào đứng đối diện khách."
n="$(printf '%s\n' "$u" | grep -c 'U-005')"
if [ "$n" = "1" ]; then echo "  ok   U4 ba dòng vắt lại thành một mục"
else echo "  FAIL U4 — mong đợi 1 mục U-005, nhận $n"; fails=$((fails + 1)); fi
hasnt "U4 không lộ byte hỏng" "towc"
hasnt "U4 không lộ lỗi awk" "multibyte"
case "$u" in
  *"đơn khách trả trước"*) echo "  ok   U4 giữ được đầu tiêu đề" ;;
  *) echo "  FAIL U4 — mất đầu tiêu đề"; fails=$((fails + 1)) ;;
esac
exit0 "U4" "$rc"

# U5. Vùng mở rỗng → (none), KHÔNG được rơi xuống đọc vùng đã đóng.
unknowns "$r" "### Đang mở" "" "Chưa còn câu nào mở." "" \
  "### Đã có lời giải" "" "- U-004 — đã đóng."
has   "U5 vùng mở rỗng in (none)" "(none)"
hasnt "U5 không rơi xuống vùng đã đóng" "U-004"
exit0 "U5" "$rc"

# U6. Không có tiêu đề '### Đang mở' — hình dạng cũ của file vẫn phải đọc được.
unknowns "$r" "- U-005 — câu đang mở, viết thẳng ở đầu mục." "" \
  "### Đã có lời giải" "" "- U-004 — đã đóng."
has   "U6 hình dạng cũ vẫn thấy U-005" "U-005"
hasnt "U6 hình dạng cũ vẫn không đọc vùng đã đóng" "U-004"
exit0 "U6" "$rc"

# U7. Không có mục Unknowns, và không có cả file → (none) + exit 0.
{ echo "# Product"; echo; echo "## 1. Actor"; echo; echo "- U-005 — ngoài mục Unknowns."; } \
  > "$r/docs/product.md"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
hasnt "U7 không đọc U- ngoài mục Unknowns" "U-005"
exit0 "U7 không có mục Unknowns" "$rc"
rm -f "$r/docs/product.md"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
has   "U7 mất docs/product.md vẫn in (none)" "(none)"
exit0 "U7 mất docs/product.md" "$rc"

if [ "$fails" -ne 0 ]; then
  echo "brief: $fails ca FAIL"; exit 1
fi
echo "brief: tất cả ca đều qua."
