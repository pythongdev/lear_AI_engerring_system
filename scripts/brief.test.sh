#!/usr/bin/env bash
# Test cho scripts/brief.sh — phần CẢNH BÁO "scope chưa dọn" (T-016 · ADR-006).
#
# Chạy tay:  ./scripts/brief.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh, nên gate cũng chạy nó khi scripts/ đổi.
#
# Mỗi task một file scope work/scope/<MÃ>.txt (T-085, ADR-063). Hai trạng thái
# phải phân biệt được, nếu không thì cảnh báo là tiếng ồn:
#   file scope của mã ĐANG ở In Progress     → bình thường, im
#   file scope của mã KHÔNG ở In Progress    → task đã Done, kêu đích danh mã đó
# Và một luật không được vi phạm ở bất kỳ ca nào: brief luôn exit 0 (CLAUDE.md §7.1).
#
# Mỗi ca dựng một repo git tạm để không đụng cây thật.

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/brief.sh"
CHECK_SCOPE="$(cd "$(dirname "$0")" && pwd)/check-scope.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0
# Hook Claude Code nạp khoảng 10 000 ký tự; ngày 2026-11-11 brief 141 KB
# khiến phiên chỉ thấy 2 KB đầu. Chừa khoảng trống cho chênh lệch byte/ký tự.
BRIEF_MAX_BYTES=9000

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
  mkdir -p "$d/docs/product"
  : > "$d/docs/product/99-unknowns.md"
  git -C "$d" add -A >/dev/null 2>&1
  git -C "$d" commit -qm init >/dev/null 2>&1
  mkdir -p "$d/scripts"
  cp "$CHECK_SCOPE" "$d/scripts/check-scope.sh"
  printf '%s' "$d"
}

# setscope <repo> <pattern>...  — file scope của T-001 (task In Progress của
# newrepo … yes); SCOPE_ID=<mã> để ghi cho task khác (T-085, ADR-063)
setscope() {
  local d="$1"; shift
  mkdir -p "$d/work/scope"
  { echo "# scope"; printf '%s\n' "$@"; } > "$d/work/scope/${SCOPE_ID:-T-001}.txt"
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

# B1. file scope của một mã KHÔNG ở In Progress → kêu, nêu đích danh mã và file
r="$(newrepo b1 no)"; echo "- [x] T-001 đã xong" >> "$r/work/backlog.md"; setscope "$r" "docs/x.md" "scripts/"
brief "$r"
want "B1 file scope của task không ở In Progress" yes "$out"
exit0 "B1" "$rc"
case "$out" in
  *"file scope không ở In Progress: T-001"*) echo "  ok   B1 nêu đích danh mã task" ;;
  *) echo "  FAIL B1 — không nêu T-001 trong cảnh báo orphan"; fails=$((fails + 1)) ;;
esac

# B1b. F-014 + T-085: cảnh báo không được ra lệnh xoá vô điều kiện — task Done mà
# chưa commit vẫn cần file scope cho Gate 7b. Xoá chỉ khi đã commit.
case "$out" in
  *"Nếu task đã commit: xoá file"*"giữ tới khi commit xong"*)
    echo "  ok   B1b chỉ bảo xoá khi đã commit, giữ khi chưa (F-014, T-085)" ;;
  *) echo "  FAIL B1b — thiếu điều kiện xoá/giữ theo commit"; fails=$((fails + 1)) ;;
esac

# B1c. hai task: file của task In Progress im, file của task khác kêu — chỉ nó
r="$(newrepo b1c yes)"; echo "- [x] T-007 đã xong" >> "$r/work/backlog.md"; setscope "$r" "docs/x.md"; SCOPE_ID=T-007 setscope "$r" "docs/y.md"
brief "$r"
case "$out" in
  *"file scope không ở In Progress: T-007"*) echo "  ok   B1c kêu đúng T-007" ;;
  *) echo "  FAIL B1c — không kêu T-007"; fails=$((fails + 1)) ;;
esac
case "$out" in
  *"T-001 không ở In Progress"*) echo "  FAIL B1c — kêu nhầm T-001 đang In Progress"; fails=$((fails + 1)) ;;
  *) echo "  ok   B1c không kêu T-001 đang In Progress" ;;
esac

# B1d. work/scope.txt còn pattern (cách khai cũ) → kêu, chỉ sang cơ chế mới
r="$(newrepo b1d yes)"; echo "docs/x.md" >> "$r/work/scope.txt"
brief "$r"
want "B1d work/scope.txt còn pattern" yes "$out"
exit0 "B1d" "$rc"

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

# unknowns <repo> <nội dung mục Unknowns…> — ghi docs/product/99-unknowns.md rồi
# chạy brief. Owner của mục Unknowns nay là file ấy, không phải bản lưu
# docs/product.md (DOC-2 · ADR-014).
unknowns() {
  local d="$1"; shift
  { echo "# Product"; echo; echo "## Unknowns"; echo; printf '%s\n' "$@"; } \
    > "$d/docs/product/99-unknowns.md"
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

# U3b. Gạch đầu dòng dưới một tiêu đề ### khác — chỗ 99-unknowns.md để hợp đồng.
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
  > "$r/docs/product/99-unknowns.md"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
hasnt "U7 không đọc U- ngoài mục Unknowns" "U-005"
exit0 "U7 không có mục Unknowns" "$rc"
rm -f "$r/docs/product/99-unknowns.md"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
has   "U7 mất docs/product/99-unknowns.md vẫn in (none)" "(none)"
exit0 "U7 mất docs/product/99-unknowns.md" "$rc"

# --- H. Cảnh báo Gate 8 chưa cài (T-025 · ADR-010 · F-011) -------------------
# `.git/` không theo `git clone`, nên một bản clone mới có file hook mà không có
# hook đang chạy. Brief là chỗ duy nhất nói ra được điều đó ở mỗi phiên.
echo "=== brief.sh — cảnh báo Gate 8 chưa cài ==="

HERE_DIR="$(cd "$(dirname "$0")" && pwd)"
r="$(newrepo h1 yes)"
mkdir -p "$r/scripts/hooks"
cp "$HERE_DIR/hooks/commit-msg" "$r/scripts/hooks/commit-msg"
cp "$HERE_DIR/install-hooks.sh" "$r/scripts/install-hooks.sh"
cp "$HERE_DIR/hooks/pre-commit" "$r/scripts/hooks/pre-commit"  # Gate 9 (T-208): --check đòi cả hook này
chmod +x "$r/scripts/hooks/commit-msg" "$r/scripts/hooks/pre-commit" "$r/scripts/install-hooks.sh"

brief "$r"
case "$out" in
  *"Gate 8 CHƯA cài"*) echo "  ok   H1 kêu khi hook chưa cài" ;;
  *) echo "  FAIL H1 — không kêu khi hook chưa cài"; fails=$((fails + 1)) ;;
esac
exit0 "H1" "$rc"

( cd "$r" && ./scripts/install-hooks.sh >/dev/null 2>&1 )
brief "$r"
case "$out" in
  *"Gate 8 CHƯA cài"*) echo "  FAIL H2 — vẫn kêu sau khi đã cài (tiếng ồn)"; fails=$((fails + 1)) ;;
  *) echo "  ok   H2 im sau khi đã cài" ;;
esac
exit0 "H2" "$rc"

# H3. Repo không có install-hooks.sh → im, và vẫn exit 0.
r="$(newrepo h3 yes)"
brief "$r"
case "$out" in
  *"GIT HOOKS"*) echo "  FAIL H3 — kêu ở repo không có scripts/install-hooks.sh"; fails=$((fails + 1)) ;;
  *) echo "  ok   H3 im ở repo không có scripts/install-hooks.sh" ;;
esac
exit0 "H3" "$rc"

# --- C. Danh sách vượt ngưỡng: brief phải NÓI ra phần đã cắt (T-027 · F-012) --
#
# Mọi ca ở trên đều dưới ngưỡng, nên không ca nào bắt được lỗi F-012: bốn danh
# sách cùng cắt ở 6 và không danh sách nào nói là đã cắt. Danh sách bảy mục in ra
# sáu mục thì trông y hệt một danh sách sáu mục — người đọc không có cách nào
# phân biệt "hết rồi" với "còn nữa". Bốn ca dài + hai ca ngắn dưới đây là chỗ đó.
echo "=== brief.sh — danh sách vượt ngưỡng phải nói là đã cắt ==="

# sect <tên mục> — lấy THÂN của một mục trong $out (tiêu đề mục bắt đầu ở cột 0).
sect() {
  printf '%s\n' "$out" | awk -v h="$1" 'index($0, h) == 1 { on = 1; next }
                                        on && /^[A-Z]/ { exit } on'
}

# manyrepo <tên> <số dòng Ready> <số dòng In Progress>
manyrepo() {
  local d="$TMPROOT/$1" n="$2" m="$3" i
  mkdir -p "$d/work" "$d/docs/product" && git -C "$d" init -q
  git -C "$d" config user.email t@t && git -C "$d" config user.name t
  {
    echo "# Backlog"; echo; echo "## Ready"; echo
    for i in $(seq 1 "$n"); do printf -- "- [ ] R-%03d việc thứ %s\n" "$i" "$i"; done
    echo; echo "## In Progress"; echo
    for i in $(seq 1 "$m"); do printf -- "- [ ] P-%03d đang chạy %s\n" "$i" "$i"; done
    echo; echo "## Done"
  } > "$d/work/backlog.md"
  echo "# scope" > "$d/work/scope.txt"
  : > "$d/docs/product/99-unknowns.md"
  git -C "$d" add -A >/dev/null 2>&1
  git -C "$d" commit -qm init >/dev/null 2>&1
  mkdir -p "$d/scripts"
  cp "$CHECK_SCOPE" "$d/scripts/check-scope.sh"
  printf '%s' "$d"
}

# manyfindings <repo> <số finding Open>
manyfindings() {
  local d="$1" n="$2" i
  {
    echo "# Findings"; echo
    for i in $(seq 1 "$n"); do
      printf -- "### F-%03d — chuyện thứ %s\n\n**Status:**\nOpen\n\n" "$i" "$i"
    done
  } > "$d/work/findings.md"
}

inbody() { # inbody <tên ca> <thân mục> <chuỗi phải có>
  case "$2" in
    *"$3"*) echo "  ok   $1" ;;
    *) echo "  FAIL $1 — mong đợi '$3', nhận:"; printf '%s\n' "$2" | sed 's/^/         /'
       fails=$((fails + 1)) ;;
  esac
}

notinbody() { # notinbody <tên ca> <thân mục> <chuỗi KHÔNG được có>
  case "$2" in
    *"$3"*) echo "  FAIL $1 — không được thấy '$3', nhận:"; printf '%s\n' "$2" | sed 's/^/         /'
            fails=$((fails + 1)) ;;
    *) echo "  ok   $1" ;;
  esac
}

# C1. Ready 10 mục / ngưỡng 6 — đúng con số thật ngày 2026-08-31, khi BA-12 nằm
#     ngoài sáu dòng đầu và không phiên mới nào nhìn thấy nó.
r="$(manyrepo c1 10 1)"
brief "$r"; b="$(sect 'NEXT READY')"
inbody "C1 Ready dài nói ĐÃ CẮT"        "$b" "ĐÃ CẮT"
inbody "C1 nói in mấy trên mấy"          "$b" "in 6/10 mục"
inbody "C1 nói còn lại bao nhiêu"        "$b" "Còn 4 mục"
inbody "C1 chỉ chỗ đọc đủ"               "$b" "work/backlog.md → Ready"
inbody "C1 vẫn in mục thứ 6"             "$b" "R-006"
notinbody "C1 mục thứ 7 đúng là bị cắt"  "$b" "R-007"
n="$(printf '%s\n' "$b" | grep -c 'R-[0-9]')"
if [ "$n" = "6" ]; then echo "  ok   C1 in đúng 6 dòng danh sách"
else echo "  FAIL C1 — mong đợi 6 dòng R-, nhận $n"; fails=$((fails + 1)); fi
exit0 "C1" "$rc"

# C2. Ready đúng 6 mục — im. Một dòng "đã in hết" ở mỗi phiên là tiếng ồn, và
#     tiếng ồn là thứ làm người ta thôi đọc brief.
r="$(manyrepo c2 6 1)"
brief "$r"; b="$(sect 'NEXT READY')"
notinbody "C2 danh sách vừa đúng ngưỡng thì im" "$b" "ĐÃ CẮT"
inbody    "C2 vẫn in đủ 6"                      "$b" "R-006"
exit0 "C2" "$rc"

# C3. In Progress 8 mục — và cảnh báo scope vẫn phải đọc danh sách ĐỦ, không đọc
#     bản đã cắt: "có task nào đang chạy không" hỏi trên nửa sự thật là sai.
r="$(manyrepo c3 1 8)"; SCOPE_ID=P-008 setscope "$r" "docs/x.md"
brief "$r"; b="$(sect 'IN PROGRESS')"
inbody "C3 In Progress dài nói ĐÃ CẮT" "$b" "in 6/8 mục"
inbody "C3 chỉ chỗ đọc đủ"             "$b" "work/backlog.md → In Progress"
want   "C3 scope bẩn nhưng CÓ task chạy → im" no "$out"
exit0 "C3" "$rc"

# C4. Open findings 8 mục — F-012 tự nó biến mất khỏi brief khi số finding Open
#     vượt sáu, đúng thứ finding ấy cảnh báo.
r="$(manyrepo c4 1 1)"; manyfindings "$r" 8
brief "$r"; b="$(sect 'OPEN FINDINGS')"
inbody "C4 findings dài nói ĐÃ CẮT" "$b" "in 6/8 mục"
inbody "C4 chỉ chỗ đọc đủ"          "$b" "work/findings.md"
inbody "C4 vẫn in finding thứ 6"    "$b" "F-006"
exit0 "C4" "$rc"

# C5. CA THẬT CỦA F-012: bảy câu hỏi mở. Ngưỡng riêng của câu hỏi mở phải in đủ
#     bảy — U-011 là câu đã vô hình với mọi phiên mới kể từ dòng nó được viết ra.
r="$(manyrepo c5 1 1)"
unknowns "$r" "### Đang mở" "" \
  "- U-005 — câu một" "- U-006 — câu hai" "- U-007 — câu ba" "- U-008 — câu bốn" \
  "- U-009 — câu năm" "- U-010 — câu sáu" "- U-011 — câu bảy"
has    "C5 bảy câu mở vẫn thấy câu thứ bảy (U-011)" "U-011"
hasnt  "C5 bảy câu mở KHÔNG bị cắt"                 "ĐÃ CẮT"
n="$(printf '%s\n' "$u" | grep -c 'U-0')"
if [ "$n" = "7" ]; then echo "  ok   C5 in đủ cả bảy câu"
else echo "  FAIL C5 — mong đợi 7 câu, nhận $n"; fails=$((fails + 1)); fi
exit0 "C5" "$rc"

# C6. Câu hỏi mở vượt CẢ ngưỡng riêng (14 > 12) — vẫn cắt, nhưng phải nói thẳng
#     hậu quả: §3.5 chỉ dừng được phiên BIẾT mình đang thiếu.
r="$(manyrepo c6 1 1)"
set -- "### Đang mở" ""
for i in $(seq 1 14); do set -- "$@" "$(printf -- '- U-%03d — câu thứ %s' "$i" "$i")"; done
unknowns "$r" "$@"
has "C6 câu hỏi mở vượt ngưỡng riêng vẫn nói ĐÃ CẮT" "in 12/14 mục"
has "C6 chỉ chỗ đọc đủ"                              "docs/product/99-unknowns.md → Unknowns → Đang mở"
has "C6 nói thẳng hậu quả §3.5"                      "§3.5"
exit0 "C6" "$rc"

# C7. Ngưỡng của câu hỏi mở là ngưỡng RIÊNG, không thừa hưởng MAX_LIST: bảy câu
#     mở thì Ready dài vẫn bị cắt ở 6 trong cùng một lần chạy.
b="$(sect 'NEXT READY')"
notinbody "C7 Ready 1 mục thì không cắt" "$b" "ĐÃ CẮT"
r="$(manyrepo c7 10 1)"
unknowns "$r" "### Đang mở" "" \
  "- U-005 — câu một" "- U-006 — câu hai" "- U-007 — câu ba" "- U-008 — câu bốn" \
  "- U-009 — câu năm" "- U-010 — câu sáu" "- U-011 — câu bảy"
hasnt "C7 bảy câu mở không bị cắt" "ĐÃ CẮT"
b="$(sect 'NEXT READY')"
inbody "C7 cùng lúc đó Ready 10 mục vẫn bị cắt ở 6" "$b" "in 6/10 mục"
exit0 "C7" "$rc"

# --- D. Owner của mục Unknowns là docs/product/99-unknowns.md (DOC-2 · ADR-014) --
#
# Bước 1 (DOC-1) đã chuyển mục Unknowns sang docs/product/99-unknowns.md và để
# docs/product.md ở lại làm BẢN LƯU — một bản lưu KHÔNG sở hữu sự thật nào và
# không ai được trỏ về. Ba ca dưới đây là ba cách hỏng của bước này:
#   đọc đúng file · file chưa có mà vẫn không chặn · đọc nhầm bản lưu.
echo "=== brief.sh — Unknowns đọc ở docs/product/99-unknowns.md ==="

# D1. File mới có ba câu dưới '### Đang mở' → in đủ ba.
r="$(newrepo d1 yes)"
unknowns "$r" "### Đang mở" "" \
  "- U-101 — câu một" "- U-102 — câu hai" "- U-103 — câu ba"
has   "D1 thấy U-101" "U-101"
has   "D1 thấy U-102" "U-102"
has   "D1 thấy U-103" "U-103"
n="$(printf '%s\n' "$u" | grep -c 'U-1')"
if [ "$n" = "3" ]; then echo "  ok   D1 in đúng 3 câu"
else echo "  FAIL D1 — mong đợi 3 câu, nhận $n"; fails=$((fails + 1)); fi
exit0 "D1" "$rc"

# D2. File mới KHÔNG tồn tại → (none), không lỗi, và vẫn exit 0 (CLAUDE.md §7.1).
r="$(newrepo d2 yes)"
rm -rf "$r/docs/product"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
has   "D2 mất cả thư mục docs/product/ vẫn in (none)" "(none)"
exit0 "D2 mất docs/product/" "$rc"

# D3. Bản lưu docs/product.md VẪN còn một mục Unknowns cũ → brief không đọc nó.
#     Đây là ca thật: bản lưu giữ nguyên văn mục cũ, và một câu đã đóng từ lâu
#     ở đó mà lọt vào brief là phiên mới đi trả lời một câu không còn ai hỏi.
r="$(newrepo d3 yes)"
unknowns "$r" "### Đang mở" "" "- U-101 — câu đang mở, ở NHÀ THẬT"
{ echo "# Product (BẢN LƯU)"; echo; echo "## Unknowns"; echo; echo "### Đang mở"; echo
  echo "- U-999 — câu cũ nằm trong bản lưu, không ai còn hỏi."; } > "$r/docs/product.md"
brief "$r"
u="$(printf '%s\n' "$out" | awk '/^OPEN UNKNOWNS/ { on = 1; next } on && /^[A-Z]/ { exit } on')"
has   "D3 vẫn thấy câu ở nhà thật" "U-101"
hasnt "D3 KHÔNG đọc mục Unknowns của bản lưu" "U-999"
exit0 "D3" "$rc"

# D4. OWNER FILES: owner nay là THƯ MỤC docs/product/. Vòng lặp cũ dùng [ -f ],
#     mà [ -f ] trên thư mục là false — dòng owner sẽ biến mất IM LẶNG, đúng kiểu
#     hỏng brief không được phép có. Và bản lưu không còn là owner nào.
b="$(sect 'OWNER FILES')"
inbody    "D4 OWNER FILES in docs/product/"        "$b" "docs/product/"
notinbody "D4 bản lưu không còn trong OWNER FILES" "$b" "docs/product.md"
# Ngày phải là ngày THẬT của git, không phải 'uncommitted': `git log -1 -- <thư mục>`
# vẫn trả lời đúng cho một thư mục, nên 'uncommitted' ở đây nghĩa là đã hỏi sai chỗ.
pline="$(printf '%s\n' "$b" | grep 'docs/product/')"
case "$pline" in
  *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*) echo "  ok   D4 docs/product/ có ngày thật" ;;
  *) echo "  FAIL D4 — docs/product/ không có ngày thật, nhận: $pline"; fails=$((fails + 1)) ;;
esac
exit0 "D4" "$rc"

echo "=== brief.sh — T-319: scope, thứ tự, ADR và trần kích thước ==="

# E1. Brief dùng phân loại --list: active/unknown giữ pattern, Ready/Done gộp.
r="$(newrepo e1 yes)"
setscope "$r" "active-pattern/"
SCOPE_ID=T-003 setscope "$r" "unknown-pattern/"
SCOPE_ID=T-002 setscope "$r" "orphan-pattern/"
brief "$r"; b="$(sect 'DECLARED SCOPE')"
inbody "E1 pattern active hiện" "$b" "active-pattern/"
inbody "E1 pattern unknown hiện" "$b" "unknown-pattern/"
inbody "E1 unknown có lời nhắc" "$b" "T-003 chưa có dòng trong work/backlog.md"
notinbody "E1 pattern orphan ẩn" "$b" "orphan-pattern/"
inbody "E1 orphan gộp số và mã" "$b" "1 file scope không ở In Progress: T-002"
exit0 "E1" "$rc"

# E2. Hơn 20 orphan vẫn chỉ một dòng, trỏ --list và nói rõ ba cách xử lý.
r="$(newrepo e2 no)"
for i in $(seq 1 25); do
  id="$(printf 'T-%03d' "$((i + 100))")"
  echo "- [x] $id đã xong" >> "$r/work/backlog.md"
  SCOPE_ID="$id" setscope "$r" "orphan-$id/"
done
brief "$r"; b="$(sect 'DECLARED SCOPE')"
inbody "E2 orphan có số 25" "$b" "25 file scope không ở In Progress"
# Thứ tự in là "mới sửa trước" (ls -t), nên đếm số mã thay vì đoán mã nào đứng thứ 21.
n="$(printf '%s\n' "$b" | grep 'file scope không ở In Progress' | grep -oE 'T-1[0-9][0-9]' | grep -c .)"
if [ "$n" = 20 ]; then echo "  ok   E2 orphan in đúng 20 mã"
else echo "  FAIL E2 — mong 20 mã orphan, nhận $n"; fails=$((fails + 1)); fi
inbody "E2 orphan báo ĐÃ CẮT và trỏ --list" "$b" "ĐÃ CẮT (xem ./scripts/check-scope.sh --list)"
inbody "E2 cách xử lý theo commit và In Progress" "$b" "đã Done mà chưa commit: giữ tới khi commit xong; đang làm: đưa mã về In Progress"
n="$(printf '%s\n' "$b" | grep -c 'file scope không ở In Progress')"
if [ "$n" = 1 ]; then echo "  ok   E2 orphan chỉ một dòng tổng hợp"
else echo "  FAIL E2 — mong 1 dòng orphan, nhận $n"; fails=$((fails + 1)); fi
exit0 "E2" "$rc"

# E3. Chỉ tick thì không nhắc task mở. Thêm một chưa tick: nó lên đầu, không
# đổi thứ tự trong nhóm; dòng dài cắt ở ranh giới từ, archive chỉ khi có file.
r="$(newrepo e3 no)"
cat > "$r/work/backlog.md" <<'EOF'
## Ready
- [ ] R-001 việc kế tiếp
## In Progress
- [x] T-001 đã tick
- [x] T-002 đã tick
EOF
brief "$r"; b="$(sect 'DECLARED SCOPE')"
notinbody "E3 chỉ tick không nhắc task mở" "$b" "a task is open"
b="$(sect 'IN PROGRESS')"
notinbody "E3 chưa có archive script thì im" "$b" "archive-done.sh"
mkdir -p "$r/scripts"; : > "$r/scripts/archive-done.sh"; chmod +x "$r/scripts/archive-done.sh"
brief "$r"; b="$(sect 'IN PROGRESS')"
inbody "E3 có script và tick thì nhắc archive" "$b" "2 việc đã tick còn ở In Progress — việc nào đã commit thì chuyển bằng ./scripts/archive-done.sh"
long=""
for i in $(seq 1 65); do long="${long}điệnthoại "; done
cat > "$r/work/backlog.md" <<EOF
## Ready
- [ ] R-001 $long
## In Progress
- [x] T-001 đã tick
- [ ] T-003 $long
- [x] T-002 đã tick
- [ ] T-004 $long
EOF
brief "$r"; b="$(sect 'IN PROGRESS')"
order="$(printf '%s\n' "$b" | sed -n 's/^  - \[[ x]\] \(T-[0-9]*\).*/\1/p' | tr '\n' ' ')"
if [ "$order" = 'T-003 T-004 T-001 T-002 ' ]; then echo "  ok   E3 chưa tick trước, giữ thứ tự từng nhóm"
else echo "  FAIL E3 — thứ tự: $order"; fails=$((fails + 1)); fi
inbody "E3 còn chưa tick thì nhắc task mở" "$(sect 'DECLARED SCOPE')" "a task is open"
line="$(printf '%s\n' "$b" | grep 'T-003')"
size="$(printf '%s' "$line" | wc -c | tr -d ' ')"
case "$line" in *"điệnthoại…") echo "  ok   E3 cắt sau từ tiếng Việt" ;;
  *) echo "  FAIL E3 — cắt giữa từ tiếng Việt: $line"; fails=$((fails + 1)) ;; esac
if [ "$size" -le 210 ]; then echo "  ok   E3 dòng In Progress khoảng 200 byte ($size)"
else echo "  FAIL E3 dòng In Progress dài $size byte"; fails=$((fails + 1)); fi
b="$(sect 'NEXT READY')"; line="$(printf '%s\n' "$b" | grep 'R-001')"
case "$line" in *"điệnthoại…") echo "  ok   E3 Ready cũng cắt sau từ tiếng Việt" ;;
  *) echo "  FAIL E3 Ready cắt giữa từ tiếng Việt"; fails=$((fails + 1)) ;; esac
exit0 "E3" "$rc"

# E4. ADR hỗn hợp ##/###, dòng khuôn, thứ tự file lộn xộn.
r="$(newrepo e4 no)"
cat > "$r/docs/decisions.md" <<'EOF'
## ADR-141 — Quyết định 141
### ADR-126 — Quyết định 126
## ADR-142 — Quyết định 142
## ADR-140 — Quyết định 140
## ADR-999 — Title
EOF
brief "$r"; b="$(sect 'LATEST DECISIONS')"
expected="$(printf '  ADR-140 — Quyết định 140\n  ADR-141 — Quyết định 141\n  ADR-142 — Quyết định 142')"
if [ "$b" = "$expected" ]; then echo "  ok   E4 ADR lấy 3 số lớn nhất, tăng dần, bỏ khuôn và dấu #"
else echo "  FAIL E4 — nhận: $b"; fails=$((fails + 1)); fi
exit0 "E4" "$rc"

# E5. check-scope không chạy được: brief giữ mọi pointer và luôn exit 0.
r="$(newrepo e5 no)"; SCOPE_ID=T-002 setscope "$r" "fallback-pattern/"
chmod -x "$r/scripts/check-scope.sh"
brief "$r"; b="$(sect 'DECLARED SCOPE')"
inbody "E5 fallback in mọi pattern" "$b" "fallback-pattern/"
exit0 "E5" "$rc"

# E5b. Mục scope có trần: 10 file scope đang được tính, mỗi file 9 pattern ⇒ chỉ 6 file in
#      pattern, mỗi file 6 pattern, phần còn lại được NÓI RA là đã cắt (một mục không trần
#      từng làm brief dài 141 KB và hook bỏ gần hết — đo 2026-11-11).
r="$(newrepo e5b no)"
{
  echo '## In Progress'
  for i in $(seq 1 10); do printf -- '- [ ] T-%03d việc đang làm\n' "$((i + 400))"; done
  echo '## Done'
} > "$r/work/backlog.md"
for i in $(seq 1 10); do
  id="$(printf 'T-%03d' "$((i + 400))")"
  SCOPE_ID="$id" setscope "$r" "p1-$id/" "p2-$id/" "p3-$id/" "p4-$id/" "p5-$id/" "p6-$id/" "p7-$id/" "p8-$id/" "p9-$id/"
done
brief "$r"; b="$(sect 'DECLARED SCOPE')"
n="$(printf '%s\n' "$b" | grep -c '^  work/scope/T-4[0-9][0-9]\.txt:$')"
if [ "$n" = 6 ]; then echo "  ok   E5b chỉ 6 file scope in pattern"
else echo "  FAIL E5b — mong 6 file in pattern, nhận $n"; fails=$((fails + 1)); fi
n="$(printf '%s\n' "$b" | grep -c '^    p[0-9]-T-4')"
if [ "$n" = 36 ]; then echo "  ok   E5b mỗi file 6 pattern"
else echo "  FAIL E5b — mong 36 dòng pattern, nhận $n"; fails=$((fails + 1)); fi
inbody "E5b nói đã cắt pattern của từng file" "$b" "ĐÃ CẮT: in 6/9 pattern"
inbody "E5b nói đã cắt file và còn mấy file" "$b" "ĐÃ CẮT: in 6/10 file scope đang được tính (mới sửa trước). Còn 4 file:"
inbody "E5b trỏ tới file scope và --list" "$b" "work/scope/<MÃ>.txt; danh sách đủ: ./scripts/check-scope.sh --list"
exit0 "E5b" "$rc"

# E6. 300 orphan × 5 pattern và 30 dòng In Progress dài hơn 600 byte.
r="$(newrepo e6 no)"
{
  echo '## In Progress'
  for i in $(seq 1 30); do printf -- '- [ ] P-%03d %s\n' "$i" "$long"; done
  echo '## Done'
  for i in $(seq 1 300); do printf -- '- [x] T-%03d đã xong\n' "$i"; done
} > "$r/work/backlog.md"
for i in $(seq 1 300); do
  id="$(printf 'T-%03d' "$i")"
  SCOPE_ID="$id" setscope "$r" "one-$id/" "two-$id/" "three-$id/" "four-$id/" "five-$id/"
done
brief "$r"
size="$(wc -c < "$BOUT" | tr -d ' ')"
if [ "$size" -le "$BRIEF_MAX_BYTES" ]; then echo "  ok   E6 300 orphan, 30 dòng dài: $size <= $BRIEF_MAX_BYTES byte"
else echo "  FAIL E6 brief $size > $BRIEF_MAX_BYTES byte"; fails=$((fails + 1)); fi
exit0 "E6" "$rc"

# E7. Đo chính repo chứa test để độ phình của brief thật làm gate đỏ.
repo_root="$(git -C "$(dirname "$SCRIPT")" rev-parse --show-toplevel)"
brief "$repo_root"
size="$(wc -c < "$BOUT" | tr -d ' ')"
if [ "$size" -le "$BRIEF_MAX_BYTES" ]; then echo "  ok   E7 repo thật: $size <= $BRIEF_MAX_BYTES byte"
else echo "  FAIL E7 brief repo thật $size > $BRIEF_MAX_BYTES byte"; fails=$((fails + 1)); fi
exit0 "E7" "$rc"

if [ "$fails" -ne 0 ]; then
  echo "brief: $fails ca FAIL"; exit 1
fi
echo "brief: tất cả ca đều qua."
