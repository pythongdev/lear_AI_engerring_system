# §1 — Actor và phạm vi hệ thống

> Nguyên văn `docs/product.md` §1, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §1: ~180 câu trong repo trỏ theo số cũ.
> Kèm phần mở đầu của bản lưu (12 dòng đầu). §1.6 tách sang `0-ba/admin/`.

<!-- ==== nguyên văn docs/product.md §1, tách 2026-09-02 ==== -->
# Product

Hành vi nghiệp vụ của sản phẩm. Mỗi mục dưới đây do một task BA chốt.

> **Dữ kiện quán không sống ở đây.** Giá, phụ thu, giờ bán, số bàn, thành phần một suất bán và
> các quy tắc vận hành thuộc `master_plan/shop-facts.md` (ADR-001). File này mô tả *sản phẩm phải
> hành xử thế nào* dựa trên các dữ kiện đó; chỗ nào cần một con số, tra ở owner, đừng chép về đây.
>
> **Mảng bán hàng và mảng quản trị (admin) không viết chung một mục.** Mục nào thuộc mảng admin thì
> tên mục mang chữ **(admin)** — hôm nay là **§1.6**. Đọc tên mục là biết mục ấy thuộc phần nào
> (`docs/decisions.md` **ADR-013**).

## 1. Actor và phạm vi hệ thống

> **Quyết định gốc của mục này:** → **ADR-028** (năm trạm; chủ quán đứng quầy vẫn là chủ quán) ·
> **ADR-016** (POS ở quầy là cửa ghi duy nhất, quyền gắn với chỗ đứng) · **ADR-031** (§1.6 — ba
> mảng quản trị được phép, nhưng đi sau bán hàng) · **ADR-011**, **ADR-013**.
> Lý do, cái bị bác và ngày chốt ở `docs/decisions.md`; mục này không chép lại.

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
  Với đơn khách **đã chọn trả trước** thì *người đứng quầy* bấm xác nhận **vào lúc nhận tiền**,
  không phải lúc khách đặt (chủ quán chốt 2026-08-31, đóng **U-005**; `shop-facts.md` §6.3, và
  §3.2.5 · §4.6 viết đủ cả hai phương thức).
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

**Mảng quản trị (admin) có ranh giới RIÊNG — đọc §1.6.** Danh sách trên nói về mảng **bán hàng**.
Nguyên liệu, con người và tài chính là mảng khác, ranh giới của chúng nằm ở mục riêng ngay dưới, và
từ 2026-09-02 nó **không còn** nằm trong danh sách *KHÔNG chịu trách nhiệm* ở trên.

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

