# Đọc một prompt cụ thể và nạp brief — ví dụ P1-12

Tài liệu này được viết ngày 2026-10-05 theo yêu cầu của chủ repo: lấy một
prompt cụ thể, giải thích cách hiểu yêu cầu và cách nạp context theo hướng dẫn
trong thư mục `docs/private/work-flow-session/`. Đây là ví dụ hướng dẫn, không
phải phiếu giao chạy lại P1-12 và không sở hữu trạng thái hay luật nghiệp vụ.
Luật hiện hành lấy ở [CLAUDE.md](../../../CLAUDE.md); trạng thái task lấy ở
[work/backlog.md](../../../work/backlog.md).

## 1. Prompt được chọn và yêu cầu cụ thể

Tôi chọn [prompt P1-12 — rà chéo ranh giới pha](../../../prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md)
vì thư mục đã có [bản phân tích ca chạy thật](guidline/vi-du-mot-task-chay-that-P1-12.md).
Có thể đối chiếu yêu cầu trước khi làm với kết quả sau khi làm, thay vì tự dựng
một kết quả giả định.

Đây là đoạn **Goal nguyên văn** trong prompt được chọn:

> Ô **10** của cổng chất lượng pha 1 hết là *"chưa ai đo"* và trở thành *"đã đo, và đây là cái đo
> được": một phép đo chạy trên **cả tám** file pha 1, dán **cả lệnh chưa lọc lẫn lệnh đã lọc**, mỗi
> chỗ lọt ra hoặc là **ngoại lệ có tên**, hoặc có **một mã** và **một owner**.

Chỉ đọc đoạn này thì chưa đủ để thực hiện. Phải đọc cả Context, Scope,
Constraints, Unknowns, Acceptance, Verify và Report trong file prompt.
Mỗi phần giải quyết một câu hỏi khác nhau; Goal cho biết đầu ra cần tạo,
còn Scope quyết định được sửa ở đâu.

## 2. Tôi hiểu prompt như thế nào?

**Vấn đề cần trả lời.** Tài liệu pha 1 có chứa nội dung thuộc quyền của pha
sau hay không? Gate tự động chỉ kiểm một phần nên task yêu cầu một phép rà
bổ sung trên toàn bộ tập được chỉ định. Tôi phải đo và phân loại, không được
mặc định rằng gate xanh có nghĩa tập tài liệu đã sạch.

**Đầu ra phải tạo.** Kết quả đo được ghi tại §7, ô 10 của cổng chất lượng pha
1, có tập file, lệnh, số liệu, phân loại và căn cứ. Nếu vẫn có vi phạm thì để
ô trống kèm lý do là một kết quả hợp lệ. Hoàn thành phép đo không đồng nghĩa
với sửa xong lỗi, và cũng không tự cho phép chuyển pha.

**Phạm vi đọc, rà và sửa.** Tôi có thể đọc các owner để hiểu luật và ý nghĩa
định danh. Tập phải rà là tám file pha 1 của ca lịch sử. Trong tập đó, chỉ ô
10 được sửa để ghi kết quả; bảy file nội dung phải giữ nguyên. Những quyền
cập nhật phụ trợ phải đọc theo từng điều kiện trong Scope, không coi danh
sách file là yêu cầu phải sửa tất cả.

**Các giới hạn quan trọng.** Không sửa script để kết quả đẹp hơn; không xoá
nội dung vi phạm trong kiến trúc; không coi mọi chuỗi `snake_case` là tên bảng;
không bỏ ngoại lệ mà không giải thích. Riêng ngoại lệ §12.3 được prompt lịch
sử chỉ tên phải được đối chiếu căn cứ và giới hạn của nó. Khi áp dụng hôm nay,
phải kiểm tra owner hiện hành, không mặc định ngoại lệ cũ còn nguyên.

**Cách kiểm chứng.** Acceptance yêu cầu ít nhất năm họ mẫu, số liệu chưa lọc
đi cùng số liệu đã lọc, phân loại mọi chỗ khớp, truy nguồn chỗ vi phạm bằng
`git blame`, kiểm tra pointer và chạy gate. Một output rỗng chỉ có ý nghĩa
khi biết lệnh đã chạy trên đúng tập và bộ lọc không che mất kết quả.

**Vai trò của tôi.** Nếu thực hiện qua phiếu việc từ Claude, Codex làm trong
scope của phiếu và báo lại phần cần người dẫn việc xử lý. Nếu chủ repo giao
trực tiếp một task nhỏ L0/L1, quyền cập nhật task theo §7.4 của `CLAUDE.md`
được áp dụng. Cả hai trường hợp đều không cho Codex quyết định nghiệp vụ hay
tự commit. Prompt lịch sử không mở rộng quyền hiện hành.

Sau khi đọc, tôi có thể diễn đạt nhiệm vụ bằng một câu: **“Đo ranh giới trên
đúng tập tài liệu, ghi bằng chứng và chuyển chỗ sai về đúng người xử lý; không
biến lượt đo thành lượt sửa thiết kế.”** Đây là cách hiểu công việc được giao,
chưa phải kết luận rằng đã chạy hay đã đạt Acceptance.

## 3. Nạp brief thực tế bằng cách nào?

Trong Codex, tôi đọc `CLAUDE.md` rồi chủ động chạy lệnh dưới đây tại repo.
Hook của Claude không thay bước này cho Codex.

```bash
./scripts/brief.sh
```

“Nạp brief” nghĩa là lấy output của lệnh vào context làm việc, đọc từng mục
để xác định trạng thái và nguồn cần mở tiếp. Nó không chỉ là chạy lệnh rồi
nhìn mã thoát. Header của [scripts/brief.sh](../../../scripts/brief.sh) quy định
brief luôn thoát 0, nên exit 0 không chứng minh đã có đủ thông tin để làm task.

Tôi dùng brief theo trình tự sau:

1. Đọc **IN PROGRESS** để nhận biết công việc đang dở; đối chiếu với việc
   người dùng vừa giao trước khi bắt đầu chỉnh sửa.
2. Đọc **DECLARED SCOPE** để biết phạm vi các task và cảnh báo scope còn lại.
   Không tự xoá scope người khác vì thấy task không còn In Progress; task
   Done nhưng chưa commit vẫn cần giữ scope theo luật hiện hành.
3. Đọc **NEXT READY** để định hướng khi chưa có việc được chỉ định. Trong
   phiên này, người dùng đã yêu cầu viết tài liệu nên tôi không nhặt task
   Ready khác để làm thay.
4. Đọc **OPEN FINDINGS**, **OPEN UNKNOWNS** và **LATEST DECISIONS** để phát hiện
   phần cần tra thêm. Tiêu đề chỉ là con trỏ; nếu cần dùng nội dung làm căn
   cứ thì phải mở mục đầy đủ trong owner. Khi có `→ ĐÃ CẮT`, mở nguồn được
   chỉ ra thay vì coi phần đã in là toàn bộ danh sách.
5. Đọc **RECENT COMMITS**, **OWNER FILES** và **UNCOMMITTED** để nhận biết
   trạng thái vừa thay đổi và công việc có sẵn. Sau đó kiểm tra Git trực tiếp
   để biết nhánh, diff và staged index.

```bash
git branch --show-current
git status --short
git diff --name-only HEAD
git diff --cached --name-only
```

Brief là bảng chỉ đường. Nó không nạp tự động toàn bộ các owner và không thay
cho việc đọc prompt. Sau context loss hoặc bàn giao, Codex phải chạy lại brief;
cũng chạy lại khi có căn cứ cho rằng trạng thái repo đã thay đổi.

## 4. Sau brief, mở file nào và vì sao?

Với ví dụ P1-12, trước hết tìm đúng dòng task và entry mô tả dài, rồi đọc
prompt mà entry dẫn tới. Có thể dùng các lệnh đọc sau:

```bash
rg -n 'P1-12' work/backlog.md work/backlog_SD.md
cat prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md
```

Kết quả tìm kiếm chỉ cho vị trí; cần đọc trọn khối P1-12, không lấy một dòng
khớp làm toàn bộ context. `work/backlog.md` xác nhận trạng thái, còn
`work/backlog_SD.md` giải thích nhiệm vụ và lưu kết quả lịch sử. Trong lần
đọc ngày 2026-10-05, dòng task cho biết P1-12 đã Done ngày 2026-09-16. Do đó
tài liệu này phân tích task đã chạy, không chuyển nó về In Progress.

Tiếp theo, chỉ mở nguồn trả lời câu hỏi đang thiếu. Luật phân pha dẫn tới
quyết định tương ứng trong `docs/decisions.md`; nơi ghi kết quả là
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md`; giới hạn bộ kiểm
đọc ở `scripts/check-phase-boundary.sh` và file ignore của nó. Nếu cần phân
biệt tên kênh bán với tên bảng, đọc mục liên quan của `master_plan/shop-facts.md`.
Các mục kế hoạch và kiến trúc mà Context của prompt chỉ ra cũng cần đọc khi
thực hiện phép đo. Đọc những nguồn ấy không cấp quyền sửa chúng.

Tôi dừng mở thêm context khi đã hiểu từng Acceptance, xác định được nguồn
căn cứ và giới hạn chỉnh sửa. Nếu còn thiếu, tôi nói rõ câu hỏi chưa trả lời
được để chọn file tiếp theo. Không đọc toàn repo chỉ vì cùng nói về một quán.

## 5. Hai tình huống giúp thấy cách hiểu được áp dụng

Giả sử bộ lọc bắt được `qr_table`. Tôi chưa gọi đó là lỗi. Trước hết đọc đoạn
chứa nó, rồi đối chiếu owner để biết đây là định danh kênh bán hay tên bảng
đang được mô tả. Nếu căn cứ xác nhận là định danh nghiệp vụ, ghi vào nhóm
tương ứng; không xoá chuỗi chỉ vì có dấu gạch dưới.

Giả sử bộ lọc bắt được `staff.role`. Tôi cũng không sửa ngay thành một câu
khác. Cần đọc ngữ cảnh để biết có thật đang quy định bảng/cột không, đối
chiếu luật và ngoại lệ, rồi dùng `git blame` xác định nguồn gốc nếu là vi
phạm. Kết quả được ghi nhận theo quyền của lượt làm; phương án sửa thuộc
lượt xử lý riêng. Đây là minh hoạ cách đọc ứng viên, không phải bằng chứng
đã chạy lại bộ lọc trong phiên viết tài liệu này.

## 6. Phân biệt ca lịch sử với cách làm hôm nay

[Workflow phiên làm việc](guidline/workflow-phien-lam-viec.md) và
[ca chạy thật P1-12](guidline/vi-du-mot-task-chay-that-P1-12.md) giúp giải thích
quy trình, nhưng có nội dung thuộc thời điểm cũ. Ví dụ, prompt P1-12 còn nói
thêm khối vào `work/scope.txt`. Luật hiện hành dùng một file
`work/scope/<ID>.txt` cho mỗi task; file scope chung chỉ còn là stub comment.
Không sao chép cách khai cũ vào một task mới.

Tương tự, [bản tóm tắt dự án](guidline/tom_tat_du_an.md) không thay cho trạng
thái hôm nay. Khi cần biết pha nào đã mở hoặc task nào còn chờ, lấy brief mới
rồi đọc owner. Nếu một prompt cũ cần thực hiện lại mà phạm vi hay căn cứ đã
khác, người dẫn việc phải xác nhận yêu cầu áp dụng cho lượt mới.

## 7. Kiểm tra và bàn giao khi thực hiện một task thật

Sau thay đổi, chạy `./scripts/gate.sh`, đọc cả PASS, FAIL, SKIP và NOTE.
Gate xanh phải đi cùng bằng chứng cho từng Acceptance; riêng P1-12 còn có
phép đo thủ công mà gate không thay thế được. Báo cáo kết quả phải phân biệt
việc đã hoàn thành, lỗi còn tồn tại và quyền ký chuyển pha của chủ repo.

Codex chạy gate trực tiếp chỉ chạy các bước 1–6. Gate 7/7b dựa trên transcript
không chạy trong cách gọi này, nên khi bàn giao phải tự kiểm danh sách file,
scope áp dụng và staged index theo `CLAUDE.md` §6.1. Chỉ lấy file của task
từ Git thực tế để viết khối commit; giữ nguyên công việc người khác. Codex
không chạy `git commit`.

Riêng phiên tạo tài liệu này chỉ bổ sung một bài giải thích được chủ repo yêu
cầu, không đổi quy trình, trạng thái P1-12 hay các owner nghiệp vụ. Các lệnh
Verify trong prompt lịch sử được giải thích để người đọc hiểu cách kiểm chứng;
không được coi chúng là những phép đo đã chạy trong phiên này.
