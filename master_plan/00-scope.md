# 00-scope.md — phạm vi bán và giá món

> Cập nhật **2026-08-29** (kênh `phone_preorder`, giá suất giò, mô hình giá = tổng thành phần). **Đây là nhà duy nhất của phạm vi bán và giá món** ([CLAUDE.md §2](../CLAUDE.md)).
> Chỗ nào khác trong repo nói khác file này ⇒ **file này thắng**, chỗ kia là bug phải sửa ngay.
> `prompt-fullstack.md` §3.1 §3.2 là nơi các con số này từng sống; chúng đã chuyển về đây, §3.2 nay chỉ trỏ lên.

---

## §1 Quán

| Mục | Giá trị |
|---|---|
| Tên | Bánh cuốn Bà Thanh Cao Bằng |
| Hotline | `0382688666` |
| Giờ bán | **06:00 – 11:00**, tất cả các ngày |
| Múi giờ | `Asia/Ho_Chi_Minh` |
| Số bàn | **11** |

## §2 Kênh bán — đúng năm, không có kênh thứ sáu

| Kênh | Ai bấm | Gắn số bàn | Ghi chú |
|---|---|---|---|
| `delivery` | khách, trên web | không | phí ship **0đ**, không có đơn tối thiểu |
| `pickup` | khách, trên web | không | có giờ hẹn lấy |
| `qr_table` | khách quét QR tại bàn | **có** | gộp vào phiên bàn |
| `staff_pos` | nhân viên đặt hộ **tại quán** | **có** | gộp vào phiên bàn |
| `phone_preorder` | nhân viên nhận **điện thoại** | **không** | đơn đặt trước, **không thuộc phiên bàn nào** |

Hai kênh gắn bàn (`qr_table`, `staff_pos`) **gộp vào một phiên bàn và tính tiền một lần**.
Ba kênh còn lại (`delivery`, `pickup`, `phone_preorder`) **mỗi đơn là một đơn vị thanh toán độc lập**.

**Đặt trước qua hotline** (owner chốt 2026-08-24, sửa **2026-08-29**): khách gọi `0382688666`,
nhân viên nhận rồi nhập vào hệ thống bằng kênh **`phone_preorder`** — **một mục riêng, không gắn
vào bàn nào**. Trước đây file này ghi đơn hotline đi bằng `staff_pos`; cách ghi đó **sai** vì
`staff_pos` luôn gắn số bàn, mà khách gọi điện thì chưa ngồi bàn nào.
Thêm kênh **thứ sáu** là **đổi phạm vi**, quyền owner ([CLAUDE.md §7](../CLAUDE.md)).

## §3 Thanh toán

| Cách | Chi tiết |
|---|---|
| Tiền mặt | tại quầy |
| Chuyển khoản | **VietQR tĩnh** — số tài khoản nhập sau ở Admin, **không chặn code** |

## §4 Menu và giá — nguồn duy nhất của tiền

### 4.1 Công thức

```
giá món = base_price (giá CHAY) + phụ thu nhân + phụ thu lượng nhân
```

### 4.2 Bảng giá **thành phần**

Đây là giá của **từng thành phần**, không phải giá một suất bán. Giá một suất = **tổng giá các
thành phần** của suất đó theo §4.4.

| Danh mục | Thành phần | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Bánh cuốn | 1 cái bánh cuốn | 3.000 | 4.000 | 5.000 |
| Bánh cuốn | 1 quả trứng chín / tái / vàng | 8.000 | 9.000 | 10.000 |
| Ăn kèm | 1 chiếc giò | **9.000** | **9.000** | **9.000** |

Giò **không nhận nhân** nên một giá cho cả ba cột.

#### Giá một suất bán — tính từ bảng trên

| Suất bán | Cách tính (§4.4) | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Suất bánh cuốn | 1 bánh | 3.000 | 4.000 | 5.000 |
| **Suất giò** | 1 giò + 4 bánh | **21.000** | **25.000** | **29.000** |
| Combo "Đầy đủ" trứng chín / tái / vàng | 3 bánh + 1 trứng + 1 giò | 26.000 | **30.000** | 34.000 |
| Suất trứng chín / tái / vàng | 1 trứng + 4 bánh | ⚠ chưa chốt — §6 GD-01 | ⚠ | ⚠ |

**Suất giò owner chốt 2026-08-29**: *"1 cái giò là 9.000, tính thêm tiền số lượng bánh là ra số
tiền của suất"* ⇒ 9.000 + 4 × giá bánh theo nhân đã chọn.
Ba ô combo đã đối chiếu: `3×3.000 + 8.000 + 9.000 = 26.000` · `3×4.000 + 9.000 + 9.000 = 30.000` ·
`3×5.000 + 10.000 + 9.000 = 34.000` — **khớp cả ba**, nên mô hình "tổng thành phần" là đúng.

### 4.3 Nhóm tuỳ chọn và phụ thu

| Nhóm tuỳ chọn | Lựa chọn | Món lẻ | Combo |
|---|---|---|---|
| **Nhân** (bắt buộc chọn 1) | Chay / Thịt / Thịt + mộc nhĩ | 0 / +1.000 / +1.000 | 0 / +4.000 / +4.000 |
| **Lượng nhân** (chỉ hiện khi nhân ≠ Chay) | Thường / Nhiều nhân | 0 / +1.000 | 0 / +4.000 |

Loại nhân (thịt hay thịt + mộc nhĩ) **không đổi giá**.

**Phụ thu là +1.000 cho MỖI phần nhận nhân**, cột "Món lẻ" và "Combo" ở trên chỉ là hai trường hợp
hay gặp của cùng một luật:

| Suất bán | Số phần nhận nhân (§4.4) | Phụ thu mỗi bậc |
|---|---|---|
| Suất bánh cuốn | 1 (cái bánh) | +1.000 (**×1**) |
| Suất giò | 4 (bốn cái bánh; giò không nhận nhân) | +4.000 (**×4**) |
| Combo "Đầy đủ" | 4 (ba cái bánh + quả trứng) | +4.000 (**×4**) |
| Suất trứng | 5 (bốn cái bánh + quả trứng) | ⚠ chưa chốt — §6 GD-01 |

### 4.4 Thành phần một suất bán — owner chốt 2026-08-19

Đây là thứ **bếp làm ra**, khác với thứ khách trả tiền.

| Suất bán | Bếp làm ra | Phần **nhận** tuỳ chọn nhân |
|---|---|---|
| Suất **bánh cuốn** | 1 cái bánh cuốn | cái bánh đó |
| Suất **trứng** (chín / tái / vàng) | **1 quả trứng + 4 cái bánh cuốn** | 4 cái bánh **và** quả trứng |
| Suất **giò** | **1 chiếc giò + 4 cái bánh cuốn** | 4 cái bánh (giò **không** nhận nhân) — owner chốt 2026-08-29: bánh có thể **chay / thường / nhiều nhân** |
| **Combo "Đầy đủ"** | **3 cái bánh cuốn + 1 quả trứng + 1 chiếc giò** | 3 cái bánh **và** quả trứng |

Một dòng đơn chọn **một** loại nhân + **một** lượng nhân, áp cho mọi phần nhận nhân của suất đó; mặc định
là **nhân thịt, lượng thường**.

**Phụ thu nhân theo số phần nhận nhân** (§4.3 bảng dưới). Câu cũ ở đây — *"không nhân theo số phần bếp
làm"* — đã bị lời chủ quán ngày **2026-08-29** phủ nhận: suất giò tính 9.000 + tiền **bốn** cái bánh,
tức phụ thu ×4. Câu cũ gỡ ngày 2026-08-29.

## §5 Ngoài phạm vi — ranh giới, để phiên sau không tự dựng

| Không làm | Vì sao ghi ở đây |
|---|---|
| Kênh bán thứ sáu | §2 chốt đúng năm; thêm là đổi phạm vi, quyền owner |
| Đơn tối thiểu, bậc phí ship | ship 0đ và không đơn tối thiểu là chốt, không phải chỗ trống chờ điền |
| Số tài khoản ngân hàng cứng trong code | §3 chốt nhập ở Admin |
| Món ngoài bảng §4.2 | thêm món là đổi phạm vi, quyền owner |

## §6 Giả định chưa chốt

### GD-01 — Giá suất trứng (rủi ro **cao**, chạm tiền)

Owner chốt suất **giò** = 9.000 + tiền 4 cái bánh (2026-08-29). Suất **trứng** có cùng hình dạng
(1 quả trứng + 4 cái bánh, §4.4) nhưng **chưa ai xác nhận** nó tính cùng cách.

| Cách hiểu | Suất trứng (chay / thường / nhiều) | Hậu quả nếu chọn sai |
|---|---|---|
| **A** — cùng mô hình tổng thành phần | 20.000 / 25.000 / 30.000 | — |
| **B** — 8.000/9.000/10.000 đã là giá cả suất | 8.000 / 9.000 / 10.000 | **Thu thiếu 12.000–20.000đ mỗi suất trứng** |

Cách A khớp với mô hình tái tạo đúng cả ba ô combo; cách B khớp với việc §4.2 trước đây được đọc như
bảng giá suất. **Không tự chọn.** Người trả lời: chủ quán.

Ngoài GD-01, mọi con số trong file này là số owner đã chốt: §4.2 §4.3 gốc theo `prompt-fullstack.md`
§3.2, §4.4 owner chốt 2026-08-19, §2 đoạn hotline owner chốt 2026-08-24 và sửa 2026-08-29,
suất giò owner chốt 2026-08-29.
