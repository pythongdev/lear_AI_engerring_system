<a id="top"></a>
# Yêu cầu hình dạng dữ liệu — cái gì phải ghi lại được, cái gì phải không xảy ra được

*Bước 7/14 của pha 1 — **P1-07**, 2026-09-07
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Đầu vào: [`architecture.md`](architecture.md) §8 · §4 · §12.3 · `quality/invariants.md` `I-012` ·
`I-018` · `master_plan/shop-facts.md` §5.4 · §6.4 · §6.11 · §6.14 · §6.15 ·
[`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4 (BA-12, xong 2026-09-04) ·
[`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §5.*

> **Mục này sở hữu yêu cầu dữ liệu:** YC-01…YC-20, YC-22…YC-25 và YC-34 để pha 2 tự chấm lược đồ;
> YC-21 (§8) để pha 5 nghiệm thu bảo toàn và khôi phục. Yêu cầu không chốt cơ chế triển khai.
> YC-26…YC-33 ở §9 là của mảng admin, do các bước `P2A-XX` chấm.
>
> **Nó không sở hữu một luật nghiệp vụ nào.** Giá, giờ bán, ai được bấm cái gì, ngưỡng lệch 0đ đều
> thuộc `master_plan/shop-facts.md` (**ADR-001**). Cột *Luật nguồn* dưới đây **trỏ** về đó và cố ý
> **không chép** — bản thứ hai luôn trôi (`work/findings.md` **F-001**).
>
> **Nó không sở hữu lời của một mệnh đề bất biến nào.** `I-0xx` có nhà ở `quality/invariants.md`;
> **tầng** giữ từng mệnh đề và **phép đối chiếu** bắt nó khi hỏng thì ở
> [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md). Mục này là nửa thứ ba của cùng một bộ: *cái
> gì phải có chỗ cất thì hai nửa kia mới nói được thành câu*.
>
> **Ở đây không có tên bảng, tên cột, khoá ngoại, endpoint hay route** (**ADR-035**). Một câu
> *"phải ghi lại được ai bấm"* là câu về **cái phải biết**; cất nó **thế nào** là việc của
> **pha 2**. Chỗ duy nhất trong repo hôm nay đã vẽ một hình dạng cụ thể là
> [`architecture.md`](architecture.md) §12.3, và chính nó tự khai là **đề xuất gửi sang pha 2**,
> không phải lược đồ đã chốt — mục này **trỏ** sang đó, **không chép về**.
>
> **Cập nhật 2026-09-30 (`P2-14`, Claude Code):** câu *"chỗ duy nhất trong repo hôm nay"* là **ảnh
> chụp lúc viết**. Hình dạng thật nay ở [`../2-db/`](../2-db/02-luoc-do-ban-hang.md) — năm file lát
> `02`…`06` và file migration chúng trỏ tới (**ADR-053** luật 2); §12.3 đã được
> [`../2-db/04-luoc-do-duong-tien.md`](../2-db/04-luoc-do-duong-tien.md) thay thế (2026-09-28, `P2-06`).

---

## 0. Cách đọc — hai dạng câu, và một mã

YC-01…YC-20, YC-22…YC-25 và YC-34 mang mã `YC-XX` và dùng hai dạng câu dưới đây. YC-21 ở §8 là yêu cầu
khôi phục, nghiệm thu ở pha vận hành; YC-26…YC-33 ở §9 là của mảng admin, dùng cùng hai dạng
câu và do các bước `P2A-XX` chấm:

| Dạng | Câu mở đầu | Pha 2 chấm thế nào |
|---|---|---|
| **Ghi được** | *"phải ghi lại được X"* | dựng một ca thật rồi đọc lại X **sau nhiều ngày**; đọc không ra ⇒ lược đồ thiếu chỗ cất |
| **Không xảy ra được** | *"phải không thể xảy ra Y"* | cố tình dựng Y; dựng được ⇒ lược đồ thiếu một cái chặn |

Bốn luật đọc:

1. **Một dòng yêu cầu không nói hình dạng.** Nó nói *cái gì phải biết được* và *cái gì phải không
   làm được*. Bao nhiêu bảng, tên gì, tách hay gộp là quyền của pha 2 — miễn mọi dòng ở đây trả
   lời được.
2. **"Phải không thể xảy ra" không có nghĩa là "cơ sở dữ liệu phải chặn".** Tầng nào giữ nó là câu
   của [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md), và ở đó có những ô nói thẳng *"máy không
   ngăn được"*. Mục này chỉ đòi **trạng thái sai ấy phải gọi tên được**; ai chặn là chuyện khác.
3. **Đọc lại được SAU NHIỀU NGÀY là một phần của yêu cầu, không phải lời văn.** Đối soát cuối ngày
   lấy ngưỡng lệch **0đ** (`master_plan/shop-facts.md` §6.10), và một khoản nợ sống qua nhiều ngày
   (§6.14). Một vết chỉ đọc được trong phiên đang chạy là một vết không có giá trị nào ở đây.
4. **Mỗi dòng của [`architecture.md`](architecture.md) §8 có ĐÚNG MỘT dòng ở §1 dưới đây.** Đó là
   phép chấm của chính bước này: §8 nói *thiếu cái gì*, §1 nói *phải đúng cái gì*. Thêm một dòng
   vào §8 thì thêm một dòng ở đây trong cùng thay đổi, và ngược lại.

---

## 1. Mười ba chỗ thiếu ở `architecture.md` §8 — mỗi chỗ đúng một dòng yêu cầu

§8 là danh sách **chỗ mô hình 16 bảng chưa với tới**. Bảng dưới đây là cùng danh sách ấy, đọc theo
chiều ngược lại: không phải *thiếu cái gì*, mà *pha 2 phải chấm được cái gì*.

| §8 nói thiếu | Mã | Câu yêu cầu | Luật nguồn |
|---|---|---|---|
| **Vết hoàn tiền** | **YC-01** | **Ghi được:** mỗi lần hoàn tiền đọc lại được đủ **năm** thứ — hoàn **bao nhiêu** · cho **lượt bán nào** · **ai bấm** · **lúc mấy giờ** · **lý do gì**. **Không xảy ra được:** một lần hoàn tiền thiếu bất kỳ thứ nào trong năm, **kể cả lý do** — quán cố ý không có luật cứng về hoàn tiền, nên lý do là thứ duy nhất thay được luật | `shop-facts.md` §6.4 · `quality/invariants.md` **I-012** |
| **Khoản nợ** | **YC-02** | **Ghi được:** một khoản nợ đứng được **sau khi phiên bàn của nó đã đóng** — ai nợ · bao nhiêu · thuộc đúng một phiên · lúc ghi; khách **trả dần** được, và **mỗi lần trả** đọc ra ngày giờ trả, số tiền trả, **số còn thiếu sau lần ấy**; khoản nợ đọc ra còn thiếu bao nhiêu và đã trả xong hay chưa. **Không xảy ra được:** đóng phiên thu thiếu mà không có chủ nợ và số tiền · một khoản nợ được cộng vào tiền đã thu của ngày ghi nợ · một phiên mang **hai** khoản nợ chưa thu cùng lúc · một số tiền nợ không dương · tổng các lần trả **vượt** số nợ · một lần trả số tiền không dương · một lần trả có số còn thiếu khác số nợ trừ mọi lần trả tới lúc ấy. *Viết lại 2026-10-01 (`T-126`, **ADR-075**) theo lời đóng `U-063`; bản trước chỉ có hai trạng thái chưa thu · đã thu.* Hình dạng nhỏ nhất đủ dùng đã có ở [`architecture.md`](architecture.md) **§12.3** — đọc ở đó, §2 dưới đây chỉ nói **cái §12.3 không nói**. *Chỗ cất thật (pha 2, `P2-06`, 2026-09-28): [`../2-db/04-luoc-do-duong-tien.md`](../2-db/04-luoc-do-duong-tien.md) §2.* | `shop-facts.md` §6.14 · `I-005` · `I-015` |
| **Vết thao tác chạm tiền / chạm trạng thái đơn** | **YC-03** | **Ghi được:** mỗi thao tác chạm tiền đọc lại được đủ **bốn** câu (cái gì · bao nhiêu · ai · mấy giờ), **và** mỗi lần sửa một bản ghi đã có dựng lại được **bản trước**, **bản sau**, **lý do**, **người sửa**. **Không xảy ra được:** một chỗ lệch trong bảng đối soát cuối ngày mà không quy được về **đúng một** thao tác có tên người. Hai vế trên là **hai** mệnh đề khác nhau — §3 dưới đây | `shop-facts.md` §6.10 · **I-012** · **I-018** |
| **Ai đang trực trạm nào, lúc này** | **YC-04** | **Ghi được:** ở **bất kỳ thời điểm nào trong quá khứ**, đọc ra được ai đang trực trạm nào; và mỗi lần huỷ · hoàn · ghi nợ · thu nợ đọc ra được **người đang trực lúc đó**, không phải chức vụ của người ấy. **Không xảy ra được:** quyền của một thao tác được quyết bởi **chức vụ ghi cố định trên hồ sơ một người** — chức vụ không mở thêm cửa nào | `shop-facts.md` §6.13 · [`architecture.md`](architecture.md) §4 |
| **Note *"đem về"* trên một suất của phiên bàn** | **YC-05** | **Ghi được:** dấu *đem về* nằm ở mức **một suất**, và bếp lẫn người bưng đọc ra được ngay **suất nào gói lại, suất nào ăn tại chỗ**. **Không xảy ra được:** dấu ấy làm suất rời khỏi phiên bàn thành một đơn lẻ · hoặc nó chỉ tồn tại ở mức cả đơn, khiến một bàn không thể vừa có suất ăn tại chỗ vừa có suất đem về | `shop-facts.md` §6.15 · `I-006` |
| **Đã phục vụ bao nhiêu cho từng bàn** | **YC-06** | **Ghi được:** với **từng thành phần** của **từng bàn** — đã gọi bao nhiêu, đã phục vụ bao nhiêu — và mọi con số tổng cộng ngang qua nhiều bàn **tách ngược về được** từng bàn, khớp cả hai chiều. **Không xảy ra được:** số đã phục vụ của một bàn **vượt** số bàn ấy đã gọi · một con số tổng không chia hết về các bàn của nó | `shop-facts.md` §5.4 · [`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4.3 · §3.4.4 · `I-019` · `I-020` |
| **Mẻ, và con số *"đã làm xong, còn ở bếp"*** *(chốt 2026-09-01, thêm vào §8 ở P1-07)* | **YC-07** | **Ghi được:** **một lần bấm** *"đã làm xong"* là **một mẻ**, và một mẻ đẩy nhiều việc của **nhiều bàn** cùng lúc — nên mỗi lần bấm ấy đọc ra được **phần của từng bàn**; con số *đã làm xong, còn ở bếp* đứng riêng, **không** gộp vào *đã phục vụ*; mỗi lần **lùi** một mẻ bấm nhầm để lại vết (lùi mẻ nào · mấy giờ · ai). **Không xảy ra được:** *còn thiếu* của người bưng và *còn phải làm* của bếp bị gộp làm một con số · một lần bấm mẻ không chia được về từng bàn · phần đã làm xong của một đơn bị huỷ biến mất mà không có lần cập nhật nào chuyển nó sang bàn khác **hoặc** ghi chú nó là *bánh làm sai* (khi không bàn nào chờ — ghi chú mang người ghi và lúc ghi, gỡ được kèm vết; *bổ sung 2026-10-01, T-127*) | `shop-facts.md` §5.4 · [`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4.2 · §3.4.5 · §3.4.8 · `I-019` · `I-020` |
| **Lượt bán nhập bù từ sổ giấy** *(chốt 2026-09-04, thêm vào §8 ở P1-07)* | **YC-08** | **Ghi được:** một lượt bán ghi trên giấy hôm mất điện, nhập vào máy hôm sau, mang **hai** mốc đọc riêng được — **ngày quán bán thật** (mốc tính tiền) và **lúc gõ vào máy** — cùng **người nhập bù**; và một ngày đọc ra được **còn bao nhiêu lượt trên giấy chưa nhập**. **Không xảy ra được:** một lượt nhập bù rơi vào doanh thu của **ngày gõ** · một ngày còn lượt chưa nhập được coi là **đã đối soát xong** | `shop-facts.md` §6.11 · `docs/decisions.md` **ADR-037** · **I-012** · **I-014** · [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 |
| **Mức liên hệ tối thiểu của đơn mang đi** *(thêm vào §8 ở T-110, 2026-09-28)* | **YC-22** | **Ghi được:** với mỗi đơn của ba kênh không gắn bàn — **số điện thoại**, **địa chỉ giao**, **giờ khách cần hàng**, và **cách trao hàng** (giao tận nơi hay tới lấy) đọc ra được từ chính đơn ấy, cùng các trường *nên có* khi khách khai. **Không xảy ra được:** một đơn tồn tại mà thiếu một trường mà kênh và cách trao hàng của nó đòi · một đơn hotline không có cách trao hàng · một đơn Delivery mang nhánh *tới lấy* hoặc Pickup mang nhánh *giao* · một trường *nên có* trở thành điều kiện tạo đơn | `shop-facts.md` §6.5 · [`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.2.1 bước 2 · 3 · §3.2.2 · §3.2.4 · **I-022** |
| **Khoản trả trước** *(thêm vào §8 ở T-112, 2026-09-28)* | **YC-23** | **Ghi được:** mỗi khoản trả trước đọc lại được **sau nhiều ngày** — cho **đơn nào** · **bao nhiêu** · từng phần theo **phương thức** · **lúc quán nhận tiền** · **ai bấm** *đã nhận tiền* — với lúc nhận tiền **tách khỏi** mốc tính tiền của đơn (ngày giao/lấy); và với mỗi ngày, đọc ra được **ba danh sách từng khoản**: trả trước **nhận** trong ngày · trả trước **thành doanh thu** trong ngày (phần đã dùng cho hoá đơn đóng hôm ấy) · trả trước **trả lại** trong ngày, mỗi lần trả lại ghi phương thức trả lại. **Không xảy ra được:** một khoản trả trước vào doanh thu của **ngày nhận tiền** khi đơn đóng ngày khác · phần đã thành doanh thu cộng phần đã trả lại **vượt** số đã nhận · một lần trả lại khoản **chưa** thành doanh thu làm giảm doanh thu của một ngày nào | `shop-facts.md` §6.3 · §6.4 · §6.10 · §6.26 · `docs/decisions.md` **ADR-040** · **ADR-059** · **I-014** · **I-015** · **I-021** |
| **Mã QR của bàn — lịch sử mã, và mã lượt gọi đã mang** *(thêm vào §8 ở T-113, 2026-09-28)* | **YC-24** | **Ghi được:** với mỗi bàn — mã **hiện hành** của nó và **mọi mã đã bị thay**, mỗi mã đọc ra được nó hiện hành **từ lúc nào tới lúc nào**; với mỗi lần đổi — **bàn nào · lúc nào · ai đổi**; với mỗi lượt gọi QR tại bàn — nó đã mang **mã nào**. **Không xảy ra được:** một bàn có hơn một mã hiện hành cùng lúc · một mã, kể cả mã đã thay, chỉ tới hơn một bàn · một lượt gọi QR tại bàn không đọc ra được mã đã mang · một lần đổi mã làm đổi số bàn, hay chạm phiên bàn đang mở của bàn ấy | `shop-facts.md` §2 · §6 quy tắc 2 · [`02-kenh-ban.md`](../0-ba/ban-hang/02-kenh-ban.md) · **I-023** · **I-018** · **I-001** · `docs/decisions.md` **ADR-060** |
| **Dấu lần gửi** *(thêm vào §8 ở T-115, 2026-09-28)* | **YC-25** | **Ghi được:** với mỗi đơn của cả năm kênh — kể cả mỗi lượt gọi vào phiên bàn — **dấu lần gửi** đã sinh ra nó, đọc lại được **sau nhiều ngày**; và từ một dấu, đọc ra được nó đã sinh ra **đơn nào**. **Không xảy ra được:** hai đơn hay hai lượt gọi mang chung một dấu, ở bất kỳ thời điểm nào, không có hạn thời gian · một đơn hay một lượt gọi không mang dấu nào · hai lần gửi có dấu khác nhau bị ghi thành một đơn vì nội dung giống nhau | `shop-facts.md` §2 · §5.1 · §6 quy tắc 2 · **I-024** · **I-007** · **I-002** · **I-018** · `docs/decisions.md` **ADR-061** |
| **Khoảng ngừng nhận đơn — tạm dừng, và quán đang mù** *(thêm vào §8 ở T-132, 2026-10-01)* | **YC-34** | **Ghi được:** mỗi lần **tạm dừng nhận đơn** đọc lại được **sau nhiều ngày** — bắt đầu lúc nào · **ai bật** · kết thúc lúc nào · **ai tắt**; mỗi lần ba kênh khách tự bấm ngừng vì **quán không nhìn thấy đơn mới** đọc lại được — bắt đầu lúc nào, tính từ **lúc quán hết nhìn thấy**, không từ lúc có người bấm tắt · do máy phát hiện hay do người bấm · kết thúc lúc nào · **ai bấm mở lại**; và với một thời điểm bất kỳ trong quá khứ, đọc ra được lúc ấy quán có đang tạm dừng không, có đang mù không. **Không xảy ra được:** hai lần tạm dừng chồng lên nhau, hay hai khoảng mù chồng lên nhau — một thời điểm có hai câu trả lời · một khoảng kết thúc trước lúc bắt đầu · một lần tạm dừng không có người bật, hay kết thúc mà không có người tắt · một khoảng mù kết thúc mà không có người bấm mở lại — mở lại là một **nút**, không tự mở khi tín hiệu về · một khoảng đã ghi bị xoá, hay bị dời lúc bắt đầu | `shop-facts.md` §6.8 · §6.11 · **I-008** · `docs/decisions.md` **ADR-047** · **ADR-078** · [`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md) §3 luật 4 |

**Dòng cuối — `YC-34` — là chỗ thiếu thứ mười ba, thêm vào §8 ở T-132 (2026-10-01).** Bước P1-08 viết
luật *mỗi lần quán đang mù phải đọc lại được sau nhiều ngày* ([`05-realtime-va-du-phong.md`](05-realtime-va-du-phong.md)
§3 luật 4) và cố ý không thêm dòng vào file này, giao nó cho *"P1-07 hoặc pha 2"*; không bước nào nhận
(`work/findings.md` **F-050**). Chủ repo chọn hướng *thêm cặp dòng ở pha 1, dựng chỗ cất ở pha 2*
(2026-10-01). Mã nhảy từ `YC-25` sang `YC-34` vì `YC-26`…`YC-33` đã thuộc §9. Khoảng **tạm dừng** đi
cùng dòng vì nó thiếu đúng cùng một thứ và hai tập đối chiếu của `I-008` đọc cả hai. Vế *ai bật, ai
tắt* là đọc từ luật nguồn — nút tạm dừng là **nút của người** (`shop-facts.md` §6.8), mở lại là **nút**
(§6.11, `U-043`); vế *tính từ lúc quán hết nhìn thấy* là lời `U-061` (2026-09-27). Ai **được** bấm là
quyền theo vai, không thuộc dòng này.

**Dòng trước nó — `YC-25` — là chỗ thiếu thứ mười hai, thêm vào §8 ở T-115 (2026-09-28).** Nền 16
bảng không có gì phân biệt một lần gửi lại với một lần gửi mới, nên *một lần gửi, nhiều nhất một
đơn* của `I-024` không có gì để đứng (`work/findings.md` **F-043**). Dòng này cố ý **không** đòi so
nội dung: đơn giống hệt nhau mang hai dấu là hai đơn thật.

**Dòng trước nữa — `YC-24` — là chỗ thiếu thứ mười một, thêm vào §8 ở T-113 (2026-09-28).** Nền 16
bảng đã có một mã ngẫu nhiên cho mỗi bàn, nhưng không có đường đổi, không giữ mã đã thay, và lượt
gọi không ghi mã đã mang — nên *đổi được, mã cũ chết ngay* của `I-023` không có gì để đứng
(`work/findings.md` **F-042**). *Ai được đổi mã, khi nào* không thuộc dòng này: đó là **U-062** — đóng 2026-09-28, chủ quán đổi
khi quán bị hack (`master_plan/shop-facts.md` §6 quy tắc 2).

**Dòng trước nữa — `YC-23` — là chỗ thiếu thứ mười, thêm vào §8 ở T-112 (2026-09-28).** Lời chốt
2026-09-06 (**ADR-040**) đã nói bảng đối soát cần một dòng cho khoản này nhưng giao nó cho *"bước
sau"*, và không bước nào nhận (`work/findings.md` **F-037**). Vế *trả lại không trừ doanh thu* là
**suy ra**, không phải lời chủ quán — lý do ở **ADR-059** điểm 5.

**Trước nữa — `YC-22` — là chỗ thiếu thứ chín, thêm vào §8 ở T-110 (2026-09-28).** Mã nhảy qua
`YC-21` vì mã ấy đã thuộc §8 của file này (**ADR-057**); luật nguồn đã chốt từ 2026-08-30 nhưng
chưa từng thành mệnh đề cho tới `I-022` (`work/findings.md` **F-038**).

**Hai dòng trước nó là chỗ thiếu thứ bảy và thứ tám, thêm vào §8 ở P1-07.** §8 tự khai
danh sách của nó là *"chỗ thiếu đã biết tính tới 2026-08-31"* và dặn *"gặp chỗ thứ bảy thì thêm vào
đây, đừng tự thiết kế quanh nó"*. Cả hai chỗ mới đều là **lời chốt của chủ quán sau ngày ấy** — mẻ
và con số thứ tư (2026-09-01), chỗ đã làm xong của đơn huỷ đổi chủ (2026-09-06), lượt bán trên giấy
mang ngày bán (2026-09-04) — nên §8 không thể có chúng lúc viết, và không ai quay lại thêm dòng cho
tới bước này.

---

## 2. Nợ — §12.3 đã vẽ hình dạng; đây là cái §12.3 KHÔNG nói

[`architecture.md`](architecture.md) §12.3 là mục duy nhất trong repo đã đi tới mức *cất cái gì* và
*ràng buộc nào phải do cơ sở dữ liệu giữ*, và nó tự khai lý do: chủ repo yêu cầu thẳng một mục DB
cho phần nợ, nên nó **cố ý vượt ranh giới §8 đặt ra**, và nó là **đề xuất gửi sang pha 2**. Mục này
**không chép nó về** — chép là dựng bản thứ hai của một thứ đã đứng được (**F-001**).

Ba câu yêu cầu §12.3 không nói, vì chúng không phải câu về hình dạng:

- **YC-09 — Nợ có vòng đời riêng, dài hơn vòng đời của phiên bàn.** Phải ghi lại được: một khoản nợ
  **sinh ra lúc đóng phiên**, sống qua **nhiều ngày**, và kết thúc lúc người ta trả. Phải không xảy
  ra được: khoản nợ chỉ đọc được **trong lúc phiên còn mở** — đó chính là hình dạng *"hai ô trên
  phiên bàn"* mà §12 bác bỏ, và nó làm chết khoản nợ ngay tại chỗ nó sinh ra.
- **YC-10 — Hai mốc của một khoản nợ phục vụ hai câu hỏi khác nhau, nên không mốc nào bỏ được.**
  Phải ghi lại được: báo cáo doanh thu đọc mốc **ghi nợ**, đối soát tiền mặt đọc mốc **thu nợ**.
  Phải không xảy ra được: một lần **trả nợ** được ghi thành một khoản **bán mới** — đó là tính
  doanh thu hai lần cho cùng một bữa ăn (`shop-facts.md` §6.14).
- **YC-11 — Ghi nợ là chỗ DUY NHẤT phiên bàn hỏi danh tính.** Phải ghi lại được: một tên hoặc một
  cách gọi lại được, **chỉ** ở ca này. Phải không xảy ra được: chỗ hỏi danh tính ấy trở thành một
  thứ hiện ra ở **mọi** phiên bàn — phiên bàn ẩn danh theo số bàn là luật đang có, và ghi nợ là
  ngoại lệ chủ quán đã chấp nhận trả giá, không phải cửa mở cho một thay đổi rộng hơn.

---

## 3. Vết — HAI mệnh đề, không phải một; đừng gộp

§8 xếp chúng chung một dòng (*"vết thao tác chạm tiền / chạm trạng thái đơn"*), nhưng
`quality/invariants.md` tách chúng làm hai và nói thẳng **đừng gộp**. Hai tập không trùng nhau:
xác nhận đã nhận tiền thuộc `I-012` mà không thuộc `I-018`; đóng phiên nhầm rồi cập nhật thuộc
`I-018` mà tiền có thể không đổi. Một lần hoàn tiền thuộc **cả hai**.

- **YC-12 — Vết của một thao tác chạm tiền (`I-012`).** Phải ghi lại được, cho **mọi** thao tác
  trong danh sách `I-012` giữ: **cái gì đổi · bao nhiêu · ai bấm · lúc mấy giờ**. Phải không xảy ra
  được: một đường nào đó đổi số tiền của quán mà **không đi qua** cửa đã chốt — máy POS ở quầy,
  trừ đúng hai ca `I-012` đã gọi tên.
- **YC-13 — Vết của một lần CẬP NHẬT (`I-018`).** Phải **dựng lại được** bản ghi ở **cả hai phía**
  của lần sửa, cộng **lý do** và **người sửa**. Phải không xảy ra được: một lần sửa chỉ để lại dấu
  *"đã sửa"* · một lần **ghi đè** khi hai người cùng thao tác trên một bàn mà bản của người bấm
  trước không dựng lại được — đó là **thu thiếu tiền**, lỗi tiền nguy hiểm nhất của luồng tại bàn.
- **YC-14 — Không có nút hoàn tác, và hình dạng dữ liệu phải chịu được điều đó.** Ngoài đúng một ca
  — lùi một mẻ *"đã làm xong"* — cách sửa cái sai là **cập nhật**. Phải không xảy ra được: một
  đường quay ngược trạng thái về chỗ cũ mà không để lại cả hai phía. `I-018` là thứ **thay thế**
  cho hoàn tác, nên nó không phải một tiện ích thêm vào.

**Một câu về mức đủ, không phải về cơ chế:** *"đọc lại được sau nhiều ngày"* nghĩa là vết sống độc
lập với bản ghi nó nói về. Xoá một đơn mà vết của nó biến mất theo là chưa đạt `YC-12`; số tiền có
thể đọc lại được nhưng chỗ lệch thì không.

---

## 4. Ai đang trực trạm nào — ba việc `architecture.md` §4 đòi

**Phạm vi đã chốt, 2026-09-25:** yêu cầu lịch sử đổi người của YC-04/YC-15
áp dụng cho trạm `quay`, do POS khai. Bốn trạm ngoài quầy không ghi mốc đổi giờ
(chủ quán, `shop-facts.md` §8.8, U-055/U-056). Tổng quan lấy số người thực tế
đang làm ở quán (chủ quán xác nhận 2026-09-27, §8.6), do POS khai và cập nhật
(chủ quán chốt 2026-09-28, đóng U-060, `docs/product/99-unknowns.md`). Không dùng câu “trạm nào” dưới đây để
áp đặt thêm mốc đổi ở bếp.

§4 nói rõ vì sao **chức vụ ghi cố định** không đủ: chức vụ trả lời *người này là ai*, còn luật hỏi
*người này đang đứng đâu, lúc này* — và câu thứ hai đổi nhiều lần trong một buổi sáng.

- **YC-15 — Trực trạm là một thứ đọc được theo THỜI ĐIỂM.** Phải ghi lại được: tại một thời điểm
  bất kỳ trong quá khứ, ai đang trực trạm nào. Phải không xảy ra được: chỉ đọc được **hiện tại**,
  khiến một lần huỷ hôm qua không truy về được người thật.
- **YC-16 — Chủ quán vào đứng quầy thì hai vai CỘNG vào nhau.** Phải ghi lại được: cùng lúc, một
  người vừa có quyền của trạm quầy vừa giữ quyền quản trị. Phải không xảy ra được: vai này **thay**
  vai kia.
- **YC-17 — Năm trạm, bốn vai người.** Phải ghi lại được: hai trạm *canh* và *dọn bàn* do **chung
  một người** đứng. Phải không xảy ra được: hệ thống đòi **năm** người mới chạy được một buổi bán
  (`shop-facts.md` §3).

---

## 5. Mốc tính tiền — ba câu `02-thoi-gian-ngay-ban.md` giao sang

[`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §5 gọi tên bước này và giao lại đúng ba câu.
Chúng là **yêu cầu**, và pha 2 chọn hình dạng:

- **YC-18 — Mỗi việc chạm tiền mang ĐÚNG MỘT mốc quyết định ngày của nó.** Phải không xảy ra được:
  một việc chạm tiền mà bảng §2 của file ấy không chỉ ra được mốc nào là mốc tính tiền của nó.
- **YC-19 — Một lần thu chia nhiều phương thức thì mọi phần dùng CHUNG một mốc.** Phải không xảy ra
  được: hai phần của cùng một lần thu rơi vào **hai** ngày (`I-015`).
- **YC-20 — Mốc đã ghi thì không dời.** Phải không xảy ra được: một lần sửa bản ghi kéo theo mốc
  tính tiền đổi **âm thầm** — nếu mốc phải đổi, lần đổi ấy là một lần cập nhật đủ `YC-13`.

---

## 6. Chỗ chưa chắc — đánh dấu, không suy hộ

Ba chỗ dưới đây **chưa có lời chủ quán**. Pha 2 được phép dựng lược đồ chạy qua chúng, nhưng
**không** được đọc chúng thành luật đã chốt, và **không** được dựng bảng ở quầy như thể chúng đã
có lời (`CLAUDE.md` §3.5, §7.2).

| Chỗ chưa chắc | Nó chạm dòng nào | Hôm nay phải làm gì |
|---|---|---|
| **`S-5`** — bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`master_plan/shop-facts.md` §7.2) | `YC-06` · `YC-07` | Chủ quán mới nói **ai** bấm, chưa nói **theo gì**. Chỗ *suy ra* là theo **bàn** — một mẻ phục vụ nhiều bàn, còn bưng thì bưng tới **một** bàn. Đơn vị **đếm** là **bàn**, đơn vị **bấm** của mốc *đã làm xong* là **mẻ** (đã chốt 2026-09-01); đơn vị **bấm** của mốc *đã bưng ra bàn* thì **để trống**, đừng điền |
| **`S-6`** — với đơn **giao tận nơi**, quầy bấm mốc *"đã ra bàn"* **lúc nào** (§7.2) | `YC-06` | **Ai** bấm đã chốt 2026-09-04 (*"pos"*, không có ngoại lệ). Vế **lúc nào** là chỗ *suy ra*: lúc đơn rời quán. Sai thì mốc ấy nghĩa là **tới tay khách**, và quầy phải chờ người đi giao báo về |
| **Chỗ đã làm xong của một đơn huỷ khi KHÔNG có bàn nào đang chờ đúng thứ ấy** | `YC-07` | Chủ quán chốt 2026-09-06 cho ca **có** bàn chờ: tính cho bàn khác, người đứng quầy chọn bàn nhận trên POS rồi cập nhật. Ca **không có bàn nào chờ**: chủ quán chốt 2026-09-30, trả lời U-064 — người đứng quầy **ghi chú trên POS rằng đó là bánh làm sai** (`shop-facts.md` §5.4). Dòng `YC-07` có vế ấy từ 2026-10-01 (T-127). Còn trống: cái bánh làm sai quán bỏ hay giữ — lời không nói, đừng điền |

**Ba chỗ này không được lấp bằng một mặc định.** Một lược đồ chọn sẵn *"bấm theo bàn"* rồi chạy
tiếp là một lược đồ đã thay chủ quán trả lời một câu chưa ai hỏi — và cái sai ấy chỉ lộ ra lúc quán
dùng thật.

---

## 7. Cái mục này cố ý không nói · pha 2 đọc nó thế nào

**Cố ý không nói:**

- **Bao nhiêu bảng, tên gì, tách hay gộp.** Kể cả `YC-02`, nơi §12.3 đã vẽ sẵn một hình: hình ấy là
  **đề xuất**, và pha 2 được quyền đổi **miễn giữ đủ** mọi thứ §12.3 liệt kê là phải cất.
- **Tầng nào giữ từng mệnh đề.** Đó là [`03-bao-ve-invariant.md`](03-bao-ve-invariant.md). Một dòng
  ở đây nói *"phải không xảy ra được"* **không** đồng nghĩa với *"cơ sở dữ liệu phải chặn"*.
- **Ba tổ hợp nồi.** Năng lực một mẻ là kiến thức của **người đứng bếp**, không phải tham số của
  thuật toán — *"máy không làm, để người làm"* ([`architecture.md`](architecture.md) §2). Không
  dòng nào ở đây đòi cất một mô hình năng lực nồi, và đừng suy ra một cái.
- **Màn hình.** Cái gì hiện ở đâu là pha 4.

**Pha 2 dùng mục này thế nào:** dựng lược đồ xong thì đi ngược bảng §1 và các dòng `YC-XX` còn lại,
với YC-01…YC-20, YC-22…YC-25 và YC-34, mỗi dòng hỏi **hai** câu — *đọc ra được không* và *dựng được trạng thái sai không*. Dòng nào không
trả lời được là một chỗ lược đồ còn thiếu, **không phải** một dòng viết chưa rõ; sửa lược đồ, và
chỉ quay lại sửa dòng ở đây khi chính luật nghiệp vụ đã đổi ở owner của nó.
YC-26…YC-33 ở §9 là của mảng admin, do các bước `P2A-XX` chấm.
**Đã chấm — 2026-09-30, `P2-13`** (pointer thêm ở `P2-14`): bảng chấm hai câu nằm ở
[`../2-db/11-cong-chat-luong-pha-2.md`](../2-db/11-cong-chat-luong-pha-2.md) §5, và những kết cục
chỉ ra chỗ lược đồ còn thiếu ở §6 của file ấy.

**Gặp chỗ thiếu tiếp theo thì thêm vào [`architecture.md`](architecture.md) §8 trước, rồi thêm một
dòng ở §1 đây trong cùng thay đổi** — hai danh sách ấy phải khớp một-đối-một, và đó là phép chấm
duy nhất giữ chúng khỏi trôi khỏi nhau.

## 8. Bảo toàn và khôi phục dữ liệu — YC-21, giao pha vận hành

**Chủ repo chốt 2026-09-27, ADR-057 (T-108):** chọn hướng thứ ba của F-034.
Mục này sở hữu yêu cầu; **pha 5 — Deploy/vận hành** sở hữu cơ chế thực hiện.

**YC-21 — Phải khôi phục lại được bản ghi của một ngày đã bán khi dữ liệu đang dùng bị mất.**
Kết quả khôi phục phải đọc lại được dữ liệu và các mối liên hệ cần cho đối soát ngày bán,
truy vết thao tác theo các yêu cầu ở trên. Dựng lại một cơ sở dữ liệu rỗng hoặc nhập dữ liệu mồi
không đáp ứng yêu cầu này. Sổ giấy dùng khi mất kết nối không thay thế việc khôi phục lịch sử.

**Giao thực hiện:** pha 5 phải thiết kế và triển khai sao lưu, phục hồi, theo dõi thất bại;
chỉ định người phụ trách và nơi giữ bằng chứng. Công cụ, nơi lưu, lịch sao lưu và quy trình
cụ thể do pha ấy thiết kế, không chốt ở pha 1. Việc tiếp nhận theo dõi tại **T-109** trong
`work/backlog.md`; khi mở owner vận hành, cập nhật bảng owner trong `CLAUDE.md` cùng lượt.

**Nghiệm thu ở pha vận hành:** phục hồi từ bản sao lưu vào môi trường riêng, đọc và đối chiếu
lại dữ liệu ngày bán cùng vết liên quan; lưu kết quả, mốc dữ liệu phục hồi được và thời gian
thực hiện. Có bản sao lưu nhưng chưa phục hồi thử chưa phải bằng chứng đạt YC-21.

**Tiêu chí nghiệm thu — chủ repo chốt 2026-09-28 (T-109):** chủ repo chọn trong các phương án
phiên Claude Code đưa ra, nguyên văn lựa chọn:
- **Mức mất dữ liệu tối đa:** *"Tối đa 1 giờ bán"* — bản phục hồi được không cũ hơn một giờ so
  với lúc mất.
- **Thời gian phục hồi tối đa:** *"Trước ca bán kế tiếp"* — trong lúc chờ, quán bán bằng đường
  suy giảm đã có.
- **Giữ bản sao lưu:** *"1 năm"*.

*Phiên suy ra, chưa có lời chủ repo:* "ca bán kế tiếp" đọc là **trước giờ mở bán kế tiếp** theo
giờ bán ở `master_plan/shop-facts.md` §1; phần bán trong khoảng mất (tối đa một giờ) và trong lúc
phục hồi được bù từ sổ giấy. Số bản sao, nơi cất ngoài máy chạy, lịch sao lưu và công cụ vẫn do
pha 5 thiết kế theo ba tiêu chí trên. Phép nghiệm thu đo đúng ba tiêu chí ấy: mốc dữ liệu phục
hồi được so với lúc mất, thời gian thực hiện so với giờ mở bán kế tiếp.
T-109 phải hoàn tất trước khi đưa hệ thống vào bán thật. Pha 2 chỉ bảo đảm dữ liệu có thể biểu
đạt đủ; phép chạy xuôi/lùi migration của P2-09 không chứng minh YC-21 đã đạt.

## 9. Mảng QUẢN TRỊ (admin) — mục riêng có nhãn (P2A-01, 2026-09-30)

Đây là yêu cầu cho **phần admin đã đủ luật** theo cột giữa bảng §2 của
`master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`, đứng riêng theo `docs/decisions.md`
**ADR-013**. Bốn luật đọc của §0 áp dụng **trừ luật 4**: các dòng này không có dòng đối ứng ở
[`architecture.md`](architecture.md) §8; mảng admin ở §14 của file ấy. Hành vi nghiệp vụ đọc ở
[`01-ranh-gioi.md`](../0-ba/admin/01-ranh-gioi.md) §1.6; lời chủ quán chỉ **trỏ**, không chép
(`work/findings.md` **F-001**).

| Vế đã đủ luật | Mã | Câu yêu cầu | Luật nguồn |
|---|---|---|---|
| **Danh mục hàng mua vào, thêm dần, một phần đã có đơn vị mua** | **YC-26** | **Ghi được:** mỗi thứ có tên, có đơn vị mua **khi chủ quán đã nói**, và thêm được một thứ mới bất kỳ lúc nào. **Không xảy ra được:** một thứ bị buộc phải có đơn vị mới tồn tại được — đơn vị chưa có lời thì **trống**, không tự gán —, một thứ đứng hai lần trong danh mục, hay danh mục mang ngưỡng nhắc sắp hết hoặc định lượng một suất. | `shop-facts.md` §8.4 · `I-025` · `I-026` |
| **Mỗi ngày, mỗi thứ, hai con số mua vào và đã dùng, người nhập tay** | **YC-27** | **Ghi được:** với mỗi thứ và mỗi ngày, con số **mua vào** và con số **đã dùng** được giữ đúng như người gõ và đọc lại được sau nhiều ngày. **Không xảy ra được:** một con số sinh ra hay đổi vì một thao tác bán hàng, một thứ trong một ngày đọc ra hai đáp số cho cùng một con số, nhóm chỉ số công tơ điện và nước nhận cặp số này, hay một lần sửa con số không để lại bản trước. | `shop-facts.md` §8.4 · [`01-ranh-gioi.md`](../0-ba/admin/01-ranh-gioi.md) §1.6 · `I-025` · `I-026` · `I-018` |
| **Thời gian nhập, và ai nhập** | **YC-28** | **Ghi được:** với mỗi con số, đọc ra được **ai** nhập, nó thuộc **ngày nào**, và **lúc** nó được gõ vào máy; hai mốc đọc riêng được, cùng hình hai mốc của `YC-08`. **Không xảy ra được:** một con số không có người nhập, hoặc hai mốc bị gộp làm một khiến *thời gian nhập* chỉ đọc được theo một nghĩa. | `shop-facts.md` §8.4 (lời `U-051`) · `I-025` |
| **Tổng cộng dồn và hiệu số máy trừ hộ** | **YC-29** | **Ghi được:** với mỗi thứ, tổng đã nhập, tổng đã dùng và hiệu số **đọc ra được bằng một phép cộng** từ các con số ngày, cộng dồn từ ngày mua rồi lấy hai tổng trừ nhau. **Không xảy ra được:** một con số tổng đứng riêng ghi được mà không qua con số ngày, tổng đặt lại mỗi lần mua thêm hay tách theo lô, máy cất một kết luận *thiếu* hay *sắp hết* hoặc một lời nhắc, hay một hiệu số âm bị từ chối. | `shop-facts.md` §8.4 (lời `U-051` · `U-054` · `U-045`) · `I-026` |
| **Chủ quán tick ô *có đi làm* cho từng người, từng ngày** | **YC-30** | **Ghi được:** mỗi ô *có đi làm* đọc lại được sau nhiều ngày *người này, ngày này, có đi làm*, cùng **ai** đã tick và **lúc** tick; người được chấm và người tick đều là người của tập người đã có (`YC-15`), không phải danh sách thứ hai. Một ô tick nhầm **huỷ được**, và ô đã huỷ đọc lại được *ai huỷ, lúc huỷ, ghi chú*. **Không xảy ra được:** một ô không gắn người nào, không có ngày hoặc không có người tick; hai ô còn hiệu lực cho cùng một người trong cùng một ngày; một ô tách theo buổi hay mang mốc lúc tới, lúc về; một ô bị xoá mất, hay một lần huỷ không có người huỷ; hay một ô sinh ra một khoản trừ tiền. *Viết lại 2026-09-30 (`P2A-03`) theo lời đóng `U-069` · `U-070`; bản trước viết theo `C31`.* | `shop-facts.md` §8.7 (lời `U-065` · `U-069` · `U-070`; `C32`) · `I-027` |
| **Tạm ứng do chủ quán duyệt** | **YC-31** | **Ghi được:** mỗi khoản tạm ứng đọc lại được sau nhiều ngày — của ai, bao nhiêu, lúc nào, ai duyệt và ai ghi — và đọc ra được nó là tiền rời két, giữ **cả** ngày khai **lẫn** lúc ghi để hạng tử *chi từ két* của `I-021` gắn nó vào một ngày bán. **Không xảy ra được:** một khoản tạm ứng không có người duyệt, một khoản bị sửa đè, một khoản tạm ứng nằm trong doanh thu hoặc tiền đã thu của một ngày, hay một con số tổng tiền rời két đứng riêng thay cho phép cộng các khoản. *Thêm vế két 2026-10-01 (T-125, **ADR-074**); luật chọn ngày bán chờ `U-072`.* | `shop-facts.md` §8.7 (`C29`) · `I-028` · `I-018` |
| **Thưởng lễ Tết** | **YC-32** | **Ghi được:** mỗi khoản thưởng lễ Tết đọc ra được của ai, bao nhiêu, lúc nào và ai ghi, và là tiền rời két — cùng hai mốc như `YC-31`. **Không xảy ra được:** một khoản thưởng thiếu người nhận hay số tiền, một khoản bị sửa đè, hay một chỗ cất sẵn cho thưởng ngày đông khách vì vế ấy của `C28` chưa có lời. *Thêm vế két 2026-10-01 (T-125, **ADR-074**).* | `shop-facts.md` §8.7 (`C28`) · `I-028` · `I-018` |
| **Khoản chi ngoài tiền hàng và lương, theo loại** | **YC-33** | **Ghi được:** mỗi khoản chi đọc ra được loại, số tiền, ngày, lúc ghi và ai ghi; mỗi **loại** đọc ra được **nguồn tiền** của nó — két bán hàng hay không; danh sách loại thêm được, và tổng chi một khoảng ngày **đọc ra được bằng một phép cộng**. **Không xảy ra được:** một khoản chi không mang loại nào, một loại không mang nguồn tiền, tiền hàng hay lương được ghi thành một khoản chi, hoặc một con số tổng chi đứng riêng. *Thêm vế nguồn 2026-10-01 (T-125, **ADR-074**); luật chọn ngày bán cho khoản nguồn két chờ `U-072`.* | `shop-facts.md` §8.10 (`E44` · `E45` và *Giới hạn lời đáp*) · `I-029` |

Vế *trực quầy theo thời điểm* của kế hoạch §2 **không có dòng mới** vì nó đã là `YC-04` ·
`YC-15` (§4 của file này) và đã dựng ở `P2-08`.

### 9.1 Chỗ chưa chắc của mục này — đánh dấu, không suy hộ

| Chỗ chưa chắc | Nó chạm dòng nào | Hôm nay phải làm gì |
|---|---|---|
| **[U-071](../99-unknowns.md)** — huỷ một ô chấm công: ghi chú có bắt buộc không, và ai được bấm huỷ; mở 2026-09-30 ở `P2A-03`. Hai câu trước của dòng này đã đóng cùng ngày: `U-069` (chủ quán tick hết, mỗi người mỗi ngày một ô) và `U-070` (nút huỷ, có phần ghi chú) | `YC-30` | `YC-30` đòi lần huỷ có **người huỷ**, **không** đòi ghi chú và **không** đòi người huỷ là chủ quán. Có lời thì siết thêm, không suy hộ. |
| **Ngày bán mà một khoản rời két trừ vào** — [U-072](../99-unknowns.md), mở 2026-10-01 ở `T-125`. Nguồn tiền đã có lời: `U-066` · `U-067` đóng 2026-09-30 (*từ két bán hàng*), rời két *trong ngày, trước lúc đếm két* (2026-10-01) | `YC-31` · `YC-32` · `YC-33` | Ba dòng đòi giữ **cả** ngày khai lẫn lúc ghi, **không** đòi một cột *ngày bán của két*. Có lời thì phép đọc chọn một trong hai, không cần đổi lược đồ. |
| **Chữ *thời gian nhập*** — `U-068` đã đóng 2026-09-30: **lúc hàng mua về**, không phải lúc gõ số vào máy | `YC-28` | `YC-28` vẫn đòi ghi **cả hai** mốc; mốc bày cho chủ quán là mốc thứ nhất. Mốc ấy là **ngày** của con số, không phải giờ: lời đáp không nói có cần giờ hay không, nên `YC-28` **không** thêm vế nào; màn nào bày gì là pha 4. |
| **B12** của `work/admin-questions.md` §3 — đơn vị của các tên cũ và đơn vị ghi lượng đã dùng | `YC-26` · `YC-29` | Đơn vị chưa có lời thì để trống; máy cộng trừ đúng con số người gõ, không quy đổi. |
| **C32** · **C30** của `work/admin-questions.md` §3 — muộn bao nhiêu phút thì ghi nhận là muộn; nghỉ có báo trước có bị trừ không | `YC-30` | `YC-30` chỉ đòi *chấm muộn không sinh khoản trừ*. Ngưỡng và ngày nghỉ chưa có lời: không dòng nào đòi, và không cất sẵn chỗ cho chúng. |

[↑ đầu file](#top)
