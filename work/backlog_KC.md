<a id="top"></a>
# Sổ mô tả — trang Khoản chi (`KC-01`…`KC-14`)

Trạng thái chỉ ở `work/backlog.md`, do Claude giữ; sổ này không giữ trạng thái. Mở **2026-11-22 bởi T-363**.
Lane **KC**. Mỗi entry là mô tả để giao bước, không phải lời cho phép làm ngay; **Nhận việc** để trống tới lúc nhận.

**Lời chủ repo 2026-11-22 (nguyên văn):** *"hãy yêu cầu codex làm backlog cho task trên và bạn kiểm tra từ db, be và fe"*.

## Cách đọc lời ấy (suy ra, chưa phải lời chủ quán)

1. “Task trên” là dựng trang thật `/chu-quan/khoan-chi` theo [bản HTML được giao][html], gồm các thay đổi
   T-247 và T-350…T-362 trong [backlog][lich-su]. Chuẩn là bản HTML sau T-362 (2026-11-22). Sổ này theo khuôn
   [backlog YT][yt].
2. “Dữ liệu thật” nghĩa là tên, mã, nguồn tiền, khoản chi và con số nguyên liệu lấy qua API của quán, không chép
   `types`, `entries`, `stockEstimates`, `usageHistory`, ngày tháng hay “Chị Thanh” từ mẫu. T-363 đối chiếu migration,
   hợp đồng và mã nguồn tại nền `1693c48`, **chưa truy vấn database đang chạy hoặc nghiệm thu trên trình duyệt**.
3. Dựng tiếp những phần đã có từ T-248. Không tạo lại ba bảng khoản chi, CRUD, tổng kỳ, chọn nhanh hoặc luật
   xoá. Các thay đổi chỉ về cách bày không kéo theo migration hay cửa API mới.
4. HTML là khuôn giao diện, không thay luật quán. Ví dụ mẫu gán *Điện, nước* là tiền riêng và *Mua nguyên liệu*
   là tiền két; [§8.10][facts] nói điện/nước từ két, còn loại mới phải khai rõ nguồn. Không tự sửa nguồn của dữ liệu
   cũ, không tự tạo ba mục mẫu hoặc chín nguyên liệu mẫu để làm trang trông giống hình.
5. T-350 cho thử nhập số còn/mức dùng, T-351 dùng lịch sử minh hoạ; các lời đó chưa chốt mô hình lưu của app thật.
   Không mặc nhiên đồng nhất `expense_item` với `supply_item`, không biến `paid_date` thành ngày nhập, không lấy
   lượng bán ra để suy lượng dùng. Những chỗ ấy chờ [câu hỏi mở](#cau-hoi-mo).
6. “Giống HTML” bao gồm bảng một hàng/ngày, các khoản cùng ngày nằm ngang, chi tiết mở ngay dưới dòng, hai lịch sử
   cạnh nhau trên màn rộng, lọc riêng và Hiện/Ẩn. Công cụ *Hiện tên component*, *Mục lục thiết kế* và chú thích số
   minh hoạ là công cụ xem mẫu; đề xuất không đưa chúng vào sản phẩm thật. Claude duyệt cách đọc này ở KC-01.

## Lời chủ repo 2026-11-22 — sáu câu hỏi đã có lời

Claude hỏi chủ repo ngay sau khi duyệt sổ; lời ở `master_plan/shop-facts.md` §8.10 *Lượt 2026-11-22*, sáu câu đóng ở
`docs/product/99-unknowns.md`. Lời ấy **thay mọi nhánh "có điều kiện" bên dưới** — chỗ nào trong bảng đối chiếu hay
entry còn nói "nếu", đọc theo bảng này:

| Câu | Lời | Hệ quả cho lane |
|---|---|---|
| Q-KC-01 · U-120 | Cùng một thứ; trang Khoản chi **thay cả Kho lẫn Nguyên liệu** | KC-02 giữ: nối khoản con nguyên liệu với `supply_item`; KC-11 gánh cả ghi lượng mua/dùng và tỉ lệ nhắc; thêm KC-14 gỡ hai trang cũ |
| Q-KC-02 · U-121 | Ngày nhập ghi riêng trên khoản chi, mặc định bằng ngày chi | KC-03 giữ: thêm ngày nhập vào khoản chi |
| Q-KC-03 · U-122 | Số còn = hiệu số máy tính (có thể âm) | Không lưu số đếm; đọc `balance` sẵn có |
| Q-KC-04 · U-123 | Máy tính ước tính; mức dùng = TB 7 ngày gần nhất có ghi dùng; chỉ để xem | **KC-04 bỏ** (không cần chỗ lưu); KC-07 tính ở backend; KC-12 chỉ hiện, không có ô gõ mức dùng |
| Q-KC-05 · U-124 | Xoá nguyên liệu đã dùng = ngừng dùng, giữ lịch sử | KC-02 thêm dấu ngừng dùng cho `supply_item`; KC-06 làm cửa ngừng dùng |
| Q-KC-06 · U-125 | Thêm nguyên liệu kèm tiền bằng một lần bấm | KC-06 thêm cửa gộp nguyên khối; KC-10 dùng nó |

Phần *cách đọc của phiên* ở §8.10 (đổi tên là đổi tên của một thứ; ngừng dùng chỉ cho nguyên liệu; ít hơn 7 ngày thì
trung bình trên số ngày có; không có ngày nào thì *chưa tính được*) **chưa ai xác nhận** — KC-01 hỏi lại trước khi chốt ADR.

**Chung cho mọi bước.** Đọc [CLAUDE.md][rules], chạy `./scripts/brief.sh`, đọc entry và owner liên quan trước khi
nhận. Mức dưới đây là đề xuất phân rã theo [README.md][readme] và CLAUDE.md §3, để Claude duyệt trước khi giao:
đụng tiền, dữ liệu lưu hoặc hợp đồng là ít nhất L2. Nếu thiết kế cần gộp/xoá dữ liệu cũ hoặc migration rủi ro,
Claude nâng phần ấy lên L3, duyệt thiết kế trước code và chia lại phiếu. Claude giữ lời quán, ADR, bất biến,
unknowns, scope và trạng thái; viết test hồi quy trước các bước L2. Codex thi công trong phiếu riêng, Claude đọc
diff thật và chạy lại kiểm tra. Không gộp DB · BE · FE trong một bước. Phạm vi từng entry là phạm vi dự kiến để
Claude lập phiếu, không phải scope của T-363; T-363 chỉ tạo sổ này.

## Bảng đối chiếu tính năng

Đối chiếu ngày **2026-11-22**. “Có” chỉ nói phần được chỉ rõ trong ô, không chứng minh dữ liệu quán đã được nhập.
“Một phần” phân biệt dữ liệu/cửa hiện có với khối mới của HTML. Các liên kết trong ô dẫn tới file đã mở; cột bằng
chứng ghi tên bảng/cột, `operationId` và component/hàm để tìm lại. API ở đây đã đối chiếu cả [hợp đồng][api],
[route khoản chi][route-chi] và [route nguyên liệu][route-nl]. Các nhãn nguồn bên dưới là liên kết tới đường dẫn thật.

| Tính năng của HTML | DB có chưa | API có chưa | FE thật có chưa | Bằng chứng cụ thể | Thiếu gì / bước |
|---|---|---|---|---|---|
| Đầu trang, điều hướng, màu tiền và bố cục | Không cần dữ liệu mới | Không cần cửa mới | Có đầu trang và route ([page][page-chi], [component][fe-chi], [CSS][css-chi]); bố cục còn khác | `TrangKhoanChi`; `.kc-category-grid` hiện 2/3 cột ở màn rộng, mẫu xếp các mục dọc | Khớp bố cục mới, giữ khung ứng dụng; KC-08 |
| Tổng tiền theo khoảng ngày; chọn nhanh 7/10/14/30 | Có dữ liệu gốc ([DB khoản chi][db-chi]); tổng không lưu | Có ([API][api], [service][svc-chi]) | Có ([FE][fe-chi], [hook][hook-chi]); khối chọn ngày còn dài | `expense.amount_vnd`, `paid_date`; `listExpenses` → `total_vnd`; `TrangKhoanChi` tính khoảng gồm hai đầu, URL `tu/den/loai/nguon` | Thu gọn theo T-362, giữ tổng backend và ngày cuối; chỉ FE, KC-08 |
| Mục chi & sản phẩm | Có ([DB chi tiết][db-ct]) | Có ([API][api], [SQL danh mục][sql-loai], [SQL khoản con][sql-con]) | Có ([FE][fe-chi], [hook][hook-chi]) | `expense_category`, `expense_item.expense_category_id`; `listExpenseCategories` trả `items`; `MucChi`, `useLoaiChi` | Bày theo mẫu với danh mục thật; chưa có dấu `ingredient` hoặc liên kết sổ lượng; KC-02, KC-06, KC-08, KC-11; Q-KC-01 |
| Bảng nguyên liệu ba cột, bấm tên mở chi tiết trượt | Một phần: có khoản con ([DB chi tiết][db-ct]) và danh mục lượng riêng ([DB nguyên liệu][db-nl]) | Một phần: `listExpenseCategories` và `getSupplyStock` là hai nguồn riêng ([API][api]) | Chưa tại Khoản chi ([FE][fe-chi]); [Kho][fe-kho] có thẻ số liệu khác mẫu | Mẫu `DanhSachKhoanCon`, `ingredientDetail`; thật `MucChi` chỉ có tên, ngày chi, tổng tiền và nút | Thiếu định danh nối hai nguồn và ngăn chi tiết đúng dòng; KC-02, KC-06, KC-11; Q-KC-01 |
| Ngày nhập trên lần mua và ngày nhập gần nhất | Một phần ([DB chi][db-chi], [DB nguyên liệu][db-nl]): sổ lượng có ngày mua; khoản chi chỉ có ngày chi/lúc ghi | Một phần ([API][api], [SQL tổng lượng][sql-nl]): `getSupplyStock` có ngày nhập gần nhất; `Expense` không có ngày nhập | Có lần nhập gần nhất ở [TrangKho][fe-kho]; chưa có trên [FormKhoan][fe-chi] | `supply_day_entry.entry_date` với `kind_code='purchased'`; `SupplyItem.latest_purchase_date`; `expense.paid_date` khác `created_at`; mẫu `receivedDate` | Chốt ngày nhập riêng và quan hệ lần mua–khoản chi, giữ thiếu ngày ở dữ liệu cũ; KC-03, KC-06, KC-10, KC-11; Q-KC-02 |
| Số hàng còn / lượng còn lại | Có con số mua/dùng để tính hiệu số ([DB nguyên liệu][db-nl]); chưa có số kiểm đếm riêng | Có hiệu số ([API][api], [SQL tổng lượng][sql-nl]) | Có hiệu số ở [TrangKho][fe-kho], chưa đưa vào [Khoản chi][fe-chi] | `entered_measure`, `kind_code`; `getSupplyStock` → `purchased_total`, `used_total`, `balance`; mẫu lấy `stockEstimates.remaining` nhập tay | Không tự gọi hiệu số là số kiểm đếm; chọn nguồn và cách xử lý hiệu số âm; KC-04, KC-07, KC-11; Q-KC-03 |
| Mức dùng/ngày, ước tính còn dùng, Sửa dự tính | Chưa có chỗ lưu mức dùng/ngày; `reminder_ratio` đã có ([migration tỉ lệ][db-ti-le]) nhưng là đại lượng khác | Chưa có dự tính; chỉ có `setSupplyItemReminderRatio`, `getSupplyStock` ([API][api]) | Chưa ở [Khoản chi][fe-chi]; [Kho][fe-kho] chỉ đặt tỉ lệ nhắc | Mẫu `forecast-form`, `forecastText`: số còn ÷ mức dùng; `SupplyItem` không có mức dùng/ngày hay số ngày | Chốt nguồn mức dùng, đơn vị, số thiếu/0/âm và cách diễn đạt; không thay nhắc POS; KC-04, KC-07, KC-12; Q-KC-03, Q-KC-04 |
| Lịch sử sử dụng nguyên liệu tổng, mỗi ngày một hàng | Có ([DB nguyên liệu][db-nl]) | Có dữ liệu từng thứ ([API][api], [SQL sổ][sql-so]); chưa có cửa HTTP đọc lịch sử mọi thứ một lượt | Có sổ từng thứ tại [TrangNguyenLieu][fe-nl], chưa có khối này trong [Khoản chi][fe-chi] | `supply_day_entry.kind_code='used'`, `entry_date`, `entered_measure`; `getSupplyItem` → `entries`; `So`, `Dong`, `useSoNguyenLieu` ([hook][hook-nl]) | Dùng lại lịch sử, ghép bằng mã đã được duyệt; đọc từng thứ được, không bắt buộc API mới; KC-11 sau KC-02/KC-06; Q-KC-01, Q-KC-05 |
| Lịch sử sử dụng trong chi tiết, mặc định 7 ngày, lọc/đặt lại | Có dữ liệu ngày ([DB nguyên liệu][db-nl]) | Có toàn bộ sổ của một thứ qua `getSupplyItem` ([API][api]); chưa có tham số ngày cho cửa này | Một phần ở [So][fe-nl]; chưa có lịch sử lọc trong ngăn chi tiết Khoản chi | Mẫu `defaultDetailUsageRange`, `renderDetailUsageHistory`; thật `useSoNguyenLieu` đọc `entries` | Lọc ngày và loại `used` trên tập đã đọc, giữ nguyên chuỗi lượng; không cần DB/BE riêng; KC-11; Q-KC-01 |
| Lịch sử mua hàng, mỗi ngày nhập một hàng, chọn nguyên liệu | Một phần: có tiền/người/ngày chi ở [DB chi][db-chi], khoản con ở [DB chi tiết][db-ct]; thiếu ngày nhập của từng khoản | Một phần: `listExpenses` có danh sách theo khoảng ngày chi ([API][api]); thiếu ngày nhập, chưa có cách đọc toàn lịch sử không phải tự đặt ngày đầu | Chưa có khối riêng trong [FE][fe-chi] | Mẫu `renderPurchaseHistory` đọc mọi khoản của mục, nhóm `receivedDate`; `Expense` có `amount_vnd`, `person_name`, `expense_item_id`, không có lượng mua | Đường đọc độc lập lọc tiền chung, đầy đủ lịch sử/ngày thiếu, liên kết đã duyệt; KC-03, KC-05, KC-06, KC-11; Q-KC-01, Q-KC-02 |
| Điện, nước: chi theo ngày và khoản con | Có cấu trúc danh mục/khoản con/khoản chi ([DB chi][db-chi], [DB chi tiết][db-ct]); không khẳng định đã có một mục gộp tên này | Có `listExpenseCategories`, `listExpenses` ([API][api]) | Một phần: [MucChi][fe-chi] bày mục thật, chưa có bảng ngày của từng mục | `paid_date`, `expense_item_id`, `item_totals.last_paid_date`; mẫu `expenseDetail`, `DanhSachKhoanCon` | Đổi cách bày, giữ nguồn thật; không thêm chỉ số công tơ hay tự gộp danh mục; KC-09 |
| Đồ dùng cho quán và các mục khác: chi theo ngày, khoản con | Có cùng cấu trúc ([DB chi][db-chi], [DB chi tiết][db-ct]); tên mục thực tế chưa kiểm | Có cùng cửa `listExpenseCategories`, `listExpenses` ([API][api]) | Một phần: [MucChi][fe-chi] dùng chung mọi mục | `expense_category_id`, `expense_item_id`, `paid_date`; `MucChi` không viết cứng ba nhóm | Bảng ngày/ngăn chi tiết dùng chung, không coi mọi đồ dùng là nguyên liệu hay ngược lại; KC-09, Q-KC-01 nếu nối sổ lượng |
| Lịch sử chi của từng khoản con ngoài nguyên liệu | Có ([DB chi][db-chi], [DB chi tiết][db-ct]) | Một phần: `listExpenses` lọc ngày và mục, trả mã khoản con ([API][api]); chưa có lọc mã khoản con/đọc mốc cuối ngoài bộ lọc | Chưa có ngăn lịch sử; [DoiTen][fe-chi] chỉ có các lần sửa tiền trong bộ lọc chung | Mẫu `defaultExpenseHistoryRange`, `renderExpenseHistory`; `Expense.expense_item_id`; service `Doc` | Đọc lịch sử độc lập; 7 ngày kết thúc ở lần chi mới nhất của mục, chọn khoảng khác; KC-05, KC-09; không cần DB |
| Sổ khoản chi: bộ lọc + số lần và tổng tiền theo ngày | Có dữ liệu gốc ([DB chi][db-chi]); không lưu tổng | Một phần ([API][api], [service][svc-chi]): có tổng kỳ/mục/khoản con, **chưa có tổng theo ngày** | Một phần: [TrangKhoanChi][fe-chi] chỉ có bộ lọc dưới tiêu đề này | `Expenses.total_vnd`, `category_totals`, `item_totals`; mẫu `daily-summary-list` tự cộng ở JS | Backend trả tổng ngày, FE chỉ bày và đếm/nhóm theo hợp đồng; KC-05 → KC-09; không migration |
| Các khoản chi: mỗi ngày một hàng, khoản cùng ngày nằm ngang | Có ([DB chi][db-chi], [DB chi tiết][db-ct]) | Có dữ liệu từng khoản: `listExpenses` ([API][api], [SQL khoản chi][sql-chi]) | Có bảng Sửa/Xoá ([FE][fe-chi]), hiện nhóm theo mục rồi mỗi khoản một dòng | `TrangKhoanChi` dùng `grouped: Map<number, Khoan[]>` theo `expense_category_id`; mẫu `entriesByDay` | Nhóm hiển thị theo `paid_date`, ngày mới trước, giữ từng mã/thao tác; KC-09 |
| Ghi/sửa/xoá khoản chi, lý do, đổi mục/khoản con | Có ([DB chi][db-chi], [DB chi tiết][db-ct]): tiền dương, FK, dấu xoá/vết | Có ([API][api], [service][svc-chi], [catalog][catalog]): `createExpense`, `updateExpense`, `deleteExpense` | Có ([FE][fe-chi], [hook][hook-chi]) | `FormKhoan`, `Xoa`; `GhiKhoan`, `SuaKhoan`, `XoaKhoan`; `deleted_at`, `deleted_by_person_id` | Giữ nguyên các cửa và luật T-248; chỉ mở thêm trường sau quyết định ngày nhập; KC-06/KC-10; Q-KC-02 |
| Loại chi; thêm/đổi tên/xoá mục và khoản con | Có ([DB chi][db-chi], [DB chi tiết][db-ct]) | Có ([API][api], [catalog][catalog]): `createExpenseCategory`, `renameExpenseCategory`, `deleteExpenseCategory`, `createExpenseItem`, `renameExpenseItem`, `deleteExpenseItem`; đọc bằng `listExpenseCategories` | Có ([FE][fe-chi], [hook][hook-chi]); hộp thêm chưa liệt kê loại như mẫu | `ThemLoai`, `ThemCon`, `DoiTen`, `Xoa`; nguồn bắt buộc; UNIQUE tên giữ cả dòng xoá; `loaiDangDung`/`conDangDung` kiểm mọi ngày | Bày lại hộp Loại chi; giữ lý do dù mẫu đổi tên không đòi; chưa đồng bộ rename/delete sang sổ lượng; KC-10, Q-KC-05 |
| Thêm nguyên liệu/khoản con kèm tiền mua tuỳ chọn | Có hai cấu trúc riêng ([DB chi][db-chi], [DB chi tiết][db-ct]) | Có hai lệnh riêng `createExpenseItem`, `createExpense`, chưa có giao dịch gộp ([API][api], [catalog][catalog]) | Một phần: [ThemCon][fe-chi] chỉ thêm tên rồi mời Ghi chi | Mẫu `product-form` thêm tên và tiền trong một lần; thật `useThemKhoanCon` không gửi tiền | Quyết có giữ một lần bấm hay hai bước, xử lý thành công một phần/mất phản hồi; KC-06 có điều kiện, KC-10; Q-KC-06 |
| Sửa tiền đã ghi từ hộp sửa tên | Có cập nhật đúng khoản ([DB chi][db-chi]) | Có `updateExpense`, lý do/vết và giữ người ghi ([API][api], [service][svc-chi]) | Có [DoiTen][fe-chi] → `FormKhoan`, bảo vệ tên chưa lưu; chỉ xem khoản trong bộ lọc | Mẫu `renderMoneyHistory` lấy toàn bộ khoản thuộc mục/khoản con; thật `data?.expenses.filter` từ truy vấn chung | Mở danh sách lịch sử độc lập để không mất khoản ngoài kỳ; giữ đúng `expense_id`, không thêm khoản mới; KC-05 → KC-10 |
| Lọc ngày riêng từng khu; lọc loại/nguồn; Đặt lại | Có ngày chi và ngày sổ lượng ([DB chi][db-chi], [DB nguyên liệu][db-nl]) | Có lọc kỳ/mục/nguồn cho `listExpenses`; `getSupplyItem` trả cả sổ ([API][api]) | Có URL lọc chung và giao khoảng riêng trong [MucChi][fe-chi]; chưa có nút Lọc ngày thu gọn, lọc lịch sử riêng | Mẫu `categoryState`, `filteredEntries`, `renderDetailUsageHistory`; thật `useKhoanChi`, `dates`, `localFrom/localTo` | Giữ bộ lọc mục nằm trong kỳ chung; lịch sử độc lập; thu gọn không xoá lọc; KC-08, KC-09, KC-11 |
| Hiện/Ẩn từng mục, khoản con, Sổ khoản chi, Các khoản chi và hai lịch sử | Không cần lưu DB | Không cần API | Một phần ([FE][fe-chi]): `expanded`, `visible`, `ledger` đã có | Mẫu `toggle-filters`, `setHistoryVisibility`, `categoryState`; thật chưa có ẩn Sổ khoản chi và hai lịch sử | Trạng thái độc lập theo mã, giữ sau đọc lại/lọc; `aria-expanded`, `aria-controls`, focus; KC-08, KC-09, KC-11 |
| Công cụ xem mẫu: tên component, mục lục, chú giải, thông báo dữ liệu minh hoạ | Không áp dụng | Không áp dụng | Không cần dựng vào FE thật; tiêu đề/trạng thái dữ liệu thật đã ở [TrangKhoanChi][fe-chi] | HTML `labels`, `.tools`, `.legend`, `.footnote`; FE `TrangThai` phân biệt chờ/lỗi/bản cũ | Claude duyệt ranh giới công cụ mẫu ở KC-01; KC-08/KC-13 kiểm không còn dữ liệu mẫu |

**Các luật hiện hành cần giữ khi dựng.** [Shop facts §8.4 và §8.10][facts] là nguồn nghiệp vụ;
[ADR-071, ADR-074, ADR-106, ADR-111, ADR-112 và ADR-128][adr] giải thích mô hình/cửa hiện có. T-248 chỉ tới
ADR-128; ADR-128 sửa giới hạn xoá và khoản con của ADR-106/111, không thay luật ghi/sửa tiền riêng.
[Lược đồ nguyên liệu][luoc-nl] và [lược đồ khoản chi][luoc-chi] giải thích ý định, migration thắng về cấu trúc.

- Khoản cũ có `expense_item_id=null` vẫn đọc/sửa được; không tự gán khoản con. Tiền mua nguyên liệu chỉ ghi một
  lần ở Khoản chi; sổ lượng không trở thành sổ tiền thứ hai. Lương vẫn ở luồng người làm.
- Nguồn nằm trên mục, bắt buộc chọn, không đổi được sau tạo. Ghi/sửa khoản từ két kiểm ngày cũ/mới liên quan;
  xoá khoản kiểm ngày đã đối soát **cho cả tiền riêng**. Không tự mở rộng lệnh cấm xoá này sang mọi sửa tiền riêng.
- Đổi tên/xoá có lý do và vết; xoá mềm. Chặn xoá mục/khoản con còn khoản chưa xoá trên mọi ngày, kể cả ngoài bộ
  lọc. Không chép việc HTML xoá `usageHistory` hoặc đổi đơn vị tự do sang sổ thật.
- Sổ lượng giữ một thứ/ngày/loại (`purchased` hoặc `used`), số thập phân là chuỗi trên API; không phải từng lần
  mua. `balance` có thể âm; không đặt lại tổng khi mua thêm. `reminder_ratio` là tỉ lệ nhắc POS, không là mức dùng/ngày.
- Theo [khung FE][khung-fe], tổng tiền phải do backend trả. Không chép `reduce` cộng tiền của mẫu vào FE;
  nhóm các dòng theo ngày để bày không đồng nghĩa tự tính tổng tiền. Chuỗi lượng cũng không đổi sang số thực để
  cộng dồn ở trình duyệt.

## Bảng bước

Thứ tự lớp thi công là **DB → BE → FE**, sau bước thiết kế. “Đứng trên” là phụ thuộc; “Chặn bởi” là điều kiện
chưa được quyết, không là cột trạng thái. KC-01 có thể duyệt từng phần: phần đọc tiền và giao diện đã có luật
không phải đợi câu trả lời về dự tính. Các bước DB/BE ghi “có điều kiện” chỉ mở nếu phương án đã duyệt thực sự
cần chúng; Claude bỏ bước không cần, cập nhật phụ thuộc rồi mới giao. Không tạo chỗ cất/cửa trống cho đủ ba tầng.

| Bước | Việc | Mức | Ai | Đứng trên | Chặn bởi |
|---|---|:--:|---|---|---|
| [KC-01](#kc-01) | Thiết kế và ADR: nối danh mục, ngày nhập, ngừng dùng, cửa gộp, công thức ước tính, gộp ba trang | L3 | Claude, chủ repo duyệt | Bảng đối chiếu; §8.4/§8.10; ADR-071/074/106/128; khung FE | Cách đọc chưa xác nhận ở §8.10 *Lượt 2026-11-22* |
| [KC-02](#kc-02) | DB: nối khoản con nguyên liệu với `supply_item`, dấu ngừng dùng | L2 | Claude test trước, Codex làm | KC-01 | — |
| [KC-03](#kc-03) | DB: ngày nhập trên khoản chi | L2 | Claude test trước, Codex làm | KC-01; KC-02 | — |
| ~~[KC-04](#kc-04)~~ | ~~DB: dữ liệu gốc của dự tính~~ — **bỏ 2026-11-22**: số còn và mức dùng đều suy từ sổ (U-122, U-123) | — | — | — | — |
| [KC-05](#kc-05) | BE: tổng tiền theo ngày và cách đọc lịch sử chi độc lập | L2 | Claude test trước, Codex làm | KC-01 phần đọc tiền | — |
| [KC-06](#kc-06) | BE: danh mục nối sổ lượng, ngày nhập, ngừng dùng, cửa thêm nguyên liệu kèm tiền | L2 | Claude test trước, Codex làm | KC-02, KC-03, KC-05 | — |
| [KC-07](#kc-07) | BE: tính ước tính còn dùng (TB 7 ngày có ghi dùng) | L2 | Claude test trước, Codex làm | KC-06 phần định danh | — |
| [KC-08](#kc-08) | FE: khung trang, chọn nhanh gọn, nút thu gọn, bố cục đáp ứng | L1 | Codex làm, Claude duyệt | KC-01 phần trình bày; FE hiện có | **làm được ngay** sau KC-01 phần trình bày |
| [KC-09](#kc-09) | FE: Sổ khoản chi, Các khoản chi, mục ngoài nguyên liệu và lịch sử chi theo ngày | L2 | Claude test trước, Codex làm | KC-05, KC-08 | — |
| [KC-10](#kc-10) | FE: hộp ghi/sửa/xoá, Loại chi, Sửa tiền đã ghi, thêm nguyên liệu kèm tiền một lần bấm | L2 | Claude test trước, Codex làm | KC-06, KC-08 | — |
| [KC-11](#kc-11) | FE: bảng nguyên liệu, chi tiết, ghi lượng mua/dùng, tỉ lệ nhắc, hai lịch sử | L2 | Claude test trước, Codex làm | KC-06, KC-08, KC-09 | — |
| [KC-12](#kc-12) | FE: hiện ước tính còn dùng (chỉ đọc) | L1 | Codex làm, Claude duyệt | KC-07, KC-11 | — |
| [KC-14](#kc-14) | FE: gỡ trang Kho và Nguyên liệu khỏi menu, đường cũ chuyển về Khoản chi | L1 | Codex làm, Claude duyệt | KC-11, KC-12 | — |
| [KC-13](#kc-13) | Nghiệm thu trang thật với API/database, đối chiếu hình và hồi quy tiền/lượng | L2 | Codex viết kịch bản, Claude chạy và duyệt | KC-09…KC-12, KC-14 | — |

KC-01 là L3 vì gộp hai danh mục đã có dữ liệu và đổi luật xoá: Claude duyệt thiết kế trước code, có thể chia KC-02 thành
lát nhỏ hơn. Mã KC-14 đứng trước KC-13 trong thứ tự làm; số chỉ là mã, không phải thứ tự.

<a id="kc-01"></a>
## KC-01 — Thiết kế nguồn dữ liệu và ghi nhận quyết định trước code

**Vì sao.** Bản mẫu có dữ liệu chưa có chỗ trong hệ thống và có thao tác trái vòng đời sổ lượng hiện hành.
Đổi cấu trúc hay ghi số thật trước khi có lời sẽ thành quyết hộ chủ quán.

**Acceptance.**

- A1 — Claude đưa từng Q-KC-01…06 tới đúng người; ghi lời xác nhận vào owner và phân biệt phương án thiết kế với
  lời quán. ADR ghi định danh, quan hệ, người có quyền, ngày nhập, nguồn số còn/mức dùng, đơn vị và vòng đời.
- A2 — Duyệt riêng hợp đồng đọc cho tổng ngày và lịch sử ngoài kỳ: cách lấy mốc đầu/cuối, lọc theo mã, dữ liệu cũ
  thiếu khoản con/ngày nhập, tập đầy đủ hay phân trang. Không dùng ngày mẫu hoặc ngày đầu tuỳ tiện để giả toàn lịch sử.
- A3 — Xác định phạm vi bộ lọc theo HTML: mục dùng giao khoảng riêng với khoảng chung; lịch sử mua và lịch sử dùng
  tổng không bị bộ lọc tiền che; lịch sử chi tiết có khoảng riêng gồm hai đầu. Mặc định 7 ngày của lịch sử dùng
  lấy ngày dùng mới nhất trong tập lịch sử đã xác định; lịch sử chi lấy ngày chi mới nhất của mục. Khi rỗng,
  dùng mốc ngày quán do backend cung cấp hoặc hiện rỗng theo thiết kế đã duyệt, không lấy ngày mẫu/đồng hồ máy khách.
- A4 — Chốt ranh giới công cụ xem mẫu, danh mục thật và giao diện; không tự ép danh mục thành ba mục mẫu. Đánh dấu
  nhánh cần DB, nhánh dùng API sẵn, nhánh cần hợp đồng mới; bỏ bước điều kiện không cần. Đối chiếu I-021, I-025,
  I-026, I-029 và chỉ sửa bất biến khi có quyết định cho phép. Claude cập nhật owner/phân rã trước khi giao code.

**Phạm vi.** `docs/decisions.md`, `docs/product/99-unknowns.md`, `master_plan/shop-facts.md`,
`quality/invariants.md`, `docs/product/4-fe/01-khung-fe.md`, `work/backlog_KC.md`, `work/backlog.md` — Claude giữ.

**Nhận việc.**

Claude Code, 2026-11-22. Hỏi chủ repo lượt hai (bốn câu + một câu về ô lượng); lời vào `master_plan/shop-facts.md` §8.10
*Lượt hai* vế 8–11. Thiết kế: **ADR-147** (*Đề xuất*, chờ chủ repo duyệt năm điểm *Chờ duyệt*). I-025 vế 3 có *Sửa
2026-11-22*. **Phần trình bày** (A4: công cụ xem mẫu không vào trang thật, danh mục theo dữ liệu, không ô hay số giả) coi là
đã đủ để giao `KC-08` ngay, vì nó không đổi dữ liệu hay hợp đồng.
Lượt ba cùng ngày: chủ repo chọn *"Duyệt, giao Codex làm"* rồi trả lời năm điểm (a)–(e) — **ADR-147 Đã chốt**, thêm điểm 12
*chuyển mục* (chỉ giữa hai mục cùng theo dõi lượng và cùng nguồn tiền — phiên chọn hướng chặt), ngừng dùng khoá hẳn phần
lượng nhưng mở lại được, hiệu số ≤ 0 hiện *Hết theo sổ*; lời ở §8.10 vế 12–15. Bước kế: `KC-02` (Claude viết test trước).

<a id="kc-02"></a>
## KC-02 — DB: danh mục chi và danh mục lượng liên hệ thế nào

**Vì sao.** `expense_item` chỉ trỏ mục chi, không trỏ `supply_item`; hai bảng trùng tên không chứng minh cùng một
thứ. Cờ `ingredient` chỉ có trong mẫu. Không thể ghép tên để đọc số thật.

**Acceptance.**

- A1 — Chỉ sau lời Q-KC-01/Q-KC-05: nếu cần lưu quan hệ/phân loại, migration mới thể hiện đúng số lượng liên hệ
  được duyệt, mã hợp lệ, điều kiện vòng đời và quyền ghi. Không sửa migration đã chạy, không tạo danh mục mẫu.
- A2 — Dữ liệu cũ không bị ghép theo tên hoặc gán nguồn tự động; thử tên giống nhau ở hai mục, thứ chưa ghép,
  một thứ được/không được dùng ở nhiều mục đúng theo quyết định. Đổi tên không đổi định danh hay số đã ghi.
- A3 — Test trước của Claude chứng minh không mất lịch sử lượng/tiền khi thay đổi quan hệ hoặc xoá mềm danh mục;
  kiểm vết và rollback khi đã có dữ liệu. `db-check` và gate đạt. Nếu quyết định không lưu quan hệ mới,
  Claude bỏ bước này và ghi chính xác cách định danh được duyệt cho bước sau.

**Phạm vi.** `db/migrations/`, `db/tests/`, `db/reconcile/`, `docs/product/2-db/12-luoc-do-nguyen-lieu.md`,
`docs/product/2-db/15-luoc-do-khoan-chi.md`, `docs/product/2-db/07-thu-tu-migration.md`,
`docs/product/2-db/09-doi-chieu-bat-bien.md`. Tên file mới và ràng buộc do phiếu sau KC-01 xác định; không sửa BE/FE.

**Nhận việc.**

**Kết quả 2026-11-22** (thực hiện: Codex rồi Claude, duyệt: Claude; worktree `../lean_wt/KC-02`, nhánh `codex/KC-02` từ
`8d71696`). Claude viết `db/tests/kc02_supply_expense_link.sql` trước. Lượt Codex một **dừng đúng**: phiếu đòi `ON UPDATE
CASCADE` cho chuyển mục, QD-51 cấm dây chuyền — Claude đổi sang khoá ngoại `expense_item_fkey` giữ mặc định từ chối nhưng
`DEFERRABLE INITIALLY DEFERRED`, cửa chuyển đổi khoản con và khoản chi trong một giao dịch (ADR-147 điểm 12 không đổi chữ).
Lượt hai Codex viết migration `20261122120000_gop_kho_khoan_chi`, sửa danh sách cột của `I-025` và mười tên `unreviewed`
ở hợp đồng 0.77.0, rồi hết hạn mức trước báo cáo. Claude đọc diff, sửa đường lùi (đếm cả cờ mặc định false nên luôn từ
chối), sinh lại sqlc, viết `docs/product/2-db/30-luoc-do-gop-kho-khoan-chi.md`, dòng 50 ở `07-thu-tu-migration.md`, mệnh
đề **I-046** và dòng *chưa có lát* của nó (câu đối chiếu dữ liệu nợ trước KC-13). `go build`/`vet`, `check-sqlcgen`,
`check-api-contract`, `check-schema-names`, `check-write-paths` PASS trong worktree. Gate lượt một ở cây chính đỏ hai chỗ do
khoá ngoại kiểm hoãn và cột dấu ngừng: `db/tests/t248_expense_items_soft_delete.sql` (thêm `SET CONSTRAINTS ALL IMMEDIATE`
sau lần ghi sai) và YC-26 của `db/scenario/yc.sql` (danh sách cột thêm hai cột dấu ngừng). Lượt hai: `./scripts/gate.sh`
PASS — `db-check` 50 bước xuôi · lùi · xuôi lại, 64 tệp test gồm `kc02_supply_expense_link.sql`; `be-check` 33/33 gói.

<a id="kc-03"></a>
## KC-03 — DB: ngày hàng về và lần chi, nếu cần chỗ lưu mới

**Vì sao.** `supply_day_entry` ghi tổng một ngày, `expense` ghi từng lần chi. Không thể mặc nhiên nối một–một,
nhất là mua nợ, trả nhiều lần hoặc nhập nhiều lần trong cùng ngày.

**Acceptance.**

- A1 — Sau Q-KC-02, lưu đúng ngày/quan hệ được duyệt hoặc dùng nguồn sẵn có nếu đủ; không tự đặt tên cột/hình
  quan hệ trong sổ này. Ngày hàng về, ngày chi và lúc gõ đọc lại phân biệt được.
- A2 — Test dữ liệu cũ thiếu ngày; nhiều khoản chi cùng ngày; hàng về khác ngày trả tiền; sửa/chuyển khoản.
  Chỉ kiểm quan hệ thời gian đã được duyệt, không tự bắt ngày nhập bằng/trước ngày chi. Không backfill ngày giả.
- A3 — Không tự thêm dòng lượng từ số tiền hoặc nhân đôi tiền mua. Migration xuôi/lùi/xuôi lại và test dữ liệu
  hiện có qua `db-check`; nếu dùng hoàn toàn dữ liệu hiện có thì Claude bỏ migration/bước này, cập nhật KC-06.

**Phạm vi.** `db/migrations/`, `db/tests/`, `db/reconcile/`, `docs/product/2-db/12-luoc-do-nguyen-lieu.md`,
`docs/product/2-db/15-luoc-do-khoan-chi.md`, `docs/product/2-db/07-thu-tu-migration.md`,
`docs/product/2-db/09-doi-chieu-bat-bien.md`.

**Nhận việc.**

**Gộp vào KC-02, 2026-11-22:** cột `expense.received_date` đã có trong migration `20261122120000_gop_kho_khoan_chi`
(ADR-147 điểm 5, test `db/tests/kc02_supply_expense_link.sql`). Bước này không còn việc riêng; cửa ghi ngày nhập ở KC-06.

<a id="kc-04"></a>
## KC-04 — DB: đầu vào dự tính được duyệt — **BỎ 2026-11-22**

**Bỏ** vì chủ repo chọn số còn là hiệu số máy tính (U-122) và mức dùng máy tự tính từ sổ (U-123): không có đầu vào mới
nào phải lưu. Phần dưới giữ làm lịch sử.


**Vì sao.** Hiện chỉ có con số mua/dùng, đơn vị và tỉ lệ nhắc. Ghi thêm “số còn” hoặc “mức dùng/ngày” có thể tạo
đáp số thứ hai cho sổ lượng; cần biết đó là số nào, ai nhập, lúc nào và có cần lịch sử.

**Acceptance.**

- A1 — Sau Q-KC-03/Q-KC-04, chỉ lưu đầu vào thật sự được phép; kiểu thập phân, đơn vị, dấu người/thời gian và
  vết sửa theo quyết định. Nếu số đều suy từ sổ hiện có thì **không tạo migration**; Claude bỏ bước này.
- A2 — Test phân biệt chưa nhập với 0; miền số/độ chính xác và cập nhật có lý do đúng quyết định. Không ghi đè
  `balance`, không dùng `reminder_ratio` thay mức dùng, không cất tổng/số ngày tính ra nếu không có ADR cho phép.
- A3 — Các ca I-025/I-026 hiện hành vẫn đạt hoặc được Claude cập nhật theo lời mới trước thi công; không quy
  suất bán thành lượng dùng. Kiểm dữ liệu cũ, rollback có dữ liệu, `db-check` và gate.

**Phạm vi.** `db/migrations/`, `db/tests/`, `db/reconcile/`, `docs/product/2-db/12-luoc-do-nguyen-lieu.md`,
`docs/product/2-db/07-thu-tu-migration.md`, `docs/product/2-db/09-doi-chieu-bat-bien.md`.

**Nhận việc.**

<a id="kc-05"></a>
## KC-05 — BE: tổng ngày và lịch sử chi độc lập bộ lọc chung

**Vì sao.** `listExpenses` đã trả các khoản và ba dạng tổng nhưng chưa có tổng ngày; `from/to` bắt buộc cũng
chưa cho FE biết mốc toàn lịch sử hay lần chi mới nhất ngoài kỳ đang xem. Đây là thiếu hợp đồng đọc, không thiếu bảng.

**Acceptance.**

- A1 — Theo thiết kế đọc của KC-01, mở rộng hợp đồng/cửa sẵn hoặc cửa riêng tối thiểu; Claude chốt `operationId`
  và hình trả trước. Backend trả tổng/số lần theo ngày, giữ tổng kỳ/mục/khoản con; không ghi tổng vào DB.
- A2 — Trên cùng tập lọc gồm hai đầu, tổng ngày cộng lại khớp tổng kỳ, kể cả khoản cũ không có khoản con và
  nhiều mục/người/nguồn cùng ngày. Khoản xoá không góp tổng; tràn số và tập rỗng có hành vi kiểm được.
- A3 — Đọc được lịch sử mục/khoản con ngoài bộ lọc chung, mốc cuối đúng tập được duyệt; không suy từ trang kết
  quả thiếu. Nếu phân trang thì tổng/mốc không tính trên riêng trang. Lọc sai báo lỗi, không phiên 401 và sai vai 403.
- A4 — Test hồi quy đọc/sửa/xoá hiện có đạt; tăng phiên bản hợp đồng, kiểm ma trận quyền nếu thêm cửa,
  `check-api-contract`, `be-check` và gate đạt. Không mở rộng quyền đọc lịch sử tiền cho POS.

**Phạm vi.** `be/internal/khoanchi/`, `docs/product/3-be/openapi.yaml`, `docs/product/3-be/02-vai-va-quyen.md`.
Không migration, không component FE; artefact sinh từ hợp đồng theo phiếu cụ thể do Claude khai riêng khi cần.

**Nhận việc.**

**Kết quả 2026-11-22** (thực hiện: Claude Code — Codex hết hạn mức tới 15:08; **chưa ai duyệt độc lập**; worktree
`../lean_wt/KC-05`, nhánh `claude/KC-05`, nền `8d71696` + patch KC-02 chỉ stage). Hình đọc Claude chốt: `listExpenses` trả
thêm `day_totals` (một dòng mỗi ngày chi trong tập lọc, ngày mới trước, `expense_count` · `total_vnd`, tổng các dòng bằng
`total_vnd`) và nhận `expense_item_id` tuỳ chọn; `listExpenseCategories` trả `last_paid_date` của mục và từng khoản con, tính
trên mọi ngày, chưa chi thì null — FE lấy mốc 7 ngày mặc định từ đây, không cần cửa thứ hai. Hợp đồng 0.78.0; `schema.ts`
sinh lại; dữ liệu mẫu `khoan-chi.test.tsx` thêm `day_totals: []`. Test viết trước: `TestI029_KC05_TongTheoNgayLaPhepCongCuaBackend`,
`TestI029_KC05_LichSuKhoanConVaNgayChiGanNhatNgoaiBoLoc` (`be/internal/khoanchi/kc05_test.go`). `be-check` trong worktree:
33/33 gói PASS; `check-api-contract` PASS 0.78.0; FE typecheck sạch, `vitest src/app/chu-quan` 17 tệp · 363 ca PASS.
Chưa chứng minh test đỏ trước khi có code (viết và làm cùng lượt).

<a id="kc-06"></a>
## KC-06 — BE: quan hệ nguyên liệu, ngày nhập và các cửa ghi liên quan

**Vì sao.** UI cần biết khoản con nào đọc được sổ lượng, đọc ngày nhập từ đâu, và đổi tên/xoá ảnh hưởng gì.
Các cửa khoản chi đã có không được thay bằng đường ghi bỏ qua khoá ngày, vết hoặc nguồn tiền.

**Acceptance.**

- A1 — Chỉ công bố/ghi quan hệ và ngày nhập theo Q-KC-01/Q-KC-02/Q-KC-05 đã được duyệt; trả được trường thiếu
  cho dữ liệu cũ. Không ghép theo tên, không tự tạo `supply_item` hay dòng mua lượng khi chỉ ghi tiền.
- A2 — Đổi tên/xoá mục hoặc khoản con tuân thủ luật đã chốt, không xoá lịch sử dùng như HTML. Test đối tượng
  không còn, liên kết sai, đổi mục, ghi đồng thời với xoá; giữ chặn danh mục còn khoản chi trên mọi ngày.
- A3 — Test I-021/I-029: nguồn không đổi; khoản từ két ghi/sửa kiểm ngày liên quan; xoá cả tiền riêng ở ngày
  đã ký bị chặn; tổng đọc và phép két không cộng khoản đã xoá. Lý do/vết/người ghi ban đầu được giữ.
- A4 — Nhánh Q-KC-06: **chỉ thêm cửa gộp nếu quyết định đòi giao dịch nguyên khối**; test lỗi giữa chừng không
  để lại nửa kết quả và mất phản hồi không nhân đôi chi theo cơ chế đã duyệt. Nếu dùng hai lệnh hiện có, không
  tạo API gộp; KC-10 hiển thị rõ bước nào đã xong và cách đọc lại an toàn.
- A5 — Tăng phiên bản hợp đồng, cập nhật quyền/cửa ghi/ánh xạ lỗi nếu cần. Test backend gồm dữ liệu thật được
  dựng riêng để thử; `check-api-contract`, `be-check` và gate đạt. Không tạo sổ tiền nguyên liệu thứ hai.

**Phạm vi.** `be/internal/khoanchi/`, `be/internal/nguyenlieu/`, `be/internal/apierr/`,
`docs/product/3-be/openapi.yaml`, `docs/product/3-be/02-vai-va-quyen.md`. Chỉ BE/hợp đồng sau DB; nếu phát hiện
cần cấu trúc DB khác thì trả lại KC-01/02/03 trước, không lén gộp migration vào bước này.

**Nhận việc.**

<a id="kc-07"></a>
## KC-07 — BE: số dự tính và đầu vào của nó

**Vì sao.** Số chia trong HTML là minh hoạ. App thật cần một cách đọc/tính theo luật được duyệt, giữ lượng
thập phân chính xác và không lẫn với cờ nhắc POS hiện có.

**Acceptance.**

- A1 — Hợp đồng ghi rõ nguồn số còn, nguồn mức dùng/ngày, mốc số liệu, đơn vị và trạng thái không thể tính;
  kết quả theo Q-KC-03/Q-KC-04. Nếu chọn tính từ lịch sử, kiểm đúng tập ngày, ngày thiếu, ngày 0 và quy tắc làm tròn.
- A2 — Nếu cho nhập đầu vào, cửa ghi chỉ chủ quán, kiểm miền/đơn vị đã duyệt, sửa có lý do/vết; không sửa đơn vị
  sổ đã có qua một cửa dự tính. Dùng số thập phân chính xác, không qua `float64` cho con số sổ.
- A3 — Test số thiếu, mức 0, lượng âm của hiệu số, số lẻ nhỏ, thay đổi con số ngày và đọc lại; nhắc POS vẫn
  theo `reminder_ratio` và luật hiện hành. Không lấy tiền chi hoặc số suất bán làm lượng dùng.
- A4 — Chỉ mở phần hợp đồng mới cần thiết; dùng lại phép đọc `sql/doc.sql` cho tổng lượng. Nếu chủ repo bỏ dự
  tính thì Claude bỏ cả KC-04/KC-07/KC-12 hoặc viết lại acceptance theo quyết định, không dựng cửa giả. Gate và
  `be-check` đạt cho phương án thực thi.

**Phạm vi.** `be/internal/nguyenlieu/`, `be/internal/khoanchi/` nếu hình liên hệ đã duyệt cần đọc qua đó,
`be/internal/apierr/`, `docs/product/3-be/openapi.yaml`, `docs/product/3-be/02-vai-va-quyen.md`.

**Nhận việc.**

Claude Code, 2026-11-23 (chủ repo: *"tiếp tục yêu cầu codex làm bạn kiểm tra"*). Thực hiện: Codex trong worktree
`../lean_wt/KC-07`, nhánh `codex/KC-07` từ `1fc16ae` + nền KC-01/KC-02/KC-06/KC-08 chưa commit chỉ stage; duyệt: Claude. Phiếu:
`../lean_wt/_claude_logs/KC-07/phieu.md`. Test viết trước: `be/internal/nguyenlieu/kc07_test.go` (sáu test, tháng 6/2033).
Hình hợp đồng Claude chốt (0.80.0): mỗi `SupplyItem` thêm khối bắt buộc `usage_estimate` {`status` · `usage_days` ·
`used_in_window` · `days_left`}; cửa sổ là tối đa 7 ngày gần nhất có con số *đã dùng* tới ngày bán hôm nay; `days_left` làm
tròn xuống một chữ số, chỉ có khi `ready`; không cửa ghi, không mã lỗi mới, nhắc POS không đổi. A2 (cửa ghi đầu vào) không áp
vì ADR-147 điểm 8 tính từ sổ. Ba điểm phiên chọn — hiệu số ≤ 0 đứng trước mọi trạng thái, nên thứ chưa có con số nào trả `out_by_ledger` (FE ghép với
`reminder_status = no_purchase` để hiện *Chưa nhập*); cửa sổ chỉ gồm con số mang ngày tới hôm nay, còn hiệu số vẫn cộng mọi
ngày (I-026); thứ đã ngừng vẫn được tính — **chủ repo xác nhận 2026-11-23** (*"không có điểm nào muốn thêm hãy tích hợp vào
cây chung"*).

**Kết quả 2026-11-23** (thực hiện: Codex, duyệt và tích hợp: Claude). Codex thêm khối vào phép đọc chung `sql/doc.sql`
(một `LATERAL` lấy tối đa bảy con số *đã dùng* tới ngày bán hôm nay, mốc từ `ngayban.DongHo` quy ngày như `QuyNgay`), struct
`UocTinh` ở `service.go`, mọi đường gọi `doc` truyền mốc; hợp đồng 0.80.0 với schema `SupplyUsageEstimate`; sinh lại
`schema.ts`; dữ liệu mẫu `SupplyItem` của ba test FE và danh sách khoá ở `tongquan/handler_test.go` thêm trường mới. Không sửa
`kc07_test.go`. Claude sửa một chỗ khi duyệt: `floor(a / b)` qua phép chia `numeric` có làm tròn đổi thành `div(a, b)` (thương
nguyên chính xác), sinh lại sqlc. Gate trong worktree (2026-11-23): `./scripts/gate.sh` PASS — `be-check` 33/33 gói, sáu test `KC07` PASS,
`db-check` 50 bước, hợp đồng 0.80.0. Báo cáo Codex, phiếu, log gate: `../lean_wt/_claude_logs/KC-07/`. Bước kế: KC-09 (FE bảng
theo ngày) hoặc KC-12 sau KC-11.

<a id="kc-08"></a>
## KC-08 — FE: khung trang và các điều khiển trình bày

**Vì sao.** Phần này dùng dữ liệu/cửa hiện có; không cần đợi chốt mô hình dự tính để sửa bố cục cũ.

**Acceptance.**

- A1 — Khối chọn nhanh gọn như T-362: tiêu đề, khoảng đang áp dụng, bốn nút 7/10/14/30; giữ tính cả ngày cuối,
  trạng thái chọn, URL loại/nguồn, ngày mặc định từ backend. Không đổi số tiền hay cách gọi cửa ghi.
- A2 — Các mục xếp dọc theo danh mục trả về; giữ header và màu vùng tiền, nút thêm/ghi/đọc lại. Không viết cứng
  tên/số mục hoặc nguồn mẫu. Không thêm ô số còn/mức dùng giả khi chưa có dữ liệu được duyệt.
- A3 — Bổ sung thu gọn bộ lọc mục và Sổ khoản chi; Hiện/Ẩn của mục, khoản con, bảng độc lập và không xoá lọc.
  `aria-expanded`/`aria-controls`, bàn phím và focus đúng; tránh đổi khoá component làm mất trạng thái khi đọc lại.
- A4 — Kiểm 320/390/1024/1440 px: trang không tràn ngang; kiểm khoảng ngày qua tháng/năm và ngày sai; các test
  hiện có không suy yếu. `fe-check`, `check-fe-rules`, gate và kiểm trực quan của Claude đạt.

**Phạm vi.** `fe/src/app/chu-quan/khoan-chi/page.tsx`, `fe/src/app/chu-quan/_components/khoan-chi.tsx`,
`fe/src/app/chu-quan/_components/khoan-chi.css`, `fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx`.
Nếu phát sinh đổi phép tính tiền, dữ liệu ghi hoặc hợp đồng thì chuyển phần đó sang bước L2, không giữ nhãn L1.

**Nhận việc.**

**Kết quả 2026-11-22** (thực hiện: Codex, duyệt: Claude; worktree `../lean_wt/KC-08`, nhánh `codex/KC-08` từ `8d71696`).
Đổi `khoan-chi.tsx`, `khoan-chi.css`, `khoan-chi.test.tsx`; `page.tsx` không cần đổi. Khối chọn ngày còn tiêu đề, dòng khoảng
ngày và bốn nút *7/10/14/30 ngày*; mục chi xếp một cột theo thứ tự backend; Sổ khoản chi và Các khoản chi có nút Ẩn/Hiện cùng
hàng tiêu đề; mỗi mục có nút *Lọc ngày* mở hai ô ngày, hiện *Đang lọc*, thu gọn giữ lọc. Codex: lint, typecheck, `npm test`
56/56 tệp · 858/858 ca, `check-fe-rules` PASS; gate trong sandbox đỏ ở bước build vì Turbopack không được mở cổng. Hai ca cũ
chỉ đổi thao tác (tên nút *7 ngày*, thêm bấm *Lọc ngày*), không nới assertion. Claude đọc diff, chạy app thật trong worktree
(`make dev`, database dev) bằng Playwright: 320/390/1024/1440 px `scrollWidth = innerWidth`, năm mục cùng lề trái, *10 ngày* →
`?tu=2026-11-13&den=2026-11-22` và `aria-pressed=true`, ẩn Sổ khoản chi và Các khoản chi đúng vùng, *Lọc ngày* mở
`aria-expanded=true`, 0 lỗi JS; xem ảnh 390 px. Kịch bản, ảnh, báo cáo: `../lean_wt/_claude_logs/KC-08/`.

<a id="kc-09"></a>
## KC-09 — FE: các bảng khoản chi theo ngày và lịch sử khoản con

**Vì sao.** FE hiện nhóm Các khoản chi theo mục, thiếu bảng tổng ngày và lịch sử chi độc lập. Dữ liệu gốc
đã đủ; chỉ tổng ngày và cách đọc ngoài kỳ cần KC-05.

**Acceptance.**

- A1 — Sổ khoản chi hiện một dòng/ngày: ngày, số khoản, tổng backend. Các khoản chi hiện một dòng/ngày, mới
  trước; mọi lần chi cùng ngày nằm ngang trong ô, còn tên, nguồn, tiền, người, Sửa/Xoá theo đúng mã.
- A2 — Mọi mục ngoài nguyên liệu, gồm Điện/nước, Đồ dùng nếu dữ liệu quán có, dùng cùng bảng ngày và bảng khoản
  con ba cột. Bấm tên mở chi tiết ngay dưới nó, trước dòng kế; ngày chi gần nhất/tổng lấy đúng tập lọc, giữ khoản
  cũ chưa có khoản con và không tạo danh mục mẫu.
- A3 — Lịch sử chi riêng mở/đóng, mặc định bảy ngày đúng mốc KC-01, đổi/đặt lại khoảng và lọc hai đầu được.
  Bộ lọc mục giao với bộ lọc chung; lịch sử riêng không bị lọc chung che. Khoảng sai/rỗng khác lỗi đọc.
- A4 — Test gửi tổng backend khác phép cộng fixture để phát hiện FE tự cộng; test cùng ngày nhiều mục, nhiều
  khoản cùng khoản con, sửa/xoá/chuyển ngày cập nhật đúng các bảng và tổng. Giữ nguồn, từng mã và thứ tự mới trước.
- A5 — 320/390 px cuộn bảng bên trong, đầu khối cùng hàng; Hiện/Ẩn giữ lọc. `fe-check`, `check-fe-rules` và gate
  đạt; kiểm trực quan bằng trang thật với API.

**Phạm vi.** `fe/src/app/chu-quan/_components/khoan-chi.tsx`,
`fe/src/app/chu-quan/_components/du-lieu-khoan-chi.ts`, `fe/src/app/chu-quan/_components/khoan-chi.css`,
`fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx`, `fe/src/lib/api/schema.ts` (sinh từ hợp đồng đã duyệt).

**Nhận việc.**

<a id="kc-10"></a>
## KC-10 — FE: các hộp thao tác dùng cửa thật

**Vì sao.** CRUD đã chạy; thiếu danh sách loại trong hộp Loại chi, lịch sử sửa tiền ngoài kỳ và các nhánh thêm
ngày nhập/thêm khoản con kèm tiền theo mẫu. Không viết lại cửa tiền chỉ vì đổi hình hộp thoại.

**Acceptance.**

- A1 — Hộp Loại chi đọc danh mục thật, thêm mục bắt buộc chủ quán chọn nguồn; đổi tên giữ tiền và có lý do.
  Xoá xác nhận/lý do; lỗi mục/khoản con còn chi ngoài kỳ được hiển thị từ backend, không tự cho phép bằng tập đang lọc.
- A2 — Sửa tiền đã ghi đọc đúng lịch sử mục/khoản con ngoài kỳ; chọn khoản mở đúng mã/số tiền/ngày. Tên chưa lưu
  được bảo vệ. Sửa dùng `updateExpense`, không tạo dòng mới; chặn đóng/bấm lặp lúc ghi và trả focus sau đóng.
- A3 — Ngày nhập và thao tác với danh mục liên hệ chỉ mở sau KC-06, theo Q-KC-02/Q-KC-05. Khoản cũ thiếu mã/ngày
  vẫn hiện rõ, không điền giả. Tải lại phản ánh kết quả, không đổi lịch sử sử dụng khi chỉ sửa tiền.
- A4 — Thêm khoản con kèm tiền theo đúng Q-KC-06: bỏ tiền thì chỉ thêm danh mục; có tiền thì không ghi trùng.
  Với hai lệnh, test danh mục thành công nhưng chi bị từ chối/mất phản hồi, giữ mã đã tạo và hướng đọc lại; không
  tự gửi lại khi chưa rõ kết quả. Với lệnh nguyên khối, test lỗi/nhấn lặp theo hợp đồng gộp được duyệt.
- A5 — Test thiếu lý do, ngày tương lai, ngày đã đối soát, đổi mục bỏ khoản con cũ, 401/403, dữ liệu bị xoá ở
  phiên khác, mất phản hồi và ghi thành công nhưng đọc lại lỗi. Giữ nháp/cảnh báo; `fe-check` và gate đạt.

**Phạm vi.** `fe/src/app/chu-quan/_components/khoan-chi.tsx`,
`fe/src/app/chu-quan/_components/du-lieu-khoan-chi.ts`, `fe/src/app/chu-quan/_components/khoan-chi.css`,
`fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx`, `fe/src/lib/api/schema.ts` (chỉ sinh từ hợp đồng).

**Nhận việc.**

<a id="kc-11"></a>
## KC-11 — FE: nguyên liệu và hai lịch sử thật

**Vì sao.** Kho và Nguyên liệu đã đọc được ngày nhập gần nhất, lượng và sổ từng thứ; Khoản chi chưa dùng chúng.
Thiếu quan hệ phải được giải quyết trước khi nối các màn.

**Acceptance.**

- A1 — Bảng nguyên liệu có ba cột cùng hàng; liên hệ theo mã đã duyệt, không so tên. Ngăn chi tiết nằm ngay dưới
  dòng được bấm, chỉ một ngăn mở theo mẫu. Ngày nhập và số còn đúng nguồn Q-KC-02/Q-KC-03, không đổi theo lọc tiền;
  tổng chi theo kỳ lấy backend. Chưa có liên hệ/số liệu thì hiện rõ, không lấy số mẫu.
- A2 — Lịch sử sử dụng lấy `getSupplyItem.entries` loại `used` hoặc cửa đọc được KC-01 duyệt; ngày mới trước,
  mỗi ngày một hàng, các nguyên liệu và chuỗi lượng/đơn vị nằm ngang. Chọn một nguyên liệu hoặc tất cả, bấm tên
  đồng bộ lựa chọn theo mẫu. Chi tiết có lịch sử riêng bảy ngày/đổi khoảng/đặt lại và không kéo dữ liệu ngoài mã.
- A3 — Dùng API từng thứ hiện có khi đủ; nếu cần tối ưu lịch sử tổng, Claude lập thay đổi hợp đồng BE riêng
  trước, không tạo migration vì thêm bảng hiển thị. Lỗi một truy vấn không được biến thành “chưa có sử dụng”
  hoặc trình bày tập một phần như đầy đủ. Không cộng/chuyển chuỗi lượng sang số thực ở FE.
- A4 — Lịch sử mua đọc khoản chi, nhóm theo ngày nhập đã duyệt; mỗi lần vẫn có ngày chi, tiền, người, nguyên
  liệu. Khoản thiếu ngày nhập có hàng rõ; không suy số lượng mua từ tiền. Chọn nguyên liệu và nhảy tới lịch sử
  mở được khối đang ẩn; bộ lọc tiền chung không che lịch sử này.
- A5 — Hai lịch sử cạnh nhau màn rộng, xếp dọc màn hẹp, nút Hiện/Ẩn độc lập và giữ lọc. Ghi/sửa lượng ở trang
  Nguyên liệu rồi quay lại, sửa/xoá khoản chi và đổi tên đều đọc lại đúng nguồn; kiểm cache `supply-items`,
  `supply-stock`, `expenses` khi liên quan. Không chép xoá lịch sử lượng theo xoá khoản con trong HTML.
- A6 — Test sổ rỗng, chưa đơn vị, hiệu số âm, nhiều nguyên liệu một ngày, khoản cũ thiếu mã/ngày; 320/390 px
  không tràn trang, bảng tự cuộn. Chạy test Kho/Nguyên liệu/Khoản chi liên quan, `fe-check` và gate.

**Phạm vi.** `fe/src/app/chu-quan/_components/khoan-chi.tsx`,
`fe/src/app/chu-quan/_components/du-lieu-khoan-chi.ts`, `fe/src/app/chu-quan/_components/khoan-chi.css`,
`fe/src/app/chu-quan/_components/du-lieu-kho.ts`, `fe/src/app/chu-quan/_components/du-lieu-nguyen-lieu.ts`,
`fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx`, `fe/src/app/chu-quan/kho/kho.test.tsx`,
`fe/src/app/chu-quan/nguyen-lieu/nguyen-lieu.test.tsx`, `fe/src/lib/api/schema.ts` (chỉ sinh từ hợp đồng).

**Nhận việc.**

<a id="kc-12"></a>
## KC-12 — FE: dự tính theo luật đã chốt

**Vì sao.** Chép `stockEstimates` vào state/localStorage sẽ tạo số khác giữa máy và mất dữ liệu khi tải lại.
Chỉ dựng phép nhập/hiện sau khi nguồn và cách lưu/tính đã được duyệt.

**Acceptance.**

- A1 — Cột ước tính, mức dùng/ngày và hộp Sửa dự tính đọc/ghi qua KC-07 theo Q-KC-03/Q-KC-04; nếu dùng mức tính
  từ sổ thì không giả có ô nhập trực tiếp. Nhãn nói đúng nguồn/mốc số, không nói số minh hoạ là dữ liệu thật.
- A2 — Thiếu lượng, thiếu đơn vị, mức dùng 0, hiệu số âm và số lẻ hiển thị đúng trạng thái hợp đồng; không
  chia cho 0, không tự làm tròn/đổi đơn vị/sửa hiệu số. Kết quả dự tính không thay nhắc POS hoặc tự tắt món.
- A3 — Nếu có ghi: lý do/vết theo hợp đồng, chống bấm lặp, lỗi giữ nháp và không tự gửi lại; đọc lại sau tải
  trang/máy khác giữ kết quả nguồn. Thay số lượng ngày cập nhật số suy ra đúng chính sách đã duyệt.
- A4 — Test trước của Claude gồm các trạng thái biên và cỡ 320/390 px; `fe-check`, `check-fe-rules` và gate đạt.
  Nếu chủ repo không duyệt dự tính, không đánh dấu chức năng đã làm: Claude sửa phạm vi/acceptance lane trước.

**Phạm vi.** `fe/src/app/chu-quan/_components/khoan-chi.tsx`,
`fe/src/app/chu-quan/_components/du-lieu-khoan-chi.ts`, `fe/src/app/chu-quan/_components/du-lieu-nguyen-lieu.ts`,
`fe/src/app/chu-quan/_components/du-lieu-kho.ts`, `fe/src/app/chu-quan/_components/khoan-chi.css`,
`fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx`, `fe/src/lib/api/schema.ts` (chỉ sinh từ hợp đồng).

**Nhận việc.**

<a id="kc-13"></a>
## KC-13 — Nghiệm thu trang thật và bàn giao

**Vì sao.** Test riêng từng tầng không chứng minh trang đang đọc đúng dữ liệu hoặc giống bản được giao.
Lượt này kiểm tích hợp, không dùng làm nơi sửa cùng lúc DB/BE/FE.

**Acceptance.**

- A1 — Claude dùng môi trường thử riêng có backend/database, đối chiếu từng dòng bảng tính năng với UI và
  phản hồi API; đọc danh mục hiện có của quán để kiểm cách bày. Không ghi/xoá khoản thật chỉ để thử giao diện.
- A2 — Kịch bản thử có nhiều khoản cùng ngày, hai nguồn, thiếu khoản con/ngày nhập, ngày đã đối soát, lịch sử
  ngoài kỳ chung, lượng lẻ/âm, mức dùng 0 và dữ liệu rỗng. Ghi/sửa/xoá chỉ tác động khoản đã chọn; đọc lại tiền
  theo ngày/mục/khoản con khớp backend; sổ lượng không sinh tiền hoặc tự đổi theo khoản bán.
- A3 — So bản HTML mới ở 320/390/1024/1440 px: ba cột nguyên liệu, ngăn đúng dòng, một hàng/ngày, khoản nằm
  ngang trong ô, hai lịch sử và các nút/ẩn/lọc. Kiểm bàn phím/focus, tải lại, mạng lỗi, phiên hết hạn; không dữ liệu mẫu.
- A4 — Ghi lệnh/output và kết quả kiểm trực quan; Claude chạy `db-check`, `be-check`, `fe-check` theo phần đã
  triển khai, cùng gate tích hợp. Mục bị chặn hoặc khác mẫu có quyết định rõ, không coi gate tài liệu là nghiệm
  thu code. Lỗi thuộc tầng nào trả về phiếu tầng ấy, không mở rộng bước nghiệm thu để sửa cả ba.

**Phạm vi.** `fe/src/app/chu-quan/khoan-chi/khoan-chi.test.tsx` (kịch bản FE nếu cần bổ sung),
`work/backlog_KC.md`, `work/backlog.md`, `docs/product/4-fe/01-khung-fe.md` (Claude ghi kết quả/owner).
Đọc và chạy các script kiểm hiện có; không sửa migration/backend trong bước nghiệm thu.

**Nhận việc.**

<a id="kc-14"></a>
## KC-14 — FE: gỡ trang Kho và Nguyên liệu

**Vì sao.** Chủ repo chọn 2026-11-22: trang Khoản chi thay cả hai trang (U-120). Gỡ chỉ sau khi KC-11 và KC-12 đã đưa đủ
việc của hai trang về Khoản chi, để chủ quán không mất lối ghi lượng.

**Acceptance.**

- A1 — Thanh điều hướng của chủ quán không còn *Kho* và *Nguyên liệu*; `/chu-quan/kho` và `/chu-quan/nguyen-lieu` chuyển
  về `/chu-quan/khoan-chi` (giữ `?thu=` nếu mở thẳng một nguyên liệu), không trả 404.
- A2 — Mọi việc của hai trang cũ làm được ở Khoản chi: thêm thứ, đặt đơn vị lần đầu, ghi/sửa lượng mua vào · đã dùng có
  lý do, đặt tỉ lệ nhắc, xem hai tổng, hiệu số, lần nhập gần nhất. Test cũ của hai trang chuyển sang Khoản chi, không xoá
  ca nào mà không có ca thay.
- A3 — Dòng `/chu-quan/kho` và `/chu-quan/nguyen-lieu` ở `docs/product/4-fe/01-khung-fe.md` đổi theo trong cùng thay đổi;
  `fe-check`, `check-fe-rules`, gate đạt.

**Phạm vi.** `fe/src/app/chu-quan/kho/`, `fe/src/app/chu-quan/nguyen-lieu/`, `fe/src/app/chu-quan/_components/thanh-dieu-huong.tsx`,
`fe/src/app/chu-quan/_components/muc-chu-quan.ts`, `docs/product/4-fe/01-khung-fe.md`. Xoá tệp do chủ repo chạy lệnh.

**Nhận việc.**

<a id="cau-hoi-mo"></a>
## Câu hỏi mở — đã có lời 2026-11-22

Cả sáu câu dưới đây đã có lời (bảng *Lời chủ repo 2026-11-22* ở đầu sổ). Phần dưới giữ nguyên câu hỏi và đề xuất của
Codex làm lịch sử; **lời thắng đề xuất** chỗ nào hai bên khác nhau.

Các mã **Q-KC** dưới đây là mã tham chiếu trong sổ và **chưa có đáp án**. Claude đã chuyển cả sáu sang
`docs/product/99-unknowns.md` ngày 2026-11-22: Q-KC-01 = **U-120**, Q-KC-02 = **U-121**, Q-KC-03 = **U-122**,
Q-KC-04 = **U-123**, Q-KC-05 = **U-124**, Q-KC-06 = **U-125** — trạng thái mở/đóng chỉ đọc ở đó. Codex không đóng câu hỏi.
Đề xuất ở đây không có hiệu lực trước khi được duyệt. Các bước phụ thuộc gián tiếp cũng chờ, kể cả khi không
chép lại mã câu hỏi trong mọi ô.

<a id="q-kc-01"></a>
**Q-KC-01 — Khoản con “nguyên liệu” có phải cùng một thứ với `supply_item` không, và nhận diện nhóm ấy bằng gì?**
Một `supply_item` có thể xuất hiện ở nhiều mục chi không; đồ dùng như túi/hộp cũng nằm trong danh mục lượng thì
được bày kiểu nào? Hai danh mục trùng tên chưa đủ để nối. **Ai trả lời:** chủ quán/chủ repo xác nhận ý nghĩa và
cách dùng; Claude chốt quan hệ, phân loại và cách chuyển dữ liệu cũ. **Chặn:** KC-01 phần danh mục; KC-02,
KC-03/KC-04 khi dùng quan hệ, KC-06/KC-07, KC-11 và phần liên quan của KC-10/KC-12; KC-13 nghiệm thu toàn trang.
**Đề xuất:** nếu cần nối, dùng định danh được xác nhận, không so tên hoặc tự gán theo chữ “nguyên liệu”; chưa
xác nhận thì giữ trạng thái chưa liên hệ, không giả hai danh mục đã hợp nhất.

<a id="q-kc-02"></a>
**Q-KC-02 — “Ngày nhập” của lịch sử mua cần lưu riêng ở khoản chi, hay đọc từ sổ lượng, và liên hệ những lần đó thế nào?**
§8.4 đã nói lúc hàng mua về, còn `entry_date` hiện là tổng theo ngày; §8.10 dùng `paid_date` cho tiền. Khi nhập
nhiều lần/ngày, mua nợ, trả nhiều lần hoặc một lần trả cho nhiều hàng thì một khoản chi có mấy ngày nhập? Ngày
nhập có bắt buộc, có được sửa ở ngày tiền đã đối soát, và dữ liệu cũ thiếu ngày bày thế nào? **Ai trả lời:** chủ
quán/chủ repo chốt cách ghi; Claude chốt quan hệ, kiểm ngày/vết và chuyển tiếp. **Chặn:** KC-01 phần ngày nhập,
KC-03, KC-06 phần ngày nhập, KC-10/KC-11 và nghiệm thu KC-13. **Đề xuất:** giữ thiếu ngày thành thiếu dữ liệu;
không lấy ngày chi/lúc tạo thay ngày hàng về, không sinh thêm khoản tiền khi liên hệ với sổ lượng.

<a id="q-kc-03"></a>
**Q-KC-03 — “Số hàng còn” trên Khoản chi là hiệu số mua−dùng hiện có, hay số chủ quán kiểm đếm nhập riêng?**
Nếu là số kiểm đếm thì số nào được dùng để dự tính/nhắc, có mốc và lịch sử riêng không, và có làm thay đổi sổ
mua/dùng không? Hiệu số hiện nhận âm, mẫu chỉ nhận số còn không âm; không được tự kẹp về 0. **Ai trả lời:** chủ
quán/chủ repo quyết ý nghĩa; Claude thiết kế cách giữ một nguồn đúng và đối chiếu I-025/I-026. **Chặn:** KC-01
phần số còn, KC-04, KC-07, KC-11/KC-12 và nghiệm thu KC-13. **Đề xuất:** cân nhắc dùng hiệu số hiện có để tránh
hai đáp số, nhưng phải duyệt cả nhãn và các trường hợp âm/thiếu trước khi triển khai.

<a id="q-kc-04"></a>
**Q-KC-04 — Mức dùng/ngày do người gõ hay tính từ sổ, và ước tính còn dùng được hiểu/hiển thị thế nào?**
Nếu tính thì lấy khoảng nào, ngày thiếu khác ngày ghi 0 ra sao; nếu gõ thì lưu theo nguyên liệu nào, ai sửa,
mốc nào có hiệu lực? Dùng đơn vị sổ hay đơn vị riêng, xử lý chưa đơn vị/mức 0/số còn âm, làm tròn và lời báo
thế nào? Đây không phải `reminder_ratio`. **Va với lời đã có (Claude thêm khi duyệt, 2026-11-22):** chủ quán đóng `U-045`
2026-09-15 bằng lời *máy không kết luận thiếu*, và ADR-103 điểm 4 cùng dòng `/chu-quan/kho` của khung FE ghi trang kho
**không có *dự kiến hết***; một con số "còn dùng N ngày" có thể bị đọc là chính dự kiến ấy, nên phải hỏi chủ quán
có muốn mở lại không, chứ không chỉ chọn công thức. **Ai trả lời:** chủ quán/chủ repo chốt nghĩa và quyền nhập; Claude
chốt công thức, độ chính xác, hợp đồng và ranh giới với nhắc POS hiện hành. **Chặn:** KC-01 phần dự tính,
KC-04, KC-07, KC-12 và nghiệm thu KC-13. **Đề xuất:** tách lời ước tính khỏi lời nhắc kiểm tra, hiện chưa tính
được khi thiếu điều kiện; không chọn sẵn cách lấy mức dùng từ lịch sử hoặc từ số suất bán.

<a id="q-kc-05"></a>
**Q-KC-05 — Khi khoản con có liên hệ sổ lượng, đổi tên/xoá ở Khoản chi tác động tới sổ ấy ra sao?**
Chỉ bỏ mục chi/liên hệ hay cũng ngừng dùng thứ trong sổ; nếu tên hai bên khác nhau thì tên nào hiện? HTML xoá
cả lịch sử dùng theo tên, trong khi sổ lượng chưa có chức năng xoá/ngừng dùng và cần giữ dấu người/ngày.
**Ai trả lời:** chủ quán/chủ repo chốt hành vi mong muốn; Claude thiết kế vòng đời phù hợp luật giữ lịch sử.
**Chặn:** KC-01 phần vòng đời, KC-02, KC-06, KC-10/KC-11 và nghiệm thu KC-13. **Đề xuất:** giữ nguyên lịch sử
tiền/lượng theo mã và xử lý việc bỏ liên hệ riêng; không suy lệnh xoá khoản con là quyền xoá sổ lượng.

<a id="q-kc-06"></a>
**Q-KC-06 — Thêm khoản con kèm tiền mua cần một lần bấm thành công toàn bộ, hay chấp nhận hai bước rõ ràng?**
Mẫu cho nhập tiền tuỳ chọn trong hộp thêm; app hiện thêm tên rồi Ghi chi. Nếu thêm tên xong nhưng ghi tiền lỗi
hoặc mất phản hồi thì giữ tên, báo và đọc lại thế nào? **Ai trả lời:** chủ repo chọn trải nghiệm; Claude thiết
kế giao dịch và cơ chế xử lý kết quả chưa rõ. **Chặn:** KC-01 phần thao tác gộp, nhánh tương ứng KC-06,
KC-10 và nghiệm thu KC-13. **Đề xuất:** dùng hai cửa hiện có nếu chủ repo chấp nhận hai bước; chỉ thêm API
nguyên khối khi yêu cầu thành công cùng nhau được duyệt. Không tự gửi lại tiền hoặc tự xoá tên đã tạo để che lỗi.

[html]: ../docs/product/4-fe/thiet_ke/chu_quan/khoan-chi/khoan-chi.html
[lich-su]: backlog.md
[yt]: backlog_YT.md
[rules]: ../CLAUDE.md
[readme]: ../README.md
[facts]: ../master_plan/shop-facts.md
[adr]: ../docs/decisions.md
[api]: ../docs/product/3-be/openapi.yaml
[luoc-nl]: ../docs/product/2-db/12-luoc-do-nguyen-lieu.md
[luoc-chi]: ../docs/product/2-db/15-luoc-do-khoan-chi.md
[khung-fe]: ../docs/product/4-fe/01-khung-fe.md
[db-chi]: ../db/migrations/20261014180000_khoan_chi.up.sql
[db-ct]: ../db/migrations/20261024140000_khoan_chi_chi_tiet.up.sql
[db-nl]: ../db/migrations/20260930100000_so_nguyen_lieu.up.sql
[db-ti-le]: ../db/migrations/20261015130000_ti_le_nhac_nguyen_lieu.up.sql
[route-chi]: ../be/internal/khoanchi/handler.go
[route-nl]: ../be/internal/nguyenlieu/handler.go
[svc-chi]: ../be/internal/khoanchi/service.go
[catalog]: ../be/internal/khoanchi/catalog.go
[sql-chi]: ../be/internal/khoanchi/sql/doc.sql
[sql-loai]: ../be/internal/khoanchi/sql/doc_loai.sql
[sql-con]: ../be/internal/khoanchi/sql/doc_khoan_con.sql
[sql-nl]: ../be/internal/nguyenlieu/sql/doc.sql
[sql-so]: ../be/internal/nguyenlieu/sql/doc_so.sql
[page-chi]: ../fe/src/app/chu-quan/khoan-chi/page.tsx
[fe-chi]: ../fe/src/app/chu-quan/_components/khoan-chi.tsx
[hook-chi]: ../fe/src/app/chu-quan/_components/du-lieu-khoan-chi.ts
[css-chi]: ../fe/src/app/chu-quan/_components/khoan-chi.css
[fe-kho]: ../fe/src/app/chu-quan/_components/kho.tsx
[fe-nl]: ../fe/src/app/chu-quan/_components/nguyen-lieu.tsx
[hook-nl]: ../fe/src/app/chu-quan/_components/du-lieu-nguyen-lieu.ts
