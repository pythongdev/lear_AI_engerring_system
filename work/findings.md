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

**Related task:**
T-011, T-012 (lần rà thứ ba)

**Status:**
Fixed
