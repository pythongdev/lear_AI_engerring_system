<a id="top"></a>
# Realtime và dự phòng — tín hiệu đọc lại, cùng một nguồn dữ liệu

Pha 3 · bước `P3-12` · viết 2026-10-12 (Claude thiết kế, Codex thi công; chờ Claude duyệt).
Thiết kế: ADR-097 trong phiếu giao việc; bản ADR ở cây chính do Claude giữ.
**Sửa điểm 5 ngày 2026-10-12, Claude trả lời trong phiên:** mốc bắt đầu khoảng mù mới lấy mốc
muộn hơn giữa lần luồng quầy cuối đóng/khởi động và lần khoảng mù gần nhất khép, chặn trên bởi `now()`.

**File này sở hữu:** cách backend nối SSE, tín hiệu sau COMMIT, đường kéo và các cửa ngừng nhận đơn;
ánh xạ từ chối của lát; bảng cắt thử phụ thuộc.

**File này KHÔNG sở hữu:** luật nghiệp vụ ở `master_plan/shop-facts.md` §6; yêu cầu tại
[realtime pha 1](../1-system-design/05-realtime-va-du-phong.md) và
[ranh giới hệ thống](../1-system-design/01-ranh-gioi-he-thong.md) §2–§3; lược đồ và tên ràng buộc ở migration;
hình trả về và mã ở [openapi.yaml](openapi.yaml); lớp quyền ở [02-vai-va-quyen.md](02-vai-va-quyen.md).
Không thiết kế màn hay viết câu thông báo cho khách.

## 1. Cách đọc lát và bảng cửa

| Cửa | Ô ghi sở hữu hoặc cửa gọi tiếp | Lớp |
|---|---|---|
| `nhandon/tam_dung` | thêm `order_intake_pause` | `chu_quan` |
| `nhandon/tiep_tuc` | sửa `order_intake_pause.ended_at`, `ended_by_person_id` | `chu_quan` |
| `nhandon/bao_mu` | kiểm quyền, gọi `nhandon/ghi_mu` | `quay_hoac_chu_quan` |
| `nhandon/mo_lai` | sửa `shop_blind_spell.ended_at`, `ended_by_person_id` | `quay_hoac_chu_quan` |
| `nhandon/ghi_mu` | thêm `shop_blind_spell`, cho cả máy và người | `theo_cua_goi` |

Bốn đường POST không nhận thân. Mốc ghi do database cấp; người lấy từ giao dịch đã kiểm quyền.
Hai cửa khép khoảng khai lý do mang mã cửa qua `vongdoi.CoVet`, giữ vết, không xoá dòng.
Khoá giao dịch chung tuần tự hoá các lần bật/khép; ràng buộc loại trừ vẫn là chốt cuối.
Không có migration mới.

## 2. Giao dịch và điều kiện nhận đơn

Cửa tạo lượt gọi giữ thứ tự của ADR-088: hình → quyền → dấu gửi lại → tạm dừng → giờ bán → quán mù.
Tạm dừng chặn cả năm kênh; quán mù chỉ chặn `qr_table`, `delivery`, `pickup`.
Dấu gửi lại đúng vẫn trả đơn đã có, không ghi khoảng mù vì không tạo đơn mới.

`cmd/server` tiêm cùng một bộ phát vào miền đơn, quầy, sản xuất và middleware.
Bộ phát giữ số luồng quầy đã qua lớp `quay`; luồng trạm, yêu cầu `HEAD`, người sai lớp đều không tăng số này.
Kiểm lớp tại lúc nối theo `authz.Read`, dùng cùng cách kiểm của cửa ghi; giao dịch đọc không phát tín hiệu.
Lúc số luồng quầy về không, bộ phát giữ mốc đóng cuối; lúc khởi động, số luồng bằng không và mốc là lúc khởi động.
Không có cửa sổ cho phép nhận đơn sau khi số luồng đã về không.

Khi tới điều kiện quán mù mà không có luồng, giao dịch tạo đơn lùi trước. Cửa chạy một giao dịch riêng,
kiểm lại caller qua `authz.RunAs`, rồi gọi `nhandon/ghi_mu` với người khai rỗng. Đã có khoảng mở thì không
chèn thêm. Chưa có thì `started_at = least(now(), greatest(mốc mất luồng, max(ended_at)))`.
COMMIT xong mới trả `shop_not_seeing_orders`. Vì thế lỗi HTTP này có thể đi cùng một tín hiệu `changed`
**của giao dịch ghi khoảng đã thành công**, không phải tín hiệu của giao dịch đơn đã lùi.
Tranh chấp với một lần mở lại có mốc giao dịch muộn hơn được thử lại tối đa bốn giao dịch khi gặp tên loại trừ.

Người được mở lại ngay cả khi chưa có luồng. Đơn tự bấm tiếp theo sẽ mở khoảng mới bắt đầu từ mốc
mở lại đó nếu nó muộn hơn lần mất luồng; hai khoảng tiếp giáp `[)` không chồng nhau.
Có luồng trở lại chỉ làm quầy nhìn thấy trạng thái: khoảng đã mở vẫn chặn tới khi người bấm mở lại.
Không có đơn bị từ chối trong lần mất luồng thì không tạo khoảng bắt buộc người khép.

## 3. Hai luồng, hai đường đọc

`GET /production-board/events` công khai như bảng trạm; `GET /counter/events` qua lớp `quay`.
Luồng gửi `hello` ngay khi nối, `changed` khi cửa ghi commit, `heartbeat` mỗi 10 giây.
Payload chỉ là `read_at` của database, không có số lượng hay dữ liệu nghiệp vụ. Luồng quầy vừa nối
mà có khoảng mù mở gửi thêm `changed`; màn đọc lại sẽ thấy `blind_since`.
Client đọc lại khi nhận `hello` hoặc `changed`, kể cả sau khi nối lại. Không replay lịch sử sự kiện.

`authz.RunAs` đánh dấu giao dịch ghi. `postgres.InTx` là **chỗ duy nhất** gọi bộ phát sau COMMIT;
COMMIT lỗi hay thân cửa từ chối thì không phát. Middleware nối bộ phát vào context của mọi đường HTTP,
không có danh sách riêng cửa nào cần báo màn nào. Cửa nội bộ dùng giao dịch cửa gọi.
Bộ phát gộp tín hiệu đang chờ của mỗi màn vào tối đa một dấu đọc lại; màn chậm không chặn cửa ghi.
Đây không phải hàng đợi công việc hay bản sao dữ liệu: mất dấu thì đường kéo bù.

`GET /production-board` giữ phép gom cũ và thêm `read_at`, `poll_interval_seconds`.
`GET /counter/queue` qua lớp `quay`, đọc đơn `pending_confirmation` theo thời điểm tạo rồi mã đơn;
trả `orders`, `paused_since`, `blind_since` và cùng hai trường mốc/chu kỳ.
Mốc và dữ liệu ở mỗi đường đọc trong cùng câu SQL, đọc thẳng chỗ ghi.
Chu kỳ do hằng `realtime.PollIntervalSeconds = 20` cấp cho cả hai; hợp đồng công bố cùng giá trị.
Màn cần tự kéo mỗi chu kỳ ngay cả khi không có SSE (pha 4).

Hạn I/O giao dịch là 5 giây, áp cả lúc lấy kết nối, câu SQL và COMMIT. Luồng có hạn ghi 10 giây,
kiểm mốc database ở mỗi heartbeat và đóng khi đọc/ghi lỗi hoặc client huỷ. Hạn I/O không phải khoảng
chờ được nhận đơn của I-008. Phát hiện lỗi mạng vật lý vẫn phụ thuộc việc HTTP/TCP báo lỗi; trạng thái
còn nhìn thấy trong ADR-097 được định nghĩa bằng luồng HTTP còn mở, không phải một máy đo mạng độc lập.

## 4. Nhận việc — xét tên từ chối

| Tên hoặc nhóm | Ánh xạ | Lý do |
|---|---|---|
| `order_intake_pause_one_at_a_time_excl` | `order_intake_already_paused` | Khoảng mới chồng khoảng đã có, kể cả hai người bấm cùng lúc. |
| `shop_blind_spell_one_at_a_time_excl` | `shop_already_blind` | Không chèn khoảng mù chồng nhau. Máy xử lý tranh chấp có giới hạn ở §2. |
| `order_intake_pause_ended_after_started_check`, `shop_blind_spell_ended_after_started_check` | `intake_state_changed` | Giao dịch khép bắt đầu quá sớm so với khoảng vừa được tạo; không sửa mốc bắt đầu để né chốt. |
| Khoá chính của hai bảng | `internal` | Mã database sinh. |
| Các khoá ngoại người của hai bảng | `internal` | Người do lớp quyền kiểm, không nhận mã từ thân yêu cầu. |
| Hai ràng buộc `*_ended_by_iff_ended_check` | `internal` | Mốc và người khép ghi cùng một câu. |

Cửa khép khi không có khoảng trả `order_intake_not_paused` hoặc `shop_not_blind`.
Nút báo mù khi đã có khoảng mở trả `shop_already_blind`. Các mã mới có HTTP 409;
quyền giữ `unauthenticated`, `owner_only`, `not_on_counter_duty` của hợp đồng.

## 5. Cắt thử từng phụ thuộc

Các test mới qua router thật nằm trong `be/cmd/server/realtime_test.go`; dùng `httptest.Server`,
không giả sự hiện diện của quầy. Khung cũ của miền đơn tiêm `AlwaysSeeing` để giữ các khẳng định cũ.
Bộ kiểm `scripts/be-check.sh` dựng database rỗng, chạy các package tuần tự; test realtime khép các
khoảng do mình mở qua cửa thật khi dọn khung, không xoá lịch sử. Test đơn cũ dùng khoảng tương lai,
vì vậy không dùng lại database đã chạy xong cả bộ để chạy riêng test realtime với thời gian hiện tại.

| Phụ thuộc | Mệnh đề và bằng chứng cần chạy | Kết quả trong sandbox |
|---|---|---|
| PT-1 — mất luồng quầy | `TestI008_KhongLuongQuayThiBaKenhTuBamBiTuChoi`, `TestI008_CoLuongQuayThiNhanDon`, `TestI008_NhieuLuongQuayVaTuChoiSaiLop` | PASS trong mọi `be-check` (sửa 2026-10-19, T-206). Ba kênh dừng; hai kênh người vẫn ghi; một trong nhiều luồng còn mở thì còn thấy. |
| PT-2 — database mất | `TestI008_PT2_DatabaseMatVaNoiLai` cắt TCP proxy tới database, kiểm lỗi có mã và giới hạn chờ, số dòng không đổi; nối lại rồi ghi/đọc đúng | PASS trong mọi `be-check` (sửa 2026-10-19, T-206). |
| PT-3 — ngân hàng không tự báo tiền | Rà route ở `be/cmd/server/router.go`, các `handler.go` và ma trận: không route webhook/ngân hàng tự ghi tiền. `TestI012_CuaTienCanNguoiCoTen` ở `be/internal/don/duong_tien_test.go`; cửa đóng phiên còn có kiểm quyền trong bộ `tai_ban_test.go` | Dẫn test có sẵn, giữ nguyên. Các cửa tiền có lớp `quay`, `nguoi_quan`, `quay_hoac_chu_quan` hoặc `chu_quan`; cửa nội bộ `theo_cua_goi` không có HTTP. |
| PT-4 — mất tin báo có | `TestI021_MotNgayBanGiaQuaCuaRa0dLech` và `TestI021_CaiMotLanThuSaiDoiSoatKeu` ở `be/internal/don/duong_tien_test.go`: chia hai phương thức, hoàn chéo, ký ngày không nhận nguồn ngân hàng | Dẫn test có sẵn; không thêm nguồn đối soát hoặc tự quyết tiền đã về. |
| PT-5 — mất báo sau khi đã nhận đơn | `TestI008_MatDayVanDocDuocDonDaNhan`: nhận QR khi luồng còn mở, đóng luồng, tạo việc qua kênh người; kéo vẫn thấy đơn cũ ở quầy và việc mới ở trạm | PASS trong mọi `be-check` (sửa 2026-10-19, T-206). Theo ADR-097, mất luồng **là** mù; không nhận thêm đơn khách tự bấm để kiểm ca này. |
| PT-6 — sổ giấy | `TestYC08_KhaiSoGiayQuaCua`, `TestI014_KyNgayConLuotGiayBiTuChoi`, `TestI014_KhaiSoChenLucKyNgay` ở `be/internal/don/so_giay_test.go` | P3-11 đã có trong cây; dẫn test giữ nguyên. |

Các ca khác: `TestI008_NutMoLaiKhepKhoangCoNguoi`, `TestI008_BaoMuCoNguoi`,
`TestI008_TamDungNhanDonCuaChuQuan`, `TestYC34_KhoangMuDocLaiDuoc`,
`TestI008_MoLaiKhiChuaCoLuongKhongChongKhoang`, `TestQC12_DayChiBaoSauCommit`,
`TestQC12_LuongCoHeartbeat`. Test bộ phát ở `be/internal/platform/realtime/realtime_test.go`
chạy không cần database, gồm kiểm tranh chấp với race detector.

## 6. Bằng chứng chạy và phần cần Claude kiểm tiếp

Output kiểm thật được bổ sung bên dưới. Biên dịch test không đồng nghĩa test PostgreSQL đã đạt.
Claude cần chạy `./scripts/be-check.sh`, `./scripts/db-check.sh`, `./scripts/gate.sh` trên môi trường
có Docker, rà diff và tích hợp ADR-097 cùng bản sửa điểm 5 ở cây chính. Không sửa trạng thái task,
không commit trong phiên thi công.

[↑ đầu file](#top)
