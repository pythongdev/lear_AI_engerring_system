# Một task chạy thật, mổ từ đầu đến cuối — ca `P1-12`

> **File này không sở hữu dữ kiện nào.** Nó là **bản mổ** của một task đã chạy
> xong trong repo này, dùng làm ví dụ cho [`workflow-phien-lam-viec.md`](workflow-phien-lam-viec.md).
> Mọi luật thật nằm ở [`CLAUDE.md`](../../CLAUDE.md) và ở các owner mà `CLAUDE.md` §2
> chỉ tên; chỗ nào file này nói khác `CLAUDE.md`, **`CLAUDE.md` thắng và file này
> là bug phải sửa**. Mọi con số dưới đây là **ảnh chụp tại lúc task chạy**
> (2026-09-16, commit `bf39be5`) — đọc chúng như *biên bản một lượt*, không phải
> như trạng thái hôm nay.

Tài liệu kia mô tả luồng ở dạng **quy tắc**. File này lấy **một** lượt có thật và
hỏi ở mỗi bước: *lúc ấy tôi biết gì, tôi quyết cái gì, và nếu quyết sai thì hỏng ở đâu.*

---

## 0. Vì sao chọn đúng task này

`P1-12` là ca tốt để mổ vì nó **không** phải ca đẹp:

- Nó là **L1** — bậc phổ biến nhất, không phải bậc hiếm.
- Nó kết thúc bằng **một ô cổng không tick được**. Task `Done`, nhưng câu trả lời
  của task là *"không"*. Đây là chỗ hầu hết quy trình tự lừa mình.
- Nó **cố ý không sửa** thứ nó tìm thấy. Ranh giới *đo* và *dọn* là ranh giới dễ
  vượt nhất khi đang cầm bàn phím.
- Nó phát hiện **chính cái cổng lẽ ra phải bắt lỗi ấy đang mù**, và vẫn không sửa cổng.

| | |
|---|---|
| **Mã** | `P1-12` — bước 12/14 của pha 1 |
| **Bậc** | **L1** |
| **Prompt** | [`prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md`](../../prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md) |
| **Mô tả dài** | [`work/backlog_SD.md`](../../work/backlog_SD.md) → `P1-12` |
| **Trạng thái** | [`work/backlog.md`](../../work/backlog.md) → *Done* 2026-09-16 |
| **Commit** | `bf39be5` — 7 file, +438 / −15 |
| **Đầu ra thật** | ô 10 của [`07-cong-chat-luong-pha-1.md`](../product/1-system-design/07-cong-chat-luong-pha-1.md) §7, **để trống kèm lý do** |

---

## 1. Task này là gì, nói một câu

> Chạy bộ lọc ranh giới pha trên **cả tám** file pha 1, dán **cả lệnh chưa lọc lẫn
> lệnh đã lọc**, rồi mỗi chỗ lọt ra hoặc là **ngoại lệ có tên**, hoặc có **một mã**
> và **một owner**.

Luật đằng sau nó là `ADR-035`: *pha 0–1 không nhắc tên bảng · pha 2 không nhắc
endpoint · pha 3 không nhắc component*. Luật ấy có ở [`docs/decisions.md`](../decisions.md)
từ 2026-09-04, nhưng **không cổng nào của repo chấm đủ nó**. `P1-12` sinh ra để
trả lời một câu duy nhất: *luật ấy có được tuân thủ thật không, hay chỉ được viết ra.*

---

## 2. Trước khi có prompt — brief đã đặt sẵn ba thứ

`scripts/brief.sh` chạy ở `SessionStart`, nên trước dòng chữ đầu tiên tôi đã có:
task nào *In Progress*, `work/scope.txt` đang khai gì, finding nào **Open**, và
commit gần đây. Ba thứ ấy quyết định lượt này trước cả khi nó bắt đầu:

1. **`P1-11` đã Done** ⇒ `P1-12` được phép chạy. Nếu brief nói khác, việc đầu tiên
   là hỏi, không phải làm.
2. **`work/scope.txt` còn 70 pattern của phiên trước.** Brief cảnh báo thẳng. Luật
   ở đây là **THÊM khối của mình vào cuối**, không xoá khối người khác
   ([`work/findings.md`](../../work/findings.md) `F-010` · `F-014`) — vì brief không có cách nào biết
   đó là scope bỏ quên hay là một phiên khác đang chạy song song trên cùng cây.
3. **Danh sách Open findings bị cắt ở sáu mục.** Brief in `→ ĐÃ CẮT`. Đây không phải
   chi tiết trang trí: ô 10 sau đó phải nêu **bốn mã** mà brief **không** in ra, nên
   bước đầu tiên là mở thẳng `work/findings.md`, không tin danh sách sáu dòng.

**Chỗ hỏng nếu bỏ qua bước này:** làm một task đã có người làm, hoặc bị Gate 3 chấm
bằng scope của người khác.

---

## 3. Phân loại — vì sao **L1** chứ không phải L2

Câu hỏi của `CLAUDE.md` §3 là *"sai thì hỏng cái gì"*, không phải *"diff to hay nhỏ"*.

| Phép thử | `P1-12` | Kết luận |
|---|---|---|
| Có đụng tiền không? | không | không lên L2 vì tiền |
| Có đụng dữ liệu đã lưu không? | không | — |
| Có **quyết định một thiết kế** không? | **không** — nó *đo*, rồi *định tuyến* cái đo được | **không cần ADR** |
| Có đổi hành vi / hợp đồng không? | không | |
| Có đổi tài liệu đã ký không? | có — một ô cổng | **≥ L1** |

⇒ **L1.** Và phân loại này trả tiền ngay: L1 **không** đòi ADR, nên lượt này
**không được** viết một ADR chọn hộ cách sửa ba chỗ lọt ra. Nó chỉ được ghi
finding và **để chủ repo chọn**. Một lượt tự nâng mình lên L2 ở đây sẽ kết thúc
bằng một quyết định kiến trúc do máy ký.

> **Bài học chung:** phân loại sai lên trên cũng hỏng như phân loại sai xuống dưới.
> Lên quá thì máy giành mất quyền quyết; xuống quá thì không ai chấm được kết quả.

---

## 4. Lấy context — chọn theo **chủ quyền**, không theo *độ liên quan*

Repo có hàng trăm file "liên quan" tới ranh giới pha. Lượt này mở đúng sáu chỗ:

| Mở cái gì | Vì nó **sở hữu** cái gì |
|---|---|
| `docs/decisions.md` → `ADR-035`, `ADR-039` | chính cái luật đang được đo, và cái cổng đang chấm nó |
| kế hoạch pha 1 §3 · §9 | ba câu không được viết ra · luật *"ô không tick được thì để trống kèm mã"* |
| [`architecture.md`](../product/1-system-design/architecture.md) §8 · §12.3 | ngoại lệ **đã tự khai** — phải kể ra như ngoại lệ, không như lỗi |
| [`07-cong-chat-luong-pha-1.md`](../product/1-system-design/07-cong-chat-luong-pha-1.md) §7 | chỗ ký, tức đầu ra của lượt này |
| `scripts/check-phase-boundary.sh` + `.ignore` | bộ mẫu thật, để chạy **nguyên văn** chứ không viết lại |
| [`master_plan/shop-facts.md`](../../master_plan/shop-facts.md) §3 · §5 | kênh bán và trạm — để **không** kêu nhầm chúng là tên bảng |

Dòng cuối là dòng đáng giá nhất. `qr_table` · `staff_pos` · `trang_banh` trông y hệt
tên bảng. Nếu không mở `shop-facts.md` trước, phép đo sẽ báo **14 vi phạm** thay vì
**3**, và cả báo cáo thành rác — con số sai làm hỏng kết luận nhanh hơn là không có
con số nào.

**Dấu hiệu lấy sai context:** phải *đoán* một định danh là gì. Lúc ấy dừng và đi tìm
owner, đừng đoán tiếp.

---

## 5. Khai scope — và ở ca này, scope **chính là phép đo**

Khối scope của `P1-12` khai bảy file được sửa, rồi ghi rõ hai nhóm **không** có
trong scope, kèm lý do đứng ngay trong file:

```text
# Đây là một PHÉP ĐO: bảy file nội dung pha 1 và scripts/ chỉ được ĐỌC, không sửa —
# chỗ lọt ra trả về bước đã viết nó (work/backlog_SD.md → P1-12, bước 5). Vì thế
# 01…06 + architecture.md + scripts/ KHÔNG có trong scope này, có chủ ý.
```

Đây là chỗ `work/scope.txt` làm nhiều hơn vai trò hành chính: **scope là hình dạng
của task**. Một lượt đo mà để `architecture.md` trong scope thì, đến chỗ thứ ba lọt
ra, gần như chắc chắn sẽ "tiện tay sửa luôn" — và Gate 3 sẽ xanh, vì file ấy được khai.

Một dòng nữa đáng đọc: `docs/product/00-index.md` **được khai mà cố ý không dùng**.
Nó ở đó phòng trường hợp pha 1 thật sự đóng trong lượt này. Ô 10 không tick được
⇒ bảng *Sáu pha* không đổi ⇒ file khai mà không sửa. Điều đó hợp lệ.

---

## 6. Làm — quy tắc duy nhất của lượt này: **đo, không dọn**

Mười một lệnh chạy, chia năm lượt lọc. Hai ràng buộc chi phối toàn bộ:

**(a) In lệnh chưa lọc cạnh lệnh đã lọc, mọi lần** (`F-017`).
Một bộ lọc rỗng vì **viết sai** trông y hệt một bộ lọc rỗng vì **không có lỗi**.
Nên mỗi lượt đều dán con số thô của chính nó:

| Lượt | Bắt cái gì | Chưa lọc | Đã lọc |
|---|---|--:|--:|
| A | bộ mẫu **nguyên văn** của Gate 1d, chạy trên cả tám file | 2385 | 1 |
| B | động từ HTTP + đường dẫn **không** mở đầu bằng `/` | 2385 | 4 |
| C | từ khoá ràng buộc SQL | 2385 | 3 |
| D | định danh `snake_case` + `bảng.cột` | 2385 | 14 + 1 |
| E | route · component · đuôi file mã | 2385 | 12 + 0 |

**Lượt E là lượt chứng minh bộ lọc không tự rỗng.** Nó bắt 12 dòng, và **không dòng
nào là vi phạm** — chúng là chính những câu *tự khai ranh giới* (*"Ở đây không có
tên bảng, endpoint, route"*). Tức bộ lọc có chạy, chỉ là không có gì để bắt. Nếu
lượt E trả về 0, tôi phải nghi lệnh trước khi nghi tài liệu.

**(b) Đừng đếm rộng hơn phạm vi** (`F-018`). Tập bị rà là `docs/product/1-system-design/*.md`
và **chỉ** nó. Đếm thêm `work/` hay `prompt/` là đo *hoạt động viết lách*, không đo
*việc còn lại*.

---

## 7. Chỗ khó thật — phân loại, không phải grep

`grep` mất vài giây. Việc thật nằm ở chỗ chia mọi chỗ khớp thành **ba nhóm, không
chỗ nào để lửng**:

| Nhóm | Ở ca này | Xử lý |
|---|---|---|
| **Ngoại lệ có tên** | `architecture.md` §12.3 — tự khai *"cố ý vượt ranh giới… chủ repo yêu cầu thẳng"* | Kể ra **kèm ranh giới của chính nó**: nó khai *tên bảng, tên cột*, và đúng **một** mục. Nó **không** phủ endpoint, **không** phủ mục khác |
| **Định danh nghiệp vụ, pha 0 sở hữu** | `qr_table` · `staff_pos` · `phone_preorder` · `trang_banh` · `gap_banh` · `don_ban` | Ghi ra để **lượt sau không kêu lại**. Bộ lọc kêu chúng là bộ lọc đo sai thứ |
| **Chỗ lọt ra thật** | ba chỗ, **tất cả** ở `architecture.md`; bảy file kia sạch | Mỗi chỗ: mục · dòng · `git blame` · một mã `F-XXX` |

Bước phân loại này là chỗ **không script nào thay được**. `UNIQUE` trong §3.1 là vi
phạm; `UNIQUE` trong §12.3 là ngoại lệ đã khai; `qr_table` không phải cả hai. Ba
chuỗi ấy giống nhau với mọi biểu thức chính quy.

**Và câu quan trọng nhất của cả bước:** ngoại lệ §12.3 **không tự nhận là phủ ba chỗ
kia**. Đọc nó thành *"phần nợ được miễn"* là đúng cái tiền lệ mà prompt đã báo trước:
*một ngoại lệ không có tên thì lần sau thành tiền lệ*.

---

## 8. `git blame` — chỗ lỗi **trả về ai**

Ba chỗ lọt ra đều `blame` về **`cf8bd83`, 2026-08-31**. `ADR-035` — cái luật chúng
vi phạm — ra đời **2026-09-04**.

Kết luận đổi hoàn toàn: đây **không** phải một bước pha 1 vượt rào. Đây là
`architecture.md` được viết **trước khi có ranh giới**, và lúc dựng ranh giới thì chỉ
**§8** được viết lại cho khớp — §3.1, §4, §12.2 không ai quét.

Nếu bỏ `git blame`, báo cáo sẽ đọc thành *"pha 1 vi phạm luật của chính nó"* — sai,
và sai theo hướng đổ lỗi nhầm chỗ. Một dòng lệnh đổi cả cách đọc kết quả.

> **Luật rút ra được:** khi tìm thấy một chỗ hỏng trong tài liệu, hỏi *"nó sinh ngày
> nào, và luật nó vi phạm sinh ngày nào"* **trước khi** viết một chữ nào về nó.

---

## 9. Ghi dữ kiện — hai mã, hai owner, không cái nào tự sửa

| Mã | Nó ghi gì | Vì sao **không** sửa trong lượt này |
|---|---|---|
| `F-040` | ba chỗ vượt ranh giới ở `architecture.md`, kèm **ba đường ra, không chọn hộ** | Chọn một trong ba là **quyết định thiết kế** ⇒ L2 ⇒ ngoài bậc của task. Người viết mục ấy mới biết câu đúng phải là gì |
| `F-041` | Gate 1d **mù** với chính khối API ấy (mẫu đòi `/` ngay sau động từ HTTP, mà tài liệu viết `staff/debts`), và dòng ignore duy nhất ghi lý do sai mục | `CLAUDE.md` §3.8: luật chỉ dựng sau khi **cùng một vấn đề đã tốn hai lần**. Đây mới là lần đo đầu tiên |

`F-041` là chi tiết đắt nhất của cả ca: **phép đo tìm ra rằng cái cổng đang bảo vệ
luật ấy không bảo vệ được gì**, và vẫn không sửa cổng. Sửa cổng ngay là hành vi đúng
theo bản năng và sai theo hệ thống — nó biến một lượt đo thành một lượt sửa, và
`scripts/` thì không có trong scope.

Ba đường ra của `F-040` được **viết ra cả ba**, kèm giá của từng cái, và **không cái
nào được chọn**. Đó là ranh giới giữa *báo cáo* và *quyết định thay người khác*.

---

## 10. Gate — và một ô cố ý không tick

`./scripts/gate.sh` xanh. Nhưng thứ đáng nói không phải màu của gate mà là **ô 10**:

- Ô 10 **trước** lượt này: để trống, lý do *"chưa ai đo"*.
- Ô 10 **sau** lượt này: vẫn để trống, lý do ***"đã đo, và câu trả lời là không"***, kèm `F-040`.
- **Cổng vẫn 9/10. Pha 1 vẫn chưa đóng.**

Đây là chỗ hệ thống chứng minh nó không phải thủ tục trang trí. Task chạy xong,
gate xanh, commit sạch — và ô cổng **vẫn không tick**, vì tick nó là nói dối. Bài học
`BA-11` viết ngay cạnh: *cổng 9/10 kèm lý do thì dùng được, cổng 10/10 bằng cảm giác
thì không chặn được gì.*

Một chi tiết nữa, thuộc loại hiếm gặp: **bản ghi của phép đo nằm trong tập bị đo.**
Ô 10 là một file pha 1, nên viết kết quả vào đó làm chính các con số ấy hết đúng
(2385 → 2459 dòng; lượt D 14 → 31). Ô 10 tự khai điều này và dặn lượt sau **trừ mục
ấy ra trước khi đếm lại**. Một biên bản kể tên chỗ hỏng thì tự nó chứa chỗ hỏng ấy.

---

## 11. Bàn giao — và câu phân biệt hai thứ dễ lẫn

Entry backlog ghi thẳng: **task `Done` ≠ ô cổng xanh**, và lần này hai thứ ấy khác nhau.

- `work/backlog.md` → `P1-12` sang *Done*. Việc đã làm xong.
- Ô 10 vẫn trống. Câu hỏi vẫn chưa có lời.
- Pha 1 **chưa đóng**, và *"được, sang pha 2"* là **chữ ký của chủ repo**, không phải
  hệ quả của một task `Done`.

Khối commit bàn giao: một task, một khối, file lấy từ `git diff --name-only HEAD`
chứ không từ trí nhớ, và **không có `work/scope.txt`** trong đó — pattern là trạng
thái phiên, không bao giờ vào commit.

---

## 12. Bản đồ: bước workflow ↔ chỗ nó xảy ra trong ca này

| Bước ở [`workflow-phien-lam-viec.md`](workflow-phien-lam-viec.md) | Ở `P1-12` nó là gì | Hỏng thì sao |
|---|---|---|
| §1 brief tự đến | thấy `P1-11` Done, thấy scope 70 pattern, thấy `→ ĐÃ CẮT` | làm trùng việc; bị chấm bằng scope người khác |
| §3 phân loại | L1, **không** ADR | L2 nhầm ⇒ máy chọn hộ cách sửa kiến trúc |
| §4 lấy context | sáu owner, trong đó `shop-facts.md` cứu phép đếm | báo 14 vi phạm thay vì 3 |
| §5 khai scope | bảy file sửa; bảy file pha 1 + `scripts/` **chỉ đọc** | "tiện tay sửa luôn", và Gate 3 vẫn xanh |
| §6 làm | năm lượt lọc, mỗi lượt hai con số | bộ lọc viết sai trông như không có lỗi |
| §7 ghi dữ kiện | `F-040` + `F-041`, cùng lần sửa | phát hiện chết theo phiên |
| §8 gate | `gate.sh` xanh, output dán thật | "tôi đã kiểm tra" không phải bằng chứng |
| §9 bàn giao | Done + ô 10 trống + khối commit | phiên sau tưởng pha 1 đã đóng |

---

## 13. Năm câu mang đi được, không phụ thuộc task này

1. **Một lượt *đo* và một lượt *dọn* là hai lượt.** Gộp chúng lại thì mất cả phép đo
   lẫn quyền quyết định của người sở hữu chỗ bị sửa.
2. **Luôn dán con số chưa lọc.** Không có nó, "không tìm thấy gì" là câu vô nghĩa.
3. **`git blame` trước khi kết luận.** Chỗ hỏng sinh trước luật không phải là vi phạm
   luật — nó là một món nợ chuyển tiếp, và cách xử lý khác hẳn.
4. **Ngoại lệ phải có tên và có ranh giới.** Một ngoại lệ không tự khai mình phủ tới
   đâu sẽ được viện dẫn để phủ thêm, lần sau.
5. **Ô không tick được thì để trống kèm mã chỗ chặn.** Giá trị của một cổng nằm ở
   những lần nó **không** xanh.

---

## Đọc tiếp

| Muốn biết | Đọc |
|---|---|
| Luồng chung của một lượt | [`workflow-phien-lam-viec.md`](workflow-phien-lam-viec.md) |
| Luật thật của hệ thống | [`CLAUDE.md`](../../CLAUDE.md) |
| Bốn bậc rủi ro | [`README.md`](../../README.md) |
| Prompt gốc của ca này | [`prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md`](../../prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md) |
| Kết quả đo đầy đủ | [`07-cong-chat-luong-pha-1.md`](../product/1-system-design/07-cong-chat-luong-pha-1.md) §7 ô 10 |
| Hai mã lượt ấy mở ra | [`work/findings.md`](../../work/findings.md) → `F-040` · `F-041` |
| Cách chấm kết quả sau khi tôi chạy xong | [`quality/review-gate.md`](../../quality/review-gate.md) |
