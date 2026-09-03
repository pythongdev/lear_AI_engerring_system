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

### F-015 — Đóng một unknown chỉ sửa chỗ câu trả lời rơi vào, không sửa chỗ câu hỏi được NHẮC TỚI

**Date:** 2026-09-02 · phát hiện khi chạy **BA-10** (đọc §4 và §6 để viết ADR-022 và ADR-017)

**Problem:**
`docs/product.md` đang giữ **ba** câu nói về một unknown **đã đóng** như thể nó còn mở — và **hai
trong ba** nói **ngược** với luật đã chốt ở mục khác của **chính file ấy**. Không phải lỗi trình
bày: đây là ba chỗ một phiên mới sẽ đọc và làm theo.

| # | Dòng | Câu đang có | Sự thật hôm nay |
|:--:|---|---|---|
| 1 | **§4.9**, dòng **1195–1196** | *"**Riêng phần VietQR thì buổi tối quán lấy gì ra đối chiếu là câu CHƯA CHỐT** — xem **U-019**."* | **U-019 đóng 2026-09-01**: nguồn đối chiếu là **tin nhắn báo có** — và nó nằm ngay **bảng ba nguồn ở đầu cùng mục ấy**, cách 25 dòng phía trên |
| 2 | **§6 dòng 7**, dòng **1564** | *"**Ranh giới trên còn mở:** `Hoàn thành → Huỷ` **hôm nay bị từ chối** — **U-022**"* | **U-027 đóng 2026-09-02**: `Hoàn thành → Huỷ` **hợp lệ**, và §5.2 dòng **1306** đã có đúng dòng ấy. Câu này nói **ngược** |
| 3 | **§6**, dòng **1588** | *"sửa được ở bất kỳ trạng thái nào (…); **không cần đường `Hoàn thành → Huỷ`**"* | Cùng lời chốt trên: đường ấy **có**, và quầy **chọn** giữa sửa và huỷ theo từng ca | 

**Cách đo lại, chạy được:** khoanh vùng thân tài liệu (mọi thứ **trước** mục *Đã có lời giải*), rồi
tìm các `U-XXX` đã đóng đứng cạnh ngôn ngữ còn-mở:

```bash
S=$(grep -n '^<a id="da-co-loi-giai">' docs/product.md | cut -d: -f1)
awk -v s=$S 'NR<s && /U-0[0-9][0-9]/ && (/CHƯA CHỐT/||/chưa chốt/||/còn mở/||/đang chờ/||/bị từ chối/)' docs/product.md
```

Lệnh này ra đúng ba dòng trên ngày 2026-09-02. Nó **không** báo động giả với những chỗ nhắc `U-XXX`
để **ghi công** một lời chốt (*"chủ quán chốt 2026-09-01, trả lời U-019"*) — kiểu nhắc ấy có hơn 40
chỗ trong file và đều **đúng**. Ranh giới là **thì của câu**, không phải sự có mặt của cái ID.

**Impact:**
Ba chỗ này hỏng theo hai kiểu khác nhau, và kiểu thứ hai đắt hơn nhiều:

- **Chỗ 1 — làm mở lại một câu đã đóng.** Phiên sau đọc §4.9 sẽ thấy một câu hỏi đang treo, trong
  khi brief nói *Unknowns rỗng*. Hai owner nói ngược nhau ⇒ hoặc phiên ấy **đi hỏi lại chủ quán một
  câu đã trả lời** (mất một lượt hỏi, và làm chủ quán mất tin vào việc mình đã nói), hoặc nó tin
  brief và **không bao giờ biết tài liệu đang sai**.
- **Chỗ 2 và 3 — dạy sai một luật nghiệp vụ.** `docs/product.md` là **owner** của quy tắc nghiệp vụ
  (CLAUDE.md §2). Một phiên System Design đọc §6 dòng 7 sẽ **dựng hàng rào chặn `Hoàn thành → Huỷ`**
  — đúng cái chủ quán vừa nói là **được phép**, và đúng thứ CLAUDE.md §3.5 cấm (*sản phẩm không tự
  dựng hàng rào ở chỗ chủ quán cố ý không đặt*). Sai theo chiều **chặt hơn thực tế**, tức là chiều
  không ai phàn nàn cho tới khi quán cần huỷ một đơn đã trao và phần mềm không cho.

**Vì sao không cổng nào bắt được, và đây là phần đáng giữ nhất:**

- **Gate 1b** chấm *đường dẫn có mở được không*, không chấm *câu này còn đúng không*. Cả ba dòng
  đều không chứa đường dẫn nào hỏng.
- **`scripts/brief.sh`** chỉ đọc **mục *Unknowns*** (ADR-007). Ba dòng trên nằm ở §4 và §6, ngoài
  vùng brief đọc — và brief đang **đúng** khi im lặng: U-019, U-022, U-027 đều đã đóng thật.
- **Chính vì mục *Unknowns* sạch** mà lỗi này sống được. Cổng duy nhất là câu CLAUDE.md §7.2 —
  *"sau khi đổi một fact, `grep -rn` cho cái gì trỏ tới nó"* — và nó là **luật dựa vào trí nhớ**,
  đúng loại `work/findings.md` **F-001** đã ghi là hỏng.

**Cơ chế sinh ra nó, viết ở dạng chung vì nó sẽ lặp lại:**
Đóng một unknown là **hai** việc, và phiên nào cũng chỉ nhớ việc thứ nhất.
1. Ghi **câu trả lời** vào chỗ nó thuộc về — `shop-facts.md`, bảng §5.2, mục *Đã có lời giải*. ✅
2. Sửa mọi chỗ **nhắc tới câu hỏi** — thường ở **mục khác**, do **task khác** viết, từ **ngày
   khác**. ❌

Ba chỗ trên là bằng chứng: câu trả lời U-019 rơi vào **§4.9 đầu mục** và §7.1, còn câu nhắc nằm ở
**§4.9 cuối mục** — cùng mục mà vẫn sót. U-027 rơi vào **§5.2** và §5.6, còn câu nhắc nằm ở **§6**,
do **BA-08** viết. Khoảng cách giữa hai chỗ càng lớn thì xác suất sót càng cao, và không ai đo được
khoảng cách ấy lúc đang sửa.

⇒ Đây là **loại thứ hai của F-001**: F-001 nói *hai file giữ hai bản của một sự thật*; đây là **một
file giữ hai đời của cùng một sự thật**, và đời cũ không chết vì không ai nhìn lại nó.

**Decision / Fix:**
**BA-10 cố ý không sửa.** §1–§8 của `docs/product.md` là nội dung nghiệp vụ đã chốt, nằm ngoài scope
prompt `prompt/BA/09-decisions-assumptions-L2.md` (mục *Không được sửa*). **BA-11** có sẵn luật cho
đúng ca này — *thấy sai/thiếu thì **không tự sửa**: ghi finding và mở lại task BA tương ứng* — nên
finding này là đầu vào của BA-11, không phải một việc bị bỏ quên.

Ba việc cụ thể cho phiên sửa:
1. Dòng 1195–1196: xoá, hoặc viết lại thành *"U-019 đã đóng 2026-09-01 — nguồn thứ ba là tin nhắn
   báo có, xem bảng đầu mục."*
2. Dòng 1564 (§6 dòng 7): bỏ *"Ranh giới trên còn mở"*, ghi `Hoàn thành ⇒ Huỷ` vào danh sách
   chuyển tiếp hợp lệ của dòng ấy, trỏ §5.2 và **ADR-017**.
3. Dòng 1588: đổi *"không cần đường `Hoàn thành → Huỷ`"* thành *"quầy chọn giữa **sửa** và **huỷ**
   theo từng ca"*.

**CẬP NHẬT 2026-09-03 (BA-11, hai lượt đọc context sạch của Gate 6) — bốn chỗ, không phải ba, và
ba dòng số ở trên đã chuyển nhà.**

Ba dòng `docs/product.md` 1195 / 1564 / 1588 nay sống ở file con của DOC-1 (2026-09-02). Địa chỉ
đọc được hôm nay, đã kiểm từng chỗ:

| # | Nhà hôm nay | Trạng thái |
|:--:|---|---|
| 1 | `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.9, dòng **313–314** | **còn nguyên** |
| 2 | `docs/product/0-ba/ban-hang/06-ngoai-le.md` §6.1 dòng 7, dòng **42** | **còn nguyên** |
| 3 | `docs/product/0-ba/ban-hang/06-ngoai-le.md` §6.2, dòng **66** | **còn nguyên** |
| **4** | `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.2, dòng **78–79** | **MỚI — F-015 chưa từng biết** |

**Chỗ thứ tư:** *"Với đơn khách **đã chọn trả trước** thì chưa rõ ai bấm xác nhận và vào lúc nào —
xem **U-005** ở *Unknowns*, **chưa ai trả lời**."* — **U-005 đóng 2026-08-31**: POS xác nhận
**lúc nhận tiền**, và người bấm là **người đứng quầy**. Lời giải nằm ở `shop-facts.md` §6.3, và
**hai mục khác của chính bộ tài liệu này** — §3.2.5 và §4.6 — đã viết đúng nó. Đây là chỗ **đắt
thứ hai** sau §6.1 dòng 7: nó nói *"chưa rõ ai bấm"* về đúng một thao tác **chạm tiền**, và nó
nằm ở §1, mục đầu tiên mọi phiên đọc.

**Và đây là phần đáng giữ nhất của lần cập nhật này: CÂU `awk` ĐO LẠI Ở TRÊN BẮT ĐƯỢC 2 TRONG 4.**
Chạy lại nó hôm nay trên `docs/product/0-ba/`, hai chỗ **lọt**, mỗi chỗ vì một lý do khác nhau — và
cả hai lý do đều sẽ lặp lại:

- **Chỗ 1 lọt vì XUỐNG DÒNG.** Câu ở §4.9 gói lại ở cột ~100 và cụm từ khoá bị cắt làm đôi:
  `…là câu CHƯA` ở cuối dòng 313, `CHỐT** — xem **U-019**` ở đầu dòng 314. `grep`/`awk` đọc theo
  **dòng**, nên không dòng nào chứa cả `CHƯA CHỐT` lẫn `U-019`. Tài liệu này gói dòng ở mọi đoạn
  văn ⇒ **mọi** bộ lọc theo dòng đều có xác suất này, không riêng câu trên.
- **Chỗ 3 lọt vì KHÔNG CÓ MÃ.** Dòng 66 viết *"không cần đường `Hoàn thành → Huỷ`"* — không mang
  `U-XXX` nào, nên vế `/U-0[0-9][0-9]/` loại nó ngay. Chính F-015 tìm ra chỗ này bằng **đọc**, không
  bằng lệnh; bảng trên vẫn kể nó như thể lệnh bắt được.
- **Chỗ 4 lọt vì TỪ KHOÁ THIẾU.** Nó viết *"chưa rõ"* và *"chưa ai trả lời"*, không viết
  `CHƯA CHỐT` / `còn mở` / `bị từ chối`. Thêm hai từ ấy vào danh sách thì nó hiện ra ngay.

⇒ **Bài học chung, và nó rộng hơn F-015:** một câu `grep` viết ra **cùng lúc** với ba ca đã biết
thì nó mô tả **ba ca ấy**, không mô tả **loại lỗi**. Nó sẽ báo xanh cho ca thứ tư — đúng hình dạng
`work/findings.md` **F-017**, chỉ khác là ở đây bộ lọc không rỗng mà **hụt**. Ai dựng cổng cho mục
này (xem đoạn dưới) thì đừng chép câu `awk` trên: nó là **cách đo một lần**, không phải một cổng.

**Bốn việc sửa nay thuộc `work/backlog.md` → BA-13** (mở 2026-09-03). BA-11 tìm ra chỗ thứ tư
nhưng **không sửa chỗ nào**: §1–§7 nằm trong mục *Không được sửa* của
`prompt/BA/10-acceptance-scenarios-L2.md`. Vì sao gom vào **một** task mới thay vì mở lại BA-01,
BA-06 và BA-08: cả ba task ấy **đúng vào ngày chúng chạy**, và bốn câu trên hỏng **về sau**, do
T-038 · T-042 · T-043 đóng unknown mà không quét chỗ nhắc tới câu hỏi — tức đúng cái cơ chế mục
này mô tả. Đẩy ba dòng `Done` về `Ready` là ghi nợ vào tên lượt không gây ra nợ.

**Đây là lần đo thứ HAI** (lần một: BA-10, 2026-09-02). Đoạn dưới viết lúc mới có lần một; nó nói
*"nếu nó lại ra kết quả sau một lượt đóng unknown khác, đó là lần hai và lúc ấy hãy dựng cổng"*.
Điều kiện ấy **nay đã đủ** — và lần hai còn nặng hơn lần một vì nó cho thấy chính công cụ đo cũng
hụt. ⇒ Dựng cổng là việc của **BA-13**, và cổng ấy phải bắt được **cả bốn** chỗ trên, kể cả chỗ
xuống dòng và chỗ không mang mã.

**Chưa đề xuất cổng mới.** CLAUDE.md §3.8: một luật/hook/test chỉ được dựng sau khi cùng một vấn đề
đã trả giá **hai** lần. Đây là lần **một** được đo. Lệnh `awk` ở trên đủ để lần sau đo lại trong 5
giây; nếu nó lại ra kết quả sau một lượt đóng unknown khác, đó là lần hai và lúc ấy hãy dựng cổng
(chỗ tự nhiên: thêm một bước vào `scripts/check-links.sh`, hoặc một `scripts/*.test.sh`).

**ĐÃ SỬA VÀ ĐÃ DỰNG CỔNG — 2026-09-03, BA-13.** Cả bốn chỗ nay nói đúng lời chốt: §1.2 ghi
*người đứng quầy bấm lúc nhận tiền* (U-005) · §4.9 ghi *đối chiếu bằng tin nhắn báo có* (U-019) ·
§6.1 dòng 7 và §6.2 ghi `Hoàn thành` ⇒ `Huỷ` là **hợp lệ** (U-027).

**Lượt đo thứ ba, và lần này bằng máy:** `scripts/check-doc-status.sh` (Gate 1c, `docs/decisions.md`
**ADR-032**), chạy ở **mọi** lượt qua `scripts/gate.sh`. Kết quả đo hai chiều, dán từ lần chạy thật:

- **Trên cây trước khi sửa** (bản `git archive HEAD`, cùng script): **ĐỎ, 8 báo động** — trong đó
  đủ **cả bốn** chỗ của mục này (`01-actors-pham-vi.md:77` · `04-gia-thanh-toan.md:311` ·
  `06-ngoai-le.md:42` · `06-ngoai-le.md:65`) cộng hai dòng bảng của **F-021**.
- **Trên cây sau khi sửa:** **XANH** — 1213 khối, 29 mã `U-XXX`, 21 chuyển tiếp hợp lệ.

**Hai chỗ câu `awk` cũ để lọt, nay bắt được — và bắt bằng đường khác, không bằng cách thêm từ khoá:**

- **Chỗ 1 (xuống dòng).** Script gộp một đoạn văn / một ô bảng / một gạch đầu dòng thành **một
  khối** rồi mới chấm, nên cụm bị cắt đôi giữa hai dòng lại liền. `check-doc-status.test.sh` ca 2b
  kiểm đúng điều đó: nó khẳng định một `grep` theo dòng **vẫn mù** với ca ấy trong khi cổng bắt được.
- **Chỗ 3 (không mang mã).** Không phép nào của cổng đi tìm nó bằng `U-XXX`. Phép C so **chuỗi
  nguyên văn của từng chuyển tiếp trong bảng vòng đời §5** với những mệnh đề mang lời phủ định —
  không dùng mã định danh nào. Ca 4b của bộ test khẳng định báo động ấy **không** chứa `U-0` nào.

**Một phép đã viết rồi bỏ, ghi lại vì nó là bài học chứ không phải rác:** *"mọi ngôn ngữ còn-mở
phải trỏ tới một thứ đang mở"* — đúng về lý, chạy thật thì ra **11 báo động, cả 11 đều giả**
(*"danh sách quyết định chưa rõ/giả định"*, *"Câu hỏi chưa có lời giải đi vào `99-unknowns.md`"*).
Một cổng kêu sai 11 lần là cổng bị gỡ (**F-018**). ⇒ Vế cứu cả ba phép còn lại là câu hỏi thứ hai:
*khối này có chỗ nào nói lời chốt không* — có thì nó đang **kể lại**, không đang **khẳng định**.
Thiếu vế ấy, mọi mục lịch sử của repo đều đỏ.

**Cái cổng này KHÔNG làm được, viết ra để đừng ai tin quá:** nó là heuristic ngôn ngữ, không phải
chứng minh. Nó không thay bước `grep -rn` của CLAUDE.md §7.2 — nó bắt lại phần bước ấy quên.

**LẦN THỨ BA CỦA CÙNG CƠ CHẾ, XẢY RA NGAY TRONG LƯỢT ĐANG DỌN NÓ — và cổng mới cố ý không bắt
được.** Lượt đọc context sạch thứ ba (Gate 6, BA-13, 2026-09-03) xác nhận cả năm chỗ đã sửa
đúng, cộng đúng toàn bộ tiền — rồi tắc ở một chỗ **mới**: mục *Lỗ hổng* và ô mục 5 của
`docs/product/0-ba/ban-hang/08-scenario.md` vẫn là **ảnh chụp trạng thái trước khi sửa**, nên
người đọc sạch *"tin §8 rồi đi sửa lại những chỗ đã đúng"*.

Đúng cơ chế mục này mô tả, chỉ dịch lên một tầng: chỗ **nhắc tới** một sự thật không được quét khi
sự thật ấy đổi — và lần này chỗ nhắc tới là **chính tài liệu nghiệm thu ghi lại lỗi**. Sửa một
finding thì phải quét cả nơi finding ấy được **kể lại**, không chỉ nơi lỗi **nằm**.

**Vì sao `check-doc-status.sh` im ở đây, và đó là lựa chọn chứ không phải lỗ thủng:** cổng ấy có
vế *"khối này có nói lời chốt không"* và một file ignore, cả hai tồn tại **để** một câu hỏng được
trích dẫn làm bằng chứng vẫn im. Một biên bản kể lại lỗi và một tài liệu đang mắc lỗi trông giống
hệt nhau với máy; phân biệt được hai thứ ấy là việc của người. ⇒ Cách chống duy nhất đang có là
**viết banner nói thẳng mục này là biên bản**, đặt ở **đầu** mục chứ không ở cuối — bản đầu tiên
của lượt này đặt banner **sau** các bảng, và người đọc sạch **đọc bảng trước, không thấy banner**.

**Related task:**
**BA-13** (nhận cả **bốn** việc sửa + dựng cổng — mở 2026-09-03) · **BA-11** (lượt đo thứ hai, tìm
ra chỗ thứ tư và chỗ hụt của câu `awk`; không sửa gì) · **BA-01** (viết câu §1.2) ·
**BA-08** (viết §6.1 dòng 7 và §6.2) · **BA-06** (viết câu §4.9) · **T-038** (đóng U-019, để lại chỗ 1) · **T-042**/**T-043** (đóng U-022 rồi U-027, để lại
chỗ 2 và 3) · **ADR-017** và **ADR-022** (`docs/decisions.md` — lời chốt thật) · **F-001** (hai đời
của một sự thật) · **F-004** (đọc rộng hơn chữ — vì sao U-027 phải hỏi riêng)

**Status:**
Fixed — 2026-09-03 (BA-13): bốn chỗ đã sửa, cổng Gate 1c dựng xong (ADR-032)

---

### F-016 — `shop-facts.md` tự khai là "điểm cuối, không trỏ đi đâu", trong khi nó trỏ đi năm chỗ

**Date:** 2026-09-02 · phát hiện khi chạy **DOC-3** (lượt L3 chia việc) — đếm lại pointer nhóm A

**Problem:**
Banner của `master_plan/shop-facts.md` (dòng 8–11) viết:

> *"Không cần mở thêm tài liệu nào khác, và file này cũng **không trỏ đi đâu** — nó là điểm cuối."*

CLAUDE.md §2 nói lại đúng lời ấy: *"It is deliberately self-contained and link-free: it points
nowhere, everything points at it."*

Thực tế file có **năm** đường trỏ ra ngoài, tất cả về `docs/product.md`:

| Dòng | Câu | Loại |
|---:|---|---|
| **501** | `docs/product.md` → *Unknowns* | pointer sống |
| **791** | *"chỗ `docs/product.md` §4.6 viết sai **trong ngày 2026-09-01**"* | câu **lịch sử** |
| **798** | *"cái đổi là món, số suất hoặc tuỳ chọn (`docs/product.md` §5.2)"* | pointer sống |
| **810** | *"vòng đời đơn có thêm dòng `Hoàn thành → Huỷ` (`docs/product.md` §5.2)"* | pointer sống |
| **955** | *"ghi ở `docs/product.md` §7"* | pointer sống |

Mâu thuẫn này **có sẵn từ trước DOC-3**, không do việc tách file sinh ra. DOC-3 chỉ là lần đầu có
người đếm.

**Impact:**
Hai cái hỏng, và cái thứ hai mới là cái đắt.

- **Banner nói dối về hình dạng của chính nó.** Ai đọc banner rồi tin rằng sửa file này không kéo
  theo gì sẽ **không grep ngược** khi đổi một dữ kiện — đúng thứ CLAUDE.md §7.2 bắt phải làm
  (*"sau khi đổi một fact, `grep -rn` cho cái gì trỏ tới nó"*).
- **Bốn pointer sống đang trỏ vào BẢN LƯU.** ADR-014 cấm mọi thứ trỏ về `docs/product.md`, nhưng
  vì file cũ còn tồn tại nên **Gate 1b vẫn xanh**. `shop-facts.md` là **owner của mọi dữ kiện
  quán** — chỗ mà một câu sai lan xa nhất.

**Vì sao không cổng nào bắt được:**
Gate 1b hỏi *"đường dẫn này mở được không"* — cả năm đều mở được, vì bản lưu vẫn nằm đó. Không
cổng nào hỏi *"file này có được phép trỏ đi không"*, và cũng **không nên dựng** một cổng như thế
bây giờ: CLAUDE.md §3.8 bắt chờ tới lần hỏng thứ hai.

**Decision / Fix:**
Tách làm hai, và **không sửa banner cho khớp**:

1. **Bốn pointer sống (501, 798, 810, 955)** → chuyển sang `docs/product/` trong **DOC-3a**, theo
   luật ánh xạ. Dòng **791 ở lại** — nó kể một chuyện đã xảy ra vào một ngày cụ thể.
2. **Banner vẫn sai sau DOC-3a** (dòng 791 còn đó). Câu đúng phải nói được ý thật:
   *"không dữ kiện nào ở đây phụ thuộc file khác"* — khác với *"không có ký tự `/` nào"*. Sửa
   banner là **việc riêng**, chưa mở task: nó chạm CLAUDE.md §2 (đang do **DOC-4** giữ), và sửa
   hai chỗ bằng hai task khác nhau là cách chắc chắn để chúng nói ngược nhau.

**Related task:**
DOC-3a (bốn pointer) · banner: chưa mở task, xem xét cùng DOC-4

**Status:**
Open

---

### F-017 — Câu `grep` "chứng minh đã xong" trong prompt lọc rỗng ở máy này, nên nó luôn báo xanh

**Date:** 2026-09-02 · phát hiện ngay lượt đầu chạy **DOC-3**, khi con số đếm ra vô lý

**Problem:**
`prompt/maintenance/13-pointer-migration-L3.md` đưa lệnh này làm **bằng chứng đã xong**, và
`prompt/maintenance/15-architecture-into-system-design-L3.md` (DOC-5) dùng lại đúng khuôn ấy:

```bash
grep -rn "docs/product\.md" --include="*.md" --include="*.sh" . \
  | grep -v '^\./work/' | grep -v '^\./prompt/maintenance/'
```

Ba bộ lọc `^\./…` **không khớp gì cả**. `grep` trên máy này là **ugrep 7.8.4**, và nó in đường
dẫn **không có tiền tố `./`** (`work/backlog.md:220:…`, không phải `./work/backlog.md:220:…`).

Đo thật, 2026-09-02:

| Lệnh | Kỳ vọng | Thực tế |
|---|---:|---:|
| tổng số dòng trỏ `docs/product.md` | 595 | **595** |
| *"phần thật sự phải chuyển"* (đã lọc) | ~239 | **595** |

Hai con số bằng nhau — bộ lọc không bỏ được dòng nào.

**Impact:**
Đây là **cổng nghiệm thu của cả DOC-3 và DOC-5**, và nó hỏng theo chiều nguy hiểm nhất: **luôn có
kết quả**, không bao giờ báo lỗi.

- Trước khi làm, nó **thổi phồng việc**: 595 thay vì 239. Prompt DOC-3 gốc chia nhóm theo con số
  563 và ước lượng *"~225 dòng"* cho luật ánh xạ — hai con số không nhất quán với nhau, và chênh
  lệch ấy **chính là dấu vết của cái bug này** ở lần đo trước.
- Sau khi làm, nó **không bao giờ chứng minh được đã xong**: lệnh vẫn trả về hàng trăm dòng
  `work/**` mà đề bài đã nói là **không phải việc phải làm**. Phiên chạy DOC-3a/3b/3c sẽ hoặc kết
  luận mình thất bại trong khi đã xong, hoặc — nhiều khả năng hơn — **đi sửa cả `work/**`**, tức
  làm hỏng đúng phần lịch sử mà CLAUDE.md §5 cố ý bảo vệ.

**Bài học chung, vì nó sẽ lặp:**
Một lệnh `grep` viết trong prompt là **hợp đồng nghiệm thu**, nhưng khác mọi cổng khác trong repo
này, **không ai chạy thử nó trước khi giao**. `scripts/*.sh` có `scripts/*.test.sh` chấm; câu lệnh
nằm trong khối ``` của một file `.md` thì **không cổng nào chấm** — Gate 1b còn cắt bỏ khối ```
trước khi rà. Lệnh nghiệm thu phải được **chạy một lần lúc viết prompt**, và **dán kết quả vào
chính prompt** làm mốc; con số dán kèm là thứ duy nhất tố cáo được một bộ lọc rỗng.

**Decision / Fix:**
Dùng bản **portable**, khớp cả có lẫn không có tiền tố `./`:

```bash
grep -rn 'docs/product\.md' --include='*.md' --include='*.sh' . \
  | grep -vE '^(\./)?(work/|prompt/maintenance/|docs/product\.md:|docs/product/)'
```

- Ba prompt con `13a` · `13b` · `13c` đã dùng bản này và **dán số đo kèm ngày**.
- ✅ **`15-…-L3.md` đã vá 2026-09-03 (T-046)** — mục *Acceptance* và mục *Verify* của nó nay dùng
  bản portable, có dán số đo kèm ngày (**48** sau lọc / **142** chưa lọc) và một câu chỉ cách đọc
  kết quả: hai lệnh ra bằng nhau ⇒ bộ lọc lại rỗng. Đây là lượt sửa mà gạch đầu dòng dưới đây gọi
  tên. DOC-5 vẫn **chưa được phép chạy** (chủ repo chốt HOÃN 2026-09-03), nhưng cổng nghiệm thu của
  nó thì đã chạy được.
- `prompt/maintenance/13-…-L3.md` còn giữ bản hỏng. Không sửa trong lượt này:
  `prompt/maintenance/**` là sổ lịch sử (CLAUDE.md §5) và prompt 13 đã được thay thế trên thực tế
  bởi ba prompt con. **DOC-5 thì phải sửa trước khi chạy** — nó chưa được chạy lần nào. *(Đã làm,
  2026-09-03, T-046 — xem gạch đầu dòng trên.)*

**Lặp lại lần hai, cơ chế khác — đo 2026-09-03 khi chạy DOC-3b:** *Verify* bước 4 của
`prompt/maintenance/13b-pointer-nhom-B-L1.md` viết
`git diff -- prompt/BA/ | grep -E '^[-+] *(grep|awk|…)' | grep -v '10-acceptance\|12-production'`.
Bộ lọc cuối **không thể khớp**: dòng thân của `git diff` chỉ mang nội dung, **không mang tên
file** — tên file nằm ở dòng `diff --git`, mà `grep -E '^[-+]…'` đã loại. Nên câu ấy in cả 8 dòng
lệnh hợp lệ của hai file còn sống và báo đỏ một việc đã làm đúng. Bản chạy được là lọc ở **đối số
của `git diff`**, không lọc ở đầu ra:
`git diff -- $(ls prompt/BA/*.md | grep -v '10-acceptance\|12-production') | grep -E '^[-+] *(grep|awk|sed|wc|cat)'` — rỗng.
⇒ Đúng bài học ở trên, lần thứ hai: **một câu `grep` trong prompt là hợp đồng nghiệm thu mà không
ai chạy thử trước khi giao.** Ba lần khác cơ chế, cùng một nguyên nhân.

**Related task:**
DOC-3a · DOC-3b (lặp lại lần hai, xem trên) · DOC-3c · **DOC-5** (còn giữ bản hỏng, sửa trước khi chạy)

**Status:**
Open

---

### F-018 — Prompt dùng số đếm động như một invariant, và biến kết quả đo thành điều kiện nghiệm thu

**Date:** 2026-09-03 · phát hiện khi chạy **DOC-3a** (chuyển pointer nhóm A), lặp lại ở DOC-3b,
DOC-3c và DOC-5/T-046 · viết lại 2026-09-03 theo yêu cầu chủ repo: **rút gọn và tổng quát hoá**,
thôi ghi nhật ký từng lần lệch số vào chính finding.

**Problem:**
Một số prompt maintenance dùng **kết quả đếm tại một thời điểm** như thể đó là một sự thật bất
biến: *"nhóm A còn **đúng 14 dòng**"* · *"**đúng 9 dòng, 1 dòng ở lại**"* · *"sửa **10** dòng, giữ
nguyên **20** dòng"* · *"**99 dòng**"* trong *Context* / *Scope* / *Deliverables*.

Các con số ấy ra từ `grep`, nhưng quyết định thật lại phụ thuộc vào **ngữ nghĩa và thì của câu**:

- một dòng có cùng đường dẫn chưa chắc thuộc tập cần chuyển;
- một dòng mang nhiều `§N` có thể không ánh xạ được vào một file con duy nhất;
- tổng có thể đúng trong khi **chỗ cắt** giữa các nhóm sai;
- tập dòng còn thay đổi tiếp sau ngày prompt được viết;
- nếu phạm vi đếm gồm cả `work/` hoặc `prompt/maintenance/`, con số còn tăng chỉ vì đang có người
  ghi chép **về chính task ấy**.

Nên có **ba loại sai khác nhau, cùng một nguyên nhân**:

| # | Loại | Hình dạng |
|:--:|---|---|
| 1 | **Tổng đúng, phân hoạch sai** | `grep` ra đúng tổng, nhưng phân loại *chuyển / ở lại* sai |
| 2 | **Tổng sai theo thời gian** | repo tiếp tục đổi sau ngày đo |
| 3 | **Đo sai phạm vi** | bộ lọc rộng hơn phạm vi việc ⇒ con số đo **hoạt động ghi chép**, không đo việc còn lại |

Bằng chứng: ở **DOC-3a** prompt ghi 14 dòng, thực tế nhóm A có **15** — `quality/invariants.md`
dòng 492 là một **câu lịch sử** (*"một câu sai từng nằm ở `docs/product.md` §4.6 trong ngày
2026-09-01"*) nên phải **ở lại**; đổi đường dẫn ở đó là khai rằng câu sai ấy nằm trong một file
**chưa tồn tại** vào ngày đó. Ở **DOC-3b** và **DOC-3c**, tổng đúng còn chỗ cắt sai. Đến **DOC-5**,
cả tổng chưa lọc lẫn tổng sau bộ lọc đều đã khác con số trong prompt cũ.

**Impact:**
Một con số nằm trong mục **Acceptance** không chỉ sai — nó **ra lệnh** cho phiên thực thi. Khi số
ấy sai, đường rẻ nhất để "về đúng N" là **sửa dữ liệu** cho khớp, thay vì sửa đúng theo ngữ nghĩa:

```text
grep → N
N → Acceptance
Acceptance → sửa dữ liệu cho bằng N
```

Cổng nghiệm thu khi ấy có thể buộc phiên làm việc phá **chính cái invariant mà prompt được dựng ra
để bảo vệ** — đúng chuyện suýt xảy ra ở DOC-3a với dòng 492.

**Root cause:**
`grep` chỉ xác định được **sự có mặt của một chuỗi**. Nó không xác định được thì của câu · ý nghĩa
của tham chiếu · dòng lịch sử hay dòng hiện hành · phân hoạch *chuyển / giữ* · một tham chiếu áp
cho một `§N` hay nhiều `§N` · phạm vi logic thật của task. Ngoài ra, **một count chỉ có nghĩa khi
đi kèm phạm vi đo + bộ lọc + thời điểm đo**.

Điều này nối dài ba bài học đã có: **F-003** — `Exactly N` chỉ hợp lệ khi N là một quyết định /
invariant ổn định, không phải bản tóm tắt của mình; **F-015** — ranh giới là **thì của câu**, không
phải sự xuất hiện của cái ID; **F-017** — `grep` có thể ra rỗng hoặc sai nếu bộ lọc không mô tả
đúng tập cần đo.

**Decision / Fix:**

1. **Không dùng `Exactly N` cho tập có thể đổi hoặc cần đọc ngữ nghĩa.** Không viết
   *"còn đúng 14 dòng"* / *"đúng 1 dòng ở lại"* / *"sửa đúng 10 dòng"*. Nếu N chỉ là kết quả của
   một lần khảo sát thì viết:

   ```text
   Measurement:
   - Đo ngày YYYY-MM-DD, với filter <...>, kết quả là N.
   - N chỉ là baseline của lần đo này.
   - Nếu phát hiện thêm phần tử, không sửa dữ liệu để ép về N;
     phải ghi nhận phần tử mới và quyết định nó thuộc tập nào.
   ```

2. **Acceptance kiểm tra quyết định, không kiểm tra ảnh chụp của count** — ví dụ: mọi tham chiếu
   *hiện hành* trỏ đúng đích · tham chiếu *lịch sử* giữ nguyên · mỗi dòng đa-`§` xử lý theo luật đã
   xác định · không item nào ngoài phạm vi bị sửa · không item nào trong phạm vi bị bỏ sót. Cần
   count để hỗ trợ kiểm tra thì count là **chẩn đoán**, không phải mục tiêu phải đạt.

3. **Mọi count dùng làm mốc phải ghi đủ xuất xứ:**

   ```text
   Measured at: YYYY-MM-DD
   Scope: <tập file/thư mục>
   Filter: <điều kiện grep/query>
   Count: N
   Purpose: baseline / diagnostic
   ```

   Một count chưa có phạm vi/bộ lọc rõ ràng thì không được dùng làm Acceptance.

4. **Tổng đúng không suy ra được phân hoạch đúng.** Phải xác định từng item bằng một luật kiểm
   chứng được: `Total: 9 · Decision: xét từng item trong 9 xem nó chuyển hay ở lại`, **không phải**
   `Exactly 9 items; exactly 1 stays`.

5. **Count phải được đo trên đúng phạm vi việc.** Không dùng count bao gồm các thư mục nhật ký
   (`work/`, `prompt/maintenance/`) nếu task không xử lý chúng — bộ lọc phải loại chúng ra ngay từ
   đầu, nếu không thì chính việc viết finding/report sẽ làm đổi con số đang đo.

6. **Các prompt cùng một lượt đo phải coi count cũ là cũ cho tới khi đo lại.** Trước khi chạy một
   prompt có count: (1) xem ngày đo · (2) xem phạm vi/bộ lọc · (3) đếm lại nếu dữ liệu đã đổi ·
   (4) không ép dữ liệu về con số ghi trong prompt.

**Bài học chung — luật rút ra:**

> **A count is evidence of a measurement, not an invariant, unless the count itself is a deliberate
> decision.**

Áp vào prompt:

> **Khi prompt ghi một N do đo đếm, phải ghi ngày đo + phạm vi/bộ lọc, và coi N là baseline. Nếu
> xuất hiện N+1, xử lý phần tử mới theo luật, không sửa dữ liệu chỉ để đưa count về N.**

CLAUDE.md §7.2 đã có đúng luật này cho **tài liệu nghiệp vụ** (F-003); mục này nói rằng nó là luật
cho **prompt** nữa, và ở prompt thì đắt hơn — một con số trong *Acceptance* là thứ phiên sau **phải
làm cho bằng**.

**Giá phải trả:**
Luật số 2 ở trên (dòng đa-`§` thì **trỏ tới thư mục**, giữ nguyên mọi `§N`) có một cái giá, ghi ra
để không ai phát hiện lại: `scripts/check-links.sh` chỉ nhận đường dẫn có **đuôi biết trước**
(`.md`, `.sh`, …), nên một đường **kết thúc bằng `/` bị bỏ qua hẳn** — không đỏ, mà cũng **không
được chấm**. Mỗi dòng chuyển từ file sang thư mục là một dòng rời khỏi tầm của Gate 1b. Đừng dựng
cổng mới cho việc này: CLAUDE.md §3.8 bắt chờ tới lần hỏng thứ hai.

**Không mở cổng mới cho chính F-018.** Đây là lỗi của **cách viết và cách duyệt prompt**; chỉ khi
cùng cơ chế hỏng ấy tái diễn **sau khi luật trên đã được áp dụng** thì mới đáng nâng thành gate
(CLAUDE.md §3.8).

**Related task:**
DOC-3a · DOC-3b · DOC-3c · T-046 / DOC-5 · F-003 (*"exactly N"*) · F-015 (thì của câu) ·
F-017 (bộ lọc `grep` không mô tả đúng tập cần đo)

**Status:**
Open

---

### F-019 — Tách file đẻ ra một tiêu đề THỨ HAI mang cùng chữ, và câu nghiệm thu đếm chữ ấy hụt mất nó

**Date:** 2026-09-03 · phát hiện khi chạy **DOC-3b**, lúc chạy thử dòng lệnh đã đổi đường dẫn của
prompt BA-12

**Problem:**
`prompt/BA/12-production-control-L2.md` nghiệm thu bằng một câu đếm chữ:

```bash
grep -n 'Ba lát cắt' <đích>      # phải rỗng
```

Ý nó là: BA-12 thêm §3.4 ⇒ tiêu đề §3 phải đổi từ *"Ba lát cắt nghiệp vụ"* sang *"bốn"*.
Acceptance 12 của chính prompt ấy nói rõ chỗ phải đổi là **một** chỗ: *"Tiêu đề `## 3.` … đã đổi
sang bốn lát cắt"*.

Đo thật 2026-09-03, sau khi đổi đích sang file con:

| Đích | `grep -n 'Ba lát cắt'` |
|---|---:|
| `docs/product.md` (bản lưu) | **2** dòng — `## 3.` (306) và một câu văn (313) |
| `docs/product/0-ba/ban-hang/03-lat-cat.md` | **3** dòng — `# §3 —` (1) · `## 3.` (7) · câu văn (14) |

Chỗ thứ ba là **tiêu đề H1 do DOC-1 sinh ra khi tách file** (`# §3 — Ba lát cắt nghiệp vụ`). Nó
không phải nội dung nghiệp vụ, nó là **tên file viết ra thành tiêu đề** — nên không prompt nào có
trước lượt tách biết nó tồn tại.

**Nguyên nhân gốc:**
Câu nghiệm thu đo **một chuỗi ký tự**, trong khi thứ nó muốn chấm là **một tiêu đề cụ thể**
(`## 3.`). Hai thứ ấy chỉ trùng nhau chừng nào cụm chữ xuất hiện đúng một lần — và lượt tách file
phá vỡ đúng điều kiện đó. Sau lượt tách, cùng một cụm chữ nằm ở ba tầng khác hẳn nhau — H1 do cơ
chế tách sinh ra · tiêu đề mục nghiệp vụ · câu văn — mà `grep` không phân biệt được tầng nào. Chỗ
hỏng nằm ở **cách viết câu nghiệm thu**, không ở BA-12 và cũng không ở lượt tách.

**Impact:**
Ai chạy BA-12 sẽ làm **đúng** Acceptance 12 (đổi `## 3.`), rồi thấy câu nghiệm thu **vẫn không
rỗng**. Hai đường ra đều xấu: hoặc kết luận mình chưa xong trong khi đã làm đúng bài, hoặc sửa
con số/câu lệnh cho khớp — tức là để lại một H1 nói *"Ba lát cắt"* trên một file có **bốn**.
Tiêu đề file và nội dung file nói khác nhau là đúng con bug ADR-014 dựng `docs/product/` để tránh.

Không cổng nào bắt được: Gate 1b chỉ hỏi **đường dẫn có mở được không**, còn *tiêu đề có khớp nội
dung không* thì không có cổng nào — và cả câu lệnh này lẫn Acceptance 12 đều nằm trong khối ``` `
của một file `.md`, vùng `scripts/check-links.sh` cắt bỏ trước khi rà.

**Bài học chung, vì nó sẽ lặp:**
Tách một tài liệu thành nhiều file **nhân đôi mọi tiêu đề mục ở tầng trên cùng**: mục §N nay có
`# §N — <tên>` (tiêu đề file) *và* `## N. <tên>` (tiêu đề mục cũ), bên cạnh những chỗ vốn đã mang
cùng tên — câu văn mô tả và mọi dòng trỏ chéo về mục ấy. Mọi câu nghiệm thu đếm **chữ trong tiêu
đề** đều lệch sau lượt tách, theo hướng **khó thấy nhất** — lệnh vẫn chạy, vẫn ra kết quả, chỉ ra
sai. ⇒ Đừng suy rằng `grep '<chữ trong tiêu đề>'` bằng với *"tiêu đề cần đổi"*; sau một lượt tách
file, **chạy thử** mọi câu nghiệm thu đếm tiêu đề, đừng chỉ đổi đường dẫn cho chúng.

**Decision / Fix:**
- **Không sửa Acceptance 12 trong lượt này.** DOC-3b chỉ được đổi đường dẫn (Acceptance 6 của
  `prompt/maintenance/13b-pointer-nhom-B-L1.md`: *"không câu chữ nào quanh pointer bị viết lại"*),
  và prompt 13b nói thẳng: lệch thì **ghi finding, đừng lặng lẽ sửa con số cho khớp**.
- **Ai chạy BA-12 đọc mục này trước:** đổi **ba** chỗ trong
  `docs/product/0-ba/ban-hang/03-lat-cat.md` — dòng 1 (H1), dòng 7 (`## 3.`), dòng 14 (câu văn) —
  chứ không phải một chỗ như Acceptance 12 viết. Đo 2026-09-03, kiểm lại cùng ngày vẫn đúng ba
  dòng ấy. **Số dòng không phải hợp đồng** — tra lại bằng chính câu `grep` trên, đừng tin ba con
  số này.
- **DOC-5 đã chạy xong 2026-09-03 và KHÔNG gặp chuyện này.** Kiểm lại cùng ngày: nó chuyển
  `docs/architecture.md` bằng `git mv`, giữ nguyên tên file và giữ nguyên §1–§14 — **dọn chỗ, chứ
  không tách file** — nên không H1 nào được sinh ra (`work/backlog.md`, dòng `Done` của DOC-5).
  Dự báo cũ ở dòng này **sai chỗ chứ không sai luật**: nó bắn vào một *task*, trong khi thứ đẻ ra
  tiêu đề thứ hai là **lượt tách**. Câu này vẫn chờ **lượt tách thật tiếp theo**, task nào cũng thế.
- **Đừng dựng cổng mới** (CLAUDE.md §3.8) — chạy thử câu nghiệm thu sau một lượt tách là đủ. Chỉ
  khi có thêm vài finding cùng loại mới bàn tới chuyện chuẩn hoá nghiệm thu theo **cấu trúc tiêu
  đề** thay cho **đếm chữ**.

**Related task:**
DOC-3b (phát hiện) · **BA-12** (chịu hậu quả, chưa chạy) · **DOC-5** (đã xong 2026-09-03, là
lượt CHUYỂN file nên không dính) ·
DOC-1 (lượt tách sinh ra H1) · **T-046** (đã trỏ prompt 15 về mục này để phiên chạy DOC-5 đọc
trước) · F-017 (câu `grep` trong prompt không ai chạy thử) ·
F-018 (con số trong prompt biến thành mệnh lệnh)

**Status:**
Open

---

### F-020 — Ba khối `work/scope.txt` bị COMMIT và không ai gỡ được, nên Gate 3 mở toang từ 2026-08-31

**Date:** 2026-09-03 · phát hiện khi chạy **DOC-5**, lúc đọc `DECLARED SCOPE` trong brief thấy in
ra những file mà task này không hề khai

**Problem:**
`CLAUDE.md` §6 viết: *"`work/scope.txt` is working state, not a deliverable — do not commit
patterns."* Nhưng `git log -- work/scope.txt` cho thấy commit **`12c77f8` (T-031)** đã đưa **ba
khối pattern** vào lịch sử: của **BA-04**, **T-027** và **T-031**. Cả ba task ấy xong từ
2026-08-31, và chính ba khối ấy tự dặn *"GỠ NGAY SAU KHI commit"* — không ai gỡ.

Mười pattern thừa đang mở cho **mọi** task chạy sau đó:

```text
docs/product.md · quality/invariants.md · work/backlog.md · scripts/brief.sh
scripts/brief.test.sh · work/findings.md · CLAUDE.md
master_plan/prompt-fullstack.md · docs/architecture.md · docs/decisions.md
```

**Impact:**
Gate 3 là cổng bắt *"thay đổi đúng nhưng chạm file không được phép"*. Danh sách trên phủ gần hết
những file quan trọng nhất của repo — `CLAUDE.md`, `docs/decisions.md`, `quality/invariants.md`,
`work/backlog.md`. Với mọi task từ 2026-08-31 tới nay, **Gate 3 vẫn in `OK` nhưng gần như không
còn chấm gì**. Nó hỏng theo đúng chiều F-017: **luôn xanh**, không bao giờ kêu.

Đo trong lượt DOC-5, 2026-09-03: chạy lại Gate 3 với `SCOPE_FILE` trỏ vào **chỉ scope của DOC-5**
ra `OK` — nên lượt này không mượn gì của ba khối cũ. Nhưng đó là may, không phải do cổng chặn.

Đếm chính xác ở `HEAD` cùng ngày: **13 dòng pattern, 10 đường khác nhau** (`work/backlog.md` lặp
ba lần, `work/findings.md` hai lần). Và ba khối ấy **đã bắt đầu mục**: DOC-5 chuyển
`docs/architecture.md` sang `docs/product/1-system-design/` cùng ngày, nên dòng allow mang tên cũ
trong khối T-031 nay **khớp không cái gì**. Một pattern chết nằm trong một cổng đang chạy — và
khác `scripts/check-links.ignore` (dòng ngoại lệ hết hạn thì gate ĐỎ), `scripts/check-scope.sh`
**không có cơ chế nào tố cáo một pattern không còn khớp gì**. Đó là chỗ đường 2 và đường 3 hơn hẳn
đường 1: chúng làm lỗi này không tái diễn được, còn đường 1 chỉ dọn một lần.

**Và đây là chỗ luật tự khoá chính nó — phần đáng đọc nhất của mục này:**
Vì các pattern **đã nằm trong git**, xoá chúng tạo ra một thay đổi **tracked** trên
`work/scope.txt`; muốn sửa thật thì phải **commit `work/scope.txt`** — đúng cái §6 cấm, và đúng
cái Gate 7b bắt (nó kêu khi `work/scope.txt` xuất hiện trong khối commit). Một phiên tuân thủ luật
**không có đường hợp lệ nào** để dọn. File đang ở trạng thái mà bộ luật hiện tại không gỡ được, và
mỗi phiên mới lại đọc nó như scope đang có hiệu lực.

Đây cũng là lý do lượt DOC-5 **không tự ý xoá ba khối ấy**: `work/findings.md` **F-014** đã ghi
đúng cái giá của việc một phiên xoá scope hộ người khác.

**Decision / Fix:**
**Chốt 2026-09-03 — chủ repo chọn ĐƯỜNG 2.** Nguyên văn quyết định: `work/scope.txt` **ở lại trong
git** như một file trạng-thái-làm-việc chỉ mang **trạng thái nền**; bản **đã commit** của nó chỉ
được chứa comment; **pattern là trạng thái phiên chạy và không bao giờ được commit**; và Gate 3 có
thêm một phép chấm trạng thái nền, đỏ khi bản đã commit mang pattern đang hiệu lực.

Hai đường kia bị loại, ghi lại lý do để không ai mở lại: **đường 1** chỉ dọn một lần, mà "ngoại lệ
một lần" này đã là **lần thứ ba** (`work/backlog.md` T-016 ghi hai lần trước). **Đường 3** là đường
duy nhất khiến lỗi không tái diễn được, nhưng nó phải đẻ ra `work/scope.txt.example` — một bản sao
thứ hai của cùng nội dung, đúng **F-001** — cộng một bước chép file ở mỗi clone mà không gì ép
được, đúng giới hạn `docs/decisions.md` **ADR-010** đã chấp nhận cho `install-hooks.sh`.

**Luật viết thành hình bất biến, không thành câu dặn dò:**

> Bản **đã commit** của `work/scope.txt` chỉ chứa comment. Pattern là trạng thái của phiên đang
> chạy, không bao giờ đi vào git.

Ba điểm dưới đây là chỗ hình bất biến ấy dễ bị thi hành sai. Cả ba đều đã có tiền lệ trong repo,
nên chúng là **ràng buộc**, không phải gợi ý.

**1. "Trạng thái nền" định nghĩa bằng PARSER, không bằng một file mẫu thứ hai.**
Cám dỗ là viết `EXPECTED="# Scope của task…"` hoặc dựng một `work/scope.baseline.txt` canonical rồi
so từng byte. Đừng: đó là **bản sao thứ hai của cùng nội dung** (F-001) và nó khoá luôn phần
comment — mà comment *phải* sửa được, bằng chứng là khối cảnh báo *"BA PHIÊN ĐANG CHẠY SONG SONG
(2026-08-31)"* đang nằm trong file nay đã sai sự thật. Định nghĩa không-phải-đoán đã có sẵn:
**chính parser của `scripts/check-scope.sh`**. Một dòng là pattern ⟺ bỏ phần từ `#` trở đi và cắt
khoảng trắng xong vẫn khác rỗng. Trạng thái nền ⟺ **đếm pattern bằng 0**. Chính xác tuyệt đối,
không có chỗ nào để gate "đoán pattern nào chết", và **ngữ nghĩa pattern vẫn chỉ có một chủ** —
đúng lập luận `docs/decisions.md` **ADR-006** đã dùng khi thêm chế độ `--match`.

**2. Chấm ở ĐÂU — chấm nhầm chỗ là sinh ra vòng khoá thứ hai.**
Vị ngữ ngây thơ *"`git show HEAD:work/scope.txt` phải sạch"* khoá đúng cái lượt đi dọn: Gate 3 chạy
**trước** commit, nên trong lượt T-047 `HEAD` vẫn mang ba khối cũ ⇒ gate đỏ ⇒ Stop hook chặn lượt ⇒
không bao giờ giao nổi khối commit làm cho nó hết đỏ. Vị ngữ đúng là:

> ĐỎ khi `HEAD:work/scope.txt` mang pattern **mà cây làm việc VẪN còn giữ**.

Dọn xong là xanh ngay trong chính lượt ấy; lần commit bậy tiếp theo vẫn đỏ và ở lại đỏ cho tới khi
có người gỡ — đúng cơ chế `scripts/check-links.ignore` (dòng ngoại lệ hết hạn thì gate đỏ). Ca còn
hở duy nhất — `HEAD` bẩn nhưng cây đã sạch, tức nợ chưa được commit đi — in thành `note:` kèm câu
*"đưa `work/scope.txt` vào khối commit của task này để xoá nợ"*, không đỏ.

**3. Gate 7b KHÔNG được có "ngoại lệ cho commit migration".**
Một cổng không xác minh được *loại* của commit; nó sẽ phải tin một chữ trong báo cáo, và chữ ấy
tốn đúng bằng chữ `ádg` (F-011). Thay vào đó, luật 3 của `scripts/check-commit-block.sh` đổi **vị
ngữ**: thôi hỏi *"`work/scope.txt` có nằm trong khối không"*, chuyển sang hỏi *"khối này có đưa
**pattern** vào `work/scope.txt` không"* — đúng phép chấm ở điểm 1, áp lên nội dung file sẽ được
`git add` (tức bản trong cây làm việc). Khi ấy:

```text
lượt migration      scope.txt chỉ-comment  → Gate 7b im  → hợp lệ THEO LUẬT
sửa comment sau này scope.txt chỉ-comment  → Gate 7b im  → hợp lệ, không cần ai cho phép
commit pattern      scope.txt có pattern   → Gate 7b kêu → đúng cái nó sinh ra để bắt
```

Không có miễn trừ nào phải nhớ, và **một vị ngữ dùng cho cả hai cổng** — hai bản so khớp sẽ trôi
khỏi nhau (F-001).

**Hệ quả về THỨ TỰ trong lượt T-047, phải làm đúng:** vì Gate 7b chấm bản trong cây, T-047 phải
**xoá sạch pattern — kể cả khối của chính nó — TRƯỚC khi viết khối commit**. Đó cũng đúng là
`CLAUDE.md` §7.3 (dọn scope khi task xong). Phần cuối lượt vì thế chạy ở trạng thái "chưa khai
scope ⇒ Gate 3 bỏ qua": đó là trạng thái đúng của một task đang kết thúc, không phải lỗ hổng.

**Pattern chết và pattern lặp: `note:`, KHÔNG phải FAIL.**
Đây là chỗ mục này đi ngược đề xuất ban đầu, có lý do: một task tạo file mới **khai đường dẫn của
file đó vào scope trước khi file tồn tại**, nên pattern ấy khớp-không-cái-gì ở mọi lượt trung gian.
"Chết ⇒ đỏ" sẽ chặn đúng việc tạo file mới, và **đỏ vì lý do sai dạy người ta bỏ qua gate**
(ADR-003 — cùng lý do file chưa track chỉ được `note:`). Khác `check-links.ignore`: ở đó đích
**phải** tồn tại ngay lúc này mới hợp lệ, còn scope hợp lệ khi trỏ vào thứ sắp có. Pattern lặp cũng
vô hại về ngữ nghĩa, chỉ là vệ sinh ⇒ cũng `note:`. **Chỉ hình bất biến ở điểm 2 mới làm gate đỏ.**

**Việc T-047 phải làm — thứ tự có ràng buộc:**

1. Sửa **`scripts/check-commit-block.sh`** (luật 3 → vị ngữ mới) và **`scripts/check-scope.sh`**
   (thêm phép chấm trạng thái nền + hai dòng `note:`) **trước tiên**. Hai cổng chạy từ **cây làm
   việc** chứ không từ `HEAD`, nên sửa xong là có hiệu lực ngay trong lượt ấy — đây chính là cách
   gỡ khoá mà không cần ai miễn trừ cho ai.
2. Đưa `work/scope.txt` về chỉ-comment: xoá ba khối cũ (BA-04, T-027, T-031), khối của chính T-047,
   và mọi khối khác còn sót. Trước khi xoá khối của người khác, **kiểm bằng `git log` rằng task chủ
   đã commit xong** — F-014 ghi cái giá của việc xoá hộ. Nhân tiện xoá luôn khối cảnh báo
   *"BA PHIÊN ĐANG CHẠY SONG SONG (2026-08-31)"*: nó nói về ba task đã xong.
3. **`scripts/check-scope.test.sh` — file này CHƯA TỒN TẠI**, phải tạo (`scripts/verify.sh` tự chạy
   mọi `scripts/*.test.sh`). Bốn ca tối thiểu cho Gate 3: nền → PASS · `HEAD` có pattern còn nguyên
   trong cây → FAIL · pattern chết → `note:` + exit 0 · pattern lặp → `note:` + exit 0. Cộng hai ca
   vào `scripts/check-commit-block.test.sh`: khối mang `scope.txt` chỉ-comment → im · khối mang
   `scope.txt` có pattern → kêu.
4. Sửa `CLAUDE.md` cho luật hết mâu thuẫn: **§6** (câu *"do not commit patterns"* → hình bất biến),
   **§6.1** (gạch đầu dòng *"`work/scope.txt` is never in the block"* nay sai — đúng phải là
   *"không bao giờ mang pattern vào khối"*), **§5** mục 1 và mục 4 (mô tả hai cổng), **§3.4** và
   **§7.3**. Chạy `grep -rn 'scope\.txt'` rồi đọc từng chỗ, đừng sửa theo trí nhớ (§7.2).
5. **ADR bắt buộc** trong `docs/decisions.md`: đường 2 đổi một luật của §6, và §3 xếp "có quyết định
   thiết kế" là L2 ⇒ phải có ADR. Nó ghi cả ba đường và lý do loại hai đường kia.
6. Chạy `./scripts/gate.sh` + phép thử riêng ở bước 6 của entry T-047 (chứng minh cổng đã sống lại,
   không chỉ dán lại dòng `OK`).
7. **Một commit duy nhất**, subject nói rõ đây là *scope-state migration* chứ không phải scope của
   một task thường.

**Mục này không đóng bằng một lần dọn file.** Dọn file là bước 2 trong bảy bước; thứ làm nó khỏi
tái diễn là **quyền sở hữu + hình bất biến + hai cổng thi hành**. F-020 chỉ chuyển sang *Fixed* khi
cả bảy bước xong.

**Related task:**
T-047 (mở cùng ngày, **hết bị chặn từ 2026-09-03** — đường đã chọn) · F-010 và F-014 (cùng file,
cùng chỗ đau: nhiều phiên một `scope.txt`) · F-017 (cùng hình dạng hỏng: cổng luôn xanh) ·
F-001 (vì sao không dựng file baseline thứ hai) · F-011 (vì sao cổng không được tin một chữ trong
báo cáo) · `CLAUDE.md` §3.4, §5, §6, §6.1, §7.3 · ADR-003 (đỏ vì lý do sai) · ADR-006 (Gate 7b,
ngữ nghĩa pattern một chủ) · ADR-010 (giới hạn của bước cài tay mỗi clone)

**Status:**
Open — đường đã chốt 2026-09-03, chờ T-047 thi hành

---

### F-021 — Bảng tổng hợp `docs/decisions.md` nói NGƯỢC thân của chính nó về hai giả định đã bị thay

**Date:** 2026-09-03 · phát hiện khi chạy **BA-11** (tick mục 6 của cổng chất lượng BA)

**Problem:**
`docs/decisions.md` mở đầu bằng một **bảng tổng hợp** — chỗ mọi phiên nhìn trước khi đọc thân. Hai
dòng của bảng ấy nói ngược thân của chính file:

| Dòng bảng | Bảng nói | Thân mục nói |
|---|---|---|
| **GĐ-01** (dòng 52) | `**Giả định**` · rủi ro **TRUNG BÌNH** — đang sống | *"~~Hai người cùng thao tác trên một bàn~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**"*, `Trạng thái: Superseded` |
| **GĐ-05** (dòng 56) | `**Giả định**` · rủi ro **TRUNG BÌNH** — đang sống | *"~~Thao tác nhầm ngoài ca 'bấm nhầm một mẻ'~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**"*, `Trạng thái: Superseded` |

Ba dòng cùng bảng — GĐ-02, GĐ-03, GĐ-04 — **đã** được sửa thành `**Đã thay** 2026-09-02`. Hai dòng
này bị bỏ sót ở lượt **T-045**, lượt thay chính hai giả định ấy.

Và đoạn văn **ngay dưới bảng** đi theo hai dòng sai: *"Hai giả định còn lại đều **TRUNG BÌNH** và
cả hai chờ ai đó gặp ca thật"* — trong khi phần mở đầu mục *Giả định BA*, cách đó ~1830 dòng, viết
*"**CẢ NĂM mục đã bị thay trong ngày 2026-09-02**, và mục này nay **không giữ giả định nào còn
hiệu lực**"*. Cùng một file, hai câu trả lời cho câu hỏi *"còn giả định nào đang sống không?"*.

**Impact:**
- **Câu hỏi mà bảng này tồn tại để trả lời là câu hỏi nó trả lời sai.** Không ai đọc 2000 dòng ADR;
  người ta đọc bảng đầu file. Một phiên hỏi *"còn giả định nào chặn không"* sẽ nhận **hai** giả
  định đang sống thay vì **không**.
- **Nó chặn đúng một cổng.** Mục 6 của cổng chất lượng BA (`master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`
  §12) là *"có danh sách quyết định chưa rõ/giả định"*. Danh sách **có**, nhưng nó nói hai câu khác
  nhau tuỳ chỗ đọc ⇒ BA-11 để trống mục ấy (`docs/product/0-ba/ban-hang/08-scenario.md`, mục
  *Cổng chất lượng BA*).
- **Sai theo chiều CHẶT HƠN thực tế** — chiều không ai phàn nàn: một phiên System Design sẽ né hai
  chỗ đã có luật thật, hoặc đi hỏi lại chủ quán một câu chủ quán đã trả lời ngày 2026-09-02.

**Cùng một cơ chế với `work/findings.md` F-015, khác chỗ đau.** F-015: đóng một **unknown** thì sửa
chỗ câu trả lời rơi vào, quên chỗ **nhắc tới** câu hỏi. Ở đây: thay một **giả định** thì sửa
**thân** mục, quên **mục lục** trỏ vào thân ấy. Cùng một hình: *cập nhật nơi nội dung sống, bỏ quên
nơi nội dung được liệt kê.* Khác một điểm quan trọng — F-015 rải qua nhiều file, còn ở đây **hai
chỗ mâu thuẫn nằm trong CÙNG một file**, cách nhau 1830 dòng.

**Vì sao không cổng nào bắt được:**
Gate 1b chấm đường dẫn mở được hay không; hai dòng bảng không chứa đường dẫn nào hỏng.
`scripts/brief.sh` in *LATEST DECISIONS* bằng cách đọc các mục `ADR-XXX`, không đọc dòng `GĐ-XXX`
của bảng. Không cổng nào so **một dòng chỉ mục** với **thân mục nó trỏ tới** — và đó là loại kiểm
tra rẻ: cùng một mã định danh, hai chỗ, một phép so chuỗi.

**Decision / Fix:**
Sửa thuộc **BA-10** (`docs/decisions.md` là owner của nó); `docs/decisions.md` nằm trong mục
*Không được sửa* của `prompt/BA/10-acceptance-scenarios-L2.md` nên **BA-11 không tự sửa**. Ba việc,
gom vào **BA-13**:

1. Dòng 52 và 56 của bảng: đổi cột trạng thái thành `**Đã thay** 2026-09-02`, đúng hình ba dòng
   GĐ-02/03/04 ngay cạnh; cột rủi ro gạch ngang như thân mục đã làm.
2. Đoạn văn dưới bảng: *"Hai giả định còn lại đều TRUNG BÌNH…"* → **cả năm đã bị thay**, không còn
   giả định nào đang sống. Giữ câu *"Hai mục CAO từng có đã được thay bằng quy tắc thật chứ không
   phải bị hạ mức"* — câu ấy vẫn đúng và vẫn đáng đọc.
3. **Kiểm ngược, không sửa theo trí nhớ** (CLAUDE.md §7.2): `grep -n 'GĐ-0' docs/decisions.md` rồi
   đọc **từng** chỗ — bảng, thân, mục mở đầu *Giả định BA*, và mọi chỗ ngoài file
   (`docs/product/0-ba/ban-hang/06-ngoai-le.md` §6.2 đã nói *"cả năm giả định nay đã bị thay"*,
   tức nó **đúng** và bảng mới là chỗ sai).

**Chưa đề xuất cổng riêng cho mục này.** CLAUDE.md §3.8: một cổng chỉ dựng sau khi cùng một vấn đề
trả giá **hai** lần. Đây là lần **một** cho hình *"mục lục lệch thân"*. Nhưng nó là họ hàng gần của
F-015 (lần **hai** cùng ngày) ⇒ nếu BA-13 dựng cổng cho F-015, hãy hỏi cổng ấy có phủ luôn ca này
không: cả hai đều là *"một mã định danh xuất hiện ở hai chỗ với hai trạng thái khác nhau"*.

**ĐÃ SỬA — 2026-09-03, BA-13, và câu hỏi ở đoạn trên có câu trả lời: CÓ, cổng ấy phủ luôn ca này.**
`scripts/check-doc-status.sh` phép **D** đọc từng `GĐ-XXX` ở bảng tổng hợp rồi so với dòng
`Trạng thái:` trong thân mục nó trỏ tới — đúng phép so chuỗi rẻ mà mục này gọi tên. Chạy trên bản
`git archive HEAD` trước khi sửa: **đỏ, đúng hai dòng 52 và 56**, mỗi dòng nêu cả số dòng của thân.

Ba việc của mục *Decision / Fix* đã làm đủ: hai dòng bảng nay ghi `**Đã thay** 2026-09-02 → I-018`
với cột rủi ro gạch ngang, đúng hình ba dòng GĐ-02/03/04 bên cạnh · đoạn văn dưới bảng nay nói
**cả năm** đã bị thay, khớp mục mở đầu *Giả định BA* cách đó ~1830 dòng · và `grep -n 'GĐ-0'` dẫn
tới **một chỗ thứ ba không nằm trong ba việc ấy**: `docs/product/99-unknowns.md` cũng đang kể
GĐ-01 và GĐ-05 là *"chờ ai đó gặp ca thật"*. Đã sửa cùng lượt — đúng bước *follow the pointers*
của CLAUDE.md §7.2, và là bằng chứng nhỏ rằng bước ấy vẫn cần người làm, cổng không thay được.

Hàng tiêu đề của bảng cũng đổi: `**Giả định — chưa có lời chốt**` → `**Giả định BA — cả năm ĐÃ
ĐƯỢC THAY bằng quy tắc thật, 2026-09-02**`. Nó không nằm trong ba việc trên, nhưng để nguyên thì
một hàng tiêu đề vẫn dạy đúng cái sai mà cả mục này viết ra để dọn.

**Related task:**
**BA-13** (nhận việc sửa — mở 2026-09-03) · **BA-10** (owner của `docs/decisions.md`) ·
**T-045** (lượt thay GĐ-01 và GĐ-05, để lại hai dòng bảng) · **BA-11** (lượt phát hiện) ·
**F-015** (cùng cơ chế, khác chỗ đau) · **F-001** (hai đời của một sự thật)

**Status:**
Fixed — 2026-09-03 (BA-13); phép D của Gate 1c nay chấm lại ở mọi lượt

---

### F-022 — Hai mục ĐÃ CHỐT trả lời khác nhau cho cùng một câu hỏi, và chỉ lộ ra khi DIỄN một scenario

**Date:** 2026-09-03 · phát hiện khi chạy **BA-11**, qua **hai lượt đọc context sạch** (Gate 6)

**Problem:**
Ba chỗ trong `docs/product/0-ba/ban-hang/` mà **hai mục đã chốt** cho **hai** câu trả lời khác nhau
cho **một** câu hỏi cụ thể. Không mục nào sai một mình; cái sai chỉ tồn tại **giữa** chúng.

| # | Câu hỏi | Mục A nói | Mục B nói | Owner |
|:--:|---|---|---|---|
| 1 | Phiên bàn mở **lúc nào**? | §3.1.1 bước 1: *"Khách ngồi vào một bàn đang trống. **Hệ thống mở** cho bàn đó một phiên bàn"* | §5.3 bảng dòng 1 + §3.1.2: *"khách ngồi vào bàn trống **VÀ lượt gọi đầu tiên được tạo**"* | **BA-03** (§3.1) |
| 2 | **Ai** bấm *"đã ra bàn"* cho một đơn **giao tận nơi**? | §5.4 bảng: ***người đứng quầy*, trên POS** | §3.2.2 + §5.2: người có mặt lúc trao hàng là ***nhân viên quán* đi giao**, và chính người ấy bấm *đã giao* + *đã thu tiền* | **BA-07** (§5) |
| 3 | *"Nâng giá một cái bánh nhân thường từ 4.000 lên 5.000"* là thao tác gì? | Ô bảng `shop-facts.md` §4.2 có sẵn ba ô cho ba mức nhân ⇒ nâng ô *Thịt thường* ⇒ suất giò mới **29.000** | §4.1 + §4.6 luật 2: giá gốc **là ô Chay**, hai ô kia là **phụ thu** ⇒ phụ thu không đổi ⇒ suất giò mới vẫn **25.000** | **BA-05** (§3.3.3) và `quality/invariants.md` **I-009** |

**Chỗ 3 nặng nhất, vì nó chạm tiền và nằm trong ví dụ có số DUY NHẤT của §3.3.** §3.3.3 tự khai
*"đây là chỗ duy nhất §3.3 có số"*, và `quality/invariants.md` I-009 chép đúng thao tác ấy vào mục
*Verification* — tức **kịch bản kiểm invariant tiền của cả repo** dựa trên một câu cho hai kết quả.
Thêm một hệ quả không ai viết ra: nâng riêng ô *Thịt thường* lên 5.000 làm nó **bằng** ô *Thịt
nhiều* (cũng 5.000), tức **xoá mất bậc phụ thu lượng nhân +1.000** của `shop-facts.md` §4.4 — sau
lần đổi giá ấy, *thường* và *nhiều nhân* cùng giá, và không ai chốt điều đó.

**Impact:**
- **Chỗ 1** — một bàn trống có được phép mang một phiên **đang mở** hay không, hai mục hai câu trả
  lời. Đọc theo §3.1.1 thì mọi bàn có khách đều có phiên, kể cả bàn chưa gọi gì; đọc theo §5.3 thì
  không. Nó chạm `quality/invariants.md` **I-001** (*một bàn thuộc nhiều nhất một phiên chưa thanh
  toán*) và chạm cách đếm bàn trống ở quầy.
- **Chỗ 2** — nếu đọc theo §5.4 thì người đứng quầy phải bấm *"đã ra bàn"* cho một suất **đang ở
  nhà khách**, thứ quầy không nhìn thấy; nếu đọc theo §3.2.2 thì §5.4 thiếu một người kích hoạt.
  Vì §5.5 buộc **mọi** việc phải `Đã ra bàn` **trước** khi đơn `Hoàn thành`, đọc sai chỗ này là
  **đơn giao tận nơi không bao giờ `Hoàn thành` được**, hoặc quầy bấm khống một mốc.
- **Chỗ 3** — sai **âm thầm** đúng kiểu §3.3 mô tả: hai người đọc cùng một câu, ra hai số tiền, và
  không có lỗi nào nổ ra. Nó còn là kịch bản kiểm của I-009 ⇒ một bài kiểm viết theo nó có thể
  **xanh trong khi sản phẩm sai**, hoặc ngược lại.

**Vì sao ba vòng rà trước không bắt được — phần đáng giữ nhất của mục này:**
Cả ba chỗ **lọt qua mọi cách đọc theo mục**, vì mỗi mục **tự nó đúng và tự nó đầy đủ**. Chỉ khi
**diễn một scenario** — đi từ đầu đến cuối và bắt mỗi bước phải trỏ về một mục — thì hai mục mới bị
đặt cạnh nhau và chỗ lệch mới hiện ra. BA-01…BA-10 đọc và viết **từng mục**; BA-11 là lượt đầu
tiên đi **ngang** qua chúng.

⇒ **Luật rút ra, rộng hơn ba chỗ này:** *một bộ tài liệu mà mọi mục đều đúng vẫn có thể mâu thuẫn,
và cách duy nhất tìm ra là bắt nó diễn một ca chạy xuyên nhiều mục.* Đó chính là lý do §12 kế hoạch
gốc đặt ba scenario **sau cùng** chứ không rải vào từng task — và là bằng chứng cổng ấy có tác
dụng thật, không phải nghi lễ.

**Và một điểm về cách nghiệm thu:** cả ba chỗ đều do **lượt đọc context sạch** (Gate 6) tìm ra,
không do phiên viết tài liệu tìm ra. Phiên viết đã đọc cả tám file nên nó **tự vá chỗ lệch trong
đầu** mà không nhận ra mình đang vá. Người chỉ được đọc tài liệu thì không vá được — nó tắc, và
chỗ tắc là bằng chứng. Gate 6 không phải thủ tục thừa.

**Decision / Fix:**
**BA-11 không sửa chỗ nào** — §1–§7 nằm trong mục *Không được sửa* của
`prompt/BA/10-acceptance-scenarios-L2.md`. Ba việc, gom vào **BA-13**:

1. **Chỗ 1 — §3.1.1 bước 1 theo §5.3**, vì hai mục (§5.3 và §3.1.2) nói cùng một câu và chỉ §3.1.1
   nói khác. Viết lại bước 1 thành *"khách ngồi vào bàn trống, và phiên mở khi lượt gọi đầu tiên
   của bàn ấy được tạo"*. **Đừng sửa ngược** — sửa §5.3 theo §3.1.1 là chọn phe thiểu số.
2. **Chỗ 2 — hỏi trước khi viết.** Đây **không** phải chỗ chọn giữa hai câu đã có: chủ quán chốt
   ngày 2026-09-01 rằng *người đứng quầy* bấm cả hai mốc (U-021), và ca **đơn giao tận nơi** không
   nằm trong câu hỏi lúc ấy. ⇒ Ghi thành một **`U-XXX` mới** ở `docs/product/99-unknowns.md` đúng
   hình dạng ADR-007, đừng tự suy. Suy hộ ở đây là dựng một luật chủ quán chưa nói (CLAUDE.md §3.5).
3. **Chỗ 3 — viết lại ví dụ §3.3.3 và mục *Verification* của I-009 thành một thao tác CHỈ CÓ MỘT
   NGHĨA.** `docs/product/0-ba/ban-hang/08-scenario.md` Scenario 3 đã làm sẵn cách viết ấy: *nâng
   **giá gốc (giá chay)** của một cái bánh cuốn từ 3.000 lên 4.000* ⇒ phụ thu §4.4 không đổi ⇒ suất
   giò nhân thường mới = 9.000 + 4 × 5.000 = **29.000**, đúng con số §3.3.3 đã chốt, và bậc *nhiều
   nhân* vẫn còn (6.000). Sửa **cả hai** chỗ trong cùng một lượt — để lệch một chỗ là đẻ ra đúng
   con bug này lần nữa.

**Không mở finding cho một chỗ thứ tư đã xét và loại:** mốc `Đã ra bàn` của đơn mang đi là lúc
**trao** chứ không phải lúc **đóng gói** — §5.4 viết gộp *"đóng gói và trao"*, nhưng ghép với §5.5
thì chỉ còn một cách đọc, nên đó là chỗ **suy ra được**, không phải chỗ hở. Ghi ra đây để lượt sau
khỏi mở lại nó.

**ĐÃ XỬ — 2026-09-03, BA-13. Hai chỗ sửa, một chỗ KHÔNG sửa, và chỗ không sửa mới là chỗ đúng.**

- **Chỗ 1 — sửa §3.1.1 bước 1 theo §5.3**, đúng phe đa số. Bước 1 nay đọc *"khách ngồi vào bàn
  trống, và phiên mở khi lượt gọi đầu tiên của bàn ấy được tạo"*, kèm một câu hệ quả mà không mục
  nào từng viết ra: **một bàn có khách ngồi mà chưa gọi gì thì vẫn ở `Trống`**, và quầy đếm nó là
  bàn trống. Câu ấy là thứ phiên System Design cần để đếm bàn, và nó chính là chỗ hai cách đọc cũ
  cho hai kết quả khác nhau.
- **Chỗ 3 — sửa §3.3.3 và mục *Verification* của I-009 TRONG CÙNG một lượt**, đúng cảnh báo của
  mục này. Cả hai nay viết *"nâng **giá gốc (giá chay)** của một cái bánh cuốn từ 3.000 lên
  4.000"* — thao tác **chỉ có một nghĩa**, ra đúng 29.000, và bậc phụ thu *nhiều nhân* vẫn còn.
  §3.3.3 được thêm hẳn một đoạn nói **vì sao** không viết *"nâng giá bánh nhân thường"*: giá một
  cái bánh nhân thường **không phải một ô sửa được** mà là *giá gốc + phụ thu*. `08-scenario.md`
  Scenario 3 bước 2 đã viết đúng từ trước ⇒ nay **ba chỗ** nói cùng một câu.
- **Chỗ 2 — KHÔNG sửa, và đó là kết quả đúng.** Mở **U-031** ở `docs/product/99-unknowns.md`
  (*Đang mở*), đúng hình dạng ADR-007, và `./scripts/brief.sh` in nó ra ở mục *OPEN UNKNOWNS* —
  tức mọi phiên sau đều thấy. Ghi thêm dấu vào **cả hai** chỗ đang nói ngược nhau: một gạch đầu
  dòng ở §5.4 (*NGOẠI LỆ CHƯA CÓ LỜI CHỐT — đơn giao tận nơi*) và một câu trong ô bảng §5.2. Trước
  lượt này, hai mục nói hai câu khác nhau **mà không mục nào biết mình đang tranh chấp**; nay cả
  hai đều trỏ về cùng một câu hỏi đang mở, nên phiên đọc bất kỳ mục nào cũng dừng lại đúng chỗ.
- **Cổng cho chỗ 3? Không có, và đây là chỗ đáng nhớ nhất của mục này.** `check-doc-status.sh`
  (ADR-032) bắt được *một mã hai trạng thái*; nó **không** bắt được *một câu tiếng Việt có hai
  cách đọc ra hai số tiền*. Chỗ ấy chỉ lộ ra khi có người **cộng lại tiền** — và nó đã lộ ra đúng
  như thế, ở lượt đọc context sạch của Gate 6. Đừng ai kết luận rằng cổng mới phủ cả F-022.

**Related task:**
**BA-13** (đã làm 2026-09-03: chỗ 1 và 3 sửa, chỗ 2 thành **U-031**) · **BA-03** (chỗ 1) · **BA-07** (chỗ 2) ·
**BA-05** (chỗ 3) · **BA-11** (lượt phát hiện) · `quality/invariants.md` **I-001**, **I-009** ·
**F-015** và **F-021** (cùng ngày, cùng họ: hai chỗ của một sự thật lệch nhau) ·
**F-004** (đọc rộng hơn chữ chủ quán nói — vì sao chỗ 2 phải hỏi chứ không suy)

**Status:**
Fixed — 2026-09-03 (BA-13): chỗ 1 và chỗ 3 đã sửa; chỗ 2 chuyển thành **U-031**, đang chờ chủ quán
