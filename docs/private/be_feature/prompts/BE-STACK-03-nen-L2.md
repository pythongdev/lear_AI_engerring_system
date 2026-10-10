# BE-STACK-03 — Nền (L2)

Bước **03/09** (dãy bắt đầu ở 00). **Cần xong trước bước này:** 02 Done.
**Chặn:** 04. **Người làm:** Codex làm, Claude duyệt.
Kế hoạch: [be-stack-migration-steps.md](../be-stack-migration-steps.md), Bước 03.

## Context

Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Đọc be/internal/db/, dbtest/, apierr/, authz/ và test; QC-03, QC-15, ADR-084/085; code dựng router hiện tại.

## Goal

Cung cấp nền dùng chung để router Gin phục vụ cả miền cũ và miền đã chuyển.

## Scope

be/internal/db/ → be/internal/platform/postgres/, be/internal/dbtest/ → be/internal/testhelper/, be/internal/apierr/, be/internal/authz/, be/internal/middleware/, be/cmd/server/; các file Go gọi nền chỉ đổi import/tên nền và dựng router; scripts/check-write-paths.sh cùng test chỉ đổi vị trí hàm InTx hợp lệ. Claude liệt kê chính xác file gọi nền trước giao.

Claude giữ riêng `work/backlog.md`, entry chi tiết đang có và `work/scope/<MÃ>.txt`.
Ngoài phạm vi: thay luật nghiệp vụ, sửa migration, hợp đồng API, shop facts hoặc invariants;
không sửa task khác hay phần chưa commit của người khác. Scope Code và scope owner do Claude
khai riêng; Codex không được sửa owner chỉ vì Claude có quyền sửa.

## Constraints

Giữ I-012: thao tác có người; giao dịch rollback toàn bộ. Test nền chỉ đổi import khi đổi tên package, không đổi điều kiện kiểm.

Giữ năm điểm §1 kế hoạch: PostgreSQL 17 + golang-migrate ở db/migrations/; mỗi câu ghi một file
trong cửa; một hàm mở giao dịch và quyền cùng giao dịch; lỗi {code, field?}; test PostgreSQL thật,
thiếu DB đỏ, tên mang mã mệnh đề. Không dùng mock để chứng minh cửa.

## Acceptance

- Open từ chối sai vai, superuser hoặc thiếu múi giờ; TestQC15_KetNoiBackend và TestQC03_ShopAppKhongXoaDuoc xanh trên PostgreSQL thật.
- InTx ở platform/postgres là hàm duy nhất mở giao dịch; authz.Run/RunAs giữ quyền và người trong cùng giao dịch; TestI012_LoiCuaThanCuaLuiCaGiaoDich xanh.
- Middleware gắn người vào gin.Context, không thay authz.Run; apierr giữ status, FromDB, JSON {code, field?}. Các test apierr/authz hiện có xanh.
- cmd/server/main.go nối router và Routes từng miền; gin.WrapH nối miền chưa chuyển, không đăng ký trùng. Gate 1g --list khớp tập hợp đồng trước/sau.
- Test HTTP qua đúng hàm dựng router kiểm path param, dấu / cuối, 404/405, HEAD, body lỗi và thứ tự từ chối theo hợp đồng hiện có. Claude đặt tên TestQC12_* cho ca nền mới; lỗi cài làm ca tương ứng đỏ.
- `./scripts/gate.sh` không có FAIL; SKIP được ghi là chưa chạy, không tính PASS.

## Verify

Chạy từ gốc repo (ngoại trừ lệnh có `cd be`). Thay `<MIEN>` khi có bằng miền đang làm.
Claude lưu output trước/sau vào scratchpad và liên kết trong entry task; không ghi log riêng theo công cụ.

```bash
./scripts/check-write-paths.sh --list
./scripts/check-api-contract.sh --list
./scripts/be-check.sh
./scripts/gate.sh
```

Exit 0 là mong đợi cho các lệnh kiểm, ngoại trừ ca lỗi cài cố ý và `rg` tìm thứ phải vắng mặt.
Claude chạy `./scripts/be-check.sh` bằng Docker/PostgreSQL thật; Codex không có Docker phải báo
chưa chạy, không sửa skip, không khai gate xanh nếu gate bị chặn bởi môi trường.

## Unknowns

**Đã chốt (Claude, 2026-10-10):** apierr **không** import Gin và không nhận *gin.Context; API ghi lỗi giữ kiểu http.ResponseWriter, handler gọi `apierr.Write(c.Writer, …)`. Luật import Gin không có ngoại lệ. Adapter phải bảo toàn path param; không giả định gin.WrapH tự điền Request.PathValue.

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
4. Ghi scope trong worktree, thêm dòng cấm riêng cho work/backlog.md, docs/decisions.md,
   docs/product/99-unknowns.md, master_plan/, quality/invariants.md, CLAUDE.md. Điền phiếu dưới vào
   scratchpad; thay mọi placeholder và rà Acceptance/Verify với base thực tế.
   Kiểm `codex exec --help`, `codex login status`, rồi gọi nền bằng lệnh bên dưới. Model
   gpt-6.1-sol trong ~/.codex/config.toml không chạy với tài khoản hiện tại, nên chỉ định gpt-6-astra.
5. Đọc báo cáo, diff thật và file mới bằng git diff/status trong worktree; duyệt theo
   quality/review-gate.md. Claude tự chạy gate, ./scripts/be-check.sh và lỗi cài theo Acceptance;
   lỗi cài phải đỏ đúng chỗ, gỡ hết lỗi rồi xanh. Tối đa hai vòng trả Codex; vòng ba viết lại phiếu
   hoặc Claude sửa. L1 bước dọn vẫn kiểm fixture route cũ bị từ chối.
6. Claude tích hợp đúng diff đã duyệt, gồm file mới, theo docs/prompt-guideline.md §6.1; kiểm không
   đè phần người khác. Chạy gate và be-check tại cây tích hợp, ghi người thực hiện/duyệt, base/nhánh,
   file và bằng chứng trong entry rồi mới Done. Codex không tích hợp hay commit.

Bàn giao khối commit theo `CLAUDE.md` §6.1: lấy danh sách từ `git diff --name-only HEAD` và
`git ls-files --others --exclude-standard`, kiểm `git diff --cached --name-only`; nếu có staged của
người khác thì báo và không đưa khối sẽ gom chúng. Liệt kê từng file đúng scope, không thêm scope
file, không `git add -A` hay `git add .`. Claude viết khối `git add <từng-file>` và
`git commit -m "<MÃ>: <nội dung>" -m "<lý do và kiểm thực chạy>"` để chủ repo dùng, không tự commit.
Giữ scope đến khi commit xong. Gate trực tiếp không chạy Gate 7/7b, phải tự đối chiếu khối này.

## Report

Báo bằng tiếng Việt: đã đổi gì; lệnh thực chạy, output và bảng Acceptance → bằng chứng; vấn đề chưa
xử lý và việc tiếp theo. Phân biệt PASS/SKIP/chưa chạy. Claude thêm khối commit §6.1 sau khi kiểm index.

## Phiếu Codex

Claude thay `<MÃ>`, `<MỨC>`, `<MIEN>` (nếu có), đường dẫn scratchpad; chốt danh sách file cụ thể trước gửi.
Bảy mục dưới giữ đúng mẫu `docs/prompt-guideline.md` §6.1. Không gửi phiếu còn placeholder.

````markdown
# Phiếu giao việc — <MÃ> (mức L<MỨC>)

Bạn là người thi công. Người quyết định là Claude; bạn không quyết thay.

## Bắt đầu
1. Đọc AGENTS.md rồi CLAUDE.md. Chạy ./scripts/brief.sh.
2. Chỉ đọc thêm: docs/product/2-db/10-quy-uoc-code.md §8; docs/decisions.md ADR-082/083/084/085
   và ADR mới ghi ở bước 01; docs/product/3-be/openapi.yaml, docs/product/3-be/02-vai-va-quyen.md;
   quality/invariants.md ở các mã nêu dưới; Đọc be/internal/db/, dbtest/, apierr/, authz/ và test; QC-03, QC-15, ADR-084/085; code dựng router hiện tại.
   Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Giữ I-012: thao tác có người; giao dịch rollback toàn bộ. Test nền chỉ đổi import khi đổi tên package, không đổi điều kiện kiểm.
**Đã chốt (Claude, 2026-10-10):** apierr **không** import Gin và không nhận *gin.Context; API ghi lỗi giữ kiểu http.ResponseWriter, handler gọi `apierr.Write(c.Writer, …)`. Luật import Gin không có ngoại lệ. Adapter phải bảo toàn path param; không giả định gin.WrapH tự điền Request.PathValue.

## Việc cần làm
Cung cấp nền dùng chung để router Gin phục vụ cả miền cũ và miền đã chuyển.
be/internal/db/ → be/internal/platform/postgres/, be/internal/dbtest/ → be/internal/testhelper/, be/internal/apierr/, be/internal/authz/, be/internal/middleware/, be/cmd/server/; các file Go gọi nền chỉ đổi import/tên nền và dựng router; scripts/check-write-paths.sh cùng test chỉ đổi vị trí hàm InTx hợp lệ. Claude liệt kê chính xác file gọi nền trước giao.
Giữ I-012: thao tác có người; giao dịch rollback toàn bộ. Test nền chỉ đổi import khi đổi tên package, không đổi điều kiện kiểm.

## Acceptance (mỗi dòng phải có bằng chứng trong báo cáo)
- [ ] Open từ chối sai vai, superuser hoặc thiếu múi giờ; TestQC15_KetNoiBackend và TestQC03_ShopAppKhongXoaDuoc xanh trên PostgreSQL thật.
- [ ] InTx ở platform/postgres là hàm duy nhất mở giao dịch; authz.Run/RunAs giữ quyền và người trong cùng giao dịch; TestI012_LoiCuaThanCuaLuiCaGiaoDich xanh.
- [ ] Middleware gắn người vào gin.Context, không thay authz.Run; apierr giữ status, FromDB, JSON {code, field?}. Các test apierr/authz hiện có xanh.
- [ ] cmd/server/main.go nối router và Routes từng miền; gin.WrapH nối miền chưa chuyển, không đăng ký trùng. Gate 1g --list khớp tập hợp đồng trước/sau.
- [ ] Test HTTP qua đúng hàm dựng router kiểm path param, dấu / cuối, 404/405, HEAD, body lỗi và thứ tự từ chối theo hợp đồng hiện có. Claude đặt tên TestQC12_* cho ca nền mới; lỗi cài làm ca tương ứng đỏ.
- [ ] ./scripts/gate.sh xanh; nếu thiếu Docker thì dán FAIL và nêu chưa hoàn tất, Claude chạy bù.
Lệnh kiểm (Claude chạy phần DB/cài lỗi; Codex chạy phần có môi trường):
```bash
./scripts/check-write-paths.sh --list
./scripts/check-api-contract.sh --list
./scripts/be-check.sh
./scripts/gate.sh
```
Các lệnh kiểm mong đợi exit 0; ca lỗi cài mong đợi đỏ. Thiếu Docker thì báo chưa chạy.


## Phạm vi
Đã khai trong work/scope/<MÃ>.txt. Chỉ sửa file khớp scope: be/internal/db/ → be/internal/platform/postgres/, be/internal/dbtest/ → be/internal/testhelper/, be/internal/apierr/, be/internal/authz/, be/internal/middleware/, be/cmd/server/; các file Go gọi nền chỉ đổi import/tên nền và dựng router; scripts/check-write-paths.sh cùng test chỉ đổi vị trí hàm InTx hợp lệ. Claude liệt kê chính xác file gọi nền trước giao. Claude đã thu hẹp thành từng file trong scope worktree; phần owner chỉ Claude làm.
Cần thêm file thì DỪNG và ghi vào báo cáo, không tự mở rộng scope.

## Cấm
- Không commit, không sửa work/backlog.md, docs/decisions.md, docs/product/99-unknowns.md,
  master_plan/, quality/invariants.md, CLAUDE.md. Không sửa owner quy ước thay Claude.
- Không bịa luật nghiệp vụ. Chỗ nào chưa rõ: để nguyên hành vi, ghi câu hỏi.
- Không git add -A, không xoá file ngoài scope, không sửa migration hay hợp đồng.
- Không đổi điều kiện kiểm test để xanh, không Skip khi thiếu database. Không mở lại stack đã chốt.

## Báo cáo (tin nhắn cuối cùng, đúng khuôn này)
1. File đã đổi / tạo (lấy từ git status --short, không nhớ lại).
2. Output cuối của ./scripts/gate.sh, dán nguyên.
3. Bảng Acceptance → bằng chứng (tên test hoặc lệnh + output).
4. Câu hỏi còn mở / điều đã phải giả định.
5. Việc chưa xong.
````

```bash
codex exec -m gpt-6-astra -C ../lean_wt/<MÃ> -s workspace-write -o <scratchpad>/<MÃ>-bao-cao.md - < <phiếu>
```
