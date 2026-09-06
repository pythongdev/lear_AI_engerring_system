# Bảo vệ invariant — tầng nào giữ từng mệnh đề, và phép đối chiếu nào bắt nó khi hỏng

*Bước 4/12 · 5/12 · 6/12 của pha 1 — **một file, ba chủ**
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Mở đầu và **§1 — nhóm TIỀN** viết ở **P1-04**, 2026-09-06. **§2 — nhóm VÒNG ĐỜI** là của **P1-05**,
**§3 — nhóm MENU · GIÁ · VẾT** là của **P1-06**; hai mục ấy chưa có, và bước nào viết mục ấy thì
**thêm** mục của mình, không sửa mục của người khác (`work/findings.md` **F-010** · **F-014**).*

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

## 1. Nhóm TIỀN — bảy mệnh đề (P1-04, 2026-09-06)

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
| **`I-015`** — một lần thu chia nhiều phương thức | **Ba vế, ba tầng.** · **Tầng 1** cho *tổng khớp* và *ghi riêng từng phần*: trạng thái *tổng các phần đã thu vượt số phải trả* và trạng thái *một phần đã thu không mang đúng một phương thức trong hai phương thức của `shop-facts.md` §1* đều **phải không tồn tại được**; thu thiếu thì phần thiếu **phải** thành một khoản nợ theo **`I-005`**. · **Tầng 2** cho *các phần của một lần thu cùng sống hoặc cùng chết*: đứt giữa hai phần ghi thì tổng hết khớp và phần đã ghi trông y hệt một lần thu thiếu — mà một lần thu thiếu thì `I-005` đòi một khoản nợ có tên, nên chỗ hỏng này đẻ ra một khoản nợ không có thật. Mọi phần cũng dùng chung **một** mốc tính tiền ([`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2.1). · **Vế *tiền đã thật sự vào tài khoản*: tầng 4 — và đây là ô nói thẳng nhất của cả bảng.** VietQR ở quán là mã **TĨNH**, không có đường nào báo tiền về ([`architecture.md`](architecture.md) §7 · `shop-facts.md` §1): hệ thống **không tự biết** tiền đã vào tài khoản, nên **máy không ngăn được** một lần bấm *đã nhận tiền* khi tiền chưa về. Câu ấy do **người đứng quầy** nhìn tin nhắn báo có rồi nói, và hệ thống chỉ **ghi lại lời ấy**. Cái máy **có** giữ thay vào là ba thứ khác: *tổng các phần = số phải trả*, *từng phần ghi riêng theo phương thức*, và *lần bấm ấy để lại vết có tên* (**`I-012`**) — đủ để cuối ngày so **phần chuyển khoản** với **tin nhắn báo có** và chỉ ra đúng một người khi lệch. **Đừng thiết kế một cơ chế để nâng vế này lên**: mã tĩnh là dữ kiện quán, đổi nó là câu của chủ quán, không phải của pha 1. | Mọi lần thu mà tổng các phần khác số phải trả và phần thiếu **không** có một khoản nợ đúng bằng nó. · Mọi lần thu có một phần không mang phương thức nào, hoặc ghi gộp thành một con số tổng. · Mọi lần thu có các phần rơi vào **hai** ngày bán khác nhau. · Mọi ngày mà **tổng phần chuyển khoản** khác tổng tin nhắn báo có của ngày ấy — tính riêng, **không** cộng gộp với phần tiền mặt (`shop-facts.md` §6.10). · Mọi ngày mà **tổng phần tiền mặt** không khớp két theo phép trừ tiền đầu két — mệnh đề ấy là **`I-021`**, và nó **không** thuộc nhóm này (§1.3). **Mọi tập kể trên phải rỗng.** |

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

### 1.3 Ba mệnh đề chạm bảng này mà không thuộc nhóm nào — `I-019` · `I-020` · `I-021`

**Đo lại 2026-09-06:** `quality/invariants.md` giữ **hai mươi mốt** mệnh đề, trong khi kế hoạch §6
chia **mười tám** thành ba nhóm và cổng §9 vẫn đếm *"mười tám"*. Ba mệnh đề ngoài nhóm:
`I-019` · `I-020` (sinh ở BA-12, 2026-09-03) và **`I-021`** (sinh ở T-056, 2026-09-04). Đây là
`work/findings.md` **F-026**, đang **Open**.

**Bước này không kéo cái nào vào bảng của mình và cũng không lặng lẽ bỏ chúng** — xếp nhóm là quyết
định của **chủ repo** (F-026 mục *Decision / Fix*, ba đường đã ghi sẵn ở đó). Một câu **đề xuất**,
không phải một quyết định: **`I-021` gần nhóm TIỀN hơn hai mệnh đề kia rất nhiều** — nó là phép trừ
*két cuối ngày − tiền đầu két = doanh thu tiền mặt*, đứng cùng chỗ với `I-014` và `I-015` và bị ô
`I-015` của bảng trên **trỏ vào** vì không có nó thì vế *phần tiền mặt so với két* không đọc được.
Chủ repo quyết thì bảng này thêm **một** hàng vào §1; tới lúc đó nó đứng ngoài, có tên, ở đây.

### 1.4 Bước sau đọc gì ở §1

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-07** — yêu cầu hình dạng dữ liệu | mọi câu *"trạng thái này phải không tồn tại được"* ở cột giữa là một **yêu cầu** gửi pha 2; và vế *vết đọc được sau nhiều ngày* của `I-012` là của P1-07, §1 cố ý không thiết kế chỗ cất vết |
| **P1-10** — sổ rủi ro | hai ô tầng 4 (`I-012` chỗ đứng dùng chung · `I-015` VietQR tĩnh) và một vế tầng 5 (`I-014` cộng thiếu một nguồn) là ba chỗ **máy không ngăn được** của nhóm tiền — rủi ro có tên sẵn, không phải *"cẩn thận hơn"* |
| **P1-11** — diễn ba scenario | mỗi bước chạm tiền trỏ được vào một ô cột giữa ở đây; `U-036` và `U-037` đã đóng 2026-09-06 nên không còn chỗ nào phải dừng ở ô `I-014` |
| **P1-12** — rà ranh giới pha | §1 không có tên bảng · cột · ràng buộc · endpoint · route · component; câu *"phải do cơ sở dữ liệu giữ"* là câu về tầng |
| **Pha 2** | **cái gì bắt buộc do cơ sở dữ liệu giữ**: `I-002` (một phiên một hoá đơn) · `I-005` (nợ có chủ, nợ không phải tiền đã thu) · `I-007` (đơn mang đi không dính phiên bàn) · `I-012` (vết đủ bốn câu) · `I-014` (một khoản một nguồn) · `I-015` (tổng khớp, từng phần có phương thức). Và **cái gì không cơ chế nào giữ được**: ba chỗ ở hàng P1-10 trên |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch §5). Đo lại 2026-09-06: §1.1, §3.3, §4, §6.3, §6.4, §7, §12.2 và §12.3 không
chỗ nào nói ngược bảng trên — §12.3 nói **hình dạng** của phần nợ và tự khai là đề xuất pha 2, còn
bảng trên nói **tầng**, hai câu khác nhau về cùng một mệnh đề.

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
