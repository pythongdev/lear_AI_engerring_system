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

**Cùng ngày 2026-09-03, T-048 mở thêm một câu — U-032 — trong lúc viết kế hoạch pha 1.** Nó không
mở vì ai quên hỏi: ba luật *doanh thu tính ngày nào* đã chốt (nợ · hoàn · sổ giấy) đều đi qua ca
**lượt bán nằm trên sổ giấy qua đêm** mà không luật nào phủ được nó. Mục này vì thế đang giữ **hai**
câu tính tới cuối ngày 2026-09-03 — con số ấy là phép đếm của người viết, không phải một quyết định
(`work/findings.md` **F-003**); đếm lại ở danh sách dưới, đừng tin câu này.

**Ngày 2026-09-04, T-050 mở U-034 trong lúc chuyển một lời chốt về owner.** Chủ quán chốt mảng
nguyên liệu ở mức *sổ ghi tay điện tử* và kèm theo một mục nhập tổng hàng ngày; lời chốt nói **ai
nhập** và **nhịp nào**, nhưng không nói **nhập con số gì**. Chỗ hở ấy không được lấp bằng suy luận
vì một trong ba đường ra sẽ lật ngược chính lời chốt vừa nói.

**Ngày 2026-09-04, chủ quán trả lời HAI câu trong một lượt — `U-032` và `U-035`** (T-054), và cả
hai đều đi cùng một hướng: **quán không dừng bán, nhưng máy không được nhận cái mà quán không nhìn
thấy.** `U-035` — mở cùng ngày bởi P1-02 — đóng bằng *"không cho đặt qua web"*; `U-032` — mở
2026-09-03 bởi T-048 — đóng bằng đúng một từ: *"bán"*. Lời thứ hai mở ra **U-037** ngay dưới: nó
làm doanh thu của một ngày **đã đối soát** đổi được về sau, nên phải có người ngồi lại với con số
ấy (`docs/decisions.md` **ADR-037**).

**Cùng ngày 2026-09-04, chủ quán đóng `U-031` và trả lời MỘT NỬA `U-034`** (T-055). `U-031` đóng
bằng đúng một từ — *"pos"*: **không** có ngoại lệ cho đơn giao tận nơi. Vế **lúc nào** POS bấm thì
lời ấy không nói, nên nó đi vào `master_plan/shop-facts.md` §7.2 thành **S-6** — chỗ **suy ra**,
không phải lời chốt (`work/findings.md` **F-004**). `U-034` thì **ở lại đây với phạm vi hẹp hơn**:
chủ quán nói *"tuỳ từng nguyên liệu"*, tức bỏ chính giả định của câu hỏi gốc — mục tổng **không**
có một loại con số dùng chung — nhưng chưa thứ nào trong danh mục biết mình mang loại nào.

**Cùng ngày 2026-09-04, P1-03 mở U-036 trong lúc định nghĩa *một ngày bán*.** Nó cũng không mở vì
ai quên hỏi: `shop-facts.md` §6.14 chốt chiều tiền về **sau** một lần bán đã xong (nợ ⇒ ngày ghi
nợ), và không lời chốt nào phủ chiều ngược lại — tiền về **trước** một lần bán chưa xong. Chừng nào
hai mốc ấy còn có thể rơi vào hai ngày khác nhau, bảng §2 của
`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` còn một hàng để trống.

- **U-033 — một đơn bị HUỶ sau khi bếp đã làm xong phần của nó: chỗ bánh ấy có được tính cho một
  bàn khác đang chờ cùng thứ, hay quán bỏ nó và làm lại từ đầu?** Câu này chạm thẳng con số
  **nhu cầu** của §3.4: nếu chỗ đã làm ấy dùng lại được thì nhu cầu của **bàn khác** phải tụt
  xuống ngay lúc đơn kia bị huỷ — tức một thao tác ở quầy làm đổi con số của một bàn không liên
  quan. Ba luật quanh nó đều đã chốt mà không luật nào phủ được nó: đơn `Huỷ` rút **việc chưa
  làm** khỏi bảng bếp (`shop-facts.md` §6.13, `05-vong-doi.md` §5.4) · quầy được huỷ đơn ở **mọi**
  trạng thái, kể cả `Hoàn thành` (§6.19, đóng U-027) · và bảng ở quầy đếm *đã làm xong, còn ở bếp*
  thành một con số riêng (§5.4, đóng S-4) — nhưng **không** chỗ nào nói con số ấy đi đâu khi chủ
  của nó biến mất. **Ai trả lời được:** chủ quán. **Đang chặn:** `03-lat-cat.md` §3.4.5 đang chạy
  bằng phương án **hẹp nhất** viết thẳng ra — *đã làm xong của bàn bị huỷ về không, nhu cầu mọi
  bàn khác không đổi* — và phương án hẹp ấy có thể đúng là thứ quán **không** làm; pha 1 cũng
  không tính được hao hụt nếu chưa biết chỗ bánh ấy đi đâu.
  **Cách hỏi** (bài học S-4, `master_plan/shop-facts.md` §7.2 — hỏi về cái quán, đừng hỏi về cái
  bảng trong máy): *"Bàn 5 huỷ đúng lúc bếp vừa tráng xong bánh của họ, mà bàn 8 đang chờ đúng
  loại bánh ấy. Ở quán, chỗ bánh đó đi đâu?"*
  *Mở 2026-09-03 · BA-12 · `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4.5.*

- **U-034 — mục *tổng lưu trữ hàng ngày* ghi con số gì cho TỪNG THỨ trong danh mục: đồ còn lại
  cuối buổi, đồ mua vào trong ngày, hay đồ đã dùng trong ngày?** *Thu hẹp 2026-09-04 (T-055), sau
  khi chủ quán trả lời một nửa.* Câu gốc hỏi **một** con số cho cả mục; lời chủ quán bỏ đúng giả
  định ấy — *"tuỳ từng nguyên liệu"* ⇒ mục tổng **không** có một loại số dùng chung, mỗi thứ trong
  danh mục mang loại của riêng nó. Phần còn mở vì thế là **thứ nào mang loại nào**, và nó không nhỏ
  đi: chưa thứ nào có lời. Ba đường ra vẫn khác hẳn nhau — *còn lại* là một lần đếm cuối buổi ·
  *mua vào* là một phiếu nhập có giá và có người bán · *đã dùng* là con số duy nhất **không** đếm
  được bằng mắt ở mức sổ tay, vì muốn có nó thì phải trừ theo công thức, đúng thứ lời chốt §8.4 nói
  máy **không** làm.
  **Cùng lượt ấy chủ quán kể ra danh mục, và nó rộng hơn hai chữ *nguyên liệu*** — ba nhóm nằm
  chung một mục: **thực phẩm** (gạo · xương · mì chính · hạt nêm · rau…), **vật tư tiêu hao và bao
  bì** (găng tay · cốc và nắp đựng canh · hộp đựng bánh cuốn · túi · khăn lau bàn · giấy ăn), và
  **số điện · số nước** — nhóm thứ ba là **chỉ số công tơ**, không phải hàng có tồn, nên nó không
  nhận được cả ba đường ra ở trên. Nguyên văn, giữ ở đây vì nó **chưa** được chép vào
  `master_plan/shop-facts.md`: *"tuỳ từng nguyên liệu tôi sẽ tự nhập các nguyên liệu gồm gạo theo
  kg, xương theo kg , mì chính theo goi hat nêm găng tay , số điện số nước, ra mùi tau , quát ,
  cốc đụng canh nắp đựng cacnh , hộp đựng bánh cuốn túi chư T, túi z về cơ khăn lau bạn giấy ăn
  về c"*. Câu ấy **đứt giữa chừng** và sai chính tả nhiều chỗ, nên đưa nó vào owner là dựng một dữ
  kiện quán chưa ai đọc lại (`CLAUDE.md` §3.5 · §7.2, `work/findings.md` **F-001**): danh mục chỉ
  lên `shop-facts.md` §8 sau khi chủ quán xác nhận lại **từng dòng** và **đơn vị tính** của nó.
  **Ai trả lời được:** chủ quán. **Đang chặn:** `work/backlog_AD.md` nhánh B (**ADM-10** danh mục
  và đơn vị tính · **ADM-11** phiếu nhập · **ADM-12** ghi hao hụt · **ADM-13** tồn ước tính và
  nhắc sắp hết) — cả bốn đều phải biết con số nền của từng thứ trước khi có hình dạng, và đường
  *đã dùng* còn lật ngược chính mức sổ tay của §8.4.
  **Đừng suy hộ** (`CLAUDE.md` §3.5): đây là dữ kiện quán, không phải chỗ để phần mềm tự chọn — và
  *"tuỳ từng nguyên liệu"* làm chỗ suy hộ **rẻ hơn** chứ không đắt hơn, vì nay chỉ cần đoán sai một
  dòng là sai một dòng, không ai thấy.
  **Cách hỏi** (bài học S-4, `master_plan/shop-facts.md` §7.2 — hỏi về cái quán, đừng hỏi về cái
  bảng trong máy), nay hỏi **theo từng thứ**, không hỏi một câu chung: *"Cuối buổi anh ngồi xuống
  nhập. Với gạo, anh nhập số cân còn lại trong thùng, hay số cân anh mua sáng nay? Với găng tay
  thì anh nhập số nào? Còn số điện số nước — anh chép chỉ số trên công tơ, đúng không?"*
  *Mở 2026-09-04 · T-050 · thu hẹp cùng ngày · T-055 · `master_plan/shop-facts.md` §8.4.*

- **U-037 — hôm sau nhập bù xong chỗ bán trên sổ giấy, AI ngồi lại đối soát ngày mất điện một lần
  nữa, và lúc nào?** Ngày 2026-09-04 chủ quán chốt lượt bán trên giấy tính doanh thu **ngày quán
  bán** (`master_plan/shop-facts.md` §6.11, trả lời `U-032`). Hệ quả bắt buộc, đã ghi thành
  `docs/decisions.md` **ADR-037**: **một ngày còn lượt chưa nhập là một ngày chưa đối soát xong**,
  nên khi `N` về 0 thì con số của ngày ấy đổi và **phải có người chấm lại nó** — nếu không thì
  ngưỡng lệch **0đ** (§6.10) chỉ được chạy trên một con số mà ai cũng biết là chưa đủ. Lời chốt nói
  **doanh thu rơi vào ngày nào**; nó **không** nói ai chấm lại và lúc nào. **Ai trả lời được:** chủ
  quán. **Đang chặn:** `quality/invariants.md` **I-014** (kịch bản *nhập bù* mới thêm nói ngày ấy
  *"mới đối soát xong"* mà chưa nói ai làm việc ấy) · **P1-04** (bảng ba cột nhóm TIỀN — ô *phép đối
  chiếu* của `I-014`) · và màn đối soát ở `docs/product/1-system-design/architecture.md` §6.4.
  **Đừng suy hộ** (`CLAUDE.md` §3.5): chỗ này quyết một ngày tiền được coi là đã chốt hay chưa.
  **Cách hỏi** (bài học S-4, `master_plan/shop-facts.md` §7.2 — hỏi về cái quán, đừng hỏi về cái
  bảng trong máy): *"Tối hôm mất điện anh đối soát rồi, nhưng còn 30 suất trên giấy chưa gõ. Sáng
  hôm sau gõ xong, anh có ngồi xuống soát lại tiền của hôm mất điện một lần nữa không, hay thôi?"*
  *Mở 2026-09-04 · T-054 · `docs/decisions.md` **ADR-037**.*

Câu tiếp theo vào đây dưới dạng một gạch đầu dòng, đúng hợp đồng dưới; mục này rỗng cũng là trạng
thái bình thường, không phải dấu hiệu quên ghi.

Hình dạng của mục là hợp đồng với `scripts/brief.sh` (ADR-007): **mỗi** câu trên là **một gạch đầu
dòng**, và câu tiếp theo cũng phải vào đây dưới dạng ấy. `master_plan/shop-facts.md` §7.2 — chỗ giữ
các mục **suy ra** chưa xác nhận — giữ **S-5** (bấm *"đã bưng ra bàn"* theo đơn vị nào); đó là chỗ
- **U-036 — một khoản khách TRẢ TRƯỚC mà quán nhận hôm nay, cho đơn giao vào một ngày khác, thì
  doanh thu tính vào ngày nào: ngày quán nhận tiền, hay ngày quán giao hàng?** Và trước đó một
  bước: **quán có nhận đơn đặt trước cho một ngày sau không?** `shop-facts.md` §6.3 cho khách của
  cả ba kênh mang đi chọn **trả trước**, và chốt rằng POS xác nhận *"vào lúc tiền thật sự tới tay
  quán"*; §5.2 điểm 5 nói `pickup` có **giờ hẹn lấy** và `phone_preorder` là **đơn đặt trước** —
  không câu nào buộc giờ hẹn ấy nằm trong cùng ngày. **Đây là chiều NGƯỢC của §6.14.** Luật nợ chốt
  ca tiền về **sau** một lần bán đã xong (⇒ ngày ghi nợ, `shop-facts.md` §6.14); ca tiền về
  **trước** một lần bán chưa xong thì chưa ai chốt, và luật hoàn ở §6.4 cũng không phủ nó.
  **Ai trả lời được:** chủ quán. **Đang chặn:** hàng cuối bảng §2 của
  `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` (**P1-03**), và qua đó cột *phép đối
  chiếu* của `I-014` ở **P1-04**. **Vì sao không được suy hộ** (`CLAUDE.md` §3.5): cả hai đường ra
  đều động vào cùng thứ mà `U-032` đang đe doạ. Tính doanh thu về **ngày giao hàng** thì ngày nhận
  tiền có tiền trong két mà không có doanh thu ⇒ ngưỡng lệch **0đ** (§6.10) báo lệch, trừ khi công
  thức đối soát `architecture.md` §6.4 mọc thêm một dòng — mà thêm dòng vào cổng chất lượng mạnh
  nhất của dự án là quyết định của chủ quán, không phải của pha 1. Tính về **ngày nhận tiền** thì
  doanh thu được ghi cho một bữa ăn **chưa bán**, và một lần huỷ hôm sau (§6.3 ⇒ hoàn theo §6.4,
  rơi vào ngày hoàn) để lại doanh thu ảo ở ngày trước đó.
  **Cách hỏi** (bài học S-4, `shop-facts.md` §7.2 — hỏi về cái quán, đừng hỏi về cái bảng trong
  máy): *"Có khách nào gọi điện tối nay đặt bánh cho sáng mai, và trả tiền luôn tối nay không? Nếu
  có, khi anh xem doanh thu, anh muốn tiền ấy nằm ở ngày anh nhận tiền hay ngày anh đưa bánh?"*
  *Mở 2026-09-04 · P1-03 · `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §4.*

- **U-038 — tiền đầu két nhập vào máy là MỘT con số tổng, hay một bảng theo TỪNG MỆNH GIÁ?** Chủ
  quán ngày 2026-09-04 (`A3`) kể ra mệnh giá — *"khoảng 1 triệu tiêng 50k, 20k, 10k. 100k tiền 5k,
  100k tiêng 2k và 1k"* — nhưng nói **"để số cố định"** ở **số ít**. Hai cách đọc, và chúng không
  cùng một hệ thống. **Ai trả lời được:** chủ quán. **Đang chặn:** `master_plan/shop-facts.md`
  §8.5, `quality/invariants.md` **I-021** (phép trừ tiền đầu két khỏi tiền két), và
  `work/backlog_AD.md` **ADM-41** · **ADM-44**. **Vì sao không được suy hộ** (`CLAUDE.md` §3.5):
  đây là câu quyết định **cách đếm cuối ngày ở ngưỡng 0đ** (§6.10). Một **số tổng** thì cuối ngày
  người đếm chỉ cần một con số, và một tờ 50k đổi thành năm tờ 10k trong buổi **không** làm lệch gì.
  Một **bảng theo mệnh giá** thì cuối ngày phải đếm từng mệnh giá, và đúng lần đổi tiền thối ấy làm
  bảng lệch trong khi tổng vẫn khớp — tức ngưỡng 0đ báo đỏ ở một ca **không phải mất tiền**. Chọn
  sai đường thì cổng chất lượng mạnh nhất của dự án kêu oan mỗi ngày, và người dùng học cách bỏ qua
  nó. **Cách hỏi** (bài học S-4 — hỏi về cái quán): *"Tối đếm két, anh đếm một lượt ra tổng bao
  nhiêu, hay anh đếm riêng từng loại tờ 50, tờ 20, tờ 10?"*
  *Mở 2026-09-04 · T-056 · `master_plan/shop-facts.md` §8.5.*

- **U-039 — quán có muốn MÁY giữ hàng chờ bàn không, và ai nhớ ai tới trước?** Câu `A8` hỏi ba vế;
  chủ quán ngày 2026-09-04 trả lời **một** vế — *"có khách đứng chờ, xếp hàng chờ"* — tức hàng chờ
  **có thật ngoài đời**. Hai vế còn lại chưa có lời: **máy có giữ nó không**, và **ai là người nhớ
  thứ tự**. **Ai trả lời được:** chủ quán. **Đang chặn:** `work/backlog_AD.md` **ADM-03**, và vế
  *"còn mấy bàn trống"* của **ADM-04**. **Vì sao không được suy hộ:** hai đường ra là hai hệ thống
  khác nhau, không phải hai mức chi tiết của một hệ thống. **Máy không giữ** thì hàng chờ không tồn
  tại trong dữ liệu và §6.24 (*ai tới trước ăn trước*) chỉ áp cho khách **đã ngồi**. **Máy giữ**
  thì sinh ra một khái niệm mới — *khách chưa có bàn* — đứng trước cả phiên bàn, thứ
  `architecture.md` §3.1 gọi là *"chỗ dễ mất tiền nhất"*, và nó phải có luật cho ca khách bỏ đi.
  **Cách hỏi:** *"Lúc đông, có ai ghi lại thứ tự người đứng chờ không, hay mọi người tự nhớ? Anh có
  muốn máy nhắc anh ai tới trước không?"*
  *Mở 2026-09-04 · T-056 · `master_plan/shop-facts.md` §6.25.*

- **U-040 — mười một cái bàn ấy mỗi cái mấy CHỖ NGỒI, và đã ĐÁNH SỐ sẵn chưa?** Câu `A7` hỏi ba
  vế; chủ quán ngày 2026-09-04 trả lời đúng **vế đã có chủ** — *"quán có 11 bàn"*, con số đã nằm ở
  `master_plan/shop-facts.md` §1 từ **2026-08-30**. Hai vế còn sống thì không. **Ai trả lời được:**
  chủ quán. **Đang chặn:** `work/backlog_AD.md` **ADM-03** (sức chứa), và **`docs/decisions.md`
  ADR-027** — luật *một phiên, một hoá đơn, chỉ ghép sang bàn **trống*** cần gọi tên được **từng**
  bàn, mà **một con số 11 không phải một danh sách bàn**. **Vì sao không được suy hộ:** đánh số
  1…11 hộ chủ quán là dựng một dữ kiện quán chưa ai xác nhận — quán có thể đang gọi bàn theo chỗ
  (*bàn trong*, *bàn ngoài hiên*), và một cái tên sai thì người đứng quầy gõ sai bàn, tức món bưng
  sai chỗ. **Cách hỏi:** *"Anh gọi các bàn là gì — bàn 1 bàn 2, hay bàn trong bàn ngoài? Mỗi bàn
  ngồi được mấy người?"*
  *Mở 2026-09-04 · T-056 · `master_plan/shop-facts.md` §6.25 · §1.*

- **U-041 — mục tổng quan bày *"còn thiếu gì không"*: thiếu NGUYÊN LIỆU, thiếu NGƯỜI, hay thiếu
  MÓN trên menu?** Chủ quán ngày 2026-09-04 (`A10`) kết câu trả lời bằng đúng bốn chữ ấy và không
  nói thêm. **Ai trả lời được:** chủ quán. **Đang chặn:** `master_plan/shop-facts.md` §8.6 (vế thứ
  bảy của mục tổng quan) và `work/backlog_AD.md` **ADM-04**. **Vì sao không được suy hộ:** đường
  *nguyên liệu* đụng thẳng mức **sổ ghi tay điện tử** đã chốt ở §8.4 — máy **không** tự trừ tồn
  theo công thức, nên máy **không tự biết** cái gì sắp hết; trả lời được vế ấy thì hoặc phải lật
  ngược §8.4, hoặc phải có một ngưỡng người tự nhập. Đường *người* thì đứng trên câu **C36** (*ai
  đang trực trạm nào*), thứ chưa dữ liệu nào ghi. Ba đường ra là ba mục khác hẳn nhau.
  **Cách hỏi:** *"Lúc anh nhìn điện thoại mà thấy «còn thiếu» thì anh đang lo thiếu cái gì — thiếu
  hàng để làm, thiếu người làm, hay hết món để bán?"*
  *Mở 2026-09-04 · T-056 · `master_plan/shop-facts.md` §8.6.*

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

**Ngày 2026-09-04, chủ quán trả lời HAI câu trong một lượt** (T-054). Hai câu ở hai đầu khác nhau
của cùng một buổi mất điện — một câu về **đơn nào được vào**, một câu về **tiền rơi vào ngày nào** —
và cả hai đều chốt theo hướng *đừng để máy giữ cái mà quán không nhìn thấy*.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-04) | Ghi ở |
|---|---|---|
| ~~U-032 — lượt bán ghi trên sổ giấy hôm mất điện, hôm sau mới nhập, tính doanh thu ngày nào~~ | **Ngày quán BÁN**, không phải ngày gõ vào máy — nguyên văn: *"bán"*. Cùng chiều luật nợ (§6.14): tiền về lúc nào không đổi được ngày bán. ⇒ Doanh thu một ngày **đã đối soát** có đổi về sau, **đúng một ca**, nên ngày còn `N > 0` là ngày **chưa đối soát xong** (**ADR-037**). *Vế **ai chấm lại con số ấy** không được chạm tới ⇒ **U-037**.* | `shop-facts.md` §6.11 · `quality/invariants.md` **I-014** (bảng ba dòng) · `docs/decisions.md` **ADR-037** · `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2 |
| ~~U-035 — quán mất mạng mà hệ thống vẫn sống: khách web vẫn đặt được, quán không thấy~~ | **Web NGỪNG nhận đơn**, trên web có **một dòng thông báo**; khách đặt qua **hotline**, quán **ghi giấy trực tiếp với POS** — nguyên văn: *"không cho đặt qua web cho đặt qua hotline và ghi giấy trực tiếp với pos, trên web có dòng thông báo"*. ⇒ **Điều kiện thứ ba** để một đơn được tạo, và là điều kiện duy nhất **không ai bấm được**. *Câu chữ của dòng thông báo **chưa** chốt — đừng tự viết.* | `shop-facts.md` §6.11 · `quality/invariants.md` **I-008** · `docs/product/1-system-design/01-ranh-gioi-he-thong.md` §3 (**PT-1**) · `06-ngoai-le.md` §6.1 dòng 11–12 |

**Cùng ngày 2026-09-04, chủ quán đóng thêm một câu — `U-031`** (T-055), và nó lại ra đúng chỗ đứng
mà những lượt trước đã ra: **POS**. Lời chủ quán chỉ có một từ, và một từ ấy đủ vì nó trả lời đúng
câu đang hỏi — *ai bấm*; vế *lúc nào* thì nó không chạm tới, nên vế ấy **không** được đọc kèm như
thể đã chốt.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-04) | Ghi ở |
|---|---|---|
| ~~U-031 — với một đơn giao tận nơi, ai bấm mốc *"đã ra bàn"* của từng việc trạm~~ | **POS** — nguyên văn: *"pos"*. **Không** có ngoại lệ cho đơn giao: *người đứng quầy* bấm mốc thứ ba y như đã bấm hai mốc kia (U-021), còn *người đi giao* vẫn chỉ giữ hai nút *đã giao* + *đã thu tiền* (§6.7). ⇒ §5.5 chạy được cho đơn giao, và không ai phải bấm khống một mốc cho suất đang ở nhà khách. *Vế **lúc nào** POS bấm thì lời ấy **không** nói ⇒ chỗ **suy ra** **S-6**, `shop-facts.md` §7.2 — đừng đọc nó thành lời chủ quán.* | `shop-facts.md` §5.4 · §7.1 · **S-6** ở §7.2 · `05-vong-doi.md` §5.2 và §5.4 · `03-lat-cat.md` §3.4.8 |

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
