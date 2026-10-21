<a id="top"></a>
# Backlog — pha 4 · FE

Mô tả dài của mười hai bước `P4-01`…`P4-12`. Mười một bước admin `P4A-01`…`P4A-11` (đang bị chặn) có sổ riêng:
[`work/backlog_FE_AD.md`](backlog_FE_AD.md) (2026-10-13, T-179, **ADR-103**). Dựng 2026-10-13 (T-178) sau khi chủ repo ký mở pha 4 (T-176) và hỏi
**"backlog của phase 4 đâu"**. Vì sao pha 4 có sổ riêng: `docs/decisions.md` **ADR-036** luật 1 và **ADR-101**;
hình dạng chép của `work/backlog_BE.md` (**ADR-051**).

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Bước nào *Ready*, *In Progress* hay *Done* đọc ở
> `work/backlog.md` — file `scripts/brief.sh` đọc (**ADR-002**).
>
> **Nó không giữ thứ tự, mức, hay đầu ra kiểm chứng được** — ba thứ đó ở
> [`master_plan/FE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/FE_master_plan_banh_cuon_ba_thanh.md) §6.
>
> **Nó không giữ một route hay component nào như sự thật.** Owner ấy ra đời ở `P4-02`, trong
> `docs/product/4-fe/` (`CLAUDE.md` §2, **ADR-035**).

## Ba file, ba việc

| Câu hỏi | Đọc ở |
|---|---|
| Pha 4 nợ gì · thứ tự · mức · đầu ra · cổng sang pha 5 · lời gọi bắt đầu một phiên | [`master_plan/FE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/FE_master_plan_banh_cuon_ba_thanh.md) |
| Bước nào **đang** chạy, xong chưa | [`work/backlog.md`](backlog.md) |
| **Vì sao** có bước này, hỏng thì mất gì, làm thế nào, **xong là thế nào** | **file này** |

## Luật của file này — chép luật của `work/backlog_BE.md`

1. **Mô tả cả mười hai bước viết trước; dòng trạng thái thì không.** Chỉ bước nhận được ngay mới có dòng ở
   *Ready* (**F-012**): hôm nay (2026-10-13) là `P4-01`.
2. **Entry là hồ sơ thực thi duy nhất của bước** (**ADR-051**). *Nghiệm thu* và *Kiểm chứng* vào khối
   **Nhận việc**, chỉ điền khi mọi bước ở *Cần xong trước* đã `Done`.
3. **Bước xong thì entry ở lại đây** và nhận khối **Bàn giao**.
4. **Luật riêng của pha 4 — hai công cụ, app thật.** Claude viết Nghiệm thu và phiếu giao việc
   (`docs/prompt-guideline.md` §6.1); Codex làm trong **worktree riêng**; Claude đọc lại diff thật, chạy lại
   `./scripts/gate.sh` **và chạy app thật cùng backend** đi từng dòng Nghiệm thu — báo cáo của Codex là lời khai,
   không phải bằng chứng (**ADR-054**). Scope khai ở `work/scope/P4-XX.txt` (**ADR-063**).

## Mục lục

| Bước | Entry |
|---|---|
| P4-01 | [Ranh giới, từ vựng và nền của pha 4](#p4-01) |
| P4-02 | [Dựng `fe/` và mở `docs/product/4-fe/`](#p4-02) |
| P4-03 | [Cổng frontend](#p4-03) |
| P4-04 | [Danh tính và khung theo vai](#p4-04) |
| P4-05 | [Trang chủ quán *Menu & giá* — trang thử](#p4-05) |
| P4-06 | [Lớp realtime chung](#p4-06) |
| P4-07 | [Màn quầy — nhận và ghi đơn](#p4-07) |
| P4-08 | [Màn quầy — tiền](#p4-08) |
| P4-09 | [Sản xuất theo mẻ](#p4-09) |
| P4-10 | [Khách — QR tại bàn và đơn web](#p4-10) |
| P4-11 | [Chủ quán — két và ngày bán](#p4-11) |
| P4-12 | [Cổng chất lượng pha 4 và rà ranh giới](#p4-12) |
| P4A-01…P4A-11 | Mảng admin (`P4A-01`…`P4A-03` mở 2026-10-19) — sổ riêng [`backlog_FE_AD.md`](backlog_FE_AD.md) |

**Chỗ đang chặn** — bảng sống ở kế hoạch §4. `P4-04` chờ thiết kế đăng nhập bằng mật khẩu (**ADR-104**, `T-181`); vế giao hàng của `P4-07`
chờ **S-6**. `P4A-01`…`P4A-03` đã mở 2026-10-19; các `P4A-XX` còn lại chờ backend admin có cửa (**ADR-068**), không câu `U-XXX` nào còn chặn bước admin (kế hoạch §6a,
sổ `backlog_FE_AD.md`).

---

<a id="p4-01"></a>
### P4-01 — Năm file hướng dẫn FE đều ghi *đề xuất, chưa chốt*, và mười một bước sau cần một câu trả lời chung

**Phụ thuộc** · bước 1/12 · **cần xong trước:** chủ repo ký mở pha 4 (**đã ký 2026-10-13**, T-176) · **chặn:** mọi bước sau

**Goal:** một ADR là **thước** của pha 4, cùng vai **ADR-082** ở pha 3: mỗi loại màn (trạm chỉ đọc · quầy · chủ
quán · khách) lấy dữ liệu thế nào, ghi xong thì đọc lại thế nào, state nào ở đâu; chốt bốn phần **ADR-100** để mở —
thư viện form, khung test frontend, công cụ sinh type từ `openapi.yaml`, theme và token màu; chốt nền mà `P4-02`
sẽ phải đoán nếu không ai chốt — trình quản lý gói và lockfile, cách trình duyệt gọi backend (cùng origin qua
Next hay khác origin), cách danh tính `X-Person-Id` đi trên luồng SSE của quầy. **Số phiên bản cụ thể không thuộc
bước này** — ADR-100 điểm 3 giao nó cho lượt dựng `fe/` (`P4-02`); `P4-01` chỉ nói *ghim thế nào*.

**Vì sao có task này:** `docs/private/fe/fe_guidance/` có năm file tốt (bốn file `fe-0X` và
`nextjs-16-4-huong-dan-fe.md`) nhưng mỗi mục ghi *đề xuất, chưa chốt*, và `docs/private/` không phải owner. Không có
thước chung thì `P4-05` và `P4-07` mỗi bước tự chọn cách cache — và một màn giữ giá cũ là rủi ro lớn nhất của pha
(kế hoạch §10). Thêm một lý do đo được 2026-10-13 (Claude Code, rà yêu cầu trước khi nhận): hợp đồng chỉ nhận danh
tính qua header `X-Person-Id` (`openapi.yaml` `PersonIdentity`) và `/counter/events` thuộc lớp `quay`, nhưng
`EventSource` của trình duyệt không gửi được header tự đặt, và `be/` không có cấu hình CORS. Nếu đường duy nhất
là đổi hợp đồng thì đó là `F-XXX` gửi về pha 3 ngay bây giờ, không phải phát hiện ở `P4-06`.

**Không làm thì mất gì:** Codex chọn thư viện theo sở thích ở bước đầu tiên chạm tới, các bước sau chép nó;
không ô cổng §9 nào có định nghĩa để ký; màn quầy dựng xong mới biết không nghe được luồng của chính nó.

**Cách hoàn thành:**
1. Đọc kế hoạch §1–§3 · §9; năm file `fe_guidance` (mục *Câu hỏi còn mở* của từng file là danh sách việc);
   `01-hop-dong-api.md` §3 · §5; `openapi.yaml` `PersonIdentity` và hai đường `*/events`; **ADR-097**;
   **ADR-100**; `QC-08` · `QC-09`.
2. Khai `work/scope/P4-01.txt`; chuyển `P4-01` sang *In Progress*.
3. Viết ADR: bảng *loại màn → cách lấy dữ liệu → ghi xong làm gì → mất kết nối bày gì*; state ở đâu (dữ liệu
   server, nháp của người dùng, tên đang chọn); bốn phần mở của ADR-100 và ba phần nền ở *Goal* — mỗi cái một
   dòng lý do, hoặc ghi *hỏi chủ repo* nếu là sở thích; câu nào trong mục *Câu hỏi còn mở* của `fe_guidance`
   không trả lời ở đây thì nói bước nào nhận.
4. Chép các vế stack chủ repo đã chọn (Next.js App Router, TanStack Query, Zustand — ADR-100 điểm 4) sang owner
   pha 4 bằng con trỏ, không chép lại lần hai: `QC-09` đã có; ADR chỉ trỏ vào đó.
5. **Không một dòng code, không một file dưới `fe/` hay `docs/product/4-fe/`** sau lượt này.
6. `./scripts/gate.sh`; tick *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng chép nguyên `fe_guidance` thành ADR — chọn và bác, ghi vì sao. Đừng kèm code mẫu; mười một bước
sau sẽ chép nó. **Đừng kể tên route, component, hook hay query key** — hàng §2 *Route, component* chưa có owner
tới `P4-02` (**ADR-035**); bảng nói theo **nhóm người dùng** và **đường gọi của hợp đồng**, không theo trang.
**Bước này không giao nguyên cho Codex** — đầu ra là ADR, việc của Claude (**ADR-054**); Codex chỉ nhận phần
kiểm kê chỉ đọc nếu được giao.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-13, Claude Code; chủ repo đồng ý cách chia cùng ngày): `docs/decisions.md` (ADR mới +
  dòng bảng tổng hợp; dòng *Còn để mở* của ADR-100 trỏ sang ADR mới) · `master_plan/FE_master_plan_banh_cuon_ba_thanh.md`
  (dòng `P4-01` ở §6; con trỏ ở §10) · `docs/product/2-db/10-quy-uoc-code.md` (`QC-09`: con trỏ hướng dẫn tham
  khảo đang chỉ `docs/private/fe/shared/` — bản chép dự án khác — sửa sang `fe_guidance/`) · `work/backlog.md` ·
  `work/backlog_FE.md` · `work/findings.md` (chỉ khi phải gửi ngược một `F-XXX` về pha 3). Không file nào dưới
  `fe/`, `docs/product/4-fe/`, `docs/product/3-be/` hay `be/`.
  *Chia vai:* Claude viết ADR. Codex (tuỳ chọn, `codex exec -s read-only`, không sửa file) lập bảng kiểm kê: mỗi đề
  xuất trong `fe_guidance` → khớp / lệch với hợp đồng, ADR-097, ADR-100, kèm dòng nguồn. Bảng là đầu vào, không
  phải bằng chứng; Claude đối chiếu lại từng dòng trích.
- *Nghiệm thu* (viết trước khi viết ADR):
  1. Một ADR mới có bảng bốn nhóm người dùng (trạm chỉ đọc · quầy · chủ quán · khách) × bốn cột (cách lấy dữ
     liệu · ghi xong làm gì · mất kết nối bày gì · dữ liệu chạm tiền đọc từ đâu); mỗi ô trỏ một nguồn (ADR-097,
     `01-hop-dong-api.md` §3 · §5, `09-realtime-du-phong.md`) hoặc ghi rõ là lựa chọn của ADR này.
  2. ADR nói **ghi xong thì đọc lại từ backend**, không ghi số vào cache từ phía trình duyệt, và dữ liệu chạm
     tiền không được giữ cũ — kèm tên bước dựng phép chấm điều ấy (`P4-03` hoặc `P4-05`).
  3. ADR nói state ở đâu cho ba loại: dữ liệu server · nháp của người dùng (không mang giá) · tên đang chọn; và
     dọn gì khi đổi người.
  4. Bảy lựa chọn — form · khung test · sinh type · theme/token (bốn phần mở của ADR-100) · trình quản lý gói và
     lockfile · cách gọi backend (origin/proxy) · danh tính trên SSE quầy — mỗi cái **một quyết định và một dòng
     lý do**, hoặc *hỏi chủ repo* có link tới câu hỏi. Danh tính trên SSE: nếu cách chọn cần đổi hợp đồng hoặc
     backend thì có một `F-XXX` gửi về pha 3; nếu không thì ADR nói vì sao không cần.
  5. Mỗi câu ở mục *Câu hỏi còn mở* của năm file `fe_guidance` có chỗ đi: trả lời trong ADR, hoặc tên bước
     `P4-XX` nhận, hoặc `U-XXX` nếu là luật quán.
  6. ADR không có một dòng code mẫu, không tên route · component · hook · query key, không một số phiên bản cụ thể.
  7. Dòng *Còn để mở* của ADR-100 và dòng `P4-01` ở kế hoạch §6 trỏ sang ADR mới; `QC-09` trỏ đúng `fe_guidance/`.
  8. `fe/` và `docs/product/4-fe/` không tồn tại; `./scripts/gate.sh` xanh.
- *Kiểm chứng:* đọc diff theo từng dòng nghiệm thu; `ls -d fe docs/product/4-fe` (cả hai *No such file*);
  `grep -n "^[0-9]\." ` trên mục *Câu hỏi còn mở* của năm file đối chiếu với bảng điểm 5; `./scripts/gate.sh`.

**Bàn giao** (2026-10-13, Claude Code; nhánh `fe_admin`, base `c903709`; chưa commit). **ADR-102** đã chốt, giao cho
phiên. Chia vai: chủ repo bảo Codex làm, Claude kiểm; Codex được giao kiểm kê chỉ đọc (`codex exec -s read-only`) nhưng
hết hạn mức ngay lượt đầu (*usage limit*, mở lại 17:41) trước khi đọc file nào — Claude tự kiểm kê, nên **chưa có
reviewer độc lập**. File đổi: `docs/decisions.md` (ADR-102, dòng bảng tổng hợp, dòng *Còn để mở* của ADR-100) ·
`master_plan/FE_master_plan_banh_cuon_ba_thanh.md` (§6 dòng `P4-01`, §10) · `docs/product/2-db/10-quy-uoc-code.md`
(`QC-09` trỏ ADR-102 và `fe_guidance/`) · file này. Nghiệm thu → bằng chứng: 1 — ADR-102 điểm 1; 2 — điểm 2 · 3 (phép
chấm `P4-03` · `P4-05`); 3 — điểm 4; 4 — điểm 5 · 6 · 7, danh tính SSE không cần `F-XXX` (đo: `be/internal/authz/chon_ten.go`
chỉ đọc header, không CORS dưới `be/`); 5 — điểm 8, đủ 27 câu của năm file; 6 — không khối code, không số phiên bản, chỉ
đường gọi của hợp đồng; 7 — diff ba file trên; 8 — `docs/product/4-fe` không tồn tại, **nhưng `fe/` có một thư mục rỗng
không ai theo dõi** (tạo 12:27 hôm nay, trước phiên này), làm phép kiểm `QC-09` của `db-check` đỏ (*"fe/ có mà không có
fe/package.json"*); mọi gate khác xanh. Phiên không được phép gỡ nó. **Việc tiếp:** chủ repo `rmdir fe`, chạy lại
`./scripts/gate.sh`; xanh thì chuyển `P4-01` sang *Done* và mở `P4-02` ở *Ready*. Tuỳ chọn: Codex rà ADR-102 theo
Nghiệm thu khi có hạn mức.

[↑ đầu file](#top)

---

<a id="p4-02"></a>
### P4-02 — Chưa có `fe/`, chưa có type nào sinh từ hợp đồng, và hàng §2 *Route, component* còn *chưa có owner*

**Phụ thuộc** · bước 2/12 · **cần xong trước:** `P4-01`

**Goal:** khung `fe/` chạy được theo `QC-08` · `QC-09` · **ADR-100** và ADR của `P4-01`: shadcn khởi tạo (chưa
thêm primitive nào ngoài cái một màn mẫu cần), type sinh từ `docs/product/3-be/openapi.yaml`, **một** lớp gọi
API đọc đúng hình lỗi và mã từ chối của hợp đồng, gửi danh tính đúng cách backend đọc (T-143). Mở
`docs/product/4-fe/` với file đầu tiên (cây route, nguồn dữ liệu mỗi màn — để trống từng màn tới bước dựng nó);
hàng *Route, component* của `CLAUDE.md` §2 trỏ file ấy **cùng lượt**; `QC-XX` mới cho frontend ở
`10-quy-uoc-code.md`; gỡ dòng ignore `fe/package.json` của `scripts/check-links.ignore`.

**Không làm thì mất gì:** mỗi màn tự viết `fetch`, tự gõ type, tự đoán lỗi — hợp đồng đổi một trường thì không
ai biết.

**Bẫy:** đừng dựng trang nào ở đây; đừng thêm cả bộ primitive shadcn; đừng gõ tay một type nào của hợp đồng.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-13, Claude Code; chủ repo giao *"hãy đọc kĩ và làm task trên"* — Claude tự dựng, không
  phiếu Codex, nên **chưa có reviewer độc lập**): `fe/` (khung Next.js, shadcn khởi tạo, type sinh, lớp gọi API, tầng
  chuyển tiếp sang backend, một test) · `docs/product/4-fe/` (file đầu tiên) · `docs/product/00-index.md` ·
  `CLAUDE.md` (hàng §2 *Route, component*) · `docs/product/2-db/10-quy-uoc-code.md` (`QC-08` dòng `fe/`, `QC-09`,
  `QC-18` mới) · `scripts/check-links.ignore` (gỡ dòng `fe/package.json`) · `master_plan/FE_master_plan_banh_cuon_ba_thanh.md`
  (§5 con trỏ) · `work/backlog.md` (`P4-01` → *Done*: đã commit `f14f2b1`, thư mục `fe/` rỗng chặn gate nay được
  bước này lấp) · file này · `work/findings.md` (chỉ khi gặp chỗ lệch). **Không** `scripts/verify.sh` hay script cổng
  nào — nối `fe/` vào cổng là `P4-03`; không `docs/product/3-be/` hay `be/`.
- *Nghiệm thu* (viết trước khi dựng):
  1. `fe/` có `package.json` với mọi phụ thuộc ghim **số chính xác** (không `^` `~`), `package-lock.json` của npm,
     `components.json` của shadcn; `npm ci` rồi `npm run build` trong `fe/` thành công.
  2. Type sinh từ `docs/product/3-be/openapi.yaml` bằng openapi-typescript qua **một** lệnh npm; chạy lại lệnh ấy
     trên bản commit thì `git diff` của file sinh rỗng; cạnh lệnh sinh ghi `int64` → số JavaScript (**ADR-102** điểm 5).
  3. Một lớp gọi API (openapi-fetch) duy nhất: đọc lời từ chối theo `Error.code` (không theo status, không theo chữ),
     giữ `field`; phân biệt *backend từ chối kèm mã* · *không có phản hồi* · *phản hồi lạ hình*; gửi `X-Person-Id`
     khi có người đã chọn; danh sách mã đọc từ type sinh, không gõ tay.
  4. Test Vitest gọi lớp API với một lời từ chối mẫu của hợp đồng (`option_combination_invalid` kèm `field`) ra đúng
     mã và trường; thêm ca mã lạ và ca mất phản hồi; `npm test` xanh.
  5. Trình duyệt chỉ gọi server Next; tầng chuyển tiếp không cache, không đệm `text/event-stream`, chuyển nguyên
     `X-Person-Id`; địa chỉ backend là biến môi trường phía server. Chứng minh trên app thật: `GET /menu` và một đường
     có `X-Person-Id` qua Next ra đúng thân backend trả.
  6. Telemetry của Next tắt ngay trong lệnh npm (**ADR-102** điểm 6); không primitive shadcn nào dưới
     `fe/src/components/ui/`; không trang nghiệp vụ nào.
  7. `docs/product/4-fe/` có file đầu tiên (cây route, nguồn dữ liệu mỗi màn để trống tới bước dựng, danh mục
     component rỗng); hàng §2 *Route, component* trỏ file ấy **cùng lượt**; `QC-18` mới có bảng bản ghim và phép kiểm
     in rỗng khi đạt; dòng ignore `fe/package.json` gỡ; `./scripts/gate.sh` xanh.
- *Kiểm chứng:* `cd fe && npm ci && npm run gen:api && git diff --exit-code src/lib/api/schema.d.ts && npm test && npm run lint && npm run build`;
  chạy backend + `npm run start`, `curl` qua cổng Next; khối `sh` của `QC-18` chạy tay in rỗng; `./scripts/gate.sh`.

**Bàn giao** (2026-10-13, Claude Code; nhánh `fe_admin`, base `f14f2b1`; chưa commit; **chưa có reviewer độc lập** —
chủ repo giao thẳng cho Claude, không phiếu Codex). File: `fe/` (mười chín file theo dõi, `node_modules/` · `.next/` bị
`fe/.gitignore` loại) · `docs/product/4-fe/01-khung-fe.md` (mới) · `docs/product/00-index.md` · `CLAUDE.md` (hàng §2) ·
`docs/product/2-db/10-quy-uoc-code.md` (`QC-08` · `QC-09` · `QC-18` mới · bảng §9) · `scripts/check-links.ignore` ·
`master_plan/FE_master_plan_banh_cuon_ba_thanh.md` §5 · `work/backlog.md` (`P4-01` → *Done*, `P4-02` → *Done*, `P4-03`
→ *Ready*) · file này. Nghiệm thu → bằng chứng: 1 — `QC-18` phép kiểm in rỗng (chạy tay và trong `db-check`: *19 khối
kiểm QC*), bốn lỗi cài trên bản chép (dải `^`, telemetry, `cacheComponents`) đều đỏ; `npm ci` · `npm run build` xanh;
2 — `npm run gen:api` chạy lại cho cùng `shasum`; dòng `int64` ở `01-khung-fe.md` §3.1; 3 — `fe/src/lib/api/client.ts`,
mã đọc từ `errorCodeValues` sinh; 4 — `npm test`: *8 passed*; 5 — đo trên backend thật + `next start`, ghi ở
`01-khung-fe.md` §3.2 (cùng `shasum` `GET /menu`, `401`/`403` theo `X-Person-Id`, `hello` của SSE tới sau 0,01 giây,
backend tắt ⇒ `502` kèm header); 6 — ba lệnh Next đặt `NEXT_TELEMETRY_DISABLED=1`, `fe/src/components/` không tồn tại,
trang `/` chỉ giữ chỗ; 7 — `01-khung-fe.md`, hàng §2, dòng ignore gỡ, `./scripts/gate.sh` xanh. Lệch khỏi khung mặc định,
mỗi cái có lý do ở `QC-18`: tắt `cacheComponents` · `partialPrefetching` · `compress` của Next 16.4; bỏ font Geist (tải
từ mạng lúc build, không bộ chữ tiếng Việt); không `AGENTS.md` của `create-next-app` (luật AI chỉ ở `CLAUDE.md`).
`npm audit`: 9 mức cao, **tất cả trong công cụ dev** (lint, CLI shadcn — gốc `braces`), `npm audit --omit=dev` = 0;
không nâng vì bản sửa là hạ `eslint-config-next` về 14. Gate 1d từng đỏ vì đường dẫn file sinh trong `QC-18` khớp mẫu
route — viết lại câu, trỏ sang `01-khung-fe.md`. **Việc tiếp:** `P4-03` nối `fe/` vào cổng (so file sinh với hợp
đồng, lint, kiểu, test, hai phép chặn). Tuỳ chọn: Codex rà diff này theo Nghiệm thu.

[↑ đầu file](#top)

---

<a id="p4-03"></a>
### P4-03 — `./scripts/gate.sh` không biết gì về frontend

**Phụ thuộc** · bước 3/12 · **cần xong trước:** `P4-02`

**Goal:** `scripts/verify.sh` gọi một bước kiểm `fe/` khi `fe/` hoặc `openapi.yaml` đổi: lint, kiểm kiểu, test,
và **type sinh lại lệch bản commit ⇒ đỏ** (cùng hình `scripts/check-sqlcgen.sh`). Hai phép chặn: **cộng tiền ở
`fe/`** và **import một bộ UI ngoài shadcn** (ADR-100). Mỗi phép chặn có ca hồi quy trong một `scripts/*.test.sh`
chứng minh nó biết đỏ.

**Không làm thì mất gì:** Gate 1 in `SKIP` cho mọi lượt chỉ đổi `fe/`, và báo cáo *đã xong* của mọi bước sau không
có bằng chứng (`CLAUDE.md` §5).

**Bẫy:** phép chặn tiền theo mẫu chữ sẽ có ca lọt — ghi rõ giới hạn trong header của script, phần còn lại là mắt
người ở Gate 4.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-14, Claude Code; chủ repo chọn *"Gỡ chặn theo thứ tự"* để đi tới `P4A-01`…`P4A-03` — Claude
  thiết kế, viết test hồi quy trước, Codex thi công trong worktree `../lean_wt/P4-03`, Claude duyệt): `scripts/check-fe-rules.sh`
  (mới, chỉ đọc file) · `scripts/check-fe-rules.test.sh` (mới, **Claude viết trước**) · `scripts/fe-check.sh` (mới, chạy
  npm) · `scripts/fe-check.test.sh` (mới) · `scripts/verify.sh` (nối hai script) · `docs/product/2-db/10-quy-uoc-code.md`
  (`QC-18`: câu *nối `fe/` là `P4-03`* thành lệnh thật) · `docs/product/4-fe/01-khung-fe.md` (con trỏ tới cổng) ·
  `CLAUDE.md` §5 bước 9 (một vế) · `work/backlog.md` · file này. **Không** sửa `fe/src/` hay `fe/package.json` trừ khi cổng
  đỏ trên code thật — khi ấy dừng và báo; không `be/`, không `docs/product/3-be/`.
- *Nghiệm thu* (viết trước khi dựng):
  1. `scripts/check-fe-rules.sh` (đổi gốc bằng `FE_RULES_DIR`, mặc định `fe`) đọc mọi `.ts` `.tsx` `.js` `.jsx` `.mjs`
     `.cjs` và `package.json` dưới gốc ấy, trừ `node_modules/` `.next/` và file sinh `src/lib/api/schema.ts`; in
     `<đường dẫn tương đối>:<dòng>: <luật>: …` cho mỗi vi phạm, dòng cuối `check-fe-rules: PASS` (exit 0) hoặc
     `check-fe-rules: FAIL — …` (exit 1). Bốn luật: `cong-tien` (toán tử số học có toán hạng mang tên tiền, kể cả
     `reduce` cộng dồn) · `bo-ui-ngoai` (import hay phụ thuộc thư viện UI ngoài shadcn, **ADR-100**) · `cache-next`
     (`"use cache"`, `unstable_cache`, `cacheLife`, `cacheTag`, `export const revalidate`, `force-static`, `force-cache`,
     `next: { revalidate }` — **ADR-102** điểm 3a) · `ghi-tay-cache` (`setQueryData`, `setQueriesData` — **ADR-102**
     điểm 2 · 3b). Chú thích không bao giờ tính; header ghi rõ ca lọt của `cong-tien`.
  2. `scripts/check-fe-rules.test.sh` (Claude viết trước, Codex **không sửa ca nào**) xanh; mỗi luật có ít nhất một ca đỏ
     và một ca xanh gần giống.
  3. `scripts/fe-check.sh`: trong `fe/` cài đúng lockfile khi chưa cài (`npm ci`), rồi `npm run lint` · `npm run
     typecheck` · `npm test` · `npm run build`; **sinh lại type vào thư mục tạm và so với `src/lib/api/schema.ts`** đã
     commit — lệch ⇒ đỏ, in lệnh sửa (`npm run gen:api`); không sửa `fe/`. Đổi gốc cho test bằng biến môi trường.
  4. `scripts/fe-check.test.sh` chứng minh phép so type biết đỏ: bản chép `openapi.yaml` thêm một đường gọi ⇒ đỏ; bản
     thật ⇒ xanh; không mạng. Khi `fe/node_modules` chưa có, test in rõ lý do và không giả là đã chạy ca đỏ.
  5. `scripts/verify.sh`: khi có `fe/package.json` luôn chạy `check-fe-rules.sh`; chạy `fe-check.sh` khi lượt đổi gì
     dưới `fe/`, `docs/product/3-be/openapi.yaml` hay hai script ấy (cùng hình nhánh `be-check`); header ghi điều ấy.
  6. Trên code thật của `fe/`: `check-fe-rules.sh` PASS, `fe-check.sh` xanh; mỗi luật cài lỗi trong **worktree riêng**
     (`quality/review-gate.md` Gate 1, luật T-167) ⇒ `./scripts/gate.sh` đỏ, gỡ ⇒ xanh.
  7. `QC-18` và `01-khung-fe.md` trỏ tới hai script; `CLAUDE.md` §5 bước 9 nêu `fe-check.sh`; `./scripts/gate.sh` xanh.
- *Kiểm chứng:* `./scripts/check-fe-rules.test.sh` · `./scripts/fe-check.test.sh` · `./scripts/fe-check.sh` ·
  bốn lỗi cài (một mỗi luật) + một lỗi lệch type trong worktree riêng, mỗi cái `./scripts/gate.sh` đỏ · `./scripts/gate.sh`
  xanh ở clone chính sau tích hợp.

**Bàn giao** (2026-10-14; thực hiện: Codex — `check-fe-rules.sh` · `fe-check.sh` · `fe-check.test.sh` · `verify.sh`, worktree
`../lean_wt/P4-03` nhánh `codex/P4-03` base `b55737b`, một lượt; Claude viết `check-fe-rules.test.sh` trước, duyệt, sửa
luật `cong-tien`, cài lỗi và tích hợp vào `fe_admin`; chưa commit). File: `scripts/check-fe-rules.sh` ·
`scripts/check-fe-rules.test.sh` · `scripts/fe-check.sh` · `scripts/fe-check.test.sh` (bốn file mới) · `scripts/verify.sh` ·
`docs/product/2-db/10-quy-uoc-code.md` (`QC-09` · `QC-18`) · `docs/product/4-fe/01-khung-fe.md` §3.1 · `CLAUDE.md` §5 bước 9 ·
`work/backlog.md` · file này. Nghiệm thu → bằng chứng: 1 · 2 — `check-fe-rules.test.sh` *OK* (hash không đổi qua lượt
Codex; Claude thêm hai ca sau duyệt); 3 — `fe-check.sh` ngoài sandbox: *apigen PASS*, *8 passed*, *Compiled successfully*,
*fe-check: PASS*; 4 — `fe-check.test.sh`: bản thật exit 0, bản thêm đường gọi exit 1; 5 — `verify.sh` in `[fe]
scripts/check-fe-rules.sh` rồi `[fe] scripts/fe-check.sh`; 6 — trong worktree: bốn lỗi cài vào `fe/src/lib/` ⇒ mỗi luật
đỏ đúng tên, gỡ ⇒ PASS; `verify.sh` với `p.price + 1` ⇒ exit 1, với một dòng thêm vào `schema.ts` ⇒ exit 1 *type sinh
lệch hợp đồng*; 7 — `./scripts/gate.sh` ở clone chính: *không cổng nào đỏ* (db-check chạy trên Docker vì lượt đổi
`docs/product/2-db/`). **Lỗi duyệt bắt được:** luật `cong-tien` của Codex khớp tên tiền theo chuỗi con và cho tên bắt
đầu giữa từ — `feedbackCount + 1`, `patientIndex - 1`, `coffeeSize * 2`, `giaiDoan + 1` đều đỏ nhầm; Claude sửa thành
khớp theo đoạn camelCase/snake_case và neo đầu tên, thêm ca `money_ok_word_parts` · `money_segment_snake`. Ca nhầm còn
lại, ghi ở header: tên có đoạn `total` mà không phải tiền (`totalPages`). Trong sandbox Codex, `next build` không mở được
cổng và `go vet` không ghi được cache — Claude chạy lại ngoài sandbox. **Việc tiếp:** `P4-04`.

[↑ đầu file](#top)

---

<a id="p4-04"></a>
### P4-04 — Mọi cửa đều cần biết *ai bấm* và *đang đứng đâu*, mà chưa màn nào hỏi

**Phụ thuộc** · bước 4/12 · **cần xong trước:** `P4-03` · backend đăng nhập `T-190` (lát (c) của **ADR-109** điểm 12).
*Viết lại 2026-10-14 (Claude Code, T-191 cùng phiên):* luật *chọn tên* (T-143, U-075) bị thay bởi tài khoản mật khẩu riêng
(U-083, **ADR-104**); thiết kế đăng nhập **ADR-109** đã duyệt — Goal cũ bỏ.

**Goal:** màn **đăng ký** (tên đăng nhập, Gmail, tên hiển thị, mật khẩu ≥ 8) báo *chờ chủ quán duyệt*; màn **đăng nhập**
có lựa chọn *đăng nhập tại quầy* (mốc `C36` — backend mở trực quầy); **đăng xuất**; **quên mật khẩu** (nhập Gmail, máy
luôn nói cùng một câu) và **đặt lại** bằng mã trong thư; **đổi mật khẩu**, bắt buộc khi `must_change_password`. Sau đăng
nhập, khung chọn theo `GET /sessions/current`: cờ chủ quán ⇒ khung chủ quán; vai `quay` ⇒ khung quầy; vai trạm ⇒ khung
trạm (chỉ đọc); khách không đăng nhập. Nút hiện theo lớp quyền của [`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md)
nhưng **backend vẫn là người chặn**. Tầng chuyển tiếp `/api` mang `cookie` và `origin` lên, `set-cookie` về, thôi mang
`X-Person-Id`; lớp gọi API bỏ tuỳ chọn `personId`. Đổi người (đăng xuất, phiên hết hạn ⇒ 401) xoá sạch cache của người
trước (**ADR-102**).

**Acceptance:**
1. Test đỏ viết trước `fe/src/app/api/[...path]/route.test.ts` (Claude) xanh, không sửa điều kiện kiểm.
2. Test component cho từng màn: đăng ký, đăng nhập (có và không *tại quầy*), quên · đặt lại, đổi mật khẩu bắt buộc, khung
   theo vai; mỗi lời từ chối của hợp đồng (`invalid_credentials`, `login_temporarily_blocked`, `username_taken`,
   `email_taken`, `password_too_short`, `reset_token_invalid`) có chữ riêng, chọn theo `code`.
3. `schema.ts` sinh lại từ hợp đồng của `T-190`; `grep -rn "X-Person-Id\|personId" fe/src` chỉ còn trong file test.
4. Chạy thật: đăng ký → chủ quán duyệt (lệnh khởi tạo chủ quán) → đăng nhập tại quầy → `GET /counter-duty/current` ra
   đúng người → đăng xuất khép trực; dán output.
5. `./scripts/gate.sh` xanh (`fe-check`).

**Không làm thì mất gì:** trang thử `P4-05` không gọi được cửa nào (mọi cửa menu là lớp `chu_quan`).

**Bẫy:** đừng viết lại luật quyền ở frontend thành bảng thứ hai — đọc lớp của cửa từ một chỗ; ma trận lệch là
lỗi của cổng §9 ô bảy. Đừng cất mã phiên ở `localStorage` hay state — cookie `HttpOnly` là chỗ duy nhất. Đừng báo
*Gmail không tồn tại* ở màn quên mật khẩu.

**Nhận việc** — 2026-10-14 · thực hiện và duyệt: **Claude Code** (Codex hết hạn mức tới 21:39; chủ repo: *"bạn có thể
sửa theo ý mình tôi cho phép"*) — **chưa review độc lập** · nhánh `fe_admin`, trên `1ead504` cộng `T-190` chưa commit.
Đã làm: tầng chuyển tiếp mang `Cookie` · `Origin` lên, mọi `Set-Cookie` về, thôi `X-Person-Id`; `createApi` bỏ `personId`;
`ApiProvider` (một client + một QueryClient); `usePhien` · `useDangNhap` · `useDangXuat`; năm màn `/dang-nhap` · `/dang-ky` ·
`/quen-mat-khau` (gồm đặt lại bằng mã) · `/doi-mat-khau`; khung `/quay` · `/chu-quan` · `/tram` có gác và đăng xuất; dòng
route · component ở `docs/product/4-fe/01-khung-fe.md`. *Claude chốt:* thư chỉ mang mã (không đường dẫn) ⇒ màn đặt lại có ô
nhập mã; vào nhầm khung thì đưa về khung của mình; khung chỉ là tiện — backend vẫn chặn.

*Nghiệm thu → bằng chứng* (2026-10-14):
1. `route.test.ts` (Claude viết trước, ba ca đỏ đúng lý do) → xanh, điều kiện không đổi.
2. `tai-khoan.test.tsx` 11 ca + `khung.test.ts` 8 ca: tại quầy / ngoài quầy / mật khẩu tạm / `invalid_credentials` /
   `login_temporarily_blocked` / quên mật khẩu cùng một câu / `reset_token_invalid` / 401 ⇒ đăng nhập / nhầm khung / đăng
   xuất; mỗi mã của sáu mã có trong hợp đồng và có chữ riêng — `Tests 40 passed (40)`.
3. `schema.ts` sinh từ hợp đồng 0.24.0 (cùng `T-190`); `grep X-Person-Id fe/src` chỉ còn trong test kiểm nó không được gửi.
4. Chạy thật (database dùng-xong-bỏ, backend thật, `next dev`, curl qua `/api`): đăng ký `201 cho_duyet` → đăng nhập khi
   chưa duyệt `401 invalid_credentials` → lệnh khởi tạo `account_id=1 status=hoat_dong` → chủ quán đăng nhập `201`, cookie
   `#HttpOnly_localhost` → duyệt `200 hoat_dong` → Lan đăng nhập tại quầy `201 counter_duty_id=1` → `GET /counter-duty/current`
   ra Lan → Origin lạ `403 cross_origin_write` → đăng xuất `200` → phiên `401`, quầy trống → `X-Person-Id: 1` `401`; database:
   `Lan|t|t|dang_xuat` (mốc mở phiên = mốc trực, khép cùng lúc).
5. `./scripts/gate.sh` — xem bàn giao cuối phiên.

*Sửa sau duyệt* (2026-10-15, chủ repo: *"yêu cầu fe dung shadcn đã có các componenent có sẵn"*; Claude Code): bản trên tự
viết ô nhập, nút, nhãn, ô chọn — trái **ADR-100** điểm 2, `fe/src/components/ui/` còn trống. Thêm bằng CLI ghim
(`npx shadcn add`, bản 4.21.4) tám primitive `button` · `input` · `label` · `checkbox` · `field` · `card` · `alert` ·
`separator`; `khung-form.tsx` và khung theo vai ghép lại từ chúng, ô *Đăng nhập tại quầy* nối qua `Controller`;
`vitest.setup.ts` giả `ResizeObserver` cho jsdom (Checkbox của Radix gọi nó). Không đổi hành vi: cùng 40 ca, `Tests 40
passed (40)`; lint, kiểm kiểu sạch. `check-fe-rules.sh` chưa bắt primitive tự viết — mới hỏng một lần, chưa thêm luật.



[↑ đầu file](#top)

---

<a id="p4-05"></a>
### P4-05 — Trang thử: chủ quán xem và sửa menu, giá

**Phụ thuộc** · bước 5/12 · **cần xong trước:** `P4-04`

**Goal:** trang đầu tiên chạm tiền, theo yêu cầu chủ repo (*"build page product với crud trước"*). Phạm vi đọc từ
cửa, không từ chữ *CRUD* (kế hoạch §7): **xem** menu (`GET /menu`), **đổi giá gốc thành phần**, **đổi phụ thu**,
**đổi số lượng thành phần suất** — ba cửa cùng bắt lý do — và **ngừng bán**. Lời nhắc *đang trong giờ bán* trước
khi đổi thành phần suất ([`03-ham-gia.md`](../docs/product/3-be/03-ham-gia.md) §4). Ghi xong thì **đọc lại** menu;
mọi số hiện là số backend trả. Xong thì rút **khuôn** (bảng, hộp thoại sửa có lý do, bày lời từ chối, query key)
vào `docs/product/4-fe/` cho mọi trang sau.

**Khuôn phải có thêm** (giao 2026-10-19, `T-202` — **ADR-102** *Sửa đổi*): (1) **kiểm accessibility** theo `fe-04`
§5 · §7.5 — lỗi ô gắn `aria-describedby`, focus vào và trả về của hộp thoại, cỡ chạm; (2) **ba kiểu chỉ báo tải**
(`fe-02` §1 · §2): khung xương lần đọc đầu · spinner trên nút khi ghi · chỉ báo nhỏ khi đọc lại mà vẫn giữ bản cũ;
(3) **chặn bấm gửi hai lần** cho lệnh ghi của người quán (`fe-02` §3): nút tắt ngay từ lần bấm đầu tới khi có kết quả,
một ca test bấm hai lần ⇒ một lời gọi.

**Không làm thì mất gì:** khuôn của mọi màn sau được rút từ một màn chưa ai duyệt chạm tiền.

**Bẫy:** không nút *thêm món*, không nút *xoá* — không có cửa (kế hoạch §7). Không cộng giá để *xem trước* ở
trình duyệt; cần xem trước thì gọi tính thử.

**Nhận việc** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-05`, nhánh
`codex/P4-05`, base `0b42889`), theo lời chủ repo *"hãy làm tất cả task trên yêu cầu codex làm bạn kiểm tra"*. **Claude chốt:** route
`/chu-quan/menu-gia`, mục *Menu & giá* sau *Sản phẩm*; thành phần đọc bằng `POST /price-quotes` một lần mỗi món với tổ hợp đầu tiên
backend kê (hợp đồng không có đường đọc thành phần, và pha 4 không đổi hợp đồng — kế hoạch §9); phụ thu từ `GET /option-groups`; bốn lệnh
mở trong `Dialog` shadcn (thêm bằng CLI ghim); lời nhắc giờ bán **luôn** hiện trước khi đổi số lượng vì không có đường đọc giờ bán (suy
ra, chờ chủ repo); đường đọc gặp `no_response` không thử lại ngầm.

*Nghiệm thu* (viết trước, 2026-10-20):
1. `fe/src/app/chu-quan/menu-gia/menu-gia.test.tsx` (Claude viết trước, 26 ca, đỏ vì chưa có trang) và `chu-quan.test.tsx` (thêm mục
   điều hướng) xanh, **không** sửa điều kiện kiểm: thứ tự backend; giá · thành phần · phụ thu là số backend; không nút thêm · xoá; khung
   xương; đọc lỗi; tính thử một món lỗi; bốn lệnh đúng thân; lý do bắt buộc với `aria-describedby`; ô số sai không gửi; `field` gắn đúng
   ô; `*_not_found` · `menu_item_discontinued` đọc lại; mất phản hồi không gửi lại; bấm hai lần một lệnh; Huỷ · Esc trả focus; *Đang
   cập nhật…*; đọc lại lỗi sau ghi.
2. `check-fe-rules` xanh; `grep setQueryData|refetchInterval` dưới `fe/src/app/chu-quan` (trừ test) rỗng.
3. `npm run build` xong, có `/chu-quan/menu-gia`.
4. Chạy thật trên trình duyệt cùng backend (Claude): chủ quán đổi giá ⇒ màn hiện số mới **không tải lại trang** (ADR-102 điểm 3).
5. Khuôn rút vào `docs/product/4-fe/01-khung-fe.md` §6; dòng §1 · §2 · §4.
6. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** `gpt-6-astra`; test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File:
`menu-gia/page.tsx` · `_components/menu-gia.tsx` · `_components/du-lieu-menu-gia.ts` · `_components/hop-thoai-sua-co-ly-do.tsx` ·
`_components/muc-chu-quan.ts` · `fe/src/components/ui/dialog.tsx` (Claude, shadcn CLI) · `menu-gia/menu-gia.test.tsx` (Claude) ·
`chu-quan.test.tsx` (Claude); owner `01-khung-fe.md` §1 · §2 · §3.1 · §4 · §6.
*Nghiệm thu → bằng chứng:*
1. `menu-gia.test.tsx` 26/26; md5 trước và sau khi Codex làm trùng nhau (`7de08404…`). Codex chỉ ra **lỗi test của Claude**: ca *Tổng
   quan* đếm cứng 12 liên kết — Claude sửa thành 13 (không phải điều kiện của P4-05). Test có răng: Claude bỏ bước đọc lại sau ghi ⇒
   `7 failed | 19 passed`; trả lại ⇒ xanh. **Claude sửa khi duyệt:** chữ lời nhắc giờ bán, nhãn *Giá* cho món không lựa chọn, chú thích
   đầu ba file.
2. `check-fe-rules: PASS`; grep rỗng.
3. Codex: `npm run build -- --webpack` có `○ /chu-quan/menu-gia` (Turbopack bị sandbox chặn mở cổng); `npm run build` ở clone chính qua gate.
4. Chạy thật (database dùng-xong-bỏ có dữ liệu mồi, backend thật, `next dev`, Chromium điều khiển bằng Playwright): đăng nhập chủ quán ⇒
   `/chu-quan`; *Giò bán rời* trước `Giò × 1 · 9.000đ`, giá bán `9.000đ`; thiếu lý do ⇒ ô `aria-invalid=true`, *Nhập lý do.*; đổi giá
   gốc *Giò* thành `11.000đ` ⇒ thành phần `11.000đ`, giá bán `11.000đ` (số backend tính lại), cờ đặt trước khi đổi vẫn còn ⇒ **không tải
   lại trang**; focus về nút *Đổi giá gốc Giò*; ngừng bán *Canh bánh cuốn* ⇒ món biến khỏi màn.
5. `01-khung-fe.md` §1 · §2 · §3.1 · §4 · §6.
6. Gate ở clone chính — khối bàn giao cuối phiên.
Còn lại: lời nhắc giờ bán luôn hiện là suy ra (chờ chủ repo); đổi giá gốc thành phần dùng chung (vd *Giò*) đổi giá mọi món mang nó — màn
chưa nói điều ấy trong hộp thoại.

[↑ đầu file](#top)

---

<a id="p4-06"></a>
### P4-06 — SSE chỉ báo *đọc lại*, và mọi màn sống phải tự kéo khi luồng đứt

**Phụ thuộc** · bước 6/12 · **cần xong trước:** `P4-04`

**Goal:** một lớp chung theo **ADR-097** và [`09-realtime-du-phong.md`](../docs/product/3-be/09-realtime-du-phong.md):
nghe luồng, nhận tín hiệu thì đọc lại đúng query, tự kéo theo `poll_interval_seconds` backend trả, **banner mất
kết nối luôn nhìn thấy** (màn trạm: không nút đóng). **Nhiều tab cùng máy** (giao 2026-10-19, `T-202` — **ADR-102**
*Sửa đổi*): đăng xuất hay đổi người ở một tab thì tab kia của cùng trình duyệt xoá cache và về màn đăng nhập ngay, không
đợi tới lần gọi trả 401; có test.

**Không làm thì mất gì:** quầy tưởng không có đơn mới trong khi luồng đã đứt từ lâu.

**Nhận việc** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-06`, nhánh
`codex/P4-06`, base `0b42889`), theo lời chủ repo *"hãy làm tất cả task trên yêu cầu codex làm bạn kiểm tra"*. **Claude chốt:** một module
`fe/src/lib/realtime/tin-hieu.tsx`; luồng mở qua client API (fetch đọc luồng) cho cả hai luồng; tín hiệu làm mất hiệu lực **mọi** query;
ngưỡng im 25 giây, nối lại 1–10 giây; banner không nút; luồng ở **layout** `/quay` · `/tram` (dời `KhungTheoVai` khỏi trang con);
nhiều tab qua `BroadcastChannel`.

*Nghiệm thu* (viết trước, 2026-10-20):
1. `fe/src/lib/realtime/realtime.test.tsx` (16 ca) · `fe/src/lib/auth/nhieu-tab.test.tsx` (4 ca) do Claude viết trước, đỏ vì chưa có code,
   và `fe/src/app/quay/quay.test.tsx` (Claude bọc layout) xanh, **không** sửa điều kiện kiểm.
2. `check-fe-rules` xanh; `grep EventSource|setQueryData` dưới `fe/src` (trừ test) rỗng.
3. Chạy thật cùng backend qua Next: luồng không đệm; tắt · bật backend ⇒ banner rồi tự nối và đọc lại; đóng tab quầy ⇒ backend thấy luồng
   đóng; hai tab: đăng xuất một tab ⇒ tab kia về `/dang-nhap`.
4. `01-khung-fe.md` §1 · §3.3 · §4.
5. `./scripts/gate.sh` xanh, có `fe-check: PASS`.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** `gpt-6-astra`; test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File:
`fe/src/lib/realtime/tin-hieu.tsx` · `fe/src/app/quay/layout.tsx` · `fe/src/app/tram/layout.tsx` · `quay/page.tsx` · `quay/giao-viec/page.tsx` ·
`quay/dao-tao/page.tsx` · `tram/page.tsx` · `fe/src/lib/auth/session.ts` · `fe/src/components/tai-khoan/khung-theo-vai.tsx`; test của Claude:
`realtime.test.tsx` · `nhieu-tab.test.tsx` · `quay.test.tsx`; owner `01-khung-fe.md`.
*Nghiệm thu → bằng chứng:*
1. `Tests 301 passed (301)` ở worktree; md5 ba file test trước và sau khi Codex làm trùng nhau. Test có răng: Claude bỏ lệnh đọc lại khi có
   tín hiệu ⇒ `2 failed | 12 passed`; trả lại ⇒ xanh. **Claude sửa khi duyệt:** chú thích đầu ba file.
2. `check-fe-rules: PASS`; grep rỗng.
3. Chạy thật — dán ở `01-khung-fe.md` §3.3: `hello` qua Next sau 29 ms; đơn web khi tab quầy mở `201`; tắt backend ⇒ *Mất kết nối trực
   tiếp. Đang tự nối lại.*; bật lại ⇒ nối thêm 1 lần, đọc lại 1 lần, banner tắt; đóng tab quầy ⇒ `409 {"code":"shop_not_seeing_orders"}`;
   đăng xuất tab A ⇒ tab B `/dang-nhap` sau 168 ms.
4. `01-khung-fe.md` §1 (hai layout) · §3.3 · §4.
5. Gate ở clone chính — khối bàn giao cuối phiên.
Còn lại: màn quầy · trạm chưa trải `tuyChonKeo()` — việc của `P4-07` · `P4-09`.

[↑ đầu file](#top)

---

<a id="p4-07"></a>
### P4-07 — Màn quầy: nhận và ghi đơn

**Phụ thuộc** · bước 7/12 · **cần xong trước:** `P4-05` · `P4-06` (U-080 đóng 2026-10-14: đơn web báo về quầy bằng SSE, không Telegram)

**Goal:** hàng đợi quầy, duyệt · từ chối đơn chờ, POS tạo lượt gọi, đơn điện thoại, nhả đơn hẹn; vế giao hàng
bày lời từ chối của **S-6** tới khi có lời. Chẻ tiếp lúc nhận nếu một phiên không đủ.

**Nhận việc** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-07`, nhánh
`codex/P4-07`, base `0b42889` + nền chưa commit của `T-213` · `P4-05` · `P4-06` đặt trong index), theo lời chủ repo *"hãy làm tất cả task trên"*.
**Chẻ lúc nhận** (kế hoạch §6: bước to chẻ nếu một phiên không đủ): **đợt một** — hàng chờ quầy, duyệt · từ chối, tạm dừng · quán mù kèm
*Mở lại nhận đơn* (quầy cần để hết mù — `09-realtime-du-phong.md` §2), đơn hẹn và máy quầy tự nhả; **đợt hai** — soạn lượt gọi POS
(`POST /table-orders`) và đơn điện thoại (`POST /phone-orders`), dùng chung bộ soạn món với `P4-10`. **Thiếu ở hợp đồng** (F-074): hàng
chờ không trả món của đơn; không đường đọc đơn đang làm nên *rời quán* chưa có chỗ đặt.

*Nghiệm thu đợt một* (viết trước): (1) `fe/src/app/quay/hang-cho.test.tsx` (Claude, 14 ca) xanh không sửa; test cũ `quay.test.tsx` ·
`realtime.test.tsx` xanh; (2) `check-fe-rules` xanh; (3) chạy thật: đơn web về hàng chờ qua SSE không tải lại, duyệt ⇒ việc xuống trạm;
(4) `01-khung-fe.md` §1 · §2 · §4; (5) gate xanh.

**Bàn giao đợt một** — 2026-10-20 · thực hiện: **Codex** `gpt-6-astra`; test trước và duyệt: **Claude Code**. Nhánh `P4A-01`. File:
`fe/src/app/quay/_components/hang-cho.tsx` · `du-lieu-hang-cho.ts` · `tu-nha-don-hen.tsx` · `quay/page.tsx` · `quay/layout.tsx`;
`quay/hang-cho.test.tsx` (Claude). *Bằng chứng:* (1) md5 test trước = sau (`9e20ac7c…`); worktree `340 passed`. (3) Chạy thật (database
dùng-xong-bỏ, backend thật, `next dev`, Chromium): POS đứng quầy mở `/quay` ⇒ đơn web `201` hiện ở hàng chờ sau 39 ms, cờ không tải lại
còn; nội dung *Giao tận nơi · Tạo lúc 09:38 · 0903333333*; *Duyệt đơn 1* ⇒ *Đã duyệt đơn 1.*, đơn rời hàng chờ; trạm thấy việc của đơn 1.
(4) owner đã ghi. (5) gate — khối bàn giao cuối phiên. **Còn lại:** đợt hai; F-074.

**Nhận đợt hai** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-07b`, nhánh
`codex/P4-07b`, base `eab46bb` + nền chưa commit của `T-218` đặt trong index), theo lời chủ repo *"còn gì chưa làm thì bạn yêu cầu codex làm
nốt"*. F-074 đã sửa ở `T-218` nên hợp đồng đủ. **Claude chốt hình màn** (không phải luật quán): hàng chờ bày `lines` · `total_vnd` của từng
đơn chờ; mục *Đơn đang làm* bày `active_orders`, nút *Rời quán* chỉ ở đơn `door_delivery` `in_progress`; `/quay/goi-mon` soạn lượt gọi
(`POST /table-orders`: chọn bàn, món, một lựa chọn mỗi nhóm — chọn sẵn `is_default`, số lượng, *Mang về*); `/quay/dien-thoai` soạn đơn
điện thoại (`POST /phone-orders`: cách trao, số điện thoại, địa chỉ khi giao tận nơi, giờ cần hàng đọc theo giờ quán, tên, ghi chú). Bộ
soạn món dùng chung cho `P4-10`; giá dòng là `menu.prices` backend trả, tổng chỉ là `total_vnd` sau khi gửi. **Combo ở bộ soạn để lượt sau.**

*Nghiệm thu đợt hai* (viết trước): (1) `fe/src/app/quay/goi-mon.test.tsx` (Claude, 12 ca) xanh không sửa; `hang-cho.test.tsx` ·
`quay.test.tsx` · `realtime.test.tsx` xanh; (2) `check-fe-rules` xanh; (3) chạy thật: POS tạo lượt gọi một bàn và một đơn điện thoại giao
tận nơi qua màn, backend thật, việc xuống trạm; đơn ấy hiện ở *Đơn đang làm*; (4) `01-khung-fe.md` §1 · §2 · §4; (5) gate xanh.

**Bàn giao đợt hai** — 2026-10-21 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4-07b`); test trước, duyệt và tích hợp:
**Claude Code**, nhánh `P4A-01`. File: `quay/_components/hang-cho.tsx` · `du-lieu-hang-cho.ts` · `quay/page.tsx` · mới `soan-don.tsx` ·
`du-lieu-soan-don.ts` · `quay/goi-mon/page.tsx` · `quay/dien-thoai/page.tsx` · `components/shared/bo-soan-mon.tsx` · `dong-mon-da-ghi.tsx` ·
`01-khung-fe.md` §1 · §2 · §4 (Claude gộp tay cạnh dòng `P4-09`); `quay/goi-mon.test.tsx` (Claude). **Claude sửa lúc duyệt:** (a) dòng
`coGia` của test đổi regex sang so chuỗi cùng nghĩa — `check-fe-rules` đọc `|` trong regex literal là phép tính với tên tiền; (b) chạy thật
cho thấy rời quán đơn giao tận nơi bị backend từ chối `delivery_served_mark_undecided` (**S-6** chưa có lời, kế hoạch pha 4 §5: màn bày lời
ấy) ⇒ `loiHangCho` thêm câu *Chưa rời quán được: quán chưa chốt lúc nào ghi món đã ra…* và một ca test. *Bằng chứng:* (1) 13 ca
`goi-mon.test.tsx` xanh; clone chính `379 passed` trước ca S-6, test quầy `52 passed` sau; `tsc` · `lint` sạch; (2) `check-fe-rules: PASS`;
(3) chạy thật 2026-10-21 (database dùng-xong-bỏ `p409run`, backend thật, `next dev`, Chromium): *Gọi món tại bàn* bàn 5 · *Suất giò* ⇒
*Đã gửi lượt gọi 5 · tổng 25.000đ*, trạm thêm 10 việc; *Đơn điện thoại* giao tận nơi cần hàng sau 10 phút ⇒ *Đã tạo đơn 4 · tổng 25.000đ*,
đơn nổ ngay, hiện ở *Đơn đang làm 4* kèm địa chỉ, món, tổng, *10 việc chưa ra bàn* và nút *Rời quán đơn 4*; bấm ⇒ câu S-6 ở trên;
(4) đã ghi; (5) gate dưới. **Còn lại (ngoài đợt này):** ~~bộ soạn chưa soạn combo và chưa xét `prerequisite_option_ids`~~ — xong ở
`T-221` 2026-10-21 ([chi tiết](backlog.md#t-221)); rời quán đơn giao chờ **S-6**.

[↑ đầu file](#top)

---

<a id="p4-08"></a>
### P4-08 — Màn quầy: tiền

**Phụ thuộc** · bước 8/12 · **cần xong trước:** `P4-07`

**Goal:** tính tiền phiên, đóng phiên, trao tại quầy, giao xong, hoàn, thu nợ, trả trước, trả lại; giảm giá cả đơn
chỉ hiện cho chủ quán (**ADR-098**). Mọi số tiền là số backend trả.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-09"></a>
### P4-09 — Sản xuất theo mẻ: bếp chỉ đọc, quầy bấm

**Phụ thuộc** · bước 9/12 · **cần xong trước:** `P4-06`

**Goal:** bảng trạm chỉ đọc; bấm mẻ · lùi mẻ · ra bàn · chuyển · ghi làm sai ở màn quầy (**ADR-090**).
Test chứng minh màn trạm không có nút thao tác.

**Nhận việc** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-09`, cùng nền như
`P4-07`). **Chặn một phần:** bấm mẻ · lùi mẻ · chuyển · ghi làm sai cần `station_job_id` · `production_batch_id` mà không đường đọc nào trả
(**F-073**, gửi pha 3). Làm phần không bị chặn: bảng trạm chỉ đọc và *ra bàn* ở quầy (`POST /served-marks` dùng khoá gom của bảng).

*Nghiệm thu phần làm được* (viết trước): (1) `fe/src/app/tram/tram.test.tsx` (5 ca, gồm *không một nút* lúc có bảng · rỗng · lỗi) và
`fe/src/app/quay/san-xuat/san-xuat.test.tsx` (9 ca) do Claude viết, dữ liệu mẫu `mau-san-xuat.ts`, xanh không sửa; (2) `check-fe-rules`
xanh; (3) chạy thật: trạm thấy việc, không nút; ra bàn đi tới backend; (4) owner; (5) gate.

**Bàn giao phần làm được** — 2026-10-20 · thực hiện: **Codex** `gpt-6-astra`; test trước và duyệt: **Claude Code**. File:
`fe/src/components/shared/bang-san-xuat.tsx` · `du-lieu-san-xuat.ts` · `man-tram.tsx` · `fe/src/app/quay/san-xuat/{page,san-xuat,hop-thoai-ra-ban,du-lieu-ra-ban}`
· `tram/page.tsx` · liên kết *Sản xuất* ở `quay/page.tsx` (Claude ghép tay vì `P4-07` cùng sửa file). *Bằng chứng:* (1) md5 ba file của
Claude trước = sau; worktree `341 passed`; test có răng — thêm một nút vào bảng hay bày *Hết việc* lúc lỗi ⇒ `2 failed`. (3) Chạy thật:
tài khoản vai `trang_banh` vào `/tram` ⇒ hai trạm, `main` có **0** nút, *Cập nhật lúc 09:38:24*; *Ra bàn Đơn 1* số 1 khi chưa ai bấm mẻ ⇒
*Số ra bàn vượt số đã làm* (`served_quantity_exceeds_made`) — đúng chỗ F-073 chặn. **Còn lại:** bốn việc chờ F-073; nút *Ra bàn* đang xếp
thành một hàng dưới bảng, chưa đặt cạnh từng phần.

**Nhận lượt hai** — 2026-10-20 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-09b`, nhánh
`codex/P4-09b`, base `eab46bb` — đã có `GET /counter/station-jobs` của `T-217`), theo lời chủ repo *"còn gì chưa làm thì bạn yêu cầu codex làm
nốt"*. **Claude chốt hình màn** (không phải luật quán): nút *Bấm mẻ* theo hàng gom còn việc `pending`, hộp thoại tick từng việc; *Lùi mẻ*
theo mẻ, khoá khi `has_served_units`, phải xác nhận; *Chuyển việc* chỉ việc `transferable`, chọn một ứng viên backend trả; *Ghi làm sai*
chỉ việc đơn huỷ `made` · `served` chưa có ghi chú, ghi chú tuỳ chọn gửi nguyên văn. Mọi mã lấy từ đường đọc, không suy từ bảng gom.

*Nghiệm thu lượt hai* (viết trước): (1) `fe/src/app/quay/san-xuat/thao-tac-me.test.tsx` (Claude, 13 ca) xanh không sửa, dữ liệu mẫu
`viecMau` · `ungVienMau`; ca đầu `san-xuat.test.tsx` đổi thành *đọc việc trạm lỗi thì không nút*; `tram.test.tsx` xanh — bảng trạm vẫn
không một nút; (2) `check-fe-rules` xanh; (3) chạy thật: bấm mẻ rồi lùi đúng mẻ ấy qua màn, backend thật; (4) `01-khung-fe.md` §1 · §2;
(5) gate xanh.

**Bàn giao lượt hai** — 2026-10-20 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4-09b`, base `eab46bb`), hết hạn mức trước
khi viết báo cáo nên **không có lời tự khai**; duyệt và tích hợp: **Claude Code**, nhánh `P4A-01`. File: `san-xuat/san-xuat.tsx` ·
`hop-thoai-ra-ban.tsx` (bỏ dòng chú F-073) · mới `du-lieu-me.ts` · `hop-thoai-me.tsx` · `components/shared/du-lieu-san-xuat.ts` (kiểu
`Pick` cho khoá gom) · `01-khung-fe.md` §1 · §2. Claude đọc diff: mọi mã việc · mã mẻ lấy từ `GET /counter/station-jobs`, ứng viên chuyển
từ `GET /station-jobs/{id}/transfer-candidates`, không suy từ bảng gom; *Lùi mẻ* tắt khi `has_served_units`. *Bằng chứng:* (1)
`thao-tac-me.test.tsx` · `san-xuat.test.tsx` · `mau-san-xuat.ts` giống hệt bản Claude (`diff -q`); clone chính `367 passed`, `tsc` ·
`eslint` sạch; (2) · (5) gate ở clone chính *PASS gate không cổng nào đỏ*, kể cả `be-check`; (4) đã ghi. (3) Chạy thật 2026-10-21 (Claude Code; database dùng-xong-bỏ
compose `p409run` cổng 5499, backend thật cổng 8099, `next dev` 3099, Chromium): POS đăng nhập đứng quầy, một lượt gọi bàn 3 ⇒ 10 việc
`pending`; `/quay/san-xuat` ⇒ *Bấm mẻ* · tick một việc · *Ghi mẻ* ⇒ *Đã ghi mẻ 2.*; *Lùi mẻ 2* · *Xác nhận lùi mẻ* ⇒ *Đã lùi mẻ 2.*, đọc lại
còn 0 nút lùi. **Claude sửa khi chạy thật:** cùng một thứ chờ ở hai trạm (gấp · tráng) cho hai nút *Bấm mẻ Bánh cuốn · Thịt · Thường* trùng
tên đứng cạnh nhau ⇒ `san-xuat.tsx` xếp nút bấm mẻ theo nhóm `role="group"` *Trạm …*, tên nút giữ nguyên; chạy lại thấy ba nhóm
`gap_banh` · `trang_banh` · `canh`, test quầy · trạm `44 passed`. **Còn lại (ngoài lượt này):** nút *Ra bàn* vẫn xếp một hàng dưới bảng.

[↑ đầu file](#top)

---

<a id="p4-10"></a>
### P4-10 — Khách: QR tại bàn và đơn web

**Phụ thuộc** · bước 10/12 · **cần xong trước:** `P4-05` · `P4-06`

**Goal:** quét mã, gọi món, gửi lượt (`I-024` — gửi lại không nhân đôi); đơn mang đi · giao · đặt trước. Giá khách
thấy là giá tính thử của backend. Chữ khách đọc khi quán tạm dừng nhận đơn **chốt 2026-10-21** (chủ repo
chọn trong hội thoại) — nguyên câu ở `master_plan/shop-facts.md` §6.8; luật chặn: `I-008`.

**Nhận việc** — 2026-10-21 · dẫn, test trước và duyệt: **Claude Code**; thi công: **Codex** (worktree `../lean_wt/P4-10`, nhánh `codex/P4-10`,
base `346f0c7` + nền chưa commit của `T-221` đặt trong index), theo lời chủ repo *"P4-10, câu chữ khi quán tạm dừng nhận đơn … yêu cầu codex
thực hiện 2 việc trên bạn kiểm tra"*. Cùng ngày chủ repo chọn câu tạm dừng và câu mất kết nối (`shop-facts.md` §6.8 · §6.11). **Claude chốt
hình màn** (không phải luật quán): `/ban/[ma]` — khách QR; `/dat-mon` — đơn web `delivery` · `pickup`. Page là server component lấy
`GET /qr-codes/{code}` · `GET /menu` bằng `fetch` `cache: "no-store"` cho từng request (**ADR-102** điểm 1 · 3), không cú pháp cache của Next;
màn khách chỉ thấy nhãn bàn (`I-023`). Bộ soạn là `BoSoanMon` của `T-221`, không *Mang về* ở QR (khách tại bàn — giữ hẹp, quầy vẫn có). Tổng khách
thấy là `total_vnd` của `POST /price-quotes` cho cả giỏ hiện tại; gửi chỉ mở khi lần tính thử mới nhất xong. Gửi theo khuôn `SoanDon` (một
`submission_code` mỗi lần bấm, giữ cho *Gửi lại*, `I-024`). Giỏ nháp ở Zustand `fe/src/lib/nhap-khach.ts` theo khoá ngữ cảnh (mã QR · đơn web),
chỉ mã món, số lượng, lựa chọn (**ADR-102** điểm 4). Ba lời từ chối theo nguyên văn shop-facts; lời khác do Claude chọn, chờ chủ quán duyệt.
Không thêm `/dat-mon` vào `PUBLIC_ROUTES` ở lượt này.

*Nghiệm thu* (viết trước, 2026-10-21): (1) `fe/src/app/ban/khach-qr.test.tsx` (8 ca) · `fe/src/app/dat-mon/dat-mon.test.tsx` (7 ca) · dữ liệu mẫu
`fe/src/app/ban/mau-khach.ts` do Claude viết, xanh không sửa (md5 `125a759a…` · `2b1c30aa…` · `4488d4fe…`); test cũ xanh; (2) `check-fe-rules` xanh;
(3) chạy thật cùng backend: khách mở `/ban/{mã}` của một bàn, gửi một lượt; gửi lại cùng dấu không sinh đơn thứ hai; chủ quán bật tạm dừng ⇒
`/dat-mon` bày đúng câu §6.8; (4) `01-khung-fe.md` §1 · §2 · §4; (5) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-21 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/P4-10`, đã gỡ); duyệt, tích hợp và chạy thật: **Claude Code**,
nhánh `P4A-01`. Codex không chạy được Vitest — `node_modules` của worktree là link sang clone chính, ngoài vùng sandbox cho ghi (`EPERM` ở
`.vite-temp`) — nên gate của Codex đỏ ở bước test; Claude chạy lại. File mới: `app/ban/[ma]/page.tsx` · `app/dat-mon/page.tsx` (server component,
`fetch` `no-store`) · `app/ban/_components/phieu-khach.tsx` (bộ soạn, tính thử cả giỏ, gửi giữ dấu) · `loi-khach.ts` · `lib/nhap-khach.ts`
(`useNhapKhach`, `dungLai`); `01-khung-fe.md` §1 · §2 · §4; test của Claude `ban/khach-qr.test.tsx` · `dat-mon/dat-mon.test.tsx` ·
`ban/mau-khach.ts`. *Bằng chứng:* (1) md5 ba file trước = sau; clone chính `406 passed` (thêm 15 ca); test có răng — bỏ `no-store` ở page QR ⇒
`1 failed`; đột biến bỏ vế *không đang tính* ở nút gửi **sống sót**, vì khoá tính thử gồm nội dung giỏ nên giỏ đổi thì nút đã khoá tới khi tính
xong — vế ấy chỉ còn tác dụng khi đọc lại cùng giỏ; (2) `check-fe-rules: PASS`, `tsc` · `eslint` sạch; (3) chạy thật 2026-10-21 (Claude Code;
database dùng-xong-bỏ compose `p410run` cổng 5499, backend thật 8098 với `BANHCUON_SHOP_TZ=UTC` để 09:0x UTC rơi vào giờ bán, `next dev` 3098,
Chromium; POS đứng quầy giữ `/quay` mở; mã QR bàn 5 chủ quán cấp qua `POST /dining-tables/5/qr-code`): HTML server của `/ban/{mã}` đã có món
và nhãn bàn; khách gửi lượt ⇒ `201` đơn 5, *Đã gửi lượt gọi · tổng 0đ* (Canh giá 0đ trong dữ liệu mồi); phát lại đúng thân và dấu ⇒ `200` cùng
đơn 5, không đơn thứ hai (`I-024`); chủ quán `POST /order-intake/pause` ⇒ `/dat-mon` đến lấy ⇒ `409 order_intake_paused`, khách đọc đúng câu
§6.8; mở lại ⇒ bấm *Đặt đơn* lần nữa ⇒ `201` đơn 6; (4) đã ghi; (5) gate *PASS không cổng nào đỏ*, có `fe-check`. **Chữ khách đọc Codex tự
viết, chờ chủ quán duyệt:** *Bạn vui lòng quét lại mã trên bàn.* · *Chưa đọc được bàn / menu. Bạn vui lòng tải lại trang.* · *Chưa xác nhận được
kết quả. Bạn có thể bấm Gửi lại.* · *Chưa gửi được phiếu. Bạn vui lòng kiểm tra lại thông tin.* · *Chưa tính được tổng / giá. Bạn vui lòng thử
lại.* **Còn lại:** `h1` màn QR là nhãn trơ của bàn (*5*); `/dat-mon` chưa vào `PUBLIC_ROUTES`; khoảng trống hợp đồng `T-216` nêu (menu không
danh mục · mô tả · ảnh, không trường trả trước) đứng nguyên.

*2026-10-21, chủ repo:* năm câu chữ khách đọc ở trên **được duyệt** (*"Câu chữ chờ duyệt: đồng ý"*), giữ nguyên; `h1` màn QR và `/dat-mon` công
khai chuyển sang `T-222` ([chi tiết](backlog.md#t-222)).

[↑ đầu file](#top)

---

<a id="p4-11"></a>
### P4-11 — Chủ quán: két và ngày bán

**Phụ thuộc** · bước 11/12 · **cần xong trước:** `P4-08`

**Goal:** khai đầu két, đếm, sửa đếm có lý do, khai sổ giấy, nhập bù (**ADR-099**), đối soát xong, danh sách nợ,
tạm dừng · tiếp tục nhận đơn, đổi mã QR. Một ngày bán giả đi hết qua màn ⇒ đối soát 0đ lệch. Ngày bán của mọi màn
lấy từ backend, không từ đồng hồ máy (`docs/product/4-fe/01-khung-fe.md` §2, 2026-10-19).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-12"></a>
### P4-12 — Cổng chất lượng pha 4 và rà ranh giới

**Phụ thuộc** · bước 12/12 · **cần xong trước:** `P4-07`…`P4-11`

**Goal:** ba scenario của `docs/product/0-ba/ban-hang/08-scenario.md` §8 diễn qua giao diện thật; file cổng trong
`docs/product/4-fe/` ký từng ô kế hoạch §9 kèm bằng chứng; rà pointer và ranh giới pha. Ký chuyển pha 5 là quyền
chủ repo.

**Nhận việc:** —

[↑ đầu file](#top)
