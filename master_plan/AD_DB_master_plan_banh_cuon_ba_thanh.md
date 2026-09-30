# Kế hoạch — lược đồ dữ liệu của mảng QUẢN TRỊ (admin) · Bánh cuốn Bà Thanh Cao Bằng

> **File này là KẾ HOẠCH, không sở hữu sự thật nào.** Nó giữ *thứ tự · mức · đầu ra kiểm chứng
> được* của các bước `P2A-XX` và cổng của chúng. Dữ kiện quán ở `master_plan/shop-facts.md` §8;
> trạng thái từng bước ở `work/backlog.md`; mô tả dài ở `work/backlog_AD_DB.md`; lược đồ thật ở
> `db/migrations/` (`CLAUDE.md` §2).
>
> Viết **2026-09-30** (T-122) theo lời chủ repo ngày 2026-09-29: *"tôi muốn làm luôn db cho phần
> admin"*. Lời ấy mở cổng thi công **lược đồ** admin — ghi ở `work/backlog.md` mục *Thứ tự làm
> giữa lane admin và các pha* và `docs/decisions.md` **ADR-068**. Mọi con số đếm trong file này
> đo ngày 2026-09-30: **đếm lại ở owner, đừng tin** (`work/findings.md` **F-003**).

---

## 1. Câu hỏi kế hoạch này phải trả lời — một dòng

**Phần nào của ba mảng *nguyên liệu · con người · tài chính* đã đủ lời chủ quán để có chỗ cất dữ
liệu, dựng theo thứ tự nào, và mỗi bước chứng minh xong bằng lệnh gì** — còn phần chưa đủ lời thì
đứng yên ở đúng câu hỏi đang chặn nó.

---

## 2. Kết quả kiểm *"đã đủ dữ liệu chưa"* — đo 2026-09-30

**Đủ cho một phần, chưa đủ cho cả ba mảng.** Cột giữa là thứ kế hoạch này dựng; cột phải là thứ nó
**không** dựng. Lời chủ quán đọc ở mục `shop-facts.md` ghi trong cột đầu, không đọc ở đây
(`work/findings.md` **F-001**).

| Mảng · owner của lời | Đủ luật để có chỗ cất | Chưa đủ — chặn bởi |
|---|---|---|
| Nguyên liệu · `shop-facts.md` §8.4 | danh mục hàng mua vào, thêm dần, một phần đã có đơn vị mua · mỗi ngày mỗi thứ hai con số *mua vào* và *đã dùng*, người nhập tay · thời gian nhập · tổng cộng dồn và hiệu số máy trừ hộ | đơn vị của các tên cũ và đơn vị ghi lượng đã dùng (`B12`) · một thứ nhiều mối (`B15`) · nợ nhà cung cấp (`B16`) · lượng kiểm đếm cuối buổi (`B18`) · thứ nào để được tới mai (`B19`) |
| Con người · §8.7 · §8.8 | trực quầy theo thời điểm — **đã dựng** ở `P2-08` · nhân viên tự bấm chấm công · tạm ứng do chủ quán duyệt · thưởng lễ Tết | ai đánh dấu công và một ô *có đi làm* là ngày hay buổi (**U-069** — mở 2026-09-30 khi lời đóng `U-065` va với `C31`) · vế nối tạm ứng và thưởng vào đối soát két (`U-067` đã đóng 2026-09-30: *từ két bán hàng*; mệnh đề chưa viết lại — task `T-125`) · công thức lương: đơn giá, đơn vị tính, kỳ trả (`C26` · `C33`) · tăng ca (`C27`) · thưởng ngày đông (`C28`) · nghỉ có báo trước (`C30`) · tổng đầu người (`C23`) · ai xem được gì (`C34` · `C35` · `F55`) |
| Tài chính · §8.10 | khoản chi ngoài tiền hàng và lương: các loại chủ quán đã kể | vế nối khoản chi vào đối soát két (`U-066` đã đóng 2026-09-30: điện, nước, wifi, xăng xe *từ két bán hàng*; mệnh đề chưa viết lại — task `T-125`) · chu kỳ wifi, xăng xe (`E45`) · phân bổ chi phí tháng vào lãi/lỗ ngày (`E47`) · ai ghi và xác nhận tiền mang về nhà (`E49`) · báo thuế (`E50`) · hạn nộp và xử lý thiếu/muộn của người giao (`E51`) |
| Sản phẩm · §8.9 | — không thuộc kế hoạch này: là lát menu và đường tiền của mảng bán hàng | combo chưa có danh mục · giảm giá cả đơn (**U-058**) · món mới, đặc sản (`D37` · `D38`) |

Mã chữ cái (`B12`, `C26`…) là câu ở `work/admin-questions.md` §3; mã `U-XXX` ở
`docs/product/99-unknowns.md`.

**Hai điều lớn hơn từng câu hỏi:**

- **Pha 1 chưa từng viết gì cho admin.** `docs/product/1-system-design/04-yeu-cau-du-lieu.md` chỉ
  có dòng yêu cầu cho mảng bán hàng, và `quality/invariants.md` không có mệnh đề nào về sổ nguyên
  liệu, chấm công hay khoản chi. Pha 2 *thi hành* tầng bảo vệ của pha 1 (`docs/decisions.md`
  **ADR-050**), nên với admin chưa có gì để thi hành ⇒ bước `P2A-01` đứng trước mọi lát.
  **Cập nhật 2026-09-30 (`P2A-01`, Claude Code):** câu trên là **ảnh chụp lúc viết kế hoạch**. Bước
  `P2A-01` đã đo lại bảng này ở owner — `master_plan/shop-facts.md` và `work/admin-questions.md`
  không đổi từ 2026-09-28 nên không vế nào đổi cột — và đã viết tám dòng `YC-26`…`YC-33`
  (`04-yeu-cau-du-lieu.md` §9), năm mệnh đề `I-025`…`I-029` (`quality/invariants.md`) cùng tầng của
  chúng (`03-bao-ve-invariant.md` §5); lý do hình dạng ở `docs/decisions.md` **ADR-069**. Thứ tự
  giữa các lát và bước `P2A-07` còn một chỗ hở có tên: `work/findings.md` **F-052**.
  **Cập nhật 2026-09-30 (`T-123`):** chỗ hở ấy đã chữa — năm mệnh đề có dòng *chưa có lát* ở
  `docs/product/2-db/09-doi-chieu-bat-bien.md` §2.1 nên `db-check` của từng lát không đỏ vì chúng
  (`docs/decisions.md` **ADR-070**); bước nào viết câu cho một mệnh đề thì gỡ dòng của nó ở đó.
- **Lời `F52`…`F55` chưa có ở nhánh làm việc.** Nhánh `task/f52-f55` giữ một commit ghi bốn lời ấy
  nhưng chưa được gộp, và mã task của nó trùng một mã đã dùng ở đây. Kế hoạch này coi bốn câu ấy
  là **chưa trả lời**; không bước nào dưới đây cần chúng (thiết bị và quyền xem là pha 3–5).

---

## 3. Ranh giới — kế hoạch này KHÔNG làm gì

1. **Không mở pha 3, pha 4 cho admin.** Lời ngày 2026-09-29 nói *db*. Ai được xem gì, màn nào bày
   gì, đường gọi nào — không bước nào ở đây viết (`docs/decisions.md` **ADR-035**).
2. **Không dựng chỗ cất cho phần chưa có lời.** Một cột *đơn giá lương* dựng trước khi chủ quán
   nói đơn giá tính theo gì là một quyết định nghiệp vụ nguỵ trang thành lược đồ (`CLAUDE.md`
   §3.5 — luật không có mức L0). Phần ấy ở §6, mỗi phần một dòng, không có bước.
3. **Không định nghĩa lại thứ pha 2 đã dựng.** Người, chỗ đứng theo thời điểm và vết là của
   `P2-08` (`docs/product/2-db/06-luoc-do-nguoi-va-vet.md`); quy ước dữ liệu và quy ước code là
   của `P2-03` · `P2-12`; đường lùi của migration là `docs/product/2-db/07-thu-tu-migration.md`.
   Lát admin **dùng lại**, thấy thiếu thì gửi ngược một dòng `F-XXX`.
4. **Không viết tên bảng, tên cột ở file này hay ở sổ mô tả.** Chúng là đầu ra của từng lát.
5. **Không sửa mảng bán hàng.** Giảm giá cả đơn, combo, món mới là việc của lát menu và đường
   tiền, chờ lời riêng của chúng.

---

## 4. Đầu ra nằm ở đâu

Tên file dưới đây là **đề xuất của kế hoạch**: bước nào thấy tên mình sai thì đặt lại và sửa dòng
này trong cùng thay đổi. Cả bốn file mới nằm trong `docs/product/2-db/`, nối số sau `11-`, **thêm**
không ghi đè (`docs/decisions.md` **ADR-053** luật 2).

```text
12-luoc-do-nguyen-lieu.md        P2A-02 — danh mục, sổ ngày, tổng cộng dồn
13-luoc-do-cham-cong.md          P2A-03 — lần chấm công của từng người
14-luoc-do-khoan-cua-nguoi.md    P2A-04 — tạm ứng, thưởng
15-luoc-do-khoan-chi.md          P2A-05 — khoản chi ngoài tiền hàng và lương
```

`P2A-01` không mở file mới: nó **thêm** vào ba owner sẵn có của pha 1 và của invariant. `P2A-07` ·
`P2A-08` thêm mục vào `09-doi-chieu-bat-bien.md` và `11-cong-chat-luong-pha-2.md` của cùng thư mục,
không mở file cổng thứ hai. Mỗi lát sửa hàng *Schema* của `CLAUDE.md` §2 và thêm dòng vào
`docs/product/00-index.md` trong cùng thay đổi.

---

## 5. Chín bước — master task

Sáu cột, cùng khuôn với `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §6. Không có cột trạng
thái: nó ở `work/backlog.md`.

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|:--:|
| **P2A-01** | **Yêu cầu dữ liệu và invariant của phần admin đã đủ luật** — dòng `YC` mới nối dãy hiện có, mệnh đề `I-0xx` mới, tầng giữ và phép đối chiếu của từng mệnh đề; chỉ cho các vế ở cột giữa §2 | — | Mỗi vế ở cột giữa §2 có đúng một dòng `YC` hai câu (*ghi được* · *không xảy ra được*) trỏ về mục `shop-facts.md` đã chốt nó; mỗi mệnh đề mới có tầng và một phép đối chiếu viết bằng lời; không dòng nào trỏ về một câu còn mở; hành vi nghiệp vụ tương ứng có ở `docs/product/0-ba/admin/01-ranh-gioi.md` | Bốn lát sau mỗi lát tự quyết *"cái gì phải không xảy ra được"*, và cổng không có gì để chấm | L2 |
| **P2A-02** | **Lát sổ nguyên liệu** — danh mục thêm dần; mỗi ngày mỗi thứ hai con số người nhập; thời gian nhập; ai nhập | P2A-01 | Mỗi mệnh đề tầng 1 của lát có ràng buộc thật: **cố tình dựng trạng thái sai ⇒ database từ chối**, dán output; tổng đã nhập, tổng đã dùng và hiệu số của một thứ **đọc ra được bằng một phép cộng** từ các dòng ngày; không chỗ nào cất ngưỡng hay định lượng một suất; có bước lùi, `db-check` xanh | Con số chủ quán gõ mỗi ngày không cộng lại được, hoặc cộng ra hai đáp số | L2 |
| **P2A-03** | **Lát chấm công** — lần chấm công của từng người, người là người của `P2-08` | P2A-01 · **U-069 có lời** (`U-065` đã đóng 2026-09-30, lời ấy va với `C31`) | Đọc ra được *người này, ngày này, đã chấm công những mốc nào*; một lần chấm không gắn với người nào ⇒ bị từ chối; không chỗ nào cất ngưỡng đi muộn hay một khoản trừ | Mức 3 (lương) sau này đứng trên một sổ công không ai tin | L2 |
| **P2A-04** | **Lát khoản của người** — tạm ứng và thưởng: của ai, bao nhiêu, lúc nào, ai duyệt | P2A-01 | Mỗi khoản đọc lại được sau nhiều ngày với đủ bốn thứ ấy; một khoản tạm ứng không có người duyệt ⇒ bị từ chối; khoản đã ghi không sửa đè — sửa để lại vết theo `P2-08` | Tiền đã đưa cho người làm không truy được về một lần duyệt có tên | L2 |
| **P2A-05** | **Lát khoản chi** — khoản chi ngoài tiền hàng và lương, theo loại | P2A-01 · **task `T-125` xong** (`U-066` đã đóng 2026-09-30: *từ két bán hàng*, nên lát này chạm đối soát két) | Mỗi khoản chi đọc lại được: loại, số tiền, ngày, ai ghi; tổng chi một khoảng ngày **đọc ra được bằng một phép cộng**; tiền hàng **không** vào đây lần thứ hai (giới hạn ghi ở `shop-facts.md` §8.10) | Lãi/lỗ sau này cộng trùng tiền hàng, hoặc thiếu hẳn một loại chi | L2 |
| **P2A-06** | **Dữ liệu mồi admin** — danh mục nguyên liệu sinh lúc chạy từ `shop-facts.md` §8.4, không chép danh sách thứ hai | P2A-02 | Số thứ và tên trong database khớp bảng ở §8.4 (`comm -3` rỗng, in cả hai danh sách); thứ chưa có đơn vị thì đơn vị **trống**, không tự gán | Mọi phép kiểm sau chạy trên một danh mục không phải của quán | L1 |
| **P2A-07** | **Phép đối chiếu của admin vào bộ đối chiếu** — mỗi phép của `P2A-01` thành đúng một câu, vào cùng một lệnh sau khi đóng quán | P2A-02 → P2A-05 · P2A-06 | `comm -3` giữa mã mệnh đề mới ở `quality/invariants.md` và mã của bộ câu ⇒ rỗng; dữ liệu đúng ⇒ 0 dòng; **mỗi** lỗi cài ⇒ đúng câu của nó kêu | Mệnh đề admin chỉ tồn tại trên giấy | L2 |
| **P2A-08** | **Cổng chất lượng** — diễn **một ngày quản trị** qua lược đồ (nhập sổ nguyên liệu · chấm công · ghi khoản chi · duyệt tạm ứng), chấm ngược từng dòng `YC` mới, ký các ô §7 | P2A-01 → P2A-07 | Mỗi bước của ngày ấy ghi rồi đọc lại được bằng dữ liệu thật; mỗi dòng `YC` mới trả lời hai câu; chỗ không trả lời được thành `F-XXX`/`U-XXX`, không thiết kế bù | Lược đồ đẹp mà không chạy nổi một ngày của chủ quán | L2 |
| **P2A-09** | **Rà ranh giới pha và pointer** trên các file lát admin | P2A-08 | Bộ lọc endpoint · route · component chạy trên mọi file mới, in cả lệnh chưa lọc cạnh lệnh đã lọc (**F-017**); pointer từ `shop-facts.md` §8 và `work/backlog_AD.md` sang chỗ mới còn đúng | Pha 3 đọc một dòng hợp đồng do lát admin viết hộ như đầu vào đã chốt | L1 |

**Chạy song song được:** `P2A-02` · `P2A-03` · `P2A-04` · `P2A-05` sau khi `P2A-01` xong — bốn lát
không dùng chung mệnh đề nào, nhưng dùng chung người và vết của `P2-08`; lát vào sau **thêm** file
và **thêm** dòng mục lục (`work/findings.md` **F-010** · **F-014**). Hai lát có câu chặn (`P2A-03` ·
`P2A-05`) **không** giữ chân các bước chung: `P2A-07` · `P2A-08` chạy trên những lát đã `Done` và
ghi rõ lát nào còn vắng.

**Ba việc chung của pha 2 không thành bước riêng ở đây**, vì từ 2026-09-29 chúng là luật của mọi
migration chứ không còn là một lượt làm: bước lùi có khoá chặn và vòng xuôi · lùi · xuôi lại
(`docs/decisions.md` **ADR-065**), đối chiếu tên bảng giữa tài liệu và migration (Gate 1e). Mỗi
lát phải qua cả ba trong chính lượt của nó.

---

## 6. Phần bị chặn — mỗi phần một dòng, không có bước

Không viết Acceptance cho dòng nào dưới đây: một *Constraints* viết trước lời chủ quán là câu đoán
(`work/findings.md` **F-013** · **F-017**). Khi câu chặn có lời, phần ấy thành một bước mới nối
tiếp dãy `P2A-XX` — không chen vào bước đã có.

| Phần | Chặn bởi | Việc nghiệp vụ tương ứng |
|---|---|---|
| Tính lương và kỳ trả lương | `C26` · `C27` · `C28` · `C30` · `C33` · `C23` | `work/backlog_AD.md` ADM-22 · ADM-23 |
| Nợ nhà cung cấp và lần trả nợ | `B16` | ADM-11 · ADM-15 |
| Lượng kiểm đếm cuối buổi | `B18` · `B19` · `B12` | ADM-12 |
| Lãi/lỗ theo ngày | `E47`, và đứng sau phần lương | ADM-43 |
| Tiền cuối buổi mang về nhà | `E49` | ADM-44 |
| Người đi giao nộp tiền về | `E51` | ADM-44 |
| Báo thuế | `E50` | — chưa có việc |
| Ai xem được lương, công, con số tiền | `C34` · `C35` · `F55` — và là việc của pha 3 | ADM-24 · ADM-51 |
| Giảm giá cả đơn · combo · món mới | **U-058** · `D37` · `D38` — và là lát của mảng bán hàng | ADM-32 |

---

## 7. Cổng chất lượng — ký ở `P2A-08`, mỗi ô một output thật

| # | Ô | Chứng minh bằng |
|---|---|---|
| 1 | Mỗi vế ở cột giữa §2 có dòng `YC`, và mỗi dòng `YC` mới trỏ về một lời đã chốt | bảng đối chiếu vế ↔ `YC` ↔ mục `shop-facts.md`, không hàng trống |
| 2 | Mỗi mệnh đề tầng 1 mới có ràng buộc thật | output *database từ chối* của từng mệnh đề |
| 3 | Mỗi phép đối chiếu mới là một câu chạy được và biết kêu | output bộ đối chiếu: 0 dòng trên dữ liệu đúng, khác 0 trên lỗi cài |
| 4 | Mỗi migration mới có bước lùi chạy thật | output `./scripts/db-check.sh` |
| 5 | Tên bảng ở tài liệu và ở migration khớp | output Gate 1e |
| 6 | Một ngày quản trị diễn được qua lược đồ | output lượt diễn ở `P2A-08` |
| 7 | Không lát nào cất thứ thuộc §6 | phép lọc ở `P2A-09`, cộng một lượt đọc bằng mắt |
| 8 | Không endpoint · route · component nào trong file lát admin | output Gate 1d và phép lọc `P2A-09` |

Lát còn bị chặn (`P2A-03`, `P2A-05`) khi cổng ký thì ô của nó ghi **vắng, chờ câu nào** — không
ghi *đạt*.

---

## 8. Chỗ kế hoạch này SUY RA — không phải lời chủ quán hay chủ repo

Tách riêng theo `CLAUDE.md` §7.2 (`work/findings.md` **F-004**). Mỗi dòng là cách đọc của phiên
viết ngày 2026-09-30; chủ repo đổi được.

1. **Chữ *"db cho phần admin"* được đọc là lược đồ của phần đã đủ luật**, không phải cả ba mảng và
   không gồm pha 3–4. Lời gốc không nói phạm vi.
2. **Lời mở cổng được ghi là lời chủ repo.** Lời Đ-2 cũ được ghi là lời chủ quán; phiên này không
   biết hai vai có là một người không, nên ghi đúng người đã nói trong phiên.
3. **Tạm ứng và thưởng được coi là dựng được trước khi có công thức lương**: mỗi khoản là một lần
   đưa tiền có ngày và có người duyệt, đọc được riêng. Cách chúng trừ vào hay cộng vào lương thì
   thuộc phần bị chặn.
4. **Chấm công được coi là phụ thuộc U-065** vì số mốc của một lần chấm đổi hình dạng thứ phải
   cất; kế hoạch không chọn hộ *một mốc* hay *hai mốc*. *Cập nhật 2026-09-30 (T-124):* `U-065` đã
   đóng — *một ô "có đi làm" do chủ quán tick* — và lời ấy va với `C31` ở vế ai bấm; chấm công nay
   phụ thuộc **U-069**.
5. **Khoản chi được coi là phụ thuộc U-066** vì lời chủ quán chỉ nói nguồn tiền của chi lặt vặt.
   *Cập nhật 2026-09-30 (T-124):* `U-066` đã đóng — điện, nước, wifi, xăng xe *từ két bán hàng* —
   nên khoản chi chạm đối soát cuối ngày; lát chờ task `T-125` viết vế ấy vào mệnh đề.
6. **Mã `P2A-XX` và sổ mô tả riêng** là lựa chọn của phiên (ADR-068), không phải lời chủ repo.
7. **Danh mục nguyên liệu cho phép một thứ chưa có đơn vị**, vì `shop-facts.md` §8.4 nói rõ một
   phần tên chưa có đơn vị và cấm tự gán.

---

## 9. Rủi ro lớn nhất

**Dựng rộng hơn lời.** Mảng admin có nhiều câu trả lời nửa chừng, và một lược đồ *"để sẵn cho sau
này"* trông vô hại cho tới khi pha 3 đọc cái cột để sẵn ấy như một luật đã chốt. Cách chặn: §6
không có bước, ô 7 của cổng, và `P2A-01` — lát nào không trỏ được về một dòng `YC` thì không dựng.
