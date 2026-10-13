<a id="top"></a>
# Vết sửa và sổ giấy — chứng minh cửa sửa, khai số lượt và chặn ký ngày còn giấy

Pha 3 · bước `P3-11` · viết 2026-10-12 (Claude thiết kế, Codex thi công, Claude duyệt và tích hợp).
Thiết kế và lý do: ADR-095 ở [decisions.md](../../decisions.md).

**File này sở hữu:** cách backend chứng minh vết theo từng cửa sửa, khai sổ giấy và đọc số lượt
còn lại; thứ tự kiểm, xét tên từ chối và giới hạn của lát.

**File này KHÔNG sở hữu:** luật sổ giấy của `master_plan/shop-facts.md` §6 quy tắc 11 và 27,
ADR-037; tầng bảo vệ của I-016 · I-018; chế độ nghiêm của trigger (ADR-092); schema và tên
ràng buộc ở migration. Hình HTTP và mã ở [openapi.yaml](openapi.yaml), lớp quyền ở
[02-vai-va-quyen.md](02-vai-va-quyen.md), khoá ngày và phép trừ két ở
[06-duong-tien.md](06-duong-tien.md).

## 1. Bảng cửa

| Cửa | Việc của lát | Lớp |
|---|---|---|
| `ket/khai_so_giay` | thêm paper_ledger với ngày, số lượt và người đã qua quyền | `quay_hoac_chu_quan` |
| `ket/doi_soat_xong` | từ chối khi số khai trừ số hoá đơn của sổ còn dương | `chu_quan` |

`GET /sale-days/{sale_date}/cash-reconciliation` thêm số lượt khai (null khi chưa có sổ) và số
lượt chưa nhập (0 khi chưa có sổ). Số còn lại tính từ hoá đơn, không nhận từ người dùng.

## 2. Thứ tự kiểm

Khai sổ: kiểm hình ngày và entry_count nguyên dương → authz.Run → so ngày theo đồng hồ giao
dịch và múi giờ quán (ngày tương lai trả invalid_request, field sale_date) → khoá tư vấn chung
của ngày được khai → kiểm ngày đã ký (sale_day_reconciled) → thêm sổ. Ngày cũ được khai;
không lấy ngày hôm nay thay cho ngày người giữ sổ chọn. Khoá chung giữ tới COMMIT, cùng namespace
với khoá riêng của cửa ký; lần ký đợi lần khai đang ghi xong rồi mới đọc số.

Ký ngày giữ thứ tự của ADR-089: khoá riêng → đủ số đếm và đầu két → chưa ký → còn lượt giấy
thì 409 paper_entries_pending → kiểm giải thích khi lệch → ghi dấu. Giải thích không bỏ qua
điều kiện còn giấy (ADR-037 điểm 2).

## 3. Vết từng cửa và khoảng hở QR

`TestI018_MoiCuaSuaCoVet` gọi HTTP cho từng cửa có UPDATE, hoặc cửa gọi nó nếu lớp
`theo_cua_goi`. Mỗi ca đọc đúng dòng trước/sau và đối chiếu cả hai ảnh trong record_revision,
lý do không trắng, person_id đúng người qua quyền. `TestI018_TapCuaSuaKhopTapCa` đọc thư mục
SQL lúc chạy và so với chính bảng ca ấy; cửa UPDATE mới thiếu ca làm test đỏ.

Phép đối chiếu I-016 giữ tập kiểm chuyển ngoài bảng và thêm kiểm khoảng hở giữa hai vết của
cùng phiên, xếp theo id của vết. Chỉ cặp bản sau Chờ thanh toán → bản trước Đang phục vụ
có một đơn qr_table của phiên tạo trong khoảng hai mốc (kể cả biên) được tha. Khoảng hở khác
vẫn là lệch. Hai biên được tính vì các câu trong cùng giao dịch có thể có cùng mốc now().
Không gán người hệ thống và không sửa chế độ nghiêm.

## 4. Nhận việc — xét tên từ chối

| Tên | Ánh xạ | Lý do |
|---|---|---|
| paper_ledger_one_per_day_key | paper_ledger_already_declared (409) | ngày đã khai sổ |
| paper_ledger_entry_count_positive_check | internal | handler đã kiểm số nguyên dương |
| paper_ledger_person_fkey | internal | authz.Run kiểm người tồn tại |
| paper_ledger_id_day_count_key; paper_ledger_pkey | internal | định danh do database sinh; cửa không sửa bản soi |

## 5. Giới hạn có tên

**Cửa nhập bù hoá đơn** (2026-10-13, `T-174`, **ADR-099** và *Sửa đổi* cùng ngày; lời **U-079** ở
`shop-facts.md` §6 quy tắc 11): `POST /sale-days/{sale_date}/paper-entries`, cửa `hoadon/nhap_bu`, lớp
`quay_hoac_chu_quan`. Mỗi lời gọi gõ lại **một lượt** trên giấy: vị trí `1…N` của sổ, `sold_at` (thuộc ngày của sổ,
trước giờ cửa), tại bàn (`dining_table_id`) hoặc mang đi (liên hệ như đơn hotline, `I-022`), từng món như lượt gọi,
phần trả như cửa trao tiền. Giá tính qua `gia.Tinh` ở mốc `sold_at` ([03-ham-gia.md](03-ham-gia.md)). Tại bàn ⇒ một
phiên tạo thẳng ở `closed`, bàn dọn ở `sold_at`, một đơn `staff_pos` `completed`; mang đi ⇒ một đơn `phone_preorder`
`completed`; không việc trạm nào. Hoá đơn mang `booked_at = sold_at`, ngày của sổ, sổ · số khai · vị trí; người là người
nhập bù. Từ chối: ngày đã ký ⇒ `sale_day_reconciled` · chưa khai sổ ⇒ `paper_ledger_missing` · vị trí ngoài `1…N` ⇒
`invalid_request` `paper_position` · vị trí đã nhập ⇒ `paper_position_already_entered` (tầng cửa, và ánh xạ
`bill_paper_position_key` khi hai lời gọi chen nhau) · `sold_at` ngoài ngày hoặc sau giờ cửa ⇒ `invalid_request`
`sold_at` · giảm giá khi không là chủ quán ⇒ `owner_only`. Cửa chỉ INSERT, nên không có ca trong
`TestI018_MoiCuaSuaCoVet`. Không có cửa sửa số lượt đã khai; thay đổi ấy cần quyết định riêng.

## 6. Bằng chứng cần chạy

| Test hoặc lệnh | Chứng minh |
|---|---|
| `be/internal/don/nhap_bu_test.go` | `TestYC08_NhapBuTaiBanQuaCua` · `TestYC08_NhapBuMangDiQuaCua` · `TestI009_NhapBuTinhGiaLucBan` · `TestYC08_NhapBuTuChoi` · `TestI021_NgayGiayNhapDuRa0dLech` — cửa nhập bù (T-174) |
| TestI018_MoiCuaSuaCoVet; TestI018_TapCuaSuaKhopTapCa | từng cửa UPDATE có ca và đủ vết |
| TestYC08_KhaiSoGiayQuaCua; TestYC08_KhaiSoGiayNgayDaKy | hình, quyền, trùng ngày, ngày tương lai và đã ký |
| TestI014_KyNgayConLuotGiayBiTuChoi; TestI014_KhaiSoChenLucKyNgay | số còn giấy, từ chối ký và khoá ngày |
| ./scripts/db-check.sh | đối chiếu và proof khoảng hở QR |
| ./scripts/gate.sh | hợp đồng, ma trận, sqlc và cổng chung |

Đây là yêu cầu chạy; kết quả thật nằm ở báo cáo thi công, không mặc định test đã xanh.

[↑ đầu file](#top)
