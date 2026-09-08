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

**Ngày 2026-09-06, chủ quán trả lời cả BẢY câu còn mở lúc đó trong một lượt** — `U-033`, `U-034`,
`U-036`, `U-037`, `U-038`, `U-039`, `U-040` — đóng nốt xuống [Đã có lời giải](#da-co-loi-giai) ngay
dưới đây; nguyên văn và chi tiết từng câu ở đó. Lúc ấy chỉ `U-041` là còn sống từ trước lượt này —
câu đó nay **đã có lời giải** (chủ quán chốt 2026-09-08, xem mục dưới).
Cùng lượt ấy, câu trả lời `U-040` làm lộ một dữ kiện quán vừa đổi — số bàn tăng từ 11 lên 15 — mà
chỗ ngồi và cách đánh số của bốn bàn mới thì **lúc ấy** chưa ai hỏi; đó mở ra **U-042** ngay dưới
đây (vế chỗ ngồi đã có lời 2026-09-08, xem đoạn kế tiếp).

**Ngày 2026-09-08, chủ quán trả lời MỘT trong hai vế của `U-042`** — *"thêm 4 bàn mới mỗi bàn 4
chỗ"* ⇒ **cả mười lăm bàn đều 4 chỗ/bàn** (`master_plan/shop-facts.md` §1 · §6.25 · §7.1, T-066).
Câu hỏi **không đóng**: vế **cách đánh số** bốn bàn mới thì lời ấy không chạm tới, nên `U-042` **ở
lại đây với phạm vi hẹp hơn** — đúng hình dạng `U-034` từng ở lại ngày 2026-09-04. Một lời chốt trả
lời được nửa câu hỏi vẫn là nửa câu hỏi.

- **U-042 — bốn bàn quán vừa mua thêm (nâng tổng từ 11 lên 15) được ĐÁNH SỐ thế nào: nối tiếp
  12–15, hay theo cách khác?** **Hẹp lại 2026-09-08** (T-066): vế *mỗi bàn mấy chỗ ngồi* **đã có
  lời** — *"thêm 4 bàn mới mỗi bàn 4 chỗ"*, cả mười lăm bàn đều 4 chỗ/bàn — nên chỉ còn **tên/số
  của bốn bàn mới** là chưa ai nói. Câu này mở ra từ chính câu trả lời `U-040` ngày 2026-09-06:
  chủ quán chốt đủ ba vế cho **mười một** bàn ban đầu rồi tự thêm *"hôm nay tôi mua thêm bàn, hãy
  để 15 bàn"* mà không nói hình dạng của bốn bàn thêm. **Đừng suy hộ** (`CLAUDE.md` §3.5): đừng tự
  đánh số 12–15 — quán có thể đặt bàn mới ở một khu riêng và gọi tên khác hẳn; hai lần chủ quán nói
  về bốn bàn ấy đều **chỉ** nói số lượng và chỗ ngồi. **Ai trả lời được:** chủ quán. **Đang chặn:**
  `docs/decisions.md` **ADR-027** (*chỉ ghép sang bàn **trống*** cần gọi tên được **từng** bàn — đủ
  cho 11 bàn cũ, còn hở cho 4 bàn mới) và `work/backlog_AD.md` **ADM-03** (danh sách bàn gọi tên
  được; vế *sức chứa* thì hết hở từ 2026-09-08). **Cách hỏi** (bài học S-4 — hỏi về cái quán):
  *"Bốn bàn mới anh vừa mua, anh định gọi chúng là bàn số mấy — 12, 13, 14, 15, hay tên khác?"*
  *Mở 2026-09-06 · trả lời `U-040` · hẹp lại 2026-09-08 · `master_plan/shop-facts.md` §1 · §6.25.*

**Cùng ngày 2026-09-08, bước P1-08 mở một câu trong lúc chốt cách hệ thống biết quán đang mất kết
nối.** Nó không mở vì ai quên hỏi: chủ quán đã chốt **cái gì xảy ra** khi quán mù — web ngừng nhận
đơn, khách gọi hotline (`U-035`, 2026-09-04) — nhưng **mất tín hiệu bao lâu mới gọi là mù** thì
chưa lời nào chạm tới, và đó đúng là chỗ quyết định lúc nào quán ngừng bán trên web.

- **U-043 — mất tín hiệu bao lâu thì web NGỪNG nhận đơn?** `quality/invariants.md` **I-008** đã có
  điều kiện thứ ba (*quán đang nhìn thấy được đơn mới*), và
  `docs/product/1-system-design/05-realtime-va-du-phong.md` §3 vừa chốt **ai phán quyết** (phía hệ
  thống, vì lúc ấy quán là bên đã mất tiếng nói) cùng **đường nào được dùng để biết** (chính đường
  việc và đơn đang đi) — chỉ còn **độ dài cửa sổ** là chưa ai nói. **Vì sao không được suy hộ**
  (`CLAUDE.md` §3.5): ngắn quá thì một lần mạng chập chờn một phút cắt mất khách đang đặt dở; dài
  quá thì đơn rơi vào một cái quán không ai nhìn thấy — đúng cái `I-008` sinh ra để chặn. Đây là
  đánh đổi của **quán**, không phải một tham số kỹ thuật, và nếu ở đây không có con số thì pha 3 sẽ
  tự chọn một con số thay chủ quán. **Ai trả lời được:** chủ quán. **Đang chặn:** con số cửa sổ ở
  **pha 3**, và hàng thứ nhất của bảng §4 trong `05-realtime-va-du-phong.md`. **Cách hỏi** (bài học
  `S-4` — hỏi về cái quán, đừng hỏi về cái đồng hồ đếm giờ trong máy): *"Mạng nhà anh có kiểu chập
  chờn mất một hai phút rồi tự có lại không? Những lúc như thế anh muốn web tạm ngừng nhận đơn
  ngay, hay cứ để khách đặt vì lát nữa quán vẫn thấy?"*
  *Mở 2026-09-08 · P1-08 · `docs/product/1-system-design/05-realtime-va-du-phong.md` §3 · §4.*

**Cùng ngày 2026-09-08, chủ quán đóng `U-041` — và lời đáp mở ra đúng câu hỏi mà `U-041` đã báo
trước từ lúc mở.** Vế *"còn thiếu gì không"* của mục tổng quan là thiếu **NGUYÊN LIỆU**, tập
nguyên liệu là **Danh mục nguyên liệu** `master_plan/shop-facts.md` §8.4; chi tiết ở
[Đã có lời giải](#da-co-loi-giai). Nhưng §8.4 chốt máy ở mức **sổ ghi tay điện tử** và danh mục
hôm nay mới chỉ có **tên**, nên chọn xong đường ra rồi mà vẫn chưa có nguồn nào sinh ra chữ
*thiếu*. Đó là `U-045` ngay dưới — cùng hình dạng `U-040` mở ra `U-042` ngày 2026-09-06: đóng câu
cũ không có nghĩa hết việc.

- **U-045 — máy biết một nguyên liệu đang THIẾU bằng cách nào: một NGƯỠNG người tự nhập cho từng
  thứ, hay chủ quán tự đọc hai con số rồi tự kết luận?** `U-041` đóng 2026-09-08 chốt *thiếu cái
  gì* (nguyên liệu) nhưng không chốt *biết bằng cách nào*. **Vì sao không được suy hộ**
  (`CLAUDE.md` §3.5): `master_plan/shop-facts.md` §8.4 chốt máy **không** tự trừ tồn theo công thức
  bán hàng, và danh mục nguyên liệu hôm nay mới có **tên** — chưa thứ nào có **đơn vị tính**, chưa
  thứ nào có **ngưỡng nhắc sắp hết**. Hai đường ra chính `U-041` đã gọi tên: hoặc **lật ngược
  §8.4** (máy tự trừ tồn ⇒ phải chốt định lượng từng thành phần, đúng cái cửa duy nhất §8.4 nói là
  mở lại được — `work/admin-questions.md` câu **B22**), hoặc **một ngưỡng người tự nhập** cho từng
  nguyên liệu (giữ nguyên mức sổ tay, nhưng danh mục phải mọc thêm hai cột dữ kiện mà hôm nay chưa
  ai đọc ra). Chọn hộ một trong hai là quyết thay chủ quán **mức của cả mảng nguyên liệu**, không
  phải chọn một tham số. **Ai trả lời được:** chủ quán. **Đang chặn:** hàng số **7** của
  `master_plan/shop-facts.md` §8.6, hai chỗ hở *đơn vị · ngưỡng* của §8.4, và
  `work/backlog_AD.md` **ADM-04**. **Cách hỏi** (bài học `S-4` — hỏi về cái quán, đừng hỏi về cái
  máy): *"Sáng nay anh biết sắp hết mắm là biết bằng cách nào — nhìn thấy chai gần cạn, hay anh
  nhẩm trong đầu một mức «dưới chừng này là phải mua»? Nếu có mức ấy thì mỗi thứ một mức khác nhau
  đúng không?"*
  *Mở 2026-09-08 · trả lời `U-041` · `master_plan/shop-facts.md` §8.6 · §8.4.*

**Cùng ngày 2026-09-08, bước P1-10 mở một câu trong lúc dựng sổ rủi ro.** Nó cũng không mở vì ai
quên hỏi: chủ quán đã chốt **được phép hoàn tiền** và **ai quyết** (`master_plan/shop-facts.md`
§6.4, 2026-08-30) và **hoàn tính vào ngày hoàn** (2026-09-01), nhưng **trả lại bằng cách nào** thì
chưa lời nào chạm tới — và vế ấy quyết định phép trừ hai hạng tử của `quality/invariants.md`
**I-021** còn đủ hạng tử hay không.

- **U-044 — hoàn tiền cho một khoản khách đã CHUYỂN KHOẢN thì quán trả lại bằng gì: tiền mặt lấy
  trong két, hay chuyển khoản lại?** **Vì sao không được suy hộ** (`CLAUDE.md` §3.5): nếu trả bằng
  **tiền mặt** thì đó là một đường **rút tiền khỏi két giữa buổi**, trong khi chủ quán đã chốt
  2026-09-04 (`A4` ⇒ `master_plan/shop-facts.md` §8.5) rằng *"không có ai lấy tiền, tiền nằm trong
  két tới cuối buổi"* — và chính `I-021` viết sẵn hậu quả: luật ấy đổi thì công thức *két cuối ngày
  − tiền đầu két* **thiếu một hạng tử**, và mệnh đề phải **viết lại**, không phải viết thêm. Thêm
  một chỗ nữa: phần tiền mặt và phần chuyển khoản đối soát bằng **hai nguồn khác nhau** (§6.10), nên
  một lần hoàn đi ra ở phương thức này cho một lần thu ở phương thức kia làm lệch **cả hai** phép
  đối chiếu cùng lúc. **Ai trả lời được:** chủ quán. **Đang chặn:** không bước nào của pha 1 — nó
  chạm công thức đối soát `docs/product/1-system-design/architecture.md` §6.4, điều kiện biên thứ
  hai của `I-021`, và dòng `RR-3` của
  `docs/product/1-system-design/06-so-rui-ro.md`. **Cách hỏi** (bài học `S-4` — hỏi về cái quán):
  *"Khách chuyển khoản rồi mà mình phải trả lại tiền cho người ta, anh thường đưa tiền mặt luôn tại
  quầy hay chuyển khoản lại cho khách?"*
  *Mở 2026-09-08 · P1-10 · `master_plan/shop-facts.md` §6.4 · §8.5 · `quality/invariants.md`
  **I-021**.*

**Cùng ngày 2026-09-08, lượt sau, chủ quán đọc ra MENU thành một danh sách — và hai trong mười tên
ấy là thứ §4 chưa từng có.** Đây là lời bổ sung cho `U-041` (câu ấy vẫn đóng, xem
[Đã có lời giải](#da-co-loi-giai)): chủ quán chạm nốt hai đường còn lại của vế *"còn thiếu gì"* —
*"đối với nguyên liệu và con người đã có"* — rồi đọc ra từng món của menu. Bảy tên đầu khớp đúng
từng chữ với bảng giá `master_plan/shop-facts.md` §4.3; tất cả nay ở **§4.9** của file ấy. Hai câu
dưới đây là hai chỗ danh sách ấy vượt ra ngoài những gì §4 đang có, và không chỗ nào lấp được bằng
suy luận vì cả hai đều **chạm tiền**.

- **U-046 — *"canh bánh cuốn"* trên menu là món khách TRẢ TIỀN, hay chính bát canh quán đang bưng
  kèm sẵn? Nếu tính tiền thì bao nhiêu một bát, và nó có nhận nhân / lượng nhân không?** **Vì sao
  không được suy hộ** (`CLAUDE.md` §3.5): `master_plan/shop-facts.md` §3 đã có một **trạm** tên
  `canh` — việc của nó là *"Nước chấm, canh"* — và §5.3 xếp việc trạm ấy vào **mọi** đơn, kể cả
  đơn mang đi (§6.6, nước chấm gói riêng). Nên hôm nay canh đã là thứ **đi kèm không tính tiền**.
  Đọc dòng menu mới thành *"một món có giá"* là tự dựng một dòng doanh thu chưa ai chốt; đọc nó
  thành *"chính cái đang kèm"* là bỏ mất một món chủ quán vừa gọi tên. Hai đường ra khác nhau ở
  chỗ đắt nhất: nếu **có giá**, §4.2 mọc thêm một thành phần, §4.3 mọc thêm một dòng suất bán, số
  **bốn suất bán** ở §4.5 phải đếm lại ở cả năm chỗ đang chép nó, và §4.8 phải thêm ca thứ mười
  hai. **Ai trả lời được:** chủ quán. **Đang chặn:** ba dòng cuối bảng §4.9, và bất cứ bước nào
  sau này dựng danh sách món để bán. **Cách hỏi** (bài học `S-4` — hỏi về cái quán): *"Khách gọi
  một suất trứng thì có bát canh bưng kèm luôn đúng không? Vậy «canh bánh cuốn» anh ghi trên menu
  là bát canh ấy, hay là một bát riêng khách gọi thêm và trả tiền?"*
  *Mở 2026-09-08 · T-068 · `master_plan/shop-facts.md` §4.9 · §3 · §5.3.*

- **U-047 — *"bánh cuốn khách ăn bao nhiêu cái thì tuỳ"* và *"giò khách gọi bao nhiêu cũng được"*:
  đó là SỐ LƯỢNG khách gọi món bán rời, hay số bánh / số giò TRONG MỘT SUẤT cũng đổi được?** **Vì
  sao không được suy hộ** (`CLAUDE.md` §3.5): hai cách đọc cho hai hệ thống giá khác hẳn nhau.
  Đọc thứ nhất — bán rời theo cái, theo chiếc — thì bánh cuốn đã đúng như `master_plan/shop-facts.md`
  §4.3 hôm nay (1 cái, 3.000, khách gọi mấy cái thì nhân lên), và chỉ còn thiếu **một dòng giò bán
  rời** mà §4.3 chưa có (§4.2 có giá 1 chiếc giò 9.000, nhưng đó là giá **thành phần** — lấy nó thu
  tiền như giá suất là **thu thiếu tiền**, đúng cái bẫy `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md`
  §4.1 dựng ra để chặn). Đọc thứ hai — số bánh trong suất đổi được — thì **con số 4 trong *suất giò*
  và *suất trứng* không còn là hằng số**, và cả §4.3, §4.5, chín quy tắc §4.6, mười một tổ hợp §4.8
  đều phải viết lại: giá suất hết là một ô tra được, phụ thu ×4 / ×5 hết là hệ quả cố định. **Ai
  trả lời được:** chủ quán. **Đang chặn:** dòng 8 và dòng 9 của bảng §4.9. **Cách hỏi** (bài học
  `S-4`): *"Khách gọi «cho tôi 3 cái bánh cuốn» thì tính 3 cái riêng lẻ đúng không? Còn suất giò
  thì vẫn luôn 4 cái bánh, hay khách bảo «suất giò nhưng 6 cái bánh» cũng được?"*
  *Mở 2026-09-08 · T-068 · `master_plan/shop-facts.md` §4.9 · §4.3 · §4.5.*

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

**Ngày 2026-09-08, chủ quán đóng `U-041` — câu cuối cùng còn sống từ lượt 2026-09-04.** Nguyên
văn: *"về nguyên liệu hãy tham khảo «Danh mục nguyên liệu» tại `master_plan/shop-facts.md`"*.

**Cùng ngày, lượt sau, chủ quán bổ sung nốt hai đường còn lại** (T-068): *"đối với nguyên liệu và
con người đã có. đối với menu: tôi muốn có …"* rồi đọc ra cả danh sách món. Câu `U-041` **vẫn
đóng** — lượt này không mở lại nó, mà làm vế thứ bảy của `master_plan/shop-facts.md` §8.6 rộng ra:
thêm đường **món trên menu**, tập món ở **§4.9** (mới). Chỗ đọc trật tự câu trả lời thành *"mục
tổng quan bày cả ba"* là **suy ra**, ghi ở §7.2 thành **S-8**, không phải lời chốt
(`work/findings.md` **F-004**). Hai chỗ danh sách ấy vượt ra ngoài §4 hôm nay thành **U-046** ·
**U-047** ở mục *Đang mở*.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-041 — mục tổng quan bày *"còn thiếu gì không"*: thiếu NGUYÊN LIỆU, thiếu NGƯỜI, hay thiếu MÓN trên menu~~ | **Thiếu NGUYÊN LIỆU**, và tập nguyên liệu là **Danh mục nguyên liệu** §8.4 (mở 2026-09-06, mười bốn tên, **còn bổ sung dần**) ⇒ vế này lớn lên theo danh mục ấy, không có danh sách thứ hai ở §8.6 (**F-001**). *Chủ quán chọn một trong ba đường; hai đường kia **không** bị loại bằng lời — đừng viết một câu loại trừ chủ quán chưa nói (**F-004**). Đường **người** thì số 6 của bảng §8.6 đã giữ một con số riêng.* **Lời này KHÔNG nói máy biết một nguyên liệu đang thiếu bằng cách nào ⇒ mở `U-045`.** | `shop-facts.md` §8.6 (hàng 7) · §8.4 |

**Đây là lần thứ ba trong bốn ngày một câu trả lời đầy đủ để lộ một câu hỏi mới** — `U-032` → `U-037`
(2026-09-04), `U-040` → `U-042` (2026-09-06), nay `U-041` → `U-045`. Ba lần cùng một hình: lời chốt
trả lời đúng câu **đã hỏi**, và câu chưa ai hỏi nằm ngay sau nó. Đếm ba lần này là phép đếm của
người viết (**F-003**), không phải một quy luật.

**Ngày 2026-09-06, chủ quán trả lời cả BẢY câu còn mở trong một lượt, và mục *Đang mở* lúc ấy chỉ
còn lại `U-041` cũ cộng `U-042` mới mở ra từ chính lượt này** (`U-041` đã đóng 2026-09-08, xem
đoạn mở đầu mục này). Bảy câu đóng chạm năm chỗ khác nhau của
nghiệp vụ: một ca huỷ đơn ở bếp, một mục nhập nguyên liệu, một luật doanh thu mới, một câu hỏi
"ai chấm lại", một cách đếm tiền, một luật hàng chờ, và một dữ kiện quán (số bàn) vừa đổi ngay
trong câu trả lời.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-06) | Ghi ở |
|---|---|---|
| ~~U-033 — đơn HUỶ sau khi bếp đã làm xong phần của nó: chỗ bánh ấy đi đâu~~ | **Tính cho một bàn khác đang chờ đúng thứ đó; POS chọn bàn nhận và cập nhật** — nguyên văn: *"tính vào bàn khác, pos sẽ cập nhật bánh này đem ra cho bàn nào."* Nhu cầu của bàn nhận giảm đúng phần vừa nhận; phần đã huỷ không còn tính vào nhu cầu của bàn cũ. | `shop-facts.md` §5.4 |
| ~~U-034 — mục tổng hàng ngày ghi con số gì cho từng thứ~~ | **HAI con số: đồ MUA VÀO trong ngày, và đồ ĐÃ DÙNG trong ngày** — để chủ quán tự biết thừa/thiếu; nguyên văn: *"đồ mua trong ngày và đồ dùng trong ngày để tôi biết còn thừa thiếu bao nhiêu."* "Đã dùng" là số chủ quán tự ước lượng và nhập tay, không phải số máy suy ra — không lật ngược mức sổ tay của §8.4. Danh mục cụ thể (thứ nào, đơn vị gì) **vẫn chưa chốt**. | `shop-facts.md` §8.4 |
| ~~U-036 — trả trước hôm nay cho đơn giao ngày khác, doanh thu tính ngày nào~~ | **Ngày GIAO hàng**, không phải ngày nhận tiền; và quán chỉ nhận đặt trước **tối đa MỘT ngày** — nguyên văn: *"quán nhận đơn trước 1 ngày, doanh thu tính vào ngày đem hàng cho khách."* Chiều ngược và đối xứng với luật nợ (§6.14). ⇒ Công thức đối soát §6.4 cần thêm một dòng cho khoản đã vào két nhưng chưa vào doanh thu. | `shop-facts.md` §6.26 · `docs/decisions.md` **ADR-040** · `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2 |
| ~~U-037 — sau khi nhập bù xong, ai chấm lại ngày mất điện, lúc nào~~ | **POS hoặc chủ quán, vào CUỐI BUỔI BÁN HÀNG** — nguyên văn: *"pos hoặc chủ quán cuối buổi bán hàng."* Cùng người, cùng nhịp đã làm việc đối soát hằng ngày ở §6.10 — không phải vai trò mới. | `shop-facts.md` §6.27 · `quality/invariants.md` **I-014** |
| ~~U-038 — tiền đầu két nhập MỘT tổng hay bảng theo mệnh giá~~ | **CẢ HAI** — bảng theo từng mệnh giá VÀ tổng cộng — nguyên văn: *"tổng của từng mệnh giá và tổng của tất cả các mệnh giá cộng lại với nhau."* Phép trừ của I-021 dùng tổng cộng; bảng mệnh giá chỉ là cách đếm/kiểm. | `shop-facts.md` §8.5 |
| ~~U-039 — quán có muốn MÁY giữ hàng chờ bàn không, ai nhớ ai tới trước~~ | **KHÔNG — POS tự điều phối khách chờ khi cần** — nguyên văn: *"không. pos sẽ điều phối khách nếu cần."* Khách chưa có bàn không phải một khái niệm dữ liệu; §6.24 vẫn chỉ áp cho khách đã ngồi. | `shop-facts.md` §6.25 |
| ~~U-040 — mỗi bàn mấy chỗ ngồi, đã đánh số sẵn chưa~~ | **4 chỗ/bàn (11 bàn ban đầu), đã đánh số** — nguyên văn: *"11 bàn mỗi bàn 4 chỗ, đã đánh số."* **Cùng câu, chủ quán báo một dữ kiện vừa đổi:** *"hôm nay tôi mua thêm bàn, hãy để 15 bàn"* ⇒ Số bàn **11 → 15**. *Chỗ ngồi/đánh số của 4 bàn mới **chưa** trả lời ⇒ mở **U-042**.* | `shop-facts.md` §1 · §6.25 |

**Đừng đọc bảy dòng trên như bảy chỗ độc lập:** `U-040` tự mở ra `U-042` ngay trong lời đáp của nó
(bảng trên, dòng cuối) — đúng hình dạng mà `U-032` từng mở ra `U-037` ngày 2026-09-04. Một câu trả
lời đầy đủ cho câu hỏi cũ vẫn có thể để lộ một câu hỏi mới; đóng câu cũ không có nghĩa hết việc.

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
