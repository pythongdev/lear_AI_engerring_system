# 00-scope.md — phạm vi bán và giá món

> Cập nhật **2026-08-24**. **Đây là nhà duy nhất của phạm vi bán và giá món** ([CLAUDE.md §2](../CLAUDE.md)).
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

## §2 Kênh bán — đúng bốn, không có kênh thứ năm

| Kênh | Ai bấm | Gắn số bàn | Ghi chú |
|---|---|---|---|
| `delivery` | khách, trên web | không | phí ship **0đ**, không có đơn tối thiểu |
| `pickup` | khách, trên web | không | có giờ hẹn lấy |
| `qr_table` | khách quét QR tại bàn | **có** | gộp vào phiên bàn |
| `staff_pos` | nhân viên đặt hộ | **có** | gộp vào phiên bàn |

Hai kênh gắn bàn (`qr_table`, `staff_pos`) **gộp vào một phiên bàn và tính tiền một lần**.

**Đặt trước qua hotline** (owner chốt 2026-08-24): khách gọi `0382688666`, **nhân viên nhận rồi nhập vào
hệ thống bằng kênh `staff_pos`**. Cuộc gọi **không** đẻ ra kênh thứ năm — nó chỉ là nguồn của đơn, không
phải một đường vào riêng. Thêm kênh thứ năm là **đổi phạm vi**, quyền owner ([CLAUDE.md §7](../CLAUDE.md)).

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

### 4.2 Bảng giá

| Danh mục | Món | Chay | Thịt thường | Thịt nhiều |
|---|---|---|---|---|
| Bánh cuốn | Bánh cuốn | 3.000 | 4.000 | 5.000 |
| Bánh cuốn | Trứng chín / tái / vàng | 8.000 | 9.000 | 10.000 |
| Ăn kèm | Giò | — | **9.000** | — |
| Combo | Đầy đủ trứng chín / tái / vàng | 26.000 | **30.000** | 34.000 |

### 4.3 Nhóm tuỳ chọn và phụ thu

| Nhóm tuỳ chọn | Lựa chọn | Món lẻ | Combo |
|---|---|---|---|
| **Nhân** (bắt buộc chọn 1) | Chay / Thịt / Thịt + mộc nhĩ | 0 / +1.000 / +1.000 | 0 / +4.000 / +4.000 |
| **Lượng nhân** (chỉ hiện khi nhân ≠ Chay) | Thường / Nhiều nhân | 0 / +1.000 | 0 / +4.000 |

Combo phụ thu **×4** vì có 4 phần nhận nhân. Loại nhân (thịt hay thịt + mộc nhĩ) **không đổi giá**.

### 4.4 Thành phần một suất bán — owner chốt 2026-08-19

Đây là thứ **bếp làm ra**, khác với thứ khách trả tiền.

| Suất bán | Bếp làm ra | Phần **nhận** tuỳ chọn nhân |
|---|---|---|
| Suất **bánh cuốn** | 1 cái bánh cuốn | cái bánh đó |
| Suất **trứng** (chín / tái / vàng) | **1 quả trứng + 4 cái bánh cuốn** | 4 cái bánh **và** quả trứng |
| Suất **giò** | **1 chiếc giò + 4 cái bánh cuốn** | 4 cái bánh (giò **không** nhận nhân) |
| **Combo "Đầy đủ"** | **3 cái bánh cuốn + 1 quả trứng + 1 chiếc giò** | 3 cái bánh **và** quả trứng |

Một dòng đơn chọn **một** loại nhân + **một** lượng nhân, áp cho mọi phần nhận nhân của suất đó; mặc định
là **nhân thịt, lượng thường**. Phụ thu vẫn theo §4.3 (món lẻ ×1, combo ×4) — **không** nhân theo số phần
bếp làm.

## §5 Ngoài phạm vi — ranh giới, để phiên sau không tự dựng

| Không làm | Vì sao ghi ở đây |
|---|---|
| Kênh bán thứ năm | §2 chốt đúng bốn; thêm là đổi phạm vi, quyền owner |
| Đơn tối thiểu, bậc phí ship | ship 0đ và không đơn tối thiểu là chốt, không phải chỗ trống chờ điền |
| Số tài khoản ngân hàng cứng trong code | §3 chốt nhập ở Admin |
| Món ngoài bảng §4.2 | thêm món là đổi phạm vi, quyền owner |

## §6 Giả định chưa chốt

Chưa có. Mọi con số trong file này là số owner đã chốt: §4.2 §4.3 theo `prompt-fullstack.md` §3.2,
§4.4 owner chốt 2026-08-19, §2 đoạn hotline owner chốt 2026-08-24.
