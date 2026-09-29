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

### 4.1. “Chủ quyền” nghĩa là gì khi chọn context?

**Context là những thông tin cần có để làm đúng task:** phải trả lời câu hỏi nào,
được sửa đến đâu, quy tắc nào dùng để chấm, bằng chứng nằm ở đâu và điều gì chưa
được phép kết luận. Đọc một file mới chỉ là lấy đầu vào; phải hiểu nó trả lời câu
hỏi nào và có quyền quyết định điều gì thì mới dùng được.

“Chủ quyền” ở đây là **file được repo giao sở hữu một loại thông tin**, theo
`CLAUDE.md` §2. Ví dụ, trạng thái task thuộc `work/backlog.md`; mô tả dài của
task pha 1 thuộc `work/backlog_SD.md`; dữ kiện quán thuộc `master_plan/shop-facts.md`.
Một file nhắc đến cùng từ khoá chưa chắc có quyền xác nhận ý nghĩa của từ ấy.
Nếu bản tóm tắt và owner nói khác nhau, phải đối chiếu owner, không chọn câu
nghe hợp lý hơn hay file vừa sửa gần nhất.

Vì vậy, chọn theo chủ quyền **vẫn cần xét task có cần thông tin ấy không**.
Không phải đọc hết mọi owner. Trình tự là: xác định câu hỏi cần trả lời → tìm
owner của câu trả lời → đọc phần đủ để hiểu cả quy tắc lẫn giới hạn áp dụng.

### 4.2. Đọc từ đâu, theo thứ tự nào?

Các bước dưới đây giải thích cách áp dụng luật đọc context trong `CLAUDE.md`
§2, §3 và §7; không tạo thêm một bộ luật riêng cho tài liệu này.

1. **Đọc `CLAUDE.md`, rồi lấy brief.** Claude nhận brief từ hook; Codex chạy
   `./scripts/brief.sh`. Dùng brief để biết task đang làm, scope, thay đổi chưa
   commit và những mục cần mở tiếp. Brief chỉ là bảng chỉ đường: thấy mã finding
   thì mở nội dung finding, thấy danh sách bị cắt thì mở nguồn để đọc phần còn lại.
   Không lấy việc brief không in một mục làm bằng chứng rằng mục ấy không tồn tại.

   **Cụ thể, đọc gì trong `CLAUDE.md` và hiểu như thế nào?** Đọc toàn bộ file vì
   đây là luật làm việc chung của repo. Sau đó rút ra những điều cần áp dụng cho
   task, thay vì chỉ nhớ tên các mục:

   **§1 — Hiểu dự án và cách trao đổi.** Biết repo phục vụ hệ thống bán hàng và
   quản trị của một quán, đồng thời quy định cách AI làm việc có kiểm chứng.
   Trả lời chủ repo bằng tiếng Việt, văn xuôi dễ hiểu. Phần giới thiệu chỉ giúp
   định hướng; dữ kiện chi tiết về quán phải đọc ở owner được chỉ ra.

   **§2 — Biết thông tin nào thuộc file nào.** Hiểu rằng `CLAUDE.md` là bản đồ
   chỉ nguồn, không chứa toàn bộ sự thật của dự án. Trạng thái task đọc ở
   `work/backlog.md`; luật ranh giới pha theo tới quyết định tương ứng; ý nghĩa
   tên kênh bán đọc ở `master_plan/shop-facts.md`. Một tài liệu nhắc lại thông
   tin không trở thành căn cứ cuối cùng chỉ vì nó dễ tìm hơn owner.

   **§3 — Biết task được làm đến đâu.** Hiểu phải xác định mục tiêu, mức rủi ro
   và phạm vi sửa trước khi làm; không tự đặt ra sự thật nghiệp vụ. Áp dụng vào
   `P1-12`, phải đọc tiếp prompt mới biết nhiệm vụ cụ thể là đo và ghi nhận.
   Tìm thấy lỗi không cho phép tự sửa kiến trúc hay script. Đây là kết luận từ
   luật chung kết hợp với phạm vi task, không phải chỉ đọc `CLAUDE.md` là biết.

   **§4 — Biết xử lý điều chưa rõ.** Không tự suy ra một quy tắc nghiệp vụ để
   tiếp tục. Câu hỏi chưa có đáp án phải chuyển tới người có quyền quyết; lỗi
   phát hiện được ghi vào nơi theo dõi phù hợp. Đọc mục này để biết cách đưa
   vấn đề về đúng nơi, đồng thời đối chiếu §7.4 để biết vai trò hiện tại có
   được trực tiếp ghi vào file đó hay phải báo lại người dẫn việc.

   **§5 và §8 — Biết khi nào được nói đã xong.** Phải có bằng chứng kiểm tra,
   đọc lại diff và, với L1 trở lên, đối chiếu từng Acceptance. Với `P1-12`,
   gate xanh chưa chứng minh toàn bộ pha 1 đúng ranh giới: script chỉ kiểm một
   phần. Đọc tiếp task để biết phép đo bổ sung và bằng chứng cần đưa ra.

   **§6 — Biết cách bàn giao commit.** Chỉ lấy đúng file thuộc task từ trạng
   thái Git thực tế, kiểm tra cả những file đã stage, rồi chuẩn bị khối lệnh
   bàn giao theo vai trò. Codex không tự commit; khi nhận phiếu việc từ Claude,
   báo cáo bằng chứng để Claude tích hợp và chuẩn bị khối commit theo §7.4.

   **§7 — Biết bắt đầu từ trạng thái nào và làm với vai trò nào.** Lấy brief,
   kiểm tra công việc đang dở và thay đổi có sẵn, rồi đọc đúng task. Khi làm
   hôm nay, Codex phải phân biệt phiếu việc từ Claude với task nhỏ chủ repo
   giao trực tiếp, vì quyền cập nhật task và scope khác nhau. Kết thúc phải
   để lại trạng thái và bằng chứng mà phiên sau có thể tiếp tục dùng.

   Sau bước này, điều cần hiểu là: **“Tôi biết tìm sự thật ở đâu, giới hạn
   quyền của mình, cách kiểm chứng và cách bàn giao. Tôi chưa biết đầy đủ nội
   dung task; brief và prompt sẽ dẫn tới phần cần đọc tiếp.”**

   Phần giải thích này hướng dẫn đọc luật hiện tại. Ca `P1-12` diễn ra ngày
   2026-09-16; muốn xác minh phiên ấy tuân theo luật nào thì đọc bản lịch sử
   của `CLAUDE.md`, không gán các quy định được bổ sung sau đó cho phiên cũ.

2. **Đọc đúng task được giao.** Với ca này, tìm dòng `P1-12` trong
   `work/backlog.md`, đọc entry `P1-12` trong `work/backlog_SD.md`, rồi đọc prompt
   được entry dẫn tới. Đọc `Goal` để hiểu kết quả cần tạo; `Scope` để biết quyền
   sửa; `Constraints` và `Unknowns` để biết giới hạn; `Acceptance` và `Verify`
   để biết phải đưa ra bằng chứng gì. Kết luận cần giữ lại là: đây là phép đo trên
   cả pha 1, kết quả ghi ở ô 10; phát hiện lỗi không có nghĩa là được sửa lỗi ấy.

   **Sau khi đọc hết các tài liệu của task, phải hiểu cụ thể điều gì?** Với
   `P1-12`, cần rút ra cách hiểu dưới đây. Đây là cách hiểu nhiệm vụ khi nhận
   việc; phần kết quả lịch sử ghi sau khi hoàn thành phải được tách riêng.

   **Vấn đề cần giải quyết.** Repo đã có luật phân chia nội dung theo pha,
   nhưng gate tự động chỉ kiểm được một phần. Vì vậy, tên bảng hoặc hợp đồng
   API vẫn có thể nằm trong tài liệu pha 1 mà gate không báo lỗi. Task được
   giao để kiểm tra khoảng trống đó trên toàn bộ tập tài liệu đã chỉ định.

   **Đầu ra phải tạo.** Cần ghi một phép đo có bằng chứng tại ô 10 của cổng
   chất lượng pha 1: đã rà những file nào, chạy lệnh gì, tìm thấy gì và phân
   loại thế nào. Nhiệm vụ không buộc kết quả phải sạch. Nếu còn vi phạm, ghi
   rõ chỗ chặn là kết quả đúng; tự sửa hoặc che vi phạm để tick ô là làm sai
   nhiệm vụ.

   **Vai trò của ba tài liệu vừa đọc.** `work/backlog.md` xác nhận trạng thái
   task. Entry `P1-12` trong `work/backlog_SD.md` giải thích vì sao cần làm,
   phụ thuộc và liên kết tới prompt. Prompt cụ thể hoá mục tiêu, phạm vi,
   ràng buộc, Acceptance và cách kiểm tra. Đoạn tổng kết lịch sử trong entry
   cho biết chuyện đã xảy ra, nhưng không thay cho bằng chứng của lần chạy mới.

   **Phạm vi đọc, rà và sửa.** Phải tách ba việc này vì mỗi việc trả lời một
   câu hỏi khác nhau. Các giới hạn dưới đây là của ca lịch sử `P1-12`, theo
   `Context`, `Scope`, `Constraints` và `Acceptance` trong prompt; không phải
   quyền sửa được cấp cho một lượt đang đọc tài liệu ví dụ này.

   **Đọc để hiểu: cần nguồn nào để làm đúng và giải thích được kết quả?**
   Đọc prompt để hiểu nhiệm vụ, quyết định để hiểu luật ranh giới, kiến trúc
   để hiểu ngoại lệ, script và file ignore để hiểu máy kiểm được gì, dữ kiện
   quán để hiểu ý nghĩa định danh. Chỉ mở những phần cần thiết và theo dẫn
   chiếu khi còn thiếu căn cứ. Những nguồn này có thể nằm ngoài tập phải rà
   và ngoài phạm vi được sửa. Ví dụ, đọc `shop-facts.md` để xác nhận một tên
   kênh bán không có nghĩa là rà toàn bộ file ấy hay được sửa dữ kiện quán.
   Xem **§4.4 bên dưới**: lượt đọc thật trường hợp `staff.role`, có lệnh,
   output, căn cứ kết luận và diff của lần sửa trong lịch sử.

   **Rà để kết luận: phải kiểm tra đầy đủ trên tập tài liệu nào?** Tập của
   ca lịch sử là tám file `docs/product/1-system-design/*.md`: sáu file
   `01-…` đến `06-…`, `architecture.md` và `07-cong-chat-luong-pha-1.md`.
   Phải liệt kê đủ tập, chạy các phép kiểm Acceptance yêu cầu trên cả tập,
   rồi đọc đoạn bao quanh từng chỗ khớp để phân loại và kiểm tra pointer.
   Không chỉ rà file vừa đổi hoặc vài file đã đọc lấy context. Ngược lại,
   kết quả tìm thấy trong script hay dữ kiện quán không được cộng vào số
   liệu đo tám file pha 1 chỉ vì đã mở chúng để tham khảo.

   **Sửa để ghi kết quả: được thay đổi đúng file nào, phần nào?** Trong tám
   file được rà, chỉ được sửa **§7, ô 10** của
   `07-cong-chat-luong-pha-1.md` để ghi bằng chứng và kết luận. Các phần khác
   của file cổng không thuộc quyền sửa ấy. Bảy file nội dung còn lại phải
   giữ nguyên; `scripts/`, `quality/invariants.md` và
   `master_plan/shop-facts.md` cũng bị cấm sửa trong lượt đo.

   **Cập nhật phụ trợ cũng có giới hạn cụ thể.** Prompt cho phép sửa chính
   file prompt `P1-12`, hàng P1-12 trong `prompt/SD/README.md`, dòng và entry
   P1-12 trong hai backlog; cập nhật kế hoạch pha 1 ở §9, ô P1-12 ở §6 và §5
   nếu bản đồ file đổi; ghi mã mở trong lượt vào `work/findings.md` hoặc
   `docs/product/99-unknowns.md`; thêm khối scope của lượt theo cách prompt
   lịch sử quy định. `docs/product/00-index.md` chỉ được cập nhật khi pha 1
   thật sự đóng, có chữ ký chủ repo. Không sửa entry Done lịch sử của bước
   khác. Đây là danh sách quyền có điều kiện, không phải yêu cầu sửa hết
   các file được liệt kê; khi thực hiện hôm nay còn phải đối chiếu vai trò
   hiện tại theo `CLAUDE.md` §7.4.

   Ví dụ, nếu tìm thấy tên bảng trái ranh giới trong `architecture.md`,
   phải đọc đoạn chứa nó và nguồn quy định để kết luận, ghi vị trí cùng
   nguồn gốc vào finding, rồi dẫn mã chặn ở ô 10; không xoá tên bảng ngay
   trong kiến trúc. Nếu script bỏ sót chỗ ấy, ghi nhận giới hạn của script,
   không sửa mẫu lọc hay file ignore để làm kết quả xanh. **Được đọc không
   đồng nghĩa với phải rà toàn bộ; phải rà không đồng nghĩa với được sửa;
   được sửa một ô không đồng nghĩa với được sửa cả file.**

   **Cách đo và diễn giải.** Phải rà đủ các họ mẫu Acceptance yêu cầu: dấu
   hiệu SQL, định danh dạng `snake_case` hoặc `bảng.cột`, hợp đồng HTTP và
   dấu hiệu route/component. Mỗi lượt có lệnh và số liệu chưa lọc đi cùng
   kết quả đã lọc. Sau đó đọc đoạn chứa từng chỗ khớp để phân biệt ngoại lệ
   được cho phép có giới hạn rõ, định danh nghiệp vụ có owner xác nhận,
   và chỗ thực sự vượt ranh giới pha cần ghi nhận. Không coi mọi chuỗi khớp
   là lỗi, cũng không tự mở rộng ngoại lệ để bỏ qua một lỗi. Các nguồn dùng
   để phân biệt nằm ở bước 3 và §4.3 bên dưới; prompt cho biết phải kiểm gì,
   còn owner cung cấp căn cứ để chấm.

   **Bằng chứng cho từng chỗ sai.** Phải chỉ được mục và dòng chứa nó, dùng
   `git blame` xác định nguồn gốc, rồi ghi mã finding tại nơi theo dõi phù
   hợp. Nguồn gốc giúp hiểu nội dung có trước hay sau luật; nó không tự làm
   cho nội dung đang trái ranh giới trở thành hợp lệ. Task ghi nhận và
   chuyển xử lý, không chọn hộ phương án thiết kế.

   **Điều kiện hoàn thành và quyền kết luận.** Phải đối chiếu đủ Acceptance:
   rà đủ tập, phân loại đủ kết quả, kiểm tra pointer, ghi ô 10 có căn cứ,
   chứng minh những file bị cấm sửa vẫn nguyên vẹn và chạy gate. Task hoàn
   thành không tự động có nghĩa ô 10 được tick; ô 10 được tick cũng không
   thay chữ ký của chủ repo cho phép đóng pha.

   Sau khi đọc, phải diễn đạt được nhiệm vụ bằng lời của mình: **“Tôi được
   giao kiểm tra ranh giới pha trên toàn bộ tập tài liệu đã chỉ định và ghi
   kết quả có thể kiểm chứng vào ô 10. Tôi phải giải thích từng chỗ tìm thấy
   bằng nguồn có thẩm quyền, ghi nhận chỗ sai và giữ nguyên những file không
   được sửa. Tôi hoàn thành việc đo theo Acceptance; việc sửa thiết kế và
   cho phép sang pha tiếp theo thuộc quyết định khác.”**

   Nếu chưa nói rõ được phải tạo gì, được sửa đâu, chấm bằng gì và ai có
   quyền quyết phần còn lại, thì chưa hiểu đủ task để bắt đầu thực hiện.

3. **Từ từng yêu cầu, tìm nguồn có quyền trả lời.** Dùng bảng owner ở
   `CLAUDE.md` §2; khi cần tìm file nghiệp vụ cụ thể, dùng `docs/product/00-index.md`
   làm mục lục. Mục lục không sở hữu quy tắc. Với `P1-12`, câu hỏi “cấm cái gì”
   dẫn tới quyết định ranh giới pha, còn “chuỗi này có nghĩa gì ở quán” dẫn tới
   `shop-facts.md`. Sáu nhóm nguồn ở §4.3 là kết quả của bước chọn này.
4. **Đọc trọn phần có ý nghĩa, rồi theo pointer nếu còn thiếu.** Tìm heading
   hoặc mã bằng `rg -n`, sau đó đọc cả mục: câu định nghĩa, bảng, ngoại lệ, ghi chú
   và dẫn chiếu đi kèm. Một dòng khớp từ khoá chỉ giúp định vị; nó chưa đủ để kết
   luận. Nếu mục dẫn sang một quyết định đang chi phối kết quả, đọc quyết định đó.
5. **Tách việc hiểu luật khỏi việc thu bằng chứng.** Sau khi hiểu luật, vẫn phải
   chạy phép đo trên toàn bộ tập file task yêu cầu. “Chỉ đọc context cần thiết”
   không cho phép chỉ rà vài file mẫu. Mỗi kết quả khớp cần đọc đoạn bao quanh
   rồi đối chiếu với owner trước khi phân loại.

`work/scope.txt` quy định **file được sửa**, không phải danh sách duy nhất được
đọc. Ở ca này, phải đọc `architecture.md` và script để đo đúng dù task cấm sửa
chúng. Ngược lại, có một file trong scope cũng không buộc phải sửa file đó.

### 4.3. Với `P1-12`, từng nguồn phải đọc và hiểu thế nào?

Sau brief và task, ca này cần sáu nhóm nguồn sau. Đây là các nguồn để **hiểu phép
đo**, chưa tính toàn bộ file phải quét để **thực hiện phép đo**:

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

Đọc bảng trên thành các thao tác cụ thể như sau:

- **Quyết định ranh giới:** đọc toàn bộ entry `ADR-035` và `ADR-039`, gồm bối cảnh,
  quyết định và giới hạn, không chỉ dòng ở mục lục. Phải phân biệt được luật cấm
  gì với script bắt được gì. Script không bắt hết luật nên gate xanh chưa đủ để
  ký ô 10.
- **Kế hoạch pha 1:** mở
  [`SD_master_plan_banh_cuon_ba_thanh.md`](../../master_plan/SD_master_plan_banh_cuon_ba_thanh.md)
  §3 để biết ranh giới đầu ra; đọc §9 và theo pointer tới cổng chất lượng để biết
  cách ghi kết quả. Kế hoạch dẫn việc; quyết định được dẫn chiếu mới là căn cứ
  cho ranh giới. Không dùng kế hoạch để tự mở rộng quyền sửa trong prompt.
- **Kiến trúc:** đọc §8 để hiểu phần việc được để lại cho các pha sau; đọc trọn
  §12.3 để thấy ngoại lệ cho phép đến đâu, do ai yêu cầu. Giữ lại phạm vi ngoại
  lệ, không suy ra rằng mọi đoạn gần đó đều được miễn. Khi bộ lọc trả về một
  dòng khác, mở cả đoạn chứa dòng ấy để phân loại riêng.
- **Cổng chất lượng:** đọc phần hướng dẫn và ô 10 trong §7 để biết bằng chứng
  phải ghi vào đâu, điều kiện tick là gì. Khi cần trả lời “pha đã đóng chưa”,
  đọc thêm §8 về quyền ký; trạng thái task hoàn thành không thay cho chữ ký ấy.
- **Script và danh sách bỏ qua:** đọc header, cách chọn file đầu vào, các mẫu lọc,
  cách áp dụng ignore và lý do từng dòng ignore. Từ đó mới biết script chạy trên
  file thay đổi hay cả tập, loại gì ra và có thể bỏ sót gì. Một dòng bị ignore
  chỉ cho biết máy bỏ qua nó; muốn gọi đó là ngoại lệ hợp lệ vẫn phải đối chiếu
  quyết định và phạm vi ngoại lệ.
- **Dữ kiện quán:** đọc §3 về trạm và §5 về luồng bán, kèm §2 nếu cần định nghĩa
  kênh. Cần lấy ý nghĩa của định danh trong câu đang xét. Không cần nạp toàn bộ
  menu, giá và mọi quy tắc quán chỉ để phân biệt tên trạm với tên bảng.

### 4.4. Chạy thật một ví dụ: đọc `staff.role`, kết luận và xem bản sửa

**Codex chạy lại các lệnh dưới đây ngày 2026-09-29 theo yêu cầu chủ repo.** Đây
là lượt kiểm chứng một trường hợp bằng lịch sử Git, không phải chạy lại toàn bộ
Acceptance của P1-12. `bf39be5` là commit kết quả đo; `20f7822` là commit sửa ở
task T-079. Dùng `git show` để đọc đúng phiên bản lịch sử mà không đổi working
tree. Các số dòng bên dưới thuộc phiên bản được chỉ định, không phải file hôm nay.

**Bước 1 — Đọc nhiệm vụ để biết tìm thấy lỗi rồi được làm gì.** Chạy từ gốc repo:

```bash
git show bf39be5:prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md | sed -n '32,54p'
```

Output có hai phần “Được sửa” và “Không được sửa”: phần đầu cho sửa §7 ô 10 của
file cổng và ghi finding; phần sau cấm sửa bảy file nội dung pha 1, gồm
`architecture.md`. Tôi hiểu rằng **phát hiện trong kiến trúc thì ghi nhận để
xử lý, không sửa kiến trúc ngay trong lượt P1-12**. Đây là quyền do prompt cấp,
không phải suy từ việc tôi đọc được file.

**Bước 2 — Tìm dòng nghi vấn, rồi đọc cả đoạn để hiểu nó đang nói gì.**

```bash
git show bf39be5:docs/product/1-system-design/architecture.md | rg -n -C 4 'staff.role'
git show bf39be5:docs/product/1-system-design/architecture.md | sed -n '238,265p'
```

Dòng khớp thật của lệnh đầu:

```text
238:## 4. Quyền gắn CHỖ ĐỨNG, không gắn chức vụ — và vì sao `staff.role` không đủ
```

Lệnh thứ hai cho thấy đoạn bên dưới còn viết “Một cột `role` cố định trên bảng
nhân viên không diễn được luật này”, rồi giải thích chức vụ trả lời *người này
là ai*, còn quyền thao tác hỏi *người này đang đứng đâu, lúc này*. Vậy đây là
cách diễn đạt bằng bảng và cột, không phải một tên kênh bán tình cờ khớp mẫu.
Tới đây tôi biết **đang có gì trong tài liệu**, nhưng còn phải đọc luật để chấm.

**Bước 3 — Đọc nguồn quyết định ranh giới và kiểm tra ngoại lệ.**

```bash
git show bf39be5:docs/decisions.md | sed -n '2066,2165p'
git show bf39be5:docs/product/1-system-design/architecture.md | sed -n '552,588p'
```

Lệnh đầu mở toàn bộ quyết định ADR-035 về quyền sở hữu theo pha. Trong bảng
Decision, “Lược đồ: tên bảng, tên cột, khoá ngoại, quan hệ, thứ tự migration”
thuộc **pha 2 · DB**. Lệnh sau mở §12.3, có câu tự khai:

> Mục 12.3 này cố ý vượt ranh giới §8 đặt ra ("không đặt tên bảng, không đặt tên cột").

Đây là trích đoạn; đọc cả output sẽ thấy lý do là chủ repo yêu cầu một mục DB
cho phần nợ và nó chỉ là đề xuất gửi sang pha 2. **Ngoại lệ nói rõ “Mục 12.3”;
dòng đang xét nằm ở §4 nên không được hưởng ngoại lệ ấy.** Kết hợp vị trí, cách
dùng và luật sở hữu, tôi mới kết luận `staff.role` là chỗ vượt ranh giới pha.
Nếu chỉ tìm chuỗi rồi báo lỗi, tôi chưa chứng minh được phần này.

**Bước 4 — Đọc nghiệp vụ để biết khi sửa phải giữ ý nghĩa nào.**

```bash
git show bf39be5:master_plan/shop-facts.md | sed -n '902,923p'
```

Đoạn §6.13 xác nhận quyền huỷ gắn với người đang đứng quầy; chủ quán không đứng
quầy thì nhờ người đứng quầy bấm. Nguồn này trả lời **ý nghĩa phải giữ**, còn
ADR-035 trả lời **cách diễn đạt nào đặt sai pha**. Không thể dùng quyết định
kiến trúc để tự đặt lại quyền huỷ của quán. Với ví dụ này chỉ cần phần nghiệp vụ
ấy, không cần đọc menu, giá hay migration đang mở trong IDE.

**Bước 5 — Kiểm tra nguồn gốc và nơi đã nhận lỗi.**

```bash
git blame bf39be5 -L 238,238 --date=short -- docs/product/1-system-design/architecture.md
git show bf39be5:work/findings.md | rg -n -C 3 'staff.role'
```

Output của blame:

```text
cf8bd83b docs/architecture.md (pythongdev 2026-08-31 238) ## 4. Quyền gắn CHỖ ĐỨNG, không gắn chức vụ — và vì sao `staff.role` không đủ
```

Git hiện đường dẫn cũ của file ở commit sinh ra dòng. Ngày 2026-08-31 đứng trước
ngày chốt ADR-035 là 2026-09-04: đây là nội dung cũ chưa được điều chỉnh theo luật
ban hành sau đó. Điều này giải thích nguồn gốc, **không làm nó hợp lệ khi đo**.
Lệnh thứ hai tìm được hàng §4, dòng 238 trong finding F-040 về ba chỗ vượt ranh
giới; P1-12 đã ghi nhận nó thay vì sửa ngay.

**Bước 6 — Xem lần sửa thật: ai cho phép, đổi câu nào, giữ lại điều gì.**

```bash
git log --oneline --all --grep='T-079'
git show 20f7822:docs/decisions.md | rg -n -A 30 '^### ADR-048'
git show 20f7822 -- docs/product/1-system-design/architecture.md
```

Lệnh đầu trả về `20f7822 T-079: o 10 cong pha 1 tick — F-040 va F-041 dong`.
Lệnh thứ hai cho thấy ADR-048 ghi chủ repo chọn cách viết lại bằng ngôn ngữ tầng
ngày 2026-09-20, giữ nguyên ý nghĩa. Lệnh cuối cho diff thật; dưới đây trích hai
phần sửa ở §4, không phải toàn bộ diff của commit:

```diff
-## 4. Quyền gắn CHỖ ĐỨNG, không gắn chức vụ — và vì sao `staff.role` không đủ
+## 4. Quyền gắn CHỖ ĐỨNG, không gắn chức vụ — và vì sao một chức vụ ghi cố định không đủ

-⇒ **Một cột `role` cố định trên bảng nhân viên không diễn được luật này.** `role` trả lời *người
-này là ai*; luật hỏi *người này đang đứng đâu, lúc này*. Hai câu khác nhau, và câu thứ hai đổi
-nhiều lần trong một buổi sáng.
+⇒ **Một chức vụ ghi cố định trên hồ sơ một người không diễn được luật này.** Chức vụ trả lời
+*người này là ai*; luật hỏi *người này đang đứng đâu, lúc này*. Hai câu khác nhau, và câu thứ
+hai đổi nhiều lần trong một buổi sáng.
```

Để kiểm tra bản sau sửa thay vì chỉ tin thông điệp commit, chạy:

```bash
git show 20f7822:docs/product/1-system-design/architecture.md | rg -n -A 17 '^## 4\.'
```

Output có tiêu đề mới ở dòng 240, câu mới ở dòng 254–256 và vẫn giữ ví dụ chủ
quán không ở quầy thì không được huỷ, nhân viên đang ở quầy thì được. Bản sửa
bỏ tên bảng/cột khỏi cách giải thích nhưng giữ sự khác nhau giữa chức vụ và
chỗ đứng. Đó là điều phải đối chiếu bằng mắt; riêng việc không còn chuỗi
`staff.role` chưa đủ chứng minh sửa đúng.

**Thay đổi thực hiện trong lượt hôm nay:** thay ví dụ giả định ở §4.4 của chính
file hướng dẫn này bằng chuỗi lệnh và kết quả đã kiểm chứng trên. Bản sửa kiến
trúc là việc đã có trong commit T-079, không phải một thay đổi mới của lượt này.
Người đọc có thể chạy lại từng lệnh để đi từ nhiệm vụ → dòng nghi vấn → luật và
ngoại lệ → ý nghĩa nghiệp vụ → nguồn gốc → bản sửa, thay vì phải tin lời kể.

### 4.5. Khi nào đã đủ context để bắt đầu?

Trước khi đo, cần nói được bằng lời của mình: task phải tạo đầu ra nào, được sửa
đâu, lấy luật ở nguồn nào, rà trên tập nào, dùng bằng chứng nào để chấm và gặp
điều chưa rõ thì trả về ai. Với mỗi kết luận quan trọng, giữ đường dẫn và mục
làm căn cứ; không cần tạo thêm một file “context” chép lại các owner.

Ví dụ, phần hiểu để bắt đầu `P1-12` có thể diễn đạt như sau: “Tôi phải đo toàn bộ
tập file pha 1 được prompt chỉ định và ghi bằng chứng vào ô 10. Tôi dùng quyết
định ranh giới để chấm, đọc giới hạn của ngoại lệ §12.3, và dùng dữ kiện quán để
phân biệt định danh nghiệp vụ. Tôi không sửa nội dung bị phát hiện hay script;
mỗi chỗ sai cần có nơi nhận xử lý.” Đây là cách tóm tắt để làm việc, không thay
thế prompt hay nguồn gốc của từng quy tắc.

Nếu vẫn phải đoán quy tắc, phạm vi ngoại lệ hoặc quyền quyết định thì context
chưa đủ: mở tiếp đúng owner hoặc chuyển câu hỏi cho người có quyền. Nếu những
câu hỏi đó đã trả lời được, bắt đầu làm; chỉ mở thêm nguồn khi bằng chứng mới
đặt ra câu hỏi mới, không đọc cả repo để có cảm giác chắc chắn.

**Lưu ý về thời điểm:** ca này là ảnh chụp ngày 2026-09-16. Để kiểm chứng chuyện
đã xảy ra, xem bản lịch sử bằng `git show bf39be5:<đường-dẫn-file>`; bản đó chứa
kết quả sau lượt đo, muốn xem đầu vào trước lượt thì dùng `bf39be5^`. Để làm một
task hôm nay, dùng brief và owner hiện tại. Không trộn mẫu script cũ, trạng thái
cũ và nội dung hiện tại để tái tạo các con số của ca lịch sử.

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

> **Hậu truyện, 2026-09-20 (T-079, `docs/decisions.md` ADR-048):** chủ repo chọn **đường 2** trong
> ba đường `F-040` ghi — ba chỗ viết lại bằng ngôn ngữ tầng, `PAT_API` của Gate 1d nới kèm hai ca
> hồi quy — nên **ô 10 nay đã tick và cổng là 10/10**. Bài học dưới đây không đổi một chữ: nó nói
> về *lượt đo*, và giá trị của lượt đo là nó **không** tick khi chưa có quyền tick.

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


các bước làm cụ thể 

Tôi đã đọc cả ba file trong docs/work-flow-session/. Để chỉ ra được câu lệnh thật chứ không chỉ kể lại, tôi mở thêm những gì ca này để lại: prompt gốc P1-12-ra-cheo-ranh-gioi-pha-L1.md, mô tả dài trong work/backlog_SD.md:1023, commit bf39be5, ô 10 đúng như lúc commit đó ghi, hai finding F-040/F-041, quality/review-gate.md và .claude/settings.json.

Ba file quan hệ với nhau thế này. workflow-phien-lam-viec.md mô tả luồng chung dưới dạng quy tắc. vi-du-mot-task-chay-that-P1-12.md mổ lại một lượt có thật theo đúng luồng ấy. tom_tat_du_an.md là bản tóm tắt dự án chụp ngày 2026-09-20. Không file nào trong ba file sở hữu dữ kiện; luật thật nằm ở CLAUDE.md.

Bối cảnh ngắn: P1-12 là bước 12/14 của pha 1 (pha thiết kế hệ thống). Nó kiểm xem luật ADR-035 có được tuân thủ thật hay không. Luật đó nói tài liệu pha 0–1 không được nhắc tên bảng, pha 2 không được nhắc endpoint, pha 3 không được nhắc component.

Dưới đây là từng bước theo đúng thứ tự thời gian.

Bước 0 — Chưa ai gõ gì, brief đã tự chạy
Cơ chế. Trong .claude/settings.json, hook SessionStart gọi scripts/brief.sh. Hook này chạy khi mở phiên, khi /clear, khi resume và khi context bị nén. Output của nó nằm trong context trước cả câu đầu tiên của người dùng:


"SessionStart": [{ "hooks": [{ "type": "command",
  "command": "\"${CLAUDE_PROJECT_DIR:-.}/scripts/brief.sh\"" }] }]
Thứ lấy ra. Brief có các mục: task In Progress, scope đang khai, task Ready tiếp theo, finding đang mở, câu hỏi nghiệp vụ còn mở, ADR mới nhất, commit gần đây, ngày sửa cuối của từng file owner, và các thay đổi chưa commit. Brief chỉ in con trỏ (tên file, mã, ngày), không bao giờ chép dữ kiện. Lý do là F-001: một bản sao thứ hai sớm muộn sẽ lệch khỏi bản gốc.

Cách đọc và quyết định ở P1-12. Có ba chi tiết quyết định lượt này trước khi nó bắt đầu.

P1-11 đã Done, nên P1-12 được phép chạy (prompt ghi "cần xong trước: P1-11"). Nếu brief nói khác, việc đầu tiên phải làm là hỏi người dùng, không phải bắt tay vào làm.
work/scope.txt còn 70 pattern của phiên trước. Brief không phân biệt được đó là scope bị bỏ quên hay một phiên khác đang chạy song song trên cùng cây thư mục. Vì vậy quyết định là thêm khối của mình vào cuối, không xoá khối của người khác (F-010, F-014). Xoá đi thì Gate 3 sẽ chấm việc của phiên kia bằng scope của phiên này.
Danh sách finding bị cắt, có dòng → ĐÃ CẮT. Brief chỉ in sáu mục, trong khi ô 10 sau đó phải nêu những mã không có trong sáu mục ấy. Quyết định là mở thẳng work/findings.md thay vì tin danh sách đã bị cắt. Đây là bài học F-012: một danh sách bị cắt mà không báo đã từng giấu một câu hỏi mở suốt nhiều phiên.
Vì sao làm vậy. Mỗi phiên Claude bắt đầu mà không nhớ gì. Nếu việc đọc trạng thái hiện tại phụ thuộc vào trí nhớ, sẽ có ngày nó bị quên, và phiên đó sẽ làm việc theo trạng thái của ngày tài liệu được viết. Khi brief mâu thuẫn với điều Claude đang tin thì brief thắng, vì ngày trong brief lấy từ git.

Bước 1 — Rút từ CLAUDE.md những gì cần dùng
CLAUDE.md được nạp sẵn vào mọi phiên. Có bốn thứ được dùng ở lượt này.

Bảng owner §2 ("một dữ kiện, một chủ"). Trước mọi lần đọc hay ghi, câu hỏi luôn là: dữ kiện này nằm ở file nào?
Các dòng ghi "chưa có owner" (lúc ấy gồm schema, API, route). Chúng là lệnh cấm: pha 1 không được đặt tên bảng hay endpoint, dù Claude "biết" chúng nên trông thế nào.
Bảng bậc rủi ro §3, đặc biệt cột "Enforced by". Nghĩa vụ ghi self-discipline là nghĩa vụ không script nào bắt được nếu bị quên, nên phải chủ động giữ.
§3.8. Chỉ dựng luật, hook hay test mới khi cùng một vấn đề đã tốn công hai lần. Điều này sẽ quyết định ở bước 8.
Bước 2 — Phân loại: vì sao là L1 mà không phải L2
Câu hỏi đặt ra là "nếu sai thì hỏng cái gì", không phải "diff to hay nhỏ". Bộ câu hỏi nằm ở docs/prompt-guideline.md §1. Lượt này không đụng tiền, không đụng dữ liệu đã lưu, không đổi hành vi hay hợp đồng, và không quyết thiết kế nào: nó chỉ đo rồi chuyển kết quả đo tới đúng chỗ. Nó có sửa một tài liệu đã ký (ô cổng), nên ít nhất là L1.

Phân loại này có hệ quả ngay. L1 không đòi ADR, nên lượt này không được phép viết ADR chọn cách sửa ba chỗ vi phạm. Nếu tự nâng lên L2, lượt này sẽ kết thúc bằng một quyết định kiến trúc do máy ký thay chủ repo. Bài học rút ra là phân loại sai lên trên cũng hỏng như phân loại sai xuống dưới. Nâng quá thì máy giành mất quyền quyết định. Hạ quá thì không ai chấm được kết quả.

Bước 3 — Lấy context theo "ai sở hữu dữ kiện", không theo "file nào liên quan"
Câu hỏi sai là "file nào liên quan?", vì trong repo này gần như file nào cũng liên quan một chút. Câu hỏi đúng là "dữ kiện tôi cần do file nào sở hữu?", và câu trả lời tra được ở bảng §2. Thứ tự đọc như sau.

1. Trạng thái task ở work/backlog.md, và chỉ ở đó. Hai file backlog_SD.md và backlog_AD.md chỉ giữ mô tả dài.

2. Mô tả dài của task. Không đọc cả file, mà tìm vị trí trước rồi đọc đúng khối:


grep -n "P1-12" work/backlog_SD.md        # → entry nằm ở dòng 1023
sed -n 1023,1095p work/backlog_SD.md
Từ khối này lấy ra: Goal, vì sao có task, không làm thì mất gì, danh sách mười bước (bước 5 viết thẳng "chỗ lọt ra trả về bước đã viết nó, không tự sửa hộ ở đây"), và bẫy hay sửa nhầm (F-018: đừng đếm rộng hơn phạm vi).

3. File prompt prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md. Đọc đủ sáu khối: Context, Goal, Scope, Constraints, Acceptance, Verify. Khối Verify chứa sẵn các lệnh đo. Khối Acceptance có 11 dòng, và đó là thước đo xem lượt này xong hay chưa.

4. Sáu owner mà task thật sự chạm tới. Mỗi file mở ra để trả lời đúng một câu hỏi:

docs/decisions.md → ADR-035, ADR-039: luật đang được đo là gì, và cổng nào đang chấm nó.
master_plan/SD_master_plan_banh_cuon_ba_thanh.md §3 và §9: ba câu không được viết ra, và luật "ô không tick được thì để trống kèm mã chỗ chặn".
architecture.md §8 và §12.3: ngoại lệ đã tự khai, phải kể ra như ngoại lệ chứ không như lỗi.
07-cong-chat-luong-pha-1.md §7: chỗ ghi kết quả của lượt này.
scripts/check-phase-boundary.sh và file .ignore của nó: bộ mẫu thật, để chạy nguyên văn chứ không viết lại.
master_plan/shop-facts.md §3 và §5: danh sách kênh bán và trạm.
Vì sao shop-facts.md quan trọng nhất. Các chuỗi qr_table, staff_pos hay trang_banh trông giống hệt tên bảng, nhưng thật ra là tên kênh bán và tên trạm do pha 0 sở hữu. Nếu không mở file này trước, phép đo sẽ báo 14 vi phạm thay vì 3, và cả báo cáo thành vô dụng.

Khi nào dừng đọc. Khi viết ra được ba thứ: từng dòng Acceptance, owner mà mỗi dữ kiện mới sẽ về, và các pattern của scope. Viết được cả ba mà vẫn muốn mở thêm file thì đó là "đọc cho chắc", nên dừng. Dấu hiệu lấy sai context là phải đoán một định danh nghĩa là gì. Khi đó phải dừng lại và đi tìm owner của nó.

Bước 4 — Chuyển task sang In Progress và khai scope trước lần sửa đầu tiên
Claude chuyển dòng P1-12 trong work/backlog.md sang In Progress, rồi thêm khối của mình vào cuối work/scope.txt. Khối này khai bảy file được sửa (ô 10 của file cổng, file prompt, prompt/SD/README.md, hai file backlog, SD master plan, findings.md/99-unknowns.md), và ghi rõ trong comment những gì cố ý không có:


# Đây là một PHÉP ĐO: bảy file nội dung pha 1 và scripts/ chỉ được ĐỌC, không sửa —
# chỗ lọt ra trả về bước đã viết nó (work/backlog_SD.md → P1-12, bước 5). Vì thế
# 01…06 + architecture.md + scripts/ KHÔNG có trong scope này, có chủ ý.
Vì sao. Ở ca này, scope chính là hình dạng của task. Nếu architecture.md nằm trong scope, đến chỗ vi phạm thứ ba gần như chắc chắn Claude sẽ "tiện tay sửa luôn", và Gate 3 vẫn xanh vì file ấy đã được khai. Để file đó ngoài scope thì Gate 3 sẽ chặn đúng hành vi này.

docs/product/00-index.md được khai nhưng cố ý không dùng. Nó chỉ phải sửa nếu pha 1 thật sự đóng trong lượt này, mà cuối cùng pha 1 không đóng. Khai mà không sửa là hợp lệ. Còn nếu không khai scope, Gate 3 sẽ in scope not declared, skipping, tức gate xanh mà không kiểm gì cả.

Bước 5 — Đo: các lệnh trong khối Verify
Có hai ràng buộc chi phối toàn bộ bước này. Thứ nhất, luôn in số dòng chưa lọc bên cạnh số đã lọc (F-017), vì một bộ lọc rỗng do viết sai trông giống hệt một bộ lọc rỗng do không có lỗi. Thứ hai, chỉ đo trong docs/product/1-system-design/*.md (F-018).

(1) Tập bị rà, ở mức thô nhất:


wc -l docs/product/1-system-design/*.md
Kết quả là 8 file, tổng 2385 dòng (ví dụ architecture 681, file 07 416). Đây là con số gốc để mọi lượt lọc so sánh.

(2) Lượt A: chạy nguyên văn bộ mẫu của Gate 1d trên cả tám file. Gate 1d thật chỉ quét những file đổi trong lượt, nên trước đó nó chưa bao giờ chạy trên toàn bộ tập:


PAT_DB='CREATE[[:space:]]+TABLE|ALTER[[:space:]]+TABLE|...|\b(VARCHAR|BIGINT|SERIAL|TIMESTAMPTZ|NOT[[:space:]]+NULL)\b'
PAT_API='\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+/|/api/|/v[0-9]+/'
PAT_FE='\.(jsx|tsx|vue)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>'
grep -nEI "$PAT_DB|$PAT_API|$PAT_FE" docs/product/1-system-design/*.md
Kết quả là 1 dòng (architecture.md:552), và dòng này đã nằm sẵn trong file ignore. Nói cách khác, Gate 1d im lặng hoàn toàn trên cả tập.

(3) Lượt B: động từ HTTP theo sau là đường dẫn không mở đầu bằng /. Đây là chỗ đoán rằng mẫu gốc bị mù:


grep -nEI '\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+[A-Za-z]' docs/product/1-system-design/*.md
Kết quả là 4 dòng, chính là bốn dòng hợp đồng API ở §12.2 (POST staff/sessions/:id/close…). Từ đây sinh ra F-041.

(4) Lượt C: từ khoá ràng buộc SQL (cờ -w để khớp nguyên từ):


grep -nEIw 'UNIQUE|CHECK|INDEX|CASCADE|CONSTRAINT|JOIN|SELECT|INSERT' docs/product/1-system-design/*.md
Kết quả là 3 dòng.

(5) Lượt D: định danh snake_case trong backtick, đếm theo tần suất:


grep -oEI '`[a-z][a-z0-9]*_[a-z0-9_]+`' docs/product/1-system-design/*.md | sort | uniq -c | sort -rn
Kết quả là 14 dòng. Lượt này bắt buộc đọc tay, vì phần lớn kết quả là tên kênh và tên trạm.

(6) Lượt D2: dạng bảng.cột, loại trừ tên file .md:


grep -nEI '`[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*`' docs/product/1-system-design/*.md | grep -v '\.md`'
Kết quả là 1 dòng (staff.role).

(7) Lượt E: dấu vết của pha 4 (route, component, useState, className, đuôi file code):


grep -nEI '\.(jsx|tsx|vue|ts|js|css)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>|\broute\b|\bcomponent\b|useState|className' docs/product/1-system-design/*.md
grep -nEI '(^|[^a-z.`])/[a-z][a-z0-9-]*/[a-z]' docs/product/1-system-design/*.md \
  | grep -v '\.md\|docs/\|work/\|scripts/\|quality/\|master_plan/\|prompt/'
Kết quả là 12 dòng cho lệnh đầu và 0 cho lệnh sau. Lượt E cố ý được viết để không rỗng: nó bắt những câu tài liệu tự khai kiểu "Ở đây không có tên bảng, endpoint, route". Như vậy nó chứng minh bộ lọc có chạy, chỉ là không có route nào để bắt. Nếu lượt E trả về 0, phải nghi lệnh viết sai trước khi kết luận tài liệu sạch.

(8) Kiểm pointer. Gate 1b tự động kiểm link, nhưng có hai thứ nó không kiểm nên phải làm thêm:


grep -ohE '\]\([^)]+\)' docs/product/1-system-design/*.md | wc -l      # tổng: 196
grep -nE '\]\([^)]*/\)' docs/product/1-system-design/*.md             # trỏ thư mục (F-018): 0
grep -ohE '\]\([^)]*#[^)]+\)' docs/product/1-system-design/*.md | sort -u  # neo #
for f in ...; do u=$(grep -c ']( *#top)' $f); a=$(grep -c 'id="top"' $f); ...; done  # neo chết: 0
./scripts/check-links.sh                                               # xanh
Bước 6 — Phân loại kết quả: chỗ không script nào làm thay được
Chạy grep chỉ mất vài giây. Việc thật là chia mọi dòng khớp vào ba nhóm, không để dòng nào lửng lơ. Lý do không script nào làm được việc này là: UNIQUE ở §3.1 là vi phạm, UNIQUE ở §12.3 là ngoại lệ đã khai, còn qr_table thì không thuộc cả hai. Với mọi biểu thức chính quy, ba chuỗi này trông như nhau.

Nhóm 1: ngoại lệ có tên. Chỉ có §12.3, và nó được kể ra cùng với ranh giới của chính nó. Câu tự khai của §12.3 chỉ phủ tên bảng, tên cột và chỉ trong một mục. Nó không phủ endpoint và không phủ mục nào khác. Nếu đọc nó thành "phần nợ được miễn" thì một ngoại lệ không có ranh giới sẽ thành tiền lệ cho lần sau.

Nhóm 2: định danh nghiệp vụ do pha 0 sở hữu. Gồm qr_table, staff_pos, phone_preorder (kênh bán, shop-facts.md §5) và trang_banh, gap_banh, don_ban (trạm, §3). Chúng được ghi ra để lượt đo sau không báo nhầm lần nữa.

Nhóm 3: chỗ vi phạm thật. Có ba chỗ, cả ba đều ở architecture.md, còn bảy file kia sạch. Đó là §12.2 dòng 552 và 555–558 (một hợp đồng API bốn dòng), §3.1 dòng 161–163 (UNIQUE trên generated column), và §4 dòng 238 (staff.role).

Bước 7 — git blame: xác định chỗ lỗi thuộc về ai

git blame -L 161,163 --date=short -- docs/product/1-system-design/architecture.md
git blame -L 238,238 --date=short -- ...
git blame -L 552,558 --date=short -- ...
Cả ba chỗ đều trả về commit cf8bd83, ngày 2026-08-31. ADR-035, cái luật mà chúng vi phạm, ra đời 2026-09-04.

Kết quả này đổi hẳn cách hiểu. Đây không phải một bước pha 1 vượt rào. architecture.md được viết trước khi có luật, và khi dựng luật ở P1-01 thì chỉ §8 được viết lại cho khớp; §3.1, §4 và §12.2 không ai rà lại. Nếu bỏ bước blame, báo cáo sẽ viết thành "pha 1 vi phạm luật của chính nó", tức đổ lỗi nhầm chỗ. Luật rút ra là: trước khi viết một chữ nào về một chỗ hỏng, hãy hỏi nó sinh ngày nào, và luật nó vi phạm sinh ngày nào.

Bước 8 — Ghi dữ kiện: hai finding, và không tự sửa gì
F-040 ghi ba chỗ vi phạm, dùng đúng khuôn năm phần (Problem / Impact / Decision-Fix / Related task / Status: Open). Nó viết ra ba hướng xử lý kèm cái giá của từng hướng, nhưng không chọn hướng nào:

Khai thêm vào ngoại lệ: rẻ nhất, nhưng biến ngoại lệ thành cả một vùng được miễn.
Viết lại bằng ngôn ngữ tầng, ví dụ "trạng thái này do cơ sở dữ liệu giữ" thay cho UNIQUE.
Mở pha 3 sớm để chứa hợp đồng API.
Chọn một trong ba là quyết định thiết kế, tức L2, vượt quá bậc của task. Vì vậy đó là quyền của chủ repo.

F-041 ghi rằng Gate 1d bị mù. Mẫu PAT_API đòi dấu / ngay sau động từ HTTP, trong khi tài liệu viết staff/debts. Ngoài ra, dòng ignore duy nhất ghi lý do là "§12.3" trong khi dòng nó che nằm ở §12.2. Finding ghi luôn mẫu sửa đã thử ([A-Za-z/] bắt đúng bốn dòng), nhưng không sửa scripts/. Có hai lý do: scripts/ nằm ngoài scope, và theo §3.8 đây mới là lần đầu vấn đề xuất hiện. Sửa cổng ngay là đúng theo bản năng nhưng sai theo hệ thống, vì nó biến một lượt đo thành một lượt sửa.

Ô 10 được viết thành - [ ] (không tick), kèm "⛔ Để trống — chỗ chặn: F-040", cùng bảng năm lượt lọc với cả hai con số, ba nhóm phân loại và kết quả blame. Có một chi tiết hiếm gặp: biên bản đo lại nằm trong chính tập bị đo (file 07 là một file pha 1). Vì vậy ngay sau khi viết xong, các con số tự thay đổi (2385 thành 2459 dòng, lượt D từ 14 thành 31). Ô 10 tự ghi lại điều này và dặn lượt đo sau phải loại mục này ra trước khi đếm.

Cùng lần sửa đó còn cập nhật mục lục đầu findings.md. Dòng ngay dưới **Status:** phải đúng một chữ Open, vì brief.sh đọc theo đúng hình dạng này. Viết Open — ... thì finding sẽ biến mất khỏi brief.

Bước 9 — Kiểm tra chất lượng: hai tầng
Tầng máy chạy bằng một lệnh:


./scripts/gate.sh
Lệnh này lần lượt chạy:

Gate 3 (check-scope.sh): mọi file đã đổi phải nằm trong scope. Ở ca này, đây là gate chặn việc "tiện tay sửa" architecture.md.
Gate 1b (check-links.sh): mọi đường dẫn trong tài liệu phải mở được.
Gate 1c (check-doc-status.sh): một mã không được mang hai trạng thái ở hai chỗ khác nhau.
Gate 1d (check-phase-boundary.sh): kiểm ranh giới pha.
Gate 1 (verify.sh): được bỏ qua, vì lượt này chỉ đổi tài liệu.
Gate này còn được gắn vào hook Stop với tham số --hook. Khi Claude định kết thúc lượt mà gate đỏ, lượt bị chặn lại (exit 2) và lỗi được trả về cho Claude sửa, nên Claude không tự tuyên bố được là đã xong. Khi gate xanh, Gate 7/7b hỏi tiếp: khối commit đâu, và các file trong khối có nằm trong scope không. Khi người dùng gõ git commit, Gate 8 (hook commit-msg của git) chấm subject.

Tầng tự kỷ luật theo quality/review-gate.md. Với L1, phải qua Gate 1 đến 4.

Gate 2 (Acceptance → bằng chứng). Mỗi dòng Acceptance phải chỉ ra được thứ chứng minh nó. Ở P1-12, ánh xạ như sau:

Acceptance	Bằng chứng
1. Tập bị rà nêu đích danh	output wc -l (8 file, 2385 dòng)
2–3. Năm lượt lọc, mỗi lượt có số chưa lọc	bảng A–E trong ô 10
4. Ba nhóm, không dòng nào lửng	danh sách ba nhóm trong ô 10
5. Mỗi chỗ vi phạm có mục, blame và mã F	output git blame, F-040
6. Pointer	check-links.sh xanh, 196 pointer, 0 trỏ thư mục, 0 neo chết
7. Ô 10 không tick trơn	- [ ] kèm mã chặn F-040
8–9. Bảy file nội dung và scripts/ không đổi	git diff --stat -- docs/.../0*.md .../architecture.md scripts/ → rỗng
10. Mã mới có ở owner và bảng tổng hợp	F-040, F-041 cùng mục lục của findings.md
11. Gate	./scripts/gate.sh xanh
Dòng nào không có bằng chứng thì coi như chưa đạt. Lệnh ở dòng 8–9 rất đáng chú ý: nó chứng minh bằng output rằng Claude không sửa những gì không được sửa.

Gate 4 là rà diff theo một danh sách dấu hiệu nguy hiểm cố định, không đọc kiểu "xem có hợp lý không". Ở lượt này, dấu hiệu đáng lo nhất là có file .md được tạo ra mà không ai yêu cầu.

Gate 6 là không tự chấm bài của mình. Việc quan trọng nên được một phiên khác, không mang context của phiên đã làm, chấm lại dựa trên diff và acceptance.

Bước 10 — Bàn giao
work/backlog.md chuyển P1-12 sang Done. Entry trong backlog_SD.md ghi thẳng câu: "Task Đóng ≠ ô cổng xanh". Nghĩa là việc đã làm xong, nhưng câu trả lời của phép đo là "không", nên cổng vẫn 9/10 và pha 1 chưa đóng. Câu "được, sang pha 2" là chữ ký của chủ repo, không phải hệ quả của một task Done. Scope được dọn. Khối commit được viết từ danh sách git đưa ra chứ không từ trí nhớ, và không có work/scope.txt:


git diff --name-only HEAD
git ls-files --others --exclude-standard

git add docs/product/1-system-design/07-cong-chat-luong-pha-1.md \
  master_plan/SD_master_plan_banh_cuon_ba_thanh.md prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md \
  prompt/SD/README.md work/backlog.md work/backlog_SD.md work/findings.md
git commit -m "P1-12: do ranh gioi pha tren ca pha 1 — o 10 khong tick duoc" -m "..."
Commit thật bf39be5 có đúng 7 file này (+438/−15). Claude chỉ viết khối lệnh; người dùng mới là người chạy git commit.

Hậu truyện. Ngày 2026-09-20, ở task T-079 (ADR-048), chủ repo chọn hướng 2 trong ba hướng của F-040. Ba chỗ được viết lại bằng ngôn ngữ tầng, mẫu của Gate 1d được nới và kèm test hồi quy, và lúc đó ô 10 mới được tick (10/10).

Năm bài học tách khỏi task này vẫn dùng được
Đo và dọn là hai lượt khác nhau. Gộp lại thì mất cả phép đo lẫn quyền quyết định của người sở hữu chỗ bị sửa.
Luôn in con số chưa lọc. Không có nó, câu "không tìm thấy gì" không có nghĩa.
Chạy git blame trước khi kết luận. Chỗ hỏng sinh ra trước luật là nợ từ trước, không phải vi phạm.
Ngoại lệ phải có tên và có ranh giới.
Ô không tick được thì để trống kèm mã chỗ chặn. Giá trị của một cổng nằm ở những lần nó không xanh.
Tôi chỉ đọc, không sửa file nào, nên không có khối commit. Trong lúc đọc tôi thấy hai tài liệu đã cũ so với hôm nay. tom_tat_du_an.md chụp ngày 2026-09-20 nên vẫn ghi "pha 2 chưa mở" và F-034 (finding về việc mất hẳn dữ liệu đã ghi) còn mở. Thực tế pha 2 đã mở, và F-034 đã đóng ở commit b04715c (T-108). Còn workflow-phien-lam-viec.md §2 vẫn xếp schema vào nhóm "chưa có owner", trong khi schema đã có owner từ P2-04. Nếu bạn muốn, tôi có thể mở một task L0/L1 để cập nhật hai chỗ này.
