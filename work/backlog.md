# Backlog

## Ready

- [ ] T-001 Replace this with the first meaningful task.

## In Progress

## Done

- [x] T-003 Vòng cập nhật liên tục — brief đầu phiên + luật ghi trong phiên (CLAUDE.md §7)

### T-003 — Vòng cập nhật liên tục

**Goal:**
Mỗi phiên mới bắt đầu bằng trạng thái **hiện tại** của hệ thống, không phải trạng thái của ngày
tài liệu được viết. Việc đó phải là cơ chế (hook chạy tự động), không phải kỷ luật (nhớ đọc file).

**Scope:**
`CLAUDE.md` · `README.md` · `scripts/brief.sh` (mới) · `.claude/settings.json` ·
`docs/decisions.md` · `work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Mọi dữ kiện nghiệp vụ — không sửa một con số, một quy tắc, một finding nào. Không đổi `gate.sh`,
`verify.sh`, `check-scope.sh`. Không tạo file `.md` mới.

**Acceptance:**
1. `./scripts/brief.sh` chạy được từ repo sạch, exit 0, in ra: task In Progress, scope đã khai báo,
   task Ready kế tiếp, finding Open, unknown Open, ADR mới nhất, commit gần đây, ngày sửa cuối của
   từng file owner ở §2.
2. `brief.sh` **không chép** một dữ kiện nghiệp vụ nào — chỉ tên file, mã số, ngày (chống tái phạm
   F-001). `grep -E '[0-9]{1,3}\.000' scripts/brief.sh` không ra kết quả.
3. `.claude/settings.json` có hook `SessionStart` gọi `brief.sh`, và hook `Stop` cũ còn nguyên.
4. `CLAUDE.md` có §7 mô tả vòng: đầu phiên (brief tự động) → trong phiên (ghi ngay, kèm ngày) →
   cuối phiên (bàn giao). §8 là Definition of Done, có thêm dòng nhắc ghi nhận.
5. Cây thư mục ở `CLAUDE.md` §2 và `README.md` có `scripts/brief.sh`.
6. ADR-002 trong `docs/decisions.md` ghi lại lựa chọn cơ chế-thay-vì-kỷ-luật.
7. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/brief.sh; echo "exit=$?"
grep -E '[0-9]{1,3}\.000' scripts/brief.sh
python3 -c "import json;print(list(json.load(open('.claude/settings.json'))['hooks']))"
./scripts/gate.sh
```

- [x] T-002 Đảo nhà thật về `master_plan/shop-facts.md` (ADR-001)

### T-002 — Đảo nhà thật về `master_plan/shop-facts.md`

**Goal:**
Một fact một nhà. `shop-facts.md` sở hữu mọi dữ kiện quán; không còn bản chép thứ hai của bất kỳ
con số nào trong repo.

**Scope:**
`CLAUDE.md` · `master_plan/shop-facts.md` · `master_plan/00-scope.md` ·
`master_plan/prompt-fullstack.md` · `prompt/BA/*.md` · `docs/decisions.md` · `work/findings.md`.

**Out of scope:**
Nội dung nghiệp vụ — không sửa một con số hay quy tắc nào, chỉ đổi chỗ sở hữu và số mục tham chiếu.

**Acceptance:**
1. `CLAUDE.md` §2 ghi `shop-facts.md` là owner của shop facts.
2. `grep -rn '00-scope' --include='*.md' .` chỉ còn kết quả trong `00-scope.md` (file trỏ),
   `CLAUDE.md`, `work/findings.md`, `prompt/BA/README.md` và `docs/decisions.md` — tức chỉ ở chỗ
   nói *về* việc chuyển nhà, không ở chỗ tra cứu số.
3. Không tài liệu nào ngoài `shop-facts.md` chứa bảng giá.
4. Mọi tham chiếu §-số trong `prompt/BA/` trỏ đúng mục mới của `shop-facts.md`.
5. ADR-001 có mặt trong `docs/decisions.md`.
6. `./scripts/gate.sh` xanh.

**Verify:**
```bash
grep -rn '00-scope' --include='*.md' .
grep -rn '3.000\|9.000\|25.000' --include='*.md' master_plan/ prompt/ docs/
./scripts/gate.sh
```

## Task Detail Template

### T-XXX — Short title

**Goal:**  
What outcome is required.

**Scope:**  
What may change.

**Out of scope:**  
What must not change.

**Acceptance:**  
How correctness will be recognized.

**Verify:**  
Commands or checks to run.
