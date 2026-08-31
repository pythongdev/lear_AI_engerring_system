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
  `shop-facts.md` §5.4).
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

> Chưa chốt — BA-04

### 3.3 Chủ quán đổi menu hoặc giá

> Chưa chốt — BA-05

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

**Không còn câu nào đang mở, tính tới 2026-08-31.** U-012 và U-013 — hai câu cuối — được chủ quán
trả lời trong ngày; cả hai đã chuyển xuống mục *Đã có lời giải*.

Mục này để trống là **trạng thái thật**, không phải mục bị bỏ quên: hình dạng của nó là hợp đồng
với `scripts/brief.sh` (ADR-007), nên câu tiếp theo phải là **một gạch đầu dòng** đặt ngay dưới
đây. Còn một chỗ **suy ra** chưa xác nhận — **S-4** — nhưng nó không sống ở đây, xem cuối mục.

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

`master_plan/shop-facts.md` §7.2 — chỗ giữ các mục **suy ra chưa xác nhận** — rỗng từ
2026-08-30 tới 2026-08-31; tài liệu nào còn nói "ba chỗ suy luận chưa ai xác nhận" là pointer cũ.
Từ **2026-08-31** nó giữ đúng một mục, **S-4**: *"đã làm xong, còn ở bếp" có phải một con số riêng
không* — sinh ra cùng lúc với U-008–U-011 ở trên, từ lời chủ quán về cách bếp gom việc theo mẻ.
S-4 nằm ở §7.2 chứ không nằm ở đây vì nó là **chỗ suy ra**, không phải câu chưa ai hỏi
(`work/findings.md` F-004).

**S-4 đã được hỏi ngày 2026-08-31 và vẫn chưa có lời giải:** chủ quán trả lời *"tôi không hiểu"*.
Câu hỏi cũ bắt chủ quán suy ra hộ *một bảng trong máy nên hiện con số nào* — một câu về mô hình dữ
liệu, không phải về cái quán. Đó là **lỗi của người hỏi**. `shop-facts.md` §7.2 nay giữ một câu
kiểm chứng **mới**, hỏi về cái quán thay vì về cái bảng; câu cũ được giữ lại nguyên văn ở đó làm
bằng chứng, **không phải để hỏi lại**.
