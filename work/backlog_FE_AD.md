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

**Mở 2026-10-19 (Claude Code):** `P4A-01` · `P4A-02` · `P4A-03` đủ ba điều — cửa ở hợp đồng 0.40.0, không câu chặn,
`P4-04` Done (kế hoạch §6a). Tám bước còn lại giữ nguyên *bị chặn* tới khi một lượt rà như thế mở chúng.

**`PAGES_INDEX.md` cho danh sách trang, không cho cách làm.** Bản ấy chép dự án khác — đăng nhập JWT, WebSocket, CRUD
tự do — và mọi link của nó đã chết. Cách làm theo **ADR-102** và `docs/private/fe/fe_guidance/`; chỗ trang nguồn trái
dữ kiện quán thì dữ kiện thắng (**ADR-103** điểm 4).

---

<a id="p4a-01"></a>
### P4A-01 — Mười trang admin cần chung một vỏ, và vỏ ấy phải chỉ mở cho chủ quán

**Phụ thuộc** · bước admin 1/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa · `P4-04`~~ — **mở 2026-10-19**: cửa `GET /sessions/current` (T-190), `P4-04` Done

**Trang nguồn:** `/admin` cùng *Admin shell* — thanh tab chung của mọi trang `/admin/*`, chặn theo vai. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** một khung chung cho các trang `P4A-02`…`P4A-11`: thanh điều hướng giữa các trang admin đã mở được, chỉ hiện với người có lớp `chu_quan`; trang chưa có cửa backend không hiện trong thanh. Backend vẫn là người chặn — khung ẩn trang là tiện, không phải bảo vệ (giống `P4-04`).

**Dữ kiện quán đã có:** ma trận vai [`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md) (lớp `chu_quan`); danh tính bằng tài khoản mật khẩu riêng (`master_plan/shop-facts.md` §8.8 sửa 2026-10-14, **ADR-104** — thay chọn tên của `T-143`); mảng quản trị đứng riêng khỏi bán hàng (`master_plan/shop-facts.md` §8 mở đầu).

**Không lấy từ PAGES_INDEX:** `AuthGuard` · `RoleGuard minRole=MANAGER` theo JWT và đoạn *mobile bottom bar* đề xuất — quán này nhận danh tính bằng cookie phiên của tài khoản (**ADR-109**, đã chạy từ `P4-04`; `X-Person-Id` gỡ ở `T-190`); vai `MANAGER` không có trong ma trận vai.

**Theo fe_guidance:** nhóm màn **chủ quán** của ADR-102 điểm 1; ba tầng và chiều import — chủ repo chọn 2026-10-19, owner [`01-khung-fe.md`](../docs/product/4-fe/01-khung-fe.md) §4 — khung admin dùng chung shared component với khung chủ quán của `P4-04`, không dựng bộ thứ hai.

**Không làm thì mất gì:** mỗi trang admin tự dựng điều hướng và tự kiểm vai, và một trang quên kiểm thì nhân viên thấy nút của chủ quán.

**Bẫy:** đừng viết bảng quyền thứ hai cho admin — đọc lớp của cửa từ cùng một chỗ `P4-04` đọc.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4A-01`, nhánh
`codex/P4A-01`) theo lời chủ repo *"yêu cầu codex làm tiếp bạn kiểm tra"*. **Claude chốt** (đọc owner route
`docs/product/4-fe/01-khung-fe.md`): không mở khung `/admin` thứ hai — `khungCua` chỉ biết ba khung, và chủ quán đã có
`/chu-quan`. Trang admin là route con của `/chu-quan`; `/chu-quan` chính là trang **Tổng quan** (`P4A-02`),
`/chu-quan/tong-ket` là **Tổng kết** (`P4A-03`). Thanh điều hướng chỉ của khung chủ quán ⇒ tầng 3 (`01-khung-fe.md` §4).

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/layout.tsx` bọc mọi trang `/chu-quan/*` bằng `KhungTheoVai khung="/chu-quan"` và thanh điều
   hướng; `fe/src/app/chu-quan/page.tsx` thôi tự bọc `KhungTheoVai` (một chỗ gác, không hai).
2. Thanh điều hướng `fe/src/app/chu-quan/_components/` đọc từ **một** danh sách mục (nhãn + route) đặt cạnh nó; hôm nay
   danh sách có đúng một mục *Tổng quan* → `/chu-quan`; mỗi bước sau thêm mục của mình cùng lượt dựng trang. Mục đang mở
   mang `aria-current="page"`; là phần tử `nav` có nhãn truy cập.
3. Không bảng quyền thứ hai: không file nào dưới `fe/src/app/chu-quan/` đọc `is_owner` hay `role_code` — gác chỉ qua
   `KhungTheoVai` / `khungCua` (`grep -rn "is_owner\|role_code" fe/src/app/chu-quan` rỗng).
4. Test Vitest (fetch giả): phiên chủ quán ⇒ thấy thanh, mục *Tổng quan* `aria-current`; phiên vai `quay` ⇒ chuyển
   `/quay`, thanh không hiện; không phiên (401) ⇒ chuyển `/dang-nhap`; mỗi route trong danh sách có `page.tsx` thật dưới
   `fe/src/app/` (test đọc cây file, danh sách thêm mục mà quên trang ⇒ đỏ).
5. Chạy thật cùng backend (Claude): chủ quán đăng nhập ⇒ `/chu-quan` có thanh; người vai `quay` mở `/chu-quan` ⇒ về
   `/quay`. Dán output.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §4 có dòng layout và thanh điều hướng (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-01`, nhánh `codex/P4A-01`, base
`103784b`); duyệt: **Claude Code** — đọc diff thật, thêm chú thích đầu ba file, tự chạy test, chứng minh test có răng, chạy
app thật. Nhánh `P4A-01`. File: `fe/src/app/chu-quan/layout.tsx` · `page.tsx` · `chu-quan.test.tsx` ·
`_components/muc-chu-quan.ts` · `_components/thanh-dieu-huong.tsx`; owner `01-khung-fe.md` §1 · §4.
*Nghiệm thu → bằng chứng:*
1. `layout.tsx` bọc `KhungTheoVai khung="/chu-quan"` + thanh; `page.tsx` thôi tự bọc (diff), `metadata` giữ.
2. `nav aria-label="Trang chủ quán"`, một danh sách, một mục; ca *đường dẫn con không làm Tổng quan sáng*.
3. `grep -rn "is_owner\|role_code" fe/src/app/chu-quan` chỉ trúng hai dòng dữ liệu giả của `chu-quan.test.tsx`; code chạy
   không đọc cờ quyền — Claude đọc dòng ấy theo ý *code chạy không tự quyết quyền*.
4. `chu-quan.test.tsx` năm ca (chủ quán · đường dẫn con · phiên quầy ⇒ `/quay` · 401 ⇒ `/dang-nhap` · mục trỏ route chưa có
   trang). Claude tự bỏ gác khỏi layout ⇒ `Tests 2 failed | 3 passed (5)` (hai ca chặn); trả lại ⇒ `5 passed`. Codex bỏ
   `aria-current` ⇒ `expected null to be 'page'`.
5. Chạy thật (database dùng-xong-bỏ cổng 5499, backend thật, `next dev`, Chrome headless qua CDP gắn cookie phiên):
   chủ quán mở `/chu-quan` ⇒ `nav ["Tổng quan href=/chu-quan aria-current=page"]`, nhãn `Trang chủ quán`; Lan vai `quay`
   mở `/chu-quan` ⇒ về `/quay`, không `nav`; không phiên ⇒ về `/dang-nhap`. Backend vẫn chặn: Lan `GET /owner-overview`
   ⇒ `403 owner_only`, chủ quán ⇒ `200`.
6. `01-khung-fe.md` §1 dòng layout `/chu-quan/*`, §4 dòng `ThanhDieuHuong`.
7. `npm run lint` · `npm run typecheck` sạch; `npx vitest run` ⇒ `Tests 46 passed (46)`; gate — dưới.
Còn lại: không. Bước sau thêm mục của mình vào `muc-chu-quan.ts`.

[↑ đầu file](#top)

---

<a id="p4a-02"></a>
### P4A-02 — Chủ quán không đứng quầy vẫn muốn nhìn một bảng biết quán đang chạy thế nào

**Phụ thuộc** · bước admin 2/11 · mức L2 · ~~**bị chặn bởi:** backend admin chưa có cửa · `P4-04`~~ — **mở 2026-10-19**: cửa `GET /owner-overview` · `PUT /daily-minimums/{sale_date}` (P3A-09 · T-199 · T-197) · **cần xong trước:** `P4A-01`

**Trang nguồn:** `/admin/overview` — *live floor*: thẻ số liệu, đơn đang chạy, bàn, nhật ký đã trả và đã huỷ. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** bày đúng bảy thứ chủ quán đã gọi tên, mỗi thứ đọc từ cửa backend khi cửa ấy có; thứ nào chưa có cửa thì trang nói *chưa có*, không tự tính từ dữ liệu khác.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.6 (bảy thứ, nguyên văn của chủ quán); hàng 6 — số người thực tế do POS khai (`U-060` đã đóng); hàng 7 — ba đường *thiếu*, đường nguyên liệu theo §8.4.

**Không lấy từ PAGES_INDEX:** bố cục và danh sách thẻ của dự án cũ; luồng WebSocket `OrdersWSProvider` — tín hiệu đọc lại đi bằng SSE theo **ADR-097** và **ADR-102**.

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0):** (1) hợp đồng **không** có luồng SSE cho chủ quán và
`OwnerOverview` không trả `poll_interval_seconds` ⇒ theo dòng *Chủ quán* của **ADR-102** điểm 1: đọc khi mở màn, khi quay
lại cửa sổ (`T-202`), khi mạng về, sau mỗi lần ghi; **không** kéo theo chu kỳ, luôn bày `read_at`. Cần bảng tự chạy hơn thế
⇒ `F-XXX` gửi pha 3, không tự đặt chu kỳ. (2) Mục nào backend trả trạng thái thiếu (`daily_minimum_missing`,
`workers_present_missing`) thì trang nói đúng điều ấy, không suy số. (3) Trang có **ô nhập hai số tối thiểu của ngày**
(`PUT /daily-minimums/{sale_date}`; cửa không nhận lý do — backend ghi vết sửa bằng mã cửa `tongquan/dat_toi_thieu`) — chưa bước FE nào khác nhận; ghi xong thì đọc lại tổng quan. (4) Số
người đang làm do POS khai ở màn quầy — **không** thuộc trang này. (5) Ngày bán của trang là `sale_date` backend trả.

**Theo fe_guidance:** mẫu R (tín hiệu đọc lại và đường kéo dự phòng) ở `fe-01-rendering.md` §6; banner mất kết nối và chế độ suy giảm ở `fe-02-loading.md` §4.

**Không làm thì mất gì:** chủ quán nhìn một bảng tự ghép từ nhiều nguồn và tin một con số máy không ai kiểm.

**Bẫy:** *số tiền dự tính* (§8.6 hàng 5) là tạm tính trong buổi — không bao giờ bày cạnh hay giống doanh thu đã đối soát; và frontend không cộng tiền (**ADR-086**).

**Nhận việc** — 2026-10-19 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4A-02`,
nhánh `codex/P4A-02`). **Claude chốt:** trang ở `/chu-quan` (thay chữ giữ chỗ); thành phần riêng màn ⇒ tầng 3 dưới
`fe/src/app/chu-quan/_components/`; giờ hiển thị theo múi giờ quán `Asia/Ho_Chi_Minh` (`master_plan/shop-facts.md` §1)
— không theo múi giờ máy; tiền định dạng `vi-VN` từ số nguyên backend trả, không phép tính; không `refetchInterval`.
Chữ trên màn do Claude đặt trong test — là nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/tong-quan.test.tsx` (Claude viết trước, 9 ca đỏ vì chưa có code) xanh, **không** sửa điều kiện
   kiểm: ngày bán · mốc đọc từ backend dù đồng hồ máy lệch; tiền tạm tính đúng số, nhãn *chưa đối soát*, không chữ
   *doanh thu*; bảy mục; nguyên liệu bày số dư và lời nhắc, `check_reminder: null` ⇒ *Chưa đủ dữ liệu để nhắc* (U-102);
   hai trạng thái thiếu nói đúng lý do, không số; nhập tối thiểu — bấm hai lần một PUT tới `sale_date` backend trả rồi đọc
   lại; điền sẵn số đã nhập; lời từ chối có `field` gắn đúng ô; đọc lại lỗi giữ bản cũ kèm cảnh báo có mốc.
2. `check-fe-rules.sh` xanh (không phép tính trên tên tiền); `grep -rn "refetchInterval" fe/src/app/chu-quan` rỗng.
3. Chỉ báo tải (`fe-02` §1 · §2): lần đọc đầu chữ *Đang đọc tổng quan…*; khi ghi nút tắt và đổi chữ *Đang lưu…*. Primitive
   `skeleton` · `spinner` của shadcn **chưa cài được** — máy không ra mạng 2026-10-19 (`npx shadcn add` ⇒ `ENOTFOUND
   ui.shadcn.com`); không tự viết primitive (**ADR-100** điểm 2), cài sau là một việc riêng.
4. Chạy thật cùng backend (Claude): ngày chưa nhập tối thiểu ⇒ hai lý do thiếu; nhập ⇒ tiến độ và thiếu người hiện số;
   Lan vai `quay` gọi `PUT /daily-minimums` ⇒ `403 owner_only`.
5. `docs/product/4-fe/01-khung-fe.md` §2 dòng màn `/chu-quan` (Claude ghi khi duyệt).
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-02`, nhánh `codex/P4A-02`, base
`d5849f4`); test trước và duyệt: **Claude Code**. Nhánh `P4A-01` (cùng nhánh bước trước). File: `page.tsx` ·
`_components/tong-quan.tsx` · `_components/du-lieu-tong-quan.ts` · `_components/form-toi-thieu.tsx` · `tong-quan.test.tsx`
(Claude) · `chu-quan.test.tsx`; owner `01-khung-fe.md` §2.
*Nghiệm thu → bằng chứng:*
1. `tong-quan.test.tsx` 9/9 xanh; md5 file test trước và sau khi Codex làm trùng nhau (`a0206cf5…`). **Claude sửa test của
   mình một chỗ khi duyệt:** ca *bấm hai lần* dùng `fireEvent.click` hai lần — React render lại giữa hai lần nên nút đã
   tắt, gỡ chốt đồng bộ mà test vẫn xanh (không có răng). Đổi thành hai `requestSubmit()` trong cùng một `act`: gỡ chốt ⇒
   `expected 3 to be 2`, trả lại ⇒ xanh. Hai lỗi cài khác: đổi chữ mục tiền thành *Doanh thu hôm nay* ⇒ ca tiền đỏ; bỏ gác
   layout ⇒ hai ca gác đỏ. **Codex đổi `chu-quan.test.tsx`** một dòng (chữ giữ chỗ ⇒ tiêu đề *Tổng quan*) nhưng để hai ca
   gác vẫn tìm chữ giữ chỗ đã mất ⇒ vế *không hiện nội dung* luôn đúng; Claude đổi hai dòng ấy sang tiêu đề *Tổng quan*.
2. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData|new Date()|Date.now` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. *Đang đọc tổng quan…* lần đầu; nút *Đang lưu…* khi ghi; primitive `skeleton` · `spinner` chưa cài (máy không mạng).
4. Chạy thật (database dùng-xong-bỏ, backend thật, `next dev`, Chrome headless qua CDP): ngày chưa nhập ⇒ *Chưa nhập số tối
   thiểu của ngày* · *POS chưa khai số người đang làm* (cả mục thiếu người), tiền *0 đ · Tiền bán tạm tính, chưa đối soát*;
   chủ quán điền 300 · 4 và bấm lưu trên form ⇒ *Đã lưu số tối thiểu.*, mốc đọc 13:41:09 → 13:41:16, *0 / 300 bánh*; Lan đứng
   quầy khai 3 người (`201`) ⇒ *3 người* · *Thiếu 1 người*; Lan `PUT /daily-minimums` ⇒ `403 owner_only`. Database thử không
   có đơn nên dòng món · phần đã ra rỗng — hình bày của chúng do test giữ.
5. `01-khung-fe.md` §2 dòng màn `/chu-quan`.
6. `npm run lint` · `typecheck` sạch; `npx vitest run` ⇒ `Tests 55 passed (55)`; gate — xem báo cáo cuối phiên.
Còn lại: cài primitive `skeleton` · `spinner` khi máy có mạng (việc riêng).

[↑ đầu file](#top)

---

<a id="p4a-03"></a>
### P4A-03 — Trang tổng kết đòi những con số mà mảng tài chính chưa chốt

**Phụ thuộc** · bước admin 3/11 · mức L2 · ~~**bị chặn bởi:** backend admin chưa có cửa · `P4-04`~~ — **mở 2026-10-19**: cửa `GET /sale-days/{sale_date}/summary` (P3A-10) · **cần xong trước:** `P4A-01`

**Trang nguồn:** `/admin/summary` — báo cáo: KPI doanh thu, món bán chạy, hiệu suất nhân viên, cảnh báo sắp hết hàng. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** trang tổng kết cho chủ quán bày bốn thứ chủ quán gọi tên 2026-10-14 (U-081, *"cho tất cả thông tin"*): **KPI doanh thu · món bán chạy · hiệu suất nhân viên · cảnh báo sắp hết**. Lượt hai cùng ngày: báo cáo **theo ngày bán**; hiệu suất nhân viên là **số đếm, không chấm điểm, không xếp hạng** — ngày công, số đơn ghi lúc đứng quầy, số lần đi giao, số lần huỷ · hoàn tiền người ấy bấm; *cảnh báo sắp hết* là máy nhắc POS kiểm tra. Ngưỡng: còn dưới tỉ lệ chủ quán đặt cho từng thứ, mặc định 20% của lần nhập gần nhất (U-087 đóng, lượt bốn).

**Dữ kiện quán đã có:** bốn thứ ở `master_plan/shop-facts.md` §8.6 (bổ sung 2026-10-14); món bán chạy khớp `E48` §8.10; luật cộng doanh thu từ hai nguồn và hoàn trừ vào ngày hoàn ở `master_plan/shop-facts.md` §6; doanh thu ngày đã đối soát không đổi; mức sâu của mảng tài chính **chưa chốt** (§8.2).

**Không lấy từ PAGES_INDEX:** *hiệu suất nhân viên* và *cảnh báo sắp hết* như những con số máy tự kết luận — §8.4 nói máy không kết luận thiếu nguyên liệu, và chưa có lời nào về chấm điểm người làm.

**Theo fe_guidance:** mẫu P hoặc S của `fe-01-rendering.md` cho màn đọc theo kỳ; mặc định TanStack Query theo loại dữ liệu ở `fe-02-loading.md` §5.

**Không làm thì mất gì:** báo cáo bày một con số theo định nghĩa của dự án khác, và chủ quán quyết theo nó.

**Bẫy:** báo cáo theo ngày phải dùng **ngày bán**, không dùng ngày lịch của trình duyệt (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`).

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0):** (1) ngày mặc định khi mở trang là `sale_date` backend trả
(`GET /owner-overview`), ngày đang xem đi trên URL (`docs/product/4-fe/01-khung-fe.md` §2). (2) `supply_reminders` là kết
quả **hiện tại**, không phải ảnh của ngày đang chọn — trang nói rõ điều ấy khi ngày chọn khác hôm nay. (3) Doanh thu bày
kèm trạng thái đối soát backend trả; `total_vnd` có thể âm. (4) Ba lúc máy chưa biết có nên nhắc kiểm tra một nguyên liệu
là câu đang mở **U-102** — trang bày đúng thứ backend trả, không tự đoán.

**Nhận việc** — 2026-10-19 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4A-03`,
nhánh `codex/P4A-03`, base `f11d80e`). **Claude chốt:** trang ở `/chu-quan/tong-ket`, mục *Tổng kết* thêm vào
`muc-chu-quan.ts`; ngày đang xem là tham số `?ngay=YYYY-MM-DD`, thiếu thì lấy `sale_date` của `GET /owner-overview`,
đổi ngày ⇒ `router.push`; tiền bày nguyên số backend trả kể cả `total_vnd` âm, không tự tính tổng; món, combo và người làm
giữ đúng thứ tự backend, người làm chỉ có số đếm; nhắc kiểm tra luôn ghi *kết quả hiện tại* kèm `read_at`, thêm *không phải
của ngày …* khi ngày xem khác hôm nay của backend; không `refetchInterval`. Chữ trên màn do Claude đặt trong test — là
nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/tong-ket/tong-ket.test.tsx` (Claude viết trước, 12 ca, đỏ vì chưa có trang) và
   `fe/src/app/chu-quan/chu-quan.test.tsx` (Claude sửa: hai mục điều hướng, *Tổng kết* sáng ở route của nó) xanh,
   **không** sửa điều kiện kiểm: ngày mặc định từ backend dù đồng hồ máy lệch; ngày trên URL; đổi ngày đi lên URL; bốn số
   doanh thu đúng như backend (tổng cố ý lệch phép cộng), tổng âm, trạng thái đối soát, sổ giấy còn chờ; món · combo tách
   nhóm giữ thứ tự; ngày rỗng; người làm không điểm không hạng giữ thứ tự; nhắc kiểm tra là kết quả hiện tại có mốc, nói rõ
   khi khác ngày; ngày sai ⇒ báo không hợp lệ; chỉ báo lần đọc đầu.
2. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData|new Date()|Date.now` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` xong (bắt thiếu `Suspense` quanh `useSearchParams`).
4. Chạy thật cùng backend (Claude): mở `/chu-quan/tong-ket` không tham số ⇒ ngày bán của backend; chọn ngày khác ⇒ URL đổi,
   số đổi theo ngày.
5. `docs/product/4-fe/01-khung-fe.md` §2 dòng màn `/chu-quan/tong-ket` (Claude ghi khi duyệt).
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-03`, nhánh `codex/P4A-03`, base
`f11d80e`); test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File: `tong-ket/page.tsx` · `_components/tong-ket.tsx` ·
`_components/muc-chu-quan.ts` · `tong-ket/tong-ket.test.tsx` (Claude) · `chu-quan.test.tsx` (Claude); owner `01-khung-fe.md` §2.
*Nghiệm thu → bằng chứng:*
1. `tong-ket.test.tsx` 12/12 và `chu-quan.test.tsx` 5/5 xanh; md5 hai file trước và sau khi Codex làm trùng nhau
   (`658a3b31…` · `ab018705…`). Lỗi cài: ngày mặc định lấy `new Date()` ⇒ 1 ca đỏ; tự xếp người theo số đơn ⇒ 1 ca đỏ; gỡ ⇒ xanh.
   **Claude sửa khi duyệt** ba chỗ: lỗi đọc tổng quan khi đã có ngày trên URL không còn báo nhầm là lỗi tổng kết; xoá trống
   ô ngày không đẩy `?ngay=` rỗng; ô ngày dùng `Input` · `Label` của shadcn thay thẻ thô (**ADR-100**).
2. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData|new Date()|Date.now` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` ở clone chính xong, có `○ /chu-quan/tong-ket` (trong worktree Turbopack vấp symlink `node_modules`).
4. Chạy thật (database dùng-xong-bỏ, backend thật, `curl` với phiên chủ quán): `/owner-overview` ⇒ `sale_date` 2026-10-19;
   `/sale-days/2026-10-19/summary` và `2026-10-15` ⇒ `200`, bốn mục đúng hình hợp đồng (rỗng vì database thử chưa có đơn),
   `read_at` dạng `+07:00`; `/sale-days/2026-13-40/summary` ⇒ `400 invalid_request` `field: sale_date` — đúng hình ca *ngày
   sai* của test. **Chưa** mở trang trên trình duyệt: phần bày do test giữ.
5. `01-khung-fe.md` §2 dòng màn `/chu-quan/tong-ket`.
6. `npx vitest run` ⇒ `Tests 67 passed (67)`; `fe-check: PASS`; gate xanh ở clone chính.
Còn lại: không.

[↑ đầu file](#top)

---

<a id="p4a-04"></a>
### P4A-04 — Trang sản phẩm của bản cũ cho thêm và xoá món, còn quán này chưa có cửa nào như thế

**Phụ thuộc** · bước admin 4/11 · mức L2 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19**: cửa `POST /menu-items` · `PUT /menu-items/{menu_item_id}` (P3A-07), đọc `GET /menu-categories` (P3A-05) · **cần xong trước:** `P4A-01`

**Trang nguồn:** `/admin/products` — CRUD sản phẩm. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** phần **sửa giá, sửa thành phần suất, ngừng bán** đã thuộc `P4-05` và không lặp ở đây. Bước này giữ phần còn lại — **thêm · xoá · sửa thông tin món** — mà chủ quán đã nói **cần** 2026-10-14 (U-082, lời chọn của chủ repo).

**Dữ kiện quán đã có:** chủ quán cần tự thêm · xoá món (`master_plan/shop-facts.md` §8.9, bổ sung 2026-10-14; *xoá* đọc là ngừng bán · ẩn, không xoá cứng); menu do chủ quán gọi tên (§4.9); *món ngoài bảng giá* là đã quyết định không làm (§6.12); D37 · D38 chưa có danh mục mới, D43 cần ảnh món nhưng chưa chốt quyền sửa ảnh (§8.9).

**Không lấy từ PAGES_INDEX:** nút *thêm món* và *xoá món* trước khi có cửa backend; hai trang không được giữ hai bản sửa giá.

**Theo fe_guidance:** mutation chờ xác nhận rồi đọc lại (`fe-02-loading.md` §3) và khuôn hộp thoại sửa có lý do mà `P4-05` rút ra.

**Không làm thì mất gì:** hai trang cùng sửa menu theo hai khuôn, và trang thứ hai không qua lần duyệt chạm tiền của `P4-05`.

**Bẫy:** không cộng giá để *xem trước* ở trình duyệt — gọi tính thử (`P4-05` Bẫy, **ADR-086**).

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0):** *xoá món* của Goal là **ngừng bán** — cửa ấy
(`POST /menu-items/{menu_item_id}/discontinuation`) cùng sửa giá và thành phần vẫn của `P4-05`, nên trang này chỉ có
**xem · thêm · đổi tên**. `P4-05` chưa làm, nên chưa có *khuôn hộp thoại sửa có lý do* để theo: ô đổi tên kèm lý do ở
đây là khuôn đầu, `P4-05` nên dùng lại thay vì dựng khuôn thứ hai (suy ra, Claude Code). Thêm món tạo thành phần **mới**
cùng giao dịch, không dùng lại thành phần có sẵn (lựa chọn của P3A-07). Món mới chưa có tuỳ chọn phụ thu — hợp đồng
không cho đặt ở cửa này.

**Nhận việc** — 2026-10-19 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4A-04`,
nhánh `codex/P4A-04`, base `1fc57cb`). **Claude chốt:** trang ở `/chu-quan/san-pham`, mục *Sản phẩm* thêm cuối
`muc-chu-quan.ts`; đọc `GET /menu-categories` mặc định (món của danh mục ẩn đã nằm trong `uncategorized_items`), bày từng
danh mục và nhóm *Chưa xếp danh mục* đúng thứ tự backend, món ngừng bán có nhãn; không bày giá, không gọi
`/price-quotes`; form *Thêm món* chọn danh mục bằng `<select>` gốc trong `Field` (shadcn chưa có Select), thành phần
thêm · bỏ được, ít nhất một; đổi tên mở ô tại dòng món, bắt buộc lý do; ghi xong chỉ làm mất hiệu lực rồi đọc lại; lời
từ chối có `field` (kể cả `components[i].x`) gắn đúng ô; `409 menu_category_hidden` · `menu_category_not_found` ⇒ báo và
đọc lại. Chữ trên màn do Claude đặt trong test — là nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/san-pham/san-pham.test.tsx` (Claude viết trước, 16 ca, đỏ vì chưa có trang) và
   `fe/src/app/chu-quan/chu-quan.test.tsx` (Claude sửa: ba mục điều hướng, *Sản phẩm* sáng ở route của nó) xanh,
   **không** sửa điều kiện kiểm: thứ tự backend, món ngừng bán và chưa xếp; không nút xoá · ngừng bán · giá; đọc lỗi;
   chưa có danh mục; thân `POST` đúng hợp đồng, số nguyên; đọc lại sau ghi; thiếu ô thì không gửi; trùng tên; `field`
   lồng; danh mục ẩn; phản hồi lạ không gửi lại; bấm hai lần một lệnh; đổi tên bắt buộc lý do, đúng món, món ngừng bán đổi được.
2. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData|price-quotes` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` xong, có `/chu-quan/san-pham`.
4. Chạy thật cùng backend (Claude): thêm một món, đổi tên nó, đọc lại thấy tên mới; tên trùng ⇒ `409`.
5. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng `/chu-quan/san-pham` (Claude ghi khi duyệt).
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-04`, nhánh `codex/P4A-04`, base
`1fc57cb`); test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File: `san-pham/page.tsx` · `_components/san-pham.tsx` ·
`_components/form-them-mon.tsx` · `_components/form-doi-ten-mon.tsx` · `_components/du-lieu-san-pham.ts` ·
`_components/muc-chu-quan.ts` · `san-pham/san-pham.test.tsx` (Claude) · `chu-quan.test.tsx` (Claude); owner `01-khung-fe.md` §1 · §2.
*Nghiệm thu → bằng chứng:*
1. `san-pham.test.tsx` 16/16 và `chu-quan.test.tsx` 6/6 xanh; md5 hai file trước và sau khi Codex làm trùng nhau
   (`e43e5120…` · `e8c0f39a…`). Test có răng: Claude bỏ bước đọc lại sau ghi ⇒ `3 failed | 13 passed`; trả lại ⇒ xanh.
   **Claude sửa khi duyệt:** thêm chữ cho `menu_component_name_conflict` và `menu_item_not_found` (món không còn ⇒ đọc lại),
   chú thích đầu hai file.
2. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData|price-quotes` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` ở clone chính xong, có `○ /chu-quan/san-pham` (worktree: Vitest không ghi được `.vite-temp` qua symlink
   `node_modules` trong sandbox Codex, nên Codex chạy bằng `--configLoader native`).
4. Chạy thật (database dùng-xong-bỏ, backend thật, `curl` với phiên chủ quán): `POST /menu-categories` `201` ·
   `POST /menu-items` hai thành phần `201` · `PUT /menu-items/1` `200 {"name":"Bánh cuốn chay nấm"}` · `GET /menu-categories`
   thấy tên mới · thêm món trùng tên `409 menu_item_name_conflict` · đổi tên lý do trắng `400 field=reason` · thành phần 2 số
   lượng 0 `400 field=components[1].quantity` — đúng hình các ca của test. **Chưa** mở trang trên trình duyệt: phần bày do test giữ.
5. `01-khung-fe.md` §1 dòng route, §2 dòng màn `/chu-quan/san-pham`.
6. `npx vitest run` ⇒ `Tests 84 passed (84)`; gate xanh ở clone chính.
Còn lại: không. `P4-05` nên dùng lại ô *đổi tên có lý do* làm khuôn sửa có lý do (suy ra, chờ chủ repo).

[↑ đầu file](#top)

---

<a id="p4a-05"></a>
### P4A-05 — Combo, danh mục và topping có trang quản lý ở bản cũ nhưng chưa có danh sách ở quán này

**Phụ thuộc** · bước admin 5/11 · mức L2 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19** cho danh mục (P3A-05) và combo (P3A-06 · P3A-11); **topping vẫn bị chặn** — chưa có cửa thêm tuỳ chọn · **cần xong trước:** `P4A-04`

**Trang nguồn:** `/admin/combos` · `/admin/categories` · `/admin/toppings` — ba trang CRUD. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quản lý combo, danh mục món và tuỳ chọn thêm — chủ quán đã nói **cần cả ba** 2026-10-14 (U-082, `master_plan/shop-facts.md` §8.9). Phụ thu của tuỳ chọn đã đổi được ở `P4-05`; bước này không lặp phần ấy.

**Dữ kiện quán đã có:** quán có combo (`master_plan/shop-facts.md` §8.9 D42) nhưng chưa có danh mục combo mới; nhóm tuỳ chọn và phụ thu §4.4; giá suất là tổng thành phần §4.5 · §4.6.

**Không lấy từ PAGES_INDEX:** khái niệm *topping* như một món có giá riêng — ở quán này tuỳ chọn là **phụ thu theo phần nhận nhân** (§4.6), không phải món cộng thêm; danh mục gồm những nhóm nào chưa có dữ kiện — trang để chủ quán tự đặt, không gieo sẵn nhóm của dự án cũ.

**Theo fe_guidance:** query key theo domain backend ở `fe-03-state-management.md` §2 — ba trang đọc cùng domain menu với `P4-05`, không mở key riêng.

**Không làm thì mất gì:** trang bày giá combo tự cộng, lệch với hàm tính giá duy nhất của backend.

**Bẫy:** giá combo không bao giờ là con số nhập tay ở màn — nó là tổng thành phần (§4.7); muốn thấy thì đọc số backend trả.

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0 và `master_plan/shop-facts.md` §8.9):** *Bẫy* và *Không làm thì
mất gì* ở trên viết trước `U-092` và **đã sai**: `U-092` đóng 2026-10-14 — giá combo **đặt riêng**, không phải tổng thành
phần; `POST /menu-combos` nhận `price_vnd` do chủ quán nhập. Bẫy đúng hôm nay: màn **không tự cộng** giá combo từ giá món,
và chỉ bày `price_vnd` backend trả. Phụ thu trong combo chủ quán đặt **theo từng món của combo** (lượt bảy, §8.9) qua
`PUT /menu-combos/{menu_combo_id}/surcharges` — bước này chỉ **đọc** mức đã đặt: muốn đặt cần danh sách lựa chọn của từng
món, mà nguồn duy nhất là `GET /menu` (chỉ món đang bán) — để bước sau. **Topping:** hợp đồng chỉ có cửa đổi phụ thu một
tuỳ chọn (của `P4-05`), không có cửa thêm tuỳ chọn hay nhóm — phần topping giữ *bị chặn*.

**Nhận việc** — 2026-10-19 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4A-05`,
nhánh `codex/P4A-05`, base `de7ca03`). **Claude chốt:** hai trang `/chu-quan/danh-muc` · `/chu-quan/combo`, mục *Danh mục*
rồi *Combo* thêm cuối `muc-chu-quan.ts`. Danh mục đọc `GET /menu-categories` mặc định, **cùng khoá query** với trang Sản
phẩm (fe-03 §2); thêm · đổi tên · ẩn danh mục; xếp món chưa có danh mục (không ô lý do) hoặc chuyển món (bắt buộc lý do,
đích bỏ danh mục hiện tại); ẩn nói rõ món về *Chưa xếp danh mục*; không nút xoá; không gieo sẵn danh mục. Combo đọc
`GET /menu-combos` mặc định; bày giá `price_vnd`, món kèm số suất, nhãn ngừng bán, mức phụ thu chỉ đọc; lập combo chọn món
còn bán từ `GET /menu-categories`, không chọn trùng món; đổi giá · ẩn bắt buộc lý do; không gọi `/price-quotes` hay
`/menu`; không nút đổi tên, sửa món, đặt phụ thu. Ghi xong chỉ làm mất hiệu lực rồi đọc lại; lời từ chối có `field` (kể
cả `items[i].x`) gắn đúng ô. Chữ trên màn do Claude đặt trong test — là nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/danh-muc/danh-muc.test.tsx` (19 ca, sau duyệt 20) và `fe/src/app/chu-quan/combo/combo.test.tsx` (16 ca) — Claude
   viết trước, đỏ vì chưa có trang — cùng `chu-quan.test.tsx` (Claude sửa: năm mục, *Danh mục* sáng ở route của nó) xanh,
   **không** sửa điều kiện kiểm.
2. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData|price-quotes` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` xong, có `/chu-quan/danh-muc` và `/chu-quan/combo`.
4. Chạy thật cùng backend (Claude): thêm danh mục, xếp một món, lập combo, đổi giá ngoài giờ bán, ẩn combo — đọc lại thấy
   đúng; tên danh mục trùng ⇒ `409`.
5. `docs/product/4-fe/01-khung-fe.md` §1 · §2 hai dòng route mới (Claude ghi khi duyệt).
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-05`, nhánh `codex/P4A-05`, base
`de7ca03`); test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File: `danh-muc/page.tsx` · `combo/page.tsx` ·
`_components/danh-muc.tsx` · `_components/combo.tsx` · `_components/du-lieu-danh-muc-combo.ts` · `_components/form-menu.tsx` ·
`_components/muc-chu-quan.ts` · `danh-muc/danh-muc.test.tsx` (Claude) · `combo/combo.test.tsx` (Claude) · `chu-quan.test.tsx`
(Claude); owner `01-khung-fe.md` §1 · §2.
*Nghiệm thu → bằng chứng:*
1. Codex làm xanh mà không sửa test (md5 trước và sau trùng: `529d2b7d…` · `2579c7d7…` · `fd52f24d…`). Test có răng: Claude
   bỏ bước đọc lại sau ghi ⇒ `8 failed | 27 passed`; trả lại ⇒ xanh. **Claude sửa khi duyệt — lỗi ở phiếu, không ở Codex:**
   chạy thật cho thấy món trong *Chưa xếp danh mục* có thể thuộc danh mục **đã ẩn** — dòng xếp cũ còn, backend coi là chuyển
   và trả `400 field=reason`, mà phản hồi đọc không phân biệt với món chưa từng xếp. Phiếu chốt *không có ô lý do* ⇒ chủ quán
   không xếp lại được món của danh mục vừa ẩn. Sửa: ô *Lý do* luôn có, không bắt buộc khi xếp, để trống thì không gửi; lời đòi
   lý do gắn vào ô; thêm ca test thứ 20. `npx vitest run src/app/chu-quan` ⇒ `Tests 80 passed (80)`.
2. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData|price-quotes` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` ở clone chính xong, có `○ /chu-quan/combo` và `○ /chu-quan/danh-muc` (worktree: Turbopack không theo
   symlink `node_modules`, Codex build bằng `--webpack`).
4. Chạy thật 2026-10-19 16:13, ngoài giờ bán (database dùng-xong-bỏ, backend thật, `curl` với phiên chủ quán): thêm hai danh
   mục `201` · trùng tên `409 menu_category_name_taken` · thêm hai món `201` · chuyển món không lý do `400 field=reason`, có
   lý do `200` · đổi tên danh mục `200` · lập combo giá riêng 17.000 `201` · đổi giá 16.000 `200` · đọc thấy `price_vnd`
   16000 · ẩn combo `200`, đọc lại rỗng · ẩn danh mục `200`, đọc lại thấy món về `uncategorized_items`. **Chưa** mở trang trên
   trình duyệt: phần bày do test giữ.
5. `01-khung-fe.md` §1 hai dòng route, §2 hai dòng màn.
6. Gate xanh ở clone chính (khối dưới).
Còn lại: **đặt mức phụ thu theo món của combo** (cửa có, cần nguồn danh sách lựa chọn của từng món) và **topping** (chưa có
cửa thêm tuỳ chọn) — hai phần chưa làm của bước này.
*2026-10-20:* màn POS giao việc và đào tạo từ quầy xong ở `T-212` (phần còn lại của `P4A-07` · `P4A-11`).
*2026-10-19 (Claude Code):* **topping** xong ở `T-210` (`work/backlog.md`) — cửa thêm · ẩn · bật lại lựa chọn và trang `/chu-quan/topping`. **Đặt mức phụ thu theo món của combo** xong ở `T-211`. Bước này không còn phần nào chưa làm.

[↑ đầu file](#top)

---

<a id="p4a-06"></a>
### P4A-06 — Trang nhân viên của bản cũ quản lý tài khoản theo vai của dự án khác, còn quán này để người làm tự đăng ký và chủ quán duyệt

**Phụ thuộc** · bước admin 6/11 · mức L2 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04` · thiết kế đăng nhập `T-181` (**ADR-104**)~~ — **mở 2026-10-19** (cửa `/accounts*` của T-190, kế hoạch §6a lượt bốn)

**Trang nguồn:** `/admin/staff` — CRUD tài khoản nhân viên: vai, bật · tắt. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** chủ quán quản lý **tài khoản** của người làm — mỗi người một tài khoản, mật khẩu riêng (U-083, 2026-10-14, thay chọn tên). Lượt hai (U-088 đóng): người làm **tự đăng ký**, trang này là chỗ chủ quán **duyệt** và gán vai, khoá tài khoản người nghỉ; mật khẩu người làm tự đặt và tự đặt lại qua Gmail — trang không bày, không đổi mật khẩu của ai.

**Dữ kiện quán đã có:** tài khoản mật khẩu riêng (`master_plan/shop-facts.md` §8.8 sửa 2026-10-14, **ADR-104**; luật cũ chọn tên của `T-143` · `U-075` đã gỡ — backend ở `T-190`, `fe/` ở `P4-04`, theo **ADR-109**); mảng con người ba mức (`master_plan/shop-facts.md` §8.7); mốc đổi người ở quầy (§8.8); bốn vai và năm trạm (§3).

**Không lấy từ PAGES_INDEX:** vai `chef / cashier / staff / manager` — không khớp bốn vai của quán; luồng JWT của dự án cũ — cách đăng nhập là của thiết kế ADR-104; trang đăng ký `/register` cũng không lấy.

**Theo fe_guidance:** đổi người (đăng nhập · đăng xuất) thì xoá sạch dữ liệu của người trước (**ADR-102** điểm 4, vế còn hiệu lực); store *chọn tên* của `fe-03-state-management.md` §4 không lấy — **ADR-109** thay nó bằng cookie phiên.

**Không làm thì mất gì:** chủ quán không có chỗ tạo hay khoá tài khoản, và một người nghỉ việc vẫn vào được máy.

**Bẫy:** ẩn một người không được làm mất vết những gì người ấy đã ghi (không xoá cứng — `docs/product/2-db/01-quy-uoc-du-lieu.md`).

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0 và **ADR-109**):** *Goal* ở trên viết trước thiết kế và nói trang
*không đổi mật khẩu của ai* — **ADR-109** điểm 9 (chủ repo duyệt 2026-10-14) cho chủ quán **khoá rồi mở lại kèm mật khẩu
tạm** khi thư đặt lại không đi, và `POST /accounts/{account_id}/unlock` đòi `temporary_password`. Đọc đúng hôm nay: trang
**không bày** mật khẩu của ai (hợp đồng không trả), chỉ nhận mật khẩu tạm lúc mở lại; người ấy phải đổi ở lần đăng nhập kế.
*Ẩn một người* ở *Bẫy* là **khoá tài khoản** — tài khoản khoá vẫn nằm trong danh sách, không có cửa xoá.

**Nhận việc** — 2026-10-19 · dẫn, test trước và thi công: **Claude Code** (chủ repo giao thẳng, *"hãy đọc kĩ và làm task
trên"*; không phiếu cho Codex), nhánh `P4A-01`, base `72072d5`. **Claude chốt:** trang `/chu-quan/nhan-vien`, mục *Nhân viên*
thêm cuối `muc-chu-quan.ts`. Đọc `GET /accounts` **không lọc** (một khoá query `accounts`), chia bốn nhóm theo `status` theo
thứ tự *Chờ duyệt* · *Đang làm* · *Đã khoá* · *Đã từ chối*, giữ thứ tự backend trong nhóm; mỗi tài khoản bày tên đã khai,
tên đăng nhập, Gmail, vai — không bày mật khẩu. Duyệt: chọn **một trong bốn vai trạm** (nhãn theo `shop-facts.md` §3; không
có `owner` — **ADR-109** điểm 3 *Sửa đổi*) và *người trong quán*: mặc định *tạo người mới từ tên đã khai* (không gửi
`person_id`), hoặc một người của `GET /people` **chưa có tài khoản và không phải chủ quán**. Từ chối và khoá qua một bước
xác nhận; khoá nói rõ mọi phiên của người ấy kết thúc ngay; **không** nút khoá trên tài khoản của chính người đang đăng nhập
(tự khoá thì chỉ lệnh máy chủ mở lại được — suy ra của phiên, backend không chặn). Mở lại đòi mật khẩu tạm ≥ 8 ký tự
(**ADR-109** điểm 5), ô kiểu mật khẩu, xoá sau khi gửi. Không nút xoá, sửa tên, đổi vai, đặt lại mật khẩu. Ghi xong chỉ làm
mất hiệu lực rồi đọc lại (`accounts`, và `people` sau khi duyệt); lời `account_not_*` (trạng thái đã đổi) cũng đọc lại.
Chữ trên màn do Claude đặt trong test — là nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/nhan-vien/nhan-vien.test.tsx` — Claude viết trước, đỏ vì chưa có trang — cùng `chu-quan.test.tsx`
   (sáu mục, *Nhân viên* sáng ở route của nó) xanh.
2. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` xong, có `/chu-quan/nhan-vien`.
4. Chạy thật cùng backend: đăng ký hai tài khoản, duyệt một (tạo người mới), từ chối một, khoá, mở lại kèm mật khẩu tạm —
   đọc lại thấy đúng trạng thái; duyệt lại tài khoản đã duyệt ⇒ `409 account_not_pending`.
5. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới.
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện, test trước và duyệt: **Claude Code**; **chưa review độc lập**. Nhánh `P4A-01`, base
`72072d5`. File: `nhan-vien/page.tsx` · `_components/nhan-vien.tsx` · `_components/du-lieu-nhan-vien.ts` ·
`_components/form-menu.tsx` (thêm hai tham số tuỳ chọn `loi` · `oLoi`, mặc định giữ lời menu) · `_components/muc-chu-quan.ts` ·
`nhan-vien/nhan-vien.test.tsx` · `chu-quan.test.tsx`; owner `01-khung-fe.md` §1 · §2; kế hoạch §6a *lượt bốn*; **F-071**.
*Nghiệm thu → bằng chứng:*
1. Test viết trước, đỏ (`Test Files 2 failed`) vì chưa có trang và mục; sau thi công `npx vitest run src/app/chu-quan` ⇒
   `Tests 101 passed (101)` (`nhan-vien.test.tsx` 20 ca). Test có răng: bỏ lọc người chủ quán ⇒ `2 failed`; bỏ chặn tự khoá ⇒
   `1 failed`; bỏ đọc lại sau ghi ⇒ `6 failed`; trả lại ⇒ `20 passed`.
2. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData` dưới `fe/src/app/chu-quan` (trừ test) rỗng; `tsc --noEmit` ·
   `eslint src/app/chu-quan` sạch.
3. `npm run build` xong, có `○ /chu-quan/nhan-vien`.
4. Chạy thật 2026-10-19 16:48 (database dùng-xong-bỏ, backend thật, `curl` với phiên chủ quán): đăng ký hai tài khoản `201` ·
   danh sách không lọc trả cả ba · duyệt Minh vai `gap_banh` không `person_id` ⇒ `200`, tạo người 2 · duyệt lại ⇒
   `409 account_not_pending` · từ chối Bình `200` · khoá Minh `200` · mở lại mật khẩu 5 ký tự ⇒ `400 password_too_short`
   (không `field` — trang tự gắn ô) · mở lại `tam-12345` ⇒ `200` · đọc lại thấy `hoat_dong` · `tu_choi`. Cùng lượt lộ **F-071**:
   duyệt gắn vào người `is_owner` chưa có tài khoản ⇒ `200`, người lạ đăng nhập thành chủ quán. **Chưa** mở trang trên trình
   duyệt: phần bày do test giữ.
5. `01-khung-fe.md` §1 dòng route, §2 dòng màn.
6. Gate xanh, `fe-check: PASS` (`Tests 142 passed`).
Còn lại: backend chặn gắn người chủ quán (**F-071**, cần task backend riêng).

[↑ đầu file](#top)

---

<a id="p4a-07"></a>
### P4A-07 — Bản cũ có bảng giao việc và danh sách việc, quán này chưa nói gì về giao việc

**Phụ thuộc** · bước admin 7/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19** (cửa `/assigned-tasks*` của P3A-03, kế hoạch §6a lượt năm)

**Trang nguồn:** `/admin/staff/task-board` · `/admin/todo-list` — bảng việc theo người và danh sách việc của cả nhóm. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quán **có** giao việc trong phần mềm (U-084, 2026-10-14). **Chủ quán và POS** tạo · sửa · xoá việc giao và **đánh dấu xong** (U-089 đóng, lượt ba). Trường của một việc do thiết kế chọn — chủ quán giao cho phiên; *xoá* là ẩn có vết. Chưa có lược đồ và cửa backend cho việc giao — cần một lát lược đồ admin mới trước bước này.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.7 (bổ sung 2026-10-14) — có làm, ai giao, ai đánh dấu xong.

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình việc · người nhận · hạn của dự án cũ.

**Theo fe_guidance:** không áp được trước khi có phạm vi.

**Không làm thì mất gì:** một trang không ai dùng, hoặc một luật giao việc bịa ra rồi thành sự thật.

**Sửa 2026-10-19 (Claude Code, đối chiếu hợp đồng 0.40.0):** *Goal* nói chưa có lược đồ và cửa — đã có: lược đồ `P2A-11`
(`docs/product/2-db/16-luoc-do-giao-viec.md`), cửa `/assigned-tasks*` của P3A-03. Thiết kế chọn trường của một việc là
**nội dung và người nhận**; hợp đồng **không có hạn** — trang không bày hạn.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công kể cả test: **Codex** (worktree `../lean_wt/P4A-07`,
nhánh `codex/P4A-07`, base `a921357`), theo lời chủ repo *"hãy yêu cầu codex làm 2 task trên bạn kiểm tra"*. **Claude
chốt:** trang `/chu-quan/giao-viec`, mục *Giao việc* (Claude thêm vào `muc-chu-quan.ts` lúc tích hợp, để hai worktree không
chạm chung file). Đọc `GET /assigned-tasks` không `include_hidden`, giữ thứ tự backend (mới nhất trước); lọc người nhận
tuỳ chọn, gửi `assignee_person_id`, khoá query `["assigned-tasks", lọc]`. Mỗi việc bày nội dung, người nhận, người giao,
lúc giao, *Đã xong* · *Chưa xong* theo `done` backend trả (không tự suy từ `marks`), và người · lúc của lần đánh dấu gần
nhất khi có. Giao việc: nội dung + người nhận chọn từ `GET /people` — **mọi người** backend trả, không lọc. Sửa: nội dung,
người nhận, lý do bắt buộc. Đánh dấu xong · bỏ đánh dấu không ô lý do. *Xoá việc* là ẩn (`/hiding`), lý do bắt buộc, qua
một bước xác nhận nói việc biến khỏi danh sách nhưng vết còn giữ. Không phần hướng dẫn (của `P4A-11`), không hạn, không bày
việc đã ẩn. Ghi xong chỉ làm mất hiệu lực rồi đọc lại; `assigned_task_not_found` · `_hidden` · `_already_done` ·
`_not_done` báo trạng thái đã đổi rồi đọc lại; `person_not_found` gắn ô người nhận. Chữ trên màn là nhãn giao diện,
không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/giao-viec/giao-viec.test.tsx` (Codex viết) phủ: bày danh sách đúng thứ tự và trạng thái; lọc gửi
   `assignee_person_id`; giao việc gửi đúng thân và đọc lại; ô trống chặn ở màn; sửa thiếu lý do không gửi; `person_not_found`
   gắn ô người nhận; đánh dấu xong · bỏ đánh dấu gửi `mark`; `assigned_task_already_done` báo và đọc lại; xoá đòi xác nhận
   và lý do; không có chữ *hạn* hay phần hướng dẫn. Claude thử răng: bỏ bước đọc lại sau ghi ⇒ test đỏ.
2. `npx vitest run src/app/chu-quan` · toàn bộ `fe` xanh; `tsc --noEmit` sạch.
3. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
4. `npm run build` xong, có `/chu-quan/giao-viec`.
5. Chạy thật cùng backend (Claude): giao việc, sửa có lý do, đánh dấu xong, đánh dấu lần hai ⇒ `409 assigned_task_already_done`,
   bỏ đánh dấu, ẩn — đọc lại thấy đúng.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện kể cả test: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-07`, nhánh
`codex/P4A-07`, base `a921357`); duyệt: **Claude Code**. Nhánh `P4A-01`. File: `giao-viec/page.tsx` ·
`giao-viec/giao-viec.test.tsx` · `_components/giao-viec.tsx` · `_components/du-lieu-giao-viec.ts`; Claude thêm lúc tích hợp:
`_components/muc-chu-quan.ts` · `chu-quan.test.tsx` (tám mục, *Giao việc* sáng ở route của nó), owner `01-khung-fe.md` §1 · §2.
Codex tự chọn giữ bộ lọc người nhận trên URL (`?assignee_person_id=`), như `?ngay=` của trang Tổng kết — Claude nhận.
*Nghiệm thu → bằng chứng:*
1. `giao-viec.test.tsx` 21 ca xanh. Test có răng (Claude chạy): bỏ đọc lại sau ghi ⇒ `11 failed | 10 passed`; nút đánh dấu luôn
   gửi `done` ⇒ `1 failed`; trả lại ⇒ `21 passed`.
2. Clone chính: `npx vitest run src/app/chu-quan` ⇒ `Tests 153 passed (153)`; `tsc --noEmit` · `eslint src/app/chu-quan` sạch.
3. `check-fe-rules: PASS` (trong gate); grep `refetchInterval|setQueryData` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
4. `npm run build` ở clone chính có `○ /chu-quan/giao-viec`.
5. Chạy thật 2026-10-19 19:24 (database dùng-xong-bỏ, backend thật, `curl` phiên chủ quán): giao `201` · nội dung trắng
   `400 field=content` · người 999 `404 person_not_found` (không `field` — trang tự gắn ô) · sửa thiếu lý do `400 field=reason`,
   có lý do `200` · đánh dấu xong `201` · lần hai `409 assigned_task_already_done` · bỏ đánh dấu `201` · lọc người nhận `200` ·
   ẩn `200`, đọc lại rỗng. **Chưa** mở trang trên trình duyệt: phần bày do test giữ.
6. `01-khung-fe.md` §1 dòng route, §2 dòng màn.
7. Gate xanh ở clone chính (khối commit dưới).
Còn lại: POS giao việc **từ quầy** — cửa mở cho `quay_hoac_chu_quan` nhưng trang nằm dưới `/chu-quan`; cần một màn quầy, chưa
có bước (kế hoạch §6a lượt năm).

[↑ đầu file](#top)

---

<a id="p4a-08"></a>
### P4A-08 — Chủ quán ghi sổ nguyên liệu bằng tay, và trang này là cuốn sổ ấy

**Phụ thuộc** · bước admin 8/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19** (cửa `/supply-items*` · `/supply-day-entries*` của P3A-02, kế hoạch §6a lượt năm)

**Trang nguồn:** `/admin/ingredients` — danh sách nguyên liệu và các lần nhập · xuất kho. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** xem danh mục nguyên liệu và ghi sổ nhập · dùng ở mức *sổ ghi tay điện tử* — đúng các dòng chủ quán đã chốt, khi backend admin có cửa ghi.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.4 (mức sổ ghi tay, danh mục nguyên liệu, mục nhập tổng hằng ngày); lược đồ `P2A-02` ở `docs/product/2-db/12-luoc-do-nguyen-lieu.md`.

**Không lấy từ PAGES_INDEX:** tồn kho do máy tự tính và cảnh báo hết hàng tự động — §8.4 nói máy không kết luận thiếu.

**Theo fe_guidance:** form theo lựa chọn của ADR-102 điểm 5; mutation chờ xác nhận rồi đọc lại (`fe-02-loading.md` §3).

**Không làm thì mất gì:** chủ quán quay về sổ giấy, và §8.6 hàng 7 (thiếu nguyên liệu) không có nguồn.

**Bẫy:** thứ chưa có đơn vị trong danh mục (§8.4) bày là *chưa có đơn vị*, không tự gán.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công kể cả test: **Codex** (worktree `../lean_wt/P4A-08`,
nhánh `codex/P4A-08`, base `a921357`), theo lời chủ repo *"hãy yêu cầu codex làm 2 task trên bạn kiểm tra"*. **Claude
chốt:** trang `/chu-quan/nguyen-lieu`, mục *Nguyên liệu* (Claude thêm vào `muc-chu-quan.ts` lúc tích hợp). Đọc
`GET /supply-items` (khoá `["supply-items"]`), giữ thứ tự backend; mỗi thứ bày tên và đơn vị mua, hoặc *Chưa có đơn vị*.
**Không** bày `purchased_total` · `used_total` · `balance` · tỉ lệ · lời nhắc — đó là trang Kho (`P4A-09`). Thêm thứ: tên,
đơn vị tuỳ chọn (trống thì không gửi). Đặt đơn vị chỉ hiện ở thứ chưa có đơn vị. Sổ một thứ mở bằng `?thu=<supply_item_id>`
trên URL, đọc `GET /supply-items/{supply_item_id}` (khoá `["supply-items", id]`): từng dòng ngày, *Mua vào* · *Đã dùng*,
con số đúng chuỗi backend trả kèm đơn vị, người ghi — thứ tự backend. Ghi một con số: ngày (bắt buộc, **không** mặc định từ
đồng hồ trình duyệt — ngày của quán do backend xét), loại, con số là **chuỗi** theo khuôn hợp đồng gửi nguyên văn sau khi cắt
khoảng trắng. Sửa con số: con số và lý do bắt buộc; không đổi ngày, loại. Không nút xoá thứ hay dòng. Không `parseFloat`,
`Number(…)` hay phép cộng trừ trên con số ở trình duyệt. Ghi xong chỉ làm mất hiệu lực tiền tố `["supply-items"]` rồi đọc
lại; `supply_item_name_taken` gắn ô tên, `supply_day_entry_already_recorded` nói dùng *Sửa* ở dòng đã có, lời có `field` gắn
đúng ô. Chữ trên màn là nhãn giao diện, không phải luật quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/nguyen-lieu/nguyen-lieu.test.tsx` (Codex viết) phủ: bày danh mục và *Chưa có đơn vị*; không bày số
   thiếu hay lời nhắc dù phản hồi có; thêm thứ không đơn vị không gửi `purchase_unit`; tên trùng gắn ô tên; đặt đơn vị chỉ ở
   thứ chưa có; mở sổ theo `?thu=`; ghi con số gửi đúng chuỗi (ví dụ `"1.250"`), không mặc định ngày; con số sai khuôn chặn
   ở màn; `entry_date` tương lai bị từ chối gắn ô ngày; trùng dòng báo dùng *Sửa*; sửa thiếu lý do không gửi. Claude thử răng:
   bỏ bước đọc lại sau ghi ⇒ test đỏ.
2. `npx vitest run src/app/chu-quan` · toàn bộ `fe` xanh; `tsc --noEmit` sạch.
3. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` dưới `fe/src/app/chu-quan` (trừ test) rỗng; grep
   `parseFloat|Number\(|parseInt` trong file nguyên liệu (trừ test) rỗng.
4. `npm run build` xong, có `/chu-quan/nguyen-lieu`.
5. Chạy thật cùng backend (Claude): thêm thứ có và không đơn vị, trùng tên ⇒ `409`, đặt đơn vị, ghi mua · dùng, trùng dòng ⇒
   `supply_day_entry_already_recorded`, ngày mai ⇒ `400 field=entry_date`, sửa có lý do — đọc lại thấy đúng.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện kể cả test: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-08`, nhánh
`codex/P4A-08`, base `a921357`); duyệt: **Claude Code**. Nhánh `P4A-01`. File: `nguyen-lieu/page.tsx` ·
`nguyen-lieu/nguyen-lieu.test.tsx` · `_components/nguyen-lieu.tsx` · `_components/du-lieu-nguyen-lieu.ts`; Claude thêm lúc
tích hợp: mục *Nguyên liệu* ở `muc-chu-quan.ts`, ca của nó ở `chu-quan.test.tsx`, owner `01-khung-fe.md` §1 · §2.
*Nghiệm thu → bằng chứng:*
1. `nguyen-lieu.test.tsx` 29 ca xanh (có ca số `-4` của `balance` không xuất hiện, `"1.250"` gửi nguyên chuỗi, `?thu=abc`).
   Test có răng (Claude chạy): bỏ đọc lại sau ghi ⇒ `7 failed | 22 passed`; trả lại ⇒ `29 passed`.
2. Clone chính: `npx vitest run src/app/chu-quan` ⇒ `Tests 153 passed (153)`; `tsc --noEmit` · `eslint src/app/chu-quan` sạch.
3. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData` rỗng; grep `parseFloat|parseInt|Number\(` trong file nguyên
   liệu (trừ test) rỗng — mã `?thu=` đổi bằng `+thu`, chỉ là định danh, không phải con số sổ.
4. `npm run build` ở clone chính có `○ /chu-quan/nguyen-lieu`.
5. Chạy thật 2026-10-19 19:24 (cùng lượt với `P4A-07`): thêm *Gạo* có đơn vị `201`, *Hành tây* không đơn vị `201`
   (`purchase_unit: null`) · trùng tên `409 supply_item_name_taken` · đặt đơn vị `200`, lần hai `409 supply_item_unit_already_set` ·
   ghi mua `"10.250"` `201` (backend trả `"10.25"`) · ghi dùng `201` · trùng dòng `409 supply_day_entry_already_recorded` ·
   ngày mai `400 field=entry_date` · sửa thiếu lý do `400 field=reason`, có lý do `200` · đọc sổ thấy hai dòng.
   **Chưa** mở trang trên trình duyệt: phần bày do test giữ.
6. `01-khung-fe.md` §1 dòng route, §2 dòng màn.
7. Gate xanh ở clone chính (khối commit dưới).
Còn lại: không — số thiếu, tỉ lệ nhắc và lời nhắc là của `P4A-09`.

[↑ đầu file](#top)

---

<a id="p4a-09"></a>
### P4A-09 — Trang kho của bản cũ dự báo ngày hết hàng, còn quán này cấm máy kết luận thiếu

**Phụ thuộc** · bước admin 9/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04` · lược đồ tỉ lệ nhắc `T-186`~~ — **mở 2026-10-19** (cửa `GET /supply-stock` · `PUT /supply-items/{supply_item_id}/reminder-ratio`, kế hoạch §6a lượt sáu)

**Trang nguồn:** `/admin/storage` — quản lý kho: cảnh báo sắp hết, nối món với tồn kho, dự báo ngày hết. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** bày ba thứ chủ quán đã chốt cho đường thiếu nguyên liệu — thời gian nhập, tổng đã dùng, số thiếu theo đúng phép trừ của §8.4 — để **chủ quán tự kết luận**.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.4 (`U-045` · `U-051` · `U-054` đã đóng) và §8.6 hàng 7.

**Không lấy từ PAGES_INDEX:** cột *dự kiến hết*, *dùng/ngày*, cảnh báo sắp hết, và việc tự tắt món khi hết nguyên liệu — hết nguyên liệu và tạm dừng nhận đơn là hai việc khác nhau (§8.3).

**Theo fe_guidance:** nhóm màn chủ quán của ADR-102: lỗi đọc giữ bản cũ kèm cảnh báo và mốc (`fe-02-loading.md` §1).

**Không làm thì mất gì:** máy nói *sắp hết* thay chủ quán, trái lời đã chốt.

**Sửa 2026-10-14:** máy **nhắc POS kiểm tra** khi một thứ sắp hết (`master_plan/shop-facts.md` §8.4 *Sửa 2026-10-14*); nhắc khi phần còn lại dưới **tỉ lệ chủ quán đặt cho thứ ấy** (mặc định 20%) của lần nhập gần nhất — U-087 đóng, lượt bốn; trang này là chỗ chủ quán đặt tỉ lệ. Cột *dự kiến hết* và *dùng/ngày* vẫn không lấy.

**Bẫy:** số thiếu là số backend trả, không trừ ở trình duyệt; nhắc sắp hết là việc của backend, không so ngưỡng ở trình duyệt.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công kể cả test: **Codex** (worktree `../lean_wt/P4A-09`,
nhánh `codex/P4A-09`, base `33221a3`), theo lời chủ repo *"hãy yêu cầu codex làm nốt 3 task trên nếu codex hết token bẹn làm nốt"*. **Claude chốt:** trang `/chu-quan/kho`, mục *Kho* (Claude thêm vào
`muc-chu-quan.ts` lúc tích hợp). Đọc `GET /supply-stock` (khoá `["supply-stock"]`), thứ tự backend; mỗi thứ bày tên, đơn vị
hoặc *Chưa có đơn vị*, *Tổng mua vào*, *Tổng đã dùng*, *Mua vào trừ đã dùng* (`balance`, số âm bày nguyên), lần nhập gần
nhất hoặc *Chưa có lần mua*, tỉ lệ nhắc đúng chuỗi backend (không đổi ra phần trăm — đổi là phép tính ở trình duyệt). Cờ nhắc
chỉ đọc `check_reminder` · `reminder_status`: *Nhắc POS kiểm tra* · *Không nhắc* · ba nhãn *Máy chưa tính nhắc: …* cho ba
trạng thái `null` của `U-102` — trang bày, không quyết. Không chữ *sắp hết*, *dự kiến hết*, *dùng/ngày*. Đặt tỉ lệ: chuỗi theo
khuôn hợp đồng, lý do bắt buộc, gửi nguyên chuỗi; ghi xong làm mất hiệu lực `["supply-stock"]` và `["supply-items"]` rồi đọc
lại. Không `parseFloat`, `Number(…)` hay so sánh con số ở trình duyệt; không đọc `/supply-check-reminders` (của màn quầy).

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/kho/kho.test.tsx` (Codex viết) phủ: đúng chuỗi ba con số, `balance` âm, hai nhãn *chưa có*; cờ `true`
   · `false` · ba trạng thái `null`; không có chữ *sắp hết*/*dự kiến*, không có `20%`; đặt tỉ lệ gửi nguyên chuỗi rồi đọc lại;
   tỉ lệ sai khuôn hay thiếu lý do không gửi; `field=reminder_ratio` gắn ô; lỗi đọc giữ bản cũ; bấm hai lần một lời gọi.
   Claude thử răng: bỏ bước đọc lại sau ghi ⇒ test đỏ.
2. `npx vitest run src/app/chu-quan` · toàn bộ `fe` xanh; `tsc --noEmit` sạch.
3. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` rỗng; grep `parseFloat|parseInt|Number\(` trong file kho
   (trừ test) rỗng.
4. `npm run build` xong, có `/chu-quan/kho`.
5. Chạy thật cùng backend (Claude): đọc kho thấy cờ đúng một thứ dưới tỉ lệ; đặt tỉ lệ có lý do ⇒ `200`, sai khuôn ⇒ `400
   field=reminder_ratio` — đọc lại thấy đúng.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-09`, nhánh `codex/P4A-09`, base
`33221a3`) viết trang và test; **Claude Code** làm nốt và duyệt. **Codex hết hạn mức** giữa chừng (*"You've hit your usage limit … try again at Oct 20th, 2026 12:23 AM"*) trước khi viết báo
cáo, nên **không có lời tự khai**; Claude chép code về clone chính, đọc lại từng file và làm nốt theo lời chủ repo. Claude sửa: bỏ `Badge` (repo không có
`components/ui/badge`) thay bằng nhãn `<strong>` nhấn mạnh, ca test tương ứng. Nhánh `P4A-01`. File: `kho/page.tsx` ·
`kho/kho.test.tsx` · `_components/kho.tsx` · `_components/du-lieu-kho.ts`; Claude thêm lúc tích hợp: mục *Kho* ở
`muc-chu-quan.ts`, ca ở `chu-quan.test.tsx`, owner `01-khung-fe.md` §1 · §2.
*Nghiệm thu → bằng chứng:*
1. `kho.test.tsx` 24 ca xanh. Test có răng (Claude chạy): bỏ đọc lại `["supply-stock"]` sau ghi ⇒ `3 failed | 21 passed`; trả lại ⇒ xanh.
2. Clone chính: `npx vitest run` ⇒ `Tests 271 passed (271)`; `tsc --noEmit` · `eslint src/app/chu-quan` sạch.
3. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData` rỗng; grep `parseFloat|parseInt|Number\(` trong file kho rỗng.
4. `npm run build` có `○ /chu-quan/kho`.
5. Chạy thật 2026-10-19 19:53 (database dùng xong bỏ, cùng lượt với `P4A-10` · `P4A-11`): mua `10` dùng `9` ⇒ `/supply-stock`
   trả `balance "1"`, tỉ lệ `"0.2"`, `check_reminder true`; thứ chưa mua ⇒ `no_purchase` · `null`; đặt `"0.05"` có lý do `200`
   rồi đọc lại `check_reminder false`; `"1.5"` ⇒ `400 field=reminder_ratio`; thiếu lý do ⇒ `400 field=reason`; mã `99` ⇒
   `404 supply_item_not_found`. **Chưa** mở trang trên trình duyệt: phần bày do test giữ.
6. `01-khung-fe.md` §1 dòng route, §2 dòng màn.
7. Gate xanh ở clone chính (khối commit dưới).
Còn lại: ba trạng thái `null` chờ `U-102`; trang chỉ bày nhãn.

[↑ đầu file](#top)

---

<a id="p4a-10"></a>
### P4A-10 — Bản cũ có trang chi phí marketing, quán này chưa có dữ kiện nào về nó

**Phụ thuộc** · bước admin 10/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19** (cửa `/expense-categories` · `/expenses*`, kế hoạch §6a lượt sáu)

**Trang nguồn:** `/admin/marketing` — ngân sách, phân bổ, dòng thời gian chiến dịch. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** ghi chi phí marketing như **một khoản chi của mảng tài chính** (U-085, 2026-10-14) — không phải một mục riêng có ngân sách hay chiến dịch.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.10 (bổ sung 2026-10-14); nguồn tiền của khoản (két hay tiền riêng) chưa nói. Lược đồ khoản chi là `P2A-05` (đang chờ duyệt ADR-074).

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình ngân sách và chiến dịch của dự án cũ.

**Theo fe_guidance:** form và mutation chờ xác nhận rồi đọc lại như `P4A-08`; trang này có thể là một bộ lọc của trang khoản chi chứ không phải trang riêng — chọn ở thiết kế.

**Không làm thì mất gì:** một sổ chi thứ hai lệch với khoản chi của mảng tài chính.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công kể cả test: **Codex** (worktree `../lean_wt/P4A-10`,
nhánh `codex/P4A-10`, base `33221a3`), theo lời chủ repo *"hãy yêu cầu codex làm nốt 3 task trên nếu codex hết token bẹn làm nốt"*. **Claude chốt (thiết kế):** **không** trang marketing riêng — chi phí
marketing là một loại chi chủ quán tự thêm với nguồn *Tiền riêng* (§8.10 lượt năm) và ghi như mọi khoản chi. Trang
`/chu-quan/khoan-chi`, mục *Khoản chi* (Claude thêm lúc tích hợp). Loại chi: `GET /expense-categories`, bày tên và nguồn
*Trả từ két* · *Tiền riêng*; thêm loại thì nguồn bắt buộc chọn, không chọn sẵn; không gài sẵn loại nào. Khoản chi: tham số URL
`?tu&den&loai&nguon`; thiếu ngày thì lấy `sale_date` của `GET /owner-overview` như trang tổng kết, không lấy đồng hồ trình
duyệt; không so `from ≤ to` ở trình duyệt. Bày ngày, loại, nguồn, số tiền, người ghi; **tổng là `total_vnd` backend**, không
cộng ở trình duyệt. Ghi: loại, số tiền nguyên đồng ≥ 1, ngày chi bắt buộc không mặc định; sửa: đủ bốn trường, lý do bắt buộc;
`sale_day_reconciled` gắn ô ngày. Không xoá, không ngân sách hay chiến dịch.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx` (Codex viết) phủ: nguồn của loại; thêm loại thiếu nguồn không gửi, đủ
   gửi `paid_from_till:false`; tên trùng gắn ô; ngày mặc định từ owner-overview; bốn tham số lọc gửi đúng, vắng thì không gửi;
   tổng là `total_vnd` (phản hồi có tổng khác tổng các dòng); ngày chi trống không gửi; số tiền 0 không gửi; ghi xong đọc lại;
   `sale_day_reconciled` gắn ô ngày; sửa thiếu lý do không gửi, đủ gửi bốn trường; `field=from` gắn ô; bấm hai lần một lời gọi.
   Claude thử răng: bày tổng bằng phép cộng các dòng ⇒ test đỏ.
2. `npx vitest run src/app/chu-quan` · toàn bộ `fe` xanh; `tsc --noEmit` sạch.
3. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` rỗng; không phép cộng tiền trong file khoản chi (trừ test).
4. `npm run build` xong, có `/chu-quan/khoan-chi`.
5. Chạy thật cùng backend (Claude): thêm loại *Marketing* nguồn tiền riêng `201`, trùng tên `409`; ghi khoản `201`, ngày mai
   ⇒ `400 field=paid_date`; lọc theo loại và nguồn; sửa có lý do `200` — đọc lại thấy đúng tổng.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-10`, nhánh `codex/P4A-10`, base
`33221a3`) viết trang và test; **Claude Code** làm nốt và duyệt. **Codex hết hạn mức** giữa chừng (*"You've hit your usage limit … try again at Oct 20th, 2026 12:23 AM"*) trước khi viết báo
cáo, nên **không có lời tự khai**; Claude chép code về clone chính, đọc lại từng file và làm nốt theo lời chủ repo. Claude sửa: test dùng backend giả chung vốn bỏ
chuỗi tham số khỏi `path` nên 16 ca đỏ — dựng backend giả cục bộ giữ tham số như `giao-viec.test.tsx`; code trang không đổi.
Nhánh `P4A-01`. File: `khoan-chi/page.tsx` · `khoan-chi/khoan-chi.test.tsx` · `_components/khoan-chi.tsx` ·
`_components/du-lieu-khoan-chi.ts`; Claude thêm lúc tích hợp: mục *Khoản chi*, ca ở `chu-quan.test.tsx`, owner `01-khung-fe.md`.
*Nghiệm thu → bằng chứng:*
1. `khoan-chi.test.tsx` 29 ca xanh. Test có răng (Claude chạy): bày tổng bằng `reduce` các dòng ⇒ `8 failed | 21 passed`; trả lại ⇒ xanh.
2. Clone chính: `Tests 271 passed (271)`; `tsc --noEmit` · `eslint` sạch.
3. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData` rỗng; grep `reduce\(|\+= ` trong file khoản chi rỗng.
4. `npm run build` có `○ /chu-quan/khoan-chi`.
5. Chạy thật 2026-10-19 19:53: *Marketing* tiền riêng `201`, *Điện* từ két `201`, trùng tên `409 expense_category_name_taken`,
   thiếu nguồn `400 field=paid_from_till`; ghi `200000` · `350000` `201`, ngày mai `400 field=paid_date`; đọc ngày ⇒
   `total_vnd 550000`; lọc loại 1 · tiền riêng ⇒ `200000`; `from > to` ⇒ `400 field=to`; sửa thiếu lý do `400`, có lý do `200`
   ⇒ `600000`. **Chưa** mở trang trên trình duyệt.
6. `01-khung-fe.md` §1 · §2.
7. Gate xanh ở clone chính.
Còn lại: không — loại chi không đổi tên hay nguồn được vì hợp đồng không có cửa.

[↑ đầu file](#top)

---

<a id="p4a-11"></a>
### P4A-11 — Bản cũ có trang đào tạo nhân viên, quán này chưa có dữ kiện nào về nó

**Phụ thuộc** · bước admin 11/11 · mức L1 · ~~**bị chặn bởi:** backend admin chưa có cửa (**ADR-068**) · `P4-04`~~ — **mở 2026-10-19** (cửa `/training-records*` · `/assigned-tasks/{assigned_task_id}/guides` · `/assigned-task-guides*`, kế hoạch §6a lượt sáu)

**Trang nguồn:** `/admin/training` — hướng dẫn công việc và theo dõi hoàn thành. Tên route ấy là **tên nguồn** trong `PAGES_INDEX.md`, không phải route đã chốt — owner route
ra đời ở `P4-02` (**ADR-035**).

**Goal:** quán **có** hướng dẫn công việc và theo dõi đào tạo trong phần mềm (U-086, 2026-10-14). Hướng dẫn là **chữ, ảnh, video, theo từng việc** (lượt hai); **chủ quán hoặc POS ghi nhận xét về người làm và đánh giá làm được việc hay chưa**, tạo · sửa · xoá được (U-090 đóng, lượt ba). Chưa có lược đồ và cửa backend — cần một lát lược đồ admin mới trước bước này.

**Dữ kiện quán đã có:** `master_plan/shop-facts.md` §8.7 (bổ sung 2026-10-14) — dạng hướng dẫn, ai ghi nhận xét, ai đánh giá.

**Không lấy từ PAGES_INDEX:** toàn bộ mô hình bài hướng dẫn và tiến độ của dự án cũ.

**Theo fe_guidance:** không áp được trước khi có phạm vi.

**Không làm thì mất gì:** một trang không ai dùng, hoặc một luật bịa ra rồi thành sự thật.

**Nhận việc** — 2026-10-19 · dẫn và duyệt: **Claude Code**; thi công kể cả test: **Codex** (worktree `../lean_wt/P4A-11`,
nhánh `codex/P4A-11`, base `33221a3`), theo lời chủ repo *"hãy yêu cầu codex làm nốt 3 task trên nếu codex hết token bẹn làm nốt"*. **Claude chốt:** trang `/chu-quan/dao-tao`, mục *Đào tạo* (Claude thêm lúc
tích hợp), hai phần. *Ghi nhận đào tạo:* `GET /training-records` lọc `?nguoi=` · `?an=1`; bày người, nhận xét, đánh giá
*Làm được* · *Chưa làm được* · *Chưa đánh giá*, người ghi, lúc ghi; thêm cần ít nhất nhận xét hoặc đánh giá, trường trống thì
không gửi khoá; sửa gửi **cả hai** trường (vắng nghĩa là không còn) cùng lý do; ẩn có lý do; dòng đã ẩn không có nút. *Hướng
dẫn theo việc:* chọn việc từ `GET /assigned-tasks` bằng `?viec=`; bày chữ, ảnh (`<img>`), video (`<video controls>`) với
nguồn tệp `/api/assigned-task-guides/<id>/file`; gắn bằng `multipart/form-data` — chữ không phần tệp, ảnh/video không phần
chữ, không tự đặt `Content-Type`, không tự kiểm cỡ tệp (`file_too_large` báo cỡ theo hợp đồng); sửa chỉ mẩu chữ, có lý do; ẩn
có lý do. Màn quầy cho POS làm cùng việc ấy **chưa có bước** — trang này chỉ cho chủ quán.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `fe/src/app/chu-quan/dao-tao/dao-tao.test.tsx` (Codex viết) phủ: ba nhãn đánh giá; lọc `?nguoi` · `?an`; dòng ẩn không
   nút; thêm không gửi khoá trống, cả hai trống không gửi; sửa gửi đủ hai trường kể cả `null` và lý do; ẩn thiếu lý do không
   gửi; `?viec=` đọc đúng đường, `?viec=abc` báo không tìm thấy; ảnh/video đúng `src`; FormData của chữ và ảnh đúng phần;
   `413` báo đúng lời; ảnh không nút sửa; ghi xong đọc lại; bấm hai lần một lời gọi. Claude thử răng: bỏ bước đọc lại ⇒ đỏ.
2. `npx vitest run src/app/chu-quan` · toàn bộ `fe` xanh; `tsc --noEmit` sạch.
3. `check-fe-rules.sh` xanh; grep `refetchInterval|setQueryData` rỗng.
4. `npm run build` xong, có `/chu-quan/dao-tao`.
5. Chạy thật cùng backend (Claude): ghi nhận chỉ nhận xét, chỉ đánh giá `201`, cả hai trống `400 field=remark`; sửa · ẩn có
   lý do; gắn chữ và một ảnh PNG `201`, tải `/file` ra ảnh; sửa chữ có lý do; ẩn — đọc lại thấy đúng.
6. `docs/product/4-fe/01-khung-fe.md` §1 · §2 dòng route mới (Claude ghi khi duyệt).
7. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4A-11`, nhánh `codex/P4A-11`, base
`33221a3`) viết trang, **chưa** viết test; **Claude Code** viết test, làm nốt và duyệt. **Codex hết hạn mức** giữa chừng (*"You've hit your usage limit … try again at Oct 20th, 2026 12:23 AM"*) trước khi viết báo
cáo, nên **không có lời tự khai**; Claude chép code về clone chính, đọc lại từng file và làm nốt theo lời chủ repo. Claude sửa: `form.watch` ⇒
`useWatch` (eslint `react-hooks/incompatible-library`). Test ghi phần multipart qua `FormData.prototype.set` vì Node treo khi
đọc lại `File` của jsdom bằng `req.formData()` — giới hạn môi trường test; lời gọi thật mang `multipart/form-data; boundary=…`.
Nhánh `P4A-01`. File: `dao-tao/page.tsx` · `dao-tao/dao-tao.test.tsx` · `_components/dao-tao.tsx` · `_components/dao-tao-form.tsx`
· `_components/du-lieu-dao-tao.ts`; Claude thêm lúc tích hợp: mục *Đào tạo*, ca ở `chu-quan.test.tsx`, owner `01-khung-fe.md`.
*Nghiệm thu → bằng chứng:*
1. `dao-tao.test.tsx` 21 ca xanh. Test có răng (Claude chạy): bỏ đọc lại sau ghi ⇒ `3 failed | 18 passed`; trả lại ⇒ xanh.
2. Clone chính: `Tests 271 passed (271)`; `tsc --noEmit` · `eslint` sạch.
3. `check-fe-rules: PASS`; grep `refetchInterval|setQueryData` rỗng.
4. `npm run build` có `○ /chu-quan/dao-tao`.
5. Chạy thật 2026-10-19 19:53: ghi nhận chỉ nhận xét `201`, chỉ đánh giá `201`, cả hai vắng `400 field=remark`; sửa thiếu lý do
   `400`, có lý do `200`; ẩn `200` — đọc thường còn một dòng, `include_hidden=true` thấy dòng ẩn *bởi Chủ quán*. Gắn chữ `201`,
   ảnh PNG `201`, ảnh kèm chữ `400 field=body`; `/file` trả `200 image/png`, trùng từng byte tệp gửi; sửa chữ có lý do `200`,
   sửa mẩu ảnh `409 assigned_task_guide_not_text`; ẩn ảnh `200`. **Chưa** mở trang trên trình duyệt.
6. `01-khung-fe.md` §1 · §2.
7. Gate xanh ở clone chính.
Còn lại: màn quầy cho POS ghi đào tạo và gắn hướng dẫn **chưa có bước**; nút tới hướng dẫn từ trang giao việc chưa có.

[↑ đầu file](#top)
