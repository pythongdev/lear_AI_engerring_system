# Backlog

## Ready

- [ ] T-001 Replace this with the first meaningful task.

## In Progress

## Done

- [x] BA-01 `docs/product.md` §1 — Actor và phạm vi hệ thống
- [x] BA-02 `docs/product.md` §2 — Kênh bán

### BA-01 / BA-02 — Actor, phạm vi hệ thống và kênh bán

**Prompt:** `prompt/BA/01-actors-channels-L1.md` (L1, chạy 2026-08-30)

**Goal:**
`docs/product.md` §1 và §2 mô tả được: hệ thống phục vụ những ai, mỗi actor được làm gì, quán bán
qua kênh nào và mỗi kênh khác nhau ở điểm nghiệp vụ nào.

**Scope:**
`docs/product.md` (§1, §2, mục Unknowns) · `work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Nội dung nghiệp vụ của §3–§8 `docs/product.md`. `docs/decisions.md`, `quality/invariants.md`,
`docs/architecture.md`, `master_plan/*` — đều là input, không phải sản phẩm.

**Acceptance:**
1. §1 có đúng 3 nhóm actor (Khách hàng · Nhân viên quán · Chủ quán), mỗi nhóm là danh sách hành
   động nghiệp vụ quan sát được → §1.1–§1.3.
2. §1 nêu ranh giới hệ thống: chịu trách nhiệm gì, không chịu trách nhiệm gì → §1.4.
3. §1 liệt kê đúng 5 trạm theo tên ở `master_plan/shop-facts.md` §3, mỗi trạm một câu → §1.5;
   không trạm thứ 6, chủ quán là vai ngoài 5 trạm.
4. §2 có bảng 5 kênh, mỗi dòng đủ: tên kênh · ai khởi tạo · có phiên bàn không · ai xác nhận ·
   định danh khách bắt buộc.
5. Đọc §2 biết ngay 3 kênh không gắn phiên bàn và 2 kênh ẩn danh theo bàn → §2.1.
6. §2 khẳng định chỉ có 5 kênh, và phân biệt Staff POS (đặt hộ tại bàn) với đặt trước qua hotline
   (không bàn) → mở đầu §2 và §2.3.
7. Với mỗi kênh, bảng §2 cho biết đơn có cần quầy duyệt trước khi xuống bếp không → cột 4 và §2.2.
8. Không câu nào gán quyền mà nguồn không nói; quyền suy đoán nằm ở Unknowns → U-001, U-002, U-003.

**Verify:**
```bash
./scripts/gate.sh
grep -n 'Delivery\|Pickup\|QR\|POS\|đặt trước\|hotline' docs/product.md
grep -c 'tráng bánh\|gấp bánh\|lấy canh\|dọn bàn\|quầy' docs/product.md
git status --porcelain
```

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
