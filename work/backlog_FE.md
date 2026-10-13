<a id="top"></a>
# Backlog — pha 4 · FE

Mô tả dài của mười hai bước `P4-01`…`P4-12`. Dựng 2026-10-13 (T-178) sau khi chủ repo ký mở pha 4 (T-176) và hỏi
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

**Chỗ đang chặn** — bảng sống ở kế hoạch §4. `P4-07` chờ **U-080** (Telegram); vế giao hàng chờ **S-6**.

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

**Nhận việc:** —

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

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-04"></a>
### P4-04 — Mọi cửa đều cần biết *ai bấm* và *đang đứng đâu*, mà chưa màn nào hỏi

**Phụ thuộc** · bước 4/12 · **cần xong trước:** `P4-03`

**Goal:** chọn tên (T-143, U-075), vào · rời quầy; khung riêng cho bốn loại người dùng — quầy, chủ quán, trạm
(chỉ đọc, không nút), khách; nút hiện theo lớp quyền của [`02-vai-va-quyen.md`](../docs/product/3-be/02-vai-va-quyen.md)
nhưng **backend vẫn là người chặn** — màn ẩn nút là tiện, không phải bảo vệ.

**Không làm thì mất gì:** trang thử `P4-05` không gọi được cửa nào (mọi cửa menu là lớp `chu_quan`).

**Bẫy:** đừng viết lại luật quyền ở frontend thành bảng thứ hai — đọc lớp của cửa từ một chỗ; ma trận lệch là
lỗi của cổng §9 ô bảy.

**Nhận việc:** —

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

**Không làm thì mất gì:** khuôn của mọi màn sau được rút từ một màn chưa ai duyệt chạm tiền.

**Bẫy:** không nút *thêm món*, không nút *xoá* — không có cửa (kế hoạch §7). Không cộng giá để *xem trước* ở
trình duyệt; cần xem trước thì gọi tính thử.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-06"></a>
### P4-06 — SSE chỉ báo *đọc lại*, và mọi màn sống phải tự kéo khi luồng đứt

**Phụ thuộc** · bước 6/12 · **cần xong trước:** `P4-04`

**Goal:** một lớp chung theo **ADR-097** và [`09-realtime-du-phong.md`](../docs/product/3-be/09-realtime-du-phong.md):
nghe luồng, nhận tín hiệu thì đọc lại đúng query, tự kéo theo `poll_interval_seconds` backend trả, **banner mất
kết nối luôn nhìn thấy** (màn trạm: không nút đóng).

**Không làm thì mất gì:** quầy tưởng không có đơn mới trong khi luồng đã đứt từ lâu.

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-07"></a>
### P4-07 — Màn quầy: nhận và ghi đơn

**Phụ thuộc** · bước 7/12 · **cần xong trước:** `P4-05` · `P4-06` · **U-080** (Telegram)

**Goal:** hàng đợi quầy, duyệt · từ chối đơn chờ, POS tạo lượt gọi, đơn điện thoại, nhả đơn hẹn; vế giao hàng
bày lời từ chối của **S-6** tới khi có lời. Chẻ tiếp lúc nhận nếu một phiên không đủ.

**Nhận việc:** —

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

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-10"></a>
### P4-10 — Khách: QR tại bàn và đơn web

**Phụ thuộc** · bước 10/12 · **cần xong trước:** `P4-05` · `P4-06`

**Goal:** quét mã, gọi món, gửi lượt (`I-024` — gửi lại không nhân đôi); đơn mang đi · giao · đặt trước. Giá khách
thấy là giá tính thử của backend. Chữ khách đọc khi quán tạm dừng nhận đơn chưa chốt — hỏi khi dựng
(`master_plan/shop-facts.md`, `I-008`).

**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p4-11"></a>
### P4-11 — Chủ quán: két và ngày bán

**Phụ thuộc** · bước 11/12 · **cần xong trước:** `P4-08`

**Goal:** khai đầu két, đếm, sửa đếm có lý do, khai sổ giấy, nhập bù (**ADR-099**), đối soát xong, danh sách nợ,
tạm dừng · tiếp tục nhận đơn, đổi mã QR. Một ngày bán giả đi hết qua màn ⇒ đối soát 0đ lệch.

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
