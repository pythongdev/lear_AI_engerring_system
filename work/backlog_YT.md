<a id="top"></a>
# Sổ mô tả — trang Yêu thích của khách (`YT-01`…`YT-07`)

Trạng thái chỉ ở `work/backlog.md`, do Claude giữ; sổ này không giữ trạng thái. Mở 2026-11-18, `T-348`.
Mỗi entry là mô tả để giao bước, không phải lời cho phép làm ngay; **Nhận việc** để trống tới lúc nhận.

**Lời chủ repo 2026-11-18** (nguyên văn): *"hãy đưa ra các step để tạo page trên từ data base, be và fe, hãy tạo
backlog riêng hãy cập nhật dữ liệu dựa trên dữ liệu thật đang chạy của quán. yêu cầu codex làm bạn kiểm tra"*, rồi
*"thiết kế giống file html trên. nhưng dữ liệu cần được cập nhật theo database của quán"* — "file html trên" là
`docs/product/4-fe/thiet_ke/khach_hang/favourite/favourite.html`.

**Cách Claude đọc lời ấy (suy ra, chưa phải lời chủ quán):**

1. Giao diện theo `favourite.html`: món đã thả tim kèm số lượng và nút thêm giỏ, *Bộ món riêng* khách tự chọn và đặt
   tên, *Lưu thành bộ* / *Bộ đã lưu*, *Thêm tất cả vào giỏ*. Bản thứ hai `mon-quen.html` (T-346) không phải bản dựng.
2. "Dữ liệu theo database của quán" = món, combo, lựa chọn và giá đọc từ app đang chạy (`GET /menu`, giá qua
   `POST /price-quotes` — hàm giá duy nhất `docs/product/3-be/03-ham-gia.md`), không chép từ `shop-facts.md` §4.3.
   Hai nguồn đang lệch: database có nhóm *Nhân* (Chay · Thịt · Thịt + mộc nhĩ · Mộc nhĩ) và *Lượng nhân*, còn §4.3 ghi
   Chay · Thịt thường · Thịt nhiều. Lane này theo database; phiếu `prompt/t-345.md` (chép giá §4.3, chưa ai làm) bị
   `YT-01` thay.
3. "Từ database, BE và FE" = món yêu thích và bộ món của khách **lưu theo tài khoản khách** (ADR-131), không chỉ
   trên trình duyệt. Khách chưa đăng nhập: **mời đăng nhập, không lưu trên máy** (chủ repo chọn 2026-11-19, đóng U-119).
4. Giá **không bao giờ** được lưu cùng món yêu thích: một dòng yêu thích có đúng hình `PriceLineRequest` của hợp đồng
   (món + `option_ids`, hoặc combo + `portions`, cộng `quantity`), giá tính lại mỗi lần đọc. Tổng của *Bộ món riêng*
   là tổng giá từng dòng, không phải giá combo và không giảm giá — bản thiết kế ghi *"Tổng giá minh hoạ của các món
   đã chọn"*. Bộ món riêng không phải combo của quán và không đi vào bảng combo.
5. Không dựng *đặt lại đơn trước* (U-106) hay xoá tài khoản (U-108); khi U-108 có lời thì dữ liệu yêu thích đi theo.

**Chung cho mọi bước.** Đọc `CLAUDE.md`, chạy `./scripts/brief.sh`, đọc entry và các owner ở **Đứng trên**. Claude
giữ thiết kế, ADR, unknowns, bất biến, trạng thái và viết test hồi quy trước ở bước L2; Codex thi công từng phiếu
trong worktree riêng `../lean_wt/YT-XX`, nhánh `codex/YT-XX`; Claude đọc diff thật, chạy lại gate, đưa về cây chính
(`docs/prompt-guideline.md` §6.1). Không gộp DB · BE · FE trong một phiếu. Codex không với tới Docker: `db-check`,
`be-check` và chạy trình duyệt do Claude chạy.

| Bước | Việc | Mức | Ai | Đứng trên | Chặn bởi |
|---|---|:--:|---|---|---|
| YT-01 | Bản thiết kế `favourite.html` dùng menu và giá thật của app đang chạy | L1 | Codex làm, Claude duyệt | — | — |
| YT-02 | Thiết kế: lưu gì, ở đâu, đọc giá thế nào, món ngừng bán thì sao — ADR-145 | L2 | Claude, chủ repo duyệt | YT-01 | — |
| YT-03 | Lược đồ: bảng món yêu thích và bộ món của khách | L2 | Claude test trước, Codex làm | YT-02 | — |
| YT-04 | Hợp đồng API và backend: đọc, thả tim, bỏ tim, đổi số lượng, tạo/sửa/xoá bộ | L2 | Claude test trước, Codex làm | YT-03 | — |
| YT-05 | FE: trang Yêu thích theo `favourite.html`, đọc thật, giá qua hàm giá, thêm vào giỏ nháp | L2 | Claude test trước, Codex làm | YT-04 | — |
| YT-06 | FE: nút tim trên thực đơn và trang chi tiết món/combo | L1 | Codex làm, Claude duyệt | YT-05 | — |
| YT-07 | Nghiệm thu trên app chạy: so với bản thiết kế, 360px và 430px, sáng/tối | L1 | Claude | YT-06 | — |

<a id="yt-01"></a>
## YT-01 — Bản thiết kế dùng menu và giá thật của app đang chạy

**Vì sao.** `favourite.html` còn món bịa (*Bánh Chay* 18.000đ, *Combo Đầy Đặn* 42.000đ) và hộp *Tạo bộ món riêng*
chỉ cho chọn ba món ấy. Chủ repo cần xem bản thiết kế với đúng món, đúng lựa chọn, đúng giá của database quán, và
chính bản ấy là khuôn cho YT-05.

**Nguồn dữ liệu.** Claude chụp 2026-11-18 từ backend `localhost:8080` (database `127.0.0.1:5433`): `GET /menu` và
`POST /price-quotes` cho mỗi combo ở lựa chọn mặc định. Bản chụp ngoài repo:
`../lean_wt/_claude_logs/YT-01/menu.json` · `combo-quotes.json`. Giá món lẻ lấy từ bảng `prices` của chính
`GET /menu`; giá combo lấy từ kết quả `price-quotes`, không tự cộng phụ thu.

**Acceptance.**

- A1 — Script có một danh mục duy nhất nhúng từ bản chụp, ghi nguồn và ngày; mọi món, combo, nhóm lựa chọn và tên
  lựa chọn khớp `menu.json` (lệnh `node` in bảng, đối chiếu tự động với `menu.json`). Không còn `Bánh Chay`,
  `Đầy Đặn`, `18000`, `42000`, `itemLabel`.
- A2 — Một dòng yêu thích chỉ giữ `menu_item_id` + `option_ids` hoặc `menu_combo_id` + `portions`, cộng `qty`;
  giá luôn tra từ danh mục (dò dữ liệu lưu trong localStorage không có trường giá).
- A3 — Thẻ món hiện tên lựa chọn (ví dụ *Thịt · Nhiều nhân*); món có nhóm lựa chọn đổi được lựa chọn trên thẻ và
  trong hộp tạo/sửa bộ món, giá dòng và tổng đổi theo; nhóm có `prerequisite_option_ids` chỉ hiện khi điều kiện đủ
  (chọn *Chay* thì không hiện *Lượng nhân*). Hai dòng cùng món khác lựa chọn là hai dòng.
- A4 — Tab lọc *Tất cả · Món lẻ · Combo* theo nhóm của database; giữ chữ *Bộ món riêng*. Khoá localStorage mới, dữ
  liệu khoá cũ không hiện lại.
- A5 — Không hỏng T-337 (chân trang cuộn theo nội dung, *Thêm tất cả vào giỏ* thêm mọi món); sáng/tối, đổi hồ sơ
  khách, lưu/sửa/xoá bộ món vẫn chạy; không cuộn ngang ở 360px và 430px (Claude chạy trình duyệt).
- A6 — `node --check` trên script trích ra, `git diff --check` sạch, `./scripts/gate.sh` xanh.

**Phạm vi.** Chỉ `docs/product/4-fe/thiet_ke/khach_hang/favourite/favourite.html`. Bản trong cây chính đang có phần
Việt hoá và T-337 chưa commit; Claude chép bản ấy vào worktree trước khi giao.

**Nhận việc.** Codex trong `../lean_wt/YT-01`, phiếu và báo cáo ở `../lean_wt/_claude_logs/YT-01/`.

**Kết quả 2026-11-18** (thực hiện: Codex, duyệt: Claude; worktree `../lean_wt/YT-01`, nhánh `codex/YT-01` từ `b635395`).
Tệp có hằng `MENU_SNAPSHOT` nhúng từ bản chụp; dòng yêu thích chỉ giữ id, lựa chọn, số lượng; combo không có ô đổi lựa
chọn, đổi khác mặc định thì hiện *Giá tính lại ở giỏ*; khoá `customer-favourite-design-v3`. A1 · A2 — `node` đối chiếu:
*khớp 15/15*, *33/33 ô giá đúng cả khi đảo thứ tự option_ids*, *default_quote_vnd khớp 7/7*; `grep` không còn
`Bánh Chay` · `Đầy Đặn` · `18000` · `42000` · `21000` · `itemLabel`. A3 — `persist` 8/8 dòng không mang tên, giá,
icon. A4 — sandbox Codex chặn Chromium; Claude chạy kịch bản Playwright của Codex trên máy: 20/20 PASS (đổi Thịt·Thường
→ Thịt·Nhiều nhân 4.000đ → 5.000đ, chọn Chay ẩn *Lượng nhân*, tạo/sửa/xoá bộ món riêng, Lưu thành bộ → Bộ đã lưu →
giỏ, Thêm tất cả, hai hồ sơ, sáng/tối, không tràn ở 360px và 430px, không lỗi JS) và xem ảnh chụp. Claude sửa một
chỗ sau duyệt: dấu `·` thừa sau giá của món không có lựa chọn trong hộp tạo bộ. A5 — `.footer` không sticky,
`#add-all` thêm mọi dòng. A6 — `node --check`, `git diff --check` sạch. Kịch bản, ảnh, báo cáo:
`../lean_wt/_claude_logs/YT-01/`.

Phát hiện khi chụp dữ liệu: database đang chạy có một món tên `canh` (id 7, 0đ, không lựa chọn) bên cạnh *Canh bánh
cuốn* — trông như món thử; bản thiết kế giữ nguyên vì theo database. Chủ quán ngừng bán nó ở trang Sản phẩm nếu thừa.

<a id="yt-02"></a>
## YT-02 — Thiết kế lưu món yêu thích theo tài khoản

**Đầu ra.** Một ADR mới trong `docs/decisions.md`, dòng route mới trong `docs/product/4-fe/01-khung-fe.md` (trạng
thái *dự kiến*), và nếu cần một `I-0xx` mới trong `quality/invariants.md`. ADR phải chốt:

- Hình một dòng yêu thích = `PriceLineRequest` không giá (điểm 4 ở trên); trùng món + lựa chọn thì gộp số lượng.
- *Bộ món riêng* và *Bộ đã lưu* là một khái niệm hay hai (bản thiết kế có hai lối vào, cùng dữ liệu: tên + các dòng).
- Món ngừng bán, combo ẩn, lựa chọn ẩn sau khi đã lưu: dòng vẫn giữ, hiện *Hết bán*, không vào giỏ; giá đọc lỗi thì
  hiện lỗi, không hiện giá cũ.
- Bỏ tim là xoá hẳn hay đánh dấu (QD-50 nói về dữ liệu nghiệp vụ; đây là dữ liệu riêng của khách — liên quan U-108).
- Giới hạn: số dòng tối đa, tên bộ tối đa 60 ký tự như bản thiết kế, số lượng tối thiểu 1.
- Ai đọc được: chỉ chính khách của phiên (`/customer-accounts/current/...`); người làm không đọc.
- Khách chưa đăng nhập: theo lời U-119; chưa có lời thì YT-05 dừng ở màn mời đăng nhập và không lưu gì trên máy.

**Acceptance.** Chủ repo duyệt ADR (câu hỏi có lựa chọn); mỗi điểm trên có một câu trong ADR; không đặt tên bảng
hay đường API trước khi ADR chốt.

**Kết quả 2026-11-19** (Claude). `docs/decisions.md` ADR-145, chủ repo chọn *"Duyệt, giao Codex làm"*; U-119 đóng với
*"Mời đăng nhập"* (ghi ở `docs/product/99-unknowns.md` → *Đã có lời giải*). Một chỗ sửa lúc viết test YT-03: chống trùng
dòng tim do cửa ghi backend làm, không phải khoá duy nhất ở database (lựa chọn nằm ở bảng con) — ghi ngay trong ADR-145
điểm 7. Route dự kiến `/khach/yeu-thich` ở `docs/product/4-fe/01-khung-fe.md`. Không thêm bất biến mới: ADR-145 là chỗ
neo, test của YT-03 · YT-04 · YT-05 mang mã bước.

<a id="yt-03"></a>
## YT-03 — Lược đồ món yêu thích và bộ món

**Đứng trên.** ADR của YT-02; `docs/product/2-db/01-quy-uoc-du-lieu.md`; `07-thu-tu-migration.md`.

**Đầu ra.** Một migration up/down mới; file lát mới `docs/product/2-db/29-luoc-do-yeu-thich.md` và một dòng ở §2 của
`CLAUDE.md` (bảng Schema); bước mới ở `07-thu-tu-migration.md`. Khoá ngoại tới `customer_account`, `menu_item`,
`menu_combo`, `menu_option`; không cột giá; ràng buộc *món hoặc combo, không cả hai*; số lượng ≥ 1.

**Acceptance.** Claude viết test DB trước (đỏ): dòng có giá bị từ chối vì không có cột, dòng vừa món vừa combo bị
từ chối, số lượng 0 bị từ chối, khách A không có khoá tới dữ liệu khách B ngoài cột chủ. Codex làm cho xanh; Claude
chạy `./scripts/db-check.sh` và gate. Dựng lại từ số không và chạy down rồi up sạch.

<a id="yt-04"></a>
## YT-04 — Hợp đồng API và backend

**Đứng trên.** ADR của YT-02; `docs/product/3-be/01-hop-dong-api.md`; `02-vai-va-quyen.md`; `03-ham-gia.md`.

**Đầu ra.** Đường mới dưới `/customer-accounts/current/` trong `openapi.yaml` (tăng phiên bản), dòng ma trận quyền
lớp khách, cửa ghi một cửa một ô (Gate 1f), câu sqlc, handler. Đọc trả các dòng kèm trạng thái còn bán; **không trả
giá** — FE gọi `POST /price-quotes` như giỏ. Ghi kiểm món/combo/lựa chọn bằng cùng bước kiểm của hàm giá, không viết
bước kiểm thứ hai.

**Acceptance.** Claude viết test trước (đỏ): không phiên ⇒ 401; khách A không đọc, sửa được của khách B; lựa chọn
không thuộc món ⇒ lỗi cùng mã với `price-quotes`; thả tim trùng gộp số lượng; món ngừng bán vẫn đọc được với cờ
hết bán; bỏ tim rồi đọc không thấy. Codex làm cho xanh; Claude chạy `./scripts/be-check.sh` và gate; Gate 1g xanh.

<a id="yt-05"></a>
## YT-05 — Trang Yêu thích trên FE

**Đứng trên.** Route và component đã ghi ở YT-02 trong `01-khung-fe.md`; `favourite.html` sau YT-01 là khuôn nhìn.

**Đầu ra.** Trang khách theo bố cục `favourite.html` (đầu trang, khối *Bộ món riêng*, tab lọc, thẻ món, chân trang
*Thêm tất cả vào giỏ* cuộn theo nội dung, hộp *Lưu bộ yêu thích* · *Bộ đã lưu* · *Tạo/Sửa bộ món riêng*). Menu từ
`GET /menu`, giá từ `POST /price-quotes`, dữ liệu từ đường YT-04; *Thêm vào giỏ* đổ vào giỏ nháp chung hiện có, giá
tính lại ở giỏ. Lỗi đọc giữ bản cũ kèm mốc và nút Đọc lại như các trang `/khach/…`; 401 theo lời U-119.

**Acceptance.** Claude viết test trước (đỏ): giá hiện bằng đúng kết quả `price-quotes` giả lập, không đọc giá từ dữ
liệu yêu thích; món hết bán không vào giỏ và có nhãn; thêm cả bộ đổ đúng các dòng vào giỏ; mất phản hồi khi ghi báo
chưa rõ kết quả, không gửi lại ngầm. Codex làm; Claude chạy `./scripts/fe-check.sh` và gate.

<a id="yt-06"></a>
## YT-06 — Nút tim trên thực đơn và trang chi tiết

**Đầu ra.** Nút ♥ trên thẻ món của thực đơn web và trên `/thuc-don/[loai]/[id]` (lưu món + lựa chọn đang chọn), điều
hướng khách có mục *Yêu thích*. **Acceptance.** Test: bấm tim lưu đúng hình dòng; bấm lại bỏ tim; khách chưa đăng
nhập theo lời U-119. `fe-check` và gate xanh.

<a id="yt-07"></a>
## YT-07 — Nghiệm thu trên app chạy

Claude chạy `make dev`, đăng nhập tài khoản khách thử, đi hết luồng của `favourite.html` trên app thật ở 360px và
430px, sáng/tối, chụp ảnh đặt cạnh bản thiết kế; đổi giá một món ở trang chủ quán rồi xem trang Yêu thích hiện giá mới.
Lệch so với bản thiết kế thì ghi thành việc riêng, không sửa trong bước này.

[↑ đầu file](#top)
