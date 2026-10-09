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
nhưng khách vẫn gọi thêm được (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.4, `master_plan/shop-facts.md` §6.1).

**Verification:**
Kịch bản nghiệp vụ: mở phiên cho bàn 5 → gọi một lượt bằng QR tại bàn → quầy bấm tính tiền (phiên
sang *chờ thanh toán*) → gửi thêm một đơn QR tại bàn 5. Kỳ vọng: đơn mới vào **chính** phiên đang
chờ thanh toán, và số phiên chưa thanh toán của bàn 5 vẫn bằng 1. Kịch bản ghép: ghép bàn 4 với
bàn 5 ⇒ **một** phiên gắn hai bàn, và mỗi bàn vẫn đếm được đúng **một** phiên chưa thanh toán —
không bàn nào lên hai. Kiểm lại con số này sau các bước
4, 9 và 11 của `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.1. Đối soát cuối ngày (`shop-facts.md` §6.10): không bàn nào
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
kia mất chỗ đứng và tiền của nó không ai thu (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.4, §5 quy tắc 9 của kế hoạch
gốc).

**Verification:**
Kịch bản: đóng phiên bàn 5 nhưng chưa dọn ⇒ bàn 5 **không** được nhận khách mới. Dọn bàn 5 trong
khi phiên còn *chờ thanh toán* ⇒ bàn 5 vẫn **không** trống. Chỉ khi cả bước 13 và bước 14 của
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.1 đã xong thì bàn mới trống. Kiểm mỗi ca: không bàn trống nào còn dính một
phiên chưa đóng.

*Phát hiện ở BA-03, 2026-08-31.*

### I-004 — Đơn đã duyệt sinh đủ việc cho mọi trạm liên quan; đơn chưa duyệt không sinh việc nào

**Invariant:**
Một đơn **đã duyệt** nổ ra việc cho **mọi** trạm mà thành phần của suất chạm tới, với số lượng =
số suất × số thành phần trong suất (`shop-facts.md` §4.5). Trạm `canh` **không** đi theo phép
nhân ấy — nó có **hai** loại việc (`shop-facts.md` §5.3): **nước chấm** là việc cấp đơn, **mọi**
đơn đều có **đúng một**, không nhân theo số suất; **canh** có số lượng **bằng đúng** con số khách
chọn trên dòng *canh bánh cuốn* — không suất nào kèm sẵn bát nào, nên khách không chọn canh thì đơn
**không** có việc canh nào. Một đơn **chưa duyệt** sinh **không** việc nào, ở cả năm trạm.

*Câu về trạm `canh` viết lại 2026-09-27 (T-103, Claude Code), theo lời chủ quán đã chốt ở `U-046` ·
`U-048` (2026-09-08): bản trước nói *"đúng một việc cho trạm `canh`"*, hết đúng từ khi canh thành
một dòng menu khách chọn số lượng (`work/findings.md` **F-036**).*

**Why:**
Hai nửa của cùng một luật. Nổ thiếu thì bếp làm thiếu: một dòng "Combo ×2" mơ hồ không cho ai biết
phải tráng sáu cái bánh, và **mọi suất bán đều kèm bánh cuốn**, không riêng combo
(`shop-facts.md` §5.3, §4.5). Nổ sớm thì bước duyệt mất tác dụng — nó tồn tại để chặn đơn ảo, nên
đơn chưa ai chịu trách nhiệm không được xuống bếp (`shop-facts.md` §6.2).

**Verification:**
Kịch bản dương: duyệt một đơn "hai suất Đầy đủ trứng tái" ở bàn 5 ⇒ đếm việc sinh ra phải khớp
đúng ví dụ ở `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.5 — sáu việc trên ba trạm, bánh cuốn ×6 chứ không phải ×2, và
dòng giò không kèm mô tả nhân. Kịch bản âm: gửi cùng đơn ấy qua QR tại bàn và **không** duyệt ⇒
đếm việc ở cả năm trạm bằng 0. Kịch bản phủ: với mỗi suất bán ở `shop-facts.md` §4.5, đơn duyệt
xong phải có ít nhất một việc bánh cuốn — suất nào không có là nổ sai. Kịch bản trạm `canh`: duyệt
cùng đơn hai suất ấy kèm dòng *canh bánh cuốn ×2* ⇒ trạm `canh` có đúng **một** việc nước chấm
(không phải hai) và **một** việc canh số lượng **2**; duyệt lại đơn ấy **không** kèm dòng canh ⇒
vẫn một việc nước chấm, **không** việc canh nào (`shop-facts.md` §5.3).

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
bỏ tính ẩn danh theo số bàn (`docs/product/0-ba/ban-hang/` §2.1, §3.1.6).

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
bàn 5 ⇒ phải **bị từ chối** (`docs/product/0-ba/ban-hang/02-kenh-ban.md` §2.4).

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
từ chối** (`docs/product/0-ba/ban-hang/` §2.4, §3.2.5). Kịch bản thật: khách đã đặt trước qua hotline nhưng
tới quán ngồi ăn ⇒ đường duy nhất đi được là **huỷ** đơn cũ rồi gọi lại bằng QR tại bàn; sau ca
này, số phiên bàn của bàn ấy vẫn là 1 và đơn hotline nằm ở trạng thái đã huỷ. Kịch bản đếm: một
khách đặt hai đơn tới lấy cách nhau mười phút ⇒ **hai** đơn, **hai** lần thu tiền, không có thao
tác nào gộp chúng. Đối soát cuối ngày (`shop-facts.md` §6.10): `doanh thu phiên bàn` +
`doanh thu đơn lẻ` = tổng doanh thu, và không đơn nào xuất hiện ở cả hai vế.

*Phát hiện ở BA-04, 2026-08-31. **Sửa ở T-054, 2026-09-04** — bản đầu viết "cả hai điều kiện";
chủ quán trả lời U-035 cùng ngày và thêm điều kiện thứ ba (`shop-facts.md` §6.11).*

### I-008 — Ngoài giờ bán, đang tạm dừng nhận đơn, hoặc quán đang mất kết nối thì không đơn nào được tạo

**Invariant:**
Một đơn mới chỉ được tạo khi **cả ba** điều kiện cùng mở: thời điểm tạo nằm trong giờ bán
(`master_plan/shop-facts.md` §1, múi giờ `Asia/Ho_Chi_Minh`) · chủ quán không đang bật "tạm
dừng nhận đơn" · và **quán đang nhìn thấy được đơn mới** (§6.11, chủ quán chốt 2026-09-04). Nút
tạm dừng có ưu tiên **cao hơn** giờ mở cửa: đang giữa giờ bán mà nút bật thì vẫn không đơn nào
được tạo. Luật này áp cho **mọi** kênh, không riêng ba kênh mang đi. Đơn đã tạo **trước** đó không
bị chạm tới: nó vẫn được làm, đóng gói, giao và thu tiền.

**Điều kiện thứ ba cần đường điều khiển khi mạng quán mất.** Chủ quán chốt
2026-09-25 (U-053): dùng 5G bấm tắt (`shop-facts.md` §6.11). Ba kênh khách
tự bấm (`delivery`, `pickup`, `qr_table`) dừng; hai kênh do người của quán nhập (`staff_pos`,
`phone_preorder`) **không** dừng — mất mạng thì họ ghi giấy (§6.11). Khách được nhìn thấy **một dòng
thông báo** trên web, và **câu chữ của dòng ấy chưa chốt** — đừng tự viết
(`docs/product/99-unknowns.md` là chỗ ghi nếu cần hỏi).

**Máy làm sao biết quán đang mất kết nối là CƠ CHẾ, không thuộc mệnh đề này** —
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 bước **P1-08** và pha 3. Mệnh đề chỉ nói:
đơn tạo ra trong lúc quán mù là đơn **không được phép tồn tại**.

**AI BẤM DỪNG — chủ quán chốt 2026-09-16** (`docs/product/99-unknowns.md` `U-043`, nguyên văn:
*"hiên thông báo để pos quyết định nếu dừng cần có nut mở lại"*): hệ thống **hiện một thông báo** ở
quầy, **POS quyết** dừng ba kênh khách tự bấm, và đã dừng thì **mở lại là một nút người bấm** —
không tự mở lại khi tín hiệu về (`master_plan/shop-facts.md` §6.11 · `docs/decisions.md`
**ADR-047**). **Bổ sung 2026-09-25 (U-053):** khi quán mất mạng hẳn, chủ
quán dùng 5G bấm tắt ba kênh. **Chủ quán chốt tiếp 2026-09-27 (U-061):
“follow I-008”.** Điều kiện quán nhìn thấy đơn mới phải được bảo vệ cả trước
khi người bấm tắt: ba kênh khách tự bấm không được tạo đơn trong khoảng đó.
Không chờ thao tác tay mới chặn; luật mở lại bằng nút giữ nguyên. Cơ chế phát
hiện và thực thi thuộc pha sau, không tự suy một khoảng chờ được nhận đơn.

**Why:**
Hai quy tắc của kế hoạch gốc (§5 quy tắc 10 và 11) nằm cạnh nhau mà không nói cái nào thắng; chủ
quán chốt thứ tự đó (`shop-facts.md` §6.8): nút tạm dừng dùng khi **hết nguyên liệu giữa buổi**,
nên một đơn lọt qua trong lúc tạm dừng là một đơn quán **không có gì để làm** — khách chờ, rồi
quán phải gọi lại xin huỷ. Điều kiện thứ ba có **cùng một cái hỏng và nặng hơn**:
đơn lọt qua trong lúc quán mù thì quán **không biết là có nó** — không phải *không có gì để làm* mà
là *không ai biết phải làm*. Khách `pickup` tới đúng giờ hẹn (`shop-facts.md` §5.2 điểm 5) và không
ai ở quán từng nhìn thấy đơn ấy. Chủ quán chọn **chặn** thay vì nhận rồi làm bù, và câu ấy đóng
**U-035** ngày 2026-09-04. Nửa sau cũng phải đúng: chặn nhầm cả đơn đã nhận thì tới 11:00 mọi đơn
đang trên đường giao bỗng không thu được tiền.

**Verification:**
Kịch bản biên: gửi một đơn lúc 05:59 và một đơn lúc 11:01 ⇒ cả hai **bị từ chối**, và khách thấy
câu *"Quán mở cửa 6h–11h sáng"* chứ không phải một nút bấm im lặng (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.2.6).
Kịch bản ưu tiên: 08:00 — trong giờ bán — chủ quán bật tạm dừng ⇒ đơn mới của **cả năm** kênh đều
bị từ chối; tắt tạm dừng thì đặt lại được ngay. Kịch bản mất kết nối: 08:00, quán mất mạng
trong khi hệ thống vẫn sống, **chủ quán chưa bấm tắt qua 5G** ⇒ ba kênh khách tự bấm (`delivery`, `pickup`, `qr_table`) **bị từ
chối** và khách thấy **một dòng thông báo**, trong khi `staff_pos` và `phone_preorder` **không** bị
chặn — quán vẫn nhận đơn qua hotline và ghi giấy; có mạng lại thì ba kênh kia mở lại **khi POS bấm
nút mở** (chủ quán chốt 2026-09-16 — **không** tự mở lại), và
**không tạo đơn trong cả khoảng quán không nhìn thấy đơn mới, kể cả trước lúc
chủ quán bấm tắt** (U-061, chủ quán chốt 2026-09-27). Kiểm tiếp: chủ quán bấm
tắt qua 5G, khôi phục mạng nhưng chưa bấm mở ⇒ ba kênh vẫn dừng. Kịch bản không chạm đơn cũ: nhận một đơn giao tận
nơi lúc 10:50, bật tạm dừng lúc 10:55 ⇒ đơn đó vẫn đi hết luồng, vẫn bấm được **đã giao và đã thu
tiền** sau 11:00. Kiểm ngược, cuối ngày: không đơn nào có thời điểm tạo nằm ngoài 06:00–11:00.

*Phát hiện ở BA-04, 2026-08-31.*

### I-009 — Đơn đã tạo không đổi giá, tên món và thành phần khi chủ quán sửa menu

**Invariant:**
Một đơn đã được tạo giữ nguyên **tổng tiền**, **giá từng dòng**, **tên món** và **thành phần của
suất** đúng như tại thời điểm tạo đơn, ở mọi thời điểm về sau. Không thao tác nào của chủ quán làm
đổi được bốn thứ đó, kể cả khi chủ quán đổi giá một thành phần, đổi mức phụ thu nhân, đổi mức phụ
thu lượng nhân, đổi thành phần của một suất bán, hay ngừng bán hẳn món đó
(`master_plan/shop-facts.md` §4.2, §4.4, §4.5 — bốn chiều liệt kê ở `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.2).
Ranh giới là **thời điểm tạo một LƯỢT GỌI**, không phải trạng thái nó đang ở: lượt gọi đang chờ
duyệt, đang làm ở bếp, đang giao hay chờ thanh toán đều đã khoá giá xong. Ranh giới **không** phải
lúc mở phiên bàn và **không** phải lúc thanh toán — nên một phiên bàn vắt qua mốc đổi giá cho ra
**một hoá đơn mang hai mức giá cho cùng một món**, và đó là kết quả đúng (chủ quán chốt 2026-09-01,
`master_plan/shop-facts.md` §6.17).

**Một ngoại lệ, và nó KHÔNG nới invariant này ra** (chủ quán chốt 2026-09-02, trả lời U-026): khi
người đứng quầy **sửa** một dòng, dòng ấy lấy **giá đang hiệu lực lúc sửa** — mốc khoá giá của
chính dòng đó được **đặt lại** (`master_plan/shop-facts.md` §6.19, `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.4). Phân
biệt phải giữ cho sắc, vì invariant này sống hay chết ở đúng chỗ ấy:

- **Cái invariant cấm là menu tự với ngược vào đơn cũ.** Chủ quán đổi giá xong, **không** dòng nào
  đã tạo được đổi theo. Điều đó **vẫn đúng nguyên văn** sau 2026-09-02.
- **Cái được phép là một thao tác cố ý của người, trên đúng một dòng.** Giá dòng ấy đổi vì **có
  người sửa nó**, không phải vì bảng giá đổi. Không có thao tác sửa thì không có thay đổi nào.
- ⇒ **Bài kiểm phân biệt hai ca:** đổi giá menu rồi **không** đụng gì vào đơn ⇒ mọi dòng giữ giá cũ
  (invariant này) · đổi giá menu rồi **sửa** một dòng ⇒ **chỉ dòng ấy** ăn giá mới, các dòng còn
  lại của cùng lượt gọi giữ giá cũ. Một sản phẩm đổi giá **cả lượt gọi** khi sửa một dòng là **vi
  phạm** invariant này.
- ⇒ **Vết của lần sửa phải ghi cả giá cũ lẫn giá mới** (I-012), nếu không thì không ai phân biệt
  được hai ca trên khi đối soát.

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
thường** (25.000 theo `shop-facts.md` §4.3) → chủ quán nâng **giá gốc của một cái bánh cuốn — ô
*chay* của `shop-facts.md` §4.2 — từ 3.000 lên 4.000**, hai mức phụ thu nhân ở §4.4 **không đổi**
(⇒ bánh nhân thường thành 5.000, bánh nhiều nhân thành 6.000) → mở lại đúng đơn ấy ⇒ tổng vẫn
**25.000**, không phải 29.000; và một suất giò cùng loại đặt **mới** ra 29.000 = 9.000 + 4 × 5.000.
**Thao tác phải viết đúng như trên, không viết *"nâng giá một cái bánh nhân thường lên 5.000"***:
giá một cái bánh nhân thường không phải một ô sửa được mà là *giá gốc + phụ thu*, nên câu ấy cho
**hai** kết quả (25.000 hoặc 29.000) và một đường đọc của nó còn xoá mất bậc phụ thu lượng nhân —
một bài kiểm viết theo nó **xanh trong khi sản phẩm sai** (`work/findings.md` **F-022**, sửa cùng
lượt với `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.3, 2026-09-03).

Kịch bản phủ bốn chiều: lặp đúng kịch bản trên cho từng chiều ở
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.2 — giá thành phần · phụ thu nhân · phụ thu lượng nhân · thành phần suất
(đổi combo "Đầy đủ" từ 3 cái bánh xuống 2) ⇒ cả bốn lần, đơn cũ giữ nguyên tổng tiền **và** giữ
nguyên số phần bếp phải làm. Kịch bản ngừng bán: ngừng bán suất giò ⇒ đơn cũ vẫn hiện đúng tên
*"suất giò"* và đúng giá đã bán, trong khi cả năm kênh (`docs/product/0-ba/ban-hang/02-kenh-ban.md` §2) không đặt mới được
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
năm kênh của `docs/product/0-ba/ban-hang/02-kenh-ban.md` §2 — đơn khách tự bấm và đơn nhân viên nhập hộ như nhau. Khi chủ
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
bất kỳ lúc nào, không nhắc gì cả (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.2).

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
(`docs/product/0-ba/ban-hang/` §2.4, §4.6, §4.8), trừ hai ca đã chốt tên người khác: **người đi giao** bấm *đã
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
(`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.8); thiếu lý do cũng là hỏng, vì không có luật cứng nào thay được nó. Kịch
bản đối soát: dựng một ngày có **ghi nợ + thu nợ cũ + một lần hoàn + một lần chủ quán đổi giá giữa
buổi** ⇒ bảng đối soát cuối ngày giải thích được **từng** chỗ lệch bằng đúng một thao tác có tên
(`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.9). Kịch bản âm: không tồn tại đường nào đổi tiền mà không qua POS ở quầy,
ngoài hai ca đã chốt ở trên.

*Phát hiện ở BA-06, 2026-09-01.*

### I-013 — Giá mọi dòng đơn do hệ thống tính lại; giá do khách gửi lên không bao giờ được dùng

**Invariant:**
Giá của mỗi dòng đơn được hệ thống **tính lại** tại thời điểm tạo lượt gọi, từ đúng hai thứ: món
khách chọn và tuỳ chọn khách chọn kèm, tra `master_plan/shop-facts.md` §4.2 và §4.5. Một con số
giá đến **từ phía khách** không bao giờ được dùng làm giá — kể cả khi nó bằng đúng giá đúng. Công
thức là **tổng giá các thành phần của suất** (§4.6 quy tắc 1), nên "tính lại" nghĩa là cộng lại từ
bảng thành phần, không phải đọc một con số nằm sẵn cạnh tên món. Luật áp cho **cả năm** kênh của
`docs/product/0-ba/ban-hang/02-kenh-ban.md` §2.

**Why:**
`shop-facts.md` §4.6 quy tắc 9 nói thẳng hậu quả: nhận giá do khách gửi nghĩa là **có ngày khách
đặt được món 0đ**. Ba kênh khách tự bấm — QR tại bàn, Delivery, Pickup — đều gửi dữ liệu từ máy
của khách, nên đây không phải rủi ro lý thuyết. Bước quầy duyệt (§6.2) **không** đỡ được: nó chặn
đơn ảo, không ai đứng đó cộng lại tiền từng dòng. Và vì giá một suất là **tổng thành phần**, đọc
một con số có sẵn cũng hỏng theo cách thứ hai: chủ quán đổi giá một cái bánh thì con số nằm sẵn ấy
không tự đúng lại (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.2).

Nó là nửa còn lại của I-010: I-010 chặn **tổ hợp tuỳ chọn** vô nghĩa đi vào đơn, invariant này
chặn **con số tiền** đi vào đơn. Hai cửa khác nhau của cùng một luật *"khách chọn món, hệ thống
quyết tiền"*.

**Verification:**
Kịch bản âm: gửi một đơn QR tại bàn kèm giá **0đ** cho một suất giò ⇒ đơn được tạo với giá tra từ
`shop-facts.md` §4.3, **không** phải 0đ; lặp lại với một giá cao hơn giá đúng ⇒ vẫn ra giá đúng.
Kịch bản kênh: lặp cả hai ca trên qua **năm** kênh của `docs/product/0-ba/ban-hang/02-kenh-ban.md` §2, kể cả quầy đặt hộ trên
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
nguồn thứ hai (`master_plan/shop-facts.md` §6.9, `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.5, §4.10).

**Ngày nào tính vào doanh thu ngày ấy — BỐN luật, hai trong bốn ngược chiều nhau, cả bốn cùng đúng:**

| Việc | Rơi vào ngày | Nguồn |
|---|---|---|
| **Bán**, kể cả khoản khách **nợ** | **ngày bán** = ngày ghi nợ, không phải ngày thu được tiền | `shop-facts.md` §6.14 |
| **Hoàn tiền** | **ngày hoàn**, không phải ngày bán gốc | `shop-facts.md` §6.4, chủ quán chốt 2026-09-01 |
| **Lượt bán ghi trên SỔ GIẤY, nhập bù sau** | **ngày quán bán**, không phải ngày gõ vào máy | `shop-facts.md` §6.11, chủ quán chốt 2026-09-04 (U-032) |
| **Trả trước cho đơn đặt trước NGÀY SAU** | **ngày giao/lấy hàng**, không phải ngày nhận tiền | `shop-facts.md` §6.26, chủ quán chốt 2026-09-06 (U-036) · `docs/decisions.md` **ADR-040** |

⇒ **Một lần trả nợ không bao giờ là một khoản bán mới**, và **một lần hoàn không bao giờ sửa lại
doanh thu của một ngày đã đóng sổ**.

**Một khoản trả trước chưa thành doanh thu thì không là doanh thu của ngày nào**, và trả lại nó
(đơn huỷ hoặc bớt **trước** khi đóng) **không** trừ vào doanh thu ngày trả lại — *suy ra, không
phải lời chủ quán nói thẳng* (2026-09-28, T-112, `docs/decisions.md` **ADR-059** điểm 5): dòng thứ
tư của bảng đặt doanh thu vào ngày **đem hàng cho khách**, còn dòng thứ hai nói về một lần hoàn cho
việc bán **đã xong**. Đơn đã đóng rồi mới hoàn thì đi dòng thứ hai như mọi lần hoàn.

**Hệ quả chung của hai luật đầu — và một ngoại lệ mà luật thứ ba mở ra, có chủ ý:**

> **Doanh thu của một ngày đã đối soát không đổi về sau, TRỪ đúng một ca: lượt bán ghi trên sổ giấy
> chưa được nhập vào máy.** Ca ấy **phải nhìn thấy được trước khi đóng sổ** — bảng đối soát của ngày
> đó đọc được *"còn N lượt bán trên giấy chưa nhập"* (`shop-facts.md` §6.11), nên **một ngày còn
> `N > 0` là một ngày CHƯA đối soát xong**, không phải một ngày đã đóng rồi bị sửa trộm.

Ngoài ca ấy, ràng buộc cũ đứng nguyên — cùng ràng buộc mà I-009 giữ cho từng đơn, ở mức một ngày
bán. Vì sao ngoại lệ này không phá ngưỡng **0đ**: `docs/decisions.md` **ADR-037**. **Ai nhìn lại
con số sau khi nhập xong, và lúc nào — POS hoặc chủ quán, vào cuối buổi bán hàng** (chủ quán chốt
2026-09-06, `docs/product/99-unknowns.md` **U-037**, đóng).
**Đừng đọc ngoại lệ này rộng ra:** nó chỉ áp cho lượt bán **đã xảy ra thật ở quán** và có mặt trên
sổ giấy. Không ca nào khác được sửa doanh thu một ngày đã qua.

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
cộng lại đúng bằng số tiền một bữa ăn (`docs/product/0-ba/ban-hang/` §3.1.6, §4.10). Kịch bản hoàn tiền — đi
**ngược** kịch bản nợ: bán thứ Hai, hoàn thứ Tư ⇒ doanh thu **thứ Hai giữ nguyên** (mở lại phải ra
đúng con số đã đối soát tối thứ Hai), doanh thu **thứ Tư** giảm đúng bằng khoản đã hoàn. Kịch bản
đối soát: dựng lại doanh thu của **mọi ngày đã qua** phải ra đúng con số đã đối soát hôm đó, kể cả
sau một lần hoàn tiền và một lần thu nợ (`shop-facts.md` §6.10, cùng ràng buộc với I-009).
Kịch bản nhập bù — **ca duy nhất con số của một ngày đã qua được phép đổi**: hôm mất điện quán bán
30 suất ghi giấy, tối ấy đối soát ⇒ bảng của ngày đó đọc được *"còn 30 lượt bán trên giấy chưa
nhập"* và ngày đó **chưa đóng sổ**; hôm sau nhập đủ 30 ⇒ doanh thu của **ngày mất điện** tăng đúng
30 suất, doanh thu của **ngày gõ** **không** tăng một đồng nào, và `N` về 0 ⇒ ngày ấy mới đối soát
xong. Kiểm ngược: nhập 20 trong 30 thì `N` = 10 và ngày ấy **vẫn chưa đóng được** — không có đường
nào đóng sổ một ngày còn `N > 0`.

*Phát hiện ở BA-06, 2026-09-01. **Sửa ở T-038, 2026-09-01** — bản đầu chỉ có luật "tính vào ngày
bán", đúng cho nợ nhưng **sai cho hoàn tiền**: lời chốt U-019 cùng ngày đặt hoàn tiền vào ngày
hoàn. Nay là bảng ba dòng, không phải một câu.*
***Sửa lần hai ở T-054, 2026-09-04*** — *chủ quán trả lời **U-032**: lượt nhập bù từ sổ giấy tính
vào **ngày bán**. Bảng nay có dòng thứ ba, và câu hệ quả "doanh thu một ngày đã đối soát không đổi
về sau" — đúng từ 2026-09-01 tới 2026-09-04 — nay mang **một ngoại lệ có tên**. Để nguyên câu cũ là
để một mệnh đề sai nằm trong file bất biến (`docs/decisions.md` **ADR-037**).*
***Sửa lần ba ở 2026-09-06*** — *chủ quán trả lời **U-036**: trả trước cho một đơn đặt trước ngày
sau tính doanh thu vào **ngày giao**, đối xứng với chiều nợ. Bảng nay có dòng thứ tư
(`docs/decisions.md` **ADR-040**).*

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
(`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.9). Kịch bản thiếu: thu ít hơn tổng hoá đơn ⇒ phần thiếu **bắt buộc** thành
một khoản nợ có tên và có số tiền, đúng I-005; không có đường nào đóng phiên với tổng nhỏ hơn mà
không ghi nợ. Kịch bản âm: thu nhiều hơn tổng hoá đơn ⇒ **bị từ chối**. Kịch bản một phần: lần thu
chỉ một phương thức vẫn hợp lệ — đây là ca thường, không phải ngoại lệ.

*Phát hiện ở T-038, 2026-09-01.*

### I-016 — Chuyển trạng thái không có trong bảng §5 bị TỪ CHỐI, không bao giờ được làm ngầm

**Invariant:**
Ba vòng đời của `docs/product/0-ba/ban-hang/05-vong-doi.md` §5 — **đơn** (§5.2), **phiên bàn và cái bàn của nó** (§5.3),
**công việc trạm** (§5.4) — mỗi cái có một bảng chuyển tiếp đóng. Một chuyển tiếp **không có dòng**
trong bảng của nó là **không hợp lệ** và bị **từ chối**; nó không được thực hiện im lặng, không
được "tự sửa thành hợp lệ", và không có đường tắt nào bỏ qua một trạng thái ở giữa. **Tính tới
2026-09-02 chỉ còn ĐÚNG MỘT ca** đã biết trước mà sản phẩm phải từ chối, kèm lý do vì sao nó nghe
có lý (§5.6): phiên `Đã đóng` **không** quay lại `Đang phục vụ`.

**Danh sách ấy ngắn đi HAI dòng trong hai ngày, và đó là bằng chứng invariant này đang làm đúng
việc.** `Đã làm xong, còn ở bếp` → `Chưa làm` rời ngày 2026-09-01 (U-024, T-039); `Hoàn thành` →
`Huỷ` rời ngày 2026-09-02 (U-027, T-043) — chủ quán chốt **huỷ được, POS quyết trong thực tế**.
Cả hai lần §5 có thêm một dòng và invariant **không phải sửa một chữ** ở phần này.

**Why:**
Vòng đời là chỗ **cả ba lát cắt của §3 gặp nhau**, nên một chuyển tiếp lạ không hỏng ở chỗ nó xảy
ra mà hỏng ở chỗ khác, muộn hơn: mở lại một phiên `Đã đóng` là mở lại một hoá đơn **đã thu tiền**
(§3.3.3, §4.4 — thứ I-009 khoá); đẩy một đơn thẳng từ `Chờ xác nhận` sang `Đang thực hiện` là cho
việc xuống bếp mà **không ai duyệt** (`master_plan/shop-facts.md` §6.2 — thứ I-004 khoá). Từ chối
sớm và nói ra là cách duy nhất giữ được luật *"mọi thao tác chạm tiền hoặc trạng thái đơn phải kiểm
chứng lại được"* (kế hoạch gốc §5 quy tắc 12, I-012).

**Ngày 2026-09-02 danh sách ba ca ấy rút xuống còn MỘT, và invariant này vẫn đúng nguyên văn.**
Chủ quán chốt đơn **sửa được ở bất kỳ trạng thái nào** và **huỷ được kể cả khi đã `Hoàn thành`**,
POS quyết theo tình hình thực tế (`master_plan/shop-facts.md` §6.19 — trả lời U-022 rồi U-027). ⇒
Bảng `docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2 có thêm dòng `Hoàn thành → Huỷ`, nên ca ấy **không còn** bị từ chối;
`Đã làm xong, còn ở bếp → Chưa làm` cũng đã rời danh sách từ 2026-09-01 (U-024). Ca duy nhất còn
lại là **`Đã đóng` → `Đang phục vụ`** (phiên bàn), và nó bị từ chối vì **đã chốt là cấm**, không
phải vì chưa hỏi ai.

⇒ **Đó chính là điều invariant này bảo vệ:** nó khoá luật *"chỉ đi theo bảng"*, **không** khoá một
danh sách ca cố định. Ba lần bảng §5 đổi trong hai ngày, ba lần invariant này không phải sửa một
chữ nào ở phần *Invariant*. Bản kiểm chứng thì **phải** đổi theo mỗi lần — xem *Verification*.

⇒ **Và lời chốt 2026-09-02 KHÔNG nới invariant này ra.** *"Sửa được ở bất kỳ trạng thái nào"* nói
về **sửa nội dung**, thứ đoạn ngay dưới đây chỉ ra là **không phải chuyển tiếp**. Đọc nó thành
*"đơn muốn đi đâu cũng được"* là phá đúng cái invariant này bảo vệ.

**Sửa đơn không phải chuyển tiếp, nên nó không nằm dưới invariant này.** Sửa đổi **nội dung** một
đơn, không đẩy đơn sang trạng thái khác (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2) — từ chối nó nhân danh *"không có
dòng nào trong bảng"* là đọc sai invariant.

**Verification:**
Kịch bản âm — nay chỉ còn **một**: đóng một phiên rồi cố đưa nó về `Đang phục vụ` ⇒ **bị từ chối**,
và khách quay lại gọi tiếp thì mở **phiên mới**. Kịch bản **dương** đi kèm **hai** ca vừa đổi phía,
và cả hai phải có bài kiểm riêng: đưa một việc từ `Đã làm xong, còn ở bếp` về `Chưa làm` ⇒
**được** · huỷ một đơn đã `Hoàn thành` ⇒ **được**. Cả hai lần đều **để lại vết** (cái gì, mấy giờ,
ai bấm — I-012) và **không có mốc thời gian nào chặn** (`shop-facts.md` §5.4, §6.19); riêng lần huỷ
đơn đã `Hoàn thành` còn phải kiểm **đường tiền**: tiền đã thu thì lần huỷ ấy kéo theo **hoàn tiền**
theo §6.4, rơi vào **ngày hoàn**, không sửa lại doanh thu ngày bán. Kịch bản bỏ bước:
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
trong nhóm (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.7, `master_plan/shop-facts.md` §6.16), vì nhóm ghép vẫn là
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

### I-018 — Mỗi lần CẬP NHẬT giữ được bản trước, bản sau, lý do và người sửa

**Invariant:**
Không có thao tác nào sửa một bản ghi đã tồn tại mà chỉ để lại dấu *"đã sửa"*. Mỗi lần cập nhật
giữ đủ **bốn** thứ, và cả bốn phải đọc được **sau nhiều ngày**: bản ghi **trước** khi sửa · bản ghi
**sau** khi sửa · **lý do** · **ai sửa**. Ràng buộc mạnh nhất là hai cái đầu — phải **dựng lại
được** bản ghi ở cả hai phía của lần sửa, không phải chỉ biết rằng nó đã đổi
(`master_plan/shop-facts.md` §6.22, chủ quán chốt 2026-09-02).

Áp cho **mọi** lần sửa một bản ghi đã tồn tại, không riêng thao tác chạm tiền: sửa nội dung đơn
(§6.19) · huỷ một đơn đã `Hoàn thành` (§6.19) · sửa sau khi **duyệt nhầm, huỷ nhầm, đóng phiên
nhầm** (§6.22) · lần ghi đè khi **hai người cùng thao tác trên một bàn** (§6.22 — người bấm sau
thắng, nhưng lần đè vẫn phải có tên người và bản trước) · lùi một mẻ bấm nhầm (§5.4) · chủ quán đổi
giá hoặc đổi thành phần suất (§6.17).

**Không có nút hoàn tác, và đó là chủ ý.** Ngoài đúng một ca — lùi một mẻ *"đã làm xong"* (§5.4) —
cách sửa cái sai là **cập nhật**, không phải quay ngược trạng thái. ⇒ Invariant này là thứ **thay
thế** cho hoàn tác: quán chấp nhận không quay ngược được, đổi lại đòi dựng lại được.

**Why:**
Chủ quán nói thẳng mục đích khi chốt: ***"để đối chiếu"***. Đối soát cuối ngày có ngưỡng **0đ**
(`shop-facts.md` §6.10) — *lệch 1 đồng cũng phải tìm ra lý do* — và một chỗ lệch do **có người sửa
tay** không thể truy được nếu chỉ biết *"đơn 12 đã bị sửa"*: phải so được số **trước** với số
**sau** mới ra con số chênh và mới biết nó có đúng không.

Hai ca cho thấy vì sao một dòng log là **không đủ**:
- **Ghi đè khi hai người cùng thao tác.** Người bấm sau thắng (§6.22), nên một lượt gọi có thể
  biến mất khỏi hoá đơn. Không giữ bản trước thì **không ai biết nó từng có** — và đó là **thu
  thiếu tiền**, lỗi tiền nguy hiểm nhất của luồng tại bàn (`shop-facts.md` §6.1).
- **Sửa một dòng đơn sau khi chủ quán đổi giá giữa buổi.** Dòng ấy lấy giá **lúc sửa** (§6.19,
  I-009), nên số tiền đổi mà **món không đổi**. Bản ghi không có giá cũ thì chỗ lệch ấy trông y
  hệt một lỗi tính tiền.

**Quan hệ với I-012 — hai invariant khác nhau, đừng gộp.** I-012 hỏi *"ai bấm, lúc mấy giờ, cái gì,
bao nhiêu"* cho mọi **thao tác chạm tiền**. I-018 hỏi *"trước thế nào, sau thế nào, vì sao"* cho mọi
lần **sửa một bản ghi đã có**. Hai tập không trùng nhau: xác nhận đã nhận tiền là I-012 mà không
phải I-018 (không sửa gì cả); đóng phiên nhầm rồi cập nhật là I-018 mà tiền có thể không đổi. Một
lần hoàn tiền thì thuộc **cả hai**.

**Verification:**
Kịch bản dựng lại: sửa nội dung một đơn rồi đọc bản ghi ⇒ dựng lại được đơn **trước** và **sau**,
đọc được **lý do** và **tên người sửa**; xoá bất kỳ một trong bốn thứ ⇒ bản ghi **không hợp lệ**.
Kịch bản ghi đè: hai người cùng sửa một phiên bàn, người sau thắng ⇒ bản ghi giữ **cả** trạng thái
người trước vừa ghi, và lượt gọi bị đè **dựng lại được**. Kịch bản đối soát: đổi giá giữa buổi rồi
sửa một dòng của lượt gọi cũ ⇒ bảng đối soát (§6.10) đọc được **giá cũ và giá mới** của đúng dòng
ấy, nên chỗ lệch có tên thay vì thành báo động giả (I-009). Kịch bản âm của hoàn tác: thử quay
ngược một đơn `Huỷ` về `Đã xác nhận` ⇒ **bị từ chối** (I-016), và đường đi hợp lệ là **cập nhật**
kèm đủ bốn thứ trên.

*Phát hiện ở T-045, 2026-09-02 — khi chủ quán xác nhận GĐ-01 và GĐ-05 và kèm theo một yêu cầu
không ai hỏi: bản copy trước và sau.*

### I-019 — Tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng bàn

**Invariant:**
Với **mỗi** dòng nhu cầu ở bảng gom việc — khoá dòng là **thành phần + loại nhân + lượng nhân**
(`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4.6) — con số tổng luôn bằng **tổng** các phần chia
về từng bàn, không hơn một đơn vị và không kém một đơn vị. Phép gom **không** được làm mất và
**không** được đẻ ra số lượng. Câu này đúng ở **cả hai chiều**: cộng xuôi từ các bàn ra tổng, và
tách ngược từ tổng về các bàn, cho ra cùng một con số.

Hai hệ quả nằm trong cùng invariant, không tách ra:
- **Mọi đơn vị trong một dòng tổng đều có chủ.** Không tồn tại một cái bánh trên bảng mà không
  bàn nào đã gọi nó.
- **Khoá gom là ranh giới của phép cộng.** Hai thành phần khác loại nhân hoặc khác lượng nhân
  **không** được cộng vào cùng một dòng, kể cả khi cùng tên món (`shop-facts.md` §5.4, §4.5).

**Why:**
Gom việc là cách quán đang chạy hôm nay, không phải một tính năng thêm vào (`shop-facts.md` §5.4,
`docs/decisions.md` ADR-009). Nhưng **gom mà mất dấu chủ sở hữu là bưng nhầm bàn** — lời chủ quán
ngày 2026-08-31: sáu quả trứng làm chung một mẻ vẫn phải về đúng sáu bàn đã gọi chúng. Một bảng
chỉ có tổng thì nhìn có vẻ đủ, và nó hỏng đúng lúc đông khách, là lúc không ai có thời gian đi dò
lại. Chiều ngược lại cũng hỏng thật: gộp hai dòng khác nhân cho gọn thì bếp tráng **đủ số** mà
**sai ruột**, và không ai biết hỏng ở đâu cho tới lúc khách nói.

**Verification:**
Kịch bản cộng xuôi: sáu bàn mỗi bàn một combo "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân ⇒
dòng nhu cầu bánh cuốn bằng **ba lần** số bàn ấy, dòng trứng tái và dòng giò mỗi dòng bằng số bàn,
đúng ví dụ ở `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4.3. Kịch bản tách ngược: lấy chính
dòng tổng ấy chia về từng bàn ⇒ mỗi bàn ba cái bánh, một quả trứng, một chiếc giò, và **tổng phần
chia bằng đúng dòng tổng** (§3.4.4). Kịch bản khoá gom: thêm một bàn gọi combo **trứng chín, thịt,
thường** ⇒ bảng phải có **hai** dòng bánh và **hai** dòng trứng (không gộp), trong khi dòng **giò
gộp** làm một vì giò không nhận nhân — gộp nhầm bất kỳ cặp nào ⇒ **sai**. Kịch bản âm: sửa tay một
dòng tổng cho lệch khỏi tổng phần chia ⇒ bảng **không hợp lệ**. Kịch bản huỷ: huỷ một đơn ⇒ cả
dòng tổng **và** phần chia của bàn ấy giảm cùng một lượt, hai chiều vẫn khớp (§3.4.5).

*Phát hiện ở BA-12, 2026-09-03.*

### I-020 — Số đã phục vụ của một bàn không bao giờ vượt số bàn ấy đã gọi

**Invariant:**
Với mỗi bàn và mỗi thành phần, **đã phục vụ ≤ đã gọi**. Không có đường nào đưa một bàn tới chỗ
nhận nhiều hơn số nó đã gọi, kể cả khi một **mẻ** phục vụ nhiều bàn cùng lúc và một lần bấm đẩy
nhiều việc cùng lúc (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4.8). Cùng một ràng buộc áp cho
con số ở giữa: **đã làm xong, còn ở bếp** của một bàn cũng không vượt số bàn ấy đã gọi, và tổng
*đã làm xong, còn ở bếp* + *đã bưng ra bàn* của một bàn không vượt số đã gọi — ba trạng thái của
một việc trạm loại trừ nhau (`05-vong-doi.md` §5.4).

**Why:**
Con số *đã phục vụ* là thứ quầy dùng để trả lời *"bàn này còn thiếu gì"* (`shop-facts.md` §5.4,
danh sách sáu thứ quầy phải nhìn). Vượt trần nghĩa là **còn thiếu** thành số âm, và một bàn đang
chờ món sẽ biến mất khỏi danh sách chờ — khách ngồi đợi trong khi bảng ở quầy báo đã xong. Đường
vào lỗi này có thật và có tên: **mẻ là đơn vị bấm, bàn là đơn vị đếm** (chủ quán chốt 2026-09-01,
đóng U-017), nên một lần bấm chia sai về các bàn là chia thừa cho bàn này và thiếu cho bàn kia.
Đường thứ hai là **đường lùi**: quầy bấm nhầm rồi lùi lại, không có mốc thời gian cứng
(chủ quán chốt 2026-09-01, đóng U-024) — lùi mà không trả lại đúng phần đã cộng cũng ra cùng
một chỗ hỏng.

**Verification:**
Kịch bản trần: một bàn gọi ba cái bánh ⇒ bấm phục vụ cái thứ tư cho bàn ấy **bị từ chối**. Kịch
bản mẻ nhiều bàn: một mẻ phủ hai bàn, bấm *"đã làm xong"* **một** lần ⇒ phần cộng cho mỗi bàn đúng
bằng phần bàn ấy đã gọi trong mẻ, và tổng hai phần bằng đúng số của mẻ (I-019). Kịch bản đường
lùi: bấm *"đã làm xong"* một mẻ rồi **lùi** ⇒ con số của **mọi** bàn trong mẻ trở về đúng giá trị
trước khi bấm, và lần lùi để lại vết đọc được (I-012, I-018). Kịch bản huỷ: huỷ một đơn đã phục vụ
một phần ⇒ không bàn nào còn *đã phục vụ* lớn hơn *đã gọi* sau khi bảng cập nhật. Kịch bản âm của
số âm: với mọi bàn và mọi thành phần, *còn thiếu* = đã gọi − đã bưng ra bàn **không bao giờ âm**.

*Phát hiện ở BA-12, 2026-09-03.*

### I-021 — Tiền mặt đếm được trong két cuối ngày trừ đi TIỀN ĐẦU KÉT phải bằng doanh thu tiền mặt của ngày bán đó, sau khi bù các lần hoàn CHÉO phương thức, nợ cũ thu bằng tiền mặt, khoản TRẢ TRƯỚC và tiền CHI từ két

**Invariant:**
Với mỗi **ngày bán** (định nghĩa ở `docs/product/1-system-design/02-thoi-gian-ngay-ban.md`, pha 1):

```
(tiền mặt đếm trong két cuối ngày)  −  (tiền đầu két của ngày bán đó)
      =  (doanh thu TIỀN MẶT của ngày bán đó)
      −  (hoàn trả bằng TIỀN MẶT trong ngày, cho khoản đã thu bằng CHUYỂN KHOẢN)
      +  (hoàn trả bằng CHUYỂN KHOẢN trong ngày, cho khoản đã thu bằng TIỀN MẶT)
      +  (nợ cũ thu bằng TIỀN MẶT trong ngày)
      +  (trả trước nhận bằng TIỀN MẶT trong ngày)
      −  (phần TIỀN MẶT của trả trước đã thành doanh thu trong ngày)
      −  (trả trước trả lại bằng TIỀN MẶT trong ngày)
      −  (tiền lấy khỏi két trong ngày để trả một KHOẢN CHI, một khoản TẠM ỨNG hay một khoản THƯỞNG)
```

*Thêm hạng tử cuối 2026-10-01 (T-125, `docs/decisions.md` **ADR-074**).* Chủ quán chốt 2026-09-30
rằng điện, nước, wifi, xăng xe, tạm ứng và thưởng đều lấy **từ két bán hàng** (`U-066` · `U-067`,
`master_plan/shop-facts.md` §8.7 · §8.10), và 2026-10-01 tiền ấy được xác nhận rời két **trong
ngày, trước lúc đếm két cuối ngày** (§8.10). Hạng tử gồm: **mọi** khoản tạm ứng và **mọi** khoản
thưởng của `I-028`, và mọi khoản chi của `I-029` mà **loại** của nó mang nguồn *két bán hàng*. Chi
lặt vặt bằng tiền riêng của chủ quán (`E46`) **không** đứng ở đây — nó là tiền hàng, không phải
khoản chi, và không rời két. Mỗi khoản trong hạng tử đã có người đứng tên — người ghi, và với tạm
ứng thêm người duyệt — nên hạng tử mở ra được thành danh sách từng khoản như mọi hạng tử khác.
**Khoản ấy trừ vào két của NGÀY NGƯỜI GHI KHAI cho khoản**, không phải ngày tiền rời két (chủ
quán chốt 2026-10-09, đóng **U-072**; `master_plan/shop-facts.md` §8.10 `E46`). Mệnh đề giữ vế
*mỗi khoản rời két trừ vào đúng MỘT ngày bán* — ngày ấy là ngày khai. *Thêm 2026-10-09, T-139;
bộ đối chiếu và cửa đóng ngày còn đọc theo luật cũ cho tới `T-140`.*

*Thêm bốn hạng tử cuối 2026-09-28 (T-112, `docs/decisions.md` **ADR-059**, đóng
`work/findings.md` **F-037**).* Ba hạng tử trả trước là phần tiền mặt của ba dòng trả trước trong
công thức đối soát `docs/product/1-system-design/architecture.md` §6.4: doanh thu của khoản trả
trước tính vào **ngày giao/lấy** (`master_plan/shop-facts.md` §6.26, **ADR-040**), còn tiền vào két
**hôm nhận**. Hạng tử *nợ cũ thu bằng tiền mặt* không thuộc F-037 — lượt đọc lại mệnh đề này tìm ra
nó chưa từng có, trong khi khoản ấy vào két mà **không** vào doanh thu ngày nào (`shop-facts.md`
§6.14). Một khoản được trả lại bằng **chuyển khoản** thì két không đổi, nên không có hạng tử.
**Lần trả lại trả trước KHÔNG đi hai hạng tử hoàn chéo ở trên**, kể cả khi nhận bằng chuyển khoản
mà trả bằng tiền mặt: hai hạng tử ấy bù cho một lần hoàn **đã trừ vào doanh thu** của phương thức
đã thu, còn khoản trả trước chưa thành doanh thu thì không có doanh thu nào để trừ. Nó có đúng một
hạng tử, theo phương thức **trả lại** — đi cả hai đường là đếm nó hai lần.

*Viết lại 2026-09-15 (T-073, `docs/decisions.md` **ADR-046**)* — đúng như điều kiện biên thứ hai
dưới đây đã viết sẵn từ 2026-09-04: chủ quán chốt 2026-09-08 (`U-044` ⇒ `master_plan/shop-facts.md`
§6.4) rằng hoàn tiền **trả lại bằng gì** cũng do POS quyết từng ca, nên có tiền rời két trong buổi
mà doanh thu tiền mặt không chứa. *Doanh thu tiền mặt* giữ nguyên nghĩa cũ: một lần hoàn trừ vào
doanh thu của **phương thức đã thu**, nên hoàn **cùng** phương thức không cần hạng tử nào — hai hạng
tử mới chỉ khác 0 ở ca **chéo**.

Hai vế bằng nhau **đúng bằng 0đ**, không có ngưỡng dung sai — cùng ngưỡng §6.10 của
`master_plan/shop-facts.md` (**ADR-022**). Invariant này chỉ nói về phần **tiền mặt**: phần chuyển
khoản đối chiếu với tin nhắn báo có và **không** được cộng gộp vào phép trừ này (§6.10, **I-014**).

Ba điều kiện biên của cùng mệnh đề:

- **Mỗi ngày bán có đúng MỘT con số tiền đầu két** — mặc định cố định, sửa được
  (`shop-facts.md` §8.5). Một ngày **không có** con số ấy thì phép trừ không chạy được, và ngày ấy
  **chưa** đối soát xong; nó không được coi là *"lệch"*.
- **Ba đường duy nhất làm tiền két vơi trong buổi mà doanh thu tiền mặt không chứa là một lần hoàn
  tiền MẶT cho khoản đã CHUYỂN KHOẢN, một lần trả lại TIỀN MẶT cho khoản trả trước chưa thành
  doanh thu, và một lần lấy tiền khỏi két để trả một khoản chi, tạm ứng hay thưởng** — cả ba đã có
  hạng tử ở trên (đường thứ hai thêm 2026-09-28, **ADR-059**; đường thứ ba thêm 2026-10-01,
  **ADR-074**, viết lại điều kiện này đúng như nó tự đòi). Quán **không** có nghiệp vụ nộp bớt tiền
  giữa buổi (chủ quán chốt 2026-09-04, `A4` ⇒ §8.5) — lời ấy vẫn đứng: lấy tiền để **trả một khoản
  có tên** không phải nộp bớt —, nên ngoài các hạng tử ấy **không** có khoản rút nào phải cộng lại. Mỗi lần hoàn chéo phải đọc ra được từ vết hoàn tiền —
  vết ấy nay ghi cả **phương thức trả lại** (§6.4) — nên hai hạng tử mới mở ra được thành danh sách
  từng khoản có người đứng tên, không phải một con số tự khai lúc đếm két. Nếu một ngày quán có
  thêm một đường tiền rời két nữa thì công thức lại **thiếu một hạng tử**, và invariant này phải
  viết lại, không phải viết thêm.
- **Tiền đầu két KHÔNG phải doanh thu.** Nó không bao giờ được cộng vào bất kỳ con số doanh thu
  nào, kể cả con số *dự tính* ở mục tổng quan của chủ quán (§8.6, vế 5).

**Why:**
Két cuối ngày **đã chứa** tiền đầu két. So thẳng nó với doanh thu tiền mặt thì lệch **đúng bằng**
tiền đầu két, **mọi ngày** — và cái vỡ không phải một con số, mà là **cổng chất lượng mạnh nhất
của cả dự án**: ngưỡng *lệch 1 đồng cũng phải tìm ra lý do* (§6.10) báo đỏ mỗi ngày vì một lý do
đã biết trước, nên người dùng học cách bỏ qua nó — và từ hôm ấy một chỗ mất tiền **thật** cũng đi
qua cùng cái đỏ ấy mà không ai nhìn. `docs/product/1-system-design/architecture.md` §14.3 đã gọi
tên chỗ trống này trước khi có lời chủ quán: *"tiền đầu buổi và tiền nộp về chưa nằm trong phép
tính đối soát"*.

Mệnh đề gắn vào **ngày bán** chứ không vào một biến cố *mở ca*, vì quán **không có** khái niệm mở
ca / đóng ca (chủ quán chốt 2026-09-04, `A2` ⇒ §6.23, `docs/decisions.md` **ADR-038**).

**Verification:**
Kịch bản cơ sở: một ngày bán, tiền đầu két **1.200.000**, bán **800.000** toàn bộ bằng tiền mặt ⇒
két đếm được **2.000.000**, phép trừ ra **800.000**, khớp doanh thu tiền mặt ⇒ **xanh**. Kịch bản
quên trừ: cùng số liệu nhưng phép so bỏ qua tiền đầu két ⇒ lệch **1.200.000** ⇒ phải **đỏ**, và
đỏ với lý do gọi tên được, không phải một con số lệch vô danh. Kịch bản hai phương thức: ngày ấy có
thêm **500.000** chuyển khoản ⇒ phép trừ trên **không đổi** (vẫn ra 800.000) và phần 500.000 đối
chiếu riêng với tin nhắn báo có; cộng gộp hai phương thức rồi so một con số tổng ⇒ phải **đỏ**
(I-014, §6.10). Kịch bản sửa con số mặc định: một ngày chủ quán bỏ vào **1.000.000** thay vì mặc
định ⇒ phép trừ dùng con số **của ngày ấy**, không dùng mặc định. Kịch bản thiếu dữ kiện: một ngày
**chưa** có con số tiền đầu két ⇒ ngày ấy báo **chưa đối soát xong**, **không** báo lệch — cùng
hình dạng với ngày còn `N > 0` lượt bán trên giấy chưa nhập (**ADR-037**). Kịch bản không có rút
giữa buổi: không đường nào trong hệ thống làm giảm tiền két trong buổi mà không phải một lần
hoàn tiền có vết (§6.4, I-012). Kịch bản hoàn **chéo** (thêm 2026-09-15, ADR-046): cùng ngày cơ
sở, một khách đã chuyển khoản **60.000** được POS hoàn bằng **tiền mặt** lấy trong két ⇒ két đếm
được **1.940.000**, phép trừ ra **740.000**; doanh thu tiền mặt vẫn **800.000**, hạng tử hoàn chéo
**60.000** ⇒ vế phải **740.000** ⇒ **xanh**. Cùng số liệu mà bỏ hạng tử hoàn chéo ⇒ lệch
**60.000** ⇒ phải **đỏ**, và lý do gọi tên được là *một lần hoàn chéo chưa được bù*. Chiều ngược:
một khách đã trả tiền mặt **60.000** được hoàn bằng **chuyển khoản** ⇒ két **vẫn** 2.000.000,
doanh thu tiền mặt còn **740.000**, hạng tử cộng **60.000** ⇒ vế phải **800.000** ⇒ **xanh**. Một
lần hoàn mà vết **không** ghi phương thức trả lại ⇒ ngày ấy **chưa** đối soát xong, không phải
*"lệch"* — cùng hình dạng ngày chưa có tiền đầu két.
Kịch bản **trả trước** (thêm 2026-09-28, ADR-059), tiền đầu két **1.200.000** cả hai ngày: thứ Hai
bán **800.000** tiền mặt, nhận trả trước **50.000** tiền mặt cho đơn B và **40.000** chuyển khoản
cho đơn E, cả hai lấy hàng thứ Ba ⇒ két **2.050.000**, phép trừ ra **850.000**; vế phải
800.000 + 50.000 = **850.000** ⇒ **xanh**; bỏ hạng tử *trả trước nhận* ⇒ lệch **50.000** ⇒ phải
**đỏ**. Thứ Ba bán **700.000** tiền mặt, đơn B đóng (doanh thu tiền mặt thứ Ba gồm cả 50.000 của
nó, tức **750.000**), đơn E huỷ và POS trả lại **40.000** bằng tiền mặt trong két ⇒ két
**1.860.000**, phép trừ ra **660.000**; vế phải 750.000 − 50.000 − 40.000 = **660.000** ⇒ **xanh**.
Doanh thu thứ Hai **không** chứa 50.000 của B, doanh thu thứ Ba **không** bị trừ 40.000 của E
(`I-014`). Kịch bản **trả nợ bằng tiền mặt**: cùng ngày cơ sở, bàn 5 trả **100.000** nợ của hôm
trước bằng tiền mặt ⇒ két **2.100.000**, phép trừ ra **900.000**; vế phải 800.000 + 100.000 ⇒
**xanh**; bỏ hạng tử ấy ⇒ lệch **100.000** ⇒ phải **đỏ**.
Kịch bản **chi từ két** (thêm 2026-10-01, ADR-074): cùng ngày cơ sở, giữa buổi chủ quán lấy
**300.000** trong két trả tiền điện và đưa một người làm **200.000** tạm ứng có chủ quán duyệt ⇒ két
đếm được **1.500.000**, phép trừ ra **300.000**; vế phải 800.000 − 300.000 − 200.000 = **300.000** ⇒
**xanh**. Bỏ hạng tử ấy ⇒ lệch **500.000** ⇒ phải **đỏ**, và hạng tử mở ra được thành **hai** khoản
có người ghi. Cùng ngày mà tiền điện ghi dưới một loại chi mang nguồn *không phải két* ⇒ vế phải
**600.000**, lệch **300.000** ⇒ **đỏ** — đúng: tiền đã rời két mà sổ nói không. Một lần mua quất
bằng tiền riêng ⇒ **không** vào hạng tử, két không đổi.

**Phép đếm ở vế trái: CẢ bảng mệnh giá LẪN tổng — phép trừ dùng TỔNG** (chủ quán chốt 2026-09-06,
đóng **U-038**, `master_plan/shop-facts.md` §8.5: bảng mệnh giá là cách đếm và kiểm cuối ngày). Phép
kiểm của mệnh đề này **so tổng**, không so từng dòng mệnh giá: một lần đổi tiền thối trong buổi làm
một dòng mệnh giá lệch mà tổng vẫn khớp, và đó không phải lệch. *Sửa 2026-10-05 (`T-133`): đoạn này
tới hôm ấy vẫn ghi U-038 là câu chưa có lời — con trỏ lệch từ 2026-09-06; số đếm cuối ngày có chỗ cất
và câu đối chiếu `I-021/1` từ cùng task (`docs/decisions.md` **ADR-079**).*

*Phát hiện ở T-056, 2026-09-04, từ lời chủ quán trả lời `A3` và `A4`.*
*Viết lại ở T-073, 2026-09-15, từ lời chủ quán trả lời `U-044` (2026-09-08).*
*Thêm bốn hạng tử ở T-112, 2026-09-28 — ba cho khoản trả trước (`U-036`, ADR-040), một cho nợ cũ thu bằng tiền mặt; `docs/decisions.md` **ADR-059**.*
*Thêm hạng tử chi từ két ở T-125, 2026-10-01 — từ lời `U-066` · `U-067` (2026-09-30) và lời *trong ngày, trước lúc đếm két* (2026-10-01); `docs/decisions.md` **ADR-074**; ngày bán của khoản chờ **U-072**.*

### I-022 — Một đơn mang đi không tồn tại được khi thiếu một trường liên hệ bắt buộc của kênh và cách trao hàng của nó

**Invariant:**
Với mọi đơn của **ba kênh không gắn bàn** — Delivery, Pickup, Đặt trước qua hotline — tại **mọi**
thời điểm đơn ấy tồn tại, đơn mang đủ mức liên hệ tối thiểu mà chủ quán đã chốt cho **kênh** và
**cách trao hàng** của nó. Bảng trường nào bắt buộc ở kênh nào có nhà duy nhất ở
`master_plan/shop-facts.md` §6.5 và được đọc thành ba câu ở
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.2.4 — **đọc ở đó, đây cố ý không chép**
(`work/findings.md` **F-001**). Mệnh đề này có bốn vế:

- **Số điện thoại** — mọi đơn của cả ba kênh.
- **Địa chỉ giao** — mọi đơn mà cách trao hàng là **giao tận nơi**: luôn luôn với Delivery, và với
  đơn hotline khi khách chọn giao. Đơn **tới lấy** — Pickup, hoặc hotline khách tới lấy — **không**
  bị đòi địa chỉ.
- **Giờ khách cần hàng** — mọi đơn Pickup và mọi đơn hotline.
- **Cách trao hàng của một đơn hotline** — đúng **một** trong hai nhánh, giao tận nơi hoặc tới lấy
  (`03-lat-cat.md` §3.2.1 bước 2 · §3.2.2). Không có nó thì vế địa chỉ không có gì để đọc. Với
  Delivery và Pickup, cách trao hàng chính là kênh — khách đã chọn lúc bấm.

Chiều ngược cũng thuộc mệnh đề: một trường mà §6.5 ghi *nên có* hoặc *tuỳ tình huống* **không**
chặn tạo đơn — phần ấy người ở quầy điền theo tình huống thật. Mệnh đề **không** áp cho `qr_table`
và `staff_pos`: khách ngồi bàn ẩn danh theo số bàn (`03-lat-cat.md` §3.2.4).

**Mệnh đề nói *thiếu*, không nói *sai*.** Một số điện thoại có mặt nhưng gọi không được, một địa
chỉ có mặt nhưng không tìm ra, không phải trạng thái mệnh đề này chặn: chủ quán chưa chốt luật nào
về định dạng hay độ đúng của hai trường ấy, và đừng tự viết một luật như thế ở đây
(`docs/product/99-unknowns.md` là chỗ ghi nếu cần hỏi).

**Why:**
Hai trường bắt buộc là **hệ quả của luồng**, không phải sở thích (`shop-facts.md` §6.5): không có
số thì không gọi lại được khi tới nơi, không có địa chỉ thì quán tự đi giao vào đâu. Ba trong năm
kênh là kênh **khách tự bấm** (`shop-facts.md` §2), nên đây là chỗ dữ liệu vào hệ thống **không
qua tay người của quán**. Một đơn giao tận nơi thiếu địa chỉ lộ ra ở chỗ muộn nhất có thể: bếp đã
làm, đã đóng gói, người đi giao đã cầm hàng — và đường ra khi ấy là **huỷ**, cộng **hoàn tiền** nếu
khách đã trả trước, tức đường không có luật cứng (`shop-facts.md` §6.4). Đơn Pickup thiếu giờ hẹn
thì quán không biết làm lúc nào cho kịp, đúng chỗ mà đường báo đơn về quầy phải tới *trước giờ hẹn
của đơn sớm nhất* (`docs/product/1-system-design/01-ranh-gioi-he-thong.md` §3, `PT-5`).

Luật đã chốt từ **2026-08-30** (chủ quán xác nhận thẳng hai trường bắt buộc, `shop-facts.md` §6.5
· §7.1) và pha 0 viết nó thành điều kiện tạo đơn ở §3.2.1 bước 3. Nó chưa từng thành mệnh đề vì
lượt BA-04 viết mệnh đề `I-007` — câu về **tiền** — cho cùng lát cắt, và không lượt nào sau đó hỏi
§3.2.4 *"chỗ này có mệnh đề chưa"* (`work/findings.md` **F-038**).

**Verification:**
Kịch bản âm, một vế một lần: tạo một đơn Delivery thiếu địa chỉ ⇒ **bị từ chối**; một đơn Pickup
thiếu giờ hẹn lấy ⇒ **bị từ chối**; một đơn của bất kỳ kênh nào trong ba kênh thiếu số điện thoại ⇒
**bị từ chối**; một đơn hotline chưa có cách trao hàng ⇒ **bị từ chối**; một đơn hotline khách chọn
giao mà thiếu địa chỉ ⇒ **bị từ chối**. Kịch bản dương, chống đọc rộng: một đơn hotline khách **tới
lấy**, có số và giờ, **không** địa chỉ ⇒ **tạo được**; một đơn Pickup không địa chỉ ⇒ **tạo được**;
một đơn Delivery không giờ khách cần hàng và không tên ⇒ **tạo được** (hai trường *nên có*). Kịch
bản sửa: một đơn Delivery đã tạo, thử xoá trắng địa chỉ của nó ⇒ **bị từ chối** — mệnh đề giữ ở
**mọi** thời điểm, không chỉ lúc tạo. Kiểm ngược, bất kỳ lúc nào: không đơn nào của ba kênh đang
tồn tại mà thiếu một trường mà kênh và cách trao hàng của nó đòi.

*Phát hiện ở P1-11, 2026-09-08 (`work/findings.md` **F-038**). Viết thành mệnh đề ở T-110,
2026-09-28, Claude Code — luật nguồn đã chốt, không hỏi thêm chủ quán.*

### I-023 — Một lượt gọi QR tại bàn chỉ vào được bàn mà mã HIỆN HÀNH của nó chỉ tới; mã của một bàn không suy ra được từ bàn khác, và đổi được

**Invariant:**
Kênh **QR tại bàn** (`qr_table`) gắn một lượt gọi vào phiên bàn **theo mã dán ở bàn** — khách ẩn
danh theo số bàn (`master_plan/shop-facts.md` §2 · `docs/product/0-ba/ban-hang/02-kenh-ban.md`), nên
mã là thứ duy nhất nói *lượt gọi này của bàn nào*. Mệnh đề có bốn vế:

- **Bàn của lượt gọi do hệ thống tra từ mã.** Bàn của một lượt gọi `qr_table` là bàn mà mã nó mang
  đang chỉ tới **tại mốc tạo lượt gọi**; một số bàn hay định danh bàn nào đến từ phía khách **không
  bao giờ** được dùng, kể cả khi nó trùng đúng bàn ấy — cùng hình với giá của `I-013`. Lượt gọi ghi
  lại được nó đã mang **mã nào**.
- **Một mã, một bàn.** Tại mọi thời điểm, một bàn có **nhiều nhất một** mã hiện hành, và một mã —
  hiện hành hay đã bị thay — chỉ tới **nhiều nhất một** bàn trong suốt đời nó: mã đã thay không được
  cấp lại cho bàn khác.
- **Không đoán được.** Biết mã của một bàn — hay của **mọi** bàn khác — không cho suy ra mã của một
  bàn còn lại, và không cho suy ra mã **kế tiếp** của chính bàn ấy. Mã không mang thông tin nào đọc
  ra được từ số bàn, từ thứ tự hay từ thời điểm nó được sinh.
- **Đổi được, và mã cũ chết ngay.** Một bàn được cấp mã mới mà **không** đổi số bàn và không chạm
  phiên bàn đang mở của nó. Từ mốc đổi, mã cũ **không tạo được lượt gọi nào nữa**; lượt gọi đã tạo
  bằng mã cũ **trước** mốc ấy giữ nguyên — không bị huỷ, không đổi bàn. Mỗi lần đổi đọc ra được bàn
  nào, lúc nào, ai đổi (`I-018`).

**Mệnh đề không nói ai được đổi mã, và khi nào quán đổi.** Đó là câu của chủ quán — đã trả lời
2026-09-28 (**U-062** đóng, T-118): **chỉ chủ quán** đổi, đổi **khi quán bị hack**; owner
`master_plan/shop-facts.md` §6 quy tắc 2 — không phải câu của mệnh đề này. Nó cũng **không** nói mã
sinh bằng gì: đó là cơ chế của pha sau.

**Why:**
Mã đoán được, hay lộ mà không đổi được, thì một người **đã từng ngồi quán** gọi món ghi vào hoá đơn
**bàn khác**, và bàn ấy trả cho thứ mình không gọi — hoặc cãi với quầy lúc tính tiền, đúng lúc đông
khách. Đó là mất tiền ở **phiên bàn**, cùng loại với thu thiếu của `I-002`: một lượt gọi đứng sai đơn
vị tính tiền. Lớp người đang có là **quầy duyệt** mọi đơn QR (`shop-facts.md` §6 quy tắc 2), nhưng
quầy duyệt theo **số bàn trên đơn**, không biết ai đang cầm điện thoại — nên quầy chặn được đơn vào
một bàn **đang trống**, không chặn được đơn vào một bàn **đang có khách** gọi thật. Bằng chứng từ dự
án cũ, không phải dữ kiện quán này (`work/proposals/from_old_project/data_base/nghien-cuu.md` §2.1): mã
sinh bằng một hàm dựa trên thời gian cho cả loạt bàn cùng lúc ⇒ có một mã là suy ra các mã kia; và
không có đường đổi mã, nên lộ một lần là hỏng vĩnh viễn.

*Mã cũ chết ngay* là **suy ra**, không phải lời chủ quán (`CLAUDE.md` §7.2): đổi mã chỉ có nghĩa nếu
mã cũ hết dùng được, và quán không mất đường bán nào khi tem mới chưa dán kịp — khách ngồi bàn ấy
gọi qua quầy đặt hộ, nhánh đã có (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.2). Chủ quán nói
khác thì mệnh đề viết lại qua một câu hỏi mới — lời đóng **U-062** không chạm tới vế này.

**Verification:**
Kịch bản âm: gửi một lượt gọi QR mang mã của bàn 5 kèm *số bàn 7* từ phía khách ⇒ lượt gọi vào **bàn
5**, không vào bàn 7; gửi một lượt gọi mang một mã không chỉ tới bàn nào ⇒ **bị từ chối**; đổi mã
bàn 5, rồi gửi một lượt gọi mang **mã cũ** ⇒ **bị từ chối**; cấp cho bàn 7 một mã đang hoặc đã từng
là mã của bàn 5 ⇒ **bị từ chối**. Kịch bản dương: lượt gọi tạo bằng mã cũ **trước** lần đổi vẫn ở
phiên của bàn 5, không đổi bàn, không bị huỷ; đổi mã một bàn đang có phiên mở ⇒ phiên giữ nguyên,
số bàn giữ nguyên. Kịch bản đoán: sinh mã cho **mọi** bàn trong cùng một lượt, và sinh lại mã của
cùng một bàn hai lần ⇒ không mã nào chứa số bàn, không hai mã nào chung một phần đọc ra được thứ tự
hay thời điểm sinh. Kiểm ngược, bất kỳ lúc nào: không lượt gọi `qr_table` nào có bàn khác bàn mà mã
nó mang chỉ tới lúc tạo, hoặc có mốc tạo **sau** lúc mã nó mang bị thay; không mã nào từng chỉ tới
hai bàn.

*Phát hiện ở T-097, 2026-09-25 (`work/findings.md` **F-042**). Viết thành mệnh đề ở T-113,
2026-09-28, Claude Code — ai đổi mã, khi nào đổi là câu của chủ quán (**U-062**, đóng cùng ngày ở
T-118: chủ quán đổi, khi bị hack).*

### I-024 — Một lần gửi sinh nhiều nhất MỘT đơn, dù máy gửi lại bao nhiêu lần; hai lần gửi khác nhau là hai đơn, kể cả khi giống hệt nhau

**Invariant:**
Mệnh đề áp cho **mọi** cửa tạo đơn của **cả năm** kênh (`master_plan/shop-facts.md` §2) — đơn mang
đi của ba kênh không gắn bàn, và **lượt gọi** vào phiên bàn của hai kênh gắn bàn (ở đây gọi chung là
*đơn*). Một **lần gửi** là một lần một người bấm gửi một đơn — khách trên web hay trên điện thoại
quét QR, người của quán trên POS; mọi lần máy **gửi lại** cùng lần bấm ấy vì mạng chập chờn, vì không
nhận được trả lời, hay vì người bấm thêm lần nữa trên cùng màn chưa kịp đổi, là **cùng một** lần gửi.
Mệnh đề có năm vế:

- **Một lần gửi, nhiều nhất một đơn.** Hai đơn không bao giờ cùng sinh ra từ một lần gửi — kể cả khi
  các lần gửi lại tới gần như cùng một lúc.
- **Mọi đơn đọc ra được lần gửi nào đã sinh ra nó.** Mỗi lần gửi mang một **dấu lần gửi** do phía gửi
  đặt **một lần**, lúc người bấm gửi, và giữ nguyên trên mọi lần gửi lại; hai lần gửi khác nhau không
  bao giờ mang chung một dấu. Một đơn không mang dấu nào là cách đi vòng qua vế trên.
- **Lần gửi lại nhận lại đúng đơn đã sinh.** Tới sau khi đơn đã có, lần gửi lại được trả lời bằng
  **chính đơn ấy** — không phải một đơn thứ hai, và không phải một lời từ chối khiến người gửi tưởng
  đơn chưa đi. Câu ấy đúng cả khi đơn đã đổi trạng thái sau đó, và cả khi cửa tạo đơn đã đóng theo
  `I-008` sau lần tạo: đơn tạo **trước** lúc đóng không bị chạm tới (`I-008`), và lần gửi lại không
  phải một đơn mới. Lần gửi đầu **bị từ chối** thì không có đơn nào mang dấu ấy, và lần gửi lại được
  xét như lần đầu.
- **Cùng dấu mà khác nội dung thì bị từ chối.** Một lần gửi mang dấu của một đơn đã có mà nội dung
  khác đơn ấy **bị từ chối**, và đơn đã có giữ nguyên — lần gửi lại không phải một đường sửa đơn;
  sửa đơn có đường riêng của nó, với vết của `I-018`.
- **Nội dung giống hệt không phải là trùng.** Hai lần gửi có dấu khác nhau là **hai** đơn, kể cả khi
  món, số lượng, bàn hay số điện thoại giống hệt nhau: khách ngồi bàn gọi thêm đúng món vừa gọi là
  một lượt gọi thật (`shop-facts.md` §5.1), và một khách đặt hai đơn tới lấy cách nhau mười phút là
  hai đơn (kịch bản đếm của `I-007`). Không cửa tạo đơn nào gộp hay bỏ một lần gửi vì nó **trông
  giống** một đơn đã có.

**Mệnh đề không nói dấu lần gửi sinh bằng gì, cất ở đâu, hay giữ bao lâu** — đó là cơ chế của pha
sau. Nó nói dấu phải riêng cho từng lần gửi, và một dấu đã sinh ra một đơn thì **không bao giờ** sinh
ra đơn thứ hai, không có hạn thời gian. Mệnh đề **không** nói về lần bấm *đã nhận tiền* hai lần: tổng
đã thu vượt số phải trả đã không tồn tại được theo `I-015`.

**Why:**
Đơn trùng làm mất tiền theo hai chiều, và cả hai chỉ lộ ra **sau** khi bếp đã làm. Với ba kênh không
gắn bàn, mỗi đơn là một đơn vị thanh toán riêng (`I-007`): đơn trùng thành **hai lần thu**, hoặc hai
suất bếp làm mà chỉ một suất có người lấy. Với hai kênh gắn bàn, lượt trùng đổ vào cùng phiên
(`I-001`) và hoá đơn cộng mọi lượt gọi (`I-002`), nên khách bị tính gấp đôi lúc tính tiền. Hai kênh
do người của quán nhập — `staff_pos`, `phone_preorder` — **không** qua bước duyệt
(`shop-facts.md` §6 quy tắc 2), nên một lần bấm đúp lúc đông đi thẳng xuống bếp mà không người nào
nhìn thấy trước. Bằng chứng từ dự án cũ, không phải dữ kiện quán này
(`work/proposals/from_old_project/data_base/nghien-cuu.md` §3.1): cả cửa khách quét QR bằng mạng yếu
lẫn cửa nhân viên bấm lúc đông đều dính, và cách *kiểm rồi mới ghi* ở tầng code thua khi hai lần gửi
tới gần như cùng lúc.

Vế **nội dung giống hệt không phải là trùng** chống cách chữa sai dễ nghĩ ra nhất — so nội dung để
đoán trùng — vì cách ấy **bỏ** một lượt gọi thêm có thật, tức thu thiếu, cùng loại với cái mệnh đề
chống. Hai vế **lần gửi lại nhận lại đúng đơn** và **cùng dấu khác nội dung bị từ chối** là **suy
ra**, không phải lời chủ quán (`CLAUDE.md` §7.2): vế đầu vì một lời từ chối cho lần gửi lại khiến
khách đặt lại từ đầu — một lần gửi **mới**, mà không vế nào của mệnh đề chặn được; vế sau vì không
thế thì lần gửi lại thành một đường sửa đơn không để vết.

**Verification:**
Kịch bản âm: gửi một đơn Pickup, rồi gửi lại **cùng dấu** năm lần, có hai lần tới gần như cùng lúc ⇒
đúng **một** đơn tồn tại, cả sáu lần đều nhận lại đơn ấy; làm như thế với một lượt gọi `qr_table` vào
bàn 5 và một lượt gọi `staff_pos` ⇒ phiên bàn 5 có **một** lượt gọi mới, không phải hai; gửi lại cùng
dấu mà đổi số lượng ⇒ **bị từ chối**, đơn đầu giữ nguyên số lượng cũ; tạo một đơn không mang dấu nào
⇒ **bị từ chối**. Kịch bản biên: gửi một đơn lúc 10:59 và được tạo, lần gửi lại tới lúc 11:00:30 ⇒
nhận lại đơn đã tạo, **không** phải câu *ngoài giờ bán*; lần gửi đầu bị từ chối vì thiếu địa chỉ
(`I-022`), gửi lại cùng dấu khi đã điền ⇒ **tạo được**. Kịch bản dương, chống đọc rộng: bàn 5 gọi hai
suất, mười phút sau gọi thêm đúng hai suất ấy bằng một lần gửi mới ⇒ **hai** lượt gọi, hoá đơn tính
cả hai; một khách đặt hai đơn tới lấy giống hệt nhau cách nhau mười phút ⇒ **hai** đơn. Kiểm ngược,
bất kỳ lúc nào: không hai đơn nào mang chung một dấu lần gửi, và không đơn nào không mang dấu.

*Phát hiện ở T-097, 2026-09-25 (`work/findings.md` **F-043**). Viết thành mệnh đề ở T-115,
2026-09-28, Claude Code — không câu nào phải hỏi chủ quán; hai vế **suy ra** ghi rõ ở trên.*

### I-025 — Con số nguyên liệu chỉ đổi khi có NGƯỜI nhập nó; không thao tác bán hàng nào làm đổi nó, và máy không tự tính ra con số nào

**Invariant:**
Mệnh đề của **mảng quản trị** — sổ nguyên liệu ở mức *sổ ghi tay điện tử*
(`master_plan/shop-facts.md` §8.4). *Con số nguyên liệu* là hai con số của sổ ngày: **mua vào** và
**đã dùng** của một thứ trong danh mục, trong một ngày. Mệnh đề có bốn vế:

- **Mọi con số do một người gõ vào.** Một con số tồn tại thì đọc ra được **ai** đã nhập nó, nó thuộc
  **ngày nào**, và **lúc** nó được gõ vào máy. Không con số nào sinh ra mà không có người nhập.
- **Không thao tác bán hàng nào chạm tới nó.** Tạo đơn, duyệt đơn, huỷ đơn, hoàn tiền, đóng phiên,
  bấm một mẻ — không việc nào sinh, cộng hay trừ một con số nguyên liệu. Đường duy nhất để một con
  số đổi là có người nhập nó (`docs/product/0-ba/admin/01-ranh-gioi.md` §1.6).
- **Máy không giữ thứ gì để tự tính thay người.** Không có định lượng của một suất bán, không có
  ngưỡng nhắc sắp hết cho bất kỳ thứ nào, và không có kết luận *thiếu* · *sắp hết* nào do máy đặt ra
  — cả ba là bảng *máy KHÔNG làm* của §8.4 (chốt 2026-09-04 và 2026-09-15).
- **Sửa một con số đã nhập là một lần cập nhật.** Nó để lại bản trước, bản sau, lý do và người sửa
  theo `I-018`; không có đường sửa đè.

**Mệnh đề không nói** ai được phép nhập (đó là quyền, pha 3), một thứ ghi theo đơn vị gì
(`work/admin-questions.md` câu **B12**), hay con số *đã dùng* có đúng với thực tế không — đó là ước
lượng của người, máy chỉ chép lại.

**Why:**
Chủ quán chốt máy là chỗ **chép lại** con số người ghi, không phải chỗ **tự tính ra** con số
(`shop-facts.md` §8.4, 2026-09-01, xác nhận lại 2026-09-04). Một đường tự trừ theo suất bán trông
như một tiện ích, nhưng nó đòi định lượng từng thành phần — đúng thứ chủ quán trả lời **không** ở
câu **B22** (2026-09-25) — và nó làm con số trong sổ khác con số chủ quán đã gõ mà không ai bấm gì.
Từ lúc ấy chủ quán không còn đọc được sổ của chính mình. Vế *ai · ngày nào · lúc nào* là thứ làm
một con số lạ truy về được một người, và là nguồn của *thời gian nhập* chủ quán muốn thấy ở mục
tổng quan (`U-051`, 2026-09-16).

**Verification:**
Kịch bản âm: diễn một buổi bán đủ năm kênh — tạo, duyệt, huỷ, hoàn tiền, đóng phiên, bấm mẻ — rồi
đọc lại sổ nguyên liệu ⇒ **không một con số nào đổi** so với trước buổi; tạo một con số không có
người nhập, hoặc không có ngày ⇒ **bị từ chối**. Kịch bản dương: chủ quán nhập *mua vào 10* và *đã
dùng 7* cho gạo ngày hôm nay ⇒ cả hai đọc lại được kèm người nhập, ngày và lúc gõ, sau nhiều ngày.
Kịch bản sửa: đổi *đã dùng 7* thành *8* ⇒ đọc ra được cả 7 lẫn 8, lý do và người sửa. Kiểm ngược,
bất kỳ lúc nào: không con số nào thiếu người nhập hay thiếu ngày; và đọc lược đồ ⇒ không chỗ nào
cất một ngưỡng, một định lượng suất, hay một kết luận thiếu · sắp hết.

*Viết ở P2A-01, 2026-09-30, Claude Code — từ lời chủ quán đã có ở `shop-facts.md` §8.4; không câu
nào phải hỏi thêm. Vế **lúc gõ vào máy** đứng cạnh **ngày của con số** là cách đọc của phiên viết
cho chữ *thời gian nhập*, không phải lời chủ quán. **2026-09-30 (`P2A-03`):** chủ quán đóng `U-068` —
*thời gian nhập* là **lúc hàng mua về**, tức vế **ngày của con số**; vế lúc gõ vào máy đứng nguyên
như vết *ai nhập, khi nào*.*

### I-026 — Tổng đã nhập, tổng đã dùng và hiệu số của một thứ luôn bằng ĐÚNG phép cộng các con số ngày của nó; cộng dồn từ ngày mua, không bao giờ đặt lại

**Invariant:**
Với **mỗi** thứ trong danh mục nguyên liệu (`master_plan/shop-facts.md` §8.4), mệnh đề có bốn vế:

- **Tổng là phép cộng, không phải một con số tự đứng.** *Tổng đã nhập* bằng đúng tổng mọi con số
  *mua vào* của thứ ấy; *tổng đã dùng* bằng đúng tổng mọi con số *đã dùng*. Không có đường nào ghi
  một con số tổng mà không qua các con số ngày.
- **Hiệu số là một phép trừ trên hai tổng ấy.** *Thiếu = tổng đã nhập − tổng đã dùng* (chủ quán
  chốt 2026-09-16, `U-051`). Máy làm phép trừ và **dừng ở đó**: hiệu số là một con số, không phải
  một phán quyết.
- **Cộng dồn từ ngày mua sản phẩm, không đặt lại.** Hai tổng chạy liên tục từ ngày mua
  (`U-054`, lời bổ sung ghi nhận 2026-09-27); không đặt về 0 mỗi lần mua thêm, không tách theo lô.
- **Một thứ, một ngày, một đáp số.** Con số *mua vào* của một thứ trong một ngày đọc ra **đúng một**
  giá trị, và *đã dùng* cũng vậy; một thứ đứng **một** lần trong danh mục, nên tổng của nó không bị
  tách làm hai.

**Điều kiện biên:** máy cộng và trừ **đúng con số người gõ**, không quy đổi đơn vị. Đơn vị ghi
lượng đã dùng chưa có lời (`work/admin-questions.md` câu **B12**); nếu lời ấy nói *mua vào* và *đã
dùng* của một thứ ghi theo hai đơn vị khác nhau thì vế hiệu số phải **viết lại**, không phải viết
thêm.

**Why:**
Hiệu số là con số chủ quán dùng để tự kết luận thừa hay thiếu (`shop-facts.md` §8.4, `U-045` ·
`U-051`). Một tổng lưu riêng và sửa riêng sẽ có ngày lệch khỏi các con số ngày, và lúc ấy sổ cho
**hai** đáp số cho cùng một câu hỏi mà không thao tác nào sai — cùng hình với `I-019`. Đặt lại tổng
theo lần mua là một luật chủ quán không nói (`shop-facts.md` §8.4: *không tự suy quản lý theo lô*).

Hai chỗ **suy ra**, không phải lời chủ quán (`CLAUDE.md` §7.2): vế *một thứ đứng một lần trong danh
mục* — suy từ việc chủ quán gộp dòng trùng *thịt mộc* · *mộc nhĩ* ngày 2026-09-25; và việc hiệu số
**âm không bị từ chối** — con số *đã dùng* là ước lượng của người, từ chối nó vì vượt tổng đã nhập
là máy kết luận thay chủ quán.

**Verification:**
Kịch bản dương: nhập cho gạo ba ngày liền *mua vào* 10 · 0 · 5 và *đã dùng* 4 · 3 · 6 ⇒ tổng đã
nhập **15**, tổng đã dùng **13**, hiệu số **2**; ngày thứ ba có mua thêm mà hai tổng **không** đặt
lại. Kịch bản sửa: đổi con số *đã dùng* ngày thứ hai từ 3 thành 5 ⇒ tổng đã dùng **15**, hiệu số
**0**, không cần ai sửa con số tổng. Kịch bản biên: nhập *đã dùng* lớn hơn tổng đã nhập ⇒ **nhận**,
hiệu số âm, không có cảnh báo nào do máy đặt ra. Kịch bản âm: tạo con số *mua vào* thứ hai cho cùng
một thứ, cùng một ngày, đứng cạnh con số đã có ⇒ không tồn tại được hai đáp số; thêm vào danh mục
một thứ trùng tên một thứ đã có ⇒ **bị từ chối**. Kiểm ngược, bất kỳ lúc nào: với mọi thứ, tổng
hiện ra bằng tổng cộng lại từ các con số ngày.

*Viết ở P2A-01, 2026-09-30, Claude Code. Hai chỗ suy ra ghi rõ ở mục Why.*

### I-027 — Mỗi ô *có đi làm* thuộc ĐÚNG MỘT người của quán và ĐÚNG MỘT ngày, mang tên người đã tick; một người một ngày không có hai ô còn hiệu lực; ô tick nhầm được HUỶ chứ không biến mất; không ô nào sinh ra khoản trừ

**Invariant:**
Mệnh đề của mức 2 mảng con người (`master_plan/shop-facts.md` §8.7). Năm vế:

- **Một ô, đúng một người, và người ấy là người của quán.** Người được chấm công thuộc cùng tập
  người mà mức 1 đếm (`shop-facts.md` §3 · §8.7) — không có danh sách người thứ hai. Một ô không
  gắn với người nào không tồn tại được.
- **Một ô, đúng một ngày; một người trong một ngày có nhiều nhất một ô còn hiệu lực.** Chủ quán chốt *mỗi người
  mỗi ngày một ô* (lời đóng `U-069`, 2026-09-30): không có ô theo buổi, không có mốc lúc tới hay
  lúc về. Đọc lại được sau nhiều ngày: *người này, ngày này, có đi làm*.
- **Mỗi ô mang tên người đã tick và lúc tick, và người tick là chủ quán.** Chủ quán tick hết; nhân
  viên không bấm (lời đóng `U-065` · `U-069`, 2026-09-30, thay `C31` ở vế này).
- **Ô tick nhầm được huỷ, và ô đã huỷ không biến mất.** Chủ quán chốt một *nút huỷ, có phần ghi chú
  để sau kiểm lại* (lời đóng `U-070`, 2026-09-30). Một ô đã huỷ ở lại, đọc ra được **ai huỷ**, **lúc
  huỷ** và **ghi chú** nếu có; nó không còn tính là *có đi làm*. Không ô nào bị xoá, và người hay
  ngày của một ô không đổi được — tick nhầm thì huỷ rồi tick ô đúng.
- **Không ô nào sinh ra khoản trừ.** Đi muộn không bị trừ tiền (`C32`); không đường nào đi từ một ô
  chấm công tới một khoản trừ tiền.
- **Mỗi lần huỷ có ghi chú, và người huỷ là chủ quán** (chủ quán chốt 2026-10-09, đóng **U-071**;
  `master_plan/shop-facts.md` §8.7). Một lần huỷ không ghi chú, hay do người không phải chủ quán
  bấm, không phải một lần huỷ. *Thêm 2026-10-09, T-139; lược đồ chấm công còn nhận cả hai cho tới
  `T-141`.*

**Mệnh đề không nói** huỷ rồi có được **tick lại** đúng người, đúng ngày ấy không: mệnh đề chỉ giữ *nhiều nhất
một ô còn hiệu lực*, nên một ô mới sau khi ô cũ đã huỷ không bị cấm. Nó không nói chủ quán có được tick **bù cho
một ngày đã qua** hay không: ngày của ô và lúc tick là hai thứ đọc riêng, mệnh đề không buộc chúng
trùng nhau. Nó không nói **muộn bao nhiêu phút thì ghi nhận là muộn** — `C32` chưa nêu ngưỡng ấy, và
một ô ngày không mang giờ tới nên không có gì để so; chưa có lời thì không có chỗ cất để sẵn cho nó
(kế hoạch lược đồ admin §3 điểm 2). Nó không nói về **ngày nghỉ**: `C30` chốt nghỉ đột xuất không
trừ tiền và chưa rõ vế nghỉ có báo trước, và một ngày không có ô không phải một ngày nghỉ đã ghi. Nó
cũng không nói một ô ngày đổi ra lương thế nào (`C26` nói *theo buổi và theo tuần*, `C33`).

**Giới hạn đã biết:** chủ quán chốt **chủ quán tick hết**, nhưng máy không ngăn được một người khác
tick trên chiếc máy chủ quán đang mở — cùng hình với chỗ đứng dùng chung của `I-012`. Cái máy giữ là
mỗi ô có **một** người được chấm, **một** ngày và **một** tên người tick; mỗi lần huỷ có **một** tên
người huỷ.

**Why:**
Mức 3 — tính lương trên máy — sẽ đứng trên sổ công này (`shop-facts.md` §8.7). Một ô không có
người, hoặc gắn vào một người không thuộc tập người của quán, là một ngày công không ai được trả;
hai ô cho cùng một người cùng một ngày là một ngày công được trả hai lần. Tên người tick là thứ duy
nhất cho phép hỏi lại *ai đã đánh dấu ngày này* khi người làm và chủ quán nhớ khác nhau. Vế *không ô
nào sinh khoản trừ* chống đúng cách dựng dễ nghĩ ra nhất: một khoản trừ tự sinh khi một người không
có ô hay tới muộn, trong khi lời chủ quán nói ngược lại.

**Verification:**
Kịch bản âm: tạo một ô không gắn người nào ⇒ **bị từ chối**; tạo một ô cho một người không có trong
tập người của quán ⇒ **bị từ chối**; tạo một ô không có ngày ⇒ **bị từ chối**; tạo một ô không có
người tick ⇒ **bị từ chối**; tạo ô thứ hai cho cùng một người cùng một ngày ⇒ **bị từ chối**. Kịch
bản huỷ: chủ quán huỷ một ô kèm ghi chú ⇒ ô **vẫn còn**, đọc ra ai huỷ, lúc huỷ, ghi chú, và không
còn tính là có đi làm; tick lại đúng người, đúng ngày ấy ⇒ **được nhận**; một lần huỷ không có người
huỷ ⇒ **bị từ chối**; xoá một ô, hay đổi người hoặc ngày của nó ⇒ **bị từ chối**. Kịch
bản dương: chủ quán tick cho hai người ngày 2026-09-21 và cho một trong hai người ngày 2026-09-22 ⇒
ba ô **được nhận**, đọc lại đúng ai có đi làm ngày nào và ai đã tick; không khoản trừ nào sinh ra.
Kiểm ngược: mọi ô có đúng một người, một ngày và một người tick là chủ quán; không cặp (người, ngày)
nào có hơn một ô còn hiệu lực; mọi ô đã huỷ có người huỷ và lúc huỷ; và đọc lược đồ ⇒ không
đường nào đi từ một ô tới một khoản trừ, không chỗ nào cất giờ tới hay một ngưỡng đi muộn.

*Viết ở P2A-01, 2026-09-30, Claude Code — từ lời chủ quán `C31` · `C32` (2026-09-25); bản ấy nói
*nhân viên tự bấm, mỗi lần chấm một mốc giờ*. **Viết lại ở P2A-03, 2026-09-30, Claude Code** — theo
lời chủ quán đóng `U-065` và `U-069` cùng ngày: chủ quán tick, mỗi người mỗi ngày một ô; vế mốc giờ
của lần chấm thành vế ngày của ô và lúc tick. **Thêm vế huỷ cùng ngày**, theo lời chủ quán đóng
`U-070`: bản viết lại đầu tiên nói *không có đường gỡ một ô*.*

### I-028 — Mỗi khoản tạm ứng và mỗi khoản thưởng đọc ra được CỦA AI · BAO NHIÊU · LÚC NÀO; một khoản tạm ứng không tồn tại được khi không có người duyệt; khoản đã ghi không bị sửa đè

**Invariant:**
Mệnh đề cho hai loại tiền chủ quán đưa cho người làm (`master_plan/shop-facts.md` §8.7, `C28` ·
`C29`). Năm vế:

- **Mỗi khoản đủ ba câu.** Một khoản tạm ứng hay một khoản thưởng tồn tại thì đọc ra được nó **của
  ai** — đúng một người thuộc tập người của quán —, **bao nhiêu** — một số tiền lớn hơn 0 —, và
  **lúc nào**; cùng **người đã ghi** khoản ấy vào máy.
- **Tạm ứng phải có người duyệt, và người duyệt là chủ quán** (`C29`: *có tạm ứng; chủ quán duyệt*).
  Một khoản tạm ứng không có người duyệt không tồn tại được.
- **Khoản đã ghi không sửa đè.** Sửa số tiền, người nhận hay ngày của một khoản là một lần cập nhật
  để lại bản trước, bản sau, lý do và người sửa theo `I-018`.
- **Hai loại khoản này không phải tiền bán hàng.** Chúng không vào doanh thu của ngày nào (`I-014`).
- **Mỗi khoản là tiền rời két bán hàng, và trừ vào phép đối soát két của đúng MỘT ngày bán**
  (`I-021`, hạng tử *chi từ két*). Lời chủ quán: tạm ứng và thưởng lấy **từ két bán hàng**
  (2026-09-30, đóng `U-067`), rời két **trong ngày, trước lúc đếm két** (2026-10-01,
  `master_plan/shop-facts.md` §8.10). Không có khoản tạm ứng hay thưởng nào *không* rời két, nên vế
  này không cần dấu nguồn tiền trên từng khoản. *Thêm 2026-10-01, T-125, **ADR-074**.*

Khoản ấy trừ vào két của **ngày người ghi khai cho khoản** (chủ quán chốt 2026-10-09, đóng
**U-072**) — vế ngày ở `I-021`.

**Mệnh đề không nói khoản ấy **trừ vào hay cộng vào lương** thế nào (chờ
`C26` · `C33`), không nói **ai duyệt thưởng**, và chỉ phủ **thưởng lễ Tết** — vế thưởng ngày đông
khách của `C28` chưa có lời.

**Why:**
Cả hai là tiền thật đã rời tay chủ quán. Không có *của ai · bao nhiêu · lúc nào* thì cuối kỳ không
ai nhớ đã ứng cho ai, và phần lương sau này không có gì để đối lại. Lời chủ quán đặt việc **duyệt**
vào tạm ứng, nên một khoản tạm ứng không mang người duyệt là một khoản không ai cho phép. Vế *số
tiền lớn hơn 0* là **suy ra**, không phải lời chủ quán (`CLAUDE.md` §7.2): một khoản 0đ hay âm không
phải một lần đưa tiền, và trả lại tạm ứng — nếu có — là một luật chưa ai nói.

**Verification:**
Kịch bản âm: tạo một khoản tạm ứng không có người duyệt ⇒ **bị từ chối**; tạo một khoản tạm ứng hay
thưởng không có người nhận, có số tiền 0đ, hoặc không có ngày ⇒ **bị từ chối**. Kịch bản dương: chủ
quán duyệt tạm ứng cho một người ⇒ sau nhiều ngày đọc lại được của ai, bao nhiêu, lúc nào, ai duyệt.
Kịch bản sửa: đổi số tiền một khoản đã ghi ⇒ đọc ra được cả số cũ lẫn số mới, lý do và người sửa.
Kiểm ngược: không khoản tạm ứng nào thiếu người duyệt, và không khoản nào của hai loại này nằm
trong doanh thu hay trong tập tiền đã thu của một ngày. Kịch bản két: khoản tạm ứng 200.000 đưa giữa
buổi ⇒ vào hạng tử *chi từ két* của **một** ngày bán, không ngày nào khác (kịch bản *chi từ két* ở
`I-021`).

*Viết ở P2A-01, 2026-09-30, Claude Code — từ lời chủ quán `C28` · `C29` (2026-09-25). Một chỗ suy ra
ghi rõ ở mục Why; câu *tiền lấy từ đâu* mở thành **U-067** cùng lượt.*
*Thêm vế thứ năm ở T-125, 2026-10-01 — từ lời đóng `U-067`; **ADR-074**.*

### I-029 — Mỗi khoản chi đọc ra được LOẠI · SỐ TIỀN · NGÀY · AI GHI; tiền hàng và lương không bao giờ là một khoản chi

**Invariant:**
*Khoản chi* ở đây là khoản chi **ngoài tiền hàng và lương** của `master_plan/shop-facts.md` §8.10
(`E44`). Bốn vế:

- **Mỗi khoản đủ bốn câu.** Một khoản chi tồn tại thì đọc ra được **loại** của nó, **số tiền** —
  lớn hơn 0 —, **ngày** chi, và **ai ghi**.
- **Loại là một trong các loại quán đã kể, và danh sách ấy thêm được.** Hôm nay: điện, nước, wifi,
  xăng xe (`E44`). §8.10 nói thẳng *không suy rằng quán không có khoản chi nào khác*, nên thêm một
  loại mới là việc bình thường; một khoản chi **không mang loại nào** thì không tồn tại được.
- **Tiền hàng và lương không đứng ở đây.** Giò, trứng, rau, quất là tiền hàng (§8.10, *Giới hạn lời
  đáp*); tiền mua hàng và tiền trả cho người làm không bao giờ được ghi thành một khoản chi, để một
  phép cộng sau này không đếm chúng hai lần.
- **Mỗi loại mang NGUỒN TIỀN của nó — két bán hàng hay không — và khoản chi của một loại mang nguồn
  két trừ vào phép đối soát két của đúng MỘT ngày bán** (`I-021`, hạng tử *chi từ két*). Điện,
  nước, wifi, xăng xe mang nguồn **két bán hàng** (lời đóng `U-066`, 2026-09-30; rời két **trong
  ngày, trước lúc đếm két**, 2026-10-01 — `master_plan/shop-facts.md` §8.10). Một loại **không mang
  nguồn** thì không tồn tại được: `E46` nói thẳng loại chi nào ngoài bốn loại ấy *chưa nói nguồn*,
  nên thêm một loại mới là phải hỏi nguồn của nó cùng lúc, không được để máy đoán. *Thêm
  2026-10-01, T-125, **ADR-074**.*

Và vì mỗi khoản có số tiền và ngày: **tổng chi của một khoảng ngày là phép cộng** các khoản trong
khoảng ấy, không phải một con số ghi riêng.

Khoản chi của loại mang nguồn két trừ vào két của **ngày người ghi khai cho khoản** (chủ quán chốt
2026-10-09, đóng **U-072**) — vế ngày ở `I-021`.

**Mệnh đề không nói** chu kỳ của wifi và xăng xe (`E45`), hay cách phân bổ khoản tháng vào lãi/lỗ ngày (`E47`).

**Giới hạn đã biết:** máy giữ được rằng mỗi khoản chi **mang đúng một loại trong danh sách**. Máy
**không ngăn được** một người gõ tiền mua trứng dưới một loại khác, và cũng không ngăn được người
thêm vào danh sách một loại mang nghĩa tiền hàng hay lương — một cái tên loại không tự nói nó là gì.
Cả hai chỗ ấy do người giữ. Máy cũng **không** biết nguồn khai cho một loại có đúng là nơi tiền ra
không; khai sai thì phép trừ két của `I-021` lệch đúng bằng khoản ấy — lệch có tên, không im lặng.

**Why:**
Hệ thống cộng được mọi đồng đi **vào** quán và chưa biết một đồng nào đi **ra**. Chủ quán muốn xem
lãi/lỗ theo ngày (`E47`); phép tính ấy còn chờ lời, nhưng đầu vào của nó — từng khoản chi có loại,
số tiền, ngày — đã đủ lời để ghi. Vế *tiền hàng không đứng ở đây* chép đúng giới hạn §8.10 đặt ra:
cộng trùng tiền hàng làm lãi/lỗ sai mà không khoản nào sai. Vế *số tiền lớn hơn 0* là **suy ra**
(`CLAUDE.md` §7.2), cùng lý do với `I-028`.

**Verification:**
Kịch bản âm: tạo một khoản chi không có loại, có số tiền 0đ, không có ngày, hoặc không có người ghi
⇒ **bị từ chối**; tạo một khoản chi mang một loại không có trong danh sách ⇒ **bị từ chối**. Kịch
bản dương: ghi tiền điện và tiền xăng xe trong cùng một tuần ⇒ mỗi khoản đọc lại được đủ bốn câu, và
tổng chi của tuần ấy bằng tổng hai khoản; thêm một loại mới vào danh sách **kèm nguồn** rồi ghi một
khoản thuộc loại ấy ⇒ **ghi được**; thêm một loại **không** khai nguồn ⇒ **bị từ chối**. Kịch bản
két: tiền điện 300.000 lấy giữa buổi ⇒ vào hạng tử *chi từ két* của **một** ngày bán (kịch bản *chi
từ két* ở `I-021`). Kiểm ngược: không khoản chi nào thiếu loại hay mang loại ngoài danh sách;
còn *danh sách loại không có loại nào là tiền hàng hay lương* là một lượt **người đọc** danh sách,
không phải một phép máy chấm được.

*Viết ở P2A-01, 2026-09-30, Claude Code — từ lời chủ quán `E44` · `E45` (2026-09-25). Một chỗ suy ra
ghi rõ ở mục Why.*
*Thêm vế thứ tư ở T-125, 2026-10-01 — từ lời đóng `U-066`; nguồn đặt trên **loại** chứ không trên
từng khoản là lựa chọn thiết kế, không phải lời chủ quán (**ADR-074**).*
