# BE-STACK-02 — Công cụ và gate (L2)

Bước **02/09** (dãy bắt đầu ở 00). **Cần xong trước bước này:** 01 Done.
**Chặn:** 03. **Người làm:** Codex làm, Claude duyệt.
Kế hoạch: [be-stack-migration-steps.md](../be-stack-migration-steps.md), Bước 02.

## Context

Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Đọc header scripts/check-write-paths.sh, scripts/check-api-contract.sh, scripts/be-check.sh, scripts/verify.sh; toàn bộ db/migrations/*.up.sql và SQL của miền mẫu menu; ADR và QC sau bước 01.

## Goal

Chứng minh công cụ sinh và các gate bảo vệ cấu trúc kết hợp trước khi chuyển miền.

## Scope

be/go.mod, be/go.sum, be/sqlc.yaml, compose.yaml; scripts/check-write-paths.sh và .test.sh, scripts/check-api-contract.sh và .test.sh, scripts/verify.sh và test liên quan; phép kiểm import Gin cùng test và điểm gọi trong scripts/gate.sh. Claude chốt tên file mới vào scope trước khi giao. Chưa chuyển cửa; thử query/config trong thư mục tạm.

Claude giữ riêng `work/backlog.md`, entry chi tiết đang có và `work/scope/<MÃ>.txt`.
Ngoài phạm vi: thay luật nghiệp vụ, sửa migration, hợp đồng API, shop facts hoặc invariants;
không sửa task khác hay phần chưa commit của người khác. Scope Code và scope owner do Claude
khai riêng; Codex không được sửa owner chỉ vì Claude có quyền sửa.

## Constraints

Giữ bảo vệ ADR-082 cho mọi I-0xx liên quan; I-012 người thao tác và I-018 vết sửa không được suy yếu. Không đổi migration/hợp đồng cho vừa parser.

Giữ năm điểm §1 kế hoạch: PostgreSQL 17 + golang-migrate ở db/migrations/; mỗi câu ghi một file
trong cửa; một hàm mở giao dịch và quyền cùng giao dịch; lỗi {code, field?}; test PostgreSQL thật,
thiếu DB đỏ, tên mang mã mệnh đề. Không dùng mock để chứng minh cửa.

## Acceptance

- Việc đầu tiên: dùng bản ghim chạy go tool sqlc generate với toàn bộ ../db/migrations/*.up.sql; chứng minh đọc được PL/pgSQL, trigger, schema shop và tên bảng trần qua search_path. Exit 0, có code sinh cho query đọc và UPDATE của menu trong cây tạm. Không được ⇒ DỪNG báo Claude, không sửa migration, không chép schema tay.
- go.mod có go 1.27.2, gin v1.12.0, pgx/v5 v5.11.0, dòng tool ghim sqlc v1.31.1; go tool sqlc version đúng v1.31.1; compose dùng migrate v4.20.1, db-check PASS.
- Gate 1f giữ internal/<miền>/sql/<cửa>/: mỗi file sql/<cửa>/*.sql đúng một -- name: và một câu, tên query duy nhất trong miền. Fixture 0/2 annotation, 2 câu, trùng tên trong miền đỏ; trùng tên khác miền hợp lệ. Dấu chấm phẩy trong chuỗi/comment không đếm thành câu.
- Code dưới internal/<miền>/internal/sqlcgen/ chỉ miễn SQL trong chuỗi Go khi khớp nguồn; giả generated, sửa hằng SQL, thiếu nguồn đều đỏ. Mọi Go khác vẫn quét Begin; generated có Begin cũng đỏ. Không thêm luật phân tích lời gọi query ghi từ repository; Go internal chặn liên miền.
- Phép kiểm import Gin cho handler.go, cmd/server/, middleware/, test xanh; service.go, repository.go và file khác import Gin đỏ, kể cả alias và import nhiều dòng.
- Gate 1g nhận HandleFunc("POST /…") và r.POST("/…/:id"), đổi :id thành {id}; Group, Any, Handle của Gin, nối chuỗi và wildcard đỏ. Test method/param sai, route trùng, comment giả, multiline có kết quả đúng; giữ mọi phép so lỗi, quyền và hợp đồng.
- verify.sh sinh lại trong thư mục tạm, so cả tập file và nội dung với internal/*/internal/sqlcgen/: sửa, thiếu hoặc dư file ⇒ đỏ; nguồn/output khớp ⇒ xanh. Gate 1f vẫn chỉ đọc file.
- Gate xanh với miền chưa chuyển; **Đã chốt (Claude, 2026-10-10):** luật annotation (đúng một `-- name:`, một câu, tên duy nhất trong miền) chỉ áp cho miền **có mục trong be/sqlc.yaml**; miền chưa có mục giữ luật cũ của Gate 1f. Danh sách miền đọc từ chính sqlc.yaml, không khai ở chỗ thứ hai. Fixture phải có ca: miền đã chuyển thiếu annotation ⇒ đỏ; miền chưa chuyển không annotation ⇒ xanh. Tới bước 08 mọi file cửa phải đạt luật đích. Danh sách ô/cửa --list trước/sau không đổi.
- `./scripts/gate.sh` không có FAIL; SKIP được ghi là chưa chạy, không tính PASS.

## Verify

Chạy từ gốc repo (ngoại trừ lệnh có `cd be`). Thay `<MIEN>` khi có bằng miền đang làm.
Claude lưu output trước/sau vào scratchpad và liên kết trong entry task; không ghi log riêng theo công cụ.

```bash
(cd be && go tool sqlc version)
bash scripts/check-write-paths.test.sh
bash scripts/check-api-contract.test.sh
./scripts/check-write-paths.sh --list
./scripts/check-api-contract.sh --list
./scripts/verify.sh
./scripts/db-check.sh
./scripts/gate.sh
```

Exit 0 là mong đợi cho các lệnh kiểm, ngoại trừ ca lỗi cài cố ý và `rg` tìm thứ phải vắng mặt.
Claude chạy `./scripts/be-check.sh` bằng Docker/PostgreSQL thật; Codex không có Docker phải báo
chưa chạy, không sửa skip, không khai gate xanh nếu gate bị chặn bởi môi trường.

## Unknowns

Khả năng sqlc đọc schema thật chưa được chứng minh. Nếu cấu hình từng miền chưa chuyển không sinh được, Claude chốt phạm vi thử tạm trước; Codex không tự chuyển SQL hoặc nới gate.

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
   quality/invariants.md ở các mã nêu dưới; Đọc header scripts/check-write-paths.sh, scripts/check-api-contract.sh, scripts/be-check.sh, scripts/verify.sh; toàn bộ db/migrations/*.up.sql và SQL của miền mẫu menu; ADR và QC sau bước 01.
   Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Giữ bảo vệ ADR-082 cho mọi I-0xx liên quan; I-012 người thao tác và I-018 vết sửa không được suy yếu. Không đổi migration/hợp đồng cho vừa parser.
Khả năng sqlc đọc schema thật chưa được chứng minh. Nếu cấu hình từng miền chưa chuyển không sinh được, Claude chốt phạm vi thử tạm trước; Codex không tự chuyển SQL hoặc nới gate.

## Việc cần làm
Chứng minh công cụ sinh và các gate bảo vệ cấu trúc kết hợp trước khi chuyển miền.
be/go.mod, be/go.sum, be/sqlc.yaml, compose.yaml; scripts/check-write-paths.sh và .test.sh, scripts/check-api-contract.sh và .test.sh, scripts/verify.sh và test liên quan; phép kiểm import Gin cùng test và điểm gọi trong scripts/gate.sh. Claude chốt tên file mới vào scope trước khi giao. Chưa chuyển cửa; thử query/config trong thư mục tạm.
Giữ bảo vệ ADR-082 cho mọi I-0xx liên quan; I-012 người thao tác và I-018 vết sửa không được suy yếu. Không đổi migration/hợp đồng cho vừa parser.

## Acceptance (mỗi dòng phải có bằng chứng trong báo cáo)
- [ ] Việc đầu tiên: dùng bản ghim chạy go tool sqlc generate với toàn bộ ../db/migrations/*.up.sql; chứng minh đọc được PL/pgSQL, trigger, schema shop và tên bảng trần qua search_path. Exit 0, có code sinh cho query đọc và UPDATE của menu trong cây tạm. Không được ⇒ DỪNG báo Claude, không sửa migration, không chép schema tay.
- [ ] go.mod có go 1.27.2, gin v1.12.0, pgx/v5 v5.11.0, dòng tool ghim sqlc v1.31.1; go tool sqlc version đúng v1.31.1; compose dùng migrate v4.20.1, db-check PASS.
- [ ] Gate 1f giữ internal/<miền>/sql/<cửa>/: mỗi file sql/<cửa>/*.sql đúng một -- name: và một câu, tên query duy nhất trong miền. Fixture 0/2 annotation, 2 câu, trùng tên trong miền đỏ; trùng tên khác miền hợp lệ. Dấu chấm phẩy trong chuỗi/comment không đếm thành câu.
- [ ] Code dưới internal/<miền>/internal/sqlcgen/ chỉ miễn SQL trong chuỗi Go khi khớp nguồn; giả generated, sửa hằng SQL, thiếu nguồn đều đỏ. Mọi Go khác vẫn quét Begin; generated có Begin cũng đỏ. Không thêm luật phân tích lời gọi query ghi từ repository; Go internal chặn liên miền.
- [ ] Phép kiểm import Gin cho handler.go, cmd/server/, middleware/, test xanh; service.go, repository.go và file khác import Gin đỏ, kể cả alias và import nhiều dòng.
- [ ] Gate 1g nhận HandleFunc("POST /…") và r.POST("/…/:id"), đổi :id thành {id}; Group, Any, Handle của Gin, nối chuỗi và wildcard đỏ. Test method/param sai, route trùng, comment giả, multiline có kết quả đúng; giữ mọi phép so lỗi, quyền và hợp đồng.
- [ ] verify.sh sinh lại trong thư mục tạm, so cả tập file và nội dung với internal/*/internal/sqlcgen/: sửa, thiếu hoặc dư file ⇒ đỏ; nguồn/output khớp ⇒ xanh. Gate 1f vẫn chỉ đọc file.
- [ ] Gate xanh với miền chưa chuyển; **Đã chốt (Claude, 2026-10-10):** luật annotation (đúng một `-- name:`, một câu, tên duy nhất trong miền) chỉ áp cho miền **có mục trong be/sqlc.yaml**; miền chưa có mục giữ luật cũ của Gate 1f. Danh sách miền đọc từ chính sqlc.yaml, không khai ở chỗ thứ hai. Fixture phải có ca: miền đã chuyển thiếu annotation ⇒ đỏ; miền chưa chuyển không annotation ⇒ xanh. Tới bước 08 mọi file cửa phải đạt luật đích. Danh sách ô/cửa --list trước/sau không đổi.
- [ ] ./scripts/gate.sh xanh; nếu thiếu Docker thì dán FAIL và nêu chưa hoàn tất, Claude chạy bù.
Lệnh kiểm (Claude chạy phần DB/cài lỗi; Codex chạy phần có môi trường):
```bash
(cd be && go tool sqlc version)
bash scripts/check-write-paths.test.sh
bash scripts/check-api-contract.test.sh
./scripts/check-write-paths.sh --list
./scripts/check-api-contract.sh --list
./scripts/verify.sh
./scripts/db-check.sh
./scripts/gate.sh
```
Các lệnh kiểm mong đợi exit 0; ca lỗi cài mong đợi đỏ. Thiếu Docker thì báo chưa chạy.


## Phạm vi
Đã khai trong work/scope/<MÃ>.txt. Chỉ sửa file khớp scope: be/go.mod, be/go.sum, be/sqlc.yaml, compose.yaml; scripts/check-write-paths.sh và .test.sh, scripts/check-api-contract.sh và .test.sh, scripts/verify.sh và test liên quan; phép kiểm import Gin cùng test và điểm gọi trong scripts/gate.sh. Claude chốt tên file mới vào scope trước khi giao. Chưa chuyển cửa; thử query/config trong thư mục tạm. Claude đã thu hẹp thành từng file trong scope worktree; phần owner chỉ Claude làm.
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
