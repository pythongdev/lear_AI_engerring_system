# Lược đồ lát chấm công — một ô có đi làm của một người một ngày

Pha 2 · bước `P2A-03` · viết 2026-09-30 · thi công Codex, thiết kế Claude Code.
Quyết định: `docs/decisions.md` **ADR-072**. Lát này thêm một file, không ghi đè lát trước.

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260930110000_cham_cong.up.sql`](../../../db/migrations/20260930110000_cham_cong.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-027` / `YC-30`; tên bảng và tên ràng buộc chỉ để
trỏ, không chép kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch ⇒ một dòng `F-XXX`.

**File này KHÔNG sở hữu:**
- **lời chủ quán** — `master_plan/shop-facts.md` §8.7; chỉ trỏ, không chép lời;
- **mệnh đề và tầng bảo vệ** — `quality/invariants.md` `I-027` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` §5; yêu cầu dữ liệu ở
  `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, dòng `YC-30`;
- **người và cơ chế vết** — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md), dùng lại
  lát `P2-08`, kể cả chế độ mềm **F-046**: sửa không khai lý do chưa để lại vết;
- **cửa ghi xét người tick** — pha 3; **câu đối chiếu** — đã có câu `db/reconcile/i027.sql` và lỗi cài ở `db/reconcile/proof/` (P2A-07, 2026-10-01);
- **quy ước cất và kiểm** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md) ·
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md); thứ tự và đường lùi ở
  [`07-thu-tu-migration.md`](07-thu-tu-migration.md).

---

## 0. Cách đọc

Hai nguồn: **owner** là mệnh đề, yêu cầu và lời chủ quán tại các con trỏ trên; **phiên chọn
2026-09-30 (ADR-072)** là lựa chọn thiết kế để thi hành chúng. Lựa chọn không thành lời chủ quán.
Các bằng chứng dưới đây trỏ câu `NOTICE` trong
`db/tests/i027_attendance_one_box_per_worker_day.sql`, chạy bằng `./scripts/db-check.sh`
(`QC-07`); chúng không thay câu đối chiếu; đã có câu `db/reconcile/i027.sql` và lỗi cài ở `db/reconcile/proof/` (P2A-07, 2026-10-01).

---

## 1. Một bảng — giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao có nó · nguồn |
|---|---|---|
| `attendance_day` | một ô có đi làm, người được chấm, ngày của ô, người tick và lúc tick; nếu ô đã huỷ: lúc huỷ, người huỷ, ghi chú | owner: `I-027` · `YC-30`; phiên chọn 2026-09-30: một dòng cho một ô đã tick, không sinh sẵn ô chưa tick |

`worker_person_id` là người được chấm; `person_id` là người tick, lấy mặc định từ người thao tác
của giao dịch qua `actor_person_id()`. Cả hai dùng `person` của lát `P2-08`, không dựng danh sách
người thứ hai. Tên cột riêng cho người được chấm giữ nghĩa *ai bấm* của cột dùng chung.

`work_date` là ngày người khai; `created_at` là lúc ghi do database cấp. Hai thứ đọc riêng,
không buộc trùng ngày. Không có dòng nghĩa là không có ô; không suy từ đó thành một ngày nghỉ
đã ghi. Lý do và lựa chọn này ở **ADR-072** điểm 1 · 2 · 5.

**Huỷ một ô** (lời chủ quán đóng `U-070`, 2026-09-30 — owner: `master_plan/shop-facts.md` §8.7) là ba
dấu ghi ngay trên dòng của ô: `cancelled_at`, `cancelled_by_person_id`, `cancel_note`. Ô đã huỷ **ở
lại** để kiểm lại và không còn tính là *có đi làm*; khoá duy nhất chỉ đếm ô chưa huỷ, nên tick lại
đúng người, đúng ngày ấy được nhận. **ADR-072** điểm 4.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng theo `03-bao-ve-invariant.md` §5, không tự nâng hay hạ. **Test I-027** dưới đây là file test
đã trỏ ở §0; phần in nghiêng trỏ câu `NOTICE` của file ấy. Các hàng là ánh xạ từng vế, không thay
câu mệnh đề ở owner.

| Mệnh đề · vế | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-027` · `YC-30`** — người được chấm | 1 | dấu người bắt buộc; `attendance_day_worker_person_fkey` dùng tập người đã có | test I-027 — *bị từ chối (ô không gắn người nào)* · *(người không phải người của quán)* |
| **`I-027` · `YC-30`** — ngày của ô và đọc lại nhiều ngày | 1 | ngày bắt buộc của `attendance_day`, tách khỏi lúc tick | test I-027 — *bị từ chối (ô không có ngày)*; *YC-30 ô có đi làm* đọc ba ô; *I-027 đọc lại* đếm ngày của hai người |
| **`I-027` · `YC-30`** — chống ô trùng còn hiệu lực | 1 | `attendance_day_one_live_per_worker_day_key` — chỉ đếm ô chưa huỷ | test I-027 — *bị từ chối (ô thứ hai cùng người, cùng ngày)* · *(ô còn hiệu lực thứ hai, sau khi đã tick lại)* |
| **`I-027` · `YC-30`** — ô tick nhầm được huỷ, ô đã huỷ không biến mất | 1 | ba dấu huỷ trên dòng của ô; `attendance_day_cancelled_by_iff_cancelled_check` · `attendance_day_cancelled_by_person_fkey` · `attendance_day_cancelled_after_created_check` · `attendance_day_cancel_note_only_when_cancelled_check`; vai ghi không xoá, không đổi người hay ngày | test I-027 — *YC-30 ô đã huỷ* đọc ai huỷ, lúc huỷ, ghi chú; *tick lại sau khi huỷ — nhận*; bốn dòng *bị từ chối (huỷ …)* và *(ghi chú huỷ …)*; *ô đã tick không đổi được người hay ngày* · *QD-50 ô không xoá được, kể cả ô đã huỷ* |
| **`I-027` · `YC-30`** — người tick và lúc tick | 1 | hai dấu bắt buộc; người mặc định lấy từ giao dịch, `attendance_day_person_fkey`; lúc ghi mặc định do database cấp | test I-027 — *bị từ chối (ô không có người tick)* · *(người tick không phải người của quán)*; *YC-30 ô có đi làm* đọc tên người tick và có lúc tick |
| **`I-027`** — người tick là chủ quán | 3 | database **không xét** cờ chủ quán; cửa ghi pha 3 xét, đã có câu `db/reconcile/i027.sql` và lỗi cài ở `db/reconcile/proof/` (P2A-07, 2026-10-01) | test I-027 — *tầng 3 — ô do người KHÔNG phải chủ quán tick: database nhận* |
| **`YC-30`** — không tách buổi hay giữ mốc tới, về | — | danh sách cột đóng của một bảng, không bảng phụ | test I-027 so danh sách bảng và cột từng chữ — *đọc lược đồ — attendance_day* |
| **`I-027` · `YC-30`** — không ô nào sinh khoản trừ | 3 | không chỗ cất khoản trừ, không đường nối tới khoản trừ; kiểm bằng đọc lược đồ, không phải điều kiện kiểm trên từng ô | test I-027 — *đọc lược đồ — 0 khoá ngoại ngoài ba khoá về người, 0 hàm nhắc tới ô, 0 trigger ngoài trigger vết* |
| **ADR-072 điểm 4 · `QD-50` · `QD-52`** — quyền của vai ghi | — | `shop_app` chèn được ô và chỉ cập nhật được ba dấu huỷ; quyền xoá không được cấp; `attendance_day_record_revision_trg` dùng cơ chế vết sẵn có | test I-027 — khối tick rồi huỷ chạy dưới vai `shop_app`; *ô đã tick không đổi được người hay ngày (shop_app)*; *QD-50 ô không xoá được*; phép kiểm `QD-52` giữ trigger |

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **Người tick là chủ quán** là tầng 3. Database chỉ giữ người tick thuộc tập người của quán;
  cửa ghi phải khai đúng người thao tác và xét người ấy. Sửa tay bỏ qua cửa ghi là giới hạn đã biết.
- **Không ô nào sinh khoản trừ** là tầng 3, kiểm bằng đọc lược đồ như bảng §2. Lát không dựng
  hàm, view hay đường ghi khác từ ô sang tiền.
- **Người khác tick trên máy chủ quán đang mở** là giới hạn tầng 4 của owner: dữ liệu không
  phân biệt được người đang cầm máy. Không coi tên người tick là bằng chứng đã chặn được việc ấy.
- **Ghi chú huỷ và người huỷ** — database nhận một lần huỷ **không ghi chú** và **không xét** người
  huỷ có phải chủ quán không; test in thẳng cả hai. Lời chủ quán chưa nói (**U-071**); cửa huỷ của
  pha 3 đứng trên chỗ này.
- **Bỏ huỷ** không có đường riêng: vai ghi sửa được ba dấu huỷ, nên xoá trắng chúng là một lần cập
  nhật đi qua vết ở chế độ mềm (**F-046**). Khoá duy nhất vẫn chặn việc ấy khi đã có ô tick lại.
- **Vết sửa bằng tay** dùng cơ chế chung của `P2-08`. **F-046** vẫn áp dụng: sửa không khai lý do
  chưa để lại vết. Thu quyền cập nhật của `shop_app` không làm cơ chế chung thành chế độ nghiêm.

---

## 4. Suy ra, không phải lời chủ quán

Các lựa chọn **phiên chọn 2026-09-30** được quyết tại `docs/decisions.md` **ADR-072**, không phải
lời chủ quán: không có dòng là không có ô; ghi chú huỷ để trống được và người huỷ không bị xét; huỷ
rồi tick lại được; nhận ô cho ngày đã qua; không cấm cũng không đòi chấm công cho chính chủ quán. Lát không có
cột trạng thái hay mã có/không để cần bảng ánh xạ `QD-40`.

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| Ghi chú huỷ có bắt buộc không, ai được bấm huỷ — **U-071**, `docs/product/99-unknowns.md` | ghi chú trống được; người huỷ chỉ cần là người của quán | chủ quán trả lời; owner cập nhật trước khi siết |
| Ngưỡng đi muộn — **C32**, `master_plan/shop-facts.md` §8.7 | không giờ tới, không ngưỡng, không dấu đi muộn | chủ quán; Claude ghi lời trước khi dựng |
| Ngày nghỉ — **C30**, cùng owner | không ô không mang nghĩa ngày nghỉ đã ghi; không chỗ cất loại nghỉ | chủ quán; Claude làm rõ vế còn thiếu |
| Công đổi ra lương — **C26 · C33**, cùng owner | không đơn giá, không công thức hay khoản tiền nối từ ô | chủ quán làm rõ đơn vị, kỳ trả và đơn giá; Claude quyết thiết kế sau |
| Ô cho ngày đã qua | ngày của ô tách lúc tick; lát không cấm, không quyết hộ quy tắc tick bù | owner chưa có lời; ADR-072 điểm 5 giữ chỗ này mở |
| Câu đối chiếu `I-027` | đã có câu `db/reconcile/i027.sql` và lỗi cài ở `db/reconcile/proof/` (P2A-07, 2026-10-01); ánh xạ ở [`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md) §1 · §2 | `P2A-07` đã viết câu và lỗi cài, 2026-10-01 |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát không thêm bảng nào vào `:bang_ky_thuat` hay
`:bang_khong_quan_he_so_hoc`.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2A-07` | §2 ánh xạ và giới hạn bằng chứng; đã có câu `db/reconcile/i027.sql` và lỗi cài ở `db/reconcile/proof/` (P2A-07, 2026-10-01) |
| `P2A-08` | §2 phép đọc lược đồ và §3 giới hạn của từng tầng |
| pha 3 | §3 khai người thao tác, xét người tick và người huỷ; §5 hai chỗ của lần huỷ còn chờ lời |
