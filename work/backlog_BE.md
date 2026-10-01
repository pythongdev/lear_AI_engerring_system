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
   có dòng ở *Ready* (**F-012**). Đo 2026-10-01 **không bước nào** nhận được: `P3-01` chờ chủ repo ký chuyển pha.
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
`P3-01` chỉ được nhận sau khi **chủ repo ký chuyển pha; hôm nay chưa ký**. Đường lùi migration
đã giải ở `P2-09`, **ADR-065** (mỗi bước một bước lùi có khoá chặn).
`P3-05` có câu về cách đăng nhập; `P3-08` · `P3-10` chờ **S-6** · **S-5**;
`P3-09` chờ **U-058**, đọc **F-048** (số tiền đếm cuối ngày chưa có chỗ cất); `P3-12` đọc **ADR-078** (T-132 — hai khoảng ngừng nhận đơn đã có chỗ cất, **F-050** đã đóng); vế ghi bánh làm sai của `P3-10` đọc **ADR-077** (T-127), đọc **F-044**;
`P3-11` gỡ **F-046**, đọc cùng **F-047** về vết khi thêm dòng con.
**U-063 đã đóng**, lược đồ thu nợ trả dần đã dựng ở **T-126**, **ADR-075**.
**U-064 đã đóng**; lược đồ có chỗ ghi bánh làm sai từ **T-127** (**ADR-077**).
Một bước bị chặn vẫn làm phần không phụ thuộc; cửa của phần bị chặn **từ chối kèm mã**,
không lấp bằng mặc định.

---

<a id="p3-01"></a>
### P3-01 — Pha 1 giao cho tầng 3 hàng chục vế "miền nghiệp vụ giữ", và chưa chỗ nào nói trong code chữ ấy nghĩa là gì

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 1/14 · **cần xong trước:** chủ repo ký chuyển pha
(đo 2026-10-01: chưa ký; pha 2 xong 2026-09-30, cổng 12/12 ở `11-cong-chat-luong-pha-2.md` §7) · **chặn:** mọi bước sau

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
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
   thêm vùng), **F-017** · **F-040** · **F-041**, ADR của `P3-01`.
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
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
   đặt múi giờ quán (`QC-06`).
4. Dựng `be/go.mod` và **một** test khói: kết nối database kiểm, đọc múi giờ phiên, thử một lệnh xoá ⇒
   bị từ chối (`QC-03`).
5. `scripts/verify.sh` gọi `go test` trong `be/` (`QC-09` *chỗ trống có tên*).
6. Dán output test và gate; *Done*; *Bàn giao*; khối commit.

**Bẫy:** đừng chọn bộ test chạy database giả trong bộ nhớ — tầng 1 và tầng 2 không tồn tại ở đó. Đừng
để hai lần chạy test dùng chung một database kiểm cố định (**F-045**).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
1. Đọc ADR của `P3-01`; `01-quy-uoc-du-lieu.md` (`QD` tiền · mốc · định danh); `QC-10` (tên ràng buộc);
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
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

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
1. Đọc **F-046** và **F-047** nguyên văn (vết khi thêm dòng con; Claude chọn cách gỡ cùng lượt); `06-luoc-do-nguoi-va-vet.md`; hàng `I-018`; `YC-08` · `YC-15`.
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
