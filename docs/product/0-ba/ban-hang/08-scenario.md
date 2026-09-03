# §8 — Scenario nghiệm thu BA

> **Owner của mục này** — bản lưu không sở hữu gì. Giữ nguyên số §8: ~180 câu trong repo trỏ
> theo số cũ. Ở lượt tách DOC-1 (2026-09-02) mục này còn rỗng — nguyên văn bản lưu chỉ có một
> dòng *"Chưa chốt — BA-11"* — nên phần dưới **không** phải bản chép của `docs/product.md`,
> nó được viết mới tại đây ngày 2026-09-03 (BA-11, `docs/decisions.md` ADR-014).

## 8. Scenario nghiệm thu BA

> **Quyết định gốc mà ba scenario dựa vào:** → **ADR-015** (năm kênh) · **ADR-016** (ai duyệt,
> ai huỷ) · **ADR-021** (giờ hẹn, `Đang giao`) · **ADR-023** (mốc khoá giá là từng dòng, đổi giá
> giữa buổi) · **ADR-025** (phụ thu suất trứng ×5) · **ADR-026** (vòng đời việc trạm) ·
> **ADR-027** (ghép bàn) · **ADR-030** (trả trước). Mục này **không** sinh ADR mới.

*BA-11 — chốt 2026-09-03. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §12 (cổng
chất lượng BA, ba scenario bắt buộc), §3 (ba lát cắt) + `master_plan/shop-facts.md` §4.2–§4.5,
§4.8 (giá và thành phần), §5.2, §5.3 (luồng mang đi, nổ việc xuống bếp), §6.1, §6.2, §6.3 (ba luật
tiền). Đầu vào: §1–§7 của `docs/product/0-ba/ban-hang/`, `docs/decisions.md`,
`quality/invariants.md`.*

**Mục này không đặt ra một luật nghiệp vụ nào.** Nó chạy thử §1–§7: ba lát cắt được diễn lại từ
đầu đến cuối bằng ngôn ngữ của quán, và mỗi bước phải **trỏ được** về mục đã chốt luật cho bước
ấy. Bước nào không trỏ được thì đó là **lỗ hổng tài liệu** — ghi thành finding và mở lại task BA
tương ứng, **không** lấp bằng cách viết thêm một luật mới ở đây.

**Con số trong mục này là bản chép**, không phải nhà thật. Mọi giá tra từ
`master_plan/shop-facts.md` §4.2 (giá thành phần), §4.3 (giá một suất) và §4.4 (phụ thu); thành
phần bếp làm ra tra §4.5. **Giá đổi thì sửa nhà thật trước, rồi sửa mục này cho khớp** — hệt như
ví dụ có số duy nhất của §3.3 (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.3).

### Cách đọc ba scenario

- **Ba scenario là ba lát cắt của §3**, đúng ba scenario mà §12 kế hoạch gốc bắt buộc: một suất
  tại bàn (§3.1) · một đơn mang đi (§3.2) · chủ quán đổi giá (§3.3).
- **Mỗi scenario có bốn phần:** *Bối cảnh* — *Các bước* — *Kết quả mong đợi* — *Sai thì sai thế
  nào*. Phần thứ tư có ở đây vì một kết quả chỉ kiểm được đúng/sai khi biết **cái sai trông ra
  sao**; hai trong ba lát cắt hỏng **âm thầm**, không có gì nổ ra để ai nhìn thấy.
- **Cột *Luật ở đâu* là phần nghiệm thu thật.** Ba cột đầu kể chuyện; cột cuối là bằng chứng câu
  chuyện ấy đã được chốt ở đâu đó chứ không phải người viết vừa nghĩ ra.
- **Không bước nào nói máy làm thế nào.** Ở đây chỉ có: ai làm, làm gì ở quán, con số nào phải ra.
  Cách hệ thống thực hiện thuộc giai đoạn sau (§7.9, kế hoạch gốc §13).
- **Tên trạng thái dùng đúng bộ tên của `docs/product/0-ba/ban-hang/05-vong-doi.md` §5**, tên trạm
  đúng năm tên ở `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.5, tên kênh đúng §2.
- **Muốn kiểm TIỀN thì phải mở `master_plan/shop-facts.md` §4.2–§4.3 cùng lúc.** §4 của tài liệu
  này **cố ý không giữ một ô giá nào** (ADR-001), nên cộng lại tổng của một suất chỉ từ §1–§8 là
  không làm được — giá từng thành phần, kể cả giá **một quả trứng**, sống ở nhà thật.

### Scenario 1 — Khách QR tại bàn, gọi ba lượt, thu tiền một lần

**Bối cảnh.** Sáng thứ Hai, trong giờ bán, quán đang nhận đơn. **Bàn 5** đang ở `Trống`. Hai khách
ngồi vào. Bảng giá đang hiệu lực đúng như `master_plan/shop-facts.md` §4.3. Không ai đổi giá trong
suốt scenario này (ca đổi giá giữa buổi là Scenario 3).

**Các bước.**

| # | Ai làm | Việc gì ở quán | Luật ở đâu |
|---|---|---|---|
| 1 | *Khách* | Ngồi vào bàn 5 đang trống và **quét QR gọi lượt đầu**: **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**. Phiên bàn của bàn 5 mở ra ở `Mở` **vào lúc lượt gọi đầu tiên được tạo**, không phải lúc khách ngồi xuống | §3.1.1 bước 1–3 · §3.1.2 · §5.3 · I-001 |
| 2 | *Hệ thống* | Tự xác định tiền của lượt gọi: **34.000 × 2 = 68.000đ**. **Giá do quán quyết, khách không khai giá** | §4.2 · `shop-facts.md` §4.3, §4.8 ca 10 · I-013 |
| 3 | *Người đứng quầy*, rồi *Hệ thống* | Quầy **duyệt** lượt 1: `Chờ xác nhận` → `Đã xác nhận`. Từ đó sang `Đang thực hiện` là bước của **hệ thống**, không phải một nút ai bấm. Trước lúc duyệt, đơn **chưa sinh một việc nào** ở cả năm trạm | §2.2 · §3.1.3 · §5.2 · §5.5 · I-004 |
| 4 | *Hệ thống* | Nổ lượt 1 thành **sáu việc trên ba trạm** — **tráng bánh**: bánh cuốn ×6 · trứng tái ×2 · **gấp bánh**: bánh cuốn ×6 · trứng tái ×2 · giò ×2 · **lấy canh**: nước chấm cho bàn 5. Ba trạm bếp nhận việc **cùng lúc** | §3.1.5 · §5.4 · `shop-facts.md` §4.5, §5.3, §6.6 |
| 5 | *Người đứng quầy* | Bếp làm xong mẻ; quầy bấm **"đã làm xong"** (`Chưa làm` → `Đã làm xong, còn ở bếp`), món bưng ra bàn rồi quầy bấm **"đã ra bàn"** cho cả sáu việc. Ba trạm bếp **không bấm gì** | §5.4 · `shop-facts.md` §5.4 |
| 6 | *Hệ thống* | Cả sáu việc đã `Đã ra bàn` ⇒ đơn của lượt 1 sang **`Hoàn thành`** | §5.5 · §5.2 |
| 7 | *Khách* → *Người đứng quầy* | **Lượt 2**: khách không tự bấm nữa mà nhờ quầy đặt hộ **1 suất giò, nhân thịt, lượng thường** — **25.000đ**. Đơn đặt hộ vào **thẳng** `Đã xác nhận`, không qua bước duyệt | §3.1.2 · §2.2 · §5.2 · `shop-facts.md` §4.3 |
| 8 | *Hệ thống* | Lượt 2 vào **chính** phiên của bàn 5, không mở phiên thứ hai và không tạo đơn lẻ nào | §3.1.4 · §3.1.2 · I-001 |
| 9 | *Người đứng quầy* | Lượt 2 nổ việc, bếp làm, quầy bấm hai mốc như bước 5 ⇒ đơn lượt 2 sang `Hoàn thành` | §3.1.5 · §5.4 · §5.5 |
| 10 | *Người đứng quầy* | Khách xin tính tiền. Quầy tính tổng **cả** phiên: 68.000 + 25.000 = **93.000đ**. Phiên sang `Chờ thanh toán`. **Bàn 5 chưa trống** | §3.1.1 bước 11 · §3.1.4 · §5.3 |
| 11 | *Khách* | **Lượt 3 — gọi thêm SAU khi quầy đã bắt đầu thu tiền**: quét QR gọi thêm **1 suất bánh cuốn chay — 3.000đ**. Phiên quay về `Đang phục vụ` | §3.1.4 · §5.3 · `shop-facts.md` §6.1 · I-002 |
| 12 | *Người đứng quầy* | Duyệt lượt 3, bếp làm, quầy bấm **"đã làm xong"** rồi **"đã ra bàn"** ⇒ đơn lượt 3 sang `Hoàn thành`. **Bước này không được bỏ**: phiên không đóng được khi còn một đơn chưa `Hoàn thành` và chưa `Huỷ` | §5.2 · §5.4 · §5.5 · I-017 |
| 13 | *Người đứng quầy* | Tính lại tổng của **cùng một hoá đơn**: 68.000 + 25.000 + 3.000 = **96.000đ**. Vẫn **một** hoá đơn, không mở hoá đơn thứ hai | §3.1.4 · §4.5 · I-002 |
| 14 | *Khách* → *Người đứng quầy* | Khách trả **60.000 tiền mặt + 36.000 VietQR**. Quầy nhìn tiền, nhìn báo có, rồi tự bấm xác nhận **đã nhận tiền**; POS ghi **số tiền của từng phần** | §4.6 · §1.4 · `shop-facts.md` §6.18 · I-015 |
| 15 | *Người đứng quầy* | Đóng phiên → `Đã đóng`. Đóng được **vì** mọi đơn của phiên đã `Hoàn thành` ở bước 6, 9 và 12 | §5.3 · §5.5 · I-017 |
| 16 | *Hệ thống*, rồi *người canh & dọn* | Phiên đóng ⇒ bàn 5 sang **`Bàn cần dọn`**. Người canh & dọn dọn bàn và xác nhận đã dọn | §3.1.1 bước 14 · §5.3 · §1.5 |
| 17 | *Hệ thống* | Bàn 5 trở lại `Trống` — sau **hai** việc: phiên `Đã đóng` **và** bàn đã dọn | §3.1.1 bước 15 · §3.1.4 · §5.3 · I-003 |

**Thứ tự bước 10 và bước 12 là thói quen của quán, không phải điều kiện.** Vào `Chờ thanh toán`
**không** đòi hỏi đơn nào phải xong — quầy được tính tiền trong khi bếp còn một bát canh chưa
bưng ra. Ràng buộc cứng chỉ nằm ở `Đã đóng`, và chỉ ở đó (§5.5).

**Kết quả mong đợi — kiểm được đúng/sai.**

| Phải ra | Con số / trạng thái |
|---|---|
| Số lần thanh toán | **1**, dù có **ba** lượt gọi bằng **hai** kênh khác nhau |
| Số hoá đơn | **1**, tổng **96.000đ** = 68.000 + 25.000 + 3.000 |
| Lượt gọi thêm sau khi quầy đã bắt đầu thu tiền | vẫn nằm trong **chính hoá đơn ấy**; không sinh hoá đơn thứ hai |
| Số lượng bếp nhận được ở lượt 1 | **6 cái bánh · 2 quả trứng · 2 chiếc giò · 1 việc nước chấm** — khác con số **×2 suất** trên hoá đơn |
| Số việc trạm lượt 1 sinh ra | **6** — vì bánh và trứng mỗi thứ có việc ở **hai** trạm (tráng và gấp), còn nước chấm là việc **cấp đơn** |
| Tổng tiền lượt 1 | **68.000đ**, tra `master_plan/shop-facts.md` §4.3 (34.000 × 2) |
| Điều kiện để phiên đóng được | mọi đơn của phiên ở `Hoàn thành` **hoặc `Huỷ`** — ở scenario này không đơn nào bị huỷ, nên là **mọi** việc trạm của **cả ba** lượt đã ở `Đã ra bàn` |
| Trạng thái cuối của bàn 5 | **`Trống`** |
| Trạng thái cuối của mọi đơn trong phiên | **`Hoàn thành`** |
| Số phiên bàn mở cho bàn 5 trong cả scenario | **1** |

**Sai thì sai thế nào.** Bốn cách hỏng, xếp theo mức đắt:

- **Lượt 3 bị tách ra hoá đơn thứ hai** ⇒ quán **thu thiếu 3.000đ** và không ai thấy lỗi nào —
  đây là lỗi tiền nguy hiểm nhất của luồng tại bàn (`shop-facts.md` §6.1, I-002).
- **Bàn 5 được coi là trống ngay khi phiên sang `Chờ thanh toán`** ⇒ khách sau được xếp vào một
  bàn chưa dọn, và lượt gọi của họ rơi vào phiên của người trước (I-001, I-003).
- **Phiên đóng khi lượt 3 còn một việc ở bếp** ⇒ khách trả tiền rồi ra về mà suất chay chưa bưng
  ra, và không còn phiên nào mở để ai nhìn thấy việc ấy (§5.5, I-017).
- **Bếp đọc "×2" rồi tráng hai cái bánh** ⇒ thiếu bốn cái bánh, và cái sai chỉ lộ ra khi đĩa
  bưng ra bàn (§3.1.5).

**Một chỗ scenario này cố ý KHÔNG dựa vào:** bấm *"đã ra bàn"* theo **đơn vị nào** — mẻ hay bàn —
là chỗ **suy ra chưa xác nhận** (`master_plan/shop-facts.md` §7.2, **S-5**). Scenario 1 chỉ có
**một** bàn nên hai cách đọc cho cùng kết quả; ca phân biệt được chúng thuộc §3.4 (BA-12).

### Scenario 2 — Ba đơn mang đi, ba kênh, không đơn nào gắn phiên bàn

**Bối cảnh.** Cùng buổi sáng, trong giờ bán, quán đang nhận đơn. Ba đơn tới bằng **ba kênh không
gắn bàn** (§2.1). Đơn A và đơn C là của **cùng một khách**, đặt cách nhau mười phút — chỗ này cố
ý, nó là ca dễ gộp nhầm nhất.

| Đơn | Kênh | Khách gọi | Tiền | Cách trao hàng |
|---|---|---|---|---|
| **A** | **Delivery** — khách tự bấm | 2 suất trứng tái, thịt + mộc nhĩ, thường | 25.000 × 2 = **50.000đ** | quán giao tận nơi |
| **B** | **Pickup** — khách tự bấm, hẹn 8:30 lấy | 1 combo "Đầy đủ" trứng chín, thịt, thường | **30.000đ** | khách tới lấy, và khách chọn **trả trước** |
| **C** | **Đặt trước qua hotline** — khách gọi điện, quầy nhập hộ | 3 suất bánh cuốn, thịt, nhiều nhân | 5.000 × 3 = **15.000đ** | khách tới lấy lúc 9:00 |

*(Giá tra `master_plan/shop-facts.md` §4.3 và §4.8 — ca 6, ca 9, ca 3. Ba định danh máy tương ứng
của ba kênh là `delivery` · `pickup` · `phone_preorder`; chép ra đây **một lần** để ghép được với
`master_plan/shop-facts.md` §5.2, sau dòng này scenario chỉ dùng tên người đọc — đúng tiền lệ
§3.2.)*

**Các bước.**

| # | Ai làm | Việc gì ở quán | Luật ở đâu |
|---|---|---|---|
| 1 | *Khách* | Đặt **đơn A** bằng Delivery, khai **số điện thoại** và **địa chỉ giao** — hai trường bắt buộc | §3.2.1 bước 1, 3 · §3.2.4 · `shop-facts.md` §6.5 |
| 2 | *Khách* | Đặt **đơn B** bằng Pickup, khai số điện thoại và **giờ hẹn lấy 8:30**; chọn **trả trước** bằng VietQR | §3.2.1 bước 1, 5 · §3.2.4 · §3.2.5 |
| 3 | *Khách* → *Người đứng quầy* | **Đơn C**: khách gọi hotline. Quầy **phải hỏi hai câu**: giao tận nơi hay tới lấy, và cần hàng lúc mấy giờ. Khách chọn **tới lấy lúc 9:00** ⇒ đơn này **không** cần địa chỉ | §3.2.1 bước 2 · §3.2.3 · §3.2.4 |
| 4 | *Hệ thống* | Tạo **ba đơn lẻ**, không đơn nào gắn phiên bàn. Đơn A và B vào `Chờ xác nhận`; **đơn C vào thẳng `Đã xác nhận`** | §3.2.1 bước 5 · §3.2.5 · §5.2 · I-007 |
| 5 | *Người đứng quầy* | Duyệt **đơn A và đơn B**. **Đơn C không đi qua bước duyệt** — nhân viên đã nhập thì đã có người chịu trách nhiệm | §2.2 · §3.2.1 bước 7 · §3.2.3 · `shop-facts.md` §6.2 |
| 6 | *Người đứng quầy* | Nhận **tiền trả trước của đơn B**, rồi mới bấm xác nhận **đã nhận tiền** — không bấm vào lúc khách chọn "trả trước" | §3.2.5 · §4.6 · `shop-facts.md` §6.3 |
| 7 | *Hệ thống* | Nổ ba đơn thành việc của từng trạm, cách nổ **y hệt** đơn tại bàn. **Mỗi đơn sinh đúng một việc nước chấm**, và nước chấm **gói riêng** | §3.2.1 bước 8 · §3.1.5 · `shop-facts.md` §5.3, §6.6 |
| 8 | *Người đứng quầy* | Bếp làm xong mẻ; quầy bấm **"đã làm xong"** ⇒ việc của cả ba đơn sang `Đã làm xong, còn ở bếp`. Ba trạm bếp **không bấm gì** | §5.4 · `shop-facts.md` §5.4 |
| 9 | *Nhân viên quán* | **Đóng gói** từng đơn. Không đơn nào có bước bưng ra bàn | §3.2.1 bước 8 · §3.2.7 |
| 10 | *Người đứng quầy* | **Đơn A** rời quán ⇒ đơn mang trạng thái **`Đang giao`**, để quầy biết đơn nào còn trên đường và **ai đang cầm tiền chưa về** | §3.2.2 · §5.2 · `shop-facts.md` §6.7 |
| 11 | *Nhân viên quán* đi giao | Giao đơn A tới địa chỉ khách, **trao hàng**, **thu tiền tại chỗ khách**, bấm **đã giao** và **đã thu tiền** cùng lúc ⇒ đơn A `Hoàn thành`. **Ai đẩy việc trạm của đơn A sang `Đã ra bàn` thì §5 chưa nói được** — xem mục *Lỗ hổng* | §3.2.2 · §4.6 · §5.2 · §5.5 |
| 12 | *Khách* → *Người đứng quầy* | **Đơn B**: khách tới lấy lúc 8:30, quầy **trao hàng** ⇒ việc trạm sang `Đã ra bàn` ⇒ đơn B `Hoàn thành`. Tiền đã nhận ở bước 6 nên **không thu lại** | §3.2.2 · §3.2.5 · §5.4 · §5.5 |
| 13 | *Khách* → *Người đứng quầy* | **Đơn C**: khách tới lấy lúc 9:00, quầy trao hàng và **thu tiền tại quầy** ⇒ đơn C `Hoàn thành`. Đơn C **không** đi qua `Đang giao` | §3.2.2 · §3.2.3 · §5.2 · §5.5 |
| 14 | — | Không đơn nào có bước dọn bàn; luồng dừng ở bước 13 | §3.2.1 bước 9 · §3.2.7 |

**Mốc `Đã ra bàn` của một đơn mang đi là lúc TRAO, không phải lúc đóng gói** — §5.4 gọi mốc ấy là
*"đóng gói và trao"*, và §5.5 chốt chiều còn lại: đơn chỉ `Hoàn thành` khi **mọi** việc đã
`Đã ra bàn`, mà đơn A chỉ `Hoàn thành` lúc người giao bấm *đã giao*. Ghép hai mục lại thì **lúc
nào** là mốc chỉ còn một cách đọc.

**Nhưng *AI* bấm mốc ấy cho một đơn giao tận nơi thì §5 chưa trả lời được.** §5.4 ghi người kích
hoạt `Đã ra bàn` là ***người đứng quầy*, trên POS** — trong khi lúc trao hàng, người ở đó là
***nhân viên quán* đi giao**, và §5.2 giao đúng cho người ấy hai nút *đã giao* / *đã thu tiền*.
Hai mục đã chốt cho hai người khác nhau. Scenario này **không tự chọn một trong hai** (CLAUDE.md
§3.5): nó ghi lại chỗ hở — xem mục *Lỗ hổng*.

**Kết quả mong đợi — kiểm được đúng/sai.**

| Phải ra | Con số / trạng thái |
|---|---|
| Số đơn vị thanh toán | **3** — mỗi đơn một đơn vị, kể cả đơn A và đơn C **cùng một khách** |
| Số lần thu tiền | **3**: một tại chỗ khách (A), một trả trước (B), một tại quầy (C) |
| Đơn nào gắn phiên bàn | **không đơn nào**, cả ba kênh |
| Trạng thái cuối của cả ba đơn | **`Hoàn thành`** |
| Đường đi của đơn đặt trước qua hotline (đơn C) | `Mới` → **thẳng** `Đã xác nhận` — **không** qua `Chờ xác nhận`, tức **không qua bước quầy duyệt** |
| Đơn nào có `Đang giao` | **chỉ đơn A**; B và C đi thẳng từ `Đang thực hiện` sang `Hoàn thành` |
| Số việc nước chấm | **3** — một việc cho mỗi đơn, gói riêng, không nhân theo số suất |
| Mốc bấm "đã nhận tiền" của đơn B | lúc **quán nhận được tiền**, không phải lúc khách chọn "trả trước" |
| Điều kiện để một đơn `Hoàn thành` | **mọi** việc trạm của nó đã `Đã ra bàn` — tức đã **trao**, không phải đã đóng gói |
| Số bước dọn bàn | **0** |

**Sai thì sai thế nào.**

- **Đơn C bị bắt qua bước duyệt** ⇒ nó nằm ở `Chờ xác nhận`, **không sinh một việc nào** ở bếp;
  9:00 khách tới lấy thì chưa có hàng. Đây là ca hỏng của đúng kênh mới nhất và ít được diễn thử
  nhất (§2.2, §3.2.3).
- **Đơn A và đơn C bị gộp vì cùng một khách** ⇒ một khoản tiền đứng ở hai chỗ, và báo cáo doanh
  thu cộng sai nguồn (§3.2.5, I-007, I-014).
- **Đơn B bị thu tiền lần nữa lúc trao hàng** ⇒ thu thừa của khách, và đối soát cuối ngày lệch mà
  không ai truy được (§4.6, §4.9).
- **Đơn A sang `Hoàn thành` ngay khi đóng gói** ⇒ quầy mất đúng thứ `Đang giao` sinh ra để giữ:
  **ai đang cầm tiền chưa về** (§3.2.2, `shop-facts.md` §6.7).
- **Một đơn mang đi bị nối vào một phiên bàn** — ví dụ khách đơn C đổi ý, tới quán ngồi ăn: đường
  đúng là **huỷ đơn C** rồi khách quét QR gọi lại, **không** có đường nối (§2.4, §3.2.3).

### Scenario 3 — Chủ quán đổi giá giữa buổi: đơn mới theo giá mới, đơn cũ đứng yên

**Bối cảnh.** Cùng ngày. **Bàn 3** mở phiên lúc 8:00. Món dùng để đo là **suất giò, nhân thịt,
lượng thường** — giá đang hiệu lực **25.000đ**, tức 9.000 (một chiếc giò) + 4 × 4.000 (bốn cái
bánh nhân thường), tra `master_plan/shop-facts.md` §4.2–§4.3.

**Các bước.**

| # | Ai làm | Việc gì ở quán | Luật ở đâu |
|---|---|---|---|
| 1 | *Khách* | 8:00 — bàn 3 gọi **1 suất giò, nhân thịt, lượng thường**. Dòng ấy khoá giá ở **25.000đ** ngay lúc lượt gọi được tạo | §4.4 · §3.3.3 · I-009 |
| 2 | *Chủ quán* | 8:30 — nâng **giá gốc của một cái bánh cuốn** (giá **chay**, `shop-facts.md` §4.2) từ **3.000** lên **4.000**. Đây là **chiều 1** trong bốn chiều — đổi giá một **thành phần**; hai mức phụ thu ở §4.4 **không đổi**, nên bánh nhân thường thành **5.000** và bánh nhiều nhân thành **6.000** | §3.3.1 bước 2 · §3.3.2 chiều 1 · `shop-facts.md` §4.1, §4.2, §4.6 luật 2 |
| 3 | *Chủ quán* | Lưu. **Có hiệu lực ngay, giữa giờ bán cũng được** — không có lịch hẹn giờ, không có "áp dụng từ ngày mai" | §3.3.1 bước 3 · `shop-facts.md` §6.17 |
| 4 | *Hệ thống* | Menu khách nhìn thấy đổi theo ở **cả năm kênh** | §3.3.1 bước 4 · §2 |
| 5 | *Khách* | 9:00 — bàn 3 gọi thêm **đúng một suất giò cùng loại**. Dòng mới khoá giá ở **29.000đ** = 9.000 + 4 × 5.000 | §3.3.1 bước 5 · §4.4 · `shop-facts.md` §4.3 |
| 6 | *Người đứng quầy* | Mở lại đơn lúc 8:00 để đối chiếu ⇒ vẫn **25.000đ**, vẫn đúng tên món, vẫn đúng số bánh bếp đã làm | §3.3.3 · §3.3.6 · I-009 |
| 7 | *Người đứng quầy* | Đóng phiên bàn 3: **một** hoá đơn, tổng **54.000đ** = 25.000 + 29.000 — **một hoá đơn mang hai mức giá cho cùng một món**, và đó là kết quả **đúng** | §4.4 · §3.1.4 · §3.3.6 · I-002 · I-009 |
| 8 | *Chủ quán* | 10:00 — **ngừng bán** suất giò ⇒ không kênh nào đặt mới được món đó, nhưng đơn 8:00 vẫn hiện đúng tên *"suất giò"* và đúng **25.000đ** | §3.3.4 · I-009 |
| 9 | *Chủ quán* | Bấm sửa **thành phần** combo "Đầy đủ" từ 3 cái bánh xuống 2 — **chiều thứ tư**. Luật là **chờ hết buổi**, nhưng đó là **luật cho NGƯỜI, không phải hàng rào của máy**: máy **nhắc một câu** rồi **vẫn cho lưu**, và để lại vết | §3.3.2 chiều 4 · **§3.3.6** · `shop-facts.md` §6.17 · I-011 |
| 10 | *Người đứng quầy* | Mở lại đơn của Scenario 1 sau khi thành phần đã đổi ⇒ vẫn **68.000đ** và vẫn **6 cái bánh** cho hai suất combo | §3.3.3 · I-009 |

**Vì sao bước 2 nói *"nâng giá chay"* chứ không nói *"nâng giá bánh nhân thường"*.** Ví dụ ở §3.3.3
và ở `quality/invariants.md` I-009 viết vế sau — và **câu ấy cho hai kết quả khác nhau**: đọc theo
bảng ô §4.2 thì suất giò mới là 29.000, đọc theo công thức §4.1 (*giá gốc chay + phụ thu*) thì vẫn
là 25.000, vì phụ thu không đổi. Nâng riêng ô *Thịt thường* lên 5.000 còn làm nó **bằng** ô *Thịt
nhiều*, tức xoá mất bậc phụ thu +1.000 của §4.4. Scenario này viết lại thao tác ấy thành một thao
tác **chỉ có một nghĩa** và ra **đúng con số 29.000** mà §3.3.3 đã chốt. Chỗ nhập nhằng ở §3.3.3
và I-009 là một lỗ hổng thật — xem mục *Lỗ hổng*.

**Kết quả mong đợi — kiểm được đúng/sai.**

| Phải ra | Con số |
|---|---|
| Tổng tiền đơn cũ (8:00) sau khi giá menu đổi | **25.000đ** — **không đổi**, chừng nào **không ai SỬA dòng ấy**: một lần đổi giá không bao giờ tự với ngược vào đơn cũ, nhưng quầy **sửa** dòng thì mốc khoá giá của chính dòng đó đặt lại (§4.4, §6.1 dòng 13) |
| Tổng tiền đơn cũ sau khi món bị **ngừng bán** | vẫn **25.000đ**, và tên món vẫn hiện đúng |
| Tổng tiền đơn cũ sau khi **thành phần suất** đổi | vẫn **68.000đ** cho đơn Scenario 1, vẫn **6 cái bánh** |
| Tổng tiền đơn mới (9:00), cùng món, cùng tuỳ chọn | **29.000đ** |
| Hoá đơn của phiên bàn 3 | **1 hoá đơn**, tổng **54.000đ**, mang **hai** mức giá cho cùng một món |
| Đổi thành phần suất giữa giờ bán | **xảy ra được** — máy nhắc rồi vẫn cho lưu. Cái sản phẩm bảo đảm **không** phải là nó không xảy ra, mà là nó **không xảy ra âm thầm**: có lời nhắc trước, có vết đọc được sau (§3.3.6, I-011) |
| Doanh thu của một ngày đã đối soát xong | đọc lại lúc nào cũng bằng chính nó |

**Sai thì sai thế nào.** Lát cắt này hỏng **âm thầm** — không có thao tác sai, không có gì nổ ra,
chỉ có số tiền của một bữa ăn đã bán tự đổi sau lưng (§3.3, I-009):

- **Tính lại cả phiên theo giá mới lúc thanh toán** ⇒ hoá đơn bàn 3 ra **58.000đ** thay vì
  54.000đ. Đó là sửa tiền của thứ khách đã ăn xong, và nó lệch **4.000đ** không ai giải thích được
  khi đối soát — nơi ngưỡng lệch là **0đ** (§4.9, `shop-facts.md` §6.10).
- **Khoá giá theo lúc mở phiên** ⇒ dòng 9:00 ăn giá cũ, quán **thu thiếu**. Mốc là **lượt gọi**,
  không phải phiên và không phải lúc thanh toán (§4.4, §3.3.6).
- **Đọc lại đơn combo cũ theo thành phần mới** ⇒ sai cả tiền lẫn **thứ bếp đã thật sự làm ra hôm
  đó**; đây là chiều dễ quên nhất trong bốn chiều (§3.3.2, I-009, I-011).
- **Dựng hàng rào chặn chủ quán sửa thành phần giữa buổi** ⇒ chặt hơn quán thật. §3.3.6 đã gọi tên
  đường ấy là đường chủ quán **không** chọn: chủ quán giữ quyền tự phá luật của chính mình, và
  việc của sản phẩm là **nhắc** rồi **ghi vết**, không phải **chặn**.

**Một phân biệt phải giữ cho sắc** (chủ quán chốt 2026-09-02, `shop-facts.md` §6.19): scenario này
là ca *"đổi giá menu rồi **không** đụng gì vào đơn"* ⇒ mọi dòng giữ giá cũ. Ca khác — *"đổi giá
menu rồi **sửa** một dòng"* ⇒ **chỉ dòng ấy** lấy giá mới, vì mốc khoá giá của chính dòng đó được
đặt lại bởi **thao tác cố ý của người đứng quầy**, không phải bởi lần đổi giá (§4.4, I-009).

### Cổng chất lượng BA — chín mục

Chín mục dưới đây là nguyên văn cổng chất lượng ở `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`
§12. **Tick là tick thật:** mục nào chưa đạt thì để trống kèm lý do, không tick trước rồi vá sau.
Hôm nay **9/9 đạt** (BA-11 tick 6 ngày 2026-09-03; **BA-13** tick nốt mục 6, 7 và 8 cùng ngày, sau
khi dọn năm chỗ mà ba ô ấy trượt vì).

**Chín ô xanh KHÔNG có nghĩa là không còn gì phải hỏi.** Cổng này chấm **tài liệu BA**. Tính tới
2026-09-03 còn **một** câu đang chờ chủ quán — **U-031**, *ai bấm mốc `Đã ra bàn` cho một đơn
**giao tận nơi*** (`docs/product/99-unknowns.md` → *Đang mở*; đánh dấu ở `05-vong-doi.md` §5.2 và
§5.4) — và nó **chặn phiên System Design** dựng màn quầy cùng màn người đi giao, vì §5.5 buộc mọi
việc trạm phải ở `Đã ra bàn` trước khi đơn sang `Hoàn thành`. Mục 7 xanh **vì** câu ấy được ghi ra
đúng chỗ, không phải vì nó không tồn tại.

- [x] **1. Có đủ năm kênh bán rõ ràng, đúng tên ở `master_plan/shop-facts.md` §2.**
  §2 chốt năm kênh và chia chúng thành hai nhóm theo đơn vị tính tiền (§2.1); ba scenario trên
  chạy qua **cả năm**: QR tại bàn và Staff POS ở Scenario 1, Delivery · Pickup · Đặt trước qua
  hotline ở Scenario 2.
- [x] **2. Có 3 lát cắt nghiệp vụ từ đầu đến cuối.**
  §3.1, §3.2, §3.3 — cả ba đã chốt (BA-03, BA-04, BA-05) và cả ba vừa được diễn lại ở trên.
  *Kèm một câu phải đọc:* **§3.4 (lát cắt sản xuất theo mẻ) chưa được viết** — nó là **BA-12**,
  còn ở *Ready*. Nó **không** nằm trong ba scenario mà §12 bắt buộc, nên mục này đạt; nhưng xem
  mục *Lỗ hổng* bên dưới trước khi coi giai đoạn BA là đóng.
- [x] **3. Có quy tắc giá và tiền.**
  §4 chốt luật gốc (§4.1), mười một tổ hợp bắt buộc phủ (§4.3), mốc khoá giá (§4.4), đơn vị thanh
  toán (§4.5), hai phương thức và ai nói được câu *"đã nhận tiền"* (§4.6), nợ (§4.7), hoàn tiền
  (§4.8), đối soát (§4.9), doanh thu hai nguồn (§4.10). Ba scenario chạm **năm** mục trong số đó:
  §4.2, §4.4, §4.5 và §4.6 ở các bước, §4.9 ở phần *Sai thì sai thế nào* của Scenario 3.
- [x] **4. Có vòng đời đơn và phiên bàn.**
  §5.2 (đơn), §5.3 (phiên bàn và cái bàn của nó), §5.4 (công việc trạm) — ba bảng chuyển tiếp đầy
  đủ, kèm §5.5 bốn chỗ ba vòng đời ràng buộc nhau. Ba scenario đi hết **đường thuận** của cả ba
  vòng đời: `Chưa làm` → `Đã làm xong, còn ở bếp` → `Đã ra bàn` · `Mới` → … → `Hoàn thành` ·
  `Mở` → … → `Đã đóng` → `Bàn cần dọn` → `Trống`. *Hai đường ra KHÔNG được diễn ở đây:* `Huỷ`
  (đơn) và `Hoàn thành → Huỷ` — chúng thuộc §6, và §12 không đòi một scenario cho chúng.
- [x] **5. Có các ngoại lệ quan trọng.**
  §6.1 — mười bốn tình huống, **không dòng nào còn mang dấu ⚠** (T-045, 2026-09-02). Tick vì mục
  này hỏi các ngoại lệ **có mặt** hay không, và mười bốn dòng đều có mặt. *(Lượt BA-11 ghi ở đây
  rằng dòng 7 còn mang một câu cũ nói ngược dòng 13 và giao chỗ đó cho mục 7. **BA-13 đã sửa dòng
  7 ngày 2026-09-03**: nay dòng 7, dòng 13, §6.2 và bảng §5.2 nói cùng một câu.)*
- [x] **6. Có danh sách quyết định chưa rõ/giả định.** — **đạt 2026-09-03 (BA-13).**
  Ba danh sách đều tồn tại (`docs/decisions.md` · `docs/product/99-unknowns.md` ·
  `master_plan/shop-facts.md` §7.2), và nay **cả ba nói cùng một câu**. Chỗ trượt của lượt trước —
  bảng tổng hợp đầu `docs/decisions.md` còn xếp **GĐ-01** và **GĐ-05** là *Giả định* đang sống
  trong khi thân hai mục ghi **Superseded** — đã sửa: hai dòng bảng, đoạn văn dưới bảng, hàng
  tiêu đề của bảng, và một chỗ thứ ba mà `grep` tìm ra ở `docs/product/99-unknowns.md`. ⇒ trả lời
  *"còn giả định nào đang sống không"* nay là **không**, đọc ở chỗ nào cũng thế.
  Phép so ấy nay **do máy chấm ở mọi lượt** — `scripts/check-doc-status.sh` phép D
  (`docs/decisions.md` **ADR-032**), nên nó không hỏng lại lặng lẽ được nữa.
- [x] **7. Không còn business rule quan trọng bị suy đoán.** — **đạt 2026-09-03 (BA-13).**
  Bốn câu nói rằng một luật đã chốt vẫn đang treo đã sửa hết (**F-015**): §1.2 ghi *người đứng
  quầy bấm lúc nhận tiền* · §4.9 ghi *đối chiếu VietQR bằng tin nhắn báo có* · §6.1 dòng 7 và §6.2
  ghi đường `Hoàn thành` ⇒ `Huỷ` là **hợp lệ**, khớp bảng §5.2 và dòng 13. Không câu nào còn dạy
  ngược luật thật.
  **Mục này đạt KÈM một câu hỏi đang mở, và hai điều đó không mâu thuẫn.** `99-unknowns.md` →
  *Đang mở* nay có **U-031** (ai bấm mốc `Đã ra bàn` của một đơn **giao tận nơi**) — mở **vì**
  BA-13 từ chối suy hộ một luật chủ quán chưa nói (CLAUDE.md §3.5). Mục này hỏi *"còn luật nào bị
  **suy đoán**"*, và một câu hỏi **được ghi ra, được brief in vào mọi phiên mới, được đánh dấu ở
  cả hai mục đang nói ngược nhau** là điều ngược lại với một luật bị suy đoán. Chỗ **suy ra** còn
  lại — **S-5** (`master_plan/shop-facts.md` §7.2) — cũng vậy: §5.4 gọi đúng tên nó là chỗ suy ra
  và giao cho BA-12. Không giả định `GĐ` nào còn hiệu lực (mục 6).
  *Ai ký cổng thì đọc kèm:* **U-031 chặn phiên System Design dựng màn quầy và màn người đi giao** —
  cổng này chấm **tài liệu BA**, không chấm việc U-031 đã có lời chốt hay chưa.
- [x] **8. Một người không biết code có thể đọc luồng và giải thích quán phải làm gì.** — **đạt
  2026-09-03 (BA-13), bằng lượt đọc context sạch THỨ BA.**
  Nghiệm bằng Gate 6 (`quality/review-gate.md`): **ba** lượt đọc **context sạch** ngày 2026-09-03,
  mỗi lượt chỉ được đọc §1–§8 + `master_plan/shop-facts.md` + `docs/product/99-unknowns.md`, không
  lượt nào được nghe giải thích thêm và không lượt nào được mở `work/`, `quality/` hay
  `docs/decisions.md`.
  **Lượt một** (BA-11) tắc ở ba chỗ trong chính §8 — đã sửa hết. **Lượt hai** (BA-11) cộng đúng
  toàn bộ tiền nhưng tắc ở ba chỗ nằm trong §1–§7 ⇒ **F-022**, giao cho BA-13.
  **Lượt ba** (BA-13, sau khi sửa) trả lời **CÓ**: diễn trọn cả ba scenario, mỗi bước tra được
  luật ở §1–§7, và **tự cộng lại toàn bộ tiền từ `shop-facts.md` §4.2/§4.4/§4.5 — khớp 100%**:
  Scenario 1 **96.000đ** · Scenario 2 **95.000đ** · Scenario 3 **54.000đ** (kèm ca sai 58.000đ,
  lệch 4.000đ), **tổng 245.000đ**, và cả ba ô combo của bảng §4.3 tái tạo đúng từ §4.2 + §4.5.
  Ba chỗ vừa sửa được kiểm riêng và **cả ba khớp**: phiên bàn mở lúc lượt gọi đầu tiên (ba mục nói
  cùng một câu) · ví dụ đổi giá §3.3.3 chỉ còn **một** nghĩa, ra 29.000 · `Hoàn thành` ⇒ `Huỷ`
  **hợp lệ** ở cả bốn chỗ.
  **Lượt ba dừng ở đúng MỘT chỗ, và dừng đúng cách:** ai bấm mốc `Đã ra bàn` cho một đơn **giao
  tận nơi**. Nguyên văn báo cáo: *"tài liệu NÓI RÕ đây là chỗ chưa chốt, không im lặng"* — có ID
  (**U-031**), có người trả lời (chủ quán), có hệ quả (§5.5). Người đọc **dừng lại và hỏi** thay
  vì đoán, tức tài liệu làm đúng việc của nó. Mục này hỏi *người đọc có giải thích được không*,
  không hỏi *mọi câu đã có lời chốt chưa* — cái sau là mục 7.
  **Lượt ba còn tìm ra một chỗ hỏng MỚI, và nó nằm trong §8 chứ không trong §1–§7:** mục *Lỗ hổng*
  và ô mục 5 lúc ấy còn là ảnh chụp của trạng thái **trước** khi sửa, nên một người đọc sạch *"tin
  §8 rồi đi sửa lại những chỗ đã đúng"*. Đó đúng là cơ chế **F-015** ở một tầng cao hơn — chỗ nhắc
  tới một sự thật không được quét khi sự thật ấy đổi, và lần này chỗ nhắc tới chính là §8. Đã sửa
  trong cùng lượt: mục *Lỗ hổng* nay mở đầu bằng banner nói thẳng nó là **biên bản**, và ô mục 5
  ghi rõ dòng 7 đã được sửa.
- [x] **9. Ba scenario nghiệm thu BA có thể được diễn lại bằng nghiệp vụ.**
  Ba scenario ở trên, đúng ba ca §12 bắt buộc. Mỗi bước có cột *Luật ở đâu*; không bước nào mô tả
  thao tác kỹ thuật.

**Cổng này chấm tài liệu BA, KHÔNG chấm backlog BA.** Kể cả khi cả chín mục xanh, hai việc vẫn
còn mở ở `work/backlog.md`: **BA-12** (§3.4 — lát cắt sản xuất theo mẻ) và **S-5**, câu chủ quán
chưa được hỏi mà BA-12 cần trước khi dựng bảng quầy. Ai ký cổng này thì ký kèm một câu về hai
việc đó.

### Lỗ hổng phát hiện khi diễn ba scenario — BIÊN BẢN CỦA BA-11, ĐÃ XỬ XONG

> ⚠️ **ĐỌC CÂU NÀY TRƯỚC KHI ĐỌC BẤT KỲ DÒNG NÀO DƯỚI ĐÂY.**
> Mục này là **ảnh chụp ngày 2026-09-03 trước khi sửa**, giữ lại làm **bằng chứng** của lượt diễn
> scenario. **Mọi câu §1–§7 bị trích trong mục này đều KHÔNG CÒN trong tài liệu** — chúng đã được
> **BA-13 sửa cùng ngày**. Đừng đọc mục này như tình trạng hôm nay, và **đừng đi sửa lại** những
> chỗ nó tố: mở chính file được nêu ra mà đọc.
>
> | Nhóm | Hôm nay |
> |---|---|
> | **1 — F-015**, bốn câu nói luật đã chốt vẫn treo | **đã sửa cả bốn** |
> | **2 — F-022** chỗ 1 (phiên mở lúc nào) và chỗ 3 (ví dụ đổi giá) | **đã sửa**; §3.1.1 nay khớp §5.3, ví dụ §3.3.3 chỉ còn **một** nghĩa |
> | **2 — F-022** chỗ 2 (**ai** bấm *"đã ra bàn"* của đơn **giao tận nơi**) | **CHƯA CHỐT — và đây là chỗ duy nhất của mục này còn sống.** Thành **U-031**, đang chờ **chủ quán**; ghi ở `docs/product/99-unknowns.md` → *Đang mở*, và đánh dấu ở cả `05-vong-doi.md` §5.2 lẫn §5.4. Không ai được suy hộ (CLAUDE.md §3.5) |
> | **3 — F-021**, bảng `docs/decisions.md` nói ngược thân | **đã sửa** |
>
> Kèm theo là một **cổng chạy ở mọi lượt** cho *loại* lỗi này, chứ không cho năm ca này:
> `scripts/check-doc-status.sh` (`docs/decisions.md` **ADR-032**) — **đỏ** trên bản trước khi sửa,
> **xanh** sau khi sửa. Nó phủ nhóm 1 và nhóm 3. Nó **không** phủ chỗ *"một câu tiếng Việt có hai
> cách đọc ra hai số tiền"* của nhóm 2: chỗ ấy chỉ lộ ra khi có người **cộng lại tiền** — tức khi
> Gate 6 chạy, đúng như nó đã lộ ra.

Ba scenario chạy hết, và **mọi bước đều trỏ được về một mục của §1–§7** — phần *luồng* không thiếu
chỗ nào. Cái hai lượt đọc **context sạch** (Gate 6, 2026-09-03) tìm ra không phải chỗ thiếu, mà là
**chỗ hai mục đã chốt nói lệch nhau**. Năm chỗ, chia làm ba nhóm:

**Nhóm 1 — F-015: bốn câu trong §1–§7 nói một luật ĐÃ CHỐT vẫn đang treo.**

| Chỗ | Câu đang có | Sự thật hôm nay |
|---|---|---|
| `01-actors-pham-vi.md` §1.2 | *"chưa rõ ai bấm xác nhận và vào lúc nào — **U-005**, chưa ai trả lời"* | **U-005 đóng 2026-08-31**: POS xác nhận **lúc nhận tiền**, người bấm là người đứng quầy (§3.2.5, §4.6) |
| `04-gia-thanh-toan.md` §4.9 | *"phần VietQR thì buổi tối quán lấy gì ra đối chiếu là câu **CHƯA CHỐT** — xem **U-019**"* | **U-019 đóng 2026-09-01**: **tin nhắn báo có** — và câu trả lời nằm ngay bảng đầu **cùng mục ấy** |
| `06-ngoai-le.md` §6.1 dòng 7 | *"Ranh giới trên còn mở: `Hoàn thành → Huỷ` **hôm nay bị từ chối** — **U-022**"* | **U-027 đóng 2026-09-02**: đường ấy **hợp lệ**, §5.2 đã có đúng dòng ấy, và **dòng 13 của chính bảng này** nói ngược lại |
| `06-ngoai-le.md` §6.2 | *"**không cần** đường `Hoàn thành → Huỷ`"* | Cùng lời chốt trên: đường ấy **có**; quầy **chọn** giữa sửa và huỷ theo từng ca |

Chỗ §1.2 là chỗ **thứ tư và mới**: F-015 mở ngày 2026-09-02 với ba chỗ, và câu `awk` đo lại của
chính nó **không** bắt được chỗ này. Chỗ §6.1 dòng 7 là chỗ đắt nhất — nó **dạy ngược một luật**,
nên một phiên System Design đọc nó sẽ dựng hàng rào chặn `Hoàn thành → Huỷ`, đúng thứ chủ quán vừa
nói là **được phép**.

**Nhóm 2 — F-022: ba chỗ hai mục đã chốt trả lời khác nhau cho cùng một câu hỏi.** Cả ba lộ ra
đúng vào lúc diễn scenario, và không lộ ra khi đọc từng mục một:

- **Phiên bàn mở lúc nào?** §3.1.1 bước 1 nói *"khách ngồi vào bàn trống ⇒ hệ thống mở phiên"*;
  §5.3 và §3.1.2 nói phiên mở **lúc lượt gọi đầu tiên được tạo**. Hai câu cho hai câu trả lời khác
  nhau về việc một bàn trống có được phép mang một phiên đang mở hay không. Scenario 1 bước 1 theo
  **§5.3**, vì hai trong ba mục nói thế. → **BA-03** (§3.1).
- **Ai bấm *"đã ra bàn"* cho một đơn giao tận nơi?** §5.4 ghi ***người đứng quầy*, trên POS**;
  nhưng lúc trao hàng người có mặt là ***nhân viên quán* đi giao**, và §5.2 giao đúng cho người ấy
  hai nút *đã giao* / *đã thu tiền*. §5.5 lại buộc mọi việc phải `Đã ra bàn` **trước** khi đơn
  `Hoàn thành`. Ba mục ghép lại thì mốc **lúc nào** rõ, còn **ai bấm** thì không. → **BA-07** (§5).
- **"Nâng giá một cái bánh nhân thường" là thao tác gì?** Ví dụ có số của §3.3.3 — và
  `quality/invariants.md` I-009 — viết đúng câu ấy, mà nó cho **hai** kết quả: đọc theo ô bảng
  `shop-facts.md` §4.2 ra **29.000**, đọc theo công thức §4.1 (*giá gốc chay + phụ thu*) ra
  **25.000**, vì phụ thu không đổi. Nó còn làm ô *Thịt thường* **bằng** ô *Thịt nhiều*, tức xoá
  bậc phụ thu +1.000 của §4.4. Đây là chỗ **chạm tiền**, trong ví dụ có số **duy nhất** của §3.3.
  → **BA-05** (§3.3) và câu *Verification* của **I-009**.

**Nhóm 3 — F-021: bảng tổng hợp `docs/decisions.md` nói ngược thân của chính nó.** Nó còn xếp
**GĐ-01** và **GĐ-05** là *Giả định* mức **TRUNG BÌNH** đang sống, trong khi thân hai mục ấy ghi
**Superseded** từ 2026-09-02 (T-045). Gặp khi tick mục 6 của cổng chất lượng. → **BA-10**.

**Việc sửa cả ba nhóm nằm ở một task mới: `work/backlog.md` → BA-13.** BA-11 **không tự sửa** —
§1–§7 và `docs/decisions.md` đều nằm trong mục *Không được sửa* của
`prompt/BA/10-acceptance-scenarios-L2.md`. Vì sao **một** task mới thay vì mở lại sáu task BA đã
xong: sáu task ấy **đúng vào ngày chúng chạy**; bốn chỗ của nhóm 1 hỏng về sau, do các lượt
**T-038 · T-042 · T-043 · T-045** đóng unknown mà không quét chỗ nhắc tới câu hỏi (đó là toàn bộ
nội dung F-015). Đẩy sáu dòng `Done` về `Ready` là ghi nợ vào tên lượt không gây ra nợ, và làm
mất luôn cái đắt nhất: **cả năm chỗ là MỘT loại lỗi và cần MỘT lượt quét**.

**Một chỗ KHÔNG phải lỗ hổng, ghi ra để không ai mở lại:** lượt đọc context sạch đầu tiên không
kiểm được tiền vì nó không có `master_plan/shop-facts.md`. Giá từng thành phần — kể cả giá **một
quả trứng** — **cố ý không** được chép vào §1–§8 (ADR-001, `work/findings.md` F-001); §4.3 có sẵn
giá bốn suất bán để **tra**, còn muốn **tái tạo** chúng thì phải mở §4.2. Lượt đọc thứ hai có
`shop-facts.md` và cộng ra **đúng toàn bộ** con số của cả ba scenario. Đó là thiết kế, không phải
chỗ thiếu.

### Bốn việc mục này cố ý không nói tới

- **Cách hệ thống thực hiện bất cứ bước nào ở trên.** Không có bước nào tả thao tác kỹ thuật, và
  đó là ràng buộc của chính giai đoạn BA (kế hoạch gốc §13).
- **Mẻ, và bảng con số ở quầy.** Thuộc §3.4 — BA-12 (`master_plan/shop-facts.md` §5.4).
- **Mảng quản trị (admin).** Ba scenario này chỉ diễn mảng **bán hàng**; ranh giới mảng admin ở
  `docs/product/0-ba/admin/01-ranh-gioi.md` và §7.6 (`docs/decisions.md` ADR-013, ADR-031).
- **Ai ký duyệt cổng chất lượng BA.** Chín mục ở trên nói **cổng đạt hay chưa**; **ai** nói câu
  *"được, sang System Design"* là quyền chủ repo và chủ quán, không phải việc của tài liệu này.
