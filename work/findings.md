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

### Cách viết dòng `**Status:**` — hợp đồng với `scripts/brief.sh`

`scripts/brief.sh` in mục OPEN FINDINGS cho **mọi phiên mới** (ADR-002), và nó so khớp
**đúng chữ**: dòng ngay dưới `**Status:**` phải là `Open`, không thêm gì. `Open — chưa siết cơ
chế` **không khớp**, nên finding đó biến mất khỏi brief trong khi vẫn còn mở — phiên sau không
bao giờ nhìn thấy nó.

Muốn nói thêm thì nói ở `**Decision / Fix:**`, không nói ở đây. Cùng một bài học với
`docs/product.md` → *Unknowns* (F-008 · ADR-007): **thứ brief đọc được là thứ có hình dạng cố
định**, và văn xuôi chen vào đúng chỗ đó là cách nhanh nhất để giấu một việc còn mở.

Ghi lại 2026-08-31 sau khi **F-011** bị chính lỗi này giấu ngay trong lượt nó được viết ra.

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

**Lần thứ năm, cùng ngày: `03ffda3 "adg"` (2026-08-31).** Ghi thêm vào đây chứ không mở finding
mới — cùng một cơ chế hỏng, chỉ khác số lần. Nó nuốt **T-023 + T-019** cùng một lúc, cộng
`work/proposals/admin.admiadmin/admin1.md` (2342 dòng) mà không task nào trong hai task đó nhận.
Bản đồ, để log ngừng nói dối (ADR-008):

| Hash | Subject trong log | Nội dung **thật** |
|---|---|---|
| `0704139` | `dsfg` | T-016 + T-021 + T-009. 10 file, +1006/−97 |
| `03ffda3` | `adg` | T-023 + T-019, **cộng** `work/proposals/admin.admiadmin/admin1.md` (+2342, không thuộc task nào). 9 file, +2779/−66 |

Điểm đáng ghi của lần thứ năm: T-023 **đang chạy** khi nó xảy ra, nên chính task đi dọn hậu quả
của `0b3a337` lại bị commit bằng đúng cơ chế nó đang dọn. Đó là bằng chứng mạnh nhất cho **T-025**:
luật viết trong `CLAUDE.md` §6 không chạm tới được cái terminal.

**ĐÓNG 2026-08-31 (T-025) — cổng đã dựng, ở đúng chỗ Gate 7 với tay không tới.**
`scripts/hooks/commit-msg` là hook của **git**, nên nó đứng giữa người gõ tay và git chứ không nằm
trong vòng đời một lượt của phiên. Luật, các phương án đã loại và các rủi ro còn lại ở
`docs/decisions.md` **ADR-010**; cách dùng ở `CLAUDE.md` §6.2. Cả năm subject kể tên trong finding
này (`ádg`, `sdgf`, `sdfg`, `dsfg`, `adg`) đều là ca test trong `scripts/commit-msg.test.sh`, và ca
cuối cùng của test dựng một repo thật rồi gõ `git commit -m "dsfg"` để chấm đúng đường mà F-011 đi
qua.

Bản đồ hash ở trên **ở lại vĩnh viễn**: hai commit kia đã push, ADR-008 nói sửa tiến chứ không viết
lại, nên log vẫn hiển thị `dsfg` và `adg`. Cổng mới không dọn quá khứ, nó chỉ chặn lần thứ sáu.

**Cái cổng này KHÔNG chặn, và ai đọc finding này phải biết:**
- `git commit --no-verify` vẫn đi qua. Cố ý (ADR-003 — cổng không có đường thoát thì bị gỡ chứ
  không được sửa). Nếu `--no-verify` thành thói quen thì đó là finding tiếp theo.
- `.git/` không đi theo `git clone`, nên bản clone mới có file hook mà **không** có hook đang chạy
  cho tới khi ai đó chạy `./scripts/install-hooks.sh`. Không ép được; chỉ nói ra được —
  `scripts/brief.sh` kêu ở mỗi phiên khi chưa cài.
- Nó chấm *rỗng nghĩa*, không chấm *đúng sai*. `T-025: fix stuff` vẫn qua.

**Related task:**
T-023 (phát hiện, ghi lại) · T-025 (siết lại, **xong 2026-08-31**) · F-009 (cùng chỗ hỏng, phía
*danh sách file* thay vì phía *subject*) · ADR-004 (đặt điều kiện kích hoạt) · ADR-008 (luật sửa
tiến) · ADR-010 (cổng được dựng ra sao và vì sao hẹp đến thế)

**Status:**
Fixed

---

### F-012 — Brief cắt mọi danh sách ở 6 mà không nói đã cắt, nên câu hỏi thứ bảy vô hình ngay lúc được viết ra

**Problem:**
`scripts/brief.sh` đặt `MAX_LIST=6` và dùng nó cho **bốn** danh sách: In Progress · Ready · Open
findings · Open unknowns. Mỗi danh sách kết thúc bằng `head -n "$MAX_LIST"`, và **không có dòng nào
nói phần còn lại tồn tại**. Danh sách bảy mục in ra sáu mục, trông y hệt một danh sách sáu mục.

Ngày **2026-08-31** nó xảy ra thật, trong chính lượt sinh ra dữ liệu: T-026 thêm bốn câu hỏi mở vào
`docs/product.md` → *Unknowns*, BA-03 thêm hai câu trong cùng khoảng thời gian, cộng U-005 có sẵn
là **bảy**. Brief in **sáu**. **U-011** — *máy chỉ hiện tổng nhu cầu hay được tự chia mẻ* — không
xuất hiện trong brief của bất kỳ phiên mới nào, kể từ dòng đầu tiên nó được viết ra.

Đây là **lần thứ hai** cùng một hậu quả, khác nguyên nhân. **F-008** là lần thứ nhất: brief đọc mục
*Unknowns* bằng hình dạng dòng nên giấu mất U-005. T-021 đã chữa **cách đọc** (ADR-007), và cách
đọc nay đúng — nó đọc ra đủ bảy mục rồi mới vứt mục thứ bảy đi ở bước in. Chỗ hỏng đã dịch từ
*parser* sang *bộ cắt*, hậu quả thì không đổi.

**Impact:**
Hậu quả rơi đúng vào thứ CLAUDE.md §7 dựng brief lên để chống. Brief là **cơ chế duy nhất** đẩy
danh sách câu hỏi mở vào một phiên bắt đầu từ context rỗng (ADR-002); phiên nào cũng đọc nó trước
chỉ thị đầu tiên. Một câu hỏi không có trong brief là một câu hỏi phiên sau **không biết là mình
đang không biết** — và CLAUDE.md §3.5 thì bắt phiên ấy dừng lại mà hỏi. Không biết có câu hỏi thì
không dừng: nó tự suy ra một câu trả lời, đúng hành vi §3.5 cấm.

Ba chỗ nữa cùng chịu, chưa xảy ra nhưng cùng một dòng mã:
- **Ready** — hiện có 10 dòng chưa tick, brief in 6. Bốn task cuối, gồm cả **BA-12** vừa mở, không
  phiên mới nào nhìn thấy.
- **Open findings** — finding thứ bảy trở đi biến mất, kể cả finding này.
- **In Progress** — ít khi quá 6, nhưng cùng cơ chế.

Cái giá của việc im lặng nặng hơn cái giá của việc cắt. Cắt là quyết định đúng: CLAUDE.md §7.1 nói
brief **trỏ, không chép**, và một brief dài 40 dòng thì không ai đọc. Thứ hỏng là **cắt mà không
nói đã cắt** — người đọc không có cách nào phân biệt "hết rồi" với "còn nữa".

**Decision / Fix:**
**Đã sửa 2026-08-31 bởi T-027.** Ghi ngày 2026-08-31 trong lúc chạy T-026; T-026 **không** chạm
`scripts/` vì hai phiên khác đang chạy song song trong cùng cây làm việc (BA-03, T-025), và T-025
sở hữu `scripts/`.

Cách sửa, đúng bốn ràng buộc dưới đây — **không** phải "đổi `MAX_LIST=6` thành một số to hơn": số
nào cũng có một danh sách vượt qua nó, và lúc đó im lặng vẫn im lặng.

- `scripts/brief.sh` có hàm `emit`: in tối đa N mục, rồi khi có mục bị bỏ lại thì nói ra
  **`→ ĐÃ CẮT: in 6/10 mục. Còn 4 mục nữa chỉ có ở work/backlog.md → Ready.`** — in mấy trên mấy,
  còn mấy, và đọc đủ ở đâu. Cả bốn danh sách đi qua nó.
- Danh sách **bằng hoặc ngắn hơn** ngưỡng không in thêm dòng nào: một dòng "đã in hết" ở mỗi phiên
  là tiếng ồn, và tiếng ồn là thứ làm người ta thôi đọc brief.
- Câu hỏi mở có hằng số riêng, `MAX_UNKNOWNS=12`, đặt cạnh `MAX_LIST=6` với lý do viết ngay ở đó.
  Ca thật của finding này — **bảy** câu mở — nay in đủ bảy, U-011 có mặt. Khi nó *thật sự* bị cắt,
  dòng thông báo nói thẳng hậu quả: phiên không biết mình đang thiếu thì CLAUDE.md §3.5 không dừng
  được nó.
- `scripts/brief.test.sh` có bảy ca mới (C1–C7) cho danh sách **vượt ngưỡng** ở cả bốn danh sách,
  cộng ca "bằng đúng ngưỡng thì im" và ca "bảy câu mở không bị cắt". Mọi ca đều kiểm `exit 0`.

Một thứ tiện thể đúng ra: `$inprog` nay giữ danh sách **đủ**, không phải bản đã cắt — cảnh báo
"scope chưa dọn" hỏi "có task nào đang chạy không", và hỏi câu đó trên một danh sách đã cắt là hỏi
trên nửa sự thật.

Ràng buộc gốc của T-027, giữ lại nguyên văn để đọc ngược:

- Brief **nói ra** phần đã cắt — bao nhiêu mục nữa, ở file nào — thay vì lặng lẽ dừng.
- Danh sách **câu hỏi mở** đáng được đối xử khác ba danh sách kia: nó là thứ §3.5 bắt phiên phải
  biết, và nó ngắn tự nhiên. Cắt nó là quyết định phải nói thẳng, không phải mặc định thừa hưởng
  từ một hằng số dùng chung.
- Không đổi mã thoát. Brief **không bao giờ** chặn (CLAUDE.md §7.1).
- `scripts/brief.test.sh` có ca cho danh sách **dài hơn** ngưỡng — ca hiện có đều dưới ngưỡng nên
  không ca nào bắt được lỗi này.

**Related task:**
T-027 (đã sửa 2026-08-31) · T-026 (phát hiện) · F-008 (lần thứ nhất, phía *cách đọc*; T-021 đã
chữa) · ADR-002 (brief đẩy trạng thái vào mọi phiên) · ADR-007 (hợp đồng hình dạng mục Unknowns)

**Status:**
Fixed (2026-08-31, T-027)

---

### F-013 — Bản xuất khẩu vẫn thiết kế nút `Xong` ở màn trạm, sau khi chủ quán đã bỏ nút ấy

**Problem:**
Ngày **2026-08-31** chủ quán trả lời câu *ai bấm "đã làm xong" và "đã bưng ra bàn"* bằng cách **bỏ
bước ấy đi**: *"bỏ qua bước này, POS sẽ tự cập nhật được bao nhiêu cái cho từng bàn"*
(`master_plan/shop-facts.md` §5.4). Ba trạm `trang_banh`, `gap_banh`, `canh` không bấm gì cả.

`master_plan/prompt-fullstack.md` — bản xuất khẩu để người **ngoài repo** lập kế hoạch full-stack —
vẫn đang nói ngược lại, ở **ba** chỗ:

| Chỗ | Đang viết |
|---|---|
| §3.6, khối *Nhân viên* | `PATCH staff/tasks/:id` (`todo → doing → done`) |
| §3.7, gạch đầu dòng *Màn hình trạm* | *"một task = một thẻ, một nút `Xong`"* |
| §3.7, cùng gạch đầu dòng | *"không hỏi 'Bạn chắc chứ?', thay bằng `Hoàn tác` trong 10 giây"* — `Hoàn tác` cho thao tác nào, khi không còn thao tác nào |

Cả ba viết trước ngày 2026-08-31 và đúng vào lúc viết. Chúng sai **từ lúc chủ quán trả lời**, không
phải từ lúc ai đó phát hiện.

**Impact:**
Đây là **loại thứ ba** của cùng một họ, sau F-005 (dữ kiện đổi, tài liệu khung còn nói cũ) và
F-007 (pointer chết trong bản xuất khẩu). Điểm chung của cả ba: **người đọc bản xuất khẩu đứng
ngoài repo** — họ không `grep` được, không thấy `shop-facts.md` §5.4, không biết có một lời chốt
sau đó. Họ đọc §3.6 và §3.7 rồi dựng đúng thứ được viết.

Cái giá cụ thể nếu không sửa: một endpoint và một màn hình được làm ra cho một thao tác **không ai
thực hiện**. Nút đứng đó, không ai bấm, nên mọi con số phía sau nó — *"bàn này đã được mấy cái"*,
*"còn thiếu gì"* — đứng im. Và vì màn hình *trông* như đang chạy, chỗ hỏng chỉ lộ ra khi quán đã
đông khách.

Nặng hơn F-005 ở một điểm: F-005 làm người ta ghi **sai một con số**; cái này làm người ta **xây
một cơ chế cho một actor không tồn tại**, rồi mọi thứ dựng trên cơ chế ấy đều phải làm lại.

**Decision / Fix:**
Chưa sửa `master_plan/prompt-fullstack.md`. Ghi ngày 2026-08-31 trong lúc chạy **T-029** (viết
`docs/architecture.md`); T-029 không nhận thêm file vào scope vì ba phiên khác đang có thay đổi
chưa commit trong cùng cây làm việc.

`docs/architecture.md` §1.1 nay nói thẳng luật đúng — **POS là nơi duy nhất ghi tiến độ; màn trạm
chỉ đọc** (`docs/decisions.md` **ADR-011**) — và nêu đích danh ba chỗ của bản xuất khẩu đang sai.
Việc sửa chính bản xuất khẩu là **T-031**.

Ràng buộc cho T-031, để nó không sửa thành một lỗi khác:

- Trạm `don_ban` **vẫn có** một thao tác (bấm *đã dọn*). "Bỏ nút ở bếp" là ba trạm, không phải bốn.
- Bỏ `PATCH staff/tasks/:id` thì phải trả lời **cái gì thay nó** — `docs/architecture.md` §1.1 nói
  là POS; đừng chỉ xoá dòng rồi để trống.
- Ba luật hiển thị còn lại của §3.7 (chữ to · cũ nhất lên đầu · màu theo thời gian chờ) **vẫn
  đúng**, đừng xoá kèm.
- Không sửa `prompt/maintenance/` — đó là ghi chép lịch sử của các task đã chạy
  (cùng lý lẽ T-028 đã dùng).

**Đã sửa — T-031, 2026-08-31.** Cả ba chỗ, và cả bốn ràng buộc trên đều giữ:

| Chỗ | Nay viết |
|---|---|
| §3.6, khối *Nhân viên* | `PATCH staff/tasks/:id` **bị gỡ**; `GET staff/tasks?station=` đánh dấu **chỉ đọc**; thêm `POST staff/sessions/:id/served` — **POS** ghi đã phục vụ |
| §3.6, ngay dưới khối | một khối *Luật ghi* **tự đứng**: chỉ POS ghi · không có vòng `todo → doing → done` · ngoại lệ duy nhất là `don_ban` bấm *đã dọn* |
| §3.7, *Màn hình trạm* | ba trạm bếp là **màn chỉ đọc**, thẻ **tự biến mất** khi POS ghi đã phục vụ; ba luật hiển thị + số bàn to nhất **giữ nguyên** |
| §3.7, `Hoàn tác` 10 giây | **chuyển** sang gạch đầu dòng mới *Màn dọn bàn* — nơi còn một thao tác thật, thay vì đứng ở màn không còn nút nào |

Cái quan trọng nhất không phải việc xoá: **luật ghi nay nằm trong chính bản xuất khẩu**, không phải
ở một pointer trỏ về `docs/architecture.md`. Đó là điểm chung của cả họ F-005 / F-007 / F-013 —
người đọc đứng **ngoài** repo — nên bản vá phải tự đứng được trong file họ cầm.

Bốn pointer nói *"bản xuất khẩu còn sai"* được sửa trong cùng thay đổi (CLAUDE.md §7.2):
`docs/architecture.md` §1.1 và §5, `docs/decisions.md` ADR-011 (*Rejected alternatives* và
*Applies to*). `master_plan/shop-facts.md` không đổi một chữ — dữ kiện chưa bao giờ sai, chỉ bản
chép sai. `prompt/maintenance/` giữ nguyên theo ràng buộc thứ tư.

**Chỗ còn hở, cố ý:** tên `POST staff/sessions/:id/served` là **thiết kế**, không phải dữ kiện —
`docs/architecture.md` §8 cố ý không đặt tên bảng/cột/endpoint, và *"đã phục vụ bao nhiêu cho từng
bàn"* vẫn nằm trong danh sách sáu chỗ 16 bảng chưa với tới. Pha System Design đổi tên nó thì đổi,
miễn giữ đúng luật: **người ghi là POS**.

**Related task:**
T-031 (đã sửa bản xuất khẩu, 2026-08-31) · T-029 (phát hiện, viết `docs/architecture.md`) ·
T-028 (ghi lời chốt 2026-08-31 sinh ra mâu thuẫn này) · F-005 · F-007 (cùng họ, cùng chỗ đọc) ·
ADR-011

**Status:**
Fixed (2026-08-31, T-031)

---

### F-014 — Cảnh báo "scope bẩn" của brief bảo phiên mới XOÁ, trong khi chủ thật của scope đang chạy song song

**Problem:**
`scripts/brief.sh` in cảnh báo này khi `work/scope.txt` còn pattern mà `work/backlog.md` không có
task nào ở *In Progress*:

> *"Scope của task đã xong chưa được dọn. **Dọn nó TRƯỚC khi bắt task mới**"*

Cảnh báo đọc trạng thái **lúc phiên bắt đầu**, và nó không phân biệt được hai thứ trông giống hệt
nhau trong một file phẳng:

| Cùng một hình dạng | Nhưng phải xử ngược nhau |
|---|---|
| Pattern của task **đã xong**, chưa commit | giữ lại — gỡ sớm là Gate 3 đỏ (đúng như chính scope.txt tự dặn) |
| Pattern của một phiên **đang chạy song song**, vừa khai xong | **không được chạm** — xoá là cướp scope của người ta |

Ngày **2026-09-01**, phiên chạy BA-04 nhận cảnh báo ấy (38 pattern, không task nào In Progress),
làm đúng thứ được bảo, và **xoá mất khối scope của hai phiên T-027 và T-031 đang chạy trong cùng
cây làm việc**. Ba khối được dựng lại ngay sau đó, mỗi khối ghi rõ nó là bản dựng lại và có thể
hẹp hơn bản gốc; hai phiên kia tự sửa lại khối của mình.

**Impact:**
Đây là lần **thứ hai** của cùng một hậu quả, và lần này nguyên nhân nằm ở **máy**, không ở người:

- Lần đầu (2026-08-31, T-019 + T-023 chạy song song) là **người** suýt ghi đè; bài học được ghi ở
  `work/backlog.md` → *Ready* — *"phiên vào sau phải THÊM khối của mình chứ đừng ghi đè"* — cùng họ
  với **F-010**.
- Lần này **brief chủ động ra lệnh xoá**. Một bài học nằm trong `work/backlog.md` không thắng được
  một câu mệnh lệnh in ra ở đầu mỗi phiên: phiên mới đọc brief trước, và brief nói "dọn nó TRƯỚC".

Cái giá: Gate 3 chấm việc của phiên khác bằng scope của mình (đúng thứ **F-010** mô tả), và trong
ca xấu hơn ca đã xảy ra — phiên kia commit trong lúc scope của nó đang bị xoá — `git add` theo một
scope sai sẽ đưa file lạ vào commit, tức lại là **F-009**.

**Decision / Fix:**
Chưa sửa `scripts/brief.sh`. Ghi ngày 2026-09-01 trong lúc chạy **T-036**; sửa script là **T-035**,
để riêng vì nó chạm `scripts/` và cần ca kiểm mới trong `scripts/brief.test.sh`.

Ràng buộc cho T-035, để nó không sửa thành một lỗi khác:

- **Đừng bỏ cảnh báo.** Ca nó bắt được là ca thật và đã cứu nhiều phiên: scope của task đã xong,
  không ai dọn (`work/findings.md` **F-010**, `docs/decisions.md` ADR-006).
- **Đổi lời, không đổi điều kiện.** Câu mệnh lệnh phải là *"THÊM khối của bạn vào cuối; chỉ gỡ khối
  nào ghi rõ đã commit"* — chứ không phải *"dọn nó TRƯỚC khi bắt task mới"*.
- **Brief không được tự đoán có phiên nào đang chạy.** Nó không có cách nào biết, và một cảnh báo
  đoán sai còn tệ hơn cảnh báo hiện tại. Nó chỉ được **nói ra rằng nó không biết**.
- Nếu muốn máy phân biệt được thật thì phải đổi **hình dạng của `work/scope.txt`** (mỗi khối có
  dòng chủ + ngày, brief đọc theo cấu trúc như đã làm với *Unknowns* ở ADR-007) — đó là một quyết
  định riêng, cần ADR, **không** gấp vào T-035 mà không hỏi.

**Lần thứ ba, cùng ngày: `ffc2997` nuốt nguyên một task đang viết dở (2026-09-01).** Ghi thêm vào
đây chứ không mở finding mới, vì nguyên nhân gốc y hệt: **nhiều phiên chạy trên cùng một cây làm
việc**. Lần này hậu quả không rơi vào `work/scope.txt` mà rơi vào **lịch sử git** — đúng ca xấu hơn
mà mục *Impact* ở trên đã đoán trước.

Diễn biến: phiên **BA-06** đang viết `docs/product.md` §4 (mục *Giá và thanh toán*, ~290 dòng) thì
một phiên song song commit hai task của nó. `git add docs/product.md` lấy **cả file**, mà file lúc
ấy đã mang sẵn §4 chưa xong của phiên khác.

*Bản đồ hash → nội dung thật:*

| Hash | Subject | Nội dung thật |
|---|---|---|
| `c5540e2` | `T-036: S-4 có lời giải…` | đúng T-036 |
| `53f58de` | `T-037: U-017 và U-018 đóng…` | đúng T-037 |
| `ffc2997` | `T-036 + T-037: S-4, U-017 và U-018 đóng; mục Unknowns rỗng` | **T-036 + T-037 CỘNG toàn bộ `docs/product.md` §4 của BA-06** (+322 dòng ở `docs/product.md`, +15 ở `work/backlog.md`). Thân commit không nhắc BA-06 một chữ |

Hai chỗ subject và thân commit `ffc2997` **nói sai về chính nó**, và cả hai đều đánh lừa được phiên
sau:

- Nó ghi *"mục Unknowns rỗng"*. Cây mà nó commit **không** rỗng: chính nó mang **U-019** và
  **U-020** — hai câu BA-06 vừa mở — vào lịch sử dưới dạng gạch đầu dòng đang mở.
- Ai chạy `git log` để tìm §4 đến từ đâu sẽ đọc ra *"T-036 + T-037"*, tức hai task **không liên
  quan gì** tới giá và thanh toán. `git blame docs/product.md` cũng trỏ về đó.

**`ffc2997` đã push lên `origin/merge_first_time` trước khi BA-06 phát hiện ra**, nên `ADR-008`
đóng đường sửa lại: **sửa tiến, không viết lại**. Bản đồ hash ở trên là bản sửa tiến, và nó **ở lại
vĩnh viễn** — cùng lý do với bản đồ hash ở F-011.

⇒ **Bài học thêm, và nó không nằm trong T-035.** T-035 sửa *lời cảnh báo của brief*; ca này thì
brief không dính dáng gì. Cái hỏng là **`git add <file>` lấy cả file, không lấy được "phần của
tôi"** — nên trong một cây có nhiều phiên, *một task một commit* (CLAUDE.md §6) không phải thứ kỷ
luật giữ được, mà là thứ **cách làm việc** phải giữ. Hai đường ra, chọn đường nào cũng được nhưng
phải chọn:

- **Không chạy hai phiên trên cùng một cây.** Phiên thứ hai làm trong `git worktree` riêng. Đây là
  đường duy nhất thật sự đóng được cả F-014 lẫn ca này.
- **Hoặc: trước khi commit, đọc `git diff --cached` và đối chiếu với `work/scope.txt` của MÌNH.**
  Gate 7b (`ADR-006`) đã làm đúng việc này cho khối commit do phiên viết ra — nhưng nó không chạy
  khi người ta gõ `git add` rồi `git commit` thẳng trong terminal, giống hệt khoảng trống mà
  **F-011** mô tả và Gate 8 chỉ bịt được một nửa (Gate 8 chấm *subject*, không chấm *nội dung*).

**Lần thứ tư, vẫn cùng ngày: `30abf8f` nuốt dòng *In Progress* của BA-07 (2026-09-01).** Cùng cơ
chế với lần thứ ba, nên mục này chỉ ghi phần **mới**:

- Phiên BA-07 khai scope, chuyển dòng task của mình từ *Ready* xuống *In Progress* trong
  `work/backlog.md`, rồi bắt đầu viết §5. Một phiên song song (T-038) `git add work/backlog.md` và
  commit — **cả file**, gồm cả dòng vừa xuất hiện của BA-07.
- Commit ấy là `30abf8f`, subject **`BA-06: docs/product.md §4 chốt quy tắc giá và thanh toán`** —
  một subject **trùng chữ** với `3f579f9` đã có trước đó. Nên lịch sử nay có **hai** commit tên
  BA-06, và cái thứ hai chứa việc của **ba** task: phần còn lại của BA-06, phần backlog của T-038,
  và một dòng của BA-07.
- Cái khác so với lần thứ ba, và là lý do lần này vẫn đáng ghi: lần thứ ba nuốt **nội dung đang
  viết dở**; lần này nuốt **trạng thái của một task đang chạy**. Hậu quả nhẹ hơn — dòng vẫn đúng,
  vẫn nằm đúng chỗ — nhưng nó phá đúng thứ `work/backlog.md` dùng để trả lời câu *"ai đang làm
  gì"*: `git log` nói dòng ấy do phiên BA-06 tạo ra, trong khi phiên tạo ra nó là BA-07.
- ⇒ **Bốn lần trong hai ngày, ba lần trong một ngày.** Đường ra thứ nhất ở trên — *phiên thứ hai
  làm trong `git worktree` riêng* — nay không còn là một trong hai lựa chọn ngang nhau nữa: đường
  thứ hai (đọc `git diff --cached` trước khi commit) đã được viết ra sau lần thứ ba và **vẫn không
  chặn được lần thứ tư**, vì nó dựa vào việc người commit nhớ làm.

**Related task:**
T-035 (sửa `brief.sh`) · T-036 (phát hiện, ghi finding) · BA-04 (phiên gây ra sự cố lần 1, entry có
mục *Sự cố trong lúc chạy*) · **BA-06 (phiên bị nuốt ở lần 3, entry có mục *Sự cố trong lúc
chạy*)** · F-010 (scope quên dọn — cùng file, ngược chiều) · F-009 (commit theo scope sai) ·
**F-011 (cùng khoảng trống: commit gõ thẳng trong terminal không qua phiên nào)** · ADR-006
(Gate 7b + cảnh báo scope) · **ADR-008 (đã push thì sửa tiến — vì sao `ffc2997` không được viết
lại)**

**Status:**
Open

---

### F-015 — §4.9 vừa liệt kê lời giải của U-019 vừa nói U-019 CHƯA CHỐT, cách nhau 25 dòng

**Date:** 2026-09-02 · phát hiện khi chạy **BA-10** (đọc §4 để viết ADR-022)

**What happened:**
`docs/product.md` §4.9 mở đầu bằng bảng **ba nguồn đối soát**, trong đó dòng thứ ba là *"Tin nhắn
báo có — phần khách **chuyển khoản** *(chủ quán chốt 2026-09-01, trả lời U-019)*"*. Hai mươi lăm
dòng sau, cùng mục ấy kết thúc bằng: *"**Riêng phần VietQR thì buổi tối quán lấy gì ra đối chiếu
là câu CHƯA CHỐT** — xem **U-019**."*

Hai câu nói ngược nhau về **cùng một câu hỏi**, trong **cùng một mục**. Câu thứ hai là văn bản của
BA-06 (2026-09-01, viết khi U-019 còn mở); T-038 đóng U-019 trong ngày và thêm nguồn thứ ba vào
bảng, nhưng **không xoá câu cũ ở cuối mục**.

**Why it matters:**
Đây không phải lỗi trình bày. `docs/product.md` là owner của quy tắc nghiệp vụ (CLAUDE.md §2), và
một phiên mới đọc mục này từ dưới lên sẽ **mở lại U-019 như một câu đang treo** — đúng thứ CLAUDE.md
§3.5 và §7.2 (*"Follow the pointers"*) tồn tại để chặn. Nó cũng là **loại lỗi thứ hai của F-001**:
không phải hai file chép nhau, mà **một file giữ hai đời của cùng một sự thật**, và cái cũ không
chết vì không ai grep nó.

`grep -rn 'U-019'` bắt được ngay — cái thiếu là **thói quen chạy grep ấy sau khi đóng một unknown**,
thứ CLAUDE.md §7.2 đã yêu cầu thành lời nhưng không có cổng nào chấm.

**Fix (chưa làm — BA-10 không sửa):**
Xoá câu cuối §4.9 hoặc viết lại thành *"U-019 đã đóng 2026-09-01, xem bảng ba nguồn ở đầu mục"*.
BA-10 **không** tự sửa: `docs/product.md` §1–§8 là nội dung nghiệp vụ đã chốt, ngoài scope BA-10
(prompt `prompt/BA/09-decisions-assumptions-L2.md` → *Không được sửa*), và **BA-11** có sẵn luật
cho đúng ca này — *thấy sai/thiếu thì ghi finding và mở lại task BA tương ứng*.

**Related task:**
**BA-11** (diễn scenario §8 — sẽ đi qua đúng mục này) · BA-06 (viết câu gốc) · T-038 (đóng U-019,
để lại câu cũ) · **ADR-022** (lời chốt thật, `docs/decisions.md`) · F-001 (hai đời của một sự thật)

**Status:**
Open
