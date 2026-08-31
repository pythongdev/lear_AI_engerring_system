# Findings

Only record findings with future value.

Good findings:
- recurring bugs
- architectural problems
- contradictions
- missing invariants
- process failures
- lessons likely to recur

Do not create findings for trivial imperfections.

## Template

### F-XXX — Short title

**Problem:**  
What is wrong.

**Impact:**  
Why it matters.

**Decision / Fix:**  
What should change or what changed.

**Related task:**  
T-XXX

**Status:**  
Open / Fixed

---

### F-001 — Bảng giá nay có hai bản: `00-scope.md` và `master_plan/shop-facts.md`

**Problem:**
`master_plan/shop-facts.md` trước đây cố ý không chứa con số nào, chỉ trỏ về `00-scope.md` — nhà
duy nhất của phạm vi bán và giá theo CLAUDE.md §2. Ngày 2026-08-30 owner yêu cầu shop-facts.md
phải **tự đứng độc lập, không tham chiếu tới đâu**, làm bản giới thiệu quán cho người ngoài repo.
Yêu cầu đó buộc phải chép toàn bộ bảng giá thành phần, giá suất bán, phụ thu và thành phần suất
bán vào shop-facts.md. Từ nay mỗi con số giá sống ở **hai** chỗ.

**Impact:**
Đổi giá ở `00-scope.md` mà quên `shop-facts.md` (hoặc ngược lại) ⇒ hai tài liệu nói hai giá khác
nhau, và không ai biết chỗ nào đang được dùng để thu tiền. Đây đúng là kiểu trôi mà header cũ của
shop-facts.md đã cảnh báo trước.

**Decision / Fix:**
Owner đã cân nhắc và chọn độc lập > không trùng bản (quyết định 2026-08-30, sau khi được nêu rõ
đánh đổi). Giảm nhẹ: `shop-facts.md` mở đầu bằng một khối cảnh báo bảo trì bắt buộc sửa cả hai chỗ
trong cùng một lần. `00-scope.md` vẫn là nhà thật theo CLAUDE.md §2 — lệch nhau thì `00-scope.md`
thắng. Nếu tái phát lệch giá dù đã có cảnh báo, cân nhắc một script so khớp hai bảng.

**Related task:**
—

**Status:**
Fixed

**ĐÓNG 2026-08-30 — bản trùng đã bị xoá, không còn hai bản nào.** Xem ADR-001: `shop-facts.md`
nay là nhà duy nhất, `00-scope.md` rút thành file trỏ không giữ số. Khuyến nghị "viết script so
khớp hai bảng giá" ở dưới **không còn cần** — không còn hai bảng để so.

**Vì sao phải đóng bằng cách đổi kiến trúc chứ không phải bằng kỷ luật:**
Chủ quán chốt giá suất trứng (20.000 / 25.000 / 30.000). Con số được ghi vào `shop-facts.md`
trước, và trong khoảng thời gian đó `00-scope.md` — **nhà thật của giá** — vẫn ghi ô đó là
"⚠ chưa chốt". Hai file mâu thuẫn nhau về một con số tiền chỉ **một ngày** sau khi bản trùng được
tạo ra. Cảnh báo bảo trì viết ở đầu `shop-facts.md` cùng ngày **không cứu được gì**.

Bài học: một bản chép có kèm cảnh báo vẫn là một bản chép. Cảnh báo dựa vào việc người sửa nhớ đọc
nó; nhà-duy-nhất không dựa vào ai nhớ gì. Khi yêu cầu "file phải đọc độc lập" xung đột với luật
"một fact một nhà", **đừng giải bằng cách chép rồi hứa sẽ đồng bộ** — hãy đổi xem ai là nhà.

---

### F-002 — Ba ca giá 5–7 từng bị ghi nhầm là "đã đối chiếu khớp"

**Problem:**
Bản cũ `shop-facts.md` §4.4 ghi *"Chín ca đầu tính được đã đối chiếu khớp bảng giá"* trong danh
sách 11 tổ hợp giá, và thêm dòng *"Ca 12 phải thêm khi GD-01 được gỡ: một suất trứng đứng riêng"*.
Cả hai đều sai: ca 5, 6, 7 (`Trứng chín/tái/vàng`) **chính là** suất trứng đứng riêng — thứ mà
GD-01 nói là chưa chốt giá. Chúng không tính ra được, và không cần thêm ca 12.

**Impact:**
Một người đọc bản cũ sẽ tưởng chỉ còn một ô trống ở đâu đó ngoài danh sách test, trong khi thực tế
**ba trong mười một ca test giá không có giá kỳ vọng**. Viết test theo bản cũ ⇒ hoặc tự bịa giá cho
ba ca, hoặc test xanh mà không kiểm gì.

**Decision / Fix:**
Đã sửa khi viết lại `shop-facts.md` (2026-08-30): ca 5–7 nay đánh ⚠ chưa chốt và trỏ thẳng vào câu
hỏi giá suất trứng; dòng "ca 12" đã gỡ. Bài học: khi một ô giá còn trống, phải rà **mọi** ca test
dùng ô đó, không chỉ ghi một dòng ghi chú ở cuối bảng.

**Related task:**
—

**Status:**
Fixed

---

### F-003 — Đếm "đúng N" trong tài liệu: có khi là quyết định, có khi là bẫy

**Problem:**
`master_plan/shop-facts.md` §5 từng viết *"Luồng ship và pickup khác luồng trên **đúng ba điểm**"*.
Câu đó khẳng định đã liệt kê đủ, nhưng thực tế thiếu ít nhất bốn điểm — trong đó có hai điểm chạm
tiền (thu tiền lúc nào, ai đi giao) và một điểm chạm bếp (đơn mang đi có nước chấm không). Cùng chỗ
đó, kênh `phone_preorder` — kênh chủ quán mới chốt 2026-08-29 — chỉ xuất hiện ở §2 rồi biến mất,
không luồng nào mô tả nó, dù nó không thuộc luồng tại bàn.

**Impact:**
Một con số đếm mang tính khẳng định đầy đủ **chặn câu hỏi tiếp theo**. Session đọc "đúng ba điểm"
sẽ tin là đã hết và tự đoán phần còn thiếu, thay vì dừng lại hỏi chủ quán. Nguy hiểm hơn hẳn một
danh sách nói thẳng là chưa đủ. Kênh mới nhất lại là kênh không có mô tả luồng nghĩa là phần rủi ro
cao nhất được che đúng bằng cơ chế này.

**Decision / Fix:**
Phân biệt hai loại đếm, và chỉ loại đầu được viết là "đúng N":
- **Đếm là QUYẾT ĐỊNH của chủ quán** — "đúng năm kênh bán, không có kênh thứ sáu" (§2). Viết "đúng
  N" là chuẩn: thêm cái thứ N+1 là đổi phạm vi, phải xin phép.
- **Đếm là TÓM TẮT của người viết tài liệu** — "khác nhau ở N điểm", "N quy tắc". Không được viết
  "đúng N". Phải kèm mốc thời gian và lời mời bổ sung.

Đã sửa 2026-08-30: §5.2 nay ghi *"Khác luồng tại bàn ở bảy điểm. Đây là danh sách đã biết tính tới
2026-08-30, không phải lời hứa là đã đủ — gặp điểm khác thứ tám thì ghi thêm vào đây, đừng tự
đoán."* `phone_preorder` nay có sơ đồ luồng riêng ở §5.2.

Kiểm tra kèm theo: mỗi khi §2 thêm hoặc sửa một kênh, rà xem kênh đó đã xuất hiện trong **một** luồng
ở §5 chưa. Kênh chỉ có trong bảng §2 mà không có trong luồng nào là bug.

**Related task:**
—

**Status:**
Fixed

---

### F-004 — Suy ra từ luật đã chốt thì phải ghi tách khỏi lời chủ quán

**Problem:**
Ngày 2026-08-30 chủ quán trả lời năm câu về luồng mang đi và ba câu còn treo. Nhiều câu trả lời là
câu nói ngắn ("thu tiền lúc giao hàng", "case by case", "cộng gộp tiền bánh"), từ đó phải **suy ra**
chi tiết mới dùng được: phụ thu suất trứng là ×5 hay ×4, trường liên hệ nào bắt buộc, hoàn tiền có
phải ghi vết không. Nếu trộn phần suy ra vào cùng chỗ với phần chủ quán nói thẳng, phiên sau không
phân biệt được cái nào đã được xác nhận và cái nào chỉ là suy luận hợp lý.

**Impact:**
Riêng chỗ phụ thu suất trứng, hai cách suy lệch nhau **1.000–2.000đ mỗi suất**. Một suy luận sai
được ghi lẫn vào các dòng "owner chốt" sẽ không bao giờ bị ai hỏi lại, vì trông y hệt một quyết định
đã xác nhận.

**Decision / Fix:**
Tách hai loại ra hai mục riêng và nói rõ mục nào lật trước:
- `master_plan/shop-facts.md` §7.1 = **nhật ký chốt** (ngày + ai chốt cái gì).
- `master_plan/shop-facts.md` §7.2 = **ba chỗ suy ra** (S-1 phụ thu ×5 · S-2 trường liên hệ bắt
  buộc · S-3 hoàn tiền phải ghi vết), mỗi mục kèm suy từ đâu và sai thì mất gì.
- ~~`master_plan/00-scope.md` §6 giữ một đoạn tương ứng~~ — file đó đã rút thành file trỏ
  (ADR-001, 2026-08-30); S-1 nay chỉ sống ở `shop-facts.md` §7.2, đúng một chỗ.
- Mỗi chỗ suy ra chạm tiền phải kèm sẵn **một câu hỏi kiểm chứng** dạng có/không để lần gặp chủ
  quán sau hỏi được ngay: *"Suất trứng nhân thường là 25.000 hay 24.000?"*

Luật chung: khi câu trả lời của chủ quán ngắn hơn quyết định cần có, phần chênh lệch là **suy luận**
và phải ghi ở mục suy luận, không được ghi lẫn vào nhật ký chốt.

**Related task:**
—

**Status:**
Fixed

---

### F-005 — Đổi một con số ở `shop-facts.md` thì phải grep cả tài liệu **khung**, không chỉ tài liệu tra cứu

**Problem:**
Chủ quán chốt kênh thứ năm (`phone_preorder`) ngày **2026-08-24**, sửa tên ngày **2026-08-29**.
`master_plan/shop-facts.md` §2 và `docs/product.md` §2 — hai chỗ người ta *tra cứu* danh sách kênh —
được cập nhật ngay. Nhưng `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`, tài liệu **khung** của
cả giai đoạn BA, vẫn nói bốn ở **bốn** chỗ tới tận **2026-08-30**: §2.2 (liệt kê 4 kênh), §9 (phạm vi
MVP), §11 dòng BA-02 (tên việc phải làm), §12 (cổng chất lượng). Lệch **sáu ngày** mà không ai thấy.
Ba chỗ đầu được T-007 nêu tên; chỗ thứ tư (§9) chỉ lộ ra khi grep, tức bản thân lần rà soát ban đầu
cũng sót.

**Impact:**
Nặng hơn một dòng tài liệu cũ, vì §12 là **cổng chất lượng của cả giai đoạn BA** và BA-11
(`prompt/BA/10-acceptance-scenarios-L2.md`) tick theo đúng danh sách đó. Tick "đủ 4 kênh" là **đóng
giai đoạn BA trong lúc một kênh thật chưa hề được nghiệm thu**, rồi bước sang System Design với mô
hình bán hàng thiếu một kênh. §11 thì giao cho BA-02 sai việc phải làm, còn §9 cắt kênh thứ năm khỏi
phạm vi MVP. Tài liệu khung không bị ai tra cứu hằng ngày nên không ai phát hiện nó sai — chính vì
vậy nó sai lâu nhất.

**Decision / Fix:**
Đã sửa cả bốn chỗ 2026-08-30 (T-007) và để lại một dòng ghi chú có ngày ngay tại §12. Luật rút ra,
**tổng quát hơn F-003**: F-003 nói *cách viết* một con số đếm (đếm nào được phép ghi "đúng N"), luật
này nói *phải đi tìm ở đâu* khi con số đó đổi.

Khi một dữ kiện ở `master_plan/shop-facts.md` đổi — số kênh, số trạm, số quy tắc, số suất bán — trong
**cùng lần sửa đó** phải `grep -rn` cả repo cho con số ấy, kể cả bằng chữ (`bốn`/`4`, `năm`/`5`), và
rà đủ **ba loại file**, không chỉ loại đầu:

1. tài liệu **tra cứu** (`docs/product.md`) — loại luôn được nhớ;
2. tài liệu **khung** (kế hoạch gốc, master task, cổng chất lượng) — loại bị quên, và là loại quyết
   định khi nào một giai đoạn được coi là xong;
3. **prompt** (`prompt/**`) — thứ phiên sau đọc rồi làm theo.

Ưu tiên chữa tận gốc thay vì chữa từng chỗ: chỗ nào cần danh sách thì **trỏ** về nhà thật, đừng chép
(ADR-001, F-001). §2.2 kế hoạch gốc nay là một câu trỏ, nên lần đổi kênh sau nó không thể lệch nữa;
chỉ những chỗ buộc phải nêu con số (§9, §11, §12) mới còn phải grep.

**Related task:**
T-007

**Status:**
Fixed

---

### F-006 — Rà theo **con số** không tìm được chỗ lệch không chứa con số nào

**Problem:**
Kênh `phone_preorder` (chủ quán chốt 2026-08-24, sửa tên 2026-08-29, luồng chốt 2026-08-30) có mặt
trong `master_plan/shop-facts.md` §2 và §5.2 — nhà thật gộp nó cùng `delivery` và `pickup` thành
**một** luồng mang đi. Tài liệu khung `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` thì không
cho nó thuộc lát cắt nào, ở **sáu** chỗ: §3 Epic B ("Một đơn ship/pickup"), §4.2 (tiêu đề
"Ship / Pickup", bước 8–9 chỉ kết thúc cho `pickup` và `delivery`), §5 quy tắc 8, §6 mục Thanh toán,
§11 dòng BA-04, §12 scenario nghiệm thu thứ hai.

Đây là **lần thứ ba** khung lệch nhà thật ở cùng một kênh (F-003, F-005). Hai lần trước đã để lại
luật rà, và cả hai đều **không thể** bắt được lần này:

- **F-003** dạy cách *viết* một con số đếm, và để lại một kiểm tra đúng hướng — *"mỗi khi §2 thêm
  hoặc sửa một kênh, rà xem kênh đó đã xuất hiện trong một luồng ở §5 chưa"*. Nhưng "§5" ở đó là
  §5 **của `shop-facts.md`**. Kiểm tra chỉ chạy trong phạm vi một file, nên nó xanh: §5.2 đã có
  `phone_preorder` thật.
- **F-005** dạy *phải grep ở đâu* khi một dữ kiện đổi: grep con số đã đổi, cả chữ lẫn số
  (`bốn`/`4`, `năm`/`5`), qua ba loại file. Chạy đúng luật này vẫn ra rỗng ở cả sáu chỗ trên —
  **không chỗ nào chứa một con số**. Chúng viết "ship/pickup", "Pickup:", "Delivery:". Grep theo
  con số không thể tìm ra một chỗ chưa bao giờ nhắc tới con số.

**Impact:**
Chỗ lệch sống sót qua đúng hai lần rà soát được thiết kế để bắt nó, và sống ở tài liệu quyết định
khi nào giai đoạn BA được coi là xong. §12 scenario 2 nghiệm thu luồng mang đi bằng hai kênh: diễn
lại được scenario đó rồi tick, là đóng giai đoạn BA trong lúc một phần ba lát cắt chưa ai kiểm.
§11 giao BA-04 thiếu việc; §5 quy tắc 8 và §6 Thanh toán để ngỏ câu hỏi `phone_preorder` có dùng
phiên bàn không, tức chạm thẳng vào cách tính tiền. Riêng lần này prompt `prompt/BA/03-slice-ship-pickup-L2.md`
đã phủ đủ ba kênh nên hậu quả bị chặn lại; đó là may, không phải luật.

**Decision / Fix:**
Đã sửa cả sáu chỗ 2026-08-30 (T-011) và ghi vào khối ghi chú sẵn có ở cuối §12 — vẫn một khối.
Luật rút ra, **thay thế mức phủ của F-003 và F-005 chứ không mâu thuẫn với chúng**:

Một chỗ lệch có thể **không chứa dữ kiện đã đổi**. Nó lệch bằng chỗ **thiếu**, và chỗ thiếu thì
không grep được. Nên khi `shop-facts.md` §2 thêm hoặc sửa một thực thể được đếm (kênh, trạm, suất
bán), lần rà không dừng ở việc grep con số, mà phải grep **định danh** của thực thể đó
(`phone_preorder`, không phải `năm`) trên toàn repo, rồi trả lời hai câu **theo tên**, không theo số:

1. Thực thể này thuộc **luồng** nào? (`shop-facts.md` §5 — phạm vi F-003.)
2. Thực thể này thuộc **lát cắt / task / dòng nghiệm thu** nào của tài liệu khung? Nếu một tài liệu
   khung mô tả cùng một luồng bằng cách **liệt kê thành viên** (`"ship/pickup"`, `"Pickup:"`,
   `"Delivery:"`) thay vì gọi tên luồng, mỗi chỗ liệt kê là một chỗ phải sửa — kể cả khi nó không
   có con số nào.

Chữa tận gốc, cùng hướng với ADR-001 và F-005: tài liệu khung **gọi tên luồng** ("đơn mang đi") và
trỏ về `shop-facts.md` §5.2 cho danh sách thành viên, thay vì tự liệt kê kênh. Chỗ nào buộc phải
liệt kê thì liệt kê đủ cả ba định danh, để lần sau grep theo tên bắt được nó.

**Lần rà thứ ba — `prompt/**`, 2026-08-30 (T-012).** Loại file thứ ba của F-005 lệch ở đúng bốn
chỗ mà bảng *Context* của `prompt/maintenance/05-ba-prompts-three-channels-L1.md` đã kể
(`10-acceptance-scenarios-L2.md`, `05-pricing-payment-L2.md`, `03-slice-ship-pickup-L2.md`,
`prompt/BA/README.md`) — **và một chỗ nữa bảng đó không kể**:
`prompt/BA/01-actors-channels-L1.md` viết *"chỉ delivery và pickup mới bắt buộc số điện thoại"*,
trong khi `shop-facts.md` §6.5 bắt buộc số điện thoại cho **cả ba** kênh không gắn bàn.

Chỗ này bổ sung một dạng lệch cho luật trên: nó **không** mô tả luồng, nó liệt kê thành viên
trong một câu nói về **một trường dữ liệu bắt buộc** — tức chạm vào cái mà quán cần để giao được
hàng. Nên câu hỏi thứ hai của luật rà mở rộng thêm một vế: mỗi chỗ liệt kê thành viên phải hỏi
*"quy tắc này áp cho cả luồng hay chỉ cho vài kênh?"* — nếu áp cho cả luồng thì gọi tên luồng,
nếu chỉ áp cho vài kênh thì nói rõ vì sao. Nó cũng chốt cách rà đúng: grep định danh
(`phone_preorder`) rồi đọc **những file không có kết quả** — chỗ thiếu nằm ở đó, không nằm
trong kết quả grep.

**Lần rà thứ tư — tài liệu tra cứu, 2026-08-30 (T-020).** Cùng một câu sai còn một bản nữa ở
`docs/product.md` → *Unknowns*: *"chỉ Delivery và Pickup bắt buộc số điện thoại"*. Nó nằm ở
**loại file thứ nhất** của F-005 — loại "luôn được nhớ" — nên ba lần rà trước đều đi qua mà
không thấy, vì cả ba đều tìm ở chỗ *hay quên*. Bài học hẹp và cụ thể: chỗ lệch nằm trong một
dòng **nhật ký câu hỏi đã đóng**, thứ ai cũng đọc lướt vì tưởng đã xong. Khi rà theo định danh,
**các mục "đã có lời giải" phải được đọc như nội dung sống**, không phải như lưu trữ —
chúng chính là chỗ một câu trả lời cũ nằm lại sau khi dữ kiện đã đi tiếp.

**Related task:**
T-011, T-012 (lần rà thứ ba), T-020 (lần rà thứ tư)

**Status:**
Fixed

---

### F-009 — Hai cổng cố ý ngoảnh mặt khỏi file chưa track, và `git add -A` chuyên đi nhặt đúng chỗ đó

**Problem:**
Ngày **2026-08-30**, commit `0b3a337` mang subject *"T-020: đơn mang đi được trả trước, §6.3 hết
câu tuyệt đối"* nhưng nội dung là **1096 dòng của ba file `docs/` chưa track**
(`updatee_sýstem.md`, `đánh_giá_file_decisions.md`, `đánh_giá_file_product.md`) — **không một dòng
nào của T-020**. T-020 thật là `1b1d5f5`, sáu file, đã đúng. Phiên làm T-020 đã nói rõ trong báo
cáo rằng ba file kia *"không phải của tôi, không nằm trong khối commit"*, và khối commit được giao
liệt kê đích danh sáu file.

Đây là lần thứ **tư** của cùng một họ lỗi — commit nuốt thứ mà task không được phép chạm:

| # | Commit | Nuốt cái gì | Task khai scope thế nào |
|---|---|---|---|
| 1 | `5c41f65` | `work/scope.txt` còn 6 pattern | §6 cấm commit `work/scope.txt` |
| 2 | `25f0f88` | `work/scope.txt` còn 8 pattern | như trên |
| 3 | `128955a` (T-013) | `prompt/maintenance/10-prepay-takeaway-L2.md`, +133 dòng | scope ghi thẳng *"Không được sửa: `prompt/**`"* |
| 4 | `0b3a337` (mang tên T-020) | ba file `docs/`, +1096 dòng | khối commit được giao liệt kê sáu file, không có file nào trong đó |

Ba lần đầu từng được đọc là chuyện quên dọn (T-016). Lần thứ tư cho thấy cơ chế thật, và nó không
phải chuyện trí nhớ — **hai cổng đang cố ý không nhìn vào đúng tập file mà `git add -A` nhặt**:

- **Gate 3** (`check-scope.sh`) chỉ chặn file **git đang theo dõi**; file chưa track chỉ in
  `note:` — đây là **quyết định**, ADR-003, và là quyết định đúng: git không phân biệt được file
  chưa track do task này tạo ra hay đã nằm đó từ trước.
- **Gate 7** (`check-commit-block.sh`) bỏ qua dòng `??` ngay từ đầu, cũng viện đúng ADR-003, và nó
  chỉ hỏi *"turn này có giao khối commit không"* — **không bao giờ hỏi trong khối đó có gì**.

⇒ File chưa track là **giao điểm mù của cả hai cổng**. `git add -A` và `git add .` thì ngược lại:
chúng nhặt chính xác tập đó. Luật cấm chúng có tồn tại — CLAUDE.md §6.1 *"List the files, one by
one. Never `git add -A`, never `.`"* — nhưng luật đó **không có cơ chế nào đứng sau**, đúng loại
hỏng F-001 mô tả.

**Impact:**
Nặng nhất không phải 1096 dòng thừa, mà là **commit message nói sai về chính nó**, ở đúng nơi hệ
thống dùng làm tín hiệu trạng thái. `brief.sh` in RECENT COMMITS cho mọi phiên mới (ADR-002), nên
phiên sau đọc log thấy **hai** commit cùng tên "T-020" và tin cả hai là việc của T-020. Kéo theo:

- **`git revert` mất an toàn.** Hai subject giống hệt nhau; revert nhầm cái thì hoặc không gỡ được
  gì, hoặc xoá âm thầm 1096 dòng của người khác.
- **Ba file kia nay đã được track**, nên chúng không còn là ghi chú vãng lai. Trong đó
  `docs/updatee_sýstem.md` (1010 dòng — nay ở `work/proposals/updatee_sýstem.md`, T-023 2026-08-31)
  mô tả một **cấu trúc sở hữu khác** với CLAUDE.md §2
  (`docs/facts/business-rules.md`… trong khi §2 nói `master_plan/shop-facts.md` là nhà duy nhất).
  §2 nói hai chỗ mâu thuẫn thì chỗ kia *"là bug phải sửa ngay"* — bug đó vừa được commit vào repo.
- Lần 3 còn cho thấy phạm vi sát thương chéo giữa các phiên: ghi chú `note:` của Gate 3 in ra cho
  **phiên đang mở**, còn `git add` lại xảy ra ở **phiên khác**. Cảnh báo được đưa cho đúng người sai.

**Decision / Fix:**
Chưa sửa cơ chế. CLAUDE.md §3.8 chỉ cho dựng cơ chế sau khi cùng một vấn đề trả giá hai lần —
ngưỡng đã vượt gấp đôi, nên lần này **được phép**, nhưng đi kèm hai ràng buộc để không đập vỡ
ADR-003:

1. **Không lật ADR-003.** Gate 3 vẫn không được chặn vì một file chưa track — lý do của ADR-003
   còn nguyên giá trị.
2. Chỗ kiểm đúng là **tập file đã `git add`**, không phải cây làm việc: tại thời điểm đó câu hỏi
   *"file này có thuộc scope không"* mới trả lời được, vì người ta vừa cố ý chọn nó. Kiểm này thuộc
   Gate 7 (nơi đã đọc khối commit) và **cảnh báo, không chặn**.

Việc sửa **gấp vào T-016** thay vì mở task mới — T-016 đã là L2, đã sửa đúng script family đó, và
mở task riêng cho cùng một lần sửa là thứ §3.8 gọi là ceremony.

Riêng hậu quả đã commit của lần thứ tư — hai commit trùng tên và ba file `docs/` nay đã track,
trong đó một file mâu thuẫn §2 — là việc **T-023**, vì nó cần chủ repo quyết (sửa lịch sử hay để
nguyên; giữ, chuyển hay xoá ba file đó).

**Cơ chế đã dựng 2026-08-31 (T-016) — Gate 7b.** `scripts/check-commit-block.sh` nay hỏi thêm câu
thứ hai: **trong khối commit có gì**. Nó đọc các dòng `git add …` của khối (cộng index thật khi
index không rỗng) và nêu đích danh ba thứ — file **ngoài scope** đã khai, dạng `git add -A` /
`git add .` mà §6.1 cấm, và `work/scope.txt` nằm trong khối. Việc so khớp pattern gọi sang
`scripts/check-scope.sh --match`, nên ngữ nghĩa scope vẫn chỉ có **một** chủ. Ca kiểm A1–A8 trong
`scripts/check-commit-block.test.sh`.

**Hai ràng buộc của finding này: một được giữ nguyên, một bị đi chệch có chủ ý.**
*Giữ nguyên —* ADR-003 không bị lật: Gate 3 không đổi một dòng, và Gate 7b chấm **danh sách file
vừa được cố ý chọn**, không chấm cây làm việc, nên trạng thái track không tham gia vào kết luận
(ca A8: file chưa track nằm trong scope thì vẫn im).
*Đi chệch —* finding này viết *"cảnh báo, không chặn"*. Gate 7b dùng **exit 2**, đúng mã thoát
Gate 7 đã dùng sẵn khi thiếu khối commit. Lý do: hook `Stop` exit 0 không có kênh nào quay về
phiên, nên "cảnh báo" ở chỗ đó nghĩa là in vào hư không. Thứ bị trả lại là **đoạn văn bản bàn
giao**, không phải thay đổi (Gate 1, 1b, 3 đã xanh trước khi nó chạy), và nó nhắc nhiều nhất một
lần cho mỗi trạng thái cây. Lập luận đầy đủ ở **docs/decisions.md ADR-006**.

**Hậu quả đã commit — đóng 2026-08-31 (T-023), theo ba quyết định của chủ repo.**

*Bản đồ hash → nội dung thật.* Hai commit mang cùng subject *"T-020: đơn mang đi được trả trước,
§6.3 hết câu tuyệt đối"*. Lịch sử **không** bị viết lại (cả hai đã nằm trên
`origin/merge_first_time`; luật ở **docs/decisions.md ADR-008**), nên bảng này là thứ duy nhất
phân biệt được chúng. Đọc nó trước khi `git revert` bất cứ cái nào:

| Hash | Subject ghi trong log | Nội dung **thật** | Revert cái này thì mất gì |
|---|---|---|---|
| `1b1d5f5` | T-020: đơn mang đi được trả trước… | **Đúng là T-020.** 6 file, +331/−29: `docs/product.md`, `master_plan/shop-facts.md`, `prompt/BA/03-slice-ship-pickup-L2.md`, `prompt/maintenance/10-prepay-takeaway-L2.md`, `work/backlog.md`, `work/findings.md` | Mất chính T-020: §6.3 lại nói "không bao giờ thu trước", U-005 biến mất |
| `0b3a337` | T-020: đơn mang đi được trả trước… *(sai)* | **Không một dòng nào của T-020.** 3 file `docs/` chưa track, +1096/−0: `updatee_sýstem.md`, `đánh_giá_file_decisions.md`, `đánh_giá_file_product.md` | Không gỡ được gì của T-020; và sẽ xoá ngược ba file kia — hai file trong đó chủ repo đã quyết **giữ** |

*Ba quyết định của chủ repo, 2026-08-31 (T-023):*

1. **Lịch sử: sửa tiến, không viết lại.** `0b3a337` đã push; rewrite + force-push bị loại. Bản đồ
   trên, cộng ADR-008, là cách log ngừng nói dối mà không đụng vào lịch sử đã chia sẻ.
2. **`docs/đánh_giá_file_product.md` và `docs/đánh_giá_file_decisions.md`: giữ nguyên tại chỗ.**
   Chúng không sở hữu fact nào nên không mâu thuẫn CLAUDE.md §2; giữ là quyết định của chủ repo,
   không phải thiếu sót.
3. **`updatee_sýstem.md`: chuyển nguyên văn sang `work/proposals/updatee_sýstem.md`.** Đây là chỗ
   duy nhất trong ba việc thật sự chạm §2: file mô tả `docs/facts/…` và `work/tasks/…` làm nhà của
   fact và của task, trái với `master_plan/shop-facts.md` (ADR-001) và `work/backlog.md`. Nay nó ra
   khỏi `docs/`, mở đầu bằng banner ghi ngày, ghi rõ **chưa áp dụng**, và ghi đích danh hai chỗ trái
   §2. Thân bài không sửa một dòng (diff của lần chuyển: +26/−0, toàn bộ là banner). CLAUDE.md §2 có
   thêm một dòng owner cho `work/proposals/` — owner mà §2 không liệt kê là owner không ai tìm ra.

**Related task:**
T-016 (đã dựng Gate 7b, 2026-08-31) · T-023 (đã dọn hậu quả đã commit, 2026-08-31) · F-010 (cùng
họ lỗi, phía scope còn sót) · F-011 (`0704139 "dsfg"` — cùng chỗ hỏng, phía *subject* thay vì phía
*danh sách file*) · ADR-006 · ADR-008

**Status:**
Fixed — cơ chế dựng 2026-08-31 (T-016), hậu quả đã commit dọn xong 2026-08-31 (T-023).

---

### F-008 — Brief đọc Unknowns bằng **hình dạng dòng**, nên cách xuống dòng quyết định phiên sau có thấy câu hỏi không

**Problem:**
`scripts/brief.sh` lấy hai danh sách "đang mở" theo hai cách khác hẳn nhau:

- **Findings** (dòng 72–78): đọc **cấu trúc** — bắt `^### F-`, rồi đọc giá trị dưới `**Status:**`.
  Viết hoa, in đậm, xuống dòng thế nào cũng không ảnh hưởng.
- **Unknowns** (dòng 82): đọc **hình dạng dòng** — `grep -E '^\s*[-*]?\s*U-[0-9]'` trên cả khối
  `## Unknowns`.

Vế thứ hai hỏng hai chiều, và ngày **2026-08-30** (T-020) hỏng cả hai chiều cùng lúc:

1. **Giấu câu đang mở.** U-005 viết là `- **U-005 — …*` (in đậm ngay sau gạch đầu dòng) ⇒ giữa
   `[-*]?` và `U-` có thêm một dấu `*` ⇒ không khớp ⇒ brief in ra như thể **không còn câu nào mở**.
2. **Khoe câu đã đóng.** Câu văn xuôi kể các unknown *đã trả lời* vắt dòng đúng chỗ khiến một dòng
   **bắt đầu** bằng `U-004 — câu sinh ra từ…` ⇒ khớp ⇒ brief in U-004 vào OPEN UNKNOWNS suốt nhiều
   phiên, dù U-004 đã đóng từ trước.

**Impact:**
Đây là hỏng ở **đúng cơ chế mà CLAUDE.md §7.1 dựa vào**: brief là thứ đẩy trạng thái hôm nay vào
phiên mới, và nó "không bao giờ chặn" — mọi đường lỗi đều `exit 0`. Nên khi nó đọc sai thì không có
gì kêu lên; phiên sau chỉ đơn giản **tin bản sai**. Cụ thể lần này: BA-06 phải biết U-005 mới tick
được mục "không còn business rule bị suy đoán", mà brief lại bảo không còn câu nào mở. Chiều ngược
lại rẻ hơn nhưng bẩn dai: nhiều phiên liền được kể là U-004 đang mở, và ADR-002 nói phiên **tin**
brief hơn trí nhớ của mình.

**Decision / Fix:**
Đã sửa **phía dữ liệu** trong T-020 (2026-08-30): U-005 viết thành `- U-005 — **…**` (định danh
đứng ngay sau gạch đầu dòng, in đậm lùi ra sau), và câu văn xuôi được vắt lại để không dòng nào bắt
đầu bằng `U-004`.

Luật khi viết một `U-XXX` ở `docs/product.md` → *Unknowns*, cho tới khi `brief.sh` đọc theo cấu
trúc: **định danh đứng đầu dòng, ngay sau `- `, không có ký tự trang trí nào chen vào**; và **không
để một dòng văn xuôi nào bắt đầu bằng `U-` khi câu đó đã đóng**. Muốn nhấn mạnh thì in đậm phần
*sau* định danh.

Chưa sửa `scripts/brief.sh` — đó là chỗ chữa tận gốc (đọc cấu trúc như đang làm với findings, hoặc
tách hẳn hai mục *đang mở* / *đã đóng* thành hai khối máy đọc được), nhưng nằm ngoài scope T-020 và
là một quyết định về hình dạng của `docs/product.md`, không phải sửa chữ. Ghi thành task
**T-021** ở `work/backlog.md` → *Ready*.

**Đã chữa tận gốc 2026-08-31 (T-021 · `docs/decisions.md` ADR-007).** Mục *Unknowns* nay có hình
dạng máy đọc được và `brief.sh` đọc đúng hình dạng đó: **vùng đang mở** = đầu mục + mọi khối dưới
`### Đang mở`; trong vùng đó **một gạch đầu dòng là một unknown**, định danh tìm ở bất cứ đâu
trong gạch đầu dòng. Nên **luật viết tay ở đoạn trên hết hiệu lực** — trang trí và cách vắt dòng
không còn quyết định phiên sau thấy gì. Cách viết một câu ở đây nay nằm trong chính
`docs/product.md` → *Unknowns* → *Cách viết một câu ở đây*, và ở CLAUDE.md §4.

Sáu ca trong `scripts/brief.test.sh` khoá cả hai chiều lại (U1 giấu câu đang mở · U2, U5, U6 khoe
câu đã đóng · U3, U3b văn xuôi và vùng khác không sinh unknown). Chạy chúng trên bản `brief.sh`
trước T-021: **8 ca FAIL** — nghĩa là chúng thật sự bắt được con bug này.

**Một bài học nhỏ đi kèm, trả giá ngay trong lúc sửa:** bản đầu cắt tiêu đề dài bằng
`substr(rest, 1, 96)`. `substr()` ở awk trên máy này đếm **byte**, nên nó xẻ đôi một chữ tiếng
Việt, và regex ngay sau đó chết vì `towc: multibyte conversion failure` — brief mất **cả mục**
Unknowns mà vẫn `exit 0`, tức là hỏng đúng kiểu im lặng mà finding này nói tới. Cắt theo **từ**
thì không bao giờ xẻ đôi một ký tự. Ca U4 giữ chỗ này.

**Related task:**
T-020 (phát hiện, sửa phía dữ liệu), T-021 (chữa tận gốc, 2026-08-31)

**Status:**
Resolved

---

### F-007 — Bản xuất khẩu trỏ vào bảy đường không tồn tại, và người đọc nó ở ngoài repo

**Problem:**
`master_plan/prompt-fullstack.md` là bản xuất khẩu để gửi cho agent **ngoài** repo. Phần đầu file
(khối trích dẫn dòng 9–16) trỏ tới bảy đường không có trong repo này — kiểm bằng
`ls design quality/05-checklist.md finding.md quality/prompt_guiline.md` ngày **2026-08-30**, cả bốn
đều `No such file or directory`:

- `design/data_base/01-thiet-ke.md` (schema) · `design/backend/01-thiet-ke.md` (API) ·
  `design/frontend/01-thiet-ke.md` (route) · `design/system_design/01-thiet-ke.md` (bất biến) —
  thư mục `design/` không tồn tại;
- `quality/05-checklist.md` (định nghĩa XONG) · `quality/prompt_guiline.md` (khuôn 5 vế, trỏ từ
  dòng đầu file) · `finding.md#f-67` (rủi ro trôi của chính bản chép này).

Cùng loại, mức nhẹ hơn: §7 hàng `0 · BA` bảo *"trả lời 3 câu chưa rõ ở §3.2"*, trong khi §3.2 nay
chỉ còn một dòng *"Đã gộp vào §3.1"* và không giữ câu hỏi nào.

**Impact:**
Nặng hơn một link hỏng ở tài liệu nội bộ, vì file này được **dán vào prompt của agent ngoài repo**.
Người trong repo gặp link hỏng thì `ls` một cái là biết; người ngoài repo không có repo để `ls`. Họ
thấy một câu khẳng định *"nhà thật của schema là `design/data_base/01`"* và không có cách nào biết
nhà đó không tồn tại — nên hoặc dừng vì thiếu đầu vào, hoặc tự bịa ra nội dung của bảy file đó rồi
coi là đã có nguồn. Riêng `quality/prompt_guiline.md` và `finding.md#f-67` còn được nêu như **khuôn
và sổ rủi ro** của chính file này, tức phần tự-mô-tả của bản xuất khẩu cũng trỏ vào hư không.

**Decision / Fix:**
Chưa sửa — và cố ý không sửa trong T-013. Đây **không phải lỗi chữ**: sửa từng link đòi phải biết
`design/**` và `quality/05-checklist.md` là (a) tài liệu của một repo khác mà file này từng thuộc
về, (b) tài liệu sẽ được sinh ra ở các pha sau, hay (c) tàn dư của một cấu trúc đã bỏ. Ba khả năng
dẫn tới ba cách sửa khác nhau (trỏ đi nơi khác · ghi là *sẽ có sau pha N* · gỡ hẳn), nên chọn bừa
một cái là đoán hộ người quyết định.

Câu hỏi phải trả lời trước khi sửa: **`prompt-fullstack.md` còn thuộc dự án nào, và nó xuất khẩu ra
cho ai?** Trả lời xong mới biết bảy đường kia là link cần chữa hay là dấu vết cần gỡ. Task đã ghi
vào `work/backlog.md` → *Ready* (**T-019**).

Luật rút ra, bổ sung cho F-005 và F-006: hai luật đó rà **dữ kiện** đã đổi. Ở một bản xuất khẩu còn
phải rà **pointer** — mọi đường dẫn nó nêu ra phải `ls` được **tại thời điểm xuất khẩu**, vì người
đọc nó không đứng trong repo để tự kiểm.

**Cơ chế đã dựng 2026-08-30 (T-024):** luật *"mọi đường dẫn nêu ra phải `ls` được"* nay do máy
chấm — `scripts/check-links.sh` (Gate 1b, ADR-005) chạy ở mọi lượt. Bảy đường của file này được
ghi vào `scripts/check-links.ignore` mang tên T-019 vì câu hỏi *"file này còn thuộc dự án nào"*
vẫn chưa ai trả lời; finding vẫn **Open**, cổng chỉ đảm bảo không có đường chết **mới**.

**ĐÓNG 2026-08-31 (T-019) — chủ repo trả lời: đáp án là (c), tàn dư của một repo khác.**
Bằng chứng đưa ra trước khi hỏi, chứ không phải sau khi đoán:

- `git log --all -- 'design/*' 'quality/05-checklist.md' 'quality/prompt_guiline.md' 'finding.md'`
  **rỗng** — không đường nào từng tồn tại trong repo này, một lần nào, trong toàn bộ lịch sử.
- Bảy đường không rời rạc mà là **một bộ layout hoàn chỉnh** của repo cũ: `project_preparation/` +
  `design/{data_base,backend,frontend,system_design}/01-thiet-ke.md` + `quality/05-checklist.md` +
  `quality/prompt_guiline.md` + `finding.md` ở gốc (đánh số F-31, F-67 — repo này đánh F-001…).

**Điểm chính, và là lý do finding này đáng giữ lại sau khi đóng: một "đường chết" không có một
cách sửa.** Bảy đường chia làm hai nhóm khác hẳn nhau:

- **Có nhà tương đương trong repo này ⇒ trỏ lại.** `quality/prompt_guiline.md` →
  `docs/prompt-guideline.md` · `quality/05-checklist.md` → `CLAUDE.md` §8 + `quality/review-gate.md`
  · `finding.md#f-67` và `#f-31` → `work/findings.md` F-001.
- **Không có nhà, và sẽ không bao giờ có sẵn ⇒ bỏ link, ghi là việc phải làm.** Bốn đường
  `design/**` (schema · API · route · bất biến) là **đầu ra của pha 1–4** ở §7 của chính file đó.
  Trỏ chúng đi đâu cũng sai. Đây là chỗ dễ hỏng nhất: một agent sốt sắng sẽ trỏ chúng sang
  `docs/architecture.md` cho gate xanh, và thế là biến *"việc chưa làm"* thành *"nguồn đã có"* —
  đúng thứ hại mà finding này mở ra để chặn.

**Đường thứ tám — finding này đếm thiếu, và Gate 1b không thấy được nó.** Dòng cuối §11 bảo người
đọc tự kiểm bằng `` `grep -n '^## §' project_preparation/prompt-fullstack.md` `` — file tự gọi tên
mình ở `project_preparation/` trong khi nó nằm ở `master_plan/`. `check-links.sh` bỏ qua chuỗi
nháy ngược **có dấu cách** (dòng lọc `*" "*`), mà đây là cả một câu lệnh `grep`, nên cổng im lặng.

**Chỗ mù đó vẫn còn, cố ý chưa dựng cơ chế.** Nới bộ lọc để nhận đường dẫn nằm trong câu lệnh sẽ
kéo theo mọi `GET orders/:code`, `PATCH staff/tasks/:id`, `Asia/Ho_Chi_Minh` của §3.6 — nhiễu
nhiều hơn tín hiệu. Mới hỏng **một** lần, dưới ngưỡng hai lần của CLAUDE.md §3.8. Cách bù hiện
tại là tay: đổi bản xuất khẩu thì `grep` cả tên thư mục của repo cũ, đừng chỉ tin Gate 1b.
Gặp lần thứ hai ⇒ mở finding riêng cho chỗ mù này, đừng nới bộ lọc trước khi có lần thứ hai.

**Sửa gì 2026-08-31 (T-019):** tám chỗ ở `master_plan/prompt-fullstack.md` — khối đầu file (khuôn,
nhà thật, F-67), §7 hàng `0 · BA`, §9.3 (F-31), §11 (hai chỗ). Bảy dòng ignore mang tên T-019 đã
gỡ khỏi `scripts/check-links.ignore`; `./scripts/check-links.sh` xanh **sau khi** gỡ — đó là bằng
chứng task xong, đúng như T-024 thiết kế (ignore hết hạn tự làm gate đỏ).

**Một cái bẫy nhỏ, đáng nhớ:** dòng 3 ghi *"Khuôn: quality/prompt_guiline.md **(5 vế)**"*. Nhà
tương đương `docs/prompt-guideline.md` §2 lại là **sáu khối**. Đổi đường dẫn mà giữ nguyên cái
ngoặc là thay một pointer **chết** bằng một pointer **đúng đường nhưng sai nội dung** — loại thứ
hai khó thấy hơn hẳn, vì mọi cổng đều xanh. Luật rút ra: sửa một pointer thì đọc cả câu chữ mô tả
đích, không chỉ đổi đường dẫn.

**Related task:**
T-013 (phát hiện) · T-019 (sửa, đóng 2026-08-31) · T-024 (dựng cổng chấm)

**Status:**
Fixed

---

### F-010 — Scope quên dọn thì phiên sau bị chấm bằng scope của người khác, và brief nói dối về trạng thái

**Problem:**
`work/scope.txt` là working state: CLAUDE.md §6 cấm commit pattern, §7.3 bắt xoá pattern khi task
xong. Cả hai luật chỉ dựa vào **việc ai đó nhớ**, và đã hỏng hai lần, đếm bằng lịch sử git tới
**2026-08-30**:

| Commit | Ngày | Còn lại trong `work/scope.txt` |
|---|---|---|
| `5c41f65` "udpate shop fact" | 2026-08-30 | 6 pattern |
| `25f0f88` "sdfg" | 2026-08-30 | 8 pattern (scope của T-010, còn kèm hai dòng của T-007) |

Đếm lại được bằng:
`for c in $(git log --format=%H -- work/scope.txt); do git show $c:work/scope.txt | grep -vcE '^\s*(#|$)'; done`

Lần thứ ba bị T-011 chặn bằng tay lúc dọn cuối task (`2692178`) — sạch nhờ một người nhớ, không
nhờ cơ chế nào.

**Impact:**
Hậu quả không nằm ở hai dòng text thừa mà ở **phiên sau**, tại đúng hai chỗ hệ thống dùng làm tín
hiệu trạng thái:

- **`scripts/check-scope.sh` (Gate 3) chấm bằng scope của task đã xong.** Nó coi *bất kỳ* pattern
  nào là "scope đã khai báo". Phiên sau sửa một file khác ⇒ Gate 3 **đỏ vì lý do sai** — đúng thứ
  ADR-003 gọi là *"dạy người ta bỏ qua gate"*. Hoặc tệ hơn: danh sách cũ tình cờ đủ rộng ⇒ gate
  **xanh** cho một thay đổi chưa ai cho phép.
- **`scripts/brief.sh` khẳng định sai.** Nó in nguyên khối *DECLARED SCOPE* rồi kết luận *"→ a task
  is open. Finish or hand it off before starting another."* Mọi phiên mới mở màn bằng một câu sai
  về trạng thái — trong khi CLAUDE.md §7 dựng cả brief lên để chống đúng chuyện đó.

Đây cũng là hai dòng đầu của bảng bốn lần trong **F-009**: cùng một họ lỗi *commit nuốt thứ task
không được phép chạm*. F-009 sở hữu phía **khối commit**; finding này sở hữu phía **scope còn sót**.

**Decision / Fix:**
Đã dựng cơ chế **2026-08-31 (T-016)**, và đây là điểm chính của finding: luật viết trong CLAUDE.md
§6 và §7.3 **không tự thi hành được**. Ngưỡng §3.8 (*"chỉ thêm cơ chế sau khi cùng một vấn đề tốn
công hai lần"*) đã đạt đúng bằng hai dòng của bảng trên — không sớm hơn.

`scripts/brief.sh` nay phân biệt hai trạng thái và chỉ kêu ở trạng thái hỏng: scope còn pattern
**mà** `work/backlog.md` không có task nào ở *In Progress*. Cảnh báo nêu đích danh `work/scope.txt`
và số pattern còn lại; scope còn pattern **kèm** task *In Progress* là hợp lệ nên vẫn im. Brief
không bao giờ đổi mã thoát (§7.1). Lý do chọn `brief.sh` chứ không phải `check-scope.sh` hay
`gate.sh`: **docs/decisions.md ADR-006**. Ca kiểm: `scripts/brief.test.sh` (B1–B5).

**Related task:**
T-016 (dựng cơ chế) · F-009 (cùng họ lỗi, phía khối commit) · ADR-006

**Status:**
Fixed

---

### F-011 — `0704139 "dsfg"`: cổng chặn được phiên quên viết nội dung commit, nhưng không chặn được người gõ `git commit -m` ngoài phiên

**Problem:**
Ngày **2026-08-31**, giữa lúc T-023 đang hỏi chủ repo ba câu quyết định, toàn bộ cây làm việc
được commit thành `0704139` với subject **`dsfg`** và không có phần thân. Commit đó gộp **ba**
task đã xong nhưng chưa commit — T-016, T-021, T-009 — 10 file, +1006/−97, kèm cả `docs/product.md`
mà không subject nào nhắc tới. Nó đã được đẩy lên `origin/merge_first_time` trước khi ai kịp đọc.

Đây là lần thứ **tư** của họ lỗi *commit không nói gì về chính nó*, sau ba lần ADR-004 đã dẫn làm
bằng chứng (`202e8c4 ádg`, `2692178 sdgf`, `25f0f88 sdfg`). Khác ba lần trước ở một điểm đáng ghi:
lần này **cơ chế đã tồn tại và đã chạy đúng** — `scripts/check-commit-block.sh` (Gate 7, ADR-004)
cùng Gate 7b (ADR-006) đều xanh, và khối commit đúng luật §6.1 cho T-016 **đã được soạn sẵn và đưa
ra trong lượt ngay trước đó**.

**Impact:**
ADR-004 nói thẳng cái mất là gì: *"lý do của một thay đổi không lấy lại được sau khi phiên kết
thúc"*. Cụ thể ở đây:

- **Ba task, một commit** — trái CLAUDE.md §6 *"One task per commit"*. Không revert được T-021 mà
  không revert kèm T-016 và T-009.
- **`brief.sh` in RECENT COMMITS cho mọi phiên mới** (ADR-002). Phiên sau đọc log thấy `dsfg` ở
  đỉnh nhánh và không suy ra được gì; ba task xong hôm đó chỉ còn dấu vết trong `work/backlog.md`.
- **Đã push** ⇒ không sửa được bằng `git commit --amend`. Cùng lý do với `0b3a337` ở F-009, nên
  cùng cách xử: sửa tiến, không viết lại (**ADR-008**).
- Nó cũng chứng minh **ranh giới thật của Gate 7**: cổng sống trong vòng đời một *lượt của phiên*.
  Một người gõ `git commit -m dsfg` ở terminal không đi qua lượt nào cả. Không có hook nào của
  Claude Code đứng ở đó được.

**Decision / Fix:**
ADR-004 mục *Rủi ro đã chấp nhận* đặt sẵn điều kiện kích hoạt: *"Nếu có lần thứ hai một thay đổi
đi vào git mà không có nội dung commit, ghi finding và siết lại."* Finding này là vế **ghi**; vế
**siết lại** là **T-025**, không làm gộp vào T-023 (§3.8: T-023 dọn hậu quả, không dựng cơ chế).

Chỗ siết đúng là chỗ Gate 7 với tay không tới nhưng vẫn chạy được với người gõ tay: một
**`commit-msg` hook của git** trong repo, từ chối subject không có dạng `T-XXX: …` hoặc ngắn hơn
một ngưỡng. Ràng buộc kèm theo, để không lặp lại bài học ADR-003 (*đỏ vì lý do sai*):

- Không lật CLAUDE.md §6: hook **không** tự soạn nội dung, chỉ từ chối cái rỗng nghĩa.
- Phải có đường thoát rõ ràng (`--no-verify`) và nói ra trong chính thông báo lỗi.
- `git` hook không đi theo bản clone; nên `T-025` phải kèm cách cài, nếu không nó chỉ bảo vệ đúng
  một máy.

Bản đồ `0704139` → ba task nó thật sự chứa nằm ngay trong finding này; đó là thứ thay cho việc
sửa lịch sử.

**Related task:**
T-023 (phát hiện, ghi lại) · T-025 (siết lại, còn mở) · F-009 (cùng chỗ hỏng, phía *danh sách
file* thay vì phía *subject*) · ADR-004 (đặt điều kiện kích hoạt) · ADR-008 (luật sửa tiến)

**Status:**
Open — cơ chế chưa siết. Bản đồ hash → nội dung thật đã ghi.
