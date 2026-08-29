# Dữ kiện quán — Bánh cuốn Bà Thanh Cao Bằng

> **Vai trò của file này:** nguồn **input** cho giai đoạn BA, đứng cạnh
> `BA_initial_plan_banh_cuon_ba_thanh.md`. Kế hoạch gốc cho **khung** nghiệp vụ; file này cho
> **quy tắc vận hành cụ thể** của quán.
>
> **File này KHÔNG chứa con số giá.** Nhà duy nhất của phạm vi bán, bảng giá, phụ thu và thành
> phần một suất bán là **`master_plan/00-scope.md`**. Lệch nhau ⇒ **`00-scope.md` thắng**, chỗ
> lệch là bug phải sửa ngay. Ở đây chỉ có **con trỏ + hệ quả nghiệp vụ**, cố ý không chép số —
> mỗi bản chép là một chỗ sẽ trôi.
>
> **Chỉ giữ phần nghiệp vụ.** `prompt-fullstack.md` §3.4–§3.7 (stack, bảng dữ liệu, endpoint,
> route, quy tắc UI) **cố ý không có ở đây** — xem §7.

---

## 1. Nhận dạng quán → `00-scope.md` §1, §3

Tên · hotline `0382688666` · giờ bán **06:00–11:00 tất cả các ngày** · múi giờ
`Asia/Ho_Chi_Minh` · **11 bàn**. Thanh toán: **tiền mặt tại quầy** và **VietQR tĩnh**.

VietQR **tĩnh** = mã cố định, hệ thống **không tự biết tiền đã về**; người ở quầy phải tự xác nhận
đã nhận được tiền. Số tài khoản do chủ quán nhập sau, không chặn việc chốt nghiệp vụ.

## 2. Năm kênh bán → `00-scope.md` §2

Đúng **năm** kênh, không có kênh thứ sáu: `delivery` · `pickup` · `qr_table` · `staff_pos` ·
`phone_preorder`. Bảng đầy đủ ở `00-scope.md` §2. Ba hệ quả nghiệp vụ:

1. **Chỉ hai kênh gắn bàn**: `qr_table` và `staff_pos` — **gộp vào một phiên bàn, tính tiền một lần**.
2. **Ba kênh không gắn bàn**: `delivery` · `pickup` · `phone_preorder` — **mỗi đơn là một đơn vị
   thanh toán độc lập**. `delivery` phí ship **0đ**, không đơn tối thiểu; `pickup` **có giờ hẹn lấy**.
3. **`phone_preorder` là kênh riêng** (owner chốt 2026-08-29): khách gọi `0382688666`, nhân viên
   nhập hộ, đơn **không thuộc phiên bàn nào**. Đây là mục **thứ năm** trong bảng §2 — trước ngày
   29/08 file cũ ghi đơn hotline đi bằng `staff_pos`, cách ghi đó đã bị gỡ vì `staff_pos` luôn gắn bàn.

Định danh khách: hai kênh gắn bàn **ẩn danh theo bàn**; ba kênh còn lại cần thông tin liên hệ để
gọi lại (mức tối thiểu là câu hỏi của BA-04, không phải dữ kiện đã chốt ở đây).

## 3. Năm trạm làm việc

| Trạm | Làm gì |
|---|---|
| `quay` — quầy | Nhận/xác nhận đơn, đặt hộ, thu tiền, đóng phiên |
| `trang_banh` — tráng bánh | Tráng bánh, làm trứng |
| `gap_banh` — gấp bánh | Gấp bánh, xếp đĩa, cắt giò |
| `canh` — lấy canh | Nước chấm, canh |
| `don_ban` — dọn bàn | Dọn bàn sau khi phiên đóng |

Chủ quán (`owner`) là vai riêng, ngoài năm trạm trên. (fullstack §3.5.7)

## 4. Giá — quy tắc, không phải số

**Mọi con số ở `00-scope.md`:** công thức **§4.1** · bảng giá **§4.2** · nhóm tuỳ chọn và phụ thu
**§4.3** · thành phần một suất bán **§4.4**. Dưới đây chỉ là **hành vi** phải đúng.

### 4.1 Bảy quy tắc cấu tạo giá

1. **Giá một suất bán = TỔNG giá các thành phần của suất** (`00-scope.md` §4.4 cho thành phần,
   §4.2 cho giá từng thành phần). Đây là luật gốc, mọi luật dưới là hệ quả.
2. Giá gốc của một thành phần là **giá CHAY**. Nhân là **phụ thu**, không phải giá riêng.
3. Nhóm **"Lượng nhân" chỉ tồn tại khi nhân ≠ Chay**.
   ⇒ tổ hợp **Chay + Nhiều nhân là không hợp lệ, phải bị TỪ CHỐI**, không được âm thầm bỏ qua
   tuỳ chọn thừa — bếp nhận phiếu mâu thuẫn là hỏng món.
4. **Loại nhân không đổi giá.** Thịt và Thịt + mộc nhĩ cùng mức phụ thu; chỉ **lượng nhân** mới
   đổi giá.
5. **Phụ thu là +1.000 cho MỖI phần nhận nhân của suất.** Suất bánh cuốn ×1 · suất giò ×4 ·
   combo ×4 — ba con số này là **hệ quả** của luật 1, không phải ba con số rời.
6. **Giò không nhận nhân**, nhưng **4 cái bánh trong suất giò thì có** (owner chốt 2026-08-29).
7. Một dòng đơn chọn **một** loại nhân + **một** lượng nhân, áp cho **mọi phần nhận nhân** của suất
   đó. Không chọn nhân riêng cho từng cái bánh.
8. **Mặc định là nhân Thịt, lượng Thường** khi khách không chọn gì.
9. Khách **không bao giờ** gửi giá lên; giá luôn do hệ thống xác định lại từ menu.

### 4.2 Thành phần một suất bán → `00-scope.md` §4.4 (owner chốt 2026-08-19)

Bốn suất bán, mỗi suất **bếp làm ra nhiều thứ hơn tên món**. Bảng đầy đủ ở `00-scope.md` §4.4.
Hai điều phải nhớ khi viết nghiệp vụ:

- **Suất trứng và suất giò đều kèm 4 cái bánh cuốn**; combo "Đầy đủ" là 3 bánh + 1 trứng + 1 giò.
  ⇒ khách gọi "1 suất trứng" thì bếp làm **5 thứ**, không phải 1.
- **Giò không nhận nhân, nhưng 4 cái bánh trong suất giò thì có** — chay, thường hoặc nhiều nhân
  (owner chốt 2026-08-29). Nên suất giò có **ba** giá, không phải một.
- ⚠️ **Suất trứng chưa chốt giá** — xem `00-scope.md` §6 GD-01 và U-1 ở §8.

### 4.3 Bằng chứng của mô hình "tổng thành phần"

Không phải suy đoán. Cộng giá thành phần theo §4.4 tái tạo **đúng cả ba** ô giá combo ở §4.2:

```
3 × bánh(chay 3.000)  + trứng(chay 8.000)  + giò(9.000) = 26.000   ✓ khớp bảng
3 × bánh(thường 4.000)+ trứng(thường 9.000)+ giò(9.000) = 30.000   ✓ khớp bảng
3 × bánh(nhiều 5.000) + trứng(nhiều 10.000)+ giò(9.000) = 34.000   ✓ khớp bảng
```

Ba ô khớp liên tiếp không phải trùng hợp ⇒ **"giá suất = tổng giá thành phần"** là luật thật, và
"combo ×4" chỉ là cách nói gọn của "combo có 4 phần nhận nhân".

⚠️ Một câu trong `00-scope.md` §4.4 từng nói ngược lại — *"không nhân theo số phần bếp làm"* — đã
được gỡ ngày 2026-08-29 vì lời chủ quán về suất giò phủ nhận nó. Nếu thấy câu đó quay lại ở bất kỳ
tài liệu nào, **đó là bug**, không phải quy tắc.

### 4.4 Mười một tổ hợp giá bắt buộc phủ

Đây là danh sách **tổ hợp đầu vào**. Giá kỳ vọng **tra thẳng ở `00-scope.md` §4.2 + §4.3**, không
chép lại vào đây. Chín ca đầu tính được đã đối chiếu khớp bảng giá; ca 8 và ca 11 là hai ca đặc biệt.

```
 1. Bánh cuốn   · Chay          · —
 2. Bánh cuốn   · Thịt          · Thường
 3. Bánh cuốn   · Thịt          · Nhiều
 4. Bánh cuốn   · Thịt+mộc nhĩ  · Nhiều      ⟵ phải BẰNG ca 3 (loại nhân không đổi giá)
 5. Trứng chín  · Chay          · —
 6. Trứng tái   · Thịt+mộc nhĩ  · Thường
 7. Trứng vàng  · Thịt          · Nhiều
 8. Giò         · Thịt          · Nhiều      ⟵ 9.000 + 4 cái bánh; giò không nhận nhân, bánh thì có
 9. Đầy đủ chín · Thịt          · Thường     ⟵ combo: phụ thu ×4
10. Đầy đủ tái  · Thịt+mộc nhĩ  · Nhiều
11. Bánh cuốn   · Chay          · Nhiều      → PHẢI BỊ TỪ CHỐI
```

Ca 11 là ca **duy nhất** có kết quả ghi tại chỗ, vì nó không phải một giá — nó là luật hành vi ở
quy tắc 4.1.3.

**Ca 12 phải thêm khi GD-01 được gỡ:** một **suất trứng** đứng riêng (không phải combo). Đây là ô
duy nhất trong bảng giá còn trống, và nó chạm tiền — xem U-1 ở §8.

## 5. Luồng ăn tại bàn (fullstack §3.3)

```
Khách ngồi bàn 5
   ├── (A) quét QR trên bàn ────┐
   └── (B) không quét được      │
         └─ quầy hỏi, đặt hộ ───┤
                                ▼
                   PHIÊN BÀN 5 (mở) — gom mọi lượt gọi món
                                │
                 Quầy xác nhận đơn (chống đơn ảo)
                                │
        ┌───────────────────────┼───────────────────────┐
     TRÁNG BÁNH             GẤP BÁNH                LẤY CANH
        └───────────────────────┴───────────────────────┘
                                │
                        Mang ra bàn 5 → khách gọi thêm → quay lại đầu
                                │
                    Quầy thu tiền (mặt / VietQR) → đóng phiên → DỌN BÀN → bàn trống
```

Ship/pickup khác 3 điểm: **cần thông tin liên hệ** · **không có phiên bàn** · có bước **đóng gói**
thay cho bước mang ra bàn.

### 5.1 Việc xuống bếp phải "nổ" ra thành phần

Khách gọi **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**:

```
Khách trả tiền theo: [Đầy đủ trứng tái ×2 — Thịt+mộc nhĩ, Nhiều nhân]   ← 1 dòng trên hoá đơn

Bếp phải thấy:
  trang_banh │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  trang_banh │ Trứng tái ×2 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Bánh cuốn ×6 — thịt+mộc nhĩ, nhiều nhân
  gap_banh   │ Trứng tái ×2
  gap_banh   │ Giò ×2                    ← thành phần không nhận nhân thì KHÔNG kèm mô tả nhân
  canh       │ Nước chấm — bàn 5, 2 suất ← việc cấp ĐƠN, mọi đơn tại bàn đều có
```

Số lượng = `số suất × số thành phần trong suất` (`00-scope.md` §4.4).
**Bếp không bao giờ được thấy một dòng "Combo ×2" mơ hồ.**
Ví dụ này đã đối chiếu khớp `00-scope.md` §4.4 (combo = 3 bánh ⇒ 2 combo = 6 bánh) và §4.2
(2 × 34.000 = 68.000). Thành phần đổi ⇒ **sửa `00-scope.md` §4.4 trước**, rồi sửa ví dụ này.

## 6. Quy tắc nghiệp vụ bổ sung so với kế hoạch gốc

1. **Khách gọi thêm khi quầy đã bắt đầu thu tiền vẫn thuộc CÙNG phiên, CÙNG một hoá đơn.**
   Phiên ở trạng thái "chờ thanh toán" **chưa** giải phóng bàn. Tách ra hoá đơn thứ hai
   ⇒ **thu thiếu tiền** — đây là lỗi tiền nguy hiểm nhất của luồng tại bàn. (fullstack §3.5.4)
2. **Đơn từ QR phải được quầy duyệt trước khi xuống bếp.** Đơn chưa duyệt không sinh việc ở trạm.
3. **Chủ quán bấm "Tạm dừng nhận đơn" có ưu tiên CAO HƠN giờ mở cửa** (dùng khi hết nguyên liệu).
   Ngoài giờ bán: web khoá nút đặt, hiện *"Quán mở cửa 6h–11h sáng"*. (fullstack §3.3)
4. **Một khoản tiền gắn với đúng MỘT đơn vị tính tiền** — hoặc một phiên bàn, hoặc một đơn lẻ,
   không bao giờ cả hai. ⇒ **báo cáo doanh thu phải cộng từ CẢ HAI nguồn**, bỏ sót một nguồn là
   báo cáo thiếu. (fullstack §3.5.6)
5. **Đối soát cuối ngày:** trong 2 tuần đầu chạy thật, mỗi tối đối chiếu doanh thu hệ thống với
   **sổ giấy** và **tiền trong két**. **Lệch 1 đồng cũng phải tìm ra lý do.** Đây là cổng chất
   lượng mạnh nhất của dự án. (fullstack §6.3)
6. **Sổ giấy là kế hoạch dự phòng BẮT BUỘC.** Mất điện / mất mạng / POS hỏng ⇒ quán chuyển sang
   ghi tay, không dừng bán. (fullstack §6.8)
7. **Bốn ranh giới đã chốt, không phải chỗ trống chờ điền** (`00-scope.md` §5): kênh bán **thứ
   năm** · **đơn tối thiểu / bậc phí ship** · số tài khoản ngân hàng cứng trong sản phẩm ·
   **món ngoài bảng giá**. Thêm bất kỳ thứ nào là **đổi phạm vi, quyền chủ quán**.

---

## 7. Những gì CỐ Ý không có ở đây

Các mục sau của `prompt-fullstack.md` **thuộc System Design trở đi**, không được đưa vào bất kỳ
tài liệu BA nào, kể cả dạng gợi ý:

- §3.4 Stack công nghệ, cổng, cơ chế thông báo/realtime
- §3.5 Danh sách 16 bảng, tên cột, ràng buộc CHECK/UNIQUE, generated column
- §3.6 Endpoint `/api/v1`, phân quyền theo JWT
- §3.7 Cây route frontend, quy tắc kích thước chữ, màu theo thời gian chờ
- §6.2 Cột "bảo vệ bằng" của bảng bất biến (cơ chế kỹ thuật) — BA chỉ lấy **mệnh đề** bất biến
- §6.8 BE một instance, không hàng đợi, không cache, polling 20s

## 8. Unknown còn treo

**Đã gỡ ngày 2026-08-29** (chủ quán trả lời, đã ghi vào `00-scope.md`):
- ~~Đơn đặt trước qua hotline gắn vào bàn nào~~ → **kênh thứ năm `phone_preorder`, không gắn bàn**.
- ~~Suất giò có nhận tuỳ chọn nhân không~~ → **có**: 9.000 + tiền 4 cái bánh theo nhân đã chọn.

Còn lại một câu chạm tiền và ba câu hỏi mở:

| # | Vấn đề | Vì sao chưa chốt được | Ảnh hưởng | Ai trả lời |
|---|---|---|---|---|
| **U-1** | **Giá một suất trứng đứng riêng là bao nhiêu?** (`00-scope.md` §6 GD-01) | Suất trứng có cùng hình dạng với suất giò (1 trứng + 4 bánh) nhưng chủ quán mới chỉ trả lời về giò. Hai cách hiểu lệch nhau **12.000–20.000đ mỗi suất** | **Chặn BA-06.** Ô duy nhất còn trống trong bảng giá | Chủ quán |
| U-2 | Delivery ở MVP chỉ ghi nhận đơn hay quản lý trạng thái giao hàng | §10.7 kế hoạch gốc chưa trả lời | BA-04 | Chủ quán |
| U-3 | Có hoàn tiền không, ai được phép | §10.5 kế hoạch gốc chưa trả lời | BA-06, BA-08 | Chủ quán |
| U-4 | Thông tin liên hệ tối thiểu cho ba kênh không gắn bàn | `00-scope.md` không chốt; chỉ biết là cần liên hệ lại được | BA-04 | Chủ quán |

Mọi mục ở đây phải xuất hiện trong `docs/decisions.md` khi chạy BA-10, không được im lặng bỏ qua.
