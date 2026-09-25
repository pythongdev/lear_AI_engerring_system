<a id="top"></a>
# Bảng hỏi — mảng QUẢN TRỊ (admin) của quán

> **File này không sở hữu sự thật nào.** Nó là hai thứ, và chỉ hai thứ:
> chỗ **chủ quán viết câu trả lời**, và chỗ giữ **danh sách việc đề xuất** cho mảng
> admin trước khi chúng đủ chín để vào `work/backlog.md`.
>
> Mỗi câu trả lời xong thì **lời giải đi về owner của nó** (`CLAUDE.md` §2 và §4) —
> chữ nằm lại đây là bản nháp, **không phải bản chính**. Hai bản sao của một sự thật
> là đúng họ lỗi `work/findings.md` **F-001**, nên khi mọi câu đã được chuyển đi,
> file này bị **xoá**, không lưu làm kỷ niệm.
>
> Nó nằm dưới `work/` có lý do: Gate 1b không chấm đường dẫn ở đây (`CLAUDE.md` §5),
> và nó là **working state** giống `work/scope.txt`, không phải tài liệu xuất bản.
>
> **Mở:** 2026-09-02 · **theo yêu cầu của:** chủ quán · **trạng thái:** **cả bốn lời chốt §1 đã về
> owner** — Đ-1 (2026-09-02, T-040) · Đ-3 (2026-09-04, T-050) · **Đ-2 và Đ-4 (2026-09-20, ADM-53)**
> ⇒ §1 nay chỉ còn **một dòng lịch sử trỏ tới owner**. **`C36` cũng đã về owner 2026-09-20**
> (ADM-21) ⇒ đọc lời ấy ở `master_plan/shop-facts.md` **§8.8**, không đọc ở đây. Còn lại ở đây là
> **§3**: **35 câu để trống** (đo 2026-09-25 bằng `grep -c '^> \*\*Trả lời:\*\*$'` — **đếm lại,
> đừng tin con số này**, `work/findings.md` **F-003**), cộng `B11`, `B12`, `B15`, `B16`, `B18` mới trả lời một phần
>
> **2026-09-04 — §2 đã chuyển đi.** Danh sách việc `ADM-01`…`ADM-53` nay ở **`work/backlog_AD.md`**
> (T-052, `docs/decisions.md` **ADR-036**). Sau ADM-53 (2026-09-20) file này chỉ còn **một** việc
> thật: **§3** — câu hỏi cho chủ quán và chỗ chủ quán trả lời. §1 và §2 nay là hai dòng lịch sử
> trỏ đi chỗ khác.

---

## 0. Cách dùng file này

1. **Trả lời ngay dưới câu hỏi**, vào dòng `**Trả lời:**`. Không cần trả lời hết một lượt — trả lời được câu nào thì viết câu ấy.
2. **"Chưa nghĩ tới"** hoặc **"không cần làm"** là câu trả lời **hợp lệ và có ích**. Nó khác hẳn với để trống: để trống thì phiên sau không biết là chưa hỏi hay đã hỏi mà chưa quyết.
3. **Con số thì nói rõ nó là gì.** *"Đúng 4 người, không có người thứ 5"* là một **quyết định** — thêm người thứ năm sau này phải xin phép. *"Khoảng 4 người"* là **ước lượng** — phiên sau được phép hỏi lại. Hai cách viết dẫn tới hai hệ thống khác nhau (`CLAUDE.md` §7.2).
4. **Đừng sửa câu hỏi.** Thấy câu hỏi sai thì viết vào phần trả lời: *"hỏi sai rồi, thực tế là…"*. Câu hỏi hỏi sai cách đã từng xảy ra một lần và được ghi lại (T-033, câu S-4).
5. Trả lời xong một nhóm thì báo — tôi chuyển lời giải về owner, mở task trong `work/backlog.md`, rồi **gạch nhóm ấy khỏi file này**.

---

## 1. Bốn lời chốt ngày 2026-09-01 — **cả bốn đã về owner**, mục này chỉ còn là lịch sử

Chủ quán chốt bốn câu trong phiên ngày **2026-09-01**; hôm ấy **không file nào ghi lại được**, vì
`docs/product.md` đang có thay đổi chưa commit của phiên BA-07 (`work/findings.md` **F-013** ·
**F-014**). Cả bốn lời nay đã đi qua đúng cửa *chủ quán xác nhận lại → chuyển về owner*, nên
**mục này không còn giữ một dữ kiện nào** — đọc lời chốt ở owner của nó, không đọc ở đây
(`work/findings.md` **F-001**):

| Lời | Về owner ngày | Đọc ở |
|---|---|---|
| **Đ-1** — mở cả ba mảng vào phạm vi | 2026-09-02 (T-040) | `master_plan/shop-facts.md` §8.1 · `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4 · `docs/product/1-system-design/architecture.md` §10 |
| **Đ-2** — thứ tự làm | **2026-09-20 (ADM-53)** | `work/backlog.md` → *Thứ tự làm giữa lane admin và các pha* |
| **Đ-3** — nguyên liệu ở mức *sổ ghi tay điện tử* | 2026-09-04 (T-050) | `master_plan/shop-facts.md` §8.4 · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 |
| **Đ-4** — mảng con người làm **cả ba mức** | **2026-09-20 (ADM-53)** | `master_plan/shop-facts.md` **§8.7** · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · `docs/product/1-system-design/architecture.md` **§14.4** |

**Đ-2 đi một đường khác ba lời kia, và đó là chỗ dễ sửa nhầm nhất.** Nó là dữ kiện **xếp lịch của
repo**, không phải dữ kiện của quán ⇒ nhà của nó là `work/backlog.md`, **không** phải
`master_plan/shop-facts.md` (`docs/decisions.md` **ADR-001**).

---

## 2. Việc đề xuất cho mảng admin → đã chuyển sang `work/backlog_AD.md`

**Danh sách việc `ADM-01`…`ADM-53` không còn ở đây.** Nó chuyển sang **`work/backlog_AD.md`** ngày
2026-09-04 (T-052, `docs/decisions.md` **ADR-036**), và ở đó mỗi việc có mô tả dài: vì sao có việc,
không làm thì mất gì, câu hỏi nào đang chặn nó.

**Vì sao chuyển đi.** File này tự khai ở banner đầu trang rằng nó **sẽ bị xoá** khi mọi câu hỏi đã
được chuyển về owner. Một danh sách việc sống trong một file có ngày hết hạn là một danh sách sẽ
biến mất cùng file — và biến mất im lặng.

**Cái ở lại đây là §3:** câu hỏi cho chủ quán cùng chỗ chủ quán viết câu trả lời. Từ 2026-09-20
(ADM-53) đó là **việc duy nhất** file này còn làm — §1 đã cạn, cả bốn lời chốt đều ở owner của
chúng. Trả lời hết §3 thì file này bị **xoá**, đúng như banner đầu trang nói.

| Câu hỏi | Đọc ở |
|---|---|
| Việc `ADM-XX` nào có, vì sao có, chặn bởi câu nào | `work/backlog_AD.md` |
| Việc nào đang *Ready* · *In Progress* · *Done* | `work/backlog.md` |
| Câu hỏi cho chủ quán, và chỗ trả lời | **§3 dưới đây** |

⚠️ **Trả lời một câu ở §3 thì đọc `work/backlog_AD.md` để biết lời ấy gỡ việc nào ra.** Bảng
*Cổng của cả lane* ở đầu file đó nối từng mã câu (`A5`, `B21`, `C36`…) với những việc nó đang chặn.

---

## 3. Câu hỏi

Trả lời theo mã câu cho nhanh — *"A5: bàn nào món xong trước thì bưng trước"*.

### ~~A. Một buổi bán hàng~~ — ĐÃ TRẢ LỜI CẢ MƯỜI CÂU, 2026-09-04

**Chủ quán trả lời `A1`…`A10` trong một lượt ngày 2026-09-04, và T-056 đã chuyển cả mười lời về
owner.** Nhóm này **đóng**: đừng trả lời lại ở đây, và đừng đọc một dữ kiện nào từ chỗ này — nguyên
văn lời chủ quán nằm ở owner bên dưới, một chỗ, không có bản thứ hai (`work/findings.md` **F-001**).

| Mã | Lời chủ quán, rất gọn | Nay đọc ở |
|---|---|---|
| ~~`A1`~~ | chỉ bán **buổi sáng** — một buổi một ngày | `master_plan/shop-facts.md` **§6.23** · §1 (giờ **06:00–11:00**) · chỗ suy ra **S-7** ở §7.2 |
| ~~`A2`~~ | **không** có mở ca / đóng ca — *"cứ đến giờ là bán rồi tối đếm tiền"* | **§6.23** · `docs/decisions.md` **ADR-038** |
| ~~`A3`~~ | **có** tiền đầu két cho POS lấy tiền thối; máy giữ số mặc định **sửa được** | **§8.5** · `quality/invariants.md` **I-021** · mở U-038, đóng 2026-09-06: nhập cả bảng mệnh giá lẫn tổng |
| ~~`A4`~~ | **không** ai lấy tiền giữa buổi; tiền ở két tới cuối buổi | **§8.5** · **I-021** |
| ~~`A5`~~ | **POS quyết**, luật cơ sở **ai tới trước ăn trước** | **§6.24** |
| ~~`A6`~~ | **đôi khi** ưu tiên **khách vội** | **§6.24** |
| ~~`A7`~~ | **11 bàn** — đúng con số §1 đã có từ 2026-08-30 | §1 · **§6.25** · mở U-040, đóng 2026-09-06: 4 chỗ/bàn, đã đánh số — và số bàn đổi **11 → 15** trong cùng lời đáp; **U-042 đóng nốt 2026-09-16**: bốn bàn mới đánh số **nối tiếp 12–15** ⇒ danh sách bàn là **1…15** |
| ~~`A8`~~ | **có** khách đứng chờ, quán xếp hàng chờ | **§6.25** · mở U-039, đóng 2026-09-06: **không**, POS tự điều phối |
| ~~`A9`~~ | **cả hai** — khách tự chọn, đôi khi nhân viên xếp | **§6.25** |
| ~~`A10`~~ | **sáu con số** cho mục tổng quan của chủ quán | **§8.6** · mở U-041, đóng 2026-09-08 qua **ba lượt**: *"còn thiếu gì"* là **cả ba** đường — nguyên liệu (Danh mục §8.4) · **người** (bảng phân vai §3) · món (§4.9) ⇒ §8.6 nay **bảy** hàng; *máy biết bằng cách nào*: nguyên liệu **đóng 2026-09-15** — máy không biết, chủ quán tự đọc hai con số rồi tự kết luận (**U-045**; mục tổng quan bày gì **đóng 2026-09-16** — **U-051**: thời gian nhập · tổng đã dùng · số thiếu máy tự trừ, còn mốc cộng dồn là **U-054**), người **C36** — **đã có lời và về owner 2026-09-20** (**§8.8**: mốc đổi người **ở quầy**), chỗ hở còn lại của vế người là **U-055** (bốn trạm ngoài quầy); (**U-049** đóng 2026-09-08: người đi giao là một trong bốn vai, POS chỉ định; **U-050** đóng 2026-09-15: POS gánh trạm bị bỏ trống, khoảng trống ấy **không** là thiếu người — **U-052 đóng 2026-09-16**: người đứng quầy **không** đi giao, chữ *"bất cứ ai"* hẹp lại còn ba vai) |

⚠️ **Bốn vế chủ quán KHÔNG chạm tới đã thành câu hỏi có mã, không thành suy luận** —
**U-038** · **U-039** · **U-040** · **U-041** ở `docs/product/99-unknowns.md`. *Cả bốn nay đã có
lời (`U-041` là câu cuối, đóng 2026-09-08 — và lời đáp của nó mở ra **U-045**, đóng 2026-09-15, lời đáp ấy lại mở **U-051**, đóng 2026-09-16, và lời đáp ấy mở **U-054**).* Chúng ở đó chứ không
ở đây, vì file này sẽ bị xoá còn `99-unknowns.md` thì không, và vì `scripts/brief.sh` đẩy danh sách
unknown vào mọi phiên mới (`CLAUDE.md` §7.1).

⚠️ **`A7` là bằng chứng sống của `work/findings.md` F-029.** Câu ấy hỏi ba vế; chủ quán trả lời đúng
**vế đã có chủ** — *"quán có 11 bàn"*, con số nằm ở §1 từ **2026-08-30** — và không chạm hai vế còn
sống. Đó chính là chỗ F-029 đoán trước: hỏi lại một dữ kiện đã có chủ thì lời đáp quay về đúng dữ
kiện ấy, còn chỗ thật sự thiếu vẫn thiếu. Dòng cảnh báo T-053 thêm vào câu `A7` **đã kịp** ngăn một
bản thứ hai, nhưng không ngăn được việc hai vế kia bị bỏ qua.

### B. Nguyên liệu
*Đã chốt mức: **sổ ghi tay điện tử**, máy không tự trừ (Đ-3). Nhóm này mở khoá ADM-10 → ADM-15.*

**B11.** Kể tên **những thứ quán mua vào** — gạo/bột, thịt, mộc nhĩ, trứng, giò, rau, hành phi, mắm, gas, than, túi/hộp, nước uống…? Càng liệt kê nhiều càng tốt.
> **Trả lời:** **Đã nhận một phần 2026-09-25 (T-089), dữ kiện ở `master_plan/shop-facts.md` §8.4.** Hai tên gõ nhầm đã được làm rõ và cập nhật tại owner cùng ngày. Còn hỏi: “túi nóng” có phải túi đựng đồ nóng không?

**B12.** Mỗi thứ mua theo **đơn vị gì** (kg, quả, bó, chai, thùng, con)?
> ⚠️ Từ 2026-09-15 đây là chỗ hở **duy nhất** còn lại của danh mục nguyên liệu `shop-facts.md`
> §8.4: phần *ngưỡng* đã đóng (`U-045` — không có ngưỡng), phần *đơn vị* thì không, và nó không
> còn mã `U-XXX` nào giữ hộ — chỉ còn câu này.
> **Trả lời:** **Đã nhận một phần 2026-09-25 (T-089), đơn vị mua ở `master_plan/shop-facts.md` §8.4.** Còn đơn vị của các tên cũ chưa được nhắc lại: nhân thịt, nhân thịt mộc nhĩ, quất, hành tây, mì chính, hạt nêm, đường trắng, đường đen, bột bánh cuốn, hạt tiêu, nước mắm, dầu rửa bát. Chưa xác nhận đơn vị ghi lượng đã dùng hoặc quy đổi bao gói.

**B13.** Quán **mấy ngày mua một lần**? Sáng nào cũng mua, hay mua theo tuần?
> **Trả lời:** **ĐÃ VỀ OWNER 2026-09-25 (T-089)** — đọc cách mua ở `master_plan/shop-facts.md` §8.4.

**B14.** **Ai đi mua**? Chỉ chủ quán, hay có người được giao?
> **Trả lời:** **ĐÃ VỀ OWNER 2026-09-25 (T-089)** — đọc người mua ở `master_plan/shop-facts.md` §8.4.

**B15.** Mua ở **chợ / mối quen / cửa hàng**? Có nhiều nhà cung cấp cho cùng một thứ không?
> **Trả lời:** **Đã nhận một phần 2026-09-25 (T-089), dữ kiện ở `master_plan/shop-facts.md` §8.4.** Nguồn mua đã bổ sung tại owner cùng ngày. Còn hỏi: cùng một mặt hàng có mua từ nhiều mối không.

**B16.** Trả tiền **liền** hay có mối cho **ghi sổ nợ**? Nếu ghi nợ thì trả theo tuần hay tháng?
> **Trả lời:** **Đã nhận một phần 2026-09-25 (T-089), dữ kiện ở `master_plan/shop-facts.md` §8.4.** Còn hỏi: khoản nợ trả theo tuần, tháng hay khi mối yêu cầu?

**B17.** Có **hoá đơn giấy** không, hay chỉ nhớ miệng?
> **Trả lời:** **ĐÃ VỀ OWNER 2026-09-25 (T-089)** — đọc chứng từ/trao đổi tiền hàng tại `master_plan/shop-facts.md` §8.4.

**B18.** Cuối buổi quán có **đếm lại đồ thừa** không? Đếm những thứ gì?
> **Trả lời (2026-09-04, một nửa):** có một **mục tổng nhập hàng ngày**, chủ quán tự nhập số liệu.
> **Loại con số ấy đã chốt 2026-09-06 (U-034, đóng):** mua vào và đã dùng — không phải một mục
> *đồ thừa* riêng. Vế *"đếm những thứ gì"* (danh mục cụ thể) **vẫn chưa trả lời**. Ghi ở
> `master_plan/shop-facts.md` §8.4.

**B19.** **Đồ thừa** hôm nay để mai bán tiếp hay bỏ? Thứ nào để được, thứ nào không?
> **Trả lời:**

**B20.** Hỏng / đổ / cháy giữa buổi thì có ai ghi lại không?
> **Trả lời:**

**B21.** Muốn máy **nhắc "sắp hết X"** thì dựa vào cái gì — chủ quán tự đặt ngưỡng, hay đếm tay rồi nhập vào?
> **Trả lời (2026-09-15, qua `U-045`, đóng):** *"chủ quán tự đọc rôi đưa ra kết luận"* — **không
> có ngưỡng**, máy **không** nhắc *sắp hết*; chủ quán đọc cặp số mua vào · đã dùng rồi tự kết
> luận. Ghi ở `master_plan/shop-facts.md` §8.4. ✅ *Chủ quán đọc ở màn nào, con số nào* cũng
> **đã có lời** — chủ quán chốt **2026-09-16** (`U-051`, đóng): mục tổng quan bày **thời gian
> nhập** · **tổng đã dùng** · **số thiếu = tổng đã nhập − tổng đã dùng** (máy trừ hộ, vẫn không
> kết luận). ⚠️ Chỗ còn hở: hai con số *tổng* ấy cộng dồn **từ mốc nào** ⇒
> `docs/product/99-unknowns.md` **U-054**.

**B22.** Có muốn biết **giá vốn một suất bánh cuốn** không? *(Trả lời "có" là **mở lại Đ-3**: phải chốt định lượng từng thành phần cho từng suất — thứ hôm nay chưa có dữ kiện nào.)*
> **Trả lời:**

### C. Con người
*Mức sâu đã chốt: **cả ba mức** (**Đ-4**) — **về owner 2026-09-20**, đọc ở `master_plan/shop-facts.md` **§8.7**,
đừng đọc ở đây. Nhóm này mở khoá ADM-20 → ADM-24, và bịt chỗ thiếu `architecture.md` §8.*
*✅ **`C36` đã trả lời và đã về owner 2026-09-20** (§8.8) ⇒ **ADM-21 `Done`**. Mười ba câu
`C23`…`C35` còn lại chưa câu nào có lời.*

**C23.** Quán có **bao nhiêu người** làm, kể cả người nhà?
> ⚠️ Câu này hỏi **tổng số**. Vế *người đi giao nằm trong hay ngoài bốn vai của
> `master_plan/shop-facts.md` §3* thì **đã có lời** — chủ quán chốt 2026-09-08 (`U-049`, đóng):
> **một trong bốn vai**, POS chỉ định từng lần, không có người thứ năm. Nên C23 nay chỉ còn hỏi
> đúng phần nó hỏi: **đầu người thật**, kể cả người nhà. ✅ Vế *trạm bị bỏ trống lúc người ấy đi*
> cũng **đã có lời** — chủ quán chốt 2026-09-15 (`U-050`, đóng): **người đứng quầy (POS) gánh**, và
> khoảng trống ấy **không** là *thiếu người*. ✅ Ca cuối cùng của việc xếp ca cũng **đã có lời** — chủ quán chốt
> **2026-09-16** (`U-052`, đóng): **người đứng quầy không đi giao**, nên chữ *"bất cứ ai"* của
> `U-049` hẹp lại còn **ba** vai (`trang_banh` · `gap_banh` · `canh`+`don_ban`) và trạm `quay`
> không bao giờ trống vì đi giao. C23 nay không còn câu U-XXX nào đứng cạnh.
> **Trả lời:**

**C24.** Người nhà làm **không lương** có phải nằm trong bảng lương không?
> **Trả lời:**

**C25.** Ai làm **cố định một trạm**, ai làm được nhiều trạm và đổi trong buổi?
> **Trả lời:**

**C26.** Trả lương theo **buổi / ngày / tháng**? Bao nhiêu một đơn vị?
> **Trả lời:**

**C27.** Có **tăng ca / làm thêm buổi** không? Tính tiền thế nào?
> **Trả lời:**

**C28.** Có **thưởng** không — ngày đông khách, lễ Tết?
> **Trả lời:**

**C29.** Có **tạm ứng giữa tháng** không? Ai duyệt?
> **Trả lời:**

**C30.** Nghỉ có báo trước / nghỉ đột xuất có trừ tiền không?
> **Trả lời:**

**C31.** **Chấm công bằng cách nào**? Nhân viên tự bấm trên máy, hay người đứng quầy điểm danh đầu buổi?
> **Trả lời:**

**C32.** Đi muộn có bị trừ không? Muộn bao nhiêu phút thì mới tính là muộn?
> **Trả lời:**

**C33.** Kỳ trả lương vào **ngày nào trong tháng**?
> **Trả lời:**

**C34.** **Ai được xem bảng lương** — chỉ chủ quán, hay người đứng quầy cũng thấy?
> **Trả lời:**

**C35.** Nhân viên có được xem **công của chính mình** không?
> **Trả lời:**

~~**C36.**~~ **ĐÃ TRẢ LỜI 2026-09-20 · ĐÃ VỀ OWNER 2026-09-20 (ADM-21) — đừng trả lời lại, và
đừng đọc một dữ kiện nào từ đây.**

> Câu hỏi cũ: *người đứng quầy đổi giữa buổi (A đi ăn, B thay) — quán có muốn máy ghi lại mốc đổi
> ấy không?* Chủ quán trả lời **có**; **ADM-53** hỏi, **ADM-21** chuyển lời về owner cùng ngày.
>
> **Nguyên văn lời đáp, phạm vi của nó, và ba vế nó KHÔNG nói: `master_plan/shop-facts.md` §8.8.**
> Hành vi nghiệp vụ: `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · hệ quả kiến trúc:
> `docs/product/1-system-design/architecture.md` §14.5. Một chỗ, không có bản thứ hai
> (`work/findings.md` **F-001**).
>
> ⚠️ **Ba vế chủ quán KHÔNG chạm tới đã thành câu hỏi có mã, không thành suy luận** — **U-055**
> (bốn trạm ngoài quầy) · **U-056** (ai khai cái mốc) · **U-057** (vế *ai bấm* của hai cửa ghi
> ngoài quầy), cả ba ở `docs/product/99-unknowns.md`. Chúng ở đó chứ không ở đây, vì file này sẽ bị
> xoá còn `99-unknowns.md` thì không, và vì `scripts/brief.sh` đẩy danh sách unknown vào mọi phiên
> mới (`CLAUDE.md` §7.1).

### D. Sản phẩm
*Nhóm này mở khoá ADM-30 → ADM-33.*

**D37.** Ngoài bánh cuốn, trứng, giò, canh — quán còn bán **nước uống** không? Nếu có thì những gì?
> **Trả lời:**

**D38.** Có **món theo mùa** hoặc **món chỉ bán cuối tuần** không?
> **Trả lời:**

**D39.** Quán **đổi giá bao lâu một lần**? Đổi vào lúc nào trong ngày?
> **Trả lời:**

**D40.** Ai được đổi giá — **chỉ chủ quán**, hay người đứng quầy cũng được?
> **Trả lời:**

**D41.** Có bao giờ **bán giá khác cho khách quen**, hoặc giảm giá không? *(Hôm nay hệ thống **cấm** chuyện này: `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.2 nói giá do hệ thống xác định, khách và nhân viên không đặt được giá. Trả lời "có" là mở lại một luật đã chốt.)*
> **Trả lời:**

**D42.** Có **combo**, **suất trẻ em**, hay **suất lớn / suất nhỏ** không?
> **Trả lời:**

**D43.** Menu QR cho khách có cần **ảnh món** không, hay chỉ tên và giá là đủ?
> **Trả lời:**

### E. Tài chính
*Nhóm này mở khoá ADM-40 → ADM-45.*

**E44.** Ngoài tiền hàng và lương, quán còn **chi những khoản gì**? (thuê nhà, điện, nước, gas, rác, wifi, sửa đồ, xăng xe đi giao…)
> **Trả lời:**

**E45.** Khoản nào **cố định hằng tháng**, khoản nào chi lặt vặt trong ngày?
> **Trả lời:**

**E46.** Chi lặt vặt lấy **từ két bán hàng** hay từ tiền riêng của chủ quán?
> **Trả lời:**

**E47.** Muốn xem **lãi/lỗ theo ngày**, hay theo **tháng** là đủ?
> **Trả lời:**

**E48.** Có muốn biết **món nào bán chạy** và **giờ nào đông khách** không?
> **Trả lời:**

**E49.** Tiền cuối buổi **nộp ngân hàng** hay để nhà? Đường đi của khoản tiền đó có cần ghi lại không?
> **Trả lời:**

**E50.** Quán có phải **báo thuế** hoặc có sổ sách gì phải nộp cho ai không?
> **Trả lời:**

**E51.** Người đi giao cầm tiền về nộp lại — có bao giờ **nộp thiếu hoặc nộp muộn** không? Quán có muốn máy theo dõi chuyện đó không?
> **Trả lời:**

### F. Chung
*Nhóm này mở khoá ADM-50 → ADM-52.*

**F52.** Phần quản trị này **chạy trên gì** — máy tính ở quầy, máy tính bảng, hay điện thoại của chủ quán?
> **Trả lời:**

**F53.** Có muốn **xem từ nhà**, ngoài giờ bán không?
> **Trả lời:**

**F54.** Mất điện / mất mạng: quán ghi sổ giấy rồi **ai nhập bù**, và nhập vào lúc nào?
> **Trả lời:**

**F55.** Ngoài lương, còn thứ gì trong đây **không muốn nhân viên nhìn thấy** — giá nhập, lãi lỗ, doanh thu?
> **Trả lời:**

---

## 4. Trả lời xong thì lời giải đi đâu

Không có câu trả lời nào ở lại file này. Bảng đường đi (`CLAUDE.md` §2 và §4):

| Loại lời giải | Về owner nào |
|---|---|
| Dữ kiện về cái quán — giá, giờ, số người, cách làm | `master_plan/shop-facts.md` (mảng admin: **§8**) |
| Luật nghiệp vụ, hành vi sản phẩm | `docs/product/0-ba/` — mảng admin vào `0-ba/admin/01-ranh-gioi.md` |
| Ranh giới hệ thống làm gì / không làm gì | `docs/product/0-ba/admin/01-ranh-gioi.md` **§1.6** + `docs/product/1-system-design/architecture.md` **§14** |
| Chọn giữa hai phương án đều chạy được | `docs/decisions.md` (ADR) |
| Luật không bao giờ được vi phạm | `quality/invariants.md` |
| Việc phải làm | mô tả vào `work/backlog_AD.md`, trạng thái vào `work/backlog.md` |
| Câu hỏi hỏi rồi mà **vẫn chưa có lời giải** | `docs/product/99-unknowns.md`, dạng `U-XXX` |

⚠️ **Mười một đường dẫn chết đã sửa 2026-09-04 (T-052)** — đếm được hôm ấy, đếm lại nếu bạn nghi (`work/findings.md` **F-003**): **bốn** ở bảng ngay trên, **hai** ở bảng *mục admin* dưới, **ba** ở §1 (hàng Đ-1, hàng Đ-4) và **hai** ở §3 (câu `C36`, câu `D41`). Chúng trỏ về `docs/product.md` và
`docs/architecture.md` — hai file nay là **bản lưu** và **đã dời**, sau khi `docs/product/` được cắt
theo pha (`docs/decisions.md` **ADR-014**, năm lượt DOC-1…DOC-5, xong 2026-09-03). Một câu trả lời
đi theo đường cũ sẽ được ghi vào bản lưu — nơi banner của chính nó viết *"Không sửa ở đây"*. File
này nằm dưới `work/` nên Gate 1b không chấm đường dẫn của nó (`CLAUDE.md` §5); đó là lý do ba dòng
ấy sống sót qua cả năm lượt chuyển pointer.

**Và lời giải ấy vào MỤC RIÊNG của mảng admin, không chen vào mục của mảng bán hàng**
(`docs/decisions.md` **ADR-013**, chủ repo yêu cầu 2026-09-02). Ba mục ấy đã có sẵn, cứ viết tiếp
vào đó:

| Tài liệu | Mục admin | Giữ gì |
|---|---|---|
| `docs/product/0-ba/admin/01-ranh-gioi.md` | **§1.6** | ranh giới và luật nghiệp vụ của ba mảng |
| `docs/product/1-system-design/architecture.md` | **§14** | mặt kiến trúc, và bốn chỗ chạm với mảng bán hàng |
| `master_plan/shop-facts.md` | **§8** | dữ kiện quán của ba mảng — §8.3 nói cách đánh số tiếp |

Nhật ký chốt thì **không** tách: dòng ngày tháng vẫn vào `master_plan/shop-facts.md` §7.1 như mọi
lời chốt khác, chỉ khác cột *Ghi ở* trỏ về §8.

**Vì sao 55 câu này không nằm thẳng ở *Unknowns*:** `scripts/brief.sh` in mục ấy vào **mọi phiên
mới** và cắt ở **12 mục** (`CLAUDE.md` §7.1). Đổ 55 câu vào đó là làm mù chính cái cơ chế giữ cho
phiên sau biết mình đang thiếu gì — đúng họ lỗi **F-012**. Chỉ câu nào **đã hỏi mà chủ quán chưa
quyết được** mới lên *Unknowns*; câu chưa hỏi thì ở đây.
