#!/usr/bin/env bash
# Gate 1c — MỘT MÃ ĐỊNH DANH, HAI CHỖ, HAI TRẠNG THÁI.
#
# Chạy tay:  ./scripts/check-doc-status.sh
# gate.sh gọi nó ở MỌI lượt, cạnh check-links.sh và vì đúng lý do ấy: lỗi loại
# này chỉ sống trong tài liệu, mà lượt chỉ đổi tài liệu là lượt verify.sh (Gate
# 1) bỏ qua — một cổng đặt trong scripts/*.test.sh sẽ không bao giờ chạy đúng
# vào lượt sinh ra lỗi (ADR-005, ADR-032).
#
# VÌ SAO CÓ GATE NÀY (work/findings.md F-015 · F-021 · F-022)
#   Đóng một câu hỏi là HAI việc: ghi câu trả lời vào chỗ nó thuộc về, rồi sửa
#   mọi chỗ NHẮC TỚI câu hỏi. Phiên nào cũng chỉ nhớ việc thứ nhất. Bốn câu
#   trong §1–§7 nói một luật đã chốt vẫn đang treo, hai dòng bảng docs/decisions.md
#   nói ngược thân của chính nó — cùng một hình: cùng một mã, hai chỗ, hai
#   trạng thái. Đó là loại kiểm tra rẻ, và nay do máy chấm.
#
#   F-015 đã ĐO HAI LẦN (2026-09-02, 2026-09-03) ⇒ CLAUDE.md §3.8 đủ điều kiện.
#
# BA PHÉP SO — không phép nào biết trước ca nào đã hỏng
#   A. Một `U-XXX` ĐÃ ĐÓNG bị nhắc bằng ngôn ngữ CÒN-MỞ, mà khối ấy KHÔNG chỗ
#      nào nói câu hỏi đã có lời chốt. Vế sau là thứ tách một câu đang sai khỏi
#      một câu kể lại lịch sử ("U-017 lúc ấy còn mở, chủ quán chốt 2026-09-01").
#   C. Một chuyển tiếp mà bảng vòng đời §5 ghi là HỢP LỆ, bị PHỦ ĐỊNH ngay cạnh
#      nó ("không cần đường X → Y", "X → Y bị từ chối"). Phép này KHÔNG dùng mã
#      định danh nào, nên nó bắt được đúng ca mà câu awk của F-015 để lọt vì
#      câu ấy "không mang mã".
#   D. `docs/decisions.md`: dòng GĐ-XXX ở bảng tổng hợp đầu file phải khớp
#      `Trạng thái:` trong thân mục nó trỏ tới.
#
# MỘT PHÉP ĐÃ THỬ VÀ BỊ BỎ, ghi lại để đừng ai dựng lại nó:
#   "mọi ngôn ngữ còn-mở phải trỏ tới một thứ đang mở" — nghe đúng, chạy thử
#   trên cây ngày 2026-09-03 ra **11 báo động, cả 11 đều giả** ("danh sách quyết
#   định chưa rõ/giả định", "Câu hỏi chưa có lời giải đi vào 99-unknowns.md").
#   Một cổng kêu 11 lần sai là cổng bị gỡ (F-018). Ca "không mang mã" mà nó định
#   phủ đã được phép C phủ, bằng đường khác và không cần từ khoá nào.
#
# ĐỌC THEO KHỐI, KHÔNG THEO DÒNG — đây là điểm chết của câu awk cũ
#   Tài liệu gói dòng ở mọi đoạn văn, nên cụm "CHƯA CHỐT" bị cắt đôi giữa hai
#   dòng và mọi bộ lọc theo dòng đều mù với nó (F-015, chỗ §4.9). Script này
#   gộp một đoạn văn / một ô bảng / một gạch đầu dòng thành MỘT khối rồi mới
#   chấm. Khối ``` bị cắt bỏ trước: trong đó là ví dụ, không phải lời khẳng định.
#
# IGNORE CÓ HẠN — scripts/check-doc-status.ignore
#   Mỗi dòng "<file> :: <chuỗi con>" kèm lý do, cho những chỗ TRÍCH DẪN một câu
#   đã hỏng làm bằng chứng. Dòng ignore không còn khớp gì thì gate ĐỎ — cùng
#   luật với Gate 1b: ignore hết hạn phải gỡ.

set -uo pipefail

ROOT="${1:-}"
if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "check-doc-status: not a git repository, skipping"
    exit 0
  }
fi
cd "$ROOT" || exit 0

UNKNOWNS="${DOC_STATUS_UNKNOWNS:-docs/product/99-unknowns.md}"
DECISIONS="${DOC_STATUS_DECISIONS:-docs/decisions.md}"
LIFECYCLE="${DOC_STATUS_LIFECYCLE:-docs/product/0-ba/ban-hang/05-vong-doi.md}"
IGNORE_FILE="${DOC_STATUS_IGNORE:-scripts/check-doc-status.ignore}"
# Tài liệu nghiệp vụ được chấm. work/ và prompt/ KHÔNG được chấm: ở đó một câu
# đã hỏng được trích dẫn làm bằng chứng (cùng lý do Gate 1b bỏ qua work/).
SCAN_DIRS="${DOC_STATUS_SCAN:-docs/product quality}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fails=0
say() { printf '%s\n' "$*"; }

# --- Bước 1: U-XXX nào đang mở, U-XXX nào đã đóng ----------------------------
# Hợp đồng hình dạng của mục Unknowns: docs/decisions.md ADR-007.
#   vùng mở = đầu mục "## Unknowns" + mọi khối dưới "### Đang mở"
#   trong vùng mở, MỘT GẠCH ĐẦU DÒNG là một câu đang mở (văn xuôi thì không)
#   mọi U-XXX ngoài vùng mở = đã đóng
if [ -f "$UNKNOWNS" ]; then
  awk '
    /^## Unknowns/            { inunk=1; region="open"; next }
    /^## / && inunk           { inunk=0; region="" }
    !inunk                    { next }
    /^### /                   { region = ($0 ~ /Đang mở/) ? "open" : "closed"; bullet=0; next }
    /^```/                    { fence = !fence; next }
    fence                     { next }
    {
      if (region == "open") {
        if ($0 ~ /^[[:space:]]*[-*][[:space:]]/) bullet = 1
        else if ($0 ~ /^[[:space:]]*$/)          bullet = 0
        else if ($0 !~ /^[[:space:]]+/)          bullet = 0
        if (!bullet) next
        state = "open"
      } else state = "closed"
      s = $0
      while (match(s, /U-[0-9][0-9][0-9]/)) {
        print substr(s, RSTART, RLENGTH) "\t" state
        s = substr(s, RSTART + RLENGTH)
      }
    }
  ' "$UNKNOWNS" | sort -u > "$TMP/u.raw"
  # Một mã vừa mở vừa đóng (mở lại một câu cũ) ⇒ tính là ĐANG MỞ.
  awk -F'\t' '{ if ($2=="open") o[$1]=1; else c[$1]=1 }
              END { for (k in o) print k "\topen"
                    for (k in c) if (!(k in o)) print k "\tclosed" }' "$TMP/u.raw" \
    | sort > "$TMP/u.status"
else
  : > "$TMP/u.status"
fi

# --- Bước 2: chuyển tiếp nào bảng vòng đời §5 ghi là HỢP LỆ ------------------
# Dòng bảng: | trạng thái nguồn | sự kiện | trạng thái đích | ai kích hoạt |
if [ -f "$LIFECYCLE" ]; then
  awk -F'|' '
    function clean(x) {
      gsub(/\*\*/, "", x); gsub(/`/, "", x)
      gsub(/\*\([^)]*\)\*/, "", x); gsub(/\([^)]*\)/, "", x)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", x)
      return x
    }
    /^\|/ && NF >= 5 {
      src = clean($2); dst = clean($4)
      if (src == "" || dst == "") next
      if (src ~ /^-+$/ || src ~ /^Trạng thái/) next
      if (src ~ /chưa có/ || dst ~ /chưa có/) next
      if (dst ~ /[[:space:]]/ && dst !~ /^[A-ZĐÀ-ỹ]/) next
      print src "\t" dst
    }
  ' "$LIFECYCLE" | sort -u > "$TMP/transitions"
else
  : > "$TMP/transitions"
fi

# --- Bước 3: gộp tài liệu thành KHỐI rồi chấm A, B, C ------------------------
files=""
for d in $SCAN_DIRS; do
  [ -d "$d" ] || continue
  files="$files $(find "$d" -name '*.md' -type f | sort)"
done

[ -f "$IGNORE_FILE" ] || : > "$TMP/empty.ignore"
IGN="${IGNORE_FILE}"
[ -f "$IGN" ] || IGN="$TMP/empty.ignore"

: > "$TMP/hits"
: > "$TMP/ignore.used"

for f in $files; do
  [ -f "$f" ] || continue
  case "$f" in "$UNKNOWNS") continue ;; esac   # owner của câu hỏi, không phải chỗ nhắc tới
  awk -v FNAME="$f" '
    function flush(   t) {
      if (buf == "") return
      t = buf
      gsub(/[[:space:]]+/, " ", t)
      print FNAME "\t" start "\t" t
      buf = ""
    }
    /^```/ { flush(); fence = !fence; next }
    fence  { next }
    /^[[:space:]]*$/ { flush(); next }
    /^\|/  { flush(); start = NR; buf = $0; flush(); next }
    /^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]/ { flush(); start = NR; buf = $0; next }
    /^#/   { flush(); next }
    { if (buf == "") start = NR; buf = buf " " $0 }
    END { flush() }
  ' "$f" >> "$TMP/blocks"
done
[ -f "$TMP/blocks" ] || : > "$TMP/blocks"

awk -F'\t' -v IGN="$IGN" '
  BEGIN {
    # "câu này còn treo" — thì hiện tại
    OPEN_LANG = "CHƯA CHỐT|chưa chốt|còn để mở|còn mở|chưa rõ|chưa ai trả lời|chưa có lời giải|chưa được trả lời|chưa hỏi|chưa được hỏi|đang chờ chủ quán|hôm nay bị từ chối"
    # "và đây là lời chốt" — có một trong những cụm này thì khối đang KỂ LẠI,
    # không đang khẳng định. Thiếu vế này, mọi mục lịch sử đều đỏ: một finding
    # trích dẫn câu đã hỏng, một ADR kể "U-017 lúc ấy còn mở", một bảng bằng
    # chứng ghi "U-005 đóng 2026-08-31" — cả ba đều ĐÚNG và đều phải im.
    CLOSED_LANG = "chủ quán chốt|đã chốt|chốt 20|đã đóng|đóng 20|đóng \\*\\*U-|đóng U-|trả lời U-|đã trả lời|lúc ấy|khi ấy|hồi ấy|trước đây|đã từng"
    DENY      = "không cần đường|không có đường|chưa có đường|không mở đường|bị từ chối|không được phép"
    NEAR      = 30   # phủ định phải đứng SÁT chuyển tiếp mới tính (ký tự)
  }
  # nạp trạng thái U-XXX
  FNR == NR && FILENAME == ARGV[1] { ustate[$1] = $2; next }
  # nạp chuyển tiếp hợp lệ
  FILENAME == ARGV[2] { valid[$1 "\t" $2] = 1; next }
  # nạp ignore
  FILENAME == ARGV[3] {
    line = $0
    sub(/[[:space:]]*#.*$/, "", line)
    if (line ~ /^[[:space:]]*$/) next
    n = index(line, "::")
    if (n == 0) next
    f = substr(line, 1, n - 1); p = substr(line, n + 2)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", f)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", p)
    ig_f[++ig_n] = f; ig_p[ig_n] = p; ig_hit[ig_n] = 0
    next
  }
  # chấm từng khối
  {
    file = $1; ln = $2; txt = $3
    for (i = 1; i <= ig_n; i++)
      if (file == ig_f[i] && index(txt, ig_p[i]) > 0) { ig_hit[i] = 1; next }
    txt2 = txt; gsub(/`/, " ", txt2); gsub(/\*\*/, "", txt2)

    # --- A: một câu hỏi ĐÃ ĐÓNG bị kể như còn treo, và khối không nói lời chốt
    if (txt ~ OPEN_LANG && txt !~ CLOSED_LANG) {
      closed_ids = ""
      s = txt
      while (match(s, /U-[0-9][0-9][0-9]/)) {
        id = substr(s, RSTART, RLENGTH)
        if (ustate[id] == "closed" && index(closed_ids, id) == 0)
          closed_ids = closed_ids " " id
        s = substr(s, RSTART + RLENGTH)
      }
      if (closed_ids != "") {
        printf "A %s:%s — câu còn-mở nhắc tới câu hỏi ĐÃ ĐÓNG:%s\n    %s\n", file, ln, closed_ids, short(txt)
        bad++
      }
    }

    # --- C: phủ định một chuyển tiếp mà bảng §5 ghi là hợp lệ
    # Chấm theo MỆNH ĐỀ (cắt ở . ; | —) chứ không theo khoảng cách ký tự, và so
    # bằng CHUỖI NGUYÊN VĂN của từng chuyển tiếp trong bảng §5 chứ không bằng
    # lớp ký tự [A-Z…]: awk ở đây đếm BYTE, nên một lớp ký tự tiếng Việt khớp
    # cả byte giữa chữ ("không" khớp ở chữ ô) và cắt tên trạng thái sai chỗ.
    # Đó là lý do phép này duyệt danh sách chuyển tiếp thay vì bắt hình dạng.
    if (txt2 ~ DENY && txt !~ CLOSED_LANG) {
      nseg = split(txt2, seg, /[.;|]| — /)
      for (si = 1; si <= nseg; si++) {
        if (seg[si] !~ DENY) continue
        for (pair in valid) {
          split(pair, ab, "\t")
          if (index(seg[si], ab[1] " → " ab[2]) > 0 || index(seg[si], ab[1] " ⇒ " ab[2]) > 0) {
            printf "C %s:%s — phủ định một chuyển tiếp mà bảng §5 ghi là HỢP LỆ: %s → %s\n    %s\n", file, ln, ab[1], ab[2], short(txt)
            bad++
          }
        }
      }
    }
  }
  function short(t) { return (length(t) > 150) ? substr(t, 1, 150) "…" : t }
  END {
    for (i = 1; i <= ig_n; i++)
      if (!ig_hit[i]) {
        printf "IGNORE HẾT HẠN %s :: %s — không còn khớp gì, gỡ dòng này đi\n", ig_f[i], ig_p[i]
        bad++
      }
    exit (bad > 0)
  }
' "$TMP/u.status" "$TMP/transitions" "$IGN" "$TMP/blocks" > "$TMP/out" 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
  say "check-doc-status: ĐỎ — tài liệu nói hai trạng thái cho cùng một mã"
  cat "$TMP/out"
  fails=1
fi

# --- Bước 4 (D): bảng GĐ-XXX đầu docs/decisions.md vs thân mục ---------------
if [ -f "$DECISIONS" ]; then
  awk '
    function gid(line,   t) {
      if (match(line, /GĐ-[0-9]+/)) return substr(line, RSTART, RLENGTH)
      return ""
    }
    /^\| *GĐ-[0-9]/ && !seenbody {
      id = gid($0)
      table[id] = $0; tline[id] = NR; next
    }
    /^### *GĐ-[0-9]/ {
      cur = gid($0); seenbody = 1; next
    }
    cur != "" && /Trạng thái:/ {
      st = $0
      body[cur] = ($0 ~ /Superseded/) ? "superseded" : "live"
      bline[cur] = NR
      cur = ""
      next
    }
    END {
      for (id in body) {
        if (!(id in table)) continue
        row = table[id]
        rowdead = (row ~ /Đã thay/ || row ~ /~~/)
        if (body[id] == "superseded" && !rowdead) {
          printf "D docs/decisions.md:%s — bảng tổng hợp còn xếp %s là giả định ĐANG SỐNG, thân dòng %s ghi Superseded\n    %s\n", tline[id], id, bline[id], row
          bad++
        }
        if (body[id] == "live" && rowdead) {
          printf "D docs/decisions.md:%s — bảng tổng hợp ghi %s đã thay, thân dòng %s vẫn ghi giả định đang sống\n", tline[id], id, bline[id]
          bad++
        }
      }
      exit (bad > 0)
    }
  ' "$DECISIONS" > "$TMP/out.d" 2>&1
  if [ $? -ne 0 ]; then
    say "check-doc-status: ĐỎ — bảng chỉ mục docs/decisions.md nói ngược thân của chính nó"
    cat "$TMP/out.d"
    fails=1
  fi
fi

if [ "$fails" -ne 0 ]; then
  say ""
  say "Sửa chỗ NHẮC TỚI, đừng sửa chỗ câu trả lời (CLAUDE.md §7.2). Trích dẫn cố ý"
  say "một câu đã hỏng thì khai vào $IGNORE_FILE kèm lý do."
  exit 1
fi

say "check-doc-status: xanh — $(wc -l < "$TMP/blocks" | tr -d ' ') khối, $(wc -l < "$TMP/u.status" | tr -d ' ') mã U-XXX, $(wc -l < "$TMP/transitions" | tr -d ' ') chuyển tiếp hợp lệ."
exit 0
