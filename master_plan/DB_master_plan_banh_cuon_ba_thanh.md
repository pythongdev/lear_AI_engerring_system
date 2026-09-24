# DB — kế hoạch pha 2 dự án Bánh cuốn Bà Thanh Cao Bằng

*Viết 2026-09-20 · T-080 · chủ repo yêu cầu trong phiên: **"chuyển sang pha 2, hãy làm master plan:
mục tiêu của pha 2 là gì, làm thế nào để kiểm tra, các bước thực hiện, mục tiêu từng bước, cách
kiểm tra từng bước"**. Quyết định về hình dạng của kế hoạch này: `docs/decisions.md` **ADR-049**;
hình dạng ấy chép của kế hoạch pha 1 (**ADR-033**).*

> **File này là KẾ HOẠCH, không sở hữu một sự thật nào.** Nó nói *pha 2 nợ những gì và chạy theo
> thứ tự nào*. Nó **không** giữ lược đồ, không giữ tên bảng, không giữ dữ kiện quán, không giữ
> invariant. Chỗ nào cần một con số hay một luật, đọc ở owner của nó (`CLAUDE.md` §2) — ở đây cố ý
> không có bản chép thứ hai (`work/findings.md` **F-001**).
>
> **Trạng thái của từng bước không nằm ở đây.** Owner của *Tasks* là `work/backlog.md`. Bảng §6
> dưới đây có sáu cột và **không có cột Trạng thái**, đúng như bảng §6 của kế hoạch pha 1.
>
> **Pha 2 là L3 ở cấp giai đoạn** — nó quyết định chỗ cất của mọi đồng tiền hệ thống này đụng vào.
> Nhưng **không bước nào trong bảng §6 là L3**: mỗi bước là một L1/L2 làm xong trong một phiên,
> đúng `CLAUDE.md` §3 (L3 ⇒ chia thành nhiều task L1/L2).
>
> **Cổng pha 1 đã đủ mười ô ngày 2026-09-20** (`docs/product/1-system-design/07-cong-chat-luong-pha-1.md`
> §7), và chủ repo chốt chuyển pha **cùng ngày**. Mười ô xanh **không** có nghĩa pha 1 hết chỗ hụt
> — §4 dưới đây kể tên bốn mã nợ mà pha 2 phải đọc **trước** khi tin bất kỳ ô nào.

---

## 1. Bốn tài liệu nói về "dữ liệu sống ở đâu" — và không cái nào là owner

Đây là chỗ dễ đọc nhầm nhất của cả pha, cùng hình với §1 của kế hoạch pha 1. Bốn tài liệu dưới đây
đều đã nói tới hình dạng dữ liệu, và tính tới hôm nay **owner của lược đồ vẫn chưa tồn tại**
(`CLAUDE.md` §2, hàng *Schema* — *chưa có owner*).

| Tài liệu | Nó là gì | Được đọc như |
|---|---|---|
| [`prompt-fullstack.md`](prompt-fullstack.md) §3.4–§3.7 | **bản xuất khẩu** viết 2026-08-31, trước phần lớn quyết định của chủ quán | **đề xuất để đối chiếu**, không phải lược đồ đã chốt (**ADR-035** luật 3) |
| [`../docs/product/1-system-design/architecture.md`](../docs/product/1-system-design/architecture.md) §12.3 | mục **duy nhất** trong repo đã đi tới mức *cất cái gì* và *ràng buộc nào phải do database giữ*, cho riêng phần **nợ** | **đề xuất gửi sang pha 2**, tự khai như thế trong thân mục |
| [`../docs/product/1-system-design/04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) | **owner** của *câu yêu cầu* — `YC-01`…`YC-20` | **đề bài của pha 2**: mỗi dòng là một câu pha 2 phải trả lời được bằng *có*/*không* sau khi dựng xong lược đồ |
| **file này** | kế hoạch: thứ tự · mức · đầu ra kiểm chứng được | **không sở hữu gì** |

**Hai tài liệu đầu là hai cái bẫy khác nhau.** Bẫy của §3.4–§3.7 là nó **rẻ và trông đúng**: nó có
sẵn một lược đồ chạy được, và thi công nó là xong việc trong một buổi —
[`architecture.md`](../docs/product/1-system-design/architecture.md) §8 đã đo được **tám** chỗ nó
chưa có chỗ cất, trong đó có **vết hoàn tiền** và **khoản nợ**, thiếu hai thứ ấy thì đối soát
ngưỡng lệch 0đ không thực hiện được (`master_plan/shop-facts.md` §6.10). Bẫy của §12.3 ngược lại:
nó **đúng** nhưng chỉ phủ một mảnh, và chép nó về một file pha 2 rồi sửa dần là dựng bản thứ hai
của một thứ đã đứng được (**F-001**) — pha 2 **thay thế** nó, và khi thay thế xong thì §12.3 nhận
một dòng trỏ sang chỗ mới, trong cùng thay đổi.

---

## 2. Câu hỏi pha 2 phải chốt xong — một dòng

> **Dữ liệu sống ở đâu.**

Đó là câu của pha 2 trong bảng sáu pha ([`prompt-fullstack.md`](prompt-fullstack.md) §7). Pha 0 trả
lời *quán làm gì, ai thao tác, tiền đi đường nào*; pha 1 trả lời *cái gì bảo vệ cái gì*; pha 3 sẽ
trả lời *ai được làm gì, giá tính ở đâu*. Pha 2 đứng giữa và chỉ có một việc: **mỗi câu *phải ghi
lại được X* và *phải không thể xảy ra Y* của pha 1 phải có một chỗ cất thật, và mỗi tầng-1 của pha 1
phải thành một ràng buộc thật mà database từ chối được.**

Năm đầu ra bắt buộc mà bảng sáu pha đòi ở pha 2, cộng một thứ thứ sáu mà **ADR-039** thêm vào:

| # | Đầu ra | Bước nào sinh ra nó |
|:--:|---|---|
| 1 | **Sơ đồ quan hệ** | `P2-04` → `P2-08` (năm lát), gom lại ở `P2-13` |
| 2 | **Thứ tự migration** | `P2-09` |
| 3 | **Dữ liệu mồi** — menu thật (`shop-facts.md` §4.2–§4.5) | `P2-10` |
| 4 | **Quy tắc dữ liệu** | `P2-03` |
| 5 | **Query đối chiếu cho từng bất biến** | `P2-11` |
| 6 | **Quy ước code**: stack, cấu trúc thư mục, đặt tên, khung test (**ADR-039**) | `P2-12` |

**Cột thứ ba cố ý KHÔNG phải cột *"hôm nay có chưa"***, dù kế hoạch pha 1 §2 dùng cột ấy. Lý do đo
được: cột ấy ở pha 1 đã hết đúng và không ai cập nhật — `work/findings.md` **F-033**. Một cột nói
*bước nào sinh ra nó* thì không bao giờ lệch, vì nó nói về **kế hoạch** (thứ file này sở hữu) chứ
không nói về **trạng thái** (thứ `work/backlog.md` sở hữu).

---

## 3. Ranh giới của pha 2 — ba câu không được xuất hiện trong đầu ra

Ranh giới cứng của bảng sáu pha: *pha 0–1 **không** nhắc tên bảng; **pha 2 không nhắc endpoint**;
pha 3 không nhắc component; pha 4 không đổi hợp đồng API.* Áp vào pha 2:

| Không được viết ra ở pha 2 | Nó là đầu ra của | Pha 2 được viết gì thay vào |
|---|---|---|
| endpoint, tên hàm, chữ ký API, quyền theo vai của một đường gọi | pha 3 · BE | *"đường ghi tới ô này phải là **một**, và lược đồ không mở đường thứ hai"* |
| route, component, cái gì hiện ở màn nào | pha 4 · FE | *"con số này phải **đọc ra được** bằng một phép cộng từ chi tiết"* |
| compose, backup theo lịch, cách phục hồi khi hỏng máy | pha 5 · Deploy | *"mỗi migration phải có đường lùi chạy thật được"* (`P2-09`) |

**Pha 2 cũng không mở lại hai thứ của pha trước:**

- **Không mở lại nghiệp vụ.** Gặp chỗ nghiệp vụ chưa rõ ⇒ hỏi chủ quán, hoặc ghi thành `U-XXX`
  (`CLAUDE.md` §3.5 · §4). Không có mức L0 cho luật này.
- **Không mở lại tầng bảo vệ.** Tầng giữ từng `I-0xx` là của pha 1
  ([`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md), **ADR-035**).
  Pha 2 **thi hành** tầng ấy; thấy một hàng sai thì gửi ngược **một dòng `F-XXX`**, không tự hạ
  tầng cho dễ dựng (`prompt-fullstack.md` §6.4 — hai sổ, không bao giờ trộn).

**Mảng admin không nằm trong mười bốn bước dưới đây.** Lược đồ của ba mảng *nguyên liệu · con người
· tài chính* chạy theo **lane admin** (`ADM-01`…`ADM-53`, `work/backlog_AD.md`, **ADR-036**), và
phần lớn lane ấy đang chờ lời chủ quán. Hai chỗ **giao nhau** thì phải hẹn trước chứ không ai lấn:
**người và chỗ đứng theo thời điểm** (`YC-15`…`YC-17` — `P2-08` dựng, lane admin dùng lại) và
**quy ước dữ liệu** (`P2-03` — áp cho cả hai lane). Đây là **cách đọc của phiên viết kế hoạch**,
không phải lời chủ repo (§8, `CLAUDE.md` §7.2).

---

## 4. Pha 2 nhận gì từ pha 1 — bốn chỗ đọc trước khi viết dòng đầu tiên

**4.1 `quality/invariants.md` giữ mệnh đề `I-001`…`I-021`, và
[`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md) §1–§4 giữ
**tầng** và **phép đối chiếu** của từng mệnh đề.** Đây là đầu vào đắt nhất pha 1 để lại. Đọc **danh
sách mã**, đừng đọc một con số đếm — một phép đếm cứng trong tài liệu đã tự hết đúng đúng một lần
(`work/findings.md` **F-026** · **F-018**). Mỗi hàng *tầng 1* ở đó là một **yêu cầu gửi pha 2**:
pha 1 viết *"phải do cơ sở dữ liệu giữ"*, không viết *"đã do"* — dựng cái *phải do* ấy thành ràng
buộc thật là việc của §6 dưới đây.

**4.2 [`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) là ĐỀ BÀI, và
nó có sẵn phép chấm.** §7 của chính mục ấy viết cách dùng: *dựng lược đồ xong thì đi ngược từng
dòng `YC-XX`, mỗi dòng hỏi hai câu — **đọc ra được không** và **dựng được trạng thái sai không**.
Dòng nào không trả lời được là một chỗ lược đồ còn thiếu, **không phải** một dòng viết chưa rõ.*
Bảng §1 của mục ấy còn có một luật một-đối-một với
[`architecture.md`](../docs/product/1-system-design/architecture.md) §8: gặp chỗ thiếu tiếp theo
thì thêm vào **cả hai** trong cùng thay đổi.

**4.3 [`02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md) giữ
định nghĩa MỘT NGÀY BÁN và mốc tính tiền của từng việc chạm tiền.** §5 của mục ấy giao thẳng cho
pha 2 đúng một câu: *cất mốc **thế nào**, kiểu gì — mục này cố ý không nói*. Ba yêu cầu đi kèm là
`YC-18` · `YC-19` · `YC-20`.

**4.4 `master_plan/shop-facts.md` giữ mọi dữ kiện quán** (**ADR-001**) — giá, thành phần suất, phụ
thu, bàn, trạm, hai mươi hai quy tắc nghiệp vụ. `P2-10` (dữ liệu mồi) **tra** ở đó, **không chép**
một bảng giá thứ hai vào bất kỳ file pha 2 nào.

### Bốn mã nợ của pha 1, và hai chỗ *suy ra* — đọc trước khi tin một ô cổng nào

Câu cuối §7 của [`07-cong-chat-luong-pha-1.md`](../docs/product/1-system-design/07-cong-chat-luong-pha-1.md)
nói thẳng: mười ô xanh **không** nghĩa là pha 1 hết chỗ hụt. Bốn mã dưới đây là chỗ hụt đã có tên,
cộng hai chỗ *suy ra* chưa ai hỏi chủ quán. Chi tiết ở §8.

| Mã | Nó thiếu cái gì | Chạm bước nào của pha 2 |
|---|---|---|
| **F-034** | cơ chế chặn *mất hẳn bản ghi đã ghi* chưa có nhà; ba đường ra đã ghi sẵn, chọn là quyền chủ repo | `P2-09` |
| **F-036** | phép đối chiếu của một mệnh đề hẹp hơn chính mệnh đề ấy — hai vế không có tầng | `P2-05` · `P2-07` |
| **F-037** | khoản **trả trước** có mốc tính tiền nhưng không có dòng nào trong bảng đối soát | `P2-06` · `P2-11` |
| **F-038** | *thiếu một trường bắt buộc thì đơn không tạo được* là luật pha 0 mà pha 1 không có mệnh đề, không có tầng, không có dòng yêu cầu | `P2-04` |
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** — `04-yeu-cau-du-lieu.md` §6 dặn **để trống, đừng điền** | `P2-07` |
| **S-6** | với đơn giao tận nơi, quầy bấm mốc *"đã ra bàn"* **lúc nào** | `P2-07` |

---

## 5. Đầu ra pha 2 nằm ở đâu — bản đồ file, và ba luật ghi

Đầu ra của pha 2 vào một thư mục **mới**, `docs/product/2-db/`, một chủ đề một file — cùng hình với
`docs/product/1-system-design/`. Thư mục ấy **chưa tồn tại và cố ý chưa tồn tại**
(`docs/product/00-index.md` → *Luật ghi*): nó ra đời cùng **dòng nội dung đầu tiên** của pha, tức ở
`P2-03`, không sớm hơn.

```text
docs/product/2-db/
  01-quy-uoc-du-lieu.md        P2-03 — từ vựng bắt buộc: tiền · mốc · khoá · đặt tên · vết
  02-luoc-do-ban-hang.md       P2-04 — bàn, phiên, đơn, dòng đơn, tuỳ chọn, suất đem về
  03-luoc-do-menu-gia.md       P2-05 — danh mục, suất bán, tuỳ chọn, ảnh chụp giá lúc đặt
  04-luoc-do-duong-tien.md     P2-06 — thu nhiều phương thức, nợ, hoàn tiền, tiền đầu két
  05-luoc-do-san-xuat.md       P2-07 — việc trạm, mẻ, phần chia về từng bàn
  06-luoc-do-nguoi-va-vet.md   P2-08 — người, chỗ đứng theo thời điểm, vết cập nhật, nhập bù
  07-thu-tu-migration.md       P2-09 — thứ tự, đường lùi, thứ tự dựng lại từ số không
  08-du-lieu-moi.md            P2-10 — menu thật, bàn, trạm, người
  09-doi-chieu-bat-bien.md     P2-11 — mỗi phép đối chiếu của pha 1 thành một câu truy vấn
  10-quy-uoc-code.md           P2-12 — stack, cấu trúc thư mục, đặt tên, khung test (ADR-039)
  11-cong-chat-luong-pha-2.md  P2-13 — diễn ba scenario qua lược đồ, và cổng sang pha 3
```

*(Tên file ở trên là **đề xuất của kế hoạch**, không phải một cam kết: bước nào thấy tên của mình
sai thì đặt lại và sửa dòng này trong cùng thay đổi.)*

Ba luật cho bản đồ này, không cái nào là hình thức:

- **File sinh ra cùng dòng nội dung đầu tiên của nó, không sớm hơn.** Một file rỗng tên sẵn là tài
  liệu nghi lễ (`CLAUDE.md` §3.8).
- **Thêm một file thì thêm một dòng vào `docs/product/00-index.md` trong cùng thay đổi**, và lượt
  đầu tiên (`P2-03`) còn phải đổi hàng *Pha 2* của bảng *Sáu pha* ở đó từ **chưa mở** sang
  **đang mở**. Một owner mà mục lục không kể là owner không ai tìm ra.
- **Mâu thuẫn với một mục pha 1 ⇒ gửi ngược một dòng `F-XXX`, không viết bản thứ hai.** Pha 2 không
  sở hữu tầng bảo vệ và không sở hữu luật nghiệp vụ (§3).

### Ba hàng của `CLAUDE.md` §2 đổi ở ba bước khác nhau

**ADR-035** luật 2 nói: hàng *chưa có owner* đổi thành tên file thật **trong cùng thay đổi mở thư
mục của pha ấy**. Ở đây thư mục mở ở `P2-03` trong khi tên bảng đầu tiên chỉ xuất hiện ở `P2-04`,
nên kế hoạch này đọc luật ấy thành ba lượt — **cách đọc của phiên viết, chờ chủ repo xác nhận**
(§8):

| Hàng §2 | Đổi ở bước | Đổi thành |
|---|---|---|
| *(hàng mới)* **Quy ước dữ liệu** | `P2-03` | file quy ước dữ liệu của `docs/product/2-db/` |
| **Schema**: tên bảng, tên cột, khoá ngoại | `P2-04` | file lược đồ đầu tiên; các lát sau **thêm** dòng, không ghi đè |
| **Quy ước code**: stack, thư mục, đặt tên, khung test | `P2-12` | file quy ước code |

**Sổ task và lane prompt của pha 2.** Mô tả dài của mười bốn bước vào một sổ riêng của pha 2 —
**`backlog_DB.md`** cạnh `work/backlog.md`, đúng hai điều kiện của **ADR-036** luật 1 (một dãy mã
riêng `P2-XX`, một chuỗi việc đọc liền nhau) — và sổ ấy cần **một hàng ở `CLAUDE.md` §2** trong cùng thay đổi dựng nó. Trạng thái thì
vẫn chỉ ở `work/backlog.md` (**ADR-002**), và **chỉ bước nào nhận được ngay mới có dòng ở *Ready***:
`scripts/brief.sh` cắt *Ready* ở sáu mục, nên mười bốn dòng đổ vào đó đẩy tám dòng ra khỏi tầm nhìn
của mọi phiên mới (**F-012**).

Prompt của mỗi bước vào lane **`prompt/DB/`**, một file một bước, theo `docs/prompt-guideline.md`.
**Lane ấy phải được thêm vào danh sách Gate 1b chấm** (`scripts/check-links.sh`) trong cùng thay đổi
tạo ra nó — đúng việc P1-01 đã làm cho `prompt/SD/` và T-058 cho `prompt/AD/`; một lane prompt
không nằm trong danh sách ấy là lane pointer **không cổng nào đọc** (**F-007**). Và **viết được
prompt của một bước khi mọi bước ở cột *Cần xong trước* của nó đã `Done`** (**ADR-008**, T-051):
sớm hơn thì *Constraints* và *Verify* là những câu đoán, đúng loại lỗi **F-013** · **F-017** ghi.

---

## 6. Mười bốn bước — master task pha 2

Sáu cột. Không có cột *Trạng thái*: nó ở `work/backlog.md`. Cột **Mức** thì ở đây, vì nó quyết định
ceremony của bước và phải đọc được trước khi ai nhận việc. Cột **Đầu ra kiểm chứng được** là *cách
kiểm tra* của bước ấy — một bước không nói nổi biên nhận của mình bằng một lệnh hoặc một phép đối
chiếu đọc được là một bước chẻ sai ([`prompt-fullstack.md`](prompt-fullstack.md) §5.6).

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|:--:|
| **P2-01** | Chốt **ranh giới và từ vựng của cả pha**: năm tầng của pha 1 dịch sang pha 2 thành cái gì (§7), và cái gì pha 2 **không** được viết (§3) — một ADR, không một dòng lược đồ nào | — | Một ADR mới; mọi bước sau trích được từ nó câu trả lời cho *"hàng tầng-1 này phải thành cái gì"*; không file nào trong `docs/product/2-db/` tồn tại sau lượt này | Mười ba bước sau mỗi bước tự định nghĩa lại chữ *ràng buộc*, và cổng §9 không chấm được gì | L2 |
| **P2-02** | **Gate 1d học vùng pha 2**: `scripts/check-phase-boundary.sh` hôm nay chỉ đọc `docs/product/1-system-design/` và bộ mẫu SQL của nó sẽ đỏ với đúng thứ pha 2 phải viết | P2-01 | Gate đỏ khi một file pha 2 mang **endpoint · route · component**, xanh khi nó mang SQL; ca hồi quy mới trong `scripts/check-phase-boundary.test.sh`, và **cả bộ ca cũ vẫn xanh** | Pha 2 viết endpoint suốt mười một file mà không cổng nào đỏ — đúng hình `F-041`, lần này không có ai đứng đọc | L2 |
| **P2-03** | **Quy ước dữ liệu** — tiền cất bằng gì · mốc thời gian cất bằng gì và quy về múi giờ nào · khoá · đặt tên · trạng thái · **không xoá cứng**. Lượt này **mở `docs/product/2-db/`** và đổi hàng §2 tương ứng (§5) | P2-01 | Mỗi quy ước một dòng, mỗi dòng một **hậu quả nếu làm khác**; `docs/product/00-index.md` hàng *Pha 2* sang **đang mở**; `CLAUDE.md` §2 có hàng chủ | Năm lát lược đồ cất tiền và mốc theo năm kiểu, và phép cộng tiền cuối ngày không cộng nổi | L2 |
| **P2-04** | **Lược đồ lát bán hàng lõi**: bàn · phiên bàn · đơn · dòng đơn · tuỳ chọn đã chọn · suất *đem về*. Mang `I-001` `I-002` `I-003` `I-006` `I-007` `I-016` `I-017` và `YC-05` | P2-03 | Mỗi mệnh đề tầng 1 trong danh sách có một ràng buộc thật: **cố tình dựng trạng thái sai ⇒ database từ chối**, dán output; `YC-05` trả lời được cả hai câu | Hai phiên chưa thanh toán trên một bàn ⇒ một hoá đơn không ai thu (`RR` của sổ rủi ro) | L2 |
| **P2-05** | **Lược đồ menu · giá · ảnh chụp giá lúc đặt**: `I-009` `I-010` `I-011` `I-013`, cộng công thức giá ở `shop-facts.md` §4.1–§4.6 | P2-03 | Đổi giá menu **sau khi** một đơn đã đặt ⇒ đọc lại đơn cũ, giá không đổi (chạy thật, dán output); tổ hợp cấm **bị từ chối**, không bị sửa hộ | Doanh thu lịch sử tự đổi theo menu ⇒ không đối soát được ngày đã chốt | L2 |
| **P2-06** | **Lược đồ đường tiền**: thu chia nhiều phương thức · **nợ** · **hoàn tiền** · tiền đầu két. Mang `I-005` `I-012` `I-014` `I-015` `I-021` và `YC-01` `YC-02` `YC-09` `YC-10` `YC-11` | P2-03 · P2-04 | Năm thứ của một lần hoàn (`YC-01`) và sáu thứ của một khoản nợ (`YC-02`) **đọc lại được sau nhiều ngày**; một lần trả nợ **không** tạo ra một khoản bán mới; §12.3 của `architecture.md` nhận một dòng trỏ sang chỗ mới | Tính doanh thu hai lần cho cùng một bữa ăn, hoặc két lệch mà không truy được về một thao tác | L2 |
| **P2-07** | **Lược đồ sản xuất theo mẻ**: việc của từng trạm · một lần bấm = một mẻ · phần chia về từng bàn · phần đã làm xong của đơn huỷ đổi chủ. Mang `I-004` `I-019` `I-020` và `YC-06` `YC-07` | P2-03 · P2-04 · **S-5 · S-6 để trống** | Tổng nhu cầu một thành phần **tách ngược về được** từng bàn, khớp cả hai chiều; số đã phục vụ của một bàn **không vượt** số bàn ấy đã gọi; đơn vị **bấm** của mốc *đã bưng ra bàn* vẫn **trống** | Bánh cộng cho bàn này, thiếu cho bàn kia, đúng lúc đông khách | L2 |
| **P2-08** | **Lược đồ người · chỗ đứng theo thời điểm · vết**: `YC-03` `YC-04` `YC-08` `YC-12`…`YC-17`, mang `I-012` `I-018` | P2-03 · P2-06 | Đọc ra được **ai đang trực trạm nào tại một thời điểm trong quá khứ**; một lần sửa dựng lại được **bản trước, bản sau, lý do, người sửa**; lượt bán nhập bù mang **hai mốc** đọc riêng được | Một chỗ lệch trong đối soát không quy được về một thao tác có tên người ⇒ ngưỡng 0đ hết nghĩa | L2 |
| **P2-09** | **Thứ tự migration**: mỗi bước có đường đi và **đường lùi**, và cả dãy dựng lại được từ số không. Đọc `work/findings.md` **F-034** trước — chọn nhà cho *mất hẳn bản ghi* là quyết định của **chủ repo**, bước này **không chọn hộ** | P2-04 → P2-08 | Chạy xuôi cả dãy trên một cơ sở dữ liệu rỗng ⇒ xanh; chạy **lùi** một bước rồi xuôi lại ⇒ xanh; dán cả hai output. `F-034` hoặc đã có nhà, hoặc có một dòng nói rõ lược đồ đứng thế nào khi nó còn mở | Một lần đổi lược đồ giữa chừng không lùi được ⇒ dữ liệu bán hàng thật kẹt ở trạng thái nửa vời | L2 |
| **P2-10** | **Dữ liệu mồi**: menu thật, bàn, trạm, người — **tra** `shop-facts.md` §1 · §3 · §4.2–§4.5, không chép bảng giá thứ hai | P2-05 · P2-04 | Dựng dữ liệu mồi rồi tính lại giá **mười một ca giá bắt buộc** (`shop-facts.md` §4.8) ⇒ khớp từng đồng; sai một ca là sai dữ liệu mồi hoặc sai lược đồ giá, **không** sửa ca | Mọi test sau đó chạy trên một cái menu không phải menu của quán | L1 |
| **P2-11** | **Bộ query đối chiếu**: mỗi phép đối chiếu của `03-bao-ve-invariant.md` thành **đúng một** câu truy vấn, gom thành **một** lệnh chạy sau khi đóng quán | P2-04 → P2-08 · P2-10 | `comm -3` giữa danh sách mã ở `quality/invariants.md` và danh sách mã của bộ truy vấn ⇒ **rỗng**; cả bộ chạy trên dữ liệu mồi ⇒ **0 dòng**; cài một lỗi thật vào dữ liệu ⇒ đúng câu truy vấn của nó ra **khác 0** (§7 luật 3) | Bất biến chỉ tồn tại trên giấy: không ai biết một ràng buộc đã bị gỡ | L2 |
| **P2-12** | **Quy ước code** (**ADR-039**): đối chiếu lại stack đề xuất ở §3.4, cấu trúc thư mục, đặt tên, khung test | P2-03 | Một file quy ước, mỗi mục một câu **kiểm được bằng lệnh**; `CLAUDE.md` §2 hàng *Quy ước code* hết nói *chưa có owner* | Phiên đầu tiên viết code tự bịa quy ước, và cái bịa đó thành fact vì không có chủ để đối chiếu | L2 |
| **P2-13** | **Cổng chất lượng pha 2**: diễn ba scenario nghiệm thu (`08-scenario.md` §8) **qua lược đồ**, chấm ngược từng dòng `YC-01`…`YC-20`, và ký các ô §9 | P2-03 → P2-12 | Mỗi **bước** của ba scenario ghi/đọc được bằng dữ liệu thật; mỗi dòng `YC` trả lời được **hai** câu; chỗ không trả lời được ghi thành `F-XXX`/`U-XXX`, **không** tự thiết kế bù | Lược đồ đẹp mà không chạy nổi một buổi bán — đúng cách `BA-11` và `P1-11` tìm ra chỗ hụt | L2 |
| **P2-14** | **Rà chéo ranh giới pha và pointer**: không endpoint · route · component nào lọt vào file pha 2; mọi pointer từ pha 1 sang pha 2 còn đúng | P2-13 | Bộ lọc chạy trên **mọi** file pha 2, và **in cả lệnh chưa lọc cạnh lệnh đã lọc** — một bộ lọc rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (**F-017**) | Pha 3 mở ra và đọc bốn dòng hợp đồng API do pha 2 viết hộ như đầu vào đã chốt — đúng `F-040` · `F-041`, lần thứ hai | L1 |

**Chạy song song được:** `P2-04` · `P2-05` · `P2-06` · `P2-07` · `P2-08` sau khi `P2-03` xong —
năm lát không dùng chung một mệnh đề nào, nhưng **chúng dùng chung một sơ đồ quan hệ**, nên lát vào
sau **thêm** file của mình và **thêm** dòng vào mục lục, không ghi đè lát trước (**F-010** ·
**F-014**). `P2-02` và `P2-12` độc lập với cả dãy. Hai phiên chạy song song thì `work/scope.txt` là
**một file, nhiều chủ**: phiên vào sau thêm khối của mình.

**Mười bốn dòng, trong khi [`prompt-fullstack.md`](prompt-fullstack.md) §8 khuyên tối đa mười hai.**
Ghi ra chứ không giấu: hai dòng vượt là `P2-02` (cổng) và `P2-12` (quy ước code) — cả hai không
phải *lát việc*, và gộp chúng vào một bước khác là dựng lại đúng cái bệnh §5.6 gọi tên (chữ *"và"*
nối hai danh từ khác nhau). Pha 1 cũng chạy mười bốn bước.

---

## 7. Năm tầng của pha 1 dịch sang pha 2 — owner là **ADR-050**, mục này chỉ trỏ

Pha 1 điền cột giữa của bảng ba cột bằng **đúng một** trong năm tầng (kế hoạch pha 1 §7). Pha 2 đọc
cột ấy và phải biết nó **nợ cái gì** cho từng tầng, chấm **bằng gì**, và cái gì **không** phải biên
nhận. Ba câu ấy nay có **một** nhà:

> **`docs/decisions.md` → ADR-050** — bảng năm tầng bốn cột · **ba luật khi dịch** · **ba câu pha 2
> không được viết ra** và viết gì thay vào.

**Bản đầu của mục này (2026-09-20, T-080) GIỮ bảng ấy trong thân mục.** Ngày **2026-09-22**, bước
`P2-01` chốt **ADR-050** và bảng có owner thật — nên mục này bỏ bản chép của mình ngay trong cùng
thay đổi, chứ không để hai bản trôi khỏi nhau (`work/findings.md` **F-001**, `CLAUDE.md` §7.2).
Kế hoạch **không sở hữu sự thật nào**; đó là câu chính nó viết ở banner đầu file.

⚠️ **Mọi chỗ trong repo viết *"kế hoạch §7"* vẫn đọc được** — chúng tới đây, và đây trỏ tiếp sang
ADR-050. Đừng sửa những pointer ấy thành *"ADR-050"* hàng loạt: một lớp trỏ là đủ, và sửa hàng loạt
là mở ra đúng loại việc rà mà **F-007** đã đo giá.

---

## 8. Chỗ đang chặn, và chỗ kế hoạch này SUY RA

**Đang chặn — không bước nào được tự quyết thay** (`CLAUDE.md` §3.5). Đọc danh sách sống ở
`./scripts/brief.sh`; bảng này chỉ nói **cái gì chặn bước nào**, đo ngày **2026-09-20**:

| Mã | Câu hỏi / chỗ thiếu | Chặn bước | Ai gỡ |
|---|---|---|---|
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`master_plan/shop-facts.md` §7.2 — chỗ *suy ra*, chưa hỏi) | `P2-07` — ô ấy **để trống**, đừng điền | chủ quán |
| **S-6** | với đơn giao tận nơi, quầy bấm mốc *"đã ra bàn"* **lúc nào** | `P2-07` | chủ quán |
| **F-034** | *mất hẳn bản ghi đã ghi* chưa có cơ chế nào; ba đường ra ghi sẵn trong finding | `P2-09` | **chủ repo** |
| **F-036** | hai vế thiếu tầng — việc cấp đơn của một trạm, và vế *ngừng bán* | `P2-05` · `P2-07` | phiên nhận F-036 (pha 1) |
| **F-037** | khoản **trả trước** không có dòng trong bảng đối soát | `P2-06` · `P2-11` | phiên nhận F-037 (pha 1) |
| **F-038** | *thiếu một trường bắt buộc thì đơn không tạo được* chưa có mệnh đề và chưa có tầng | `P2-04` | phiên nhận F-038 (pha 1) |
| **U-054** | hai con số *tổng* của vế nguyên liệu cộng dồn **từ mốc nào** | lane **admin**, không chặn bước nào ở §6 | chủ quán |

**Một bước bị chặn vẫn chạy được phần không phụ thuộc câu trả lời**, và ghi chỗ trống ra kèm mã —
đúng cách `P1-04` xử `I-014`. Cái **không** được làm là lấp chỗ trống bằng một mặc định rồi chạy
tiếp: một lược đồ tự chọn *"bấm theo bàn"* là một lược đồ đã thay chủ quán trả lời một câu chưa ai
hỏi, và cái sai ấy chỉ lộ ra lúc quán dùng thật
([`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) §6).

**Ba chỗ kế hoạch này SUY RA, không phải lời chủ repo** (`CLAUDE.md` §7.2 — *cái được bảo ≠ cái
mình suy*). Chủ repo mới nói đúng một câu: *chuyển sang pha 2, làm master plan*. Ba chỗ dưới đây là
cách phiên viết hiểu câu ấy, và cả ba **chờ xác nhận**:

- **Mảng admin không nằm trong mười bốn bước** (§3). Lý lẽ: lane admin có sổ riêng và phần lớn đang
  chờ lời chủ quán. Nếu chủ repo muốn lược đồ admin đi cùng pha 2, bảng §6 dài thêm chứ không phải
  bước nào đổi nghĩa.
- **Ba hàng `CLAUDE.md` §2 đổi ở ba bước khác nhau** (§5), thay vì đổi hết ở lượt mở thư mục.
- **Số bước là mười bốn** và cách chẻ năm lát lược đồ theo **nhóm mệnh đề** (tiền · menu · lõi bán
  hàng · sản xuất · người và vết) chứ không theo nhóm bảng. Lý lẽ: chẻ theo mệnh đề thì mỗi bước có
  sẵn phép chấm; chẻ theo bảng thì biên nhận là *"đã tạo xong bảng"*, thứ không chứng minh gì.

---

## 9. Cổng chất lượng pha 2 — chỉ sang pha 3 khi đủ các ô, mỗi ô có bằng chứng

Cổng này chép **hình dạng** của cổng pha 1 (kế hoạch pha 1 §9), không chép nội dung. Bài học giữ
nguyên: một cổng tick kèm lý do cho ô còn trống thì trung thực và dùng được; một cổng tick trơn
bằng cảm giác thì không chặn được gì. Nên mỗi ô dưới đây kèm sẵn **cách chứng minh**.

> **Các ô dưới đây là LỜI của cổng; chỗ nó được KÝ thì không ở file này** — chỗ ký là file cổng chất
> lượng pha 2 do `P2-13` sinh ra, đúng cách cổng pha 1 được ký ở
> [`07-cong-chat-luong-pha-1.md`](../docs/product/1-system-design/07-cong-chat-luong-pha-1.md) §7
> chứ không ở kế hoạch. Những hộp `- [ ]` ở đây vì thế **không** phải một phép đếm và **không được
> tick**: kế hoạch này không sở hữu sự thật nào, và hai bản tick sẽ trôi khỏi nhau (**F-001** ·
> **F-033**). **Đếm ở danh sách, đừng đếm ở tiêu đề** (**F-018**).

- [ ] **Mọi mã `I-0xx` của `quality/invariants.md` có đúng một câu truy vấn đối chiếu** → `comm -3`
      giữa hai danh sách **mã** (không đếm số lượng — **F-026**) ⇒ rỗng; cả bộ chạy trên dữ liệu mồi
      ⇒ **0 dòng**.
- [ ] **Mỗi câu truy vấn đã được chứng minh là biết kêu** → cài một lỗi thật vào dữ liệu ⇒ đúng câu
      của nó ra khác 0 (§7 luật 3). Một bộ chưa bao giờ đỏ là một bộ chưa được chấm.
- [ ] **Mọi hàng *tầng 1* của [`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md)
      có một ràng buộc thật mang nó** → với từng hàng, dán nguyên lời từ chối của database khi cố
      dựng trạng thái sai. Hàng nào dựng không nổi ⇒ **một `F-XXX` gửi ngược**, không hạ tầng.
- [ ] **Mọi dòng `YC-01`…`YC-20` được chấm bằng hai câu** — *đọc ra được không* và *dựng được trạng
      thái sai không* → `P2-13`, mỗi dòng một kết quả chạy thật, không một lời khẳng định suông.
- [ ] **Mỗi migration có đường lùi đã chạy thật** → chạy xuôi cả dãy trên cơ sở dữ liệu rỗng, lùi
      một bước, xuôi lại; dán cả ba output.
- [ ] **Dữ liệu mồi dựng lại đúng menu thật** → mười một ca giá bắt buộc của `shop-facts.md` §4.8
      tính lại khớp **từng đồng**.
- [ ] **Ba scenario nghiệm thu đi hết được trên lược đồ** → `P2-13`, mỗi bước ghi/đọc được bằng dữ
      liệu thật; tiền của cả ba cộng lại được từ `shop-facts.md`.
- [ ] **Mọi mốc tính tiền cất đúng một chỗ, và không phép cộng nào dựa vào giờ của máy khách** →
      `grep` các mốc, đối chiếu với bảng §2 của
      [`02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md).
- [ ] **Không endpoint · route · component nào lọt vào file pha 2** → `P2-14` **cộng** Gate 1d
      (`P2-02`), và dán **cả lệnh chưa lọc cạnh lệnh đã lọc** (**F-017**).
- [ ] **Không câu hỏi nghiệp vụ nào đang mở mà một bước pha 2 phải đoán thay** → `./scripts/brief.sh`
      mục *OPEN UNKNOWNS*, hỏi từng câu một: *có bước nào phải đoán thay câu này để viết được một
      dòng của mình?*
- [ ] **Bốn mã nợ của pha 1 đã được đọc** — `F-034` · `F-036` · `F-037` · `F-038` → mỗi mã hoặc đã
      đóng, hoặc có **một dòng** trong file pha 2 nói rõ lược đồ đứng thế nào khi nó còn mở.
- [ ] **Ba hàng `CLAUDE.md` §2 hết nói *chưa có owner*** cho thứ pha 2 sở hữu, và
      `docs/product/00-index.md` kể tên mọi file pha 2.

**Một ô không tick được thì để trống kèm lý do và mã của chỗ đang chặn.** Không tick hộ, không xoá
ô, và không sang pha 3 với một ô trống chạm tiền. **Đủ các ô không phải câu *"được, sang pha 3"***:
ký chuyển pha là quyền chủ repo.

---

## 10. Rủi ro lớn nhất của pha này

**Pha 2 thi công đề xuất 16 bảng ngày 2026-08-31 như một lược đồ đã chốt.** Nó chạy được, nó trông
đúng, và nó rẻ hơn mọi đường khác — nhưng
[`architecture.md`](../docs/product/1-system-design/architecture.md) §8 đã đo được **tám** chỗ nó
chưa có chỗ cất, trong đó có **vết hoàn tiền** và **khoản nợ**. Thiếu hai thứ ấy thì đối soát ngưỡng
lệch **0đ** — cổng chất lượng mạnh nhất của cả dự án — không thực hiện được, và điều đó chỉ lộ ra
sau vài tuần quán chạy thật, lúc sửa lược đồ đã phải mang theo dữ liệu bán hàng thật.

**Cách chặn:** năm lát ở §6 mỗi lát chấm ngược **danh sách `YC` của mình**, không chấm bằng *"đã
tạo xong bảng"*; và ô cổng thứ tư ở §9 tồn tại riêng để bắt đúng ca này.

---

## 11. Còn lại — pha 3

**Pha 3 · BE** nhận từ pha 2: lược đồ đã dựng, thứ tự migration, dữ liệu mồi, quy tắc dữ liệu, bộ
truy vấn đối chiếu và quy ước code. Pha 3 trả lời *ai được làm gì, giá tính ở đâu* — endpoint,
quyền theo vai, **một** hàm tính giá duy nhất. Pha 3 không mở lại lược đồ; gặp chỗ pha 2 sai thì
gửi ngược một dòng `F-XXX`, đúng luật hai sổ ([`prompt-fullstack.md`](prompt-fullstack.md) §6.4).
