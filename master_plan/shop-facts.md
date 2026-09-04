# Bánh cuốn Bà Thanh Cao Bằng — dữ kiện quán

> **Đây là nhà duy nhất của mọi dữ kiện về quán** — phạm vi bán, kênh bán, bảng giá, phụ thu,
> thành phần suất bán, luồng vận hành, quy tắc nghiệp vụ. Chỗ nào khác trong dự án nói khác file
> này ⇒ **file này thắng**, chỗ kia là bug phải sửa ngay. Không có bản chép thứ hai của bất kỳ
> con số nào; đổi giá thì sửa đúng một chỗ, là đây.
>
> **File này tự đứng một mình.** Ai chưa từng biết quán, đọc hết file này là nắm được: quán bán
> gì, bán cho ai qua đường nào, giá bao nhiêu, bếp làm ra cái gì, và tiền đi đường nào từ lúc
> khách gọi tới lúc bàn trống. Không cần mở thêm tài liệu nào khác, và file này cũng không trỏ
> đi đâu — nó là điểm cuối.
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
| Số bàn | **11** |
| Thanh toán | Tiền mặt tại quầy · Chuyển khoản **VietQR tĩnh** |

**VietQR tĩnh nghĩa là mã cố định** — không phải mã sinh riêng cho từng hoá đơn. Hệ quả: hệ thống
**không tự biết tiền đã về tài khoản**; người ở quầy phải tự nhìn báo có rồi bấm xác nhận đã nhận
tiền. Số tài khoản do chủ quán nhập sau trong phần quản trị, không phải thứ cần biết trước để bắt
đầu làm.

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

Giò **không nhận nhân** nên một giá cho cả ba cột.

### 4.3 Giá một SUẤT BÁN — tính từ bảng §4.2

| Suất bán | Cách tính | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Suất bánh cuốn | 1 bánh | 3.000 | 4.000 | 5.000 |
| **Suất giò** | 1 giò + 4 bánh | **21.000** | **25.000** | **29.000** |
| Combo "Đầy đủ" trứng chín / tái / vàng | 3 bánh + 1 trứng + 1 giò | 26.000 | **30.000** | 34.000 |
| **Suất trứng** chín / tái / vàng | 1 trứng + 4 bánh | **20.000** | **25.000** | **30.000** |

**Suất giò, chủ quán chốt 2026-08-29:** *"1 cái giò là 9.000, tính thêm tiền số lượng bánh là ra
số tiền của suất"* ⇒ 9.000 + 4 × giá bánh theo nhân đã chọn.

**Suất trứng, chủ quán chốt 2026-08-30:** gồm 1 quả trứng + 4 cái bánh cuốn, **cộng gộp tiền
thành phần** như suất giò, bánh tính theo mức nhân đã chọn ⇒ giá trứng + 4 × giá bánh.
**Quả trứng cũng lên giá theo mức nhân đã chọn** (chủ quán xác nhận 2026-08-30, trả lời thẳng câu
hỏi *"suất trứng nhân thường là 25.000 hay 24.000"* ⇒ **25.000**). Nên phụ thu suất trứng là **×5**,
không phải ×4 — xem §4.6 luật 5. Đây **không còn là suy luận**.
Đây là ô cuối cùng còn trống của bảng giá; **từ 2026-08-30 bảng giá đã đầy, không còn ô ⚠ nào.**

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

Đây là thứ **bếp làm ra**, khác với thứ khách trả tiền. Bốn suất bán, và mỗi suất bếp làm ra
**nhiều thứ hơn tên món**:

| Suất bán | Bếp làm ra | Phần **nhận** tuỳ chọn nhân |
|---|---|---|
| Suất **bánh cuốn** | 1 cái bánh cuốn | cái bánh đó |
| Suất **trứng** (chín / tái / vàng) | **1 quả trứng + 4 cái bánh cuốn** | 4 cái bánh **và** quả trứng |
| Suất **giò** | **1 chiếc giò + 4 cái bánh cuốn** | 4 cái bánh (giò **không** nhận nhân) |
| **Combo "Đầy đủ"** | **3 cái bánh cuốn + 1 quả trứng + 1 chiếc giò** | 3 cái bánh **và** quả trứng |

Khách gọi "1 suất trứng" thì bếp làm **5 thứ**, không phải 1. Đây là chỗ hay bị làm thiếu nhất.

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

**Cả mười ca có số (1–10) đều tính được và đã đối chiếu khớp bảng giá §4.3** — từ 2026-08-30 không
còn ca nào treo. Ca 11 là ca duy nhất có kết quả không phải một con số. Mười một ca này là **hợp
đồng với chủ quán**: đủ mười một mới được coi là tính giá đúng.

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

Khách gọi **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**:

```
Khách trả tiền theo: [Đầy đủ trứng tái ×2 — Thịt+mộc nhĩ, Nhiều nhân — 34.000 × 2 = 68.000]
                                                          ↑ 1 dòng trên hoá đơn

Bếp phải thấy:
  trang_banh │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  trang_banh │ Trứng tái ×2 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Trứng tái ×2
  gap_banh   │ Giò ×2                    ← thành phần không nhận nhân thì KHÔNG kèm mô tả nhân
  canh       │ Nước chấm — bàn 5, 2 suất ← việc cấp ĐƠN, MỌI đơn đều có,
                                            đơn mang đi thì gói riêng thay vì bưng ra bàn
```

Số lượng = `số suất × số thành phần trong suất` (§4.5: combo = 3 bánh ⇒ 2 combo = 6 bánh).
**Bếp không bao giờ được thấy một dòng "Combo ×2" mơ hồ** — nhìn dòng đó thì không ai biết phải
tráng mấy cái bánh.

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

## 6. Hai mươi hai quy tắc nghiệp vụ phải đúng

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
    lời U-006). Ghép bàn là chuyện có thật ở quán, không phải ca hiếm — quán có 11 bàn (§1) và
    nhóm đông thì ngồi tràn sang bàn bên.
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

## 7. Nhật ký chốt

**Tính tới 2026-09-01 §7.2 giữ đúng MỘT chỗ suy ra chưa xác nhận — S-5.** Bảng giá đã đầy, cả
năm kênh đều có luồng, ba mục suy luận S-1–S-3 đã được chủ quán trả lời thẳng ngày 2026-08-30
(§7.1, ba dòng đánh dấu *xác nhận S-*), và **S-4** — chỗ suy ra sinh ngày 2026-08-31 từ lời chủ
quán về cách bếp gom việc (§5.4) — đã được trả lời ngày **2026-09-01**. Cùng ngày, lời chốt cho
U-021 đẻ ra **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị nào), nên mục §7.2 lại có một dòng. Mục này
giữ lại **ai chốt cái gì, ngày nào**, để phiên sau muốn lật lại một quyết định thì biết đang lật
lại điều gì.

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
| 2026-09-04 | **Mảng nguyên liệu làm ở mức SỔ GHI TAY ĐIỆN TỬ** — máy **không** tự trừ tồn theo công thức, nên phần mềm không cần định lượng từng thành phần; kèm **một mục tổng nhập hàng ngày, chủ quán tự nhập số liệu** | **§8.4** |

### 7.2 Chỗ suy ra chưa xác nhận — **một mục, tính tới 2026-09-01**

Mục này giữ những chỗ được **suy ra** từ luật đã chốt chứ không phải lời chủ quán nói thẳng. Bốn
mục S-1–S-4 từng nằm đây đều đã được chủ quán xác nhận và đã lên §7.1; **S-5 mở ngày 2026-09-01**
(T-039) và là mục duy nhất còn chưa xác nhận.

| Chỗ suy ra | Hỏi ngày | Lời giải | Nay ở |
|---|---|---|---|
| **S-1** — phụ thu suất trứng ×5 hay ×4 | 2026-08-30 | **×5**, suất trứng nhân thường = 25.000 | §4.3 · §4.6 |
| **S-2** — hai trường liên hệ bắt buộc | 2026-08-30 | **đúng**, số điện thoại và địa chỉ giao | §6.5 |
| **S-3** — hoàn tiền phải ghi vết, ai ghi | 2026-08-30 | **người đứng quầy** vừa quyết vừa ghi | §6.4 |
| **S-4** — *"đã làm xong, còn ở bếp"* có phải một con số riêng | 2026-08-31 (hỏng) → **2026-09-01** | **có** — bánh nằm chờ thật; bảng quầy **bốn** con số, **người đứng quầy bấm** | §5.4 |
| **S-5** — *"đã bưng ra bàn"* bấm theo **đơn vị nào** | **2026-09-01**, chưa hỏi | *suy ra:* theo **bàn**, không theo mẻ — một mẻ phục vụ nhiều bàn (§5.4), còn bưng thì bưng tới **một** bàn. Chủ quán mới chỉ nói **ai** bấm, chưa nói **theo gì** | §5.4 · **BA-12** cần trước khi dựng bảng quầy |

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
mảng **nguyên liệu** có mức sâu của nó (§8.4); **hai mảng còn lại — con người và tài chính — vẫn
đúng như đoạn dưới đây tả**, và đoạn ấy đọc cho hai mảng đó, không đọc cho mảng nguyên liệu:

- **Mức sâu: mảng nguyên liệu ĐÃ chốt, hai mảng kia thì chưa.** Mảng nguyên liệu làm ở mức *sổ ghi
  tay điện tử* — lời chốt và ranh giới của nó ở **§8.4**. Mảng con người làm tới đâu, mảng tài
  chính làm tới đâu — chưa có dòng nào trong tài liệu này trả lời, nên đừng suy ra hộ.
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

**Điều KHÔNG được nói, và đừng suy hộ:** *"số liệu"* ấy là con số gì — đồ **còn lại** cuối buổi,
đồ **mua vào** trong ngày, hay đồ **đã dùng** — và mục tổng ấy ghi những thứ nào, theo đơn vị nào.
Ba đường ấy dẫn tới ba cách ghi khác nhau và chỉ chủ quán trả lời được ⇒ **U-034**
(`docs/product/99-unknowns.md`). Ai dựng mục này trước khi U-034 có lời giải là tự quyết thay chủ
quán (`CLAUDE.md` §3.5).

**Ba ranh giới của chính §8.4:**

- **Chốt *cách ghi*, không chốt *ghi cái gì*.** Danh mục nguyên liệu, đơn vị tính, ngưỡng nhắc sắp
  hết — cả ba vẫn chưa có dữ kiện nào, đúng như §8.2 nói.
- **Không nói mảng này có vào bản chạy đầu tiên hay không.** Đó là câu của
  `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7, và câu ấy đã chốt riêng ngày 2026-09-02
  (U-030): **không** mảng quản trị nào phải chạy cùng bản bán hàng đầu tiên.
- **Mở lại được, và có đúng một cửa để mở.** Muốn biết **giá vốn một suất** thì phải chốt định
  lượng từng thành phần, tức lật ngược mức sổ tay ở trên. Hôm nay chưa ai hỏi câu ấy
  (`work/admin-questions.md` câu **B22**); hỏi rồi mà chủ quán trả lời *"có"* thì mục này phải
  viết lại, không phải viết thêm.
