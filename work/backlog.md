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
| [Chi tiết — việc cần làm](#chi-tiet-can-lam) | bảng mười câu hỏi §10 + mô tả dài T-019…BA-12 |
| [Chi tiết — việc đã xong](#chi-tiet-da-xong) | mô tả dài T-025…T-002 |
| [Vòng chạy một task L1](#vong-chay) | mười bước thủ tục từ nhận task tới khối commit |
| [Task Detail Template](#template) | khuôn viết một task mới |

Mỗi mục có link `↑ đầu file` ở cuối để quay lại bảng này.

<a id="ready"></a>
## Ready

Việc bảo trì ở mục này không việc nào chặn ai — chen vào lúc nào cũng được. Chuỗi BA nay
không còn bị task bảo trì nào chặn (T-015 xong 2026-08-31, T-016 xong 2026-08-31).


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
- **T-021 đã xong 2026-08-31 — F-008 đóng, và mục *Unknowns* nay có hình dạng bắt buộc.**
  `brief.sh` hết đọc mục ấy bằng `grep` theo hình dạng dòng (nó vừa giấu U-005 vừa in U-004 đã
  đóng như đang mở); nay nó đọc **cấu trúc**. Hệ quả cho mọi task sau: một câu hỏi nghiệp vụ chỉ
  được brief nhìn thấy khi nó là **một gạch đầu dòng** trong vùng đang mở của
  `docs/product.md` → *Unknowns* — luật đầy đủ ở CLAUDE.md §4 và `docs/decisions.md` **ADR-007**.
- **T-019 và T-023 chạy song song ngày 2026-08-31, cả hai đã xong.** Trong lúc chạy,
  `work/scope.txt` mang pattern của **cả hai** task cùng lúc, mỗi khối ghi rõ chủ. Hai task không
  giẫm chân nhau: T-019 sở hữu `master_plan/prompt-fullstack.md` + `scripts/check-links.ignore`,
  T-023 sở hữu `docs/updatee_sýstem.md` + `work/proposals/`; hai file dùng chung
  (`work/backlog.md`, `work/findings.md`) mỗi task chỉ sửa mục của mình.
  **Bài học, ghi ở đây chứ không mở finding mới:** hai phiên chạy cùng lúc thì `work/scope.txt` là
  **một file, hai chủ**. Phiên vào sau phải **thêm** khối của mình chứ đừng ghi đè — ghi đè làm
  Gate 3 chấm việc của người kia bằng scope của mình, đúng thứ `work/findings.md` **F-010** mô tả,
  chỉ khác là nguyên nhân đến từ song song chứ không từ quên dọn.
- **T-031 sinh ra từ T-029 (2026-08-31), không chặn ai, nhưng chặn được người ngoài repo.**
  Chủ quán bỏ nút báo xong ở ba trạm bếp ngày 2026-08-31 (`master_plan/shop-facts.md` §5.4), trong
  khi `master_plan/prompt-fullstack.md` §3.6 và §3.7 vẫn thiết kế `PATCH staff/tasks/:id` và
  *"một task = một thẻ, một nút `Xong`"*. Đây là **loại thứ ba** của họ lỗi F-005 / F-007: người
  đọc bản xuất khẩu đứng **ngoài** repo nên không grep được, họ dựng đúng thứ được viết — lần này
  là một cơ chế cho một actor không tồn tại. Ràng buộc (đặc biệt: `don_ban` **vẫn** có thao tác,
  và bỏ endpoint thì phải nói cái gì thay nó) ở `work/findings.md` **F-013** (Open).
- **T-027 sinh ra từ T-026 (2026-08-31), không chặn ai, nhưng brief đang nói dối mỗi phiên.**
  `scripts/brief.sh` cắt cả bốn danh sách ở `MAX_LIST=6` và **không nói là đã cắt**. Ngày
  2026-08-31 số câu hỏi mở lên **bảy**, nên U-011 vô hình với mọi phiên mới kể từ dòng đầu tiên nó
  được viết. Ready cũng đang có 10 dòng chưa tick, trong đó **BA-12** nằm ngoài sáu dòng đầu. Đây
  là lần **thứ hai** cùng một hậu quả với `work/findings.md` **F-008**, khác nguyên nhân: F-008
  hỏng ở *cách đọc* (T-021 đã chữa), lần này hỏng ở *bộ cắt*. Ràng buộc — đặc biệt "đừng chỉ đổi
  6 thành một số to hơn" — ở `work/findings.md` **F-012** (Open).
- **T-025 đã xong 2026-08-31 — F-011 đóng, và repo nay có một cổng thứ tám.**
  `scripts/hooks/commit-msg` là hook của **git**, nên nó đứng ở đúng chỗ Gate 7 không với tới:
  giữa người gõ `git commit -m` ở terminal và git. Hệ quả cho **mọi task sau**, kể cả L0: một
  subject không nói gì (`adg`) không vào được repo, và **mỗi bản clone phải chạy
  `./scripts/install-hooks.sh` một lần** — `.git/` không đi theo `git clone`, nên brief kêu ở mỗi
  phiên khi chưa cài. Luật đầy đủ ở `CLAUDE.md` §6.2 và `docs/decisions.md` **ADR-010**.
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
- **BA-12 sinh ra từ T-026 (2026-08-31), không chặn ai, nhưng chặn được BA-09.** Chủ quán mô tả
  cách bếp **gom việc theo mẻ** trong `work/proposals/admin.admiadmin/admin1.md`; lời ấy nay là dữ
  kiện ở `master_plan/shop-facts.md` §5.4 và cách đọc nó là `docs/decisions.md` **ADR-009**. Đây
  là **lát cắt thứ tư**, không phải một mục của lát cắt nào có sẵn: nó cộng ngang qua mọi bàn và
  mọi đơn, nên không có chỗ đứng trong §3.1 hay §3.2. BA-09 (phạm vi MVP) không chốt được nếu
  chưa biết trục này rộng tới đâu.

Chuỗi BA chạy từ trên xuống. Thứ tự là cột "Cần xong trước" của §11 kế hoạch gốc; BA-01 và BA-02
đã xong 2026-08-30 và **BA-03 xong 2026-08-31**, nên BA-04, BA-05 chạy song song được, còn
BA-07 nay hết bị chặn.

- [ ] T-027 Brief cắt danh sách ở 6 mà không nói đã cắt — U-011 vô hình ngay lúc viết ra (F-012)
- [ ] T-031 Bản xuất khẩu còn thiết kế nút `Xong` ở màn trạm mà chủ quán đã bỏ (F-013)

- [ ] BA-04 `docs/product.md` §3.2 — lát cắt một đơn mang đi (ba kênh) · cần BA-02 (T-011, T-012, T-020 xong)
- [ ] BA-05 `docs/product.md` §3.3 — lát cắt chủ quán đổi menu/giá · cần BA-02
- [ ] BA-06 `docs/product.md` §4 — quy tắc giá và thanh toán · cần BA-04 (BA-03, T-020 xong; **U-005 còn mở**)
- [ ] BA-07 `docs/product.md` §5 — vòng đời đơn, phiên bàn, công việc trạm (BA-03 xong; **U-006, U-007 còn mở**)
- [ ] BA-08 `docs/product.md` §6 — ngoại lệ · cần BA-04–BA-07 (BA-03 xong; **U-007 còn mở**)
- [ ] BA-09 `docs/product.md` §7 — phạm vi MVP · cần BA-01–BA-08
- [ ] BA-10 `docs/decisions.md` — quyết định và giả định · cần BA-01–BA-09
- [ ] BA-11 `docs/product.md` §8 — ba scenario nghiệm thu BA · cần BA-03–BA-10
- [ ] BA-12 `docs/product.md` §3.4 — lát cắt sản xuất theo mẻ · cần BA-03, BA-07 (**U-008–U-011 + S-4 còn mở**)

Mỗi task chạm **một** mục tài liệu riêng, nên revert được độc lập: §3.1 · §3.2 · §3.3 · §4 · §5 ·
§6 · §7 · `docs/decisions.md` · §8 · §3.4. Hai task cùng chạm một mục là dấu hiệu chia việc sai.
BA-12 đứng cuối danh sách nhưng chạm §3.4, tức nó cũng đổi tiêu đề §3 từ *ba* lát cắt sang *bốn* —
đó là dòng duy nhất nó dùng chung với BA-03–BA-05.

Chi tiết từng task ở [**Chi tiết — việc cần làm**](#chi-tiet-can-lam).

[↑ đầu file](#top)

<a id="in-progress"></a>
## In Progress

(không có task nào đang chạy)

<a id="done"></a>
## Done

- [x] T-033 U-012 và U-013 đóng nốt; câu hỏi S-4 viết lại vì hỏi sai cách (2026-08-31)
- [x] T-029 `docs/architecture.md` hết là template rỗng: mặt admin có đặc tả, chỉ POS được ghi (ADR-011) (2026-08-31)
- [x] T-026 Đề xuất Admin/POS được chấm: lời chủ quán về gom mẻ vào nhà thật, phần còn lại bị từ chối có tên (ADR-009) (2026-08-31)
Chi tiết từng task ở [**Chi tiết — việc đã xong**](#chi-tiet-da-xong).

- [x] T-025 Gate 8 — hook `commit-msg` của git từ chối subject rỗng nghĩa; cài bằng `core.hooksPath` (ADR-010, F-011) (2026-08-31)
- [x] T-032 Nợ là một phần riêng: `docs/architecture.md` §12 có mục FE · BE · DB (ADR-012) (2026-08-31)
- [x] T-030 U-006 — ghép bàn là MỘT phiên, MỘT hoá đơn; I-001 đọc lại; mở U-013 (2026-08-31)
- [x] T-028 Bảy lời chốt của chủ quán 2026-08-31: cho nợ, năng lực nồi, suất đem về, máy không gom (2026-08-31)
- [x] BA-03 `docs/product.md` §3.1 — lát cắt một suất tại bàn; I-001–I-004; mở U-006, U-007 (2026-08-31)
- [x] T-023 Hậu quả đã commit của F-009 dọn xong: bản đồ hash, blueprint ra khỏi `docs/` (ADR-008) (2026-08-31)
- [x] T-019 Bản xuất khẩu hết trỏ vào layout repo cũ; bảy dòng ignore đã gỡ (F-007) (2026-08-31)
- [x] T-021 `brief.sh` đọc Unknowns theo cấu trúc; mục Unknowns có hình dạng máy đọc được (ADR-007) (2026-08-31)
- [x] T-009 Ready hết dòng mẫu của template — brief chỉ phiên mới vào một task thật (2026-08-31)
- [x] T-016 Scope quên dọn thì brief kêu; Gate 7b đọc nội dung khối commit (ADR-006) (2026-08-31)
- [x] T-015 §10 kế hoạch gốc: bốn câu mang dấu đã chốt, câu 6 hỏi đúng cả hai kênh (2026-08-31)
- [x] T-014 §2.1 kế hoạch gốc nay có đường điện thoại — khách gọi, nhân viên nhập hộ (2026-08-31)
- [x] T-024 Gate 1b — tài liệu cũng bị máy chấm: mọi pointer phải mở được (ADR-005) (2026-08-30)
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

### T-019 — `prompt-fullstack.md` trỏ tới bảy đường không tồn tại

**Cập nhật 2026-08-30 (T-024):** bảy đường này nay nằm trong `scripts/check-links.ignore` mang tên
T-019, nên Gate 1b xanh chừng nào chúng còn chết. Sửa xong thì **phải gỡ bảy dòng ignore đó** —
ignore hết hạn tự làm gate đỏ, đó là cách task này báo mình đã xong.

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

**Câu hỏi đã có lời giải — chủ repo chốt 2026-08-31.** Đáp án là **(c) tàn dư của một repo
khác**, và cách sửa là **trỏ về nhà thật của repo này**. Bằng chứng đưa ra trước khi hỏi:

- `git log --all -- 'design/*' 'quality/05-checklist.md' 'quality/prompt_guiline.md' 'finding.md'`
  **rỗng** — không đường nào từng tồn tại trong repo này, một lần nào, trong toàn bộ lịch sử.
- Bảy đường không rời rạc mà là **một bộ layout hoàn chỉnh** của repo cũ: `project_preparation/` +
  `design/{data_base,backend,frontend,system_design}/01-thiet-ke.md` + `quality/05-checklist.md` +
  `quality/prompt_guiline.md` + `finding.md` (ở gốc, đánh số F-31, F-67 — repo này đánh F-001…).

**Đường thứ tám, F-007 không kể và Gate 1b không thấy:** dòng cuối §11 bảo người đọc tự kiểm bằng
`grep -n '^## §' project_preparation/prompt-fullstack.md` — file tự gọi tên mình ở
`project_preparation/`, trong khi nó nằm ở `master_plan/`. Gate 1b mù chỗ này vì `check-links.sh`
chỉ nhận chuỗi nháy ngược **không có dấu cách**, mà đây là cả một câu lệnh `grep`. Ghi vào F-007.

**Hai nhóm, hai cách sửa khác nhau** — đây là điểm chính của task:

| Đường cũ | Repo này có nhà tương đương? | Cách sửa |
|---|---|---|
| `quality/prompt_guiline.md` | có — `docs/prompt-guideline.md` | trỏ lại |
| `quality/05-checklist.md` | có — `CLAUDE.md` §8 + `quality/review-gate.md` | trỏ lại |
| `finding.md#f-67`, `#f-31` | có — `work/findings.md` F-001 | trỏ lại |
| `project_preparation/…` | có — chính file này ở `master_plan/` | trỏ lại |
| `design/**` × 4 (schema · API · route · bất biến) | **không** | **bỏ link**, ghi là **đầu ra của pha 1–4 (§7)** |

Bốn đường `design/**` là chỗ dễ sai nhất: chúng là **đầu ra** của chính prompt này, không phải đầu
vào để tra. Trỏ chúng đi đâu cũng sai — nhà duy nhất đúng là "chưa tồn tại, pha 1–4 sinh ra".

**Một cái ngoặc phải sửa theo, không chỉ đổi đường dẫn:** dòng 3 ghi *"Khuôn: quality/prompt_guiline.md
(5 vế)"*. `docs/prompt-guideline.md` §2 là **sáu khối** (Context · Goal · Scope · Constraints ·
Acceptance · Verify). Đổi đường dẫn mà giữ "(5 vế)" là thay một pointer chết bằng một pointer đúng
đường nhưng **sai nội dung** — loại lỗi khó thấy hơn hẳn loại cũ. Năm vế ở §11 là bộ tự kiểm của
**chính file này** trên §2/§3/§4/§6/§8, khác với sáu khối của repo; giữ cả hai, nói rõ cái nào của ai.

**§7 hàng `0 · BA`:** chủ repo chốt **gỡ hẳn** vế *"trả lời 3 câu chưa rõ ở §3.2 hoặc ghi thành giả
định có mức rủi ro"*. Ba câu đó đã gộp vào §3.1 và không còn tồn tại như câu hỏi; ba đầu ra còn lại
của pha 0 giữ nguyên.

**Scope:** `master_plan/prompt-fullstack.md` · `scripts/check-links.ignore` · `work/findings.md` ·
`work/backlog.md`.

**Out of scope:** `master_plan/shop-facts.md` (nhà thật, đang đúng) · `docs/**` · `prompt/**` ·
`quality/**` · `scripts/*.sh` · cấu trúc §1 → §10 · nội dung nghiệp vụ của bất kỳ mục nào.

**Acceptance:**
1. `./scripts/check-links.sh` xanh **sau khi bảy dòng ignore mang tên T-019 đã bị xoá khỏi**
   `scripts/check-links.ignore` — đây là cách task tự chứng minh mình xong (T-024 dựng sẵn: ignore
   hết hạn làm gate đỏ).
2. `grep -nE 'design/|quality/05-checklist|prompt_guiline|finding\.md|project_preparation'
   master_plan/prompt-fullstack.md` **rỗng** — không còn dấu vết layout repo cũ, kể cả đường thứ tám
   nằm trong câu lệnh `grep` mà Gate 1b không thấy.
3. Mọi link markdown còn lại trong file đều mở được, kiểm bằng vòng lặp `ls` chạy tay (Gate 1b bỏ
   qua chuỗi có dấu cách nên không thay thế được bước này).
4. Khối đầu file vẫn nói đúng ba việc: file là **bản xuất khẩu**, lệch ⇒ **nhà thật thắng**, và
   `shop-facts.md` là nhà của dữ kiện quán. Không thêm dữ kiện quán nào vào khối đó (F-001).
5. Bốn thứ `design/**` từng trỏ tới (schema · API · route · bất biến) vẫn được nêu tên, nhưng nêu
   như **đầu ra của pha 1–4 (§7)**, kèm câu nói thẳng chúng chưa tồn tại — người đọc ngoài repo
   không được đi tìm chúng.
6. Dòng 3 không còn ghi "(5 vế)" cho `docs/prompt-guideline.md`; §11 vẫn giữ bộ tự kiểm năm vế của
   file này và nói rõ đó là năm vế của **file này**.
7. §7 hàng `0 · BA` không còn nhắc §3.2; ba đầu ra còn lại của pha 0 (năm kênh · 2 sơ đồ luồng ·
   danh sách quy tắc nghiệp vụ) giữ nguyên.
8. Không đổi cấu trúc §1 → §10, không đổi stack/sơ đồ 16 bảng/bảng sáu pha, không đụng con số
   thành phần ở §9.4 (T-022 sở hữu chúng).
9. `grep -c '⚠️'` không tăng — task này không thêm khối cảnh báo mới (T-022 đã chốt **một** khối ở §3.1).
10. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/gate.sh
grep -nE 'design/|quality/05-checklist|prompt_guiline|finding\.md|project_preparation' \
  master_plan/prompt-fullstack.md            # rỗng
grep -n 'T-019' scripts/check-links.ignore   # rỗng
./scripts/check-links.sh                     # xanh sau khi gỡ ignore
grep -c '⚠️' master_plan/prompt-fullstack.md  # không tăng (2)
grep -n '^## §' master_plan/prompt-fullstack.md   # vẫn đủ §1 → §11
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

### T-027 — Brief cắt danh sách ở 6 và không nói đã cắt, nên mục thứ bảy vô hình

**Prompt:** chưa có · **L1** — nó đổi thứ mọi phiên mới đọc trước chỉ thị đầu tiên.

**Goal:**
Một phiên mới đọc brief là biết **có phần bị cắt hay không**. Danh sách bảy mục không còn trông
giống hệt danh sách sáu mục.

**Nói một câu, việc phải làm là gì:**
Cho brief **nói ra** phần nó đã cắt. Việc **không** phải làm: đổi `MAX_LIST=6` thành một số to hơn
— số nào cũng có một danh sách vượt qua nó, và lúc đó im lặng vẫn im lặng.

**Vì sao có task này:**
Ghi ngày 2026-08-31 trong lúc chạy T-026: câu hỏi mở lên **bảy**, brief in **sáu**, U-011 vô hình
với mọi phiên mới kể từ dòng đầu tiên nó được viết ra. Chi tiết, bốn ràng buộc, và vì sao đây là
lần thứ hai của cùng một hậu quả (sau F-008) ở `work/findings.md` **F-012**.

**Không làm thì mất gì:**
- **Phiên sau tự suy ra câu trả lời cho một câu hỏi nó không biết là đang mở** — nặng nhất, vì
  CLAUDE.md §3.5 chỉ dừng được phiên **biết** mình đang thiếu.
- **BA-12 không phiên nào nhìn thấy**: Ready đang có 10 dòng chưa tick, BA-12 nằm ngoài sáu dòng
  đầu.
- **Chính F-012 biến mất khỏi brief** khi số finding Open vượt sáu.

**Acceptance · Verify:** viết vào prompt khi bắt đầu task; ràng buộc đã có sẵn ở F-012.

[↑ đầu file](#top)

### T-031 — Bản xuất khẩu vẫn thiết kế nút `Xong` ở màn trạm mà chủ quán đã bỏ

**Prompt:** chưa có · **L1** — nó sửa tài liệu người **ngoài** repo dùng để dựng hệ thống.

**Goal:**
`master_plan/prompt-fullstack.md` §3.6 và §3.7 nói đúng thứ chủ quán đã chốt: ba trạm bếp không có
nút báo xong, và POS là nơi ghi tiến độ.

**Nói một câu, việc phải làm là gì:**
Sửa ba chỗ của bản xuất khẩu cho khớp `docs/architecture.md` §1.1. Việc **không** phải làm: xoá
luôn ba luật hiển thị còn đúng của §3.7 (chữ to · cũ nhất lên đầu · màu theo thời gian chờ).

**Vì sao có task này:**
Chủ quán bỏ nút báo xong ngày 2026-08-31 (`master_plan/shop-facts.md` §5.4). Bản xuất khẩu viết
trước đó và nay sai ở ba chỗ; chi tiết, cái giá, và bốn ràng buộc để không sửa thành một lỗi khác ở
`work/findings.md` **F-013**.

**Không làm thì mất gì:**
Một endpoint và một màn hình được xây cho một thao tác **không ai thực hiện**, rồi mọi con số phía
sau nó đứng im — và vì màn hình *trông* như đang chạy, chỗ hỏng chỉ lộ ra lúc quán đã đông khách.

**Acceptance · Verify:** viết vào prompt khi bắt đầu task; bốn ràng buộc đã có sẵn ở F-013.

[↑ đầu file](#top)

### BA-12 — Lát cắt sản xuất theo mẻ chưa có ở đâu, trong khi quán đang làm theo mẻ mỗi sáng

**Prompt:** `prompt/BA/12-production-control-L2.md` (L2) · **Cần xong trước:** BA-03, BA-07 ·
**chặn** BA-09

**Goal:**
`docs/product.md` §3.4 mô tả trọn lát cắt sản xuất — từ lúc một đơn được duyệt, việc của nó nhập
vào tổng nhu cầu của quán, được gom thành mẻ, làm xong, rồi về đúng bàn đã gọi. Xong rồi thì người
đứng quầy đọc §3.4 là biết bảng trước mặt mình phải hiện con số nào, và con số nào tăng giảm khi
ai làm gì.

**Nói một câu, việc phải làm là gì:**
Viết ra **những con số nào tồn tại** ở trục sản xuất và chúng liên hệ với nhau thế nào. Việc
**không** phải làm: vẽ màn hình, đặt tên trạng thái kiểu mã, hay chọn cấu trúc dữ liệu — đề xuất
`work/proposals/admin.admiadmin/admin1.md` có sẵn cả ba và không thứ nào được nhận.

**Vì sao có task này:**
Chủ quán nói ngày **2026-08-31**: hai nồi tráng bánh, mỗi nồi ba quả trứng, sáu khách vào cùng lúc
thì làm sáu quả một mẻ; làm lần lượt từng suất là *mất thời gian và mất nhiệt*. Kèm theo là danh
sách những thứ người đứng quầy phải nhìn thấy cùng lúc — đếm được sáu tính tới ngày đó. Dữ kiện ở `master_plan/shop-facts.md` §5.4,
cách đọc ở `docs/decisions.md` **ADR-009**.

Vì sao nó không nằm gọn trong một lát cắt đã có: con số quán thật sự dùng — *"còn phải làm 14 cái
bánh"* — **không thuộc đơn nào cả**, nó cộng ngang qua mọi đơn đang mở. §3.1 kể chuyện một bàn,
§3.2 kể chuyện một đơn; không mục nào có chỗ cho một con số cắt ngang cả hai.

**Không làm thì mất gì:**
- **BA-09 chốt phạm vi MVP mà không biết trục này rộng tới đâu** — nặng nhất, vì MVP chốt xong là
  cơ sở cho mọi việc sau.
- **BA-07 viết vòng đời công việc trạm theo từng đơn** rồi phát hiện quán không làm theo đơn. Sửa
  sau nghĩa là viết lại §5.
- **Hệ thống làm ra bắt bếp nhận việc lẻ từng suất**, tức chậm hơn cách quán đang làm bằng tay —
  hỏng nặng hơn thiếu tính năng, và chỉ lộ ra khi đang phục vụ khách.
- **Năm câu hỏi (U-008–U-011, S-4) nằm mãi không ai hỏi.** Cả năm hỏi được trong **một** lần gặp;
  để lâu thì phiên sau tự suy, đúng thứ CLAUDE.md §3.5 cấm.

**Đây là con bug của một chỗ mù, không phải của một finding:**
Không vòng rà nào bỏ sót — trục này **chưa từng** có mặt trong `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`,
nên mười một task BA-01–BA-11 phủ đúng khung gốc và vẫn không phủ nó. Khung gốc mô tả quán bằng
**đơn**; chủ quán vận hành quán bằng **mẻ**. Bài học ghi ở đây chứ không mở finding mới: một bộ
task phủ kín tài liệu khung vẫn có thể phủ thiếu thực tế, vì tài liệu khung do người viết, không
do quán viết.

**Thứ tự đọc trước khi sửa file đầu tiên:**
1. `master_plan/shop-facts.md` §5.4 → §5.3 → §4.5 — đọc ngược lên: gom việc, nổ thành phần, thành
   phần một suất. Đọc xuôi sẽ tưởng §5.4 là mở rộng của §5.3, nó không phải.
2. `docs/decisions.md` ADR-009 — bốn khái niệm và vì sao chúng không thay nhau được.
3. `docs/product.md` §3.1 (BA-03) và §5 (BA-07) — trục đơn, để biết hai trục gặp nhau ở đâu.
4. `master_plan/shop-facts.md` §7.2 (S-4) — chỗ suy ra chưa xác nhận; đọc **trước** khi viết một
   dòng nào về "đã làm xong".

**Bẫy hay sửa nhầm nhất:**
- **Chép con số 2 · 3 · 6 vào `docs/product.md`.** Đúng số, và là bản chép thứ hai — F-001. §3.4
  trỏ sang `shop-facts.md` §5.4, không mang số về.
- **Viết "đã làm xong ≠ đã phục vụ" như thể chủ quán nói câu đó.** Chủ quán **không** nói; đó là
  S-4, chưa xác nhận. Trộn vào phần đã chốt là đúng lỗi F-004.
- **Cho §3.4 chỉ có bảng tổng.** Nhìn thì đủ, và mất chủ sở hữu: gom sáu quả trứng mà không tách
  ngược về sáu bàn là bưng nhầm bàn.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở [Vòng chạy một task L1](#vong-chay). Việc riêng của task này ở từng bước:
1. Đọc brief; xác nhận BA-03 và BA-07 đã ở *Done*, vì §3.4 tham chiếu tên trạng thái của cả hai.
2. Nhận task, chuyển BA-12 sang *In Progress*.
3. **Hỏi chủ quán năm câu U-008–U-011 + S-4 trong một lần.** Câu kiểm chứng của S-4 đã soạn sẵn ở
   `master_plan/shop-facts.md` §7.2 — hỏi đúng câu đó.
4. Lời giải nào có ⇒ ghi vào `master_plan/shop-facts.md` §5.4 + §7.1 (và xoá khỏi §7.2 nếu là
   S-4) **trước**, trong cùng một lần sửa; câu nào còn treo thì để nguyên ở *Unknowns*.
5. Khai báo `work/scope.txt` theo mục Scope của prompt.
6. Viết §3.4; đổi tiêu đề §3 sang **bốn** lát cắt.
7. Thêm invariant vào `quality/invariants.md` — chỉ thêm, không sửa cái của task khác.
8. `./scripts/gate.sh`.
9. Gate 2 + Gate 5: cộng xuôi ví dụ sáu bàn ra tổng, rồi tách ngược về sáu bàn; hai chiều phải khớp.
10. Đóng task, dọn scope, giao khối commit.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).

[↑ đầu file](#top)

<a id="chi-tiet-da-xong"></a>
## Chi tiết — việc đã xong

### T-033 — Hai câu cuối đã có lời chốt, và câu hỏi S-4 hỏi sai người

**Prompt:** không có — chủ quán trả lời thẳng ba câu trong một lượt, 2026-08-31. **L2** — một trong
hai lời chốt quyết định **doanh thu tính vào ngày nào**, tức chạm tiền và chạm đối soát.

**Goal:**
U-012 và U-013 hết nằm trong danh sách đang mở, lời chốt về đúng owner, và mọi pointer nói chúng
"còn mở" đã đuổi theo. S-4 vẫn mở, nhưng mang một câu hỏi **hỏi được**.

**Ba câu, ba cách xử khác nhau:**

| Câu | Lời chủ quán | Xử thế nào |
|---|---|---|
| **U-013** | *"pos bấm ghép bàn. không được ghép khi bàn kia đang mở"* | ghi thẳng — `shop-facts.md` §6.16 · `docs/product.md` §3.1.7 |
| **U-012** | *"pos nhận. doanh thu tính ngày nợ"* | ghi thẳng — `shop-facts.md` §6.14 · `docs/product.md` §3.1.6 · `docs/architecture.md` §6.4, §12.4 |
| **S-4** | *"tôi không hiểu"* | **không ghi lời giải nào.** Viết lại câu hỏi — `shop-facts.md` §7.2 |

**Vì sao có task này:**
Lời chốt chỉ sống trong hội thoại thì chết theo phiên (CLAUDE.md §7.2). Hai trong ba câu chặn
BA-06, BA-07, BA-08.

**Điều đáng ghi nhất — lời chốt U-013 đóng một ca đắt bằng một câu:**
Câu hỏi mở ra hai ca rất khác nhau. Ca rẻ: nới một phiên sang bàn **trống**. Ca đắt: **gộp hai hoá
đơn đã có tiền trong đó** — trộn tiền của hai phiên đang mở, chạm thẳng I-001. Chủ quán trả lời
*"không được ghép khi bàn kia đang mở"* ⇒ **ca đắt bị đóng bằng quyết định, không phải bằng mã.**
Hệ thống không cần và **không được** có đường trộn tiền hai hoá đơn. Hệ quả nghiệp vụ phải nói
thẳng ra, vì nó là cái giá: hai nhóm đã ngồi hai bàn riêng thì trả **hai** hoá đơn, kể cả khi họ
quen nhau và xin gộp.

**Điều đáng ghi thứ hai — U-012 làm đối soát lệch ở HAI ngày, không phải một:**
*Doanh thu tính ngày ghi nợ* nghĩa là ngày ghi nợ két **thiếu**, ngày trả nợ két **thừa** trong khi
doanh thu hôm ấy không tăng. Công thức đối soát ở `docs/architecture.md` §6.4 trước đó chỉ có một
dòng nợ ⇒ đã viết lại thành bốn dòng. Kèm một luật mới phải nói ra: **một lần trả nợ không bao giờ
được ghi thành khoản bán mới** — ghi vậy là tính doanh thu **hai lần** cho cùng một bữa ăn, sai
nặng hơn quên thu vì nó làm báo cáo trông đẹp hơn sự thật.

**S-4: "tôi không hiểu" là dữ liệu về CÂU HỎI, không phải về người trả lời.**
Câu kiểm chứng cũ — *"bảng ở quầy lúc đó hiện bàn 5 còn thiếu 3 hay đã đủ?"* — bắt chủ quán suy ra
hộ **một bảng trong máy nên hiện con số nào**. Đó là câu về mô hình dữ liệu, và người viết tài liệu
mới có nghĩa vụ trả lời nó. Câu mới hỏi về **cái quán**, thứ chủ quán biết rõ hơn bất kỳ ai:
*"từ lúc bánh tráng xong đến lúc nó xuống bàn, có khi nào nó phải nằm chờ không?"* — kèm một câu
thứ hai chỉ dùng khi trả lời là "có", vì lời chốt U-009 (bỏ nút bấm ở bếp) đã bịt nguồn dữ liệu
duy nhất của con số thứ tư.

Câu cũ giữ nguyên văn ở §7.2 làm **bằng chứng**, không phải để hỏi lại. Bài học ghi ở đây chứ không
mở finding mới (CLAUDE.md §3.8 — mới hỏng một lần): **câu kiểm chứng phải hỏi về cái quán, không
hỏi về cái bảng.** Ba câu kiểm chứng trước đó — S-1, S-2, S-3 — đều hỏi về quán và đều được trả lời
gọn trong một lần.

**Pointer đã đuổi theo (§7.2):** năm chỗ nói U-012/U-013 còn mở — `docs/product.md` §3.1.6, §3.1.7
và phần văn xuôi mục *Unknowns* · `docs/architecture.md` §11, §12.3, §12.4 · `docs/decisions.md`
ADR-011 và ADR-012 (**sửa tiến** bằng một dòng *Cập nhật*, không viết lại thân ADR — ADR-008).

**Một xác nhận nhỏ đáng giữ:** §12.2 từng chọn **phương án hẹp** cho câu *ai bấm thu nợ* (người
đang trực quầy) và ghi rõ đó là suy ra. Lời chủ quán trùng đúng phương án ấy ⇒ không phải sửa gì.
Đây là bằng chứng cho luật chọn hẹp: chọn hẹp thì lúc có lời giải hoặc đúng sẵn, hoặc sửa một chỗ;
chọn rộng thì sửa cả một nhánh.

**Còn treo:**
Danh sách câu hỏi nghiệp vụ đang mở nay **rỗng**. Còn đúng một chỗ suy ra — **S-4** — với câu hỏi
mới chưa ai hỏi.

[↑ đầu file](#top)

### T-032 — Nợ là một phần riêng, có mục FE · BE · DB

**Xong 2026-08-31.** L2 · không có prompt — chủ repo yêu cầu thẳng.
`docs/architecture.md` **§12** (mới, bốn mục con) + §8, §11, §13 · `docs/decisions.md` **ADR-012**
· `docs/product.md` *Unknowns* U-012 (trỏ tới §12).

**Vì sao có task này:**
Chủ quán chốt **cho nợ** (T-028, `shop-facts.md` §6.14), nhưng lời chốt chỉ nói *lúc sinh ra* của
khoản nợ. T-029 viết xong `docs/architecture.md` thì nợ nằm rải ở sáu chỗ — §1.1, §4, §6.4, §7,
§8, §11 — **không có mục nào của riêng nó**. Chủ repo yêu cầu một mục riêng, có FE, BE, DB.

**Lập luận trung tâm:** nợ và phiên bàn có **hai vòng đời khác nhau**. Phiên đóng xong là hết;
khoản nợ sinh ra *lúc* phiên đóng rồi sống tiếp nhiều ngày. Hai ô *"ai nợ / bao nhiêu"* gắn vào
phiên bàn thì khoản nợ chết ngay tại chỗ nó sinh ra: không tra được ai còn nợ, không thu lại được,
và §6.4 (ngưỡng lệch 0đ) mãi mãi không giải thích được chỗ két thiếu.

**Ba mục đã viết:**
- **§12.1 FE** — ba chỗ nợ hiện ra (POS lúc đóng phiên · màn *Nợ* riêng ở POS · báo cáo & đối
  soát của chủ quán) và **một chỗ nó không được hiện**: năm màn trạm bếp.
- **§12.2 BE** — bốn luật (chặn ở BE chứ không ở FE · nợ ≠ tiền đã thu · mọi thao tác có vết kèm
  người đang trực `quay` · chỉ POS ghi) + bốn đường API bổ sung.
- **§12.3 DB** — sáu thứ phải cất, ba ràng buộc phải để **database** giữ.

**Hai chỗ nói thẳng là đang vượt rào / đang suy ra:**
- §12.3 **cố ý vượt ranh giới §8** (*"không đặt tên bảng, không đặt tên cột"*) cho riêng phần nợ,
  theo yêu cầu thẳng của chủ repo. Đã ghi ⚠️ ngay trong mục: đây là **đề xuất gửi sang pha 2**,
  không phải lược đồ đã chốt.
- **Người bấm *thu nợ* là người đang trực `quay`** — suy từ §4 và §3.3, **không** phải lời chủ
  quán. Ghi rõ ở §12.4 và trong ADR-012 để chủ quán nói khác thì biết sửa chỗ nào trước.

**Chỗ thiết kế bám vào câu còn treo:** §12.3 cất **cả hai** mốc thời gian — lúc ghi nợ và lúc thu
nợ. U-012 còn mở ở vế *doanh thu tính ngày nào*; giữ cả hai mốc thì chủ quán chốt kiểu nào cũng
dựng lại được báo cáo mà không sửa dữ liệu quá khứ. Đó là **phương án hẹp nhất**, không phải một
lựa chọn ngầm (CLAUDE.md §3.5).

**Pointer đã đuổi theo (§7.2):** §11 của `docs/architecture.md` còn liệt **U-006** là câu đang mở —
T-030 đã đóng nó cùng ngày. Đã thay bằng **U-013** và ghi rõ U-006 đóng ra kết quả gì.

**Verify:**
```bash
./scripts/gate.sh
grep -n '^## 12\.\|^## 13\.\|^### 12\.' docs/architecture.md
grep -n 'ADR-012' docs/decisions.md docs/architecture.md
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/LATEST/p'      # U-012, U-013
```

### T-029 — `docs/architecture.md` là template rỗng, trong khi mặt admin đã đủ dữ kiện để viết

**Prompt:** không có — chủ repo yêu cầu thẳng 2026-08-31: *"tôi muốn thêm phần admin cho hệ thống
này"*. **L2** — nó chốt ai được ghi cái gì, tức chạm quyền và chạm tiền.

**Goal:**
`docs/architecture.md` — owner của *Architecture* theo CLAUDE.md §2 — hết là template tiếng Anh
rỗng, và giữ đặc tả mặt quản trị: ba mặt một miền · luật ghi · hai trục · POS · bếp · chủ quán ·
tiền · quyền theo chỗ đứng · chỗ thiếu của hình dạng dữ liệu · câu còn treo.

**Nói một câu, việc phải làm là gì:**
Viết ra **ai được ghi cái gì** và **luật nào không bao giờ được rời khỏi backend**. Việc **không**
phải làm: đặt tên bảng, tên cột, endpoint hay thư mục — lược đồ là việc của System Design và phải
chạy sau BA-12.

**Vì sao có task này:**
Ba nguồn hội tụ trong cùng ngày 2026-08-31. (a) Chủ repo yêu cầu mặt admin. (b) T-026 đã đưa lời
chủ quán về gom mẻ vào `master_plan/shop-facts.md` §5.4 và chốt ADR-009. (c) T-028 ghi bảy lời chốt
nữa, trong đó **ba** lời quyết định thẳng hình dạng của mặt admin: bỏ nút bấm ở bếp (U-009) · máy
không gom, người gom (U-011) · cho nợ và phải ghi ai nợ (U-007 → §6.14).

Vì sao viết được ngay dù BA-12 chưa xong: phần lớn đặc tả **derive được** từ dữ kiện đã chốt, chứ
không phải từ lát cắt chưa viết. Chỗ nào chưa chốt thì tài liệu nêu đích danh là đang treo (§11 của
nó) thay vì tự quyết — lý lẽ đầy đủ ở `docs/decisions.md` **ADR-011**, mục *Rejected alternatives*.

**Không làm thì mất gì:**
- **Người dựng màn hình trạm làm ra một nút không ai bấm** — nặng nhất, và nó **đang** sắp xảy ra:
  bản xuất khẩu vẫn thiết kế `PATCH staff/tasks/:id` (F-013 → T-031).
- **Quyền huỷ bị gán theo `role`**, tức sai `shop-facts.md` §6.13: chủ quán có `role=owner` sẽ huỷ
  được từ bất kỳ đâu, đúng thứ luật *"chức vụ không mở thêm cửa nào"* cấm.
- **Sáu chỗ thiếu của 16 bảng không ai biết là thiếu** — vết hoàn tiền, khoản nợ, audit, ai đang
  trực, note "đem về", đã phục vụ bao nhiêu. Phát hiện lúc đang viết mã là làm lại lược đồ.
- **Owner của §2 vẫn rỗng.** Một owner rỗng là một owner nhìn thì như đã có.

**Phát hiện lớn nhất trong lúc làm — không phải thứ task này đi tìm:**
Lời chốt *"bỏ nút bấm ở bếp"* (2026-08-31) **bác** hai câu đang nằm trong
`master_plan/prompt-fullstack.md` §3.6 và §3.7. Đây là **loại thứ ba** của họ lỗi F-005 / F-007 —
người đọc bản xuất khẩu đứng **ngoài** repo nên không grep được, họ dựng đúng thứ được viết. Ghi
thành `work/findings.md` **F-013**, việc sửa là **T-031**. Task này **không** tự sửa bản xuất khẩu:
ba phiên khác đang có thay đổi chưa commit trong cùng cây, nhận thêm file vào scope là giẫm chân.

**Chạy song song với ba phiên khác — và va số task:**
T-026, T-025, T-028 đều XONG-CHƯA-COMMIT khi task này chạy; `work/scope.txt` mang **bốn** khối, mỗi
khối ghi rõ chủ (F-010). T-029 sở hữu riêng `docs/architecture.md`; ba file dùng chung
(`docs/decisions.md` ADR-011 · `work/findings.md` F-013 · `work/backlog.md`) mỗi task chỉ thêm mục
của mình.

**Bài học lặp lại lần thứ hai trong một ngày, ghi ở đây chứ không mở finding mới:** task này đánh
số **T-030** cho việc sửa bản xuất khẩu, rồi phát hiện một phiên khác vừa lấy T-030 cho U-006 ⇒ đổi
thành **T-031**. Đúng thứ đã xảy ra với U-006/U-008 lúc T-026 chạy. **Dãy số cũng là tài nguyên
dùng chung**: đọc lại số cuối cùng ngay trước khi ghi, đừng lấy số theo bản đọc lúc đầu phiên.

**Còn treo:**
Ba câu chạm thẳng vào mặt admin, ghi ở §11 của tài liệu: **U-006** (ghép bàn một hoá đơn hay hai —
nay đã có T-030 của phiên khác) · **U-012** (nợ trả sau tính doanh thu ngày nào) · **S-4** (bảng
quầy ba cột hay bốn).

[↑ đầu file](#top)

### T-030 — U-006: ghép bàn là một phiên, một hoá đơn

**Xong 2026-08-31.** L2 · không có prompt — lời chủ quán trả lời thẳng U-006.
`master_plan/shop-facts.md` §5.1, §6.16, §7.1 · `docs/product.md` §2.1, §3.1.1, §3.1.4, §3.1.7,
*Unknowns* · `quality/invariants.md` **I-001** (viết lại), **I-002** (thêm vế nhóm ghép).

**Lời chốt:** ghép bàn ⇒ **một phiên và một hoá đơn**.

**Vì sao đây là task L2 chứ không phải một dòng thêm vào:**
Lời chốt này **phủ định cách đọc cũ của một invariant đang có**. I-001 đang viết *"một bàn chỉ có
một phiên chưa thanh toán"*; câu ấy đọc xuôi thì như cấm luôn việc một phiên phủ hai bàn. Câu đúng
là **"một bàn thuộc nhiều nhất một phiên chưa thanh toán"** — quan hệ **không đối xứng**: một bàn
không nằm trong hai phiên còn mở, nhưng một phiên gắn được nhiều bàn. Không sửa I-001 thì phiên
sau đọc invariant rồi chặn đúng thứ chủ quán vừa cho phép.

**Bốn hệ quả đã viết ra, không để người đọc tự suy:**
- Mọi lượt gọi từ bất kỳ bàn nào trong nhóm vào **cùng** phiên — tách ra hai hoá đơn là **thu
  thiếu tiền**, đúng nghĩa cũ của §6.1.
- **Bàn trở lại trống theo từng bàn**: đóng phiên là điều kiện chung, dọn bàn thì dọn từng cái.
- **Bếp không biết đến chuyện ghép** — việc xuống bếp vẫn ghi bàn nào gọi, vì người bưng cần biết
  bưng tới chỗ nào. Ghép là chuyện của tiền.
- §2.1 (ẩn danh theo số bàn) vẫn đúng, chỉ nới thành nhóm bàn.

**Chỗ cố ý KHÔNG suy ra ⇒ mở U-013:** ai được bấm ghép, và ghép được cả khi bàn kia **đã** có
phiên đang mở hay chỉ khi bàn kia còn trống. Xếp một nhóm vào hai bàn trống ≠ gộp hai hoá đơn đã
có tiền trong đó. Quyền bấm cũng chưa ai nói — §6.13 gắn quyền huỷ đơn với chỗ đứng ở quầy, nhưng
đó là luật của việc khác.

**Pointer đã đuổi theo (§7.2):** §6 lên **mười sáu** quy tắc ⇒ sửa lại
`master_plan/prompt-fullstack.md` §7 và `prompt/BA/README.md` (lần thứ hai trong ngày; T-028 vừa
đưa chúng lên mười lăm).

**Verify:**
```bash
./scripts/gate.sh
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/LATEST/p'                    # U-012, U-013
sed -n '/^### 3.1/,/^### 3.2/p' docs/product.md | grep -cE '^ *[0-9]+\.'   # vẫn 15
grep -rn --include='*.md' '15 quy tắc' master_plan/ prompt/BA/ docs/        # rỗng
```

### T-028 — Bảy lời chốt của chủ quán ngày 2026-08-31

**Xong 2026-08-31.** L2 · không có file prompt — lời chủ quán trả lời thẳng bảy câu đang mở.
`master_plan/shop-facts.md` §5.1, §5.4, §6.3, §6.14, §6.15, §7.1, §7.2 · `docs/product.md` §1.1,
§1.2, §1.4, §2.1, §3.1.1, §3.1.4, §3.1.6, *Unknowns* · `quality/invariants.md` **I-005, I-006**.

**Vì sao có task này:**
Chủ quán trả lời một loạt bảy câu trong một lượt. Lời chốt chỉ sống trong hội thoại thì chết theo
phiên (CLAUDE.md §7.2), và sáu trong bảy câu đang **chặn** BA-06, BA-07, BA-08, BA-09, BA-12.

**Bảy câu, và mỗi câu đi về đâu:**

| Câu | Lời chốt | Nhà của nó |
|---|---|---|
| U-005 | Trả trước dùng **đúng hai** phương thức đang có; **POS xác nhận lúc nhận tiền** | `shop-facts.md` §6.3 |
| U-006 | **Ghép bàn có thật** — nhưng một hoá đơn hay hai thì chưa nói ⇒ **còn mở, hẹp lại** | `docs/product.md` → *Unknowns* |
| U-007 | **Cho nợ**; đóng phiên trên POS ghi **ai nợ, nợ bao nhiêu** | `shop-facts.md` §6.14 · §3.1.6 |
| U-008 | Một nồi một lần tráng: **3 trứng / 2 bánh / 1 trứng + 1 bánh**; 2 nồi | `shop-facts.md` §5.4 |
| U-009 | **Bỏ nút bấm ở bếp**; POS tự cập nhật số đã làm cho từng bàn | `shop-facts.md` §5.4 |
| U-010 | Đơn mang đi **không** chung bảng gom việc; suất **đem về** của khách ngồi bàn thuộc **phiên bàn** | `shop-facts.md` §6.15 |
| U-011 | **Máy không gom, người gom** — hệ thống chỉ hiện tổng nhu cầu | `shop-facts.md` §5.4 · §1.4 |

**Ba chỗ cố ý KHÔNG suy ra (CLAUDE.md §3.5, §7.2):**
- **U-006 chỉ đóng một nửa.** *"Ghép bàn có thể xảy ra"* là xác nhận việc ấy có thật, **không**
  phải quyết định hệ thống phải làm gì. Ghép rồi ra một hoá đơn hay hai là câu chạm tiền và chạm
  I-001, nên U-006 ở lại *Đang mở* với phạm vi hẹp hơn và một câu kiểm chứng soạn sẵn.
- **Ba tổ hợp nồi không quy về một đơn vị chung.** 3 trứng · 2 bánh · 1+1 không khớp một mô hình
  "N chỗ mỗi nồi"; §5.4 ghi nguyên ba tổ hợp và cấm đặt ra mô hình quy đổi.
- **S-4 hẹp lại nhưng chưa được trả lời.** U-009 bỏ nút bấm ở bếp ⇒ vế *"phải có người bấm thêm
  một nút"* của S-4 hết đúng, nhưng câu gốc — *có con số thứ tư hay không* — vẫn nguyên. Ghi rõ ở
  `shop-facts.md` §7.2, câu kiểm chứng cũ không phải sửa một chữ.

**Một câu mới mở ra:** **U-012** — nợ trả sau thì ai ghi nhận, doanh thu tính vào ngày nợ hay ngày
trả. Sinh ra từ chính lời chốt cho nợ; để trống thì đối soát lệch hai lần mà §6.10 lấy ngưỡng 0đ.

**Pointer đã đuổi theo (§7.2):** §6 lên **mười lăm** quy tắc ⇒ sửa
`master_plan/prompt-fullstack.md` §7 và `prompt/BA/README.md`. Hai chỗ còn nói "13 quy tắc" là
**ghi chép lịch sử, cố ý không sửa**: `prompt/maintenance/10-prepay-takeaway-L2.md` là prompt của
T-020 đã chạy (nó *ra lệnh* giữ 13 quy tắc — sửa là viết lại thứ T-020 đã được bảo), và các entry
Done cũ trong file này mô tả trạng thái lúc ấy.

**Verify:**
```bash
./scripts/gate.sh
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/LATEST/p'     # đúng U-006, U-012
sed -n '/^### 3.1/,/^### 3.2/p' docs/product.md | grep -cE '^ *[0-9]+\.'   # vẫn 15
grep -rn --include='*.md' '13 quy tắc' master_plan/ prompt/BA/ docs/        # rỗng
grep -n '^### I-' quality/invariants.md                                     # I-005, I-006
```

### T-025 — `commit-msg` hook chặn subject rỗng nghĩa

**Prompt:** không có — task sinh từ `work/findings.md` **F-011** · **ADR:** ADR-004 đặt sẵn điều
kiện kích hoạt, ADR-008 là luật dọn hậu quả, **ADR-010** là quyết định của chính task này ·
L2 — đổi hành vi của **mọi** commit trong repo · **Xong 2026-08-31**

**Goal:**
Một commit có subject không nói gì về chính nó (`dsfg`, `adg`, `ádg`) không vào được repo, kể cả
khi người ta gõ `git commit -m` thẳng ở terminal — chỗ Gate 7 không với tới.

**Nói một câu, việc phải làm là gì:**
Thêm một `commit-msg` hook của **git** (không phải hook của Claude Code) từ chối subject không có
dạng `T-XXX: …` và không đủ dài, kèm cách cài đặt cho bản clone mới. Việc **không** phải làm:
sửa `scripts/check-commit-block.sh` — nó đã đúng phần việc của nó (ADR-004, ADR-006); lỗ hổng nằm
ở chỗ nó chỉ sống trong vòng đời một lượt của phiên.

**Vì sao có task này:**
ADR-004 mục *Rủi ro đã chấp nhận* viết đúng câu: *"Nếu có lần thứ hai một thay đổi đi vào git mà
không có nội dung commit, ghi finding và siết lại."* Ngày **2026-08-31** có **hai** lần nữa trong
cùng một ngày — `0704139 "dsfg"` (nuốt T-016 + T-021 + T-009) và `03ffda3 "adg"` (nuốt T-023 +
T-019 + một file 2342 dòng không thuộc task nào). Cả hai đã push, nên không sửa lại được
(**ADR-008**). Bảng hash → nội dung thật ở **F-011**.

**Không làm thì mất gì:**
- `brief.sh` in RECENT COMMITS cho mọi phiên mới (ADR-002); đỉnh nhánh đang là `adg`.
- `CLAUDE.md` §6 *"One task per commit"* hiện không có cơ chế nào đứng sau — đúng loại hỏng F-001.
- Lý do của một thay đổi mất theo phiên và không lấy lại được.

**Bẫy:**
- **`git` hook không đi theo `git clone`.** Hook đặt trong `.git/hooks/` chỉ bảo vệ một máy. Phải
  có cách cài (ví dụ `core.hooksPath` trỏ vào một thư mục được commit) và phải viết ra ở đâu đó
  người mới đọc được.
- **Phải có đường thoát và nói ra trong chính thông báo lỗi** (`--no-verify`), nếu không nó sẽ bị
  gỡ khỏi máy chứ không được sửa — bài học ADR-003 về *đỏ vì lý do sai*.
- **Không tự soạn nội dung commit.** `CLAUDE.md` §6 nói commit là quyết định của người dùng;
  ADR-004 đã loại phương án hook tự commit.

**Ba cái bẫy trên đã xử ra sao:**
- **Hook không đi theo `git clone`** → hook được **commit** ở `scripts/hooks/`, bật bằng
  `git config core.hooksPath scripts/hooks` qua `./scripts/install-hooks.sh`. Không ép được mỗi
  clone chạy nó, nên chỗ *nói ra* là `scripts/brief.sh`: nó chấm `install-hooks.sh --check` và kêu
  ở **mỗi phiên** khi chưa cài (ADR-002 — trạng thái được đẩy vào phiên, không chờ ai đọc).
- **Đường thoát** `git commit --no-verify` được in **trong chính thông báo từ chối**, cùng với số
  hiệu F-011 để người bị chặn đọc được lý do thay vì chỉ thấy mình bị chặn.
- **Không tự soạn nội dung commit.** Hook chỉ đọc và từ chối; nó không sửa file nội dung, không
  `git add`, không `git commit`.

**Một quyết định phát sinh trong lúc làm — subject dài chỉ bị NHẮC, không bị chặn.**
`CLAUDE.md` §6 nói subject ≤ 72 ký tự, nhưng một subject 75 ký tự **vẫn nói được nó là gì**, tức là
không nằm trong Goal của task này. Chặn nó là *đỏ vì lý do sai*, và ADR-003 đã trả giá một lần cho
bài học ấy. Ghi vào ADR-010 chứ không im lặng, vì nó là chỗ hook **cố ý không** thi hành một câu
chữ của §6.

**Acceptance:**
1. `scripts/hooks/commit-msg` từ chối (exit ≠ 0) cả **năm** subject đã thật sự vào repo này:
   `ádg`, `sdgf`, `sdfg`, `dsfg`, `adg` (F-011).
2. Subject hợp lệ đi qua: `T-025: …` đầy đủ, và L0 không mã task (`Fix typo`) — §6 cho phép.
3. Nội dung git tự sinh (`Merge …`, `Revert …`, `fixup!`, `squash!`, `amend!`) không bị chấm.
4. Comment và dòng trống ở đầu file nội dung không bị nhận nhầm là subject.
5. Subject > 72 ký tự: **exit 0** kèm một dòng nhắc, không chặn.
6. Thông báo từ chối nêu `--no-verify` **và** F-011.
7. File nội dung không đọc được ⇒ exit 0 (hook hỏng không được cướp mất commit).
8. `./scripts/install-hooks.sh` đặt `core.hooksPath`, `--check` đỏ khi chưa cài và xanh sau khi
   cài; nó nêu tên hook thật trong `.git/hooks/` sẽ ngừng chạy.
9. Trong một repo git thật: `git commit -m "dsfg"` bị từ chối, subject hợp lệ commit được,
   `--no-verify` vẫn đi qua — **và cả ba điều đó vẫn đúng khi commit từ một thư mục con**
   (`core.hooksPath` là đường dẫn tương đối; git giải nó theo gốc cây làm việc, đã chấm bằng test).
10. `scripts/brief.sh` kêu khi chưa cài, **im** sau khi cài, im ở repo không có
    `scripts/install-hooks.sh`, và exit 0 ở cả ba ca.
11. ADR-010 ghi luật, bảy phương án bị loại và bốn rủi ro còn lại; `CLAUDE.md` §2, §6.2 và F-011
    nói cùng một chuyện.
12. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/commit-msg.test.sh   # 28/28 ca ok (phủ 1–9)
./scripts/brief.test.sh        # tất cả ca đều qua, gồm H1–H3 (phủ 10)
./scripts/install-hooks.sh     # core.hooksPath = scripts/hooks
./scripts/gate.sh              # xanh, exit 0
```

**Còn lại sau task này — cố ý, đã ghi ở ADR-010 và F-011:**
`--no-verify` vẫn đi qua được · mỗi bản clone vẫn phải tự chạy `install-hooks.sh` · cổng chấm
*rỗng nghĩa*, không chấm *đúng sai* (`T-025: fix stuff` vẫn qua).

### T-026 — Đề xuất Admin/POS nằm trong repo không banner, và lời chủ quán trong đó chưa vào nhà thật

**Prompt:** không có — task sinh từ yêu cầu trực tiếp của chủ repo ngày 2026-08-31
(*"xem xét và làm hệ thống cho nhà hàng này dựa trên `work/proposals/admin.admiadmin/admin1.md`"*).
**L2** — nó thêm dữ kiện vào `master_plan/shop-facts.md`, tức chạm hợp đồng với chủ quán.

**Goal:**
`work/proposals/admin.admiadmin/admin1.md` đi qua đúng đường CLAUDE.md §2 dành cho một đề xuất:
banner nói nó là gì và trái §2 ở đâu · phần **dữ kiện quán** trong nó về đúng owner · phần
**thiết kế** bị từ chối và ghi rõ là bị từ chối · phần **việc phải làm** thành một task có prompt.
Xong rồi thì phiên sau đọc file ấy không còn tưởng nó là sự thật của repo.

**Nói một câu, việc phải làm là gì:**
Chấm một đề xuất và định tuyến nội dung của nó. Việc **không** phải làm: viết mã, dựng cây thư mục,
hay chốt hành vi sản phẩm — hành vi là việc của BA-12, và nó cần năm câu trả lời chưa ai có.

**Vì sao có task này:**
File vào repo ngày **2026-08-31** trong commit `03ffda3 "adg"` — không thuộc task nào, không banner
(`work/findings.md` **F-011**, lần thứ năm của họ lỗi ấy). CLAUDE.md §2 bắt mọi file trong
`work/proposals/` mở đầu bằng banner nêu ngày, trạng thái, và những dòng của bảng §2 mà nó trái;
file này không có. Trong lúc chưa ai chấm, nó là 3.318 dòng nói repo *nên* trông thế nào, nằm cạnh
các file nói repo *đang* thế nào.

Và nó không chỉ là lời cố vấn: **có nguyên văn lời chủ quán** trong đó — hai nồi tráng bánh, mỗi
nồi ba quả trứng, làm lẻ thì mất nhiệt, cùng danh sách những thứ người đứng quầy phải nhìn thấy.
CLAUDE.md §7.2
nói dữ kiện phải được ghi **ngay lúc phát hiện**, vào owner của nó, không để lại thành ghi chú.

**Không làm thì mất gì:**
- **Dữ kiện quán chết cùng phiên.** Con số 2 nồi · 3 quả · 6 quả một mẻ chỉ nằm trong một file
  không ai được phép tin. Phiên sau viết BA-07 hay BA-09 sẽ mô tả quán bằng **đơn**, trong khi quán
  chạy bằng **mẻ**.
- **Phiên sau nhận nhầm tầng thiết kế.** File có cây `/admin/...`, cây `code/be/internal/...`, tên
  trạng thái kiểu mã và mô hình dữ liệu. Không có banner thì một phiên đang vội sẽ chép chúng vào
  `docs/architecture.md` — và tầng dưới quyết thay tầng trên.
- **Bốn câu hỏi + một chỗ suy ra không ai hỏi.** Cả năm hỏi được trong một lần gặp chủ quán.

**Đây là con bug F-011, phía nội dung:**
F-011 sở hữu phía **commit** — vì sao file này vào repo mà không ai nhìn. Task này sở hữu phía
**nội dung** — file đã vào rồi thì chấm nó thế nào. Vòng rà trước không bắt được vì Gate 1b không
chấm `work/` (cố ý, CLAUDE.md §5) và **không cổng nào kiểm banner của một file trong
`work/proposals/`**: luật §2 hiện chỉ sống bằng trí nhớ. Đây là lần **thứ nhất** nó hỏng ở repo
này — `work/proposals/updatee_sýstem.md` cũng từng vào không banner, nhưng lúc đó luật §2 chưa
được viết (T-023 viết nó cùng ngày). Chưa đủ ngưỡng "tốn công hai lần" của CLAUDE.md §3.8 nên
**không mở finding và không thêm cổng**; lần thứ hai thì mở.

**Đã làm gì:**

| Phần của đề xuất | Đi đâu |
|---|---|
| Lời **chủ quán** — 2 nồi · 3 quả/nồi · 6 quả một mẻ · làm lẻ mất nhiệt · danh sách thứ quầy phải nhìn | `master_plan/shop-facts.md` **§5.4** mới, nhật ký ở **§7.1** |
| Suy luận của cố vấn — *"đã làm xong" là con số riêng* | `master_plan/shop-facts.md` **§7.2** làm **S-4**, kèm câu kiểm chứng — **không** trộn vào §7.1 (F-004) |
| Cách đọc nghiệp vụ — sản xuất là trục riêng, bốn khái niệm | `docs/decisions.md` **ADR-009** |
| Chỗ chủ quán chưa nói | `docs/product.md` → *Unknowns* **U-008–U-011** |
| Hành vi sản phẩm phải viết | `work/backlog.md` **BA-12** + `prompt/BA/12-production-control-L2.md` |
| Cây thư mục, màn hình Phase A–D, tên trạng thái, mô hình dữ liệu, bộ `harness/plans/admin/` | **từ chối**, nêu đích danh trong banner của chính file đề xuất |

Kèm theo, ba pointer khẳng định `shop-facts.md` §7.2 rỗng đã hết đúng khi S-4 ra đời và đã được
sửa trong cùng lần thay đổi (CLAUDE.md §7.2 — *theo dấu con trỏ*): `master_plan/shop-facts.md` §7
mở đầu · `master_plan/00-scope.md` · `prompt/BA/README.md`.

**Chạy song song với BA-03 — hai chủ trên ba file.**
BA-03 ở *In Progress* trong một phiên khác khi task này chạy. `work/scope.txt` mang **hai** khối,
mỗi khối ghi rõ chủ; phiên này **thêm** khối của mình chứ không ghi đè (bài học ở mục Ready,
`work/findings.md` **F-010**). Ba file dùng chung, mỗi task chỉ sửa mục của mình:
`docs/product.md` (BA-03 giữ §3.1 · T-026 chỉ thêm vào *Unknowns*) · `work/backlog.md` (mỗi task
một entry) · `quality/invariants.md` (T-026 **không** chạm — invariant của trục sản xuất thuộc
BA-12). Không viết dòng `!quality/invariants.md` vào scope: deny thắng allow, nên nó sẽ chấm đỏ
thay đổi hợp lệ của BA-03.

**Va số ngay trong lúc chạy, đáng ghi:** bốn unknown mới ban đầu đánh U-006–U-009; BA-03 đã lấy
U-006 và U-007 trong cùng khoảng thời gian, nên chúng được đánh lại thành **U-008–U-011**. Hai
phiên chạy song song thì **dãy số cũng là tài nguyên dùng chung** — kiểm số cuối cùng ngay trước
khi ghi, đừng lấy số theo bản đọc lúc đầu phiên.

**Còn treo, phiên sau nhặt:**
Năm câu hỏi chủ quán chưa trả lời — U-008, U-009, U-010, U-011 và S-4. BA-12 không tick hết được
cho tới lúc có lời giải, và cả năm hỏi được trong một lần gặp.

[↑ đầu file](#top)

### BA-03 — Lát cắt một suất tại bàn

**Xong 2026-08-31.** L2 · prompt `prompt/BA/02-slice-dine-in-L2.md` · `docs/product.md` §3.1 ·
`quality/invariants.md` **I-001–I-004** · mở **U-006** (tách/gộp bàn) và **U-007** (khách rời quán
chưa trả tiền) ở `docs/product.md` → *Unknowns*.

**Hai chỗ lệch so với entry gốc, cố ý:**
- Acceptance 6 viết *"đơn `qr_table`"*, nhưng §3.1 gọi kênh là **QR tại bàn** — đúng tên §2 đang
  dùng. Định danh `qr_table` là tên máy, `docs/product.md` chưa từng dùng tên máy của kênh nào, và
  mục *Verify* của chính prompt BA-03 grep `table` mong không có kết quả. Hai tên cho một kênh
  trong cùng tài liệu là đúng họ lỗi F-001, nên chọn tên §2.
- `quality/invariants.md` mục *Template* dùng luôn ID `I-001` làm ví dụ, trùng với invariant thật
  đầu tiên. Đã đổi placeholder đó thành `I-XXX`; không invariant nào bị sửa.

**Gate 2 — mỗi dòng Acceptance trỏ về đâu:**

| # | Chứng minh ở |
|---|---|
| 1 | `docs/product.md` §3.1.1, mười lăm bước; `sed … \| grep -cE '^ *[0-9]+\.'` = 15 |
| 2 | §3.1.2, gạch đầu dòng 3 — "vào đúng phiên đang mở của bàn ấy" |
| 3 | §3.1.4, gạch đầu dòng 2 |
| 4 | §3.1.4, gạch đầu dòng 3 (và bước 11 của §3.1.1) |
| 5 | §3.1.4, gạch đầu dòng 4 (và bước 15) |
| 6 | §3.1.3, đoạn "Điểm chặn nằm giữa bước 4 và bước 6" (và bước 4, bước 5) |
| 7 | §3.1.1 bước 6 và bước 7; §3.1.3 "cả năm trạm" |
| 8 | §3.1.5, khối ví dụ + câu "Hoá đơn ghi ×2, bếp phải tráng ×6" |
| 9 | §3.1.5, đoạn in đậm "Mọi suất bán đều kèm bánh cuốn, không riêng combo" |
| 10 | `quality/invariants.md` I-001 · I-002 · I-003 · I-004, cả bốn có Verification |
| 11 | `grep -nEi 'websocket\|socket\|queue\|endpoint\|schema\|table' docs/product.md` → rỗng |

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

### T-023 — Hai commit trùng tên "T-020", và ba file `docs/` bị commit nhầm

**Xong 2026-08-31.** `docs/decisions.md` **ADR-008** · `work/findings.md` **F-009** (Fixed) ·
**F-011** (mới lúc đó; **đóng cùng ngày** bởi T-025 — Gate 8, ADR-010) · L2 · không có file
prompt — ba quyết định lấy trực tiếp từ chủ repo

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

**Ba quyết định của chủ repo (2026-08-31), làm căn cứ cho Acceptance dưới đây:**

| | Câu hỏi | Chủ repo chốt |
|---|---|---|
| (a) | Hai commit trùng subject `T-020` | **Sửa tiến, không đụng lịch sử.** `0b3a337` đã nằm trên `origin/merge_first_time` — rewrite là lịch sử đã chia sẻ. Ghi bản đồ hash → nội dung thật và chốt luật thành ADR |
| (b) | Hai file `đánh_giá_file_*.md` | **Giữ nguyên trong `docs/`.** Không xoá, không chuyển |
| (c) | `docs/updatee_sýstem.md` | **Chuyển nguyên văn ra ngoài `docs/`**, kèm banner nói rõ là đề xuất chưa áp dụng. Không chiết nội dung |

**Acceptance (viết 2026-08-31, TRƯỚC khi sửa — CLAUDE.md §3, L2):**

| # | Acceptance |
|---|---|
| A1 | `docs/updatee_sýstem.md` không còn; file ở `work/proposals/updatee_sýstem.md`, thân bài **nguyên văn** — diff của lần chuyển chỉ được thêm banner ở đầu, không sửa một dòng nội dung nào |
| A2 | Banner nói đủ bốn thứ: ngày, đây là **đề xuất chưa áp dụng**, mục nào trái CLAUDE.md §2, và §2 vẫn thắng |
| A3 | `grep -rn "docs/updatee"` trong repo không còn kết quả nào trỏ đường cũ như một đường sống (§7.2 *Follow the pointers*) |
| A4 | `CLAUDE.md` §2 có dòng owner cho `work/proposals/`, và cây thư mục §2 có nó — owner mà §2 không liệt kê là owner không ai tìm ra (§7.2) |
| A5 | Hai file `đánh_giá_file_*.md` **không đổi một byte nào** — quyết định (b) là giữ nguyên |
| A6 | F-009 mang bảng hash → nội dung thật cho `1b1d5f5` và `0b3a337`, và phần *hậu quả đã commit* đóng lại |
| A7 | ADR-008 chốt luật "lịch sử đã chia sẻ thì sửa tiến, không viết lại", nêu đích danh hai hash |
| A8 | `0704139 "dsfg"` được ghi thành finding riêng (F-011) — ADR-004 *Rủi ro đã chấp nhận* nói đúng câu "nếu có lần thứ hai … ghi finding và siết lại"; việc siết lại thành task mới trong Ready |
| A9 | `./scripts/gate.sh` xanh |

**Verify:** `./scripts/gate.sh`; `git show --stat` cho lần chuyển file (A1); `grep -rn "docs/updatee" . --exclude-dir=.git` (A3); `git diff --stat` trên hai file `đánh_giá_file_*.md` (A5).

**Đã làm gì (2026-08-31):**

| # | Acceptance | Bằng chứng |
|---|---|---|
| A1 | File ra khỏi `docs/` | `git mv` → `work/proposals/updatee_sýstem.md`; `git diff -M --stat` = **+26/−0**, không một dòng thân bài nào đổi |
| A2 | Banner đủ bốn thứ | Ngày · "ĐỀ XUẤT — CHƯA ÁP DỤNG" · hai chỗ trái §2 (`docs/facts/…`, `work/tasks/…`) · "§2 thắng" |
| A3 | Pointer đi theo | `work/findings.md` F-009 §Impact nay ghi kèm đường mới; các chỗ còn lại là **trích dẫn lịch sử** trong `work/`, nơi đường chết là bằng chứng chứ không phải bug (CLAUDE.md §5) |
| A4 | §2 có owner mới | `CLAUDE.md` §2 thêm dòng `work/proposals/`, thêm một đoạn giải thích, và cây thư mục §2 có nó |
| A5 | Hai file `đánh_giá_*` nguyên vẹn | Không xuất hiện trong `git status`; quyết định (b) là giữ nguyên |
| A6 | F-009 đóng phần hậu quả | Bảng `hash → nội dung thật` cho `1b1d5f5` / `0b3a337`, ba quyết định của chủ repo, Status → Fixed trọn vẹn |
| A7 | ADR-008 | "Lịch sử đã chia sẻ thì sửa tiến, không viết lại", nêu đích danh cả hai hash, bốn phương án bị loại |
| A8 | `0704139 "dsfg"` | **F-011** + **T-025** trong Ready — cả hai **đã đóng 2026-08-31**, cùng ngày, bởi T-025 (Gate 8, ADR-010) |
| A9 | Gate xanh | `./scripts/gate.sh` |

**Hai thứ phát sinh trong lúc làm, không nằm trong task gốc:**

1. **`0704139 "dsfg"`** — giữa lúc T-023 đang hỏi chủ repo ba câu, toàn bộ cây làm việc bị commit
   thành một commit subject `dsfg` gộp T-016 + T-021 + T-009, và đã push. Đây đúng điều kiện kích
   hoạt mà ADR-004 đặt sẵn, nên nó thành **F-011** + **T-025**, không giải quyết trong T-023 (§3.8).
2. **T-019 đang ở *In Progress* nhưng chưa sửa gì**, và `work/scope.txt` của nó bị T-023 ghi đè.
   T-019 đã trả về *Ready*; ai nhận lại phải khai lại scope từ đầu.

**Việc cố ý KHÔNG làm:** không `rebase`, không `--amend`, không `push --force` — lý do đầy đủ ở
**ADR-008**. Và không chiết nội dung `updatee_sýstem.md` thành ADR hay task: chủ repo chọn chuyển
nguyên văn.

### T-021 — `brief.sh` đọc Unknowns theo cấu trúc, không theo hình dạng dòng

**Xong 2026-08-31.** `docs/decisions.md` **ADR-007** · `work/findings.md` **F-008** (Resolved) · L2

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

**Acceptance (viết 2026-08-31, TRƯỚC khi sửa code — CLAUDE.md §3, L2):**

Hợp đồng mới, phát biểu một câu: trong mục `## Unknowns` của `docs/product.md`, **vùng đang mở**
là phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối dưới một tiêu đề `### Đang mở`;
trong vùng đó, **một gạch đầu dòng là một unknown đang mở**, và định danh `U-XXX` được tìm ở bất
cứ đâu trong gạch đầu dòng ấy. Văn xuôi trong vùng mở không sinh ra unknown; mọi thứ dưới một
tiêu đề `###` khác không được đọc.

| # | Ca | Phải xảy ra |
|---|---|---|
| U1 | `- **U-005 — …**` (in đậm chen giữa gạch đầu dòng và định danh) | Vẫn in ra `U-005` — đây là chiều **giấu câu đang mở** của F-008 |
| U2 | Dòng văn xuôi bắt đầu bằng `U-004 — …` nằm dưới `### Đã có lời giải` | **Không** in — chiều **khoe câu đã đóng** của F-008 |
| U3 | Dòng văn xuôi (không gạch đầu dòng) bắt đầu bằng `U-006` ngay trong vùng mở | **Không** in — chỉ gạch đầu dòng mới là unknown |
| U3b | Gạch đầu dòng chứa `U-` nằm dưới một tiêu đề `###` khác (mục "cách viết" chẳng hạn) | **Không** in — tiêu đề khác đóng vùng lại |
| U4 | Một unknown vắt qua ba dòng, tiêu đề dài hơn 96 ký tự | In **một** mục, tiêu đề nối lại rồi cắt ở ranh giới **từ** — không xẻ đôi một chữ tiếng Việt |
| U5 | Vùng mở không còn gạch đầu dòng nào | In `(none)`, không rơi xuống đọc vùng đã đóng |
| U6 | Không có tiêu đề `### Đang mở` (hình dạng cũ của file) | Vẫn đọc được các gạch đầu dòng ở đầu mục — hợp đồng không đòi file phải sửa trước |
| U7 | `docs/product.md` không tồn tại / không có mục `## Unknowns` | `(none)`, **exit 0** — brief không bao giờ chặn (CLAUDE.md §7.1) |
| U8 | Bất kỳ ca nào ở trên | `brief.sh` exit 0, và chỉ in định danh + tiêu đề câu hỏi, không in nội dung dữ kiện (§7.1 "trỏ, không chép") |

Ràng buộc chéo: **không nới regex cho khớp thêm hình dạng** (đó là chữa triệu chứng — Goal ở trên
đã cấm), và **không tạo file test mới** — mở rộng `scripts/brief.test.sh` đã có.

**Verify:** `./scripts/gate.sh` · `./scripts/brief.test.sh` (verify.sh tự chạy mọi
`scripts/*.test.sh`) · `./scripts/brief.sh` trên repo thật, đối chiếu bằng mắt với
`docs/product.md` → *Unknowns*.

### T-016 — Scope quên dọn thì brief kêu; Gate 7b đọc nội dung khối commit

**Cập nhật 2026-08-30 (T-024):** một nguồn của lỗi này đã bị gỡ — `check-scope.sh` không còn tính
`work/scope.txt` là file ngoài scope, nên phiên sau không còn bị Gate 3 ép liệt kê nó vào chính
nó. Phần còn lại của T-016 (kêu khi scope quên dọn, và kiểm tập đã `git add`) vẫn nguyên.

**Prompt:** `prompt/maintenance/09-scope-not-cleared-L2.md` (L2 — đổi hành vi thứ mọi phiên đều chạy)
· **Xong 2026-08-31** · **ADR-006** · `work/findings.md` **F-010** (mới), **F-009** (đóng phần cơ chế)

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

**Acceptance · Verify phần gốc (scope quên dọn):** trong file prompt.

**Acceptance phần mở rộng F-009 (viết 2026-08-31, TRƯỚC khi sửa code — CLAUDE.md §3, L2):**

Gọi *khối commit* là đoạn `git add …` + `git commit -m …` mà lượt giao ra theo §6.1. Gate 7 đã
đọc transcript để hỏi *"có khối không"*; phần mở rộng hỏi thêm *"trong khối có gì"*.

| # | Ca | Phải xảy ra |
|---|---|---|
| A1 | Khối liệt kê một file **ngoài** `work/scope.txt` | Gate 7 nêu **đích danh** file đó, lượt không kết thúc im lặng |
| A2 | Khối chỉ liệt kê file **trong** scope | Gate 7 im lặng, exit 0 |
| A3 | Khối dùng `git add -A` hoặc `git add .` | Gate 7 nêu đích danh dạng lệnh bị §6.1 cấm |
| A4 | Khối liệt kê `work/scope.txt` | Gate 7 kêu — §6.1 cấm nó nằm trong khối |
| A5 | `work/scope.txt` **chưa khai** (rỗng/chỉ comment) | Gate 7 im lặng — không có gì để đối chiếu, đoán là tệ hơn im |
| A6 | Đã kêu một lần cho **cùng một trạng thái cây** | Lần sau im — không lặp vô hạn, đúng luật 3 ở đầu `check-commit-block.sh` |
| A7 | **Index thật** (`git diff --cached`) có file ngoài scope | Cũng bị nêu, cùng một đường ra với A1 |
| A8 | File chưa track nằm trong khối và **trong** scope | Không kêu — ADR-003 không bị lật, vì ở đây căn cứ là scope, không phải trạng thái track |

Ràng buộc chéo: **không đổi cách `check-scope.sh` đọc pattern** (Gate 3 đang đúng), và **không
tạo script mới** — ngữ nghĩa pattern phải còn đúng **một** chủ, nếu không hai bản sẽ trôi khỏi
nhau (cùng họ lỗi F-001).

**Verify phần mở rộng:** `scripts/check-commit-block.test.sh` (mở rộng, không tạo file test mới cho
Gate 7) + `scripts/brief.test.sh` cho phần gốc. Cả hai chạy tự động trong `verify.sh`.

**Đã dựng gì — hai triệu chứng, hai chỗ chấm, vì chúng nổ ở hai thời điểm khác nhau:**

| Chỗ | Kêu khi nào | Mã thoát |
|---|---|---|
| `scripts/brief.sh` | `work/scope.txt` còn pattern **mà** không có task nào ở *In Progress* — nêu đích danh file và số pattern | luôn 0 (§7.1) |
| `scripts/check-commit-block.sh` — **Gate 7b** | khối commit nhặt file ngoài scope · dùng `git add -A` / `git add .` · có `work/scope.txt` trong khối | 2, nhiều nhất **một lần** cho mỗi trạng thái cây |
| `scripts/check-scope.sh --match <path>…` | không kêu — chế độ phụ, in path nằm ngoài scope rồi exit 0 | luôn 0 |

`--match` tồn tại để Gate 7b **không chép lại** cách so khớp pattern: ngữ nghĩa scope giữ đúng một
chủ, nếu không hai bản sẽ trôi khỏi nhau đúng như hai bảng giá của F-001. Cách đọc pattern của
Gate 3 không đổi một dòng nào.

**Ba lựa chọn phải giải trình, đã ghi đủ trong ADR-006:**

1. **Chọn `brief.sh`, không chọn `check-scope.sh`/`gate.sh`** cho triệu chứng "scope quên dọn":
   nó là chỗ duy nhất trong ba ứng viên mà đầu ra **chắc chắn** tới được người đọc (hook
   `SessionStart` → vào thẳng context, ADR-002). Nhánh xanh của gate chỉ đi ra stdout của một hook
   `Stop` exit 0 — nơi không quay lại phiên; muốn nó tới nơi thì phải exit khác 0, tức là chặn,
   thứ Constraints cấm. Nó cũng đúng là chỗ câu sai đang được in ra, và đã cầm sẵn cả hai đầu vào.
2. **Gate 7b đi chệch F-009 ở một điểm, có chủ ý:** F-009 viết *"cảnh báo, không chặn"*; Gate 7b
   dùng **exit 2** — đúng mã thoát Gate 7 đã dùng khi thiếu khối commit — vì ở exit 0 một hook
   `Stop` không có kênh nào về phiên, nên "cảnh báo" ở đó là in vào hư không. Thứ bị trả lại là
   **đoạn văn bản bàn giao**, không phải thay đổi: Gate 1, 1b, 3 đã xanh trước khi nó chạy.
3. **ADR-003 không bị lật.** Gate 7b chấm **danh sách file vừa được cố ý chọn**, không chấm cây
   làm việc; trạng thái track không tham gia vào kết luận (ca A8: file chưa track nằm trong scope
   thì vẫn im). `check-scope.sh` không đổi hành vi Gate 3.

**Số ADR/finding thực dùng khác số ghi trong prompt** — prompt viết ADR-004 và F-007, cả hai đã bị
T-018 và T-013 lấy mất ngày 2026-08-30. Số trống kế tiếp tại thời điểm làm: **ADR-006** và
**F-010**. F-010 chỉ sở hữu phía *scope còn sót* (hậu quả ở `check-scope.sh` và `brief.sh`); phía
*khối commit nhặt nhầm* đã là **F-009** từ trước, nên nó được **nối thêm và đóng**, không chép lại
— viết finding thứ hai cho cùng bảng bằng chứng chính là bệnh F-001.

**Kiểm bằng gì:** `scripts/brief.test.sh` (mới, B1–B5) và `scripts/check-commit-block.test.sh`
(mở rộng, A1–A8 — đúng bảng Acceptance ở trên). Cả hai chạy tự động trong `verify.sh`. Ca A6 từng
**FAIL** ở lần chạy đầu: dấu vết `.git/lean-ai-commit-block` chỉ được đọc ở nhánh *thiếu khối*, nên
một khối xấu bị kêu lại mãi. Đã sửa: nhánh *có khối* đọc dấu cũ trước rồi mới đóng dấu mới.

**Còn nợ, cố ý:** Gate 7b đọc `git add` bằng **văn bản** trong transcript, nên khối viết theo kiểu
lạ (biến shell, `xargs`, xuống dòng giữa danh sách file) sẽ lọt. Nó bắt đúng dạng §6.1 mô tả — cũng
là dạng cả bốn lần hỏng đã dùng. Rủi ro này ghi ở ADR-006, không mở task mới.

### T-009 — Gỡ dòng mẫu T-001 khỏi Ready

**Prompt:** `prompt/maintenance/03-retire-T-001-L0.md` (L0) · **Xong 2026-08-31**

**Hiện trạng đã sửa:**
*Ready* còn một dòng mẫu của template khởi tạo repo — ID `T-001`, nội dung là câu "thay dòng này
bằng task thật đầu tiên". Nó chưa bao giờ là task thật: không Goal, không Scope, không Acceptance.
Nguyên văn dòng đó cố ý **không** chép lại ở đây, vì acceptance của task này là `grep` chuỗi ấy
trong `work/backlog.md` phải rỗng.

Nó không vô hại: `scripts/brief.sh` in **NEXT READY** bằng những dòng chưa tick đầu tiên của
*Ready*, và brief là `SessionStart` hook — nên mọi phiên mới nhận nó như một việc, trước cả chỉ
thị đầu tiên của người dùng. ADR-002 dựng brief để phiên mới nhận trạng thái **hôm nay**; một
brief trỏ vào dòng mẫu là đúng thứ ADR-002 muốn chặn.

**Đã làm:**
Xoá dòng đó khỏi *Ready*. **Không** tick `[x]`, **không** chuyển xuống *Done* — Done ghi việc đã
làm, đưa một dòng mẫu vào đó là làm hỏng lịch sử. Không phát minh task mới lấp chỗ: *Ready* sau
việc này đúng bằng những task đã có.

**Luật để lại — ID đã dùng thì không tái sử dụng:**
Số **T-001 không được cấp lại** cho bất kỳ task mới nào. Nó vẫn xuất hiện trong tên task này, trong
`prompt/maintenance/03-retire-T-001-L0.md` và trong các entry lịch sử — đó là **tham chiếu**, không
phải một task đang sống.

**Verify:** `grep -n 'meaningful task' work/backlog.md` rỗng;
`./scripts/brief.sh` in NEXT READY là T-019 (task thật, có entry chi tiết); *Done* không có dòng nào
mang ID T-001; `./scripts/gate.sh` xanh.

### T-015 — §10 kế hoạch gốc: hai câu đã có lời giải, một câu hỏi hẹp hơn thực tế

**Prompt:** `prompt/maintenance/08-plan-open-questions-scope-L1.md` (L1) · **Xong 2026-08-31** · gỡ chặn BA-10

**Goal:**
§10 câu 6 ("Pickup có cần giờ hẹn bắt buộc không?") và câu 7 (trạng thái giao hàng) **đã có lời
giải** ở `shop-facts.md` §6.5 · §6.7, nhưng §10 vẫn để mở. Riêng câu 6 còn hỏi **hẹp hơn** thực tế:
mốc giờ bắt buộc với cả `pickup` **và** `phone_preorder` (§6.5). Câu 7 thì đúng phạm vi — trạng
thái "đang giao" chỉ có ở đơn giao tận nơi; đừng mở rộng nó cho ba kênh.

Đánh số 1–10 **không đổi**: `work/backlog.md` và `prompt/BA/09-decisions-assumptions-L2.md` trỏ
theo số thứ tự (`§10.6`).

**Acceptance · Verify:** trong file prompt.

**Đã sửa, tất cả trong §10 của `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`:**

| Câu | Thành gì |
|---|---|
| **1** | giữ nguyên câu hỏi, thêm dấu *xác nhận* và *hủy* **đã chốt 2026-08-30** → §6.2 · §6.13, và ghi thẳng **phần "chỉnh sửa đơn" vẫn còn mở** |
| **5** | giữ nguyên câu hỏi, thêm dấu **đã chốt 2026-08-30** → §6.4 |
| **6** | **đổi phạm vi** — từ *"Pickup có cần giờ hẹn bắt buộc không?"* thành *"Giờ khách cần hàng có bắt buộc không, và với những kênh nào?"*, dấu chốt trỏ §6.5: bắt buộc với **cả `pickup` và `phone_preorder`** |
| **7** | giữ nguyên câu hỏi **và phạm vi `delivery`**, thêm dấu chốt trỏ §6.7 |
| đầu §10 | ba dòng dẫn: bốn câu 1·5·6·7 đã có lời giải, đọc ở nguồn, **đừng biến thành `GIẢ ĐỊNH`** |

**Sáu câu còn mở (2, 3, 4, 8, 9, 10) không đổi một ký tự** — `git diff -U0` chỉ hiện bốn dòng
1, 5, 6, 7. Đánh số 1–10 liên tục, vẫn đủ mười câu.

**Đã mở từng mục nguồn ra kiểm (Acceptance yêu cầu nói rõ):** §6.2 (đơn khách tự gửi phải quầy
duyệt) · §6.4 (hoàn tiền, quầy quyết từng ca) · §6.5 (bảng thông tin liên hệ — *Giờ khách cần
hàng* bắt buộc với `pickup` **và** `phone_preorder`) · §6.7 (quán tự giao, trạng thái "đang giao") ·
§6.13 (chỉ người đứng quầy được huỷ). Hai mục đỡ chéo: §5.2 điểm 5 (cả hai kênh đều có mốc giờ)
và điểm 7 (chỉ đơn giao tận nơi có "đang giao"). Ngày chốt lấy từ §7.1 — cả năm dòng đều
**2026-08-30**.

**Ba câu được xác nhận là KHÔNG có lời giải**, nên cố ý không mang dấu chốt: câu 3 (món hết),
câu 9 (đổi giá đang bán), câu 10 (lịch sử thao tác) — `grep` trên `shop-facts.md` không ra dòng
nào. Câu 2, 4, 8 cũng vậy: §6.13 chỉ nói *huỷ* chứ không nói *sửa*, §6.1 nói phiên "chờ thanh
toán" chứ không nói ca khách không trả được, §6.9 · §6.10 nói cộng đủ nguồn và đối soát chứ
không chốt mốc ngày doanh thu.

**Không tự chốt câu nào, không mở U-XXX mới.** Task chỉ ghi lại lời giải đã có sẵn trong
`shop-facts.md`; không có chỗ nào phải suy luận (F-004).

**Mục *"Mười câu hỏi §10"* ở trên không sửa** — đã đúng sẵn và trùng khớp với `shop-facts.md`;
sửa nó là tạo bản chép thứ hai (ADR-001, F-001).

### T-014 — §2.1 kế hoạch gốc thiếu việc khách gọi điện đặt trước

**Prompt:** `prompt/maintenance/07-plan-actor-phone-order-L1.md` (L1) · **Xong 2026-08-31**

**Goal:**
§2.1 *Người dùng chính* liệt kê việc khách làm là "Đặt ship · Đặt trước để tới lấy · Quét QR tại
bàn" — không có đường điện thoại; phía nhân viên cũng chỉ có "Đặt món hộ khách" (tức `staff_pos`).
`docs/product.md` §1.1 · §1.2 **đã** đúng từ BA-01, nên đây là chỗ khung lệch với cả nhà thật lẫn
tài liệu tra cứu — chỗ lệch **thứ bảy** của cùng một kênh. T-011 cố ý không sửa: §2.1 nằm ngoài
vòng rà của nó.

**Đã sửa ba chỗ, tất cả trong §2.1 của `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`:**

| Chỗ | Thêm gì |
|---|---|
| nhóm **1. Khách hàng** | dòng thứ tư: *"Gọi điện đặt trước — khách nói, **không tự bấm**; nhân viên nhập hộ."* Ba dòng cũ giữ nguyên chữ |
| nhóm **2. Nhân viên quán** | dòng *"Nhập hộ đơn đặt trước qua điện thoại"*, đặt ngay dưới "Đặt món hộ khách" và **nói rõ khác chỗ nào** (đặt hộ **tại quầy**), kèm nghĩa vụ hỏi giao-hay-lấy và mấy giờ |
| cuối §2.1 | một dòng trỏ `master_plan/shop-facts.md` §5.2 cho phần ai duyệt và phải hỏi gì lúc nhận máy |

**Không có chỗ lệch thứ tám trong cùng file.** Đã đọc §1, §4.3, §13, §14 — không mục nào khác kể
việc của khách/nhân viên theo kênh; §4.2 và Epic B đã đủ ba kênh từ T-011. Nên **F-006 không được
nối thêm** (prompt chỉ yêu cầu nối khi tìm thấy chỗ thứ tám).

**Đọc chéo `docs/product.md` §1.1 · §1.2 (Acceptance yêu cầu nói rõ đã đọc):** không câu nào ở §2.1
mâu thuẫn. §1.1 ghi *"Gọi hotline để đặt trước; khách nói, nhân viên nhập hộ vào hệ thống"* —
§2.1 nói cùng một việc, ngắn hơn, và **không chép số hotline**. §1.2 ghi *"Nhập hộ đơn đặt trước
qua điện thoại, và khi nhận điện thoại phải hỏi: giao tận nơi hay tới lấy, và cần hàng lúc mấy
giờ"* — §2.1 giữ đúng hai nghĩa vụ đó, thêm phần phân biệt với đặt hộ tại quầy mà §1.2 tách sẵn
thành hai gạch đầu dòng riêng.

**§2.2 không đổi một ký tự** — vẫn là câu trỏ `shop-facts.md` §2 (ADR-001, F-001).

### T-024 — Lượt chỉ đổi tài liệu là lượt không có gì máy chấm

**Prompt:** yêu cầu miệng của chủ repo, 2026-08-30 — *"đánh giá hệ thống và nâng cấp"* (L2) ·
**Xong 2026-08-30**

**Goal:**
Repo này sản xuất tài liệu, nhưng cổng máy chấm duy nhất (`verify.sh`) in đúng một dòng cho mọi
thay đổi tài liệu: *"verify: skipped — only documentation changed."* Bảy trong chín finding đang
có đều là lỗi tài liệu. Xong rồi thì mọi lượt — kể cả lượt chỉ đổi tài liệu — đều có một cổng
deterministic chạy qua, và không tài liệu chỉ đường nào còn trỏ vào đường không mở được mà không
ai biết.

**Nói một câu, việc phải làm là gì:**
Dựng `scripts/check-links.sh` và cho `gate.sh` chạy nó ở **mọi** lượt. Việc **không** phải làm:
sửa bảy đường chết của `master_plan/prompt-fullstack.md` — F-007 nói rõ sửa được thì phải biết
trước file đó còn thuộc dự án nào, và đó là T-019.

**Vì sao có task này:**
Ngưỡng `CLAUDE.md` §3.8 (hai lần) đã vượt cho họ lỗi *tài liệu nói sai về chính repo*: F-005 và
F-006 rà **dữ kiện** đã đổi, F-007 là loại thứ ba — **pointer chết**, và người đọc bản xuất khẩu
đứng ngoài repo nên không `ls` được. Bằng chứng cổng chạy đúng: lần chạy đầu, chưa có dòng ignore
nào, nó dựng lại **đúng bảy đường** F-007 tìm ra bằng tay, cộng hai đường cố ý không tồn tại,
không hơn. Lựa chọn thiết kế ghi ở **ADR-005**.

**Không làm thì mất gì:**
- Mỗi bản xuất khẩu gửi ra ngoài repo lại có thể mang theo pointer chết mà không ai chấm — F-007
  đã cho thấy giá: agent ngoài repo hoặc dừng, hoặc **tự bịa** nội dung bảy file rồi coi là nguồn.
- Nợ pointer không có nơi hết hạn: bảy đường của T-019 nay nằm trong `check-links.ignore` mang tên
  task, và ngày T-019 xong thì dòng ignore thừa **tự bắt đỏ** cho tới khi bị gỡ.

**Đây là con bug F-007** — vòng rà trước không bắt được vì T-013 rà **con số** ("bốn kênh"), còn
chỗ hỏng của F-007 không chứa con số nào. Chấm bằng máy thì không phụ thuộc vòng rà nào cả.

**Sửa kèm — `check-scope.sh` không còn tính `work/scope.txt` là vi phạm scope.**
Gặp ngay khi khai báo scope cho chính task này: Gate 3 đỏ vì `work/scope.txt` (file vừa sửa để
khai báo) nằm ngoài scope nó khai báo. Nghĩa là **mọi** task L1+ khai báo đúng luật §3.4 đều mở
màn bằng một Gate 3 đỏ, và lối thoát duy nhất là tự liệt kê `work/scope.txt` vào chính nó — đúng
thứ đã đi thẳng vào hai commit (T-016). `check-commit-block.sh` đã miễn trừ file này từ trước;
nay `check-scope.sh` cũng vậy. Đỏ vì lý do sai là thứ ADR-003 cấm.

**Acceptance:**
1. `scripts/check-links.sh` chạy độc lập, exit 1 khi một tài liệu chỉ đường nêu đường không mở
   được, in ra `<file> :: <đường dẫn>`.
2. Không chấm `work/` và `prompt/maintenance/` — ở đó đường đã chết là bằng chứng được trích dẫn.
3. Nội dung trong khối ``` không bị tính là pointer; đường dẫn tương đối tính theo thư mục file.
4. File `.md` **chưa track** chỉ được in dòng `note:`, không chặn gate (ADR-003).
5. `scripts/check-links.ignore` giữ ngoại lệ kèm chủ, và **ignore hết hạn làm gate đỏ**.
6. `gate.sh` gọi nó ở mọi lượt, kể cả lượt chỉ đổi tài liệu (khác `verify.sh`).
7. `scripts/check-links.test.sh` phủ 1–5, và `verify.sh` tự chạy mọi `scripts/*.test.sh`.
8. `check-scope.sh` bỏ qua chính `work/scope.txt`.
9. ADR-005 ghi bốn ranh giới và bốn phương án bị loại; `CLAUDE.md` §5, `quality/review-gate.md`
   Gate 1b, `README.md` nói cùng một chuyện.
10. `./scripts/gate.sh` xanh.

**Verify:**
```bash
./scripts/check-links.sh          # OK — mọi đường dẫn ... đều mở được
./scripts/check-links.test.sh     # 8/8 ca ok
./scripts/check-scope.sh          # OK — all tracked changes within declared scope
./scripts/gate.sh                 # xanh, exit 0
```

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
