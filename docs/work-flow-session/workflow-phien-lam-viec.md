# Một lượt làm việc diễn ra thế nào

> **File này không sở hữu dữ kiện nào.** Nó mô tả *cơ chế* và *cách nghĩ* của một
> phiên AI chạy trong repo này. Mọi luật thật nằm ở `CLAUDE.md` và ở các owner
> mà `CLAUDE.md` §2 chỉ tên; chỗ nào file này nói khác `CLAUDE.md`, **`CLAUDE.md`
> thắng và file này là bug phải sửa**. Viết 2026-09-16 theo yêu cầu của chủ repo,
> để đọc hiểu luồng chạy chứ không phải để tra luật.

Đọc theo thứ tự: §1 là thứ xảy ra **trước khi** bạn gõ chữ đầu tiên, §2–§9 là một
lượt từ prompt tới khối commit, §10–§12 là cách nhìn vấn đề đằng sau các bước ấy.

---

## 0. Bản đồ một lượt

```text
       [bạn mở phiên]
            │
            ▼
   SessionStart hook ──► scripts/brief.sh ──► trạng thái HÔM NAY vào context
            │                                 (task đang chạy, scope, finding,
            │                                  câu hỏi mở, ADR mới, commit gần đây)
            ▼
   CLAUDE.md nạp sẵn ──► bảng owner §2 · bậc rủi ro §3 · luật §4–§8
            │
            ▼
       [bạn viết prompt]
            │
            ├─1─► PHÂN LOẠI: hỏi đáp? L0? L1+? hay thiếu dữ kiện nghiệp vụ?
            ├─2─► LẤY CONTEXT: chỉ owner mà task chạm tới, không đọc cả repo
            ├─3─► KHAI SCOPE (L1+): work/scope.txt, trước lần sửa đầu tiên
            ├─4─► LÀM: sửa trong scope; gặp chỗ nghiệp vụ mơ hồ thì DỪNG, HỎI
            ├─5─► GHI DỮ KIỆN: finding / unknown / ADR về đúng nhà, cùng lần sửa
            ├─6─► CHẠY GATE: ./scripts/gate.sh — output thật là bằng chứng duy nhất
            └─7─► BÀN GIAO: backlog đúng thực tế, scope dọn, khối commit dán được
            │
            ▼
      Stop hook ──► gate.sh --hook ──► đỏ thì CHẶN lượt, trả lỗi về cho tôi sửa
            │                          xanh thì hỏi tiếp: khối commit đâu? (Gate 7)
            ▼
       [bạn dán khối commit] ──► git hook commit-msg (Gate 8) chấm subject
```

Hai chỗ đáng chú ý ngay từ bản đồ: **tôi không tự chạy `git commit`** (bạn quyết),
và **tôi không tự quyết được lượt đã xong** (Stop hook quyết).

---

## 1. Trước khi bạn gõ chữ đầu tiên — brief tự đến

`.claude/settings.json` gắn `scripts/brief.sh` vào hook `SessionStart`. Nó chạy
khi mở phiên, khi `/clear`, khi resume, khi context bị nén. Output của nó nằm
trong context **trước** câu đầu tiên của bạn.

Vì sao cơ chế này tồn tại: mỗi phiên của tôi bắt đầu **lạnh hoàn toàn**. Tôi
không nhớ hôm qua làm gì. Repo thì lớn lên mỗi ngày. Nếu việc "đọc trạng thái
hiện tại" là thứ phải nhớ làm, sẽ có ngày tôi không làm, và tôi sẽ hành động theo
trạng thái của ngày tài liệu được viết chứ không phải hôm nay. Brief tự đến nên
**không ai quên nó được**.

Brief đưa cho tôi, mỗi mục là một con trỏ chứ không phải một bản sao:

| Mục brief in ra | Tôi dùng nó để làm gì |
|---|---|
| IN PROGRESS | có task đang dở không — nếu có thì tôi không mở task mới |
| DECLARED SCOPE | Gate 3 sẽ chấm tôi bằng scope nào; còn pattern mà không có task ⇒ cảnh báo |
| NEXT READY | việc tiếp theo nếu bạn không chỉ định việc khác (`CLAUDE.md` §3.3) |
| OPEN FINDINGS | lỗi lặp đã biết — có cái nào chặn việc tôi sắp làm không |
| OPEN UNKNOWNS | câu hỏi nghiệp vụ **chưa có lời**, tức vùng tôi tuyệt đối không được tự suy |
| LATEST DECISIONS | ADR mới nhất — luật vừa đổi mà tài liệu cũ chưa kịp phản ánh |
| RECENT COMMITS + OWNER FILES last changed | file nào vừa động, để tôi biết chỗ nào trí nhớ của mình đã cũ |
| UNCOMMITTED | có ai đang sửa dở giữa chừng không |

Ba luật giữ brief lành mạnh, và cả ba đều đáng để bạn biết vì chúng quyết định
**tôi tin gì**:

- **Brief trỏ, không chép.** Nó in tên file, mã số, ngày, tiêu đề — không bao giờ
  in một cái giá, một luật nghiệp vụ, một danh sách kênh bán. Một brief mang dữ
  kiện là bản sao thứ hai, và bản sao thứ hai luôn trôi khỏi bản gốc (đó là
  `work/findings.md` F-001, bài học đắt nhất của repo này).
- **Brief không bao giờ chặn.** Mọi đường lỗi đều exit 0. Brief hỏng không được
  làm mất một phiên làm việc.
- **Brief nói khi nó cắt danh sách.** Mỗi danh sách có ngưỡng. Vượt ngưỡng thì in
  `→ ĐÃ CẮT` kèm số còn lại và chỗ đọc đủ. Im lặng chỉ được phép nghĩa là *"đó là
  cả danh sách"* — vì đã có một câu hỏi mở vô hình suốt nhiều phiên chỉ vì brief
  in 6/7 mục mà không nói nó in thiếu.

**Khi brief mâu thuẫn với điều tôi đang tin: brief thắng.** Ngày của nó lấy từ
git, còn niềm tin của tôi lấy từ một tài liệu tôi vừa đọc mà không biết nó cũ hay
mới. Gặp mâu thuẫn, tôi mở lại owner đó trước khi chạm vào bất cứ gì.

---

## 2. `CLAUDE.md` nạp vào — tôi thật sự đọc ra cái gì

`CLAUDE.md` đứng sẵn trong context mọi phiên. Nó cố tình **không** chứa dữ kiện
nghiệp vụ — mỗi dòng của nó là thuế cố định trả cho mọi phiên, nên nó chỉ giữ thứ
phiên nào cũng cần. Cái tôi rút ra khỏi nó, theo đúng thứ tự ưu tiên:

1. **Bảng owner §2 — "một dữ kiện, một chủ".** Đây là thứ tôi dùng nhiều nhất
   trong cả phiên. Nó trả lời câu hỏi tôi phải hỏi trước mọi lần đọc và mọi lần
   ghi: *dữ kiện này nhà ở đâu?* Hai file nói khác nhau thì file được bảng chỉ
   tên là đúng, file kia là bug phải sửa **ngay lúc phát hiện**, không phải task
   sau.
2. **Những dòng ghi *chưa có owner*.** Schema, quy ước code, hợp đồng API, route
   — bốn dòng ấy cố ý trống vì chúng thuộc pha sau. Chúng là **lệnh cấm** đối với
   tôi: trước khi pha ấy mở, tôi không được đặt tên bảng, tên cột, endpoint hay
   route ở bất cứ đâu, kể cả khi tôi "biết" nó nên trông thế nào. Đây đúng là chỗ
   một LLM trượt dễ nhất, vì câu văn bịa ra nghe rất hợp lý.
3. **Bậc rủi ro §3 và cột *Enforced by*.** Cột cuối bảng §3 là cột quan trọng
   nhất: nghĩa vụ nào có script đứng sau thì tôi không cần nhớ — script sẽ nói.
   Nghĩa vụ ghi *self-discipline* thì **không có gì bắt được nếu tôi quên**, và
   đó chính là những thứ rụng đầu tiên khi context đầy và task dài.
4. **§4 — đường đi của một chỗ chưa biết** (xem §6 dưới đây).
5. **§7 — nạp/ghi/bàn giao**, tức vòng đời bộ nhớ của hệ thống này.

---

## 3. Bạn viết prompt — việc đầu tiên tôi làm là phân loại, không phải gõ

Trước khi đọc bất kỳ file nào, tôi trả lời bốn câu về chính prompt của bạn:

**a) Đây là câu hỏi hay là một thay đổi?** Câu hỏi thì trả lời, không sửa file,
không khai scope, không cần khối commit. Một nửa số prompt là loại này và mọi thủ
tục dưới đây đều không áp dụng.

**b) Nếu là thay đổi, nó ở bậc nào?** Chọn theo **hậu quả khi sai**, không theo số
dòng diff. Bộ câu hỏi ở `docs/prompt-guideline.md` §1:

| Câu hỏi | Nếu "có" |
|---|---|
| Chạm tiền, đơn hàng, hay dữ liệu lịch sử? | tối thiểu L2 |
| Người dùng thấy hành vi nghiệp vụ khác đi? | tối thiểu L2 |
| Thêm/đổi contract giữa hai thành phần? | tối thiểu L2 |
| Sai thì sai **âm thầm**, vài ngày sau mới lộ? | L2+ |
| Revert không còn là revert một commit? | L3 |

Phân vân giữa hai bậc thì chọn bậc cao hơn. Nhưng **L0 là bậc thật, không phải
kẽ hở**: sửa typo, đổi tên cơ học, chạy format — *sửa → gate → xong*, không giấy
tờ. Nâng bậc để "cho an toàn" là ceremony rỗng, và ceremony rỗng dạy người ta bỏ
qua ceremony thật.

**c) Prompt này có đủ sáu khối để làm được không?** Một prompt L1+ đầy đủ có
*Context · Goal · Scope · Constraints · Acceptance · Verify*
(`docs/prompt-guideline.md` §2). Thiếu khối nào thì tôi tự suy ra khối đó và
**nói ra tôi đã suy gì** — chỗ nguy hiểm nhất là *Acceptance*: nếu không viết nổi
acceptance thì Goal chưa rõ, và không ai chấm được kết quả, kể cả bạn.

**d) Có chỗ nào là dữ kiện nghiệp vụ mà tôi đang phải đoán không?** Nếu có, tôi
dừng ở đây và hỏi bạn — trước khi làm, không phải sau. Luật này không có mức L0
(`CLAUDE.md` §3.5).

Ba hình prompt hay gặp và phản ứng của tôi:

| Bạn viết | Tôi hiểu thành |
|---|---|
| "sửa lỗi chính tả ở file X" | L0 · không backlog, không scope, gate rồi xong |
| "thêm phụ thu cho kênh giao hàng" | L1+ **và** một dữ kiện nghiệp vụ ⇒ mở `master_plan/shop-facts.md` xem đã có lời chốt chưa; chưa có thì **hỏi**, không tự đặt con số |
| "làm task tiếp theo đi" | lấy mục Ready đầu tiên ở `work/backlog.md`, trừ khi có finding Open đang chặn nó |

---

## 4. Lấy context — chọn theo **chủ quyền**, không theo **độ liên quan**

Mặc định của repo này viết thẳng trong `README.md`: **không đọc cả repo**. Lý do
không phải tiết kiệm — mà là chất lượng. Context đầy thì thứ rụng trước tiên
chính là các nghĩa vụ *self-discipline* ở §3, tức những thứ không script nào bắt
được. Một phiên đọc 30 file rồi quên dọn `work/scope.txt` tệ hơn một phiên đọc 4
file và bàn giao sạch.

### 4.1 Câu hỏi tôi đặt, và câu hỏi tôi cố ý không đặt

Câu hỏi sai là **"file nào liên quan tới task này?"**. Trong một repo mà mọi tài
liệu nói về cùng một quán ăn, gần như file nào cũng *liên quan một chút* — nên câu
ấy không có điểm dừng, và nó luôn trả lời bằng "đọc thêm cho chắc".

Câu hỏi đúng là **"dữ kiện tôi đang cần có chủ là ai?"**. Câu ấy có đúng một câu
trả lời, và câu trả lời nằm ở bảng owner `CLAUDE.md` §2 — tra bảng chứ không tìm
kiếm. Chọn context ở repo này là một phép **tra chủ quyền**, không phải một phép
đo độ giống nhau.

Hệ quả thực tế: tôi liệt kê ra *các dữ kiện* task cần trước, rồi mới suy ra danh
sách file — chứ không liệt kê file rồi đọc xem trong đó có gì dùng được.

### 4.2 Bốn phép thử cho một file đang cân nhắc

| Phép thử | Câu hỏi | Nếu câu trả lời là "không" |
|---|---|---|
| **Chủ quyền** | §2 có chỉ file này làm chủ dữ kiện tôi cần không? | Nó là bản sao hoặc bằng chứng. Đọc để hiểu bối cảnh thì được; **lấy dữ kiện ra khỏi nó thì không** — dữ kiện lấy ở owner |
| **Câu hỏi cụ thể** | Tôi mở nó để trả lời câu nào? Viết được câu ấy ra thành một câu hoàn chỉnh không? | Viết không ra thì đó là *đọc cho chắc*. Bỏ |
| **Hậu quả** | Nếu tôi đoán sai chỗ này, gate hay test có bắt được không? | Bắt được ⇒ đọc sau cũng kịp. **Không bắt được** — tiền, dữ kiện nghiệp vụ, nghĩa vụ *self-discipline* — ⇒ đọc **trước** lần sửa đầu tiên |
| **Bậc** | Task này có phải L0 không? | L0 thì gần như không đọc gì: diff của chính mình và `./scripts/gate.sh`. Đọc thêm ở L0 là ceremony rỗng |

Phép thử **hậu quả** là phép thử tôi dùng để xếp thứ tự, không chỉ để loại: nó nói
file nào phải đọc *trước khi gõ*, file nào đọc lúc cần cũng được.

### 4.3 Thứ tự đọc — dừng ngay khi đã đủ để làm

1. **Brief** (đã có sẵn) — trạng thái hôm nay.
2. **Entry của task** ở `work/backlog.md`. Mô tả dài có thể nằm ở sổ khác:
   pha 1 ở `work/backlog_SD.md`, mảng admin ở `work/backlog_AD.md` — nhưng
   **trạng thái** thì chỉ `work/backlog.md` giữ.
3. **File prompt** của task trong `prompt/` nếu có — đọc cả *Constraints* và
   *Unknowns*, không chỉ *Goal*.
4. **Đúng những owner mà task chạm tới** ở bảng `CLAUDE.md` §2. Task về luật bán
   hàng ⇒ `master_plan/shop-facts.md` và `docs/product/`. Task về kiến trúc ⇒
   `docs/product/1-system-design/architecture.md`. Task đụng tiền ⇒
   `quality/invariants.md`. Không mở owner mà task không chạm.
5. **Câu hỏi đang mở** ở `docs/product/99-unknowns.md` nếu vùng tôi sắp sửa nằm
   gần một câu chưa có lời.
6. **Code và test nằm trong các pattern của `work/scope.txt`.**

Ba thứ tôi **cố ý không** đọc: `work/proposals/` (đề xuất chưa được nhận, không
phải dữ kiện), `docs/product.md` (bản lưu trước khi tách, không sở hữu gì), và
lịch sử commit xa — brief đã in đúng phần cần.

### 4.4 Nhiều file mang cùng một chữ — chỗ tôi mở sai dễ nhất

Đây là bảng quan trọng nhất của mục này. Mọi lần chọn sai context ở repo này đều
là chọn **đúng chủ đề, sai chủ quyền**: file mở ra nói về thứ tôi cần, nhưng nó
không phải nhà của thứ ấy.

| Khi tôi cần | Mở | Đừng lấy dữ kiện ở đây, và vì sao |
|---|---|---|
| **Trạng thái** một task (`Ready`/`In Progress`/`Done`) | `work/backlog.md` | `work/backlog_SD.md`, `work/backlog_AD.md` — hai file ấy chỉ giữ *mô tả dài*; trạng thái viết ở đó là bản sao |
| **Mô tả dài** của một task pha 1 / admin | `work/backlog_SD.md` · `work/backlog_AD.md` | `work/backlog.md` — ở đó task chỉ có một dòng, đọc một dòng rồi tự suy phần còn lại là cách bịa ra yêu cầu |
| Một **luật của quán** (giá, kênh, phụ thu, luồng) | `master_plan/shop-facts.md` | `master_plan/00-scope.md` là stub chuyển hướng, không sở hữu gì; các file `*_plan_*.md` và `to_do_list.md` là kế hoạch/ảnh chụp, không phải chủ của luật |
| **Hành vi sản phẩm** theo pha | `docs/product/00-index.md` để định tuyến, rồi đúng file nó chỉ | `docs/product.md` — bản lưu trước khi tách; nó không sở hữu gì và không ai trỏ vào nó |
| **Vì sao** một thiết kế được chọn | `docs/decisions.md` (ADR) | `architecture.md` nói *hiện trạng*, không nói *vì sao*; suy ngược lý do từ hiện trạng là bịa một ADR |
| Ràng buộc về **tiền / dữ liệu không được sai** | `quality/invariants.md` | bất cứ file nào nhắc lại con số ấy — nhắc lại là bản sao |
| Một **câu chưa có lời** | `docs/product/99-unknowns.md` | báo cáo cũ, prompt cũ, hay ADR trích lại câu ấy — Gate 1c tồn tại đúng vì lỗi này |
| Ai đó **đề xuất đổi** chính hệ thống này | `work/proposals/` — đọc như ý kiến | không bao giờ là dữ kiện; chỗ nào nó trái §2 thì **§2 thắng** |
| Việc phải làm trong task | `prompt/` | prompt mô tả *việc*, không sở hữu *dữ kiện nghiệp vụ*; số trong prompt vẫn phải đối chiếu owner |

Thêm một luật cứng đứng trên cả bảng trên: bốn dòng §2 ghi **chưa có owner**
(schema, quy ước code, hợp đồng API, route) nghĩa là *không có file nào* được đọc
để lấy những thứ ấy — chúng chưa tồn tại. Đi tìm context cho một câu hỏi thuộc pha
sau là bước đầu của việc bịa ra nó.

### 4.5 Trong một file lớn, tôi không đọc cả file

Chọn context không chỉ là chọn file, mà là chọn **khối** trong file.

- `grep -n` mã định danh hoặc tiêu đề trước (`U-0`, `F-0`, `ADR-0`, `I-0`,
  `### `), rồi đọc quanh chỗ khớp.
- Đọc theo **khối, không theo dòng**: tài liệu ở đây ngắt dòng giữa câu, nên một
  phép đọc theo dòng sẽ mù với từ khoá bị cắt qua hai dòng — đúng cái đã sinh ra
  `work/findings.md` F-015.
- `docs/product/00-index.md` là bảng định tuyến: nó không sở hữu dữ kiện nào, và
  đọc nó rẻ hơn mở ba file để xem file nào đúng.
- Đọc trọn một file chỉ khi tôi **sắp sửa** nó — sửa một đoạn mà không biết phần
  còn lại nói gì là cách tạo ra hai câu trái nhau trong cùng một file.

Một phản xạ nữa, rẻ và cứu nhiều lần: sau khi đọc một dữ kiện, tôi `grep -rn`
xem **những chỗ nào đang trỏ tới nó**. Cả ba họ lỗi nặng nhất của repo này đều
cùng một hình — *dữ kiện đổi ở một chỗ, bản sao ở chỗ khác không đổi theo*.

### 4.6 Khi nào tôi dừng đọc

Không phải khi hết file, mà khi viết ra được ba thứ:

1. từng dòng **Acceptance** của task;
2. **owner** mà mỗi dữ kiện mới sẽ về (§2), tên file cụ thể;
3. các **pattern** của `work/scope.txt`.

Thiếu một trong ba thì tôi thiếu context — nhưng thiếu **đúng cái đó**, và chính
nó chỉ ra file tiếp theo phải mở. Viết ra được cả ba mà vẫn muốn mở thêm file thì
đó là *đọc cho chắc*: dừng.

### 4.7 Dấu hiệu tôi đã lấy sai context

Nhìn ra sau khi đã sai, nhưng rẻ và đáng kiểm trước khi kết lượt:

- Tôi viết ra một dữ kiện mà **không chỉ được owner** của nó ⇒ tôi lấy nó từ một
  bản sao.
- Tôi gọi tên **bảng, cột, endpoint, route** trong một việc thuộc pha 1 ⇒ hoặc
  tôi đọc file của pha sau, hoặc tôi vừa bịa (Gate 1d bắt các hình phổ biến).
- Tôi trích một `U-XXX` **đã đóng** như còn mở ⇒ tôi đọc bản sao cũ thay vì
  `docs/product/99-unknowns.md` (Gate 1c bắt).
- Báo cáo của tôi **nhắc lại nội dung** thay vì trỏ vào dòng của owner ⇒ tôi vừa
  tạo bản sao thứ hai, đúng thứ `work/findings.md` F-001 nói tới.
---

## 5. Khai scope — trước lần sửa đầu tiên, không phải sau

Từ L1 trở lên, `work/scope.txt` phải được khai **trước** khi tôi sửa file đầu
tiên, và nội dung khớp mục *Scope* của prompt. Mỗi dòng một pattern:

```text
order/          mọi thứ dưới order/
docs/x.md       đúng file này
!order/db.go    cấm, kể cả khi dòng cho phép ở trên có khớp
```

Bỏ bước này thì Gate 3 in `scope not declared, skipping` — **gate xanh mà không
kiểm gì cả**, đây là dạng xanh giả nguy hiểm nhất trong repo. Cần ra ngoài scope
giữa chừng thì tôi sửa `work/scope.txt` và **nói ra**, không sửa lén.

Hai luật phụ mà tôi phải nhớ vì brief chỉ cảnh báo chứ không sửa hộ:

- **Bản đã commit của `work/scope.txt` chỉ được chứa comment.** Pattern là trạng
  thái của phiên đang chạy; nó không bao giờ được đi vào git.
- **Có thể có phiên khác đang chạy song song trên cùng cây.** Khi đó
  `work/scope.txt` là một file hai chủ: tôi **thêm** khối của mình vào cuối, chỉ
  gỡ khối nào ghi rõ đã commit. Ghi đè làm Gate 3 chấm việc của người kia bằng
  scope của tôi.

---

## 6. Làm — và quy tắc duy nhất không có ngoại lệ

Tôi sửa file trong scope, một task một lúc, xong hẳn rồi mới sang task khác.

Quy tắc không có ngoại lệ, không có mức L0: **không bao giờ bịa ra sự thật nghiệp
vụ.** Gặp chỗ nghiệp vụ chưa rõ thì dừng và hỏi bạn. Không hỏi được thì ghi lại
và **để hành vi đó chưa quyết** — tuyệt đối không để việc thực hiện âm thầm quyết
thay.

Đây là chỗ mấy chữ trong `CLAUDE.md` §7.2 làm việc nặng nhất:

- **Cái bạn nói ≠ cái tôi suy ra.** Khi câu trả lời của bạn ngắn hơn quyết định
  tôi cần, phần chênh là **suy luận của tôi** và nó đi vào mục *suy ra*, không
  bao giờ đi vào sổ ghi lời đã chốt.
- **"Đúng N cái" chỉ được viết khi N là một quyết định.** Bạn nói *"đúng năm kênh,
  không có kênh thứ sáu"* thì tôi được ghi là con số chốt. Còn phép đếm của
  chính tôi — *"lệch ở ba chỗ"* — thì phải ghi kèm ngày và để ngỏ khả năng có
  chỗ thứ tư.
- **Mọi dữ kiện mới mang ngày `YYYY-MM-DD` và tên người quyết.** Dữ kiện không
  ngày thì không bao giờ già đi được, nên nó được tin mãi mãi.

---

## 7. Ghi dữ kiện — finding, unknown, ADR đi đâu và viết thế nào

Ghi **ngay lúc phát hiện, trong cùng lần sửa, vào đúng nhà**, không bao giờ ghi
vào một ghi chú "để sau nộp". Thứ tôi học được mà không viết xuống sẽ chết cùng
phiên, và phiên sau suy lại nó sai.

| Loại | Nhà | Hình dạng |
|---|---|---|
| Câu hỏi nghiệp vụ chưa có lời | `docs/product/99-unknowns.md` | một gạch đầu dòng dưới `### Đang mở`: `U-XXX — câu hỏi, ai trả lời được, đang chặn cái gì` |
| Vấn đề lặp lại / bài học | `work/findings.md` | khuôn `F-XXX` trong chính file đó |
| Chọn giữa hai thiết kế đều chạy được | `docs/decisions.md` | khuôn `ADR-XXX` trong chính file đó |

### 7.1 Làm một finding ra sao

Finding **không phải nhật ký bug**. Một chỗ xấu xảy ra một lần không phải finding.
Thứ đáng ghi là: lỗi tái diễn, mâu thuẫn giữa hai tài liệu, invariant còn thiếu,
quy trình hỏng, bài học nhiều khả năng lặp lại.

Cách tôi quyết trong lúc chạy — ba câu:

1. **Chuyện này đã xảy ra lần thứ hai chưa?** Chưa thì thường chưa phải finding.
   (`CLAUDE.md` §3.8: chỉ thêm luật/hook/test sau khi cùng một vấn đề bắt bạn trả
   giá **hai lần**.)
2. **Phiên sau có vấp lại đúng chỗ này không nếu không ai ghi?** Có ⇒ ghi.
3. **Nó thuộc loại nào trong ba loại trên?** Câu hỏi cần chủ quán trả lời là
   *unknown*, không phải finding. Chọn giữa hai thiết kế là *ADR*, không phải
   finding.

Khuôn năm khối, viết đủ cả năm:

```markdown
### F-XXX — Tiêu đề ngắn

**Problem:**
Cái gì sai.

**Impact:**
Vì sao nó quan trọng.

**Decision / Fix:**
Cái gì nên đổi, hoặc đã đổi gì.

**Related task:**
T-XXX

**Status:**
Open
```

Một chi tiết nhỏ mà hỏng là finding **biến mất**: dòng ngay dưới `**Status:**`
phải đúng một chữ `Open` hoặc `Fixed`, không thêm gì. `Open — chưa siết cơ chế`
**không khớp** cái `scripts/brief.sh` đọc, nên finding đó còn mở mà không phiên
nào nhìn thấy nữa. Muốn nói thêm thì nói ở `**Decision / Fix:**`. Cùng một bài
học áp cho câu hỏi mở: viết thành đoạn văn thay vì gạch đầu dòng, hoặc để nhầm
dưới tiêu đề "đã đóng", là cách nhanh nhất để giấu một việc còn mở khỏi mọi phiên
sau. **Thứ brief đọc được là thứ có hình dạng cố định.**

Ghi xong một finding thì còn một việc nữa: cập nhật dòng của nó ở mục lục đầu
`work/findings.md` trong **cùng lần sửa** — nhà thật của trạng thái là dòng
`**Status:**`, mục lục chỉ là bản chụp, và bản chụp để trôi là đúng họ lỗi mà
finding đầu tiên của repo này nói về.

### 7.2 Thứ tôi **không** làm

Không tạo file `.md` mới mà không ai yêu cầu. Dữ kiện mới thuộc về một owner đã
có. Chỉ khi xuất hiện một **loại** dữ kiện thật sự mới thì bảng `CLAUDE.md` §2
mới mọc thêm một hàng — và hàng ấy phải sinh ra trong **cùng lần sửa** tạo ra
owner, vì một owner mà §2 không kể tên là owner không ai tìm thấy.

---

## 8. Gate chạy — bằng chứng duy nhất là output của lệnh

```bash
./scripts/gate.sh
```

Nó chạy sáu bước, theo đúng thứ tự này:

| # | Script | Nó bắt cái gì | Chạy khi nào |
|---|---|---|---|
| 1 | `scripts/check-scope.sh` (Gate 3) | thay đổi **đúng** nhưng chạm file task không được phép chạm | mọi lượt |
| 2 | `scripts/check-links.sh` (Gate 1b) | một tài liệu chỉ đường nêu đường dẫn không mở được | mọi lượt |
| 3 | `scripts/check-doc-status.sh` (Gate 1c) | **một mã, hai chỗ, hai trạng thái** — câu đã đóng còn bị nhắc như đang mở | mọi lượt |
| 4 | `scripts/check-phase-boundary.sh` (Gate 1d) | tài liệu pha 1 đặt tên thứ pha 2/3/4 sở hữu | khi `docs/product/1-system-design/` đổi |
| 5 | `scripts/verify.sh` (Gate 1) | format, build, test, và mọi `scripts/*.test.sh` | **bỏ qua** khi lượt chỉ đổi tài liệu |
| 6 | `scripts/check-commit-block.sh` (Gate 7) | lượt kết thúc mà chưa giao nội dung commit | chỉ ở chế độ hook, chỉ sau khi 1–5 xanh |

Vì sao bước 2, 3, 4 **không** được bỏ qua ở lượt chỉ đổi tài liệu, dù bước 5 thì
có: tài liệu chính là thứ repo này sản xuất. Lượt chỉ sửa `.md` từng là lượt duy
nhất không bị máy chấm gì cả — mà đó lại đúng là lượt **sinh ra** loại lỗi bước 3
bắt (đóng một câu hỏi thì chỉ sửa `.md` chứ có đụng code đâu). Một cổng đặt trong
`verify.sh` sẽ ngủ qua đúng lượt tạo ra lỗi nó được sinh ra để bắt.

Ba cổng 1b/1c/1d đều có file ignore riêng
(`scripts/check-links.ignore`, `scripts/check-doc-status.ignore`,
`scripts/check-phase-boundary.ignore`) và cả ba theo cùng một luật: ngoại lệ phải
ghi lý do, và **dòng ignore nào không còn khớp lỗi nào thì gate đỏ cho tới khi
gỡ**. Ngoại lệ có hạn, không được nằm lại làm nợ vô hình.

Hai chỗ gate cố ý **không** đỏ, và bạn nên biết vì nó chuyển việc sang mắt người:

- **File git chưa theo dõi nằm ngoài scope** chỉ được in thành một dòng `note:`.
  Git không biết file chưa track có từ bao giờ, nên nó có thể là bản nháp nằm sẵn
  từ trước task. Gate đỏ vì lý do sai dạy người ta bỏ qua gate — mất nhiều hơn
  được. Cái giá: file **mới do chính task tạo ra** ngoài scope giờ chỉ được ghi
  chú. Dòng `note:` vì thế phải **đọc**, đừng lướt.
- **Gate 1d cố ý bảo thủ**: nó bắt các hình vi phạm phổ biến (từ khoá SQL, động
  từ HTTP kèm `/api/`, thẻ giống JSX) và im lặng khi không chắc. Nó không bắt hết
  — mắt người vẫn là lớp cuối.

`gate.sh` còn được gắn làm hook `Stop` trong `.claude/settings.json`: nó chạy khi
tôi kết thúc một lượt, và **đỏ thì chặn lượt lại**, trả nguyên output về cho tôi
sửa. Nghĩa là tôi không có quyền tuyên bố "xong" — script tuyên bố.

Luật cuối, quan trọng hơn cả sáu bước: **"tôi đã test rồi" không phải bằng chứng.
Output của lệnh mới là bằng chứng.** Các cổng còn lại — ánh xạ acceptance sang
bằng chứng, săn red flag trong diff, review theo bậc, review bằng context lạnh —
nằm ở `quality/review-gate.md`.

---

## 9. Kết thúc lượt — bàn giao

Thứ chỉ đúng trong đầu tôi thì mất khi phiên đóng. Trước khi kết thúc:

1. **Task ở `work/backlog.md` phản ánh đúng thực tế** — chuyển sang *Done*, hoặc
   để nguyên *In Progress* kèm phần còn lại viết vào entry.
2. **`work/scope.txt` dọn sạch pattern** khi task xong; còn dở thì để nguyên và
   để nó đúng.
3. **Mọi luật, quyết định, invariant, câu hỏi tôi chạm phải đã nằm ở nhà của nó.**
4. **Khối commit dán chạy được**, cho mọi thứ chưa commit:

   ```bash
   # lấy danh sách từ git, đừng dựng lại từ trí nhớ:
   git diff --name-only HEAD

   git add CLAUDE.md work/backlog.md
   git commit -m "T-XXX: what changed" -m "Why it changed.
   Verified: ./scripts/gate.sh green."
   ```

   Liệt kê từng file, **không bao giờ** `git add -A` hay `git add .`. Đọc danh
   sách từ git chứ không từ trí nhớ: một phiên nhớ lại mình đã sửa gì sẽ thỉnh
   thoảng sót một file hoặc thêm một file không có thật; `git diff --name-only
   HEAD` thì không. Một task một khối. **Việc chưa commit của người khác thì
   không gộp vào** — gọi tên nó, nói rõ nó không nằm trong khối của tôi, và để
   lại cho người tạo ra nó.

5. **Báo cáo nói rõ cái gì còn dang dở**, bằng đúng những chữ mà phiên sau cần để
   cầm tiếp. Mỗi thứ còn mở được nhắc tên đều kèm **link tới đúng dòng nó được
   viết**, số dòng lấy bằng `grep -n` **trong chính lượt viết báo cáo** — số dòng
   trôi khi tài liệu lớn lên, số chép từ trí nhớ trỏ sai chỗ. Một câu *"U-022 vẫn
   mở"* bắt người đọc đi săn; mã số là mục lục, không phải câu trả lời.

Hai cổng đứng gác đoạn này:

- **Gate 7 / 7b** (`scripts/check-commit-block.sh`) chặn lượt nếu còn thay đổi
  đã track mà báo cáo không có khối `git commit`. Rồi nó hỏi câu thứ hai — *trong
  khối đó có gì* — và gọi tên: file nằm ngoài scope, `git add -A` / `git add .`,
  và `work/scope.txt` nếu nội dung sắp add còn mang pattern. Nó chấm **danh sách
  file tôi cố ý chọn**, không chấm cây làm việc. Nó nhắc **một lần cho mỗi trạng
  thái cây**, và thứ nó trả về là *chữ trong báo cáo* phải viết lại — không phải
  thay đổi, vì lúc đó thay đổi đã xanh rồi.
- **Gate 8** (`scripts/hooks/commit-msg`) là hook của **git**, không phải của
  Claude Code, nên nó đứng ở chỗ Gate 7 với tay không tới: người gõ `git commit`
  thẳng trong terminal. Luật hẹp một cách cố ý — bỏ tiền tố `T-XXX: `, phần còn
  lại phải có ≥ 2 từ và ≥ 8 ký tự. `Fix typo` qua; `adg` chết. Subject dài quá 72
  ký tự chỉ bị **nhắc**, không bị chặn — đỏ vì lý do sai thì người ta gỡ hook chứ
  không sửa message. Đường thoát in ngay trong lời từ chối: `git commit
  --no-verify`. Hook không đi theo bản clone, nên mỗi bản clone mới phải chạy
  `./scripts/install-hooks.sh` một lần; brief cảnh báo khi nó chưa được cài.

---

## 10. Cách tôi nhìn vấn đề — bốn thứ tôi giả định là mình sẽ sai

Toàn bộ kiến trúc trên chỉ là câu trả lời cho bốn kiểu sai. Hiểu bốn kiểu này thì
mọi luật ở trên tự giải thích chính nó.

**a) Tôi sẽ chép một dữ kiện sang chỗ thứ hai, rồi hai bản trôi khỏi nhau.**
Đây là họ lỗi đắt nhất của repo. Cùng một luật nằm ở tài liệu tra cứu, tài liệu
khung, file prompt và bản xuất khẩu; ai đó sửa một chỗ, ba chỗ còn lại thành lời
nói dối có thẩm quyền. Phòng thủ: một dữ kiện một chủ (§2), brief trỏ chứ không
chép, entry backlog trỏ còn prompt giữ, và `grep -rn` mọi pointer sau khi đổi một
dữ kiện. **Khi tôi định viết lại một câu đã có ở chỗ khác — đó là lúc phải dừng
và thay bằng một con trỏ.**

**b) Tôi sẽ sửa đúng cái bạn nhờ, và sửa kèm thêm bốn chỗ không ai nhờ.**
Scope drift là lỗi số một của LLM và nó **không** hiện ra trong test xanh: mọi
test vẫn xanh, diff vẫn đẹp, chỉ là có ba file không liên quan vừa bị "dọn dẹp".
Phòng thủ: khai scope trước lần sửa đầu tiên, Gate 3 chấm, Gate 7b chấm lại danh
sách file trong khối commit. Trong mục *Scope* của một prompt, phần **"không được
sửa"** có giá trị cao hơn phần "được sửa".

**c) Tôi sẽ điền vào chỗ trống bằng thứ nghe hợp lý.**
Tôi *biết* một schema quán ăn trông thế nào, *biết* phụ thu giao hàng thường tính
ra sao. Nên khi tài liệu im lặng, câu văn tôi viết ra sẽ trôi chảy và có vẻ đúng
— và nó trở thành dữ kiện vì không có chủ nào để đối chiếu. Phòng thủ: cấm bịa sự
thật nghiệp vụ (không có mức L0), bốn dòng *chưa có owner* trong §2, Gate 1d, và
ranh giới cứng giữa *lời bạn chốt* và *phần tôi suy ra*.

**d) Tôi sẽ tin là code của mình đúng vì tôi vừa viết nó.**
Phiên vừa viết xong có thiên kiến xác nhận rất nặng. Phòng thủ: bằng chứng phải
là output lệnh; mỗi dòng acceptance phải trỏ được tới thứ chứng minh nó; săn diff
theo **đúng danh sách red flag** ở `quality/review-gate.md` chứ không đọc kiểu
"xem có hợp lý không" (mắt sẽ trôi); và với việc quan trọng thì chấm lại bằng một
context lạnh.

Một nguyên tắc bao trùm cả bốn: **cổng nào đỏ vì lý do sai sẽ bị gỡ.** Vì thế
Gate 3 chỉ ghi chú file chưa track, Gate 1d im khi không chắc, Gate 8 chỉ nhắc
subject dài, và mọi hook đều có đường thoát in sẵn trong lời từ chối. Một cổng
nghiêm quá mức không bảo vệ được gì — nó chỉ dạy người ta đi vòng.

---

## 11. Một ví dụ chạy thật

> *"Thêm luật: đơn giao tận nơi dưới 50k thì tính phụ thu 10k."*

1. **Phân loại.** Chạm tiền ⇒ tối thiểu **L2**. Và nó là **dữ kiện nghiệp vụ**,
   không phải kỹ thuật.
2. **Câu hỏi đầu tiên không phải "sửa file nào" mà là "ai quyết con số này".**
   Nếu đây là lời chủ quán vừa chốt ⇒ nó là dữ kiện, ghi vào
   `master_plan/shop-facts.md` kèm ngày và người quyết. Nếu đây là bạn đang phác
   thảo ⇒ nó là **câu hỏi mở**, đi vào `docs/product/99-unknowns.md` chứ không
   được biến thành luật.
3. **Đọc context tối thiểu:** mục phụ thu ở `master_plan/shop-facts.md`, mục giá
   trong `docs/product/`, và `quality/invariants.md` xem có invariant nào về tiền
   bị đụng.
4. **Khai `work/scope.txt`** đúng những file trên, trước lần sửa đầu tiên.
5. **Kiểm tra ranh giới pha:** pha 2/3/4 chưa mở, nên tôi mô tả **luật**, không
   được đặt tên cột `surcharge_amount` hay endpoint nào. Gate 1d sẽ chặn nếu tôi
   quên.
6. **Ghi luật vào owner**, kèm ngày và ai quyết, rồi `grep -rn "phụ thu"` để sửa
   mọi chỗ đang trỏ tới luật cũ **trong cùng lần sửa**.
7. **L2 ⇒ invariant.** Nếu luật này đụng một invariant ở `quality/invariants.md`,
   nó cần regression test và tôi phải **tự chạy** test đó.
8. **Chạy `./scripts/gate.sh`**, dán output thật vào báo cáo.
9. **Bàn giao:** task sang *Done*, `work/scope.txt` dọn sạch, khối commit dán
   được, và báo cáo nói rõ cái gì còn mở kèm link tới đúng dòng.

Chỗ dễ hỏng nhất trong ví dụ này là **bước 2**, và nó nằm hoàn toàn ngoài tầm
với của mọi script.

Ví dụ trên là ví dụ **dựng**. Một ca **có thật**, mổ từ brief tới khối commit — kể
cả chỗ nó kết thúc bằng một ô cổng **không tick được** — ở
[`vi-du-mot-task-chay-that-P1-12.md`](vi-du-mot-task-chay-that-P1-12.md).

---

## 12. Chỗ hệ thống không đỡ được bạn

Nhìn lại cột *Enforced by* trong `CLAUDE.md` §3: có script đứng sau là gate chạy,
chỉ ghi *self-discipline* là **không có gì bắt được**. Danh sách những chỗ đó,
nói thẳng:

| Nghĩa vụ | Ai bắt | Hỏng thì ra sao |
|---|---|---|
| Có entry trong `work/backlog.md` | không ai | việc xong rồi nhưng phiên sau không biết nó đã xong |
| Viết acceptance **trước** khi sửa | không ai | không có cách nào chấm kết quả, kể cả bạn |
| Viết ADR khi đã chọn một thiết kế | không ai | ba tháng sau không ai biết vì sao chọn thế, và có người lật lại |
| Duyệt thiết kế trước khi viết code (L3) | không ai | sai kiến trúc chỉ lộ ra khi đã có code dựa vào nó |
| Đọc dòng `note:` của Gate 3 | không ai | file mới do task tạo ra ngoài scope đi lọt |
| Đọc tiếp danh sách khi brief in `→ ĐÃ CẮT` | không ai | quyết định dựa trên một danh sách bị cắt |

Và ba thứ **chỉ bạn** làm được, không phải tôi:

- **Trả lời câu hỏi nghiệp vụ.** Mọi `U-XXX` đang mở đều đứng đó chờ bạn; không
  script nào đóng được chúng, và tôi thì bị cấm tự đoán.
- **Chạy `git commit`.** Tôi viết khối, bạn quyết. Commit là quyết định của người
  dùng, và một commit do máy soạn sẽ có đúng chất lượng của `adg`.
- **Nói tôi sai.** Gate chấm hình dạng — nó biết đường dẫn có mở được không,
  không biết nó có trỏ **đúng chỗ** không.

---

## Đọc tiếp

| Muốn biết | Đọc |
|---|---|
| Luật thật của hệ thống này | `CLAUDE.md` |
| Bốn bậc rủi ro, triết lý repo | `README.md` |
| Cách viết một prompt cho từng bậc | `docs/prompt-guideline.md` |
| Cách chấm kết quả sau khi tôi chạy xong | `quality/review-gate.md` |
| Một task có thật, mổ từng bước | [`vi-du-mot-task-chay-that-P1-12.md`](vi-du-mot-task-chay-that-P1-12.md) |
| Mười bước thủ tục của một task L1 | `work/backlog.md` → *Vòng chạy một task L1* |
| Vì sao mỗi cổng tồn tại | comment ở đầu chính script đó trong `scripts/` |
| Dữ kiện của quán | `master_plan/shop-facts.md` |
