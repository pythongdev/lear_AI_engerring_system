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

- **Gọi thêm suất để đem về, khi đang ngồi bàn.** Suất ấy vào **chính phiên bàn** đang mở kèm note
  "đem về", chứ không thành một đơn mang đi riêng (chủ quán chốt 2026-08-31, `shop-facts.md`
  §6.15). Xem §2.1 và §3.1.4.

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
- **Cho nợ khi khách không trả được**, và lúc đóng phiên phải ghi **ai nợ** và **nợ bao nhiêu**
  (chủ quán chốt 2026-08-31, `shop-facts.md` §6.14). Phiên vẫn đóng, bàn vẫn được dọn và trả về
  trống — xem §3.1.1 bước 12–13.
- **Không phải bấm gì ở trạm bếp để báo đã làm xong.** Ba trạm bếp không có nút "đã làm xong" hay
  "đã bưng ra bàn"; số lượng đã làm cho từng bàn được cập nhật ở POS (chủ quán chốt 2026-08-31,
  `shop-facts.md` §5.4). Luật này nói về **bếp**: từ 2026-09-01 có một nút *"đã làm xong"*, nhưng
  nó nằm ở **quầy** và **người đứng quầy** bấm — xem gạch đầu dòng ngay dưới.
- **Bấm "đã làm xong" cho món bếp đã làm xong nhưng chưa bưng ra** — việc của **người đứng quầy**
  (chủ quán chốt 2026-09-01, `shop-facts.md` §5.4). Món gấp xong có nằm chờ thật — chờ đủ đĩa, chờ
  người rảnh tay bưng, chờ món khác của cùng bàn — nên *làm xong* và *ra tới bàn* là hai việc, và
  bảng ở quầy đếm chúng bằng hai con số. **Bấm theo MẺ** (chủ quán chốt 2026-09-01,
  `shop-facts.md` §5.4): một lần bấm ứng với một mẻ bếp vừa làm xong, không bấm từng cái và không
  bấm cả bàn.
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
- **Không gom mẻ thay người.** Hệ thống chỉ hiện **tổng nhu cầu** để người tự gom; nó không tự
  chia mẻ, không xếp nồi, không quyết thứ tự làm và không đề xuất mẻ — *"máy không làm, để người
  làm"* (chủ quán chốt 2026-08-31, `shop-facts.md` §5.4). Cho máy chia mẻ là **đổi phạm vi**.
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
  kênh này, **gộp vào một phiên và tính tiền một lần**. Khách **ghép bàn** thì một phiên phủ nhiều
  bàn và vẫn chỉ một hoá đơn (§3.1.7).
- **Ba kênh không gắn phiên bàn — Delivery, Pickup, Đặt trước qua hotline.** Mỗi đơn là **một đơn
  vị thanh toán độc lập**, không gộp với đơn nào khác, kể cả cùng một khách đặt hai lần. Cả ba
  phải có thông tin để gọi lại được.

**"Đem về" không phải một kênh.** Khách **đang ngồi bàn** gọi thêm một suất để mang về thì suất ấy
đi vào **chính phiên bàn** đang mở, kèm note **"đem về"** — không mở đơn Pickup hay Delivery nào
(chủ quán chốt 2026-08-31, `shop-facts.md` §6.15). Nó vẫn là tiền của **phiên bàn**, vẫn nằm trong
một hoá đơn của bàn ấy. Đường ngược lại **không** tồn tại: một đơn Delivery, Pickup hay đặt trước
qua hotline không bao giờ nối được vào một phiên bàn (§2.4).

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
   bàn, trạng thái **đang mở**. Bàn nào còn một phiên chưa thanh toán thì không mở phiên thứ hai
   (§3.1.4). Nhóm đông ngồi **ghép** hai bàn thì vẫn là **một** phiên, gắn cả hai bàn (§3.1.7).
2. **Khách quét QR, hoặc nhân viên đặt hộ.** Hai đường vào, hai kênh: *Khách* quét QR tại chính
   bàn mình đang ngồi, hoặc *người đứng quầy* đặt hộ bằng Staff POS cho đúng số bàn ấy (nhánh đầy
   đủ ở §3.1.2). Cả hai đường đều đổ vào phiên của bàn đó.
3. **Khách chọn món.** *Khách* — hoặc *người đứng quầy* khi nhập hộ — chọn suất bán, chọn nhân và
   lượng nhân. Khách không gửi giá lên: *Hệ thống* tự xác định giá từ bảng giá và từ chối tổ hợp
   tuỳ chọn không hợp lệ (`shop-facts.md` §4.6 quy tắc 3 và quy tắc 9).
4. **Đơn được gửi.** *Khách* bấm gửi. Đơn vào phiên bàn ở trạng thái **chờ duyệt**, và **chưa sinh
   việc ở bất kỳ trạm nào** (§3.1.3).
5. **Quầy xác nhận.** *Người đứng quầy* duyệt đơn; đơn chuyển sang **đã duyệt**. Đơn khách tự gửi
   qua QR tại bàn mà quầy chưa duyệt thì đứng lại ở bước 4. Đơn do *người đứng quầy* nhập bằng
   Staff POS không đi qua bước này — nhân viên đã nhập thì đã có người chịu trách nhiệm (§2.2).
6. **Công việc được phân tới các trạm.** *Hệ thống* nổ đơn đã duyệt thành việc của từng trạm theo
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
- Đơn được **xác nhận ngay**, không có chặng chờ duyệt: đơn do nhân viên nhập thì không cần duyệt
  (§2.2).
- Đơn đi thẳng vào bước 6 — nổ ra việc cho các trạm.
- *Khách* gọi thêm sau đó bằng đường nào cũng được, quét QR hay lại nhờ quầy; mọi lượt vẫn vào
  **cùng** phiên ấy.

Nhánh này **không** tạo ra một đơn vị tính tiền thứ hai. Bàn 5 gọi hai lượt bằng QR tại bàn và một
lượt nhờ quầy đặt hộ vẫn là **một** phiên, **một** hoá đơn (§3.1.4).

#### 3.1.3 Đơn khách tự gửi bị chặn tới khi quầy duyệt

Bước duyệt tồn tại để **chặn đơn ảo**, nên nó chỉ áp cho đơn không ai chịu trách nhiệm (§2.2).

Điểm chặn nằm **giữa bước 4 và bước 6**: một đơn **QR tại bàn** đã gửi mà *người đứng quầy* chưa
xác nhận thì nằm nguyên ở trạng thái **chờ duyệt** và **không sinh một việc nào** ở cả năm trạm —
không tráng bánh, không gấp bánh, không nước chấm (`shop-facts.md` §6.2). Bếp không nhìn thấy đơn
đó.

Chặn ở đây là chặn **việc xuống bếp**, không phải chặn đơn khỏi phiên: đơn chờ duyệt **vẫn thuộc**
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
   **chờ duyệt** với hai kênh khách tự bấm và **đã duyệt** ngay với đơn hotline (bước 7). Đơn chỉ
   được tạo khi quán **đang nhận đơn** — trong giờ bán và chủ quán không bấm tạm dừng (§3.2.6).
   Ở bước này *Khách* được chọn **trả trước** thay cho đường mặc định là trả lúc nhận hàng; đó là
   **tuỳ chọn**, và chỉ đơn mang đi mới có nó (§3.2.5).
6. **Quán nhận thông báo.** *Hệ thống* báo đơn mới về quầy. *Người đứng quầy* là người nhìn thấy
   đơn đầu tiên, kể cả với đơn hotline do chính mình vừa nhập.
7. **Quầy xác nhận đơn khách tự gửi.** *Người đứng quầy* duyệt đơn **Delivery** và **Pickup**;
   đơn chuyển từ **chờ duyệt** sang **đã duyệt**. Đơn **Đặt trước qua hotline** *không* đi qua
   bước này — nhân viên đã nhập thì đã có người chịu trách nhiệm (§2.2). Đơn chưa duyệt **không
   sinh việc ở bất kỳ trạm nào** (`shop-facts.md` §6.2), đúng như đơn tại bàn ở §3.1.3.
8. **Quán chuẩn bị món và đóng gói.** *Hệ thống* nổ đơn đã duyệt thành việc của từng trạm theo
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
  **đã duyệt** (§2.2, bước 7).
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

**Một lượt gọi đã tạo thì đã xong chuyện giá**, dù nó đang ở trạng thái nào — chờ quầy duyệt, đang
làm ở bếp, đang giao, hay chờ thanh toán. Ranh giới là thời điểm **tạo lượt gọi**, không phải thời
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
  (`docs/architecture.md`), không phải của tài liệu sản phẩm.
- **Thêm món mới, hoặc đổi bảng giá thành một cấu trúc khác.** Thêm món ngoài `shop-facts.md` §4.2
  là **đổi phạm vi**, quyền chủ quán (`shop-facts.md` §6.12).
- **Ai được xem lại lịch sử đổi giá, và xem ở đâu.** Mọi thao tác chạm tiền đều phải kiểm chứng lại
  được (§1.4), nhưng màn hình nào bày ra việc đó là câu của §7 (BA-09).

## 4. Giá và thanh toán

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

**Tổng của một phiên bàn = tổng các lượt gọi thuộc phiên ấy, mỗi lượt tính theo giá đã khoá của
chính nó.** Không có phép tính nào lấy giá hiện tại nhân với số suất của cả phiên; làm thế là hỏng
đúng ca hai mức giá ở trên. Với **nhóm bàn ghép**, "phiên ấy" phủ mọi bàn trong nhóm — vẫn một
hoá đơn (§3.1.7, `quality/invariants.md` I-002).

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

**Một lần thu chọn một phương thức.** Chủ quán mô tả lựa chọn của khách là *"tiền mặt **hoặc**
VietQR"* (`shop-facts.md` §1, §6.3), nên mục này viết theo nghĩa ấy. Ca khách muốn trả **một phần
tiền mặt, một phần chuyển khoản** chưa ai hỏi chủ quán — nó là **U-020** ở mục *Unknowns*, đừng để
việc thực hiện tự quyết thay.

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

**Hoàn tiền rơi vào doanh thu ngày nào thì CHƯA CHỐT** — xem **U-019** ở mục *Unknowns*, và giả
định đang dùng ở §4.10.

### 4.9 Đối soát cuối ngày — ngưỡng lệch là 0đ

**Đây là quy trình của quán, không phải một tính năng phần mềm.** Mỗi tối, trong **2 tuần đầu chạy
thật**, người của quán đối chiếu **doanh thu hệ thống** với **sổ giấy** và **tiền trong két**
(`shop-facts.md` §6.10). **Lệch 1 đồng cũng phải tìm ra lý do** — ngưỡng chấp nhận là **0đ**, và
đây là cổng chất lượng mạnh nhất của cả dự án, mạnh hơn mọi bài kiểm thử.

Sổ giấy không phải thứ chép cho vui: nó là **kế hoạch dự phòng bắt buộc** (`shop-facts.md` §6.11)
— mất điện, mất mạng hay máy hỏng thì quán ghi tay và **không dừng bán**. Nên buổi tối luôn có hai
bản ghi độc lập để so.

**Bốn chuyện làm hai con số lệch nhau một cách HỢP LỆ.** Cả bốn đều phải có tên trong bảng đối
soát; không bày ra thì đúng luật *lệch một đồng cũng phải tìm ra lý do* sẽ báo động giả mỗi ngày:

| Chuyện xảy ra trong ngày | Két so với doanh thu | Vì sao vẫn đúng |
|---|---|---|
| **Ghi nợ** | két **thiếu** đúng bằng tổng nợ ghi trong ngày | doanh thu tính vào ngày ghi nợ, tiền thì chưa về (§3.1.6) |
| **Thu nợ cũ** | két **thừa** đúng bằng tổng nợ cũ thu hôm đó, doanh thu hôm đó **không tăng** | trả nợ là tiền về, không phải một lần bán mới |
| **Hoàn tiền** | két **thiếu** đúng bằng tổng đã hoàn | mỗi lần hoàn có vết riêng: bao nhiêu, đơn nào, ai bấm, lý do (§4.8) |
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

**GIẢ ĐỊNH đang dùng, chưa hỏi chủ quán** *(câu §10.8 · **U-019** · chuyển sang BA-10 nếu tới lúc
đó vẫn chưa có lời giải)*: một lần **hoàn tiền** hoặc một lần **huỷ đơn đã trả trước** được **trừ
vào doanh thu của ngày bán gốc**, không phải ngày bấm hoàn — cùng logic với nợ ở trên: sửa lại con
số của chính bữa ăn đó thay vì tạo một khoản âm ở ngày khác.

**Rủi ro nếu giả định này sai:** doanh thu của một ngày **đã đối soát xong** sẽ đổi khi có người
hoàn tiền vào hôm sau, tức phá đúng thứ I-009 giữ — *đọc lại doanh thu của mọi ngày đã qua phải ra
đúng con số đã đối soát hôm đó*. Chủ quán chốt ngược lại (trừ vào ngày bấm hoàn) thì phải sửa §4.9,
§4.10 và cách bày bảng đối soát; **không** phải sửa dữ liệu quá khứ, vì cả hai mốc thời gian —
ngày bán và ngày hoàn — đều đã được ghi.

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

**Hai câu mở ngày 2026-09-01 (BA-06), cả hai đều là câu về TIỀN.** Năm câu mở trước đó trong
cùng ngày — U-014, U-015, U-016 (mốc đổi menu/giá, T-034) và U-017, U-018 (T-036, T-037) — đều đã
được chủ quán trả lời trong ngày và đã chuyển xuống mục *Đã có lời giải*.

- **U-019 — Buổi tối đối soát, quán lấy gì ra đối chiếu phần khách chuyển khoản, và một lần hoàn
  tiền thì trừ vào doanh thu của ngày nào?** Két chỉ giữ **tiền mặt**, mà `shop-facts.md` §6.10 lại
  bắt so doanh thu với **sổ giấy và tiền trong két**, ngưỡng lệch **0đ** — nên phần VietQR không
  có chỗ nào để so, và mỗi lần hoàn tiền lại làm hai ngày lệch nhau. *Ai trả lời được:* **chủ
  quán** (hỏi về cái quán: *"tối về anh chị ngồi tính tiền thế nào — phần khách chuyển khoản thì
  nhìn vào đâu để biết đủ hay thiếu?"*). *Đang chặn:* `docs/product.md` §4.9 và §4.10 đang chạy
  bằng một **giả định** viết thẳng ở §4.10 (hoàn tiền trừ vào ngày bán gốc); **BA-08** (§6 ngoại
  lệ) và **BA-10** sẽ phải chốt hoặc chuyển nó thành giả định có tên. Đây là câu §10.8 của bảng
  mười câu hỏi trong `work/backlog.md`.
- **U-020 — Khách trả một phần tiền mặt, một phần chuyển khoản thì quán có nhận không?**
  `shop-facts.md` §1 và §6.3 luôn nói *"tiền mặt **hoặc** VietQR"*, nên `docs/product.md` §4.6 hiện
  viết là **một lần thu chọn một phương thức** — nhưng chưa ai hỏi thẳng chủ quán câu này. *Ai trả
  lời được:* **chủ quán** (hỏi về cái quán: *"có khi nào khách đưa một ít tiền mặt rồi chuyển khoản
  nốt phần còn lại không?"*). *Đang chặn:* không chặn task nào ngay, nhưng nó quyết định một lần
  thu tiền được ghi thành **một** hay **nhiều** khoản — sai thì đối soát 0đ (§4.9) không bao giờ
  khớp ở những ngày có ca đó. **BA-07** (§5 vòng đời) và **BA-10** phải đọc câu này.

Hình dạng của mục là hợp đồng với `scripts/brief.sh` (ADR-007): mỗi câu ở trên là **một gạch đầu
dòng**, và câu tiếp theo cũng phải vào đây dưới dạng ấy. `master_plan/shop-facts.md` §7.2 — chỗ
giữ các mục **suy ra** chưa xác nhận — vẫn rỗng từ 2026-09-01, khi S-4 có lời giải; hai câu trên
là **câu hỏi chưa ai trả lời**, không phải chỗ suy ra.

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

<a id="da-co-loi-giai"></a>
### Đã có lời giải — không ghi lại thành Unknown nữa

Ngày **2026-08-31** chủ quán trả lời một loạt sáu câu (T-028). Một câu thứ bảy — U-006 — chỉ được
trả lời **một nửa**, nên nó ở lại mục *Đang mở* với phạm vi hẹp hơn.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-31) | Ghi ở |
|---|---|---|
| ~~U-005 — đơn trả trước trả bằng gì, ai xác nhận, lúc nào~~ | **Tiền mặt hoặc VietQR** — không có phương thức thứ ba; **POS xác nhận vào lúc nhận tiền**, không phải lúc khách bấm chọn trả trước | `shop-facts.md` §6.3 |
| ~~U-007 — khách rời quán chưa trả tiền thì ai đóng phiên~~ | **Quán cho nợ.** Quầy vẫn đóng phiên, và lúc đóng POS **bắt buộc ghi ai nợ, nợ bao nhiêu** | §3.1.6 · `shop-facts.md` §6.14 |
| ~~U-008 — một nồi làm được bao nhiêu, trứng và bánh có tranh nhau nồi không~~ | **2 nồi.** Một nồi một lần tráng làm được **3 trứng**, *hoặc* **2 bánh**, *hoặc* **1 trứng + 1 bánh** ⇒ trứng và bánh **tranh nhau cùng một nồi** | `shop-facts.md` §5.4 |
| ~~U-009 — ai bấm "đã làm xong" / "đã bưng ra bàn"~~ | **Bỏ bước ấy đi.** Không có nút bấm nào ở trạm bếp; **POS tự cập nhật** số đã làm cho từng bàn | `shop-facts.md` §5.4 |
| ~~U-010 — đơn mang đi có chung bảng gom việc với bàn không~~ | **Không.** Nhưng khách **đang ngồi bàn** gọi suất đem về thì suất ấy thuộc **phiên bàn**, kèm note **"đem về"** phải rõ ràng | §2.1 · §3.1.4 · `shop-facts.md` §6.15 |
| ~~U-011 — máy có được tự chia mẻ không~~ | **Không.** Hệ thống **chỉ hiện tổng nhu cầu** để người tự gom — *"máy không làm, để người làm"* | §1.4 · `shop-facts.md` §5.4 |
| ~~U-006 — ghép bàn thì hệ thống phải làm gì~~ | **MỘT phiên và MỘT hoá đơn.** Một phiên gắn được nhiều bàn; *"một bàn một phiên"* đọc lại thành *"một bàn thuộc nhiều nhất một phiên"* | §3.1.7 · `shop-facts.md` §6.16 |

U-006 đi hai nhịp trong cùng ngày: sáng chỉ chốt được *ghép bàn là chuyện có thật*, chiều chốt nốt
*một phiên, một hoá đơn*. Nhịp thứ hai làm lộ ra **U-013**, và U-013 được trả lời nốt trong cùng
ngày (bảng dưới) — ca *ghép hai bàn đều đang có phiên* bị **đóng bằng quyết định**: không ghép
được, nên không bao giờ có việc gộp hai hoá đơn.

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

Ngày **2026-08-31**, hai câu cuối cùng đóng nốt:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-31) | Ghi ở |
|---|---|---|
| ~~U-012 — nợ trả sau thì ai ghi nhận, doanh thu tính ngày nợ hay ngày trả~~ | **POS ghi nhận**; doanh thu tính vào **ngày ghi nợ**, không phải ngày thu được tiền | §3.1.6 · `shop-facts.md` §6.14 |
| ~~U-013 — ai được bấm ghép bàn, ghép được khi bàn kia đang mở không~~ | **Người đứng quầy bấm trên POS**; **chỉ ghép được khi bàn kia còn trống** | §3.1.7 · `shop-facts.md` §6.16 |

Lời giải U-013 đóng luôn ca đáng sợ nhất mà câu hỏi ấy mở ra: **không bao giờ có việc gộp hai hoá
đơn đã có tiền trong đó.** Ghép bàn chỉ là nới một phiên sang bàn trống.

Ngày **2026-09-01**, ba câu BA-05 vừa mở được trả lời hết trong lượt kế tiếp (T-034):

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-014 — chủ quán có được lưu thay đổi giá ngay giữa giờ bán không~~ | **Được** — *"không phải chờ đến hết buổi"*; hiệu lực từ lúc lưu | §3.3.1 · `shop-facts.md` §6.17 |
| ~~U-015 — phiên bàn đang mở vắt qua mốc đổi giá thì hoá đơn ra sao~~ | **Lượt gọi trước mốc giữ giá cũ, lượt gọi sau mốc áp giá mới** ⇒ một hoá đơn mang **hai mức giá**, và như thế là đúng | §3.3.6 · `shop-facts.md` §6.17 |
| ~~U-016 — có được đổi thành phần một suất trong lúc đang bán không~~ | **Không — phải chờ hết buổi bán.** Khác hẳn ba chiều tiền | §3.3.2 · `shop-facts.md` §4.5 · §6.17 |

Ba câu ra **hai** luật, không phải một: chiều **tiền** sửa lúc nào cũng được, chiều **thành phần
suất** phải chờ. §3.3.2 giữ ranh giới đó trong một bảng; nhớ nó thành một mốc duy nhất là làm sai
đúng chiều đắt nhất.

Cuối ngày **2026-09-01**, hai câu cuối — mỗi câu do một phiên mở — được trả lời nốt trong cùng một
lượt (T-037):

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-017 — bấm "đã làm xong" theo từng cái, cả mẻ, hay cả bàn~~ | **Theo MẺ** — một lần bấm ứng với một mẻ bếp vừa làm xong | §1.2 · `shop-facts.md` §5.4 |
| ~~U-018 — máy chặn hẳn hay chỉ nhắc khi sửa thành phần suất giữa giờ bán~~ | **Chỉ nhắc một câu, rồi vẫn cho lưu** — luật *"chờ hết buổi"* là luật cho **người** | §3.3.6 · `shop-facts.md` §6.17 |

Lời giải U-018 buộc **viết lại `quality/invariants.md` I-011**: bản đầu nói *"thành phần suất không
đổi trong giờ bán"*, và câu đó sai kể từ lúc biết máy không chặn. Thứ sản phẩm giữ được là chuyện
đó không xảy ra **âm thầm** — nhắc trước, để vết sau. Một invariant hệ thống không giữ nổi thì
không phải invariant.

`master_plan/shop-facts.md` §7.2 — chỗ giữ các mục **suy ra chưa xác nhận** — rỗng từ
2026-08-30 tới 2026-08-31, rồi giữ đúng một mục **S-4** từ 2026-08-31, và **rỗng trở lại từ
2026-09-01** khi S-4 có lời giải. Tài liệu nào còn nói "ba chỗ suy luận chưa ai xác nhận", hay
"§7.2 giữ S-4", là pointer cũ. S-4 nằm ở §7.2 chứ không nằm ở đây vì nó là **chỗ suy ra**, không
phải câu chưa ai hỏi (`work/findings.md` F-004).

**S-4 đã đóng ngày 2026-09-01, sau khi hỏi hai lần.** Lần đầu (2026-08-31) chủ quán trả lời
*"tôi không hiểu"*: câu hỏi cũ bắt chủ quán suy ra hộ *một bảng trong máy nên hiện con số nào* —
một câu về mô hình dữ liệu, không phải về cái quán, tức **lỗi của người hỏi**. Câu viết lại hỏi về
**cái quán** — *từ lúc bánh tráng xong đến lúc nó xuống bàn, có nằm chờ không* — và được trả lời
ngay: **có**, vì chờ đủ đĩa, chờ người rảnh tay bưng, chờ món khác của cùng bàn. Câu thứ hai —
*ai nói cho máy biết món đã xong* — trả lời: **người đứng quầy bấm**. Cả hai ghi ở
`shop-facts.md` §5.4 và §7.1; bài học về cách hỏi ở lại §7.2. Lời giải này mở ra **U-017** ở trên
(bấm theo từng cái hay cả mẻ).
