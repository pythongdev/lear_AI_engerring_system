# Bảo vệ invariant — tầng nào giữ từng mệnh đề, và phép đối chiếu nào bắt nó khi hỏng

*Bước 4/14 · 5/14 · 6/14 · 13/14 · 14/14 của pha 1 — **một file, năm chủ**
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Mở đầu và **§1 — nhóm TIỀN** viết ở **P1-04**, 2026-09-06. **§2 — nhóm VÒNG ĐỜI** là của **P1-05**,
**§3 — nhóm MENU · GIÁ · VẾT** viết ở **P1-06**, 2026-09-07. **§4 — nhóm SẢN XUẤT THEO MẺ** là của
**P1-13**, 2026-09-07 — bước thứ mười ba, mở ra
sau khi `I-019`/`I-020` sinh **sau** kế hoạch chia ba nhóm ban đầu (`work/findings.md` **F-026**,
`docs/decisions.md` **ADR-042**). **Hàng `I-021` của §1 và mục §1.5** là của **P1-14**, 2026-09-07 —
mệnh đề mồ côi thứ ba, sinh ở T-056 sau khi kế hoạch ấy đã chia nhóm, và nó đứng giữa nhóm TIỀN
chứ không mở một nhóm mới (`docs/decisions.md` **ADR-044**). Không sửa mục của người khác
(`work/findings.md` **F-010** · **F-014**).*

> **Mục này sở hữu đúng hai thứ cho mỗi mệnh đề bất biến:** **tầng bảo vệ** đang giữ nó, và **phép
> đối chiếu** bắt được nó khi nó đã hỏng (`CLAUDE.md` §2, hàng *Tầng bảo vệ của từng invariant* —
> **ADR-035**).
>
> **Nó không sở hữu lời của một mệnh đề nào.** `I-0xx` có nhà ở `quality/invariants.md`; cột thứ
> nhất dưới đây **trỏ** về đó và cố ý **không chép** câu mệnh đề — bản thứ hai luôn trôi
> (`work/findings.md` **F-001**).
>
> **Nó không sở hữu dữ kiện quán.** Giá, giờ bán, hai phương thức thu tiền, ngưỡng lệch 0đ đều
> thuộc `master_plan/shop-facts.md` (**ADR-001**).
>
> **Nó không thiết kế một cơ chế nào.** Cột giữa nói *cái gì ngăn trạng thái sai xảy ra*, cột phải
> nói *cái gì bắt được nó khi đã xảy ra* — không cái nào nói **khoá bằng gì**. Không nút *"khoá sổ
> một ngày"*, không đường báo tiền về của ngân hàng, không lịch chạy đối soát: đó là pha 2, pha 3
> và **P1-08** (kế hoạch §6).
>
> **Ở đây không có tên bảng, tên cột, tên ràng buộc, endpoint hay route** (**ADR-035**). Một câu
> *"phải do cơ sở dữ liệu giữ"* là một câu về **tầng**; hình dạng của nó do **pha 2** chọn.

---

## 0. Cách đọc ba cột — và năm tầng

| Cột | Trả lời câu gì |
|---|---|
| **Mệnh đề** | mã `I-0xx`, trỏ về `quality/invariants.md`; đọc lời của nó ở đó |
| **Bảo vệ bằng** | **cái gì ngăn trạng thái sai xảy ra**, viết bằng đúng từ vựng năm tầng |
| **Phép đối chiếu** | **cái gì bắt được nó sau khi đã xảy ra**, viết dạng *"tập này phải rỗng"* |

**Từ vựng năm tầng — ở đây chỉ nhắc TÊN; nghĩa đầy đủ và cột *đúng cả khi…* ở kế hoạch pha 1 §7**,
đọc ở đó, đây cố ý không có bản chép (**F-001**):
**tầng 1** cơ sở dữ liệu giữ · **tầng 2** một giao dịch giữ · **tầng 3** miền nghiệp vụ giữ ·
**tầng 4** người + thủ tục giữ · **tầng 5** phép đối chiếu bắt sau khi hỏng.

Bốn luật đọc, ba luật đầu là của kế hoạch §7, luật thứ tư là của chính pha này:

1. **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở.** Đây là rủi ro lớn
   nhất của cả pha 1 (kế hoạch §10): một bảng ba cột trông đã đủ, trong khi cột giữa của mấy mệnh
   đề chạm tiền chỉ là tầng 4 mà không ai nói ra.
2. **Mỗi mệnh đề vẫn có một phép đối chiếu, kể cả khi cột giữa đã là tầng 1.** Ràng buộc cũng bị
   người ta gỡ; phép đối chiếu là thứ phát hiện ra điều đó.
3. **Ô nào chỉ tới được tầng 4 hoặc tầng 5 phải nói thẳng *"máy không ngăn được"***, và nói kèm
   **cái máy CÓ giữ thay vào**.
4. **Mọi câu *"tầng 1"* ở đây là YÊU CẦU gửi pha 2, không phải một ràng buộc đã có.** Hôm nay chưa
   có lược đồ nào: `docs/product/2-db/` chưa mở (**ADR-035**), nên không dòng nào của bảng này
   được đọc thành *"đã có ràng buộc"*. Chỗ duy nhất trong repo hôm nay **trông** như đã có —
   ba câu *"để database giữ, không để mã ứng dụng giữ"* ở [`architecture.md`](architecture.md)
   §12.3 — **tự khai là đề xuất gửi sang pha 2**, và mục này đọc nó đúng như thế.

---

## 1. Nhóm TIỀN — tám mệnh đề (P1-04, 2026-09-06 · hàng `I-021` thêm ở P1-14, 2026-09-07)

Nhóm này đi trước hai nhóm kia vì nó là nhóm **mất tiền**, và vì nó là chỗ rủi ro lớn nhất của cả
pha đang nằm (kế hoạch §10).

**Cột *Mệnh đề* trỏ về `quality/invariants.md`** — nhãn sau mỗi mã chỉ để nhận ra hàng, **không**
phải câu mệnh đề; lời của từng mệnh đề đọc ở nhà của nó (**F-001**).

| Mệnh đề | Bảo vệ bằng | Phép đối chiếu — *tập này phải rỗng* |
|---|---|---|
| **`I-002`** — tính tiền theo phiên bàn | **Tầng 1** cho vế *một phiên sinh đúng một hoá đơn*: trạng thái *một phiên bàn có hai hoá đơn* **phải không tồn tại được** ở tầng cơ sở dữ liệu. · **Tầng 3** cho vế *tổng hoá đơn = tổng mọi lượt gọi của phiên*: chỉ **một cửa ghi** quyết định một lượt gọi thuộc đơn vị tính tiền nào ([`architecture.md`](architecture.md) §1.1), và hoá đơn **cộng lại** từ các lượt gọi chứ không mang một con số tự đứng — nên lượt gọi thêm lúc phiên đã ở *chờ thanh toán*, và lượt gọi từ bàn khác trong nhóm ghép, không có đường nào rơi ra ngoài. Giới hạn đã biết của tầng 3: nó không đúng khi có người sửa dữ liệu bằng tay. | Mọi phiên bàn đã đóng mà số hoá đơn của nó khác **một**. · Mọi phiên bàn đã đóng mà tổng hoá đơn khác tổng mọi lượt gọi thuộc phiên ấy — tính cả lượt gọi sau khi quầy đã bắt đầu thu, và cả lượt gọi từ mọi bàn trong nhóm ghép. · Mọi lượt gọi tại một bàn đang mở phiên mà không thuộc phiên nào. **Mọi tập kể trên phải rỗng.** |
| **`I-005`** — nợ khi đóng phiên thiếu tiền | **Tầng 1, và là *phải do* chứ không phải *đã do*.** Hai trạng thái **phải không tồn tại được** ở tầng cơ sở dữ liệu: *phiên đã đóng, tổng đã thu nhỏ hơn số phải trả, mà không có khoản nợ nào đứng tên với đúng phần thiếu*; và *một khoản nợ nằm trong tập tiền đã thu của một ngày*. Vì là một câu về **trạng thái cuối**, nó đứng cả khi việc ghi bị đứt giữa chừng. ⚠️ [`architecture.md`](architecture.md) §12.3 đã đề nghị đúng ba ràng buộc như thế và **tự khai là đề xuất gửi sang pha 2**, không phải ràng buộc đã có — hàng này **yêu cầu**, không **ghi nhận**. | Mọi phiên đã đóng mà *tổng các phần đã thu + phần đã ghi nợ* khác số phải trả. · Mọi khoản nợ không truy được về đúng một phiên **và** đúng một người. · Mọi ngày mà chênh lệch giữa doanh thu và tiền thực nhận không giải thích được bằng đúng danh sách *nợ ghi trong ngày* + *nợ cũ thu được hôm nay* + *hoàn tiền trong ngày* ([`architecture.md`](architecture.md) §6.4). **Mọi tập kể trên phải rỗng.** |
| **`I-007`** — đơn mang đi là đơn vị thanh toán độc lập | **Tầng 1** cho vế *không thuộc phiên bàn nào, tại mọi thời điểm*: trạng thái *một đơn của ba kênh không gắn bàn đang thuộc một phiên bàn* **phải không tồn tại được**. · **Tầng 3** cho vế *không gộp*: không có thao tác nào nối một đơn mang đi vào một phiên bàn, và đường duy nhất khi khách đổi ý là **huỷ rồi gọi lại** — lời chốt của chủ quán, `master_plan/shop-facts.md` §2. **Đây là một nửa của một ranh giới; nửa kia là `I-006`, thuộc nhóm VÒNG ĐỜI (P1-05)** — hàng này chỉ trỏ sang, không viết hộ và không mô tả lại. | Mọi đơn của ba kênh không gắn bàn đang gắn với một phiên bàn, ở bất kỳ trạng thái nào của vòng đời. · Mọi lần thu gộp hai đơn lẻ làm một. · Mọi đơn lẻ mà số lần thu của nó khác **một** khi đơn đã đóng. **Mọi tập kể trên phải rỗng.** |
| **`I-012`** — vết của mọi thao tác chạm tiền | **Tầng 1** cho *hình dạng của vết*: trạng thái *một thao tác chạm tiền đã ghi mà thiếu một trong bốn câu — cái gì đổi, bao nhiêu, ai bấm, lúc mấy giờ* **phải không tồn tại được**. · **Tầng 3** cho *đúng một cửa*: mọi thao tác trong danh sách đi qua cửa ghi duy nhất ([`architecture.md`](architecture.md) §1.1), **trừ hai ca đã chốt tên người khác** — người đi giao bấm *đã giao + đã thu tiền* tại chỗ khách (`shop-facts.md` §6.7) và **chủ quán** đổi giá hoặc đổi thành phần suất trên mặt quản trị (§6.17). Hai ca ấy **không phải lỗ thủng**: chúng có tên, và chúng cũng để lại vết. · **Tầng 4** cho vế *cái tên trong vết là người thật đã bấm*: quyền gắn **chỗ đứng**, không gắn chức vụ ([`architecture.md`](architecture.md) §4), nên **máy không ngăn được** hai người dùng chung một chỗ đứng. Cái máy **có** giữ thay vào: mọi thao tác chạm tiền đều mang **một chỗ đứng và một mốc**, đủ để đối soát cuối ngày chỉ đúng **một** hàng khi lệch — mà đó đúng là giá trị duy nhất của tầng này. Vế *đọc được sau nhiều ngày* là **yêu cầu hình dạng dữ liệu** ⇒ **P1-07**; hàng này không thiết kế chỗ cất vết. | Mọi thao tác chạm tiền của một ngày mà thiếu một trong bốn câu. · Mọi chỗ lệch trong bảng đối soát cuối ngày không chỉ ra được **đúng một** thao tác có tên (`shop-facts.md` §6.10, ngưỡng 0đ). · Mọi đường làm đổi số tiền của quán mà không đi qua ba chỗ bấm đã kể tên ở cột giữa. · Mọi lần hoàn tiền không đọc ra đủ *bao nhiêu · đơn nào · ai bấm · lý do gì*. **Mọi tập kể trên phải rỗng.** |
| **`I-013`** — giá do hệ thống tính lại | **Tầng 3, và tầng 3 là trần thật của hàng này.** Chỉ **một chỗ** trong hệ thống được tính giá của một dòng đơn, và **mọi** đường đặt món của **cả năm** kênh (`shop-facts.md` §2) đi qua chỗ ấy; con số giá đến từ phía khách bị **bỏ**, không bao giờ được dùng, kể cả khi nó bằng đúng giá đúng. Cơ sở dữ liệu **không** giữ được vế này: nó không đọc được một con số **đến từ đâu**. Và **bước quầy duyệt không phải cơ chế giữ nó** — bước ấy chặn đơn ảo, không ai đứng đó cộng lại tiền từng dòng (`shop-facts.md` §6.2 · `I-013` mục *Why*). Giới hạn đã biết của tầng 3: nó không đúng khi có người sửa dữ liệu bằng tay. | Mọi dòng đơn mà số tiền của nó khác **tổng giá các thành phần** của suất ấy (`shop-facts.md` §4.2 · §4.6 quy tắc 1) theo mức giá **đang có hiệu lực tại mốc tạo lượt gọi** — mốc: [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2; một hoá đơn mang hai mức giá vì chủ quán đổi giá giữa buổi là **đúng**, không phải lệch (`shop-facts.md` §6.17). · Mọi dòng đơn có giá **0đ** cho một suất mà suất ấy không có giá 0đ. · Mọi kênh trong năm kênh không có ít nhất một lượt kiểm ra đúng giá kỳ vọng của `shop-facts.md` §4.8. **Mọi tập kể trên phải rỗng.** |
| **`I-014`** — doanh thu một ngày cộng từ đủ hai nguồn | **Hai vế, hai tầng khác nhau — đừng gộp.** · **Vế *không khoản nào đứng ở cả hai nguồn*: tầng 1.** Trạng thái *một khoản tiền gắn với hơn một đơn vị tính tiền* **phải không tồn tại được** (`shop-facts.md` §6.9). · **Vế *cộng đủ hai nguồn*: tầng 5.** Ở đây **máy không ngăn được** một báo cáo cộng thiếu một nguồn: không ràng buộc nào biết một phép cộng đã bỏ sót cái gì, và nó thiếu một cách im lặng — không thao tác nào sai, chỉ có một con số nhỏ hơn sự thật. Cái máy **có** giữ thay vào: mỗi khoản tiền có **đúng một** nguồn (tầng 1 ở trên) và **đúng một** mốc tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §1 · §2), nên con số của một ngày **dựng lại được từ đầu** và đem so được với ba nguồn ngoài của `shop-facts.md` §6.10. **Hai mã từng mở ở chính ô này, cả hai đã đóng 2026-09-06** (`CLAUDE.md` §3.5): ~~`U-036`~~ (khoản trả trước nhận ngày này cho đơn giao ngày khác — nay **có** mốc tính tiền: ngày giao/lấy hàng, **ADR-040**) và ~~`U-037`~~ (nhập bù xong thì **ai** chấm lại ngày ấy, **lúc nào** — POS hoặc chủ quán, cuối buổi bán hàng). **Phương án hẹp nhất đã chọn khi cả hai còn mở nay là mệnh đề chính thức** — nó là một câu về *phép đối chiếu*, không phải một luật mới: ngày nào còn một khoản chưa có mốc, hoặc còn lượt bán trên giấy chưa nhập, thì phép đối chiếu **không kết luận** — ngày ấy đọc là **chưa đối soát xong**, không đọc là **lệch** (**ADR-037**). Chi tiết ở §1.2. | Mọi khoản tiền của một ngày xuất hiện ở **hơn một** nguồn. · Mọi khoản tiền của ngày ấy không xuất hiện ở **nguồn nào**. · Mọi ngày mà tổng báo cáo khác *tổng nguồn phiên bàn + tổng nguồn đơn lẻ*, trong đó cả ba kênh mang đi cùng rơi vào nguồn thứ hai. · Mọi lần trả nợ được đếm như một khoản bán mới. · Mọi ngày **đã đối soát xong** mà vẫn còn lượt bán trên giấy chưa nhập, hoặc còn một khoản chạm tiền không có mốc tính tiền. · Mọi ngày đã qua mà con số dựng lại hôm nay khác con số đã đối soát hôm ấy, **trừ** đúng ca nhập bù từ sổ giấy (**ADR-037**). **Mọi tập kể trên phải rỗng.** |
| **`I-015`** — một lần thu chia nhiều phương thức | **Ba vế, ba tầng.** · **Tầng 1** cho *tổng khớp* và *ghi riêng từng phần*: trạng thái *tổng các phần đã thu vượt số phải trả* và trạng thái *một phần đã thu không mang đúng một phương thức trong hai phương thức của `shop-facts.md` §1* đều **phải không tồn tại được**; thu thiếu thì phần thiếu **phải** thành một khoản nợ theo **`I-005`**. · **Tầng 2** cho *các phần của một lần thu cùng sống hoặc cùng chết*: đứt giữa hai phần ghi thì tổng hết khớp và phần đã ghi trông y hệt một lần thu thiếu — mà một lần thu thiếu thì `I-005` đòi một khoản nợ có tên, nên chỗ hỏng này đẻ ra một khoản nợ không có thật. Mọi phần cũng dùng chung **một** mốc tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2.1). · **Vế *tiền đã thật sự vào tài khoản*: tầng 4 — và đây là ô nói thẳng nhất của cả bảng.** VietQR ở quán là mã **TĨNH**, không có đường nào báo tiền về ([`architecture.md`](architecture.md) §7 · `shop-facts.md` §1): hệ thống **không tự biết** tiền đã vào tài khoản, nên **máy không ngăn được** một lần bấm *đã nhận tiền* khi tiền chưa về. Câu ấy do **người đứng quầy** nhìn tin nhắn báo có rồi nói, và hệ thống chỉ **ghi lại lời ấy**. Cái máy **có** giữ thay vào là ba thứ khác: *tổng các phần = số phải trả*, *từng phần ghi riêng theo phương thức*, và *lần bấm ấy để lại vết có tên* (**`I-012`**) — đủ để cuối ngày so **phần chuyển khoản** với **tin nhắn báo có** và chỉ ra đúng một người khi lệch. **Đừng thiết kế một cơ chế để nâng vế này lên**: mã tĩnh là dữ kiện quán, đổi nó là câu của chủ quán, không phải của pha 1. | Mọi lần thu mà tổng các phần khác số phải trả và phần thiếu **không** có một khoản nợ đúng bằng nó. · Mọi lần thu có một phần không mang phương thức nào, hoặc ghi gộp thành một con số tổng. · Mọi lần thu có các phần rơi vào **hai** ngày bán khác nhau. · Mọi ngày mà **tổng phần chuyển khoản** khác tổng tin nhắn báo có của ngày ấy — tính riêng, **không** cộng gộp với phần tiền mặt (`shop-facts.md` §6.10). · Mọi ngày mà **tổng phần tiền mặt** không khớp két theo phép trừ tiền đầu két — mệnh đề ấy là **`I-021`** — **hàng cuối của chính bảng này** từ 2026-09-07 (P1-14, §1.3); lúc ô này được viết nó còn đứng ngoài mọi nhóm. **Mọi tập kể trên phải rỗng.** |
| **`I-021`** — két cuối ngày trừ tiền đầu két bằng doanh thu tiền mặt | **Ba vế, ba tầng — và vế đắt nhất chỉ tới tầng 4.** · **Vế *mỗi ngày bán có đúng MỘT con số tiền đầu két, và con số ấy KHÔNG phải doanh thu*: tầng 1.** Hai trạng thái **phải không tồn tại được** ở tầng cơ sở dữ liệu: *một ngày bán mang hơn một con số tiền đầu két*, và *tiền đầu két nằm trong tập tiền đã thu của một ngày*. Vế thứ hai cùng hình dạng với vế *một khoản nợ nằm trong tập tiền đã thu* của **`I-005`**, và cùng lý do: một con số đứng nhầm tập thì mọi phép cộng phía sau sai trong khi **không thao tác nào sai**. · **Vế *không đường nào làm giảm tiền trong két giữa buổi*: tầng 3.** Quán **không có** nghiệp vụ nộp bớt tiền giữa buổi (chủ quán chốt 2026-09-04, `A4` ⇒ `shop-facts.md` §8.5), nên miền nghiệp vụ không có thao tác nào rút tiền khỏi két trong buổi — đó là thứ làm phép trừ **hai hạng tử** ở cột phải đủ. Nếu lời chủ quán ấy đổi thì công thức **thiếu một hạng tử**, và mệnh đề phải **viết lại**, không phải viết thêm (`quality/invariants.md` **`I-021`**, điều kiện biên thứ hai). · **Vế *con số két cuối ngày là số ĐẾM ĐƯỢC thật*: tầng 4 — máy không ngăn được.** Không có đường nào cho hệ thống biết trong két thật đang có bao nhiêu tiền: con số ấy do **người đếm rồi nhập**. Một lần đếm nhầm, hoặc một lần nhập lại đúng con số hệ thống đang chờ thay vì con số vừa đếm, cho phép trừ ra **0đ** trông y hệt một ngày khớp thật. Cái máy **có** giữ thay vào là ba thứ: doanh thu tiền mặt của vế phải **dựng lại được từ từng phần thu mang phương thức** (**`I-015`** tầng 1), mỗi lần bấm chạm tiền để lại **vết có tên** (**`I-012`**) nên khi hai vế lệch thì chỉ ra được đúng một hàng, và lần **sửa** con số tiền đầu két mặc định của một ngày cũng là một thao tác chạm tiền, mang vết như thế. **Đừng thiết kế một cơ chế để nâng vế này lên**: đếm két là việc của người và của thủ tục: rủi ro ấy có tên ở **P1-10**, không có ở đây. | Mọi **ngày bán** mà *(tiền mặt đếm trong két cuối ngày) − (tiền đầu két của ngày ấy)* khác **doanh thu tiền mặt** của ngày ấy — ngưỡng **0đ**, không dung sai (`shop-facts.md` §6.10). · Mọi ngày bán mang số lượng con số tiền đầu két khác **một**. · Mọi ngày **chưa** có con số tiền đầu két mà bị đọc là **lệch** thay vì **chưa đối soát xong** — cùng hình dạng với ngày còn lượt bán trên giấy chưa nhập (**ADR-037**, ô **`I-014`**). · Mọi lần phép trừ trên chạy trên một tổng **gộp** cả phần chuyển khoản thay vì chỉ phần tiền mặt (**`I-014`** · `shop-facts.md` §6.10). · Mọi con số doanh thu — kể cả con số **dự tính** ở mục tổng quan của chủ quán (`shop-facts.md` §8.6) — có cộng tiền đầu két vào. · Mọi lần sửa con số tiền đầu két của một ngày mà không đọc ra được *ai bấm · lúc mấy giờ · từ bao nhiêu sang bao nhiêu* (**`I-012`**). **Mọi tập kể trên phải rỗng.** |

### 1.1 Ba chỗ hàng trên dễ bị đọc rộng ra

- **`I-012` — "đúng một cửa" có HAI ngoại lệ đã chốt, và chúng phải nằm trong câu.** Một hàng viết
  *"mọi thao tác chạm tiền đi qua máy POS ở quầy"* rồi dừng là mô tả một hệ thống không tồn tại:
  người đi giao bấm tại chỗ khách (`shop-facts.md` §6.7) và chủ quán bấm trên mặt quản trị (§6.17)
  đều là lời chốt của chủ quán. Ngoại lệ **đã chốt** không phải lỗ thủng — nó là một cửa **có tên**,
  và pha 2 phải biết có ba chỗ bấm chứ không phải một.
- **`I-013` — bước quầy duyệt KHÔNG phải cơ chế giữ nó.** Đây là chỗ dễ ghi tầng cao hơn sự thật:
  bước duyệt có thật, nó đứng ngay trên đường đơn đi, nên rất dễ bị mượn làm hàng rào cho một câu
  nó không đỡ. Nó chặn **đơn ảo**; không ai đứng ở đó cộng lại tiền từng dòng.
- **`I-015` — không chỗ nào trong bảng được nói như thể hệ thống tự biết tiền đã về.** Vế *đã nhận
  tiền* của phần chuyển khoản là một **lời của người**, và bảng này ghi nó là tầng 4 đúng như thế.
  Vế máy giữ được là vế khác: *tổng các phần = số phải trả* và *từng phần ghi riêng theo phương
  thức*.

### 1.2 Chỗ cố ý để trống — lịch sử hai mã, cả hai nay đã đóng (2026-09-06)

Kế hoạch §9: *một ô không tick được thì để trống kèm mã của chỗ đang chặn*. Nhóm này có **một** ô
như thế, và nó mang **hai** mã — cả hai là **câu của chủ quán** (`CLAUDE.md` §3.5), và cả hai nay
đều có lời. Đọc nguyên văn ở [`docs/product/99-unknowns.md`](../99-unknowns.md), đừng đọc bản tóm
này thay cho nó.

- ~~**`U-036`**~~ — **ĐÃ ĐÓNG.** Khoản trả trước nhận hôm nay cho đơn giao hôm khác tính doanh thu
  vào **ngày giao/lấy hàng**, không phải ngày nhận tiền (`docs/decisions.md` **ADR-040**). Hàng
  cuối bảng §2 của [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) **hết trống**: khoản này
  nay **có** mốc tính tiền, như mọi khoản khác.
- ~~**`U-037`**~~ — **ĐÃ ĐÓNG.** Sau khi nhập bù xong, **POS hoặc chủ quán** chấm lại con số của
  ngày ấy, vào **cuối buổi bán hàng** — cùng người, cùng nhịp đã làm việc đối soát hằng ngày
  (`shop-facts.md` §6.10, §6.27).

**Phương án hẹp nhất chọn trước khi hai mã trên có lời vẫn đứng, nay là mệnh đề chính thức, không
phải tạm thời:** ô `I-014` viết đúng một câu điều kiện: *ngày nào còn một khoản chưa có mốc, hoặc
còn lượt bán trên giấy chưa nhập (**ADR-037**), thì phép đối chiếu **không kết luận**, và ngày ấy
đọc là **chưa đối soát xong**, không đọc là **lệch***. Việc đóng hai mã trên không đổi câu điều
kiện này — nó chỉ làm cho vế *"chưa có mốc"* không còn ca nào rơi vào nữa, vì mọi khoản chạm tiền
nay đều có đúng một mốc (`02-thoi-gian-ngay-ban.md` §2).

**Việc còn lại, và nó không phải của bước này:** công thức đối soát
[`architecture.md`](architecture.md) §6.4 cần thêm một dòng cho khoản tiền đã vào két mà chưa vào
doanh thu (đối xứng với dòng *nợ ghi trong ngày* nhưng ngược chiều) — **ADR-040** đã chốt là cần,
nhưng câu chữ và cơ chế của dòng ấy là việc của bước đọc mục này tiếp theo, không phải của bảng
này.

### 1.3 Ba mệnh đề từng đứng ngoài mọi nhóm — nay cả ba đã có nhà (đóng 2026-09-07)

**Lịch sử, giữ lại vì nó là bài học chứ không phải trạng thái đang chạy** (`work/findings.md`
**F-026**, `docs/decisions.md` **ADR-042** · **ADR-044**). Kế hoạch §6 chia **mười tám** mệnh đề
thành ba nhóm vào 2026-09-03; ba mệnh đề sinh **sau** ngày ấy nên không nhóm nào nhận chúng, trong
khi cổng chất lượng §9 vẫn đếm *"mười tám"* và vì thế **tick xanh được** trong lúc ba mệnh đề chưa
có tầng giữ nào. Đo lại 2026-09-06 (lượt viết §1 này): `quality/invariants.md` đã giữ **hai mươi
mốt** mệnh đề.

Chủ repo chốt chỗ đứng của cả ba, mỗi lần một quyết định riêng vì hai ca không giống nhau:

- **`I-019` · `I-020`** (sinh ở **BA-12**, 2026-09-03) — trục **sản xuất theo mẻ**, xa cả ba nhóm
  ban đầu ⇒ **nhóm thứ tư của riêng chúng**, **§4** của chính file này
  (bước **P1-13**, **ADR-042**, 2026-09-07).
- **`I-021`** (sinh ở **T-056**, 2026-09-04) — **không** mở nhóm mới: nó là phép trừ *két cuối ngày
  − tiền đầu két = doanh thu tiền mặt*, đứng cùng chỗ với `I-014` và `I-015`, và ô `I-015` của bảng
  trên đã **trỏ vào nó** từ lúc bảng được viết ⇒ nó vào **chính bảng này**, hàng cuối §1, viết ở
  bước **P1-14** (**ADR-044**, 2026-09-07). Ba chỗ hàng ấy dễ đọc sai ở **§1.5**.

**Cái đáng giữ không phải ba cái tên, mà là cơ chế đã giấu chúng:** một cổng đếm *"mười tám"* đọc
xanh trong khi tập nó đếm đã đổi. Cổng §9 nay đối chiếu **danh sách mã** giữa `quality/invariants.md`
và bảng này, không đếm số lượng — mệnh đề thứ hai mươi hai sinh ra ngày mai sẽ tự bị bắt là *vắng
mặt*, không cần ai nhớ cập nhật một con số (`work/findings.md` **F-018** · **F-026**).

### 1.4 Bước sau đọc gì ở §1

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-07** — yêu cầu hình dạng dữ liệu | mọi câu *"trạng thái này phải không tồn tại được"* ở cột giữa là một **yêu cầu** gửi pha 2; vế *vết đọc được sau nhiều ngày* của `I-012` là của P1-07, §1 cố ý không thiết kế chỗ cất vết; và `I-021` thêm hai yêu cầu nữa — **một ngày bán mang đúng một con số tiền đầu két**, và **tiền đầu két không nằm trong tập tiền đã thu** |
| **P1-10** — sổ rủi ro | các chỗ **máy không ngăn được** của nhóm tiền, gọi tên chứ không đếm (**F-018**): `I-012` chỗ đứng dùng chung · `I-015` VietQR tĩnh · `I-021` con số két cuối ngày do người đếm rồi nhập — ba ô **tầng 4**; cộng vế **tầng 5** của `I-014` (cộng thiếu một nguồn, thiếu một cách im lặng). Rủi ro có tên sẵn, không phải *"cẩn thận hơn"* |
| **P1-11** — diễn ba scenario | mỗi bước chạm tiền trỏ được vào một ô cột giữa ở đây; `U-036` và `U-037` đã đóng 2026-09-06 nên không còn chỗ nào phải dừng ở ô `I-014` |
| **P1-12** — rà ranh giới pha | §1 không có tên bảng · cột · ràng buộc · endpoint · route · component; câu *"phải do cơ sở dữ liệu giữ"* là câu về tầng |
| **Pha 2** | **cái gì bắt buộc do cơ sở dữ liệu giữ**: `I-002` (một phiên một hoá đơn) · `I-005` (nợ có chủ, nợ không phải tiền đã thu) · `I-007` (đơn mang đi không dính phiên bàn) · `I-012` (vết đủ bốn câu) · `I-014` (một khoản một nguồn) · `I-015` (tổng khớp, từng phần có phương thức) · `I-021` (một ngày bán một con số tiền đầu két; tiền đầu két không phải tiền đã thu). Và **cái gì không cơ chế nào giữ được**: các chỗ ở hàng P1-10 trên |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch §5). Đo lại 2026-09-06: §1.1, §3.3, §4, §6.3, §6.4, §7, §12.2 và §12.3 không
chỗ nào nói ngược bảng trên — §12.3 nói **hình dạng** của phần nợ và tự khai là đề xuất pha 2, còn
bảng trên nói **tầng**, hai câu khác nhau về cùng một mệnh đề.

### 1.5 Ba chỗ hàng `I-021` dễ bị đọc sai (P1-14)

- **Phép trừ này chỉ nói về TIỀN MẶT.** Phần chuyển khoản đối chiếu với **tin nhắn báo có** và
  **không** được cộng gộp vào (`shop-facts.md` §6.10 · ô `I-014`). Gộp hai phương thức rồi so một
  con số tổng là làm hỏng cả hai phép đối chiếu cùng lúc: lệch ở phương thức nào cũng không đọc ra
  được nữa.
- **Tiền đầu két KHÔNG BAO GIỜ là doanh thu**, kể cả trong con số *dự tính* ở mục tổng quan của chủ
  quán (`shop-facts.md` §8.6). Đây là chỗ dễ hỏng nhất vì nó hỏng **im lặng**: cộng nhầm nó vào thì
  mọi con số vẫn có, chỉ lớn hơn sự thật đúng bằng một hằng số quen mắt.
- **Một ngày thiếu con số tiền đầu két là *chưa đối soát xong*, không phải *lệch*.** Đọc nó thành
  lệch là dạy đúng cái mà mệnh đề này sinh ra để chặn: một ngưỡng 0đ báo đỏ vì một lý do đã biết
  trước sẽ được người dùng học cách bỏ qua, và từ hôm ấy một chỗ mất tiền **thật** cũng đi qua cùng
  cái đỏ ấy mà không ai nhìn (`quality/invariants.md` `I-021` mục *Why*; cùng hình dạng với ngày còn
  lượt bán trên giấy chưa nhập, **ADR-037**).

---

## 2. Nhóm VÒNG ĐỜI — sáu mệnh đề (P1-05, 2026-09-06)

Nhóm này là chỗ **bàn kẹt** và **đơn kẹt**: một cơ chế viết ẩu ở đây không làm mất tiền ngay lập
tức như nhóm TIỀN, nhưng nó khoá một cái bàn hoặc một đơn cả buổi, và đó là chỗ khách nhìn thấy
đầu tiên.

**Cột *Mệnh đề* trỏ về `quality/invariants.md`** — nhãn sau mỗi mã chỉ để nhận ra hàng, **không**
phải câu mệnh đề; lời của từng mệnh đề đọc ở nhà của nó (**F-001**).

| Mệnh đề | Bảo vệ bằng | Phép đối chiếu — *tập này phải rỗng* |
|---|---|---|
| **`I-001`** — một bàn ≤ một phiên chưa thanh toán, ghép bàn thì một phiên nhiều bàn | **Tầng 1, và ràng buộc phải phủ cả trạng thái *chờ thanh toán***, không chỉ trạng thái đang mở: trạng thái *một bàn cùng lúc gắn với hai phiên đều chưa thanh toán (Mở · Đang phục vụ · Chờ thanh toán)* **phải không tồn tại được** ở tầng cơ sở dữ liệu ([`architecture.md`](architecture.md) §3.1 — nếu ràng buộc chỉ tính trạng thái đang mở, lúc quầy bấm thu tiền ràng buộc nhả ra và lượt gọi thêm rơi vào hoá đơn thứ hai). Ràng buộc buộc theo **từng bàn**, không theo từng phiên — nên nó tự nhiên cho phép chiều ngược: **một phiên gắn nhiều bàn** khi ghép (`docs/decisions.md` **ADR-027**) không vi phạm gì, vì ràng buộc không giới hạn số bàn của một phiên, chỉ giới hạn số phiên chưa thanh toán của một bàn. Ghép một bàn đang có phiên mở vào một phiên khác bị đúng ràng buộc này chặn — không cần một cơ chế riêng cho ghép bàn. | Mọi bàn xuất hiện trong **hơn một** phiên đang ở Mở, Đang phục vụ hoặc Chờ thanh toán tại cùng một thời điểm. · Mọi nhóm ghép bàn mà một bàn thành viên đồng thời còn gắn một phiên khác ngoài phiên của nhóm. **Mọi tập kể trên phải rỗng.** |
| **`I-003`** — bàn trống ⟺ phiên đã đóng VÀ bàn đã dọn | **Tầng 3.** Bảng chuyển trạng thái đã chốt ([`05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5.3) chỉ có **một** cửa dẫn tới mỗi nửa của điều kiện: bàn chuyển sang *Cần dọn* do **hệ thống** kích tự động, đúng lúc và chỉ lúc phiên của nó chuyển sang *Đã đóng* — không cửa nào khác đẩy bàn vào *Cần dọn*; và bàn chỉ rời *Cần dọn* sang *Trống* khi **người canh & dọn** xác nhận đã dọn xong ở đúng bàn ấy. `I-016` khoá mọi cửa khác cho cả hai chuyển tiếp này, nên bàn không có đường tắt nào tới *Trống* mà bỏ qua một trong hai điều kiện. Với nhóm ghép bàn: điều kiện *phiên đã đóng* dùng chung cho cả nhóm, điều kiện *đã dọn* tính riêng từng bàn. Giới hạn đã biết của tầng 3: cơ chế này giữ đúng **trạng thái ghi nhận trong hệ thống**, không giữ được sự thật là bàn có **thực sự sạch** hay không — đó là một khoảng cách khác, không phải khoảng cách invariant này đóng. | Mọi bàn đang ở Trống mà phiên gần nhất từng gắn với nó chưa ở Đã đóng. · Mọi bàn đang ở Trống mà không có một sự kiện *đã dọn* nào được ghi sau lần đóng phiên gần nhất của nó. **Mọi tập kể trên phải rỗng.** |
| **`I-004`** — đơn duyệt sinh đủ việc cho mọi trạm; đơn chưa duyệt không việc nào; hai trục gặp nhau đúng một chỗ, kể cả khi đơn huỷ SAU KHI việc đã làm xong | **Bốn vế, ba tầng — đừng gộp.** · **Vế *đơn chưa duyệt sinh không việc nào*: tầng 1.** Trạng thái *tồn tại một việc trạm gắn với một đơn đang ở Mới hoặc Chờ xác nhận* **phải không tồn tại được** ở tầng cơ sở dữ liệu — việc trạm chỉ được sinh ra bởi đúng một sự kiện, đơn chuyển Đã xác nhận → Đang thực hiện ([`05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5.2). · **Vế *đơn đã duyệt sinh ĐỦ việc, đúng số lượng, cho mọi trạm liên quan*: tầng 2.** Việc nổ đơn thành các dòng việc — số lượng = số suất × số thành phần (`master_plan/shop-facts.md` §4.5) — phải xảy ra trong **cùng một giao dịch** với việc ghi đơn sang Đang thực hiện: nếu giao dịch đứt giữa chừng, đơn đứng ở Đang thực hiện mà thiếu việc là chính xác cái mệnh đề này chống. · **Vế *đơn huỷ rút nhu cầu, việc CHƯA XONG*: tầng 3.** Đơn sang Huỷ thì **mọi việc trạm chưa xong** của đơn ấy rời bảng bếp cùng lúc, không có ai đứng ở trạm huỷ riêng một việc ([`05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5.4 cuối mục) — đây là **đúng một cửa** nơi trục sản xuất và trục đơn gặp nhau ở chiều rút ra ([`architecture.md`](architecture.md) §2). · **Vế *đơn huỷ SAU KHI việc đã ở *Đã làm xong, còn ở bếp* hoặc *Đã ra bàn*: tầng 4.** Chỗ đã làm xong đó **không bỏ đi** — nó **chuyển sang một bàn khác đang chờ đúng thứ ấy** (cùng thành phần, cùng lượng nhân, `shop-facts.md` §4.5), và **người đứng quầy trên POS chọn bàn nhận rồi cập nhật** (chủ quán chốt 2026-09-06, trả lời `U-033`, `shop-facts.md` §5.4). Tầng 4 vì **chọn bàn nào nhận là quyết định của người**, không phải luật máy tự gán — máy chỉ **bày ra** ai đang chờ đúng thứ đã làm; **máy không ngăn được** một lần quầy chọn nhầm bàn (bàn được chọn hoá ra không thực sự đang chờ đúng thứ ấy). Cái máy **có** giữ thay vào: một khi người đã chọn, việc **chuyển nhu cầu** — giảm đúng phần ở bàn nhận, bỏ đúng phần ấy khỏi bàn cũ — xảy ra trong **cùng một giao dịch** (tầng 2), nên hai con số không bao giờ lệch nhau ở giữa chừng. **Giới hạn đã biết, chủ quán chưa nói tới:** ca **không có bàn nào đang chờ đúng thứ đã làm** — chưa có luật, chưa hỏi (`shop-facts.md` §5.4). | Mọi việc trạm tồn tại mà đơn của nó đang ở Mới hoặc Chờ xác nhận. · Mọi đơn đã Đang thực hiện mà thiếu một việc cho một trạm mà thành phần suất của nó chạm tới, hoặc số lượng việc khác đúng suất × thành phần (`shop-facts.md` §4.5). · Mọi việc trạm còn ở Chưa làm mà đơn của nó đã Huỷ. · Mọi việc trạm đã ở *Đã làm xong, còn ở bếp* hoặc *Đã ra bàn* mà đơn của nó đã Huỷ và **không** có một lần cập nhật nào chuyển nó sang một bàn khác. · Mọi lần chuyển như vậy mà nhu cầu của bàn nhận và bàn cũ không cộng khớp (phần chuyển đi phải bằng đúng phần nhận được). **Mọi tập kể trên phải rỗng** — trừ ca chưa có luật (không bàn nào đang chờ đúng thứ đã làm), ca ấy chưa có tập đối chiếu vì chưa có luật để đối chiếu. |
| **`I-006`** — suất "đem về" của khách ngồi bàn thuộc phiên bàn, mang note, không sinh đơn lẻ | **Hai vế.** · **Vế *chiều ngược không tồn tại*: tầng 1, cùng ràng buộc với `I-007`** (nhóm TIỀN, §1) — hai invariant là hai nửa của **cùng một ranh giới** (`quality/invariants.md`, mục *Why* của cả hai mệnh đề) nên dùng chung một cơ chế: trạng thái *một đơn của ba kênh không gắn bàn đang thuộc một phiên bàn* **phải không tồn tại được**. Hàng này **trỏ** sang cơ chế đã viết ở `I-007` (§1), không mô tả lại (**F-001**). · **Vế *suất đem về đi đúng vào phiên bàn, mang note, tính đúng nguồn*: tầng 3.** Kênh **QR tại bàn** và **Staff POS đặt hộ tại bàn** là hai cửa duy nhất tạo lượt gọi cho một suất của khách ngồi bàn, và cả hai luôn gắn lượt gọi ấy vào **phiên đang mở của bàn đó** — kể cả khi suất mang note *"đem về"* — vì không có kênh nào trong hai kênh ấy có đường tạo đơn lẻ độc lập cho một bàn đang có phiên. Nguồn báo cáo doanh thu đọc theo **đơn vị tính tiền của lượt gọi** (phiên bàn), không đọc theo note; note chỉ là nhãn cho bảng bếp (`shop-facts.md` §6.15) và không tự đổi nguồn tiền. Giới hạn: **máy không tự biết** khách có thật sự yêu cầu mang về hay không — quầy phải **bấm đúng note** tại thời điểm ghi lượt gọi; bấm sai note là lỗi hiển thị cho bếp, không phải lỗi tiền, vì tiền vẫn đi đúng nguồn phiên bàn bất kể note đúng hay sai. | Mọi đơn của ba kênh không gắn bàn đang nối với một phiên bàn, ở bất kỳ trạng thái nào — **cùng một tập** với `I-007` (§1), không đối chiếu hai lần cho cùng một ranh giới. · Mọi suất mang note *"đem về"* xuất hiện ở nguồn đơn lẻ thay vì nguồn phiên bàn của báo cáo doanh thu (`shop-facts.md` §6.9). **Mọi tập kể trên phải rỗng.** |
| **`I-016`** — chuyển trạng thái ngoài ba bảng §5 bị TỪ CHỐI, không bao giờ làm ngầm | **Tầng 3.** Mỗi vòng đời trong ba vòng đời của [`05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5 — đơn (§5.2), phiên bàn và cái bàn của nó (§5.3), việc trạm (§5.4) — có **đúng một** hàm xác thực chuyển trạng thái, tra đúng bảng của vòng đời ấy trước khi ghi; một cặp (trạng thái nguồn, trạng thái đích) không có dòng trong bảng bị **từ chối** ngay tại đó, không được tự sửa cho hợp lệ và không có đường tắt bỏ qua một trạng thái ở giữa. Đây là kiểu *"đúng một cửa"* giống cơ chế của `I-002` và `I-013` (§1) — không phải một ràng buộc cấu trúc tĩnh, vì **danh sách hợp lệ đổi theo thời gian** (bảng §5 đã đổi ba lần trong hai tuần) nên một ràng buộc cứng theo từng cặp sẽ phải sửa lại mỗi lần bảng đổi — rủi ro ngược đúng điều mệnh đề này chống. Giới hạn đã biết của tầng 3: nó không đúng khi có người sửa dữ liệu bằng tay, bỏ qua hàm xác thực. | Dựng lại lịch sử chuyển trạng thái của mỗi đơn, mỗi phiên bàn/bàn và mỗi việc trạm từ vết cập nhật (`I-018` buộc giữ), rồi liệt kê mọi cặp (nguồn, đích) không có dòng trong bảng của đúng vòng đời ấy **tại đúng thời điểm nó xảy ra** — danh sách so sánh phải đổi theo mỗi lần §5 thêm hoặc bớt một dòng, nếu không phép đối chiếu và sản phẩm đã rời nhau (kịch bản phủ của chính `I-016`, `quality/invariants.md`). **Tập kết quả phải rỗng.** |
| **`I-017`** — phiên bàn không Đã đóng khi còn đơn chưa Hoàn thành/Huỷ; tiền chưa thu không chặn đóng | **Tầng 2.** Thao tác đóng phiên đọc trạng thái của **mọi** đơn thuộc phiên — kể cả đơn của **mọi bàn khác trong cùng nhóm ghép** (`master_plan/shop-facts.md` §6.16, `I-002`) — và ghi *Đã đóng* trong **cùng một giao dịch**: nếu đọc và ghi tách rời, một đơn có thể chuyển sang Đang thực hiện đúng lúc giữa hai bước và điều kiện đọc được không còn đúng lúc ghi. Đóng phiên **không** bị chặn bởi tiền chưa thu (`I-005`) — hai luật ngược chiều, cùng nằm trong một thao tác nhưng đọc hai cột dữ liệu khác nhau (đơn vs. tiền), và không được gộp thành một câu. ⚠️ **Điểm kiểm là một MỐC, không phải một trạng thái bất biến sau đó**: đơn đã Hoàn thành **vẫn huỷ được** sau khi phiên đã đóng (`docs/decisions.md` **ADR-017**, `shop-facts.md` §6.19) — lần huỷ ấy đi qua `I-016`, kéo theo **hoàn tiền** rơi vào ngày hoàn (`architecture.md` §6.4), và **không** mở lại phiên hay đổi lại điều kiện đã kiểm lúc đóng; đọc mệnh đề này thành *"trạng thái cuối bất biến"* là đọc sai. ⚠️ **Phần liên quan đơn giao tận nơi:** người đứng quầy bấm mốc *"đã ra bàn"* của từng việc trạm kể cả với đơn giao, không có ngoại lệ (`U-031`, chủ quán chốt 2026-09-04 — đọc `docs/product/99-unknowns.md` mục *Đã có lời giải*); vế **lúc nào** quầy bấm mốc ấy chưa có lời — **đang chờ `S-6`** (`master_plan/shop-facts.md` §7.2). | Mọi phiên đang Đã đóng mà có ít nhất một đơn thuộc phiên đó — kể cả đơn của bàn khác trong cùng nhóm ghép — không ở Hoàn thành hoặc Huỷ, **tính tại đúng thời điểm đóng**. · Mọi phiên Chờ thanh toán nhận thêm một lượt gọi mà vẫn đóng được trước khi lượt gọi ấy tới Hoàn thành/Huỷ (`shop-facts.md` §6.1, `I-001`). **Mọi tập kể trên phải rỗng.** |

### 2.1 Năm chỗ hàng trên dễ bị đọc rộng ra hoặc đọc hẹp lại

- **`I-001` không đối xứng — đừng viết ràng buộc theo chiều phiên → bàn.** Ràng buộc thật đi theo
  chiều **bàn → phiên** (một bàn tối đa một phiên chưa thanh toán); đọc ngược nó thành *"một phiên
  tối đa một bàn"* là chặn nhầm đúng ca ghép bàn mà chủ quán đã chốt cho phép.
- **`I-003` không phải một cơ chế đã có.** Chưa có lược đồ nào (`docs/product/2-db/` chưa mở), nên
  câu *"chỉ một cửa dẫn tới mỗi nửa điều kiện"* là một **yêu cầu** gửi pha 2 dựa trên hành vi đã
  chốt ở `05-vong-doi.md` §5.3, không phải một ràng buộc đang chạy.
- **`I-004` vế thứ tư — đừng đọc tầng 4 thành "chưa có luật".** Khác với lúc prompt của bước này
  được viết (`U-033` khi đó còn mở), chủ quán đã trả lời **2026-09-06**: chỗ đã làm xong chuyển
  sang bàn khác, POS chọn. Tầng 4 ở đây không phải *"chưa ai quyết"* — luật đã có — mà là *"luật đã
  có nhưng chỗ giữ nó là một quyết định của người, máy không tự gán"*, đúng nghĩa gốc của tầng 4.
  Đọc nhầm thành "chưa có luật" là dùng lại khung của một bản nháp đã cũ hơn sự thật một bước.
- **`I-016` khoá một LUẬT, không khoá một danh sách case cố định.** Danh sách case bị từ chối đã
  ngắn đi hai dòng trong hai ngày (`quality/invariants.md` mục *Why*) mà mệnh đề không phải sửa một
  chữ — đó là bằng chứng cơ chế đúng phải tra **bảng**, không được mã hoá cứng từng cặp đã biết.
- **`I-017` — đừng lẫn "đóng phiên bị chặn bởi MÓN" với "đóng phiên bị chặn bởi TIỀN".** Hai luật
  ngược chiều nhau trong cùng một thao tác: món chưa xong thì chặn, tiền chưa thu thì không — gộp
  thành một câu là mất chính cái luật *"quán cho nợ"* mà chủ quán chốt để tránh khoá bàn cả buổi.

### 2.2 Một chỗ cố ý để trống — một mã còn treo, một mã vừa đóng ngay trong lượt này

Kế hoạch §9: *một ô không tick được thì để trống kèm mã của chỗ đang chặn*. Lúc prompt của bước
này được viết (2026-09-04), nhóm này có hai chỗ như vậy — `U-033` (`I-004`) và `S-6` (`I-017`).
**Chủ quán đã đóng `U-033` ngày 2026-09-06** (cùng ngày viết mục này, cùng một lượt trả lời bảy câu
khác của `docs/product/99-unknowns.md`, chuyển hết xuống mục *Đã có lời giải*), nên bảng ở §2 phía
trên đã ghi **thẳng** cơ chế thật của `I-004`, không còn ô nào để trống cho nó. Đọc nguyên văn ở
[`docs/product/99-unknowns.md`](../99-unknowns.md), đừng đọc bản tóm này thay cho nó.

- **`U-033` — ĐÃ ĐÓNG 2026-09-06, chạm `I-004`.** Đơn bị huỷ sau khi bếp đã làm xong phần của nó:
  chỗ đã làm xong chuyển sang một bàn khác đang chờ đúng thứ ấy, POS chọn bàn nhận và cập nhật
  (nguyên văn *"tính vào bàn khác, pos sẽ cập nhật bánh này đem ra cho bàn nào"*). Cơ chế đã viết
  thẳng vào hàng `I-004` ở trên (tầng 4); không còn là chỗ treo.
- **`S-6` — VẪN TREO, chạm `I-017`.** Với một đơn giao tận nơi, quầy bấm mốc *"đã ra bàn"* **lúc
  nào** — chỗ **suy ra**, không phải câu hỏi đang mở, ở `master_plan/shop-facts.md` §7.2, và tính
  tới 2026-09-06 vẫn *"chưa hỏi"* (`shop-facts.md` §7.2 bảng S-5/S-6/S-7). Vế **ai bấm** đã chốt
  2026-09-04 (`U-031`, *"pos"*), nên hai đường ra xấu cũ (đơn giao không bao giờ Hoàn thành được /
  quầy bấm khống một mốc) đã đóng; chỉ còn câu **lúc nào**, và nó vẫn chạm mốc `I-017` dùng để kiểm
  đơn đã tới tay khách chưa.

**Vì sao `S-6` không đẩy tầng nào của bảng trên xuống 4 hoặc 5:** nó là chỗ luật nghiệp vụ còn thiếu
một vế (chưa ai hỏi vế *lúc nào*), không phải chỗ máy bất lực trước một luật đã đủ. Tầng 4/5 nói
*"luật đã đủ, máy không giữ nổi"* — đúng hình dạng mà hàng `I-004` mang bây giờ — còn ở đây luật
chưa đủ, nên câu đúng vẫn là *"đang treo"*, không phải một tầng.

### 2.3 Bước sau đọc gì ở §2

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-07** — yêu cầu hình dạng dữ liệu | mọi câu *"trạng thái này phải không tồn tại được"* ở cột giữa (`I-001` · `I-004` vế 1 · `I-006`) là một **yêu cầu** gửi pha 2; vế `I-004` tầng 4 cần một chỗ hiển thị *"ai đang chờ đúng thứ đã làm"* để quầy chọn — đó là yêu cầu hình dạng dữ liệu, không phải một ràng buộc; vế `I-017` còn treo (`S-6`) chưa sinh yêu cầu nào |
| **P1-10** — sổ rủi ro | `I-004` vế huỷ-sau-khi-làm-xong là **tầng 4** của nhóm này — chọn nhầm bàn nhận là **máy không ngăn được**, cùng loại rủi ro với `I-012`/`I-015` ở nhóm TIỀN; `S-6` (`I-017`) vẫn là rủi ro **vận hành chưa có luật**, một loại khác |
| **P1-11** — diễn ba scenario | mỗi bước chạm vòng đời trỏ được vào một ô cột giữa ở đây; chỗ phải dừng là `I-004` vế tầng 4 (POS chọn bàn nhận) và `I-017` với `S-6` |
| **P1-12** — rà ranh giới pha | §2 không có tên bảng · cột · ràng buộc · endpoint · route · component; câu *"phải không tồn tại được ở tầng cơ sở dữ liệu"* là câu về tầng |
| **Pha 2** | **cái gì bắt buộc do cơ sở dữ liệu giữ**: `I-001` (một bàn một phiên chưa thanh toán, phủ cả chờ thanh toán) · `I-004` vế chưa duyệt (không việc trạm nào cho đơn Mới/Chờ xác nhận) · `I-006`/`I-007` (ranh giới phiên bàn ↔ ba kênh không gắn bàn, một cơ chế cho cả hai). Và **cái gì cần một giao dịch, không chỉ một ràng buộc**: `I-004` vế đủ việc (nổ đơn) và vế chuyển nhu cầu sau khi POS chọn bàn nhận · `I-017` (đọc rồi ghi trong cùng một giao dịch) |

---

## 3. Nhóm MENU · GIÁ · VẾT — năm mệnh đề (P1-06, 2026-09-07)

Nhóm này chứa **ca dạy được nhiều nhất của cả pha**: `I-011` từng được viết là *"thành phần suất
không đổi trong giờ bán"*, và câu đó **sai** kể từ khi chủ quán trả lời `U-018` (2026-09-01) — máy
**chỉ nhắc một câu rồi vẫn cho lưu**, vì luật *"chờ hết buổi"* là luật cho **người**, không phải
hàng rào của máy. Một invariant hệ thống không giữ nổi thì không phải invariant; thứ sản phẩm giữ
được là chuyện đó không xảy ra **âm thầm** (`docs/product/99-unknowns.md` mục *Đã có lời giải*,
`U-018`). Bốn mệnh đề còn lại mỗi cái một chỗ dễ sai riêng, ghi ở §3.1.

**Cột *Mệnh đề* trỏ về `quality/invariants.md`** — nhãn sau mỗi mã chỉ để nhận ra hàng, **không**
phải câu mệnh đề; lời của từng mệnh đề đọc ở nhà của nó (**F-001**).

| Mệnh đề | Bảo vệ bằng | Phép đối chiếu — *tập này phải rỗng* |
|---|---|---|
| **`I-008`** — ngoài giờ bán, đang tạm dừng, hoặc quán mất kết nối thì không đơn nào được tạo | **Tầng 3, đúng một cửa tạo lượt gọi** ([`architecture.md`](architecture.md) §6.2, cùng kiểu cửa ghi duy nhất với `I-013`), cửa ấy xét đủ ba điều kiện **theo đúng thứ tự**, không gộp thành một điều kiện: **(1)** đang bật *tạm dừng nhận đơn* ⇒ **chặn ngay, không xét tiếp** — nút này thắng giờ mở cửa (`shop-facts.md` §6.8); **(2)** không tạm dừng ⇒ mới xét **thời điểm tạo có nằm trong giờ bán** (06:00–11:00, `Asia/Ho_Chi_Minh`) hay không; **(3)** quán có đang **nhìn thấy được đơn mới** hay không — điều kiện này khác hai cái trên ở chỗ **không ai bấm được nó**: nó tắt đúng lúc không ai ở quán bấm được gì. **Cách máy biết quán đang mất kết nối là một cơ chế của P1-08/pha 3, chưa thiết kế ở bước này** — mệnh đề chỉ yêu cầu: một khi hệ thống đã xác định quán đang mù, cửa tạo lượt gọi phải chặn đúng **ba** kênh khách tự bấm (`delivery`, `pickup`, `qr_table`) và **không** chặn `staff_pos`/`phone_preorder` (hai kênh ấy vẫn nhận đơn qua hotline, ghi giấy). Đơn đã tạo **trước** một trong ba điều kiện đóng lại không bị chạm tới. | Mọi đơn có thời điểm tạo nằm ngoài 06:00–11:00. · Mọi đơn có thời điểm tạo rơi vào một khoảng *tạm dừng nhận đơn* đang bật. · Mọi đơn của ba kênh khách tự bấm (`delivery`, `pickup`, `qr_table`) có thời điểm tạo rơi vào một khoảng quán đã được xác nhận là mất kết nối. · Mọi đơn của `staff_pos`/`phone_preorder` bị chặn nhầm trong đúng khoảng mất kết nối ấy — chặn nhầm hai kênh này cũng là một chỗ hỏng, không riêng gì lọt đơn qua ba kênh kia. **Mọi tập kể trên phải rỗng.** |
| **`I-009`** — đơn đã tạo không đổi giá, tên món và thành phần khi chủ quán sửa menu | **Tầng 1 cho vế lưu bản sao**: một dòng đơn thiếu giá, tên món hoặc thành phần **đã chụp tại thời điểm tạo** — tức đọc theo bảng giá/menu **hiện hành** thay vì theo bản đã khoá — **phải không tồn tại được** ở tầng cơ sở dữ liệu; đây là **yêu cầu** gửi pha 2 (mục 0 luật 4), pha 2 chưa mở. **Tầng 3 cho vế mốc khoá**: chỉ **một cửa tạo lượt gọi** (cùng cửa `I-013`) đọc giá tại đúng mốc rồi khoá vào dòng đơn, và mốc ấy là **từng lượt gọi** (`docs/decisions.md` **ADR-023**) — **không phải** lúc mở hay đóng phiên bàn. Vì mốc là lượt gọi, một phiên bàn vắt qua một lần chủ quán đổi giá giữa buổi cho ra **đúng hai mức giá trên cùng một hoá đơn**, và đó là **kết quả đúng**, không phải một chỗ hỏng cần chặn (`shop-facts.md` §6.17). **Một ngoại lệ đã chốt, tầng 4**: khi người đứng quầy chủ động **sửa** một dòng, dòng ấy lấy giá **đang hiệu lực lúc sửa** — mốc khoá của riêng dòng đó được **đặt lại** (trả lời `U-026`, 2026-09-02); máy không tự làm điều này, nó chỉ xảy ra khi có một thao tác sửa của người. Đi kèm bắt buộc, **tầng 2**: vết của lần sửa ấy ghi **cả giá cũ lẫn giá mới** trong **cùng một giao dịch** với chính lần sửa (`I-012`, `I-018`) — thiếu vết ấy thì không ai phân biệt được "đổi giá menu không đụng đơn" với "sửa tay một dòng". | Mọi dòng đơn có giá, tên món hoặc thành phần đọc ra **khác** với giá trị đã khoá tại mốc tạo lượt gọi của chính nó, **trừ** đúng dòng vừa có một lần **sửa** còn để lại vết giá cũ/giá mới (`I-012`/`I-018`). · Mọi phiên bàn vắt qua một lần đổi giá giữa buổi mà **chỉ** mang một mức giá cho món đã đổi — đây **mới** là điều kiện lệch; **hai mức giá trên một hoá đơn không phải điều kiện lệch**. · Mọi lần sửa một dòng không để lại vết giá cũ/giá mới. **Mọi tập kể trên phải rỗng.** |
| **`I-010`** — tổ hợp món/tuỳ chọn không hợp lệ bị TỪ CHỐI, không bao giờ được sửa hộ | **Tầng 3, đúng một cửa** (cùng cửa `I-013`/`I-009` tính giá và khoá menu) kiểm tổ hợp tuỳ chọn **trước khi** tạo dòng đơn: hợp lệ ⇒ tạo; **không hợp lệ ⇒ từ chối toàn bộ**, không có đường nào tự bỏ bớt, đổi hay thêm tuỳ chọn rồi cho đơn đi tiếp. Danh sách tổ hợp không hợp lệ tra theo **luật**, không theo một danh sách case mã cứng — cùng lý do `I-016` (§2) chọn tầng 3 thay vì một ràng buộc cứng từng cặp: tổ hợp *Chay + Nhiều nhân* không hợp lệ **hôm nay** (`shop-facts.md` §4.4, §4.6 quy tắc 3), chủ quán sửa menu có thể đổi danh sách này mà mệnh đề không cần sửa một chữ. Cửa này áp cho **mọi** kênh trong năm kênh như nhau — đơn khách tự bấm và đơn nhân viên nhập hộ không có đường nào khác để bỏ qua bước kiểm. | Mọi dòng đơn tồn tại mang một tổ hợp không hợp lệ theo danh sách đang hiệu lực **tại đúng mốc tạo lượt gọi** của nó. · Mọi dòng đơn mang một tổ hợp **khác** với tổ hợp khách đã gửi ban đầu mà không phải do người sửa tay có vết (`I-018`) — dấu hiệu của một lần "sửa hộ" cho hợp lệ. · Mọi yêu cầu tạo đơn bị từ chối vì tổ hợp không hợp lệ mà vẫn có một dòng đơn được tạo ra ngay sau đó cho cùng yêu cầu ấy. **Mọi tập kể trên phải rỗng.** |
| **`I-011`** — đổi thành phần suất trong giờ bán không bao giờ xảy ra ÂM THẦM | **Tầng 4 — máy không ngăn được, và đây là ca mẫu của cả nhóm.** Chủ quán chốt ngược với bản đầu của mệnh đề này (`U-016` rồi `U-018`, cả hai 2026-09-01): đổi thành phần suất **phải** chờ hết buổi, nhưng máy **chỉ nhắc một câu** trước khi lưu rồi **vẫn cho lưu** nếu người bấm tiếp tục — **không có đường nào ngăn được việc lưu**, và tự dựng một đường ngăn là tự đặt luật nghiệp vụ
(`CLAUDE.md` §3.5). Cái máy **có** giữ thay vào, hai thứ: **lời nhắc** — tầng 3, một cửa sửa thành phần suất luôn hỏi trước khi ghi bất kỳ thay đổi nào rơi vào giờ bán (06:00–11:00); và **cái vết** — tầng 1 + tầng 2, mọi lần lưu (kể cả sau khi người bấm bỏ qua lời nhắc) ghi lại **đổi cái gì, lúc mấy giờ, ai bấm** trong cùng giao dịch với chính lần cập nhật (`I-018`). Ba chiều đổi giá khác — giá thành phần, phụ thu nhân, phụ thu lượng nhân — **không** chịu ràng buộc lời nhắc này, đổi được bất kỳ lúc nào, không nhắc gì cả; đừng bắt nhầm luật này sang ba chiều tiền. | Mọi lần đổi thành phần của một suất bán xảy ra trong giờ bán mà **không** có một vết ghi lại đổi cái gì/lúc mấy giờ/ai bấm (`I-018`). · Mọi lần đổi thành phần trong giờ bán mà không có bằng chứng lời nhắc đã hiện trước khi lưu (lời nhắc là điều kiện bắt buộc **hiện ra**, không phải điều kiện **được tuân theo** — người vẫn được bấm bỏ qua). · Mọi lần đổi **giá** (không phải thành phần) bị hệ thống nhắc nhầm như một lần đổi thành phần. **Mọi tập kể trên phải rỗng** — và tập đầu tiên có phần tử **không** có nghĩa mệnh đề bị vi phạm nếu lời nhắc đã hiện đúng lúc lưu; nó chỉ có nghĩa khi thiếu cả lời nhắc **và** vết. |
| **`I-018`** — mỗi lần CẬP NHẬT giữ được bản trước, bản sau, lý do và người sửa | **Tầng 1 cho hình dạng bản ghi**: một lần cập nhật thiếu **một trong bốn** thứ — bản ghi trước, bản ghi sau, lý do, người sửa — **phải không tồn tại được** ở tầng lưu trữ; đây là **yêu cầu** gửi pha 2 (mục 0 luật 4), pha 2 chưa mở. **Tầng 2 cho vế đồng thời**: việc ghi đủ bốn thứ ấy xảy ra trong **cùng một giao dịch** với chính lần cập nhật — đứt giữa chừng thì bản ghi chính và bản ghi vết lệch nhau, đúng trạng thái mệnh đề này cấm. Áp cho **mọi** lần sửa một bản ghi đã tồn tại, không riêng thao tác chạm tiền (khác `I-012` — hai tập không trùng nhau, xem `quality/invariants.md` mục *Quan hệ với I-012*): sửa nội dung đơn, huỷ đơn đã `Hoàn thành`, sửa sau khi duyệt/huỷ/đóng phiên nhầm, ghi đè khi hai người cùng thao tác một bàn (người bấm sau thắng, nhưng lần đè vẫn phải giữ bản của người trước), lùi một mẻ bấm nhầm, chủ quán đổi giá hoặc thành phần suất. **Không có nút hoàn tác** (trừ đúng ca lùi một mẻ) — mệnh đề này là thứ **thay thế** cho hoàn tác: quán chấp nhận không quay ngược được, đổi lại đòi dựng lại được. | Mọi lần cập nhật một bản ghi đã tồn tại mà thiếu một trong bốn thứ: bản trước, bản sau, lý do, người sửa. · Mọi lần ghi đè do hai người cùng thao tác một bàn mà không dựng lại được trạng thái của người bấm trước. · Mọi lần đổi giá hoặc thành phần suất giữa buổi rồi sửa một dòng đơn cũ mà bảng đối soát (`shop-facts.md` §6.10) không đọc ra được cả giá trị **trước** lẫn **sau** của đúng dòng ấy (`I-009`). **Mọi tập kể trên phải rỗng.** |

### 3.1 Bốn chỗ hàng trên dễ bị ghi sai tầng

- **`I-011` không được ghi tầng 1, kể cả để bảng "đẹp".** Bản đầu của mệnh đề này —
  *"thành phần suất không đổi trong giờ bán"* — viết đúng tầng 1, và bản đó **sai** kể từ lời chốt
  `U-018`. Ghi hàng này tầng 1 hôm nay là nói dối pha 2: pha 2 sẽ dựng một ràng buộc chặn thật, và
  quán mất khả năng sửa thành phần giữa buổi — đúng thứ chủ quán cố ý giữ lại cho mình.
- **`I-009` không phải "khoá giá theo phiên".** Mốc khoá là **từng lượt gọi**
  (`docs/decisions.md` **ADR-023**), nên một hoá đơn phiên bàn mang **hai mức giá** vì vắt qua một
  lần đổi giá là **kết quả đúng**, không phải một chỗ hỏng cần một ràng buộc chặn.
- **`I-010` là *từ chối*, không phải *sửa hộ*.** Không dòng nào của cột giữa được đọc thành một cơ
  chế tự bỏ bớt hay đổi tuỳ chọn để tổ hợp *Chay + Nhiều nhân* thành hợp lệ rồi cho đơn đi tiếp.
- **`I-008` có hai cửa NGƯỜI bấm được, có thứ tự, cộng một điều kiện KHÔNG ai bấm được.** Tạm dừng
  luôn được xét **trước** giờ bán vì nó thắng giờ mở cửa; gộp ba điều kiện thành một câu làm mất
  đúng cái thứ tự ấy, và cũng làm mất chỗ khác nhau giữa "người bấm" và "không ai bấm được".

### 3.2 Bước sau đọc gì ở §3

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-07** — yêu cầu hình dạng dữ liệu | vế lưu bản sao của `I-009` và vế hình dạng bản ghi của `I-018` là hai **yêu cầu** gửi pha 2 (mục 0 luật 4); `I-008` cần một chỗ hệ thống đọc được trạng thái *tạm dừng* và *đang mất kết nối* trước khi tạo lượt gọi |
| ~~**P1-08**~~ — realtime, đường kéo dự phòng, ràng buộc ẩn — **xong 2026-09-08** | cơ chế **phát hiện** quán đang mất kết nối (input cho điều kiện thứ ba của `I-008`) đã có nhà: [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §3 — bốn câu luật, và **độ dài cửa sổ** thì để ngỏ có tên (`U-043`). §3 ở đây vẫn chỉ nói máy phải chặn đúng ba kênh khi đã biết |
| **P1-10** — sổ rủi ro | `I-011` là **tầng 4** của nhóm này — chủ quán tự phá luật của chính mình là **máy không ngăn được**, cùng loại rủi ro với `I-012`/`I-015` (§1) và `I-004` (§2), khác ba loại đó ở chỗ nó là rủi ro **cố ý chấp nhận**, không phải một giới hạn kỹ thuật |
| **P1-11** — diễn ba scenario | mỗi bước chạm menu/giá/vết trỏ được vào một ô cột giữa ở đây; chỗ phải diễn đúng là kịch bản `I-011` (nhắc rồi vẫn cho lưu) và kịch bản `I-009` (một hoá đơn hai mức giá là đúng) |
| **P1-12** — rà ranh giới pha | §3 không có tên bảng · cột · ràng buộc · endpoint · route · component; câu *"phải không tồn tại được ở tầng cơ sở dữ liệu"* và *"đúng một cửa"* là câu về tầng |
| **Pha 2** | **cái gì bắt buộc do cơ sở dữ liệu giữ**: `I-009` (dòng đơn lưu bản sao giá/tên/thành phần, không tham chiếu động) · `I-018` (một lần cập nhật thiếu một trong bốn thứ là không hợp lệ). Và **cái gì không cơ chế nào giữ được, chỉ có lời nhắc + vết**: `I-011` (hàng P1-10 trên) |

---

## 4. Nhóm SẢN XUẤT THEO MẺ — hai mệnh đề (P1-13, 2026-09-07)

`I-019` và `I-020` sinh ở **BA-12, 2026-09-03** — **sau** khi kế hoạch §6 đã chia mười tám mệnh đề
ban đầu thành ba nhóm — nên không nhóm nào trong ba nhóm TIỀN · VÒNG ĐỜI · MENU·GIÁ·VẾT nhận chúng
(`work/findings.md` **F-026**). Chủ repo chốt đường thứ hai trong ba đường F-026 liệt: mở **bước
thứ mười ba**, nhóm riêng (`docs/decisions.md` **ADR-042**). Trục chung của cả hai mệnh đề là
**sản xuất theo mẻ** — *mẻ là đơn vị bấm, bàn là đơn vị đếm* (chủ quán chốt 2026-09-01, đóng
`U-017`) — không phải tiền và không phải vòng đời của một thực thể.

| Mệnh đề | Bảo vệ bằng | Phép đối chiếu |
|---|---|---|
| **`I-019`** — tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng bàn, cả hai chiều | **Hai vế, hai tầng.** · **Vế *tổng luôn khớp tổng phần chia*: tầng 1** — trạng thái *con số tổng của một dòng nhu cầu (khoá: thành phần + loại nhân + lượng nhân) lệch khỏi tổng các phần đã chia về từng bàn* **phải không tồn tại được** ở tầng lưu trữ: tổng phải là một sự thật suy ra được từ các phần chia (hoặc ngược lại), không phải hai con số ghi độc lập ở hai chỗ. Nếu vì hiệu năng vẫn cần một con số tổng lưu riêng (bản đệm), thì mọi lần một phần chia của một bàn đổi phải cộng/trừ đúng lượng ấy vào tổng trong **cùng một giao dịch** (**tầng 2**) — không có bước giữa chừng nào để hai con số đứng lệch nhau, kể cả khi mất điện giữa hai bước ghi. · **Vế *khoá gom là ranh giới phép cộng*: tầng 3** — đúng **một** hàm gom nhận lượt gọi của từng bàn và xếp vào đúng dòng theo khoá; mọi lời gọi tạo hoặc sửa một dòng nhu cầu đi qua đúng hàm đó, không có đường tắt tự gộp hai khoá khác nhau cho gọn hay tự tách một khoá làm hai dòng. | Với **mỗi** dòng nhu cầu (một khoá gom): tổng các phần chia về từng bàn phải bằng đúng con số tổng của dòng — tính **cả hai chiều**, cộng xuôi (các phần → tổng) và tách ngược (tổng → đúng các phần đã ghi). Và: không tồn tại hai dòng khác nhau cùng chung một khoá gom (gộp nhầm bỏ sót), cũng không tồn tại một khoá gom bị tách thành hai dòng (tách nhầm sinh thừa). **Cả hai tập phải rỗng.** |
| **`I-020`** — số đã phục vụ của một bàn không bao giờ vượt số bàn ấy đã gọi | **Bốn vế, ba tầng.** · **Vế *trần trên, kể cả trạng thái giữa*: tầng 1** — với mỗi bàn và mỗi thành phần, trạng thái *đã bưng ra bàn vượt số đã gọi* **phải không tồn tại được** ở tầng lưu trữ; cùng ràng buộc áp cho *đã làm xong còn ở bếp* cộng *đã bưng ra bàn* không vượt số đã gọi — ba trạng thái của một việc trạm loại trừ nhau. · **Vế *một mẻ phủ nhiều bàn, một lần bấm*: tầng 2** — bấm *"đã làm xong"* cho một mẻ phủ N bàn thì phần cộng cho **mỗi** bàn (đúng bằng phần bàn ấy đã gọi trong mẻ, dùng lại chính khoá gom của `I-019`) phải ghi trong **cùng một giao dịch** — không có trạng thái giữa chừng nơi vài bàn đã được cộng còn bàn khác chưa. · **Vế *đường lùi*: tầng 2** — một lần lùi phải là giao dịch nghịch đảo đúng những gì giao dịch tiến đã cộng, cho **mọi** bàn trong mẻ, cùng lúc; không lùi được một phần của mẻ mà để phần còn lại đứng nguyên. · **Vế *ba trạng thái loại trừ nhau*: tầng 3, trỏ sang `I-016`** — đúng một cửa chuyển trạng thái giữ cho *chưa làm* / *đã xong còn ở bếp* / *đã ra bàn* không lẫn vào nhau; hàng này không mô tả lại cơ chế đã viết ở `I-016` (§2). Vết của mỗi lần lùi là **tầng 4**, trỏ sang `I-012`/`I-018`: máy không ngăn được người bấm lùi sai bối cảnh, cái máy **có** giữ là một vết đọc được. | Với **mọi** bàn và **mọi** thành phần: *còn thiếu* = đã gọi − đã bưng ra bàn **không bao giờ âm**; và *đã làm xong còn ở bếp* + *đã bưng ra bàn* của một bàn **không vượt** số đã gọi. **Cả hai tập phải rỗng**, đo lại sau mỗi lần huỷ đơn và sau mỗi lần bấm lùi. |

### 4.1 Vì sao là nhóm thứ tư, không gấp vào VÒNG ĐỜI (P1-05)

`I-020` trông có dáng một câu vòng đời — *đã phục vụ ≤ đã gọi* đọc gần giống trần trên của một
thực thể, kiểu `I-001`/`I-017`. Nhưng `I-019` là một câu về **phép cộng** giữa nhiều bàn qua một
khoá gom, không nói về vòng đời của bất kỳ thực thể nào — gấp cả hai vào P1-05 sẽ buộc `I-019`
mượn một tầng nó không có (F-026, đường 1 đã bác vì lý do này). Hai mệnh đề cũng **không độc lập
với nhau**: cơ chế tầng 2 của `I-020` (chia đúng phần cho từng bàn trong một mẻ) **dùng lại đúng**
khoá gom mà `I-019` giữ — chia sai theo khoá gom tự động kéo `I-020` sai theo. Đó là lý do cả hai
đứng chung một nhóm riêng thay vì tách mỗi mệnh đề vào nhóm nó "giống" nhất.

### 4.2 Bốn chỗ dễ đọc sai

- **`I-019` ràng buộc theo KHOÁ GOM, không theo tên món.** Hai combo cùng tên nhưng khác loại nhân
  hoặc khác lượng nhân là **hai dòng khác nhau** — gộp chúng lại cho gọn là đúng loại lỗi mệnh đề
  này cấm (`shop-facts.md` §5.4, §4.5).
- **`I-019` đúng ở CẢ HAI CHIỀU.** Ràng buộc chỉ chiều cộng (các phần → tổng) mà bỏ qua chiều tách
  (tổng → đúng các phần đã ghi) để lại một khe: hai chiều có thể lệch nhau nếu chỉ một chiều được
  giữ.
- **`I-020` không chỉ nói về trạng thái CUỐI.** Nó áp cho cả trạng thái **giữa** (*đã làm xong,
  còn ở bếp*) cộng dồn với *đã bưng ra bàn* — một cơ chế chỉ chặn *đã bưng ra bàn* mà bỏ qua tổng
  hai trạng thái là chặn thiếu một nửa.
- **Đường lùi của `I-020` là một GIAO DỊCH, không phải một API xoá dòng.** Lùi một phần của mẻ mà
  để phần còn lại đứng nguyên phá đúng vế *mọi bàn trong mẻ, cùng lúc*.

### 4.3 Bước sau đọc gì ở §4

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-07** — yêu cầu hình dạng dữ liệu | mọi câu tầng 1 ở đây (`I-019` tổng khớp phần chia, `I-020` trần trên) là **yêu cầu** gửi pha 2; `I-019` cần thêm một yêu cầu riêng — pha 2 phải quyết định tổng là **suy ra** hay **lưu đệm cùng giao dịch**, không được để ngỏ |
| **P1-09** — bảng quầy bốn con số | con số thứ tư (*đã làm xong, còn ở bếp*) đọc trực tiếp từ cơ chế `I-020` giữ ở đây — mẻ là đơn vị bấm, bàn là đơn vị đếm |
| **P1-10** — sổ rủi ro | chia sai phần theo khoá gom (`I-019`) tự động kéo `I-020` sai theo — một rủi ro, hai mệnh đề (§4.1); đường lùi thiếu tầng 2 là rủi ro thứ hai của nhóm này |
| **P1-11** — diễn ba scenario | scenario chạm mẻ phủ nhiều bàn phải trỏ được vào cơ chế tầng 2 ở đây, cả chiều tiến lẫn chiều lùi |
| **P1-12** — rà ranh giới pha | §4 không có tên bảng · cột · ràng buộc · endpoint · route · component |
| **Pha 2** | **cái gì bắt buộc do cơ sở dữ liệu giữ**: `I-020` vế trần trên (đã bưng ra bàn ≤ đã gọi). Và **cái gì cần một giao dịch, không chỉ một ràng buộc**: `I-019` (cộng/trừ một phần chia và tổng cùng lúc) · `I-020` (cộng cho mọi bàn của một mẻ trong cùng giao dịch, và đường lùi là giao dịch nghịch đảo của đúng giao dịch tiến) |
