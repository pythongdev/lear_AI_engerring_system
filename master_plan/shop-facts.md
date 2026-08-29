# Dữ kiện quán — Bánh cuốn Bà Thanh Cao Bằng

> **Vai trò của file này:** nguồn **input** thứ hai cho giai đoạn BA, đứng cạnh
> `BA_initial_plan_banh_cuon_ba_thanh.md`. Kế hoạch gốc cho **khung** nghiệp vụ; file này cho
> **dữ kiện cụ thể** của quán.
>
> **File này không phải nhà của sự thật.** Nó là bản trích từ `prompt-fullstack.md` (dự án cũ),
> mà chính file đó cũng tự khai là bản xuất khẩu. Sau khi giai đoạn BA chạy xong, nhà thật của
> mọi quy tắc dưới đây là `docs/product.md`; lệch nhau ⇒ **`docs/product.md` thắng**.
>
> **Chỉ trích phần nghiệp vụ.** `prompt-fullstack.md` §3.4–§3.7 (stack, bảng dữ liệu, endpoint,
> route, quy tắc UI) và §6.8 phần ràng buộc kỹ thuật **cố ý không có ở đây** — đó là scope của
> System Design, không phải BA.

---

## 1. Nhận dạng quán

| Mục | Giá trị | Nguồn |
|---|---|---|
| Tên | Bánh cuốn Bà Thanh Cao Bằng | fullstack §3.1 |
| Hotline | `0382688666` | fullstack §3.1 |
| Giờ bán | **06:00 – 11:00**, tất cả các ngày | fullstack §3.1 |
| Múi giờ | `Asia/Ho_Chi_Minh` | fullstack §3.1 |
| Số bàn | **11** | fullstack §3.1 |
| Phí ship | **0đ** | fullstack §3.1 |
| Đơn tối thiểu | **không có** | fullstack §3.1 |
| Thanh toán | Tiền mặt tại quầy · Chuyển khoản **VietQR tĩnh** | fullstack §3.1 |

VietQR **tĩnh** = mã cố định, hệ thống **không tự biết tiền đã về**; người ở quầy phải tự xác nhận
đã nhận được tiền. Số tài khoản do chủ quán nhập sau, không chặn việc chốt nghiệp vụ.

## 2. Bốn kênh bán

| Kênh | Ai khởi tạo | Gắn phiên bàn | Định danh khách |
|---|---|---|---|
| `delivery` | Khách, qua web | Không | **Bắt buộc số điện thoại** |
| `pickup` | Khách, qua web | Không | **Bắt buộc số điện thoại**, **có giờ hẹn tới lấy** |
| `qr_table` | Khách, quét QR tại bàn | **Có** | Ẩn danh theo bàn, không cần SĐT |
| `staff_pos` | Nhân viên đặt hộ | **Có** | Ẩn danh theo bàn, không cần SĐT |

Hai kênh cuối **đều gắn với một số bàn** và **gộp vào cùng một phiên bàn, tính tiền một lần**.
(fullstack §3.1, §3.5.5)

## 3. Năm trạm làm việc

| Trạm | Làm gì |
|---|---|
| `quay` — quầy | Nhận/xác nhận đơn, đặt hộ, thu tiền, đóng phiên |
| `trang_banh` — tráng bánh | Tráng bánh, làm trứng |
| `gap_banh` — gấp bánh | Gấp bánh, xếp đĩa, cắt giò |
| `canh` — lấy canh | Nước chấm, canh |
| `don_ban` — dọn bàn | Dọn bàn sau khi phiên đóng |

Chủ quán (`owner`) là vai riêng, ngoài năm trạm trên. (fullstack §3.5.7)

## 4. Cấu trúc menu và giá

**Chưa có bảng giá.** Công thức và bảng giá thật nằm ở `00-scope.md §4.1–§4.4` của dự án cũ —
**file đó không có trong repo này**. Ta có *quy tắc cấu tạo giá*, **không** có *con số*.
⚠️ Đây là **unknown chặn** BA-06 và BA-10: không có bảng giá thì không viết được §4 `docs/product.md`
ở mức đủ để nghiệm thu. Phải hỏi chủ quán, hoặc lấy lại `00-scope.md`.

Quy tắc cấu tạo giá đã biết (fullstack §3.2, §3.5.1–§3.5.2, §9.3):

1. Giá gốc của một món là **giá CHAY**. Nhân là **phụ thu**, không phải giá riêng.
2. Nhóm tuỳ chọn **"Lượng nhân"** chỉ xuất hiện khi khách đã chọn nhân **khác Chay**.
   ⇒ tổ hợp **Chay + Nhiều nhân là không hợp lệ, phải bị TỪ CHỐI**, không được âm thầm bỏ qua —
   bếp nhận phiếu mâu thuẫn là hỏng món.
3. **Loại nhân không đổi giá** (Thịt và Thịt+mộc nhĩ cùng mức); chỉ **lượng nhân** mới đổi giá.
4. Món **Giò không nhận nhân** — không có tuỳ chọn nhân cho món này.
5. Combo ("Đầy đủ ...") tính **phụ thu ×4** so với một suất đơn lẻ.
6. Khách **không bao giờ** gửi giá lên; giá luôn do hệ thống xác định lại từ menu.

### 4.1 Mười một tổ hợp giá bắt buộc phủ

Đây là danh sách **tổ hợp đầu vào**, không phải bảng giá. Giá kỳ vọng của mười ca đầu **chưa có**
(xem cảnh báo trên); ca 11 là ca duy nhất có kết quả chốt sẵn vì nó là luật hành vi, không phải giá.

```
 1. Bánh cuốn   · Chay          · —
 2. Bánh cuốn   · Thịt          · Thường
 3. Bánh cuốn   · Thịt          · Nhiều
 4. Bánh cuốn   · Thịt+mộc nhĩ  · Nhiều      ⟵ phải bằng ca 3 (loại nhân không đổi giá)
 5. Trứng chín  · Chay          · —
 6. Trứng tái   · Thịt+mộc nhĩ  · Thường
 7. Trứng vàng  · Thịt          · Nhiều
 8. Giò         · —             · —          ⟵ giò không nhận nhân
 9. Đầy đủ chín · Thịt          · Thường     ⟵ combo: phụ thu ×4
10. Đầy đủ tái  · Thịt+mộc nhĩ  · Nhiều
11. Bánh cuốn   · Chay          · Nhiều      → PHẢI BỊ TỪ CHỐI
```

### 4.2 Thành phần một suất bán

Combo "Đầy đủ" = **3 cái bánh cuốn + 1 quả trứng + 1 chiếc giò** (chủ quán chốt **2026-08-19**).
Thành phần đổi ⇒ phải sửa mục này **trước**, vì mọi ví dụ khác đều tham chiếu về đây.

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

Ship/pickup khác 3 điểm: **cần SĐT** · **không có phiên bàn** · có bước **đóng gói** thay cho
bước mang ra bàn.

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

Số lượng = `số combo × số thành phần`. **Bếp không bao giờ được thấy một dòng "Combo ×2" mơ hồ.**

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

---

## 7. Những gì file này CỐ Ý không chứa

Các mục sau của `prompt-fullstack.md` **thuộc System Design trở đi**, không được đưa vào bất kỳ
tài liệu BA nào, kể cả dạng gợi ý:

- §3.4 Stack công nghệ, cổng, cơ chế thông báo/realtime
- §3.5 Danh sách 16 bảng, tên cột, ràng buộc CHECK/UNIQUE, generated column
- §3.6 Endpoint `/api/v1`, phân quyền theo JWT
- §3.7 Cây route frontend, quy tắc kích thước chữ, màu theo thời gian chờ
- §6.2 Cột "bảo vệ bằng" của bảng bất biến (cơ chế kỹ thuật) — BA chỉ lấy **mệnh đề** bất biến
- §6.8 BE một instance, không hàng đợi, không cache, polling 20s

## 8. Unknown còn treo sau khi trích

| # | Câu hỏi | Ảnh hưởng | Ai trả lời |
|---|---|---|---|
| U-1 | **Bảng giá thật và danh sách món đầy đủ** (`00-scope.md §4.2–§4.3` không có trong repo) | **Chặn BA-06, BA-11** — không có số thì không nghiệm thu được | Chủ quán |
| U-2 | Mức phụ thu "Nhiều nhân" là bao nhiêu | Chặn BA-06 | Chủ quán |
| U-3 | Danh sách nhóm tuỳ chọn đầy đủ (ngoài "Nhân" và "Lượng nhân") | Ảnh hưởng BA-05, BA-06 | Chủ quán |
| U-4 | Delivery ở MVP chỉ ghi nhận đơn hay quản lý trạng thái giao hàng | BA-04 | Chủ quán |
| U-5 | Có hoàn tiền không, ai được phép | BA-06, BA-08 | Chủ quán |

Mọi unknown ở đây phải xuất hiện trong `docs/decisions.md` khi chạy BA-10, không được im lặng bỏ qua.
