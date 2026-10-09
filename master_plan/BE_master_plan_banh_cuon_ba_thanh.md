# BE — kế hoạch pha 3 dự án Bánh cuốn Bà Thanh Cao Bằng

*Viết 2026-09-29, cập nhật 2026-10-01 · T-120 · chủ repo yêu cầu trong phiên: **"phase db đã xong hãy kiểm tra lại và làm
viết prompt để thực hiện pha tiếp theo. pha tiếp theo cần master plan, backlog, hay làm tất cả các
bước cần thiết để thực hiện"**. Quyết định về hình dạng của kế hoạch này: `docs/decisions.md`
**ADR-076**; hình dạng ấy chép của kế hoạch pha 2 (**ADR-049**), vốn chép của pha 1 (**ADR-033**).*

> **File này là KẾ HOẠCH, không sở hữu một sự thật nào.** Nó nói *pha 3 nợ những gì và chạy theo thứ
> tự nào*. Nó **không** giữ hợp đồng API, không giữ tên endpoint, không giữ quyền của một vai, không
> giữ luật nghiệp vụ, không giữ lược đồ. Chỗ nào cần một con số hay một luật, đọc ở owner của nó
> (`CLAUDE.md` §2) — ở đây cố ý không có bản chép thứ hai (`work/findings.md` **F-001**).
>
> **Trạng thái của từng bước không nằm ở đây.** Owner của *Tasks* là `work/backlog.md`; mô tả dài và
> hồ sơ thực thi của từng bước là entry ở [`work/backlog_BE.md`](../work/backlog_BE.md) (**ADR-051**
> áp sang pha 3). Bảng §6 có sáu cột và **không có cột Trạng thái**.
>
> **Pha 3 là L3 ở cấp giai đoạn** — nó là chỗ đầu tiên code thật ghi tiền của quán. **Không bước
> nào trong bảng §6 là L3**: mỗi bước là một L1/L2 làm xong trong một phiên (`CLAUDE.md` §3).
>
> **Pha 3 ĐÃ MỞ 2026-10-05 — chủ repo ký chuyển pha** (T-136), nguyên văn *"đồng ý chuyển sang pha 3. xác nhận cách chia mười bốn bước pha 3"*. Pha 2 đã xong
> cả mười bốn bước ngày 2026-09-30; cổng tick **12/12**, bằng chứng ở
> `docs/product/2-db/11-cong-chat-luong-pha-2.md` §7. `P3-01` nhận được từ hôm ấy; các bước sau
> theo cột *Cần xong trước* của §6. Thư mục `docs/product/3-be/` mở ngày 2026-10-06 ở `P3-04` (hợp đồng API, **ADR-084**). Đường lùi migration đã được giải
> ở `P2-09`, **ADR-065**: mỗi bước migration một bước lùi có khoá chặn.

---

## 1. Bốn tài liệu đã nói về "API trông thế nào" — và không cái nào là owner

Cùng hình §1 của kế hoạch pha 2. Lúc viết kế hoạch **owner của hợp đồng API chưa tồn tại** — từ
2026-10-06 (`P3-04`) owner là `docs/product/3-be/openapi.yaml` cùng khuôn `01-hop-dong-api.md`
(`CLAUDE.md` §2, **ADR-084**) — nhưng bốn chỗ đã nói tới nó trước đó:

| Tài liệu | Nó là gì | Được đọc như |
|---|---|---|
| [`prompt-fullstack.md`](prompt-fullstack.md) §3.6 · §3.4 | **bản xuất khẩu** viết 2026-08-31 — một danh sách đường gọi, một stack, một cách đăng nhập | **đề xuất để đối chiếu** (**ADR-035** luật 3); chính khối §3.4 đã sai một lần (DBMS, **ADR-055**) |
| [`../docs/product/1-system-design/architecture.md`](../docs/product/1-system-design/architecture.md) §1.1 · §4 · §12.2 | luật ghi (*ai ghi tiến độ*), quyền gắn **chỗ đứng**, bốn luật backend của nợ | **luật pha 1** — pha 3 thi hành, không viết lại |
| [`../docs/product/1-system-design/03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md) | mọi vế giao cho **tầng 2 · tầng 3** | **đề bài chính của pha 3** — xem §4.1 |
| **file này** | kế hoạch: thứ tự · mức · đầu ra kiểm chứng được | **không sở hữu gì** |

**Bẫy của pha này giống hệt bẫy của pha 2, chỉ đổi tầng.** §3.6 có sẵn một danh sách đường gọi trông
đủ, và thi công nó là xong trong vài buổi. Nhưng nó viết **trước** lược đồ của pha 2 và trước phần
lớn lời chủ quán: nó không có dấu lần gửi (`I-024`), không có quyền theo **chỗ đứng tại thời điểm**
(`YC-15`…`YC-17`), không có đường nợ · hoàn tiền · trả trước, không có vết sửa. Thi công nó như hợp
đồng đã chốt là rủi ro lớn nhất của pha (§10).

---

## 2. Câu hỏi pha 3 phải chốt xong — một dòng

> **Ai được làm gì, giá tính ở đâu.**

Đó là câu của pha 3 trong bảng sáu pha ([`prompt-fullstack.md`](prompt-fullstack.md) §7). Pha 2 trả
lời *dữ liệu sống ở đâu* và dựng tầng 1; pha 3 dựng **cửa** — mỗi đường ghi tới một ô là **một** hàm
có tên, chạy trong **một** giao dịch, do **một** vai được phép gọi, và mọi vế pha 1 giao cho tầng 2 ·
tầng 3 đứng ở cửa ấy.

Năm đầu ra bảng sáu pha đòi ở pha 3, cộng một thứ thứ sáu theo cùng lý lẽ **ADR-039** đã thêm cho
pha 2:

| # | Đầu ra | Bước nào sinh ra nó |
|:--:|---|---|
| 1 | **Endpoint + quyền theo vai** | `P3-05` (ma trận vai × thao tác) → `P3-06`…`P3-12` (từng lát) |
| 2 | **Hợp đồng API** — nguồn duy nhất cho FE | `P3-04` (khuôn) → mỗi lát thêm phần của mình |
| 3 | **Hàm tính giá duy nhất** + bảng ca test | `P3-06` |
| 4 | **Luồng đặt món từng bước** | `P3-07` (tại bàn) · `P3-08` (mang đi · giao · đặt trước) |
| 5 | **Realtime + dự phòng** | `P3-12` |
| 6 | **Quy ước code backend**: thư viện, truy cập database, khung test, cấu trúc `be/` | `P3-03` |

Cột thứ ba nói **bước nào sinh ra nó**, không nói *hôm nay có chưa* — lý do đo được ở **F-033**.

---

## 3. Ranh giới của pha 3 — cái gì không được xuất hiện trong đầu ra

Ranh giới cứng của bảng sáu pha: *pha 3 **không** nhắc component; pha 4 không đổi hợp đồng API.*

| Không được viết ra ở pha 3 | Nó là đầu ra của | Pha 3 được viết gì thay vào |
|---|---|---|
| component · route màn hình · bố cục · màu · cái gì hiện ở màn nào | pha 4 · FE | *"đường đọc này trả **đủ** để màn hiện được X mà không tự tính"* |
| compose production · HTTPS · backup theo lịch · phục hồi khi hỏng máy | pha 5 · Deploy (**T-109**, **ADR-057**) | *"cửa ghi này không mất dữ liệu đã xác nhận khi tiến trình chết giữa chừng"* |
| một bảng · một cột · một ràng buộc mới **viết thẳng trong code** | pha 2 — **migration thắng** (**ADR-053** luật 2) | một **migration mới đi tới** (`QC-05`), cùng test, trong đúng lát cần nó |

**Pha 3 cũng không mở lại ba thứ của pha trước:**

- **Không mở lại nghiệp vụ.** Chỗ chưa rõ ⇒ hỏi chủ quán hoặc một `U-XXX` (`CLAUDE.md` §3.5 · §4). Pha
  3 là pha **dễ bịa luật nhất**: mỗi `if` trong code là một luật, và một `if` viết theo cảm giác là
  một luật chủ quán chưa bao giờ nói.
- **Không mở lại tầng bảo vệ.** Thấy một hàng tầng sai ⇒ một `F-XXX` gửi ngược pha 1.
- **Không mở lại lược đồ bằng tay.** Ràng buộc database đã đứng thì code **không** kiểm lại để thay
  nó; code đọc lời từ chối (tên ràng buộc theo `QC-10`) và dịch thành lỗi. Kiểm trước ở code để
  báo lỗi đẹp hơn thì được — nhưng ràng buộc vẫn là thứ giữ.

**Mảng admin không nằm trong pha 3 này** — **ADR-068** quy định *"pha 3 · pha 4 của admin
không mở"*, cùng **Đ-2** ở `work/backlog.md` (vế 2026-09-29 chỉ mở lược đồ admin của phần
đã đủ luật). Phần *chủ quán
sửa menu · tạm dừng nhận đơn · đổi mã QR · báo cáo ngày* là của mảng **bán hàng**
(`architecture.md` §6), nên nằm trong bảng §6.

---

## 4. Pha 3 nhận gì từ pha trước — năm chỗ đọc trước khi viết dòng code đầu tiên

**4.1 Mọi vế tầng 2 · tầng 3 ở [`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md).**
Đây là đề bài chính. Tầng 1 pha 2 đã dựng; **tầng 3 là cửa của pha 3**, và tầng 2 là giao dịch mà cửa
ấy mở. Lấy danh sách bằng **lệnh**, đừng đọc một con số đếm (**F-026** · **F-018**) — đo 2026-09-29
có mười tám mã mang ít nhất một vế tầng 3, nhưng con số ấy là của phiên đo. Mỗi vế ấy phải thành một
**test từ chối qua cửa**: gọi cửa với trạng thái sai ⇒ cửa từ chối, database không đổi.

**4.2 Lược đồ đã dựng và cách đọc lời từ chối.** `db/migrations/` là owner của tên · kiểu · ràng buộc
(**ADR-053** luật 2); năm file lát ở `docs/product/2-db/` giữ ý định. `QC-10` đặt tên ràng buộc
**để backend đọc được luật nào vừa chặn** — pha 3 dựa vào điều ấy. `QC-03`: backend chạy bằng vai
`shop_app`, **không xoá được** (`QD-50`). `QC-06`: mọi kết nối đặt múi giờ quán tường minh — đó là
chỗ trống pha 2 để lại cho kết nối của backend.

**4.3 Thời gian và ngày bán.** [`02-thoi-gian-ngay-ban.md`](../docs/product/1-system-design/02-thoi-gian-ngay-ban.md)
— **nguồn thời gian** của mọi mốc tính tiền. Pha 3 là chỗ duy nhất có thể lỡ tay lấy giờ của máy
khách; ô cổng §9 thứ tám của pha 2 chấm lược đồ, ô tương ứng của pha 3 chấm **code**.

**4.4 Realtime và đường suy giảm.** [`05-realtime-va-du-phong.md`](../docs/product/1-system-design/05-realtime-va-du-phong.md)
và [`01-ranh-gioi-he-thong.md`](../docs/product/1-system-design/01-ranh-gioi-he-thong.md) §2 · §3 —
sáu phụ thuộc ngoài, mỗi cái một đường suy giảm đủ ba vế. `P3-12` thi hành, không chọn lại.

**4.5 Dữ kiện quán và ca giá.** `master_plan/shop-facts.md` — owner của giá, phụ thu, kênh, luật.
Bảng ca giá §4.8 là **bảng ca test** của hàm giá `P3-06`; test **đọc** nó, không gõ lại con số
(cùng cách `P2-10` làm — `db/seed/`).

### Chỗ đang mở mà một bước pha 3 chạm vào — đọc trước khi tin một ô nào

Đo 2026-10-01. Danh sách sống ở `./scripts/brief.sh`; bảng này nói **cái gì chặn bước nào**.

| Mã | Nó thiếu cái gì | Chạm bước nào | Ai gỡ |
|---|---|---|---|
| **S-5** | bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`shop-facts.md` §7.2, suy ra, chưa hỏi) | `P3-10` — **không còn chặn cửa** (chủ repo chọn 2026-10-09, ADR-090 điểm 4: cửa nhận đúng tập đơn vị quầy chọn); vẫn cần trước khi pha 4 dựng màn quầy | chủ quán |
| **S-6** | đơn giao tận nơi, quầy bấm mốc *"đã ra bàn"* **lúc nào** | `P3-08` · `P3-10` | chủ quán |
| **U-058** | giảm giá cả đơn: có trong bản đầu không · trần · có bắt ghi lý do không | `P3-09` | chủ quán |
| **F-044** | một tập đối chiếu của `I-004` không bao giờ rỗng | `P3-10` (và `P2-11`) | pha 1/2 |
| ~~**F-047**~~ | **đóng 2026-10-05 (`T-137`, ADR-081)**: lần thêm dòng con có khai lý do để lại vết trên bản ghi cha (migration bước 17); ba câu `I-024/3` · `I-011/1` · `I-021/7` chỉ kêu lần thêm không vết | `P3-11` — cửa sửa đơn khai lý do khi thêm món; chế độ nghiêm cho cả lần thêm đi cùng F-046 | — |
| **F-046** | vết cập nhật ở chế độ mềm | `P3-11` — gỡ cùng lượt dựng cửa cập nhật | `P3-11` |
| ~~**F-048**~~ | **đóng 2026-10-05 (`T-133`, ADR-079)**: số đếm két `cash_count` · `cash_count_line` và dấu `reconciled_day` có chỗ cất, câu `I-021/1` · `I-012/2` · `I-014/5` chạy | `P3-09` — cửa đóng ngày ghi số đếm và dấu; còn chờ **U-073** (ngày lệch có đóng được không) và quyết con số chụp lúc đóng (`I-014` tập 6) | chủ quán qua `U-073` |
| ~~**F-050**~~ — **đóng 2026-10-01 (T-132)** | vết của mỗi lần *quán đang mù* và mỗi lần *tạm dừng nhận đơn*: nay có dòng `YC-34` và chỗ cất (migration bước 14, **ADR-078**) | `P3-12` — cửa tạo lượt gọi đọc hai khoảng tại mốc tạo, ghi khoảng mù khi phát hiện và khép bằng nút mở lại | — |

**Một bước bị chặn vẫn chạy được phần không phụ thuộc câu trả lời**, và cửa của phần bị chặn **từ
chối** thao tác ấy kèm mã của chỗ đang chặn — không bao giờ lấp bằng một mặc định.
**U-063 đã đóng**; cửa thu nợ đọc **ADR-075** và `04-luoc-do-duong-tien.md` theo lược đồ
đã dựng ở **T-126**: mỗi lần trả một dòng mang số còn thiếu, các lần trả nối thành chuỗi.
**U-064 đã đóng**; lược đồ có chỗ ghi bánh làm sai từ **T-127** (2026-10-01, **ADR-077**).

---

## 5. Đầu ra pha 3 nằm ở đâu — bản đồ file, và ba luật ghi

Tài liệu của pha 3 vào thư mục **mới** `docs/product/3-be/`, ra đời cùng **dòng nội dung đầu tiên**
của pha — ở `P3-04`, không sớm hơn (**ADR-035** luật 2). Code vào `be/` (`QC-08` · `QC-09`), ra đời ở
`P3-03`.

```text
docs/product/3-be/
  01-hop-dong-api.md           P3-04 — khuôn hợp đồng: hình lỗi, tiền và mốc trên dây, dấu lần gửi
  openapi.yaml                 P3-04 — hợp đồng máy đọc, nguồn duy nhất cho FE (OpenAPI 3.1, ADR-084)
  02-vai-va-quyen.md           P3-05 — ma trận vai × thao tác, chỗ đứng tại thời điểm
  03-ham-gia.md                P3-06 — một hàm tính giá, bảng ca test đọc từ shop-facts §4.8
  04-luong-tai-ban.md          P3-07
  05-luong-mang-di.md          P3-08
  06-duong-tien.md             P3-09
  07-san-xuat-theo-me.md       P3-10
  08-vet-va-nhap-bu.md         P3-11
  09-realtime-du-phong.md      P3-12
  10-cong-chat-luong-pha-3.md  P3-13 — ba scenario qua API, và cổng sang pha 4
be/                            P3-03 — code backend (QC-08 · QC-09)
```

*(Tên file là **đề xuất của kế hoạch**, không phải cam kết: bước nào thấy tên sai thì đặt lại và sửa
dòng này trong cùng thay đổi.)*

- **File sinh ra cùng dòng nội dung đầu tiên, không sớm hơn** (`CLAUDE.md` §3.8).
- **Thêm một file thì thêm một dòng vào `docs/product/00-index.md`** trong cùng thay đổi; `P3-04` đổi
  hàng *Pha 3* của bảng *Sáu pha* ở đó sang **đang mở**.
- **Mâu thuẫn với pha 1 hoặc pha 2 ⇒ một dòng `F-XXX` gửi ngược**, không viết bản thứ hai.

**Hàng `CLAUDE.md` §2 đổi ở bước nào** — cùng cách đọc kế hoạch pha 2 §5 (**ADR-035** luật 2):

| Hàng §2 | Đổi ở bước | Đổi thành |
|---|---|---|
| **Hợp đồng API**: endpoint, quyền theo vai, chữ ký | `P3-04` | file hợp đồng của `docs/product/3-be/`; quyền theo vai thêm file của `P3-05` |
| **Quy ước code** | `P3-03` | không đổi owner — thêm mục `QC-XX` mới vào `10-quy-uoc-code.md` (`QC-09` đã hẹn thế) |

**Hợp đồng thắng hay code thắng** — đã chốt 2026-10-06 ở `P3-04`: **ADR-084** (hợp đồng thắng code; migration
thắng hợp đồng về tên ràng buộc; Gate 1g chấm mọi lượt).

**Sổ task và hồ sơ thực thi.** Mô tả dài của mười bốn bước ở [`work/backlog_BE.md`](../work/backlog_BE.md)
(**ADR-036** luật 1: dãy mã riêng `P3-XX`, một chuỗi việc đọc liền nhau), có hàng ở `CLAUDE.md` §2.
Trạng thái chỉ ở `work/backlog.md`, và **chỉ bước nhận được ngay mới có dòng *Ready*** (**F-012**).
Khối *Nhận việc* của một bước chỉ viết khi mọi bước ở cột *Cần xong trước* đã `Done` (T-051).

---

## 6. Mười bốn bước — master task pha 3

Cột **Mức** ở đây vì nó quyết định ceremony trước khi ai nhận việc. Mọi bước L2 chạm tiền nên đi theo
**`docs/prompt-guideline.md` §6.1** (**ADR-054**): Claude viết test hồi quy **trước**, Codex làm cho
test xanh trong worktree riêng, Claude tự chạy lại.

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Mức |
|---|---|---|---|---|:--:|
| **P3-01** | Chốt **ranh giới và từ vựng pha 3**: tầng 2 · tầng 3 dịch sang code thành cái gì (*một cửa ghi* nghĩa là gì, chấm bằng gì), lời từ chối của database dịch thành lỗi thế nào, và cái pha 3 **không** viết — một ADR, không một dòng code | pha 2 đã xong 2026-09-30, cổng 12/12 ở `11-cong-chat-luong-pha-2.md` §7; chủ repo ký chuyển pha 2026-10-05 (T-136) | Một ADR mới; mọi bước sau trích được từ nó câu trả lời cho *"vế tầng 3 này phải thành cái gì, và biên nhận là gì"*; `docs/product/3-be/` và `be/` **chưa** tồn tại sau lượt này | Mười ba bước sau mỗi bước tự hiểu chữ *"cửa"*, và tám lát chạy song song gặp nhau ở cổng với tám cách hiểu | L2 |
| **P3-02** | **Gate 1d học vùng pha 3**: `scripts/check-phase-boundary.sh` chấm thêm `docs/product/3-be/` — đỏ với **component · route màn hình · thẻ JSX kể cả thẻ có thuộc tính và thẻ đóng**, im với endpoint và SQL; bộ mẫu riêng dựng trên mẫu sau T-131, **F-049 Fixed (T-131)** | P3-01 | Ca hồi quy mới trong `scripts/check-phase-boundary.test.sh` theo khuôn T-131 (đỏ với component, route màn hình, các dạng thẻ; xanh với endpoint và SQL); hai hình tên trong backtick — PascalCase và đường dẫn mở đầu bằng dấu gạch chéo — vẫn để mắt người theo header; **cả bộ ca cũ vẫn xanh** | Pha 3 viết giao diện hộ pha 4 mà không cổng nào đỏ — lần thứ ba của `F-040` · `F-041` | L2 |
| **P3-03** | **Quy ước code backend** (`QC-09` đã hẹn): thư viện web · cách truy cập database · khung test Go chạy trên **PostgreSQL thật** · cấu trúc `be/` · kết nối bằng `shop_app` và đặt múi giờ (`QC-06`) · `scripts/verify.sh` gọi `be/` — dựng `be/go.mod` với **một** test khói | P3-01 | Mỗi quy ước mới một mục `QC-XX` có **phép kiểm chạy được**; `./scripts/gate.sh` chạy `go test` trong `be/` (dán output); test khói kết nối database kiểm và đọc được múi giờ quán; **lệnh liệt kê đường ghi** của **ADR-082** điểm 3 chạy trong gate, có ca hồi quy đỏ khi cài một đường ghi thứ hai | Phiên đầu tiên của mỗi lát tự chọn thư viện, và bốn lát có bốn cách mở giao dịch | L2 |
| **P3-04** | **Khuôn hợp đồng API** — **mở `docs/product/3-be/`**: định dạng file hợp đồng máy đọc được · hình lỗi chung (tên ràng buộc `QC-10` → mã lỗi) · tiền và mốc trên dây theo `QD-XX` · dấu lần gửi (`I-024`) trên dây · **bên nào thắng khi hợp đồng và code lệch** (ADR) | P3-01 · P3-03 | `CLAUDE.md` §2 hàng *Hợp đồng API* có owner; `00-index.md` hàng *Pha 3* **đang mở**; một **lệnh** so hợp đồng với code chạy trong gate, có ca hồi quy đỏ khi lệch | Pha 4 sinh type từ một hợp đồng không ai kiểm, và FE tính lại thứ backend đã tính — đúng chỗ `I-013` cấm | L2 |
| **P3-05** | **Danh tính · vai · quyền theo chỗ đứng tại thời điểm**: nhân viên đăng nhập · quyền gắn **chỗ đứng lúc bấm** (`architecture.md` §4, `YC-15`…`YC-17`) · khách QR vào bàn qua mã hiện hành (`I-023`) · chủ quán · *ai bấm* bắt buộc trên mọi thao tác chạm tiền (`I-012`) · đổi mã QR. **Cách đăng nhập là câu cho chủ quán** nếu chưa có lời — §3.6 chỉ là đề xuất | P3-04 | Ma trận vai × thao tác trong file mới; mỗi thao tác ghi có **đúng một** dòng; test: người không đứng quầy bấm việc của quầy ⇒ từ chối; mã QR cũ ⇒ từ chối; thao tác chạm tiền không có người ⇒ từ chối | Một thao tác tiền không truy được về người ⇒ ngưỡng lệch 0đ mất nghĩa | L2 |
| **P3-06** | **Hàm tính giá duy nhất + menu của chủ quán**: một hàm, tính thử và ghi đơn gọi **cùng** hàm · giá khách gửi lên bị bỏ (`I-013`) · tổ hợp cấm bị từ chối (`I-010`) · ảnh chụp giá lúc đặt (`I-009`) · món ngừng bán bị cửa từ chối (`I-009` tầng 3, **ADR-056**) · đổi thành phần trong giờ bán không âm thầm (`I-011`) | P3-04 · P3-05 | Test đọc bảng §4.8 của `shop-facts.md` **lúc chạy** ⇒ mọi ca khớp từng đồng qua **cửa**, không qua hàm trần; `grep` chứng minh **một** đường tính giá; sửa menu sau khi đặt ⇒ đơn cũ không đổi | Tính thử một giá, ghi đơn một giá khác — khách thấy một con số, quầy thu con số khác | L2 |
| **P3-07** | **Luồng tại bàn từng bước**: mở phiên · gọi món qua QR (chờ duyệt) và đặt hộ · duyệt · gửi lại cùng một lần (`I-024`) · suất đem về trong phiên · chuyển trạng thái (`I-016`) · đóng phiên nguyên tử (`I-017`) · dọn bàn (`I-003`). Mang `I-001` `I-002` `I-003` `I-006` `I-016` `I-017` `I-024` | P3-05 · P3-06 | Mỗi vế tầng 2 · tầng 3 của bảy mã một test từ chối qua cửa (dán output); gửi lại cùng dấu ba lần ⇒ **một** đơn; cắt giữa lúc đóng phiên ⇒ không nửa nào sống | Hai phiên trên một bàn, hoặc một lượt gọi thành hai đơn ⇒ thu sai tiền lúc đông khách | L2 |
| **P3-08** | **Luồng mang đi · giao · đặt trước**: bốn kênh ngoài bàn · liên hệ tối thiểu theo kênh (`I-022`) · đơn mang đi độc lập (`I-007`) · ngoài giờ bán, tạm dừng nhận đơn thì không đơn nào tạo được (`I-008`, `architecture.md` §6.2) · mốc giao (**S-6** để trống) | P3-05 · P3-06 | Test từ chối qua cửa cho `I-007` `I-008` `I-022` `I-024`; mỗi kênh một đơn đi hết vòng đời bằng dữ liệu thật; vế **S-6** bị cửa từ chối kèm mã, không đoán | Đơn giao không có số điện thoại, hoặc nhận đơn lúc quán đã tạm dừng | L2 |
| **P3-09** | **Đường tiền**: thu chia phương thức (`I-015`) · nợ (`I-005`), thu nợ theo chuỗi trả dần đã dựng ở **T-126**: mỗi lần trả một dòng mang số còn thiếu, nối chuỗi (đọc **ADR-075** và `04-luoc-do-duong-tien.md`) · hoàn tiền · trả trước · tiền đầu két · giảm giá cả đơn (**U-058** để trống) · đối soát cuối ngày gọi bộ truy vấn của `P2-11` (`I-014`, `I-021`) · mọi thao tác có người (`I-012`) | P3-07 · P3-08 | Test từ chối qua cửa cho năm mã; một ngày bán giả đi hết qua cửa ⇒ lệnh đối soát ra **0đ lệch**; cài một lần thu sai ⇒ đối soát kêu; thao tác còn chờ `U-XXX` bị từ chối kèm mã | Két lệch mà không truy được về một thao tác — đúng thứ ngưỡng 0đ tồn tại để bắt | L2 |
| **P3-10** | **Sản xuất theo mẻ**: duyệt đơn sinh việc trạm (`I-004`, canh ở tầng 2 — **ADR-056**) · một lần bấm một mẻ · **ghi đã phục vụ ở POS** (`architecture.md` §1.1; cửa nhận tập đơn vị quầy chọn, **S-5** không bị chọn hộ — ADR-090) · phần chia về bàn (`I-019`) · không phục vụ vượt số gọi (`I-020`) · đơn huỷ đổi chủ phần đã làm (**F-044**); cửa ghi chú bánh làm sai và cửa huỷ ghi chú theo lược đồ của **T-127** (**ADR-077**) | P3-07 | Test từ chối qua cửa cho `I-004` `I-019` `I-020`; ba trạm bếp **không có cửa ghi nào** (liệt kê cửa ⇒ trạm bếp chỉ đọc); cửa *đã bưng* nhận đúng tập đơn vị quầy chọn, không chọn *theo bàn* hay *theo mẻ* (chủ repo chọn 2026-10-09, ADR-090 điểm 4) | Bánh cộng cho bàn này thiếu cho bàn kia, hoặc bếp phải bấm nút giữa lúc tay đang tráng bánh | L2 |
| **P3-11** | **Vết sửa · nhập bù sổ giấy · trực quầy**: mọi cửa cập nhật khai lý do và người (`I-018`) — **gỡ F-046** bằng một migration mới cùng lượt, phủ cả trigger vết thêm dòng con của **ADR-081** (F-047 đã gỡ ở `T-137`) · nhập bù lượt bán trên giấy mang hai mốc (`YC-08`) · mở · khép khoảng trực quầy (`YC-15`) | P3-05 · P3-09 | Mọi cửa cập nhật liệt kê được, mỗi cửa một test *sửa ⇒ có vết đủ bốn thứ*; chế độ vết **nghiêm** bật và `db-check` vẫn xanh; nhập bù ⇒ lượt ấy đọc riêng được hai mốc | Một lần ghi đè lượt gọi không dựng lại được ⇒ thu thiếu tiền mà không ai biết | L2 |
| **P3-12** | **Realtime + dự phòng**: đẩy việc xuống màn trạm · báo đơn mới · đường suy giảm của từng phụ thuộc (`01-ranh-gioi-he-thong.md` §3, `05-realtime-va-du-phong.md`) · mất kết nối thì không đơn nào tạo được (`I-008` vế mất kết nối) | P3-10 | Test cắt từng phụ thuộc ⇒ hệ thống đi đúng đường suy giảm đã viết (dán output mỗi phụ thuộc); màn đọc bắt lại được trạng thái sau khi mất kết nối mà không mất việc nào | Bếp không thấy đơn lúc mạng chập, và không ai biết cho tới khi khách hỏi | L2 |
| **P3-13** | **Cổng chất lượng pha 3**: diễn ba scenario nghiệm thu (`08-scenario.md` §8) **qua API**, chấm mọi vế tầng 2 · tầng 3, và ký các ô §9 | P3-02 → P3-12 | Mỗi bước của ba scenario là một lần gọi thật với output; mọi vế tầng 3 có một test từ chối; chỗ không trả lời được ⇒ `F-XXX`/`U-XXX`, không tự thiết kế bù | Backend từng lát xanh mà không chạy nổi một buổi bán | L2 |
| **P3-14** | **Rà ranh giới pha và pointer**: không component · route màn hình nào trong `docs/product/3-be/` · hợp đồng là **nguồn duy nhất** (không bản chép ở chỗ khác) · mọi pointer pha 1/2 → pha 3 còn đúng | P3-13 | Bộ lọc chạy trên **mọi** file pha 3, **in cả lệnh chưa lọc cạnh lệnh đã lọc** (**F-017**); `grep` pointer hai chiều | Pha 4 đọc giao diện do pha 3 viết hộ như đầu vào đã chốt | L1 |

**Chạy song song được:** sau `P3-05` · `P3-06`, hai lát `P3-07` và `P3-08` chạy song song; `P3-02`
độc lập với cả dãy sau `P3-01`. Các lát còn lại nối nhau vì cửa sau gọi cửa trước (thu tiền cần
phiên và đơn; sản xuất cần đơn đã duyệt). Song song thì **mỗi lát một worktree, một nhánh** (`CLAUDE.md`
§7.4) và mỗi lát **thêm** phần hợp đồng của mình, không ghi đè lát trước.

**Mười bốn dòng**, trong khi [`prompt-fullstack.md`](prompt-fullstack.md) §8 khuyên tối đa mười hai —
ghi ra chứ không giấu, cùng lý lẽ kế hoạch pha 2 §6: `P3-02` (cổng) và `P3-03` (quy ước code) không
phải *lát việc*.

---

## 7. Tầng 2 · tầng 3 dịch sang pha 3 — owner là **ADR-082**

Bảng *pha 3 nợ gì · chấm bằng gì · cái gì không phải biên nhận* cho **tầng 2** và **tầng 3**, nghĩa của
*ô ghi* và *cửa ghi*, lệnh liệt kê đường ghi, phạm vi ô cổng thứ nhất, và đường đi của lời từ chối của
database: `docs/decisions.md` **ADR-082** (chốt 2026-10-05, `P3-01`). Mục này cố ý không chép (**F-001**).

---

## 8. Chỗ đang chặn, và chỗ kế hoạch này SUY RA

**Đang chặn:** bảng ở cuối §4. Một bước bị chặn vẫn chạy phần không phụ thuộc câu trả lời.

**Admin ngoài pha 3 đã có nguồn**, không còn là suy ra chờ xác nhận: **ADR-068** nói
*"pha 3 · pha 4 của admin không mở"*; xem **Đ-2** ở `work/backlog.md`, vế 2026-09-29.

**Cách chia mười bốn bước đã được chủ repo xác nhận 2026-10-05** (T-136, cùng câu ký chuyển pha:
*"đồng ý chuyển sang pha 3. xác nhận cách chia mười bốn bước pha 3"*): chẻ theo nhóm mệnh đề (giá · tại bàn · mang đi · tiền · sản xuất · vết), không theo nhóm
endpoint. Lời xác nhận nói **cách chia**; nó không chốt nội dung từng bước — mỗi bước vẫn viết
*Nhận việc* lúc nhận.

**Trạng thái đo 2026-10-01:** pha 2 xong 2026-09-30, cổng 12/12 ở
`docs/product/2-db/11-cong-chat-luong-pha-2.md` §7; chủ repo ký chuyển pha 2026-10-05.
`P3-09` đọc **ADR-075** và `04-luoc-do-duong-tien.md` để dựng cửa thu nợ theo chuỗi đã có
ở **T-126**. Vế ghi bánh làm sai của `P3-10` dựng cửa trên lược đồ của **T-127** (**ADR-077**).

**Câu cho chủ quán mà pha 3 sẽ phải hỏi** (chưa thành `U-XXX` — bước chạm nó mở `U-XXX` lúc nhận nếu
owner chưa có lời, và ghi vào `docs/product/99-unknowns.md`, không vào đây): *nhân viên đăng nhập
bằng gì* (`P3-05`; §3.6 đề xuất mã số ngắn, chủ quán chưa nói). Các câu S-5 · S-6 · U-058 còn mở ở bảng §4. U-063 và U-064 đã đóng;
không dùng hai mã ấy làm lý do từ chối.

---

## 9. Cổng chất lượng pha 3 — chỉ sang pha 4 khi đủ các ô, mỗi ô có bằng chứng

> **Các ô dưới đây là LỜI của cổng; chỗ KÝ là file cổng do `P3-13` sinh ra.** Hộp `- [ ]` ở đây
> **không được tick** (**F-001** · **F-033**). **Đếm ở danh sách, đừng đếm ở tiêu đề** (**F-018**).

- [ ] **Mọi vế tầng 3 của `03-bao-ve-invariant.md` §1–§4 có một test từ chối qua cửa** (§5 admin ngoài cổng — **ADR-082** điểm 4) → danh sách vế lấy
      bằng lệnh, danh sách test lấy bằng lệnh, `comm -3` ⇒ rỗng; mỗi test dán lời từ chối.
- [ ] **Mọi vế tầng 2 có ranh giới giao dịch đã bị cắt thử** → cắt giữa chừng ⇒ không nửa nào sống,
      dán output.
- [ ] **Mỗi ô ghi có đúng một cửa** → lệnh liệt kê đường ghi (**ADR-082** điểm 3, dựng ở `P3-03`) ⇒ mỗi ô (bảng × loại ghi) một cửa.
- [ ] **Một hàm tính giá** → bảng ca §4.8 khớp từng đồng **qua cửa**; `grep` ra một đường tính giá.
- [ ] **Hợp đồng khớp code** → lệnh của `P3-04` xanh, và đã được chứng minh biết đỏ.
- [ ] **Mọi thao tác ghi có dòng trong ma trận vai × thao tác** → `comm -3` giữa cửa và ma trận ⇒ rỗng.
- [ ] **Không mốc tính tiền nào lấy giờ của máy khách** → `grep` trong `be/` đối chiếu với
      `02-thoi-gian-ngay-ban.md` §2.
- [ ] **Ba scenario đi hết qua API** → `P3-13`, mỗi bước một lần gọi thật; một ngày bán giả qua cửa ⇒
      đối soát 0đ lệch.
- [ ] **Mỗi phụ thuộc ngoài đã bị cắt thử** → `P3-12`, dán output từng đường suy giảm.
- [ ] **Không component · route màn hình nào trong file pha 3** → `P3-14` cộng Gate 1d (`P3-02`), dán
      cả lệnh chưa lọc cạnh lệnh đã lọc.
- [ ] **Không câu nghiệp vụ nào đang mở mà một cửa phải đoán thay** → mỗi `U-XXX` · `S-X` ở bảng §4
      hoặc đã đóng, hoặc cửa của nó **từ chối** kèm mã.
- [ ] **Hàng `CLAUDE.md` §2 *Hợp đồng API* hết nói *chưa có owner***, và `00-index.md` kể tên mọi file
      pha 3.

**Ô không tick được thì để trống kèm lý do và mã.** Không sang pha 4 với một ô trống chạm tiền. Ký
chuyển pha là quyền chủ repo.

---

## 10. Rủi ro lớn nhất của pha này

**Pha 3 thi công danh sách đường gọi ngày 2026-08-31 (§3.6) như một hợp đồng đã chốt, và kiểm lại
ràng buộc database bằng `if` trong code rồi coi đó là đủ.** Nó chạy được và trông đúng — nhưng mỗi
`if` viết theo cảm giác là một luật chủ quán chưa nói, và mỗi lần kiểm ở code *thay* ràng buộc là một
lần hạ tầng trong im lặng.

**Cách chặn:** mỗi lát chấm ngược **danh sách vế tầng 3 của mình** bằng test từ chối qua cửa, không
chấm bằng *"đã có đường gọi"*; chỗ chưa có luật thì cửa **từ chối kèm mã**; và ô cổng thứ nhất ở §9
tồn tại riêng để bắt đúng ca này.

---

## 11. Cách giao một bước — lời gọi dán được

Hồ sơ thực thi của mỗi bước là entry của nó ở [`work/backlog_BE.md`](../work/backlog_BE.md); không có
file prompt riêng (**ADR-051**). Lời gọi dưới đây là để **bắt đầu** một phiên, không thay entry:

```text
Nhận bước P3-XX của pha 3. Đọc CLAUDE.md, chạy ./scripts/brief.sh, rồi đọc entry P3-XX ở
work/backlog_BE.md và kế hoạch master_plan/BE_master_plan_banh_cuon_ba_thanh.md §4 · §6 · §9.
Kiểm cột "Cần xong trước": bước nào chưa Done thì dừng và báo, không làm trước.
Nếu khối "Nhận việc" còn trống: viết Phạm vi, Nghiệm thu, Kiểm chứng TRƯỚC khi sửa gì, rồi dừng
cho tôi duyệt. Nếu đã có: khai work/scope/P3-XX.txt, chuyển P3-XX sang In Progress và làm.
Mức L2 chạm tiền: viết test từ chối qua cửa trước (đỏ), rồi mới viết cửa (xanh).
Gặp luật nghiệp vụ chưa rõ: không đoán — mở U-XXX, cửa từ chối kèm mã, làm tiếp phần còn lại.
Kết thúc bằng khối Bàn giao trong entry và khối git commit dán được (CLAUDE.md §6.1).
```

Giao cho Codex thì Claude viết **phiếu giao việc** theo `docs/prompt-guideline.md` §6.1 từ entry ấy,
trong worktree riêng; Claude tích hợp và tự chạy lại gate (**ADR-054**).

---

## 12. Còn lại — pha 4

**Pha 4 · FE** nhận từ pha 3: hợp đồng API (nguồn duy nhất, sinh type từ nó), ma trận vai × thao tác,
đường suy giảm realtime. Pha 4 trả lời *người dùng thấy gì*; nó **không đổi hợp đồng** — cần đổi thì
gửi ngược một dòng `F-XXX` về pha 3.
