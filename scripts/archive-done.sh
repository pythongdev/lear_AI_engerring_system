#!/usr/bin/env bash
# T-320 — chuyển cơ học việc đã xong khỏi backlog. Mặc định chỉ xem trước;
# --apply mới ghi hai file, sau khi đã tính đủ các dòng và khối cần chuyển.

set -uo pipefail

if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "$1" != "--apply" ]; }; then
  echo 'Cách dùng: ./scripts/archive-done.sh [--apply]' >&2
  exit 2
fi
if [ ! -f work/backlog.md ] || [ ! -f work/backlog_archive.md ]; then
  echo 'archive-done: thiếu work/backlog.md hoặc work/backlog_archive.md.' >&2
  exit 2
fi

mode=dry
out_b="" out_a=""
if [ "${1:-}" = "--apply" ]; then
  mode=apply
  out_b="$(mktemp work/.backlog.md.XXXXXX)" || exit 2
  out_a="$(mktemp work/.backlog_archive.md.XXXXXX)" || exit 2
  trap 'rm -f -- "$out_b" "$out_a"' EXIT
fi

# Đọc ba nguồn theo thứ tự: subject của lịch sử tới được từ HEAD, archive, backlog.
# awk giữ từng dòng trong bộ nhớ, quyết định hết rồi mới ghi vào file tạm.
result="$(awk -v mode="$mode" -v out_b="$out_b" -v out_a="$out_a" '
function add_id(id) {
  if (!(id in seen)) { seen[id] = 1; order[++nids] = id }
}
function reason(id, why) {
  if (index("|" reasons[id] "|", "|" why "|") == 0)
    reasons[id] = reasons[id] (reasons[id] == "" ? "" : "; ") why
}
function anchor_of(s, a) {
  a = s
  if (a !~ /^<a id="[^"]+"><\/a>$/) return ""
  sub(/^<a id="/, "", a)
  sub(/"><\/a>$/, "", a)
  return a
}
function task_header(s, parts, id) {
  if (s !~ /^### [A-Z][A-Z0-9]*-[0-9]+ —/) return ""
  split(s, parts, " ")
  return parts[2]
}
function row_id(s, parts) {
  if (s !~ /^- \[[ x]\] [A-Z][A-Z0-9]*-[0-9]+([[:space:]]|$)/) return ""
  split(s, parts, " ")
  return parts[3]
}
function replace_literal(s, old, new, p, result) {
  result = ""
  while ((p = index(s, old)) > 0) {
    result = result substr(s, 1, p - 1) new
    s = substr(s, p + length(old))
  }
  return result s
}
function rewrite_remaining(s, k) {
  for (k = 1; k <= nblocks; k++)
    if (move_block[k])
      s = replace_literal(s, "](#" block_anchor[k] ")", "](backlog_archive.md#" block_anchor[k] ")")
  return s
}
function rewrite_block(s, p, q, prefix, tail, target, id) {
  tail = s; s = ""
  while ((p = index(tail, "](")) > 0) {
    q = index(substr(tail, p + 2), ")")
    if (!q) break
    s = s substr(tail, 1, p - 1) "](" 
    target = substr(tail, p + 2, q - 1)
    if (substr(target, 1, 19) == "backlog_archive.md#")
      target = "#" substr(target, 20)
    if (substr(target, 1, 1) == "#" && !(substr(target, 2) in archive_anchor))
      target = "backlog.md" target
    s = s target ")"
    tail = substr(tail, p + 2 + q)
  }
  return s tail
}
FILENAME == ARGV[1] {
  if ($0 ~ /^[A-Z][A-Z0-9]*-[0-9]+:/) {
    split($0, x, ":")
    commits[x[1]] = 1
  }
  next
}
FILENAME == ARGV[2] {
  a[++na] = $0
  anchor = anchor_of($0)
  if (anchor != "") archive_anchor[anchor] = 1
  if ($0 == "<a id=\"chi-tiet-da-xong\"></a>") archive_at = na
  next
}
FILENAME == ARGV[3] { b[++nb] = $0; next }
END {
  if (mode == "apply" && (out_b == "" || out_a == "")) exit 2
  section = ""
  for (i = 1; i <= nb; i++) {
    if (b[i] ~ /^## /) section = b[i]
    section_at[i] = section
    if (b[i] == "## In Progress") in_at = i
    if (b[i] == "## Done") done_at = i
    id = row_id(b[i])
    if (id == "") continue
    add_id(id)
    if (section == "## Ready") ready[id]++
    if (section == "## In Progress") {
      progress[id]++
      if (b[i] ~ /^- \[x\] /) {
        if (id in commits) candidate[id]++
        else reason(id, "chưa có commit mang mã")
      }
    }
    if (section == "## Done" && b[i] ~ /^- \[x\] /) done[id]++
  }
  if (!in_at || !done_at || !archive_at) {
    print "archive-done: thiếu mục ## In Progress, ## Done hoặc neo chi-tiet-da-xong." > "/dev/stderr"
    exit 2
  }
  for (i = 1; i <= nb; i++) {
    anchor = anchor_of(b[i])
    id = (anchor != "" && i < nb) ? task_header(b[i + 1]) : ""
    if (id == "") continue
    add_id(id)
    starts[++nblocks] = i
    block_id[nblocks] = id
    block_anchor[nblocks] = anchor
    block_count[id]++
  }
  for (k = 1; k <= nblocks; k++) {
    stop = nb + 1
    for (j = starts[k] + 1; j <= nb; j++) {
      # Dừng trước mục kế, trước mọi neo, và trước tiêu đề của một task khác dù nó
      # thiếu neo (backlog thật: `### T-259` không neo đứng ngay sau khối T-260).
      if (b[j] ~ /^## / || anchor_of(b[j]) != "" || (j > starts[k] + 1 && task_header(b[j]) != "")) {
        stop = j; break
      }
    }
    ends[k] = stop - 1
  }
  for (p = 1; p <= nids; p++) {
    id = order[p]
    if (done[id] + candidate[id] > 1) reason(id, "mã có hai dòng Done")
    if (block_count[id] > 1) reason(id, "mã có hai khối mô tả")
  }
  for (k = 1; k <= nblocks; k++) {
    id = block_id[k]
    if (block_anchor[k] in archive_anchor) reason(id, "neo đã tồn tại trong archive")
    # Neo đặt lệch mã (backlog thật: neo t-259 đứng trước `### T-260`) ⇒ không đoán
    # khối này của ai; người sửa neo trước rồi mới chuyển.
    if (block_anchor[k] != tolower(id)) reason(id, "neo " block_anchor[k] " không khớp mã")
  }
  for (i = 1; i <= nb; i++) {
    id = row_id(b[i])
    if (id != "" && b[i] ~ /^- \[x\] / && section_at[i] == "## In Progress" &&
        (id in commits) && reasons[id] == "") {
      move_row[i] = 1
      moved_line[id]++
      rows++
    }
  }
  for (k = 1; k <= nblocks; k++) {
    id = block_id[k]
    if (reasons[id] != "") continue
    if (done[id] + moved_line[id] == 0) reason(id, "khối không có dòng của mã ở Done")
    else if (ready[id] > 0 || progress[id] > moved_line[id]) reason(id, "mã còn dòng ở Ready hoặc In Progress")
    else {
      move_block[k] = 1
      moved_block[id] = k
      archive_anchor[block_anchor[k]] = 1
      blocks++
    }
  }
  # Hai danh sách dùng chung kết quả tính, không đụng hai file ở chế độ thử.
  if (mode == "dry") {
    print "Sẽ chuyển:"
    any = 0
    for (p = 1; p <= nids; p++) {
      id = order[p]
      if (moved_line[id] || moved_block[id]) {
        print "  " id " — " (moved_line[id] ? "dòng" : "") (moved_line[id] && moved_block[id] ? ", " : "") (moved_block[id] ? "khối mô tả" : "")
        any = 1
      }
    }
    if (!any) print "  (không có)"
    print "Bị giữ:"
    any = 0
    for (p = 1; p <= nids; p++) {
      id = order[p]
      if (reasons[id] != "") { print "  " id " — " reasons[id]; any = 1 }
    }
    if (!any) print "  (không có)"
    exit 0
  }
  insert_done_at = done_at + (b[done_at + 1] == "" ? 1 : 0)
  for (i = 1; i <= nb; i++) {
    skip = 0
    for (k = 1; k <= nblocks; k++)
      if (move_block[k] && i >= starts[k] && i <= ends[k]) { skip = 1; break }
    if (!skip && !move_row[i]) {
      print rewrite_remaining(b[i]) > out_b
    }
    if (i == insert_done_at) {
      for (j = in_at + 1; j < done_at; j++) {
        if (!move_row[j]) continue
        print rewrite_remaining(b[j]) > out_b
      }
    }
  }
  for (i = 1; i <= na; i++) {
    print a[i] > out_a
    if (i == archive_at) {
      for (k = 1; k <= nblocks; k++) {
        if (!move_block[k]) continue
        for (j = starts[k]; j <= ends[k]; j++) print rewrite_block(b[j]) > out_a
      }
    }
  }
  print rows + 0, blocks + 0
}
' <(git log --format=%s HEAD 2>/dev/null) work/backlog_archive.md work/backlog.md)" || exit $?

if [ "$mode" = dry ]; then
  printf '%s\n' "$result"
  exit 0
fi
before="$(wc -c < work/backlog.md | tr -d ' ')"
after="$(wc -c < "$out_b" | tr -d ' ')"
mv -- "$out_b" work/backlog.md || exit 2
mv -- "$out_a" work/backlog_archive.md || exit 2
set -- $result
printf 'archive-done: %s dòng, %s khối đã chuyển; work/backlog.md: %s → %s byte.\n' "$1" "$2" "$before" "$after"
