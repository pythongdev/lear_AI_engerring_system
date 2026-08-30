<a id="top"></a>
# Backlog

Hai phần, đọc từ trên xuống: **cần làm** (`Ready`, `In Progress`) và **đã xong** (`Done`).
Cả hai là danh sách gạch đầu dòng, gọn trong một màn hình. Mô tả dài của từng task nằm ở
hai mục *Chi tiết* phía dưới, tách đúng theo hai phần trên.

| Mục | Nội dung |
|---|---|
| [Ready](#ready) | việc cần làm — checklist + thứ tự lấy |
| [In Progress](#in-progress) | task đang chạy |
| [Done](#done) | việc đã xong |
| [Chi tiết — việc cần làm](#chi-tiet-can-lam) | mô tả dài T-014…BA-11 + bảng mười câu hỏi §10 |
| [Chi tiết — việc đã xong](#chi-tiet-da-xong) | mô tả dài T-013…T-002 |
| [Vòng chạy một task L1](#vong-chay) | mười bước thủ tục từ nhận task tới khối commit |
| [Task Detail Template](#template) | khuôn viết một task mới |

Mỗi mục có link `↑ đầu file` ở cuối để quay lại bảng này.

<a id="ready"></a>
## Ready

Bảy việc bảo trì. **Một việc chặn chuỗi BA, làm trước: T-015.** Sáu việc còn lại không
chặn ai, chen vào lúc nào cũng được.

- [ ] T-015 §10 kế hoạch gốc: hai câu đã có lời giải, một câu hỏi hẹp hơn thực tế — chặn BA-10
- [ ] T-014 §2.1 kế hoạch gốc thiếu việc khách gọi điện đặt trước
- [ ] T-016 `work/scope.txt` được commit kèm pattern, hai lần
- [ ] T-009 Gỡ dòng mẫu T-001 khỏi Ready
- [ ] T-019 `prompt-fullstack.md` trỏ tới bảy đường không tồn tại — F-007
- [ ] T-021 `brief.sh` đọc Unknowns bằng hình dạng dòng, in sai cả hai chiều — F-008
- [ ] T-023 Hai commit trùng tên "T-020"; ba file `docs/` bị commit nhầm, một file mâu thuẫn §2 — F-009
- [ ] T-001 Replace this with the first meaningful task.

- **T-011 đã xong 2026-08-30** — dòng BA-04 ở §11 kế hoạch gốc nay ghi đủ ba kênh không gắn bàn,
  và §3 Epic B, §4.2, §5, §6, §12 cũng vậy. Khung và nhà thật (`master_plan/shop-facts.md` §5.2)
  nay nói cùng một luồng mang đi.
- **T-012 và T-013 đã xong 2026-08-30 — con bug T-011 mở ra nay đóng hết.** Cùng một kênh
  `phone_preorder`, bốn loại file: tài liệu tra cứu (xong từ trước), tài liệu khung (T-007, T-011),
  prompt (T-012) — ba loại F-005 kể tên — và loại thứ tư F-005 không kể, **bản xuất khẩu** (T-013). Luật rà chung ở `work/findings.md`
  **F-006**: grep theo **định danh** kênh, không theo con số — và đọc những file grep **không**
  ra kết quả, vì chỗ thiếu nằm ở đó.
- **T-023 dọn hậu quả đã commit của F-009 (2026-08-30) — cần chủ repo quyết, không tự làm.**
  Commit `0b3a337` mang subject của T-020 nhưng chứa 1096 dòng của ba file `docs/` chưa track;
  T-020 thật là `1b1d5f5`. Hai commit trùng tên làm `git revert` mất an toàn, và
  `docs/updatee_sýstem.md` nay đã track trong khi nó mô tả một cấu trúc sở hữu khác CLAUDE.md
  §2. **Sửa lịch sử hay để nguyên là quyền chủ repo**, nên task này dừng ở mức ghi.
- **T-016 nay gánh thêm phần kiểm của F-009.** Nó vốn chỉ lo `work/scope.txt` quên dọn; F-009
  cho thấy cùng một script family phải kiểm thêm **tập file đã `git add`** có nằm trong scope
  không. Gấp vào T-016, không mở task riêng (§3.8).
- **T-021 sinh ra từ T-020 (2026-08-30), không chặn ai nhưng chạm vào thứ mọi phiên đều dùng.**
  `brief.sh` đọc mục *Unknowns* bằng `grep` theo hình dạng dòng, nên nó vừa giấu U-005 vừa in
  U-004 đã đóng như đang mở. T-020 đã sửa **phía dữ liệu** để brief đọc đúng ngay hôm nay; chữa
  tận gốc là cho brief đọc **cấu trúc** như nó đang làm với findings — `work/findings.md`
  **F-008** (Open). Chạm `scripts/**` nên là task riêng, không nhét vào T-020.
- **T-019 sinh ra từ T-013 (2026-08-30), không chặn ai.** T-013 sửa chữ trong
  `master_plan/prompt-fullstack.md`; nó **không** sửa việc file đó trỏ tới bảy đường không tồn
  tại trong repo. Đó không phải lỗi chữ mà là câu hỏi *file này còn thuộc dự án nào* — ghi ở
  `work/findings.md` **F-007** (Open).
- **BA-04, BA-06 và BA-11 hết bị T-012 chặn (2026-08-30).** Scenario 2 ở
  `prompt/BA/10-acceptance-scenarios-L2.md` nay nêu đủ ba kênh và đòi diễn `phone_preorder`
  **không qua bước quầy duyệt**, nên tick BA-11 không còn đóng giai đoạn BA khi một kênh chưa
  ai nghiệm thu.
- **T-020 đã xong 2026-08-30, BA-04 và BA-06 hết bị nó chặn.** Chủ quán lật luật thu tiền ngay
  trong ngày đã chốt nó: đơn mang đi **được** trả trước, là tuỳ chọn. `shop-facts.md` §6.3 nay
  nói đúng thứ đó, nên hai task kia đọc vào không còn chép một luật đã chết. **Nhưng T-020 để
  lại U-005** (ai xác nhận tiền của đơn trả trước) — BA-06 không tick hết được nếu U-005 còn mở.
- **T-015 chặn BA-10** và nên xong trước BA-04, BA-06: §10 còn để mở hai câu đã chốt, task sau đọc
  vào sẽ biến luật đã chốt thành giả định (CLAUDE.md §3.5 cấm).
- T-016 là việc của hệ thống làm việc, không chạm dữ kiện quán — chạy song song với bất kỳ task nào.
- T-009 gỡ dòng mẫu T-001 khỏi Ready; chạy được ngay vì Ready đã có task thật.

Chuỗi BA chạy từ trên xuống. Thứ tự là cột "Cần xong trước" của §11 kế hoạch gốc; BA-01 và BA-02
đã xong 2026-08-30 nên BA-03, BA-04, BA-05 mở được ngay và chạy song song được.

- [ ] BA-03 `docs/product.md` §3.1 — lát cắt một suất tại bàn · cần BA-02
- [ ] BA-04 `docs/product.md` §3.2 — lát cắt một đơn mang đi (ba kênh) · cần BA-02 (T-011, T-012, T-020 xong)
- [ ] BA-05 `docs/product.md` §3.3 — lát cắt chủ quán đổi menu/giá · cần BA-02
- [ ] BA-06 `docs/product.md` §4 — quy tắc giá và thanh toán · cần BA-03, BA-04 (T-020 xong; **U-005 còn mở**)
- [ ] BA-07 `docs/product.md` §5 — vòng đời đơn, phiên bàn, công việc trạm · cần BA-03
- [ ] BA-08 `docs/product.md` §6 — ngoại lệ · cần BA-03–BA-07
- [ ] BA-09 `docs/product.md` §7 — phạm vi MVP · cần BA-01–BA-08
- [ ] BA-10 `docs/decisions.md` — quyết định và giả định · cần BA-01–BA-09
- [ ] BA-11 `docs/product.md` §8 — ba scenario nghiệm thu BA · cần BA-03–BA-10

Mỗi task chạm **một** mục tài liệu riêng, nên revert được độc lập: §3.1 · §3.2 · §3.3 · §4 · §5 ·
§6 · §7 · `docs/decisions.md` · §8. Hai task cùng chạm một mục là dấu hiệu chia việc sai.

Chi tiết từng task ở [**Chi tiết — việc cần làm**](#chi-tiet-can-lam).

[↑ đầu file](#top)

<a id="in-progress"></a>
## In Progress

<a id="done"></a>
## Done

Chi tiết từng task ở [**Chi tiết — việc đã xong**](#chi-tiet-da-xong).

- [x] T-022 Bản xuất khẩu hết chép số tiền của nhà thật — §4, §9.1, §9.4 nay trỏ `shop-facts.md` (2026-08-30)
- [x] T-020 Đơn mang đi được trả trước — §6.3 hết câu "không bao giờ thu trước", mở U-005 (2026-08-30)
- [x] T-013 Bản xuất khẩu `prompt-fullstack.md` không còn nói "4 kênh", lát cắt B phủ luồng mang đi (2026-08-30)
- [x] T-012 Bộ prompt `prompt/BA/` gọi luồng mang đi bằng ba kênh (F-006, lần rà thứ ba) (2026-08-30)
- [x] T-018 Gate 7 — hook chặn turn kết thúc mà chưa giao khối commit (ADR-004) (2026-08-30)
- [x] T-017 Kết thúc mỗi task/phiên giao sẵn nội dung commit (CLAUDE.md §6.1) (2026-08-30)
- [x] T-011 `phone_preorder` nay thuộc lát cắt Epic B — luồng mang đi ba kênh (2026-08-30)
- [x] T-008 Backlog có 11 task BA-01–BA-11, thứ tự phụ thuộc và acceptance kiểm được
- [x] T-010 Gate 3 chỉ chặn file git đang theo dõi; file chưa track chỉ được ghi chú (ADR-003)
- [x] T-007 Kế hoạch gốc không còn nói "bốn kênh bán" — §2.2 · §9 · §11 · §12 (F-005)
- [x] T-006 Quyền huỷ đơn gắn với chỗ đứng, không gắn chức vụ (chủ quán chốt 2026-08-30)
- [x] T-005 U-004 — chỉ người đứng quầy được huỷ đơn (chủ quán chốt 2026-08-30)
- [x] T-004 Ghi nhận sáu câu trả lời của chủ quán ngày 2026-08-30 (U-001–U-003, S-1–S-3)
- [x] BA-01 `docs/product.md` §1 — Actor và phạm vi hệ thống
- [x] BA-02 `docs/product.md` §2 — Kênh bán
- [x] T-003 Vòng cập nhật liên tục — brief đầu phiên + luật ghi trong phiên (CLAUDE.md §7)
- [x] T-002 Đảo nhà thật về `master_plan/shop-facts.md` (ADR-001)

[↑ đầu file](#top)

<a id="chi-tiet-can-lam"></a>
## Chi tiết — việc cần làm

### Mười câu hỏi §10 kế hoạch gốc — ai trả lời câu nào

Bốn câu **đã có lời giải trước khi chuỗi BA bắt đầu**; task tương ứng chỉ chép lời giải kèm nguồn,
**không** mở lại thành câu hỏi.

| §10 | Câu hỏi | Task | Trạng thái |
|---|---|---|---|
| 1 | Ai xác nhận / huỷ / sửa đơn | BA-07 | xác nhận **đã chốt** → `shop-facts.md` §6.2 · huỷ **đã chốt** → §6.13 (2026-08-30) · **sửa đơn còn mở** |
| 2 | Đơn đã xác nhận được sửa hay chỉ huỷ/tạo lại | BA-07 | còn mở |
| 3 | Món hết sau khi khách đã đặt | BA-08 | còn mở |
| 4 | Khách không trả được tiền thì phiên bàn ở đâu | BA-08 | còn mở |
| 5 | Có hoàn tiền không, ai được | BA-06 | **đã chốt** → `shop-facts.md` §6.4 — quầy quyết từng ca, phải ghi vết |
| 6 | Pickup có cần giờ hẹn bắt buộc | BA-04 | **đã chốt** → `shop-facts.md` §6.5 — bắt buộc |
| 7 | Delivery có quản lý trạng thái giao | BA-04 | **đã chốt** → `shop-facts.md` §6.7 — quán tự giao, có trạng thái "đang giao" |
| 8 | Doanh thu tính theo ngày nào, đơn huỷ/hoàn tiền ra sao | BA-06 | còn mở |
| 9 | Chủ quán đổi giá đang bán ngay lập tức được không | BA-05 | còn mở |
| 10 | Có lưu lịch sử thao tác nhân viên ở MVP không | BA-09 | còn mở |

Sáu câu còn mở đều được BA-10 gom lại lần cuối (`docs/decisions.md`): câu nào chốt được thì thành
ADR, câu nào chưa thì thành GIẢ ĐỊNH có mức rủi ro và người cần trả lời.

**S-1, S-2, S-3 không phải giả định.** Chủ quán xác nhận cả ba ngày **2026-08-30**
(`shop-facts.md` §7.1); §7.2 nay không còn mục nào. Task nào ghi chúng là "chưa xác nhận" là sai.

### T-014 — §2.1 kế hoạch gốc thiếu việc khách gọi điện đặt trước

**Prompt:** `prompt/maintenance/07-plan-actor-phone-order-L1.md` (L1)

**Goal:**
§2.1 *Người dùng chính* liệt kê việc khách làm là "Đặt ship · Đặt trước để tới lấy · Quét QR tại
bàn" — không có đường điện thoại; phía nhân viên cũng chỉ có "Đặt món hộ khách" (tức `staff_pos`).
`docs/product.md` §1.1 · §1.2 **đã** đúng từ BA-01, nên đây là chỗ khung lệch với cả nhà thật lẫn
tài liệu tra cứu — chỗ lệch **thứ bảy** của cùng một kênh. T-011 cố ý không sửa: §2.1 nằm ngoài
vòng rà của nó.

**Acceptance · Verify:** trong file prompt.

### T-015 — §10 kế hoạch gốc: hai câu đã có lời giải, một câu hỏi hẹp hơn thực tế

**Prompt:** `prompt/maintenance/08-plan-open-questions-scope-L1.md` (L1) · **chặn** BA-10

**Goal:**
§10 câu 6 ("Pickup có cần giờ hẹn bắt buộc không?") và câu 7 (trạng thái giao hàng) **đã có lời
giải** ở `shop-facts.md` §6.5 · §6.7, nhưng §10 vẫn để mở. Riêng câu 6 còn hỏi **hẹp hơn** thực tế:
mốc giờ bắt buộc với cả `pickup` **và** `phone_preorder` (§6.5). Câu 7 thì đúng phạm vi — trạng
thái "đang giao" chỉ có ở đơn giao tận nơi; đừng mở rộng nó cho ba kênh.

Đánh số 1–10 **không đổi**: `work/backlog.md` và `prompt/BA/09-decisions-assumptions-L2.md` trỏ
theo số thứ tự (`§10.6`).

**Acceptance · Verify:** trong file prompt.

### T-016 — `work/scope.txt` được commit kèm pattern, hai lần

**Prompt:** `prompt/maintenance/09-scope-not-cleared-L2.md` (L2 — đổi hành vi thứ mọi phiên đều chạy)

**Goal:**
Task kết thúc mà `work/scope.txt` còn pattern thì phải nhìn thấy ngay, không phụ thuộc ai nhớ dọn.
Đã hỏng hai lần: `5c41f65` (6 pattern) và `25f0f88` (8 pattern). Hậu quả ở hai chỗ — Gate 3 đỏ vì
lý do sai (hoặc xanh nhầm), và `brief.sh` in *"a task is open"* cho mọi phiên mới.

CLAUDE.md §3.8 chỉ cho dựng cơ chế **sau hai lần**; ngưỡng đã đạt, nên task này được phép — nhưng
là **cảnh báo, không chặn** (ADR-003), và chỉ kêu khi scope đã khai báo mà backlog không có task
nào ở *In Progress*. Cần một ADR và một finding — nhưng **hai số prompt viết ra đã bị lấy mất**:
ADR-004 là của T-018 (2026-08-30), F-007 là của T-013 (2026-08-30). Dùng số trống kế tiếp tại
thời điểm làm, đừng dùng số ghi trong prompt.

**Phạm vi mở rộng 2026-08-30 (F-009):** ngoài việc kêu khi `work/scope.txt` còn pattern, task
này gánh thêm phần kiểm **tập file đã `git add` có nằm trong scope không**. Lý do gộp: cùng một
script family, cùng một họ lỗi *commit nuốt thứ task không được phép chạm*, và đã trả giá bốn
lần (`5c41f65`, `25f0f88`, `128955a`, `0b3a337`). Hai ràng buộc bắt buộc, chi tiết ở F-009:
**không lật ADR-003** (Gate 3 vẫn không chặn vì file chưa track), và phần kiểm mới **cảnh báo,
không chặn**, đặt ở Gate 7 — nơi đã đọc khối commit.

**Acceptance · Verify:** trong file prompt — **phần mở rộng trên chưa có Acceptance**, phải viết
trước khi sửa code (CLAUDE.md §3, L2).

### T-023 — Hai commit trùng tên "T-020", và ba file `docs/` bị commit nhầm

**Prompt:** chưa có · **Finding:** `work/findings.md` **F-009** (Open) · L2

**Goal:**
Lịch sử git kể đúng thứ đã xảy ra, và `docs/` không còn file nào mâu thuẫn CLAUDE.md §2.

**Nói một câu, việc phải làm là gì:**
Quyết ba việc rồi thi hành: (a) hai commit trùng subject `T-020` xử thế nào, (b) ba file `docs/`
vừa bị track thì giữ, chuyển hay xoá, (c) riêng `docs/updatee_sýstem.md` mô tả cấu trúc sở hữu
khác §2 thì phần nào thành đề xuất có chủ, phần nào bỏ. Việc **không** phải làm: tự sửa lịch
sử git — đó là quyền chủ repo.

**Vì sao có task này:**
`0b3a337` (2026-08-30) mang subject *"T-020: đơn mang đi được trả trước…"* nhưng nội dung là
1096 dòng của ba file `docs/` chưa track, không một dòng nào của T-020; T-020 thật là `1b1d5f5`.
Cơ chế và ba lần trước ghi ở **F-009**.

**Không làm thì mất gì:**
- `brief.sh` in RECENT COMMITS cho mọi phiên mới (ADR-002), nên phiên sau đọc thấy **hai** commit
  cùng tên T-020 và tin cả hai là việc của T-020.
- `git revert` mất an toàn: revert nhầm cái thì hoặc không gỡ được gì, hoặc xoá âm thầm 1096 dòng.
- `docs/updatee_sýstem.md` nay là **nội dung repo đã track** mô tả một cấu trúc sở hữu khác §2.
  §2 nói hai chỗ mâu thuẫn thì chỗ kia là bug phải sửa ngay — bug đó đang nằm trong repo.

**Bẫy:**
- **Không `git push --force` hay rewrite lịch sử đã chia sẻ** nếu chưa có lệnh rõ ràng.
- **Đọc `updatee_sýstem.md` trước khi xoá.** 1010 dòng, có thể có đề xuất đáng giữ; xoá thẳng là
  vứt việc của người khác.

**Acceptance · Verify:** chưa viết — task này chưa có file prompt.

### T-009 — Gỡ dòng mẫu T-001 khỏi Ready

**Prompt:** `prompt/maintenance/03-retire-T-001-L0.md` (L0)

**Goal:**
`brief.sh` là `SessionStart` hook, in NEXT READY bằng dòng chưa tick đầu tiên — nên mọi phiên mới
đang được chỉ vào một dòng mẫu không phải task. Gỡ nó đi, không tick, không đưa xuống Done.

**Acceptance · Verify:** trong file prompt.

### T-021 — `brief.sh` đọc Unknowns bằng hình dạng dòng, in sai cả hai chiều

**Prompt:** chưa có · **Finding:** `work/findings.md` **F-008** (Open) · L2

**Goal:**
`scripts/brief.sh` in đúng danh sách unknown **đang mở** của `docs/product.md`, không phụ thuộc
vào việc người viết vắt dòng hay in đậm ở đâu.

**Nói một câu, việc phải làm là gì:**
Cho mục OPEN UNKNOWNS đọc **cấu trúc**, đúng cách mục OPEN FINDINGS đã làm (`brief.sh` dòng 72–78
bắt `^### F-` rồi đọc `**Status:**`). Việc **không** phải làm: nới regex cho khớp thêm vài hình
dạng — đó là chữa triệu chứng, hình dạng thứ ba sẽ lại trượt.

**Vì sao có task này:**
T-020 (2026-08-30) mở U-005 và brief **không** in nó ra, đồng thời vẫn in U-004 — câu đã đóng từ
trước — như đang mở. T-020 đã sửa phía dữ liệu nên brief đúng ngay hôm nay, nhưng luật "viết
`U-XXX` sao cho `grep` bắt được" là thứ dựa vào trí nhớ, đúng loại hỏng `work/findings.md` F-001
nói tới.

**Không làm thì mất gì:**
Brief là cơ chế ADR-002 dựa vào để **đẩy** trạng thái vào mỗi phiên, và nó cố ý `exit 0` ở mọi
đường lỗi — nên khi đọc sai thì không có gì kêu lên, phiên sau chỉ đơn giản tin bản sai. Một câu
hỏi nghiệp vụ bị giấu là một chỗ CLAUDE.md §3.5 bị vô hiệu: phiên sau không biết có câu phải hỏi
nên tự quyết.

**Bẫy hay sửa nhầm nhất:**
- **Đây là L2 vì chạm `scripts/**` — thứ chạy trong mọi phiên.** Sửa hỏng `brief.sh` thì mọi phiên
  sau mở ra với một brief sai hoặc rỗng. Có `scripts/*.test.sh` làm khuôn sẵn để viết test.
- **Giữ luật "brief không bao giờ chặn"** (CLAUDE.md §7.1): mọi đường lỗi vẫn phải `exit 0`.
- **Brief trỏ, không chép** — vẫn chỉ in định danh và tiêu đề câu hỏi, không in nội dung dữ kiện.

**Acceptance · Verify:** chưa viết — task này chưa có file prompt.

### T-019 — `prompt-fullstack.md` trỏ tới bảy đường không tồn tại

**Prompt:** chưa có · **Finding:** `work/findings.md` **F-007** (Open) · L1

**Goal:**
`master_plan/prompt-fullstack.md` là bản xuất khẩu, được **dán vào prompt của agent ngoài repo**.
Khối trích dẫn đầu file trỏ tới bốn tài liệu `design/**`, `quality/05-checklist.md`,
`quality/prompt_guiline.md` và `finding.md#f-67` — kiểm ngày 2026-08-30, **không đường nào tồn
tại**. Người đọc file này không có repo để `ls`, nên họ hoặc dừng vì thiếu đầu vào, hoặc tự bịa nội
dung của bảy file rồi coi là đã có nguồn.

**Không sửa được bằng cách sửa từng link.** Phải trả lời trước: *`prompt-fullstack.md` còn thuộc dự
án nào, xuất khẩu cho ai?* — bảy đường kia là (a) tài liệu của một repo khác, (b) tài liệu sẽ sinh
ra ở pha sau, hay (c) tàn dư của cấu trúc đã bỏ. Ba khả năng, ba cách sửa khác nhau. **Hỏi người,
đừng đoán** (CLAUDE.md §3.5).

Kèm theo, cùng loại nhưng nhẹ hơn: §7 hàng `0 · BA` bảo *"trả lời 3 câu chưa rõ ở §3.2"*, trong khi
§3.2 nay chỉ còn dòng *"Đã gộp vào §3.1"* và không giữ câu hỏi nào. T-013 cố ý không sửa câu đó vì
sửa là phải đoán ba câu ấy nay nằm ở đâu.

**Acceptance · Verify:** viết khi có lời giải cho câu hỏi trên.

### BA-03 — Lát cắt một suất tại bàn

**Prompt:** `prompt/BA/02-slice-dine-in-L2.md` (L2) · **Cần xong trước:** BA-02 (xong 2026-08-30)

**Goal:**
`docs/product.md` §3.1 mô tả trọn vòng đời một khách ăn tại quán — từ lúc bàn được mở tới lúc bàn
trở lại trạng thái trống — đủ để một người không biết code diễn lại được bằng nghiệp vụ.

**Scope:** `docs/product.md` §3.1 · `quality/invariants.md` (chỉ **thêm**) · `work/backlog.md`.

**Out of scope:** §3.2, §3.3, §4–§8 của `docs/product.md` · `docs/decisions.md` ·
`docs/architecture.md` · invariant do task khác viết.

**Acceptance:**
1. §3.1 có luồng chính đúng 15 bước theo §4.1 kế hoạch gốc, mỗi bước ghi actor thực hiện.
2. Có nhánh "đặt hộ tại quầy" (§4.3) và câu nói nó nhập vào phiên bàn nào.
3. Có câu khẳng định nhiều lượt gọi món tại một bàn tạo **một** lần thanh toán.
4. Có câu khẳng định khách gọi thêm lúc phiên đang chờ thanh toán vẫn vào cùng một hoá đơn, và
   bàn chưa được coi là trống ở thời điểm đó (`shop-facts.md` §6.1).
5. Có điều kiện để bàn trở lại trạng thái trống, và điều kiện đó gồm bước dọn bàn.
6. Có điểm mà đơn `qr_table` bị chặn khi quầy chưa xác nhận (`shop-facts.md` §6.2).
7. Nêu một đơn duyệt xong sinh việc ở những trạm nào, dùng đúng 5 tên trạm ở `shop-facts.md` §3.
8. Có ví dụ nổ thành phần lấy lại từ `shop-facts.md` §5.3, cho thấy số lượng bếp thấy khác số
   lượng trên hoá đơn.
9. Có câu khẳng định **mọi suất bán đều kèm bánh cuốn**, không chỉ combo.
10. `quality/invariants.md` có ít nhất bốn invariant: một bàn một phiên chưa thanh toán (tính cả
    lúc chờ thanh toán) · tính tiền theo phiên chứ không theo lượt gọi · bàn trống chỉ sau khi
    đóng phiên và dọn bàn · đơn đã duyệt sinh việc cho mọi trạm liên quan. Mỗi invariant có mục
    Verification không để trống.
11. §3.1 không chứa từ hiện thực kỹ thuật (websocket, queue, bảng dữ liệu).

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^### 3.1/,/^### 3.2/p' docs/product.md | grep -cE '^ *[0-9]+\.'   # 15 bước
grep -n 'tráng bánh\|gấp bánh\|canh\|dọn bàn\|quầy' docs/product.md
grep -nEi 'websocket|queue' docs/product.md                                # rỗng
git status --porcelain
```

### BA-04 — Lát cắt một đơn mang đi (ba kênh không gắn bàn)

**Prompt:** `prompt/BA/03-slice-ship-pickup-L2.md` (L2) · **Cần xong trước:** BA-02 (xong
2026-08-30) và T-011 (xong 2026-08-30).

**Goal:**
`docs/product.md` §3.2 mô tả trọn đường đi của một đơn không gắn bàn — từ lúc khách chọn món tới
lúc đơn hoàn thành — cho **cả ba** kênh `delivery`, `pickup`, `phone_preorder`, và nêu nó khác đơn
tại bàn ở chỗ nào.

Lát cắt này là **ba** kênh, không phải hai. Nguồn: `master_plan/shop-facts.md` §5.2 gộp cả ba kênh
không gắn bàn vào **một** luồng, và `prompt/BA/03-slice-ship-pickup-L2.md` đã phủ đủ ba. Dòng BA-04
ở §11 kế hoạch gốc từng viết "ship/pickup"; T-011 đã sửa **2026-08-30**, nên khung và nhà thật nay
khớp nhau.

**Scope:** `docs/product.md` §3.2 · `quality/invariants.md` (chỉ **thêm**) · `work/backlog.md`.

**Out of scope:** §3.1, §3.3, §4–§8 của `docs/product.md` · `docs/decisions.md` ·
`docs/architecture.md`.

**Acceptance:**
1. §3.2 có luồng đúng 9 bước theo §4.2 kế hoạch gốc, mỗi bước ghi actor.
2. §3.2 phủ **ba** kênh không gắn bàn và nói `phone_preorder` khác `staff_pos` ở chỗ nào
   (`docs/product.md` §2.3).
3. Có đường đi của đơn `phone_preorder` từ lúc nhân viên nghe máy tới lúc đơn hoàn thành, gồm
   **cả hai** kiểu kết thúc — khách tới lấy hoặc quán giao (`shop-facts.md` §5.2).
4. Có câu khẳng định đơn mang đi không gắn phiên bàn và được thanh toán độc lập.
5. Nêu thông tin liên hệ tối thiểu theo từng kênh: số điện thoại bắt buộc cả ba kênh, địa chỉ bắt
   buộc khi giao tận nơi, giờ hẹn bắt buộc với `pickup` và `phone_preorder` — tra
   `shop-facts.md` §6.5, ghi là **đã chốt 2026-08-30**, không đánh dấu suy luận. → §10 câu 6.
6. Nêu đơn giao tận nơi mang trạng thái **"đang giao"** và quán tự đi giao
   (`shop-facts.md` §6.7). → §10 câu 7.
7. Nêu giờ bán 06:00–11:00 và phí ship 0đ, không đơn tối thiểu — bằng số, không viết chung chung.
8. Có hành vi khi đặt ngoài giờ bán (đơn bị từ chối, khách nhìn thấy gì) và khi chủ quán tạm dừng
   nhận đơn, kèm câu khẳng định nút tạm dừng **thắng** giờ mở cửa (`shop-facts.md` §6.8).
9. Có đoạn "Khác gì so với đơn tại bàn" liệt kê ít nhất 3 khác biệt nghiệp vụ.
10. `quality/invariants.md` có hai invariant: đơn mang đi không thuộc phiên bàn nào · không tạo
    được đơn ngoài giờ bán hoặc khi đang tạm dừng nhận đơn.
11. §3.2 không nói về nhà cung cấp vận chuyển, bản đồ, hay cách tính phí ship theo bậc.

**Verify:**
```bash
./scripts/gate.sh
grep -n 'phone_preorder' docs/product.md                       # có mặt trong §3.2
sed -n '/^### 3.2/,/^### 3.3/p' docs/product.md | grep -cE '^ *[0-9]+\.'   # 9 bước
grep -n 'đang giao\|06:00\|0đ' docs/product.md
git status --porcelain
```

### BA-05 — Lát cắt chủ quán thay đổi menu/giá

**Prompt:** `prompt/BA/04-slice-menu-price-change-L2.md` (L2) · **Cần xong trước:** BA-02 (xong
2026-08-30)

**Goal:**
`docs/product.md` §3.3 chốt nguyên tắc lịch sử đơn hàng: đơn mới dùng menu/giá mới, đơn cũ giữ
nguyên tên món và giá tại thời điểm đặt, kể cả khi món đã ngừng bán.

**Scope:** `docs/product.md` §3.3 · `quality/invariants.md` (chỉ **thêm**) · `work/backlog.md`.

**Out of scope:** §3.1, §3.2, §4–§8 của `docs/product.md` · `docs/decisions.md` ·
`docs/architecture.md`.

**Acceptance:**
1. §3.3 mô tả luồng trước/sau khi đổi giá và nêu thời điểm giá mới bắt đầu có hiệu lực.
2. Có câu khẳng định đơn đặt trước thời điểm đổi giá giữ nguyên tổng tiền.
3. Có câu khẳng định món đã ngừng bán không còn trong menu mới nhưng vẫn hiện đúng tên và giá
   trong đơn cũ.
4. Có hành vi khi tổ hợp món/option không hợp lệ: đơn bị từ chối, không tự sửa thành hợp lệ; nêu
   đích danh ví dụ Chay + Nhiều nhân (`shop-facts.md` §4.4).
5. §3.3 phủ cả bốn chiều đổi giá: giá thành phần · phụ thu nhân · phụ thu lượng nhân · thành phần
   một suất (`shop-facts.md` §4.5).
6. §3.3 không chép bảng giá; ví dụ minh hoạ ghi nguồn `shop-facts.md` §4.2–§4.3.
7. Nêu trạng thái của đơn đang dở khi giá đổi — hoặc ghi thành câu hỏi mở nếu chưa chốt được.
8. `quality/invariants.md` có hai invariant: đơn đã tạo không đổi giá và tên món khi menu đổi ·
   tổ hợp món/option không hợp lệ bị từ chối. Invariant lịch sử đơn có Verification mô tả được
   kịch bản: đổi giá món → mở đơn cũ → tổng tiền không đổi.
9. §3.3 không mô tả cách lưu dữ liệu (bảng, cột, version, snapshot).

**Câu hỏi §10 gắn vào task này:** câu 9 — chủ quán có được đổi giá đang bán ngay lập tức không.
**Còn mở**; BA-05 hỏi người, không tự chốt. Chưa có lời giải thì ghi GIẢ ĐỊNH kèm mức rủi ro và
chuyển sang BA-10.

**Verify:**
```bash
./scripts/gate.sh
grep -n 'Chay' docs/product.md
grep -n 'shop-facts.md §4' docs/product.md                     # ví dụ có ghi nguồn
grep -nEi 'snapshot|version' docs/product.md                   # rỗng
git status --porcelain
```

### BA-06 — Quy tắc giá và thanh toán

**Prompt:** `prompt/BA/05-pricing-payment-L2.md` (L2) · **Cần xong trước:** BA-03, BA-04

**Goal:**
`docs/product.md` §4 chốt toàn bộ quy tắc nghiệp vụ về tiền: giá từ đâu ra, tổng tiền xác định lúc
nào, thu bằng cách nào, đối soát dựa trên cái gì.

**Scope:** `docs/product.md` §4 · `quality/invariants.md` (chỉ **thêm**) · `work/backlog.md`.

**Out of scope:** §1–§3, §5–§8 của `docs/product.md` · `docs/decisions.md` · `docs/architecture.md`.

**Acceptance:**
1. §4 nêu nguồn của giá và câu khẳng định khách không tự đặt được giá.
2. §4 nêu thời điểm tổng tiền được xác định, và điều gì xảy ra nếu giá menu đổi sau thời điểm đó.
3. §4 mở đầu bằng luật "giá một suất = tổng giá thành phần" và phân biệt bảng giá **thành phần**
   (`shop-facts.md` §4.2) với bảng giá **một suất** (§4.3).
4. §4 nêu quy tắc phụ thu **+1.000 mỗi phần nhận nhân**, và nói ×1 / ×4 / ×5 là hệ quả.
5. §4 nêu mặc định khi khách không chọn gì: nhân Thịt, lượng Thường.
6. §4 có bảng 11 tổ hợp bắt buộc phủ theo `shop-facts.md` §4.8; ca 11 ghi rõ **bị từ chối**.
7. Ba ca suất trứng đứng riêng ghi phụ thu ×5 là **đã chốt 2026-08-30**, không đánh dấu suy luận.
8. §4 **không chép** bảng giá; chỗ cần số thì trỏ `shop-facts.md` §4.2–§4.3.
9. Không có câu nào nói phụ thu "không nhân theo số phần bếp làm" — câu đó đã bị gỡ 2026-08-29,
   thấy nó quay lại là bug.
10. Có bảng phân biệt đơn vị thanh toán theo kênh: tại bàn = phiên · mang đi = đơn.
11. Liệt kê đúng 2 phương thức thanh toán, mỗi phương thức nói ai xác nhận đã thu được tiền.
12. Có trường hợp thanh toán chưa xác nhận được: phiên/đơn ở trạng thái nào, bàn có được giải
    phóng không.
13. Nêu cơ sở đối soát cuối ngày: sổ giấy và tiền trong két, ngưỡng lệch chấp nhận = **0đ**
    (`shop-facts.md` §6.10).
14. Có câu khẳng định doanh thu một ngày = tiền từ phiên bàn **cộng** tiền từ đơn mang đi, và một
    khoản tiền chỉ thuộc một trong hai (`shop-facts.md` §6.9).
15. `quality/invariants.md` có ít nhất ba invariant: tổng tiền một phiên bằng tổng các đơn thuộc
    phiên · giá áp cho một đơn không đổi sau khi đơn được tạo · không có thao tác đổi tiền nào
    không truy vết lại được.
16. Không có tên cổng thanh toán hay ngân hàng cụ thể.

**Câu hỏi §10 gắn vào task này:**
- Câu 5 — có hoàn tiền không, ai được: **đã chốt** → `shop-facts.md` §6.4. Quầy quyết từng ca,
  **mọi lần hoàn phải để lại vết** (hoàn bao nhiêu, đơn nào, ai bấm, lý do gì) và người đứng quầy
  là người ghi vết. Chép lời giải, đừng mở lại thành câu hỏi.
- Câu 8 — doanh thu tính theo ngày nào, đơn huỷ/hoàn tiền vào đâu: **còn mở**. Hỏi người; chưa có
  lời giải thì GIẢ ĐỊNH + rủi ro, chuyển BA-10.

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^## 4\./,/^## 5\./p' docs/product.md | grep -c '^|'    # bảng 11 tổ hợp + bảng đơn vị
grep -n '6.4\|6.9\|6.10' docs/product.md                        # có trỏ nguồn hoàn tiền/đối soát
grep -nE '[0-9]{2}\.000' docs/product.md                        # không chép bảng giá
git status --porcelain
```

### BA-07 — Vòng đời đơn, phiên bàn và công việc trạm

**Prompt:** `prompt/BA/06-lifecycles-L2.md` (L2) · **Cần xong trước:** BA-03

**Goal:**
`docs/product.md` §5 định nghĩa ba vòng đời nghiệp vụ — đơn, phiên bàn, công việc trạm — với các
trạng thái, chuyển tiếp hợp lệ, ai kích hoạt mỗi chuyển tiếp, và trạng thái kết thúc.

**Scope:** `docs/product.md` §5 · §3.1–§3.3 **chỉ khi** phải đổi tên trạng thái cho khớp §5 (đổi
tên, không đổi nghĩa) · `quality/invariants.md` (chỉ **thêm**) · `work/backlog.md`.

**Out of scope:** §1, §2, §4, §6–§8 của `docs/product.md` · nội dung nghiệp vụ của §3 ·
`docs/decisions.md` · `docs/architecture.md`.

**Acceptance:**
1. §5 có ba bảng chuyển trạng thái; mỗi dòng gồm trạng thái nguồn · sự kiện · trạng thái đích ·
   ai kích hoạt.
2. Mỗi vòng đời nêu trạng thái bắt đầu và các trạng thái kết thúc.
3. Có câu khẳng định chuyển tiếp không nằm trong bảng thì bị từ chối.
4. Nêu quan hệ giữa ba vòng đời: phiên bàn chỉ vào `Chờ thanh toán` khi các đơn của nó ở trạng
   thái nào; đơn chỉ `Hoàn thành` khi công việc trạm ở trạng thái nào.
5. Mọi tên trạng thái xuất hiện ở §3.1–§3.3 đều có trong §5, không còn tên lạc.
6. Có điều kiện chuyển `Bàn cần dọn → Trống` và ai xác nhận đã dọn (trạm `don_ban`).
7. Bảng phiên bàn có đường quay lại từ `Chờ thanh toán` khi khách gọi thêm, kèm câu khẳng định
   `Chờ thanh toán` vẫn là phiên **chưa thanh toán**.
8. §5 nói vòng đời "công việc trạm" áp cho **một việc ở một trạm**, và một đơn có nhiều việc chạy
   song song ở các trạm khác nhau.
9. `quality/invariants.md` có hai invariant: chuyển trạng thái không hợp lệ bị từ chối · phiên bàn
   không thể `Đã đóng` khi còn đơn chưa hoàn thành hoặc chưa huỷ.
10. Không có tên trạng thái viết kiểu mã (`ORDER_PENDING`, `status=2`).

**Câu hỏi §10 gắn vào task này:**
- Câu 1 — ai xác nhận / huỷ / sửa đơn. Hai phần **đã chốt**: xác nhận → `shop-facts.md` §6.2
  (đơn khách tự gửi phải qua quầy; `staff_pos` và `phone_preorder` thì không); huỷ → §6.13
  (**chỉ người đứng quầy**, quyền gắn với chỗ đứng chứ không gắn chức vụ, chốt 2026-08-30).
  **Phần "sửa đơn" chưa ai nói** — đó là chỗ còn mở của câu này.
- Câu 2 — đơn đã xác nhận được sửa hay chỉ huỷ rồi tạo lại: **còn mở**, cùng gốc với phần trên.
  Hỏi người; chưa có lời giải thì GIẢ ĐỊNH + rủi ro, chuyển BA-10.

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^## 5\./,/^## 6\./p' docs/product.md | grep -c '^|'    # ba bảng chuyển trạng thái
grep -nE 'ORDER_[A-Z]+|status *=' docs/product.md               # rỗng
git status --porcelain
```

### BA-08 — Ngoại lệ

**Prompt:** `prompt/BA/07-exceptions-L2.md` (L2) · **Cần xong trước:** BA-03–BA-07

**Goal:**
`docs/product.md` §6 chốt cách quán xử lý từng ngoại lệ quan trọng, ở mức nghiệp vụ, đủ để nhân
viên biết phải làm gì mà không cần hỏi chủ quán.

**Scope:** `docs/product.md` §6 · `docs/decisions.md` (ghi GIẢ ĐỊNH cho ngoại lệ chưa có lời
giải) · `work/findings.md` (khi phát hiện mâu thuẫn giữa hai quy tắc đã chốt) · `work/backlog.md`.

**Out of scope:** §1–§5, §7–§8 của `docs/product.md` · `quality/invariants.md` (BA-08 mô tả cách
xử lý, không thêm bất biến) · `docs/architecture.md`.

**Acceptance:**
1. §6 có bảng phủ đúng 14 tình huống ở §8 kế hoạch gốc, không thiếu dòng nào.
2. Mỗi dòng có đúng 4 cột: tình huống · ai xử lý · kết quả với đơn/phiên (trạng thái có trong §5) ·
   kết quả với tiền.
3. Mọi tên trạng thái trong §6 tìm được trong §5.
4. Tình huống chưa chốt được đánh dấu `⚠ Chưa chốt — xem docs/decisions.md`; không dòng nào bị bỏ
   trống lặng lẽ.
5. Ba tình huống đã có lời giải — gọi thêm khi đang thu tiền (`shop-facts.md` §6.1) · tạm dừng
   nhận đơn (§6.8) · mất điện/mất mạng/POS hỏng (§6.11) — **không** bị đánh dấu Chưa chốt.
6. Mỗi tình huống chưa chốt có một mục tương ứng trong `docs/decisions.md` kèm mức rủi ro.
7. Không dòng nào mô tả cách hệ thống kỹ thuật xử lý (retry, hàng đợi, offline cache).
8. Hai quy tắc đã chốt mà mâu thuẫn nhau thì có finding trong `work/findings.md`.

**Câu hỏi §10 gắn vào task này:**
- Câu 3 — món hết sau khi khách đã đặt: thay thế, huỷ phần đó, hay huỷ cả đơn; và nếu chỉ hết
  **một thành phần** của suất thì sao. **Còn mở.**
- Câu 4 — khách không thanh toán được thì phiên bàn giữ ở trạng thái nào. **Còn mở.**
Cả hai: hỏi người, không tự chốt; chưa có lời giải thì GIẢ ĐỊNH + rủi ro trong `docs/decisions.md`.

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^## 6\./,/^## 7\./p' docs/product.md | grep -c '^| '   # 14 dòng tình huống
grep -n 'Chưa chốt' docs/product.md docs/decisions.md           # khớp đôi một
grep -nEi 'retry|offline cache|hàng đợi' docs/product.md        # rỗng
git status --porcelain
```

### BA-09 — Phạm vi MVP

**Prompt:** `prompt/BA/08-mvp-scope-L1.md` (L1) · **Cần xong trước:** BA-01–BA-08

**Goal:**
`docs/product.md` §7 chốt danh sách năng lực có trong MVP và danh sách những thứ **không** làm ở
giai đoạn đầu, để mọi task sau có chỗ đối chiếu khi bị đề nghị mở rộng.

**Scope:** `docs/product.md` §7 · `work/backlog.md`.

**Out of scope:** §1–§6, §8 của `docs/product.md` · `docs/decisions.md` ·
`quality/invariants.md` · `docs/architecture.md`.

**Acceptance:**
1. §7 có hai danh sách tách bạch: "Trong MVP" và "Ngoài MVP (giai đoạn đầu không làm)".
2. "Trong MVP" phủ đúng 14 hạng mục ở §9 kế hoạch gốc. Hạng mục về kênh bán ghi là **năm** kênh
   theo `shop-facts.md` §2, kèm một dòng nói kế hoạch gốc viết lúc chưa có `phone_preorder`.
3. Mỗi hạng mục "Trong MVP" trỏ tới mục §1–§6 mô tả nó.
4. Mỗi hạng mục "Ngoài MVP" có một câu lý do.
5. Có câu khẳng định yêu cầu ngoài danh sách MVP không được làm trong giai đoạn này mà phải vào
   `work/backlog.md`.
6. "Ngoài MVP" nêu đích danh ít nhất: khuyến mãi/giảm giá · tích điểm · tách/gộp bàn · đặt bàn
   trước, cộng đúng 4 dòng ở `shop-facts.md` §6.12 với lý do là *chủ quán đã quyết*, không phải
   *để sau*.
7. Đối soát cuối ngày và quy trình sổ giấy nằm trong "Trong MVP".
8. Không hạng mục nào là công việc kỹ thuật thuần (cấu trúc dữ liệu, CI).

**Câu hỏi §10 gắn vào task này:** câu 10 — có lưu lịch sử thao tác của nhân viên ở MVP không.
**Còn mở**; quyết ở đây thì ghi vào §7 kèm ngày và người quyết, chưa quyết được thì chuyển BA-10.

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^## 7\./,/^## 8\./p' docs/product.md | grep -c '^- '   # 14 + danh sách ngoài MVP
grep -n 'năm kênh\|5 kênh' docs/product.md                      # phải có
grep -c 'phone_preorder' docs/product.md                        # kênh thứ năm có tên trong §7
git status --porcelain
```

### BA-10 — Quyết định và giả định BA

**Prompt:** `prompt/BA/09-decisions-assumptions-L2.md` (L2) · **Cần xong trước:** BA-01–BA-09

**Goal:**
`docs/decisions.md` chứa toàn bộ quyết định BA đã chốt và toàn bộ giả định chưa chốt, mỗi giả định
có mức rủi ro và người cần trả lời — không còn câu hỏi nghiệp vụ nào nằm rải rác trong đầu ai.

**Task này không rỗng dù S-1–S-3 đã chốt.** Việc của nó không phải "gom giả định còn sót": nó
phải viết ra ADR cho mọi thứ đã chốt — hiện `docs/decisions.md` mới có ADR-001–ADR-003 và cả ba
đều là quyết định **về cách vận hành repo**, không có ADR nghiệp vụ nào. Còn lại: **sáu** câu §10
đang mở (2, 3, 4, 8, 9, 10) cộng phần "sửa đơn" của câu 1, mọi mục Unknowns của prompt 01–08, và ba mục
S-1–S-3 phải được ghi ở dạng **ADR đã chốt 2026-08-30**, không phải GIẢ ĐỊNH.

**Scope:** `docs/decisions.md` · `docs/product.md` (**chỉ** thêm dòng tham chiếu `→ ADR-00N` tại
chỗ quy tắc liên quan) · `work/backlog.md`.

**Out of scope:** nội dung nghiệp vụ đã chốt ở §1–§8 `docs/product.md` ·
`quality/invariants.md` · `docs/architecture.md`.

**Acceptance:**
1. 10 câu hỏi ở §10 kế hoạch gốc đều có mục tương ứng trong `docs/decisions.md`, dạng ADR hoặc
   GIẢ ĐỊNH, không câu nào thiếu.
2. S-1, S-2, S-3 đều có mục, ở dạng **ADR** (chốt 2026-08-30), không phải GIẢ ĐỊNH. ADR của S-1
   ghi con số đã chốt (25.000, ×5) và nói rõ nó từng là suy luận tới 2026-08-30.
3. Mọi mục Unknowns của prompt 01–08 đều xuất hiện trong file, không sót mục nào.
4. Sáu câu đã có lời giải — giờ hẹn pickup · phí ship 0đ · khách QR ẩn danh · gọi thêm khi đang
   thu tiền · `phone_preorder` là kênh thứ năm · giá suất giò — nằm ở dạng **ADR**, và phần "Why"
   trỏ về `shop-facts.md` kèm mục số và ngày chốt ở §7.1.
5. Không mục nào về giá bị ghi là "chưa biết" hay "giả định".
6. Mỗi ADR có đủ 4 phần: Decision · Why · Rejected alternatives · Applies to.
7. Mỗi GIẢ ĐỊNH có đủ: nội dung · mức rủi ro · hậu quả nếu sai · người cần trả lời.
8. Không mục nào vừa là quyết định vừa không nói được ai đã quyết.
9. Đầu file có bảng tổng hợp: ID | Trạng thái (Đã chốt / Giả định) | Rủi ro | Chặn việc gì.
10. Mỗi quy tắc trong `docs/product.md` bắt nguồn từ một quyết định đều có tham chiếu `→ ADR-00N`.
11. Không có quyết định về công nghệ hay kiến trúc.

**Verify:**
```bash
./scripts/gate.sh
grep -c '^### ADR-\|^### GIẢ ĐỊNH' docs/decisions.md
grep -n 'S-1\|S-2\|S-3' docs/decisions.md          # cả ba ở dạng ADR
grep -n 'ADR-0' docs/product.md                    # tham chiếu ngược
git status --porcelain
```

### BA-11 — Ba scenario nghiệm thu BA

**Prompt:** `prompt/BA/10-acceptance-scenarios-L2.md` (L2) · **Cần xong trước:** BA-03–BA-10

**Goal:**
`docs/product.md` §8 có ba scenario nghiệm thu diễn lại được bằng nghiệp vụ thuần, và kết quả chạy
thử ba scenario đó chứng minh tài liệu BA không còn lỗ hổng chặn System Design.

**Scope:** `docs/product.md` §8 · `work/findings.md` (lỗ hổng phát hiện khi diễn scenario) ·
`work/backlog.md` (cập nhật trạng thái BA-01–BA-11).

**Out of scope:** §1–§7 của `docs/product.md` — thấy sai/thiếu thì **không tự sửa**: ghi finding và
mở lại task BA tương ứng. `docs/decisions.md` · `quality/invariants.md`.

**Acceptance:**
1. §8 có đúng 3 scenario; mỗi scenario có bối cảnh · các bước · kết quả mong đợi kiểm được
   đúng/sai.
2. Scenario 1 nêu số lần thanh toán = 1 dù có nhiều lượt gọi món, và trạng thái cuối của bàn là
   `Trống`.
3. Scenario 1 có ít nhất một lượt gọi thêm **sau khi quầy bắt đầu thu tiền**, kết quả vẫn 1 hoá đơn.
4. Scenario 1 có bước kiểm số lượng bếp nhận được (6 bánh · 2 trứng · 2 giò · 1 nước chấm) khác số
   lượng trên hoá đơn (2 suất), và tổng tiền **68.000đ** tra từ `shop-facts.md` §4.3.
5. Scenario 2 nêu đơn không gắn phiên bàn, trạng thái cuối là `Hoàn thành`, và có ít nhất một lượt
   dùng kênh `phone_preorder`.
6. Scenario 3 có món cụ thể, giá trước và giá sau tra từ `shop-facts.md` §4.3, và câu khẳng định
   tổng tiền đơn cũ không đổi sau khi giá menu đổi.
7. Mỗi bước trong cả 3 scenario trỏ tới mục §1–§7 chứa quy tắc tương ứng.
8. Có checklist cổng chất lượng BA (9 mục ở §12 kế hoạch gốc) với trạng thái tick thật; không tick
   mục chưa đạt. Mục "không còn business rule quan trọng bị suy đoán" chỉ được tick khi mọi câu
   hỏi đang mở ở `docs/product.md` → Unknowns đã đóng.
9. Mọi lỗ hổng phát hiện khi diễn scenario có finding trong `work/findings.md` kèm task BA cần mở
   lại.
10. `work/backlog.md`: task BA nào đã xong thì ở Done; task phải mở lại thì quay về Ready kèm lý do.
11. Không bước nào trong scenario mô tả thao tác kỹ thuật.

**Verify:**
```bash
./scripts/gate.sh
sed -n '/^## 8\./,/^## Unknowns/p' docs/product.md | grep -c '^### '   # 3 scenario
grep -n '68.000' docs/product.md
grep -n 'phone_preorder' docs/product.md
./scripts/brief.sh | sed -n '/NEXT READY/,+3p'
git status --porcelain
```

[↑ đầu file](#top)

<a id="chi-tiet-da-xong"></a>
## Chi tiết — việc đã xong

### T-022 — Bản xuất khẩu còn chép ba con số tiền của nhà thật

**Prompt:** không có (task sinh trong phiên 2026-08-30, từ mục *còn chưa giải quyết* của T-013) · L1
· **Xong 2026-08-30**

**Goal:**
`master_plan/prompt-fullstack.md` tự đặt luật ở §3.1 — *"Không có con số nào ở đây"* — nhưng vẫn
còn bốn dòng mang số tiền. T-013 chỉ rà **kênh và luồng** nên không đụng tới chúng; chúng có từ
trước, không phải do T-013 thêm vào.

| Dòng | Đang viết | Nhà thật của con số |
|---|---|---|
| §4 (FE, giao diện khách) | `Thêm vào giỏ · 5.000đ` · `→ 34.000đ` | bánh cuốn nhân Nhiều = 5.000 (`shop-facts.md` §4.2) · combo Đầy đủ nhiều nhân = 34.000 (§4.3) |
| §9.1 (ví dụ dòng master task ĐÚNG) | "Sai **1.000đ** mỗi suất" | phụ thu mỗi phần nhận nhân (§4.4) |
| §9.4 (ví dụ nổ thành phần) | `34.000 × 2 = 68.000` | **chép nguyên văn** `shop-facts.md` §5.3 |

Nặng nhất là hai dòng ở §9: §9 tự giới thiệu là *"Ví dụ chuẩn — bám đúng, đừng sáng tạo"*, nên agent
ngoài repo được bảo chép y nguyên. Chủ quán đổi giá thì bản xuất khẩu vẫn dạy giá cũ, và người đọc
nó không có repo để đối chiếu.

**Vì sao là task chứ không phải finding:** bài học đã có nhà — `work/findings.md` **F-001**
(*"một bản chép có kèm cảnh báo vẫn là một bản chép"*) và chính luật §3.1 của file. Ở đây chỉ thiếu
**việc**, và việc thì không chờ ai trả lời. Cũng vì thế **không gộp vào T-019**: T-019 đứng chờ một
câu hỏi cho người, việc này làm được ngay.

**Scope:** `master_plan/prompt-fullstack.md` · `work/backlog.md` · `work/scope.txt`.

**Out of scope:** `master_plan/shop-facts.md` (nhà thật, đang đúng) · `docs/**` · `prompt/**` ·
`quality/**` · `scripts/**` · mọi file T-020 vừa sửa.

**Acceptance:**
1. `grep -nE '[0-9]{1,3}\.000' master_plan/prompt-fullstack.md` **rỗng**.
2. §4 vẫn chốt được hai luật giao diện cũ (giá hiện ngay trên nút thêm vào giỏ · tiền định dạng
   `vi-VN`) mà không nêu con số nào, và nói thêm **giá lấy từ API**, khớp §6.9 (*BE luôn tính lại
   giá từ DB*).
3. §9.1 ô *Hỏng thì mất gì* vẫn **cụ thể** — nói đúng khoản tiền nào sai, không nói chung chung
   kiểu "lỗi đơn" — nhưng không còn con số. Đây là ví dụ dạy cách viết cột đó, hỏng tính cụ thể
   là hỏng cả bài học.
4. §9.4 **giữ nguyên** phần nổ thành phần và mọi số **thành phần** (combo = 3 bánh + 1 trứng +
   1 giò, 2 combo ⇒ 6 bánh). Chúng được phép ở lại vì ví dụ dạy đúng chúng, đã trỏ
   `shop-facts.md` §4.5, có ngày chốt và có sẵn luật bảo trì *"thành phần đổi thì sửa ví dụ này
   trước"*. Chỉ **dòng tiền** bị bỏ số và trỏ §4.3.
5. Khối ⚠️ ở §3.1 ghi thêm lần này, kèm ngày — vẫn đúng **một** khối.
6. Không đổi cấu trúc §1 → §10, không đổi stack/cổng/sơ đồ 16 bảng, không đụng bảng sáu pha §7.
7. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/prompt-fullstack.md   # rỗng
grep -n 'Thêm vào giỏ\|Intl.NumberFormat' master_plan/prompt-fullstack.md
grep -n 'Hỏng thì mất gì\|không ai phát hiện' master_plan/prompt-fullstack.md
sed -n '/9.4 Việc xuống bếp/,/§10/p' master_plan/prompt-fullstack.md      # ×6 còn nguyên
grep -c '⚠️' master_plan/prompt-fullstack.md
git status --porcelain
```

**Đã sửa ba dòng, giữ lại một:**

| Chỗ | Sau khi sửa |
|---|---|
| §4 giao diện khách | bỏ cả hai số; thêm luật **giá lấy từ API, không hard-code** (trỏ §6.9) và tả định dạng `vi-VN` bằng lời (dấu chấm ngăn nghìn, hậu tố `đ`) |
| §9.1 ô *Hỏng thì mất gì* | "Thu sai **phụ thu ở mọi suất có nhân**, không ai phát hiện tới cuối tháng" — vẫn nói đúng khoản tiền nào sai, không còn con số |
| §9.4 dòng tiền | `[… — Thịt+mộc nhĩ, Nhiều nhân]   ← đơn giá: shop-facts §4.3` |
| §9.4 số **thành phần** | **giữ nguyên** (`×6`, `×2`, combo = 3 bánh + 1 trứng + 1 giò) — xem Acceptance 4 |
| §3.1 khối ⚠️ | vẫn **một** khối, ghi thêm lần này |

**Một chỗ suýt hỏng, đáng nhớ:** bản nháp đầu của khối ⚠️ **trích cả ba con số** để kể lại lỗi —
và thế là Acceptance 1 vẫn đỏ, file vẫn đủ ba con số tiền, chỉ là chúng chuyển từ chỗ này sang chỗ
kia. Luật đã ghi thẳng vào khối đó: *cảnh báo nêu chỗ sai và loại sai, không chép lại giá trị sai.*
Cùng họ với F-001 — bản chép nào cũng là bản chép, kể cả bản chép nằm trong lời cảnh báo về việc
chép.

**Phát hiện kèm theo, không sửa:** §9.3 còn một link `../finding.md#f-31` — cùng loại với F-007,
và cho thấy F-007 đếm thiếu (nó chỉ kể `#f-67`). Vào **T-019** khi task đó chạy.

### T-020 — §6.3 còn viết "không bao giờ thu trước", trong khi đơn mang đi đã được trả trước

**Prompt:** `prompt/maintenance/10-prepay-takeaway-L2.md` (L2) · **chặn** BA-04, BA-06

**Goal:**
`master_plan/shop-facts.md` nói đúng thứ chủ quán chốt: đơn mang đi **mặc định** thu lúc trao
hàng, nhưng khách **được chọn** trả trước; đơn đã trả trước mà huỷ thì hoàn theo §6.4. Không còn
chỗ nào trong repo nói "không bao giờ thu trước", và không còn chỗ nào suy ra "huỷ đơn không bao
giờ sinh việc hoàn tiền".

**Nói một câu, việc phải làm là gì:**
Sửa **luật** ở nhà thật rồi đuổi theo mọi chỗ trỏ về nó. Việc **không** phải làm: biến trả trước
thành mặc định — nó là tuỳ chọn; và không đụng luồng ăn tại bàn, vẫn thu ở quầy lúc đóng phiên.

**Vì sao có task này:**
Chủ quán chốt **2026-08-30**: *"đơn mang đi có thể thanh toán trước"*, kèm ba vế trả lời trong
cùng ngày — trả trước là **tuỳ chọn** · áp cho **cả ba** kênh mang đi · huỷ đơn đã trả trước thì
hoàn **theo §6.4** (quầy quyết từng ca, phải ghi vết). Câu này **lật một luật đã chốt cùng ngày**:
§6.3 quy tắc 3 đang viết *"không bao giờ thu trước"*, và §7.1 có dòng nhật ký ghi đúng câu đó.
Chỗ lệch lộ ra khi T-012 đọc mục *Unknowns* của `prompt/BA/03-slice-ship-pickup-L2.md` — câu hỏi
"đơn mang đi có được thanh toán trước không" nằm đó, và §6.3 đã trả lời "không". T-012 cố ý không
sửa (ngoài scope), báo cáo lại, và chủ quán trả lời ngược với §6.3.

**Không làm thì mất gì — ba chỗ, xếp theo mức nặng:**
- **BA-06** viết `docs/product.md` §4 — quy tắc giá và thanh toán. Nó đọc §6.3. Chạy BA-06 trước
  T-020 là **chép nguyên một luật đã chết vào tài liệu sản phẩm**, rồi mọi thứ hạ nguồn tính tiền
  theo nó. Đây là chỗ nặng nhất.
- **BA-04** viết §3.2 — chính lát cắt mang đi, nơi nhánh trả trước sống. Prompt của nó còn giữ câu
  hỏi đã có lời giải, nên nó sẽ hỏi lại một thứ đã chốt (CLAUDE.md §3.5 cấm biến luật đã chốt
  thành giả định).
- **Luật đổ theo:** `shop-facts.md` §2 và `docs/product.md` §2.4 đều suy ra *"tiền chưa bao giờ
  thu trước ⇒ huỷ đơn đặt trước **không sinh việc hoàn tiền**"*. Từ hôm nay câu đó chỉ đúng cho
  đơn chưa trả tiền — để nguyên là để một quán thật tin rằng huỷ đơn thì không phải trả lại tiền.

**Thứ tự đọc trước khi sửa file đầu tiên:**
1. `master_plan/shop-facts.md` §6.3 (luật đang sai) → §6.4 (hoàn tiền, nơi ca huỷ đơn đã trả rơi
   vào) → §5 và §5.2 (hai bản nhắc lại) → §2 đoạn huỷ đơn hotline → §7.1 nhật ký chốt.
2. `prompt/maintenance/10-prepay-takeaway-L2.md` — bảng *Context* liệt kê **tám** chỗ phải sửa,
   mục *Constraints* có sáu cái bẫy, *Acceptance* có **mười một** dòng.

**Ba cái bẫy hay sửa nhầm nhất** (danh sách đủ ở *Constraints* của prompt):
- **Trả trước là tuỳ chọn, không phải mặc định.** Viết thành "đơn mang đi thu tiền trước" là sai
  lời chốt.
- **Không xoá dòng nhật ký §7.1 cũ.** Hai lần chốt cùng một ngày là chuyện thật; nhật ký phải kể
  được cả hai mà không tự mâu thuẫn.
- **Không tự quyết ai bấm xác nhận "đã nhận tiền" cho đơn trả trước.** VietQR là tĩnh và không có
  ai đứng đối diện khách lúc trả ⇒ ghi **U-005**, đừng suy ra.

**Cách hoàn thành — đủ mười bước, 1 tới 10.** Luật chung ở
[Vòng chạy một task L1](#vong-chay); dưới đây là việc cụ thể của T-020 ở đúng bước đó.

1. **Đọc.** Entry này rồi cả file prompt — nhất là bảng *Context* và sáu dòng *Constraints*.
2. **Khai scope.** Bảy dòng ở mục *Scope* của prompt, nối vào cuối `work/scope.txt`.
3. **Mở task.** Cắt dòng `- [ ] T-020 …` khỏi [Ready](#ready) xuống [In Progress](#in-progress).
4. **Sửa, từ nhà thật ra ngoài.** `shop-facts.md` §6.3 → §5 → §5.2 điểm 6 → §2 → §7.1, rồi mới
   tới `docs/product.md`, rồi `prompt/BA/03`. Sửa nhà thật sau cùng là tự chép luật cũ đi tiếp.
5. **Một câu hỏi phải ghi, không được trả lời:** U-005 (ai xác nhận tiền của đơn trả trước).
6. **Verify.** Bảy lệnh ở mục *Verify* của prompt. Lệnh dễ trượt nhất là lệnh `grep` toàn repo tìm
   "không bao giờ thu trước" — phải **rỗng**, kể cả trong `master_plan/**` và `docs/**`.
7. **Gate 2 — mười một dòng Acceptance, mười một bằng chứng**, mỗi dòng trỏ tới một `file:dòng`.
8. **Findings.** Chỗ lệch số điện thoại ở `docs/product.md` → *Unknowns* nối vào **F-006**, không
   mở finding mới: đúng con bug T-012 đã sửa ở `prompt/BA/01`, lần này ở tài liệu tra cứu.
9. **Đóng task.** Tick ở [Done](#done) kèm ngày · chuyển khối này sang
   [Chi tiết — việc đã xong](#chi-tiet-da-xong) · xoá bảy pattern khỏi `work/scope.txt` · sửa hai
   dòng ở [Ready](#ready) đang trỏ tới T-020 (câu "Sáu việc bảo trì", bullet "T-020 chặn BA-04 và
   BA-06") và ghi `(T-020 xong)` vào dòng BA-04, BA-06.
10. **Khối commit.** Một khối, liệt kê từng file, subject `T-020: …`, không có `work/scope.txt`.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).

**Đã xong 2026-08-30.** Tám chỗ trong bảng *Context* đã sửa; nhà thật `shop-facts.md` §6.3 nay
nói đủ ba vế của lời chốt và §6 vẫn đúng 13 quy tắc. Hai chỗ **ngoài** bảng đó cũng phải sửa vì
trỏ vào dữ kiện vừa dịch chuyển: dòng lệch số điện thoại ở `docs/product.md` → *Unknowns* (nối
vào **F-006**, lần rà thứ tư — lần đầu chỗ lệch nằm ở **tài liệu tra cứu**), và ghi chú đóng
T-012 trong chính backlog này, chỗ còn khẳng định *"§6.3 đã trả lời: không"*.
**Một dòng Acceptance đã bị sửa sau khi bắt đầu:** dòng 10 đòi grep toàn repo phải rỗng, nhưng
hồ sơ của chính task (entry này + file prompt) **phải** trích lại câu cũ mới kể được nó sửa gì.
Dòng 10 nay loại trừ đúng hai file đó và vẫn đòi rỗng ở `master_plan/**`, `docs/**`,
`prompt/BA/**`.
**Còn mở:** **U-005** — đơn trả trước thì trả bằng gì, ai bấm xác nhận đã nhận tiền, lúc nào.
Chặn BA-06 và một phần BA-07; chỉ chủ quán trả lời được.

### T-013 — Bản xuất khẩu còn nói "4 kênh" và gọi luồng mang đi bằng hai kênh

**Prompt:** `prompt/maintenance/06-fullstack-export-three-channels-L1.md` (L1) · **Xong 2026-08-30**

**Goal:**
`master_plan/prompt-fullstack.md` — bản xuất khẩu cho agent **ngoài** repo — không còn chỗ nào nói
quán bán bốn kênh, và mọi chỗ mô tả luồng mang đi đều gọi tên luồng thay vì kể thiếu thành viên.

**Đã sửa năm chỗ** (chỉ trong `master_plan/prompt-fullstack.md`):

| Mục | Trước | Sau |
|---|---|---|
| §7 hàng `0 · BA` | "4 kênh bán · 2 sơ đồ luồng (tại bàn, ship)" | "**năm** kênh bán, đủ cả năm (trỏ `shop-facts.md` §2) · 2 sơ đồ luồng (tại bàn, **mang đi**)" |
| §2 bảng ba mặt | POS chỉ có "đặt món hộ khách"; không có đường điện thoại | quầy "đặt hộ tại bàn **và nhập hộ đơn khách gọi qua điện thoại**", kèm câu "ba mặt **không** phải ba kênh" + trỏ `shop-facts.md` §2 |
| §3.3 | "Luồng ship/pickup khác **3 điểm**: cần SĐT, không phiên bàn, có đóng gói" | gọi tên **luồng mang đi**, nêu khác biệt cốt lõi (mỗi đơn là một đơn vị thanh toán, không phiên bàn), **bỏ con số**, trỏ `shop-facts.md` §5.2 |
| §5 lát cắt B | "**B. Một đơn ship** — khách web đặt → Telegram → quầy duyệt" | "**B. Một đơn mang đi**" — thêm nhánh đơn gọi điện thoại do nhân viên nhập hộ, **không** qua bước quầy duyệt |
| §3.1 khối ⚠️ | kể hai kiểu chép sai cũ | vẫn **một** khối, nay kể ba kiểu + lần gặp 2026-08-30 và tìm thấy ở đâu |

**Ba điều task này chứng minh, ngoài việc sửa chữ:**

1. **Cảnh báo cùng file không cứu được bản chép (F-001).** Dòng "4 kênh bán" sống sót **ngay dưới**
   khối ⚠️ nói "thấy 'bốn kênh bán' quay lại là bug", trong ô định nghĩa đầu ra bắt buộc của cả
   pha BA. Một agent ngoài repo giao đúng bốn kênh rồi coi pha BA là xong.
2. **Bỏ con số, đừng thay số (F-003).** "Khác 3 điểm" **không** được sửa thành "khác 7 điểm": đếm
   là tóm tắt của người viết thì không được viết như khẳng định đã đủ, và một bản xuất khẩu càng
   không nên giữ con số sẽ trôi. Chỗ cần danh sách thì **trỏ** nhà thật.
3. **Loại file thứ tư của F-005 nay đã rà xong.** Tra cứu → khung (T-007, T-011) → prompt (T-012)
   → bản xuất khẩu (T-013), cùng một kênh `phone_preorder`.

**Phát hiện kèm theo, KHÔNG sửa trong task này:** file trỏ tới bảy đường không tồn tại →
`work/findings.md` **F-007** (Open) + **T-019** ở [Ready](#ready). Sửa từng link là đoán hộ người
quyết định `prompt-fullstack.md` còn thuộc dự án nào.

**Lệch nhỏ so với Acceptance của prompt:** dòng `grep -c '⚠️'` trong prompt kỳ vọng **1**, thực tế
ra **2** — cả trước lẫn sau khi sửa. Kết quả thứ hai là §6.2 (*"bất biến nào chưa có cơ chế bảo vệ
thì đánh dấu ⚠️ ngay trong bảng"*), một câu hướng dẫn chứ không phải khối cảnh báo. Điều kiện thật
— **một** khối cảnh báo ở §3.1 — vẫn đúng.

### T-012 — Bộ prompt BA còn mô tả luồng mang đi bằng hai kênh

**Prompt:** `prompt/maintenance/05-ba-prompts-three-channels-L1.md` (L1) · **chặn** BA-04, BA-06, BA-11

**Goal:**
Không còn prompt nào trong `prompt/BA/` mô tả luồng mang đi bằng cách kể hai kênh. T-011 đã sửa
tài liệu **khung**; đây là loại file thứ ba của `work/findings.md` F-005 — `prompt/**`, thứ phiên
sau đọc rồi làm theo. Nặng nhất là `10-acceptance-scenarios-L2.md` dòng 45: BA-11 tick theo nó.

**Nói một câu, việc phải làm là gì:**
Sửa **chữ** trong `prompt/BA/**` để mọi prompt gọi luồng mang đi là **một luồng ba kênh**
(`delivery` · `pickup` · `phone_preorder`) thay vì kể tên hai kênh ("ship/pickup"). Đây là việc
sửa phạm vi cho đúng, **không** phải viết lại prompt: không đổi tên file, không đổi ID `BA-01`–
`BA-11`, không đổi level, không thêm/bớt bước hay scenario.

**Vì sao có task này:**
Chủ quán chốt kênh bán thứ năm `phone_preorder` (2026-08-24, sửa tên 2026-08-29, chốt luồng
2026-08-30). Nhà thật `master_plan/shop-facts.md` §5.2 xếp nó **chung một luồng** với `delivery`
và `pickup` — ba kênh không gắn bàn, mỗi đơn là một đơn vị thanh toán riêng. Theo F-005, một dữ
kiện đổi thì phải rà đủ **ba loại file**: tài liệu tra cứu (`docs/product.md` — đã xong từ BA-02),
tài liệu khung (kế hoạch gốc — T-011 xong 2026-08-30), và **prompt** — loại thứ ba, chưa ai rà.
T-012 chính là loại thứ ba đó. T-013 là phần còn lại: bản xuất khẩu.

**Không làm thì mất gì — ba chỗ, xếp theo mức nặng:**
- **BA-11** tick nghiệm thu theo `prompt/BA/10-acceptance-scenarios-L2.md`. Scenario 2 đang viết là
  "khách đặt ship/pickup". Diễn lại được scenario đó rồi tick nghĩa là **đóng cả giai đoạn BA
  trong lúc một trong ba kênh chưa ai nghiệm thu**, rồi bước sang System Design với mô hình bán
  hàng thiếu một kênh. Đây là chỗ nặng nhất, và là lý do T-012 phải chạy trước.
- **BA-06** chốt quy tắc giá và thanh toán. `05-pricing-payment-L2.md` đang mô tả đơn vị thanh
  toán của đơn không gắn bàn bằng hai kênh ⇒ `phone_preorder` bước vào giai đoạn sau mà **không có
  luật tính tiền**.
- **BA-04** viết `docs/product.md` §3.2 — chính lát cắt mang đi. Prompt của nó
  (`03-slice-ship-pickup-L2.md`) hiện **tự mâu thuẫn**: một dòng đã nói đủ ba kênh, tiêu đề và
  nhiều dòng khác vẫn nói hai.

**Đây là con bug F-006, không phải bug mới.**
Chỗ lệch **không chứa con số nào** — nó viết "ship/pickup", "Ship / Pickup" — nên luật grep theo
con số của F-005 (`bốn`/`4`, `năm`/`5`) chạy đúng vẫn ra rỗng. Rà bằng **định danh** kênh
(`phone_preorder`), và mỗi chỗ liệt kê thành viên thay vì gọi tên luồng là một chỗ phải sửa.

**Thứ tự đọc trước khi sửa file đầu tiên:**
1. `master_plan/shop-facts.md` §5.2 — luồng thật. Chú ý điểm dễ bỏ sót: `phone_preorder` do nhân
   viên nhập hộ nên **không qua bước quầy duyệt**, khác `delivery` và `pickup`.
2. `work/findings.md` F-005 và F-006 — vì sao rà theo định danh, và ba loại file phải rà.
3. `prompt/maintenance/05-ba-prompts-three-channels-L1.md` — mục *Context* có **bảng liệt kê đúng
   từng file, từng dòng** đang sai và sai kiểu gì. Chép bốn dòng ở mục *Scope* vào `work/scope.txt`
   trước khi sửa. Đọc hết *Constraints*: có mấy cái bẫy sửa nhầm là hỏng.
4. `prompt/BA/03-slice-ship-pickup-L2.md` dòng 51 — câu đã viết đúng, dùng làm mẫu giọng văn cho
   các chỗ còn lại.

**Ba cái bẫy hay sửa nhầm nhất** (danh sách đủ ở mục *Constraints* của prompt):
- **Không đổi tên file.** `03-slice-ship-pickup-L2.md` giữ nguyên tên dù nội dung nói ba kênh —
  `prompt/BA/README.md`, `work/backlog.md` và §11 kế hoạch gốc trỏ tới nó theo tên. Sửa tiêu đề
  bên trong thì được.
- **Doanh thu vẫn cộng từ HAI nguồn, không phải ba.** Con số hai chia theo **đơn vị thanh toán**
  (phiên bàn ↔ đơn lẻ), không chia theo kênh. Thấy "hai" mà sửa thành "ba" là sai.
- **Không chép sơ đồ, số hotline hay giá** từ `shop-facts.md` vào prompt — chỗ cần chi tiết thì
  **trỏ** (ADR-001, F-001).

**Cách hoàn thành — đủ mười bước, 1 tới 10.** Luật chung của từng bước ở
[Vòng chạy một task L1](#vong-chay); dưới đây là **việc cụ thể của T-012** đứng ở đúng bước đó.

1. **Đọc.** Entry này, rồi đọc hết `prompt/maintenance/05-ba-prompts-three-channels-L1.md` — nhất
   là bảng ở mục *Context* (liệt kê từng file, từng dòng đang sai) và mục *Constraints*. Nền tảng
   thì theo "Thứ tự đọc trước khi sửa" ở trên: `shop-facts.md` §5.2 rồi F-005 · F-006.
2. **Khai scope.** Nối bốn dòng ở mục *Scope* của prompt vào **cuối** `work/scope.txt` — nối thêm,
   đừng ghi đè phần chú thích có sẵn:
   ```bash
   cat >> work/scope.txt <<'EOF'
   prompt/BA/
   work/backlog.md
   work/findings.md
   work/scope.txt
   EOF
   ```
   Ngoài bốn dòng đó là ngoài scope: `master_plan/**`, `docs/**`, `quality/**`, `scripts/**`,
   `prompt/maintenance/**` — chạm vào là Gate 3 đỏ, đúng như thiết kế.
3. **Mở task.** Cắt dòng `- [ ] T-012 …` khỏi [Ready](#ready), dán xuống
   [In Progress](#in-progress). Chưa tick, chưa đụng [Done](#done).
4. **Sửa, từ chỗ nặng xuống nhẹ.** `10-acceptance-scenarios-L2.md` (chặn BA-11) →
   `05-pricing-payment-L2.md` (chặn BA-06) → `03-slice-ship-pickup-L2.md` (chặn BA-04) →
   `prompt/BA/README.md`. Dòng 51 của file thứ ba là câu đã viết đúng — dùng làm mẫu giọng văn cho
   các chỗ còn lại. Ba cái bẫy ở mục ngay trên: không đổi tên file · doanh thu vẫn **hai** nguồn ·
   không chép sơ đồ, hotline hay giá vào prompt.
5. **Không có câu hỏi nghiệp vụ nào phải hỏi.** Luồng ba kênh đã chốt ở `shop-facts.md` §5.2 (chủ
   quán chốt 2026-08-30) và tài liệu khung đã khớp từ T-011. Task này chỉ sửa chữ cho khớp thứ đã
   chốt — dừng lại hỏi ở đây là hiểu sai việc.
6. **Verify.** Chạy nguyên khối lệnh ở mục *Verify* của prompt (tám lệnh: `gate.sh`, bốn lệnh
   `grep`, `git status --porcelain`, `git diff --stat`), rồi đọc kỹ hai lệnh dễ trượt nhất:
   `git status` **không được có file nào bị rename**, và `grep` hotline/giá phải **rỗng**.
7. **Gate 2 — chín dòng Acceptance, chín bằng chứng.** Mục *Acceptance* của prompt có đúng **chín**
   dòng. Mỗi dòng phải trỏ được tới một `file:dòng` cụ thể sau khi sửa, hoặc tới output thật của
   lệnh `grep` tương ứng. Dòng nào không trỏ được là chưa xong — không tick.
8. **Findings — chỉ ghi khi có.** Tìm thấy chỗ lệch **ngoài** bảng *Context* thì sửa luôn trong
   cùng lần và **nối vào `work/findings.md` F-006**, đừng mở F-007: cùng một con bug, cùng một
   luật. Không tìm thấy gì thêm thì không đụng file này, và bỏ nó khỏi khối commit ở bước 10.
9. **Đóng task — bốn việc, làm cùng lúc.** (a) Tick `- [x] T-012 … (YYYY-MM-DD)` ở [Done](#done);
   (b) chuyển khối chi tiết này sang [Chi tiết — việc đã xong](#chi-tiet-da-xong); (c) **xoá bốn
   pattern vừa thêm ở bước 2** khỏi `work/scope.txt`; (d) sửa **bốn dòng ở [Ready](#ready) đang
   trỏ tới T-012**: câu "Sáu việc bảo trì" → năm · câu "Hai việc chặn chuỗi BA, làm trước:
   T-012 → T-015" → chỉ còn T-015 · bullet "T-012 và T-013 là phần còn lại của cùng con bug T-011
   sửa" · bullet "T-012 chặn BA-04, BA-06, BA-11". Dòng BA-04 ghi thêm `(T-012 xong)` theo đúng
   cách nó đang ghi `(T-011 xong)`.
10. **Khối commit.** Một khối, liệt kê từng file, subject `T-012: …`, **không** có
    `work/scope.txt` (§6):
    ```bash
    git add prompt/BA/10-acceptance-scenarios-L2.md prompt/BA/05-pricing-payment-L2.md \
            prompt/BA/03-slice-ship-pickup-L2.md prompt/BA/README.md work/backlog.md
    git commit -m "T-012: bộ prompt BA gọi luồng mang đi bằng ba kênh" -m "..."
    ```
    Thêm `work/findings.md` vào `git add` **chỉ khi** bước 8 thực sự có ghi.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).

**Đã xong 2026-08-30.** Bốn chỗ trong bảng *Context* của prompt đã sửa, cộng một chỗ thứ năm
bảng đó không kể — `prompt/BA/01-actors-channels-L1.md` viết *"chỉ delivery và pickup mới bắt
buộc số điện thoại"*, sai với `shop-facts.md` §6.5 (bắt buộc cho cả ba kênh). Chỗ thứ năm này
được nối vào `work/findings.md` **F-006** đúng theo bước 8, không mở F-007. `grep -rn
'ship/pickup\|Ship / Pickup' prompt/BA/` nay rỗng; `phone_preorder` có mặt ở sáu file
(`01`, `03`, `05`, `08`, `09`, `10`); không file nào bị đổi tên; câu doanh thu vẫn **hai** nguồn.
**Đã chuyển tiếp, không thuộc T-012:** `03-slice-ship-pickup-L2.md` còn một Unknown *"đơn mang
đi có được thanh toán trước không"*. T-012 báo cáo lại thay vì tự sửa, và **chủ quán trả lời
ngược với §6.3 đang viết lúc đó**: đơn mang đi **được** trả trước. Việc ghi lời chốt đó thành
**T-020**, đóng 2026-08-30 — nên câu Unknown này nay đã có lời giải trong chính file 03.*

*Mục này được viết dài thêm 2026-08-30 theo yêu cầu của owner ("không hiểu task này để làm gì").
Phạm vi công việc không đổi — chỉ thêm phần vì sao, hậu quả, thứ tự đọc và cách hoàn thành. Bảng
chỗ phải sửa, Acceptance và Verify vẫn chỉ sống ở file prompt; mười bước thủ tục sống một chỗ ở
[Vòng chạy một task L1](#vong-chay), không chép vào từng task.*

### T-018 — §6.1 là kỷ luật, chưa có cơ chế nào chặn việc quên

**Prompt:** yêu cầu miệng của chủ repo, 2026-08-30 — *"thêm hook để đảm bảo không quên"* (L2)

**Goal:**
T-017 viết luật §6.1 nhưng không có gì thi hành nó: một phiên quên giao khối commit thì không ai
biết, đúng loại hỏng `work/findings.md` F-001 nói tới — luật dựa vào trí nhớ. Cuối mỗi turn, nếu
cây làm việc còn thay đổi **git đang theo dõi** mà báo cáo của turn đó không kèm khối
`git commit -m`, Stop hook phải chặn và trả lời về cho phiên.

**Scope:**
`scripts/check-commit-block.sh` (mới) · `scripts/check-commit-block.test.sh` (mới) ·
`scripts/gate.sh` · `scripts/verify.sh` · `CLAUDE.md` · `README.md` · `docs/decisions.md` ·
`work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Không tự chạy `git add`/`git commit` — quyền commit vẫn của người dùng (CLAUDE.md §6). Không đổi
`check-scope.sh`. Không thêm hook thứ hai vào `.claude/settings.json`. Không dữ kiện nghiệp vụ.

**Acceptance:**
1. `scripts/check-commit-block.sh` đọc JSON hook trên stdin, exit 2 khi có thay đổi tracked chưa
   commit mà turn hiện tại không có `git commit -m`; exit 0 khi có khối, hoặc khi cây sạch.
2. `work/scope.txt` **không** tính là thay đổi cần commit (§6.1: nó không bao giờ nằm trong khối).
3. Chỉ file **tracked** kích hoạt hook — file chưa track không, đúng luật ADR-003.
4. Nhắc **một lần cho mỗi trạng thái cây**: đã giao khối rồi thì turn sau không bị nhắc lại nếu
   cây không đổi. Dấu vết nằm trong `.git/`, không phải file trong repo.
5. Mọi đường lỗi (không phải git repo, thiếu python3, không đọc được transcript, không phải hook
   mode) đều exit 0 — không bao giờ chặn nhầm.
6. `gate.sh --hook` gọi nó **sau** khi gate xanh; `gate.sh` chạy tay không gọi (không có transcript).
7. `scripts/check-commit-block.test.sh` chạy được độc lập, phủ 1–5, và `verify.sh` tự chạy mọi
   `scripts/*.test.sh`.
8. ADR-004 ghi lại ba lựa chọn: nhắc-không-tự-commit · chỉ file tracked · gắn vào `gate.sh` thay vì
   hook Stop thứ hai.
9. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/check-commit-block.test.sh
./scripts/gate.sh
```

### T-017 — Kết thúc task/phiên chưa giao nội dung commit

**Prompt:** yêu cầu miệng của chủ repo, 2026-08-30 (L1)

**Goal:**
Chủ repo là người bấm commit, nhưng người viết commit phải là phiên làm việc — phiên là chỗ duy
nhất còn biết task nào, file nào, bằng chứng nào. Hiện §6 chỉ quy định *dạng* subject và cấm tự
commit; không có dòng nào bắt phiên **giao** nội dung commit. Kết quả nằm ngay trong git log:
`202e8c4 ádg`, `2692178 sdgf`, `25f0f88 sdfg` — ba commit gần nhất không có nội dung, vì việc soạn
nội dung rơi vào lúc phiên đã kết thúc.

**Scope:**
`CLAUDE.md` · `work/backlog.md` · `work/scope.txt`.

**Out of scope:**
Không dữ kiện nghiệp vụ. Không tự chạy `git commit`/`git add`. Không thêm hook, không thêm script,
không tạo file `.md` mới (CLAUDE.md §3.8).

**Acceptance:**
1. `CLAUDE.md` §6 có tiểu mục §6.1 quy định: cuối **mỗi task** và cuối **mỗi phiên** cho phần chưa
   commit, báo cáo kết thúc bằng một khối `git add` + `git commit` dán chạy được ngay.
2. §6.1 nói rõ khối đó **liệt kê từng file**, không `git add -A`, và không bao giờ chứa
   `work/scope.txt` (nối lại luật §6 gạch đầu dòng 4 và T-016).
3. §7.3 (bàn giao cuối phiên) có một gạch đầu dòng trỏ tới §6.1.
4. §8 *Every level* có một dòng checklist về nội dung commit.
5. Chính task này giao commit theo đúng §6.1 — bằng chứng là khối commit ở cuối báo cáo.
6. `./scripts/gate.sh` xanh.

**Verify:**
```bash
grep -n "6.1" CLAUDE.md
./scripts/gate.sh
```

### T-011 — Kênh `phone_preorder` không thuộc lát cắt BA nào

**Prompt:** `prompt/maintenance/04-phone-preorder-slice-L1.md` (L1)

**Goal:**
Mỗi kênh ở `master_plan/shop-facts.md` §2 có **đúng một** lát cắt BA nhận trách nhiệm mô tả luồng.
`phone_preorder` chưa có trong **tài liệu khung**: kế hoạch gốc §3 chỉ có Epic A (tại bàn) và Epic B
(ship/pickup), §4.2 cũng vậy, §11 giao BA-04 đúng hai kênh, §12 nghiệm thu đúng hai kênh.

Chỗ lệch là **chỉ ở khung**: `shop-facts.md` §5.2 đã gộp ba kênh không gắn bàn thành một luồng
("Luồng mang đi — `delivery`, `pickup`, `phone_preorder`"), và `prompt/BA/03-slice-ship-pickup-L2.md`
— prompt thật sự chạy BA-04 — **đã phủ đủ ba kênh** (*"Bỏ `phone_preorder` là bỏ một phần ba lát
cắt"*). Nên đây là việc đồng bộ khung theo nhà thật, không phải chốt luật mới; giữ nguyên **ba** lát
cắt, mở rộng Epic B, không thêm Epic D.

Đúng con bug mà `work/findings.md` F-003 đã đặt tên: *"Kênh chỉ có trong bảng §2 mà không có trong
luồng nào là bug."* T-007 sửa **con số** kênh, không sửa chỗ thiếu **luồng** này.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).

**Đã làm 2026-08-30:** **sáu** chỗ (không phải bốn) đã chuyển từ "ship/pickup" sang luồng **mang
đi** gồm cả ba kênh không gắn bàn, trong `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`:
§3 Epic B (đổi tên, nêu đích danh `phone_preorder`, **Mục tiêu BA** giữ nguyên), §4.2 (đổi tiêu đề,
thêm bước nhân viên hỏi giao-hay-lấy lúc nhận máy, bước cuối kết thúc **cả hai** nhánh, kèm một
dòng trỏ `shop-facts.md` §5.2), §11 dòng BA-04 (chỉ ô "Việc"), §12 scenario nghiệm thu thứ hai.
Hai chỗ kia là **chỗ lệch thứ năm và thứ sáu**, chỉ lộ ra khi grep theo tên kênh: §5 quy tắc 8
("Đơn ship/pickup không sử dụng phiên bàn") và §6 mục Thanh toán ("Đối với ship/pickup") — cả hai
mô tả luồng bằng cách liệt kê hai trong ba thành viên. Vẫn **ba** lát cắt, không có Epic D; khối
ghi chú ở cuối §12 được nối thêm chứ không tách khối thứ hai.

Vì sao hai lần rà trước (F-003, F-005) không chặn được lần này — grep theo **con số** không tìm
được chỗ lệch không chứa con số nào — ghi ở `work/findings.md` **F-006**.

### T-008 — Chạy BA-00 sau khi BA-01/BA-02 đã xong

**Prompt:** `prompt/maintenance/02-run-ba00-backlog-L3.md` (L3, bọc `prompt/BA/00-master-L3.md`)

**Goal:**
Backlog có 11 task BA-01–BA-11 với thứ tự phụ thuộc và acceptance kiểm được. BA-00 chưa từng chạy,
nhưng prompt 01 thì đã chạy — nên chạy BA-00 nguyên văn sẽ **ghi đè** `docs/product.md` §1/§2 bằng
chỗ giữ. Prompt bọc nêu ba điều chỉnh cần thiết.

**Acceptance · Verify:** trong file prompt.

**Đã làm 2026-08-30.** Ready nay có BA-03–BA-11 xếp theo cột "Cần xong trước" của §11 kế hoạch gốc;
BA-01/BA-02 giữ nguyên ở Done. Mười câu hỏi §10 được phân bổ trong bảng ở đầu mục Ready — bốn câu
đã có lời giải ghi kèm nguồn `shop-facts.md` §6.2 · §6.4 · §6.5 · §6.7 · §6.13 và **không** bị mở
lại thành câu hỏi.

Ba điều chỉnh của prompt bọc, đã áp dụng:

1. `docs/product.md` không bị sửa một ký tự. Việc duy nhất của file đó — đối chiếu tiêu đề §3–§8
   với bảng khung của BA-00 — đã chạy và **cả 8 tiêu đề đã khớp sẵn** từ lần chạy prompt 01
   (commit `e801668`), nên `git diff docs/product.md` rỗng.
2. BA-01/BA-02 giữ ở Done với entry cũ, không tạo bản thứ hai.
3. S-1–S-3 ghi là **đã chốt 2026-08-30**, không ghi dạng giả định.

Hai chỗ phải tự quyết, ghi lại để phiên sau không phải đoán:

- **BA-04 viết là ba kênh, không phải hai.** T-011 chưa chạy nên dòng BA-04 ở §11 kế hoạch gốc còn
  ghi "ship/pickup". Backlog **không** chép chỗ thiếu đó: entry BA-04 lấy định nghĩa lát cắt từ
  `shop-facts.md` §5.2 và `prompt/BA/03-slice-ship-pickup-L2.md`, hai chỗ đã phủ ba kênh. T-011
  vẫn phải xong trước khi ai mở BA-04 — đã ghi vào cả hai chỗ.
- **BA-10 không rỗng.** Lý do nằm trong entry BA-10: `docs/decisions.md` hiện chỉ có ADR-001–003,
  đều là quyết định về cách vận hành repo, chưa có ADR nghiệp vụ nào; sáu câu §10 vẫn đang mở; và
  S-1–S-3 phải được viết thành ADR đã chốt chứ không phải biến mất. Sáu câu đó là 2, 3, 4, 8, 9, 10;
  phần "sửa đơn" của câu 1 là chỗ mở thứ bảy.

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

**Đã làm 2026-08-30.** `scripts/check-scope.sh` tách hai loại: file đã track ngoài scope vẫn FAIL
exit 1; file chưa track ngoài scope in thành dòng `note:` và exit 0. Đầu script ghi luật mới kèm lý
do; `CLAUDE.md` §5 và `quality/review-gate.md` Gate 3 đã sửa theo; lựa chọn *ghi chú thay vì chặn*
và rủi ro đã chấp nhận nằm ở `docs/decisions.md` **ADR-003**.

Chạy thật, cả hai nhánh, trên cây làm việc có `prompt/maintenance/` chưa track:

```text
# nhánh FAIL — file ĐÃ track ngoài scope (plan.md, findings.md của T-007)
check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):
  ? prompt/maintenance/01-fix-plan-channel-count-L1.md
  ? prompt/maintenance/02-run-ba00-backlog-L3.md
  ? prompt/maintenance/03-retire-T-001-L0.md
check-scope: FAIL — files changed outside the scope declared in work/scope.txt:
  - master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
  - work/findings.md
exit=1

# nhánh OK — chỉ còn file chưa track nằm ngoài scope
check-scope: note — file chưa được git theo dõi, nằm ngoài scope (không chặn gate):
  ? prompt/maintenance/01-fix-plan-channel-count-L1.md ...
check-scope: OK — all tracked changes within declared scope.
exit=0
```

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

[↑ đầu file](#top)

<a id="vong-chay"></a>
## Vòng chạy một task L1 — mười bước

File prompt trong `prompt/**` giữ **nội dung** của task: sửa gì, ở đâu, xong là thế nào. Mười bước
dưới đây là **thủ tục** — thứ CLAUDE.md bắt mọi task L1+ phải làm và prompt không nhắc lại. Chạy
prompt mà bỏ thủ tục thì gate xanh nhưng không kiểm gì (bước 2), hoặc phiên sau nhận một backlog
nói sai sự thật (bước 9).

1. Đọc entry của task ở [Chi tiết — việc cần làm](#chi-tiet-can-lam), rồi đọc hết file prompt của
   nó — cả mục *Constraints* và *Unknowns*, không chỉ *Goal*.
2. **Khai `work/scope.txt`**: chép nguyên khối dòng ở mục *Scope* của prompt, **trước** lần sửa đầu
   tiên (CLAUDE.md §3.4). Bỏ bước này thì Gate 3 in `scope not declared, skipping` — gate xanh mà
   không kiểm gì.
3. Chuyển dòng task từ [Ready](#ready) xuống [In Progress](#in-progress) (§3.3).
4. Sửa file theo mục *Context* và *Constraints* của prompt, ở trong scope. Cần ra ngoài scope thì
   sửa `work/scope.txt` và **nói ra**, đừng sửa lén.
5. Gặp dữ kiện nghiệp vụ chưa rõ thì **dừng và hỏi** — không tự quyết. Luật này không có mức L0
   (§3.5); không hỏi được thì ghi thành U-XXX ở `docs/product.md` → *Unknowns*.
6. Chạy mục *Verify* của prompt, rồi `./scripts/gate.sh`. Dán **output thật** vào report — "tôi đã
   test" không phải bằng chứng (§5).
7. Gate 2: mỗi dòng *Acceptance* phải trỏ được tới **dòng cụ thể** trong file chứng minh nó
   (`quality/review-gate.md`). Dòng nào không trỏ được là chưa xong.
8. Dữ kiện mới ghi về đúng nhà của nó (§2, §4), kèm ngày và ai quyết (§7.2). Rồi `grep -rn` những
   chỗ **trỏ tới** thứ vừa đổi và sửa luôn trong cùng lần — pointer lệch là bug của lần này, không
   phải task sau.
9. Tick task ở [Done](#done) kèm ngày, chuyển khối chi tiết sang
   [Chi tiết — việc đã xong](#chi-tiet-da-xong), và **xoá sạch pattern trong `work/scope.txt`**
   (§7.3). Quên bước xoá đã hỏng hai lần — đó là lý do T-016 tồn tại.
10. Kết thúc bằng **khối `git commit` dán được** (§6.1): liệt kê từng file, không `git add -A`,
    không kèm `work/scope.txt`. Gate 7 chặn turn nếu thiếu khối này.

[↑ đầu file](#top)

<a id="template"></a>
## Task Detail Template

Khuôn dưới đây rút ra từ entry **T-012** — entry đầy đủ nhất hiện có. T-012 đã xong 2026-08-30
nên đọc nó ở [Chi tiết — việc đã xong](#chi-tiet-da-xong), mục đầu tiên, như một bản mẫu
**đã điền** — cả phần đóng task ở cuối, thứ chỉ viết được sau khi làm xong.

**Luật số một: entry TRỎ, prompt GIỮ.** Entry trả lời *vì sao có task này và mất gì nếu bỏ*.
File prompt trả lời *sửa dòng nào, xong là thế nào*. Năm thứ **không bao giờ** chép vào entry:
bảng file/dòng phải sửa · mục *Acceptance* · mục *Verify* · giá và số điện thoại · sơ đồ luồng.
Chép là tạo bản thứ hai, và bản thứ hai luôn trôi — `work/findings.md` F-001.

### Khuôn L1+ — bảy khối bắt buộc

```markdown
### T-XXX — <hiện trạng đang SAI, không phải việc phải làm>

**Prompt:** `prompt/.../xx-tên-Lx.md` (L?) · **chặn** <task khác, nếu có>

**Goal:**
Xong rồi thì thế giới khác đi thế nào. Một đoạn.

**Nói một câu, việc phải làm là gì:**
Một câu việc phải làm, kèm một câu việc **không** phải làm — chỗ người ta hay làm quá tay.

**Vì sao có task này:**
Gốc rễ, kèm ngày và ai quyết. Nói cả vì sao chỗ này không được sửa trong lần trước.

**Không làm thì mất gì:**
Hậu quả xếp theo mức nặng, mỗi cái gọi tên task hoặc dữ liệu lãnh đủ. Đây là khối
quyết định thứ tự ưu tiên — viết mơ hồ ở đây thì task nằm mãi trong Ready.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở [Vòng chạy một task L1](#vong-chay); ở đây viết **việc cụ thể của task
này** đứng ở đúng bước đó. Bước nào không có gì riêng vẫn phải có một dòng — bỏ trống
là người đọc tưởng mình đọc sót.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).
```

### Ba khối thêm — chỉ khi có thật

| Khối | Thêm khi |
|---|---|
| **Đây là con bug F-XXX** | task là lần lặp lại của một finding đã ghi — nói rõ vì sao vòng rà trước không bắt được |
| **Thứ tự đọc trước khi sửa file đầu tiên** | phải đọc từ ba file trở lên mới hiểu việc |
| **Bẫy hay sửa nhầm nhất** | có chỗ sửa đúng-mà-hỏng; hai tới ba cái, mỗi cái một dòng, danh sách đủ để ở *Constraints* của prompt |

### Khuôn L0 — bốn dòng là đủ

L0 là mức thật, không phải cửa lách: sửa lỗi chính tả, đổi tên máy móc, chạy formatter.
Không bịa thêm khối cho đủ bộ.

```markdown
### T-XXX — <việc>

**Prompt:** `prompt/.../xx-tên-L0.md` (L0)

**Goal:**
Một tới ba dòng.

**Acceptance · Verify:** trong file prompt.
```

### Soát lại trước khi coi entry là viết xong

- [ ] Tiêu đề nói **hiện trạng sai**, không nói cách sửa — để lúc đóng task đọc lại còn biết nó từng hỏng ở đâu.
- [ ] Mỗi dữ kiện có **ngày** và **ai quyết** (CLAUDE.md §7.2).
- [ ] "Đúng N" chỉ dùng khi N là **quyết định** của chủ quán; phép đếm của người viết thì phải kèm mốc thời gian và lời mời bổ sung (F-003).
- [ ] Không có giá, số hotline, sơ đồ hay bảng file/dòng nào bị chép từ nhà thật vào entry (F-001).
- [ ] Mục *Cách hoàn thành* chạy **liền 1→10**, không nhảy cóc.
- [ ] Viết lại đáng kể thì để lại một dòng *nghiêng* cuối entry: ngày, ai yêu cầu, đổi cái gì.

[↑ đầu file](#top)
