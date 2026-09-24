# Prompt DB — pha 2 · Lược đồ dữ liệu · Bánh cuốn Bà Thanh Cao Bằng

Bộ prompt để chạy **pha 2** mô tả ở `master_plan/DB_master_plan_banh_cuon_ba_thanh.md`.
Một file một bước, mã bước là **`P2-XX`** — không phải `DB-XX` (`docs/decisions.md` **ADR-049**
điểm 2: một tiền tố mang hai nghĩa là cái bẫy `work/findings.md` **F-015** · **F-021** · **F-022**
ghi lại).

Viết theo `docs/prompt-guideline.md`. Kiểm kết quả theo `quality/review-gate.md`.

Lane này dựng **2026-09-22** ở bước `P2-01`, và `prompt/DB/*` được thêm vào danh sách Gate 1b chấm
(`scripts/check-links.sh`) **trong cùng thay đổi** — đúng việc `P1-01` đã làm cho `prompt/SD/` và
`T-058` cho `prompt/AD/`. Một lane prompt không nằm trong danh sách ấy là lane pointer **không cổng
nào đọc** (**F-007**).

## Bốn lane prompt, đừng lẫn

| Lane | Pha | Nội dung |
|---|---|---|
| `prompt/BA/` | pha 0 · BA | hành vi nghiệp vụ — *quán làm gì, ai thao tác, tiền đi đường nào* |
| `prompt/SD/` | pha 1 · System design | *cái gì bảo vệ cái gì* |
| **`prompt/DB/`** | **pha 2 · DB** | **dữ liệu sống ở đâu** |
| `prompt/AD/` | mảng admin | nguyên liệu · con người · tài chính (**ADR-036**) |
| `prompt/maintenance/` | — | sửa chính cái repo này, không thuộc pha nào |

⚠️ **Hệ quả khi viết prompt trong thư mục này:** Gate 1b chấm mọi đường dẫn viết ở đây, nên đường
dẫn của một file **đầu ra chưa tồn tại** không được viết đủ cả thư mục lẫn tên file trong một dấu
nháy ngược — gate sẽ đỏ ngay khi file prompt được `git add`. Viết **tên file trần** cạnh thư mục
chứa nó, thành hai mẩu. Pha 2 gặp chuyện này nhiều hơn pha 1, vì **cả mười một file đầu ra của nó
đều chưa tồn tại** cho tới đúng bước sinh ra chúng.

## Ba nguồn input, không phải một

| Nguồn | Cho cái gì | Ai là nhà thật |
|---|---|---|
| `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` | **thứ tự · mức · đầu ra kiểm chứng được** của mười bốn bước, cổng sang pha 3 (§9) | kế hoạch — **không sở hữu sự thật nào**; §7 của nó **trỏ** sang **ADR-050** cho từ vựng năm tầng |
| `work/backlog_DB.md` | **mô tả dài** của từng bước: vì sao có nó, hỏng thì mất gì, mười bước chạy | sổ task pha 2 — không giữ trạng thái |
| `work/backlog.md` | **trạng thái** *Ready* / *In Progress* / *Done* của mọi bước | owner của Tasks (**ADR-002** · **ADR-036**) |

Dữ kiện quán thì **không** nằm ở ba chỗ trên: `master_plan/shop-facts.md` là nhà duy nhất
(**ADR-001**). Mệnh đề bất biến ở `quality/invariants.md`; **tầng** giữ từng mệnh đề và **phép đối
chiếu** của nó ở `docs/product/1-system-design/03-bao-ve-invariant.md` (**ADR-035**).

## Luật riêng của lane này

1. **Prompt của một bước chỉ viết được khi mọi bước ở cột *Cần xong trước* của nó đã `Done`**
   (**ADR-008**, T-051). Sớm hơn thì *Constraints* và *Verify* là những câu đoán — đúng loại lỗi
   **F-013** · **F-017** ghi.
2. **Không prompt nào ở đây được viết một endpoint, một route hay một tên component.** Đó là đầu ra
   của pha 3 và pha 4 (**ADR-035**); ranh giới đầy đủ ở **ADR-050**.
3. **Không prompt nào được tự hạ tầng của một mệnh đề.** Dựng không nổi ràng buộc cho một hàng
   *tầng 1* là một `F-XXX` gửi ngược pha 1, không phải lý do để hàng ấy tụt tầng (**ADR-050**).
4. **Chỗ đang chặn thì để TRỐNG CÓ TÊN.** Mã của chỗ chặn viết thẳng vào đầu ra, không lấp bằng
   một mặc định (`CLAUDE.md` §3.5 — luật này **không có mức L0**).
