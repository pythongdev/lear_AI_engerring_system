<a id="top"></a>
# Backlog — mảng QUẢN TRỊ (admin)

Mô tả dài của **hai mươi chín** việc `ADM-01`…`ADM-53` — ba mảng *nguyên liệu · con người · tài
chính*. Dựng 2026-09-04 (T-052) theo yêu cầu chủ repo; quyết định vì sao nó là một file riêng:
`docs/decisions.md` **ADR-036**.

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Việc nào đang *Ready*, *In Progress* hay *Done*
> đọc ở `work/backlog.md` — đó là file `scripts/brief.sh` đọc và đẩy vào mọi phiên mới
> (`docs/decisions.md` ADR-002). Một dòng trạng thái viết ở đây là một dòng **không phiên nào
> thấy**.
>
> **Nó cũng không giữ CÂU HỎI.** Năm mươi lăm câu hỏi chủ quán ở `work/admin-questions.md` §3, và
> **chỗ chủ quán viết câu trả lời cũng ở đó**. File này chỉ trỏ tới mã câu (`A5`, `B21`, `C36`…),
> không chép lại câu hỏi.
>
> **Nó cũng không giữ DỮ KIỆN QUÁN, LUẬT NGHIỆP VỤ hay QUYẾT ĐỊNH.** Ba thứ ấy có owner ở
> `CLAUDE.md` §2 — `master_plan/shop-facts.md` §8, `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6,
> `docs/product/1-system-design/architecture.md` §14, `docs/decisions.md`. Chép về đây là tạo bản
> thứ hai, và bản thứ hai luôn trôi (`work/findings.md` **F-001**).

## Bốn file, bốn việc — đọc bảng này trước khi sửa bất kỳ file nào

| Câu hỏi | Đọc ở |
|---|---|
| **Vì sao** có việc này, hỏng thì mất gì, chạy thế nào | **file này** |
| Việc nào **đang** chạy, xong chưa | `work/backlog.md` → *Ready* · *In Progress* · *Done* |
| Câu hỏi cho chủ quán, và **chỗ chủ quán trả lời** | `work/admin-questions.md` §3 |
| Ranh giới · luật nghiệp vụ · dữ kiện quán · quyết định | owner ở `CLAUDE.md` §2 — không file nào ở trên |

## Luật của file này — sáu câu

1. **Mô tả cả hai mươi chín việc được viết trước; dòng trạng thái thì không.** Chỉ việc nào **nhận
   được ngay** mới có một dòng ở `work/backlog.md` → *Ready*. Lý do đo được: `brief.sh` cắt danh
   sách *Ready* ở sáu mục, nên hai mươi chín dòng đổ vào đó đẩy hai mươi ba dòng ra khỏi tầm nhìn
   của mọi phiên mới — đúng cơ chế đã làm `U-011` và `BA-12` vô hình (**F-012**).
2. **Entry TRỎ, prompt GIỮ.** *Acceptance* và *Verify* nằm trong file prompt viết lúc nhận việc,
   không nằm ở đây — cùng luật với `work/backlog.md` → *Task Detail Template*.
3. **Việc xong thì entry ở lại đây**, thêm một dòng *Xong ngày…* ở đầu entry; dòng `- [x]` đi vào
   `work/backlog.md` → *Done*. Không có mục *đã xong* riêng ở file này.
4. **Ranh giới giữa ba sổ là LANE, không phải độ dài** — pha 1 ở `work/backlog_SD.md`, mảng admin ở
   file này, phần còn lại ở `work/backlog.md` (**ADR-036**, sửa luật 3 của **ADR-034**).
5. **Entry ở đây viết tại tầng NGHIỆP VỤ.** Không một tên bảng · tên cột · endpoint · route ·
   component nào được viết trong file này (**ADR-035**: lược đồ là pha 2, hợp đồng API là pha 3,
   route là pha 4). Chữ *"màn"* trong tên vài việc — *màn tổng quan buổi bán*, *màn đối soát* — là
   tên gọi tắt của một **năng lực**, thừa kế nguyên văn từ `work/admin-questions.md` §2; nó
   **không** là một route và không ai được đọc nó thành một route.
6. **Ba hình dạng entry, và hình dạng do TIỀN ĐỀ quyết định, không do người viết chọn.** Việc
   nhận được ngay có mục *Cách hoàn thành — đủ mười bước*; việc còn chờ chủ quán có mục ***Chặn
   bởi — hỏi gì trước*** thay vào; việc đã đủ luật nhưng phần còn lại thuộc pha khác có mục
   ***Luật đã ở đâu, còn thiếu gì***. Lý do là bài học **T-051** (2026-09-04): một *Constraints*
   viết trước đầu ra là **câu chết** (**F-013** · **F-017**). Ở đây còn nặng hơn — viết mười bước
   cho một việc chưa có luật là tự quyết thay chủ quán, thứ `CLAUDE.md` §3.5 cấm và không có mức
   L0. Ba loại ấy đếm được ở bảng mục *Cổng của cả lane* ngay dưới.

## Cổng của cả lane — 54 câu chưa trả lời

**Hai mươi ba trong hai mươi chín việc ở đây không nhận được hôm nay**, và chỗ chặn hầu hết không
phải kỹ thuật: nó là câu hỏi chưa hỏi được chủ quán. Con số đo ngày **2026-09-04**, đếm lại ở
owner chứ đừng tin con số trong câu này (`work/findings.md` **F-003**).

| Nhánh | Câu hỏi ở `admin-questions.md` §3 | Việc bị chặn |
|---|---|---|
| **A** — một buổi bán | `A1`…`A10` (10 câu, **chưa câu nào**) | ADM-01 · ADM-02 · ADM-03 · ADM-04 |
| **B** — nguyên liệu | `B11`…`B22` (12 câu, `B18` trả lời **một nửa**) + **U-034** | ADM-10 · ADM-11 · ADM-12 · ADM-13 · ADM-14 · ADM-15 |
| **C** — con người | `C23`…`C36` (14 câu, **chưa câu nào**) | ADM-20 · ADM-21 · ADM-22 · ADM-23 · ADM-24 |
| **D** — sản phẩm | `D37`…`D43` (7 câu, **chưa câu nào**) | ADM-32 · ADM-33 (ADM-30 chỉ vướng vế quyền, ADM-31 không vướng) |
| **E** — tài chính | `E44`…`E51` (8 câu, **chưa câu nào**) | ADM-42 · ADM-43 · ADM-44 · ADM-45 |
| **F** — chung | `F52`…`F55` (4 câu, **chưa câu nào**) | ADM-51 · ADM-52 (ADM-50 chỉ vướng vế *ai*) |

**Không phải việc nào không bị chặn cũng là việc của lane này.** Đo ngày 2026-09-04, hai mươi chín
việc chia làm **ba loại**, và loại quyết định ai nhận nó:

| Loại | Nghĩa là gì | Gồm |
|---|---|---|
| **1 — thiếu LUẬT** | phải hỏi chủ quán trước, không phiên nào được suy hộ (`CLAUDE.md` §3.5) | **hai mươi ba** việc: cả nhánh A · B · C, ADM-32 · ADM-33 · ADM-42 · ADM-43 · ADM-44 · ADM-45 · ADM-51 |
| **2 — luật ĐÃ ĐỦ, thiếu THI CÔNG** | phần nghiệp vụ đã chốt sẵn ở mảng bán hàng; cái còn lại thuộc pha 2–4, **không** thuộc lane này | **năm** việc: ADM-30 · ADM-31 · ADM-40 · ADM-41 · ADM-50 (ADM-52 nằm một nửa ở đây) |
| **3 — việc của chính lane** | nhận được ngay, không chờ ai | **một** việc: **ADM-53** |

Loại 2 là chỗ dễ hiểu nhầm nhất của cả file. `work/admin-questions.md` §2 được viết ngày 2026-09-02
như một danh sách *"những gì chủ quán còn muốn"*, không phải như một ranh giới lane; nên năm việc
trong đó đã có đủ luật từ trước và chỉ còn chờ người viết mã. Entry của chúng ở dưới **không** có
mục *Cách hoàn thành*: nó có mục ***Luật đã ở đâu, còn thiếu gì***. Gộp chúng vào lane admin rồi
viết lại luật là tạo bản thứ hai của một sự thật đã có owner (**F-001**).

⚠️ **Một câu đáng hỏi trước mọi câu khác: `C36`** — *người đứng quầy đổi giữa buổi thì máy có ghi
lại mốc đổi ấy không*. Nó không chỉ mở khoá ADM-21: `docs/product/1-system-design/architecture.md`
§4 chốt **quyền gắn chỗ đứng, không gắn chức vụ**, và §8 đo rằng **không dữ liệu nào ghi ai đang
đứng đâu**. Chừng nào `C36` chưa có lời, mọi thiết kế quyền của pha 2–4 phải gán quyền theo chức
vụ — tức **làm ngược một luật đã chốt** — hoặc dừng lại. Nó cũng là vế *ai* của **ADM-50**.

## Sáu chỗ lane này CHẠM pha 1 — đọc trước khi nhận bất kỳ việc nào ở đây

Pha 1 đang chạy song song với mười hai bước `P1-01`…`P1-12` (`work/backlog_SD.md`). Sáu chỗ dưới
đây là nơi hai lane viết về **cùng một thứ**, và ở mỗi chỗ **pha 1 đi trước**: nó viết yêu cầu ở
tầng hệ thống, lane này chỉ được trỏ về, không viết bản thứ hai (**F-001**).

| Chỗ chạm | Bước pha 1 | Việc ở lane này | Ai viết trước |
|---|---|---|---|
| *một ngày bán* cho phép cộng tiền | **P1-03** | ADM-01 (mốc **vận hành** của một buổi) | P1-03 |
| lượt bán ghi **sổ giấy** tính doanh thu ngày nào (`U-032`) | **P1-03** | ADM-52 (nhập bù) | P1-03 |
| hình dạng *ai đang trực trạm nào* | **P1-07** | ADM-21 (luật ghi mốc đổi người) | ADM-21 phải có lời `C36` trước, rồi P1-07 viết yêu cầu |
| hình dạng **vết thao tác** | **P1-07** | ADM-50 | P1-07 |
| invariant nhóm **TIỀN** + phép đối chiếu | **P1-04** | ADM-41 · ADM-44 | P1-04 |
| **bảng quầy** bày gì lên đầu | **P1-09** | ADM-02 · ADM-04 | P1-09 |

Bảng này là **chỗ dễ vỡ nhất** của việc chạy hai lane cùng lúc, và không cổng nào của repo đọc
được nó — Gate 1b chỉ kiểm đường dẫn mở được, Gate 1c chỉ kiểm một mã hai trạng thái. Cái chấm là
mắt người, đúng như **ADR-035** luật 1 đã nói cho ranh giới pha.

## Ba lời đang treo, và không lời nào được chuyển hộ

| Mã | Nội dung | Trạng thái hôm nay |
|---|---|---|
| **Đ-2** | thứ tự làm: đóng nốt chuỗi BA trước, rồi mới chạy nhánh admin | **điều kiện đã đủ** — BA-08…BA-13 đều `Done` tính tới 2026-09-04 — nhưng lời chốt **chưa được chủ quán xác nhận lại**, nên nó vẫn nằm ở `work/admin-questions.md` §1 |
| **Đ-4** | mảng con người làm tới **cả ba mức**: trực trạm + chấm công + lương | **chưa xác nhận lại**, chưa về owner nào |
| **U-034** | mục tổng nhập hàng ngày ghi **con số gì** | đang mở ở `docs/product/99-unknowns.md` — chặn bốn việc nhánh B |

**Không phiên nào được chuyển Đ-2 hay Đ-4 về owner khi chủ quán chưa nhắc lại chúng** (`CLAUDE.md`
§3.5). Đ-1 và Đ-3 đều đã đi qua đúng cửa ấy: chủ quán xác nhận lại rồi mới có T-040 và T-050. Việc
đi hỏi là **ADM-53**.

## Ba mảng này chưa được xếp lịch so với pha 1 — đó là câu của chủ repo

`docs/decisions.md` **ADR-031** chốt ba mảng *được phép* nhưng đi **sau** mảng bán hàng. Mảng bán
hàng (pha 0 · BA) đóng ngày 2026-09-04, và cùng ngày **pha 1 · System design** mở với mười hai bước
`P1-01`…`P1-12` (`work/backlog_SD.md`). Câu chưa ai trả lời: lane admin chạy **song song** với pha
1, hay chờ pha 1 xong? File này **không** trả lời hộ — nó chỉ ghi rằng câu ấy chưa có lời, và rằng
`ADM-53` là chỗ hỏi.

## Mục lục

| Nhánh | Việc | Loại (xem *Cổng của cả lane*) |
|---|---|:--:|
| **A — một buổi bán** | [ADM-01](#adm-01) ca bán · [ADM-02](#adm-02) thứ tự bưng · [ADM-03](#adm-03) sức chứa · [ADM-04](#adm-04) tổng quan buổi bán | 1 |
| **B — nguyên liệu** | [ADM-10](#adm-10) danh mục · [ADM-11](#adm-11) phiếu nhập · [ADM-12](#adm-12) hao hụt · [ADM-13](#adm-13) tồn ước tính · [ADM-14](#adm-14) nối nút tạm dừng · [ADM-15](#adm-15) công nợ nhà cung cấp | 1 |
| **C — con người** | [ADM-20](#adm-20) hồ sơ · [ADM-21](#adm-21) ai đang trực trạm · [ADM-22](#adm-22) chấm công · [ADM-23](#adm-23) bảng lương · [ADM-24](#adm-24) quyền xem lương | 1 |
| **D — sản phẩm** | [ADM-30](#adm-30) sửa giá thành phần · [ADM-31](#adm-31) bật/tắt món · [ADM-32](#adm-32) thêm món · [ADM-33](#adm-33) ảnh và thứ tự | 2: 30 · 31 · 1: 32 · 33 |
| **E — tài chính** | [ADM-40](#adm-40) doanh thu ngày · [ADM-41](#adm-41) đối soát cuối ngày · [ADM-42](#adm-42) sổ chi · [ADM-43](#adm-43) lãi/lỗ · [ADM-44](#adm-44) quỹ và két · [ADM-45](#adm-45) bán chạy | 2: 40 · 41 · 1: 42–45 |
| **F — nền dùng chung** | [ADM-50](#adm-50) vết thao tác · [ADM-51](#adm-51) phân quyền · [ADM-52](#adm-52) nhập bù · [ADM-53](#adm-53) đưa Đ-2 và Đ-4 về owner | **3: 53** · 2: 50 · 52 · 1: 51 |

**Mã số không đánh lại.** `ADM-05`…`ADM-09`, `ADM-16`…`ADM-19`, `ADM-25`…`ADM-29`, `ADM-34`…`ADM-39`
và `ADM-46`…`ADM-49` **cố ý trống**: mỗi nhánh giữ một dãy số riêng để việc mới chèn vào đúng nhánh
mà không phải đánh số lại. `docs/decisions.md` ADR-013 và ADR-031 gọi lane này bằng dãy
*"ADM-01…ADM-52"*; dãy ấy viết ngày 2026-09-02, trước khi `ADM-53` ra đời, và **con số 52 ở ADR-013
là đọc dãy thành phép đếm** — số việc thật đo ngày 2026-09-04 là **29** (`work/findings.md`
**F-028**).

---

<a id="adm-01"></a>
### ADM-01 — Doanh thu tính theo NGÀY, đối soát làm vào cuối buổi, nhưng không tài liệu nào nói một buổi bán bắt đầu và kết thúc lúc nào

**L2** · nhánh A · **chưa nhận được — chặn bởi `A1` `A2` `A3` `A4`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì câu *"buổi bán hôm nay"* có một mốc mở và một mốc đóng đọc được ở một chỗ, và mọi
việc nói *"cuối buổi"* — đối soát, đếm két, nhập hao hụt — biết mình đang đứng ở cuối cái gì.

**Nói một câu, việc phải làm là gì:**
Chốt **khái niệm buổi bán ở tầng nghiệp vụ**: có mấy buổi một ngày, ai mở, ai đóng, mở/đóng thì
những con số nào được chốt lại. Việc **không** phải làm: đừng định nghĩa lại *ngày bán* cho phép
cộng tiền — thứ đó là **P1-03** của pha 1 và nó có owner riêng.

⚠️ **Ranh giới với P1-03, đọc trước khi viết dòng đầu tiên.** P1-03 định nghĩa *một ngày bán* cho
**phép cộng tiền** (doanh thu, nợ, hoàn, đối soát). Việc này định nghĩa *một buổi bán* cho **vận
hành** (mở, đóng, tiền lẻ đầu buổi, đếm cuối buổi). Hai khái niệm khác nhau và có thể không trùng
biên. Ai làm việc này **sau** khi P1-03 xong thì trỏ về định nghĩa của P1-03, đừng viết bản thứ
hai (**F-001**); ai làm **trước** thì dừng — thứ tự đúng là P1-03 trước.

**Vì sao có việc này:**
`master_plan/shop-facts.md` §6.10 chốt đối soát cuối ngày ngưỡng lệch **0đ**, và
`docs/product/1-system-design/architecture.md` §6.4 đã bày công thức của nó. Cả hai câu bắt đầu
bằng chữ *"cuối"*, mà **không mục nào của repo nói cái gì bắt đầu**. Không có mốc mở thì cũng không
có chỗ ghi số tiền lẻ đầu két — và §14.3 của cùng tài liệu đã kể đúng chỗ chạm ấy: *"tiền đầu buổi
và tiền nộp về chưa nằm trong phép tính đối soát"*.

**Không làm thì mất gì:**
- **Đối soát ngưỡng 0đ không chạy được.** Két có tiền lẻ đầu buổi mà phép so không biết con số ấy
  thì nó lệch đúng bằng số tiền lẻ, mọi ngày, và người dùng sẽ học cách bỏ qua chỗ lệch — hỏng
  đúng cổng chất lượng mạnh nhất của dự án.
- **ADM-44 (quỹ và két) và ADM-41 (đối soát) đều mất nửa dữ kiện đầu vào.**
- **Mỗi màn tự chọn một mốc "hôm nay".** Báo cáo doanh thu, bảng quầy và sổ nhập cùng nói *hôm
  nay* mà ba nghĩa khác nhau là loại lỗi chỉ lộ ra vào ngày khó đối chiếu nhất.

**Chặn bởi — hỏi gì trước:**
`A1` (mấy buổi một ngày, mấy giờ) · `A2` (có khái niệm mở/đóng ca không, hay cứ đến giờ là bán) ·
`A3` (đầu buổi có đếm tiền lẻ trong két không, con số ấy có nhập vào máy không) · `A4` (giữa buổi
có nộp bớt tiền không). Bốn câu ở `work/admin-questions.md` §3 nhóm A. `A2` là câu quyết định hình
dạng: trả lời *"không có ca"* thì việc này co lại còn một mốc đóng, và ADM-44 đổi theo.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc (entry này trỏ, prompt giữ).

[↑ đầu file](#top)

---

<a id="adm-02"></a>
### ADM-02 — Bảng quầy sắp xếp theo "cũ nhất lên đầu", nhưng người bưng ngoài đời không bưng theo thứ tự đó

**L1** · nhánh A · **chưa nhận được — chặn bởi `A5` `A6`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì thứ tự quán **thật sự** dùng để quyết bàn nào bưng trước được viết ra, và bảng quầy
hoặc theo đúng thứ tự ấy, hoặc nói rõ nó chỉ sắp theo thời gian và người bưng vẫn tự quyết.

**Nói một câu, việc phải làm là gì:**
Ghi **luật ưu tiên** của quán ở tầng nghiệp vụ. Việc **không** phải làm: đừng thiết kế thuật toán
xếp hàng, và đừng cho máy quyết thay người bưng nếu chủ quán nói người bưng tự nhìn.

**Vì sao có việc này:**
Hôm nay repo chỉ có một luật hiển thị — *cũ nhất lên đầu* — và đó là luật của **bảng**, không phải
luật của **quán**. `master_plan/shop-facts.md` §5.4 đã chốt bếp làm theo **mẻ**, tức thứ tự món ra
lò không trùng thứ tự khách gọi; `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 (BA-12) viết trục
sản xuất ấy ra. Một bảng sắp theo giờ gọi trong khi bếp trả theo mẻ là bảng nói sai về thế giới.

**Không làm thì mất gì:**
- **Người bưng bỏ qua bảng.** Một màn nói sai thứ tự thật thì người dùng học cách không tin nó, và
  từ đó mọi thông tin khác trên màn ấy cũng mất tác dụng.
- **P1-09 (bảng quầy bốn con số) mất một dữ kiện đầu vào**: nó phải quyết bày gì lên đầu.

**Chặn bởi — hỏi gì trước:**
`A5` (bàn gọi trước ra trước · món xong trước bưng trước · người bưng tự quyết) · `A6` (có ca ưu
tiên cố ý không: khách quen, người già, đoàn đông, khách vội). Trả lời *"người bưng tự quyết"* là
một câu trả lời **đủ** — nó đóng việc này lại ở mức một dòng luật, không phải mở nó ra.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-03"></a>
### ADM-03 — "Khách vào khách ra" mới có nửa TRONG QUÁN; khách đứng chờ bàn không tồn tại ở đâu

**L1** · nhánh A · **chưa nhận được — chặn bởi `A7` `A8` `A9`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì quán biết mình có bao nhiêu chỗ, và nếu có hàng chờ thì hàng chờ ấy có một chỗ để
sống — hoặc có một câu chốt rằng quán **không** muốn máy giữ nó.

**Nói một câu, việc phải làm là gì:**
Chốt **sức chứa** và **có hay không một hàng chờ bàn** ở tầng nghiệp vụ. Việc **không** phải làm:
đừng dựng đặt bàn trước — đó là một kênh bán, và năm kênh là danh sách **đóng** (**ADR-015**;
`shop-facts.md` §6.12 xếp kênh thứ sáu vào *đã quyết định không làm*).

**Vì sao có việc này:**
Phiên bàn là khái niệm trung tâm của luồng ăn tại bàn (`architecture.md` §3.1 — *"chỗ dễ mất tiền
nhất"*), nhưng số bàn và số chỗ ngồi chưa là dữ kiện ở `shop-facts.md`. Ghép bàn đã có luật
(**ADR-027**: một phiên, một hoá đơn, chỉ ghép sang bàn **trống**) — luật ấy nói về *bàn trống*,
tức nó đã giả định một danh sách bàn tồn tại.

**Không làm thì mất gì:**
- **ADR-027 không kiểm chứng được**: không có danh sách bàn thì không có khái niệm *bàn trống*.
- **ADM-04 (tổng quan buổi bán) không có mẫu số** — *"còn mấy bàn trống"* là con số đầu tiên bất
  kỳ ai liếc màn tổng quan cũng tìm.

**Chặn bởi — hỏi gì trước:**
`A7` (bao nhiêu bàn, mấy chỗ, đã đánh số chưa) · `A8` (có khách đứng chờ không, ai nhớ ai tới
trước, quán có muốn máy giữ không) · `A9` (khách tự chọn bàn hay nhân viên xếp). `A7` là dữ kiện
quán và về `shop-facts.md`; `A8` và `A9` là luật nghiệp vụ và về
`docs/product/0-ba/admin/01-ranh-gioi.md`.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-04"></a>
### ADM-04 — Chủ quán không đứng quầy thì hôm nay không có gì để nhìn, vì mọi màn đã tả đều là màn của người đang làm việc

**L1** · nhánh A · **chưa nhận được — chặn bởi `A10`, và một nửa nằm ở `F52` `F53`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một câu trả lời cho *"chủ quán liếc một cái thì thấy gì"*, viết bằng ngôn ngữ
nghiệp vụ: những con số nào, cập nhật nhanh tới đâu, và cái gì **không** được bày ra ở đó.

**Nói một câu, việc phải làm là gì:**
Chốt **tập con số** của một cái liếc. Việc **không** phải làm: đừng vẽ màn, đừng đặt tên route,
đừng chọn cách đẩy dữ liệu — cái sau là **P1-08** của pha 1, cái trước là pha 4 (**ADR-035**).

**Vì sao có việc này:**
`docs/product/1-system-design/architecture.md` §6 tả **mặt CHỦ QUÁN** gồm cấu hình, tiền, báo cáo —
tất cả đều là việc *làm*, không phải việc *xem*. §14.2 nói thẳng: mở ranh giới ba mảng **không**
sinh thêm màn nào cho ba mặt đã có. Cho nên chỗ này không phải chỗ bị bỏ quên; nó là chỗ chưa ai
hỏi chủ quán cần gì.

**Không làm thì mất gì:**
- **Mỗi phiên sau tự đoán một tập con số khác nhau** rồi bày lên; sửa lại tốn hơn hỏi một câu.
- **P1-09 (bảng quầy bốn con số) dễ bị kéo sang làm hộ.** Bảng quầy là màn của người **đang đứng
  quầy**; trộn nhu cầu của người **không** ở quán vào đó là làm hỏng cả hai.

**Chặn bởi — hỏi gì trước:**
`A10` (chủ quán lúc không đứng quầy muốn nhìn thấy gì trên điện thoại) · `F52` (phần quản trị chạy
trên máy gì) · `F53` (có muốn xem từ nhà, ngoài giờ bán không). `F53` trả lời *"có"* thì việc này
kéo theo **ADM-51** (ai được xem gì) và không còn là L1.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-10"></a>
### ADM-10 — Mức "sổ ghi tay điện tử" đã chốt, nhưng cuốn sổ ấy ghi những dòng gì thì chưa ai kể tên

**L1** · nhánh B · **chưa nhận được — chặn bởi `B11` `B12` và `U-034`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một danh mục thứ quán mua vào, mỗi thứ một đơn vị tính, và danh mục ấy là **dữ
kiện quán** ở owner của nó chứ không phải một bảng ai đó bịa ra lúc dựng màn.

**Nói một câu, việc phải làm là gì:**
Ghi **danh mục nguyên liệu và đơn vị tính** vào `master_plan/shop-facts.md` §8. Việc **không** phải
làm: đừng chốt định lượng *một suất ăn hết bao nhiêu gam* — đó là mở lại Đ-3, và câu hỏi mở lại nó
là `B22`.

**Vì sao có việc này:**
Chủ quán chốt 2026-09-01, xác nhận lại 2026-09-04: mảng nguyên liệu làm ở mức **sổ ghi tay điện
tử** — người nhập con số, máy giữ và cộng, **máy không tự trừ tồn theo công thức**
(`master_plan/shop-facts.md` §8.4 · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6). Mức đã có;
**đơn vị đo thì chưa**. Không có danh mục thì mọi việc còn lại của nhánh B không có chỗ bám.

**Không làm thì mất gì:**
- **Năm việc còn lại của nhánh B đều treo.** Phiếu nhập, hao hụt, tồn ước tính, nhắc sắp hết, công
  nợ — cả năm đều bắt đầu bằng *"thứ nào"*.
- **Phiên đầu tiên dựng nó sẽ tự bịa danh mục.** Danh mục bịa trông vô hại cho tới lúc chủ quán
  nhập số thật và không tìm thấy dòng mình cần.

**Chặn bởi — hỏi gì trước:**
`B11` (kể tên thứ quán mua vào) · `B12` (mỗi thứ đơn vị gì) · và **U-034** — mục tổng hàng ngày ghi
con số gì. `U-034` chặn thật chứ không chặn hình thức: ba đường ra *còn lại · mua vào · đã dùng*
dẫn tới ba danh mục khác nhau, và đường *đã dùng* còn lật ngược chính mức sổ tay vừa chốt.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-11"></a>
### ADM-11 — Tiền mua hàng đi ra khỏi quán mỗi ngày và không có một dòng nào trong hệ thống ghi lại

**L2** · nhánh B · **chưa nhận được — chặn bởi `B13` `B14` `B15` `B16` `B17` và `U-034`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì một lần mua hàng có luật: ghi cái gì, ai được ghi, trả liền hay ghi nợ, và khoản ấy
vào sổ chi ngày nào.

**Nói một câu, việc phải làm là gì:**
Chốt **luật của một lần nhập hàng**. Việc **không** phải làm: đừng thiết kế quy trình duyệt chi —
quán có bốn người và một chủ, thêm một bước duyệt là thêm một bước không ai bấm.

**Vì sao có việc này:**
Đây là **đường tiền thứ năm** của hệ thống. `docs/product/1-system-design/architecture.md` §7 tả
**bốn** đường tiền, cả bốn đều là tiền **vào**; tiền **ra** chưa có đường nào. Mà
`master_plan/shop-facts.md` §6.10 chốt đối soát cuối ngày ngưỡng lệch **0đ** — nếu tiền mua hàng
lấy thẳng từ két bán hàng (`E46` hỏi đúng chuyện đó) thì mỗi lần mua là một lần két lệch mà không
dòng nào giải thích.

**Không làm thì mất gì:**
- **Đối soát 0đ vỡ vào đúng ngày quán đi chợ bằng tiền két**, và vỡ theo cách không truy được.
- **ADM-42 (sổ chi) và ADM-43 (lãi/lỗ) mất khoản chi lớn nhất của quán.** Lãi lỗ thiếu tiền hàng
  là một con số sai theo hướng nguy hiểm nhất: nó luôn đẹp hơn sự thật.
- **ADM-15 (công nợ nhà cung cấp) không có chỗ bám** — một khoản nợ sinh ra từ một lần nhập.

**Chặn bởi — hỏi gì trước:**
`B13` (mấy ngày mua một lần) · `B14` (ai đi mua) · `B15` (chợ, mối quen hay cửa hàng; một thứ có
nhiều nguồn không) · `B16` (trả liền hay ghi sổ nợ, trả theo tuần hay tháng) · `B17` (có hoá đơn
giấy không). `B16` là câu quyết định: trả lời *"có ghi nợ"* thì **ADM-15 thành bắt buộc** và việc
này lên L2 chạm tiền thật.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-12"></a>
### ADM-12 — Đồ hỏng, đồ đổ, đồ thừa cuối buổi là chi phí thật của quán và hôm nay không có chỗ nào nhận con số ấy

**L2** · nhánh B · **chưa nhận được — chặn bởi `B18` (vế còn lại) `B19` `B20` và `U-034`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì cuối buổi có một chỗ nhập những gì đã mất đi mà không thành doanh thu, và con số ấy
đứng đúng một chỗ — không trộn vào doanh thu, không trộn vào tồn.

**Nói một câu, việc phải làm là gì:**
Chốt **luật ghi hao hụt / huỷ / đồ thừa** ở mức người nhập tay. Việc **không** phải làm: đừng cho
một thao tác bán hàng nào tự sinh ra dòng hao hụt — `01-ranh-gioi.md` §1.6 chốt *đường duy nhất để
một con số nguyên liệu đổi là có người nhập nó*.

**Vì sao có việc này:**
Chủ quán đã trả lời **một nửa** của `B18` ngày 2026-09-04: có **một mục tổng nhập hàng ngày, chủ
quán tự nhập**. Nửa còn lại — *đếm những thứ gì*, và con số ấy có phải *đồ thừa* hay không — là
**U-034**, đang mở. Đây là việc gần lời chốt nhất của cả nhánh B và cũng là việc dễ làm sai nhất:
một mục nhập tổng làm đúng thì đóng cả `B18`, làm sai thì thành cái sổ không ai nhập.

**Không làm thì mất gì:**
- **Mục tổng hàng ngày mà chủ quán đã yêu cầu không có luật để dựng.** Chủ quán đã nói *sẽ nhập số
  liệu*; không có việc này thì lời hứa ấy không có chỗ đáp.
- **ADM-13 (tồn ước tính) không có vế trừ.** Nhập vào có, dùng ra không, thì con số tồn chỉ tăng.

**Chặn bởi — hỏi gì trước:**
Vế còn lại của `B18` (đếm những thứ gì) · `B19` (đồ thừa để mai hay bỏ) · `B20` (hỏng/đổ/cháy giữa
buổi có ai ghi không) · và **U-034**. Đọc `U-034` trước cả ba câu kia: nó quyết **con số nền**, và
ba câu kia chỉ có nghĩa sau khi biết con số nền là gì.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-13"></a>
### ADM-13 — Không có tồn thì không có "sắp hết", và không có "sắp hết" thì nút tạm dừng nhận đơn phải bấm bằng trí nhớ

**L1** · nhánh B · **chưa nhận được — chặn bởi `B21` và `U-034`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một con số tồn **ước tính** — đúng chữ *ước tính*, vì mức sổ tay không cho phép nói
chắc — và một lời nhắc khi nó xuống thấp.

**Nói một câu, việc phải làm là gì:**
Chốt **cách con số tồn được suy ra và ngưỡng nhắc**. Việc **không** phải làm: đừng cho lời nhắc
**chặn** bất kỳ thao tác bán hàng nào — tiền lệ đã có ở `U-018`, chủ quán chốt máy chỉ **nhắc**,
không chặn.

**Vì sao có việc này:**
Mức sổ tay nghĩa là máy không biết chắc còn bao nhiêu; nó chỉ biết những gì người nhập. Một hệ
thống nói *"còn 3 kg"* bằng giọng chắc chắn trong khi dữ liệu là ước lượng thì tệ hơn một hệ thống
im lặng — người dùng tin nó đúng một lần, mất hàng một lần, rồi không tin nữa.

**Không làm thì mất gì:**
- **ADM-14 mất tín hiệu đầu vào**: nối *hết nguyên liệu* với nút tạm dừng cần một chỗ phát tín hiệu.
- **Chủ quán tự nhớ như hôm nay.** Đây là hậu quả nhẹ nhất trong nhánh B, và cũng là lý do việc này
  ở **L1** chứ không phải L2 — làm sai thì phiền, không mất tiền.

**Chặn bởi — hỏi gì trước:**
`B21` (nhắc dựa vào cái gì: chủ quán tự đặt ngưỡng, hay đếm tay rồi nhập) · và **U-034**. Trả lời
*"tự đặt ngưỡng"* thì việc này rất rẻ; trả lời *"đếm tay rồi nhập"* thì nó gộp vào ADM-12.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-14"></a>
### ADM-14 — Nút tạm dừng nhận đơn đã có từ lâu, và tới hôm nay vẫn không ai viết được ai bấm nó theo cái gì

**L1** · nhánh B · **chưa nhận được — chặn bởi `B21` và ADM-13**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì *"hết nguyên liệu"* và *"tạm dừng nhận đơn"* nối được với nhau bằng một luật viết ra,
chứ không bằng thói quen của người đứng quầy.

**Nói một câu, việc phải làm là gì:**
Chốt **luật nối** giữa tín hiệu hết nguyên liệu và nút tạm dừng đã có. Việc **không** phải làm:
đừng cho máy **tự** bấm nút ấy — bấm tự động là chặn bán hàng bằng một con số ước tính, đúng thứ
`U-018` đã bác.

**Vì sao có việc này:**
`docs/product/1-system-design/architecture.md` §14.3 kể bốn chỗ mảng admin **chạm** mảng bán hàng,
và đây là chỗ thứ nhất, ghi nguyên văn: *"nút tạm dừng đã có ở §6.2; ai bấm và bấm theo cái gì thì
chưa"*. Nút nằm ở `master_plan/shop-facts.md` §6.8 và đã chốt từ trước; chỗ thiếu là **luật bấm**.

**Không làm thì mất gì:**
- **Quán nhận đơn cho món đã hết** — khách chờ rồi bị báo hết, đúng ca `ADR-018` đã phải viết luật
  riêng để xử. Việc này là đường **chặn trước**; ADR-018 là đường **chữa sau**.
- **Một chỗ chạm đã ghi rõ trong tài liệu kiến trúc nằm mở vô thời hạn**, và mỗi phiên đọc §14.3
  lại gặp lại đúng câu ấy.

**Chặn bởi — hỏi gì trước:**
`B21` (cái gì phát tín hiệu *sắp hết*) và bản thân **ADM-13**. Nếu chủ quán trả lời rằng không cần
tồn ước tính, việc này vẫn còn giá trị ở mức nhỏ nhất: một luật nói **người nào** được bấm nút và
bấm thì cái gì đổi.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-15"></a>
### ADM-15 — Repo đã có cả một phần riêng cho NỢ, và toàn bộ phần ấy chỉ nói về nợ của khách

**L2** · nhánh B · **chưa nhận được — chặn bởi `B16` và ADM-11**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì khoản quán **nợ nhà cung cấp** có luật riêng, và không ai nhầm nó với khoản **khách nợ
quán** — hai chiều tiền ngược nhau đi vào hai phép cộng khác nhau.

**Nói một câu, việc phải làm là gì:**
Chốt **luật công nợ nhà cung cấp** ở tầng nghiệp vụ: sinh ra lúc nào, trả lúc nào, ai được ghi đã
trả. Việc **không** phải làm: đừng tái dùng luật nợ của khách — `ADR-019` gắn nợ khách với **doanh
thu ngày ghi nợ**, và nợ nhà cung cấp không phải doanh thu theo bất kỳ chiều nào.

**Vì sao có việc này:**
`docs/decisions.md` **ADR-012** dựng *Nợ* thành một phần riêng có mục ở cả ba tầng, và
`docs/product/1-system-design/architecture.md` §12 viết đủ bốn tiểu mục cho nó — **tất cả** là nợ
của khách. `work/admin-questions.md` §2 đã gọi tên chỗ lệch này ngay lúc mở nhánh B: *"nợ tiền
hàng, khác hẳn nợ của khách"*.

**Không làm thì mất gì:**
- **Phiên đầu tiên gặp công nợ nhà cung cấp sẽ đọc §12 và dùng lại luật ở đó**, vì §12 là chỗ duy
  nhất trong repo mang chữ *nợ*. Kết quả là một khoản phải trả bị cộng vào phép tính doanh thu.
- **ADM-43 (lãi/lỗ) sai theo hướng đẹp hơn sự thật** chừng nào tiền hàng chưa trả chưa được kể.

**Chặn bởi — hỏi gì trước:**
`B16` (có mối cho ghi sổ nợ không; trả theo tuần hay tháng). Trả lời *"trả liền hết"* thì việc này
**đóng lại bằng một dòng** — và đó là kết quả tốt, không phải công cốc: một dòng chốt *quán không
ghi nợ nhà cung cấp* chặn được mọi phiên sau tự dựng nó.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

⚠️ **Cả nhánh C bị chặn HAI lớp.** Lớp thứ nhất là mười bốn câu `C23`…`C36`. Lớp thứ hai nặng hơn:
lời chốt **Đ-4** — *mảng con người làm cả ba mức* — **chưa được chủ quán xác nhận lại và chưa nằm
trong owner nào**. Nó chỉ sống trong `work/admin-questions.md` §1, mà file ấy tự khai không sở hữu
sự thật nào và sẽ bị xoá. Gỡ lớp thứ hai là việc **ADM-53**, và nó phải chạy trước cả nhánh.

<a id="adm-20"></a>
### ADM-20 — Hệ thống nói về "người đứng quầy" và "người ở bếp" suốt mười ba mục, và không mục nào biết họ là ai

**L1** · nhánh C · **chưa nhận được — chặn bởi `C23` `C24` `C25`, và bởi Đ-4 chưa về owner**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một danh sách người làm, mỗi người kèm những trạm họ làm được, và mọi câu nói *"ai
bấm"* trong repo có chỗ để trỏ về.

**Nói một câu, việc phải làm là gì:**
Chốt **hồ sơ nhân viên ở mức nghiệp vụ**: gồm những thông tin gì, ai được sửa. Việc **không** phải
làm: đừng gắn **quyền** vào hồ sơ ấy — `architecture.md` §4 chốt quyền gắn **chỗ đứng**, không gắn
chức vụ, và §4 có hẳn một mục nói vì sao một trường chức vụ cố định trên hồ sơ **không đủ**.

**Vì sao có việc này:**
`master_plan/shop-facts.md` §3 chốt **năm trạm** và `docs/decisions.md` **ADR-028** chốt chủ quán
đứng quầy vẫn giữ vai chủ quán. Cả hai câu nói về **vai** và **chỗ**; không câu nào nói về **người**.
Trong khi đó `ADR-024` chốt MVP **có** lưu vết cho thao tác chạm tiền — mà một cái vết ghi *ai* thì
cần một danh sách *ai*.

**Không làm thì mất gì:**
- **ADM-21, ADM-22, ADM-23 đều mất chỗ bám.** Trực trạm, chấm công và lương đều là thuộc tính gắn
  vào một người.
- **Vết thao tác (ADM-50) ghi được thời điểm nhưng không ghi được người**, và một cái vết không có
  người là một cái vết không truy được — đúng thứ §6.10 đòi.

**Chặn bởi — hỏi gì trước:**
`C23` (bao nhiêu người, kể cả người nhà) · `C24` (người nhà làm không lương có nằm trong bảng lương
không) · `C25` (ai cố định một trạm, ai đổi trạm trong buổi). `C24` là câu quyết định ranh giới
giữa việc này và ADM-23.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-21"></a>
### ADM-21 — Quyền huỷ đơn và hoàn tiền gắn với CHỖ ĐỨNG, mà không dữ liệu nào trong hệ thống biết ai đang đứng đâu

**L2** · nhánh C · **chưa nhận được — chặn bởi `C36`** · ⚠️ **việc có đòn bẩy lớn nhất của cả lane**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì câu *"ai đang trực trạm nào, lúc này"* trả lời được, và luật quyền đã chốt từ
2026-08-30 lần đầu tiên đứng được trên một dữ kiện thật.

**Nói một câu, việc phải làm là gì:**
Chốt **luật ghi mốc đổi người ở một trạm** — đổi lúc nào thì ai chịu trách nhiệm từ lúc nào. Việc
**không** phải làm: đừng biến nó thành chấm công (**ADM-22**); trực trạm trả lời *"lúc này ai đứng
đây"*, chấm công trả lời *"hôm nay người này làm mấy giờ"*. Hai câu khác nhau, hai việc khác nhau.

**Vì sao có việc này:**
Ba tài liệu cùng chỉ vào đúng chỗ trống này, và đây là chỗ trống được gọi tên nhiều nhất trong cả
repo:

| Tài liệu | Câu nó viết |
|---|---|
| `docs/product/1-system-design/architecture.md` §4 | quyền gắn **chỗ đứng**, không gắn chức vụ — và vì sao `staff.role` **không đủ** |
| cùng tài liệu, §8 | *"Ai đang trực trạm nào, lúc này"* là một trong **sáu** chỗ hình dạng dữ liệu chưa với tới; không có nó thì *"quyền huỷ phải gán theo `role`, tức sai luật"* |
| cùng tài liệu, §14.3 | chỗ chạm thứ hai giữa hai mảng: *"§4 nói quyền gắn chỗ đứng, mà không dữ liệu nào ghi ai đang đứng đâu"* |

`docs/decisions.md` **ADR-016** (POS ở quầy là cửa ghi duy nhất; quyền gắn chỗ đứng) chốt
2026-08-30, xác nhận lại 2026-09-02. Chỗ trống này đã đứng đó **từ ngày luật ấy ra đời**.

**Không làm thì mất gì:**
- **Pha 2–4 buộc phải gán quyền theo chức vụ**, tức thi công ngược một quyết định đã chốt — hoặc
  dừng lại giữa đường. Đây là hậu quả nặng nhất của cả lane admin, vì nó không hỏng ở mảng admin:
  nó hỏng ở **mảng bán hàng**.
- **Vết thao tác (ADM-50) không có vế *ai*.** `ADR-024` chốt MVP có lưu vết; §6.10 đòi *"lệch một
  đồng phải tìm ra lý do"*. Cả hai câu rỗng nghĩa nếu cái vết chỉ ghi được *một cái máy ở quầy*.
- **ADM-22, ADM-23, ADM-24 xếp hàng phía sau.**

**Chặn bởi — hỏi gì trước:**
Đúng **một** câu: `C36` — *người đứng quầy đổi giữa buổi (A đi ăn, B thay) thì quán có muốn máy ghi
lại mốc đổi ấy không*. Một câu, và nó gỡ nhiều thứ nhất trong năm mươi lăm câu. Trả lời *"không
cần"* cũng là một lời giải: khi ấy `architecture.md` §4 phải được sửa **tiến** bằng một khối ghi
ngày, vì luật quyền của nó không còn dữ kiện để đứng.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-22"></a>
### ADM-22 — Trả lương theo buổi hay theo ngày thì đều phải biết ai đã làm buổi nào, và hôm nay không có chỗ nào ghi

**L2** · nhánh C · **chưa nhận được — chặn bởi `C30` `C31` `C32`, và bởi Đ-4 chưa về owner**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì mỗi buổi có một bản ghi ai làm, vào lúc nào, ra lúc nào — đủ để **ADM-23** cộng ra
tiền mà không phải hỏi lại ai.

**Nói một câu, việc phải làm là gì:**
Chốt **luật chấm công**: ai bấm, bấm bằng gì, sửa được không và ai sửa được. Việc **không** phải
làm: đừng chốt đơn giá và cách tính tiền — đó là **ADM-23**, mức L3 vì nó chạm tiền.

**Vì sao có việc này:**
Đ-4 chốt mảng con người làm **cả ba mức**, và chấm công là mức giữa: không có nó thì mức thứ ba
(lương) phải nhập tay toàn bộ, tức mảng con người co lại còn một máy tính bỏ túi.

**Không làm thì mất gì:**
- **ADM-23 phải nhập tay số công**, và một con số nhập tay chạm tiền là chỗ sai không ai đối chiếu
  được.
- **Nếu quán trả theo buổi, con số công là con số nhân trực tiếp ra tiền** — sai một buổi là sai
  tiền của một người thật.

**Chặn bởi — hỏi gì trước:**
`C31` (chấm công bằng cách nào: nhân viên tự bấm, hay người đứng quầy điểm danh) · `C32` (đi muộn
có trừ không, muộn bao nhiêu phút mới tính) · `C30` (nghỉ báo trước / nghỉ đột xuất có trừ không).
`C31` quyết hình dạng; hai câu kia quyết luật.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-23"></a>
### ADM-23 — Lương là khoản chi lớn thứ hai của quán và nó chưa tồn tại trong bất kỳ phép tính nào

**L3** — chạm tiền, và chạm tiền của người thật · nhánh C · **chưa nhận được — chặn bởi `C24` `C26`
`C27` `C28` `C29` `C33`, ADM-22, và Đ-4 chưa về owner**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì số phải trả cho mỗi người trong một kỳ tính ra được từ dữ liệu đã có, và mỗi khoản
cộng trừ trong đó truy ngược được về một dòng ai đó đã nhập.

**Nói một câu, việc phải làm là gì:**
Chốt **luật tính lương**: đơn giá theo gì, cộng gì, trừ gì, kỳ trả ngày nào. Việc **không** phải
làm: đừng gộp nó vào sổ chi (**ADM-42**) — sổ chi ghi *đã chi bao nhiêu*, bảng lương tính *phải trả
bao nhiêu*, và hai con số ấy lệch nhau đúng phần tạm ứng.

**Vì sao có việc này:**
`CLAUDE.md` §3 nói escalate lên L3 khi cái hỏng chạm **tiền, dữ liệu đã lưu, hoặc hợp đồng đã công
bố**. Việc này chạm cả ba theo nghĩa nặng nhất: sai một dòng là trả sai tiền cho một người đang
đứng trong quán. Đây là việc duy nhất của lane admin mà `CLAUDE.md` §3 đòi **review thiết kế trước
khi viết dòng mã đầu tiên**.

**Không làm thì mất gì:**
- **Mảng con người dừng ở hai phần ba**, tức Đ-4 chỉ được thực hiện một nửa — mà Đ-4 là lời chốt
  của chủ quán, không phải lựa chọn của người làm.
- **ADM-43 (lãi/lỗ) thiếu khoản chi lớn thứ hai** sau tiền hàng.

**Chặn bởi — hỏi gì trước:**
`C26` (trả theo buổi/ngày/tháng, bao nhiêu một đơn vị) · `C27` (tăng ca tính thế nào) · `C28` (có
thưởng không) · `C29` (tạm ứng giữa tháng, ai duyệt) · `C33` (kỳ trả ngày nào) · `C24` (người nhà
không lương có nằm trong bảng không). Sáu câu, và **cả sáu phải có lời trước khi viết một dòng** —
một bảng lương thiếu luật tạm ứng là một bảng lương trả thừa tiền.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-24"></a>
### ADM-24 — Bảng lương sẽ nằm trong cùng một hệ thống mà bốn người khác đang dùng mỗi ngày

**L2** · nhánh C · **chưa nhận được — chặn bởi `C34` `C35` `F55`, và ADM-23**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một luật nói ai được xem con số lương của ai, và luật ấy đứng cùng chỗ với luật
quyền đã có chứ không thành một hệ quyền thứ hai.

**Nói một câu, việc phải làm là gì:**
Chốt **luật xem** cho nhóm số nhạy cảm. Việc **không** phải làm: đừng dựng một mô hình phân quyền
riêng cho mảng admin — **ADM-51** là chỗ làm việc đó cho cả mảng, và hai mô hình quyền trong một hệ
thống là một trong những cách hỏng khó gỡ nhất.

**Vì sao có việc này:**
`architecture.md` §4 chốt quyền gắn **chỗ đứng**, và chỗ đứng là khái niệm của người **đang làm
việc**. Xem bảng lương thì không gắn với chỗ đứng: chủ quán xem lương lúc ở nhà. Đây là chỗ đầu
tiên trong repo mà mô hình quyền hiện có **không phủ tới**, và nó phải được nói ra chứ không lặng
lẽ mở rộng.

**Không làm thì mất gì:**
- **Lương lộ ra cho người không được xem** — hỏng một lần là hỏng vĩnh viễn, khác mọi lỗi khác
  trong repo này.
- **Hoặc ngược lại: cả mảng lương bị khoá chặt tới mức chính chủ quán không xem được từ nhà**, và
  khi ấy `F53` mất nghĩa.

**Chặn bởi — hỏi gì trước:**
`C34` (ai được xem bảng lương) · `C35` (nhân viên có được xem công của chính mình không) · `F55`
(ngoài lương còn thứ gì không muốn nhân viên nhìn thấy: giá nhập, lãi lỗ, doanh thu). `F55` mở rộng
việc này ra khỏi lương, và đó là lý do nó phải làm cùng **ADM-51**.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-30"></a>
### ADM-30 — Luật "sửa thành phần, không sửa giá suất" đã viết đủ ở tầng kiến trúc; cái chưa ai chốt là AI được bấm nút ấy

**L2** · nhánh D · **loại 2** — luật đã đủ, phần còn lại thuộc pha 2–4 · **một nửa còn chặn: `D40`**
**Prompt:** không cần prompt cho phần nghiệp vụ; phần thi công đi theo prompt của pha nhận nó

**Goal:**
Xong rồi thì không phiên nào phải viết lại luật giá — nó đã có — và câu *ai được đổi giá* có lời.

**Nói một câu, việc phải làm là gì:**
Hỏi `D40` rồi ghi lời giải về owner của luật quyền. Việc **không** phải làm: đừng viết lại luật cấu
tạo giá vào bất kỳ file admin nào — nó đã có owner và bản thứ hai luôn trôi (**F-001**).

**Luật đã ở đâu, còn thiếu gì:**

| Vế | Đã chốt ở | Trạng thái |
|---|---|---|
| giá một suất = **tổng giá thành phần**, nên màn quản trị sửa **thành phần** | `master_plan/shop-facts.md` §4.6 quy tắc 1 · `docs/product/1-system-design/architecture.md` §6.1 | ✅ đủ |
| màn phải cho **xem trước bốn suất thành bao nhiêu** trước khi lưu | `architecture.md` §6.1 | ✅ đủ |
| đơn cũ **không** đổi giá; tên và giá chụp lại lúc đặt | `architecture.md` §6.1 · `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3 | ✅ đủ |
| đổi giá được **giữa buổi**; mốc khoá giá là **từng dòng** | `docs/decisions.md` **ADR-023** | ✅ đủ |
| **ai** được bấm | — | ❌ **`D40`** |

⇒ **Phần nghiệp vụ của việc này gần như đã xong từ trước khi nó được viết ra.** Cái còn lại là một
câu hỏi (`D40`) và một lượt thi công ở pha 2–4. Đừng mở nó thành một task đặc tả.

**Không làm thì mất gì:**
- **Người đứng quầy đổi giá mà chủ quán không biết.** `ADR-016` chốt quyền gắn **chỗ đứng**, và chỗ
  đứng của người đổi giá là *quầy* — cùng chỗ đứng với người bán hàng. Không có lời `D40` thì luật
  quyền hiện có **cho phép** người đứng quầy đổi giá, và không ai chắc chủ quán muốn thế.
- **Mỗi lần đổi giá phải để lại vết** (`shop-facts.md` §6.10, `architecture.md` §6.4) — vết ghi
  *ai*, mà vế *ai* lại đang chờ `C36`.

**Acceptance · Verify:** phần nghiệp vụ không có gì để nghiệm thu ngoài lời `D40` nằm đúng owner.

[↑ đầu file](#top)

---

<a id="adm-31"></a>
### ADM-31 — Việc này đã có đủ luật từ trước khi nó được ghi vào danh sách, và nó nằm đây chỉ vì danh sách được viết theo mong muốn chứ không theo ranh giới lane

**L1** · nhánh D · **loại 2** — luật đã đủ, không thiếu gì ở tầng nghiệp vụ
**Prompt:** không cần prompt; phần thi công đi theo prompt của pha nhận nó

**Goal:**
Xong rồi thì không ai mở lại việc này như một task đặc tả nữa.

**Luật đã ở đâu, còn thiếu gì:**
`docs/product/0-ba/ban-hang/03-lat-cat.md` **§3.3.4** viết đủ cả bốn vế: ngừng bán là **quyền chủ
quán** · món biến khỏi **cả năm kênh** ngay khi lưu · đơn cũ vẫn hiện **đúng tên đúng giá** · báo
cáo những ngày trước **không đổi một đồng**. Nó còn phân biệt sẵn ca dễ nhầm nhất — *ngừng bán* (chủ
quán đổi menu) khác *hết món giữa buổi* (hết nguyên liệu, đi đường **tạm dừng nhận đơn**). Không
còn vế nào thiếu.

**Không làm thì mất gì:**
Không mất gì ở tầng nghiệp vụ. Cái mất là **thời gian của phiên đọc nhầm**: một entry nằm trong sổ
task trông như việc chưa làm, và phiên nhận nó sẽ viết lại §3.3.4 vào một file admin — tạo bản thứ
hai của một luật đã có owner (**F-001**), lần này còn kèm vi phạm **ADR-013** theo chiều ngược
(nội dung **bán hàng** chảy vào mục admin).

⚠️ **Chỗ duy nhất cần canh:** `ADM-14` nối *hết nguyên liệu* với nút tạm dừng. §3.3.4 đã tách hai ca
này ra; ai làm ADM-14 phải giữ nguyên chỗ tách đó, đừng gộp *ngừng bán* và *hết món* làm một.

**Acceptance · Verify:** không có — việc này đóng lại bằng một lời chốt của chủ repo, không bằng
một thay đổi file.

[↑ đầu file](#top)

---

<a id="adm-32"></a>
### ADM-32 — Thêm một món mới là ĐỔI PHẠM VI, và phạm vi đó nằm trong danh sách "đã quyết định không làm"

**L2** · nhánh D · **chưa nhận được — chặn bởi `D37` `D38` `D42`, và bởi một lời mở lại ranh giới**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì quán biết mình có được thêm món qua phần mềm hay không, và nếu có thì thêm một món kéo
theo những gì.

**Nói một câu, việc phải làm là gì:**
Xin chủ quán **mở lại** một ranh giới đã đóng, rồi mới nói tới hình dạng. Việc **không** phải làm:
đừng dựng màn thêm món trước lời mở lại — đó là tự đổi phạm vi sản phẩm.

**Vì sao có việc này:**
`master_plan/shop-facts.md` §6.12 xếp *món ngoài bảng giá §4.2* vào **bốn ranh giới đã quyết định
không làm**, và `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 khẳng định lại: lời chốt mở ba mảng
admin ngày 2026-09-01 **không chạm** bốn ranh giới ấy. `03-lat-cat.md` §3.3.4 nhắc lại lần thứ ba.
Ba chỗ cùng nói một câu — đây là ranh giới được canh kỹ nhất của repo.

**Không làm thì mất gì:**
Không mất gì hôm nay. Việc này ở trong sổ để **giữ chỗ cho một câu hỏi**, không phải để làm: nếu
một ngày quán bán thêm món, chỗ này là nơi ghi rằng câu trả lời phải đến từ chủ quán trước.

**Chặn bởi — hỏi gì trước:**
`D37` (có bán nước uống không) · `D38` (có món theo mùa / cuối tuần không) · `D42` (có combo, suất
trẻ em, suất lớn/nhỏ không). Cả ba câu đều có thể trả lời *"có"*, và mỗi lần *"có"* là một lần
**bảng giá thành phần** ở `shop-facts.md` §4.2 phải mở rộng — thứ kéo theo `§4.3`, `§4.6` và mười
một tổ hợp giá bắt buộc phủ ở `§4.8`.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-33"></a>
### ADM-33 — Menu QR là mặt khách nhìn thấy đầu tiên, và không ai chốt nó bày gì ngoài tên với giá

**L1** · nhánh D · **chưa nhận được — chặn bởi `D43`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một câu chốt menu QR bày những gì, và ai sửa được thứ tự hiển thị.

**Nói một câu, việc phải làm là gì:**
Chốt **nội dung hiển thị của menu khách** ở tầng nghiệp vụ. Việc **không** phải làm: đừng chọn cách
lưu ảnh, đừng đặt tên thư mục ảnh — đó là pha 2–4 (**ADR-035**).

**Vì sao có việc này:**
`qr_table` là một trong năm kênh bán (**ADR-015**), và là kênh duy nhất khách **tự** gọi món. Mọi
tài liệu hiện có nói về *luật* của kênh ấy — duyệt đơn, khoá giá, tổ hợp hợp lệ — không tài liệu
nào nói khách **nhìn thấy gì**.

**Không làm thì mất gì:**
- **Pha 4 tự quyết**, và quyết xong thì đổi lại tốn hơn hỏi một câu hôm nay.
- Hậu quả dừng ở đó: việc này không chạm tiền, không chạm dữ liệu đã lưu. Đó là lý do nó **L1**.

**Chặn bởi — hỏi gì trước:**
`D43` (menu QR có cần ảnh món không, hay tên và giá là đủ). Một câu, và nó có thể đóng việc này
bằng chữ *"không cần"*.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-40"></a>
### ADM-40 — Luật cộng doanh thu đã chốt tới mức có cả hai chỗ dễ đếm sai; việc này nằm trong sổ như một task đặc tả là nhầm

**L2** · nhánh E · **loại 2** — luật đã đủ, phần còn lại thuộc pha 2–4 · **một nửa còn chặn: `E47`**
**Prompt:** không cần prompt cho phần nghiệp vụ

**Luật đã ở đâu, còn thiếu gì:**

| Vế | Đã chốt ở | Trạng thái |
|---|---|---|
| doanh thu cộng từ **hai nguồn** (phiên bàn + đơn lẻ), bỏ sót một nguồn là thiếu tiền | `docs/decisions.md` **ADR-022** · `architecture.md` §6.3 · `shop-facts.md` §6.9 | ✅ đủ |
| suất *đem về* của khách ngồi bàn thuộc nguồn **phiên bàn** | `shop-facts.md` §6.15 · **ADR-029** | ✅ đủ |
| một khoản **nợ** đã tính doanh thu nhưng chưa có tiền | `shop-facts.md` §6.14 · **ADR-019** | ✅ đủ |
| **hoàn tiền** tính vào **ngày hoàn** | `shop-facts.md` §6.4 · **ADR-020** | ✅ đủ |
| báo cáo có cần mốc **tháng** không | — | ❌ **`E47`** |

⇒ Chỗ **thật sự** còn thiếu ở tầng hệ thống không nằm ở việc này mà ở **P1-03**: *một ngày bán* là
gì cho phép cộng tiền. Chừng nào P1-03 chưa xong, mọi phép cộng ở đây đứng trên một khái niệm chưa
định nghĩa.

**Không làm thì mất gì:**
- Không mất gì ở tầng nghiệp vụ hôm nay. Cái mất là **một phiên đọc nhầm** rồi viết lại luật cộng
  tiền vào một file admin — bản thứ hai của một luật đang giữ tiền (**F-001**).

**Chặn bởi — hỏi gì trước:** `E47` (xem lãi/lỗ theo ngày hay theo tháng là đủ) — nó ảnh hưởng
**ADM-43** nhiều hơn ảnh hưởng việc này.

**Acceptance · Verify:** phần nghiệp vụ không có gì để nghiệm thu ngoài lời `E47` nằm đúng owner.

[↑ đầu file](#top)

---

<a id="adm-41"></a>
### ADM-41 — Công thức đối soát đã viết ra bằng năm dòng và ba luật, và nó thiếu đúng hai con số mà không câu hỏi nào đã hỏi

**L3** — chạm tiền, và là cổng chất lượng mạnh nhất của dự án · nhánh E · **loại 2 nửa trên, chặn
bởi `A3` `A4` nửa dưới**
**Prompt:** không cần prompt cho phần đã chốt; nửa còn lại đi cùng **ADM-01** và **ADM-44**

**Luật đã ở đâu, còn thiếu gì:**
`docs/product/1-system-design/architecture.md` §6.4 đã bày **công thức đủ năm dòng** — tiền thực
nhận = doanh thu − nợ ghi trong ngày + nợ cũ thu được + (trừ) hoàn tiền — kèm **ba luật** không
được vi phạm: nợ cũ thu hôm nay **không bao giờ** cộng vào doanh thu hôm nay · mỗi dòng phải mở ra
được thành từng khoản có người đứng tên · **không có nút "đóng ca dù lệch"**. Ngưỡng lệch **0đ**
chốt ở `shop-facts.md` §6.10 (**ADR-022**).

Thiếu **hai** con số, và cả hai đến từ nhánh A:

| Thiếu | Vì sao nó làm công thức lệch | Hỏi ở |
|---|---|---|
| **tiền lẻ đầu két** | két luôn thừa đúng bằng số tiền lẻ, mọi ngày | `A3` |
| **tiền nộp về giữa buổi** | két thiếu đúng bằng số đã nộp, không dòng nào giải thích | `A4` |

`architecture.md` §14.3 đã ghi sẵn chỗ chạm này bằng đúng chữ: *"§6.4 chốt ngưỡng lệch 0đ; tiền đầu
buổi và tiền nộp về chưa nằm trong phép tính đó"*.

**Không làm thì mất gì:**
- **Ngưỡng 0đ trở thành một câu chữ.** Một cổng luôn báo lệch là một cổng người dùng học cách bỏ
  qua — và lúc ấy nó tệ hơn không có cổng, vì ai cũng tin là đang có.
- **ADM-44 (quỹ và két) không có chỗ đổ số vào.**
- Đây là hậu quả nặng nhất trong nhánh E, và là lý do việc này **L3** chứ không L2.

**Chặn bởi — hỏi gì trước:** `A3` · `A4`. Hai câu, và cả hai nằm ở nhóm A chứ không nhóm E — chỗ
đáng chú ý, vì nó cho thấy nhóm câu hỏi không trùng với nhánh việc.

**Acceptance · Verify:** trong file prompt của việc gộp (**ADM-01** + **ADM-44**), viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-42"></a>
### ADM-42 — Hệ thống cộng được mọi đồng tiền đi VÀO quán và không biết một đồng nào đi RA

**L2** · nhánh E · **chưa nhận được — chặn bởi `E44` `E45` `E46`, và ADM-11**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì mọi khoản chi của quán có một chỗ để ghi, và mỗi khoản biết mình lấy tiền từ đâu ra.

**Nói một câu, việc phải làm là gì:**
Chốt **danh mục khoản chi và luật ghi một khoản chi**. Việc **không** phải làm: đừng dựng kế toán
kép — Đ-3 đã đặt mức cho cả lane này là **sổ ghi tay điện tử**, và không có lời chốt nào nâng mức
ấy lên cho mảng tài chính.

**Vì sao có việc này:**
`docs/product/1-system-design/architecture.md` §7 tả **bốn** đường tiền, cả bốn đều là tiền vào.
§14.3 kể chỗ chạm thứ ba: *"§6.3 mới cộng doanh thu; chi phí chưa có ở đâu"*. Và `E46` hỏi đúng chỗ
nguy hiểm: chi lặt vặt lấy **từ két bán hàng** hay từ tiền riêng chủ quán — nếu lấy từ két thì mỗi
khoản chi là một lần đối soát 0đ lệch.

**Không làm thì mất gì:**
- **Đối soát 0đ vỡ mỗi lần ai đó rút tiền két đi mua đá.**
- **ADM-43 (lãi/lỗ) không tồn tại được** — lãi lỗ là doanh thu trừ chi phí, và vế trừ chưa có.

**Chặn bởi — hỏi gì trước:**
`E44` (chi những khoản gì) · `E45` (khoản nào cố định hằng tháng, khoản nào lặt vặt trong ngày) ·
`E46` (chi lặt vặt lấy từ két hay tiền riêng). `E46` là câu quyết định việc này có chạm đối soát
hay không — trả lời *"tiền riêng"* thì nó rơi từ chỗ chạm tiền xuống một cuốn sổ thường.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-43"></a>
### ADM-43 — Con số duy nhất chủ quán thật sự muốn biết là con số duy nhất chưa có một vế nào

**L2** · nhánh E · **chưa nhận được — chặn bởi `E47`, ADM-42, ADM-23, ADM-11**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có một con số lãi/lỗ, và mỗi đồng trong đó mở ra được thành dòng đã ghi ở đâu.

**Nói một câu, việc phải làm là gì:**
Chốt **phép tính lãi/lỗ và nhịp của nó**. Việc **không** phải làm: đừng tính lãi/lỗ khi vế chi phí
còn thiếu khoản — một con số lãi đẹp hơn sự thật là con số nguy hiểm nhất phần mềm này có thể in ra.

**Vì sao có việc này:**
Đây là việc **cuối** của cả nhánh E theo thứ tự phụ thuộc: nó cần doanh thu (đã có), tiền hàng
(ADM-11), lương (ADM-23) và chi khác (ADM-42). Ba trong bốn vế chưa tồn tại.

**Không làm thì mất gì:**
- Không mất gì hôm nay — nhưng nó là **đích** của cả nhánh E và nhánh B. Bỏ nó ra khỏi sổ thì ba
  việc kia mất lý do tồn tại.

**Chặn bởi — hỏi gì trước:**
`E47` (theo ngày hay theo tháng là đủ) — và ba việc ADM-42 · ADM-23 · ADM-11 phải xong trước. Đây
là việc bị chặn sâu nhất của cả lane; đừng nhận nó sớm.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-44"></a>
### ADM-44 — Két là chỗ đối soát so vào, và không ai chốt trong két có gì lúc mở cửa

**L3** — chạm tiền mặt · nhánh E · **chưa nhận được — chặn bởi `A3` `A4` `E49`, và ADM-01**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì đường đi của tiền mặt trong một buổi — vào két, ra khỏi két, nộp về — có luật, và
`ADM-41` cộng ra đúng số.

**Nói một câu, việc phải làm là gì:**
Chốt **luật quỹ tiền mặt của một buổi bán**. Việc **không** phải làm: đừng gộp nó vào sổ chi
(ADM-42) — sổ chi ghi *tiền đi đâu*, quỹ ghi *tiền đang ở đâu*, và hai câu ấy trả lời hai câu hỏi
khác nhau lúc đối soát lệch.

**Vì sao có việc này:**
`architecture.md` §6.4 và §14.3 cùng chỉ vào đúng chỗ trống: phép tính đối soát chưa có tiền đầu
buổi và tiền nộp về. Và `E51` mở một ca chưa ai viết: **người đi giao cầm tiền về nộp lại** — tiền
đã thu nhưng chưa vào két là một trạng thái thứ ba, không phải *đã thu* cũng không phải *chưa thu*.

**Không làm thì mất gì:**
- **Ngưỡng 0đ không đạt được bằng bất kỳ cách nào** — xem ADM-41.
- **Tiền người giao cầm về không có chỗ đứng**, nên ngày nào có đơn giao là ngày đối soát lệch.

**Chặn bởi — hỏi gì trước:**
`A3` (tiền lẻ đầu két, có nhập máy không) · `A4` (nộp bớt giữa buổi) · `E49` (tiền cuối buổi nộp
ngân hàng hay để nhà; đường đi ấy có cần ghi không) · và `E51` (người giao nộp thiếu / nộp muộn,
quán có muốn máy theo dõi không). Nên hỏi cùng lượt với `ADM-01`: cả hai việc đều đứng trên mốc
mở/đóng buổi.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-45"></a>
### ADM-45 — Việc rẻ nhất của cả lane, và nó vẫn phải chờ một câu trả lời "có muốn không"

**L1** · nhánh E · **chưa nhận được — chặn bởi `E48`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì hoặc có một báo cáo bán chạy / giờ cao điểm, hoặc có một dòng chốt rằng quán không cần
nó — và cả hai đều là kết quả tốt.

**Nói một câu, việc phải làm là gì:**
Hỏi `E48` rồi ghi lời giải. Việc **không** phải làm: đừng dựng nó vì *dễ làm* — mọi báo cáo không
ai đọc đều bắt đầu bằng lý do ấy, và `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7 (BA-09) là
chỗ quyết cái gì vào MVP, không phải chỗ này.

**Vì sao có việc này:**
Dữ liệu để dựng nó đã có sẵn từ luồng bán hàng — không cần một dữ kiện mới nào. Đó vừa là lý do nó
rẻ, vừa là lý do nó dễ bị làm trước những việc quan trọng hơn.

**Không làm thì mất gì:**
Không gì. Đây là việc duy nhất của lane mà câu trả lời trung thực cho *"không làm thì mất gì"* là
**không mất gì** — và điều đó phải được viết ra, vì nó xếp thứ tự ưu tiên.

**Chặn bởi — hỏi gì trước:** `E48` (có muốn biết món nào bán chạy, giờ nào đông khách không).

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-50"></a>
### ADM-50 — MVP đã chốt là CÓ lưu vết, phạm vi vết cũng đã chốt, và cái vết ấy vẫn không ghi được AI

**L3** — vết là thứ đối soát dựa vào · nhánh F · **loại 2** — luật đã đủ, phần còn lại thuộc
**P1-07** và pha 2 · **vế *ai* chặn bởi `C36`**
**Prompt:** không cần prompt cho phần nghiệp vụ; yêu cầu hình dạng dữ liệu do **P1-07** viết

**Luật đã ở đâu, còn thiếu gì:**

| Vế | Đã chốt ở | Trạng thái |
|---|---|---|
| MVP **có** lưu vết; phạm vi = thao tác **chạm tiền** và **chạm trạng thái đơn** | `docs/decisions.md` **ADR-024** | ✅ đủ |
| vết phải ghi *ai · lúc nào · sửa gì · giá trị cũ*, đủ để *"lệch 1 đồng tìm ra lý do"* | `shop-facts.md` §6.10 · `architecture.md` §6.4 luật 2 | ✅ đủ |
| **hình dạng dữ liệu** của cái vết | — | ⏳ **P1-07** của pha 1 viết yêu cầu; pha 2 chốt lược đồ (**ADR-035**) |
| **ai** — người thao tác là ai, khi quyền gắn **chỗ đứng** | — | ❌ **`C36`** → **ADM-21** |

`architecture.md` §8 xếp *"Vết thao tác chạm tiền / chạm trạng thái đơn"* vào **sáu chỗ hình dạng
dữ liệu chưa với tới**, ngay cạnh *"Ai đang trực trạm nào, lúc này"*. Hai dòng ấy là **một** vấn
đề: một cái vết không có người là một cái vết không truy được.

**Không làm thì mất gì:**
- **Câu *"lệch 1 đồng cũng phải tìm ra lý do"* không thực hiện được** — nguyên văn cột hậu quả của
  §8. Đây là câu `shop-facts.md` §6.10 gọi là cổng chất lượng mạnh nhất của dự án.
- **`ADR-017` mất chân đứng.** Nó chốt sửa và huỷ đơn **không** bị chặn bởi trạng thái, POS quyết
  từng ca — một luật mở, và luật mở chỉ an toàn khi mọi lần dùng đều để lại vết.

⚠️ **Đừng nhận việc này như một task đặc tả của lane admin.** Yêu cầu hình dạng dữ liệu là **P1-07**
(bảng *Sáu chỗ lane này chạm pha 1* đầu file). Việc còn lại thuộc lane này đúng một vế: đi hỏi
`C36`, tức **ADM-21**.

**Acceptance · Verify:** trong file prompt của **P1-07** và của **ADM-21**.

[↑ đầu file](#top)

---

<a id="adm-51"></a>
### ADM-51 — Mô hình quyền hiện có gắn với CHỖ ĐỨNG, và mảng quản trị đầy những việc làm khi không đứng ở chỗ nào

**L2** · nhánh F · **chưa nhận được — chặn bởi `C34` `C35` `F52` `F53` `F55`**
**Prompt:** chưa viết được (luật 6 đầu file)

**Goal:**
Xong rồi thì có **một** mô hình quyền phủ cả hai mảng, và mọi màn quản trị đọc quyền từ đó — không
có hệ quyền thứ hai.

**Nói một câu, việc phải làm là gì:**
Chốt **luật xem cho mảng quản trị** và nối nó vào mô hình quyền đã có. Việc **không** phải làm:
đừng dựng vai trò mới (`role`) — `architecture.md` §4 đã viết hẳn một mục về **vì sao `staff.role`
không đủ**, và mở lại nó bằng một mảng mới là đi ngược một quyết định đã chốt.

**Vì sao có việc này:**
Quyền gắn **chỗ đứng** hoạt động vì mọi việc của mảng bán hàng đều xảy ra khi ai đó **đang đứng ở
một trạm**. Mảng quản trị phá giả định ấy ngay ở câu hỏi `F53`: *có muốn xem từ nhà, ngoài giờ bán
không*. Chủ quán ở nhà không đứng ở trạm nào. Đây là chỗ đầu tiên mô hình quyền hiện có không phủ
tới, và nó phải được nói ra chứ không lặng lẽ mở rộng.

**Không làm thì mất gì:**
- **Hai hệ quyền trong một hệ thống** — mỗi màn mới lại chọn hệ nào, và chỗ hở nằm ở đúng khe giữa
  hai hệ.
- **ADM-24 (lương), ADM-30 (giá), ADM-43 (lãi/lỗ) đều treo** ở vế *ai được xem / ai được bấm*.

**Chặn bởi — hỏi gì trước:**
`C34` · `C35` (ai xem được lương, nhân viên xem được công mình không) · `F52` (phần quản trị chạy
trên máy gì) · `F53` (có xem từ nhà không) · `F55` (còn thứ gì không muốn nhân viên thấy). `F53` là
câu quyết định: *"không, chỉ xem ở quán"* thì mô hình chỗ đứng vẫn đủ và việc này co lại rất nhiều.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-52"></a>
### ADM-52 — Quán đã chốt "mất điện thì không dừng bán", và không ai chốt buổi bán trên giấy ấy quay vào máy bằng đường nào

**L2** · nhánh F · **nửa trên là loại 2, nửa dưới chặn bởi `U-032` `F54`**
**Prompt:** chưa viết được cho nửa dưới (luật 6 đầu file)

**Luật đã ở đâu, còn thiếu gì:**

| Vế | Đã chốt ở | Trạng thái |
|---|---|---|
| mất điện / mất mạng / hỏng máy ⇒ quán bán bằng **sổ giấy**, không dừng bán | `master_plan/shop-facts.md` §6.11 (chủ quán chốt 2026-09-02) | ✅ đủ |
| MVP **có** một đường nhập lại phần bán tay | `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.3 (`U-025` đóng) | ✅ đủ |
| một lượt bán ghi tay gồm **những trường gì** | — | ❌ chưa ai hỏi |
| lượt bán ấy tính doanh thu **ngày nào** | — | ❌ **`U-032`**, đang mở — và nó là việc của **P1-03** |
| **ai** nhập bù và nhập **lúc nào** | — | ❌ **`F54`** |

**Không làm thì mất gì:**
- **Đối soát của ngày mất điện không chạy được.** `shop-facts.md` §6.11 đã nói trước hệ quả này:
  bảng đối soát ngày ấy *"lệch mà lý do chỉ là chưa gõ xong"* — và ngưỡng 0đ không phân biệt được
  chỗ lệch vì gian lận với chỗ lệch vì chưa nhập.
- **`I-014`** (*doanh thu một ngày đã đối soát không bao giờ đổi về sau*) **bị đe doạ trực tiếp**:
  nhập bù sau khi đã đối soát là đúng cái việc `I-014` cấm.

⚠️ **`U-032` là câu của P1-03, không phải câu của lane này** (bảng *Sáu chỗ lane này chạm pha 1*).
Prompt của P1-03 đã ghi ⛔ *không viết mục nhập bù trước khi chủ quán trả lời*. Ai nhận ADM-52 mà
trả lời hộ `U-032` là viết chồng lên một bước pha 1 đang chờ.

**Chặn bởi — hỏi gì trước:** `U-032` (chủ quán) · `F54` (ai nhập bù, lúc nào) · và câu chưa có mã:
*một lượt bán ghi tay gồm những trường gì*. Câu thứ ba nên hỏi cùng lượt với hai câu kia.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc.

[↑ đầu file](#top)

---

<a id="adm-53"></a>
### ADM-53 — Hai trong bốn lời chủ quán chốt ngày 2026-09-01 vẫn chỉ sống trong một file nháp tự khai là sẽ bị xoá

**L1** · nhánh F · **loại 3 — nhận được ngay, không chờ ai** · **mở khoá:** cả nhánh C, và câu xếp
lịch của cả lane
**Prompt:** chưa có — viết lúc nhận việc

**Goal:**
Xong rồi thì bốn lời chốt ngày 2026-09-01 đều nằm ở owner của chúng, `work/admin-questions.md` §1
co lại còn một dòng lịch sử, và câu *lane admin chạy song song pha 1 hay chờ pha 1* có lời.

**Nói một câu, việc phải làm là gì:**
**Hỏi chủ quán xác nhận lại Đ-2 và Đ-4**, rồi chuyển hai lời ấy về owner. Việc **không** phải làm:
**đừng chuyển khi chưa hỏi được.** Đ-1 và Đ-3 đều đi qua đúng cửa ấy — chủ quán nhắc lại rồi mới có
T-040 và T-050 — và `CLAUDE.md` §3.5 không có mức L0.

**Vì sao có việc này:**
Chủ quán chốt bốn câu ngày 2026-09-01. Hôm ấy **không file nào ghi lại** vì `docs/product.md` đang
có thay đổi chưa commit của phiên BA-07, và sửa chồng lên là đúng cơ chế sự cố **F-013** · **F-014**
đã ghi. Hai lời đã về owner:

| Lời | Về owner ngày | Nằm ở đâu |
|---|---|---|
| **Đ-1** — mở cả ba mảng vào phạm vi | 2026-09-02 (T-040) | `01-ranh-gioi.md` §1.6 · `architecture.md` §14 · `shop-facts.md` §7.1 |
| **Đ-3** — nguyên liệu ở mức sổ ghi tay điện tử | 2026-09-04 (T-050) | `shop-facts.md` §8.4 · `01-ranh-gioi.md` §1.6 · mở `U-034` |
| **Đ-2** — thứ tự làm | **chưa** | chỉ ở `work/admin-questions.md` §1 |
| **Đ-4** — mảng con người làm **cả ba mức** | **chưa** | chỉ ở `work/admin-questions.md` §1 |

Điều kiện của Đ-2 — *đóng nốt chuỗi BA trước* — **đã đủ**: BA-08 · BA-09 · BA-10 · BA-11 · BA-12 ·
BA-13 đều `Done` tính tới 2026-09-04. Nhưng điều kiện đủ không thay được lời xác nhận.

**Không làm thì mất gì:**
- **Cả nhánh C đứng trên một lời chốt không owner nào giữ.** Năm việc ADM-20…ADM-24 lấy *"cả ba
  mức"* làm tiền đề, và tiền đề ấy chỉ tồn tại trong một file mà banner của chính nó nói sẽ bị xoá.
  Khi file ấy bị xoá, lời chốt biến mất cùng — đúng họ lỗi **F-001**, lần này mất luôn bản gốc.
- **Không ai biết lane admin chạy khi nào.** `ADR-031` nói *sau mảng bán hàng*; mảng bán hàng đóng
  rồi, pha 1 đang chạy, và câu *song song hay nối tiếp* chưa có lời. Mỗi phiên sau tự đoán một câu.
- **Đây là việc rẻ nhất và mở khoá nhiều nhất của cả lane** — một lượt hỏi, một lượt ghi.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở `work/backlog.md` → *Vòng chạy một task L1*; dưới đây là việc riêng của việc này.

1. Đọc `work/admin-questions.md` §1 (bảng bốn lời) · `master_plan/shop-facts.md` §7.1 nhật ký ·
   §8.3 (cách đánh số tiếp) · §8.4 (bản mẫu T-050 đã làm) · `docs/product/0-ba/admin/01-ranh-gioi.md`
   §1.6 · `docs/product/1-system-design/architecture.md` §14 · `docs/decisions.md` **ADR-013** ·
   **ADR-031**.
2. Khai `work/scope.txt`. Ba khối pattern **đã bị commit** ở đầu file là nợ của **T-047** — đừng gỡ
   hộ, đừng dùng.
3. Chuyển dòng ADM-53 từ *Ready* xuống *In Progress* ở `work/backlog.md`.
4. **Hỏi chủ quán ba câu, trong một lượt:** (a) xác nhận lại **Đ-4** — mảng con người có làm cả ba
   mức không · (b) xác nhận lại **Đ-2**, và hỏi thêm vế mới: lane admin chạy **song song** pha 1 hay
   **chờ** pha 1 xong · (c) nhân thể hỏi `C36` (câu có đòn bẩy lớn nhất — xem đầu file).
5. **Không có lời thì dừng ở bước 4** và ghi lại rằng đã hỏi. Suy hộ là vi phạm `CLAUDE.md` §3.5,
   và lời chốt gốc ngày 2026-09-01 **không** đủ để tự chuyển: T-040 và T-050 đều chờ xác nhận lại.
6. Có lời thì ghi: **Đ-4** → `shop-facts.md` **§8.5** (mục mới, đánh số tiếp theo §8.3) + một dòng
   nhật ký §7.1 + mục admin của `01-ranh-gioi.md` §1.6 và `architecture.md` §14 (**ADR-013**: mục
   riêng có nhãn). **Đ-2** → `work/backlog.md` (nó là dữ kiện **xếp lịch của repo**, không phải dữ
   kiện quán, nên nó **không** vào `shop-facts.md`) và một dòng ở file này, mục *Ba mảng này chưa
   được xếp lịch*.
7. Chạy `./scripts/gate.sh`. Lượt này chỉ đổi tài liệu nên `verify.sh` được bỏ qua (**ADR-005**),
   còn Gate 1b và Gate 1c vẫn chạy.
8. `grep -rn` cụm *"chưa được xác nhận lại"*, *"Đ-2"*, *"Đ-4"* và *"ADM-53"* — mọi pointer nói
   ngược lời vừa ghi là bug của **lượt này**, không phải task sau (`CLAUDE.md` §7.2).
9. Gạch `~~ADM-53~~` ở `work/admin-questions.md` §1 và §2, sửa banner trạng thái của file ấy; nếu
   cả bốn lời đã về owner thì §1 co lại còn một dòng lịch sử trỏ tới owner. Tick ADM-53 ở
   `work/backlog.md` → *Done*; entry này **ở lại đây** kèm một dòng *Xong ngày…* (luật 3 đầu file).
   Xoá pattern của mình trong `work/scope.txt`.
10. Khối `git commit` dán được, liệt kê từng file, **không** kèm `work/scope.txt`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng chuyển Đ-2 vào `master_plan/shop-facts.md`.** Nó là thứ tự làm việc của **repo**, không
  phải dữ kiện của **quán**; `shop-facts.md` là nhà của dữ kiện quán (**ADR-001**) và §8.3 nói rõ
  chỉ dữ kiện admin mới vào §8.
- **Đừng viết Đ-4 vào mục của mảng bán hàng.** **ADR-013** đòi mục riêng có nhãn; T-040 đã sai đúng
  chỗ này một lần và đó là lý do ADR-013 tồn tại.
- **Đừng coi "điều kiện đã đủ" là "lời đã xác nhận".** Chuỗi BA đóng rồi không có nghĩa chủ quán
  vẫn muốn thứ tự cũ; hỏi mất một câu, đoán sai mất một nhánh.

**Acceptance · Verify:** trong file prompt viết lúc nhận việc (entry này trỏ, prompt giữ).

[↑ đầu file](#top)

---

## Việc mới của lane này thì viết vào đâu

Vào **file này**, lấy số tiếp theo trong dãy của nhánh nó thuộc về (mục *Mục lục* nói dãy nào còn
trống), viết đủ hình dạng mà luật 6 quy định cho loại của nó. Rồi:

- **Chỉ thêm một dòng ở `work/backlog.md` → *Ready* nếu nó nhận được ngay** (luật 1). Việc còn chờ
  chủ quán thì **không** có dòng trạng thái nào.
- **Câu hỏi mới cho chủ quán vào `work/admin-questions.md` §3**, không vào đây, và không vào
  `docs/product/99-unknowns.md` — mục ấy chỉ nhận câu **đã hỏi mà chủ quán chưa quyết được**, và
  `brief.sh` cắt nó ở mười hai mục (**F-012**).
- **Lời giải thì đi về owner ở `CLAUDE.md` §2**, vào **mục riêng có nhãn** của mảng admin
  (**ADR-013**), không ở lại file này.

[↑ đầu file](#top)
