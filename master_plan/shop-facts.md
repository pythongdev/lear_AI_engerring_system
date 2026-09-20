# Bánh cuốn Bà Thanh Cao Bằng — dữ kiện quán

> **Đây là nhà duy nhất của mọi dữ kiện về quán** — phạm vi bán, kênh bán, bảng giá, phụ thu,
> thành phần suất bán, luồng vận hành, quy tắc nghiệp vụ. Chỗ nào khác trong dự án nói khác file
> này ⇒ **file này thắng**, chỗ kia là bug phải sửa ngay. Không có bản chép thứ hai của bất kỳ
> con số nào; đổi giá thì sửa đúng một chỗ, là đây.
>
> **File này tự đứng một mình.** Ai chưa từng biết quán, đọc hết file này là nắm được: quán bán
> gì, bán cho ai qua đường nào, giá bao nhiêu, bếp làm ra cái gì, và tiền đi đường nào từ lúc
> khách gọi tới lúc bàn trống — không cần mở thêm tài liệu nào khác để hiểu một dữ kiện quán. File
> này có thể trích dẫn nơi khác (câu hỏi mở, quyết định, một lần sửa trong quá khứ) để chỉ đường,
> nhưng không dữ kiện quán nào ở đây phụ thuộc vào việc mở file khác mới hiểu đúng.
>
> **Hai mảng, hai chỗ.** §1–§7 là mảng **bán hàng**; **§8 là mảng quản trị (admin)** — nguyên liệu,
> con người, tài chính. Đọc số mục là biết mình đang ở mảng nào, và dữ kiện admin mới **chỉ** được
> viết vào §8.

---

## 1. Quán

| Mục | Giá trị |
|---|---|
| Tên | Bánh cuốn Bà Thanh Cao Bằng |
| Hotline | `0382688666` |
| Giờ bán | **06:00 – 11:00**, tất cả các ngày |
| Múi giờ | `Asia/Ho_Chi_Minh` |
| Số bàn | **15** |
| Thanh toán | Tiền mặt tại quầy · Chuyển khoản **VietQR tĩnh** |
| Báo đơn web mới về quầy | **Telegram** — bot gửi tin nhắn báo đơn mới vào quầy |
| Hạ tầng vận hành | **Một VPS** duy nhất chạy toàn bộ hệ thống |

**Hai dòng "Báo đơn web mới" và "Hạ tầng vận hành" chốt 2026-09-07 (chủ repo).** Đây là chỗ đặt
tên cho hai phụ thuộc mà `docs/product/1-system-design/01-ranh-gioi-he-thong.md` gọi là **PT-5**
(*đường báo đơn web về quầy*) và **PT-2** (*nơi hệ thống chạy*) — bảng đó ghi **cái quán dựa vào**
chứ không ghi **tên của thứ đảm nhiệm nó**, và `work/findings.md` **F-027** (2026-09-04) từng đo
được rằng hai cái tên ấy trước đó chỉ sống ở `master_plan/prompt-fullstack.md`, một bản xuất khẩu
tự khai **không sở hữu sự thật nào** (`docs/decisions.md` ADR-035). Ghi ở đây là **owner thật** cho
hai cái tên, đúng đường đã chọn ở F-027: pha 1 giữ nguyên cách viết trừu tượng, tên cụ thể sống ở
`shop-facts.md` — xem `docs/decisions.md` **ADR-041**. **Chưa chốt**: token/cấu hình bot Telegram,
nhà cung cấp và cấu hình VPS cụ thể — đó là việc của pha 3 (BE) và pha 5 (Deploy), không phải một
dữ kiện quán (ADR-035).

**VietQR tĩnh nghĩa là mã cố định** — không phải mã sinh riêng cho từng hoá đơn. Hệ quả: hệ thống
**không tự biết tiền đã về tài khoản**; người ở quầy phải tự nhìn báo có rồi bấm xác nhận đã nhận
tiền. Số tài khoản do chủ quán nhập sau trong phần quản trị, không phải thứ cần biết trước để bắt
đầu làm.

**Số bàn đổi từ 11 lên 15 ngày 2026-09-06** — chủ quán mua thêm bàn, nguyên văn: *"hôm nay tôi mua
thêm bàn, hãy để 15 bàn"* (trả lời một phần của `U-040`, `docs/product/99-unknowns.md`). Con số
**11** đứng từ 2026-08-30 tới 2026-09-06; **15** là con số hiện hành — mọi chỗ trong repo còn nói
*"11 bàn"* là pointer cũ, cần sửa theo (`CLAUDE.md` §7.2: theo dấu con trỏ sau khi đổi một dữ kiện).
Mười một bàn ban đầu mỗi bàn **4 chỗ ngồi**, và **đã đánh số sẵn**; **bốn bàn mới cũng 4 chỗ mỗi
bàn** — chủ quán chốt **2026-09-08**, nguyên văn: *"thêm 4 bàn mới mỗi bàn 4 chỗ"* (trả lời vế thứ
nhất của `U-042`) ⇒ **cả mười lăm bàn đều 4 chỗ/bàn**. **Bốn bàn mới đánh số NỐI TIẾP: 12 · 13 ·
14 · 15** — chủ quán chốt **2026-09-16**, nguyên văn: *"trả lời nối tiếp 12–15"* (trả lời vế cuối
của `U-042`, câu ấy nay **đóng**) ⇒ mười lăm bàn mang tên **1…15**, không khu riêng, không cách gọi
nào khác. Không lời nào nói bàn có **tên** ngoài số, cũng không lời nào gắn thứ tự số với chỗ ngồi
trong quán — đừng đọc thêm (`CLAUDE.md` §3.5). Chi tiết ở §6.25.

## 2. Năm kênh bán — đúng năm, không có kênh thứ sáu

| Kênh | Ai bấm | Gắn số bàn | Ghi chú |
|---|---|---|---|
| `delivery` | khách, trên web | không | phí ship **0đ**, không có đơn tối thiểu |
| `pickup` | khách, trên web | không | có giờ hẹn lấy |
| `qr_table` | khách quét QR tại bàn | **có** | gộp vào phiên bàn |
| `staff_pos` | nhân viên đặt hộ **tại quán** | **có** | gộp vào phiên bàn |
| `phone_preorder` | nhân viên nhận **điện thoại** | **không** | đơn đặt trước, không thuộc phiên bàn nào |

Ba hệ quả nghiệp vụ, đây mới là phần quan trọng của bảng trên:

1. **Chỉ hai kênh gắn bàn** — `qr_table` và `staff_pos`. Hai kênh này **gộp vào một phiên bàn và
   tính tiền một lần**. Khách ngồi bàn 5 gọi ba lượt bằng bất kỳ tổ hợp nào của hai kênh này thì
   vẫn là **một hoá đơn**.
2. **Ba kênh không gắn bàn** — `delivery`, `pickup`, `phone_preorder`. Mỗi đơn là **một đơn vị
   thanh toán độc lập**, không gộp với gì cả. `delivery` phí ship **0đ** và không có đơn tối
   thiểu; `pickup` **có giờ hẹn lấy**.
3. **`phone_preorder` là kênh riêng, không gắn bàn** (chủ quán chốt 2026-08-29). Khách gọi
   `0382688666`, nhân viên nghe rồi nhập hộ vào hệ thống. Trước ngày 29/08 đơn hotline từng được
   ghi là đi bằng `staff_pos`; cách ghi đó **sai** và đã bị gỡ, vì `staff_pos` luôn gắn một số
   bàn, mà khách gọi điện thì chưa ngồi bàn nào.

**Đơn hotline mà khách tới ăn tại quán thì HUỶ, không chuyển thành phiên bàn** (chủ quán chốt
2026-08-30). Khách đã đặt trước qua điện thoại nhưng rồi tới quán ngồi ăn ⇒ **huỷ đơn đặt trước**,
khách quét QR tại bàn và gọi lại bằng `qr_table` như mọi khách ngồi bàn khác. Không có đường nối
một đơn `phone_preorder` vào một phiên bàn — điều đó giữ nguyên luật "mỗi đơn không gắn bàn là một
đơn vị thanh toán độc lập" ở trên. **Huỷ như vậy sinh việc hoàn tiền hay không là tuỳ đơn đã trả
tiền chưa** (§6.3, chủ quán chốt 2026-08-30): đơn **chưa** trả — đường mặc định — thì huỷ xong là
hết, không có tiền nào phải trả lại; đơn khách **đã chọn trả trước** thì huỷ **có** sinh việc hoàn
tiền, xử theo §6.4 (quầy quyết từng ca, ghi vết).

**Định danh khách:** hai kênh gắn bàn là **ẩn danh theo bàn** — quán chỉ cần biết "bàn 5", không
cần biết tên ai. Ba kênh còn lại phải có thông tin để gọi lại được — danh sách trường tối thiểu ở
§6.5.

## 3. Năm trạm làm việc

| Trạm | Làm gì |
|---|---|
| `quay` — quầy | Nhận và xác nhận đơn, đặt hộ, thu tiền, đóng phiên |
| `trang_banh` — tráng bánh | Tráng bánh, làm trứng |
| `gap_banh` — gấp bánh | Gấp bánh, xếp đĩa, cắt giò |
| `canh` — lấy canh | Nước chấm, canh |
| `don_ban` — dọn bàn | Dọn bàn sau khi phiên đã đóng |

**Ai làm trạm nào — chủ quán chốt 2026-08-30.** Năm trạm trên là năm loại việc, nhưng chỉ chia
thành **bốn vai người**:

| Vai | Gồm trạm | Ghi chú |
|---|---|---|
| Người đứng quầy | `quay` | trạm riêng, một người |
| Người tráng bánh | `trang_banh` | trạm riêng, một người |
| Người gấp bánh | `gap_banh` | trạm riêng, một người |
| Người canh & dọn | `canh` + `don_ban` | **một người làm cả hai trạm** |

Ba trạm đầu là **trạm riêng** — không kiêm sang trạm khác. `canh` và `don_ban` **chung một người**;
đây là hai loại việc khác nhau nhưng cùng một đôi tay, nên khi bếp đông thì hai việc này tranh nhau
người, còn ba trạm kia thì không.

Chủ quán (`owner`) là một vai riêng, **ngoài** năm trạm trên — nhưng **thỉnh thoảng chủ quán đứng
quầy** (chốt 2026-08-30), tức làm đúng việc của trạm `quay`. Chủ quán đứng quầy vẫn là chủ quán;
vai quản trị không mất đi.

**Người ĐI GIAO là MỘT TRONG BỐN VAI trên, không phải người thứ năm — và ai đi là do POS chỉ định
từng lần** (chủ quán chốt **2026-09-08**, trả lời `U-049`). Nguyên văn: *"1 trong bốn vai trên có
thể là bất cứ ai pos sẽ chỉ định."*

- **Con số người của quán đóng lại ở đây: bốn vai, cộng chủ quán ngoài năm trạm.** Việc đi giao
  **không** thêm một dòng nào vào bảng ca hay bảng lương.
- ***Đi giao* không phải trạm thứ sáu, cũng không phải một vai thứ năm.** Nó là **việc rời quán
  giao cho một vai đang có mặt**, từng lần một — nên §3 vẫn là năm trạm, bốn vai, không sửa bảng.
- **Ai đi thì không có luật cứng — POS quyết từng lần.** Đúng hình dạng đã gặp nhiều lần ở quán
  này: *"máy không gom, người gom"* và *POS chọn bàn nhận phần đã làm xong* (§5.4), *POS quyết thứ
  tự phục vụ* (§6.24), *POS quyết đường lùi* (§5.4). ⇒ Theo §6.10, chỗ nào người quyết từng ca thay
  cho luật cứng, chỗ đó phải **để lại vết**.
- **Lúc một vai rời quán đi giao, NGƯỜI ĐỨNG QUẦY (`quay`, POS) gánh trạm của người ấy — và khoảng
  trống ấy KHÔNG là *thiếu người*** (chủ quán chốt **2026-09-15**, trả lời `U-050`). Nguyên văn:
  *"pos gánh, không thiếu người vì đi ship luc quán vắng."*
  - ⇒ **Ba trạm riêng có một ngoại lệ, và chỉ một:** trong lúc có người đi giao, `quay` **kiêm**
    trạm bị bỏ trống tới lúc người kia về. Ngoài lúc ấy, câu *"ba trạm đầu không kiêm sang trạm
    khác"* ở trên vẫn đúng nguyên chữ. Quán **không** dừng trạm nào, và chủ quán **không** phải đứng
    vào.
  - ⇒ **Khoảng trống do đi giao không tính vào số 7 của §8.6** (*đang thiếu người hay không*).
    Lý do chủ quán đưa ra: quán **chỉ cho đi giao lúc vắng**. Đó là **lý do**, không phải một luật
    cấm giao lúc đông — không lời nào nói máy chặn hay cảnh báo một chuyến giao lúc quán đông, nên
    đừng viết luật ấy (`work/findings.md` **F-004**).
  - ⇒ **NGƯỜI ĐỨNG QUẦY KHÔNG BAO GIỜ ĐI GIAO — chủ quán chốt 2026-09-16, trả lời `U-052`.**
    Nguyên văn: *"người đứng quầy khônng đi giao"*. Câu này **hẹp** chữ *"bất cứ ai"* ngay trên lại
    còn **BA vai**: `trang_banh` · `gap_banh` · `canh`+`don_ban`. ⇒ trạm `quay` **không bao giờ** là
    trạm bị bỏ trống vì đi giao, nên lời *"pos gánh"* luôn có người để gánh — ca `U-052` hỏi (chính
    người đứng quầy đi giao) **không tồn tại**. Lời này **không** đụng tới chủ quán: chủ quán vẫn
    *thỉnh thoảng đứng quầy* như đã chốt 2026-08-30, và không lời nào nói chủ quán có đi giao hay
    không — đừng đọc thành luật (`work/findings.md` **F-004**).
- ⇒ *Chỗ chưa ai hỏi:* máy có **ghi lại** POS đã chỉ định ai cho đơn giao nào không. Không lời nào
  nói, và không mục nào hôm nay cần nó để chạy (§6.7 — hai nút *đã giao* + *đã thu tiền* không hỏi
  người bấm là ai). Câu **C36** — *người đứng quầy đổi giữa buổi* — **đã có lời và đã về owner
  2026-09-20** (**§8.8**), nhưng nó phủ đúng trạm `quay`: hai nút ở §6.7 bấm **ngoài quán**, nên vế
  *ai bấm* của chúng mang mã riêng — **`U-057`**. Câu còn lại chạm chỗ này khi lane admin tới lượt
  là **E51** (*người đi giao nộp tiền về*), ở `work/admin-questions.md` §3.

## 4. Menu, giá và tuỳ chọn

### 4.1 Công thức

```
giá món = base_price (giá CHAY) + phụ thu nhân + phụ thu lượng nhân
```

### 4.2 Bảng giá THÀNH PHẦN

Đây là giá của **từng thành phần**, không phải giá một suất bán. Giá một suất = **tổng giá các
thành phần** của suất đó theo §4.5.

| Danh mục | Thành phần | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Bánh cuốn | 1 cái bánh cuốn | 3.000 | 4.000 | 5.000 |
| Bánh cuốn | 1 quả trứng chín / tái / vàng | 8.000 | 9.000 | 10.000 |
| Ăn kèm | 1 chiếc giò | **9.000** | **9.000** | **9.000** |
| Ăn kèm | **1 bát canh bánh cuốn** | **0** | **0** | **0** |

Giò **không nhận nhân** nên một giá cho cả ba cột.

**Bát canh là 0đ, và con số 0 ấy là một lời chốt chứ không phải chỗ trống** — chủ quán 2026-09-08:
*"canh bánh cuốn bưng kèm sẵn không tính tiền nhưng cần có trong menu để khách chọn"*. Nó đứng
trong bảng này vì luật 1 §4.6 đòi mọi thứ bếp làm ra phải có một giá để cộng; 0 cộng vào không đổi
tổng, nhưng thiếu hàng này thì bát canh thứ hai của khách không có chỗ nào ghi. Canh **không nhận
nhân** — chủ quán không nói gì về nhân cho canh, và không lời nào cho phép suy ra một mức phụ thu
(`work/findings.md` **F-004**).

⚠️ **Chữ *"bưng kèm sẵn"* trong câu trên chỉ có nghĩa KHÔNG TÍNH TIỀN, không có nghĩa bếp tự động
bưng ra.** Cùng ngày **2026-09-08**, lượt sau, chủ quán nói thẳng: *"mỗi suất bếp sẽ không bưng
kèm theo canh. bếp bưng canh như nào dựa vào lựa chọn thực tế của khách"* (đóng `U-048`). Đây là
**lời chốt phủ một cách đọc**, không phải suy luận của người viết: vế *không tính tiền* đứng
nguyên (nên ô 0đ ở bảng trên không đổi một chữ), còn vế *tự động bưng* thì bị chính chủ quán bỏ.
⇒ **không suất nào ở §4.5 mang sẵn một bát canh**, và số bát bếp bưng đúng bằng con số khách chọn
trên dòng *canh bánh cuốn* — xem §4.5 và §5.3.

### 4.3 Giá một SUẤT BÁN — tính từ bảng §4.2

| Suất bán | Cách tính | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Suất bánh cuốn | 1 bánh | 3.000 | 4.000 | 5.000 |
| **Suất giò** | 1 giò + 4 bánh | **21.000** | **25.000** | **29.000** |
| Combo "Đầy đủ" trứng chín / tái / vàng | 3 bánh + 1 trứng + 1 giò | 26.000 | **30.000** | 34.000 |
| **Suất trứng** chín / tái / vàng | 1 trứng + 4 bánh | **20.000** | **25.000** | **30.000** |
| **Giò bán rời** | 1 giò | ⚠️ **9.000** | ⚠️ **9.000** | ⚠️ **9.000** |
| **Canh bánh cuốn** | 1 bát canh | **0** | **0** | **0** |

**Suất giò, chủ quán chốt 2026-08-29:** *"1 cái giò là 9.000, tính thêm tiền số lượng bánh là ra
số tiền của suất"* ⇒ 9.000 + 4 × giá bánh theo nhân đã chọn.

**Suất trứng, chủ quán chốt 2026-08-30:** gồm 1 quả trứng + 4 cái bánh cuốn, **cộng gộp tiền
thành phần** như suất giò, bánh tính theo mức nhân đã chọn ⇒ giá trứng + 4 × giá bánh.
**Quả trứng cũng lên giá theo mức nhân đã chọn** (chủ quán xác nhận 2026-08-30, trả lời thẳng câu
hỏi *"suất trứng nhân thường là 25.000 hay 24.000"* ⇒ **25.000**). Nên phụ thu suất trứng là **×5**,
không phải ×4 — xem §4.6 luật 5. Đây **không còn là suy luận**.
**Giò bán rời và canh bánh cuốn, chủ quán chốt 2026-09-08** (trả lời `U-047` và `U-046`): cả hai là
**dòng menu thật**, khách gọi bao nhiêu cũng được, và con số khách gọi là **số lượng món bán rời**
— **không** phải số giò hay số bánh bên trong một suất. Số thành phần **trong** một suất là **hằng
số**, chủ quán nói thẳng: *"số bánh / số giò TRONG MỘT SUẤT là không đổi"* ⇒ *suất giò* vẫn đúng 4
bánh, *suất trứng* vẫn đúng 4 bánh, *combo* vẫn đúng 3 bánh, và §4.5 · §4.6 · §4.8 không đổi một
chữ nào vì lời chốt này.

⚠️ **Ô giá của *giò bán rời* là ô ⚠ đầu tiên kể từ 2026-08-30** — bảng giá lại có một ô chưa được
chủ quán đọc thành lời. **9.000** ở đó là **hệ quả tính ra** từ luật 1 §4.6 (giá suất = tổng giá
thành phần; một chiếc giò rời gồm đúng một chiếc giò, §4.2 ⇒ 9.000), **không** phải con số chủ quán
nói. Cùng hình dạng **S-1** ngày 2026-08-30 — ô suất trứng cũng từng là hệ quả tính ra, và phải hỏi
mới thành fact. Ghi ở §7.2 thành **S-9**; đừng đọc ba ô ấy như đã chốt.

Bát canh thì **không** có ô ⚠: chủ quán nói thẳng *"không tính tiền"*.

Đây là ô cuối cùng còn trống của bảng giá; **từ 2026-08-30 bảng giá đã đầy** — rồi **2026-09-08 mở
lại một ô ⚠** cho giò bán rời (S-9), là ô ⚠ duy nhất hiện nay.

### 4.4 Nhóm tuỳ chọn và phụ thu

| Nhóm tuỳ chọn | Lựa chọn | Món lẻ | Combo |
|---|---|---|---|
| **Nhân** (bắt buộc chọn 1) | Chay / Thịt / Thịt + mộc nhĩ | 0 / +1.000 / +1.000 | 0 / +4.000 / +4.000 |
| **Lượng nhân** (chỉ hiện khi nhân ≠ Chay) | Thường / Nhiều nhân | 0 / +1.000 | 0 / +4.000 |

Loại nhân (thịt hay thịt + mộc nhĩ) **không đổi giá**.

Hai cột "Món lẻ" và "Combo" ở trên chỉ là hai trường hợp hay gặp của **cùng một luật**: phụ thu là
**+1.000 cho MỖI phần nhận nhân**.

| Suất bán | Số phần nhận nhân | Phụ thu mỗi bậc |
|---|---|---|
| Suất bánh cuốn | 1 (cái bánh) | +1.000 (**×1**) |
| Suất giò | 4 (bốn cái bánh; giò không nhận nhân) | +4.000 (**×4**) |
| Combo "Đầy đủ" | 4 (ba cái bánh + quả trứng) | +4.000 (**×4**) |
| Suất trứng | 5 (bốn cái bánh + quả trứng) | +5.000 (**×5**) |

### 4.5 Thành phần một suất bán — chủ quán chốt 2026-08-19

Đây là thứ **bếp làm ra**, khác với thứ khách trả tiền. **Sáu dòng menu tính tới 2026-09-08** (đếm
bảng ngay dưới, đừng tin câu này — `work/findings.md` **F-003**), và **bốn** trong sáu dòng ấy bếp
làm ra **nhiều thứ hơn tên món**:

| Suất bán | Bếp làm ra | Phần **nhận** tuỳ chọn nhân |
|---|---|---|
| Suất **bánh cuốn** | 1 cái bánh cuốn | cái bánh đó |
| Suất **trứng** (chín / tái / vàng) | **1 quả trứng + 4 cái bánh cuốn** | 4 cái bánh **và** quả trứng |
| Suất **giò** | **1 chiếc giò + 4 cái bánh cuốn** | 4 cái bánh (giò **không** nhận nhân) |
| **Combo "Đầy đủ"** | **3 cái bánh cuốn + 1 quả trứng + 1 chiếc giò** | 3 cái bánh **và** quả trứng |
| **Giò bán rời** | 1 chiếc giò | **không phần nào** — giò không nhận nhân (§4.6 luật 6) |
| **Canh bánh cuốn** | 1 bát canh | **không phần nào** |

Khách gọi "1 suất trứng" thì bếp làm **5 thứ**, không phải 1. Đây là chỗ hay bị làm thiếu nhất.

**Hai dòng cuối vào bảng ngày 2026-09-08 (`U-046` · `U-047`) là THÊM DÒNG MENU, không đổi cấu tạo
của suất nào đang có** — bốn hàng trên đứng nguyên từng chữ, và con số 3 · 4 bánh trong đó là hằng
số chủ quán vừa xác nhận thẳng (§4.3). Vì thế lời chốt này **không** rơi vào luật *"đổi thành phần
thì chờ hết buổi bán"* ở đoạn dưới: nó không đổi thành phần nào.

**Bát canh là dòng menu duy nhất bếp làm ra mà khách KHÔNG trả tiền, và nó vẫn là việc thật của
trạm `canh`** (§3). Chủ quán 2026-09-08: *"đôi khi 1 suất đầy đủ khách muốn có 2 bát canh, 1 bát
cho con và 1 bát cho mẹ"* ⇒ số bát canh **không** suy ra được từ số suất, nên §5.3 hết đọc được
việc trạm `canh` như một việc cấp đơn không có số lượng.

**Không suất nào kèm sẵn một bát canh — chủ quán chốt 2026-09-08** (đóng `U-048`), nguyên văn:
*"mỗi suất bếp sẽ không bưng kèm theo canh. bếp bưng canh như nào dựa vào lựa chọn thực tế của
khách"*. Hai điều luật ấy chốt, và cả hai đều đọc thẳng ra từ câu trên:

1. **Phần kèm sẵn là KHÔNG bát nào.** Bốn hàng suất của bảng ngay trên **không** mọc thêm một
   thành phần *bát canh* nào; cột *Bếp làm ra* của chúng đứng nguyên từng chữ.
2. **Con số khách chọn trên dòng *canh bánh cuốn* là TỔNG số bát bếp bưng**, vì không còn phần nền
   nào để cộng thêm vào. Khách gọi 1 suất đầy đủ + *canh ×2* ⇒ bếp múc **đúng 2** bát. Không chọn
   dòng canh ⇒ **0 bát**, và đơn ấy không có việc *canh* nào xuống bếp (việc **nước chấm** thì vẫn
   có, mọi đơn đều có — §5.3).

⇒ trạm `canh` **đọc con số trên dòng đơn**, không nhân từ số suất và không cộng thêm gì. Chữ
*"bưng kèm sẵn"* của lời chốt `U-046` cùng ngày vì thế chỉ còn nghĩa **không tính tiền** (§4.2).

Một dòng đơn chọn **một** loại nhân + **một** lượng nhân, áp cho mọi phần nhận nhân của suất đó;
mặc định là **nhân thịt, lượng thường**.

Bánh trong suất giò **có** nhận nhân — chay, thường hoặc nhiều nhân (chủ quán chốt 2026-08-29).
Nên suất giò có **ba** giá, không phải một.

**Bảng thành phần này chỉ được sửa sau khi hết buổi bán** (chủ quán chốt 2026-09-01, §6.17). Nó
khác bảng giá §4.2 và bảng phụ thu §4.4 ở đúng chỗ đó: hai bảng kia sửa giữa giờ bán cũng được.

### 4.6 Chín quy tắc cấu tạo giá

1. **Giá một suất bán = TỔNG giá các thành phần của suất** (§4.5 cho thành phần, §4.2 cho giá từng
   thành phần). Đây là luật gốc, tám luật dưới đều là hệ quả.
2. Giá gốc của một thành phần là **giá CHAY**. Nhân là **phụ thu**, không phải một giá riêng.
3. Nhóm **"Lượng nhân" chỉ tồn tại khi nhân ≠ Chay**. ⇒ tổ hợp **Chay + Nhiều nhân là không hợp
   lệ, phải bị TỪ CHỐI**, không được âm thầm bỏ qua tuỳ chọn thừa — bếp nhận phiếu mâu thuẫn là
   hỏng món.
4. **Loại nhân không đổi giá.** Thịt và Thịt + mộc nhĩ cùng mức phụ thu; chỉ **lượng nhân** mới đổi
   giá.
5. **Phụ thu là +1.000 cho MỖI phần nhận nhân của suất.** Suất bánh cuốn ×1 · suất giò ×4 · combo
   ×4 · **suất trứng ×5** — bốn con số này là **hệ quả** của luật 1, không phải bốn con số rời cần
   nhớ thuộc lòng. Suất trứng ×5 vì cả 4 cái bánh **và** quả trứng đều nhận nhân (§4.5); chủ quán
   xác nhận thẳng con số này ngày 2026-08-30 (suất trứng nhân thường = **25.000**, không phải
   24.000).
6. **Giò không nhận nhân, nhưng 4 cái bánh trong suất giò thì có** (chủ quán chốt 2026-08-29).
7. Một dòng đơn chọn **một** loại nhân + **một** lượng nhân, áp cho **mọi phần nhận nhân** của
   suất đó. Không chọn nhân riêng cho từng cái bánh.
8. **Mặc định là nhân Thịt, lượng Thường** khi khách không chọn gì.
9. Khách **không bao giờ** gửi giá lên; giá luôn do hệ thống tự xác định lại từ bảng giá. Nhận giá
   do khách gửi nghĩa là có ngày khách đặt được món 0đ.

### 4.7 Bằng chứng của mô hình "tổng thành phần"

Đây không phải suy đoán. Cộng giá thành phần theo §4.5 tái tạo **đúng cả ba** ô giá combo ở §4.3:

```
3 × bánh(chay 3.000)   + trứng(chay 8.000)   + giò(9.000) = 26.000   ✓ khớp
3 × bánh(thường 4.000) + trứng(thường 9.000) + giò(9.000) = 30.000   ✓ khớp
3 × bánh(nhiều 5.000)  + trứng(nhiều 10.000) + giò(9.000) = 34.000   ✓ khớp
```

Ba ô khớp liên tiếp không phải trùng hợp ⇒ **"giá suất = tổng giá thành phần"** là luật thật, và
"combo ×4" chỉ là cách nói gọn của "combo có 4 phần nhận nhân".

⚠️ Một câu từng lưu hành trong dự án nói ngược lại — *"phụ thu không nhân theo số phần bếp làm"* —
đã bị lời chủ quán ngày 2026-08-29 về suất giò phủ nhận và đã gỡ bỏ. Nếu thấy câu đó quay lại ở
bất kỳ tài liệu nào, **đó là bug**, không phải quy tắc.

### 4.8 Mười một tổ hợp giá bắt buộc phủ

Đây là danh sách **tổ hợp đầu vào** mà việc tính giá phải làm đúng, kèm giá kỳ vọng tính từ §4.2 và
§4.4.

| # | Món | Nhân | Lượng nhân | Giá kỳ vọng | Ghi chú |
|---|---|---|---|---|---|
| 1 | Bánh cuốn | Chay | — | **3.000** | |
| 2 | Bánh cuốn | Thịt | Thường | **4.000** | |
| 3 | Bánh cuốn | Thịt | Nhiều | **5.000** | |
| 4 | Bánh cuốn | Thịt + mộc nhĩ | Nhiều | **5.000** | phải **bằng ca 3** — loại nhân không đổi giá |
| 5 | Suất trứng chín | Chay | — | **20.000** | 8.000 + 4 × 3.000 |
| 6 | Suất trứng tái | Thịt + mộc nhĩ | Thường | **25.000** | 9.000 + 4 × 4.000; phụ thu ×5 |
| 7 | Suất trứng vàng | Thịt | Nhiều | **30.000** | 10.000 + 4 × 5.000; phụ thu ×5 |
| 8 | Suất giò | Thịt | Nhiều | **29.000** | 9.000 + 4 × 5.000; giò không nhận nhân, bánh thì có |
| 9 | Combo Đầy đủ chín | Thịt | Thường | **30.000** | combo: phụ thu ×4 |
| 10 | Combo Đầy đủ tái | Thịt + mộc nhĩ | Nhiều | **34.000** | |
| 11 | Bánh cuốn | Chay | Nhiều | **PHẢI BỊ TỪ CHỐI** | không phải một giá, mà là luật ở §4.6.3 |
| 12 | **Giò bán rời ×3** | — | — | ⚠️ **27.000** | 3 × 9.000; giò không nhận nhân nên **nhóm nhân không được hiện** — ô giá còn ⚠ (**S-9**) |
| 13 | **Canh bánh cuốn ×2** | — | — | **0** | dòng 0đ **vẫn phải nằm trên đơn**: nó là việc của trạm `canh` (§4.5) và là thứ khách chọn số lượng. Một đơn *chỉ* có canh vẫn là đơn hợp lệ, tổng **0đ** |

**Mười ba ca tính tới 2026-09-08** — đếm bảng, đừng tin câu này (`work/findings.md` **F-003**). Ca
1–10 đều tính được và đã đối chiếu khớp bảng giá §4.3 từ 2026-08-30. Ca 11 là ca duy nhất có kết
quả không phải một con số. **Ca 12 và ca 13 vào bảng ngày 2026-09-08** cùng hai dòng menu mới, và
mỗi ca canh đúng một chỗ dễ hỏng của chúng: ca 12 canh việc **hiện nhóm tuỳ chọn cho một món không
nhận nhân**, ca 13 canh việc **một dòng 0đ bị lặng lẽ bỏ khỏi đơn** vì nó không cộng thêm tiền —
bỏ nó đi thì trạm `canh` không thấy bát canh thứ hai, và đó chính là ca chủ quán kể ra khi chốt
`U-046`. Mười ba ca này là **hợp đồng với chủ quán**: đủ cả mười ba mới được coi là tính giá đúng.

### 4.9 MENU — chủ quán tự gọi tên từng món, 2026-09-08

**Đây là lần đầu chủ quán đọc ra *menu gồm những gì* thành một danh sách.** Trước lượt này §4.3 có
bốn dòng giá, nhưng không lời chủ quán nào nói bốn dòng ấy **là** menu, hay menu còn món khác.
Nguyên văn 2026-09-08: *"đối với menu: tôi muốn có suất đầy đủ trứng tai, đầy đủ trứng chín, đầy
đủ trứng vàng, suất giò, suất trứng chín, suất trứng tái, suất trứng vàng. bánh cuốn khách sẽ lựa
chọn ăn bao nhiêu cái thì tuỳ. giò: khách có thể gọi bao nhiêu cũng được. canh bánh cuốn."*

Mục này chỉ ghi **món nào có mặt trên menu**. Giá và cách tính vẫn ở §4.2–§4.3, thành phần bếp làm
ra vẫn ở §4.5 — không chép một ô nào của chúng xuống đây (`work/findings.md` **F-001**).

| # | Chủ quán gọi tên | Đã có ở §4.3 chưa | Ghi chú |
|---|---|---|---|
| 1 | *đầy đủ trứng chín* | ✅ Combo "Đầy đủ" trứng chín | |
| 2 | *đầy đủ trứng tái* | ✅ Combo "Đầy đủ" trứng tái | chủ quán viết *"tai"*, đọc là **tái** — cùng ba loại trứng chín/tái/vàng của §4.2 |
| 3 | *đầy đủ trứng vàng* | ✅ Combo "Đầy đủ" trứng vàng | |
| 4 | *suất giò* | ✅ Suất giò | |
| 5 | *suất trứng chín* | ✅ Suất trứng chín | |
| 6 | *suất trứng tái* | ✅ Suất trứng tái | |
| 7 | *suất trứng vàng* | ✅ Suất trứng vàng | |
| 8 | *bánh cuốn — khách ăn bao nhiêu cái thì tuỳ* | ✅ Suất bánh cuốn (1 cái, giá theo cái) | **`U-047` đóng 2026-09-08**: đó là **số lượng khách gọi**, đúng như §4.3 đang làm — không đổi gì |
| 9 | *giò — khách gọi bao nhiêu cũng được* | ✅ **Giò bán rời**, thêm vào §4.2 · §4.3 · §4.5 ngày 2026-09-08 | **`U-047` đóng**: giò là **món bán rời**, khách gọi bao nhiêu chiếc cũng được. ⚠️ Ô giá **9.000** là hệ quả tính từ luật 1 §4.6, chủ quán chưa đọc thành lời ⇒ **S-9** §7.2 |
| 10 | *canh bánh cuốn* | ✅ **Canh bánh cuốn 0đ**, thêm vào §4.2 · §4.3 · §4.5 ngày 2026-09-08 | **`U-046` đóng**: *"bưng kèm sẵn không tính tiền nhưng cần có trong menu để khách chọn"* — dòng menu **0đ có số lượng**, vì một suất đầy đủ đôi khi cần 2 bát. **`U-048` đóng cùng ngày, lượt sau**: **không suất nào bưng kèm canh**, nên con số khách chọn ở dòng này là **TỔNG số bát** bếp bưng (§4.5 · §5.3) |

**Bảy dòng đầu khớp đúng từng chữ với §4.3, không thừa không thiếu** — đây là phép đếm và phép đối
chiếu của phiên viết, không phải lời chủ quán (`work/findings.md` **F-003**): chủ quán liệt kê
bảy tên, không nói *"đúng bảy"*, nên một tên thứ tám xuất hiện sau này **không** cần ai cho phép.

**Ba dòng cuối (8 · 9 · 10) đều có lời trong ngày** — `U-047` rồi `U-046`, cùng 2026-09-08, lượt
sau nữa. Hai điều lời đáp ấy chốt, và cả hai đều là **luật**, không phải một con số lẻ:

- **Số thành phần TRONG một suất là hằng số.** Nguyên văn: *"số bánh / số giò TRONG MỘT SUẤT là
  không đổi"* ⇒ suất giò 4 bánh, suất trứng 4 bánh, combo 3 bánh — §4.5 · §4.6 · §4.8 giữ nguyên
  từng chữ. Con số khách gọi là **số lượng món bán rời**, việc của dòng đơn, không phải của cấu
  tạo suất.
- **Menu có hai dòng mới, và một trong hai không sinh một đồng doanh thu nào**: *giò bán rời*
  (⚠️ giá là hệ quả tính ra, **S-9**) và *canh bánh cuốn* (**0đ**, chủ quán nói thẳng). Menu vì thế
  đi từ **bốn** lên **sáu** dòng, và mọi chỗ trong repo còn chép chữ *"bốn suất bán"* đã được sửa
  trong cùng lần sửa này (`CLAUDE.md` §7.2) — `architecture.md` §6.1 ·
  `docs/product/0-ba/ban-hang/03-lat-cat.md` §3 · `08-scenario.md`. Hàng nhật ký §7.1 ngày
  2026-08-19 **không** sửa: nó ghi đúng cái đã chốt hôm ấy.
- §4.8 đi từ mười một lên **mười ba** ca, hai ca mới canh hai chỗ dễ hỏng riêng của hai dòng này.

## 5. Hai luồng bán

Quán có đúng **hai** luồng, và năm kênh ở §2 rơi vào đúng một trong hai:

| Luồng | Kênh | Đơn vị tính tiền |
|---|---|---|
| **Ăn tại bàn** (§5.1) | `qr_table` · `staff_pos` | phiên bàn — mọi lượt gọi gộp vào **một** hoá đơn |
| **Mang đi** (§5.2) | `delivery` · `pickup` · `phone_preorder` | mỗi đơn là **một** đơn vị thanh toán riêng |

Hai luật chạy xuyên cả hai luồng, nhớ trước khi đọc sơ đồ:

- **Mặc định thu tiền lúc TRAO HÀNG.** Tiền mặt hoặc VietQR, khách chọn. Riêng **đơn mang đi**,
  khách được chọn **trả trước** — nhánh tuỳ chọn, luật đầy đủ ở §6.3.
- **Đơn do KHÁCH tự gửi phải được quầy duyệt; đơn do NHÂN VIÊN nhập thì không.** Bước duyệt tồn tại
  để chống đơn ảo — nhân viên nhập thì đã có người chịu trách nhiệm rồi.

### 5.1 Luồng ăn tại bàn — `qr_table`, `staff_pos`

Đây là luồng chiếm phần lớn doanh thu.

```
Khách ngồi bàn 5
   ├── (A) quét QR trên bàn ────┐   ← khách tự gửi ⇒ PHẢI duyệt
   └── (B) không quét được      │
         └─ quầy hỏi, đặt hộ ───┤   ← nhân viên nhập ⇒ không cần duyệt
                                ▼
                   PHIÊN BÀN 5 (mở) — gom mọi lượt gọi món
                                │
                 Quầy xác nhận đơn (chống đơn ảo)
                                │
        ┌───────────────────────┼───────────────────────┐
     TRÁNG BÁNH             GẤP BÁNH                LẤY CANH
   (tráng bánh, trứng)  (gấp, xếp đĩa, cắt giò)  (nước chấm, canh)
        └───────────────────────┴───────────────────────┘
                                │
                        Mang ra bàn 5 → khách gọi thêm → quay lại đầu
                                │
                    Quầy thu tiền (mặt / VietQR) → đóng phiên → DỌN BÀN → bàn trống
```

Sơ đồ trên là **đường thuận**. Hai nhánh đã chốt ngày 2026-08-31 không vẽ trong đó:

- **Khách không trả được ⇒ quán cho nợ** (§6.14). Phiên vẫn đóng, vẫn dọn bàn, vẫn trả bàn về
  trống — nhưng lúc đóng, POS bắt buộc ghi **ai nợ** và **nợ bao nhiêu**.
- **Khách đang ngồi bàn gọi thêm suất đem về** (§6.15). Suất ấy đi vào **chính phiên bàn** này,
  kèm note **"đem về"**; nó không rẽ sang luồng §5.2 và không thành một đơn riêng.
- **Nhóm đông ngồi ghép hai bàn** (§6.16). Sơ đồ vẽ *"PHIÊN BÀN 5"* cho gọn; thật ra một phiên
  gắn **một hoặc nhiều** bàn, và nhóm ghép trả **một** hoá đơn.

### 5.2 Luồng mang đi — `delivery`, `pickup`, `phone_preorder`

```
Khách đặt
   ├── (A) delivery       — khách bấm trên web, chọn giao tận nơi   ⇒ PHẢI duyệt
   ├── (B) pickup         — khách bấm trên web, có giờ hẹn lấy      ⇒ PHẢI duyệt
   └── (C) phone_preorder — khách gọi 0382688666, nhân viên nhập hộ ⇒ không cần duyệt
             nhân viên PHẢI hỏi: giao tận nơi hay tới lấy, và cần lúc mấy giờ
                                ▼
              MỖI ĐƠN LÀ MỘT ĐƠN VỊ THANH TOÁN RIÊNG — không gộp với gì
                                │
                 (A)(B) Quầy duyệt      (C) vào thẳng, nhân viên đã chịu trách nhiệm
                                │
        ┌───────────────────────┼───────────────────────┐
     TRÁNG BÁNH             GẤP BÁNH                LẤY CANH
   (tráng bánh, trứng)  (gấp, xếp đĩa, cắt giò)  (nước chấm — GÓI RIÊNG)
        └───────────────────────┴───────────────────────┘
                                │
                            ĐÓNG GÓI
                                │
          ┌─────────────────────┴─────────────────────┐
     GIAO TẬN NƠI                                 TỚI LẤY
   quán TỰ đi giao                          khách tới quán lấy
   đơn mang trạng thái "đang giao"                  │
          │                                        │
   trao hàng → THU TIỀN tại chỗ khách      trao hàng → THU TIỀN tại quầy
   (mặt / VietQR)                          (mặt / VietQR)
          └─────────────────────┬─────────────────────┘
                                │
                        Đơn đóng — KHÔNG có bước dọn bàn
```

**Khác luồng tại bàn ở bảy điểm.** Đây là danh sách đã biết tính tới 2026-08-30, **không phải lời
hứa là đã đủ** — gặp điểm khác thứ tám thì ghi thêm vào đây, đừng tự đoán.

1. **Cần thông tin liên hệ** của khách để gọi lại được (luồng tại bàn ẩn danh theo số bàn).
2. **Không có phiên bàn.** Mỗi đơn tự nó là một đơn vị thanh toán, không gộp với đơn nào khác —
   kể cả cùng một khách đặt hai lần.
3. Có bước **đóng gói** thay cho bước mang ra bàn, và **không có bước dọn bàn**.
4. **Nước chấm phải gói riêng** — trạm `canh` vẫn sinh việc cho đơn mang đi, chỉ khác cách đưa.
5. **`pickup` có giờ hẹn lấy**, `phone_preorder` là đơn đặt trước nên cũng có mốc giờ khách cần
   hàng. Luồng tại bàn không có khái niệm hẹn giờ.
6. **Thu tiền lúc trao hàng, có thể ở ngoài quán** — đơn giao tận nơi thu ngay tại chỗ khách, không
   phải ở quầy. Luồng tại bàn luôn thu ở quầy lúc đóng phiên. **Và chỉ luồng này có nhánh trả
   trước** (§6.3): khách mang đi được chọn trả tiền ngay lúc đặt, khách ngồi bàn thì không.
7. **Chỉ đơn giao tận nơi có trạng thái "đang giao"** — vì quán tự đi giao, quầy phải biết đơn nào
   còn trên đường và ai đang cầm tiền chưa về.

### 5.3 Việc xuống bếp phải "nổ" ra thành phần

Khách gọi **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**, và chọn **2 bát canh**:

```
Khách trả tiền theo: [Đầy đủ trứng tái ×2 — Thịt+mộc nhĩ, Nhiều nhân — 34.000 × 2 = 68.000]
                     [Canh bánh cuốn ×2  — 0 × 2 = 0]  ← 0đ nhưng VẪN là một dòng khách chọn
                                                          ↑ 2 dòng trên hoá đơn

Bếp phải thấy:
  trang_banh │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  trang_banh │ Trứng tái ×2 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Trứng tái ×2
  gap_banh   │ Giò ×2                    ← thành phần không nhận nhân thì KHÔNG kèm mô tả nhân
  canh       │ Nước chấm — bàn 5, 2 suất ← việc cấp ĐƠN, MỌI đơn đều có,
                                            đơn mang đi thì gói riêng thay vì bưng ra bàn
  canh       │ Canh bánh cuốn ×2         ← SỐ LƯỢNG RIÊNG, khách chọn (2026-09-08),
                                            KHÔNG suy ra từ số suất; đây là TỔNG số bát,
                                            không suất nào kèm sẵn — xem ngay dưới.
                                            Khách không chọn canh ⇒ KHÔNG có dòng này
```

Số lượng = `số suất × số thành phần trong suất` (§4.5: combo = 3 bánh ⇒ 2 combo = 6 bánh).
**Bếp không bao giờ được thấy một dòng "Combo ×2" mơ hồ** — nhìn dòng đó thì không ai biết phải
tráng mấy cái bánh.

⚠️ **Bát canh là ngoại lệ của phép nhân trên, từ 2026-09-08.** Chủ quán chốt canh là một **dòng
menu khách chọn số lượng** (`U-046`): *"đôi khi 1 suất đầy đủ khách muốn có 2 bát canh"* ⇒ số bát
**không** nhân ra từ số suất, nó là con số khách gọi. Nên trạm `canh` có **hai** loại việc khác
nhau trên cùng một đơn: **nước chấm** — cấp đơn, mọi đơn đều có, không có số lượng riêng — và
**canh** — có số lượng riêng.

**Con số ấy là TỔNG số bát, không phải phần thêm — chủ quán chốt 2026-09-08** (đóng `U-048`),
nguyên văn: *"mỗi suất bếp sẽ không bưng kèm theo canh. bếp bưng canh như nào dựa vào lựa chọn
thực tế của khách"*. Nên trạm `canh` **múc đúng con số trên dòng đơn**: `×2` ở ví dụ trên là **2**
bát cho cả đơn, không phải 2 bát thêm vào một phần kèm sẵn nào — không có phần kèm sẵn nào cả.
Đơn nào khách **không** chọn canh thì **không có dòng canh** xuống bếp; dòng **nước chấm** thì vẫn
còn, vì nó là việc cấp đơn của mọi đơn (§4.5).

Nếu thành phần một suất đổi thì **sửa §4.5 trước**, rồi sửa ví dụ này cho khớp.

### 5.4 Bếp làm theo MẺ, không làm lần lượt từng suất — chủ quán chốt 2026-08-31

§5.3 nói một dòng đơn **nổ ra** thành phần nào. Mục này nói bếp **làm chúng theo thứ tự nào**, và
đây là lời chủ quán, không phải cách tổ chức do người viết tài liệu nghĩ ra.

**Năng lực bếp — con số của chủ quán:**

Quán có **2 nồi** tráng bánh cuốn. Một nồi, trong **một lần tráng**, làm được **đúng một** trong
ba tổ hợp dưới đây — không phải một sức chứa chung quy đổi được:

| Một lần tráng, MỘT nồi làm được | |
|---|---|
| **3 quả trứng** | hoặc |
| **2 cái bánh** | hoặc |
| **1 quả trứng + 1 cái bánh** | |

Đây là lời chủ quán nói thẳng, hai lần trong ngày 2026-08-31: *"1 nồi tráng bánh cuốn có thể làm
3 quả trứng và tôi có 2 nồi nên có thể làm 6 quả trứng cùng 1 lúc"*, rồi *"1 nồi có thể làm nhiều
nhất 3 trứng, hoặc làm 2 bánh, hoặc làm 1 quả trứng và 1 cái bánh cùng 1 lần tráng"*.

**Hệ quả quan trọng nhất: trứng và bánh tranh nhau cùng một cái nồi.** Không có nồi riêng cho
trứng và nồi riêng cho bánh. Nồi đang làm trứng thì **vẫn** tráng được bánh, nhưng khi ấy nồi chỉ
còn chỗ cho **1 trứng + 1 bánh** — tức nhận thêm một cái bánh làm mất hai chỗ trứng.

**Ba tổ hợp trên không quy về một đơn vị chung.** 3 trứng · 2 bánh · 1+1 không phải ba cách chia
cùng một số chỗ; đừng đặt ra "một nồi có N chỗ, trứng chiếm x, bánh chiếm y" rồi tính. Đó sẽ là mô
hình của người viết tài liệu, không phải lời chủ quán. Cần một tổ hợp thứ tư thì **hỏi chủ quán**.

Nhân lên cho **hai** nồi — đây là **phép nhân của người viết tài liệu**, không phải con số chủ quán
đọc ra, trừ con số 6 quả trứng thì chủ quán nói thẳng: tối đa **6 trứng** một mẻ, **hoặc** 4 bánh,
**hoặc** 2 trứng + 2 bánh, **hoặc** các tổ hợp trộn hai nồi khác nhau (một nồi 3 trứng + một nồi
2 bánh).

**Vì sao phải gom.** Làm lần lượt từng suất thì **mất thời gian và mất nhiệt** — một cái nồi chỉ
nấu một quả trứng là nồi chạy gần như không tải. Sáu khách vào cùng lúc gọi sáu suất đầy đủ thì
quán **không** làm xong suất người thứ nhất rồi mới bắt đầu suất người thứ hai: quán làm **sáu quả
trứng một mẻ**, rồi tráng bánh dần cho từng người. Chủ quán mô tả đúng tình huống sáu người này
làm ví dụ (2026-08-31).

⇒ **Gom việc là cách quán đang chạy, không phải một tính năng thêm vào.** Một thiết kế bắt bếp
nhận việc theo từng suất một là thiết kế bắt quán chạy chậm hơn hiện nay.

**Gom theo tổng, nhưng vẫn biết thành phẩm của ai.** Sáu quả trứng làm chung một mẻ vẫn phải về
đúng sáu bàn đã gọi chúng. Gom mà mất dấu chủ sở hữu là bưng nhầm bàn.

**Gom theo đúng thứ khách chọn.** Loại nhân và lượng nhân đi theo từng thành phần (§4.5), nên hai
cái bánh cùng tên nhưng khác lượng nhân là **hai** dòng việc, không gộp làm một. Trứng cũng vậy:
gom theo **từng loại** — chín, tái, vàng — không gom thành một con số "trứng".

**Những con số chủ quán đòi nhìn thấy — đếm được BỐN, tính tới 2026-09-01.** Ba con số đầu là
**phép đếm của người viết tài liệu** trên lời chủ quán ngày 2026-08-31; con số thứ tư được chính
chủ quán xác nhận ngày **2026-09-01** (trả lời S-4, xem dưới bảng). Không con số nào ở đây là
ranh giới chốt: chủ quán nói ra con số thứ năm thì thêm dòng, không cần xin phép ai.

| Con số | Nghĩa | Nguồn |
|---|---|---|
| **Khách đã gọi** | tổng thành phần nổ ra từ các dòng đơn (§5.3) | chủ quán, 2026-08-31 |
| **Đã bưng ra bàn** | đã tới tay khách | chủ quán, 2026-08-31 |
| **Còn thiếu** | khách đã gọi − đã bưng ra bàn | chủ quán, 2026-08-31 |
| **Đã làm xong, còn ở bếp** | bếp làm ra rồi nhưng chưa bưng ra | chủ quán, **2026-09-01** — trả lời S-4 |

**Con số thứ tư có thật, vì cái quán có thật khoảng nằm chờ ấy** (chủ quán trả lời 2026-09-01,
đóng S-4). Câu hỏi *"từ lúc bếp tráng xong một cái bánh đến lúc nó đặt xuống bàn khách, có khi nào
nó phải nằm chờ không"* được trả lời là **có**, kèm đúng ba lý do chủ quán nêu:

- **chờ đủ đĩa**,
- **chờ người rảnh tay bưng**,
- **chờ món khác của cùng bàn**.

Ba lý do này là lời chủ quán, không phải danh sách người viết tài liệu nghĩ ra; gặp lý do thứ tư
thì thêm vào đây. Hệ quả: *làm xong* và *ra tới bàn* là **hai** việc khác nhau, nên bảng ở quầy
tách chúng thành hai con số chứ không gộp.

**Ai nói cho máy biết món đã xong: người đứng quầy bấm** (chủ quán trả lời 2026-09-01). Đây là câu
hỏi thứ hai của S-4, tồn tại vì lời chốt U-009 đã bỏ mọi nút bấm ở trạm bếp — không còn nguồn nào
khác. Hai câu phải đọc cùng nhau, và chúng **không** mâu thuẫn:

- **Ba trạm bếp vẫn không bấm gì** — U-009 nguyên vẹn. Người tráng bánh, người gấp bánh, người lấy
  canh không nhận thêm một thao tác nào.
- **Nút "đã làm xong" nằm ở QUẦY**, trên POS — cùng một máy với duyệt đơn (§6.2), huỷ đơn (§6.13),
  thu tiền, ghi nợ (§6.14) và ghép bàn (§6.16).
- ⇒ Đây là thao tác **thứ sáu** người đứng quầy gánh. Con số sáu ấy là **phép đếm của người viết
  tài liệu**, không phải lời chủ quán, và nó không phải một luật — ghi ra vì nó là rủi ro vận hành
  thật: quầy là đôi tay bận nhất quán, thêm một nút là thêm một chỗ quên bấm.

**Bấm theo MẺ** (chủ quán chốt 2026-09-01, trả lời U-017). Không bấm theo từng cái, không bấm theo
cả bàn: **một lần bấm ứng với một mẻ bếp vừa làm xong**.

- Đây là câu trả lời **khớp với chính cách bếp làm** (mục này): bếp gom việc theo mẻ, nên cái mốc
  *"vừa xong"* trong quán cũng rơi theo mẻ chứ không rơi theo từng cái bánh. Bấm theo từng cái là
  bắt quầy bấm sáu lần cho một nồi trứng; bấm theo cả bàn là mất luôn con số thứ tư, vì một bàn
  thường được phục vụ bằng nhiều mẻ.
- ⇒ **Con số "đã làm xong, còn ở bếp" nhảy theo bậc, không nhảy từng đơn vị.** Bảng ở quầy có lúc
  hiện một con số vừa tăng thêm cả mẻ; đó là đúng, không phải lỗi đếm.
- ⇒ **Một mẻ phục vụ nhiều bàn thì một lần bấm phải chia được về từng bàn.** Mẻ là đơn vị **bấm**;
  bàn vẫn là đơn vị **đếm** (§5.3 — việc xuống bếp luôn ghi bàn nào gọi). Hai thứ này không thay
  nhau được.
- *Cách đọc, không phải lời chủ quán nói thẳng:* gạch đầu dòng thứ ba ở trên là hệ quả của việc
  ghép lời chốt này với §5.3. Chủ quán chỉ nói **theo mẻ**.

**Một đơn bị HUỶ sau khi bếp đã làm xong phần của nó: chỗ đã làm xong đó KHÔNG bỏ đi — nó chuyển
cho một bàn khác đang chờ đúng thứ ấy, và người đứng quầy trên POS chọn bàn nhận rồi cập nhật lại**
(chủ quán chốt 2026-09-06, trả lời U-033). Nguyên văn: *"tính vào bàn khác, pos sẽ cập nhật bánh
này đem ra cho bàn nào."*

- **Con số *"đã làm xong, còn ở bếp"* không về 0 khi đơn chủ của nó bị huỷ** — nó đổi chủ sang bàn
  được chọn. Nhu cầu (*còn thiếu*, cột thứ ba của bảng bốn con số ở trên) của **bàn nhận** giảm
  đúng bằng phần vừa nhận; của **bàn bị huỷ** thì phần đã huỷ không còn tính vào nhu cầu của nó nữa.
- **Chọn bàn nào nhận là quyết định của người đứng quầy, không phải luật máy tự gán** — cùng lối
  nghĩ *"máy không gom, người gom"* ở trên: máy chỉ bày ra ai đang chờ đúng thứ đã làm (cùng thành
  phần, cùng lượng nhân — §4.5), người ở quầy chọn và bấm.
- **Chỉ áp dụng khi có bàn khác đang chờ đúng thứ đã làm.** Chủ quán không nói tới ca không bàn
  nào chờ — ca ấy chưa có luật, chưa hỏi.
**Con số thứ ba cũng do POS bấm, và đường lùi thì CÓ** (chủ quán chốt 2026-09-01, trả lời U-021 và
U-024). Hai câu này khép nốt bảng bốn con số:

- **"Đã bưng ra bàn" — người bấm là POS**, đúng chỗ đứng đã bấm *"đã làm xong"*. Lần hỏi
  2026-08-31 gộp câu này vào U-009 và nhận lại *"bỏ qua bước này, POS sẽ tự cập nhật"*, tức chưa
  trả lời **ai**; lần hỏi 2026-09-01 trả lời thẳng: **pos**. ⇒ **Cả hai mốc của một suất — làm
  xong, và ra tới bàn — đều do người đứng quầy bấm.** Ba trạm bếp vẫn không bấm gì; U-009 nguyên
  vẹn, vì nó là luật về **bếp**, không phải luật về quầy.
- **Bấm nhầm thì LÙI ĐƯỢC, và không có mốc thời gian cứng** — lời chủ quán: *"có đường lui. thời
  gian tuỳ theo thực tế để pos quyết định"*. Không có "trong vòng N phút": người đứng quầy nhìn
  tình huống thật rồi quyết, đúng cùng một kiểu với quyền hoàn tiền ở §6.4.
- ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* **vì không có luật cứng nên mỗi lần lùi phải để
  lại vết** — lùi mẻ nào, lúc mấy giờ, ai bấm. Đây không phải luật mới mà là §6.4 áp cho cùng một
  hình dạng: chỗ nào người quyết từng ca thay cho luật cứng, chỗ đó phải truy ngược được (§6.10,
  lệch 1 đồng cũng phải tìm ra lý do).
- **Đơn GIAO TẬN NƠI cũng vậy — vẫn là POS bấm** (chủ quán chốt **2026-09-04**, trả lời U-031).
  Lần hỏi 2026-09-01 không nhắc tới ca này, và ca này là ca duy nhất mà lúc suất tới tay khách thì
  người có mặt **không** phải người đứng quầy: *nhân viên quán* đi giao, người đã giữ hai nút
  *đã giao* + *đã thu tiền* (§6.7). Lời chủ quán 2026-09-04 chỉ có một từ — *"pos"* — và nó khép
  ca ấy lại: **không** có ngoại lệ, mốc *"đã ra bàn"* của mọi việc trạm đều do quầy bấm, kể cả khi
  suất ấy sắp rời quán. ⇒ *Người đi giao vẫn không bấm mốc nào của bảng bếp*, đúng hình dạng
  U-009: người ở ngoài quầy không nhận thêm thao tác nào.
- ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* **lúc nào** quầy bấm mốc ấy cho một đơn giao
  thì lời 2026-09-04 **không** nói. Chỗ suy ra là **S-6** ở §7.2 — đừng đọc nó thành lời chủ quán,
  và đừng dựng màn người đi giao như thể câu ấy đã chốt.
- ⇒ *Chỗ từng chưa có lời, nay đã chốt — **U-049**, đóng **2026-09-08**:* tài liệu ở đây gọi người
  đi giao là *"nhân viên quán"* và không nói thêm; §3 chia **bốn vai** cho **năm trạm việc**, mà
  *đi giao* **không** phải một trạm. Chủ quán đã trả lời: **người đi giao là một trong bốn vai của
  §3**, không phải người thứ năm, và **POS chỉ định** ai đi từng lần — nguyên văn *"1 trong bốn vai
  trên có thể là bất cứ ai pos sẽ chỉ định."* Lời chốt và hệ quả của nó ở **§3**; đừng chép xuống
  đây (`work/findings.md` **F-001**). Vế §6.7 **không đổi một chữ**: hai nút *đã giao* + *đã thu
  tiền* vẫn không hỏi người bấm là ai, đúng như U-049 tự khai *"chưa chặn"* lúc còn mở.
- ⇒ *Phép đếm của người viết tài liệu, không phải lời chủ quán:* *"đã bưng ra bàn"* là thao tác
  **thứ bảy** người đứng quầy gánh, sau *"đã làm xong"* là thứ sáu. Con số bảy không phải một
  ranh giới; nó ghi ở đây vì nó là rủi ro vận hành thật — quầy là đôi tay bận nhất quán, và nay
  quầy bấm **cả hai** mốc của mỗi suất.

**Người đứng quầy phải nhìn được những thứ dưới đây cùng một lúc** — chủ quán liệt kê ngày
2026-08-31; **đếm được sáu, tính tới ngày đó**. Sáu là phép đếm của người viết tài liệu, không
phải một ranh giới chủ quán chốt (khác hẳn "đúng năm kênh" ở §2, thứ *là* quyết định). Thấy thứ
thứ bảy thì thêm vào đây:

1. Tổng **còn phải làm**, tách theo từng thành phần: bánh cuốn · trứng theo từng loại (chín, tái,
   vàng) · giò · nước chấm, kèm nhân và lượng nhân.
2. Số ấy **chia cho bàn nào**.
3. Bàn nào **đang ăn**, bàn nào **đang chờ món**.
4. Mỗi bàn **đã được phục vụ bao nhiêu**.
5. Mỗi bàn **còn thiếu gì**.
6. Hiện tại quán **đang thế nào** — bao nhiêu bàn chờ, bao nhiêu bàn đang phục vụ.

Đây là **một** thứ chủ quán mô tả: *"tôi cần nắm được hiện tại quán thế nào"*. Sáu dòng trên là
sáu phần của cùng một cái nhìn đó, không phải sáu màn hình.

**Ba chỗ từng để trống, chủ quán trả lời hết ngày 2026-08-31** (trước đó là U-008, U-009, U-010 ở
`docs/product/99-unknowns.md`):

**1 · Không có nút bấm nào ở trạm bếp.** Câu hỏi *ai bấm "đã làm xong" và "đã bưng ra bàn", theo
từng cái hay theo cả mẻ* được chủ quán trả lời bằng cách **bỏ bước ấy đi**: *"bỏ qua bước này, POS
sẽ tự cập nhật được bao nhiêu cái cho từng bàn"*. Người tráng bánh, người gấp bánh và người lấy
canh **không** phải bấm gì để báo xong — bắt bếp bấm là thêm việc cho ba đôi tay đang bận. Con số
"mỗi bàn đã được bao nhiêu" sinh ra ở **POS**, không sinh ra ở bếp.

**Cập nhật 2026-09-01 (S-4): luật này còn nguyên một chữ, nhưng nó nói về BẾP, không nói về quầy.**
Ngày 2026-09-01 chủ quán chốt là có một nút *"đã làm xong"* và **người đứng quầy** bấm nó (xem
bảng bốn con số ở trên). Ba trạm bếp vẫn không bấm gì. Đọc câu này thành *"cả quán không ai bấm
báo xong"* là đọc sai — chỗ đứng khác nhau, không phải luật khác nhau.

**2 · Đơn mang đi KHÔNG nằm chung bảng gom việc với bàn.** Chủ quán trả lời thẳng: **không**. Bảng
gom việc ở quầy là bảng **theo bàn**; ba kênh không gắn bàn (§2, §5.2) không đổ vào đó.

**3 · Nhưng khách ĐANG NGỒI BÀN gọi thêm suất để đem về thì suất ấy thuộc BÀN, không thành đơn
mang đi.** Lời chủ quán: *"có những lúc bàn đang ăn gọi đem về thì sẽ thêm suất cho bàn đó và note
lại là đem về; thế này quản lý đơn giản hơn, nhưng mục note đem về cần rõ ràng"*. Ba hệ quả:

- Suất đem về ấy vào **chính phiên bàn** đang mở, nên nó nằm trong **một** hoá đơn của bàn (§6.1)
  và được **tính vào nguồn "phiên bàn"** của báo cáo doanh thu, không tính vào nguồn "đơn lẻ"
  (§6.9). Không mở một đơn `pickup` hay `delivery` nào cho nó.
- Suất ấy **vẫn nằm trên bảng gom việc theo bàn** — vì nó là suất của bàn đó. Đây không phải ngoại
  lệ của luật 2 ở trên: luật 2 nói về ba kênh không gắn bàn, còn suất này gắn bàn.
- **Note "đem về" phải rõ ràng** — chủ quán nhấn đúng chữ này. Bếp và người bưng phải đọc ra ngay
  suất nào ăn tại chỗ, suất nào gói lại; đọc nhầm là khách mang về một đĩa không gói, hoặc một
  suất bị gói trong khi khách ngồi ăn.

**Và điều chủ quán đã chốt về quyền của máy: máy KHÔNG gom, người gom.** Ngày 2026-08-31 chủ quán
trả lời câu *hệ thống chỉ hiện tổng nhu cầu, hay được phép tự chia mẻ*: **hệ thống chỉ hiện tổng
nhu cầu để người tự gom — *"máy không làm, để người làm"***. Hệ thống **không** tự chia mẻ, **không**
tự xếp nồi, **không** tự quyết thứ tự làm và **không** đề xuất mẻ. Nó bày ra các con số ở trên; ai
gom, gom mấy quả, làm trước làm sau là quyết định của người ở bếp và ở quầy. Đây là một **ranh
giới đã chốt** như bốn ranh giới ở §6.12 — cho máy chia mẻ là đổi phạm vi, phải xin phép chủ quán.

## 6. Hai mươi bảy quy tắc nghiệp vụ phải đúng

1. **Khách gọi thêm khi quầy đã bắt đầu thu tiền vẫn thuộc CÙNG phiên, CÙNG một hoá đơn.** Phiên
   ở trạng thái "chờ thanh toán" **chưa** giải phóng bàn. Tách ra hoá đơn thứ hai ⇒ **thu thiếu
   tiền** — đây là lỗi tiền nguy hiểm nhất của luồng tại bàn.
2. **Đơn do KHÁCH tự gửi phải được quầy duyệt trước khi xuống bếp; đơn do NHÂN VIÊN nhập thì
   không.** Phải duyệt: `qr_table`, `delivery`, `pickup`. Không cần duyệt: `staff_pos`,
   `phone_preorder`. Lý do là mục đích của bước duyệt — chặn đơn ảo — chỉ có nghĩa với đơn không
   ai chịu trách nhiệm. Đơn chưa duyệt **không sinh việc ở bất kỳ trạm nào**.
3. **Mặc định thu tiền lúc trao hàng; riêng đơn mang đi, khách ĐƯỢC CHỌN trả trước** (chủ quán
   chốt 2026-08-30). Đường mặc định không đổi: ăn tại bàn thu ở quầy lúc đóng phiên · tới lấy
   thu ở quầy lúc khách tới · giao tận nơi thu **tại chỗ khách**, lúc đưa hàng. Cả ba trường
   hợp khách đều được chọn **tiền mặt hoặc VietQR**.
   - **Trả trước là tuỳ chọn của khách, cho cả ba kênh mang đi** (`delivery`, `pickup`,
     `phone_preorder` — §5.2). Khách không chọn gì thì đơn đi đường mặc định ở trên. **Luồng ăn
     tại bàn không có nhánh trả trước** — phiên bàn còn mở thì còn gọi thêm được, nên chưa
     chốt được số tiền để trả (§6.1).
   - ⇒ **Huỷ một đơn ĐÃ trả trước thì sinh việc hoàn tiền, xử theo §6.4** — quầy quyết từng ca
     và phải ghi vết. Đơn **chưa** trả tiền thì huỷ không sinh việc gì về tiền.
   - **Đơn trả trước trả bằng đúng hai phương thức đang có, và POS xác nhận vào lúc nhận tiền**
     (chủ quán chốt 2026-08-31, trả lời U-005). Không có phương thức thứ ba, không có cổng thanh
     toán nào: vẫn là **tiền mặt** hoặc **chuyển khoản VietQR**. Và mốc xác nhận là **lúc tiền
     thật sự tới tay quán** — người ở POS bấm xác nhận đã nhận tiền tại đúng thời điểm đó, không
     phải lúc khách bấm chọn "trả trước". VietQR ở đây là **tĩnh** (§1) nên hệ thống vẫn không tự
     biết tiền đã về; chọn "trả trước" là **ý định của khách**, còn "đã nhận tiền" chỉ do người
     bấm ở POS tạo ra. POS đặt ở quầy (§6.13) nên người bấm là **người đứng quầy**.
4. **Hoàn tiền: có, nhưng không có luật cứng — người ở quầy quyết định từng trường hợp** (chủ quán
   chốt 2026-08-30). Không phải mọi ca đều được hoàn, và cũng không cấm hoàn; quầy nhìn tình huống
   thật rồi quyết.
   ⇒ Chính vì **không có luật cứng nên mọi lần hoàn phải để lại vết**: hoàn bao nhiêu, cho đơn nào,
   ai bấm, lý do gì. **Người đứng quầy là người làm việc ghi vết đó** (chủ quán xác nhận
   2026-08-30) — cùng một người vừa quyết vừa ghi, nên không có ca nào hoàn tiền mà không ai đứng
   tên. Không có vết thì đối soát cuối ngày (§6.10) sẽ lệch mà không ai truy được — mà
   luật đối soát nói *lệch 1 đồng cũng phải tìm ra lý do*.
   - **Một lần hoàn tiền trừ vào doanh thu của NGÀY HOÀN, không phải ngày bán gốc** (chủ quán chốt
     2026-09-01, trả lời U-019). Bán hôm thứ Hai, hoàn hôm thứ Tư ⇒ doanh thu thứ Hai **giữ
     nguyên**, doanh thu thứ Tư bị trừ đi khoản đã hoàn.
   - ⇒ **Luật này NGƯỢC CHIỀU với luật nợ ở §6.14, và đó là chủ ý — đừng nhớ nhầm thành một.** Nợ
     tính vào **ngày ghi nợ** (ngày bán) dù tiền về sau; hoàn tính vào **ngày hoàn** dù hàng bán
     trước đó. Hai luật, hai chiều.
   - *Cách đọc, không phải lời chủ quán nói thẳng:* hai ca khác nhau ở chỗ **cái gì đã xong**. Một
     khoản nợ vẫn là một bữa ăn **đã bán xong**, chỉ có tiền là về muộn — nên nó thuộc ngày bán.
     Một lần hoàn thì không sửa lại chuyện đã bán; nó là **một quyết định mới của người đứng quầy**
     trong ngày hôm ấy (§6.4 không có luật cứng, quầy quyết từng ca) — nên nó thuộc ngày quyết.
   - ⇒ **Doanh thu của một ngày đã đối soát xong không bao giờ đổi về sau.** Đây là hệ quả đắt nhất
     của lời chốt này: mọi thứ xảy ra sau khi đóng sổ một ngày đều rơi vào ngày mới, nên con số đã
     ký hôm qua đọc lại lúc nào cũng bằng chính nó.
   - **Trả lại bằng gì — cũng không có luật cứng, POS quyết từng ca** (chủ quán chốt 2026-09-08,
     trả lời `U-044`). Nguyên văn: *"tuỳ vào tình hình thực tế, pos quyết định."* Khách đã chuyển
     khoản mà cần hoàn thì quầy có thể đưa **tiền mặt lấy trong két**, cũng có thể **chuyển khoản
     lại** — không đường nào bị cấm, không đường nào là mặc định. Cùng hình dạng với quyền hoàn ở
     trên: người đứng quầy nhìn tình huống thật rồi quyết.
   - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* **vết hoàn tiền phải ghi thêm một câu thứ năm
     — trả lại bằng phương thức nào.** Phần tiền mặt và phần chuyển khoản đối soát bằng **hai nguồn
     khác nhau** (§6.10), nên một lần hoàn trả ra ở phương thức **khác** với phương thức đã thu làm
     lệch **cả hai** phép đối chiếu cùng lúc, ngược chiều nhau: hoàn tiền mặt cho khoản đã chuyển
     khoản ⇒ két **vơi** đi một khoản mà doanh thu tiền mặt không hề chứa; hoàn chuyển khoản cho
     khoản đã thu tiền mặt ⇒ két **giữ nguyên** trong khi doanh thu tiền mặt bị trừ. Không ghi
     phương thức thì chỗ lệch ấy không truy ra được — đúng thứ ngưỡng 0đ cấm. Hệ quả cho phép trừ
     tiền két: `quality/invariants.md` **I-021** (viết lại 2026-09-15, `docs/decisions.md`
     **ADR-046**).
5. **Thông tin liên hệ cho ba kênh không gắn bàn.** Hai trường **bắt buộc**, phần còn lại người ở
   quầy điền theo tình huống thật lúc đó (chủ quán chốt 2026-08-30):

   | Trường | `delivery` | `pickup` | `phone_preorder` |
   |---|---|---|---|
   | **Số điện thoại** | **bắt buộc** | **bắt buộc** | **bắt buộc** |
   | **Địa chỉ giao** | **bắt buộc** | không cần | **bắt buộc nếu chọn giao tận nơi** |
   | Tên / cách xưng hô | nên có | nên có | nên có |
   | Giờ khách cần hàng | nên có | **bắt buộc** (giờ hẹn lấy) | **bắt buộc** |
   | Ghi chú (lối vào, mốc đường…) | tuỳ tình huống | tuỳ tình huống | tuỳ tình huống |

   Hai trường bắt buộc là **hệ quả của luồng**, không phải sở thích: không có số điện thoại thì
   không gọi lại được khi tới nơi, không có địa chỉ thì quán tự đi giao vào đâu. **Chủ quán xác
   nhận thẳng hai trường này là bắt buộc (2026-08-30)** — trước đó chúng mới là suy ra từ luồng.
6. **Mọi đơn đều có nước chấm — kể cả đơn mang đi.** Trạm `canh` sinh việc cho **mọi** đơn, không
   riêng đơn tại bàn; đơn mang đi thì gói riêng. Bỏ sót là khách nhận bánh không có nước chấm.
7. **Quán tự đi giao, và đơn giao tận nơi mang trạng thái "đang giao".** Quầy phải nhìn được đơn
   nào còn trên đường và ai đang cầm tiền chưa về. Giao xong bấm **đã giao + đã thu tiền** cùng lúc.
   - **POS bấm mốc VÀO trạng thái ấy** (chủ quán chốt 2026-09-01, trả lời U-023). Trước đó mới chốt
     mốc **ra** — người đi giao bấm *đã giao + đã thu tiền*; mốc **vào** thì chưa ai nói. Nay đủ hai
     đầu: **quầy bấm lúc đơn rời quán**, người đi giao bấm lúc giao xong. ⇒ Cùng một lý do với
     §6.13: quầy là chỗ nhìn thấy **ai đang cầm tiền chưa về**, nên quầy phải là chỗ đánh dấu lúc
     tiền rời quán.
8. **Nút "Tạm dừng nhận đơn" của chủ quán có ưu tiên CAO HƠN giờ mở cửa** — dùng khi hết nguyên
   liệu giữa buổi. Ngoài giờ bán, web khoá nút đặt và hiện *"Quán mở cửa 6h–11h sáng"*.
9. **Một khoản tiền gắn với đúng MỘT đơn vị tính tiền** — hoặc một phiên bàn, hoặc một đơn lẻ,
   không bao giờ cả hai. ⇒ **báo cáo doanh thu phải cộng từ CẢ HAI nguồn**; bỏ sót một nguồn là
   báo cáo thiếu tiền.
10. **Đối soát cuối ngày.** Trong 2 tuần đầu chạy thật, mỗi tối đối chiếu doanh thu hệ thống với
    **ba** nguồn: **sổ giấy**, **tiền trong két**, và **tin nhắn báo có của phần khách chuyển
    khoản** (chủ quán chốt 2026-09-01, trả lời U-019). **Lệch 1 đồng cũng phải tìm ra lý do.** Đây
    là cổng chất lượng mạnh nhất của cả dự án, mạnh hơn mọi bài kiểm thử.
    - **Nguồn thứ ba tồn tại vì két không giữ tiền chuyển khoản.** Quán có hai phương thức (§1) mà
      chỉ một đi qua két, nên so doanh thu với mỗi *sổ giấy + két* thì phần VietQR không có gì để
      đối chiếu. Chủ quán trả lời thẳng: *"đối chiếu qua tin nhắn khách chuyển khoản"* — tin nhắn
      báo có trên điện thoại là bản ghi độc lập của phần ấy.
    - ⇒ **Đối soát chia theo PHƯƠNG THỨC, không cộng gộp.** Phần tiền mặt so với két; phần chuyển
      khoản so với tin nhắn. Cộng hai phần lại rồi so với một con số tổng thì một chỗ thiếu ở két
      có thể bị một chỗ thừa ở ngân hàng che mất, và ngưỡng 0đ không còn nghĩa gì.
    - ⇒ **Một lần thu chia hai phương thức (§6.18) phải ghi rõ từng phần**, nếu không thì không
      xếp được vào nguồn nào để đối chiếu.
11. **Sổ giấy là kế hoạch dự phòng BẮT BUỘC.** Mất điện, mất mạng, hoặc máy hỏng ⇒ quán chuyển sang
    ghi tay và **không dừng bán**.
    - **Người giữ sổ và người nhập lại: POS hoặc chủ quán** (chủ quán chốt 2026-09-02, trả lời
      U-025). Không giao cho trạm bếp nào — vẫn đúng một cửa như mọi việc chạm tiền khác (§6.13).
    - **Nhập lại NGAY KHI CÓ THỂ, không có mốc giờ cứng** (cùng lời chốt). Chủ quán nói thẳng:
      *"nhập ngay khi có thể… túm lại khi có thể sẽ nhập"*. Không có luật *"phải nhập trước cuối
      ngày"* — người làm nhìn tình hình thật rồi nhập.
    - **Có điện lại giữa buổi thì quay lại làm trên hệ thống ngay, phần ghi tay cập nhật sau**
      (cùng lời chốt). Bán tiếp là việc gấp, nhập bù là việc sau — không bắt quán dừng bán để gõ
      cho kịp sổ.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* vì không có mốc cứng, **đối soát cuối ngày
      (§6.10) có thể chạy khi phần ghi tay chưa vào máy hết**. Ngày mất điện là ngày bảng đối soát
      phải đọc được *"còn N lượt bán trên giấy chưa nhập"*, nếu không thì ngưỡng **0đ** sẽ báo lệch
      mà lý do chỉ là chưa gõ xong. Đây là hệ quả của lời chốt, phải nói ra chứ đừng để §6.10 tự vỡ.
    - **Lượt bán ghi trên giấy tính doanh thu vào NGÀY QUÁN BÁN, không phải ngày gõ vào máy**
      (chủ quán chốt **2026-09-04**, trả lời **U-032** — nguyên văn: *"bán"*). Hôm mất điện quán
      bán 30 suất ghi giấy, hôm sau mới nhập ⇒ 30 suất ấy nằm trong doanh thu của **hôm mất điện**.
      Cùng chiều với luật nợ (§6.14, *doanh thu tính ngày ghi nợ*): tiền về lúc nào không đổi được
      **ngày bán**.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* hai lời chốt trên gộp lại thì **doanh thu
      của một ngày đã đối soát CÓ đổi về sau** — đúng một ca, và là ca này. Nên **một ngày còn lượt
      bán trên giấy chưa nhập là một ngày CHƯA đối soát xong**: dòng *"còn N lượt bán trên giấy chưa
      nhập"* ở trên không phải một lời chú thích, nó là **điều kiện** để ngưỡng **0đ** của §6.10 còn
      nghĩa. Nhập xong thì con số của ngày ấy đổi, và ai đó phải nhìn lại nó — **ai nhìn lại và lúc
      nào thì chưa chốt** (`docs/product/99-unknowns.md` **U-037**). Hệ quả cho `quality/invariants.md`
      **I-014** ghi ở `docs/decisions.md` **ADR-037**.
    - **Mất mạng mà hệ thống vẫn sống thì WEB NGỪNG NHẬN ĐƠN, và trên web có một dòng thông báo cho
      khách** (chủ quán chốt **2026-09-04**, trả lời **U-035** — nguyên văn: *"không cho đặt qua web
      cho đặt qua hotline và ghi giấy trực tiếp với pos, trên web có dòng thông báo"*). Khách muốn
      đặt thì **gọi hotline**; quán **ghi giấy trực tiếp cùng POS** như mọi ca ở mục này.
      - Đây là **điều kiện thứ ba** để một đơn được tạo, đứng cạnh *trong giờ bán* và *chủ quán
        không bấm tạm dừng* (§6.8) — nay ở `quality/invariants.md` **I-008**. Nó khác hai điều kiện
        kia ở một chỗ: hai điều kiện kia do **người** bật, điều kiện này thì **không ai bấm được**,
        vì lúc quán mất mạng thì nút tạm dừng cũng nằm sau đúng đường mạng vừa mất.
      - **Ba kênh khách tự bấm cùng dừng**: `delivery`, `pickup` và `qr_table` (§2). ⇒ *Cách đọc:*
        chủ quán nói *"web"*; `qr_table` cũng là trang web khách mở trên điện thoại của họ, và khách
        ngồi bàn thì gọi nhân viên — đúng vế *"ghi giấy trực tiếp với POS"*. Hai kênh còn lại
        (`staff_pos`, `phone_preorder`) là **người của quán** nhập nên không dừng: mất mạng thì họ
        ghi giấy.
      - **Câu chữ của dòng thông báo chưa chốt** — chủ quán mới nói *có một dòng*, chưa đọc nội
        dung. Đừng tự viết một câu rồi coi là đã chốt (`CLAUDE.md` §3.5); hỏi khi dựng màn (pha 4).
      - **AI BẤM DỪNG: máy BÁO, POS QUYẾT — và đã dừng thì mở lại bằng NÚT** (chủ quán chốt
        **2026-09-16**, trả lời **U-043** — nguyên văn: *"hiên thông báo để pos quyết định nếu dừng
        cần có nut mở lại"*). Câu hỏi hỏi *mất tín hiệu **bao lâu** thì web ngừng nhận đơn*; lời đáp
        **bỏ chính giả định ấy**: không có con số cửa sổ nào, vì việc dừng không do đồng hồ quyết.
        Ba điều lời này chốt:
        1. thấy dấu hiệu mất kết nối thì hệ thống **hiện một thông báo** ở quầy — nó **báo**, không
           tự kết luận thay người;
        2. **POS** là người quyết ba kênh khách tự bấm có dừng hay không;
        3. đã dừng thì **mở lại là một nút người bấm** — **không** tự mở lại khi tín hiệu về.
        - ⇒ Vế *"web ngừng nhận đơn"* của lời chốt `U-035` (2026-09-04) giữ nguyên **cái gì xảy
          ra**; lời này chốt **ai bấm**, và câu trả lời là **người**, không phải cái đồng hồ. Cùng
          hình dạng *POS quyết theo tình hình thực tế* đã gặp ở §5.4 · §6.4 · §6.24.
        - ⛔ **Ca quán MẤT MẠNG HẲN thì lời này KHÔNG phủ** — lúc ấy POS không nhìn thấy thông
          báo và cũng không bấm được nút nào, mà đó đúng là ca điều kiện thứ ba sinh ra để chặn
          (`quality/invariants.md` **I-008**). Máy có **tự** dừng ba kênh trong ca ấy không là
          `docs/product/99-unknowns.md` **U-053**. Không suy hộ (`CLAUDE.md` §3.5).
      - **Máy làm sao biết quán đang mất kết nối** là **cơ chế**, không phải dữ kiện quán: nó thuộc
        `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 bước **P1-08** và pha 3.
12. **Bốn ranh giới đã chốt — đây là quyết định, không phải chỗ trống chờ ai điền:**

    | Không làm | Vì sao |
    |---|---|
    | Kênh bán **thứ sáu** | §2 chốt đúng năm kênh |
    | Đơn tối thiểu, bậc phí ship | ship 0đ và không đơn tối thiểu là chốt |
    | Số tài khoản ngân hàng cứng trong sản phẩm | §1 chốt là nhập trong phần quản trị |
    | Món ngoài bảng giá §4.2 | thêm món là đổi phạm vi |

    Thêm bất kỳ thứ nào trong bốn thứ trên là **đổi phạm vi, quyền chủ quán**.

13. **Chỉ người đứng quầy được huỷ một đơn** (chủ quán chốt 2026-08-30) — bấm trên máy POS ở quầy.
    Nhân viên ở bốn trạm còn lại (`trang_banh`, `gap_banh`, `canh`, `don_ban`) **không** huỷ được
    đơn, kể cả đơn của chính việc mình đang làm.
    **Quyền huỷ gắn với CHỖ ĐỨNG, không gắn với chức vụ** (chủ quán chốt 2026-08-30). Hai ca của
    chính chủ quán:

    | Chủ quán… | Huỷ đơn thế nào |
    |---|---|
    | **đang đứng quầy** | tự bấm — lúc đó chủ quán làm đúng việc của trạm `quay` (§3) |
    | **không đứng quầy** | **nhờ người đứng quầy bấm trên POS** — không có đường huỷ riêng nào khác |

    Chức vụ không mở thêm cửa nào. **Mọi lần huỷ đều đi qua đúng một cửa: máy POS ở quầy**, nên
    lần huỷ nào cũng có đúng một người đứng tên.

    Quyền này đi đôi với hai luật đã có: quầy là nơi **duyệt** đơn (§6.2) và là nơi **quyết định
    hoàn tiền** (§6.4). Cùng một người chịu trách nhiệm cho cả ba việc chạm tiền, nên đối soát
    cuối ngày (§6.10) luôn truy được về một người.

14. **Khách không trả được thì quán CHO NỢ; đóng phiên trên POS phải ghi AI nợ và nợ BAO NHIÊU**
    (chủ quán chốt 2026-08-31, trả lời U-007). Đây là đường chính thức cho ca khách rời quán mà
    chưa trả tiền — không phải một ngoại lệ chờ ai đó nghĩ ra cách xử.
    - **Phiên vẫn được đóng.** Không có chuyện để phiên mở mãi chờ tiền: đóng phiên rồi dọn bàn
      thì bàn trở lại trống như mọi phiên khác (§6.1 vẫn đúng — bàn trống cần đóng phiên **và**
      dọn bàn). Nếu không cho nợ thì một bàn quỵt tiền sẽ khoá luôn cái bàn đó.
    - **Đóng phiên kiểu này bắt buộc ghi hai thứ: ai nợ, nợ bao nhiêu.** Thiếu một trong hai thì
      khoản nợ vô chủ, và đối soát cuối ngày (§6.10) sẽ thấy két thiếu tiền mà không ai truy được
      — đúng thứ luật *lệch 1 đồng cũng phải tìm ra lý do* cấm.
    - ⇒ **Ghi nợ phá tính ẩn danh của phiên bàn.** Bình thường phiên bàn ẩn danh theo số bàn (§2);
      ca này bắt buộc phải có một cái tên hoặc một cách gọi lại được. Đó là cái giá của việc cho
      nợ, chủ quán đã chấp nhận.
    - ⇒ **Một khoản nợ KHÔNG phải tiền đã thu.** Doanh thu trong ngày và tiền trong két lệch nhau
      đúng bằng tổng nợ ghi trong ngày; §6.9 và §6.10 phải đọc được con số đó, nếu không đối soát
      sẽ báo lệch mỗi lần có người nợ.
    - **Người nợ quay lại trả thì POS ghi nhận** (chủ quán chốt 2026-08-31, trả lời U-012) — cùng
      một cửa với mọi việc chạm tiền khác.
    - **Doanh thu tính vào NGÀY GHI NỢ, không phải ngày thu được tiền** (chủ quán chốt
      2026-08-31, trả lời U-012). Bữa ăn bán ngày nào thì doanh thu ngày ấy; lần trả sau chỉ là
      tiền về, không phải một lần bán mới.
    - ⇒ **Đối soát lệch ở HAI ngày khác nhau, và cả hai đều phải có tên**: ngày ghi nợ, két
      **thiếu** đúng bằng tổng nợ ghi trong ngày; ngày người ta trả, két **thừa** đúng bằng tổng
      nợ cũ thu được hôm đó, trong khi doanh thu hôm đó không tăng. Bảng đối soát (§6.10) phải bày
      **cả hai** dòng, nếu không thì đúng luật *lệch một đồng cũng phải tìm ra lý do* sẽ báo động
      giả mỗi lần có người nợ hoặc trả nợ.
    - ⇒ **Một lần trả nợ không bao giờ được ghi thành một khoản bán mới.** Ghi thành khoản bán là
      **tính doanh thu hai lần** cho cùng một bữa ăn — lỗi tiền nặng hơn cả việc quên thu.
15. **Khách đang ngồi bàn gọi thêm suất để ĐEM VỀ thì suất ấy thuộc PHIÊN BÀN, kèm note "đem về"**
    (chủ quán chốt 2026-08-31, trả lời U-010). Không mở đơn `pickup` hay `delivery` nào cho nó —
    chủ quán chọn đường này vì *"thế này quản lý đơn giản hơn"*.
    - Suất ấy vào **một** hoá đơn của bàn (§6.1) và tính vào nguồn **phiên bàn** của báo cáo doanh
      thu, không tính vào nguồn đơn lẻ (§6.9).
    - **Note "đem về" phải rõ ràng** — chủ quán nhấn đúng chữ này. Bếp và người bưng phải đọc ra
      ngay suất nào ăn tại chỗ, suất nào gói lại.
    - Luật này **không** mở đường ngược lại: một đơn `delivery`, `pickup` hay `phone_preorder` vẫn
      không bao giờ nối được vào phiên bàn (§2, §5.2).
16. **Ghép bàn: nhiều bàn ghép lại là MỘT phiên và MỘT hoá đơn** (chủ quán chốt 2026-08-31, trả
    lời U-006). Ghép bàn là chuyện có thật ở quán, không phải ca hiếm — quán có nhiều bàn (**15**,
    §1 — con số đổi 2026-09-06, xem §1) và nhóm đông thì ngồi tràn sang bàn bên.
    - **Một phiên phục vụ được nhiều bàn.** Đây là chỗ luật cũ phải đọc lại: câu đúng không phải
      *"một bàn một phiên"* mà là **"một bàn thuộc nhiều nhất một phiên chưa thanh toán"**. Một
      phiên gắn **một hoặc nhiều** bàn; một bàn thì không bao giờ nằm trong hai phiên còn mở.
    - **Mọi lượt gọi từ bất kỳ bàn nào trong nhóm đều vào cùng phiên ấy**, bằng bất kỳ tổ hợp nào
      của `qr_table` và `staff_pos`. Khách ngồi bàn 4 quét QR trên bàn 4, khách ngồi bàn 5 quét QR
      trên bàn 5 — vẫn **một** hoá đơn. Đây là §6.1 nới ra cho nhóm bàn, không phải luật mới chống
      lại nó: tách nhóm ghép thành hai hoá đơn cũng là **thu thiếu tiền** theo đúng nghĩa cũ.
    - **Bàn trở lại trống theo TỪNG bàn.** Phiên đóng là điều kiện chung cho cả nhóm, nhưng dọn
      bàn thì dọn từng cái: bàn 4 trống khi phiên đã đóng **và** bàn 4 đã được dọn, không phụ
      thuộc bàn 5 dọn xong chưa (§6.1 giữ nguyên hai điều kiện).
    - **Việc xuống bếp vẫn ghi bàn nào gọi**, không ghi "nhóm" — người bưng cần biết bưng tới chỗ
      nào (§5.3, §5.4). Ghép là chuyện của **tiền**, không phải chuyện của bếp.
    - **Người đứng quầy bấm ghép, trên POS** (chủ quán chốt 2026-08-31, trả lời U-013). Cùng một
      cửa với duyệt đơn (§6.2), huỷ đơn (§6.13), hoàn tiền (§6.4) và ghi nợ (§6.14) — mọi việc
      chạm tiền đi qua đúng một máy, nên truy được về một người khi đối soát (§6.10).
    - **CHỈ ghép được khi bàn kia còn TRỐNG. Bàn đang có phiên mở thì KHÔNG ghép được**
      (chủ quán chốt 2026-08-31, trả lời U-013). Đây là **ranh giới**, không phải hạn chế kỹ
      thuật chờ ai gỡ.
    - ⇒ **Ghép bàn là NỚI một phiên đang mở sang một bàn trống, không bao giờ là GỘP hai hoá
      đơn.** Hai việc nghe giống nhau nhưng khác hẳn: nới thì chưa có đồng nào của bàn kia phải
      dời chỗ; gộp thì phải trộn tiền của hai hoá đơn đã có. Chủ quán chọn đường thứ nhất và
      đóng đường thứ hai.
    - ⇒ **Hai nhóm đã ngồi hai bàn riêng, mỗi bàn một phiên, thì trả HAI hoá đơn** — kể cả khi
      họ quen nhau và xin gộp. Muốn một hoá đơn thì phải ghép **trước khi** bàn thứ hai được mở
      phiên. Đây là hệ quả trực tiếp của luật trên, không phải luật thêm.
    - ⇒ Luật này giữ nguyên vẹn *"một bàn thuộc nhiều nhất một phiên chưa thanh toán"* ở gạch đầu
      dòng thứ nhất: bàn được ghép vào đang **trống**, tức chưa thuộc phiên nào.

17. **Chủ quán sửa GIÁ được ngay giữa giờ bán; sửa THÀNH PHẦN một suất thì phải chờ hết buổi**
    (chủ quán chốt 2026-09-01). Ba câu hỏi, một lần trả lời, ra **hai** luật khác nhau — đây là chỗ
    dễ nhớ nhầm thành một.
    - **Ba chiều tiền sửa lúc nào cũng được.** Giá một thành phần (§4.2), mức phụ thu nhân, mức phụ
      thu lượng nhân (§4.4): chủ quán **không phải chờ đến hết buổi**, sửa giữa giờ bán 06:00–11:00
      (§1) cũng được. Hiệu lực tính từ **lúc chủ quán lưu**, không có lịch hẹn giờ.
    - **Chiều thứ tư phải chờ.** Đổi **thành phần của một suất bán** (§4.5 — combo gồm mấy cái
      bánh, suất giò gồm những gì) **chỉ làm sau khi hết buổi bán**, không làm giữa giờ bán.
    - **Lượt gọi nào tính giá của lượt ấy.** Một phiên bàn đang mở vắt qua mốc đổi giá thì lượt gọi
      **trước** mốc giữ giá cũ, lượt gọi **sau** mốc áp giá mới ⇒ **một hoá đơn mang hai mức giá
      cho cùng một món**, và chủ quán **chấp nhận** điều đó. Đây không phải lỗi tính tiền: §6.1 vẫn
      nguyên vẹn — một phiên, một hoá đơn — chỉ có điều tổng của nó cộng từ những lượt gọi có giá
      khác nhau.
    - ⇒ **Ranh giới là thời điểm tạo một LƯỢT GỌI**, không phải lúc mở phiên và cũng không phải lúc
      thanh toán. Khoá giá theo lúc mở phiên là **sai** với lời chốt này; tính lại cả phiên theo giá
      mới lúc thanh toán còn sai nặng hơn — đó là sửa tiền của một thứ khách đã ăn xong.
    - ⇒ **Đối soát cuối ngày (§6.10) phải đọc được chuyện này.** Ngày nào chủ quán đổi giá giữa buổi
      thì trong ngày ấy cùng một món có hai giá đúng, và cả hai đều đúng. Coi đó là lệch rồi đi tìm
      lý do là báo động giả — nhưng *lệch 1 đồng cũng phải tìm ra lý do* vẫn nguyên: lý do ở đây có
      tên, là lần đổi giá lúc mấy giờ.
    - *Cách đọc, không phải lời chủ quán nói thẳng:* hai chiều xử khác nhau vì chúng hỏng khác nhau.
      Đổi giá chỉ đổi **số tiền** của đơn sau đó; đổi thành phần đổi **thứ bếp phải làm ra**, mà
      bếp thì đang làm theo **mẻ** (§5.4) — sửa giữa chừng là hai suất cùng tên, cách nhau mười
      phút, trong quán có ruột khác nhau. Máy chữa được cái thứ nhất, không chữa được cái thứ hai.
    - *Cách đọc theo §1, không phải lời chủ quán nói thẳng:* **"hết buổi" là sau 11:00** — quán bán
      đúng một buổi mỗi ngày nên hết buổi và hết ngày bán là một. Quán mở thêm buổi thứ hai thì
      phải hỏi lại câu này.
    - **Máy chỉ NHẮC MỘT CÂU, không chặn** (chủ quán chốt 2026-09-01, trả lời U-018). Chủ quán bấm
      sửa thành phần lúc 9h sáng thì máy nói ra rằng đang trong giờ bán và luật là chờ hết buổi —
      rồi **vẫn cho lưu** nếu chủ quán muốn thế. Đây là **quyết định**, không phải chỗ chưa làm
      xong: chủ quán giữ quyền tự phá luật của chính mình.
    - ⇒ **Luật "chờ hết buổi" là luật cho NGƯỜI, không phải hàng rào của máy.** Hệ quả phải nói
      thẳng: trong quán vẫn có thể có một ngày mà thành phần suất đổi lúc 9h sáng. Tài liệu nào
      viết như thể máy bảo đảm điều đó không xảy ra là **sai**.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* vì máy không chặn, **lần lưu ấy phải để lại
      vết** — đổi cái gì, lúc mấy giờ, ai bấm. Đây không phải luật mới mà là hai luật đã có cộng
      lại: đổi thành phần là đổi **tiền** của suất (§4.6 luật 1), và mọi thao tác chạm tiền đều
      phải truy ngược được cho đối soát cuối ngày (§6.10). Không có vết thì lời nhắc chỉ là một
      hộp thoại bấm cho qua.

18. **Một lần thu tiền chia được làm nhiều phương thức, và POS ghi số tiền của TỪNG phần** (chủ
    quán chốt 2026-09-01, trả lời U-020). Khách trả một phần tiền mặt, một phần chuyển khoản thì
    quán **nhận cả hai** — *"POS xác nhận thông tin bao nhiêu chuyển khoản, bao nhiêu tiền mặt"*.
    - **Vẫn đúng hai phương thức (§1), không có phương thức thứ ba.** Luật này không thêm cách trả
      nào; nó nói rằng **một lần thu** không bị buộc phải nằm gọn trong một phương thức.
    - **Tổng các phần đã thu = số tiền phải trả.** Thiếu thì đó là **nợ** và xử theo §6.14 (ghi ai
      nợ, nợ bao nhiêu); không có ca nào tổng các phần lớn hơn số phải trả.
    - **Mỗi phần mang đúng một phương thức, và số tiền của từng phần phải ghi riêng.** Ghi gộp
      thành một con số tổng là làm hỏng đối soát cuối ngày: §6.10 so **phần tiền mặt với két** và
      **phần chuyển khoản với tin nhắn báo có**, nên một lần thu không tách được thì không xếp vào
      nguồn nào.
    - **Người xác nhận không đổi:** vẫn là người bấm ở POS theo §6.3 — người đứng quầy, hoặc người
      đi giao với đơn giao tận nơi (§6.7). Chia phương thức không mở thêm cửa nào.
    - *Cách đọc, không phải lời chủ quán nói thẳng:* chữ **hoặc** trong *"tiền mặt hoặc VietQR"* ở
      §1 và §6.3 mô tả **lựa chọn của khách**, không phải một ràng buộc rằng mỗi lần thu chỉ được
      một phương thức. Tài liệu nào đọc chữ *hoặc* ấy thành luật loại trừ là **sai** — đó đúng là
      chỗ `docs/product.md` §4.6 viết sai trong ngày 2026-09-01 trước khi có lời chốt này.

19. **Đơn đã xác nhận thì SỬA được, và sửa trên POS** (chủ quán chốt 2026-09-01, trả lời một nửa
    U-022). Câu hỏi là *"khách đổi ý thì quán sửa đơn ấy, hay huỷ rồi tạo lại"*; chủ quán trả lời
    **"pos sửa đơn"**. Vậy đường chính thức là **sửa**, không phải huỷ-rồi-tạo-lại, và nó đi qua
    đúng cái cửa mọi việc chạm tiền đã đi qua: **máy POS ở quầy** (§6.13).
    - **Sửa là đổi NỘI DUNG đơn, không phải đẩy đơn sang một trạng thái khác.** Đơn đang ở đâu thì
      vẫn ở đó; cái đổi là món, số suất hoặc tuỳ chọn (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2).
    - **Sửa được ở BẤT KỲ trạng thái nào, và POS quyết theo tình hình thực tế** (chủ quán chốt
      2026-09-02, trả lời nốt U-022): *"quán đang ở trạng thái nào cũng sửa được. POS sẽ quyết định
      dựa trên tình hình thực tế."* **Không có mốc trạng thái cứng** — không có ranh giới kiểu
      *"bếp đã tráng rồi thì thôi"*. Đơn đã `Hoàn thành` cũng nằm trong chữ *bất kỳ*.
    - ⇒ **Luật này cùng họ với §6.4 (hoàn tiền) và với đường lùi một mẻ (§5.4).** Ba chỗ, một kiểu:
      chủ quán **không** dựng hàng rào cho máy, mà giao quyết định cho **người đứng quầy** nhìn ca
      thật. Tài liệu nào biến nó thành một bảng điều kiện là hiểu ngược lời chốt.
    - ⇒ **Vì không có luật cứng nên mọi lần sửa phải để lại vết** — sửa đơn nào, đổi gì, lúc mấy
      giờ, ai bấm. Đây là §6.10 áp vào, không phải luật mới: sửa đơn **chạm tiền**.
    - **Vế HUỶ nay cũng đã chốt: HUỶ ĐƯỢC, kể cả đơn đã `Hoàn thành`, và POS quyết** (chủ quán
      chốt 2026-09-02, trả lời U-027): *"có thể huỷ được, để POS quyết định trong thực tế."* ⇒ Bảng
      vòng đời đơn có thêm dòng `Hoàn thành → Huỷ` (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2), và ca ấy **rời** danh
      sách chuyển tiếp bị từ chối (§5.6).
    - ⇒ **Sửa và huỷ nay CÙNG một luật: không có mốc trạng thái nào chặn, POS quyết từng ca.** Hỏi
      hai lần, hai ngày, ra cùng một câu trả lời — đó là **luật**, không phải hai lời chốt rời.
    - ⇒ **Huỷ một đơn đã `Hoàn thành` gần như luôn kéo theo tiền**: hàng đã tới tay khách và tiền
      có thể đã thu, nên lần huỷ ấy đi kèm **hoàn tiền** theo §6.4 — quầy quyết từng ca, để lại
      vết, và khoản hoàn rơi vào **ngày hoàn**. Huỷ không phải đường vòng tránh §6.4.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* sửa một đơn **đã `Hoàn thành`** thì tiền đã
      có thể thu xong rồi, nên lần sửa ấy kéo theo một khoản chênh — thu thêm, hoặc **hoàn** theo
      §6.4 (và khoản hoàn rơi vào **ngày hoàn**). Sửa không phải là một đường vòng tránh §6.4.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* sửa một đơn **đã nổ việc xuống bếp** thì việc
      ở các trạm phải nổ lại theo nội dung mới (§5.3), và một suất bếp đã làm ra theo nội dung cũ
      không tự biến mất. Đây là lý do vế *"sửa được tới trạng thái nào"* không phải chuyện nhỏ —
      nó là ranh giới giữa *sửa* và *làm lại*.
    - ⇒ *Cách đọc, không phải lời chủ quán nói thẳng:* sửa đơn **chạm tiền**, nên nó thuộc luật
      §6.10 và phải để lại vết như mọi thao tác chạm tiền khác. Và nó đụng mốc khoá giá ở §6.17
      (*giá khoá theo từng lượt gọi*).
    - **Một dòng vừa sửa lấy GIÁ ĐANG HIỆU LỰC LÚC SỬA** (chủ quán chốt 2026-09-02, trả lời U-026).
      Không giữ giá cũ của lượt gọi: dòng nào bị sửa thì **mốc khoá giá của chính dòng ấy được đặt
      lại** về thời điểm sửa.
    - ⇒ **Đây là NGOẠI LỆ có chủ ý của §6.17, không phải mâu thuẫn.** §6.17 nói *lượt gọi nào tính
      giá của lượt ấy* — luật ấy trả lời câu *"chủ quán đổi giá thì đơn cũ có bị kéo theo không?"*
      và câu trả lời vẫn là **không**: một lần đổi giá **không bao giờ** tự với ngược vào dòng cũ.
      Cái đặt lại mốc ở đây là **một thao tác cố ý của người đứng quầy** trên đúng dòng đó, không
      phải lần đổi giá. Hai chuyện khác nhau, đừng nhớ nhầm thành một.
    - ⇒ **Sửa một dòng là ĐỊNH GIÁ LẠI dòng ấy.** Hệ quả phải nói thẳng vì nó chạm tiền của khách:
      khách đổi sang món đắt hơn thì trả giá **mới**; và nếu chủ quán vừa đổi giá giữa buổi, một
      dòng sửa sau mốc ấy sẽ **đắt hơn hoặc rẻ hơn** chính nó lúc mới gọi, dù khách không đổi món.
    - ⇒ **Vết của lần sửa phải ghi cả GIÁ CŨ và GIÁ MỚI**, không chỉ ghi "đã sửa". Đối soát cuối
      ngày ngưỡng **0đ** (§6.10) chỉ giải thích được chỗ lệch nếu đọc được dòng nào đổi giá lúc
      mấy giờ; đây là §6.10 áp vào, không phải luật mới. **Hình dạng đầy đủ của cái vết ấy nay ở
      §6.22** — bản trước, bản sau, lý do, người sửa (`quality/invariants.md` I-018).

20. **Món hết sau khi khách đã chọn: POS làm việc với khách, quyết định ra tại lúc thoả thuận xong**
    (chủ quán chốt 2026-09-02). Không có luật cứng kiểu *"tự động thay thế"* hay *"tự động huỷ"*:
    người đứng quầy gọi khách, bàn với khách, và **kết quả là cái hai bên thống nhất tại thời điểm
    đó** — đổi sang thứ khác, bỏ phần thiếu, hay huỷ cả đơn.
    - **Quy mô của ca này lớn hơn tên gọi của nó.** Mọi suất bán đều kèm bánh cuốn (§4.5), nên
      **hết bánh là hết gần như mọi món** — không phải một dòng menu tắt đèn mà phần lớn thực đơn
      tắt cùng lúc. Lời chốt này vì thế áp cho **nhiều bàn một lúc**, không phải một đơn lẻ.
    - **Đường đã có cho đơn CHƯA vào là nút tạm dừng nhận đơn của chủ quán (§6.8).** Hai việc khác
      nhau và phải làm cả hai: §6.8 chặn đơn **mới**, quy tắc này xử những đơn **đã nhận rồi**.
    - ⇒ **Huỷ hoặc bớt món ở đây kéo theo tiền**: đơn đã trả trước thì sinh việc hoàn, xử theo
      §6.4; đơn chưa trả thì chỉ bớt số phải trả. Không có ca nào quán giữ tiền của phần không giao.
21. **Khách nói đã chuyển khoản mà quầy chưa thấy tin nhắn báo có: POS thảo luận với khách và quyết
    ngay lúc đó** (chủ quán chốt 2026-09-02). Không có luật cứng *"phải giữ khách lại chờ"* và cũng
    không có luật *"cứ cho đi"* — người đứng quầy nhìn ca thật rồi quyết.
    - **Vì sao ca này có thật:** VietQR của quán là mã **tĩnh** (§1), nên **máy không bao giờ tự
      biết tiền đã về**; câu *"đã nhận tiền"* chỉ do người bấm ở POS tạo ra (§6.3). Khoảng chênh
      giữa lúc khách bấm chuyển và lúc tin nhắn tới là khoảng có thật, ngày nào cũng gặp.
    - **Hai đường ra đều đã có sẵn, không cần đẻ trạng thái mới:** quầy tin và cho đi ⇒ ghi **nợ**
      theo §6.14 (ai nợ, bao nhiêu), xoá nợ khi tin nhắn tới; hoặc quầy chờ tin nhắn rồi mới đóng
      phiên theo §6.3. Chọn đường nào là quyết định của người đứng quầy tại ca đó.
    - ⇒ **Dù chọn đường nào cũng không được ghi là "đã thu tiền mặt"** — phần chuyển khoản đối
      chiếu bằng **tin nhắn báo có**, phần tiền mặt đối chiếu bằng **két**, và §6.10 cấm cộng gộp
      hai nguồn. Ghi nhầm nguồn là làm hỏng đúng cái ngưỡng 0đ.
22. **Sửa cái sai bằng CẬP NHẬT, không bằng hoàn tác — và mỗi lần cập nhật giữ BẢN TRƯỚC, BẢN SAU,
    LÝ DO và NGƯỜI SỬA** (chủ quán chốt 2026-09-02). Ngoài đúng một ca đã có đường lùi — bấm nhầm
    *"đã làm xong"* một mẻ (§5.4) — **không thao tác nào có nút hoàn tác**: duyệt nhầm một đơn, huỷ
    nhầm, đóng phiên nhầm đều **không** quay ngược được. Thay vào đó có **nút cập nhật**, và lần
    cập nhật ấy phải để lại một bản ghi đọc được về sau.
    - **Bốn thứ một bản ghi phải trả lời:** **trước** khi sửa là thế nào · **sau** khi sửa là thế
      nào · **lý do** · **ai sửa**. Chủ quán nói thẳng mục đích: *"để đối chiếu"* — nên bản ghi này
      phục vụ §6.10, không phải một tính năng lịch sử cho vui.
    - **"Bản copy trước và sau" là nguyên văn, và nó mạnh hơn một dòng log.** Ghi *"đã sửa đơn 12"*
      là **chưa đủ**: phải dựng lại được đơn 12 **trước** lúc sửa và **sau** lúc sửa. Đây là chỗ
      một bản ghi kiểu *"ai làm gì lúc mấy giờ"* thường thiếu, và thiếu đúng thứ để đối chiếu.
    - **Luật này áp cho cả ca HAI NGƯỜI CÙNG THAO TÁC trên một bàn** (chủ quán chốt cùng lúc):
      người bấm **sau thắng**, nhưng lần ghi đè ấy vẫn phải **note ai là người sửa** và giữ bản
      trước — nếu không thì một lượt gọi bị đè mất sẽ không ai truy ra, và đó là **thu thiếu tiền**
      đúng nghĩa §6.1.
    - ⇒ **Quan hệ với §6.10 và §6.4:** đây là điều kiện để *lệch 1 đồng cũng tìm ra lý do* chạy
      được ở những ca **không phải lỗi cộng trừ** mà là **có người sửa tay**. Hoàn tiền (§6.4) và
      sửa đơn (§6.19) đã có luật *"để lại vết"*; quy tắc này nói **vết ấy gồm những gì**.
    - *Cách đọc, không phải lời chủ quán nói thẳng:* chữ **lý do** chủ quán nêu ở ca *nút cập nhật*
      (thao tác nhầm); áp nó cho **mọi** lần cập nhật — kể cả lần sửa đơn theo yêu cầu khách — là
      **suy ra**, không phải lời chốt. Suy thế vì không có cách nào phân biệt lúc ghi: một lần sửa
      đơn và một lần sửa vì bấm nhầm nhìn giống hệt nhau trong bản ghi, và cái phân biệt chúng
      **chính là** ô lý do. Chủ quán nói khác đi thì sửa lại chỗ này.

23. **Một ngày quán bán ĐÚNG MỘT BUỔI — buổi sáng — và quán KHÔNG có khái niệm "mở ca / đóng ca"**
    (chủ quán chốt 2026-09-04, trả lời `A1` và `A2`). Nguyên văn: *"quán chỉ bán buổi sáng"* và
    *"cứ đến giờ là bán rồi tối đếm tiền"*.
    - **Không có biến cố nào để bấm.** Không ai bấm *mở*, không ai bấm *đóng*. Cửa sổ giờ ở §1 —
      **06:00 – 11:00, tất cả các ngày** — là mốc duy nhất quán có, và nó là một hằng số trên đồng
      hồ chứ không phải một việc ai đó làm.
    - **Việc đếm tiền xảy ra BUỔI TỐI**, cách giờ bán nhiều tiếng. Khớp với §6.10, vốn đã viết
      *"mỗi tối đối chiếu"* — hai câu nói cùng một việc, không phải hai việc.
    - ⇒ **Mốc gom tiền là NGÀY BÁN, không phải một ca.** Định nghĩa *một ngày bán* cho phép cộng
      tiền là của pha 1 (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`); quy tắc này chỉ
      nói rằng ở quán **không có** một mốc vận hành nào nhỏ hơn nó. Xem `docs/decisions.md`
      **ADR-038**.
    - *Cách đọc, không phải lời chủ quán nói thẳng:* chủ quán nói *"chỉ bán buổi sáng"*; đọc cửa sổ
      **06:00–11:00** của §1 **chính là** một buổi ấy là **suy ra** — §7.2 **S-7**. Chủ quán nói
      khác đi thì sửa lại chỗ này.

24. **Thứ tự bưng do NGƯỜI ĐỨNG QUẦY quyết trên POS; luật cơ sở là ai tới trước ăn trước, và ưu
    tiên khách vội là ngoại lệ do người quyết từng ca** (chủ quán chốt 2026-09-04, trả lời `A5` và
    `A6`). Nguyên văn: *"pos quyết định. nhưng cơ bản là ai tới trước ăn trước"* và *"đôi khi ưu
    tiên cho khách vội"*.
    - **Máy KHÔNG tự xếp thứ tự bưng thay người.** Nó bày ra cái đang có; ai được bưng trước là
      quyết định của người đứng quầy. Cùng lối nghĩ với *"máy không gom, người gom"* (§5.4).
    - **Luật cơ sở là thời điểm khách tới**, không phải thời điểm món chín. Quy tắc này **không**
      mâu thuẫn với §5.4 (*bếp làm theo mẻ*): mẻ quyết **cái gì chín trước**, quy tắc này quyết
      **bưng cho ai trước**. Hai câu hỏi khác nhau, và chỉ câu thứ hai có ưu tiên của con người.
    - **Ngoại lệ có thật và có tên: khách vội.** Nó là *đôi khi*, không phải luôn — nên nó là một
      quyết định người, không phải một luật máy chạy được.
    - *Cách đọc, không phải lời chủ quán nói thẳng:* một lần ưu tiên là đúng hình dạng mà §6.22 và
      §6.4 đã gọi tên — *chỗ nào người quyết từng ca thay cho luật cứng, chỗ đó phải truy ngược
      được*. Áp luật để-lại-vết ấy cho lần đảo thứ tự bưng là **suy ra**, không phải lời chốt.
      Chủ quán chưa được hỏi câu này.

25. **Khách tự chọn bàn, và đôi khi nhân viên xếp chỗ — cả hai đều đúng; đông khách thì ngoài đời
    CÓ người đứng chờ và quán xếp hàng chờ** (chủ quán chốt 2026-09-04, trả lời `A8` và `A9`).
    Nguyên văn: *"cả 2 khách tự chọn đôi khi nhân viên xếp"* và *"có khách đứng chờ, xếp hàng
    chờ"*.
    - **Không có một luật xếp chỗ duy nhất để mã hoá.** Hệ thống phải chịu được cả hai đường, và
      không được bắt buộc một trong hai.
    - **Hàng chờ tồn tại ở ngoài đời.** Đây là dữ kiện, không phải một tính năng: chủ quán xác nhận
      có người đứng chờ và quán có xếp hàng.
    - **Máy KHÔNG giữ hàng chờ; người đứng quầy (POS) tự điều phối khách chờ khi cần** (chủ quán
      chốt 2026-09-06, trả lời `U-039`). Nguyên văn: *"không. pos sẽ điều phối khách nếu cần."*
      ⇒ *Khách chưa có bàn* **không** phải một khái niệm dữ liệu — không có phiên, không có hàng
      đợi nào sống trong hệ thống. §6.24 (*ai tới trước ăn trước*) vẫn chỉ áp cho khách **đã ngồi**
      bàn; người đứng quầy nhớ và xếp khách chờ hoàn toàn ngoài máy, như hôm nay.
    - **Mười một bàn ban đầu mỗi bàn 4 CHỖ NGỒI, và ĐÃ ĐÁNH SỐ sẵn** (chủ quán chốt 2026-09-06, trả
      lời `U-040`). Nguyên văn: *"11 bàn mỗi bàn 4 chỗ, đã đánh số."* ⇒ Vế mà **ADR-027** cần —
      *bàn gọi tên được từng cái* — coi như đủ cho **mười một** bàn ban đầu.
      - **Cùng câu, chủ quán báo một dữ kiện quán vừa đổi:** *"hôm nay tôi mua thêm bàn, hãy để 15
        bàn."* ⇒ §1 sửa **Số bàn: 11 → 15** (2026-09-06, chi tiết ở §1).
      - **Bốn bàn mới cũng 4 CHỖ NGỒI mỗi bàn** (chủ quán chốt 2026-09-08, trả lời vế thứ nhất của
        `U-042`). Nguyên văn: *"thêm 4 bàn mới mỗi bàn 4 chỗ."* ⇒ **cả mười lăm bàn đều 4 chỗ/bàn**,
        không còn hai loại bàn khác nhau về sức chứa.
        - *Phép nhân của người viết, không phải lời chủ quán:* 15 × 4 = **60 chỗ ngồi** (tính
          2026-09-08). Chủ quán chưa nói con số 60 lần nào — đếm lại, đừng trích nó như một lời
          chốt (`work/findings.md` **F-003**).
      - **Bốn bàn mới ĐÁNH SỐ NỐI TIẾP: 12 · 13 · 14 · 15** (chủ quán chốt **2026-09-16**, trả lời
        vế cuối của `U-042` — câu ấy nay **đóng**). Nguyên văn: *"trả lời nối tiếp 12–15"*.
        ⇒ Danh sách bàn của quán là **1…15**, mỗi cái gọi tên được bằng đúng số của nó — vế mà
        **ADR-027** cần (*chỉ ghép sang bàn trống*, nên phải gọi tên được **từng** bàn) nay **hết
        hở**, và `work/backlog_AD.md` **ADM-03** (danh sách bàn) cũng vậy.
        - *Chỗ lời chốt không nói, đừng đọc thêm* (`CLAUDE.md` §3.5): không lời nào nói bàn có
          **tên** nào ngoài số, không lời nào nói bốn bàn mới đặt ở khu nào, và không lời nào gắn
          thứ tự số với vị trí ngồi trong quán.

26. **Trả trước cho một đơn ĐẶT TRƯỚC giao/lấy vào một ngày SAU: doanh thu tính vào NGÀY GIAO/LẤY
    hàng, không phải ngày nhận tiền; và quán chỉ nhận đặt trước cho TỐI ĐA một ngày sau** (chủ quán
    chốt 2026-09-06, trả lời `U-036`). Nguyên văn: *"quán nhận đơn trước 1 ngày, doanh thu tính vào
    ngày đem hàng cho khách."*
    - **Đây là chiều NGƯỢC của luật nợ ở §6.14, và đối xứng với nó — đừng nhớ nhầm thành một.** Nợ
      là tiền về **sau** một lần bán **đã xong** (⇒ tính vào ngày bán); đây là tiền về **trước** một
      lần bán **chưa xong** (⇒ tính vào ngày bán, tức ngày giao/lấy). Cả hai đều lấy mốc theo
      **ngày việc bán thật sự xảy ra**, không theo ngày tiền đổi tay.
    - **Quán không nhận đặt trước xa hơn một hôm** — không có ca "trả trước hôm nay cho đơn ba ngày
      sau". Khoảng cách tối đa giữa ngày nhận tiền và ngày giao là **một** ngày.
    - ⇒ **Một khoản trả trước nhận hôm nay cho đơn giao ngày mai nằm trong két hôm nay nhưng KHÔNG
      vào doanh thu hôm nay.** Công thức đối soát §6.4 (`docs/product/1-system-design/architecture.md`)
      cần thêm một dòng cho khoản này, đối xứng với dòng *nợ ghi trong ngày* nhưng ngược chiều.
      Xem `docs/decisions.md` **ADR-040**.
27. **Sau khi nhập bù xong một ngày có bán trên sổ giấy: POS hoặc chủ quán ngồi lại chấm con số của
    ngày ấy, vào CUỐI BUỔI BÁN HÀNG** (chủ quán chốt 2026-09-06, trả lời `U-037`). Nguyên văn: *"pos
    hoặc chủ quán cuối buổi bán hàng."*
    - **Cùng người, cùng nhịp đã làm việc đối soát hằng ngày ở §6.10** — không phải một vai trò mới,
      không phải một mốc vận hành mới. Ngày còn `N > 0` lượt bán trên giấy chưa nhập là ngày chưa
      đối soát xong (**ADR-037**); khi `N` về 0 thì đúng buổi đối soát cuối ngày ấy (hoặc buổi hôm
      sau, nếu nhập bù xảy ra sau khi buổi hôm đó đã đóng sổ) là lúc con số được chấm lại.

## 7. Nhật ký chốt

**§7.2 luôn giữ ít nhất một chỗ suy ra chưa xác nhận, và mục này KHÔNG nói con số ấy là bao nhiêu**
— con số đúng đọc ở tiêu đề §7.2 rồi đếm lại ở bảng của nó (`work/findings.md` **F-003**: một phép
đếm của người viết không phải một quyết định, và một dòng chép lại nó ở đây là bản thứ hai sẽ trôi
— **F-001**).

Đường đi tới nay: bảng giá đã đầy, cả năm kênh đều có luồng, ba mục suy luận S-1–S-3 đã được chủ
quán trả lời thẳng ngày 2026-08-30 (§7.1, ba dòng đánh dấu *xác nhận S-*), và **S-4** — chỗ suy ra
sinh ngày 2026-08-31 từ lời chủ quán về cách bếp gom việc (§5.4) — đã được trả lời ngày
**2026-09-01**. Cùng ngày, lời chốt cho U-021 đẻ ra **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị
nào); ngày **2026-09-04**, lời chốt cho U-031 đẻ ra **S-6** theo đúng một kiểu — chủ quán trả lời
**ai bấm**, câu hỏi còn vế **bấm theo gì / bấm lúc nào**. Mục này giữ lại **ai chốt cái gì, ngày
nào**, để phiên sau muốn lật lại một quyết định thì biết đang lật lại điều gì.

### 7.1 Chủ quán đã chốt những gì

| Ngày | Chốt cái gì | Ghi ở |
|---|---|---|
| 2026-08-19 | Thành phần bếp làm ra của cả bốn suất bán | §4.5 |
| 2026-08-24 | Đơn hotline đi bằng kênh riêng, không gắn bàn | §2 |
| 2026-08-29 | Sửa: kênh đó tên `phone_preorder`, và **`staff_pos` không dùng cho đơn hotline** | §2 |
| 2026-08-29 | Suất giò = 9.000 + tiền 4 cái bánh; bánh trong suất giò **có** nhận nhân | §4.3 · §4.5 |
| 2026-08-30 | **Suất trứng = giá trứng + tiền 4 cái bánh**, cộng gộp thành phần như suất giò | §4.3 |
| 2026-08-30 | Thu tiền **lúc trao hàng** là đường mặc định, tiền mặt hoặc VietQR | §6.3 |
| 2026-08-30 | **Sửa cùng ngày:** đơn mang đi — cả ba kênh — khách **được chọn trả trước**; huỷ đơn đã trả trước ⇒ hoàn theo §6.4 | §6.3 · §6.4 |
| 2026-08-30 | **Quán tự đi giao**, đơn giao mang trạng thái "đang giao" | §6.7 |
| 2026-08-30 | Đơn web (`delivery`, `pickup`) **cần quầy duyệt** như đơn QR | §6.2 |
| 2026-08-30 | Đơn mang đi **vẫn có nước chấm**, gói riêng | §6.6 |
| 2026-08-30 | `phone_preorder` kết thúc **cả hai kiểu**; nhân viên hỏi khách khi nhận điện thoại | §5.2 |
| 2026-08-30 | **Hoàn tiền được phép**, quyết định từng ca ở quầy, không có luật cứng | §6.4 |
| 2026-08-30 | Thông tin liên hệ: quầy cung cấp theo tình huống thật, có trường bắt buộc | §6.5 |
| 2026-08-30 | **Phân trạm**: quầy · tráng bánh · gấp bánh là ba trạm riêng; `canh` + `don_ban` chung một người | §3 |
| 2026-08-30 | **Chủ quán thỉnh thoảng đứng quầy** — làm việc của trạm `quay`, vẫn giữ vai chủ quán | §3 |
| 2026-08-30 | Đơn hotline mà khách tới ăn tại quán ⇒ **huỷ**, khách gọi lại bằng `qr_table` | §2 |
| 2026-08-30 | *(xác nhận S-1)* Quả trứng **lên giá theo nhân** ⇒ phụ thu suất trứng **×5**, suất trứng nhân thường = **25.000** | §4.3 · §4.6 |
| 2026-08-30 | *(xác nhận S-2)* Số điện thoại và địa chỉ giao **đúng là hai trường bắt buộc** | §6.5 |
| 2026-08-30 | *(xác nhận S-3)* **Người đứng quầy** là người quyết định và ghi vết mỗi lần hoàn tiền | §6.4 |
| 2026-08-30 | **Chỉ người đứng quầy được huỷ đơn**, bấm trên máy POS ở quầy | §6.13 |
| 2026-08-30 | Quyền huỷ gắn **chỗ đứng, không gắn chức vụ**: chủ quán không đứng quầy thì **nhờ người đứng quầy bấm** | §6.13 |
| 2026-08-31 | **Năng lực bếp**: 2 nồi tráng bánh, mỗi nồi 3 quả trứng ⇒ **6 quả một mẻ** | §5.4 |
| 2026-08-31 | Bếp **làm theo mẻ**, không làm lần lượt từng suất — làm lẻ thì mất thời gian và mất nhiệt | §5.4 |
| 2026-08-31 | **Đơn trả trước** trả bằng đúng hai phương thức đang có (tiền mặt / VietQR), và **POS xác nhận vào lúc nhận tiền** — đóng U-005 | §6.3 |
| 2026-08-31 | **Ghép bàn là chuyện có thật ở quán** | §6.16 |
| 2026-08-31 | **Ghép bàn ⇒ MỘT phiên, MỘT hoá đơn** — một phiên gắn được nhiều bàn; "một bàn một phiên" đọc lại thành "một bàn thuộc nhiều nhất một phiên" — đóng U-006 | §6.16 |
| 2026-08-31 | **Khách không trả được thì CHO NỢ**; đóng phiên trên POS phải ghi **ai nợ, nợ bao nhiêu** — đóng U-007 | §6.14 |
| 2026-08-31 | **Năng lực một nồi, một lần tráng**: 3 trứng **hoặc** 2 bánh **hoặc** 1 trứng + 1 bánh ⇒ trứng và bánh **tranh nhau cùng một nồi** — đóng U-008 | §5.4 |
| 2026-08-31 | **Bỏ nút bấm ở trạm bếp**: không ai bấm "đã làm xong" / "đã bưng ra bàn"; **POS tự cập nhật** số đã làm cho từng bàn — đóng U-009 | §5.4 |
| 2026-08-31 | **Đơn mang đi KHÔNG chung bảng gom việc với bàn**; nhưng khách **đang ngồi bàn** gọi suất đem về thì suất ấy thuộc **phiên bàn**, kèm note "đem về" — đóng U-010 | §5.4 · §6.15 |
| 2026-08-31 | **Máy không gom, người gom**: hệ thống chỉ hiện tổng nhu cầu, không tự chia mẻ / xếp nồi / quyết thứ tự — đóng U-011 | §5.4 |
| 2026-08-31 | Người đứng quầy phải nhìn được cùng lúc (đếm được sáu, tính tới ngày này): tổng còn phải làm theo thành phần · chia cho bàn nào · bàn đang ăn / đang chờ · mỗi bàn đã phục vụ bao nhiêu · mỗi bàn còn thiếu gì · quán hiện đang thế nào | §5.4 |
| 2026-08-31 | **Người đứng quầy bấm ghép bàn trên POS**; **chỉ ghép được khi bàn kia còn trống** (trả lời U-013) | §6.16 |
| 2026-08-31 | **POS ghi nhận khi người nợ quay lại trả**; doanh thu tính vào **ngày ghi nợ**, không phải ngày trả (trả lời U-012) | §6.14 |
| 2026-09-01 | **Sửa giá được ngay giữa giờ bán** — không phải chờ hết buổi (trả lời U-014) | §6.17 |
| 2026-09-01 | **Lượt gọi trước mốc giữ giá cũ, lượt gọi sau mốc áp giá mới** ⇒ một hoá đơn được phép mang **hai mức giá**, chủ quán chấp nhận (trả lời U-015) | §6.17 |
| 2026-09-01 | **Đổi THÀNH PHẦN một suất bán thì phải chờ hết buổi bán** — khác hẳn ba chiều tiền (trả lời U-016) | §4.5 · §6.17 |
| 2026-09-01 | *(trả lời S-4, vế 1)* Bánh gấp xong **CÓ nằm chờ** trước khi ra bàn — chờ đủ đĩa · chờ người rảnh tay bưng · chờ món khác của cùng bàn ⇒ *làm xong* và *ra bàn* là **hai** việc, bảng quầy có **bốn** con số | §5.4 |
| 2026-09-01 | *(trả lời S-4, vế 2)* **Người đứng quầy bấm** nút "đã làm xong" trên POS — ba trạm bếp vẫn không bấm gì (U-009 nguyên vẹn) | §5.4 |
| 2026-09-01 | **Bấm "đã làm xong" theo MẺ** — không theo từng cái, không theo cả bàn (trả lời U-017) | §5.4 |
| 2026-09-01 | **Máy chỉ NHẮC một câu, không chặn**, khi chủ quán sửa thành phần suất giữa giờ bán ⇒ luật "chờ hết buổi" là luật cho **người** (trả lời U-018) | §6.17 |
| 2026-09-01 | **POS bấm cả con số "đã bưng ra bàn"** — cùng chỗ đứng đã bấm *"đã làm xong"*; ba trạm bếp vẫn không bấm gì (trả lời U-021) | §5.4 |
| 2026-09-01 | **Bấm nhầm một mẻ thì LÙI ĐƯỢC**, và **không có mốc thời gian cứng** — người đứng quầy quyết từng ca (trả lời U-024) | §5.4 |
| 2026-09-01 | **Đơn đã xác nhận thì SỬA được, sửa trên POS** — không phải huỷ rồi tạo lại; vế *sửa/huỷ được tới trạng thái nào* **chưa** trả lời (trả lời một nửa U-022) | §6.19 |
| 2026-09-01 | **POS bấm mốc đơn giao tận nơi VÀO trạng thái "đang giao"** — mốc ra vẫn do người đi giao bấm (trả lời U-023) | §6.7 |
| 2026-09-01 | **Đối soát cuối ngày có NGUỒN THỨ BA: tin nhắn báo có** — phần khách chuyển khoản đối chiếu bằng tin nhắn, vì két chỉ giữ tiền mặt (trả lời U-019) | §6.10 |
| 2026-09-01 | **Hoàn tiền tính vào doanh thu NGÀY HOÀN**, không phải ngày bán gốc — ngược chiều với luật nợ ở §6.14 (trả lời U-019) | §6.4 |
| 2026-09-01 | **Một lần thu chia được nhiều phương thức**; POS ghi **bao nhiêu tiền mặt, bao nhiêu chuyển khoản** (trả lời U-020) | §6.18 |
| 2026-09-02 | **Sửa sai bằng CẬP NHẬT, không hoàn tác; mỗi lần giữ bản trước, bản sau, lý do, người sửa** — *"để đối chiếu"* (xác nhận GĐ-01 và GĐ-05, kèm yêu cầu mới) | §6.22 |
| 2026-09-02 | **Dòng vừa sửa lấy GIÁ ĐANG HIỆU LỰC LÚC SỬA** — sửa một dòng là đặt lại mốc khoá giá của dòng ấy; ngoại lệ có chủ ý của §6.17 (trả lời U-026) | §6.19 |
| 2026-09-02 | **Đơn đã `Hoàn thành` cũng HUỶ được, POS quyết trong thực tế** (trả lời U-027) — cùng luật với *sửa*: không mốc trạng thái nào chặn | §6.19 |
| 2026-09-02 | **Không mảng quản trị nào phải chạy cùng bản bán hàng đầu tiên** — *"bán hàng xong chạy được thì để chạy trước"* (trả lời U-030) | — *phạm vi MVP, không phải dữ kiện quán; ghi ở `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7* |
| 2026-09-02 | **Sửa đơn được ở BẤT KỲ trạng thái nào**, POS quyết theo tình hình thực tế — không có mốc trạng thái cứng (trả lời nốt U-022; vế *huỷ* **không** được chạm tới, thành U-026) | §6.19 |
| 2026-09-02 | **Sổ giấy: POS hoặc chủ quán giữ và nhập lại, nhập ngay khi có thể** — có điện lại giữa buổi thì làm tiếp trên hệ thống, ghi tay cập nhật sau (trả lời U-025) | §6.11 |
| 2026-09-02 | **Món hết sau khi khách đã chọn: POS bàn với khách, quyết tại lúc thoả thuận xong** — không tự thay thế, không tự huỷ (đóng câu 3 bảng §10) | §6.20 |
| 2026-09-02 | **Khách nói đã chuyển khoản mà chưa thấy báo có: POS bàn với khách, quyết ngay lúc đó** — hai đường ra là ghi nợ (§6.14) hoặc chờ tin nhắn (§6.3) | §6.21 |
| 2026-09-01 | **Ba mảng quản trị vào phạm vi phần mềm**: nguyên liệu · con người · tài chính — lật ngược ranh giới cũ *"không quản lý nguyên liệu, tồn kho, chấm công, kế toán"*; chủ quán **xác nhận lại 2026-09-02** | **§8** |
| 2026-09-04 | **Lượt bán ghi trên giấy tính doanh thu vào NGÀY QUÁN BÁN**, không phải ngày gõ vào máy (trả lời **U-032**) — ⇒ doanh thu một ngày **đã đối soát** có đổi về sau, đúng một ca; xem ADR-037 | §6.11 |
| 2026-09-04 | **Mất mạng mà hệ thống vẫn sống ⇒ WEB NGỪNG NHẬN ĐƠN**, có một dòng thông báo; khách đặt qua **hotline**, quán **ghi giấy trực tiếp với POS** (trả lời **U-035**) — điều kiện thứ ba của I-008 | §6.11 |
| 2026-09-04 | **Đơn GIAO TẬN NƠI không có ngoại lệ: POS vẫn bấm mốc *"đã ra bàn"* của từng việc trạm** — nguyên văn *"pos"*; người đi giao vẫn chỉ giữ *đã giao* + *đã thu tiền* (trả lời **U-031**). *Vế **lúc nào** bấm thì chưa nói ⇒ **S-6** ở §7.2* | §5.4 · §6.7 |
| 2026-09-04 | **Mảng nguyên liệu làm ở mức SỔ GHI TAY ĐIỆN TỬ** — máy **không** tự trừ tồn theo công thức, nên phần mềm không cần định lượng từng thành phần; kèm **một mục tổng nhập hàng ngày, chủ quán tự nhập số liệu** | **§8.4** |
| 2026-09-04 | **Một ngày bán ĐÚNG MỘT BUỔI — buổi sáng — và quán KHÔNG có mở ca / đóng ca**: *"cứ đến giờ là bán rồi tối đếm tiền"* (trả lời `A1` `A2`) ⇒ không có mốc vận hành nào nhỏ hơn **ngày bán**; xem **ADR-038**. *Vế cửa sổ 06:00–11:00 của §1 **chính là** một buổi ấy là suy ra ⇒ **S-7** ở §7.2* | §6.23 |
| 2026-09-04 | **Thứ tự bưng do POS quyết, luật cơ sở là ai tới trước ăn trước, ưu tiên khách vội là ngoại lệ *đôi khi*** (trả lời `A5` `A6`) — máy **không** xếp thứ tự thay người; không mâu thuẫn §5.4 vì mẻ quyết *cái gì chín trước*, luật này quyết *bưng cho ai trước* | §6.24 |
| 2026-09-04 | **Tiền đầu két có thật: chủ quán bỏ tiền lẻ cho POS lấy tiền thối, máy giữ một số mặc định SỬA ĐƯỢC; giữa buổi KHÔNG ai lấy tiền ra** (trả lời `A3` `A4`) ⇒ vế còn thiếu của đối soát 0đ §6.10, và là **I-021**. Cộng **mục tổng quan của chủ quán** — sáu con số (trả lời `A10`) | **§8.5** · **§8.6** · §6.25 |
| 2026-09-06 | **Đơn HUỶ sau khi bếp làm xong: phần đã làm chuyển cho bàn khác đang chờ, POS chọn và cập nhật** (trả lời **U-033**) — nguyên văn *"tính vào bàn khác, pos sẽ cập nhật bánh này đem ra cho bàn nào"* | §5.4 |
| 2026-09-06 | **Mục tổng hàng ngày ghi HAI con số — mua vào và đã dùng — để biết thừa/thiếu** (trả lời **U-034**) — nguyên văn *"đồ mua trong ngày và đồ dùng trong ngày để tôi biết còn thừa thiếu bao nhiêu"* | §8.4 |
| 2026-09-06 | **Trả trước cho đơn giao ngày SAU: doanh thu tính ngày GIAO, nhận trước tối đa MỘT ngày** (trả lời **U-036**) — nguyên văn *"quán nhận đơn trước 1 ngày, doanh thu tính vào ngày đem hàng cho khách"*; xem **ADR-040** | §6.26 |
| 2026-09-06 | **Sau khi nhập bù xong: POS hoặc chủ quán chấm lại con số vào CUỐI BUỔI BÁN HÀNG** (trả lời **U-037**) — nguyên văn *"pos hoặc chủ quán cuối buổi bán hàng"* | §6.27 |
| 2026-09-06 | **Tiền đầu két nhập CẢ HAI: bảng theo từng mệnh giá VÀ tổng cộng** (trả lời **U-038**) — nguyên văn *"tổng của từng mệnh giá và tổng của tất cả các mệnh giá cộng lại với nhau"* | §8.5 |
| 2026-09-06 | **Máy KHÔNG giữ hàng chờ bàn; POS tự điều phối khi cần** (trả lời **U-039**) — nguyên văn *"không. pos sẽ điều phối khách nếu cần"* | §6.25 |
| 2026-09-06 | **Mười một bàn ban đầu: 4 chỗ/bàn, đã đánh số; quán vừa mua thêm bàn ⇒ Số bàn 11 → 15** (trả lời **U-040**) — nguyên văn *"11 bàn mỗi bàn 4 chỗ, đã đánh số, hôm nay tôi mua thêm bàn, hãy để 15 bàn"*. *Chỗ ngồi/đánh số của 4 bàn mới **chưa** trả lời ⇒ **U-042*** | §1 · §6.25 |
| 2026-09-06 | **Danh mục nguyên liệu bắt đầu có TÊN — mười bốn thứ đầu tiên, còn bổ sung dần** (chủ quán tự liệt kê, không trả lời riêng một U-XXX nào) — nguyên văn *"nhân thịt, nhân thịt mộc nhĩ, rau mùi tàu, quất, hành tây, mì chính, hạt nêm, đường trắng, đường đen, gạo, bột bánh cuốn, hạt tiêu, nước mắm, dầu rửa bát"*; đơn vị tính và ngưỡng nhắc sắp hết vẫn chưa có | §8.4 |
| 2026-09-07 | **Đặt tên chủ cho hai phụ thuộc PT-5/PT-2: đường báo đơn web về quầy là Telegram, hạ tầng vận hành là một VPS duy nhất** (chốt bởi chủ repo, không phải một câu hỏi U-XXX — đóng một phần **F-027**) — xem **ADR-041** | §1 |
| 2026-09-08 | **Bốn bàn mới cũng 4 chỗ/bàn ⇒ cả 15 bàn đều 4 chỗ** (trả lời vế **chỗ ngồi** của **U-042**) — nguyên văn *"thêm 4 bàn mới mỗi bàn 4 chỗ"*. *Vế **cách đánh số** bốn bàn mới **vẫn chưa** trả lời ⇒ **U-042** ở lại, hẹp hơn* | §1 · §6.25 |
| 2026-09-08 | **Vế *"còn thiếu gì không"* của mục tổng quan là thiếu NGUYÊN LIỆU, và tập nguyên liệu là Danh mục §8.4** (trả lời **U-041**) — nguyên văn *"về nguyên liệu hãy tham khảo «Danh mục nguyên liệu» tại `master_plan/shop-facts.md`"*. *Máy biết một nguyên liệu đang thiếu **bằng cách nào** thì lời ấy không nói — danh mục mới có tên, chưa có đơn vị và ngưỡng ⇒ **U-045*** | **§8.6** · §8.4 |
| 2026-09-08 | **Menu có tên từng món, và vế *"còn thiếu gì"* chạm nốt hai đường còn lại** (bổ sung cho **U-041**, cùng ngày, lượt sau) — nguyên văn *"đối với nguyên liệu và con người đã có. đối với menu: tôi muốn có suất đầy đủ trứng tai, đầy đủ trứng chín, đầy đủ trứng vàng, suất giò, suất trứng chín, suất trứng tái, suất trứng vàng. bánh cuốn khách sẽ lựa chọn ăn bao nhiêu cái thì tuỳ. giò: khách có thể gọi bao nhiêu cũng được. canh bánh cuốn."* Bảy tên đầu khớp §4.3; **giò bán rời** và **canh bánh cuốn** thì §4 chưa từng có ⇒ **U-046** · **U-047**. *Việc mục tổng quan bày cả ba đường là suy ra ⇒ **S-8** ở §7.2* | **§4.9** · §8.6 |
| 2026-09-08 | **Số thành phần TRONG một suất là HẰNG SỐ; "bao nhiêu cũng được" là số lượng món bán rời** (đóng **U-047**) — nguyên văn *"đó là SỐ LƯỢNG khách gọi món bán rời. số bánh / số giò TRONG MỘT SUẤT là không đổi"* ⇒ suất giò 4 bánh · suất trứng 4 bánh · combo 3 bánh đứng nguyên, và **giò bán rời** thành một dòng menu. *Giá 9.000 của dòng ấy là hệ quả tính từ luật 1 §4.6, chủ quán chưa đọc thành lời ⇒ **S-9*** | §4.3 · §4.5 · §4.9 |
| 2026-09-08 | **Canh bánh cuốn: bưng kèm sẵn, KHÔNG tính tiền, nhưng vẫn phải là một dòng menu khách chọn SỐ LƯỢNG** (đóng **U-046**) — nguyên văn *"canh bánh cuốn bưng kèm sẵn không tính tiền nhưng cần có trong menu để khách chọn vì đôi khi 1 suất đầy đủ khách muốn có 2 bát canh, 1 bát cho con và 1 bát cho mẹ"* ⇒ dòng menu **0đ có số lượng**, và việc trạm `canh` hết suy ra được từ số suất (§5.3). *Kèm sẵn mấy bát, và con số khách chọn là tổng hay phần thêm ⇒ **U-048*** | §4.2 · §4.3 · §4.5 · §5.3 |
| 2026-09-08 | **KHÔNG suất nào bưng kèm canh; số bát bếp bưng đúng bằng lựa chọn của khách** (đóng **U-048**, mở cùng ngày) — nguyên văn *"mỗi suất bếp sẽ không bưng kèm theo canh. bếp bưng canh như nào dựa vào lựa chọn thực tế của khách"* ⇒ phần kèm sẵn là **0 bát**, nên con số ở dòng *canh bánh cuốn* là **TỔNG số bát**, không phải phần thêm; không chọn ⇒ **0 bát** và đơn ấy không có việc *canh* nào xuống bếp. Chữ *"bưng kèm sẵn"* của lời chốt `U-046` cùng ngày vì thế chỉ còn nghĩa **không tính tiền** — ô 0đ §4.2 · §4.3 đứng nguyên | §4.2 · §4.5 · §4.9 · §5.3 |
| 2026-09-08 | **Người ĐI GIAO là một trong BỐN VAI của §3, không phải người thứ năm — và POS chỉ định ai đi từng lần** (đóng **U-049**) — nguyên văn *"1 trong bốn vai trên có thể là bất cứ ai pos sẽ chỉ định."* ⇒ con số người của quán đóng lại ở **bốn vai + chủ quán**; *đi giao* không thành trạm thứ sáu, không thêm dòng nào vào bảng ca/bảng lương. *Lúc người ấy rời quán thì **trạm của họ ai gánh** — lời chốt không nói ⇒ **U-050*** | **§3** · §6.7 · §8.6 |
| 2026-09-08 | **Hoàn tiền trả lại bằng gì cũng không có luật cứng — POS quyết từng ca** (đóng **U-044**) — nguyên văn *"tuỳ vào tình hình thực tế, pos quyết định"* ⇒ khách đã chuyển khoản có thể được hoàn bằng **tiền mặt lấy trong két** hoặc **chuyển khoản lại**, và ngược lại. *Vết hoàn tiền phải ghi thêm **phương thức trả lại** là suy ra từ §6.10, không phải lời chủ quán*; hệ quả cho phép trừ tiền két: **I-021** viết lại, **ADR-046** | **§6.4** · §8.5 |
| 2026-09-15 | **Lúc một vai rời quán đi giao, NGƯỜI ĐỨNG QUẦY (POS) gánh trạm của người ấy — và khoảng trống ấy KHÔNG là thiếu người** (đóng **U-050**) — nguyên văn *"pos gánh, không thiếu người vì đi ship luc quán vắng."* ⇒ ba trạm riêng có **một** ngoại lệ: `quay` kiêm trạm bị bỏ trống trong lúc có người đi giao; khoảng trống ấy không tính vào số 7 của §8.6 — *"lúc quán vắng"* là lý do, không phải luật cấm giao lúc đông. *Khi chính người đứng quầy đi giao thì ai gánh `quay` — lời chốt va lời `U-049` (*"bất cứ ai"*) ⇒ **U-052*** | **§3** · §8.6 |
| 2026-09-15 | **KHÔNG có ngưỡng nhắc sắp hết: chủ quán tự đọc hai con số mua vào · đã dùng rồi tự kết luận thiếu hay đủ** (đóng **U-045**) — nguyên văn *"chủ quán tự đọc rôi đưa ra kết luận"* ⇒ máy không kết luận, không nhắc; danh mục §8.4 không mọc cột *ngưỡng*; §8.4 đứng nguyên ở mức sổ ghi tay điện tử. *Mục tổng quan bày gì cho vế nguyên liệu thì lời ấy không nói ⇒ **U-051**; đơn vị tính vẫn ở câu **B12*** | **§8.4** · §8.6 |
| 2026-09-16 | **Bốn bàn mới đánh số NỐI TIẾP 12 · 13 · 14 · 15 ⇒ danh sách bàn là 1…15** (đóng **U-042**, vế cuối) — nguyên văn *"trả lời nối tiếp 12–15"*. ⇒ mọi bàn gọi tên được bằng đúng số của nó: vế **ADR-027** cần (*chỉ ghép sang bàn trống*) và `work/backlog_AD.md` **ADM-03** hết hở. *Không lời nào nói bàn có tên ngoài số, cũng không lời nào gắn số với vị trí ngồi* | **§1** · §6.25 |
| 2026-09-16 | **Web ngừng nhận đơn KHÔNG do đồng hồ: máy BÁO, POS QUYẾT, mở lại bằng NÚT** (đóng **U-043**) — nguyên văn *"hiên thông báo để pos quyết định nếu dừng cần có nut mở lại"* ⇒ không có con số cửa sổ nào; hệ thống hiện thông báo ở quầy, POS quyết dừng ba kênh khách tự bấm, và đã dừng thì không tự mở lại. ⇒ lật luật 1 của `docs/product/1-system-design/05-realtime-va-du-phong.md` §3 và một câu *Verification* của **I-008** (**ADR-047**). *Ca quán mất mạng hẳn — POS không bấm được gì — lời chốt không phủ ⇒ **U-053*** | **§6.11** · `quality/invariants.md` **I-008** |
| 2026-09-16 | **Mục tổng quan bày THỜI GIAN NHẬP · TỔNG ĐÃ DÙNG · SỐ THIẾU do máy trừ** (đóng **U-051**) — nguyên văn *"thời gian nhâp sản phẩm và tổng đã sử dụng lấy thiếu bằng tổng đã nhập trừ đi sử dụng"* ⇒ *thiếu = tổng đã nhập − tổng đã dùng*; máy **cộng dồn hộ** nhưng vẫn không có ngưỡng và không kết luận (`U-045` đứng nguyên), §8.4 vẫn ở mức sổ ghi tay điện tử. *Hai con số **tổng** cộng dồn từ mốc nào thì lời ấy không nói ⇒ **U-054*** | **§8.4** · §8.6 (hàng 7) |
| 2026-09-16 | **NGƯỜI ĐỨNG QUẦY KHÔNG BAO GIỜ ĐI GIAO** (đóng **U-052**) — nguyên văn *"người đứng quầy khônng đi giao"* ⇒ chữ *"bất cứ ai"* của `U-049` hẹp lại còn **ba** vai (`trang_banh` · `gap_banh` · `canh`+`don_ban`); trạm `quay` không bao giờ bỏ trống vì đi giao, nên lời *"pos gánh"* của `U-050` luôn có người gánh. *Lời này không đụng tới chủ quán — §3 vẫn để chủ quán thỉnh thoảng đứng quầy* | **§3** · §8.6 |
| 2026-09-20 | **Mảng CON NGƯỜI làm tới CẢ BA MỨC: ai đang trực trạm nào · chấm công · tính lương trên máy** (xác nhận lại lời chốt **Đ-4** ngày 2026-09-01; việc đi hỏi: `work/backlog_AD.md` **ADM-53**) — chủ quán chọn *"Đúng, cả ba mức"*. *Lời này chốt **mức sâu**, không chốt một con số nào: đơn giá công, kỳ trả lương, quyền xem lương vẫn là các câu `C23`…`C35` ở `work/admin-questions.md` §3* | **§8.7** |
| 2026-09-20 | **Mỗi lần ĐỔI NGƯỜI Ở QUẦY là một mốc CÓ GIỜ — ghi cả ai vào, ai ra** (trả lời câu `C36`; hỏi qua `work/backlog_AD.md` **ADM-53**, chuyển về owner qua **ADM-21**, cùng ngày) — nguyên văn *"Có — ghi cả mốc đổi, ai vào ai ra lúc mấy giờ"* ⇒ đơn nào, huỷ nào, hoàn tiền nào cũng truy ra được người đang đứng quầy lúc ấy. Đây là dữ kiện **đầu tiên** đỡ được luật quyền gắn **chỗ đứng** của §6.13 và **ADR-016**. *Lời này phủ **trạm `quay`**, không phủ bốn trạm còn lại ⇒ **U-055**; không nói **ai khai** cái mốc ⇒ **U-056**; không phủ hai cửa ghi ngoài quầy (§6.7 · §6.17) ⇒ **U-057*** | **§8.8** · §8.7 (mức 1) |

### 7.2 Chỗ suy ra chưa xác nhận — **năm mục, tính tới 2026-09-08**

Mục này giữ những chỗ được **suy ra** từ luật đã chốt chứ không phải lời chủ quán nói thẳng. Bốn
mục S-1–S-4 từng nằm đây đều đã được chủ quán xác nhận và đã lên §7.1; còn **bốn** mục chưa xác
nhận — **S-5** (2026-09-01, T-039) · **S-6** (2026-09-04, T-055) · **S-7** (2026-09-04, T-056) ·
**S-8** (2026-09-08, T-068) · **S-9** (2026-09-08, T-069).

S-5 và S-6 sinh ra cùng một kiểu: chủ quán trả lời **ai bấm**, và câu hỏi còn một vế **bấm theo gì
/ bấm lúc nào** mà lời ấy không chạm tới. **S-7 là kiểu thứ hai**: chủ quán trả lời về **cả ngày**
(*"chỉ bán buổi sáng"*), và chỗ suy ra là việc đọc câu ấy thành một mệnh đề về **một buổi**.
**S-8 là kiểu thứ ba**: chủ quán trả lời **từng vế của câu hỏi theo thứ tự câu hỏi đưa ra**, và
chỗ suy ra là việc đọc trật tự ấy thành một mệnh đề *cả ba vế cùng nằm trong một chỗ*. **S-9 là
kiểu thứ tư, và là kiểu nguy hiểm nhất vì nó ra một CON SỐ TIỀN**: luật tính giá đã chốt cho ra
đúng một đáp số, nên đáp số ấy trông như một fact — nhưng chủ quán chưa từng đọc nó. **S-1** ngày
2026-08-30 là cùng kiểu, và hỏi ra thì đúng; điều đó không làm kiểu này an toàn, nó chỉ cho thấy
hỏi là rẻ.

⚠️ Con số *ba* ở tiêu đề là **phép đếm của phiên, không phải một quyết định** — đếm lại ở bảng dưới
chứ đừng tin câu này (`work/findings.md` **F-003** · **F-018**).

| Chỗ suy ra | Hỏi ngày | Lời giải | Nay ở |
|---|---|---|---|
| **S-1** — phụ thu suất trứng ×5 hay ×4 | 2026-08-30 | **×5**, suất trứng nhân thường = 25.000 | §4.3 · §4.6 |
| **S-2** — hai trường liên hệ bắt buộc | 2026-08-30 | **đúng**, số điện thoại và địa chỉ giao | §6.5 |
| **S-3** — hoàn tiền phải ghi vết, ai ghi | 2026-08-30 | **người đứng quầy** vừa quyết vừa ghi | §6.4 |
| **S-4** — *"đã làm xong, còn ở bếp"* có phải một con số riêng | 2026-08-31 (hỏng) → **2026-09-01** | **có** — bánh nằm chờ thật; bảng quầy **bốn** con số, **người đứng quầy bấm** | §5.4 |
| **S-5** — *"đã bưng ra bàn"* bấm theo **đơn vị nào** | **2026-09-01**, chưa hỏi | *suy ra:* theo **bàn**, không theo mẻ — một mẻ phục vụ nhiều bàn (§5.4), còn bưng thì bưng tới **một** bàn. Chủ quán mới chỉ nói **ai** bấm, chưa nói **theo gì** | §5.4 · **BA-12** cần trước khi dựng bảng quầy |
| **S-6** — với đơn **giao tận nơi**, quầy bấm *"đã ra bàn"* **lúc nào** | **2026-09-04**, chưa hỏi | *suy ra:* **lúc đơn rời quán** — cùng mốc quầy đã bấm để đưa đơn sang `Đang giao` (§6.7, chốt 2026-09-01 trả lời U-023), vì quầy chỉ nhìn thấy suất ấy tới lúc đó. Chủ quán 2026-09-04 mới chỉ nói **ai** bấm (*"pos"*, U-031), chưa nói **lúc nào**. ⇒ Nếu suy ra này sai thì mốc *"đã ra bàn"* của đơn giao nghĩa là **tới tay khách**, và quầy phải chờ người đi giao báo về mới bấm được | §5.4 · §6.7 · `docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2 |
| **S-7** — cửa sổ **06:00–11:00** của §1 có phải **đúng một buổi bán** | **2026-09-04**, chưa hỏi | *suy ra:* **có** — chủ quán nói *"quán chỉ bán buổi sáng"* (`A1`) và *"cứ đến giờ là bán"* (`A2`), nên cửa sổ giờ duy nhất quán có cũng là buổi duy nhất quán bán. Chủ quán **không** đọc ra một mốc bắt đầu và một mốc kết thúc của *buổi*; hai câu ấy nói về **cả ngày** chứ không nói về một buổi trong nhiều buổi. ⇒ Nếu suy ra này sai thì có buổi thứ hai ngoài 06:00–11:00, và §6.23 · **ADR-038** · **I-021** đều phải viết lại | §1 · §6.23 · **ADR-038** |
| **S-8** — mục tổng quan §8.6 có bày **cả ba** đường của vế *"còn thiếu gì"* (nguyên liệu · người · món) không | **2026-09-08**, chưa hỏi | *suy ra:* **có** — chủ quán trả lời đúng ba vế câu hỏi đã đưa ra, theo thứ tự ấy (*"nguyên liệu và con người đã có, đối với menu…"*), nên ba vế được đọc là ba thứ mục tổng quan bày. Chủ quán **không** nói thẳng *"mục tổng quan hiện cả ba"*, và chữ *"đã có"* cũng có thể chỉ nghĩa là *hai thứ ấy hệ thống ghi ở đâu đó rồi*. ⇒ Nếu suy ra này sai thì §8.6 hàng 7 chỉ còn **một** đường (nguyên liệu), và §4.9 vẫn đứng nguyên vì nó là **menu**, không phải một dòng của mục tổng quan | §8.6 · §4.9 |
| **S-9** — giá một chiếc **giò bán rời** có đúng bằng **9.000** không | **2026-09-08**, chưa hỏi | *suy ra:* **có** — luật 1 §4.6 nói giá một suất là **tổng giá các thành phần**, dòng *giò bán rời* gồm đúng một chiếc giò, và §4.2 định giá chiếc giò là 9.000 cho cả ba cột (giò không nhận nhân). Chủ quán 2026-09-08 chốt giò là **món bán rời khách gọi bao nhiêu cũng được**, nhưng **không** đọc ra giá của nó. ⇒ Nếu suy ra này sai — quán bán lẻ một chiếc giò đắt hơn giá nó đứng trong suất — thì ba ô ⚠ ở §4.3 sai, ca **12** của §4.8 sai, và luật 1 §4.6 có ngoại lệ đầu tiên kể từ khi được viết | §4.3 · §4.2 · §4.8 ca 12 |

Mục này **không xoá** kể cả khi rỗng: chỗ suy ra tiếp theo phải nằm ở đây, tách khỏi §7.1
(`work/findings.md` F-004). Thấy dòng nào trong repo còn nói *"§7.2 rỗng"* ⇒ đó là pointer cũ, sửa
đi — nó đúng trong khoảng từ lúc S-4 có lời giải tới lúc S-5 mở ra, cùng ngày **2026-09-01**.

**S-4 phải hỏi hai lần, và lần đầu hỏng — bài học ở lại đây kể cả khi câu hỏi đã đóng.** Ngày
2026-08-31 câu hỏi là: *"Bếp đã tráng xong 6 cái bánh của bàn 5 nhưng mới bưng ra 3 cái. Bảng ở
quầy lúc đó hiện bàn 5 còn thiếu 3 hay đã đủ?"* — chủ quán trả lời **"tôi không hiểu"**. Câu ấy
bắt người biết rõ cái quán đi trả lời một câu về **mô hình dữ liệu**. Ngày 2026-09-01 hỏi lại về
**cái quán** — *"từ lúc bếp tráng xong một cái bánh đến lúc nó đặt xuống bàn khách, có khi nào nó
phải nằm chờ không?"* — chủ quán trả lời ngay, và còn tự kể ra ba lý do nằm chờ mà không ai gợi ý.

⇒ **Hỏi về cái quán thì được trả lời; hỏi về cái bảng trong máy thì không.** Đó là luật cho mọi
câu kiểm chứng viết sau này, không phải một mẩu chuyện riêng của S-4 (`docs/decisions.md` ADR-009,
`work/findings.md` F-004).

**Câu thứ hai của S-4 lại là một câu về máy — và lần này trả lời được**, vì lúc hỏi nó, cái quán
đã có sẵn câu trả lời cho vế nghiệp vụ: *"anh đã bỏ nút bấm ở bếp rồi, vậy ai nói cho máy biết món
đã xong?"* Câu hỏi về máy **đứng được** khi nó hỏi *ai làm việc đó ở quán*, chứ không hỏi *bảng
nên hiện con số nào*.

### 7.3 Quy tắc cho phiên sau

Khi chủ quán chốt thêm điều gì: ghi vào đúng mục nghiệp vụ (§1–§6) **trước**, rồi thêm một dòng vào
bảng §7.1 với ngày. Đừng để một quyết định chỉ sống ở §7 — mục này là nhật ký, không phải nơi tra
cứu quy tắc.

**Chốt về mảng QUẢN TRỊ (admin) thì mục nghiệp vụ của nó là §8, không phải §1–§6.** §1–§6 nói về
việc **bán hàng**; nguyên liệu, con người và tài chính là mảng khác và có mục riêng. Dòng nhật ký
vẫn vào §7.1 như mọi lời chốt khác, cột *Ghi ở* trỏ §8. Trộn dữ kiện admin vào §1–§6 là làm hỏng cả
hai mục cùng lúc.

Nếu một mục ở §7.2 được chủ quán xác nhận hoặc bác bỏ, chuyển nó lên §7.1 kèm ngày và xoá khỏi
§7.2 — **và trong cùng lần sửa đó, `grep -rn` cả repo tìm những chỗ đang nói mục ấy "chưa xác
nhận" rồi sửa nốt.** Một mục chỉ được nằm ở §7.2 chừng nào **chưa ai hỏi**. Cả ba mục đầu tiên
(S-1, S-2, S-3) đã đi qua đúng đường này ngày 2026-08-30.

---

## 8. Mảng QUẢN TRỊ (admin) — mục riêng, không trộn vào §1–§7

**Mục này là chỗ duy nhất giữ dữ kiện của mảng quản trị.** §1–§6 nói về việc **bán hàng** — bàn,
đơn, giá, bếp, thu tiền. Mục này nói về việc **chạy cái quán**: nguyên liệu, con người, tiền vào
tiền ra. Hai mảng đứng riêng vì chúng đổi vì hai lý do khác nhau, và một mục phục vụ hai lý do thì
sai với ít nhất một trong hai.

### 8.1 Ranh giới: ba mảng nằm TRONG phạm vi phần mềm

**Chủ quán chốt 2026-09-01, xác nhận lại 2026-09-02.** Ba mảng vào phạm vi:

| Mảng | Gồm những gì (theo lời chủ quán) |
|---|---|
| **Nguyên liệu** | thứ quán mua vào, nhập, dùng, hao hụt, còn lại |
| **Con người** | ai làm, ai trực trạm nào, công, lương |
| **Tài chính** | tiền vào tiền ra ngoài tiền hàng — chi phí, lãi lỗ, quỹ |

Trước ngày đó, phần mềm được mô tả là **không** làm ba mảng này. Lời chốt lật ngược đúng câu ấy.

### 8.2 Mở ranh giới chưa phải là có luật

Tới **2026-09-03** mục này chỉ có ranh giới, chưa một quy tắc nghiệp vụ nào. Ngày **2026-09-04**
mảng **nguyên liệu** có mức sâu của nó (§8.4); ngày **2026-09-20** mảng **con người** có mức sâu của
nó (§8.7); **mảng tài chính thì vẫn đúng như đoạn dưới đây tả**, và đoạn ấy nay đọc cho một mình
mảng tài chính:

- **Mức sâu: nguyên liệu và con người ĐÃ chốt, tài chính thì chưa.** Mảng nguyên liệu làm ở mức
  *sổ ghi tay điện tử* — **§8.4**. Mảng con người làm tới **cả ba mức** — **§8.7**. Mảng tài chính
  làm tới đâu thì chưa có dòng nào trong tài liệu này trả lời, nên đừng suy ra hộ (§8.5 chốt **tiền
  đầu két**, đó là một dữ kiện, không phải mức sâu của cả mảng).
- **Chưa có con số nào — kể cả cho mảng nguyên liệu.** Không danh mục nguyên liệu, không đơn vị
  tính, không số người, không đơn giá công, không khoản chi. §8.4 chốt *cách ghi*, không chốt
  *ghi cái gì*: mọi con số cho ba mảng này còn phải hỏi chủ quán.
- **Bốn ranh giới ở §6.12 không bị lời chốt này chạm tới** — kênh bán thứ sáu, đơn tối
  thiểu và bậc phí ship, số tài khoản cứng trong sản phẩm, món ngoài bảng giá. Cả bốn vẫn là *đã
  quyết định không làm*.

### 8.3 Dữ kiện admin mới thì viết vào đâu

Vào **mục này**, đánh số tiếp §8.4, §8.5…, rồi thêm một dòng vào nhật ký §7.1 với ngày và cột
*Ghi ở* trỏ về mục con vừa viết. Không viết dữ kiện admin vào §1–§6, kể cả khi nó "gần giống" một
quy tắc bán hàng đã có: hết nguyên liệu và tạm dừng nhận đơn là hai việc khác nhau, một cái ở mục
này, một cái ở §6.

### 8.4 Mảng NGUYÊN LIỆU — mức **sổ ghi tay điện tử**, và một mục nhập tổng hàng ngày

**Chủ quán chốt 2026-09-01, xác nhận lại 2026-09-04.** Mảng nguyên liệu làm ở mức **sổ ghi tay
điện tử**: máy là chỗ **chép lại** con số người ghi, không phải chỗ **tự tính ra** con số.

| Máy làm | Máy KHÔNG làm |
|---|---|
| nhận con số người nhập bằng tay, giữ lại, cộng lại, hiện ra | tự trừ tồn mỗi lần bán một suất |
| ghi lại ai nhập và nhập ngày nào | quy một suất bán ra thành lượng nguyên liệu đã dùng |

**Hệ quả: phần mềm không cần biết một suất bánh ăn hết bao nhiêu gam gạo.** Định lượng từng thành
phần là kiến thức của người làm, không phải tham số của phần mềm. Cùng lối nghĩ với lời chốt
*"máy không gom, người gom"* (2026-08-31, §5.4): máy giữ con số, người quyết con số.

**Mục tổng lưu trữ hàng ngày — chủ quán chốt 2026-09-04.** Nguyên văn lời chủ quán:
*"có mục tổng lưu trữ hàng ngày tôi sẽ nhập số liệu"*. Ba điều nói thẳng, không suy:

1. có **một mục tổng** cho nguyên liệu — không phải ghi theo từng lần bán;
2. nhịp của nó là **hàng ngày**;
3. người nhập là **chủ quán**, và nhập **bằng tay**.

**Con số ghi trong mục tổng — chủ quán chốt 2026-09-06, trả lời `U-034`.** Nguyên văn: *"đồ mua
trong ngày và đồ dùng trong ngày để tôi biết còn thừa thiếu bao nhiêu."* Mục tổng ghi **HAI** con
số mỗi ngày cho mỗi thứ trong danh mục — không phải một, và không phải đường *còn lại cuối buổi*:

1. **đồ MUA VÀO trong ngày**, và
2. **đồ ĐÃ DÙNG trong ngày**,

để chủ quán tự cộng dồn và biết **còn thừa hay thiếu** bao nhiêu — mục đích chủ quán nói thẳng,
không phải suy ra.

- **"Đã dùng" ở đây là con số chủ quán TỰ ƯỚC LƯỢNG VÀ NHẬP TAY**, không phải con số máy suy ra từ
  công thức bán hàng. Câu này **không** lật ngược bảng *máy làm / máy KHÔNG làm* ở trên: máy vẫn
  chỉ chép lại con số người gõ vào, không tự quy đổi một suất bán thành lượng nguyên liệu đã dùng.
- **Nhóm "số điện, số nước" vẫn đứng ngoài cặp mua/dùng này** — nhóm đó là **chỉ số công tơ**
  (chốt 2026-09-04, `work/findings.md` bối cảnh T-055), không phải hàng có tồn, nên không nhận
  cặp số này.
- **Danh mục cụ thể (thứ nào, đơn vị gì) vẫn CHƯA chốt xong** — U-034 chỉ trả lời **loại con số**,
  không trả lời **ghi cái gì**; chủ quán đã bắt đầu liệt kê **tên** (ngay dưới đây, 2026-09-06),
  nên ranh giới đầu tiên của "Ba ranh giới của chính §8.4" đổi một phần — xem ngay dưới.

**Danh mục nguyên liệu — chủ quán bắt đầu liệt kê 2026-09-06, còn bổ sung dần.** Nguyên văn:
*"nhân thịt, nhân thịt mộc nhĩ, rau mùi tàu, quất, hành tây, mì chính, hạt nêm, đường trắng, đường
đen, gạo, bột bánh cuốn, hạt tiêu, nước mắm, dầu rửa bát"* — mười bốn thứ đầu tiên. Chủ quán nói
thẳng đây là **hạng mục quan trọng** và sẽ **bổ sung dần dần**, nên đừng đọc mười bốn thứ này như
một danh mục đã đủ.

- **Đây mới chỉ là TÊN, chưa có đơn vị tính cho bất kỳ thứ nào** — đúng ranh giới thứ nhất dưới
  đây: *ghi cái gì* mới có phần **tên**; phần **đơn vị** vẫn như §8.2 đã nói, chưa có dữ kiện nào
  (`work/admin-questions.md` câu **B12**). Đừng tự suy đơn vị (vd "gạo" tính theo kg hay theo bao).
  Phần **ngưỡng nhắc sắp hết** thì **không bao giờ có** — xem khối *không có ngưỡng* ngay dưới
  (chủ quán chốt 2026-09-15).
- **Danh sách CHƯA đầy đủ — đừng coi mười bốn thứ này là toàn bộ nguyên liệu quán dùng.** Chủ quán
  nói sẽ thêm dần; mỗi lần thêm, nối tiếp vào đây kèm ngày, đừng viết đè lên danh sách cũ.
- **Từ 2026-09-08, danh mục này có một người ĐỌC nó ngoài mục §8.4:** mục tổng quan §8.6 — vế
  *"còn thiếu gì không"* của chủ quán chỉ thẳng vào danh mục này. ⇒ Danh mục dài ra thì vế ấy dài
  ra theo, không có danh sách thứ hai ở §8.6 (**F-001**). Chỗ hở *đơn vị tính · ngưỡng nhắc sắp
  hết* từng mang mã `docs/product/99-unknowns.md` **U-045** vì nó chặn §8.6 bày được chữ *thiếu*;
  câu ấy đóng 2026-09-15 — ngay dưới.

**Không có ngưỡng: CHỦ QUÁN tự đọc hai con số rồi tự kết luận thiếu hay đủ — chủ quán chốt
2026-09-15, trả lời `U-045`.** Nguyên văn: *"chủ quán tự đọc rôi đưa ra kết luận"* — trả lời câu
*"một ngưỡng người tự nhập cho từng thứ, hay chủ quán tự đọc hai con số rồi tự kết luận?"*. Hai
con số là cặp **mua vào · đã dùng** ở trên (`U-034`, 2026-09-06).

| Máy làm | Máy KHÔNG làm |
|---|---|
| giữ và hiện hai con số người nhập cho từng thứ trong danh mục | giữ một **ngưỡng nhắc sắp hết** cho bất kỳ thứ nào |
| | tự kết luận một thứ đang **thiếu** hay **sắp hết**, tự nhắc, tự báo |

- **Bảng này thêm vào bảng *máy làm / máy KHÔNG làm* đầu §8.4, không thay nó**: §8.4 đứng nguyên
  ở mức **sổ ghi tay điện tử**. Lời chốt đi đúng đường **không** lật ngược §8.4 — nên cửa duy nhất
  mở lại được mức ấy (câu **B22**, giá vốn một suất) vẫn chưa ai mở.
- **Danh mục nguyên liệu KHÔNG mọc cột *ngưỡng*.** Chỗ hở còn lại của danh mục chỉ là **đơn vị
  tính** (câu **B12**) — nó từng nằm chung trong `U-045`, nhưng lời chốt này **không** đóng nó.
- **Chủ quán đọc hai con số ấy Ở ĐÂU, và đọc con số nào — chủ quán chốt 2026-09-16, trả lời
  `U-051`.** Nguyên văn: *"thời gian nhâp sản phẩm và tổng đã sử dụng lấy thiếu bằng tổng đã nhập
  trừ đi sử dụng"*. ⇒ **mục tổng quan §8.6 bày ba thứ** cho vế nguyên liệu:
  1. **thời gian nhập** của từng thứ — dữ kiện mới, chưa mục nào trước đây nói tới;
  2. **tổng đã dùng**;
  3. **số thiếu**, và số ấy **máy tự trừ**: *thiếu = tổng đã nhập − tổng đã dùng*.
  - **Không lật §8.4, và không lật `U-045`.** Bảng *máy làm* đầu mục vốn đã cho máy *"nhận con số
    người nhập, giữ lại, **cộng lại**, hiện ra"* — một phép trừ trên hai con số **người đã gõ vào**
    vẫn nằm trong đúng mức sổ ghi tay điện tử, không phải máy tự quy suất bán ra lượng nguyên liệu.
    Máy vẫn **không** có ngưỡng, **không** tự kết luận *sắp hết*, **không** nhắc.
  - *Cách đọc của phiên viết, không phải lời chủ quán* (`work/findings.md` **F-004**): chữ *thiếu*
    trong lời chốt này là **tên của hiệu số**, không phải một phán quyết — đúng thứ `U-045` vừa dời
    ra khỏi máy ngày 2026-09-15.
  - ⛔ **Hai con số *tổng* cộng dồn TỪ MỐC NÀO thì lời chốt không nói** — mục tổng ghi hai con số
    theo **từng ngày** (`U-034`), nên *tổng* có ít nhất ba nghĩa: từ ngày đầu tiên có sổ, trong
    tháng, hay trong ngày. Đó là `docs/product/99-unknowns.md` **U-054**. Không suy hộ
    (`CLAUDE.md` §3.5).

**Ba ranh giới của chính §8.4:**

- **Chốt *cách ghi*, không chốt *ghi cái gì*.** Danh mục nguyên liệu **bắt đầu có tên** (xem ngay
  trên, 2026-09-06, còn bổ sung dần); đơn vị tính thì vẫn chưa có dữ kiện nào, đúng như §8.2 nói.
  Ngưỡng nhắc sắp hết thì **không có** — chủ quán tự kết luận (2026-09-15, ngay trên).
- **Không nói mảng này có vào bản chạy đầu tiên hay không.** Đó là câu của
  `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7, và câu ấy đã chốt riêng ngày 2026-09-02
  (U-030): **không** mảng quản trị nào phải chạy cùng bản bán hàng đầu tiên.
- **Mở lại được, và có đúng một cửa để mở.** Muốn biết **giá vốn một suất** thì phải chốt định
  lượng từng thành phần, tức lật ngược mức sổ tay ở trên. Hôm nay chưa ai hỏi câu ấy
  (`work/admin-questions.md` câu **B22**); hỏi rồi mà chủ quán trả lời *"có"* thì mục này phải
  viết lại, không phải viết thêm.

### 8.5 Mảng TÀI CHÍNH — tiền đầu két, và tiền nằm trong két tới cuối buổi

**Chủ quán chốt 2026-09-04** (trả lời `A3` và `A4`). Đây là hai dữ kiện mà phép đối soát ngưỡng
lệch **0đ** ở §6.10 đang thiếu, và là đúng chỗ trống mà tài liệu kiến trúc §14.3 đã gọi tên:
*"tiền đầu buổi và tiền nộp về chưa nằm trong phép tính đối soát"*.

**Đầu buổi, chủ quán bỏ tiền lẻ vào két cho POS lấy tiền thối.** Nguyên văn: *"chủ quán để tiền cho
pos khoảng 1 triệu tiêng 50k, 20k, 10k. 100k tiền 5k, 100k tiêng 2k và 1k. để số cố định nhưng có
thể sửa có những không như thế."*

| Phần | Con số | Loại con số (§0 luật 3 của `work/admin-questions.md`) |
|---|---|---|
| mệnh giá 50.000 · 20.000 · 10.000 | **khoảng 1.000.000** | **ước lượng** — chữ *"khoảng"* là của chủ quán, phiên sau được phép hỏi lại |
| mệnh giá 5.000 | **100.000** | nói thẳng |
| mệnh giá 2.000 và 1.000 | **100.000** | nói thẳng |

⚠️ **Tổng ≈ 1.200.000đ là PHÉP CỘNG CỦA PHIÊN, không phải con số chủ quán nói.** Chủ quán chưa bao
giờ đọc ra một con số tổng. Đừng viết *"đúng 1.200.000"* ở bất kỳ đâu (`work/findings.md` **F-003**).

**Máy giữ con số ấy như một số mặc định CỐ ĐỊNH, và người dùng SỬA được.** Nguyên văn: *"để số cố
định nhưng có thể sửa có những không như thế"* — tức có ngày số tiền bỏ vào không đúng như trên, và
máy phải nhận con số của ngày hôm ấy.

**Giữa buổi KHÔNG ai lấy tiền ra; tiền nằm trong két tới cuối buổi.** Nguyên văn: *"không có ai lấy
tiền tiền nằm trong két tới cuối buổi."* ⇒ **quán không có nghiệp vụ nộp bớt tiền giữa buổi**, nên
phép đối soát không phải cộng lại các lần rút giữa chừng. Đây là một câu trả lời **đóng**: nó làm
việc ít đi, không nhiều thêm.
⚠️ **Một đường tiền rời két giữa buổi có tồn tại, và nó KHÔNG phải một lần nộp bớt:** POS hoàn
bằng **tiền mặt** cho một khoản khách đã **chuyển khoản** (chủ quán chốt 2026-09-08, trả lời
`U-044` ⇒ §6.4). Lời chốt ở trên vẫn đúng nguyên văn — không ai *lấy* tiền ra — nhưng phép trừ của
`quality/invariants.md` **I-021** nay mang hạng tử cho đúng ca ấy (viết lại 2026-09-15, **ADR-046**).

**Hệ quả cho phép đối soát — đây là chỗ đắt nhất của cả mục:** tiền mặt đếm được trong két cuối
ngày **đã bao gồm** tiền đầu két. So thẳng nó với doanh thu tiền mặt thì lệch **đúng bằng** số tiền
đầu két, **mọi ngày**, và ngưỡng 0đ của §6.10 mất hết ý nghĩa — người dùng sẽ học cách bỏ qua chỗ
lệch ấy. Mệnh đề này là `quality/invariants.md` **I-021**.

**Con số nhập vào máy — chủ quán chốt 2026-09-06, trả lời `U-038`: CẢ HAI**, không phải chọn một.
Nguyên văn: *"tổng của từng mệnh giá và tổng của tất cả các mệnh giá cộng lại với nhau."* ⇒ Máy giữ
một **bảng** — mỗi dòng một mệnh giá, sửa được (như đã chốt ở trên) — **và** hiện **tổng cộng** của
bảng đó. Con số dùng cho phép trừ ở `quality/invariants.md` **I-021** là **tổng cộng**; bảng theo
từng mệnh giá là cách **đếm và kiểm** cuối ngày, không phải một phép tính thứ hai — đổi tiền thối
giữa buổi có thể làm lệch một dòng mệnh giá mà không làm lệch tổng, và đó không phải một lần đối
soát 0đ báo đỏ vì I-021 chỉ so **tổng**.

### 8.6 Mục TỔNG QUAN của chủ quán khi không đứng quầy

**Chủ quán chốt 2026-09-04** (trả lời `A10`). Nguyên văn: *"nhìn thấy bảng tổng quan của quán có
đang làm cho bao nhiêu người ăn, đưa ra dc bao nhiêu còn thiếu bao nhiêu bán dc như nào rồi số tiền
dự tính đã bán dc. có bao nhiêu người đang làm còn thiếu gì không"*.

**Bảy** thứ chủ quán gọi tên, viết ở tầng nghiệp vụ — **không** phải một màn, **không** phải một
route (`docs/decisions.md` ADR-035). *Con số **bảy** là phép đếm của bảng ngay dưới, không phải lời
chủ quán — đếm lại, đừng tin câu này (`work/findings.md` **F-003**). Tới 2026-09-07 mục này đếm
**sáu**: thứ thứ bảy nằm trong nguyên văn từ đầu nhưng chưa ai hiểu nó là gì, và chỉ có nghĩa từ
2026-09-08.*

| # | Chủ quán muốn thấy | Ghi chú |
|---|---|---|
| 1 | đang làm cho **bao nhiêu người ăn** | số khách đang được phục vụ |
| 2 | **đưa ra được bao nhiêu** | phần đã ra bàn |
| 3 | **còn thiếu bao nhiêu** | phần chưa ra bàn — cùng cặp với số 2 |
| 4 | **bán được như nào rồi** | tiến độ bán trong buổi |
| 5 | **số tiền dự tính đã bán được** | ⚠️ chữ *dự tính* là của chủ quán: đây là con số **tạm tính trong buổi**, **không** phải doanh thu đã đối soát (§6.10) và không bao giờ được bày ra như thể đã đối soát |
| 6 | có **bao nhiêu người đang làm** | ⛔ vẫn chưa đủ nguồn, nhưng **chặn đã CHUYỂN CHỦ ngày 2026-09-20**: câu `C36` đã có lời và lời ấy đã về owner (**§8.8** — mỗi lần đổi người **ở quầy** là một mốc có giờ). Lời ấy phủ **một** trong năm trạm, nên con số này còn đứng trên **`U-055`** — *bốn trạm còn lại có mốc đổi người không* |
| 7 | **còn thiếu gì không** | **cả BA đường, không phải một** (chốt 2026-09-08, ba lượt): thiếu **NGUYÊN LIỆU** · thiếu **NGƯỜI** · thiếu **MÓN trên menu** — xem ngay dưới. Mỗi đường trỏ vào một tập **đã có chủ ở chỗ khác**, không đường nào có danh sách riêng ở đây (**F-001**): nguyên liệu → **Danh mục nguyên liệu** §8.4 · người → **bảng phân vai** §3 · món → **§4.9**. Chữ *thiếu* từ đâu ra: **nguyên liệu — máy KHÔNG kết luận, chủ quán tự đọc hai con số mua vào · đã dùng rồi tự kết luận** (chốt 2026-09-15, đóng `U-045`, §8.4), và **mục tổng quan bày ba thứ**: *thời gian nhập* · *tổng đã dùng* · *số thiếu = tổng đã nhập − tổng đã dùng* (chốt 2026-09-16, đóng `U-051`, §8.4); ⛔ hai con số *tổng* ấy cộng dồn từ mốc nào thì chưa — **U-054**. ⛔ **Người** thì lời đầu tiên có ngày **2026-09-20** và đã về owner — **§8.8**, mốc đổi người **ở quầy** — nhưng nó phủ **một** trong năm trạm, nên vế này còn đứng trên **`U-055`** (bốn trạm còn lại) — *U-049 đóng 2026-09-08 (người đi giao là một trong bốn vai, POS chỉ định) và U-050 đóng 2026-09-15 (POS gánh trạm bị bỏ trống, khoảng trống do đi giao **không** là thiếu người) — cả hai ở §3* |

**Vế thứ bảy — *"còn thiếu gì không"* — chủ quán chốt 2026-09-08: thiếu NGUYÊN LIỆU.** Nguyên văn
lượt ấy: *"về nguyên liệu hãy tham khảo «Danh mục nguyên liệu» tại `master_plan/shop-facts.md`"* ⇒
trong ba đường ra mà `U-041` hỏi (nguyên liệu · người · món trên menu), chủ quán chọn đường
**nguyên liệu**, và chỉ thẳng tập nguyên liệu là **Danh mục nguyên liệu** ở §8.4 — mười bốn tên mở
2026-09-06, **còn bổ sung dần**, nên vế này lớn lên theo danh mục ấy chứ không có danh sách riêng
của mình (`work/findings.md` **F-001**: đừng chép danh mục xuống đây).

**Cùng ngày 2026-09-08, lượt sau, chủ quán chạm nốt hai đường còn lại.** Nguyên văn: *"đối với
nguyên liệu và con người đã có. đối với menu: tôi muốn có …"* rồi đọc ra cả danh sách món (nay ở
**§4.9**). Nên vế thứ bảy **không** chỉ là nguyên liệu:

- **Đường *món trên menu* nay có tập của nó — §4.9.** Trước lượt ấy không lời nào nói menu gồm
  những gì; nay có, nên chữ *thiếu món* đã có chỗ để trỏ vào. Như với nguyên liệu, vế này **lớn
  lên theo §4.9**, không có danh sách thứ hai ở đây (`work/findings.md` **F-001**), và ba dòng cuối
  của §4.9 còn đang chờ **U-046** · **U-047**.
- **Đường *người* nay cũng có tập của nó — bảng phân vai §3** (chủ repo chỉ chỗ 2026-09-08, lượt
  thứ ba). Chủ quán đã nói *"đã có"* ở lượt trước; chỗ còn thiếu là **đường ấy đọc vào đâu**, và
  câu trả lời là **§3**: **năm trạm việc**, gộp thành **bốn vai người** (chủ quán chốt 2026-08-30),
  cộng **chủ quán** là vai riêng đứng ngoài năm trạm. Như hai đường kia, vế này **lớn lên theo §3**
  chứ không có bảng vai thứ hai ở đây (**F-001**).
  - **Chỗ §3 đáng nhớ nhất cho vế *thiếu người*:** ba trạm `quay` · `trang_banh` · `gap_banh` là
    **trạm riêng**, còn `canh` + `don_ban` **chung một đôi tay** — nên khi bếp đông, hai loại việc
    ấy tranh nhau người còn ba trạm kia thì không. Chữ *thiếu người* vì thế **không** đồng đều giữa
    năm trạm; đó là dữ kiện của §3, không phải một luật mới của mục này.
  - **Số 6 và số 7 là HAI con số khác nhau, đừng gộp** (phép đọc của phiên viết, không phải lời chủ
    quán — **F-004**): số 6 là *bao nhiêu người **đang** làm* (đếm người có mặt), số 7 là *đang
    **thiếu** người hay không* (so cái có mặt với cái cần). Gộp hai cái thì mục tổng quan mất đúng
    câu chủ quán hỏi.
  - ✅ **Con số người thật của quán ĐÃ đóng, 2026-09-08** (chủ quán, trả lời `U-049`): người **đi
    giao** là **một trong bốn vai** của §3 rời quán đi giao, **không** phải người thứ năm, và **POS
    chỉ định** ai đi từng lần. ⇒ Số **6** (*bao nhiêu người đang làm*) đếm trên **bốn vai** của §3
    cộng chủ quán, không có dòng thứ năm nào cho việc đi giao. Lời chốt ở **§3**.
  - ✅ **Khoảng trống do đi giao KHÔNG là thiếu người, 2026-09-15** (chủ quán, trả lời `U-050`):
    *"pos gánh, không thiếu người vì đi ship luc quán vắng."* ⇒ một chuyến giao rút một đôi tay
    ra khỏi năm trạm nhưng **không** làm số **7** bật lên; người đứng quầy gánh trạm bị bỏ trống.
    Lời chốt ở **§3**.
  - ⛔ **Máy biết đang thiếu người bằng cách nào thì vẫn chưa đủ** — nhưng chỗ hở đã **hẹp lại**
    ngày **2026-09-20**: câu **C36** có lời và lời ấy đã về owner (**§8.8**, qua ADM-21), nên trạm
    `quay` nay có nguồn. Bốn trạm còn lại thì chưa, và chỗ hở còn lại mang mã **`U-055`**
    (`docs/product/99-unknowns.md`). Chừng nào `U-055` chưa có lời, số **7** vẫn chưa đủ nguồn —
    dù số **6** thì có rồi. (`U-052` —
    ai gánh `quay` khi chính người đứng quầy đi giao — **đã đóng 2026-09-16**: người đứng quầy
    **không** đi giao, nên ca ấy không tồn tại; nó vốn cũng không chặn số 7, vì lời `U-050` đã loại
    khoảng trống do đi giao khỏi chữ *thiếu người*, bất kể ai đi.)
- ⚠️ **Chỗ suy ra:** rằng mục tổng quan **bày cả ba** đường cùng một chỗ là cách phiên viết đọc câu
  *"nguyên liệu và con người đã có, đối với menu…"*; chủ quán **không** nói thẳng *"mục tổng quan
  hiện cả ba"* (`work/findings.md` **F-004**). Ghi ở §7.2 thành **S-8** — đừng đọc nó như một lời
  chốt.
- **Không đường nào bị loại bằng lời** (**F-004**): không câu nào nói *"không bao giờ hiện thiếu
  người"*. Đừng viết một lời loại trừ mà chủ quán chưa nói.
- ✅ **Máy biết một nguyên liệu đang thiếu bằng cách nào — ĐÃ đóng, 2026-09-15: máy KHÔNG biết,
  và không cần biết.** Chủ quán trả lời `U-045`: *"chủ quán tự đọc rôi đưa ra kết luận"* ⇒ không
  có ngưỡng, máy không bày chữ *thiếu*; người đọc cặp số **mua vào · đã dùng** rồi tự kết luận
  (§8.4, khối *không có ngưỡng*). ✅ **Vế nguyên liệu của hàng 7 BÀY GÌ — ĐÃ đóng, 2026-09-16**
  (`U-051`): *"thời gian nhâp sản phẩm và tổng đã sử dụng lấy thiếu bằng tổng đã nhập trừ đi sử
  dụng"* ⇒ **thời gian nhập** · **tổng đã dùng** · **số thiếu máy tự trừ**; máy cộng dồn hộ nhưng
  vẫn không kết luận (§8.4). ⛔ Chỗ còn hở nay là **mốc cộng dồn** của hai con số *tổng* —
  **`U-054`**. Lúc
  `U-045` còn mở (2026-09-08) có hai đường ra: **lật ngược §8.4** (máy tự trừ tồn) hoặc **một
  ngưỡng người tự nhập**; chủ quán không chọn đường nào trong hai — chọn đường thứ ba câu hỏi đưa
  ra, **người đọc và người kết luận**, nên §8.4 đứng nguyên.

**Mục này chốt TẬP CON SỐ, không chốt cách bày và không chốt nhịp cập nhật.** Bày thế nào là pha 4;
đẩy dữ liệu về máy chủ quán bằng đường nào là **P1-08** của pha 1. Cả hai đều không được viết ở đây.

### 8.7 Mảng CON NGƯỜI — làm tới **cả ba mức**: ai đang trực trạm · chấm công · tính lương

**Chủ quán chốt 2026-09-01, xác nhận lại 2026-09-20** (việc đi hỏi: `work/backlog_AD.md` ADM-53).
Câu hỏi lượt xác nhận: *quán biết ai đang trực ở trạm nào · quán chấm công · quán tính lương trên
máy — vẫn đúng cả ba chứ?*; chủ quán chọn **"Đúng, cả ba mức"**.

| Mức | Máy làm gì |
|---|---|
| 1 | **ai đang trực trạm nào** — tại một lúc bất kỳ, quán biết được người nào đang đứng ở trạm nào trong năm trạm §3 |
| 2 | **chấm công** — quán ghi được công của từng người trên máy |
| 3 | **tính lương** — quán tính lương **trên máy**, không tính ngoài bằng sổ hay bảng tính riêng |

**Lời này chốt MỨC SÂU, không chốt một con số nào.** Đơn giá công, cách tính một công, kỳ trả
lương, ai được xem bảng lương, đi muộn có trừ không — **không** câu nào trong số đó có lời; chúng
là các câu `C23`…`C35` ở `work/admin-questions.md` §3 và vẫn đang chờ. Đừng suy ra hộ một con số
nào từ mục này (`CLAUDE.md` §3.5).

**Người mà ba mức này đếm là người của §3, không phải một danh sách thứ hai.** Bốn vai cộng chủ
quán (§3, chốt 2026-08-30 và 2026-09-08) là tập người duy nhất; mục này **không** giữ bảng người
riêng (`work/findings.md` **F-001**). Mức 1 cũng chính là chỗ mục tổng quan §8.6 hàng 6 đang hở —
*bao nhiêu người đang làm* đứng trên nó.

**Mức 1 nay có luật — nhưng chỉ cho TRẠM QUẦY.** *Người đứng quầy đổi giữa buổi thì máy có ghi lại
mốc đổi không* là câu **`C36`**; nó có lời ngày **2026-09-20**, và lời ấy đã về owner trong cùng
ngày qua `work/backlog_AD.md` **ADM-21** — đọc ở **§8.8**, không đọc ở đâu khác
(`work/findings.md` **F-001**). Lời ấy phủ **một** trong năm trạm; bốn trạm còn lại của mức 1 vẫn
chưa có luật nào, và chỗ hở ấy mang mã **`U-055`** (`docs/product/99-unknowns.md`).

**Lời này KHÔNG nói mảng con người lưu ở đâu hay bày thế nào.** Chỗ cất dữ liệu là pha 2, màn hình
là pha 4 (`docs/decisions.md` **ADR-035**). Mục này chỉ nói quán muốn máy làm tới đâu.

### 8.8 Mức 1 của mảng CON NGƯỜI — **mỗi lần đổi người ở QUẦY là một mốc có giờ**

**Chủ quán chốt 2026-09-20** — câu **`C36`**, hỏi qua `work/backlog_AD.md` **ADM-53** và chuyển về
owner qua **ADM-21** trong cùng ngày. Câu hỏi: *người đứng quầy đổi giữa buổi (A đi ăn, B thay) —
quán có muốn máy ghi lại mốc đổi ấy không?* Nguyên văn lời đáp:

> **"Có — ghi cả mốc đổi, ai vào ai ra lúc mấy giờ."**

Chủ quán tả thêm: **mỗi lần đổi người ở quầy là một mốc có giờ; đơn nào, huỷ nào, hoàn tiền nào
cũng truy ra được người đang đứng lúc ấy.**

Ba điều lời chốt nói, và không điều nào rộng hơn:

| # | Lời chốt nói gì |
|---|---|
| 1 | Máy **ghi lại mốc đổi**, chứ không chỉ giữ người đang đứng lúc này — một mốc đã qua vẫn đọc lại được |
| 2 | Mỗi mốc có **giờ**, và có **cả hai vế**: ai **vào**, ai **ra** |
| 3 | Đọc ngược được: với một đơn · một lần huỷ · một lần hoàn tiền, truy ra **người đang đứng quầy lúc ấy** |

**Phạm vi là trạm `quay`, đúng bằng câu hỏi — đừng đọc rộng ra năm trạm.** Câu `C36` hỏi về người
đứng quầy và lời đáp nói về người đứng quầy. Bốn trạm còn lại của §3 — `trang_banh` · `gap_banh` ·
`canh`+`don_ban` — **chưa có lời nào**, và chỗ hở ấy là **`U-055`**, không phải một chỗ để suy ra
(`work/findings.md` **F-004**).

**Vì sao trạm `quay` là trạm đáng chốt trước:** `docs/decisions.md` **ADR-016** chốt POS ở quầy là
**cửa ghi duy nhất**, và §6.13 chốt quyền huỷ / hoàn tiền gắn **chỗ đứng** chứ không gắn chức vụ.
Cả hai luật ấy hỏi đúng một câu — *ai đang đứng quầy lúc ấy* — và tới trước ngày 2026-09-20 không
dữ kiện nào trả lời được. Lời `C36` là dữ kiện đầu tiên trả lời nó.

**Lời này chốt LUẬT GHI, không chốt hình dạng dữ liệu.** Mốc ấy cất ở đâu, đọc ra bằng đường nào,
bày ở màn nào — pha 2 và pha 4 (`docs/decisions.md` **ADR-035**). Yêu cầu tương ứng ở tầng nghiệp
vụ đã viết sẵn từ **P1-07** (2026-09-07): `docs/product/1-system-design/04-yeu-cau-du-lieu.md`
**`YC-15`** — *trực trạm là một thứ đọc được theo thời điểm*. Lời `C36` **xác nhận** câu ấy, không
thêm một yêu cầu nào.

**Ba vế lời chốt KHÔNG nói — cả ba mang mã riêng, không vế nào được lấp bằng suy luận**
(`CLAUDE.md` §3.5 · **F-004**):

- **Bốn trạm còn lại có mốc đổi không** ⇒ **`U-055`**. Số **6** của §8.6 (*bao nhiêu người đang
  làm*) đứng trên vế này.
- **Ai khai cái mốc ấy** — người vào tự bấm, người ra bấm, hay POS bấm hộ ⇒ **`U-056`**. Lời đáp
  nói máy **ghi**, không nói ai **khai**.
- **Hai cửa ghi ngoài quầy** — người đi giao bấm *đã giao + đã thu tiền* tại chỗ khách (§6.7) và
  chủ quán đổi giá / đổi thành phần suất trên mặt quản trị (§6.17) ⇒ **`U-057`**.
  `quality/invariants.md` **I-012** đòi *ai bấm* cho cả hai, và lời `C36` không phủ chúng.

**Lời này KHÔNG chạm chấm công.** *Lúc này ai đứng quầy* và *hôm nay người này làm mấy giờ* là hai
câu khác nhau; câu thứ hai là mức 2 của §8.7 và vẫn chờ `C30` · `C31` · `C32`
(`work/admin-questions.md` §3).
