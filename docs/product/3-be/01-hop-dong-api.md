<a id="top"></a>
# Hợp đồng API — khuôn, luật đọc, luật đổi

Pha 3 · bước `P3-04` · viết 2026-10-06 (Claude Code). File đầu tiên của `docs/product/3-be/`, và nó mở
thư mục ấy (**ADR-035** luật 2). Quyết định *hợp đồng thắng code* và vì sao chọn định dạng này:
`docs/decisions.md` **ADR-084**. Thước của pha 3 (ô ghi, cửa ghi, lời từ chối tới người dùng qua tên):
**ADR-082**.

**Hai file, một owner** — hàng *Hợp đồng API* của `CLAUDE.md` §2:

| File | Giữ gì |
|---|---|
| [`openapi.yaml`](openapi.yaml) | **hợp đồng máy đọc**: đường gọi, chữ ký, schema, mã lỗi, bảng tên từ chối → mã. Pha 4 sinh type từ nó. |
| **file này** | khuôn của file trên, luật đọc mỗi phần, luật đổi, và lệnh chấm nó với code |

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ** — một mã lỗi nói *luật nào vừa chặn*, không định nghĩa luật ấy. Luật ở
  `quality/invariants.md` và `master_plan/shop-facts.md`; hợp đồng trỏ, không chép (**F-001**);
- **quyền theo vai** — ma trận vai × thao tác ra đời ở `P3-05`, trong một file mới của thư mục này;
- **tên bảng, cột, ràng buộc** — file migration thắng (**ADR-053** luật 2). Bảng ánh xạ ở §4 **theo**
  migration, không đặt tên cho nó;
- **chữ hiện cho người dùng** ứng với mỗi mã, và cái gì hiện ở đâu — pha 4.

---

## 1. Định dạng — OpenAPI 3.1, một file YAML, bắt đầu rỗng đường gọi

Hợp đồng là **một** file [`openapi.yaml`](openapi.yaml) theo OpenAPI **3.1**. Pha 4 sinh type từ đó
bằng công cụ của pha 4 — chọn công cụ nào là việc của pha ấy; định dạng này là định dạng mà các công cụ
sinh type phổ biến cùng đọc.

Ngày mở (2026-10-06) file có `paths: {}` — **không một đường gọi nào**. Mỗi lát `P3-05`…`P3-12` thêm
đường gọi của mình **cùng lượt** dựng cửa của nó, và Gate 1g (§9) bắt hai bên đi cùng nhau. Danh sách
đường gọi ở `master_plan/prompt-fullstack.md` §3.6 là **đề xuất** viết trước lược đồ (kế hoạch pha 3 §1);
không chép nó vào đây "cho đủ".

Tên trường trong JSON: **snake_case tiếng Anh**; trường ứng với một cột thì **trùng tên cột**
(`01-quy-uoc-du-lieu.md` `QD-01`) — một tên, ba tầng, không bảng dịch nào ở giữa.

## 2. Khuôn viết — để một lệnh đọc được mà không cần trình đọc YAML

Gate 1g đọc file bằng một bộ đọc khuôn, không phải trình đọc YAML đầy đủ — cùng lối Gate 1f đọc SQL
(**ADR-083**). Vì vậy file giữ năm điều:

1. Thụt **hai dấu cách** mỗi bậc; dòng chú thích mở đầu bằng `#`.
2. Khoá đường gọi nằm ở bậc 1 dưới `paths:`, mở đầu bằng `/`; phương thức (`get` · `post` · `put` ·
   `patch` · `delete`) ở bậc 2 ngay dưới nó. Tham số đường dẫn viết `{tên}` — cùng cú pháp với mẫu của
   `net/http` (`QC-12`), nên hai phía so được từng chữ.
3. Enum mã lỗi ở `components.schemas.ErrorCode.enum`, mỗi mã một dòng `- mã`; status của mỗi mã ở
   `ErrorCode.x-http-status`, mỗi dòng `mã: status`.
4. Bảng ánh xạ ở khoá gốc `x-constraint-errors`, mỗi dòng `tên: giá trị` (§4).
5. Không neo, không gộp khối (`&` · `*` · `<<`), không viết một ánh xạ trên một dòng ngoài `{}` rỗng.

Phần còn lại của file (schema của request, response) viết tự do theo OpenAPI 3.1.

## 3. Hình lỗi chung

Mọi lời từ chối của mọi đường gọi trả **cùng một hình** — schema `Error` của hợp đồng:

| Trường | Bắt buộc | Nghĩa |
|---|:--:|---|
| `code` | có | một giá trị của `ErrorCode`. FE chọn cách hiện **theo mã** — không theo status, không theo chữ |
| `field` | không | tên trường của yêu cầu gây lỗi, khi lỗi chỉ được về đúng một trường |

**Không có trường chữ cho người đọc.** Câu báo lỗi của database **không** bao giờ tới người dùng
(**ADR-082** điểm 5.2); chữ hiện ra là việc của pha 4, đọc từ mã.

**Status đi theo mã**, khai ở `ErrorCode.x-http-status` — mỗi mã đúng một status. Khuôn mở với hai mã
chung, không thuộc luật nào:

| Mã | Status | Khi nào |
|---|:--:|---|
| `internal_error` | 500 | mọi lời từ chối của database mà bảng §4 không ánh xạ ra mã công khai, và mọi lỗi không lường trước. Không bao giờ là *đã ghi* — cửa trả mã này thì giao dịch đã lùi (**ADR-082** điểm 5.3). |
| `invalid_request` | 400 | yêu cầu sai hình: JSON hỏng, thiếu trường bắt buộc, sai kiểu — kể cả tiền không phải số nguyên (§5) hay mốc thiếu độ lệch múi giờ (§6) |

**Mã của một luật do lát dựng cửa của luật ấy thêm**, cùng lượt, kèm test từ chối qua cửa **kiểm đúng
mã ấy** (**ADR-082** điểm 2). Mã viết snake_case tiếng Anh, nói *luật nào chặn*, không nói *màn nào
hiện gì*. Một cửa từ chối vì một câu nghiệp vụ **còn mở** (`U-XXX` · `S-X`) cũng trả một mã riêng của chỗ
đang mở ấy — không lấp bằng mặc định (kế hoạch pha 3 §4).

Code giữ bản của phần này ở `be/internal/apierr/` (`QC-14`): hằng mã, status, hàm dịch lời từ chối của
database và hàm gửi lỗi. Gate 1g so hai bản (§9).

## 4. Bảng tên từ chối → mã — `x-constraint-errors`

Lời từ chối của database tới cửa mang **tên** (`10-quy-uoc-code.md` `QC-10`, kể cả lời từ chối của
trigger từ migration bước 18). Cửa đọc tên, tra bảng này, trả mã theo §3 (**ADR-082** điểm 5). **Owner
của bảng là hợp đồng** — dòng nằm trong `openapi.yaml`, khoá `x-constraint-errors`.

**Mọi tên mà migration dựng có đúng một dòng** — ràng buộc, chỉ mục duy nhất, tên trong lệnh
`RAISE … USING CONSTRAINT` của hàm trigger. Giá trị là một trong ba:

| Giá trị | Nghĩa | Cửa trả |
|---|---|---|
| một mã của `ErrorCode` | luật này tới người dùng như một lời từ chối có tên | mã ấy, status của nó |
| `internal` | **đã xét**: không đường gọi nào làm database từ chối theo tên này, trừ khi hệ thống có lỗi — ví dụ khoá chính, vì `id` do database sinh (`QD-10`) | `internal_error`, ghi lại tên |
| `unreviewed` | **chưa lát nào xét** | `internal_error`, ghi lại tên |

**Ngày mở bảng**: khoá chính là `internal`; mọi tên khác là `unreviewed` — khuôn **không** đoán một
ràng buộc nghĩa là gì với người dùng; người đoán đúng là lát dựng cửa ghi vào bảng ấy. Số dòng đọc bằng
`./scripts/check-api-contract.sh`, không chép về đây (**F-018**).

**Ai sửa dòng nào, khi nào:**

1. **Lát dựng một cửa** xét lại mọi dòng của các bảng mà cửa ấy ghi: tên mà cửa có thể làm database từ
   chối thì thành một mã (thêm mã vào `ErrorCode` nếu chưa có) **hoặc** `internal` kèm lý do ở khối *Nhận
   việc* của lát. Test từ chối qua cửa kiểm **mã**, nên một dòng còn `unreviewed` ở đúng chỗ cửa từ chối
   làm test ấy đỏ — đó là cách bảng này không trôi.
2. **Lượt thêm migration** thêm một dòng cho mỗi tên mới (`unreviewed` nếu chưa có cửa) — Gate 1g đỏ khi
   thiếu. Gỡ hay đổi tên trong migration thì gỡ hay đổi dòng cùng lượt.
3. **Dòng mang mã công khai** có bản trong code: bảng `constraintCodes` ở `be/internal/apierr/`. Hai dòng
   `internal` · `unreviewed` không chép sang code — tên vắng mặt ở bảng code đã là `internal_error`.

## 5. Tiền trên dây

- Số tiền là **số nguyên JSON, đơn vị đồng**, không âm — schema `MoneyVnd`, dịch thẳng `QD-20` ·
  `QD-21`. Không chuỗi, không số có phần lẻ; gửi lên sai hình ⇒ `invalid_request`. Chiều đi của tiền nói
  bằng loại bản ghi, không bằng dấu trừ (`QD-21`).
- Trường tiền mang hậu tố `_vnd`, như cột (`QD-03`), và **luôn có mặt** khi schema khai nó — số 0 là một
  giá trị, không phải vắng mặt.
- **Mọi con số FE hiện ra là con số backend gửi xuống.** FE không cộng giá, không tính phụ thu, không
  tính tổng: giá tính ở một hàm của backend (`P3-06`), và giá client gửi lên không được dùng
  (`quality/invariants.md` **I-013**). Đường đọc nào cần cho FE hiện một tổng thì **trả** tổng ấy.

## 6. Mốc và ngày bán trên dây

- **Mốc** là chuỗi RFC 3339 **có độ lệch múi giờ** — schema `Instant`, một thời điểm tuyệt đối
  (`QD-30`). Backend gửi xuống mốc theo múi giờ của quán (`master_plan/shop-facts.md` §1, kết nối đặt
  múi giờ ấy — `QC-15`). Mốc gửi lên **thiếu** độ lệch ⇒ `invalid_request`: một giờ đồng hồ trần đọc theo
  múi giờ máy nào thì sai theo máy ấy.
- **Mốc tính tiền không nhận từ người gọi.** Backend cấp nó ở nơi ghi, lúc ghi
  (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §3). Ngoại lệ duy nhất là lượt **nhập bù**
  từ sổ giấy: mốc của buổi bán trên giấy do người khai, và cửa ấy ghi ai khai (§3 của file ấy, **ADR-037**,
  **I-012**) — lát của nó (`P3-11`) khai trường ấy trong hợp đồng, có tên riêng.
- **Ngày bán** là chuỗi `YYYY-MM-DD` — schema `SaleDate`, do backend quy từ mốc tính tiền theo múi giờ
  quán (`QD-31`). Cửa nào nhận một ngày bán từ người gọi — chẳng hạn chọn ngày để đối soát — thì lát của
  nó nói vì sao ở khối *Nhận việc*, với nguồn.

## 7. Phiên bản

`info.version` theo dạng `MAJOR.MINOR.PATCH`; **mỗi lượt đổi `openapi.yaml` tăng nó** — Gate 1g so với
bản ở `HEAD` và đỏ khi file khác mà phiên bản không lớn hơn.

- **Trước khi pha 4 nhận hợp đồng** (`MAJOR` = 0): mọi lượt đổi tăng `MINOR`; chỉ đổi chữ mô tả thì tăng
  `PATCH`.
- **Sau đó:** bỏ hay đổi nghĩa một trường, một mã, một đường gọi ⇒ tăng `MAJOR`; thêm ⇒ `MINOR`; chỉ mô tả
  ⇒ `PATCH`.
- **Không phiên bản trong đường dẫn** (không tiền tố kiểu `/v1`). Quán có một backend và một FE, triển
  khai cùng nhau; hai phiên bản đường gọi chạy song song là thứ không ai cần mà phải giữ cả hai.

## 8. Dấu lần gửi trên dây

Mọi đường gọi **tạo đơn hay tạo lượt gọi**, ở cả năm kênh, nhận dấu lần gửi của `I-024` trong **thân
yêu cầu**, trường `submission_code` — trùng tên cột `sales_order.submission_code`:

- schema `SubmissionCode`: một UUID chữ thường, **phía gửi sinh một lần lúc người bấm gửi**, và gửi lại
  **đúng chuỗi ấy** ở mọi lần gửi lại cùng lần bấm. Backend so từng byte (`QD-61`), không chuẩn hoá.
- Trường bắt buộc: thiếu dấu hay sai hình ⇒ `invalid_request` — một đơn không mang dấu là cách đi vòng
  mà `I-024` chặn, và cột `submission_code` cũng từ chối nó ở tầng 1.
- **Lần gửi lại nhận lại đúng đơn đã sinh**, cùng hình trả về của lần đầu — kể cả khi đơn đã đổi trạng
  thái hay cửa đã đóng sau đó. Cùng dấu mà khác nội dung ⇒ bị từ chối, đơn cũ giữ nguyên. Hai vế này là
  của `I-024`: `P3-07` trả **200** khi gửi lại, `submission_code_conflict` **409** khi nội dung khác; lần tạo trả **201**.
- Dấu nằm trong thân, không trong header: nó là một phần của nội dung được so ở vế *cùng dấu khác nội
  dung*, và type sinh từ hợp đồng bắt FE gửi nó như mọi trường bắt buộc khác.

**Cách so nội dung tại bàn** (`P3-07`, ADR-087, 2026-10-06): đặt hộ so `dining_table_id`; khách so
mã của đơn (`qr_code.code` qua `qr_code_id`) với mã trên đường dẫn. Hai đường khác kênh không phải cùng
nội dung. So số dòng và từng dòng **theo thứ tự**: `menu_item_id`, `quantity`, **tập** `option_ids`,
`is_takeaway`. Không tính lại giá hay đọc menu để quyết gửi lại. Quyền kiểm trước dấu: rời quầy hoặc mã
đã bị thay vẫn bị từ chối, kể cả cùng dấu. Khi tranh chấp khoá duy nhất của dấu hoặc phiên bàn, cửa
chạy lại toàn bộ giao dịch (tối đa bốn lần), từ quyền tới đọc dấu; không gộp theo nội dung.

**Cách so nội dung ngoài bàn** (`P3-08`, ADR-088, 2026-10-09): cùng đường gọi và kênh
(web khác hotline, delivery khác pickup, ngoài bàn khác tại bàn), cùng `handover_code`.
`customer_phone`, `delivery_address`, `customer_name`, `contact_note` so từng byte, vắng mặt tương
đương null; không bỏ khoảng trắng khi ghi hay so. `customer_needed_at` so cùng khoảnh khắc,
không so chuỗi độ lệch múi giờ, sau khi cắt về micro giây (độ chính xác của cột). Các dòng so như tại bàn, dấu đem về luôn mặc định false.
Tra dấu sau quyền và trước I-008: gửi lại trả trạng thái hiện tại cùng ảnh chụp, kể cả quán vừa
ngừng nhận đơn; khác nội dung trả `submission_code_conflict`. Tranh chấp dấu chạy lại cả giao dịch
như tại bàn. Cách thi công: [luồng mang đi](05-luong-mang-di.md).

## 9. Hợp đồng thắng code — và lệnh chấm điều ấy

**Hợp đồng thắng code** (**ADR-084**): code khác hợp đồng là lỗi của code. Đổi một đường gọi, một mã hay
một dòng ánh xạ là sửa `openapi.yaml` **trước** (tăng phiên bản, §7), rồi sửa code cho khớp, **cùng một
lượt**. Về tên ràng buộc, **migration thắng hợp đồng** (**ADR-053** luật 2): bảng §4 đi theo migration.

| Lệnh | Chạy khi nào | So gì |
|---|---|---|
| `./scripts/check-api-contract.sh` — **Gate 1g** | mọi lượt, kể cả lượt chỉ đổi tài liệu; chỉ đọc file | đường gọi ở hợp đồng ↔ `HandleFunc` · `Handle` trong `be/` (phải nêu phương thức); `ErrorCode` + status ↔ hằng và bảng status ở `be/internal/apierr/`; thư mục cửa ↔ dòng ma trận của [`02-vai-va-quyen.md`](02-vai-va-quyen.md) ↔ khai báo `authz.Door`, lớp hai phía bằng nhau (`P3-05`); tên trong migration ↔ dòng của `x-constraint-errors`; dòng mang mã ↔ `constraintCodes`; phiên bản ↔ `HEAD`. In số mỗi phía; `--list` in từng dòng. Đọc gì, đỏ khi nào: header của script. |
| `TestQC10_MoiTenTuChoiCoDongTrongHopDong` | `./scripts/be-check.sh` (Gate 1, khi `be/` · `db/` đổi) | tập tên đọc từ **database sống** ↔ dòng của `x-constraint-errors` — bắt cả tên Gate 1g không đọc được từ file |
| `TestQC10_LoiTuChoiTriggerMangTen` | cùng chỗ | lời từ chối của trigger tới pgx mang tên, và `apierr` dịch nó qua tên |

**Giới hạn có tên:** Gate 1g **không** so thân request · response với struct Go. Lát nào thêm đường gọi
chứng minh hình trả về bằng test gọi qua cửa trên PostgreSQL thật (**ADR-082** điểm 2), đọc JSON trả về
theo schema của hợp đồng.

## 10. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P3-05` | **xong 2026-10-06** — §3 thêm mã của lời từ chối quyền; §4 xét dòng `qr_code_*` (bảng cửa của lát ghi); dòng `person` · `counter_duty` để lại cho lát ghi hai bảng ấy (`P3-11`, lane admin); ma trận cửa × lớp ở [`02-vai-va-quyen.md`](02-vai-va-quyen.md), Gate 1g so nó với code (§9) |
| `P3-06` | **xong 2026-10-06** — §1 thêm sáu đường gọi (tính thử, menu, bốn cửa sửa menu); §3 sáu mã của giá và menu; §4 xét dòng của bảng menu và bảng dòng đơn (`internal`), dòng `sales_order_*` để lại cho phần kênh của cửa tạo lượt gọi (`P3-07` · `P3-08`); hàm và bảng ca: [`03-ham-gia.md`](03-ham-gia.md) |
| `P3-07` | **xong 2026-10-06** — thêm tám đường gọi tại bàn, mười mã; xét ràng buộc của đơn tại bàn, phiên, bàn và hoá đơn; §8 so nội dung và trả lại đơn; [luồng tại bàn](04-luong-tai-ban.md) |
| `P3-08` | **xong 2026-10-09** — ba đường gọi ngoài bàn, bốn mã 409; liên hệ tối thiểu, dấu lần gửi, I-008 cho cả năm kênh và rời quán có chặn S-6; xét năm ràng buộc liên hệ; [luồng mang đi](05-luong-mang-di.md) |
| `P3-09`…`P3-12` | §1 thêm đường gọi cùng lượt dựng cửa · §3 mã của luật · §4 xét dòng của bảng mình ghi · §5 · §6 · §7 tăng phiên bản |
| `P3-13` | §9 — ô cổng *hợp đồng khớp code*: Gate 1g xanh và đã từng đỏ (`scripts/check-api-contract.test.sh`) |
| pha 4 | `openapi.yaml` — sinh type; §3 cách đọc lỗi; §5 không tự tính |

[↑ đầu file](#top)
