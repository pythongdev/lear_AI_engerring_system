<a id="top"></a>
# Backlog — pha 4 · FE của mảng QUẢN TRỊ (admin)

Mô tả dài của mười một bước `P4A-01`…`P4A-11`. Dựng 2026-10-13 (T-179) theo lời chủ repo: *"work/backlog_FE.md hãy cập
nhật file trên làm cả phần admin kết hợp với docs/private/fe/PAGES_INDEX.md docs/private/fe/fe_guidance"*, rồi
*"hãy tạo thêm 1 file backlo_fe_ad.md cho các task của admin"*. Vì sao có sổ riêng và mọi bước đang bị chặn:
`docs/decisions.md` **ADR-103**. Hình dạng chép của `work/backlog_FE.md` (**ADR-051**).

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Bước nào *Ready*, *In Progress* hay *Done* đọc ở
> `work/backlog.md` (**ADR-002**).
>
> **Nó không giữ thứ tự, mức, hay cột chặn** — ba thứ đó ở
> [`master_plan/FE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/FE_master_plan_banh_cuon_ba_thanh.md) §6a.
>
> **Nó không giữ một route hay component nào như sự thật, và không giữ lời chủ quán.** Owner route ra đời ở `P4-02`
> (**ADR-035**); lời chủ quán ở `master_plan/shop-facts.md` §8; câu còn mở ở `docs/product/99-unknowns.md`.

## Luật của file này

1. **Mô tả viết trước; dòng trạng thái thì không.** Mọi bước đang bị chặn, nên hôm nay (2026-10-13) không bước nào có
   dòng ở *Ready* (**F-012**).
2. **Luật của `work/backlog_FE.md` áp nguyên** — khối **Nhận việc**, khối **Bàn giao**, hai công cụ và app thật.

## Mục lục

| Bước | Entry |
|---|---|
| P4A-01 | [Khung admin](#p4a-01) |
| P4A-02 | [Tổng quan](#p4a-02) |
| P4A-03 | [Tổng kết](#p4a-03) |
| P4A-04 | [Sản phẩm](#p4a-04) |
| P4A-05 | [Combo · danh mục · topping](#p4a-05) |
| P4A-06 | [Nhân viên](#p4a-06) |
| P4A-07 | [Giao việc](#p4a-07) |
| P4A-08 | [Nguyên liệu](#p4a-08) |
| P4A-09 | [Kho](#p4a-09) |
| P4A-10 | [Marketing](#p4a-10) |
| P4A-11 | [Đào tạo](#p4a-11) |

## Chung cho cả mười một bước

**Nguồn:** chủ repo 2026-10-13 (**ADR-103**): thêm bước admin **bị chặn**, theo **đúng các trang admin** của
`docs/private/fe/PAGES_INDEX.md`. Thứ tự, mức và cột *chặn* là của
[kế hoạch §6a](../master_plan/FE_master_plan_banh_cuon_ba_thanh.md); entry dưới đây chỉ giữ mô tả.

Một bước `P4A-XX` chỉ *Ready* khi đủ ba điều: chủ repo mở kế hoạch backend admin và cửa trang cần đã có trong
`docs/product/3-be/openapi.yaml`; câu `U-XXX` của bước đã đóng; `P4-04` đã *Done*. Bước admin **không chặn**
`P4-12` hay cổng pha 4.

**Lời chủ quán 2026-10-14 (T-180).** Sáu câu của sổ này đã đóng (`docs/product/99-unknowns.md`, mục đã có lời giải):
chủ quán **muốn** trang tổng kết, tự quản lý menu, giao việc, ghi chi phí marketing, và hướng dẫn · theo dõi đào tạo;
mỗi người làm có **tài khoản, mật khẩu riêng** — lời này thay *chọn tên* (**ADR-104**). Vế chưa rõ mở thành
`U-087`…`U-090`; lượt hai và ba cùng ngày (T-182 · T-183) đóng `U-088`, `U-089`, `U-090`; lượt bốn (T-185) đóng `U-087` — không câu nào của sổ này còn mở. Lời mới **không** mở bước nào: điều (a) — backend admin có cửa — vẫn chưa có, và `P4-04` đang dừng.

**`PAGES_INDEX.md` cho danh sách trang, không cho cách làm.** Bản ấy chép dự án khác — đăng nhập JWT, WebSocket, CRUD
tự do — và mọi link của nó đã chết. Cách làm theo **ADR-102** và `docs/private/fe/fe_guidance/`; chỗ trang nguồn trái
dữ kiện quán thì dữ kiện thắng (**ADR-103** điểm 4).

---

<a id="p4a-01"></a>
### P4A-01 — Mười trang admin cần chung một vỏ, và vỏ ấy phải chỉ mở cho chủ quán

**Phụ thuộc** · bước admin 1/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin` cùng *Admin shell* — thanh tab chung của mọi trang `/admin/*`, chặn theo vai. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** một khung chung cho các trang `P4A-02`…`P4A-11`: thanh điều hướng giữa các trang admin đã mở được, chỉ hiện với người có lớp `chu_quan`; trang chưa có cửa backend không hiện trong thanh. Backend vẫn là người chặn — khung ẩn trang là tiện, không phải bảo vệ (giống `P4-04`).

**Dữ kiện quán đã có:** ma trận vai [`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md) (lớp `chu_quan`); danh tính bằng tài khoản mật khẩu riêng (`master_plan/shop-facts.md` §8.8 sửa 2026-10-14, **ADR-104** — thay chọn tên của `T-143`); mảng quản trị đứng riêng khỏi bán hàng (`master_plan/shop-facts.md` §8 mở đầu).

**Không lấy từ PAGES_INDEX:** `AuthGuard` · `RoleGuard minRole=MANAGER` theo JWT và đoạn *mobile bottom bar* đề xuất — quán này nhận danh tính bằng header theo **ADR-102**; vai `MANAGER` không có trong ma trận vai.

**Theo fe_guidance:** nhóm màn **chủ quán** của ADR-102 điểm 1; ba tầng và chiều import của `fe-04-shared-components.md` §1 — khung admin dùng chung shared component với khung chủ quán của `P4-04`, không dựng bộ thứ hai.

**Không làm thì mất gì:** mỗi trang admin tự dựng điều hướng và tự kiểm vai, và một trang quên kiểm thì nhân viên thấy nút của chủ quán.

**Bẫy:** đừng viết bảng quyền thứ hai cho admin — đọc lớp của cửa từ cùng một chỗ `P4-04` đọc.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-02"></a>
### P4A-02 — Chủ quán không đứng quầy vẫn muốn nhìn một bảng biết quán đang chạy thế nào

**Phụ thuộc** · bước admin 2/11 · mức L2 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/overview` — *live floor*: thẻ số liệu, đơn đang chạy, bàn, nhật ký đã trả và đã huỷ. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** bày đúng bảy thứ chủ quán đã gọi tên, mỗi thứ đọc từ cửa backend khi cửa ấy có; thứ nào chưa có cửa thì trang nói *chưa có*, không tự tính từ dữ liệu khác.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.6 (bảy thứ, nguyên văn của chủ quán); hàng 6 — số người thực tế do POS khai (`U-060` đã đóng); hàng 7 — ba đường *thiếu*, đường nguyên liệu theo §8.4.

**Không lấy từ PAGES_INDEX:** bố cục và danh sách thẻ của dự án cũ; luồng WebSocket `OrdersWSProvider` — tín hiệu đọc lại đi bằng SSE theo **ADR-097** và **ADR-102**.

**Theo fe_guidance:** mẫu R (tín hiệu đọc lại và đường kéo dự phòng) ở `fe-01-rendering.md` §6; banner mất kết nối và chế độ suy giảm ở `fe-02-loading.md` §4.

**Không làm thì mất gì:** chủ quán nhìn một bảng tự ghép từ nhiều nguồn và tin một con số máy không ai kiểm.

**Bẫy:** *số tiền dự tính* (§8.6 hàng 5) là tạm tính trong buổi — không bao giờ bày cạnh hay giống doanh thu đã đối soát; và frontend không cộng tiền (**ADR-086**).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-03"></a>
### P4A-03 — Trang tổng kết đòi những con số mà mảng tài chính chưa chốt

**Phụ thuộc** · bước admin 3/11 · mức L2 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/summary` — báo cáo: KPI doanh thu, món bán chạy, hiệu suất nhân viên, cảnh báo sắp hết hàng. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** trang tổng kết cho chủ quán bày bốn thứ chủ quán gọi tên 2026-10-14 (U-081, *"cho tất cả thông tin"*): **KPI doanh thu · món bán chạy · hiệu suất nhân viên · cảnh báo sắp hết**. Lượt hai cùng ngày: báo cáo **theo ngày bán**; hiệu suất nhân viên là **số đếm, không chấm điểm, không xếp hạng** — ngày công, số đơn ghi lúc đứng quầy, số lần đi giao, số lần huỷ · hoàn tiền người ấy bấm; *cảnh báo sắp hết* là máy nhắc POS kiểm tra. Ngưỡng: còn dưới tỉ lệ chủ quán đặt cho từng thứ, mặc định 20% của lần nhập gần nhất (U-087 đóng, lượt bốn).

**Dữ kiện quán đã có:** bốn thứ ở `master_plan/shop-facts.md` §8.6 (bổ sung 2026-10-14); món bán chạy khớp `E48` §8.10; luật cộng doanh thu từ hai nguồn và hoàn trừ vào ngày hoàn ở `master_plan/shop-facts.md` §6; doanh thu ngày đã đối soát không đổi; mức sâu của mảng tài chính **chưa chốt** (§8.2).

**Không lấy từ PAGES_INDEX:** *hiệu suất nhân viên* và *cảnh báo sắp hết* như những con số máy tự kết luận — §8.4 nói máy không kết luận thiếu nguyên liệu, và chưa có lời nào về chấm điểm người làm.

**Theo fe_guidance:** mẫu P hoặc S của `fe-01-rendering.md` cho màn đọc theo kỳ; mặc định TanStack Query theo loại dữ liệu ở `fe-02-loading.md` §5.

**Không làm thì mất gì:** báo cáo bày một con số theo định nghĩa của dự án khác, và chủ quán quyết theo nó.

**Bẫy:** báo cáo theo ngày phải dùng **ngày bán**, không dùng ngày lịch của trình duyệt (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-04"></a>
### P4A-04 — Trang sản phẩm của bản cũ cho thêm và xoá món, còn quán này chưa có cửa nào như thế

**Phụ thuộc** · bước admin 4/11 · mức L2 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/products` — CRUD sản phẩm. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** phần **sửa giá, sửa thành phần suất, ngừng bán** đã thuộc `P4-05` và không lặp ở đây. Bước này giữ phần còn lại — **thêm · xoá · sửa thông tin món** — mà chủ quán đã nói **cần** 2026-10-14 (U-082, lời chọn của chủ repo).

**Dữ kiện quán đã có:** chủ quán cần tự thêm · xoá món (`master_plan/shop-facts.md` §8.9, bổ sung 2026-10-14; *xoá* đọc là ngừng bán · ẩn, không xoá cứng); menu do chủ quán gọi tên (§4.9); *món ngoài bảng giá* là đã quyết định không làm (§6.12); D37 · D38 chưa có danh mục mới, D43 cần ảnh món nhưng chưa chốt quyền sửa ảnh (§8.9).

**Không lấy từ PAGES_INDEX:** nút *thêm món* và *xoá món* trước khi có cửa backend; hai trang không được giữ hai bản sửa giá.

**Theo fe_guidance:** mutation chờ xác nhận rồi đọc lại (`fe-02-loading.md` §3) và khuôn hộp thoại sửa có lý do mà `P4-05` rút ra.

**Không làm thì mất gì:** hai trang cùng sửa menu theo hai khuôn, và trang thứ hai không qua lần duyệt chạm tiền của `P4-05`.

**Bẫy:** không cộng giá để *xem trước* ở trình duyệt — gọi tính thử (`P4-05` Bẫy, **ADR-086**).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-05"></a>
### P4A-05 — Combo, danh mục và topping có trang quản lý ở bản cũ nhưng chưa có danh sách ở quán này

**Phụ thuộc** · bước admin 5/11 · mức L2 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/combos` · `/admin/categories` · `/admin/toppings` — ba trang CRUD. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quản lý combo, danh mục món và tuỳ chọn thêm — chủ quán đã nói **cần cả ba** 2026-10-14 (U-082, `master_plan/shop-facts.md` §8.9). Phụ thu của tuỳ chọn đã đổi được ở `P4-05`; bước này không lặp phần ấy.

**Dữ kiện quán đã có:** quán có combo (`master_plan/shop-facts.md` §8.9 D42) nhưng chưa có danh mục combo mới; nhóm tuỳ chọn và phụ thu §4.4; giá suất là tổng thành phần §4.5 · §4.6.

**Không lấy từ PAGES_INDEX:** khái niệm *topping* như một món có giá riêng — ở quán này tuỳ chọn là **phụ thu theo phần nhận nhân** (§4.6), không phải món cộng thêm; danh mục gồm những nhóm nào chưa có dữ kiện — trang để chủ quán tự đặt, không gieo sẵn nhóm của dự án cũ.

**Theo fe_guidance:** query key theo domain backend ở `fe-03-state-management.md` §2 — ba trang đọc cùng domain menu với `P4-05`, không mở key riêng.

**Không làm thì mất gì:** trang bày giá combo tự cộng, lệch với hàm tính giá duy nhất của backend.

**Bẫy:** giá combo không bao giờ là con số nhập tay ở màn — nó là tổng thành phần (§4.7); muốn thấy thì đọc số backend trả.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-06"></a>
### P4A-06 — Trang nhân viên của bản cũ quản lý tài khoản mật khẩu, còn quán này vào máy bằng chọn tên

**Phụ thuộc** · bước admin 6/11 · mức L2 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04` · thiết kế đăng nhập `T-181` (**ADR-104**)

**Trang nguồn:** `/admin/staff` — CRUD tài khoản nhân viên: vai, bật · tắt. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** chủ quán quản lý **tài khoản** của người làm — mỗi người một tài khoản, mật khẩu riêng (U-083, 2026-10-14, thay chọn tên). Lượt hai (U-088 đóng): người làm **tự đăng ký**, trang này là chỗ chủ quán **duyệt** và gán vai, khoá tài khoản người nghỉ; mật khẩu người làm tự đặt và tự đặt lại qua Gmail — trang không bày, không đổi mật khẩu của ai.

**Dữ kiện quán đã có:** tài khoản mật khẩu riêng (`master_plan/shop-facts.md` §8.8 sửa 2026-10-14, **ADR-104**; luật cũ chọn tên của `T-143` · `U-075` còn chạy trong code tới khi thiết kế mới được duyệt); mảng con người ba mức (`master_plan/shop-facts.md` §8.7); mốc đổi người ở quầy (§8.8); bốn vai và năm trạm (§3).

**Không lấy từ PAGES_INDEX:** vai `chef / cashier / staff / manager` — không khớp bốn vai của quán; luồng JWT của dự án cũ — cách đăng nhập là của thiết kế ADR-104; trang đăng ký `/register` cũng không lấy.

**Theo fe_guidance:** store chọn tên ở `fe-03-state-management.md` §4 — đổi người thì xoá sạch dữ liệu của người trước (**ADR-102**).

**Không làm thì mất gì:** chủ quán không có chỗ tạo hay khoá tài khoản, và một người nghỉ việc vẫn vào được máy.

**Bẫy:** ẩn một người không được làm mất vết những gì người ấy đã ghi (không xoá cứng — `docs/product/2-db/01-quy-uoc-du-lieu.md`).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-07"></a>
### P4A-07 — Bản cũ có bảng giao việc và danh sách việc, quán này chưa nói gì về giao việc

**Phụ thuộc** · bước admin 7/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/staff/task-board` · `/admin/todo-list` — bảng việc theo người và danh sách việc của cả nhóm. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quán **có** giao việc trong phần mềm (U-084, 2026-10-14). **Chủ quán và POS** tạo · sửa · xoá việc giao và **đánh dấu xong** (U-089 đóng, lượt ba). Trường của một việc do thiết kế chọn — chủ quán giao cho phiên; *xoá* là ẩn có vết. Chưa có lược đồ và cửa backend cho việc giao — cần một lát lược đồ admin mới trước bước này.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.7 (bổ sung 2026-10-14) — có làm, ai giao, ai đánh dấu xong.

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình việc · người nhận · hạn của dự án cũ.

**Theo fe_guidance:** không áp được trước khi có phạm vi.

**Không làm thì mất gì:** một trang không ai dùng, hoặc một luật giao việc bịa ra rồi thành sự thật.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-08"></a>
### P4A-08 — Chủ quán ghi sổ nguyên liệu bằng tay, và trang này là cuốn sổ ấy

**Phụ thuộc** · bước admin 8/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/ingredients` — danh sách nguyên liệu và các lần nhập · xuất kho. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** xem danh mục nguyên liệu và ghi sổ nhập · dùng ở mức *sổ ghi tay điện tử* — đúng các dòng chủ quán đã chốt, khi backend admin có cửa ghi.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.4 (mức sổ ghi tay, danh mục nguyên liệu, mục nhập tổng hằng ngày); lược đồ `P2A-02` ở `docs/product/2-db/12-luoc-do-nguyen-lieu.md`.

**Không lấy từ PAGES_INDEX:** tồn kho do máy tự tính và cảnh báo hết hàng tự động — §8.4 nói máy không kết luận thiếu.

**Theo fe_guidance:** form theo lựa chọn của ADR-102 điểm 5; mutation chờ xác nhận rồi đọc lại (`fe-02-loading.md` §3).

**Không làm thì mất gì:** chủ quán quay về sổ giấy, và §8.6 hàng 7 (thiếu nguyên liệu) không có nguồn.

**Bẫy:** thứ chưa có đơn vị trong danh mục (§8.4) bày là *chưa có đơn vị*, không tự gán.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-09"></a>
### P4A-09 — Trang kho của bản cũ dự báo ngày hết hàng, còn quán này cấm máy kết luận thiếu

**Phụ thuộc** · bước admin 9/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04` · lược đồ tỉ lệ nhắc `T-186`

**Trang nguồn:** `/admin/storage` — quản lý kho: cảnh báo sắp hết, nối món với tồn kho, dự báo ngày hết. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** bày ba thứ chủ quán đã chốt cho đường thiếu nguyên liệu — thời gian nhập, tổng đã dùng, số thiếu theo đúng phép trừ của §8.4 — để **chủ quán tự kết luận**.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.4 (`U-045` · `U-051` · `U-054` đã đóng) và §8.6 hàng 7.

**Không lấy từ PAGES_INDEX:** cột *dự kiến hết*, *dùng/ngày*, cảnh báo sắp hết, và việc tự tắt món khi hết nguyên liệu — hết nguyên liệu và tạm dừng nhận đơn là hai việc khác nhau (§8.3).

**Theo fe_guidance:** nhóm màn chủ quán của ADR-102: lỗi đọc giữ bản cũ kèm cảnh báo và mốc (`fe-02-loading.md` §1).

**Không làm thì mất gì:** máy nói *sắp hết* thay chủ quán, trái lời đã chốt.

**Sửa 2026-10-14:** máy **nhắc POS kiểm tra** khi một thứ sắp hết (`master_plan/shop-facts.md` §8.4 *Sửa 2026-10-14*); nhắc khi phần còn lại dưới **tỉ lệ chủ quán đặt cho thứ ấy** (mặc định 20%) của lần nhập gần nhất — U-087 đóng, lượt bốn; trang này là chỗ chủ quán đặt tỉ lệ. Cột *dự kiến hết* và *dùng/ngày* vẫn không lấy.

**Bẫy:** số thiếu là số backend trả, không trừ ở trình duyệt; nhắc sắp hết là việc của backend, không so ngưỡng ở trình duyệt.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-10"></a>
### P4A-10 — Bản cũ có trang chi phí marketing, quán này chưa có dữ kiện nào về nó

**Phụ thuộc** · bước admin 10/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/marketing` — ngân sách, phân bổ, dòng thời gian chiến dịch. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** ghi chi phí marketing như **một khoản chi của mảng tài chính** (U-085, 2026-10-14) — không phải một mục riêng có ngân sách hay chiến dịch.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.10 (bổ sung 2026-10-14); nguồn tiền của khoản (két hay tiền riêng) chưa nói. Lược đồ khoản chi là `P2A-05` (đang chờ duyệt ADR-074).

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình ngân sách và chiến dịch của dự án cũ.

**Theo fe_guidance:** form và mutation chờ xác nhận rồi đọc lại như `P4A-08`; trang này có thể là một bộ lọc của trang khoản chi chứ không phải trang riêng — chọn ở thiết kế.

**Không làm thì mất gì:** một sổ chi thứ hai lệch với khoản chi của mảng tài chính.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4a-11"></a>
### P4A-11 — Bản cũ có trang đào tạo nhân viên, quán này chưa có dữ kiện nào về nó

**Phụ thuộc** · bước admin 11/11 · mức L1 · **bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`

**Trang nguồn:** `/admin/training` — hướng dẫn công việc và theo dõi hoàn thành. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quán **có** hướng dẫn công việc và theo dõi đào tạo trong phần mềm (U-086, 2026-10-14). Hướng dẫn là **chữ, ảnh, video, theo từng việc** (lượt hai); **chủ quán hoặc POS ghi nhận xét về người làm và đánh giá làm được việc hay chưa**, tạo · sửa · xoá được (U-090 đóng, lượt ba). Chưa có lược đồ và cửa backend — cần một lát lược đồ admin mới trước bước này.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.7 (bổ sung 2026-10-14) — dạng hướng dẫn, ai ghi nhận xét, ai đánh giá.

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình bài hướng dẫn và tiến độ của dự án cũ.

**Theo fe_guidance:** không áp được trước khi có phạm vi.

**Không làm thì mất gì:** một trang không ai dùng, hoặc một luật bịa ra rồi thành sự thật.

**Nhận việc:** —

[↑ đầu file](#top)
