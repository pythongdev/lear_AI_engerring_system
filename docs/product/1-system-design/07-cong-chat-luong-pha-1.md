<a id="top"></a>
# Cổng chất lượng pha 1 — ba scenario nghiệm thu diễn qua thiết kế, và mười ô sang pha 2

*Bước 11/14 của pha 1 — **P1-11**, chốt 2026-09-08
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · §9 · `docs/decisions.md` **ADR-033**).
Đầu vào: [`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8 (ba scenario) ·
sáu mục pha 1 do P1-02 → P1-10 sinh ra — [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) ·
[`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) ·
[`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) ·
[`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) ·
[`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) ·
[`06-so-rui-ro.md`](06-so-rui-ro.md) — cộng [`architecture.md`](architecture.md) §1.1 · §3.4 · §5 ·
§6.3 · §6.4 · §7 · §8 · `quality/invariants.md` · `master_plan/shop-facts.md` §4.2 · §4.3 · §4.4 ·
§4.5 · §6.10 · §6.11.*

> **Mục này sở hữu đúng hai thứ:** **biên bản lượt diễn** ba scenario nghiệm thu qua thiết kế pha
> 1 — mỗi bước ở quán trỏ vào cơ chế nào giữ cho nó đúng — và **trạng thái đã ký của mười ô cổng
> sang pha 2**, mỗi ô kèm bằng chứng.
>
> **Nó không sở hữu một bước scenario nào.** Ba scenario có nhà ở
> [`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8; cột đầu dưới đây chỉ đủ
> **nhận ra** bước, không chép lại lời của nó (`work/findings.md` **F-001**).
>
> **Nó không sở hữu một cơ chế nào.** Cột *Cơ chế pha 1 giữ nó* **trỏ** về mục đã viết ra cơ chế
> ấy. Gặp chỗ không trỏ được, lượt này **ghi** một `F-XXX` — nó **không** thiết kế bù, và đó là
> ràng buộc cứng của bước này (`work/backlog_SD.md` → P1-11).
>
> **Nó không sở hữu mười ô cổng.** Lời của mười ô là của kế hoạch pha 1 §9; §7 dưới đây chép
> **nguyên văn** hình dạng ấy và thêm **bằng chứng** — cùng cách
> [`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) ký cổng chất lượng BA từ
> nguyên văn `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §12.
>
> **Nó không sở hữu một dữ kiện quán nào.** Mọi con số tiền ở §5 **tra** `master_plan/shop-facts.md`
> §4.2 · §4.3 · §4.4 (**ADR-001**); không ô giá nào sống ở đây.
>
> **Ở đây không có tên bảng, tên cột, endpoint, route hay component** (**ADR-035**).
>
> **Vì sao mục này tồn tại.** `BA-11` diễn ba scenario qua tài liệu BA và tick cổng **6/9 kèm lý
> do cho ba ô còn lại**; hai lượt đọc *context sạch* của nó tìm ra **sáu** chỗ hai mục đã chốt nói
> lệch nhau — `work/findings.md` **F-022**, và một chỗ trong đó thành `U-031`. Không lượt diễn nào
> thì không chỗ nào trong sáu chỗ ấy lộ ra: `docs/decisions.md` **ADR-032** nói thẳng rằng không
> cổng máy nào bắt được loại lỗi ấy. Lượt này là lượt ấy, chạy trên thiết kế thay vì trên nghiệp vụ
> — và nó tìm ra **ba** chỗ (§6).

---

## 0. Cách đọc — ba cột, và bốn luật

| Cột | Nó trả lời câu gì |
|---|---|
| **#** | số bước, đúng số của bảng ở [`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8 |
| **Bước ở quán** | đủ để nhận ra bước — **không** phải bản chép của nó (**F-001**) |
| **Cơ chế pha 1 giữ nó** | **mã** (`I-0xx` · `PT-x` · `RB-x` · `RR-x` · `YC-XX`) **cộng** mục để đọc; hoặc chữ **KHÔNG TRỎ ĐƯỢC** kèm mã của chỗ đang thiếu |

Bốn luật khi đọc:

1. **Một ô chỉ được đọc là *đã có cơ chế* khi nó chỉ tên được một mã VÀ một mục đã viết ra.** Một
   câu *"chỗ này bảng bảo vệ có nói"* không phải một pointer, và một bước được giữ bởi *"quầy làm
   cẩn thận"* là một bước chưa có cơ chế.
2. **Trỏ được ≠ đã an toàn.** Bốn ô của bảng bảo vệ chỉ tới **tầng 4 hoặc 5** — máy **không ngăn**,
   nó chỉ nhắc, để vết và bắt sau ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1.2 luật 1). Bước nào
   đứng trên một ô như thế thì cột thứ ba nói thẳng ra.
3. **Chỗ dừng có tên khác chỗ không trỏ được.** `S-6` và vế tầng 4 của `I-004` là hai chỗ mà
   [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §2.2 · §2.3 **đã** gọi tên trước lượt này và
   dặn lượt diễn phải dừng ở đó; chúng **không** là phát hiện của lượt này. Ba chỗ ở §6 thì là.
4. **Lượt này không sửa một chữ nào của sáu mục pha 1 kia.** Gặp chỗ hụt ⇒ `F-XXX`. Sửa nhân tiện
   mục của bước khác là `work/findings.md` **F-010** · **F-014**.

---

## 1. Scenario 1 — khách QR tại bàn, ba lượt gọi, thu tiền một lần

Mười bảy bước. Đây là scenario đi qua **nhiều cơ chế nhất** của cả ba, vì nó chạm cả ba vòng đời
cùng lúc và chạm hai kênh bán.

| # | Bước ở quán | Cơ chế pha 1 giữ nó |
|:--:|---|---|
| 1 | Khách quét QR gọi lượt đầu ở bàn 5; phiên mở **lúc lượt gọi đầu tiên được tạo** | `I-001` **tầng 1** — ràng buộc *một bàn ≤ một phiên chưa thanh toán* phủ **cả** trạng thái chờ thanh toán ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §2) · `I-008` **tầng 3**, một cửa tạo lượt gọi xét **ba** điều kiện theo đúng thứ tự (§3) · mốc do **một** nguồn cấp **ở nơi ghi**, không lấy từ máy khách — `qr_table` là kênh khách tự bấm ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §3 câu 1) |
| 2 | Hệ thống tự tính tiền của lượt gọi; khách không khai giá | `I-013` **tầng 3, và tầng 3 là trần thật** — một chỗ tính giá, cả năm kênh đi qua nó, con số từ phía khách bị **bỏ** (§1) · `I-009` **tầng 3** mốc khoá giá là **từng lượt gọi** (§3) · `I-010` **tầng 3** kiểm tổ hợp **trước khi** tạo dòng (§3) · `RB-3` giá đọc thẳng ở nơi ghi, **không** bộ nhớ đệm ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §2) |
| 3 | Quầy duyệt lượt 1; trước lúc duyệt đơn **chưa sinh việc nào** ở cả năm trạm | `I-004` **vế một, tầng 1** — *tồn tại một việc trạm gắn với đơn đang Mới/Chờ xác nhận* phải không tồn tại được (§2) · `I-016` **tầng 3**, một hàm xác thực tra đúng bảng vòng đời của đơn (§2) |
| 4 | Nổ lượt 1 thành **sáu việc trên ba trạm**, ba trạm nhận cùng lúc | `I-004` **vế hai, tầng 2** — nổ đơn và ghi đơn sang *Đang thực hiện* trong **cùng một giao dịch** (§2) · `I-019` **tầng 1 + tầng 3** khoá gom *thành phần + loại nhân + lượng nhân* (§4) · đường **đẩy** ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1.1) và ràng buộc `RB-1` sinh ra từ chính nó (§2) · ⚠️ **một nửa KHÔNG trỏ được** — việc **nước chấm** là việc **cấp đơn**, không nhân theo suất, và phép đối chiếu của `I-004` chỉ đếm *suất × thành phần*: **`F-036`** |
| 5 | Bếp xong mẻ; quầy bấm *đã làm xong* rồi *đã ra bàn*; ba trạm bếp **không bấm gì** | `I-020` **vế trần trên, tầng 1** + **vế một mẻ phủ nhiều bàn, tầng 2** (§4) · màn trạm **chỉ đọc, không có nút nào** — **ADR-011**, [`architecture.md`](architecture.md) §1.1 · §5, dẫn lại ở [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1 · con số **thứ tư** của bảng quầy, *đã làm xong còn ở bếp*, đứng riêng ([`architecture.md`](architecture.md) §3.4) · **chỗ dừng đã có tên:** đơn vị **bấm** của mốc *đã ra bàn* là `S-5`, [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §6 nói thẳng *để trống, đừng điền* — scenario chỉ có **một** bàn nên hai cách đọc cho cùng kết quả |
| 6 | Cả sáu việc *đã ra bàn* ⇒ đơn lượt 1 sang *Hoàn thành* | `I-016` **tầng 3** (§2) · `I-020` **tầng 1** — *đã ra bàn* không vượt *đã gọi* (§4) |
| 7 | Lượt 2: quầy đặt hộ, đơn vào **thẳng** *Đã xác nhận* | `I-008` **tầng 3** — cửa tạo lượt gọi **không** chặn `staff_pos` ngay cả trong ca quán mất kết nối (§3) · `I-016` **tầng 3** đường ấy có dòng trong bảng vòng đời (§2) · `I-013` **tầng 3** (§1) |
| 8 | Lượt 2 vào **chính** phiên của bàn 5, không mở phiên thứ hai, không tạo đơn lẻ nào | `I-001` **tầng 1** (§2) · `I-002` **tầng 3** — **một cửa ghi** quyết định một lượt gọi thuộc đơn vị tính tiền nào (§1) · `I-006` **tầng 3** — hai kênh của khách ngồi bàn luôn gắn lượt gọi vào phiên đang mở của bàn đó (§2) |
| 9 | Lượt 2 nổ việc, bếp làm, quầy bấm hai mốc ⇒ *Hoàn thành* | Cùng bốn ô với bước 4 · 5 · 6: `I-004` **tầng 2**, `I-019` **tầng 1 + 3** (§2 · §4) · `I-020` **tầng 1 + 2** (§4) · `I-016` **tầng 3** (§2) — và cùng một nửa **KHÔNG TRỎ ĐƯỢC** ở việc nước chấm, **`F-036`** |
| 10 | Quầy tính tổng **cả** phiên; phiên sang *Chờ thanh toán*; **bàn 5 chưa trống** | `I-002` **tầng 1** *một phiên đúng một hoá đơn* + **tầng 3** *hoá đơn cộng lại từ các lượt gọi, không mang một con số tự đứng* (§1) · `I-003` **tầng 3** — bàn về *Trống* cần **hai** việc, và *Chờ thanh toán* không phải một trong hai (§2) |
| 11 | **Lượt 3 — gọi thêm SAU khi quầy đã bắt đầu thu tiền**; phiên quay về *Đang phục vụ* | `I-001` **tầng 1**, và đây là chỗ ràng buộc ấy **được viết riêng cho**: nếu nó chỉ tính trạng thái đang mở thì lúc quầy bấm thu tiền nó **nhả ra** và lượt gọi thêm rơi vào hoá đơn thứ hai (§2, câu trong ngoặc) · `I-002` phép đối chiếu tính **cả** lượt gọi sau khi quầy đã bắt đầu thu (§1) · `RR-1`…`RR-5` không chạm; rủi ro *thu thiếu 3.000đ mà không ai thấy* là **`I-002`**, ô có tầng 1 |
| 12 | Duyệt lượt 3, bếp làm, hai mốc — **bước này không được bỏ** | `I-017` **tầng 2** — thao tác đóng phiên đọc trạng thái **mọi** đơn của phiên và ghi *Đã đóng* trong **cùng một giao dịch** (§2) |
| 13 | Tính lại tổng của **cùng một** hoá đơn; không mở hoá đơn thứ hai | `I-002` **tầng 1** (§1) |
| 14 | Khách trả **hai phương thức**; quầy nhìn tiền, nhìn báo có, rồi bấm *đã nhận tiền*; POS ghi **số tiền từng phần** | `I-015` **tầng 1** *tổng khớp · từng phần mang đúng một phương thức* + **tầng 2** *các phần cùng sống hoặc cùng chết* + **tầng 4** cho vế *tiền đã thật sự vào tài khoản* — **máy không ngăn được**, mã VietQR của quán là mã **tĩnh**, `PT-3` ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2 · §3 + khung dưới bảng) · `I-012` **tầng 1** vết đủ bốn câu (§1) · mọi phần dùng **chung một** mốc tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2.1) · rủi ro đã có tên: `RR-1` ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1) |
| 15 | Đóng phiên → *Đã đóng*, **vì** mọi đơn đã *Hoàn thành* | `I-017` **tầng 2** (§2) · `I-005` không kích hoạt — thu đủ nên không sinh khoản nợ nào (§1) · mốc tính tiền của lần **bán** là mốc **đóng** đơn vị tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2) |
| 16 | Phiên đóng ⇒ bàn 5 sang *Bàn cần dọn*; người canh & dọn xác nhận đã dọn | `I-003` **tầng 3** — **một** cửa dẫn tới mỗi nửa điều kiện, và `I-016` khoá mọi cửa khác (§2) |
| 17 | Bàn 5 trở lại *Trống* — sau **hai** việc | `I-003` **tầng 3** (§2); giới hạn đã ghi sẵn: cơ chế giữ **trạng thái ghi nhận**, không giữ được việc bàn có **thực sự sạch** |

**Ba kết quả mong đợi của scenario này đều có một ô tầng 1 đứng sau.** *Một hoá đơn* ⇒ `I-002` ·
*một phiên cho bàn 5 trong cả scenario* ⇒ `I-001` · *lượt gọi thêm nằm trong chính hoá đơn ấy* ⇒
`I-001` phủ cả *Chờ thanh toán* + `I-002` cộng lại từ lượt gọi. Còn *sáu việc trên ba trạm* thì
chỉ đúng một nửa — nửa thiếu là **`F-036`**.

---

## 2. Scenario 2 — ba đơn mang đi, ba kênh, không đơn nào gắn phiên bàn

Mười bốn bước. Đây là scenario **dừng** ở hai chỗ, và cả hai đã có tên trước lượt này.

| # | Bước ở quán | Cơ chế pha 1 giữ nó |
|:--:|---|---|
| 1 | Đơn **A** — Delivery, khách khai **số điện thoại** và **địa chỉ giao**, hai trường **bắt buộc** | ⚠️ **KHÔNG TRỎ ĐƯỢC** — **`F-038`**. Pha 0 đã chốt *thiếu một trường bắt buộc thì đơn không tạo được* ([`../0-ba/ban-hang/03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.2.4), nhưng **không** mệnh đề `I-0xx` nào nói câu ấy, **không** ô nào của bảng bảo vệ giữ nó, và **không** dòng `YC-XX` nào đòi nó |
| 2 | Đơn **B** — Pickup, khai số điện thoại và **giờ hẹn lấy**; chọn **trả trước** | Vế *trả trước có một mốc tính tiền*: **`I-014`** ô nhắc `U-036` **đã đóng 2026-09-06** — mốc là **ngày giao/lấy hàng**, **ADR-040** ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 hàng cuối) · vế *giờ hẹn phải tới được quầy trước khi trễ*: `PT-5` đường suy giảm ghi rõ *trước giờ hẹn của đơn sớm nhất* ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §3) · ⚠️ vế **trường bắt buộc** — **`F-038`** |
| 3 | Đơn **C** — hotline, quầy **phải hỏi hai câu**; khách tới lấy ⇒ **không** cần địa chỉ | ⚠️ **KHÔNG TRỎ ĐƯỢC** — **`F-038`**: *mức tối thiểu đổi theo cách trao hàng* là đúng loại câu *phải không xảy ra được*, và pha 1 không có nhà cho nó |
| 4 | Tạo **ba đơn lẻ**, không đơn nào gắn phiên bàn; A · B vào *Chờ xác nhận*, **C vào thẳng** *Đã xác nhận* | `I-007` **tầng 1** — *một đơn của ba kênh không gắn bàn đang thuộc một phiên bàn* phải không tồn tại được (§1) · `I-006` dùng **chung** cơ chế ấy, hai nửa một ranh giới (§2) · `I-016` **tầng 3** cho đường vào thẳng (§2) |
| 5 | Duyệt **A** và **B**; **C không đi qua bước duyệt** | `I-004` **vế một, tầng 1** — đơn chưa duyệt không sinh việc nào; C đã *Đã xác nhận* nên nó **được** nổ việc (§2) · `I-013` §1.1 nhắc thẳng: bước duyệt chặn **đơn ảo**, nó **không** phải cơ chế giữ giá |
| 6 | Nhận **tiền trả trước của đơn B**, rồi **mới** bấm *đã nhận tiền* | `I-015` **tầng 4** cho vế tiền đã về — **máy không ngăn được** (§1 · §1.1) · `I-012` **tầng 1** vết (§1) · `PT-3` đường suy giảm: *không bấm đã thu khi chưa nhìn thấy tiền về* ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §3) · ⚠️ **một nửa KHÔNG TRỎ ĐƯỢC** — khoản trả trước nhận **ngày này** cho đơn **ngày khác** đã có **mốc tính tiền** nhưng **không** có dòng nào trong công thức đối soát để đứng: **`F-037`** |
| 7 | Nổ ba đơn thành việc từng trạm, **y hệt** đơn tại bàn; **mỗi đơn đúng một việc nước chấm**, gói riêng | `I-004` **vế hai, tầng 2** (§2) · `I-019` **tầng 1 + 3** khoá gom (§4) · ⚠️ **nửa *đúng một việc nước chấm cho mỗi đơn* KHÔNG TRỎ ĐƯỢC** — **`F-036`**, và ở đây nó **đắt hơn** Scenario 1: nước chấm của đơn mang đi phải **gói riêng**, thiếu nó thì khách phát hiện ở nhà |
| 8 | Bếp xong mẻ; quầy bấm *đã làm xong* cho việc của **cả ba** đơn; ba trạm bếp không bấm gì | `I-020` **vế một mẻ phủ nhiều bàn, tầng 2** — một lần bấm, phần của **mỗi** đơn ghi trong cùng một giao dịch, dùng lại chính khoá gom của `I-019` (§4) · **ADR-011** màn trạm chỉ đọc |
| 9 | **Đóng gói** từng đơn; không đơn nào có bước bưng ra bàn | `YC-07` — *một lần bấm là một mẻ, và mẻ đẩy nhiều việc của nhiều bàn cùng lúc* ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §1) · mốc *đã ra bàn* của đơn mang đi là lúc **trao**, không phải lúc đóng gói — pha 0 đã ghép §5.4 với §5.5; pha 1 giữ nó bằng `I-020` **tầng 1** (đã ra bàn ≤ đã gọi, §4) |
| 10 | Đơn **A** rời quán ⇒ *Đang giao*, để quầy biết **ai đang cầm tiền chưa về** | `I-016` **tầng 3** (§2) · `I-012` **tầng 3** — *đúng một cửa* có **hai ngoại lệ đã chốt**, và người đi giao bấm tại chỗ khách là một trong hai (§1 · §1.1) · `RR-6` là rủi ro của đúng chỗ ấy ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1) |
| 11 | Giao đơn A, **trao hàng**, **thu tiền tại chỗ khách**, bấm *đã giao* + *đã thu tiền* ⇒ *Hoàn thành* | `I-012` **tầng 3** ngoại lệ thứ nhất + **tầng 4** cho vế *cái tên trong vết là người thật* (§1) · `I-015` như bước 6 · **chỗ dừng đã có tên:** đơn chỉ *Hoàn thành* khi **mọi** việc trạm ở *đã ra bàn* (`I-017`, §2), quầy là người bấm mốc ấy — `U-031` **đã đóng 2026-09-04**, chủ quán trả lời *"pos"* — nhưng **lúc nào** quầy bấm thì vẫn là **`S-6`**, và [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §2.2 đã dặn lượt diễn phải dừng ở đúng đây |
| 12 | Đơn **B**: khách tới lấy, quầy trao hàng ⇒ *Hoàn thành*; tiền đã nhận ở bước 6 nên **không thu lại** | `I-017` **tầng 2** (§2) · `I-015` **tầng 1** *tổng các phần không vượt số phải trả* — thu lần nữa là trạng thái phải không tồn tại được (§1) · `I-014` **tầng 1** *một khoản tiền gắn hơn một đơn vị tính tiền* phải không tồn tại được (§1) |
| 13 | Đơn **C**: khách tới lấy, quầy trao hàng và **thu tiền tại quầy**; **không** đi qua *Đang giao* | `I-016` **tầng 3** (§2) · `I-015` · `I-012` **tầng 1** (§1) |
| 14 | Không đơn nào có bước dọn bàn; luồng dừng ở bước 13 | `I-003` không áp — nó ràng buộc **bàn**, và ba kênh này không gắn bàn nào (`I-007` **tầng 1**, §1 · §2) |

**Hai kết quả mong đợi đắt nhất của scenario này đều có ô tầng 1 đứng sau.** *Ba đơn vị thanh
toán, kể cả A và C cùng một khách* ⇒ `I-007` + `I-014` · *không đơn nào gắn phiên bàn* ⇒ `I-007`
dùng chung cơ chế với `I-006`. Còn *số việc nước chấm = 3* thì **không** — đó là **`F-036`**.

---

## 3. Scenario 3 — chủ quán đổi giá giữa buổi

Mười bước. Đây là scenario **hỏng âm thầm**: không thao tác sai, không gì nổ ra, chỉ có số tiền
của một bữa đã bán tự đổi sau lưng. Nó cũng là scenario duy nhất diễn **đúng** ca mà
[`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §3.2 dặn phải diễn.

| # | Bước ở quán | Cơ chế pha 1 giữ nó |
|:--:|---|---|
| 1 | 8:00 — bàn 3 gọi một suất; dòng ấy **khoá giá ngay lúc lượt gọi được tạo** | `I-009` **tầng 3** cho vế mốc khoá — mốc là **từng lượt gọi**, **ADR-023**, **không** phải lúc mở hay đóng phiên (§3) · `I-013` **tầng 3** (§1) |
| 2 | 8:30 — chủ quán nâng **giá gốc một thành phần**; hai mức phụ thu **không đổi** | `I-011` **tầng 4** *không* áp cho chiều này — §3 nói thẳng: ba chiều đổi **giá** đổi được bất kỳ lúc nào, **không nhắc gì cả**; bắt nhầm luật lời nhắc sang chiều tiền là chỗ dễ sai đã ghi sẵn (§3, câu cuối ô `I-011`) · `I-018` **tầng 1 + tầng 2** — lần lưu giữ đủ bốn thứ trong **cùng một giao dịch** (§3) · `I-012` **tầng 3** ngoại lệ thứ hai: **chủ quán** bấm trên mặt quản trị (§1 · §1.1) |
| 3 | Lưu. **Có hiệu lực ngay, giữa giờ bán cũng được** | `I-009` **tầng 3** — mốc khoá theo lượt gọi làm việc này **an toàn**, không cần lịch hẹn giờ (§3) |
| 4 | Menu khách nhìn thấy đổi theo ở **cả năm kênh** | `RB-3` — **không** bộ nhớ đệm, menu và giá đọc thẳng ở nơi ghi, và ô này ghi đúng lý do: *một bản cũ sống thêm vài giây là một hoá đơn tính bằng cái giá chủ quán vừa đổi* ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §2, cộng luật 3: được đệm thứ để **nhìn**, **giá thì không**) |
| 5 | 9:00 — bàn 3 gọi thêm **đúng một suất cùng loại**; dòng mới khoá **giá mới** | `I-009` **tầng 3** (§3) · `I-013` **tầng 3** (§1) |
| 6 | Quầy mở lại đơn lúc 8:00 để đối chiếu ⇒ vẫn giá cũ, vẫn đúng số bánh bếp đã làm | `I-009` **tầng 1** cho vế **lưu bản sao** — một dòng đơn đọc theo bảng giá/menu **hiện hành** thay vì theo bản đã khoá phải không tồn tại được (§3) · `YC-13` vết của một lần cập nhật ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §3) |
| 7 | Đóng phiên bàn 3: **một** hoá đơn mang **hai** mức giá cho cùng một món — và đó là kết quả **đúng** | `I-002` **tầng 1** một phiên một hoá đơn (§1) · `I-009` phép đối chiếu nói **ngược** điều người ta hay chặn: *mọi phiên vắt qua một lần đổi giá mà **chỉ** mang một mức giá* mới là tập lệch; hai mức giá **không** phải điều kiện lệch (§3 · §3.1) |
| 8 | 10:00 — **ngừng bán** suất giò ⇒ không kênh nào đặt mới được, nhưng đơn 8:00 vẫn đúng tên và đúng giá | Nửa *đơn cũ đứng yên* ⇒ `I-009` **tầng 1** (§3). ⚠️ Nửa *không kênh nào đặt mới được món đã ngừng bán* — **KHÔNG TRỎ ĐƯỢC**, **`F-036`**: chính `quality/invariants.md` `I-009` liệt *ngừng bán hẳn món đó* trong bốn chiều và có một kịch bản phủ cho nó, nhưng ô `I-009` của bảng bảo vệ chỉ giữ nửa *đơn cũ*; `I-010` giữ **tổ hợp tuỳ chọn**, không giữ *món còn bán hay không* |
| 9 | Chủ quán sửa **thành phần** một suất giữa buổi — luật là *chờ hết buổi*, nhưng máy **nhắc rồi vẫn cho lưu** | `I-011` **tầng 4 — máy không ngăn được**, và đây là **ca mẫu của cả bảng** (§3 · §3.1). Cái máy **có** giữ: **lời nhắc** (tầng 3, một cửa sửa luôn hỏi trước khi ghi thay đổi rơi vào giờ bán) và **cái vết** (tầng 1 + 2, `I-018`) · rủi ro đã có tên và **cố ý chấp nhận**: [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §3.2 hàng P1-10 |
| 10 | Mở lại đơn combo của Scenario 1 sau khi thành phần đã đổi ⇒ vẫn đúng tiền và **vẫn đúng số bánh** | `I-009` **tầng 1** — bản sao gồm cả **thành phần**, không riêng giá (§3); đây là chiều thứ tư, chiều mà `quality/invariants.md` gọi là *đắt nhất và dễ quên nhất* |

**Ca *"sai thì sai thế nào"* đắt nhất của scenario này — tính lại cả phiên theo giá mới lúc thanh
toán — có đúng một ô chặn:** `I-009` **tầng 1** cho bản sao đã khoá, và phép đối chiếu của nó bắt
được cả chiều ngược. Ca *dựng hàng rào chặn chủ quán sửa thành phần* thì bị **`I-011`** chặn từ
phía ngược lại: ghi hàng ấy là tầng 1 cho đẹp bảng là **nói dối pha 2** (§3.1).

---

## 4. Lượt diễn thứ tư — một buổi mất kết nối

[`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §5 đặt điều kiện này thẳng cho bước hiện
tại: *ba scenario phải đi qua được **PT-1** và **PT-6**, tức đi qua được một buổi mất điện*. Ba
scenario ở §8 pha 0 **không** có bước nào mất kết nối, nên lượt này diễn thêm **một** lát: quán
đang giữa Scenario 1 thì **PT-1** chết.

| # | Bước ở quán | Cơ chế pha 1 giữ nó |
|:--:|---|---|
| 1 | Quán mất điện/mất mạng giữa buổi; **hệ thống vẫn sống** ⇒ quán mù, khách web **không** mù | `PT-1` §2 · đường suy giảm đủ ba vế ở §3 ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md)) · `RR-8` ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1) |
| 2 | **Ba kênh khách tự bấm dừng**; hai kênh người của quán nhập **không** dừng | `I-008` **điều kiện thứ ba, tầng 3** — và nó là điều kiện **duy nhất không ai bấm được** ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §3 · §3.1) · bốn câu luật *ai phán quyết và dựa vào đường nào* ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §3) · **chỗ để trống có tên:** `U-043` **đã đóng 2026-09-16** — không có độ dài cửa sổ nào, máy báo và **POS quyết** (**ADR-047**); chỗ trống nay là ca quán **mất mạng hẳn**, `U-053`, câu của **chủ quán** (§4) |
| 3 | Khách đặt qua **hotline**; quán **ghi giấy trực tiếp với POS** | `PT-6` — sổ giấy là quy trình của **người** (§2), đường suy giảm §3 · `RB-4` chỉ đứng được **vì** có đường bán không đi qua máy ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §2) |
| 4 | Màn trạm mất đường đẩy nhưng **vẫn đúng, chỉ trễ hơn** — và **rỗng thì nói được vì sao nó rỗng** | đường **kéo** tự chạy, ba luật, và nó **không** phải một cái nút — **ADR-011**, màn trạm không có nút nào ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1.2) · luật *màn chỉ đọc phải cho biết nó vừa lấy lại lúc nào* (§1.3) · `RR-7` là rủi ro của đúng chỗ này và cột *Cơ chế chặn* của nó trỏ về §1.3 ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1) · `RB-1` là ràng buộc sinh ra từ tính chất của đường đẩy (§2) |
| 5 | Có điện lại ⇒ bán tiếp **ngay** trên hệ thống; phần ghi tay **nhập bù sau** | `PT-1` cột *bù lúc nào* §3 · mốc tính tiền của lượt nhập bù là **mốc quán bán thật** ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 · §3, ca **duy nhất** một mốc vào hệ thống mà **không** do hệ thống cấp) · `YC-08` ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §1) |
| 6 | Tối đối soát: bảng phải đọc được ***"còn N lượt bán trên giấy chưa nhập"*** | `PT-6` §3 · `I-014` phép đối chiếu — ngày còn lượt chưa nhập đọc là **chưa đối soát xong**, **không** đọc là **lệch**, **ADR-037** ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1 · §1.2) · `RR-5` là rủi ro của chính chỗ ấy ([`06-so-rui-ro.md`](06-so-rui-ro.md) §1 · §1.2 luật 2) · ai chấm lại con số: `U-037` **đã đóng 2026-09-06** — POS hoặc chủ quán, cuối buổi bán hàng |
| 7 | Ngày mất điện đọc lại về sau vẫn bằng chính nó | `I-014` phép đối chiếu, hàng cuối: *mọi ngày đã qua mà con số dựng lại hôm nay khác con số đã đối soát hôm ấy*, **trừ** đúng ca nhập bù (**ADR-037**) |

**Lát này đi hết, không chỗ nào dừng** — sáu trong bảy bước trỏ được vào **hai** mục khác nhau, và
chỗ để trống duy nhất là câu của **chủ quán**, có tên và có người trả lời, không phải một chỗ pha 1
phải đoán. *Viết 2026-09-08 khi câu ấy là `U-043` (độ dài cửa sổ); `U-043` đóng **2026-09-16** —
không có con số nào, máy báo và POS quyết — và cùng lời đáp mở `U-053` (ai dừng khi quán mất mạng
hẳn), nên chỗ trống đổi mã chứ không mất.*

---

## 5. Tiền — cộng lại từ `master_plan/shop-facts.md`, không đọc con số của scenario

Đây là phép duy nhất bắt được loại lỗi **F-022** (*một câu tiếng Việt cho hai số tiền*), và nó chỉ
chạy được khi mở `master_plan/shop-facts.md` §4.2 · §4.3 · §4.4 cùng lúc — §8 pha 0 **cố ý** không
giữ một ô giá nào (**ADR-001**).

| Scenario | Dòng | Cộng từ §4.2 · §4.4 | Ra |
|---|---|---|---|
| **1** | 2 combo "Đầy đủ" trứng tái, thịt + mộc nhĩ, **nhiều nhân** | (3 bánh chay + 1 trứng chay + 1 giò) = 26.000 · **bốn** phần nhận nhân ⇒ +4.000 nhân +4.000 lượng = 34.000 · ×2 | **68.000** |
| **1** | 1 suất giò, thịt, thường | (1 giò + 4 bánh chay) = 21.000 · **bốn** phần nhận nhân ⇒ +4.000 | **25.000** |
| **1** | 1 suất bánh cuốn **chay** | 1 bánh chay, không phụ thu | **3.000** |
| **1** | **tổng hoá đơn** | 68.000 + 25.000 + 3.000 | **96.000** |
| **1** | hai phương thức | tiền mặt + chuyển khoản, cộng lại đúng số phải trả | **96.000** |
| **2** | đơn A — 2 suất trứng tái, thịt, thường | (1 trứng chay + 4 bánh chay) = 20.000 · **năm** phần nhận nhân ⇒ +5.000 = 25.000 · ×2 | **50.000** |
| **2** | đơn B — 1 combo "Đầy đủ" trứng chín, thịt, thường | 26.000 + 4×1.000 | **30.000** |
| **2** | đơn C — 3 suất bánh cuốn, thịt, **nhiều nhân** | (3.000 + 1.000 + 1.000) × 3 | **15.000** |
| **2** | **tổng ba đơn** | 50.000 + 30.000 + 15.000 | **95.000** |
| **3** | dòng 8:00 — suất giò, thịt, thường | 9.000 + 4 × 4.000 | **25.000** |
| **3** | dòng 9:00 — **cùng món**, sau khi giá gốc bánh chay lên 4.000 | 9.000 + 4 × 5.000 | **29.000** |
| **3** | **tổng hoá đơn bàn 3** | 25.000 + 29.000 | **54.000** |
| **3** | ca **sai** — tính lại cả phiên theo giá mới | 29.000 × 2 = 58.000 ⇒ lệch | **4.000** |

**Cả mười ba dòng khớp từng đồng với §8 pha 0**, và ba ô của bảng §4.3 (`21.000` · `25.000` ·
`26.000`) tái tạo đúng từ §4.2 + §4.5. Ba con số phụ thu **×1 · ×4 · ×5** là chỗ dễ sai nhất và cả
ba ra đúng: suất trứng là **×5** vì quả trứng cũng nhận nhân, suất giò là **×4** vì giò **không**
nhận nhân. Không chỗ nào phải mở một `F-XXX`.

**Một câu về vì sao phép này thuộc pha 1, không thuộc pha 0:** `I-013` nói *giá do hệ thống tính
lại*, và nó là **tầng 3** — trần thật. Không ràng buộc nào của cơ sở dữ liệu đọc được một con số
**đến từ đâu**, nên phép kiểm duy nhất còn lại là **cộng tay từ nhà thật rồi so**, đúng dòng cuối
của phép đối chiếu ô `I-013`: *mọi kênh trong năm kênh không có ít nhất một lượt kiểm ra đúng giá
kỳ vọng*.

---

## 6. Ba chỗ KHÔNG trỏ được — biên bản của lượt diễn

Ba chỗ dưới đây là **phát hiện của lượt này**. Không chỗ nào được lấp ở đây: lượt này **ghi**, và
việc thiết kế bù thuộc bước hoặc phiên nhận `F-XXX` tương ứng (`work/backlog_SD.md` → P1-11, mục
*Nói một câu, việc phải làm là gì*).

| Mã | Chỗ hụt | Lộ ra ở bước nào | Nó đắt ở chỗ nào |
|---|---|---|---|
| **`F-036`** | Một **vế** của một mệnh đề có mặt đủ ở `quality/invariants.md` nhưng **không** có tầng lẫn phép đối chiếu ở bảng bảo vệ — hai ca: `I-004` vế *mọi đơn có đúng một việc trạm `canh`, nước chấm là việc **cấp đơn*** · `I-009` vế *món đã **ngừng bán** thì không kênh nào đặt mới được* | S1 bước 4 · 9 · S2 bước 7 · S3 bước 8 | **Ô cổng thứ nhất vẫn tick xanh**: nó đối chiếu **danh sách mã**, và cả hai mã đều có hàng. Một phép đối chiếu hẹp hơn mệnh đề nó nhận giữ thì đọc ra **rỗng** trong khi trạng thái thật đã sai — cùng hình với `work/findings.md` **F-012** (một danh sách bị cắt trông y hệt một danh sách đủ) |
| **`F-037`** | Khoản **trả trước** nhận ngày này cho một đơn của ngày khác **có** mốc tính tiền (**ADR-040**) nhưng **không** có dòng nào trong công thức đối soát để đứng — chính [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §4 đã giao dòng ấy cho *"bước đọc mục này (P1-04 trở đi)"*, và không bước nào nhận | S2 bước 6 | Tiền đã vào két/tài khoản **hôm nay**, doanh thu thuộc **hôm khác** ⇒ phép trừ của `I-021` và phép so *phần chuyển khoản với tin nhắn báo có* của `I-015` **cùng** lệch, ở **hai** ngày, ngược chiều nhau — đúng hình của nợ nhưng không có hai dòng nợ để giải thích. Ngưỡng là **0đ**, nên đây là đường trực tiếp tới `RR-5` (*ngưỡng lệch bị bào mòn*) |
| **`F-038`** | **Mức tối thiểu của một đơn theo kênh và theo cách trao hàng** — pha 0 chốt *thiếu một trường bắt buộc thì đơn không tạo được* — không có mệnh đề `I-0xx` nào, không ô nào của bảng bảo vệ, không dòng `YC-XX` nào | S2 bước 1 · 2 · 3 | Ba trong năm kênh là kênh **khách tự bấm**. Một đơn giao tận nơi tồn tại mà thiếu địa chỉ là một đơn **không giao được**, và nó lộ ra lúc người đi giao đã cầm hàng ra khỏi quán — muộn nhất trong mọi chỗ lộ |

**Hai chỗ dừng KHÔNG phải phát hiện của lượt này**, ghi ra để không ai đếm chúng thành năm:

- **`S-6`** — với đơn **giao tận nơi**, quầy bấm mốc *đã ra bàn* **lúc nào**. Vế **ai** đã chốt
  2026-09-04 (`U-031`, *"pos"*). Chỗ *suy ra* ở `master_plan/shop-facts.md` §7.2;
  [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §2.2 đã gọi tên nó là chỗ lượt diễn phải dừng,
  và §2.3 nhắc lại. Lộ ra ở S2 bước 11, đúng như đã báo trước.
- **`I-004` vế tầng 4** — chỗ đã làm xong của một đơn **huỷ** chuyển sang bàn khác, **POS chọn bàn
  nhận**. Ba scenario không có bước huỷ nào nên lát này không diễn tới; ca **không có bàn nào đang
  chờ đúng thứ đã làm** thì *chưa có luật, chưa hỏi*
  ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §6).

**Một chỗ ba scenario đã CŨ hơn nhà thật đúng một ngày, và lượt này không sửa scenario:** cùng
ngày lượt diễn này chạy, một phiên song song đóng `U-046` — chủ quán chốt **canh bánh cuốn** là một
**dòng menu 0đ khách chọn số lượng**, nên `master_plan/shop-facts.md` §5.3 nay cho trạm `canh`
**hai** loại việc trên cùng một đơn: **nước chấm** (cấp đơn, không số lượng) và **canh** (số lượng
riêng, khách gọi, **không** suy ra từ số suất). Bảng bước 4 của Scenario 1 ở
[`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8 liệt **sáu** việc và không
có dòng canh — nó viết trước lời chốt ấy. Lượt này **không** thêm bước vào scenario (ba scenario là
**đầu vào**, §8 dưới đây) và **không** sửa `shop-facts.md`; nó ghi chỗ ấy vào **`F-036`**, nơi vế
*canh* lúc ấy **chờ `U-048`** (*mỗi suất kèm sẵn mấy bát, và con số khách chọn là tổng hay là phần
thêm*). **`U-048` đóng cùng ngày, lượt sau** (T-072): **không** suất nào bưng kèm canh, con số
khách chọn là **tổng** số bát — nên một đơn khách không chọn canh thì **đúng** là không có dòng canh
nào, và bảng sáu việc của Scenario 1 chỉ cũ ở chỗ nó không cho thấy dòng canh **khi** khách có
chọn. Đọc `F-036` trước khi tin bảng §1 là ảnh chụp của hôm nay.

**Một chỗ đọc được là *đã đủ*, ghi ra vì nó dễ bị mở lại:** mốc tính tiền của một lần **bán** là
mốc **đóng** đơn vị tính tiền, còn tiền vào két ở mốc **thu** — hai mốc khác nhau trong cùng một
phiên. Chúng không bao giờ rơi vào hai **ngày bán** khác nhau, và lý do đã viết ra ở
[`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §1.1 lý do 1: *không phiên bàn, không lần
thu, không lượt đối soát nào bắc qua 00:00*. Đó là một điều kiện **có tên và có cảnh báo** — cùng
mục đã dặn phải hỏi lại chủ quán nếu quán mở **buổi thứ hai**. Nên đây không phải chỗ hụt hôm nay,
mà là chỗ hết đúng cùng ngày quán đổi giờ bán.

---

## 7. Cổng chất lượng pha 1 — mười ô

Mười ô dưới đây là **nguyên văn** cổng ở `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §9;
chỗ ký thì ở đây, không ở kế hoạch — kế hoạch **không sở hữu sự thật nào**, đúng cách cổng chất
lượng BA được ký ở [`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) chứ không
ở `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §12.

**Hôm nay 9/10, và cả chín ô đều tick KÈM LÝ DO, không ô nào tick trơn.** Ô thứ mười để trống có
chủ ý. Một cổng 10/10 bằng cảm giác thì không chặn được gì (kế hoạch §9, bài học của `BA-11`).

**Ô 10 đổi lý do ngày 2026-09-16, không đổi trạng thái** (**P1-12**). Nó từng để trống vì *chưa ai
đo*; nay nó để trống vì **đã đo và câu trả lời là không** — ba chỗ ở [`architecture.md`](architecture.md)
mang thứ pha 2/3 sở hữu, và chỉ một trong ba có tên trong một ngoại lệ (`work/findings.md`
**`F-040`**, cộng **`F-041`** cho cái cổng lẽ ra phải bắt chúng). Phép đo đầy đủ ở chính ô 10.
**Cổng vẫn 9/10**, và pha 1 vì thế **chưa đóng**.

- [x] **1. Mọi `I-0xx` của `quality/invariants.md` đều có tầng bảo vệ và phép đối chiếu.**
  Đối chiếu **danh sách mã** giữa hai file (không đếm số lượng — **F-026** · **F-018**):
  `comm -3` giữa mã của `quality/invariants.md` và mã của
  [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) ra **rỗng** — không mã nào vắng, không mã nào
  thừa; không ô nào trống; mỗi tầng là một trong năm giá trị kế hoạch §7.
  ⚠️ **Tick KÈM một câu, và câu này là lý do `F-036` tồn tại:** ô này chấm **mã**, không chấm
  **vế**. Hai mệnh đề có hàng đầy đủ mà vẫn thiếu hẳn một vế (`I-004` việc cấp đơn `canh`,
  `I-009` vế ngừng bán) — xem §6. Đừng đọc ô xanh này thành *mọi vế đã có tầng*.
- [x] **2. Mỗi mệnh đề chỉ được giữ ở tầng 4 hoặc 5 đã nói thẳng ra điều đó.**
  Lọc chữ *"máy không ngăn được"* trên [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md): **11**
  lần, và đối chiếu từng hàng có chữ *tầng 4* / *tầng 5* — `I-004` · `I-011` · `I-012` · `I-014` ·
  `I-015` · `I-020` · `I-021` đều **có** câu ấy trong đúng hàng của mình.
  **Một hàng có tầng 4 mà KHÔNG có câu ấy, và nó đúng như thế:** `I-009` — vế tầng 4 của nó là
  **một ngoại lệ đã chốt** (quầy **sửa** một dòng thì mốc khoá của dòng đó đặt lại, `U-026` đã
  đóng 2026-09-02), còn mệnh đề thì được giữ ở **tầng 1 + tầng 3**. Luật của ô này là *ô nào **chỉ
  tới được** tầng 4/5*, và `I-009` không phải ô như thế (§0 luật 3 của mục ấy).
- [x] **3. Định nghĩa ngày bán có đúng một chỗ, và ba phép cộng tiền trỏ về nó.**
  `grep` cả `docs/product/`, `quality/` và `master_plan/shop-facts.md` cho câu định nghĩa: ra
  **đúng một** dòng, ở [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §1. Bảng §2 của
  chính mục ấy có **năm** hàng — bán · hoàn · thu nợ · nhập bù · trả trước — và cả năm trỏ về
  cùng một định nghĩa ở §1, không hàng nào định nghĩa lại.
  ⚠️ **Tick KÈM `F-037`:** hàng *trả trước* có **mốc tính tiền**, nhưng dòng công thức đối soát mà
  §4 của cùng mục ấy giao cho *"P1-04 trở đi"* thì chưa ai viết. Ô này hỏi *ngày bán có một chỗ và
  các phép cộng có trỏ về nó*, và câu trả lời là **có**; chỗ hụt nằm ở **bảng đối soát**, không ở
  định nghĩa.
- [x] **4. Mỗi phụ thuộc ngoài có một đường suy giảm.**
  Đếm hai bảng của [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md): §2 có **6** hàng
  `PT-1`…`PT-6`, §3 có **6** hàng, cùng bộ mã, không mã nào lệch. Mỗi hàng §3 đủ **ba vế** — quán
  làm gì · ai bù · bù lúc nào.
  ⚠️ **Tick KÈM cách đọc bảng ấy:** sáu dòng **không cùng một loại** — ba dòng là **lời chốt**, một
  dòng chốt một nửa (`PT-2`), **hai** dòng là **suy ra** (`PT-4` · `PT-5`), và chính mục ấy đã ghi
  hai câu để đi hỏi chủ quán. Sáu ô có mặt là đủ cho ô cổng này; hai dòng *suy ra* thì **không**
  được đọc như lời chốt.
- [x] **5. Bốn ràng buộc kiến trúc ẩn có dấu hiệu đo được.**
  Lọc *"khi cần"* và *"nếu chậm"* trên
  [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md): **rỗng**. Lệnh **chưa** lọc trên cùng
  file trả về **179** dòng, nên bộ lọc không tự rỗng (**F-017**). Bốn hàng `RB-1`…`RB-4` có mặt,
  mỗi hàng một dấu hiệu **đo bằng thứ đã có**: nhật ký khởi động · nửa giây chờ ở máy quầy · số
  dòng suất bán ở màn quản trị menu · dòng *còn N lượt bán trên giấy chưa nhập*.
  ⚠️ **Tick KÈM luật đắt nhất của bảng ấy:** dấu hiệu bật thì việc phải làm là **mở lại quyết
  định**, không phải **bỏ ràng buộc** — với `RB-1`, thêm một tiến trình thứ hai **trước** khi có
  chỗ chung giữ *"màn nào đang nối"* chính là dựng ra cái hỏng mà `RB-1` sinh ra để chặn.
- [x] **6. Mọi rủi ro của sổ rủi ro có cơ chế chặn đã tồn tại ở một mục pha 1.**
  Đọc **từng dòng** `RR-x` của [`06-so-rui-ro.md`](06-so-rui-ro.md) §1 (không đếm số lượng —
  **F-026** · **F-018**): **`RR-1`…`RR-8`** mỗi dòng trỏ được tới ít nhất một mục pha 1 cụ thể;
  lọc *"cẩn thận hơn" · "chú ý hơn" · "nhớ kiểm tra"* **trên các dòng rủi ro** ra **rỗng**.
  ⚠️ **Ô này tick KÈM LÝ DO, không tick trơn** — đúng như §2 của sổ rủi ro đã báo trước: **`RR-9`**
  (*mất hẳn bản ghi đã ghi*) là dòng **⛔ chưa có cơ chế**, mã `work/findings.md` **F-034**, và
  chọn nhà cho nó là quyết định của **chủ repo**. Bốn dòng nữa — `RR-1` · `RR-3` vế vết · `RR-4` ·
  `RR-6` — có cơ chế cao nhất là **tầng 4/5**: máy **không ngăn**, nó nhắc, để vết và bắt sau.
- [x] **7. Ba scenario BA đi hết được qua thiết kế — mỗi bước trỏ được một cơ chế.**
  §1 · §2 · §3 ở trên: **17 + 14 + 10 = 41 bước**, cộng **7** bước của lát mất kết nối (§4). Mỗi
  bước có một ô *Cơ chế pha 1 giữ nó* không trống, và tiền của cả ba scenario **cộng lại được từ
  `master_plan/shop-facts.md`**, khớp từng đồng (§5).
  ⚠️ **Tick KÈM ba mã, và đây là ô đắt nhất của cả cổng:** **năm** bước không trỏ được hết — S2
  bước 1 · 2 · 3 (**`F-038`**) · S1 bước 4 · 9 và S2 bước 7 và S3 bước 8 (**`F-036`**) · S2 bước 6
  (**`F-037`**). Ô này tick **vì** ba chỗ ấy được **ghi ra, có mã, có owner và brief in ra được** —
  đó là điều ngược lại với một chỗ hụt không ai biết, đúng cách ô số 7 của cổng BA được tick kèm
  `U-031`. **Nó không tick vì thiết kế đã đủ.**
- [x] **8. Trục sản xuất theo mẻ đã có mục nghiệp vụ (BA-12) và §3 đã viết lại (P1-09).**
  `BA-12` `Done` 2026-09-04 — [`../0-ba/ban-hang/03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md)
  §3.4; `P1-09` `Done` 2026-09-07 — [`architecture.md`](architecture.md) §3.4 có **bốn** con số và
  §11 hết giao việc cho một task đã `Done` (**F-024** đóng). Trục ấy cũng đã có **hai** mệnh đề và
  một nhóm riêng: [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §4 (`I-019` · `I-020`, P1-13,
  **ADR-042**).
  ⚠️ **Tick KÈM `S-5`:** đơn vị **bấm** của mốc *đã bưng ra bàn* vẫn để trống có chủ ý
  ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §6) — chưa ai hỏi chủ quán. Ô này hỏi *mục
  nghiệp vụ và §3 đã có chưa*, không hỏi *mọi câu của trục ấy đã có lời chưa*.
- [x] **9. Không câu hỏi nghiệp vụ nào đang mở mà một bước pha 1 phải đoán thay.**
  **Phép chấm, không phải danh sách:** mở `./scripts/brief.sh` mục *OPEN UNKNOWNS* — **danh sách
  sống ở đó**, không ở đây — rồi hỏi từng câu **một** câu: *có mục nào trong bảy mục pha 1 phải
  đoán thay câu này để viết được một dòng của mình?* Ô này tick khi câu trả lời là **không** cho
  mọi câu đang mở.
  **Trả lời tại mốc ký, 2026-09-08, sáu câu** *(cả sáu nay **đã có lời chủ quán**: `U-043` và
  `U-042` đóng **2026-09-16**, `U-044` · `U-045` · `U-048` · `U-049` đóng trước đó — mốc ký vẫn
  đứng nguyên, phần dưới đây là phép đo của ngày 2026-09-08, không phải trạng thái hôm nay)**:**
  **`U-043`** (độ dài cửa sổ mất kết nối) — kế hoạch
  §8 ghi *pha 3, không chặn bước nào của pha 1*, và
  [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §3 · §4 đã chốt được *ai phán quyết*
  và *dựa vào đường nào* mà không cần con số · **`U-044`** (hoàn tiền cho khoản đã chuyển khoản) —
  §8 ghi *không chặn bước nào của pha 1*, và [`06-so-rui-ro.md`](06-so-rui-ro.md) §1.3 đã ghi sẵn
  hậu quả nếu lời chốt đi đường *tiền mặt* (**câu này đã có lời ngay trong ngày 2026-09-08**: tuỳ
  ca, POS quyết — hậu quả ấy đã xảy ra và `I-021` được viết lại, **ADR-046**; ô vẫn tick vì không
  bước nào phải đoán thay) · **`U-042`** (đánh số bốn bàn mới) · **`U-045`** (máy
  biết một nguyên liệu đang thiếu bằng cách nào) · **`U-048`** (mỗi suất kèm sẵn mấy bát canh) ·
  **`U-049`** (người đi giao là một trong bốn vai hay người thứ năm) — bốn câu ấy thuộc **mảng
  admin** và **dữ kiện quán**; không mục nào trong bảy mục pha 1 dựa vào số bàn, danh mục nguyên
  liệu, số bát canh hay con số nhân sự để viết một tầng bảo vệ, và `U-049` **tự khai** *"chưa
  chặn"* vì hai nút của §6.7 không hỏi người bấm là ai.
  ⚠️ **Tick KÈM ba câu.** (1) Bốn mã sau **không** có hàng ở kế hoạch §8, và đó là **đúng**: bảng
  ấy tên là *Chỗ đang chặn*, còn bốn câu ấy không chặn gì của pha 1 — nên *đối chiếu với §8* phải
  đọc là *mọi câu đang mở mà §8 vắng phải giải thích được vì sao nó vắng*, không phải *§8 phải liệt
  đủ mọi câu đang mở*. (2) Hàng **`S-5`** của §8 còn ghi *Chặn bước: P1-07 · P1-09* trong khi cả
  hai bước ấy đã `Done` — ô của kế hoạch, cùng hình với `work/findings.md` **F-033**; ghi lại, và
  lượt này **không sửa hộ** (tiền lệ **F-032**). (3) **Danh sách sáu mã trên đã đổi HAI lần trong
  chính lượt ký này**: `U-046` · `U-047` đóng và `U-048` · `U-049` mở, do hai phiên song song, giữa
  lúc mục này đang được viết. Nên **đừng đọc sáu mã ấy như danh sách hôm nay** — chúng là **ảnh
  chụp tại mốc ký**, giữ lại để đọc được *phép chấm đã chạy trên cái gì*. Một danh sách mã chép tay
  trong một tài liệu đã ký là bản sao thứ hai và nó sẽ trôi (**F-001**, và đúng hình **F-033** mà ô
  trên vừa ghi lại). Danh sách sống: `./scripts/brief.sh`.
- [ ] **10. Không tên bảng · cột · endpoint · route · component nào lọt vào file pha 1.**
  **⛔ Để trống — chỗ chặn: `F-040`.** Ô này **đã được đo** 2026-09-16 (**P1-12**), và câu trả lời
  là **không**: `architecture.md` có **ba** chỗ, và chỉ **một** trong ba có tên trong một ngoại lệ.
  Kế hoạch §9: *một ô không tick được thì để trống kèm lý do và mã của chỗ đang chặn* — nên ô này
  **đổi lý do**, từ *"chưa ai đo"* sang *"đã đo, và đây là cái đo được"*. Cổng vẫn **9/10**.

  **Tập bị rà — lệnh chưa lọc, ở mức thô nhất** (`wc -l docs/product/1-system-design/*.md`): **tám**
  file, **2385** dòng — `01-…` 177 · `02-…` 213 · `03-…` 354 · `04-…` 204 · `05-…` 179 · `06-…` 161 ·
  `07-…` 416 · `architecture.md` 681. Chỉ thư mục này, **không** đếm `work/` hay `prompt/maintenance/`
  (**F-018**: một con số đếm rộng hơn phạm vi thì đo hoạt động viết lách, không đo việc còn lại).

  **Năm lượt lọc, mỗi lượt in cả hai con số** (**F-017** — bộ lọc rỗng vì viết sai trông y hệt bộ lọc
  rỗng vì không có lỗi):

  | Lượt | Bắt cái gì | Chưa lọc | Đã lọc |
  |---|---|--:|--:|
  | **A** | bộ mẫu **nguyên văn** của `scripts/check-phase-boundary.sh` (Gate 1d), chạy trên cả tám file — Gate 1d thật chỉ quét file **đã đổi** trong lượt, nên nó chưa từng chạy trên cả tập | 2385 | **1** |
  | **B** | động từ HTTP + đường dẫn **không** mở đầu bằng `/` — đúng chỗ mẫu của Gate 1d mù | 2385 | **4** |
  | **C** | từ khoá ràng buộc SQL: `UNIQUE` · `CHECK` · `INDEX` · `CONSTRAINT` · `JOIN` · `SELECT` · `INSERT` | 2385 | **3** |
  | **D** | định danh `snake_case` trong backtick + `bảng.cột` (trừ tên file `.md`) | 2385 | **14 + 1** |
  | **E** | pha 4 — route · component · `useState` · `className` · đuôi file mã; và đường dẫn hình route | 2385 | **12 + 0** |

  **Lượt E là chỗ chứng minh bộ lọc không tự rỗng.** Mười hai dòng nó bắt được **không** phải vi
  phạm: chúng là chính những câu **tự khai ranh giới** — *"Ở đây không có tên bảng, tên cột,
  endpoint, route"* ở đầu `03-…`, `04-…`, `06-…`, `07-…`, bốn hàng *P1-12 — rà ranh giới pha* trong
  bảng *Bước sau đọc gì* của `03-…` và `06-…`, hai dòng `architecture.md` trỏ sang
  `master_plan/prompt-fullstack.md`, và chính dòng này. Bộ lọc chạy; nó chỉ không có route nào để bắt.

  **Phân loại — ba nhóm, không chỗ nào để lửng:**

  1. **Ngoại lệ CÓ TÊN — một chỗ.** [`architecture.md`](architecture.md) **§12.3** (`table_sessions` ·
     `open_key` · `payments` · `UNIQUE` · `CHECK`): mục tự khai ngay trong thân *"cố ý vượt ranh giới
     §8 đặt ra… chủ repo yêu cầu thẳng một mục DB cho phần nợ… là **đề xuất gửi sang pha 2**, không
     phải lược đồ đã chốt"*. Kể ra ở đây như **ngoại lệ**, không như lỗi — và kể ra kèm **ranh giới
     của chính nó**: câu ⚠️ ấy khai đúng hai thứ (*tên bảng, tên cột*) và đúng **một** mục. Nó
     **không** phủ endpoint, và **không** phủ mục nào khác.
  2. **Định danh nghiệp vụ, pha 0 sở hữu — không phải tên bảng.** `qr_table` · `staff_pos` ·
     `phone_preorder` là **kênh bán** (`master_plan/shop-facts.md` §5, bảng dòng 64–66);
     `trang_banh` · `gap_banh` · `don_ban` là **trạm** (§3, dòng 99–102). Chúng có nhà ở pha 0. Một
     bộ lọc kêu chúng lên là bộ lọc đo sai thứ — ghi ra đây để lượt sau không kêu lại.
  3. **Chỗ lọt ra thật — ba chỗ, tất cả ở `architecture.md`, bảy file kia sạch.** **§12.2** dòng
     552 · 555–558 (một **hợp đồng API bốn dòng**: động từ, đường dẫn, tên trường thân yêu cầu,
     tham số truy vấn) · **§3.1** dòng 161–163 (`UNIQUE` trên generated column, và **chỉ định** nó
     phải gồm trạng thái `billing`) · **§4** dòng 238 (`staff.role` — một `bảng.cột`, trong tiêu đề).

  **Cả ba trả về `git blame`, không trả về một bước pha 1 nào:** bốn dòng đều sinh ở **`cf8bd83`,
  2026-08-31** — **trước** **ADR-035** (2026-09-04, bước `P1-01`). `architecture.md` viết trước khi
  có ranh giới; lúc P1-01 dựng ranh giới thì **chỉ §8** được viết lại cho khớp, §3.1 · §4 · §12.2
  không ai quét. Ba đường ra đã ghi, **không chọn hộ** — đó là quyết định của chủ repo:
  `work/findings.md` **F-040**.

  ⚠️ **Và một câu về cổng lẽ ra phải bắt chỗ này: `work/findings.md` `F-041`.** Bộ mẫu của Gate 1d
  đòi dấu `/` **ngay sau** động từ HTTP; bốn dòng §12.2 viết `staff/debts`, không `/staff/debts` —
  nên Gate 1d **im hoàn toàn** trên cả tập, và dòng duy nhất nó khớp thì đã nằm trong
  `scripts/check-phase-boundary.ignore`. Dòng ignore ấy còn ghi lý do là *"§12.3"* trong khi dòng nó
  che nằm ở **§12.2** — một ngoại lệ có tên đang đứng tên cho một dòng ngoài mục mình. Lượt này
  **không sửa `scripts/`**: P1-12 là phép đo, và `CLAUDE.md` §3.8 nói luật chỉ dựng sau khi cùng một
  vấn đề đã tốn hai lần.

  **Pointer pha 1, rà lần cuối:** `./scripts/check-links.sh` **xanh**; **196** pointer trong tám
  file (số chưa lọc). Cộng hai phép Gate 1b **không** làm — pointer trỏ **thư mục** (nó không chấm
  đường kết thúc bằng `/`, **F-018**): **không có cái nào** trong cả pha 1; pointer **neo `#`**:
  chỉ `](#top)`, và bốn file dùng nó đều tự định nghĩa `id="top"`, không neo chết nào.

  ⚠️ **Mọi con số trên là ẢNH CHỤP TẠI MỐC ĐO — 2026-09-16, TRƯỚC khi ô này được viết — và chính
  ô này làm chúng hết đúng ngay lập tức.** Đo lại sau khi viết xong: tập bị rà **2459** dòng (không
  còn 2385), lượt D **31** (không còn 14), lượt D2 **2** (không còn 1). Lý do đơn giản và không sửa
  được: bản ghi của một phép đo **nằm trong** tập bị đo — mục này là một file pha 1. Ba thứ theo sau,
  và lượt sau phải đọc chúng trước khi chạy lại:

  1. **Đừng đọc năm con số kia như con số hôm nay.** Chúng ghi *phép đo đã chạy trên cái gì*, đúng
     cách ô 9 giữ sáu mã của nó (`F-001` · `F-033`: một danh sách chép tay trong tài liệu đã ký là
     bản sao thứ hai và nó sẽ trôi).
  2. **Chênh lệch ấy là TRÍCH DẪN, không phải vi phạm mới.** `table_sessions` · `open_key` ·
     `payments` · `staff.role` · `UNIQUE` · `CHECK` xuất hiện thêm ở mục này vì ô 10 phải **gọi tên**
     chỗ nó bắt được — một phép đo không được phép nói *"có ba chỗ"* mà giấu chúng đi, và một ngoại
     lệ không có tên thì lần sau thành tiền lệ.
  3. **Lượt đo sau trừ mục này ra trước khi đếm**, rồi đọc lại danh sách ba nhóm ở trên thay vì đọc
     lại con số. Bảy file nội dung pha 1 mới là tập cần rà; `07-…` là **biên bản**, và một biên bản
     kể tên chỗ hỏng thì tự nó chứa chỗ hỏng ấy.

  **Ô này KHÔNG tick, và đó là câu trả lời thật.** Bài học `BA-11`: cổng 9/10 kèm lý do thì dùng
  được, cổng 10/10 bằng cảm giác thì không chặn được gì. Ô 10 xanh khi **F-040** có lời — và **ai
  nói câu *được, sang pha 2*** vẫn là quyền chủ repo, đúng như §8 mục này đã ghi cho mình.

**Một câu cho người ký cổng.** Chín ô xanh **không** có nghĩa là pha 1 đã hết chỗ hụt: ô 1 xanh
trong khi hai vế thiếu tầng (**`F-036`**), ô 3 xanh trong khi bảng đối soát thiếu một dòng
(**`F-037`**), ô 7 xanh **vì** ba chỗ hụt được ghi ra chứ không phải vì không có chỗ hụt, và ô 6
xanh với một dòng **⛔** trong sổ rủi ro (**`F-034`**). Bốn mã ấy cộng `S-5` · `S-6` là **cái pha 2
phải đọc trước khi tin bất kỳ ô nào ở trên** — cộng **`F-040`** · **`F-041`**, hai mã ô 10 mở ra
ngày 2026-09-16. Ô 10 **đã đo, chưa ký**: `architecture.md` §3.1 · §4 · §12.2 vẫn mang tên cột,
`bảng.cột` và một hợp đồng API bốn dòng, ngoài ngoại lệ §12.3 đã khai.

⚠️ **Và một câu về đường dẫn tới bốn mã ấy.** Đo ngay sau lượt này: `work/findings.md` có **chín**
mục đang mở, còn `scripts/brief.sh` cắt mục *OPEN FINDINGS* ở **sáu** — nên **`F-036`** ·
**`F-037`** · **`F-038`**, ba mã lượt này vừa mở, là đúng ba mã **brief không in tên**. Brief **có**
in dòng `→ ĐÃ CẮT: in 6/9 mục` (đó là bản sửa của `work/findings.md` **F-012**, T-027), nên phiên
sau được **báo** là danh sách bị cắt — nhưng nó phải tự mở `work/findings.md` mới thấy ba mã này.
Ai đọc cổng này thì đọc kèm câu đó.

---

## 8. Cái mục này cố ý không nói · bước sau đọc gì

**Cố ý không nói:**

- **Cách lấp ba chỗ hụt ở §6.** Lượt này ghi `F-036` · `F-037` · `F-038` và dừng; thiết kế bù ngay
  trong lượt diễn là làm mất chính phép nghiệm thu (`work/backlog_SD.md` → P1-11).
- **Một lời nào của ba scenario.** Chúng là **đầu vào**, và sửa đầu vào để nó đi qua được thiết kế
  là chạy phép thử ngược.
- **Ai nói câu *"được, sang pha 2"***. Mười ô ở §7 nói **cổng đạt tới đâu**; ký là quyền của **chủ
  repo**, đúng như cổng BA đã ghi cho mình.
- **Cách sửa ba chỗ ô 10 đo ra.** Ô 10 ghi ba đường ra và **không chọn hộ** — chọn là quyền chủ
  repo, và người viết `architecture.md` §3.1 · §4 · §12.2 mới biết câu đúng phải là gì
  (`work/findings.md` **`F-040`**). Sửa `scripts/check-phase-boundary.sh` cũng không: đó là
  **`F-041`**, và `CLAUDE.md` §3.8 nói luật chỉ dựng sau khi cùng một vấn đề đã tốn hai lần.

| Bước / pha | Lấy gì từ mục này |
|---|---|
| **P1-12** — rà chéo ranh giới pha | **đã chạy 2026-09-16**: ô **10** của §7 mang toàn bộ phép đo — tập bị rà, năm lượt lọc kèm cả hai con số, ba nhóm phân loại. Mục này nằm trong tập bị rà và **sạch** |
| **Phiên nhận `F-040`** | ba chỗ, ba dòng `git blame` về cùng `cf8bd83` (2026-08-31, **trước ADR-035**), và ba đường ra đã ghi sẵn — khai thêm vào ngoại lệ · viết lại bằng ngôn ngữ tầng · mở pha 3. Đường 2 là thứ ADR-035 thật sự đòi |
| **Phiên nhận `F-041`** | nới `PAT_API` **kèm một ca hồi quy** dùng đúng bốn dòng §12.2 làm đầu vào — không có ca hồi quy thì lần nới sau lại đóng lại; và sửa lý do dòng ignore cho đúng mục (§12.2, không §12.3) |
| **Pha 2** | §7 câu cuối — bốn mã cộng `S-5` · `S-6` phải đọc **trước** khi tin một ô cổng nào; §6 là danh sách chỗ pha 1 **chưa** phủ, đừng đọc chúng thành yêu cầu đã có |
| **Phiên nhận `F-036`** | hai ca cụ thể, và câu hỏi thật: phép đối chiếu của một mệnh đề phải phủ **mọi vế** của mệnh đề ấy, không chỉ vế chính |
| **Phiên nhận `F-037`** | [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §4 đã tả sẵn hình của dòng còn thiếu — *đúng hình của dòng nợ ghi trong ngày nhưng ngược chiều* — cộng luật một-đối-một giữa [`architecture.md`](architecture.md) §8 và [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §1 |
| **Phiên nhận `F-038`** | [`../0-ba/ban-hang/03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.2.4 là nhà của luật; chỗ thiếu là một **mệnh đề** và một **tầng**, không phải một luật mới |
| **Chủ quán** | không câu mới nào từ lượt này. *Viết 2026-09-08: lúc ấy `U-043` còn mở. Chủ quán đã trả lời nó **2026-09-16** — máy báo, POS quyết, mở lại bằng nút (**ADR-047**) — và cùng lượt đóng nốt `U-042` · `U-051` · `U-052`; hai câu mới `U-053` · `U-054` thế chỗ ở `docs/product/99-unknowns.md`.* `U-044` **đã đóng 2026-09-08** — POS quyết từng ca |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch pha 1 §5). Đo lại 2026-09-08: không có chỗ nào mâu thuẫn — chỗ duy nhất mục
này chạm tới §6.4 là **`F-037`**, và đó là một chỗ **thiếu** một dòng, không phải một chỗ **nói
ngược** một dòng.

[↑ đầu file](#top)
