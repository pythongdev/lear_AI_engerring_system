# Khung frontend — cây route, nguồn dữ liệu mỗi màn, lớp gọi API, danh mục component

Pha 4 · bước `P4-02` · viết 2026-10-13 (Claude Code). Owner của hàng *Route, component* ở `CLAUDE.md` §2
(**ADR-035**). Thước của pha 4 — mỗi nhóm người dùng lấy dữ liệu thế nào, ghi xong làm gì, state ở đâu:
`docs/decisions.md` **ADR-102**; file này **áp** thước ấy vào từng route, không chép lại nó.

**File này sở hữu:** cây route của `fe/` · nguồn dữ liệu của từng màn · cách lớp gọi API đọc hợp đồng ·
danh mục component dùng chung.

**File này KHÔNG sở hữu:**
- **hợp đồng API** — đường gọi, thân, mã lỗi: [`../3-be/openapi.yaml`](../3-be/openapi.yaml), luật đọc ở
  [`../3-be/01-hop-dong-api.md`](../3-be/01-hop-dong-api.md);
- **ai được bấm gì** — [`../3-be/02-vai-va-quyen.md`](../3-be/02-vai-va-quyen.md);
- **dựng bằng gì, ghim bản nào** — `QC-09` · `QC-18` ở [`../2-db/10-quy-uoc-code.md`](../2-db/10-quy-uoc-code.md);
- **chữ hiện cho khách** — luật quán, mở `U-XXX` ở bước gặp nó (kế hoạch pha 4 §2).

---

## 1. Cây route

Mỗi màn thêm **một dòng** ở đây cùng lượt dựng nó, và nhóm người dùng của nó là một trong bốn nhóm của
**ADR-102** điểm 1. Thư mục là `fe/src/app/`.

| Route | Nhóm (ADR-102) | Là gì | Bước dựng |
|---|---|---|---|
| `/` | — | trang giữ chỗ của khung, không dữ liệu, không màn nghiệp vụ | `P4-02` |
| /robots.txt | — | chỉ dẫn thu thập cho máy tìm kiếm | `T-189` |
| /sitemap.xml | — | danh sách URL công khai | `T-189` |
| `/api/[...path]` | — | **tầng chuyển tiếp** cùng origin, không phải màn (§3.2) | `P4-02` |
| `/dang-nhap` | — | đăng nhập; *tại quầy* mở trực quầy (mốc `C36`, **ADR-109** điểm 7) | `P4-04` |
| `/dang-ky` | — | tự đăng ký, chờ chủ quán duyệt | `P4-04` |
| `/quen-mat-khau` | — | xin mã đặt lại (luôn cùng một câu) và đặt lại bằng mã trong thư | `P4-04` |
| `/doi-mat-khau` | — | đổi mật khẩu; bắt buộc khi đang dùng mật khẩu tạm | `P4-04` |
| `/quay` | quầy | khung quầy; màn chính là **hàng chờ quầy** (2026-10-20, `P4-07` đợt một): đơn chờ xác nhận · duyệt · từ chối, tạm dừng · quán mù và *Mở lại nhận đơn*, đơn hẹn; soạn lượt gọi và đơn điện thoại là đợt hai | `P4-04` · `P4-07` |
| `/quay/san-xuat` | quầy | **Sản xuất** (2026-10-20, `P4-09`): cùng bảng của trạm + *Ra bàn* theo bàn · đơn không bàn; bấm mẻ · lùi mẻ · chuyển · ghi làm sai chờ đường đọc (F-073) | `P4-09` |
| `/quay/*` (layout) | quầy | vỏ chung (2026-10-20, `P4-06`): `KhungTheoVai` gác một chỗ, `TinHieuProvider` giữ `GET /counter/events` **suốt ca** — đổi trang con không đóng mở lại luồng (luồng quầy là dấu hiệu *quán còn nhìn thấy*, **ADR-097** điểm 4), `BaoMatKetNoi` dính đầu màn; trang con không tự bọc khung | `P4-06` |
| `/quay/giao-viec` · `/quay/dao-tao` | quầy | POS giao việc và ghi đào tạo từ quầy (2026-10-19, `T-212`): **cùng** `TrangGiaoViec` · `TrangDaoTao` của chủ quán trong khung quầy; `/quay` có hai lối vào | `T-212` |
| `/chu-quan` | chủ quán | khung chủ quán — màn nghiệp vụ dựng từ `P4-05`; trang **Tổng quan** của admin (`P4A-02`) | `P4-04` |
| `/chu-quan/*` (layout) | chủ quán | vỏ chung mọi trang chủ quán (sửa 2026-10-19, `P4A-01`): gác một chỗ bằng `KhungTheoVai`, thanh điều hướng đọc từ `fe/src/app/chu-quan/_components/muc-chu-quan.ts`. Trang admin là route con của `/chu-quan` — **không** khung `/admin` thứ hai (`khungCua` chỉ biết ba khung); `/chu-quan/tong-ket` dành cho `P4A-03` | `P4A-01` |
| `/chu-quan/san-pham` | chủ quán | trang **Sản phẩm** (2026-10-19, `P4A-04`): xem · thêm · đổi tên món; sửa giá · thành phần · ngừng bán vẫn ở màn của `P4-05` | `P4A-04` |
| `/chu-quan/menu-gia` | chủ quán | trang **Menu & giá** (2026-10-20, `P4-05`) — trang thử chạm tiền, khuôn ở §6: giá mỗi tổ hợp · thành phần · phụ thu; đổi giá gốc · phụ thu · số lượng thành phần suất có lý do, ngừng bán; không thêm món, không xoá | `P4-05` |
| `/chu-quan/danh-muc` | chủ quán | trang **Danh mục** (2026-10-19, `P4A-05`): thêm · đổi tên · ẩn danh mục, xếp · chuyển món; không xoá, không gieo sẵn danh mục | `P4A-05` |
| `/chu-quan/combo` | chủ quán | trang **Combo** (2026-10-19, `P4A-05`): xem · lập combo với giá riêng · đổi giá ngoài giờ bán · ẩn; mức phụ thu theo món đặt được từ `T-211` (lựa chọn theo món đọc `GET /option-groups`) | `P4A-05` |
| `/chu-quan/topping` | chủ quán | trang **Topping** (2026-10-19, `T-210`): nhóm tuỳ chọn và lựa chọn, phụ thu mỗi phần nhận nhân; thêm lựa chọn vào nhóm có sẵn kèm nhóm nó mở; ẩn · bật lại có lý do; mặc định không ẩn | `T-210` |
| `/chu-quan/nhan-vien` | chủ quán | trang **Nhân viên** (2026-10-19, `P4A-06`): tài khoản theo trạng thái · duyệt kèm vai trạm · từ chối · khoá · mở lại kèm mật khẩu tạm (**ADR-109**); không bày mật khẩu, không xoá | `P4A-06` |
| `/chu-quan/giao-viec` | chủ quán | trang **Giao việc** (2026-10-19, `P4A-07`): việc mới nhất trước, lọc người nhận · giao · sửa có lý do · đánh dấu xong và bỏ đánh dấu · xoá là ẩn có lý do; không hạn, không hướng dẫn (của `P4A-11`) | `P4A-07` |
| `/chu-quan/nguyen-lieu` | chủ quán | trang **Nguyên liệu** (2026-10-19, `P4A-08`): sổ ghi tay §8.4 — danh mục · thêm thứ · đặt đơn vị lần đầu · sổ ngày của một thứ, ghi con số mua vào · đã dùng, sửa có lý do; không bày số thiếu, tỉ lệ, lời nhắc (của `P4A-09`) | `P4A-08` |
| `/chu-quan/kho` | chủ quán | trang **Kho** (2026-10-19, `P4A-09`): hai tổng, *mua vào trừ đã dùng*, lần nhập gần nhất, tỉ lệ nhắc và cờ nhắc POS kiểm tra đúng như backend trả; đặt tỉ lệ có lý do; không *dự kiến hết* | `P4A-09` |
| `/chu-quan/khoan-chi` | chủ quán | trang **Khoản chi** (2026-10-19, `P4A-10`): loại chi khai nguồn két · tiền riêng, ghi · sửa có lý do khoản chi, lọc ngày · loại · nguồn; chi phí marketing là một loại chi ở đây, không có trang riêng | `P4A-10` |
| `/chu-quan/dao-tao` | chủ quán | trang **Đào tạo** (2026-10-19, `P4A-11`): ghi nhận xét và đánh giá *làm được · chưa* về một người, sửa · ẩn có lý do; hướng dẫn chữ · ảnh · video gắn từng việc được giao, sửa chữ · ẩn có lý do; màn quầy cho POS chưa có | `P4A-11` |
| `/tram` | trạm (chỉ đọc) | **Bảng trạm** (2026-10-20, `P4-09`): bảng sản xuất gom theo trạm, không một nút | `P4-04` · `P4-09` |
| `/tram/*` (layout) | trạm (chỉ đọc) | vỏ chung (2026-10-20, `P4-06`): `KhungTheoVai` + `TinHieuProvider` trên `GET /production-board/events` + `BaoMatKetNoi` | `P4-06` |

### Hiện trên máy tìm kiếm

Bổ sung 2026-10-14 theo phiếu `T-189`: layout gốc mặc định ẩn khỏi máy tìm kiếm. Trang công khai phải nằm
trong `PUBLIC_ROUTES` ở `fe/src/lib/seo.ts`, gọi `publicPageMetadata(path)` tại trang và thêm dòng vào bảng
route cùng lượt. Nội dung trang công khai phải render ở server, không chỉ tải bằng React Query phía trình duyệt.
Biến phía server `BANHCUON_SITE_URL` đọc lúc build; thiếu biến thì không có địa chỉ canonical, sitemap rỗng và
robots.txt không khai sitemap. Cách kiểm và phần còn chờ: [báo cáo SEO](02-toi-uu-seo.md).

## 2. Nguồn dữ liệu mỗi màn

Ô cổng §9 thứ ba của kế hoạch pha 4 đối chiếu từng màn với bảng này. Mỗi màn một dòng, viết ở bước dựng nó;
ô *Đọc lại sau ghi* và *Mất kết nối* chép đúng dòng nhóm của **ADR-102** điểm 1 trừ khi màn có lý do khác —
khi ấy ghi lý do.

**Ngày bán không suy từ đồng hồ máy** (2026-10-19, `T-202`, theo `fe-03` §6 và
`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`): màn cần *ngày bán hôm nay* lấy ngày backend trả
(ví dụ `sale_date` của `GET /owner-overview`), không dựng từ `new Date()` của trình duyệt; ngày người dùng chọn để
xem đi trên URL (**ADR-102** điểm 4).

| Màn (route) | Đường đọc của hợp đồng | Đường ghi | Đọc lại khi | Mất kết nối bày gì | Bước |
|---|---|---|---|---|---|
| `/chu-quan` — Tổng quan | `GET /owner-overview` | `PUT /daily-minimums/{sale_date}` (`sale_date` của lần đọc) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ — hợp đồng không trả `poll_interval_seconds` cho chủ quán | giữ bản cũ kèm `Alert` có mốc `read_at` của bản ấy (dòng *Chủ quán*) | `P4A-02` |
| `/chu-quan/tong-ket` — Tổng kết | `GET /sale-days/{sale_date}/summary`; ngày xem là `?ngay=YYYY-MM-DD`, thiếu thì `sale_date` của `GET /owner-overview` | — | mở màn · đổi ngày · quay lại cửa sổ · mạng về; **không** kéo theo chu kỳ — đọc theo kỳ, ngày đã qua ít đổi | `Alert`; `400 invalid_request` ⇒ *Ngày không hợp lệ*, không bày mục; `supply_reminders` luôn ghi là kết quả hiện tại kèm `read_at` (2026-10-19, Claude Code) | `P4A-03` |
| `/chu-quan/san-pham` — Sản phẩm | `GET /menu-categories` (mặc định; món của danh mục ẩn nằm trong `uncategorized_items`) | `POST /menu-items` · `PUT /menu-items/{menu_item_id}` (có lý do) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh sách món*, không bày form; trang **không** bày giá, không gọi `/price-quotes` — giá do backend tính từ thành phần (2026-10-19, Claude Code) | `P4A-04` |
| `/chu-quan/menu-gia` — Menu & giá | `GET /menu` (giá mỗi tổ hợp) · `POST /price-quotes` **một lần cho mỗi món**, dòng `{menu_item_id, quantity: 1, option_ids: prices[0].option_ids}` — đọc `lines[0].components` (mã, tên, số lượng, giá gốc), vì hợp đồng không có đường đọc thành phần riêng · `GET /option-groups` (phụ thu) | `PUT /menu-components/{menu_component_id}/base-price` · `PUT /menu-options/{menu_option_id}/surcharge` · `PUT /menu-items/{menu_item_id}/components/{menu_component_id}` · `POST /menu-items/{menu_item_id}/discontinuation` — cả bốn có lý do | mở màn · quay lại cửa sổ · mạng về · sau ghi (khoá `menu` · `price-quotes` · `option-groups`, thêm `menu-categories` khi ngừng bán); **không** kéo theo chu kỳ | `Alert` *Chưa đọc được menu* kèm giờ của bản cũ; món tính thử lỗi bày *Chưa đọc được thành phần* và không nút sửa thành phần; số là số backend, màn chỉ định dạng `35.000đ`. Lời nhắc giờ bán trước khi đổi số lượng **luôn** hiện — hợp đồng không có đường đọc giờ bán, màn không đoán từ đồng hồ máy (`03-ham-gia.md` §4; suy ra 2026-10-20, Claude Code, chờ chủ repo) | `P4-05` |
| `/quay` — Hàng chờ quầy | `GET /counter/queue` (`tuyChonKeo`) · `GET /dining-tables` (nhãn bàn) · `GET /preorder-reminders` (kéo 20 giây — đường này không trả chu kỳ) | `POST /orders/{sales_order_id}/approval` · `/rejection` · `POST /shop-blind/reopening`; layout gọi `POST /preorder-releases` thân `{}` mỗi 20 giây (*máy POS tự gọi*, `05-luong-mang-di.md` §2) | tín hiệu `hello` · `changed` · chu kỳ backend · sau ghi | `BaoMatKetNoi` của layout; tạm dừng · quán mù chỉ theo `paused_since` · `blind_since`; đơn chờ **chưa** bày món — hợp đồng chưa trả (F-074) | `P4-07` |
| `/quay/san-xuat` — Sản xuất · `/tram` — Bảng trạm | `GET /production-board` (`tuyChonKeo`) · `GET /menu` (tên nhân) · `GET /dining-tables` (nhãn bàn) — cả ba công khai | quầy: `POST /served-marks`; trạm: không | tín hiệu · chu kỳ backend · sau ghi | luôn hiện *Cập nhật lúc* của `read_at`; *Hết việc* chỉ khi đọc được mà rỗng; đọc lỗi giữ bản cũ kèm cảnh báo (`05-realtime-va-du-phong.md` §1.3) | `P4-09` |
| `/chu-quan/danh-muc` — Danh mục | `GET /menu-categories` (mặc định, **cùng khoá** với Sản phẩm) | `POST /menu-categories` · `PUT /menu-categories/{menu_category_id}` · `POST /menu-categories/{menu_category_id}/hiding` (có lý do) · `PUT /menu-items/{menu_item_id}/category` (lý do chỉ khi chuyển) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh mục*, không bày form (2026-10-19, Claude Code) | `P4A-05` |
| `/chu-quan/combo` — Combo | `GET /menu-combos` (mặc định) · `GET /menu-categories` (món chọn được khi lập, cùng khoá) | `POST /menu-combos` · `PUT /menu-combos/{menu_combo_id}/price` · `POST /menu-combos/{menu_combo_id}/hiding` (có lý do) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh sách combo*; giá là `price_vnd` backend trả — **không** cộng giá món, không gọi `/price-quotes` (giá combo đặt riêng, `master_plan/shop-facts.md` §8.9) (2026-10-19, Claude Code) | `P4A-05` |
| `/chu-quan/topping` — Topping | `GET /option-groups` | `POST /option-groups/{option_group_id}/options` · `POST /menu-options/{menu_option_id}/hiding` · `…/unhiding` | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | phụ thu là số backend trả, không nhân theo suất ở màn; không tính giá (2026-10-19, Claude Code) | `T-210` |
| `/chu-quan/nhan-vien` — Nhân viên | `GET /accounts` (không lọc, chia nhóm theo `status`) · `GET /people` (người gắn được khi duyệt: chưa có tài khoản, không phải chủ quán) · `GET /sessions/current` (không nút khoá chính mình) | `POST /accounts/{account_id}/approval` · `/rejection` · `/lock` · `/unlock` (mật khẩu tạm ≥ 8 ký tự) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh sách tài khoản*; `account_not_*` ⇒ *trạng thái đã đổi* và đọc lại; trang **không** bày mật khẩu của ai (2026-10-19, Claude Code) | `P4A-06` |
| `/chu-quan/giao-viec` — Giao việc | `GET /assigned-tasks` (không `include_hidden`; lọc `?assignee_person_id=` trên URL) · `GET /people` (mọi người, không lọc) | `POST /assigned-tasks` · `PUT /assigned-tasks/{assigned_task_id}` · `/hiding` · `/marks` | mở màn · đổi lọc · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh sách việc*; `assigned_task_*` đã đổi ⇒ báo rồi đọc lại; `person_not_found` gắn ô người nhận (2026-10-19, Claude Code) | `P4A-07` |
| `/chu-quan/nguyen-lieu` — Nguyên liệu | `GET /supply-items` · sổ mở bằng `?thu=` đọc `GET /supply-items/{supply_item_id}` | `POST /supply-items` · `PUT /supply-items/{supply_item_id}/purchase-unit` · `POST /supply-day-entries` · `PUT /supply-day-entries/{supply_day_entry_id}` | mở màn · mở sổ · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | con số là chuỗi backend trả, không tính ở trình duyệt; ngày ghi không mặc định từ đồng hồ trình duyệt; `supply_day_entry_already_recorded` ⇒ *dùng Sửa ở dòng đã có* (2026-10-19, Claude Code) | `P4A-08` |
| `/chu-quan/kho` — Kho | `GET /supply-stock` | `PUT /supply-items/{supply_item_id}/reminder-ratio` | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | con số và tỉ lệ là chuỗi backend trả, không đổi ra phần trăm, không so ngưỡng; cờ nhắc là `boolean` backend trả; trạng thái `no_purchase` · `latest_purchase_zero` bày lý do nhắc, `usage_before_first_purchase` bày ghi chú (T-204, 2026-10-19, Claude Code) | `P4A-09` |
| `/chu-quan/khoan-chi` — Khoản chi | `GET /expense-categories` · `GET /expenses` theo `?tu` · `?den` · `?loai` · `?nguon`; ngày thiếu lấy `sale_date` của `GET /owner-overview` | `POST /expense-categories` · `POST /expenses` · `PUT /expenses/{expense_id}` | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | tổng là `total_vnd` backend, không cộng ở trình duyệt; nguồn của loại bắt buộc chọn, không chọn sẵn; ngày chi không mặc định; `sale_day_reconciled` gắn ô ngày (2026-10-19, Claude Code) | `P4A-10` |
| `/chu-quan/dao-tao` — Đào tạo | `GET /training-records` (lọc `?nguoi=` · `?an=1`) · `GET /people` · `GET /assigned-tasks` · hướng dẫn mở bằng `?viec=` đọc `GET /assigned-tasks/{assigned_task_id}/guides` (`?an-hd=1`); ảnh · video phát từ `GET /assigned-task-guides/{assigned_task_guide_id}/file` | `POST /training-records` · `PUT /training-records/{training_record_id}` · `POST /training-records/{training_record_id}/hiding` · `POST /assigned-tasks/{assigned_task_id}/guides` (multipart) · `PUT /assigned-task-guides/{assigned_task_guide_id}` · `POST /assigned-task-guides/{assigned_task_guide_id}/hiding` | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | sửa ghi nhận gửi **cả hai** trường vì vắng nghĩa là không còn; trường trống khi thêm thì không gửi khoá; không tự kiểm cỡ tệp, `file_too_large` báo cỡ theo hợp đồng (2026-10-19, Claude Code) | `P4A-11` |

## 3. Lớp gọi API

### 3.1 Một lớp, sinh từ hợp đồng

- **Type sinh, không gõ tay.** `fe/src/lib/api/schema.ts` sinh từ `openapi.yaml` bằng `npm run gen:api` trong `fe/`
  (openapi-typescript, cờ `--enum-values` để có danh sách mã lỗi lúc chạy). Hợp đồng đổi ⇒ chạy lại lệnh và
  commit file sinh cùng lượt; `scripts/fe-check.sh` (`P4-03`) làm cổng đỏ khi file sinh lệch hợp đồng.
- **`int64` sinh thành số JavaScript** (`number`). Chấp nhận vì mã và số tiền của một quán nằm xa giới hạn số
  nguyên an toàn (**ADR-102** điểm 5).
- **Mọi lời gọi đi qua `fe/src/lib/api/client.ts`** (openapi-fetch có kiểu theo đường gọi): `createApi` dựng
  client, `call` đổi kết quả thành `ApiResult`. Không màn nào tự viết `fetch` tới backend.
- **Ba hình thất bại** (`ApiFailure`), theo `01-hop-dong-api.md` §3 và **ADR-102** điểm 1 · 2:

  | `kind` | Khi nào | Màn làm gì |
  |---|---|---|
  | `rejected` | backend trả hình `Error` với một `code` có trong `ErrorCode` | chọn chữ **theo `code`**, không theo status; có `field` thì gắn vào đúng ô |
  | `no_response` | không có phản hồi của backend — mất mạng, hay tầng chuyển tiếp không nối được backend | lệnh ghi: *chưa rõ kết quả*, không mời gửi lại ngầm; đường đọc: giữ bản cũ kèm cảnh báo theo nhóm |
  | `unexpected` | có phản hồi nhưng lạ hình — mã không có trong hợp đồng, thân không phải `Error` | coi như lỗi hệ thống; mã lạ là dấu hợp đồng và code lệch ⇒ `F-XXX` |

- **Không thử lại** ở lớp này — lệnh ghi không thử lại ngầm, đường đọc không thử lại lời từ chối có `code`
  (**ADR-102** điểm 2). Đường đọc gặp `no_response` **cũng không** thử lại ngầm (chốt 2026-10-20, `P4-05`, Claude Code):
  `retry: false` giữ nguyên; màn giữ bản cũ kèm cảnh báo và đọc lại khi quay lại cửa sổ, khi mạng về, hay khi người bấm
  *Đọc lại*. Màn sống (quầy, trạm) còn kéo theo chu kỳ của `P4-06`.
- **Một `QueryClient`** ở `fe/src/lib/api/provider.tsx` (sửa 2026-10-19, `T-202`): `retry: false`; *đọc lại khi quay
  lại cửa sổ* để mặc định của TanStack Query (bật) — **ADR-102** điểm 3. Màn nào muốn tắt cho một query phải ghi lý do
  ở dòng của nó trong §2. Test: `fe/src/lib/api/provider.test.tsx`.
- **Danh tính** (sửa 2026-10-14, `P4-04`, **ADR-109** điểm 6): cookie phiên `banhcuon_phien` `HttpOnly` do backend
  đặt; trình duyệt tự gửi tới `/api` cùng origin (`credentials: "same-origin"`), code **không** đọc hay cất mã phiên.
  Header chọn tên `X-Person-Id` đã gỡ ở `T-190`. Phiên đọc bằng `usePhien()` (`fe/src/lib/auth/session.ts`,
  `GET /sessions/current`; 401 ⇒ chưa đăng nhập); đăng nhập, đăng xuất, đổi mật khẩu xoá sạch cache của người trước.
  Khung theo vai chọn ở `fe/src/lib/auth/khung.ts` — vai chọn màn, **không** mở quyền.
- **Test:** `fe/src/lib/api/client.test.ts` — lời từ chối mẫu `option_combination_invalid` kèm `field`, mã lạ,
  thân không phải JSON, mất kết nối, tầng chuyển tiếp không nối được backend, không gửi header danh tính.

### 3.2 Tầng chuyển tiếp cùng origin

Trình duyệt chỉ gọi server Next (**ADR-102** điểm 6): `/api/<đường gọi của hợp đồng>` → backend ở
`BANHCUON_BE_URL` (biến môi trường **phía server**, không tiền tố `NEXT_PUBLIC_`; mặc định
`http://127.0.0.1:8080`, cổng mặc định của `be/cmd/server`). File: `fe/src/app/api/[...path]/route.ts`.

- Chạy cho từng request, không cache; trả nguyên status, thân, `Content-Type`, `Cache-Control`, `Allow`.
- Chuyển `Accept`, `Content-Type`, `Cookie`, `Origin`, `Last-Event-ID` — không header nào khác lên backend
  (sửa 2026-10-14, `P4-04`: `Origin` để backend chặn cửa ghi khác nguồn; `X-Person-Id` thôi chuyển). Trả về mọi
  dòng `Set-Cookie` riêng rẽ, không gộp. Test: `fe/src/app/api/[...path]/route.test.ts`.
- Thân backend đi ra dưới dạng luồng, nén tắt (`fe/next.config.ts`) ⇒ `text/event-stream` không bị đệm.
- Đường dẫn lấy nguyên từ URL, không giải mã lại — `%2F` trong mã QR tới backend như cũ (`QC-12`).
- Không nối được backend ⇒ `502` kèm header `x-banhcuon-upstream-unreachable` (lớp gọi API đọc thành
  `no_response`). Backend không bao giờ đặt header ấy.
- Trình duyệt đi ⇒ lời gọi lên backend huỷ theo. Điều này và *luồng quầy đóng thì backend thấy đóng* là việc
  `P4-06` chứng minh trên app thật (**ADR-102** điểm 7).

Đo 2026-10-13 (Claude Code, `P4-02`, backend thật + `next start`): `GET /menu` qua Next ra cùng `shasum` với gọi
thẳng backend; `/counter/queue` không danh tính `401 unauthenticated`, có `X-Person-Id` thì backend đọc người
(`403 not_on_counter_duty`) — header tới nơi; `POST /price-quotes` lời từ chối kèm `field` đi nguyên; mã QR
`a%2Fb` ra cùng lời backend; `405` giữ `Allow`; sự kiện `hello` của luồng trạm tới sau 0,01 giây — không đệm;
backend tắt ⇒ `502` kèm header trên.

### 3.3 Lớp realtime và nhiều tab (`P4-06`, 2026-10-20)

- **Luồng là tín hiệu đọc lại** (**ADR-097**): `TinHieuProvider` mở luồng bằng client của `useApi()` (`parseAs: "stream"`,
  không `EventSource`), đọc khung SSE; `hello` · `changed` ⇒ `invalidateQueries()` **mọi** query (không bảng tín hiệu → query,
  ADR-097 bác bảng ấy); `heartbeat` chỉ giữ mốc còn sống. Dữ liệu kèm tín hiệu không vào cache.
- **Đứt** = luồng kết thúc, lỗi, trả khác 200, mất phản hồi, hay **im 25 giây** (2,5 nhịp heartbeat 10 giây — chốt ở đây, câu fe-01 §8.3
  của ADR-102 điểm 8). Đứt ⇒ huỷ lời gọi, `BaoMatKetNoi` hiện (`role="alert"`, không nút, dính đầu màn), nối lại sau 1 · 2 · 4 · 8 rồi
  10 giây, về lại 1 giây sau một `hello`. Lần nối đầu chưa hiện banner. Tab nền giữ luồng (luồng quầy là dấu hiệu *quán còn nhìn thấy*).
- **Kéo theo chu kỳ:** đường đọc sống trải `tuyChonKeo()` — `poll_interval_seconds × 1000`, chưa có lần đọc thì 20 giây (hằng của
  hợp đồng), cả khi tab nền, cả khi luồng sống (**ADR-102** điểm 1).
- **Nhiều tab:** đăng nhập thành công và đăng xuất gửi `{ loai: "doi-phien", tab }` trên `BroadcastChannel("banhcuon-phien")`;
  `KhungTheoVai` của tab **khác** xoá sạch cache rồi về `/dang-nhap`; tin của chính tab hay tin lạ bị bỏ qua.
- **Đo trên app thật** 2026-10-20 (Claude Code, backend thật + `next dev` + Chromium): qua Next, `hello` của luồng trạm tới sau 29 ms —
  không đệm; POS đứng quầy mở `/quay` ⇒ đơn web `201`, tín hiệu `changed` ⇒ màn đọc lại; tắt backend ⇒ banner; bật lại ⇒ nối lại,
  đọc lại, banner tắt; **đóng tab quầy ⇒ đơn web kế tiếp `409 shop_not_seeing_orders`** — backend thấy luồng quầy đóng qua Next
  (ba điều của **ADR-102** điểm 7 đều làm được qua Next, không cần `F-XXX`); hai tab chủ quán, đăng xuất ở tab A ⇒ tab B về
  `/dang-nhap` sau 168 ms. `next dev` mở luồng hai lần lúc vào màn vì React chạy hiệu ứng hai lần ở chế độ phát triển; lần đầu bị huỷ.

## 4. Danh mục component dùng chung

**Ba tầng và chiều import** — chủ repo chọn 2026-10-19 (`T-202`, lấy đề xuất `fe-04` §1):

| Tầng | Thư mục | Giữ gì |
|---|---|---|
| 1 | `fe/src/components/ui/` | primitive shadcn sinh bằng CLI; không fetch, không đọc store, không quyết quyền |
| 2 | `fe/src/components/shared/` | thành phần nghiệp vụ dùng ở **≥ 2** nhóm màn hay khung; nâng lên khi có nơi dùng thứ hai |
| 3 | `fe/src/app/<route>/_components/` | thành phần riêng một màn, đặt cạnh route |

Import chỉ đi **3 → 2 → 1** (tầng 3 dùng thẳng tầng 1 được); tầng 2 không import route hay thành phần riêng của route.
Thư mục theo miền đã có (`fe/src/components/tai-khoan/`, `P4-04`) giữ nguyên tới khi một bước chạm nó thì chuyển về
đúng tầng cùng lượt — không dời hàng loạt chỉ để cho gọn.

Primitive giao diện là shadcn/ui, thêm bằng CLI ghim của `fe/` (`npx shadcn add <tên>` trong `fe/`) vào
`fe/src/components/ui/`, **từng cái khi một màn cần** (**ADR-100**). Một thành phần được nâng lên dùng chung khi
có nơi dùng thứ hai (**ADR-102** điểm 8) và thêm một dòng ở đây cùng lượt.

| Component | Ở đâu | Làm gì | Ai dùng | Bước |
|---|---|---|---|---|
| Primitive shadcn: `Button` · `Input` · `Label` · `Checkbox` · `Field` · `Card` · `Alert` · `Separator` | `fe/src/components/ui/` | sinh bằng CLI ghim, không sửa tay focus, bàn phím, accessibility (**ADR-100** điểm 2) | mọi màn | `P4-04` |
| `TheTaiKhoan` · `Truong` · `Bao` · `NutGui` | `fe/src/components/tai-khoan/khung-form.tsx` | khung, ô nhập kèm lỗi, dòng báo, nút gửi của màn tài khoản — ghép từ primitive trên | năm màn tài khoản | `P4-04` |
| `KhungTheoVai` | `fe/src/components/tai-khoan/khung-theo-vai.tsx` | gác lối vào khung theo phiên, thanh đầu có nút đăng xuất | `/quay` · `/chu-quan` · `/tram` | `P4-04` |
| `ThanhDieuHuong` (tầng 3) | `fe/src/app/chu-quan/_components/thanh-dieu-huong.tsx` | `nav` giữa các trang chủ quán, đọc **một** danh sách mục; mục khớp đúng đường dẫn mang `aria-current`; thêm trang ⇒ thêm mục cùng lượt (test đỏ khi mục trỏ route chưa có `page.tsx`) | layout `/chu-quan/*` | `P4A-01` |
| Primitive shadcn `Dialog` | `fe/src/components/ui/dialog.tsx` | hộp thoại: focus vào khi mở, trả về nút mở khi đóng, `Esc` đóng (Radix) | hộp thoại sửa có lý do | `P4-05` |
| `HopThoaiSuaCoLyDo` (tầng 3, khuôn) | `fe/src/app/chu-quan/_components/hop-thoai-sua-co-ly-do.tsx` | một hộp thoại cho bốn lệnh sửa có lý do của *Menu & giá* — §6 | `/chu-quan/menu-gia` | `P4-05` |
| `TinHieuProvider` · `BaoMatKetNoi` · `tuyChonKeo` · `chuKyKeoMs` | `fe/src/lib/realtime/tin-hieu.tsx` | lớp realtime chung — §3.3 | layout `/quay` · `/tram`; màn quầy · trạm trải `tuyChonKeo()` vào `useQuery` | `P4-06` |
| `BangSanXuat` · `useSanXuat` (tầng 2) | `fe/src/components/shared/bang-san-xuat.tsx` · `du-lieu-san-xuat.ts` | bảng sản xuất **không nút**; nút của quầy nằm ngoài | `/tram` · `/quay/san-xuat` | `P4-09` |
| `TuNhaDonHen` (tầng 3) | `fe/src/app/quay/_components/tu-nha-don-hen.tsx` | máy quầy tự nhả đơn hẹn theo chu kỳ; lỗi thì nói ra | layout `/quay` | `P4-07` |

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P4-03` | §3.1 lệnh sinh type để so lệch; §3.2 để biết tầng chuyển tiếp là chỗ duy nhất gọi `fetch` thẳng |
| `P4-04` | §3.1 danh tính bằng cookie phiên (đã làm; chữ *`personId` · tên đang chọn* cũ bỏ 2026-10-19, `T-202`) |
| `P4-05` | §1 · §2 thêm dòng màn đầu tiên; §3.1 cấu hình thư viện truy vấn; §4 primitive đầu tiên |
| `P4-06` | §3.2 ba điều phải chứng minh trên luồng thật |

## 6. Khuôn một màn — rút từ trang thử *Menu & giá* (`P4-05`, 2026-10-20)

Trang đầu chạm tiền đã qua test viết trước, duyệt diff và chạy thật cùng backend; màn sau làm **theo** khuôn này, khác
thì ghi lý do ở dòng §2 của mình. File mẫu: `fe/src/app/chu-quan/_components/du-lieu-menu-gia.ts` · `menu-gia.tsx` ·
`hop-thoai-sua-co-ly-do.tsx`; test mẫu: `fe/src/app/chu-quan/menu-gia/menu-gia.test.tsx`.

| Phần | Khuôn |
|---|---|
| Dữ liệu | một file `du-lieu-<màn>.ts`: mỗi đường đọc một `useQuery`, khoá bắt đầu bằng tên đường gọi (`["menu"]`, `["option-groups"]`, `["price-quotes", id, …]`) để màn khác cùng đọc thì cùng khoá; lời từ chối đổi chữ trong **một** hàm `loi<Màn>(failure)` theo `code`, không theo status |
| Danh sách | giữ thứ tự backend, không tự xếp; mỗi mục một `section` có `aria-label` là tên — test tìm bằng `getByRole("region")` |
| Số tiền | chỉ định dạng số backend trả (`toLocaleString("vi-VN")` + `đ`); không cộng, không nhân, không suy giá — `check-fe-rules` chặn phần bắt được |
| Sửa có lý do | `Dialog` của shadcn mở từ nút có `aria-label` *động từ + tên*; ô số chỉ nhận chữ số; lý do bỏ khoảng trắng đầu cuối, rỗng ⇒ lỗi ở ô, không gửi; lỗi ô gắn `aria-invalid` và `aria-describedby`; `field` của lời từ chối gắn đúng ô, không có `field` thì bày trong hộp thoại |
| Gửi | một lần bấm một lời gọi (cờ chặn + nút tắt, chữ *Đang lưu…* kèm vòng quay); `no_response` ⇒ *chưa xác nhận được kết quả*, không gửi lại ngầm |
| Sau ghi | thành công ⇒ đóng hộp thoại, báo `role="status"`, chỉ `invalidateQueries` các khoá của màn rồi đọc lại; đọc lại lỗi ⇒ *Đã lưu nhưng chưa đọc lại được*; `*_not_found` hay trạng thái đã đổi ⇒ báo rồi đọc lại |
| Chỉ báo tải | lần đọc đầu: khung xương `role="status"` *Đang tải …*; đang ghi: vòng quay trên nút; đọc lại mà còn bản cũ: dòng nhỏ *Đang cập nhật…*, bản cũ giữ trên màn |
| Mất kết nối | lỗi đọc giữ bản cũ kèm `Alert` có giờ của bản ấy; nút *Đọc lại* |
| Test viết trước | backend giả bằng `fetch` tiêm vào `ApiProvider`, trả được lời hứa chưa giải để thử trạng thái chờ; mỗi ca kiểm **thân** lệnh ghi đúng hợp đồng và **số lần** đọc lại; cài lỗi *bỏ đọc lại* phải làm test đỏ |

