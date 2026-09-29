# Prompt — lập kế hoạch và sổ việc cho LƯỢC ĐỒ DỮ LIỆU của mảng admin (mức L2)

> Viết 2026-09-29 theo yêu cầu chủ repo: *"làm luôn db cho phần admin — kiểm tra đã đủ dữ liệu
> chưa, nếu rồi thì viết prompt để làm master plan, backlog"*. Prompt này **không** dựng lược đồ:
> đầu ra của nó là **một kế hoạch** và **một sổ mô tả việc**, để các phiên sau dựng theo.
> Mọi con số đếm trong prompt đo ngày 2026-09-29 — **đếm lại ở owner**, đừng tin (`work/findings.md` F-003).

## Context

Đọc theo thứ tự này, và chỉ những thứ này, trước khi viết dòng đầu tiên:

1. `CLAUDE.md` (luật chung) và output `./scripts/brief.sh`.
2. **Thứ tự làm giữa lane admin và các pha — lời Đ-2:** `work/backlog.md`, mục *Thứ tự làm giữa
   lane admin và các pha*. Hôm nay nó nói **thu luật** admin được chạy song song pha 2, còn **thi
   công** admin thì **không**, và pha 2 không được gánh lược đồ admin. `docs/decisions.md`
   **ADR-031** nói ba mảng admin đi **sau** bán hàng ở nghĩa thi công.
3. **Dữ kiện admin của quán:** `master_plan/shop-facts.md` §8 (§8.4 nguyên liệu · §8.5 tiền đầu két ·
   §8.6 tổng quan · §8.7 con người · §8.8 trực quầy · §8.9 sản phẩm · §8.10 tài chính). Các vế còn
   thiếu: `work/admin-questions.md` §3 và `docs/product/99-unknowns.md`.
4. **Mô tả nghiệp vụ của 29 việc admin:** `work/backlog_AD.md` (mục *Cổng của cả lane* và entry
   `ADM-10`…`ADM-15`, `ADM-20`…`ADM-24`, `ADM-40`…`ADM-45`, `ADM-50`…`ADM-52`). Ranh giới nghiệp
   vụ: `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · `docs/product/1-system-design/architecture.md` §14.
5. **Pha 2 đang chạy thế nào:** `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` (§3 ranh giới,
   §5 bản đồ file, §6 mười bốn bước, §9 cổng), `docs/decisions.md` **ADR-050** (năm tầng dịch sang
   pha 2) · **ADR-053** (migration thắng) · **ADR-049** (mã bước), và hai file quy ước
   `docs/product/2-db/01-quy-uoc-du-lieu.md` · `docs/product/2-db/10-quy-uoc-code.md`.
6. **Pha 1 bảo vệ gì:** `docs/product/1-system-design/04-yeu-cau-du-lieu.md` (YC) và
   `quality/invariants.md` (I-0xx).

### Kết quả kiểm "đã đủ dữ liệu chưa" — đo 2026-09-29, phiên viết prompt

**Trả lời ngắn: đủ cho MỘT PHẦN, chưa đủ cho cả ba mảng.** Chia theo mảng:

| Mảng | Đủ luật để thiết kế lược đồ | Chưa đủ — chặn bởi |
|---|---|---|
| Nguyên liệu (§8.4) | danh mục hàng mua vào có **đơn vị mua**, thêm dần; mục tổng **hàng ngày**, mỗi thứ **hai con số** mua vào · đã dùng do chủ quán nhập tay; **thời gian nhập**; tổng cộng dồn **từ ngày mua**; số thiếu = tổng nhập − tổng dùng; **không** ngưỡng, **không** giá vốn | đơn vị ghi lượng đã dùng / quy đổi bao gói, đơn vị các tên cũ (B12) · một mặt hàng nhiều mối (B15) · kỳ trả nợ nhà cung cấp, trả từng phần (B16) · cách nhập lượng kiểm đếm cuối buổi (B18) |
| Con người (§8.7–§8.8) | mức 1 trực quầy **đã dựng** ở `P2-08`; mức 2 **nhân viên tự bấm** chấm công; đi muộn không trừ tiền; nghỉ đột xuất không trừ; **tạm ứng** do chủ quán duyệt; **thưởng lễ Tết** có; người nhà không lương vẫn nằm trong bảng lương | **công thức lương**: đơn giá, đơn vị tính (buổi/ngày) và kỳ trả (tuần) (C26 · C33) · tăng ca (C27) · nghỉ có báo trước (C30) · thưởng ngày đông (C28) · tổng đầu người (C23) · ai xem được gì (C34 · C35 · F55, U-061) |
| Tài chính (§8.10) | khoản chi điện · nước · wifi · xăng; chi lặt vặt từ **tiền riêng** chủ quán; tiền cuối buổi để ở nhà và **phải ghi đường đi**; phải **theo dõi người giao nộp tiền** | cách phân bổ chi phí tháng vào lãi/lỗ ngày (E47) · ai ghi/nhận tiền mang về (E49) · hạn nộp và xử lý nộp thiếu/muộn (E51) · chu kỳ wifi/xăng (E45) · thuế (E50) |
| Sản phẩm (§8.9) | — (thuộc lát menu `P2-05`, không phải lát admin) | combo (U-059 chưa có danh mục) · giảm giá cả đơn (**U-058** mở) · món mới/đặc sản |

**Ba lỗ lớn hơn từng câu hỏi — kế hoạch phải xử lý, không được lờ:**

- **Pha 1 chưa từng thiết kế cho admin.** `04-yeu-cau-du-lieu.md` chỉ có YC cho mảng bán hàng;
  `quality/invariants.md` không có mệnh đề nào về nguyên liệu, chấm công, lương, chi phí. Pha 2
  **thi hành** tầng của pha 1 (ADR-050), nên với admin **không có gì để thi hành**. Kế hoạch phải
  có bước viết **YC và invariant cho phần admin đã đủ luật** trước mọi lát lược đồ — đúng thứ tự
  pha 1 → pha 2, không nhảy cóc.
- **Pha 2 chưa đóng.** `P2-09`, `P2-11`, `P2-13`, `P2-14` chưa có dòng *Done* ở `work/backlog.md`
  (kiểm lại). Lát admin sẽ phải đi qua cùng cổng thứ tự migration, bộ đối chiếu và cổng chất lượng.
- **Lời F52–F55 nằm trên nhánh chưa gộp.** Nhánh `task/f52-f55` có commit `3d5b834` ghi lời
  F52–F55 vào `shop-facts.md` §8.11 và mở U-061, nhưng nhánh làm việc hiện tại **chưa có** — và
  commit ấy mang mã `T-096` trùng với một `T-096` khác đã có trên nhánh này. **Không đọc dữ kiện
  từ nhánh chưa gộp.** Hỏi chủ repo có gộp không; chưa gộp thì coi F52–F55 là chưa trả lời.

## Goal

Sau lượt này, một phiên mới mở repo ra biết được: **lát lược đồ admin nào dựng được ngay, theo thứ
tự nào, mỗi lát nhận được khi nào và chứng minh xong bằng lệnh gì** — và phần nào đang chờ câu
nào của chủ quán, không một lát nào tự quyết thay chủ quán.

## Scope

Khai `work/scope/<T-XXX>.txt` trước lần sửa đầu (`CLAUDE.md` §3.4), đúng danh sách này:

```text
master_plan/                     chỉ file kế hoạch MỚI của lượt này (tên ở Acceptance 3)
work/                            chỉ file sổ mô tả MỚI của lượt này (tên ở Acceptance 4)
work/backlog.md
docs/decisions.md
docs/product/99-unknowns.md
work/admin-questions.md
CLAUDE.md
docs/product/00-index.md
```

Viết dòng cụ thể (tên file thật), không để cả thư mục `master_plan/` hay `work/` mở.

**Không được sửa:** `master_plan/shop-facts.md`, `quality/invariants.md`,
`docs/product/1-system-design/`, `docs/product/2-db/`, `db/migrations/`, `work/backlog_AD.md`,
`work/backlog_DB.md`, `master_plan/DB_master_plan_banh_cuon_ba_thanh.md`. Kế hoạch **trỏ** tới
chúng; việc sửa chúng là **bước** trong kế hoạch, làm ở lượt sau.

## Constraints

1. **Việc đầu tiên là ghi lời mở cổng, không phải viết kế hoạch.** Lời Đ-2 hôm nay cấm thi công
   admin song song pha 2. Yêu cầu *"làm luôn db cho phần admin"* của chủ repo ngày 2026-09-29 là
   lời đổi vế ấy. Ghi nó vào mục *Thứ tự làm…* của `work/backlog.md` (owner của Đ-2) kèm ngày và
   người nói, và mở **một ADR** sửa đổi ADR-031 (thi công lược đồ admin được bắt đầu trước khi
   pha 2 đóng — phạm vi đúng bằng lời, không rộng hơn). **Nếu chủ repo chưa xác nhận câu này
   trong phiên của bạn thì dừng và hỏi** — đây là lời của người quyết, không phải suy luận.
2. **Không bịa luật.** Mỗi lát trong kế hoạch phải trỏ được tới dòng owner đã chốt nó
   (`shop-facts.md` §8.x hoặc `U-XXX` đã đóng). Vế chưa có lời thì ghi vào cột *Chặn bởi* của
   bước, hoặc mở `U-XXX` mới ở `docs/product/99-unknowns.md` (một bullet dưới `### Đang mở`, đúng
   khuôn), **không** thiết kế bù. Luật này không có mức L0.
3. **Không viết tên bảng, tên cột, SQL, endpoint, route, component** trong kế hoạch hay sổ mô tả.
   Kế hoạch nói *"ghi được / không xảy ra được"*; tên bảng là đầu ra của lát lược đồ (ADR-035,
   ADR-053). Gate 1d chỉ bắt một phần — tự đọc lại.
4. **Không tự đặt mã mới trùng nghĩa.** `ADM-XX` là việc tầng nghiệp vụ (luật 5 đầu
   `work/backlog_AD.md` cấm tên bảng ở đó); `P2-XX` là mười bốn bước đã đóng khung của pha 2.
   Mã bước lược đồ admin là một lựa chọn thiết kế ⇒ ghi trong ADR ở Constraint 1 hoặc một ADR
   riêng. Đề xuất mặc định (chủ repo có thể đổi): tiền tố **`P2A-XX`**, sổ mô tả riêng
   `backlog_AD_DB.md` trong thư mục `work/`, trạng thái vẫn chỉ ở `work/backlog.md` (ADR-002).
5. **Kế hoạch chép khuôn của pha 2, không chép nội dung.** Cùng sáu cột §6 (ID · Việc · Cần xong
   trước · Đầu ra kiểm chứng được · Hỏng thì mất gì · Mức), cùng kiểu cổng §9. Không chép bảng
   giá, danh mục nguyên liệu hay lời chủ quán vào kế hoạch — trỏ tới `shop-facts.md` (F-001).
6. **Thứ tự bắt buộc của các bước trong kế hoạch:**
   1. *Yêu cầu dữ liệu và invariant cho phần admin đã đủ luật* — YC mới nối tiếp dãy hiện có,
      invariant mới ở `quality/invariants.md`, tầng bảo vệ theo pha 1. Mức L2.
   2. *Lát lược đồ*, mỗi mảng một lát, chỉ phần đủ luật (bảng *Kết quả kiểm* ở trên — **đo
      lại**): sổ nguyên liệu · chấm công và các khoản của người (tạm ứng, thưởng) · khoản chi và
      đường đi của tiền. Lát dùng lại người và vết của `P2-08`, quy ước `P2-03`/`P2-12`, không
      định nghĩa lại. File tài liệu mới nối số sau `11-` trong `docs/product/2-db/`, **thêm**
      không ghi đè (bản đồ §5 của kế hoạch pha 2).
   3. *Nối vào ba bước chung của pha 2*: thứ tự migration có đường lùi (`P2-09`), phép đối
      chiếu mới vào bộ `P2-11`, diễn một buổi admin qua lược đồ ở cổng (`P2-13`). Ghi rõ lát
      admin **chờ** hay **đi cùng** các bước ấy.
   4. *Phần bị chặn* (công thức lương, lãi/lỗ ngày, nợ nhà cung cấp, quyền xem…) — mỗi phần
      **một dòng** ghi câu chặn, **không** chẻ bước, không viết Acceptance.
7. **Mười hai bước là trần** (`master_plan/prompt-fullstack.md` §8). Vượt thì ghi lý do như kế
   hoạch pha 2 đã làm.
8. **Đường dẫn file chưa tồn tại** không viết đủ thư mục lẫn tên file trong một cặp dấu nháy
   ngược ở file mà Gate 1b chấm — viết tên file trần cạnh thư mục (`prompt/AD/README.md`).

## Acceptance

1. `work/backlog.md` mục *Thứ tự làm…* có dòng lời mới ngày 2026-09-29, ghi người nói; và
   `docs/decisions.md` có ADR mới sửa đổi ADR-031, bảng tổng hợp đầu file khớp thân ADR.
2. Mã bước và nơi đặt sổ mô tả được chốt trong một ADR (Constraint 4).
3. Có **một** file kế hoạch mới trong `master_plan/` cho lược đồ admin, với: bảng *Kết quả kiểm*
   đã **đo lại** ngày chạy; bảng bước sáu cột theo đúng thứ tự Constraint 6; mục *Phần bị chặn*;
   mục cổng chất lượng kiểu §9 pha 2; mục *Chỗ kế hoạch này SUY RA* tách khỏi lời đã chốt (F-004).
4. Có **một** sổ mô tả mới trong `work/`, mỗi bước một entry theo khuôn `work/backlog_DB.md`
   (vì sao · hỏng thì mất gì · mười bước chạy); bước có *Cần xong trước* chưa `Done` thì **chưa**
   viết khối *Nhận việc* (T-051, ADR-051).
5. `work/backlog.md` → *Ready* có dòng cho **đúng** những bước nhận được ngay (thường chỉ bước
   YC/invariant); các bước khác chỉ có mô tả ở sổ mới.
6. `CLAUDE.md` §2 có hàng cho sổ mô tả mới và kế hoạch mới (nếu là owner mới) — cùng thay đổi.
7. Mỗi vế chưa có lời mà kế hoạch cần đã có mã: câu `B`/`C`/`E` ở `work/admin-questions.md` §3
   hoặc `U-XXX` mới ở `docs/product/99-unknowns.md`. Không vế nào chỉ sống trong kế hoạch.
8. `grep` trên kế hoạch và sổ mới không ra tên bảng, SQL, endpoint, route (dán lệnh và output,
   in cả lệnh chưa lọc cạnh lệnh đã lọc — F-017).
9. `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -nE 'CREATE |ALTER |/api/|<[A-Z][a-zA-Z]+ ' master_plan/<file-kế-hoạch-mới> work/<sổ-mới>
grep -n '2026-09-29' work/backlog.md docs/decisions.md
```

## Unknowns

Gặp câu nghiệp vụ chưa rõ ⇒ dừng phần ấy, ghi `U-XXX` (khuôn ở `docs/product/99-unknowns.md`
→ *Cách viết một câu ở đây*), để trống trong kế hoạch. Đặc biệt **không** tự chọn: đơn giá và
công thức lương, cách phân bổ chi phí tháng, luật trả nợ nhà cung cấp, quy đổi đơn vị nguyên liệu,
ai được xem lương/công.

## Report (AI trả lời sau khi làm)

Viết bằng tiếng Việt, văn xuôi (`CLAUDE.md` §1): đã tạo gì, lát nào nhận được ngay, lát nào chờ câu
nào (mỗi mã kèm link tới dòng của nó, `grep -n` trong cùng lượt — §7.3), output gate làm bằng
chứng, bảng Acceptance → bằng chứng, và khối commit §6.1.
