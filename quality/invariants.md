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


### I-007 — Đơn mang đi không thuộc phiên bàn nào và là một đơn vị thanh toán độc lập

**Invariant:**
Mọi đơn của **ba kênh không gắn bàn** — Delivery, Pickup, Đặt trước qua hotline — không thuộc
phiên bàn nào, tại **mọi** thời điểm trong vòng đời của nó. Mỗi đơn như vậy là **một** đơn vị
thanh toán độc lập: nó không gộp với đơn khác, kể cả hai đơn của cùng một khách, và không bao giờ
được nối vào một phiên bàn — kể cả khi khách đổi ý và tới quán ngồi ăn.

**Why:**
Đây là ranh giới chia đôi toàn bộ mô hình tiền của sản phẩm: một khoản tiền gắn với đúng **một**
đơn vị tính tiền — hoặc một phiên bàn, hoặc một đơn lẻ, không bao giờ cả hai
(`master_plan/shop-facts.md` §6.9). Nối một đơn mang đi vào phiên bàn thì khoản tiền ấy bị đếm ở
nguồn sai, và báo cáo doanh thu — thứ phải cộng từ **cả hai** nguồn — hoặc thiếu, hoặc đếm hai
lần. Chủ quán đã đóng đường nối đó bằng một quyết định (chốt 2026-08-30, `shop-facts.md` §2):
khách đặt trước rồi tới quán ăn thì **huỷ đơn và gọi lại**, không chuyển đơn thành phiên bàn.
I-006 khoá chiều ngược lại — suất "đem về" của khách ngồi bàn thuộc phiên bàn; hai invariant này
là hai nửa của cùng một ranh giới và phải cùng đúng.

**Verification:**
Kịch bản âm: tạo một đơn tới lấy, rồi thử nối nó vào phiên đang mở của bàn 5 ⇒ thao tác phải **bị
từ chối** (`docs/product.md` §2.4, §3.2.5). Kịch bản thật: khách đã đặt trước qua hotline nhưng
tới quán ngồi ăn ⇒ đường duy nhất đi được là **huỷ** đơn cũ rồi gọi lại bằng QR tại bàn; sau ca
này, số phiên bàn của bàn ấy vẫn là 1 và đơn hotline nằm ở trạng thái đã huỷ. Kịch bản đếm: một
khách đặt hai đơn tới lấy cách nhau mười phút ⇒ **hai** đơn, **hai** lần thu tiền, không có thao
tác nào gộp chúng. Đối soát cuối ngày (`shop-facts.md` §6.10): `doanh thu phiên bàn` +
`doanh thu đơn lẻ` = tổng doanh thu, và không đơn nào xuất hiện ở cả hai vế.

*Phát hiện ở BA-04, 2026-08-31.*

### I-008 — Ngoài giờ bán hoặc đang tạm dừng nhận đơn thì không đơn nào được tạo

**Invariant:**
Một đơn mới chỉ được tạo khi **cả hai** điều kiện cùng mở: thời điểm tạo nằm trong giờ bán
(`master_plan/shop-facts.md` §1, múi giờ `Asia/Ho_Chi_Minh`) **và** chủ quán không đang bật "tạm
dừng nhận đơn". Nút tạm dừng có ưu tiên **cao hơn** giờ mở cửa: đang giữa giờ bán mà nút bật thì
vẫn không đơn nào được tạo. Luật này áp cho **mọi** kênh, không riêng ba kênh mang đi. Đơn đã tạo
**trước** đó không bị chạm tới: nó vẫn được làm, đóng gói, giao và thu tiền.

**Why:**
Hai quy tắc của kế hoạch gốc (§5 quy tắc 10 và 11) nằm cạnh nhau mà không nói cái nào thắng; chủ
quán chốt thứ tự đó (`shop-facts.md` §6.8): nút tạm dừng dùng khi **hết nguyên liệu giữa buổi**,
nên một đơn lọt qua trong lúc tạm dừng là một đơn quán **không có gì để làm** — khách chờ, rồi
quán phải gọi lại xin huỷ. Nửa sau cũng phải đúng: chặn nhầm cả đơn đã nhận thì tới 11:00 mọi đơn
đang trên đường giao bỗng không thu được tiền.

**Verification:**
Kịch bản biên: gửi một đơn lúc 05:59 và một đơn lúc 11:01 ⇒ cả hai **bị từ chối**, và khách thấy
câu *"Quán mở cửa 6h–11h sáng"* chứ không phải một nút bấm im lặng (`docs/product.md` §3.2.6).
Kịch bản ưu tiên: 08:00 — trong giờ bán — chủ quán bật tạm dừng ⇒ đơn mới của **cả năm** kênh đều
bị từ chối; tắt tạm dừng thì đặt lại được ngay. Kịch bản không chạm đơn cũ: nhận một đơn giao tận
nơi lúc 10:50, bật tạm dừng lúc 10:55 ⇒ đơn đó vẫn đi hết luồng, vẫn bấm được **đã giao và đã thu
tiền** sau 11:00. Kiểm ngược, cuối ngày: không đơn nào có thời điểm tạo nằm ngoài 06:00–11:00.

*Phát hiện ở BA-04, 2026-08-31.*

### I-009 — Đơn đã tạo không đổi giá, tên món và thành phần khi chủ quán sửa menu

**Invariant:**
Một đơn đã được tạo giữ nguyên **tổng tiền**, **giá từng dòng**, **tên món** và **thành phần của
suất** đúng như tại thời điểm tạo đơn, ở mọi thời điểm về sau. Không thao tác nào của chủ quán làm
đổi được bốn thứ đó, kể cả khi chủ quán đổi giá một thành phần, đổi mức phụ thu nhân, đổi mức phụ
thu lượng nhân, đổi thành phần của một suất bán, hay ngừng bán hẳn món đó
(`master_plan/shop-facts.md` §4.2, §4.4, §4.5 — bốn chiều liệt kê ở `docs/product.md` §3.3.2).
Ranh giới là **thời điểm tạo một LƯỢT GỌI**, không phải trạng thái nó đang ở: lượt gọi đang chờ
duyệt, đang làm ở bếp, đang giao hay chờ thanh toán đều đã khoá giá xong. Ranh giới **không** phải
lúc mở phiên bàn và **không** phải lúc thanh toán — nên một phiên bàn vắt qua mốc đổi giá cho ra
**một hoá đơn mang hai mức giá cho cùng một món**, và đó là kết quả đúng (chủ quán chốt 2026-09-01,
`master_plan/shop-facts.md` §6.17).

**Why:**
Kế hoạch gốc §5 quy tắc 5 và 6 chốt giá được xác định tại thời điểm đặt hàng và thay đổi menu
không làm đổi đơn cũ. Vi phạm ở đây **không nổ ra lỗi nào** — không có thao tác sai, không có màn
hình đỏ, chỉ có số tiền của một bữa ăn đã bán tự đổi sau lưng. Hậu quả rơi vào đối soát cuối ngày,
nơi ngưỡng lệch là **0đ** (`shop-facts.md` §6.10): két khớp với số tiền thật đã thu, còn hệ thống
lại kể một con số khác, và không ai truy ngược được vì thao tác gây ra nó là một lần chủ quán sửa
giá hoàn toàn hợp lệ, có thể đã xảy ra nhiều ngày trước.

Chiều thứ tư — **thành phần của một suất** — là chiều đắt nhất và dễ quên nhất. Giá một suất là
**tổng giá các thành phần** (`shop-facts.md` §4.6 quy tắc 1, bằng chứng §4.7), nên đọc lại một đơn
combo cũ theo thành phần **mới** làm sai cả tiền lẫn thứ bếp đã thật sự làm ra hôm đó.

**Verification:**
Kịch bản gốc — đổi giá món → mở đơn cũ → tổng tiền không đổi: đặt **một suất giò, nhân thịt, lượng
thường** (25.000 theo `shop-facts.md` §4.3) → chủ quán nâng giá một cái bánh nhân thường từ 4.000
lên 5.000 → mở lại đúng đơn ấy ⇒ tổng vẫn **25.000**, không phải 29.000; và một suất giò cùng loại
đặt **mới** ra 29.000. Kịch bản phủ bốn chiều: lặp đúng kịch bản trên cho từng chiều ở
`docs/product.md` §3.3.2 — giá thành phần · phụ thu nhân · phụ thu lượng nhân · thành phần suất
(đổi combo "Đầy đủ" từ 3 cái bánh xuống 2) ⇒ cả bốn lần, đơn cũ giữ nguyên tổng tiền **và** giữ
nguyên số phần bếp phải làm. Kịch bản ngừng bán: ngừng bán suất giò ⇒ đơn cũ vẫn hiện đúng tên
*"suất giò"* và đúng giá đã bán, trong khi cả năm kênh (`docs/product.md` §2) không đặt mới được
món đó. Kiểm ngược, cuối ngày: doanh thu của **mọi ngày đã qua** đọc lại phải bằng đúng con số đã
đối soát hôm đó, kể cả sau một lần chủ quán sửa giá (`shop-facts.md` §6.9, §6.10).

Kịch bản phiên bàn vắt qua mốc (chủ quán được đổi giá **giữa giờ bán**, `shop-facts.md` §6.17):
bàn 5 gọi một suất bánh cuốn nhân thường lúc 8:00 → chủ quán nâng giá cái bánh nhân thường lúc 8:30
→ bàn 5 gọi thêm **đúng món đó** lúc 9:00 → quầy đóng phiên. Kỳ vọng: **một** hoá đơn (I-002),
tổng của nó = giá **cũ** + giá **mới**, không phải hai lần giá mới và cũng không phải hai lần giá
cũ. Kịch bản âm đi kèm: không thao tác nào — kể cả bấm tính tiền — làm dòng lúc 8:00 nhảy sang giá
mới.

*Phát hiện ở BA-05, 2026-09-01. Siết lại ở T-034, 2026-09-01 — ranh giới là lượt gọi, không phải
phiên.*

### I-010 — Tổ hợp món/tuỳ chọn không hợp lệ bị TỪ CHỐI, không bao giờ được sửa hộ

**Invariant:**
Một dòng đơn mang tổ hợp tuỳ chọn không hợp lệ **bị từ chối**; hệ thống không bao giờ bỏ bớt, đổi
hay thêm tuỳ chọn để biến nó thành hợp lệ rồi cho đơn đi tiếp. Tổ hợp không hợp lệ đã chốt là
**Chay + Nhiều nhân**: nhóm *Lượng nhân* chỉ tồn tại khi nhân khác Chay
(`master_plan/shop-facts.md` §4.4, §4.6 quy tắc 3, §4.8 ca 11). Luật này áp cho **mọi** kênh trong
năm kênh của `docs/product.md` §2 — đơn khách tự bấm và đơn nhân viên nhập hộ như nhau. Khi chủ
quán sửa menu làm một tổ hợp đang hợp lệ trở thành không hợp lệ, luật áp cho đơn **mới** kể từ lúc
lưu; đơn **cũ** mang tổ hợp ấy không bị sửa lại và không bị đánh dấu hỏng (I-009).

**Why:**
Bếp nhận một phiếu mâu thuẫn là **hỏng món**: *"chay"* và *"nhiều nhân"* trên cùng một dòng không
cho ai biết phải làm gì. Sửa hộ còn tệ hơn từ chối — khách trả tiền cho một thứ khác thứ mình bấm,
và không ai biết vì đơn trông hoàn toàn bình thường. Đây cũng là nửa còn lại của luật giá: khách
**không bao giờ** gửi giá lên, hệ thống tự xác định lại từ bảng giá (`shop-facts.md` §4.6 quy tắc
9) — nhận một tổ hợp vô nghĩa rồi tự diễn giải là mở đúng cái cửa mà quy tắc 9 đóng.

**Verification:**
Kịch bản âm: gửi *"bánh cuốn, nhân Chay, lượng Nhiều nhân"* ⇒ đơn **bị từ chối**, không có đơn nào
được tạo, và **không** có đơn *"bánh cuốn Chay"* nào lặng lẽ ra đời — đúng ca 11 của
`shop-facts.md` §4.8, ca duy nhất trong mười một ca có kết quả không phải một con số. Kịch bản
dương đối chứng: mười ca còn lại của §4.8 (ca 1–10) đều tạo được đơn và ra đúng giá kỳ vọng ghi ở
đó. Kịch bản kênh: lặp ca 11 qua cả năm kênh, kể cả quầy đặt hộ trên POS ⇒ cả năm đều từ chối.
Kịch bản đổi menu: một tổ hợp đang hợp lệ, chủ quán sửa menu làm nó thành không hợp lệ ⇒ đơn mới
bị từ chối, còn đơn cũ mở lại vẫn nguyên vẹn tên, giá và thành phần (I-009).

*Phát hiện ở BA-05, 2026-09-01.*

### I-011 — Đổi thành phần suất trong giờ bán không bao giờ xảy ra ÂM THẦM

**Invariant:**
Một thao tác đổi **thành phần của suất bán** (`master_plan/shop-facts.md` §4.5) thực hiện trong
giờ bán (06:00–11:00, `shop-facts.md` §1, múi giờ `Asia/Ho_Chi_Minh`) **luôn** phải đi qua hai
thứ: một **lời nhắc** trước khi lưu, nói rằng đang trong giờ bán và luật là chờ hết buổi; và một
**vết đọc được** sau khi lưu — đổi cái gì, lúc mấy giờ, ai bấm. Ba chiều còn lại của việc đổi giá
— giá thành phần, phụ thu nhân, phụ thu lượng nhân — **không** chịu ràng buộc này: chúng đổi được
bất kỳ lúc nào, không nhắc gì cả (`docs/product.md` §3.3.2).

**Why:**
Chủ quán chốt hai câu, và phải đọc **cùng nhau**. Câu thứ nhất (2026-09-01, trả lời U-016,
`shop-facts.md` §6.17): đổi thành phần thì *"chờ đến hết buổi bán hàng"*. Câu thứ hai (2026-09-01,
trả lời U-018): máy **chỉ nhắc một câu, không chặn** — chủ quán giữ quyền tự phá luật của chính
mình.

⚠️ **Nên invariant này KHÔNG nói "thành phần suất không đổi trong giờ bán".** Câu đó từng là bản
đầu của I-011 (T-034) và nó **sai** kể từ lời chốt U-018: máy không chặn, nên trong quán vẫn có thể
có một ngày thành phần đổi lúc 9h sáng. Một invariant mà hệ thống không giữ nổi thì không phải
invariant — nó là một câu chúc. Thứ hệ thống **thật sự** giữ được là: chuyện đó không bao giờ xảy
ra mà không ai biết.

Vì sao đáng giữ đến thế: đổi thành phần đổi **thứ bếp phải làm ra**, mà bếp làm theo **mẻ**
(`shop-facts.md` §5.4) — hai suất cùng tên, cách nhau mười phút, có ruột khác nhau, và không bản
ghi nào chữa được chuyện suất bưng ra thiếu một cái bánh. Nó cũng đổi **tiền**: giá một suất là
tổng giá các thành phần (§4.6 luật 1). Hai lý do ấy cộng lại là vì sao lần lưu ấy phải để lại vết —
mọi thao tác chạm tiền đều phải truy ngược được cho đối soát cuối ngày (§6.10).

**Verification:**
Kịch bản lời nhắc: 09:00, sửa thành phần combo "Đầy đủ" từ 3 cái bánh xuống 2 ⇒ **phải** hiện lời
nhắc trước khi lưu; bấm bỏ qua thì **vẫn lưu được** (đó là lời chốt U-018, không phải lỗi). Kịch
bản đối chứng, phải **không** nhắc: 09:00, sửa **giá** một cái bánh ⇒ lưu thẳng, không lời nhắc nào
— luật này không được bắt nhầm sang ba chiều tiền (`shop-facts.md` §6.17). Kịch bản ngoài giờ:
13:00, sửa thành phần ⇒ không nhắc. Kịch bản vết: sau một lần lưu có bỏ qua lời nhắc, đối soát cuối
ngày (§6.10) đọc ra được **lần đổi đó**, kèm giờ và người bấm; không đọc ra được là hỏng invariant
này, kể cả khi lời nhắc đã hiện đúng. Kịch bản hệ quả, giữ nguyên từ I-009: mọi đơn tạo **trước**
lần đổi mở lại vẫn thấy đúng thành phần cũ.

*Phát hiện ở T-034, 2026-09-01. **Viết lại ở T-037, 2026-09-01** — lời chốt U-018 (máy chỉ nhắc)
làm bản đầu sai; xem khối ⚠️ ở mục Why.*

### I-012 — Mọi thao tác chạm tiền để lại vết truy ngược được về một người và một thời điểm

**Invariant:**
Không có thao tác nào làm đổi số tiền của quán mà không để lại vết đọc được **sau nhiều ngày**, và
mỗi vết trả lời đủ bốn câu: **cái gì đổi**, **bao nhiêu**, **ai bấm**, **lúc mấy giờ**. Danh sách
thao tác chạm tiền, tính tới 2026-09-01: **duyệt** đơn (`shop-facts.md` §6.2) · **huỷ** đơn (§6.13)
· **hoàn tiền** (§6.4) · **ghi nợ** lúc đóng phiên và **thu nợ** về sau (§6.14) · **xác nhận đã
nhận tiền** cho cả hai phương thức (§6.3) · **ghép bàn** (§6.16) · chủ quán **đổi giá** hoặc **đổi
thành phần suất** (§6.17). Mọi thao tác trong danh sách đi qua **đúng một cửa: máy POS ở quầy**
(`docs/product.md` §2.4, §4.6, §4.8), trừ hai ca đã chốt tên người khác: **người đi giao** bấm *đã
giao + đã thu tiền* tại chỗ khách (§6.7), và **chủ quán** bấm đổi giá / đổi thành phần suất trên
mặt quản trị (§6.17).

**Why:**
Đây là điều kiện để đối soát cuối ngày tồn tại được. `shop-facts.md` §6.10 lấy ngưỡng lệch là
**0đ** — *lệch 1 đồng cũng phải tìm ra lý do* — mà "tìm ra lý do" chỉ là một câu chữ nếu thao tác
gây ra chỗ lệch không có tên người và không có giờ. Hoàn tiền là ca rõ nhất: chủ quán cố ý **không
đặt luật cứng** (§6.4), nên thứ duy nhất giữ được nó khỏi thành lỗ thủng là cái vết — không có
luật để đối chiếu thì phải có người đứng tên. Ghi nợ (§6.14) và đổi thành phần suất giữa giờ bán
(§6.17, I-011) cũng cùng một lý do: cả hai đều hợp lệ, cả hai đều làm két lệch, và cả hai chỉ vô
hại khi đọc lại được.

Nó **khác** I-005: I-005 bắt bản ghi đóng phiên phải có *ai nợ, bao nhiêu*; invariant này bắt **mọi
thao tác tiền khác** cũng phải có mức đó, kể cả những thao tác không sinh ra bản ghi nào mới.

**Verification:**
Kịch bản phủ: chạy đủ một lượt tám thao tác trong danh sách trên, rồi **hôm sau** mở lại — mỗi
thao tác phải đọc ra đủ bốn câu (cái gì, bao nhiêu, ai, mấy giờ). Kịch bản hoàn tiền: hoàn tiền một
đơn đã trả trước bị huỷ ⇒ vết ghi đủ **bao nhiêu, đơn nào, ai bấm, lý do gì**
(`docs/product.md` §4.8); thiếu lý do cũng là hỏng, vì không có luật cứng nào thay được nó. Kịch
bản đối soát: dựng một ngày có **ghi nợ + thu nợ cũ + một lần hoàn + một lần chủ quán đổi giá giữa
buổi** ⇒ bảng đối soát cuối ngày giải thích được **từng** chỗ lệch bằng đúng một thao tác có tên
(`docs/product.md` §4.9). Kịch bản âm: không tồn tại đường nào đổi tiền mà không qua POS ở quầy,
ngoài hai ca đã chốt ở trên.

*Phát hiện ở BA-06, 2026-09-01.*

### I-013 — Giá mọi dòng đơn do hệ thống tính lại; giá do khách gửi lên không bao giờ được dùng

**Invariant:**
Giá của mỗi dòng đơn được hệ thống **tính lại** tại thời điểm tạo lượt gọi, từ đúng hai thứ: món
khách chọn và tuỳ chọn khách chọn kèm, tra `master_plan/shop-facts.md` §4.2 và §4.5. Một con số
giá đến **từ phía khách** không bao giờ được dùng làm giá — kể cả khi nó bằng đúng giá đúng. Công
thức là **tổng giá các thành phần của suất** (§4.6 quy tắc 1), nên "tính lại" nghĩa là cộng lại từ
bảng thành phần, không phải đọc một con số nằm sẵn cạnh tên món. Luật áp cho **cả năm** kênh của
`docs/product.md` §2.

**Why:**
`shop-facts.md` §4.6 quy tắc 9 nói thẳng hậu quả: nhận giá do khách gửi nghĩa là **có ngày khách
đặt được món 0đ**. Ba kênh khách tự bấm — QR tại bàn, Delivery, Pickup — đều gửi dữ liệu từ máy
của khách, nên đây không phải rủi ro lý thuyết. Bước quầy duyệt (§6.2) **không** đỡ được: nó chặn
đơn ảo, không ai đứng đó cộng lại tiền từng dòng. Và vì giá một suất là **tổng thành phần**, đọc
một con số có sẵn cũng hỏng theo cách thứ hai: chủ quán đổi giá một cái bánh thì con số nằm sẵn ấy
không tự đúng lại (`docs/product.md` §3.3.2).

Nó là nửa còn lại của I-010: I-010 chặn **tổ hợp tuỳ chọn** vô nghĩa đi vào đơn, invariant này
chặn **con số tiền** đi vào đơn. Hai cửa khác nhau của cùng một luật *"khách chọn món, hệ thống
quyết tiền"*.

**Verification:**
Kịch bản âm: gửi một đơn QR tại bàn kèm giá **0đ** cho một suất giò ⇒ đơn được tạo với giá tra từ
`shop-facts.md` §4.3, **không** phải 0đ; lặp lại với một giá cao hơn giá đúng ⇒ vẫn ra giá đúng.
Kịch bản kênh: lặp cả hai ca trên qua **năm** kênh của `docs/product.md` §2, kể cả quầy đặt hộ trên
POS. Kịch bản tính lại: đặt một suất giò nhân thường, rồi chủ quán đổi giá một cái bánh, rồi đặt
**mới** một suất giò cùng loại ⇒ đơn mới ra giá **mới** (đơn cũ giữ nguyên — I-009), chứng minh giá
được cộng lại từ bảng thành phần chứ không đọc từ một chỗ nằm sẵn. Kịch bản phủ: mười ca có số của
`shop-facts.md` §4.8 (ca 1–10) đều ra đúng giá kỳ vọng ghi ở đó.

*Phát hiện ở BA-06, 2026-09-01.*

### I-014 — Doanh thu một ngày cộng từ ĐỦ hai nguồn, và không khoản tiền nào đứng ở hai nguồn

**Invariant:**
Doanh thu của một ngày bán = **tiền từ phiên bàn** + **tiền từ đơn mang đi**, cộng từ **cả hai**
nguồn, không bao giờ chỉ một. Mỗi khoản tiền thuộc **đúng một** nguồn: không khoản nào bị đếm hai
lần, và không khoản nào rơi ra ngoài cả hai. "Hai nguồn" chia theo **đơn vị thanh toán**, không
chia theo kênh — cả **ba** kênh mang đi (Delivery, Pickup, Đặt trước qua hotline) cùng rơi vào
nguồn thứ hai (`master_plan/shop-facts.md` §6.9, `docs/product.md` §4.5, §4.10).

**Ngày nào tính vào doanh thu ngày ấy — hai luật NGƯỢC CHIỀU, cả hai cùng đúng:**

| Việc | Rơi vào ngày | Nguồn |
|---|---|---|
| **Bán**, kể cả khoản khách **nợ** | **ngày bán** = ngày ghi nợ, không phải ngày thu được tiền | `shop-facts.md` §6.14 |
| **Hoàn tiền** | **ngày hoàn**, không phải ngày bán gốc | `shop-facts.md` §6.4, chủ quán chốt 2026-09-01 |

⇒ **Một lần trả nợ không bao giờ là một khoản bán mới**, và **một lần hoàn không bao giờ sửa lại
doanh thu của một ngày đã đóng sổ**. Hệ quả chung của hai luật: **doanh thu của một ngày đã đối soát
không đổi về sau** — cùng ràng buộc mà I-009 giữ cho từng đơn, ở mức một ngày bán.

**Why:**
I-006 và I-007 chốt **một đơn thuộc nguồn nào**; invariant này chốt **phép cộng ở trên** — và hai
thứ hỏng khác nhau. Định tuyến đúng từng đơn mà báo cáo chỉ cộng một nguồn thì vẫn là **báo cáo
thiếu tiền**, và nó thiếu một cách im lặng: không có thao tác sai, không có đơn nào lạc chỗ, chỉ có
một con số nhỏ hơn sự thật. `shop-facts.md` §6.9 nói thẳng *"bỏ sót một nguồn là báo cáo thiếu"*.
Chỗ dễ sai nhất là đếm **ba kênh** mang đi thành ba nguồn rồi quên phiên bàn, hoặc ngược lại — làm
sản phẩm cho một quán mà phần lớn khách ngồi bàn thì nguồn đơn lẻ rất dễ bị bỏ quên. Vế "trả nợ
không phải khoản bán mới" là chỗ đếm **hai lần** duy nhất đã biết trước: ghi nó thành một lần bán
là tính doanh thu hai lần cho cùng một bữa ăn.

**Verification:**
Kịch bản cộng đủ: một ngày có **cả** phiên bàn **và** đơn của cả ba kênh mang đi ⇒ tổng báo cáo =
tổng hai nguồn, và bỏ nguồn nào ra thì con số cũng nhỏ đi (chứng minh cả hai thật sự được cộng).
Kịch bản không trùng: liệt kê mọi khoản tiền của ngày ấy ⇒ mỗi khoản xuất hiện đúng **một** lần
trên đúng **một** nguồn; suất "đem về" của khách ngồi bàn nằm ở nguồn **phiên bàn** (I-006), đơn
Pickup nằm ở nguồn **đơn lẻ** (I-007). Kịch bản nợ: bàn 5 nợ hôm nay, trả vào ba hôm sau ⇒ doanh
thu **hôm nay** đã có đủ khoản đó, doanh thu **hôm trả** **không** tăng, và tổng doanh thu hai ngày
cộng lại đúng bằng số tiền một bữa ăn (`docs/product.md` §3.1.6, §4.10). Kịch bản hoàn tiền — đi
**ngược** kịch bản nợ: bán thứ Hai, hoàn thứ Tư ⇒ doanh thu **thứ Hai giữ nguyên** (mở lại phải ra
đúng con số đã đối soát tối thứ Hai), doanh thu **thứ Tư** giảm đúng bằng khoản đã hoàn. Kịch bản
đối soát: dựng lại doanh thu của **mọi ngày đã qua** phải ra đúng con số đã đối soát hôm đó, kể cả
sau một lần hoàn tiền và một lần thu nợ (`shop-facts.md` §6.10, cùng ràng buộc với I-009).

*Phát hiện ở BA-06, 2026-09-01. **Sửa ở T-038, 2026-09-01** — bản đầu chỉ có luật "tính vào ngày
bán", đúng cho nợ nhưng **sai cho hoàn tiền**: lời chốt U-019 cùng ngày đặt hoàn tiền vào ngày
hoàn. Nay là bảng hai dòng ngược chiều, không phải một câu.*

### I-015 — Một lần thu chia được nhiều phương thức, nhưng tổng luôn khớp và từng phần luôn ghi riêng

**Invariant:**
Một lần thu tiền của một phiên bàn hoặc một đơn gồm **một hoặc nhiều** phần, mỗi phần mang **đúng
một** phương thức trong hai phương thức của `master_plan/shop-facts.md` §1 (tiền mặt · VietQR
tĩnh), và **số tiền của từng phần được ghi riêng** — không bao giờ gộp thành một con số tổng
(`shop-facts.md` §6.18, chủ quán chốt 2026-09-01). **Tổng các phần đã thu = số tiền phải trả**;
thiếu thì phần thiếu là một khoản **nợ** và đi theo I-005, và không có ca nào tổng các phần **vượt
quá** số phải trả.

**Why:**
Chủ quán trả lời U-020 rằng quán **nhận cả hai** — *"POS xác nhận thông tin bao nhiêu chuyển khoản,
bao nhiêu tiền mặt"*. Vế *ghi riêng từng phần* không phải chi tiết trình bày mà là điều kiện để đối
soát cuối ngày tồn tại: §6.10 so **phần tiền mặt với két** và **phần chuyển khoản với tin nhắn báo
có**, hai nguồn khác nhau, nên một lần thu ghi gộp thì không xếp được vào nguồn nào và ngưỡng **0đ**
mất nghĩa ngay hôm có ca đó. Vế *tổng luôn khớp* chặn hai lỗi ngược chiều: thu thiếu mà tưởng đã đủ
(khoản thiếu biến mất thay vì thành nợ có chủ), và thu thừa được ghi nhận (két thừa mà không ai
truy được).

⚠️ Invariant này **thay** một câu sai từng nằm ở `docs/product.md` §4.6 trong ngày 2026-09-01,
câu ràng buộc mỗi lần thu vào **một** phương thức. Câu đó đọc chữ **hoặc** ở `shop-facts.md` §1
thành luật loại trừ, trong khi chữ ấy chỉ mô tả **lựa chọn của khách**. Bất kỳ câu nào bắt một lần
thu nằm gọn trong một phương thức là lỗi ấy quay lại.

**Verification:**
Kịch bản chia: một phiên bàn thu làm hai phần — một phần tiền mặt, một phần VietQR ⇒ POS ghi **hai**
khoản, mỗi khoản có phương thức và số tiền riêng, và tổng hai khoản bằng đúng tổng hoá đơn (I-002).
Kịch bản đối soát: cuối ngày, **tổng phần tiền mặt** của mọi lần thu khớp két và **tổng phần chuyển
khoản** khớp tin nhắn báo có, tính riêng từng nguồn — không cộng gộp rồi so một con số
(`docs/product.md` §4.9). Kịch bản thiếu: thu ít hơn tổng hoá đơn ⇒ phần thiếu **bắt buộc** thành
một khoản nợ có tên và có số tiền, đúng I-005; không có đường nào đóng phiên với tổng nhỏ hơn mà
không ghi nợ. Kịch bản âm: thu nhiều hơn tổng hoá đơn ⇒ **bị từ chối**. Kịch bản một phần: lần thu
chỉ một phương thức vẫn hợp lệ — đây là ca thường, không phải ngoại lệ.

*Phát hiện ở T-038, 2026-09-01.*

### I-016 — Chuyển trạng thái không có trong bảng §5 bị TỪ CHỐI, không bao giờ được làm ngầm

**Invariant:**
Ba vòng đời của `docs/product.md` §5 — **đơn** (§5.2), **phiên bàn và cái bàn của nó** (§5.3),
**công việc trạm** (§5.4) — mỗi cái có một bảng chuyển tiếp đóng. Một chuyển tiếp **không có dòng**
trong bảng của nó là **không hợp lệ** và bị **từ chối**; nó không được thực hiện im lặng, không
được "tự sửa thành hợp lệ", và không có đường tắt nào bỏ qua một trạng thái ở giữa. Ba ca đã biết
trước mà sản phẩm phải từ chối, kèm lý do vì sao chúng nghe có lý (§5.6): phiên `Đã đóng` **không**
quay lại `Đang phục vụ` · đơn `Hoàn thành` **không** sang `Huỷ`.

**Danh sách ấy ngắn đi một dòng ngày 2026-09-01 (T-039), và đó là bằng chứng invariant này đang làm
đúng việc.** Việc trạm `Đã làm xong, còn ở bếp` → `Chưa làm` từng nằm trong danh sách bị từ chối;
chủ quán chốt là **có** đường lùi (trả lời U-024), nên §5.4 có thêm một dòng và ca ấy nay **hợp
lệ**. Invariant không phải sửa một chữ: nó bảo vệ *"chỉ đi theo bảng"*, không bảo vệ một danh sách
cố định.

**Why:**
Vòng đời là chỗ **cả ba lát cắt của §3 gặp nhau**, nên một chuyển tiếp lạ không hỏng ở chỗ nó xảy
ra mà hỏng ở chỗ khác, muộn hơn: mở lại một phiên `Đã đóng` là mở lại một hoá đơn **đã thu tiền**
(§3.3.3, §4.4 — thứ I-009 khoá); đẩy một đơn thẳng từ `Chờ xác nhận` sang `Đang thực hiện` là cho
việc xuống bếp mà **không ai duyệt** (`master_plan/shop-facts.md` §6.2 — thứ I-004 khoá). Từ chối
sớm và nói ra là cách duy nhất giữ được luật *"mọi thao tác chạm tiền hoặc trạng thái đơn phải kiểm
chứng lại được"* (kế hoạch gốc §5 quy tắc 12, I-012).

**Một trong hai ca còn lại bị từ chối vì CHƯA AI CHỐT, không phải vì đã chốt là cấm:**
`Hoàn thành → Huỷ` chờ **U-022** — mà U-022 nay đã có **một nửa** lời giải (đơn đã xác nhận thì
sửa được, trên POS, `master_plan/shop-facts.md` §6.19), chỉ còn nửa *"tới trạng thái nào"*. Chủ
quán trả lời nốt thì bảng §5.2 có thêm dòng và invariant này vẫn đúng nguyên văn.

**Sửa đơn không phải chuyển tiếp, nên nó không nằm dưới invariant này.** Sửa đổi **nội dung** một
đơn, không đẩy đơn sang trạng thái khác (`docs/product.md` §5.2) — từ chối nó nhân danh *"không có
dòng nào trong bảng"* là đọc sai invariant.

**Verification:**
Kịch bản âm: đóng một phiên rồi cố đưa nó về `Đang phục vụ` ⇒ **bị từ chối**, và khách quay lại gọi
tiếp thì mở **phiên mới** · huỷ một đơn đã `Hoàn thành` ⇒ **bị từ chối**. Kịch bản **dương** đi kèm,
vì nó là ca vừa đổi phía: đưa một việc từ `Đã làm xong, còn ở bếp` về `Chưa làm` ⇒ **được**, và
lần lùi ấy **để lại vết** (mẻ nào, mấy giờ, ai bấm — I-012); không có mốc thời gian nào chặn nó
(`shop-facts.md` §5.4). Kịch bản bỏ bước:
đơn ở `Chờ xác nhận` sinh việc xuống bếp mà không qua `Đã xác nhận` ⇒ **không việc nào được sinh**
(I-004). Kịch bản phủ: dựng lại đúng danh sách dòng của ba bảng §5 rồi thử **mọi** cặp (nguồn,
đích) còn lại ⇒ tất cả bị từ chối; danh sách bị từ chối phải **thay đổi** khi §5 thêm một dòng —
nếu không, bảng và sản phẩm đã rời nhau.

*Phát hiện ở BA-07, 2026-09-01. Đọc lại ở T-039 cùng ngày — đường lùi của việc trạm chuyển từ
ca bị từ chối sang dòng hợp lệ (U-024).*

### I-017 — Phiên bàn không thể `Đã đóng` khi còn đơn chưa `Hoàn thành` và chưa `Huỷ`

**Invariant:**
Một phiên bàn chỉ chuyển sang `Đã đóng` khi **mọi** đơn thuộc phiên đó ở `Hoàn thành` **hoặc**
`Huỷ`. Còn một đơn ở `Mới`, `Chờ xác nhận`, `Đã xác nhận` hay `Đang thực hiện` thì thao tác đóng
phiên **bị từ chối**. Với **nhóm ghép bàn**, "mọi đơn thuộc phiên" phủ đơn của **tất cả** các bàn
trong nhóm (`docs/product.md` §3.1.7, `master_plan/shop-facts.md` §6.16), vì nhóm ghép vẫn là
**một** phiên (I-002).

**Điều kiện này nói về MÓN, không nói về TIỀN.** Phiên **vẫn** đóng được khi khách chưa trả đồng
nào: quán **cho nợ**, và lúc đóng POS bắt buộc ghi **ai nợ** và **nợ bao nhiêu** (I-005,
`shop-facts.md` §6.14). Hai luật ngược chiều nhau và **không được nhớ nhầm thành một**: món chưa
xong thì **chặn** đóng phiên; tiền chưa thu thì **không** chặn.

**Why:**
Đóng phiên là mốc **cuối cùng** phiên còn nhận được lượt gọi và còn tính thêm được tiền (§5.3): từ
đó bàn đi tiếp sang `Bàn cần dọn` rồi `Trống`, và mọi việc bếp còn treo của phiên ấy mất chỗ đứng.
Đóng khi còn một đơn `Đang thực hiện` hỏng theo hai chiều cùng lúc — bếp vẫn làm ra một suất **không
còn hoá đơn nào để về**, và khách đã trả tiền cho một món **không bao giờ được bưng ra**. Cả hai đều
im lặng: không thao tác nào sai, chỉ có đối soát cuối ngày thấy lệch mà không truy được lý do
(`shop-facts.md` §6.10, ngưỡng **0đ**).

Chiều ngược lại phải chặn cùng lúc, nếu không luật này đẻ ra một cái bẫy: **không** được lấy nó làm
cớ giữ phiên mở để chờ tiền. Không cho nợ thì một bàn quỵt tiền **khoá luôn cái bàn đó** cả buổi
(§3.1.6) — đúng thứ chủ quán chốt 2026-08-31 là phải tránh.

**Verification:**
Kịch bản âm: bàn 5 có hai đơn, một `Hoàn thành` và một `Đang thực hiện` ⇒ bấm đóng phiên **bị từ
chối**; huỷ hoặc hoàn thành nốt đơn thứ hai ⇒ đóng được. Kịch bản nợ: mọi đơn đã `Hoàn thành`, khách
không trả được ⇒ phiên **đóng được**, và POS **bắt buộc** ghi ai nợ và bao nhiêu (I-005); bỏ trống
một trong hai ⇒ thao tác bị từ chối. Kịch bản ghép bàn: nhóm bàn 4 + bàn 5, bàn 4 xong hết, bàn 5
còn một đơn `Đang thực hiện` ⇒ **không** đóng được phiên, và bàn 4 **không** về `Trống` sớm hơn
(I-003). Kịch bản gọi thêm: phiên ở `Chờ thanh toán` nhận một lượt gọi mới ⇒ phiên quay lại
`Đang phục vụ` và **không** đóng được cho tới khi lượt gọi ấy xong (`shop-facts.md` §6.1, I-001).

*Phát hiện ở BA-07, 2026-09-01.*
