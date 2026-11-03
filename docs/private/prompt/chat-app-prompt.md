Khởi động đợt kiểm tra toàn bộ task trong work/backlog_CHAT.md, mỗi task một phiên Codex riêng. Trả lời tôi bằng tiếng Việt, văn xuôi. Việc này chỉ đọc: không sửa file nào trong repo, không tạo task, không commit, không xoá gì.

**Bước 1 — Kiểm tra vòng lặp đang chạy.** Chạy:

```bash
ps -axo pid,etime,command | grep -E '[k]iem-chat|[c]odex exec'
ls /Users/monghoaivu/Desktop/code/lean_wt/chat-review/ 2>/dev/null
```

Nếu đã có tiến trình `kiem-chat`, không khởi động thêm: chuyển thẳng tới bước 4 và chỉ báo tiến độ. Hai vòng song song sẽ làm trùng việc và ghi đè báo cáo của nhau.

**Bước 2 — Ghi script ra ngoài repo, đúng nguyên văn:**

```bash
mkdir -p /Users/monghoaivu/Desktop/code/lean_wt/chat-review
cat > /Users/monghoaivu/Desktop/code/lean_wt/chat-review/kiem-chat.sh <<'EOF'
#!/usr/bin/env bash
# Mỗi task CHAT một phiên Codex mới, chỉ đọc. Chạy lại thì bỏ qua task đã có báo cáo.
REPO=/Users/monghoaivu/Desktop/code/lean_ai_engineering_system
OUT="${OUT:-/Users/monghoaivu/Desktop/code/lean_wt/chat-review}"
cd "$REPO" || exit 1
mkdir -p "$OUT"
for id in $(grep -oE '^### CHAT-[0-9]+' work/backlog_CHAT.md | cut -d' ' -f2); do
  [ -s "$OUT/$id.md" ] && continue
  echo "$(date +%H:%M) $id"
  if ! codex exec -C "$REPO" -s read-only -m gpt-6-astra -o "$OUT/$id.tmp" \
    "Kiểm tra độc lập task $id trong work/backlog_CHAT.md. Chỉ đọc, không sửa file nào, không tự trả lời câu hỏi nghiệp vụ.
Đọc CLAUDE.md, mục 'Chung cho mọi bước' của sổ, entry $id, dòng của nó trong work/backlog.md, master_plan/CHAT_master_plan_banh_cuon_ba_thanh.md và các owner entry nêu ở 'Đứng trên'.
Đối chiếu: cửa và operationId có thật trong docs/product/3-be/openapi.yaml; phụ thuộc và U-XXX chặn còn đúng trạng thái; Acceptance và Verify kiểm chứng được; không trái ADR-136, ADR-137. Task đã Done thì đối chiếu thêm với file thực tế.
Báo cáo tiếng Việt. Dòng đầu là ĐẠT hoặc CÓ LỖI. Mỗi lỗi có file:dòng và bằng chứng. Câu nghiệp vụ chỉ liệt kê, không kết luận." \
    </dev/null >"$OUT/$id.log" 2>&1 || [ ! -s "$OUT/$id.tmp" ]; then
    echo "DỪNG ở $id, xem $OUT/$id.log. Chạy lại script để làm tiếp."; exit 1
  fi
  mv "$OUT/$id.tmp" "$OUT/$id.md"
done
cat "$OUT"/CHAT-*.md | codex exec -C "$REPO" -s read-only -m gpt-6-astra -o "$OUT/TONG-HOP.md" \
  "Đây là báo cáo kiểm tra từng task CHAT. Gộp lỗi trùng, tìm mâu thuẫn giữa các task (thứ tự, phụ thuộc, hai task cùng giành một việc), xác minh lại lỗi nặng trong repo, xếp theo mức nặng. Chỉ đọc, tiếng Việt." \
  >"$OUT/TONG-HOP.log" 2>&1 || { echo "DỪNG ở bước tổng hợp, xem $OUT/TONG-HOP.log. Chạy lại script để thử lại."; exit 1; }
echo "XONG: $OUT/TONG-HOP.md"
EOF
```

**Bước 3 — Khởi động tách khỏi phiên này.** Dùng `screen` như dưới đây, không dùng tiến trình nền của công cụ, vì Codex chạy nền sẽ chết theo phiên đã gọi nó. Lệnh cần chạy ngoài sandbox để Codex con có mạng.

```bash
D=/Users/monghoaivu/Desktop/code/lean_wt/chat-review
screen -dmS chat-review bash -c 'caffeinate -i bash "$0" >> "$1" 2>&1' "$D/kiem-chat.sh" "$D/chay.log"
```

**Bước 4 — Kiểm tra rồi báo cáo.** Đợi tới khi có thêm một file `CHAT-XX.md` mới, tối đa 10 phút. Mở file đó xem dòng đầu có phải ĐẠT hoặc CÓ LỖI không, đọc đuôi `chay.log`, và so `git status --short` trước với sau để chắc Codex không sửa repo. Sau đó kết thúc phiên, không đợi đủ 34 task: vòng lặp tự chạy tiếp.

Báo cáo cho tôi: đã xong bao nhiêu trên 34 task, đang ở task nào, và thời gian còn lại ước tính. Nếu log có dòng DỪNG thì nói rõ nguyên nhân đọc được trong file `.log` của task đó. Khi nguyên nhân là hết hạn mức, chỉ báo lại và để tôi tự chạy lại sau, vì script sẽ làm tiếp từ chỗ dở.

Không tự sửa lỗi nào mà báo cáo của Codex nêu. Đó chỉ là lời khai, sẽ được Claude đối chiếu với repo ở một task riêng, sau khi có `TONG-HOP.md`.


screen -ls