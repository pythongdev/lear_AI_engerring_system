<a id="top"></a>
# Sổ rủi ro pha 1 — mỗi rủi ro một cơ chế ĐÃ VIẾT RA, một người chịu, một dấu hiệu

*Bước 10/14 của pha 1 — **P1-10**, chốt 2026-09-08
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Đầu vào: [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1 · §2 · §3 · §4 (bốn hàng *P1-10 —
sổ rủi ro* của bốn mục *Bước sau đọc gì*) · [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md)
§2 · §3 · [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 ·
[`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §3 · §4 ·
[`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1.2 · §1.3 · §2 · §3 ·
[`architecture.md`](architecture.md) §3.4 · §4 · §6.3 · §6.4 · §7 · `master_plan/shop-facts.md`
§6.4 · §6.10 · §6.11 · §6.14 · §8.5 · `quality/invariants.md`.*

> **Mục này sở hữu đúng một thứ: SỔ RỦI RO của pha 1** — cái gì hỏng thì quán mất gì, **cơ chế nào
> đang chặn nó và đọc cơ chế ấy ở đâu**, **ai chịu**, và **dấu hiệu nó đang xảy ra**.
>
> **Nó không sở hữu một cơ chế nào.** Cột *Cơ chế chặn* **trỏ** về mục đã viết ra cơ chế ấy và cố
> ý **không chép** lời của nó — bản thứ hai luôn trôi (`work/findings.md` **F-001**). Một rủi ro
> chưa có mục nào sở hữu cơ chế thì ở đây ghi thẳng **chưa có cơ chế**, không mượn tạm một câu.
>
> **Nó không sở hữu một mệnh đề bất biến nào.** `I-0xx` có nhà ở `quality/invariants.md`; **tầng**
> giữ từng mệnh đề và **phép đối chiếu** của nó ở [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md).
>
> **Nó không sở hữu một dữ kiện quán nào.** Ngưỡng lệch 0đ, ba nguồn đối soát, luật cho nợ, luật
> hoàn tiền, tiền đầu két đều thuộc `master_plan/shop-facts.md` (**ADR-001**).
>
> **Ở đây không có tên bảng, tên cột, tên ràng buộc, endpoint hay route** (**ADR-035**).
>
> **Vì sao mục này tồn tại.** Năm rủi ro lớn nhất của dự án tới hôm nay chỉ sống ở
> `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` §6 — một **bản nháp** mang banner
> *"không sửa ở đây"* và **không sở hữu sự thật nào** (**ADR-014**). Bảng ấy viết **trước** ba luật
> đường tiền đã chốt từ đó: **cho nợ** · **hoàn tiền tính ngày hoàn** · **đối soát ba nguồn ngưỡng
> 0đ**. Một sổ rủi ro thiếu ba thứ ấy là sổ của một hệ thống khác (§1.1).

---

## 0. Cách đọc — sáu cột, và năm luật

| Cột | Nó trả lời câu gì |
|---|---|
| **Mã** | `RR-x` — **nhãn cục bộ của file này**, để các bước sau trỏ được vào đúng một dòng. Nó không phải mã dùng chung của repo (cùng kiểu `PT-x` ở §2 của [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) và `RB-x` ở §2 của [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md)) |
| **Rủi ro** | cái gì hỏng — một câu, không phải một chủ đề |
| **Hậu quả ở quán** | quán mất gì, kể bằng chuyện xảy ra **ở quán**: khách, két, bàn, người bấm — không bằng thuật ngữ hệ thống |
| **Cơ chế chặn — chỗ đọc** | **cái gì đang giữ nó**, kèm mục pha 1 đã viết ra cái ấy |
| **Người chịu** | một vai **đã có** trong tài liệu, không phải một vai đặt ra ở đây |
| **Dấu hiệu nó ĐANG xảy ra** | quan sát được bằng thứ quán **đã có** trong tay |

Năm luật khi đọc và khi thêm một dòng:

1. **Một dòng chỉ được đọc là *đã chặn* khi cột *Cơ chế chặn* chỉ tên được một mục pha 1 ĐÃ VIẾT
   RA.** Không có mục ấy ⇒ dòng ghi thẳng **⛔ chưa có cơ chế** kèm mã của chỗ đang thiếu.
   **`RR-9` là dòng như thế**, và nó nằm trong bảng để không bị quên chứ không phải để trông như đã
   được chặn.
2. **"Cẩn thận hơn", "chú ý", "nhớ kiểm tra" không phải cơ chế.** Đó là ranh giới duy nhất giữa một
   sổ rủi ro thật và một sổ trang trí.
3. **Cột *Dấu hiệu* là cột đắt nhất, và nó phải đo được bằng thứ đã có** — bảng đối soát cuối ngày,
   bảng quầy, cái vết, dòng *còn N lượt bán trên giấy chưa nhập*. Một dấu hiệu phải dựng thêm một
   phép đo mới đo được là một dấu hiệu không ai đo (cùng luật với §2 của
   [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md); `work/findings.md` **F-012**).
4. **Người chịu là một vai đã có:** *người đứng quầy* (POS) · *chủ quán* · *POS hoặc chủ quán*.
   Đặt ra một vai mới ở đây là đặt ra một dữ kiện quán (`CLAUDE.md` §3.5).
5. **Cột *Cơ chế chặn* trỏ, không chép.** Lời của cơ chế ở mục sở hữu nó; ở đây chỉ đủ để nhận ra
   hàng (**F-001**).

---

## 1. Chín rủi ro — bảng

**Thứ tự là thứ tự tiền đi ra khỏi quán, không phải thứ tự chữ cái.** Năm dòng đầu là **đường
tiền**; `RR-6` là **đường truy**; `RR-7` là **đường bánh**; `RR-8` xuống cuối **có chủ ý** vì nó là
rủi ro duy nhất đã có đường lùi viết ra; `RR-9` đứng cuối vì nó là dòng **chưa có cơ chế** (§1.2).

| Mã | Rủi ro | Hậu quả ở quán | Cơ chế chặn — chỗ đọc | Người chịu | Dấu hiệu nó ĐANG xảy ra |
|---|---|---|---|---|---|
| **RR-1** | Một lần thu **chuyển khoản** được bấm *đã nhận tiền* trong khi tiền chưa về tài khoản | Khách cầm hàng đi. Tối đối chiếu thì phần chuyển khoản của ngày ít hơn con số hệ thống **đúng bằng** lần bấm ấy — và không lần bấm nào trông khác lần bấm nào | **Máy không ngăn được, và bảng bảo vệ đã nói thẳng như thế:** ô `I-015` là **tầng 4** ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1 · §1.1) vì mã VietQR của quán là mã **tĩnh**, không có đường nào báo tiền về ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2 `PT-3` + khung dưới bảng §3 · [`architecture.md`](architecture.md) §7). Cái máy **có** giữ, cả ba đều đã viết ra: từng phần thu ghi riêng theo **phương thức** (`I-015` tầng 1) · **vết đủ bốn câu** (`I-012` tầng 1) · đối soát **chia theo phương thức**, phần chuyển khoản so với **tin nhắn báo có**, ngưỡng **0đ** ([`architecture.md`](architecture.md) §6.4 · `PT-4` ở §2 · §3) | **Người đứng quầy** bấm (`architecture.md` §7); **chủ quán** đối chiếu buổi tối (`shop-facts.md` §6.10) | Phần chuyển khoản của một ngày **không khớp** tin nhắn báo có — bất kỳ ngày nào, vì ngưỡng là 0đ. Dấu hiệu thứ hai, đắt hơn: chỗ lệch ấy **lặp lại**, và các vết của nó mang **cùng một cái tên** |
| **RR-2** | Một lần **trả nợ** bị ghi thành một khoản **bán mới**, hoặc bảng đối soát thiếu một trong hai dòng nợ | Cùng một bữa ăn được tính doanh thu **hai lần**, và cái sai nằm ở phía **đẹp hơn sự thật** nên không ai đi tìm. Ở chiều kia: tối nào có người nợ, két thiếu mà không dòng nào giải thích; tối nào có người trả nợ, két thừa | **Tầng 1** — hai trạng thái phải **không tồn tại được**: *phiên đã đóng, thu thiếu, mà không khoản nợ nào đứng tên đúng phần thiếu*, và *một khoản nợ nằm trong tập tiền đã thu của một ngày* (ô `I-005`, [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1). Cộng **công thức đối soát bốn dòng**, trong đó **hai dòng nợ ngược chiều nhau**, và luật 1 *"nợ cũ thu được hôm nay không bao giờ cộng vào doanh thu hôm nay"* ([`architecture.md`](architecture.md) §6.4); mốc tính tiền của khoản bán là **ngày ghi nợ** ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2) | **POS** ghi nợ và ghi lần trả (`shop-facts.md` §6.14); **chủ quán** đối soát | Một ngày có *nợ cũ thu được hôm nay* khác 0 mà doanh thu ngày ấy **cũng** tăng đúng bằng con số đó; hoặc bảng đối soát của một ngày có nợ mà **thiếu** một trong hai dòng nợ |
| **RR-3** | Một lần **hoàn tiền** đi ra khỏi két mà thiếu vết, hoặc bị trừ vào **ngày bán gốc** thay vì **ngày hoàn** | Hoàn tiền **không có luật cứng** — quầy quyết từng ca (`shop-facts.md` §6.4) — nên cái vết là thứ **duy nhất** phân biệt một lần hoàn với một lần tiền tự đi khỏi két. Trừ nhầm ngày thì **doanh thu của một ngày đã đối soát xong đổi về sau**, đúng thứ lời chốt 2026-09-01 sinh ra để chặn | **Tầng 1** cho hình dạng vết: một thao tác chạm tiền thiếu một trong bốn câu — *cái gì đổi · bao nhiêu · ai bấm · lúc mấy giờ* — phải **không tồn tại được** (ô `I-012`, [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1; yêu cầu gửi pha 2 ở [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §3). Mốc tính tiền là **ngày hoàn**, và **mốc đã ghi thì không dời** ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 · §2.2); dòng *hoàn tiền trong ngày* đứng sẵn trong công thức đối soát ([`architecture.md`](architecture.md) §6.4). ⚠️ **Một vế chưa có luật — `U-044`**, xem §1.3 | **Người đứng quầy** — cùng một người vừa quyết vừa ghi (`shop-facts.md` §6.4) | Một khoản hoàn không đọc ra được **lý do** và **người bấm**; hoặc tiền mặt trong két hụt so với phép trừ của `I-021` **đúng bằng** một khoản vừa hoàn (đó là `U-044` đang hiện ra) |
| **RR-4** | Doanh thu một ngày **cộng thiếu một nguồn** — hoặc phiên bàn, hoặc đơn mang đi | Con số nhỏ hơn sự thật, **không thao tác nào sai**, và nó thiếu **im lặng**: không ai nhìn thấy, kể cả người vừa bán | **Máy không ngăn được** — ô `I-014` vế *cộng đủ hai nguồn* là **tầng 5**: không ràng buộc nào biết một phép cộng đã bỏ sót cái gì ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1). Cái máy **có** giữ: mỗi khoản đúng **một** nguồn (`I-014` tầng 1) và đúng **một** mốc tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 · §2.1 · §2.2) ⇒ con số **dựng lại được** từ từng khoản; hai chỗ dễ đếm sai đã có tên sẵn — suất *đem về* của khách ngồi bàn thuộc nguồn **phiên bàn**, và **một khoản nợ không phải tiền đã thu** ([`architecture.md`](architecture.md) §6.3) | **Chủ quán** — người đọc báo cáo (`architecture.md` §6) | Báo cáo doanh thu của một ngày **nhỏ hơn** con số dựng lại từ chính bốn dòng bảng đối soát của ngày ấy. Hai đường cộng ra hai con số ⇒ một đường đã bỏ sót một nguồn |
| **RR-5** | **Ngưỡng lệch 0đ bị bào mòn**: bảng báo đỏ vì một lý do ai cũng biết trước, và người ta học cách nhìn cái đỏ ấy rồi bỏ qua | Từ hôm ấy, một ngày mất tiền **thật** đi qua **đúng cái đỏ đó** mà không ai nhìn. Đây là rủi ro **của chính cổng chất lượng mạnh nhất dự án** (`shop-facts.md` §6.10) ⇒ nó hỏng thì bốn dòng trên **mất người bắt**, dù mọi ô của chúng vẫn xanh | Một **câu điều kiện** đã viết ra: *ngày còn một khoản chưa có mốc, hoặc còn lượt bán trên giấy chưa nhập, thì phép đối chiếu **không kết luận** — ngày ấy đọc là **chưa đối soát xong**, không đọc là **lệch*** ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1.2), và **cùng câu ấy** cho ngày thiếu con số **tiền đầu két** (§1.5 · ô `I-021`). Cộng: dòng *"còn N lượt bán trên giấy chưa nhập"* phải đọc được trên bảng cuối ngày (`PT-6` ở [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §3 · `RB-4` ở [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §2) · **không có nút *"đóng ca dù lệch"*** ([`architecture.md`](architecture.md) §6.4 luật 3) | **Chủ quán** | Một tối bảng đọc là **lệch** trong khi dòng *còn N lượt chưa nhập* khác 0, hoặc ngày ấy thiếu con số tiền đầu két — hai ca **phải** đọc là *chưa đối soát xong*. Và: hai tối liên tiếp đóng sổ với một ô lệch mang **cùng một lý do đã biết trước** |
| **RR-6** | Vết của một thao tác chạm tiền mang tên một **chỗ đứng**, không phải một **người** | Tối đối soát lệch thì truy về được *"quầy"* chứ không về ai. Ba việc quầy quyết từng ca — **hoàn tiền · ghi nợ · huỷ đơn** — mất đúng cái tên khiến chúng được phép tồn tại mà không cần một luật cứng | **Máy không ngăn được** vế *cái tên trong vết là người thật đã bấm*: ô `I-012` **tầng 4**, vì quyền gắn **chỗ đứng**, không gắn chức vụ ([`architecture.md`](architecture.md) §4) — hai người dùng chung một chỗ đứng là chuyện máy không phân biệt ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1). Cái máy **có** giữ: vết đủ **bốn câu** (`I-012` tầng 1) · mọi thao tác chạm tiền qua **một cửa có tên**, kể cả **hai** ngoại lệ đã chốt — người đi giao và chủ quán (§1.1) · mỗi lần cập nhật giữ đủ bốn thứ (`I-018`, §3) · yêu cầu *ai đang trực trạm nào* đã gửi pha 2 ([`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §4) | **Chủ quán** — người quyết ai được đứng chỗ nào (`architecture.md` §4) | Một buổi bán có **hơn một** người đứng quầy mà **mọi** vết chạm tiền của buổi ấy mang **cùng một** cái tên |
| **RR-7** | Một mẻ **chia sai phần theo khoá gom** ⇒ bàn này thừa, bàn kia thiếu, và số *đã phục vụ* sai theo | Bàn 7 ngồi chờ đúng thứ bếp **đã làm xong**; người tráng bánh nhìn màn trống và đọc ra *"chưa có việc"*. Khách chờ món không bao giờ tới, và không ai biết vì sao | **Tầng 1** — tổng nhu cầu luôn bằng tổng các phần chia, **cả hai chiều**, và ranh giới phép cộng là **khoá gom** (thành phần + loại nhân + lượng nhân), không phải tên món (ô `I-019`, [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §4 · §4.2). **Tầng 1 + tầng 2** cho ô `I-020`: trần trên kể cả **trạng thái giữa**, và một mẻ phủ **nhiều bàn trong cùng một giao dịch**, đường lùi là giao dịch nghịch đảo (§4). Cộng: **con số thứ tư** của bảng quầy — *đã làm xong, còn ở bếp* ([`architecture.md`](architecture.md) §3.4) · luật *màn rỗng phải nói được vì sao nó rỗng* ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1.3) | **Người đứng quầy** — mẻ là đơn vị **bấm**, và ba trạm bếp không bấm gì (`architecture.md` §3.4 · §5) | Con số *đã làm xong, còn ở bếp* khác 0 và **không giảm** trong khi vẫn có bàn đang chờ đúng thành phần ấy |
| **RR-8** | Quán **mất điện hoặc mất mạng** giữa buổi — quán mù trong khi **hệ thống vẫn sống** | Khách web vẫn đặt được mà không ai ở quán nhìn thấy; doanh thu buổi ấy chỉ tồn tại **trên giấy** cho tới lúc nhập bù, nên ngày ấy **chưa đối soát xong** | **Đường suy giảm đủ ba vế** — *quán làm gì · ai bù · bù lúc nào* — cho `PT-1` · `PT-2` · `PT-6` ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §3). Cộng: **web ngừng nhận đơn, khách gọi hotline** — điều kiện thứ ba của `I-008`, chủ quán chốt 2026-09-04 — và **bốn câu luật** về phía nào phán quyết ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §3) · **đường kéo dự phòng tự chạy** (§1.2) · doanh thu lượt nhập bù rơi vào **ngày quán bán** ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2) | **POS hoặc chủ quán** — người giữ sổ cũng là người nhập lại (`shop-facts.md` §6.11) | `RB-4`: quán phải chuyển sang sổ giấy vì hệ thống chết **quá một buổi bán trong một tháng** ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §2). Và: mỗi tối đóng sổ còn dòng *còn N lượt bán trên giấy chưa nhập* khác 0 |
| **RR-9** | **Mất hẳn bản ghi đã ghi** — không phải mất kết nối, mà là dữ liệu của những ngày đã bán không còn | Không đối soát lại được ngày nào, không truy được vết nào, và **không có đường lùi**: sổ giấy chỉ có những ngày quán ghi tay, còn những ngày máy chạy bình thường thì không có bản thứ hai ở đâu cả | ⛔ **CHƯA CÓ CƠ CHẾ NÀO Ở PHA 1.** Không mục nào của `docs/` hay `quality/` sở hữu câu *bản ghi đã ghi có còn không*. Chỗ **duy nhất** trong repo nói tới nó — sao lưu, diễn tập phục hồi, không triển khai trong giờ bán — nằm ở `master_plan/prompt-fullstack.md` §5, đúng tài liệu mà **ADR-035** đã chốt là **không sở hữu thứ gì**. Đó là `work/findings.md` **F-034**, cùng hình dạng với **F-027**. **Đừng đọc dòng này như đã được chặn** | **Chưa có** — chọn nhà cho nó là quyết định của **chủ repo** (`F-034`), không phải của bước này | **Chưa đo được**: phép đo cũng chưa có nhà. Dấu hiệu rẻ nhất ngay khi nó có nhà — **bản sao lưu gần nhất chưa từng được phục hồi thử** |

### 1.1 Chín là phép đếm của lượt này, và năm dòng bản nháp đi đâu

**Chín là phép đếm ngày 2026-09-08, không phải một quyết định** (`work/findings.md` **F-003**).
Thấy cái thứ mười thì **thêm một dòng** đủ sáu ô, đừng ép nó vào một dòng đã có; và cũng đừng đi
tìm cho đủ một con số. Con số **năm** ở bản nháp là phép đếm của người viết ngày ấy, không phải một
ranh giới ai chốt.

**Bản nháp §6 giữ năm dòng `R1`–`R5`, và nó không sở hữu gì** (**ADR-014**) — đoạn dưới là **bản
ghi lịch sử** để người từng đọc bản nháp biết mỗi dòng đi đâu, **không** phải một pointer coi bảng
ấy là owner. Bảng ấy viết **trước** ba luật đường tiền đã chốt từ đó: **cho nợ**
(`master_plan/shop-facts.md` §6.14, 2026-08-31) · **hoàn tiền tính ngày hoàn** (§6.4, 2026-09-01) ·
**đối soát ba nguồn ngưỡng 0đ** (§6.10, 2026-09-01). Ba thứ ấy sinh ra `RR-2` · `RR-3` · `RR-5`,
tức **ba trong chín dòng của bảng trên không có mặt trong bản nháp**.

- *Tính sai giá* → nay là ô `I-013` **tầng 3**, và tầng 3 là **trần thật** của nó
  ([`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §3): một chỗ tính giá duy nhất, **cả năm**
  kênh đi qua nó, con số giá đến từ phía khách bị **bỏ**. Cơ chế phủ hết ⇒ nó ở lại bảng bảo vệ,
  không lên sổ này.
- *Hai phiên cùng một bàn* → ô `I-001` **tầng 1**, phủ cả trạng thái *chờ thanh toán* và ca **ghép
  bàn** (§2). Cùng lý do: có tầng giữ, không còn là một trong những chỗ mất tiền lớn nhất.
- *Đơn khách tự gửi xuống bếp khi chưa duyệt* → ô `I-004` vế một, **tầng 1** (§2), cộng `I-008`
  (§3).
- *Mất dữ liệu / lịch sử đơn* → hôm nay tách làm **hai** thứ khác hẳn nhau: **cái tên trong vết**
  → `RR-6`, và **bản ghi còn hay mất** → `RR-9`. Cách chặn mà bản nháp ghi — *backup + snapshot +
  verification* — **chưa bao giờ có nhà** trong `docs/` hay `quality/` (`work/findings.md`
  **F-034**).
- *Realtime hỏng* → `RR-8`, và nó **xuống cuối bảng có chủ ý**: xem §1.2 luật 3.

### 1.2 Bốn chỗ bảng trên dễ bị đọc sai

1. **Đừng đọc *"đã có cơ chế"* thành *"đã an toàn"*.** Bốn dòng — `RR-1` · `RR-3` (vế vết) ·
   `RR-4` · `RR-6` — có cơ chế cao nhất là **tầng 4 hoặc tầng 5**: máy **không ngăn**, nó chỉ
   **nhắc, để vết, và bắt sau**. Một dòng như thế được chặn bởi **người**; cái máy giữ là **đường
   truy**, không phải hàng rào. Đây đúng là rủi ro lớn nhất của cả pha 1 mà kế hoạch §10 gọi tên.
2. **`RR-5` không cùng hạng với bốn dòng trên nó — nó là điều kiện sống của chúng.** `RR-1`, `RR-2`,
   `RR-3`, `RR-4` đều được **bắt** ở cùng một chỗ: bảng đối soát cuối ngày. `RR-5` là rủi ro của
   **chính chỗ ấy** ⇒ nó hỏng thì bốn dòng kia mất người bắt, trong khi mọi ô của chúng vẫn xanh.
3. **Đừng xếp `RR-8` ngang `RR-1`.** Bản nháp xếp *realtime hỏng* cùng một bảng với *thu sai tiền*;
   hôm nay biết rõ hơn: mất kết nối có **đường kéo dự phòng tự chạy**
   ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §1.2) và **sổ giấy** (`PT-6`,
   [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §3) — quán **không dừng bán**. Thu sai
   tiền thì **không có đường lùi nào**: tiền đã ra khỏi quán.
4. **`RR-9` là một dòng ⛔, không phải một dòng yếu.** Đọc nó thành *"đã có sao lưu"* vì bản xuất
   khẩu có nhắc chữ ấy là lặp lại đúng ca `work/findings.md` **F-027** đã tốn một vòng rà: một cơ
   chế chỉ sống ở tài liệu **không sở hữu gì** là một cơ chế **không ai chịu trách nhiệm**.

### 1.3 Chỗ cố ý để trống — hai mã, không mã nào được đoán hộ

Kế hoạch §9: *một ô không tick được thì để trống kèm mã của chỗ đang chặn*. Sổ này có **hai** mã
như thế, và chúng khác loại nhau — một là câu của **chủ quán**, một là chỗ trống của **chủ repo**.

- **`U-044` — hoàn tiền cho một khoản khách đã CHUYỂN KHOẢN thì quán trả lại bằng gì.** Chạm
  `RR-3`. **Vì sao không được suy hộ:** nếu quán trả lại bằng **tiền mặt** thì đó là một đường
  **rút tiền khỏi két giữa buổi**, và điều kiện biên thứ hai của `I-021` — *không có khoản rút giữa
  buổi nào phải cộng lại* (`shop-facts.md` §8.5, chủ quán chốt 2026-09-04) — hết đúng. Chính
  `I-021` đã viết sẵn hậu quả: luật ấy đổi thì công thức **thiếu một hạng tử**, và mệnh đề phải
  **viết lại**, không phải viết thêm. Nguyên văn câu hỏi và cách hỏi ở
  [`../99-unknowns.md`](../99-unknowns.md).
- **`F-034` — `RR-9` chưa có mục nào ở pha 1 sở hữu cơ chế của nó.** Bước này **không** tự mở một
  mục mới cho nó và **không** thiết kế một cơ chế sao lưu nào: *cách chạy hệ thống* thuộc pha sau
  (**ADR-035**), và một tài liệu nghi lễ viết ra ở đây sẽ thành cái ai cũng tưởng là đã có
  (`CLAUDE.md` §3.8). Chọn nhà cho nó là quyết định của **chủ repo**.

---

## 2. Bước sau đọc gì ở đây

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-11** — diễn ba scenario, và cổng sang pha 2 | ô cổng thứ sáu của kế hoạch §9 đọc **bảng §1**: mỗi dòng phải trỏ được tới một mục pha 1, **hoặc** nói thẳng *chưa có cơ chế* kèm mã. **`RR-9` là dòng làm ô ấy không tick trơn được** — nó tick kèm lý do và mã, đúng luật *"không tick hộ, không xoá ô"* |
| **P1-12** — rà ranh giới pha | mục này không có tên bảng · cột · ràng buộc · endpoint · route · component; các câu *"phải không tồn tại được"* là câu **trích** từ [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md), tức câu về **tầng** |
| **Pha 2** | bốn dòng chỉ tới **tầng 4/5** (`RR-1` · `RR-3` vế vết · `RR-4` · `RR-6`) là **cái pha 2 không dựng nổi một ràng buộc nào chặn** — đừng đọc chúng thành yêu cầu. Yêu cầu gửi pha 2 nằm ở [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md) §1.4 và [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) |
| **Pha sau — chạy thật** | `RR-8` (đường suy giảm đã có đủ ba vế) và `RR-9` (chỗ trống chưa có nhà, `F-034`) |
| **Chủ quán** | `U-044` — một câu, hỏi về **cái quán**: hoàn tiền cho khách đã chuyển khoản thì trả lại thế nào |

[↑ đầu file](#top)
