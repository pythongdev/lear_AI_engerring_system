<a id="top"></a>
# Backlog

Hai phần, đọc từ trên xuống: **cần làm** (`Ready`, `In Progress`) và **đã xong** (`Done`).
Cả hai là danh sách gạch đầu dòng. Mô tả dài của việc **đang cần làm** nằm ở mục *Chi tiết* phía
dưới; mô tả dài của việc **đã xong** nằm ở **`work/backlog_archive.md`** (T-086, 2026-09-28).

**Một việc đã xong là một dòng** (T-086, 2026-09-28): `- [x] <mã> <tên> — <ngày> · <hash> · [chi
tiết](…)`. Lúc chuyển *Done*, hồ sơ dài của task **chuyển nguyên khối** lên đầu mục *Chi tiết — việc
đã xong* của `work/backlog_archive.md`, kèm neo `<a id="<mã>">`; từ đó không ai cập nhật nó nữa.
Hash chưa có lúc tick *Done* — commit đến sau — nên dòng mới **không ghi hash**: commit của nó tra
bằng mã, vì subject mở đầu bằng mã (`CLAUDE.md` §6), `git log --oneline --grep='^T-XXX:'`. Hash ở
các dòng cũ là commit mang mã ở đầu subject, hoặc — khi không commit nào mang mã — commit đầu tiên
tick dòng ấy, ghi rõ *(commit tick Done)*.

| Mục | Nội dung |
|---|---|
| [Thứ tự làm lane admin vs các pha](#thu-tu-lane) | **Đ-2** — lời chủ quán về thứ tự làm; file này là owner |
| [Ready](#ready) | việc cần làm — checklist + thứ tự lấy |
| [In Progress](#in-progress) | task đang chạy |
| [Done](#done) | việc đã xong — một dòng mỗi việc |
| [Chi tiết — việc cần làm](#chi-tiet-can-lam) | mô tả dài của việc chưa xong; con trỏ tới sổ pha 1 và sổ admin |
| [`work/backlog_archive.md`](backlog_archive.md) | lưu trữ: dòng *Done* nguyên văn cũ, ghi chú lịch sử, mô tả dài mọi việc đã xong |
| [Vòng chạy một task L1](#vong-chay) | mười bước thủ tục từ nhận task tới khối commit |
| [Task Detail Template](#template) | khuôn viết một task mới |

**Sáu sổ, một chỗ giữ trạng thái.** Ranh giới giữa chúng là **lane** (`docs/decisions.md`
**ADR-036**): pha 1 (`P1-01`…`P1-14`) giữ mô tả ở **`work/backlog_SD.md`** (**ADR-034**) · pha 2
(`P2-01`…`P2-14`) giữ mô tả ở **`work/backlog_DB.md`** (**ADR-049**, dựng 2026-09-20 ở T-081) ·
pha 3 (`P3-01`…`P3-14`) giữ mô tả ở **`work/backlog_BE.md`** (**ADR-076**, dựng 2026-10-01 ở T-120) ·
mảng admin (`ADM-01`…`ADM-53`) giữ mô tả ở **`work/backlog_AD.md`** · lược đồ admin
(`P2A-01`…`P2A-09`) giữ mô tả ở **`work/backlog_AD_DB.md`** (**ADR-068**, dựng 2026-09-30 ở T-122) ·
mọi thứ còn lại ở file này,
rồi sang `work/backlog_archive.md` khi xong.
Dù mô tả nằm ở sổ nào, **file này vẫn là nơi duy nhất giữ trạng thái** — đó là file
`scripts/brief.sh` đọc và đẩy vào mọi phiên mới (**ADR-002**).


<a id="thu-tu-lane"></a>
## Thứ tự làm giữa lane admin và các pha — **Đ-2**, chủ quán chốt

**File này là owner của thứ tự làm.** Nó là dữ kiện **xếp lịch của repo**, không phải dữ kiện của
quán — nên nó **không** nằm ở `master_plan/shop-facts.md` (`docs/decisions.md` **ADR-001**, và §8.3
của file ấy chỉ nhận dữ kiện admin của quán).

**Chủ quán chốt 2026-09-01, xác nhận lại và mở rộng 2026-09-20** (việc đi hỏi: `work/backlog_AD.md`
**ADM-53**):

| Vế | Lời chốt | Trạng thái |
|---|---|---|
| Vế cũ (2026-09-01) | **đóng nốt chuỗi BA trước**, rồi mới chạy nhánh admin | **đã xong** — BA-08…BA-13 đều `Done` từ 2026-09-04 |
| Vế mới (2026-09-20) | lane admin chạy **SONG SONG** với pha 2: *hỏi chủ quán về admin trong khi pha 2 chạy* | **đang hiệu lực** |
| Vế 2026-09-29 | **chủ repo**: *"tôi muốn làm luôn db cho phần admin"* — nhắc lại 2026-09-30 (*"tiếp tục"*) | **đang hiệu lực** — mở thi công **lược đồ** admin cho phần đã đủ luật; `docs/decisions.md` **ADR-068** |

**Vế mới nói chính xác cái gì.** Chủ quán chọn *"Song song: hỏi chủ quán về admin trong khi pha 2
chạy"*, và phương án ấy nói rõ hai nửa:

- **Được làm song song: THU LUẬT.** Đem các câu `A`…`F` còn mở ở `work/admin-questions.md` §3 đi
  hỏi chủ quán, và chuyển lời về owner — trong lúc pha 2 (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`)
  đang thi công lược đồ dữ liệu của mảng bán hàng.
- **KHÔNG làm song song: THI CÔNG ADMIN.** Lời này **không** cho phép dựng phần admin, cũng không
  cho phép pha 2 gánh luôn lược đồ admin. Việc admin nào cũng vẫn phải qua cổng của lane nó
  (`work/backlog_AD.md`, mục *Cổng của cả lane*).

⇒ Hệ quả đọc được ngay: **23/29 việc của lane admin đang bị chặn bởi câu chưa hỏi** (đo 2026-09-04,
`work/backlog_AD.md`) nay **được phép gỡ ngay**, không phải chờ pha 2 đóng. Việc *thi công* chúng
thì vẫn chờ.

⚠️ **`docs/decisions.md` ADR-031 nói *"ba mảng đi SAU mảng bán hàng"*** — lời ngày 2026-09-20
**không** lật ngược câu đó: *"sau"* ở ADR-031 nói về **thi công**, còn lời này nói về **thu luật**.
Hai chữ khác nhau; đừng đọc cái này thành phép thi công admin trước.

**Vế 2026-09-29 đổi đúng một nửa của vế trước, và chỉ nửa ấy** (T-122, `docs/decisions.md`
**ADR-068**). Lúc lời này có hiệu lực, mười bốn bước pha 2 của mảng bán hàng đều đã `Done`
(2026-09-30).

- **Nay được làm: LƯỢC ĐỒ admin của phần đã đủ luật** — chín bước `P2A-01`…`P2A-09`, thứ tự và
  cổng ở `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`, mô tả ở `work/backlog_AD_DB.md`.
- **Vẫn KHÔNG làm:** chỗ cất cho phần còn chờ lời chủ quán (kế hoạch ấy §6), và pha 3 · pha 4 của
  admin. Lời ngày 2026-09-29 nói *db*; nó không nói API hay màn hình.
- **Thu luật vẫn chạy song song** như vế 2026-09-20.
- *Cách đọc của phiên ghi, không phải lời chủ repo* (`work/findings.md` **F-004**): lời gốc không
  nêu phạm vi; phiên đọc nó hẹp — chỉ phần đã đủ luật. Người nói trong phiên là **chủ repo**; hai
  vế trước được ghi là lời **chủ quán**, và phiên không tự đồng nhất hai vai.

Mỗi mục có link `↑ đầu file` ở cuối để quay lại bảng này.

<a id="ready"></a>
## Ready

- [ ] P3-05 **Danh tính · vai · quyền theo chỗ đứng** — ma trận vai × thao tác (file mới ở `docs/product/3-be/`), đăng nhập nhân viên, quyền theo chỗ đứng lúc bấm, khách QR qua mã hiện hành, *ai bấm* trên mọi thao tác tiền; **cách đăng nhập là câu cho chủ quán** nếu `shop-facts.md` chưa có lời — L2. Mở 2026-10-06 sau `P3-04`. [chi tiết](backlog_BE.md#p3-05)
- [ ] P2A-05 Lát khoản chi — khoản chi ngoài tiền hàng và lương, theo loại; **mỗi loại mang nguồn tiền** (bốn loại `E44` mang nguồn két), khoản giữ ngày khai và lúc ghi, không cột *ngày bán của két* khi `U-072` còn mở. **Chờ chủ repo duyệt `docs/decisions.md` ADR-074** (thiết kế của T-125, mức L3) trước khi dựng — L2 · [chi tiết](backlog_AD_DB.md#p2a-05)
- [ ] T-109 **ĐANG CHỜ mở pha 5 — không nhặt theo thứ tự trên xuống** (chủ repo chọn chờ, 2026-09-28). **Pha 5 — triển khai và nghiệm thu bảo toàn, khôi phục dữ liệu** — L2, giao 2026-09-27 theo ADR-057. Yêu cầu và tiêu chí: `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8 (YC-21). Thực hiện khi mở pha vận hành; phải xong trước bán thật. Ba tiêu chí nghiệm thu **đã chốt 2026-09-28** (chủ repo, ghi ở YC-21 §8: mất tối đa 1 giờ bán · phục hồi trước ca bán kế tiếp · giữ bản sao lưu 1 năm); cùng ngày chủ repo chọn **chờ mở pha 5** mới làm phần cơ chế, không dựng thử trên database máy phát triển. Pha vận hành chỉ định người phụ trách, mở owner đúng quy tắc pha, thiết kế sao lưu/phục hồi, chạy phục hồi thử và lưu bằng chứng đối chiếu. RR-9 còn chưa được chặn cho tới khi nghiệm thu đạt; không mở lại quyết định chọn owner của F-034.

[↑ đầu file](#top)

<a id="in-progress"></a>
## In Progress


<a id="done"></a>
## Done

- [x] P3-04 **Khuôn hợp đồng API — mở `docs/product/3-be/`** — OpenAPI 3.1 `openapi.yaml` rỗng đường gọi + khuôn `01-hop-dong-api.md`; hình lỗi `{code, field?}`, mã kèm status; bảng tên từ chối → mã phủ 290 tên migration; Gate 1g `scripts/check-api-contract.sh` so hợp đồng ↔ code ↔ migration mọi lượt; hợp đồng thắng code (**ADR-084**); migration bước 18 đóng **F-058** — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-04)
- [x] P3-03 **Quy ước code backend — dựng `be/`** — Go 1.27.1 · `net/http` · pgx v5 với câu ghi trong file `.sql` của một cửa (ADR-083); `QC-11`…`QC-17`; Gate 1f `scripts/check-write-paths.sh` liệt kê ô ghi → cửa, có ca hồi quy đường ghi thứ hai; `scripts/be-check.sh` chạy `go test` trên PostgreSQL thật — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-03)
- [x] P3-02 **Gate 1d học vùng pha 3** — `scripts/check-phase-boundary.sh` soát thêm `docs/product/3-be/` với bộ mẫu riêng: đỏ với thẻ JSX (ký tự trước `<` không phải chữ/số, tách khỏi generic), route màn hình, đuôi `.jsx`/`.tsx`/`.vue`; im với endpoint, SQL, generic; ca hồi quy 20–25 — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-02)
- [x] P3-01 **Ranh giới và từ vựng pha 3** — *ô ghi* · *cửa ghi*, phép chấm tầng 2 · tầng 3, lệnh liệt kê đường ghi dựng ở `P3-03`, cổng đếm §1–§4 (admin ngoài), lời từ chối của database tới người dùng qua tên — **ADR-082**; mở **F-058** — L2 — 2026-10-05 · [chi tiết](backlog_BE.md#p3-01)
- [x] T-137 Thêm một dòng con vào bản ghi đã có (món vào đơn · thành phần vào suất · xấp vào tiền đầu két) để lại vết trên bản ghi cha — migration bước 17 `20261005130000_vet_them_dong_con` (trigger `AFTER INSERT`, chế độ mềm như vết sửa); câu `I-024/3` · `I-011/1` · `I-021/7` chỉ kêu lần thêm không vết; khoá chặn đường lùi theo vết; **F-047** đóng — **ADR-081** — L2 — 2026-10-05 · [chi tiết](backlog_archive.md#t-137)
- [x] T-136 Chủ repo ký chuyển sang pha 3 và xác nhận cách chia mười bốn bước — ghi ở cổng pha 2 §7, kế hoạch pha 3, ADR-076 *Sửa đổi*; `P3-01` vào *Ready* — 2026-10-05 · [chi tiết](backlog_archive.md#t-136)
- [x] T-134 Ngày đã đối soát xong thì số đếm và tiền đầu két đứng yên với mọi vai, và dấu không đứng trên số rỗng — migration bước 16 `20261005120000_khoa_so_dem_ngay_da_ky` (trigger chặn thêm · sửa · xoá · `TRUNCATE`; dấu cần dòng mệnh giá ở cả hai vế); sáu file `db/reconcile/proof/` tắt khoá trong chính lỗi cài; không dựng đường sửa số đã ký (**U-074**), không đòi lệch 0 (**U-073**); **F-056** · **F-057** đóng — **ADR-080** — Codex thi công, Claude duyệt — 2026-10-05 · [chi tiết](backlog_archive.md#t-134)
- [x] T-135 Con trỏ chết sau khi chuyển `docs/work-flow-session/` · `docs/project_work_flow/` sang `docs/private/` — ba con trỏ đến và link tương đối trong năm file đã chuyển, chỉ đổi đường dẫn; khối commit gồm luôn việc chuyển (chưa commit lúc làm) — L0 — 2026-10-05 · [chi tiết](backlog_archive.md#t-135)
- [x] T-133 Số tiền mặt đếm cuối ngày và dấu *ngày đã đối soát xong* có chỗ cất — migration bước 15 `20261001150000_dem_ket_doi_soat`: `cash_count` · `cash_count_line` cùng hình tiền đầu két, `reconciled_day` khoá ngoại về số đếm và tiền đầu két, không đòi lệch 0 (**U-073**); câu `I-021/1` · `I-012/2` · `I-014/5` mỗi câu một lỗi cài; `YC-03` · `YC-08` sang *GỌI TÊN*; ngày chờ `U-072` không kết luận; **F-048** đóng — **ADR-079** — 2026-10-05 · [chi tiết](backlog_archive.md#t-133)
- [x] T-132 Vết của mỗi lần *quán đang mù* và mỗi lần *tạm dừng nhận đơn* có dòng yêu cầu và chỗ cất — `YC-34` cặp với một dòng `architecture.md` §8; migration bước 14 dựng `order_intake_pause` · `shop_blind_spell` (không chồng nhau, kết thúc phải có người, chỉ khép được — **ADR-078**); câu `I-008/2` · `I-008/3` có lỗi cài, `YC-34` chấm đọc + sai; tập 5 còn chờ lý do huỷ máy đọc được; **F-050** *Fixed* — 2026-10-01 · [chi tiết](backlog_archive.md#t-132)
- [x] T-127 Thứ đã làm của đơn huỷ mà không bàn nào chờ có chỗ ghi *bánh làm sai* — bảng `wrong_make_note` (bước migration 13, đường lùi có khoá chặn): một ghi chú một dòng trên đúng một thứ đã làm của đơn đã Huỷ, người ghi · lúc ghi · chữ tuỳ chọn, ghi nhầm huỷ tại chỗ; `I-004/6` loại thứ đã ghi chú — **ADR-077** — 2026-10-01 · [chi tiết](backlog_archive.md#t-127)
- [x] T-120 Pha 3 có kế hoạch `master_plan/BE_master_plan_banh_cuon_ba_thanh.md` và sổ `work/backlog_BE.md`: mười bốn bước `P3-01`…`P3-14`, admin ngoài pha 3, `P3-01` chờ chủ repo ký chuyển pha — **ADR-076** — 2026-10-01 · [chi tiết](backlog_archive.md#t-120)
- [x] P2A-09 Rà ranh giới pha và pointer trên file lát admin — chín lượt `P2-14` và chín nhóm §6 trên 18 file tài liệu · 36 file mã: 0 endpoint · route · component, 0 dòng *cất* thứ bị chặn, mỗi lượt có dòng thử kêu đúng; hai dòng *quyền* loại 5 Claude xếp loại 3 + 2; bảy con trỏ lệch sửa cùng lượt; ô 7 · 8 ký ⇒ cổng lược đồ admin **8/8** trừ lát `P2A-05` vắng; Codex lọc, Claude duyệt và ký — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-09)
- [x] P2A-08 Cổng chất lượng lược đồ admin — `db/scenario/s4_ngay_quan_tri.sql` diễn chín bước một ngày quản trị (sổ nguyên liệu, chấm công có huỷ, tạm ứng có duyệt, thưởng), mỗi bước trỏ một dòng `shop-facts.md` §8; đọc lại ở kết nối khác; `YC-26`…`YC-32` chấm đọc + sai, `db-check` đòi cả mã §9 trừ danh sách *YC chưa có lát* tự hết hạn (§9.3, khuôn ADR-070); ô 1–6 ký kèm output, `P2A-05` · `YC-33` vắng chờ ADR-074; Codex thi công, Claude chạy database, sửa một lỗi tên biến và ký — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-08)
- [x] T-126 Khách trả nợ dần — migration `20261001120000_tra_no_dan`: mỗi lần trả một dòng mang số còn thiếu trước · sau, chuỗi giữ bằng khoá ngoại và khoá duy nhất (**ADR-075**); `YC-02` viết lại; test hồi quy viết trước (chín lời từ chối, đọc lại năm ngày); hạng tử nợ cũ thu của `I-005/3` · `I-012/1` đọc mức nợ giảm; khoá chặn bước lùi thử thật; Claude thiết kế và viết test, Codex thi công, Claude chạy database và duyệt — 2026-10-01 · [chi tiết](backlog_archive.md#t-126)
- [x] T-131 Gate 1d bắt thẻ component có thuộc tính và thẻ đóng — `PAT_FE` nới, 12 ca hồi quy (sáu hình × hai vùng) và một ca văn xuôi không kêu oan; hai hình *tên trong backtick* để mắt người, lý do ở header; `F-049` *Fixed*; Codex thi công, Claude duyệt — 2026-10-01 · [chi tiết](backlog_archive.md#t-131)
- [x] T-130 Đề bài `P2A-09` giao được cho Codex — kế hoạch §7: ô 1–6 ký ở `P2A-08`, ô 7 · 8 ở `P2A-09`; entry `P2A-09` có tập file và tập con trỏ, lượt lọc cho chín phần §6, luật xếp dòng *quyền* (cách đọc của phiên, chờ chủ repo), dòng lát vắng (`P2A-05` mang việc rà về mình); không rà, không đổi lời quán hay lược đồ — 2026-10-01 · [chi tiết](backlog_archive.md#t-130)
- [x] P2A-07 Phép đối chiếu của admin vào bộ đối chiếu — mười hai câu mới trong `db/reconcile/i025.sql` … `i028.sql`, mỗi câu một lỗi cài kêu đúng mã; tập không thành câu (`I-026` tập 1 · 2, `I-028` tập 5 · 6, `I-021` tập 2) có dòng vì sao ở `09-doi-chieu-bat-bien.md` §2; hai câu *chuỗi vết đứt* đọc lần sửa mất vết dưới chế độ mềm (**F-046**) trên dòng đã có vết; ngày bán mẫu thêm dữ liệu admin, mọi câu vẫn rỗng; `I-029` *vắng*, người nợ `P2A-05`; câu `I-021` đánh số lại theo bảy tập (**F-055** đóng); Codex thi công, Claude thiết kế và duyệt; `db-check` 97 câu · 97 lỗi cài, gate xanh — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-07)
- [x] T-128 Hai lần chạy `db-check` song song không gỡ database của nhau — mỗi lần chạy một compose project `banhcuon_check_<PID>_…`, `cleanup` chỉ gỡ của mình, project của lần chạy đã chết (hỏi `ps -p`) được lần sau dọn, tên cũ và `banhcuon` không bị đụng; `QC-07` và hai trang `docs/guideline/` đổi cùng lượt; **F-045** *Fixed*. Codex thi công, Claude duyệt, sửa một chỗ (`kill -0` → `ps -p`) và đo bằng Docker: hai lần chồng nhau đều PASS, `kill -9` được dọn — 2026-10-01 · [chi tiết](backlog_archive.md#t-128)
- [x] P2A-06 Dữ liệu mồi admin — `db/seed/seed.pl` đọc lúc chạy hai danh sách của `master_plan/shop-facts.md` §8.4 (danh sách 2026-09-06 và bảng *Hàng mua vào*) vào `supply_item`: tên bằng nhau khi bỏ hoa thường là một dòng mang đơn vị của bảng, tên khác nhau giữ riêng; thứ chưa có đơn vị để NULL; 30 hàng · 12 chưa có đơn vị trên owner hôm nay; `db-check` bước 4 đối chiếu tên owner ↔ database bằng `comm -3`; Codex thi công, Claude viết nghiệm thu và duyệt; đơn vị của mười hai tên cũ còn ở bản nháp B12 — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-06)
- [x] T-125 Tiền RA khỏi két trong ngày thành một hạng tử *chi từ két* của `I-021`; `I-028` · `I-029` có vế nối két, mỗi loại chi mang nguồn tiền; `YC-31`…`YC-33`, tầng bảo vệ, công thức `architecture.md` §6.4 viết lại theo cùng lời; **ADR-074**; chủ repo trả lời *tiền rời két trong ngày, trước lúc đếm két* (ghi ở `shop-facts.md` §8.10), mở `U-072` (trừ vào két ngày bán nào); chỉ tài liệu, không code; chủ repo **chưa duyệt** thiết kế — 2026-10-01 · [chi tiết](backlog_archive.md#t-125)
- [x] P2A-04 Lát khoản của người — hai bảng `staff_advance` · `holiday_bonus` (bước migration thứ mười một, có bước lùi có khoá chặn): mỗi khoản một dòng mang người nhận, số tiền lớn hơn 0, ngày, người ghi và lúc ghi; tạm ứng có người duyệt bắt buộc; vai ghi chỉ sửa số tiền · người nhận · ngày, không xoá; không gì nối sang két (chờ `T-125`); thi hành `I-028` · `YC-31` · `YC-32`, **ADR-073**; **F-054** tìm ra và sửa (ngày bán mẫu thêm một khoản mỗi loại); Codex thi công, Claude thiết kế, viết test trước và duyệt; câu đối chiếu của `I-028` còn nợ ở `P2A-07` — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-04)
- [x] P2A-03 Lát chấm công — một bảng `attendance_day` (bước migration thứ mười, có bước lùi có khoá chặn): một ô *có đi làm* là một dòng của một người một ngày, mang người tick và lúc tick; ô tick nhầm **huỷ** được tại chỗ (lúc huỷ, ai huỷ, ghi chú) và ở lại để kiểm, tick lại được; vai ghi không đổi người hay ngày, không xoá; không giờ tới, buổi, ngưỡng đi muộn hay khoản trừ; thi hành `I-027` · `YC-30` (cả hai viết lại theo lời chủ quán đóng `U-069`: chủ quán tick hết, mỗi người mỗi ngày một ô), **ADR-072**; cùng lượt ghi lời chủ quán đóng `U-070` (nút huỷ, có ghi chú) · `U-068` (*thời gian nhập* là lúc hàng mua về), `U-058` nhận lại lời cũ lần thứ năm, vẫn mở; mở `U-071` (ghi chú huỷ có bắt buộc không, ai được huỷ); Codex thi công, Claude ghi lời chủ quán, thiết kế, viết test trước và duyệt; câu đối chiếu của `I-027` còn nợ ở `P2A-07` — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-03)
- [x] P2A-02 Lát sổ nguyên liệu — hai bảng `supply_item` · `supply_day_entry` (bước migration thứ chín, có bước lùi có khoá chặn): một con số người gõ là một dòng mang người nhập, ngày và lúc gõ; tổng và hiệu số không có chỗ cất, đọc ra bằng phép cộng; con số là `numeric` đúng như gõ (vai trò cột mới `_measure`, `QD-03` · `QC-04`); thi hành `I-025` · `I-026`, **ADR-071**; bước khoá chặn của `db-check` lùi qua bước còn rỗng (**F-053**, ghi và chữa cùng lượt). Codex thi công, Claude thiết kế, viết test trước và duyệt; `db-check` 9 bước · 28 file test xanh, gate xanh. Còn nợ có tên: buổi bán đủ năm kênh (`P2A-08`), câu đối chiếu (`P2A-07`), vết mềm (`F-046`) — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-02)
- [x] T-124 Lời chủ quán 2026-09-30 cho sáu câu hỏi về owner: đóng `U-067` · `U-066` (tiền từ két bán hàng), `U-065` (một ô *có đi làm* do chủ quán tick), `U-064` (POS ghi chú bánh làm sai), `U-063` (khách nợ được trả dần); `U-058` nhận lại lời cũ lần thứ tư, vẫn mở; mở `U-069` (lời `U-065` va với `C31`); hệ quả chưa làm thành `T-125` · `T-126` · `T-127` — 2026-09-30 · [chi tiết](backlog_archive.md#t-124)
- [x] T-123 Phép so mã của bộ đối chiếu nhận danh sách *mệnh đề chưa có lát* có tên, tự hết hạn — chữa `F-052` theo đường (b), **ADR-070**; danh sách ở `09-doi-chieu-bat-bien.md` §2.1, `scripts/reconcile.sh` đọc lúc chạy; `--codes` exit 0 với năm `NOTE`, `scripts/reconcile.test.sh` 21 ca, `db-check` xanh; Codex thi công, Claude thiết kế và duyệt; còn chờ chủ repo: câu viết ở lát hay dồn về `P2A-07` — 2026-09-30 · [chi tiết](backlog_archive.md#t-123)
- [x] P2A-01 Yêu cầu dữ liệu và invariant của phần admin đã đủ luật — tám dòng `YC-26`…`YC-33`, năm mệnh đề `I-025`…`I-029` cùng tầng và phép đối chiếu (nhóm QUẢN TRỊ), hành vi ở `01-ranh-gioi.md` §1.6, **ADR-069**; Codex thi công hai file pha 1, Claude viết mệnh đề và duyệt; mở `U-067` · `U-068`; chỗ hở mới `F-052` (mã mệnh đề có trước câu đối chiếu) — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-01)
- [x] T-122 Lược đồ admin có kế hoạch và sổ việc: chín bước `P2A-01`…`P2A-09` cho phần đã đủ luật, chín phần còn chặn mỗi phần một dòng; lời chủ repo 2026-09-29 mở cổng ghi ở mục *Thứ tự làm* và **ADR-068**; mở `U-065` · `U-066` — 2026-09-30 · [chi tiết](backlog_archive.md#t-122)
- [x] P2-14 Rà chéo ranh giới pha và pointer — chín lượt lọc endpoint · route · component trên mười một file pha 2 (2753 dòng), mỗi lượt một cặp chưa lọc · đã lọc, bộ lọc chứng minh biết kêu trên bản sao có cài lỗi; ô 9 ký ⇒ cổng pha 2 **12/12**; pointer hai chiều rà xong, bốn câu *"pha 2 chưa mở"* của pha 1 nhận ghi chú có ngày; chỗ hở mới `F-049` (Gate 1d hẹp) · `F-050` (vết *quán đang mù* chưa có dòng yêu cầu). **Ký chuyển pha 3 là quyền chủ repo** — 2026-09-30 · [chi tiết](backlog_DB.md#p2-14)
- [x] T-121 `db-check` hết đỏ theo giờ trong ngày — đơn mà test `I-024` để lại sau COMMIT nay khai lúc tạo trong giờ bán thay vì lấy đồng hồ; không phép chấm nào đổi. `./scripts/db-check.sh` lúc 20:59 ⇒ exit 0, cùng lệnh trên `HEAD` lúc 20:55 ⇒ exit 1 (`I-008/1`); `work/findings.md` **F-051** *Fixed*. L1, làm trước vì chặn `P2-14` — 2026-09-30
- [x] P2-13 Cổng chất lượng pha 2 — ba scenario diễn qua lược đồ (mỗi bước một giao dịch COMMIT, đọc lại ở kết nối khác, đối chiếu rỗng trên ngày ấy), 24 dòng `YC` chấm hai câu, 11/12 ô cổng ký kèm bằng chứng, ô 9 chờ `P2-14`; chỗ hở mới `F-048` — 2026-09-30 · [chi tiết](backlog_DB.md#p2-13)
- [x] P2-11 Bộ query đối chiếu bất biến — 63 câu `I-0xx/n` + 22 câu `QD`, một lệnh `scripts/reconcile.sh`; ngày mẫu đúng ⇒ 0 dòng, 85 lỗi cài kêu đúng tập khai; 29 tập chưa có câu có tên — 2026-09-30 · [chi tiết](backlog_DB.md#p2-11)
- [x] P2-09 Thứ tự migration và đường lùi — mỗi bước một file lùi có khoá chặn, `db-check` xuôi · lùi · xuôi lại từng bước; tên bảng `.md` ↔ migration là Gate 1e — 2026-09-30 · [chi tiết](backlog_DB.md#p2-09)
- [x] T-087 `CLAUDE.md` chỉ giữ luật và con trỏ — 607 còn 412 dòng; cơ chế về header script, lý do về ADR-064 — 2026-09-29 · [chi tiết](backlog_archive.md#t-087)
- [x] P2-08 Lược đồ người · chỗ đứng theo thời điểm · vết — trực quầy theo khoảng, *ai bấm* bắt buộc, vết cập nhật bản trước / bản sau, sổ giấy nhập bù — 2026-09-28 · `8e5a77e` · [chi tiết](backlog_DB.md#p2-08)
- [x] T-119 Đo lại thí điểm lane pha 2 (ADR-051): mục tiêu đạt, ba trên bảy bước có dấu *Done* trong commit của task khác — 2026-09-28 · [chi tiết](backlog_archive.md#t-119)
- [x] T-086 `work/backlog.md` chỉ giữ trạng thái — mỗi việc đã xong một dòng; chi tiết sang `work/backlog_archive.md` — 2026-09-28 · [chi tiết](backlog_archive.md#t-086)
- [x] T-085 Mỗi task một file scope `work/scope/<MÃ>.txt`; Gate 7b chấm theo task trong subject — 2026-09-28 · `2ab82bc` · [chi tiết](backlog_archive.md#t-085)
- [x] T-084 Gate in lẫn "OK" · "xanh" · "skipping" · "note:", nên "đã kiểm và đạt" trông giống "không kiểm" — 2026-09-28 · `5d64e6c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-10 Dữ liệu mồi — menu thật, bàn và mã QR, trạm của thành phần; mười ba ca giá §4.8 khớp từng đồng — 2026-09-28 · `f385fc0` · [chi tiết](backlog_DB.md#p2-10)
- [x] P2-07 Lược đồ sản xuất theo mẻ — việc trạm một dòng một đơn vị, mẻ và lần lùi mẻ, phần của từng bàn… — 2026-09-28 · `3701e1a` · [chi tiết](backlog_DB.md#p2-07)
- [x] P2-06 Lược đồ đường tiền — hoá đơn, thu chia phương thức, nợ, hoàn tiền, trả trước, tiền đầu két… — 2026-09-28 · `89ac41b` · [chi tiết](backlog_DB.md#p2-06)
- [x] T-114 Migration giữ `I-023` — bảng `qr_code` giữ mã hiện hành và mọi mã đã thay, một cửa sinh mã… — 2026-09-28 · `3768250` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-118 Ghi lời chủ quán đóng U-062 (ai đổi mã QR, khi nào) và U-060 (ai cập nhật số người thực tế)… — 2026-09-28 · `3768250` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-116 Migration giữ `I-024` — dấu lần gửi trên mọi đơn và mọi lượt gọi, bắt buộc và duy nhất không… — 2026-09-28 · `82a1587` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-111 Migration giữ `I-022` — liên hệ tối thiểu của đơn mang đi thành năm ràng buộc thật trên… — 2026-09-28 · `9671f93` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-117 F-031: Gate 8 chặn subject trùng một commit đã có trong lịch sử, sửa hai con số của entry T-062 — 2026-09-28 · `74cc89f` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-115 F-043: một lần gửi thành đúng một đơn — mệnh đề `I-024`, có tầng, có `YC-25` — 2026-09-28 · `34b3d9c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-113 F-042: mã QR của bàn thành mệnh đề `I-023` — bàn của lượt gọi QR tra từ mã, mã không đoán… — 2026-09-28 · `f152dd1` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-112 F-037: khoản trả trước có dòng trong công thức đối soát, `I-021` có hạng tử cho nó, và `YC-23` — 2026-09-28 · `d333b7b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-110 F-038: mức liên hệ tối thiểu của đơn mang đi thành mệnh đề `I-022`, có tầng và có `YC-22` — 2026-09-28 · `0dd8afb` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-108 Đặt yêu cầu khôi phục ở pha 1, giao cơ chế cho pha 5 và đóng F-034 — 2026-09-27 · `b04715c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-107 F-033: kế hoạch pha 1 thôi tự khai trạng thái — mỗi ô trỏ về bước sở hữu và `work/backlog.md` — 2026-09-28 · `8ebe7f4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-106 Rà phép đếm ADM và đóng F-028 — 2026-09-27 · `18dbd31` · [chi tiết](backlog_archive.md#t-106)
- [x] T-105 Mọi điều AI truyền đạt cho chủ repo viết bằng văn xuôi tiếng Việt — 2026-09-27 · `92b4f76` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-103 F-036: phép đối chiếu phủ mọi vế — hai hàng thiếu vế và năm hàng cùng hình — 2026-09-27 · `a70467b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-104 Đóng F-019 — nghiệm thu đếm chữ trong tiêu đề sau lượt tách file — 2026-09-27 · `71f8705` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-05 Lược đồ menu · giá · ảnh chụp giá lúc đặt — `I-009` tầng 1 thành ràng buộc thật, `F-036` là… — 2026-09-27 · `71f8705` (commit tick *Done*) · [chi tiết](backlog_DB.md#p2-05)
- [x] T-102 Ghi lời xác nhận số người thực tế và giảm giá cả đơn — 2026-09-28 · `066c94a` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-04 Lược đồ lát bán hàng lõi — bảy mệnh đề thành ràng buộc thật, `F-038` · `F-043` là chỗ trống có… — 2026-09-27 · `a99d3ef` · [chi tiết](backlog_DB.md#p2-04)
- [x] T-101 Codex được sửa thêm vài file khi chủ repo giao thẳng task nhỏ — 2026-09-27 · `598d7ee` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-12 Quy ước code — DBMS là PostgreSQL 17 — 2026-09-27 · `6bf8f97` · [chi tiết](backlog_DB.md#p2-12)
- [x] T-100 Áp dụng chia vai Claude quyết, Codex thi công — 2026-09-27 · `5ca8c96` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-03 Quy ước dữ liệu — mở `docs/product/2-db/` — 2026-09-27 · `70ecefc` · [chi tiết](backlog_DB.md#p2-03)
- [x] T-097 Mười một bài học lược đồ của dự án cũ vào đúng bước pha 2 — 2026-09-25 · `cf048d4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-096 Ba lỗ quy trình pha 2 rút từ dự án cũ: DBMS chốt trước lát lược đồ · bản nào thắng khi có… — 2026-09-25 · `b4b603e` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-094 Ghi nhận lời đáp U-053–U-059 — 2026-09-25 · `1480aba` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-098 Chốt mốc nguyên liệu và người khai danh tính ngoài quầy — 2026-09-27 · `1145325` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-099 Ghi nhận lời bổ sung về mất mạng, đi giao và giảm giá — 2026-09-27 · `f378015` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-095 Cập nhật lời chủ quán về B19/B20 — 2026-09-25 · `404719d` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-093 Ghi nhận câu trả lời E44–E51 — 2026-09-25 · `1e00f9b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-092 Ghi nhận câu trả lời D37–D43 — 2026-09-25 · `1f7f6d4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-091 Ghi nhận câu trả lời C24–C35 — 2026-09-25 · `a044398` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-090 Ghi nhận B18/B19/B22 và làm rõ B20 — 2026-09-25 · `3dde852` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-089 Ghi nhận câu trả lời B11–B17 — 2026-09-25 · `b85afc9` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-088 Claude Code và Codex dùng chung luật và bàn giao — 2026-09-25 · `3dde852` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-088)
- [x] T-083 Lane pha 2: entry ở `work/backlog_DB.md` là hồ sơ thực thi duy nhất, trạng thái chỉ ở file này — 2026-09-25 · `8e319c1` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-02 Gate 1d nay chấm CẢ vùng pha 2, với một bộ mẫu riêng im lặng với SQL — 2026-09-24 · `d57cf4f` · [chi tiết](backlog_DB.md#p2-02)
- [x] P2-01 Ranh giới và từ vựng của cả pha 2 có owner: `docs/decisions.md` ADR-050 — 2026-09-24 · `0715382` · [chi tiết](backlog_DB.md#p2-01)
- [x] T-082 Món nợ trạng thái scope lần thứ BA, và lần thứ SÁU một phiên song song nhặt việc của phiên khác — 2026-09-22 · `d4bb50f` · [chi tiết](backlog_archive.md#t-082)
- [x] T-081 Pha 2 có sổ mô tả riêng: `work/backlog_DB.md`, mười bốn entry `P2-01`…`P2-14` — 2026-09-20 · `04c5a64` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-081)
- [x] ADM-21 Lời `C36` đã về owner: mỗi lần đổi người Ở QUẦY là một mốc có giờ — 2026-09-20 · `04c5a64` (commit tick *Done*) · [chi tiết](backlog_AD.md#adm-21)
- [x] ADM-53 Hai lời chủ quán chốt 2026-09-01 đã về owner — và `C36` có lời — 2026-09-20 · `e1ecbaf` · [chi tiết](backlog_AD.md#adm-53)
- [x] T-080 Pha 2 có kế hoạch còn sống: mười bốn bước `P2-01`…`P2-14`, và một cổng mỗi ô kèm cách chứng… — 2026-09-20 · `3f18bf3` · [chi tiết](backlog_archive.md#t-080)
- [x] T-079 Ô 10 của cổng pha 1 tick — cổng lên 10/10 — 2026-09-20 · `20f7822` · [chi tiết](backlog_archive.md#t-079)
- [x] T-078 Chủ quán trả lời BỐN câu trong một lượt — `U-042` · `U-043` · `U-051` · `U-052` — và hai lời… — 2026-09-20 · `711d4fd` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-077 `docs/product/99-unknowns.md` có mục lục — file hơn bốn trăm dòng, ba tiêu đề `###`, không có… — 2026-09-16 · `bd9e42e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-12 Ranh giới pha được ĐO lần đầu trên cả pha 1 — và câu trả lời là KHÔNG: ba chỗ lọt ra, chỉ một… — 2026-09-16 · `bf39be5` · [chi tiết](backlog_SD.md#p1-12)
- [x] T-073 Chủ quán đóng `U-044`: hoàn tiền trả lại bằng gì cũng KHÔNG có luật cứng — POS quyết từng ca… — 2026-09-16 · `14203ae` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-072 Chủ quán đóng `U-048` — KHÔNG suất nào bưng kèm canh, nên con số khách chọn trên dòng canh là… — 2026-09-16 · `b3c7c6e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-075 Chủ quán đóng `U-050` — NGƯỜI ĐỨNG QUẦY gánh trạm của người đi giao, và khoảng trống ấy KHÔNG… — 2026-09-16 · `f1bf975` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-074 Chủ quán đóng `U-045` — chữ *thiếu* của mục tổng quan KHÔNG do máy nghĩ ra: không có ngưỡng… — 2026-09-16 · `b3c7c6e` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-071 Chủ quán đóng `U-049` — người ĐI GIAO là một trong bốn vai của §3, không phải người thứ năm… — 2026-09-15 · `66798b8` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-070 Gate 7b chặn một khối bàn giao HỢP LỆ vì một "file" tên `\` — và cùng phép lọc ấy đang bỏ qua… — 2026-09-16 · `bafd656` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-076 Vế NGƯỜI của `U-041` cuối cùng cũng có tập để trỏ vào — bảng phân vai §3 — và lộ ra rằng con… — 2026-09-15 · `66798b8` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-069 Chủ quán đóng `U-046` và `U-047` trong một lượt — menu đi từ BỐN lên SÁU dòng, và một trong… — 2026-09-15 · `66798b8` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-11 Ba scenario nghiệm thu BA nay đã được diễn qua thiết kế, và cổng sang pha 2 ký 9/10 — cả chín… — 2026-09-16 · `63b5eb2` · [chi tiết](backlog_SD.md#p1-11)
- [x] T-068 Chủ quán đọc ra MENU thành một danh sách — bảy tên khớp đúng bảng giá đang có, hai tên là thứ… — 2026-09-08 · `0b61b4d` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-067 Chủ quán đóng `U-041`: vế *"còn thiếu gì không"* của mục tổng quan là thiếu NGUYÊN LIỆU — và… — 2026-09-08 · `0b61b4d` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-10 Năm rủi ro lớn nhất nay là CHÍN, và mỗi dòng chỉ tên được một cơ chế đã viết ra — trừ một dòng… — 2026-09-08 · `0b61b4d` · [chi tiết](backlog_SD.md#p1-10)
- [x] P1-08 Bốn ràng buộc quyết định hình dạng cả hệ thống nay có nhà trong pha 1, mỗi cái một dấu hiệu ĐO… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-08)
- [x] T-066 Chủ quán trả lời NỬA câu `U-042`: bốn bàn mới cũng 4 chỗ/bàn — vế ĐÁNH SỐ vẫn chưa có lời, nên… — 2026-09-08 · `54c0924` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-07 Pha 2 nay có một DANH SÁCH YÊU CẦU để tự chấm lược đồ, và `architecture.md` §8 hết đếm cứng ở… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-07)
- [x] T-065 Hai bước đã xong của pha 1 nay có dòng *Xong ngày…* mà chính luật 3 của `work/backlog_SD.md`… — 2026-09-08 · `54c0924` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-09 Bảng quầy `architecture.md` §3 nay có BỐN con số, và §11 hết giao việc cho một task đã *Done*… — 2026-09-07 · `53febdd` · [chi tiết](backlog_SD.md#p1-09)
- [x] T-047 Bản đã commit của `work/scope.txt` chỉ còn chứa comment, đóng F-020 — 2026-09-03 · `3ee8420` · [chi tiết](backlog_archive.md#t-047)
- [x] T-064 Sửa banner `shop-facts.md` hết tự khai "không trỏ đi đâu", đóng phần còn lại của F-016 — 2026-09-07 · `ffada33` · [chi tiết](backlog_archive.md#t-064)
- [x] T-035 Đổi lời cảnh báo "scope bẩn" của `scripts/brief.sh`, đóng F-014 — 2026-09-07 · `b4d91ea` · [chi tiết](backlog_archive.md#t-035)
- [x] T-063 F-030 đóng: Gate 1c hết coi mã U-XXX được TRÍCH DẪN trong một gạch đầu dòng đang mở là mã đang… — 2026-09-07 · `9cf9f9a` · [chi tiết](backlog_archive.md#t-063)
- [x] P1-06 Năm mệnh đề menu · giá · vết nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng… — 2026-09-07 · `2a39826` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-06)
- [x] P1-14 Mệnh đề mồ côi thứ ba `I-021` nay là hàng thứ tám của nhóm TIỀN, và ô `I-015` hết trỏ tới một… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-14)
- [x] P1-13 Hai mệnh đề sinh SAU khi kế hoạch chia nhóm nay có nhóm thứ tư của riêng chúng — SẢN XUẤT THEO… — 2026-09-07 · `2a39826` · [chi tiết](backlog_SD.md#p1-13)
- [x] T-062 Chủ repo đặt tên chủ cho hai phụ thuộc mà F-027 đo được là chưa có owner — đường báo đơn về… — 2026-09-07 · `7ffabb7` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-061 Danh mục nguyên liệu bắt đầu có TÊN — chủ quán liệt kê mười bốn thứ đầu tiên, còn bổ sung dần — 2026-09-07 · `0159d2e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-060 Chủ quán trả lời BẢY câu cuối cùng còn mở ở `docs/product/99-unknowns.md` trong một lượt, và… — 2026-09-06 · `f2d86e5` · [chi tiết](backlog_archive.md#t-060)
- [x] P1-05 Sáu mệnh đề vòng đời nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng — và một… — 2026-09-06 · `f01a5bd` · [chi tiết](backlog_SD.md#p1-05)
- [x] T-059 Gate 1d chấm máy phần phổ biến nhất của ranh giới pha; `CLAUDE.md` hết ba chỗ mục nát mà một… — 2026-09-06 · `ba4bafb` · [chi tiết](backlog_archive.md#t-059)
- [x] P1-04 Bảy mệnh đề chạm tiền nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng — và ba… — 2026-09-07 · `0159d2e` · `8bea106` · [chi tiết](backlog_SD.md#p1-04)
- [x] T-056 Chủ quán trả lời CẢ MƯỜI câu nhóm A trong một lượt, và một trong mười lời LÀM MẤT NỬA CÂU HỎI… — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-056)
- [x] T-057 Bước 4/12 của pha 1 nay có prompt, và nó là bước DUY NHẤT hôm nay đủ tiền đề để có một. — 2026-09-06 · `8a9ae2b` · [chi tiết](backlog_archive.md#t-057)
- [x] T-058 Lane admin có lane prompt riêng: `prompt/AD/` — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-058)
- [x] T-055 Chủ quán đóng `U-031` bằng một từ, và trả lời MỘT NỬA `U-034` — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-054 Chủ quán trả lời HAI câu trong một lượt, và cả hai đi cùng một hướng: quán không dừng bán… — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-03 Mọi phép cộng tiền của hệ thống nay đứng trên cùng MỘT định nghĩa *một ngày bán*, và định… — 2026-09-04 · `625739e` · [chi tiết](backlog_SD.md#p1-03)
- [x] T-053 Hai việc bị chặn bởi một câu hỏi mà `shop-facts.md` đã trả lời năm ngày trước — 2026-09-04 · `625739e` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-053)
- [x] T-052 Mảng admin có sổ task riêng: `work/backlog_AD.md` — 2026-09-04 · `be4f488` · [chi tiết](backlog_archive.md#t-052)
- [x] P1-02 Pha 1 nay kể tên những thứ NGOÀI hệ thống mà hệ thống đang dựa vào, và nói mất từng thứ thì… — 2026-09-04 · `cfaa725` · [chi tiết](backlog_SD.md#p1-02)
- [x] T-051 Lane `prompt/SD/` nay có sáu file, không phải một. — 2026-09-04 · `508356f` · [chi tiết](backlog_archive.md#t-051)
- [x] P1-01 Ranh giới sở hữu của pha 1 đã có một câu trả lời, và không tài liệu nào còn nói ngược nó. — 2026-09-04 · `da7dd2f` · [chi tiết](backlog_SD.md#p1-01)
- [x] T-050 Đ-3 về owner — 2026-09-04 · `4a6c1cd` · [chi tiết](backlog_archive.md#t-050)
- [x] T-049 Pha 1 có sổ task riêng: `work/backlog_SD.md` — mười hai entry `P1-01`…`P1-12` viết đủ bảy khối… — 2026-09-04 · `da7dd2f` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-049)
- [x] BA-12 `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 — lát cắt sản xuất theo mẻ, và §3 nay là bốn… — 2026-09-04 · `31fb071` · [chi tiết](backlog_archive.md#ba-12)
- [x] T-048 Pha 1 nay có kế hoạch còn sống: `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — mười hai… — 2026-09-03 · `faacc38` · [chi tiết](backlog_archive.md#t-048)
- [x] BA-13 Năm chỗ hai mục đã chốt nói lệch nhau đã dọn, và cổng chất lượng BA nay 9/9 bằng tick thật ⇒… — 2026-09-03 · `39ca608` · `1b9d238` · [chi tiết](backlog_archive.md#ba-13)
- [x] BA-11 `docs/product/0-ba/ban-hang/08-scenario.md` §8 — ba scenario nghiệm thu BA + cổng chất lượng… — 2026-09-03 · `4f8dcd6` · [chi tiết](backlog_archive.md#ba-11)
- [x] DOC-5 `docs/architecture.md` → `docs/product/1-system-design/architecture.md` — lượt 5/5, đóng… — 2026-09-03 · `ad875f0` · `5ddd0e9` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-046 Prompt của DOC-5 hết mang hai con số hỏng — không mở khoá DOC-5. Chủ repo được hỏi 2026-09-03… — 2026-09-03 · `31faded` · [chi tiết](backlog_archive.md#t-046)
- [x] DOC-4 `CLAUDE.md` hết trỏ về bản lưu — 6 chỗ prompt đếm đều có thật và đều đã đổi (29, 30, 135→141… — 2026-09-03 · `ddec2f0` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-3b Nhóm B (`prompt/BA/`, 13 file) hết trỏ về bản lưu — 92 dòng chuyển, 22 ở lại. Ba loại như… — 2026-09-03 · `fd64862` · [chi tiết](backlog_archive.md#doc-3b)
- [x] DOC-3c Vùng *Ready* + *In Progress* của `work/backlog.md` hết trỏ về bản lưu — 7 dòng chuyển (8 lần… — 2026-09-03 · `1a56b8e` · [chi tiết](backlog_archive.md#doc-3c)
- [x] DOC-3a Nhóm A (6 tài liệu chỉ đường lõi) hết trỏ về bản lưu — 99 dòng chuyển, 15 ở lại (prompt đoán… — 2026-09-03 · `dc53768` · [chi tiết](backlog_archive.md#doc-3a)
- [x] DOC-3 (giai đoạn chia việc L3) — đếm lại 2026-09-02: 595 dòng/50 file, không phải 563. Ngoài sổ lịch… — 2026-09-03 · `4f5d8f8` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-2 `scripts/brief.sh` đọc mục *Unknowns* ở `docs/product/99-unknowns.md` thay cho bản lưu — bốn… — 2026-09-02 · `83fe8ff` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-1 `docs/product/` dựng theo pha — 10 mục chuyển nguyên văn (diff với `git show HEAD` rỗng cả 10… — 2026-09-02 · `bc5033c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-0 Chủ repo chốt trục pha thay cho mảng — ADR-014 thêm khối *SỬA ĐỔI 2026-09-02*, tiêu đề đổi… — 2026-09-02 · `3159ef7` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-045 GĐ-01 và GĐ-05 được xác nhận kèm một yêu cầu mới: mỗi lần cập nhật giữ bản trước · bản sau… — 2026-09-02 · `3159ef7` · [chi tiết](backlog_archive.md#t-045)
- [x] BA-10 `docs/decisions.md` — 17 ADR nghiệp vụ (ADR-015…ADR-031), bảng tổng hợp đầu file và bản đồ phủ… — 2026-09-02 · `0e39b9b` · [chi tiết](backlog_archive.md#ba-10)
- [x] T-044 U-026 đóng — dòng vừa sửa lấy giá đang hiệu lực lúc sửa; ngoại lệ có chủ ý của §4.4, I-009… — 2026-09-02 · `61dfc2c` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-044)
- [x] T-043 U-027 và U-030 đóng: đơn đã `Hoàn thành` huỷ được (§5.2 thêm dòng, §5.6 còn một ca, I-016 viết… — 2026-09-02 · `61dfc2c` · [chi tiết](backlog_archive.md#t-043)
- [x] T-042 Chủ quán trả lời U-022, U-025, GĐ-02, GĐ-03 — POS quyết theo tình hình thực tế; §6.19–§6.21 và… — 2026-09-02 · `b296268` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-042)
- [x] T-041 Mảng ADMIN có mục riêng có nhãn ở ba tài liệu — `docs/product.md` §1.6, `docs/architecture.md`… — 2026-09-02 · `2c31dbb` · [chi tiết](backlog_archive.md#t-041)
- [x] BA-09 `docs/product.md` §7 — phạm vi MVP chốt: 14 năng lực + 2 việc vận hành trong MVP, hai loại… — 2026-09-02 · `c4576f2` · `510f092` · `b296268` · [chi tiết](backlog_archive.md#ba-09)
- [x] T-040 Đ-1: ba mảng nguyên liệu · con người · tài chính vào phạm vi — hai dòng ranh giới cũ bị xoá ở… — 2026-09-02 · `691e37a` · [chi tiết](backlog_archive.md#t-040)
- [x] BA-08 `docs/product.md` §6 — mười bốn ngoại lệ; chín dòng chốt, năm dòng thành GĐ-01–GĐ-05 kèm mức… — 2026-09-02 · `9ef217a` · [chi tiết](backlog_archive.md#ba-08)
- [x] T-039 U-021, U-023, U-024 đóng — POS bấm cả bốn mốc, bấm nhầm một mẻ lùi được; U-022 còn một nửa… — 2026-09-02 · `5570e2e` · [chi tiết](backlog_archive.md#t-039)
- [x] BA-07 `docs/product.md` §5 — ba vòng đời, trạng thái giữa của việc trạm là đã làm xong còn ở bếp… — 2026-09-02 · `5570e2e` · [chi tiết](backlog_archive.md#ba-07)
- [x] T-038 U-019 và U-020 đóng: đối chiếu bằng tin nhắn báo có, hoàn tiền tính NGÀY HOÀN, một lần thu… — 2026-09-01 · `c77a740` · [chi tiết](backlog_archive.md#t-038)
- [x] BA-06 `docs/product.md` §4 — quy tắc giá và thanh toán; I-012, I-013, I-014; mở U-019, U-020 — 2026-09-01 · `30abf8f` · `3f579f9` · [chi tiết](backlog_archive.md#ba-06)
- [x] T-037 U-017 và U-018 đóng: bấm theo MẺ, máy chỉ NHẮC; I-011 viết lại vì bản đầu sai (2026-09-01)… — 2026-09-01 · `ffc2997` · `53f58de` · [chi tiết](backlog_archive.md#t-037)
- [x] T-036 S-4 có lời giải: bảng quầy BỐN con số, quầy bấm "đã làm xong"; mở U-017, ghi F-014… — 2026-09-01 · `ffc2997` · `c5540e2` · [chi tiết](backlog_archive.md#t-036)
- [x] T-034 Giá đổi được giữa giờ bán, thành phần suất phải chờ hết buổi; §6.17, I-011; mở U-018 — 2026-09-01 · `f75470c` · [chi tiết](backlog_archive.md#t-034)
- [x] BA-05 `docs/product.md` §3.3 — lát cắt chủ quán đổi menu/giá; I-009, I-010; mở U-014–U-016 — 2026-09-01 · `53f58de` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-05)
- [x] BA-04 `docs/product.md` §3.2 — lát cắt một đơn mang đi, ba kênh không gắn bàn; I-007, I-008 — 2026-08-31 · `12c77f8` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-04)
- [x] T-027 Brief nói ra phần nó đã cắt: `→ ĐÃ CẮT: in 6/10 mục` (F-012 đóng) — 2026-08-31 · `12c77f8` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-027)
- [x] T-031 Bản xuất khẩu hết nút `Xong` ở màn trạm: §3.6 mang luật ghi, POS là nơi duy nhất ghi (F-013) — 2026-08-31 · `12c77f8` · [chi tiết](backlog_archive.md#t-031)
- [x] T-033 U-012 và U-013 đóng nốt; câu hỏi S-4 viết lại vì hỏi sai cách — 2026-08-31 · `cf8bd83` · [chi tiết](backlog_archive.md#t-033)
- [x] T-029 `docs/architecture.md` hết là template rỗng: mặt admin có đặc tả, chỉ POS được ghi (ADR-011) — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-029)
- [x] T-026 Đề xuất Admin/POS được chấm: lời chủ quán về gom mẻ vào nhà thật, phần còn lại bị từ chối có… — 2026-08-31 · `3612d13` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-026)
- [x] T-025 Gate 8 — hook `commit-msg` của git từ chối subject rỗng nghĩa; cài bằng `core.hooksPath`… — 2026-08-31 · `3612d13` · [chi tiết](backlog_archive.md#t-025)
- [x] T-032 Nợ là một phần riêng: `docs/architecture.md` §12 có mục FE · BE · DB (ADR-012) — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-032)
- [x] T-030 U-006 — ghép bàn là MỘT phiên, MỘT hoá đơn; I-001 đọc lại; mở U-013 — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-030)
- [x] T-028 Bảy lời chốt của chủ quán 2026-08-31: cho nợ, năng lực nồi, suất đem về, máy không gom — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-028)
- [x] BA-03 `docs/product.md` §3.1 — lát cắt một suất tại bàn; I-001–I-004; mở U-006, U-007 — 2026-08-31 · `3612d13` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-03)
- [x] T-023 Hậu quả đã commit của F-009 dọn xong: bản đồ hash, blueprint ra khỏi `docs/` (ADR-008) — 2026-08-31 · `08af40c` · [chi tiết](backlog_archive.md#t-023)
- [x] T-019 Bản xuất khẩu hết trỏ vào layout repo cũ; bảy dòng ignore đã gỡ (F-007) — 2026-08-31 · `03ffda3` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-019)
- [x] T-021 `brief.sh` đọc Unknowns theo cấu trúc; mục Unknowns có hình dạng máy đọc được (ADR-007) — 2026-08-30 · `1b1d5f5` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-021)
- [x] T-009 Ready hết dòng mẫu của template — brief chỉ phiên mới vào một task thật — 2026-08-31 · `0704139` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-009)
- [x] T-016 Scope quên dọn thì brief kêu; Gate 7b đọc nội dung khối commit (ADR-006) — 2026-08-31 · `0704139` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-016)
- [x] T-015 §10 kế hoạch gốc: bốn câu mang dấu đã chốt, câu 6 hỏi đúng cả hai kênh — 2026-08-31 · `a85fda7` · [chi tiết](backlog_archive.md#t-015)
- [x] T-014 §2.1 kế hoạch gốc nay có đường điện thoại — khách gọi, nhân viên nhập hộ — 2026-08-31 · `a85fda7` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-014)
- [x] T-024 Gate 1b — tài liệu cũng bị máy chấm: mọi pointer phải mở được (ADR-005) — 2026-08-31 · `5483762` · [chi tiết](backlog_archive.md#t-024)
- [x] T-022 Bản xuất khẩu hết chép số tiền của nhà thật — §4, §9.1, §9.4 nay trỏ `shop-facts.md` — 2026-08-30 · `de7c80e` · [chi tiết](backlog_archive.md#t-022)
- [x] T-020 Đơn mang đi được trả trước — §6.3 hết câu "không bao giờ thu trước", mở U-005 — 2026-08-30 · `0b3a337` · `1b1d5f5` · [chi tiết](backlog_archive.md#t-020)
- [x] T-013 Bản xuất khẩu `prompt-fullstack.md` không còn nói "4 kênh", lát cắt B phủ luồng mang đi — 2026-08-30 · `128955a` · [chi tiết](backlog_archive.md#t-013)
- [x] T-012 Bộ prompt `prompt/BA/` gọi luồng mang đi bằng ba kênh (F-006, lần rà thứ ba) — 2026-08-30 · `0578786` · `9685b1a` · [chi tiết](backlog_archive.md#t-012)
- [x] T-018 Gate 7 — hook chặn turn kết thúc mà chưa giao khối commit (ADR-004) — 2026-08-30 · `5c84476` · [chi tiết](backlog_archive.md#t-018)
- [x] T-017 Kết thúc mỗi task/phiên giao sẵn nội dung commit (CLAUDE.md §6.1) — 2026-08-30 · `b0ce1f6` · [chi tiết](backlog_archive.md#t-017)
- [x] T-011 `phone_preorder` nay thuộc lát cắt Epic B — luồng mang đi ba kênh — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-011)
- [x] T-008 Backlog có 11 task BA-01–BA-11, thứ tự phụ thuộc và acceptance kiểm được — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-008)
- [x] T-010 Gate 3 chỉ chặn file git đang theo dõi; file chưa track chỉ được ghi chú (ADR-003) — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-010)
- [x] T-007 Kế hoạch gốc không còn nói "bốn kênh bán" — §2.2 · §9 · §11 · §12 (F-005) — 2026-08-30 · `25f0f88` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-007)
- [x] T-006 Quyền huỷ đơn gắn với chỗ đứng, không gắn chức vụ (chủ quán chốt 2026-08-30) — 2026-08-30 · `b977589` · [chi tiết](backlog_archive.md#t-006)
- [x] T-005 U-004 — chỉ người đứng quầy được huỷ đơn (chủ quán chốt 2026-08-30) — 2026-08-30 · `d7fe7d8` · [chi tiết](backlog_archive.md#t-005)
- [x] T-004 Ghi nhận sáu câu trả lời của chủ quán ngày 2026-08-30 (U-001–U-003, S-1–S-3) — 2026-08-30 · `8330a0a` · [chi tiết](backlog_archive.md#t-004)
- [x] BA-01 `docs/product.md` §1 — Actor và phạm vi hệ thống — 2026-08-30 · `e801668` · [chi tiết](backlog_archive.md#ba-01)
- [x] BA-02 `docs/product.md` §2 — Kênh bán — 2026-08-30 · `e801668` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-003 Vòng cập nhật liên tục — brief đầu phiên + luật ghi trong phiên (CLAUDE.md §7) — 2026-08-30 · `d3dcc15` · [chi tiết](backlog_archive.md#t-003)
- [x] T-002 Đảo nhà thật về `master_plan/shop-facts.md` (ADR-001) — 2026-08-30 · `7228d36` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-002)

Dòng *Done* nguyên văn trước 2026-09-28 và mọi hồ sơ đã xong: [`work/backlog_archive.md`](backlog_archive.md).

[↑ đầu file](#top)

<a id="chi-tiet-can-lam"></a>
## Chi tiết — việc cần làm

<a id="p1-01"></a>
### Mười hai bước của pha 1 — mô tả dài ở `work/backlog_SD.md`

**`P1-01`…`P1-12` không có mô tả ở file này.** Chúng nằm ở **`work/backlog_SD.md`** — sổ task
riêng của pha 1, dựng 2026-09-04 (T-049, `docs/decisions.md` **ADR-034**). Neo `#p1-01` giữ lại ở
đây vì dòng *Ready* của P1-01 trỏ qua nó; đọc entry thật ở file kia.

**Chia việc giữa ba file, một câu:** file này giữ **trạng thái** (*Ready* · *In Progress* · *Done*
— thứ `scripts/brief.sh` đọc và đẩy vào mọi phiên mới) · `work/backlog_SD.md` giữ **mô tả** (vì sao
có bước, hỏng thì mất gì, chạy mười bước thế nào) · `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`
§6 giữ **thứ tự · mức · đầu ra kiểm chứng được**. Ba chỗ, ba việc, không chỗ nào chép chỗ nào
(`work/findings.md` **F-001**).

**Chỉ bước nào nhận được ngay mới có dòng ở *Ready*.** Mười hai dòng đổ vào đó đẩy bảy dòng ra
khỏi tầm nhìn của mọi phiên mới — `brief.sh` cắt *Ready* ở sáu mục (**F-012**).

[↑ đầu file](#top)

<a id="adm-53"></a>
### Hai mươi chín việc của mảng admin — mô tả dài ở `work/backlog_AD.md`

**`ADM-01`…`ADM-53` không có mô tả ở file này.** Chúng nằm ở **`work/backlog_AD.md`** — sổ task
riêng của mảng admin, dựng 2026-09-04 (T-052, `docs/decisions.md` **ADR-036**). Neo `#adm-53` giữ
ở đây vì dòng trạng thái của ADM-53 trỏ qua nó; đọc entry thật ở file kia.

**Chia việc giữa bốn file, một câu:** file này giữ **trạng thái** · `work/backlog_AD.md` giữ **mô
tả** (vì sao có việc, hỏng thì mất gì, chặn bởi câu hỏi nào) · `work/admin-questions.md` §3 giữ
**câu hỏi cho chủ quán và chỗ chủ quán trả lời** · lời giải đi về **owner** ở `CLAUDE.md` §2, vào
mục riêng có nhãn của mảng admin (**ADR-013**). Bốn chỗ, bốn việc, không chỗ nào chép chỗ nào
(`work/findings.md` **F-001**).

**ADM-53 và ADM-21 đều ✅ `Done` ngày 2026-09-20 ⇒ lane admin KHÔNG còn việc nào nhận được ngay.**
Chủ quán trả lời `C36` trong lượt ADM-53, nên ADM-21 đi **loại 1 → 3 → `Done`** trong cùng một
ngày: lời ấy nay ở owner (`master_plan/shop-facts.md` **§8.8**). Những việc khác vẫn chờ câu trả
lời của chủ quán, và một nhóm đã đủ luật từ trước — phần còn lại của chúng thuộc pha 2–4, không
thuộc lane này. ⇒ **Việc mở lại lane này là một lượt HỎI CHỦ QUÁN, không phải một lượt viết.**
**Ba loại và con số của chúng đọc ở mục *Cổng của cả lane* đầu `work/backlog_AD.md`** — đó là
owner, đừng đếm ở đây (`work/findings.md` **F-003**).

**Từ 2026-09-20, lane này được chạy SONG SONG pha 2 ở nghĩa *thu luật*; từ 2026-09-29 phần đã đủ
luật được dựng LƯỢC ĐỒ** (`P2A-XX`, `work/backlog_AD_DB.md`). Đọc đủ ở mục
*[Thứ tự làm giữa lane admin và các pha](#thu-tu-lane)*.

[↑ đầu file](#top)

<a id="vong-chay"></a>
## Vòng chạy một task L1 — mười bước

File prompt trong `prompt/**` giữ **nội dung** của task: sửa gì, ở đâu, xong là thế nào. Mười bước
dưới đây là **thủ tục** — thứ CLAUDE.md bắt mọi task L1+ phải làm và prompt không nhắc lại. Chạy
prompt mà bỏ thủ tục thì gate xanh nhưng không kiểm gì (bước 2), hoặc phiên sau nhận một backlog
nói sai sự thật (bước 9).

1. Đọc entry của task ở [Chi tiết — việc cần làm](#chi-tiet-can-lam), rồi đọc hết file prompt của
   nó — cả mục *Constraints* và *Unknowns*, không chỉ *Goal*.
   Bước pha 2 thì không có file prompt: đọc khối *Nhận việc* của entry (**ADR-051**).
2. **Khai `work/scope/<MÃ>.txt`** (một file mỗi task, **ADR-063**): chép nguyên khối dòng ở mục
   *Scope* của prompt, **trước** lần sửa đầu tiên (CLAUDE.md §3.4). Bỏ bước này thì Gate 3 in
   `scope not declared, skipping` — gate xanh mà không kiểm gì.
3. Chuyển dòng task từ [Ready](#ready) xuống [In Progress](#in-progress) (§3.3).
4. Sửa file theo mục *Context* và *Constraints* của prompt, ở trong scope. Cần ra ngoài scope thì
   sửa file scope của task và **nói ra**, đừng sửa lén.
5. Gặp dữ kiện nghiệp vụ chưa rõ thì **dừng và hỏi** — không tự quyết. Luật này không có mức L0
   (§3.5); không hỏi được thì ghi thành U-XXX ở `docs/product.md` → *Unknowns*.
6. Chạy mục *Verify* của prompt, rồi `./scripts/gate.sh`. Dán **output thật** vào report — "tôi đã
   test" không phải bằng chứng (§5).
7. Gate 2: mỗi dòng *Acceptance* phải trỏ được tới **dòng cụ thể** trong file chứng minh nó
   (`quality/review-gate.md`). Dòng nào không trỏ được là chưa xong.
8. Dữ kiện mới ghi về đúng nhà của nó (§2, §4), kèm ngày và ai quyết (§7.2). Rồi `grep -rn` những
   chỗ **trỏ tới** thứ vừa đổi và sửa luôn trong cùng lần — pointer lệch là bug của lần này, không
   phải task sau.
9. Xoá dòng task khỏi [In Progress](#in-progress), thêm **một dòng** ở đầu [Done](#done) theo khuôn
   ở đầu file (không hash — commit chưa có), và chuyển nguyên khối chi tiết lên đầu mục *Chi tiết —
   việc đã xong* của [`work/backlog_archive.md`](backlog_archive.md#chi-tiet-da-xong) kèm neo (T-086).
   File scope **giữ** tới khi task đã commit rồi mới xoá (§7.3, **ADR-063**).
10. Kết thúc bằng **khối `git commit` dán được** (§6.1): liệt kê từng file, không `git add -A`,
    không kèm file scope. Gate 7 chặn turn nếu thiếu khối này.

[↑ đầu file](#top)

<a id="template"></a>
## Task Detail Template

Khuôn dưới đây rút ra từ entry **T-012** — entry đầy đủ nhất hiện có. T-012 đã xong 2026-08-30
nên đọc nó ở [`work/backlog_archive.md`](backlog_archive.md#t-012) như một bản mẫu
**đã điền** — cả phần đóng task ở cuối, thứ chỉ viết được sau khi làm xong.

**Luật số một: entry TRỎ, prompt GIỮ.** Entry trả lời *vì sao có task này và mất gì nếu bỏ*.
File prompt trả lời *sửa dòng nào, xong là thế nào*. Năm thứ **không bao giờ** chép vào entry:
bảng file/dòng phải sửa · mục *Acceptance* · mục *Verify* · giá và số điện thoại · sơ đồ luồng.
Chép là tạo bản thứ hai, và bản thứ hai luôn trôi — `work/findings.md` F-001.

**Ngoại lệ thí điểm — lane pha 2** (`docs/decisions.md` **ADR-051**, 2026-09-25): entry ở
`work/backlog_DB.md` là hồ sơ **duy nhất**, Nghiệm thu và Kiểm chứng nằm trong khối *Nhận việc* của
nó, không có file prompt. Khuôn riêng ở cuối file ấy. Các lane khác giữ luật số một cho tới khi thí
điểm được đánh giá.

### Khuôn L1+ — bảy khối bắt buộc

```markdown
### T-XXX — <hiện trạng đang SAI, không phải việc phải làm>

**Prompt:** `prompt/.../xx-tên-Lx.md` (L?) · **chặn** <task khác, nếu có>

**Goal:**
Xong rồi thì thế giới khác đi thế nào. Một đoạn.

**Nói một câu, việc phải làm là gì:**
Một câu việc phải làm, kèm một câu việc **không** phải làm — chỗ người ta hay làm quá tay.

**Vì sao có task này:**
Gốc rễ, kèm ngày và ai quyết. Nói cả vì sao chỗ này không được sửa trong lần trước.

**Không làm thì mất gì:**
Hậu quả xếp theo mức nặng, mỗi cái gọi tên task hoặc dữ liệu lãnh đủ. Đây là khối
quyết định thứ tự ưu tiên — viết mơ hồ ở đây thì task nằm mãi trong Ready.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở [Vòng chạy một task L1](#vong-chay); ở đây viết **việc cụ thể của task
này** đứng ở đúng bước đó. Bước nào không có gì riêng vẫn phải có một dòng — bỏ trống
là người đọc tưởng mình đọc sót.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).
```

### Ba khối thêm — chỉ khi có thật

| Khối | Thêm khi |
|---|---|
| **Đây là con bug F-XXX** | task là lần lặp lại của một finding đã ghi — nói rõ vì sao vòng rà trước không bắt được |
| **Thứ tự đọc trước khi sửa file đầu tiên** | phải đọc từ ba file trở lên mới hiểu việc |
| **Bẫy hay sửa nhầm nhất** | có chỗ sửa đúng-mà-hỏng; hai tới ba cái, mỗi cái một dòng, danh sách đủ để ở *Constraints* của prompt |

### Khuôn L0 — bốn dòng là đủ

L0 là mức thật, không phải cửa lách: sửa lỗi chính tả, đổi tên máy móc, chạy formatter.
Không bịa thêm khối cho đủ bộ.

```markdown
### T-XXX — <việc>

**Prompt:** `prompt/.../xx-tên-L0.md` (L0)

**Goal:**
Một tới ba dòng.

**Acceptance · Verify:** trong file prompt.
```

### Soát lại trước khi coi entry là viết xong

- [ ] Tiêu đề nói **hiện trạng sai**, không nói cách sửa — để lúc đóng task đọc lại còn biết nó từng hỏng ở đâu.
- [ ] Mỗi dữ kiện có **ngày** và **ai quyết** (CLAUDE.md §7.2).
- [ ] "Đúng N" chỉ dùng khi N là **quyết định** của chủ quán; phép đếm của người viết thì phải kèm mốc thời gian và lời mời bổ sung (F-003).
- [ ] Không có giá, số hotline, sơ đồ hay bảng file/dòng nào bị chép từ nhà thật vào entry (F-001).
- [ ] Mục *Cách hoàn thành* chạy **liền 1→10**, không nhảy cóc.
- [ ] Viết lại đáng kể thì để lại một dòng *nghiêng* cuối entry: ngày, ai yêu cầu, đổi cái gì.

[↑ đầu file](#top)
