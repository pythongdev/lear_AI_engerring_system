# §5 — Vòng đời nghiệp vụ

> Nguyên văn `docs/product.md` §5, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §5: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §5, tách 2026-09-02 ==== -->
## 5. Vòng đời nghiệp vụ

> **Quyết định gốc của mục này:** → **ADR-017** (§5.2 sửa và huỷ không bị chặn bởi trạng thái;
> dòng `Hoàn thành → Huỷ`) · **ADR-026** (§5.4 bỏ `Đang làm`, giữ `Đã làm xong, còn ở bếp`, và
> đường lùi một mẻ) · **ADR-027** (§5.3 phiên bàn gắn nhiều bàn) · **ADR-016** (ai bấm mỗi mốc).

*BA-07 — chốt 2026-09-01. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §7 (ba vòng
đời), §5 quy tắc 1, 4, 9, 12 + `master_plan/shop-facts.md` §3, §5.3, §5.4, §6.1, §6.2, §6.6, §6.7,
§6.13, §6.14, §6.16 (dữ kiện quán, chủ quán chốt 2026-08-19 → 2026-09-01).*

Ba vòng đời, ba bảng: **đơn** (§5.2) · **phiên bàn và cái bàn của nó** (§5.3) · **công việc trạm**
(§5.4). §3 kể ba lát cắt chạy từ đầu đến cuối; mục này rút ra bộ **tên trạng thái** mà cả ba lát
cắt dùng chung, và nói ai được đẩy cái gì đi đâu.

Sai ở đây không lộ ra lúc viết tài liệu, nó lộ ra giữa giờ cao điểm: một cái bàn kẹt ở trạng thái
không ai gỡ được, hoặc một đơn nằm mãi trong bếp mà bảng ở quầy vẫn báo xong.

<a id="cach-doc-5"></a>
### 5.1 Cách đọc ba bảng dưới đây

- **Mỗi dòng là một chuyển tiếp**, gồm bốn thứ: trạng thái nguồn · sự kiện · trạng thái đích · ai
  kích hoạt. Cột *ai kích hoạt* dùng đúng tên vai của §1 và tên trạm của §1.5.
- **Chuyển tiếp không có trong bảng là không hợp lệ và bị TỪ CHỐI.** Không có đường tắt, không có
  chuyển tiếp "ngầm hiểu là được". Ba ca đáng gọi tên vì chúng nghe như có lý mà không có trong
  bảng, ở §5.5. `quality/invariants.md` **I-016** giữ luật này.
- **Tên trạng thái viết hoa chữ đầu ở mục này** — `Chờ thanh toán`. §3 và §4 viết thường trong văn
  xuôi (*chờ thanh toán*): **cùng một trạng thái**, khác nhau ở cách trình bày, không phải hai thứ.
- **Không có tên kiểu mã.** Trạng thái ở đây luôn là một cụm tiếng Việt đọc được thành câu — không
  có hằng viết hoa nối bằng gạch dưới, không có trạng thái viết thành một con số. Tên máy, kiểu dữ
  liệu và chỗ lưu là việc của `docs/architecture.md`. *(Mục này cố ý không viết ra một ví dụ kiểu
  mã: `work/backlog.md` → BA-07 dò đúng hình dạng ấy bằng `grep`, và một ví dụ nêu ra để cấm cũng
  làm phép dò kêu.)*
- **BA-07 đổi tên hai trạng thái ở §3, đổi tên chứ không đổi nghĩa:** *chờ duyệt* → **Chờ xác
  nhận**, *đã duyệt* → **Đã xác nhận**. Động từ **duyệt** giữ nguyên — người đứng quầy vẫn *duyệt*
  đơn, chỉ có tên trạng thái là lấy theo kế hoạch gốc §7.
- **"Phiên chưa đóng" là một cách gọi gộp, không phải một trạng thái.** Nó phủ cả ba trạng thái
  `Mở` · `Đang phục vụ` · `Chờ thanh toán` — tức mọi phiên chưa tới `Đã đóng`. §3.1.4, §3.1.7 và
  `quality/invariants.md` I-001 dùng chữ *"phiên đang mở"* theo đúng nghĩa gộp này.

### 5.2 Vòng đời ĐƠN

**Bắt đầu:** `Mới`. **Kết thúc:** `Huỷ` — và `Hoàn thành`, **trạng thái kết thúc duy nhất còn
đường đi tiếp**. Không có đường ra thứ ba.

⚠ **`Hoàn thành` KHÔNG còn là điểm dừng tuyệt đối kể từ 2026-09-02.** Chủ quán chốt đơn đã xong
vẫn **huỷ được**, POS quyết từng ca (`shop-facts.md` §6.19, trả lời U-027). Hệ quả phải nói thẳng
vì nó chạm tiền: một đơn đã `Hoàn thành` **đã có thể thu tiền rồi**, nên mọi thứ đọc `Hoàn thành`
như *"chốt sổ xong, không đụng nữa"* đều phải đọc lại — báo cáo doanh thu (§4.10), đối soát cuối
ngày (§4.9) và bất cứ chỗ nào cộng tiền theo đơn. Đường tiền của lần huỷ ấy là **hoàn tiền** (§4.8):
khoản hoàn rơi vào **ngày hoàn**, không sửa lại ngày bán.

| Trạng thái nguồn | Sự kiện | Trạng thái đích | Ai kích hoạt |
|---|---|---|---|
| *(chưa có đơn)* | Khách bấm gửi trên web hoặc QR tại bàn; hoặc quầy nhập xong một đơn đặt hộ / đơn hotline | **Mới** | *Khách* (QR tại bàn, Delivery, Pickup) hoặc *người đứng quầy* (Staff POS, Đặt trước qua hotline) |
| Mới | Đơn thuộc kênh **phải duyệt**: QR tại bàn, Delivery, Pickup | **Chờ xác nhận** | *Hệ thống*, theo kênh (`shop-facts.md` §6.2) |
| Mới | Đơn thuộc kênh **không phải duyệt**: Staff POS, Đặt trước qua hotline | **Đã xác nhận** | *Hệ thống*, theo kênh (§2.2) |
| Chờ xác nhận | Quầy duyệt đơn | **Đã xác nhận** | *Người đứng quầy* (§3.1.1 bước 5, §3.2.1 bước 7) |
| Chờ xác nhận | Quầy từ chối đơn | **Huỷ** | *Người đứng quầy* (`shop-facts.md` §6.13) |
| Đã xác nhận | Hệ thống nổ đơn thành việc của từng trạm theo thành phần của suất (§3.1.5) | **Đang thực hiện** | *Hệ thống* |
| Đã xác nhận | Quầy huỷ đơn — ví dụ khách đặt hotline đổi ý, tới quán ngồi ăn (§2.4) | **Huỷ** | *Người đứng quầy* |
| Đang thực hiện | **Mọi** việc trạm của đơn đã ra tới tay khách: bưng ra bàn, hoặc đóng gói và trao cho khách tới lấy | **Hoàn thành** | *Người đứng quầy*, trên POS (chủ quán chốt 2026-09-01, `shop-facts.md` §5.4) |
| Đang thực hiện | Đơn **giao tận nơi** đã đóng gói xong và rời quán | **Đang giao** | *Người đứng quầy*, trên POS (chủ quán chốt 2026-09-01, `shop-facts.md` §6.7) |
| Đang thực hiện | Quầy huỷ đơn | **Huỷ** | *Người đứng quầy* (`shop-facts.md` §6.13) |
| **Hoàn thành** | Quầy huỷ một đơn **đã xong** — ví dụ phát hiện nhầm sau khi đã trao hàng | **Huỷ** | *Người đứng quầy*, trên POS — **POS quyết từng ca**, không có mốc chặn (chủ quán chốt 2026-09-02, `shop-facts.md` §6.19) |
| Đang giao | Nhân viên giao xong, bấm **đã giao** và **đã thu tiền** cùng lúc | **Hoàn thành** | *Nhân viên quán* đi giao (§3.2.2, `shop-facts.md` §6.7) |

Bốn điều phải đọc kèm bảng, rồi một việc không nằm trong bảng:

- **`Mới` là một trạng thái rất ngắn, và nó có thật.** Đơn nào cũng đi qua nó, rồi **kênh** quyết
  định nó rẽ đâu ngay lập tức: ba kênh khách tự bấm sang `Chờ xác nhận`, hai kênh nhân viên nhập
  sang thẳng `Đã xác nhận`. Tách `Mới` ra khỏi `Chờ xác nhận` là để chỗ rẽ ấy có tên — nhập chúng
  làm một thì luật §6.2 mất chỗ đứng trong vòng đời.
- **`Đã xác nhận` → `Đang thực hiện` là một bước của hệ thống, không phải một nút của người.** Ở
  quán này việc xuống bếp ngay khi đơn được xác nhận (§3.1.1 bước 6), nên hai trạng thái ấy cách
  nhau một khoảnh khắc. Đừng thiết kế một màn hình chờ ai đó bấm *"bắt đầu làm"*: không có ai bấm
  (§5.4).
- **`Đang giao` chỉ có ở đơn giao tận nơi**, và nó là trạng thái BA-07 **thêm** so với kế hoạch gốc
  §7. Lý do ghi rõ: chủ quán chốt 2026-08-30 rằng **quán tự đi giao** và đơn giao mang trạng thái
  *"đang giao"* để quầy nhìn được đơn nào còn trên đường và **ai đang cầm tiền chưa về**
  (`shop-facts.md` §6.7); §3.2.2 đã dùng tên này từ BA-04. Nhánh khách tới lấy đi thẳng từ
  `Đang thực hiện` sang `Hoàn thành`. **Hai đầu của nó do hai người khác nhau bấm** (chủ quán chốt
  2026-09-01, trả lời U-023): *người đứng quầy* bấm lúc đơn **rời quán**, *nhân viên đi giao* bấm
  lúc **giao xong** — vì quầy là chỗ phải biết ai đang cầm tiền chưa về.
- **Đơn ở `Chờ xác nhận` không sinh một việc nào ở cả năm trạm** (`shop-facts.md` §6.2,
  `quality/invariants.md` I-004). Nó **vẫn thuộc** phiên bàn của nó và vẫn được tính vào hoá đơn
  của phiên khi được duyệt (§3.1.3) — chặn ở đây là chặn **việc xuống bếp**, không phải chặn đơn
  khỏi phiên.

**Và một việc KHÔNG có trong bảng, vì nó không phải chuyển tiếp: SỬA ĐƠN.** Khách đổi ý sau khi đơn
đã xác nhận thì quán **sửa chính đơn ấy**, trên **POS**, chứ không huỷ rồi tạo lại (chủ quán chốt
2026-09-01, `shop-facts.md` §6.19). Sửa đổi **nội dung** đơn — món, số suất, tuỳ chọn — chứ không
đẩy đơn sang trạng thái khác, nên nó không có dòng nào trong bảng trên và cũng **không** được coi
là một chuyển tiếp ngoài bảng bị từ chối (§5.1).

**Sửa được ở BẤT KỲ trạng thái nào** (chủ quán chốt 2026-09-02, `shop-facts.md` §6.19): *"quán
đang ở trạng thái nào cũng sửa được, POS sẽ quyết định dựa trên tình hình thực tế"*. Không có ranh
giới kiểu *"bếp tráng rồi thì thôi"*; đơn đã `Hoàn thành` cũng nằm trong chữ **bất kỳ**. Đây là
cùng một kiểu luật với hoàn tiền (§4.8) và với đường lùi một mẻ (§5.4): chủ quán **không** dựng
hàng rào cho máy mà giao quyết định cho người đứng quầy. ⇒ Vì không có luật cứng nên **mỗi lần sửa
phải để lại vết** — sửa đơn nào, đổi gì, lúc mấy giờ, ai bấm (§4.9).

**Hai vế lời chốt ngày 2026-09-01 không chạm tới đều đã đóng trong ngày 2026-09-02**, và cả hai
đều được hỏi riêng thay vì suy ra từ chữ *sửa* (`work/findings.md` F-004):

- **Huỷ** cũng được, **kể cả đơn đã `Hoàn thành`**, POS quyết trong thực tế (U-027) ⇒ bảng trên nay
  có dòng `Hoàn thành → Huỷ`, và §5.6 mất ca thứ hai.
- **Một dòng vừa sửa lấy giá đang hiệu lực LÚC SỬA** (U-026) ⇒ sửa một dòng là **đặt lại mốc khoá
  giá của chính dòng ấy**. Đây là ngoại lệ có chủ ý của §4.4, không phải §4.4 bị phá: một lần đổi
  giá vẫn **không** tự với ngược vào dòng cũ — cái đặt lại mốc là **thao tác của người đứng quầy**.
  Đọc §4.4 trước khi đụng vào phần tính tiền của việc sửa đơn.

### 5.3 Vòng đời PHIÊN BÀN — và cái bàn của nó

**Bắt đầu:** bàn ở `Trống`, phiên sinh ra ở `Mở`. **Kết thúc:** phiên dừng hẳn ở `Đã đóng`; **cái
bàn** thì đi tiếp hai bước nữa và quay về `Trống`.

Kế hoạch gốc §7 viết cả sáu trạng thái thành một chuỗi
`Mở → Đang phục vụ → Chờ thanh toán → Đã đóng → Bàn cần dọn → Trống`. Sáu trạng thái ấy giữ nguyên,
nhưng chúng **không cùng một chủ thể**: bốn cái đầu là trạng thái của **phiên**, hai cái cuối là
trạng thái của **cái bàn**. Đây không phải chuyện chữ nghĩa — nhóm ghép bàn (§3.1.7) là chỗ nó lộ
ra: **một** phiên đóng lại, nhưng **từng** bàn được dọn riêng, nên bàn 4 về `Trống` trong khi bàn 5
còn ở `Bàn cần dọn`. Một chuỗi sáu bước với một chủ thể duy nhất không tả được ca đó.

| Trạng thái nguồn | Sự kiện | Trạng thái đích | Ai kích hoạt |
|---|---|---|---|
| **Trống** *(bàn)* | Khách ngồi vào bàn trống và lượt gọi đầu tiên được tạo cho bàn ấy, bằng QR tại bàn hoặc quầy đặt hộ | **Mở** *(phiên)* | *Hệ thống*, do *khách* hoặc *người đứng quầy* kích (§3.1.1 bước 1) |
| **Trống** *(bàn)* | Quầy **ghép** bàn trống ấy vào một phiên chưa đóng đang có | bàn nhập vào phiên đó; phiên **giữ nguyên** trạng thái đang có | *Người đứng quầy*, trên POS (§3.1.7, `shop-facts.md` §6.16) |
| Mở | Đơn đầu tiên của phiên được xác nhận và việc xuống bếp | **Đang phục vụ** | *Hệ thống* |
| Đang phục vụ | Quầy tính tổng **cả** phiên và ra một hoá đơn (§3.1.1 bước 11) | **Chờ thanh toán** | *Người đứng quầy* |
| Chờ thanh toán | **Khách gọi thêm** — quét QR, hoặc nhờ quầy đặt hộ | **Đang phục vụ** | *Khách* hoặc *người đứng quầy* (`shop-facts.md` §6.1) |
| Chờ thanh toán | Quầy xác nhận **đã nhận tiền** rồi đóng phiên | **Đã đóng** | *Người đứng quầy* (§4.6) |
| Chờ thanh toán | Khách **không trả được** ⇒ quán cho nợ; quầy đóng phiên kèm **ai nợ** và **nợ bao nhiêu** | **Đã đóng** | *Người đứng quầy* (§3.1.6, `shop-facts.md` §6.14) |
| **Đã đóng** *(phiên)* | Phiên đã đóng ⇒ mọi bàn thuộc phiên cần dọn | **Bàn cần dọn** *(từng bàn)* | *Hệ thống* |
| **Bàn cần dọn** *(bàn)* | Dọn xong **chính bàn ấy**, và xác nhận đã dọn | **Trống** *(bàn)* | *Người canh & dọn* — trạm `don_ban` (§1.5, `shop-facts.md` §3) |

Bốn điều phải đọc kèm bảng:

- **`Chờ thanh toán` KHÔNG phải trạng thái khoá, và nó vẫn là phiên CHƯA THANH TOÁN.** Đây là chỗ
  dễ hiểu nhầm nhất của cả mục §5. Quầy bấm tính tiền không đóng phiên, không giải phóng bàn, và
  không chặn lượt gọi mới: khách gọi thêm thì phiên **quay lại** `Đang phục vụ` và lượt gọi ấy vào
  **chính** hoá đơn đó. Tách nó ra hoá đơn thứ hai là **thu thiếu tiền** — lỗi tiền nguy hiểm nhất
  của luồng tại bàn (`shop-facts.md` §6.1, §3.1.4, `quality/invariants.md` I-002).
- **Bàn rời khỏi "một phiên chưa thanh toán" chỉ khi phiên `Đã đóng`.** Bàn của một phiên đang ở
  `Chờ thanh toán` vẫn **không trống**, kể cả khi khách đã quét VietQR mà quầy chưa thấy báo có
  (§4.7 ca a).
- **Đóng phiên bị chặn bởi MÓN chưa xong, không bị chặn bởi TIỀN chưa thu.** Hai luật ngược nhau và
  rất dễ nhớ nhầm thành một: phiên **không** đóng được khi còn đơn chưa `Hoàn thành` và chưa `Huỷ`
  (`quality/invariants.md` I-017); nhưng phiên **vẫn** đóng được khi khách còn nợ tiền, và đó là
  đường chính thức chứ không phải ngoại lệ (§3.1.6, `shop-facts.md` §6.14).
- **Bàn về `Trống` cần HAI việc, không phải một** — phiên `Đã đóng` **và** bàn đã dọn
  (`quality/invariants.md` I-003). Dọn trước khi đóng phiên không làm bàn trống sớm hơn; đóng phiên
  mà chưa dọn thì bàn vẫn bận. Với nhóm ghép bàn, điều kiện thứ nhất chung cho cả nhóm, điều kiện
  thứ hai tính **từng bàn**.

### 5.4 Vòng đời CÔNG VIỆC TRẠM — đơn vị là MỘT VIỆC Ở MỘT TRẠM

**Đơn vị của vòng đời này là một việc ở một trạm, không phải cả đơn.** Một đơn nổ ra **nhiều** việc
(§3.1.5, `shop-facts.md` §5.3) và chúng chạy **song song** ở các trạm khác nhau: hai suất đầy đủ
trứng tái sinh sáu việc trên ba trạm, và ba trạm bếp nhận việc **cùng lúc** chứ không nối đuôi
nhau. Mỗi việc trong sáu việc ấy có vòng đời riêng của nó, đi hết bảng dưới đây một mình.

Hai cỡ việc, cả hai đều chạy đúng bảng này: việc **cấp thành phần** — bánh cuốn, trứng, giò — nhân
lên theo số suất; việc **cấp đơn** — nước chấm — mỗi đơn đúng **một** việc cho trạm `canh`, không
nhân lên (`shop-facts.md` §6.6).

**Bắt đầu:** `Chưa làm`. **Kết thúc:** `Đã ra bàn`.

| Trạng thái nguồn | Sự kiện | Trạng thái đích | Ai kích hoạt |
|---|---|---|---|
| *(chưa có việc)* | Đơn sang `Đang thực hiện`; hệ thống nổ đơn thành thành phần theo §3.1.5 | **Chưa làm** | *Hệ thống* |
| Chưa làm | Quầy bấm **"đã làm xong"** cho **một mẻ** bếp vừa làm xong | **Đã làm xong, còn ở bếp** | *Người đứng quầy*, trên POS — **ba trạm bếp không bấm gì** (`shop-facts.md` §5.4) |
| Đã làm xong, còn ở bếp | Việc được **bưng ra bàn**, hoặc **đóng gói và trao** với đơn mang đi | **Đã ra bàn** | *Người đứng quầy*, trên POS (chủ quán chốt 2026-09-01) |
| Đã làm xong, còn ở bếp | Quầy nhận ra vừa bấm **nhầm** một mẻ và **lùi** lại | **Chưa làm** | *Người đứng quầy*, trên POS — **không có mốc thời gian cứng**, quầy quyết từng ca (chủ quán chốt 2026-09-01) |

**Vòng đời này KHÁC kế hoạch gốc, và khác vì lời chủ quán.** Kế hoạch gốc §7 viết
`Chưa làm → Đang làm → Hoàn thành`. Vẫn **ba** trạng thái, nhưng trạng thái giữa không phải
*Đang làm*:

- **Quán không ghi được `Đang làm`.** Chủ quán đã **bỏ mọi nút bấm ở trạm bếp** (chốt 2026-08-31,
  đóng U-009, `shop-facts.md` §5.4): người tráng bánh, người gấp bánh và người lấy canh không phải
  bấm gì cả. Không ai nói cho máy biết lúc bếp **bắt đầu** một việc, nên một trạng thái *Đang làm*
  trong tài liệu sẽ là một trạng thái không bao giờ có dữ liệu thật.
- **Nhưng có một khoảng khác, và nó có thật.** Chủ quán chốt 2026-09-01 (trả lời S-4) rằng bánh
  gấp xong **có nằm chờ** trước khi ra bàn — *chờ đủ đĩa*, *chờ người rảnh tay bưng*, *chờ món khác
  của cùng bàn*. Vì vậy bảng ở quầy có **bốn** con số chứ không phải ba, và con số thứ tư tên là
  **"đã làm xong, còn ở bếp"** (`shop-facts.md` §5.4).
- ⇒ **`Đã làm xong, còn ở bếp` là thứ quán ĐẾM ĐƯỢC; `Đang làm` là thứ kế hoạch gốc đoán.** BA-07
  giữ đúng ba trạng thái và thay cái giữa bằng cái có dữ liệu. Đây là một **quyết định thiết kế
  nghiệp vụ**, không phải chỗ chép thiếu — **BA-10** gom nó thành ADR.

Ba điều phải đọc kèm bảng:

- **Mẻ là đơn vị BẤM, bàn là đơn vị ĐẾM** (chủ quán chốt 2026-09-01, trả lời U-017). Một lần bấm
  *"đã làm xong"* đẩy **nhiều** việc — có khi của **nhiều bàn** — từ `Chưa làm` sang
  `Đã làm xong, còn ở bếp` cùng một lúc. ⇒ Con số ở quầy **nhảy theo bậc**, cả mẻ một lần; đó là
  đúng, không phải lỗi đếm. Và một lần bấm phải **chia được** về từng bàn, vì việc xuống bếp luôn
  ghi bàn nào gọi (`shop-facts.md` §5.3, §5.4).
- **Cả hai mốc đều do người đứng quầy bấm** (chủ quán chốt 2026-09-01, trả lời U-021): *"đã làm
  xong"* và *"đã ra bàn"*. Ba trạm bếp vẫn **không bấm gì** — U-009 nguyên vẹn, vì nó là luật về
  **bếp**, không phải luật về quầy. ⇒ Quầy nay gánh **cả hai** mốc của mỗi suất; đó là rủi ro vận
  hành thật, không phải chi tiết trình bày (`shop-facts.md` §5.4). *Bấm "đã ra bàn" theo đơn vị
  nào — mẻ hay bàn — thì chủ quán chưa nói; chỗ suy ra ấy là* **S-5** *ở `shop-facts.md` §7.2, và*
  **BA-12** *cần nó trước khi dựng bảng quầy.*
- **Bấm nhầm thì LÙI ĐƯỢC, và không có mốc thời gian cứng** (chủ quán chốt 2026-09-01, trả lời
  U-024): *"có đường lui, thời gian tuỳ theo thực tế để POS quyết định"*. Không có "trong vòng N
  phút" — người đứng quầy nhìn tình huống thật rồi quyết, đúng cùng một kiểu với quyền hoàn tiền
  (§4.8). ⇒ **Vì không có luật cứng nên mỗi lần lùi phải để lại vết** — lùi mẻ nào, lúc mấy giờ,
  ai bấm. Đó không phải luật mới: `quality/invariants.md` I-012 đã buộc mọi thao tác chạm tiền
  truy ngược được, và một mẻ lùi sai là một suất tính nhầm.
- **Việc trạm không có nhánh huỷ của riêng nó.** Nó sống chết theo đơn: đơn sang `Huỷ` thì mọi việc
  chưa xong của đơn ấy rời bảng bếp cùng lúc. Không có ai đứng ở trạm huỷ được một việc — quyền huỷ
  chỉ nằm ở quầy, và nó là quyền huỷ **đơn** (`shop-facts.md` §6.13).
- **Không có trạng thái "tạm dừng".** Hết nguyên liệu giữa buổi thì đường xử lý của quán là chủ
  quán bấm **tạm dừng nhận đơn** — chặn đơn **mới**, không chạm việc đang làm (§3.2.6,
  `shop-facts.md` §6.8, `quality/invariants.md` I-008). Còn ca **món hết sau khi khách đã đặt** là
  câu 3 của bảng mười câu hỏi trong `work/backlog.md`, **còn mở**, và nó thuộc §6 (BA-08).
- **Cách quán GOM nhiều việc thành một mẻ không ở đây.** §5 chốt trạng thái của **một** việc; bảng
  gom việc ở quầy, bốn con số và năng lực hai cái nồi là **§3.4** (BA-12, `shop-facts.md` §5.4).
  Và ranh giới đã chốt: **máy không gom, người gom** (chủ quán chốt 2026-08-31, đóng U-011).

### 5.5 Ba vòng đời gặp nhau ở đâu

Ba vòng đời không chạy độc lập. Bốn chỗ chúng ràng buộc nhau, và cả bốn đều là luật:

- **Đơn ⟶ việc trạm.** Việc trạm chỉ sinh ra khi đơn vào `Đang thực hiện`, tức **sau** khi đơn đã
  `Đã xác nhận`. Đơn ở `Mới` hoặc `Chờ xác nhận` **không sinh một việc nào** ở cả năm trạm
  (`shop-facts.md` §6.2, `quality/invariants.md` I-004).
- **Việc trạm ⟶ đơn.** Đơn chỉ `Hoàn thành` khi **mọi** việc trạm của nó đã ở `Đã ra bàn`. Còn một
  việc ở `Chưa làm` hay ở `Đã làm xong, còn ở bếp` thì đơn vẫn `Đang thực hiện` — **kể cả khi khách
  đã trả tiền xong**. Nước chấm cũng tính: nó là một việc như mọi việc khác, và quên nó là khách
  nhận bánh không có nước chấm (`shop-facts.md` §6.6).
- **Đơn ⟶ phiên bàn.** Phiên chỉ `Đã đóng` khi **mọi** đơn thuộc phiên ở `Hoàn thành` hoặc `Huỷ`
  (`quality/invariants.md` I-017). Với nhóm ghép bàn, "mọi đơn thuộc phiên" phủ đơn của **tất cả**
  các bàn trong nhóm (§3.1.7).
- **Phiên bàn ⟶ cái bàn.** Bàn về `Trống` khi phiên `Đã đóng` **và** chính bàn ấy đã dọn xong
  (`quality/invariants.md` I-003).

Và một chỗ **cố ý không** ràng buộc, vì nó là chỗ hay bị siết nhầm:

- **Vào `Chờ thanh toán` không đòi hỏi đơn nào phải xong.** Ở luồng thường ngày của quán, quầy tính
  tiền **sau** khi món đã ra bàn — bước 11 đứng sau bước 8 của §3.1.1 — nên lúc ấy các đơn của phiên
  thường đã `Hoàn thành` cả. Nhưng đó là **thứ tự quen của quán, không phải điều kiện**: `Chờ thanh
  toán` là lúc quầy bắt đầu tính tiền, không phải lời tuyên bố phiên đã xong (`shop-facts.md` §6.1).
  Ràng buộc cứng nằm ở `Đã đóng`, và chỉ ở đó. Siết nó lên `Chờ thanh toán` là cấm quầy tính tiền
  trước trong khi bếp còn một bát canh chưa bưng — quán không làm việc theo kiểu đó.

### 5.6 Một chuyển tiếp nghe có lý mà bị TỪ CHỐI

Luật ở §5.1 nói mọi chuyển tiếp ngoài bảng đều bị từ chối. Ca dưới đây được gọi tên vì nó nghe như
hợp lý, và vì sẽ có người hỏi *"sao không cho?"*:

- **`Đã đóng` → `Đang phục vụ` (phiên bàn): không có đường quay lại, và đây là ca đã CHỐT.** Khách
  quay lại bàn ấy gọi tiếp thì đó là một **phiên mới**, một hoá đơn mới. Mở lại một phiên đã đóng
  là mở lại một hoá đơn đã thu tiền — thứ §3.3.3 và §4.4 khoá chặt.

**Hai ca đã rời danh sách này, và cả hai rời vì chủ quán trả lời NGƯỢC với tài liệu.**

- **`Đã làm xong, còn ở bếp` → `Chưa làm` (việc trạm), rời ngày 2026-09-01.** Từng nằm đây với ghi
  chú *"quầy bấm nhầm một mẻ thì hôm nay không có đường lùi"*; chủ quán trả lời U-024 là **có**
  đường lùi, nên nay nó là một **dòng hợp lệ** ở bảng §5.4.
- **`Hoàn thành` → `Huỷ` (đơn), rời ngày 2026-09-02.** Từng nằm đây suốt vì *"chưa ai hỏi chủ
  quán"*, qua hai lần thu hẹp (U-022 rồi U-027); chủ quán trả lời **huỷ được, POS quyết trong thực
  tế** (`shop-facts.md` §6.19), nên nay nó là một **dòng hợp lệ** ở bảng §5.2.

Ghi lại chỗ hai ca ấy từng đứng để phiên sau đọc §5.6 cũ không tưởng là tài liệu tự mâu thuẫn.

**Và một bài học chung cho cả hai, đắt hơn hai dòng bảng.** Cả hai ca đều bị tài liệu ghi là *"sản
phẩm từ chối"* trong khi chưa ai hỏi chủ quán, và **cả hai lần chủ quán đều trả lời ngược lại**. ⇒
Một ca *"bị từ chối vì chưa chốt"* là một **câu hỏi chưa hỏi**, không phải một luật; viết nó vào
tài liệu bằng giọng của luật là cách sản phẩm tự bó chặt hơn cái quán thật. Cùng một bài học với ba
giả định `docs/decisions.md` GĐ-02, GĐ-03, GĐ-04 bị thay trong ngày 2026-09-02, và là lý do
CLAUDE.md §3.5 tồn tại.

### 5.7 Bốn việc mục này cố ý không nói tới

- **Ngoại lệ.** Khách gửi nhầm đơn, món hết sau khi khách đã đặt, hai người cùng thao tác trên một
  bàn, mất điện hoặc mất mạng giữa buổi — §5 chỉ chốt **bộ trạng thái và các đường đi hợp lệ**;
  quán xử từng ca thế nào là §6 (BA-08).
- **Lát cắt sản xuất theo mẻ.** Bảng gom việc ở quầy, bốn con số, năng lực hai cái nồi: **§3.4**
  (BA-12). §5 nói một việc đi qua những trạng thái nào, §3.4 nói quán gom nhiều việc lại ra sao.
- **Máy giữ trạng thái bằng cách nào.** Tên kỹ thuật, chỗ lưu, ai được xem lại lịch sử chuyển trạng
  thái, màn hình nào bày ra bảng nào — `docs/architecture.md` và §7 (BA-09).
- **Trạng thái của TIỀN.** Đã thu · chưa thu · nợ · đã hoàn — đó là §4, và nó **không** phải một
  trạng thái của phiên hay của đơn. §5 chạm tiền đúng một chỗ: tiền chưa thu **không** chặn phiên
  đóng (§5.3).

