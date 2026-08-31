Được. Dựa trên **fact duy nhất của quán** bạn cung cấp, tôi sẽ thiết kế phần **Admin** theo hướng: **Admin không phải một dashboard chung chung**, mà là hệ thống điều hành quán, bám trực tiếp vào 5 kênh bán, 5 trạm, 2 luồng bán và các quyền nghiệp vụ đã chốt.

Nguồn gốc nghiệp vụ là file fact của quán; file này quy định phạm vi bán, kênh, giá, vận hành và quy tắc nghiệp vụ, đồng thời là nguồn sự thật duy nhất. 

# 1. Mục tiêu của Admin

Admin cần giải quyết 6 việc chính:

```text
                    ADMIN
                      │
       ┌──────────────┼──────────────┐
       │              │              │
     ORDER          KITCHEN        TABLE
       │              │              │
   nhận/duyệt      điều phối       phiên bàn
   huỷ/thu tiền    các trạm        bàn trống
       │              │              │
       └──────────────┼──────────────┘
                      │
                   MONEY
                      │
             doanh thu / đối soát
                      │
                  SETTINGS
                      │
             menu / giá / quán
```

Điểm quan trọng: **Admin phải quản lý được cả tiền và vận hành**, không chỉ CRUD menu.

---

# 2. Cấu trúc Admin tổng thể

Tôi đề xuất:

```text
/admin
│
├── dashboard
│
├── orders
│   ├── pending
│   ├── active
│   ├── preparing
│   ├── ready
│   ├── delivering
│   ├── completed
│   └── cancelled
│
├── tables
│   ├── overview
│   └── sessions
│
├── kitchen
│   ├── trang_banh
│   ├── gap_banh
│   ├── canh
│   └── don_ban
│
├── menu
│   ├── items
│   ├── components
│   ├── options
│   └── pricing
│
├── payments
│   ├── transactions
│   ├── refunds
│   └── reconciliation
│
├── reports
│   ├── sales
│   ├── orders
│   ├── channels
│   └── daily
│
├── settings
│   ├── shop
│   ├── payment
│   ├── ordering
│   └── operations
│
└── audit
    └── activity-log
```

Nhưng **không nên làm tất cả ngay**.

---

# 3. Dashboard

Dashboard là màn hình chủ sau khi đăng nhập.

## Hiển thị

```text
┌──────────────────────────────────────────────┐
│ Bánh cuốn Bà Thanh                 08:32     │
├──────────────────────────────────────────────┤
│                                              │
│  Đơn chờ duyệt       Đang làm       Bàn dùng │
│       3                 7              5/11  │
│                                              │
├──────────────────────────────────────────────┤
│ DOANH THU HÔM NAY                            │
│                                              │
│              2.450.000đ                      │
│                                              │
├──────────────────────────────────────────────┤
│ ĐƠN HÀNG                                     │
│                                              │
│ Delivery       4                            │
│ Pickup         3                            │
│ Phone          2                            │
│ Tại bàn        8                            │
│                                              │
├──────────────────────────────────────────────┤
│ ⚠ CẦN XỬ LÝ                                  │
│                                              │
│ • 3 đơn chờ duyệt                            │
│ • 1 đơn đang giao                            │
│ • 1 đơn cần xác nhận thanh toán              │
│                                              │
└──────────────────────────────────────────────┘
```

Dashboard **không nên chứa quá nhiều biểu đồ** ở MVP.

Ưu tiên:

1. Việc cần xử lý ngay
2. Đơn hàng
3. Bàn
4. Tiền
5. Doanh thu

---

# 4. Orders — trung tâm của Admin

Đây là module quan trọng nhất.

## 4.1 Order list

```text
ORDER

[ Tất cả ] [Chờ duyệt] [Đang làm] [Sẵn sàng]
[Đang giao] [Hoàn thành] [Huỷ]

------------------------------------------------
#1024   delivery       08:15     68.000đ
#1025   qr_table       Bàn 5     34.000đ
#1026   pickup         09:00     59.000đ
#1027   phone_preorder 10:00     90.000đ
------------------------------------------------
```

Mỗi order cần cho thấy:

```text
order_id
channel
status
customer
items
total
payment_status
created_at
required_at
table/session nếu có
```

---

# 5. Order Detail

Đây phải là màn hình cực kỳ rõ ràng.

```text
ORDER #1024

Delivery
08:15
Trạng thái: CHỜ DUYỆT

Khách
────────────────
Nguyễn Văn A
038xxxxxxx
12 Nguyễn Trãi
Ghi chú: gọi trước khi giao

MÓN
────────────────
2 × Combo Đầy đủ tái
Thịt + mộc nhĩ
Nhiều nhân

34.000 × 2
                    68.000đ

THANH TOÁN
────────────────
Chưa thanh toán
Mặc định: thu khi giao

────────────────
[ DUYỆT ĐƠN ]

[ HUỶ ĐƠN ]
```

Sau khi duyệt:

```text
ĐÃ DUYỆT

        ↓

TRÁNG BÁNH
        ↓
GẤP BÁNH
        ↓
CANH
        ↓
ĐÓNG GÓI
        ↓
ĐANG GIAO
        ↓
ĐÃ GIAO + ĐÃ THU
```

Điều này bám đúng luật: đơn do khách gửi phải được quầy duyệt, còn đơn do nhân viên nhập thì không cần duyệt. Đơn chưa duyệt không được sinh việc ở trạm. 

---

# 6. POS / Quầy

Tôi khuyên **không tách POS khỏi Admin về mặt backend domain**.

Có thể có:

```text
/admin/pos
```

hoặc UI riêng:

```text
/pos
```

nhưng vẫn dùng chung domain Order.

POS cần hỗ trợ:

### Bán tại bàn

```text
BÀN

01  Trống
02  Đang dùng
03  Trống
04  Đang dùng
05  Đang dùng
...
11  Trống
```

Click bàn 5:

```text
BÀN 5

Phiên #S005

09:01
────────────────

2 × Bánh cuốn        8.000
1 × Suất giò         29.000

────────────────
Tạm tính              45.000

[ + THÊM MÓN ]

[ BẮT ĐẦU THANH TOÁN ]
```

---

# 7. Luật cực kỳ quan trọng: Table Session

Admin phải có khái niệm:

```text
Table
   ↓
Table Session
   ↓
Orders
   ↓
Payment
```

Không được:

```text
Table
 ├── Order 1
 ├── Order 2
 └── Order 3
```

rồi mỗi order tự thanh toán.

Vì `qr_table` và `staff_pos` phải gộp vào **một phiên bàn và một hóa đơn**, kể cả khách gọi nhiều lượt. 

Đặc biệt:

```text
WAITING_PAYMENT

≠

CLOSED
```

Nếu khách gọi thêm trong lúc quầy đang thu tiền, vẫn phải thuộc **cùng phiên và cùng hóa đơn**; chỉ sau khi đóng phiên mới giải phóng bàn. 

Đây nên trở thành một invariant ở backend.

---

# 8. Kitchen Admin

Đây là phần rất quan trọng và khác với e-commerce thông thường.

Không cho bếp nhìn:

```text
Combo Đầy đủ × 2
```

mà phải explode thành component.

Ví dụ:

```text
TRÁNG BÁNH
────────────────────
Bánh cuốn × 6
Thịt + mộc nhĩ
Nhiều

Trứng tái × 2
Thịt + mộc nhĩ
Nhiều
```

```text
GẤP BÁNH
────────────────────
Bánh cuốn × 6
Thịt + mộc nhĩ
Nhiều

Trứng tái × 2

Giò × 2
```

```text
CANH
────────────────────
Nước chấm
Bàn 5
2 suất
```

Đây chính xác là mô hình nghiệp vụ đã được chốt: bếp phải nhận **thành phần thực tế**, không nhận một dòng combo mơ hồ. 

---

# 9. Kitchen Stations

Admin nên có màn hình theo 4 vai vận hành:

```text
QUẦY
TRÁNG BÁNH
GẤP BÁNH
CANH + DỌN BÀN
```

Mặc dù nghiệp vụ có **5 trạm**, `canh` và `don_ban` do cùng một người đảm nhiệm. 

### Tráng bánh

```text
┌──────────────────────────┐
│ #1024                     │
│ Bánh cuốn ×6              │
│ Thịt + mộc nhĩ             │
│ Nhiều nhân                │
│                           │
│ [ ĐANG LÀM ] [ XONG ]     │
└──────────────────────────┘
```

### Gấp bánh

Tương tự nhưng chỉ hiện component thuộc station.

### Canh

```text
#1024
Nước chấm × 2
Delivery
[ ĐÃ CHUẨN BỊ ]
```

### Dọn bàn

```text
Bàn 5
Phiên #S005
Đã đóng
[ BẮT ĐẦU DỌN ]

        ↓

[ BÀN TRỐNG ]
```

---

# 10. Menu Admin

Đây là nơi tôi **không khuyến nghị cho admin nhập giá suất thủ công**.

Fact đã xác định:

```text
giá suất
=
tổng giá thành phần
+
phụ thu
```

Giá thành phần mới là nguồn dữ liệu. 

Do đó UI nên là:

```text
MENU
│
├── Thành phần
│
│   Bánh cuốn
│   ├── Chay       3.000
│   ├── Thịt       4.000
│   └── Nhiều      5.000
│
│   Trứng
│   ├── Chay       8.000
│   ├── Thịt       9.000
│   └── Nhiều     10.000
│
│   Giò             9.000
│
├── Suất bán
│
│   Bánh cuốn
│   Suất trứng
│   Suất giò
│   Combo đầy đủ
│
└── Tuỳ chọn
    ├── Nhân
    └── Lượng nhân
```

---

# 11. Pricing Engine

Tôi đề xuất tách hẳn:

```text
pricing/
```

khỏi UI Admin.

Ví dụ:

```text
calculatePrice(orderLine)
```

Input:

```text
product = "suất_trứng"
filling = "meat"
amount = "normal"
```

Engine:

```text
egg(meat)
+
4 × cake(meat)
```

=

```text
9.000 + 4 × 4.000
= 25.000
```

Không được:

```text
price = request.price
```

Fact đã chốt rõ khách **không bao giờ gửi giá lên**; hệ thống phải tự tính lại từ bảng giá. 

---

# 12. Pricing Admin phải có Preview

Đây là tính năng rất đáng làm.

Admin thay đổi giá:

```text
Bánh cuốn — Thịt

Giá hiện tại: 4.000
Giá mới:      4.500

ẢNH HƯỞNG:

Suất bánh cuốn       4.500
Suất giò              27.000
Suất trứng             27.000
Combo                  31.500

[ HUỶ ] [ XÁC NHẬN ]
```

Như vậy owner thấy **giá thành phần thay đổi kéo theo giá suất** thế nào.

---

# 13. Payment Admin

Có 4 nhóm:

```text
Payments
│
├── Unpaid
├── Paid
├── Refund required
└── Refunded
```

Ví dụ:

```text
ORDER #1024

68.000đ

Payment
────────────────
Status: UNPAID
Method: COD

[ XÁC NHẬN ĐÃ THU ]
```

VietQR là **static QR**, nên Admin phải có thao tác xác nhận thủ công; hệ thống không được giả định rằng đã nhận tiền chỉ vì khách nói đã chuyển khoản. 

---

# 14. Refund

Refund cần UI riêng:

```text
REFUND

Order: #1024
Paid: 68.000đ

Số tiền hoàn:
[ 68.000 ]

Lý do:
[ Khách huỷ đơn ]

Người thực hiện:
Người đứng quầy

[ XÁC NHẬN HOÀN ]
```

Backend phải lưu:

```text
refund
├── order_id
├── amount
├── reason
├── created_by
└── created_at
```

Không nên thiết kế:

```text
refund = true
```

vì nghiệp vụ yêu cầu phải biết **hoàn bao nhiêu, cho đơn nào, ai bấm, lý do gì**. 

---

# 15. Cancel Order

Đây là nơi cần đặc biệt cẩn thận.

Không phải:

```text
if user.isAdmin:
    cancel()
```

Mà:

```text
CanCancelOrder(actor, context)
```

Fact đã chốt:

> Chỉ người đứng quầy được huỷ đơn.

Và quyền này gắn với **chỗ đứng**, không gắn với chức vụ. Chủ quán nếu không đứng quầy cũng phải nhờ người đứng quầy bấm trên POS. 

Do đó hệ thống nên có concept:

```text
current_station_assignment
```

Ví dụ:

```text
User: Owner
Current station: owner
Can cancel: NO

User: Employee A
Current station: quay
Can cancel: YES
```

Đây là một business rule rất đáng đưa xuống backend.

---

# 16. Delivery

Delivery có lifecycle riêng:

```text
PENDING
   ↓
APPROVED
   ↓
PREPARING
   ↓
PACKED
   ↓
OUT_FOR_DELIVERY
   ↓
DELIVERED
```

Khi giao xong:

```text
[ ĐÃ GIAO + ĐÃ THU TIỀN ]
```

Không nên cho:

```text
DELIVERED
```

mà payment vẫn vô tình chưa xử lý trong đường mặc định.

Fact quy định quán tự đi giao và đơn giao phải có trạng thái **đang giao**. 

---

# 17. Pickup

Pickup có:

```text
required_at
```

Ví dụ:

```text
ORDER #1026

Pickup
Khách cần: 09:30

08:45  Approved
08:50  Preparing
09:05  Ready
09:25  Customer arrived
09:26  Paid
09:27  Completed
```

`pickup` bắt buộc có giờ hẹn lấy. 

---

# 18. Phone Preorder

Đây là một module nhỏ nhưng phải làm đúng.

POS:

```text
NEW PHONE ORDER

Số điện thoại *
[ 0382688666 ]

Tên
[ Nguyễn Văn A ]

Khách muốn:
( ) Giao tận nơi
( ) Tới lấy

Giờ cần hàng *
[ 10:00 ]

Địa chỉ giao
[................]

Món:
[ + Thêm món ]

[ TẠO ĐƠN ]
```

Không có:

```text
table
```

và không có:

```text
approval
```

vì nhân viên đã nhập đơn thay khách.

Fact cũng chốt rằng `phone_preorder` là kênh riêng, không được dùng `staff_pos` cho đơn hotline. 

---

# 19. Table Admin

Màn hình:

```text
TABLES

01  AVAILABLE
02  AVAILABLE
03  OCCUPIED
04  AVAILABLE
05  PAYMENT
06  OCCUPIED
07  AVAILABLE
...
11  AVAILABLE
```

Mỗi bàn:

```text
Table #5

Status: OCCUPIED

Session:
S-20260831-005

Started:
08:15

Orders:
3

Total:
124.000đ

[ VIEW SESSION ]
```

---

# 20. Reports

MVP chỉ cần:

### Daily Sales

```text
DOANH THU HÔM NAY

Tại bàn          1.240.000
Delivery           420.000
Pickup             310.000
Phone              280.000

TOTAL            2.250.000
```

Điều này quan trọng vì doanh thu phải cộng từ:

```text
table sessions
+
standalone orders
```

chứ không chỉ cộng `orders`. 

### Theo channel

```text
qr_table
staff_pos
delivery
pickup
phone_preorder
```

### Theo payment

```text
cash
vietqr
```

### Refund

```text
Gross sales
- refunds
= Net
```

---

# 21. Daily Reconciliation

Đây phải là màn hình riêng, không giấu trong report.

```text
DAILY RECONCILIATION

Date: 31/08/2026

System sales
                2.450.000đ

Cash expected
                1.650.000đ

Cash counted
                1.650.000đ

VietQR
                  800.000đ

Refunds
                   50.000đ

Difference
                        0đ

STATUS
✓ RECONCILED

[ CONFIRM ]
```

Nếu:

```text
Difference = 1đ
```

thì:

```text
⚠ RECONCILIATION FAILED
```

Không có:

```text
close anyway
```

vì quy định đối soát yêu cầu **lệch 1 đồng cũng phải tìm ra lý do**. 

---

# 22. Settings

Admin Settings chỉ chứa những thứ thực sự được phép cấu hình.

## Shop

```text
Tên quán
Hotline
Giờ mở cửa
Timezone
Số bàn
```

Hiện tại:

```text
06:00 - 11:00
11 tables
Asia/Ho_Chi_Minh
```

## Payment

```text
VietQR
Account name
Account number
Bank
QR image
```

Số tài khoản **không hard-code vào product**; chủ quán nhập trong quản trị. 

---

# 23. Pause Ordering

Đây là một feature quan trọng:

```text
[ 🟢 ĐANG NHẬN ĐƠN ]

[ TẠM DỪNG NHẬN ĐƠN ]
```

Khi bật:

```text
⚠ QUÁN TẠM DỪNG NHẬN ĐƠN

Lý do:
Hết bánh / hết nguyên liệu

Đơn mới:
BLOCKED
```

Priority:

```text
MANUAL PAUSE
      >
OPENING HOURS
```

Tức là chủ quán có thể đóng nhận đơn giữa giờ nếu hết nguyên liệu. 

---

# 24. Audit Log

Tôi rất khuyến nghị làm từ đầu.

```text
AUDIT LOG

09:15
Employee A
APPROVED
Order #1024

09:22
Employee A
CONFIRMED PAYMENT
Order #1024
68.000đ

09:30
Employee A
CANCELLED
Order #1027
Reason: customer cancelled

09:35
Employee A
REFUNDED
Order #1027
50.000đ
```

Đặc biệt các hành động:

```text
approve
cancel
payment confirmation
refund
price change
pause ordering
session close
reconciliation
```

phải có audit.

---

# 25. Data model Admin nên xoay quanh

Tôi sẽ **không bắt đầu bằng UI**.

Nên thiết kế domain trước:

```text
Shop
 │
 ├── Tables
 │
 ├── Menu
 │    ├── Components
 │    ├── Products
 │    └── Options
 │
 ├── Orders
 │    ├── OrderItems
 │    └── OrderComponents
 │
 ├── TableSessions
 │    └── Orders
 │
 ├── Payments
 │
 ├── Refunds
 │
 ├── KitchenJobs
 │    ├── trang_banh
 │    ├── gap_banh
 │    ├── canh
 │    └── don_ban
 │
 ├── StationAssignments
 │
 ├── Reconciliations
 │
 └── AuditLogs
```

Đây mới là **xương sống của Admin**.

---

# 26. Trạng thái Order

Tôi đề xuất chuẩn hoá state machine thay vì cho từng màn hình tự đổi status:

```text
DRAFT
  │
  ▼
PENDING_APPROVAL
  │
  ▼
APPROVED
  │
  ▼
PREPARING
  │
  ▼
READY
  │
  ├──────────────► OUT_FOR_DELIVERY
  │                       │
  │                       ▼
  │                   DELIVERED
  │
  └──────────────► PICKUP_READY
                          │
                          ▼
                      COMPLETED
```

Các nhánh:

```text
CANCELLED
REFUND_PENDING
REFUNDED
```

phải có transition rule riêng.

---

# 27. Nhưng có một điểm tôi muốn chỉnh trong kiến trúc

**Đừng xây "Admin CRUD" trước.**

Với dự án này, thứ tự đúng nên là:

```text
                BUSINESS FACT
                     │
                     ▼
                DOMAIN MODEL
                     │
                     ▼
              STATE MACHINES
                     │
                     ▼
              BUSINESS RULES
                     │
                     ▼
                ADMIN/POS
                     │
                     ▼
                 REPORTING
```

Không nên:

```text
Admin UI
   ↓
API CRUD
   ↓
Database
```

Vì như vậy rất dễ tạo ra những lỗi kiểu:

```text
Order được huỷ bởi người không đứng quầy
Combo xuống bếp thành 1 dòng
Bàn bị đóng nhưng vẫn gọi thêm
Delivery được completed nhưng chưa thu tiền
Giá được client gửi lên
Phone preorder bị gắn bàn
Doanh thu bỏ sót table session
```

---

# 28. MVP Admin tôi đề xuất

Không cần làm toàn bộ ở phiên bản đầu.

## Phase A — Core operation

```text
01  Login
02  Dashboard
03  POS
04  Orders
05  Table sessions
06  Kitchen jobs
07  Payment
08  Cancel
```

Đây là **MVP bắt buộc**.

## Phase B — Management

```text
09  Menu
10  Pricing
11  Delivery
12  Pickup
13  Phone preorder
14  Shop settings
15  Pause ordering
```

## Phase C — Money control

```text
16  Refund
17  Daily reconciliation
18  Sales reports
19  Channel reports
20  Audit log
```

## Phase D — Optimization

```text
21  Kitchen workload
22  Sales analytics
23  Operational analytics
24  Staff/station monitoring
25  Advanced dashboard
```

---

# 29. Cấu trúc code tôi khuyên dùng

Nếu project của bạn đang theo hướng **Lean AI Engineering System**, phần Admin nên nằm theo domain chứ không phải một đống component UI:

```text
code/
├── be/
│   ├── internal/
│   │   ├── order/
│   │   ├── table/
│   │   ├── menu/
│   │   ├── pricing/
│   │   ├── payment/
│   │   ├── refund/
│   │   ├── kitchen/
│   │   ├── reconciliation/
│   │   └── audit/
│   │
│   └── ...
│
└── fe/
    ├── admin/
    │   ├── dashboard/
    │   ├── orders/
    │   ├── pos/
    │   ├── tables/
    │   ├── kitchen/
    │   ├── menu/
    │   ├── payments/
    │   ├── reports/
    │   ├── reconciliation/
    │   └── settings/
    │
    └── ...
```

Quan trọng hơn nữa:

```text
pricing
order lifecycle
payment
table session
kitchen decomposition
authorization
```

**không được nằm trong frontend.**

---

# 30. Admin cuối cùng sẽ có 3 "mặt" khác nhau

Tôi nghĩ đây là cách tổ chức tốt nhất cho dự án của bạn:

```text
                    ADMIN SYSTEM
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
       POS            KITCHEN          OWNER
        │                │                │
   nhận đơn          nhận việc        quản trị
   thu tiền          làm món          giá/menu
   quản bàn          hoàn thành       báo cáo
   huỷ đơn           dọn bàn          đối soát
```

### POS

**Điều hành tiền + đơn + bàn**

### Kitchen

**Điều hành việc phải làm**

### Owner/Admin

**Điều hành cấu hình + tiền + báo cáo**

Nhưng cả ba dùng chung **một domain model và một business rule engine**.

---

## Bộ Admin BA nên tạo tiếp theo

Nếu triển khai theo framework bạn đang xây, tôi sẽ tách thành các artifact sau:

```text
harness/
└── plans/
    └── admin/
        ├── 00-admin-scope.md
        ├── 01-admin-actors.md
        ├── 02-admin-permissions.md
        ├── 03-order-management.md
        ├── 04-table-session.md
        ├── 05-kitchen.md
        ├── 06-payment.md
        ├── 07-refund.md
        ├── 08-menu-pricing.md
        ├── 09-delivery-pickup-phone.md
        ├── 10-reconciliation.md
        ├── 11-reports.md
        ├── 12-settings.md
        ├── 13-audit-log.md
        ├── 14-state-machines.md
        └── 15-admin-acceptance.md
```

**Tôi khuyên bước tiếp theo chưa viết code.** Hãy làm `00-admin-scope.md` trước để khóa phạm vi Admin, sau đó `01-admin-actors.md` + `02-admin-permissions.md`, rồi mới đi vào Order/Table/Kitchen. Như vậy Admin sẽ trở thành một phần chính thức của BA/Fact system thay vì một dashboard được phát triển song song và dễ lệch nghiệp vụ.


..............2222222222222222222222222

Đúng. Với yêu cầu này, tôi thấy **thiết kế Admin trước đó còn thiếu một lớp rất quan trọng: Production Planning / Kitchen Control**.

Bạn không chỉ cần biết **"có bao nhiêu order"**, mà người đứng quầy phải nhìn được:

> **Hiện tại quán đang phải sản xuất tổng cộng bao nhiêu cái bánh, bao nhiêu trứng từng loại, bao nhiêu canh/nước chấm; cái nào đã làm, đã phục vụ, còn thiếu; thiếu cho bàn nào; và nên gom việc nào để bếp làm theo batch tối ưu.**

Điều này phù hợp trực tiếp với fact hiện tại: một suất bán phải được "nổ" thành các thành phần bếp cần làm, chứ bếp không được nhìn một dòng `Combo ×2` mơ hồ. 

## 1. Tôi sẽ đổi kiến trúc Admin thành 3 lớp

```text
                         ADMIN
                           │
          ┌────────────────┼─────────────────┐
          │                │                 │
          ▼                ▼                 ▼
        POS            PRODUCTION         OWNER
      / QUẦY           CONTROL           REPORT
          │                │
          │                │
          ▼                ▼
   Đơn + bàn + tiền    Bếp phải làm gì?
                       Làm bao nhiêu?
                       Cho ai?
                       Còn thiếu gì?
```

Trong đó **Production Control** là màn hình trung tâm cho người đứng quầy.

---

# 2. Màn hình chính của POS không nên là Order List

Thay vì:

```text
Orders
#1001
#1002
#1003
...
```

tôi đề xuất màn hình chính:

# **QUẦY — TỔNG QUAN PHỤC VỤ**

```text
┌─────────────────────────────────────────────────────────────┐
│ QUẦY                                      08:32             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BÀN ĐANG ĂN       CHỜ PHỤC VỤ       ĐANG THIẾU            │
│      6                   2                  5               │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ SẢN XUẤT CẦN LÀM                                          │
│                                                             │
│  BÁNH CUỐN                         31 cái                  │
│  TRỨNG                              8 quả                  │
│    ├── Chín                         3                     │
│    ├── Tái                          3                     │
│    └── Vàng                         2                     │
│                                                             │
│  NƯỚC CHẤM                          7 suất                 │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ BẾP ĐANG LÀM                                             │
│                                                             │
│  Tráng bánh       12 / 31                                │
│  Trứng             4 / 8                                 │
│  Gấp bánh          9 / 31                                │
│  Canh              5 / 7                                 │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│ BÀN                                                      │
│                                                             │
│  Bàn 2   Đang phục vụ     còn 2 bánh + 1 trứng tái       │
│  Bàn 5   Đang phục vụ     còn 4 bánh                     │
│  Bàn 7   Chờ món          còn 3 bánh + 2 trứng chín      │
│  Bàn 8   Chờ món          còn 6 bánh + 2 trứng vàng      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Đây mới là **control tower của quầy**.

---

# 3. Phải phân biệt 4 con số

Đây là phần rất quan trọng.

Không chỉ có:

```text
ORDERED
```

mà cần:

```text
ORDERED
   ↓
NEEDED
   ↓
PRODUCED
   ↓
SERVED
```

Ví dụ bàn 5:

```text
Bàn 5

Khách gọi:
6 bánh
2 trứng tái
2 giò

Đã sản xuất:
4 bánh
1 trứng

Đã phục vụ:
3 bánh
1 trứng

Còn khách chờ:
3 bánh
1 trứng tái
2 giò
```

Nhưng production cũng phải biết:

```text
TỔNG CẦN
6 bánh
2 trứng

ĐÃ SẢN XUẤT
4 bánh
1 trứng

CÒN PHẢI SẢN XUẤT
2 bánh
1 trứng
```

Và service lại có thể khác:

```text
ĐÃ RA BÀN
3 bánh
1 trứng

CÒN CHỜ PHỤC VỤ
3 bánh
1 trứng
```

Do đó:

```text
                    ORDER
                      │
             ┌────────┴────────┐
             ▼                 ▼
       PRODUCTION            SERVICE
             │                 │
       cần sản xuất       cần mang ra
             │                 │
             ▼                 ▼
       đã sản xuất       đã phục vụ
```

---

# 4. Đặc biệt: Production phải GỘP các bàn

Đây chính là insight quan trọng nhất trong yêu cầu của bạn.

Ví dụ 6 người vào cùng lúc:

```text
Bàn 1
1 Combo đầy đủ

Bàn 2
1 Combo đầy đủ

Bàn 3
1 Combo đầy đủ

Bàn 4
1 Combo đầy đủ

Bàn 5
1 Combo đầy đủ

Bàn 6
1 Combo đầy đủ
```

Không được biến thành:

```text
Bàn 1 → làm 1 trứng
Bàn 2 → làm 1 trứng
Bàn 3 → làm 1 trứng
...
```

Mà Production Control phải nhìn:

```text
TRỨNG

Chín      2
Tái       2
Vàng      2

TOTAL     6
```

Sau đó hệ thống biết:

```text
1 nồi = 3 quả
2 nồi = 6 quả

→ Có thể chạy 6 quả cùng một batch
```

**Đây là optimization của production, không phải optimization của order.**

---

# 5. Production Board nên có 2 chiều nhìn

Tôi sẽ làm:

```text
             PRODUCTION CONTROL

       [ THEO TỔNG ]       [ THEO BÀN ]
```

## Theo tổng

```text
╔══════════════════════════════════════╗
║ CẦN LÀM NGAY                         ║
╠══════════════════════════════════════╣
║                                      ║
║ BÁNH CUỐN                            ║
║ ████████████████          24 / 36    ║
║                                      ║
║ TRỨNG                                 ║
║                                      ║
║ Chín       ███████          3 / 5    ║
║ Tái        █████████        4 / 4    ║
║ Vàng       ███              1 / 3    ║
║                                      ║
║ NƯỚC CHẤM                            ║
║ ███████████               5 / 8      ║
╚══════════════════════════════════════╝
```

---

# 6. Nhưng tổng thôi vẫn chưa đủ

Nếu chỉ hiển thị:

```text
Bánh: 36
Trứng: 6
```

người đứng quầy sẽ không biết:

> "36 cái bánh này dành cho bàn nào?"

Vì vậy phải có **allocation**.

Ví dụ:

```text
TỔNG BÁNH CÒN THIẾU: 12

Bàn 1     2
Bàn 3     4
Bàn 5     3
Bàn 6     3
```

Trứng:

```text
TRỨNG CÒN THIẾU: 5

Chín
Bàn 1     1
Bàn 6     2

Tái
Bàn 3     1

Vàng
Bàn 5     1
```

Như vậy người quầy biết:

> **Tôi có thể gom production, nhưng vẫn biết thành phẩm cuối cùng thuộc về ai.**

---

# 7. Đây là mô hình tôi khuyên dùng

```text
                    ORDER
                      │
                      ▼
               ORDER COMPONENT
                      │
          ┌───────────┼───────────┐
          │           │           │
        BÁNH         TRỨNG       GIÒ
          │           │
          │       ┌───┼────┐
          │       │   │    │
          │      CHÍN TÁI  VÀNG
          │
          ▼
      PRODUCTION
          │
          ▼
       BATCH
          │
          ▼
     PRODUCED ITEM
          │
          ▼
       SERVICE
          │
          ▼
        TABLE
```

**Order line** là thứ khách mua.

**Order component** là thứ bếp phải làm.

**Batch** là cách bếp gom nhiều component để sản xuất hiệu quả.

**Service** là thứ đã thực sự đưa ra bàn.

Đây là 4 khái niệm khác nhau.

---

# 8. Batch Production

Tôi nghĩ đây nên là một domain chính:

```text
production/
├── demand
├── batch
├── production_job
└── service
```

Ví dụ:

```text
Batch #001

Loại: TRỨNG
────────────────────

Chín     3
Tái      2
Vàng     1

TOTAL    6

Thiết bị:
Nồi 1
Nồi 2

[ BẮT ĐẦU ]
```

Sau khi làm:

```text
Batch #001

6 / 6 DONE

Phân bổ:

Bàn 1 → chín ×1
Bàn 2 → chín ×1
Bàn 3 → chín ×1

Bàn 4 → tái ×1
Bàn 5 → tái ×1

Bàn 6 → vàng ×1
```

---

# 9. Nhưng hệ thống KHÔNG nên tự quyết định quá sâu

Có một điểm cần giữ:

```text
SYSTEM
  ↓
tổng hợp nhu cầu
  ↓
đề xuất batch
  ↓
NGƯỜI BẾP / QUẦY quyết định
```

Không nên ngay từ đầu làm:

```text
AI tự quyết định:
Nồi 1 làm...
Nồi 2 làm...
lúc 08:37...
```

MVP chỉ cần:

> **Hệ thống cho người đứng quầy thấy tổng nhu cầu và cho phép gom thành batch.**

Sau này mới tối ưu algorithm.

---

# 10. Bánh cuốn cũng phải gom

Ví dụ:

```text
6 khách:

Combo × 6

Bếp cần:

Bánh cuốn = 18
Trứng = 6
Giò = 6
Nước chấm = 6
```

Fact hiện tại quy định Combo Đầy đủ gồm:

```text
3 bánh
+
1 trứng
+
1 giò
```

và khi xuống bếp phải explode thành:

```text
Bánh ×18
Trứng ×6
Giò ×6
Nước chấm ×6
```



Nhưng **không có nghĩa là phải sản xuất 18 bánh một lúc**.

Production có thể:

```text
TRỨNG
Batch 6

BÁNH
Batch 6
Batch 6
Batch 6

GIÒ
Batch 6

CANH
Batch 6
```

hoặc điều chỉnh theo tình hình thực tế.

---

# 11. Bảng "Quán hiện tại"

Tôi rất thích ý bạn nói:

> "tôi cần nắm được hiện tại quán thế nào"

Vậy nên POS cần một bảng **LIVE FLOOR**.

```text
┌──────┬───────────────┬───────────────┬─────────────────────┐
│ Bàn  │ Trạng thái    │ Đã phục vụ    │ Còn thiếu           │
├──────┼───────────────┼───────────────┼─────────────────────┤
│ 01   │ Đang ăn       │ 3/5 món       │ 2 bánh              │
│ 02   │ Chờ món       │ 0/5           │ 3 bánh + 2 trứng    │
│ 03   │ Đang ăn       │ 4/4           │ —                   │
│ 04   │ Chờ phục vụ   │ 2/6           │ 4 bánh              │
│ 05   │ Đang ăn       │ 3/6           │ 2 bánh + 1 trứng    │
│ 06   │ Chờ thanh toán│ 6/6           │ —                   │
└──────┴───────────────┴───────────────┴─────────────────────┘
```

Chỉ cần nhìn bảng này, người đứng quầy biết ngay:

```text
Bàn nào đang ăn?
Bàn nào đang chờ?
Bàn nào thiếu món?
Bàn nào đủ?
Bàn nào chờ thanh toán?
```

---

# 12. Thêm "Kitchen Demand"

Ngay bên cạnh:

```text
┌─────────────────────────────────────┐
│ BẾP CÒN PHẢI LÀM                    │
├─────────────────────────────────────┤
│                                     │
│ Bánh cuốn              14           │
│                                     │
│ Trứng chín              3           │
│ Trứng tái               4           │
│ Trứng vàng              2           │
│                                     │
│ Giò                     5           │
│ Nước chấm               7           │
│                                     │
└─────────────────────────────────────┘
```

Và thêm:

```text
ĐANG LÀM

Bánh cuốn       8
Trứng           6
Giò             3
Nước chấm       4
```

Do đó:

```text
DEMAND
-
PRODUCED
=
OUTSTANDING
```

---

# 13. Một bảng cực kỳ hữu ích: "Thiếu gì?"

```text
⚠ CẦN LÀM

BÁNH
14 cái

TRỨNG
Chín       3
Tái        4
Vàng       2

GIÒ
5

CANH
7
```

Click `Trứng tái`:

```text
TRỨNG TÁI — CÒN THIẾU 4

Bàn 2     1
Bàn 5     1
Bàn 7     2

[ TẠO BATCH ]
```

Click:

```text
[ TẠO BATCH ]
```

→

```text
BATCH TRỨNG

Tái ×4

Phân bổ:
Bàn 2 ×1
Bàn 5 ×1
Bàn 7 ×2

[ BẮT ĐẦU ]
```

---

# 14. Quan trọng: "Đã phục vụ" không phải "đã sản xuất"

Ví dụ:

```text
Bàn 5 cần:

6 bánh
2 trứng
```

Bếp đã làm:

```text
6 bánh
2 trứng
```

nhưng mới mang ra:

```text
3 bánh
1 trứng
```

thì POS phải hiển thị:

```text
PRODUCED
6 bánh
2 trứng

SERVED
3 bánh
1 trứng

WAITING SERVICE
3 bánh
1 trứng
```

Không được tự động coi:

```text
produced = served
```

Đây sẽ là một domain state riêng.

---

# 15. Tôi đề xuất State cho từng component

```text
PENDING
   ↓
QUEUED
   ↓
IN_PRODUCTION
   ↓
PRODUCED
   ↓
READY_FOR_SERVICE
   ↓
SERVED
```

Nếu huỷ trước production thì:

```text
CANCELLED
```

Nhưng **Order** và **Component** có state khác nhau.

Ví dụ:

```text
ORDER #1025
APPROVED

Components:

Bánh ×6
SERVED 3
PRODUCED 6

Trứng ×2
SERVED 1
PRODUCED 2

Giò ×2
SERVED 2
```

Order vẫn:

```text
PARTIALLY_SERVED
```

---

# 16. Từ đây POS có thể có một màn hình cực mạnh

## **LIVE CONTROL**

```text
╔══════════════════════════════════════════════════════════════╗
║                     QUÁN HIỆN TẠI                            ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║ BÀN       6 đang ăn     2 chờ món     1 thanh toán           ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                    CẦN SẢN XUẤT                              ║
║                                                              ║
║ Bánh cuốn                                14                  ║
║ Trứng chín                                3                  ║
║ Trứng tái                                 4                  ║
║ Trứng vàng                                2                  ║
║ Giò                                        5                  ║
║ Nước chấm                                 7                  ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                    ĐANG SẢN XUẤT                             ║
║                                                              ║
║ Batch #18  Trứng       6/6                   ✓               ║
║ Batch #19  Bánh        6/12                  ███             ║
║ Batch #20  Giò         3/5                   ██              ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                    CẦN PHỤC VỤ                               ║
║                                                              ║
║ Bàn 2       2 bánh + 1 trứng tái                            ║
║ Bàn 5       3 bánh                                          ║
║ Bàn 7       2 bánh + 2 trứng chín                           ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                    BÀN                                      ║
║                                                              ║
║ 01  ĂN       02  CHỜ      03  ĂN       04  TRỐNG            ║
║ 05  ĂN       06  THANH    07  CHỜ      08  TRỐNG            ║
║ 09  TRỐNG    10  ĂN       11  TRỐNG                         ║
╚══════════════════════════════════════════════════════════════╝
```

**Đây mới chính là Admin/POS phù hợp với quán của bạn.**

---

# 17. Và tôi sẽ sửa lại cấu trúc Admin trước đó

Thành:

```text
admin/
│
├── live/
│   ├── floor
│   ├── production
│   └── service
│
├── pos/
│   ├── orders
│   ├── tables
│   └── payment
│
├── production/
│   ├── demand
│   ├── batches
│   ├── stations
│   └── jobs
│
├── kitchen/
│   ├── trang_banh
│   ├── gap_banh
│   ├── canh
│   └── don_ban
│
├── orders/
│
├── menu/
│
├── pricing/
│
├── payments/
│
├── reconciliation/
│
├── reports/
│
├── settings/
│
└── audit/
```

Trong đó:

> **`live/` + `production/` là hai module mới cực kỳ quan trọng.**

---

# 18. Domain model cũng phải thêm Production

Tôi sẽ thiết kế:

```text
Order
  │
  └── OrderItem
         │
         └── OrderComponent
                │
                ├── production demand
                │
                ├── batch
                │
                └── service
```

Và:

```text
ProductionDemand
        │
        ├── component_type
        ├── filling
        ├── filling_amount
        ├── quantity
        ├── served_quantity
        ├── produced_quantity
        └── status
```

Sau đó:

```text
ProductionBatch
        │
        ├── component_type
        ├── quantity
        ├── production_station
        └── batch_items
                 │
                 ├── table/session
                 ├── order
                 └── quantity
```

Điều này cho phép:

```text
6 trứng từ 6 order
        ↓
        ↓
    1 BATCH
        ↓
     6 quả
        ↓
 phân bổ lại
        ↓
6 bàn khác nhau
```

Đây chính là thứ kiến trúc Order thông thường không giải quyết được.

---

# 19. Một nguyên tắc rất quan trọng

**Order là đơn vị kinh doanh.**

**Production batch là đơn vị sản xuất.**

Hai thứ này **không phải một**.

```text
6 orders
   ↓
có thể tạo
   ↓
1 production batch
```

và:

```text
1 order
   ↓
có thể tạo
   ↓
nhiều production batch
```

Ví dụ một combo:

```text
Batch 1
6 trứng

Batch 2
6 bánh

Batch 3
6 bánh

Batch 4
6 giò
```

Điều này phản ánh đúng cách quán thực sự vận hành.

---

## 20. Đây nên là mục tiêu của Admin

Tôi sẽ định nghĩa Admin/POS của dự án bằng câu này:

> **"Người đứng quầy nhìn một màn hình và biết ngay: quán đang có bao nhiêu bàn, bàn nào đang ăn, bàn nào đang chờ, mỗi bàn đã được phục vụ bao nhiêu, còn thiếu gì; đồng thời bếp tổng cộng còn phải làm bao nhiêu bánh, bao nhiêu trứng theo từng loại, bao nhiêu giò và nước chấm — và có thể gom các nhu cầu đó thành batch sản xuất để tận dụng năng lực của bếp."**

Điểm này **nên trở thành một yêu cầu cốt lõi của Admin**, không phải một feature phụ.

Và từ đây, tôi sẽ **không tiếp tục viết `admin-scope` theo kiểu CRUD nữa**. Artifact BA tiếp theo hợp lý nhất là thiết kế riêng **`production-control.md`**, trong đó khóa 5 thứ: **Demand → Batch → Production → Service → Live Floor**, rồi dùng nó làm nền cho UI POS và các API/backend sau này.
