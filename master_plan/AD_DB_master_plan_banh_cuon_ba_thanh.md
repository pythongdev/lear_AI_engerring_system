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
| Con người · §8.7 · §8.8 | trực quầy theo thời điểm — **đã dựng** ở `P2-08` · chủ quán tick ô *có đi làm* cho từng người từng ngày (`U-069` đóng 2026-09-30, thay `C31` ở vế người đánh dấu) · tạm ứng do chủ quán duyệt · thưởng lễ Tết | ghi chú huỷ một ô chấm công (**U-071** — đóng 2026-10-09: bắt buộc, chỉ chủ quán huỷ; siết ở `T-141`) · vế nối tạm ứng và thưởng vào đối soát két (`U-067` đã đóng 2026-09-30: *từ két bán hàng*; mệnh đề chưa viết lại — task `T-125`) · công thức lương: đơn giá, đơn vị tính, kỳ trả (`C26` · `C33`) · tăng ca (`C27`) · thưởng ngày đông (`C28`) · nghỉ có báo trước (`C30`) · tổng đầu người (`C23`) · ai xem được gì (`C34` · `C35` · `F55`) |
| Tài chính · §8.10 | khoản chi ngoài tiền hàng và lương: các loại chủ quán đã kể | ngày bán mà một khoản chi rời két trừ vào (`U-072` — đóng 2026-10-09: ngày người ghi khai; nguồn tiền đã có lời và đã vào `I-021` · `I-029` ở `T-125`, 2026-10-01, **ADR-074**) · chu kỳ wifi, xăng xe (`E45`) · phân bổ chi phí tháng vào lãi/lỗ ngày (`E47`) · ai ghi và xác nhận tiền mang về nhà (`E49`) · báo thuế (`E50`) · hạn nộp và xử lý thiếu/muộn của người giao (`E51`) |
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

**Đo lại 2026-10-14 (T-184, Claude Code) — lượt hai.** Lời chủ quán 2026-10-14 (T-180 · T-182 · T-183)
chuyển thêm năm vế sang cột giữa, đọc ở owner, không chép về đây:

| Vế mới đủ luật | Owner của lời | Thành bước |
|---|---|---|
| Giao việc: chủ quán và POS tạo · sửa · xoá việc, đánh dấu xong | `shop-facts.md` §8.7 (U-084 · U-089) | `P2A-11` |
| Đào tạo: hướng dẫn chữ · ảnh · video; ghi nhận xét và đánh giá đạt · chưa | §8.7 (U-086 · U-090) | `P2A-12` — hướng dẫn gắn từng việc giao (U-091 đóng 2026-10-14) |
| Danh mục món · combo do chủ quán tự quản lý; topping là tuỳ chọn phụ thu sẵn có | §8.9 (U-082) | `P2A-13` — giá combo đặt riêng (U-092 đóng 2026-10-14) |
| Mỗi người một tài khoản, mật khẩu riêng; tự đăng ký, chủ quán duyệt; Gmail để đặt lại | §8.8 (U-083 · U-088, **ADR-104**) | `P2A-14` — chờ thiết kế `T-181` |
| Chi phí marketing là một loại chi | §8.10 (U-085) | thêm vào `P2A-05` — nguồn tiền riêng (U-093 đóng 2026-10-14) |

Vế ngưỡng sắp hết (**U-087**) đóng 2026-10-14 ở lượt bốn: mỗi thứ một tỉ lệ do chủ quán đặt, mặc định 20% — cột ấy vào lát nguyên liệu ở `work/backlog.md` **T-186**. Vế *đơn vị* của `B12` đã có lời lượt ba (mỗi
thứ một đơn vị riêng, §8.4) nên không còn chặn sổ nguyên liệu; mười hai tên cũ chưa có đơn vị vẫn để trống tới khi
chủ quán khai. Trang tổng kết và hiệu suất nhân viên (§8.6) **chỉ đọc** dữ liệu đã có chỗ cất — không thành bước
lược đồ; nếu backend admin thấy thiếu một cột để đếm thì gửi ngược một `F-XXX`.

---

## 3. Ranh giới — kế hoạch này KHÔNG làm gì

1. **Không mở pha 3, pha 4 cho admin.** Lời ngày 2026-09-29 nói *db*. Ai được xem gì, màn nào bày
   gì, đường gọi nào — không bước nào ở đây viết (`docs/decisions.md` **ADR-035**).
   *Bổ sung 2026-10-14 (T-184):* chủ repo nói sẽ làm backend admin (`work/backlog.md` mục *Thứ tự
   làm*). Backend admin có kế hoạch riêng của nó; file này vẫn chỉ giữ lược đồ.
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
   *Ngoại lệ 2026-10-14 (T-184), cách đọc của phiên:* chủ quán **tự quản lý** danh mục món và combo
   (U-082) là việc của trang admin, nên lát `P2A-13` **thêm** bảng cạnh lát menu `P2-05`, không sửa
   bảng giá của món; giá combo đặt riêng (U-092 đóng 2026-10-14) nằm trên combo, và hàm tính giá nhận
   combo là việc của backend.

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
16-luoc-do-giao-viec.md          P2A-11 — việc giao và lần đánh dấu xong
17-luoc-do-dao-tao.md            P2A-12 — hướng dẫn công việc, ghi nhận đào tạo
18-luoc-do-danh-muc-combo.md     P2A-13 — danh mục món, combo
19-luoc-do-tai-khoan.md          P2A-14 — tài khoản đăng nhập
```

`P2A-01` không mở file mới: nó **thêm** vào ba owner sẵn có của pha 1 và của invariant. `P2A-07` ·
`P2A-08` thêm mục vào `09-doi-chieu-bat-bien.md` và `11-cong-chat-luong-pha-2.md` của cùng thư mục,
không mở file cổng thứ hai. Mỗi lát sửa hàng *Schema* của `CLAUDE.md` §2 và thêm dòng vào
`docs/product/00-index.md` trong cùng thay đổi.

---

## 5. Mười sáu bước — master task (chín bước lượt một, bảy bước lượt hai từ 2026-10-14)

Sáu cột, cùng khuôn với `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §6. Không có cột trạng
thái: nó ở `work/backlog.md`.

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|:--:|
| **P2A-01** | **Yêu cầu dữ liệu và invariant của phần admin đã đủ luật** — dòng `YC` mới nối dãy hiện có, mệnh đề `I-0xx` mới, tầng giữ và phép đối chiếu của từng mệnh đề; chỉ cho các vế ở cột giữa §2 | — | Mỗi vế ở cột giữa §2 có đúng một dòng `YC` hai câu (*ghi được* · *không xảy ra được*) trỏ về mục `shop-facts.md` đã chốt nó; mỗi mệnh đề mới có tầng và một phép đối chiếu viết bằng lời; không dòng nào trỏ về một câu còn mở; hành vi nghiệp vụ tương ứng có ở `docs/product/0-ba/admin/01-ranh-gioi.md` | Bốn lát sau mỗi lát tự quyết *"cái gì phải không xảy ra được"*, và cổng không có gì để chấm | L2 |
| **P2A-02** | **Lát sổ nguyên liệu** — danh mục thêm dần; mỗi ngày mỗi thứ hai con số người nhập; thời gian nhập; ai nhập | P2A-01 | Mỗi mệnh đề tầng 1 của lát có ràng buộc thật: **cố tình dựng trạng thái sai ⇒ database từ chối**, dán output; tổng đã nhập, tổng đã dùng và hiệu số của một thứ **đọc ra được bằng một phép cộng** từ các dòng ngày; không chỗ nào cất ngưỡng hay định lượng một suất; có bước lùi, `db-check` xanh | Con số chủ quán gõ mỗi ngày không cộng lại được, hoặc cộng ra hai đáp số | L2 |
| **P2A-03** | **Lát chấm công** — ô *có đi làm* của từng người từng ngày, người là người của `P2-08` | P2A-01 · `U-069` — **đã có lời 2026-09-30** (chủ quán tick hết, mỗi người mỗi ngày một ô) | Đọc ra được *người này, ngày này, có đi làm, ai tick*; một ô không gắn với người nào, hay ô thứ hai cùng người cùng ngày ⇒ bị từ chối; không chỗ nào cất giờ tới, ngưỡng đi muộn hay một khoản trừ | Mức 3 (lương) sau này đứng trên một sổ công không ai tin | L2 |
| **P2A-04** | **Lát khoản của người** — tạm ứng và thưởng: của ai, bao nhiêu, lúc nào, ai duyệt | P2A-01 | Mỗi khoản đọc lại được sau nhiều ngày với đủ bốn thứ ấy; một khoản tạm ứng không có người duyệt ⇒ bị từ chối; khoản đã ghi không sửa đè — sửa để lại vết theo `P2-08` | Tiền đã đưa cho người làm không truy được về một lần duyệt có tên | L2 |
| **P2A-05** | **Lát khoản chi** — khoản chi ngoài tiền hàng và lương, theo loại | P2A-01 · task `T-125` (xong 2026-10-01, **ADR-074**: mỗi loại chi mang nguồn tiền; khoản giữ ngày khai và lúc ghi, không cột ngày bán của két khi `U-072` còn mở) · **chủ repo duyệt ADR-074** | Mỗi khoản chi đọc lại được: loại, số tiền, ngày, ai ghi; mỗi loại đọc ra nguồn tiền; tổng chi một khoảng ngày **đọc ra được bằng một phép cộng**; tiền hàng **không** vào đây lần thứ hai (giới hạn ghi ở `shop-facts.md` §8.10) | Lãi/lỗ sau này cộng trùng tiền hàng, hoặc thiếu hẳn một loại chi | L2 |
| **P2A-06** | **Dữ liệu mồi admin** — danh mục nguyên liệu sinh lúc chạy từ `shop-facts.md` §8.4, không chép danh sách thứ hai | P2A-02 | Số thứ và tên trong database khớp bảng ở §8.4 (`comm -3` rỗng, in cả hai danh sách); thứ chưa có đơn vị thì đơn vị **trống**, không tự gán | Mọi phép kiểm sau chạy trên một danh mục không phải của quán | L1 |
| **P2A-07** | **Phép đối chiếu của admin vào bộ đối chiếu** — mỗi phép của `P2A-01` thành đúng một câu, vào cùng một lệnh sau khi đóng quán | P2A-02 → P2A-05 · P2A-06 | `comm -3` giữa mã mệnh đề mới ở `quality/invariants.md` và mã của bộ câu ⇒ rỗng; dữ liệu đúng ⇒ 0 dòng; **mỗi** lỗi cài ⇒ đúng câu của nó kêu | Mệnh đề admin chỉ tồn tại trên giấy | L2 |
| **P2A-08** | **Cổng chất lượng** — diễn **một ngày quản trị** qua lược đồ (nhập sổ nguyên liệu · chấm công · ghi khoản chi · duyệt tạm ứng), chấm ngược từng dòng `YC` mới, ký ô 1–6 của §7 (ô 7 · 8 là của `P2A-09`) | P2A-01 → P2A-07 | Mỗi bước của ngày ấy ghi rồi đọc lại được bằng dữ liệu thật; mỗi dòng `YC` mới trả lời hai câu; chỗ không trả lời được thành `F-XXX`/`U-XXX`, không thiết kế bù | Lược đồ đẹp mà không chạy nổi một ngày của chủ quán | L2 |
| **P2A-09** | **Rà ranh giới pha và pointer** trên các file lát admin, ký ô 7 · 8 của §7 | P2A-08 | Bộ lọc endpoint · route · component **và** bộ lọc chín phần ở §6 chạy trên mọi file và mọi đoạn lượt admin thêm (tập liệt kê ở entry), in cả lệnh chưa lọc cạnh lệnh đã lọc (**F-017**), mỗi lượt có một dòng cài để chứng minh biết kêu; lát còn vắng có dòng *vắng, rà lại khi lát ấy xong*; pointer từ `shop-facts.md` §8, `work/backlog_AD.md`, `architecture.md` §14, `docs/product/0-ba/admin/01-ranh-gioi.md`, hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` sang chỗ mới còn đúng | Pha 3 đọc một dòng hợp đồng do lát admin viết hộ như đầu vào đã chốt | L1 |

| **P2A-10** | **Yêu cầu dữ liệu và invariant của lượt hai** — dòng `YC` và mệnh đề `I-0xx` mới cho đúng các vế ở bảng *lượt hai* §2, cùng tầng giữ và phép đối chiếu; khuôn của `P2A-01` | `P2A-01` | Mỗi vế ở bảng lượt hai có đúng một dòng `YC` hai câu trỏ về mục `shop-facts.md` đã chốt nó; vế còn chờ `T-181` ghi *chờ*, không viết hộ; hành vi ở `docs/product/0-ba/admin/01-ranh-gioi.md` | Bốn lát sau tự quyết *cái gì phải không xảy ra được* | L2 |
| **P2A-11** | **Lát giao việc** — một việc: nội dung, người nhận, ai tạo, lúc tạo; ai đánh dấu xong và lúc nào; *xoá* là ẩn có vết | P2A-10 | Người không phải chủ quán hay POS tạo · đánh dấu xong ⇒ bị từ chối ở tầng nào `P2A-10` chọn; việc đã ẩn còn đọc lại được kèm ai ẩn; sửa để lại vết theo `P2-08`; có bước lùi, `db-check` xanh | Việc đã giao biến mất không ai biết ai xoá | L2 |
| **P2A-12** | **Lát đào tạo** — ghi nhận về một người: nhận xét, *đạt · chưa*, ai ghi, lúc ghi; hướng dẫn công việc chữ · ảnh · video | P2A-10 · `P2A-11` cho vế hướng dẫn (gắn việc giao, U-091) | Ghi nhận đọc lại được với đủ bốn thứ; hướng dẫn gắn đúng một việc giao; *đạt · chưa* không có giá trị thứ ba; ảnh · video cất đường dẫn, không cất tệp trong database (chỗ giữ tệp là quyết định của bước, có ADR) | Đánh giá người làm không truy được ai đánh giá | L2 |
| **P2A-13** | **Lát danh mục món và combo** — danh mục do chủ quán đặt tên, món thuộc danh mục; combo gồm những món nào và giá riêng của nó | P2A-10 | Món gắn một danh mục có thật; danh mục, combo ẩn chứ không xoá; mỗi combo một giá chủ quán đặt (U-092), số nguyên đồng lớn hơn 0, đổi giá để lại vết; lát không sửa hàm giá — combo vào hàm giá là việc backend | Hai bản giá cho cùng một combo | L2 |
| **P2A-14** | **Lát tài khoản đăng nhập** — tài khoản của một `person`: tên đăng nhập, mật khẩu đã băm, Gmail, trạng thái chờ duyệt · đã duyệt · khoá, vai; phiên đăng nhập; mã đặt lại mật khẩu | `T-181` — **thiết kế đăng nhập được chủ repo duyệt** (**ADR-104**) | Tài khoản chưa duyệt không mở được phiên; không cột nào cất mật khẩu thô; một Gmail một tài khoản; đăng nhập ở quầy ghi được mốc `C36` vào trực quầy sẵn có | Người nghỉ việc vẫn vào máy, hoặc mật khẩu lộ cả quán | L2 |
| **P2A-15** | **Đối chiếu và cổng lượt hai** — rà `comm -3` và câu ngang lát cho mệnh đề của `P2A-10` (câu của từng mệnh đề viết ở lát của nó từ 2026-10-14, **ADR-105** điểm 6); diễn một ngày quản trị lượt hai (giao việc · đánh dấu xong · ghi nhận đào tạo · chủ quán thêm món vào danh mục); khuôn `P2A-07` · `P2A-08` | P2A-11 → P2A-14 đã `Done` hoặc ghi *vắng* | `comm -3` mã mệnh đề ↔ mã câu rỗng; mỗi lỗi cài kêu đúng câu; mỗi bước của ngày ghi rồi đọc lại được | Mệnh đề lượt hai chỉ có trên giấy | L2 |
| **P2A-16** | **Rà ranh giới pha và pointer lượt hai** — khuôn `P2A-09` trên file lát `16-`…`19-` và migration của chúng | P2A-15 | Như `P2A-09`: cặp lệnh chưa lọc · đã lọc, dòng cài biết kêu, pointer từ §2 `CLAUDE.md` và `docs/product/00-index.md` đúng | Pha 3 đọc dòng hợp đồng do lát viết hộ | L1 |

**Lượt hai — chạy song song được:** `P2A-11` · `P2A-12` · `P2A-13` sau `P2A-10`; `P2A-14` chạy riêng theo `T-181`.
Lát nào còn chờ câu thì dựng phần đã có lời và ghi rõ phần chờ, không dựng chỗ cất cho phần chờ.

**Chạy song song được:** `P2A-02` · `P2A-03` · `P2A-04` · `P2A-05` sau khi `P2A-01` xong — bốn lát
không dùng chung mệnh đề nào, nhưng dùng chung người và vết của `P2-08`; lát vào sau **thêm** file
và **thêm** dòng mục lục (`work/findings.md` **F-010** · **F-014**). Lát còn bị chặn (`P2A-05` chờ chủ repo duyệt
**ADR-074** — *duyệt 2026-10-14, T-188*; `P2A-03` hết bị chặn 2026-09-30) **không** giữ chân các bước chung: `P2A-07` · `P2A-08` chạy trên những lát đã `Done` và
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
| ~~Ngưỡng nhắc sắp hết của từng nguyên liệu~~ — **đã có lời 2026-10-14** (U-087 đóng: tỉ lệ chủ quán đặt, mặc định 20%) | — | lược đồ ở `T-186` |

---

## 7. Cổng chất lượng — ô 1–6 ký ở `P2A-08`, ô 7 · 8 ký ở `P2A-09`, mỗi ô một output thật

| # | Ô | Chứng minh bằng |
|---|---|---|
| 1 | Mỗi vế ở cột giữa §2 có dòng `YC`, và mỗi dòng `YC` mới trỏ về một lời đã chốt | bảng đối chiếu vế ↔ `YC` ↔ mục `shop-facts.md`, không hàng trống |
| 2 | Mỗi mệnh đề tầng 1 mới có ràng buộc thật | output *database từ chối* của từng mệnh đề |
| 3 | Mỗi phép đối chiếu mới là một câu chạy được và biết kêu | output bộ đối chiếu: 0 dòng trên dữ liệu đúng, khác 0 trên lỗi cài |
| 4 | Mỗi migration mới có bước lùi chạy thật | output `./scripts/db-check.sh` |
| 5 | Tên bảng ở tài liệu và ở migration khớp | output Gate 1e |
| 6 | Một ngày quản trị diễn được qua lược đồ | output lượt diễn ở `P2A-08` |
| 7 | Không lát nào cất thứ thuộc §6 | phép lọc ở `P2A-09`, cộng một lượt đọc bằng mắt |
| 8 | Không endpoint · route · component nào trong file lát admin | phép lọc `P2A-09` theo mẫu rộng của `P2-14`, cộng output Gate 1d — Gate 1d hẹp hơn phép lọc (`work/findings.md` **F-049**), nên một mình nó không ký được ô |

Lát còn bị chặn (`P2A-05` chờ duyệt **ADR-074** — *duyệt 2026-10-14, T-188*; `P2A-03` hết bị chặn 2026-09-30) khi cổng ký thì ô của nó ghi **vắng, chờ câu nào** — không
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
   đóng — *một ô "có đi làm" do chủ quán tick* — và lời ấy va với `C31` ở vế ai bấm; chấm công khi ấy
   phụ thuộc **U-069**. *Cập nhật 2026-09-30 (`P2A-03`):* `U-069` đã đóng — chủ quán tick hết, mỗi
   người mỗi ngày một ô — nên lát chấm công không còn câu chặn; câu mở ra khi ấy, **U-070** (gỡ một ô
   tick nhầm), cũng đóng cùng ngày — nút huỷ, có ghi chú — và lát đã dựng theo lời ấy; **U-071**
   đóng 2026-10-09 (ghi chú bắt buộc, chỉ chủ quán huỷ) — siết ở `T-141`, không chặn lát.
5. **Khoản chi được coi là phụ thuộc U-066** vì lời chủ quán chỉ nói nguồn tiền của chi lặt vặt.
   *Cập nhật 2026-09-30 (T-124):* `U-066` đã đóng — điện, nước, wifi, xăng xe *từ két bán hàng* —
   nên khoản chi chạm đối soát cuối ngày; lát chờ task `T-125` viết vế ấy vào mệnh đề.
   *Cập nhật 2026-10-01 (T-125):* vế ấy đã viết (**ADR-074**); lát chờ chủ repo duyệt thiết kế ấy,
   không chờ `U-072`.
6. **Mã `P2A-XX` và sổ mô tả riêng** là lựa chọn của phiên (ADR-068), không phải lời chủ repo.
7. **Danh mục nguyên liệu cho phép một thứ chưa có đơn vị**, vì `shop-facts.md` §8.4 nói rõ một
   phần tên chưa có đơn vị và cấm tự gán.

---

## 9. Rủi ro lớn nhất

**Dựng rộng hơn lời.** Mảng admin có nhiều câu trả lời nửa chừng, và một lược đồ *"để sẵn cho sau
này"* trông vô hại cho tới khi pha 3 đọc cái cột để sẵn ấy như một luật đã chốt. Cách chặn: §6
không có bước, ô 7 của cổng, và `P2A-01` — lát nào không trỏ được về một dòng `YC` thì không dựng.
