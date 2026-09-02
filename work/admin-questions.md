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
> **Mở:** 2026-09-02 · **theo yêu cầu của:** chủ quán · **trạng thái:** 4 câu đã chốt — **Đ-1 đã về owner
> 2026-09-02 (T-040)**, Đ-2/Đ-3/Đ-4 chưa — và **55 câu đang chờ**

---

## 0. Cách dùng file này

1. **Trả lời ngay dưới câu hỏi**, vào dòng `**Trả lời:**`. Không cần trả lời hết một lượt — trả lời được câu nào thì viết câu ấy.
2. **"Chưa nghĩ tới"** hoặc **"không cần làm"** là câu trả lời **hợp lệ và có ích**. Nó khác hẳn với để trống: để trống thì phiên sau không biết là chưa hỏi hay đã hỏi mà chưa quyết.
3. **Con số thì nói rõ nó là gì.** *"Đúng 4 người, không có người thứ 5"* là một **quyết định** — thêm người thứ năm sau này phải xin phép. *"Khoảng 4 người"* là **ước lượng** — phiên sau được phép hỏi lại. Hai cách viết dẫn tới hai hệ thống khác nhau (`CLAUDE.md` §7.2).
4. **Đừng sửa câu hỏi.** Thấy câu hỏi sai thì viết vào phần trả lời: *"hỏi sai rồi, thực tế là…"*. Câu hỏi hỏi sai cách đã từng xảy ra một lần và được ghi lại (T-033, câu S-4).
5. Trả lời xong một nhóm thì báo — tôi chuyển lời giải về owner, mở task trong `work/backlog.md`, rồi **gạch nhóm ấy khỏi file này**.

---

## 1. Bốn lời đã chốt ngày 2026-09-01 — Đ-1 đã về owner, ba lời còn lại thì chưa

Chủ quán chốt trong phiên ngày 2026-09-01. Lúc ấy **chưa file nào ghi lại**, vì `docs/product.md`
đang có thay đổi chưa commit của phiên BA-07 và sửa chồng lên là đúng cơ chế sự cố đã ghi bốn lần
ở `work/findings.md` (F-013, F-014).

**2026-09-02 — chủ quán xác nhận lại Đ-1** (*"Đ-1 → trả lời đồng ý theo lời chốt"*) và **T-040 đã
chuyển nó về owner**. Ba lời còn lại **chưa được xác nhận lại và chưa đi đâu cả**: chúng vẫn chỉ
tồn tại trong file này, mà file này không sở hữu sự thật nào.

| # | Câu | Lời chốt | Phải về đâu |
|---|---|---|---|
| ~~Đ-1~~ | Có mở lại ranh giới hệ thống không? | **Mở cả ba** — nguyên liệu, con người, tài chính vào phạm vi | ✅ **đã về owner 2026-09-02 (T-040)**: `docs/product.md` §1.4 · `docs/architecture.md` §10 · `master_plan/shop-facts.md` §7.1 |
| Đ-2 | Thứ tự làm | **Đóng nốt BA-08 → BA-12 trước**, rồi mới chạy nhánh admin | `work/backlog.md` |
| Đ-3 | Nguyên liệu làm ở mức nào | **Sổ ghi tay điện tử** — máy **không** tự trừ kho theo công thức | `master_plan/shop-facts.md` **§8** · `docs/product.md` **§1.6** (mục admin, ADR-013) |
| Đ-4 | Con người làm tới đâu | **Cả ba mức**: ai đang trực trạm + chấm công + tính lương | `master_plan/shop-facts.md` **§8** · `docs/architecture.md` **§14** (mục admin, ADR-013) |

**Đ-1 lật ngược một câu đang nằm trong tài liệu — và câu ấy nay đã sửa (T-040, 2026-09-02).**
`docs/product.md` §1.4 từng viết *"Không quản lý nguyên liệu, tồn kho, chấm công hay kế toán"*, và
`docs/architecture.md` §10 xếp chúng vào *"đã quyết định không làm"*; cả hai dòng đã bị xoá, ngày
chốt nằm ở `master_plan/shop-facts.md` §7.1. Việc trong §2 dưới đây vì thế **hết mâu thuẫn với
owner của chính nó** — nhưng mở ranh giới mới chỉ là *được phép*: mảng nào vào MVP vẫn là câu của
**BA-09**.

**Đ-3 đóng luôn một câu chưa ai hỏi.** Chọn mức sổ tay nghĩa là hệ thống **không cần biết một suất
bánh ăn hết bao nhiêu gam gạo**. Định lượng từng thành phần là kiến thức của người làm, không phải
tham số của phần mềm — cùng một lối nghĩ với lời chốt *"máy không gom, người gom"* (2026-08-31).
Muốn biết giá vốn một suất thì phải mở lại câu này (**B22** bên dưới).

---

## 2. Việc đề xuất cho mảng admin

**Chưa cái nào nằm trong `work/backlog.md`.** Đợi câu trả lời ở §3 rồi mới mở task, vì một task mở
sớm trước khi biết luật là một task sẽ phải viết lại.

Cột **L** là mức rủi ro `CLAUDE.md` §3 (L0 không giấy tờ → L3 phải review thiết kế trước khi viết mã).

### Nhánh 0 — chạy trước, đã nằm sẵn trong backlog

| Việc | Trạng thái hôm nay |
|---|---|
| **T-039** — chủ quán trả lời U-021 → U-024 | đang dở trong cây, **chưa commit** |
| **BA-08** ngoại lệ · **BA-09** phạm vi MVP · **BA-10** ADR · **BA-11** scenario · **BA-12** lát cắt sản xuất theo mẻ | Ready |
| **T-035** brief bảo phiên mới xoá scope của phiên đang chạy (F-014) | Ready |

### Nhánh A — Điều hành một buổi bán (phần còn thiếu)

| # | Việc | L | Vì sao cần |
|---|---|:--:|---|
| ADM-01 | **Ca bán / buổi bán** — tài liệu hiện **không có** khái niệm này | L2 | doanh thu tính theo *ngày*, đối soát theo *tối*, nhưng không ai mở/đóng ca ⇒ "cuối buổi" không có mốc bắt đầu |
| ADM-02 | **Thứ tự ưu tiên bàn** — bàn nào bưng trước | L1 | chưa có ở đâu; hôm nay chỉ có luật hiển thị *"cũ nhất lên đầu"* |
| ADM-03 | **Sức chứa & khách chờ bàn** | L1 | "khách vào khách ra" hiện chỉ có nửa *trong quán* |
| ADM-04 | Màn **tổng quan buổi bán cho chủ quán**, khác màn POS của quầy | L1 | chủ quán không đứng quầy vẫn muốn liếc một cái |

### Nhánh B — Nguyên liệu · mức **sổ ghi tay điện tử** (Đ-3)

| # | Việc | L |
|---|---|:--:|
| ADM-10 | Danh mục nguyên liệu + đơn vị tính | L1 |
| ADM-11 | **Phiếu nhập**: mua gì · bao nhiêu · giá · của ai · ai đi mua · trả liền hay ghi nợ | L2 |
| ADM-12 | Ghi **xuất / hao hụt / huỷ** cuối buổi, người nhập bằng tay | L2 |
| ADM-13 | Tồn **ước tính** + nhắc sắp hết — **chỉ nhắc, không chặn** (theo tiền lệ U-018) | L1 |
| ADM-14 | Nối *"hết nguyên liệu"* với nút **tạm dừng nhận đơn** đã có (`shop-facts.md` §6.8) | L1 |
| ADM-15 | **Công nợ nhà cung cấp** — nợ tiền hàng, khác hẳn nợ của khách (`architecture.md` §12) | L2 |

### Nhánh C — Con người · **cả ba mức** (Đ-4)

| # | Việc | L |
|---|---|:--:|
| ADM-20 | Hồ sơ nhân viên (tên, liên hệ, ngày vào, trạm làm được) | L1 |
| ADM-21 | **Ai đang trực trạm nào, lúc này** — bịt chỗ thiếu `architecture.md` §8, mở khoá luật quyền gắn **CHỖ ĐỨNG** | **L2** |
| ADM-22 | **Chấm công** giờ vào / giờ ra từng buổi | L2 |
| ADM-23 | **Bảng lương**: đơn giá công · tạm ứng · kỳ trả · số phải trả | **L3** — chạm tiền |
| ADM-24 | Quyền xem: lương chỉ chủ quán thấy | L2 |

### Nhánh D — Sản phẩm

| # | Việc | L |
|---|---|:--:|
| ADM-30 | Màn sửa **giá thành phần** + xem trước bốn suất thành bao nhiêu (`architecture.md` §6.1) | L2 |
| ADM-31 | Bật / tắt bán một món (luật đã chốt `docs/product.md` §3.3.4) | L1 |
| ADM-32 | Thêm món / nhóm tuỳ chọn mới — đụng ranh giới `shop-facts.md` §6.12 | L2 |
| ADM-33 | Ảnh, mô tả, thứ tự hiển thị món trên menu QR | L1 |

### Nhánh E — Tài chính

| # | Việc | L |
|---|---|:--:|
| ADM-40 | Báo cáo **doanh thu ngày**, cộng từ hai nguồn (luật đã chốt `docs/product.md` §4.10) | L2 |
| ADM-41 | Màn **đối soát cuối ngày**, ngưỡng lệch 0đ, **không có** nút "đóng ca dù lệch" | **L3** |
| ADM-42 | **Sổ chi** — nguyên liệu, lương, điện nước, thuê nhà, chi vặt | L2 |
| ADM-43 | **Lãi / lỗ** theo ngày và theo tháng | L2 |
| ADM-44 | **Quỹ tiền mặt & két** — tiền đầu buổi, nộp về, rút ra | **L3** |
| ADM-45 | Báo cáo bán chạy / giờ cao điểm | L1 |

### Nhánh F — Nền dùng chung cho cả bốn nhánh trên

| # | Việc | L |
|---|---|:--:|
| ADM-50 | **Vết thao tác** — ai · lúc nào · sửa gì · giá trị cũ (chỗ thiếu `architecture.md` §8) | **L3** |
| ADM-51 | Phân quyền màn quản trị: ai xem được lương, giá vốn, báo cáo | L2 |
| ADM-52 | **Nhập bù sau khi mất điện** — quán bán bằng sổ giấy rồi nhập lại (`shop-facts.md` §6.11) | L2 |
| ~~**ADM-53**~~ | ~~Sửa `docs/product.md` §1.4 + `architecture.md` §10 + `shop-facts.md` §7.1 để ghi bốn lời chốt ở §1~~ — **phần Đ-1 xong 2026-09-02 (T-040)**; còn lại **Đ-2** (thứ tự làm → `work/backlog.md`), **Đ-3** và **Đ-4** (mức sâu của mảng nguyên liệu và mảng con người → `shop-facts.md`, mục mới) | L1 |

⇒ **Phần chặn nhất của ADM-53 đã xong**: BA-09 nay đọc được ranh giới đúng ở `docs/product.md`
§1.4, nên nó không còn nguy cơ chốt "MVP gồm những gì" theo ranh giới cũ rồi phải viết lại lần hai.
Phần còn lại của ADM-53 — Đ-2, Đ-3, Đ-4 — **chờ chủ quán xác nhận lại** đúng cách Đ-1 vừa được xác
nhận; chưa xác nhận thì chưa chuyển, vì chuyển một lời chốt cũ mà chủ quán không nhắc lại là tự
quyết thay chủ quán (`CLAUDE.md` §3.5).

---

## 3. Câu hỏi

Trả lời theo mã câu cho nhanh — *"A5: bàn nào món xong trước thì bưng trước"*.

### A. Một buổi bán hàng
*Nhóm này mở khoá: ADM-01 → ADM-04, và BA-12.*

**A1.** Một ngày quán bán **mấy buổi**? Chỉ buổi sáng, hay có cả chiều/tối? Mấy giờ tới mấy giờ?
> **Trả lời:**

**A2.** Quán có khái niệm **"mở ca / đóng ca"** không, hay cứ đến giờ là bán rồi tối đếm tiền?
> **Trả lời:**

**A3.** Đầu buổi có ai **đếm tiền lẻ trong két** để lấy tiền thối không? Khoảng bao nhiêu? Con số đó có cần nhập vào máy không?
> **Trả lời:**

**A4.** Giữa buổi có ai **nộp bớt tiền** cho chủ quán không, hay tiền nằm trong két tới cuối buổi?
> **Trả lời:**

**A5.** **Bàn nào bưng trước?** Bàn gọi trước ra trước · bàn nào món xong trước thì bưng trước · hay người bưng tự nhìn mà quyết?
> **Trả lời:**

**A6.** Có ca nào quán **cố ý ưu tiên** không — khách quen, người già, đoàn đông người, khách nói đang vội?
> **Trả lời:**

**A7.** Quán có **bao nhiêu bàn**, mỗi bàn mấy chỗ ngồi? Bàn đã đánh số sẵn chưa?
> **Trả lời:**

**A8.** Đông khách quá thì có **khách đứng chờ bàn** không? Ai nhớ ai tới trước? Quán có muốn máy giữ hàng chờ ấy không?
> **Trả lời:**

**A9.** Khách vào **tự chọn bàn** hay nhân viên xếp chỗ?
> **Trả lời:**

**A10.** Chủ quán lúc **không đứng quầy** thì muốn nhìn thấy gì trên điện thoại của mình?
> **Trả lời:**

### B. Nguyên liệu
*Đã chốt mức: **sổ ghi tay điện tử**, máy không tự trừ (Đ-3). Nhóm này mở khoá ADM-10 → ADM-15.*

**B11.** Kể tên **những thứ quán mua vào** — gạo/bột, thịt, mộc nhĩ, trứng, giò, rau, hành phi, mắm, gas, than, túi/hộp, nước uống…? Càng liệt kê nhiều càng tốt.
> **Trả lời:**

**B12.** Mỗi thứ mua theo **đơn vị gì** (kg, quả, bó, chai, thùng, con)?
> **Trả lời:**

**B13.** Quán **mấy ngày mua một lần**? Sáng nào cũng mua, hay mua theo tuần?
> **Trả lời:**

**B14.** **Ai đi mua**? Chỉ chủ quán, hay có người được giao?
> **Trả lời:**

**B15.** Mua ở **chợ / mối quen / cửa hàng**? Có nhiều nhà cung cấp cho cùng một thứ không?
> **Trả lời:**

**B16.** Trả tiền **liền** hay có mối cho **ghi sổ nợ**? Nếu ghi nợ thì trả theo tuần hay tháng?
> **Trả lời:**

**B17.** Có **hoá đơn giấy** không, hay chỉ nhớ miệng?
> **Trả lời:**

**B18.** Cuối buổi quán có **đếm lại đồ thừa** không? Đếm những thứ gì?
> **Trả lời:**

**B19.** **Đồ thừa** hôm nay để mai bán tiếp hay bỏ? Thứ nào để được, thứ nào không?
> **Trả lời:**

**B20.** Hỏng / đổ / cháy giữa buổi thì có ai ghi lại không?
> **Trả lời:**

**B21.** Muốn máy **nhắc "sắp hết X"** thì dựa vào cái gì — chủ quán tự đặt ngưỡng, hay đếm tay rồi nhập vào?
> **Trả lời:**

**B22.** Có muốn biết **giá vốn một suất bánh cuốn** không? *(Trả lời "có" là **mở lại Đ-3**: phải chốt định lượng từng thành phần cho từng suất — thứ hôm nay chưa có dữ kiện nào.)*
> **Trả lời:**

### C. Con người
*Đã chốt: làm **cả ba mức** (Đ-4). Nhóm này mở khoá ADM-20 → ADM-24, và bịt chỗ thiếu `architecture.md` §8.*

**C23.** Quán có **bao nhiêu người** làm, kể cả người nhà?
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

**C36.** Người đứng quầy **đổi giữa buổi** (A đi ăn, B thay) — quán có muốn máy ghi lại mốc đổi ấy không? *(Câu này quyết định ADM-21, và nó đang chặn luật quyền huỷ đơn / hoàn tiền: hôm nay `docs/architecture.md` §4 nói quyền gắn **chỗ đứng** chứ không gắn chức vụ, nhưng không có dữ liệu nào ghi ai đang đứng đâu.)*
> **Trả lời:**

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

**D41.** Có bao giờ **bán giá khác cho khách quen**, hoặc giảm giá không? *(Hôm nay hệ thống **cấm** chuyện này: `docs/product.md` §4.2 nói giá do hệ thống xác định, khách và nhân viên không đặt được giá. Trả lời "có" là mở lại một luật đã chốt.)*
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
| Dữ kiện về cái quán — giá, giờ, số người, cách làm | `master_plan/shop-facts.md` |
| Luật nghiệp vụ, hành vi sản phẩm | `docs/product.md` |
| Ranh giới hệ thống làm gì / không làm gì | `docs/product.md` §1.4 + `docs/architecture.md` §10 |
| Chọn giữa hai phương án đều chạy được | `docs/decisions.md` (ADR) |
| Luật không bao giờ được vi phạm | `quality/invariants.md` |
| Việc phải làm | `work/backlog.md` |
| Câu hỏi hỏi rồi mà **vẫn chưa có lời giải** | `docs/product.md` → *Unknowns*, dạng `U-XXX` |

**Và lời giải ấy vào MỤC RIÊNG của mảng admin, không chen vào mục của mảng bán hàng**
(`docs/decisions.md` **ADR-013**, chủ repo yêu cầu 2026-09-02). Ba mục ấy đã có sẵn, cứ viết tiếp
vào đó:

| Tài liệu | Mục admin | Giữ gì |
|---|---|---|
| `docs/product.md` | **§1.6** | ranh giới và luật nghiệp vụ của ba mảng |
| `docs/architecture.md` | **§14** | mặt kiến trúc, và chỗ chạm với mảng bán hàng |
| `master_plan/shop-facts.md` | **§8** | dữ kiện quán của ba mảng — §8.3 nói cách đánh số tiếp |

Nhật ký chốt thì **không** tách: dòng ngày tháng vẫn vào `master_plan/shop-facts.md` §7.1 như mọi
lời chốt khác, chỉ khác cột *Ghi ở* trỏ về §8.

**Vì sao 55 câu này không nằm thẳng ở *Unknowns*:** `scripts/brief.sh` in mục ấy vào **mọi phiên
mới** và cắt ở **12 mục** (`CLAUDE.md` §7.1). Đổ 55 câu vào đó là làm mù chính cái cơ chế giữ cho
phiên sau biết mình đang thiếu gì — đúng họ lỗi **F-012**. Chỉ câu nào **đã hỏi mà chủ quán chưa
quyết được** mới lên *Unknowns*; câu chưa hỏi thì ở đây.
