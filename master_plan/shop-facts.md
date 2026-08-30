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
đơn vị thanh toán độc lập" ở trên. Tiền chưa bao giờ thu trước (§6.3) nên huỷ đơn đặt trước **không
sinh việc hoàn tiền**.

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

- **Thu tiền lúc TRAO HÀNG, không bao giờ thu trước.** Tiền mặt hoặc VietQR, khách chọn.
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
   phải ở quầy. Luồng tại bàn luôn thu ở quầy lúc đóng phiên.
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

## 6. Mười ba quy tắc nghiệp vụ phải đúng

1. **Khách gọi thêm khi quầy đã bắt đầu thu tiền vẫn thuộc CÙNG phiên, CÙNG một hoá đơn.** Phiên
   ở trạng thái "chờ thanh toán" **chưa** giải phóng bàn. Tách ra hoá đơn thứ hai ⇒ **thu thiếu
   tiền** — đây là lỗi tiền nguy hiểm nhất của luồng tại bàn.
2. **Đơn do KHÁCH tự gửi phải được quầy duyệt trước khi xuống bếp; đơn do NHÂN VIÊN nhập thì
   không.** Phải duyệt: `qr_table`, `delivery`, `pickup`. Không cần duyệt: `staff_pos`,
   `phone_preorder`. Lý do là mục đích của bước duyệt — chặn đơn ảo — chỉ có nghĩa với đơn không
   ai chịu trách nhiệm. Đơn chưa duyệt **không sinh việc ở bất kỳ trạm nào**.
3. **Thu tiền lúc trao hàng, không bao giờ thu trước.** Ăn tại bàn: thu ở quầy lúc đóng phiên.
   Tới lấy: thu ở quầy lúc khách tới. Giao tận nơi: thu **tại chỗ khách**, lúc đưa hàng. Cả ba
   trường hợp khách đều được chọn **tiền mặt hoặc VietQR**.
4. **Hoàn tiền: có, nhưng không có luật cứng — người ở quầy quyết định từng trường hợp** (chủ quán
   chốt 2026-08-30). Không phải mọi ca đều được hoàn, và cũng không cấm hoàn; quầy nhìn tình huống
   thật rồi quyết.
   ⇒ Chính vì **không có luật cứng nên mọi lần hoàn phải để lại vết**: hoàn bao nhiêu, cho đơn nào,
   ai bấm, lý do gì. **Người đứng quầy là người làm việc ghi vết đó** (chủ quán xác nhận
   2026-08-30) — cùng một người vừa quyết vừa ghi, nên không có ca nào hoàn tiền mà không ai đứng
   tên. Không có vết thì đối soát cuối ngày (§6.10) sẽ lệch mà không ai truy được — mà
   luật đối soát nói *lệch 1 đồng cũng phải tìm ra lý do*.
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
8. **Nút "Tạm dừng nhận đơn" của chủ quán có ưu tiên CAO HƠN giờ mở cửa** — dùng khi hết nguyên
   liệu giữa buổi. Ngoài giờ bán, web khoá nút đặt và hiện *"Quán mở cửa 6h–11h sáng"*.
9. **Một khoản tiền gắn với đúng MỘT đơn vị tính tiền** — hoặc một phiên bàn, hoặc một đơn lẻ,
   không bao giờ cả hai. ⇒ **báo cáo doanh thu phải cộng từ CẢ HAI nguồn**; bỏ sót một nguồn là
   báo cáo thiếu tiền.
10. **Đối soát cuối ngày.** Trong 2 tuần đầu chạy thật, mỗi tối đối chiếu doanh thu hệ thống với
    **sổ giấy** và **tiền trong két**. **Lệch 1 đồng cũng phải tìm ra lý do.** Đây là cổng chất
    lượng mạnh nhất của cả dự án, mạnh hơn mọi bài kiểm thử.
11. **Sổ giấy là kế hoạch dự phòng BẮT BUỘC.** Mất điện, mất mạng, hoặc máy hỏng ⇒ quán chuyển sang
    ghi tay và **không dừng bán**.
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

## 7. Nhật ký chốt

**Tính tới 2026-08-30, không còn câu hỏi nào treo, và cũng không còn chỗ suy ra nào chưa xác
nhận.** Bảng giá đã đầy, cả năm kênh đều có luồng, ba mục suy luận S-1–S-3 đã được chủ quán trả
lời thẳng (§7.1, ba dòng đánh dấu *xác nhận S-*). Mục này giữ lại **ai chốt cái gì, ngày nào**, để phiên sau
muốn lật lại một quyết định thì biết đang lật lại điều gì.

### 7.1 Chủ quán đã chốt những gì

| Ngày | Chốt cái gì | Ghi ở |
|---|---|---|
| 2026-08-19 | Thành phần bếp làm ra của cả bốn suất bán | §4.5 |
| 2026-08-24 | Đơn hotline đi bằng kênh riêng, không gắn bàn | §2 |
| 2026-08-29 | Sửa: kênh đó tên `phone_preorder`, và **`staff_pos` không dùng cho đơn hotline** | §2 |
| 2026-08-29 | Suất giò = 9.000 + tiền 4 cái bánh; bánh trong suất giò **có** nhận nhân | §4.3 · §4.5 |
| 2026-08-30 | **Suất trứng = giá trứng + tiền 4 cái bánh**, cộng gộp thành phần như suất giò | §4.3 |
| 2026-08-30 | Thu tiền **lúc trao hàng**, tiền mặt hoặc VietQR — không thu trước | §6.3 |
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

### 7.2 Chỗ suy ra chưa xác nhận — **hiện không còn mục nào**

Mục này từng giữ ba chỗ được **suy ra** từ luật đã chốt chứ không phải lời chủ quán nói thẳng:
**S-1** (phụ thu suất trứng ×5 hay ×4) · **S-2** (hai trường liên hệ bắt buộc) · **S-3** (hoàn tiền
phải ghi vết, ai ghi). Ngày **2026-08-30** chủ quán trả lời thẳng cả ba, đúng như đang ghi trong
tài liệu; chúng đã chuyển lên §7.1 và **không còn là suy luận**.

Riêng S-1 — chỗ chạm tiền — được hỏi bằng đúng câu kiểm chứng đã soạn sẵn: *"Suất trứng nhân
thường là 25.000 hay 24.000?"* Trả lời: **25.000**, tức quả trứng cũng lên giá theo mức nhân. Bảng
giá §4.3 không phải sửa một con số nào; thứ thay đổi là **trạng thái** của con số đó, từ suy luận
thành đã chốt.

Mục này để trống có chủ đích, **không xoá**: chỗ suy ra tiếp theo phải nằm ở đây, tách khỏi §7.1
(`work/findings.md` F-004). Thấy một dòng nào trong repo còn nói "ba chỗ suy luận chưa ai xác nhận"
⇒ đó là pointer cũ, sửa đi.

### 7.3 Quy tắc cho phiên sau

Khi chủ quán chốt thêm điều gì: ghi vào đúng mục nghiệp vụ (§1–§6) **trước**, rồi thêm một dòng vào
bảng §7.1 với ngày. Đừng để một quyết định chỉ sống ở §7 — mục này là nhật ký, không phải nơi tra
cứu quy tắc.

Nếu một mục ở §7.2 được chủ quán xác nhận hoặc bác bỏ, chuyển nó lên §7.1 kèm ngày và xoá khỏi
§7.2 — **và trong cùng lần sửa đó, `grep -rn` cả repo tìm những chỗ đang nói mục ấy "chưa xác
nhận" rồi sửa nốt.** Một mục chỉ được nằm ở §7.2 chừng nào **chưa ai hỏi**. Cả ba mục đầu tiên
(S-1, S-2, S-3) đã đi qua đúng đường này ngày 2026-08-30.
