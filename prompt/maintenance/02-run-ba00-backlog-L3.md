# 02 — Chạy BA-00 sau khi BA-01/BA-02 đã xong (L3) · T-008

> Prompt này **không thay thế** `prompt/BA/00-master-L3.md`. Nó là bản hướng dẫn chạy prompt đó
> **trong tình trạng hôm nay**: BA-01 và BA-02 đã chạy rồi, nên chạy nguyên văn sẽ ghi đè nội dung
> thật bằng chỗ giữ. Đọc cả hai file, làm theo BA-00, trừ ba điều chỉnh ở mục Constraints.

## Context

- `prompt/BA/00-master-L3.md` là prompt **chia việc** của cả giai đoạn BA: dựng `work/backlog.md`
  gồm 11 task BA-01–BA-11 với thứ tự phụ thuộc, acceptance riêng và khung mục `docs/product.md`.
  **Nó chưa từng được chạy.**
- Nhưng prompt **01** thì đã chạy (commit `e801668`, 2026-08-30): `docs/product.md` §1 và §2 có nội
  dung thật, khung §3–§8 đã dựng sẵn với chỗ giữ `> Chưa chốt — BA-0N`, mục Unknowns đã có.
  Backlog hiện có BA-01, BA-02 ở **Done**; **BA-03–BA-11 chưa tồn tại**.
- Hệ quả: Deliverable 2 của BA-00 ("dựng mục lục + chỗ giữ") **đã xong**. Chạy nguyên văn sẽ xoá
  §1/§2 để thay bằng `> Chưa chốt` — mất trắng công của một task đã nghiệm thu.
- Sáu câu hỏi từng treo (`U-001`–`U-004`, `S-1`–`S-3`) đã được chủ quán trả lời hết ngày
  2026-08-30. `shop-facts.md` §7.2 **rỗng**, `docs/product.md` → Unknowns **rỗng**.
- Nếu `prompt/maintenance/01-fix-plan-channel-count-L1.md` (T-007) chưa chạy thì kế hoạch gốc còn
  nói "bốn kênh" ở §11 dòng 260. Thứ tự phụ thuộc ở §11 vẫn dùng được — chỉ chữ "bốn" là sai.
  **Đừng chép chữ đó vào backlog.**

## Goal

`work/backlog.md` có đủ kế hoạch BA thực thi được: 11 task BA-01–BA-11, đúng ID, đúng thứ tự phụ
thuộc, BA-01/BA-02 nằm ở Done với ngày và commit, BA-03–BA-11 nằm ở Ready với acceptance quan sát
được và dòng `Prompt:` trỏ tới file có thật.

## Scope

Được sửa:
- `work/backlog.md`
- `docs/product.md` — **chỉ** khi tiêu đề §3–§8 lệch bảng khung ở BA-00; sửa tiêu đề, không viết
  nội dung

Không được sửa:
- `docs/product.md` §1, §2 và mục Unknowns — **một ký tự cũng không**
- `master_plan/*` (input), `docs/decisions.md`, `quality/invariants.md` (thuộc prompt con)
- `prompt/BA/*`, `prompt/maintenance/*`
- `scripts/`, `.claude/`

Dòng chép vào `work/scope.txt`:
```text
work/backlog.md
docs/product.md
work/scope.txt
```

## Constraints

Làm theo `prompt/BA/00-master-L3.md` — Goal, Constraints, Deliverables 1 và 3, Acceptance — với
**ba điều chỉnh**, và chỉ ba:

1. **Không đụng `docs/product.md` §1, §2, Unknowns.** Deliverable 2 của BA-00 coi như đã xong.
   Việc duy nhất còn lại ở file đó là đối chiếu tiêu đề §3–§8 với bảng khung; lệch thì sửa tiêu đề.
2. **BA-01 và BA-02 vào mục Done, không phải Ready** — đã chạy 2026-08-30, commit `e801668`, prompt
   `prompt/BA/01-actors-channels-L1.md`. Backlog hiện đã có một entry chung cho hai task đó; giữ
   nguyên, đừng tạo bản thứ hai.
3. **Không mang S-1–S-3 vào backlog dạng giả định.** Chúng đã chốt 2026-08-30 (`shop-facts.md`
   §7.1). Acceptance gốc của BA-00 đã được sửa theo — nếu bản bạn đọc vẫn bắt ghi S-1 là "chạm
   tiền chưa xác nhận" thì đó là bản cũ, dừng lại và báo.

Thêm hai ràng buộc riêng của lần chạy này:

- **10 câu hỏi ở §10 kế hoạch gốc: bốn câu đã có lời giải, đừng mở lại.** Phân bổ chúng kèm nguồn
  thay vì biến thành unknown mới:

  | § | Câu hỏi | Trạng thái |
  |---|---|---|
  | 1 | Ai xác nhận / **huỷ** / chỉnh sửa đơn | xác nhận → `shop-facts.md` §6.2 · huỷ → §6.13 (chốt 2026-08-30). **Chỉnh sửa đơn thì chưa ai nói** — phần này còn mở |
  | 5 | Có hoàn tiền không, ai được | **đã chốt** → §6.4 (quầy quyết từng ca, phải ghi vết) |
  | 6 | Pickup có cần giờ hẹn bắt buộc | **đã chốt** → §6.5 (bắt buộc) |
  | 7 | Delivery có quản lý trạng thái giao | **đã chốt** → §6.7 (có trạng thái "đang giao") |
  | 2, 3, 4, 8, 9, 10 | sửa đơn đã xác nhận · hết món · khách không trả được tiền · doanh thu tính ngày nào · đổi giá tức thì · lưu lịch sử thao tác | **còn mở**, gắn vào task sẽ trả lời |

- **Mỗi task phải revert được độc lập** (luật của BA-00): BA-03 → `docs/product.md` §3.1,
  BA-04 → §3.2, BA-05 → §3.3, BA-06 → §4, BA-07 → §5, BA-08 → §6, BA-09 → §7, BA-11 → §8.
  BA-10 → `docs/decisions.md`. Hai task chạm cùng một mục là dấu hiệu chia việc sai.

## Acceptance

- `work/backlog.md` có đúng 11 ID BA-01–BA-11, không thiếu, không thừa, không trùng.
- BA-01, BA-02 ở **Done**; BA-03–BA-11 ở **Ready**, xếp theo thứ tự phụ thuộc cột "Cần xong trước"
  của §11 kế hoạch gốc.
- Mỗi task Ready có dòng `Prompt:` trỏ tới một file **tồn tại** trong `prompt/BA/`.
- Mỗi task có Acceptance viết dạng điều kiện đúng/sai kiểm được; không dòng nào kiểu "đầy đủ",
  "rõ ràng", "hoạt động tốt".
- 10 câu hỏi §10 đều xuất hiện; bốn câu đã chốt ghi kèm **nguồn `shop-facts.md` §-số**, không bị
  mở lại thành unknown.
- Không dòng nào trong backlog ghi S-1–S-3 là giả định chưa xác nhận.
- Không dòng nào trong backlog nói quán có **bốn** kênh.
- `git diff docs/product.md` **không** chạm §1, §2 hay mục Unknowns.
- Không tạo file mới nào ngoài hai file trong Scope.
- Không có chuỗi `endpoint`, `schema`, `API`, `component`, `Docker` trong nội dung mới thêm.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -c 'BA-0\|BA-1' work/backlog.md                   # ≥ 11 dòng có ID task
grep -n '^- \[' work/backlog.md                        # BA-03..BA-11 ở Ready, BA-01/02 ở Done
grep -nEi 'bốn kênh|4 kênh' work/backlog.md            # rỗng
grep -nEi 'endpoint|schema|component|docker' work/backlog.md   # rỗng
git diff docs/product.md | head -40                    # không có §1/§2/Unknowns
./scripts/brief.sh | sed -n '/NEXT READY/,+3p'         # trỏ vào một task BA thật
git status --porcelain
```
Gate 2: đọc lại từng dòng Acceptance và chỉ ra chỗ trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ mới. Prompt này chia việc; câu hỏi nghiệp vụ thuộc task con.
- Câu duy nhất có thể phải quyết trong lúc làm: **BA-10 (`docs/decisions.md`) nay còn gì để làm**,
  khi S-1–S-3 đã chốt và không còn giả định nào? Không tự thu nhỏ nó — vẫn còn sáu câu §10 đang mở
  và mọi ADR chưa được viết. Nếu bạn kết luận BA-10 rỗng thật thì **ghi rõ lý do trong entry**,
  đừng lặng lẽ bỏ task.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
