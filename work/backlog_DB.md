<a id="top"></a>
# Backlog — pha 2 · DB

Mô tả dài của mười bốn bước `P2-01`…`P2-14`. Dựng 2026-09-20 (T-081) theo yêu cầu chủ repo trong
phiên: **"hãy làm backlog_db.md"**. Quyết định vì sao pha 2 có sổ riêng: `docs/decisions.md`
**ADR-036** luật 1 (một dãy mã riêng `P2-XX`, một chuỗi việc đọc liền nhau) và **ADR-049**; hình
dạng của file này chép của `work/backlog_SD.md` (**ADR-034**), sổ mô tả pha 1.

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Bước nào đang *Ready*, *In Progress* hay *Done*
> đọc ở `work/backlog.md` — đó là file `scripts/brief.sh` đọc và đẩy vào mọi phiên mới
> (`docs/decisions.md` **ADR-002**). Một dòng trạng thái viết ở đây là một dòng **không phiên nào
> thấy**.
>
> **Nó cũng không giữ thứ tự, mức, hay đầu ra kiểm chứng được của từng bước** — ba thứ đó ở
> [`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`](../master_plan/DB_master_plan_banh_cuon_ba_thanh.md) §6.
> Chép về đây là tạo bản thứ hai, và bản thứ hai luôn trôi (`work/findings.md` **F-001**).
>
> **Nó tuyệt đối không giữ một dòng lược đồ nào.** Không tên bảng, không tên cột, không khoá
> ngoại. Owner của lược đồ ra đời ở `P2-04`, trong `docs/product/2-db/` (`CLAUDE.md` §2,
> **ADR-035**). Một cái tên bảng viết sẵn ở đây là pha 2 tự chốt trước khi bước nào chấm nó.

## Ba file, ba việc — đọc bảng này trước khi sửa bất kỳ file nào

| Câu hỏi | Đọc ở |
|---|---|
| Pha 2 còn nợ gì · thứ tự · mức · đầu ra kiểm chứng được · cổng sang pha 3 | [`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`](../master_plan/DB_master_plan_banh_cuon_ba_thanh.md) |
| Bước nào **đang** chạy, xong chưa | [`work/backlog.md`](backlog.md) → *Ready* · *In Progress* · *Done* |
| **Vì sao** có bước này, hỏng thì mất gì, chạy mười bước thế nào, **xong là thế nào** (Nghiệm thu · Kiểm chứng) | **file này** |
| Sự thật nghiệp vụ, invariant, quyết định, lược đồ | owner ở `CLAUDE.md` §2 — không file nào ở trên |

## Luật của file này — bốn câu

1. **Mô tả cả mười bốn bước được viết trước; dòng trạng thái thì không.** Chỉ bước nào **nhận
   được ngay** mới có một dòng ở `work/backlog.md` → *Ready*. Lý do đo được: `brief.sh` cắt danh
   sách *Ready* ở sáu mục, nên mười bốn dòng đổ vào đó đẩy tám dòng ra khỏi tầm nhìn của mọi phiên
   mới — đúng cơ chế đã làm `U-011` và `BA-12` vô hình (**F-012**). Mô tả nằm ở file này thì không
   chiếm chỗ nào của brief.
2. **Entry là hồ sơ thực thi DUY NHẤT của bước** (**ADR-051**, 2026-09-25 — thay luật *entry TRỎ,
   prompt GIỮ* cho lane này). *Nghiệm thu* và *Kiểm chứng* viết vào khối **Nhận việc** cuối entry,
   không vào một file prompt riêng; lời gọi một phiên chỉ cần *"làm P2-XX theo entry của nó"*. Khối
   ấy chỉ điền được **khi mọi bước ở *Cần xong trước* đã `Done`** (T-051): sớm hơn thì nó là những
   câu đoán (**F-013** · **F-017**). Nghiệm thu **cụ thể hoá** cột *Đầu ra kiểm chứng được* của kế
   hoạch §6 cho lượt này, không chép lại nó.
3. **Bước xong thì entry ở lại đây** và nhận khối **Bàn giao** cuối entry: kết quả, output gate, phần
   còn thiếu kèm link tới owner. Bàn giao giữ **kết quả**, không giữ **trạng thái** — dòng `- [x]`
   ở `work/backlog.md` → *Done* là chỗ duy nhất nói bước đã xong (**ADR-051**). Không có mục *đã
   xong* riêng ở file này: mười bốn bước là một pha, tách đôi làm mất đường đọc từ `P2-01` tới
   `P2-14`.
4. **Bước mới của pha 2 vào đây, không vào `work/backlog.md`.** Task không thuộc pha 2 thì ngược
   lại. Ranh giới là *pha*, không phải *độ dài* (**ADR-036**).

## Mục lục

Mục lục không có cột trạng thái hay mức: trạng thái ở `work/backlog.md`, mức và thứ tự ở kế hoạch
§6 (**ADR-051**).

| Bước | Entry |
|---|---|
| P2-01 | [Ranh giới và từ vựng của cả pha 2](#p2-01) |
| P2-02 | [Gate 1d học vùng pha 2](#p2-02) |
| P2-03 | [Quy ước dữ liệu — và lượt mở `docs/product/2-db/`](#p2-03) |
| P2-04 | [Lược đồ lát bán hàng lõi](#p2-04) |
| P2-05 | [Lược đồ menu · giá · ảnh chụp giá lúc đặt](#p2-05) |
| P2-06 | [Lược đồ đường tiền](#p2-06) |
| P2-07 | [Lược đồ sản xuất theo mẻ](#p2-07) |
| P2-08 | [Lược đồ người · chỗ đứng theo thời điểm · vết](#p2-08) |
| P2-09 | [Thứ tự migration và đường lùi](#p2-09) |
| P2-10 | [Dữ liệu mồi](#p2-10) |
| P2-11 | [Bộ query đối chiếu bất biến](#p2-11) |
| P2-12 | [Quy ước code](#p2-12) |
| P2-13 | [Cổng chất lượng pha 2](#p2-13) |
| P2-14 | [Rà chéo ranh giới pha và pointer](#p2-14) |

**Thứ tự lấy việc, và cái gì chạy song song được: kế hoạch §6.** Đừng đọc thứ tự từ mục lục trên —
nó xếp theo số, còn phụ thuộc thật thì không. `P2-01` · `P2-02` · `P2-03` đã `Done`
(2026-09-22 · 09-24 · 09-26), nên bước duy nhất vừa hết chặn — **`P2-12`** — có dòng ở
`work/backlog.md` → *Ready*. Năm lát `P2-04`…`P2-08` còn chờ chính `P2-12` (**ADR-053** luật 1), nên
chưa có dòng trạng thái: `brief.sh` cắt *Ready* ở sáu mục (**F-012**).

**Chỗ đang chặn, đo ngày 2026-09-20** — mỗi chỗ ghi ở owner của nó, đếm lại ở đó chứ đừng tin con
số trong câu này (`work/findings.md` **F-003**). Bảng sống ở kế hoạch §8; bảng dưới đây chỉ là bản
đọc nhanh theo bước:

| Mã | Chỗ thiếu | Chặn bước | Ai gỡ |
|---|---|---|---|
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`master_plan/shop-facts.md` §7.2 — chỗ *suy ra*, **chưa hỏi**) | `P2-07` — ô ấy **để trống**, đừng điền | chủ quán |
| **S-6** | với đơn giao tận nơi, quầy bấm mốc *"đã ra bàn"* **lúc nào** (§7.2) | `P2-07` | chủ quán |
| **F-034** | Đã Fixed 2026-09-27: yêu cầu YC-21 có owner (ADR-057); cơ chế chưa triển khai | `P2-09` đọc yêu cầu | **pha 5**, T-109 |
| ~~**F-036**~~ | ~~hai vế thiếu tầng~~ — **đã đóng 2026-09-27** (T-103, **ADR-056**): nước chấm · canh của `I-004` **tầng 2** trong giao dịch nổ đơn; ngừng bán của `I-009` **tầng 3**, không ràng buộc | `P2-07` dựng hai loại việc trạm `canh` theo hàng `I-004` | — |
| ~~**F-037**~~ | ~~khoản **trả trước** không có dòng trong bảng đối soát~~ — **đã đóng 2026-09-28** (T-112, **ADR-059**): **ba** dòng trả trước ở `architecture.md` §6.4, hạng tử ở `I-021`, `YC-23` | `P2-06` dựng chỗ cất `YC-23` · `P2-11` có câu truy vấn cho ba dòng | — |
| ~~**F-038**~~ | ~~*thiếu một trường bắt buộc thì đơn không tạo được* chưa có mệnh đề, chưa có tầng, chưa có dòng `YC`~~ — **đã đóng 2026-09-28** (T-110, **ADR-058**): `I-022` **tầng 1** cho bốn vế *thiếu thì không tồn tại được*, `YC-22` | `T-111` — migration mới dựng chỗ cất và ràng buộc | — |
| ~~**F-042**~~ | ~~mã QR của bàn *không đoán được và đổi được* chưa có mệnh đề~~ — **đã đóng 2026-09-28** (T-113, **ADR-060**): `I-023` — hai vế tầng 1 (*một mã một bàn* · *lần đổi có vết*), ba vế tầng 3, `YC-24`; *ai đổi, khi nào* là **U-062** | `T-114` — migration mới dựng chỗ cất và ràng buộc; `P2-10` sinh mã qua cửa sinh mã sau `T-114` | — |
| ~~**F-043**~~ | ~~*một lần gửi đơn thành đúng một đơn* chưa có mệnh đề~~ — **đã đóng 2026-09-28** (T-115, **ADR-061**): `I-024` — hai vế tầng 1 (*một dấu lần gửi một đơn* · *không đơn nào thiếu dấu*), ba vế tầng 3, `YC-25`; nội dung giống hệt **không** phải là trùng | `T-116` — migration mới dựng chỗ cất dấu và ràng buộc | — |

⚠️ **Một bước bị chặn vẫn chạy được phần không phụ thuộc câu trả lời**, và ghi chỗ trống ra kèm mã
— đúng cách `P1-04` xử `I-014` và `P1-07` xử `S-5`. Cái **không** được làm là lấp chỗ trống bằng
một mặc định rồi chạy tiếp: một lược đồ tự chọn *"bấm theo bàn"* là một lược đồ đã thay chủ quán
trả lời một câu **chưa ai hỏi**, và cái sai ấy chỉ lộ ra lúc quán dùng thật
([`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) §6).

⚠️ **`U-054` không chặn bước nào ở đây.** Nó là câu của lane **admin** (`work/backlog_AD.md`) —
hai con số *tổng* của vế nguyên liệu cộng dồn từ mốc nào. Lane admin chạy **song song** pha 2 ở
nghĩa **thu luật**, không ở nghĩa thi công (`work/backlog.md` → *Thứ tự làm giữa lane admin và các
pha*, chủ quán chốt 2026-09-20).

⚠️ **Lane `prompt/DB/` chưa tồn tại tính tới 2026-09-20.** Lượt nào tạo ra nó phải **thêm nó vào
danh sách Gate 1b chấm** (`scripts/check-links.sh`) trong **cùng thay đổi** — đúng việc `P1-01` đã
làm cho `prompt/SD/` và `T-058` cho `prompt/AD/`. Một lane prompt không nằm trong danh sách ấy là
lane pointer **không cổng nào đọc** (**F-007**).

---

<a id="p2-01"></a>
### P2-01 — Pha 1 viết *"phải do cơ sở dữ liệu giữ"* hai mươi mốt lần, và không chỗ nào nói câu ấy dịch sang pha 2 thành cái gì

**Prompt:** [`prompt/DB/P2-01-ranh-gioi-tu-vung-pha-2-L2.md`](../prompt/DB/P2-01-ranh-gioi-tu-vung-pha-2-L2.md)
(viết 2026-09-22 lúc nhận việc, sáu khối theo `docs/prompt-guideline.md`) ·
**L2** · bước 1/14 (kế hoạch §6) · **không bị bước nào chặn** — bước duy nhất như vậy của pha 2 ·
**mở khoá** cả mười ba bước còn lại (§6: `P2-02` và `P2-03` ghi thẳng *Cần xong trước: P2-01*, và
mọi bước sau đứng trên hai bước ấy)

**Goal:**
Xong rồi thì câu *"hàng **tầng 1** này phải thành cái gì trong lược đồ"* có **đúng một** câu trả
lời, đọc được ở một ADR, và mười ba bước sau trích được từ nó thay vì tự định nghĩa lại chữ *ràng
buộc*. Cổng §9 của kế hoạch có một thước để chấm, thay vì một cảm giác.

**Nói một câu, việc phải làm là gì:**
Chốt **ranh giới và từ vựng của cả pha 2** thành một ADR: năm tầng của pha 1 dịch sang pha 2 thành
cái gì (kế hoạch §7), và ba câu pha 2 **không** được viết ra (§3). Việc **không** phải làm: đừng
viết một dòng lược đồ nào, đừng đặt một cái tên bảng nào, đừng mở `docs/product/2-db/` — thư mục ấy
ra đời ở `P2-03`, cùng dòng nội dung đầu tiên của nó.

**Vì sao có task này:**
`docs/product/1-system-design/03-bao-ve-invariant.md` (pha 1, `P1-04`…`P1-06` · `P1-13` · `P1-14`)
điền cột giữa của mỗi mệnh đề bằng **đúng một** trong năm tầng, và tầng 1 ghi *"phải do cơ sở dữ
liệu giữ"*. Đó là một câu **gửi sang pha 2**, không phải một câu mô tả hiện trạng — pha 1 cố ý
không nói *"đã do"*. Chừng nào chữ ấy chưa được dịch, mỗi lát trong năm lát lược đồ
(`P2-04`…`P2-08`) sẽ tự hiểu nó một kiểu: lát này dựng một khoá duy nhất, lát kia viết một dòng
bình luận rồi coi là đã giữ. **ADR-035** (2026-09-04) đã chốt *ai sở hữu* lược đồ; bước này chốt
*sở hữu ấy phải sinh ra hình dạng gì*.

**Không làm thì mất gì:**
- **Hạ tầng trong im lặng.** Lát nào dựng không nổi ràng buộc cho một hàng *tầng 1* sẽ lặng lẽ coi
  nó là tầng 3 (*miền nghiệp vụ giữ*), vì tầng 3 không đòi một dòng lược đồ nào. Kế hoạch §7 luật 1
  cấm đúng việc này, nhưng luật ấy chỉ có hiệu lực nếu có một ADR để trỏ vào.
- **Cổng §9 không chấm được gì.** Ô thứ ba của cổng đòi *"dán nguyên lời từ chối của database khi
  cố dựng trạng thái sai"*. Không có từ vựng chung thì ô ấy được tick bằng cảm giác, đúng thứ cổng
  pha 1 đã mất mười ngày để bỏ (`07-cong-chat-luong-pha-1.md`).
- **Hậu quả ở quán:** một mệnh đề chạm tiền tụt tầng mà không ai thấy nghĩa là cái duy nhất chặn nó
  là người thao tác nhớ đúng luật, lúc đông khách. `I-001` (*một bàn nhiều nhất một phiên chưa
  thanh toán*) tụt tầng ⇒ hai hoá đơn trên một bàn, một trong hai không ai thu.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở [`work/backlog.md` → *Vòng chạy một task L1*](backlog.md#vong-chay); dưới đây là việc
riêng của bước này.

1. Đọc kế hoạch §3 (ba câu không được viết), §7 (bảng năm tầng và ba luật), và
   [`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md) §1–§4 — đọc
   **danh sách mã**, đừng đọc một con số đếm (**F-026** · **F-018**). Đọc luôn **ADR-035** và
   **ADR-039**.
2. Khai `work/scope.txt`: khối `P2-01` — `docs/decisions.md`, `work/backlog.md`,
   `work/backlog_DB.md`, `prompt/DB/`. **Thêm** khối, không ghi đè khối của phiên khác (**F-010** ·
   **F-014**).
3. Chuyển dòng `P2-01` từ *Ready* sang *In Progress* ở `work/backlog.md`.
4. Viết prompt `prompt/DB/P2-01-…-L2.md` theo `docs/prompt-guideline.md` (sáu khối), và **cùng lượt
   ấy** thêm `prompt/DB/*` vào `scripts/check-links.sh` — lane không nằm trong danh sách Gate 1b là
   lane không cổng nào đọc (**F-007**).
5. Viết ADR mới: mỗi tầng trong năm tầng ⇒ pha 2 nợ **cái gì** và chấm **bằng gì**; cộng ba câu pha
   2 không được viết ra. Gặp một chỗ phải chọn giữa hai cách dịch ⇒ đó là câu của **chủ repo**, hỏi
   trước khi ghi; gặp một chỗ nghiệp vụ chưa rõ ⇒ `U-XXX` (`CLAUDE.md` §3.5 — **không có mức L0**).
6. Chạy `./scripts/gate.sh`. Lượt này chỉ đổi tài liệu + một script nên `verify.sh` chạy vì
   `scripts/*.test.sh` có đổi; Gate 1b · 1c · 1d vẫn chạy như mọi lượt.
7. Gate 2: mỗi dòng *Acceptance* của prompt trỏ tới một dòng thật trong ADR vừa viết.
8. `grep -rn` cụm *"tầng 1"* và *"phải do cơ sở dữ liệu giữ"* — mọi pointer nói ngược ADR mới là bug
   của **lượt này**, không phải task sau (`CLAUDE.md` §7.2).
9. Tick `P2-01` ở `work/backlog.md` → *Done*; entry này **ở lại đây** kèm dòng *✅ Xong ngày…*, cột
   *Trạng thái* ở *Mục lục* đổi sang **Đóng** trong cùng lượt. Thêm dòng *Ready* cho `P2-02` và
   `P2-03` — hai bước vừa hết chặn. Xoá khối scope của mình.
10. Khối `git commit` dán được, liệt kê từng file lấy từ `git diff --name-only HEAD`, **không** kèm
    `work/scope.txt`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng viết một lược đồ mẫu "cho dễ hiểu".** Một ví dụ `CREATE TABLE` trong ADR này sẽ được mười
  ba bước sau đọc như lược đồ đã chốt — đúng cách đề xuất 16 bảng ngày 2026-08-31 suýt trở thành
  lược đồ thật (kế hoạch §10).
- **Đừng mở `docs/product/2-db/` ở lượt này** để "đỡ phải mở sau". Một file rỗng có tên sẵn là tài
  liệu nghi lễ (`CLAUDE.md` §3.8), và kế hoạch §5 chốt thư mục ra đời ở `P2-03`.
- **Đừng gộp bước này với `P2-03`.** Bước này quyết *tầng 1 nghĩa là gì*; `P2-03` quyết *tiền cất
  bằng gì*. Gộp là để một lượt vừa đặt thước vừa dùng thước.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc (**F-001** — entry này trỏ, prompt
giữ).

**Bàn giao (2026-09-22):** `docs/decisions.md` **ADR-050**: bảng năm tầng **bốn** cột (*pha 2 nợ
cái gì* · *chấm bằng gì* · **cái gì KHÔNG phải biên nhận**), **ba luật khi dịch**, và **ba câu pha 2
không được viết ra** kèm *viết gì thay vào*. Lane **`prompt/DB/`** dựng cùng lượt, và `prompt/DB/*`
vào danh sách Gate 1b chấm (`scripts/check-links.sh`) — chứng minh bằng một đường dẫn cố tình sai ⇒
gate **đỏ**, sửa lại ⇒ **xanh** (**F-007**). **Một chỗ dọn phát sinh giữa lượt:** ADR-050 nhận
quyền sở hữu bảng năm tầng, nên **§7 của kế hoạch pha 2 thôi giữ bản chép của mình và chỉ còn trỏ**
— bản thứ hai luôn trôi (**F-001**), và dọn nó là bug của chính lượt ấy (`CLAUDE.md` §7.2). Mọi
pointer viết *"kế hoạch §7"* vẫn đọc được; số hiệu ba luật giữ nguyên 1 · 2 · 3.
**Không** file nào dưới `docs/product/2-db/` tồn tại sau lượt này — thư mục ấy vẫn là của `P2-03`.
⇒ **`P2-02` và `P2-03` hết bị chặn.** Trạng thái: `work/backlog.md` → *Done*.

[↑ đầu file](#top)

---

<a id="p2-02"></a>
### P2-02 — Cổng duy nhất biết chặn một pha viết hộ pha sau chỉ đọc thư mục pha 1, và bộ mẫu SQL của nó sẽ đỏ với đúng thứ pha 2 phải viết

**Prompt:** [`prompt/DB/P2-02-gate-1d-vung-pha-2-L2.md`](../prompt/DB/P2-02-gate-1d-vung-pha-2-L2.md)
(viết 2026-09-24 lúc nhận việc) · **L2** · bước 2/14 (kế hoạch §6) · **cần xong trước:** `P2-01`,
**đã xong 2026-09-22** · **không** chặn bước nào, nhưng mọi bước viết file pha 2 chạy **mù** cho
tới khi nó xong · chạy song song được với cả dãy

**Goal:**
Xong rồi thì `scripts/check-phase-boundary.sh` đỏ khi một file pha 2 mang **endpoint · route ·
component**, và **xanh** khi file ấy mang SQL — thứ pha 2 có quyền viết. Ranh giới pha có cổng gác
ở cả hai vùng, không chỉ ở vùng pha 1.

**Nói một câu, việc phải làm là gì:**
Dạy Gate 1d vùng `docs/product/2-db/`: một bộ mẫu **khác** bộ mẫu của vùng pha 1, cộng ca hồi quy
trong `scripts/check-phase-boundary.test.sh`. Việc **không** phải làm: đừng nới bộ mẫu của vùng pha
1 cho "thống nhất" — nới nó là gỡ đúng cái cổng `T-079` vừa dựng.

**Vì sao có task này:**
`scripts/check-phase-boundary.sh` (Gate 1d, **ADR-039**) hôm nay chỉ đọc
`docs/product/1-system-design/`, và nó đỏ khi thấy từ khoá SQL. Pha 2 **phải** viết từ khoá SQL —
đó là đầu ra của nó. Nên tính tới 2026-09-20, vùng pha 2 có **không** cổng nào: mười một file sắp
sinh ra ở `docs/product/2-db/` chạy ngoài tầm mọi phép chấm tự động. Đây là đúng hình của
**F-041** (pha 1 viết hộ pha sau mà cổng mù), chỉ khác một chỗ làm nó nặng hơn: lần ấy có `P1-12`
và người đứng đọc; lần này pha 2 có mười một file và `P2-14` đứng ở **cuối**.

**Không làm thì mất gì:**
- **Pha 2 viết endpoint suốt mười một file mà không cổng nào đỏ.** Pha 3 mở ra và đọc những dòng
  ấy như hợp đồng API đã chốt — lần thứ hai của `F-040` · `F-041`.
- **`P2-14` gánh một mình.** Một vòng rà thủ công ở cuối pha bắt được cái sai sau khi nó đã đứng
  trong tài liệu nhiều ngày và đã có pointer trỏ vào; sửa lúc ấy đắt hơn chặn lúc viết.
- **Hoặc ngược lại: ai đó nới bộ mẫu vùng pha 1 cho khỏi vướng**, và từ hôm ấy tài liệu pha 1 lại
  đặt được tên bảng — mất luôn cái Gate 1d sinh ra để giữ.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `scripts/check-phase-boundary.sh` **nguyên văn** (header comment giữ cơ chế — `CLAUDE.md`
   mở đầu), `scripts/check-phase-boundary.test.sh`, `scripts/check-phase-boundary.ignore`, và ADR
   của `P2-01`.
2. Khai `work/scope.txt`: khối `P2-02` — `scripts/check-phase-boundary.sh`, file test của nó,
   `work/backlog.md`, `work/backlog_DB.md`, `prompt/DB/`.
3. Chuyển `P2-02` sang *In Progress*.
4. Thêm vùng `docs/product/2-db/` với bộ mẫu **riêng**: đỏ với HTTP verb + `/api/`, với JSX-looking
   tag, với hình dạng route; **im lặng** với từ khoá SQL. Giữ nguyên hành vi vùng pha 1.
5. Không có dữ kiện nghiệp vụ nào ở bước này. Gặp một hình dạng không chắc nên đỏ hay không ⇒ để
   **im lặng**: Gate 1d cố ý bảo thủ (`CLAUDE.md` §5.4), và một cổng đỏ sai dạy người ta gỡ cổng.
6. Viết ca hồi quy **mới** cho vùng pha 2 (đỏ · xanh), rồi chạy `./scripts/gate.sh` và xác nhận
   **cả bộ ca cũ vẫn xanh** — dán output.
7. Gate 2: mỗi dòng *Acceptance* map vào một ca test có tên, không vào một câu khẳng định.
8. `grep -rn 'check-phase-boundary'` — `CLAUDE.md` §5.4 và `README.md` mô tả cổng này; câu nào nay
   hết đúng là bug của **lượt này**.
9. Tick `P2-02` → *Done*; dòng *✅ Xong ngày…* + cột *Trạng thái* ở *Mục lục*. Xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng để bộ lọc mới im lặng vì viết sai.** Một bộ lọc rỗng vì regex hỏng trông y hệt một bộ lọc
  rỗng vì không có lỗi (**F-017**) — nên ca test phải có **một ca đỏ thật**, không chỉ ca xanh.
- **Đừng thêm vùng pha 3 · pha 4 "luôn thể".** Thư mục của chúng chưa tồn tại, và một bộ mẫu viết
  cho một vùng chưa có nội dung là một bộ mẫu chưa bao giờ được chấm.
- **Đừng dùng `.ignore` để chữa một bộ mẫu sai.** Dòng ignore là cho **một chỗ trích cố ý**, kèm lý
  do; dùng nó để im một lớp lỗi là gỡ cổng bằng cửa sau.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc (**F-001**).

**Bàn giao (2026-09-24):** `scripts/check-phase-boundary.sh` nay đọc **hai vùng, hai bộ mẫu**:
vùng pha 1 giữ **nguyên** hành vi cũ (đỏ với SQL · endpoint · route), vùng `docs/product/2-db/` đỏ
với **endpoint · route · component** và **im lặng với SQL** — vì SQL là đầu ra hợp lệ của pha 2
(**ADR-049** · **ADR-050**). Mẫu endpoint của hai vùng **khác nhau có lý do đo được**: mẫu pha 1
nhận `DELETE` + khoảng trắng + chữ, nên ở vùng pha 2 nó sẽ kêu oan `ON DELETE CASCADE` và
`DELETE FROM …` ở **mọi** lát lược đồ có khoá ngoại; mẫu vùng pha 2 vì thế đòi một **dấu gạch
chéo nằm trong đường dẫn** ngay sau động từ — vẫn bắt được `POST staff/debts/:id/collect` (hồi quy
**F-041**) mà không kêu oan SQL. Bộ ca lên **mười tám**: mười ca cũ xanh **không đổi một kỳ vọng
nào**, tám ca mới cho vùng pha 2, trong đó ca *SQL có `DELETE` không bị kêu oan* là thứ duy nhất
chặn việc "dọn cho gọn" bằng cách gộp hai bộ mẫu về một. Vùng pha 3 và pha 4 **cố ý không thêm**:
thư mục của chúng chưa tồn tại, và một bộ mẫu viết cho vùng chưa có nội dung là bộ mẫu chưa bao giờ
được chấm (**F-017**). `scripts/check-phase-boundary.ignore` **không thêm mục nào**.
Trạng thái: `work/backlog.md` → *Done*.

[↑ đầu file](#top)

---

<a id="p2-03"></a>
### P2-03 — Năm lát lược đồ sắp chạy song song, mà không chỗ nào nói tiền cất bằng gì và mốc cất bằng gì

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 3/14 (kế hoạch
§6) · **cần xong trước:** `P2-01` · **chặn** `P2-04` · `P2-05` · `P2-06` · `P2-07` · `P2-08` ·
`P2-12` — sáu bước, nhiều nhất pha 2; năm lát còn chờ thêm `P2-12` (**ADR-053** luật 1) · **lượt
này MỞ `docs/product/2-db/`**

**Goal:**
Xong rồi thì tiền, mốc thời gian, khoá, cách đặt tên, trạng thái và luật *không xoá cứng* có **đúng
một** cách làm, viết ra, mỗi cái kèm **hậu quả nếu làm khác**. Năm lát lược đồ chạy song song mà
vẫn cộng được tiền với nhau.

**Nói một câu, việc phải làm là gì:**
Viết **quy ước dữ liệu** của cả pha vào file đầu tiên của `docs/product/2-db/`, và trong **cùng
thay đổi** mở thư mục ấy: một dòng ở `docs/product/00-index.md` (hàng *Pha 2* từ **chưa mở** sang
**đang mở**) và một hàng chủ ở `CLAUDE.md` §2. Việc **không** phải làm: đừng dựng bảng nào — bước
này viết *từ vựng*, không viết lược đồ.

**Vì sao có task này:**
Kế hoạch §6 cho phép `P2-04`…`P2-08` chạy **song song** sau bước này. Song song là thứ chỉ an toàn
khi năm lát dùng chung một từ vựng: `I-014` (*doanh thu một ngày cộng từ đủ hai nguồn*) và `I-021`
(*két cuối ngày trừ tiền đầu két*) là **phép cộng ngang qua nhiều lát**, và một phép cộng không
chạy nổi nếu lát tiền cất một kiểu còn lát sản xuất cất kiểu khác.
[`02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md) §5 giao
thẳng cho pha 2 đúng một câu: *cất mốc **thế nào**, kiểu gì — mục này cố ý không nói*. Đây là chỗ
trả lời nó.

**Không làm thì mất gì:**
- **Phép cộng tiền cuối ngày không cộng nổi.** Năm lát cất tiền theo năm kiểu ⇒ `I-014` và `I-021`
  chỉ tồn tại trên giấy, và **ngưỡng lệch 0đ** (`master_plan/shop-facts.md` §6.10) — cổng chất
  lượng mạnh nhất của cả dự án — không thực hiện được.
- **Mốc tính tiền trôi theo múi giờ của máy khách.** `YC-18`…`YC-20` đòi mỗi việc chạm tiền mang
  **đúng một** mốc quyết định ngày của nó và mốc ấy **không dời**; không có quy ước thì mỗi lát tự
  chọn nguồn thời gian, và một ngày bán cộng nhầm sang ngày khác.
- **Xoá cứng một bản ghi.** Không có luật *không xoá cứng* thì vết (`I-018`, `YC-12`…`YC-14`) chết
  theo bản ghi nó nói về, và `YC-12` hỏng đúng ở chỗ nó sinh ra để giữ.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc ADR của `P2-01`; [`02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md)
   §2 · §5; `quality/invariants.md` `I-014` · `I-015` · `I-018` · `I-021`;
   [`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) `YC-12`…`YC-14`
   và `YC-18`…`YC-20`; `docs/product/00-index.md` → *Luật ghi*.
2. Khai `work/scope.txt`: khối `P2-03` — `docs/product/2-db/`, `docs/product/00-index.md`,
   `CLAUDE.md`, `work/backlog.md`, `work/backlog_DB.md`.
3. Chuyển `P2-03` sang *In Progress*.
4. Viết file quy ước: **mỗi quy ước một dòng, mỗi dòng một hậu quả nếu làm khác và một phép kiểm
   chạy được** — một câu truy vấn hoặc một lệnh (**ADR-053** luật 3). DBMS chưa chốt ở bước này
   (`P2-12` chốt), nên phép kiểm viết trên thứ không phụ thuộc DBMS: câu truy vấn trên
   `information_schema` chuẩn SQL, hoặc một lệnh đọc file migration. Mỗi phép mang mã của quy ước
   nó gác, vì `P2-11` gom chúng vào bộ đối chiếu thành một nhóm riêng. Tối thiểu sáu chủ đề kế hoạch
   §6 kể tên — tiền · mốc và múi giờ · khoá · đặt tên · trạng thái · không xoá cứng — **cộng một
   chủ đề thứ bảy, *văn bản và định danh***. Ba chỗ dự án cũ đã trả giá, mỗi chỗ vào đúng chủ đề
   của nó, kèm phép kiểm như mọi quy ước khác. Mục ghi cạnh từng ý là mục của
   `work/proposals/from_old_project/data_base/nghien-cuu.md` — bằng chứng của dự án cũ, không phải
   dữ kiện quán này:
   - ***Văn bản và định danh*** (§2.2): cách so và sắp xếp chuỗi chọn **theo vai trò cột**. Văn bản
     cho người đọc thì so và sắp xếp đúng tiếng Việt; định danh máy đọc và chuỗi băm thì so **từng
     byte, phân biệt hoa thường**. Hậu quả nếu làm khác: hai định danh khác nhau va nhau ở một khoá
     duy nhất, hoặc một chuỗi băm bị so lỏng; và đổi cách so **sau khi có dữ liệu** là dựng lại cả
     bảng lẫn mọi chỉ mục — rẻ nhất đúng ở lượt này.
   - ***Mốc*** (§1.7): kiểu cất mốc không được mang **giới hạn năm 2038** mà một số kiểu có; và mọi
     kết nối — **kể cả kết nối của môi trường test** — đọc mốc trong **cùng một** múi giờ với môi
     trường chạy thật. Dự án cũ lệch 7 tiếng chỉ trong test (§4.4), nên test đầu tiên của luật giờ
     bán sẽ đỏ hoặc **xanh nhầm**. `P2-12` biến vế kết nối thành lệnh của khung test.
   - ***Tiền*** (§2.7): quan hệ số học giữa các cột tiền **trong cùng một bản ghi** (ví dụ thành tiền
     của một dòng = đơn giá × số lượng) do **database** giữ — bằng ràng buộc kiểm, hoặc bằng cột tự
     tính. Hậu quả nếu làm khác: một lỗi làm tròn nằm im trong dữ liệu và được cộng vào doanh thu
     như tiền thật. Tổng đi **qua nhiều bản ghi** không thuộc quy ước này — nó là một câu đối chiếu
     của `P2-11`.
5. Gặp một chỗ nghiệp vụ chưa rõ (ví dụ: đơn vị nhỏ nhất của tiền ở quán) ⇒ **hỏi chủ quán**, hoặc
   `U-XXX`. Không có mức L0 cho luật này (`CLAUDE.md` §3.5).
6. Trong **cùng** thay đổi: `docs/product/00-index.md` thêm dòng file mới **và** đổi hàng *Pha 2*
   sang **đang mở**; `CLAUDE.md` §2 thêm hàng *Quy ước dữ liệu* trỏ vào file này (**ADR-035** luật
   2). Chạy `./scripts/gate.sh` — lượt này là lượt **đầu tiên** Gate 1d gặp thư mục pha 2, nên đọc
   kỹ output của nó.
7. Gate 2: mỗi dòng *Acceptance* trỏ vào một dòng thật trong file quy ước, và **mỗi quy ước có
   phép kiểm của nó ngay trên dòng ấy** — đếm bằng danh sách mã, không bằng một con số (**F-026**).
   Phép kiểm chưa chạy được vì chưa có bảng nào thì ghi rõ thế; `P2-12` chạy nó lần đầu trên DBMS
   vừa chọn, `P2-11` gom nó vào bộ và chứng minh nó biết kêu.
8. `grep -rn 'chưa có owner'` ở `CLAUDE.md` — hàng nào nay đã có chủ mà vẫn nói *chưa có* là bug của
   **lượt này**.
9. Tick `P2-03` → *Done*; điền khối **Bàn giao**; thêm dòng *Ready* cho năm lát vừa hết
   chặn — **nhưng đọc luật 1 đầu file trước**: `brief.sh` cắt *Ready* ở sáu mục.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng chép một bảng giá hay một dữ kiện quán vào file quy ước.** Quy ước nói *cất bằng gì*, không
  nói *giá bao nhiêu* — giá có nhà ở `master_plan/shop-facts.md` (**ADR-001** · **F-001**).
- **Đừng mở thư mục bằng một file rỗng rồi điền sau.** Kế hoạch §5 luật 1: file sinh ra **cùng** dòng
  nội dung đầu tiên của nó.
- **Đừng viết quy ước mà không viết hậu quả.** Một dòng *"tiền cất bằng số nguyên"* không có hậu quả
  kèm theo là một dòng ai cũng sửa được ở lát sau mà không thấy mình đang phá cái gì.
- **Đừng để phép kiểm thành lời hứa.** Dự án cũ viết sẵn câu truy vấn chặn cột tiền không phải kiểu
  nguyên, ghi *"thêm vào CI"*, rồi không lệnh nào gọi tới nó — bằng chứng của dự án cũ ở
  `work/proposals/from_old_project/data_base/nghien-cuu.md` §1.1, không phải dữ kiện của quán này.
  Một quy ước mà phép kiểm của nó chỉ nằm trong lời văn là quy ước tự trôi (**ADR-053** luật 3).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* nhận 2026-09-26, Claude Code, nhánh `chatgpt_involve`, base `cf048d4`. Scope:
  `docs/product/2-db/` · `docs/product/00-index.md` · `CLAUDE.md` · `work/backlog.md` ·
  `work/backlog_DB.md`. **Không** ADR: lựa chọn của phiên nằm ngay trong file quy ước, có nhãn
  *phiên chọn* và chờ chủ repo, vì `docs/decisions.md` dành ADR cho quyết định có lời người thật.
- *Nghiệm thu:* (N1) file quy ước dữ liệu mở `docs/product/2-db/`, mỗi quy ước một mục mang mã
  `QD-XX`, phủ **bảy** chủ đề: đặt tên · khoá · tiền · mốc và múi giờ · trạng thái · không xoá cứng
  · văn bản và định danh. (N2) Mỗi mục có đủ ba ô *hậu quả nếu làm khác* · *phép kiểm* · *nguồn*.
  Phép kiểm là câu truy vấn trên `information_schema` hoặc một lệnh; chỗ nào cần thứ `P2-12` chốt
  thì ghi tên tham số. (N3) Ba bài học T-097 (văn bản và định danh, mốc 2038 và múi giờ kết nối
  test, quan hệ số học trong một bản ghi) mỗi bài có đúng một mã. (N4) Không có con giá, tên kiểu
  của một DBMS hay tên bảng nào. (N5) `00-index.md` có hàng *Pha 2* **đang mở** và một dòng trỏ
  file mới; `CLAUDE.md` §2 có hàng *Quy ước dữ liệu*; hàng *Schema* và *Quy ước code* vẫn ghi
  *chưa có owner*. (N6) Chỗ nghiệp vụ chưa rõ thì trỏ `U-XXX`, không tự quyết.
- *Kiểm chứng:* `grep -o 'QD-[0-9]*'` trên file mới, liệt kê theo chủ đề (N1, N3). Một lệnh đếm
  mục `QD` thiếu ô, in cả danh sách chưa lọc (**F-017**) (N2). `grep` giá có dấu chấm nghìn · tên
  kiểu DBMS · tên bảng cũ trên file mới ⇒ rỗng (N4). `grep -n 'chưa có owner' CLAUDE.md` (N5).
  `./scripts/gate.sh` xanh, đọc riêng dòng Gate 1d vì lượt này là lượt đầu nó gặp vùng pha 2.

**Bàn giao (2026-09-26):** mở `docs/product/2-db/` bằng
[`01-quy-uoc-du-lieu.md`](../docs/product/2-db/01-quy-uoc-du-lieu.md) — **mười tám** mục, đếm bằng
danh sách mã: `QD-01` `QD-02` `QD-03` (đặt tên) · `QD-10` `QD-11` (khoá) · `QD-20` `QD-21` `QD-22`
(tiền) · `QD-30`…`QD-34` (mốc và múi giờ) · `QD-40` (trạng thái) · `QD-50` `QD-51` (không xoá cứng)
· `QD-60` `QD-61` (văn bản và định danh). Nghiệm thu → bằng chứng:
- **N1 · N3** — `grep -oE '^### QD-[0-9]+'` ra đúng mười tám mã trên, bảy chủ đề. Ba bài học T-097:
  văn bản và định danh ⇒ `QD-60` · `QD-61` (hai vai trò, hai mã); mốc ⇒ `QD-30` vế (b) giới hạn
  2038 và `QD-32` múi giờ kết nối test; quan hệ số học trong một bản ghi ⇒ `QD-22`. Bài 1 và bài 2
  mỗi bài hai mã vì mỗi bài có hai vế kiểm khác nhau — lệch khỏi chữ *đúng một mã* của N3, ghi ra.
- **N2** — lệnh `awk` in từng mã kèm ba cờ *hậu quả · phép kiểm · nguồn*: cả mười tám mã `1 1 1`,
  danh sách thiếu ô **rỗng**.
- **N4** — `grep` giá có dấu chấm nghìn · tên kiểu DBMS · tên bảng/cột dự án cũ trên file mới ⇒
  exit 1, **rỗng**. Tên kiểu cụ thể là tham số `:kieu_moc` · `:collation_*` do `P2-12` điền.
- **N5** — `docs/product/00-index.md`: hàng *Pha 2* **đang mở**, bảng *Pha 2 — Database* có một
  dòng. `CLAUDE.md` §2: hàng *Quy ước dữ liệu* mới; `grep -n 'chưa có owner'` vẫn ra *Schema* ·
  *Quy ước code* · *API* · *Route*. Cùng lượt sửa hai pointer đã lệch ở `CLAUDE.md`: câu *"khi
  `2-db/` mở thì hàng đổi"* (nay nói ba hàng đổi ở ba bước, theo kế hoạch §5) và câu Gate 1d *chỉ đọc
  thư mục pha 1* (sai từ `P2-02`); cây thư mục thêm `2-db/`.
- **N6** — luật làm tròn cho phép chia chạm tiền trỏ **U-058**, không tự chọn (`QD-20`, §8 của file).
- **Gate** — `./scripts/gate.sh` xanh; Gate 1d chạy riêng ⇒ exit 0 và file mới **có** trong danh
  sách nó quét. Lệnh chưa lọc cạnh lệnh lọc (**F-017**): dòng duy nhất mang một động từ HTTP là
  câu SQL phân quyền của `QD-50`, đúng thứ vùng pha 2 được viết.

**Chưa chạy được, và ai chạy:** mọi phép kiểm — chưa có database. `P2-12` chạy lần đầu trên DBMS vừa
chọn và điền sáu tham số ở §0; `P2-11` gom và chứng minh biết kêu. **Lựa chọn của phiên, chờ chủ
repo:** tên cấu trúc tiếng Anh (`QD-01`), bảng hậu tố vai trò (`QD-03`), khoá chính `id` tự sinh
(`QD-10`), tiền không âm với chiều đi theo loại bản ghi (`QD-21`), `sale_date` cất riêng (`QD-31`),
trạng thái là mã chữ có bảng ánh xạ (`QD-40`), cấm xoá bằng **quyền của database** (`QD-50`). Không
viết ADR, vì `docs/decisions.md` dành ADR cho quyết định có lời người thật; chủ repo xác nhận thì
nhãn *phiên chọn* của mục ấy đổi thành *owner*. Claude Code, nhánh `chatgpt_involve`, base
`cf048d4`; chưa review độc lập. Trạng thái: `work/backlog.md` → *Done*.

[↑ đầu file](#top)

---

<a id="p2-04"></a>
### P2-04 — Bảy mệnh đề của lát bán hàng lõi đang chờ một ràng buộc thật, và một luật đã chốt của pha 0 (`F-038`) chưa có mệnh đề nào mang

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 4/14 (kế hoạch
§6) · **cần xong trước:** `P2-03` · `P2-12` · **chặn** `P2-06` · `P2-07` · `P2-09` · `P2-10` · `P2-11` ·
**chỗ đang chặn nó:** `F-038` · chạy song song được với `P2-05` · `P2-06` · `P2-07` · `P2-08`

**Goal:**
Xong rồi thì bàn, phiên bàn, đơn, dòng đơn, tuỳ chọn đã chọn và suất *đem về* có chỗ cất thật, và
**cố tình dựng một trạng thái sai thì database từ chối** — không phải một dòng bình luận nói rằng
nó sẽ từ chối. `YC-05` trả lời được cả hai câu của
[`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) §7.

**Nói một câu, việc phải làm là gì:**
Dựng **lát bán hàng lõi** mang `I-001` `I-002` `I-003` `I-006` `I-007` `I-016` `I-017` và `YC-05`,
mỗi hàng *tầng 1* thành **một ràng buộc thật**. Việc **không** phải làm: đừng dựng đường tiền
(`P2-06`), đừng dựng việc trạm (`P2-07`), và đừng viết một endpoint nào — *"đường ghi tới ô này
phải là **một**"* là câu pha 2 được viết, *"POST /api/orders"* thì không (kế hoạch §3).

**Vì sao có task này:**
Đây là lát mà cả pha đứng lên: `P2-06` `P2-07` `P2-09` `P2-10` `P2-11` đều đọc nó. Bảy mệnh đề
trong danh sách trên là bảy câu pha 1 đã chốt tầng cho (`03-bao-ve-invariant.md` §1–§4) và **chưa
câu nào có chỗ cất**. Cộng thêm một khoản nợ có tên: **`F-038`** (mở 2026-09-08, `P1-11`) — luật
*"thiếu một trường bắt buộc thì đơn không tạo được"* đã chốt ở pha 0
([`03-lat-cat.md`](../docs/product/0-ba/ban-hang/03-lat-cat.md) §3.2.1 bước 3 · §3.2.4) nhưng pha 1
**không** có mệnh đề, **không** có tầng, **không** có dòng `YC` nào mang nó. Bước này là chỗ đầu
tiên cái thiếu ấy thành một lỗ hổng chạy được.

**Không làm thì mất gì:**
- **Hai phiên chưa thanh toán trên một bàn** — `I-001` không có ràng buộc ⇒ một hoá đơn không ai
  thu, và cái lệch ấy không quy được về một thao tác nào (sổ rủi ro pha 1,
  [`06-so-rui-ro.md`](../docs/product/1-system-design/06-so-rui-ro.md)).
- **Phiên đóng khi còn đơn chưa xong** (`I-017`) ⇒ bếp làm tiếp một đơn của một bàn đã tính tiền
  xong, và phần ấy không ai trả.
- **Một đơn `delivery` tạo được mà không có địa chỉ giao** (`F-038`) ⇒ người đi giao cầm đơn không
  biết đi đâu, và chỗ hỏng ấy chỉ lộ ra **sau khi** khách đã trả tiền.
- **Suất *đem về* rời khỏi phiên bàn thành một đơn lẻ** (`YC-05` · `I-006`) ⇒ một bàn không thể vừa
  ăn tại chỗ vừa gói mang về, đúng ca quán làm mỗi ngày.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc file quy ước của `P2-03` và file quy ước code của `P2-12` (DBMS, phiên bản, thư mục
   migration); `quality/invariants.md` bảy mệnh đề trên **nguyên văn** (cả điều
   kiện biên và kịch bản kiểm); `03-bao-ve-invariant.md` các hàng tương ứng — cột **tầng** là đề
   bài; `04-yeu-cau-du-lieu.md` `YC-05`; và **`F-038` nguyên văn**.
2. Khai `work/scope.txt`: khối `P2-04` — **thêm**, vì bốn lát kia có thể đang chạy song song
   (**F-010** · **F-014**).
3. Chuyển `P2-04` sang *In Progress*.
4. Dựng lát: mỗi hàng *tầng 1* ⇒ một ràng buộc thật (khoá duy nhất, kể cả khoá duy nhất chỉ áp cho
   vài trạng thái · điều kiện kiểm · khoá ngoại bắt buộc) — từ vựng ở ADR của `P2-01`.
5. **`F-038` không được tự lấp.** Pha 2 **không** sở hữu mệnh đề và **không** sở hữu tầng
   (**ADR-035**): viết một dòng trong file lát này nói rõ lược đồ đứng thế nào khi `F-038` còn mở,
   và gửi ngược tình trạng ấy vào `work/findings.md`. Dựng ràng buộc cho một luật chưa có mệnh đề
   là pha 2 tự viết mệnh đề. **Cùng cách cho `F-043`** (*một lần gửi đơn thành đúng một đơn* chưa
   có mệnh đề): file lát ghi một dòng **chỗ trống có tên** — lát này chưa giữ gì cho vế ấy, vì sao,
   và mã `F-043` — không tự dựng khoá chống trùng khi pha 1 chưa chốt tầng.
6. Chứng minh: cố tình dựng trạng thái sai cho **từng** mệnh đề tầng 1 ⇒ **dán nguyên lời từ chối
   của database**. Rồi `./scripts/gate.sh` — Gate 1d nay chấm cả vùng pha 2 (`P2-02`).
7. Gate 2: mỗi dòng *Acceptance* map vào một output thật, không vào một câu khẳng định.
8. Thêm dòng file mới vào `docs/product/00-index.md`; đổi hàng *Schema* của `CLAUDE.md` §2 từ *chưa
   có owner* sang file này (**ADR-035** luật 2) — các lát sau **thêm** dòng, không ghi đè. Khi đổi
   hàng *Schema* của `CLAUDE.md` §2 thì viết theo luật chủ sở hữu của **ADR-053** luật 2: file
   migration là nhà của tên bảng · tên cột · kiểu · ràng buộc; file lát ở `docs/product/2-db/` là
   nhà của ý định, lý do và ánh xạ `I-0xx`/`YC-xx`; lệch ⇒ `F-XXX`. Ý 1 (migration thắng) có lời chủ
   repo 2026-09-25; ý 2 · 3 là phần suy ra — đọc ADR-053 *Trạng thái* trước khi viết hàng ấy.
9. Tick `P2-04` → *Done*; điền khối **Bàn giao** — kèm output phép so tên bảng giữa file `.md` và
   file migration, chạy tay cho tới khi `P2-09` biến nó thành lệnh (**ADR-053** luật 2); xoá **khối
   của mình** trong `work/scope.txt`, không xoá khối của lát khác.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng thi công đề xuất 16 bảng ngày 2026-08-31** (`master_plan/prompt-fullstack.md` §3.4–§3.7)
  như một lược đồ đã chốt. Nó rẻ, nó chạy được, và
  [`architecture.md`](../docs/product/1-system-design/architecture.md) §8 đã đo **tám** chỗ nó chưa
  có chỗ cất — đây là **rủi ro lớn nhất của cả pha 2** (kế hoạch §10).
- **Đừng hạ tầng một hàng dựng không nổi.** Đó là một `F-XXX` gửi ngược pha 1, không phải lý do để
  hàng ấy tụt xuống tầng 3 (kế hoạch §7 luật 1).
- **Đừng chấm bằng *"đã tạo xong bảng"*.** Biên nhận của bước này là **lời từ chối của database**,
  đúng cột *Đầu ra kiểm chứng được* của kế hoạch §6.
- **Đừng viết điều kiện của `I-001` bằng một giá trị trạng thái.** Nó phải theo **nghĩa** — *bàn
  còn nợ tiền*, gồm cả *chờ thanh toán*. Dự án cũ chặn đúng một giá trị, và ràng buộc nhả ra đúng
  lúc quầy bấm tính tiền (bằng chứng cũ: `nghien-cuu.md` §1.3, không phải dữ kiện quán này).

**Nhận việc** — *điền 2026-09-27 (Claude Code), `P2-03` · `P2-12` đã `Done`* (**ADR-051**):
- *Phạm vi:* `db/migrations/` (một file mới) · `db/tests/` (file `i0xx_…` · `yc05_…` mới) ·
  `docs/product/2-db/02-luoc-do-ban-hang.md` (mới) · `docs/product/00-index.md` · `CLAUDE.md` §2 hàng
  *Schema* · `work/findings.md` (`F-038` · `F-043` nhận một dòng tình trạng) · `work/backlog.md` ·
  entry này · `work/scope.txt`. **Không** chạm: menu và giá (`P2-05`), đường tiền (`P2-06`), việc trạm
  (`P2-07`), người và vết (`P2-08`), kế hoạch pha 2, `quality/`, `docs/product/1-system-design/`.
- *Nghiệm thu:*
  1. Mỗi hàng **tầng 1** của lát — `I-001` (phủ cả *chờ thanh toán*, theo **nghĩa** *chưa đóng*, và
     ghép bàn vẫn được) · `I-002` vế *một phiên một hoá đơn* · `I-006`/`I-007` vế ranh giới — có một
     ràng buộc thật mang tên theo `QC-10`; cố tình dựng trạng thái sai ⇒ database **từ chối**, lời
     từ chối nguyên văn dán ở *Bàn giao*.
  2. `YC-05` trả lời được cả hai câu: một đơn của phiên bàn mang **cùng lúc** suất ăn tại chỗ và suất
     đem về, đọc ra được suất nào là suất nào; dấu *đem về* không làm suất rời phiên.
  3. Ba hàng không phải tầng 1 (`I-003` tầng 3 · `I-016` tầng 3 · `I-017` tầng 2) có dòng ở file lát
     nói lược đồ nợ gì cho tầng ấy theo **ADR-050** và cái gì còn là việc của pha 3 — không hàng nào
     bị nâng hay hạ tầng.
  4. `F-038` và `F-043` mỗi mã một dòng *chỗ trống có tên* ở file lát, và một dòng tình trạng ở
     `work/findings.md`; lược đồ không có cột hay ràng buộc nào cho hai vế ấy.
  5. `./scripts/db-check.sh` chạy migration từ số 0 và cả bộ `QD-XX` · `QC-XX` + test lát ⇒ PASS;
     `./scripts/gate.sh` xanh.
  6. Phép so tên bảng file `.md` ↔ migration (**ADR-053** luật 2) chạy tay, in cả hai danh sách chưa
     lọc cạnh `comm -3` rỗng.
  7. `CLAUDE.md` §2 hàng *Schema* có owner theo luật chủ sở hữu **ADR-053** luật 2; `00-index.md` có
     dòng file mới.
- *Kiểm chứng:* output `./scripts/db-check.sh` (dòng `NOTICE … bị từ chối` của từng test) · output
  `./scripts/gate.sh` · output phép so tên bảng — cả ba dán ở *Bàn giao*.

**Bàn giao** — 2026-09-27, Claude Code, nhánh `chatgpt_involve`, base `6bf8f97`; **chưa review độc
lập**.

*Kết quả:* migration
[`db/migrations/20260927120000_ban_hang_loi.up.sql`](../db/migrations/20260927120000_ban_hang_loi.up.sql)
dựng năm bảng; file lát
[`docs/product/2-db/02-luoc-do-ban-hang.md`](../docs/product/2-db/02-luoc-do-ban-hang.md) giữ ý định,
ánh xạ mệnh đề → ràng buộc → test (§2), phần nợ của ba hàng không phải tầng 1 (§3), bảng ánh xạ
trạng thái (§4) và tám chỗ trống có tên (§5); bảy test ở `db/tests/`. `CLAUDE.md` §2 hàng *Schema*
có owner theo **ADR-053** luật 2; `docs/product/00-index.md` thêm một dòng; `F-038` · `F-043` nhận
dòng tình trạng, vẫn **Open**.

*Nghiệm thu → bằng chứng* (output `./scripts/db-check.sh`, cơ sở dữ liệu rỗng dựng từ số 0,
PostgreSQL 17.11):
1. Tầng 1 bị từ chối, nguyên văn:
   - `I-001` (phiên cũ **đang chờ thanh toán**): `duplicate key value violates unique constraint
     "table_session_member_one_unpaid_session_key"`; ghép bàn đang có phiên sang phiên khác: cùng lời;
     ghép hai bàn vào một phiên — được; sau khi phiên cũ đóng, bàn nhận phiên mới — được.
   - `I-002`: `new row for relation "sales_order" violates check constraint
     "sales_order_session_iff_table_channel_check"` (đơn `qr_table` không phiên) · `insert or update on
     table "sales_order" violates foreign key constraint "sales_order_session_table_fkey"` (bàn 7 đổ
     vào phiên bàn 5); hai lượt QR + POS ⇒ `2 đơn, 1 phiên`.
   - `I-006`/`I-007`: `new row for relation "sales_order" violates check constraint
     "sales_order_session_iff_table_channel_check"` — ba ca: tạo `pickup` trong phiên · nối
     `phone_preorder` vào phiên · đổi kênh để lách.
2. `YC-05`: `2 suất, đem về = f, thuộc phiên bàn 5 = t` và `1 suất, đem về = t, thuộc phiên bàn 5 = t`
   trên **cùng** một đơn; suất đem về rời đơn ⇒ `null value in column "sales_order_id" of relation
   "order_line" violates not-null constraint`.
3. Không phải tầng 1: `I-003` — `violates check constraint "table_session_member_cleaned_after_close_check"`
   + bàn không có cột trạng thái; `I-016` — `violates check constraint "sales_order_status_check"` ·
   `"table_session_status_check"` · `column "is_closed" can only be updated to DEFAULT`; `I-017` —
   `update or delete on table "table_session" violates foreign key constraint
   "table_session_member_session_fkey"`, rồi `phiên ở awaiting_payment, bàn đã đánh dấu đóng: 0 —
   không nửa nào sống sót`. Phần pha 3 nợ: file lát §3.
4. `F-038` · `F-043`: file lát §5, `work/findings.md` hai dòng *Tình trạng ở pha 2*.
5. `db-check: PASS — 26 khối kiểm tài liệu, 4 phép kiểm dạng lệnh, 7 file test`; `QD-02`
   (`sales_order.channel_code` = năm mã của `shop-facts.md` §2) và `QD-40(b)` (hai cột `status`) in
   cả hai danh sách, `comm -3` rỗng. `./scripts/gate.sh` exit 0.
6. Phép so tên bảng `.md` ↔ migration (chạy tay, `grep 'CREATE TABLE'` trên migration ·
   `grep '^| \`tên\` |'` trên `docs/product/2-db/*.md`): cả hai danh sách chưa lọc là
   `dining_table order_line sales_order table_session table_session_member`; `comm -3` **rỗng**.
7. `CLAUDE.md` §2 · `00-index.md`: trong diff của lượt này.

*Test biết kêu:* trên một database riêng, gỡ `table_session_member_one_unpaid_session_key` và
`sales_order_session_iff_table_channel_check` rồi chạy lại hai test ⇒ `ERROR: I-001: database KHÔNG
từ chối phiên thứ hai khi phiên cũ đang chờ thanh toán` và `ERROR: I-007: database KHÔNG từ chối đơn
pickup tạo trong phiên bàn`, cả hai exit 3.

*Còn mở — cần chủ repo đọc:*
- **Tuỳ chọn đã chọn chưa được dựng**, trong khi kế hoạch §6 xếp nó vào lát này: mọi cột của nó là
  ảnh chụp menu, nên phiên giao sang `P2-05` (file lát §5, phiên chọn). Kế hoạch §5 · §6 chưa sửa
  (ngoài scope) — nếu chủ repo đồng ý thì sửa dòng `P2-04` · `P2-05` của kế hoạch; nếu không, một lượt
  sau dựng nó ở đây.
- Mọi lựa chọn *phiên chọn 2026-09-27* của file lát (bản soi + khoá ngoại hai cột hoãn cho `I-001`,
  không bản ghi hoá đơn riêng, *Trống* đọc ra từ chi tiết) chưa có lời chủ repo.
- `F-038` · `F-043` · `F-042` vẫn Open — việc của pha 1. *(Đo lại 2026-09-28: `F-038` đóng ở T-110, `F-042` đóng ở T-113, `F-043` đóng ở T-115 — cả ba đã có mệnh đề; phần lược đồ là T-111 · T-114 · T-116.)*

*Bước sau:* `P2-06` · `P2-07` hết chặn (mọi bước *Cần xong trước* đã `Done`; `S-5` · `S-6` của `P2-07`
là ô **để trống**, không phải chỗ chặn) nên có dòng ở *Ready*; `P2-08` còn chờ `P2-06`. `P2-05` đọc file
lát §5 trước khi thêm vào `order_line`.

[↑ đầu file](#top)

---

<a id="p2-05"></a>
### P2-05 — Giá của một đơn đã đặt chưa có chỗ cất riêng, nên sửa menu là sửa luôn doanh thu của ngày đã chốt

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 5/14 (kế hoạch
§6) · **cần xong trước:** `P2-03` · `P2-12` · **chặn** `P2-10` · `P2-11` · **chỗ đang chặn nó:** `F-036` (vế
*ngừng bán hẳn*) · chạy song song được với bốn lát kia

**Goal:**
Xong rồi thì đổi giá menu **sau khi** một đơn đã đặt không làm đơn cũ đổi một đồng nào, và một tổ
hợp món/tuỳ chọn cấm bị **từ chối** chứ không bị sửa hộ. Doanh thu của một ngày đã đối soát không
bao giờ đổi về sau — lời chốt 2026-09-01 của chủ quán cuối cùng có chỗ đứng trong dữ liệu.

**Nói một câu, việc phải làm là gì:**
Dựng **lát menu · giá · ảnh chụp giá lúc đặt** mang `I-009` `I-010` `I-011` `I-013`, cộng công thức
giá ở `master_plan/shop-facts.md` §4.1–§4.6. Việc **không** phải làm: đừng viết **hàm** tính giá —
*một hàm tính giá duy nhất* là đầu ra của **pha 3** (kế hoạch §11); pha 2 chỉ dựng chỗ cất cho cái
hàm ấy đọc và ghi.

**Vì sao có task này:**
`I-009` nói *đơn đã tạo không đổi giá, tên món và thành phần khi chủ quán sửa menu*, và
`03-bao-ve-invariant.md` giữ vế ấy bằng một **bản sao đã khoá tại mốc lượt gọi**. Bản sao ấy là một
**chỗ cất** — thứ chỉ pha 2 dựng được. Chừng nào nó chưa có, dòng đơn trỏ thẳng vào món trong menu,
và mỗi lần chủ quán sửa giá là một lần lịch sử bán hàng tự viết lại. `I-013` (*giá do khách gửi lên
không bao giờ được dùng*) đứng trên cùng chỗ cất ấy.

**Không làm thì mất gì:**
- **Doanh thu lịch sử tự đổi theo menu** ⇒ không đối soát được một ngày đã chốt, và **ngưỡng lệch
  0đ** (`shop-facts.md` §6.10) mất nghĩa từ lần sửa giá đầu tiên.
- **Một tổ hợp cấm bị *sửa hộ* thay vì bị từ chối** (`I-010`) ⇒ khách nhận một suất khác cái họ gọi,
  và không ai biết chỗ lệch bắt đầu từ đâu.
- **Đổi thành phần suất trong giờ bán xảy ra âm thầm** (`I-011`) ⇒ bếp làm theo công thức cũ, quầy
  tính theo công thức mới.
- **`F-036` để nguyên** ⇒ vế *món đã ngừng bán thì không kênh nào đặt mới được* không có tầng, nên
  lát này dựng xong vẫn còn một cửa mở mà không ai ghi ra.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc file quy ước `P2-03` và file quy ước code `P2-12`; `quality/invariants.md` `I-009` `I-010` `I-011` `I-013` nguyên văn;
   `master_plan/shop-facts.md` §4.1–§4.6 (công thức giá) và §4.8 (các ca giá bắt buộc); **`F-036`
   nguyên văn**, bảng hai hàng của nó.
2. Khai `work/scope.txt`: khối `P2-05` — **thêm**, không ghi đè.
3. Chuyển `P2-05` sang *In Progress*.
4. Dựng lát, gồm **chỗ cất ảnh chụp giá lúc đặt**: bản sao khoá tại mốc lượt gọi, đủ để đọc lại một
   đơn cũ mà không chạm menu hiện tại.
5. **`F-036` không được tự vá.** Vế *ngừng bán hẳn* thiếu **tầng**, và tầng là của pha 1: viết một
   dòng trong file lát này nói lược đồ đứng thế nào khi `F-036` còn mở, gửi ngược vào
   `work/findings.md`, **không** tự chọn tầng cho nó.
6. Chứng minh, chạy thật và dán output: (a) đổi giá menu sau khi một đơn đã đặt ⇒ đọc lại đơn cũ,
   giá **không đổi**; (b) tổ hợp cấm ⇒ **bị từ chối**, dán nguyên lời từ chối; (c) **đổi mức phụ
   thu một lần, ở một chỗ ⇒ mọi suất nhận nhân đổi giá theo đúng công thức của `shop-facts.md` §4.6
   luật 5, không dòng nào phải sửa tay**. Rồi `./scripts/gate.sh`.
7. Gate 2: ba dòng *Acceptance* trên map vào ba output thật.
8. Thêm dòng vào `docs/product/00-index.md`; hàng *Schema* ở `CLAUDE.md` §2 **thêm** tên file này,
   không ghi đè tên file của `P2-04`.
9. Tick `P2-05` → *Done*; điền khối **Bàn giao**, kèm output phép so tên bảng `.md` ↔ migration
   (**ADR-053** luật 2); xoá khối scope của mình.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng cất giá đã tính của cả đơn thay cho giá từng dòng.** `P2-10` sẽ tính lại các ca giá bắt
  buộc của §4.8 và đối chiếu **từng đồng**; một con số tổng không tách về dòng thì không chấm được
  ca nào.
- **Đừng chép một con giá nào vào file pha 2.** Giá có nhà ở `master_plan/shop-facts.md`
  (**ADR-001**); `P2-10` **tra** ở đó, không chép (kế hoạch §4.4).
- **Đừng lẫn *ngừng bán* với *tổ hợp không hợp lệ*.** `I-010` giữ tổ hợp tuỳ chọn; *món còn bán hay
  không* là vế khác, và nó đang là `F-036`.
- **Đừng chép phụ thu thành từng con số trên từng suất.** `shop-facts.md` §4.6 luật 5 nói các hệ số
  là **hệ quả** của một công thức. Dự án cũ chép tay nhiều dòng lặp: đổi phụ thu mà sót một dòng thì
  một món bán sai giá, không lệnh nào kêu (`nghien-cuu.md` §2.4) — đầu ra (c) ở bước 6 chặn đúng ca ấy.
- **Đừng cất luật *Lượng nhân* bằng một tham chiếu tới MỘT lựa chọn.** Luật 3 của §4.6 phụ thuộc một
  **tập** (*nhân ≠ Chay*); một tham chiếu đơn chỉ giữ nửa luật, nửa kia rơi xuống code và `I-010`
  mất tầng dữ liệu (`nghien-cuu.md` §2.5).
- **Đừng để ảnh chụp tuỳ chọn trên dòng đơn chỉ giữ tên hiển thị.** Giữ cả **mã gốc** của tuỳ chọn:
  chủ quán đổi tên hiển thị thì mọi phép đếm theo tuỳ chọn gãy làm đôi từ ngày đổi (`nghien-cuu.md` §2.6).
- **Đừng dùng chung một cờ cho *ngừng bán* và *hết giữa buổi*.** Owner đã tách: ngừng bán là đổi menu
  (`03-lat-cat.md` §3.3.4); hết giữa buổi là **tạm dừng nhận đơn** + POS bàn với khách (`shop-facts.md`
  §6.8 · §6.20). Không có thao tác *tạm hết từng món* — cần thì hỏi chủ quán (`nghien-cuu.md` §2.9).

**Nhận việc** — *điền 2026-09-27 (Claude Code), `P2-03` · `P2-12` đã `Done`* (**ADR-051**):
- *Phạm vi:* `db/migrations/` (một file mới) · `db/tests/` (file `i009_…` · `i010_…` · `i013_…` · một
  file cho đầu ra (c) mới; test `yc05_…` của `P2-04` sửa phần dựng dữ liệu vì `order_line` có cột bắt
  buộc mới) · `docs/product/2-db/03-luoc-do-menu-gia.md` (mới) · `02-luoc-do-ban-hang.md` §5 · §6 (hàng
  *món, giá, tuỳ chọn* trỏ sang file mới) · `docs/product/00-index.md` · `CLAUDE.md` §2 hàng *Schema* ·
  `work/findings.md` (`F-036` nhận một dòng tình trạng) · `work/backlog.md` · entry này ·
  `work/scope.txt`. **Không** chạm: kế hoạch pha 2, `quality/`, `docs/product/1-system-design/`,
  `master_plan/shop-facts.md`, đường tiền (`P2-06`), việc trạm (`P2-07`), vết (`P2-08`).
- *Đọc đầu ra (b) thế nào — lệch chữ với bước 6, ghi trước khi dựng:* `I-010` là **tầng 3**
  (`03-bao-ve-invariant.md` §3 — *"tra theo luật, không theo một danh sách case mã cứng"*). Pha 2 không
  nâng tầng (**ADR-050** luật 1 · điểm 4), nên database **không** từ chối *Chay + Nhiều nhân*; lời từ
  chối ấy là của cửa tạo lượt gọi ở pha 3. Cái lát này nợ cho tầng 3: luật *Lượng nhân chỉ có khi nhân
  ≠ Chay* cất thành **dữ liệu, một chỗ, theo TẬP** (bẫy thứ năm) — không nửa nào rơi xuống code.
- *Nghiệm thu:*
  1. **(a) · `I-009` tầng 1.** Đổi giá gốc một thành phần, đổi mức phụ thu, đổi thành phần một suất,
     đổi tên món và tên tuỳ chọn, ngừng bán món — **sau khi** một đơn đã đặt ⇒ đọc lại đơn cũ **chỉ từ
     ảnh chụp** ra đúng giá, tên, thành phần, tuỳ chọn như lúc đặt; một suất đặt mới đọc giá mới.
     Dòng đơn thiếu giá · thiếu tên món · thiếu ảnh chụp thành phần ⇒ database **từ chối**, lời từ chối
     nguyên văn ở *Bàn giao*.
  2. **(b) · `I-010` tầng 3.** Một câu đọc chỉ trên dữ liệu luật ra *Chay + Nhiều nhân* **không hợp
     lệ**, *Thịt + mộc nhĩ + Nhiều nhân* và *Thịt + Nhiều nhân* **hợp lệ**; thêm một loại nhân thứ tư là
     **một** dòng dữ liệu. Ảnh chụp tuỳ chọn trên dòng đơn giữ **mã gốc** (khoá ngoại về lựa chọn) cạnh
     tên hiển thị; đổi tên hiển thị không đổi phép đếm theo tuỳ chọn.
  3. **(c) · §4.6 luật 5.** Đổi mức phụ thu **một lần, ở một dòng** ⇒ giá tính từ dữ liệu của mọi suất
     đổi đúng *Δ × số phần nhận nhân* (1 · 4 · 4 · 5 · 0 phần), không dòng nào khác bị sửa; hệ số không
     cất ở đâu cả.
  4. **`I-013` tầng 3 · `I-011` tầng 4.** File lát liệt kê mọi cột tiền của dòng đơn và chứng minh chỉ
     có **một** cột giá ghi được mỗi dòng (không cột *giá khách gửi*); `I-011` có dòng nói lược đồ nợ gì
     (chỗ cất vết thuộc `P2-08`) — không hàng nào bị nâng hay hạ tầng.
  5. **`F-036`** vế *ngừng bán*: file lát có một dòng *chỗ trống có tên* (lược đồ cất **mốc** ngừng bán
     vì `QD-50` cấm xoá, nhưng **không** ràng buộc nào chặn đặt mới món đã ngừng) và `work/findings.md`
     một dòng tình trạng.
  6. `./scripts/db-check.sh` từ số 0 ⇒ PASS cả bộ `QD-XX` · `QC-XX` + mọi test (cả bảy test của
     `P2-04`); `./scripts/gate.sh` xanh; không con giá thật nào của `shop-facts.md` trong file pha 2.
  7. Phép so tên bảng `.md` ↔ migration chạy tay, in cả hai danh sách chưa lọc cạnh `comm -3` rỗng;
     `CLAUDE.md` §2 hàng *Schema* **thêm** tên file lát mới; `00-index.md` có dòng mới.
- *Kiểm chứng:* output `./scripts/db-check.sh` (dòng `NOTICE` của từng test) · output
  `./scripts/gate.sh` · output phép so tên bảng — dán ở *Bàn giao*.

**Bàn giao** — 2026-09-27, Claude Code, nhánh `chatgpt_involve`, base `a99d3ef`; **chưa review độc
lập**.

*Kết quả:* migration
[`db/migrations/20260927140000_menu_gia.up.sql`](../db/migrations/20260927140000_menu_gia.up.sql) —
bảy bảng menu, ba chỗ cất ảnh chụp (thêm cột vào `order_line`, tạo `order_line_component` ·
`order_line_option`); file lát
[`docs/product/2-db/03-luoc-do-menu-gia.md`](../docs/product/2-db/03-luoc-do-menu-gia.md); ba test mới
ở `db/tests/`; test `yc05_…` của `P2-04` sửa **phần dựng dữ liệu** (hai câu nó chứng minh không đổi).
`02-luoc-do-ban-hang.md` §1 · §5 trỏ sang file mới; `CLAUDE.md` §2 hàng *Schema* thêm tên file;
`00-index.md` thêm một dòng; `F-036` nhận dòng tình trạng, vẫn **Open**.

*Nghiệm thu → bằng chứng* (output `./scripts/db-check.sh`, database rỗng dựng từ số 0, PostgreSQL
17.11; số trong test là số giả):
1. `I-009`: `đơn cũ đọc lại sau năm lần sửa menu: "test-suất giò" · giá 1340 · thành tiền 1340 ·
   [test-giò ×1 @900, test-bánh ×4 @100] · [test-Lượng nhân: test-Thường +0, test-Nhân: test-Thịt +10]`
   sau khi đổi giá thành phần · phụ thu · thành phần suất · tên món · tên tuỳ chọn · ngừng bán; suất
   đặt mới `1410`, `một đơn, hai mức giá cho cùng món: 1340 · 1410`. Từ chối, nguyên văn:
   `null value in column "unit_price_vnd" of relation "order_line" violates not-null constraint` ·
   `null value in column "item_name" …` · `insert or update on table "order_line" violates foreign key
   constraint "order_line_last_component_fkey"` (không ảnh chụp thành phần nào) · `insert or update on
   table "order_line_component" violates foreign key constraint
   "order_line_component_previous_position_fkey"` (thiếu một thành phần) · `new row for relation
   "order_line_component" violates check constraint "order_line_component_position_in_range_check"`
   (thừa so với số đã khai).
2. `I-010`: `Chay + Nhiều nhân ⇒ KHÔNG hợp lệ` · `Thịt + Nhiều nhân ⇒ hợp lệ` · `Thịt + mộc nhĩ +
   Nhiều nhân ⇒ hợp lệ` · `Chay, không chọn lượng ⇒ hợp lệ` — đọc chỉ trên dữ liệu; nhân thứ tư ⇒
   `tập điều kiện của Lượng nhân nay có 3 lựa chọn`; `đếm theo mã gốc: 2 suất · đếm theo tên hiển thị:
   … = 1 · … (đặc biệt) = 1`; ảnh chụp tuỳ chọn không gốc ⇒ `violates foreign key constraint
   "order_line_option_menu_option_fkey"`. **Database không từ chối *Chay + Nhiều nhân*** — đúng tầng 3
   (*Nhận việc*, đoạn *Đọc đầu ra (b)*).
3. (c): `đổi phụ thu nhân 10 → 15: 1 dòng bị sửa`; Δ = `0 · 5 · 20 · 20 · 25` cho `0 · 1 · 4 · 4 · 5`
   phần nhận nhân.
4. `I-013`: bốn cột tiền — `order_line.line_total_vnd (tự tính: t)` · `order_line.unit_price_vnd` ·
   `order_line_component.base_price_vnd` · `order_line_option.surcharge_vnd`; không cột giá khách gửi.
   `I-011`: file lát §3, chỗ cất vết ở `P2-08`.
5. `F-036`: `dòng mới cho món đã ngừng bán vẫn ghi được (không ràng buộc nào — chưa có tầng)`; file lát
   §5; `work/findings.md` dòng *Tình trạng ở pha 2 (`P2-05`)*.
6. `db-check: PASS — 26 khối kiểm tài liệu, 4 phép kiểm dạng lệnh, 10 file test` (bảy test `P2-04` vẫn
   PASS). Lọc số dạng giá trên file lát, migration và ba test mới: chỉ còn số giả `1340`.
   `./scripts/gate.sh`: links OK · doc-status xanh · verify PASS; **Gate 3 đỏ vì bảy file của `T-102`**
   (phiên Codex song song, chưa commit — `shop-facts.md` · `99-unknowns.md` · `architecture.md` ·
   `04-yeu-cau-du-lieu.md` · `admin/01-ranh-gioi.md` · `admin-questions.md` · `backlog_AD.md`), không file
   nào của lượt này.
7. So tên bảng (`grep 'CREATE TABLE'` trên migration · `grep '^| \`tên\` |'` trên file lát): cả hai
   danh sách là `dining_table menu_component menu_item menu_item_component menu_item_option_group
   menu_option option_group option_group_prerequisite order_line order_line_component order_line_option
   sales_order table_session table_session_member`; `comm -3` **rỗng**.

*Chưa làm:* **test biết kêu** — lệnh gỡ ràng buộc trong một test tạm rồi chạy lại bị từ chối quyền
trong phiên; mỗi test tự ném lỗi khi database không từ chối (khuôn `QC-07`), nhưng chưa có một lần
đỏ thật.

*Còn mở — cần chủ repo đọc:*
- **Đầu ra (b) đọc theo tầng 3**: kế hoạch §6 và bước 6 viết *"bị từ chối, dán nguyên lời từ chối"*;
  lát này giữ luật ở dữ liệu, lời từ chối là của pha 3. Muốn database từ chối thì phải đổi tầng của
  `I-010` ở pha 1 trước.
- Mọi lựa chọn *phiên chọn 2026-09-27* của file lát (ngừng bán là mốc, chuỗi vị trí cho ảnh chụp thành
  phần, mốc khoá giá riêng dòng, giá menu sửa tại chỗ — lịch sử giá lấy từ vết `P2-08`).
- `F-036` vẫn Open — việc của pha 1.

*Bước sau:* `P2-10` hết chặn khi đủ `P2-04` · `P2-05` (cả hai `Done`) — dựng menu thật vào bảy bảng
menu bằng cách tra `shop-facts.md` §4.2–§4.5; đọc file lát §5 hàng *trứng chín/tái/vàng*.

[↑ đầu file](#top)

---

<a id="p2-06"></a>
### P2-06 — Vết hoàn tiền và khoản nợ — hai thứ mà thiếu chúng thì đối soát ngưỡng 0đ không chạy nổi — vẫn chưa có chỗ cất

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 6/14 (kế
hoạch §6) · **cần xong trước:** `P2-03` · `P2-04` · `P2-12` · **chặn** `P2-08` · `P2-09` · `P2-11` · **chỗ
đang chặn nó:** không còn — `F-037` đã đóng 2026-09-28 (T-112, **ADR-059**) · chạy song song được với `P2-05` · `P2-07`

**Goal:**
Xong rồi thì **năm** thứ của một lần hoàn (`YC-01`) và **sáu** thứ của một khoản nợ (`YC-02`) đọc
lại được sau nhiều ngày, và một lần trả nợ **không** tạo ra một khoản bán mới. Đối soát cuối ngày
có đủ dữ liệu để chạy ở ngưỡng lệch 0đ.

**Nói một câu, việc phải làm là gì:**
Dựng **lát đường tiền** — thu chia nhiều phương thức · **nợ** · **hoàn tiền** · tiền đầu két — mang
`I-005` `I-012` `I-014` `I-015` `I-021` và `YC-01` `YC-02` `YC-09` `YC-10` `YC-11` `YC-23` (khoản
trả trước — thêm 2026-09-28, T-112). Việc **không**
phải làm: đừng quyết *ai được bấm hoàn tiền* — quyền theo vai là pha 3; pha 2 chỉ đảm bảo mỗi lần
bấm để lại đủ vết để hỏi câu ấy sau.

**Vì sao có task này:**
[`architecture.md`](../docs/product/1-system-design/architecture.md) §8 đo được **tám** chỗ đề xuất
16 bảng ngày 2026-08-31 chưa có chỗ cất, và **hai** trong số đó là **vết hoàn tiền** và **khoản
nợ**. Thiếu hai thứ ấy thì đối soát ngưỡng lệch **0đ** (`master_plan/shop-facts.md` §6.10) —
cổng chất lượng mạnh nhất của cả dự án — không thực hiện được. §12.3 của cùng file là mục **duy
nhất** trong repo đã đi tới mức *cất cái gì*, nhưng chỉ cho riêng phần **nợ**, và nó **tự khai** là
một đề xuất gửi sang pha 2. Bước này **thay thế** nó, và khi thay xong thì §12.3 nhận một dòng trỏ
sang chỗ mới — **trong cùng thay đổi**, không phải một task sau (**F-001**).

**Không làm thì mất gì:**
- **Tính doanh thu hai lần cho cùng một bữa ăn.** Một khoản nợ được cộng vào tiền đã thu của ngày
  ghi nợ, rồi cộng lại lần nữa lúc thu — `YC-02` cấm đúng ca này, và `I-005` nói *nợ không phải
  tiền đã thu*.
- **Két lệch mà không truy được về một thao tác.** `YC-03` đòi mỗi chỗ lệch quy được về **đúng một**
  thao tác có tên người; không có vết hoàn tiền thì một lần hoàn là một lỗ trống trong bảng đối
  soát.
- **Hoàn tiền thiếu *lý do*.** Quán **cố ý** không có luật cứng về hoàn tiền (`shop-facts.md` §6.4),
  nên lý do là thứ **duy nhất** thay được luật — một lần hoàn không lý do là một lần không ai xét
  lại được.
- **Khoản trả trước không có chỗ cất** ⇒ bảng đối soát có **ba** dòng trả trước (`architecture.md`
  §6.4, **ADR-059**) mà không danh sách nào dựng lại được chúng, và két lệch đúng bằng khoản ấy ở
  hai ngày — `YC-23`. *(F-037, đã đóng ở pha 1 2026-09-28.)*

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc file quy ước `P2-03`; file quy ước code `P2-12`; lát `P2-04`; `quality/invariants.md` năm mệnh đề trên; `YC-01` `YC-02`
   `YC-09` `YC-10` `YC-11`; `architecture.md` **§12.3** và **§8**; `shop-facts.md` §6.4 · §6.10 ·
   §6.14 · §6.18 · §6.26; `architecture.md` §6.4 ba dòng trả trước · **ADR-059** · `YC-23`.
2. Khai `work/scope.txt`: khối `P2-06` — **thêm**.
3. Chuyển `P2-06` sang *In Progress*.
4. Dựng lát. `I-015` (*một lần thu chia nhiều phương thức, tổng luôn khớp, từng phần ghi riêng*) là
   hàng dễ dựng sai nhất: **từng phần** phải đứng riêng được, và `YC-19` đòi mọi phần dùng **chung
   một** mốc.
5. **Khoản trả trước theo `YC-23`**, không tự thiết kế thêm: lúc nhận tiền tách khỏi mốc tính
   tiền; ba danh sách *nhận · thành doanh thu · trả lại* dựng lại được cho mỗi ngày. Vế *trả lại
   không trừ doanh thu* là **suy ra** (**ADR-059** điểm 5) — dựng theo nó, và nếu chủ quán nói khác
   thì đó là một `U-XXX`, không phải một sửa lược đồ âm thầm. *(Bước này từng là "`F-037` không
   được tự lấp"; F-037 đóng ở pha 1 ngày 2026-09-28, T-112.)*
6. Chứng minh, chạy thật và dán output: năm thứ của một lần hoàn và sáu thứ của một khoản nợ **đọc
   lại được sau nhiều ngày**; một lần trả nợ **không** sinh một khoản bán mới. Rồi
   `./scripts/gate.sh`.
7. Gate 2: mỗi dòng *Acceptance* map vào một output thật.
8. **Cùng lượt**: `architecture.md` §12.3 nhận một dòng trỏ sang file mới; `00-index.md` thêm dòng;
   `CLAUDE.md` §2 hàng *Schema* **thêm** tên file. Rồi `grep -rn '§12.3'` — pointer nào còn đọc
   §12.3 như nhà thật là bug của **lượt này**.
9. Tick `P2-06` → *Done*; điền khối **Bàn giao**, kèm output phép so tên bảng `.md` ↔ migration
   (**ADR-053** luật 2); xoá khối scope của mình.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng chép §12.3 về rồi sửa dần.** Đó là dựng bản thứ hai của một thứ đã đứng được (**F-001**) —
  pha 2 **thay thế** nó, kế hoạch §1 nói thẳng.
- **Đừng gộp luật nợ với luật hoàn tiền.** Hoàn tiền tính vào **ngày hoàn** (§6.4); nợ tính vào
  **ngày bán** (§6.14) — hai chiều **ngược nhau**, gộp là hỏng cả hai.
- **Đừng để tiền đầu két nằm trong tập tiền đã thu.** `I-021` là một phép **trừ**; trộn hai thứ vào
  một ô làm mọi ngày lệch đúng bằng tiền đầu két, và một báo đỏ mỗi ngày dạy người ta bỏ qua báo
  đỏ.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-07"></a>
### P2-07 — Một lần bấm *"đã làm xong"* đẩy việc của nhiều bàn cùng lúc, mà không chỗ nào cất phần của từng bàn

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 7/14 (kế hoạch
§6) · **cần xong trước:** `P2-03` · `P2-04` · `P2-12` · **chặn** `P2-09` · `P2-11` · **chỗ đang chặn nó:**
`S-5` · `S-6` (**để trống, đừng điền**) · `F-036` (vế việc **cấp đơn**) · chạy song song được với
`P2-05` · `P2-06` · `P2-08`

**Goal:**
Xong rồi thì tổng nhu cầu một thành phần **tách ngược về được** từng bàn và khớp **cả hai chiều**,
số đã phục vụ của một bàn **không vượt** số bàn ấy đã gọi, và đơn vị **bấm** của mốc *đã bưng ra
bàn* vẫn **trống có tên** — không bị một mặc định lấp.

**Nói một câu, việc phải làm là gì:**
Dựng **lát sản xuất theo mẻ** — việc của từng trạm · một lần bấm = một mẻ · phần chia về từng bàn ·
phần đã làm xong của đơn huỷ đổi chủ — mang `I-004` `I-019` `I-020` và `YC-06` `YC-07`. Việc
**không** phải làm: đừng chọn đơn vị bấm cho `S-5`, đừng chọn mốc cho `S-6`.

**Vì sao có task này:**
Chủ quán chốt 2026-09-01: **một lần bấm là một mẻ**, và một mẻ đẩy việc của **nhiều bàn** cùng lúc
(`shop-facts.md` §5.4; lát cắt sản xuất ở
[`03-lat-cat.md`](../docs/product/0-ba/ban-hang/03-lat-cat.md) §3.4, mở ở `BA-12`). `I-019` biến
lời ấy thành một mệnh đề đo được: *tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng
bàn*. Một mệnh đề như thế chỉ đứng được khi **phần của từng bàn** có chỗ cất; nếu chỉ cất con số
tổng của mẻ, hai vế của `I-019` không bao giờ so được với nhau. Cộng thêm ca chủ quán chốt
2026-09-06: phần **đã làm xong** của một đơn bị huỷ **tính cho bàn khác**, POS chọn bàn nhận rồi
cập nhật — đó là một lần **đổi chủ**, cũng cần chỗ cất.

**Không làm thì mất gì:**
- **Bánh cộng cho bàn này, thiếu cho bàn kia, đúng lúc đông khách** — và không ai dựng lại được mẻ
  nào đã chia đi đâu.
- ***Còn thiếu* của người bưng và *còn phải làm* của bếp bị gộp làm một con số** (`YC-07`) ⇒ bếp
  làm thừa hoặc quầy đứng chờ một thứ đã nằm sẵn ở bếp.
- **Phần đã làm xong của một đơn huỷ biến mất** mà không có lần cập nhật nào chuyển nó sang bàn
  khác ⇒ nguyên liệu mất trắng, và lệch ấy không có tên trong bất kỳ bảng nào.
- **`S-5` bị lấp bằng một mặc định** ⇒ lược đồ đã thay chủ quán trả lời một câu **chưa ai hỏi**, và
  cái sai chỉ lộ ra lúc quán dùng thật ([`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) §6).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc file quy ước `P2-03`; file quy ước code `P2-12`; lát `P2-04`; `quality/invariants.md` `I-004` `I-019` `I-020`; `YC-06`
   `YC-07`; `shop-facts.md` §5.4 và §7.2 (**`S-5`** · **`S-6`** nguyên văn); `03-lat-cat.md` §3.4.2
   · §3.4.3 · §3.4.4 · §3.4.5 · §3.4.8; **`F-036`** hàng `I-004`.
2. Khai `work/scope.txt`: khối `P2-07` — **thêm**.
3. Chuyển `P2-07` sang *In Progress*.
4. Dựng lát: một mẻ cất được **phần của từng bàn**; con số *đã làm xong, còn ở bếp* đứng **riêng**,
   không gộp vào *đã phục vụ*; mỗi lần **lùi** một mẻ bấm nhầm để lại vết (lùi mẻ nào · mấy giờ ·
   ai).
5. **`S-5` và `S-6` để TRỐNG CÓ TÊN.** Ghi thẳng trong file: ô đơn vị bấm của mốc *đã bưng ra bàn*
   chưa có lời, mã là `S-5`, ai gỡ là **chủ quán**. Cùng cách `P1-07` và `P1-09` đã xử `S-5` ngày
   2026-09-07. **`F-036`** (việc **cấp đơn** của trạm `canh` — một đơn **một** việc nước chấm,
   không nhân theo số suất) gửi ngược, không tự chọn tầng.
6. Chứng minh, chạy thật và dán output: tổng nhu cầu một thành phần **tách ngược về** từng bàn,
   khớp cả hai chiều; số đã phục vụ **không vượt** số đã gọi. Rồi `./scripts/gate.sh`.
7. Gate 2: mỗi dòng *Acceptance* map vào một output thật; dòng cho `S-5` map vào **một ô trống có
   mã**, không vào một giá trị.
8. `00-index.md` thêm dòng; `CLAUDE.md` §2 hàng *Schema* **thêm** tên file. `grep -rn 'S-5'` — mọi
   chỗ nói `S-5` chặn `P2-07` phải còn đúng sau lượt này.
9. Tick `P2-07` → *Done*; điền khối **Bàn giao**, kèm output phép so tên bảng `.md` ↔ migration
   (**ADR-053** luật 2); xoá khối scope của mình.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng đọc *"đơn vị đếm là bàn"* thành *"đơn vị bấm là bàn"*.** `04-yeu-cau-du-lieu.md` §6 phân
  biệt hai chữ ấy và dặn để trống đúng cái thứ hai.
- **Đừng dựng mẻ như một con số tổng.** Một mẻ không chia được về từng bàn là một mẻ làm `I-019`
  không chấm được — đúng vế `YC-07` cấm.
- **Đừng gộp ca *đơn huỷ có bàn chờ* với ca *không có bàn nào chờ*.** Chủ quán chỉ chốt ca thứ
  nhất (2026-09-06); ca thứ hai **chưa có luật, chưa hỏi** (`shop-facts.md` §5.4) — gặp nó thì ghi
  `U-XXX`, đừng suy.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-08"></a>
### P2-08 — Quyền của một thao tác gắn với CHỖ ĐỨNG tại thời điểm bấm, mà không dữ liệu nào biết ai đứng đâu lúc nào

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 8/14 (kế
hoạch §6) · **cần xong trước:** `P2-03` · `P2-06` · `P2-12` · **chặn** `P2-09` · `P2-11` · chạy song song
được với `P2-05` · `P2-07` · **chỗ giao nhau với lane admin** — đọc kế hoạch §3 trước khi dựng

**Goal:**
Xong rồi thì đọc ra được **ai đang trực trạm nào tại một thời điểm trong quá khứ**; một lần sửa
dựng lại được **bản trước, bản sau, lý do, người sửa**; và một lượt bán nhập bù mang **hai** mốc
đọc riêng được. Mọi chỗ lệch trong đối soát quy được về một thao tác **có tên người**.

**Nói một câu, việc phải làm là gì:**
Dựng **lát người · chỗ đứng theo thời điểm · vết**, mang `YC-03` `YC-04` `YC-08` `YC-12`…`YC-17` và
`I-012` `I-018`. Việc **không** phải làm: đừng dựng chấm công hay tính lương — đó là mảng **con
người** của lane admin (`work/backlog_AD.md`, `shop-facts.md` §8.7), và lane ấy chạy song song ở
nghĩa **thu luật**, không ở nghĩa thi công.

**Vì sao có task này:**
`YC-04` chốt một câu làm cả lát này tồn tại: quyền của một thao tác **không** được quyết bởi *chức
vụ ghi cố định trên hồ sơ một người* — nó gắn với **chỗ đứng tại thời điểm bấm**
(`shop-facts.md` §6.13, [`architecture.md`](../docs/product/1-system-design/architecture.md) §4).
Một câu như thế chỉ thi hành được nếu *ai trực trạm nào* là một thứ **đọc được theo thời điểm**
(`YC-15`), chứ không phải một ô hiện tại bị ghi đè mỗi lần đổi ca. `YC-16` thêm một vế nữa: chủ
quán vào đứng quầy thì **hai vai cộng vào nhau**, không thay nhau. Và `I-018` · `YC-13` đòi vết của
mỗi lần **cập nhật** — trong một hệ **không có nút hoàn tác** (`YC-14`), vết là đường lùi duy nhất.

**Không làm thì mất gì:**
- **Ngưỡng 0đ hết nghĩa.** Một chỗ lệch không quy được về một thao tác có tên người thì báo đỏ chỉ
  nói *"có lệch"*, không nói *"lệch ở đâu"* — và một báo như thế không ai xử được.
- **Quyền huỷ đơn và hoàn tiền không có chỗ bám.** Nó gắn chỗ đứng, mà chỗ đứng không được cất theo
  thời điểm ⇒ hoặc hệ thống quay về chức vụ cố định (đúng thứ `YC-04` cấm), hoặc nó không kiểm gì
  cả.
- **Lượt bán nhập bù rơi vào doanh thu của ngày gõ** (`YC-08`) ⇒ một ngày mất điện có doanh thu
  bằng 0 và ngày hôm sau gấp đôi; chủ quán chốt 2026-09-04 là tính vào **ngày bán** (**ADR-037**).
- **Xoá một đơn làm vết của nó biến mất theo** ⇒ `YC-12` hỏng: vết phải **sống độc lập** với bản
  ghi nó nói về.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc file quy ước `P2-03`; file quy ước code `P2-12`; lát `P2-06`; `YC-03` `YC-04` `YC-08` và `YC-12`…`YC-17` nguyên văn;
   `quality/invariants.md` `I-012` `I-018`; `shop-facts.md` §6.11 · §6.13 · §8.7; `architecture.md`
   §4; **ADR-037**; và kế hoạch §3 (hai chỗ giao nhau với lane admin).
2. Khai `work/scope.txt`: khối `P2-08` — **thêm**. Lane admin có thể đang chạy song song ở nghĩa
   thu luật; đọc `./scripts/brief.sh` mục *DECLARED SCOPE* trước.
3. Chuyển `P2-08` sang *In Progress*.
4. Dựng lát: *ai trực trạm nào* là một thứ **có khoảng thời gian**, không phải một ô hiện tại;
   `YC-16` (hai vai cộng vào nhau) và `YC-17` (hai trạm `canh` và `dọn bàn` do **chung** một người)
   phải dựng được mà không cần sửa lược đồ.
5. **Đừng thay lane admin quyết luật nhân sự.** Gặp một chỗ chỉ trả lời được bằng một luật về con
   người chưa chốt ⇒ `U-XXX`, hoặc một dòng trỏ sang `work/admin-questions.md` §3 (`CLAUDE.md`
   §3.5).
6. Chứng minh, chạy thật và dán output: đọc ra ai trực trạm nào **tại một thời điểm trong quá
   khứ**; dựng lại bản trước/bản sau/lý do/người sửa của một lần sửa; một lượt nhập bù mang hai mốc
   đọc riêng được. Rồi `./scripts/gate.sh`.
7. Gate 2: mỗi dòng *Acceptance* map vào một output thật.
8. `00-index.md` thêm dòng; `CLAUDE.md` §2 hàng *Schema* **thêm** tên file. `grep -rn 'YC-15\|YC-16\|YC-17'`
   — lane admin trỏ vào ba dòng này (kế hoạch §3), pointer nào hết đúng là bug của **lượt này**.
9. Tick `P2-08` → *Done*; điền khối **Bàn giao**, kèm output phép so tên bảng `.md` ↔ migration
   (**ADR-053** luật 2); xoá khối scope của mình.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng cất chỗ đứng bằng một ô *"đang trực"* bị ghi đè.** Ghi đè xoá lịch sử, và `YC-15` đòi đúng
  cái lịch sử ấy.
- **Đừng cho vết sống chung số phận với bản ghi gốc.** `YC-12` đòi xoá bản ghi gốc mà vết **vẫn**
  đọc được sau nhiều ngày.
- **Đừng lẫn *người nhập bù* với *người bán*.** `YC-08` đòi cả hai, và hai mốc của chúng khác nhau.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-09"></a>
### P2-09 — Mỗi lần đổi lược đồ sau này sẽ chạy trên dữ liệu bán hàng thật, mà không chỗ nào nói đường lùi

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 9/14 (kế hoạch
§6) · **cần xong trước:** `P2-04` → `P2-08` (cả năm lát) · **F-034 đã Fixed** 2026-09-27 (ADR-057); đọc YC-21, cơ chế giao pha 5 qua T-109

**Goal:**
Xong rồi thì cả dãy migration dựng lại được một cơ sở dữ liệu từ **số không**, và **lùi** một bước
rồi xuôi lại vẫn xanh — chạy thật, dán output. Một lần đổi lược đồ giữa chừng không còn là một
đường một chiều.

**Nói một câu, việc phải làm là gì:**
Chốt **thứ tự migration**: mỗi bước có đường đi và **đường lùi** chạy thật được, cả dãy dựng lại
được từ số không. Việc **không** phải làm: đừng thiết kế backup theo lịch, compose hay cách phục
hồi khi hỏng máy — đó là **pha 5 · Deploy** (kế hoạch §3); theo ADR-057; yêu cầu chính thức là YC-21.

**Vì sao có task này:**
Năm lát ở trên sinh ra lược đồ; không bước nào trong số đó nói **thứ tự dựng** và **đường lùi**.
Chừng nào chưa có, lần đổi lược đồ đầu tiên sau khi quán chạy thật sẽ mang theo dữ liệu bán hàng
thật, và nếu nó hỏng giữa chừng thì không có đường về. Cộng thêm một khoản nợ đã có tên:
**`F-034`** (mở 2026-09-08, `P1-10`) — cơ chế chặn *mất hẳn bản ghi đã ghi* (`RR-9` của sổ rủi ro)
lúc phát hiện chưa có owner. Chủ repo đã chọn hướng 3 ngày 2026-09-27: YC-21 ở pha 1,
cơ chế và bằng chứng ở pha 5 (ADR-057, T-109). Finding đã Fixed, cơ chế chưa được nghiệm thu.

**Không làm thì mất gì:**
- **Dữ liệu bán hàng thật kẹt ở trạng thái nửa vời.** Một migration chạy được một nửa rồi lỗi, và
  không có đường lùi ⇒ quán dừng bán cho tới khi có người sửa tay từng bản ghi.
- **Không dựng lại được từ số không** ⇒ `P2-10` (dữ liệu mồi) và `P2-11` (bộ đối chiếu) không có
  nền sạch để chạy, nên mọi kết quả của chúng phụ thuộc vào trạng thái sẵn có của máy ai chạy.
- **`F-034` bị lấp bằng một lựa chọn kỹ thuật lặng lẽ** ⇒ repo có một cơ chế chống mất dữ liệu mà
  chủ repo chưa bao giờ chọn, và không ai biết nó đang bảo vệ tới đâu.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc **ADR-057 và YC-21** ở `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8;
   [`06-so-rui-ro.md`](../docs/product/1-system-design/06-so-rui-ro.md) dòng `RR-9`; năm file lát
   `P2-04`…`P2-08`; file quy ước `P2-03`.
2. Khai `work/scope.txt`: khối `P2-09`.
3. Chuyển `P2-09` sang *In Progress*.
4. Viết thứ tự migration: mỗi bước một đường đi, một **đường lùi**, và thứ tự dựng lại từ số không.
   Cùng lượt, biến phép so của **ADR-053** luật 2 thành **lệnh**: danh sách tên bảng các file `.md`
   của `docs/product/2-db/` nhắc tới, danh sách tên bảng file migration tạo ra, `comm -3` giữa hai
   danh sách ⇒ **rỗng**. Nối lệnh ấy vào `./scripts/gate.sh` — một lệnh chạy tay mà không cổng nào
   gọi là đúng hình *luật không có lệnh gác thì tự trôi* (**ADR-053** luật 3). Lệch ⇒ một dòng
   `F-XXX`, **không** sửa migration cho khớp chữ.
5. **Trỏ YC-21 và ADR-057.** Nêu rõ dựng/lùi lược đồ không phải phục hồi dữ liệu bán hàng;
   cơ chế và nghiệm thu thuộc pha 5, theo T-109 (`work/backlog.md`).
6. Chứng minh, chạy thật và **dán cả ba output**: (a) chạy xuôi cả dãy trên một cơ sở dữ liệu rỗng
   ⇒ xanh; (b) chạy **lùi** một bước ⇒ xanh; (c) xuôi lại ⇒ xanh. Rồi `./scripts/gate.sh`.
7. Gate 2: ba dòng *Acceptance* map vào ba output trên, không vào một câu khẳng định. Cộng một dòng
   *Đầu ra* thứ tư: lệnh đối chiếu tên bảng giữa file `.md` và file migration ra **rỗng**, và output
   dán **cả lệnh chưa lọc cạnh lệnh đã lọc** — hai danh sách đầy đủ trước `comm`, rồi kết quả
   `comm -3` (**F-017**).
8. `00-index.md` thêm dòng. `grep -rn 'F-034'` — `work/findings.md` và sổ rủi ro cùng nói về nó;
   trạng thái ở hai chỗ phải khớp sau lượt này (Gate 1c chấm `docs/`, không chấm `work/`).
9. Tick `P2-09` → *Done*; điền khối **Bàn giao**; xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng coi *"chưa bao giờ cần lùi"* là bằng chứng đường lùi chạy được.** Một đường lùi chưa chạy
  lần nào là một đường lùi chưa được chứng minh — cùng luật với kế hoạch §7 luật 3.
- **Đừng để thứ tự migration đi trước một lát chưa xong.** Cột *Cần xong trước* của bước này là cả
  năm lát; chạy sớm thì thứ tự phải viết lại, và bản viết lại luôn bỏ sót một bảng.
- **Đừng nhét backup vào đây cho "đủ bộ".** cơ chế YC-21 thuộc pha 5 (ADR-057); bước này chỉ chứng minh đường đi/lùi của lược đồ.
- **Đừng tin một phép so tên bảng ra rỗng mà không in hai danh sách.** Một danh sách rỗng vì biểu
  thức lọc viết sai cũng cho `comm -3` rỗng (**F-017**). Dự án cũ phát hiện chữ trôi khỏi migration
  ba lần chỉ khi đọc thẳng file migration — bằng chứng của dự án cũ,
  `work/proposals/from_old_project/data_base/nghien-cuu.md` §4.1–§4.3, không phải dữ kiện của quán
  này.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-10"></a>
### P2-10 — Mọi test của pha 2 sẽ chạy trên một cái menu chưa ai dựng từ menu thật của quán

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 10/14 (kế hoạch §6)
· **cần xong trước:** `P2-04` · `P2-05` · **chặn** `P2-11`

**Goal:**
Xong rồi thì dựng dữ liệu mồi lên rồi tính lại **các ca giá bắt buộc** của `master_plan/shop-facts.md`
§4.8 ⇒ khớp **từng đồng**. Mọi test sau đó chạy trên đúng menu quán đang bán.

**Nói một câu, việc phải làm là gì:**
Dựng **dữ liệu mồi** — menu thật, bàn, trạm, người — bằng cách **tra** `shop-facts.md` §1 · §3 ·
§4.2–§4.5. Việc **không** phải làm: **đừng chép một bảng giá thứ hai** vào bất kỳ file pha 2 nào,
và đừng sửa một ca giá nào cho khớp.

**Vì sao có task này:**
`master_plan/shop-facts.md` là owner **duy nhất** của mọi dữ kiện quán (**ADR-001**): giá, thành
phần suất, phụ thu, bàn, trạm. `P2-05` dựng **chỗ cất** cho giá; không bước nào dựng **nội dung**.
Chừng nào dữ liệu mồi chưa có, `P2-11` (bộ đối chiếu) và `P2-13` (ba scenario) không có gì để chạy
trên, và mỗi phiên sẽ tự gõ vài món để thử — mỗi phiên một menu khác nhau.

**Không làm thì mất gì:**
- **Mọi test sau đó chạy trên một cái menu không phải menu của quán** ⇒ chúng xanh, và cái xanh ấy
  không chứng minh gì.
- **Một ca giá sai không phát hiện được.** §4.8 là bộ ca **bắt buộc** — nó tồn tại đúng để bắt lỗi
  công thức giá; không có dữ liệu mồi thật thì không ai chạy được nó.
- **Một bảng giá thứ hai sinh ra trong `docs/product/2-db/`** ⇒ từ hôm ấy repo có hai nguồn giá, và
  bản thứ hai luôn trôi (**F-001**). Chủ quán đổi giá một lần là hai con số lệch nhau.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `master_plan/shop-facts.md` §1 · §3 · §4.2–§4.5 (nội dung) và **§4.8** (các ca giá bắt
   buộc); lát `P2-04` và `P2-05`; file quy ước `P2-03`.
2. Khai `work/scope.txt`: khối `P2-10`.
3. Chuyển `P2-10` sang *In Progress*.
4. Dựng dữ liệu mồi: menu thật, bàn, trạm, người. Mỗi mục **tra** owner, và file dữ liệu mồi ghi rõ
   nó tra ở §nào — để lần chủ quán đổi giá sau này có đường lần về.
5. Gặp một món hoặc một phụ thu không có ở `shop-facts.md` ⇒ **hỏi chủ quán**, hoặc `U-XXX`. Không
   tự thêm một món để "đủ bộ test".
6. Chứng minh, chạy thật và dán output: dựng dữ liệu mồi rồi **tính lại các ca giá bắt buộc của
   §4.8** ⇒ khớp **từng đồng**. Rồi `./scripts/gate.sh`.
7. Gate 2: mỗi ca giá là một dòng *Acceptance* có kết quả chạy thật kèm theo.
8. `00-index.md` thêm dòng. `grep -rn` một con giá bất kỳ trong `docs/product/2-db/` — ra kết quả
   nghĩa là đã có bản chép thứ hai, và đó là bug của **lượt này**.
9. Tick `P2-10` → *Done*; điền khối **Bàn giao**; xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Sai một ca giá thì sai dữ liệu mồi hoặc sai lược đồ giá — KHÔNG sửa ca.** §4.8 là đề bài, không
  phải kết quả.
- **Đừng "làm tròn cho đẹp".** Khớp **từng đồng** là câu của cột *Đầu ra kiểm chứng được*; một ca
  lệch một đồng là một ca đỏ.
- **Đừng dựng người thật với tên thật vào dữ liệu mồi mà không đọc `shop-facts.md` §3 trước** — số
  người và vai là dữ kiện có owner, không phải thứ tự nghĩ ra.
- **Đừng sinh mã QR của bàn bằng một hàm dựa trên thời gian hay thứ tự.** Dự án cũ làm vậy: có một mã
  là suy ra mười mã kia (`nghien-cuu.md` §2.1). Từ 2026-09-28 (T-113, **ADR-060**) pha 1 có mệnh đề
  **`I-023`** — mã *không đoán được, đổi được*, sinh ở **một** cửa — và yêu cầu **`YC-24`**. Dữ liệu
  mồi sinh mã **qua đúng cửa ấy**, do `work/backlog.md` **T-114** dựng; `T-114` chưa xong thì bàn mồi
  **chưa có mã**, ghi chỗ trống kèm `T-114`, không tự chọn cách sinh.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-11"></a>
### P2-11 — Hai mươi mốt mệnh đề có phép đối chiếu viết bằng lời, và không câu nào chạy được

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 11/14 (kế hoạch
§6) · **cần xong trước:** `P2-04` → `P2-08` · `P2-10` · **chỗ đang chặn nó:** không còn — `F-037`
đã đóng 2026-09-28 (T-112, **ADR-059**)

**Goal:**
Xong rồi thì mỗi phép đối chiếu của
[`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md) là **đúng một**
câu truy vấn chạy được, gom thành **một** lệnh chạy sau khi đóng quán; `comm -3` giữa danh sách mã
ở `quality/invariants.md` và danh sách mã của bộ truy vấn ⇒ **rỗng**.

**Nói một câu, việc phải làm là gì:**
Dịch mọi phép đối chiếu của pha 1 thành truy vấn, và **chứng minh từng câu biết kêu** — cài một lỗi
thật vào dữ liệu ⇒ đúng câu của nó ra **khác 0**. Việc **không** phải làm: đừng sửa một chữ nào
của phép đối chiếu ở pha 1; thấy một phép đối chiếu sai thì gửi ngược một `F-XXX`.

**Vì sao có task này:**
Pha 1 viết phép đối chiếu bằng **lời** — đó là đúng phạm vi của nó (**ADR-035**). Một phép đối
chiếu bằng lời không chạy được sau khi đóng quán, nên nó không phát hiện được gì. Nặng hơn: kế
hoạch §7 luật 2 nói **mỗi mệnh đề vẫn phải có câu truy vấn của nó, kể cả khi ràng buộc đã đứng ở
tầng 1** — vì ràng buộc cũng bị người ta gỡ, và câu truy vấn là thứ phát hiện ra điều đó. Bộ này
là lớp cuối cùng của cả hệ thống.

**Không làm thì mất gì:**
- **Bất biến chỉ tồn tại trên giấy.** Một ràng buộc bị gỡ trong một lần sửa lược đồ về sau, và
  không ai biết — cho tới khi tiền lệch.
- **Không có cách đóng ngày.** `shop-facts.md` §6.10 chốt đối soát ở ngưỡng lệch **0đ**; ngưỡng ấy
  chỉ chạy được khi có một lệnh chạy sau khi đóng quán.
- **Một bộ truy vấn chưa bao giờ đỏ là một bộ chưa được chấm** (kế hoạch §7 luật 3) ⇒ cả bộ có thể
  xanh vì viết sai, và cái xanh ấy đắt hơn không có gì, vì nó tạo lòng tin.
- **Ba dòng trả trước không có câu truy vấn** ⇒ tiền đã vào két mà không câu nào nhìn thấy — ba
  tập mới ở ô `I-014` và các hạng tử trả trước ở ô `I-021` (**ADR-059**) phải có câu của chúng.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `03-bao-ve-invariant.md` §1–§4 — **cột phải** của mọi hàng; `quality/invariants.md` danh
   sách **mã** (đừng đọc một con số đếm — **F-026** · **F-018**); năm lát `P2-04`…`P2-08`; dữ liệu
   mồi `P2-10`; `architecture.md` §6.4 ba dòng trả trước (**ADR-059**).
2. Khai `work/scope.txt`: khối `P2-11`.
3. Chuyển `P2-11` sang *In Progress*.
4. Viết **đúng một** câu truy vấn cho mỗi phép đối chiếu, mỗi câu mang mã mệnh đề của nó; gom
   thành **một** lệnh. Lệnh ấy chạy thêm **nhóm phép kiểm quy ước** mà `P2-03` viết (**ADR-053**
   luật 3), mỗi phép mang mã quy ước của nó — nhóm riêng, **không** trộn vào danh sách mã `I-0xx`
   mà `comm -3` so.
5. **Không sửa lời một phép đối chiếu nào.** Một phép đối chiếu hẹp hơn chính mệnh đề của nó là
   một `F-XXX` gửi ngược — đúng hình **F-036** đã ghi; pha 2 **thi hành**, không sở hữu.
6. Chứng minh, chạy thật và dán **ba** output: (a) `comm -3` hai danh sách **mã** ⇒ rỗng; (b) cả bộ
   chạy trên dữ liệu mồi ⇒ **0 dòng**; (c) **cài một lỗi thật** vào dữ liệu ⇒ **đúng** câu của nó
   ra khác 0. Nhóm phép kiểm quy ước cũng qua (a)–(c): danh sách mã quy ước ở file `P2-03` so với
   danh sách mã trong bộ ⇒ rỗng, và mỗi phép được cài một vi phạm thật ⇒ ra khác 0. Rồi
   `./scripts/gate.sh`.
7. Gate 2: ba dòng *Acceptance* map vào ba output trên.
8. `00-index.md` thêm dòng. `grep -rn 'I-0'` trong bộ truy vấn và đối chiếu ngược với
   `quality/invariants.md` — mã nào có ở một bên mà không ở bên kia là chỗ hụt của **lượt này**.
9. Tick `P2-11` → *Done*; điền khối **Bàn giao**; xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng đếm số lượng thay cho đối chiếu danh sách mã.** Hai danh sách cùng độ dài vẫn lệch nhau —
  **F-026** là bản ghi của đúng lỗi ấy.
- **Đừng bỏ câu truy vấn cho một mệnh đề đã có ràng buộc tầng 1.** Kế hoạch §7 luật 2 nói rõ vì
  sao.
- **Đừng cài lỗi bằng cách sửa câu truy vấn cho nó đỏ.** Lỗi phải cài vào **dữ liệu**; sửa truy vấn
  là chứng minh ngược.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-12"></a>
### P2-12 — Phiên đầu tiên viết code chưa có một quy ước nào để đối chiếu, và cái nó bịa ra sẽ thành fact

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 12/14 (kế hoạch
§6) · **cần xong trước:** `P2-03` · **chặn** `P2-04` · `P2-05` · `P2-06` · `P2-07` · `P2-08` (năm
lát, **ADR-053** luật 1) — **không còn** độc lập với dãy lược đồ

**Goal:**
Xong rồi thì stack, cấu trúc thư mục, cách đặt tên và khung test có **một** chủ, và hàng *Quy ước
code* ở `CLAUDE.md` §2 hết nói *chưa có owner*. Mỗi mục là một câu **kiểm được bằng lệnh**.

**Nói một câu, việc phải làm là gì:**
Viết **quy ước code** (**ADR-039**), sau khi đối chiếu lại stack đề xuất ở
`master_plan/prompt-fullstack.md` §3.4. Việc **không** phải làm: đừng viết một dòng code sản phẩm
nào, và đừng chốt hợp đồng API hay route — hai thứ ấy là pha 3 và pha 4 (**ADR-035**).

**Vì sao có task này:**
`CLAUDE.md` §2 có một hàng nói thẳng lý do: *"Không ai sở hữu dòng này thì phiên đầu tiên viết code
sẽ tự bịa quy ước, và cái bịa đó thành fact vì không có chủ để đối chiếu."* Hàng ấy đã nói **chưa
có owner** từ 2026-09-04 (**ADR-035** · **ADR-039**), và pha 3 là pha đầu tiên viết code thật. Đây
là bước cuối cùng trước lúc ấy.

**Không làm thì mất gì:**
- **Quy ước sinh ra từ diff đầu tiên.** Phiên nào viết file đầu tiên đặt luôn cách đặt tên cho cả
  dự án, và không có gì để nói nó sai.
- **Khung test không có chủ** ⇒ `scripts/verify.sh` (Gate 1) không biết gọi gì, nên cổng mạnh nhất
  của repo im lặng ở đúng pha bắt đầu có code.
- **Stack đề xuất ngày 2026-08-31 được thi công như đã chốt** — cùng bệnh với đề xuất 16 bảng (kế
  hoạch §1): cụ thể không có nghĩa là đã chốt, và bản ấy viết trước phần lớn lời chốt của chủ quán.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc **ADR-039**; `master_plan/prompt-fullstack.md` §3.4; file quy ước dữ liệu của `P2-03`;
   `scripts/verify.sh` (Gate 1 gọi gì cho Go và cho Node); `CLAUDE.md` §2 hàng *Quy ước code*.
2. Khai `work/scope.txt`: khối `P2-12`.
3. Chuyển `P2-12` sang *In Progress*.
4. Viết file quy ước code. **Mục đầu tiên là DBMS + phiên bản** (**ADR-053** luật 1), vì năm lát
   chờ đúng mục ấy; câu kiểm của nó là một lệnh in ra phiên bản đang chạy. Rồi stack · cấu trúc thư
   mục (có thư mục migration — năm lát viết ràng buộc vào đó) · đặt tên · khung test. **Mỗi mục một
   câu kiểm được bằng lệnh** — không có lệnh thì không phải một quy ước, mà là một lời khuyên.
5. Chọn stack là một **quyết định thiết kế** ⇒ ADR trong `docs/decisions.md` (`CLAUDE.md` §3, hàng
   *ADR*), và nếu có hơn một đường hợp lý thì hỏi **chủ repo** trước khi ghi.
6. Chạy `./scripts/gate.sh` và xác nhận `scripts/verify.sh` **gọi đúng** khung test vừa chốt — dán
   output; một quy ước mà Gate 1 không gọi là một quy ước không cổng nào đọc (**F-007**). Chạy
   **từng phép kiểm quy ước của `P2-03`** trên DBMS vừa chọn, trên một cơ sở dữ liệu rỗng ⇒ 0 dòng,
   dán output; phép nào không chạy nổi trên DBMS đã chọn là bug của **lượt này** (**ADR-053** luật
   3).
7. Gate 2: mỗi mục quy ước map vào một lệnh chạy thật.
8. `00-index.md` thêm dòng; `CLAUDE.md` §2 hàng *Quy ước code* đổi sang tên file này (**ADR-035**
   luật 2). `grep -rn 'chưa có owner'` — hàng nào nay có chủ mà còn nói *chưa có* là bug của **lượt
   này**.
9. Tick `P2-12` → *Done*; điền khối **Bàn giao**; xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng viết quy ước mà không viết lệnh kiểm.** Một dòng *"đặt tên hàm theo camelCase"* không có
  lệnh là một dòng không ai chấm được, và nó sẽ trôi ngay ở PR thứ hai.
- **Đừng chép §3.4 nguyên khối.** Bản xuất khẩu **không sở hữu gì** (**ADR-035** luật 3) — đọc nó
  như đề xuất để đối chiếu.
- **Đừng đợi hết pha 2 mới làm bước này.** Nó đứng giữa `P2-03` và năm lát (**ADR-053** luật 1):
  làm muộn nghĩa là lát đầu tiên dựng ràng buộc trên một DBMS chưa ai chọn. Bằng chứng của dự án cũ
  (`work/proposals/from_old_project/data_base/nghien-cuu.md` §1.3 · §2.7, không phải dữ kiện của
  quán này): cách dựng một khoá duy nhất có điều kiện, và việc ràng buộc kiểm có được thực thi hay
  không, đều đổi theo DBMS và phiên bản.
- **Đừng tách DBMS ra một bước riêng cho nhanh.** Năm lát cần cả thư mục và cách đặt tên migration,
  không chỉ tên DBMS — phương án ấy đã bị bác ở **ADR-053**.
- **Đừng để kết nối của khung test đọc mốc ở múi giờ khác kết nối chạy thật.** Luật nằm ở quy ước
  *mốc* của `P2-03`; ở bước này nó phải thành **lệnh** của khung test, không thành một dòng cấu hình
  mẫu ai cũng chép thiếu.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* khối `P2-12` ở `work/scope.txt` — file quy ước code mới ở `docs/product/2-db/`; §0 và
  bốn mục chờ DBMS của `01-quy-uoc-du-lieu.md`; một ADR; `compose.yaml` · `db/` · `scripts/db-check.sh`
  · `scripts/verify.sh`; `CLAUDE.md` §2 · §5; `00-index.md`; một dòng trỏ ở
  `master_plan/prompt-fullstack.md` §3.4. Nhận 2026-09-27, Claude Code, base `f378015`.
- *Nghiệm thu:* (1) mục đầu tiên của file quy ước code là DBMS + phiên bản, câu kiểm là một lệnh in
  phiên bản đang chạy; (2) mỗi mục còn lại (stack · thư mục có thư mục migration · đặt tên migration ·
  khung test · múi giờ kết nối) có một lệnh kiểm, hoặc ghi rõ là chỗ trống có tên kèm bước gỡ; (3)
  một ADR ghi lựa chọn DBMS với phương án bị loại và lời giao của chủ repo; (4) sáu tham số ở §0 của
  `01-quy-uoc-du-lieu.md` có giá trị; (5) **mười tám** phép kiểm `QD-XX` chạy trên DBMS đã chọn, cơ sở
  dữ liệu rỗng ⇒ 0 dòng, output dán ở *Bàn giao*; (6) `scripts/verify.sh` gọi bộ kiểm database,
  output dán; (7) `CLAUDE.md` §2 hàng *Quy ước code* trỏ file mới, `grep -rn 'chưa có owner'` không
  còn hàng nào đã có chủ mà vẫn nói chưa có.
- *Kiểm chứng:* `./scripts/db-check.sh` · `./scripts/verify.sh` · `./scripts/gate.sh` · `grep -rn
  'chưa có owner' CLAUDE.md docs/`.

**Bàn giao:** xong 2026-09-27 — Claude Code, nhánh `chatgpt_involve`, base `f378015`; chưa review
độc lập. File: `docs/product/2-db/10-quy-uoc-code.md` (mới, `QC-01`…`QC-10`, tên theo bản đồ kế hoạch
§5) · **ADR-055** · `compose.yaml` · `db/init/001-vai-va-schema.sql` · `db/migrations/.gitkeep` ·
`db/tests/.gitkeep` · `scripts/db-check.sh` (mới) · `scripts/verify.sh` · `scripts/check-links.ignore`
(một dòng `fe/package.json`) · `01-quy-uoc-du-lieu.md` §0 · `QD-01` · `QD-02` · `QD-30` · `QD-31` ·
`QD-32` · `QD-40` · `QD-50` · `QD-60` · `QD-61` · §8 · §9 · `CLAUDE.md` §2 · §5 · cây thư mục ·
`00-index.md` · `master_plan/prompt-fullstack.md` §3.4 (một dòng trỏ) ·
`docs/work-flow-session/workflow-phien-lam-viec.md` (ba câu *bốn dòng chưa có owner*).

Nghiệm thu → bằng chứng:
1. DBMS mục đầu ⇒ `QC-01`, khối `sql` so `server_version_num`; output `PASS QC-01 (sql) — 0 dòng`
   trên `17.11 (Debian 17.11-1.pgdg13+2)`.
2. Mỗi mục một lệnh ⇒ `QC-02`…`QC-10` đều có khối `sql`/`sh` hoặc hàm có tên; hai chỗ trống có tên:
   kết nối backend (`QC-06`) và `verify.sh` gọi Go/Node trong `be/` · `fe/` (`QC-09`) — cả hai giao
   pha 3.
3. ADR ⇒ **ADR-055**: lời giao nguyên văn *"DBMS cho P2-12: làm theo đề xuất của bạn"*, loại MySQL
   8.4 · SQLite · PostgreSQL 18.
4. Sáu tham số ⇒ bảng §0 có cột *Giá trị*; `db-check.sh` đọc thẳng từ đó.
5. Mười tám `QD-XX` trên database rỗng: `PASS` cho `QD-01` `03` `10` `11` `20` `21` `22` `30` `31`
   `33` `34` `40` `50` `51` `60` `61` (sql, 0 dòng) và `QD-02` · `QD-31(b)` · `QD-32` · `QD-40(b)`
   (lệnh); dòng cuối `db-check: PASS — 26 khối kiểm tài liệu, 4 phép kiểm dạng lệnh, 0 file test`.
   Thêm (không phải nghiệm thu, P2-11 mới là chứng minh đủ): một bản sao script ở scratchpad cài
   một bảng sai mọi quy ước ⇒ `FAIL` ở `QD-01` `03` `10` `11` `20` `21` `34` `40` `50` `60`, `QC-04`
   `QC-10`, `QD-02` (in `delivery grab` cạnh năm mã owner) và `QD-40(b)`.
6. Gate 1 gọi ⇒ `./scripts/verify.sh` in `[db] scripts/db-check.sh` rồi `db-check: PASS …`; trước khi
   sửa `verify.sh`, `QC-07 (sh)` đỏ đúng câu *"scripts/verify.sh không gọi scripts/db-check.sh"*.
7. `CLAUDE.md` §2 ⇒ hàng *Quy ước code* trỏ file mới; `grep -rn 'chưa có owner' CLAUDE.md docs/`
   còn *Schema* · *Hợp đồng API* · *Route* (đúng, chưa có chủ) và các câu lịch sử của ADR-035 ·
   ADR-039.

`./scripts/gate.sh` xanh (Gate 3 chỉ note hai file `prompt/maintenance/` chưa track, không phải của
task này). **Cần chủ repo xem:** ADR-055 (lựa chọn đã được giao trước); `QC-05` dùng golang-migrate
và `QC-09` dùng Go · Next.js theo §3.4 — đề xuất, chưa đọc lại. Máy chạy bộ kiểm cần Docker: lượt đổi
`db/` mà Docker tắt thì Gate 1 **đỏ**, có chủ ý. Trạng thái: `work/backlog.md` → *Done*.

[↑ đầu file](#top)

---

<a id="p2-13"></a>
### P2-13 — Mười một file pha 2 sẽ tự khai là xong, mà chưa ai diễn thử một buổi bán qua chúng

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 13/14 (kế
hoạch §6) · **cần xong trước:** `P2-03` → `P2-12` (toàn bộ) · **chặn** `P2-14` · **đây là chỗ các ô
cổng §9 được KÝ**

**Goal:**
Xong rồi thì ba scenario nghiệm thu
([`08-scenario.md`](../docs/product/0-ba/ban-hang/08-scenario.md) §8) đi hết được **qua lược đồ**
bằng dữ liệu thật, mỗi dòng `YC-01`…`YC-20` · `YC-22`…`YC-25` được chấm bằng **hai** câu, và các ô cổng §9 có chỗ ký
với bằng chứng kèm theo.

**Nói một câu, việc phải làm là gì:**
Dựng **cổng chất lượng pha 2** — file mà các ô §9 của kế hoạch được ký vào — bằng cách diễn ba
scenario qua lược đồ và chấm ngược hai mươi dòng `YC`. Việc **không** phải làm: gặp một chỗ không
trả lời được thì ghi `F-XXX`/`U-XXX`, **không tự thiết kế bù** ngay trong lượt chấm.

**Vì sao có task này:**
Kế hoạch §9 viết sẵn các ô cổng nhưng nói rõ **chúng không được tick ở đó**: kế hoạch không sở hữu
sự thật nào, và hai bản tick sẽ trôi khỏi nhau (**F-001** · **F-033**). Chỗ ký là một file do bước
này sinh ra, đúng cách cổng pha 1 được ký ở
[`07-cong-chat-luong-pha-1.md`](../docs/product/1-system-design/07-cong-chat-luong-pha-1.md) §7.
Và cách chấm đã được chứng minh: `BA-11` và `P1-11` tìm ra chỗ hụt bằng đúng việc **diễn scenario**
— `F-036` · `F-037` · `F-038` đều sinh ra từ `P1-11`, không từ một vòng đọc từng mục.

**Không làm thì mất gì:**
- **Lược đồ đẹp mà không chạy nổi một buổi bán.** Từng lát xanh riêng lẻ không chứng minh chúng nối
  được với nhau — đúng chỗ `P1-11` đã bắt được ba khoản nợ.
- **Pha 3 nhận một nền chưa ai chấm** ⇒ chỗ hụt lộ ra lúc đã có endpoint viết trên nó, và sửa lúc
  ấy phải sửa cả hai tầng.
- **Ô cổng được tick bằng cảm giác** ⇒ cổng pha 2 lặp lại đúng thứ cổng pha 1 mất nhiều lượt để bỏ:
  một cổng tick trơn không chặn được gì (`F-033`).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc [`08-scenario.md`](../docs/product/0-ba/ban-hang/08-scenario.md) §8 (ba scenario);
   `04-yeu-cau-du-lieu.md` §7 (**phép chấm hai câu**) và cả hai mươi dòng `YC`; kế hoạch §9; cách
   cổng pha 1 được ký ở `07-cong-chat-luong-pha-1.md` §7.
2. Khai `work/scope.txt`: khối `P2-13`.
3. Chuyển `P2-13` sang *In Progress*.
4. Diễn **từng bước** của ba scenario qua lược đồ bằng dữ liệu thật: mỗi bước phải **ghi được** và
   **đọc lại được**; tiền của cả ba cộng lại được từ `shop-facts.md`.
5. Chấm ngược `YC-01`…`YC-20` · `YC-22`…`YC-25`, mỗi dòng **hai** câu: *đọc ra được không* · *dựng được trạng thái
   sai không*. Dòng nào không trả lời được là **một chỗ lược đồ còn thiếu**, không phải một dòng
   viết chưa rõ — ghi `F-XXX`/`U-XXX`, **không** tự thiết kế bù.
6. Ký các ô cổng vào file mới, **mỗi ô kèm bằng chứng**. Ô không tick được thì **để trống kèm lý do
   và mã của chỗ đang chặn** — không tick hộ, không xoá ô. Rồi `./scripts/gate.sh`.
7. Gate 2: mỗi ô cổng map vào một output thật hoặc một mã chặn có tên.
8. `00-index.md` thêm dòng. Đối chiếu **bốn mã nợ pha 1** (`F-034` · `F-036` · `F-037` · `F-038`):
   mỗi mã hoặc đã đóng, hoặc có **một dòng** trong file pha 2 nói rõ lược đồ đứng thế nào khi nó
   còn mở (ô cổng thứ mười một).
9. Tick `P2-13` → *Done*; điền khối **Bàn giao**; xoá khối scope.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng tick một ô vì "nhìn chung là đạt".** Mỗi ô của §9 có sẵn **cách chứng minh** viết kèm —
  dùng đúng cách đó.
- **Đừng sửa lược đồ ngay trong lượt chấm.** Một lượt vừa chấm vừa sửa là một lượt tự chấm mình;
  chỗ hụt thành một `F-XXX` và một bước riêng.
- **Đủ các ô KHÔNG phải câu *"được, sang pha 3"*.** Ký chuyển pha là quyền **chủ repo** (kế hoạch
  §9).

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

<a id="p2-14"></a>
### P2-14 — Pha 1 đã viết hộ pha sau và cổng không bắt được (`F-040` · `F-041`); pha 2 có mười một file và nhiều cửa hơn

**Phụ thuộc** (bản đọc nhanh — kế hoạch §6 thắng khi lệch) · bước 14/14 (kế
hoạch §6) · **cần xong trước:** `P2-13` · **bước cuối của pha 2**

**Goal:**
Xong rồi thì không endpoint · route · component nào nằm trong file pha 2, và mọi pointer từ pha 1
sang pha 2 còn đúng. Pha 3 mở ra và đọc được một nền không lẫn đầu ra của chính nó.

**Nói một câu, việc phải làm là gì:**
Chạy một bộ lọc trên **mọi** file pha 2 và rà lại mọi pointer, rồi **in cả lệnh chưa lọc cạnh lệnh
đã lọc**. Việc **không** phải làm: đừng sửa nội dung nghiệp vụ hay lược đồ trong lượt này — thấy
một chỗ sai thì ghi `F-XXX`, vì một lượt rà vừa sửa vừa chấm là một lượt tự chấm mình.

**Đây là con bug `F-040` · `F-041`.**
Hai finding ấy ghi đúng chuyện này ở pha 1: một pha viết những dòng thuộc pha sau, và vòng rà lẫn
cổng đều không bắt được — `T-079` mới đóng cả hai ngày 2026-09-20. Vòng rà trước không bắt được vì
nó tin vào một bộ lọc **im lặng**, và một bộ lọc rỗng vì viết sai trông y hệt một bộ lọc rỗng vì
không có lỗi (**F-017**). Pha 2 rộng hơn pha 1 ở chỗ nó có mười một file và một vùng SQL hợp lệ,
nên cửa để lọt nhiều hơn.

**Không làm thì mất gì:**
- **Pha 3 đọc bốn dòng hợp đồng API do pha 2 viết hộ như đầu vào đã chốt** — lần thứ hai của
  `F-040` · `F-041`, và lần này người đọc đứng ở pha sau nên không có ai để đối chiếu.
- **Pointer chết giữa hai pha.** Pha 1 trỏ sang pha 2 ở nhiều chỗ (`architecture.md` §12.3 ·
  `02-thoi-gian-ngay-ban.md` §5 · `04-yeu-cau-du-lieu.md` §7); Gate 1b chấm đường dẫn, **không**
  chấm việc đích còn nói đúng cái nó từng nói.
- **Một bộ lọc rỗng vì viết sai được đọc là *"sạch"*** ⇒ lượt rà tạo lòng tin mà không tạo bằng
  chứng.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc **`F-017` nguyên văn** (lệnh chưa lọc cạnh lệnh đã lọc), **`F-040`** · **`F-041`**, cách
   `P1-12` đã rà pha 1, và `scripts/check-phase-boundary.sh` sau khi `P2-02` sửa.
2. Khai `work/scope.txt`: khối `P2-14`.
3. Chuyển `P2-14` sang *In Progress*.
4. Chạy bộ lọc trên **mọi** file `docs/product/2-db/`: HTTP verb + `/api/` · route · JSX-looking
   tag · tên component.
5. Không có dữ kiện nghiệp vụ ở bước này. Gặp một dòng không chắc thuộc pha nào ⇒ hỏi **chủ repo**,
   đừng tự xử — ranh giới pha là quyết định, không phải sở thích.
6. **Dán cả lệnh chưa lọc cạnh lệnh đã lọc** (**F-017**): người đọc phải thấy bộ lọc có đọc được gì
   không, trước khi tin rằng nó không thấy gì. Rồi `./scripts/gate.sh` — Gate 1d là lớp thứ hai,
   không phải lớp duy nhất.
7. Gate 2: mỗi dòng *Acceptance* map vào một cặp output (chưa lọc · đã lọc).
8. Rà **pointer hai chiều**: `grep -rn '2-db'` và `grep -rn 'pha 2'` — mọi chỗ pha 1 hứa *"việc của
   pha 2"* nay phải trỏ được vào một dòng thật, và mọi chỗ pha 2 trỏ ngược về pha 1 phải còn đúng.
   Chỗ lệch là bug của **lượt này** (`CLAUDE.md` §7.2).
9. Tick `P2-14` → *Done*; điền khối **Bàn giao**; xoá khối scope. Pha 2 đóng ở đây về mặt
   việc — **ký chuyển pha 3 là quyền chủ repo**.
10. Khối `git commit` dán được, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng tin một output rỗng.** Đó là toàn bộ nội dung của `F-017`.
- **Đừng sửa chỗ sai ngay trong lượt rà.** Ghi `F-XXX`; sửa là một bước riêng, có cổng riêng.
- **Đừng bỏ qua file quy ước code (`P2-12`).** Nó là file pha 2 dễ mang tên route và tên component
  nhất, vì nó nói về cấu trúc thư mục của cả dự án.

**Nhận việc** — *điền lúc nhận, khi mọi bước ở* Cần xong trước *đã `Done`* (**ADR-051**):
- *Phạm vi:* —
- *Nghiệm thu:* —
- *Kiểm chứng:* —

**Bàn giao:** —

[↑ đầu file](#top)

---

## Khuôn viết một bước mới của pha 2

Dùng các khối *lập kế hoạch* của **Khuôn L1+** ở
[`work/backlog.md` → *Task Detail Template*](backlog.md#template) — Goal · vì sao · hỏng thì mất gì
· cách hoàn thành · bẫy — kèm năm khác biệt của file này (**ADR-051**, 2026-09-25):

1. Dòng đầu entry là **Phụ thuộc**: *bước N/14*, **cần xong trước**, **chặn**, **chỗ đang chặn** nếu
   có — bản đọc nhanh, kế hoạch §6 thắng khi lệch. **Không** ghi mức: mức sống ở §6.
2. **Không có file prompt riêng.** Entry cuối bằng khối **Nhận việc** (*Phạm vi · Nghiệm thu · Kiểm
   chứng*) để trống có nhãn; chỉ điền khi mọi bước ở *Cần xong trước* đã `Done` (T-051).
3. Bước 3 và bước 9 của *Cách hoàn thành* nói tới `work/backlog.md` — đó là nơi dòng trạng thái
   sống, không phải file này.
4. Bước xong thì entry **ở lại đây** và nhận khối **Bàn giao** cuối entry — kết quả, output gate,
   phần còn thiếu kèm link. Không dòng ✅, không cột trạng thái.
5. **Không một dòng lược đồ nào vào entry.** Tên bảng, tên cột và khoá ngoại có owner ở
   `docs/product/2-db/` từ `P2-04` (**ADR-035**); một entry mô tả mang chúng là bản chép thứ hai
   (**F-001**).

[↑ đầu file](#top)
