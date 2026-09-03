# §3 — Bốn lát cắt nghiệp vụ

> Nguyên văn `docs/product.md` §3, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §3: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §3, tách 2026-09-02 ==== -->
## 3. Bốn lát cắt nghiệp vụ

> **Quyết định gốc của mục này:** → **ADR-027** (§3.1.7 ghép bàn = một phiên, một hoá đơn) ·
> **ADR-019** (§3.1.6 cho nợ, doanh thu tính ngày ghi nợ) · **ADR-029** (§3.1.4 suất *đem về* của
> khách ngồi bàn) · **ADR-023** (§3.3 đổi giá giữa buổi, thành phần suất chờ hết buổi) ·
> **ADR-021** (§3.2 luồng mang đi) · **ADR-009** (§3.4 — trục mẻ).

Bốn lát cắt chạy được từ đầu đến cuối, mỗi lát do một task BA chốt: một suất tại bàn (§3.1) · một
đơn mang đi (§3.2) · chủ quán đổi menu hoặc giá (§3.3) · quán làm theo mẻ (§3.4). Ba lát đầu kể
chuyện một bàn, một đơn, một lần sửa menu; lát thứ tư **cắt ngang** cả ba (ADR-009).
Hai luồng bán của quán ở `master_plan/shop-facts.md` §5; năm kênh ở §2 trên đây rơi vào đúng một trong hai luồng ấy.

### 3.1 Một suất tại bàn

*BA-03 — chốt 2026-08-31. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic A,
§4.1 (mười lăm bước), §4.3 (đặt hộ tại quầy), §5 quy tắc 1–4 và 9 + `master_plan/shop-facts.md`
§2, §3, §4.5, §5.1, §5.3, §6.1, §6.2, §6.6 (dữ kiện quán, chủ quán chốt 2026-08-19 → 2026-08-30).*

Lát cắt này đi trọn một vòng: từ lúc một bàn được mở tới lúc chính bàn ấy trở lại trạng thái trống.
Hai kênh gắn phiên bàn ở §2.1 — **QR tại bàn** và **Staff POS** — đều chạy trong lát cắt này và đổ
vào cùng một phiên.

#### 3.1.1 Luồng chính — mười lăm bước

Mỗi bước ghi rõ ai làm. Tên actor dùng đúng §1, tên trạm dùng đúng năm tên ở §1.5.

1. **Phiên bàn được mở.** *Khách* ngồi vào một bàn đang trống, và phiên mở khi **lượt gọi đầu
   tiên của bàn ấy được tạo** — bằng QR tại bàn hoặc quầy đặt hộ (§3.1.2, bảng §5.3 dòng 1).
   *Hệ thống* mở cho bàn đó **một** phiên bàn, trạng thái **Mở**. ⇒ **Một bàn có khách ngồi mà
   chưa gọi gì thì vẫn ở `Trống`**, và quầy đếm nó là bàn trống. Bàn nào còn một phiên chưa thanh
   toán thì không mở phiên thứ hai (§3.1.4). Nhóm đông ngồi **ghép** hai bàn thì vẫn là **một**
   phiên, gắn cả hai bàn (§3.1.7).
2. **Khách quét QR, hoặc nhân viên đặt hộ.** Hai đường vào, hai kênh: *Khách* quét QR tại chính
   bàn mình đang ngồi, hoặc *người đứng quầy* đặt hộ bằng Staff POS cho đúng số bàn ấy (nhánh đầy
   đủ ở §3.1.2). Cả hai đường đều đổ vào phiên của bàn đó.
3. **Khách chọn món.** *Khách* — hoặc *người đứng quầy* khi nhập hộ — chọn suất bán, chọn nhân và
   lượng nhân. Khách không gửi giá lên: *Hệ thống* tự xác định giá từ bảng giá và từ chối tổ hợp
   tuỳ chọn không hợp lệ (`shop-facts.md` §4.6 quy tắc 3 và quy tắc 9).
4. **Đơn được gửi.** *Khách* bấm gửi. Đơn vào phiên bàn ở trạng thái **Chờ xác nhận**, và **chưa sinh
   việc ở bất kỳ trạm nào** (§3.1.3).
5. **Quầy xác nhận.** *Người đứng quầy* duyệt đơn; đơn chuyển sang **Đã xác nhận**. Đơn khách tự gửi
   qua QR tại bàn mà quầy chưa duyệt thì đứng lại ở bước 4. Đơn do *người đứng quầy* nhập bằng
   Staff POS không đi qua bước này — nhân viên đã nhập thì đã có người chịu trách nhiệm (§2.2).
6. **Công việc được phân tới các trạm.** *Hệ thống* nổ đơn đã xác nhận thành việc của từng trạm theo
   thành phần của suất (§3.1.5). Ba trạm bếp nhận việc **cùng lúc** — **tráng bánh**, **gấp
   bánh**, **lấy canh** — không phải ba chặng nối đuôi nhau.
7. **Các trạm hoàn thành phần việc.** *Người tráng bánh* tráng bánh và làm trứng; *người gấp bánh*
   gấp bánh, xếp đĩa, cắt giò; *người canh & dọn* làm nước chấm và canh. Nước chấm là việc **cấp
   đơn**: mọi đơn tại bàn đều sinh đúng một việc cho trạm **lấy canh** (`shop-facts.md` §6.6).
8. **Món được mang ra bàn.** *Nhân viên quán* bưng ra đúng số bàn của phiên.
9. **Khách có thể gọi thêm.** *Khách* quét QR gọi tiếp, hoặc nhờ *người đứng quầy* đặt hộ. Mỗi
   lượt gọi thêm quay lại bước 3.
10. **Các lượt gọi tiếp tục thuộc cùng phiên bàn.** *Hệ thống* gom mọi lượt gọi của bàn đó — bằng
    bất kỳ tổ hợp nào của hai kênh — vào **một** phiên đang mở (§3.1.4).
11. **Quầy tính tổng toàn bộ phiên.** *Người đứng quầy* tính tiền trên **cả** phiên, ra **một**
    hoá đơn. Phiên chuyển sang **chờ thanh toán**. Bàn **chưa** trống ở thời điểm này, và khách
    vẫn gọi thêm được (§3.1.4).
12. **Khách thanh toán.** *Khách* trả tại quầy, tiền mặt hoặc VietQR. *Người đứng quầy* nhìn tiền
    hoặc nhìn báo có rồi **tự bấm xác nhận đã nhận tiền** — hệ thống không tự biết tiền đã về
    (§1.4). Khách ngồi bàn **không** có nhánh trả trước: phiên còn mở thì còn gọi thêm được nên
    chưa chốt được số tiền để trả (§1.1). Khách **không trả được** thì quán **cho nợ** — luồng
    vẫn đi tiếp sang bước 13, xem §3.1.6.
13. **Phiên bàn đóng.** *Người đứng quầy* đóng phiên. Từ đây phiên không nhận thêm lượt gọi nào.
    Phiên đóng được **cả khi khách còn nợ**; khi ấy việc đóng bắt buộc kèm hai thông tin, ai nợ và
    nợ bao nhiêu (§3.1.6).
14. **Bàn được dọn.** *Người canh & dọn* dọn bàn — cũng chính là người làm trạm **lấy canh** ở
    bước 7, nên lúc đông khách hai việc này tranh nhau một đôi tay (§1.5).
15. **Bàn trở lại trạng thái sẵn sàng.** *Hệ thống* trả bàn về **trống** khi và chỉ khi phiên đã
    đóng (bước 13) **và** bàn đã được dọn (bước 14). Thiếu một trong hai thì bàn chưa trống
    (§3.1.4).

#### 3.1.2 Nhánh đặt hộ tại quầy

Khách không quét được QR — máy hết pin, không có mạng, hoặc khách không muốn tự bấm — thì *người
đứng quầy* đặt hộ bằng **Staff POS**. Nhánh này thay bước 2 tới bước 5 của luồng chính, gồm sáu
việc theo thứ tự (§4.3 kế hoạch gốc):

- *Người đứng quầy* chọn **số bàn** khách đang ngồi.
- *Người đứng quầy* chọn món theo lời khách, kèm nhân và lượng nhân.
- *Hệ thống* tạo đơn **vào đúng phiên đang mở của bàn ấy** — không mở phiên mới, không tạo một đơn
  lẻ. Bàn chưa có phiên nào thì chính lượt gọi này là lúc phiên được mở (bước 1).
- Đơn được **xác nhận ngay**, không có chặng **Chờ xác nhận**: đơn do nhân viên nhập thì không cần duyệt
  (§2.2).
- Đơn đi thẳng vào bước 6 — nổ ra việc cho các trạm.
- *Khách* gọi thêm sau đó bằng đường nào cũng được, quét QR hay lại nhờ quầy; mọi lượt vẫn vào
  **cùng** phiên ấy.

Nhánh này **không** tạo ra một đơn vị tính tiền thứ hai. Bàn 5 gọi hai lượt bằng QR tại bàn và một
lượt nhờ quầy đặt hộ vẫn là **một** phiên, **một** hoá đơn (§3.1.4).

#### 3.1.3 Đơn khách tự gửi bị chặn tới khi quầy duyệt

Bước duyệt tồn tại để **chặn đơn ảo**, nên nó chỉ áp cho đơn không ai chịu trách nhiệm (§2.2).

Điểm chặn nằm **giữa bước 4 và bước 6**: một đơn **QR tại bàn** đã gửi mà *người đứng quầy* chưa
xác nhận thì nằm nguyên ở trạng thái **Chờ xác nhận** và **không sinh một việc nào** ở cả năm trạm —
không tráng bánh, không gấp bánh, không nước chấm (`shop-facts.md` §6.2). Bếp không nhìn thấy đơn
đó.

Chặn ở đây là chặn **việc xuống bếp**, không phải chặn đơn khỏi phiên: đơn ở **Chờ xác nhận** **vẫn thuộc**
phiên của bàn, và khi được duyệt thì vẫn được tính vào chính hoá đơn của phiên ấy (§3.1.4).

#### 3.1.4 Một bàn, một phiên, một hoá đơn — và lúc nào bàn mới trống

Bốn câu dưới đây là luật, không phải mô tả (§5 quy tắc 1, 2, 3, 9 của kế hoạch gốc ·
`shop-facts.md` §2, §6.1):

- **Một bàn thuộc nhiều nhất một phiên chưa thanh toán.** Bàn đang có phiên *đang mở* hoặc phiên
  *chờ thanh toán* thì mọi lượt gọi mới đổ vào chính phiên đó, không sinh phiên thứ hai. Chiều
  ngược lại **không** đối xứng: một phiên gắn được **nhiều** bàn khi khách ghép bàn (§3.1.7).
- **Nhiều lượt gọi món tại một bàn tạo *một* lần thanh toán.** Mọi lượt gọi của bàn đó, bằng bất
  kỳ tổ hợp nào của QR tại bàn và Staff POS, thuộc cùng một phiên và được tính tiền **một** lần,
  trên **một** hoá đơn. Không tách hoá đơn theo lượt gọi, cũng không tách theo từng người ngồi
  cùng bàn.
- **Khách gọi thêm lúc phiên đang chờ thanh toán vẫn vào cùng một hoá đơn ấy**, và **bàn chưa được
  coi là trống** ở thời điểm đó. Trạng thái *chờ thanh toán* (bước 11) không đóng phiên và không
  giải phóng bàn; quầy tính lại tổng rồi thu một lần. Tách lượt gọi ấy thành hoá đơn thứ hai là
  **thu thiếu tiền** — lỗi tiền nguy hiểm nhất của luồng tại bàn (`shop-facts.md` §6.1).
- **Suất khách gọi để đem về cũng nằm trong hoá đơn ấy.** Khách đang ngồi bàn gọi thêm một suất
  mang về thì suất đó vào **chính phiên bàn** này, kèm note **"đem về"**, chứ không tách thành một
  đơn mang đi (chủ quán chốt 2026-08-31, `shop-facts.md` §6.15). Nó là tiền của **phiên bàn**, và
  nó vẫn nằm trên bảng việc của bàn ấy. Note phải **rõ ràng** — bếp và người bưng đọc vào phải
  biết ngay suất nào gói lại, suất nào bày ra đĩa.
- **Bàn trống chỉ sau hai việc, không phải một.** Điều kiện để bàn trở lại **trống** là phiên **đã
  đóng** *và* bàn **đã được dọn**. Đóng phiên xong mà chưa dọn thì bàn vẫn bận; dọn trước khi đóng
  phiên cũng không làm bàn trống sớm hơn.

#### 3.1.5 Khách nhìn suất bán, bếp nhìn thành phần

Cùng một đơn có hai cách nhìn, cả hai đều đúng:

- **Khách** nhìn theo **suất bán** — thứ khách chọn và trả tiền, mỗi suất một dòng trên hoá đơn.
- **Bếp** nhìn theo **thành phần** — thứ từng trạm thật sự làm ra. Số lượng thành phần = số suất ×
  số thành phần trong suất (`shop-facts.md` §4.5).

**Mọi suất bán đều kèm bánh cuốn, không riêng combo.** Cả bốn suất bán ở `shop-facts.md` §4.5 đều
có bánh cuốn trong thành phần: suất trứng và suất giò mỗi suất kèm bốn cái bánh, combo kèm ba.
Nên khách gọi "một suất trứng" thì bếp làm **năm** thứ, không phải một — đây là chỗ hay bị làm
thiếu nhất. Việc xuống bếp **không bao giờ** được là một dòng "Combo ×2" mơ hồ: nhìn dòng đó thì
không trạm nào biết phải tráng mấy cái bánh (`shop-facts.md` §5.3).

Ví dụ lấy lại từ `shop-facts.md` §5.3 — khách bàn 5 gọi **hai suất Đầy đủ trứng tái, thịt + mộc
nhĩ, nhiều nhân**:

```text
Khách nhìn hoá đơn — MỘT dòng:
    Đầy đủ trứng tái ×2 — Thịt + mộc nhĩ, Nhiều nhân      (số tiền: shop-facts.md §4.3)

Bếp nhìn — SÁU việc, trên BA trạm:
    tráng bánh │ Bánh cuốn ×6 — thịt + mộc nhĩ, nhiều nhân
    tráng bánh │ Trứng tái  ×2 — thịt + mộc nhĩ, nhiều nhân
    gấp bánh   │ Bánh cuốn ×6 — thịt + mộc nhĩ, nhiều nhân
    gấp bánh   │ Trứng tái  ×2
    gấp bánh   │ Giò        ×2   ← giò không nhận nhân ⇒ không kèm mô tả nhân
    lấy canh   │ Nước chấm — bàn 5, hai suất
```

Hoá đơn ghi **×2**, bếp phải tráng **×6** — hai con số khác nhau của cùng một đơn, vì một combo có
ba cái bánh. Ai đọc "×2" rồi tráng hai cái bánh là làm thiếu bốn cái.

Hai chi tiết đi kèm, đều là luật: thành phần **không nhận nhân** — chiếc giò — thì việc xuống bếp
**không** kèm mô tả nhân (`shop-facts.md` §4.6 quy tắc 6); và **nước chấm là việc cấp đơn**, một
đơn một việc cho trạm **lấy canh**, không nhân lên theo số suất.

#### 3.1.7 Ghép bàn — một phiên, một hoá đơn

*Chủ quán chốt 2026-08-31 (`shop-facts.md` §6.16). Ghép bàn là chuyện có thật ở quán, không phải
ca hiếm: quán có mười một bàn và nhóm đông thì ngồi tràn sang bàn bên.*

Nhiều bàn ghép lại được phục vụ bằng **một** phiên và trả **một** hoá đơn:

- **Một phiên gắn một hoặc nhiều bàn.** Câu đúng của luật ở §3.1.4 là *"một bàn thuộc nhiều nhất
  một phiên chưa thanh toán"* — không phải *"một bàn một phiên"*. Một bàn không bao giờ nằm trong
  hai phiên còn mở; một phiên thì phủ được nhiều bàn.
- **Mọi lượt gọi từ bất kỳ bàn nào trong nhóm đều vào cùng phiên ấy.** Khách ngồi bàn 4 quét QR
  trên bàn 4, khách ngồi bàn 5 quét QR trên bàn 5 — vẫn một hoá đơn. Đây là §3.1.4 nới ra cho
  nhóm bàn, không phải luật chống lại nó: tách nhóm ghép thành hai hoá đơn cũng là **thu thiếu
  tiền** theo đúng nghĩa cũ.
- **Bàn trở lại trống theo từng bàn.** Đóng phiên là điều kiện chung cho cả nhóm, nhưng dọn bàn
  thì dọn từng cái: bàn 4 trống khi phiên đã đóng **và** bàn 4 đã được dọn, không đợi bàn 5.
- **Bếp không biết đến chuyện ghép.** Việc xuống bếp vẫn ghi **bàn nào gọi**, không ghi "nhóm" —
  người bưng cần biết bưng tới chỗ nào (§3.1.5). Ghép là chuyện của **tiền**, không phải của bếp.

**Ai bấm, và ghép được lúc nào** *(chủ quán chốt 2026-08-31, `shop-facts.md` §6.16 — trả lời
U-013)*:

- **Người đứng quầy bấm ghép, trên POS.** Cùng một cửa với duyệt đơn (§2.2), huỷ đơn (§2.4), hoàn
  tiền và ghi nợ (§3.1.6) — mọi việc chạm tiền đi qua đúng một máy.
- **Chỉ ghép được khi bàn kia còn trống.** Bàn đang có phiên mở thì **không** ghép được. Đây là
  ranh giới chủ quán chốt, không phải hạn chế kỹ thuật chờ ai gỡ.
- ⇒ **Ghép bàn là NỚI một phiên đang mở sang một bàn trống, không bao giờ là GỘP hai hoá đơn.**
  Nới thì chưa đồng nào phải dời chỗ; gộp thì phải trộn tiền của hai hoá đơn đã có. Chủ quán chọn
  đường thứ nhất và đóng đường thứ hai.
- ⇒ **Hai nhóm đã ngồi hai bàn riêng, mỗi bàn một phiên, thì trả hai hoá đơn** — kể cả khi họ quen
  nhau và xin gộp. Muốn một hoá đơn thì phải ghép **trước khi** bàn thứ hai được mở phiên.
- ⇒ Luật này giữ nguyên vẹn *"một bàn thuộc nhiều nhất một phiên chưa thanh toán"* (§3.1.4): bàn
  được ghép vào đang **trống**, tức chưa thuộc phiên nào.

#### 3.1.6 Khách không trả được thì quán cho nợ

*Chủ quán chốt 2026-08-31 (`shop-facts.md` §6.14). Đây là đường chính thức, không phải ngoại lệ
chờ ai nghĩ ra cách xử.*

Khách rời quán mà chưa trả tiền thì **quán cho nợ**, và luồng chính vẫn chạy hết:

- *Người đứng quầy* **vẫn đóng phiên** (bước 13). Không để phiên mở mãi chờ tiền — làm thế thì
  một bàn quỵt tiền khoá luôn cái bàn đó.
- Lúc đóng, POS **bắt buộc ghi hai thứ**: **ai nợ** và **nợ bao nhiêu**. Thiếu một trong hai thì
  khoản nợ vô chủ và đối soát cuối ngày sẽ thấy két thiếu tiền mà không ai truy được
  (`shop-facts.md` §6.10 — lệch một đồng cũng phải tìm ra lý do).
- *Người canh & dọn* **vẫn dọn bàn** (bước 14), và bàn **vẫn trở lại trống** (bước 15). Điều kiện
  ở §3.1.4 không đổi một chữ: đóng phiên **và** dọn bàn.

Hai hệ quả phải nói ra, vì cả hai đều chạm thứ đã chốt ở chỗ khác:

- **Ghi nợ phá tính ẩn danh của phiên bàn.** Phiên bàn vốn ẩn danh theo số bàn (§2.1); ca này bắt
  buộc phải có một cái tên hoặc một cách gọi lại được. Đó là cái giá của việc cho nợ, chủ quán đã
  chấp nhận.
- **Một khoản nợ không phải tiền đã thu.** Doanh thu trong ngày và tiền trong két lệch nhau đúng
  bằng tổng nợ ghi trong ngày. Báo cáo nào cộng khoản nợ vào như tiền mặt đã nhận là báo cáo sai
  (`shop-facts.md` §6.9).

**Trả nợ về sau** *(chủ quán chốt 2026-08-31, `shop-facts.md` §6.14 — trả lời U-012)*:

- **POS ghi nhận** lúc người nợ quay lại trả — cùng một cửa với mọi việc chạm tiền khác.
- **Doanh thu tính vào ngày GHI NỢ**, không phải ngày thu được tiền: bữa ăn bán ngày nào thì doanh
  thu ngày ấy, lần trả sau chỉ là tiền về chứ không phải một lần bán mới.
- ⇒ **Một lần trả nợ không bao giờ được ghi thành một khoản bán mới** — ghi vậy là tính doanh thu
  **hai lần** cho cùng một bữa ăn.
- ⇒ Két lệch ở **hai** ngày ngược chiều nhau: ngày ghi nợ két **thiếu**, ngày trả nợ két **thừa**
  trong khi doanh thu hôm ấy không tăng. Đối soát (`shop-facts.md` §6.10) phải bày cả hai dòng,
  nếu không nó báo động giả mỗi lần có người nợ hoặc trả nợ.

### 3.2 Một đơn mang đi (ba kênh không gắn bàn)

*BA-04 — chốt 2026-08-31. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic B,
§4.2 (chín bước), §5 quy tắc 5, 8, 10, 11, §6 + `master_plan/shop-facts.md` §1, §2, §5.2, §6.2,
§6.3, §6.5, §6.6, §6.7, §6.8, §6.12 (dữ kiện quán, chủ quán chốt 2026-08-19 → 2026-08-31).*

Lát cắt này đi trọn một đơn **không gắn bàn**: từ lúc khách chọn món tới lúc đơn hoàn thành. Ba
kênh không gắn phiên bàn ở §2.1 — **Delivery**, **Pickup** và **Đặt trước qua hotline** — chạy
chung **một** luồng (`shop-facts.md` §5.2), không phải ba luồng song song.

Tài liệu này gọi kênh bằng tên người đọc, đúng như §2. Ba định danh máy tương ứng, dùng ở
`master_plan/shop-facts.md` §2 và §5.2, là `delivery` · `pickup` · `phone_preorder` — chép ra đây
**một lần** để hai tài liệu ghép được vào nhau, sau dòng này §3.2 chỉ dùng tên người đọc.

**Một luồng, ba kênh, hai kiểu kết thúc.** Ba kênh khác nhau ở *đường đơn đi vào* (ai bấm, có phải
duyệt không); chúng khác nhau ở *đường đơn đi ra* theo **cách trao hàng**, không theo kênh: giao
tận nơi, hoặc khách tới lấy (§3.2.2). Đây là chỗ dễ chia sai nhất của lát cắt — chia theo kênh sẽ
đẻ ra một nhánh thứ ba cho đơn hotline, thứ không tồn tại.

#### 3.2.1 Luồng chính — chín bước

Mỗi bước ghi rõ ai làm. Tên actor dùng đúng §1, tên trạm dùng đúng năm tên ở §1.5, tên trạng thái
dùng đúng bộ tên của §3.1.

1. **Khách chọn món.** *Khách* tự bấm trên web (**Delivery**, **Pickup**), hoặc *Khách* gọi
   hotline và *người đứng quầy* nhập hộ (**Đặt trước qua hotline**). Khách không gửi giá lên:
   *Hệ thống* tự xác định giá từ bảng giá và từ chối tổ hợp tuỳ chọn không hợp lệ
   (`shop-facts.md` §4.6 quy tắc 3 và quy tắc 9) — giống hệt bước 3 của §3.1.1.
2. **Nhân viên hỏi cách trao hàng và giờ cần hàng — chỉ với đơn hotline.** *Người đứng quầy* đang
   nghe máy **phải hỏi hai câu**: giao tận nơi hay khách tới lấy, và cần hàng lúc mấy giờ
   (`shop-facts.md` §5.2). Câu trả lời của khách quyết định đơn này ra bằng nhánh nào ở bước 9.
   Đơn **Delivery** và **Pickup** không có bước này: khách đã tự chọn cách trao hàng lúc bấm.
3. **Khách cung cấp thông tin liên hệ.** *Khách* khai, hoặc *người đứng quầy* nhập hộ theo lời
   khách. Mức tối thiểu của từng kênh ở §3.2.4 — thiếu một trường bắt buộc thì đơn không tạo được.
4. **Hệ thống xác định tổng tiền.** *Hệ thống* tính lại tổng từ bảng giá tại thời điểm tạo đơn.
   Đơn mang đi không có phí ship và không có đơn tối thiểu (§3.2.6), nên tổng tiền của đơn đúng
   bằng tổng tiền các suất khách gọi.
5. **Đơn được tạo.** *Hệ thống* tạo **một đơn lẻ**, không gắn phiên bàn nào (§3.2.5), ở trạng thái
   **Chờ xác nhận** với hai kênh khách tự bấm và **Đã xác nhận** ngay với đơn hotline (bước 7). Đơn chỉ
   được tạo khi quán **đang nhận đơn** — trong giờ bán và chủ quán không bấm tạm dừng (§3.2.6).
   Ở bước này *Khách* được chọn **trả trước** thay cho đường mặc định là trả lúc nhận hàng; đó là
   **tuỳ chọn**, và chỉ đơn mang đi mới có nó (§3.2.5).
6. **Quán nhận thông báo.** *Hệ thống* báo đơn mới về quầy. *Người đứng quầy* là người nhìn thấy
   đơn đầu tiên, kể cả với đơn hotline do chính mình vừa nhập.
7. **Quầy xác nhận đơn khách tự gửi.** *Người đứng quầy* duyệt đơn **Delivery** và **Pickup**;
   đơn chuyển từ **Chờ xác nhận** sang **Đã xác nhận**. Đơn **Đặt trước qua hotline** *không* đi qua
   bước này — nhân viên đã nhập thì đã có người chịu trách nhiệm (§2.2). Đơn chưa duyệt **không
   sinh việc ở bất kỳ trạm nào** (`shop-facts.md` §6.2), đúng như đơn tại bàn ở §3.1.3.
8. **Quán chuẩn bị món và đóng gói.** *Hệ thống* nổ đơn đã xác nhận thành việc của từng trạm theo
   thành phần của suất — cách nổ y hệt §3.1.5, đơn mang đi không có cách tính riêng. Ba trạm bếp
   nhận việc **cùng lúc**: *người tráng bánh*, *người gấp bánh*, *người canh & dọn*. **Mọi đơn
   mang đi đều sinh một việc nước chấm**, chỉ khác là **gói riêng** (`shop-facts.md` §6.6) — bỏ
   sót là khách nhận bánh không có nước chấm. Xong việc, *nhân viên quán* **đóng gói** đơn; bước
   này thay cho bước "mang ra bàn" của §3.1.1.
9. **Đơn kết thúc theo một trong hai nhánh.** *Nhân viên quán* giao tận nơi, hoặc *Khách* tới quán
   lấy (§3.2.2). Tiền được thu ở bước này với đơn đi đường mặc định; đơn đã trả trước thì chỉ còn
   việc trao hàng. Đơn chuyển sang **hoàn thành**. **Không có bước dọn bàn** — luồng này kết thúc
   ở đây, trong khi §3.1.1 còn hai bước nữa.

#### 3.2.2 Hai nhánh kết thúc — chia theo cách trao hàng, không theo kênh

Bước 9 tách làm hai, và đường tách là **cách trao hàng** (`shop-facts.md` §5.2):

- **Giao tận nơi.** *Nhân viên quán* **tự đi giao** — quán không thuê bên thứ ba (§1.4). Đơn mang
  trạng thái **"đang giao"** từ lúc rời quán, để quầy nhìn được đơn nào còn trên đường và **ai
  đang cầm tiền chưa về** (`shop-facts.md` §6.7). Thu tiền **tại chỗ khách**, tiền mặt hoặc
  VietQR. Giao xong, *nhân viên quán* bấm **đã giao và đã thu tiền cùng lúc**.
- **Khách tới lấy.** *Khách* tới quán nhận hàng, *người đứng quầy* trao và **thu tiền tại quầy**,
  tiền mặt hoặc VietQR. Không có trạng thái "đang giao" ở nhánh này.

**Chỉ đơn giao tận nơi có trạng thái "đang giao"** — nhánh tới lấy đi thẳng từ đóng gói sang hoàn
thành. Và **không có nhánh thứ ba**: một đơn **Đặt trước qua hotline** rơi vào đúng một trong hai
nhánh trên, theo câu trả lời khách đã cho ở bước 2.

Hệ thống **không tự biết tiền đã về tài khoản** ở cả hai nhánh: mã VietQR là mã tĩnh, nên người
trao hàng phải tự nhìn tiền hoặc nhìn báo có rồi bấm xác nhận đã nhận tiền (§1.4).

#### 3.2.3 Đường đi của một đơn đặt trước qua hotline

Kênh này khác **Staff POS** ở chỗ đã nói tại §2.3 — nhân viên bấm ở cả hai, nhưng Staff POS luôn
gắn **một số bàn cụ thể** và đổ vào phiên bàn, còn khách gọi điện thì **chưa ngồi bàn nào** nên
đơn của họ là một đơn lẻ, tự nó là một đơn vị thanh toán. Nói cách khác: hai kênh này giống nhau ở
*ai bấm* và khác nhau ở **đơn vị tính tiền**, và đó là khác biệt quyết định: một bên tiền vào hoá
đơn của bàn, một bên tiền đứng riêng một mình. Khác biệt thứ hai đi kèm: đơn hotline **phải hỏi**
cách trao hàng và giờ (bước 2), đơn Staff POS thì không — khách đã ngồi ngay đó. Ghi đơn
`phone_preorder` thành `staff_pos` là **bug**, cách ghi ấy đã bị gỡ ngày 2026-08-29 (§2.3).

Trọn đường đi, từ lúc nhấc máy:

- *Khách* gọi hotline. *Người đứng quầy* nghe máy và **hỏi hai câu bắt buộc**: giao tận nơi hay
  tới lấy, cần hàng lúc mấy giờ (bước 2).
- *Người đứng quầy* nhập món hộ khách, kèm số điện thoại và giờ khách cần hàng; chọn giao tận nơi
  thì nhập thêm địa chỉ (§3.2.4).
- *Hệ thống* tính tổng tiền và tạo đơn. Đơn **không đi qua bước duyệt** — vào thẳng trạng thái
  **Đã xác nhận** (§2.2, bước 7).
- Bếp làm và *nhân viên quán* đóng gói như bước 8, không khác đơn của hai kênh kia một điểm nào.
- **Kết thúc kiểu thứ nhất — khách tới lấy:** *Khách* tới quán đúng giờ đã hẹn, *người đứng quầy*
  trao hàng và thu tiền tại quầy. Đơn **hoàn thành**.
- **Kết thúc kiểu thứ hai — quán giao:** đơn mang trạng thái **"đang giao"**, *nhân viên quán* đem
  tới địa chỉ khách, thu tiền tại chỗ, bấm **đã giao và đã thu tiền**. Đơn **hoàn thành**.
- **Khách đổi ý, tới quán ngồi ăn:** *người đứng quầy* **huỷ** đơn đặt trước và khách quét QR gọi
  lại như mọi khách ngồi bàn (§2.4). Không có đường nối đơn này vào một phiên bàn. Đơn đã trả
  trước thì việc huỷ sinh việc **hoàn tiền**, xử theo `shop-facts.md` §6.4.

#### 3.2.4 Thông tin liên hệ tối thiểu — theo kênh, và theo cách trao hàng

*Chủ quán chốt **2026-08-30** (`shop-facts.md` §6.5). Đây là dữ kiện **đã chốt**, không phải chỗ
suy ra: trước ngày đó hai trường bắt buộc mới chỉ là suy luận từ luồng (S-2, `shop-facts.md` §7.1).*

Ba câu, và cả ba là điều kiện để đơn được tạo ở bước 3:

- **Số điện thoại — bắt buộc với cả ba kênh.** Không có số thì không gọi lại được khi tới nơi hoặc
  khi cần hỏi lại. Đây là chỗ luồng mang đi khác hẳn luồng tại bàn: khách ngồi bàn **ẩn danh theo
  số bàn** (§2.1), khách mang đi thì không bao giờ ẩn danh.
- **Địa chỉ giao — bắt buộc khi giao tận nơi.** Tức: luôn bắt buộc với **Delivery**; với **Đặt
  trước qua hotline** thì bắt buộc **nếu** khách chọn giao tận nơi (câu trả lời ở bước 2). Với
  **Pickup** thì không cần — quán không đi đâu cả.
- **Giờ khách cần hàng — bắt buộc với Pickup và với Đặt trước qua hotline.** Pickup có **giờ hẹn
  lấy**; đơn hotline là đơn đặt trước nên cũng có mốc giờ. Với Delivery, giờ là trường **nên có**,
  không bắt buộc.

Danh sách trường đầy đủ — kể cả các trường "nên có" và "tuỳ tình huống" — ở `shop-facts.md` §6.5;
§2 của tài liệu này đã nói **đừng chép nó về đây**, và §3.2 không chép.

#### 3.2.5 Không phiên bàn, và mỗi đơn là một đơn vị thanh toán độc lập

Bốn câu dưới đây là luật (§5 quy tắc 8 của kế hoạch gốc · `shop-facts.md` §2, §5.2, §6.3, §6.9):

- **Đơn mang đi không thuộc phiên bàn nào.** Cả ba kênh, không có ngoại lệ. Không có đường nối một
  đơn Delivery, Pickup hay đặt trước qua hotline vào một phiên bàn — kể cả khi khách đổi ý và tới
  quán ngồi ăn; ca đó là **huỷ rồi gọi lại** (§2.4).
- **Mỗi đơn được thanh toán độc lập.** Hai đơn của **cùng một khách**, đặt cách nhau mười phút,
  vẫn là hai đơn vị tính tiền và hai lần thu tiền. Không có chỗ nào gộp chúng lại — cái gộp duy
  nhất trong sản phẩm này là phiên bàn, và ba kênh này không có phiên bàn.
- **Trả lúc trao hàng là đường mặc định; trả trước là tuỳ chọn của khách** (chủ quán chốt
  2026-08-30, `shop-facts.md` §6.3). Cả ba kênh mang đi đều được chọn trả trước, bằng đúng hai
  phương thức đang có — tiền mặt hoặc VietQR, không có phương thức thứ ba. **POS xác nhận đã nhận
  tiền vào lúc tiền thật sự tới tay quán**, không phải lúc khách bấm chọn "trả trước" (chủ quán
  chốt 2026-08-31, `shop-facts.md` §6.3): chọn trả trước là *ý định của khách*, còn *đã nhận tiền*
  chỉ do người bấm ở POS tạo ra. Khách ngồi bàn **không** có nhánh này (§1.1).
- **Suất "đem về" của khách đang ngồi bàn KHÔNG phải một đơn mang đi.** Nó thuộc **phiên bàn**
  đang mở, kèm note "đem về" (§2.1, §3.1.4). Chiều ngược lại cũng không tồn tại. Nhầm chỗ này là
  đếm tiền sai nguồn: `shop-facts.md` §6.9 buộc một khoản tiền gắn với đúng **một** đơn vị tính
  tiền, và báo cáo doanh thu phải cộng **cả hai** nguồn — phiên bàn và đơn lẻ.

#### 3.2.6 Khi nào quán không nhận đơn — giờ bán, và nút tạm dừng thắng giờ bán

Hai điều kiện, và đơn chỉ được tạo khi **cả hai** đều mở (§5 quy tắc 10 và 11 của kế hoạch gốc ·
`shop-facts.md` §1, §6.8):

- **Giờ bán: 06:00 – 11:00, tất cả các ngày**, múi giờ `Asia/Ho_Chi_Minh` (`shop-facts.md` §1).
  Ngoài khung giờ đó, web **khoá nút đặt** và khách nhìn thấy câu *"Quán mở cửa 6h–11h sáng"* —
  khách biết ngay vì sao không đặt được và khi nào quay lại được, chứ không gặp một nút bấm im
  lặng. Đơn gửi ngoài giờ bán **bị từ chối**, không xếp hàng chờ tới sáng hôm sau.
- **Nút "Tạm dừng nhận đơn" của chủ quán THẮNG giờ mở cửa** (`shop-facts.md` §6.8). Đang giữa giờ
  bán mà chủ quán bấm tạm dừng — thường là hết nguyên liệu giữa buổi — thì quán **vẫn không nhận
  đơn**. Ưu tiên chỉ chạy một chiều: nút tạm dừng chặn được giờ bán, còn giờ bán **không bao giờ**
  gỡ được nút tạm dừng — chỉ chủ quán tắt nó thì quán mới nhận đơn trở lại. Hai quy tắc này không
  ngang hàng nhau.
- **Đơn đã tạo trước đó không bị hai điều kiện này chạm tới.** Tạm dừng và hết giờ bán chặn *đơn
  mới*; đơn đã nhận vẫn được làm, đóng gói, giao và thu tiền bình thường.

**Phí ship 0đ, không có đơn tối thiểu, không có bậc phí ship theo khoảng cách.** Cả ba là **quyết
định đã chốt** của chủ quán (`shop-facts.md` §2, §6.12), không phải chỗ trống chờ ai điền: thêm
đơn tối thiểu hay bậc phí ship là **đổi phạm vi**, phải xin phép chủ quán.

Hai con số vừa nêu — giờ bán và phí ship — là **dữ kiện quán**, nhà của chúng là `shop-facts.md`
§1 và §2. Đây là chỗ **duy nhất** trong tài liệu này chép lại một con số của quán, và nó được chép
vì một câu kiểu *"theo giờ mở cửa của quán"* thì không ai kiểm được. Đổi giờ bán hay phí ship ⇒
sửa ở owner **và** sửa ở đây, trong cùng một lần đổi.

#### 3.2.7 Khác gì so với đơn tại bàn

Bảy điểm khác, lấy đúng danh sách của `shop-facts.md` §5.2 — **đây là danh sách đã biết tính tới
2026-08-30, không phải lời hứa là đã đủ**: gặp điểm khác thứ tám thì ghi thêm vào `shop-facts.md`
§5.2 trước, đừng tự đoán ở đây.

- **Phải có thông tin liên hệ** (§3.2.4). Luồng tại bàn ẩn danh theo số bàn.
- **Không có phiên bàn.** Mỗi đơn tự nó là một đơn vị thanh toán, không gộp với đơn nào khác, kể
  cả cùng một khách đặt hai lần (§3.2.5). Luồng tại bàn gộp mọi lượt gọi của một bàn vào **một**
  hoá đơn (§3.1.4).
- **Có bước đóng gói thay cho bước mang ra bàn, và không có bước dọn bàn.** Luồng tại bàn kết thúc
  ở bàn trống sau hai việc — đóng phiên và dọn bàn (§3.1.4); luồng mang đi kết thúc ngay khi trao
  hàng xong.
- **Nước chấm phải gói riêng.** Trạm **lấy canh** vẫn sinh việc cho mọi đơn mang đi, chỉ khác cách
  đưa (`shop-facts.md` §6.6).
- **Có hẹn giờ.** Pickup có giờ hẹn lấy, đơn hotline có mốc giờ khách cần hàng. Luồng tại bàn
  không có khái niệm hẹn giờ.
- **Thu tiền lúc trao hàng, và có thể thu ở ngoài quán** — đơn giao tận nơi thu ngay tại chỗ
  khách. Luồng tại bàn luôn thu ở quầy lúc đóng phiên. **Và chỉ luồng này có nhánh trả trước**
  (§3.2.5).
- **Chỉ đơn giao tận nơi có trạng thái "đang giao"** (§3.2.2), vì quán tự đi giao nên quầy phải
  biết đơn nào còn trên đường và ai đang cầm tiền chưa về.

#### 3.2.8 Ba việc lát cắt này cố ý không nói tới

- **Cách quán đi giao ngoài đường.** Ai cầm đơn nào, đi đường nào, giao mấy đơn một chuyến — quán
  tự sắp, sản phẩm chỉ giữ trạng thái "đang giao" và cho quầy nhìn thấy nó (§1.4).
- **Cách tính một mức phí ship khác 0đ.** Không có bậc, không có ngưỡng đơn tối thiểu; ranh giới
  này đã chốt (§3.2.6).
- **Vòng đời đầy đủ của đơn và tên từng trạng thái.** §3.2 chỉ dùng những trạng thái mà luồng này
  thật sự đi qua; bộ tên đầy đủ và các nhánh ngoại lệ là việc của §5 (BA-07) và §6 (BA-08).

### 3.3 Chủ quán đổi menu hoặc giá

*BA-05 — chốt 2026-09-01. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic C,
§5 quy tắc 5, 6, 7, §6 (Giá) + `master_plan/shop-facts.md` §4.1–§4.8, §6.12 (dữ kiện quán, chủ
quán chốt 2026-08-19 → 2026-08-31).*

Hai lát cắt trên tạo ra đơn; lát cắt này **không tạo đơn nào**. Nó chốt đúng một câu: khi chủ quán
sửa menu hoặc giá, cái gì đi theo cái mới và cái gì ở lại như cũ. Sai ở đây là sai **âm thầm** —
không có lỗi nào nổ ra, chỉ có số tiền của một bữa ăn đã bán bị đổi sau lưng.

Ranh giới chia hai phía là **thời điểm một lượt gọi được tạo**, không phải trạng thái nó đang ở
đâu (kế hoạch gốc §5 quy tắc 5 và 6): giá được xác định một lần, lúc lượt gọi ấy được tạo, và từ
đó không có thao tác nào của chủ quán chạm lại được vào nó.

**Bốn chiều đổi giá ở §3.3.2 chia làm hai nhóm, với hai mốc khác nhau** (chủ quán chốt 2026-09-01,
`shop-facts.md` §6.17): ba chiều **tiền** sửa được ngay giữa giờ bán; chiều thứ tư — **thành phần
của một suất** — phải chờ hết buổi bán. Nhớ §3.3 thành *"một mốc duy nhất"* là làm sai đúng chiều
đắt nhất.

#### 3.3.1 Luồng — bảy bước

Mỗi bước ghi rõ ai làm. Tên actor dùng đúng §1.

1. **Chủ quán mở phần quản trị.** *Chủ quán* — vai ở §1.3 — là người duy nhất sửa được menu và
   giá. Không trạm nào trong năm trạm ở §1.5 làm được việc này, kể cả quầy.
2. **Chủ quán sửa.** Một trong bốn chiều ở §3.3.2, hoặc **ngừng bán** một món (§3.3.4).
3. **Thay đổi có hiệu lực khi chủ quán lưu.** Không có lịch hẹn giờ, không có "áp dụng từ ngày
   mai". **Sửa giá thì lưu lúc nào cũng được, kể cả giữa giờ bán** — chủ quán không phải chờ hết
   buổi (chốt 2026-09-01, `shop-facts.md` §6.17). **Sửa thành phần một suất thì phải chờ hết
   buổi bán** (§3.3.2 chiều thứ tư).
4. **Menu khách nhìn thấy đổi theo, ở cả năm kênh** (§2). Một khách đang mở trang chọn món giữa
   chừng thì lần gửi đơn tiếp theo của khách đó đã đi theo bảng giá mới — vì giá không do khách
   gửi lên (`shop-facts.md` §4.6 quy tắc 9), *hệ thống* tự xác định lại lúc tạo đơn.
5. **Đơn tạo sau mốc đó dùng menu và giá mới.** Toàn bộ, cả bốn chiều.
6. **Đơn tạo trước mốc đó không đổi một chữ nào** — không đổi tên món, không đổi giá, không đổi
   thành phần bếp phải làm (§3.3.3).
7. **Việc đã xuống bếp không bị viết lại.** Đơn đã được duyệt thì việc ở các trạm đã nổ ra theo
   thành phần tại thời điểm ấy (§3.1.5, `shop-facts.md` §5.3); chủ quán sửa menu sau đó không làm
   phiếu đang treo ở bếp đổi nội dung.

#### 3.3.2 "Đổi giá" có bốn chiều, không phải một

Giá một suất bán **không** phải một con số nằm sẵn: nó là **tổng giá các thành phần** của suất
(`shop-facts.md` §4.6 quy tắc 1, bằng chứng ở §4.7). Nên chủ quán có bốn cách khác nhau để làm đổi
số tiền một khách phải trả:

| # | Chủ quán đổi | Nhà thật | **Sửa được lúc nào** | Đơn cũ phải giữ nguyên |
|---|---|---|---|---|
| 1 | Giá một **thành phần** (cái bánh, quả trứng, chiếc giò) | `shop-facts.md` §4.2 | **giữa giờ bán cũng được** | giá từng thành phần đã áp |
| 2 | Mức phụ thu **nhân** | `shop-facts.md` §4.4 | **giữa giờ bán cũng được** | mức phụ thu đã áp |
| 3 | Mức phụ thu **lượng nhân** | `shop-facts.md` §4.4 | **giữa giờ bán cũng được** | mức phụ thu đã áp |
| 4 | **Thành phần của một suất bán** | `shop-facts.md` §4.5 | **chỉ sau khi hết buổi bán** | suất đó gồm những gì, và bao nhiêu phần nhận nhân |

Bốn chiều, **một luật**: đơn cũ giữ nguyên cả bốn. Giữ ba chiều đầu mà quên chiều thứ tư thì đơn cũ
vẫn hỏng — và hỏng nặng hơn, vì lúc đó cả **tiền** lẫn **thứ bếp làm ra** đều sai.

Chiều thứ tư là chiều dễ quên nhất, và là chiều duy nhất **không** được làm giữa giờ bán (chủ quán
chốt 2026-09-01, `shop-facts.md` §6.17): nó đổi **thứ bếp phải làm ra**, mà bếp đang làm theo
**mẻ** (`shop-facts.md` §5.4) — sửa giữa chừng là hai suất cùng tên, cách nhau mười phút, có ruột
khác nhau. Đổi combo "Đầy đủ" từ ba cái bánh xuống hai là một thao tác duy
nhất của chủ quán, nhưng nó chạm **mọi** đơn combo đã bán: nếu suất trong đơn cũ được đọc lại theo
thành phần mới thì tổng tiền của những đơn ấy tụt xuống, và một hoá đơn đã thu tiền xong bỗng không
khớp với số tiền thật đã nhận — thứ đối soát cuối ngày (`shop-facts.md` §6.10) bắt được nhưng không
ai truy ra được lý do.

#### 3.3.3 Đơn cũ giữ nguyên tổng tiền — đây là câu chốt của lát cắt

**Một đơn đã tạo trước thời điểm đổi giá giữ nguyên tổng tiền của nó, mãi mãi.** Không có thao tác
nào của chủ quán — đổi giá, đổi phụ thu, đổi thành phần suất, ngừng bán món — làm đổi được số tiền
của một đơn đã có. Câu này áp cho mọi đơn của cả năm kênh (§2), và cho mọi phiên bàn đã đóng.

Một ví dụ để thấy con số nào đứng yên. **Ví dụ này là bản chép của `shop-facts.md` §4.2–§4.3, và
là chỗ duy nhất §3.3 có số; đổi giá thật thì sửa nhà thật trước, rồi sửa ví dụ này theo:**

> Sáng thứ Hai, khách đặt **một suất giò, nhân thịt, lượng thường** — 25.000, tức
> 9.000 (giò) + 4 × 4.000 (bốn cái bánh nhân thường). Trưa thứ Hai, chủ quán nâng **giá gốc của
> một cái bánh cuốn — tức ô *chay* của `shop-facts.md` §4.2 — từ 3.000 lên 4.000**; hai mức phụ
> thu nhân ở §4.4 **không đổi**, nên cái bánh nhân thường thành 5.000 và cái bánh nhiều nhân
> thành 6.000. Từ lúc lưu, một suất giò cùng loại đặt mới có giá **29.000** = 9.000 + 4 × 5.000.
> **Đơn sáng thứ Hai vẫn là 25.000** — mở lại nó ngày nào cũng thấy đúng con số đó.

**Vì sao ví dụ nói *"nâng giá chay"* chứ không nói *"nâng giá bánh nhân thường"*.** Giá một cái
bánh nhân thường **không phải một ô người ta sửa được**: nó là *giá gốc chay + phụ thu nhân*
(§4.1, `shop-facts.md` §4.6 luật 2). Câu *"nâng giá một cái bánh nhân thường lên 5.000"* vì thế có
**hai** đường đọc — sửa ô *Thịt thường* của bảng §4.2 ra 29.000, hay sửa giá gốc ra 25.000 — và
một trong hai đường còn **xoá mất bậc phụ thu lượng nhân** (*thường* và *nhiều nhân* cùng thành
5.000, trái `shop-facts.md` §4.4). Bản trên là thao tác **chỉ có một nghĩa**, ra đúng con số
29.000 đã chốt. `08-scenario.md` Scenario 3 bước 2 và `quality/invariants.md` **I-009** viết y hệt
câu này; ba chỗ phải đổi cùng một lượt (`work/findings.md` **F-022**).

Ba điều đơn cũ giữ, không chỉ một:

- **Tổng tiền**, và giá từng dòng đơn tạo ra tổng đó.
- **Tên món** đúng như lúc khách gọi, kể cả khi tên ấy đã bị đổi hoặc ngừng bán (§3.3.4).
- **Thành phần suất** đúng như lúc đặt — nghĩa là đọc lại một đơn combo cũ vẫn thấy đủ số bánh mà
  bếp đã thật sự làm ra hôm đó (`shop-facts.md` §4.5).

#### 3.3.4 Ngừng bán một món: biến khỏi menu, không biến khỏi đơn cũ

Chủ quán quyết món nào đang bán, món nào ngừng bán (§1.3). Ngừng bán là **quyền chủ quán**, và lát
cắt này chỉ mô tả **hệ quả** khi chủ quán làm việc đó — nó không mở đường cho ai khác làm. Chiều
ngược lại — **thêm một món ngoài bảng giá `shop-facts.md` §4.2 — là đổi phạm vi**, cũng là quyền
chủ quán và cũng không phải việc của lát cắt này (`shop-facts.md` §6.12).

Từ lúc chủ quán lưu:

- Món đó **không còn chọn được** ở bất kỳ kênh nào trong năm kênh của §2 — khách không thấy nó
  trên web, quầy không đặt hộ được nó trên POS.
- Đơn cũ có món đó **vẫn hiện đúng tên và đúng giá** đã bán. Không hiện thành "món đã xoá", không
  hiện giá trống, không biến mất khỏi hoá đơn.
- Báo cáo doanh thu của những ngày trước **không đổi một đồng nào** (`shop-facts.md` §6.9).

Ca xảy ra thật và dễ làm sai nhất: món bị ngừng bán khi trong quán còn một đơn của nó **chưa hoàn
thành**. Đơn ấy đi tiếp bình thường tới lúc trao hàng và thu tiền — nó đã được tạo trước mốc đổi,
nên §3.3.3 áp cho nó. Ngừng bán chặn đơn **mới**, không rút lại đơn **cũ**.

Món **hết giữa buổi** thì khác hẳn ca này: đó không phải chủ quán đổi menu mà là quán hết nguyên
liệu, và đường xử lý là **tạm dừng nhận đơn** (§1.3, `quality/invariants.md` I-008) hoặc nhánh ngoại lệ của §6 (BA-08 —
câu 3 của §10 kế hoạch gốc, còn mở).

#### 3.3.5 Tổ hợp không hợp lệ bị TỪ CHỐI, không được tự sửa thành hợp lệ

Nhóm **"Lượng nhân" chỉ tồn tại khi nhân khác Chay** (`shop-facts.md` §4.4). Nên tổ hợp
**Chay + Nhiều nhân là không hợp lệ**, và đường đi duy nhất của nó là **bị từ chối**
(`shop-facts.md` §4.6 quy tắc 3 · §4.8 ca 11 — ca duy nhất trong mười một ca có kết quả không phải
một con số).

**Từ chối, không phải sửa hộ.** Âm thầm bỏ tuỳ chọn thừa rồi cho đơn đi tiếp là đường sai: bếp nhận
một phiếu mâu thuẫn thì hỏng món, và khách trả tiền cho một thứ khác thứ mình bấm. Hệ thống nói
thẳng là tổ hợp đó không đặt được, để khách chọn lại.

Lát cắt này thêm một chiều thời gian cho luật ấy: chủ quán đổi menu **có thể làm một tổ hợp đang
hợp lệ trở thành không hợp lệ**. Từ lúc lưu, tổ hợp đó bị từ chối như mọi tổ hợp không hợp lệ khác
— nhưng **đơn cũ mang tổ hợp ấy không bị sửa lại và không bị đánh dấu hỏng**: nó hợp lệ tại thời
điểm nó được tạo, và §3.3.3 khoá nó lại ở đó.

#### 3.3.6 Đơn đang dở, và phiên bàn vắt qua thời điểm đổi

**Một lượt gọi đã tạo thì đã xong chuyện giá**, dù nó đang ở trạng thái nào — `Chờ xác nhận`, `Đang
thực hiện`, `Đang giao`, hay phiên của nó đang `Chờ thanh toán` (§5). Ranh giới là thời điểm **tạo lượt gọi**, không phải thời
điểm hoàn thành (kế hoạch gốc §5 quy tắc 5). Không có bước "xác nhận lại giá" nào cho đơn đang dở.

**Một phiên bàn đang mở vắt qua mốc đổi giá thì hoá đơn của nó mang hai mức giá — và như thế là
đúng** (chủ quán chốt 2026-09-01, `shop-facts.md` §6.17, trả lời U-015):

- Lượt gọi **trước** mốc giữ giá cũ; lượt gọi **sau** mốc áp giá mới. Cùng một món, cùng một bàn,
  hai con số khác nhau trên **một** hoá đơn.
- §3.1.4 và `quality/invariants.md` I-002 vẫn nguyên vẹn: một phiên vẫn sinh đúng **một** hoá đơn.
  Cái đổi không phải số hoá đơn, mà là cách đọc tổng của nó — nó cộng từ những lượt gọi có thể có
  giá khác nhau.
- **Phiên bàn không khoá giá theo lúc mở phiên.** Đây là đường chủ quán **không** chọn, ghi ra đây
  để không ai chọn lại nó sau này.
- **Càng không tính lại cả phiên theo giá mới lúc thanh toán.** Đó là sửa tiền của một thứ khách
  đã ăn xong, và nó phá thẳng §3.3.3.
- ⇒ **Đối soát cuối ngày đọc được chuyện này** (`shop-facts.md` §6.10): ngày nào chủ quán đổi giá
  giữa buổi thì cùng một món có hai giá đúng trong ngày ấy. Đó không phải một khoản lệch phải đi
  tìm lý do — lý do đã có tên sẵn, là lần đổi giá lúc mấy giờ.

**Luật *"đổi thành phần suất phải chờ hết buổi"* là luật cho NGƯỜI, không phải hàng rào của máy**
(chủ quán chốt 2026-09-01, `shop-facts.md` §6.17, trả lời U-018). Chủ quán bấm sửa thành phần lúc
9h sáng thì máy **nhắc một câu** — đang trong giờ bán, luật là chờ hết buổi — rồi **vẫn cho lưu**.
Chủ quán giữ quyền tự phá luật của chính mình, và đó là quyết định, không phải chỗ chưa làm xong.

⇒ Hệ quả phải nói thẳng, vì nó đổi cách đọc cả §3.3.2: **sản phẩm không bảo đảm rằng thành phần
suất đứng yên trong giờ bán.** Nó chỉ bảo đảm chuyện đó không xảy ra **âm thầm** — có lời nhắc
trước, và có vết đọc được sau, đủ để đối soát cuối ngày tìm ra (`shop-facts.md` §6.10).
`quality/invariants.md` **I-011** được viết đúng theo ranh giới đó.

#### 3.3.7 Ba việc lát cắt này cố ý không nói tới

- **Cách máy giữ được lịch sử giá.** §3.3 chốt **kết quả nghiệp vụ phải luôn đúng** — mở một đơn cũ
  ra thì thấy đúng số tiền đã bán. Làm cách nào để điều đó luôn đúng là việc của thiết kế hệ thống
  (`docs/product/1-system-design/architecture.md`), không phải của tài liệu sản phẩm.
- **Thêm món mới, hoặc đổi bảng giá thành một cấu trúc khác.** Thêm món ngoài `shop-facts.md` §4.2
  là **đổi phạm vi**, quyền chủ quán (`shop-facts.md` §6.12).
- **Ai được xem lại lịch sử đổi giá, và xem ở đâu.** Mọi thao tác chạm tiền đều phải kiểm chứng lại
  được (§1.4), nhưng màn hình nào bày ra việc đó là câu của §7 (BA-09).


### 3.4 Quán làm theo MẺ — trục sản xuất cắt ngang mọi bàn và mọi đơn

*BA-12 — chốt 2026-09-03. Nguồn: `master_plan/shop-facts.md` §5.4 (bếp làm theo mẻ, bốn con số,
danh sách quầy phải nhìn), §5.3 (một dòng đơn nổ ra thành phần nào), §4.5 (thành phần một suất),
§3 (năm trạm), §7.2 (**S-5** — chỗ suy ra chưa xác nhận) + `docs/decisions.md` **ADR-009** (bốn
khái niệm của trục này). Dữ kiện quán do chủ quán chốt 2026-08-31 → 2026-09-01.*

Ba mục trên kể chuyện **một** bàn (§3.1), **một** đơn (§3.2), hoặc **một** lần chủ quán sửa
menu (§3.3). Lát cắt này kể thứ không thuộc bàn nào và không thuộc đơn nào: con số quán thật sự
dùng để chạy bếp — *"còn phải làm bao nhiêu cái bánh"* — **cộng ngang qua mọi bàn và mọi đơn đang
mở**. Nó không có chỗ đứng trong ba lát cắt kia, và đó là lý do nó là lát cắt thứ tư
(`docs/decisions.md` **ADR-009**).

**Đây là cách quán đang chạy hôm nay, không phải một tính năng thêm vào.** Bếp gom việc theo mẻ vì
làm lần lượt từng suất là *mất thời gian và mất nhiệt* — lời chủ quán ngày 2026-08-31
(`shop-facts.md` §5.4). Một thiết kế bắt bếp nhận việc theo từng suất một là thiết kế bắt quán
chạy **chậm hơn** cách đang làm bằng tay; đó là hỏng nặng hơn thiếu một tính năng.

Lát cắt này **không** thay trục đơn. Đơn vẫn có vòng đời của nó (§5) và việc trạm vẫn có vòng đời
của nó (§5.4 của `05-vong-doi.md`); §3.4 nói **hai trục gặp nhau ở đâu** (§3.4.5) và **con số nào
tồn tại** ở trục sản xuất.

#### 3.4.1 Bốn khái niệm — mỗi cái một đơn vị, mỗi cái một câu hỏi

Bốn khái niệm của **ADR-009**. Chúng **không** thay nhau được: mất một cái là mất một câu hỏi
không còn ai trả lời.

| Khái niệm | Đơn vị của nó | Câu nó trả lời |
|---|---|---|
| **Nhu cầu** | một **thành phần** + loại nhân + lượng nhân | quán **còn phải làm** tổng cộng bao nhiêu |
| **Mẻ** | một **lần bếp làm** | lần này làm mấy cái, bằng thiết bị nào |
| **Đã làm xong** | một **thành phần** | bếp **đã làm ra** bao nhiêu |
| **Đã phục vụ** | một **thành phần**, gắn **một bàn** | khách **đã nhận** bao nhiêu |

Đơn vị của *nhu cầu* và *đã làm xong* là **thành phần**, không phải suất bán: khách trả tiền theo
suất, bếp làm theo thành phần, và một suất nổ ra nhiều thành phần (§3.1.5, `shop-facts.md` §4.5,
§5.3). Chỉ *đã phục vụ* mới bắt buộc gắn **một bàn** — vì bưng là bưng tới một chỗ.

#### 3.4.2 Bốn con số trên bảng ở quầy, và hai chữ "còn" khác nhau

`shop-facts.md` §5.4 chốt bảng ở quầy có **bốn** con số, đếm được tới 2026-09-01. Con số thứ tư
được chính chủ quán xác nhận ngày **2026-09-01** (trả lời **S-4**): bánh gấp xong **có** nằm chờ
trước khi ra bàn — *chờ đủ đĩa*, *chờ người rảnh tay bưng*, *chờ món khác của cùng bàn*.

| Con số ở quầy | Nghĩa | Nguồn |
|---|---|---|
| **Khách đã gọi** | tổng thành phần nổ ra từ các dòng đơn | chủ quán, 2026-08-31 |
| **Đã làm xong, còn ở bếp** | bếp làm ra rồi nhưng chưa bưng ra | chủ quán, **2026-09-01** (S-4) |
| **Đã bưng ra bàn** | đã tới tay khách | chủ quán, 2026-08-31 |
| **Còn thiếu** | khách đã gọi − đã bưng ra bàn | chủ quán, 2026-08-31 |

Bốn con số ấy **không** phải bốn khái niệm ở §3.4.1 đổi tên. Chúng khớp nhau qua ba trạng thái của
một việc trạm — `Chưa làm` → `Đã làm xong, còn ở bếp` → `Đã ra bàn` (§5.4 của `05-vong-doi.md`) —
và chỗ khớp ấy làm lộ ra **hai chữ "còn" khác nhau**, đây là chỗ dễ nhớ nhầm nhất của cả §3.4:

- **Còn thiếu** — thứ **khách chưa nhận** = `Chưa làm` + `Đã làm xong, còn ở bếp`.
  Đây là con số của **người bưng**, và là con số §5.4 định nghĩa.
- **Nhu cầu**, tức *còn phải làm* — thứ **bếp chưa làm** = `Chưa làm`.
  Đây là con số của **bếp**, và nó là khái niệm ở §3.4.1.

Hai con số ấy lệch nhau **đúng bằng** con số thứ hai của bảng. Gộp chúng làm một là quay về bảng
**ba** con số, tức xoá đúng cái khoảng nằm chờ mà chủ quán đã xác nhận là có thật — và hậu quả
đọc được ngay ở quầy: bếp bị giục làm lại một cái bánh **đang nằm chờ đủ đĩa**.

*Cách đọc, không phải lời chủ quán nói thẳng:* ba gạch đầu dòng trên là phép cộng của người viết
tài liệu trên hai thứ đã chốt — bảng bốn con số (`shop-facts.md` §5.4) và ba trạng thái của việc
trạm (§5.4 của `05-vong-doi.md`). Chủ quán chốt **bốn con số** và **ba lý do nằm chờ**; chủ quán
không đọc ra phép trừ nào.

#### 3.4.3 Nhu cầu cộng ngang qua nhiều bàn và nhiều đơn

**Sáu bàn mỗi bàn một suất giống nhau là MỘT dòng nhu cầu, không phải sáu.** Đây là lý do trục này
tồn tại: con số *"còn phải làm mười tám cái bánh"* không thuộc đơn nào cả.

Ví dụ — sáu bàn cùng gọi **một combo "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**. Một combo
gồm ba cái bánh cuốn, một quả trứng và một chiếc giò (`shop-facts.md` §4.5):

```text
Sáu đơn, sáu bàn: bàn 1 · bàn 4 · bàn 5 · bàn 7 · bàn 8 · bàn 9

Nhu cầu — SÁU dòng, gom từ ba mươi sáu việc rời:
  tráng bánh │ Bánh cuốn — thịt + mộc nhĩ, nhiều nhân   │ mười tám
  tráng bánh │ Trứng tái — thịt + mộc nhĩ, nhiều nhân   │ sáu
  gấp bánh   │ Bánh cuốn — thịt + mộc nhĩ, nhiều nhân   │ mười tám
  gấp bánh   │ Trứng tái                                │ sáu
  gấp bánh   │ Giò                                      │ sáu
  lấy canh   │ Nước chấm                                │ sáu
```

Ba điều phải đọc kèm ví dụ:

- **Bánh cuốn ra mười tám, không phải sáu.** Hoá đơn của mỗi bàn ghi *một* combo; bếp phải tráng
  **ba** cái bánh cho mỗi combo ấy. Ai đọc con số trên hoá đơn rồi tráng theo là làm thiếu
  (§3.1.5, `shop-facts.md` §5.3).
- **Một cái bánh sinh việc ở HAI trạm** — tráng rồi mới gấp — nên cùng một con số mười tám có mặt
  ở cả dòng *tráng bánh* lẫn dòng *gấp bánh*, đúng hình dạng ví dụ ở §3.1.5 và `shop-facts.md`
  §5.3. Đó **không** phải đếm hai lần: hai dòng ấy là hai việc khác nhau trên cùng số bánh, và
  chúng không cộng vào nhau. Trứng cũng đi qua hai trạm như vậy.
- **Nước chấm không nhân lên theo suất.** Nó là việc **cấp đơn**: mỗi đơn đúng một việc cho trạm
  *lấy canh* (`shop-facts.md` §6.6). Sáu đơn ⇒ sáu việc, và một bàn gọi ba suất trong **một** lượt
  gọi vẫn chỉ sinh **một** việc nước chấm.
- **Dòng giò không kèm mô tả nhân**, vì giò không nhận nhân (`shop-facts.md` §4.6 quy tắc 6).

Nhu cầu cộng ngang cả **nhiều đơn của cùng một bàn**: một bàn gọi thêm ba lượt trong một phiên thì
ba lượt ấy nhập vào cùng những dòng nhu cầu trên, không thành ba bảng riêng.

#### 3.4.4 Gom nhưng KHÔNG mất chủ sở hữu — mọi tổng phải tách ngược về từng bàn

**Mọi con số tổng ở §3.4.3 phải tách ngược về được: bàn nào bao nhiêu.** Một bảng chỉ có tổng là
một bảng chưa đạt — gom sáu quả trứng mà không biết chúng của sáu bàn nào là **bưng nhầm bàn**
(`shop-facts.md` §5.4).

Tách ngược đúng ví dụ trên:

```text
  tráng bánh │ Bánh cuốn — thịt + mộc nhĩ… │ mười tám │ bàn 1: ba · bàn 4: ba · bàn 5: ba
             │                            │          │ bàn 7: ba · bàn 8: ba · bàn 9: ba
  tráng bánh │ Trứng tái — thịt + mộc nhĩ… │ sáu      │ mỗi bàn: một
  gấp bánh   │ Bánh cuốn — thịt + mộc nhĩ… │ mười tám │ như dòng tráng bánh: mỗi bàn ba
  gấp bánh   │ Trứng tái                   │ sáu      │ mỗi bàn: một
  gấp bánh   │ Giò                         │ sáu      │ mỗi bàn: một
  lấy canh   │ Nước chấm                   │ sáu      │ mỗi bàn: một
```

Cộng xuôi và tách ngược phải **khớp cả hai chiều**: sáu bàn × ba cái bánh = mười tám, và mười tám
chia hết về sáu bàn không dư một cái nào. Chiều nào hụt là bảng sai, không phải bếp sai.

Hai chỗ đáng nói vì chúng **không** phá luật này:

- **Ghép bàn không đổi gì ở đây.** Việc xuống bếp luôn ghi **bàn nào gọi**, không ghi "nhóm"
  (§3.1.7) — nhóm ghép là chuyện của **tiền**, không phải của bếp. Nên một nhóm ghép hai bàn vẫn
  tách ngược thành **hai** dòng bàn.
- **Suất *đem về* của khách đang ngồi bàn vẫn thuộc bàn ấy** (§3.1.4, `shop-facts.md` §5.4) — nên
  nó **vẫn nằm** trên bảng gom việc theo bàn, và note *đem về* phải đọc ra ngay được: bếp và người
  bưng cần biết suất nào gói lại, suất nào ăn tại chỗ.

#### 3.4.5 Hai trục gặp nhau ở đâu — đơn nhập vào nhu cầu, và rút khỏi nhu cầu

- **Đơn `Đã xác nhận` mới nhập vào nhu cầu.** Đơn ở `Mới` hay `Chờ xác nhận` **không** sinh một
  việc nào ở cả năm trạm, nên nó **không** có mặt trên bảng gom việc (`shop-facts.md` §6.2, §5
  của `05-vong-doi.md`, `quality/invariants.md` I-004). Đơn khách tự gửi mà quầy chưa duyệt thì
  bếp chưa thấy nó.
- **Đơn `Huỷ` rút khỏi nhu cầu.** Mọi việc **chưa làm** của đơn ấy rời bảng cùng một lúc; không ai
  đứng ở trạm huỷ được một việc, quyền huỷ chỉ ở quầy và nó là quyền huỷ **đơn**
  (`shop-facts.md` §6.13, §5.4 của `05-vong-doi.md`).
- **Phần đã làm xong của một đơn bị huỷ thì rời bảng theo bàn, và nó KHÔNG biến mất khỏi cái
  quán.** Cái đĩa bánh ấy có thật, đang nằm ở bếp. Bảng theo bàn hết chỗ ghi nó, vì bàn đã gọi nó
  không còn gọi nữa. **Nó có được tính vào phần đã làm của một bàn khác hay không thì chưa ai
  hỏi chủ quán — `docs/product/99-unknowns.md` U-033.** §3.4 chọn phương án **hẹp nhất**: con số
  *đã làm xong* của **bàn bị huỷ** về không, và nhu cầu của **mọi bàn khác không đổi một đơn vị
  nào**. Nghĩa là ở bản hẹp này, quán làm lại từ đầu cho bàn khác — đúng thứ quán có thể đang
  **không** làm, nên đừng ghi nó thành luật đã chốt.
- **Ba kênh không gắn bàn KHÔNG đổ vào bảng này.** Chủ quán trả lời thẳng **không** ngày 2026-08-31
  (đóng **U-010**, `shop-facts.md` §5.4): bảng gom việc ở quầy là bảng **theo bàn**, còn
  `delivery`, `pickup`, `phone_preorder` (§2, §3.2) thì không. Việc của chúng vẫn nổ ra thành phần
  như mọi đơn và vẫn có vòng đời việc trạm — chỗ chúng **không** có mặt là cái bảng theo bàn.
- **`Hoàn thành` của một đơn đọc từ trục việc trạm, không đọc từ bảng tổng.** Đơn chỉ `Hoàn thành`
  khi **mọi** việc trạm của nó đã ở `Đã ra bàn`, kể cả nước chấm (§5.5 của `05-vong-doi.md`). Một
  con số tổng bằng không **không** phải lời tuyên bố đơn nào đã xong: tổng bằng không nghĩa là
  không còn gì phải làm, không nghĩa là mọi thứ đã ra bàn.

#### 3.4.6 Gom theo đúng thứ khách chọn — hai dòng cùng tên không gộp được

**Loại nhân và lượng nhân đi theo từng thành phần** (`shop-facts.md` §4.5, §5.4), nên khoá gom
một dòng nhu cầu là **thành phần + loại nhân + lượng nhân**, đúng đơn vị ở §3.4.1:

- **Trứng gom theo từng loại** — chín, tái, vàng. Không có con số "trứng" chung.
- **Bánh gom theo nhân và lượng nhân.** Hai cái bánh cùng tên khác lượng nhân là **hai** dòng.
- **Thành phần không nhận nhân thì gom theo tên trần** — chiếc giò gộp được với mọi chiếc giò khác.

Thêm **bàn 10** vào ví dụ §3.4.3, gọi một combo **"Đầy đủ trứng chín", thịt, lượng thường**
(trích dòng của trạm *tráng bánh* và hai dòng gộp; dòng của trạm *gấp bánh* đi theo y hệt):

```text
  tráng bánh │ Bánh cuốn — thịt + mộc nhĩ, nhiều nhân │ mười tám  ← sáu bàn cũ
  tráng bánh │ Bánh cuốn — thịt, thường               │ ba        ← bàn 10, KHÔNG gộp lên dòng trên
  tráng bánh │ Trứng tái — thịt + mộc nhĩ, nhiều nhân │ sáu       ← sáu bàn cũ
  tráng bánh │ Trứng chín — thịt, thường              │ một       ← bàn 10, KHÔNG gộp: khác LOẠI trứng
  gấp bánh   │ Giò                                    │ bảy       ← GỘP: giò không nhận nhân
  lấy canh   │ Nước chấm                              │ bảy       ← GỘP: việc cấp đơn, bảy đơn
```

Đọc ví dụ này theo hai chiều thì thấy trọn luật: hai dòng bánh **không** gộp dù cùng tên món, vì
khác nhân — trong khi dòng giò **có** gộp, vì giò không nhận nhân. Cùng một bảng, cùng một lúc.

**Vì sao không được gộp cho gọn.** Bếp nhận một dòng *"Bánh cuốn — hai mươi mốt"* thì tráng đủ số
và **sai ruột**: sáu bàn kia đã gọi bánh **nhiều nhân** còn bàn 10 gọi bánh **nhân thường**, nên
một dòng gộp không cho ai biết cái bánh vừa tráng là của ai — và không ai biết đã hỏng ở đâu cho
tới lúc khách nói. Gộp là **mất thông tin khách đã chọn**, không phải làm gọn bảng.

#### 3.4.7 Sáu thứ người đứng quầy phải nhìn được cùng một lúc

Chủ quán liệt kê ngày **2026-08-31**, đếm được **sáu** tính tới ngày đó (`shop-facts.md` §5.4).
Sáu là **phép đếm của người viết tài liệu**, không phải một ranh giới chủ quán chốt — thấy thứ thứ
bảy thì thêm dòng, ở nhà thật trước rồi ở đây.

1. **Tổng còn phải làm, tách theo từng thành phần** — bánh cuốn · trứng theo từng loại · giò ·
   nước chấm, kèm loại nhân và lượng nhân (đúng khoá gom ở §3.4.6).
2. **Số ấy chia cho bàn nào** — tách ngược theo §3.4.4.
3. **Bàn nào đang ăn, bàn nào đang chờ món.**
4. **Mỗi bàn đã được phục vụ bao nhiêu.**
5. **Mỗi bàn còn thiếu gì** — chữ *còn thiếu* ở đây là con số của người bưng, không phải nhu cầu
   của bếp (§3.4.2).
6. **Hiện tại quán đang thế nào** — bao nhiêu bàn chờ, bao nhiêu bàn đang phục vụ.

Chủ quán mô tả sáu dòng ấy là **một** thứ: *"tôi cần nắm được hiện tại quán thế nào"*. Chúng là
sáu phần của cùng một cái nhìn, **không** phải sáu màn hình — và §3.4 nói *phải nhìn được*, không
nói *nằm ở góc nào* (§3.4.9).

Một thứ §3.4 **không** nói được, và biết trước là không nói được: **bao giờ xong.** Năng lực một
mẻ có giới hạn và **trứng với bánh tranh nhau cùng một cái nồi** — con số ở `shop-facts.md` §5.4,
tra ở đó, §3.4 không chép về (chủ quán chốt 2026-08-31, đóng **U-008**). Nhưng máy **không** xếp
nồi (§3.4.8), nên không có chỗ nào trong sản phẩm suy ra được thời điểm một mẻ xong. Bảng ở quầy
trả lời *còn phải làm bao nhiêu*, không trả lời *còn mấy phút*.

#### 3.4.8 Ai làm con số thay đổi — và ranh giới "máy không gom, người gom"

**Máy chỉ bày ra các con số; người gom.** Chủ quán chốt 2026-08-31 (đóng **U-011**): *"máy không
làm, để người làm"*. Hệ thống **không** tự chia mẻ, **không** tự xếp nồi, **không** tự quyết thứ
tự làm và **không** đề xuất mẻ. Ai gom, gom mấy quả, làm trước làm sau là quyết định của người ở
bếp và ở quầy. Đây là một **ranh giới đã chốt** (`shop-facts.md` §6.12): cho máy chia mẻ là đổi
phạm vi, phải xin phép chủ quán.

Con số chỉ thay đổi khi có người bấm, và cả hai mốc đều bấm ở **quầy**, trên POS:

| Mốc | Đơn vị bấm | Ai bấm | Chốt ngày |
|---|---|---|---|
| **đã làm xong** | **một mẻ** | người đứng quầy | 2026-09-01 (U-017) |
| **đã bưng ra bàn** | *chưa chốt* — xem dưới | người đứng quầy | 2026-09-01 (U-021) |

- **Ba trạm bếp không bấm gì** — chủ quán bỏ mọi nút bấm ở trạm bếp ngày 2026-08-31 (đóng
  **U-009**). Người tráng bánh, người gấp bánh và người lấy canh không nhận thêm một thao tác nào.
  Luật ấy là luật về **bếp**; nút ở **quầy** không phá nó.
- **Mẻ là đơn vị bấm, bàn là đơn vị đếm** (chủ quán chốt 2026-09-01, trả lời **U-017**). Một lần
  bấm *"đã làm xong"* đẩy nhiều việc — có khi của nhiều bàn — sang `Đã làm xong, còn ở bếp` cùng
  lúc. ⇒ Con số ở quầy **nhảy theo bậc**, cả mẻ một lần; đó là đúng, không phải lỗi đếm. Và một
  lần bấm ấy **phải chia được** về từng bàn (§3.4.4).
- **Đơn vị bấm của *đã bưng ra bàn* thì chưa ai hỏi chủ quán.** Chỗ suy ra là **S-5**
  (`shop-facts.md` §7.2): *suy ra* là theo **bàn**, không theo mẻ — một mẻ phục vụ nhiều bàn, còn
  bưng thì bưng tới **một** bàn. Chủ quán mới chỉ nói **ai** bấm, chưa nói **theo gì**. §3.4 để
  nguyên chỗ ấy là suy ra: **đừng đọc nó thành lời chủ quán**, và đừng dựng bảng quầy như thể câu
  ấy đã chốt.
- **Bấm nhầm thì lùi được, và không có mốc thời gian cứng** (chủ quán chốt 2026-09-01, trả lời
  **U-024**): *"có đường lui, thời gian tuỳ theo thực tế để POS quyết định"*. Không có "trong vòng
  N phút" — người đứng quầy nhìn tình huống thật rồi quyết, cùng một kiểu với quyền hoàn tiền
  (§4.8). ⇒ **Vì không có luật cứng nên mỗi lần lùi phải để lại vết**: lùi mẻ nào, lúc mấy giờ, ai
  bấm (`quality/invariants.md` I-012, I-018).
- ⇒ **Quầy nay gánh cả hai mốc của mỗi suất.** Đó là rủi ro vận hành thật, không phải chi tiết
  trình bày: quầy là đôi tay bận nhất quán, thêm một nút là thêm một chỗ quên bấm
  (`shop-facts.md` §5.4).
- **Với đơn giao tận nơi, ai bấm mốc *đã ra bàn* thì đang mở** — **U-031**
  (`docs/product/99-unknowns.md`). Lúc suất tới tay khách, người có mặt là *nhân viên quán* đi
  giao, trong khi bảng ở §5.4 của `05-vong-doi.md` ghi *người đứng quầy*. §3.4 **không** chọn phe:
  chọn sai là đơn giao **không bao giờ** `Hoàn thành` được (§5.5 của `05-vong-doi.md`), hoặc quầy
  bấm khống một mốc cho một suất đang ở nhà khách.

#### 3.4.9 Bốn việc lát cắt này cố ý không nói tới

- **Bảng ở quầy trông thế nào.** §3.4 nói **con số nào phải nhìn thấy được**, không nói nó nằm ở
  góc nào, mấy cột, màu gì. Màn hình là việc của pha thiết kế hệ thống
  (`docs/product/1-system-design/architecture.md`) và của §7 (phạm vi).
- **Tên trạng thái kỹ thuật, tên bảng dữ liệu, đường dẫn.** Trạng thái ở tài liệu này luôn là một
  cụm tiếng Việt đọc được thành câu (§5.1 của `05-vong-doi.md`).
- **Con số năng lực của hai cái nồi.** Nó ở `shop-facts.md` §5.4 và chỉ ở đó — §3.4 trỏ sang, không
  mang về (`work/findings.md` **F-001**). Cần một tổ hợp nồi thứ tư thì **hỏi chủ quán**, đừng quy
  ba tổ hợp đã chốt về một đơn vị chung.
- **Cấu trúc thư mục và mô hình dữ liệu của `work/proposals/admin.admiadmin/admin1.md`.** Đề xuất
  ấy có sẵn cả màn hình, cả cây trạng thái, cả mô hình dữ liệu; **không** thứ nào được nhận —
  `work/proposals/` không sở hữu dữ kiện nào (ADR-009). Lấy được từ nó đúng một thứ: cách đặt
  câu hỏi.

[↑ đầu file](#top)
