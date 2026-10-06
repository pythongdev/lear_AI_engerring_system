<a id="top"></a>
# Backlog — pha 3 · BE

Mô tả dài của mười bốn bước `P3-01`…`P3-14`. Dựng 2026-09-29, cập nhật 2026-10-01 (T-120) theo yêu cầu chủ repo trong
phiên: **"pha tiếp theo cần master plan, backlog, hay làm tất cả các bước cần thiết để thực hiện"**.
Vì sao pha 3 có sổ riêng: `docs/decisions.md` **ADR-036** luật 1 (một dãy mã riêng, một chuỗi việc
đọc liền nhau) và **ADR-076**; hình dạng chép của `work/backlog_DB.md` (**ADR-051**).

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Bước nào *Ready*, *In Progress* hay *Done* đọc ở
> `work/backlog.md` — file `scripts/brief.sh` đọc (**ADR-002**).
>
> **Nó không giữ thứ tự, mức, hay đầu ra kiểm chứng được** — ba thứ đó ở
> [`master_plan/BE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/BE_master_plan_banh_cuon_ba_thanh.md)
> §6. Chép về đây là bản thứ hai (**F-001**).
>
> **Nó không giữ một dòng hợp đồng API nào.** Không tên endpoint, không chữ ký, không quyền của một
> vai. Owner của hợp đồng ra đời ở `P3-04`, trong `docs/product/3-be/` (`CLAUDE.md` §2, **ADR-035**).

## Ba file, ba việc

| Câu hỏi | Đọc ở |
|---|---|
| Pha 3 còn nợ gì · thứ tự · mức · đầu ra · cổng sang pha 4 · lời gọi bắt đầu một phiên | [`master_plan/BE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/BE_master_plan_banh_cuon_ba_thanh.md) |
| Bước nào **đang** chạy, xong chưa | [`work/backlog.md`](backlog.md) |
| **Vì sao** có bước này, hỏng thì mất gì, làm thế nào, **xong là thế nào** | **file này** |
| Sự thật nghiệp vụ, invariant, quyết định, lược đồ, hợp đồng | owner ở `CLAUDE.md` §2 |

## Luật của file này — bốn câu, chép luật của `work/backlog_DB.md`

1. **Mô tả cả mười bốn bước viết trước; dòng trạng thái thì không.** Chỉ bước **nhận được ngay** mới
   có dòng ở *Ready* (**F-012**). Từ 2026-10-05 (chủ repo ký chuyển pha, T-136) `P3-01` nhận được; `P3-01` xong cùng ngày (**ADR-082**) ⇒ `P3-02` · `P3-03` nhận được; bước sau theo cột *Cần xong trước*.
2. **Entry là hồ sơ thực thi duy nhất của bước** (**ADR-051**). *Nghiệm thu* và *Kiểm chứng* vào khối
   **Nhận việc** cuối entry, chỉ điền khi mọi bước ở *Cần xong trước* đã `Done` (T-051).
3. **Bước xong thì entry ở lại đây** và nhận khối **Bàn giao**: kết quả, output gate, phần còn thiếu
   kèm link. Dòng `- [x]` ở `work/backlog.md` là chỗ duy nhất nói bước đã xong.
4. **Bước mới của pha 3 vào đây**, task không thuộc pha 3 thì không (**ADR-036**).

**Luật riêng của pha 3 — code thật, hai công cụ.** Bước L2 chạm tiền chạy theo
`docs/prompt-guideline.md` §6.1 (**ADR-054**): Claude viết Nghiệm thu và **test từ chối đỏ trước**,
Codex (hoặc Claude) viết cửa cho test xanh trong **worktree riêng** (`CLAUDE.md` §7.4), Claude tích hợp
và tự chạy lại `./scripts/gate.sh`. Scope khai ở `work/scope/P3-XX.txt` (**ADR-063**).

## Mục lục

| Bước | Entry |
|---|---|
| P3-01 | [Ranh giới và từ vựng của pha 3](#p3-01) |
| P3-02 | [Gate 1d học vùng pha 3](#p3-02) |
| P3-03 | [Quy ước code backend — dựng `be/`](#p3-03) |
| P3-04 | [Khuôn hợp đồng API — mở `docs/product/3-be/`](#p3-04) |
| P3-05 | [Danh tính · vai · quyền theo chỗ đứng](#p3-05) |
| P3-06 | [Hàm tính giá duy nhất và menu của chủ quán](#p3-06) |
| P3-07 | [Luồng tại bàn từng bước](#p3-07) |
| P3-08 | [Luồng mang đi · giao · đặt trước](#p3-08) |
| P3-09 | [Đường tiền](#p3-09) |
| P3-10 | [Sản xuất theo mẻ](#p3-10) |
| P3-11 | [Vết sửa · nhập bù · trực quầy](#p3-11) |
| P3-12 | [Realtime và dự phòng](#p3-12) |
| P3-13 | [Cổng chất lượng pha 3](#p3-13) |
| P3-14 | [Rà ranh giới pha và pointer](#p3-14) |

**Chỗ đang chặn** — bảng sống ở kế hoạch §4, đo 2026-10-01. Pha 2 đã xong cả mười bốn bước
ngày 2026-09-30; cổng tick **12/12**, bằng chứng ở `docs/product/2-db/11-cong-chat-luong-pha-2.md` §7.
**Chủ repo ký chuyển pha 2026-10-05** (T-136); `P3-01` nhận được. Đường lùi migration
đã giải ở `P2-09`, **ADR-065** (mỗi bước một bước lùi có khoá chặn).
`P3-05` có câu về cách đăng nhập; `P3-08` · `P3-10` chờ **S-6** · **S-5**;
`P3-09` chờ **U-058** và **U-073**, đọc **ADR-079** (T-133 — số đếm két và dấu đối soát xong đã có chỗ cất, **F-048** đã đóng); `P3-12` đọc **ADR-078** (T-132 — hai khoảng ngừng nhận đơn đã có chỗ cất, **F-050** đã đóng); vế ghi bánh làm sai của `P3-10` đọc **ADR-077** (T-127), đọc **F-044**;
`P3-11` gỡ **F-046**; vết khi thêm dòng con đã có từ `T-137` (**F-047** đóng, **ADR-081**) — chế độ nghiêm phủ cả nó.
**U-063 đã đóng**, lược đồ thu nợ trả dần đã dựng ở **T-126**, **ADR-075**.
**U-064 đã đóng**; lược đồ có chỗ ghi bánh làm sai từ **T-127** (**ADR-077**).
Một bước bị chặn vẫn làm phần không phụ thuộc; cửa của phần bị chặn **từ chối kèm mã**,
không lấp bằng mặc định.

---

<a id="p3-01"></a>
### P3-01 — Pha 1 giao cho tầng 3 hàng chục vế "miền nghiệp vụ giữ", và chưa chỗ nào nói trong code chữ ấy nghĩa là gì

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 1/14 · **cần xong trước:** chủ repo ký chuyển pha
(**đã ký 2026-10-05**, T-136; pha 2 xong 2026-09-30, cổng 12/12 ở `11-cong-chat-luong-pha-2.md` §7) · **chặn:** mọi bước sau

**Goal:** một ADR mới là **thước** của pha 3, cùng vai **ADR-050** ở pha 2: tầng 2 và tầng 3 dịch sang
code thành cái gì, chấm bằng gì, cái gì **không** phải biên nhận; lời từ chối của database đi tới người
dùng thế nào; ba thứ pha 3 không được viết.

**Vì sao có task này:** `03-bao-ve-invariant.md` giao nhiều vế cho *"miền nghiệp vụ giữ"*. Chữ ấy ở pha 1
là **yêu cầu**, giống chữ *"cơ sở dữ liệu giữ"* trước **ADR-050**. Tám lát pha 3 sẽ chạy phần lớn nối
tiếp nhau nhưng mỗi lát viết cửa của mình; không có thước chung thì mỗi lát tự định nghĩa *"một cửa
ghi"* và cổng `P3-13` không chấm được gì.

**Không làm thì mất gì:** một lát coi *"có kiểm trong code"* là đủ, lát khác coi *"có test gọi hàm
trong"* là đủ — cả hai đều không chứng minh cửa từ chối khi người gọi đi vòng; và ô cổng thứ nhất của
kế hoạch §9 không có định nghĩa để ký.

**Cách hoàn thành:**
1. Đọc kế hoạch pha 3 §3 · §7; **ADR-050** nguyên văn (hình mẫu); `03-bao-ve-invariant.md` §0 và cột
   giữa của mọi hàng; `architecture.md` §1.1 · §4; `10-quy-uoc-code.md` `QC-03` · `QC-10`.
2. Khai `work/scope/P3-01.txt`; chuyển `P3-01` sang *In Progress*.
3. Viết ADR trả lời ba câu của kế hoạch §7 — *liệt kê đường ghi bằng gì* · *chấm một vế tầng 3 bằng
   gì* · *lời từ chối của database đi tới đâu* — và bảng *không được viết ở pha 3 / viết gì thay vào*.
4. **Không một dòng code, không một file dưới `docs/product/3-be/` hay `be/`** sau lượt này.
5. Kế hoạch pha 3 §7 thay bản mô tả bằng một dòng trỏ sang ADR mới, cùng lượt (**F-001**).
6. `./scripts/gate.sh`; tick *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng viết kèm một đoạn code mẫu cho "dễ hình dung" — mười ba bước sau sẽ chép nó (**ADR-050**
*Rejected alternatives* thứ ba). Đừng chọn thư viện ở đây — đó là `P3-03`.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-05, Claude Code): `docs/decisions.md` · `master_plan/BE_master_plan_banh_cuon_ba_thanh.md`
  · `work/backlog.md` · `work/backlog_BE.md` · `work/findings.md` (thêm giữa lượt, cho **F-058**). Không file nào dưới
  `docs/product/3-be/` hay `be/`.
- *Nghiệm thu* (viết trước khi viết ADR): (1) một ADR mới trả lời đủ ba câu của kế hoạch §7, mỗi câu có
  một phép chấm, hoặc tên bước dựng phép chấm ấy; (2) ADR nói cái gì **không** phải biên nhận cho tầng 2 và
  tầng 3; (3) ADR không có một dòng code mẫu, không tên thư viện, không tên endpoint · route · component,
  không một dòng bảng mã lỗi; (4) phạm vi ô cổng thứ nhất (§9) với vế admin được nói rõ, có nguồn;
  (5) kế hoạch §7 rút còn con trỏ sang ADR mới, ô §9 *mỗi ô ghi có đúng một cửa* trỏ cùng chỗ;
  (6) `docs/product/3-be/` và `be/` không tồn tại; (7) `./scripts/gate.sh` xanh.
- *Kiểm chứng:* đọc diff theo từng dòng nghiệm thu; `ls -d be docs/product/3-be`; `./scripts/gate.sh`.

**Bàn giao** (2026-10-05): **ADR-082** đã chốt. Thực hiện: Codex soạn bản kiểm kê và bản nháp ở chế độ chỉ
đọc (`codex exec -s read-only`, không sửa file); duyệt và chốt: Claude Code, đối chiếu lại nguồn trích. Claude
sửa bản nháp ba chỗ: đơn vị *một cửa* là **ô ghi** (bảng × loại ghi), không phải bảng; ô cổng thứ nhất đếm §1–§4,
admin §5 ngoài cổng theo **ADR-068**; lời từ chối do trigger cũng phải mang tên — bốn `RAISE EXCEPTION` hôm nay
không có ⇒ **F-058** (Open, sửa trước `P3-09`, muộn nhất ở `P3-04`). File đổi: `docs/decisions.md` (ADR-082 + dòng
bảng tổng hợp) · `master_plan/BE_master_plan_banh_cuon_ba_thanh.md` (§7 thành con trỏ; §9 ô một và ba; dòng
`P3-03` ở §6) · `work/backlog_BE.md` (entry này; bước `P3-03`, `P3-04`, `P3-14` trỏ ADR-082) · `work/findings.md`
(F-058) · `work/backlog.md`. Kiểm chứng: `ls -d be docs/product/3-be` ⇒ cả hai *No such file*; `./scripts/gate.sh`
⇒ `PASS  gate     không cổng nào đỏ`. Còn mở: **F-058**; cách dựng lệnh liệt kê đường ghi là việc của `P3-03`.


[↑ đầu file](#top)

---

<a id="p3-02"></a>
### P3-02 — Cổng ranh giới pha chỉ đọc hai thư mục, và pha 3 sắp mở thư mục thứ ba

**Phụ thuộc** · bước 2/14 · **cần xong trước:** `P3-01` · độc lập với `P3-03`…`P3-12`

**Goal:** `scripts/check-phase-boundary.sh` chấm thêm `docs/product/3-be/`: **đỏ** với component, route
màn hình, thẻ JSX kể cả thẻ có thuộc tính và thẻ đóng; **im** với endpoint và SQL (hai thứ hợp lệ ở pha 3).

**Vì sao có task này:** Gate 1d hôm nay đọc `docs/product/1-system-design/` và `docs/product/2-db/`
(`P2-02`). **F-049 Fixed (T-131)** ngày 2026-10-01: mẫu hiện tại đã bắt thẻ có thuộc tính
và thẻ đóng. Bước này thêm vùng mới trên mẫu ấy. Pha 3 là pha gần giao diện nhất — viết một đường đọc rất dễ trượt sang viết *"màn này hiện
gì"*. `F-040` · `F-041` là hai lần một pha viết hộ pha sau mà không cổng nào đỏ.

**Không làm thì mất gì:** mười file pha 3 mang mô tả màn hình, pha 4 đọc nó như đầu vào đã chốt.

**Cách hoàn thành:**
1. Đọc header `scripts/check-phase-boundary.sh`, entry `P2-02` ở `work/backlog_DB.md` (cách lượt trước
   thêm vùng), **F-017** · **F-040** · **F-041**, ADR của `P3-01` (**ADR-082**).
2. Khai scope; *In Progress*.
3. Thêm vùng pha 3 với bộ mẫu riêng; ca hồi quy mới trong `scripts/check-phase-boundary.test.sh`: một
   file giả mang component, route màn hình và các dạng thẻ JSX ⇒ đỏ; file giả mang endpoint
   và SQL ⇒ xanh. Dựng ca theo khuôn T-131, không mở lại phần T-131 đã sửa.
4. **Cả bộ ca cũ vẫn xanh** — dán output đầy đủ.
5. `CLAUDE.md` §5 câu tả Gate 1d chỉ đổi nếu nó liệt kê thư mục (ưu tiên sửa header script).
6. `./scripts/gate.sh`; *Done*; *Bàn giao*; khối commit.

**Hai hình tên trong backtick** vẫn để mắt người theo header: PascalCase và đường dẫn mở đầu
bằng dấu gạch chéo; không tự coi chúng là component hay route.

**Bẫy:** một mẫu quá rộng (mọi chữ viết hoa trong dấu `<…>`) sẽ đỏ với kiểu dữ liệu generic trong Go —
thử nó trên một đoạn hợp đồng thật trước khi tin.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-06, Claude Code; thi công: Codex theo `docs/prompt-guideline.md` §6.1):
  `scripts/check-phase-boundary.sh` · `scripts/check-phase-boundary.test.sh` · `work/backlog.md` ·
  `work/backlog_BE.md`. Không tạo `docs/product/3-be/` (thư mục ấy sinh cùng dòng nội dung đầu tiên
  của pha 3, ADR-035).
- *Thiết kế* (Claude, 2026-10-06): vùng pha 3 có bộ mẫu thứ ba, **không** có mẫu SQL, **không** có
  mẫu endpoint. Mẫu thẻ dùng lại hình của T-131 nhưng đòi **ký tự đứng trước `<` không phải chữ, số
  hay `_`** — đúng chỗ phân biệt thẻ (`<DebtList />`, `{<DebtList />}`) với kiểu generic
  (`Result<Order>`, `Array<OrderLine>`); generic Go viết bằng `[...]` nên không chạm mẫu. Route màn
  hình: thuộc tính `path=` · `href=` · `to=` theo sau bởi dấu nháy hoặc `{`, và lệnh chuyển màn
  `navigate(` · `router.push(` · `router.replace(` · `useNavigate` · `useRouter`. Đuôi
  `.jsx` · `.tsx` · `.vue` giữ như cũ. Hai vùng cũ không đổi mẫu.
- *Nghiệm thu* (viết trước khi giao): (1) mỗi hình sau trong một file `.md` đã đổi dưới
  `docs/product/3-be/` cho exit 1 và output có `pha 3 đang đặt tên` cùng chính dòng ấy: sáu hình
  thẻ của ca 18 (F-049), `<Route path="/no" element={<DebtList />} />`, `path="/menu/product"`,
  `href="/no"`, `navigate("/no")`, `router.push("/no")`; (2) một file pha 3 mang endpoint (có và
  không có `/` mở đầu, có `/api/` và `/v1/`), SQL (`CREATE TABLE` · `ON DELETE CASCADE` ·
  `DELETE FROM` · `NOT NULL`), generic (`Result<Order>`, `Array<OrderLine>`, `func Page[T any]`) và
  hai hình tên trong backtick cho exit 0 với `OK — 1 file .md đã soát` — **đọc rồi im**, không phải
  bỏ qua; (3) dòng *skipping* nêu cả `docs/product/3-be`; (4) mọi ca 1–19 cũ vẫn `ok`;
  (5) `./scripts/gate.sh` xanh.
- *Kiểm chứng:* ca 20–23 trong `scripts/check-phase-boundary.test.sh` (Claude viết trước, đỏ trên
  script cũ); Claude tự chạy lại test và gate trong worktree và ở clone chính.

**Bàn giao** (2026-10-06): thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree
`../lean_wt/P3-02`, nhánh `codex/P3-02` từ `c7da3ee`, đã gỡ), duyệt và tích hợp **Claude Code**.
- *File đổi:* `scripts/check-phase-boundary.sh` (vùng thứ ba `PHASE3_DIR`, `PATTERN3`, `hits3`, ignore,
  đếm file, dòng skipping và header nêu ba vùng) · `scripts/check-phase-boundary.test.sh` (ca 20–23 Claude
  viết trước, đỏ 25 ca trên script cũ; ca 24–25 Codex thêm: các hình route/đuôi còn lại, ignore và đếm ba vùng).
- *Duyệt sửa một điểm:* phiếu viết `` `<X>` `` như ký hiệu thay cho một thẻ, Codex đọc thành thẻ một chữ và nới
  tên thẻ sang `[A-Z][A-Za-z]*` — `<T>` đứng sau dấu cách sẽ đỏ oan. Lỗi nằm ở phiếu nên Claude tự sửa: trả về
  `+` như T-131, ca 24 dùng `` `<DebtList>` ``, ca 21 thêm dòng `Kiểu trả về <T> do nơi gọi chọn.` (đỏ với `*`,
  im với `+`, đã thử).
- *Bằng chứng:* `./scripts/check-phase-boundary.test.sh` → `check-phase-boundary.test: OK` (ca 1–19 cũ đều
  `ok`); `./scripts/gate.sh` ở worktree và clone chính → `PASS gate không cổng nào đỏ`; `PATTERN3` chạy trên
  toàn bộ `docs/product/1-system-design/`, `docs/product/2-db/`, `docs/decisions.md` → 0 dòng khớp.
- *Ghi chú môi trường:* trong sandbox `workspace-write` của Codex hai ca `--amend` của
  `scripts/commit-msg.test.sh` hỏng vì hook dò `--amend` bằng `ps`, sandbox chặn `ps`; ngoài sandbox cùng
  commit thì qua. Không phải lỗi của task này. Mô hình mặc định trong cấu hình Codex (`gpt-6.1-sol`) bị tài
  khoản ChatGPT từ chối, nên lượt này ghi đè `-m`.
- *Còn lại:* không. Vùng pha 3 chưa có file nào, nên Gate 1d vẫn `SKIP` cho tới lát nội dung đầu tiên của
  `docs/product/3-be/`.

[↑ đầu file](#top)

---

<a id="p3-03"></a>
### P3-03 — `QC-09` chốt ngôn ngữ backend nhưng để trống thư viện, cách nói chuyện với database và khung test

**Phụ thuộc** · bước 3/14 · **cần xong trước:** `P3-01` · **chặn:** `P3-04` và mọi lát

**Goal:** `be/` tồn tại với `be/go.mod`, **một** test khói chạy trên PostgreSQL thật, và
`./scripts/gate.sh` gọi nó; mỗi quy ước mới là một mục `QC-XX` có phép kiểm chạy được trong
`docs/product/2-db/10-quy-uoc-code.md`.

**Vì sao có task này:** `QC-09` viết thẳng: *thư viện web, cách truy cập database từ Go và khung test
chốt ở pha 3*; *lượt pha 3 tạo `be/go.mod` sửa `verify.sh` trong cùng lượt*. `QC-06` để lại chỗ trống
múi giờ cho kết nối của backend. Không chốt một lần thì mỗi lát tự chọn.

**Không làm thì mất gì:** bốn lát mở giao dịch theo bốn cách; test của lát này chạy trên database thật,
lát kia chạy trên bản giả — và bản giả không từ chối gì, nên test tầng 3 xanh vì không có ai để từ chối.

**Cách hoàn thành:**
1. Đọc `10-quy-uoc-code.md` toàn bộ (nhất là `QC-03` · `QC-05` · `QC-06` · `QC-07` · `QC-08` · `QC-09`);
   `scripts/verify.sh` · `scripts/db-check.sh`; **F-045** (hai lần chạy database kiểm giẫm nhau);
   `master_plan/prompt-fullstack.md` §3.4 như **đề xuất**.
2. Khai scope; *In Progress*.
3. Chốt, mỗi thứ một mục `QC-XX` (**quy ước · hậu quả nếu làm khác · phép kiểm · nguồn**): thư viện web
   · cách truy cập database (sinh code từ SQL hay viết tay) · phiên bản Go · cấu trúc thư mục trong `be/`
   · cách test dựng database kiểm (dùng lại `db-check` hay riêng) · kết nối bằng vai `shop_app` và
   đặt múi giờ quán (`QC-06`) · **dấu truy từ test về `I-0xx`** (**ADR-082** điểm 4).
   Cùng lượt dựng **lệnh liệt kê đường ghi** và đưa nó vào gate, có ca hồi quy đỏ (**ADR-082** điểm 3).
4. Dựng `be/go.mod` và **một** test khói: kết nối database kiểm, đọc múi giờ phiên, thử một lệnh xoá ⇒
   bị từ chối (`QC-03`).
5. `scripts/verify.sh` gọi `go test` trong `be/` (`QC-09` *chỗ trống có tên*).
6. Dán output test và gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng chọn bộ test chạy database giả trong bộ nhớ — tầng 1 và tầng 2 không tồn tại ở đó. Đừng
để hai lần chạy test dùng chung một database kiểm cố định (**F-045**).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-06, Claude Code; thi công: Codex theo `docs/prompt-guideline.md` §6.1):
  `be/` · `scripts/check-write-paths.sh` · `scripts/check-write-paths.test.sh` · `scripts/be-check.sh` ·
  `scripts/verify.sh` · `scripts/gate.sh` · `scripts/gate.test.sh` · `docs/product/2-db/10-quy-uoc-code.md`
  · `docs/decisions.md` · `CLAUDE.md` (§5, một dòng Gate 1f) · `work/backlog.md` · `work/backlog_BE.md`.
  Không tạo `docs/product/3-be/` (sinh ở `P3-04`), không endpoint, không `be/cmd/`.
- *Thiết kế* (Claude, 2026-10-06; lý do và phương án bị loại: **ADR-083**): Go **1.27.1** ghim ở dòng
  `go` của `be/go.mod`; web bằng thư viện chuẩn `net/http`, không framework; database bằng **pgx v5**,
  SQL viết tay, và **mọi câu ghi nằm trong file `.sql` dưới thư mục của một cửa**
  `be/internal/<gói>/sql/<cửa>/` — vì thế lệnh liệt kê đường ghi chỉ đọc file (Gate 1f
  `scripts/check-write-paths.sh`, khuôn Gate 1e); giao dịch mở bằng **một** hàm ở `be/internal/db/`;
  kết nối từ chối mọi vai khác `shop_app` và từ chối khi thiếu múi giờ; test Go chạy trên PostgreSQL
  thật qua `scripts/be-check.sh` (compose project riêng mỗi lần, **F-045**), thiếu database thì **đỏ**,
  không bỏ qua; tên test mang mã mệnh đề. Bảy mục `QC-11`…`QC-17`.
- *Nghiệm thu* (viết trước khi giao): (1) `10-quy-uoc-code.md` có `QC-11`…`QC-17`, mỗi mục bốn ô, và
  `./scripts/db-check.sh` in `PASS` cho mọi khối của chúng; `QC-06` · `QC-09` không còn *chỗ trống có
  tên* của pha 3. (2) `be/go.mod` ghim `go 1.27.1` và `github.com/jackc/pgx/v5`, có `be/go.sum`.
  (3) `scripts/be-check.sh` dựng database riêng, chạy migration từ số 0, chạy `go test` trong `be/` và in
  output test; không Docker ⇒ exit khác 0; hai lần chạy chồng nhau ⇒ cả hai đạt. (4) test khói
  `TestQC15_*` chạy qua hàm kết nối của backend: vai là `shop_app`, không superuser; `SHOW TimeZone` qua
  kết nối ấy **bằng** múi giờ `shop-facts.md` §1, trong khi kết nối không đặt múi giờ đọc ra UTC; một
  lệnh xoá bị từ chối `42501`, in lời từ chối nguyên văn, số dòng không đổi; kết nối bằng `shop_owner`
  hoặc thiếu múi giờ ⇒ hàm kết nối trả lỗi. (5) `cd be && go test ./...` không qua `be-check.sh` ⇒ **đỏ**
  với lời chỉ sang `be-check.sh`, không `SKIP`. (6) `scripts/verify.sh` chạy gofmt · vet · build trong
  `be/` và gọi `be-check.sh` khi `be/` · `db/` · `compose.yaml` · `scripts/be-check.sh` đổi.
  (7) Gate 1f chạy mọi lượt sau Gate 1e; `scripts/check-write-paths.test.sh` (Claude viết trước, đỏ khi
  chưa có script) xanh, trong đó ca **cài một đường ghi thứ hai** ⇒ đỏ và nêu cả hai cửa;
  `scripts/gate.test.sh` xanh. (8) `CLAUDE.md` §5 có dòng Gate 1f. (9) `./scripts/gate.sh` xanh.
- *Kiểm chứng:* Claude tự chạy trong worktree và ở clone chính: `./scripts/check-write-paths.test.sh` ·
  `./scripts/be-check.sh` (một lần, rồi hai lần chồng nhau) · `cd be && go test ./...` (mong đỏ) ·
  `./scripts/db-check.sh` · `./scripts/gate.sh`; đọc diff theo từng dòng nghiệm thu.

**Bàn giao** (2026-10-06): thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree
`../lean_wt/P3-03`, nhánh `codex/P3-03` từ `bd6b2a8`), thiết kế · QC-11…QC-17 · ca hồi quy 1–16 · duyệt và
tích hợp **Claude Code**. Phần thiết kế (ADR-083, dòng `CLAUDE.md` §5, entry này) đã vào commit `a8b6c6e`.
- *File đổi ở lượt thi công:* `be/go.mod` · `be/go.sum` · `be/internal/db/db.go` (`Open`, `InTx`) ·
  `be/internal/db/khoi_test.go` · `be/internal/dbtest/dbtest.go` · `scripts/check-write-paths.sh` (Gate 1f) ·
  `scripts/check-write-paths.test.sh` (ca 1–16 Claude viết trước, đỏ 29 ca khi chưa có script; ca 17 trở đi
  Codex thêm: RENAME · DROP · REVOKE từng loại · chú thích lồng · bốn loại ghi bị cấm) · `scripts/be-check.sh` ·
  `scripts/verify.sh` (khối Go chuyển sang `be/`) · `scripts/gate.sh` · `scripts/gate.test.sh` ·
  `docs/product/2-db/10-quy-uoc-code.md` (§8 mới; `QC-06` · `QC-08` · `QC-09` · bảng §9) ·
  `scripts/check-links.ignore` (gỡ bốn dòng tạm đã vào `a8b6c6e`).
- *Duyệt:* code khớp đặc tả; sửa một chỗ (cột của dòng `step "Gate 1f"`). Sandbox của Codex chặn Docker, nên
  phần PostgreSQL thật do Claude chạy; hai ca `commit-msg.test.sh` đỏ trong sandbox là lỗi môi trường đã ghi ở
  P3-02 (sandbox chặn `ps`), ngoài sandbox qua.
- *Bằng chứng:* `./scripts/check-write-paths.test.sh` → `OK`; lệnh liệt kê trên migration thật với ba cửa giả
  ⇒ `record_revision` đỏ *thuộc migration*, `sales_order` · `cash_count` liệt kê được. `./scripts/be-check.sh`
  → `vai=shop_app, superuser=false; múi giờ quán=Asia/Ho_Chi_Minh; backend=Asia/Ho_Chi_Minh; kết nối không
  đặt=Etc/UTC` · `ERROR: permission denied for table attendance_day (SQLSTATE 42501)` · `be-check: PASS`.
  Lỗi cài (bỏ dòng đặt `timezone` trong `Open`) ⇒ `backend="Etc/UTC", quán="Asia/Ho_Chi_Minh"`,
  `be-check: FAIL`; trả lại thì xanh. Hai lần `be-check` chồng nhau ⇒ cả hai PASS, không còn project kiểm nào.
  `cd be && go test ./...` không qua be-check ⇒ `thiếu BANHCUON_TEST_APP_DSN: chạy qua ./scripts/be-check.sh
  (QC-16)`, FAIL. `./scripts/gate.sh` ở worktree và clone chính ⇒ `PASS gate không cổng nào đỏ`, db-check
  `17 khối kiểm QC`.
- *Còn lại:* chưa có cửa nào nên Gate 1f đang đếm 0 ô; lát đầu có cửa (`P3-05` trở đi) là lần đầu nó liệt
  kê ô thật. Ở database rỗng, vế *số dòng không đổi* của `TestQC03_` là 0 = 0; bằng chứng chính là mã `42501`.
  **F-058** vẫn mở (lời từ chối của trigger không mang tên) — việc của `P3-04`.

[↑ đầu file](#top)

---

<a id="p3-04"></a>
### P3-04 — Pha 4 sẽ sinh type từ hợp đồng API, mà hợp đồng chưa có khuôn, chưa có owner, chưa có cách kiểm với code

**Phụ thuộc** · bước 4/14 · **cần xong trước:** `P3-01` · `P3-03` · **chặn:** mọi lát `P3-05`…`P3-12`

**Goal:** `docs/product/3-be/` mở với khuôn hợp đồng: định dạng file hợp đồng máy đọc được, hình lỗi
chung, tiền và mốc trên dây, dấu lần gửi trên dây; `CLAUDE.md` §2 hàng *Hợp đồng API* có owner; một
**lệnh** so hợp đồng với code chạy trong gate; một ADR nói **bên nào thắng khi lệch**.

**Vì sao có task này:** bảng sáu pha đòi *hợp đồng API — nguồn duy nhất cho FE* và *type sinh từ hợp
đồng, không gõ tay*. Không có khuôn thì mỗi lát tự đặt hình lỗi, và FE nhận tám kiểu lỗi.
**ADR-053** luật 2 nói *code dựng database thắng tài liệu* — với API, câu tương ứng chưa ai chốt.

**Không làm thì mất gì:** FE tính lại thứ backend đã tính (đúng chỗ `I-013` cấm), và một lần đổi hợp
đồng không ai thấy cho tới khi màn hình vỡ.

**Cách hoàn thành:**
1. Đọc ADR của `P3-01` (**ADR-082** — điểm 5: lời từ chối của database, **F-058**); `01-quy-uoc-du-lieu.md` (`QD` tiền · mốc · định danh); `QC-10` (tên ràng buộc);
   `quality/invariants.md` `I-024` (dấu lần gửi); `CLAUDE.md` §2 đoạn *phase ownership boundary*.
2. Khai scope; *In Progress*.
3. Viết `docs/product/3-be/01-hop-dong-api.md` (tên đề xuất): định dạng · hình lỗi (tên ràng buộc → mã
   lỗi, ai giữ bảng ánh xạ) · tiền là số nguyên đồng · mốc mang múi giờ · dấu lần gửi · cách đánh phiên
   bản. File hợp đồng máy đọc được bắt đầu **rỗng đường gọi** — mỗi lát thêm phần của mình.
4. ADR: hợp đồng thắng hay code thắng, và lệnh kiểm chứng điều đó (có ca hồi quy đỏ khi lệch).
5. Cùng lượt: `CLAUDE.md` §2 hàng *Hợp đồng API* → file thật; `docs/product/00-index.md` hàng *Pha 3* →
   **đang mở** + dòng file mới.
6. Gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng chép danh sách đường gọi của `prompt-fullstack.md` §3.6 vào file hợp đồng "cho đủ" — mỗi
đường gọi vào cùng lát chấm nó. Đừng để lệnh so hợp đồng in rỗng mà không in hai danh sách (**F-017**).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-06, Claude Code; chủ repo giao *"hãy đọc kĩ và làm task này"*, Claude tự thi công):
  `docs/product/3-be/` (mới: `01-hop-dong-api.md` · `openapi.yaml`) · `be/internal/apierr/` (mới) ·
  migration bước 18 `20261006120000_ten_loi_tu_choi_trigger` (F-058) · `scripts/check-api-contract.sh` ·
  `scripts/check-api-contract.test.sh` · `scripts/gate.sh` · `scripts/gate.test.sh` · `docs/decisions.md` ·
  `CLAUDE.md` (§2 hàng *Hợp đồng API*, §5 dòng Gate 1g) · `docs/product/00-index.md` ·
  `docs/product/2-db/10-quy-uoc-code.md` (`QC-10` vế trigger, `QC-14` dòng `apierr`) ·
  `docs/product/2-db/07-thu-tu-migration.md` (bước 18) · `docs/product/2-db/04-luoc-do-duong-tien.md`
  (tên lời từ chối) · kế hoạch pha 3 §5 · `work/backlog.md` · `work/backlog_BE.md` · `work/findings.md`.
  Không một đường gọi nào, không `be/cmd/`.
- *Thiết kế* (Claude, 2026-10-06; lý do và phương án bị loại: **ADR-084**): hợp đồng máy đọc là **OpenAPI
  3.1** viết YAML, `docs/product/3-be/openapi.yaml`, `paths: {}`; khuôn và luật đọc ở `01-hop-dong-api.md`.
  **Hợp đồng thắng code**; migration thắng hợp đồng về tên ràng buộc (**ADR-053** luật 2 không đổi). Hình
  lỗi chung `{code, field?}`, mã là enum `ErrorCode` kèm status HTTP; khuôn chỉ có hai mã chung
  (`internal_error` · `invalid_request`), mã của luật do lát thêm. Bảng **tên từ chối → mã** là phần mở rộng
  `x-constraint-errors` của hợp đồng: mọi tên trong migration một dòng, giá trị là một mã, `internal`
  (khoá chính — id do database sinh, `QD-10`) hoặc `unreviewed` (chưa lát nào xét; chạy như lỗi hệ thống
  chung) — khuôn **không** đoán nghĩa người dùng của 200+ ràng buộc. F-058: migration mới cho mười lời từ
  chối của trigger một tên `QC-10` qua `USING CONSTRAINT`, cùng mã lỗi và câu cũ. Code giữ phần công khai
  ở `be/internal/apierr/`; **Gate 1g** `scripts/check-api-contract.sh` (chỉ đọc file, mọi lượt) so: đường
  gọi hợp đồng ↔ `HandleFunc` trong `be/`, enum + status ↔ hằng Go, tên migration ↔ dòng ánh xạ, dòng có
  mã ↔ bảng Go, và đổi hợp đồng ⇒ phải tăng `info.version`.
- *Nghiệm thu* (viết trước khi sửa): (1) `docs/product/3-be/01-hop-dong-api.md` nói định dạng · hình lỗi
  và ai giữ bảng ánh xạ · tiền · mốc · ngày bán · dấu lần gửi · phiên bản · ai thắng, không một tên đường
  gọi; `openapi.yaml` có `paths: {}`. (2) Gate 1g chạy mọi lượt sau Gate 1f, in hai danh sách mỗi phía;
  `scripts/check-api-contract.test.sh` (viết trước, đỏ khi chưa có script) xanh, có ca đỏ cho: đường gọi chỉ
  ở code · chỉ ở hợp đồng · không nêu phương thức; tên migration thiếu dòng · dòng thừa; giá trị không phải
  mã; mã ở hợp đồng thiếu hằng Go và ngược lại; status lệch; bảng Go lệch; đổi hợp đồng không tăng phiên
  bản. (3) Trên cây thật Gate 1g `PASS` với 0 đường gọi mỗi phía và số tên migration = số dòng ánh xạ.
  (4) Migration bước 18 xuôi · lùi · xuôi lại trong `db-check`; khối `QC-10` mới (mọi `RAISE EXCEPTION`
  trong hàm của schema mang `CONSTRAINT`) ra 0 dòng sau bước 18 và **ra dòng** trước nó (đã thử); các test
  `db/tests/` cũ vẫn xanh. (5) Test Go `TestQC10_…` qua `be-check.sh` trên PostgreSQL thật: lời từ chối của
  trigger tới pgx mang đúng tên (`ConstraintName`), `apierr` dịch nó thành `internal_error` và trả tên để
  ghi lại; tập tên đọc từ database sống (ràng buộc + chỉ mục duy nhất + tên trong thân hàm) **bằng** tập
  khoá của `x-constraint-errors`. (6) `CLAUDE.md` §2 hàng *Hợp đồng API* trỏ file thật; `00-index.md` hàng
  *Pha 3* **đang mở** + dòng hai file mới; **F-058** đóng. (7) `./scripts/gate.sh` xanh.
- *Kiểm chứng:* `./scripts/check-api-contract.test.sh` · `./scripts/check-api-contract.sh --list` ·
  `./scripts/be-check.sh` · `./scripts/db-check.sh` · `./scripts/gate.sh`; lỗi cài bằng tay cho (4) và (5);
  đọc diff theo từng dòng nghiệm thu.

**Bàn giao** (2026-10-06): thực hiện, duyệt và tích hợp **Claude Code** (không giao Codex — chủ repo giao thẳng
cho phiên). Thiết kế và lý do: **ADR-084**.
- *File đổi:* mới — `docs/product/3-be/01-hop-dong-api.md` · `docs/product/3-be/openapi.yaml` (OpenAPI 3.1,
  `paths: {}`, 290 dòng `x-constraint-errors`) · `be/internal/apierr/apierr.go` · `be/internal/apierr/apierr_test.go`
  · `db/migrations/20261006120000_ten_loi_tu_choi_trigger.{up,down}.sql` (bước 18) · `scripts/check-api-contract.sh`
  (Gate 1g) · `scripts/check-api-contract.test.sh`; sửa — `scripts/gate.sh` · `scripts/gate.test.sh` ·
  `scripts/verify.sh` (chú thích) · `CLAUDE.md` §2 · §5 · `docs/decisions.md` (ADR-084) · `docs/product/00-index.md`
  · `docs/product/2-db/10-quy-uoc-code.md` (`QC-10` vế trigger + khối `sql` thứ hai, `QC-14` dòng `apierr`, §9) ·
  `07-thu-tu-migration.md` (bước 18) · `04-luoc-do-duong-tien.md` (tên lời từ chối) · kế hoạch pha 3 §1 · §5 ·
  `work/findings.md` (F-058 Fixed) · `work/backlog.md` · entry này.
- *Bằng chứng theo nghiệm thu:* (1) tài liệu khuôn đủ mười mục, không tên đường gọi; Gate 1d `4 file .md đã soát`.
  (2) `./scripts/check-api-contract.test.sh` viết trước, đỏ `FAIL — 34 ca` khi chưa có script, nay
  `check-api-contract.test: OK`. (3) `check-api-contract: PASS — hợp đồng 0.1.0; 0 đường gọi ở hợp đồng, 0 ở code;
  2 mã lỗi; 290 tên từ chối ở migration, 290 dòng ánh xạ (42 internal, 248 unreviewed, 0 dòng mang mã công khai)`.
  (4) `db-check: PASS — 18 bước xuôi · lùi · xuôi lại, 18 khối kiểm QC, 36 file test…`; lùi bước 18 ⇒ `lược đồ giống
  hệt lúc trước bước ấy`. Lỗi cài (rút bước 18 ra khỏi `db/migrations/`) ⇒ `FAIL QC-10 (sql) — 2 dòng:
  cash_day_reconciled_guard|RAISE EXCEPTION không mang tên · reconciled_day_nonempty_guard|…`. (5) `be-check: PASS`:
  `lời từ chối nguyên văn: cash_count_line: không được ghi số của ngày đã đối soát xong (SQLSTATE 23001, constraint
  "cash_count_line_reconciled_day_locked_check")` · `… (SQLSTATE 23514, constraint "reconciled_day_cash_count_has_lines_check")`
  · `database sống: 290 tên; x-constraint-errors: 290 dòng`. Cùng lỗi cài ⇒ hai test đỏ: `constraint ""` và `database
  sống: 280 tên … chỉ ở hợp đồng: [cash_count_line_reconciled_day_locked_check …]`. (6) `CLAUDE.md` §2 · `00-index.md`
  · F-058 như trên. (7) `./scripts/gate.sh` ⇒ `PASS gate không cổng nào đỏ`.
- *Duyệt (Gate 4):* test Go sửa một lần sau lần chạy đầu — lỗi ở chính test (tham số `set_config` truyền `int64`
  vào `text`), không nới điều kiện. `apierr.Write` · `Error.Status` chưa có ai gọi: là bản code của `x-http-status`
  và hình lỗi, lát đầu có đường gọi (`P3-05`) dùng chúng.
- *Còn lại:* 248 dòng `unreviewed` — mỗi lát xét dòng của bảng mình ghi (`01-hop-dong-api.md` §4). Gate 1g không so
  thân request · response với struct Go (giới hạn có tên, ADR-084).

[↑ đầu file](#top)

---

<a id="p3-05"></a>
### P3-05 — Quyền gắn với CHỖ ĐỨNG tại thời điểm bấm, mà chưa cửa nào hỏi "người này đang đứng đâu"

**Phụ thuộc** · bước 5/14 · **cần xong trước:** `P3-04` · **chặn:** `P3-06`…`P3-11` · **câu cho chủ
quán:** nhân viên đăng nhập bằng gì (mở `U-XXX` lúc nhận nếu `shop-facts.md` chưa có lời)

**Goal:** ma trận vai × thao tác (file mới ở `docs/product/3-be/`), mỗi thao tác ghi đúng một dòng; cửa
đăng nhập nhân viên; quyền đọc từ **chỗ đứng tại thời điểm bấm** (`YC-15`…`YC-17`); khách QR vào bàn qua
**mã hiện hành** (`I-023`); mọi thao tác chạm tiền mang *ai bấm* (`I-012`); cửa đổi mã QR của chủ quán.

**Vì sao có task này:** `architecture.md` §4 chốt *quyền gắn chỗ đứng, không gắn chức vụ*; lược đồ
`P2-08` đã cất ai đứng quầy lúc nào. Chưa cửa nào đọc nó.

**Không làm thì mất gì:** một thao tác tiền không truy được về người, hoặc người đã rời quầy vẫn thu
tiền được — ngưỡng lệch 0đ hết nghĩa.

**Cách hoàn thành:**
1. Đọc `architecture.md` §4 · §14.5; `04-yeu-cau-du-lieu.md` `YC-15`…`YC-17`; `06-luoc-do-nguoi-va-vet.md`;
   `02-luoc-do-ban-hang.md` hàng `I-023`; hàng `I-012` · `I-023` ở `03-bao-ve-invariant.md`;
   `shop-facts.md` về vai và đăng nhập.
2. Cách đăng nhập chưa có lời ⇒ mở `U-XXX` (`CLAUDE.md` §4), làm phần còn lại; **không** tự chọn mã số.
3. Khai scope; *In Progress*.
4. **Test từ chối trước (đỏ):** người không đứng quầy làm việc của quầy ⇒ từ chối; mã QR cũ ⇒ từ chối;
   thao tác tiền không người ⇒ từ chối; khách QR gọi vào bàn khác ⇒ từ chối.
5. Viết cửa cho test xanh; thêm phần của lát vào file hợp đồng.
6. `comm -3` giữa danh sách cửa ghi và danh sách dòng ma trận ⇒ rỗng (in cả hai).
7. Gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng gắn quyền vào một cột *vai* cố định của người — đó đúng là thứ §4 bác. Đừng để khách QR
suy ra bàn từ số bàn trong đường dẫn.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-06, Claude Code; chủ repo giao *"hãy đọc kĩ task trên và làm yêu cầu codex làm bạn
  kiểm tra"* — Claude thiết kế và viết test đỏ; phiếu giao Codex chạy hỏng vì model trong
  cấu hình Codex không dùng được với tài khoản, chủ repo chọn **Claude tự thi công** ở clone chính): `docs/product/3-be/` (mới `02-vai-va-quyen.md`; `openapi.yaml`;
  `01-hop-dong-api.md` §10) · `be/internal/apierr/` · `be/internal/authz/` (mới) · `be/internal/qr/` (mới) ·
  `scripts/check-api-contract.sh` · `scripts/check-api-contract.test.sh` · `docs/product/2-db/10-quy-uoc-code.md`
  (`QC-14` dòng `authz`) — `docs/decisions.md` (ADR-085) · `docs/product/99-unknowns.md` (U-075) ·
  `CLAUDE.md` §2 · §5 · `work/`. **Không** cửa đăng nhập, không bảng phiên,
  không migration, không `be/cmd/`.
- *Câu cho chủ quán:* `shop-facts.md` không có lời nào về cách đăng nhập ⇒ mở **U-075** (2026-10-06). Lát này
  không chọn mã số, không chọn mật khẩu.
- *Thiết kế* (Claude, 2026-10-06; lý do và phương án bị loại: **ADR-085**): mỗi cửa khai **một lớp quyền**
  (`authz.Door{Code: "<gói>/<cửa>", Need: …}`); lớp `quay` = người bấm có khoảng `counter_duty` chứa `now()`
  của giao dịch cửa; lớp `chu_quan` = `person.is_owner`; hai lớp đọc độc lập (`YC-16`). `authz.Run` mở giao
  dịch qua `db.InTx`, kiểm người · lớp, khai `shop.actor_person_id` bằng người đã kiểm, rồi chạy thân cửa.
  Danh tính tới cửa qua giao diện `authz.Authenticator` — bản thật chờ **U-075**; test dùng bản trong `_test.go`.
  Khách QR: đường gọi mang mã, bàn tra từ mã hiện hành (`I-023`); gửi kèm bàn ⇒ `invalid_request`. Cửa đầu
  tiên: `qr/doi_ma` lớp `chu_quan`, gọi `qr_code_issue` sẵn có. Đường gọi: `GET /qr-codes/{code}` (khách) ·
  `POST /dining-tables/{dining_table_id}/qr-code` (chủ quán). Mã mới: `unauthenticated` 401 ·
  `not_on_counter_duty` 403 · `owner_only` 403 · `qr_code_not_current` 404 · `dining_table_not_found` 404 ·
  `qr_code_issue_conflict` 409. Gate 1g thêm phép so **thư mục cửa ↔ dòng ma trận ↔ khai báo `authz.Door`**,
  lớp hai phía bằng nhau. Dòng `x-constraint-errors` của `person` · `counter_duty` **giữ `unreviewed`** — lát
  này không cửa nào ghi hai bảng ấy; lát ghi chúng (`P3-11`, lane admin) xét (sửa §10 của `01-hop-dong-api.md`).
- *Nghiệm thu* (viết trước khi sửa): (1) `docs/product/3-be/02-vai-va-quyen.md` có luật đọc (lớp quyền, mốc
  giao dịch, khách QR, danh tính chờ U-075) và bảng ma trận **một dòng mỗi cửa** — hôm nay đúng một dòng
  `qr/doi_ma` · `chu_quan`; Gate 1d không kêu. (2) `openapi.yaml` có hai đường gọi trên, sáu mã mới kèm status,
  `info.version` tăng; mọi dòng `qr_code_*` của `x-constraint-errors` đã xét (mã hoặc `internal`, lý do ở
  *Bàn giao*), `constraintCodes` khớp. (3) Test đỏ do Claude viết trước — `be/internal/authz/authz_test.go` ·
  `be/internal/qr/qr_test.go` — xanh qua `./scripts/be-check.sh` **mà không sửa điều kiện kiểm nào**: người
  đã rời quầy · chủ quán không đứng quầy làm việc lớp `quay` ⇒ `not_on_counter_duty`, thân cửa không chạy;
  người đang đứng quầy ⇒ chạy, người thao tác của giao dịch là chính người ấy; chủ quán đứng quầy qua cả hai
  lớp; không người · người không tồn tại ⇒ `unauthenticated`; nhân viên đổi mã ⇒ `owner_only`, mã không đổi;
  chủ quán đổi ⇒ mã mới, mã cũ ⇒ `qr_code_not_current`; khách gửi kèm bàn ⇒ `invalid_request` field
  `dining_table_id`; bàn không có ⇒ `dining_table_not_found`. (4) Gate 1g đỏ cho bốn ca lệch (thư mục cửa
  không dòng ma trận · dòng ma trận không thư mục · cửa không khai `authz.Door` · lớp hai phía khác) —
  `check-api-contract.test.sh` viết ca trước khi sửa script; cây thật `PASS` in số mỗi phía. (5) `comm -3`
  giữa danh sách thư mục cửa và danh sách dòng ma trận in rỗng, kèm cả hai danh sách. (6) `./scripts/gate.sh`
  xanh ở worktree **và** ở clone chính sau tích hợp.
- *Kiểm chứng:* `./scripts/be-check.sh` · `./scripts/check-api-contract.test.sh` ·
  `./scripts/check-api-contract.sh --list` · lệnh `comm -3` của (5) · `./scripts/gate.sh`; Claude đọc diff theo
  từng dòng nghiệm thu và tự chạy lại gate.

**Bàn giao** (2026-10-06): thiết kế, test đỏ, thi công và duyệt — **Claude Code**. Phiếu giao Codex đã viết
và chạy, nhưng Codex dừng ngay vì model trong `~/.codex/config.toml` không dùng được với tài khoản đang đăng
nhập; chủ repo chọn để Claude tự thi công. Hệ quả: lát này **không có reviewer độc lập** — chưa ai ngoài
người viết đọc diff. Thiết kế và lý do: **ADR-085**.
- *File đổi:* mới — `docs/product/3-be/02-vai-va-quyen.md` · `be/internal/authz/authz.go` ·
  `be/internal/authz/authz_test.go` · `be/internal/qr/qr.go` · `be/internal/qr/qr_test.go` ·
  `be/internal/qr/sql/doi_ma/cap_ma.sql`; sửa — `docs/product/3-be/openapi.yaml` (0.1.0 → 0.2.0) ·
  `docs/product/3-be/01-hop-dong-api.md` (§9 · §10) · `be/internal/apierr/apierr.go` ·
  `scripts/check-api-contract.sh` · `scripts/check-api-contract.test.sh` · `docs/product/2-db/10-quy-uoc-code.md`
  (`QC-14`, §9) · `docs/decisions.md` (ADR-085) · `docs/product/99-unknowns.md` (U-075) · `CLAUDE.md` §2 · §5 ·
  `work/backlog.md` · entry này.
- *Bằng chứng theo nghiệm thu:* (1) ma trận một dòng `qr/doi_ma` · `chu_quan`; `PASS Gate 1d … 3 file .md đã
  soát`. (2) `check-api-contract: PASS — hợp đồng 0.2.0; 2 đường gọi ở hợp đồng, 2 ở code; 8 mã lỗi; 290 tên
  từ chối ở migration, 290 dòng ánh xạ (46 internal, 241 unreviewed, 3 dòng mang mã công khai)`. Dòng `qr_code_*`:
  `qr_code_dining_table_fkey` → `dining_table_not_found`; `qr_code_one_current_per_table_key` →
  `qr_code_issue_conflict`; `qr_code_replaced_after_issued_check` → `qr_code_issue_conflict` (lần đầu xếp
  `internal`; test chen nhau đỏ 2/5 lần chạy với `500 internal_error` — lần đổi bắt đầu trước mà ghi sau có
  `now()` sớm hơn mốc cấp của mã vừa sinh, nên đây cũng là ca chen nhau); `qr_code_code_key` → `internal` (mã
  sinh từ sha256 của UUID ngẫu nhiên, trùng là lỗi hệ thống); `qr_code_code_not_blank_check` → `internal`
  (hàm `qr_code_issue` tự đặt `code`, không giá trị nào từ người gọi); `qr_code_id_table_key` → `internal`
  (đích khoá ngoại, `id` do database sinh); `qr_code_person_fkey` → `internal` (`authz.Run` chỉ khai người đã
  đọc được ở `person`). (3) Test đỏ viết trước — `go vet` lúc chưa có code: `no non-test Go files in
  …/internal/authz` · `…/internal/qr`; sau thi công `be-check: PASS` lần chạy đầu, không sửa điều kiện kiểm:
  `A đã rời quầy bấm việc của quầy: mã="not_on_counter_duty", thân cửa chạy=false` · `B đang đứng quầy: …
  người thao tác=3 (B=3)` · `chủ quán không đứng quầy bấm việc của quầy: mã="not_on_counter_duty"` · `A đứng
  quầy bấm việc của chủ quán: mã="owner_only"` · `chủ quán đứng quầy: lớp quay="", lớp chu_quan=""` · sáu
  dòng `người 0 / -1 / 9000000000 … mã="unauthenticated", thân cửa chạy=false` · `POST … (người 10) ⇒ 403
  owner_only` · `GET /qr-codes/<mã cũ> ⇒ 404 qr_code_not_current` · `?dining_table_id=5 ⇒ 400 invalid_request
  field:dining_table_id` · `POST /dining-tables/9000000000/qr-code ⇒ 404 dining_table_not_found` · `16 lần đổi
  chen nhau: 4 thành, 12 xung đột; mã hiện hành: 1`; sau khi sửa dòng `replaced_after_issued`, `be-check` chạy
  lặp tám lần liền đều xanh (xem dưới). (4) `check-api-contract.test.sh` thêm ca 29–37 trước khi
  sửa script: `FAIL — 10 ca`; sau đó `check-api-contract.test: OK`. (5) `comm -3` giữa `qr/doi_ma` (thư mục
  cửa) và `qr/doi_ma` (ma trận) in rỗng. (6) `./scripts/gate.sh` ⇒ `PASS gate không cổng nào đỏ` (gồm
  `be-check: PASS`, `db-check — 18 bước …`).
- *Duyệt (Gate 4):* không câu ghi thẳng vào `qr_code` (Gate 1f `0 ô ghi, 1 cửa`); không `Authenticator` thật
  ngoài file test (`grep … PersonID(` chỉ ra định nghĩa và một lời gọi); test không bị sửa.
- *Còn lại:* cửa đăng nhập và `be/cmd/` chờ **U-075**; dòng `person` · `counter_duty` của `x-constraint-errors`
  còn `unreviewed` — lát ghi hai bảng ấy (`P3-11`) xét; lớp `quay` chưa có cửa thật (`P3-07` thêm test qua cửa).
  Một reviewer độc lập (Codex khi cấu hình chạy được, hoặc một phiên khác) nên đọc lại diff này.

[↑ đầu file](#top)

---

<a id="p3-06"></a>
### P3-06 — Giá được tính thử một chỗ và ghi đơn một chỗ khác là cách chắc nhất để khách thấy một số, quầy thu số khác

**Phụ thuộc** · bước 6/14 · **cần xong trước:** `P3-04` · `P3-05` · **chặn:** `P3-07` · `P3-08`

**Goal:** **một** hàm tính giá; tính thử và ghi đơn gọi cùng hàm qua cửa; giá khách gửi lên bị bỏ
(`I-013`); tổ hợp cấm bị từ chối, không sửa hộ (`I-010`); dòng đơn chụp giá lúc đặt (`I-009`); món
ngừng bán bị **cửa** từ chối (`I-009` tầng 3, **ADR-056**); đổi thành phần trong giờ bán không âm
thầm (`I-011`); cửa sửa menu của chủ quán sửa **thành phần**, không sửa giá suất (`architecture.md` §6.1).

**Vì sao có task này:** bảng sáu pha đòi *hàm tính giá duy nhất + bảng ca test*. `P2-10` đã chứng minh
lược đồ + dữ liệu mồi khớp §4.8 từng đồng; pha 3 phải chứng minh **cửa** khớp.

**Không làm thì mất gì:** doanh thu tính khác giá niêm yết; sửa menu làm đổi đơn cũ.

**Cách hoàn thành:**
1. Đọc `shop-facts.md` §4.1–§4.8; `03-luoc-do-menu-gia.md`; `db/seed/` (cách đọc §4.8 lúc chạy); hàng
   `I-009` `I-010` `I-011` `I-013` ở `03-bao-ve-invariant.md`; `0-ba/ban-hang/04-gia-thanh-toan.md`.
2. Khai scope; *In Progress*.
3. **Test đỏ trước:** mọi ca §4.8 **đọc lúc chạy** từ `shop-facts.md` và chạy **qua cửa**; tổ hợp cấm ⇒
   từ chối; giá gửi lên bị bỏ; món ngừng bán ⇒ từ chối; sửa menu sau khi đặt ⇒ đơn cũ không đổi.
4. Viết hàm và cửa; `grep` chứng minh **một** đường tính giá (in lệnh và kết quả).
5. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng gõ lại con số của §4.8 vào test. Đừng để FE nhận một công thức — nó nhận **kết quả**.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi* (nhận 2026-10-06, Claude Code; chủ repo giao *"hãy đọc kĩ và làm yêu codex làm bạn kiểm
  tra"* — Claude thiết kế và viết test đỏ; Codex thi công ở worktree `../lean_wt/P3-06`, nhánh
  `codex/P3-06`, model chỉ định trên dòng lệnh `-m gpt-6-astra` vì model trong `~/.codex/config.toml`
  vẫn bị từ chối; Claude duyệt và tích hợp): `be/internal/gia/` · `be/internal/don/` · `be/internal/menu/`
  (mới) · `be/internal/apierr/` · `db/seed/seed.pl` (chế độ `--price-cases-tsv`) ·
  `docs/product/3-be/` (`openapi.yaml`, `02-vai-va-quyen.md` §3 · §4, mới `03-ham-gia.md`,
  `01-hop-dong-api.md` §10) · `docs/product/00-index.md` · `docs/product/2-db/03-luoc-do-menu-gia.md`
  (con trỏ §5 · §6) — `docs/decisions.md` (ADR-086) · `CLAUDE.md` §2 · `work/`. **Không** migration, không
  đường gọi HTTP cho cửa tạo lượt gọi, không `be/cmd/`.
- *Vế tầng 2 · tầng 3 lát chạm* (đọc cột giữa của `docs/product/1-system-design/03-bao-ve-invariant.md`,
  2026-10-06): `I-013` dòng 101 — tầng 3, **một chỗ** tính giá, giá từ phía khách bị bỏ; `I-009` dòng 298 —
  tầng 3 vế *mốc khoá là từng lượt gọi* và vế *ngừng bán ⇒ không đặt mới được* (cửa tạo lượt gọi), tầng 1
  vế lưu bản sao đã có từ `P2-05`; `I-010` dòng 299 — tầng 3, cùng cửa, từ chối **toàn bộ**, không sửa hộ;
  `I-011` dòng 300 — tầng 4 (máy không chặn), cái máy giữ là **vết** người · lúc · cái gì. Không vế tầng 2
  nào của bốn hàng thuộc lát này (vế tầng 2 của `I-009` là vết khi **sửa một dòng**, `U-026` — `P3-11`).
- *Câu cho chủ quán:* không mở câu mới. Mặc định *Thịt · Thường* (`shop-facts.md` §4.6 luật 8) **có** lời
  của chủ quán nhưng **không có chỗ cất** ⇒ **F-059**, không phải `U-XXX`.
- *Thiết kế* (Claude, 2026-10-06; lý do và phương án bị loại: **ADR-086**): một hàm `gia.Tinh` đọc menu
  trong giao dịch của người gọi; ba đường gọi nó — `POST /price-quotes` (tính thử), `GET /menu` (giá của
  mọi tổ hợp hợp lệ) và cửa `don/tao_luot_goi` (lớp `quay`, lối vào đặt hộ tại quầy vào phiên đã có,
  **chưa** đường gọi HTTP; `P3-07` · `P3-08` thêm phần kênh vào chính cửa ấy). Bốn cửa lớp `chu_quan`:
  `menu/doi_gia_thanh_phan` · `menu/doi_phu_thu` · `menu/sua_thanh_phan` · `menu/ngung_ban`, mỗi cửa bắt
  buộc `reason` và khai nó cho trigger vết. Sáu mã mới: `menu_item_not_found` · `menu_option_not_found` ·
  `menu_component_not_found` · `menu_item_component_not_found` 404 · `menu_item_discontinued` 409 ·
  `option_combination_invalid` 422. Ca §4.8 đọc lúc chạy qua `perl db/seed/seed.pl --price-cases-tsv`
  (Claude thêm, cùng bộ đọc với `--price-cases` của `P2-10`; bản SQL cũ không đổi một byte — `md5`
  trước/sau bằng nhau).
- *Nghiệm thu* (viết trước khi sửa): (1) Test đỏ do Claude viết trước — `be/internal/gia/gia_test.go` ·
  `be/internal/menu/menu_test.go` · `be/internal/don/don_test.go` — xanh qua `./scripts/be-check.sh` **mà
  không sửa điều kiện kiểm nào**: mười ba ca §4.8 khớp từng đồng qua tính thử **và** qua cửa ghi đơn, hai
  đường ra cùng đơn giá; ca 11 bị từ chối ở cả hai, bốn bảng đơn không đổi; menu kể giá mọi tổ hợp hợp lệ,
  không kể tổ hợp cấm, không hiện nhóm nhân cho món không nhận nhân; giá gửi lên (0đ · gấp mười) bị bỏ;
  năm hình tổ hợp sai và *một dòng đúng + một dòng cấm* bị từ chối nguyên yêu cầu, không tự điền mặc định;
  món ngừng bán bị từ chối ở tính thử và cửa ghi, biến khỏi menu; người không đứng quầy · không người ⇒
  `not_on_counter_duty` · `unauthenticated`, không ghi; đơn của quầy là `staff_pos` · `new`; sửa giá thành
  phần · phụ thu · thành phần suất rồi ngừng bán ⇒ đơn cũ đứng nguyên từng chữ (giá · tên · ảnh chụp ·
  mốc khoá), lượt gọi mới cùng phiên ăn giá mới bằng đúng con số tính thử; bốn cửa menu: nhân viên ⇒
  `owner_only`, không người ⇒ `unauthenticated`, thiếu · trắng lý do ⇒ `invalid_request` field `reason`,
  mỗi lần sửa đúng một `record_revision` mang chủ quán · lý do · giá trị mới; giá trị sai hình ⇒
  `invalid_request` kèm field; không tồn tại ⇒ bốn mã 404; ngừng bán lần hai ⇒ `menu_item_discontinued`,
  mốc cũ giữ; không đường gọi nào nhận giá suất. (2) `openapi.yaml` có sáu đường gọi mới (tính thử, menu, bốn cửa sửa menu — tám tất cả), sáu mã kèm status,
  `info.version` 0.3.0; dòng `x-constraint-errors` của bảng menu và bảng dòng đơn đã xét (`internal`, lý
  do ở **ADR-086** điểm 5), `sales_order_*` giữ `unreviewed`. (3) Ma trận có năm dòng mới; Gate 1g `PASS`
  với sáu cửa ở ba phía. (4) Gate 1f: bốn ô *thêm* của đơn chỉ thuộc `don/tao_luot_goi`, bốn ô sửa của
  menu mỗi ô một cửa `menu/…`. (5) `grep` một đường tính giá: phép cộng giá chỉ ở `be/internal/gia/`.
  (6) `./scripts/gate.sh` xanh ở worktree **và** ở clone chính sau tích hợp.
- *Kiểm chứng:* `./scripts/be-check.sh` (Claude tự chạy lại, ít nhất hai lần) ·
  `./scripts/check-api-contract.sh --list` · `./scripts/check-write-paths.sh --list` · lệnh `grep` của (5)
  · `./scripts/gate.sh`; Claude đọc diff theo từng dòng nghiệm thu, đối chiếu bảng red flag Gate 4.

**Bàn giao** (2026-10-06): thiết kế, test đỏ, duyệt và tích hợp — **Claude Code**; thi công — **Codex**
(`codex exec -m gpt-6-astra`, worktree `../lean_wt/P3-06`, nhánh `codex/P3-06` từ `c1bb8d9`, một vòng). Thiết kế và
lý do: **ADR-086**; cách đọc hàm và chỗ trống: `docs/product/3-be/03-ham-gia.md`.
- *File đổi:* mới — `be/internal/gia/` (`gia.go`, `http.go`, `gia_test.go`) · `be/internal/don/` (`don.go`,
  `don_test.go`, bốn file `sql/tao_luot_goi/`) · `be/internal/menu/` (`menu.go`, `menu_test.go`, bốn thư mục cửa
  dưới `sql/`) · `docs/product/3-be/03-ham-gia.md`; sửa — `be/internal/apierr/apierr.go` · `db/seed/seed.pl`
  (`--price-cases-tsv`) · `docs/product/3-be/openapi.yaml` (0.2.0 → 0.3.0) · `02-vai-va-quyen.md` (§3 năm dòng,
  §4) · `01-hop-dong-api.md` §10 · `docs/product/00-index.md` (dòng `03-ham-gia.md`, và dòng `02-vai-va-quyen.md`
  mà `P3-05` quên) · `docs/product/2-db/03-luoc-do-menu-gia.md` (§5 · §6 con trỏ) · `docs/decisions.md` (ADR-086) ·
  `work/findings.md` (F-059) · `CLAUDE.md` §2 · `work/backlog.md` · entry này.
- *Duyệt — ba lỗi, cả ba ở phần của Claude, Codex bắt hai:* (a) dữ liệu giả của test `I-009` làm ba lần sửa menu
  triệt tiêu nhau (trước và sau đều 21000) nên điều kiện *giá mới khác giá cũ* không bao giờ đạt — Codex **dừng
  đúng luật**, không sửa test, kèm `shasum` chứng minh ba file test nguyên; Claude đổi **dữ liệu** (giá bánh mới
  4000 → 5000), giữ điều kiện; (b) bốn dòng `gia_test.go` chưa qua `gofmt` — Codex báo, Claude chạy `gofmt`;
  (c) mười hàm test đặt tên không theo `QC-17` — gate đầy đủ bắt, Claude đổi **tên** sang mã mệnh đề
  (`TestI009_` · `TestI010_` · `TestI012_` · `TestI013_` · `TestI018_`), không đổi điều kiện. Codex cũng chỉ ra phiếu
  đếm nhầm *bảy đường gọi* — đúng là sáu đường mới, tám tất cả; đã sửa chữ ở đây và §10 của hợp đồng.
  Claude đọc diff thật của `gia.go` · `http.go` · `don.go` · `menu.go` và mười file SQL: một câu đọc lấy món,
  thành phần, lựa chọn trong cùng giao dịch; `GET /menu` liệt kê tổ hợp rồi hỏi chính `Tinh` (không bản luật
  thứ hai); cửa ghi gọi `Tinh` trước câu ghi đầu, chỉ chép kết quả; bốn cửa menu kiểm hình → `authz.Run` →
  `FOR UPDATE` → khai lý do → ghi; phép cộng có chặn tràn `int64`. Không red flag Gate 4.
- *Bằng chứng theo nghiệm thu:* (1) `be-check: PASS` hai lần liền ở worktree và lần thứ ba trong gate; mười ba
  ca §4.8 in từng dòng, ví dụ `ca 6 Suất trứng tái ×1 [[Nhân Thịt + mộc nhĩ] [Lượng nhân Thường]] ⇒ đơn giá
  25000 …(§4.8 đòi 25000)`; **lỗi cài**: bỏ vế *nhóm có mặt phải đúng một lựa chọn* trong `gia.go` ⇒
  `--- FAIL: TestI010_TuChoiToanBoLuotGoi` · `--- FAIL: TestI010_TuChoiKhongSuaHo`, gỡ ra thì xanh. (2) `hợp
  đồng 0.3.0; 8 đường gọi ở hợp đồng, 8 ở code; 14 mã lỗi; 290 tên … (85 internal, 202 unreviewed, 3 dòng mang
  mã công khai)`; dòng `sales_order_*`, `option_group_*`, `menu_item_option_group_*`, `menu_component_station_*`
  giữ `unreviewed` (chỉ khoá chính là `internal`, như trước). (3) `6 cửa, 6 dòng ma trận, 6 khai báo
  authz.Door`. (4) `check-write-paths --list`: `sales_order` · `order_line` · `order_line_component` ·
  `order_line_option` *thêm* → `don/tao_luot_goi`; `menu_component.base_price_vnd` → `menu/doi_gia_thanh_phan`,
  `menu_option.surcharge_vnd` → `menu/doi_phu_thu`, `menu_item_component.quantity` → `menu/sua_thanh_phan`,
  `menu_item.discontinued_at` → `menu/ngung_ban` — `PASS — 8 ô ghi, 6 cửa`. (5) `grep -rnE
  'base_price_vnd|surcharge_vnd' be/internal --include='*.go' --include='*.sql' | grep -v _test.go` ⇒ phép cộng
  chỉ ở `be/internal/gia/gia.go`; `don/sql/` chỉ chép vào cột ảnh chụp, `menu/` chỉ `SET` của cửa sửa. (6)
  `./scripts/gate.sh` ⇒ `PASS gate không cổng nào đỏ` ở worktree **và** ở clone chính sau `git apply`.
- *Còn lại:* mặc định *Thịt · Thường* — **F-059**; đường gọi HTTP của cửa tạo lượt gọi, khách QR, mở phiên,
  dấu lần gửi trùng — `P3-07`; bốn kênh ngoài bàn và giờ bán · tạm dừng — `P3-08` · `P3-12`; lời nhắc *đang
  trong giờ bán* khi đổi thành phần — pha 4; danh sách đủ ở `docs/product/3-be/03-ham-gia.md` §4.

[↑ đầu file](#top)

---

<a id="p3-07"></a>
### P3-07 — Luồng ăn tại bàn là phần lớn doanh thu, và bảy mệnh đề của nó mới có tầng 1

**Phụ thuộc** · bước 7/14 · **cần xong trước:** `P3-05` · `P3-06` · song song được với `P3-08` · **chặn:**
`P3-09` · `P3-10`

**Goal:** mở phiên · gọi món qua QR (chờ duyệt) và đặt hộ · duyệt · gửi lại cùng một lần ⇒ đúng một đơn
(`I-024`) · suất đem về trong phiên (`I-006`) · chuyển trạng thái đúng bảng (`I-016`) · đóng phiên
nguyên tử (`I-017`) · dọn bàn (`I-003`) — mỗi vế tầng 2 · tầng 3 của `I-001` `I-002` `I-003` `I-006`
`I-016` `I-017` `I-024` có một test từ chối qua cửa.

**Vì sao có task này:** `master_plan/prompt-fullstack.md` §3.3 và `architecture.md` §3.1 — phiên bàn là
*chỗ dễ mất tiền nhất*. Pha 2 dựng ràng buộc; cửa quyết thứ tự và giao dịch.

**Không làm thì mất gì:** một lượt gọi thành hai đơn khi mạng chập, hoặc phiên đóng khi còn đơn dở.

**Cách hoàn thành:**
1. Đọc `0-ba/ban-hang/05-vong-doi.md`; `02-luoc-do-ban-hang.md`; bảy hàng ở `03-bao-ve-invariant.md`;
   `08-scenario.md` §8 (scenario tại bàn).
2. Khai scope; *In Progress*.
3. Lập danh sách vế tầng 2 · tầng 3 của bảy mã **bằng lệnh** từ `03-bao-ve-invariant.md`; mỗi vế một
   test đỏ trước.
4. Viết cửa; mỗi cửa một giao dịch. Cắt giữa lúc đóng phiên ⇒ không nửa nào sống (dán output).
5. Gửi lại cùng dấu ba lần ⇒ một đơn; cùng dấu khác nội dung ⇒ từ chối (**ADR-061**).
6. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng kiểm *"bàn đã có phiên mở"* bằng một câu đọc rồi mới ghi — hai máy bấm cùng lúc vượt qua
cả hai; để ràng buộc tầng 1 từ chối và dịch lời từ chối.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-08"></a>
### P3-08 — Bốn kênh ngoài bàn, mỗi kênh một mức liên hệ tối thiểu, và một cửa phải biết quán đang nhận đơn hay không

**Phụ thuộc** · bước 8/14 · **cần xong trước:** `P3-05` · `P3-06` · song song được với `P3-07` · **chỗ
chặn:** **S-6**

**Goal:** mọi kênh ngoài bàn tạo được đơn độc lập (`I-007`) với đủ liên hệ tối thiểu của kênh (`I-022`),
gửi lại không nhân đôi (`I-024`), và **không đơn nào** tạo được ngoài giờ bán hay lúc chủ quán tạm dừng
nhận đơn (`I-008`, `architecture.md` §6.2). Mốc *"đã ra bàn"* của đơn giao chờ **S-6**.

**Vì sao có task này:** `architecture.md` §3.2; `0-ba/ban-hang/02-kenh-ban.md` — năm kênh bán, bốn kênh
ngoài bàn đi đường riêng.

**Không làm thì mất gì:** đơn giao không có số điện thoại, hoặc quán nhận đơn lúc đã tạm dừng.

**Cách hoàn thành:**
1. Đọc `02-kenh-ban.md`; `05-vong-doi.md` §5.2; hàng `I-007` `I-008` `I-022` `I-024`; `shop-facts.md` §6.7
   · §7.2 (**S-6**).
2. Khai scope; *In Progress*.
3. Test đỏ trước cho mọi vế tầng 3 của bốn mã; mỗi kênh một đơn đi hết vòng đời.
4. Vế **S-6** chưa có lời ⇒ cửa **từ chối kèm mã**, ghi chỗ trống vào file lát; không đoán *"lúc rời
   quán"*.
5. Vế *mất kết nối* của `I-008` thuộc `P3-12`; lát này chỉ để lại chỗ nối.
6. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng đọc giờ bán từ đồng hồ của máy gửi đơn (`02-thoi-gian-ngay-ban.md`).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-09"></a>
### P3-09 — Đối soát cuối ngày ở ngưỡng 0đ chỉ chạy được khi mọi đường tiền đi qua một cửa có tên người

**Phụ thuộc** · bước 9/14 · **cần xong trước:** `P3-07` · `P3-08` · **chỗ chặn:** **U-058** (giảm giá)

**Goal:** thu chia nhiều phương thức (`I-015`) · ghi nợ và thu nợ (`I-005`) · hoàn tiền · trả trước ·
tiền đầu két · mọi thao tác mang người (`I-012`) · đối soát cuối ngày gọi bộ truy vấn của `P2-11` và ra
**0đ lệch** trên một ngày bán giả đi hết qua cửa (`I-014`, `I-021`). Cửa thu nợ dựng theo chuỗi trả dần đã có ở **T-126**,
đọc **ADR-075** và `04-luoc-do-duong-tien.md`: mỗi lần trả một dòng mang số còn thiếu,
các lần trả nối thành chuỗi. Giảm giá cả đơn còn chờ U-058 ⇒ cửa **từ chối kèm mã**.

**Vì sao có task này:** `shop-facts.md` §6.10 chốt ngưỡng lệch 0đ; `architecture.md` §6.4 · §7 · §12.2.

**Không làm thì mất gì:** két lệch mà không truy được về một thao tác; doanh thu tính hai lần khi thu nợ.

**Cách hoàn thành:**
1. Đọc `04-luoc-do-duong-tien.md`; `architecture.md` §6.3 · §6.4 · §7 · §12.2; hàng `I-005` `I-012`
   `I-014` `I-015` `I-021`; bộ đối chiếu `P2-11`; **ADR-075**; **U-058** ở `docs/product/99-unknowns.md`.
2. Khai scope; *In Progress*.
3. Test đỏ trước cho mọi vế tầng 3; một ngày bán giả qua cửa ⇒ đối soát 0đ; cài một lần thu sai ⇒ đối
   soát kêu.
4. Viết cửa; thu nợ theo **ADR-075** và lược đồ `04-luoc-do-duong-tien.md` đã cập nhật bởi T-126,
   không tự thêm luật cho chuỗi trả dần.
5. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng ghi một lần thu nợ thành một khoản bán mới (`YC-10`). Đừng tự đặt trần giảm giá.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-10"></a>
### P3-10 — Bếp không bấm gì, POS ghi hết — và chưa cửa nào ghi "bàn này đã được mấy cái"

**Phụ thuộc** · bước 10/14 · **cần xong trước:** `P3-07` · **chặn:** `P3-12` · **chỗ chặn:** **S-5** ·
đọc **F-044**

**Goal:** duyệt đơn sinh đủ việc trạm trong cùng giao dịch (`I-004`, canh ở tầng 2 — **ADR-056**) · một
lần bấm là một mẻ · POS ghi đã phục vụ (`architecture.md` §1.1) · phần chia về từng bàn khớp hai chiều
(`I-019`) · không phục vụ vượt số gọi (`I-020`) · ba trạm bếp **không có cửa ghi nào**. Đơn vị của lần
bấm *đã bưng* chờ **S-5**; vế ghi bánh làm sai của đơn huỷ dựng trên `wrong_make_note` (**T-127**, **ADR-077**).

**Vì sao có task này:** luật ghi của chủ quán 2026-08-31 — *POS là nơi duy nhất ghi tiến độ; ba trạm bếp
chỉ đọc*. `05-luoc-do-san-xuat.md` dựng chỗ cất; cửa thì chưa.

**Không làm thì mất gì:** bánh cộng cho bàn này thiếu cho bàn kia lúc đông khách; hoặc bếp phải bấm nút
giữa lúc tay đang tráng bánh.

**Cách hoàn thành:**
1. Đọc `architecture.md` §1.1 · §3.4 · §5; `05-luoc-do-san-xuat.md`; hàng `I-004` `I-019` `I-020`;
   `shop-facts.md` §5.4 · §7.2; **F-044** · **ADR-077** (`05-luoc-do-san-xuat.md`).
2. Khai scope; *In Progress*.
3. Test đỏ trước; liệt kê cửa ghi ⇒ không cửa nào gọi được từ vai trạm bếp.
4. Vế **S-5** ⇒ cửa từ chối kèm mã; không chọn *"theo bàn"* thay chủ quán.
   Vế ghi bánh làm sai: cửa ghi chú và cửa huỷ ghi chú theo **ADR-077**; *không bàn nào chờ* là người
   đứng quầy quyết (tầng 4) — không tự so khoá gom thay họ.
5. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng thêm một nút *"xong"* cho trạm bếp vì màn hình "trông thiếu" — đó là luật chủ quán, không
phải sơ suất.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-11"></a>
### P3-11 — Vết cập nhật đang ở chế độ mềm, và chỉ cửa của pha 3 mới bật được chế độ nghiêm mà không làm vỡ mọi thứ

**Phụ thuộc** · bước 11/14 · **cần xong trước:** `P3-05` · `P3-09` · **gỡ:** **F-046**

**Goal:** mọi cửa cập nhật khai lý do và người, vết giữ bản trước · bản sau (`I-018`); chế độ vết
**nghiêm** bật bằng một migration mới đi tới (`QC-05`), cùng lượt sửa test và dữ liệu mồi khai lý do
(**F-046** *Decision / Fix*); nhập bù lượt bán trên sổ giấy mang hai mốc (`YC-08`); mở · khép khoảng trực
quầy (`YC-15`).

**Vì sao có task này:** **F-046** hoãn chế độ nghiêm *"tốt nhất cùng lượt pha 3 dựng cửa ghi duy nhất"*.
Sổ giấy là đường suy giảm khi mất mạng (`01-ranh-gioi-he-thong.md` §3).

**Không làm thì mất gì:** một lần ghi đè lượt gọi không dựng lại được ⇒ thu thiếu tiền không ai biết.

**Cách hoàn thành:**
1. Đọc **F-046** nguyên văn và **ADR-081** (vết khi thêm dòng con, dựng ở `T-137`: chế độ nghiêm phải phủ cả trigger `record_revision_capture_added_line`); `06-luoc-do-nguoi-va-vet.md`; hàng `I-018`; `YC-08` · `YC-15`.
2. Khai scope (gồm `db/migrations/` cho **một file mới**, `db/tests/`, `db/seed/`); *In Progress*.
3. Test đỏ trước: sửa không lý do ⇒ từ chối; sửa qua cửa ⇒ vết đủ bốn thứ.
4. Migration mới bật chế độ nghiêm; `./scripts/db-check.sh` vẫn xanh.
5. Liệt kê mọi cửa cập nhật, mỗi cửa một test *sửa ⇒ có vết*.
6. **F-046** → *Fixed*; thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng sửa file migration đã commit để bật chế độ nghiêm (`QC-05`).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-12"></a>
### P3-12 — Sáu phụ thuộc ngoài có đường suy giảm trên giấy, và chưa lần nào bị cắt thử

**Phụ thuộc** · bước 12/14 · **cần xong trước:** `P3-10`

**Goal:** màn trạm nhận việc mới không cần tải lại; đơn mới báo cho quầy; mỗi phụ thuộc ngoài bị **cắt
thử** và hệ thống đi đúng đường suy giảm đã viết; mất kết nối thì không đơn nào tạo được (`I-008` vế
mất kết nối); màn đọc bắt lại trạng thái sau khi nối lại mà không mất việc nào.

**Vì sao có task này:** `05-realtime-va-du-phong.md` và `01-ranh-gioi-he-thong.md` §3 viết đường suy giảm
cho từng phụ thuộc — lời, chưa phải hành vi.

**Không làm thì mất gì:** bếp không thấy đơn lúc mạng chập, không ai biết cho tới khi khách hỏi.

**Cách hoàn thành:**
1. Đọc hai file trên; hàng `I-008`; `02-thoi-gian-ngay-ban.md` (nguồn thời gian khi nối lại).
2. Khai scope; *In Progress*.
3. Mỗi phụ thuộc một test cắt thử, dán output; không chọn lại đường suy giảm — lệch ⇒ `F-XXX` gửi ngược.
4. Thêm phần hợp đồng; gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng coi *"kênh đẩy chạy được"* là biên nhận — biên nhận là *"mất kênh đẩy thì vẫn đúng"*.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-13"></a>
### P3-13 — Mười lát backend sẽ tự khai là xong, mà chưa ai diễn một buổi bán qua chúng

**Phụ thuộc** · bước 13/14 · **cần xong trước:** `P3-02` → `P3-12` · **đây là chỗ các ô cổng kế hoạch §9
được KÝ**

**Goal:** file cổng chất lượng pha 3 ở `docs/product/3-be/`: ba scenario (`0-ba/ban-hang/08-scenario.md`
§8) đi hết **qua API** bằng lời gọi thật; mọi ô của kế hoạch §9 ký kèm bằng chứng, hoặc để trống kèm lý
do và mã.

**Vì sao có task này:** cùng lý lẽ `P2-13` và `P1-11` — chỗ hụt lộ ra khi diễn scenario, không khi đọc
từng mục.

**Không làm thì mất gì:** pha 4 dựng màn trên một backend chưa chạy nổi một buổi bán.

**Cách hoàn thành:**
1. Đọc `08-scenario.md` §8; kế hoạch pha 3 §9; cách cổng pha 2 được ký (file cổng của `P2-13`).
2. Khai scope; *In Progress*.
3. Diễn từng bước qua API; một ngày bán giả qua cửa ⇒ đối soát 0đ.
4. Ký từng ô §9 bằng đúng *cách chứng minh* viết kèm ô; ô không ký được ⇒ trống + mã.
5. Chỗ hụt ⇒ `F-XXX`/`U-XXX`, **không** sửa code trong lượt chấm.
6. `00-index.md`; gate; *Done*; *Bàn giao*; khối commit. **Ký chuyển pha 4 là quyền chủ repo.**

**Bẫy:** đừng tick một ô vì *"nhìn chung đạt"*.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p3-14"></a>
### P3-14 — Pha 3 là pha gần giao diện nhất, và hai lần trước một pha viết hộ pha sau đều lọt cổng

**Phụ thuộc** · bước 14/14 · **cần xong trước:** `P3-13` · **bước cuối của pha 3**

**Goal:** không component · route màn hình nào trong `docs/product/3-be/`; hợp đồng là **nguồn duy
nhất** (không bản chép ở file khác); mọi pointer pha 1/2 → pha 3 còn đúng.

**Vì sao có task này:** **F-040** · **F-041**; và **F-017** — một bộ lọc rỗng vì viết sai trông y hệt một
bộ lọc rỗng vì không có lỗi.

**Không làm thì mất gì:** pha 4 đọc giao diện do pha 3 viết hộ như đầu vào đã chốt.

**Cách hoàn thành:**
1. Đọc **F-017** · **F-040** · **F-041**; entry `P2-14`; header Gate 1d sau `P3-02`.
2. Khai scope; *In Progress*.
3. Chạy bộ lọc trên **mọi** file pha 3, **in cả lệnh chưa lọc cạnh lệnh đã lọc**.
4. `grep -rn '3-be'` và `grep -rn 'pha 3'` — mọi chỗ hứa *"việc của pha 3"* nay trỏ được vào một dòng thật.
5. Chỗ sai ⇒ `F-XXX`, không sửa trong lượt rà.
6. Gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng tin một output rỗng.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)
