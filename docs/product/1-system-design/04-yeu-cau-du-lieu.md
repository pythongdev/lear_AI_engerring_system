<a id="top"></a>
# Yêu cầu hình dạng dữ liệu — cái gì phải ghi lại được, cái gì phải không xảy ra được

*Bước 7/14 của pha 1 — **P1-07**, 2026-09-07
(`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · `docs/decisions.md` **ADR-033**).
Đầu vào: [`architecture.md`](architecture.md) §8 · §4 · §12.3 · `quality/invariants.md` `I-012` ·
`I-018` · `master_plan/shop-facts.md` §5.4 · §6.4 · §6.11 · §6.14 · §6.15 ·
[`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4 (BA-12, xong 2026-09-04) ·
[`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §5.*

> **Mục này sở hữu đúng một thứ: câu YÊU CẦU mà pha 2 tự chấm lược đồ của mình.** Mỗi dòng ở đây
> là một câu pha 2 trả lời được bằng *có* hoặc *không* sau khi đã dựng xong lược đồ — không phải
> một lời khuyên, không phải một gợi ý hình dạng.
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

---

## 0. Cách đọc — hai dạng câu, và một mã

Mỗi yêu cầu mang một mã `YC-XX` và được viết bằng **đúng một trong hai dạng**, thường là cả hai:

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

## 1. Tám chỗ thiếu ở `architecture.md` §8 — mỗi chỗ đúng một dòng yêu cầu

§8 là danh sách **chỗ mô hình 16 bảng chưa với tới**. Bảng dưới đây là cùng danh sách ấy, đọc theo
chiều ngược lại: không phải *thiếu cái gì*, mà *pha 2 phải chấm được cái gì*.

| §8 nói thiếu | Mã | Câu yêu cầu | Luật nguồn |
|---|---|---|---|
| **Vết hoàn tiền** | **YC-01** | **Ghi được:** mỗi lần hoàn tiền đọc lại được đủ **năm** thứ — hoàn **bao nhiêu** · cho **lượt bán nào** · **ai bấm** · **lúc mấy giờ** · **lý do gì**. **Không xảy ra được:** một lần hoàn tiền thiếu bất kỳ thứ nào trong năm, **kể cả lý do** — quán cố ý không có luật cứng về hoàn tiền, nên lý do là thứ duy nhất thay được luật | `shop-facts.md` §6.4 · `quality/invariants.md` **I-012** |
| **Khoản nợ** | **YC-02** | **Ghi được:** một khoản nợ đứng được **sau khi phiên bàn của nó đã đóng** — ai nợ · bao nhiêu · thuộc đúng một phiên · lúc ghi · lúc thu · đã thu hay chưa. **Không xảy ra được:** đóng phiên thu thiếu mà không có chủ nợ và số tiền · một khoản nợ được cộng vào tiền đã thu của ngày ghi nợ · một phiên mang **hai** khoản nợ chưa thu cùng lúc · một số tiền nợ không dương. Hình dạng nhỏ nhất đủ dùng đã có ở [`architecture.md`](architecture.md) **§12.3** — đọc ở đó, §2 dưới đây chỉ nói **cái §12.3 không nói** | `shop-facts.md` §6.14 · `I-005` · `I-015` |
| **Vết thao tác chạm tiền / chạm trạng thái đơn** | **YC-03** | **Ghi được:** mỗi thao tác chạm tiền đọc lại được đủ **bốn** câu (cái gì · bao nhiêu · ai · mấy giờ), **và** mỗi lần sửa một bản ghi đã có dựng lại được **bản trước**, **bản sau**, **lý do**, **người sửa**. **Không xảy ra được:** một chỗ lệch trong bảng đối soát cuối ngày mà không quy được về **đúng một** thao tác có tên người. Hai vế trên là **hai** mệnh đề khác nhau — §3 dưới đây | `shop-facts.md` §6.10 · **I-012** · **I-018** |
| **Ai đang trực trạm nào, lúc này** | **YC-04** | **Ghi được:** ở **bất kỳ thời điểm nào trong quá khứ**, đọc ra được ai đang trực trạm nào; và mỗi lần huỷ · hoàn · ghi nợ · thu nợ đọc ra được **người đang trực lúc đó**, không phải chức vụ của người ấy. **Không xảy ra được:** quyền của một thao tác được quyết bởi **chức vụ ghi cố định trên hồ sơ một người** — chức vụ không mở thêm cửa nào | `shop-facts.md` §6.13 · [`architecture.md`](architecture.md) §4 |
| **Note *"đem về"* trên một suất của phiên bàn** | **YC-05** | **Ghi được:** dấu *đem về* nằm ở mức **một suất**, và bếp lẫn người bưng đọc ra được ngay **suất nào gói lại, suất nào ăn tại chỗ**. **Không xảy ra được:** dấu ấy làm suất rời khỏi phiên bàn thành một đơn lẻ · hoặc nó chỉ tồn tại ở mức cả đơn, khiến một bàn không thể vừa có suất ăn tại chỗ vừa có suất đem về | `shop-facts.md` §6.15 · `I-006` |
| **Đã phục vụ bao nhiêu cho từng bàn** | **YC-06** | **Ghi được:** với **từng thành phần** của **từng bàn** — đã gọi bao nhiêu, đã phục vụ bao nhiêu — và mọi con số tổng cộng ngang qua nhiều bàn **tách ngược về được** từng bàn, khớp cả hai chiều. **Không xảy ra được:** số đã phục vụ của một bàn **vượt** số bàn ấy đã gọi · một con số tổng không chia hết về các bàn của nó | `shop-facts.md` §5.4 · [`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4.3 · §3.4.4 · `I-019` · `I-020` |
| **Mẻ, và con số *"đã làm xong, còn ở bếp"*** *(chốt 2026-09-01, thêm vào §8 ở P1-07)* | **YC-07** | **Ghi được:** **một lần bấm** *"đã làm xong"* là **một mẻ**, và một mẻ đẩy nhiều việc của **nhiều bàn** cùng lúc — nên mỗi lần bấm ấy đọc ra được **phần của từng bàn**; con số *đã làm xong, còn ở bếp* đứng riêng, **không** gộp vào *đã phục vụ*; mỗi lần **lùi** một mẻ bấm nhầm để lại vết (lùi mẻ nào · mấy giờ · ai). **Không xảy ra được:** *còn thiếu* của người bưng và *còn phải làm* của bếp bị gộp làm một con số · một lần bấm mẻ không chia được về từng bàn · phần đã làm xong của một đơn bị huỷ biến mất mà không có lần cập nhật nào chuyển nó sang bàn khác | `shop-facts.md` §5.4 · [`03-lat-cat.md`](../0-ba/ban-hang/03-lat-cat.md) §3.4.2 · §3.4.5 · §3.4.8 · `I-019` · `I-020` |
| **Lượt bán nhập bù từ sổ giấy** *(chốt 2026-09-04, thêm vào §8 ở P1-07)* | **YC-08** | **Ghi được:** một lượt bán ghi trên giấy hôm mất điện, nhập vào máy hôm sau, mang **hai** mốc đọc riêng được — **ngày quán bán thật** (mốc tính tiền) và **lúc gõ vào máy** — cùng **người nhập bù**; và một ngày đọc ra được **còn bao nhiêu lượt trên giấy chưa nhập**. **Không xảy ra được:** một lượt nhập bù rơi vào doanh thu của **ngày gõ** · một ngày còn lượt chưa nhập được coi là **đã đối soát xong** | `shop-facts.md` §6.11 · `docs/decisions.md` **ADR-037** · **I-012** · **I-014** · [`02-thoi-gian-ngay-ban.md`](02-thoi-gian-ngay-ban.md) §2 |

**Hai dòng cuối là chỗ thiếu thứ bảy và thứ tám, thêm vào §8 trong chính lượt này.** §8 tự khai
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
| **Chỗ đã làm xong của một đơn huỷ khi KHÔNG có bàn nào đang chờ đúng thứ ấy** | `YC-07` | Chủ quán chốt 2026-09-06 cho ca **có** bàn chờ: tính cho bàn khác, người đứng quầy chọn bàn nhận trên POS rồi cập nhật. Ca **không có bàn nào chờ** thì chủ quán không nói tới — **chưa có luật, chưa hỏi** (`shop-facts.md` §5.4) |

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
mỗi dòng hỏi **hai** câu — *đọc ra được không* và *dựng được trạng thái sai không*. Dòng nào không
trả lời được là một chỗ lược đồ còn thiếu, **không phải** một dòng viết chưa rõ; sửa lược đồ, và
chỉ quay lại sửa dòng ở đây khi chính luật nghiệp vụ đã đổi ở owner của nó.

**Gặp chỗ thiếu thứ chín thì thêm vào [`architecture.md`](architecture.md) §8 trước, rồi thêm một
dòng ở §1 đây trong cùng thay đổi** — hai danh sách ấy phải khớp một-đối-một, và đó là phép chấm
duy nhất giữ chúng khỏi trôi khỏi nhau.

[↑ đầu file](#top)
