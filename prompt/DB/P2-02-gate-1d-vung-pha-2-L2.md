# P2-02 — Gate 1d học vùng pha 2 (L2) · pha 2, bước 2/14

> Bước **2/14** của pha 2 — `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §6
> (`docs/decisions.md` **ADR-049**). Mô tả dài ở `work/backlog_DB.md` → **P2-02**; trạng thái ở
> `work/backlog.md`. **Cần xong trước:** `P2-01` — **đã xong 2026-09-22** (**ADR-050**).
>
> Bước này **không chặn** bước nào, nhưng mọi bước viết file pha 2 chạy **mù** cho tới khi nó
> xong. Nó độc lập với cả dãy lược đồ, nên nó đi trước `P2-03` — lượt sinh ra file pha 2 đầu tiên.

## Context

- **`scripts/check-phase-boundary.sh`** — Gate 1d. Header comment của nó giữ cơ chế (`CLAUDE.md`
  mở đầu: mechanism detail sống trong header của chính script). Hôm nay nó chỉ đọc **một** vùng,
  `docs/product/1-system-design/`, và bộ mẫu `PAT_DB` của nó đỏ với từ khoá SQL.
- **`scripts/check-phase-boundary.test.sh`** — mười ca, trong đó ca **9** là ca hồi quy **F-041**
  (endpoint không mở đầu bằng `/` vẫn phải bị bắt) và ca **10** là ca chống kêu oan văn xuôi.
- **`scripts/check-phase-boundary.ignore`** — hiện **không có mục nào**, và đó là trạng thái đúng
  kể từ `T-079`. Đọc phần đầu file: nó kể vì sao một dòng ignore hết khớp là một dòng phải gỡ.
- **`docs/decisions.md` ADR-050** — bảng năm tầng và **ba câu pha 2 không được viết ra**. Bộ mẫu
  của vùng pha 2 phải khớp đúng ba câu ấy, không rộng hơn.
- **`docs/decisions.md` ADR-039** — quyết định dựng Gate 1d, và câu *cố ý bảo thủ, im lặng khi
  không chắc*. Bước này **không** lật câu ấy.
- **`work/findings.md` F-041** — pha 1 đã viết hộ pha sau và cổng mù. **F-017** — một bộ lọc rỗng
  vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi.

## Goal

Gate 1d **đỏ** khi một file pha 2 mang endpoint · route · component, và **xanh** khi file ấy mang
SQL — thứ pha 2 có quyền viết. Ranh giới pha có cổng gác ở **cả hai** vùng, không chỉ ở vùng pha 1,
và điều đó đúng **trước** khi file pha 2 đầu tiên ra đời.

## Scope

Được sửa:
- `scripts/check-phase-boundary.sh` — thêm vùng `docs/product/2-db/` với bộ mẫu **riêng**
- `scripts/check-phase-boundary.test.sh` — ca hồi quy mới cho vùng pha 2
- `work/backlog.md` · `work/backlog_DB.md` — trạng thái và entry
- `prompt/DB/` — file prompt này

Không được sửa:
- **Hành vi của vùng pha 1.** Cả mười ca cũ phải còn xanh, **nguyên văn kỳ vọng**.
- `scripts/check-phase-boundary.ignore` — không thêm mục nào; ignore là cho **một chỗ trích cố ý**,
  không phải để im một lớp lỗi
- `docs/product/` — bước này không viết một dòng tài liệu pha nào

## Constraints

- **Đừng nới bộ mẫu của vùng pha 1 cho "thống nhất".** Nới nó là gỡ đúng cái cổng `T-079` vừa
  dựng (**F-040** · **F-041**).
- **Vùng pha 2 phải im lặng với SQL, kể cả SQL có chữ `DELETE`.** `ON DELETE CASCADE` và
  `DELETE FROM …` là SQL hợp lệ; mẫu endpoint của vùng pha 1 nhận `DELETE` + khoảng trắng + chữ,
  nên dùng chung mẫu ấy sẽ kêu oan ở **mọi** lát lược đồ có khoá ngoại.
- **Nhưng vẫn phải bắt endpoint không có `/` mở đầu.** Bài học **F-041**: một dấu gạch chéo thiếu
  ở đầu chuỗi là toàn bộ khoảng cách giữa *bắt được* và *không thấy gì*.
- **Gặp một hình dạng không chắc nên đỏ hay không ⇒ để IM LẶNG.** Gate 1d cố ý bảo thủ
  (`CLAUDE.md` §5.4), và một cổng đỏ sai dạy người ta gỡ cổng.
- **Invariant liên quan:** không mệnh đề `I-0xx` nào. Bất biến bước này giữ là bất biến của **repo**
  — *một pha không viết thứ pha sau sở hữu* (**ADR-035**).

## Acceptance

- Một file trong `docs/product/2-db/` mang `POST /api/orders` ⇒ Gate 1d **đỏ**, và output nêu đúng
  vùng pha 2.
- Một file trong `docs/product/2-db/` mang `POST staff/debts/:id/collect` (**không** có `/` mở đầu)
  ⇒ Gate 1d **đỏ**. Đây là ca hồi quy **F-041** cho vùng mới.
- Một file trong `docs/product/2-db/` mang `<DebtList />` ⇒ Gate 1d **đỏ**.
- Một file trong `docs/product/2-db/` mang `CREATE TABLE`, `ON DELETE CASCADE`, `DELETE FROM …`,
  `CHECK (…)` ⇒ Gate 1d **xanh**, output **rỗng**.
- Một file trong `docs/product/2-db/` mang câu ADR-050 dặn viết thay cho endpoint — *"đường ghi tới
  ô này phải là MỘT"* — ⇒ Gate 1d **xanh**.
- File **chưa track** trong vùng pha 2 cũng bị chấm, đúng như vùng pha 1.
- Hai vùng cùng vi phạm trong một lượt ⇒ output nêu **cả hai**, không dừng ở vùng đầu.
- **Cả mười ca cũ vẫn xanh**, không đổi một kỳ vọng nào.

## Verify

```bash
bash scripts/check-phase-boundary.test.sh
./scripts/gate.sh
```

`verify.sh` (Gate 1) chạy ở lượt này vì `scripts/` có đổi — nó tự gọi mọi `scripts/*.test.sh`.
Dán output của cả hai lệnh.

## Unknowns

Không có câu hỏi nghiệp vụ nào: bước này không chạm một dữ kiện quán nào.

Một chỗ **cố ý để ngỏ**: vùng pha 3 (`docs/product/3-be/`) và pha 4 (`docs/product/4-fe/`) **không**
được thêm ở lượt này. Thư mục của chúng chưa tồn tại, và một bộ mẫu viết cho một vùng chưa có nội
dung là một bộ mẫu **chưa bao giờ được chấm** — đúng loại lỗi **F-017** ghi.
