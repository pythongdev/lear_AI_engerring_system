# Lược đồ lát khoản của người — tạm ứng và thưởng lễ Tết

Pha 2 · bước `P2A-04` · viết 2026-09-30 · thi công Codex, thiết kế Claude Code.
Quyết định: `docs/decisions.md` **ADR-073**. Lát này thêm một file, không ghi đè lát trước.

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260930120000_khoan_cua_nguoi.up.sql`](../../../db/migrations/20260930120000_khoan_cua_nguoi.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-028` / `YC-31` / `YC-32`; tên bảng và tên ràng
buộc chỉ để trỏ, không chép kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch ⇒ một dòng `F-XXX`.

**File này KHÔNG sở hữu:**
- **lời chủ quán** — `master_plan/shop-facts.md` §8.7; chỉ trỏ, không chép lời;
- **mệnh đề và tầng bảo vệ** — `quality/invariants.md` `I-028` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` §5; yêu cầu dữ liệu ở
  `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, dòng `YC-31` · `YC-32`;
- **người và cơ chế vết** — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md), dùng lại
  lát `P2-08`, kể cả chế độ mềm **F-046** ở `work/findings.md`;
- **cửa ghi xét người duyệt** — pha 3; **câu đối chiếu** — `P2A-07`;
- **quy ước cất và kiểm** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md) ·
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md); thứ tự và đường lùi ở
  [`07-thu-tu-migration.md`](07-thu-tu-migration.md).

---

## 0. Cách đọc

Hai nguồn: **owner** là mệnh đề, yêu cầu và lời chủ quán tại các con trỏ trên; **phiên chọn
2026-09-30 (ADR-073)** là lựa chọn thiết kế để thi hành chúng. Lựa chọn không thành lời chủ quán.
Các bằng chứng dưới đây trỏ câu `NOTICE` trong
`db/tests/i028_advance_and_bonus_name_a_worker.sql`, chạy bằng `./scripts/db-check.sh`
(`QC-07`); chúng không thay câu đối chiếu của `P2A-07`.

---

## 1. Hai bảng — giữ gì, và vì sao có chúng

| Bảng | Giữ gì | Vì sao có nó · nguồn |
|---|---|---|
| `staff_advance` | một khoản tạm ứng, người nhận, số tiền, ngày, người duyệt, người ghi và lúc ghi | owner: `I-028` · `YC-31`; ADR-073 điểm 1 · 2 tách dấu người duyệt khỏi người ghi |
| `holiday_bonus` | một khoản thưởng lễ Tết, người nhận, số tiền, ngày, người ghi và lúc ghi | owner: `I-028` · `YC-32`; ADR-073 điểm 1 không dựng sẵn người duyệt hay loại thưởng |

Cả hai dùng tập `person` của lát `P2-08`, không dựng danh sách người thứ hai. Người nhận là người
mà khoản nói về; người ghi là người thao tác; người duyệt là người cho phép tạm ứng. Ba vai không
bị gộp làm một. Ngày của khoản đứng riêng với lúc ghi, để đọc được khoản ghi lại cho ngày đã qua.
Lý do của cách tách này nằm ở **ADR-073** điểm 2 · 4.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng theo `03-bao-ve-invariant.md` §5. **Test I-028** dưới đây là file test ở §0; phần in nghiêng
trỏ câu `NOTICE` của file ấy. Vế vết sửa chưa đạt đủ tầng đã chốt được nói rõ ở §3.

| Mệnh đề · vế | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-028` · `YC-31` · `YC-32`** — người nhận | 1 | dấu bắt buộc; `staff_advance_worker_person_fkey` · `holiday_bonus_worker_person_fkey` | test I-028 — *bị từ chối (tạm ứng không có người nhận)* · *(thưởng không có người nhận)* và hai câu *người nhận không phải người của quán* |
| **`I-028` · `YC-31` · `YC-32`** — số tiền | 1 | dấu bắt buộc; `staff_advance_positive_amount_check` · `holiday_bonus_positive_amount_check` | test I-028 — hai câu *không có số tiền*, hai câu *0đ* và hai câu *QD-21 bị từ chối* |
| **`I-028` · `YC-31` · `YC-32`** — ngày, đọc lại khoản đã đưa | 1 | ngày bắt buộc ở hai bảng, tách lúc ghi | test I-028 — hai câu *không có ngày*; *YC-31 tạm ứng* · *YC-32 thưởng lễ Tết*; *khoản thứ hai cùng người cùng ngày — nhận* |
| **`I-028` · `YC-31` · `YC-32`** — người ghi và lúc ghi | 1 | hai dấu bắt buộc; `staff_advance_person_fkey` · `holiday_bonus_person_fkey`; mặc định theo cơ chế chung của lát người và vết | test I-028 — hai câu *không có người ghi*, *người ghi không phải người của quán*; *YC-31 tạm ứng* · *YC-32 thưởng lễ Tết* đọc tên người ghi và có lúc ghi |
| **`I-028` · `YC-31`** — tạm ứng có người duyệt | 1 | dấu bắt buộc phải khai; `staff_advance_approver_person_fkey` | test I-028 — *tạm ứng không có người duyệt* · *người duyệt không phải người của quán*; *kiểm ngược* in số khoản thiếu người duyệt |
| **`I-028` · `YC-31`** — người duyệt là chủ quán | 3 | database không xét; cửa ghi pha 3 và câu đối chiếu giữ vế này | test I-028 — *tầng 3 — tạm ứng do người KHÔNG phải chủ quán duyệt: database nhận* |
| **`I-028` · `YC-31` · `YC-32`** — không sửa đè | theo `I-018`, còn nợ F-046 | trigger vết trên hai bảng dùng cơ chế chung; `record_revision` giữ bản trước, bản sau, lý do, người sửa khi có khai lý do | test I-028 — *sửa khoản* đọc ba lần sửa bằng vai ghi; *chế độ mềm — sửa số tiền không khai lý do: 0 vết mới (F-046)* |
| **`I-028` · `YC-31` · `YC-32`** — không phải tiền bán hàng | 3 | hai bảng chỉ nối về người, không đường sang doanh thu hay tiền đã thu | test I-028 — *không phải tiền bán hàng* so số dòng mọi bảng khác; *đọc lược đồ — 0 khoá ngoại ngoài các khoá về người, 0 hàm nhắc tới hai bảng, 0 trigger ngoài trigger vết* |
| **`YC-32`** — không cất sẵn thưởng ngày đông khách | — | hình đóng của `holiday_bonus` theo ADR-073 điểm 1 · 8 | test I-028 — *đọc lược đồ — holiday_bonus* so danh sách cột từng chữ, không người duyệt, không loại thưởng, không chỗ cho thưởng ngày đông khách |
| **ADR-073 điểm 6 · `QD-50`** — quyền của vai ghi | — | thu quyền sửa cả bảng, chỉ cấp lại ba dấu được sửa; không cấp quyền xoá | test I-028 — *vai shop_app ghi được một khoản tạm ứng và một khoản thưởng*; *sửa khoản*; ba câu *không đổi được (shop_app)* và hai câu *QD-50 … không xoá được (shop_app)* |

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **Người duyệt là chủ quán** là tầng 3, database không xét. Cửa ghi pha 3 phải xét người duyệt
  và khai đúng người thao tác. Sửa tay bỏ qua cửa ghi là giới hạn đã biết.
- **Không phải tiền bán hàng** là tầng 3. Lát không dựng đường nối tới doanh thu hay tiền đã thu;
  phép đọc lược đồ và so số dòng trong test chỉ chứng minh phạm vi đó.
- **Vết ở chế độ mềm (F-046)**: sửa không khai lý do vẫn đi qua mà không để lại vết. Vì vậy vế
  **không sửa đè hôm nay thấp hơn tầng pha 1 đã chốt**, cùng khoản nợ với `I-018`. Cửa ghi pha 3
  và câu đối chiếu phải giữ vế còn thiếu; quyền sửa theo cột không làm cơ chế vết thành nghiêm.
- **Chưa nối két**: chờ task `T-125` ở `work/backlog.md` viết lại mệnh đề và phép trừ két; lát này
  không thay việc ấy bằng một dấu nối dựng sẵn.

---

## 4. Suy ra, không phải lời chủ quán

Các lựa chọn **phiên chọn 2026-09-30** và lý do nằm ở `docs/decisions.md` **ADR-073**, mục
*Decision* và *Suy ra, không phải lời chủ quán*. File này chỉ trỏ quyết định ấy, không chép lại
thành luật thứ hai. Lát không có trạng thái hay mã loại để cần bảng ánh xạ `QD-40`.

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| Nối khoản vào két | không đường nối; mệnh đề chưa viết lại theo lời đóng câu hỏi nguồn tiền | task `T-125` ở `work/backlog.md`, trước migration nối két |
| Vết sửa không khai lý do | chế độ mềm, chưa bảo vệ đủ vế không sửa đè | đường gỡ **F-046** ở `work/findings.md`, cho mọi bảng |
| Câu đối chiếu `I-028` | lát đã có, câu và lỗi cài chưa viết; [`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md) §2.1 giữ tên khoản nợ | `P2A-07` |
| Trừ hay cộng vào lương — **C26 · C33**, `master_plan/shop-facts.md` §8.7 | không dấu đã trừ, không công thức hay kỳ lương | chủ quán làm rõ, Claude quyết thiết kế sau |
| Trả lại tạm ứng — `I-028` mục Why | không trạng thái hay đường trả lại | chủ quán cho lời, Claude ghi owner trước |
| Người duyệt thưởng, dịp lễ và thưởng ngày đông khách — **C28**, cùng owner | không dựng sẵn dấu cho những việc chưa có lời | chủ quán; Claude cập nhật owner trước khi dựng |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát không thêm bảng nào vào `:bang_ky_thuat` hay
`:bang_khong_quan_he_so_hoc`.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2A-07` | §2 ánh xạ và giới hạn bằng chứng; viết câu đối chiếu cùng lỗi cài |
| `P2A-08` | §2 kịch bản đọc, sửa và phép đọc lược đồ; §3 giới hạn của từng tầng |
| task `T-125` | §3 · §5 ranh giới chưa nối két |
| pha 3 | §3 xét người duyệt, khai người thao tác và lý do sửa; §5 các chỗ còn chờ lời |
