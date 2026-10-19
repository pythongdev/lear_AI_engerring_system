<a id="top"></a>
# Sổ mô tả — backend admin (`P3A-01`…`P3A-11`)

Thứ tự, mức và cổng: [`master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md).
Trạng thái: `work/backlog.md`. Mỗi entry giữ mô tả dài; *Nhận việc* điền khi bước được nhận. Viết 2026-10-14 (T-191,
Claude Code) — **ADR-110**.

**Chung cho mọi bước.** Danh tính là phiên cookie của `T-190`; mọi bước cần `T-190` đã đưa về. Khuôn domain như
`be/internal/nguoi` (handler · service · repository · `sql/<cửa>/` · sqlc). Claude viết test trước, Codex thi công,
Claude chạy `be-check` · `db-check` (sandbox Codex không tới Docker). Lớp của cửa đọc từ mệnh đề `I-0xx`; mệnh đề
không nói ⇒ `chu_quan` và một câu hỏi (kế hoạch §3).

---

<a id="p3a-01"></a>
### P3A-01 — Chủ quán ghi tiền điện vào máy rồi không có cửa nào nhận nó

**Goal:** ghi, sửa có lý do và đọc khoản chi theo khoảng ngày, theo loại, theo nguồn; thêm loại chi kèm nguồn. Trang
`P4A-10` là một bộ lọc *loại = marketing* của cùng cửa đọc.
**Đứng trên:** lát `P2A-05` (`docs/product/2-db/15-luoc-do-khoan-chi.md`), `I-029`.
**Bẫy:** nguồn tiền ở **loại**, không trên khoản; loại đã có không đổi nguồn được (database từ chối) — cửa không mở
đường ấy. Ai được ghi: **chỉ chủ quán** (lời đóng `U-095`, 2026-10-15, T-192) ⇒ lớp `chu_quan`, cả ghi lẫn sửa.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-01`, nhánh
`codex/P3A-01` từ `4b25d7f`. Mức L2 — chạm két (`I-021`).

*Thiết kế (Claude, không phải lời quán):* năm đường `GET`/`POST /expense-categories`, `POST /expenses`,
`PUT /expenses/{expense_id}`, `GET /expenses?from&to[&expense_category_id][&paid_from_till]`; ba cửa
`khoanchi/them_loai` · `ghi` · `sua`, mọi đường lớp `chu_quan` kể cả đọc; loại mới bắt buộc khai nguồn, không đường
đổi nguồn hay tên; ngày khai sau hôm nay của quán bị từ chối; khoản của loại trả từ két vào ngày **đã đối soát** bị
từ chối `sale_day_reconciled`, kể cả khi sửa dời ngày hay đổi loại — cùng luật với các cửa tiền khác (`ngayban.DaKy`).
*Phát hiện khi thiết kế:* câu đọc két `be/internal/ket/sql/ket_ngay.sql` chưa trừ khoản chi từ két mà bộ đối chiếu
`db/reconcile/prelude.sql` đã trừ (lát `P2A-05`) — chưa sai vì chưa cửa nào ghi khoản chi; bước này thêm hạng tử.

*Acceptance:*
- [x] Bảy test viết trước ở `be/internal/khoanchi/khoanchi_test.go` xanh qua PostgreSQL thật, file không đổi.
- [x] Người đứng quầy bị `owner_only`, không phiên bị `unauthenticated` ở cả năm đường; database không đổi.
- [x] Mỗi khoản đọc ra loại · số tiền · ngày khai · người ghi · lúc ghi; tổng của khoảng là backend cộng.
- [x] Sửa không lý do bị từ chối; có lý do thì vết giữ bản trước, bản sau, lý do, người sửa.
- [x] Khoản từ két trừ vào két của ngày khai — cửa đọc két và bộ đối chiếu cùng con số; tiền riêng không chạm két.
- [x] Hợp đồng 0.25.0, ba mã lỗi mới, bảy dòng `expense*` của `x-constraint-errors` đã xét, ba dòng ma trận.
- [x] `./scripts/gate.sh` xanh ở clone chính, `be-check` do Claude chạy (`db-check` không chạy: lát không chạm database).

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/khoanchi`, hạng tử chi từ két ở `ket_ngay.sql`,
hợp đồng 0.25.0, ba mã lỗi, bảy dòng `expense*`, ba dòng ma trận, thêm `TestQC14_HinhKhoanChiTruocQuyen` ở
`handler_test.go`) · **Claude Code** (thiết kế, bảy test viết trước; khi duyệt: sửa khung test của chính mình — mở
khoảng trực chồng khoảng vừa khép, database từ chối `counter_duty_one_at_a_time_excl`; thêm ca `khoanchi/sua` vào
`be/internal/don/vet_cua_test.go` vì `TestI018_TapCuaSuaKhopTapCa` đòi; sinh lại `fe/src/lib/api/schema.ts`; ADR-111) ·
duyệt: **Claude Code**, chưa review độc lập · nhánh `fe_admin`, worktree từ `4b25d7f`, áp vào clone chính trên `52d88d3`.

*Nghiệm thu → bằng chứng* (worktree và clone chính, 2026-10-15): `--- PASS` cả bảy `TestI029_*` · `TestI021_KhoanChi*`;
`19 cửa UPDATE khớp 19 ca`; `be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`; `PASS Gate 1g — hợp đồng
0.25.0; 71 đường gọi ở hợp đồng, 71 ở code; … 66 cửa, 66 dòng ma trận`; `fe-check: apigen PASS — schema.ts khớp hợp
đồng`; `PASS gate không cổng nào đỏ`.

*Còn lại:* `fe-check` chạy riêng đỏ 5 test ở `fe/src/components/tai-khoan/` (`ResizeObserver is not defined`) — file của
`P4-04` chưa commit, không do bước này. Trang `P4A-10` có cửa.

[↑ đầu file](#top)

---

<a id="p3a-02"></a>
### P3A-02 — Sổ nguyên liệu có chỗ cất mà không có cửa ghi

**Goal:** thêm thứ vào danh mục, đặt đơn vị cho thứ chưa có; ghi hai con số *mua vào · đã dùng* của một ngày; sửa có
lý do; đọc tổng và hiệu số của một thứ theo phép của `I-026`.
**Đứng trên:** lát `P2A-02` (`docs/product/2-db/12-luoc-do-nguyen-lieu.md`), `I-025` · `I-026`.
**Bẫy:** máy chép con số người ghi, không tự suy lượng dùng từ món bán (§8.4); thứ chưa có đơn vị đọc ra *trống*.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-02`, nhánh
`codex/P3A-02` từ `52d88d3` cộng thay đổi chưa commit của `P3A-01` (đặt sẵn ở index). Mức L2.

*Thiết kế (Claude, không phải lời quán):* sáu đường `GET`/`POST /supply-items`, `PUT /supply-items/{id}/purchase-unit`,
`GET /supply-items/{id}`, `POST /supply-day-entries`, `PUT /supply-day-entries/{id}`; bốn cửa `nguyenlieu/them_thu` ·
`dat_don_vi` · `ghi_so` · `sua_so`, mọi đường lớp `chu_quan` (kế hoạch §4 đọc từ §8.4 *chủ quán tự nhập số liệu*);
con số trên dây là **chuỗi thập phân** (tối đa 9 chữ số nguyên, 3 chữ số lẻ, không âm), đọc ra không số 0 thừa — không
qua số thực; tổng và hiệu số từ **một** câu SQL cho cả hai đường đọc (`I-026` tầng 3); đơn vị **đặt một lần** cho thứ
chưa có, đã có thì từ chối (đổi đơn vị làm hỏng vế hiệu số của `I-026`); sửa chỉ đổi con số, không đổi thứ · ngày · loại.

*Acceptance:*
- [x] Sáu test viết trước ở `be/internal/nguyenlieu/nguyenlieu_test.go` xanh qua PostgreSQL thật, file không đổi.
- [x] Người đứng quầy bị `owner_only`, không phiên bị `unauthenticated` ở cả sáu đường; database không đổi.
- [x] Mỗi con số đọc ra người nhập · ngày · lúc gõ; thứ chưa có đơn vị đọc ra `null`.
- [x] Tổng đã nhập · đã dùng · hiệu số đúng phép của `I-026` (15/13/2 → sửa → 15/15/0; vượt ⇒ âm, nhận); danh sách và
      chi tiết cùng đáp số; số lẻ cộng đúng.
- [x] Một thứ · một ngày · một loại có một con số; trùng tên bị từ chối; sửa có lý do để vết bản trước, bản sau.
- [x] Hợp đồng tăng MINOR, năm mã lỗi mới, mười dòng `supply_*` đã xét, bốn dòng ma trận; ca vết `nguyenlieu/*` sửa.
- [x] `./scripts/gate.sh` xanh ở clone chính; `be-check` · `db-check` do Claude chạy.

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/nguyenlieu`, hợp đồng 0.26.0, năm mã lỗi, mười dòng
`supply_*` — tám `unreviewed` được xét, hai khoá chính giữ `internal` —, bốn dòng ma trận, hai ca vết
`nguyenlieu/dat_don_vi` · `sua_so` ở `be/internal/don/vet_cua_test.go`, con trỏ §3 · §5 ở `12-luoc-do-nguyen-lieu.md`,
thêm `TestI025_HinhSaiTruocQuyenVaDatabase`) · **Claude Code** (thiết kế, sáu test viết trước, sinh lại
`fe/src/lib/api/schema.ts`, ADR-112) · duyệt: **Claude Code**, chưa review độc lập · worktree `../lean_wt/P3A-02` từ
`52d88d3` cộng P3A-01 đặt sẵn ở index; xanh lượt đầu, không gửi lại lỗi nào.

*Nghiệm thu → bằng chứng* (2026-10-15): `--- PASS` cả sáu `TestI025_*` · `TestI026_*` của file viết trước;
`21 cửa UPDATE khớp 21 ca`; `be-check: PASS`; `PASS Gate 1g — hợp đồng 0.26.0; 77 đường gọi ở hợp đồng, 77 ở code; …
70 cửa, 70 dòng ma trận`; `db-check — 28 bước xuôi · lùi · xuôi lại … 140 lỗi cài`; `fe-check: apigen PASS`, `Tests 40
passed (40)`; `PASS gate không cổng nào đỏ`.

*Còn lại:* trang `P4A-08` có cửa; `P3A-08` (nhắc POS) còn chờ `T-186`.

[↑ đầu file](#top)

---

<a id="p3a-03"></a>
### P3A-03 — Việc giao có chỗ cất mà không ai tạo được

**Goal:** tạo · sửa · ẩn việc, đánh dấu xong và bỏ đánh dấu, đọc việc theo người nhận.
**Đứng trên:** lát `P2A-11` (`docs/product/2-db/16-luoc-do-giao-viec.md`), `I-030` — lớp `quay_hoac_chu_quan`.
**Bẫy:** mỗi lần đánh dấu là một dòng sự kiện, không đè cờ; người nhận tự đánh dấu — lời không nói, không mở.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-03`, nhánh
`codex/P3A-03` từ `92c16a7` cộng thay đổi chưa commit của `P3A-01` · `P3A-02` (đặt sẵn ở index). Mức L2.

*Thiết kế (Claude, không phải lời quán):* sáu đường `POST`/`GET /assigned-tasks` (lọc `assignee_person_id`,
`include_hidden`), `GET`/`PUT /assigned-tasks/{assigned_task_id}`, `POST /assigned-tasks/{assigned_task_id}/hiding`,
`POST /assigned-tasks/{assigned_task_id}/marks`; bốn cửa `giaoviec/tao` · `sua` · `an` · `danh_dau`, mọi đường lớp
`quay_hoac_chu_quan` kể cả đọc — đọc là điều kiện để đánh dấu, lời không cho ai khác đọc; người nhận không đứng quầy
không tự đánh dấu. Sửa và ẩn đòi lý do (vết `I-018`); việc đã ẩn không sửa, không đánh dấu, không ẩn lần nữa
(`assigned_task_hidden`). Đánh dấu thừa bị từ chối — *xong* khi đang xong (`assigned_task_already_done`), *bỏ* khi chưa
xong (`assigned_task_not_done`) — để mỗi sự kiện là một lần đổi thật; khoá dòng việc trước khi đọc sự kiện mới nhất.
Người nhận không có ⇒ `person_not_found`. Danh sách mới nhất trước; sự kiện theo thứ tự bấm.

*Acceptance:*
- [x] Sáu test viết trước ở `be/internal/giaoviec/giaoviec_test.go` xanh qua PostgreSQL thật, file không đổi.
- [x] Người không đứng quầy, không là chủ quán — kể cả người nhận — bị `not_on_counter_duty`, không phiên bị
      `unauthenticated` ở cả sáu đường; database không đổi.
- [x] Mỗi việc đọc ra nội dung · người nhận · ai tạo · lúc tạo; *đã xong* đọc từ sự kiện mới nhất; xong → bỏ còn hai
      sự kiện có người và lúc.
- [x] Sửa và ẩn không lý do bị từ chối; có lý do thì vết giữ bản trước, bản sau, lý do, người; việc đã ẩn đọc lại được.
- [x] Hợp đồng tăng MINOR, năm mã lỗi mới, các dòng `assigned_task*` của `x-constraint-errors` đã xét, bốn dòng ma trận;
      ca vết `giaoviec/sua` · `giaoviec/an` ở `be/internal/don/vet_cua_test.go`.
- [x] `./scripts/gate.sh` xanh ở clone chính; `be-check` do Claude chạy.

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/giaoviec`, hợp đồng 0.27.0, năm mã lỗi, chín dòng
`assigned_task*` — hai mang mã công khai, bảy `internal` —, bốn dòng ma trận, hai ca vết `giaoviec/sua` · `giaoviec/an` ở
`be/internal/don/vet_cua_test.go`, con trỏ §3 ở `16-luoc-do-giao-viec.md`, `TestQC14_HinhGiaoViecTruocQuyenVaDatabase`) ·
**Claude Code** (thiết kế, sáu test viết trước, xếp lại import theo khuôn package bên cạnh, sinh lại
`fe/src/lib/api/schema.ts`, ADR-113) · duyệt: **Claude Code**, chưa review độc lập · worktree `../lean_wt/P3A-03` từ
`92c16a7` cộng P3A-01 · P3A-02 đặt sẵn ở index; xanh lượt đầu, không gửi lại lỗi nào.

*Nghiệm thu → bằng chứng* (clone chính, 2026-10-15): `--- PASS` cả sáu `TestI030_*` của file viết trước;
`23 cửa UPDATE khớp 23 ca`; `be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`; `PASS Gate 1g — hợp đồng
0.27.0; 83 đường gọi ở hợp đồng, 83 ở code; 91 mã lỗi … 74 cửa, 74 dòng ma trận`; `db-check — 28 bước xuôi · lùi · xuôi
lại`; `PASS gate không cổng nào đỏ`.

*Còn lại:* trang `P4A-07` có cửa; `P3A-04` (hướng dẫn gắn việc) dùng `assigned_task_not_found` · `assigned_task_hidden` ·
`person_not_found` của bước này.

[↑ đầu file](#top)

---

<a id="p3a-04"></a>
### P3A-04 — Hướng dẫn và ghi nhận đào tạo chưa có cửa

**Goal:** hướng dẫn gắn một việc giao (chữ, tệp ảnh · video), ghi nhận *đạt · chưa* kèm nhận xét về một người.
**Đứng trên:** lát `P2A-12` (`docs/product/2-db/17-luoc-do-dao-tao.md`), `I-031` — lớp `quay_hoac_chu_quan`.
**Bẫy:** tệp không vào database; chỗ giữ tệp theo quyết định của lát `P2A-12`.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-04`, nhánh
`codex/P3A-04` từ `92c16a7` cộng thay đổi chưa commit của `P3A-01` … `P3A-03` (đặt sẵn ở index). Mức L2. Codex hết hạn
mức hai lần trước khi sửa dòng nào (10:28, 11:19); chạy lại 14:29 tiếp phiên cũ.

*Thiết kế (Claude, không phải lời quán — **ADR-114**):* chín đường — `GET`/`POST /assigned-tasks/{assigned_task_id}/guides`
(gắn bằng `multipart/form-data`: `kind`, `body`, `file`), `PUT /assigned-task-guides/{id}`, `POST …/hiding`,
`GET …/file`; `GET`/`POST /training-records`, `PUT /training-records/{id}`, `POST …/hiding`; sáu cửa `daotao/*`, mọi đường lớp
`quay_hoac_chu_quan` kể cả đọc và tải tệp. Kho tệp là thư mục `BANHCUON_FILE_DIR` trên máy chạy hệ thống (ADR-107); khoá tệp
`guides/<hex ngẫu nhiên>.<đuôi>`; loại tệp nhận bằng nội dung — ảnh jpg · png · webp ≤ 10 MiB, video mp4 · webm · mov
≤ 100 MiB; lời từ chối không để tệp mồ côi; ẩn không xoá tệp; tệp mất ⇒ `assigned_task_guide_file_missing`, chữ vẫn đọc.
Chỉ mẩu chữ sửa được — đổi ảnh là ẩn rồi gắn mẩu mới. Ghi nhận về một người, nhận xét và/hoặc *đạt · chưa*, đọc theo lúc
ghi; sửa thay cả hai trường. Sửa và ẩn đòi lý do; mẩu và ghi nhận đã ẩn đứng yên, vẫn đọc lại được.

*Acceptance:*
- [x] Tám test viết trước ở `be/internal/daotao/daotao_test.go` xanh qua PostgreSQL thật, file không đổi.
- [x] Người không đứng quầy, không là chủ quán bị `not_on_counter_duty`, không phiên bị `unauthenticated` ở cả chín
      đường; database và kho tệp không đổi.
- [x] Hướng dẫn đọc lại được từ đúng việc của nó; ảnh · video là tệp trong kho, database chỉ cất khoá; tải lại đúng byte
      và đúng loại; tệp sai loại, quá cỡ, hay bị từ chối trong giao dịch không để lại tệp.
- [x] Ghi nhận đọc ra về ai · ai ghi · lúc ghi, theo thứ tự ghi; rỗng cả hai hay đánh giá thứ ba bị từ chối; sửa và ẩn
      có vết; đã ẩn đọc lại được.
- [x] Hợp đồng tăng MINOR, bảy mã lỗi mới, các dòng `assigned_task_guide_*` · `training_record_*` đã xét, sáu dòng ma
      trận, bốn ca vết; biến `BANHCUON_FILE_DIR` ghi ở `docs/command/make.md` và hợp đồng.
- [x] `./scripts/gate.sh` xanh ở clone chính; `be-check` do Claude chạy.

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/daotao` — handler, service, repository, SQL và mã
sinh sqlc; `TestQC14_HinhDaoTaoTruocQuyenVaDatabase` ở `handler_test.go`; hợp đồng 0.28.0, bảy mã lỗi, các dòng
`assigned_task_guide_*` · `training_record_*` của `x-constraint-errors`, sáu dòng ma trận; bốn ca vết ở
`be/internal/don/vet_cua_test.go`; `BANHCUON_FILE_DIR` ở `be/cmd/server/main.go` · `router.go`; con trỏ ở
`17-luoc-do-dao-tao.md` §3) · **Claude Code** (thiết kế, tám test viết trước; khi duyệt: chuyển ghi chú biến kho tệp vào
đúng đoạn cấu hình ở `01-hop-dong-api.md` và `docs/command/make.md`; xoá dòng trống cắt đôi bảng ma trận ở
`02-vai-va-quyen.md` §3 — lỗi có từ bước trước; sinh lại `fe/src/lib/api/schema.ts` vì sandbox Codex thiếu
`openapi-typescript`) · duyệt: **Claude Code**, chưa review độc lập · worktree từ `92c16a7`, áp vào clone chính trên
`7da137b`.

*Nghiệm thu → bằng chứng* (worktree, 2026-10-15, Docker bật): `--- PASS` cả tám `TestI031_*` và
`TestQC14_HinhDaoTaoTruocQuyenVaDatabase`; `--- PASS: TestI018_MoiCuaSuaCoVet/daotao/sua_huong_dan` · `an_huong_dan` ·
`sua_ghi_nhan` · `an_ghi_nhan`; `be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`; `git diff --exit-code`
trên `daotao_test.go` thoát 0; Gate 1g `hợp đồng 0.28.0; 92 đường gọi ở hợp đồng, 92 ở code; … 80 cửa, 80 dòng ma
trận`. Gate ở clone chính: xem khối commit.

*Còn lại:* tệp tải lên được kiểm hình và ghi vào kho **trước** khi xét quyền (đúng thiết kế ADR-114 — lời từ chối hình
trước quyền); người chưa đăng nhập làm máy ghi tạm tối đa ~100 MiB rồi xoá, không tệp mồ côi. Chưa giới hạn số lần —
xét lại khi mở pha vận hành. Trang `P4A-11` có cửa.

[↑ đầu file](#top)

---

<a id="p3a-05"></a>
### P3A-05 — Chủ quán muốn tự đặt danh mục món

**Goal:** thêm · đổi tên · ẩn danh mục, xếp món vào danh mục, đọc menu theo danh mục.
**Đứng trên:** lát `P2A-13` (`docs/product/2-db/18-luoc-do-danh-muc-combo.md`), `I-032` — lớp `chu_quan`.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-05`, nhánh
`codex/P3A-05` từ `7da137b` cộng thay đổi chưa commit của `P3A-04` (đặt sẵn ở index). Mức L1; Claude viết test trước dù
L1 không bắt buộc.

*Thiết kế (Claude, không phải lời quán — **ADR-115**):* năm đường — `GET`/`POST /menu-categories`,
`PUT /menu-categories/{menu_category_id}`, `POST …/hiding`, `PUT /menu-items/{menu_item_id}/category`; bốn cửa
`danhmuc/them` · `doi_ten` · `an` · `xep_mon`, mọi đường lớp `chu_quan` kể cả đọc. Đọc trả mọi món của bảng món, mỗi món
đúng một chỗ: trong danh mục của nó hoặc ở `uncategorized_items`. Ẩn được danh mục còn món; chuyển món đòi lý do, xếp lần
đầu không; không đường bỏ xếp. `GET /menu` (hàm giá) không đổi.

*Acceptance:*
- [x] Tám test viết trước ở `be/internal/danhmuc/danhmuc_test.go` xanh qua PostgreSQL thật; điều kiện kiểm không đổi.
- [x] Người đứng quầy bị `owner_only`, không phiên bị `unauthenticated` ở cả năm đường; database không đổi.
- [x] Mỗi món đọc ra đúng một chỗ; danh mục đã ẩn đưa món về nhóm chưa xếp, đọc kèm ẩn trả lại.
- [x] Tên danh mục còn dùng không trùng; đổi tên, ẩn và chuyển món có vết mang lý do.
- [x] Không file nào dưới `be/internal/gia/`, `be/internal/menu/`, `db/` đổi.
- [x] Hợp đồng 0.29.0, bốn mã lỗi mới, chín dòng `menu_category_*` · `menu_item_category_*` đã xét, bốn dòng ma trận,
      ba ca vết.
- [x] `./scripts/gate.sh` xanh ở clone chính; `be-check` do Claude chạy.

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/danhmuc` — handler, service, repository, SQL và mã
sinh sqlc, câu đọc một lệnh SQL; `TestQC14_HinhDanhMucTruocQuyenVaDatabase`; hợp đồng 0.29.0, bốn mã lỗi, ánh xạ tên
từ chối, bốn dòng ma trận; ba ca vết ở `be/internal/don/vet_cua_test.go`) · **Claude Code** (thiết kế, tám test viết
trước, ADR-115; khi duyệt: be-check lần đầu đỏ năm test của `gia` và `don` vì món test không thành phần lọt vào
`GET /menu` — sửa test của chính mình cho món test ngừng bán khi xong, và ca vết `danhmuc/xep_mon` dựng món đã ngừng
bán; sinh lại `fe/src/lib/api/schema.ts`) · duyệt: **Claude Code**, chưa review độc lập · worktree từ `7da137b`, áp vào
clone chính cùng nền.

*Nghiệm thu → bằng chứng* (worktree, 2026-10-15): `--- PASS` cả tám `TestI032_*` và
`TestQC14_HinhDanhMucTruocQuyenVaDatabase`; `--- PASS: TestI018_MoiCuaSuaCoVet/danhmuc/doi_ten` · `an` · `xep_mon`;
`be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`; Gate 1g `hợp đồng 0.29.0; 97 đường gọi ở hợp đồng, 97
ở code; … 84 cửa, 84 dòng ma trận`; `git diff HEAD -- be/internal/gia be/internal/menu db` rỗng. Gate ở clone chính: xem
khối commit.

*Còn lại:* `GET /menu` trả 500 khi có một món đang bán không có thành phần — bước `P3A-07` (thêm món) phải giữ điều ấy.
Khách và quầy có thấy menu chia theo danh mục không là câu cho chủ repo, chưa mở `U-XXX` (ADR-115). Trang `P4A-05` có
cửa phần danh mục; combo là `P3A-06`.

[↑ đầu file](#top)

---

<a id="p3a-06"></a>
### P3A-06 — Combo có giá riêng nhưng hàm giá chưa biết combo

**Goal:** chủ quán lập combo (tên, giá riêng, các món kèm số phần), đổi giá ngoài giờ bán, ẩn và đọc combo — cửa cho trang
`P4A-05`. **Bán** combo (hàm giá, dòng đơn, bếp) là `P3A-11`.
**Đứng trên:** lát `P2A-13` (`docs/product/2-db/18-luoc-do-danh-muc-combo.md`), `I-032` — lớp `chu_quan`; lời quán ở
`master_plan/shop-facts.md` §8.9 (đóng `U-092`, T-188, lượt bảy 2026-10-15).
**Bẫy:** giá combo **không** là tổng giá món (`I-032`, U-092); đổi giá trong giờ bán là câu `I-032/6`.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · Codex thi công ở `../lean_wt/P3A-06`, nhánh
`codex/P3A-06` từ `7304895`. Mức L2 — giá do chủ quán đặt. Chủ repo chọn tách phần bán sang `P3A-11` (2026-10-15).

*Thiết kế (Claude, không phải lời quán — **ADR-116**):* bốn đường — `GET`/`POST /menu-combos`,
`PUT /menu-combos/{menu_combo_id}/price`, `POST /menu-combos/{menu_combo_id}/hiding`; ba cửa `combo/them` · `doi_gia` · `an`,
mọi đường lớp `chu_quan` kể cả đọc. Lập một lần đủ món (có thật, chưa ngừng bán, mỗi món một lần, số phần nguyên dương);
không cửa đổi tên hay thành phần. Đổi giá đòi lý do và bị từ chối trong giờ bán, hai đầu tính là trong giờ; phép *trong giờ
bán* dời về `be/internal/ngayban`, cửa nhận đơn dùng lại. Combo đã ẩn đứng yên, đọc kèm ẩn vẫn trả. `GET /menu`, `gia.Tinh`
không đổi.

*Acceptance:*
- [x] Bảy test viết trước ở `be/internal/combo/combo_test.go` xanh qua PostgreSQL thật, điều kiện kiểm không đổi.
- [x] Người đứng quầy bị `owner_only`, không phiên bị `unauthenticated` ở cả bốn đường; database không đổi.
- [x] Combo đọc lại tên, giá đã đặt, người lập, món theo thứ tự gửi kèm số phần; món trong combo không mang giá.
- [x] Đổi giá: thiếu lý do bị từ chối; trong giờ bán (cả hai đầu) bị `menu_combo_price_in_sales_hours`; ngoài giờ có vết
      giá cũ, giá mới, lý do, người sửa.
- [x] Giờ bán chỉ còn một chỗ trong `be/` (`ngayban`); test `I-008` của `don` vẫn xanh.
- [x] Không file nào dưới `be/internal/gia/`, `be/internal/menu/`, `db/` đổi.
- [x] Hợp đồng tăng MINOR, ba mã lỗi mới, mười dòng `menu_combo*` của `x-constraint-errors` đã xét, ba dòng ma trận, hai
      ca vết.
- [x] `./scripts/gate.sh` xanh ở clone chính; `be-check` do Claude chạy.

**Bàn giao** — 2026-10-15 · thực hiện: **Codex** (package `be/internal/combo` — handler, service, repository, SQL và mã
sinh sqlc, câu đọc một lệnh SQL; `TestQC14_HinhComboTruocQuyenVaDatabase`; phép giờ bán dời về
`be/internal/ngayban/sql/ngoai_gio.sql`, `don` gọi `ngayban.NgoaiGio`; hợp đồng 0.30.0, ba mã lỗi, mười dòng `menu_combo*`
đã xét, ba dòng ma trận; hai ca vết ở `be/internal/don/vet_cua_test.go`) · **Claude Code** (thiết kế, bảy test viết trước,
ADR-116; khi duyệt: gofmt chính test của mình — chỉ khoảng trắng, điều kiện kiểm không đổi; sinh lại
`fe/src/lib/api/schema.ts`) · duyệt: **Claude Code**, chưa review độc lập · worktree từ `7304895`, áp vào clone chính.

*Nghiệm thu → bằng chứng* (clone chính, 2026-10-15): `--- PASS` cả bảy `TestI032_*Combo*` (`ChiChuQuanQuanLyCombo`,
`ComboMotGiaRiengDocLaiDuoc`, `LapComboSaiBiTuChoi`, `DoiGiaComboCoLyDoDeVet`, `KhongDoiGiaComboTrongGioBan`,
`AnComboChuKhongXoa`, `ComboSaiHinhBiTuChoi`) và `TestQC14_HinhComboTruocQuyenVaDatabase`;
`--- PASS: TestI018_MoiCuaSuaCoVet/combo/doi_gia` · `combo/an`; mười sáu `TestI008_*` của `don` xanh, kể cả
`TestI008_GioBanHaiDauTinhLaTrongGio`; `grep -rn "06:00\|11:00" be --include='*.sql'` chỉ ra
`be/internal/ngayban/sql/ngoai_gio.sql`; `git diff HEAD -- be/internal/gia be/internal/menu db` rỗng; `be-check: PASS`;
Gate 1g `hợp đồng 0.30.0; 101 đường gọi ở hợp đồng, 101 ở code; … 87 cửa, 87 dòng ma trận`.

*Còn lại:* combo lập được mà **chưa bán được** — `P3A-11` (`U-096` đóng 2026-10-15). Trang `P4A-05` đủ cửa cho phần combo.

[↑ đầu file](#top)

---

<a id="p3a-11"></a>
### P3A-11 — Combo đã lập mà chưa bán được

**Goal:** bán một combo ở mọi kênh: giá = giá combo + phụ thu chủ quán đặt theo **từng món** của combo cho lựa chọn khách
chọn ở món ấy (`master_plan/shop-facts.md` §8.9, lượt bảy); khách chọn nhân riêng từng món.
**Đứng trên:** `P3A-06`; `docs/product/3-be/03-ham-gia.md`; **ADR-108** điểm 7 · **ADR-116** điểm 6.
**Bẫy:** `order_line` bắt buộc đúng một món — dòng đơn mang combo cần migration; bếp nhận việc theo thành phần của dòng đơn
(lát `P2-07`); hoá đơn, nhập bù, đối chiếu `I-009` · `I-013` đọc dòng đơn. Chỗ cất phụ thu theo món của combo chưa có.
**Bị chặn bởi:** ~~`U-096`~~ — đóng 2026-10-15 (lượt tám: cộng 0đ). Mức L3: Claude viết ADR, chủ repo duyệt trước mọi
code, rồi tách lát L1/L2.
**Nhận việc:** 2026-10-15 · Claude Code (thiết kế, test trước, duyệt) · thiết kế **ADR-117**, mệnh đề `I-034`, lời lượt tám ở
`master_plan/shop-facts.md` §8.9. Chủ repo duyệt ADR-117 2026-10-15, giao Codex từng lát (Claude làm nốt nếu Codex hết hạn mức).

*Bốn lát (ADR-117 điểm 8) — mỗi lát một phiếu Codex trong worktree riêng `../lean_wt/<mã>`, Claude viết test đỏ trước,
chạy `db-check` · `be-check`, đọc diff thật rồi mới chấm Done:*

- **`T-193` — lược đồ (L2).** Migration mới: `menu_combo_item_option_surcharge`; `order_line` thêm `menu_combo_id`,
  `parent_order_line_id`, `menu_item_id` và `component_count` thành nullable với ràng buộc hai tầng của ADR-117 điểm 3; file
  ý định `docs/product/2-db/20-luoc-do-ban-combo.md`. *Acceptance:* test `db/tests/i034_*` xanh qua `db-check` — dòng combo
  thiếu dòng con, dòng con trỏ sang đơn khác, dòng mang cả món lẫn combo, dòng combo có thành phần, mức âm đều bị từ chối;
  test cũ `i004` · `i009` · `i013` · `i019` · `i020` xanh không sửa; Gate 1e xanh; down-migration dựng lại được.
  *Bàn giao T-193 (2026-10-15):* thực hiện **Claude Code** — phiếu đã giao Codex ở `../lean_wt/T-193` nhưng Codex hết hạn
  mức trước khi sửa dòng nào; duyệt: chưa ai duyệt độc lập. File: migration `20261015120000_ban_combo` (xuôi, lùi có khoá
  chặn), `db/tests/i034_combo_on_order.sql` (viết trước, đỏ vì thiếu bảng, nay xanh), `db/reconcile/i034.sql` bảy tập
  kèm `db/reconcile/proof/i034_1…7.sql`, ngày mẫu thêm một đơn tới lấy mang combo, `i013.sql` · `i009.sql` (I-009/2) bỏ
  qua dòng combo và dòng con, test `i032` cho `order_line` trỏ tới combo, `20-luoc-do-ban-combo.md`, bước 29 ở `07`,
  dòng `I-034` ở `09`, sqlc sinh lại và `be/internal/don/repository.go` bọc hai cột nullable, hợp đồng 0.30.1 (mười lăm
  dòng `x-constraint-errors`, mười ba `unreviewed` chờ T-194 · T-196). Bằng chứng: `db-check: PASS — 29 bước xuôi · lùi
  · xuôi lại … 145 câu … 147 lỗi cài`; `be-check: PASS`; `./scripts/gate.sh` xanh. Lệch so với phiếu: thêm `I-034/7`
  (giá dòng combo = giá combo tại mốc) và `I-034/5` so mức **tại mốc** chứ không chỉ mức đã chụp.
  *Bàn giao T-194…T-196 (2026-10-15):* thực hiện **Claude Code** (Codex hết hạn mức tới 19:29, chủ repo dặn Claude làm
  nốt); duyệt độc lập: chưa. Test viết trước từng lát rồi mới code: `be/internal/combo/muc_test.go` (4 test),
  `be/internal/gia/combo_test.go` (4), `be/internal/don/combo_test.go` (3), ca vết `combo/dat_muc` trong
  `be/internal/don/vet_cua_test.go`. Code: cửa `combo/dat_muc`; `gia.Tinh` tách `tinhMon` và thêm `tinhCombo`, đọc
  combo tại mốc (`be/internal/gia/sql/doc_combo.sql`), `GET /menu` thêm `combos`; `don` ghi dòng qua `ghiDong` cho cả
  cửa tạo lượt gọi và nhập bù, `kiemHinhDong` nhận dòng combo, `cungDong` so suất. Hợp đồng 0.32.0 (đường đặt mức,
  `PriceLineRequest` · `PriceLine` mang combo, `Menu.combos`, ba mã lỗi mới), `fe/src/lib/api/schema.ts` sinh lại và
  `tsc` sạch; `03-ham-gia.md` §1.1; ma trận thêm `combo/dat_muc`. Bằng chứng: mười một `--- PASS: TestI034_*`,
  `be-check: PASS`, `./scripts/gate.sh` xanh. **Còn lại ngoài P3A-11:** màn FE gọi combo và trang chủ quán đặt mức
  (`P4A-05` và màn gọi món pha 4); báo cáo món bán chạy (`P3A-10`) phải đếm suất con theo món và dòng combo riêng.
- **`T-194` — cửa đặt mức (L2).** ADR-117 điểm 6. *Acceptance:* chỉ chủ quán; thiếu lý do, lựa chọn không thuộc nhóm của
  món, combo đã ẩn, trong giờ bán (cả hai đầu) bị từ chối; ngoài giờ có vết mức cũ, mức mới, lý do, người; `GET
  /menu-combos` trả mức; hợp đồng tăng MINOR.
- **`T-195` — hàm giá (L2).** ADR-117 điểm 4 · 5 (tính thử, menu). *Acceptance:* combo hai suất trứng — một *Nhiều nhân* có
  mức, một *Thường* ⇒ giá combo + một mức; cả hai ⇒ hai mức; lựa chọn chưa đặt mức ⇒ 0đ; ba mã từ chối mới đúng thứ tự;
  *Chay + Nhiều nhân* trong một suất bị `option_combination_invalid`; đọc tại mốc dùng giá và mức trước lần sửa; ca §4.8 cũ
  xanh không đổi; `03-ham-gia.md` cập nhật.
- **`T-196` — ghi đơn (L2).** ADR-117 điểm 2 · 5 · 7. *Acceptance:* năm kênh ghi combo bằng cùng con số tính thử; giá gửi
  kèm bị bỏ; tổng hoá đơn = giá combo + mức đã chụp; bếp nhận đúng số việc theo suất con, nhân của từng suất giữ riêng;
  đọc đơn lồng suất dưới combo; nhập bù combo dùng giá ngày bán; đổi giá combo sau khi đặt ⇒ đơn cũ đứng nguyên.

[↑ đầu file](#top)

---

<a id="p3a-07"></a>
### P3A-07 — Chủ quán muốn tự thêm món

**Goal:** thêm món mới, sửa thông tin món (tên, danh mục); *xoá* là ngừng bán đã có ở pha 3. Sửa giá và thành phần đã
có cửa — không mở cửa thứ hai.
**Đứng trên:** lát menu `P2-05` (`docs/product/2-db/03-luoc-do-menu-gia.md`), §8.9.
**Bẫy:** cột món mới cần mà lược đồ chưa có ⇒ dừng, mở task lược đồ.
**Nhận việc:** 2026-10-15 · Claude Code (phiếu, duyệt) · Codex thi công ở `../lean_wt/P3A-07-09`, nhánh `codex/P3A-07-09` từ `3bdc76f`; Codex viết cả test trước (chủ repo dặn giao hết vì Claude sắp hết hạn mức — lệch ADR-054 vế *Claude viết test*). be-check · db-check chưa chạy.

*Bàn giao (2026-10-16):* thực hiện Codex (nhánh `codex/P3A-07-09`), duyệt Claude Code. Cửa `menu/them_mon` (tạo món, xếp danh mục qua `danhmuc.XepMonMoiTrongGiaoDich`, tạo thành phần mới cùng giao dịch — không dùng lại thành phần đã có, lựa chọn thiết kế của Codex Claude chấp nhận) và `menu/doi_ten`; hai mã lỗi `menu_item_name_conflict` · `menu_component_name_conflict`. Claude thêm ca vết `menu/doi_ten` (món đã ngừng bán, để không làm `GET /menu` trả 500). Bằng chứng: `TestQC14_HinhThemDoiTenMon`, `TestI018_MoiCuaSuaCoVet/menu/doi_ten` PASS; be-check · gate xanh. Còn lại: trang `P4A-04`.

[↑ đầu file](#top)

---

<a id="p3a-08"></a>
### P3A-08 — Kho phải nhắc POS mà không kết luận thiếu

**Goal:** đọc thời gian nhập, tổng đã dùng, số thiếu theo phép §8.4, và cờ *nhắc kiểm tra* khi phần còn lại dưới tỉ lệ
chủ quán đặt.
**Bị chặn bởi:** `T-186` (cột tỉ lệ nhắc).
**Nhận việc:** 2026-10-15 · Claude Code (phiếu, duyệt) · Codex thi công ở `../lean_wt/P3A-07-09`, nhánh `codex/P3A-07-09` từ `3bdc76f`; Codex viết cả test trước (chủ repo dặn giao hết vì Claude sắp hết hạn mức — lệch ADR-054 vế *Claude viết test*). be-check · db-check chưa chạy.

*Bàn giao (2026-10-16):* thực hiện Codex (ba lượt: hai lần dừng vì scope thiếu file vết và file sqlc sinh, một lần hết hạn mức), duyệt Claude Code. Gộp `T-186`: migration `20261015130000_ti_le_nhac_nguyen_lieu`, test `db/tests/i025_reminder_ratio.sql`, đối chiếu `i025` cập nhật. Claude: thêm dòng `_ratio` vào QC-04 (chủ repo chọn cách 1, 2026-10-16), chuyển kịch bản chạy tay `i025_reminder_migration.test.sh` ra khỏi repo (không gate nào gọi; db-check đã chấm xuôi · lùi). Bằng chứng: `TestI025_KhoTongVaBienNhacKiemTra` (15 · 14 · 1, biên 0.999/1/1.001), `TestI025_KhoChiChuQuanVaTiLeTheoTungThu`; `db-check: PASS — 30 bước xuôi · lùi · xuôi lại … 149 lỗi cài`; be-check · gate xanh. Chưa chứng minh test db đỏ trước migration trên database. Câu hỏi Codex ghi ở `01-hop-dong-api.md`: chưa có lần nhập hay lần nhập bằng 0 ⇒ trạng thái riêng, cờ `null`.

[↑ đầu file](#top)

---

<a id="p3a-09"></a>
### P3A-09 — Chủ quán không đứng quầy vẫn muốn một bảng

**Goal:** một cửa đọc gom bảy thứ của §8.6 cho lớp `chu_quan`; thứ nào đã có cửa đọc thì dùng lại truy vấn của nó.
**Bẫy:** *số tiền dự tính* là tạm tính, không bày như doanh thu đã đối soát.
**Nhận việc:** 2026-10-15 · Claude Code (phiếu, duyệt) · Codex thi công ở `../lean_wt/P3A-07-09`, nhánh `codex/P3A-07-09` từ `3bdc76f`; Codex viết cả test trước (chủ repo dặn giao hết vì Claude sắp hết hạn mức — lệch ADR-054 vế *Claude viết test*). be-check · db-check chưa chạy.

*Bàn giao (2026-10-16):* thực hiện Codex, duyệt Claude Code. `be/internal/tongquan` chỉ đọc, dùng lại `sanxuat.DocGom` và `nguyenlieu`; tạm tính không nằm cạnh doanh thu đã đối soát (hiện *chưa có*). Mục chưa đủ lời trả `{status: unavailable, reason}`, không trả 0: U-097 khách · U-098 tiến độ · U-099 tạm tính · U-100 phạm vi đếm phần (bản đầu chỉ bàn đang mở) · U-101 thiếu người/món; số người đang làm chờ `T-197`. Ngày bán tính giống `ngayban.quyNgay` nhưng chép truy vấn — nên gom về một hàm xuất khẩu. Bằng chứng: test `tongquan` PASS qua be-check; gate xanh.

[↑ đầu file](#top)

---

<a id="t-199"></a>
### T-199 — Mục tổng quan đủ số theo lời 2026-10-16

**Goal:** năm mục `GET /owner-overview` đang trả *chưa có* (P3A-09) trả số theo lời chủ quán 2026-10-16
(`master_plan/shop-facts.md` §8.6, khối *Năm vế còn hở*). Mở 2026-10-16 · Claude Code (T-198).

**Thiết kế:** `docs/decisions.md` **ADR-118** (2026-10-18). Lời ba vế thi công: §8.6 *Ba vế thi công*.

**Acceptance:**
- Lát lược đồ `daily_minimum` (ADR-118 điểm 1): migration xuôi · lùi, file `docs/product/2-db/21-luoc-do-so-toi-thieu.md`,
  test database cho khoá duy nhất theo ngày, hai số dương, sửa có vết.
- `PUT /daily-minimums/{sale_date}` chỉ `chu_quan`; hợp đồng tăng phiên bản; một hàng ma trận quyền; test 403 cho lớp khác.
- `GET /owner-overview`: `serving_guests` (điểm 2); đã ra · còn thiếu tách `in_store` · `online` (điểm 3); `sales_progress`
  (điểm 4); `provisional_sales` (điểm 5, có ca combo đã ra hết và ca combo ra dở); `shortages.menu_items` (điểm 6);
  `shortages.workers` *chưa có* `workers_present_missing` (điểm 7); ngày chưa nhập tối thiểu ⇒ `daily_minimum_missing`.
- `./scripts/gate.sh` xanh; Claude tự chạy be-check · db-check trong worktree hoặc clone chính.

**Nhận việc:** 2026-10-18 · Claude Code (thiết kế, phiếu, duyệt) · Codex thi công ở `../lean_wt/T-199`, nhánh `codex/T-199`.
Codex viết cả test (lệch ADR-054 vế *Claude viết test trước*, như P3A-09 — chủ repo giao *"codex cập nhật, bạn kiểm tra"*).

*Bàn giao (2026-10-19):* thực hiện Codex (nhánh `codex/T-199` từ `0f9be2d`), duyệt Claude Code — vòng 1 (phiên 2026-10-18) bắt đếm trùng bánh theo việc trạm, hai test đỏ, tên test sai mệnh đề; phiên ấy dừng giữa vòng sửa, phiên 2026-10-19 nhận duyệt tiếp. Đã kiểm: đếm theo đơn vị `(order_line_component_id, position)`, đơn vị ra khi mọi trạm `served` (`TestQC14_ComboNgayHuyVaThieuMon`: một trạm ⇒ chưa tính, hai trạm ⇒ đúng một); tạm tính bỏ combo ra dở, đơn huỷ, ngày khác; ngày chưa nhập không lấy số trước; cửa ghi 401 · 403 cho lớp khác (`TestYC16_TongQuanChiChuQuanVaNgayBan`). Bằng chứng: gate xanh trong worktree và ở clone chính — be-check PASS, `db-check — 31 bước xuôi · lùi · xuôi lại`. Ghi nhận, không phải lỗi: vết sửa số tối thiểu mang lý do là mã cửa, ADR-118 không đòi lý do người gõ. Còn lại: `shortages.supplies` vẫn đọc từng thứ kèm cả sổ ngày — `T-200` vế (2); thiếu người chờ `T-197`; trang `P4A`.

[↑ đầu file](#top)

---

<a id="p3a-10"></a>
### P3A-10 — Trang tổng kết đòi số theo ngày bán

**Goal:** doanh thu theo **ngày bán** (`02-thoi-gian-ngay-ban.md`), món bán chạy (`E48`), cảnh báo sắp hết từ
`P3A-08`; *hiệu suất nhân viên* là số đếm theo người, không chấm điểm, không xếp hạng (`master_plan/shop-facts.md` §8.6
*Lượt hai* — *sửa 2026-10-19*: câu cũ *"trả chưa có lời"* viết trước lượt hai). Thiết kế: `docs/decisions.md` **ADR-120**;
Acceptance ở `work/backlog.md`.
**Nhận việc:** 2026-10-19 — dẫn Claude Code, thi công Codex (nhánh `codex/P3A-10`).

*Bàn giao (2026-10-19):* thực hiện Codex (nhánh `codex/P3A-10` từ `446fee2`, Codex viết cả test theo lời chủ repo *"yêu
cầu codex làm bạn kiểm tra"*), duyệt Claude Code. Vòng 1 Codex dừng đúng phiếu: `ket.DocSo` trả `cash_day_incomplete` khi
ngày chưa đếm két và bỏ luôn số lượt giấy chưa nhập ⇒ Claude cho thêm `ket.DocTrangThaiNgay` (dấu đối soát + sổ giấy, không
đổi cửa cũ). Vòng 2: code xong, Codex không tới được Docker. Claude chạy be-check: một test đỏ vì dữ liệu dựng ghi dấu đối
soát mà số đếm két và tiền đầu két không có dòng mệnh giá — Claude tự thêm hai dòng ở
`be/internal/tongket/testdata/http.sql`. Thử đột biến: bỏ phép trừ hoàn ⇒ `TestI014_BanThuHaiHoanThuTu` đỏ; bỏ điều kiện
*trước đó chưa huỷ* ⇒ `TestQC14_StaffBayTruongKhoangTrucVaNguoiBam` đỏ. Bằng chứng: bốn `TestI014_*`,
`TestQC14_BanChayComboSuatConHuyChuaHoaDonVaThuTu`, `TestQC14_StaffBayTruongKhoangTrucVaNguoiBam`,
`TestQC14_SummaryQuyenHinhSoGiayVaNhacKiemTra` (401 · 403 người thường và người đứng quầy · 400 · ngày trống · khai 3 nhập 1
⇒ còn 2 · reconciled · reopened · cùng tập với `/supply-check-reminders`), `TestQC14_NgaySaiTruocQuyenVaDatabase`;
`be-check: PASS` và `./scripts/gate.sh` xanh ở clone chính. Ghi nhận: két và kho đọc ngoài giao dịch của doanh thu, hợp
đồng ghi rõ không hứa ảnh nguyên tử xuyên nguồn. Còn lại: trang `P4A-03`.

[↑ đầu file](#top)
