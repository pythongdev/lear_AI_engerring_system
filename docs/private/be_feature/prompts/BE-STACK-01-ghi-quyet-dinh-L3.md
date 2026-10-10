# BE-STACK-01 — Ghi quyết định (L3)

Bước **01/09** (dãy bắt đầu ở 00). **Cần xong trước bước này:** 00 Done.
**Chặn:** 02. **Người làm:** Claude.
Kế hoạch: [be-stack-migration-steps.md](../be-stack-migration-steps.md), Bước 01.

## Context

Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Đọc docs/decisions.md ADR-082, ADR-083, ADR-084, ADR-085; docs/product/2-db/10-quy-uoc-code.md §8 và QC-05; đọc toàn bộ kế hoạch kèm theo.

## Goal

Ghi thiết kế đã được chủ repo duyệt vào đúng owner và chia việc có thể bàn giao.

## Scope

Claude sửa docs/decisions.md, docs/product/2-db/10-quy-uoc-code.md: QC-05, QC-11…QC-14. Không sửa code, migration hay invariants.

Claude giữ riêng `work/backlog.md`, entry chi tiết đang có và `work/scope/<MÃ>.txt`.
Ngoài phạm vi: thay luật nghiệp vụ, sửa migration, hợp đồng API, shop facts hoặc invariants;
không sửa task khác hay phần chưa commit của người khác. Scope Code và scope owner do Claude
khai riêng; Codex không được sửa owner chỉ vì Claude có quyền sửa.

## Constraints

Giữ I-012 (người thao tác), I-018 (vết sửa), I-020 (sản xuất) và các bất biến đường tiền theo quality/invariants.md. Không tạo luật nghiệp vụ mới.

Giữ năm điểm §1 kế hoạch: PostgreSQL 17 + golang-migrate ở db/migrations/; mỗi câu ghi một file
trong cửa; một hàm mở giao dịch và quyền cùng giao dịch; lỗi {code, field?}; test PostgreSQL thật,
thiếu DB đỏ, tên mang mã mệnh đề. Không dùng mock để chứng minh cửa.

## Acceptance

- ADR mới ghi ngày 2026-10-10, người quyết là chủ repo, thay điểm 1 và 6 ADR-083, giữ ADR-082/084/085; có bốn lý do kết hợp và hai phương án bị loại đúng kế hoạch.
- QC-05, QC-11…QC-14 ghi đủ pin, cây, luật route/import và phép kiểm tương ứng; đối chiếu từng mục với §0–§2 kế hoạch không lệch.
- Từng bước 02…09 có task hoặc nhóm task, Acceptance và thứ tự; bước 05/06 mỗi miền một task, bước 07 hai task. Mỗi lát có mốc xanh để lùi code riêng, không đổi dữ liệu.
- Claude rà thiết kế trước code, ghi các điểm thiếu thông tin chặn bước nào; gate không FAIL.
- `./scripts/gate.sh` không có FAIL; SKIP được ghi là chưa chạy, không tính PASS.

## Verify

Chạy từ gốc repo (ngoại trừ lệnh có `cd be`). Thay `<MIEN>` khi có bằng miền đang làm.
Claude lưu output trước/sau vào scratchpad và liên kết trong entry task; không ghi log riêng theo công cụ.

```bash
grep -o 'ADR-[0-9]*' docs/decisions.md | sort -u | tail -1
./scripts/gate.sh
```

Exit 0 là mong đợi cho các lệnh kiểm, ngoại trừ ca lỗi cài cố ý và `rg` tìm thứ phải vắng mặt.
Claude chạy `./scripts/be-check.sh` bằng Docker/PostgreSQL thật; Codex không có Docker phải báo
chưa chạy, không sửa skip, không khai gate xanh nếu gate bị chặn bởi môi trường.

## Unknowns

Đường dẫn hàm mở giao dịch ở điểm 3 ADR-083 vẫn nhắc internal/db; Claude ghi rõ việc chuyển vị trí sang platform/postgres trong ADR mới mà giữ nguyên luật một hàm. Không tự tuyên bố owner đã đổi trước bước này.

Gặp mâu thuẫn owner hoặc thiếu dữ kiện thì dừng phần phụ thuộc và báo Claude; không quyết thay.
Nếu cần ADR, dùng số ADR kế tiếp (tra bằng `grep -o 'ADR-[0-9]*' docs/decisions.md | sort -u | tail -1`),
không ghim số trước. Đây không phải yêu cầu tạo thêm ADR ở mỗi miền.

## Claude làm

1. Chấm mức theo hậu quả, nhận task hiện có hoặc lấy số `T-XXX` kế tiếp bằng
   `grep -o 'T-[0-9]*' work/backlog.md | sort -Vu | tail -1`, kiểm chưa trùng rồi tăng số.
   Không đoán mã. Ghi Acceptance trước thay đổi, trạng thái ở backlog, bàn giao trong entry hiện có.
2. Khai scope từng file, kiểm thay đổi chưa commit và base. Khi giao Codex, tạo
   `git worktree add ../lean_wt/<MÃ> -b codex/<MÃ>`; worktree từ HEAD không thấy thay đổi chưa commit.
   Nếu phụ thuộc phần chưa commit thì chờ chủ repo commit hoặc chưa giao. Tài liệu private chưa track
   phải được Claude đưa nguyên nội dung cần thiết vào phiếu scratchpad, không giả định worktree thấy nó.
3. Với L2, Claude chuẩn bị test hồi quy/vế invariant và ca cài lỗi trước thi công; kiểm Acceptance có tên
   test thật bằng `rg '^func Test'` ở file liên quan. Khi tên trong mẫu không có ở base mới, ghi thiếu và
   xác định ca tương đương từ owner trước giao, không bỏ tiêu chí. L3 chỉ ghi quyết định và chia lát.
4. Bước này Claude tự làm, **không gọi Codex và không có phiếu Codex**. Dùng cây làm việc riêng
   nếu cây chính có người đang viết. Bước 00 chạy be-check lặp và cài lỗi như Acceptance; bước 01
   chỉ tài liệu nên be-check/cài lỗi không áp dụng, ghi rõ chưa chạy; bước 09 chạy be-check và kiểm
   lại bằng chứng lỗi cài ở các bước trước. Không bịa output.
5. Claude tự duyệt diff theo quality/review-gate.md, chạy gate; nếu có worktree thì tích hợp riêng phần
   task rồi chạy lại kiểm ở cây tích hợp. Chỉ Done khi từng dòng Acceptance có bằng chứng.

Bàn giao khối commit theo `CLAUDE.md` §6.1: lấy danh sách từ `git diff --name-only HEAD` và
`git ls-files --others --exclude-standard`, kiểm `git diff --cached --name-only`; nếu có staged của
người khác thì báo và không đưa khối sẽ gom chúng. Liệt kê từng file đúng scope, không thêm scope
file, không `git add -A` hay `git add .`. Claude viết khối `git add <từng-file>` và
`git commit -m "<MÃ>: <nội dung>" -m "<lý do và kiểm thực chạy>"` để chủ repo dùng, không tự commit.
Giữ scope đến khi commit xong. Gate trực tiếp không chạy Gate 7/7b, phải tự đối chiếu khối này.

## Report

Báo bằng tiếng Việt: đã đổi gì; lệnh thực chạy, output và bảng Acceptance → bằng chứng; vấn đề chưa
xử lý và việc tiếp theo. Phân biệt PASS/SKIP/chưa chạy. Claude thêm khối commit §6.1 sau khi kiểm index.
