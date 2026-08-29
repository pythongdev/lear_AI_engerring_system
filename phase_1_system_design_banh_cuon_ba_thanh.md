# PHASE 1 — SYSTEM DESIGN
## Bánh cuốn Bà Thanh Cao Bằng

> Mục tiêu của phase này: chốt **cái gì phải luôn đúng và hệ thống bảo vệ nó bằng cách nào**.
> Chưa thiết kế DB schema, API endpoint, FE component hoặc code implementation.

---

## 1. CHỐT XONG

### SD-01 — Tiền là ưu tiên cao nhất
Mọi thiết kế quan trọng phải ưu tiên ngăn sai tiền hơn là tối ưu sự tiện lợi.

### SD-02 — Một phiên bàn là một đơn vị tính tiền
Một bàn có thể có nhiều lượt gọi món nhưng khi thanh toán phải gom thành một hóa đơn/đơn vị thanh toán.

### SD-03 — Backend/system là nguồn sự thật về giá
Khách hàng và giao diện không được quyết định số tiền cuối cùng.

### SD-04 — QR là kênh yêu cầu, không phải kênh tự động xuống bếp
Đơn từ QR phải được quầy xác nhận trước khi trở thành công việc thực hiện.

### SD-05 — Dữ liệu lịch sử phải bất biến về mặt nghiệp vụ
Thay đổi menu hoặc giá chỉ ảnh hưởng đơn mới; thông tin đã dùng cho đơn cũ phải giữ nguyên.

### SD-06 — Realtime là tối ưu, không phải điều kiện tồn tại
Nếu realtime mất, nhân viên vẫn phải có cách nhận biết và xử lý công việc.

### SD-07 — Hệ thống phải có phương án vận hành khi công nghệ gặp sự cố
Sổ giấy là phương án dự phòng bắt buộc cho tình huống mất mạng/mất điện/hỏng thiết bị.

---

# 2. SYSTEM BOUNDARY

Hệ thống có 4 nhóm tương tác chính:

```text
                    ┌─────────────────────┐
                    │   Customer          │
                    │ delivery / pickup   │
                    │ QR table            │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │     Ordering        │
                    │       System        │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┼─────────────┐
                 ▼             ▼             ▼
              Quầy          Các trạm       Payment
           xác nhận        thực hiện        / Checkout
                 │             │             │
                 └─────────────┼─────────────┘
                               ▼
                         Table / Order
                           lifecycle

Owner / Admin ───────────────► System
        quản lý menu, giá, nhân viên, bàn, báo cáo
```

### Ngoài boundary của phase này

Chưa quyết định:

- database table cụ thể;
- API cụ thể;
- frontend component;
- framework/package;
- cấu trúc source code;
- cách triển khai chi tiết từng service.

---

# 3. CÁC INVARIANT

Mỗi invariant gồm:

`Mệnh đề → Cơ chế bảo vệ → Cách kiểm chứng`

## I1 — Một bàn tối đa một phiên chưa thanh toán

**Mệnh đề:** Một bàn không được đồng thời có hai phiên chưa thanh toán.

**Bảo vệ:** Ràng buộc ở tầng dữ liệu phải ngăn trạng thái này, không chỉ kiểm tra ở UI/application.

**Kiểm chứng:** Tạo hai phiên đồng thời cho cùng một bàn → hệ thống phải từ chối một thao tác.

**Nếu hỏng:** Có thể tạo hai hóa đơn cho cùng một bàn và thu thiếu tiền.

---

## I2 — Tổng phiên bằng tổng chi tiết các đơn trong phiên

**Mệnh đề:** Tổng tiền phải trả của phiên luôn bằng tổng các dòng món thuộc toàn bộ đơn trong phiên.

**Bảo vệ:** Có một cơ chế tính lại tổng từ dữ liệu chi tiết; checkout phải dựa trên tổng đã được kiểm chứng.

**Kiểm chứng:** Query đối chiếu tất cả phiên chưa đóng/đã đóng → phiên có tổng khác tổng tính lại phải bằng 0 dòng.

**Nếu hỏng:** Thu thiếu hoặc thu thừa tiền.

---

## I3 — Giá thu phải do hệ thống xác định

**Mệnh đề:** Client không được quyết định giá cuối cùng.

**Bảo vệ:** Hệ thống tự xác định giá từ dữ liệu menu/options; dữ liệu gửi từ client chỉ mô tả món và lựa chọn.

**Kiểm chứng:** Test gửi giá giả từ client → giá giả phải bị bỏ qua/từ chối; kết quả phải dùng giá hệ thống.

**Nếu hỏng:** Khách có thể đặt món với giá sai, kể cả 0đ.

---

## I4 — Đơn QR chưa được xác nhận không xuống trạm

**Mệnh đề:** Đơn đang chờ quầy duyệt không được tạo công việc thực hiện.

**Bảo vệ:** Trạng thái đơn và thao tác tạo công việc phải nằm trong cùng một luồng nghiệp vụ được kiểm soát.

**Kiểm chứng:** Tạo đơn QR pending → kiểm tra danh sách công việc → không được có công việc của đơn pending.

**Nếu hỏng:** Bếp làm món ảo hoặc đơn bị gửi nhầm.

---

## I5 — Đơn đã xác nhận phải sinh đủ công việc cần thiết

**Mệnh đề:** Khi đơn được xác nhận, tất cả công việc cần thiết cho các trạm của món phải tồn tại.

**Bảo vệ:** Việc sinh công việc phải là một phần không thể tách rời khỏi bước xác nhận.

**Kiểm chứng:** Xác nhận một đơn mẫu → kiểm tra các công việc tương ứng với từng trạm → không thiếu công việc.

**Nếu hỏng:** Khách nhận thiếu món hoặc một phần món không bao giờ được làm.

---

## I6 — Một khoản thanh toán thuộc đúng một đơn vị tính tiền

**Mệnh đề:** Một payment phải gắn với đúng một đơn vị nghiệp vụ cần thanh toán.

**Bảo vệ:** Ràng buộc dữ liệu không cho phép payment vừa thuộc order vừa thuộc session, hoặc không thuộc cái nào.

**Kiểm chứng:** Chạy kiểm tra dữ liệu → mọi payment vi phạm phải bằng 0 dòng.

**Nếu hỏng:** Báo cáo doanh thu có thể đếm sai hoặc bỏ sót tiền.

---

## I7 — Đơn cũ không đổi khi menu đổi giá

**Mệnh đề:** Giá/tên đã áp dụng cho đơn phải được giữ lại ngay tại thời điểm đặt.

**Bảo vệ:** Snapshot thông tin bán tại thời điểm order.

**Kiểm chứng:** Tạo order → thay đổi giá menu → kiểm tra order cũ → thông tin giá của order cũ không đổi.

**Nếu hỏng:** Doanh thu lịch sử thay đổi và không đối chiếu được với tiền thực thu.

---

## I8 — Bàn trống phải phản ánh đúng phiên chưa đóng

**Mệnh đề:** Một bàn chỉ được coi là trống khi không còn phiên chưa đóng.

**Bảo vệ:** Chọn một nguồn sự thật duy nhất cho trạng thái bàn, tránh hai nguồn dữ liệu có thể lệch nhau.

**Kiểm chứng:** Đối chiếu trạng thái bàn với các phiên chưa đóng → mọi trường hợp mâu thuẫn phải bằng 0 dòng.

**Nếu hỏng:** Khách mới có thể bị gán nhầm vào bàn đang có khách hoặc phiên cũ.

---

# 4. QUY TẮC KIẾN TRÚC CẤP CAO

## 4.1 Một nguồn sự thật cho nghiệp vụ quan trọng

Không để cùng một business rule tồn tại dưới nhiều phiên bản độc lập.

Ví dụ:

```text
Business Rule
      │
      └── một cơ chế chính
             ├── runtime protection
             └── verification
```

Đặc biệt áp dụng cho:

- giá;
- tổng tiền;
- vòng đời order;
- trạng thái phiên bàn;
- payment.

---

## 4.2 Realtime không được là đường duy nhất

Luồng bình thường:

```text
Event
  ↓
Realtime
  ↓
Staff screen
```

Nhưng phải có đường dự phòng:

```text
Staff screen
  ↓
Periodic refresh
  ↓
Server state
```

Mục tiêu là mất SSE không làm trạm ngừng hoạt động.

---

## 4.3 Không mở rộng hệ thống trước khi có dấu hiệu cần thiết

Ở MVP:

- không mặc định thêm queue;
- không mặc định thêm cache;
- không mặc định chạy nhiều backend instance;
- không chia hệ thống thành nhiều service.

Mỗi lần muốn thêm một thành phần phải trả lời:

1. Vấn đề thực tế là gì?
2. Có số liệu chứng minh chưa?
3. Thành phần mới giải quyết vấn đề đó thế nào?
4. Chi phí vận hành/debug là bao nhiêu?

---

## 4.4 Một backend instance ở giai đoạn đầu

Mục tiêu là giữ hệ thống dễ vận hành và dễ debug.

Nếu sau này cần nhiều instance thì phải xem lại:

- realtime;
- shared state;
- session/state;
- deployment;
- observability.

---

## 4.5 Không có hàng đợi ở MVP nếu chưa có bằng chứng cần

Luồng xác nhận đơn phải đủ nhanh.

**Dấu hiệu xem lại:** thao tác xác nhận đơn thường xuyên vượt ngưỡng thời gian chấp nhận được trong thực tế.

---

## 4.6 Không cache business data ở giai đoạn đầu

Menu/catalog có thể được đọc trực tiếp từ nguồn sự thật.

**Dấu hiệu xem lại:** lượng dữ liệu hoặc tải thực tế đủ lớn khiến database trở thành bottleneck.

---

# 5. THỜI GIAN VÀ TÍNH NHẤT QUÁN

Mọi logic liên quan đến giờ mở cửa, ngày bán và báo cáo phải sử dụng cùng một khái niệm thời gian của quán:

```text
Asia/Ho_Chi_Minh
```

Không để mỗi thành phần tự hiểu một timezone khác nhau.

---

# 6. 5 RỦI RO LỚN NHẤT

| # | Rủi ro | Hậu quả | Cách chặn |
|---|---|---|---|
| R1 | Tính sai giá | Thu sai tiền | Một nguồn tính giá + test |
| R2 | Hai phiên cùng bàn | Tách hóa đơn, thu thiếu | Invariant I1 |
| R3 | QR xuống bếp khi chưa duyệt | Làm đơn ảo | Invariant I4 |
| R4 | Mất dữ liệu/lịch sử đơn | Không đối soát được doanh thu | Backup + snapshot + verification |
| R5 | Realtime hỏng | Trạm không nhận việc | SSE + periodic refresh |

---

# 7. MASTER TASK — SYSTEM DESIGN

| ID | Pha · Tầng | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Trạng thái |
|---|---|---|---|---|---|---|
| SD-01 | 1 · Architecture | Chốt system boundary và trách nhiệm từng nhóm | BA | Sơ đồ boundary + danh sách responsibility | Các phần hệ thống giẫm trách nhiệm nhau | ⬜ |
| SD-02 | 1 · Architecture | Chốt các invariant liên quan đến tiền | SD-01 | I1, I2, I3, I6, I7 có protection + verification | Thu sai tiền | ⬜ |
| SD-03 | 1 · Architecture | Chốt invariant vòng đời bàn và order | SD-01 | I4, I5, I8 có protection + verification | Đơn/bàn bị kẹt | ⬜ |
| SD-04 | 1 · Architecture | Chốt nguồn sự thật cho trạng thái và thời gian | SD-01 | Decision record về state/time ownership | Các màn hình báo trạng thái khác nhau | ⬜ |
| SD-05 | 1 · Architecture | Chốt chiến lược realtime và fallback | SD-01 | Luồng realtime + refresh fallback | Trạm mất việc khi realtime lỗi | ⬜ |
| SD-06 | 1 · Architecture | Chốt giới hạn kiến trúc MVP | SD-01 | Danh sách những thứ chưa cần: queue/cache/replica | Over-engineering, khó vận hành | ⬜ |
| SD-07 | 1 · Risk | Chốt 5 rủi ro và cơ chế giảm thiểu | SD-02, SD-03 | Risk register có owner/mechanism | Rủi ro lớn không có người chặn | ⬜ |
| SD-08 | 1 · Quality | Chốt bộ verification cho invariants | SD-02, SD-03 | Danh sách query/test cần xanh | Invariant chỉ tồn tại trên giấy | ⬜ |
| SD-09 | 1 · Architecture | Kiểm tra ba vertical slices qua kiến trúc | SD-02–SD-08 | A/B/C đều có đường đi hợp lệ | Thiết kế không chạy được nghiệp vụ | ⬜ |
| SD-10 | 1 · Quality | Chạy review gate trước khi sang DB | SD-09 | Không còn invariant quan trọng thiếu protection | DB xây trên quyết định chưa chốt | ⬜ |

---

# 8. CỔNG CHẤT LƯỢNG

Chỉ chuyển sang DB Design khi tất cả điều kiện sau đạt:

- [ ] System boundary rõ.
- [ ] Invariant quan trọng đã được định nghĩa.
- [ ] Mỗi invariant có cơ chế bảo vệ.
- [ ] Mỗi invariant có cách kiểm chứng.
- [ ] Nguồn sự thật của trạng thái đã chốt.
- [ ] Nguồn sự thật của thời gian đã chốt.
- [ ] Realtime có fallback.
- [ ] 5 rủi ro lớn nhất có cách chặn.
- [ ] Không có quyết định kiến trúc quan trọng đang dựa trên giả định chưa được ghi nhận.
- [ ] Ba vertical slices A/B/C đều có thể đi xuyên qua system design.

### Lệnh/kịch bản nghiệm thu cấp phase

```text
Review checklist:
- invariant → protection → verification: 100%
- risk → mitigation: 100%
- vertical slice A/B/C: không có điểm mơ hồ cấp kiến trúc
- không xuất hiện DB table/API/component trong quyết định chưa tới phase
```

---

# 9. GIẢ ĐỊNH

### A1 — Thanh toán
VietQR hiện được xem là phương thức thanh toán mà quán xác nhận ở quy trình nghiệp vụ; cơ chế tự động đối soát giao dịch chưa được chốt.

**Rủi ro:** Trung bình.

### A2 — Hoàn tiền
Chính sách hoàn tiền chưa được chốt ở BA.

**Rủi ro:** Trung bình.

### A3 — Delivery
Phase này chỉ xem delivery là một loại đơn; nghiệp vụ điều phối shipper chưa được đưa vào MVP.

**Rủi ro:** Thấp nếu MVP không quản lý giao vận.

---

# 10. RỦI RO LỚN NHẤT CỦA PHASE

**Sai tiền do business rule không được bảo vệ ở tầng hệ thống; cách chặn là mọi invariant liên quan tiền phải có protection + verification trước khi DB được thiết kế.**

---

# 11. CÒN LẠI

**DB Design:** chuyển các invariant và ownership đã chốt thành mô hình dữ liệu, constraint, migration và dữ liệu mồi; không quay lại mở lại business rules nếu không có finding mới.
