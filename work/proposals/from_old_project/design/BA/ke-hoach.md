# Kế hoạch hoàn thành phần BA cho dự án này

> Cập nhật **2026-08-19** · Lane sở hữu: **BA** (`T-BA-01` đã dựng lane, 2026-08-18).
> Nền lý thuyết ở [nghien-cuu-vai-tro.md](nghien-cuu-vai-tro.md) — không chép về đây.
> **File này là kế hoạch, không phải nhà của sự thật nào.** Nó giữ đúng hai thứ chưa có ở đâu khác:
> **lý do của từng bước + thứ tự**. Mỗi bước đã thành **một dòng trong
> [task_BA.md](task_BA.md)** — sổ task của lane BA (mỗi lane một sổ riêng, [§2](../../CLAUDE.md)) —
> và nội dung từng bước rơi vào nhà ghi ở ô *Đầu ra*. Trạng thái ✅ và biên nhận **chỉ** nằm ở sổ task;
> đọc file này để biết *vì sao*, đọc [task_BA.md](task_BA.md) để biết *xong chưa* ([§2.1](../../CLAUDE.md)).

## 0. Kế hoạch này đứng ở đâu trong bức tranh lớn

[project_preparation/prompt-fullstack.md](../../project_preparation/prompt-fullstack.md) §7 đã chia cả
dự án thành **6 pha**: `0·BA → 1·System design → 2·DB → 3·BE → 4·FE → 5·Deploy`. **BA không phải việc
thêm vào — nó là pha 0**, và §5.2 của file đó liệt kê `BA` ngang hàng `DB/BE/FE/DevOps` trong danh sách
tầng. Đây là bằng chứng mạnh nhất cho hướng (b) ở Bước 0: BA đã được thiết kế như một lane, chỉ là
chưa ai dựng nhà cho nó.

**Pha 0 có đầu ra bắt buộc, đã chốt sẵn** (§7 của file đó) — kế hoạch này chỉ là cách đi tới đó:

| Đầu ra bắt buộc của pha 0 | Bước tương ứng dưới đây |
|---|---|
| 4 kênh bán | B3.1 |
| **2 sơ đồ luồng** (tại bàn · ship) | B3.1 |
| Danh sách quy tắc nghiệp vụ | B4.2 |
| **Trả lời 3 câu chưa rõ** ở §3.2, hoặc ghi `GIẢ ĐỊNH:` + mức rủi ro | B1.1 |

Ngoài ra mọi pha đều phải giao thêm **master task của pha** (§5) và **cổng chất lượng của pha** (§6).

### Ranh giới cứng của pha BA — đọc trước khi viết dòng nào

§7 của prompt-fullstack ra một luật mà kế hoạch bản trước của tôi **đã vi phạm**:

> *"pha 0–1 **không** nhắc tên bảng; pha 2 không nhắc endpoint; pha 3 không nhắc component"*

Nghĩa là sản phẩm BA phải viết **bằng ngôn ngữ quán**, không bằng ngôn ngữ schema: nói *"phiên bàn"*
chứ không nói `table_sessions`; nói *"vết đổi trạng thái"* chứ không nói `order_status_history`.
Không phải hình thức — đây là cổng chặn: BA mà đã nghĩ bằng tên bảng thì nó chép lại thiết kế DB có
sẵn thay vì kiểm tra xem thiết kế ấy có khớp quán thật không, và bước kiểm tra đó chính là lý do pha 0 tồn tại.

### Lối thoát khi không hỏi được owner

§4.10 của prompt-fullstack cho sẵn: thiếu dữ kiện ⇒ ghi **một dòng `GIẢ ĐỊNH:` + mức rủi ro**, rồi làm
tiếp. Không phải đứng chờ, cũng không phải đoán im lặng. Mọi bước "cần owner" dưới đây đều dùng lối
thoát này — trừ **B1.1**, vì [F-68](../../finding.md#f-68) đã ghi rõ giá của việc đoán sai ở đúng chỗ ấy.

## 1. Đọc từng bước thế nào

Mỗi bước viết đúng kích cỡ task của [§9](../../CLAUDE.md) — trùng khớp §5.2 của prompt-fullstack:
**1 lane · ≤ 3 file · 1 đầu ra kiểm chứng được · vừa một session**.

Sáu ô mỗi bước: **Vì sao** · **Đầu vào** · **Việc làm** · **Đầu ra → nhà nào** · **Biên nhận** (lane BA
không có compiler ⇒ biên nhận là *lệnh đọc lại*, [§8](../../CLAUDE.md)) · **Ai làm được**.

Ô cuối hay bị bỏ qua nhất: **phần lớn việc BA là hỏi người thật.** Agent dựng được *bộ câu hỏi* và
*khuôn để điền*; câu trả lời phải ra từ owner hoặc từ một ca sáng ở quán.

---

## 2. Kế hoạch tổng quát — 6 giai đoạn, 13 bước

### 2.1 Dự án đang ở đâu — và vì sao đây đúng là lúc làm BA

Đọc bảng dưới mà không biết dự án đang đứng ở đâu thì thứ tự các giai đoạn trông như tuỳ tiện. Nên
nói trước hiện trạng — **đo bằng lệnh, không chép số** ([§10](../../CLAUDE.md)), chạy từ gốc repo:

```bash
ls code/be/migrations/*.up.sql            # DB đã dựng tới đâu
find code/be -name '*.go' | sort          # BE có những gì
find fe -type f | wc -l              # FE có gì chưa
ls code/be/api/openapi.yaml 2>&1          # hợp đồng BE↔FE đã có chưa
grep -c '🔓 MỞ' finding.md            # còn bao nhiêu chỗ đang sai
```

Chạy xong sẽ thấy một hình dạng rất đặc trưng: **phần dưới cùng đã xây, phần trên chưa có gì.**
Cơ sở dữ liệu đã có menu, bàn, nhân viên, đơn hàng và bản vá khoá chống hai phiên một bàn. Backend
mới có mảnh **tính giá** cùng bộ test của nó và một đường đọc menu, chưa có tầng dịch vụ ([F-16](../../finding.md#f-16)),
chưa có hợp đồng API cho FE (`T-13`). Thư mục `fe/` **chưa có file nào**. Nói cách khác: *đường đi của
tiền* đã bắt đầu được xây, còn *đường đi của món và của người* — khách gọi, quầy duyệt, bếp làm, bưng
ra bàn, dọn bàn — thì mới nằm trên giấy.

**Đó chính xác là lý do BA còn kịp có ích.** Việc của BA là kiểm xem những gì sắp xây có khớp cách quán
thật vận hành không. Làm bây giờ, phát hiện lệch thì sửa một dòng trong tài liệu. Làm sau khi FE đã
dựng xong màn hình trạm và POS, phát hiện lệch thì phải sửa màn hình, sửa API, sửa cả dữ liệu đã chạy —
và tới lúc đó BA không còn là phân tích nữa, nó chỉ còn là **biên bản giải thích vì sao phải làm lại**.

Có một dấu hiệu nữa cho thấy thời điểm đã chín: repo hiện có **nhiều tài liệu hơn code**
([quality/07 §0](../../quality/07-cau-truc-du-an.md) đã đo và ghi thẳng là *"bộ khung đã dựng xong
trước khi có sản phẩm để nó quản lý"*). Trong tình huống đó, thứ dự án thiếu **không phải thêm tài liệu**
— mà là mấy câu trả lời chỉ lấy được từ người thật ở quán. Đó đúng là việc mà không lane code nào làm thay được.

### 2.2 Sáu giai đoạn, mỗi giai đoạn một tình huống có thật

**BA-0 — chốt nhà.** *Tình huống:* một session sau được giao *"vẽ luồng ăn tại bàn"*. Nó mở repo, tra
bảng lane ở [CLAUDE.md §1](../../CLAUDE.md), **không thấy `design/BA/`** ⇒ theo luật §1.2 nó rơi về lane
NON-CODE. Mà NON-CODE sở hữu `task.md`, `finding.md`, `quality/`, `project_preparation/` — không có chỗ
nào là nhà của sơ đồ luồng. Nên nó đoán: viết vào [00-scope.md](../../project_preparation/00-scope.md),
hoặc tự đẻ file mới. Session sau nữa đoán khác. Ba tháng sau có ba bản sơ đồ, không bản nào thắng, và
cái nào sai thì không lệnh nào báo. **Đây không phải giả thuyết** — đó đúng là cơ chế đã đẻ ra
[F-67](../../finding.md#f-67). Chốt nhà mất một session; dọn ba bản là một dòng finding sống nhiều tháng.

**BA-1 — gỡ nút đang chặn.** *Tình huống đang xảy ra ngay lúc này:* khách gọi một suất trứng chín.
Hoá đơn in ra 9.000đ — **đúng**. Khách trả 9.000đ — **đúng**. Nhưng phiếu xuống bếp chỉ ghi *"trứng chín ×1"*,
thiếu 4 cái bánh đi kèm, vì dữ liệu mồi mới khai thành phần cho combo. Không test nào đỏ, không cảnh báo
nào bật, vì **phần tiền hoàn toàn đúng** — chỉ có phần bếp sai. Nó sẽ sai như vậy **mỗi đơn**, và chỉ lộ
ra khi có người đứng đếm bánh. Đây là [F-68](../../finding.md#f-68) 🟠 đang mở, và lane DB đang đứng chờ
đúng ba câu trả lời mà chỉ chủ quán mới có. Không giai đoạn nào khác được đi trước việc này.

**BA-2 — hiện trạng.** *Tình huống:* [prompt-fullstack §3.7](../../project_preparation/prompt-fullstack.md)
đã thiết kế màn hình trạm khá chi tiết — mỗi việc một thẻ, một nút `Xong`, cũ nhất lên đầu, màu đổi theo
thời gian chờ. Giả sử ra quán xem thì thấy người tráng bánh **tráng theo mẻ**, sáu tám cái một lượt cho
mấy bàn cùng lúc, chứ không làm dứt điểm từng suất. Màn hình bắt bấm `Xong` từng thẻ theo thứ tự cũ nhất
sẽ buộc họ làm ngược cách họ đang làm. Bảy rưỡi sáng đông khách, họ bỏ tablet, quay lại hô miệng như cũ.
**Phần mềm không lỗi. Test vẫn xanh. Chỉ là không ai dùng** — và không có lệnh nào báo được chuyện đó.
Một buổi sáng đứng xem là biết; ngồi đoán thì không bao giờ biết.

**BA-2, vế thứ hai — số nền.** *Tình huống:* ba tháng sau khi chạy thật, chủ quán hỏi *"cái này rốt cuộc
có đáng không?"*. Muốn trả lời thì phải so với lúc chưa có nó: trước đây một ca quên món mấy lần, cuối ca
tiền lệch bao nhiêu, khách chờ bao lâu. **Không ai đo, nên không ai trả lời được — và không bao giờ trả lời
được nữa**, vì thời điểm đo đã trôi qua. Đo mất một buổi sáng, và chỉ có đúng một cửa sổ để làm: trước khi
phần mềm lên.

**BA-3 — nghiệp vụ mục tiêu.** *Tình huống:* tới lượt xây đăng nhập và phân quyền. Người viết code đọc
được đúng một câu trong [00-scope §5](../../project_preparation/00-scope.md): *"đứng quầy … quyền cao nhất
trong ca"*. Nhưng câu hỏi thật lúc gõ phím là: người **dọn bàn** có được xem đơn của bàn khác không? Người
**gấp bánh** bấm nhầm `Xong` của trạm tráng bánh thì hệ thống chặn hay cho qua? Ai được **huỷ món** khi
khách đổi ý? Không có bảng trả lời thì mỗi endpoint tự đoán một kiểu, và sai phân quyền chỉ lộ ra đúng lúc
nhân viên bấm nhầm giữa giờ đông khách. *Tình huống thứ hai, cùng giai đoạn:* mất mạng lúc 7h30. Quán vẫn
đầy người, món vẫn phải ra. Không ai biết chuyển sang sổ giấy theo bước nào, ai hô, bàn đang ăn dở thì tính
tiền ra sao. [prompt-fullstack §6.8](../../project_preparation/prompt-fullstack.md) đã gọi sổ giấy là kế
hoạch dự phòng **bắt buộc** — nhưng chữ *bắt buộc* đó chưa nở thành một dòng quy trình nào.

**BA-4 — yêu cầu kiểm chứng được.** *Tình huống — thử ngay bây giờ:* [README](../../README.md) có sáu
*"Quy tắc không được phá"*. Lấy quy tắc số 5, *"đơn từ QR phải được quầy duyệt trước khi xuống bếp"*, và
hỏi: **lệnh nào đang giữ nó?** Nếu không ai trả lời được trong một phút thì nghĩa là không ai biết nó đang
là luật hay chỉ là một câu viết trên giấy. Hôm nào có người sửa code bỏ mất bước duyệt, sẽ không có gì đỏ
lên, và đơn ảo xuống thẳng bếp. Bảng truy vết biến câu hỏi đó từ *"để tôi đọc lại code đã"* thành *tra một
dòng bảng* — và mỗi ô trống trong bảng chính là một chỗ hở tìm ra trước khi nó thành sự cố.

**BA-5 — đo sau khi chạy.** *Tình huống:* hai tuần sau go-live, tối đóng quán, tiền trong két lệch 50.000đ
so với báo cáo. Không có định nghĩa *"chạy tốt nghĩa là gì"* và không có chỉ số nào đang theo dõi ⇒ cuộc
tranh luận thành *"hình như hệ thống tính sai"* đấu với *"hình như nhân viên nhập nhầm"*, và không bên nào
chứng minh được. Giai đoạn này chốt trước 5 con số cùng cách lấy chúng, để câu trả lời là dữ liệu chứ không
phải cảm giác.

### 2.3 Bảng tóm tắt

| Giai đoạn | Câu hỏi giai đoạn trả lời | Bước | Chặn cái gì nếu không làm |
|---|---|---|---|
| **BA-0** Chốt nhà | Sản phẩm BA để ở đâu, ai sở hữu | B0 | 12 bước sau không biết ghi vào file nào |
| **BA-1** Gỡ nút đang chặn | Câu nào chưa trả lời mà code đang đứng chờ | B1.1 · B1.2 | [F-68](../../finding.md#f-68) 🟠 · phiếu bếp · ví dụ nổ việc §9.4 · go-live |
| **BA-2** Hiện trạng | Quán **đang** chạy thế nào khi chưa có phần mềm | B2.1 · B2.2 | Thiết kế trạm đang là giả định · mất vĩnh viễn số nền |
| **BA-3** Nghiệp vụ mục tiêu | Luồng chạy ra sao, ai được làm gì, hỏng thì sao | B3.1 · B3.2 · B3.3 · B3.4 | Phân quyền · vết trạng thái · màn hình trạm · kế hoạch dự phòng |
| **BA-4** Yêu cầu kiểm chứng được | Làm sao biết đúng, lệnh nào giữ | B4.1 · B4.2 | Tiêu chí "xong" của các luồng · bảng bất biến pha 1 |
| **BA-5** Đo sau khi chạy | Chạy rồi có ăn thua không | B5.1 · B5.2 | Không trả lời được "phần mềm này có đáng không" |

### 2.4 Bốn ràng buộc ép ra thứ tự này

Thứ tự sáu giai đoạn không phải sở thích — bốn ràng buộc ép ra nó:

1. **BA-1 phải trước mọi thứ** — nó đang chặn code *ngay bây giờ*, không phải chặn trong tương lai.
2. **BA-2 phải trước BA-3.** Không biết quán đang làm theo trình tự nào thì "thiết kế luồng mới" là
   đoán cho đẹp. Phần mềm bắt bếp đổi thói quen lúc 7h30 sẽ bị bỏ dùng, và không ai báo lỗi.
3. **B2.2 (đo số nền) có hạn chót cứng: trước khi phần mềm lên.** Sau đó số "trước khi có phần mềm"
   biến mất vĩnh viễn và câu *"làm cái này có ăn thua không"* thành không trả lời được mãi mãi.
   Rẻ nhất, dễ mất nhất trong cả kế hoạch.
4. **Toàn bộ BA-3 phải xong trước pha 1 (System design).** §6.2 của prompt-fullstack yêu cầu bảng
   **bất biến 3 cột** ở pha 1, và bất biến là mệnh đề nghiệp vụ — viết nó khi chưa chốt ai được làm gì
   (B3.3) thì I4/I5/I8 không có cách nào viết đúng.

---

## 3. Các bước chi tiết

### B0 — Chốt nhà cho sản phẩm BA · lane NON-CODE

- **Vì sao.** `design/BA/` chưa có tên trong bảng lane [§1](../../CLAUDE.md). Ghi bừa vào đó thì không
  lane nào sở hữu, không lệnh nào gác ⇒ đúng loại nhà mà
  [quality/07 §1](../../quality/07-cau-truc-du-an.md) gọi là *lane không có lệnh đỏ thì lane đó trôi*.
- **Ba đường** (nêu ở [bản tra cứu §6](nghien-cuu-vai-tro.md)) — **đề xuất (b)**, nay có thêm hai chứng cứ:
  prompt-fullstack §5.2 xếp `BA` ngang hàng các tầng khác, và §7 giao cho pha 0 bốn đầu ra bắt buộc
  mà **không đầu ra nào có nhà** trong repo hiện tại.
- **Việc làm.** Thêm 1 dòng lane BA vào [§1](../../CLAUDE.md) (sở hữu `design/BA/**`, gói nạp
  `design/BA/04-yeu-cau.md`, biên nhận = lệnh đọc lại) + dựng 4 file theo khuôn 3 lane kia.
- **Khuôn khớp sẵn ba khung:** `03-hien-trang` = BABOK *Analyze Current State* = pha 0 vế "quán làm
  gì" · `01-thiet-ke` = *Define Future State* = 2 sơ đồ luồng · `02-luat` = *Verify/Validate* +
  *Measure Performance* = quy tắc nghiệp vụ + thước đo.
- **Biên nhận.** `grep -c 'design/BA' CLAUDE.md` ≥ 1 **và** `wc -l CLAUDE.md` ≤ 175
  ([§12](../../CLAUDE.md): thêm luật ⇒ **thay hoặc gộp**, không thêm mục).
- **Ai làm được.** Owner chốt hướng, agent viết. **Bẫy:** §12 đang sát trần — đây là lý do B0 phải
  đứng riêng một session chứ không làm kèm.

### B1.1 — Trả lời 3 câu về thành phần một suất · lane NON-CODE · 🔺 chặn

- **Vì sao.** [F-68](../../finding.md#f-68) 🟠 đang mở. Hai file độc lập cùng chỉ vào nó:
  [00-scope §4.4](../../project_preparation/00-scope.md) (*"đang chặn `product_components` và phiếu bếp"*)
  và prompt-fullstack §3.2 (*"pha 0 (BA) phải chốt trước khi ai chạm tới DB"*). Đây là **định nghĩa
  giáo khoa của elicitation**: câu hỏi nghiệp vụ chưa ai đi hỏi, và nó đang giữ cả một tầng.
- **Đầu vào.** [00-scope §4.2–4.4](../../project_preparation/00-scope.md) · [F-68](../../finding.md#f-68) ·
  prompt-fullstack **§3.2** (3 câu) và **§9.4** (ví dụ nổ việc xuống bếp).
- **Việc làm — kỹ thuật, không phải chép lại câu hỏi.** Hỏi trừu tượng (*"4 bánh có nhận nhân không?"*)
  nhận về câu mơ hồ. Hỏi bằng **ca cụ thể** thì owner trả lời ngay:
  > *"Khách gọi 1 suất trứng chín, thịt + mộc nhĩ, nhiều nhân, 9.000đ. Phiếu xuống trạm tráng bánh in
  > ra đúng mấy dòng, mỗi dòng ghi gì? 4 cái bánh kia là bánh chay hay bánh có nhân?"*
  Ba ca, mỗi ca ứng một câu. **Ghi lại cả ca lẫn câu trả lời** — ca chính là thứ sau này dựng thành test.
- **Việc làm, vế thứ hai — đừng bỏ.** prompt-fullstack §9.4 tự ghi: *"số bánh ở đây tính theo cách hiểu
  cũ … nếu phải tính lại thì **sửa ví dụ này trước**, vì mọi pha sau đều tham chiếu tới nó."*
  Trả lời 3 câu xong ⇒ tính lại ví dụ 2 combo và sửa ngay trong cùng bước.
- **Đầu ra → nhà.** (1) Bảng thành phần đầy đủ đè lên khối *"Ba câu chưa có câu trả lời"* ở
  [00-scope §4.4](../../project_preparation/00-scope.md) — **giá không đụng vào**, bảng 4.2 giữ nguyên.
  (2) Ví dụ §9.4 trong prompt-fullstack tính lại.
- **Biên nhận.** `grep -c 'Ba câu chưa có câu trả lời' project_preparation/00-scope.md` → **0** và
  `grep -c 'tính theo cách hiểu cũ' project_preparation/prompt-fullstack.md` → **0**.
  Việc *đóng* F-68 (migration + test nổ việc) thuộc lane DB, là **task riêng** nối bằng cột
  *Cần xong trước* ([§8](../../CLAUDE.md)).
- **Ai làm được.** **Cần owner — bước duy nhất không được dùng lối thoát `GIẢ ĐỊNH:`.** Lý do ghi sẵn
  trong F-68: đoán sai thì bếp làm sai **mỗi đơn**, mà hoá đơn vẫn đúng nên rất lâu mới lộ.

### B1.2 — Khoá 5 dòng "Còn thiếu" bằng người + hạn · lane NON-CODE

- **Vì sao.** Địa chỉ đầy đủ, số tài khoản VietQR, ảnh 8 món, logo, domain — [00-scope](../../project_preparation/00-scope.md)
  ghi đúng là *không chặn code*, nhưng cả 5 **chặn go-live**. Việc không có tên người và hạn thì tới
  tuần deploy mới lộ, đúng lúc hết thời gian.
- **Việc làm.** Mỗi dòng thêm: ai lấy · hạn · chặn bước nào của [step.md](../../step.md). Riêng VietQR
  ghi rõ *chặn kênh thanh toán chuyển khoản*.
- **Đầu ra → nhà.** Bảng *Còn thiếu* ở [00-scope](../../project_preparation/00-scope.md), thêm 2 cột.
- **Biên nhận.** `sed -n '/^## Còn thiếu/,$p' project_preparation/00-scope.md | grep -c '|'` — mọi dòng đủ cột.
- **Ai làm được.** Cần owner (chỉ owner biết ai lấy được ảnh, ai giữ số tài khoản).

### B2.1 — Ghi lại quán đang chạy thế nào · lane BA

- **Vì sao.** [00-scope §5](../../project_preparation/00-scope.md) khai 5 trạm ở mức *ai làm việc gì* —
  đó là **mô tả tổ chức**, chưa phải **trình tự thời gian**. prompt-fullstack §3.7 thiết kế màn hình
  trạm rất chi tiết (thẻ việc, màu theo thời gian chờ trắng→vàng→đỏ, cũ nhất lên đầu) — toàn bộ thiết
  kế ấy đứng trên một giả định về trình tự làm việc mà **chưa ai đi kiểm ở quán thật**.
- **Việc làm.** Quan sát **một ca sáng thật** (06:00–11:00) + hỏi owner. Ghi 4 thứ: (1) trình tự một
  suất từ lúc gọi tới lúc lên bàn · (2) chỗ nào đang **chờ** và chờ vì gì · (3) giờ cao điểm, bao nhiêu
  bàn/lượt · (4) hiện quán nhớ "bàn nào gọi gì" bằng cách nào.
- **Đầu ra → nhà.** `design/BA/03-hien-trang.md`, bảng *bước · ai · người hay máy · chờ gì*.
- **Biên nhận.** Mỗi trạm ở [00-scope §5](../../project_preparation/00-scope.md) xuất hiện ≥ 1 lần:
  `for t in quay trang_banh gap_banh canh don_ban; do printf '%s %s\n' "$t" "$(grep -c "$t" design/BA/03-hien-trang.md)"; done` — không ô nào `0`.
- **Ai làm được.** **Cần người ở quán.** Bước agent làm được ít nhất, giá trị cao nhất.

### B2.2 — Đo số nền trước khi phần mềm lên · lane BA · ⏰ hạn chót cứng

- **Vì sao.** Ràng buộc 3 ở [mục 2.4](#24-bốn-ràng-buộc-ép-ra-thứ-tự-này). Đo sau khi phần mềm chạy là **quá muộn vĩnh viễn**.
- **Việc làm.** 4 con số, đo trong 1–2 ca, đo thô cũng được: (1) từ lúc khách gọi tới lúc lên bàn —
  10 suất · (2) một ca sai/quên mấy lần · (3) cuối ca tiền lệch bao nhiêu · (4) mấy lượt khách phải
  hỏi lại *"món tôi tới đâu rồi"*.
- **Đầu ra → nhà.** `design/BA/03-hien-trang.md`, mục *Số nền — đo ngày <ngày>*. **Phải có ngày đo**;
  số không ngày là số vô dụng ([§10](../../CLAUDE.md)).
- **Biên nhận.** `grep -c 'Số nền' design/BA/03-hien-trang.md` = 1 và mục đó có ngày.
- **Ai làm được.** Cần người ở quán.

### B3.1 — Hai sơ đồ luồng + 4 kênh bán · lane BA

- **Vì sao.** Đây là đầu ra bắt buộc số 1 và 2 của pha 0. **Nháp đã có sẵn** ở prompt-fullstack §3.3
  (sơ đồ luồng tại bàn + 3 điểm khác của ship/pickup) — nhưng file đó tự khai là **bản xuất khẩu,
  không phải nhà của sự thật nào**, và [F-67](../../finding.md#f-67) đang mở vì đúng chuyện nó chép.
  Nên việc ở đây **không phải vẽ lại từ đầu**: nó là *đưa sơ đồ mồ côi ấy về một nhà thật rồi bổ sung
  phần nó thiếu.*
- **Phần nó thiếu — nhánh hỏng.** Sơ đồ §3.3 chỉ vẽ đường đi thuận. Phải bổ sung: khách quét QR mà bàn
  đã có phiên · khách bỏ về giữa chừng · đơn ship gọi không nghe máy · quầy duyệt nhầm · hết nguyên
  liệu giữa ca (nút *Tạm dừng nhận đơn* mà §3.3 nói **ưu tiên cao hơn giờ mở cửa**).
- **Phải phủ 3 lát cắt của §5.1**, vì master task cả dự án sẽ chẻ theo chúng: **A** một suất tại bàn ·
  **B** một đơn ship · **C** chủ quán đổi giá (đơn cũ giữ nguyên giá). Lát cắt C hay bị quên vì nó
  không có màn hình khách nào — nhưng nó là lát cắt chứng minh snapshot giá.
- **Đầu ra → nhà.** `design/BA/01-thiet-ke.md`. **Ngôn ngữ quán, không tên bảng** (ranh giới cứng §0).
  Giá/menu/schema/endpoint chỉ đặt link ([§2.1](../../CLAUDE.md)).
- **Biên nhận.** Đủ 4 mã kênh, mỗi mã ≥ 1 nhánh hỏng, và **0 tên bảng lọt vào**:
  `grep -cE 'table_sessions|order_items|product_components|order_tasks' design/BA/01-thiet-ke.md` → **0**.
- **Ai làm được.** Agent viết nháp từ §3.3 + scope; owner soi nhánh hỏng (chỉ owner biết quán thật xử
  lý sao khi khách bỏ về).

### B3.2 — Máy trạng thái đơn + phiên bàn, bằng ngôn ngữ quán · lane BA

- **Vì sao.** Luật *"đơn từ QR phải được quầy duyệt trước khi xuống bếp"* ở [README](../../README.md),
  *"hoá đơn tính trên phiên bàn"* cũng ở đó, còn vết trạng thái và khoá chống hai phiên nằm ở lane BE/DB.
  **Không chỗ nào có bức tranh đủ**: trạng thái nào tồn tại, chuyển nào hợp lệ, ai được chuyển. Ba lane
  mỗi bên giữ một mảnh — đúng chỗ [§8](../../CLAUDE.md) gọi là mối nối, chỗ hỏng nhất.
- **Việc làm.** Một bảng: *từ → tới · ai được làm · điều kiện · có để lại vết không*. Cho cả đơn và
  phiên bàn. **Chuyển bị cấm cũng phải liệt kê** — cấm mà không viết ra thì không ai test được điều cấm.
- **Chú ý ranh giới.** Viết *"phiên đang thu tiền"*, không viết `status='billing'`. Việc ánh xạ trạng
  thái sang cột là pha 2. BA chỉ trả lời: **trạng thái nào có thật trong quán, và ai được đổi.**
- **Đầu ra → nhà.** `design/BA/01-thiet-ke.md`, mục riêng.
- **Biên nhận.** Mọi trạng thái trong bảng đều có ≥ 1 dòng *tới* và ≥ 1 dòng *từ*, trừ trạng thái
  đầu/cuối được khai rõ là đầu/cuối.
- **Ai làm được.** Agent dựng từ README + code, owner chốt các ô *ai được làm*.

### B3.3 — Ma trận vai × hành động · lane BA

- **Vì sao.** Đây là đầu vào trực tiếp của **phân quyền theo vai** mà prompt-fullstack §3.6 đã hứa
  (*"Nhân viên (JWT, phân quyền theo `role`)"*) và §7 pha 3 đòi (*"ai được làm gì"*). Hiện quyền chỉ
  có một câu văn xuôi ở [00-scope §5](../../project_preparation/00-scope.md): *"đứng quầy … quyền cao
  nhất trong ca"*. Viết code phân quyền từ một câu văn xuôi = mỗi endpoint tự đoán một kiểu.
- **Việc làm.** Hàng = 5 trạm + quầy + chủ quán; cột = xem đơn · duyệt đơn QR · đổi trạng thái việc
  trạm mình · đổi trạng thái trạm khác · sửa món · huỷ món · sửa giá · gộp/tách phiếu bàn · đóng phiên ·
  thu tiền · đánh dấu bàn đã dọn · xem doanh thu. Ô = ✅ / ❌ / ⚠️ có điều kiện (ghi rõ điều kiện).
- **Đầu ra → nhà.** `design/BA/01-thiet-ke.md`, mục riêng.
- **Biên nhận.** Không ô nào rỗng — `awk -F'|' '/^\|/{for(i=2;i<=NF-1;i++) if($i ~ /^ *$/) print NR}'`
  trên đúng mục đó ra **rỗng**.
- **Ai làm được.** Cần owner — *"nhân viên gấp bánh có được huỷ món không"* là quyết định kinh doanh.

### B3.4 — Quy trình dự phòng khi hệ thống chết trong giờ bán · lane BA

- **Vì sao.** prompt-fullstack §6.8 khai một ràng buộc kiến trúc rồi tự nêu đối trọng của nó:
  *"tất cả trên 1 VPS (đối trọng: **sổ giấy là kế hoạch dự phòng bắt buộc**)"*. Chữ *bắt buộc* đó
  **chưa nở ra thành quy trình ở bất kỳ file nào** — và nó là quy trình **con người làm**, nên không
  lane code nào sẽ tự nhặt. Quán bán 06:00–11:00; mất mạng lúc 7h30 không có thời gian ứng biến.
- **Việc làm.** Trả lời 5 câu: (1) ai phát hiện hệ thống chết và phát hiện bằng gì · (2) chuyển sang
  sổ giấy theo bước nào, ai hô · (3) bàn đang có phiên dở tính tiền ra sao · (4) hệ thống sống lại thì
  nhập bù thế nào, ai nhập · (5) đơn ship/pickup đã nhận trước lúc chết xử lý ra sao.
- **Việc làm, vế hai.** §6.3 đòi *đối chiếu doanh thu hệ thống với sổ giấy mỗi tối trong 2 tuần đầu* —
  tức sổ giấy còn là **công cụ nghiệm thu**, không chỉ là dự phòng. Chốt luôn mẫu sổ giấy ghi những cột
  gì để đối chiếu được, nếu không thì tối đầu tiên đã không đối chiếu nổi.
- **Đầu ra → nhà.** `design/BA/01-thiet-ke.md`, mục *Dự phòng*.
- **Biên nhận.** 5 câu đều có câu trả lời có tên người; `grep -c 'sổ giấy' design/BA/01-thiet-ke.md` ≥ 1.
- **Ai làm được.** Cần owner (đây là quy trình nhân sự, không phải kỹ thuật).

### B4.1 — User story + tiêu chí chấp nhận · lane BA

- **Vì sao.** Luồng ở B3.1 mô tả *chuyện gì xảy ra*; test cần *điều kiện đúng/sai*. BABOK gọi bước này
  là **Verify** (yêu cầu đã viết đủ chất lượng chưa), tách khỏi **Validate** (có đáng làm không).
- **Việc làm.** Mỗi luồng ⇒ `Là <vai>, tôi muốn <X>, để <Y>` + tiêu chí Given/When/Then.
  **Luật cứng: mỗi tiêu chí phải chỉ ra được một lệnh/test sẽ giữ nó.** Không chỉ được ⇒ ghi rõ *chưa
  có chỗ giữ* thay vì để trôi. Đây chính là §5.3 của prompt-fullstack áp cho tầng nghiệp vụ: *thiếu cột
  đầu ra kiểm chứng được thì nó là ý kiến, không phải task*.
- **Ba tiêu chí bắt buộc phải có** vì §4 xếp chúng vào loại "vi phạm là làm lại": chọn *Chay + Nhiều
  nhân* phải **bị từ chối** chứ không âm thầm bỏ qua · đơn QR chưa duyệt **không** xuống bếp · khách
  gọi 3 lần trong một bữa ra **đúng 1 hoá đơn**.
- **Đầu ra → nhà.** `design/BA/02-luat.md`.
- **Biên nhận.** `grep -c 'Then' design/BA/02-luat.md` = `grep -c 'giữ bởi' design/BA/02-luat.md`.
- **Ai làm được.** Agent làm được gần hết; owner soi lại.

### B4.2 — Bảng truy vết quy tắc nghiệp vụ → lệnh giữ (RTM) · lane BA

- **Vì sao.** Đây là đầu ra bắt buộc thứ 3 của pha 0 (*danh sách quy tắc nghiệp vụ*), và là thứ trả lời
  câu chưa ai trả lời được: **quy tắc nào đang có lệnh giữ, quy tắc nào chỉ là lời hứa?**
- **Nguồn phải gom đủ ba chỗ** — trước khi đọc prompt-fullstack tôi tưởng chỉ có chỗ đầu:
  [README](../../README.md) 6 *"Quy tắc không được phá"* · prompt-fullstack **§4** 11 ràng buộc
  (§4.6 *Chay + Nhiều nhân phải bị từ chối*, §4.9 *realtime không được là đường duy nhất* — **không**
  có trong README) · prompt-fullstack **§6.2** 8 bất biến `I1–I8`.
- **Việc làm.** Bảng 3 cột *quy tắc → nhà của nó → lệnh/test đang giữ*. Ô 3 rỗng ⇒ phân loại theo
  [§7](../../CLAUDE.md): code **đang sai** ⇒ finding · **chưa xây tới** ⇒ task. Đừng đổ hết vào sổ
  finding — đó là bệnh [F-65](../../finding.md#f-65).
- **Ba ô đã biết trước là rỗng**, §6.2 tự đánh dấu: `I3` (giá thu = giá backend) và `I7` (đơn cũ giữ giá)
  ghi query đối chiếu là `—`; `I8` (bàn trống ⟺ không còn phiên mở) ghi thẳng *"phải chọn một nguồn sự
  thật"* — tức **một quyết định nghiệp vụ chưa ai ra**. Ba ô này là sản phẩm chính của bước, không phải
  phần dư.
- **Đầu ra → nhà.** `design/BA/02-luat.md` + dòng mới ở [task_BA.md](task_BA.md)/[finding_BA.md](finding_BA.md), hoặc sổ của lane phải sửa nếu quy tắc đó không thuộc BA.
- **Biên nhận.** 6 luật README + 11 ràng buộc §4 + 8 bất biến đều có 1 dòng; mỗi ô cột 3 rỗng kèm đúng
  1 mã `T-` hoặc `F-`.
- **Ai làm được.** Agent (đối chiếu file, không cần hỏi ai) — trừ quyết định `I8`, cần owner.

### B5.1 — Định nghĩa "chạy tốt nghĩa là gì" · lane BA

- **Vì sao.** BABOK nhóm 8 (*Solution Evaluation*) trả lời câu đắt nhất: *bỏ 8 tuần làm cái này có ăn
  thua không*. Không định nghĩa trước thì sau này tranh luận bằng cảm giác.
- **Đã có sẵn một nửa — đừng phát minh lại.** §6.3 đã chốt cổng nghiệm thu mạnh nhất: *2 tuần đầu, mỗi
  tối đối chiếu doanh thu hệ thống với sổ giấy và tiền trong két; lệch 1 đồng cũng phải tìm ra lý do*.
  Bước này **link** tới đó rồi bổ sung phần còn thiếu, không chép ([§2.1](../../CLAUDE.md)).
- **Việc làm.** 5 chỉ số, mỗi cái đủ 3 vế: **cách lấy số · ngưỡng đạt · so với số nền B2.2**. Gợi ý:
  thời gian đặt→lên bàn · tỷ lệ đơn phải sửa/huỷ · số lần phải đặt hộ vì QR không dùng được · lệch
  tiền cuối ca · đơn ship trễ hẹn.
- **Việc làm, vế hai — đừng bỏ.** Chỉ số nào **không lấy được** từ dữ liệu hệ thống đang giữ ⇒ đó là
  **yêu cầu mới cho DB/BE**, mở task ngay, đừng hạ chỉ số cho vừa dữ liệu.
- **Đầu ra → nhà.** `design/BA/02-luat.md`, mục *Thước đo*.
- **Biên nhận.** 5 chỉ số × 3 vế đều có mặt.
- **Ai làm được.** Agent dựng, owner chốt ngưỡng.

### B5.2 — Chốt lịch soi lại · lane BA

- **Vì sao.** Chỉ số không có lịch đọc thì không ai đọc. Đây là chỗ BABOK 8.5 (*Recommend Actions*)
  nối ngược về [task_BA.md](task_BA.md). prompt-fullstack §6.6 đã có nhịp cho **kỹ thuật** (mỗi task /
  mỗi tối / trước deploy / mỗi tháng) nhưng **không có nhịp nào cho chỉ số nghiệp vụ**.
- **Việc làm.** Chốt: đo lần đầu sau go-live bao lâu · ai đọc · kết quả ghi vào đâu · ai được mở task từ đó.
- **Đầu ra → nhà.** `design/BA/02-luat.md`.
- **Biên nhận.** `grep -c 'soi lại' design/BA/02-luat.md` ≥ 1 và có mốc thời gian cụ thể.

---

## 4. Khuôn đầu ra khi giao pha 0

prompt-fullstack §8 đã chốt hình dạng mỗi pha phải giao — **dùng nguyên, đừng sáng tạo khuôn mới**:

```
PHA: 0 · BA
CHỐT XONG:            <3–7 quyết định, mỗi dòng 1 quyết định + 1 câu lý do>
MASTER TASK:          <bảng 7 cột §5.3, tối đa 12 dòng>
CỔNG CHẤT LƯỢNG:      <lệnh/kịch bản phải xanh mới được sang pha 1>
GIẢ ĐỊNH:             <chỗ tự chốt vì chưa hỏi được owner, kèm mức rủi ro>
RỦI RO LỚN NHẤT:      <1 dòng + cách chặn>
CÒN LẠI:              <1 dòng, việc của pha 1>
```

Hai lưu ý khi mang khuôn này vào repo:

- Bảng 7 cột của §5.3 là khuôn cho agent **ngoài** repo. Trong repo, nhà của task là
  [task_BA.md](task_BA.md) với bộ cột của nó — lệch ⇒ **sổ của lane thắng** ([§2](../../CLAUDE.md)).
  Cột đáng mang sang là *Hỏng thì mất gì*, viết bằng hậu quả ở quán (*"thu thiếu tiền bàn 5"*),
  vì §5.4 dùng đúng cột đó để phá thế hoà khi xếp thứ tự.
- Dòng `BẤT BIẾN MỚI:` của §8 **thuộc pha 1**, không phải pha 0 — pha 0 chỉ giao quy tắc nghiệp vụ
  bằng ngôn ngữ quán (B4.2), còn cột *bảo vệ bằng* và *query đối chiếu* là việc pha 1 và pha 2.

## 5. Năm cái bẫy của riêng lane BA

| Bẫy | Vì sao nó xảy ra ở đây | Cách chặn |
|---|---|---|
| **Nhắc tên bảng ở pha 0** | Schema 16 bảng đã có sẵn ở §3.5, đọc xong là nghĩ bằng tên bảng | Lệnh `grep` tên bảng ở biên nhận B3.1 — ranh giới cứng §7 |
| **Đẻ nhà thứ hai** — chép giá/menu/schema vào file BA | Tài liệu BA chuẩn (BRD/SRS) vốn viết để đọc độc lập | Chỉ đặt link. Đúng cơ chế [F-67](../../finding.md#f-67), mà nạn nhân là chính prompt-fullstack |
| **Sổ finding phình vì dòng *"chưa có X"*** | B4.2 sẽ lòi ra nhiều quy tắc không có lệnh giữ | Gác ở cửa vào bằng phép thử [§7](../../CLAUDE.md) — bệnh [F-65](../../finding.md#f-65) |
| **Lane không có compiler ⇒ trôi im lặng** | BA không có `make check` | Mỗi bước trên đã kèm lệnh đọc lại; nghĩ không ra lệnh = bước chưa viết xong |
| **Agent tự trả lời câu của owner** | B1.1/B2.1/B3.3/B3.4 chờ người thì rất cám dỗ "đoán cho chạy tiếp" | Dùng lối thoát `GIẢ ĐỊNH:` + mức rủi ro (§4.10) — **trừ B1.1**, xem F-68 |

## 6. Làm gì ngay bây giờ

Ba việc, đúng thứ tự — hai việc đầu **cần owner**, không agent nào làm thay:

1. **Chốt B0** (a/b/c). Quyết định này khoá chỗ ghi của 12 bước còn lại. Hai chứng cứ mới nghiêng hẳn
   về (b): §5.2 xếp `BA` ngang hàng các tầng, §7 giao pha 0 bốn đầu ra mà không cái nào có nhà.
2. **Trả lời 3 câu của B1.1** — đang chặn [F-68](../../finding.md#f-68) 🟠, chặn `product_components`,
   và làm ví dụ §9.4 của prompt-fullstack sai theo.
3. **Đặt lịch B2.1 + B2.2 vào một ca sáng.** B2.2 có hạn chót cứng là *trước khi phần mềm lên*; qua
   mốc đó thì không đo lại được nữa.
