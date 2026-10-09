<a id="top"></a>
# Đường tiền — mỗi lần tiền đổi tay qua một cửa có người

Pha 3 · bước `P3-09` · viết 2026-10-09 (Claude thiết kế, Codex thi công; chờ Claude duyệt).
Thiết kế và các suy luận: [ADR-089](../../decisions.md).

**File này sở hữu:** cách backend ghi đường tiền, nối chuỗi trả trước và thu nợ, lấy ngày bán,
đếm két và ký ngày; phần xét tên từ chối của lát.

**File này KHÔNG sở hữu:** luật tiền ở `master_plan/shop-facts.md` §6; công thức đối soát ở
[architecture.md](../1-system-design/architecture.md) §6.4; lược đồ và tên ràng buộc ở migration;
hình yêu cầu, trả về và mã ở [openapi.yaml](openapi.yaml); lớp quyền ở
[02-vai-va-quyen.md](02-vai-va-quyen.md). Cách đọc các hạng tử:
[04-luoc-do-duong-tien.md](../2-db/04-luoc-do-duong-tien.md) §3, §7.

## 1. Cách đọc lát và bảng cửa

Mỗi dòng tiền mới có người đã qua `authz.Run`. Ba cửa không lối vào nhận `pgx.Tx` của cửa gọi;
`authz.Run` từ chối lớp `theo_cua_goi`. Chúng không mở giao dịch riêng. Phụ thuộc một chiều
`hoadon → tratruoc`; một ô thêm chỉ có một câu ghi.

| Cửa | Ô ghi sở hữu hoặc cửa gọi tiếp | Lớp |
|---|---|---|
| `hoadon/dong` | gọi ghi hoá đơn, chuyển phiên Đã đóng | `quay` |
| `hoadon/trao_tai_quay` | gọi ghi hoá đơn, chuyển đơn Hoàn thành | `quay` |
| `hoadon/giao_xong` | gọi ghi hoá đơn, chuyển đơn Hoàn thành | `nguoi_quan` |
| `hoadon/hoan` | gọi ghi hoàn cho hoá đơn | `quay` |
| `hoadon/thu_no` | thêm debt_collection | `quay` |
| `tratruoc/nhan` | thêm prepayment | `quay` |
| `hoadon/tra_lai` | gọi ghi hoàn và dùng trả trước | `quay` |
| `ket/khai_dau_ket` | thêm opening_float và opening_float_line | `quay_hoac_chu_quan` |
| `ket/dem` | thêm cash_count và cash_count_line | `quay_hoac_chu_quan` |
| `ket/doi_soat_xong` | thêm reconciled_day | `quay_hoac_chu_quan` |
| `hoadon/ghi` | thêm bill; gọi dùng trả trước nếu có phần trả trước | `theo_cua_goi` |
| `hoadon/ghi_hoan` | thêm refund | `theo_cua_goi` |
| `tratruoc/dung` | thêm prepayment_use | `theo_cua_goi` |

Đường gọi có hình yêu cầu riêng, không nhận một cờ để đổi loại cửa. Hai đường đọc
`GET /debts` và `GET /sale-days/{sale_date}/cash-reconciliation` không ghi gì; giống các
đường đọc của lát trước, chưa có lớp quyền đọc riêng. Quyền đọc dữ liệu khi triển khai cần được
Claude xét; lát này không thêm lớp ngoài ADR-089.

## 2. Thứ tự kiểm và đồng hồ

HTTP kiểm hình trước khi đọc người; tiền là số nguyên không âm, trường bắt buộc không được thiếu.
Lý do hoàn không trắng; phương thức là cash hoặc transfer. Xấp tiền có mệnh giá dương, số tiền
không âm và chia hết cho mệnh giá, không trùng mệnh giá trong một yêu cầu.

Sau quyền là khoá dòng → tồn tại → ngày đã ký → điều kiện nghiệp vụ → ghi. Riêng giảm giá dương
và nợ đơn lẻ dương trả `order_discount_undecided` và `standalone_debt_undecided` ngay sau
quyền, trước đọc đơn. Hoá đơn đóng phiên cũng từ chối giảm giá dương.

`ngayban.DongHo` bản thật đọc `now()` của giao dịch; mọi dòng tiền có booked_at dùng cùng mốc
cho booked_at và `sale_date = $n::timestamptz::date`. Pool do `db.Open` đặt TimeZone của quán,
nên ngày không phụ thuộc múi giờ máy Go. Tiền đầu két và số đếm lấy ngày cùng cách; chúng không
có cột booked_at. Dấu đối soát nhận ngày cần ký từ đường dẫn theo ADR-089 điểm 5.

Cửa tiền giữ khoá tư vấn chung theo ngày đến COMMIT; cửa ký giữ khoá riêng cùng ngày trước khi
đọc phép trừ. Đây là cách thi công điều kiện không ghi tiền vào ngày đã ký: lần ghi đang chạy
phải xong trước phép tính lúc ký, lần đến sau thấy dấu và trả `sale_day_reconciled`.
Khoá chỉ giữ các cửa của lát; sửa tay ngoài cửa không được bảo vệ bởi nó.

## 3. Hoá đơn, hoàn, thu nợ và trả trước

Trao tại quầy chỉ nhận đơn lẻ tới lấy ở in_progress, không còn việc trạm chưa served. Giao xong
chỉ nhận door_delivery ở delivering. Đi nhầm cửa trả `order_handover_mismatch`; sai trạng thái
trả `order_transition_not_allowed`; còn việc trả `order_jobs_not_served`. Số phải trả cộng từ
line_total_vnd của đơn. Ghi bill và gọi `vongdoi.ChuyenDon` trong cùng giao dịch; lỗi ở bất kỳ
bước nào đều lùi cả tiền, trạng thái và vết.

Thu nợ khoá bill trước khi đọc chuỗi. Số còn nợ là min(remaining_vnd), hoặc debt_vnd khi chưa có
lần trả. Lần đầu ghi remaining_before_vnd NULL; mỗi lần sau nối vào số còn lại. Không sửa bill,
không tạo bill mới; danh sách nợ chỉ trả khoản còn dương (ADR-075, YC-10).

Nhận trả trước khoá đơn; chỉ đơn lẻ ở pending_confirmation, confirmed hoặc in_progress được nhận
(suy luận ADR-089). Khi dùng hoặc trả lại, khoá prepayment trước khi đọc mắt cuối; kiểm số lấy theo
từng phương thức, rồi nối đúng một mắt với use_no kế tiếp. Cửa không tự chia số dư. Hoá đơn nhận
phần trả trước do người bấm khai; refund trả lại mang tổng hai phần lấy, source_method_code NULL.
Cả refund và mắt chuỗi cùng sống hoặc cùng lùi.

Hoàn cho hoá đơn giữ phương thức trả, phương thức đã thu, lý do và người bấm. Không có trần hoàn
tiền, theo shop-facts.md §6.4. Hoàn vào ngày mới không sửa doanh thu ngày hoá đơn cũ.

## 4. Phép trừ két và ký ngày

`be/internal/ket/sql/ket_ngay.sql` là bản đọc có chủ ý của `pg_temp.ket_ngay`
(`db/reconcile/prelude.sql`, ADR-089 điểm 6). Giữ từng hạng tử: tiền mặt hoá đơn và phần trả trước,
hoàn cho tiền mặt, hai chiều hoàn chéo, thu nợ, nhận trả trước, trừ trả trước thành doanh thu,
trả lại trả trước bằng tiền mặt, chi tạm ứng và thưởng theo ngày khai. Không rút gọn công thức.
Đường đọc và cửa ký dùng cùng file này. Gap = counted − opening − expected; expected và gap có thể âm.

Cửa ký xét theo thứ tự ADR-089 điểm 5:

| Điều kiện chặn | Mã 409 |
|---|---|
| Thiếu số đếm hoặc tiền đầu két | `cash_day_incomplete` |
| Đã có dấu | `sale_day_already_reconciled` |
| Còn lượt sổ giấy chưa nhập | `paper_entries_pending` |
| Tạm ứng/thưởng có ngày khai khác ngày ghi và chạm ngày đang xét | `cash_day_expense_date_undecided` |
| Gap khác 0, dù chỉ một đồng | `cash_day_not_balanced` |

Chỉ ngày đủ điều kiện mới thêm dấu. Không có ô lý do để đóng ngày lệch. Ngày có khoản chi chờ
U-072 vẫn đọc được bốn con số; cửa ký từ chối, không chọn hộ ngày tiền rời két.
Số đếm hoặc đầu két có dòng đầu nhưng không có xấp là dữ liệu ngoài cửa; trigger từ chối ký
với `cash_day_incomplete`.

## 5. Nhận việc — xét tên từ chối

Mọi tên của bill, debt_collection, prepayment, prepayment_use, refund, opening_float,
opening_float_line, cash_count, cash_count_line và reconciled_day đã được xét ở hợp đồng 0.6.0.

| Nhóm tên | Mã hoặc cách xét | Lý do |
|---|---|---|
| bill_parts_equal_due_check; bill_debtor_iff_debt_check | payment_parts_mismatch; debtor_name_mismatch | giữ ánh xạ từ lát tại bàn; cửa kiểm tổng và tên trước ghi |
| prepayment_use_balance_check | prepayment_balance_exceeded | không lấy quá số dư theo từng phương thức |
| prepayment_one_per_order_key | prepayment_already_received | một khoản cho một đơn |
| opening_float_one_per_day_key; cash_count_one_per_day_key | opening_float_already_declared; cash_count_already_recorded | mỗi ngày một lần khai/đếm |
| reconciled_day_one_per_day_key | sale_day_already_reconciled | mỗi ngày một dấu |
| debt_collection_amounts_check | debt_overpaid | giữ chuỗi nợ giảm đúng và không âm |
| Bốn tên kết thúc reconciled_day_locked_check | sale_day_reconciled | trigger khoá cả đầu và các dòng xấp của ngày đã ký |
| Hai khoá ngoại từ reconciled_day về số đếm/đầu két; hai has_lines_check | cash_day_incomplete | dấu phải có cả hai số không rỗng |
| Khoá chính; khoá duy nhất trên cột tự tính/bản soi | internal | database sinh định danh; cửa không khai cột tự tính |
| Khoá chuỗi debt_collection và prepayment_use, khoá bill theo đơn/phiên | internal | khoá cha trước đọc mắt cuối/trạng thái, nên cửa không rẽ nhánh hay ghi lần hai |
| Khoá ngoại người, đơn, phiên, bill, prepayment, refund và các bản soi | internal | quyền/tồn tại kiểm trước ghi; khoá giữ cha; trạng thái và tiền ghi cùng giao dịch |
| Điều kiện số tiền, phương thức, lý do, mệnh giá; duy nhất mệnh giá | internal | HTTP kiểm hình; cửa sinh đúng nguồn và đúng số cho mỗi dòng |
| Điều kiện một đích, một đơn vị, trả trước chỉ đơn lẻ, phương thức nguồn chỉ hoàn bill | internal | cấu tạo từng cửa và các tham số cửa gọi giữ hình ấy |
| Các tên bill_paper_* | internal | cửa hiện tại không nhận thông tin nhập bù |
| Bốn tên kết thúc reconciled_day_truncate_check | internal | backend không có đường TRUNCATE |

Các nhóm internal bao phủ những tên còn lại của mười bảng; danh sách từng tên ở
`x-constraint-errors` của hợp đồng. Tên của bảng chỉ đọc như paper_ledger, staff_advance,
holiday_bonus giữ nguyên; chúng thuộc lát ghi của mình.

## 6. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| Huỷ đơn đã xác nhận | không thêm cửa huỷ; phần trả lại trả trước đã có cửa | P3-10 |
| Sửa dòng tiền, sửa tiền đầu két, nhập bù | không có cửa ở lát này | P3-11 |
| Khoản chi I-029 | chưa có bảng khoản chi, chưa có hạng tử ấy | P2A-05 |
| Tin nhắn báo có | chưa có chỗ cất, chưa đối soát chuyển khoản bằng tin nhắn | lát sau |
| U-058 — giảm giá cả đơn | giảm giá dương bị từ chối bằng order_discount_undecided | chủ quán |
| U-073 — đóng ngày lệch đã tìm ra lý do | lệch khác 0 bị từ chối bằng cash_day_not_balanced | chủ quán |
| U-076 — khách đơn lẻ chưa trả đủ | nợ dương bị từ chối bằng standalone_debt_undecided | chủ quán |
| U-072 — ngày két của khoản chi | ngày khai khác ngày ghi bị từ chối ký bằng cash_day_expense_date_undecided | chủ quán |
| Quyền đọc của `GET /debts` · `GET /sale-days/{sale_date}/cash-reconciliation` | như mọi đường đọc hiện có, không đòi người gọi — mà `GET /debts` trả **tên người nợ** (`YC-11`); chưa có chương trình chạy thật nên chưa lộ ra đâu | cùng lượt với cách đăng nhập — **U-075**; trước khi backend chạy thật (Claude, 2026-10-09) |
| I-014 tập 6 — con số đã ký | cửa không ghi tiền vào ngày đã ký; không chụp con số, sửa tay ngoài cửa vẫn chưa có câu bắt | tầng 4; ADR-089 điểm 4 |

Các câu hỏi nằm ở [99-unknowns.md](../99-unknowns.md); tài liệu này không đóng hay trả lời chúng.

## 7. Bằng chứng cần chạy

| Test hoặc lệnh | Chứng minh |
|---|---|
| `TestQC14_HinhDuongTienTruocQuyen` | yêu cầu sai bị chặn trước đọc người/database |
| `TestI012_QuayHoacChuQuanTuChoiNguoiNgoaiQuay` | authz.Run từ chối thiếu người và người ngoài quầy; nhận chủ quán/quầy |
| `be/internal/don/duong_tien_test.go` qua `./scripts/be-check.sh` | một ngày đủ đường tiền ra 0đ; lỗi cài làm cửa và bộ đối chiếu cùng kêu; tiền và trạng thái cùng lùi; vết, quyền, chuỗi và ngày ký |
| `./scripts/check-write-paths.sh --list` | mỗi ô ghi đúng một cửa, ba ô dùng chung có cửa riêng |
| `./scripts/check-api-contract.sh --list` | đường gọi, mã, ánh xạ, ma trận và Door bằng nhau |
| `./scripts/gate.sh` | các cổng chung và bộ kiểm backend |

Danh sách này là yêu cầu chạy; kết quả thật nằm trong báo cáo thi công và phần bàn giao của task
sau khi Claude tích hợp.

[↑ đầu file](#top)
