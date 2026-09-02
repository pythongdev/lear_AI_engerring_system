# §7 — Phạm vi MVP

> Nguyên văn `docs/product.md` §7, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §7: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §7, tách 2026-09-02 ==== -->
## 7. Phạm vi MVP

> **Quyết định gốc của mục này:** → **ADR-031** (§7.6 ba mảng quản trị đi sau bán hàng) ·
> **ADR-024** (dòng 12 — *báo cáo doanh thu cơ bản* gồm cái vết tới đâu) · **ADR-015** (dòng 2 —
> năm kênh, không có kênh thứ sáu) · **ADR-028** (dòng 6 — đúng năm trạm).

*BA-09 — chốt 2026-09-02. Nguồn: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §9 (làm /
chưa chi tiết), §13 (rủi ro đi sớm vào kỹ thuật) + `master_plan/shop-facts.md` §2 (năm kênh), §3
(năm trạm), §6.10–§6.11 (đối soát, sổ giấy), §6.12 (bốn ranh giới đã chốt).*

Mục này **không đặt ra một luật nghiệp vụ nào**. Nó khoanh vùng cái §1–§6 đã chốt: cái gì làm ngay
ở giai đoạn đầu, cái gì không, và **vì sao không** — để lần sau có người đề nghị mở rộng thì đã có
chỗ đối chiếu thay vì cãi nhau bằng cảm tính.

### 7.1 Cách đọc mục này

- **Trong MVP** = làm ngay ở giai đoạn đầu, **và** §1–§6 đã mô tả nó. Hạng mục nào chưa trỏ được về
  một mục §1–§6 thì mục này nói thẳng ra ở §7.7, không viết bù hộ.
- **Ngoài MVP có HAI loại, không được trộn.** §7.4 là *chủ quán đã quyết định không làm* — mở lại
  phải xin phép chủ quán. §7.5 là *chưa ai cần tới, để sau* — mở lại chỉ cần một task. Viết chung
  một danh sách là biến quyết định của chủ quán thành một dòng chờ ai đó làm nốt.
- **Chưa xếp được cũng là một chỗ đứng.** §7.6 giữ ba mảng mà ranh giới **mảng quản trị (admin)**
  vừa mở (**§1.6**, 2026-09-02) nhưng chưa ai nói mảng nào phải có trong bản chạy đầu tiên. Chúng
  **không** bị đẩy sang §7.4 và **không** tự nhảy vào §7.2.
- **Danh sách này nói về năng lực nghiệp vụ, không nói về việc kỹ thuật.** Lý do ở §7.9.

### 7.2 Trong MVP — mười bốn năng lực

Đúng mười bốn dòng của kế hoạch gốc §9, không bớt dòng nào và không thêm dòng nào nghe hợp lý.

| # | Năng lực | Mô tả ở đâu |
|---|---|---|
| 1 | **Menu và giá** — món nào đang bán, giá một suất tính thế nào | §3.3, §4.1–§4.3 |
| 2 | **Năm kênh bán** — `delivery` · `pickup` · `qr_table` · `staff_pos` · `phone_preorder` | §2, §2.1 |
| 3 | **Đặt món** — khách tự bấm, hoặc quầy nhập hộ; hệ thống tự tính giá | §3.1.1 (bước 1–4), §3.1.2, §3.2.1 (bước 1–5), §4.2 |
| 4 | **Quản lý phiên bàn** — một bàn một phiên, ghép bàn vẫn một hoá đơn | §3.1.4, §3.1.7, §5.3 |
| 5 | **Xác nhận đơn** — đơn khách tự gửi phải qua quầy, đơn nhân viên nhập thì không | §2.2, §3.1.3, §3.2.1 (bước 7), §5.2 |
| 6 | **Điều phối công việc tới các trạm** — nổ một dòng đơn thành việc cho **đúng năm trạm** ở §1.5 | §1.5, §3.1.5, §5.4 |
| 7 | **Thu tiền** — hai đơn vị thanh toán, hai phương thức, và ca chưa thu được | §4.5, §4.6, §4.7 |
| 8 | **Đóng phiên và dọn bàn** — bàn chỉ trống sau khi đóng **và** dọn | §3.1.4, §5.3 |
| 9 | **Quản lý menu cơ bản** — bật/tắt món, sửa giá, và đơn cũ không đổi theo | §1.3, §3.3.1, §3.3.4 |
| 10 | **Quản lý nhân viên cơ bản** | §1.3 — ⚠ mới có **một dòng**, xem §7.7 |
| 11 | **Quản lý bàn** — danh sách bàn và trạng thái của một cái bàn | §1.3, §3.1.4, §5.3 — ⚠ một nửa, xem §7.7 |
| 12 | **Báo cáo doanh thu cơ bản** — cộng từ **đủ hai nguồn** | §1.3, §4.9, §4.10 — ⚠ "cơ bản" gồm gì, xem §7.7 |
| 13 | **Thông báo đơn** — đơn mới nổ về quầy | §3.2.1 (bước 6) — ⚠ một câu, xem §7.7 |
| 14 | **Cơ chế dự phòng khi realtime không hoạt động** | §6.1 (dòng 11–12), §6.2 — kèm **đường nhập lại** phần bán tay, xem §7.3 |

**Dòng 2 đọc là NĂM, không phải bốn.** Kế hoạch gốc §9 viết *"Bốn kênh bán"*, vì nó viết **trước
2026-08-29** — ngày chủ quán chốt `phone_preorder` là một **kênh riêng**, không phải đơn `staff_pos`
không gắn bàn (`shop-facts.md` §2, §2.3 trên đây). Dòng ấy trong kế hoạch gốc nay đã sửa thành năm.
**Không có kênh thứ sáu** — thêm một kênh là việc của §7.4, không phải của MVP.

**Dòng 6 khoanh đúng năm trạm ở §1.5**, không mở thành *"cấu hình trạm tuỳ ý"*. Trạm thứ sáu là đổi
cách quán vận hành, phải hỏi chủ quán (§1.5). **Trục còn thiếu:** quán làm theo **mẻ**, không làm
lần lượt từng suất (`shop-facts.md` §5.4) — trục ấy có mặt trong MVP nhưng chưa có mục nào của
tài liệu này mô tả nó; §3.4 (BA-12) là chỗ của nó, xem §7.7.

### 7.3 Hai việc VẬN HÀNH bắt buộc nằm trong MVP

Hai dòng dưới đây **không phải tính năng phần mềm** — chúng là **việc quán làm bằng tay**. Chúng
nằm trong MVP vì `shop-facts.md` §6.10 và §6.11 coi chúng là bắt buộc, và phần mềm phải làm ra để
chúng chạy được chứ không cản chúng.

| Việc của quán | Phần mềm phải chịu được gì | Mô tả ở đâu |
|---|---|---|
| **Đối soát doanh thu cuối ngày** — mỗi tối, hai tuần đầu chạy thật, đối chiếu **ba** nguồn: sổ giấy · tiền trong két · tin nhắn báo có. **Lệch 1 đồng cũng phải tìm ra lý do** | Doanh thu chia **theo phương thức**, không cộng gộp; mọi thao tác chạm tiền truy ngược được về một người và một thời điểm | §4.9, §4.10 · `shop-facts.md` §6.10 |
| **Quy trình sổ giấy khi mất điện / mất mạng / POS hỏng** — quán ghi tay và **không dừng bán** | Không được là chỗ dựa duy nhất để bán hàng (§1.4); phần bán tay phải quay lại được vào hệ thống trong **cùng ngày**, nếu không thì đối soát ngưỡng 0đ vô nghĩa | §6.1 (dòng 11–12), §6.2 · `shop-facts.md` §6.11 |

**Dòng thứ hai kéo theo một năng lực thứ ba, và nó cũng ở trong MVP.** U-025 đóng ngày
**2026-09-02**: **POS hoặc chủ quán** giữ sổ và là người **nhập lại**, **ngay khi có thể** và
**không có mốc giờ cứng**; có điện lại giữa buổi thì làm tiếp trên hệ thống, phần ghi tay cập nhật
sau (`shop-facts.md` §6.11). ⇒ MVP **phải có một đường nhập lại** phần bán bằng sổ giấy — không có
nó thì §4.9 không bao giờ đối soát nổi một ngày mất điện, và ngưỡng **0đ** thành vô nghĩa. Đường ấy
**bằng màn hình nào, hình dạng ra sao** thì §7 không nói: đó là việc của mục mô tả nó (§7.7) và của
pha System Design, không phải của một mục khoanh phạm vi.

### 7.4 Ngoài MVP vì CHỦ QUÁN ĐÃ QUYẾT không làm

Không phải *"để sau"*. Đây là **quyết định**, và mở lại bất kỳ dòng nào là **đổi phạm vi, quyền
chủ quán** — một task trong `work/backlog.md` không đủ để mở, phải có lời chủ quán.

| Không làm | Vì sao — lời đã chốt |
|---|---|
| **Kênh bán thứ sáu** | §2 chốt **đúng năm** kênh, không có kênh thứ sáu (`shop-facts.md` §2, §6.12) |
| **Đơn tối thiểu, bậc phí ship** | ship **0đ** và **không** có đơn tối thiểu là lời chốt, không phải giá trị mặc định chờ ai chỉnh (`shop-facts.md` §6.12, §3.2.6 trên đây) |
| **Số tài khoản ngân hàng cứng trong sản phẩm** | chủ quán **nhập trong phần quản trị**; VietQR ở quán là mã **tĩnh** (`shop-facts.md` §1, §6.12 · §1.3, §4.6 trên đây) |
| **Món ngoài bảng giá `shop-facts.md` §4.2** | thêm một món là đổi phạm vi (`shop-facts.md` §6.12) |
| **Máy tự chia mẻ, tự xếp nồi, tự quyết thứ tự làm** | *"máy không làm, để người làm"* (chủ quán chốt 2026-08-31, `shop-facts.md` §5.4 · §1.4 trên đây). Hệ thống chỉ hiện **tổng nhu cầu** |
| **Nút bấm báo xong ở ba trạm bếp** | chủ quán **bỏ bước ấy đi** 2026-08-31 (U-009). Cả hai mốc *đã làm xong* và *đã bưng ra bàn* đều bấm ở **POS quầy** (§5.4) |

### 7.5 Ngoài MVP vì chưa ai cần tới — để sau

Không nguồn nào — kế hoạch gốc, `shop-facts.md`, hay lời chủ quán — nhắc tới những thứ dưới đây.
Mặc định của một thứ không ai nhắc là **ngoài MVP**, không phải *"chắc là cũng cần"*.

| Không làm ở giai đoạn đầu | Lý do |
|---|---|
| **Khuyến mãi, giảm giá, mã giảm giá** | §4.2 chốt giá **do hệ thống xác định** từ bảng giá; một khoản giảm là một luật giá mới mà chủ quán chưa chốt bao giờ |
| **Tích điểm, khách hàng thân thiết** | hai kênh gắn bàn **ẩn danh theo bàn** (`shop-facts.md` §2) — quán không có định danh khách để cộng điểm vào |
| **Tách bàn, tách hoá đơn** | ngược thẳng với I-002 và §3.1.4: một phiên bàn là **một** hoá đơn. *(Chiều ngược lại — **ghép** bàn — thì **đã vào MVP**, xem ghi chú ngay dưới bảng)* |
| **Đặt bàn trước** | `phone_preorder` là đặt **món** trước, không phải giữ **bàn** (§2.3). Quán chưa bao giờ nói tới việc giữ chỗ |
| **Đánh giá món, phản hồi của khách** | không nguồn nào nhắc tới |
| **Tài khoản đăng nhập cho khách** | khách quét QR là xong, không có bước đăng nhập nào ở §3.1 hay §3.2 |
| **Nhiều chi nhánh, nhiều quán** | mọi dữ kiện ở `shop-facts.md` tả **một** quán |

**Một dòng của khuôn cũ nay chỉ còn đúng một nửa.** Khuôn BA-09 xếp *"tách/gộp bàn"* thành một dòng
ngoài MVP; khuôn ấy viết **trước 2026-08-31**. Ngày đó chủ quán trả lời U-006: **ghép bàn là chuyện
có thật**, một phiên gắn được nhiều bàn và vẫn **một** hoá đơn (`shop-facts.md` §6.16, §3.1.7 trên
đây). Nên **gộp bàn nằm TRONG MVP** (dòng 4 của §7.2) và chỉ **tách** là ở ngoài. Chép nguyên dòng
cũ vào đây sẽ loại bỏ một năng lực chủ quán đã chốt là có.

### 7.6 Mảng QUẢN TRỊ (admin) — được phép làm, nhưng KHÔNG mảng nào ở bản chạy đầu tiên

Ngày **2026-09-02** ranh giới mảng quản trị mở ra ba mảng — **nguyên liệu · con người · tài
chính** (**§1.6**, chủ quán chốt 2026-09-01 và xác nhận lại 2026-09-02). §1.6 nói rõ: mở ranh giới
là *được phép làm*, và **mảng nào vào MVP là câu của mục này**.

*Mục này mang nhãn admin vì nội dung của nó là mảng quản trị, đúng luật viết ở `docs/decisions.md`
**ADR-013**. Nó là một **ô của bảng phạm vi**, không phải chỗ thứ hai giữ ranh giới ba mảng — ranh
giới ở §1.6, mục này chỉ nói ba mảng ấy đứng đâu trong MVP.*

**Chủ quán chốt 2026-09-02 (trả lời U-030): KHÔNG mảng nào phải chạy cùng bản bán hàng đầu tiên.**
Nguyên văn: *"không mảng nào cần chạy với bán hàng. Bán hàng xong chạy được thì để chạy trước."*

⇒ **Thứ tự đã rõ: bán hàng chạy trước, ba mảng quản trị đi sau.** Đây là một **quyết định về thứ
tự**, không phải một lần loại bỏ — ranh giới §1.6 vẫn mở, ba mảng vẫn *được phép làm*.

Hai điều đọc kèm, vì chúng dễ bị nhớ nhầm thành ngược nhau:

- **Không mảng nào ở §7.2**, và nay có **hai** lý do độc lập cùng chỉ một hướng: (1) §7.2 có điều
  kiện vào cửa — *§1–§6 đã mô tả nó* — mà §2–§6 **chưa có một quy tắc nghiệp vụ nào** cho ba mảng;
  (2) chủ quán vừa nói thẳng là **không cần** chúng ở bản chạy đầu. Trước 2026-09-02 chỉ có lý do
  thứ nhất, và nó là lý do **của tài liệu**; nay có thêm lý do **của chủ quán**.
- **Ba mảng này vẫn không thuộc §7.4 và cũng không thuộc §7.5.** Không phải *"đã quyết định không
  làm"* (§7.4) — ngược lại, chủ quán vừa mở ranh giới cho chúng hai lần. Không phải *"chưa ai cần
  tới"* (§7.5) — có người cần, chỉ là **cần sau**. Chỗ đứng đúng vẫn là mục này, nhưng câu mô tả
  nay đổi: **được phép, chưa có luật, và đã có thứ tự — đi sau bán hàng.**

⇒ **Hệ quả cho việc xếp lịch:** ADM-01…ADM-52 ở `work/admin-questions.md` §2 nay có một mốc để xếp
quanh — không phải *"chưa biết bao giờ"* mà là *"sau khi luồng bán hàng chạy được"*. Điều kiện vào
cửa §7.2 **không đổi**: một mảng chỉ vào MVP khi §1–§6 đã có luật nghiệp vụ cho nó.

`work/admin-questions.md` giữ 55 câu hỏi và danh sách việc ADM-01…ADM-52 cho ba mảng ấy. Đó là
**working state**, không phải phạm vi: một dòng ở đó không vào MVP cho tới khi nó có luật ở §1–§6
và có tên trong §7.2.

### 7.7 Bốn chỗ MVP còn thiếu mô tả ở §1–§6

Bốn dòng dưới đây **đang trong MVP** (§7.2 và §7.3) nhưng chưa trỏ được về một mô tả đủ để làm.
Ghi ra đây thay vì viết bù, đúng như khuôn BA-09 dặn — viết bù là đặt ra luật nghiệp vụ mới, việc
mà một mục L1 không được làm.

| Chỗ thiếu | Hôm nay có gì | Ai lấp, bằng cách nào |
|---|---|---|
| **Trục sản xuất theo mẻ** (dòng 6) | dữ kiện đã đủ và đã chốt (`shop-facts.md` §5.4, `docs/decisions.md` ADR-009), nhưng tài liệu này chưa có mục nào cho nó | **§3.4 — BA-12.** Đây là **lát cắt thứ tư**, cộng ngang qua mọi bàn và mọi đơn nên không có chỗ trong §3.1 hay §3.2 |
| **Quản lý nhân viên cơ bản** (dòng 10) | đúng **một** gạch đầu dòng ở §1.3: *"Quản lý nhân viên và bàn"*. Không mục nào nói thao tác nào có, thao tác nào không | câu hỏi cho **chủ quán**, và nó chồng lên mảng **con người** vừa mở ở §7.6 — nên nó đi cùng **U-030**, không tách ra thành một câu riêng |
| **Báo cáo doanh thu "cơ bản"** (dòng 12) | §4.9 và §4.10 chốt **cách cộng** doanh thu và ngưỡng lệch **0đ**; chưa mục nào chốt báo cáo **bày ra những chỉ số nào** | **BA-10** gom, hoặc một task riêng. Không chặn: cách cộng đã đúng thì thêm một chỉ số không phá gì |
| **Thông báo đơn** (dòng 13) | một câu ở §3.2.1 bước 6 — *hệ thống báo đơn mới về quầy* | chưa chặn ai ở pha BA. Báo **bằng đường nào** là System Design, nhưng *báo cái gì, cho trạm nào* thì còn thiếu |

**Chỗ thứ năm mới đóng trong ngày, và nó biến thành một chỗ thiếu MÔ TẢ.** **U-025** — sổ giấy:
ai giữ, ghi gì, nhập lại lúc nào — có lời giải **2026-09-02** (§7.3). Lời giải ấy nói **ai** và
**lúc nào**, nhưng **chưa** nói một lượt bán ghi tay gồm **những trường nào**, nên đường nhập lại
vẫn chưa có mô tả đủ để làm. Việc lấp nó là **ADM-52** ở `work/admin-questions.md` §2 — không chặn
BA-10 hay BA-12.

### 7.8 Yêu cầu ngoài hai danh sách này thì làm gì

**Một yêu cầu không có tên ở §7.2 hay §7.3 thì không được làm trong giai đoạn này.** Không thêm
lặng lẽ vì *"nó nhỏ thôi"*, không gộp vào một task đang chạy vì *"tiện tay"*.

Đường duy nhất là:

1. **Vào `work/backlog.md`** thành một task có mức rủi ro và có Acceptance (CLAUDE.md §3).
2. Nếu nó chạm một dòng của **§7.4** — bốn ranh giới `shop-facts.md` §6.12, máy chia mẻ, nút ở
   trạm bếp — thì **task là chưa đủ**: phải có lời **chủ quán** trước, và lời ấy đi về owner của
   nó (`master_plan/shop-facts.md`) trước khi ai viết một dòng nào.
3. Nếu nó là một **luật nghiệp vụ** chưa ai chốt thì nó là một câu ở *Unknowns*, không phải một
   hạng mục MVP (CLAUDE.md §3.5, §4).

**Mục này là chỗ đối chiếu, không phải hàng rào.** Nó không chặn được ai; cái nó làm được là khiến
việc mở rộng phải **nói ra thành lời** thay vì lặng lẽ chui vào một diff.

### 7.9 Bốn việc mục này cố ý không nói tới

- **Công việc kỹ thuật.** Kiến trúc BE và FE, cấu trúc dữ liệu, giao diện lập trình, thành phần
  giao diện, đóng gói và tích hợp liên tục, cấu trúc mô-đun, nền tảng lập trình — kế hoạch gốc §9
  xếp cả tám vào *"chưa cần chi tiết ở BA phase"*, và §13 cảnh báo đúng cái rủi ro đi sớm vào
  kỹ thuật. Không dòng nào trong số đó là một **năng lực** của MVP; chúng là cách làm ra năng lực.
  Chỗ của chúng là pha System Design, `docs/architecture.md`.
- **Thứ tự làm.** §7 nói *cái gì trong MVP*, không nói *làm cái nào trước*. Thứ tự nằm ở
  `work/backlog.md`.
- **Ngày tháng.** Không mục nào ở đây hứa một mốc thời gian. MVP là một **danh sách**, không phải
  một lịch.
- **Mức sâu của một năng lực đã có tên.** *"Quản lý menu cơ bản"* gồm đúng những thao tác §3.3 mô
  tả, không hơn; muốn hơn thì đi đường §7.8. §7 khoanh **có hay không**, còn **tới đâu** là việc
  của mục mô tả nó ở §1–§6.

