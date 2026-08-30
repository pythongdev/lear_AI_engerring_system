# Bánh cuốn Bà Thanh Cao Bằng — dữ kiện quán

> **File này tự đứng một mình.** Ai chưa từng biết quán, đọc hết file này là nắm được: quán bán
> gì, bán cho ai qua đường nào, giá bao nhiêu, bếp làm ra cái gì, và tiền đi đường nào từ lúc
> khách gọi tới lúc bàn trống. Không cần mở thêm tài liệu nào khác.
>
> ⚠️ **Cảnh báo bảo trì.** Bảng giá ở §4 là bản chép; trong dự án còn một bản nữa của đúng những
> con số này. **Đổi giá thì phải đổi cả hai chỗ trong cùng một lần sửa.** Hai bản lệch nhau nghĩa
> là quán đang thu sai tiền ở một trong hai chỗ, và không ai biết chỗ nào.

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

**Định danh khách:** hai kênh gắn bàn là **ẩn danh theo bàn** — quán chỉ cần biết "bàn 5", không
cần biết tên ai. Ba kênh còn lại phải có thông tin để gọi lại được (mức tối thiểu là bao nhiêu thì
chưa chốt — xem §7).

## 3. Năm trạm làm việc

| Trạm | Làm gì |
|---|---|
| `quay` — quầy | Nhận và xác nhận đơn, đặt hộ, thu tiền, đóng phiên |
| `trang_banh` — tráng bánh | Tráng bánh, làm trứng |
| `gap_banh` — gấp bánh | Gấp bánh, xếp đĩa, cắt giò |
| `canh` — lấy canh | Nước chấm, canh |
| `don_ban` — dọn bàn | Dọn bàn sau khi phiên đã đóng |

Chủ quán (`owner`) là một vai riêng, **ngoài** năm trạm trên.

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
| Suất trứng chín / tái / vàng | 1 trứng + 4 bánh | ⚠ chưa chốt | ⚠ chưa chốt | ⚠ chưa chốt |

**Suất giò, chủ quán chốt 2026-08-29:** *"1 cái giò là 9.000, tính thêm tiền số lượng bánh là ra
số tiền của suất"* ⇒ 9.000 + 4 × giá bánh theo nhân đã chọn.

**Suất trứng chưa có giá** — đây là ô duy nhất còn trống trong toàn bộ bảng giá, và nó chạm tiền.
Xem §7.

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
| Suất trứng | 5 (bốn cái bánh + quả trứng) | ⚠ chưa chốt — §7 |

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
   ×4 — ba con số này là **hệ quả** của luật 1, không phải ba con số rời cần nhớ thuộc lòng.
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
| 5 | Suất trứng chín | Chay | — | ⚠ **chưa chốt** | §7 |
| 6 | Suất trứng tái | Thịt + mộc nhĩ | Thường | ⚠ **chưa chốt** | §7 |
| 7 | Suất trứng vàng | Thịt | Nhiều | ⚠ **chưa chốt** | §7 |
| 8 | Suất giò | Thịt | Nhiều | **29.000** | 9.000 + 4 × 5.000; giò không nhận nhân, bánh thì có |
| 9 | Combo Đầy đủ chín | Thịt | Thường | **30.000** | combo: phụ thu ×4 |
| 10 | Combo Đầy đủ tái | Thịt + mộc nhĩ | Nhiều | **34.000** | |
| 11 | Bánh cuốn | Chay | Nhiều | **PHẢI BỊ TỪ CHỐI** | không phải một giá, mà là luật ở §4.6.3 |

Tám ca có số (1–4, 8–10) đã đối chiếu khớp bảng giá §4.3. **Ba ca 5–7 chưa tính được** vì giá suất
trứng chưa chốt — chúng chính là ô trống ở §7, không phải ca cần thêm sau. Ca 11 là ca duy nhất có
kết quả không phải một con số.

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

## 6. Mười quy tắc nghiệp vụ phải đúng

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
4. **Mọi đơn đều có nước chấm — kể cả đơn mang đi.** Trạm `canh` sinh việc cho **mọi** đơn, không
   riêng đơn tại bàn; đơn mang đi thì gói riêng. Bỏ sót là khách nhận bánh không có nước chấm.
5. **Quán tự đi giao, và đơn giao tận nơi mang trạng thái "đang giao".** Quầy phải nhìn được đơn
   nào còn trên đường và ai đang cầm tiền chưa về. Giao xong bấm **đã giao + đã thu tiền** cùng lúc.
6. **Nút "Tạm dừng nhận đơn" của chủ quán có ưu tiên CAO HƠN giờ mở cửa** — dùng khi hết nguyên
   liệu giữa buổi. Ngoài giờ bán, web khoá nút đặt và hiện *"Quán mở cửa 6h–11h sáng"*.
7. **Một khoản tiền gắn với đúng MỘT đơn vị tính tiền** — hoặc một phiên bàn, hoặc một đơn lẻ,
   không bao giờ cả hai. ⇒ **báo cáo doanh thu phải cộng từ CẢ HAI nguồn**; bỏ sót một nguồn là
   báo cáo thiếu tiền.
8. **Đối soát cuối ngày.** Trong 2 tuần đầu chạy thật, mỗi tối đối chiếu doanh thu hệ thống với
   **sổ giấy** và **tiền trong két**. **Lệch 1 đồng cũng phải tìm ra lý do.** Đây là cổng chất
   lượng mạnh nhất của cả dự án, mạnh hơn mọi bài kiểm thử.
9. **Sổ giấy là kế hoạch dự phòng BẮT BUỘC.** Mất điện, mất mạng, hoặc máy hỏng ⇒ quán chuyển sang
   ghi tay và **không dừng bán**.
10. **Bốn ranh giới đã chốt — đây là quyết định, không phải chỗ trống chờ ai điền:**

    | Không làm | Vì sao |
    |---|---|
    | Kênh bán **thứ sáu** | §2 chốt đúng năm kênh |
    | Đơn tối thiểu, bậc phí ship | ship 0đ và không đơn tối thiểu là chốt |
    | Số tài khoản ngân hàng cứng trong sản phẩm | §1 chốt là nhập trong phần quản trị |
    | Món ngoài bảng giá §4.2 | thêm món là đổi phạm vi |

    Thêm bất kỳ thứ nào trong bốn thứ trên là **đổi phạm vi, quyền chủ quán**.

## 7. Ba điều chủ quán chưa chốt

**Đã gỡ ngày 2026-08-29:**
- ~~Đơn đặt trước qua hotline gắn vào bàn nào~~ → **kênh riêng `phone_preorder`, không gắn bàn**.
- ~~Suất giò có nhận tuỳ chọn nhân không~~ → **có**: 9.000 + tiền 4 cái bánh theo nhân đã chọn.

**Đã gỡ ngày 2026-08-30** (năm câu về luồng mang đi):
- ~~Đơn giao hàng thu tiền lúc nào~~ → **lúc trao hàng cho khách**, tiền mặt hoặc VietQR (§6.3).
- ~~Ai đi giao~~ → **quán tự đi giao**, và đơn giao có trạng thái **"đang giao"** (§6.5).
- ~~Đơn web có cần quầy duyệt như đơn QR không~~ → **có** (§6.2).
- ~~Đơn mang đi có nước chấm không~~ → **có, gói riêng** (§6.4).
- ~~`phone_preorder` kết thúc thế nào~~ → **cả hai kiểu**; nhân viên hỏi khách giao tận nơi hay
  tới lấy khi nhận điện thoại (§5.2).

Còn lại ba câu, câu đầu chạm tiền:

| # | Câu hỏi | Vì sao chưa trả lời được | Hỏng thì mất gì |
|---|---|---|---|
| **1** | **Một suất trứng đứng riêng giá bao nhiêu?** | Suất trứng có cùng hình dạng với suất giò (1 trứng + 4 bánh) nhưng chủ quán mới chỉ nói về giò | Hai cách hiểu lệch nhau **12.000–20.000đ mỗi suất**. Xem bảng dưới |
| 2 | Có hoàn tiền không, ai được phép hoàn? | chưa ai hỏi chủ quán | Không có đường xử lý khi khách trả món |
| 3 | Ba kênh không gắn bàn cần tối thiểu những thông tin liên hệ gì? | chỉ biết là phải gọi lại được, chưa biết gồm những gì | Nhận đơn xong không liên lạc được với khách |

**Chi tiết câu 1 — giá suất trứng:**

| Cách hiểu | Suất trứng (chay / thường / nhiều) | Hậu quả nếu chọn sai |
|---|---|---|
| **A** — cùng mô hình tổng thành phần như suất giò | 20.000 / 25.000 / 30.000 | — |
| **B** — 8.000 / 9.000 / 10.000 đã là giá cả suất | 8.000 / 9.000 / 10.000 | **Thu thiếu 12.000–20.000đ mỗi suất trứng** |

Cách A khớp với mô hình đã tái tạo đúng cả ba ô combo ở §4.7. Cách B khớp với việc bảng §4.2 trước
đây từng bị đọc nhầm thành bảng giá suất. **Không được tự chọn — phải hỏi chủ quán.**

Ngoài ba câu trên, mọi con số và quy tắc trong file này là thứ chủ quán đã chốt: bảng giá §4.2 và
phụ thu §4.4 là giá gốc của quán · thành phần suất bán §4.5 chốt 2026-08-19 · kênh `phone_preorder`
chốt 2026-08-24 và sửa 2026-08-29 · giá suất giò chốt 2026-08-29 · năm quy tắc luồng mang đi (§6.2
đến §6.5, và nhánh kết thúc của `phone_preorder` ở §5.2) chốt 2026-08-30.
