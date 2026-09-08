# CLAUDE.md — đọc trước, mỗi phiên

## 1. Repo này là gì

**Sản phẩm đang xây:** ⚠️ TODO — điền một dòng: hệ thống gì, cho ai, bán cái gì.
Không có dòng này, phiên cold nhận quy trình trước khi biết sản phẩm và sẽ đi
sai hướng. Dữ kiện đầy đủ nằm ở `master_plan/shop-facts.md`.

**Cách làm:** một bộ tài liệu có chủ sở hữu duy nhất, một backlog, và vài gate
shell khiến mọi thay đổi đều kiểm chứng được.

File này nói **dữ kiện nằm ở đâu**, **làm việc thế nào**, **"xong" nghĩa là gì**.
Nó không chép lại dữ kiện — nó chỉ chỉ chỗ. Chi tiết cơ chế của từng script nằm ở
comment đầu script đó, không nằm ở đây: file này vào context mọi phiên, nên mỗi
dòng thừa là thuế cố định.

Nghi thức tỉ lệ với rủi ro (L0–L3). **Phần lớn thay đổi là L0 hoặc L1.** Định
nghĩa mức: `README.md`. Chi phí từng mức: §3. Cách viết prompt theo mức:
`docs/prompt-guideline.md`.

Repo lớn dần; trí nhớ của một phiên thì không. §7 là cách hệ thống trao cho phiên
mới trạng thái của **hôm nay** — đọc nó trước khi tin bất cứ điều gì bạn nghĩ là
mình đã biết về dự án này.

---

## 2. Chủ sở hữu dữ kiện

Một dữ kiện, một chủ. Hai file mâu thuẫn → chủ trong bảng thắng, file kia là bug
phải sửa **ngay**, không phải task theo sau.

### 2.1 Sản phẩm & kiến trúc

| Dữ kiện | Chủ sở hữu |
|---|---|
| Quy tắc nghiệp vụ, hành vi sản phẩm | `docs/product/` (mục lục: `docs/product/00-index.md`) |
| Dữ kiện quán: phạm vi bán, kênh, giá, phụ thu, thành phần suất, luồng vận hành, quy tắc kinh doanh | `master_plan/shop-facts.md` |
| Câu hỏi nghiệp vụ còn mở | `docs/product/99-unknowns.md` |
| Kiến trúc | `docs/product/1-system-design/architecture.md` |
| Quyết định kiến trúc (ADR) | `docs/decisions.md` |
| Invariant nghiệp vụ | `quality/invariants.md` |
| Tầng bảo vệ của từng invariant + phép đối chiếu | `docs/product/1-system-design/` — pha 1, sinh ở P1-04…P1-06 (ADR-035) |
| Phụ thuộc ngoài + đường suy giảm của từng cái | `docs/product/1-system-design/01-ranh-gioi-he-thong.md` — pha 1, P1-02 |
| Định nghĩa **một ngày bán** + mốc tính tiền + nguồn thời gian | `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` — pha 1, P1-03 |

### 2.2 Chưa có chủ — sinh ra ở pha sau (ADR-035)

| Dữ kiện | Sẽ có chủ khi |
|---|---|
| Schema: tên bảng, tên cột, khoá ngoại | **pha 2**, cùng `docs/product/2-db/` |
| Quy ước code: stack, layout thư mục, đặt tên, khung test | **pha 2**, cùng `docs/product/2-db/` |
| Hợp đồng API: endpoint, quyền theo vai, chữ ký | **pha 3**, cùng `docs/product/3-be/` |
| Route, component | **pha 4**, cùng `docs/product/4-fe/` |

Thư mục của một pha được tạo **cùng dòng nội dung đầu tiên của pha đó**, không
bao giờ trước. Khi `docs/product/2-db/` mở ra, hai dòng đầu bảng này đổi thành
tên file thật **trong cùng một change**.

Đến lúc đó, **không tài liệu nào được đặt tên một bảng, một endpoint hay một
route.** Pha viết thứ pha sau sở hữu là bug kể cả khi mọi gate xanh. Gate 1d (§5)
bắt lớp vi phạm phổ biến nhất, nhưng nó không bắt hết — P1-12 và mắt người vẫn là
lớp cuối.

Dòng *Quy ước code* được thêm vào bảng này có chủ đích: nếu không ai sở hữu nó,
phiên đầu tiên viết code sẽ **tự bịa** stack, cách đặt tên và cấu trúc thư mục —
và cái bịa đó thành fact vì không có chủ để đối chiếu.

### 2.3 Công việc

| Dữ kiện | Chủ sở hữu |
|---|---|
| Trạng thái của **mọi** task (`Ready`/`In Progress`/`Done`) | `work/backlog.md` |
| Mô tả dài của **pha 1**, `P1-01`…`P1-12` | `work/backlog_SD.md` |
| Mô tả dài của **mảng admin**, `ADM-01`…`ADM-53` | `work/backlog_AD.md` |
| Câu hỏi cho chủ quán về admin, và chỗ chủ quán trả lời | `work/admin-questions.md` §3 |
| Scope của task đang chạy | `work/scope.txt` |
| Vấn đề lặp lại, bài học | `work/findings.md` |
| Đề xuất về hệ thống này **chưa được nhận** | `work/proposals/` |

### 2.4 Quy trình

| Dữ kiện | Chủ sở hữu |
|---|---|
| Cách viết prompt/task | `docs/prompt-guideline.md` |
| Cách soát output của LLM | `quality/review-gate.md` |
| Mức rủi ro, triết lý repo | `README.md` |

### 2.5 Ba ghi chú về bảng trên

- **`docs/product.md` là lưu trữ tiền-tách file.** Nó không sở hữu gì, không ai
  trỏ vào nó, và không phiên nào đọc một dữ kiện từ nó.
- **`master_plan/shop-facts.md` cố tình không có link.** Nó trỏ đi đâu cả, mọi
  thứ trỏ vào nó. `master_plan/00-scope.md` là stub chuyển hướng giữ cho link cũ
  còn mở, không sở hữu gì.
- **`work/proposals/` không chứa dữ kiện nào.** Mỗi file mở đầu bằng banner ghi
  ngày, trạng thái, và những dòng của §2 mà nó mâu thuẫn — chỗ nào lệch, **§2
  thắng**. Nó nằm dưới `work/` có chủ đích: đường dẫn nó nêu mô tả một cấu trúc
  chưa tồn tại, và `work/` là nơi Gate 1b không soát link (§5). Một đề xuất được
  nhận sẽ thành task trong `work/backlog.md`, và dữ kiện của nó rơi vào chủ ở §2.

```text
CLAUDE.md          file này — đọc trước
docs/              product/ → 00-index.md, 0-ba/… (hành vi), 1-system-design/
                   (kiến trúc), 99-unknowns.md — tất cả cắt theo pha;
                   decisions.md, prompt-guideline.md
work/              backlog.md (trạng thái mọi task), backlog_SD.md (mô tả pha 1),
                   backlog_AD.md (mô tả admin), admin-questions.md, scope.txt,
                   findings.md; proposals/ — chưa nhận, không sở hữu gì
quality/           invariants.md, review-gate.md
scripts/           gate.sh → check-scope.sh + check-links.sh + check-doc-status.sh
                   + check-phase-boundary.sh + verify.sh + check-commit-block.sh
                   brief.sh (§7); hooks/ → commit-msg (Gate 8), install-hooks.sh
master_plan/       dữ kiện nghiệp vụ của dự án hiện tại
prompt/            bộ prompt dựng từ master_plan/
.claude/           settings.json (SessionStart → brief.sh, Stop → gate.sh)
```

---

## 3. Luật làm việc

Chọn mức theo **cái gì hỏng nếu thay đổi này sai**, không theo độ lớn của diff.

| Nghĩa vụ | L0 | L1 | L2 | L3 | Cưỡng chế bởi |
|---|:--:|:--:|:--:|:--:|---|
| `./scripts/gate.sh` xanh | ✓ | ✓ | ✓ | ✓ | Stop hook |
| Có entry trong `work/backlog.md` | — | ✓ | ✓ | ✓, tách L1/L2 | *tự giác* |
| `work/scope.txt` đã khai | — | ✓ | ✓ | ✓ | Gate 3 (một phần) |
| Acceptance viết **trước** khi sửa | — | ✓ | ✓ | ✓ | *tự giác* |
| Regression test cho invariant liên quan | — | — | ✓ | ✓ | Gate 1 nếu test tồn tại |
| ADR trong `docs/decisions.md` | — | — | nếu có lựa chọn thiết kế | ✓ | *tự giác* |
| Thiết kế được duyệt trước khi viết code | — | — | — | ✓ | *tự giác* |

Cột cuối là cột quan trọng nhất của bảng này. Luật có script chặn thì bạn không
cần nhớ — script sẽ nhắc. Luật ghi *tự giác* thì **không có gì đỡ bạn**: khi
context đầy và task dài, đó chính là những luật sẽ rơi trước. Đọc lại cột đó
trước khi bắt đầu một task L2+.

**L0 là một mức thật, không phải kẽ hở.** Sửa typo, chạy format, đổi tên máy móc
= *sửa → gate → xong*, không giấy tờ. Một thay đổi thành L1+ khi nó đổi hành vi,
đổi hợp đồng, hoặc đổi dữ liệu. Chỉ leo mức khi câu trả lời cho "hỏng gì nếu sai"
chạm tới **tiền, dữ liệu đã lưu, hoặc hợp đồng đã công bố** — không leo để thấy
an tâm.

Ở mọi mức:

1. **Context** — bắt đầu từ session brief (§7.1), nó tự đến. Rồi nạp **đúng cái
   task cần**: entry trong `work/backlog.md`, pattern trong `work/scope.txt`, các
   chủ ở §2 mà task thật sự chạm, code và test dưới các pattern đó. **Không đọc
   repo theo mặc định.**
2. **Focus** — một task một lúc, xong rồi mới sang cái tiếp.
3. **Ưu tiên** (L1+) — lấy item chưa tick trên cùng ở `work/backlog.md` → *Ready*,
   trừ khi người dùng chỉ định khác. Một finding Open trong `work/findings.md`
   đang chặn một task Ready thì làm trước. Chuyển item sang *In Progress* khi bắt
   đầu.
4. **Scope** (L1+) — khai `work/scope.txt` **trước lần sửa đầu tiên**, khớp mục
   Scope của prompt, và ở trong đó. Mỗi dòng một pattern:

   ```text
   order/          mọi thứ dưới order/
   docs/x.md       đúng file này
   !order/db.go    cấm, kể cả khi dòng cho phép ở trên khớp
   ```

   Task thật sự cần rộng hơn → sửa `work/scope.txt` và **nói ra**. Không bao giờ
   sửa ngoài scope trong im lặng. Xoá pattern khi task xong.
5. **Không bao giờ bịa sự thật nghiệp vụ** — quy tắc nghiệp vụ không rõ thì
   **dừng và hỏi**. Không hỏi được thì ghi lại và để hành vi chưa quyết (§4).
   Luật này **không có L0**.
6. **Kiểm chứng** — chạy `./scripts/gate.sh` sau mỗi thay đổi (§5).
7. **Ghi dữ kiện bền** — quy tắc, quyết định, invariant phát hiện lúc làm sẽ vào
   chủ của nó ở §2, theo template của chính file đó, **trong cùng change đã phát
   hiện ra nó**. Cách viết để phiên sau tin được: §7.2.
8. **Không tạo tài liệu nghi thức** — đừng tạo file `.md` không ai yêu cầu. Thêm
   một luật, một hook, một test **chỉ sau khi cùng một vấn đề đã tốn của bạn hai
   lần** (`quality/review-gate.md` → *Vòng phản hồi*).

---

## 4. Việc chưa biết

Không bao giờ để phần cài đặt lặng lẽ quyết một câu hỏi còn mở. Định tuyến nó:

| Loại | Vào đâu | Định dạng |
|---|---|---|
| Câu hỏi nghiệp vụ còn mở | `docs/product/99-unknowns.md` | một bullet dưới `### Đang mở`: `U-XXX — câu hỏi, ai trả lời được, đang chặn cái gì` |
| Vấn đề lặp lại / bài học | `work/findings.md` | template `F-XXX` trong file đó |
| Lựa chọn giữa các thiết kế đều khả thi | `docs/decisions.md` | template `ADR-XXX` trong file đó |

Chỉ ghi thứ có giá trị cho tương lai. Một khiếm khuyết một lần không phải finding.

**Một câu hỏi chỉ được định tuyến nếu brief tìm thấy nó.** `scripts/brief.sh` đọc
mục *Unknowns* theo **cấu trúc**: vùng mở là phần đầu mục cộng mọi khối dưới
heading `### Đang mở`, và trong đó **một bullet là một câu hỏi**. Hệ quả: câu hỏi
viết thành đoạn văn, hoặc để nhầm dưới heading đã trả lời, là câu hỏi phiên sau
**không bao giờ nhìn thấy**. Hợp đồng đầy đủ nằm cùng mục nó chi phối, ở
`docs/product/99-unknowns.md` → *Cách viết một câu ở đây* (ADR-007, F-008).

---

## 5. Kiểm chứng

```bash
./scripts/gate.sh
```

Chạy theo thứ tự:

| # | Script | Bắt gì | Chạy khi |
|---|---|---|---|
| 1 | `check-scope.sh` (Gate 3) | file **git đang theo dõi** bị đổi mà không khớp `work/scope.txt` | mọi lượt |
| 2 | `check-links.sh` (Gate 1b) | đường dẫn trong tài liệu chỉ đường không mở được | mọi lượt, kể cả lượt chỉ sửa docs |
| 3 | `check-doc-status.sh` (Gate 1c) | một mã định danh, hai chỗ, hai trạng thái (`U-XXX`, `GĐ-XXX`) | mọi lượt |
| 4 | `check-phase-boundary.sh` (Gate 1d) | pha 1 đặt tên thứ pha 2/3/4 sở hữu (§2.2) | khi `docs/product/1-system-design/` đổi |
| 5 | `verify.sh` (Gate 1) | Go: gofmt/build/test · Node: test/lint/build · `scripts/*.test.sh` | bỏ qua khi chỉ đổi tài liệu |
| 6 | `check-commit-block.sh` (Gate 7) | lượt kết thúc còn thay đổi tracked mà không có khối commit (§6.1) | chế độ hook, sau khi 1–5 xanh |

Bốn điều cần biết, không hơn:

- **Gate đỏ → đọc đúng cái nó in ra và sửa cái đó.** Vì sao mỗi gate tồn tại và
  nó so sánh thế nào nằm ở comment đầu chính script đó. Không lặp lại ở đây.
- **Gate 1b, 1c chạy cả trên lượt chỉ sửa tài liệu** — đó là loại lượt *sinh ra*
  các lỗi này (đóng một unknown chỉ đụng `.md`), nên một check nằm trong
  `verify.sh` sẽ ngủ đúng lượt tạo ra nó (ADR-005, ADR-032).
- **`work/` và `prompt/maintenance/` không bị soát link/trạng thái** — một đường
  dẫn chết hay một câu hỏng trích ở đó là **bằng chứng**, không phải bug.
- **Cần trích một thứ cố tình sai** → khai vào `scripts/check-*.ignore` kèm chủ
  và lý do. Dòng ignore hết khớp sẽ làm gate đỏ cho đến khi bị xoá.

Gate 3 chỉ phán xét file git **đang theo dõi**. File chưa track nằm ngoài scope
chỉ in ra `note:` và không làm đỏ gate — git không biết nó có trước task hay
không (ADR-003). **Nếu note đó liệt kê file do task của bạn tạo ra: đưa nó vào
scope hoặc xoá nó.** Không có gì khác chặn bạn ở đây, và LLM là loài rất thích
tạo file mới.

Gate cũng được cắm làm Stop hook trong `.claude/settings.json`, nên nó chạy khi
một lượt kết thúc; thất bại chặn lượt và trả output về để sửa.

**Output của gate là bằng chứng duy nhất cho việc một thay đổi chạy được.** "Tôi
đã test rồi" không phải bằng chứng. Các gate còn lại — ánh xạ acceptance→bằng
chứng, cờ đỏ trong diff, review theo mức, review cold-context — ở
`quality/review-gate.md`.

---

## 6. Git

- Làm trên branch cắt từ `main`; không bao giờ commit thẳng vào `main`.
- Chỉ commit hoặc push khi người dùng yêu cầu.
- Một task một commit. Subject: `T-XXX: cái gì đã đổi` (mệnh lệnh, ≤ 72 ký tự).
- `work/scope.txt` là trạng thái làm việc, không phải sản phẩm — **không commit
  pattern**.

### 6.1 Trao khối commit, dán là chạy

Bạn không chạy `git commit`; bạn **viết** nó. Phiên làm việc là nơi duy nhất còn
biết đây là task nào, nó chạm file nào, và gate đã in ra gì — kiến thức đó phải
rời khỏi phiên dưới dạng người dùng dán được. Nên báo cáo kết thúc **mỗi task**,
và **mỗi phiên** cho mọi thứ còn chưa commit, kết thúc bằng:

```bash
# 1. lấy danh sách file — để máy liệt kê, đừng liệt kê bằng trí nhớ
git diff --name-only HEAD | grep -v '^work/scope\.txt$'

# 2. dán danh sách đó vào đây
git add CLAUDE.md work/backlog.md
git commit -m "T-XXX: cái gì đã đổi" -m "Vì sao đổi.
Verified: ./scripts/gate.sh xanh."
```

- **Liệt kê file, từng cái một.** Không bao giờ `git add -A`, không bao giờ `.`
  — khối này phải stage file của task này và không stage thứ đang nằm vạ vật.
  Lấy danh sách bằng lệnh ở dòng 1, đừng nhớ lại: model liệt kê file theo trí nhớ
  thì lúc sót lúc thừa, còn máy thì không.
- **`work/scope.txt` không bao giờ nằm trong khối** (§6; hai lần nó bị commit
  nằm ở `work/backlog.md` T-016).
- **Subject theo §6**, viết bằng ngôn ngữ mà chính thay đổi đó được viết. Thay
  đổi L0 không có mã task thì bỏ tiền tố `T-XXX:`.
- **Body một đến ba dòng** — vì sao, cộng bằng chứng nó chạy. Bỏ body khi subject
  đã nói hết (typo, đổi tên).
- **Một task một khối.** Hai task xong trong một phiên là hai khối, theo đúng thứ
  tự nên commit.
- **Việc chưa commit không phải của bạn thì không gộp vào.** Gọi tên nó, nói rõ
  nó không nằm trong khối của bạn, để lại cho người đã tạo ra nó.

Trao khối này dù người dùng có hỏi hay không — xin commit là một yêu cầu riêng
(§6), và câu trả lời cho nó thì đã viết sẵn rồi.

Luật này được cưỡng chế: `check-commit-block.sh` (Gate 7, §5) chặn lượt kết thúc
mà còn thay đổi tracked chưa commit và không có khối `git commit -m` trong báo
cáo. Nó cũng đọc các dòng `git add` trong khối và gọi tên bất cứ file nào ngoài
`work/scope.txt`, mọi `git add -A` / `.`, và cả `work/scope.txt` nếu nó lỡ xuất
hiện ở đó (Gate 7b, ADR-006). Nó phán xét **danh sách bạn cố ý chọn**, không phán
xét working tree — nên ADR-003 vẫn đứng.

### 6.2 Gate 8 — git tự chối một subject không nói gì

Gate 7 sống trong vòng đời **một lượt của phiên**. Người gõ `git commit -m` trong
terminal không đi qua lượt nào cả, và năm commit đã vào repo này theo đường đó
dưới cái tên `ádg`, `sdgf`, `sdfg`, `dsfg`, `adg` (`work/findings.md` F-011).
`scripts/hooks/commit-msg` là gate đứng ở chỗ Gate 7 không với tới: nó là hook
của **git**, nên chạy cho mọi commit trên clone này, ai viết cũng vậy.

```bash
./scripts/install-hooks.sh          # một lần mỗi clone — set core.hooksPath
./scripts/install-hooks.sh --check  # exit 1 = chưa cài ở đây
```

**Chạy nó trong mọi clone mới.** `.git/` không đi theo `git clone`, nên file hook
nằm trong repo nhưng chưa chạy cho đến khi lệnh trên trỏ `core.hooksPath` vào
`scripts/hooks/` (ADR-010). Session brief (§7.1) in cảnh báo suốt thời gian nó
chưa được cài, nên không ai phải nhớ — nhưng **không gì ép được**, và giới hạn đó
là một phần của quyết định.

Luật: bỏ tiền tố `T-XXX: ` tuỳ chọn, phần còn lại phải **≥ 2 từ và ≥ 8 ký tự**.
Hết. `Fix typo` qua; `adg` không. Subject quá 72 ký tự chỉ **cảnh báo** — nó vẫn
nói được nó đổi gì, mà đỏ vì lý do sai thì dạy người ta gỡ hook. Lối thoát in sẵn
trong chính lời từ chối: `git commit --no-verify`. Nó **không bao giờ viết message
hộ bạn** — §6 giữ commit là quyết định của người dùng (ADR-004); một subject do
máy viết sẽ có đúng chất lượng của `ádg`.

---

## 7. Giữ hệ thống đúng với hiện tại

Repo lớn dần; trí nhớ của một phiên không sống qua được. Mỗi phiên bắt đầu lạnh
và sẽ hành động theo bất cứ thứ gì được trao — nên phải trao nó trạng thái của
**hôm nay**, không phải của ngày viết tài liệu.

Vòng lặp: **brief tự đến → ghi khi đang làm → bàn giao.** Chỉ bước giữa cần kỷ
luật, và điều đó là cố ý — `work/findings.md` F-001 là hồ sơ về chuyện gì xảy ra
khi một luật dựa vào việc ai đó phải nhớ.

### 7.1 Đầu phiên — brief tự đến

`scripts/brief.sh` in trạng thái sống: task đang In Progress, scope đã khai, task
Ready kế tiếp, finding Open, unknown Open, ADR mới nhất, commit gần đây, ngày sửa
cuối của mọi file chủ ở §2, và mọi việc chưa commit. Nó là `SessionStart` hook
trong `.claude/settings.json`, nên chạy khi khởi động, `/clear`, resume và
compaction — output đã ở trong context trước chỉ thị đầu tiên.

Nó cũng cảnh báo một trạng thái mà nó thấy còn bạn thì không: `work/scope.txt`
còn pattern trong khi **không** task nào đang *In Progress* — scope của một task
đã xong mà không ai xoá (§7.3). Xoá nó trước khi bắt đầu bất cứ gì, nếu không
Gate 3 sẽ phán xét thay đổi của bạn bằng scope của người khác. Nếu bạn đang giữa
task, hãy **đưa task về *In Progress*** thay vì xoá scope.

Chạy tay khi trạng thái có thể đã dịch chuyển dưới chân bạn:

```bash
./scripts/brief.sh
```

Ba luật giữ nó lương thiện:

- **Nó chỉ trỏ, không bao giờ chép.** Tên file, mã, ngày, heading — không bao giờ
  một cái giá, một câu quy tắc, một danh sách kênh. Một brief mang dữ kiện chính
  là bản sao thứ hai mà F-001 đã viết về. Đọc dữ kiện từ chủ của nó ở §2.
- **Nó không bao giờ chặn.** Mọi nhánh lỗi exit 0. Một brief hỏng không được phép
  làm bạn mất một phiên.
- **Nó nói khi nó cắt danh sách.** Mọi danh sách đều có trần — 6 cho In Progress,
  Ready, Open findings; 12 cho Open unknowns. Vượt trần thì nó in `→ ĐÃ CẮT` kèm
  số đã in, số còn lại, và chỗ đọc đủ. **Im lặng chỉ có một nghĩa: đó là cả danh
  sách.** Một danh sách 7 mục in ra 6 mục trong im lặng chính là thứ đã làm U-011
  vô hình từ ngày nó được viết (F-012, sửa bởi T-027). Một danh sách bị cắt là
  một con trỏ, không phải một câu trả lời — mở file nó chỉ ra trước khi quyết bất
  cứ điều gì.

Khi một dòng của brief mâu thuẫn với điều bạn tin: ngày tháng của brief lấy từ
git, nên **brief thắng** — đọc lại file chủ đó trước khi chạm vào bất cứ gì.

### 7.2 Trong phiên — ghi sao cho phiên sau tin được

Ghi ngay lúc phát hiện, trong cùng change, vào chủ ở §2 — không bao giờ ghi vào
một note "để lát nữa nộp". Một dữ kiện bạn học được mà không viết xuống sẽ chết
khi phiên kết thúc, và phiên sau sẽ suy lại nó sai.

Bốn luật khiến một dữ kiện đã ghi dùng được bởi người không có mặt lúc đó:

- **Ngày và người quyết.** Mọi dữ kiện mới hoặc đổi đều mang `YYYY-MM-DD` và ai
  đã quyết. Một dữ kiện không ngày thì không bao giờ hết hạn được, nên nó được
  tin mãi mãi.
- **Cái bạn được cho biết ≠ cái bạn suy ra.** ("Chủ" ở đây là người quyết — chủ
  quán, người dùng — không phải file chủ của §2.) Khi câu trả lời bạn nhận được
  ngắn hơn quyết định bạn cần, **khoảng trống đó là suy luận của bạn**: nó vào
  mục suy luận, không bao giờ vào nhật ký những gì đã được xác nhận (F-004).
- **"Đúng N cái" chỉ khi N là một quyết định, không phải bản tóm tắt của bạn.**
  Chủ quán nói "đúng năm kênh, không có kênh thứ sáu" thì được viết là chính xác
  — thêm kênh thứ sáu sau đó cần họ cho phép. Con số bạn tự đếm — "khác nhau ở ba
  chỗ" — thì không: ghi ngày cho nó và mời cái thứ tư (F-003).
- **Đi theo các con trỏ.** Sau khi đổi một dữ kiện, `grep -rn` tìm cái gì đang
  trỏ vào nó. Một con trỏ còn nhắm vào dữ kiện đã dời là bug **trong cùng
  change**, không phải task theo sau.

Loại dữ kiện nào vào đâu: §4. Đừng tạo file mới cho nó (§3.8) — dữ kiện mới thuộc
về một chủ đã có. Nếu một **loại** dữ kiện thật sự mới xuất hiện, bảng §2 mọc
thêm một dòng trong cùng change tạo ra chủ của nó: một chủ mà §2 không liệt kê là
một chủ không ai tìm ra.

### 7.3 Cuối phiên — bàn giao

Bất cứ điều gì chỉ đúng trong đầu bạn đều mất. Trước khi kết thúc:

- Task trong `work/backlog.md` phản ánh thực tế — chuyển sang *Done*, hoặc để
  *In Progress* với phần còn lại **viết vào entry**.
- `work/scope.txt` đã xoá nếu task xong, hoặc còn khai và chính xác nếu chưa.
- Mọi quy tắc, quyết định, invariant, unknown bạn chạm đều nằm ở chủ của nó
  (§2, §4).
- Mọi task xong trong phiên có khối commit dán-là-chạy trong báo cáo (§6.1), cộng
  một khối cho mọi thứ khác còn chưa commit.
- Báo cáo cuối nói **cái gì còn treo**, bằng đúng những từ mà phiên sau cần để
  nhặt lên tiếp — và **mỗi câu hỏi mở nó gọi tên đều mang một link tới chính câu
  hỏi**, không chỉ mã số.

  Một báo cáo viết *"U-022 vẫn mở"* bắt người đọc đi săn U-022; mã số là mục lục,
  không phải câu trả lời. Nên mỗi cái được một link bấm được tới dòng câu hỏi
  thật sự nằm:

  ```markdown
  **U-022** — [docs/product/99-unknowns.md:61](docs/product/99-unknowns.md#L61)
  **GĐ-04** — [docs/decisions.md:844](docs/decisions.md#L844)
  ```

  - **Áp dụng cho mọi loại thứ còn mở bạn gọi tên:** `U-XXX`
    (`docs/product/99-unknowns.md`), `GĐ-XXX` và `ADR-XXX` (`docs/decisions.md`),
    `F-XXX` (`work/findings.md`), `S-X` (`master_plan/shop-facts.md` §7.2), và
    một task bị chặn trong `work/backlog.md`.
  - **Lấy số dòng ngay lúc viết báo cáo**, bằng `grep -n`, trong chính lượt đó.
    Số dòng trôi khi tài liệu lớn lên; số chép từ trí nhớ hoặc từ lượt trước sẽ
    trỏ nhầm dòng.
  - **Link tới chủ ở §2, không bao giờ tới một bản sao.** Link là con trỏ, không
    phải chỗ chép lại câu hỏi — cùng lý do brief chỉ trỏ và không chép (§7.1,
    F-001).

---

## 8. "Xong" nghĩa là gì

Phân tầng như §3. **Một thay đổi L0 xong sau bốn dòng.**

### L0 — bốn dòng

- [ ] `./scripts/gate.sh` xanh (§5).
- [ ] Bạn đã đọc diff của chính mình.
- [ ] Dữ kiện bền nào bạn chạm phải (nếu có) đã nằm ở chủ của nó (§2, §4, §7.2).
- [ ] Nội dung commit đã trao dưới dạng khối dán-là-chạy (§6.1).

### L1 trở lên — thêm

- [ ] Mỗi dòng Acceptance ánh xạ tới một test có tên, hoặc một lần chạy tay có
      output thật dán vào (`quality/review-gate.md` Gate 2).
- [ ] Diff đã đối chiếu bảng cờ đỏ ở Gate 4.
- [ ] Task chuyển sang *Done* trong `work/backlog.md`; `work/scope.txt` đã xoá.
- [ ] Bàn giao: backlog và `work/scope.txt` khớp thực tế (§7.3).
- [ ] Báo cáo: cái gì đổi, kiểm bằng gì (kèm output lệnh), cái gì còn treo — mỗi
      thứ còn mở được gọi tên đều mang link tới dòng nó nằm, grep trong lượt này
      (§7.3).

### L2 trở lên — thêm

- [ ] Invariant liên quan trong `quality/invariants.md` có regression test, và
      **bạn đã tự chạy nó**.
