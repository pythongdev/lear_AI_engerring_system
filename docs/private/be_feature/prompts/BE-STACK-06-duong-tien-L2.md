# BE-STACK-06 — Đường tiền (L2)

Bước **06/09** (dãy bắt đầu ở 00). **Cần xong trước bước này:** 05 đủ bảy miền Done (T-153…T-159); miền liền trước trong nhóm Done.
**Chặn:** 07 sau khi đủ ba miền. **Người làm:** Codex làm, Claude duyệt.
Kế hoạch: [be-stack-migration-steps.md](../be-stack-migration-steps.md), Bước 06.

## Context

Đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc trạng thái thật trong
`work/backlog.md`, entry bàn giao, nhánh, `git status --short` và diff. Kiểm bước trước đã Done;
nhóm nhiều miền phải đủ mọi task tiền nhiệm. Kế hoạch là con trỏ, owner ở `CLAUDE.md` §2 thắng.
Stack đã được chủ repo duyệt 2026-10-10: Go 1.27.2, gin v1.12.0, sqlc v1.31.1 (dòng tool,
chạy go tool sqlc), pgx/v5 v5.11.0, migrate v4.20.1; không mở lại lựa chọn.

Đọc `be/internal/<MIEN>/`; test của đường tiền nằm hết ở `be/internal/don/` (`duong_tien_test.go`, `duong_tien_hinh_test.go`,
phần dựng router của `don_test.go`) — ba thư mục miền không có test riêng. Đọc `quality/invariants.md` I-005, I-012, I-014,
I-015, I-021; `docs/product/3-be/06-duong-tien.md`, hợp đồng và ma trận quyền.

## Goal

Chuyển đúng một miền đường tiền mỗi lượt mà không đổi kết quả thu, trả và đối soát.

## Scope

`be/internal/<MIEN>/`, `be/sqlc.yaml`, `be/cmd/server/router.go`, và phần dựng router của hai file test bên gọi:
`be/internal/don/don_test.go` (hàm `dung`) · `be/internal/don/duong_tien_hinh_test.go` (đầu `TestQC14_HinhDuongTienTruocQuyen`).
Thay `<MIEN>` theo `tratruoc` → `hoadon` → `ket`; mỗi miền một task.

Bên gọi giữa các miền: `hoadon` gọi `tratruoc.KiemSoDu` · `tratruoc.Dung` · kiểu `tratruoc.PhanTien`; `hoadon` · `ket` ·
`tratruoc` gọi `ngayban` (đã chuyển, T-155). Task của một miền **giữ nguyên tên và chữ ký** mọi thứ exported mà miền khác
dùng, để bên gọi không phải sửa. Không giữ được thì DỪNG và báo Claude — Claude thêm file bên gọi vào scope, không tự mở.

Claude giữ riêng `work/backlog.md`, entry chi tiết đang có và `work/scope/<MÃ>.txt`.
Ngoài phạm vi: thay luật nghiệp vụ, sửa migration, hợp đồng API, shop facts hoặc invariants;
không sửa task khác hay phần chưa commit của người khác. Scope Code và scope owner do Claude
khai riêng; Codex không được sửa owner chỉ vì Claude có quyền sửa.

## Constraints

Giữ I-005 (đóng phiên còn nợ phải ghi ai nợ, bao nhiêu), I-012 (mọi thao tác chạm tiền có người và mốc), I-014 (trả trước chưa là
doanh thu của ngày nào), I-015 (một lần thu chia nhiều phương thức, tổng khớp), I-021 (két cuối ngày khớp doanh thu tiền mặt sau
bù trả trước, hoàn chéo, nợ cũ, chi); đọc nguyên văn các vế hiện hành ở `quality/invariants.md` trước viết Acceptance chi tiết.
Không sửa phép tính để hợp kiểu sinh.

Giữ năm điểm §1 kế hoạch: PostgreSQL 17 + golang-migrate ở db/migrations/; mỗi câu ghi một file
trong cửa; một hàm mở giao dịch và quyền cùng giao dịch; lỗi {code, field?}; test PostgreSQL thật,
thiếu DB đỏ, tên mang mã mệnh đề. Không dùng mock để chứng minh cửa.

- Mọi test hiện có giữ nguyên điều kiện kiểm; chỉ phần dựng router trong test được đổi.
- `check-write-paths.sh --list` trước/sau chỉ khác dòng đếm file đã soát; không đổi mã cửa hay ô ghi.
- Dùng `internal/<MIEN>/handler.go`, `service.go`, `repository.go`, `sql/<cửa>/<câu>.sql`,
  `sql/*.sql`, `internal/sqlcgen/`. Handler không gọi DB; service/repository không import Gin, repository
  nhận `pgx.Tx`, không Begin/Commit. Service khai `authz.Door`, gọi `authz.Run`; API `theo_cua_goi` nhận `pgx.Tx`.
- Câu ghi giữ nguyên văn, chỉ thêm `-- name:` và `;` (Gate 1f so nguyên văn với hằng sinh); ép kiểu chỉ ở câu đọc.
- `apierr.ReadID` đọc `PathValue` của `ServeMux`; ở Gin, handler đọc `c.Param` và trả cùng lỗi (400, field là tên tham số).

**Test hình trước quyền** (Claude chốt 2026-10-12). `TestQC14_HinhDuongTienTruocQuyen` gắn cả ba miền vào một `ServeMux` với
authenticator làm test dừng ngay khi bị hỏi người, và `pool = nil`. Ở Gin, người được đọc bởi `middleware.GanNguoi` cho **mọi**
yêu cầu (T-151 — middleware không bao giờ từ chối), nên vế "không đọc người" không còn là thuộc tính của handler. Cách giữ: miền
đã chuyển gắn vào `gin.New()` **không** `GanNguoi`, với service dựng từ `pool = nil`, miền chưa chuyển vẫn gắn vào `ServeMux` cũ
sau `NoRoute`. Mọi ca hình sai vẫn phải ra 400 đúng `field` trước `authz.Run` và trước database — `pool = nil` làm mọi lần chạm
database thành panic, nên test vẫn chứng minh *hình trước quyền*. Bảng ca và điều kiện kiểm không đổi.

## Acceptance

Claude ghi Acceptance cụ thể của từng miền vào entry task trước khi giao, với tên test thật kiểm bằng `rg '^func Test'` ở nền:

- Mười test ở `duong_tien_test.go` (`TestI015_*` · `TestI005_*` · `TestYC23_*` · `TestYC10_*` · `TestYC01_*` · bốn `TestI021_*`),
  `TestQC14_HinhDuongTienTruocQuyen` và mọi test khác đi qua đường của miền (tìm theo đường dẫn trong test, không chỉ theo tiền tố)
  xanh qua be-check trên PostgreSQL thật; lưu tên cụ thể từ output.
- Ca nhận/dùng/trả trước, thu nợ/hoàn, đếm két/đối soát, từ chối và rollback liên quan miền đều giữ kết quả và người thao tác.
- Lỗi cài trong **worktree riêng** (luật T-167, `quality/review-gate.md` Gate 1), mỗi lần một lỗi, đỏ đúng test rồi hoàn nguyên:
  `tratruoc` — trừ sai số dư khi dùng; `hoadon` — ghi lệch phần tiền mặt của một lần thu; `ket` — câu đối soát cộng sai một nguồn.
  Lỗi nào không bị bắt thì ghi kết quả thật, không đoán (khuôn F-064).
- Mỗi miền có ba file tầng và một `internal/sqlcgen/`, SQL giữ nguyên thư mục cửa; build, sinh lại, Gate 1f · 1g · 1h đạt.
- `./scripts/gate.sh` không có `FAIL`; `SKIP` được ghi là chưa chạy, không tính PASS.

## Verify

Chạy từ gốc repo (ngoại trừ lệnh có `cd be`). Claude lưu output trước/sau vào scratchpad và liên kết trong entry task.

```bash
rg '^func Test' be/internal/don/duong_tien_test.go be/internal/don/duong_tien_hinh_test.go
./scripts/check-write-paths.sh --list
./scripts/check-api-contract.sh --list
./scripts/be-check.sh
./scripts/gate.sh
```

Exit 0 là mong đợi, ngoại trừ ca lỗi cài cố ý. Claude chạy `./scripts/be-check.sh` bằng Docker/PostgreSQL thật; Codex không có
Docker phải báo chưa chạy, không sửa skip, không khai gate xanh. Trước/sau sửa lưu hai `--list` và
`rg --no-filename '^func Test' be/internal be/cmd | sort`; `diff` chỉ được khác dòng đếm file.

## Unknowns

Unknown nghiệp vụ còn mở ở owner không được đóng hay quyết trong lần chuyển stack. Gặp ca không có kỳ vọng đã chốt thì để
nguyên hành vi và báo Claude. Gặp mâu thuẫn owner hoặc thiếu dữ kiện thì dừng phần phụ thuộc và báo Claude; không quyết thay.

## Claude làm

1. Chấm mức, nhận task trong backlog (T-160 · T-161 · T-162), ghi Acceptance trước thay đổi, chuyển In Progress.
2. Khai `work/scope/<MÃ>.txt`; tạo `git worktree add ../lean_wt/<MÃ> -b codex/<MÃ>` từ HEAD đã commit miền trước; ghi scope
   trong worktree kèm dòng cấm `work/`, `docs/`, `master_plan/`, `quality/`, `CLAUDE.md`. Lưu `--list` và tập tên test trước.
3. Viết phiếu vào scratchpad theo khuôn `docs/prompt-guideline.md` §6.1, không placeholder; gọi nền
   `codex exec -m gpt-6-astra -C ../lean_wt/<MÃ> -s workspace-write -o <scratchpad>/<MÃ>-bao-cao.md - < <phiếu>`.
4. Đọc báo cáo và diff thật; chạy gate trong worktree; cài lỗi trong worktree riêng; tối đa hai vòng trả Codex.
5. Tích hợp bằng patch, chạy gate ở cây chính, ghi bàn giao trong entry, chuyển Done, đưa khối commit §6.1.

## Report

Báo bằng tiếng Việt: đã đổi gì; lệnh thực chạy, output và bảng Acceptance → bằng chứng; vấn đề chưa xử lý và việc tiếp theo.
Phân biệt PASS/SKIP/chưa chạy. Claude thêm khối commit §6.1 sau khi kiểm index.
