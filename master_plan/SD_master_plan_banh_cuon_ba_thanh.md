# System Design — kế hoạch pha 1 dự án Bánh cuốn Bà Thanh Cao Bằng

*Viết 2026-09-03 · T-048 · chủ repo yêu cầu trong phiên: **"BA về cơ bản đã xong, pha tiếp theo sẽ
là system design, hãy làm master plan cho system design thật kĩ và cẩn thận từng bước"**. Quyết
định về hình dạng của kế hoạch này: `docs/decisions.md` **ADR-033**.*

> **File này là KẾ HOẠCH, không sở hữu một sự thật nào.** Nó nói *pha 1 còn nợ những gì và chạy
> theo thứ tự nào*. Nó **không** giữ dữ kiện quán, không giữ invariant, không giữ đặc tả. Chỗ nào
> cần một con số hay một luật, đọc ở owner của nó (`CLAUDE.md` §2) — ở đây cố ý không có bản chép
> thứ hai (`work/findings.md` **F-001**).
>
> **Trạng thái của từng bước không nằm ở đây.** Owner của *Tasks* là `work/backlog.md`. Bảng §6
> dưới đây có sáu cột và **không có cột Trạng thái** — đó là chỗ lệch có chủ đích so với §11 của
> `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`, nơi một bảng ⬜ trong kế hoạch và một dòng
> `- [x]` trong backlog nói về cùng một việc bằng hai giọng.
>
> **Pha 1 là L3 ở cấp giai đoạn** — nó quyết định cái gì bảo vệ cái gì cho toàn hệ thống. Nhưng
> **không bước nào trong bảng §6 là L3**: mỗi bước là một L1/L2 làm xong trong một phiên, đúng
> `CLAUDE.md` §3 (L3 ⇒ chia thành nhiều task L1/L2).

---

## 1. Bốn tài liệu nói về pha 1 — biết cái nào là cái nào trước khi đọc tiếp

Đây là chỗ dễ đọc nhầm nhất của cả pha. Bốn file dưới đây đều nói về pha 1 và **chỉ một** trong
số đó là owner.

| File | Nó là gì | Được đọc như |
|---|---|---|
| [`docs/product/1-system-design/architecture.md`](../docs/product/1-system-design/architecture.md) | **OWNER duy nhất của Architecture** (`CLAUDE.md` §2), §1–§14, 592 dòng | sự thật đang có hiệu lực |
| [`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md`](phase_1_system_design_banh_cuon_ba_thanh.md) | **bản nháp đầu**, banner hoá 2026-09-03 (ADR-014 khối *SỬA ĐỔI*) | bản ghi lịch sử — `I1`–`I8` ở đó **đã bị thay** bởi `I-001`…`I-018` |
| [`master_plan/prompt-fullstack.md`](prompt-fullstack.md) §3.4–§3.7 | **bản xuất khẩu**, viết 2026-08-31 | **đề xuất** stack · 16 bảng · API · route, chưa ai chốt là đầu ra pha nào |
| file này | **kế hoạch pha 1** | thứ tự việc, không phải nội dung việc |

**Vì sao phải nói ra:** bản nháp giữ `SD-01`…`SD-10` làm mã task, **và** `SD-01`…`SD-07` làm mã
quyết định — hai nghĩa cho một mã trong cùng một file. Kế hoạch này vì thế **không dùng lại tiền
tố `SD-`**; nó dùng **`P1-XX`** (pha 1). Thêm một nghĩa thứ ba cho `SD-01` là dựng đúng cái bẫy mà
`work/findings.md` **F-015** · **F-021** · **F-022** đã ghi ba lần: một mã định danh, hai chỗ, hai
nghĩa.

---

## 2. Câu hỏi pha 1 phải chốt xong — một dòng

> **Cái gì bảo vệ cái gì.**

Đó là câu của pha 1 trong bảng sáu pha ([`prompt-fullstack.md`](prompt-fullstack.md) §7). Pha 0 đã
trả lời *quán làm gì, ai thao tác, tiền đi đường nào*; pha 2 sẽ trả lời *dữ liệu sống ở đâu*. Pha 1
đứng giữa và chỉ có một việc: **mỗi mệnh đề phải-luôn-đúng phải có một cơ chế cụ thể giữ nó, và một
phép kiểm chứng minh cơ chế đó còn sống.**

Bốn đầu ra bắt buộc mà bảng sáu pha đòi ở pha 1, cộng một thứ thứ năm mà dự án này thêm vào:

| # | Đầu ra | Hôm nay có chưa |
|:--:|---|---|
| 1 | Bảng bất biến **ba cột**: mệnh đề · bảo vệ bằng · phép đối chiếu | **chưa** — xem §4 |
| 2 | Ràng buộc kiến trúc ẩn + **dấu hiệu phải xem lại** từng cái | chỉ có ở bản xuất khẩu §6.8, chưa vào owner nào |
| 3 | Nguồn thời gian | dữ kiện có (`shop-facts.md` §1); **định nghĩa NGÀY BÁN cho phép cộng tiền thì chưa** |
| 4 | Năm rủi ro lớn nhất kèm cách chặn | chỉ có ở bản nháp §6, và nó viết trước khi có nợ · hoàn tiền · đối soát ba nguồn |
| 5 | **Đường suy giảm** — mất điện, mất mạng, hỏng máy | luật nghiệp vụ có (`shop-facts.md` §6.11); hệ quả kiến trúc thì chưa |

Thứ năm không có trong bảng sáu pha, và nó ở đây vì chủ quán đã chốt một câu mà hầu hết hệ thống
POS không chốt: **mất điện thì quán không dừng bán**. Một hệ thống chỉ đúng khi nó đang chạy thì
không phục vụ được cái quán này.

---

## 3. Ranh giới của pha 1 — ba câu không được xuất hiện trong đầu ra

Ranh giới cứng của bảng sáu pha: *pha 0–1 **không** nhắc tên bảng; pha 2 **không** nhắc endpoint;
pha 3 **không** nhắc component.* Áp vào pha 1:

| Không được viết ra ở pha 1 | Nó là đầu ra của | Pha 1 được viết gì thay vào |
|---|---|---|
| tên bảng, tên cột, khoá ngoại | pha 2 · DB | *"trạng thái này phải do **cơ sở dữ liệu** giữ, không phải do màn hình kiểm"* |
| endpoint, tên hàm, chữ ký API | pha 3 · BE | *"chỉ **một** chỗ trong hệ thống được tính giá, và mọi đường đặt món đi qua nó"* |
| route, component, kích thước chữ | pha 4 · FE | *"màn trạm **không có nút nào** ghi ra tiến độ"* (ADR-011) |

⚠️ **Bản xuất khẩu tự phá luật này ở đúng một chỗ, và biết trước là sẽ có người đọc nhầm.**
[`prompt-fullstack.md`](prompt-fullstack.md) §6.2 viết cột *bảo vệ bằng* của `I1` là
`UNIQUE(open_key)` — một tên cột, ở một bảng dành cho pha 1. Cách đọc đúng: đó là **đề xuất của
pha 2**, hay nhất là đọc nó **sau** khi pha 1 đã viết xong dòng của mình bằng ngôn ngữ tầng. Viết
ngược lại — chép tên cột vào pha 1 rồi gọi là đã chốt — là để một bản nháp ngày 2026-08-31 quyết
lược đồ của một hệ thống mà từ đó tới nay chủ quán đã chốt thêm hơn hai mươi luật.

**Pha 1 cũng không mở lại nghiệp vụ.** Gặp chỗ nghiệp vụ chưa rõ ⇒ hỏi chủ quán, hoặc ghi thành
`U-XXX` (`CLAUDE.md` §3.5 · §4). Không có mức L0 cho luật này.

---

## 4. Pha 1 đã có gì rồi — đọc bốn chỗ này trước khi viết dòng đầu tiên

**4.1 `architecture.md` §1–§14 đã chốt phần *ai được ghi cái gì*.** Ba mặt một miền · luật ghi
(chỉ POS ghi tiến độ) · hai trục (đơn và nhu cầu sản xuất) · quyền gắn **chỗ đứng** chứ không gắn
chức vụ · bốn đường tiền · đối soát ngưỡng 0đ · nợ có mục ở cả ba tầng · mảng quản trị ở §14. Pha 1
**không viết lại** những mục này; chỗ nào một bước ở §6 thấy nó sai thì sửa **tại đó**, không mở
một mục thứ hai nói khác (F-001).

**4.2 `quality/invariants.md` đã có `I-001`…`I-018`, và mỗi mục có ba khối: *Invariant · Why ·
Verification*.** Đây là tài sản lớn nhất pha 0 để lại. Nhưng nó **chưa phải** bảng ba cột mà pha 1
nợ, vì khối *Verification* hôm nay viết bằng **kịch bản nghiệp vụ** (*"mở phiên bàn 5 → gọi một
lượt → quầy bấm tính tiền → gửi thêm một đơn"*), tức là cách **một người** kiểm. Cái còn thiếu là
cột giữa: **tầng nào giữ nó** — và ở vài mục, câu trả lời trung thực sẽ là *"không tầng máy nào
giữ được"*.

**4.3 `master_plan/shop-facts.md` giữ mọi dữ kiện quán** (ADR-001) — giờ bán, múi giờ, giá, nồi,
trạm, mười chín quy tắc nghiệp vụ, sổ giấy, đối soát ba nguồn. Pha 1 **tra**, không chép.

**4.4 Bản xuất khẩu §3.4–§3.7 là đề xuất, và nó viết trước phần lớn quyết định.**
`architecture.md` §8 đã đo: **sáu** thứ mà 16 bảng ấy chưa có chỗ cất (vết hoàn tiền · khoản nợ ·
vết thao tác · ai đang trực trạm nào · note *"đem về"* · đã phục vụ bao nhiêu cho từng bàn). Pha 1
không sửa đề xuất ấy; nó viết **yêu cầu** để pha 2 tự đối chiếu.

### Ba câu bảng sáu pha đòi mà hôm nay chưa ai trả lời

1. **Mỗi `I-0xx` được giữ bởi tầng nào?** Mười tám mệnh đề, không mục nào có cột ấy.
2. **Một ngày bán bắt đầu và kết thúc lúc nào, đối với phép cộng tiền?** Ba luật đã chốt cùng chạm
   vào nó theo ba chiều khác nhau — nợ tính **ngày ghi nợ**, hoàn tính **ngày hoàn**, còn lượt bán
   trên sổ giấy thì *nhập ngay khi có thể, không có mốc cứng*.
3. **Mất SSE / mất mạng / mất điện thì mỗi mặt xử sự thế nào?** Nghiệp vụ đã chốt là *không dừng
   bán*; kiến trúc chưa có đường nào viết ra.

---

## 5. Đầu ra pha 1 nằm ở đâu — bản đồ file, và luật chống bản sao thứ hai

`architecture.md` giữ **§1–§14 và không đánh số lại** (ADR-012 gọi *Nợ* = §12, ADR-013 gọi *admin*
= §14). Nó cũng đã 592 dòng, và `work/findings.md` **F-014** đã xảy ra **năm** lần trên đúng loại
file dùng chung như thế. Nên đầu ra mới của pha 1 đi vào **file mới, một chủ đề một file**, cạnh
nó:

```text
docs/product/1-system-design/
  architecture.md              §1–§14 — GIỮ NGUYÊN, chỉ sửa chỗ sai tại chỗ
  01-ranh-gioi-he-thong.md     P1-02 — actor, phụ thuộc ngoài, đường suy giảm
  02-thoi-gian-ngay-ban.md     P1-03 — nguồn thời gian, định nghĩa ngày bán
  03-bao-ve-invariant.md       P1-04 · P1-05 · P1-06 — bảng ba cột, 18 mệnh đề
  04-yeu-cau-du-lieu.md        P1-07 — cái gì phải ghi được, cái gì phải không xảy ra được
  05-realtime-va-du-phong.md   P1-08 — đường đẩy, đường kéo, ràng buộc một instance
  06-so-rui-ro.md              P1-10 — năm rủi ro + cơ chế chặn + dấu hiệu
  07-cong-chat-luong-pha-1.md  P1-11 — diễn ba scenario qua thiết kế, và cổng sang pha 2
```

Ba luật cho bản đồ này, không cái nào là hình thức:

- **File sinh ra cùng dòng nội dung đầu tiên của nó, không sớm hơn** (`docs/product/00-index.md`,
  mục *Luật ghi*). Một file rỗng tên sẵn là tài liệu nghi lễ (`CLAUDE.md` §3.8).
- **Thêm một file thì thêm một dòng vào bảng *Pha 1* của `docs/product/00-index.md` trong cùng
  thay đổi.** Một owner mà mục lục không kể là owner không ai tìm ra.
- **Mâu thuẫn với `architecture.md` ⇒ sửa `architecture.md`, không viết bản thứ hai.** Ba file
  cùng nói về một mặt thì bản mới nhất luôn thắng trong đầu người viết và bản cũ luôn thắng trong
  đầu người đọc — đó là F-001, và nó đã tốn của repo này bốn lần rà.

---

## 6. Mười hai bước — master task pha 1

Sáu cột. Không có cột *Trạng thái*: nó ở `work/backlog.md`. Cột **Mức** thì ở đây, vì nó quyết
định ceremony của bước và phải đọc được trước khi ai nhận việc.

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|:--:|
| **P1-01** | Chốt pha 1 sở hữu cái gì, pha 2–5 sở hữu cái gì; dọn câu đang giao lược đồ/API/route cho một tài liệu tự khai **không** sở hữu chúng (F-023) | — | Một ADR mới; `CLAUDE.md` §2 có câu trả lời cho *ai sở hữu lược đồ · API · route*; câu sai trong ADR-014 không còn | Pha 2 mở ra với **hai** chỗ cùng khai sở hữu lược đồ ⇒ hai lược đồ, và cái sai được thi công | L2 |
| **P1-02** | Viết ranh giới hệ thống: actor, **phụ thuộc ngoài**, và đường suy giảm của từng phụ thuộc | P1-01 | Mỗi phụ thuộc ngoài (Telegram · VietQR tĩnh · tin nhắn báo có · một VPS · sổ giấy) có **đúng một dòng**: mất nó thì quán làm gì, ai bù, bù lúc nào | Mất mạng giữa buổi mà không ai có luật ⇒ quán dừng bán, đúng thứ `shop-facts.md` §6.11 cấm | L2 |
| **P1-03** | Chốt nguồn thời gian và **định nghĩa NGÀY BÁN** dùng cho mọi phép cộng tiền | P1-01 · **chặn: U-032** | Ba phép cộng tiền (bán · nợ · hoàn) mỗi phép trỏ đúng **một** định nghĩa ngày; lượt bán nhập bù có một câu luật | Doanh thu một ngày **đã đối soát** đổi về sau ⇒ phá đúng thứ `I-014` giữ, và ngưỡng 0đ hết nghĩa | L2 |
| **P1-04** | Bảng ba cột — nhóm **TIỀN**: `I-002` `I-005` `I-007` `I-012` `I-013` `I-014` `I-015` | P1-01 · P1-03 | Bảy mệnh đề, mỗi mệnh đề đủ ba ô, **không ô nào trống**; ô nào chỉ tới tầng 4–5 (§7) phải nói thẳng *"máy không ngăn được"* | Thu sai tiền mà không cơ chế nào chặn và không phép kiểm nào bắt | L2 |
| **P1-05** | Bảng ba cột — nhóm **VÒNG ĐỜI**: `I-001` `I-003` `I-004` `I-006` `I-016` `I-017` | P1-01 | Sáu mệnh đề đủ ba ô; riêng `I-001` phải nói được cả ca **ghép bàn** (một phiên, nhiều bàn — ADR-027) | Đơn hoặc bàn bị kẹt; hai phiên trên một bàn ⇒ một hoá đơn không ai thu | L2 |
| **P1-06** | Bảng ba cột — nhóm **MENU · GIÁ · VẾT**: `I-008` `I-009` `I-010` `I-011` `I-018` | P1-01 | Năm mệnh đề đủ ba ô; `I-011` phải giữ đúng lời chốt *máy chỉ **nhắc**, vẫn cho lưu* (U-018) — không được siết thành *máy chặn* | Đơn cũ đổi giá theo menu mới ⇒ doanh thu lịch sử tự đổi, không đối soát được | L2 |
| **P1-07** | Viết **yêu cầu hình dạng dữ liệu** bằng ngôn ngữ nghiệp vụ: sáu chỗ thiếu ở `architecture.md` §8 + nợ (§12.3) + vết (`I-012` `I-018`) + ai đang trực trạm nào (§4) | P1-04 · P1-05 · P1-06 · **BA-12** | Mỗi dòng của §8 có **đúng một** dòng yêu cầu dạng *phải ghi lại được X* / *phải không thể xảy ra Y*; bộ lọc tên bảng và tên cột trong file mới trả về **rỗng** | Pha 2 dựng lược đồ không cất được vết hoàn tiền và khoản nợ ⇒ đối soát 0đ không thực hiện được | L2 |
| **P1-08** | Chốt chiến lược realtime, đường kéo dự phòng, và **dấu hiệu phải xem lại** từng ràng buộc ẩn | P1-02 | Bốn ràng buộc ẩn (một instance · không hàng đợi · không cache · một VPS) mỗi cái có một **dấu hiệu đo được**, không phải một lời hứa | Mất SSE ⇒ trạm không nhận việc; thêm replica ⇒ trạm mất việc ngẫu nhiên, chỗ khó debug nhất dự án | L2 |
| **P1-09** | Viết lại `architecture.md` §3 — bảng quầy **bốn** con số, đơn vị **bấm** là mẻ, đơn vị **đếm** là bàn; và gỡ câu §11 đang giao việc này cho một task đã *Done* (F-024) | **BA-12** · **S-5** | §3 nêu đủ bốn con số và nói rõ con số thứ tư nhảy theo bậc mẻ; không còn câu nào giao việc cho `T-036` | Quầy không thấy bánh đang nằm chờ ⇒ khách chờ món không bao giờ tới, và không ai biết vì sao | L2 |
| **P1-10** | Dựng sổ rủi ro: năm rủi ro lớn nhất, kèm cơ chế chặn, ai chịu, và dấu hiệu nó **đang** xảy ra | P1-04 · P1-05 · P1-06 | Năm dòng, mỗi dòng chỉ tên đúng một cơ chế đã viết ở bước trước — không rủi ro nào được chặn bằng *"cẩn thận hơn"* | Rủi ro lớn không có người chặn, và lần đầu nó xảy ra là lần đầu ai đó nghĩ về nó | L1 |
| **P1-11** | **Diễn ba scenario nghiệm thu BA qua thiết kế** (`docs/product/0-ba/ban-hang/08-scenario.md` §8) và chốt cổng sang pha 2 | P1-02 → P1-10 | Mỗi **bước** của ba scenario trỏ được tới một cơ chế bảo vệ đã viết ra; chỗ không trỏ được ghi thành `F-XXX`/`U-XXX`, **không** tự thiết kế bù | Thiết kế đẹp mà không chạy được nghiệp vụ — đúng cách BA-11 tìm ra năm chỗ nói lệch nhau | L2 |
| **P1-12** | Rà chéo ranh giới pha và pointer | P1-11 | Bộ lọc *tên bảng · tên cột · endpoint · route · component* trên mọi file pha 1 trả về **rỗng**, và mỗi lần rỗng có in cả lệnh chưa lọc để chứng minh bộ lọc không tự rỗng (F-017); `./scripts/gate.sh` xanh | Pha 1 âm thầm quyết việc của pha 2, và không ai rà lại vì mọi cổng đều xanh | L1 |

**Chạy song song được:** P1-02 · P1-03 sau khi P1-01 xong · P1-04 · P1-05 · P1-06 độc lập với nhau
(ba nhóm không dùng chung mệnh đề nào) · P1-09 độc lập với cả dãy, nó chỉ chờ BA-12 và S-5. Hai
phiên chạy song song thì `work/scope.txt` là **một file, nhiều chủ**: phiên vào sau **thêm** khối
của mình, không ghi đè (F-010 · F-014).

**Mỗi bước tạo entry riêng ở `work/backlog.md` lúc nhận việc, không tạo trước cả mười hai.** Lý do
đo được: `scripts/brief.sh` cắt danh sách *Ready* ở sáu mục, và mười hai dòng đổ vào đó sẽ đẩy
bảy dòng ra ngoài tầm nhìn của mọi phiên mới — đúng cơ chế đã làm `U-011` và `BA-12` vô hình
(`work/findings.md` **F-012**).

**Mỗi bước có một file prompt viết theo `docs/prompt-guideline.md`** (sáu khối), viết lúc nhận việc.
Kế hoạch này không viết prompt hộ: một prompt viết trước khi biết bước trước đã ra kết quả gì sẽ
mang những câu *Constraints* đã chết, đúng loại lỗi mà `work/findings.md` **F-013** · **F-017** ghi.

---

## 7. Năm tầng bảo vệ — từ vựng bắt buộc của ba bước P1-04 → P1-06

Ba bước ấy viết ra ba mảnh của **một** bảng. Không có từ vựng chung thì ba mảnh không so được với
nhau, và cột giữa sẽ đầy những chữ như *"xử lý cẩn thận"*. Nên cột giữa chỉ được nhận đúng một
trong năm giá trị dưới đây, xếp **mạnh dần**:

| Tầng | Nghĩa | Đúng cả khi… |
|:--:|---|---|
| **1** | **Cơ sở dữ liệu giữ** — trạng thái sai không tồn tại được | hai người bấm cùng lúc, **và** ứng dụng có bug |
| **2** | **Một giao dịch giữ** — các thay đổi cùng sống hoặc cùng chết | mất điện giữa hai bước ghi |
| **3** | **Miền nghiệp vụ giữ** — một cửa ghi duy nhất, mọi lời gọi đi qua đó (ADR-011 · ADR-016) | lời gọi đến từ màn hình khác, nhưng **không** đúng khi có người sửa dữ liệu bằng tay |
| **4** | **Người + thủ tục giữ** — máy chỉ **nhắc** và để **vết** | không đúng khi người bỏ qua; giá trị duy nhất là cái vết |
| **5** | **Phép đối chiếu bắt sau khi hỏng** — không ngăn, chỉ phát hiện | phát hiện *muộn hơn* lúc hỏng; đây là đối soát cuối ngày |

Ba luật khi điền:

1. **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở.** `I-011` là ca mẫu:
   chủ quán chốt 2026-09-01 rằng máy **chỉ nhắc** rồi vẫn cho lưu ⇒ nó là **tầng 4**, và bài học
   đã ghi sẵn ở `docs/product/99-unknowns.md`: *một invariant hệ thống không giữ nổi thì không phải
   invariant*. Ghi nó là tầng 1 cho đẹp bảng là nói dối cả pha 2.
2. **Mỗi mệnh đề vẫn phải có một phép đối chiếu (cột 3), kể cả khi cột 2 đã là tầng 1.** Ràng buộc
   cũng bị người ta gỡ; phép đối chiếu là thứ phát hiện ra điều đó.
3. **Phép đối chiếu viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ.** *"Mọi phiên đã
   đóng mà tổng đã thu khác tổng hoá đơn — tập này phải rỗng"*. Pha 2 dịch nó thành một câu truy
   vấn; pha 1 không viết câu truy vấn (§3).

---

## 8. Bốn thứ đang chặn, và hai thứ đang sai

**Đang chặn — không bước nào được tự quyết thay** (`CLAUDE.md` §3.5):

| Mã | Câu hỏi | Chặn bước | Ai trả lời |
|---|---|---|---|
| **U-031** | với đơn **giao tận nơi**, ai bấm mốc *"đã ra bàn"* của từng việc trạm, lúc nào | P1-05 (`I-017`) · P1-07 · P1-09 | chủ quán |
| **U-032** | lượt bán ghi trên **sổ giấy** hôm mất điện, hôm sau mới nhập — doanh thu tính ngày nào | **P1-03** · P1-04 (`I-014`) | chủ quán |
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`shop-facts.md` §7.2 — chỗ **suy ra**, chưa hỏi) | P1-07 · P1-09 | chủ quán |
| **BA-12** | lát cắt sản xuất theo mẻ chưa có mục nào trong `docs/product/` | P1-07 · P1-09 | task ở `work/backlog.md`, không phải câu hỏi |

**Cách hỏi, không phải chuyện lễ nghi — nó đã hỏng một lần và tốn một ngày.** Câu hỏi `S-4` ngày
2026-08-31 hỏi *"bảng ở quầy hiện bàn 5 còn thiếu 3 hay đã đủ"* và chủ quán trả lời **"tôi không
hiểu"**; hỏi lại ngày 2026-09-01 về **cái quán** — *"từ lúc bánh tráng xong đến lúc nó xuống bàn,
có khi nào nó nằm chờ không"* — thì được trả lời ngay, kèm ba lý do không ai gợi ý. ⇒ **Hỏi về cái
quán thì được trả lời; hỏi về cái bảng trong máy thì không** (`shop-facts.md` §7.2). Pha 1 là pha
dễ vi phạm luật này nhất, vì mọi câu nó cần đều là câu về máy.

**Đang sai — hai chỗ, sửa trong bước tương ứng chứ không mở task riêng:**

- **F-023** — `docs/decisions.md` ADR-014 giao tên bảng · tên cột · khoá ngoại · API · route cho
  `architecture.md`, trong khi §8 của chính file ấy viết *"Điều tài liệu này cố ý KHÔNG làm"* đúng
  ba thứ đầu, và bản xuất khẩu thì khai cả bốn thứ *"chưa có nhà"*. ⇒ **P1-01**.
- **F-024** — `architecture.md` §11 giao việc viết lại §3 (bảng quầy bốn con số) cho `T-036`, mà
  `T-036` đã *Done* từ 2026-09-01 mà không giao nó. ⇒ **P1-09**.

---

## 9. Cổng chất lượng pha 1 — chỉ sang pha 2 khi đủ mười ô, mỗi ô có bằng chứng

Cổng này chép **hình dạng** của cổng BA (`docs/product/0-ba/ban-hang/08-scenario.md`), không chép
nội dung. Bài học của BA-11: một cổng tick **6/9 kèm lý do cho ba ô còn lại** thì trung thực và
dùng được; một cổng tick 9/9 bằng cảm giác thì không chặn được gì. Nên mỗi ô dưới đây kèm sẵn
**cách chứng minh**.

- [ ] Mười tám `I-0xx` **đều** có tầng bảo vệ và phép đối chiếu → mở `03-bao-ve-invariant.md`, đếm:
      không ô nào trống, và mỗi tầng là một trong năm giá trị §7.
- [ ] Mỗi mệnh đề chỉ được giữ ở **tầng 4 hoặc 5** đã nói thẳng ra điều đó → lọc chữ *"máy không
      ngăn được"*, đối chiếu với danh sách các mục thuộc hai tầng ấy.
- [ ] Định nghĩa **ngày bán** có đúng một chỗ, và ba phép cộng tiền trỏ về nó → `grep` ba luật
      (bán · nợ · hoàn), cả ba trỏ cùng một mục.
- [ ] Mỗi phụ thuộc ngoài có một đường suy giảm → đếm số phụ thuộc và số dòng suy giảm, hai số bằng nhau.
- [ ] Bốn ràng buộc kiến trúc ẩn có **dấu hiệu đo được** → không dòng nào chứa *"khi cần"* hoặc *"nếu chậm"*.
- [ ] Năm rủi ro có cơ chế chặn **đã tồn tại ở một mục pha 1** → mỗi dòng rủi ro trỏ được tới một mục cụ thể.
- [ ] Ba scenario BA đi hết được qua thiết kế → P1-11, mỗi bước trỏ được một cơ chế.
- [ ] Trục sản xuất theo mẻ đã có mục nghiệp vụ (**BA-12**) và §3 đã viết lại (**P1-09**).
- [ ] Không câu hỏi nghiệp vụ nào đang mở mà một bước pha 1 phải đoán thay → `./scripts/brief.sh`
      mục *OPEN UNKNOWNS*, đối chiếu với §8 của kế hoạch này.
- [ ] Không tên bảng · cột · endpoint · route · component nào lọt vào file pha 1 → **P1-12**, và
      dán cả lệnh **chưa lọc** cạnh lệnh đã lọc: một bộ lọc rỗng vì viết sai thì trông y hệt một
      bộ lọc rỗng vì không có lỗi (`work/findings.md` **F-017**).

**Một ô không tick được thì để trống kèm lý do và mã của chỗ đang chặn.** Không tick hộ, không xoá
ô, và không sang pha 2 với một ô trống chạm tiền.

---

## 10. Rủi ro lớn nhất của pha này

**Pha 1 viết ra một bảng ba cột trông đã đủ, trong khi cột giữa của mấy mệnh đề chạm tiền chỉ là
tầng 4 — người và thủ tục — mà không ai nói ra.** Pha 2 đọc bảng ấy, thấy mọi dòng đều "đã có bảo
vệ", và không dựng ràng buộc nào ở tầng 1 cho đúng những chỗ mất tiền.

**Cách chặn:** từ vựng năm tầng ở §7 là **bắt buộc**, và ô cổng chất lượng thứ hai ở §9 tồn tại
riêng để bắt đúng ca này.

---

## 11. Còn lại — pha 2

**Pha 2 · DB** nhận từ pha 1: mười tám mệnh đề kèm tầng giữ chúng, yêu cầu hình dạng dữ liệu bằng
ngôn ngữ nghiệp vụ, định nghĩa ngày bán, và **đề xuất 16 bảng** ở bản xuất khẩu §3.5 để **đối
chiếu** — không phải để thi hành. Pha 2 không mở lại nghiệp vụ và không mở lại tầng bảo vệ; gặp
chỗ pha 1 sai thì gửi ngược một dòng `F-XXX`, đúng luật hai sổ (`prompt-fullstack.md` §6.4).
