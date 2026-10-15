# Lược đồ lát đào tạo — hướng dẫn của việc và ghi nhận về người

Pha 2 · bước `P2A-12` · 2026-10-14 · thi công Codex, thiết kế Claude Code theo phiếu giao việc.
Quyết định: `docs/decisions.md` **ADR-107**, **ADR-105** điểm 1, 4, 6.

**Bản nào thắng:** tên bảng, cột, kiểu và ràng buộc thuộc
[`db/migrations/20261014150000_dao_tao.up.sql`](../../../db/migrations/20261014150000_dao_tao.up.sql)
(**ADR-053** luật 2). File này giữ ý định, lý do và ánh xạ `I-031` · `YC-36`.

Nguồn lời là `master_plan/shop-facts.md` §8.7; mệnh đề ở `quality/invariants.md` `I-031`;
tầng và các tập phải rỗng ở `docs/product/1-system-design/03-bao-ve-invariant.md` §5;
yêu cầu ở `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, dòng `YC-36`.
Dùng lại việc của [16-luoc-do-giao-viec.md](16-luoc-do-giao-viec.md), người và vết của
[06-luoc-do-nguoi-va-vet.md](06-luoc-do-nguoi-va-vet.md). Quy ước ở
[01-quy-uoc-du-lieu.md](01-quy-uoc-du-lieu.md) và [10-quy-uoc-code.md](10-quy-uoc-code.md);
bước 25 và khoá chặn đường lùi ở [07-thu-tu-migration.md](07-thu-tu-migration.md).

## 1. Hai bảng — giữ gì và vì sao

| Bảng | Giữ gì | Lý do |
|---|---|---|
| `assigned_task_guide` | một việc giao, loại chữ/ảnh/video, chữ hoặc khoá tệp, người gắn và lúc gắn, dấu ẩn | mỗi mẩu thuộc đúng một việc; một việc có nhiều mẩu; tệp nằm ngoài database theo ADR-107 |
| `training_record` | một người được ghi nhận, nhận xét và/hoặc đánh giá, người ghi và lúc ghi, dấu ẩn | ghi nhận đứng trên người, mỗi lần một dòng, lần mới không thay lần cũ theo ADR-105 điểm 4 |

Hai bảng có khoá identity, người thao tác mặc định từ `actor_person_id()`, lúc ghi mặc định
`now()`. Các người đều trỏ về `person`; hướng dẫn trỏ về `assigned_task`. Khoá ngoại không
dây chuyền (QD-51), quyền mặc định không cấp xoá (QD-50), cập nhật mang trigger
`record_revision_capture()` (QD-52). Cặp người/lúc ẩn đi cùng nhau, lúc ẩn không trước lúc tạo.

`guide_kind_code` nhận `text`, `image`, `video`. Chữ có `body` không trắng và không `file_code`;
ảnh/video có `file_code` và không `body`. Khoá tệp dài 1–255 ký tự, mở đầu bằng chữ thường hoặc
số, phần sau chỉ thêm dấu chấm, gạch dưới, gạch nối, gạch chéo; không chứa `..`.
`file_code` là định danh máy đọc, so từng byte bằng `COLLATE "C"` theo QD-61.
`body` và `remark` dùng cách so tiếng Việt. `rating_code` nhận `pass` (*đạt*) hoặc `not_yet`
(*chưa*), có thể thiếu; nhận xét có thể thiếu nhưng khi có không trắng, hai trường không cùng rỗng.

Vai `shop_app` chỉ sửa `body`, `file_code`, dấu ẩn của hướng dẫn và `remark`, `rating_code`,
dấu ẩn của ghi nhận. Không đổi việc, loại, người được ghi nhận, người ghi/gắn hay lúc ghi/gắn;
ghi nhầm người thì ẩn và ghi lại. Mọi ghi nhận đọc theo `created_at, id` để phân định cùng mốc.

## 2. Mệnh đề → cái giữ nó → bằng chứng

Test I-031 là `db/tests/i031_task_guide_and_training_record.sql`, Claude viết trước, không sửa.
Chạy qua `./scripts/db-check.sh`; bảng dưới chỉ chỗ kiểm, không khẳng định đã chạy xanh.
Câu đối chiếu ở `db/reconcile/i031.sql`, mỗi câu có lỗi cài cùng số ở `db/reconcile/proof/`;
ánh xạ ở [09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md).

| Mệnh đề · yêu cầu | Tầng | Cái giữ nó | Bằng chứng |
|---|:--:|---|---|
| `I-031` · `YC-36`: hướng dẫn gắn đúng một việc có thật | 1 | một khoá ngoại bắt buộc về việc | test I-031 từ chối thiếu việc/việc lạ; `I-031/1`, lỗi cài `i031_1.sql` bỏ việc |
| `I-031` · `YC-36`: chữ, ảnh hoặc video; ảnh/video là chỗ trỏ tệp | 3 cho kho tệp; 1 cho hình dữ liệu | loại và hình chữ/khoá tệp có CHECK; khoá tệp ngắn; không cột chứa tệp | test I-031 từ chối loại lạ, sai hình, dữ liệu nhúng, đường tuyệt đối, khoá dài; đọc lược đồ |
| `I-031` · `YC-36`: ghi nhận về ai, ai ghi, lúc ghi | 1 | khoá ngoại bắt buộc tới người, lúc ghi bắt buộc | test I-031 thiếu người/người lạ bị từ chối; `I-031/2`, lỗi cài `i031_2.sql` bỏ lúc ghi |
| `I-031` · `YC-36`: người ghi là chủ quán hoặc POS | 3 | cửa ghi xét vai tại lúc ghi; database giữ người có thật | test I-031 nói rõ database nhận người ngoài vai; `I-031/3`, lỗi cài `i031_3.sql` đổi người ghi ngoài vai |
| `I-031` · `YC-36`: không rỗng cả nhận xét lẫn đánh giá | 1 | CHECK không rỗng, nhận xét có thì không trắng | test I-031 từ chối rỗng/trắng; `I-031/4`, lỗi cài `i031_4.sql` xoá cả hai giá trị |
| `I-031` · `YC-36`: chỉ đạt hoặc chưa | 1 | CHECK hai mã đánh giá khi có | test I-031 từ chối giá trị thứ ba/điểm số; `I-031/5`, lỗi cài `i031_5.sql` đặt `good` |
| `I-031` · `YC-36`: sửa có vết | theo `I-018` | trigger vết chung, chế độ nghiêm ADR-092 | test I-031 đọc bản trước/sau, lý do, người sửa; câu chung `I-018/1` |
| `I-031` · `YC-36`: xoá là ẩn, dấu ẩn đủ, mọi ghi nhận ở lại | 1 | cặp dấu ẩn, khoá ngoại người ẩn, mốc ẩn; không quyền xoá | test I-031 ghi hai lần, ẩn rồi đọc lại, từ chối xoá; `I-031/6`, lỗi cài `i031_6.sql` bỏ người ẩn hướng dẫn |

Khối `YC-36` trong `db/scenario/yc.sql` có dòng `yc_doc` đọc hướng dẫn của một việc và một
ghi nhận cùng người ghi/gắn, lúc ghi/gắn, dấu ẩn; `yc_tu_choi` thử ghi nhận rỗng cả hai;
`yc_goi_ten` dẫn vế tầng 3 tới `I-031/3`. Một ngày lượt hai vẫn thuộc `P2A-15`.

## 3. Giới hạn và bước sau

Không trigger xét người ghi là chủ quán hoặc POS: ADR-105 điểm 1 giao cho tầng 3.
`I-031/3` dùng `counter_duty` theo khoảng `[started_at, ended_at)` và cờ `person.is_owner`
hiện hành như `I-030/2`, không có lịch sử cờ chủ quán. Câu chỉ xét dòng có lúc ghi;
thiếu người hoặc lúc thuộc `I-031/2`. Vết sửa của cả hai bảng dùng tập `I-018/1`.

Chỗ trỏ tệp chưa có tập dạng dữ liệu: kiểm bằng đọc lược đồ và thử khoá tệp, không viết
câu đối chiếu riêng. Theo ADR-107, kho tệp ở cùng nơi chạy hệ thống (PT-2); sao lưu database
không chứa tệp, vận hành phải sao lưu kho riêng. Khoá trỏ tới tệp đã mất vẫn hợp lệ ở database:
tệp không mở được nhưng chữ hướng dẫn vẫn đọc được. Cửa dựng và phục vụ kho ở `be/internal/daotao`, dùng biến `BANHCUON_FILE_DIR` (P3A-04).

Phần đã bị xoá mất, kể cả ghi nhận cũ bị thay mất mà không còn dấu, chưa có tập để đối chiếu.
Test ghi hai lần rồi ẩn và đọc lại cùng kiểm quyền xoá chứng minh đường ứng dụng giữ dữ liệu;
không chứng minh người có quyền vượt database không xoá được. `P2A-15` rà bộ câu và diễn ngày
lượt hai; `P2A-16` rà ranh giới pha.
