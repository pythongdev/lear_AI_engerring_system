# Architecture — mặt quản trị của "Bánh cuốn Bà Thanh Cao Bằng"

*T-029 — chốt 2026-08-31. Nguồn: `master_plan/shop-facts.md` (dữ kiện quán) ·
`docs/product.md` §1, §2, §3 (hành vi đã chốt) · `master_plan/prompt-fullstack.md` §3.4–§3.7, §4
(stack, hình dạng dữ liệu, API, route — đã chốt trước đó) · `docs/decisions.md` ADR-009, ADR-011.*

> **Tài liệu này sở hữu cấu trúc hệ thống, không sở hữu dữ kiện quán.** Giá, giờ bán, số bàn, số
> nồi, thành phần một suất, quy tắc nghiệp vụ đều thuộc `master_plan/shop-facts.md` (ADR-001).
> Chỗ nào cần một con số, tra ở đó — ở đây không có bản chép thứ hai (`work/findings.md` F-001).
>
> **Đây là đặc tả, không phải mã.** Nó nói *cái gì phải đúng* và *ai được ghi cái gì*; nó không
> nói tên hàm, tên file hay thư viện. Stack đã chốt ở `master_plan/prompt-fullstack.md` §3.4.

---

## 1. Một hệ thống, ba mặt

Quán không cần ba sản phẩm. Nó cần **một** miền nghiệp vụ, nhìn từ ba chỗ đứng khác nhau
(`docs/decisions.md` **ADR-011**):

```
                    MỘT MIỀN NGHIỆP VỤ
        (giá · phiên bàn · nổ thành phần · quyền · tiền)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
      POS                 BẾP                CHỦ QUÁN
     /quầy/           /năm màn trạm/         /quản trị/
        │                   │                   │
   GHI mọi thứ          CHỈ ĐỌC           GHI cấu hình
   đơn · bàn · tiền     việc phải làm      menu · giá · người
   nhu cầu · phục vụ    (không nút bấm)    đọc báo cáo · đối soát
```

Ba mặt, **một** bộ luật. Cùng một quy tắc *"chỉ người đứng quầy được huỷ đơn"* phải chặn được cả
lời gọi từ màn hình chủ quán lẫn lời gọi từ màn hình trạm — nên nó sống ở miền nghiệp vụ, không
sống trong màn hình nào.

### 1.1 Luật ghi — điểm quan trọng nhất của cả tài liệu

> **POS là nơi duy nhất ghi ra tiến độ sản xuất và phục vụ. Màn hình trạm chỉ đọc.**

Chủ quán chốt 2026-08-31 (`shop-facts.md` §5.4, mục *"Không có nút bấm nào ở trạm bếp"*): người
tráng bánh, người gấp bánh, người lấy canh **không bấm gì** để báo xong — *"bỏ qua bước này, POS
sẽ tự cập nhật được bao nhiêu cái cho từng bàn"*. Lý do là ba đôi tay ấy đang bận; thêm một nút là
thêm việc cho đúng người không rảnh.

Hệ quả, và đây là chỗ dễ làm sai nhất:

| | Ai ghi | Ghi cái gì |
|---|---|---|
| Đơn: duyệt, huỷ | **POS** | `shop-facts.md` §6.2, §6.13 |
| Phiên bàn: mở, thêm suất, đóng | **POS** | §6.1 |
| Tiền: đã thu, hoàn, ghi nợ | **POS** | §6.3, §6.4, §6.14 |
| **Đã phục vụ cho bàn nào, bao nhiêu** | **POS** | §5.4 |
| Bàn đã dọn | trạm `don_ban` | §3 — việc này **có** một thao tác, vì nó là bước cuối của bàn, không phải bước giữa của món |
| Việc phải làm | **không ai ghi** — nó *sinh ra* từ đơn đã duyệt (§5.3) | |

✅ **Bản xuất khẩu đã khớp lại, 2026-08-31 (T-031).** `master_plan/prompt-fullstack.md` §3.6 từng
liệt kê một endpoint cho bếp bấm và §3.7 từng thiết kế một nút `Xong` ở màn trạm; cả hai viết
**trước** lời chủ quán ngày 2026-08-31 và đã bị gỡ. §3.6 nay mang chính luật ghi này thành một
khối tự đứng — người đọc **ngoài** repo không grep được, nên luật phải nằm trong file họ cầm, không
phải ở một pointer về đây. Chi tiết mâu thuẫn và giá của nó: `work/findings.md` **F-013** (Fixed).

### 1.2 Cái gì không bao giờ được nằm ở frontend

Sáu thứ, và mỗi thứ có một cách hỏng cụ thể nếu để sai chỗ:

| Ở backend | Để ở frontend thì hỏng thế nào |
|---|---|
| **Tính giá** | khách đặt được món 0đ (`shop-facts.md` §4.6 quy tắc 9) |
| **Gộp phiên bàn** | mỗi lượt gọi một hoá đơn ⇒ **thu thiếu tiền** (§6.1) |
| **Nổ suất thành thành phần** | bếp nhận `Combo ×2` mơ hồ (§5.3) |
| **Quyền huỷ / hoàn / duyệt** | ẩn cái nút đi không phải là chặn (§6.2, §6.4, §6.13) |
| **Chặn ngoài giờ bán / đang tạm dừng** | đổi đồng hồ máy khách là đặt được (§6.8) |
| **Từ chối tổ hợp `Chay` + `Nhiều nhân`** | bếp nhận phiếu mâu thuẫn (§4.6 quy tắc 3) |

Frontend được phép **hiện** kết quả của sáu thứ trên và **ẩn** nút cho gọn mắt; nó không bao giờ
là chỗ quyết định.

---

## 2. Hai trục, không phải một

`docs/decisions.md` **ADR-009**: nhu cầu sản xuất là một trục riêng, đặt cạnh trục đơn hàng chứ
không nằm trong nó.

```
   TRỤC ĐƠN  (khách trả tiền cho cái gì)
   đơn → duyệt → phiên bàn → hoá đơn → đã thu / ghi nợ

              ╲          ╱   gặp nhau đúng MỘT chỗ:
               ╲        ╱    đơn ĐÃ DUYỆT thì nhập nhu cầu,
                ╲      ╱     đơn HUỶ thì rút khỏi nhu cầu
                 ╲    ╱
   TRỤC SẢN XUẤT  ╳  (bếp phải làm cái gì)
                 ╱    ╲
   nhu cầu (cộng ngang mọi bàn) → người gom mẻ → làm xong → bưng ra bàn
```

Vì sao phải hai trục: con số quán thật sự dùng — *"còn phải làm 14 cái bánh"* — **không thuộc đơn
nào cả**. Nó cộng ngang qua mọi đơn đang mở. Trong một mô hình chỉ có đơn, con số ấy không có chỗ
nào để tồn tại.

**Máy không gom, người gom** (chủ quán chốt 2026-08-31, `shop-facts.md` §5.4 — *"máy không làm, để
người làm"*). Hệ thống bày ra tổng nhu cầu; nó **không** tự chia mẻ, **không** xếp nồi, **không**
quyết thứ tự, **không** đề xuất mẻ. Đây là **ranh giới đã chốt** ngang hàng bốn ranh giới ở §6.12
— cho máy chia mẻ là đổi phạm vi, phải xin phép chủ quán.

⇒ Hệ thống **không** cần biết một nồi làm được bao nhiêu. Ba tổ hợp ở `shop-facts.md` §5.4 là kiến
thức của **người đứng bếp**, không phải tham số của một thuật toán. Đừng mã hoá chúng.

---

## 3. Mặt POS — đài điều hành, không phải danh sách đơn

Màn hình chính của quầy **không** phải danh sách đơn. Người đứng quầy cần trả lời *"quán đang thế
nào"* trong một cái liếc, và `shop-facts.md` §5.4 liệt kê sáu thứ phải thấy cùng lúc (đếm được sáu
tính tới 2026-08-31 — đọc lại danh sách ấy, đừng tin con số này).

Bốn khối, cùng một màn:

```
┌─ QUÁN ĐANG THẾ NÀO ──────────── bàn đang ăn · chờ món · chờ thanh toán · trống
├─ CẦN LÀM (tổng) ─────────────── bánh · trứng CHÍN/TÁI/VÀNG · giò · nước chấm
│                                 tách theo nhân + lượng nhân
├─ CẦN LÀM (cho bàn nào) ──────── mỗi dòng tổng ở trên tách ngược về từng bàn
└─ CẦN CHÚ Ý ─────────────────── đơn chờ duyệt · đơn đang giao · phiên chờ thu
```

Bốn luật của khối này:

1. **Tổng và phân bổ luôn khớp nhau.** Tổng một thành phần = tổng phần chia về từng bàn. Gom không
   được làm mất hay đẻ ra số lượng — đây là invariant, xem §9.
2. **Tách theo đúng thứ khách chọn** (`shop-facts.md` §4.5): trứng theo chín/tái/vàng; bánh theo
   nhân và lượng nhân. Hai cái bánh cùng tên khác lượng nhân là **hai** dòng, không gộp.
3. **Chỉ bàn.** Ba kênh không gắn bàn không đổ vào bảng này (chủ quán chốt 2026-08-31, §6.15).
   Đơn mang đi có màn riêng, §3.2.
4. **Suất "đem về" của khách đang ngồi bàn VẪN nằm ở đây** (§6.15) — nó là suất của bàn đó. Nhưng
   nó phải mang **note "đem về" đọc ra được ngay**; chủ quán nhấn đúng chữ ấy. Đọc nhầm là khách
   mang về một đĩa không gói.

### 3.1 Phiên bàn — chỗ dễ mất tiền nhất

```
Trống ──► Mở ──► Đang phục vụ ──► Chờ thanh toán ──► Đã đóng ──► Cần dọn ──► Trống
                       ▲                  │
                       └──────────────────┘
                    khách gọi thêm: VẪN cùng phiên, cùng hoá đơn
```

- **`Chờ thanh toán` KHÔNG khoá bàn.** Khách gọi thêm lúc quầy đang thu vẫn vào **cùng** phiên,
  **cùng** hoá đơn (`shop-facts.md` §6.1 — lỗi tiền nguy hiểm nhất của luồng tại bàn).
- **Bàn trống cần CẢ HAI**: phiên đã đóng **và** bàn đã dọn (`quality/invariants.md` I-003).
- **Ghép bàn là NỚI một phiên sang bàn TRỐNG, không phải gộp hai hoá đơn** (chủ quán chốt
  2026-08-31, `shop-facts.md` §6.16). Người đứng quầy bấm, trên POS; bàn đang có phiên mở thì
  **không** ghép được. ⇒ Hệ thống **không cần** và **không được** có đường trộn tiền của hai
  hoá đơn đã mở — ca đắt nhất của ghép bàn đã bị đóng bằng quyết định, không phải bằng mã.
- Ràng buộc này phải được **database giữ**, không phải mã ứng dụng giữ:
  `master_plan/prompt-fullstack.md` §3.5 chi tiết 4 dùng generated column + `UNIQUE`, và nó
  **phải gồm cả trạng thái `billing`** — nếu chỉ tính `open`, lúc quầy bấm thu tiền ràng buộc nhả
  ra và lượt gọi thêm rơi vào hoá đơn thứ hai.

### 3.2 Đơn mang đi — màn riêng, ba kênh

`delivery` · `pickup` · `phone_preorder` — mỗi đơn là **một** đơn vị thanh toán độc lập
(`shop-facts.md` §5.2). Màn này cần cho thấy: đơn nào **chờ duyệt** (chỉ `delivery`, `pickup` —
`phone_preorder` do nhân viên nhập nên vào thẳng, §6.2), đơn nào có **giờ hẹn** đang tới gần, và
đơn nào **đang giao** — vì quán tự đi giao nên quầy phải biết ai đang cầm tiền chưa về (§6.7).

Giao xong bấm **đã giao + đã thu tiền cùng một lúc** — không có trạng thái "đã giao mà chưa thu"
trên đường mặc định.

### 3.3 Ba việc chạm tiền, cùng một người chịu trách nhiệm

| Việc | Luật | Bắt buộc ghi lại |
|---|---|---|
| **Duyệt đơn** | đơn khách tự gửi phải duyệt; đơn nhân viên nhập thì không (§6.2) | ai duyệt, lúc nào |
| **Huỷ đơn** | **chỉ người đứng quầy** (§6.13) | ai bấm, lý do |
| **Hoàn tiền** | không có luật cứng — quầy quyết từng ca (§6.4) | hoàn bao nhiêu · cho đơn nào · ai bấm · lý do gì |

Ba việc này đi qua **đúng một cửa: máy POS ở quầy**, nên mọi thao tác chạm tiền đều truy được về
một người khi đối soát cuối ngày (§6.10).

---

## 4. Quyền gắn CHỖ ĐỨNG, không gắn chức vụ — và vì sao `staff.role` không đủ

Đây là chỗ đặc tả này khác rõ nhất với một hệ thống phân quyền thông thường.

`shop-facts.md` §6.13: chủ quán **đang đứng quầy** thì tự bấm huỷ; chủ quán **không** đứng quầy thì
**nhờ người đứng quầy bấm**. Chức vụ không mở thêm cửa nào.

```
Người      : chủ quán            Người      : nhân viên A
Chức vụ    : owner               Chức vụ    : nhân viên
Đang đứng  : (không ở quầy)      Đang đứng  : quầy
Huỷ được?  : KHÔNG               Huỷ được?  : ĐƯỢC
```

⇒ **Một cột `role` cố định trên bảng nhân viên không diễn được luật này.** `role` trả lời *người
này là ai*; luật hỏi *người này đang đứng đâu, lúc này*. Hai câu khác nhau, và câu thứ hai đổi
nhiều lần trong một buổi sáng.

Hệ thống vì thế cần một khái niệm nữa: **ai đang trực trạm nào, tính tới lúc này**. Ba điều nó
phải làm được:

1. **Một người đang trực `quay`** ⇒ được duyệt, huỷ, thu tiền, hoàn tiền, ghi nợ.
2. **Chủ quán vào đứng quầy** ⇒ có quyền của trạm `quay`, **và vẫn giữ** quyền quản trị (§3, §1.3
   của `docs/product.md`) — hai vai cộng vào nhau, không thay thế nhau.
3. **Mỗi lần huỷ / hoàn / ghi nợ ghi lại người đang trực lúc đó**, không ghi chức vụ — để đối soát
   truy được về một người thật.

Bảng nhân viên trong `master_plan/prompt-fullstack.md` §3.5 chưa có khái niệm này; đó là một chỗ
thiếu đã biết, xem §8.

**Năm trạm, bốn vai người** (`shop-facts.md` §3): `quay` · `trang_banh` · `gap_banh` là ba trạm
riêng; `canh` + `don_ban` **chung một người**. Hệ thống không được giả định năm người.

---

## 5. Mặt BẾP — năm màn hình chỉ đọc

Mỗi trạm một màn. Việc sinh ra từ đơn **đã duyệt**, nổ theo thành phần (`shop-facts.md` §5.3), và
**không** trạm nào có nút báo xong (§1.1).

| Trạm | Màn hình cho thấy |
|---|---|
| `trang_banh` | bánh cuốn và trứng còn phải làm, tách theo loại trứng + nhân/lượng nhân, kèm bàn |
| `gap_banh` | bánh, trứng, giò cần gấp/xếp/cắt — thành phần **không nhận nhân** thì không kèm mô tả nhân |
| `canh` | nước chấm theo **đơn**, mọi đơn đều có (§6.6); đơn mang đi thì **gói riêng** |
| `don_ban` | bàn đã đóng phiên, chờ dọn — **màn duy nhất ở bếp có một thao tác**: bấm đã dọn |
| `quay` | xem §3 |

Ba luật hiển thị đã chốt ở `master_plan/prompt-fullstack.md` §3.7 và vẫn đúng: chữ to đọc được từ
xa · cũ nhất lên đầu · màu theo thời gian chờ. Nút `Xong` thì đã bị gỡ khỏi đó ngày 2026-08-31
(T-031); §3.7 nay nói thẳng ba màn trạm là **chỉ đọc** và thẻ tự biến mất khi POS ghi đã phục vụ
(§1.1, F-013 Fixed).

**Realtime không được là đường duy nhất** (`prompt-fullstack.md` §4 ràng buộc 9): màn trạm vẫn phải
tự lấy lại dữ liệu theo chu kỳ. Mất kết nối mà màn hình đứng im là bếp làm thiếu mà không ai biết.

---

## 6. Mặt CHỦ QUÁN — cấu hình, tiền, báo cáo

### 6.1 Menu và giá — sửa THÀNH PHẦN, không sửa giá suất

`shop-facts.md` §4.6 quy tắc 1: **giá một suất = tổng giá các thành phần**. Nên màn quản trị giá
phải cho sửa **giá thành phần** và bảng phụ thu; giá bốn suất bán là **kết quả tính ra**, không
phải bốn ô nhập tay.

Cho nhập tay giá suất là mở đường cho hai bảng giá lệch nhau — đúng họ lỗi `work/findings.md`
F-001, lần này nằm trong dữ liệu chứ không nằm trong tài liệu.

⇒ Màn đổi giá nên cho thấy **đổi một thành phần thì bốn suất thành bao nhiêu**, trước khi lưu.

**Đơn cũ không đổi giá.** Tên món và giá được chụp lại vào chi tiết đơn lúc đặt
(`prompt-fullstack.md` §4 ràng buộc 2, `docs/product.md` §3.3). Không chụp thì một lần tăng giá
làm sai mọi đơn cũ **và** mọi báo cáo đã in.

### 6.2 Tạm dừng nhận đơn

Nút này **thắng giờ mở cửa** (`shop-facts.md` §6.8) — dùng khi hết nguyên liệu giữa buổi. Thứ tự
chấm: đang tạm dừng ⇒ chặn; không tạm dừng ⇒ mới xét tới giờ bán.

### 6.3 Báo cáo doanh thu — cộng từ HAI nguồn

`shop-facts.md` §6.9: một khoản tiền gắn với **đúng một** đơn vị tính tiền — hoặc một phiên bàn,
hoặc một đơn lẻ, không bao giờ cả hai. ⇒ **Báo cáo phải cộng từ cả hai nguồn**; bỏ sót một nguồn
là báo cáo thiếu tiền. Ràng buộc này được database giữ (`prompt-fullstack.md` §3.5 chi tiết 6).

Hai chỗ dễ đếm sai:
- **Suất "đem về" của khách ngồi bàn** thuộc nguồn **phiên bàn**, không thuộc nguồn đơn lẻ (§6.15).
- **Một khoản nợ không phải tiền đã thu** (§6.14) — xem §7.

### 6.4 Đối soát cuối ngày — ngưỡng lệch là 0đ

`shop-facts.md` §6.10 gọi đây là **cổng chất lượng mạnh nhất của cả dự án, mạnh hơn mọi bài kiểm
thử**: mỗi tối đối chiếu doanh thu hệ thống với **sổ giấy** và **tiền trong két**; **lệch 1 đồng
cũng phải tìm ra lý do**.

Màn đối soát phải bày đủ để **tìm ra lý do**, không chỉ bày con số lệch. Chủ quán chốt 2026-08-31
(trả lời U-012, `shop-facts.md` §6.14): **doanh thu tính vào ngày GHI NỢ, không phải ngày thu được
tiền** — bữa ăn bán ngày nào thì doanh thu ngày ấy. Hệ quả là **nợ làm két lệch ở hai ngày khác
nhau, ngược chiều nhau**, và bảng đối soát phải bày cả hai:

```
tiền thực nhận trong ngày  ( mặt + chuyển khoản, đếm được trong két )
  =  doanh thu trong ngày          hoá đơn đóng hôm nay, kể cả hoá đơn ghi nợ
  −  nợ ghi trong ngày             đã tính doanh thu, CHƯA có tiền  ⇒ két thiếu
  +  nợ cũ thu được hôm nay        có tiền, doanh thu đã tính hôm TRƯỚC ⇒ két thừa
  −  hoàn tiền trong ngày          từng khoản có vết: ai, lý do (§6.4)
```

Ba luật của màn này:

1. **Dòng "nợ cũ thu được hôm nay" không bao giờ được cộng vào doanh thu hôm nay.** Cộng vào là
   **tính doanh thu hai lần** cho cùng một bữa ăn — nặng hơn quên thu, vì nó làm báo cáo trông
   đẹp hơn sự thật.
2. **Mỗi dòng trừ/cộng phải mở ra được thành danh sách từng khoản**, mỗi khoản có người đứng tên.
   Một con số tổng không giúp ai tìm ra lý do lúc lệch.
3. **Không có nút "đóng ca dù lệch".** Lệch mà vẫn đóng được thì luật ngưỡng 0đ chỉ là một câu chữ.

Khoản nợ có mục riêng ở cả ba tầng — xem §12.

---

## 7. Tiền — bốn đường, mỗi đường một vết

| Đường | Khi nào | Ai xác nhận |
|---|---|---|
| **Thu lúc trao hàng** — đường mặc định | ăn tại bàn: quầy, lúc đóng phiên · tới lấy: quầy · giao tận nơi: **tại chỗ khách** | người trao hàng bấm (§6.3) |
| **Trả trước** — tuỳ chọn, **chỉ đơn mang đi** | khách chọn lúc đặt | **POS xác nhận lúc nhận được tiền** (chủ quán chốt 2026-08-31, §6.3) |
| **Hoàn tiền** | quầy quyết từng ca, không có luật cứng | người đứng quầy, **bắt buộc để lại vết** (§6.4) |
| **Ghi nợ** | khách không trả được (§6.14) | POS, **bắt buộc ghi ai nợ + nợ bao nhiêu** |

Hai điều hệ thống **không** làm (`docs/product.md` §1.4):

- **Không tự biết tiền đã về tài khoản.** VietQR ở đây là mã **tĩnh** (§1), không sinh riêng cho
  từng hoá đơn ⇒ người ở quầy nhìn báo có rồi bấm. Đừng thiết kế như thể có webhook.
- **Không quyết định thay quầy việc hoàn tiền** — nó chỉ ghi lại quyết định đó.

**Ghi nợ phá tính ẩn danh của phiên bàn.** Bình thường phiên bàn ẩn danh theo số bàn (§2); ca ghi
nợ bắt buộc có tên hoặc cách gọi lại được. Đó là cái giá chủ quán đã chấp nhận (§6.14).

---

## 8. Sáu chỗ hình dạng dữ liệu hiện có chưa với tới

`master_plan/prompt-fullstack.md` §3.5 chốt **16 bảng, 4 nhóm**, và nó vẫn là nền đúng. Nhưng nó
được viết **trước** một loạt quyết định của chủ quán ngày 2026-08-30 và 2026-08-31, nên có sáu thứ
tài liệu này nêu ra mà nó chưa có chỗ để cất:

| Thiếu cái gì | Vì luật nào | Không có thì hỏng thế nào |
|---|---|---|
| **Vết hoàn tiền** — bao nhiêu · đơn nào · ai bấm · lý do | §6.4 | đối soát thấy két lệch, không ai truy được |
| **Khoản nợ** — ai nợ · bao nhiêu · phiên nào | §6.14 | đóng phiên xong khoản nợ vô chủ — hình dạng đầy đủ ở **§12.3** |
| **Vết thao tác chạm tiền / chạm trạng thái đơn** | §6.10 · `docs/product.md` §1.4 | *"lệch 1 đồng phải tìm ra lý do"* không thực hiện được |
| **Ai đang trực trạm nào, lúc này** | §6.13 (quyền gắn chỗ đứng) | quyền huỷ phải gán theo `role`, tức sai luật — §4 |
| **Note "đem về"** trên một suất của phiên bàn | §6.15 | khách mang về một đĩa không gói |
| **Đã phục vụ bao nhiêu cho từng bàn** | §5.4 | bảng quầy không hiện được *"còn thiếu gì"* |

Đây là **danh sách chỗ thiếu đã biết tính tới 2026-08-31**, không phải lời hứa là đã đủ. Gặp chỗ
thứ bảy thì thêm vào đây, đừng tự thiết kế quanh nó.

**Điều tài liệu này cố ý KHÔNG làm:** không đặt tên bảng, không đặt tên cột, không vẽ khoá ngoại.
Chốt lược đồ là việc của tầng System Design, và nó phải chạy sau khi §3.4 của `docs/product.md`
(BA-12) viết xong trục sản xuất bằng ngôn ngữ nghiệp vụ.

---

## 9. Invariant mà mặt admin phải giữ

Bốn invariant đã có ở `quality/invariants.md` (I-001–I-004) áp thẳng vào mặt admin: một bàn một
phiên chưa thanh toán · tính tiền theo phiên · bàn trống cần đóng phiên **và** dọn · đơn đã duyệt
sinh đủ việc, đơn chưa duyệt sinh không việc nào.

Trục sản xuất cần thêm ít nhất hai, và chúng thuộc **BA-12** chứ không thuộc task này — viết
invariant trước khi lát cắt nghiệp vụ định nghĩa hành vi là viết kết luận trước khi phân tích:

- Tổng nhu cầu một thành phần luôn **bằng** tổng phần chia về từng bàn.
- Số đã phục vụ của một bàn không bao giờ **vượt** số bàn đó đã gọi.

---

## 10. Ngoài phạm vi mặt admin

Không phải "chưa làm" — là **đã quyết định không làm**:

- **Bốn ranh giới ở `shop-facts.md` §6.12**: kênh bán thứ sáu · đơn tối thiểu và bậc phí ship ·
  số tài khoản cứng trong sản phẩm · món ngoài bảng giá. Thêm bất kỳ thứ nào là đổi phạm vi,
  quyền chủ quán.
- **Máy tự chia mẻ, tự xếp nồi, tự xếp thứ tự làm** — chủ quán chốt 2026-08-31: *"máy không làm,
  để người làm"* (§2).
- **Nút bấm báo xong ở ba trạm bếp** — chủ quán bỏ đi, 2026-08-31 (§1.1).
- **Hệ thống là chỗ dựa duy nhất để bán hàng.** Mất điện hay mất mạng thì quán chuyển sang **sổ
  giấy** và **không dừng bán** (`shop-facts.md` §6.11). Mặt admin phải chịu được việc một buổi
  sáng bị nhập bù sau.

**Một dòng đã RA khỏi mục này ngày 2026-09-02**, và mảng đó nay có **mục riêng: §14**.
*Nguyên liệu, tồn kho, chấm công, kế toán* từng đứng ở đây như một quyết định không làm; chủ quán
chốt **ngược lại** 2026-09-01, xác nhận lại 2026-09-02. Dòng ấy bị **xoá**, không phải chuyển chỗ —
mục này chỉ giữ những gì **vẫn** là *đã quyết định không làm*, và toàn bộ mảng quản trị đọc ở §14.

---

## 11. Câu chưa ai trả lời — đừng để mã tự quyết

**Cập nhật 2026-09-01 — S-4 đã có lời giải, và nó đổi số cột của §3.** Chủ quán trả lời: bánh gấp
xong **có nằm chờ** (chờ đủ đĩa · chờ người rảnh tay bưng · chờ món khác của cùng bàn), và **người
đứng quầy bấm** nút *"đã làm xong"* — `master_plan/shop-facts.md` §5.4, §7.1.

| Chỗ từng chưa chắc | Nay | Hệ quả cho tài liệu này |
|---|---|---|
| **S-4** — *"đã làm xong, còn ở bếp"* có phải một con số riêng | **có**, chủ quán 2026-09-01 | §3 — bảng quầy có **BỐN** con số, không phải ba |

⇒ **Phương án "ba con số" ở §3 hết đúng và phải viết lại.** Câu *"bảng quầy không biết khoảng chờ
giữa làm xong và ra bàn"* nay sai: nó **biết**, vì quầy bấm. Nút ấy nằm ở **quầy**, không ở bếp —
lời chốt U-009 (không có nút nào ở trạm bếp) vẫn nguyên vẹn, hai luật không mâu thuẫn.

⚠️ **Chưa viết được ngay khi tài liệu này ghi dòng trên** — `docs/product.md` → *Unknowns*
**U-017** lúc ấy còn mở: quầy bấm theo **từng cái**, theo **cả mẻ**, hay theo **cả bàn**?

*Cập nhật 2026-09-01 (T-037): **U-017 đã có lời giải — bấm theo MẺ*** (chủ quán chốt,
`master_plan/shop-facts.md` §5.4). §3 nay viết được đủ: **bốn** con số, và con số thứ tư nhảy
**theo bậc mẻ**, không nhảy từng đơn vị. Mẻ là đơn vị **bấm**, bàn vẫn là đơn vị **đếm** (§5.3).
Việc viết lại §3 vẫn là của T-036 — T-037 chỉ gỡ dòng chặn này, không viết hộ đặc tả.*

**Danh sách câu hỏi nghiệp vụ đang mở** (`docs/product.md` → *Unknowns*): cuối ngày 2026-09-01 nó
**rỗng trở lại** — U-014, U-015, U-016 (mốc đổi menu/giá), U-017 và U-018 đều đã đóng trong ngày.
Đọc ở owner, đừng tin con số trong câu này.

**Ba câu đã đóng ngày 2026-08-31**, đọc lại nếu thấy tài liệu nào còn ghi chúng là đang mở:

| Câu | Lời chốt | Ghi ở |
|---|---|---|
| U-006 | ghép bàn ⇒ **một phiên, một hoá đơn**; một phiên gắn nhiều bàn | `shop-facts.md` §6.16 |
| U-013 | **người đứng quầy bấm trên POS**; **chỉ ghép được khi bàn kia còn trống** ⇒ không bao giờ gộp hai hoá đơn | `shop-facts.md` §6.16 |
| U-012 | **POS ghi nhận** lúc trả nợ; doanh thu tính **ngày ghi nợ** | `shop-facts.md` §6.14 |

Chưa có lời giải thì phần liên quan viết theo **phương án hẹp nhất** và nói thẳng là đang treo.
Không tự chọn phương án rộng rồi ghi như đã chốt (`CLAUDE.md` §3.5).

---

## 12. Nợ — một phần riêng, có mục ở cả ba tầng

*Chủ repo yêu cầu 2026-08-31, sau khi chủ quán chốt **cho nợ** (`shop-facts.md` §6.14,
`docs/product.md` §3.1.6). Quyết định vì sao tách riêng: `docs/decisions.md` **ADR-012**.*

**Nợ không phải một cột trên phiên bàn.** Nếu chỉ thêm hai ô *"ai nợ / bao nhiêu"* vào lúc đóng
phiên thì khoản nợ chết ngay tại đó: không ai tra được hôm nay còn những ai nợ, không ai thu lại
được, và đối soát (§6.4) mãi mãi lệch. Khoản nợ có **vòng đời riêng** — sinh ra lúc đóng phiên,
sống qua nhiều ngày, kết thúc lúc người ta trả — trong khi phiên bàn thì đóng xong là hết. Hai
vòng đời khác nhau ⇒ hai phần khác nhau, đúng lý do §2 tách hai trục.

Nợ chạm **bốn** thứ đã chốt ở trên, nên nó không được thiết kế tách khỏi chúng: luật ghi (§1.1 —
POS ghi), quyền gắn chỗ đứng (§4), bốn đường tiền (§7), đối soát ngưỡng 0đ (§6.4).

### 12.1 Mặt FE — ba chỗ nợ hiện ra, và một chỗ nó không được hiện

| Mặt | Nợ hiện ra thế nào |
|---|---|
| **POS — lúc đóng phiên** | Đóng phiên mà tiền thu **ít hơn** tổng hoá đơn ⇒ hiện ô bắt buộc **ai nợ** + **nợ bao nhiêu**. Thiếu một trong hai thì **không đóng được phiên** (§9, I-005). Đây là chỗ duy nhất khoản nợ được sinh ra. |
| **POS — màn *Nợ* riêng** | Danh sách khoản nợ **chưa thu**: ai · bao nhiêu · từ phiên nào · ngày nào. Có thao tác **thu nợ**. Đây là màn mới, không nhét vào màn phiên bàn — phiên đã đóng rồi. |
| **Chủ quán — báo cáo và đối soát** | §6.3 cộng hai nguồn thì nay có thêm một dòng: **nợ ghi trong ngày** và **nợ thu được trong ngày**. §6.4 dùng đúng hai con số ấy để giải thích chỗ két lệch. |
| **Bếp** | **Không hiện gì.** Năm màn trạm là màn chỉ đọc về *việc phải làm* (§5); nợ là chuyện tiền, không phải chuyện bếp. |

**Ghi nợ là chỗ duy nhất phiên bàn phải hỏi danh tính.** Bình thường khách ăn tại bàn ẩn danh theo
số bàn (§2 `docs/product.md`); ô *"ai nợ"* phá điều đó, và nó **chỉ** được hỏi ở đúng ca này —
không được biến thành ô "tên khách" hiện ra ở mọi phiên.

### 12.2 Mặt BE — bốn luật, và ai được bấm

1. **Đóng phiên thiếu tiền ⇒ bắt buộc có chủ nợ và số tiền.** Ràng buộc này nằm ở BE, không nằm ở
   FE: FE ẩn nút chỉ là tiện tay, BE mới là chỗ chặn (§1.2).
2. **Nợ không phải tiền đã thu.** Số tiền nợ **không** được cộng vào tổng tiền mặt / chuyển khoản
   của ngày. Công thức §7 giữ nguyên: két thiếu đúng bằng tổng nợ ghi trong ngày.
3. **Mọi thao tác chạm nợ để lại vết** — ghi nợ, thu nợ, sửa số — kèm **người đang trực `quay`
   lúc đó**, không kèm chức vụ (§4). Nợ là việc chạm tiền thứ tư, cùng họ với duyệt · huỷ · hoàn
   (§3.3).
4. **Chỉ POS ghi** (§1.1). Không có đường nào khác tạo hay xoá một khoản nợ.

Hợp đồng API bổ sung, cùng họ với `/api/v1` đang có (`master_plan/prompt-fullstack.md` §3.6):

```
POST   staff/sessions/:id/close      body có { paid, debtor, debt_amount } khi thu thiếu
GET    staff/debts?status=open       danh sách nợ chưa thu — màn Nợ ở POS
POST   staff/debts/:id/collect       thu nợ; ghi vết người đang trực quay
GET    staff/reports/debts?date=     nợ ghi trong ngày · nợ thu trong ngày — cho §6.3, §6.4
```

### 12.3 Mặt DB — cất cái gì, và ràng buộc nào phải do database giữ

§8 liệt kê **Khoản nợ** là một trong sáu chỗ mô hình 16 bảng chưa với tới. Đây là hình dạng nhỏ
nhất đủ dùng, treo vào `table_sessions` đã có:

| Phải cất | Vì luật nào |
|---|---|
| Khoản nợ thuộc **đúng một** phiên bàn | §6.14 — nợ vô chủ thì đối soát không truy được |
| **Ai nợ** — tên hoặc cách gọi lại được | §6.14; đây là chỗ duy nhất phiên bàn bỏ ẩn danh |
| **Số tiền nợ** | §6.14 |
| **Lúc ghi nợ**: thời điểm + người đang trực `quay` | §4, §6.10 |
| **Lúc thu nợ**: thời điểm + người đang trực `quay` + phương thức (tiền mặt / VietQR) | §7 — thu nợ cũng là một đường tiền, phải có vết |
| Trạng thái: **chưa thu / đã thu** | màn *Nợ* ở POS lọc theo nó |

Ba ràng buộc để **database** giữ, không để mã ứng dụng giữ — cùng lý do `open_key` ở
`prompt-fullstack.md` §3.5 chi tiết 4:

- Một phiên bàn có **nhiều nhất một** khoản nợ chưa thu (`UNIQUE` trên khoá sinh theo trạng thái).
- Số tiền nợ **> 0**.
- Khoản nợ **không** được ghi vào bảng thanh toán như một khoản đã thu — `payments` giữ nguyên
  `CHECK` một-nguồn của nó (§3.5 chi tiết 6). **Việc thu nợ** thì mới sinh một dòng thanh toán.

**Cất cả hai mốc thời gian là bắt buộc, không còn là phòng xa.** Chủ quán chốt 2026-08-31
(U-012): doanh thu tính vào **ngày ghi nợ**. ⇒ Báo cáo doanh thu đọc mốc **ghi nợ**; đối soát tiền
mặt đọc mốc **thu nợ** (§6.4 cần cả hai dòng). Hai mốc phục vụ hai câu hỏi khác nhau, nên bỏ mốc
nào cũng làm hỏng một trong hai.

⚠️ **Mục 12.3 này cố ý vượt ranh giới §8 đặt ra** (*"không đặt tên bảng, không đặt tên cột"*), vì
chủ repo yêu cầu thẳng một mục DB cho phần nợ. Nó là **đề xuất gửi sang pha 2**, không phải lược
đồ đã chốt: tên bảng và tên cột do pha 2 đặt, và pha 2 được quyền đổi hình dạng miễn giữ đủ sáu
thứ phải cất và ba ràng buộc ở trên.

### 12.4 U-012 đã đóng — và phương án hẹp hoá ra đúng

**Chủ quán chốt cả hai vế còn lại ngày 2026-08-31** (`shop-facts.md` §6.14):

| Vế | Lời chốt |
|---|---|
| Ai ghi nhận lúc người nợ quay lại trả | **POS** |
| Doanh thu tính ngày nào | **ngày GHI NỢ**, không phải ngày thu được tiền |

Vế thứ nhất **trùng** với phương án hẹp §12.2 đã chọn (người đang trực `quay` bấm) — nên không
phải sửa gì, và dòng cảnh báo *"đây là suy ra, không phải lời chủ quán"* nay gỡ được: nó đã thành
lời chủ quán. Ghi lại việc này vì nó là **bằng chứng cho luật chọn hẹp**: chọn hẹp thì lúc có lời
giải hoặc là đúng sẵn, hoặc là sửa một chỗ; chọn rộng thì sửa cả một nhánh.

Vế thứ hai **đổi hình dạng của đối soát**, không đổi mục này: doanh thu tính ngày ghi nợ nghĩa là
két lệch ở **hai** ngày ngược chiều nhau — công thức đầy đủ ở §6.4. Một lần trả nợ **không bao giờ
được ghi thành một khoản bán mới**; ghi vậy là tính doanh thu hai lần cho cùng một bữa ăn.

**Không còn gì treo ở mục nợ.**

---

## 13. Đọc gì tiếp

| Muốn biết | Đọc |
|---|---|
| Dữ kiện quán — giá, giờ, bàn, nồi, quy tắc | `master_plan/shop-facts.md` |
| Hành vi nghiệp vụ đã chốt | `docs/product.md` |
| Stack, 16 bảng, API, route | `master_plan/prompt-fullstack.md` §3.4–§3.7 |
| Vì sao hai trục | `docs/decisions.md` ADR-009 |
| Vì sao ba mặt một miền, và vì sao chỉ POS ghi | `docs/decisions.md` ADR-011 |
| Vì sao nợ là một phần riêng, không phải một cột | `docs/decisions.md` ADR-012 · **§12** |
| Trục sản xuất bằng ngôn ngữ nghiệp vụ | `work/backlog.md` BA-12 — **chưa viết** |
| **Mảng quản trị (admin)** — nguyên liệu, con người, tài chính | **§14** · `docs/product.md` §1.6 · `master_plan/shop-facts.md` §8 |
| Bản tư vấn ngoài, **không phải sự thật** | `work/proposals/admin.admiadmin/admin1.md` |

---

## 14. Mảng QUẢN TRỊ (admin) — nguyên liệu · con người · tài chính

⚠️ **"Mảng admin" ở mục này KHÁC "mặt admin" ở §9 và §10.** Tiêu đề của cả tài liệu — *mặt quản
trị* — nói về **toàn bộ** hệ thống nhìn từ ba chỗ đứng (§1); đó là nghĩa của chữ *admin* ở §9 và
§10. Chữ **mảng admin** ở mục này hẹp hơn hẳn: đúng **ba mảng nghiệp vụ** nguyên liệu · con người ·
tài chính, theo cách `work/admin-questions.md` gọi tên chúng. Đọc nhầm hai chữ này là đọc nhầm phạm
vi của cả mục.

**Mục này là chỗ duy nhất của tài liệu này nói về ba mảng đó.** §1–§13 mô tả kiến trúc của mảng
**bán hàng** — ba mặt, hai trục, phiên bàn, tiền, nợ. Mục này là mảng **chạy quán**. Hai mảng đứng
riêng vì chúng đổi vì hai lý do khác nhau; ai viết mảng này thì viết vào đây, không chèn vào mục
của mảng kia.

### 14.1 Ranh giới — ba mảng nằm TRONG phạm vi

**Chủ quán chốt 2026-09-01, xác nhận lại 2026-09-02:** nguyên liệu · con người · tài chính vào
phạm vi. Trước đó §10 xếp *"nguyên liệu, tồn kho, chấm công, kế toán"* vào **đã quyết định không
làm**; dòng ấy đã bị xoá. Hành vi nghiệp vụ tương ứng ở `docs/product.md` §1.6; dữ kiện quán ở
`master_plan/shop-facts.md` §8.

### 14.2 Hôm nay mục này CHƯA có thiết kế nào

Mở ranh giới **không** sinh ra kiến trúc. Tính tới 2026-09-02, tài liệu này chưa có cho ba mảng ấy:

- không mặt nào trong §1 (*Một hệ thống, ba mặt*) được giao thêm việc — POS, BẾP và CHỦ QUÁN vẫn
  đúng những màn đã tả;
- không trục thứ ba nào ở §2 — hai trục *đơn* và *nhu cầu sản xuất* vẫn là tất cả;
- không hình dạng dữ liệu nào; §8 (*Sáu chỗ hình dạng dữ liệu hiện có chưa với tới*) giữ nguyên
  danh sách của nó, không cộng thêm chỗ thiếu nào vì lời chốt này.

⚠️ **Đừng đọc mục này thành lời cho phép thiết kế.** *Được phép làm* là câu của mục này; *làm ngay
bây giờ* là câu của `docs/product.md` §7 (BA-09). Ai dựng bảng, dựng màn hay chọn tầng cho ba mảng
này trước khi §7 chốt là đang tự quyết phạm vi MVP.

### 14.3 Chỗ mảng admin CHẠM vào mảng bán hàng — bốn chỗ đã biết

Tách mục không có nghĩa hai mảng không dính nhau. Bốn chỗ dưới đây là nơi chúng gặp nhau, và cả
bốn **chưa có luật**:

| Chỗ chạm | Vì sao nó là chỗ chạm |
|---|---|
| Hết nguyên liệu → **tạm dừng nhận đơn** | nút tạm dừng đã có ở §6.2; ai bấm và bấm theo cái gì thì chưa |
| **Ai đang trực trạm nào** → quyền huỷ đơn / hoàn tiền | §4 nói quyền gắn **chỗ đứng**, mà không dữ liệu nào ghi ai đang đứng đâu (§8 chỗ thiếu) |
| **Sổ chi** → báo cáo lãi lỗ | §6.3 mới cộng doanh thu; chi phí chưa có ở đâu |
| **Quỹ tiền mặt** → đối soát cuối ngày | §6.4 chốt ngưỡng lệch 0đ; tiền đầu buổi và tiền nộp về chưa nằm trong phép tính đó |

Bốn chỗ này là lý do mảng admin **không** thể thiết kế tách rời mảng bán hàng, dù nó được viết ở
mục riêng. Mục riêng là để **đọc** không lẫn, không phải để **thiết kế** không nhìn nhau.

