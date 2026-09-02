# §2 — Kênh bán

> Nguyên văn `docs/product.md` §2, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §2: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §2, tách 2026-09-02 ==== -->
## 2. Kênh bán

> **Quyết định gốc của mục này:** → **ADR-015** (năm kênh là danh sách đóng; `qr_table` ẩn danh
> theo bàn, ba kênh không gắn bàn bắt buộc số điện thoại) · **ADR-021** (giờ hẹn bắt buộc với
> `pickup` **và** `phone_preorder`; `delivery` có `Đang giao`) · **ADR-016** (ai duyệt, ai huỷ).

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

