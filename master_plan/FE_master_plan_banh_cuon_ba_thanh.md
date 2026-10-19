# FE — kế hoạch pha 4 dự án Bánh cuốn Bà Thanh Cao Bằng

*Viết 2026-10-13 · T-178 · chủ repo ký mở pha 4 cùng ngày (T-176, *"mở phase 4"*) rồi hỏi *"backlog của phase 4
đâu"*. Quyết định về hình dạng của kế hoạch này: `docs/decisions.md` **ADR-101**; hình dạng chép của kế hoạch
pha 3 (**ADR-076**), vốn chép của pha 2 (**ADR-049**).*

> **File này là KẾ HOẠCH, không sở hữu một sự thật nào.** Nó nói *pha 4 nợ những gì và chạy theo thứ tự
> nào*. Nó không giữ route, component, hợp đồng API, quyền của một vai, luật nghiệp vụ hay giá. Chỗ nào cần
> một con số hay một luật, đọc ở owner của nó (`CLAUDE.md` §2) — ở đây cố ý không có bản chép thứ hai (**F-001**).
>
> **Trạng thái của từng bước không nằm ở đây.** Owner của *Tasks* là `work/backlog.md`; mô tả dài và hồ sơ
> thực thi của từng bước là entry ở [`work/backlog_FE.md`](../work/backlog_FE.md) (**ADR-051**). Bảng §6 không
> có cột Trạng thái.
>
> **Pha 4 ĐÃ MỞ 2026-10-13 — chủ repo ký chuyển pha** (T-176) khi cổng pha 3 đứng 10/12; `F-068` (nợ test
> backend) mang sang Open, không chặn bước nào ở đây vì pha 4 không đổi cửa. **Cách chia mười hai bước dưới
> đây là phiên đề xuất, chờ chủ repo xác nhận** (§8).

---

## 1. Câu hỏi pha 4 phải chốt xong — một dòng

> **Người dùng thấy gì.**

Câu của pha 4 trong bảng sáu pha ([`prompt-fullstack.md`](prompt-fullstack.md) §7). Đầu ra bắt buộc ở đó:
**cây route** · **nguyên tắc UI theo từng loại người dùng** · **nguồn dữ liệu mỗi màn** · **type sinh từ hợp
đồng API, không gõ tay**. Kế hoạch này thêm thứ năm, cùng lý lẽ ADR-039 thêm cho pha 2: **một cổng frontend
trong `./scripts/gate.sh`** — không có nó, báo cáo của Codex về một màn không có bằng chứng (`CLAUDE.md` §5).

## 2. Ranh giới của pha 4 — ba thứ không được xuất hiện trong đầu ra

| Không được | Vì sao | Gặp thì làm gì |
|---|---|---|
| **Đổi hợp đồng API** — thêm đường gọi, đổi chữ ký, đổi mã lỗi | [`prompt-fullstack.md`](prompt-fullstack.md) §7: *pha 4 không đổi hợp đồng*; hợp đồng thắng code (**ADR-084**) | Ghi một `F-XXX` gửi ngược về pha 3; màn chờ, hoặc bày phần đã có |
| **Tự tính tiền ở trình duyệt** — cộng giá gốc, phụ thu, giảm giá, tổng | Một hàm tính giá duy nhất ở backend (**ADR-086**, `I-013`); [`01-hop-dong-api.md`](../docs/product/3-be/01-hop-dong-api.md) §5 | Gọi tính thử (`POST /price-quotes`) hoặc đọc số backend trả |
| **Đoán một luật quán** — chữ hiện cho khách, ai thấy nút nào ngoài ma trận vai | `CLAUDE.md` §3.5 | Mở `U-XXX`; màn bày lời từ chối của backend, không chặn thay |

Ngoài ra **mảng admin** có mười một bước `P4A-01`…`P4A-11` trong sổ pha 4 (**ADR-103**, chủ repo 2026-10-13), nhưng
các bước ấy chỉ mở khi backend admin có cửa (**ADR-068**). Trang của chủ quán **dựng được** trong pha 4 chỉ
là trang **có cửa ở pha 3**. Danh sách và điều kiện mở: §6a — `P4A-01`…`P4A-03` mở 2026-10-19.

## 3. Pha 4 nhận gì từ pha trước — đọc trước khi viết dòng code đầu tiên

| Nguồn | Đọc như |
|---|---|
| [`docs/product/3-be/openapi.yaml`](../docs/product/3-be/openapi.yaml) · [`01-hop-dong-api.md`](../docs/product/3-be/01-hop-dong-api.md) | **nguồn duy nhất** của type và hình lỗi; §3 cách đọc lỗi; §5 không tự tính |
| [`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md) | lớp quyền của mỗi cửa — nút nào hiện cho ai |
| [`03-ham-gia.md`](../docs/product/3-be/03-ham-gia.md) §4 | việc giao pha 4: lời nhắc *đang trong giờ bán* trước khi đổi thành phần suất |
| [`09-realtime-du-phong.md`](../docs/product/3-be/09-realtime-du-phong.md) · **ADR-097** | SSE chỉ báo *đọc lại*; màn tự kéo 20 giây cả khi không có SSE |
| [`05-realtime-va-du-phong.md`](../docs/product/1-system-design/05-realtime-va-du-phong.md) §1.3 | màn trạm chỉ đọc; màn rỗng trông thế nào là việc pha 4 |
| [`10-quy-uoc-code.md`](../docs/product/2-db/10-quy-uoc-code.md) `QC-08` · `QC-09` · **ADR-100** | `fe/` ở gốc; Next.js + TypeScript, Node 24 LTS; shadcn/ui, TanStack Query, Zustand |
| `docs/private/fe/fe_guidance/` | **đề xuất tham khảo** (render, tải, state, component) — `P4-01` chọn cái gì thành luật |
| `docs/private/fe/PAGES_INDEX.md` · `docs/private/fe/shared/` | bản chép dự án khác — **chỉ** cảm hứng bố cục, không phải danh sách màn |

## 4. Chỗ đang chặn

| Mã | Chặn bước | Ghi chú |
|---|---|---|
| **ADR-104** · `T-181` — đăng nhập bằng tài khoản mật khẩu thay chọn tên (chủ quán 2026-10-14) | `P4-04`, rồi mọi bước cần danh tính | chờ thiết kế L3 `T-181` được chủ repo duyệt; U-088 đã đóng; U-080 (Telegram) đã đóng 2026-10-14 — báo đơn bằng SSE |
| **S-6** — đơn giao tận nơi bấm *đã ra bàn* lúc nào | `P4-07` vế giao hàng | cửa backend đang từ chối kèm mã; màn bày lời ấy |
| **Backend admin chưa có cửa** (ADR-068) | ~~mọi `P4A-XX`~~ — **gỡ cho `P4A-01`…`P4A-03` 2026-10-19** (cửa ở hợp đồng 0.40.0: `P3A-09` · `P3A-10` · `T-197` · `T-199`; `P4-04` Done); còn chặn bước nào thì đọc §6a | §6a; không chặn cổng pha 4; U-081…U-086 đã đóng 2026-10-14 |
| **F-068** | không chặn bước nào | nợ test của `be/`; sửa trong lane backend |

## 5. Đầu ra pha 4 nằm ở đâu

- **Code:** `fe/` (`QC-08` · `QC-18`), ra đời ở `P4-02` (2026-10-13).
- **Tài liệu:** `docs/product/4-fe/`, ra đời ở `P4-02` cùng lượt hàng *Route, component* của `CLAUDE.md` §2 có
  owner thật (**ADR-035**). Trước lượt ấy không file nào được kể tên route hay component như một sự thật.
- **Quyết định:** `docs/decisions.md`; luật code frontend vào `10-quy-uoc-code.md` thành `QC-XX` mới.

## 6. Mười hai bước — master task pha 4

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|---|
| **P4-01** | **Ranh giới, từ vựng và nền của pha 4** — chọn từ `fe_guidance` cái gì thành luật (cách render theo loại màn, cách tải và đọc lại sau ghi, chỗ ở của state), chốt phần **ADR-100** để mở (form, khung test, công cụ sinh type, theme) và nền của `fe/` (trình quản lý gói, cách gọi backend, danh tính trên SSE quầy); số phiên bản cụ thể để `P4-02` — một ADR, không code — **đã chốt: ADR-102** | T-176 | ADR mới; mọi bước sau trích được câu trả lời cho *"màn này lấy dữ liệu thế nào, ghi xong làm gì"*; `fe/` chưa tồn tại | Mười một bước mỗi bước tự chọn thư viện và cách đọc lại — giá cũ nằm trong cache sau khi chủ quán đổi giá | L2 |
| **P4-02** | **Dựng `fe/` và mở `docs/product/4-fe/`** — khung Next.js, shadcn khởi tạo theo ADR-100, type sinh từ `openapi.yaml`, lớp gọi API đọc đúng hình lỗi và mã từ chối; `QC-XX` mới cho frontend; hàng §2 *Route, component* có owner | P4-01 | `fe/` dựng và chạy; type sinh ra khớp bản commit; một test gọi lớp API với một lỗi mẫu của hợp đồng ra đúng mã | Mỗi màn tự viết `fetch` và tự đoán hình lỗi | L1 |
| **P4-03** | **Cổng frontend** — `verify.sh` gọi bước kiểm `fe/` (lint, kiểm kiểu, test, type sinh lệch hợp đồng ⇒ đỏ); phép chặn *cộng tiền ở `fe/`* và *bộ UI thứ hai* (ADR-100) | P4-02 | Cổng chạy trong `./scripts/gate.sh`; ca hồi quy chứng minh nó biết đỏ với từng lỗi | Màn đỏ mà gate xanh; Codex báo *đã xong* không bằng chứng | L2 |
| **P4-04** | **Danh tính và khung theo vai** — chọn tên, vào · rời quầy (T-143), khung riêng cho quầy · chủ quán · trạm (chỉ đọc) · khách; nút hiện theo lớp quyền nhưng backend vẫn là người chặn | P4-03 | Test: người không đứng quầy không thấy nút của lớp `quay`; gọi cửa vẫn bị backend từ chối và màn bày đúng lời | Nhân viên thấy nút đổi giá; hoặc màn chặn thay backend rồi lệch ma trận | L2 |
| **P4-05** | **Trang chủ quán *Menu & giá* — trang thử** — xem menu, đổi giá gốc · phụ thu · thành phần suất có lý do, ngừng bán; lời nhắc *đang trong giờ bán* (`03-ham-gia.md` §4); rút **khuôn** cho mọi trang sau | P4-04 | Ghi xong thì màn đọc lại menu, số hiện là số backend trả; thiếu lý do ⇒ bày lời từ chối; chạy trên app thật cùng backend | Chủ quán đổi giá mà màn còn hiện giá cũ, hoặc màn tự cộng phụ thu sai | L2 |
| **P4-06** | **Lớp realtime chung** — nghe SSE, tự kéo 20 giây, banner mất kết nối luôn nhìn thấy (ADR-097) | P4-04 | Cắt backend ⇒ banner hiện, màn vẫn kéo lại khi nối được; test với luồng giả | Quầy tưởng không có đơn mới trong khi luồng đã đứt | L2 |
| **P4-07** | **Màn quầy — nhận và ghi đơn** — hàng đợi, duyệt · từ chối, POS tạo lượt gọi, đơn điện thoại, nhả đơn hẹn | P4-05 · P4-06 · U-080 | Đi Scenario 1 · 2 đến hết bước nhận đơn qua màn | Đơn web nằm chờ không ai thấy | L2 |
| **P4-08** | **Màn quầy — tiền** — tính tiền phiên, đóng, trao tại quầy, giao xong, hoàn, thu nợ, trả trước, trả lại, giảm giá cả đơn (chủ quán) | P4-07 | Mọi số tiền trên màn là số backend trả; Scenario 1 · 2 đến hoá đơn | Thu sai tiền khách mà sổ vẫn cân | L2 |
| **P4-09** | **Sản xuất theo mẻ** — bảng trạm chỉ đọc; bấm mẻ · lùi mẻ · ra bàn · chuyển · ghi làm sai ở quầy | P4-06 | Màn trạm không có một nút thao tác nào (test); bấm mẻ ở quầy ⇒ trạm đổi qua SSE | Bếp bấm thay quầy, hai nơi giữ một tiến độ | L2 |
| **P4-10** | **Khách — QR tại bàn và đơn web** — quét mã, gọi món, gửi lượt; đơn mang đi · giao · đặt trước | P4-06 · P4-05 | Giá khách thấy là giá tính thử của backend; gửi lại cùng lượt không nhân đôi đơn (`I-024`) | Khách gửi hai lần, bếp làm hai lần | L2 |
| **P4-11** | **Chủ quán — két và ngày bán** — khai đầu két, đếm, sửa đếm, khai sổ giấy, nhập bù, đối soát xong, nợ, tạm dừng · tiếp tục nhận đơn, đổi mã QR | P4-08 | Một ngày bán giả đi hết qua màn ⇒ đối soát 0đ lệch | Ngày ký sai mà không ai thấy lệch | L2 |
| **P4-12** | **Cổng chất lượng pha 4 và rà ranh giới** — ba scenario diễn qua giao diện thật; rà pointer; mỗi ô §9 một bằng chứng | P4-07…P4-11 | File cổng ký từng ô; ký chuyển pha 5 là quyền chủ repo | Sang vận hành với một màn chưa ai đi hết | L2 |

**Thứ tự này đưa trang chủ quán *Menu & giá* lên làm trang thử** theo yêu cầu chủ repo (2026-10-13: *"test
với page product … build page product với crud trước"*): trang ấy có ít cửa nhất mà vẫn chạm tiền, nên khuôn rút
ra từ nó đã qua một lần duyệt chạm tiền trước khi nhân sang màn quầy. **Không bước nào là L3**; mỗi bước làm
xong trong một phiên, bước to (`P4-07`, `P4-08`) được chẻ tiếp ở lúc nhận nếu một phiên không đủ.

## 6a. Mười một bước admin — `P4A-01`…`P4A-11`, đều đang bị chặn

**Nguồn:** chủ repo 2026-10-13 (**ADR-103**): thêm bước admin **bị chặn**, theo **đúng các trang admin** của
`docs/private/fe/PAGES_INDEX.md`. Tên route ở cột hai là **tên nguồn** trong bản ấy, không phải route đã chốt
(owner route ra đời ở `P4-02`). Mô tả dài của từng bước: [`work/backlog_FE_AD.md`](../work/backlog_FE_AD.md).
Cách làm theo **ADR-102**, không theo JWT · WebSocket của `PAGES_INDEX.md`.

**Một bước `P4A-XX` chỉ *Ready* khi đủ ba điều:** (a) chủ repo mở kế hoạch backend admin và cửa trang cần đã có trong
`docs/product/3-be/openapi.yaml`; (b) câu `U-XXX` ở cột *Chặn thêm* đã đóng; (c) `P4-04` đã *Done*. Bước admin không
chặn `P4-12` hay cổng §9.

**Mở 2026-10-19** (Claude Code, chủ repo bảo làm tiếp đề xuất *sửa đề bài P4A rồi giao Codex*): `P4A-01` · `P4A-02` ·
`P4A-03` đủ ba điều — cửa `GET /sessions/current` (T-190), `GET /owner-overview` · `PUT /daily-minimums/{sale_date}`
(P3A-09 · T-199 · T-197), `GET /sale-days/{sale_date}/summary` (P3A-10) ở hợp đồng 0.40.0; không câu `U-XXX` chặn;
`P4-04` Done. Route chốt ở `docs/product/4-fe/01-khung-fe.md` §1 cùng lượt dựng — trang admin nằm dưới khung
`/chu-quan`, không mở khung `/admin` thứ hai.

**Mở 2026-10-19, lượt hai** (Claude Code, chủ repo giao `P4A-04`): `P4A-04` đủ ba điều — cửa `POST /menu-items` ·
`PUT /menu-items/{menu_item_id}` (P3A-07) và `GET /menu-categories` (P3A-05) ở hợp đồng 0.40.0; không câu `U-XXX` chặn;
`P4-04` Done. Trang dưới `/chu-quan/san-pham`; sửa giá · thành phần · ngừng bán vẫn của `P4-05`.

**Mở 2026-10-19, lượt ba** (Claude Code, chủ repo giao `P4A-05`): `P4A-05` đủ ba điều cho **danh mục** và **combo** —
cửa `/menu-categories*` · `PUT /menu-items/{menu_item_id}/category` (P3A-05) và `/menu-combos*` (P3A-06 · P3A-11) ở hợp
đồng 0.40.0; không câu `U-XXX` chặn; `P4-04` Done. **Topping chưa đủ điều (a):** hợp đồng không có cửa thêm tuỳ chọn hay
nhóm tuỳ chọn, còn đổi phụ thu của tuỳ chọn là của `P4-05` — phần ấy giữ *bị chặn*. Trang dưới `/chu-quan/danh-muc` ·
`/chu-quan/combo`.

**Mở 2026-10-19, lượt bốn** (Claude Code, chủ repo giao `P4A-06`): `P4A-06` đủ ba điều — cửa `GET /accounts` ·
`POST /accounts/{account_id}/approval|rejection|lock|unlock` (T-190) và `GET /people` ở hợp đồng 0.40.0; thiết kế `T-181`
Done (**ADR-109**); không câu `U-XXX` chặn (`U-083` · `U-088` đã đóng); `P4-04` Done. Trang dưới `/chu-quan/nhan-vien`.

**Mở 2026-10-19, lượt năm** (Claude Code, chủ repo bảo *"hãy yêu cầu codex làm 2 task trên bạn kiểm tra"* cho `P4A-07` ·
`P4A-08`): `P4A-07` đủ ba điều — cửa `/assigned-tasks*` (P3A-03, lớp `quay_hoac_chu_quan`) và `GET /people` ở hợp đồng
0.40.0; `U-084` · `U-089` đã đóng; `P4-04` Done. Trang dưới `/chu-quan/giao-viec` chỉ cho chủ quán; POS giao việc **từ
quầy** cần một màn quầy riêng — chưa có bước. Hướng dẫn gắn vào việc (`/assigned-tasks/{assigned_task_id}/guides`) là của
`P4A-11`. `P4A-08` đủ ba điều — cửa `/supply-items*` · `/supply-day-entries*` (P3A-02) ở hợp đồng 0.40.0; không câu `U-XXX`
chặn; `P4-04` Done. Trang dưới `/chu-quan/nguyen-lieu`; số thiếu, tỉ lệ nhắc và lời nhắc (`/supply-stock` ·
`/reminder-ratio`) để lại cho `P4A-09`.

| ID | Trang (tên nguồn trong `PAGES_INDEX.md`) | Dữ kiện quán đã có | Chặn thêm | Mức |
|---|---|---|---|---|
| **P4A-01** | **Khung admin** — vỏ chung của `/admin/*` | lớp `chu_quan` ([`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md)) | — | L1 |
| **P4A-02** | **Tổng quan** — `/admin/overview` | bảy thứ chủ quán muốn thấy, `master_plan/shop-facts.md` §8.6; *số tiền dự tính* không phải doanh thu đã đối soát | — | L2 |
| **P4A-03** | **Tổng kết** — `/admin/summary` | bốn thứ chủ quán muốn, theo ngày, hiệu suất nhân viên đã định nghĩa (§8.6 bổ sung 2026-10-14); doanh thu cộng hai nguồn, hoàn trừ ngày hoàn (§6) | — | L2 |
| **P4A-04** | **Sản phẩm** — `/admin/products` | sửa giá · ngừng bán đã ở `P4-05`; chủ quán **cần** thêm · xoá món (§8.9 bổ sung 2026-10-14); có cửa thêm · đổi tên món 2026-10-16 (P3A-07) | — | L2 |
| **P4A-05** | **Combo · danh mục · topping** — `/admin/combos` · `/admin/categories` · `/admin/toppings` | chủ quán **cần** cả ba (§8.9 bổ sung 2026-10-14); quán có combo (D42); topping là tuỳ chọn phụ thu §4.4 · §4.6 | — | L2 |
| **P4A-06** | **Nhân viên** — `/admin/staff` | mỗi người một tài khoản, mật khẩu riêng (§8.8 sửa 2026-10-14, **ADR-104**): tự đăng ký, chủ quán duyệt; mảng con người §8.7 | thiết kế `T-181` | L2 |
| **P4A-07** | **Giao việc** — `/admin/staff/task-board` · `/admin/todo-list` | chủ quán và POS tạo · sửa · xoá việc và đánh dấu xong (§8.7, 2026-10-14); chưa có lược đồ | — | L1 |
| **P4A-08** | **Nguyên liệu** — `/admin/ingredients` | sổ ghi tay điện tử §8.4; lược đồ `P2A-02` | — | L1 |
| **P4A-09** | **Kho** — `/admin/storage` | §8.4: máy **không** kết luận thiếu ⇒ không có *dự kiến hết*; **sửa 2026-10-14:** máy nhắc POS kiểm tra khi còn dưới tỉ lệ chủ quán đặt (U-087 đóng) | lược đồ `T-186` | L1 |
| **P4A-10** | **Marketing** — `/admin/marketing` | một **khoản chi** của mảng tài chính (§8.10 bổ sung 2026-10-14) | — | L1 |
| **P4A-11** | **Đào tạo** — `/admin/training` | hướng dẫn chữ · ảnh · video theo việc; chủ quán hoặc POS ghi nhận xét và đánh giá đạt · chưa (§8.7, 2026-10-14); chưa có lược đồ | — | L1 |

## 7. Trang *Menu & giá* có gì — đọc từ cửa, không từ chữ *CRUD*

Cửa của pha 3 cho chủ quán **xem**, **sửa có lý do** (giá gốc thành phần, phụ thu, số lượng thành phần suất) và
**ngừng bán**. Không có cửa **tạo món** — thêm món ngoài `shop-facts.md` §4.2 là đổi phạm vi, quyền chủ quán
([`03-lat-cat.md`](../docs/product/0-ba/ban-hang/03-lat-cat.md) §3.3.7); không có **xoá** — quy ước không xoá cứng
(`docs/product/2-db/01-quy-uoc-du-lieu.md`). Chủ repo muốn tạo món ⇒ một câu cho chủ quán và một bước ở pha 3, không
một nút ở pha 4.

## 8. Chỗ kế hoạch này SUY RA — chờ chủ repo xác nhận

- **Cách chia mười hai bước và thứ tự §6.** Lời chủ repo mới là *mở pha 4* và *trang sản phẩm trước*.
- **Trang thử đứng sau danh tính (`P4-04`)**: mọi cửa menu là lớp `chu_quan`, không có danh tính thì không gọi được.
- **Cách gộp trang admin thành mười một bước `P4A-XX`, mức của từng bước, và việc chúng không chặn cổng §9** — chủ repo
  chỉ nói *thêm bước admin bị chặn, đúng các trang trong PAGES_INDEX* (2026-10-13, **ADR-103**). Chấm công, khoản của
  người, khoản chi có dữ kiện nhưng không có trang trong `PAGES_INDEX.md`, nên chưa có bước.

## 9. Cổng chất lượng pha 4 — chỉ sang pha 5 khi đủ các ô, mỗi ô có bằng chứng

> **Các ô dưới đây là LỜI của cổng; chỗ KÝ là file cổng do `P4-12` sinh ra.** Hộp ở đây không được tick (**F-001**).

- [ ] **Type sinh từ hợp đồng, không gõ tay** → cổng `P4-03` đỏ khi type lệch `openapi.yaml`; `grep` không type
      đường gọi nào viết tay.
- [ ] **Không chỗ nào trong `fe/` tính tiền** → phép chặn của `P4-03` xanh, đã chứng minh biết đỏ.
- [ ] **Mọi màn đọc dữ liệu từ đúng một nguồn và đọc lại sau mỗi lần ghi** → bảng nguồn dữ liệu mỗi màn ở
      `docs/product/4-fe/`, đối chiếu từng màn.
- [ ] **Màn trạm chỉ đọc** → test `P4-09`.
- [ ] **Mất kết nối luôn nhìn thấy** → cắt backend, dán ảnh hoặc log của từng màn có realtime.
- [ ] **Mọi mã lỗi công khai có chữ hiện cho người dùng** → danh sách mã từ hợp đồng, `comm -3` với bảng chữ.
- [ ] **Nút hiện theo lớp quyền khớp ma trận** → mỗi cửa một dòng, đối chiếu với `02-vai-va-quyen.md`.
- [ ] **Ba scenario đi hết qua giao diện thật** → `P4-12`, một ngày bán giả ⇒ đối soát 0đ lệch.
- [ ] **Pha 4 không đổi hợp đồng** → `git log` của `openapi.yaml` trong mọi bước `P4-XX` rỗng.
- [ ] **Hàng `CLAUDE.md` §2 *Route, component* hết nói *chưa có owner***.

## 10. Rủi ro lớn nhất của pha này

**Màn giữ một bản giá hoặc trạng thái cũ trong cache sau khi backend đã đổi** — chủ quán đổi giá, quầy vẫn bán
giá cũ trên màn, khách thấy một số và hoá đơn ra số khác. **Cách chặn:** `P4-01` chốt *ghi xong thì đọc lại* (**ADR-102** điểm 2 · 3),
`P4-03` chặn cộng tiền ở `fe/`, và ô cổng thứ ba ở §9.

## 11. Cách giao một bước — lời gọi dán được

Hồ sơ thực thi của mỗi bước là entry của nó ở [`work/backlog_FE.md`](../work/backlog_FE.md). Lời gọi dưới đây để
**bắt đầu** một phiên, không thay entry:

```text
Nhận bước P4-XX của pha 4. Đọc CLAUDE.md, chạy ./scripts/brief.sh, rồi đọc entry P4-XX ở
work/backlog_FE.md và kế hoạch master_plan/FE_master_plan_banh_cuon_ba_thanh.md §2 · §6 · §9.
Kiểm cột "Cần xong trước": bước nào chưa Done thì dừng và báo.
Nếu khối "Nhận việc" còn trống: viết Phạm vi, Nghiệm thu, Kiểm chứng TRƯỚC khi sửa gì, rồi dừng
cho tôi duyệt. Nếu đã có: khai work/scope/P4-XX.txt, chuyển P4-XX sang In Progress và làm.
Không đổi docs/product/3-be/openapi.yaml; không tính tiền ở fe/; chỉ dùng primitive shadcn (ADR-100).
Gặp luật nghiệp vụ chưa rõ: không đoán — mở U-XXX, màn bày lời từ chối của backend.
Kết thúc bằng khối Bàn giao trong entry và khối git commit dán được (CLAUDE.md §6.1).
```

Giao cho Codex thì Claude viết **phiếu giao việc** theo `docs/prompt-guideline.md` §6.1 từ entry ấy, trong worktree
riêng; Claude đọc lại diff thật, chạy lại gate và chạy app thật trước khi tích hợp (**ADR-054**).

## 12. Còn lại — pha 5

Triển khai, HTTPS, sao lưu đã phục hồi thử (`T-109`), và câu VPS của `F-070` điểm 2.
