# Prompt Guideline

Cách viết một prompt để AI làm đúng việc, đúng phạm vi, và có thể kiểm chứng.

Một prompt tốt không phải là prompt dài. Là prompt mà sau khi đọc xong, người khác biết
**việc gì phải xong**, **được chạm vào cái gì**, và **làm sao biết là đúng**.

Guideline này bám theo ceremony theo rủi ro trong `README.md` (L0 → L3) và dùng lại đúng
các trường của task trong `work/backlog.md`.

---

## 1. Nguyên tắc chọn level

Chọn level theo **hậu quả khi sai**, không theo số dòng code.

| Level | Loại thay đổi | Prompt phải có |
|-------|---------------|----------------|
| L0 | Format, typo, rename cơ học, sửa comment | Goal + Verify |
| L1 | Bug nhỏ, feature cô lập, không đổi hành vi nghiệp vụ | Context + Goal + Scope + Acceptance + Verify |
| L2 | API mới, đổi schema, đổi hành vi nghiệp vụ, đổi cách tính tiền | L1 + Constraints + Invariants liên quan |
| L3 | Subsystem mới, đổi kiến trúc, auth, thanh toán, migration rủi ro | L2 + Decision (ADR) + chia nhỏ thành nhiều task L1/L2 |

### Bộ câu hỏi quyết định

Trả lời 5 câu. Chỉ cần **một** câu "có" ở nhóm dưới là phải nâng level.

1. Thay đổi này có chạm tiền, đơn hàng, hoặc dữ liệu lịch sử không? → tối thiểu L2
2. Người dùng có nhìn thấy hành vi nghiệp vụ khác đi không? → tối thiểu L2
3. Có thêm/đổi contract giữa 2 thành phần (API, event, schema) không? → tối thiểu L2
4. Nếu sai, hệ thống có báo lỗi ngay, hay sai âm thầm rồi vài ngày sau mới phát hiện? → sai âm thầm là L2+
5. Revert có phải chỉ là revert 1 commit không? → nếu không (đã migrate data, đã gửi tiền, đã publish) thì L3

### Quy tắc bổ sung

- Phân vân giữa hai level → chọn level cao hơn. Chi phí viết thừa một mục Constraints rẻ hơn chi phí sửa sai tiền.
- Không hạ level chỉ vì thay đổi "nhìn có vẻ nhỏ". Sửa một dòng công thức tính tổng tiền vẫn là L2.
- Không nâng level để cho an toàn hình thức. L3 cho một task đổi màu button là ceremony rỗng.
- Một prompt = một level. Nếu thấy mình đang viết prompt chứa cả việc L1 lẫn việc L3, đó là dấu hiệu phải tách task.

---

## 2. Sáu khối của một prompt

### Context

Bối cảnh tối thiểu để AI không phải đoán, và không phải đọc cả repo.

Nêu: file/module liên quan, tài liệu nguồn sự thật liên quan (`docs/product/`,
`docs/product/1-system-design/architecture.md`, `quality/invariants.md`), và trạng thái hiện tại.

- Tốt: "Giá đơn hiện được tính ở `order/pricing.go`. Quy tắc phụ thu nằm ở `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` mục 4."
- Tệ: "Đọc codebase rồi tự hiểu."

Context không phải là chỗ kể lịch sử dự án. Chỉ đưa cái cần cho task này.

### Goal

**Một** kết quả nghiệp vụ phải đạt được. Viết theo outcome, không theo cách làm.

- Tốt: "Đơn có món đã bị ngừng bán vẫn phải giữ nguyên giá và tên món tại thời điểm đặt."
- Tệ: "Refactor lại pricing cho sạch."

Nếu Goal có chữ "và" nối hai kết quả độc lập → tách thành hai task.

### Scope

Cái gì **được phép** thay đổi, và cái gì **không được** thay đổi.

Phần "Out of scope" quan trọng hơn phần "Scope". Đó là thứ ngăn AI đi refactor lan man.

- Tốt: "Được sửa: `order/pricing.go`, test của nó. Không được sửa: schema DB, API response shape, module payment."
- Tệ: "Sửa những gì cần thiết."

### Constraints

Ràng buộc kỹ thuật và nghiệp vụ phải tôn trọng trong lúc làm.

Gồm: invariants phải giữ, tính tương thích ngược, hiệu năng, thư viện được/không được dùng,
pattern phải theo trong codebase.

- Tốt: "Không đổi chữ ký hàm public. Giữ invariant I-002: snapshot đơn cũ không đổi khi giá sản phẩm đổi."
- Tệ: "Code cho chuẩn."

Từ L2 trở lên, Constraints phải trích **đích danh** invariant từ `quality/invariants.md`.

### Acceptance

Làm sao nhận ra là đúng. Viết dạng điều kiện quan sát được, không phải cảm tính.

Mỗi dòng acceptance phải trả lời được đúng/sai, không "tuỳ".

- Tốt:
  - "Đơn cũ chứa món đã đổi giá: tổng tiền không đổi."
  - "Món ngừng bán không xuất hiện trong menu mới, nhưng vẫn hiển thị đúng trong đơn cũ."
  - "Chuyển trạng thái đơn không hợp lệ bị từ chối, trả lỗi rõ ràng."
- Tệ: "Hoạt động tốt, không lỗi."

Acceptance là hợp đồng. Nếu không viết được acceptance, tức là Goal chưa rõ — quay lại sửa Goal.

### Verify

Lệnh hoặc thao tác cụ thể để chứng minh acceptance đã đạt.

- Tốt: `./scripts/verify.sh`, `go test ./order/...`, hoặc kịch bản thủ công 3 bước có kết quả mong đợi.
- Tệ: "Test lại xem sao."

Verify phải chạy được bởi người khác, không cần hỏi lại.

---

## 3. Template theo level

### L0 — Trivial

```text
Goal:
<một câu, thay đổi cơ học>

Verify:
<lệnh>
```

Ví dụ:

```text
Goal:
Sửa lỗi chính tả "Confrim" thành "Confirm" trong màn hình thanh toán.

Verify:
grep -r "Confrim" . → không còn kết quả
./scripts/verify.sh
```

### L1 — Small

```text
Context:
<file/module liên quan, trạng thái hiện tại — 1-3 dòng>

Goal:
<một kết quả>

Scope:
Được sửa: <danh sách>
Không được sửa: <danh sách>

Acceptance:
- <điều kiện quan sát được>
- <điều kiện quan sát được>

Verify:
<lệnh>
```

### L2 — Significant

```text
Context:
<file/module liên quan>
<tài liệu nguồn sự thật liên quan: docs/product/ mục X, quality/invariants.md I-00N>

Goal:
<một kết quả nghiệp vụ>

Scope:
Được sửa: <danh sách>
Không được sửa: <danh sách>

Constraints:
- Giữ invariant: I-00N — <tên invariant>
- <tương thích ngược / hiệu năng / pattern bắt buộc>

Acceptance:
- <happy path>
- <edge case>
- <trường hợp phải bị từ chối>

Verify:
<lệnh test + kiểm tra invariant>

Unknowns:
- <câu hỏi nghiệp vụ chưa có lời giải — nếu có, hỏi trước khi code>
```

### L3 — Architectural

L3 **không** làm trong một prompt. Prompt L3 là prompt **thiết kế và chia việc**, không phải prompt code.

```text
Context:
<vấn đề, ràng buộc hệ thống hiện tại, tài liệu liên quan>

Goal:
<năng lực hệ thống cần có sau khi xong>

Scope:
Hệ thống/thành phần bị ảnh hưởng: <danh sách>
Ngoài phạm vi: <danh sách>

Constraints:
- <invariants phải giữ xuyên suốt>
- <ràng buộc vận hành: downtime, migration, rollback>

Deliverables:
1. Phương án thiết kế + phương án bị loại và lý do
2. ADR ghi vào docs/decisions.md
3. Invariants mới ghi vào quality/invariants.md
4. Chia thành các task L1/L2 trong work/backlog.md, mỗi task có acceptance riêng

Acceptance (của giai đoạn thiết kế):
- Mỗi task con revert được độc lập
- Có phương án rollback cho bước rủi ro nhất
- Không còn unknown nghiệp vụ nào chặn task đầu tiên

Verify:
Review thiết kế trước khi bắt đầu task đầu tiên.
```

---

## 4. Anti-patterns

| Anti-pattern | Biểu hiện | Sửa thế nào |
|---|---|---|
| Prompt mù phạm vi | "Sửa giúp phần đặt hàng" | Liệt kê file được sửa và file cấm sửa |
| Nhiều goal trong một prompt | Goal có "và", "đồng thời", "tiện thể" | Tách task, làm tuần tự |
| Acceptance cảm tính | "Chạy ổn", "code sạch hơn" | Viết điều kiện đúng/sai quan sát được |
| Không có Verify | Kết thúc bằng "xong rồi" | Luôn có lệnh chạy được |
| Đổ cả repo vào context | "Đọc hết rồi làm" | Chỉ đưa file và mục tài liệu liên quan |
| Để AI tự đặt luật nghiệp vụ | "Tự quyết định cách tính phụ thu" | Ghi unknown, hỏi người, rồi mới code |
| Ceremony sai level | ADR cho việc đổi màu button | Chọn level theo hậu quả khi sai |
| Level thấp cho việc chạm tiền | "Chỉ sửa một dòng công thức thôi" | Chạm tiền/dữ liệu lịch sử là L2+ |
| Prompt kể cách làm thay vì kết quả | "Tạo class X, thêm method Y" | Nêu outcome, để cách làm mở |
| Scope trôi giữa chừng | Sửa thêm thứ ngoài task vì "thấy nó xấu" | Ghi vào `work/findings.md` hoặc backlog, không sửa ngay |
| Đóng task khi chưa verify | Báo xong trước khi chạy test | Verify trước, báo cáo sau |

---

## 5. Golden Template

Template mặc định. Dùng cho mọi task từ L1 trở lên; xoá mục không cần cho L1.

```text
## Context
<Module/file liên quan. Trạng thái hiện tại. Tài liệu nguồn sự thật liên quan.>

## Goal
<Một kết quả nghiệp vụ duy nhất, viết theo outcome.>

## Scope
Được sửa:
- <file/module>

Không được sửa:
- <file/module/contract>

## Constraints
- Giữ invariant: <I-00N>
- <ràng buộc kỹ thuật>

## Acceptance
- <điều kiện đúng/sai — happy path>
- <điều kiện đúng/sai — edge case>
- <điều kiện đúng/sai — trường hợp phải bị từ chối>

## Verify
- <lệnh>
- ./scripts/verify.sh

## Unknowns
- <câu hỏi nghiệp vụ chưa có lời giải. Nếu mục này không rỗng, hỏi trước khi code.>

## Report (AI trả lời sau khi làm)
- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
```

Ba dòng cuối trong **Report** là bắt buộc, khớp với mục "Before Finishing" trong `CLAUDE.md`.
