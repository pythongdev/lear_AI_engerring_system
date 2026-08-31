# Business Invariants

Invariants are statements that must always remain true.

## Template

### I-XXX — Short title

**Invariant:**  
A condition that must always hold.

**Why:**  
Business or technical reason.

**Verification:**  
How the invariant is tested or checked.

## Examples

- Order total equals the sum of applicable item totals, discounts, and surcharges.
- Existing order snapshots do not change when a product price changes.
- Invalid order state transitions are rejected.
- Cache loss does not cause source-of-truth data loss.

---

## Invariants

Mỗi invariant ghi task nào phát hiện ra nó và ngày. Verification phải viết được cách kiểm — một
mục Verification để trống là invariant chưa dùng được.

### I-001 — Một bàn thuộc nhiều nhất một phiên chưa thanh toán

**Invariant:**
Tại mọi thời điểm, một bàn thuộc **nhiều nhất một** phiên chưa thanh toán. Phiên ở trạng thái *chờ
thanh toán* vẫn tính là chưa thanh toán, nên lượt gọi mới của bàn đó đổ vào chính phiên ấy chứ
không mở phiên thứ hai. Quan hệ này **không đối xứng**: một phiên gắn được **một hoặc nhiều** bàn
khi khách ghép bàn (`master_plan/shop-facts.md` §6.16, chủ quán chốt 2026-08-31), nhưng một bàn
không bao giờ nằm trong hai phiên còn mở.

**Why:**
Bàn có hai phiên mở cùng lúc thì một trong hai sẽ được đóng mà không ai nhìn tới — tiền của phiên
kia không bao giờ được thu. Trạng thái *chờ thanh toán* là chỗ dễ vỡ nhất: nhìn thì như đã xong,
nhưng khách vẫn gọi thêm được (`docs/product.md` §3.1.4, `master_plan/shop-facts.md` §6.1).

**Verification:**
Kịch bản nghiệp vụ: mở phiên cho bàn 5 → gọi một lượt bằng QR tại bàn → quầy bấm tính tiền (phiên
sang *chờ thanh toán*) → gửi thêm một đơn QR tại bàn 5. Kỳ vọng: đơn mới vào **chính** phiên đang
chờ thanh toán, và số phiên chưa thanh toán của bàn 5 vẫn bằng 1. Kịch bản ghép: ghép bàn 4 với
bàn 5 ⇒ **một** phiên gắn hai bàn, và mỗi bàn vẫn đếm được đúng **một** phiên chưa thanh toán —
không bàn nào lên hai. Kiểm lại con số này sau các bước
4, 9 và 11 của `docs/product.md` §3.1.1. Đối soát cuối ngày (`shop-facts.md` §6.10): không bàn nào
xuất hiện trên hai hoá đơn chưa đóng cùng lúc.

*Phát hiện ở BA-03, 2026-08-31.*

### I-002 — Tính tiền theo phiên bàn, không theo lượt gọi

**Invariant:**
Tổng tiền của một phiên bàn bằng tổng của **mọi** đơn thuộc phiên đó, và một phiên sinh ra đúng
**một** hoá đơn. Nhiều lượt gọi tại cùng một bàn — bằng bất kỳ tổ hợp nào của QR tại bàn và Staff
POS — không bao giờ tách thành nhiều hoá đơn. Với **nhóm bàn ghép**, "cùng một bàn" đọc thành
"cùng một phiên": lượt gọi từ bàn 4 và lượt gọi từ bàn 5 của cùng nhóm vẫn ra **một** hoá đơn
(`master_plan/shop-facts.md` §6.16).

**Why:**
Tách hoá đơn theo lượt gọi là **thu thiếu tiền**: lượt gọi thêm lúc quầy đã bắt đầu thu rất dễ rơi
ra ngoài lần thu duy nhất. `shop-facts.md` §6.1 gọi đây là lỗi tiền nguy hiểm nhất của luồng tại
bàn; §6.9 thì buộc mỗi khoản tiền gắn với đúng **một** đơn vị tính tiền.

**Verification:**
Kịch bản: bàn 5 gọi ba lượt — QR, Staff POS đặt hộ, rồi QR lần nữa sau khi quầy đã bấm tính tiền.
Kỳ vọng: đúng một hoá đơn cho bàn 5, và tổng của nó bằng tổng ba lượt. Kiểm ngược: đếm số hoá đơn
sinh ra cho một phiên phải luôn bằng 1. Đối soát cuối ngày (`shop-facts.md` §6.10) so tổng doanh
thu phiên bàn với sổ giấy và tiền trong két, ngưỡng lệch chấp nhận là 0đ.

*Phát hiện ở BA-03, 2026-08-31.*

### I-003 — Bàn chỉ trở lại trống sau khi phiên đóng VÀ bàn được dọn

**Invariant:**
Một bàn ở trạng thái **trống** khi và chỉ khi phiên của nó **đã đóng** *và* bàn **đã được dọn**.
Thiếu một trong hai điều kiện thì bàn chưa trống.

**Why:**
Hai lỗi ngược chiều nhau, cùng chặn bằng một câu. Trả bàn về trống ngay khi đóng phiên thì khách
mới được xếp vào một cái bàn còn bẩn. Trả bàn về trống khi mới dọn mà phiên chưa đóng thì phiên
kia mất chỗ đứng và tiền của nó không ai thu (`docs/product.md` §3.1.4, §5 quy tắc 9 của kế hoạch
gốc).

**Verification:**
Kịch bản: đóng phiên bàn 5 nhưng chưa dọn ⇒ bàn 5 **không** được nhận khách mới. Dọn bàn 5 trong
khi phiên còn *chờ thanh toán* ⇒ bàn 5 vẫn **không** trống. Chỉ khi cả bước 13 và bước 14 của
`docs/product.md` §3.1.1 đã xong thì bàn mới trống. Kiểm mỗi ca: không bàn trống nào còn dính một
phiên chưa đóng.

*Phát hiện ở BA-03, 2026-08-31.*

### I-004 — Đơn đã duyệt sinh đủ việc cho mọi trạm liên quan; đơn chưa duyệt không sinh việc nào

**Invariant:**
Một đơn **đã duyệt** nổ ra việc cho **mọi** trạm mà thành phần của suất chạm tới, với số lượng =
số suất × số thành phần trong suất (`shop-facts.md` §4.5). Mọi đơn đều có đúng một việc cho trạm
`canh` — nước chấm là việc cấp đơn. Một đơn **chưa duyệt** sinh **không** việc nào, ở cả năm trạm.

**Why:**
Hai nửa của cùng một luật. Nổ thiếu thì bếp làm thiếu: một dòng "Combo ×2" mơ hồ không cho ai biết
phải tráng sáu cái bánh, và **mọi suất bán đều kèm bánh cuốn**, không riêng combo
(`shop-facts.md` §5.3, §4.5). Nổ sớm thì bước duyệt mất tác dụng — nó tồn tại để chặn đơn ảo, nên
đơn chưa ai chịu trách nhiệm không được xuống bếp (`shop-facts.md` §6.2).

**Verification:**
Kịch bản dương: duyệt một đơn "hai suất Đầy đủ trứng tái" ở bàn 5 ⇒ đếm việc sinh ra phải khớp
đúng ví dụ ở `docs/product.md` §3.1.5 — sáu việc trên ba trạm, bánh cuốn ×6 chứ không phải ×2, và
dòng giò không kèm mô tả nhân. Kịch bản âm: gửi cùng đơn ấy qua QR tại bàn và **không** duyệt ⇒
đếm việc ở cả năm trạm bằng 0. Kịch bản phủ: với mỗi suất bán ở `shop-facts.md` §4.5, đơn duyệt
xong phải có ít nhất một việc bánh cuốn — suất nào không có là nổ sai.

*Phát hiện ở BA-03, 2026-08-31.*

### I-005 — Phiên đóng khi còn nợ phải ghi ai nợ và bao nhiêu; nợ không phải tiền đã thu

**Invariant:**
Một phiên bàn được đóng mà khách chưa trả đủ tiền thì bản ghi đóng phiên **bắt buộc** mang hai
thông tin: **ai nợ** và **nợ bao nhiêu**. Không có phiên nào đóng ở trạng thái thiếu tiền mà không
có chủ nợ. Và khoản nợ đó **không** được cộng vào tiền đã thu trong ngày.

**Why:**
Chủ quán chốt 2026-08-31 là **cho nợ** (`master_plan/shop-facts.md` §6.14), nên phiên phải đóng
được — không cho nợ thì một bàn quỵt tiền khoá luôn cái bàn. Nhưng đối soát cuối ngày lấy ngưỡng
lệch là **0đ** (§6.10): nếu khoản nợ không có chủ, hoặc bị cộng vào như tiền mặt đã nhận, thì két
lệch mà không ai truy ngược được — đúng thứ §6.10 cấm. Ghi nợ cũng là chỗ duy nhất phiên bàn phải
bỏ tính ẩn danh theo số bàn (`docs/product.md` §2.1, §3.1.6).

**Verification:**
Kịch bản: đóng phiên bàn 5 với số tiền thu được ít hơn tổng hoá đơn ⇒ thao tác **bị từ chối** nếu
thiếu tên người nợ hoặc thiếu số tiền nợ. Kịch bản đối soát: cuối ngày, `tiền trong két` +
`tổng nợ ghi trong ngày` phải bằng `doanh thu hệ thống`; chênh lệch phải bằng đúng tổng nợ, không
phải một con số khác. Kiểm ngược: mọi khoản nợ đều truy được về đúng một phiên và đúng một người.

*Phát hiện ở T-028, 2026-08-31.*

### I-006 — Suất "đem về" của khách ngồi bàn thuộc phiên bàn, không sinh đơn lẻ

**Invariant:**
Khách đang ngồi bàn gọi thêm một suất để mang về thì suất ấy nằm trong **phiên bàn** đang mở, mang
note **"đem về"**, và tiền của nó thuộc nguồn **phiên bàn** của báo cáo doanh thu. Nó không tạo ra
đơn `pickup`, `delivery` hay `phone_preorder` nào. Chiều ngược lại không tồn tại: không đơn nào của
ba kênh không gắn bàn được nối vào một phiên bàn.

**Why:**
Chủ quán chọn đường này vì *"thế này quản lý đơn giản hơn"* (chốt 2026-08-31,
`master_plan/shop-facts.md` §6.15). Tách nó thành đơn lẻ thì một bữa ăn của một bàn bị chẻ làm hai
đơn vị tính tiền, phá luật "một bàn một hoá đơn" (I-002) và làm khoản tiền ấy bị đếm ở nguồn sai —
`shop-facts.md` §6.9 buộc một khoản tiền gắn với đúng **một** đơn vị tính tiền.

**Verification:**
Kịch bản: bàn 5 đang ăn, gọi thêm một suất đem về ⇒ số đơn lẻ trong ngày **không** tăng, hoá đơn
của bàn 5 tăng đúng giá suất đó, và dòng việc xuống bếp của suất ấy mang note "đem về" đọc được.
Kịch bản đối soát: `doanh thu phiên bàn` + `doanh thu đơn lẻ` = tổng doanh thu, và không suất đem
về nào xuất hiện ở cả hai vế (`shop-facts.md` §6.9). Kịch bản âm: thử nối một đơn tới lấy vào phiên
bàn 5 ⇒ phải **bị từ chối** (`docs/product.md` §2.4).

*Phát hiện ở T-028, 2026-08-31.*

