#!/usr/bin/env bash
# Gate 1b — mọi đường dẫn mà một tài liệu **chỉ đường** nêu ra phải mở được.
#
# Chạy tay:  ./scripts/check-links.sh
# gate.sh gọi nó ở MỌI lượt, kể cả lượt chỉ đổi tài liệu — vì tài liệu chính là
# thứ repo này sản xuất, và verify.sh (Gate 1) bỏ qua đúng loại thay đổi đó.
#
# VÌ SAO CÓ GATE NÀY (work/findings.md F-007, bổ sung cho F-005 · F-006):
# F-005 và F-006 rà **dữ kiện** đã đổi. F-007 là loại thứ ba: pointer chết. Bản
# xuất khẩu master_plan/prompt-fullstack.md khẳng định "nhà thật của schema là
# design/data_base/01" trong khi thư mục design/ không tồn tại — người đọc nó
# đứng NGOÀI repo, không `ls` được, nên hoặc dừng, hoặc tự bịa nội dung bảy file
# đó rồi coi là đã có nguồn. Luật rút ra: mọi đường dẫn nêu ra phải `ls` được tại
# thời điểm xuất khẩu. Luật đó bây giờ do máy chấm.
#
# CHẤM FILE NÀO
#   Chấm  — tài liệu chỉ đường: CLAUDE.md · README.md · docs/ · quality/ ·
#           master_plan/ · prompt/BA/ · prompt/SD/ · .claude/
#           (prompt/SD/ = lane prompt của pha 1, mã bước P1-XX; thêm 2026-09-04
#            bởi P1-01, lượt tạo ra lane ấy. Một lane prompt không nằm trong
#            danh sách này là một lane pointer không cổng nào chấm — đúng thứ
#            F-007 dựng gate này để bắt.)
#   Đỏ   — chỉ file git ĐANG THEO DÕI. File .md chưa track có đường chết chỉ được
#          in thành một dòng `note:` và không chặn gate — cùng lý do ADR-003:
#          gate đỏ vì một bản nháp nằm sẵn trong cây dạy người ta bỏ qua gate.
#   Không — sổ ghi chép lịch sử: work/ · prompt/maintenance/
#           Ở đó một đường đã chết được **trích dẫn làm bằng chứng** (F-007 kể
#           tên đủ bảy đường chết). Chấm chúng thì mỗi finding viết ra lại phải
#           xin một dòng ignore — thuế đánh vào đúng việc ta muốn người ta làm.
#
# NHẬN DIỆN ĐƯỜNG DẪN
#   - Khối code ``` bị cắt bỏ trước khi rà: trong đó là ví dụ, không phải pointer.
#   - Chỉ nhận hai hình thức: link markdown ](đường/dẫn) và `đường/dẫn` trong dấu
#     nháy ngược. Phải có "/" và phải có đuôi biết trước (md sh go ts js json txt
#     yml yaml sql). Bỏ neo #..., bỏ http(s)/mailto, bỏ chuỗi có ... * < > $ {.
#   - Mở được = tồn tại so với gốc repo, HOẶC so với thư mục của file đang chấm.
#
# IGNORE CÓ HẠN — scripts/check-links.ignore
#   Mỗi dòng "<file> :: <đường dẫn>" kèm lý do. Dòng nào không còn khớp lỗi nào
#   thì gate ĐỎ: ignore hết hạn phải gỡ, không được nằm lại làm nợ vô hình.

set -uo pipefail

ROOT="${1:-}"
if [ -z "$ROOT" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "check-links: not a git repository, skipping"
    exit 0
  }
fi
cd "$ROOT" || exit 0

IGNORE_FILE="${CHECK_LINKS_IGNORE:-scripts/check-links.ignore}"

# --- tập file được chấm ------------------------------------------------------
checked() {
  case "$1" in
    work/*|prompt/maintenance/*) return 1 ;;
    CLAUDE.md|README.md|docs/*|quality/*|master_plan/*|prompt/BA/*|prompt/SD/*|.claude/*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- rút đường dẫn ra khỏi một file .md --------------------------------------
extract() {
  awk '
    /^[[:space:]]*```/ { infence = !infence; next }
    infence { next }
    {
      line = $0
      while (match(line, /\]\([^)]+\)/)) {
        p = substr(line, RSTART + 2, RLENGTH - 3)
        print p
        line = substr(line, RSTART + RLENGTH)
      }
      line = $0
      while (match(line, /`[^`]+`/)) {
        p = substr(line, RSTART + 1, RLENGTH - 2)
        print p
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$1"
}

dead=()          # "file :: path" — file git đang theo dõi, làm gate đỏ
notes=()         # "file :: path" — file chưa track, chỉ ghi chú (ADR-003)
declare -a ign_pat=() ign_hit=()

tracked_list="$(git ls-files '*.md')"
is_tracked() {
  case $'\n'"$tracked_list"$'\n' in *$'\n'"$1"$'\n'*) return 0 ;; esac
  return 1
}

if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] || continue
    ign_pat+=("$line")
    ign_hit+=(0)
  done < "$IGNORE_FILE"
fi

while IFS= read -r f; do
  checked "$f" || continue
  [ -f "$f" ] || continue
  dir="$(dirname "$f")"
  while IFS= read -r p; do
    p="${p%%#*}"                                   # bỏ neo
    [ -n "$p" ] || continue
    case "$p" in
      http://*|https://*|mailto:*|\#*) continue ;;
      *...*|*\**|*\<*|*\>*|*\$*|*\{*|*" "*) continue ;;
      */*) ;;
      *) continue ;;                               # không có "/" → không coi là đường dẫn
    esac
    case "$p" in
      *.md|*.sh|*.go|*.ts|*.js|*.json|*.txt|*.yml|*.yaml|*.sql) ;;
      *) continue ;;
    esac
    [ -e "$p" ] && continue
    [ -e "$dir/$p" ] && continue

    entry="$f :: $p"
    skip=0
    for i in "${!ign_pat[@]}"; do
      if [ "${ign_pat[$i]}" = "$entry" ]; then
        ign_hit[$i]=1
        skip=1
        break
      fi
    done
    [ "$skip" -eq 1 ] && continue

    # một file nêu cùng một đường chết nhiều lần → báo một lần
    if is_tracked "$f"; then
      seen=0
      for d in ${dead[@]+"${dead[@]}"}; do
        [ "$d" = "$entry" ] && { seen=1; break; }
      done
      [ "$seen" -eq 0 ] && dead+=("$entry")
    else
      seen=0
      for d in ${notes[@]+"${notes[@]}"}; do
        [ "$d" = "$entry" ] && { seen=1; break; }
      done
      [ "$seen" -eq 0 ] && notes+=("$entry")
    fi
  done < <(extract "$f")
done < <(git ls-files --cached --others --exclude-standard '*.md')

stale=()
for i in "${!ign_pat[@]}"; do
  [ "${ign_hit[$i]}" -eq 0 ] && stale+=("${ign_pat[$i]}")
done

rc=0
if [ ${#notes[@]} -gt 0 ]; then
  echo "check-links: note — file chưa được git theo dõi, có đường dẫn không mở được (không chặn gate):"
  printf '  ? %s\n' "${notes[@]}"
fi

if [ ${#dead[@]} -gt 0 ]; then
  echo "check-links: FAIL — tài liệu chỉ đường trỏ tới đường dẫn không tồn tại:"
  printf '  - %s\n' "${dead[@]}"
  echo "  Sửa đường dẫn, gỡ nó đi, hoặc — nếu chưa quyết được — ghi vào $IGNORE_FILE kèm số task."
  rc=1
fi

if [ ${#stale[@]} -gt 0 ]; then
  echo "check-links: FAIL — dòng ignore đã hết hạn (đường dẫn nay mở được hoặc câu chữ đã đổi):"
  printf '  - %s\n' "${stale[@]}"
  echo "  Gỡ những dòng đó khỏi $IGNORE_FILE."
  rc=1
fi

[ "$rc" -eq 0 ] && echo "check-links: OK — mọi đường dẫn trong tài liệu chỉ đường đều mở được."
exit "$rc"
