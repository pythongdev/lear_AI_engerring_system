<a id="top"></a>
# Backlog — pha 1 · System design

Mô tả dài của mười hai bước `P1-01`…`P1-12`. Dựng 2026-09-04 (T-049) theo yêu cầu chủ repo;
quyết định vì sao nó là một file riêng: `docs/decisions.md` **ADR-034**.

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Task nào đang *Ready*, *In Progress* hay *Done*
> đọc ở `work/backlog.md` — đó là file `scripts/brief.sh` đọc và đẩy vào mọi phiên mới
> (`docs/decisions.md` ADR-002). Một dòng trạng thái viết ở đây là một dòng **không phiên nào
> thấy**.
>
> **Nó cũng không giữ thứ tự, mức, hay đầu ra kiểm chứng được của từng bước** — ba thứ đó ở
> `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Chép về đây là tạo bản thứ hai, và bản
> thứ hai luôn trôi (`work/findings.md` **F-001**).

## Ba file, ba việc — đọc bảng này trước khi sửa bất kỳ file nào

| Câu hỏi | Đọc ở |
|---|---|
| Pha 1 còn nợ gì · thứ tự · mức · đầu ra kiểm chứng được · cổng sang pha 2 | `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` |
| Bước nào **đang** chạy, xong chưa | `work/backlog.md` → *Ready* · *In Progress* · *Done* |
| **Vì sao** có bước này, hỏng thì mất gì, chạy mười bước thế nào | **file này** |
| Sự thật nghiệp vụ, invariant, quyết định | owner ở `CLAUDE.md` §2 — không file nào ở trên |

## Luật của file này — bốn câu

1. **Mô tả cả mười hai bước được viết trước; dòng trạng thái thì không.** Chỉ bước nào **nhận
   được ngay** mới có một dòng ở `work/backlog.md` → *Ready*. Lý do đo được: `brief.sh` cắt danh
   sách *Ready* ở sáu mục, nên mười hai dòng đổ vào đó đẩy bảy dòng ra khỏi tầm nhìn của mọi phiên
   mới — đúng cơ chế đã làm `U-011` và `BA-12` vô hình (**F-012**). Mô tả nằm ở file này thì không
   chiếm chỗ nào của brief.
2. **Entry TRỎ, prompt GIỮ.** *Acceptance* và *Verify* nằm trong file prompt viết lúc nhận việc,
   không nằm ở đây — cùng luật với `work/backlog.md` → *Task Detail Template*.
3. **Bước xong thì entry ở lại đây**, thêm một dòng *Xong ngày…* ở đầu entry; dòng `- [x]` đi vào
   `work/backlog.md` → *Done*. Không có mục *đã xong* riêng ở file này: mười hai bước là một pha,
   tách đôi làm mất đường đọc từ P1-01 tới P1-12.
4. **Bước mới của pha 1 vào đây, không vào `work/backlog.md`.** Task không thuộc pha 1 thì ngược
   lại. Ranh giới là *pha*, không phải *độ dài*.

## Mục lục

| Bước | Entry |
|---|---|
| P1-01 | [Ai sở hữu lược đồ · API · route](#p1-01) |
| P1-02 | [Ranh giới hệ thống và phụ thuộc ngoài](#p1-02) |
| P1-03 | [Định nghĩa một NGÀY BÁN](#p1-03) |
| P1-04 | [Bảng ba cột — nhóm TIỀN](#p1-04) |
| P1-05 | [Bảng ba cột — nhóm VÒNG ĐỜI](#p1-05) |
| P1-06 | [Bảng ba cột — nhóm MENU · GIÁ · VẾT](#p1-06) |
| P1-07 | [Yêu cầu hình dạng dữ liệu](#p1-07) |
| P1-08 | [Realtime, đường kéo dự phòng, ràng buộc ẩn](#p1-08) |
| P1-09 | [Bảng quầy bốn con số](#p1-09) |
| P1-10 | [Sổ rủi ro](#p1-10) |
| P1-11 | [Diễn ba scenario qua thiết kế](#p1-11) |
| P1-12 | [Rà chéo ranh giới pha](#p1-12) |

**Thứ tự lấy việc, và cái gì chạy song song được: kế hoạch §6.** Đừng đọc thứ tự từ mục lục trên —
nó xếp theo số, còn phụ thuộc thật thì không.

**Chỗ đang chặn, đo lại 2026-09-04** — mỗi chỗ ghi ở owner của nó, đếm lại ở đó chứ đừng tin
con số trong câu này (`work/findings.md` **F-003**):

| Mã | Câu hỏi | Chặn bước |
|---|---|---|
| **U-031** | đơn **giao tận nơi**: ai bấm mốc *"đã ra bàn"*, lúc nào | P1-05 · P1-07 · P1-09 |
| **U-032** | lượt bán trên **sổ giấy** nhập bù tính doanh thu **ngày nào** | P1-03 · P1-04 |
| **U-036** | khoản **trả trước** nhận ngày này, hàng giao ngày khác — doanh thu **ngày nào** *(mở 2026-09-04 bởi chính P1-03)* | P1-03 · P1-04 |
| **U-033** | đơn bị **huỷ** sau khi bếp đã làm xong phần của nó thì chỗ ấy đi đâu | P1-05 · P1-07 · P1-09 |
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** (chỗ **suy ra**, chưa hỏi) | P1-07 · P1-09 |

Cả bốn đều phải hỏi **chủ quán**, và cả bốn đã có sẵn **câu hỏi soạn theo bài học S-4** — hỏi về
**cái quán**, đừng hỏi về cái bảng trong máy (`master_plan/shop-facts.md` §7.2).

✅ **BA-12 đã xong 2026-09-04** (commit `31fb071`): `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4
nay có lát cắt sản xuất theo mẻ, nên **P1-07 và P1-09 hết bị nó chặn**. Chính BA-12 mở ra
**U-033**.

⚠️ **Một chỗ chặn KHÔNG phải câu hỏi nghiệp vụ, nên nó không nằm trong bảng trên:
`work/findings.md` **F-026**.** `I-019` và `I-020` sinh ra ở BA-12 ngày 2026-09-03 — **sau** khi
kế hoạch §6 chia ba nhóm — nên chúng **không thuộc nhóm nào** của P1-04 · P1-05 · P1-06, và cổng
chất lượng §9 vẫn đếm *"mười tám"* trong khi `quality/invariants.md` giữ **hai mươi**. Xếp chúng
vào đâu là **quyết định của chủ repo**. Ai nhận một trong ba bước bảng ba cột đọc F-026 trước;
đừng lặng lẽ kéo hai mệnh đề ấy vào bảng của mình, và cũng đừng lặng lẽ bỏ chúng.

---

<a id="p1-01"></a>
### P1-01 — Ba tài liệu nói ba câu khác nhau về việc AI sở hữu lược đồ · API · route, và pha 2 sẽ đọc đúng chỗ đó

✅ **Xong ngày 2026-09-04** — `docs/decisions.md` **ADR-035** (lược đồ → pha 2 · hợp đồng API → pha 3 ·
route → pha 4 · tầng bảo vệ của từng `I-0xx` → pha 1), **ADR-014** khối *SỬA ĐỔI 2026-09-04*,
`CLAUDE.md` §2 bốn hàng mới, `work/findings.md` **F-023** → *Fixed*. ⇒ **mười một bước còn lại của
pha 1 hết bị chặn.** Entry ở lại đây theo luật 3 đầu file; dòng `- [x]` ở `work/backlog.md` → *Done*.

**Prompt:** [`prompt/SD/P1-01-ranh-gioi-so-huu-L2.md`](../prompt/SD/P1-01-ranh-gioi-so-huu-L2.md)
(viết 2026-09-04 lúc nhận việc, sáu khối theo `docs/prompt-guideline.md`), **L2** ·
bước 1/12 của `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 (ADR-033) ·
**không bị chỗ nào chặn** ·
**mở khoá** mọi bước còn lại của pha 1 (§6: mười bước trong mười một bước còn lại ghi *Cần xong
trước: P1-01*)

**Goal:**
Xong rồi thì câu *"ai sở hữu tên bảng, endpoint và route"* có **đúng một** câu trả lời, đọc được ở
`CLAUDE.md` §2, và không tài liệu nào còn nói ngược nó. Pha 1 biết mình được viết gì và không được
viết gì; pha 2 mở ra mà không phải chọn giữa hai chỗ cùng khai sở hữu.

**Nói một câu, việc phải làm là gì:**
Chốt **ranh giới sở hữu** giữa pha 1 và pha 2–5 rồi ghi nó vào ba chỗ đang lệch (một ADR mới ·
khối sửa đổi cho ADR-014 · một hàng ở `CLAUDE.md` §2). Việc **không** phải làm: đừng chốt hộ lược
đồ, đừng đặt một cái tên bảng nào — bước này quyết **ai được đặt**, không đặt.

**Vì sao có task này:**
`work/findings.md` **F-023**, mở 2026-09-03 (T-048). ADR-014 giao ba thứ ấy cho
`docs/product/1-system-design/architecture.md` và `master_plan/prompt-fullstack.md` §3.4–§3.7;
§8 của file thứ nhất viết *"Điều tài liệu này cố ý KHÔNG làm: không đặt tên bảng, không đặt tên
cột, không vẽ khoá ngoại"*, banner của file thứ hai viết *"Schema · API · route · bất biến CHƯA có
nhà — đừng đi tìm"*, và bảng `CLAUDE.md` §2 không có hàng nào cho chúng. Chỗ này không phải lỗi
chính tả: nó là câu hỏi *pha 1 dừng ở đâu*, và nó phải có lời trước khi bất kỳ bước nào của pha 1
viết dòng đầu tiên.

**Không làm thì mất gì:**
- **Pha 2 thi công đề xuất 16 bảng như một lược đồ đã chốt.** Bản ấy viết 2026-08-31, và
  `architecture.md` §8 đã đo **sáu** thứ nó chưa có chỗ cất — trong đó có **vết hoàn tiền** và
  **khoản nợ**. Thiếu hai thứ đó thì đối soát ngưỡng 0đ (`shop-facts.md` §6.10) không thực hiện
  được, tức là mất cổng chất lượng mạnh nhất của cả dự án.
- **Hoặc tên bảng chảy vào `architecture.md`**, phá đúng câu §8 của chính nó và biến một tài liệu
  mà `docs/product/00-index.md` giới thiệu là *"đặc tả, không phải mã"* thành nửa lược đồ.
- **Mười một bước còn lại của pha 1 mất mốc.** Không có ranh giới thì mỗi bước tự đoán mình được
  viết tới đâu, và cổng P1-12 (*không tên bảng nào lọt vào file pha 1*) không có gì để chấm.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở `work/backlog.md` → *Vòng chạy một task L1*; dưới đây là việc riêng của bước này.

1. Đọc **F-023** (`work/findings.md`), rồi đọc **ba** chỗ nó dẫn — ADR-014 thân mục,
   `architecture.md` §8 cuối mục, banner `master_plan/prompt-fullstack.md` — và §7 của bản xuất
   khẩu (bảng sáu pha, cột *Đầu ra bắt buộc*). Đọc luôn `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §3.
2. Khai `work/scope.txt`: `docs/decisions.md`, `CLAUDE.md`, `work/findings.md`, `work/backlog.md`.
   Ba khối pattern **đã bị commit** ở đầu file là nợ của **T-047** — đừng gỡ hộ, đừng dùng.
3. Chuyển dòng P1-01 từ *Ready* xuống *In Progress*.
4. Viết ADR mới: pha 2 sở hữu lược đồ · pha 3 sở hữu hợp đồng API · pha 4 sở hữu route, và pha 1
   sở hữu **tầng bảo vệ** của từng invariant. Thêm hàng vào `CLAUDE.md` §2 — kể cả khi câu trả lời
   là *"chưa có owner, sinh ra ở pha N"*.
5. Không có dữ kiện nghiệp vụ nào trong bước này, nên không có chỗ phải hỏi chủ quán. Gặp một chỗ
   phải chọn giữa hai cách chia sở hữu ⇒ đó là câu của **chủ repo**, hỏi trước khi ghi.
6. Sửa ADR-014 bằng một **khối sửa đổi** ghi ngày, không viết lại câu cũ (ADR-008 — sửa tiến).
   Chạy `./scripts/gate.sh`; lượt này chỉ đổi tài liệu nên `verify.sh` được bỏ qua (ADR-005), còn
   Gate 1b và Gate 1c vẫn chạy.
7. Gate 2: mỗi dòng *Acceptance* của prompt trỏ tới một dòng thật trong file.
8. Sau khi ghi, `grep -rn` cụm *"chưa có nhà"* và *"cố ý KHÔNG làm"* — mọi pointer nói ngược quyết
   định mới là bug của **lượt này**, không phải task sau. Cập nhật **F-023** sang *Fixed* kèm ngày.
9. Tick P1-01 ở `work/backlog.md` → *Done*; entry này **ở lại đây**, thêm một dòng *Xong ngày…*
   ở đầu (luật 3 đầu file). Xoá pattern của mình trong `work/scope.txt`.
10. Khối `git commit` dán được, liệt kê từng file, **không** kèm `work/scope.txt`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng "sửa cho sạch" bằng cách xoá câu trong ADR-014.** Nó là lịch sử; sửa tiến bằng một khối
  sửa đổi, đúng cách ADR-014 tự làm hai lần trong ngày 2026-09-02 và 2026-09-03.
- **Đừng đọc §3.5 của bản xuất khẩu thành lược đồ đã chốt** chỉ vì nó cụ thể hơn mọi thứ khác.
  Cụ thể không có nghĩa là đã chốt; nó viết trước hơn hai mươi lời chốt của chủ quán.
- **Đừng gộp bước này với P1-04.** Bước này quyết *ai được đặt tên bảng*; bảng ba cột thì chỉ được
  nói *tầng nào giữ* (§7 của kế hoạch). Gộp là để một lượt vừa quyết ranh giới vừa vi phạm nó.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc (F-001 — entry này trỏ, prompt giữ).

[↑ đầu file](#top)

---

<a id="p1-02"></a>
### P1-02 — Quán đã chốt "mất điện thì không dừng bán", nhưng không tài liệu kiến trúc nào kể tên những thứ ngoài quán mà hệ thống đang dựa vào

✅ **Xong ngày 2026-09-04** — `docs/product/1-system-design/01-ranh-gioi-he-thong.md` (mới):
**sáu** phụ thuộc ngoài `PT-1`…`PT-6`, **sáu** dòng đường suy giảm đủ ba vế *quán làm gì · ai bù ·
bù lúc nào*, actor **trỏ** về pha 0 chứ không chép. Mở **U-035** (quán mất mạng mà hệ thống vẫn
sống: khách web vẫn đặt được, quán không thấy) và **F-027** (hai trong năm phụ thuộc mà kế hoạch §6
kể tên — Telegram · một VPS — chỉ có ở bản xuất khẩu, thứ ADR-035 vừa chốt là không sở hữu gì; nó
là đầu vào của cả bốn ràng buộc ẩn ở **P1-08**). ⇒ **P1-08 hết bị P1-02 chặn** (P1-11 vẫn chờ
P1-03 → P1-10); ô thứ tư của cổng chất lượng §9 — *mỗi phụ thuộc ngoài có một đường suy giảm* —
**tick được**, nhưng nó không chứng minh mỗi phụ thuộc đã có nhà: đó là F-027.
Entry ở lại đây theo luật 3 đầu file; dòng `- [x]` ở
`work/backlog.md` → *Done*.

**Prompt:** [`prompt/SD/P1-02-ranh-gioi-he-thong-L2.md`](../prompt/SD/P1-02-ranh-gioi-he-thong-L2.md)
(viết 2026-09-04, T-051) — **L2** · bước 2/12 (kế hoạch §6) · **cần xong trước:** P1-01, **đã xong
2026-09-04** · không chờ câu hỏi nào đang mở

**Goal:**
Xong rồi thì có một chỗ duy nhất trả lời: hệ thống này dựa vào những gì **nằm ngoài nó**, và mỗi
thứ ấy chết thì quán làm gì, ai bù, bù lúc nào. Người dựng pha 2–5 đọc một mục là biết mình không
được thiết kế như thể mọi thứ luôn sống.

**Nói một câu, việc phải làm là gì:**
Liệt kê actor và **phụ thuộc ngoài**, mỗi phụ thuộc kèm **một** dòng đường suy giảm, vào một file
mới của pha 1. Việc **không** phải làm: đừng thiết kế cơ chế dự phòng (retry, hàng đợi, cache) —
bước này chỉ nói *mất nó thì quán làm gì*, còn cơ chế là chuyện của pha 3 và P1-08.

**Vì sao có task này:**
Bốn dữ kiện đã chốt nằm rải ở bốn chỗ và chưa chỗ nào gom lại thành *phụ thuộc ngoài*:

| Thứ nằm ngoài hệ thống | Đã chốt ở | Hôm nay ai giữ |
|---|---|---|
| **VietQR là mã TĨNH** ⇒ không có webhook báo tiền về | `architecture.md` §7 · `shop-facts.md` §1 | §7 nói *"đừng thiết kế như thể có webhook"*, nhưng không mục nào kể nó là một phụ thuộc |
| **Tin nhắn báo có** của ngân hàng — nguồn đối soát thứ ba | `shop-facts.md` §6.10 (chủ quán chốt 2026-09-01) | chỉ là một dòng trong luật đối soát |
| **Telegram** báo đơn web về quán | `master_plan/prompt-fullstack.md` §3.4 | một bản xuất khẩu, không phải owner |
| **Sổ giấy** khi mất điện / mất mạng / hỏng máy | `shop-facts.md` §6.11 (chủ quán chốt 2026-09-02) | luật nghiệp vụ; hệ quả kiến trúc chưa ai viết |

Chủ quán đã chốt một câu mà phần lớn hệ thống POS không chốt: **mất điện thì quán không dừng bán.**
Một hệ thống chỉ đúng khi nó đang chạy thì không phục vụ được cái quán này — và hôm nay câu ấy chỉ
sống ở tầng nghiệp vụ.

**Không làm thì mất gì:**
- **Có người thiết kế đối soát VietQR bằng một webhook không tồn tại.** `architecture.md` §7 đã
  cảnh báo đúng chỗ này; cảnh báo nằm trong một mục về *tiền*, nên người dựng tầng tích hợp không
  đọc tới.
- **Mất mạng giữa buổi mà không ai có luật.** Quán chuyển sang giấy, hệ thống thì không biết mình
  đang thiếu dữ liệu ⇒ đối soát cuối ngày báo lệch, và lý do chỉ là *"chưa gõ xong"* —
  `shop-facts.md` §6.11 đã suy ra đúng ca này nhưng chưa tầng nào cất nó.
- **Mất một trong ba nguồn đối soát mà bảng vẫn đòi ngưỡng 0đ** ⇒ nút *"đóng ca dù lệch"* sẽ được
  ai đó thêm vào, và luật ngưỡng 0đ (`architecture.md` §6.4 luật 3) chết ngay hôm ấy.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở `work/backlog.md` → *Vòng chạy một task L1*; dưới đây là việc riêng của bước này.

1. Đọc `architecture.md` §1 (ba mặt) · §7 (bốn đường tiền) · §6.4 (đối soát), `shop-facts.md`
   §6.10 · §6.11 · §1, và `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4.
2. Khai `work/scope.txt`: file mới của pha 1 + `docs/product/00-index.md`.
3. Chuyển dòng P1-02 sang *In Progress* ở `work/backlog.md` (tạo dòng ấy nếu chưa có — luật 1).
4. Viết file mới: **actor** (trỏ `01-actors-pham-vi.md`, không chép) · **phụ thuộc ngoài** một
   bảng · **đường suy giảm** một dòng cho mỗi phụ thuộc. Thêm một dòng vào bảng *Pha 1* của
   `docs/product/00-index.md` trong **cùng** thay đổi.
5. Không tự thêm một phụ thuộc chủ quán chưa nói tới (ví dụ máy in bill, tổng đài). Thấy một thứ
   khả nghi ⇒ hỏi, hoặc ghi `U-XXX`.
6. `./scripts/gate.sh`.
7. Gate 2: mỗi phụ thuộc trỏ được tới dòng chốt của nó ở `shop-facts.md`.
8. `grep -rn` cụm *"webhook"* và *"Telegram"* — chỗ nào nói ngược mục mới là bug của lượt này.
9. Tick ở `work/backlog.md` → *Done*; entry này ở lại đây kèm dòng *Xong ngày…*; dọn scope.
10. Khối `git commit` dán được.

**Bẫy hay sửa nhầm nhất:**
- **Đừng chép giờ bán, số bàn hay số tài khoản vào file mới.** Chúng thuộc `shop-facts.md`
  (ADR-001); mục này chỉ nói *hệ thống dựa vào cái gì*.
- **Đừng biến "sổ giấy" thành một tính năng.** Nó là **quy trình của người**; thứ hệ thống nợ nó
  chỉ là chỗ nhập bù và một dòng *"còn N lượt bán trên giấy chưa nhập"* ở bảng đối soát.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-03"></a>
### P1-03 — Ba luật "doanh thu tính ngày nào" đã chốt, nhưng "một ngày bán" thì chưa có định nghĩa ở đâu

✅ **Xong ngày 2026-09-04** — `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` (mới):
**một ngày bán = một ngày lịch trong múi giờ quán**, đóng ở mốc đầu và mở ở mốc cuối, phủ **cả hai
mươi tư giờ** chứ không phải giờ bán 06:00–11:00 — nên thu nợ và hoàn tiền lúc 14h đều có ngày.
Kèm bảng **mốc tính tiền** (mỗi việc chạm tiền đúng **một** mốc; ba luật đã chốt **trỏ** về đây chứ
không được nhắc lại bằng lời khác) và mục **nguồn thời gian** (một nguồn, cấp ở nơi ghi, không lấy
từ máy khách — viết bằng ngôn ngữ tầng, không tên cột, không kiểu dữ liệu). `I-014` và `I-015`
**không đổi một chữ**; công thức `architecture.md` §6.4 **không bị viết lại**.
Mở **U-036** — khoản **trả trước** nhận ngày này cho đơn giao ngày khác tính doanh thu ngày nào:
chiều **ngược** của luật nợ §6.14, và không lời chốt nào phủ nó. ⇒ **P1-04 hết bị P1-03 chặn**,
nhưng ô `I-014` của nó phải mang **hai** mã đang mở (`U-032` · `U-036`), không được tick trơn.
Ô thứ ba của cổng chất lượng §9 — *định nghĩa ngày bán có đúng một chỗ* — **tick được**; tick nó là
việc của P1-11/P1-12, lượt này không tick hộ.
Entry ở lại đây theo luật 3 đầu file; dòng `- [x]` ở `work/backlog.md` → *Done*.

**Prompt:** [`prompt/SD/P1-03-ngay-ban-L2.md`](../prompt/SD/P1-03-ngay-ban-L2.md) (viết 2026-09-04,
T-051) — **L2** · bước 3/12 (kế hoạch §6) · **cần xong trước:** P1-01, **đã xong 2026-09-04** ·
⛔ **đang chặn: U-032** (`docs/product/99-unknowns.md`) — không viết mục *nhập bù* trước khi chủ
quán trả lời

**Goal:**
Xong rồi thì mọi phép cộng tiền trong hệ thống — doanh thu, nợ, hoàn, đối soát — dùng **cùng một**
định nghĩa *một ngày bán*, và định nghĩa ấy có đúng một chỗ để đọc.

**Nói một câu, việc phải làm là gì:**
Định nghĩa *ngày bán* cho **phép cộng tiền** rồi ghi vào một file mới của pha 1, kèm ba luật đã
chốt trỏ về nó. Việc **không** phải làm: đừng chốt hộ ca **nhập bù từ sổ giấy** — đó là `U-032`,
chờ chủ quán.

**Vì sao có task này:**
Múi giờ và giờ bán đã là dữ kiện (`shop-facts.md` §1) — đây **không** phải chỗ thiếu. Chỗ thiếu là
*ranh giới một ngày cho phép cộng tiền*, và ba luật đã chốt cùng chạm vào nó theo ba chiều khác
nhau:

| Luật | Tính vào ngày | Chốt ở |
|---|---|---|
| Bán, kể cả khoản khách **nợ** | **ngày ghi nợ** | `shop-facts.md` §6.14 (2026-08-31) |
| **Hoàn tiền** | **ngày hoàn**, không phải ngày bán gốc | §6.4 (2026-09-01) |
| Lượt bán trên **sổ giấy** | *"nhập ngay khi có thể, không có mốc giờ cứng"* | §6.11 (2026-09-02) |

Hai luật đầu đứng vững vì `I-014` giữ câu *"doanh thu một ngày đã đối soát không bao giờ đổi về
sau"*. Luật thứ ba **không** nói ngày nào, và đó chính là `U-032` — mở 2026-09-03 (T-048).
`architecture.md` §6.4 đã bày công thức đối soát với **hai** ngày ngược chiều nhau cho khoản nợ;
công thức ấy chỉ đọc được khi *một ngày* đã có nghĩa.

**Không làm thì mất gì:**
- **Doanh thu một ngày đã đối soát đổi về sau** ⇒ phá đúng thứ `I-014` giữ, và ngưỡng lệch 0đ
  (`shop-facts.md` §6.10 — *"cổng chất lượng mạnh nhất của cả dự án"*) mất nghĩa.
- **Mỗi tầng tự hiểu một ranh giới ngày.** Quán mở 6h–11h nên hầu hết lượt bán nằm gọn trong một
  ngày lịch, và đó chính là chỗ nguy hiểm: sai sót chỉ lộ ra ở đúng ngày mất điện hoặc ngày có
  người trả nợ — tức là những ngày khó đối chiếu nhất.
- **P1-04 không viết được `I-014`**: cột *phép đối chiếu* của nó phải nói *"cộng trong một ngày"*,
  và câu đó rỗng nghĩa cho tới khi bước này xong.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `shop-facts.md` §1 · §6.4 · §6.10 · §6.11 · §6.14, `quality/invariants.md` **I-014** ·
   **I-015**, `architecture.md` §6.3 · §6.4, và **U-032** ở `docs/product/99-unknowns.md`.
2. Khai `work/scope.txt`: file mới của pha 1 + `docs/product/00-index.md`.
3. Chuyển dòng P1-03 sang *In Progress*.
4. Viết định nghĩa *ngày bán* + ba luật trỏ về nó. Ca **nhập bù** để **trống có chủ ý**, ghi rõ
   *"đang chờ U-032"* ngay tại chỗ — đúng luật của kế hoạch §9 (một ô không tick được thì để trống
   kèm mã của chỗ đang chặn).
5. **Hỏi chủ quán U-032 nếu hỏi được** — câu hỏi đã soạn sẵn trong chính gạch đầu dòng U-032, viết
   về **cái quán** chứ không về cái bảng trong máy (bài học S-4, `shop-facts.md` §7.2). Có lời
   giải thì ghi vào `shop-facts.md` **trước**, rồi mới viết tiếp mục này.
6. `./scripts/gate.sh`.
7. Gate 2: ba luật trỏ về **một** định nghĩa, `grep` ra đúng một chỗ.
8. `grep -rn "ngày bán"` — mọi chỗ đang dùng cụm ấy phải khớp định nghĩa mới, hoặc được sửa trong
   cùng lượt.
9. Tick *Done*; dòng *Xong ngày…* ở entry này; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng định nghĩa *ngày bán* bằng giờ mở cửa.** 6h–11h là giờ **bán**, còn tiền thì đi cả sau
  đó: một lần thu nợ hay hoàn tiền có thể rơi vào 14h. Định nghĩa phải phủ cả những giờ ấy.
- **Đừng tự quyết U-032 bằng câu "cứ tính ngày gõ cho tiện".** Đó là quyết định tiền, và cả hai
  đường ra đều phá một thứ đang có — lý lẽ đầy đủ trong chính U-032.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-04"></a>
### P1-04 — Bảy invariant chạm TIỀN chỉ có cách kiểm bằng kịch bản người; không mục nào nói tầng nào giữ chúng

**Prompt:** chưa có — **L2** · bước 4/12 (kế hoạch §6) · **cần xong trước:** P1-01 · **P1-03**,
**cả hai đã xong 2026-09-04** (định nghĩa *ngày bán* ở
[`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md))
· chạy song song được với P1-05, P1-06 · ⛔ ô `I-014` còn **hai** mã đang mở: `U-032` · `U-036`

**Goal:**
Xong rồi thì bảy mệnh đề chạm tiền — `I-002` `I-005` `I-007` `I-012` `I-013` `I-014` `I-015` —
mỗi mệnh đề có **tầng giữ nó** và **một phép đối chiếu ra rỗng**, và chỗ nào chỉ có người giữ thì
nói thẳng ra như thế.

**Nói một câu, việc phải làm là gì:**
Điền cột giữa và cột phải cho bảy mệnh đề, dùng **đúng** năm giá trị của từ vựng ở kế hoạch §7.
Việc **không** phải làm: đừng đặt tên bảng, tên cột hay ràng buộc cụ thể — nói *"cơ sở dữ liệu
giữ"*, không nói *"`UNIQUE(...)`"* (kế hoạch §3).

**Vì sao có task này:**
`quality/invariants.md` giữ `I-001`…`I-018` với ba khối *Invariant · Why · Verification*, và khối
*Verification* viết bằng **kịch bản nghiệp vụ** — cách **một người** kiểm. Bảng sáu pha
(`master_plan/prompt-fullstack.md` §7) đòi ở pha 1 một bảng **ba cột**, trong đó cột giữa là
*cơ chế cụ thể bảo vệ*. Cột ấy hôm nay **không mục nào có**. Bảy mệnh đề trong nhóm này là nhóm
chạm tiền, nên chúng đi trước.

**Không làm thì mất gì:**
- **Thu sai tiền mà không cơ chế nào chặn và không phép kiểm nào bắt.** Đây là đúng câu
  `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` §10 gọi là rủi ro lớn nhất của pha, và
  nó vẫn đúng nguyên văn.
- **Pha 2 không biết cái gì phải do database giữ.** `architecture.md` §12.3 đã làm mẫu đúng một
  lần cho phần **nợ** (ba ràng buộc *"để database giữ, không để mã ứng dụng giữ"*); sáu mệnh đề
  còn lại của nhóm này chưa ai làm việc ấy.
- **Rủi ro đặc thù của nhóm tiền:** vài mệnh đề ở đây **chỉ** có người giữ, và nếu không nói ra
  thì bảng trông như đã đủ. Ví dụ *"đã nhận tiền"* của VietQR: mã là mã **tĩnh**, không webhook
  (`architecture.md` §7), nên câu ấy do **người đứng quầy** nói — máy không xác minh được.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc kế hoạch §7 (năm tầng) trước tiên, rồi bảy mục `I-0xx` ở `quality/invariants.md`, rồi
   `architecture.md` §6.3 · §6.4 · §7 · §12.2 · §12.3.
2. Khai `work/scope.txt`: file bảng ba cột của pha 1 + `docs/product/00-index.md`.
   **Không** khai `quality/invariants.md`: bước này **không** sửa mệnh đề, chỉ nói ai giữ nó.
3. Chuyển dòng P1-04 sang *In Progress*.
4. Điền bảy hàng. Mỗi hàng: mệnh đề **trỏ** `I-0xx` (không chép câu) · tầng (một trong năm) ·
   phép đối chiếu dạng *"tập này phải rỗng"* bằng ngôn ngữ nghiệp vụ.
5. Gặp mệnh đề mà **không** tầng máy nào giữ được ⇒ ghi tầng 4 hoặc 5 và viết thẳng *"máy không
   ngăn được"*. Đừng nâng cấp cho đẹp bảng; đừng tự thêm một luật mới để nâng nó lên tầng 1 — thêm
   luật là việc của chủ quán.
6. `./scripts/gate.sh`.
7. Gate 2: bảy hàng, không ô trống, mỗi tầng là một trong năm giá trị.
8. Nếu trong lúc điền phát hiện một mệnh đề ở `quality/invariants.md` **sai** hoặc thiếu vế ⇒ đó
   là finding, ghi `F-XXX`; **không** sửa mệnh đề trong bước này (sửa invariant là task riêng, và
   nó chạm nghiệp vụ).
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **`I-005` (nợ) rất dễ ghi nhầm là "đã có ràng buộc".** `architecture.md` §12.3 mới là **đề xuất
  gửi pha 2**, chính nó nói vậy — đừng đọc thành *đã chốt*.
- **`I-014` (doanh thu hai nguồn) có hai vế**: cộng đủ hai nguồn, **và** không khoản nào đứng ở cả
  hai. Vế thứ hai mới là vế database giữ được; vế thứ nhất là một phép cộng, và nó chỉ đúng khi
  *ngày bán* đã có nghĩa — **P1-03 xong 2026-09-04**, định nghĩa ở
  [`docs/product/1-system-design/02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md)
  §1, và bảng §2 của file ấy còn **hai hàng để trống** (`U-032` · `U-036`) ⇒ ô của `I-014` phải
  mang hai mã đó, không tick trơn.
- **`I-015` (một lần thu chia hai phương thức) đừng gộp với `I-002`.** Một cái nói *tổng các phần
  bằng số phải trả*, cái kia nói *tổng phiên bằng tổng đơn* — hai phép cộng khác nhau, và đối soát
  chia theo **phương thức** (`shop-facts.md` §6.10) chỉ đọc được cái thứ nhất.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-05"></a>
### P1-05 — Sáu invariant vòng đời bàn và đơn chưa có tầng giữ, trong khi đúng chúng là chỗ bàn và đơn bị kẹt

**Prompt:** [`prompt/SD/P1-05-invariant-vong-doi-L2.md`](../prompt/SD/P1-05-invariant-vong-doi-L2.md)
(viết 2026-09-04, T-051) — **L2** · bước 5/12 (kế hoạch §6) · **cần xong trước:** P1-01, **đã xong
2026-09-04** · ⚠️ **F-026**: `I-019` · `I-020` chưa thuộc nhóm nào — đọc trước khi điền bảng ·
⚠️ **U-031 chạm `I-017`** (ca đơn **giao tận nơi**) và **U-033 chạm `I-004`** (đơn huỷ sau khi bếp
đã làm xong) — viết hai chỗ ấy theo phương án hẹp và ghi là đang treo · chạy song song được với
P1-04, P1-06

**Goal:**
Xong rồi thì sáu mệnh đề vòng đời — `I-001` `I-003` `I-004` `I-006` `I-016` `I-017` — mỗi mệnh đề
có tầng giữ và phép đối chiếu, kể cả ca **ghép bàn** và ca **suất đem về**.

**Nói một câu, việc phải làm là gì:**
Điền sáu hàng theo từ vựng năm tầng. Việc **không** phải làm: đừng vẽ máy trạng thái mới — bảng
chuyển trạng thái đã chốt ở `docs/product/0-ba/ban-hang/05-vong-doi.md` §5, bước này chỉ nói **ai
giữ** cho nó đúng.

**Vì sao có task này:**
Nhóm này là chỗ *bàn kẹt* và *đơn kẹt*, và nó có hai ca mà một bảng viết ẩu sẽ bỏ sót:

- **`I-001` không đối xứng.** Một bàn nằm trong nhiều nhất một phiên chưa thanh toán, nhưng **một
  phiên gắn được nhiều bàn** khi khách ghép bàn (`ADR-027`, chủ quán chốt 2026-08-31). Một cơ chế
  chỉ đọc theo chiều *bàn → phiên* sẽ chặn nhầm chính ca ghép bàn.
- **`I-004` là chỗ hai trục gặp nhau.** `ADR-009`: nhu cầu sản xuất là trục riêng; hai trục gặp
  nhau đúng **một** chỗ — đơn **đã duyệt** thì nhập nhu cầu, đơn **huỷ** thì rút ra
  (`architecture.md` §2). Cơ chế giữ `I-004` phải giữ đúng một chỗ ấy.

**Không làm thì mất gì:**
- **Hai phiên trên một bàn** ⇒ một hoá đơn không ai thu; đây là ca `master_plan/prompt-fullstack.md`
  §3.5 chi tiết 4 đã kể tên trước cả khi có dự án này.
- **Đơn giao tận nơi không bao giờ `Hoàn thành` được**, hoặc quầy bấm khống một mốc cho suất đang
  ở nhà khách — cả hai đường đều nằm trong **U-031**, và cả hai đều chạm mốc thu tiền.
- **Bàn báo trống trong khi phiên còn mở** ⇒ khách mới bị gán vào bàn đang có khách (`I-003`).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc kế hoạch §7, sáu mục `I-0xx`, `docs/product/0-ba/ban-hang/05-vong-doi.md` §5 (bảng chuyển
   trạng thái) và `architecture.md` §2 · §3.1.
2. Khai `work/scope.txt`: file bảng ba cột + `docs/product/00-index.md`.
3. Chuyển dòng P1-05 sang *In Progress*.
4. Điền sáu hàng. `I-001` phải nói được cả ca ghép bàn; `I-016` phải nói rõ *"chuyển trạng thái
   ngoài bảng §5 bị từ chối"* là tầng nào giữ.
5. **U-031 chưa có lời** ⇒ phần `I-017` liên quan đơn giao tận nơi viết theo **phương án hẹp
   nhất** và ghi thẳng là đang treo (`CLAUDE.md` §3.5, và đúng cách `architecture.md` §11 dặn).
6. `./scripts/gate.sh`.
7. Gate 2: sáu hàng, không ô trống.
8. `grep -rn "một bàn một phiên"` — mọi chỗ diễn đạt tắt câu ấy phải khớp bản không đối xứng của
   `I-001`, hoặc sửa trong cùng lượt.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng ghi `I-006` (suất "đem về" của khách ngồi bàn) vào nhóm đơn mang đi.** Chủ quán chốt
  2026-08-31: suất ấy thuộc **phiên bàn** (`ADR-029`), và đó cũng là lý do báo cáo doanh thu đếm
  nó ở nguồn phiên bàn (`architecture.md` §6.3).
- **Đừng để `I-017` mâu thuẫn `ADR-017`.** Đơn đã `Hoàn thành` vẫn **huỷ được** (chủ quán chốt
  2026-09-02); ràng buộc *"phiên không đóng khi còn đơn chưa xong"* không được biến thành *"trạng
  thái cuối là bất biến"*.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-06"></a>
### P1-06 — Năm invariant menu · giá · vết chưa có tầng giữ, và một trong năm là mệnh đề mà máy CỐ Ý không giữ

**Prompt:** [`prompt/SD/P1-06-invariant-menu-gia-vet-L2.md`](../prompt/SD/P1-06-invariant-menu-gia-vet-L2.md)
(viết 2026-09-04, T-051) — **L2** · bước 6/12 (kế hoạch §6) · **cần xong trước:** P1-01, **đã xong
2026-09-04** · ⚠️ **F-026**: `I-019` · `I-020` chưa thuộc nhóm nào — đọc trước khi điền bảng ·
chạy song song được với P1-04, P1-05

**Goal:**
Xong rồi thì năm mệnh đề — `I-008` `I-009` `I-010` `I-011` `I-018` — có tầng giữ và phép đối
chiếu, và `I-011` được ghi đúng là **tầng người**, không bị nâng lên tầng máy.

**Nói một câu, việc phải làm là gì:**
Điền năm hàng. Việc **không** phải làm: đừng siết `I-011` thành *"máy chặn"* — chủ quán đã chốt
ngược lại, và siết nó là tự đặt luật nghiệp vụ (`CLAUDE.md` §3.5).

**Vì sao có task này:**
Nhóm này chứa ca dạy được nhiều nhất của cả pha. **`I-011`** — *đổi thành phần suất trong giờ bán
không bao giờ xảy ra âm thầm* — từng được viết là *"thành phần suất không đổi trong giờ bán"*, và
câu đó **sai** kể từ lúc chủ quán trả lời `U-018` (2026-09-01): máy **chỉ nhắc một câu rồi vẫn cho
lưu**, vì luật *"chờ hết buổi"* là luật cho **người**. Bài học đã ghi ở
`docs/product/99-unknowns.md`: *một invariant hệ thống không giữ nổi thì không phải invariant* —
thứ sản phẩm giữ được là chuyện đó không xảy ra **âm thầm**: nhắc trước, để vết sau.

Bốn mệnh đề còn lại đều có chỗ dễ sai riêng: `I-008` có **hai** cửa và chúng có **thứ tự** (đang
tạm dừng ⇒ chặn; không tạm dừng ⇒ mới xét giờ bán — `architecture.md` §6.2); `I-009` là snapshot,
thứ chỉ lộ ra sau vài tuần; `I-010` là *từ chối*, **không bao giờ sửa hộ**; `I-018` là mệnh đề đã
**thay** cả `GĐ-01` lẫn `GĐ-05` ngày 2026-09-02.

**Không làm thì mất gì:**
- **Đơn cũ đổi giá theo menu mới** ⇒ doanh thu lịch sử tự đổi, và không đối chiếu được với tiền
  thực thu. Đây là lát cắt C của cả dự án (`prompt-fullstack.md` §5.1).
- **Bảng ba cột nói dối ở đúng một hàng.** Nếu `I-011` được ghi là tầng 1, pha 2 sẽ dựng một ràng
  buộc chặn thật — và quán mất khả năng sửa thành phần giữa buổi, thứ chủ quán cố ý giữ.
- **Mất vết** ⇒ `ADR-024` (MVP **có** lưu vết, phạm vi = thao tác chạm tiền và chạm trạng thái)
  thành một câu không ai thi hành.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc kế hoạch §7, năm mục `I-0xx`, `ADR-023` · `ADR-024`, `architecture.md` §6.1 · §6.2, và
   mục *Đã có lời giải* của `docs/product/99-unknowns.md` phần `U-018`.
2. Khai `work/scope.txt`: file bảng ba cột + `docs/product/00-index.md`.
3. Chuyển dòng P1-06 sang *In Progress*.
4. Điền năm hàng. `I-008` phải nói được **thứ tự** hai cửa; `I-011` ghi tầng 4 kèm câu *"máy không
   ngăn được"* và nói rõ cái máy **có** giữ: lời nhắc + cái vết.
5. Không tự thêm một luật nào cho `I-011`. Muốn máy chặn ⇒ đó là câu hỏi cho chủ quán.
6. `./scripts/gate.sh`.
7. Gate 2: năm hàng, không ô trống; hàng `I-011` chứa câu *"máy không ngăn được"*.
8. `grep -rn "không đổi trong giờ bán"` — bản chữ cũ của `I-011` còn sót ở đâu thì sửa trong cùng
   lượt.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **`I-009` không phải "khoá giá theo phiên".** Mốc khoá giá là **từng lượt gọi** (`ADR-023`), nên
  **một hoá đơn phiên bàn được phép mang hai mức giá** — và đó là kết quả **đúng**.
- **`I-010` là *từ chối*, không phải *sửa hộ*.** Tổ hợp `Chay` + `Nhiều nhân` bị chặn, không được
  tự bỏ bớt option cho hợp lệ.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-07"></a>
### P1-07 — Sáu chỗ thiếu ở §8 mới là một DANH SÁCH; pha 2 không có câu yêu cầu nào để đối chiếu lược đồ

**Prompt:** chưa có — **L2** · bước 7/12 (kế hoạch §6) · **cần xong trước:** P1-04 · P1-05 ·
P1-06 · **BA-12 đã xong 2026-09-04** ⇒ hết bị chặn · ⚠️ chạm **U-031**, **U-033** và **S-5** ở
phần *đã phục vụ cho từng bàn*

**Goal:**
Xong rồi thì pha 2 có một danh sách **yêu cầu** — *phải ghi lại được X* / *phải không thể xảy ra
Y* — đủ để tự chấm bất kỳ lược đồ nào nó dựng, mà không câu nào trong danh sách ấy nhắc tên bảng.

**Nói một câu, việc phải làm là gì:**
Chuyển sáu chỗ thiếu ở `architecture.md` §8, cộng phần **nợ** (§12.3), phần **vết** (`I-012`,
`I-018`) và phần **ai đang trực trạm nào** (§4), thành câu yêu cầu bằng ngôn ngữ nghiệp vụ. Việc
**không** phải làm: đừng thiết kế bảng — kể cả khi §12.3 đã làm mẫu, vì chính §12.3 tự khai nó là
**đề xuất gửi sang pha 2**, không phải lược đồ đã chốt.

**Vì sao có task này:**
`architecture.md` §8 đo được **sáu** thứ mà đề xuất 16 bảng chưa có chỗ cất — vết hoàn tiền ·
khoản nợ · vết thao tác chạm tiền/chạm trạng thái · ai đang trực trạm nào · note *"đem về"* · đã
phục vụ bao nhiêu cho từng bàn — và nói thẳng đó là *"danh sách chỗ thiếu đã biết tính tới
2026-08-31, không phải lời hứa là đã đủ"*. Danh sách ấy nói *thiếu cái gì*; nó **không** nói
*phải đúng cái gì*, nên pha 2 không dùng nó để chấm được.

Hai chỗ trong sáu chỗ ấy phụ thuộc việc chưa xong: **BA-12** (lát cắt sản xuất theo mẻ, đang *In
Progress*) và **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị nào — suy ra, chưa hỏi chủ quán).

**Không làm thì mất gì:**
- **Lược đồ pha 2 không cất được vết hoàn tiền và khoản nợ** ⇒ đối soát ngưỡng 0đ không thực hiện
  được. `architecture.md` §6.4 luật 2 đòi *mỗi dòng trừ/cộng phải mở ra được thành danh sách từng
  khoản, mỗi khoản có người đứng tên*; không có chỗ cất thì câu ấy vô nghĩa.
- **Quyền vẫn phải gán theo `role`** ⇒ sai đúng luật `ADR-016`: quyền gắn **chỗ đứng**, không gắn
  chức vụ. `architecture.md` §4 đã chỉ ra một cột `role` cố định **không diễn được** ca chủ quán
  không đứng quầy.
- **Khách mang về một đĩa không gói** — note *"đem về"* là chỗ chủ quán nhấn đúng chữ (§6.15).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `architecture.md` §8 · §4 · §12.1–§12.3, `quality/invariants.md` `I-012` · `I-018`,
   `shop-facts.md` §6.4 · §6.14 · §6.15, và **§3.4 của `docs/product/0-ba/ban-hang/03-lat-cat.md`**
   (BA-12, xong 2026-09-04) — kể cả mục §3.4.5, nơi phương án hẹp của **U-033** được viết thẳng ra.
2. Khai `work/scope.txt`: file yêu cầu dữ liệu của pha 1 + `docs/product/00-index.md`.
3. Chuyển dòng P1-07 sang *In Progress*.
4. Mỗi dòng của §8 sinh **đúng một** dòng yêu cầu. Thêm ba nhóm §8 chưa kể: nợ · vết · trực trạm.
5. **Đừng suy hộ S-5 và U-031.** Chỗ *"đã phục vụ cho từng bàn"* viết theo phương án hẹp, ghi rõ
   đơn vị đếm là **bàn** và đơn vị bấm là **mẻ** (`U-017` đã chốt), rồi đánh dấu phần chưa chắc.
6. `./scripts/gate.sh`.
7. Gate 2: mỗi dòng §8 có đúng một dòng yêu cầu; bộ lọc tên bảng/tên cột trong file mới **rỗng**,
   và dán cả lệnh **chưa lọc** cạnh lệnh đã lọc (`F-017`).
8. `grep -rn` §8 — nếu tìm ra **chỗ thiếu thứ bảy** thì thêm vào §8 của `architecture.md` trong
   cùng lượt, đúng câu §8 đã dặn: *"Gặp chỗ thứ bảy thì thêm vào đây, đừng tự thiết kế quanh nó"*.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng chép §12.3 sang file mới.** Nó đã là một mục đứng được; chép là tạo bản thứ hai (F-001).
  Dòng yêu cầu chỉ cần trỏ *"hình dạng nhỏ nhất đủ dùng ở §12.3"*.
- **Đừng mã hoá ba tổ hợp nồi.** `architecture.md` §2 chốt: đó là kiến thức của **người đứng bếp**,
  không phải tham số của thuật toán — *"máy không làm, để người làm"*.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-08"></a>
### P1-08 — Bốn ràng buộc kiến trúc ẩn chỉ sống ở một bản xuất khẩu, và không cái nào có dấu hiệu xem lại đo được

**Prompt:** chưa có — **L2** · bước 8/12 (kế hoạch §6) · **cần xong trước:** P1-02 ·
không chờ câu hỏi nào đang mở

**Goal:**
Xong rồi thì bốn ràng buộc — **một** instance BE · **không** hàng đợi · **không** cache · tất cả
trên **một** VPS — nằm trong một owner của pha 1, mỗi cái kèm một **dấu hiệu đo được** nói lúc nào
phải xem lại; và đường realtime có đường kéo dự phòng viết ra thành luật.

**Nói một câu, việc phải làm là gì:**
Ghi bốn ràng buộc + dấu hiệu, và luật *realtime không được là đường duy nhất*. Việc **không** phải
làm: đừng chọn thư viện, đừng đặt tên endpoint, đừng chốt chu kỳ giây — pha 3 làm việc ấy.

**Vì sao có task này:**
`master_plan/prompt-fullstack.md` §6.8 đã viết bốn ràng buộc kèm dấu hiệu (*"xem lại khi confirm
đơn > 500ms"*, *"xem lại khi menu > 200 món"*), và nó là **bản xuất khẩu** — banner của chính nó
viết *"không phải nhà của sự thật nào"*. `architecture.md` §5 có một câu về realtime
(*"màn trạm vẫn phải tự lấy lại dữ liệu theo chu kỳ"*) nhưng không mục nào giữ bốn ràng buộc.

Ràng buộc nguy hiểm nhất trong bốn: **BE chạy một instance** vì SSE giữ kết nối trong bộ nhớ
process. Thêm một replica là **trạm mất việc ngẫu nhiên** — bản xuất khẩu gọi đây là *chỗ khó
debug nhất dự án*, và nó đúng.

**Không làm thì mất gì:**
- **Mất SSE ⇒ trạm không nhận việc**, và vì màn trạm **không có nút nào** (`architecture.md` §1.1)
  nên không ai ở bếp phát hiện ra: thẻ không hiện thì trông y hệt *"không còn việc"*.
- **Ai đó thêm replica cho "an toàn"** ⇒ hỏng ngẫu nhiên, giờ đông khách, không tái hiện được.
- **Ràng buộc không có dấu hiệu thì thành giáo điều.** Không đo được lúc nào phải bỏ nó, người ta
  hoặc giữ mãi, hoặc bỏ vì cảm tính.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `prompt-fullstack.md` §6.8 · §4 (ràng buộc 9), `architecture.md` §5 · §1.1,
   `shop-facts.md` §6.11 (sổ giấy), và file ranh giới hệ thống mà P1-02 vừa viết.
2. Khai `work/scope.txt`: file realtime/ràng buộc của pha 1 + `docs/product/00-index.md`.
3. Chuyển dòng P1-08 sang *In Progress*.
4. Viết: đường **đẩy** (việc xuống trạm) · đường **kéo** dự phòng · bốn ràng buộc, mỗi cái một
   dấu hiệu **đo được** (một con số hoặc một sự kiện quan sát được, không phải *"khi cần"*).
5. Không tự đặt ngưỡng mới cho quán (số món, số bàn, thời gian chờ) — lấy ở `shop-facts.md`, hoặc
   ghi là dấu hiệu **kỹ thuật** của hệ thống chứ không phải dữ kiện quán.
6. `./scripts/gate.sh`.
7. Gate 2: bốn ràng buộc, bốn dấu hiệu; `grep` cụm *"khi cần"* và *"nếu chậm"* trong file mới ⇒
   **rỗng**.
8. `grep -rn "một instance\|SSE"` — chỗ nào nói ngược thì sửa cùng lượt.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng thiết kế đường kéo thành "trạm bấm tải lại".** Màn trạm là **chỉ đọc** và không có nút
  nào (`ADR-011`); đường kéo phải tự chạy.
- **Đừng đọc "không hàng đợi" thành "không bao giờ có hàng đợi".** Nó là *chưa cần, và đây là dấu
  hiệu để xem lại* — đúng tinh thần `prompt-fullstack.md` §6.8.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-09"></a>
### P1-09 — §3 vẫn là phương án ba con số mà §11 của chính nó tuyên bố đã hết đúng, và việc viết lại đang được giao cho một task đã *Done*

**Prompt:** [`prompt/SD/P1-09-bang-quay-bon-con-so-L2.md`](../prompt/SD/P1-09-bang-quay-bon-con-so-L2.md)
(viết 2026-09-04, T-051) — **L2** · bước 9/12 (kế hoạch §6) · **BA-12 đã xong 2026-09-04** ⇒ chỉ còn
chờ **S-5**, và đọc **U-033** trước khi viết con số thứ tư · độc lập với cả dãy P1 còn lại ·
đây là con bug **F-024**

**Đây là con bug F-024.** Vòng rà trước không bắt được vì T-036 sửa **sáu** pointer trong một lượt
và §11 là một trong sáu: nó được sửa đúng phần *nội dung đã cũ* và giữ lại phần *giao việc*. Câu
hỏi không ai đặt là **"cái tên trong câu này còn sống không"**.

**Goal:**
Xong rồi thì bảng ở quầy trong `architecture.md` §3 có **bốn** con số đúng như lời chủ quán, và
không câu nào trong tài liệu còn giao việc cho một mã task đã đóng.

**Nói một câu, việc phải làm là gì:**
Viết lại §3 với bốn con số — **đơn vị bấm là mẻ, đơn vị đếm là bàn** — và gỡ câu §11 đang giao
việc cho `T-036`. Việc **không** phải làm: đừng đụng số mục; §1–§14 bị `ADR-012` và `ADR-013` ghim.

**Vì sao có task này:**
Chủ quán trả lời `S-4` ngày 2026-09-01: bánh gấp xong **có nằm chờ** — chờ đủ đĩa, chờ người rảnh
tay bưng, chờ món khác của cùng bàn — và **người đứng quầy bấm** *"đã làm xong"*. `U-017` chốt
tiếp: bấm **theo mẻ**. `architecture.md` §11 ghi nhận cả hai và kết luận *"Phương án ba con số ở §3
hết đúng và phải viết lại"*, rồi giao việc cho `T-036`. **T-036 đóng 2026-09-01 mà không giao.**
Đo lại 2026-09-03: §3 không chứa cụm *"đã làm xong"*, *"còn ở bếp"* hay *"đã ra bàn"* ở dòng nào.

**Không làm thì mất gì:**
- **Quầy không thấy bánh đang nằm chờ.** Chủ quán phải trả lời **hai lần** mới lấy được dữ kiện ấy
  (lần đầu hỏi sai, ghi ở `shop-facts.md` §7.2); mất con số thứ tư là vứt đúng thứ đắt nhất.
- **Mỗi phiên mới đọc §11 lại tưởng có người khác đang lo** — chỗ trống được che bằng một cái tên,
  cùng hậu quả với `F-012` chỉ khác cách che.
- **P1-07 không viết nổi dòng *đã phục vụ cho từng bàn*** nếu §3 vẫn nói ba con số.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `architecture.md` §3 và §11, `shop-facts.md` §5.4 · §7.2 (S-4, S-5), `ADR-026`, **§3.4 của
   `03-lat-cat.md`** (BA-12, xong 2026-09-04) và **U-033**.
2. Khai `work/scope.txt`: `docs/product/1-system-design/architecture.md` · `work/findings.md`.
3. Chuyển dòng P1-09 sang *In Progress*.
4. Viết lại §3: bốn con số, con số thứ tư nhảy **theo bậc mẻ**; gỡ câu giao việc ở §11 và thay
   bằng một câu nói việc ấy nay thuộc bước này.
5. **S-5 chưa hỏi chủ quán** ⇒ phần *"đã bưng ra bàn"* ghi theo phương án hẹp (**theo bàn**) và
   đánh dấu là chỗ suy ra, đúng chỗ `shop-facts.md` §7.2 đang giữ nó.
6. `./scripts/gate.sh`.
7. Gate 2: §3 nêu đủ bốn con số; `grep -n "T-036" docs/product/1-system-design/architecture.md`
   không còn dòng nào **giao việc**.
8. `grep -rn "ba con số"` — mọi chỗ còn nói phương án cũ phải sửa hoặc nói rõ nó là lịch sử.
   Cập nhật **F-024** sang *Fixed* kèm ngày.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng thêm nút nào cho bếp.** `U-009` vẫn nguyên: ba trạm bếp không bấm gì. Cả bốn con số đều
  do **quầy** bấm hoặc do hệ thống suy ra từ đơn đã duyệt.
- **Đừng gộp "mẻ" và "bàn" thành một đơn vị.** Một mẻ phục vụ nhiều bàn; gộp là làm bánh nằm chờ
  trở thành vô hình lần nữa.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-10"></a>
### P1-10 — Năm rủi ro lớn nhất chỉ có ở một bản nháp bị đóng băng, và bản ấy viết trước khi có nợ · hoàn tiền · đối soát ba nguồn

**Prompt:** chưa có — **L1** · bước 10/12 (kế hoạch §6) · **cần xong trước:** P1-04 · P1-05 ·
P1-06 (mỗi rủi ro phải chỉ tên được một cơ chế đã viết ra)

**Goal:**
Xong rồi thì pha 1 có một sổ rủi ro trong đó **mỗi** rủi ro có: cơ chế chặn **đã tồn tại** ở một
mục pha 1, người chịu, và một **dấu hiệu nó đang xảy ra**.

**Nói một câu, việc phải làm là gì:**
Viết lại năm rủi ro theo hiện trạng hôm nay và nối mỗi cái vào một cơ chế có thật. Việc **không**
phải làm: đừng chép bảng `R1`–`R5` của bản nháp — nó là ảnh chụp ngày cũ.

**Vì sao có task này:**
`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` §6 giữ năm rủi ro `R1`–`R5`, và file ấy
bị banner *"Không sửa ở đây"* (`ADR-014`). Quan trọng hơn: bảng ấy viết **trước** ba thứ đã thành
luật từ đó — **cho nợ** (§6.14, 2026-08-31) · **hoàn tiền tính ngày hoàn** (§6.4, 2026-09-01) ·
**đối soát ba nguồn ngưỡng 0đ** (§6.10, 2026-09-01). Ba thứ ấy đều là đường tiền, nên một sổ rủi
ro không có chúng là sổ của một hệ thống khác.

**Không làm thì mất gì:**
- **Rủi ro lớn không có người chặn**, và lần đầu nó xảy ra là lần đầu có ai đó nghĩ về nó.
- **Sổ rủi ro thành trang trí.** Một dòng *"cẩn thận hơn"* không chặn được gì; ràng buộc *mỗi rủi
  ro chỉ tên một cơ chế đã viết ra* là thứ duy nhất phân biệt sổ thật với sổ hình thức.
- **Cổng chất lượng pha 1 mất một ô** (kế hoạch §9, ô thứ sáu).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc bản nháp §6 (**để biết cái cũ nói gì, không để chép**), ba file bảng ba cột do P1-04–P1-06
   vừa viết, `architecture.md` §6.4 · §7 · §12, `shop-facts.md` §6.10.
2. Khai `work/scope.txt`: file sổ rủi ro + `docs/product/00-index.md`.
3. Chuyển dòng P1-10 sang *In Progress*.
4. Viết năm dòng. Mỗi dòng: rủi ro · hậu quả **ở quán** (không phải thuật ngữ) · cơ chế chặn kèm
   **chỗ đọc** · người chịu · dấu hiệu đang xảy ra.
5. Không tự phát minh một cơ chế chưa ai viết. Rủi ro chưa có cơ chế ⇒ ghi thẳng *"chưa có cơ chế"*
   và mở một bước hoặc một `F-XXX` — đừng để nó trông như đã được chặn.
6. `./scripts/gate.sh`.
7. Gate 2: năm dòng, mỗi dòng trỏ được tới một mục pha 1 có thật.
8. `grep -rn "R1\b"` ở tài liệu pha 1 — không chỗ nào được trỏ về bảng của bản nháp như một owner.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng đếm "đúng năm rủi ro" như một quyết định.** Con số năm đến từ bảng sáu pha, là **phép
  đếm của người viết** — thấy cái thứ sáu thì thêm, đúng luật `F-003`.
- **Đừng xếp *mất realtime* ngang hàng *thu sai tiền*.** Bản nháp xếp chúng cùng bảng; hôm nay đã
  biết rõ hơn: mất realtime có đường kéo dự phòng (P1-08), còn thu sai tiền thì không có đường lùi.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-11"></a>
### P1-11 — Chưa ai diễn ba scenario nghiệm thu BA qua thiết kế, nên không ai biết thiết kế có chạy được nghiệp vụ không

**Prompt:** chưa có — **L2** · bước 11/12 (kế hoạch §6) · **cần xong trước:** P1-02 → P1-10 ·
đây là **cổng** của cả pha

**Goal:**
Xong rồi thì mỗi **bước** của ba scenario ở `docs/product/0-ba/ban-hang/08-scenario.md` §8 trỏ
được tới một cơ chế bảo vệ đã viết ra ở pha 1, và cổng sang pha 2 có mười ô với bằng chứng thật.

**Nói một câu, việc phải làm là gì:**
Diễn ba scenario **qua thiết kế**, ghi lại chỗ nào không trỏ được. Việc **không** phải làm: gặp
chỗ hụt thì **đừng thiết kế bù ngay trong lượt này** — ghi `F-XXX` hoặc `U-XXX`, đúng cách BA-11
đã làm khi nó tìm ra năm chỗ nói lệch nhau.

**Vì sao có task này:**
Đây là bài học đắt nhất của pha 0, và nó lặp lại được. **BA-11** diễn ba scenario và tick cổng
**6/9 kèm lý do cho ba ô còn lại**; hai lượt đọc *context sạch* của nó tìm ra ba chỗ **trong §8**
rồi ba chỗ nữa **trong §1–§7** — thành `F-022`, và một trong ba chỗ ấy thành `U-031`, câu hỏi
**vẫn đang mở hôm nay**. Không lượt diễn nào thì không chỗ nào trong sáu chỗ ấy lộ ra.

Cổng của pha 1 (kế hoạch §9) đã viết sẵn **mười ô, mỗi ô kèm cách chứng minh** — bước này là lượt
chạy nó.

**Không làm thì mất gì:**
- **Thiết kế đẹp mà không chạy được nghiệp vụ** — đúng cột *Hỏng thì mất gì* của kế hoạch §6.
- **Pha 2 dựng lược đồ trên một thiết kế chưa ai thử.** Sửa ở pha 1 là sửa chữ; sửa ở pha 2 là
  sửa `migration` và dữ liệu.
- **Mất cơ hội tìm ra chỗ hai mục đã chốt nói lệch nhau.** `F-022` chỉ lộ ra khi có người **cộng
  lại tiền** và **diễn từng bước**; không cổng máy nào bắt được loại lỗi ấy (`ADR-032` nói thẳng).

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc `08-scenario.md` §8 (ba scenario), rồi toàn bộ file pha 1 do P1-02 → P1-10 sinh ra, và
   kế hoạch §9 (mười ô).
2. Khai `work/scope.txt`: file cổng chất lượng pha 1 + `work/findings.md` + `docs/product/00-index.md`.
3. Chuyển dòng P1-11 sang *In Progress*.
4. Diễn từng bước của từng scenario; mỗi bước ghi **cơ chế nào giữ cho bước ấy đúng** và chỗ đọc.
5. Chỗ nào không trỏ được ⇒ `F-XXX`; chỗ nào là câu hỏi cho chủ quán ⇒ `U-XXX`. Không tự chốt.
6. `./scripts/gate.sh`.
7. Gate 2: mười ô của cổng, ô nào không tick được thì **để trống kèm mã chỗ chặn** — không tick hộ.
8. `grep -rn` mã của mọi `F-XXX`/`U-XXX` vừa mở để chắc chúng nằm đúng owner và brief in ra được.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng diễn bằng trí nhớ.** BA-11 dùng **context sạch** cho lượt diễn, và đó là lý do nó thấy
  được chỗ người viết không thấy (`quality/review-gate.md`, Gate 6).
- **Đừng tick 10/10 cho tròn.** Cổng BA tick 6/9 và vì thế nó **có ích**; một cổng 10/10 bằng cảm
  giác không chặn được gì.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="p1-12"></a>
### P1-12 — Không cổng nào chấm ranh giới pha: một tên bảng lọt vào tài liệu pha 1 thì mọi gate vẫn xanh

**Prompt:** chưa có — **L1** · bước 12/12 (kế hoạch §6) · **cần xong trước:** P1-11 ·
bước cuối, chạy ngay trước khi mở pha 2

**Goal:**
Xong rồi thì có bằng chứng đo được rằng không tài liệu pha 1 nào nhắc tên bảng · tên cột ·
endpoint · route · component, và mọi pointer của pha 1 đều mở được.

**Nói một câu, việc phải làm là gì:**
Chạy bộ lọc ranh giới trên mọi file pha 1 và dán kết quả kèm lệnh chưa lọc. Việc **không** phải
làm: đừng dựng một cổng shell mới cho việc này — `CLAUDE.md` §3.8 chỉ cho dựng luật khi cùng một
vấn đề đã tốn hai lần, và đây mới là lần đo đầu tiên.

**Vì sao có task này:**
Ranh giới *pha 0–1 không nhắc tên bảng; pha 2 không nhắc endpoint; pha 3 không nhắc component* là
luật cứng của bảng sáu pha, và **không cổng nào của repo chấm nó**: `check-links.sh` chấm đường
dẫn, `check-doc-status.sh` chấm một mã hai trạng thái, `verify.sh` bị bỏ qua ở lượt chỉ-đổi-tài-liệu.
Một tên bảng lọt vào pha 1 sẽ đi thẳng vào pha 2 như thể đã chốt — đúng ca `F-023` mô tả, chỉ khác
chiều.

Đã có sẵn một chỗ dễ vấp: `architecture.md` §12.3 **cố ý** vượt ranh giới (chủ repo yêu cầu một
mục DB cho phần nợ) và tự khai điều đó ngay trong mục. Bộ lọc phải kể nó ra như một **ngoại lệ có
tên**, không phải như một lỗi — và cũng không được im lặng bỏ qua.

**Không làm thì mất gì:**
- **Pha 1 âm thầm quyết việc của pha 2** và không ai rà lại, vì mọi cổng đều xanh.
- **Bộ lọc rỗng vì viết sai trông y hệt bộ lọc rỗng vì không có lỗi** — `F-017` đã xảy ra đúng như
  thế ở prompt của DOC-5, và cách chữa là **dán cả lệnh chưa lọc**.
- **Ngoại lệ không có tên thì lần sau thành tiền lệ.** §12.3 sẽ được viện dẫn để đưa thêm lược đồ
  vào pha 1.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**

1. Đọc kế hoạch §3 (ba câu không được viết ra) và §9 (ô thứ mười), `architecture.md` §8 và §12.3.
2. Khai `work/scope.txt`: file cổng chất lượng pha 1 (nơi dán kết quả) — bước này **không** sửa
   tài liệu nội dung nào; sửa thì là việc của bước sinh ra chỗ sai.
3. Chuyển dòng P1-12 sang *In Progress*.
4. Chạy bộ lọc trên mọi file pha 1; dán **cả hai** con số: chưa lọc và đã lọc.
5. Mỗi chỗ lọt ra ⇒ trả về **bước đã viết nó**, không tự sửa hộ ở đây.
6. `./scripts/gate.sh`.
7. Gate 2: kết quả lọc = **rỗng**, trừ ngoại lệ §12.3 được kể tên kèm lý do.
8. `grep -rn` lần cuối các pointer của pha 1; `check-links.sh` không chấm đường kết thúc bằng `/`
   (`F-018`) nên chỗ trỏ **thư mục** phải kiểm bằng mắt.
9. Tick *Done*; dòng *Xong ngày…*; dọn scope. Pha 1 đóng ⇒ cập nhật `docs/product/00-index.md`
   bảng *Sáu pha*.
10. Khối `git commit`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng đếm rộng hơn phạm vi.** `F-018`: một con số đếm cả `work/` và `prompt/maintenance/` thì
  đo hoạt động viết lách, không đo việc còn lại.
- **Đừng coi bước này là "dọn cho sạch".** Nó là **phép đo**; chỗ sai trả về bước đẻ ra nó, vì
  người viết mục ấy mới biết câu đúng phải là gì.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

## Khuôn viết một bước mới của pha 1

Dùng nguyên **Khuôn L1+ — bảy khối bắt buộc** ở `work/backlog.md` → *Task Detail Template*, kèm
ba khác biệt của file này:

1. Dòng **Prompt** ghi thêm *bước N/12 (kế hoạch §6)* và **chỗ đang chặn** nếu có.
2. Bước 3 và bước 9 của *Cách hoàn thành* nói tới `work/backlog.md` — đó là nơi dòng trạng thái
   sống, không phải file này.
3. Bước xong thì entry **ở lại đây** kèm một dòng *Xong ngày…* ở đầu, không chuyển mục.

[↑ đầu file](#top)
