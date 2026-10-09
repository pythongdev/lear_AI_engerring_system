<a id="top"></a>
# Luồng tại bàn — một lượt gọi, một phiên, một lần đóng

Pha 3 · bước `P3-07` · viết 2026-10-06…2026-10-09 (Claude thiết kế và duyệt, Codex thi công). Vì sao
thiết kế thế này và cái bị loại: [`../../decisions.md`](../../decisions.md) **ADR-087**. Lát này không
dựng thêm luật nghiệp vụ nào.

**File này sở hữu:** cách backend thực hiện luồng tại bàn: cửa nào giữ ô ghi nào, thứ tự khoá và
kiểm, cách trả lại đơn theo dấu lần gửi, giao dịch đóng phiên và phần xét ràng buộc của lát.

**File này KHÔNG sở hữu:**
- **vòng đời và ai kích hoạt** — [`../0-ba/ban-hang/05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md)
  §5.2 · §5.3; dữ kiện quán ở `master_plan/shop-facts.md`;
- **tầng bảo vệ invariant** — [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md),
  các hàng `I-001` · `I-002` · `I-003` · `I-006` · `I-016` · `I-017` · `I-024`;
- **bảng, cột và tên ràng buộc** — migration thắng; ý định ở
  [`../2-db/02-luoc-do-ban-hang.md`](../2-db/02-luoc-do-ban-hang.md),
  [`../2-db/04-luoc-do-duong-tien.md`](../2-db/04-luoc-do-duong-tien.md) và
  [`../2-db/06-luoc-do-nguoi-va-vet.md`](../2-db/06-luoc-do-nguoi-va-vet.md);
- **đường gọi, hình yêu cầu/trả về, mã lỗi** — [`openapi.yaml`](openapi.yaml);
  **lớp quyền** — [`02-vai-va-quyen.md`](02-vai-va-quyen.md);
- **luật giá và hàm tính giá** — [`03-ham-gia.md`](03-ham-gia.md).

---

## 1. Cửa, ô ghi và lớp quyền

Mỗi ô có đúng một cửa (`QC-13`). Câu ghi nằm trong file `.sql` dưới thư mục cửa; cửa không sở hữu ô
vẫn có thư mục chứa câu đọc/khoá. Mỗi cửa bên ngoài mở một giao dịch qua `authz.Run` hoặc `RunAs`;
hai cửa của `vongdoi` nhận `pgx.Tx` của cửa gọi, không mở giao dịch riêng và không có lối vào trực tiếp.

| Cửa | Ô ghi sở hữu | Lớp |
|---|---|---|
| `don/tao_luot_goi` | thêm `sales_order`, `order_line`, `order_line_component`, `order_line_option`, `table_session`, `table_session_member` | `quay_hoac_khach` |
| `don/duyet` | không; gọi cửa chuyển đơn và phiên | `quay` |
| `don/tu_choi` | không; gọi cửa chuyển đơn | `quay` |
| `phien/tinh_tien` | không; gọi cửa chuyển phiên | `quay` |
| `hoadon/dong` | thêm `bill`; gọi cửa chuyển phiên | `quay` |
| `ban/da_don` | sửa `table_session_member.cleaned_at` | `nguoi_quan` |
| `vongdoi/chuyen_don` | sửa `sales_order.status` | `theo_cua_goi` |
| `vongdoi/chuyen_phien` | sửa `table_session.status`, `table_session_member.session_closed` | `theo_cua_goi` |

`authz.RunAs` kiểm người và quyền ngay trong giao dịch. Người có danh tính phải có thật và đang
đứng quầy; không lấy mã QR làm đường thoát khi người ấy thiếu quyền. Nhánh QR không người phải mang mã
hiện hành, bàn tra từ mã qua một câu SQL duy nhất ở `authz.CurrentTable`; `qr.CurrentTable` gọi lại
hàm này để tránh vòng import. Khách không khai `shop.actor_person_id`.

`nguoi_quan` chỉ kiểm người có thật, không kiểm chỗ đứng: đây là **suy luận của phiên, ADR-087 điểm 7**,
dựa vào dòng dọn bàn của §5.3 và việc bốn trạm ngoài quầy không ghi mốc đổi người (`U-055`).
`authz.Run` gặp `theo_cua_goi` trả lỗi trước khi chạy thân cửa.

## 2. Thứ tự khoá và tạo lượt gọi

**Mọi cửa ghi vào một phiên khoá dòng `table_session` trước, rồi mới khoá hoặc ghi đơn.** Duyệt và
từ chối đọc mã phiên của đơn, khoá phiên nếu có, rồi mới khoá đơn và gọi `ChuyenDon`. Cửa từ chối
chỉ nhận đơn chờ xác nhận; huỷ một đơn đã xác nhận là một cửa khác của lát sau.

Tạo lượt gọi thực hiện theo thứ tự trong một giao dịch:

1. Kiểm hình yêu cầu trước quyền: dấu UUID chữ thường, bàn của đặt hộ, các dòng món theo hình của
   `gia.DongYeuCau` cộng `is_takeaway`. Bỏ trường lạ, kể cả giá. Riêng `table_session_id` luôn bị từ
   chối; đường khách còn từ chối `dining_table_id`, kể cả khi trường cấm mang `null`.
2. Kiểm quyền, rồi tra dấu lần gửi (§3). Đã có dấu thì trả lại hoặc từ chối, không tạo gì.
   Chưa có dấu thì xét I-008 trước mọi lần đọc hoặc mở phiên; thứ tự và đồng hồ ở
   [luồng mang đi](05-luong-mang-di.md) §3 (P3-08, ADR-088).
3. Đặt hộ đọc bàn tồn tại; khách lấy bàn từ mã đã kiểm. Khoá phiên chưa đóng của bàn bằng
   `FOR UPDATE OF s`, điều kiện chưa đóng đọc trên chính dòng phiên bị khoá. Nếu đóng chen vào lúc
   chờ khoá, câu đọc xét lại dòng ấy rồi cửa đọc lại trạng thái bàn.
4. Không có phiên thì đọc trạng thái bàn bằng `ban.Doc`. Bàn cần dọn bị từ chối; còn lại thêm phiên
   `open` và dòng bàn của phiên. Không dùng một phép kiểm có phiên hay chưa để chặn tranh chấp: khoá
   duy nhất `table_session_member_one_unpaid_session_key` quyết; cửa chạy lại cả giao dịch (§3).
5. Gọi `gia.Tinh`, ghi đơn và các ảnh chụp từ kết quả. `TrangThaiDauDon` quyết trạng thái đầu theo
   kênh: ghi thẳng trạng thái ấy, không thêm `new` rồi sửa. Dấu đem về đi theo từng dòng, cùng đơn và
   cùng phiên (`I-006`). Nếu tính giá từ chối thì phiên vừa thêm cũng lùi.
6. Đơn đã xác nhận trong phiên `open` đẩy phiên sang `serving`. Mọi lượt gọi thêm vào phiên
   `awaiting_payment`, kể cả khách QR còn chờ xác nhận, cũng đẩy phiên về `serving`.
7. Trả **201** với đơn, phiên, bàn, kênh, trạng thái, tổng và các dòng đã chụp.

`ban.Doc` và `GET /dining-tables` dùng **cùng một câu đọc trạng thái**: có phiên chưa đóng thì
`in_session`; không có phiên ấy mà còn dòng đã đóng chưa dọn thì `needs_cleaning`; còn lại `empty`.
Không cất trạng thái của bàn thành cột. Mã phiên và trạng thái phiên chỉ có mặt khi bàn đang thuộc
phiên chưa đóng. Nhóm ghép dùng chung phiên, còn dọn theo từng bàn.

## 3. Dấu lần gửi và bảng chuyển

Cách so nội dung do [`01-hop-dong-api.md`](01-hop-dong-api.md) §8 sở hữu: đặt hộ so bàn; khách so mã
QR của đơn với mã trên đường dẫn; so từng dòng theo thứ tự, gồm món, số suất, tập lựa chọn và dấu đem
về. Số dòng phải bằng nhau. Cùng dấu khác kênh là khác nội dung.

Khớp thì trả **200**, cùng hình trả về, trạng thái hiện tại và ảnh chụp đã lưu; không tính giá lại
khi menu đã đổi. Khác thì `submission_code_conflict` **409**, đơn cũ đứng nguyên. Nội dung giống hệt
mà dấu khác vẫn là hai lượt gọi thật.

Chỉ hai tên từ chối `sales_order_submission_code_key` và
`table_session_member_one_unpaid_session_key` kích chạy lại **toàn bộ** giao dịch, tối đa bốn lần
(lựa chọn thi công theo giới hạn vài lần của phiếu). Mỗi lần kiểm lại quyền và dấu. Hai tên ấy là
`internal`, không gửi tên ràng buộc tới người dùng; hết số lần thử thì lỗi hệ thống, không báo đã ghi.

`vongdoi.CapDon` và `CapPhien` giữ tập cặp theo §5.2 · §5.3, gồm nguồn rỗng cho dòng sinh ra. Test
đọc owner lúc chạy để so tập, không so với một bảng chép tay trong test. Hàm chuyển khoá dòng bằng
`FOR UPDATE`, tra cặp rồi mới sửa; không dòng trả mã không tìm thấy, ngoài bảng trả **409**.
Nhánh từ `new` kiểm kênh bằng `TrangThaiDauDon`; nhánh sang `delivering` kiểm cách trao hàng là
`door_delivery`, gồm cả đơn đặt trước giao tận nơi theo §5.2 và lược đồ bán hàng §4.

Nếu giao dịch có người, mỗi câu sửa trạng thái khai lý do `<mã cửa>: <nguồn> → <đích>` ngay trước
câu sửa và gỡ ngay sau nó. Khi đóng, câu sửa phiên chạy trước câu sửa mọi dòng bàn; mỗi câu đều có
lý do. Dọn bàn cũng khai lý do quanh câu sửa mốc. Không người thì không khai lý do — giới hạn §6.

## 4. Tính tiền, đóng phiên và dọn bàn

`phien/tinh_tien` khoá phiên, chuyển sang `awaiting_payment` qua `vongdoi`, rồi trả `due_vnd`.
`phien.TongTien` là **một chỗ cộng tiền của phiên** dùng chung với đóng: tổng `order_line.line_total_vnd`
của mọi đơn không `cancelled`, gồm mọi bàn ghép và mọi lượt gọi. Câu đọc lại một đơn khi gửi lại chỉ
cộng các dòng của chính đơn ấy; nó không tính tổng phiên hay quyết số phải thu.

`hoadon/dong` kiểm hình tiền trước quyền: ba phần tiền là số nguyên không âm và bắt buộc; tên người
nợ nếu có không được trắng. Trong **một giao dịch**, cửa khoá phiên, dùng bảng `vongdoi` kiểm có thể
sang `closed` trước mọi câu ghi, rồi khoá **mọi** đơn của phiên theo thứ tự mã đơn. Còn đơn ngoài
`completed`/`cancelled` thì `table_session_has_open_orders` **409**.

Sau đó cửa gọi `TongTien`, **thêm `bill` trước**, để `person_id` lấy mặc định từ người đã kiểm của
giao dịch, rồi gọi `ChuyenPhien(closed)`: sửa trạng thái phiên trước, đánh dấu mọi dòng bàn đã đóng
sau. Khoá ngoại hoãn được kiểm lúc commit; cắt giữa chừng lùi cả hoá đơn, trạng thái và dòng bàn.
Không kiểm tiền đã thu đủ để chặn đóng: phần chưa thu là nợ và database kiểm tên người nợ.

| Tên từ chối | Mã công khai | Status |
|---|---|---|
| `bill_parts_equal_due_check` | `payment_parts_mismatch` | 422 |
| `bill_debtor_iff_debt_check` | `debtor_name_mismatch` | 422 |

`ban/da_don` khoá các dòng đã đóng, chưa dọn của **bàn ấy**, sửa `cleaned_at = now()` rồi đọc lại
trạng thái. Không có dòng cần dọn: bàn không tồn tại trả `dining_table_not_found`, còn lại trả
`dining_table_not_needing_cleaning` **409**. Dọn A trong nhóm không làm B trống.

## 5. Nhận việc — xét từng tên từ chối

Bảng dưới giải thích từng dòng `internal` của `x-constraint-errors` thuộc phần lát này xét. Hai dòng
mang mã công khai ở §4 có bản trong `apierr.constraintCodes`. Các dòng menu và dòng đơn đã được xét
ở `P3-06`, xem [`03-ham-gia.md`](03-ham-gia.md); không xét lại ở đây.

| Tên `internal` | Vì sao lời từ chối chỉ là lỗi hệ thống trong cửa tại bàn |
|---|---|
| `bill_amounts_not_negative_check` | Yêu cầu đã kiểm tiền nguyên không âm; số phải trả cộng từ dòng đơn và phần trả trước giữ mặc định 0. |
| `bill_debtor_name_not_blank_check` | Tên có mặt mà trắng đã bị chặn bằng invalid_request trước quyền. |
| `bill_id_debt_key` | Mã hoá đơn do database sinh; không nhận cặp mã và nợ từ người gọi. |
| `bill_id_order_prepaid_key` | Mã tự sinh, cửa không ghi đơn lẻ hay phần trả trước. |
| `bill_one_per_order_key` | Cửa không ghi sales_order_id vào hoá đơn tại bàn. |
| `bill_one_per_session_key` | Khoá phiên trước khi kiểm chuyển; lần đóng sau bị từ chối ở trạng thái closed. |
| `bill_one_unit_check` | Cửa chỉ ghi table_session_id đã khoá, không nhận đơn vị tính tiền thứ hai. |
| `bill_paper_columns_check` | Cửa không ghi các cột sổ giấy. |
| `bill_paper_ledger_fkey` | Cửa không ghi các cột sổ giấy. |
| `bill_paper_position_in_range_check` | Cửa không ghi vị trí hay số lượt của sổ giấy. |
| `bill_paper_position_key` | Cửa không ghi sổ giấy hoặc vị trí trong sổ. |
| `bill_person_fkey` | Người thao tác đã được authz kiểm tồn tại; person_id lấy mặc định database. |
| `bill_pkey` | Mã do database sinh, không nhận từ yêu cầu. |
| `bill_prepaid_only_standalone_check` | Cửa tại bàn giữ hai phần trả trước ở mặc định 0. |
| `bill_prepayment_use_fkey` | Cửa không ghi phần trả trước nên không sinh đích phải có dòng dùng trả trước. |
| `bill_sales_order_fkey` | Cửa tại bàn không ghi sales_order_id của hoá đơn. |
| `bill_table_session_fkey` | Phiên đã khoá, hoá đơn và chuyển closed nằm trong cùng giao dịch. |
| `dining_table_label_key` | Lát chỉ đọc bàn; không thêm bàn hay sửa nhãn. |
| `dining_table_label_not_blank_check` | Lát không ghi nhãn bàn. |
| `dining_table_pkey` | Lát không thêm bàn hoặc sửa mã bàn. |
| `sales_order_bill_fkey` | Đơn tại bàn có phiên, không sinh nghĩa vụ hoá đơn riêng của đơn lẻ. |
| `sales_order_channel_code_check` | Kênh do đường vào quyết, cửa chỉ ghi staff_pos hoặc qr_table. |
| `sales_order_id_if_approved_key` | Cột tự tính từ mã tự sinh và trạng thái; cửa không ghi trực tiếp. |
| `sales_order_id_if_cancelled_key` | Cột tự tính từ mã tự sinh và trạng thái; cửa không ghi trực tiếp. |
| `sales_order_id_if_standalone_key` | Cửa tại bàn không tạo đơn lẻ và không ghi cột tự tính. |
| `sales_order_pkey` | Mã đơn do database sinh, không nhận từ yêu cầu. |
| `sales_order_qr_code_iff_qr_channel_check` | Cửa chỉ gắn qr_code_id khi đường vào là QR; đặt hộ không gắn mã. |
| `sales_order_qr_code_table_fkey` | Bàn và mã QR lấy cùng dòng từ CurrentTable, không lấy bàn khách gửi. |
| `sales_order_session_iff_table_channel_check` | Hai kênh tại bàn luôn được gắn cả bàn lẫn phiên do cửa tìm hoặc mở. |
| `sales_order_session_table_fkey` | Cửa khoá phiên của bàn hoặc thêm dòng thành viên trước khi thêm đơn. |
| `sales_order_status_check` | Trạng thái đầu từ TrangThaiDauDon; các lần sửa chỉ qua bảng vongdoi. |
| `sales_order_submission_code_key` | Tranh chấp chạy lại toàn bộ giao dịch; lần sau so dấu và nội dung, không đưa tên từ chối ra ngoài. |
| `sales_order_submission_code_not_blank_check` | UUID chữ thường được kiểm trước quyền; không cho dấu thiếu hay trắng. |
| `table_session_bill_fkey` | Chỉ đóng qua giao dịch thêm hoá đơn trước, sửa phiên và dòng bàn sau. |
| `table_session_id_closed_key` | Mã tự sinh, is_closed tự tính; cửa không ghi cặp này trực tiếp. |
| `table_session_id_if_closed_key` | Mã tự sinh và cột tự tính, không có đầu vào ghi tay. |
| `table_session_member_cleaned_after_close_check` | Cửa dọn chỉ khoá và sửa dòng session_closed đã đúng. |
| `table_session_member_dining_table_fkey` | Đặt hộ đã đọc bàn tồn tại; khách lấy bàn từ mã hiện hành. |
| `table_session_member_one_unpaid_session_key` | Tranh chấp mở phiên chạy lại cả giao dịch để đi vào phiên vừa có. |
| `table_session_member_pkey` | Mã dòng do database sinh, không nhận từ yêu cầu. |
| `table_session_member_session_fkey` | Mở thêm dòng vào phiên mới; đóng sửa status rồi mọi session_closed trong cùng giao dịch. |
| `table_session_member_table_once_key` | Tạo phiên chỉ thêm một dòng bàn cho mã phiên vừa sinh; chưa có cửa ghép bàn. |
| `table_session_pkey` | Mã phiên do database sinh, người gọi không chọn phiên khi tạo lượt gọi. |
| `table_session_status_check` | Mở ghi open; mọi lần sửa status đi qua bảng vongdoi. |

`sales_order_takeaway_handover_check`, `sales_order_takeaway_needed_at_check`,
`sales_order_takeaway_phone_check`, `sales_order_door_delivery_address_check` và
`sales_order_handover_code_check` đã được `P3-08` xét là `internal`, xem
[luồng mang đi](05-luong-mang-di.md) §5; cửa tại bàn không ghi các cột ấy.
Các phần trả trước và sổ giấy của hoá đơn để mặc định, vì vậy những tên tương ứng được xét `internal`
trong phạm vi cửa này; lát ngoài bàn hoặc nhập sổ giấy phải xét lại khi mở đường ghi tới chúng.

## 6. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **Ghép bàn** | đọc và đóng phiên đã ghép đúng; chưa có cửa ghép, test dựng nhóm bằng kết nối chủ lược đồ | lát ghép bàn sau, theo ADR-087 |
| **Nổ việc trạm sau duyệt** | duyệt chỉ chuyển đơn confirmed và phiên serving; chưa thêm việc trạm | `P3-10` |
| **Huỷ từ đơn đã xác nhận trở đi** | bảng vongdoi có cặp của owner; cửa tu_choi chỉ dùng cho pending_confirmation | `P3-09` / `P3-10` |
| **Vết của khách QR** | không có người thao tác nên không khai lý do; gọi thêm khi chờ thanh toán chuyển phiên mà chưa để lại vết | **F-060** (`work/findings.md`) — `P3-11` gỡ, cùng lượt bật vết nghiêm |
| **Gửi lại sau khi rời quầy hoặc mã bị thay** | kiểm quyền trước dấu; trả not_on_counter_duty hoặc qr_code_not_current, không trả lại đơn | giới hạn đã chốt ADR-087 |
| **Cách xác thực danh tính** | chỉ có giao diện Authenticator và bản test | chủ quán chốt 2026-10-09 **chọn tên** (đóng **U-075**, [unknowns](../99-unknowns.md)); bản thật dựng ở `T-143` |

## 7. Bằng chứng cần chạy

| Test hoặc lệnh | Chứng minh |
|---|---|
| `be/internal/vongdoi/vongdoi_test.go` | tập cặp bằng owner lúc chạy; kênh quyết trạng thái đầu |
| `be/internal/don/don_test.go` | ca giá, ảnh chụp, quyền và lỗi tính giá qua cửa tạo lượt gọi |
| `be/internal/don/tai_ban_test.go` | mở phiên, chen nhau, gửi lại, ghép bàn, đem về, quyền, vết, đóng nguyên tử và dọn từng bàn |
| `./scripts/check-write-paths.sh --list` | mỗi ô đúng cửa, kể cả ba cửa không ô ghi |
| `./scripts/check-api-contract.sh --list` | đường gọi, mã lỗi và ma trận khớp code |

Kết quả chạy thật — hai lần `be-check`, hai lỗi cài làm test đỏ rồi gỡ — ghi ở khối *Bàn giao* của
`P3-07` trong sổ task của pha 3, không chép về đây.

[↑ đầu file](#top)
