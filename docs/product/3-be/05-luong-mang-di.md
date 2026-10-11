<a id="top"></a>
# Luồng mang đi — ba kênh ngoài bàn qua cùng cửa tạo lượt gọi

Pha 3 · bước `P3-08` · viết 2026-10-09 (Claude thiết kế và duyệt, Codex thi công). Vì sao thiết kế
thế này và cái bị loại: [`../../decisions.md`](../../decisions.md) **ADR-088**.

**File này sở hữu:** cách backend thực hiện phần ngoài bàn của cửa tạo lượt gọi, xét I-008,
so dấu với liên hệ, rời quán và phần xét ràng buộc của lát.

**File này KHÔNG sở hữu:** luật kênh và liên hệ ở
[`../../../master_plan/shop-facts.md`](../../../master_plan/shop-facts.md) §5.2 · §6.5; vòng đời ở
[`../0-ba/ban-hang/05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5.2; lược đồ trong migration;
đường gọi, hình yêu cầu/trả về và mã lỗi ở [`openapi.yaml`](openapi.yaml); lớp quyền ở
[`02-vai-va-quyen.md`](02-vai-va-quyen.md); giá ở [`03-ham-gia.md`](03-ham-gia.md).

## 1. Cửa, ô ghi và lớp quyền

| Cửa | Ô ghi sở hữu | Lớp |
|---|---|---|
| `don/tao_luot_goi` | thêm `sales_order`, `order_line`, `order_line_component`, `order_line_option`, `table_session`, `table_session_member`; nhánh ngoài bàn không ghi hai bảng phiên | `quay_hoac_khach` |
| `don/duyet` | không; gọi chuyển đơn, chuyển phiên nếu có | `quay` |
| `don/tu_choi` | không; gọi chuyển đơn | `quay` |
| `don/roi_quan` | không; gọi chuyển đơn | `quay` |
| `don/nha_hen` | không; gọi `sanxuat/no_don` trong cùng giao dịch | `quay` |
| `vongdoi/chuyen_don` | sửa `sales_order.status` | `theo_cua_goi` |

Hai đường `POST /online-orders` và `POST /phone-orders` vào **chính** `don/tao_luot_goi`.
Web không gọi bộ đọc danh tính, kể cả có header; khách không khai người thao tác. Hotline phải là
người có thật đang đứng quầy. Người có danh tính không dùng nhánh khách để tránh kiểm quyền.

## 2. Hình liên hệ và thứ tự tạo

Bảng này trỏ luật của từng hình, không dựng bảng luật thứ hai. Các cột và ràng buộc do
[`../../../db/migrations/20260928090000_lien_he_don_mang_di.up.sql`](../../../db/migrations/20260928090000_lien_he_don_mang_di.up.sql)
sở hữu; mức bắt buộc và vế ngược của I-022 ở `shop-facts.md` §6.5.

| Hình | Schema của đường gọi | Nguồn mức liên hệ |
|---|---|---|
| Web giao (`delivery`) | `OnlineOrderRequest` | `shop-facts.md` §6.5 cột delivery; migration liên hệ |
| Web tới lấy (`pickup`) | `OnlineOrderRequest` | `shop-facts.md` §6.5 cột pickup; migration liên hệ |
| Hotline giao (`phone_preorder`, `door_delivery`) | `PhoneOrderRequest` | `shop-facts.md` §6.5 cột phone_preorder, nhánh giao; migration liên hệ |
| Hotline tới lấy (`phone_preorder`, `shop_pickup`) | `PhoneOrderRequest` | `shop-facts.md` §6.5 cột phone_preorder, nhánh tới lấy; migration liên hệ |

1. HTTP kiểm dấu `submission_code` trước; rồi trường cấm (kể cả null), kênh/cách trao, liên hệ,
   cuối cùng `lines`. Thiếu hoặc sai hình trả `invalid_request` kèm tên trường, trước quyền.
   Bỏ khoảng trắng chỉ để kiểm trường bắt buộc còn nội dung; chuỗi ghi vẫn nguyên từng byte.
   Mốc gửi lên dùng RFC 3339 có độ lệch theo `01-hop-dong-api.md` §6. Phần nhỏ hơn micro giây bị cắt ngay lúc
   đọc — PostgreSQL chỉ giữ tới micro giây, nên lần gửi lại so đúng với mốc đã ghi (Claude, 2026-10-09).
2. Trong giao dịch, `authz.RunAs` kiểm quyền, rồi tra dấu toàn cục. Cùng nội dung trả **200**;
   khác trả `submission_code_conflict`. Cách so do `01-hop-dong-api.md` §8 sở hữu: gồm kênh,
   cách trao, liên hệ và dòng món; mốc so cùng khoảnh khắc, chuỗi so từng byte, vắng tương đương null.
   Không xét lại I-008 hoặc tính lại giá khi đã có đơn. Tranh chấp dấu chạy lại cả giao dịch,
   giữ giới hạn bốn lần và hai tên từ chối như [luồng tại bàn](04-luong-tai-ban.md) §3.
3. Chưa có dấu thì xét I-008 (§3), trước phần riêng của kênh và mọi lần đọc/mở phiên bàn.
4. Nhánh tại bàn làm như lát trước; nhánh ngoài bàn giữ `table_session_id`, `dining_table_id`,
   `qr_code_id` NULL. Không có đường nối đơn ngoài bàn vào phiên; dấu đi qua đường khác bị conflict.
5. Gọi `gia.Tinh` trong cùng giao dịch; ghi đơn, liên hệ và ảnh chụp các dòng. Trạng thái đầu lấy
   `vongdoi.TrangThaiDauDon(kenh)`; `order_line.is_takeaway` để database dùng mặc định false.
   Theo phiếu T-142 (thiết kế ADR-091, Claude, 2026-10-09), `phone_preorder` giữ `confirmed`,
   chưa nổ việc; nếu giờ cần hàng trừ 20 phút đã tới theo `don.DongHo` thì gọi `sanxuat.NoDon`
   ngay trong giao dịch tạo. `staff_pos` vẫn nổ ngay; `pickup`/`delivery` của khách nổ lúc duyệt.
6. Đọc lại và trả **201** theo `TakeawayOrder`, hoàn toàn vắng hai trường bàn/phiên. Gửi lại giữ
   cùng hình và trạng thái hiện tại. Duyệt/từ chối dùng cửa đã có, trả hai trường phiên là null.

### Nhả đơn hẹn và đọc nhắc

Máy POS tự gọi `POST /preorder-releases` bằng người đang đứng quầy; người không phải bấm cho
đơn xuống bếp. Cửa `don/nha_hen` nhận thân rỗng hoặc `{}`, lấy mốc từ `don.DongHo`, khóa các đơn
`phone_preorder` còn `confirmed` có giờ cần hàng trừ 20 phút không lớn hơn mốc ấy, theo giờ hẹn
rồi mã đơn, bằng `FOR UPDATE SKIP LOCKED`. Đơn đang bị khóa để lượt gọi sau xử lý; xét lại trạng
thái sau khóa rồi gọi `sanxuat.NoDon` cho từng đơn trong cùng giao dịch. Vết chuyển trạng thái
mang người gọi; lỗi lùi cả lần. Trả **200** với `released_order_ids`, luôn là mảng kể cả khi rỗng.

`GET /preorder-reminders` chỉ đọc, cùng kiểu quyền với `GET /production-board`: không kiểm
người hay lớp cửa ghi. Danh sách gồm đơn điện thoại ở `confirmed` hoặc `in_progress`, sắp theo
giờ cần hàng rồi mã đơn. Mỗi dòng có hai mốc `remind_at` trước giờ cần hàng 20 và 10 phút;
`due_reminders` là `[]`, `[20]` hoặc `[20, 10]` theo cùng `don.DongHo`. Lần nhắc thứ hai không
nổ thêm việc. Đơn đã xong hoặc hủy không còn trong danh sách. Gửi lại dấu tạo đơn chỉ trả đơn
cũ, không tự nhả dù đã tới giờ nhắc. Hình trên dây do `openapi.yaml` sở hữu.

## 3. Đồng hồ và I-008

`don.DongHo` bản thật đọc `SELECT now()` từ **chính giao dịch** được đưa vào; chỉ test thay nó.
Giờ bán là hai hằng code trỏ `shop-facts.md` §1, so trên giờ địa phương theo múi giờ phiên kết nối
mà `db.Open` đã đặt. Hai đầu tính là trong giờ, cùng cách tập 1 của
[`../../../db/reconcile/i008.sql`](../../../db/reconcile/i008.sql). Test đọc giờ bán từ owner lúc chạy.

Cửa xét lần lượt và dừng ở điều kiện đầu tiên chặn:

| Thứ tự | Phép đọc | Mã 409 |
|---|---|---|
| 1 | `order_intake_pause` có khoảng `[started_at, ended_at)` phủ mốc; cả năm kênh | `order_intake_paused` |
| 2 | giờ địa phương ngoài khoảng giờ bán, cả năm kênh | `outside_selling_hours` |
| 3 | `shop_blind_spell` có khoảng phủ mốc, chỉ delivery · pickup · qr_table | `shop_not_seeing_orders` |

Staff POS và hotline vẫn qua điều kiện quán mù. Các câu đọc là `const` inline trong gói `don`,
không sinh thư mục cửa riêng. Không ghi hai bảng khoảng ngừng nhận đơn; nguồn lược đồ là
[`../../../db/migrations/20261001140000_khoang_chan_tao_don.up.sql`](../../../db/migrations/20261001140000_khoang_chan_tao_don.up.sql).
Từ chối trước phần kênh không ghi đơn, dòng hay phiên nào.

## 4. Rời quán và vế S-6

`POST /orders/{sales_order_id}/departure` vào `don/roi_quan`: kiểm quyền, khoá đơn, không có đơn
trả `sales_order_not_found` **404**. `vongdoi.KiemChuyenDon` dùng chung bảng kiểm với `ChuyenDon`;
phải đúng cặp từ `in_progress` tới `delivering`, cách trao `door_delivery`, nếu không trả
`order_transition_not_allowed` **409** trước khi xét việc trạm.

Sau đó đọc **bất kỳ** `station_job` của đơn có `status <> 'served'`: còn thì từ chối
`delivery_served_mark_undecided` **409**, không ghi gì. Đây là chỗ S-6 chưa có lời ở `shop-facts.md`
§7.2; cửa không tự đổi việc trạm. Không còn thì gọi `vongdoi.ChuyenDon(..., "delivering")`
trong chính giao dịch; vết mang người quầy và lý do. Trả **200** theo `OrderTransition`, hai trường
phiên là null. Cửa rời quán chỉ giữ câu khoá/đọc dưới `sql/roi_quan/`, không sở hữu ô ghi mới.

## 5. Nhận việc — xét từng tên từ chối

| Tên | Xét ở lát này | Lý do |
|---|---|---|
| `sales_order_takeaway_handover_check` | `internal` | Web suy cách trao từ kênh; hotline đã kiểm enum trước quyền. |
| `sales_order_takeaway_phone_check` | `internal` | Số điện thoại bắt buộc và không trắng được kiểm ở HTTP. |
| `sales_order_takeaway_needed_at_check` | `internal` | HTTP kiểm mốc bắt buộc theo kênh, đúng RFC 3339 có độ lệch. |
| `sales_order_door_delivery_address_check` | `internal` | Nhánh giao tận nơi đã kiểm địa chỉ có nội dung. |
| `sales_order_handover_code_check` | `internal` | Chỉ hai mã hợp lệ do đường gọi quyết hoặc đã kiểm enum. |
| `sales_order_session_iff_table_channel_check` | giữ `internal` | Ba kênh ngoài bàn luôn ghi NULL cho bàn và phiên. |
| `sales_order_qr_code_iff_qr_channel_check` | giữ `internal` | Ngoài bàn không ghi mã QR. |
| `sales_order_channel_code_check` | giữ `internal` | Kênh do HTTP kiểm hoặc đường hotline quyết. |
| `sales_order_status_check` | giữ `internal` | Trạng thái đầu và mọi lần sửa qua bảng vongdoi. |
| `sales_order_submission_code_key` | giữ `internal` | Cửa chạy lại sau tranh chấp, tra dấu và so nội dung. |
| `sales_order_bill_fkey` | giữ `internal` trong phạm vi lát | Chưa đưa đơn lẻ tới Hoàn thành; đường hoá đơn đơn lẻ thuộc P3-09. |
| `sales_order_id_if_standalone_key` | giữ `internal` | Cột tự tính, không ghi trực tiếp. |

Các tên `sales_order_*` còn lại tiếp tục theo giải thích của [luồng tại bàn](04-luong-tai-ban.md)
§5; dòng món theo [hàm giá](03-ham-gia.md). Các dòng `order_intake_pause_*` và `shop_blind_spell_*`
đang `unreviewed` giữ nguyên vì lát chỉ đọc; khoá chính đang `internal` cũng giữ nguyên. Không thêm
ánh xạ `constraintCodes`. `bill_*` và `prepayment_*` không đổi; P3-09 xét khi mở đường tiền đơn lẻ.

## 6. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **S-6 — lúc nào POS bấm đã ra bàn của đơn giao** | rời quán khi còn việc chưa served bị từ chối kèm mã; không tự ghi việc trạm | chủ quán, `shop-facts.md` §7.2 |
| **Bật/tắt tạm dừng nhận đơn** | chưa có cửa; khoảng tạm dừng hôm nay chỉ ghi tay ở database; ai bấm chưa có lời ở `architecture.md` §7 dòng *Hết nguyên liệu → tạm dừng nhận đơn* | Claude/chủ quán làm rõ trước khi dựng cửa |
| **Phát hiện quán mù và ghi khoảng mù** | cửa tạo chỉ đọc `shop_blind_spell` | `P3-12` |
| **Hoàn thành của đơn lẻ** | cần hoá đơn đơn lẻ; lát này chưa có cửa tới trạng thái ấy | `P3-09` thu tiền · `P3-10` ghi đã ra bàn |
| **Đặt trước tối đa một ngày và giờ cần hàng ở quá khứ** | cửa không xét; chưa có luật cho máy | `02-thoi-gian-ngay-ban.md` §4, U-036 |
| **Đường đọc quán đang nhận đơn không cho web** | chưa có, dù cửa tạo đã chặn ngoài giờ | `shop-facts.md` §6 quy tắc 8 — web khoá nút ngoài giờ |

## 7. Bằng chứng cần chạy

| Test hoặc lệnh | Chứng minh |
|---|---|
| `be/internal/don/mang_di_hinh_test.go` | hình yêu cầu bị từ chối trước đọc người/database; so chuỗi nguyên byte, vắng/null và cùng khoảnh khắc |
| `be/internal/don/mang_di_test.go` qua `./scripts/be-check.sh` | đồng hồ giao dịch; biên giờ bán và thứ tự I-008; liên hệ đủ/thiếu; không phiên; gửi lại và chen nhau; quyền, rời quán, vết và S-6 |
| `be/internal/don/don_test.go`, `tai_ban_test.go` qua cùng lệnh | giá và các luồng tại bàn vẫn chạy với đồng hồ cố định trong giờ bán |
| `cd be && go build ./... && go vet ./...`; `gofmt -l be` | build, phân tích tĩnh và định dạng |
| `./scripts/check-write-paths.sh --list` | vẫn một cửa mỗi ô ghi; rời quán không ô ghi mới |
| `./scripts/check-api-contract.sh --list` | ba đường mới, bốn mã, lớp đổi tên và ma trận khớp code |
| `./scripts/gate.sh` | kiểm phạm vi, tài liệu, hợp đồng và bộ kiểm chung |

Kết quả chạy thật thuộc báo cáo thi công và khối *Bàn giao* của `P3-08` trong sổ task pha 3 sau khi
Claude tích hợp; danh sách này không phải lời khẳng định đã chạy xanh.

[↑ đầu file](#top)
