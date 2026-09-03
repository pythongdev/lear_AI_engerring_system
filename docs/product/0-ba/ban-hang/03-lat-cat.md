# §3 — Ba lát cắt nghiệp vụ

> Nguyên văn `docs/product.md` §3, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §3: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §3, tách 2026-09-02 ==== -->
## 3. Ba lát cắt nghiệp vụ

> **Quyết định gốc của mục này:** → **ADR-027** (§3.1.7 ghép bàn = một phiên, một hoá đơn) ·
> **ADR-019** (§3.1.6 cho nợ, doanh thu tính ngày ghi nợ) · **ADR-029** (§3.1.4 suất *đem về* của
> khách ngồi bàn) · **ADR-023** (§3.3 đổi giá giữa buổi, thành phần suất chờ hết buổi) ·
> **ADR-021** (§3.2 luồng mang đi) · **ADR-009** (§3.4 — trục mẻ, BA-12 chưa viết).

Ba lát cắt chạy được từ đầu đến cuối, mỗi lát do một task BA chốt: một suất tại bàn (§3.1) · một
đơn mang đi (§3.2) · chủ quán đổi menu hoặc giá (§3.3). Hai luồng bán của quán ở
`master_plan/shop-facts.md` §5; năm kênh ở §2 trên đây rơi vào đúng một trong hai luồng ấy.

### 3.1 Một suất tại bàn

*BA-03 — chốt 2026-08-31. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic A,
§4.1 (mười lăm bước), §4.3 (đặt hộ tại quầy), §5 quy tắc 1–4 và 9 + `master_plan/shop-facts.md`
§2, §3, §4.5, §5.1, §5.3, §6.1, §6.2, §6.6 (dữ kiện quán, chủ quán chốt 2026-08-19 → 2026-08-30).*

Lát cắt này đi trọn một vòng: từ lúc một bàn được mở tới lúc chính bàn ấy trở lại trạng thái trống.
Hai kênh gắn phiên bàn ở §2.1 — **QR tại bàn** và **Staff POS** — đều chạy trong lát cắt này và đổ
vào cùng một phiên.

#### 3.1.1 Luồng chính — mười lăm bước

Mỗi bước ghi rõ ai làm. Tên actor dùng đúng §1, tên trạm dùng đúng năm tên ở §1.5.

1. **Bàn được mở.** *Khách* ngồi vào một bàn đang trống. *Hệ thống* mở cho bàn đó **một** phiên
   bàn, trạng thái **Mở**. Bàn nào còn một phiên chưa thanh toán thì không mở phiên thứ hai
   (§3.1.4). Nhóm đông ngồi **ghép** hai bàn thì vẫn là **một** phiên, gắn cả hai bàn (§3.1.7).
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
> 9.000 (giò) + 4 × 4.000 (bốn cái bánh nhân thường). Trưa thứ Hai, chủ quán nâng giá một cái bánh
> nhân thường lên 5.000. Từ lúc lưu, một suất giò cùng loại đặt mới có giá 29.000.
> **Đơn sáng thứ Hai vẫn là 25.000** — mở lại nó ngày nào cũng thấy đúng con số đó.

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

