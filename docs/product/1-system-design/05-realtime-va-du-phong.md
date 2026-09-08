<a id="top"></a>
# Realtime và đường dự phòng — hai đường xuống trạm, bốn ràng buộc, bốn dấu hiệu phải xem lại

*Bước 8/14 của pha 1 — **P1-08**, chốt 2026-09-08
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Đầu vào: [`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2 · §3 (**PT-2** · **PT-5** ·
**PT-6**) · [`architecture.md`](architecture.md) §1.1 · §5 · `quality/invariants.md` **I-008** ·
**I-009** · **I-012** · `master_plan/shop-facts.md` §1 · §6.11 ·
`work/findings.md` **F-027** · `docs/decisions.md` **ADR-011** · **ADR-041** · **ADR-045**.*

> **Mục này sở hữu đúng ba thứ:** **hai đường** đưa việc xuống màn trạm và luật giữa chúng · **bốn
> ràng buộc kiến trúc** cùng **dấu hiệu đo được** bắt phải xem lại từng cái · và câu trả lời *hệ
> thống dựa vào cái gì để nói **quán đang mất kết nối***.
>
> **Nó không sở hữu một cơ chế nào.** Ở đây không có tên công nghệ, tên thư viện, tên giao thức,
> và không một con số chu kỳ nào. Pha 1 nói **tính chất** sinh ra ràng buộc; **pha 3** chọn thứ có
> tính chất ấy, **pha 5** chọn cách chạy nó (**ADR-035**).
>
> **Nó không sở hữu một dữ kiện quán nào.** Giờ bán, số bàn, bảng menu, tên của chỗ hệ thống đang
> chạy đều thuộc `master_plan/shop-facts.md` (**ADR-001**); ở đây chỉ có **pointer**, không có bản
> thứ hai (`work/findings.md` **F-001**).
>
> **Nó không viết lại một mệnh đề bất biến nào.** `I-008` đã nói *đơn tạo ra trong lúc quán mù là
> đơn không được phép tồn tại*; mục này chỉ cấp **đầu vào** cho điều kiện thứ ba của nó (§3).
>
> **Vì sao mục này tồn tại.** Bốn ràng buộc quyết định hình dạng của cả hệ thống — *một tiến trình ·
> không hàng đợi · không bộ nhớ đệm · một chỗ chạy duy nhất* — trước hôm nay chỉ sống ở
> `master_plan/prompt-fullstack.md` §6.8, một **bản xuất khẩu tự khai không sở hữu sự thật nào**
> (**ADR-035**), và không cái nào có dấu hiệu xem lại đo được. Đó là `work/findings.md` **F-027**.

---

## 1. Hai đường xuống trạm — và không đường nào được là đường duy nhất

Việc ở bếp **sinh ra từ đơn đã duyệt** và **không trạm nào bấm gì** để báo xong: màn trạm là màn
**chỉ đọc**, thẻ tự biến mất khi POS ghi *đã phục vụ* ([`architecture.md`](architecture.md) §1.1 ·
§5, chủ quán chốt 2026-08-31, `docs/decisions.md` **ADR-011**). Cả hình dạng của mục này đứng trên
câu ấy: **người ở bếp không có cách nào hỏi lại hệ thống**, nên hệ thống phải tự đúng.

### 1.1 Đường đẩy — việc chạy xuống trạm ngay khi nó sinh ra

Đường **đẩy** là đường mặc định: POS ghi một thứ, màn trạm liên quan thấy nó **ngay**, không ai
phải chờ tới nhịp sau.

**Tính chất sinh ra ràng buộc, và đây là chỗ phải đọc kỹ:** một đường đẩy giữ **kết nối mở trong
bộ nhớ của tiến trình đang phục vụ nó**. Cái đang nhớ *"màn trạm nào đang nối, và nó chờ việc
gì"* nằm trong đúng một tiến trình, không nằm ở nơi ghi. Ràng buộc **RB-1** ở §2 là hệ quả trực
tiếp của tính chất này — không phải một sở thích kỹ thuật.

**Tên của thứ mang tính chất ấy là việc của pha 3.** Ở đây không có tên giao thức, không có tên
thư viện. Pha 3 chọn thứ nào cũng được, miễn nó thoả cả ba: đẩy được một chiều từ hệ thống xuống
màn · không đòi màn trạm bấm gì · và **nói được cho phía nhận biết là nó còn sống**.

### 1.2 Đường kéo — dự phòng bắt buộc, và nó tự chạy

**Realtime không được là đường duy nhất.** Câu này đã đứng ở [`architecture.md`](architecture.md)
§5 từ trước; mục này là nhà của nó, và viết nó ra thành ba luật:

1. **Mỗi màn chỉ đọc tự lấy lại dữ liệu của nó theo chu kỳ, không cần đường đẩy còn sống.** Mất
   đường đẩy thì màn vẫn **đúng**, chỉ **trễ hơn** — trễ nhiều nhất một chu kỳ.
2. **Đường kéo tự chạy. Nó không phải một cái nút.** Màn trạm **không có nút nào** (**ADR-011**);
   một câu *"trạm bấm tải lại"* là phá đúng lời chủ quán đã chốt, và nó giao việc phát hiện hỏng
   hóc cho đúng ba đôi tay đang bận.
3. **Hai đường trả về cùng một sự thật.** Đường kéo đọc ở **nơi ghi**, không đọc một bản tính sẵn
   nào khác. Hai đường tính ra hai kết quả khác nhau là bản sao thứ hai của cùng một con số
   (**F-001**), và cái sai sẽ là cái người ở bếp nhìn thấy.

**Chu kỳ là một con số của pha 3, không phải của mục này.** Pha 1 chỉ đòi ba điều đo được: có chu
kỳ · chu kỳ là **một** con số của hệ thống chứ không phải mỗi màn một kiểu · và không màn nào đứng
im quá một chu kỳ khi đường đẩy đã chết. Bản xuất khẩu §6.8 đề xuất một con số cụ thể; nó là **đề
xuất**, không phải luật, và pha 3 chốt.

### 1.3 Màn rỗng phải nói được vì sao nó rỗng

Đây là chỗ hỏng đắt nhất của cả mục, và nó sinh ra từ chính lời chủ quán đã chốt: vì màn trạm
**không có nút nào**, một màn **rỗng vì hết việc** trông **y hệt** một màn **rỗng vì mất kết nối**.
Người tráng bánh nhìn màn trắng và đọc ra *"chưa có việc"*, trong khi bàn 7 đang chờ.

⇒ **Luật:** một màn chỉ đọc phải cho biết **nó vừa lấy lại dữ liệu lúc nào**, và phải phân biệt
được *rỗng-vì-hết-việc* với *rỗng-vì-không-lấy-được*. Đây là câu **cái gì phải đúng**; **trông thế
nào** là việc của pha 4 — mục này không mô tả một cái nhãn, một màu, hay một dòng chữ nào.

---

## 2. Bốn ràng buộc kiến trúc, mỗi cái một dấu hiệu đo được

**Bốn ràng buộc này là *chưa cần, và đây là dấu hiệu để xem lại*, không phải giáo điều.** Một ràng
buộc không có dấu hiệu thì chỉ có hai kết cục: giữ mãi vì không ai dám bỏ, hoặc bỏ vì cảm tính giữa
một buổi đông khách. Nên mỗi hàng dưới đây phải trả lời được câu *cái gì xảy ra thì tôi mở lại
quyết định này*, bằng **một con số hoặc một sự kiện quan sát được** — và bằng thứ **đã có sẵn**,
không phải bằng một phép đo phải dựng thêm mới đo được.

**Ba trong bốn ràng buộc được chốt ở chính bước này** (`docs/decisions.md` **ADR-045**, đóng nốt
**F-027**); ràng buộc thứ tư — *một chỗ chạy duy nhất* — chủ repo đã chốt 2026-09-07 (**ADR-041**,
tên của chỗ ấy ở `master_plan/shop-facts.md` §1).

| Mã | Ràng buộc | Vì sao nó tồn tại | **Dấu hiệu đo được** phải xem lại | Ai đo, bằng cái gì đã có |
|---|---|---|---|---|
| **RB-1** | Đúng **một** tiến trình phục vụ đường đẩy | §1.1 — kết nối sống trong bộ nhớ của tiến trình ấy. Thêm một tiến trình thứ hai mà không có chỗ chung giữ *"ai đang nối"* ⇒ trạm nối vào tiến trình không cầm việc của mình và **mất việc ngẫu nhiên**: không tái hiện được, xảy ra đúng lúc đông khách, và màn trạm không có nút nào để ai đó kịp nghi ngờ (§1.3) | Hệ thống phải **khởi động lại trong giờ bán quá một lần trong một tháng** vì tiến trình ấy không còn chịu nổi tải (giờ bán: `master_plan/shop-facts.md` §1) | Người vận hành, đếm trên chính nhật ký khởi động của hệ thống — không phải dựng thêm phép đo nào |
| **RB-2** | **Không** hàng đợi: một lần bấm ghi xong trong chính lượt bấm | Hàng đợi thêm một chỗ để việc **nằm im mà không ai nhìn thấy**. POS là nơi **duy nhất** ghi (§1.1), nên *đã bấm* và *đã ghi* phải là cùng một khoảnh khắc — tách ra thì vết (`quality/invariants.md` **I-012**) và bảng đối soát cuối ngày đứng trên hai thời điểm khác nhau, đúng chỗ ngưỡng lệch **0đ** hết nghĩa | **Người đứng quầy bấm duyệt một đơn mà phải chờ quá 500 mili-giây** mới thấy màn hình trả lời, **lặp lại** chứ không phải một lần lẻ (`master_plan/prompt-fullstack.md` §6.8 đề xuất con số; bước này nhận nó làm dấu hiệu) | Người dựng đo ở chính máy quầy — và người đứng quầy **thấy trước cả máy đo**: nửa giây chờ là nhìn được bằng mắt |
| **RB-3** | **Không** bộ nhớ đệm: menu và giá đọc thẳng ở nơi ghi | Một bộ nhớ đệm là **bản thứ hai** của con số đang dùng để thu tiền (**F-001**). `I-009` khoá giá theo **từng lượt gọi** (**ADR-023**): một bản cũ sống thêm vài giây là một hoá đơn tính bằng cái giá chủ quán vừa đổi, và không ai nhìn thấy chỗ lệch ấy cho tới lúc đối soát | **Menu vượt 200 dòng suất bán** (`prompt-fullstack.md` §6.8 đề xuất; bước này nhận làm dấu hiệu) | Chủ quán hoặc POS đếm ở chính màn quản trị menu. Bảng suất bán hôm nay (`master_plan/shop-facts.md` §4.3) còn **rất xa** ngưỡng ấy — đo lại ở đó, đừng tin một con số chép về đây |
| **RB-4** | Toàn bộ hệ thống chạy ở **đúng một chỗ** | **PT-2** ([`01-ranh-gioi-he-thong.md`](01-ranh-gioi-he-thong.md) §2 · §3): chỗ ấy chết thì **cả năm kênh bán qua máy** chết cùng lúc, và hai kênh khách tự bấm **mất hẳn** — không đơn nào để nhập bù vì đơn ấy chưa từng tồn tại. Ràng buộc này chỉ đứng được **vì** quán có đường bán không đi qua máy: **sổ giấy** là đối trọng **bắt buộc**, không phải một lời an ủi (**PT-6** · `master_plan/shop-facts.md` §6.11) | Quán phải chuyển sang **sổ giấy vì hệ thống chết** quá **một buổi bán trong một tháng** | Chủ quán, ở bảng đối soát cuối ngày: dòng ***"còn N lượt bán trên giấy chưa nhập"*** (§6.11) đã tồn tại sẵn. Đếm những ngày dòng ấy khác 0 **vì hệ thống chết** — người giữ sổ biết ngày nào là mất điện (**PT-1**), ngày nào là hệ thống chết |

**Ba luật đọc bảng này, không cái nào là hình thức:**

1. **Dấu hiệu bật thì việc phải làm là *mở lại quyết định*, không phải *bỏ ràng buộc*.** Với
   **RB-1** cụ thể: dấu hiệu bật **không** cho phép thêm một tiến trình thứ hai ngay. Thứ phải có
   **trước** là một chỗ chung giữ *"màn nào đang nối"* nằm **ngoài** bộ nhớ tiến trình; thêm tiến
   trình trước khi có chỗ ấy là dựng ra đúng cái hỏng ngẫu nhiên mà RB-1 sinh ra để chặn.
2. **Bỏ một ràng buộc thì ghi một ADR, không sửa lặng.** Bốn dòng này là quyết định có ngày tháng
   (`docs/decisions.md` **ADR-041** · **ADR-045**); đổi chúng bằng một dòng cấu hình là làm mất
   đúng thứ mục này sinh ra để giữ.
3. **Khi một ràng buộc được nới, cái được nới trước là thứ KHÔNG chạm tiền.** Với **RB-2**: chỗ
   đầu tiên được phép trễ là **đường báo đơn về quầy** (**PT-5**) — đường suy giảm của nó đã nói
   rõ *đơn vẫn vào hệ thống, chỉ là không ai được báo* — **không** phải đường ghi đơn hay ghi tiền.
   Với **RB-3**: được phép đệm thứ chỉ để **nhìn** (danh mục, tên hiển thị); **giá thì không** —
   giá luôn tính ở nơi ghi ([`architecture.md`](architecture.md) §1.2).

---

## 3. Hệ thống dựa vào cái gì để nói *quán đang mất kết nối*

`quality/invariants.md` **I-008** có **ba** điều kiện để một đơn được tạo, và điều kiện thứ ba —
*quán đang nhìn thấy được đơn mới* — là điều kiện **duy nhất không ai bấm được**: lúc quán mất
mạng thì nút *"Tạm dừng nhận đơn"* cũng nằm sau đúng đường mạng vừa mất. I-008 giao thẳng phần
**cơ chế** cho bước này. Bước này trả lời bằng **bốn câu luật**, không bằng một cơ chế:

1. **Phán quyết đứng ở phía hệ thống, không phía quán.** Đúng lúc phải phán quyết thì quán là bên
   đã mất tiếng nói — mọi thiết kế chờ quán *báo* rằng mình đang mù đều hỏng ở đúng ca nó sinh ra
   để xử.
2. **Dấu hiệu *quán còn nhìn thấy* phải chạy trên CÙNG đường mà việc và đơn đang đi** (§1). Dùng
   một đường riêng để kiểm thì có ngày đường kiểm còn sống trong khi đường thật đã chết, và hệ
   thống sẽ nhận đơn cho một cái quán đang mù.
3. **Phán quyết ấy chỉ chạm ba kênh khách tự bấm.** Hai kênh do người của quán nhập **không** dừng
   — họ ghi giấy (**I-008**, chủ quán chốt 2026-09-04). Có tín hiệu trở lại thì ba kênh kia **mở
   lại ngay**; không có luật chờ thêm nào, và mục này không mở ra luật ấy.
4. **Mỗi lần hệ thống tự chuyển sang *quán đang mù* phải đọc lại được sau nhiều ngày** — bắt đầu
   lúc nào, kết thúc lúc nào. Một lần web ngừng nhận đơn mười lăm phút mà không để lại gì là một
   khoản doanh thu không ai từng biết là đã mất. *Câu này là một **yêu cầu hình dạng dữ liệu**, và
   nhà của loại câu đó là [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §1 — nơi mỗi dòng phải
   khớp một-đối-một với một dòng của [`architecture.md`](architecture.md) §8 (luật của **P1-07**).
   Bước này **không** tự thêm dòng vào hai file ấy; nó ghi ra chỗ trống, có tên, ở §4.*

**Bao lâu không thấy tín hiệu thì gọi là mất kết nối** — mục này **không** chốt, và cũng không để
pha 3 tự chốt: xem `U-043` ở §4.

---

## 4. Chỗ cố ý để trống — ba chỗ, mỗi chỗ một cái tên

| Chỗ trống | Vì sao không tự quyết | Ai đóng được |
|---|---|---|
| **Cửa sổ thời gian** để gọi là *quán đang mất kết nối* — mất tín hiệu bao lâu thì web ngừng nhận đơn | Con số này quyết định **lúc nào quán ngừng bán trên web**: ngắn quá thì một lần mạng chập chờn cắt mất khách đang đặt; dài quá thì đơn rơi vào một cái quán không ai nhìn thấy — đúng cái `I-008` sinh ra để chặn. Đây là đánh đổi của **quán**, không phải một tham số kỹ thuật (`CLAUDE.md` §3.5) | **Chủ quán** — `docs/product/99-unknowns.md` **`U-043`**, mở trong lượt này. Có lời chốt thì con số vào `master_plan/shop-facts.md`, pha 3 thi hành |
| **Câu chữ dòng thông báo** khách nhìn thấy khi ba kênh tự bấm dừng | Chủ quán mới nói *có một dòng*, chưa đọc nội dung (`quality/invariants.md` **I-008**) — tự viết một câu rồi coi là đã chốt là bịa một dữ kiện quán | **Chủ quán**, hỏi khi dựng màn (**pha 4**) |
| **Dòng yêu cầu dữ liệu cho vết của mỗi lần tự chuyển sang *quán đang mù*** (§3 luật 4) | Nhà của loại câu ấy là [`04-yeu-cau-du-lieu.md`](04-yeu-cau-du-lieu.md) §1, và mỗi dòng ở đó phải khớp một-đối-một với một dòng [`architecture.md`](architecture.md) §8 — luật của **P1-07**. Thêm hộ một dòng vào hai file của bước khác là phá đúng phép chấm ấy | **P1-07** (thêm một cặp dòng), hoặc **pha 2** khi nó đọc §3 luật 4 ở đây |

**Ba thứ thuộc pha sau, và mục này cố ý không chạm:** tên của thứ mang tính chất đường đẩy và
**con số chu kỳ** của đường kéo (**pha 3**) · cách chạy, cách theo dõi, cách khởi động lại ở chỗ
duy nhất ấy (**pha 5**) · hình dạng của màn khi nó rỗng (**pha 4**, §1.3).

---

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì từ mục này |
|---|---|
| **P1-10** — sổ rủi ro | **RB-1** và **RB-4** là hai rủi ro đã có cơ chế chặn viết ra thành chữ; §1.3 là rủi ro *bếp làm thiếu mà không ai biết*, đã có luật chặn. Sổ rủi ro **trỏ** về đây thay vì viết lại |
| **P1-11** — diễn ba scenario | Một buổi mất kết nối phải đi qua được §3 (ba kênh dừng, hai kênh không) và §1.2 (màn trạm trễ nhưng vẫn đúng) |
| **P1-12** — rà chéo ranh giới pha | Mục này là chỗ dễ lọt tên công nghệ nhất của cả pha 1. Bộ lọc gợi ý ở `prompt/SD/P1-08-realtime-du-phong-L2.md` mục *Verify* |
| **Pha 2** | §3 luật 4 — vết của mỗi lần hệ thống tự chuyển sang *quán đang mù* phải đọc lại được sau nhiều ngày |
| **Pha 3** | §1.1 ba tính chất bắt buộc của đường đẩy · §1.2 ba luật của đường kéo và con số chu kỳ · §3 bốn luật phán quyết, **sau khi** `U-043` có lời chốt |
| **Pha 5** | **RB-1** và **RB-4** — và luật 2 của §2: bỏ một ràng buộc thì ghi ADR, không sửa lặng |

**Mâu thuẫn với [`architecture.md`](architecture.md) thì sửa `architecture.md`, không viết bản thứ
hai ở đây** (kế hoạch pha 1 §5). Tính tới 2026-09-08 không có chỗ nào mâu thuẫn: §5 của nó nói
*"màn trạm vẫn phải tự lấy lại dữ liệu theo chu kỳ"*, đúng bằng §1.2 ở đây, và §5 nay mang một dòng
trỏ về mục này.

[↑ đầu file](#top)
