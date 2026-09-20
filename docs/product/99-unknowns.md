# Unknowns — câu hỏi nghiệp vụ chưa có lời giải

> Nguyên văn mục *Unknowns* của `docs/product.md`, tách 2026-09-02 · DOC-1 · ADR-014.
> **Owner của mọi câu U-XXX.** Hợp đồng hình dạng (*Cách viết một câu ở đây*) giữ nguyên:
> `docs/decisions.md` **ADR-007** dựa vào nó. `scripts/brief.sh` còn đọc bản lưu cho tới
> khi DOC-2 trỏ nó sang file này.

<a id="muc-luc"></a>
## Mục lục

<!-- Mục lục ĐỨNG TRÊN tiêu đề `## Unknowns` có chủ ý (thêm 2026-09-16):
     scripts/brief.sh và scripts/check-doc-status.sh đọc từ dòng `## Unknowns`
     trở xuống, và trong vùng đang mở MỘT GẠCH ĐẦU DÒNG LÀ MỘT CÂU ĐANG MỞ
     (docs/decisions.md ADR-007 · work/findings.md F-008). Chuyển mấy dòng dưới
     đây xuống dưới tiêu đề ấy là đẻ ra đúng bấy nhiêu câu hỏi ma. -->

- [Đang mở](#dang-mo) — câu chưa có lời giải; `scripts/brief.sh` in mục này vào **mọi phiên mới**:
  - [U-053](#u-053) — quán mất mạng HẲN thì ai bấm dừng ba kênh, khi POS không bấm được gì
  - [U-054](#u-054) — hai con số *tổng* của vế nguyên liệu cộng dồn từ mốc nào
  - [U-055](#u-055) — bốn trạm ngoài quầy có ghi mốc đổi người không
  - [U-056](#u-056) — **ai khai** cái mốc đổi người ở quầy
  - [U-057](#u-057) — vế *ai bấm* của hai cửa ghi **ngoài** quầy
- [Cách viết một câu ở đây](#cach-viet) — hợp đồng hình dạng giữa mục này và `scripts/brief.sh`;
  đọc nó trước khi thêm, sửa hay đóng một câu
- [Đã có lời giải](#da-co-loi-giai) — câu đã đóng, xếp theo lượt trả lời của chủ quán, kèm nguyên
  văn lời chốt và chỗ lời ấy đã đi vào owner. Tìm một mã cụ thể bằng
  `grep -n 'U-0[0-9][0-9]' docs/product/99-unknowns.md` — đừng đếm bằng mắt.

<!-- ==== nguyên văn docs/product.md §Unknowns, tách 2026-09-02 ==== -->
## Unknowns

Câu hỏi nghiệp vụ chưa có lời giải. Không để việc thực hiện âm thầm quyết định thay.

`scripts/brief.sh` đọc mục này và in danh sách đang mở vào **mọi phiên mới**, nên hình dạng của
mục là một hợp đồng, không phải chuyện trình bày — cách viết ở
[Cách viết một câu ở đây](#cach-viet) bên dưới.

<a id="dang-mo"></a>
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
chỗ"* ⇒ cả mười lăm bàn đều 4 chỗ/bàn — **và ngày 2026-09-16 trả lời nốt vế kia**: bốn bàn mới
đánh số **nối tiếp 12–15**. Câu ấy nay ở [Đã có lời giải](#da-co-loi-giai), kèm nguyên văn cả hai
lượt. Một lời chốt trả lời được nửa câu hỏi vẫn là nửa câu hỏi — nửa còn lại ở đây tám ngày.

**Cùng ngày 2026-09-08, bước P1-08 mở `U-043`** — *mất tín hiệu bao lâu thì web ngừng nhận đơn* —
**và chủ quán đóng nó 2026-09-16 bằng cách bỏ chính giả định của câu hỏi**: không có con số cửa sổ
nào, máy **báo** còn **POS quyết**, đã dừng thì mở lại bằng **nút**. Câu ấy nay ở
[Đã có lời giải](#da-co-loi-giai); lời đáp lật luật 1 của
`docs/product/1-system-design/05-realtime-va-du-phong.md` §3 (`docs/decisions.md` **ADR-047**) và
để hở đúng ca `quality/invariants.md` **I-008** sinh ra để chặn ⇒ **U-053** ngay dưới.

**Ngày 2026-09-15, chủ quán đóng `U-045` — và lời đáp dời chữ *thiếu* ra khỏi máy.** Nguyên văn:
*"chủ quán tự đọc rôi đưa ra kết luận"* ⇒ **không có ngưỡng**, máy **không** kết luận thay người.
Chỗ lời ấy để hở — mục tổng quan **bày cái gì** ở vế nguyên liệu — thành `U-051`, và **chủ quán
đóng nốt nó 2026-09-16**: bày **thời gian nhập** cùng **tổng đã dùng**, còn số thiếu thì **máy
trừ**. Cả hai câu nay ở [Đã có lời giải](#da-co-loi-giai); chỗ lời đáp mới để hở — chữ *tổng* cộng
dồn từ mốc nào — là **U-054** ngay dưới.

**Cùng ngày 2026-09-08, bước P1-10 mở `U-044` trong lúc dựng sổ rủi ro, và chủ quán đóng nó cùng
ngày** — *trả lại bằng gì* cũng do POS quyết từng ca. Câu ấy nay ở
[Đã có lời giải](#da-co-loi-giai); hệ quả của nó là `quality/invariants.md` **I-021** được viết lại
(2026-09-15, `docs/decisions.md` **ADR-046**).

**Ngày 2026-09-08, cả BA câu sinh ra từ danh sách MENU đều đã đóng trong ngày** — `U-046` ·
`U-047` ở một lượt, rồi `U-048` (*mỗi suất kèm sẵn mấy bát canh*) ở lượt sau nữa. Cả ba nay ở
[Đã có lời giải](#da-co-loi-giai); mục *Đang mở* không còn câu nào chạm menu.

**Ngày 2026-09-15, chủ quán đóng `U-050` bằng một câu** — *"pos gánh, không thiếu người vì đi ship
luc quán vắng."* — **và câu ấy va đúng vào lời chốt `U-049` bảy ngày trước**: người đi giao là
*"bất cứ ai"* trong bốn vai, kể cả chính người đứng quầy, mà lúc ấy POS không gánh được trạm của
chính mình. Chỗ va ấy là `U-052`, và **chủ quán đóng nó ngày 2026-09-16** bằng đúng một câu —
*người đứng quầy không đi giao*. Cả hai nay ở [Đã có lời giải](#da-co-loi-giai).

**Ngày 2026-09-16, chủ quán trả lời BỐN câu trong một lượt — và hai trong bốn lời đáp để lộ hai câu
chưa ai hỏi** (T-078). Cả hai đều không mở vì ai quên hỏi: `U-043` chuyển quyền **dừng web** sang
**POS**, nên đúng ca *quán mất mạng hẳn, POS không bấm được gì* — ca `quality/invariants.md`
**I-008** sinh ra để chặn — hết người quyết; `U-051` bảo máy **trừ hai con số tổng**, mà
`master_plan/shop-facts.md` §8.4 ghi hai con số ấy theo **từng ngày**, nên chữ *tổng* chưa có mốc.
Nguyên văn cả bốn lời đáp ở [Đã có lời giải](#da-co-loi-giai).

<a id="u-053"></a>
- **U-053 — quán mất mạng HẲN thì ba kênh khách tự bấm có TỰ dừng không, khi POS không nhìn thấy
  thông báo và cũng không bấm được nút nào?** Lời chốt `U-043` (2026-09-16) giao quyền dừng cho
  **POS**: máy hiện thông báo, POS quyết. Nhưng điều kiện thứ ba của `quality/invariants.md`
  **I-008** sinh ra cho đúng ca **không ai ở quán bấm được gì** — *"quán mất mạng thì nút tạm dừng
  cũng nằm sau đúng đường mạng vừa mất"* (I-008 · `master_plan/shop-facts.md` §6.11). Đọc hai lời
  cạnh nhau thì hở đúng ca ấy: máy thấy quán mù, thông báo không ai đọc, không ai bấm dừng, và đơn
  web vẫn rơi vào một cái quán không ai nhìn thấy. **Vì sao không được suy hộ** (`CLAUDE.md` §3.5):
  hai đường ra là hai luật khác nhau, không đường nào suy được từ chữ đã có — hoặc **máy tự dừng**
  ba kênh khi quán mù còn POS chỉ quyết ở ca chập chờn mà quầy vẫn nhìn thấy, hoặc **máy không bao
  giờ tự dừng** và quán chấp nhận đơn rơi vào khoảng mù rồi xử sau, mà đường sau lật chính `I-008`.
  **Ai trả lời được:** chủ quán. **Đang chặn:** luật 1 của
  `docs/product/1-system-design/05-realtime-va-du-phong.md` §3, hàng thứ nhất bảng §4 của file ấy,
  và vế **cơ chế** của `I-008` — tức cả **pha 3**. **Cách hỏi** (bài học `S-4` — hỏi về cái quán):
  *"Lúc quán mất mạng hẳn, không ai ở quán bấm được gì: anh muốn máy tự ngừng nhận đơn trên web cho
  tới khi có người bấm mở lại, hay cứ để khách đặt rồi lát nữa quán xem lại?"*
  *Mở 2026-09-16 · T-078 · trả lời `U-043` · `quality/invariants.md` **I-008** ·
  `docs/product/1-system-design/05-realtime-va-du-phong.md` §3.*

<a id="u-054"></a>
- **U-054 — hai con số *tổng* mà mục tổng quan lấy hiệu — *tổng đã nhập* trừ *tổng đã dùng* — cộng
  dồn TỪ MỐC NÀO: từ ngày đầu tiên có sổ, từ đầu tháng, hay chỉ trong ngày hôm nay?** Lời chốt
  `U-051` (2026-09-16) bảo máy trừ hai con số **tổng**; `master_plan/shop-facts.md` §8.4 thì ghi
  hai con số **mua vào · đã dùng** theo **từng ngày** (`U-034`, 2026-09-06). Chữ *tổng* vì thế có
  ít nhất ba nghĩa, và mỗi nghĩa cho một con số khác hẳn trên cùng một màn. **Vì sao không được
  suy hộ** (`CLAUDE.md` §3.5): đây là con số chủ quán nhìn để quyết **có phải đi mua hàng không**
  — chọn hộ cái mốc là quyết hộ nghĩa của chữ *thiếu*, đúng thứ `U-045` vừa dời ra khỏi máy
  (2026-09-15). **Ai trả lời được:** chủ quán. **Đang chặn:** vế nguyên liệu của hàng số **7**
  `master_plan/shop-facts.md` §8.6, và `work/backlog_AD.md` **ADM-04** · **ADM-13**. **Chưa chặn:**
  không bước nào của pha 1 — không mục nào của pha 1 dựa vào danh mục nguyên liệu. **Cách hỏi**
  (bài học `S-4` — hỏi về cái quán): *"Con số còn lại anh muốn cộng từ lúc nào — cộng hết từ trước
  tới nay, từ đầu tháng, hay chỉ tính riêng trong ngày hôm nay?"*
  *Mở 2026-09-16 · T-078 · trả lời `U-051` · `master_plan/shop-facts.md` §8.4 · §8.6.*

**Ngày 2026-09-20, chủ quán trả lời `C36` và lời đáp để lộ BA vế chưa ai hỏi** (ADM-53 hỏi,
**ADM-21** chuyển lời về owner trong cùng ngày). Cả ba đều không mở vì ai quên hỏi: câu `C36` hỏi
về **người đứng quầy**, và lời đáp — *"Có — ghi cả mốc đổi, ai vào ai ra lúc mấy giờ"* — trả lời
đúng vế ấy. Nhưng chỗ trống mà ba tài liệu gọi tên rộng hơn câu hỏi: `master_plan/shop-facts.md`
§8.7 chốt mức 1 cho **năm** trạm, §8.6 hàng 6 hỏi **bao nhiêu người đang làm**, và
`quality/invariants.md` **I-012** đòi *ai bấm* ở **hai cửa ghi ngoài quầy**. Nguyên văn lời đáp và
phạm vi của nó ở `master_plan/shop-facts.md` **§8.8**.

<a id="u-055"></a>
- **U-055 — bốn trạm ngoài quầy (`trang_banh` · `gap_banh` · `canh`+`don_ban`) có ghi mốc đổi
  người không, hay chỉ trạm `quay` mới ghi?** Lời chốt `C36` (2026-09-20,
  `master_plan/shop-facts.md` **§8.8**) nói mỗi lần đổi người **ở quầy** là một mốc có giờ. Nhưng
  §8.7 chốt mức 1 của mảng con người là *ai đang trực trạm nào* trên **cả năm** trạm §3, nên bốn
  trạm kia còn trống đúng chỗ trạm `quay` vừa được lấp. **Vì sao không được suy hộ**
  (`CLAUDE.md` §3.5): hai đường ra là hai cái quán khác nhau — hoặc **cả năm trạm** đều ghi mốc
  đổi, tức mỗi người ở bếp cũng phải khai vào/ra và quán gánh thêm một thao tác mỗi buổi; hoặc
  **chỉ quầy** ghi vì quầy là nơi duy nhất chạm tiền (**ADR-016**), còn bếp thì không ai cần truy
  ngược. Đường sau rẻ hơn hẳn cho quán, nhưng chọn nó là quyết hộ nghĩa của số **6** ở §8.6.
  **Ai trả lời được:** chủ quán. **Đang chặn:** số **6** (*bao nhiêu người đang làm*) và vế *người*
  của số **7** ở `master_plan/shop-facts.md` §8.6, `work/backlog_AD.md` **ADM-04**, và phạm vi đầy
  đủ của mức 1 ở §8.7. **Chưa chặn:** luật quyền huỷ / hoàn tiền — luật ấy sống ở trạm `quay` và
  §8.8 đã đỡ được nó. **Cách hỏi** (bài học `S-4` — hỏi về cái quán): *"Ngoài người đứng quầy, mấy
  người ở bếp đổi chỗ cho nhau giữa buổi thì anh có muốn máy ghi lại không, hay chỉ cần biết ai
  đang đứng quầy là đủ?"*
  *Mở 2026-09-20 · ADM-21 · trả lời `C36` · `master_plan/shop-facts.md` **§8.8** · §8.6 · §8.7.*

<a id="u-056"></a>
- **U-056 — AI khai cái mốc đổi người ở quầy: người vào tự bấm, người ra bấm, hay POS bấm hộ?**
  Lời chốt `C36` (2026-09-20, `master_plan/shop-facts.md` **§8.8**) nói máy **ghi** mốc đổi; nó
  không nói ai **khai** mốc ấy. **Vì sao không được suy hộ** (`CLAUDE.md` §3.5): ba đường ra cho ba
  luật khác nhau, và một trong ba lật chính lời vừa chốt — nếu **người vào tự bấm** thì có ca hai
  người cùng nhận mình đang đứng quầy, nếu **người ra bấm** thì có ca người ra quên bấm và quầy
  thành trống trong máy giữa lúc đang bán, nếu **POS bấm hộ** thì cái mốc lại do chính chỗ đứng nó
  ghi lại xác nhận, và quán phải chấp nhận điều đó. Không đường nào suy được từ chữ đã có.
  **Ai trả lời được:** chủ quán. **Đang chặn:** vế *đổi lúc nào thì ai chịu trách nhiệm từ lúc nào*
  của `work/backlog_AD.md` **ADM-21** khi nó đi tiếp, và **ADM-51** (phân quyền). **Chưa chặn:**
  pha 2 — chỗ cất một cái mốc không đổi theo người khai nó (**ADR-035**). **Cách hỏi** (bài học
  `S-4` — hỏi về cái quán): *"Lúc B thay A ở quầy, ai là người bấm vào máy cái mốc đổi ấy — người
  vừa vào, người vừa ra, hay ai đang cầm máy cũng được?"*
  *Mở 2026-09-20 · ADM-21 · trả lời `C36` · `master_plan/shop-facts.md` **§8.8**.*

<a id="u-057"></a>
- **U-057 — hai cửa ghi NGOÀI quầy lấy tên người từ đâu: người đi giao bấm *đã giao + đã thu tiền*
  tại chỗ khách, và chủ quán đổi giá / đổi thành phần suất trên mặt quản trị?**
  `quality/invariants.md` **I-012** đòi mọi thao tác chạm tiền để lại vết có đủ *ai bấm*, và chính
  I-012 chốt hai ca này nằm **ngoài** cửa POS ở quầy (`master_plan/shop-facts.md` §6.7 · §6.17).
  Lời chốt `C36` (2026-09-20, **§8.8**) chỉ cho biết ai đang đứng **quầy**, nên hai cửa kia vẫn
  không có nguồn cho vế *ai*. **Vì sao không được suy hộ** (`CLAUDE.md` §3.5): với người đi giao,
  §3 chốt POS **chỉ định từng lần** và không lời nào nói máy có ghi lại lần chỉ định ấy không — lấy
  cái vết ra từ một quyết định miệng là bịa; với chủ quán, đường ra đụng vào một luật đã chốt, vì
  gán tên theo **chức vụ** là đúng thứ §4 của `docs/product/1-system-design/architecture.md` cấm.
  **Ai trả lời được:** chủ quán. **Đang chặn:** vế *ai* của `work/backlog_AD.md` **ADM-50** (vết
  thao tác), và phần *Kịch bản phủ* của **I-012** ở hai ca ngoài quầy. **Chưa chặn:** mọi thao tác
  đi qua POS ở quầy — §8.8 đã đỡ. **Cách hỏi** (bài học `S-4` — hỏi về cái quán): *"Lúc người đi
  giao bấm đã thu tiền ở nhà khách, và lúc anh tự sửa giá ở nhà, anh có muốn máy ghi lại đó là ai
  bấm không — hay chỉ cần biết là 'người đi giao' và 'chủ quán' là đủ?"*
  *Mở 2026-09-20 · ADM-21 · trả lời `C36` · `quality/invariants.md` **I-012** ·
  `master_plan/shop-facts.md` **§8.8** · §6.7 · §6.17.*

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
- **Mở hay đóng một câu thì sửa [Mục lục](#muc-luc) ở đầu file trong CÙNG thay đổi ấy** — thêm
  (hoặc gỡ) dòng của mã đó, và thêm (hoặc gỡ) cái neo `<a id="u-xxx"></a>` ngay trên gạch đầu
  dòng. Mục lục là bản sao thứ hai của danh sách đang mở: bản sao nào không được sửa cùng lúc với
  bản gốc thì thành lời nói dối (`work/findings.md` **F-001**). Máy **không** chấm chỗ này — cả
  Gate 1b lẫn Gate 1c đều không đọc phần trên tiêu đề `## Unknowns`.

<a id="da-co-loi-giai"></a>
### Đã có lời giải — không ghi lại thành Unknown nữa

**Ngày 2026-09-16, chủ quán trả lời BỐN câu trong một lượt — `U-042` · `U-043` · `U-051` · `U-052`**
(T-078) — cả bốn câu đang mở lúc ấy, đóng trong cùng một lượt. Hai lời trong đó **để lộ hai câu
mới** — `U-053` · `U-054`, nay ở [Đang mở](#dang-mo); hai lời còn lại (`U-042`, `U-052`) đóng hẳn,
không để hở chỗ nào.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-16) | Ghi ở |
|---|---|---|
| ~~U-042 — bốn bàn quán vừa mua thêm (11 → 15) được ĐÁNH SỐ thế nào: nối tiếp 12–15, hay theo cách khác~~ | **Nối tiếp 12–15** — nguyên văn: *"trả lời nối tiếp 12–15"*. ⇒ mười lăm bàn mang tên **1…15**; bốn bàn mới là **12 · 13 · 14 · 15**, không khu riêng, không cách gọi khác. Câu này đóng **vế cuối** của `U-042` — vế *chỗ ngồi* đã đóng 2026-09-08 (*"thêm 4 bàn mới mỗi bàn 4 chỗ"*) — nên `U-042` hết là câu hỏi sau **mười ngày** và hai lượt. ⇒ `docs/decisions.md` **ADR-027** (*chỉ ghép sang bàn **trống***) nay gọi tên được **từng** bàn trong cả mười lăm, và `work/backlog_AD.md` **ADM-03** (danh sách bàn) hết chỗ hở. Không lời nào nói bàn có **tên** ngoài số, cũng không lời nào nói thứ tự ấy gắn với chỗ ngồi trong quán — đừng đọc thêm. | `shop-facts.md` **§1** · §6.25 · §7.1 · `work/backlog_AD.md` **ADM-03** |
| ~~U-043 — mất tín hiệu BAO LÂU thì web NGỪNG nhận đơn~~ | **Không có con số cửa sổ nào: máy BÁO, POS QUYẾT, và đã dừng thì mở lại bằng NÚT** — nguyên văn: *"hiên thông báo để pos quyết định nếu dừng cần có nut mở lại"*. ⇒ câu hỏi đóng bằng cách **bỏ chính giả định của nó**, đúng hình dạng bảy câu ngày 2026-09-02 và `U-044`: không luật cứng, người quyết theo tình hình. **Ba điều lời này chốt:** (1) thấy dấu hiệu mất kết nối thì máy **hiện một thông báo** ở quầy, không tự kết luận thay người; (2) **POS** là người quyết ba kênh khách tự bấm có dừng hay không; (3) đã dừng thì **mở lại là một nút người bấm**, **không** tự mở lại khi tín hiệu về. ⚠️ Lời này **lật hai câu đã viết trước khi có nó**: luật 1 của `05-realtime-va-du-phong.md` §3 (*phán quyết đứng ở phía hệ thống, không phía quán*) và câu *"có mạng lại thì ba kênh kia mở lại ngay"* ở phần **Verification** của `I-008` — cả hai sửa theo lời chủ quán trong cùng thay đổi này (`docs/decisions.md` **ADR-047**). ⚠️ Lời này **KHÔNG** nói ca quán **mất mạng hẳn** — lúc POS không nhìn thấy thông báo và không bấm được gì, đúng ca `I-008` sinh ra để chặn ⇒ mở **`U-053`**. | `shop-facts.md` **§6.11** · `quality/invariants.md` **I-008** · `docs/product/1-system-design/05-realtime-va-du-phong.md` §3 · §4 · `docs/decisions.md` **ADR-047** |
| ~~U-051 — máy không kết luận *thiếu* nữa, vậy mục tổng quan bày GÌ ở vế nguyên liệu~~ | **Bày THỜI GIAN NHẬP và TỔNG ĐÃ DÙNG; số thiếu thì MÁY TRỪ — thiếu = tổng đã nhập − tổng đã dùng** — nguyên văn: *"thời gian nhâp sản phẩm và tổng đã sử dụng lấy thiếu bằng tổng đã nhập trừ đi sử dụng"*. ⇒ trong ba đường câu hỏi đưa ra, chủ quán chọn **đường thứ tư**: không phải cặp *mua vào · đã dùng* của từng thứ, không phải *không bày gì* — mà **máy cộng dồn hộ rồi bày hiệu số**, kèm **thời gian nhập** (thứ chưa mục nào của §8.4 từng nói tới). **Không lật §8.4 và không lật `U-045`:** bảng *máy làm* của §8.4 vốn đã cho máy *"nhận con số người nhập, giữ lại, **cộng lại**, hiện ra"*, và máy vẫn **không** có ngưỡng, **không** tự kết luận *sắp hết*, **không** nhắc. *Chữ **thiếu** trong lời chủ quán ở đây là **tên của hiệu số**, không phải một phán quyết — cách đọc của phiên viết, không phải lời chủ quán (**F-004**).* ⚠️ Lời này **KHÔNG** nói hai con số *tổng* cộng dồn **từ mốc nào** ⇒ mở **`U-054`**; và cũng không nói bày **cả mười bốn thứ** của danh mục hay chỉ thứ có động — chỗ ấy là hình dạng màn, **pha 4**. | `shop-facts.md` **§8.4** · §8.6 (hàng 7) · §7.1 |
| ~~U-052 — khi POS chỉ định CHÍNH NGƯỜI ĐỨNG QUẦY đi giao thì trạm `quay` do ai gánh~~ | **Người đứng quầy KHÔNG BAO GIỜ là người đi giao** — nguyên văn: *"người đứng quầy khônng đi giao"*. ⇒ chủ quán chọn đúng **đường thứ nhất** trong ba đường câu hỏi đưa ra: chữ *"bất cứ ai"* của `U-049` (2026-09-08) **hẹp lại còn BA vai** — `trang_banh` · `gap_banh` · `canh`+`don_ban`. Trạm `quay` vì thế **không bao giờ** là trạm bị bỏ trống vì đi giao, nên lời *"pos gánh"* của `U-050` (2026-09-15) luôn có người để gánh: ca duy nhất §3 chưa khép nay khép, và câu **C36** (*ai đang trực trạm nào*) hết phải chờ nó để xếp ca. ⚠️ Lời này **không** đụng tới chủ quán: §3 vẫn để chủ quán *thỉnh thoảng đứng quầy*, và không lời nào nói chủ quán có đi giao hay không — đừng đọc thành luật (**F-004**). | `shop-facts.md` **§3** · §8.6 · §7.1 · `work/admin-questions.md` **C23** |


**Ngày 2026-09-08, chủ quán đóng `U-044` — mở và đóng trong cùng ngày** (ghi vào owner 2026-09-15,
T-073). Lời đáp cùng hình dạng với bảy câu ngày 2026-09-02 và với `U-049`: **không có luật cứng,
POS quyết theo tình hình thực tế**.

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-044 — hoàn tiền cho một khoản khách đã CHUYỂN KHOẢN thì quán trả lại bằng gì: tiền mặt lấy trong két, hay chuyển khoản lại~~ | **Tuỳ ca — POS quyết** — nguyên văn: *"tuỳ vào tình hình thực tế, pos quyết định."* ⇒ **cả hai đường đều có**: tiền mặt lấy trong két, hoặc chuyển khoản lại; không đường nào là mặc định, không đường nào bị cấm — cùng hình dạng quyền hoàn tiền §6.4 (2026-08-30). ⇒ Đúng như câu hỏi đã viết sẵn: hoàn **tiền mặt** cho khoản **chuyển khoản** là một đường tiền rời két giữa buổi, nên `I-021` **viết lại** — thêm hai hạng tử cho ca hoàn **chéo** phương thức, *doanh thu tiền mặt* giữ nguyên nghĩa (**ADR-046**). *Vết hoàn tiền phải ghi thêm **phương thức trả lại** là **suy ra** từ §6.10, không phải lời chủ quán* (**F-004**). ⚠️ Lời này **không** nói một lần hoàn **chuyển khoản** (tiền **ra**) được đối chiếu với nguồn nào — §6.10 hôm nay chỉ có tin nhắn báo có (tiền **vào**); ghi ở **ADR-046** *Chỗ không chốt*, chưa chặn bước nào của pha 1. | `shop-facts.md` **§6.4** · §8.5 · §7.1 · `quality/invariants.md` **I-021** |

**Ngày 2026-09-15, chủ quán đóng `U-045`** (T-074) — câu mở 2026-09-08 từ chính lời đáp `U-041`.
Chủ quán chọn đúng **một** trong hai đường câu hỏi đưa ra, bằng chính chữ của câu hỏi:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-15) | Ghi ở |
|---|---|---|
| ~~U-045 — máy biết một nguyên liệu đang THIẾU bằng cách nào: một NGƯỠNG người tự nhập cho từng thứ, hay chủ quán tự đọc hai con số rồi tự kết luận~~ | **Chủ quán tự đọc, tự kết luận — không có ngưỡng** — nguyên văn: *"chủ quán tự đọc rôi đưa ra kết luận"*. ⇒ Máy **không** giữ ngưỡng nhắc sắp hết cho thứ nào, **không** tự bày chữ *thiếu* hay *sắp hết*, **không** nhắc; danh mục §8.4 **không** mọc cột *ngưỡng*. Hai con số người đọc là cặp **mua vào · đã dùng** mà `U-034` đã chốt 2026-09-06. **§8.4 đứng nguyên ở mức sổ ghi tay điện tử** — lời này đi đúng đường *không* lật ngược nó, nên cửa `B22` (giá vốn, định lượng) vẫn chưa ai mở. Cùng lối nghĩ với *"máy không gom, người gom"* (§5.4): máy giữ con số, người quyết. ⚠️ Lời này **KHÔNG** nói người đọc hai con số ấy **ở đâu** — trên mục tổng quan, hay trong mục nhập hàng ngày — ⇒ mở **`U-051`**. ⚠️ Chỗ hở **đơn vị tính** của danh mục §8.4 **không** đóng theo: nó chỉ từng nằm chung trong `U-045`, nay đứng một mình ở câu `B12` (`work/admin-questions.md`). | `shop-facts.md` **§8.4** · §8.6 (hàng 7) · §7.1 |

**Ngày 2026-09-08, chủ quán đóng `U-041` — câu cuối cùng còn sống từ lượt 2026-09-04.** Nguyên
văn: *"về nguyên liệu hãy tham khảo «Danh mục nguyên liệu» tại `master_plan/shop-facts.md`"*.

**Cùng ngày, lượt sau nữa, chủ quán đóng cả `U-046` lẫn `U-047` trong một lượt** (T-069) — hai câu
mở ra từ chính danh sách menu, và cả hai đáp án đều là **luật**, không phải một con số lẻ:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-047 — *"bao nhiêu cái thì tuỳ"* / *"gọi bao nhiêu cũng được"* là số lượng món bán rời, hay số bánh · số giò trong một suất cũng đổi được~~ | **Số lượng món BÁN RỜI; số thành phần trong một suất là HẰNG SỐ** — nguyên văn: *"đó là SỐ LƯỢNG khách gọi món bán rời. số bánh / số giò TRONG MỘT SUẤT là không đổi."* ⇒ suất giò 4 bánh · suất trứng 4 bánh · combo 3 bánh đứng nguyên; §4.5 · §4.6 · §4.8 không đổi một chữ. **Giò thành một dòng menu bán rời** — thứ §4.3 chưa từng có. ⚠️ Giá 9.000 của dòng ấy là **hệ quả tính từ luật 1 §4.6**, chủ quán chưa đọc thành lời ⇒ **S-9** (`shop-facts.md` §7.2), cùng hình dạng `S-1` | `shop-facts.md` §4.3 · §4.5 · §4.9 |
| ~~U-046 — *"canh bánh cuốn"* là món trả tiền hay bát canh kèm sẵn~~ | **Kèm sẵn, KHÔNG tính tiền — nhưng vẫn phải là một dòng menu khách chọn SỐ LƯỢNG** — nguyên văn: *"canh bánh cuốn bưng kèm sẵn không tính tiền nhưng cần có trong menu để khách chọn vì đôi khi 1 suất đầy đủ khách muốn có 2 bát canh, 1 bát cho con và 1 bát cho mẹ."* ⇒ dòng menu **0đ có số lượng** — thứ chưa bảng nào trong repo có chỗ chứa — và việc trạm `canh` **hết suy ra được từ số suất** (§5.3). **Lời này KHÔNG nói kèm sẵn mấy bát, cũng không nói con số khách chọn là tổng hay phần thêm ⇒ mở `U-048` — đóng cùng ngày, lượt sau (bảng ngay dưới): chữ *kèm sẵn* chỉ còn nghĩa *không tính tiền*.** | `shop-facts.md` §4.2 · §4.3 · §4.5 · §5.3 |

**Đây là lần thứ tư trong năm ngày một câu trả lời đầy đủ để lộ một câu hỏi mới** (`U-032`→`U-037`,
`U-040`→`U-042`, `U-041`→`U-045`, nay `U-046`→`U-048`) — phép đếm của người viết, không phải một
quy luật (**F-003**).

**Cùng ngày 2026-09-08, lượt sau nữa, chủ quán đóng `U-048` bằng một câu** (T-072) — câu mở ra từ
chính lời đáp `U-046`, đóng trong ngày, và lần này lời đáp **không** mở câu nào mới:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-048 — mỗi suất bếp bưng kèm sẵn mấy bát canh, và con số khách chọn trên dòng *canh bánh cuốn* là TỔNG số bát hay số bát THÊM~~ | **KHÔNG suất nào bưng kèm canh; bếp bưng đúng số bát khách chọn** — nguyên văn: *"mỗi suất bếp sẽ không bưng kèm theo canh. bếp bưng canh như nào dựa vào lựa chọn thực tế của khách."* ⇒ phần kèm sẵn là **0 bát**, nên con số ở dòng *canh bánh cuốn* là **TỔNG số bát** — hai cách đọc của câu hỏi trùng nhau khi phần nền bằng 0. Khách gọi 1 suất đầy đủ + *canh ×2* ⇒ **2** bát; không chọn canh ⇒ **0** bát, và đơn ấy không có việc *canh* nào xuống bếp (việc **nước chấm** cấp đơn thì vẫn có). Lời này **phủ một cách đọc** của lời `U-046` ngay trên: chữ *"bưng kèm sẵn"* ở đó chỉ còn nghĩa **không tính tiền** — ô 0đ đứng nguyên, vế *tự động bưng* bị bỏ. Bốn hàng suất của §4.5 không mọc thêm thành phần nào | `shop-facts.md` §4.2 · §4.5 · §4.9 · §5.3 · §7.1 |

**Cùng ngày, lượt trước đó, chủ quán bổ sung nốt hai đường còn lại** (T-068): *"đối với nguyên liệu và
con người đã có. đối với menu: tôi muốn có …"* rồi đọc ra cả danh sách món. Câu `U-041` **vẫn
đóng** — lượt này không mở lại nó, mà làm vế thứ bảy của `master_plan/shop-facts.md` §8.6 rộng ra:
thêm đường **món trên menu**, tập món ở **§4.9** (mới). Chỗ đọc trật tự câu trả lời thành *"mục
tổng quan bày cả ba"* là **suy ra**, ghi ở §7.2 thành **S-8**, không phải lời chốt
(`work/findings.md` **F-004**). Hai chỗ danh sách ấy vượt ra ngoài §4 hôm nay thành **U-046** ·
**U-047** ở mục *Đang mở*.

**Cùng ngày, lượt thứ ba, vế *người* mới có chỗ để trỏ vào** (T-076). Lượt trước chủ quán chỉ nói
*"con người đã có"* — nhận là có, nhưng **không** nói đường ấy đọc vào đâu, nên §8.6 để trống đúng
chỗ ấy. Lượt này chủ repo chỉ thẳng: tập của vế *người* là **bảng phân vai `master_plan/shop-facts.md`
§3** — **năm trạm việc** gộp thành **bốn vai** (chủ quán chốt 2026-08-30), cộng **chủ quán** là vai
riêng ngoài năm trạm. `U-041` **vẫn đóng**; lượt này không mở lại nó, chỉ hoàn tất đường thứ hai
trong ba. Hai điều lượt này làm rõ và **không** phải lời chủ quán (**F-004**): số **6** của bảng
§8.6 (*bao nhiêu người đang làm*) và số **7** (*đang thiếu người hay không*) là **hai** con số khác
nhau, đừng gộp; và chữ *thiếu người* **không đồng đều giữa năm trạm**, vì §3 cho `canh` + `don_ban`
chung một đôi tay còn ba trạm kia thì riêng. Chỗ lượt này để hở thành **U-049** — mở và **đóng
trong cùng ngày**, ở lượt sau (T-071, ngay dưới).

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-041 — mục tổng quan bày *"còn thiếu gì không"*: thiếu NGUYÊN LIỆU, thiếu NGƯỜI, hay thiếu MÓN trên menu~~ | **CẢ BA đường, chốt qua ba lượt cùng ngày 2026-09-08** — không phải một. **(1) Nguyên liệu**, tập là **Danh mục nguyên liệu** §8.4 (mở 2026-09-06, mười bốn tên, **còn bổ sung dần**). **(2) Người** — *"nguyên liệu và con người đã có"*, tập là **bảng phân vai §3** (chủ repo chỉ chỗ ở lượt thứ ba): năm trạm việc gộp thành **bốn vai**, cộng chủ quán đứng ngoài. **(3) Món trên menu**, tập là **§4.9**. Cả ba đều **lớn lên theo tập của mình**, không đường nào có danh sách thứ hai ở §8.6 (**F-001**). **Ba chỗ lời chốt KHÔNG nói máy biết chữ *thiếu* từ đâu:** nguyên liệu ⇒ `U-045` (**đóng 2026-09-15**: không có ngưỡng, chủ quán tự đọc hai con số rồi tự kết luận; chỗ còn hở là mục tổng quan **bày gì** ⇒ `U-051`); người ⇒ câu **C36** (*ai đang trực trạm nào*) — `U-049` (người **đi giao** là ai) đóng cùng ngày: một trong bốn vai, POS chỉ định; `U-050` (**trạm bị bỏ trống** lúc người ấy đi) đóng **2026-09-15**: POS gánh, và khoảng trống ấy **không** là thiếu người; món ⇒ chưa mở câu nào. | `shop-facts.md` §8.6 (hàng 7) · §8.4 · §3 · §4.9 |

**Cùng ngày 2026-09-08, lượt kế tiếp, chủ quán đóng `U-049` bằng một câu** (T-071) — câu mở buổi
sáng, đóng buổi chiều cùng ngày:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-08) | Ghi ở |
|---|---|---|
| ~~U-049 — người ĐI GIAO là một trong bốn vai của §3 rời quán đi giao, hay là NGƯỜI THỨ NĂM~~ | **Một trong BỐN VAI, và POS chỉ định ai đi từng lần** — nguyên văn: *"1 trong bốn vai trên có thể là bất cứ ai pos sẽ chỉ định."* ⇒ **không** có người thứ năm: con số người của quán là **bốn vai + chủ quán ngoài năm trạm**, *đi giao* không thành trạm thứ sáu và không thêm dòng nào vào bảng ca / bảng lương. Ai đi thì **không có luật cứng** — đúng hình dạng *POS quyết từng ca* đã gặp ở §5.4 · §6.24, nên theo §6.10 việc chỉ định phải **để lại vết**. ⚠️ Lời này **KHÔNG** nói lúc người ấy rời quán thì **trạm của họ ai gánh** — mà §3 đã chốt ba trạm kia là *trạm riêng, không kiêm* ⇒ mở **`U-050`**. Vế §6.7 không đổi một chữ. | `shop-facts.md` **§3** · §6.7 · §8.6 · §7.1 |

Câu này khép nốt **số 6** của `shop-facts.md` §8.6 (*bao nhiêu người đang làm*) — thứ `U-049` tự
khai là đang chặn — nhưng **số 7** (*đang thiếu người hay không*) thì không: nó chuyển từ `U-049`
sang `U-050`. Một lời chốt đóng được một trong hai vế nó chặn vẫn để lại vế kia, đúng hình dạng
`U-034` (2026-09-04) và `U-042` (2026-09-08).

**Ngày 2026-09-15, chủ quán đóng `U-050` bằng một câu, cả hai vế** (T-075) — mở 2026-09-08:

| Câu hỏi cũ | Lời giải (chủ quán, 2026-09-15) | Ghi ở |
|---|---|---|
| ~~U-050 — lúc một trong bốn vai rời quán ĐI GIAO, trạm của người ấy DO AI GÁNH, và khoảng trống ấy có phải là "thiếu người" của mục tổng quan không~~ | **POS gánh, và KHÔNG là thiếu người** — nguyên văn: *"pos gánh, không thiếu người vì đi ship luc quán vắng."* **(1) Ai gánh:** **người đứng quầy** (trạm `quay`) làm thay việc của trạm bị bỏ trống tới lúc người đi giao về ⇒ chữ *"trạm riêng, không kiêm"* của §3 nay có **một ngoại lệ có tên**: trong lúc có người đi giao, `quay` kiêm trạm của người ấy. Quán **không** dừng trạm nào, và chủ quán **không** phải đứng vào. **(2) Thiếu người:** khoảng trống do đi giao **không** tính vào số **7** của §8.6 — vì quán **chỉ cho đi giao lúc vắng**. Chữ *"vì … lúc quán vắng"* là **lý do** chủ quán đưa ra, **không** phải một luật cấm giao lúc đông: không lời nào nói máy chặn hay cảnh báo một chuyến giao lúc quán đông, nên đừng viết luật ấy (**F-004**). ⚠️ Lời *"pos gánh"* **va** lời chốt `U-049` — người đi giao là *"bất cứ ai"* trong bốn vai, kể cả người đứng quầy ⇒ mở **`U-052`**. | `shop-facts.md` **§3** · §8.6 (hàng 7) · §7.1 |

Số **7** của §8.6 hết đứng trên `U-050`; nó còn đứng trên đúng **một** câu — **C36** (*ai đang trực
trạm nào*, `work/admin-questions.md`), vì máy vẫn chưa có dữ liệu nào để so người có mặt với người
cần. `U-052` **không** chặn số 7: lời chốt `U-050` đã nói khoảng trống do đi giao không là thiếu
người, bất kể ai đi.

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
