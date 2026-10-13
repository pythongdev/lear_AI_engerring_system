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
### P4-01 — Bốn file hướng dẫn FE đều ghi *đề xuất, chưa chốt*, và mười một bước sau cần một câu trả lời chung

**Phụ thuộc** · bước 1/12 · **cần xong trước:** chủ repo ký mở pha 4 (**đã ký 2026-10-13**, T-176) · **chặn:** mọi bước sau

**Goal:** một ADR là **thước** của pha 4, cùng vai **ADR-082** ở pha 3: mỗi loại màn (trạm chỉ đọc · quầy · chủ
quán · khách) lấy dữ liệu thế nào, ghi xong thì đọc lại thế nào, state nào ở đâu; chốt phần **ADR-100** để mở —
thư viện form, khung test frontend, công cụ sinh type từ `openapi.yaml`, chính sách ghim phiên bản.

**Vì sao có task này:** `docs/private/fe/fe_guidance/` có bốn file tốt nhưng mỗi mục ghi *đề xuất, chưa chốt*, và
`docs/private/` không phải owner. Không có thước chung thì `P4-05` và `P4-07` mỗi bước tự chọn cách cache — và
một màn giữ giá cũ là rủi ro lớn nhất của pha (kế hoạch §10).

**Không làm thì mất gì:** Codex chọn thư viện theo sở thích ở bước đầu tiên chạm tới, các bước sau chép nó;
không ô cổng §9 nào có định nghĩa để ký.

**Cách hoàn thành:**
1. Đọc kế hoạch §1–§3 · §9; bốn file `fe_guidance`; `01-hop-dong-api.md` §3 · §5; **ADR-097**; **ADR-100**;
   `QC-08` · `QC-09`.
2. Khai `work/scope/P4-01.txt`; chuyển `P4-01` sang *In Progress*.
3. Viết ADR: bảng *loại màn → cách lấy dữ liệu → ghi xong làm gì → mất kết nối bày gì*; state ở đâu (dữ liệu
   server, nháp của người dùng, tên đang chọn); bốn lựa chọn còn mở của ADR-100 — mỗi cái một dòng lý do, hoặc
   ghi *hỏi chủ repo* nếu là sở thích.
4. **Không một dòng code, không một file dưới `fe/` hay `docs/product/4-fe/`** sau lượt này.
5. `./scripts/gate.sh`; tick *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng chép nguyên `fe_guidance` thành ADR — chọn và bác, ghi vì sao. Đừng kèm code mẫu; mười một bước
sau sẽ chép nó.

**Nhận việc** — *điền lúc nhận*:
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

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
