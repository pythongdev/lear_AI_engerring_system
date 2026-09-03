# Unknowns — câu hỏi nghiệp vụ chưa có lời giải

> Nguyên văn mục *Unknowns* của `docs/product.md`, tách 2026-09-02 · DOC-1 · ADR-014.
> **Owner của mọi câu U-XXX.** Hợp đồng hình dạng (*Cách viết một câu ở đây*) giữ nguyên:
> `docs/decisions.md` **ADR-007** dựa vào nó. `scripts/brief.sh` còn đọc bản lưu cho tới
> khi DOC-2 trỏ nó sang file này.

<!-- ==== nguyên văn docs/product.md §Unknowns, tách 2026-09-02 ==== -->
## Unknowns

Câu hỏi nghiệp vụ chưa có lời giải. Không để việc thực hiện âm thầm quyết định thay.

`scripts/brief.sh` đọc mục này và in danh sách đang mở vào **mọi phiên mới**, nên hình dạng của
mục là một hợp đồng, không phải chuyện trình bày — cách viết ở
[Cách viết một câu ở đây](#cach-viet) bên dưới.

### Đang mở

**Ngày 2026-09-02 chủ quán trả lời BẢY câu, trong hai lượt, và cả bảy cùng một hình dạng: POS hoặc
chủ quán quyết theo tình hình thực tế, không có luật cứng.** Lượt một (T-042) đóng U-022, U-025 và
thay hai giả định rủi ro CAO; lượt hai (T-043) đóng **U-027** — đơn đã `Hoàn thành` cũng **huỷ
được** — và **U-030** — **không** mảng quản trị nào phải chạy cùng bản bán hàng đầu tiên.

**Ngày 2026-09-03, BA-13 mở lại đúng MỘT câu** — và nó mở vì hai mục **đã chốt** trả lời khác
nhau, không vì ai quên hỏi. Bảy câu mở ngày 2026-09-02 đều đã đóng trong ngày (T-042, T-043,
T-044). Chỗ chưa chắc còn lại **không** phải câu hỏi: cả năm **giả định** `docs/decisions.md` GĐ
đã bị **thay bằng quy tắc thật** ngày 2026-09-02 nên không mục nào còn hiệu lực, và một chỗ
**suy ra** ở `master_plan/shop-facts.md` §7.2 (**S-5**).

- **U-031 — với một đơn GIAO TẬN NƠI, ai bấm mốc *"đã ra bàn"* của từng việc trạm, và vào lúc
  nào?** Chủ quán chốt 2026-09-01 (U-021) rằng *người đứng quầy* bấm **cả hai** mốc của bảng bếp,
  nhưng câu hỏi lúc ấy **không nhắc tới ca đơn giao tận nơi**: lúc suất tới tay khách thì người
  có mặt là *nhân viên quán* đi giao, và `05-vong-doi.md` §5.2 đã giao cho chính người ấy hai nút
  *đã giao* + *đã thu tiền*. ⇒ Bảng §5.4 (*người đứng quầy*) và §3.2.2 + §5.2 (*người đi giao*)
  nay chỉ **hai người khác nhau** cho cùng một nút. **Ai trả lời được:** chủ quán.
  **Đang chặn:** §5.5 buộc **mọi** việc trạm phải ở `Đã ra bàn` **trước** khi đơn sang
  `Hoàn thành`, nên đọc sai chỗ này là **đơn giao tận nơi không bao giờ `Hoàn thành` được**, hoặc
  quầy bấm khống một mốc cho một suất đang ở nhà khách. Chặn phiên System Design dựng màn quầy và
  màn người đi giao. **Đừng suy hộ** (CLAUDE.md §3.5) — chỗ này chạm mốc thu tiền.
  *Mở 2026-09-03 · BA-13 · `work/findings.md` F-022 chỗ 2.*

Câu tiếp theo vào đây dưới dạng một gạch đầu dòng, đúng hợp đồng dưới; mục này rỗng cũng là trạng
thái bình thường, không phải dấu hiệu quên ghi.

Hình dạng của mục là hợp đồng với `scripts/brief.sh` (ADR-007): **mỗi** câu trên là **một gạch đầu
dòng**, và câu tiếp theo cũng phải vào đây dưới dạng ấy. `master_plan/shop-facts.md` §7.2 — chỗ giữ
các mục **suy ra** chưa xác nhận — giữ **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị nào); đó là chỗ
**suy ra**, không phải câu hỏi đang mở, nên nó không nằm ở đây.

<a id="cach-viet"></a>
### Cách viết một câu ở đây

Hợp đồng giữa mục này và `scripts/brief.sh` (T-021 · `docs/decisions.md` ADR-007 ·
`work/findings.md` F-008). Mục này nằm dưới tiêu đề `###` của riêng nó nên brief **không** đọc —
vì thế mấy ví dụ dưới đây viết `U-` thoải mái mà không bị in ra như câu đang mở.

- **Vùng đang mở** = phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối nằm dưới một
  tiêu đề `### Đang mở`. Mọi thứ dưới một tiêu đề `###` khác đều không được đọc.
- **Trong vùng đang mở, một gạch đầu dòng là một unknown đang mở.** Định danh `U-XXX` được tìm ở
  bất cứ đâu trong gạch đầu dòng, nên in đậm chỗ nào cũng được và vắt dòng thoải mái.
- **Văn xuôi trong vùng đang mở không sinh ra unknown.** Muốn nhắc tới một câu mà không mở nó thì
  viết thành câu văn, đừng gạch đầu dòng.
- Trả lời xong một câu thì **chuyển gạch đầu dòng ấy xuống mục đã có lời giải**, đừng chỉ gạch
  ngang tại chỗ.

<a id="da-co-loi-giai"></a>
### Đã có lời giải — không ghi lại thành Unknown nữa

**Ngày 2026-09-01, chủ quán trả lời ba câu BA-07 vừa mở, và cả ba ra cùng MỘT chỗ đứng: POS**
(T-039). Đây là lần thứ tư cùng một câu trả lời lặp lại — duyệt đơn (§6.2), huỷ đơn (§6.13), hoàn
tiền (§6.4), ghép bàn (§6.16), thu tiền, ghi nợ (§6.14) và nay cả hai mốc của bảng bếp đều đi qua
đúng **một** cái máy ở quầy.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-021 — ai nói cho máy biết một mẻ đã bưng ra bàn~~ | **POS** — người đứng quầy bấm, đúng chỗ đứng đã bấm *"đã làm xong"*; ba trạm bếp vẫn không bấm gì (U-009 nguyên vẹn) | `shop-facts.md` §5.4 · §5.4 trên đây |
| ~~U-023 — ai bấm cho đơn giao tận nơi sang *đang giao*, lúc nào~~ | **POS**, lúc đơn **rời quán**; mốc **ra** vẫn do *người đi giao* bấm cùng lúc với *đã thu tiền* | `shop-facts.md` §6.7 · §5.2 trên đây |
| ~~U-024 — bấm nhầm *đã làm xong* một mẻ thì có đường lùi không~~ | **Có đường lùi**, và **không có mốc thời gian cứng** — *"tuỳ theo thực tế để POS quyết định"* | `shop-facts.md` §5.4 · §5.4 và §5.6 trên đây |

**Ngày 2026-09-02, chủ quán trả lời bốn câu một lúc, và cả bốn ra cùng MỘT câu trả lời: POS quyết
theo tình hình thực tế** (T-042). Đây là lần thứ năm cùng một hình dạng lặp lại — sau hoàn tiền
(§4.8) và đường lùi một mẻ (§5.4). ⇒ **Đó là một luật về cách quán vận hành, không phải bốn chỗ
tài liệu còn thiếu:** chủ quán cố ý **không** dựng hàng rào cho máy ở những chỗ này, và sản phẩm
không được tự dựng hộ.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-02) | Ghi ở |
|---|---|---|
| ~~U-022 — sửa một đơn được phép tới trạng thái nào~~ | **Bất kỳ trạng thái nào**, POS quyết theo tình hình thực tế — kể cả đơn đã `Hoàn thành`. *Vế **huỷ** không được chạm tới ⇒ **U-027**; vế **giá của dòng vừa sửa** ⇒ **U-026**.* | `shop-facts.md` §6.19 · §5.2, §5.6 và §6 dòng 13 trên đây |
| ~~U-025 — ai giữ sổ giấy, ghi gì, nhập lại lúc nào~~ | **POS hoặc chủ quán** giữ và nhập; **nhập ngay khi có thể**, không có mốc giờ cứng; có điện lại giữa buổi thì làm tiếp trên hệ thống, ghi tay cập nhật sau | `shop-facts.md` §6.11 · §6 dòng 11–12 trên đây |
| ~~GĐ-02 — món hết sau khi khách đã chọn~~ | **POS bàn với khách**, quyết tại lúc thoả thuận xong — không tự thay thế, không tự huỷ. Đóng **câu 3** bảng mười câu hỏi | `shop-facts.md` §6.20 · §6 dòng 5 và §6.3 trên đây |
| ~~GĐ-03 — khách nói đã chuyển khoản mà chưa thấy báo có~~ | **POS bàn với khách**, quyết ngay lúc đó; hai đường ra đã có sẵn — ghi **nợ** (§4.7) hoặc **chờ tin nhắn** (§4.6) | `shop-facts.md` §6.21 · §6 dòng 9 trên đây |
| ~~U-027 — đơn đã `Hoàn thành` thì có huỷ được không~~ | **Huỷ được**, POS quyết trong thực tế — *"có thể huỷ được, để POS quyết định trong thực tế"*. Bảng §5.2 có thêm dòng `Hoàn thành → Huỷ`; §5.6 mất ca thứ hai | `shop-facts.md` §6.19 · §5.2, §5.6 và §6 dòng 13 trên đây |
| ~~U-030 — mảng quản trị nào phải có ở bản chạy đầu tiên~~ | **Không mảng nào** — *"bán hàng xong chạy được thì để chạy trước"*. Là quyết định về **thứ tự**, không phải loại bỏ: ranh giới §1.6 vẫn mở | §7.6 trên đây · `shop-facts.md` §7.1 (ngày chốt) |
| ~~U-026 — một dòng vừa sửa thì tính giá lúc nào~~ | **Giá đang hiệu lực LÚC SỬA** — sửa một dòng là **đặt lại mốc khoá giá** của chính dòng ấy. Ngoại lệ có chủ ý của §4.4: một lần đổi giá vẫn không tự với ngược vào dòng cũ | `shop-facts.md` §6.19 · §4.4, §5.2 và §6 dòng 13 trên đây |

Ngày **2026-08-31** chủ quán trả lời một loạt sáu câu (T-028). Một câu thứ bảy — U-006 — chỉ được
trả lời **một nửa**, nên nó ở lại mục *Đang mở* với phạm vi hẹp hơn.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-31) | Ghi ở |
|---|---|---|
| ~~U-005 — đơn trả trước trả bằng gì, ai xác nhận, lúc nào~~ | **Tiền mặt hoặc VietQR** — không có phương thức thứ ba; **POS xác nhận vào lúc nhận tiền**, không phải lúc khách bấm chọn trả trước | `shop-facts.md` §6.3 |
| ~~U-007 — khách rời quán chưa trả tiền thì ai đóng phiên~~ | **Quán cho nợ.** Quầy vẫn đóng phiên, và lúc đóng POS **bắt buộc ghi ai nợ, nợ bao nhiêu** | §3.1.6 · `shop-facts.md` §6.14 |
| ~~U-008 — một nồi làm được bao nhiêu, trứng và bánh có tranh nhau nồi không~~ | **2 nồi.** Một nồi một lần tráng làm được **3 trứng**, *hoặc* **2 bánh**, *hoặc* **1 trứng + 1 bánh** ⇒ trứng và bánh **tranh nhau cùng một nồi** | `shop-facts.md` §5.4 |
| ~~U-009 — ai bấm "đã làm xong" / "đã bưng ra bàn"~~ | **Bỏ bước ấy đi.** Không có nút bấm nào ở trạm bếp; **POS tự cập nhật** số đã làm cho từng bàn | `shop-facts.md` §5.4 |
| ~~U-010 — đơn mang đi có chung bảng gom việc với bàn không~~ | **Không.** Nhưng khách **đang ngồi bàn** gọi suất đem về thì suất ấy thuộc **phiên bàn**, kèm note **"đem về"** phải rõ ràng | §2.1 · §3.1.4 · `shop-facts.md` §6.15 |
| ~~U-011 — máy có được tự chia mẻ không~~ | **Không.** Hệ thống **chỉ hiện tổng nhu cầu** để người tự gom — *"máy không làm, để người làm"* | §1.4 · `shop-facts.md` §5.4 |
| ~~U-006 — ghép bàn thì hệ thống phải làm gì~~ | **MỘT phiên và MỘT hoá đơn.** Một phiên gắn được nhiều bàn; *"một bàn một phiên"* đọc lại thành *"một bàn thuộc nhiều nhất một phiên"* | §3.1.7 · `shop-facts.md` §6.16 |

U-006 đi hai nhịp trong cùng ngày: sáng chỉ chốt được *ghép bàn là chuyện có thật*, chiều chốt nốt
*một phiên, một hoá đơn*. Nhịp thứ hai làm lộ ra **U-013**, và U-013 được trả lời nốt trong cùng
ngày (bảng dưới) — ca *ghép hai bàn đều đang có phiên* bị **đóng bằng quyết định**: không ghép
được, nên không bao giờ có việc gộp hai hoá đơn.

Ngày **2026-08-30** chủ quán trả lời hết ba unknown mở ở BA-01, cả ba chỗ suy luận S-1–S-3,
và cả câu U-004 sinh ra từ chính lời giải của U-003.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-30) | Ghi ở |
|---|---|---|
| ~~U-001 — nhân viên có phân vai theo trạm không~~ | **Có.** Quầy · tráng bánh · gấp bánh là ba trạm riêng; lấy canh và dọn bàn **chung một người** | §1.5 · `shop-facts.md` §3 |
| ~~U-002 — chủ quán có là nhân viên không~~ | **Thỉnh thoảng đứng quầy**, vẫn giữ vai chủ quán | §1.3 · `shop-facts.md` §3 |
| ~~U-003 — đơn hotline rồi khách tới ăn tại quán~~ | **Huỷ đơn đặt trước**, khách quét QR gọi lại | §2.4 · `shop-facts.md` §2 |
| ~~S-1 — phụ thu suất trứng ×5 hay ×4~~ | **×5** — quả trứng cũng lên giá theo nhân, suất trứng nhân thường = **25.000** | `shop-facts.md` §4.3 · §4.6 |
| ~~S-2 — hai trường liên hệ bắt buộc~~ | **Đúng**, số điện thoại và địa chỉ giao là bắt buộc | §2 · `shop-facts.md` §6.5 |
| ~~S-3 — ai ghi vết mỗi lần hoàn tiền~~ | **Người đứng quầy** vừa quyết định vừa ghi vết | `shop-facts.md` §6.4 |
| ~~U-004 — ai được bấm huỷ một đơn~~ | **Chỉ người đứng quầy**, bấm trên máy POS ở quầy; chủ quán không đứng quầy thì **nhờ người đứng quầy bấm** | §2.4 · `shop-facts.md` §6.13 |

Câu cũ hơn, đã đóng từ trước:

- ~~Đơn đặt trước qua hotline gắn vào bàn nào~~ → là **kênh thứ năm, không gắn bàn**
  (chủ quán chốt 2026-08-29, `shop-facts.md` §2).
- ~~Khách quét QR có phải khai định danh không~~ → **ẩn danh theo số bàn**; **cả ba kênh không
  gắn bàn** — Delivery, Pickup và đặt trước qua hotline — bắt buộc số điện thoại
  (`shop-facts.md` §2, §6.5).

Ngày **2026-08-31**, hai câu cuối cùng đóng nốt:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-08-31) | Ghi ở |
|---|---|---|
| ~~U-012 — nợ trả sau thì ai ghi nhận, doanh thu tính ngày nợ hay ngày trả~~ | **POS ghi nhận**; doanh thu tính vào **ngày ghi nợ**, không phải ngày thu được tiền | §3.1.6 · `shop-facts.md` §6.14 |
| ~~U-013 — ai được bấm ghép bàn, ghép được khi bàn kia đang mở không~~ | **Người đứng quầy bấm trên POS**; **chỉ ghép được khi bàn kia còn trống** | §3.1.7 · `shop-facts.md` §6.16 |

Lời giải U-013 đóng luôn ca đáng sợ nhất mà câu hỏi ấy mở ra: **không bao giờ có việc gộp hai hoá
đơn đã có tiền trong đó.** Ghép bàn chỉ là nới một phiên sang bàn trống.

Ngày **2026-09-01**, ba câu BA-05 vừa mở được trả lời hết trong lượt kế tiếp (T-034):

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-014 — chủ quán có được lưu thay đổi giá ngay giữa giờ bán không~~ | **Được** — *"không phải chờ đến hết buổi"*; hiệu lực từ lúc lưu | §3.3.1 · `shop-facts.md` §6.17 |
| ~~U-015 — phiên bàn đang mở vắt qua mốc đổi giá thì hoá đơn ra sao~~ | **Lượt gọi trước mốc giữ giá cũ, lượt gọi sau mốc áp giá mới** ⇒ một hoá đơn mang **hai mức giá**, và như thế là đúng | §3.3.6 · `shop-facts.md` §6.17 |
| ~~U-016 — có được đổi thành phần một suất trong lúc đang bán không~~ | **Không — phải chờ hết buổi bán.** Khác hẳn ba chiều tiền | §3.3.2 · `shop-facts.md` §4.5 · §6.17 |

Ba câu ra **hai** luật, không phải một: chiều **tiền** sửa lúc nào cũng được, chiều **thành phần
suất** phải chờ. §3.3.2 giữ ranh giới đó trong một bảng; nhớ nó thành một mốc duy nhất là làm sai
đúng chiều đắt nhất.

Cuối ngày **2026-09-01**, hai câu cuối — mỗi câu do một phiên mở — được trả lời nốt trong cùng một
lượt (T-037):

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-01) | Ghi ở |
|---|---|---|
| ~~U-017 — bấm "đã làm xong" theo từng cái, cả mẻ, hay cả bàn~~ | **Theo MẺ** — một lần bấm ứng với một mẻ bếp vừa làm xong | §1.2 · `shop-facts.md` §5.4 |
| ~~U-018 — máy chặn hẳn hay chỉ nhắc khi sửa thành phần suất giữa giờ bán~~ | **Chỉ nhắc một câu, rồi vẫn cho lưu** — luật *"chờ hết buổi"* là luật cho **người** | §3.3.6 · `shop-facts.md` §6.17 |
| ~~U-019 — buổi tối lấy gì đối chiếu phần khách chuyển khoản~~ | **Tin nhắn báo có** — nguồn thứ **ba** của đối soát, đứng cạnh sổ giấy và tiền trong két; ⇒ đối soát chia theo **phương thức**, không cộng gộp | §4.9 · `shop-facts.md` §6.10 |
| ~~U-019 (vế 2) — một lần hoàn tiền trừ vào doanh thu ngày nào~~ | **Ngày HOÀN**, không phải ngày bán gốc — **ngược chiều** với luật nợ (nợ tính ngày ghi nợ) ⇒ doanh thu một ngày đã đối soát không bao giờ đổi về sau | §4.8 · §4.10 · `shop-facts.md` §6.4 |
| ~~U-020 — khách trả một phần tiền mặt, một phần chuyển khoản~~ | **Nhận cả hai.** POS ghi **bao nhiêu tiền mặt, bao nhiêu chuyển khoản**; tổng các phần = số phải trả. Chữ *"hoặc"* ở `shop-facts.md` §1 là lựa chọn của khách, **không** phải luật loại trừ | §4.6 · `shop-facts.md` §6.18 |

Lời giải U-018 buộc **viết lại `quality/invariants.md` I-011**: bản đầu nói *"thành phần suất không
đổi trong giờ bán"*, và câu đó sai kể từ lúc biết máy không chặn. Thứ sản phẩm giữ được là chuyện
đó không xảy ra **âm thầm** — nhắc trước, để vết sau. Một invariant hệ thống không giữ nổi thì
không phải invariant.

`master_plan/shop-facts.md` §7.2 — chỗ giữ các mục **suy ra chưa xác nhận** — rỗng từ
2026-08-30 tới 2026-08-31, rồi giữ đúng một mục **S-4** từ 2026-08-31, và **rỗng trở lại từ
2026-09-01** khi S-4 có lời giải. Tài liệu nào còn nói "ba chỗ suy luận chưa ai xác nhận", hay
"§7.2 giữ S-4", là pointer cũ. S-4 nằm ở §7.2 chứ không nằm ở đây vì nó là **chỗ suy ra**, không
phải câu chưa ai hỏi (`work/findings.md` F-004).

**S-4 đã đóng ngày 2026-09-01, sau khi hỏi hai lần.** Lần đầu (2026-08-31) chủ quán trả lời
*"tôi không hiểu"*: câu hỏi cũ bắt chủ quán suy ra hộ *một bảng trong máy nên hiện con số nào* —
một câu về mô hình dữ liệu, không phải về cái quán, tức **lỗi của người hỏi**. Câu viết lại hỏi về
**cái quán** — *từ lúc bánh tráng xong đến lúc nó xuống bàn, có nằm chờ không* — và được trả lời
ngay: **có**, vì chờ đủ đĩa, chờ người rảnh tay bưng, chờ món khác của cùng bàn. Câu thứ hai —
*ai nói cho máy biết món đã xong* — trả lời: **người đứng quầy bấm**. Cả hai ghi ở
`shop-facts.md` §5.4 và §7.1; bài học về cách hỏi ở lại §7.2. Lời giải này mở ra **U-017** ở trên
(bấm theo từng cái hay cả mẻ).
