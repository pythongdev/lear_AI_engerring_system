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
| `/quay` | quầy | khung quầy — màn nghiệp vụ dựng ở các bước sau | `P4-04` |
| `/chu-quan` | chủ quán | khung chủ quán — màn nghiệp vụ dựng từ `P4-05`; trang **Tổng quan** của admin (`P4A-02`) | `P4-04` |
| `/chu-quan/*` (layout) | chủ quán | vỏ chung mọi trang chủ quán (sửa 2026-10-19, `P4A-01`): gác một chỗ bằng `KhungTheoVai`, thanh điều hướng đọc từ `fe/src/app/chu-quan/_components/muc-chu-quan.ts`. Trang admin là route con của `/chu-quan` — **không** khung `/admin` thứ hai (`khungCua` chỉ biết ba khung); `/chu-quan/tong-ket` dành cho `P4A-03` | `P4A-01` |
| `/chu-quan/san-pham` | chủ quán | trang **Sản phẩm** (2026-10-19, `P4A-04`): xem · thêm · đổi tên món; sửa giá · thành phần · ngừng bán vẫn ở màn của `P4-05` | `P4A-04` |
| `/chu-quan/danh-muc` | chủ quán | trang **Danh mục** (2026-10-19, `P4A-05`): thêm · đổi tên · ẩn danh mục, xếp · chuyển món; không xoá, không gieo sẵn danh mục | `P4A-05` |
| `/chu-quan/combo` | chủ quán | trang **Combo** (2026-10-19, `P4A-05`): xem · lập combo với giá riêng · đổi giá ngoài giờ bán · ẩn; mức phụ thu theo món chỉ đọc | `P4A-05` |
| `/tram` | trạm (chỉ đọc) | khung trạm — bảng dựng ở các bước sau | `P4-04` |

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
| `/chu-quan/danh-muc` — Danh mục | `GET /menu-categories` (mặc định, **cùng khoá** với Sản phẩm) | `POST /menu-categories` · `PUT /menu-categories/{menu_category_id}` · `POST /menu-categories/{menu_category_id}/hiding` (có lý do) · `PUT /menu-items/{menu_item_id}/category` (lý do chỉ khi chuyển) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh mục*, không bày form (2026-10-19, Claude Code) | `P4A-05` |
| `/chu-quan/combo` — Combo | `GET /menu-combos` (mặc định) · `GET /menu-categories` (món chọn được khi lập, cùng khoá) | `POST /menu-combos` · `PUT /menu-combos/{menu_combo_id}/price` · `POST /menu-combos/{menu_combo_id}/hiding` (có lý do) | mở màn · quay lại cửa sổ · mạng về · sau ghi; **không** kéo theo chu kỳ | `Alert` *Chưa đọc được danh sách combo*; giá là `price_vnd` backend trả — **không** cộng giá món, không gọi `/price-quotes` (giá combo đặt riêng, `master_plan/shop-facts.md` §8.9) (2026-10-19, Claude Code) | `P4A-05` |

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
  (**ADR-102** điểm 2). Thử lại đường đọc khi `no_response` là cấu hình của thư viện truy vấn, chốt ở `P4-05`.
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

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P4-03` | §3.1 lệnh sinh type để so lệch; §3.2 để biết tầng chuyển tiếp là chỗ duy nhất gọi `fetch` thẳng |
| `P4-04` | §3.1 danh tính bằng cookie phiên (đã làm; chữ *`personId` · tên đang chọn* cũ bỏ 2026-10-19, `T-202`) |
| `P4-05` | §1 · §2 thêm dòng màn đầu tiên; §3.1 cấu hình thư viện truy vấn; §4 primitive đầu tiên |
| `P4-06` | §3.2 ba điều phải chứng minh trên luồng thật |
