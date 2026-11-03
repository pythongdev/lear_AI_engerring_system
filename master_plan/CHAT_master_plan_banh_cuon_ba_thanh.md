# Kế hoạch — chat với app · Bánh cuốn Bà Thanh Cao Bằng

> **File này là KẾ HOẠCH, không sở hữu sự thật nào.** Nó giữ thứ tự · mức · đầu ra kiểm chứng được.
> Dữ kiện quán: `master_plan/shop-facts.md`; quyết định: `docs/decisions.md`; câu chưa có lời:
> `docs/product/99-unknowns.md`; bất biến: `quality/invariants.md`; hợp đồng:
> `docs/product/3-be/openapi.yaml`; quyền: `docs/product/3-be/02-vai-va-quyen.md`; lược đồ: migration.
> Route và component: `docs/product/4-fe/01-khung-fe.md`. Trạng thái do Claude giữ ở `work/backlog.md`;
> mô tả nhận việc ở `work/backlog_CHAT.md`. Luật chia vai: `CLAUDE.md` §7.4.
>
> Soạn **2026-11-01**, T-283, Codex theo phiếu Claude. Đo từ **cây chính có thay đổi chưa commit**,
> không lấy HEAD của worktree làm sự thật hiện tại. ADR-136 còn **Đề xuất**, chờ chủ repo duyệt.
> Các bước dưới đây là **suy luận lập kế hoạch**, không phải lời chủ quán hay phép mở thi công.
> Claude duyệt 2026-11-01, sửa ba chỗ: tin báo · báo nghỉ không chờ lát model, thêm CHAT-34, đổi giá §7.

## 1. Câu hỏi kế hoạch trả lời — một dòng

Ô chat bật tắt được cần đi qua những lát nào để hỏi đúng, ghi đúng quyền và báo việc mà không đổi luật quán?

## 2. Năng lực → cửa đã có → còn thiếu — đo 2026-11-01

Nguồn đo: entry T-283, hợp đồng **0.54.0** và ma trận quyền ở cây chính. “Có” ở đây là **có hợp đồng**,
không khẳng định code đã commit hay đã nghiệm thu. Đếm lại khi nhận việc. Mọi dòng đều còn thiếu mặt chat.

Bảng có **24 dòng năng lực**, đếm 2026-11-01. Các loại lệnh chủ quán là cách người lập kế hoạch phân rã
câu “tất cả các [việc] làm bằng tay”, không phải danh sách đóng do chủ quán xác nhận. `C01`…`C19` là
nhãn tra ngay dưới bảng: mỗi nhãn ghi **operationId, đường thật và lớp thật**, không phải tên cửa mới.

| Năng lực trong lời yêu cầu | Cửa đã có, tra ngay dưới | Còn thiếu / chặn |
|---|---|---|
| Khách hỏi thông tin quán | C01 | Nguồn thông tin công khai; chờ U-112 |
| Khách đặt món online | C02 | Soạn đơn và xác nhận; chờ U-112, U-117 |
| Chủ quán hỏi số liệu để điều hành | C03 | Công cụ đọc theo phiên; chờ U-112 |
| Chủ quán nhập thông tin món, danh mục, topping | C04 | Lệnh theo nhóm; chờ U-112, U-114, U-115 |
| Chủ quán đổi giá, thành phần, combo | C05 | Lệnh chạm tiền; chờ U-112, U-114, U-115 |
| Chủ quán quản lý tài khoản người làm | C06 | Không đưa bí mật vào model; chờ U-112, U-114, U-115 |
| Chủ quán nhập nguyên liệu, đặt nhắc kho | C07 | Không suy lượng dùng từ đơn; chờ U-112, U-114, U-115 |
| Chủ quán giao, sửa, ẩn, đánh dấu việc | C08 | Thẻ xác nhận; chờ U-112, U-114, U-115 |
| Chủ quán ghi hướng dẫn và đào tạo | C09 | Chọn đúng việc/người; chờ U-112, U-114, U-115 |
| Chủ quán ghi và sửa khoản chi | C10 | Giữ nguồn tiền, vết; chờ U-112, U-114, U-115 |
| Chủ quán dừng/mở nhận đơn, báo quán mù | C11 | Không tự mở khi mạng về; chờ U-112, U-114, U-115 |
| Chủ quán làm thao tác POS lúc đứng quầy | C12, C15, C17 | Không thêm quyền chức vụ; chờ U-114, U-115 |
| Chủ quán thu, huỷ, hoàn, nợ, giảm giá | C13 | Giảm giá theo cửa đóng phiên; chờ U-112, U-114, U-115 |
| Chủ quán khai két, sổ giấy, đối soát | C14 | Thẻ theo từng cửa; chờ U-112, U-114, U-115 |
| Chủ quán chấm công | Chưa có cửa HTTP | Có luật/chỗ cất chưa đủ để mở chat; chờ U-114, U-115 |
| Chủ quán tạm ứng, thưởng, tính lương | Chưa có cửa HTTP | Chờ lane admin đủ luật và cửa; không dựng trong CHAT |
| POS nhập thông tin đặt hàng | C15 | Phân kênh đúng, không giả khách; chờ U-112, U-115 |
| POS xem bàn thiếu bánh cuốn, bánh trứng, giò | C16 | Số từ BE, không model tự trừ; chờ U-112 |
| POS giao việc cho người khác | C08 | Người nhận không tự đánh dấu; chờ U-112, U-115 |
| Người canh nhận số cần múc và báo đã múc/đem | C18 đọc; báo: chưa có | Tin báo riêng, không tiến độ; chờ U-113 |
| Người dọn nhận bàn, báo POS xác nhận, nhận việc phụ | C19; C08 phía POS; đọc việc: chưa có | CHAT-34; chờ U-113 |
| Khách muốn thêm: trạm báo / khách nhắn POS | Chưa có cửa tin báo | Chờ U-113 (trạm), U-117 (khách) |
| Báo nghỉ, kể cả chủ quán nhập hộ | Chưa có | U-116 có lời 2026-11-03 (shop-facts §8.11 điểm 7); chạm ô chấm công nên Claude thiết kế trước lược đồ |
| Các trạm khác nhận và báo tương tự | C18 đọc; báo: chưa có | Tráng, gấp; không tự ghi tiến độ; chờ U-113 |

### Cửa thật để đọc bảng trên

Các dòng công khai dưới đây là tính chất `security: []` của hợp đồng; không bịa dòng ma trận cho cửa đọc.
Lớp của cửa ghi và các cửa đọc có kiểm quyền lấy từ `02-vai-va-quyen.md`. Tên trong ngoặc là mã cửa
nghiệp vụ khi cần phân biệt với operationId. Mỗi nhóm chỉ nêu những cửa dùng để lập kế hoạch; mở rộng
danh sách công cụ phải được Claude duyệt ở CHAT-02 và bước của nhóm ấy.

- **C01 — hỏi công khai:** `getMenu` — `GET /menu`; `quotePrices` — `POST /price-quotes`.
  Cả hai công khai, chỉ đọc; POST tính thử **không ghi**. Thông tin địa chỉ, giờ bán, liên hệ: chưa có
  cửa thông tin quán tổng hợp trong hợp đồng. CHAT-05 chỉ xuất phần công khai được Claude duyệt từ owner.
- **C02 — khách đặt:** `createOnlineOrder` — `POST /online-orders`;
  `createQrOrder` — `POST /qr-codes/{code}/orders`.
  Cùng cửa `don/tao_luot_goi`, lớp `quay_hoac_khach`. Web hiện cho đăng nhập tuỳ chọn; QR có cửa không có
  nghĩa chat được dùng: chờ U-117. Tài khoản khách và người làm tách nhau theo ADR-131.
- **C03 — số quản trị:** `getOwnerOverview` — `GET /owner-overview`;
  `getSaleDaySummary` — `GET /sale-days/{sale_date}/summary`;
  `getSupplyStock` — `GET /supply-stock`: lớp `chu_quan`.
  `putDailyMinimum` — `PUT /daily-minimums/{sale_date}` là **ghi**, lớp `chu_quan`, dành CHAT-29.
- **C04 — thông tin menu:** `createMenuItem` — `POST /menu-items`;
  `renameMenuItem` — `PUT /menu-items/{menu_item_id}`;
  `discontinueMenuItem` — `POST /menu-items/{menu_item_id}/discontinuation`;
  `createMenuCategory` — `POST /menu-categories`;
  `renameMenuCategory` — `PUT /menu-categories/{menu_category_id}`;
  `hideMenuCategory` — `POST /menu-categories/{menu_category_id}/hiding`;
  `assignMenuItemCategory` — `PUT /menu-items/{menu_item_id}/category`;
  `addMenuOption` — `POST /option-groups/{option_group_id}/options`;
  `hideMenuOption` — `POST /menu-options/{menu_option_id}/hiding`;
  `unhideMenuOption` — `POST /menu-options/{menu_option_id}/unhiding`: lớp `chu_quan`.
  Thêm lựa chọn có phần phụ thu thì chuyển CHAT-26; không lách U-115 bằng tên “thông tin”.
- **C05 — giá và cấu tạo:** `changeComponentPrice` — `PUT /menu-components/{menu_component_id}/base-price`;
  `changeOptionSurcharge` — `PUT /menu-options/{menu_option_id}/surcharge`;
  `addItemComponent` — `POST /menu-items/{menu_item_id}/components`;
  `changeItemComponent` — `PUT /menu-items/{menu_item_id}/components/{menu_component_id}`;
  `createMenuCombo` — `POST /menu-combos`;
  `updateMenuComboPrice` — `PUT /menu-combos/{menu_combo_id}/price`;
  `setMenuComboSurcharges` — `PUT /menu-combos/{menu_combo_id}/surcharges`;
  `hideMenuCombo` — `POST /menu-combos/{menu_combo_id}/hiding`: lớp `chu_quan`.
- **C06 — tài khoản:** `approveAccount` — `POST /accounts/{account_id}/approval`;
  `rejectAccount` — `POST /accounts/{account_id}/rejection`;
  `lockAccount` — `POST /accounts/{account_id}/lock`;
  `unlockAccount` — `POST /accounts/{account_id}/unlock`: lớp `chu_quan`.
  Mật khẩu tạm chỉ xử lý ở màn tay; tài khoản chat không phải tài khoản dịch vụ.
- **C07 — nguyên liệu:** `createSupplyItem` — `POST /supply-items`;
  `setSupplyItemPurchaseUnit` — `PUT /supply-items/{supply_item_id}/purchase-unit`;
  `createSupplyDayEntry` — `POST /supply-day-entries`;
  `updateSupplyDayEntry` — `PUT /supply-day-entries/{supply_day_entry_id}`;
  `setSupplyItemReminderRatio` — `PUT /supply-items/{supply_item_id}/reminder-ratio`: lớp `chu_quan`.
- **C08 — giao việc:** `listAssignedTasks` — `GET /assigned-tasks`;
  `createAssignedTask` — `POST /assigned-tasks`;
  `updateAssignedTask` — `PUT /assigned-tasks/{assigned_task_id}`;
  `hideAssignedTask` — `POST /assigned-tasks/{assigned_task_id}/hiding`;
  `markAssignedTask` — `POST /assigned-tasks/{assigned_task_id}/marks`: lớp `quay_hoac_chu_quan`.
  Ma trận giữ `giaoviec/*`; người nhận thường không được tự đọc qua cửa này hay tự đánh dấu xong.
  ⇒ Đo 2026-11-01: người được giao **chưa có đường nào đọc việc của mình**; lấp ở CHAT-34.
- **C09 — đào tạo:** `attachAssignedTaskGuide` — `POST /assigned-tasks/{assigned_task_id}/guides`;
  `updateAssignedTaskGuide` — `PUT /assigned-task-guides/{assigned_task_guide_id}`;
  `hideAssignedTaskGuide` — `POST /assigned-task-guides/{assigned_task_guide_id}/hiding`;
  `createTrainingRecord` — `POST /training-records`;
  `updateTrainingRecord` — `PUT /training-records/{training_record_id}`;
  `hideTrainingRecord` — `POST /training-records/{training_record_id}/hiding`: lớp `quay_hoac_chu_quan`.
  Tệp ảnh/video vẫn dùng màn tay; chat không tự tải tệp ngoài hay đưa tệp riêng tư vào model.
- **C10 — khoản chi:** `createExpenseCategory` — `POST /expense-categories`;
  `renameExpenseCategory` — `PUT /expense-categories/{expense_category_id}`;
  `deleteExpenseCategory` — `DELETE /expense-categories/{expense_category_id}`;
  `createExpenseItem` — `POST /expense-items`;
  `renameExpenseItem` — `PUT /expense-items/{expense_item_id}`;
  `deleteExpenseItem` — `DELETE /expense-items/{expense_item_id}`;
  `createExpense` — `POST /expenses`; `updateExpense` — `PUT /expenses/{expense_id}`;
  `deleteExpense` — `DELETE /expenses/{expense_id}`: lớp `chu_quan`; DELETE ở đây là xoá mềm.
- **C11 — nhận đơn:** `pauseIntake` — `POST /order-intake/pause`;
  `resumeIntake` — `POST /order-intake/resume`: lớp `chu_quan`.
  `declareBlind` — `POST /shop-blind/declaration`;
  `reopenBlind` — `POST /shop-blind/reopening`: lớp `quay_hoac_chu_quan`.
- **C12 — xử lý đơn của POS:** `approveOrder` — `POST /orders/{sales_order_id}/approval`;
  `rejectOrder` — `POST /orders/{sales_order_id}/rejection`;
  `departOrder` — `POST /orders/{sales_order_id}/departure`: lớp `quay`.
- **C13 — tiền theo đơn/phiên:** `cancelOrder` — `POST /orders/{sales_order_id}/cancellation`;
  `closeSession` — `POST /table-sessions/{table_session_id}/closing`;
  `handoverOrder` — `POST /orders/{sales_order_id}/handover`;
  `refundBill` — `POST /bills/{bill_id}/refunds`;
  `collectDebt` — `POST /bills/{bill_id}/debt-collections`;
  `receivePrepayment` — `POST /orders/{sales_order_id}/prepayment`;
  `returnPrepayment` — `POST /prepayments/{prepayment_id}/returns`: lớp `quay`.
  `deliverOrder` — `POST /orders/{sales_order_id}/delivered`: lớp `nguoi_quan`, kiểm người được giao
  tại cửa; không đổi thành quyền POS. Không có cửa giảm giá độc lập: đọc hình đóng phiên trong hợp đồng.
- **C14 — két và sổ:** `declareOpeningFloat` — `POST /opening-floats`;
  `recordCashCount` — `POST /cash-counts`;
  `createPaperEntry` — `POST /sale-days/{sale_date}/paper-entries`;
  `declarePaperLedger` — `POST /sale-days/{sale_date}/paper-ledger`: lớp `quay_hoac_chu_quan`.
  `correctReconciledCashCount` — `PUT /sale-days/{sale_date}/cash-count`;
  `reconcileSaleDay` — `POST /sale-days/{sale_date}/reconciliation`: lớp `chu_quan`.
- **C15 — nhập đơn tại quầy:** `createTableOrder` — `POST /table-orders`;
  `createPhoneOrder` — `POST /phone-orders`: lớp cửa `quay_hoac_khach`, **nhánh người phải đang đứng quầy**.
  Không vì tên lớp có chữ “khách” mà cho khách gọi đường nhập hộ.
- **C16 — thiếu theo bàn:** `getServiceBoard` — `GET /service-board`: lớp `quay_hoac_chu_quan`;
  `counterStationJobs` — `GET /counter/station-jobs`: lớp `quay`.
  Số thiếu theo đơn vị trong `getServiceBoard`; số việc theo trạm không cộng lẫn thành số món.
- **C17 — tiến độ POS:** `makeProductionBatch` — `POST /production-batches`;
  `rollbackProductionBatch` — `POST /production-batches/{id}/rollback`;
  `markServed` — `POST /served-marks`;
  `transferStationJobs` — `POST /station-job-transfers`;
  `writeWrongMakeNote` — `POST /wrong-make-notes`;
  `cancelWrongMakeNote` — `POST /wrong-make-notes/{id}/cancellation`;
  `postWorkersPresentDeclaration` — `POST /workers-present-declarations`: lớp `quay`.
- **C18 — bảng trạm:** `getProductionBoard` — `GET /production-board`, công khai, lọc `station_code`.
  `productionEvents` — `GET /production-board/events`, công khai, chỉ tín hiệu đọc lại.
  `counterEvents` — `GET /counter/events`, lớp `quay`, không dùng luồng công khai chở tin riêng.
- **C19 — dọn bàn:** `getDiningTables` — `GET /dining-tables`, công khai;
  `cleanTable` — `POST /dining-tables/{dining_table_id}/cleaning`, lớp `nguoi_quan` (`ban/da_don`).
  Đây là ngoại lệ đã có của dọn bàn; tin “đã dọn, xin POS xác nhận” không tự gọi cửa này.

## 3. Ranh giới — kế hoạch này KHÔNG làm gì

- Không code trong T-283, không đổi ADR, câu hỏi, trạng thái, luật quán hay invariant. Không đặt tên bảng,
  cột, đường API mới như đã chốt. CHAT-02 và các lát thiết kế sau do Claude đặt trong đúng owner.
- Không cấp quyền riêng cho trợ lý, không SQL ghi riêng, không gom nhiều việc thành một cửa ghi chat.
  Backend chọn danh sách công cụ theo phiên; mỗi công cụ gọi đúng service hiện có, kiểm tại mốc giao dịch
  theo ADR-085. Khách không bao giờ nhận bộ công cụ của người làm; cookie hai không gian không thay nhau.
- Không lật ADR-011, `shop-facts.md` §6.13 và §6.2: POS ghi tiến độ; chủ quán ngoài quầy không có quyền
  huỷ; khách gửi đơn vẫn chờ POS duyệt. U-113 hoặc U-114 có lời trái luật cũ ⇒ **dừng lát liên quan**,
  Claude xử lý thay đổi thiết kế/owner ở việc riêng trước khi sửa kế hoạch; không mặc nhiên thi công.
- Không cho model tính giá, tự nói tồn, tự chia mẻ, tự phân bàn hay tự ghi đơn. Giá qua hàm duy nhất
  của `docs/product/3-be/03-ham-gia.md`; số lượng, trạng thái và mốc đọc lấy từ công cụ đọc của backend.
- Không biến tin báo thành tiến độ, tin muốn thêm thành đơn, báo nghỉ thành chấm công/trừ lương.
  Không mở chấm công, tạm ứng, thưởng, lương khi chưa có cửa HTTP được nghiệm thu ở lane admin.
- Không thay màn tay, đường điện thoại/sổ giấy, cách đăng nhập, hoặc hệ thống thông báo bằng chat.
  Không giữ giao dịch DB lúc chờ model; không hàng đợi ghi ngầm; không lưu cache giá/menu cho trợ lý.
  Giữ RB-1…RB-4 tại `docs/product/1-system-design/05-realtime-va-du-phong.md` §2:
  một tiến trình đường đẩy, không hàng đợi, không bộ nhớ đệm nghiệp vụ, một chỗ chạy.
- SSE theo ADR-097 chỉ báo đọc lại sau COMMIT; kéo lại nguồn ghi theo chu kỳ hợp đồng khi mất SSE.
  Bật/tắt ô chat không được đóng luồng quầy của layout, cũng không làm quán “nhìn thấy” giả.

### Cách đọc tạm khi chưa có lời — không phải giấy phép thi công

| Câu ở `docs/product/99-unknowns.md` | Giữ tạm đúng câu hỏi đang ghi |
|---|---|
| U-112 — model, ngân sách, dữ liệu gửi ngoài | Lớp đổi được nhà cung cấp; chưa gọi model thật |
| U-113 — xác nhận ở trạm và thiết bị | Chỉ tin báo, POS vẫn ghi; chưa mở hộp tin trạm |
| U-114 — quyền chủ quán | Giữ luật cũ; ngoài quầy bị từ chối ở cửa quầy |
| U-115 — cửa ghi, nhất là tiền | Chưa mở cửa chạm tiền nào qua chat |
| U-116 — báo nghỉ, duyệt, ca/lương | Chưa dựng cả chỗ cất; không suy thêm từ C30 |
| U-117 — đặt món, đăng nhập, nhắn POS | Chỉ giao/đến lấy theo luật web hiện có; chưa mở đặt qua chat |

U-116 không chặn phần còn lại. Thu lời từng câu là việc của Claude; một câu có lời không tự gỡ câu khác.

## 4. Bảng bước — 34 lát dự kiến, đếm 2026-11-01

**Sau lời 2026-11-01 (CHAT-01):** `U-114` · `U-115` · `U-117` đóng; `U-113` đóng (tin báo, điện thoại riêng); `U-112` còn câu model; `U-116` còn mở
(owner: `docs/product/99-unknowns.md`, `master_plan/shop-facts.md` §8.11). **Mở được:** `CHAT-04` · `CHAT-34` · `CHAT-12` · `CHAT-13` ·
`CHAT-14` theo ADR-137. **Đóng tới khi chọn model:** `CHAT-03`, `05`…`11`, `15`…`26`. **Loại:** `CHAT-27` · `28` · `29`. **Đóng tới khi có
`U-116`:** `CHAT-30`…`32`. `CHAT-26` (đổi giá) phải hỏi lại trước khi mở. Bảng và mục cách đọc tạm dưới đây giữ nguyên làm lịch sử lập kế hoạch.

**Vai thi công:** `C` = Claude thu lời/thiết kế/duyệt; `K` = Codex thi công theo phiếu, Claude viết test
trước cho L2+, rà diff, chạy lại và tích hợp. Mức dưới đây là đề xuất cho Claude duyệt khi nhận việc.
Tính năng là L3; lát thi công tách L1/L2 sau thiết kế. Không có lát L0 vì không lát nào chỉ sửa chữ.

Trong cột **Chờ U**, `112` là `U-112`, tương tự các số khác. Phụ thuộc là mã CHAT cùng bảng.
Mọi bước ghi dùng model đều chờ 112 **và** 115; bước chủ quán ghi còn chờ 114. DB/tin báo không model
chờ 113; báo nghỉ không model chờ 116. Chặn truyền theo phụ thuộc, nhưng không thay chặn ghi rõ tại dòng.

| ID | Mức | Đầu ra kiểm chứng được | Trước | Chờ U | Ai |
|---|:--:|---|---|---|:--:|
| CHAT-01 | L3 | ADR duyệt, lời từng câu về owner; phần chưa có lời vẫn đóng | — | 112–117 theo nhánh | C |
| CHAT-02 | L3 | Thiết kế công cụ, thẻ, tin báo, dữ liệu gửi ngoài và phép kiểm | 01 | 112–117 theo nhánh | C |
| CHAT-03 | L2 | BE: lớp model đổi hãng, tắt được, hạn chờ, trần chi phí | 02 | 112 | K |
| CHAT-04 | L1 | FE: vỏ chat bật/tắt, chưa nối model/ghi, màn tay chạy | 01 | Không | K |
| CHAT-05 | L2 | BE: hỏi đáp công khai chỉ đọc, nguồn được phép, số từ công cụ | 03 | 112 | K |
| CHAT-06 | L2 | Eval: giá, lời chèn lệnh, quyền, dữ liệu riêng; báo cáo đạt/trượt | 05 | 112 | K |
| CHAT-07 | L1 | FE: hỏi công khai sau eval, lỗi có đường về màn tay | 04,06 | 112 | K |
| CHAT-08 | L2 | BE: đọc theo phiên, thiếu theo bàn/trạm và số chủ quán | 06 | 112 | K |
| CHAT-09 | L2 | FE: hỏi số nội bộ, mốc đọc, đổi người không lộ hội thoại | 07,08 | 112 | K |
| CHAT-10 | L2 | BE: đề xuất/thực thi thẻ tách nhau, kiểm lại quyền | 09 | 112,114,115 | K |
| CHAT-11 | L2 | FE: thẻ xác nhận, huỷ nháp, lỗi/chưa rõ kết quả | 10 | 112,114,115 | K |
| CHAT-12 | L2 | DB: tin báo riêng, người gửi/nhận, loại trạm, vết | 02 | 113 | K |
| CHAT-13 | L2 | BE: cửa tin báo và đọc riêng tư, định tuyến canh + dọn | 12 | 113 | K |
| CHAT-14 | L2 | FE: hộp tin trạm ↔ POS, dùng được khi tắt model | 04,13,34 | 113 | K |
| CHAT-15 | L2 | BE: công cụ giao/sửa/ẩn/đánh dấu việc qua C08 | 11,14 | 112,114,115 | K |
| CHAT-16 | L2 | BE: hướng dẫn chữ và đào tạo qua C09 | 15 | 112,114,115 | K |
| CHAT-17 | L2 | BE: sổ nguyên liệu và nhắc kho qua C07 | 11 | 112,114,115 | K |
| CHAT-18 | L2 | BE: duyệt/từ chối/khoá tài khoản qua C06 | 11 | 112,114,115 | K |
| CHAT-19 | L2 | BE: thông tin menu/danh mục qua C04, không phần giá | 11 | 112,114,115 | K |
| CHAT-20 | L2 | BE: dừng/mở nhận đơn và báo mù qua C11 | 11 | 112,114,115 | K |
| CHAT-21 | L2 | BE: khách soạn và gửi đơn qua C02 | 11,20 | 112,115,117 | K |
| CHAT-22 | L2 | BE: POS nhập/duyệt/từ chối/rời quán qua C15, C12 | 11,20 | 112,114,115 | K |
| CHAT-23 | L2 | FE: thẻ đơn khách, thông tin giao nhập trực tiếp | 21 | 112,115,117 | K |
| CHAT-24 | L2 | FE: thẻ đơn POS, phân kênh và bàn, đúng người bấm | 22 | 112,114,115 | K |
| CHAT-25 | L2 | BE: tiến độ và khai người tại POS qua C17 | 14,22,24 | 112,113,114,115 | K |
| CHAT-26 | L2 | BE: giá/thành phần/combo qua C05, phần giá của C04 | 19,23,24 | 112,114,115 | K |
| CHAT-27 | L2 | BE: khoản chi, loại và khoản con qua C10 | 11,26 | 112,114,115 | K |
| CHAT-28 | L2 | BE: thu/huỷ/hoàn/nợ/giảm giá qua C13 | 23,24,25 | 112,114,115 | K |
| CHAT-29 | L2 | BE: két/sổ giấy/đối soát C14, đặt tối thiểu C03 | 27,28 | 112,114,115 | K |
| CHAT-30 | L2 | DB: báo nghỉ theo lời, tách khỏi chấm công/lương | 02 | 116 | K |
| CHAT-31 | L2 | BE: báo nghỉ, kiểm người gửi/nhận/duyệt theo lời | 30 | 116; 114 nếu chủ nhập hộ | K |
| CHAT-32 | L2 | FE: báo nghỉ bằng mẫu, không cần model | 04,31 | 116; 114 nếu chủ nhập hộ | K |
| CHAT-33 | L3 | Diễn đầu-cuối, cắt phụ thuộc, đo chi phí | Nhánh được duyệt | 112–117 theo nhánh | C/K |
| CHAT-34 | L2 | BE: người được giao đọc việc của chính mình, không mở cả quán | 02 | Không | K |

**Thứ tự là phụ thuộc và rủi ro, không phải lịch.** Lát chỉ đọc 03…09 phải nghiệm thu trước mọi lệnh ghi
qua model; tin báo 12…14, báo nghỉ 30…32 và 34 không gọi model nên không chờ các lát ấy, và U-112 trả lời
chậm không giữ chân hộp tin. Mã là nhãn, không phải thứ tự: 34 đứng trước 14. CHAT-33 vẫn là bước đóng lane.
06 trước khi khách thật dùng 07, và trước đặt món. Các nhánh ít rủi ro mở trước; 28…29 mở sau đơn và
tiến độ. Nhánh nghỉ chỉ mở khi đủ lời, không ép cả lane đợi nó. CHAT-01/02 có thể thu và duyệt từng nhánh;
không gọi phần chưa có lời là xong. Trạng thái thực tế vẫn chỉ ở backlog chung.

**Mỗi lát lùi riêng:** tắt công cụ hoặc mặt FE của lát ấy, giữ dữ liệu và vết; lát phụ thuộc tắt trước.
Lát DB phải có xuôi/lùi và từ chối lùi khi sẽ mất tin đã ghi. Không lùi dữ liệu bằng cách xoá lịch sử.
Các bước 15…20, 25…29 chỉ thêm nối công cụ BE; FE dùng thẻ chung của 11, không gộp sửa FE vào phiếu.
Nếu thẻ chung không diễn đủ một nhóm, Claude tách thêm lát FE trước khi mở nhóm đó; không nhét vào BE.
Các cửa còn thiếu của admin là phụ thuộc ngoài lane, không tự phát sinh DB/BE admin trong bước chat.

## 5. Cổng của lane

**Mở bước đầu:** T-283 được Claude duyệt để CHAT-01 thu lời; đây là bước quyết định, chưa thi công.
**Mở thi công:** ADR-136 đã chốt, thiết kế nhánh qua CHAT-02, câu chặn nhánh đã có lời trong owner,
phiếu có scope/Acceptance/test trước và nền thật được tích hợp. Không dựng từ HEAD thiếu nền ở cây chính.
Gỡ xung đột luật trước, không dùng chính kế hoạch để gỡ U-XXX.

**Đóng lane:** CHAT-33 có bằng chứng cho từng năng lực đã được duyệt, cả ca nhận và ca từ chối;
thử tắt model mà quán vẫn làm việc; số và giá khớp backend; không lộ dữ liệu khi đổi phiên; không ghi đôi;
Claude duyệt và chủ repo quyết mở thật. Nhánh bị loại có lời loại trong owner, nhánh còn chờ ghi rõ ở
backlog chung; không đánh dấu toàn bộ mong muốn hoàn thành khi nhánh còn bị chặn. Bán thật còn chờ T-109.

| Cổng | Giữ gì | Không chứng minh được |
|---|---|---|
| Gate 3 | File đúng scope | Đúng nghiệp vụ |
| Gate 1b/1c/1d | Pointer, trạng thái tài liệu, ranh giới pha | Nội dung tự bịa nhưng hợp khuôn |
| Gate 1e | Tên lược đồ khớp migration | Tin báo có bị hiểu nhầm là tiến độ |
| Gate 1f/1g | Một cửa một việc, hợp đồng/quyền khớp code | Model chọn đúng ý định |
| Gate 1h, Gate 1 | Ranh giới code, test DB/BE/FE khi có thay đổi | Thiết bị bếp dễ bấm hay không |
| Eval CHAT-06 | Ca chữ đã biết, giá có nguồn, từ chối vượt quyền | Mọi câu tự nhiên có thể xuất hiện |
| Review Gate 2/4/5/6 | Acceptance, diff, mức, duyệt độc lập | Lời chủ quán chưa thu |
| Gate 7/7b và §6.1 | Khối commit và scope do lead bàn giao | Direct gate không chạy hai gate này |

Mắt người giữ: câu nào là lời chủ quán, nhánh nào chưa được cho phép, nghĩa của “xác nhận”, nội dung công
khai được gửi model, mẫu chữ bếp đọc được, một người canh+dọn không nhận trùng việc, thẻ có đủ rõ để bấm.
Claude phải xem diff thật và chạy lại gate khi tích hợp; báo cáo Codex không thay bằng chứng ấy.

## 6. Rủi ro và đường lùi

| Rủi ro | Phép kiểm cần có | Đường lùi |
|---|---|---|
| Model hỏng/chậm | Cắt mạng, quá hạn, huỷ khi đóng chat; DB không chờ model | Tắt trợ lý, vào màn tay |
| Model nói sai giá/số | So với nguồn đọc, ca không có dữ liệu và giá vừa đổi | Không bày số không có nguồn |
| Lời chèn lệnh của khách | Giả vai, gọi công cụ kín, nội dung độc trong tin | Backend từ chối |
| Lộ dữ liệu cá nhân | Hai phiên, hai vai, log và payload gửi hãng được kiểm | Chặn gửi, thu hẹp nội dung theo U-112 |
| Vượt chi phí | Nhiều lượt đồng thời, hết trần, khởi động lại không mất số dùng | Ngừng gọi model, không ngừng bán |
| Tin trạm trễ/trùng | Mất SSE, kéo lại, gửi mất phản hồi, canh+dọn cùng người | Đọc nguồn ghi; nói trực tiếp với POS |
| Ghi thành công mà mất phản hồi | Gửi lại đúng dấu nếu cửa hỗ trợ, đọc lại có quyền | Báo chưa rõ; không gửi lại ngầm |
| Đổi người trước khi xác nhận | Khoá tài khoản/rời quầy giữa đề xuất và bấm | Từ chối; bỏ thẻ của phiên trước |

Không cho lời trong tin, tên món hay kết quả công cụ trở thành chỉ dẫn hệ thống. Dữ liệu riêng không vào
prompt công khai; cookie, mật khẩu, mã đặt lại không gửi hãng. Cơ chế giữ lịch sử, hạn lưu, bộ lọc dữ liệu
và bộ đếm chi phí do Claude thiết kế ở 02 theo U-112; chưa duyệt thì không gửi nội dung thật.

**Nếu U-112 trả lời không dùng model:** bỏ nhánh 03, 05…09 và các công cụ ngôn ngữ 15…29; màn tay tiếp tục
đảm nhiệm những việc ấy. Giữ 01/02 để Claude duyệt phương án hẹp, 04 làm vỏ hộp tin, 12…14 và 34 làm tin
trạm, 30…32 làm báo nghỉ nếu đủ U-116, và 33 nghiệm thu phần được giữ.
10/11 chỉ giữ phần xác nhận bằng mẫu nếu thiết kế hộp tin cần, không gọi model. Hỏi quán và đặt món đi qua
màn công khai hiện có; không tuyên bố hộp tin thuần tuý làm được trợ lý ngôn ngữ.

## 7. Chi phí — suy luận, chưa đo

Không chọn model: **chờ U-112**. Bảng USD/1M token, Claude tra trang hãng **2026-11-01**; tra lại trước
khi mở thật:

| Model | Đầu vào | Đầu ra | Đọc cache |
|---|---:|---:|---:|
| `claude-opus-5-5` | 4 | 20 | 0,20 |
| `claude-sonnet-5-5` | 2 | 10 | 0,10 |
| `claude-haiku-5-5` (prompt tới 100.000 token) | 0,10 | 0,50 | 0,01 |

Nguồn: [Anthropic — Pricing](https://platform.claude.com/docs/en/about-claude/pricing). Ghi cache đắt hơn
đầu vào thường; Haiku tăng giá khi prompt vượt 100.000 token. Đo token ở CHAT-03 rồi mới tính hoá đơn.

Đặt `D` = ngày dùng/tháng, `N` = lượt/ngày, `K` = lần gọi model trung bình/lượt; một lượt có thể gọi model
nhiều lần sau khi đọc công cụ. `I`, `O` = token đầu vào chưa cache/đầu ra trung bình **mỗi lần gọi**, gồm
lịch sử và kết quả công cụ; `H` = token đọc cache, `W` = token ghi cache; `pI`, `pO`, `pH`, `pW` = đơn giá.
`E` = chi phí eval và lần gọi thử/lỗi tính phí ngoài các lượt trên. Không đếm trùng token giữa I/H/W.

```text
C_model_USD = D × N × K × (I × pI + O × pO + H × pH + W × pW) / 1_000_000 + E
C_total_USD = C_model_USD + C_hạ_tầng_tăng_thêm + C_theo_dõi + C_thuế_phí
```

Giả định nền để ước lượng thận trọng: `H = W = 0`, chưa dựa vào tiết kiệm cache; `D, N, K, I, O, E`
đều chưa đo, không đặt một hoá đơn tháng giả làm lời hứa. Cache prompt của hãng không cho phép cache
giá/menu nghiệp vụ trái RB-3; nếu dùng sau này phải có phép đo và quyết định riêng theo U-112.

CHAT-03 phải đo token, số lần gọi và chi phí theo lượt/ngày/tháng, đặt trần tháng `B` theo lời U-112.
Kiểm phần còn lại trước mỗi lần gọi, tính cả lượt đang chạy và phần đầu ra tối đa; không đợi vượt trần
mới báo. Hết ngân sách, thiếu số dùng sau khởi động lại hoặc không tính được chi phí ⇒ ngừng gọi model.
Chỗ cất bộ đếm nếu cần lược đồ phải được Claude tách lát DB trước 03; chưa đặt tên bảng ở kế hoạch này.

## 8. Vị trí so với Đ-2 và pha 5

Owner xếp lịch là `work/backlog.md` mục **Thứ tự làm — Đ-2**; kế hoạch không cho CHAT chen trước, cũng
không suy lời mở DB/backend admin thành lời mở chat. Nhánh 15…29 cần các cửa nền của admin/bán hàng đã
vào nhánh tích hợp và chạy được; đọc thấy ở cây chính chưa commit không đủ điều kiện giao worktree mới.

`T-109` là việc bảo toàn và phục hồi dữ liệu, đang chờ chủ repo mở pha 5; phải đạt trước bán thật.
CHAT có thể thu lời và diễn trên dữ liệu thử sau cổng của mình; điều ấy không mở pha 5 thay chủ repo.
Tin báo/báo nghỉ và dữ liệu giới hạn chi phí nếu được cất phải đi vào phạm vi sao lưu/khôi phục khi
pha vận hành được mở. Chủ repo quyết lịch; Claude chỉ ghi phụ thuộc và bằng chứng trong backlog chung.
