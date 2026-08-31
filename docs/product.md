# Product

Hành vi nghiệp vụ của sản phẩm. Mỗi mục dưới đây do một task BA chốt.

> **Dữ kiện quán không sống ở đây.** Giá, phụ thu, giờ bán, số bàn, thành phần một suất bán và
> các quy tắc vận hành thuộc `master_plan/shop-facts.md` (ADR-001). File này mô tả *sản phẩm phải
> hành xử thế nào* dựa trên các dữ kiện đó; chỗ nào cần một con số, tra ở owner, đừng chép về đây.

## 1. Actor và phạm vi hệ thống

*BA-01 — chốt 2026-08-30. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §2.1 (khung
actor) + `master_plan/shop-facts.md` §1, §2, §3, §5, §6 (dữ kiện quán, chủ quán chốt 2026-08-19 →
2026-08-30).*

Hệ thống phục vụ **ba** nhóm actor. Mục này chỉ nói **quyền và trách nhiệm nghiệp vụ** — ai được
làm gì, ai chịu trách nhiệm việc gì. Màn hình, cách đăng nhập và mô hình phân quyền là việc của
System Design, không có ở đây.

### 1.1 Khách hàng

Người đặt món. Không có mặt trong quán cũng có thể là khách (giao tận nơi, tới lấy, gọi điện).

Việc khách làm:

- Đặt món **giao tận nơi**, tự bấm trên web.
- Đặt món **tới lấy** tại quán, tự bấm trên web, kèm giờ hẹn lấy.
- **Quét QR tại bàn** và tự gọi món cho bàn mình đang ngồi.
- **Gọi hotline để đặt trước**; khách nói, nhân viên nhập hộ vào hệ thống.
- **Gọi thêm món** khi đang ngồi bàn, kể cả sau khi quầy đã bắt đầu thu tiền — mọi lượt gọi của
  cùng một bàn vẫn thuộc **một** phiên và được tính **một** lần (`shop-facts.md` §6.1).
- **Chọn cách trả tiền** — tiền mặt hoặc VietQR — và trả **lúc nhận hàng** (`shop-facts.md`
  §6.3). Đó là đường mặc định.
- **Chọn trả trước, nếu là đơn mang đi** — khách đặt giao tận nơi, tới lấy hay gọi hotline đều
  được trả tiền ngay lúc đặt thay vì lúc nhận hàng (chủ quán chốt 2026-08-30,
  `shop-facts.md` §6.3). Là **tuỳ chọn**: không chọn thì trả lúc nhận hàng. Khách ngồi bàn
  không có lựa chọn này — phiên bàn còn mở thì còn gọi thêm được nên chưa chốt được số tiền.

Việc khách **không** làm: khách không tự xác nhận đơn của mình, và **không bao giờ quyết định giá**
— giá luôn do hệ thống xác định lại từ bảng giá (`shop-facts.md` §4.6 quy tắc 9).

### 1.2 Nhân viên quán

Người của quán, làm việc theo **năm trạm** ở §1.5. Năm trạm đó chia thành **bốn vai người**: quầy,
tráng bánh, gấp bánh mỗi thứ là một trạm riêng; lấy canh và dọn bàn do **cùng một người** làm
(chủ quán chốt 2026-08-30, `shop-facts.md` §3).

Việc nhân viên làm:

- **Xác nhận (duyệt) đơn khách tự gửi** trước khi việc xuống bếp. Đơn chưa duyệt không sinh việc ở
  bất kỳ trạm nào (`shop-facts.md` §6.2).
- **Đặt món hộ khách tại quán**, gắn vào một số bàn cụ thể.
- **Nhập hộ đơn đặt trước qua điện thoại**, và khi nhận điện thoại **phải hỏi**: giao tận nơi hay
  tới lấy, và cần hàng lúc mấy giờ (`shop-facts.md` §5.2).
- **Làm phần việc của trạm mình** (§1.5).
- **Đóng gói** đơn mang đi, và **tự đi giao** đơn giao tận nơi — quán không thuê bên thứ ba
  (`shop-facts.md` §6.7).
- **Thu tiền lúc trao hàng** (tiền mặt hoặc VietQR) và **tự bấm xác nhận đã nhận tiền** — xem ranh giới hệ thống ở §1.4.
  Với đơn khách **đã chọn trả trước** thì chưa rõ ai bấm xác nhận và vào lúc nào — xem
  **U-005** ở *Unknowns*, chưa ai trả lời.
- **Đóng phiên bàn** khi khách đã trả tiền, rồi **dọn bàn** để bàn trở lại trạng thái trống.
- **Huỷ một đơn** — chỉ **người đứng quầy** làm được (chủ quán chốt 2026-08-30,
  `shop-facts.md` §6.13); bốn trạm còn lại không huỷ được đơn nào, kể cả đơn của việc mình đang làm.
- **Quyết định hoàn tiền theo từng trường hợp** tại quầy — không có luật cứng, người ở quầy nhìn
  tình huống thật rồi quyết; mọi lần hoàn phải để lại vết: hoàn bao nhiêu, cho đơn nào, ai bấm, lý
  do gì (`shop-facts.md` §6.4).

### 1.3 Chủ quán

Vai riêng, **ngoài** năm trạm — nhưng **thỉnh thoảng chủ quán đứng quầy** (chốt 2026-08-30), tức
làm đúng việc của trạm quầy ở §1.2: nhận và xác nhận đơn, thu tiền, đóng phiên. Lúc đó chủ quán
vẫn là chủ quán, không mất vai quản trị.

Việc chủ quán làm:

- **Quản lý menu**: món nào đang bán, món nào ngừng bán.
- **Quản lý giá** theo bảng giá ở `shop-facts.md` §4.
- **Quản lý nhân viên và bàn**.
- **Tạm dừng nhận đơn** giữa buổi (ví dụ hết nguyên liệu). Nút này có ưu tiên **cao hơn giờ mở
  cửa** (`shop-facts.md` §6.8).
- **Nhập số tài khoản** nhận chuyển khoản trong phần quản trị (`shop-facts.md` §1).
- **Không** có đường huỷ đơn riêng. Muốn huỷ một đơn mà không đang đứng quầy thì **nhờ người
  đứng quầy bấm** (chủ quán chốt 2026-08-30, `shop-facts.md` §6.13) — quyền huỷ gắn với chỗ đứng,
  không gắn với chức vụ.
- **Xem báo cáo doanh thu**, cộng từ **cả hai** nguồn — phiên bàn và đơn lẻ; bỏ sót một nguồn là
  báo cáo thiếu tiền (`shop-facts.md` §6.9).

### 1.4 Ranh giới hệ thống

**Hệ thống chịu trách nhiệm:**

- Nhận đơn qua đúng năm kênh ở §2, và chặn đơn ngoài giờ bán hoặc khi chủ quán đang tạm dừng nhận
  đơn.
- Tự xác định giá của mọi đơn từ bảng giá, và từ chối tổ hợp tuỳ chọn không hợp lệ.
- Giữ một bàn có **một** phiên chưa thanh toán, và gộp mọi lượt gọi của bàn đó vào phiên ấy.
- Nổ một dòng đơn thành **việc cho từng trạm** theo thành phần của suất (`shop-facts.md` §5.3).
- Giữ trạng thái của đơn và của bàn, kể cả trạng thái "đang giao" của đơn giao tận nơi.
- Ghi lại mọi thao tác chạm tiền hoặc chạm trạng thái đơn, đủ để đối soát cuối ngày truy ngược.

**Hệ thống KHÔNG chịu trách nhiệm:**

- **Không tự biết tiền đã về tài khoản.** Mã VietQR là mã tĩnh, không sinh riêng cho từng hoá đơn;
  người ở quầy nhìn báo có rồi bấm xác nhận (`shop-facts.md` §1).
- **Không quyết định thay quầy việc hoàn tiền** — hệ thống chỉ ghi lại quyết định đó
  (`shop-facts.md` §6.4).
- **Không giao hàng thay quán.** Quán tự đi giao; hệ thống chỉ cho biết đơn nào còn trên đường
  (`shop-facts.md` §6.7).
- **Không phải chỗ dựa duy nhất để bán hàng.** Mất điện, mất mạng hay máy hỏng thì quán chuyển sang
  **sổ giấy** và **không dừng bán** (`shop-facts.md` §6.11).
- Không quản lý nguyên liệu, tồn kho, chấm công hay kế toán.

### 1.5 Năm trạm làm việc

Nhân viên quán làm việc theo **đúng năm trạm** (`shop-facts.md` §3). Đây là **việc quán làm**,
không phải màn hình hay quyền đăng nhập của trạm đó.

| Trạm | Trạm đó làm gì |
|---|---|
| **quầy** | Nhận và xác nhận đơn, đặt hộ khách, **huỷ đơn**, thu tiền, đóng phiên bàn |
| **tráng bánh** | Tráng bánh và làm trứng |
| **gấp bánh** | Gấp bánh, xếp đĩa, cắt giò |
| **lấy canh** | Làm nước chấm và canh cho **mọi** đơn — đơn mang đi thì gói riêng |
| **dọn bàn** | Dọn bàn sau khi phiên đã đóng, trả bàn về trạng thái trống |

**Năm trạm, bốn người** (chủ quán chốt 2026-08-30): quầy · tráng bánh · gấp bánh là **ba trạm
riêng**, mỗi trạm một người, không kiêm sang trạm khác. **Lấy canh và dọn bàn do cùng một người
làm** — hai loại việc khác nhau nhưng cùng một đôi tay, nên khi đông khách chúng tranh nhau người,
còn ba trạm kia thì không.

Chủ quán là vai riêng, **ngoài** năm trạm này, nhưng có đứng quầy khi cần (§1.3). Không có trạm thứ
sáu; thêm một trạm là đổi cách quán vận hành, phải hỏi chủ quán.

## 2. Kênh bán

*BA-02 — chốt 2026-08-30. Nguồn: `master_plan/shop-facts.md` §2 (bảng kênh, chủ quán chốt
2026-08-24, sửa 2026-08-29), §6.2 (ai phải duyệt), §6.5 (thông tin liên hệ, chủ quán chốt
2026-08-30).*

Quán bán qua **đúng năm kênh, không có kênh thứ sáu**. Con số năm là **quyết định của chủ quán**,
không phải bản tóm tắt của người viết tài liệu: thêm kênh thứ sáu là **đổi phạm vi**, phải xin phép
chủ quán (`shop-facts.md` §2, §6.12).

| Kênh | Ai khởi tạo đơn | Gắn phiên bàn | Ai xác nhận trước khi việc xuống bếp | Định danh khách **bắt buộc** |
|---|---|---|---|---|
| **Delivery** — giao tận nơi | Khách, tự bấm trên web | **Không** | **Quầy phải duyệt** | Số điện thoại **và** địa chỉ giao |
| **Pickup** — khách tới lấy | Khách, tự bấm trên web | **Không** | **Quầy phải duyệt** | Số điện thoại **và** giờ hẹn lấy |
| **QR tại bàn** | Khách, quét QR tại bàn mình ngồi | **Có** | **Quầy phải duyệt** | Không — **ẩn danh theo số bàn** |
| **Staff POS** — đặt hộ tại bàn | Nhân viên, tại quán, cho **một số bàn cụ thể** | **Có** | Không cần duyệt — đơn vào thẳng | Không — **ẩn danh theo số bàn** |
| **Đặt trước qua hotline** | Nhân viên, nhập hộ khi khách gọi điện | **Không** | Không cần duyệt — đơn vào thẳng | Số điện thoại **và** giờ khách cần hàng; **địa chỉ giao nếu khách chọn giao tận nơi** |

Danh sách trường liên hệ đầy đủ (kể cả trường "nên có") ở `shop-facts.md` §6.5 — đừng chép về đây.

### 2.1 Hai kênh gắn phiên bàn, ba kênh không

- **Hai kênh gắn phiên bàn — QR tại bàn và Staff POS.** Khách **ẩn danh theo số bàn**: quán chỉ cần
  biết "bàn 5", không cần biết tên ai. Mọi lượt gọi của bàn đó, bằng bất kỳ tổ hợp nào của hai
  kênh này, **gộp vào một phiên và tính tiền một lần**.
- **Ba kênh không gắn phiên bàn — Delivery, Pickup, Đặt trước qua hotline.** Mỗi đơn là **một đơn
  vị thanh toán độc lập**, không gộp với đơn nào khác, kể cả cùng một khách đặt hai lần. Cả ba
  phải có thông tin để gọi lại được.

### 2.2 Ai phải được duyệt, và vì sao

Luật chỉ có một câu: **đơn do KHÁCH tự gửi phải được quầy duyệt; đơn do NHÂN VIÊN nhập thì không**
(`shop-facts.md` §6.2).

- Phải duyệt: **QR tại bàn, Delivery, Pickup** — ba kênh khách tự bấm.
- Không cần duyệt: **Staff POS, Đặt trước qua hotline** — nhân viên đã nhập thì đã có người chịu
  trách nhiệm.

Bước duyệt tồn tại để **chặn đơn ảo**, nên nó chỉ có nghĩa với đơn không ai chịu trách nhiệm. Đơn
chưa được duyệt **không sinh việc ở bất kỳ trạm nào**.

### 2.3 Staff POS ≠ Đặt trước qua hotline

Hai kênh này đều do nhân viên bấm, nhưng là **hai việc khác nhau** và không được gộp:

| | **Staff POS** | **Đặt trước qua hotline** |
|---|---|---|
| Khách đang ở đâu | **Tại quán, ngồi một bàn cụ thể** | Ở ngoài, gọi điện tới |
| Có số bàn không | **Có** — đơn vào phiên của bàn đó | **Không** — đơn không thuộc phiên bàn nào |
| Đơn vị tính tiền | Phiên bàn, gộp chung một hoá đơn | Đơn lẻ, tự nó là một đơn vị thanh toán |
| Kết thúc thế nào | Ăn tại bàn, đóng phiên, dọn bàn | Khách tới lấy **hoặc** quán đi giao — nhân viên phải hỏi |
| Khách đổi ý, tới ăn tại quán | — (đã ở quán rồi) | **Huỷ đơn**, khách quét QR gọi lại bằng kênh QR tại bàn (§2.4) |

Trước 2026-08-29, đơn hotline từng bị ghi là đi bằng Staff POS. **Cách ghi đó sai và đã bị gỡ**
(chủ quán chốt 2026-08-29, `shop-facts.md` §2): Staff POS luôn gắn một số bàn, mà khách gọi điện
thì chưa ngồi bàn nào. Thấy cách ghi cũ quay lại ở bất kỳ tài liệu nào ⇒ đó là bug.

### 2.4 Đơn hotline mà khách tới ăn tại quán thì huỷ, không chuyển thành phiên bàn

Chủ quán chốt 2026-08-30 (`shop-facts.md` §2): khách đã đặt trước qua điện thoại nhưng rồi tới quán
ngồi ăn ⇒ **huỷ đơn đặt trước**, khách quét QR tại bàn và gọi lại như mọi khách ngồi bàn khác.

Không có đường nối một đơn đặt trước vào một phiên bàn. Đó là lý do luật "mỗi đơn không gắn bàn là
một đơn vị thanh toán độc lập" (§2.1) không có ngoại lệ nào.

**Huỷ như vậy có sinh việc hoàn tiền hay không là tuỳ đơn đã trả tiền chưa** (chủ quán chốt
2026-08-30, `shop-facts.md` §6.3). Đơn **chưa** trả — đường mặc định — thì huỷ xong là hết. Đơn
khách **đã chọn trả trước** thì huỷ **có** sinh việc hoàn tiền, xử theo `shop-facts.md` §6.4:
người đứng quầy quyết từng ca và ghi vết.

**Người bấm huỷ là người đứng quầy** (chủ quán chốt 2026-08-30, `shop-facts.md` §6.13) — không
phải nhân viên bất kỳ. Cùng một người vừa duyệt đơn (§2.2), vừa huỷ đơn, vừa quyết định hoàn tiền,
nên mọi thao tác chạm tiền đều truy được về một người.

**Quyền huỷ gắn với chỗ đứng, không gắn với chức vụ** (chủ quán chốt 2026-08-30). Chủ quán đang
đứng quầy thì tự bấm, vì lúc đó làm đúng việc của trạm quầy (§1.3); chủ quán **không** đứng quầy
thì **nhờ người đứng quầy bấm**. Không có cửa thứ hai — mọi lần huỷ đều đi qua máy POS ở quầy.

## 3. Ba lát cắt nghiệp vụ

> Chưa chốt — BA-03, BA-04, BA-05

## 4. Giá và thanh toán

> Chưa chốt — BA-06

## 5. Vòng đời nghiệp vụ

> Chưa chốt — BA-07

## 6. Ngoại lệ

> Chưa chốt — BA-08

## 7. Phạm vi MVP

> Chưa chốt — BA-09

## 8. Scenario nghiệm thu BA

> Chưa chốt — BA-11

## Unknowns

Câu hỏi nghiệp vụ chưa có lời giải. Không để việc thực hiện âm thầm quyết định thay.

`scripts/brief.sh` đọc mục này và in danh sách đang mở vào **mọi phiên mới**, nên hình dạng của
mục là một hợp đồng, không phải chuyện trình bày — cách viết ở
[Cách viết một câu ở đây](#cach-viet) bên dưới.

### Đang mở

Một câu, sinh ra ngày 2026-08-30 từ chính lời chốt cho phép trả trước:

- U-005 — **đơn khách trả trước thì trả bằng gì, ai bấm xác nhận "đã nhận tiền", và vào lúc
  nào?** Đơn thu lúc trao hàng thì người trao hàng bấm; đơn trả trước thì không có nhân viên
  nào đứng đối diện khách, và VietQR ở đây là **tĩnh** (`shop-facts.md` §1) nên hệ thống không
  tự biết tiền đã về. *Ai trả lời được:* chủ quán. *Đang chặn:* BA-06 (§4 phải nói rõ ai xác
  nhận đã thu được tiền cho **từng** phương thức) và một phần BA-07 (đơn trả trước đứng ở
  trạng thái nào trước khi giao).

<a id="cach-viet"></a>
### Cách viết một câu ở đây

Hợp đồng giữa mục này và `scripts/brief.sh` (T-021 · `docs/decisions.md` ADR-007 ·
`work/findings.md` F-008). Mục này nằm dưới tiêu đề `###` của riêng nó nên brief **không** đọc —
vì thế mấy ví dụ dưới đây viết `U-` thoải mái mà không bị in ra như câu đang mở.

- **Vùng đang mở** = phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối nằm dưới một
  tiêu đề `### Đang mở`. Mọi thứ dưới một tiêu đề `###` khác đều không được đọc.
- **Trong vùng đang mở, một gạch đầu dòng là một unknown đang mở.** Định danh `U-XXX` được tìm ở
  bất cứ đâu trong gạch đầu dòng, nên in đậm chỗ nào cũng được và vắt dòng thoải mái.
- **Văn xuôi trong vùng đang mở không sinh ra unknown.** Muốn nhắc tới một câu mà không mở nó thì
  viết thành câu văn, đừng gạch đầu dòng.
- Trả lời xong một câu thì **chuyển gạch đầu dòng ấy xuống mục đã có lời giải**, đừng chỉ gạch
  ngang tại chỗ.

### Đã có lời giải — không ghi lại thành Unknown nữa

Ngày **2026-08-30** chủ quán trả lời hết ba unknown mở ở BA-01, cả ba chỗ suy luận S-1–S-3,
và cả câu U-004 sinh ra từ chính lời giải của U-003.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-30) | Ghi ở |
|---|---|---|
| ~~U-001 — nhân viên có phân vai theo trạm không~~ | **Có.** Quầy · tráng bánh · gấp bánh là ba trạm riêng; lấy canh và dọn bàn **chung một người** | §1.5 · `shop-facts.md` §3 |
| ~~U-002 — chủ quán có là nhân viên không~~ | **Thỉnh thoảng đứng quầy**, vẫn giữ vai chủ quán | §1.3 · `shop-facts.md` §3 |
| ~~U-003 — đơn hotline rồi khách tới ăn tại quán~~ | **Huỷ đơn đặt trước**, khách quét QR gọi lại | §2.4 · `shop-facts.md` §2 |
| ~~S-1 — phụ thu suất trứng ×5 hay ×4~~ | **×5** — quả trứng cũng lên giá theo nhân, suất trứng nhân thường = **25.000** | `shop-facts.md` §4.3 · §4.6 |
| ~~S-2 — hai trường liên hệ bắt buộc~~ | **Đúng**, số điện thoại và địa chỉ giao là bắt buộc | §2 · `shop-facts.md` §6.5 |
| ~~S-3 — ai ghi vết mỗi lần hoàn tiền~~ | **Người đứng quầy** vừa quyết định vừa ghi vết | `shop-facts.md` §6.4 |
| ~~U-004 — ai được bấm huỷ một đơn~~ | **Chỉ người đứng quầy**, bấm trên máy POS ở quầy; chủ quán không đứng quầy thì **nhờ người đứng quầy bấm** | §2.4 · `shop-facts.md` §6.13 |

Câu cũ hơn, đã đóng từ trước:

- ~~Đơn đặt trước qua hotline gắn vào bàn nào~~ → là **kênh thứ năm, không gắn bàn**
  (chủ quán chốt 2026-08-29, `shop-facts.md` §2).
- ~~Khách quét QR có phải khai định danh không~~ → **ẩn danh theo số bàn**; **cả ba kênh không
  gắn bàn** — Delivery, Pickup và đặt trước qua hotline — bắt buộc số điện thoại
  (`shop-facts.md` §2, §6.5).

`master_plan/shop-facts.md` §7.2 — chỗ giữ các mục **suy ra chưa xác nhận** — từ 2026-08-30
**không còn mục nào**. Tài liệu nào còn nói "ba chỗ suy luận chưa ai xác nhận" là pointer cũ.
