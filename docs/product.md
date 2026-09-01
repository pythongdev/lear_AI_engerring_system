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

## 5. Vòng đời nghiệp vụ

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

**Bắt đầu:** `Mới`. **Kết thúc:** `Hoàn thành` **hoặc** `Huỷ` — hai trạng thái kết thúc, không có
đường ra thứ ba.

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
| Đang thực hiện | Quầy huỷ đơn | **Huỷ** | *Người đứng quầy* — ranh giới huỷ tới đâu vẫn còn mở, **U-022** |
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

Hai chỗ của việc sửa đơn **chưa ai chốt**, và cả hai đều nằm ở **U-022**: sửa được **từ trạng thái
nào** — đơn bếp đang làm dở thì còn sửa được không, đơn đã `Hoàn thành` thì sao — và một dòng vừa
sửa **tính giá lúc nào**, vì §4.4 khoá giá theo *thời điểm tạo lượt gọi*. Chủ quán mới nói **ai
sửa** và **sửa được**; đừng đọc câu ấy rộng hơn chữ của nó (`work/findings.md` F-004). Đây cũng là
lý do dòng huỷ từ `Đang thực hiện` trong bảng còn để ngỏ ranh giới của nó.

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

### 5.6 Hai chuyển tiếp nghe có lý mà bị TỪ CHỐI

Luật ở §5.1 nói mọi chuyển tiếp ngoài bảng đều bị từ chối. Hai ca dưới đây được gọi tên vì chúng
nghe như hợp lý, và vì mỗi ca đều có người sẽ hỏi *"sao không cho?"*:

- **`Đã đóng` → `Đang phục vụ` (phiên bàn): không có đường quay lại, và đây là ca đã CHỐT.** Khách
  quay lại bàn ấy gọi tiếp thì đó là một **phiên mới**, một hoá đơn mới. Mở lại một phiên đã đóng
  là mở lại một hoá đơn đã thu tiền — thứ §3.3.3 và §4.4 khoá chặt.
- **`Hoàn thành` → `Huỷ` (đơn): bị từ chối vì CHƯA CHỐT, không phải vì đã chốt là cấm.** Kế hoạch
  gốc §8 liệt kê *"đơn đã hoàn thành nhưng cần điều chỉnh"* như một ngoại lệ phải xử. Ngày
  2026-09-01 chủ quán trả lời **một nửa** câu ấy — đơn đã xác nhận thì **sửa** được, trên POS
  (§5.2, `shop-facts.md` §6.19) — nhưng **không** nói sửa hay huỷ được **tới trạng thái nào**, nên
  nửa còn lại vẫn là **U-022**. Bảng §5.2 không có dòng ấy nên sản phẩm từ chối nó; đó là trạng
  thái **tạm thời của tài liệu**, và §6 (BA-08) là chỗ nó được chốt.

**Ca thứ ba đã rời danh sách này ngày 2026-09-01.** `Đã làm xong, còn ở bếp` → `Chưa làm` từng nằm
đây với ghi chú *"quầy bấm nhầm một mẻ thì hôm nay không có đường lùi"*. Chủ quán trả lời U-024 là
**có** đường lùi, nên nay nó là một **dòng hợp lệ** trong bảng §5.4 chứ không còn là ca bị từ chối.
Ghi lại chỗ nó từng đứng để phiên sau đọc §5.6 cũ không tưởng là tài liệu tự mâu thuẫn.

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

## 6. Ngoại lệ

Mục này chốt **cách quán xử lý**, không chốt cách máy làm. Mỗi dòng nói ba thứ: **ai xử lý**, đơn
hoặc phiên **về trạng thái nào** (tên trạng thái lấy nguyên ở §5), và **tiền** ra sao (luật ở §4).
Cách hệ thống kỹ thuật thực hiện — thử lại, hàng chờ, bộ nhớ đệm khi mất mạng — **không** thuộc mục
này và cũng không thuộc giai đoạn BA.

Danh sách mười bốn tình huống lấy nguyên của kế hoạch gốc §8, không bớt dòng nào. Dòng nào chủ quán
**chưa** chốt thì mang dấu **⚠ Chưa chốt** và có một mục **GĐ-XXX** tương ứng trong
`docs/decisions.md` kèm mức rủi ro — không dòng nào để trống lặng lẽ.

### 6.1 Bảng mười bốn tình huống

| # | Tình huống | Ai xử lý | Kết quả với đơn / phiên | Kết quả với tiền |
|---|---|---|---|---|
| 1 | **Khách gửi nhầm đơn QR** | *Người đứng quầy*, trên POS — khách **không** có cửa tự huỷ (`shop-facts.md` §6.13) | Đơn đang ở `Chờ xác nhận` ⇒ `Huỷ`. Chưa duyệt thì **chưa việc trạm nào được sinh** (I-004), nên không có gì phải rút khỏi bếp. Phiên bàn của nó **giữ nguyên** trạng thái đang có | Chưa thu ⇒ **không sinh việc gì về tiền** (§4.7). Đơn mang đi **đã trả trước** ⇒ sinh việc hoàn, xử theo §4.8 |
| 2 | **Quầy từ chối đơn QR** | *Người đứng quầy* (`shop-facts.md` §6.2, §6.13) | `Chờ xác nhận` ⇒ `Huỷ` — dòng có sẵn ở bảng §5.2. Đơn bị từ chối **không** vào hoá đơn của phiên | Không có gì: đơn chưa duyệt chưa bao giờ chạm tiền |
| 3 | **Khách gọi thêm sau khi quầy đã bắt đầu thu tiền** | *Khách* (QR tại bàn) hoặc *người đứng quầy* (đặt hộ) | Phiên `Chờ thanh toán` ⇒ **quay lại** `Đang phục vụ` (§5.3). Đơn mới đi vòng đời đơn bình thường | Vào **cùng phiên, cùng một hoá đơn** (`shop-facts.md` §6.1). Mở hoá đơn thứ hai là **thu thiếu tiền** — lỗi tiền nguy hiểm nhất của luồng tại bàn. Lượt gọi mới tính **giá tại thời điểm tạo lượt gọi** (§4.4) |
| 4 | **Hai người cùng thao tác trên một bàn** | ⚠ **Chưa chốt — `docs/decisions.md` GĐ-01** | ⚠ Chưa chốt | ⚠ Chưa chốt |
| 5 | **Món hết sau khi khách đã chọn** | ⚠ **Chưa chốt — `docs/decisions.md` GĐ-02** (câu 3 của bảng mười câu hỏi, `work/backlog.md`) | ⚠ Chưa chốt — xem ghi chú §6.3 bên dưới: hết **một thành phần** không phải chuyện của một dòng menu | ⚠ Chưa chốt |
| 6 | **Chủ quán tạm dừng nhận đơn** | *Chủ quán*, trên phần quản trị | Chặn đơn **mới**; nút này **thắng giờ mở cửa** (`shop-facts.md` §6.8, I-008). Đơn đang chạy **không** đổi trạng thái, việc đang làm ở bếp **không** dừng — không có trạng thái "tạm dừng" của việc trạm (§5.4) | Không đổi. Đơn đã nhận trước lúc bấm vẫn thu bình thường |
| 7 | **Khách huỷ đơn** | Khách **báo**, *người đứng quầy* bấm trên POS — quyền huỷ gắn với **chỗ đứng**, không gắn chức vụ (`shop-facts.md` §6.13) | `Chờ xác nhận`, `Đã xác nhận` hoặc `Đang thực hiện` ⇒ `Huỷ` (§5.2). Việc trạm chưa xong của đơn ấy **rời bảng bếp cùng lúc** (§5.4). **Ranh giới trên còn mở:** `Hoàn thành → Huỷ` hôm nay bị từ chối — **U-022**, và dòng 13 của bảng này | Chưa trả ⇒ không gì. **Đã trả trước** ⇒ hoàn theo §4.8: quầy quyết từng ca, **mọi lần đều để lại vết**, và khoản hoàn trừ vào doanh thu **ngày hoàn** |
| 8 | **Nhân viên huỷ đơn** | **Chỉ** *người đứng quầy*, trên POS. Bốn trạm còn lại (`trang_banh`, `gap_banh`, `canh`, `don_ban`) **không** huỷ được, kể cả đơn của chính việc mình đang làm. Chủ quán **không** đứng quầy thì **nhờ quầy bấm** — chức vụ không mở thêm cửa nào (`shop-facts.md` §6.13) | Như dòng 7 | Như dòng 7. Mọi lần huỷ đi qua **đúng một cửa**, nên lần nào cũng có đúng một người đứng tên khi đối soát (§4.9) |
| 9 | **Thanh toán thất bại hoặc chưa xác nhận được** | ⚠ **Chưa chốt — `docs/decisions.md` GĐ-03**. *Phần đã chốt:* VietQR ở quán là mã **tĩnh**, máy **không** tự biết tiền đã về; câu *"đã nhận tiền"* chỉ do **người bấm ở POS** tạo ra (`shop-facts.md` §6.3) | ⚠ Chưa chốt — khách nói đã chuyển mà quầy chưa thấy tin nhắn báo có thì phiên đi đường nào | ⚠ Chưa chốt. *Đã chốt phần kề bên:* thu được **một phần** thì phần thiếu là **nợ**, xử theo §4.7 (dòng 10) |
| 10 | **Khách rời bàn nhưng chưa thanh toán** | *Người đứng quầy*, trên POS (`shop-facts.md` §6.14) | Phiên `Chờ thanh toán` ⇒ `Đã đóng` — **tiền chưa thu không chặn phiên đóng** (§5.3, I-017). Bàn sang `Bàn cần dọn`, dọn xong về `Trống` | Quán **cho nợ**. Đóng phiên **bắt buộc ghi ai nợ và nợ bao nhiêu** — thiếu một trong hai thì khoản nợ vô chủ. Doanh thu tính vào **ngày ghi nợ**, không phải ngày thu được tiền; két thiếu đúng bằng tổng nợ ghi trong ngày (§4.7, §4.10) |
| 11 | **Mất mạng trong lúc quán đang phục vụ** | Cả quán chuyển cách làm; *người đứng quầy* giữ sổ (`shop-facts.md` §6.11) | **Không dừng bán.** Đơn và phiên vẫn chạy đúng các trạng thái §5, nhưng ghi **trên sổ giấy** thay vì trên máy | Thu bình thường, ghi sổ. Phần ghi tay phải nhập lại để đối soát cuối ngày còn đọc được (§4.9) |
| 12 | **Mất điện hoặc thiết bị POS gặp sự cố** | Như dòng 11 (`shop-facts.md` §6.11) | Như dòng 11 | Như dòng 11 |
| 13 | **Đơn đã hoàn thành nhưng cần điều chỉnh** | ⚠ **Chưa chốt — `docs/decisions.md` GĐ-04** (**U-022**). *Phần đã chốt:* đơn **đã xác nhận** thì **sửa** được, và sửa trên **POS** (`shop-facts.md` §6.19) | *Đã chốt:* **sửa đơn không phải một chuyển tiếp trạng thái** — đơn đang ở đâu vẫn ở đó, cái đổi là món / số suất / tuỳ chọn (§5.2). ⚠ *Chưa chốt:* sửa được **từ trạng thái nào**, và `Hoàn thành → Huỷ` hiện bị từ chối (§5.6) | ⚠ Chưa chốt: một dòng vừa sửa **tính giá lúc nào**, vì §4.4 khoá giá theo **thời điểm tạo lượt gọi**. Sửa đơn **chạm tiền** nên phải để lại vết như mọi thao tác chạm tiền khác (§4.9) |
| 14 | **Nhân viên thao tác nhầm trạng thái** | *Người đứng quầy*, trên POS | *Đã chốt cho ca hay xảy ra nhất:* bấm nhầm *"đã làm xong"* một **mẻ** ⇒ **lùi được**, `Đã làm xong, còn ở bếp` ⇒ `Chưa làm` (§5.4). **Không có mốc thời gian cứng** — quầy quyết từng ca. ⚠ **Chưa chốt — `docs/decisions.md` GĐ-05** cho **mọi thao tác nhầm khác** (duyệt nhầm, huỷ nhầm, đóng phiên nhầm) | Lùi một mẻ **phải để lại vết** — lùi mẻ nào, lúc mấy giờ, ai bấm: một mẻ lùi sai là một suất tính nhầm (I-012) |

### 6.2 Ba tình huống đã có lời giải từ trước, đọc thẳng ở đây

Ba dòng dưới đây **không** chờ ai chốt thêm; chúng đã là quy tắc của quán trước khi §6 được viết:

- **Gọi thêm khi quầy đang thu tiền** (dòng 3) — cùng phiên, cùng hoá đơn (`shop-facts.md` §6.1).
- **Tạm dừng nhận đơn** (dòng 6) — thắng giờ mở cửa, kể cả đang trong giờ bán (`shop-facts.md` §6.8).
- **Mất mạng / mất điện / POS hỏng** (dòng 11 và 12) — **sổ giấy, quán vẫn bán** (`shop-facts.md` §6.11).

### 6.3 Hết một THÀNH PHẦN, không phải hết một dòng menu

Dòng 5 của bảng còn mở, nhưng có một dữ kiện đã chốt phải đọc kèm nó, nếu không cả tình huống sẽ bị
hiểu sai cỡ:

- **Mọi suất bán đều gồm nhiều thành phần** (`shop-facts.md` §4.5) — kể cả suất trứng và suất giò
  đều kèm bốn cái bánh. Nên "hết món" ở quán này gần như luôn là **hết một thành phần**, và câu hỏi
  thật là: hết một thành phần thì làm gì với **cả suất**.
- ⇒ **Hết bánh cuốn là hết gần như mọi món.** Đây không phải một dòng menu tắt đèn; nó là phần lớn
  thực đơn tắt cùng lúc. Ai đọc dòng 5 như chuyện của một món lẻ là đọc sai quy mô.
- Đường xử lý **đã có** cho ca hết nguyên liệu là chủ quán bấm **tạm dừng nhận đơn** (dòng 6) —
  nhưng nút ấy chặn đơn **mới**, nó **không** trả lời câu hỏi của dòng 5: những đơn **đã nhận** rồi
  thì làm gì. Đó đúng là chỗ còn mở.

### 6.4 Bốn việc mục này cố ý không nói tới

- **Cách hệ thống kỹ thuật chịu lỗi.** Thử lại, hàng chờ, đồng bộ lại sau khi có mạng, lưu tạm dưới
  máy — §6 chốt **quán làm gì bằng tay**; phần máy là System Design, không phải BA.
- **Bất biến mới.** §6 mô tả cách xử lý, không thêm dòng nào vào `quality/invariants.md`. Cách xử lý
  ở đây phải **không phá** bất biến nào đang có — ba dòng chạm tiền nặng nhất (9, 10, 13) đã được
  đối chiếu với I-005, I-012, I-017.
- **Phạm vi MVP.** Ngoại lệ nào được làm ngay, ngoại lệ nào để sau: **§7** (BA-09).
- **Chốt các câu còn mở.** Năm dòng ⚠ ở trên là **câu hỏi cho chủ quán**, không phải chỗ để việc
  thực hiện tự quyết (CLAUDE.md §3.5). `docs/decisions.md` giữ giả định tạm thời và mức rủi ro của
  chúng cho tới khi có lời chốt.

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

**Bốn câu BA-07 mở ngày 2026-09-01 được chủ quán trả lời ngay trong ngày (T-039).** Ba câu đóng hẳn
— U-021, U-023, U-024 — và đã xuống mục *Đã có lời giải*. Câu thứ tư chỉ được trả lời **một nửa**,
nên nó **ở lại đây với phạm vi hẹp hơn**, đúng cách U-006 từng ở lại ngày 2026-08-31. **BA-08 mở
thêm U-025** ngày 2026-09-02: §6 chốt được rằng quán chuyển sang sổ giấy, nhưng không chốt nổi ai
giữ sổ và nhập lại lúc nào — đó là câu hỏi cho chủ quán, không phải chỗ để §6 tự quyết.

- **U-022 — Sửa và huỷ một đơn được phép tới trạng thái nào?** *Nửa đã có lời giải (2026-09-01):*
  đơn đã xác nhận thì **sửa được**, và **POS** là nơi sửa — không phải huỷ rồi tạo lại
  (`shop-facts.md` §6.19, `docs/product.md` §5.2). *Nửa còn mở:* chủ quán nói **ai sửa** và **sửa
  được**, chưa nói **tới đâu thì thôi** — sửa được khi bếp đang làm dở không, đơn đã `Hoàn thành`
  thì sửa hay không, và **huỷ** còn được phép tới trạng thái nào. Đi kèm là một câu về **tiền**
  cùng gốc: một dòng vừa sửa **tính giá lúc nào**, vì §4.4 khoá giá theo *thời điểm tạo lượt gọi*
  — sửa xong mà lấy giá mới thì §3.3.3 vỡ, lấy giá cũ thì khách đổi sang món đắt hơn vẫn trả giá
  rẻ. *Ai trả lời được:* **chủ quán** (hỏi về cái quán: *"khách đổi món lúc bếp đang tráng rồi thì
  quán sửa hay làm lại từ đầu — và lúc ấy tính tiền theo giá nào?"*). *Đang chặn:* dòng huỷ từ
  `Đang thực hiện` ở bảng `docs/product.md` §5.2 còn để ngỏ ranh giới, và ca `Hoàn thành → Huỷ` vẫn
  bị từ chối vì chưa chốt (§5.6). Đây là **câu 1 (phần sửa đơn) và câu 2** của bảng mười câu hỏi
  trong `work/backlog.md`; **BA-08** chốt, **BA-10** gom lần cuối.
- **U-025 — Mất điện hoặc mất mạng thì AI giữ sổ giấy, ghi những gì, và nhập lại vào hệ thống lúc
  nào?** *Nửa đã có lời giải (2026-08-30):* sổ giấy là phương án dự phòng **bắt buộc**, và quán
  **không dừng bán** (`shop-facts.md` §6.11, `docs/product.md` §6 dòng 11–12). *Nửa còn mở:* chủ
  quán chưa nói **ai** cầm quyển sổ, **ghi những trường nào** cho một lượt bán, và **ai nhập lại
  vào máy, lúc nào** sau khi có điện. *Ai trả lời được:* **chủ quán** (hỏi về cái quán: *"hôm mất
  điện thì ai ghi, ghi vào đâu, và lúc có điện lại thì ai gõ vào máy?"*). *Đang chặn:* đối soát
  cuối ngày ngưỡng **0đ** (§4.9) chỉ chạy được nếu phần bán tay quay lại được vào hệ thống **trong
  cùng ngày** — không có luật nhập lại thì mọi ngày mất điện đều lệch sổ mà không ai truy được. Và
  **§7** (BA-09) cần nó để biết MVP có phải làm màn hình nhập bù hay không.

Hình dạng của mục là hợp đồng với `scripts/brief.sh` (ADR-007): **mỗi** câu trên là **một gạch đầu
dòng**, và câu tiếp theo cũng phải vào đây dưới dạng ấy. `master_plan/shop-facts.md` §7.2 — chỗ giữ các mục
**suy ra** chưa xác nhận — nay giữ **một** mục, **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị nào),
mở cùng ngày 2026-09-01; đó là chỗ **suy ra**, không phải câu hỏi đang mở, nên nó không nằm ở đây.

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

**Ngày 2026-09-01, chủ quán trả lời ba câu BA-07 vừa mở, và cả ba ra cùng MỘT chỗ đứng: POS**
(T-039). Đây là lần thứ tư cùng một câu trả lời lặp lại — duyệt đơn (§6.2), huỷ đơn (§6.13), hoàn
tiền (§6.4), ghép bàn (§6.16), thu tiền, ghi nợ (§6.14) và nay cả hai mốc của bảng bếp đều đi qua
đúng **một** cái máy ở quầy.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-021 — ai nói cho máy biết một mẻ đã bưng ra bàn~~ | **POS** — người đứng quầy bấm, đúng chỗ đứng đã bấm *"đã làm xong"*; ba trạm bếp vẫn không bấm gì (U-009 nguyên vẹn) | `shop-facts.md` §5.4 · §5.4 trên đây |
| ~~U-023 — ai bấm cho đơn giao tận nơi sang *đang giao*, lúc nào~~ | **POS**, lúc đơn **rời quán**; mốc **ra** vẫn do *người đi giao* bấm cùng lúc với *đã thu tiền* | `shop-facts.md` §6.7 · §5.2 trên đây |
| ~~U-024 — bấm nhầm *đã làm xong* một mẻ thì có đường lùi không~~ | **Có đường lùi**, và **không có mốc thời gian cứng** — *"tuỳ theo thực tế để POS quyết định"* | `shop-facts.md` §5.4 · §5.4 và §5.6 trên đây |

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
| ~~U-019 — buổi tối lấy gì đối chiếu phần khách chuyển khoản~~ | **Tin nhắn báo có** — nguồn thứ **ba** của đối soát, đứng cạnh sổ giấy và tiền trong két; ⇒ đối soát chia theo **phương thức**, không cộng gộp | §4.9 · `shop-facts.md` §6.10 |
| ~~U-019 (vế 2) — một lần hoàn tiền trừ vào doanh thu ngày nào~~ | **Ngày HOÀN**, không phải ngày bán gốc — **ngược chiều** với luật nợ (nợ tính ngày ghi nợ) ⇒ doanh thu một ngày đã đối soát không bao giờ đổi về sau | §4.8 · §4.10 · `shop-facts.md` §6.4 |
| ~~U-020 — khách trả một phần tiền mặt, một phần chuyển khoản~~ | **Nhận cả hai.** POS ghi **bao nhiêu tiền mặt, bao nhiêu chuyển khoản**; tổng các phần = số phải trả. Chữ *"hoặc"* ở `shop-facts.md` §1 là lựa chọn của khách, **không** phải luật loại trừ | §4.6 · `shop-facts.md` §6.18 |

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
