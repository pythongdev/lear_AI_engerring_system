# Thời gian — nguồn thời gian và định nghĩa MỘT NGÀY BÁN cho phép cộng tiền

*P1-03 — chốt 2026-09-04. Bước 3/12 của pha 1
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 · `docs/decisions.md` **ADR-033**).
Nguồn: `master_plan/shop-facts.md` §1 · §6.3 · §6.4 · §6.9 · §6.10 · §6.11 · §6.14 · §6.17 ·
[`architecture.md`](architecture.md) §1.1 · §6.3 · §6.4 · §12.3 ·
`quality/invariants.md` **I-014** · **I-015**.*

> **Mục này sở hữu đúng hai thứ:** **định nghĩa *một ngày bán*** dùng cho mọi phép cộng tiền, và
> luật về **nguồn thời gian** cấp mốc cho những phép cộng ấy. Không tài liệu nào khác được định
> nghĩa lại hai thứ này — bản thứ hai luôn trôi (`work/findings.md` **F-001**).
>
> **Nó không sở hữu dữ kiện quán.** Giờ bán và múi giờ là của `master_plan/shop-facts.md` §1
> (**ADR-001**); ở đây chỉ có đường trỏ về, không có bản chép.
>
> **Nó không sở hữu ba luật *tính ngày nào*.** Nợ (§6.14), hoàn (§6.4) và sổ giấy (§6.11) đã chốt ở
> `shop-facts.md` và đã có mặt trong `quality/invariants.md` **I-014**. Mục này chỉ cấp cho chúng
> một **cái ngày** để trỏ vào, và **không sửa một chữ nào** của chúng.
>
> **Nó không viết lại công thức đối soát.** Công thức năm dòng ở [`architecture.md`](architecture.md)
> §6.4 đứng nguyên; mục này làm nó **đọc được**, không thay nó.
>
> **Nó không thiết kế một cơ chế nào.** Không nút *"khoá sổ một ngày"*, không đường đồng bộ đồng
> hồ, không lịch chạy. Cơ chế là việc của **P1-08** và của pha 3 (kế hoạch §6).

**Vì sao mục này tồn tại.** Ba luật *doanh thu tính ngày nào* đã chốt và cả ba đều **ngược chiều
nhau một cách có chủ ý**: nợ tính **ngày ghi nợ** (`shop-facts.md` §6.14), hoàn tính **ngày hoàn**
(§6.4), sổ giấy thì *"nhập ngay khi có thể, không có mốc giờ cứng"* (§6.11). Cả ba đều nói *"ngày
nào"* mà **chưa tài liệu nào nói một ngày bắt đầu và kết thúc lúc nào**. Công thức đối soát
[`architecture.md`](architecture.md) §6.4 — cổng chất lượng mạnh nhất của cả dự án, ngưỡng lệch
**0đ** (`shop-facts.md` §6.10) — thì **không một dòng nào của nó đọc được** mà không có câu ấy: mỗi
dòng đều gắn với *"trong ngày"* hoặc *"hôm nay"*.

---

## 1. Định nghĩa — một ngày bán

> **Một ngày bán là một ngày lịch trong múi giờ của quán** (`master_plan/shop-facts.md` §1).
> Nó **bắt đầu ở mốc 00:00 của ngày ấy** và **kết thúc ngay trước mốc 00:00 của ngày kế tiếp**:
> mốc đầu **thuộc** ngày này, mốc cuối **thuộc** ngày sau.

Hai vế của câu trên, mỗi vế chặn một lỗi khác nhau:

- **Ranh giới đóng ở đầu, mở ở cuối.** Hai ngày liền nhau vì thế không bao giờ cùng nhận một mốc,
  và cũng không bao giờ để rơi một mốc vào khe giữa. Đây là điều kiện để **I-014** đứng được: mỗi
  khoản tiền thuộc **đúng một** ngày, không đếm hai lần và không rơi ra ngoài.
- **Múi giờ của quán, ở mọi tầng** — không phải múi giờ của cái máy đang gõ, không phải múi giờ mặc
  định của chỗ hệ thống chạy (**PT-2**, [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2).
  Một tầng quy mốc về ngày bằng một múi giờ khác sẽ cắt **một** ngày của quán thành **hai**, và nó
  cắt đúng ở chỗ khó thấy nhất: những giờ quán đóng cửa.

**Ngày bán KHÔNG phải giờ bán.** Giờ bán là **06:00–11:00** (`shop-facts.md` §1); một ngày bán phủ
**cả hai mươi tư giờ**. Tiền của quán đi cả ngoài giờ bán và mọi khoản ấy đều phải có ngày:

| Việc chạm tiền ngoài giờ bán | Đã chốt ở |
|---|---|
| **Thu nợ cũ** — người nợ quay lại trả lúc nào cũng được | `shop-facts.md` §6.14 |
| **Hoàn tiền** — quầy quyết từng ca, không có luật cứng nên không có giờ cứng | §6.4 |
| **Nhập bù lượt bán từ sổ giấy** — *"nhập ngay khi có thể"* | §6.11 |
| **Đối soát cuối ngày** — chủ quán làm **mỗi tối** | §6.10 |

Một định nghĩa lấy 11:00 làm mốc kết thúc sẽ đẩy cả bốn việc trên ra ngoài mọi ngày.

### 1.1 Vì sao là ngày lịch, chứ không phải một khung giờ riêng

*Cách đọc của lượt viết 2026-09-04, không phải lời chủ quán nói thẳng — theo `CLAUDE.md` §7.2.
Chủ quán chưa từng được hỏi câu này; ba lý do dưới đây suy từ những dữ kiện đã chốt.*

1. **Nửa đêm là mốc duy nhất chắc chắn không có tiền nào đang đi.** Quán bán **đúng một buổi mỗi
   ngày**, và *"hết buổi là sau 11:00"* (`shop-facts.md` §6.17, cách đọc theo §1); đối soát chạy
   **mỗi tối** (§6.10). Không phiên bàn, không lần thu, không lượt đối soát nào bắc qua 00:00. Một
   khung giờ riêng — ví dụ ngày chạy từ 03:00 tới 03:00 — không mua thêm được gì và bắt mọi tầng
   phải dịch một lần nữa.
2. **Đó là cái ngày chủ quán đang nói.** Câu hỏi `U-032` viết *"doanh thu của hôm mất điện"*, §6.4
   viết *"bán thứ Hai, hoàn thứ Tư"*. Chủ quán đếm bằng ngày lịch; một định nghĩa lệch với cách
   ông ấy đếm thì bảng đối soát nói một đằng, người đọc hiểu một nẻo.
3. **Nó là phương án hẹp nhất** ([`architecture.md`](architecture.md) §11, câu cuối). Ngày lịch là
   thứ đã có sẵn nghĩa; mọi phương án khác đều là một khái niệm mới phải nuôi.

⚠️ **Điều kiện của lý do 1 phải được đọc lại nếu quán mở buổi thứ hai.** `shop-facts.md` §6.17 đã
nói thẳng: *"Quán mở thêm buổi thứ hai thì phải hỏi lại câu này"*. Một buổi bán vắt qua nửa đêm làm
lý do 1 hết đúng, và định nghĩa ở §1 phải hỏi lại chủ quán chứ không được tự nới.

---

## 2. Mốc tính tiền — mỗi việc chạm tiền có ĐÚNG MỘT mốc quyết định ngày của nó

Định nghĩa ở §1 nói **một ngày dài từ đâu tới đâu**. Nó chưa nói **việc nào rơi vào ngày nào** —
câu đó do ba luật đã chốt trả lời, và mục này chỉ **gom chúng lại trỏ về cùng một cái ngày**.

> **Mốc tính tiền** của một việc chạm tiền là **một** mốc thời gian duy nhất, và ngày bán của việc
> ấy là ngày lịch (§1) chứa mốc đó. Một việc chạm tiền không bao giờ có hai mốc tính tiền.

| Việc | Mốc tính tiền là mốc nào | Luật chốt ở |
|---|---|---|
| **Bán** — đóng một đơn vị tính tiền (phiên bàn hoặc đơn lẻ), **kể cả** hoá đơn ghi nợ | mốc **đóng** đơn vị tính tiền ấy | `shop-facts.md` §6.14 · [`architecture.md`](architecture.md) §6.4 (*"hoá đơn đóng hôm nay, kể cả hoá đơn ghi nợ"*) |
| **Hoàn tiền** | mốc **hoàn** — không phải mốc bán gốc | `shop-facts.md` §6.4 (chủ quán chốt 2026-09-01, U-019) |
| **Thu nợ cũ** | mốc **thu** — và khoản ấy **không** vào doanh thu ngày nào cả, nó chỉ là dòng *nợ cũ thu được hôm nay* của bảng đối soát | `shop-facts.md` §6.14 · [`architecture.md`](architecture.md) §6.4 · §12.3 (hai mốc, hai câu hỏi) |
| **Nhập bù một lượt bán từ sổ giấy** | ⛔ **CHƯA CHỐT — đang chờ [`U-032`](../99-unknowns.md)** | — |
| **Trả trước nhận trước ngày giao hàng** | ⛔ **CHƯA CHỐT — đang chờ [`U-036`](../99-unknowns.md)** | — |

**Ba luật đã chốt không được nhắc lại bằng lời của mục này.** Bảng trên nói *mốc nào*, và trỏ về
nhà của từng luật. Chỗ duy nhất đọc được cả ba cạnh nhau là `quality/invariants.md` **I-014**;
lời của chúng thì ở `master_plan/shop-facts.md` (**ADR-001**).

### 2.1 Một lần thu không bao giờ rơi vào hai ngày

**I-015** cho một lần thu chia làm nhiều phần theo phương thức (tiền mặt · VietQR tĩnh), mỗi phần
ghi riêng số tiền. Định nghĩa ở trên vì thế phải nói thêm đúng một câu:

> **Mọi phần của cùng một lần thu dùng chung một mốc tính tiền.** Chia theo **phương thức** thì
> không kéo theo chia theo **ngày**.

Không có câu này thì một lần thu bắt đầu 23:59 và kết thúc 00:01 rơi vào hai ngày theo hai phương
thức, và đối soát của **cả hai** ngày cùng lệch — trong khi §6.10 đòi so **phần tiền mặt** với két
và **phần chuyển khoản** với tin nhắn báo có, tính riêng từng nguồn. Ngưỡng **0đ** khi đó báo lệch
hai lần cho một lần thu duy nhất, và không ai truy ra được lý do.

### 2.2 Mốc đã ghi thì không dời

*Cách đọc của lượt viết 2026-09-04, suy từ `I-014` — không phải một luật mới của chủ quán.*

`shop-facts.md` §6.22 cho phép **sửa cái sai bằng cập nhật**, giữ bản trước và bản sau. Một lần cập
nhật như thế **không dời mốc tính tiền** của khoản tiền đã ghi.

Vì sao: **I-014** đứng trên câu *doanh thu của một ngày đã đối soát không bao giờ đổi về sau*
(`shop-facts.md` §6.4). Nếu mốc tính tiền của một khoản đã ghi dời được, thì một thao tác hôm nay
lấy tiền ra khỏi ngày hôm qua, và con số chủ quán đã ký tối qua đọc lại không còn bằng chính nó.
⇒ Sửa một khoản tiền đã ghi là một **việc mới**, mang mốc của **ngày sửa**, đúng cách §6.4 xử một
lần hoàn.

Đây là một câu **ràng buộc**, không phải một cơ chế: *cái gì phải đúng*, không phải *khoá bằng gì*.
Khoá bằng gì là việc của pha 2 và pha 3.

---

## 3. Nguồn thời gian — một nguồn, không phải nguồn của máy khách

> **Mọi mốc tính tiền (§2) do đúng MỘT nguồn thời gian cấp, và nguồn ấy nằm ở chỗ hệ thống ghi —
> không phải ở cái máy gửi yêu cầu tới.**

Ba câu hệ quả, mỗi câu chặn một đường hỏng đã biết:

1. **Mốc không bao giờ lấy từ máy của khách.** Trong năm kênh bán của `shop-facts.md` §2, ba kênh
   là kênh khách **tự bấm trên máy của mình** — `qr_table`, `delivery`, `pickup`. Một mốc do máy
   khách gửi lên nghĩa là đồng hồ trên điện thoại của khách quyết định doanh thu của quán rơi vào
   ngày nào.
2. **Cũng không lấy từ đồng hồ của từng máy trong quán.** Quán có nhiều màn hình (POS ở quầy, năm
   màn trạm chỉ đọc — [`architecture.md`](architecture.md) §1.1 · §5). Mỗi máy một đồng hồ lệch vài
   phút là đủ để hai khoản tiền của cùng một buổi rơi vào hai ngày, và **chỉ** lộ ra ở những lượt
   sát nửa đêm — tức là những lượt hiếm nhất và khó dựng lại nhất.
3. **Mốc được cấp ở nơi ghi, đúng lúc ghi.** [`architecture.md`](architecture.md) §1.1 đã chốt
   **POS là nơi duy nhất ghi**; luật này chỉ nói thêm rằng mốc đi kèm việc ghi ấy được cấp cùng
   chỗ, chứ không đi theo yêu cầu từ ngoài vào.

**Một chỗ luật này KHÔNG với tới, và phải nói thẳng.** Lượt bán trên **sổ giấy** (**PT-6**,
[`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2 · §3) xảy ra khi hệ thống không có mặt:
mốc thật của nó nằm trên giấy, do **người** ghi. Hệ thống không cấp được mốc cho một việc nó không
chứng kiến. Đây chính là chỗ [`U-032`](../99-unknowns.md) đang đứng, và nó là **câu của chủ quán**,
không phải chỗ cho một luật kỹ thuật lấp vào.

**Ở đây không có tên cột, không có kiểu dữ liệu.** *Nguồn thời gian* là một câu về **tầng**: ai cấp
mốc và cấp ở đâu. Cất nó **thế nào** là việc của **pha 2** (**ADR-035**).

---

## 4. Chỗ cố ý để trống — hai mã, và không mã nào được quyết ở đây

Kế hoạch pha 1 §9: *một ô không tick được thì để trống kèm mã của chỗ đang chặn*. Hai ô dưới đây để
trống, và cả hai đều là **câu của chủ quán** (`CLAUDE.md` §3.5).

- **`U-032` — nhập bù một lượt bán từ sổ giấy tính doanh thu ngày nào.** Đang mở từ 2026-09-03.
  Hai đường ra đều phá một thứ đang có: về **ngày gõ** thì doanh thu ngày mất điện sai mãi mãi;
  về **ngày bán** thì một ngày **đã đối soát** đổi về sau, tức mất đúng câu **I-014** đang giữ và
  ngưỡng **0đ** hết nghĩa. Định nghĩa ở §1 **không quyết hộ** nó: §1 nói một ngày dài từ đâu tới
  đâu, `U-032` hỏi lượt nhập bù mang **mốc** nào — hai câu khác nhau, và câu thứ hai chạm tiền.
  Đọc nguyên văn ở [`docs/product/99-unknowns.md`](../99-unknowns.md).
- **`U-036` — khoản TRẢ TRƯỚC nhận hôm nay cho đơn giao hôm khác tính doanh thu ngày nào.**
  **Mở trong chính lượt này.** `shop-facts.md` §6.3 cho khách mang đi chọn **trả trước**, và POS
  xác nhận **lúc tiền thật sự tới tay quán**; §5.2 điểm 5 nói `pickup` có **giờ hẹn lấy** và
  `phone_preorder` là **đơn đặt trước**. Không luật nào nói hai mốc ấy có được rơi vào hai ngày
  khác nhau không, và nếu có thì doanh thu thuộc ngày nào. Đây là **chiều ngược của §6.14**: nợ là
  tiền về **sau** một lần bán đã xong, trả trước là tiền về **trước** một lần bán chưa xong — §6.14
  chốt chiều thứ nhất và không ai chốt chiều thứ hai. Nó chặn đúng hàng cuối bảng §2.
  Đọc nguyên văn ở [`docs/product/99-unknowns.md`](../99-unknowns.md).

**Hai mã trên có thể đòi công thức đối soát §6.4 của [`architecture.md`](architecture.md) thêm một
dòng** — dòng cho khoản tiền đã vào két mà chưa vào doanh thu, đúng hình của dòng *nợ ghi trong
ngày* nhưng ngược chiều. Mục này **không** thêm dòng ấy: chưa có lời chủ quán thì
chưa biết có cần hay không, và viết trước là chốt hộ.

---

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-04** — bảng ba cột nhóm **TIỀN** | cột *phép đối chiếu* của `I-014` nay có nghĩa: *"cộng trong một ngày"* = §1, và *"ngày nào"* = bảng §2. Hai hàng cuối bảng §2 còn trống ⇒ ô của `I-014` phải mang mã `U-032` · `U-036`, không được tick trơn |
| **P1-07** — yêu cầu hình dạng dữ liệu | §2 đòi **một** mốc tính tiền cho mỗi việc chạm tiền, §2.1 đòi mọi phần của một lần thu dùng chung mốc, §2.2 đòi mốc đã ghi không dời. Ba câu ấy là **yêu cầu**, pha 2 chọn hình dạng |
| **P1-08** — realtime và ràng buộc ẩn | §3 nói mốc do **một** nguồn cấp ở nơi ghi. Nhiều nơi cùng ghi thì câu ấy hỏng ⇒ đây là một đầu vào của ràng buộc *một instance* |
| **P1-09** — bảng quầy | bảng quầy đếm **trong ngày**; ngày ấy là §1 |
| **P1-11** — diễn ba scenario | scenario nào đi qua một buổi mất điện đều dừng ở `U-032`; nói ra chỗ dừng, đừng bước qua |
| **Pha 2** | cất mốc **thế nào**, kiểu gì, cột nào — mục này cố ý không nói (**ADR-035**) |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch pha 1 §5). Đo lại 2026-09-04: không có chỗ nào mâu thuẫn — §6.3, §6.4 và
§12.3 đều dùng chữ *"trong ngày"* / *"ngày ghi nợ"* / *"ngày thu"* và cả ba đọc đúng với §1 · §2 ở
trên. Chúng vốn **thiếu** một định nghĩa, không **nói ngược** một định nghĩa.
