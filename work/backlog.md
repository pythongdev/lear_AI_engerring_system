# Backlog

## Ready

- [ ] T-010 `check-scope` đang tính file chưa track là "thay đổi ngoài scope"
- [ ] T-011 Kênh `phone_preorder` không thuộc lát cắt BA nào — kế hoạch gốc §3 · §4
- [ ] T-008 Chạy BA-00: dựng BA-03–BA-11 trong backlog (BA-01/02 đã xong)
- [ ] T-009 Gỡ dòng mẫu T-001 khỏi Ready
- [ ] T-001 Replace this with the first meaningful task.

Bốn task trên chạy **theo thứ tự**: T-010 → T-011 → T-008 → T-009.

- T-010 trước, vì mọi task sau đều chạy với prompt chưa commit trong `prompt/maintenance/` và
  sẽ đỏ gate vì đúng lý do sai đó.
- **T-011 phải xong trước T-008.** T-008 dựng BA-03–BA-11 trong backlog **từ bảng §11 của kế
  hoạch gốc**; nếu định nghĩa lát cắt của BA-04 còn thiếu `phone_preorder` thì T-008 chép đúng
  chỗ thiếu đó vào backlog rồi khoá lại — cùng cái bẫy đã bắt T-007 phải chạy trước.
- T-009 chạy trước T-008 thì Ready rỗng.

(T-007 xong 2026-08-30, nên kế hoạch gốc không còn con số kênh sai để T-008 chép vào backlog.)

### T-010 — `check-scope` tính file chưa track là thay đổi ngoài scope

**Prompt:** không có — phát hiện trong lúc chạy T-007, sửa ngay trong cùng phiên 2026-08-30.

**Goal:**
Gate chỉ đỏ vì thứ **task này** làm. `scripts/check-scope.sh` đọc `git status --untracked-files=all`
nên ba file `prompt/maintenance/*.md` đã nằm sẵn trong cây từ **trước** khi T-007 bắt đầu bị tính là
"thay đổi ngoài scope", và T-007 phải nới `work/scope.txt` chỉ để gate xanh. Một gate đỏ vì lý do
sai dạy người dùng bỏ qua nó — đắt hơn nhiều so với thứ nó bắt được.

**Scope:**
`scripts/check-scope.sh` · `CLAUDE.md` §5 · `quality/review-gate.md` Gate 3 · `docs/decisions.md` ·
`work/backlog.md` · `work/scope.txt`.

**Out of scope:**
`gate.sh`, `verify.sh`, `brief.sh`, `.claude/settings.json`. Không đổi cú pháp pattern của
`work/scope.txt`. Không đụng dữ kiện nghiệp vụ.

**Acceptance:**
1. File **đã được git theo dõi** mà đổi ngoài scope ⇒ `check-scope.sh` vẫn FAIL, exit 1 — hành vi
   này không được yếu đi.
2. File **chưa track** (`??`) nằm ngoài scope ⇒ **không** làm gate đỏ; được in thành một dòng
   `note:` để vẫn nhìn thấy, exit 0.
3. Chạy `./scripts/gate.sh` trên cây hiện tại (có `prompt/maintenance/` chưa track) với scope
   **không** chứa `prompt/maintenance/` ⇒ xanh.
4. Đầu file `check-scope.sh` nói rõ luật mới và **vì sao** — người đọc sau không tự ý siết lại.
5. `CLAUDE.md` §5 và `quality/review-gate.md` Gate 3 nói đúng hành vi mới (rà pointer, CLAUDE.md §7.2).
6. `docs/decisions.md` có ADR-003 ghi lựa chọn *ghi chú thay vì chặn*, kèm rủi ro đã chấp nhận:
   file **mới** do task tạo ra ngoài scope (ví dụ file `.md` nghi lễ, CLAUDE.md §3.8) nay chỉ được
   ghi chú, không bị chặn.
7. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
touch /tmp/x && cp /tmp/x ./ngoai-scope-untracked.md && ./scripts/check-scope.sh; echo "exit=$?"   # note, exit 0
echo x >> README.md && ./scripts/check-scope.sh; echo "exit=$?"                                    # FAIL, exit 1
git checkout README.md && rm -f ngoai-scope-untracked.md
```

### T-011 — Kênh `phone_preorder` không thuộc lát cắt BA nào

**Prompt:** `prompt/maintenance/04-phone-preorder-slice-L1.md` (L1)

**Goal:**
Mỗi kênh ở `master_plan/shop-facts.md` §2 có **đúng một** lát cắt BA nhận trách nhiệm mô tả luồng.
Hiện `phone_preorder` không có: kế hoạch gốc §3 chỉ có Epic A (tại bàn) và Epic B (ship/pickup), §4
cũng vậy, nên BA-03 và BA-04 không ai nhận nó. Đây đúng con bug mà `work/findings.md` F-003 đã đặt
tên: *"Kênh chỉ có trong bảng §2 mà không có trong luồng nào là bug."* T-007 sửa **con số** kênh,
không sửa chỗ thiếu **luồng** này.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).

### T-008 — Chạy BA-00 sau khi BA-01/BA-02 đã xong

**Prompt:** `prompt/maintenance/02-run-ba00-backlog-L3.md` (L3, bọc `prompt/BA/00-master-L3.md`)

**Goal:**
Backlog có đủ 11 task BA-01–BA-11 với thứ tự phụ thuộc và acceptance kiểm được. BA-00 chưa từng
chạy, nhưng prompt 01 thì đã chạy — nên chạy BA-00 nguyên văn sẽ **ghi đè** `docs/product.md`
§1/§2 bằng chỗ giữ. Prompt bọc nêu ba điều chỉnh cần thiết.

**Acceptance · Verify:** trong file prompt.

### T-009 — Gỡ dòng mẫu T-001 khỏi Ready

**Prompt:** `prompt/maintenance/03-retire-T-001-L0.md` (L0)

**Goal:**
`brief.sh` là `SessionStart` hook, in NEXT READY bằng dòng chưa tick đầu tiên — nên mọi phiên mới
đang được chỉ vào một dòng mẫu không phải task. Gỡ nó đi, không tick, không đưa xuống Done.

**Acceptance · Verify:** trong file prompt.


## In Progress

## Done

- [x] T-007 Kế hoạch gốc không còn nói "bốn kênh bán" — §2.2 · §9 · §11 · §12 (F-005)

### T-007 — Kế hoạch gốc còn nói "bốn kênh bán"

**Prompt:** `prompt/maintenance/01-fix-plan-channel-count-L1.md` (L1)

**Goal:**
`master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` không còn chỗ nào nói quán bán qua bốn kênh.
Nguy hiểm nhất là §12 dòng 277 — cổng chất lượng của cả giai đoạn BA; BA-11 tick theo nó sẽ đóng
giai đoạn BA trong lúc kênh thứ năm chưa được nghiệm thu.

**Acceptance · Verify:** sống trong file prompt, **không chép lại ở đây** (F-001 — một fact một
nhà; entry này trỏ, prompt giữ).

**Đã làm 2026-08-30:** bốn chỗ (không phải ba) đã sửa thành **năm** kênh —
`master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §2.2 (nay là câu trỏ về `shop-facts.md` §2,
không chép bảng), §9 (phạm vi MVP — chỗ thứ tư, chỉ lộ ra khi grep), §11 dòng BA-02, §12 cổng chất
lượng. Một dòng ghi chú có ngày để lại ở cuối §12. Bài học ghi ở `work/findings.md` **F-005**.

- [x] T-006 Quyền huỷ đơn gắn với chỗ đứng, không gắn chức vụ (chủ quán chốt 2026-08-30)

### T-006 — Chủ quán không đứng quầy thì huỷ đơn thế nào

**Goal:**
Chỗ suy luận duy nhất còn lại của T-005 — "chủ quán không đứng quầy mà muốn huỷ thì chưa ai nói" —
đã có lời chủ quán: **nhờ người đứng quầy bấm trên POS**. Không còn đường huỷ riêng cho chức vụ.

**Scope:**
`master_plan/shop-facts.md` · `docs/product.md` · `work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Không đổi ai được huỷ (§6.13 đã chốt ở T-005), không chạm luật duyệt đơn hay hoàn tiền.

**Acceptance:**
1. `shop-facts.md` §6.13 không còn câu "chưa ai nói"; thay bằng quyết định của chủ quán kèm ngày.
2. §6.13 nói rõ quyền huỷ gắn với **chỗ đứng (quầy/POS)**, không gắn **chức vụ**.
3. `shop-facts.md` §7.1 có dòng ngày 2026-08-30 cho quyết định này.
4. `docs/product.md` §1.3 và §2.4 khớp: chủ quán không có đường huỷ riêng; đoạn ghi "hệ quả suy
   ra" ở §2.4 được thay bằng lời chủ quán.
5. `grep -rn 'chưa ai nói\|hệ quả suy ra'` trong hai file trên không còn dính tới quyền huỷ.
6. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
grep -n 'chưa ai nói\|suy ra' master_plan/shop-facts.md docs/product.md
git status --porcelain
```

- [x] T-005 U-004 — chỉ người đứng quầy được huỷ đơn (chủ quán chốt 2026-08-30)

### T-005 — Ai được bấm huỷ một đơn

**Goal:**
U-004 — câu hỏi sinh ra từ luật huỷ đơn hotline ở T-004 — đã có lời giải của chủ quán: **người
đứng quầy**, thao tác trên máy POS ở quầy. Ghi vào owner, đóng U-004, sửa mọi pointer đang chờ nó.

**Scope:**
`master_plan/shop-facts.md` · `master_plan/prompt-fullstack.md` · `docs/product.md` ·
`prompt/BA/*.md` · `work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Không đổi luật huỷ đơn (đã chốt ở T-004), không đổi luật hoàn tiền, không chạm bảng giá.

**Acceptance:**
1. `shop-facts.md` §6 có quy tắc mới: **chỉ người đứng quầy được huỷ đơn**; tiêu đề §6 đổi từ
   "Mười hai" sang "Mười ba quy tắc" và mọi pointer đếm số quy tắc được sửa theo.
2. Hệ quả "chủ quán đứng quầy thì huỷ được" ghi là **hệ quả suy ra**, không trộn vào lời chủ quán.
3. `shop-facts.md` §7.1 có dòng ngày 2026-08-30 cho quyết định này.
4. `docs/product.md`: quyền huỷ nằm trong việc của nhân viên (§1.2) và của trạm quầy (§1.5);
   §2.4 gán đích danh người bấm huỷ; U-004 chuyển sang bảng đã có lời giải.
5. `grep -rn 'U-004'` không còn chỗ nào coi nó là câu hỏi đang mở.
6. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
grep -rn 'U-004' --include='*.md' .
grep -rn 'Mười hai quy tắc\|Mười ba quy tắc' --include='*.md' .
git status --porcelain
```

- [x] T-004 Ghi nhận sáu câu trả lời của chủ quán ngày 2026-08-30 (U-001–U-003, S-1–S-3)

### T-004 — Sáu câu trả lời của chủ quán 2026-08-30

**Goal:**
Sáu câu hỏi đang treo — ba unknown ở `docs/product.md` và ba chỗ suy luận ở
`master_plan/shop-facts.md` §7.2 — được chủ quán trả lời hết ngày 2026-08-30. Mỗi câu trả lời về
đúng owner của nó, kèm ngày và người chốt, và **mọi pointer đang nói "chưa ai xác nhận" phải được
sửa trong cùng lần thay đổi này** (CLAUDE.md §7.2).

**Scope:**
`master_plan/shop-facts.md` · `master_plan/00-scope.md` · `docs/product.md` · `prompt/BA/*.md` ·
`work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Không đổi một con số giá nào — S-1 được xác nhận **đúng như bảng §4.3 đang ghi**, đây là đổi
*trạng thái* của một dữ kiện, không phải đổi dữ kiện. Không sửa `work/findings.md` (F-004 là bản
ghi lịch sử của một bài học, không phải chỗ tra cứu trạng thái hiện tại).

**Acceptance:**
1. `shop-facts.md` §3 ghi cách phân trạm: quầy · tráng bánh · gấp bánh là ba trạm riêng, lấy canh
   và dọn bàn do cùng một người; chủ quán thỉnh thoảng đứng quầy.
2. `shop-facts.md` ghi: đơn đặt trước qua hotline mà khách tới ăn tại quán thì **huỷ** đơn đó,
   khách gọi lại bằng `qr_table` — không có đường chuyển đơn hotline thành phiên bàn.
3. `shop-facts.md` §6.4 ghi rõ **người đứng quầy** là người quyết định và ghi vết hoàn tiền.
4. `shop-facts.md` §4.3/§4.6 ghi phụ thu suất trứng ×5 là **chốt**, không còn chữ "suy luận";
   giá 20.000 / 25.000 / 30.000 **không đổi**.
5. `shop-facts.md` §7.1 có bốn dòng mới ngày 2026-08-30 cho bốn quyết định trên; §7.2 không còn
   mục nào và nói rõ là đã rỗng.
6. `docs/product.md`: U-001, U-002, U-003 chuyển sang mục đã có lời giải kèm câu trả lời và ngày;
   §1 và §2 phản ánh nội dung mới; mục "chưa ai xác nhận" ở §2 được gỡ.
7. `grep -rn 'S-1' --include='*.md' .` không còn chỗ nào nói S-1 là suy luận chưa xác nhận, trừ
   `work/findings.md` (bản ghi lịch sử) và chỗ ghi ngày nó được chốt.
8. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
grep -rn 'chưa ai xác nhận\|chưa xác nhận' --include='*.md' . | grep -v findings.md
grep -n '25.000' master_plan/shop-facts.md      # giá suất trứng không đổi
grep -n 'U-00' docs/product.md
git status --porcelain
```

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
