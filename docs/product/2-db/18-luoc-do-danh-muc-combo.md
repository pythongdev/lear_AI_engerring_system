# Lược đồ lát danh mục món và combo có giá riêng

Pha 2 · bước `P2A-13` · 2026-10-14 · thi công Codex, thiết kế Claude Code theo phiếu giao việc.
Quyết định: `docs/decisions.md` **ADR-108**, **ADR-105** điểm 1, 5, 6.

**Bản nào thắng:** tên bảng, cột, kiểu và ràng buộc thuộc
[`db/migrations/20261014160000_danh_muc_combo.up.sql`](../../../db/migrations/20261014160000_danh_muc_combo.up.sql)
(**ADR-053** luật 2). File này giữ ý định, lý do và ánh xạ `I-032` · `YC-37`.

Nguồn lời: `master_plan/shop-facts.md` §8.9; mệnh đề: `quality/invariants.md` `I-032`;
tầng và các tập phải rỗng: `docs/product/1-system-design/03-bao-ve-invariant.md` §5;
yêu cầu: `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9, dòng `YC-37`.
Dùng món của [03-luoc-do-menu-gia.md](03-luoc-do-menu-gia.md), người và vết của
[06-luoc-do-nguoi-va-vet.md](06-luoc-do-nguoi-va-vet.md). Quy ước ở
[01-quy-uoc-du-lieu.md](01-quy-uoc-du-lieu.md) và [10-quy-uoc-code.md](10-quy-uoc-code.md);
bước 26 và khoá chặn đường lùi ở [07-thu-tu-migration.md](07-thu-tu-migration.md).

## 1. Bốn bảng — giữ gì và vì sao

| Bảng | Giữ gì | Lý do |
|---|---|---|
| `menu_category` | tên, người lập, lúc lập, người và lúc ẩn | chủ quán tự thêm danh mục; tên duy nhất trong danh mục còn dùng, ẩn rồi nhường tên |
| `menu_item_category` | món duy nhất, danh mục, người xếp, lúc xếp | nhiều nhất một danh mục mỗi món; chưa xếp là không có dòng, bảng món giữ nguyên |
| `menu_combo` | tên, giá riêng nguyên đồng dương, người lập, lúc lập, dấu ẩn | giá chủ quán đặt, không tính từ thành phần; tên combo không buộc duy nhất |
| `menu_combo_item` | combo, món, số phần nguyên dương, lúc tạo; mỗi cặp một dòng | đọc lại thành phần và số phần, không chứa cột tiền |

Cả bốn bảng có khoá identity, lúc tạo mặc định `now()`. Ba bảng có người thao tác lấy mặc
định `actor_person_id()`. Các người trỏ về `person`, món trỏ về `menu_item`. Khoá ngoại
không dây chuyền (QD-51), quyền mặc định không cấp xoá (QD-50), mọi cập nhật có trigger
`record_revision_capture()` (QD-52). Dấu ẩn của danh mục và combo đi thành cặp; lúc ẩn
không trước lúc tạo. Tên dùng `COLLATE "vi-x-icu"`, không trắng (QD-60); giá `bigint`
`price_vnd > 0` (QD-20, QD-21). Không thêm cột, ràng buộc vào bảng món hay bảng giá cũ.

Trigger ràng buộc sau lần chèn combo là `DEFERRABLE INITIALLY DEFERRED`: cha và món ghi
trong cùng giao dịch; lúc kiểm, combo còn tồn tại mà không có món thì từ chối bằng
`menu_combo_has_item_check`. Hàm giữ quyền chủ lược đồ, cố định `search_path`, thu quyền
của PUBLIC. Vai `shop_app` không xoá hay chuyển món sang combo khác, nên không cần trigger
xoá thành phần. Đổi thành phần là lập combo mới và ẩn combo cũ theo ADR-108 điểm 5.

Quyền sửa chỉ có: danh mục sửa tên/dấu ẩn; xếp món sửa danh mục; combo sửa tên/giá/dấu ẩn;
thành phần combo sửa số phần. Người lập/xếp và lúc tạo không sửa được qua vai ứng dụng.
Đường lùi kiểm cả bốn bảng rỗng trước khi gỡ bất cứ thứ gì, rồi gỡ trigger ràng buộc, hàm,
thành phần combo, combo, xếp món và danh mục theo thứ tự ngược.

## 2. Mệnh đề → cái giữ nó → bằng chứng

Test `db/tests/i032_category_and_combo_own_price.sql` do Claude viết trước, không sửa.
Chạy qua `./scripts/db-check.sh`; bảng chỉ nơi kiểm, không khẳng định đã chạy xanh.
Tám câu ở `db/reconcile/i032.sql`; mỗi câu có lỗi cài cùng số ở `db/reconcile/proof/`.
Ánh xạ chung: [09-doi-chieu-bat-bien.md](09-doi-chieu-bat-bien.md).

| Mệnh đề · yêu cầu | Tầng | Cái giữ nó | Bằng chứng |
|---|:--:|---|---|
| `I-032` · `YC-37`: tên danh mục một lần khi còn dùng | 1 | chỉ mục duy nhất có điều kiện | test trùng tên, ẩn rồi dùng lại; `I-032/1`, `i032_1.sql` chèn tên trùng |
| Món nhiều nhất một danh mục có thật | 1 | khoá duy nhất trên món, khoá ngoại bắt buộc | test danh mục lạ, xếp hai lần, chuyển có vết; `I-032/2`, `i032_2.sql` xếp trùng |
| Combo ít nhất một món | 2 | trigger ràng buộc hoãn | test ép kiểm combo rỗng, đúng tên từ chối; `I-032/3`, `i032_3.sql` xoá hết món |
| Món có thật, số phần nguyên dương | 1 | khoá ngoại, integer NOT NULL, CHECK | test món lạ, thiếu/0/âm; `I-032/4`, `i032_4.sql` số phần 0 |
| Đúng một giá riêng nguyên đồng dương | 1 | một cột bigint NOT NULL, CHECK; thành phần không có tiền | test đọc lược đồ, giá thiếu/0/âm, đổi giá món; `I-032/5`, `i032_5.sql` giá NULL |
| Giá không đổi giữa buổi | 3 | cửa sửa giá xét giờ bán; database nhận | `I-032/6`, `i032_6.sql` dời vết đổi giá vào giờ bán |
| Danh mục và combo ẩn có người/lúc, đọc lại được | 1 | cặp dấu ẩn, khoá ngoại, mốc ẩn; không quyền xoá | test ẩn rồi đọc lại, từ chối xoá; `I-032/7`, `i032_7.sql` bỏ người ẩn |
| Người lập, sửa, ẩn là chủ quán | 3 | cửa ghi xét vai; database giữ người có thật | test ghi người ngoài vai được database nhận; `I-032/8`, `i032_8.sql` người lập là người đứng quầy |
| Sửa có vết; đơn cũ giữ giá | `I-018` · `I-009` | trigger vết chung; ảnh chụp đơn hiện hữu | test đọc bản trước/sau/người/lý do; dùng tập chung, không viết câu riêng |

Khối `YC-37` ở `db/scenario/yc.sql` có một dòng đọc danh mục và món, combo và số phần,
giá riêng, vết đổi giá, dấu ẩn; một dòng thử giá 0đ bị từ chối. Hai vế tầng 3 dẫn tới
`I-032/6` và `I-032/8`. Ngày mẫu có dữ liệu của cả bốn bảng, vết đổi giá đặt ngoài buổi,
trả lại người thao tác và lý do trước khối; mọi combo qua `SET CONSTRAINTS ALL IMMEDIATE`.

## 3. Giới hạn và bước sau

Không trigger xét chủ quán hoặc giờ bán: đó là tầng 3 (ADR-105 điểm 1, ADR-108 điểm 6).
`I-032/6` chỉ xét vết có lúc và có đổi giá, đọc `:mui_gio`, `:gio_mo`, `:gio_dong` từ owner
qua bộ chạy đối chiếu, cùng cách `I-011`; không tự đặt giờ. `I-032/8` đọc cờ
`person.is_owner` hiện hành như `I-030/2`, không có lịch sử cờ và không chấp nhận trực quầy
thay chủ quán. Vết sửa được đọc cả khi người ẩn trên dòng khác người sửa.

Món chưa xếp bị chặn bán chưa có tập: lần bị chặn không sinh dữ liệu; test đọc lược đồ
bảng món nguyên vẹn và không có liên kết bắt buộc từ bên ngoài lát. Không cộng từ giá món
chưa có tập vì giá đặt có thể tình cờ bằng tổng: kiểm lược đồ và kịch bản đổi giá món mà
giá combo giữ nguyên. Phần đã bị xoá mất chưa có tập khi không còn dấu: kiểm quyền xoá,
ẩn rồi đọc lại. Vết sửa dùng tập `I-018`, đơn cũ giữ giá dùng `I-009`, không nhân đôi câu.

Bỏ xếp về chưa xếp chưa có đường theo ADR-108 điểm 2; không tự cấp quyền xoá.
Đơn bán combo và hàm giá là việc backend, có migration riêng khi tới theo ADR-108 điểm 7;
lát này không sửa bảng đơn hay hàm giá. `P2A-15` rà bộ câu và diễn ngày lượt hai;
`P2A-16` rà ranh giới pha.
