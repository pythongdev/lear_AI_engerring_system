# Lược đồ lát giao việc — một việc và các lần đánh dấu

Pha 2 · bước `P2A-11` · 2026-10-14 · thi công Codex, thiết kế Claude Code theo phiếu giao việc.
Quyết định: `docs/decisions.md` **ADR-105** điểm 1, 2, 3, 6.

**Bản nào thắng:** tên bảng, cột, kiểu và ràng buộc thuộc
[`db/migrations/20261014140000_giao_viec.up.sql`](../../../db/migrations/20261014140000_giao_viec.up.sql)
(**ADR-053** luật 2). File này giữ ý định, lý do và ánh xạ `I-030` · `YC-35`.

Nguồn lời là `master_plan/shop-facts.md` §8.7; mệnh đề ở `quality/invariants.md` `I-030`;
tầng và các tập phải rỗng ở `docs/product/1-system-design/03-bao-ve-invariant.md` §5;
yêu cầu ở `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, dòng `YC-35`.
Người và vết dùng lại [06-luoc-do-nguoi-va-vet.md](06-luoc-do-nguoi-va-vet.md).
Quy ước cất và kiểm ở [01-quy-uoc-du-lieu.md](01-quy-uoc-du-lieu.md) và
[10-quy-uoc-code.md](10-quy-uoc-code.md); đường lùi ở
[07-thu-tu-migration.md](07-thu-tu-migration.md).

## 1. Hai bảng — giữ gì và vì sao

| Bảng | Giữ gì | Lý do |
|---|---|---|
| `assigned_task` | nội dung, một người nhận, người tạo và lúc tạo; người ẩn và lúc ẩn | trả lời đủ bốn câu của việc, việc đã ẩn còn đọc lại được |
| `assigned_task_mark` | từng lần xong hoặc bỏ đánh dấu, việc được đánh dấu, người bấm và lúc bấm | gỡ đánh dấu bằng sự kiện mới, giữ cả hai lần theo ADR-105 điểm 3 |

Người nhận và người thao tác cùng thuộc `person`. Người thao tác mặc định lấy từ giao dịch;
lúc tạo do database cấp. Vai ghi sửa được nội dung, người nhận và dấu ẩn, không đổi người tạo
hay lúc tạo. Sự kiện chỉ thêm. Cả hai bảng dùng trigger vết chung cho lần cập nhật (QD-52),
kể cả lần sửa tay của chủ lược đồ; không quyền xoá (QD-50), không khoá ngoại dây chuyền (QD-51).

Không sự kiện nghĩa là chưa xong. Khi đã có sự kiện, đọc mới nhất theo `created_at DESC, id DESC`
như test Claude viết trước; `id` phân định hai sự kiện cùng mốc. Bảng việc không cất trạng thái
hay cờ xong độc lập. `mark_code` là loại sự kiện: `done` là đánh dấu xong, `undone` là bỏ đánh dấu.
Không có hạn, ghi chú riêng hay nhiều người nhận. Đây là hình Claude chọn trong phiếu, không
phải lời bổ sung của chủ quán.

## 2. Mệnh đề → cái giữ nó → bằng chứng

Test I-030 trong bảng là `db/tests/i030_assigned_task_names_assignee_and_marks.sql`,
chạy qua `./scripts/db-check.sh`. Câu đối chiếu ở `db/reconcile/i030.sql`, mỗi câu có lỗi
cài cùng số trong `db/reconcile/proof/`; ánh xạ ở
[09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md).

| Mệnh đề · yêu cầu | Tầng | Cái giữ nó | Bằng chứng |
|---|:--:|---|---|
| `I-030` · `YC-35`: nội dung, đúng một người nhận, ai tạo, lúc tạo | 1 | nội dung bắt buộc không trắng; khoá ngoại về người và dấu tạo bắt buộc | test I-030 từ chối thiếu nội dung, người nhận, người tạo và người lạ; `I-030/1` |
| `I-030` · `YC-35`: chủ quán hoặc POS tạo, sửa, ẩn, đánh dấu | 3 | cửa ghi xét người làm tại mốc thao tác; database chỉ giữ người có thật | test I-030 nói thẳng database nhận người ngoài vai; `I-030/2` đọc người tạo, người bấm, người ẩn và vết sửa, đối chiếu trực quầy |
| `I-030` · `YC-35`: mỗi lần đánh dấu mang người và lúc, sự kiện ở lại | 1 | sự kiện riêng, người và lúc bắt buộc; vai ghi không sửa, không xoá | test I-030 đánh dấu rồi gỡ còn hai sự kiện, từ chối sửa/xoá; `I-030/3` |
| `I-030` · `YC-35`: đã xong là suy ra | 1, theo cấu tạo | không có cờ xong trên việc; đọc sự kiện mới nhất | test I-030 đọc lược đồ và đọc ra `undone` sau lần gỡ |
| `I-030` · `YC-35`: sửa có bản trước, bản sau, lý do, người sửa | theo `I-018` | trigger `record_revision_capture`, chế độ nghiêm ADR-092 | test I-030 sửa người nhận và nội dung, đọc hai vết; câu chung `I-018/1` |
| `I-030` · `YC-35`: xoá là ẩn, việc và sự kiện còn, có người và lúc ẩn | 1 | cặp dấu ẩn đi cùng nhau, khoá ngoại người ẩn, mốc ẩn không trước tạo; không quyền xoá | test I-030 ẩn rồi đọc lại hai sự kiện, từ chối xoá cứng và ẩn thiếu người; `I-030/4` |
| `I-030`: người khác bấm trên máy đang mở | 4 | chỉ giữ một tên người cho mỗi sự kiện; không nhận ra người cầm máy | giới hạn của owner; không có tập dữ liệu phân biệt bấm hộ |

`db/scenario/yc.sql` tự dựng việc, thêm hai sự kiện, sửa rồi ẩn trong giao dịch ROLLBACK;
dòng `yc_doc` của `YC-35` đọc nội dung, người nhận, người tạo, lúc tạo, các lần đánh dấu,
người và lúc ẩn. `yc_tu_choi` thử việc thiếu người nhận; `yc_goi_ten` dẫn `I-030/2`.
Một ngày quản trị lượt hai ở các file scenario riêng vẫn là việc của `P2A-15`.

## 3. Giới hạn và bước sau

ADR-105 điểm 1 giao vế ai được làm cho tầng 3; lát không dựng trigger xét chủ quán hay POS.
Câu đối chiếu dùng `counter_duty` với khoảng đầu đóng, cuối mở như lát người, và cờ chủ quán
hiện hành: lược đồ không có lịch sử cờ chủ quán. Vết sửa đọc theo người sửa và lúc sửa;
việc sửa tay không có vết thì mang giới hạn chung của `I-018`.

Sự kiện hoặc việc bị xoá mất ngoài quyền ứng dụng không còn dấu để đối chiếu. Đọc lược đồ và
kịch bản gỡ/ẩn là bằng chứng cho quyền ứng dụng, không phải chứng minh không ai vượt database.
Vế tầng 4 bấm hộ cũng không có tập phân biệt được. Cửa `be/internal/giaoviec` xét người thao tác qua lớp `quay_hoac_chu_quan` (P3A-03);
`P2A-15` rà bộ câu và diễn ngày lượt hai; `P2A-16` rà ranh giới pha.

Lát không thêm bảng vào các tham số ngoại lệ của quy ước dữ liệu.
