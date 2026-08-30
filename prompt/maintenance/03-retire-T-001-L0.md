# 03 — Gỡ dòng mẫu T-001 khỏi Ready (L0) · T-009

> Chạy **sau** `prompt/maintenance/02-run-ba00-backlog-L3.md` (T-008). Trước đó thì Ready chưa có
> task BA thật để thay chỗ, gỡ T-001 sẽ để lại một mục Ready rỗng.

## Context

- `work/backlog.md` → *Ready* còn dòng `- [ ] T-001 Replace this with the first meaningful task.`
  Đó là dòng mẫu của template khởi tạo repo, **chưa bao giờ là một task thật**: không Goal, không
  Scope, không Acceptance.
- Nó không vô hại. `scripts/brief.sh` in mục **NEXT READY** bằng dòng chưa tick đầu tiên của Ready,
  và brief là `SessionStart` hook — nên **mọi phiên mới đang được chỉ vào một placeholder** trước
  cả chỉ thị đầu tiên của người dùng. Kiểm bằng:

  ```bash
  ./scripts/brief.sh | sed -n '/NEXT READY/,+2p'
  ```

- ADR-002 dựng brief để phiên mới nhận **trạng thái hôm nay**. Một brief trỏ vào dòng mẫu là brief
  đang nói sai — đúng thứ ADR-002 muốn chặn.
- ID đã dùng thì **không tái sử dụng**: sau việc này không được có task mới nào mang số T-001.

## Goal

Task đầu tiên mà `brief.sh` in ra cho phiên sau là một task thật, có prompt và acceptance.

## Scope

Được sửa:
- `work/backlog.md`

Không được sửa: mọi file khác. Không đụng `scripts/brief.sh` — brief đang chạy đúng, dữ liệu vào
mới sai.

Dòng chép vào `work/scope.txt`:
```text
work/backlog.md
work/scope.txt
```

## Constraints

- **Xoá dòng T-001, không "hoàn thành" nó.** Nó chưa bao giờ là việc thật nên không được tick `[x]`
  và không được chuyển xuống Done — Done là nơi ghi việc đã làm, đưa một dòng mẫu vào đó là làm
  hỏng lịch sử.
- **Không phát minh task mới để lấp chỗ.** Ready sau việc này chứa đúng những task BA mà T-008 đã
  dựng, không thêm gì.
- Nếu Ready **chưa** có task BA nào (T-008 chưa chạy): dừng lại, chạy T-008 trước. Nếu buộc phải
  làm ngay thì thay dòng T-001 bằng đúng một task: *"chạy `prompt/maintenance/02-run-ba00-backlog-L3.md`"*,
  cấp ID kế tiếp chưa dùng — và nói rõ trong Report là đã đi đường vòng này.
- Không đụng T-002, T-003, T-004, T-005, T-006 và entry BA-01/BA-02 ở Done.
- Giữ nguyên mục *Task Detail Template* ở cuối file — đó là template, không phải task.

## Acceptance

- `grep -n 'Replace this with the first meaningful task' work/backlog.md` **rỗng**.
- Mục *Ready* không còn dòng nào không có `Prompt:` hoặc không có Acceptance ở entry chi tiết.
- `./scripts/brief.sh` in NEXT READY là một task BA có thật, và task đó tìm được entry chi tiết
  trong `work/backlog.md`.
- Mục *Done* không có dòng nào mang ID T-001.
- Số task ở Done không đổi so với trước khi làm.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -n 'Replace this' work/backlog.md                 # rỗng
grep -n 'T-001' work/backlog.md                        # rỗng
grep -c '^- \[x\]' work/backlog.md                     # bằng số cũ
./scripts/brief.sh | sed -n '/NEXT READY/,+3p'         # một task BA thật
git status --porcelain                                 # chỉ work/backlog.md
```
Gate 2: dán nguyên output `brief.sh` trước và sau khi sửa vào Report — đó là bằng chứng duy nhất
cho thấy việc này có tác dụng thật.

## Unknowns

- Không có. Việc này không quyết định gì về nghiệp vụ.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao (kèm output `brief.sh` trước/sau)
- Còn vấn đề gì chưa giải quyết
