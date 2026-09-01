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

### I-011 — Thành phần một suất bán không đổi trong giờ bán

**Invariant:**
Một thay đổi **thành phần của suất bán** (`master_plan/shop-facts.md` §4.5 — suất đó gồm những gì)
không bao giờ có hiệu lực trong giờ bán. Mọi lần đổi thành phần đều có mốc hiệu lực nằm **ngoài**
06:00–11:00 (`shop-facts.md` §1, múi giờ `Asia/Ho_Chi_Minh`). Ba chiều còn lại của việc đổi giá —
giá thành phần, phụ thu nhân, phụ thu lượng nhân — **không** chịu ràng buộc này: chúng đổi được bất
kỳ lúc nào (`docs/product.md` §3.3.2).

**Why:**
Chủ quán chốt 2026-09-01 (`shop-facts.md` §6.17, trả lời U-016): giá thì *"không phải chờ đến hết
buổi"*, còn thành phần thì *"chờ đến hết buổi bán hàng"*. Hai chiều xử khác nhau vì chúng hỏng khác
nhau. Đổi giá chỉ đổi **số tiền** của lượt gọi sau đó, và I-009 đã khoá phần quá khứ. Đổi thành
phần đổi **thứ bếp phải làm ra** — mà bếp làm theo **mẻ** (`shop-facts.md` §5.4), nên một mẻ đang
trên nồi bỗng thuộc về hai định nghĩa khác nhau của cùng một tên món, và không có bản ghi nào chữa
được chuyện suất bưng ra thiếu một cái bánh. Đây là chiều duy nhất trong bốn chiều mà hậu quả rơi
vào **món ăn thật**, không rơi vào con số.

**Verification:**
Kịch bản kiểm ngược, chạy được mỗi ngày mà không cần biết máy có chặn hay không: liệt kê mọi lần
đổi thành phần suất trong ngày ⇒ **không lần nào** có mốc hiệu lực nằm trong 06:00–11:00. Kịch bản
đối chứng, phải **không** báo lỗi: một lần đổi **giá** lúc 08:30 là hợp lệ (§6.17) — luật này không
được bắt nhầm sang ba chiều tiền. Kịch bản hệ quả: sau một lần đổi thành phần hợp lệ (ngoài giờ
bán), mọi đơn của buổi hôm trước mở lại vẫn thấy đúng thành phần cũ (I-009), và đơn của buổi hôm
sau thấy thành phần mới.

**Chưa chốt:** máy **chặn hẳn** hay chỉ **nhắc rồi vẫn cho lưu** khi chủ quán định đổi thành phần
giữa giờ bán — `docs/product.md` → *Unknowns* **U-018**. Verification ở trên cố ý viết ở mức đối
soát cuối ngày nên nó đúng với cả hai lời giải; lời giải của U-018 sẽ **thêm** một kịch bản kiểm
tại chỗ, không thay kịch bản này.

*Phát hiện ở T-034, 2026-09-01.*
