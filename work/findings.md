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
Open

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
