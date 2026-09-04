# Ranh giới hệ thống — actor · phụ thuộc ngoài · đường suy giảm

*P1-02 — chốt 2026-09-04. Bước 2/12 của pha 1
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 · `docs/decisions.md` **ADR-033**).
Nguồn: `master_plan/shop-facts.md` §1 · §6.10 · §6.11 ·
`docs/product/1-system-design/architecture.md` §1 · §6.4 · §7 ·
`docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4.*

> **Mục này sở hữu đúng ba thứ:** danh sách **phụ thuộc ngoài** của hệ thống · **đường suy giảm**
> của từng phụ thuộc · và **đường đi tới actor** — không phải một bản chép actor.
>
> **Nó không sở hữu dữ kiện quán.** Giờ bán, số bàn, bảng giá, số tài khoản đều thuộc
> `master_plan/shop-facts.md` (**ADR-001**); ở đây không có bản chép thứ hai (`work/findings.md` **F-001**).
>
> **Nó không thiết kế một cơ chế nào.** Một dòng suy giảm nói **người** làm gì khi thứ ấy chết —
> không nói **máy** làm gì. Thử lại, hàng đợi, bộ nhớ đệm, đường kéo dự phòng là việc của **P1-08**
> và của pha 3 (kế hoạch §6).
>
> **Vì sao mục này tồn tại.** Chủ quán đã chốt một câu mà phần lớn hệ thống bán hàng không chốt:
> **mất điện thì quán không dừng bán** (`master_plan/shop-facts.md` §6.11, chốt 2026-09-02). Trước
> hôm nay câu ấy chỉ sống ở tầng nghiệp vụ, và không tài liệu kiến trúc nào kể tên những thứ **nằm
> ngoài** hệ thống mà hệ thống đang dựa vào. Một hệ thống chỉ đúng khi nó đang chạy thì không phục
> vụ được cái quán này.

---

## 1. Actor — đọc ở pha 0, ở đây không có bản thứ hai

Danh sách actor, phạm vi *hệ thống chịu trách nhiệm / KHÔNG chịu trách nhiệm*, và năm trạm làm việc
đều đã có nhà ở **pha 0**: [`docs/product/0-ba/ban-hang/01-actors-pham-vi.md`](../0-ba/ban-hang/01-actors-pham-vi.md)
§1.2 (actor) · §1.4 (ranh giới trách nhiệm) · §1.5 (năm trạm). Mảng quản trị có ranh giới **riêng**:
[`docs/product/0-ba/admin/01-ranh-gioi.md`](../0-ba/admin/01-ranh-gioi.md) §1.6.

Chép lại chúng ở đây là tạo bản thứ hai, và bản thứ hai luôn trôi (**F-001**). Mục này chỉ **dùng**
một câu của §1.4 làm điểm tựa, vì cả mục dựng trên nó:

> *"**Không phải chỗ dựa duy nhất để bán hàng.** Mất điện, mất mạng hay máy hỏng thì quán chuyển
> sang **sổ giấy** và **không dừng bán**"* — `01-actors-pham-vi.md` §1.4, dẫn `shop-facts.md` §6.11.

Một câu nữa của pha 1 nằm ngay cạnh nó và phải đọc cùng: **POS là nơi duy nhất ghi ra tiến độ sản
xuất và phục vụ** (`architecture.md` §1.1). Hai câu ấy gộp lại cho ra hình dạng của cả mục này —
**đúng một cái máy ở quầy đứng giữa quán và hệ thống**, nên mọi thứ ngoài kia chết thì chỗ hứng
luôn là **người đứng quầy**, không phải một trạm bếp nào.

---

## 2. Phụ thuộc ngoài — sáu thứ nằm ngoài hệ thống mà hệ thống đang dựa vào

**Sáu** là **phép đếm của lượt này (2026-09-04), không phải một quyết định** — gặp thứ thứ bảy thì
thêm vào đây kèm một dòng ở §3, đừng tự thiết kế quanh nó (`work/findings.md` **F-003**, cùng luật
với `architecture.md` §8).

Mã `PT-x` là **nhãn cục bộ của file này**, để §3 và các bước sau (**P1-08** · **P1-10** · **P1-11**)
trỏ được vào đúng một dòng. Nó không phải một mã dùng chung của repo.

| Mã | Thứ nằm ngoài hệ thống | Hệ thống dựa vào nó để làm gì | Đã chốt ở |
|---|---|---|---|
| **PT-1** | **Điện · mạng tại quán · thiết bị POS** | mọi thao tác **ghi** đều đi qua một máy ở quầy (`architecture.md` §1.1) | `shop-facts.md` §6.11 · `06-ngoai-le.md` dòng 11–12 · `01-actors-pham-vi.md` §1.4 |
| **PT-2** | **Nơi hệ thống chạy** — máy chủ và đường ra Internet của nó | năm kênh bán ở `shop-facts.md` §2 đều là kênh **qua máy**; hệ thống chết thì cả năm chết | `shop-facts.md` §6.11 (*"máy hỏng"*) · `01-actors-pham-vi.md` §1.4 · ⚠️ **số máy và hình thức triển khai chưa có owner** — `work/findings.md` **F-027** |
| **PT-3** | **Ngân hàng, qua mã VietQR TĨNH** | một trong hai phương thức thu tiền của quán | `shop-facts.md` §1 · `architecture.md` §7 · `01-actors-pham-vi.md` §1.4 |
| **PT-4** | **Tin nhắn báo có của ngân hàng** | nguồn đối soát **thứ ba**: phần khách chuyển khoản, thứ mà két không giữ | `shop-facts.md` §6.10 (chủ quán chốt 2026-09-01) · `architecture.md` §6.4 |
| **PT-5** | **Đường báo đơn web về quầy** | quầy biết có đơn mới của ba kênh không gắn bàn mà **không phải ngồi canh màn hình** | `03-lat-cat.md` §3.2.1 bước 6 · `07-pham-vi-mvp.md` §7.7 dòng *Thông báo đơn* · ⚠️ **tên đường cụ thể chưa có owner** — **F-027** |
| **PT-6** | **Sổ giấy** — quy trình của **người**, không phải một tính năng | ngày mất điện, doanh thu chỉ tồn tại trên giấy cho tới lúc nhập bù; và nó là nguồn đối soát **thứ nhất** | `shop-facts.md` §6.11 · §6.10 (chủ quán chốt 2026-09-02 · 2026-09-01) |

**PT-1 và PT-2 không phải một thứ**, và chỗ khác nhau của chúng là chỗ dễ thiết kế sai nhất:

- **PT-1 chết, hệ thống vẫn sống.** Quán mù, nhưng **khách web vẫn đặt được** — đơn `delivery`,
  `pickup`, `phone_preorder` vẫn vào hệ thống mà không ai ở quán nhìn thấy. Chủ quán cũng **không
  bấm được** nút *"Tạm dừng nhận đơn"* (`shop-facts.md` §6.8) vì nút ấy cũng nằm sau cùng đường
  mạng vừa mất. ⇒ Ca này còn một câu chưa ai trả lời: **U-035** (§4).
- **PT-2 chết, cả hai bên đều mù.** Khách không đặt được, quán không ghi được. Quán vẫn bán bằng
  tay tại chỗ và qua điện thoại; hai kênh khách tự bấm thì **mất hẳn** trong khoảng thời gian ấy —
  không có đường nào bù được một đơn chưa bao giờ tồn tại.

**Bốn thứ KHÔNG có trong bảng trên, và chúng vắng mặt có chủ ý** — chủ quán chưa nói tới thứ nào
trong bốn thứ này, nên viết chúng vào đây là **đặt ra một dữ kiện quán** (`CLAUDE.md` §3.5): máy in
hoá đơn · tổng đài điện thoại · cổng thanh toán trực tuyến (đã bị bác thẳng, `docs/decisions.md`
**ADR-030** *Rejected alternatives* — *"ngoài phạm vi, và nó đổi cách quán nhận tiền chứ không chỉ
đổi phần mềm"*) · dịch vụ giao hàng ngoài (quán **tự** đi giao,
`shop-facts.md` §6.7). Thấy quán thật sự dựa vào một trong bốn thứ ấy ⇒ **hỏi chủ quán**, đừng
thêm dòng.

---

## 3. Đường suy giảm — mỗi phụ thuộc đúng một dòng, đủ ba vế

Đọc mỗi ô theo ba vế: **quán làm gì · ai bù · bù lúc nào**. Không ô nào nói máy làm gì.

| Mã | Mất nó thì **quán làm gì** | **Ai bù** | **Bù lúc nào** |
|---|---|---|---|
| **PT-1** | **Không dừng bán.** Chuyển sang **sổ giấy** (PT-6): đơn và phiên vẫn chạy đúng các trạng thái của `05-vong-doi.md`, chỉ ghi trên giấy thay vì trên máy. Ca **khách web đặt trong lúc quán mù** thì chưa có luật — **U-035**, đừng suy hộ | **POS hoặc chủ quán** giữ sổ và nhập lại — không giao cho trạm bếp nào, vẫn đúng một cửa như mọi việc chạm tiền (`shop-facts.md` §6.11 · §6.13) | **Ngay khi có thể, không có mốc giờ cứng.** Có điện lại giữa buổi thì quay lại làm trên hệ thống **ngay**, phần ghi tay nhập sau — bán tiếp là việc gấp, nhập bù là việc sau (§6.11) |
| **PT-2** | **Không dừng bán**, y hệt PT-1 — nhưng hai kênh khách tự bấm (`qr_table`, `delivery`/`pickup` trên web) **không có gì để bù**: đơn ấy chưa từng tồn tại. Quán bán tại chỗ và qua điện thoại, ghi giấy | **POS hoặc chủ quán** (§6.11). Phần khách web mất thì **không ai bù được** — đó là cái giá, không phải một chỗ trống chờ thiết kế | **Ngay khi có thể** sau khi hệ thống sống lại (§6.11). Dấu hiệu đo được của ràng buộc *một chỗ chạy duy nhất* là việc của **P1-08** |
| **PT-3** | **Quầy không bấm *"đã thu"* khi chưa nhìn thấy tiền về.** Hệ thống **không tự biết tiền đã về tài khoản** — đó là một tính chất cố định, không phải một chỗ chưa làm xong (xem khung dưới bảng). Khách không chuyển được thì trả **tiền mặt**, hoặc **ghi nợ** (§6.14) | **Người đứng quầy** — người trao hàng bấm (`architecture.md` §7); hệ thống chỉ **ghi lại** quyết định đó, không quyết thay | **Tại chỗ, trước khi khách rời quán hoặc trước khi người giao rời chỗ khách.** Không có đường bấm bù sau lưng khách |
| **PT-4** | Phần **tiền mặt** vẫn đối soát với **két** như thường; phần **chuyển khoản** của ngày ấy **không có nguồn đối chiếu độc lập**. **Không cộng gộp hai phần lại** để một chỗ thừa che một chỗ thiếu (§6.10), và **không có nút *"đóng ca dù lệch"*** (`architecture.md` §6.4 luật 3) | **Chủ quán** — đối chiếu bằng chính bản ghi của tài khoản ấy (cùng ngân hàng ở PT-3, không phải một nguồn thứ tư), rồi ghi lý do lệch | **Ngay tối hôm ấy**, cùng lượt đối soát cuối ngày — ngưỡng lệch là **0đ** và *"lệch 1 đồng cũng phải tìm ra lý do"* (§6.10) |
| **PT-5** | Đơn web **vẫn vào hệ thống**, chỉ là **không ai được báo**. Quầy **tự mở danh sách đơn chờ xác nhận** trên POS thay vì chờ báo — đơn chưa duyệt vẫn **không sinh việc ở trạm nào** (`shop-facts.md` §6.2), nên chỗ hỏng là **khách chờ**, không phải bếp làm sai | **Người đứng quầy** — vẫn là người nhìn thấy đơn đầu tiên (`03-lat-cat.md` §3.2.1 bước 6) | **Trong buổi bán, trước giờ hẹn của đơn sớm nhất**: `pickup` và `phone_preorder` đều mang mốc giờ khách cần hàng (`shop-facts.md` §5.2 điểm 5). Chờ tới cuối buổi là trễ hẹn |
| **PT-6** | Bảng đối soát cuối ngày phải đọc được ***"còn N lượt bán trên giấy chưa nhập"*** — không có dòng ấy thì ngưỡng **0đ** báo lệch mà lý do chỉ là *chưa gõ xong* (§6.11) | **POS hoặc chủ quán** — người giữ sổ cũng là người nhập lại (§6.11) | **Ngay khi có thể** (§6.11). **Doanh thu của lượt nhập bù tính vào ngày nào thì CHƯA CHỐT — `U-032`**, và mục này không quyết hộ: nó chặn **P1-03** |

**Sáu dòng trên KHÔNG cùng một loại: ba dòng là lời chốt, một dòng chốt một nửa, hai dòng là SUY
RA.** Trộn hai loại ấy vào nhau đúng là chỗ `work/findings.md` **F-004** đã ghi, và `CLAUDE.md` §7.2
đặt thành luật. Đọc bảng theo đúng loại, đừng đọc cả sáu dòng như nhau:

| Dòng | Loại | Đo bằng gì |
|---|---|---|
| **PT-1** · **PT-6** | **lời chốt** | chủ quán chốt 2026-09-02, `shop-facts.md` §6.11 nói đủ cả ba vế: ai giữ sổ · nhập lại lúc nào · làm gì khi có điện lại giữa buổi |
| **PT-3** | **lời chốt** | `architecture.md` §7 (người trao hàng bấm) · `shop-facts.md` §6.3 (POS xác nhận **lúc nhận được tiền**, ADR-030) · §6.14 (đường ghi nợ) |
| **PT-2** | **một nửa chốt, một nửa suy ra** | *"máy hỏng ⇒ ghi giấy, không dừng bán"* là lời chốt (§6.11). *"Hai kênh khách tự bấm mất hẳn, không có gì để bù"* là **suy ra** từ §2 (hai kênh ấy do **khách** bấm trên web) — chủ quán chưa được hỏi câu này |
| **PT-4** | **suy ra** | chủ quán chốt tin nhắn báo có **là** nguồn thứ ba (§6.10, 2026-09-01), nhưng **chưa ai hỏi** mất nó thì làm gì. Dòng suy giảm ở đây chỉ là hệ quả bắt buộc của hai luật đang đứng: đối soát **chia theo phương thức** (§6.10) và **không có nút *"đóng ca dù lệch"*** (`architecture.md` §6.4 luật 3) |
| **PT-5** | **suy ra** | *"hệ thống báo đơn mới về quầy"* và *"người đứng quầy là người nhìn thấy đơn đầu tiên"* là lời chốt (`03-lat-cat.md` §3.2.1 bước 6); *"mất đường báo thì quầy tự mở danh sách"* là **suy ra** — nó đứng được vì đơn chưa duyệt **không sinh việc ở trạm nào** (`shop-facts.md` §6.2), nên chỗ hỏng chỉ nằm ở **khách chờ** |

**Hai dòng suy ra không được đọc như một lời chốt**, và cách kiểm chúng cũng là cách của quán chứ
không phải của máy: hỏi chủ quán *"hôm nào điện thoại anh không nhận được tin nhắn ngân hàng, tối
ấy anh đối chiếu phần khách chuyển khoản bằng gì"* (**PT-4**) và *"nếu quán không được báo, ai là
người nhớ mở danh sách đơn web ra xem"* (**PT-5**). Trả lời xong thì sửa dòng ở đây và ghi ngày —
đừng thêm một mục thứ hai (**F-001**).

> **Hệ thống không tự biết tiền đã về tài khoản.** Mã VietQR của quán là mã **tĩnh** — một mã cố
> định, không sinh riêng cho từng hoá đơn (`shop-facts.md` §1) — nên **không có đường nào để tiền
> tự báo về hệ thống**. Người ở quầy nhìn thấy tiền rồi bấm; hệ thống chỉ **ghi lại** cái bấm ấy.
> Đừng dựng bất kỳ luật nào — đối soát, tự đóng đơn trả trước, tự chuyển trạng thái — trên giả định
> ngược lại (`architecture.md` §7 · `01-actors-pham-vi.md` §1.4).

**Ba chỗ mà một đường suy giảm không được đi qua**, vì đi qua là phá một thứ đang đứng:

1. **Không mở nút *"đóng ca dù lệch"*.** Ngưỡng lệch **0đ** (`architecture.md` §6.4 luật 3,
   `docs/decisions.md` **ADR-022**) là cổng chất lượng mạnh nhất của cả dự án; mất một nguồn đối
   soát là **lý do để đi tìm**, không phải lý do để bỏ qua.
2. **Không đánh mất vết.** Mọi thao tác chạm tiền phải truy ngược được về **một người** và **một
   thời điểm** (`quality/invariants.md` **I-012**). Lượt bán ghi trên giấy rồi nhập bù cũng vậy:
   người nhập bù là người đứng tên cái vết ấy, và **PT-6** nói rõ đó là **POS hoặc chủ quán**.
3. **Không cộng gộp hai nguồn tiền để lấp một chỗ mất.** Doanh thu một ngày cộng từ **đủ hai**
   nguồn và không khoản nào đứng ở hai nguồn (`quality/invariants.md` **I-014**); đối soát thì
   chia theo **phương thức** (§6.10). Một chỗ thiếu ở két bị một chỗ thừa ở ngân hàng che mất là
   ngưỡng 0đ hết nghĩa.

---

## 4. Chỗ cố ý để trống — hai mã, và không mã nào được quyết ở đây

- **`U-032`** — lượt bán ghi trên **sổ giấy** hôm mất điện, hôm sau mới nhập, thì doanh thu tính
  vào **ngày nào**. Chạm **PT-6**. Hai đường ra đều phá một thứ đang có, nên mục này viết *"quán
  ghi giấy, nhập bù khi máy sống lại"* và **dừng ở đó**; câu *ngày nào* là của **P1-03**.
  Đọc ở [`docs/product/99-unknowns.md`](../99-unknowns.md).
- **`U-035`** — **mở trong chính lượt này.** Quán mất mạng mà hệ thống vẫn sống (**PT-1**): khách
  web vẫn đặt được, quán không nhìn thấy, và nút *"Tạm dừng nhận đơn"* cũng nằm sau đúng đường mạng
  vừa mất. Quán muốn ca ấy đi đường nào là **câu của chủ quán**, không phải chỗ để pha 1 tự chọn.
  Nó chặn vế *khách web* của dòng suy giảm **PT-1**, và chặn **P1-08**.
  Đọc ở [`docs/product/99-unknowns.md`](../99-unknowns.md).

Một chỗ nữa **không phải câu hỏi nghiệp vụ**, nên nó không nằm trong `99-unknowns.md`:
**`work/findings.md` F-027** — **PT-2** (*một máy chạy duy nhất*) và **PT-5** (*tên đường báo đơn*)
hôm nay chỉ có ở `master_plan/prompt-fullstack.md`, một **bản xuất khẩu tự khai không sở hữu sự
thật nào** (`docs/decisions.md` **ADR-035**). Bảng §2 vì thế ghi **cái quán dựa vào**, không ghi
**tên của thứ đang đảm nhiệm nó**. Ai nhận **P1-08** đọc F-027 trước: cả bốn ràng buộc ẩn của bước
ấy đều đứng trên cùng một bản xuất khẩu.

---

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-08** — realtime, đường kéo dự phòng, ràng buộc ẩn | **PT-2** và **PT-5**: mục này nói *mất nó thì quán làm gì*; P1-08 nói *máy làm gì* và đặt **dấu hiệu đo được** cho từng ràng buộc. Đọc **F-027** trước |
| **P1-10** — sổ rủi ro | mỗi dòng §3 là một rủi ro đã có người chịu; sổ rủi ro trỏ về đây thay vì viết lại |
| **P1-11** — diễn ba scenario | ba scenario của `08-scenario.md` §8 phải đi qua được **PT-1** và **PT-6**, tức đi qua được một buổi mất điện |
| **Pha 3 · pha 5** | cơ chế thật (thử lại, hàng đợi, bộ nhớ đệm, triển khai) — mục này **không** chốt cái nào, và không được đọc như thể có chốt |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch pha 1 §5). Tính tới 2026-09-04 không có chỗ nào mâu thuẫn: §7 nói *"đừng
thiết kế như thể có webhook"* và §10 xếp *"hệ thống là chỗ dựa duy nhất để bán hàng"* vào loại **đã
quyết định không làm** — cả hai cùng chiều với mục này.
