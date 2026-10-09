<a id="top"></a>
# Sản xuất theo mẻ — quầy ghi tiến độ, ba trạm bếp chỉ đọc

Pha 3 · bước `P3-10` · viết 2026-10-09 (Claude thiết kế, Codex thi công theo phiếu).
Thiết kế: **ADR-090** ở [`../../decisions.md`](../../decisions.md). Không coi tài liệu thi công là
lời chốt mới của chủ quán.

**File này sở hữu:** cách các cửa backend thực hiện nổ đơn, mẻ, phục vụ, chuyển phần đã làm,
ghi chú bánh làm sai, huỷ đơn và phép gom nhu cầu; cách xét tên từ chối của lát.

**File này KHÔNG sở hữu:** nghiệp vụ ở
[`../../../master_plan/shop-facts.md`](../../../master_plan/shop-facts.md) §5.4; vòng đời ở
[`../0-ba/ban-hang/05-vong-doi.md`](../0-ba/ban-hang/05-vong-doi.md) §5.2 · §5.4 · §5.5;
lược đồ ở migration (ý định tại [lát sản xuất pha 2](../2-db/05-luoc-do-san-xuat.md));
đường gọi, chữ ký và mã lỗi ở [`openapi.yaml`](openapi.yaml); quyền ở
[`02-vai-va-quyen.md`](02-vai-va-quyen.md). Không dựng nút hay cách gom mẻ của màn quầy.

## 0. Cách đọc lát

Đọc bảng cửa để biết ô nào có một người ghi, rồi đọc giao dịch và phép gom. Mỗi `station_job`
là một đơn vị, không có ô tổng lưu riêng. **POS là nơi duy nhất ghi tiến độ sản xuất và phục vụ**;
hai đường đọc không có cửa ghi hay kiểm quyền, cùng hình `GET /dining-tables`.

Nguồn của lựa chọn triển khai là phiếu ADR-090 ngày 2026-10-09. Chỗ nào là suy luận của phiên,
hoặc cần Claude/chủ quán quyết tiếp, được giữ tên ở §6. Hợp đồng 0.7.0 là bản trên dây.

## 1. Cửa, ô ghi và lớp quyền

| Cửa | Ô ghi sở hữu | Lớp |
|---|---|---|
| `sanxuat/no_don` | thêm `station_job` | `theo_cua_goi` |
| `sanxuat/bam_me` | thêm `production_batch`, `production_batch_item` | `quay` |
| `sanxuat/lui_me` | sửa `production_batch.rolled_back_at`, `rolled_back_by_person_id`; `production_batch_item.batch_rolled_back` | `quay` |
| `sanxuat/ra_ban` | không ô riêng; gọi chuyển việc và chuyển đơn | `quay` |
| `sanxuat/chuyen` | thêm `station_job_transfer`; sửa `production_batch_item.station_job_id` | `quay` |
| `sanxuat/ghi_lam_sai` | thêm `wrong_make_note` | `quay` |
| `sanxuat/huy_ghi_lam_sai` | sửa `wrong_make_note.cancelled_at`, `cancelled_by_person_id` | `quay` |
| `don/huy` | không ô riêng; gọi chuyển đơn | `quay` |
| `vongdoi/chuyen_viec` | sửa `station_job.status` | `theo_cua_goi` |

`sanxuat.Routes` đăng ký các đường sản xuất; huỷ đơn đăng ký trong `don.Routes`.
Các cửa nội bộ nhận giao dịch của cửa gọi, không có đường HTTP. Người ghi lấy từ giao dịch
đã qua `authz.Run`; mọi sửa có lý do qua `vongdoi.CoVet`. Không tạo lớp quyền cho trạm bếp.

## 2. Nổ đơn và vòng đời việc

Sau khi ghi đủ ảnh chụp dòng đơn, kênh `staff_pos` và `phone_preorder` gọi `NoDon` nếu trạng thái
đầu là `confirmed`. Duyệt đơn chờ xác nhận cũng gọi nó trong cùng giao dịch. Hàm chuyển đơn sang
`in_progress` rồi ghi mọi (dòng, thành phần đã chụp, trạm của thành phần) với vị trí 1 đến tích
số suất và số thành phần; sau cùng ghi đúng một nước chấm cấp đơn tại `canh` (ADR-056).
Bất kỳ lỗi nào lùi cả đơn, phiên và các việc. Trả trạng thái sau nổ; tra dấu gửi lại trước nhánh
tạo nên không nổ lần hai. Giữ bước phiên Mở → Đang phục vụ của P3-07.

`CapViec` giữ đúng bốn cặp: chưa có → `pending`, `pending` → `made`, `made` → `served`,
`made` → `pending`. Cặp ngoài bảng trả `station_job_transition_not_allowed`.
`NhaNguonChuyen` là ngoại lệ trong cùng cửa chuyển việc: chỉ nguồn `made` của đơn huỷ, có lần
chuyển đã ghi và vật đã đổi đúng chủ, được nhả về `pending`. Cái đã `served` không đổi chủ — nó đã
ra tới bàn khách (ADR-090 điểm 3; sửa lúc duyệt 2026-10-09, bản thi công nhận cả `served`). Vết sửa mang người quầy và lý do chuyển trạng thái.

## 3. Giao dịch của quầy

Mọi cửa đụng việc khoá phiên theo id, rồi đơn theo id, rồi tập việc `FOR UPDATE` theo id trước
khi kiểm. Chủ của việc không đổi; lần chuyển chỉ đổi chủ của vật đã làm. Cửa lùi và chuyển khoá
mẻ theo id **trước** chuỗi ấy; đọc lại chủ hiện tại sau khi khoá để lùi đúng đích nếu đã chuyển.
Huỷ đơn khoá phiên trước đơn theo cùng thứ tự. Các danh sách được xử lý nguyên tử.

- **Bấm mẻ:** tập không rỗng, không trùng, toàn số nguyên dương. Thiếu mã trả 404; một việc
  không `pending` hoặc của đơn huỷ từ chối cả tập. Thêm mẻ, thêm mỗi vật với mã làm cho và mã
  đang giữ bằng nhau, rồi gọi chuyển việc sang `made`. Cạnh tranh cùng việc được kiểm lại sau khoá.
- **Lùi mẻ:** khoá mẻ, từ chối không có hoặc đã lùi; kiểm chủ hiện tại của mọi vật. Có `served`
  thì chặn; có ghi chú còn hiệu lực thì chặn. Ghi người/mốc lùi, đổi mọi bản soi rồi gọi chuyển
  việc về `pending`, cùng giao dịch. Không chỉ đọc `made_for_station_job_id` vì chủ có thể đã đổi.
  Việc của đơn **đã huỷ** cũng về `pending` qua `vongdoi.LuiViecCuaMe` (chỉ cặp `made` → `pending`):
  mẻ lùi là mẻ không có thật, giữ việc ở `made` để lại một thứ không ai làm mà cửa chuyển sẽ đem
  cho bàn khác (ADR-090, sửa đổi 2026-10-09).
- **Đã ra bàn** (lời **S-5**, chủ quán 2026-10-09 — `shop-facts.md` §5.4): POS nhập **số cái từng
  thứ cho một bàn** rồi bấm. Thân nhận đúng một trong `dining_table_id` · `sales_order_id` (đơn không
  bàn; đơn có bàn thì bấm theo bàn) và `items` — mỗi item một hàng của bảng nhu cầu (`station_code`,
  `menu_component_id` null với nước chấm, `filling_option_ids`, `quantity` ≥ 1), không hàng nào hai lần.
  Cửa khoá phiên rồi các đơn `in_progress` của phần ấy, chọn đủ `quantity` cái `made` đúng khoá — khoá
  đọc từ `viecGom`, cùng định nghĩa với §4 — **lượt gọi sớm hơn trước** (đơn rồi mã việc; suy ra của
  phiên, ADR-090 điểm 4 *Sửa đổi*). Thiếu cái đã làm cho một item ⇒ `served_quantity_exceeds_made` cho
  cả lần. Chuyển sang `served` qua chuyển việc, rồi đơn gắn phiên mà mọi việc đã served thì hoàn thành
  trong cùng giao dịch; đơn lẻ không tự hoàn thành. Trả `station_job_ids` đã chọn và `completed_order_ids`.
- **Chuyển:** nguồn thuộc đơn huỷ, `made`, có vật còn hiệu lực, không ghi chú còn sống;
  đích khác nguồn, `pending`, đơn `in_progress`. Mỗi cặp ghi lần chuyển → đổi chủ vật → nguồn
  về `pending` → đích sang `made`. Không so khoá gom hai bên; quầy chịu lựa chọn (I-004 tầng 4).
  Danh sách sai ở cặp sau lùi cả các cặp trước.
- **Ghi chú bánh làm sai:** chỉ việc `made`/`served` của đơn huỷ; không ghi chú sống thứ hai.
  Chữ tuỳ chọn, có thì phải còn chữ sau khi bỏ khoảng trắng; không cắt hay chuẩn hoá khi lưu.
  Huỷ ghi chú khoá dòng, chỉ ghi hai cột người/mốc huỷ, có vết, không xoá dòng (ADR-077).
- **Huỷ đơn:** chỉ `confirmed`/`in_progress` đi qua cửa này. `completed` trả
  `completed_order_cancel_not_ready`; các trạng thái khác trả `order_transition_not_allowed`.
  Chờ xác nhận vẫn đi cửa từ chối. Không sửa hay xoá việc khi huỷ đơn.

## 4. Một hàm gom cho bảng và ứng viên

`docGom` ở `sanxuat` dùng một câu SQL với một nguồn khoá: trạm + mã gốc thành phần đã chụp
(null cho nước chấm) + tập mã lựa chọn đã chụp, sắp tăng, **chỉ khi** thành phần nhận nhân.
Tên hiển thị không tham gia khoá; nếu nhiều ảnh chụp cùng mã khác tên, lấy tên nhỏ nhất theo
thứ tự so của database để kết quả ổn định. Không đọc lại tên hay lựa chọn từ menu hiện tại.

Bảng lọc đơn huỷ; giữ đơn `in_progress` hoặc thuộc phiên chưa đóng. Câu đọc lọc phần còn sống
ngay ở bước đầu (cộng việc nguồn khi hỏi ứng viên), nên không quét cả lịch sử mỗi lần đọc. Mỗi phần là một bàn theo
`dining_table_id` của đơn (không đổi theo ghép bàn), hoặc một đơn lẻ. SQL đếm năm số từ cùng
các đơn vị, rồi cộng các phần thành hàng trong **cùng câu đọc**, không có khoảng đọc tổng khác
đọc phần. `missing` bằng `ordered − served`; đã làm chưa ra bàn vẫn còn thiếu. Mảng nhân và
mảng hàng luôn là mảng, kể cả rỗng; lọc trạm không thay cách đếm.

Đường ứng viên dùng cùng nguồn khoá và cùng ảnh đọc: nguồn lạ 404, nguồn không hợp lệ (kể cả
có ghi chú sống) 409 `transfer_source_not_available`. Đích là việc đang chờ thuộc đơn
`in_progress`, cùng khoá nguồn; đơn lẻ trả bàn null. Kết quả đọc là gợi ý tại thời điểm đọc;
cửa ghi chuyển vẫn khoá và kiểm lại trạng thái, không bắt buộc chọn trong gợi ý.

## 5. Nhận việc — xét tên từ chối

Bảng `x-constraint-errors` xét toàn bộ `station_job_*`, `production_batch*`,
`station_job_transfer_*`, `wrong_make_note_*`. Những tên cùng lý do được nhóm dưới đây;
không để `unreviewed` cho các bảng cửa mới ghi.

| Nhóm tên | Kết quả | Lý do |
|---|---|---|
| `wrong_make_note_live_station_job_fkey`, `wrong_make_note_live_key` | `station_job_has_wrong_make_note` | Chốt của ghi chú còn hiệu lực; cả khi lời từ chối lọt qua kiểm trước vẫn có mã công khai. |
| `wrong_make_note_cancelled_order_fkey` | `wrong_make_note_not_allowed` | Ghi chú chỉ đứng tên đơn huỷ. |
| Mọi khoá chính của năm bảng | `internal` | Mã do database sinh, không nhận từ client. |
| `station_job_component_columns_check`, `station_job_position_in_range_check`, `station_job_position_key`, `station_job_one_sauce_per_order_key` | `internal` | Hình nổ do cửa tạo từ ảnh chụp, vị trí chạy theo tích và nước chấm ghi một lần; gửi lại không nổ thêm. |
| `station_job_order_line_component_fkey`, `station_job_order_line_fkey`, `station_job_sales_order_fkey` | `internal` | Mã và số lượng do cửa đọc từ đơn đã chuyển trạng thái trong cùng giao dịch. |
| `station_job_station_code_check`, `station_job_status_check`, `station_job_id_if_made_or_served_key`, `station_job_id_order_key` | `internal` | Trạm từ dữ liệu menu, trạng thái qua bảng chuyển, hai khoá trên mã tự sinh/tự tính. |
| `station_job_made_in_batch_fkey`, `production_batch_item_live_station_job_fkey`, `production_batch_item_batch_fkey`, `production_batch_item_transfer_fkey` | `internal` | Cửa ghi đủ các vế nguyên tử; thiếu vế là lỗi thi công. |
| `production_batch_id_rolled_back_key`, `production_batch_item_once_key`, `production_batch_item_live_key` | `internal` | Một mẻ mới và tập không trùng; khoá việc rồi kiểm lại, không ghi đè vật còn hiệu lực. |
| `production_batch_item_made_for_station_job_fkey`, `production_batch_item_station_job_fkey` | `internal` | Các mã được khoá và kiểm tồn tại; không xoá cứng việc. |
| `production_batch_made_by_person_fkey`, `production_batch_rolled_back_by_person_fkey`, `production_batch_rolled_back_by_iff_rolled_back_check`, `production_batch_rolled_back_after_made_check` | `internal` | Người lấy từ quyền, mốc do database cấp, mốc lùi và người lùi ghi cùng câu. |
| `station_job_transfer_changes_owner_check`, `station_job_transfer_item_to_key` | `internal` | Đích khác nguồn, đang chờ; nguồn đã huỷ không được làm lại qua cửa bấm mẻ. |
| `station_job_transfer_from_station_job_fkey`, `station_job_transfer_to_station_job_fkey`, `station_job_transfer_production_batch_item_fkey`, `station_job_transfer_person_fkey` | `internal` | Hai việc và vật được kiểm/khoá, người từ giao dịch. |
| `wrong_make_note_note_not_blank_check`, `wrong_make_note_station_job_order_fkey`, `wrong_make_note_person_fkey` | `internal` | HTTP kiểm chữ trước quyền, mã đơn đọc từ việc đã khoá, người đã kiểm. |
| `wrong_make_note_cancelled_by_person_fkey`, `wrong_make_note_cancelled_by_iff_cancelled_check`, `wrong_make_note_cancelled_after_created_check` | `internal` | Huỷ tại chỗ ghi người và mốc database cùng câu, chỉ khi chưa huỷ. |

Mã của các lần kiểm trước, status và schema thuộc hợp đồng; bảng code `constraintCodes` chỉ
chép ba ánh xạ công khai mới. Các bảng chỉ đọc như `menu_component_station` giữ ánh xạ trước đó.

## 6. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| ~~**S-5 — bấm đã ra bàn theo đơn vị nào**~~ | **Có lời 2026-10-09:** số cái từng thứ cho một bàn (§3). Còn suy ra của phiên: lượt gọi sớm hơn trước, đơn không bàn bấm theo mã đơn — ADR-090 điểm 4 *Sửa đổi*. | Chủ quán, `shop-facts.md` §5.4. |
| **S-6 — lúc quầy bấm đã ra bàn cho đơn giao** | Giữ ADR-088: rời quán khi còn việc chưa served bị từ chối bằng `delivery_served_mark_undecided`; không tự phục vụ ở cửa rời quán. | Chủ quán, `shop-facts.md` §7.2. |
| **U-077 — đơn đặt trước nổ lúc nhận** | Hotline nổ khi tạo đã xác nhận, không dựng bộ hẹn giờ — làm đúng chữ đang có, câu hỏi ở [`../99-unknowns.md`](../99-unknowns.md). | Chủ quán quyết thời điểm. |
| **F-044 — đối chiếu việc chưa làm của đơn huỷ** | Hiểu vế rút nhu cầu là lọc đơn huỷ khỏi bảng đọc; dữ liệu việc vẫn ở lại. | Pha 1 sửa phép đối chiếu, `work/findings.md`. |
| **Hoàn thành → Huỷ** | Có cặp vòng đời nhưng cửa huỷ trả mã chưa dựng đường hoàn tiền. | Lát đường tiền; không tự bỏ giới hạn. |
| **Ai huỷ ghi chú** | Quầy theo suy luận của phiên, ADR-090 điểm 6; không diễn đạt thành lời chủ quán. | Claude/chủ quán. |
| **Đích chuyển gồm đơn lẻ** | Cho phép theo suy luận của phiên, ADR-090 điểm 7; bàn của ứng viên đơn lẻ null. | Claude/chủ quán. |
| **Lùi mẻ còn giữ việc của đơn huỷ** | Lùi trả cả việc của đơn huỷ về `pending` (§3) — suy ra của phiên từ nghĩa của lùi mẻ, không phải lời chủ quán (ADR-090, sửa đổi 2026-10-09). | Claude/chủ quán. |

## 7. Bằng chứng cần chạy

| Test hoặc lệnh | Chứng minh |
|---|---|
| `be/internal/don/san_xuat_test.go` qua `./scripts/be-check.sh` | Nổ đủ/cắt giữa/gửi lại; mẻ nhiều bàn; cạnh tranh năm lần; lùi; tập ra bàn; một hàm gom; chuyển khác khoá; ghi chú và quyền quầy. |
| `be/internal/don/don_test.go`, `tai_ban_test.go`, `mang_di_test.go` | Hồi quy giá, tại bàn, ngoài bàn sau khi nối nổ đơn. |
| `go test ./internal/vongdoi/ -run 'TestI016_BangChuyen'` trong `be/` | Ba bảng chuyển đúng tập cặp; không cần database. |
| `go build ./...`, `go vet ./...` trong `be/`; `gofmt -l be/` | Biên dịch, phân tích tĩnh, định dạng. |
| `be/internal/don/san_xuat_lui_huy_test.go` | Lùi mẻ trả cả việc của đơn huỷ; việc vừa lùi không còn là nguồn chuyển; ghi chú làm sai vẫn chặn lùi. |
| `./scripts/check-write-paths.sh --list` | Liệt kê ô ghi, kiểm một cửa mỗi ô; đọc `GRANT UPDATE (cột)` sau `REVOKE` như PostgreSQL. |
| `./scripts/check-api-contract.sh` | Hợp đồng 0.7.0, đường gọi, mã, ma trận, khai báo cửa khớp. |
| `./scripts/gate.sh` | Bộ kiểm chung, gồm dựng PostgreSQL thật. |

Danh sách trên là phép kiểm cần chạy, không phải lời khẳng định xanh. Output thật và năm hash
không đổi thuộc báo cáo thi công. Claude giữ phần tích hợp, cập nhật task và khối commit.

[↑ đầu file](#top)
