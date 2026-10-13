# BE Features — Danh Sách Tính Năng & Function Theo Domain

> Liệt kê **toàn bộ tính năng backend** và **các function** thực hiện chúng, chia theo domain và theo tầng `handler → service → repository`.
> Cấu trúc thư mục + quy ước kiến trúc → [`BE_STRUCTURE_GUIDE.md`](BE_STRUCTURE_GUIDE.md).
> Route + quyền lấy từ `be/cmd/server/main.go` (nguồn sự thật — comment trong handler có chỗ ghi method/quyền cũ).
> Snapshot code ngày 2026-10-12.

**Ký hiệu quyền:** `Public` = không cần token · `Auth` = có JWT bất kỳ (guest hoặc staff) · `Chef+` / `Cashier+` / `Manager+` / `Admin` = `middleware.AtLeast(role)`.
Cấp role: customer (1, tách riêng) · chef = cashier (2) · staff (3) · manager (4) · admin (5).

---

## Mục Lục

| # | Domain | Số endpoint | Ghi chú |
|---|---|---|---|
| 1 | [Auth](#1-auth) | 7 | Login staff, refresh cookie, guest QR / online |
| 2 | [Products](#2-products--categories--toppings--combos) | 18 | Món, danh mục, topping, combo + cache Redis |
| 3 | [Orders](#3-orders) | 11 | Tạo đơn, thêm món, đổi trạng thái, huỷ, phục vụ |
| 4 | [Order Groups](#4-order-groups-gộp-đơn) | 6 | Gộp nhiều đơn để thanh toán chung |
| 5 | [Payments](#5-payments) | 5 | Tạo thanh toán + webhook VNPay/MoMo/ZaloPay |
| 6 | [Tables](#6-tables) | 4 | Bàn + giải mã QR |
| 7 | [Staff](#7-staff) | 6 | Quản lý nhân viên theo cấp bậc |
| 8 | [Analytics](#8-analytics-dashboard) | 3 | Doanh thu, món bán chạy, hiệu suất NV |
| 9 | [Ingredients](#9-ingredients-kho-nguyên-liệu) | 8 | Nguyên liệu + nhập/xuất kho |
| 10 | [Tasks](#10-staff-tasks) | 3 | Bảng công việc nhân viên |
| 11 | [Training](#11-training) | 7 | Tài liệu đào tạo + tiến độ |
| 12 | [Files](#12-files) | 1 | Upload ảnh |
| 13 | [Marketing](#13-marketing) | 1 | Số liệu chi tiêu (tĩnh) |
| 14 | [AI Chat](#14-ai-chat) | 2 | Trợ lý đặt món bằng Claude |
| 15 | [Realtime](#15-realtime-sse--websocket) | 6 | SSE + WebSocket qua Redis Pub/Sub |
| 16 | [Background Jobs](#16-background-jobs) | — | Hết hạn payment, dọn file |
| 17 | [Hạ tầng chung](#17-hạ-tầng-chung-middleware--pkg--hệ-thống) | — | Middleware, pkg, health, metrics |

---

## 1. Auth

**Tính năng:** đăng nhập staff (access token + refresh token trong httpOnly cookie), làm mới token, đăng xuất từng thiết bị, đăng ký cashier, khách quét QR nhận guest JWT 2h, khách online nhận guest JWT không cần QR. Có rate limit đăng nhập và cache trạng thái `is_active` trong Redis.

| Endpoint | Quyền | Handler | Service |
|---|---|---|---|
| `POST /auth/login` | Public | `Login` | `AuthService.Login` |
| `POST /auth/register` | Public | `Register` | `AuthService.Register` |
| `POST /auth/refresh` | Public (cookie) | `Refresh` | `AuthService.Refresh` |
| `POST /auth/guest` | Public | `Guest` | `AuthService.GuestLogin` |
| `POST /auth/guest/online` | Public | `OnlineGuest` | `AuthService.OnlineGuestLogin` |
| `POST /auth/logout` | Auth | `Logout` | `AuthService.Logout` |
| `GET /auth/me` | Auth | `Me` | `AuthService.GetMe` |

**Service — `auth_service.go`**

| Function | Mô tả |
|---|---|
| `Login` | Kiểm tra user/pass; sai username hay sai password đều trả cùng `ErrInvalidCredentials` (không lộ field nào sai). |
| `Register` | Tạo tài khoản role=cashier, trả token giống Login. |
| `Refresh` | Đổi refresh token (từ cookie) lấy access token mới. |
| `Logout` | Chỉ thu hồi refresh token của phiên hiện tại (giữ phiên thiết bị khác). |
| `GetMe` | Thông tin staff đang đăng nhập. |
| `GuestLogin` | Xác thực QR token của bàn → guest JWT 2h (stateless) kèm thông tin bàn. |
| `OnlineGuestLogin` | Guest JWT cho khách đặt online (không có bàn). |
| `IsStaffActive` | Middleware gọi mỗi request — đọc cache Redis trước, fallback DB. |
| `DeactivateStaff` / `ReactivateStaff` | Bật/tắt tài khoản + cập nhật cache ngay (không chờ TTL). |
| `NewPublicUUID`, `NewRandomBytes` | Helper sinh UUID / bytes ngẫu nhiên dùng chung. |
| *(private)* `issueTokens`, `checkLoginRateLimit`, `setIsActiveCache`, `delIsActiveCache` | |

**Repository — `auth_repo.go`:** `GetStaffByUsername` · `GetStaffByID` · `CreateRefreshToken` · `GetRefreshToken` · `DeleteRefreshToken` · `DeleteRefreshTokensByStaff` · `SetStaffActive` · `ListActiveSessionsByStaff` · `CountActiveSessionsByStaff` · `DeleteOldestSessionByStaff` · `UpdateRefreshTokenLastUsed` · `CreateStaffForRegister` · `GetTableByQRToken`

---

## 2. Products · Categories · Toppings · Combos

**Tính năng:** CRUD món ăn, danh mục, topping, combo. Khách chỉ thấy món đang bán; manager thấy tất cả. Xoá = soft delete. Danh sách được cache Redis và tự xoá cache khi ghi. Cung cấp "snapshot giá" cho Orders lúc tạo đơn.

| Endpoint | Quyền | Handler (`ProductHandler`) | Service (`ProductService`) |
|---|---|---|---|
| `GET /products` | Public | `ListProducts` | `ListProducts` (chỉ món đang bán) |
| `GET /products/all` | Manager+ | `ListAllProducts` | `ListAllProducts` |
| `GET /products/:id` | Public | `GetProduct` | `GetProduct` |
| `POST /products` | Manager+ | `CreateProduct` | `CreateProduct` (kèm gắn topping) |
| `PATCH /products/:id` | Manager+ | `UpdateProduct` | `UpdateProduct` (có thể thay toàn bộ topping) |
| `PATCH /products/:id/availability` | Manager+ | `UpdateProduct` | `UpdateProduct` |
| `DELETE /products/:id` | Admin | `DeleteProduct` | `DeleteProduct` |
| `GET /categories` | Public | `ListCategories` | `ListCategories` (cache) |
| `POST /categories` | Manager+ | `CreateCategory` | `CreateCategory` (trùng tên → `DUPLICATE_NAME`) |
| `PATCH /categories/:id` | Manager+ | `UpdateCategory` | `UpdateCategory` |
| `DELETE /categories/:id` | Admin | `DeleteCategory` | `DeleteCategory` (còn món → `CATEGORY_HAS_PRODUCTS`) |
| `GET /toppings` | Public | `ListToppings` | `ListToppings` (cache) |
| `POST /toppings` | Manager+ | `CreateTopping` | `CreateTopping` |
| `PATCH /toppings/:id` | Manager+ | `UpdateTopping` | `UpdateTopping` |
| `DELETE /toppings/:id` | Admin | `DeleteTopping` | `DeleteTopping` |
| `GET /combos` | Public | `ListCombos` | `ListCombos` |
| `POST /combos` | Manager+ | `CreateCombo` | `CreateCombo` |
| `PATCH /combos/:id` | Manager+ | `UpdateCombo` | `UpdateCombo` |
| `DELETE /combos/:id` | Admin | `DeleteCombo` | `DeleteCombo` |

**Service — function phục vụ domain khác (implement `ProductLookup` trong `deps.go`):**

| Function | Mô tả |
|---|---|
| `GetProductSnapshot` | Tên + giá món tại thời điểm đặt (lưu vào `order_items`). |
| `GetToppingSnapshot` | Tên + giá topping (lưu vào `toppings_snapshot`). |
| `GetComboSnapshot` | Combo + danh sách món con để Orders bung ra. |
| `ParsePrice` | Đổi chuỗi `DECIMAL(10,0)` → `int64` VND. |
| *(private)* `enrichProduct`, `enrichCombo`, `buildCategoryMap`, `invalidateProductCaches`, `invalidateToppingCaches`, `invalidateComboCaches`, `getCacheJSON`, `setCacheJSON` | |

**Repository — `product_repo.go`:**
- Product: `CreateProduct` · `GetProductByID` · `UpdateProduct` · `SoftDeleteProduct` · `ToggleProductAvailability` · `ListProducts` · `ListProductsAvailable` · `GetToppingsByProductID` · `AttachToppingToProduct` · `ClearProductToppings`
- Category: `CreateCategory` · `GetCategoryByID` · `GetCategoryByName` · `UpdateCategory` · `CountProductsByCategory` · `SoftDeleteCategory` · `ListCategories`
- Topping: `CreateTopping` · `GetToppingByID` · `UpdateTopping` · `UpdateToppingAvailability` · `SoftDeleteTopping` · `ListToppings` · `ListToppingsAvailable`
- Combo: `CreateCombo` · `GetComboByID` · `UpdateCombo` · `SoftDeleteCombo` · `ListCombos` · `ListCombosAvailable` · `CreateComboItem` · `DeleteComboItemsByComboID` · `GetComboItems`

---

## 3. Orders

**Tính năng:** khách (guest) hoặc thu ngân tạo đơn (nguồn `qr` / `pos` / `online`), thêm món vào đơn đang mở, sửa số lượng, huỷ món chưa phục vụ, huỷ cả đơn (chỉ khi phục vụ < 30%), bếp đánh dấu số lượng đã phục vụ → đơn tự chuyển `ready`, xem danh sách đơn đang chạy + lịch sử hôm nay, tìm kiếm. Mỗi thay đổi đều publish sự kiện realtime.

Vòng đời trạng thái: `pending → confirmed → preparing → ready → delivered → paid` (hoặc `cancelled`).

| Endpoint | Quyền | Handler (`OrderHandler`) | Service (`OrderService`) |
|---|---|---|---|
| `POST /orders` | Auth | `Create` | `CreateOrder` |
| `GET /orders` | Chef+ | `ListLive` | `ListActiveOrders` |
| `GET /orders/live?q=` | Cashier+ | `ListLive` | `ListActiveOrders` / `SearchActiveOrders` |
| `GET /orders/history` | Cashier+ | `ListHistory` | `ListTodayHistory` (đơn huỷ + đã trả hôm nay) |
| `GET /orders/:id` | Auth | `Get` | `GetOrder` (guest chỉ xem đơn của mình) |
| `PATCH /orders/:id/status` | Chef+ | `UpdateStatus` | `UpdateOrderStatus` |
| `DELETE /orders/:id` | Auth | `Cancel` | `CancelOrder` (≥ 30% đã phục vụ → `CANCEL_THRESHOLD`) |
| `POST /orders/:id/items` | Auth | `AddItemsToOrder` | `AddItemsToOrder` |
| `PATCH /orders/items/:id/quantity` | Auth | `UpdateItemQuantity` | `UpdateOrderItemQuantity` |
| `PATCH /orders/items/:id` | Chef+ | `UpdateItemServed` | `UpdateItemServed` (tăng `qty_served`) |
| `DELETE /orders/items/:id` | Auth | `CancelItem` | `CancelOrderItem` |

**Service — function phục vụ domain khác:**

| Function | Dùng bởi | Mô tả |
|---|---|---|
| `GetOrderForPayment` | Payments (`OrderReader`) | Đơn phải ở trạng thái `ready`; trả tổng tiền chính thức. |
| `MarkOrderDelivered` | Payments (`OrderWriter`) | `ready → delivered`. |
| `MarkOrderPaid` | Payments (`OrderWriter`) | `delivered → paid`. |
| `MonitorSnapshot` | SSE order-monitor | Snapshot hàng đợi + trạng thái bàn khi client vừa kết nối. |
| `SetPaymentRepo` | `main.go` | Gắn payment repo để hiện trạng thái thanh toán trong live view. |
| *(private)* `buildProductRow`, `buildToppingsSnapshot`, `expandCombo` (bung combo thành 1 dòng header + N dòng con), `maybeAutoReady`, `generateOrderNumber`, `publishOrderEvent`, `publishAdminOrderEvent`, `publishItemEvent`, `buildMonitorPayloads`, `publishMonitorBroadcast` | | |

**Repository — `order_repo.go`:** `CreateOrderWithItems` *(transaction)* · `AppendOrderItems` *(transaction)* · `GetOrderByID` · `GetOrderItemsByOrderID` · `GetOrderItemByID` · `GetActiveOrderByTable` · `ListAllOrders` · `ListActiveOrders` · `ListTodayHistory` · `UpdateOrderStatus` · `UpdateQtyServed` · `UpdateItemQuantity` · `RecalculateTotalAmount` · `SoftDeleteOrder` · `SumQtyServedAndQuantity` · `DeleteOrderItem` · `CountActiveOrderItems` · *(group)* `SetOrderGroupID` · `ClearOrderGroupID` · `ListOrdersByGroupID`

---

## 4. Order Groups (gộp đơn)

**Tính năng:** gộp nhiều đơn đang hoạt động (vd nhiều bàn đi chung) thành một nhóm để theo dõi/thanh toán chung; thêm, bớt đơn, giải tán nhóm. Một đơn chỉ thuộc một nhóm (`ORDER_ALREADY_GROUPED`).

| Endpoint | Quyền | Handler (`GroupHandler`) | Service (`GroupService`) |
|---|---|---|---|
| `POST /orders/group` | Cashier+ | `CreateGroup` | `CreateGroup` |
| `GET /orders/group/:id` | Auth | `GetGroup` | `GetGroupOrders` + `GroupOrderJSON` |
| `POST /orders/group/:id/orders` | Cashier+ | `AddToGroup` | `AddToGroup` |
| `DELETE /orders/group/:id/orders/:orderId` | Cashier+ | `RemoveFromGroup` | `RemoveFromGroup` |
| `DELETE /orders/group/:id` | Manager+ | `DisbandGroup` | `DisbandGroup` |
| `GET /orders/group/:id/events` | Auth | `sse.StreamGroup` | — (xem §15) |

Khác: `HasOrderInGroup` (kiểm tra quyền guest) · *(private)* `publishGroupEvent`. Repository dùng chung `OrderRepository` (các function nhóm ở §3).

---

## 5. Payments

**Tính năng:** thu ngân tạo thanh toán cho đơn `ready` (tiền mặt hoặc qua cổng VNPay / MoMo / ZaloPay), mỗi đơn chỉ một payment (`PAYMENT_ALREADY_EXISTS`). Cổng gọi webhook → **verify chữ ký HMAC trước tiên** → cập nhật payment → chuyển đơn sang `delivered`/`paid`. Payment pending quá hạn sẽ tự fail (§16).

| Endpoint | Quyền | Handler (`PaymentHandler`) | Service (`PaymentService`) |
|---|---|---|---|
| `POST /payments` | Cashier+ | `Create` | `CreatePayment` |
| `GET /payments/:id` | Cashier+ | `GetPayment` | `GetPayment` |
| `POST /payments/webhook/vnpay` | Public (HMAC) | `VNPayWebhook` | `HandleVNPayWebhook` |
| `POST /payments/webhook/momo` | Public (HMAC) | `MoMoWebhook` | `HandleMoMoWebhook` |
| `POST /payments/webhook/zalopay` | Public (HMAC) | `ZaloPayWebhook` | `HandleZaloPayWebhook` |

Service private: `processWebhookResult`, `completePayment`.

**Adapter cổng — `internal/payment/`:**

| File | Function |
|---|---|
| `vnpay.go` | `VNPayCreateURL` · `VNPayVerifyWebhook` (HMAC-SHA512 trên params đã sort) |
| `momo.go` | `MoMoCreatePayment` · `MoMoCallAPI` · `MoMoVerifyCallback` |
| `zalopay.go` | `ZaloPayCreatePayment` · `ZaloPayCallAPI` · `ZaloPayVerifyCallback` |

**Repository — `payment_repo.go`:** `CreatePayment` · `GetPaymentByID` · `GetPaymentByOrderID` · `UpdatePaymentStatus` · `IncrementPaymentAttempt` · `SoftDeletePayment`

---

## 6. Tables

**Tính năng:** quản lý bàn (tên, sức chứa, bật/tắt), mỗi bàn có `qr_token` ngẫu nhiên 64 ký tự; endpoint public giải mã QR → thông tin bàn.

| Endpoint | Quyền | Handler (`TableHandler`) |
|---|---|---|
| `GET /tables/qr/:token` | Public | `DecodeQR` |
| `GET /tables` | Cashier+ | `ListTables` |
| `POST /tables` | Manager+ | `CreateTable` (sinh UUID + QR token) |
| `PATCH /tables/:id` | Manager+ | `UpdateTable` |

⚠️ Không có service — handler gọi thẳng repository (xem BE_STRUCTURE_GUIDE §6).

**Repository — `table_repo.go`** *(raw SQL)*: `ListTables` · `GetTableByID` · `GetTableByQRToken` · `CreateTable` · `UpdateTable`

---

## 7. Staff

**Tính năng:** quản lý nhân viên có phân trang + lọc theo role / trạng thái / tìm kiếm; tạo / sửa có kiểm tra cấp bậc (không tạo hoặc nâng ai lên ngang/hơn mình); khoá/mở tài khoản (xoá cache `is_active` ngay lập tức); xoá mềm (chỉ Admin, không được xoá admin cuối cùng).

| Endpoint | Quyền | Handler (`StaffHandler`) | Service (`StaffService`) |
|---|---|---|---|
| `GET /staff` | Manager+ | `ListStaff` | `ListStaff` |
| `POST /staff` | Manager+ | `CreateStaff` | `CreateStaff` |
| `GET /staff/:id` | Manager+ | `GetStaff` | `GetStaff` |
| `PATCH /staff/:id` | Manager+ | `UpdateStaff` | `UpdateStaff` |
| `PATCH /staff/:id/status` | Manager+ | `SetStaffStatus` | `SetStaffStatus` |
| `DELETE /staff/:id` | Admin | `DeleteStaff` | `DeleteStaff` |

**Repository — `staff_repo.go`:** `ListStaff` · `GetStaffByID` · `GetStaffByUsername` · `CreateStaff` · `UpdateStaff` · `SetStaffActiveByID` · `SoftDeleteStaff` · `CountAdmins`

---

## 8. Analytics (Dashboard)

**Tính năng:** số liệu cho dashboard quản lý theo khoảng `today | week | month`.

| Endpoint | Quyền | Handler (`AnalyticsHandler`) | Service / Repository |
|---|---|---|---|
| `GET /admin/summary?range=` | Manager+ | `GetSummary` | `GetSummary` — tổng doanh thu, số đơn… |
| `GET /admin/top-dishes?limit=&range=` | Manager+ | `GetTopDishes` | `GetTopDishes` — món bán chạy |
| `GET /admin/staff-performance?range=` | Manager+ | `GetStaffPerformance` | `GetStaffPerformance` |

Service và repository (`analytics_repo.go`) có cùng 3 function trên.

---

## 9. Ingredients (Kho nguyên liệu)

**Tính năng:** CRUD nguyên liệu, danh sách sắp hết hàng, ghi nhận nhập/xuất kho (stock movement) và xem lịch sử.

| Endpoint | Quyền | Handler / Service (cùng tên) |
|---|---|---|
| `GET /admin/ingredients` | Manager+ | `ListIngredients` |
| `GET /admin/ingredients/low-stock` | Manager+ | `ListLowStock` |
| `GET /admin/ingredients/:id` | Manager+ | `GetIngredient` |
| `POST /admin/ingredients` | Manager+ | `CreateIngredient` |
| `PATCH /admin/ingredients/:id` | Manager+ | `UpdateIngredient` |
| `DELETE /admin/ingredients/:id` | Admin | `DeleteIngredient` |
| `POST /admin/stock-movements` | Manager+ | `CreateStockMovement` |
| `GET /admin/ingredients/:id/movements` | Manager+ | `ListStockMovements` |

**Repository — `ingredient_repo.go`:** `ListIngredients` · `ListLowStock` · `GetIngredientByID` · `CreateIngredient` · `UpdateIngredient` · `SoftDeleteIngredient` · `CreateStockMovement` · `ListStockMovements`

---

## 10. Staff Tasks

**Tính năng:** giao việc cho nhân viên; thống kê theo ngày (tổng / hoàn thành / đang làm / quá hạn) và theo từng người (tỉ lệ hoàn thành, điểm chất lượng).

| Endpoint | Quyền | Handler / Service (cùng tên) |
|---|---|---|
| `GET /admin/tasks/stats?date=` | Manager+ | `GetTaskStats` |
| `GET /admin/tasks?staffId=&date=` | Manager+ | `GetStaffTasks` |
| `POST /admin/tasks` | Manager+ | `CreateTask` |

**Repository — `task_repo.go`:** `GetDailyMetrics` · `GetStaffStats` · `GetTasksByStaffDate` · `CreateTask`

---

## 11. Training

**Tính năng:** tài liệu đào tạo gán cho từng role; theo dõi tiến độ xem + kết quả quiz của từng nhân viên; quản lý ghi chú đánh giá.

| Endpoint | Quyền | Handler / Service (cùng tên) |
|---|---|---|
| `GET /admin/training/guides?role=` | Manager+ | `ListGuides` |
| `POST /admin/training/guides` | Manager+ | `CreateGuide` |
| `PATCH /admin/training/guides/:id` | Manager+ | `UpdateGuide` |
| `DELETE /admin/training/guides/:id` | Admin | `DeleteGuide` |
| `GET /admin/training/guides/:id/progress?page=&pageSize=` | Manager+ | `ListGuideProgress` |
| `GET /admin/training/staff/:staffId/progress/:guideId` | Manager+ | `GetStaffProgressDetail` |
| `PATCH /admin/training/staff/:staffId/progress/:guideId` | Manager+ | `UpdateManagerNotes` |

Service khác: `GetGuide` · *(private)* `setGuideRoles`.

**Repository — `training_repo.go`:** `ListGuides` · `ListGuidesByRole` · `GetGuide` · `CreateGuide` · `UpdateGuide` · `SoftDeleteGuide` · `GetGuideRoles` · `DeleteGuideRoles` · `InsertGuideRole` · `ListGuideProgress` · `CountGuideProgress` · `GetStaffProgress` · `UpsertStaffProgress` · `UpdateManagerNotes` · `ListQuizAttempts` · `CountQuizAttempts` · `InsertQuizAttempt`

> `UpsertStaffProgress`, `InsertQuizAttempt` đã có ở repo nhưng **chưa có endpoint** cho nhân viên tự ghi tiến độ / làm quiz.

---

## 12. Files

**Tính năng:** upload ảnh (món ăn…), file được serve tĩnh tại `/uploads` khi đặt `STORAGE_BASE_PATH`. File không được gắn vào đâu sau 24h sẽ bị dọn (§16).

| Endpoint | Quyền | Handler |
|---|---|---|
| `POST /files/upload` | Cashier+ | `FileHandler.Upload` |

⚠️ Không có service. **Repository — `file_repo.go`:** `CreateFileAttachment` · `GetFileAttachmentByID` · `DeleteOrphanFilesOlderThan24h`

---

## 13. Marketing

| Endpoint | Quyền | Handler |
|---|---|---|
| `GET /admin/marketing/spend` | Manager+ | `MarketingHandler.GetSpend` — **dữ liệu tĩnh** (ngân sách/chi tiêu chiến dịch khai trương), không có service/repo/DB. |

---

## 14. AI Chat

**Tính năng:** trợ lý chat (Claude) cho khách và nhân viên; trả lời dạng stream SSE. Model có thể đọc menu / đơn của mình, và **đề xuất** tạo hoặc huỷ đơn. Đề xuất chỉ được thực hiện khi người dùng xác nhận (`/chat/confirm`) — bước này đi qua service layer bình thường, không gọi lại model. Lịch sử hội thoại lưu Redis, tự tóm tắt khi dài. Rate limit 10 req/phút/token + 30 req/phút/IP. Thiếu `ANTHROPIC_API_KEY` → tính năng tắt (`CHAT_001`).

| Endpoint | Quyền | Handler (`ChatHandler`) | Service (`ChatService`) |
|---|---|---|---|
| `POST /chat` | Auth + rate limit | `Chat` (SSE) | `Chat` |
| `POST /chat/confirm` | Auth + rate limit | `Confirm` | `Confirm` |

**Tool cho model — `chat_tools.go`:** `get_menu` · `get_my_order` (đọc, chạy ngay) · `create_order` · `cancel_order` (ghi, phải chờ confirm).

Service private: `executeReadTool`, `toolGetMenu`, `toolGetMyOrder`, `proposalSummary`, `confirmCreateOrder`, `confirmCancelOrder`, `loadHistory`, `saveHistory`, `appendHistory`, `appendAssistantLine`, `summarize`, `savePending`.

**Adapter — `internal/ai/client.go`:** `NewClientFromEnv` (trả `nil` nếu thiếu key) · `Model` · `CreateMessage` · `CreateMessageStreaming`. Không có repository — dùng lại `ProductService` + `OrderService`.

---

## 15. Realtime (SSE + WebSocket)

Service publish sự kiện lên Redis Pub/Sub → các handler dưới đây subscribe và đẩy xuống client.

| Endpoint | Quyền | Function | Dùng cho |
|---|---|---|---|
| `GET /orders/:id/events` | Auth | `sse.StreamOrder` | Khách theo dõi 1 đơn (heartbeat 15s) |
| `GET /orders/group/:id/events` | Auth | `sse.StreamGroup` | Theo dõi nhóm đơn (gửi snapshot mỗi khi có sự kiện) |
| `GET /sse/admin` | Manager+ | `sse.StreamAdmin` | Dashboard admin — đơn mới (channel `orders:admin`) |
| `GET /sse/order-monitor/:id` | Auth | `sse.StreamOrderMonitor` | Màn hình khách: `order.status` + `queue.update` + `tables.status` |
| `GET /ws/kds` | `?token=` (Chef+) | `websocket.KDSHandler` | Màn hình bếp (KDS) |
| `GET /ws/orders-live` | `?token=` (Cashier+) | `websocket.LiveHandler` | Màn hình đơn trực tiếp của thu ngân |

WebSocket internals: `hub.go` (`NewHub`, `Run`, `Broadcast`) · `client.go` (`readPump`, `writePump`) · `handler.go` (`wsHandler`).

---

## 16. Background Jobs

Khởi động trong `main.go` bằng goroutine, dừng khi server shutdown.

| Function | Chu kỳ | Việc làm |
|---|---|---|
| `jobs.StartPaymentTimeoutWatcher` | mỗi 1 phút | Payment `pending` quá `expires_at` → `failed` (nhận `rdb` nhưng hiện **không** publish sự kiện) |
| `jobs.StartFileCleanup` | mỗi 6 giờ | Xoá `file_attachments` mồ côi cũ hơn 24h |

---

## 17. Hạ tầng chung (middleware · pkg · hệ thống)

**Endpoint hệ thống:** `GET /health` (Public, `{"status":"ok"}`) · `GET /metrics` (Prometheus) · `GET /uploads/*` (file tĩnh).

**Middleware — `internal/middleware/`:**

| Function | Mô tả |
|---|---|
| `AuthRequired` | Parse Bearer JWT, kiểm tra `is_active`, gắn claims vào context |
| `ClaimsFromContext` · `StaffIDFromContext` · `RoleFromContext` | Đọc thông tin người gọi trong handler |
| `RefreshTokenFromCookie` · `SetRefreshCookie` · `ClearRefreshCookie` | Quản lý cookie refresh token |
| `AtLeast(role)` | Yêu cầu cấp role tối thiểu |
| `RequireRole(roles...)` | Chỉ cho đúng các role được liệt kê |
| `RequireOwner` · `CustomerOrStaff` | Kiểm tra chủ sở hữu / cho guest hoặc staff |
| `RateLimit` · `RateLimitKeyByIP` · `RateLimitKeyByToken` | Fixed-window qua Redis, Redis lỗi → cho qua |
| `Metrics` | Đếm request cho Prometheus |
| *(trong `main.go`)* CORS | Allowlist từ `CORS_ORIGINS` |

**Error helpers:** `handler.respondError` · `handler.handleServiceError` · `service.NewAppError` · `service.IsAppError` + sentinel errors trong `service/errors.go`.

**`pkg/`:**

| Package | Function |
|---|---|
| `jwt` | `GenerateAccessToken` · `GenerateGuestToken` · `GenerateOnlineGuestToken` · `ParseToken` · `AccessTTL` · `RefreshTTL` |
| `bcrypt` | `Hash` (cost 12) · `Verify` |
| `redis` | `New` · `HealthCheck` · `Publish` · `Subscribe` · `Unsubscribe` |

**Tool CLI — `cmd/`:** `seed` (tạo tài khoản demo mọi role) · `qr` (in URL QR các bàn) · `demo_order` (giả lập khách quét QR → xem menu → đặt món qua API thật).
