# §4 — Giá và thanh toán

> Nguyên văn `docs/product.md` §4, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §4: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §4, tách 2026-09-02 ==== -->
## 4. Giá và thanh toán

> **Quyết định gốc của mục này:** → **ADR-023** (§4.4 mốc khoá giá là từng dòng) · **ADR-030**
> (§4.6 hai phương thức, POS xác nhận lúc nhận tiền) · **ADR-019** (§4.7 nợ) · **ADR-020** (§4.8
> hoàn tiền, tính ngày hoàn) · **ADR-022** (§4.9 đối soát ba nguồn ngưỡng 0đ, §4.10 hai nguồn
> doanh thu) · **ADR-024** (vết của mọi thao tác chạm tiền) · **ADR-025** (giá suất trứng ×5).

*BA-06 — chốt 2026-09-01. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §6 (giá,
thanh toán), §5 quy tắc 3, 5, 6, 12 + `master_plan/shop-facts.md` §1 (hai phương thức, VietQR
tĩnh), §4.1–§4.8 (công thức, hai bảng giá, phụ thu, chín quy tắc, mười một tổ hợp), §6.3, §6.4,
§6.7, §6.9, §6.10, §6.11, §6.14, §6.17 (dữ kiện quán, chủ quán chốt 2026-08-19 → 2026-09-01).*

Mục này chốt **quy tắc tiền**: giá từ đâu ra, tổng tiền đứng yên từ lúc nào, thu bằng cách nào, ai
nói được câu "đã nhận tiền", và cuối ngày lấy gì ra đối chiếu. Con số thì không ở đây — bảng giá có
đúng một nhà là `shop-facts.md` §4.2–§4.3, và mục này **cố ý không chép** một ô nào của nó.

### 4.1 Luật gốc — giá một SUẤT là TỔNG giá các THÀNH PHẦN của suất

Mọi luật còn lại của mục này là hệ quả của một câu (`shop-facts.md` §4.6 quy tắc 1, bằng chứng
§4.7):

> **Giá một suất bán = tổng giá các thành phần mà bếp làm ra cho suất đó.**

Thành phần của từng suất ở `shop-facts.md` §4.5, giá từng thành phần ở §4.2. Giá một suất **không**
phải một con số ai đó gõ vào cạnh tên món; nó được **tính lại** mỗi lần, từ hai bảng ấy.

**Hai bảng, và đọc nhầm bảng là thu thiếu tiền.** `shop-facts.md` §4.2 và §4.3 nhìn giống nhau
nhưng là hai thứ khác hẳn:

| Bảng | Nó cho giá của | Một dòng của nó là |
|---|---|---|
| `shop-facts.md` **§4.2** | **thành phần** | một cái bánh cuốn · một quả trứng · một chiếc giò |
| `shop-facts.md` **§4.3** | **một suất bán** | suất bánh cuốn · suất giò · suất trứng · combo "Đầy đủ" |

Một suất bán gần như luôn gồm **nhiều** thành phần: suất giò là một chiếc giò **cộng bốn cái
bánh**, suất trứng là một quả trứng **cộng bốn cái bánh** (`shop-facts.md` §4.5). Nên giá của dòng
*"1 chiếc giò"* ở §4.2 **không** phải giá khách trả cho một *suất giò* — nó chỉ là một trong năm
thứ tạo nên giá ấy. Lấy số ở bảng thành phần rồi thu tiền như thể đó là giá suất là **thu thiếu
tiền**, và thiếu đúng phần bánh mà bếp đã thật sự làm ra. Cần một con số cụ thể thì tra
`shop-facts.md` §4.3, đừng tự cộng lại từ trí nhớ.

### 4.2 Giá do hệ thống xác định, khách không bao giờ đặt được giá

- **Giá luôn do hệ thống tính lại từ bảng giá**, từ đúng hai thứ: món khách chọn, và tuỳ chọn
  khách chọn kèm. Khách **không bao giờ** gửi giá lên; giá do khách gửi tới thì bỏ, không dùng
  (`shop-facts.md` §4.6 quy tắc 9). Nhận giá từ phía khách nghĩa là có ngày khách đặt được món 0đ.
- **Giá gốc của một thành phần là giá CHAY.** Nhân là **phụ thu** cộng thêm, không phải một bảng
  giá riêng (§4.6 quy tắc 2).
- **Loại nhân không đổi giá.** *Thịt* và *Thịt + mộc nhĩ* cùng một mức phụ thu; chỉ **lượng nhân**
  mới làm đổi số tiền (§4.6 quy tắc 4).
- **Phụ thu là +1.000 cho MỖI phần nhận nhân của suất.** Đây là toàn bộ luật phụ thu, và nó là
  một câu chứ không phải một bảng phải nhớ thuộc lòng.
- **Mặc định là nhân Thịt, lượng Thường** khi khách không chọn gì (§4.6 quy tắc 8). Đơn không có
  tuỳ chọn nào **không** phải đơn chay.
- **Một dòng đơn chọn một loại nhân và một lượng nhân, áp cho mọi phần nhận nhân của suất ấy**
  (§4.6 quy tắc 7). Không chọn nhân riêng cho từng cái bánh trong cùng một suất.
- **Tổ hợp Chay + Nhiều nhân bị TỪ CHỐI**, không được âm thầm bỏ bớt tuỳ chọn thừa rồi cho đơn đi
  tiếp: nhóm *Lượng nhân* chỉ tồn tại khi nhân ≠ Chay (§4.6 quy tắc 3, §3.3.5, `quality/invariants.md`
  I-010).

**×1 / ×4 / ×4 / ×5 là HỆ QUẢ, không phải bốn con số rời.** Đếm số phần nhận nhân của từng suất
theo `shop-facts.md` §4.5 thì bốn con số tự rơi ra:

| Suất bán | Phần **nhận** nhân | ⇒ phụ thu mỗi bậc |
|---|---|---|
| Suất bánh cuốn | cái bánh | **×1** |
| Suất giò | bốn cái bánh — **giò không nhận nhân** | **×4** |
| Combo "Đầy đủ" | ba cái bánh **và** quả trứng | **×4** |
| Suất trứng | bốn cái bánh **và** quả trứng | **×5** |

Hai dòng dễ sai nhất, cả hai đều là lời chủ quán chứ không phải suy luận: **giò không nhận nhân,
nhưng bốn cái bánh trong suất giò thì có** (chốt 2026-08-29, `shop-facts.md` §4.6 quy tắc 6); và
**quả trứng cũng lên giá theo nhân, nên suất trứng là ×5 chứ không phải ×4** (chốt 2026-08-30,
`shop-facts.md` §4.3, §4.6 quy tắc 5).

⚠️ **Một câu từng lưu hành trong dự án nói ngược lại** — rằng phụ thu **không** nhân lên theo số
phần bếp làm ra. Lời chủ quán ngày 2026-08-29 về suất giò đã phủ nhận nó, và nó đã bị gỡ khỏi
`shop-facts.md`. Nguyên văn câu ấy nay chỉ còn sống ở đúng **một** chỗ trong repo — tấm bia ở
`shop-facts.md` §4.7 — và mục này cố ý **không** chép lại, để câu ấy grep ra ở đâu cũng là dấu
hiệu nó đã quay lại. Thấy nó ở bất kỳ tài liệu nào, **đó là bug**, không phải một quy tắc.

### 4.3 Mười một tổ hợp bắt buộc phủ

Đây là **hợp đồng với chủ quán** (`shop-facts.md` §4.8): tính đúng cả mười một ca mới được coi là
tính giá đúng. Cột giá kỳ vọng **cố ý không có số** — tra `shop-facts.md` §4.2–§4.3, nơi mười ca
đầu đã được đối chiếu khớp bảng giá từ 2026-08-30.

| # | Món | Nhân | Lượng nhân | Kết quả phải ra | Ca này bắt lỗi gì |
|---|---|---|---|---|---|
| 1 | Bánh cuốn | Chay | — | giá chay, tra `shop-facts.md` §4.2 | giá gốc là giá chay |
| 2 | Bánh cuốn | Thịt | Thường | tra `shop-facts.md` §4.2–§4.3 | phụ thu nhân ×1 |
| 3 | Bánh cuốn | Thịt | Nhiều | tra `shop-facts.md` §4.2–§4.3 | phụ thu lượng nhân ×1 |
| 4 | Bánh cuốn | Thịt + mộc nhĩ | Nhiều | **bằng đúng ca 3** | loại nhân **không** đổi giá |
| 5 | Suất trứng chín | Chay | — | tra `shop-facts.md` §4.3 | suất trứng gồm trứng **và bốn cái bánh** |
| 6 | Suất trứng tái | Thịt + mộc nhĩ | Thường | tra `shop-facts.md` §4.3 | phụ thu **×5** — trứng cũng lên giá theo nhân |
| 7 | Suất trứng vàng | Thịt | Nhiều | tra `shop-facts.md` §4.3 | phụ thu **×5** ở bậc *nhiều nhân* |
| 8 | Suất giò | Thịt | Nhiều | tra `shop-facts.md` §4.3 | **×4** — giò không nhận nhân, bốn cái bánh thì có |
| 9 | Combo Đầy đủ chín | Thịt | Thường | tra `shop-facts.md` §4.3 | combo **×4**, không phải ×5 |
| 10 | Combo Đầy đủ tái | Thịt + mộc nhĩ | Nhiều | tra `shop-facts.md` §4.3 | ×4 ở bậc *nhiều nhân* |
| 11 | Bánh cuốn | **Chay** | **Nhiều** | **PHẢI BỊ TỪ CHỐI** | tổ hợp không hợp lệ — **không** có giá nào đúng ở đây |

**Ba ca suất trứng đứng riêng — ca 5, 6, 7 — ghi phụ thu ×5, và đó là con số ĐÃ CHỐT** (chủ quán
xác nhận 2026-08-30 khi được hỏi thẳng suất trứng nhân thường là bao nhiêu, `shop-facts.md` §7.1).
Không đánh dấu ba ca này là suy luận nữa; chỗ nào còn ghi *"chưa chắc ×4 hay ×5"* là pointer cũ.

**Ca 11 là ca duy nhất có kết quả không phải một con số.** Nó không hỏi *"giá bao nhiêu"* mà hỏi
*"hệ thống có chịu tạo đơn không"*, và câu trả lời đúng là **không** — không tạo đơn, và cũng
không lặng lẽ tạo một đơn *"bánh cuốn Chay"* đã bỏ bớt tuỳ chọn thừa (§3.3.5, `quality/invariants.md`
I-010).

### 4.4 Tổng tiền đứng yên từ lúc nào — mốc là một LƯỢT GỌI

- **Giá được khoá tại thời điểm tạo một lượt gọi.** Từ lúc đó, giá từng dòng và tổng của lượt gọi
  ấy không đổi nữa, mãi mãi (§3.3.3, `quality/invariants.md` I-009).
- **Mốc KHÔNG phải lúc mở phiên bàn, và KHÔNG phải lúc thanh toán.** Khoá giá theo lúc mở phiên là
  sai; tính lại cả phiên theo giá mới lúc thanh toán còn sai nặng hơn — đó là sửa tiền của một thứ
  khách đã ăn xong (`shop-facts.md` §6.17).
- **Giá menu đổi sau mốc thì không chạm được lượt gọi cũ.** Chủ quán sửa giá thành phần, sửa mức
  phụ thu nhân hoặc phụ thu lượng nhân **ngay giữa giờ bán cũng được**, hiệu lực từ lúc lưu (chủ
  quán chốt 2026-09-01, `shop-facts.md` §6.17); lượt gọi tạo trước lúc lưu vẫn giữ nguyên giá cũ.
  Bốn chiều đổi giá và những gì đơn cũ phải giữ ở §3.3.2–§3.3.3.
- ⇒ **Một hoá đơn phiên bàn được phép mang HAI mức giá cho cùng một món**, và đó là kết quả
  **đúng**, không phải lỗi tính tiền (chủ quán chấp nhận, chốt 2026-09-01). Bàn gọi một lượt trước
  khi chủ quán đổi giá và một lượt sau thì hoá đơn cộng hai mức giá lại — §3.1.4 vẫn nguyên vẹn:
  vẫn **một** phiên, **một** hoá đơn.

**Và một ngoại lệ có chủ ý, chốt 2026-09-02: SỬA một dòng thì ĐẶT LẠI mốc khoá giá của dòng ấy.**
Dòng vừa sửa lấy **giá đang hiệu lực lúc sửa**, không giữ giá cũ của lượt gọi (`shop-facts.md`
§6.19, trả lời U-026). Ba điều phải đọc kèm, vì đây là chỗ dễ nhớ nhầm thành *"§4.4 bị phá"*:

- **Luật ở đầu mục KHÔNG đổi.** *"Giá menu đổi sau mốc thì không chạm được lượt gọi cũ"* vẫn đúng
  nguyên văn: một lần đổi giá **không bao giờ** tự với ngược vào dòng đã tạo. Cái đặt lại mốc là
  **thao tác cố ý của người đứng quầy** trên đúng dòng đó — không phải lần đổi giá.
- **Mốc khoá giá là của TỪNG DÒNG, không phải của cả lượt gọi.** Sửa một dòng trong lượt gọi ba
  dòng thì hai dòng kia giữ nguyên giá cũ. ⇒ Một lượt gọi cũng được phép mang hai mức giá, đúng
  cách một hoá đơn được phép mang hai mức giá ở gạch đầu dòng trên.
- ⇒ **Hệ quả chạm tiền khách, phải nói thẳng:** nếu chủ quán đổi giá giữa buổi, một dòng sửa sau
  mốc ấy sẽ **đắt hơn hoặc rẻ hơn chính nó lúc mới gọi**, dù khách không đổi món. Vì vậy vết của
  lần sửa phải ghi **cả giá cũ lẫn giá mới** — ghi mỗi *"đã sửa"* là làm đối soát §4.9 không giải
  thích được chỗ lệch.

**Tổng của một phiên bàn = tổng các lượt gọi thuộc phiên ấy, mỗi lượt tính theo giá đã khoá của
chính nó** — và mỗi **dòng** theo mốc đã khoá của chính dòng ấy. Không có phép tính nào lấy giá
hiện tại nhân với số suất của cả phiên; làm thế là hỏng đúng ca hai mức giá ở trên. Với **nhóm bàn
ghép**, "phiên ấy" phủ mọi bàn trong nhóm — vẫn một hoá đơn (§3.1.7,
`quality/invariants.md` I-002).

### 4.5 Đơn vị thanh toán — theo kênh

Sản phẩm có **đúng hai** đơn vị tính tiền, và mỗi kênh trong năm kênh của §2 rơi vào đúng một:

| Kênh | Đơn vị thanh toán | Thu mấy lần |
|---|---|---|
| **QR tại bàn** | **Phiên bàn** | một lần, lúc đóng phiên |
| **Staff POS** | **Phiên bàn** | một lần, lúc đóng phiên |
| **Delivery** | **Đơn** | một lần cho mỗi đơn |
| **Pickup** | **Đơn** | một lần cho mỗi đơn |
| **Đặt trước qua hotline** | **Đơn** | một lần cho mỗi đơn |

Ba hệ quả, cả ba đã chốt ở chỗ khác và nhắc lại đây vì chúng là luật **tiền**:

- **Nhiều lượt gọi tại một bàn ⇒ một lần thu.** Kể cả lượt gọi thêm lúc phiên đang *chờ thanh
  toán*; tách nó ra hoá đơn thứ hai là **thu thiếu tiền** (§3.1.4, `shop-facts.md` §6.1).
- **Suất "đem về" của khách đang ngồi bàn là tiền của PHIÊN BÀN**, không phải một đơn mang đi
  (§2.1, §3.1.4, `quality/invariants.md` I-006).
- **Hai đơn mang đi của cùng một khách vẫn là hai lần thu**, không có thao tác nào gộp chúng
  (§3.2.5, `quality/invariants.md` I-007).

### 4.6 Hai phương thức thanh toán, và ai nói được câu "đã nhận tiền"

MVP có **đúng hai** phương thức (`shop-facts.md` §1). Không có phương thức thứ ba, và không có cổng
thanh toán hay ví điện tử nào — kể cả dạng "chuẩn bị cho sau này".

| Phương thức | Ai xác nhận đã thu được tiền | Xác nhận vào lúc nào |
|---|---|---|
| **Tiền mặt** | **Người đứng quầy**, bấm trên POS ở quầy — trừ đơn giao tận nơi, do **người đi giao** bấm *đã giao* và *đã thu tiền* cùng lúc (`shop-facts.md` §6.7) | lúc nhận tiền từ tay khách |
| **Chuyển khoản VietQR tĩnh** | **Người đứng quầy**, bấm trên POS ở quầy, **sau khi tự nhìn thấy báo có** | lúc nhìn thấy tiền đã về, không phải lúc khách bấm |

**VietQR ở đây là mã TĨNH, và đó là chi tiết đắt nhất của cả mục này** (`shop-facts.md` §1). Mã cố
định, không sinh riêng cho từng hoá đơn ⇒ **hệ thống không tự biết tiền đã về tài khoản**. Nên
"đã nhận tiền" **không** phải một sự kiện máy tự phát hiện; nó là một câu **do người bấm ra**, và
người đó chịu trách nhiệm cho câu ấy khi đối soát cuối ngày (§4.9).

**Thu tiền lúc trao hàng là đường mặc định** (`shop-facts.md` §6.3): ăn tại bàn thu ở quầy lúc đóng
phiên · khách tới lấy thu ở quầy lúc khách tới · giao tận nơi thu **tại chỗ khách**, lúc đưa hàng.

**Trả trước là tuỳ chọn của khách, và chỉ có ở ba kênh mang đi** (§3.2.5). Khách chọn trả trước thì
vẫn trả bằng đúng hai phương thức trên, và **POS xác nhận vào lúc tiền thật sự tới tay quán** —
chọn *trả trước* là **ý định của khách**, còn *đã nhận tiền* chỉ do người bấm ở POS tạo ra (chủ
quán chốt 2026-08-31, `shop-facts.md` §6.3). **Phiên bàn không có nhánh trả trước**: phiên còn mở
thì khách còn gọi thêm được, nên chưa có số tiền nào để trả.

**Một lần thu CHIA ĐƯỢC làm hai phần, mỗi phần một phương thức** *(chủ quán chốt 2026-09-01,
`shop-facts.md` §6.18)*. Khách đưa một phần tiền mặt rồi chuyển khoản nốt phần còn lại thì quán
**nhận cả hai**, và **POS ghi số tiền của từng phần** — bao nhiêu tiền mặt, bao nhiêu chuyển khoản.

- **Vẫn đúng hai phương thức**, không có phương thức thứ ba. Luật này không thêm cách trả nào, nó
  chỉ nói một lần thu **không bị buộc** nằm gọn trong một phương thức.
- **Tổng các phần đã thu = số tiền phải trả.** Thiếu thì đó là **nợ**, xử theo §4.7(b); không có
  ca nào tổng các phần vượt quá số phải trả.
- **Ghi gộp thành một con số tổng là hỏng đối soát.** Buổi tối, phần tiền mặt so với **két** và
  phần chuyển khoản so với **tin nhắn báo có** (§4.9) — một lần thu không tách được thì không xếp
  vào nguồn nào để đối chiếu.
- **Người xác nhận không đổi**: vẫn là người bấm ở POS theo bảng trên. Chia phương thức không mở
  thêm cửa nào.

⚠️ Chữ **hoặc** trong *"tiền mặt hoặc VietQR"* (`shop-facts.md` §1, §6.3) mô tả **lựa chọn của
khách**, **không** phải luật loại trừ. Mục này từng đọc nhầm đúng chỗ ấy trong ngày 2026-09-01,
trước khi chủ quán trả lời U-020 — nó viết rằng mỗi lần thu chỉ được **một** phương thức. Tài liệu
nào ràng buộc một lần thu vào một phương thức là đang mang lại lỗi đó.

### 4.7 Khi chưa thu được tiền: phiên/đơn ở đâu, bàn có trống không

Hai tình huống nghe giống nhau nhưng xử khác hẳn nhau. Phân biệt sai là để một cái bàn bị khoá cả
buổi, hoặc để một khoản tiền biến mất khỏi sổ.

**(a) Chưa xác nhận ĐƯỢC — tiền đang trên đường về.** Khách đã quét VietQR nhưng quầy chưa thấy
báo có:

- Phiên bàn ở nguyên trạng thái **chờ thanh toán**; nó **chưa đóng**.
- ⇒ **Bàn KHÔNG trống.** Điều kiện ở §3.1.4 không có ngoại lệ nào cho ca này: bàn trống cần phiên
  **đã đóng** *và* bàn **đã được dọn** (`quality/invariants.md` I-003).
- Khách gọi thêm trong lúc chờ ấy vẫn vào **chính** hoá đơn đó (§3.1.4).
- Đơn mang đi thì tương tự: đơn **chưa đóng**, và với đơn giao tận nơi thì quầy phải nhìn được
  đơn nào còn trên đường và **ai đang cầm tiền chưa về** (`shop-facts.md` §6.7).

**(b) Sẽ KHÔNG thu được hôm nay — quán cho nợ.** Khách rời quán mà chưa trả. Đây **không** phải
tình huống (a) kéo dài, và cũng không phải một ngoại lệ chờ ai nghĩ ra cách xử — nó là đường chính
thức, chủ quán chốt 2026-08-31 (`shop-facts.md` §6.14, `docs/decisions.md` ADR-012):

- **Phiên vẫn được đóng**, và lúc đóng POS **bắt buộc ghi ai nợ và nợ bao nhiêu**. Thiếu một trong
  hai thì thao tác bị từ chối (`quality/invariants.md` I-005).
- ⇒ **Bàn trở lại trống bình thường** theo đúng hai điều kiện của §3.1.4. Không cho nợ thì một bàn
  quỵt tiền khoá luôn cái bàn đó.
- **Một khoản nợ KHÔNG phải tiền đã thu.** Nó vào doanh thu của **ngày ghi nợ**, nhưng không vào
  két ngày hôm đó — chi tiết và cách nó hiện ra lúc đối soát ở §3.1.6 và §4.9.

### 4.8 Hoàn tiền — quầy quyết từng ca, và mọi lần đều để lại vết

**Có hoàn tiền, nhưng không có luật cứng** (chủ quán chốt 2026-08-30, `shop-facts.md` §6.4). Không
phải ca nào cũng được hoàn, cũng không cấm hoàn: **người đứng quầy** nhìn tình huống thật rồi quyết.

⇒ **Chính vì không có luật cứng nên mọi lần hoàn phải để lại vết**: hoàn **bao nhiêu**, cho **đơn
nào**, **ai** bấm, **lý do** gì. **Người đứng quầy vừa quyết vừa ghi vết** (chủ quán xác nhận
2026-08-30) — cùng một người, nên không có lần hoàn nào mà không ai đứng tên.

**Khi nào một lần huỷ sinh việc hoàn tiền** (`shop-facts.md` §6.3):

| Đơn bị huỷ | Có sinh việc hoàn tiền không |
|---|---|
| Chưa trả tiền — đường mặc định | **Không.** Huỷ xong là hết, không có việc gì về tiền |
| Khách **đã chọn trả trước** và quán **đã xác nhận nhận tiền** | **Có.** Xử theo §6.4 — quầy quyết từng ca, và ghi vết |

Người bấm huỷ cũng là **người đứng quầy**, trên POS ở quầy (§2.4, `shop-facts.md` §6.13). Cùng một
cửa với duyệt đơn, hoàn tiền, ghi nợ và ghép bàn — nên mọi việc chạm tiền đều truy được về một
người (`quality/invariants.md` I-012).

**Một lần hoàn tiền trừ vào doanh thu của NGÀY HOÀN, không phải ngày bán gốc** *(chủ quán chốt
2026-09-01, `shop-facts.md` §6.4)*. Bán thứ Hai, hoàn thứ Tư ⇒ doanh thu **thứ Hai giữ nguyên**,
doanh thu **thứ Tư** bị trừ đi khoản đã hoàn.

⇒ **Luật này ngược chiều với luật nợ (§4.7b), và đó là chủ ý.** Nợ tính vào **ngày ghi nợ** dù tiền
về sau; hoàn tính vào **ngày hoàn** dù hàng đã bán trước đó. Hai luật, hai chiều — nhớ nhầm thành
một là sai một trong hai.

*Cách đọc, không phải lời chủ quán nói thẳng:* hai ca khác nhau ở chỗ **cái gì đã xong**. Khoản nợ
vẫn là một bữa ăn **đã bán xong**, chỉ tiền về muộn ⇒ thuộc ngày bán. Một lần hoàn thì không sửa
lại chuyện đã bán; nó là **một quyết định mới của người đứng quầy** trong ngày hôm ấy — chính vì
§6.4 không có luật cứng ⇒ thuộc ngày quyết.

### 4.9 Đối soát cuối ngày — ngưỡng lệch là 0đ

**Đây là quy trình của quán, không phải một tính năng phần mềm.** Mỗi tối, trong **2 tuần đầu chạy
thật**, người của quán đối chiếu **doanh thu hệ thống** với **ba** nguồn (`shop-facts.md` §6.10):

| Nguồn | Đối chiếu phần nào |
|---|---|
| **Sổ giấy** | toàn bộ — bản ghi tay độc lập của cả ngày |
| **Tiền trong két** | phần khách trả **tiền mặt** |
| **Tin nhắn báo có** | phần khách **chuyển khoản** *(chủ quán chốt 2026-09-01, trả lời U-019)* |

**Lệch 1 đồng cũng phải tìm ra lý do** — ngưỡng chấp nhận là **0đ**, và đây là cổng chất lượng mạnh
nhất của cả dự án, mạnh hơn mọi bài kiểm thử.

**Nguồn thứ ba tồn tại vì két không giữ tiền chuyển khoản.** Quán có hai phương thức mà chỉ một đi
qua két; so doanh thu với mỗi *sổ giấy + két* thì phần VietQR không có gì để đối chiếu. ⇒ **Đối
soát chia theo PHƯƠNG THỨC, không cộng gộp**: một chỗ thiếu ở két có thể bị một chỗ thừa ở ngân
hàng che mất, và lúc đó ngưỡng 0đ không còn nghĩa gì. Đây cũng là lý do một lần thu chia hai phương
thức phải ghi rõ từng phần (§4.6).

Sổ giấy không phải thứ chép cho vui: nó là **kế hoạch dự phòng bắt buộc** (`shop-facts.md` §6.11)
— mất điện, mất mạng hay máy hỏng thì quán ghi tay và **không dừng bán**. Nên buổi tối luôn có hai
bản ghi độc lập để so.

**Bốn chuyện làm hai con số lệch nhau một cách HỢP LỆ.** Cả bốn đều phải có tên trong bảng đối
soát; không bày ra thì đúng luật *lệch một đồng cũng phải tìm ra lý do* sẽ báo động giả mỗi ngày:

| Chuyện xảy ra trong ngày | Két so với doanh thu | Vì sao vẫn đúng |
|---|---|---|
| **Ghi nợ** | két **thiếu** đúng bằng tổng nợ ghi trong ngày | doanh thu tính vào ngày ghi nợ, tiền thì chưa về (§3.1.6) |
| **Thu nợ cũ** | két **thừa** đúng bằng tổng nợ cũ thu hôm đó, doanh thu hôm đó **không tăng** | trả nợ là tiền về, không phải một lần bán mới |
| **Hoàn tiền** | **không lệch** — doanh thu hôm đó đã trừ sẵn khoản hoàn | hoàn tính vào **ngày hoàn** (§4.8), nên hai vế cùng giảm; trừ ở đúng nguồn đã hoàn ra — hoàn tiền mặt thì két giảm, hoàn chuyển khoản thì tin nhắn có chiều đi |
| **Chủ quán đổi giá giữa buổi** | không lệch — nhưng **cùng một món có hai giá đúng trong ngày** | ranh giới khoá giá là từng lượt gọi (§4.4); coi đó là lệch là báo động giả |

Ba chỗ tiền không nằm trong két mà vẫn là doanh thu — **VietQR**, **nợ ghi trong ngày** và tiền
người đi giao chưa mang về — nên "tiền trong két" không bao giờ được so thẳng với doanh thu mà
không trừ ba khoản ấy ra. **Riêng phần VietQR thì buổi tối quán lấy gì ra đối chiếu là câu CHƯA
CHỐT** — xem **U-019**.

### 4.10 Doanh thu một ngày cộng từ HAI nguồn

**Doanh thu một ngày = tiền từ phiên bàn + tiền từ đơn mang đi**, và **một khoản tiền thuộc đúng
một trong hai, không bao giờ cả hai** (`shop-facts.md` §6.9). Báo cáo bỏ sót một nguồn là **báo cáo
thiếu tiền** (`quality/invariants.md` I-014).

**"Hai" ở đây chia theo ĐƠN VỊ THANH TOÁN, không chia theo kênh.** Cả **ba** kênh mang đi —
Delivery, Pickup, Đặt trước qua hotline — cùng rơi vào nguồn thứ hai; đếm "ba kênh" thành "ba
nguồn" là chia sai (§4.5).

**Doanh thu tính vào ngày nào:**

- **Bán trong ngày nào thì doanh thu ngày ấy**, kể cả khoản khách nợ: doanh thu tính vào **ngày
  ghi nợ**, không phải ngày thu được tiền (chủ quán chốt 2026-08-31, `shop-facts.md` §6.14).
- ⇒ **Một lần trả nợ không bao giờ được ghi thành một khoản bán mới.** Ghi vậy là **tính doanh thu
  hai lần** cho cùng một bữa ăn — lỗi tiền nặng hơn cả việc quên thu (§3.1.6).
- Quán bán **một buổi mỗi ngày**, 06:00–11:00 (`shop-facts.md` §1), nên "một ngày" ở đây là một
  buổi bán, không có ca đơn vắt qua nửa đêm.

- **Hoàn tiền thì ngược lại: tính vào ngày HOÀN**, không phải ngày bán gốc (chủ quán chốt
  2026-09-01, `shop-facts.md` §6.4). Lý do hai luật đi ngược chiều nhau ở §4.8.

⇒ **Doanh thu của một ngày đã đối soát xong không bao giờ đổi về sau.** Đây là hệ quả đắt nhất của
hai lời chốt trên, và là thứ giữ cho §4.9 có nghĩa: mọi chuyện xảy ra **sau** khi đóng sổ một ngày
— khách trả nợ, quầy hoàn tiền — đều rơi vào **ngày mới**, nên con số đã ký hôm qua đọc lại lúc nào
cũng bằng chính nó. Cùng một ràng buộc mà I-009 giữ cho từng đơn, ở mức một ngày bán
(`quality/invariants.md` I-014).

*Ghi lại cho phiên sau:* trong ngày 2026-09-01, §4 từng chạy bằng **giả định ngược lại** — hoàn
tiền trừ vào ngày bán gốc — và giả định ấy đã được ghi ra kèm rủi ro của nó (BA-06, U-019). Chủ
quán trả lời trong ngày và chốt **ngược**; đúng như phần rủi ro đã dặn, chỗ phải sửa là §4.8–§4.10
và cách bày bảng đối soát, **không** phải dữ liệu quá khứ — cả hai mốc thời gian đều đã được ghi.

### 4.11 Bốn việc mục này cố ý không nói tới

- **Màn hình nào bày ra báo cáo doanh thu, và ai xem được.** Mọi thao tác chạm tiền phải kiểm
  chứng lại được (§1.4), nhưng bày ra ở đâu là câu của §7 (BA-09).
- **Giảm giá và khuyến mãi.** Công thức giá ở `shop-facts.md` §4.1 không có số hạng nào cho chúng,
  và mười một tổ hợp ở §4.8 là hợp đồng đầy đủ — nên MVP **không** có giảm giá. Thêm vào là **đổi
  phạm vi, quyền chủ quán** (`shop-facts.md` §6.12), không phải việc của mục này.
- **Số tài khoản ngân hàng, và mọi chuyện tích hợp.** Số tài khoản do chủ quán nhập trong phần
  quản trị, không cứng trong sản phẩm (`shop-facts.md` §1, §6.12).
- **Cách tính toán được viết ra sao, và tiền được lưu ở đâu.** Đó là việc của
  `docs/architecture.md`; mục này chỉ chốt luật.

