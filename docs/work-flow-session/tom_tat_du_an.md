# Tóm tắt dự án — Bánh cuốn Bà Thanh Cao Bằng

> Cập nhật theo tài liệu hiện có đến **2026-09-20**. Đây là bản định hướng để
> đọc nhanh; khi cần quyết định hoặc triển khai, luôn đọc tài liệu owner được
> liên kết bên dưới. Một bản tóm tắt không thay thế nguồn sự thật.

## 1. Dự án đang làm gì

Repo này xây một **hệ điều hành phát triển gọn, có AI hỗ trợ** cho sản phẩm bán
hàng và quản trị của **một quán Bánh cuốn Bà Thanh Cao Bằng**. Sản phẩm phục vụ
luồng bán tại quán, mang đi và ba mảng quản trị: nguyên liệu, con người, tài
chính.

Điểm đặc trưng không phải là chọn công nghệ trước, mà là chốt đúng nghiệp vụ,
invariant, ranh giới sở hữu và cách kiểm chứng trước. Hiện repo mới có đặc tả
BA và system design; **chưa có schema, quy ước code, API, route hay mã ứng dụng
thuộc pha 2–5**. Việc tự đặt ra những thứ đó ở pha hiện tại là sai ranh giới.

Nguyên tắc vận hành là:

1. Một dữ kiện chỉ có một owner.
2. Một task chỉ có một outcome.
3. Mọi thay đổi đáng kể có acceptance và bằng chứng kiểm tra.
4. AI không được tự bịa dữ kiện nghiệp vụ.
5. Ceremony tăng theo rủi ro, không theo độ dài diff.

Nguồn quy định cách làm là [CLAUDE.md](../../CLAUDE.md), còn triết lý mức rủi
ro nằm ở [README.md](../../README.md).

## 2. Bức tranh quán và phạm vi bán hàng

| Hạng mục | Đã chốt |
|---|---|
| Giờ và địa điểm thời gian | Bán mỗi ngày 06:00–11:00, múi giờ `Asia/Ho_Chi_Minh`. Ngày bán dùng để cộng tiền là ngày lịch 00:00–24:00 theo múi giờ quán, không phải ca bán. |
| Bàn và thanh toán | 15 bàn, mỗi bàn 4 chỗ, đánh số 1–15. Nhận tiền mặt và VietQR tĩnh; quầy tự nhìn báo có rồi xác nhận, hệ thống không tự biết tiền đã vào tài khoản. |
| Hạ tầng đang biết | Một VPS chạy hệ thống; Telegram báo đơn web mới về quầy. Chi tiết triển khai/cấu hình vẫn thuộc pha sau. |
| Trạm và người | Năm trạm: quầy, tráng bánh, gấp bánh, lấy canh, dọn bàn. Có bốn vai người vì lấy canh và dọn bàn chung một người; chủ quán là vai riêng nhưng có thể đứng quầy. |
| Giao hàng | Quán tự giao. Người đi giao thuộc một trong ba vai không phải quầy; POS chỉ định. Người đứng quầy không đi giao, và quầy gánh trạm bị bỏ trống khi có người đi giao. |

Mọi số liệu và luật vận hành của quán chỉ lấy từ
[shop-facts.md](../../master_plan/shop-facts.md), không lấy từ bản sao trong
prompt, kế hoạch hay tài liệu cũ.

### Năm kênh bán là danh sách đóng

| Kênh | Khởi tạo | Đơn vị tính tiền | Duyệt trước khi xuống bếp |
|---|---|---|---|
| `qr_table` | Khách quét QR tại bàn | Phiên bàn | Có |
| `staff_pos` | Nhân viên đặt hộ tại quán | Phiên bàn | Không |
| `delivery` | Khách đặt web, giao tận nơi | Đơn riêng | Có |
| `pickup` | Khách đặt web, tới lấy | Đơn riêng | Có |
| `phone_preorder` | Nhân viên nhập khi khách gọi | Đơn riêng | Không |

Hai kênh gắn bàn gộp mọi lượt gọi của cùng bàn vào **một phiên, một hoá đơn**.
Ba kênh còn lại không gắn bàn, mỗi đơn thu tiền độc lập. `pickup` và
`phone_preorder` bắt buộc có giờ hẹn; các đơn không gắn bàn cần số điện thoại,
và giao tận nơi cần địa chỉ. Khách đặt trước qua điện thoại rồi tới ngồi ăn thì
huỷ đơn đó và gọi lại qua QR, không chuyển đơn sang phiên bàn.

Chi tiết hành vi thuộc [BA §1–§3](../product/0-ba/ban-hang/01-actors-pham-vi.md)
và [dữ kiện quán §2, §5](../../master_plan/shop-facts.md).

### Hai luồng bán và trục sản xuất

```text
Ăn tại bàn: QR / POS → phiên bàn → quầy xác nhận → các trạm → thu tiền/ghi nợ
             → đóng phiên → dọn bàn → bàn trống

Mang đi: delivery / pickup / hotline → (quầy duyệt nếu khách tự gửi) → các trạm
          → đóng gói → giao hoặc khách lấy → thu tiền → đơn đóng

Sản xuất: đơn đã duyệt → nhu cầu theo thành phần → người tự gom mẻ → làm xong
           → phục vụ từng bàn
```

Sản xuất không phải trạng thái phụ của đơn. Hệ thống cộng nhu cầu theo **thành
phần + loại nhân + lượng nhân** trên nhiều bàn, nhưng luôn phải tách ngược được
về từng bàn. Máy chỉ hiển thị nhu cầu; con người quyết định gom mẻ, xếp nồi và
thứ tự làm. Bảng quầy phân biệt bốn số: khách đã gọi, đã làm xong còn ở bếp, đã
phục vụ, và còn thiếu. POS là nơi duy nhất ghi tiến độ làm/đã phục vụ; màn trạm
bếp chỉ đọc. Một đơn mang đi không vào bảng theo bàn, còn suất đem về của khách
đang ngồi bàn vẫn thuộc phiên bàn và phải có note rõ ràng.

Nguồn: [lát cắt sản xuất theo mẻ](../product/0-ba/ban-hang/03-lat-cat.md),
[quy tắc vận hành §5](../../master_plan/shop-facts.md),
[architecture §1–§3](../product/1-system-design/architecture.md).

### Menu, giá và tiền

- Giá suất là **tổng giá thành phần bếp làm ra**. Giá thành phần hiện theo ba
  mức chay/thịt thường/thịt nhiều; phụ thu là +1.000đ cho mỗi phần nhận nhân.
  Khách không gửi hoặc quyết định giá; hệ thống phải tính lại.
- Menu có bánh cuốn, suất giò, combo đầy đủ (trứng chín/tái/vàng), suất trứng
  (chín/tái/vàng), giò bán rời và canh bánh cuốn. Canh là dòng khách chọn số
  lượng, giá 0đ, không tự kèm theo bất kỳ suất nào. Giá giò bán rời 9.000đ là
  kết quả suy ra từ luật thành phần, chưa phải lời đọc trực tiếp của chủ quán.
- `Chay + Nhiều nhân` là tổ hợp không hợp lệ và phải bị từ chối. Khi chủ quán
  đổi giá giữa buổi, mỗi dòng đã tạo giữ giá tại mốc của nó; **riêng dòng được
  POS sửa** lấy giá đang hiệu lực lúc sửa và phải lưu giá cũ/mới.
- Một lần thu có thể chia tiền mặt và VietQR, nhưng phải lưu từng phần. Đơn mang
  đi được chọn trả trước; khách tại bàn không có nhánh này.
- Khách không trả được thì quán cho nợ: phiên vẫn đóng nhưng bắt buộc lưu người
  nợ và số tiền. Hoàn tiền, sửa/hủy đơn và các quyết định ngoại lệ do POS quyết
  theo từng ca, nhưng phải có vết truy nguyên.
- Đối soát cuối ngày có ngưỡng lệch 0đ và tách theo phương thức: tiền mặt đối
  chiếu két, VietQR đối chiếu tin nhắn báo có, đồng thời đối chiếu sổ giấy. Nợ,
  trả nợ, hoàn tiền và trả trước khác ngày giao đều phải xuất hiện đúng dòng để
  không làm doanh thu bị tính hai lần hoặc che mất lệch.

Xem [giá và thanh toán](../product/0-ba/ban-hang/04-gia-thanh-toan.md),
[vòng đời](../product/0-ba/ban-hang/05-vong-doi.md),
[dữ kiện menu/tiền](../../master_plan/shop-facts.md).

## 3. Mảng quản trị và phạm vi MVP

Nguyên liệu, con người và tài chính đều **nằm trong phạm vi phần mềm**, nhưng
không mảng nào bắt buộc phải đi cùng bản bán hàng đầu tiên. Mảng này chưa có đủ
luật để thiết kế/thi công rộng.

- **Nguyên liệu** đã chốt ở mức “sổ ghi tay điện tử”: người nhập số mua vào và
  đã dùng theo ngày; máy lưu, cộng và hiện số thiếu bằng phép trừ. Máy không tự
  quy đơn bán ra lượng nguyên liệu, không đặt ngưỡng, không tự kết luận sắp hết.
  Danh mục mới là danh sách mở; đơn vị tính còn chưa chốt.
- **Con người** và **tài chính** mới mở ranh giới, phần lớn luật chi tiết vẫn
  cần chủ quán trả lời. Mục tổng quan chủ quán muốn thấy tiến độ phục vụ, doanh
  số tạm tính, số người đang làm và các dạng thiếu, nhưng một số nguồn dữ liệu
  của các con số này còn thiếu.
- Ngoài phạm vi đã chốt: kênh bán thứ sáu, phí/đơn tối thiểu giao hàng, số tài
  khoản ngân hàng hard-code, món ngoài bảng giá; máy tự gom mẻ hay xếp nồi; và
  hệ thống trở thành phương án bán hàng duy nhất khi mất điện/mạng.

Nguồn: [ranh giới admin](../product/0-ba/admin/01-ranh-gioi.md),
[MVP](../product/0-ba/ban-hang/07-pham-vi-mvp.md),
[dữ kiện admin §8](../../master_plan/shop-facts.md).

## 4. Thiết kế pha 1 đã chốt

Kiến trúc có **một miền nghiệp vụ, ba mặt**: POS/quầy ghi mọi biến động nghiệp
vụ; bếp hiển thị việc chỉ đọc; chủ quán cấu hình menu/giá/người và xem báo cáo,
đối soát. Những luật quyết định tiền, gộp phiên, nổ thành phần, quyền duyệt/hủy/
hoàn, chặn giờ bán và tổ hợp menu đều phải giữ ở phía nghiệp vụ, không tin vào
frontend.

Pha 1 đã xác định:

- Sáu phụ thuộc ngoài và đường suy giảm tương ứng: điện/mạng/POS tại quán, nơi
  hệ thống chạy, ngân hàng/VietQR, tin nhắn báo có, đường báo đơn web và sổ giấy.
  Mất điện/mạng/máy không làm quán ngừng bán: chuyển sang sổ giấy và nhập bù.
- Hai đường tới màn trạm: đường đẩy để cập nhật ngay và đường kéo tự chạy làm dự
  phòng. Màn rỗng phải phân biệt hết việc với không lấy được dữ liệu.
- Bốn ràng buộc chỉ được nới khi có dấu hiệu đo được: một tiến trình đường đẩy,
  không hàng đợi cho thao tác ghi, không cache menu/giá, một nơi chạy hệ thống.
- Năm tầng bảo vệ invariant: cơ sở dữ liệu, giao dịch, miền nghiệp vụ, người +
  thủ tục, và phép đối chiếu sau khi hỏng. `quality/invariants.md` hiện có
  `I-001` đến `I-021`, phủ bàn/phiên, đơn/trạm, giá/vết, sản xuất theo mẻ và két.
- Pha 2 sẽ nhận các yêu cầu hình dạng dữ liệu (`YC-01`…`YC-20`): phải lưu được
  vết hoàn tiền, nợ, vết cập nhật, trực trạm theo thời điểm, suất đem về, phân
  bổ theo bàn, mẻ, nhập bù sổ giấy và mốc tiền. Đây là yêu cầu nghiệp vụ, chưa
  phải tên bảng/cột.

Tài liệu gốc: [architecture](../product/1-system-design/architecture.md),
[ranh giới hệ thống](../product/1-system-design/01-ranh-gioi-he-thong.md),
[ngày bán](../product/1-system-design/02-thoi-gian-ngay-ban.md),
[bảo vệ invariant](../product/1-system-design/03-bao-ve-invariant.md),
[yêu cầu dữ liệu](../product/1-system-design/04-yeu-cau-du-lieu.md),
[realtime/dự phòng](../product/1-system-design/05-realtime-va-du-phong.md).

## 5. Trạng thái dự án

| Hạng mục | Trạng thái hiện tại |
|---|---|
| BA bán hàng | Đã có đủ §1–§8, bốn lát cắt, 3 scenario nghiệm thu và cổng BA 9/9. |
| Pha 1 — System design | 14 bước P1 đã có đầu ra; cổng pha 1 đã đạt **10/10** ngày 2026-09-20 sau T-079. Việc ký “được sang pha 2” vẫn là quyền của chủ repo, không phải hệ quả tự động của các ô xanh. |
| Pha 2 — DB | Chưa mở; đây là pha đầu tiên được sở hữu schema, tên bảng/cột, khóa và quy ước code. |
| Pha 3 — Backend | Chưa mở; mới được sở hữu hợp đồng API và cơ chế cụ thể. |
| Pha 4 — Frontend | Chưa mở; mới được sở hữu route, component và cách trình bày màn hình. |
| Pha 5 — Deploy | Chưa mở; mới chọn cách chạy/vận hành cụ thể. |
| Task đang chạy | Không có task `In Progress`; `work/scope.txt` đang sạch, chỉ còn comment. |

Nguồn trạng thái task là [work/backlog.md](../../work/backlog.md), không phải
hai backlog mô tả dài. Mục lục pha ở [docs/product/00-index.md](../product/00-index.md)
vẫn ghi pha 0 và 1 là “đang mở”, vì admin và quyết định chuyển pha chưa được
đóng bằng một thao tác ký riêng.

### Công việc sẵn sàng tiếp theo

**Cả hai task Ready của lane admin đã xong ngày 2026-09-20**: `ADM-53` (đưa hai
lời chốt Đ-2 · Đ-4 về owner, và hỏi được `C36`) rồi `ADM-21` (đưa lời `C36` về
owner — mỗi lần đổi người **ở quầy** là một mốc có giờ, `master_plan/shop-facts.md`
§8.8). Lane admin vì thế **không còn việc nào nhận được ngay**: việc mở lại nó là
một lượt **hỏi chủ quán**, không phải một lượt viết.

Trạng thái task đọc ở [work/backlog.md](../../work/backlog.md); mô tả dài ở
[work/backlog_AD.md](../../work/backlog_AD.md). Hai prompt đã chạy:
[ADM-53](../../prompt/AD/ADM-53-hai-loi-ve-owner-L1.md) ·
[ADM-21](../../prompt/AD/ADM-21-loi-c36-ve-owner-L2.md).

## 6. Các điểm còn mở cần biết

### Câu hỏi cần chủ quán quyết

1. **U-053** — khi quán mất mạng hẳn, POS không thấy thông báo và không bấm được,
   ba kênh khách tự bấm có tự dừng không? Đây chặn cơ chế backend cho invariant
   không nhận đơn vào quán đang mù.
2. **U-054** — “tổng đã nhập trừ tổng đã dùng” của nguyên liệu cộng dồn từ mốc
   nào: từ đầu sổ, đầu tháng hay trong ngày? Câu này chặn nghĩa của số thiếu trên
   tổng quan admin.
3. **U-055** — bốn trạm ngoài quầy có ghi mốc đổi người không, hay chỉ trạm quầy?
   Lời chốt `C36` (2026-09-20) phủ đúng trạm quầy; câu này chặn con số *bao nhiêu
   người đang làm* của tổng quan admin.
4. **U-056** — ai khai cái mốc đổi người ở quầy: người vào, người ra, hay POS?
5. **U-057** — hai cửa ghi ngoài quầy (người đi giao bấm đã thu tiền, chủ quán đổi
   giá) lấy tên người từ đâu? Câu này chặn vế *ai* của vết thao tác.

Đọc nguyên văn và người trả lời ở [Unknowns](../product/99-unknowns.md), không
đoán từ bản tóm tắt này.

### Điều suy ra nhưng chưa xác nhận

Năm mục `S-5`…`S-9` trong [nhật ký suy ra](../../master_plan/shop-facts.md) chưa
phải lời chốt: đơn vị bấm “đã bưng ra bàn”; thời điểm POS bấm mốc đó cho đơn giao;
cách hiểu 06:00–11:00 là một buổi; liệu tổng quan hiển thị cả ba dạng thiếu; và
giá 9.000đ của giò bán rời. Khi chạm một mục, phải hỏi chủ quán hoặc ghi rõ phần
để trống — không coi nó là requirement đã chốt.

### Nợ thiết kế/cơ chế đã được ghi nhận

Các finding quan trọng còn mở gồm: cơ chế tránh mất hẳn bản ghi đã ghi (`F-034`),
phép đối chiếu invariant chưa phủ hết vế (`F-036`), thiếu dòng trả trước trong
đối soát (`F-037`), và thiếu mệnh đề/tầng bảo vệ cho trường liên hệ bắt buộc
(`F-038`). Ngoài ra còn các bài toán vận hành tài liệu/commit song song và chỉ
mục cũ. Đọc [Findings](../../work/findings.md) trước khi nhận task liên quan.

Lưu ý: bảng mục lục finding đầu file chưa cập nhật trạng thái `F-040`/`F-041`,
nhưng nội dung gốc của cả hai ghi **Closed, 2026-09-20, T-079**. Trạng thái thực
tế phải đọc ở mục finding tương ứng và backlog; không dùng bảng chỉ mục cũ để
kết luận chúng còn mở.

## 7. Bản đồ tài liệu: đọc đâu khi cần gì

| Cần biết | Owner cần mở |
|---|---|
| Dữ kiện quán, giá, menu, luồng vận hành | [master_plan/shop-facts.md](../../master_plan/shop-facts.md) |
| Hành vi sản phẩm BA theo pha | [docs/product/00-index.md](../product/00-index.md) rồi file mục tương ứng |
| Câu hỏi nghiệp vụ chưa có lời | [docs/product/99-unknowns.md](../product/99-unknowns.md) |
| Cấu trúc, ranh giới, realtime, yêu cầu pha 1 | [docs/product/1-system-design/](../product/1-system-design/architecture.md) |
| Lý do của lựa chọn kiến trúc/quy trình | [docs/decisions.md](../decisions.md) |
| Invariant nghiệp vụ | [quality/invariants.md](../../quality/invariants.md) |
| Trạng thái task | [work/backlog.md](../../work/backlog.md) |
| Mô tả dài task pha 1 / admin | [work/backlog_SD.md](../../work/backlog_SD.md) / [work/backlog_AD.md](../../work/backlog_AD.md) |
| Bài học và lỗi lặp | [work/findings.md](../../work/findings.md) |
| Prompt đã chuẩn bị | [prompt/](../../prompt/) — chỉ mô tả task, không sở hữu sự thật nghiệp vụ |

`docs/product.md`, `master_plan/00-scope.md`, các bản kế hoạch/ảnh chụp cũ và
`work/proposals/` không phải owner của fact hiện hành. Chúng chỉ dùng để tra lịch
sử, định tuyến hoặc đọc đề xuất chưa được nhận.

## 8. Một phiên làm việc phải diễn ra thế nào

Với thay đổi từ L1 trở lên, luồng chuẩn là: brief tự đến → chọn level theo hậu
quả → mở đúng owner → khai scope trước khi sửa → làm một task → ghi unknown,
finding hoặc ADR ngay vào đúng nhà → chạy `./scripts/gate.sh` → bàn giao khối
commit dán được. Không tự commit nếu người dùng chưa yêu cầu.

Các gate tự động kiểm scope, link tài liệu, trạng thái mã, ranh giới pha, build/
test khi có code và nội dung khối commit. Review còn phải ánh xạ từng acceptance
với bằng chứng thật; output lệnh mới là bằng chứng, không phải câu “đã test”.

Đọc [workflow phiên làm việc](workflow-phien-lam-viec.md),
[ví dụ P1-12](vi-du-mot-task-chay-that-P1-12.md),
[prompt guideline](../prompt-guideline.md) và
[review gate](../../quality/review-gate.md) trước khi vận hành repo lần đầu.


đánh giá về cách xây hệ thống
Đánh giá ngắn: cách xây hệ thống này rất mạnh ở phần làm rõ nghiệp vụ, kiểm soát rủi ro và tránh AI tự bịa; khoảng **8/10 cho giai đoạn khám phá/thiết kế**. Nó chưa thể được chấm về chất lượng sản phẩm chạy thật vì pha DB, backend, frontend và deploy chưa mở.

Điểm mạnh lớn nhất là kỷ luật “một fact, một owner”. Dữ kiện quán, hành vi BA, invariant, ADR, task và finding đều có nơi sở hữu rõ; điều này đặc biệt phù hợp với bài toán tiền, đơn hàng và nhiều quyết định vận hành thủ công. Ba scenario BA, 21 invariant, đường suy giảm khi mất điện/mạng và đối soát lệch 0đ cho thấy thiết kế bám sát quán thật, không chỉ vẽ kiến trúc đẹp. Cổng pha 1 đạt 10/10 cũng cho thấy ranh giới pha đã được rà kỹ.

Kiến trúc lựa chọn khá đúng tỷ lệ với quán nhỏ: một miền nghiệp vụ, POS là cửa ghi chính, bếp chỉ đọc, realtime có đường kéo dự phòng, vẫn bán bằng sổ giấy khi hệ thống hỏng. Việc không vội chọn schema, API hay công nghệ trước pha tương ứng là một điểm tốt.

Điểm yếu chính là chi phí tài liệu và điều hướng đã cao. Một số tài liệu là ảnh chụp lịch sử hoặc chỉ mục cũ, thậm chí bảng mục lục finding chưa phản ánh trạng thái đóng của F-040/F-041. Điều đó không làm sai owner gốc, nhưng làm người mới dễ đọc nhầm. Nếu tiếp tục tăng độ dài mà không tối giản đường vào, hệ thống sẽ tốn thời gian “vận hành tài liệu” hơn xây sản phẩm.

Các rủi ro cần xử lý trước khi mở pha 2/3 là `U-053` (dừng đơn web khi quán mất mạng hẳn), `F-034` (chống mất hẳn bản ghi), `F-037` (trả trước trong đối soát), `F-038` (trường liên hệ bắt buộc), cùng các suy ra `S-5`/`S-6` chạm trực tiếp tới tiến độ phục vụ. Đây là các chỗ có thể gây mất đơn, sai tiền hoặc vận hành không thống nhất.

Khuyến nghị: chủ repo nên ký rõ quyết định chuyển pha 1 → pha 2, sau đó mở pha DB với phạm vi tối thiểu, dùng trực tiếp `YC-01…YC-20` và invariant làm acceptance. Đồng thời tạo task riêng để dọn các chỉ mục trạng thái cũ; không nên tiện tay sửa trong task DB.