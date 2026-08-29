# 00 — Master BA (L3: thiết kế & chia việc)

> Level 3. Đây **không** phải prompt viết tài liệu nghiệp vụ. Đây là prompt chốt kế hoạch,
> chia việc và dựng khung. Không viết nội dung §3–§8 của `docs/product.md` trong prompt này.

## Context

- Kế hoạch BA gốc: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` (đọc §2–§14) — cho **khung**.
- Dữ kiện quán: `master_plan/shop-facts.md` (đọc toàn bộ) — cho **số liệu cụ thể**. §8 của file này
  có 5 unknown còn treo, trong đó **U-1 (chưa có bảng giá thật) chặn BA-06 và BA-11**.
- Nguồn sự thật cần điền: `docs/product.md`, `docs/decisions.md`, `quality/invariants.md`,
  `work/backlog.md` — hiện đang là template rỗng.
- Quy tắc viết prompt/task: `docs/prompt-guideline.md`. Quy tắc nghiệm thu: `quality/review-gate.md`.
- Bộ prompt con đã có sẵn trong `prompt/BA/` (01 → 10), mỗi prompt một kết quả.
- Dự án chưa có code. Giai đoạn này chỉ chốt nghiệp vụ.

## Goal

`work/backlog.md` có kế hoạch BA thực thi được: 11 task BA-01–BA-11 với thứ tự phụ thuộc,
acceptance riêng và đầu ra kiểm chứng được, kèm khung mục lục `docs/product.md` để các
prompt con điền vào mà không giẫm chân nhau.

## Scope

Được sửa:
- `work/backlog.md`
- `docs/product.md` (chỉ dựng **mục lục và tiêu đề mục rỗng**, không viết nội dung nghiệp vụ)

Không được sửa:
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`, `master_plan/shop-facts.md` (là input, không phải sản phẩm)
- `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md`, `master_plan/prompt-fullstack.md`
- `docs/architecture.md`, `docs/decisions.md`, `quality/invariants.md` (thuộc prompt con)
- `prompt/BA/*` (bộ prompt con đã chốt)
- Mọi file trong `scripts/`, `.claude/`

Dòng chép vào `work/scope.txt`:
```text
work/backlog.md
docs/product.md
```

## Constraints

- Không phát minh business truth. Mọi thứ chưa có trong kế hoạch gốc → ghi thành câu hỏi
  trong mục Unknowns của task tương ứng, không tự chốt.
- Không viết bất kỳ nội dung nào về BE, FE, DB schema, API endpoint, component, framework,
  Docker/CI — kể cả dạng gợi ý. Đó là scope của System Design.
- **Không đọc, không trích `master_plan/prompt-fullstack.md`.** File đó chứa stack, 16 bảng dữ
  liệu, endpoint và cây route; phần nghiệp vụ dùng được đã trích sẵn sang `shop-facts.md`.
  Cần dữ kiện quán ⇒ lấy ở `shop-facts.md`, không lấy ở `prompt-fullstack.md`.
- Mỗi task trong backlog phải revert được độc lập (mỗi task chạm một mục tài liệu riêng).
- Giữ nguyên ID BA-01–BA-11 và quan hệ phụ thuộc trong §11 của kế hoạch gốc. Không đổi số,
  không gộp, không thêm task mới nếu không có lý do ghi rõ.
- Khung `docs/product.md` phải khớp bảng mục ở §11 dưới đây, vì các prompt con khai scope theo nó.

## Deliverables

1. `work/backlog.md`: 11 task BA-01–BA-11 ở mục **Ready**, mỗi task theo Task Detail Template
   sẵn có (Goal / Scope / Out of scope / Acceptance / Verify), cộng dòng `Prompt:` trỏ tới file
   prompt tương ứng trong `prompt/BA/`.
2. `docs/product.md`: mục lục 8 mục dưới đây, mỗi mục chỉ có tiêu đề + một dòng
   `> Chưa chốt — BA-0N` làm chỗ giữ.
3. Danh sách 10 câu hỏi ở §10 kế hoạch gốc **và 5 unknown U-1–U-5 ở §8 `shop-facts.md`** được
   phân bổ về đúng task sẽ trả lời chúng (ghi trong mục Acceptance hoặc Unknowns của task đó
   trong backlog). U-1 phải được ghi là **chặn** BA-06 và BA-11.

Khung mục `docs/product.md`:

| Mục | Tiêu đề | Task |
|---|---|---|
| §1 | Actor và phạm vi hệ thống | BA-01 |
| §2 | Kênh bán | BA-02 |
| §3 | Ba lát cắt nghiệp vụ | BA-03, BA-04, BA-05 |
| §4 | Giá và thanh toán | BA-06 |
| §5 | Vòng đời nghiệp vụ | BA-07 |
| §6 | Ngoại lệ | BA-08 |
| §7 | Phạm vi MVP | BA-09 |
| §8 | Scenario nghiệm thu BA | BA-11 |

## Acceptance

- `work/backlog.md` có đúng 11 task ID BA-01–BA-11, không thiếu, không thừa.
- Mỗi task có Acceptance viết dạng điều kiện quan sát được (đúng/sai), không có dòng nào
  kiểu "hoạt động tốt", "rõ ràng", "đầy đủ".
- Mỗi task có dòng `Prompt:` trỏ tới một file tồn tại trong `prompt/BA/`.
- Thứ tự phụ thuộc trong backlog khớp cột "Cần xong trước" của §11 kế hoạch gốc.
- `docs/product.md` có đúng 8 tiêu đề mục theo bảng trên, mỗi mục có chỗ giữ, không mục nào
  chứa nội dung nghiệp vụ đã chốt.
- 10 câu hỏi ở §10 kế hoạch gốc đều xuất hiện trong backlog, mỗi câu gắn với ít nhất một task.
- 5 unknown U-1–U-5 ở §8 `shop-facts.md` đều xuất hiện trong backlog; U-1 và U-2 được đánh dấu
  chặn task nào, không chỉ ghi cho có.
- Không có file mới nào được tạo ngoài hai file trong Scope.
- Không có chuỗi `endpoint`, `schema`, `API`, `component`, `Docker` trong nội dung mới thêm.

## Verify

```bash
./scripts/gate.sh
grep -c 'BA-0\|BA-1' work/backlog.md          # ≥ 11 dòng có ID task
grep -n '^## ' docs/product.md                # 8 mục, đúng thứ tự bảng trên
grep -nEi 'endpoint|schema|component|docker' docs/product.md work/backlog.md   # không có kết quả
grep -n 'U-1' work/backlog.md                 # unknown chặn có mặt và ghi rõ chặn task nào
git status --porcelain                        # chỉ 2 file trong Scope thay đổi
```
Gate 2: đọc lại từng dòng Acceptance ở trên và chỉ ra chỗ trong file chứng minh nó.

## Unknowns

- Chưa có câu hỏi mới. Prompt này chỉ chia việc; các câu hỏi nghiệp vụ được chuyển về task con,
  không trả lời ở đây.
- Đã biết trước: `shop-facts.md` §8 U-1 — **chưa có bảng giá và danh sách món đầy đủ**
  (nhà thật `00-scope.md` của dự án cũ không có trong repo này). Không tự bịa giá.
  Việc của prompt này là **ghi nó thành vật cản có tên trong backlog**, không phải giải nó.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
