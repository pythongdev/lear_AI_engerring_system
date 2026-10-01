# Architecture Decisions

Record decisions that future engineers or AI sessions need to understand.

<a id="bang-tong-hop"></a>
## Bảng tổng hợp — mọi quyết định và giả định của repo này

Một dòng cho mỗi mục của file. **Đây là bảng tra, không phải nơi giữ sự thật:** lý do, cái bị bác
và phạm vi áp dụng nằm ở chính mục ấy bên dưới. Cột *Rủi ro* chỉ có nghĩa với một `GĐ` — một
quyết định đã chốt thì không mang mức rủi ro, nó mang một cái ngày và một cái tên.

Hai loại mục, và ranh giới giữa chúng là luật cứng (CLAUDE.md §3.5): **ADR** = có lời người thật ·
**GĐ** = chưa ai trả lời, đang tạm chấp nhận. Không phiên nào được đổi loại của một mục mà không
có câu trả lời mới từ người.

| ID | Nội dung một dòng | Trạng thái | Rủi ro | Chặn việc gì |
|---|---|---|:--:|---|
| **Quyết định về CÁCH VẬN HÀNH REPO** ||||
| ADR-001 | `master_plan/shop-facts.md` là nhà duy nhất của mọi dữ kiện quán | Đã chốt | — | — |
| ADR-002 | Trạng thái hệ thống được **đẩy** vào mỗi phiên (brief) | Đã chốt | — | — |
| ADR-003 | Gate 3 chỉ chặn file git đang theo dõi | Đã chốt | — | — |
| ADR-004 | Nội dung commit do phiên viết; Gate 7 chặn khi quên | Đã chốt | — | — |
| ADR-005 | Tài liệu cũng bị máy chấm: mọi pointer phải mở được | Đã chốt | — | — |
| ADR-006 | Scope chấm ở hai chỗ: brief kêu khi quên dọn, Gate 7b đọc khối commit | Đã chốt | — | — |
| ADR-007 | Mục *Unknowns* có hình dạng máy đọc được | Đã chốt | — | — |
| ADR-008 | Lịch sử git đã chia sẻ thì sửa **tiến**, không viết lại | Đã chốt | — | — |
| ADR-009 | Nhu cầu sản xuất là một **trục riêng**, không phải trạng thái của đơn | Đã chốt | — | — |
| ADR-010 | Gate 8 là hook của **git**, cài bằng `core.hooksPath` | Đã chốt | — | — |
| ADR-011 | Ba mặt dùng chung một miền, và **chỉ POS được ghi** tiến độ | Đã chốt | — | — |
| ADR-012 | Nợ là một **phần riêng** có mục ở cả ba tầng | Đã chốt | — | — |
| ADR-013 | Nội dung mảng ADMIN đi vào **mục riêng có nhãn** | Đã chốt | — | — |
| ADR-014 | `docs/product.md` tách thành folder `docs/product/` | **Đang thi hành** — lượt 4/5 xong 2026-09-03 | — | chỉ còn lượt 5, **chưa chốt** |
| **Quyết định NGHIỆP VỤ — BA-10** ||||
| ADR-015 | Năm kênh bán là danh sách **đóng**; định danh khách khác nhau theo kênh | Đã chốt 2026-08-24→30 | — | — |
| ADR-016 | **POS ở quầy là cửa ghi duy nhất**; quyền gắn với chỗ đứng | Đã chốt 2026-08-30→09-02 | — | — |
| ADR-017 | Sửa và huỷ đơn **không** bị chặn bởi trạng thái; POS quyết từng ca | Đã chốt 2026-09-02 | — | — |
| ADR-018 | Món hết sau khi khách chọn: **POS bàn với khách** | Đã chốt 2026-09-02 | — | thay **GĐ-02** |
| ADR-019 | Không trả được thì **cho nợ**; doanh thu tính **ngày ghi nợ** | Đã chốt 2026-08-31 | — | — |
| ADR-020 | Hoàn tiền: quầy quyết + ghi vết; tính **ngày hoàn** | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-021 | Giờ hẹn bắt buộc cả `pickup` **và** `phone_preorder`; `delivery` có `Đang giao` | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-022 | Doanh thu **hai nguồn**; đối soát **ba nguồn**, ngưỡng **0đ** | Đã chốt 2026-09-01 | — | — |
| ADR-023 | Đổi giá được giữa buổi; mốc khoá giá là **từng dòng**; thành phần suất chờ hết buổi | Đã chốt 2026-09-01 · 09-02 | — | — |
| ADR-024 | MVP **có** lưu vết, phạm vi = thao tác chạm tiền và chạm trạng thái | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-025 | Phụ thu suất trứng **×5** — suất trứng nhân thường **25.000** (S-1) | Đã chốt 2026-08-30 | — | — |
| ADR-026 | Vòng đời việc trạm **bỏ `Đang làm`**, giữ `Đã làm xong, còn ở bếp` | Đã chốt 2026-08-31 · 09-01 | — | **BA-12** đọc trước khi dựng bảng quầy (kèm **S-5**) |
| ADR-027 | Ghép bàn = **một phiên, một hoá đơn**, chỉ ghép sang bàn **trống** | Đã chốt 2026-08-31 | — | — |
| ADR-028 | **Năm trạm**; chủ quán đứng quầy vẫn giữ vai chủ quán | Đã chốt 2026-08-30 | — | — |
| ADR-029 | Suất *đem về* của khách ngồi bàn thuộc **phiên bàn** | Đã chốt 2026-08-31 | — | — |
| ADR-030 | Trả trước: **tiền mặt hoặc VietQR**, POS xác nhận lúc **nhận tiền** | Đã chốt 2026-08-31 | — | — |
| ADR-031 | Ba mảng quản trị **được phép**, nhưng đi **sau** bán hàng | Đã chốt 2026-09-02 | — | mốc xếp lịch cho ADM-01…ADM-52 |
| ADR-032 | Cổng *một mã, hai chỗ, hai trạng thái* chạy **ở mọi lượt** (Gate 1c), không nằm trong `verify.sh` | Đã chốt 2026-09-03 | — | — |
| ADR-033 | Pha 1 chạy theo **kế hoạch riêng** ở `master_plan/`, mã bước là **`P1-XX`**, đầu ra vào **file mới** cạnh `architecture.md` | Đã chốt 2026-09-03 | — | mở khoá **P1-01…P1-12** |
| ADR-034 | Pha 1 có **sổ task riêng** `work/backlog_SD.md` giữ **mô tả**; `work/backlog.md` vẫn giữ **trạng thái** | Đã chốt 2026-09-04 | — | sửa một luật của **ADR-033** |
| ADR-035 | Sở hữu chạy theo **pha**: lược đồ ở **pha 2**, hợp đồng API ở **pha 3**, route ở **pha 4**; **tầng bảo vệ** của từng invariant ở **pha 1** | Đã chốt 2026-09-04 | — | mở khoá **P1-02…P1-12**; sửa một câu của **ADR-014** |
| ADR-036 | Mảng **admin** có sổ task riêng `work/backlog_AD.md` giữ **mô tả**; ranh giới giữa ba sổ nay là **LANE**, không phải pha | Đã chốt 2026-09-04 | — | sửa luật 3 của **ADR-034** |
| ADR-037 | Lượt bán trên **sổ giấy** tính doanh thu **ngày bán** ⇒ ngày còn `N > 0` là ngày **chưa đối soát xong**; ngưỡng **0đ** giữ nguyên | Đã chốt 2026-09-04 | — | sửa câu hệ quả của **I-014**; **U-037** đóng 2026-09-06 — POS/chủ quán, cuối buổi bán hàng |
| ADR-038 | Quán **không có mở ca / đóng ca** ⇒ mốc gom tiền nhỏ nhất là **ngày bán**, và **tiền đầu két gắn vào ngày bán** chứ không vào một biến cố ca | Đã chốt 2026-09-04 | — | **I-021** mới; **U-038** đóng 2026-09-06 — nhập cả bảng mệnh giá lẫn tổng; ADM-01 co lại |
| ADR-039 | `CLAUDE.md` §2.2 có thêm dòng chủ **quy ước code** (pha 2) và Gate 1d (`check-phase-boundary.sh`) chấm máy phần phổ biến nhất của ranh giới pha; §3 có cột **Cưỡng chế bởi**; §8 hết mâu thuẫn "bốn dòng" | Đã chốt 2026-09-06 | — | sửa một câu của **ADR-035** |
| ADR-040 | Trả trước cho đơn đặt trước ngày SAU tính doanh thu vào **ngày GIAO**, không phải ngày nhận tiền; quán nhận đặt trước **tối đa một ngày** | Đã chốt 2026-09-06 | — | công thức đối soát `architecture.md` §6.4 cần thêm một dòng; **U-036** đóng |
| ADR-041 | Đặt tên chủ cho **PT-5** (đường báo đơn web về quầy = **Telegram**) và **PT-2** (nơi hệ thống chạy = **một VPS**) | Đã chốt 2026-09-07 | — | đóng một phần **F-027**; **shop-facts.md §1** giữ tên cụ thể |
| ADR-042 | Mở **bước thứ mười ba** của pha 1 (`P1-13`), nhóm **SẢN XUẤT THEO MẺ**, cho `I-019`/`I-020` — hai mệnh đề mồ côi vì sinh sau khi kế hoạch chia ba nhóm | Đã chốt 2026-09-07 | — | đóng **F-026**; kế hoạch §6/§7/§9 và `03-bao-ve-invariant.md` thêm §4 |
| ADR-043 | Bản **đã commit** của `work/scope.txt` chỉ được chứa comment; pattern là trạng thái phiên chạy, Gate 3 và Gate 7b cùng thi hành | Đã chốt 2026-09-03, thi hành 2026-09-07; cơ chế thay bởi **ADR-063** 2026-09-27 | — | đóng **F-020**; sửa một câu của `CLAUDE.md` §6, §6.1 |
| ADR-044 | `I-021` vào **nhóm TIỀN đã có** (§1 của bảng ba cột), **không** mở nhóm thứ năm; hàng ấy có chủ là bước mới **P1-14** | Đã chốt 2026-09-07 | — | đóng **hẳn F-026**; kế hoạch §6/§7, `03-bao-ve-invariant.md` §1 thêm một hàng và §1.5 |
| ADR-045 | **Bốn ràng buộc kiến trúc ẩn có nhà ở pha 1**, mỗi cái một **dấu hiệu đo được**; ba cái chưa có chủ (*một tiến trình · không hàng đợi · không bộ nhớ đệm*) được chốt ở bước **P1-08** | Đã chốt 2026-09-08 | — | đóng **nốt F-027**; file mới `05-realtime-va-du-phong.md` §2 |
| ADR-046 | Hoàn tiền **chéo phương thức** vào `I-021` bằng **hai hạng tử riêng**; *doanh thu tiền mặt* giữ nguyên nghĩa, vết hoàn tiền ghi thêm **phương thức trả lại** | Đã chốt 2026-09-15 | — | viết lại **I-021**; **U-044** đóng — POS quyết từng ca |
| ADR-047 | **Dừng nhận đơn web khi mất kết nối là quyết định của NGƯỜI, không của đồng hồ**: máy **báo**, **POS quyết**, mở lại bằng **nút** — lật luật 1 của `05-realtime-va-du-phong.md` §3 và một câu *Verification* của `I-008` | Đã chốt 2026-09-16 | — | **U-043** đóng; **U-053** đã đóng 2026-09-25 — chủ quán dùng 5G bấm tắt |
| ADR-048 | **Ba chỗ pha 1 viết hộ pha 2/3 được VIẾT LẠI BẰNG NGÔN NGỮ TẦNG, không được khai thành ngoại lệ**: `architecture.md` §3.1 · §4 · §12.2 giữ nguyên nghĩa, bỏ tên cột · `bảng.cột` · hợp đồng API; `PAT_API` của Gate 1d nới kèm ca hồi quy | Đã chốt 2026-09-20 | — | **F-040** · **F-041** đóng; ô 10 cổng pha 1 tick ⇒ **10/10** |
| ADR-049 | Pha 2 chạy theo **kế hoạch riêng** ở `master_plan/`, mã bước là **`P2-XX`**, đầu ra vào thư mục **mới** `docs/product/2-db/` mở cùng dòng nội dung đầu tiên; năm tầng của pha 1 dịch sang pha 2 thành **ràng buộc · giao dịch · một đường ghi · chỗ cất vết · câu truy vấn** | Đã chốt 2026-09-20 | — | mở khoá **P2-01…P2-14**; chép hình dạng của **ADR-033** |
| ADR-050 | **Năm tầng của pha 1 dịch sang pha 2 thành năm thứ dựng được, mỗi thứ một phép chấm** — ràng buộc thật · ranh giới giao dịch · một đường ghi duy nhất · chỗ cất vết sống độc lập · một câu truy vấn ra 0 dòng; cộng **ba câu pha 2 không được viết ra** (endpoint · route · cơ chế vận hành) và ba luật dịch: không tự hạ tầng · mệnh đề tầng 1 vẫn có câu truy vấn · câu truy vấn chưa bao giờ đỏ là chưa được chứng minh | Đã chốt 2026-09-22 | — | mở khoá **P2-02** và **P2-03**; lane `prompt/DB/` vào Gate 1b |
| ADR-051 | **Lane pha 2 thí điểm: entry ở `work/backlog_DB.md` là hồ sơ thực thi DUY NHẤT của một bước** — Nghiệm thu và Kiểm chứng viết vào entry lúc nhận việc, không còn file prompt riêng bắt buộc; trạng thái chỉ ở `work/backlog.md` (bỏ cột *Trạng thái* của *Mục lục* và dòng *✅ Xong ngày…*); mức và thứ tự chỉ ở kế hoạch §6 | Đã chốt 2026-09-25 | — | thay luật 2 · 3 của `work/backlog_DB.md` (**ADR-034** hình dạng · **ADR-049**) cho lane pha 2; lane khác giữ nguyên tới khi thí điểm được đánh giá |
| ADR-052 | Claude Code và Codex dùng chung luật; AGENTS.md là điểm vào mỏng | Đã chốt 2026-09-25 | — | T-088; giữ lõi Gate 7, phân biệt hook và chạy trực tiếp |
| ADR-053 | **Pha 2 dựng trên nền gì và cái gì chứng minh nó còn đúng** — `P2-12` (có chọn DBMS + phiên bản) vào *Cần xong trước* của năm lát `P2-04`…`P2-08`; khi đã có file migration thì **migration thắng** cho tên · kiểu · ràng buộc, `.md` giữ ý định, lệch ⇒ `F-XXX`, `P2-09` biến phép đối chiếu tên bảng thành lệnh; mỗi quy ước dữ liệu của `P2-03` kèm **một phép kiểm chạy được**, gom vào bộ `P2-11` | **Đã chốt** 2026-09-25 — chủ repo xác nhận luật 2 ý 1 (*code dựng database thắng*); ý 2 · 3 là phần suy ra của phiên | — | T-096; đổi *Cần xong trước* của `P2-04`…`P2-08`; không chọn DBMS |
| ADR-054 | **Claude quyết, Codex thi công** — Claude giữ chọn task, mức, Acceptance, scope, thiết kế, ADR, unknowns, lời chủ quán, duyệt, tích hợp, khối commit; Codex làm theo phiếu trong worktree riêng, không quyết nghiệp vụ, không commit | Đã chốt 2026-09-27 | — | T-100; nối ADR-052; quy trình ở `docs/prompt-guideline.md` §6.1 |
| ADR-055 | **DBMS là PostgreSQL 17** — chọn vì lát bán hàng lõi cần khoá duy nhất chỉ áp cho vài trạng thái, DDL trong giao dịch và kiểu mốc không vướng 2038; loại MySQL 8.4 của `prompt-fullstack.md` §3.4 và SQLite. Quy ước code ở `docs/product/2-db/10-quy-uoc-code.md` | Đã chốt 2026-09-27 (giao cho phiên) | — | mở `P2-04`…`P2-08` |
| ADR-056 | **Hai vế thiếu tầng của F-036** — nước chấm · canh của `I-004` giữ ở **tầng 2** trong giao dịch nổ đơn; *ngừng bán ⇒ không đặt mới được* ở lại hàng `I-009`, **tầng 3** tại cửa tạo lượt gọi; đơn vị của bảng bảo vệ là **vế**, không phải mã | Đã chốt 2026-09-27 (giao cho phiên) | — | `P2-07` (nổ đơn trạm `canh`) |
| ADR-057 | Yêu cầu bảo toàn và khôi phục dữ liệu ở pha 1; cơ chế và kiểm chứng ở pha 5 (F-034) | Đã chốt 2026-09-27 (chủ repo) | — | T-109 — triển khai và nghiệm thu vận hành |
| ADR-058 | **`I-022` vào nhóm VÒNG ĐỜI đã có**, không mở nhóm mới; bốn vế *thiếu thì không tồn tại được* ở **tầng 1**, vế *trường nên có không chặn* ở **tầng 3**; `architecture.md` §8 thêm một chỗ thiếu và `YC-22` (F-038) | Đã chốt 2026-09-28 (giao cho phiên) | — | T-110; migration ở `T-111` |
| ADR-059 | **Khoản trả trước vào công thức đối soát bằng BA dòng** — *nhận trong ngày* (+) · *thành doanh thu trong ngày* (−) · *trả lại trong ngày* (−), không điều kiện ngày; `I-021` thêm hạng tử tiền mặt cho ba dòng ấy và cho nợ cũ thu bằng tiền mặt; chuyển khoản so theo lúc tiền tới; trả lại khoản chưa thành doanh thu không trừ doanh thu (*suy ra*); `YC-23` (F-037) | Đã chốt 2026-09-28 (giao cho phiên) | — | T-112; chỗ cất ở `P2-06` |
| ADR-060 | **`I-023` — mã QR của bàn — vào nhóm TIỀN đã có**, không mở nhóm mới; vế *một mã một bàn* và *lần đổi có vết* ở **tầng 1**, vế *bàn tra từ mã* · *mã cũ chết ngay* · *không đoán được* ở **tầng 3**, mã hiện hành trong tay người ngoài là **tầng 4** (`RR-10`); `YC-24`; *ai đổi, khi nào* mở `U-062` (F-042) | Đã chốt 2026-09-28 (giao cho phiên) | — | T-113; migration ở `T-114` |
| ADR-061 | **`I-024` — một lần gửi, nhiều nhất một đơn — vào nhóm TIỀN đã có**; đồng nhất lần gửi bằng **dấu lần gửi** do phía gửi đặt một lần, **không** bằng nội dung; vế *một dấu một đơn* và *không đơn nào thiếu dấu* ở **tầng 1**, vế *gửi lại nhận lại đúng đơn* · *cùng dấu khác nội dung bị từ chối* · *giống hệt không phải là trùng* ở **tầng 3**, hai ý định của người là **tầng 4** (`RR-11`); `YC-25` (F-043) | Đã chốt 2026-09-28 (giao cho phiên) | — | T-115; migration ở `T-116` |
| ADR-062 | Gate 8 chặn thêm **subject trùng từng chữ một commit đã có** trong lịch sử; `git commit --amend` giữ nguyên subject của `HEAD` vẫn qua (F-031, sửa đổi ADR-010) | Đã chốt 2026-09-28 (giao cho phiên) | — | T-117 |
| ADR-063 | **Mỗi task một file scope `work/scope/<MÃ>.txt`, git bỏ qua** — Gate 3 chấm theo hợp các file scope; Gate 7b chấm khối commit theo file của mã đứng đầu subject; file scope giữ tới khi task đã commit; `work/scope.txt` thành stub chỉ-comment | Đã chốt 2026-09-27 (chủ repo) | — | thay luật khai/gỡ scope của **ADR-043** · đóng T-085 |
| ADR-064 | **`CLAUDE.md` chỉ giữ luật và con trỏ** — cơ chế của một cổng ở header script của nó, lý do ở ADR; số mục §1–§8 giữ nguyên; bảng §2 giữ đủ hàng (607 → khoảng 410 dòng) | Đã chốt 2026-09-29 (giao cho phiên) | — | T-087 |
| ADR-065 | **Mỗi bước migration một bước lùi, và bước lùi chỉ gỡ chỗ còn rỗng** — `QC-05` bỏ luật *chỉ đi tới*; mỗi `.up.sql` một `.down.sql` mở đầu bằng khoá chặn (bảng có dòng, cột có giá trị ⇒ từ chối); lùi trên dữ liệu đã ghi là migration mới; `db-check` xuôi · lùi · xuôi lại từng bước và so lược đồ; tên bảng `.md` ↔ migration thành Gate 1e | Đã chốt 2026-09-29 (giao cho phiên) | — | P2-09 |
| ADR-066 | **Bộ đối chiếu: một câu một TẬP, một lệnh sau khi đóng quán, chứng minh bằng ngày mẫu và lỗi cài** — mỗi tập *"phải rỗng"* của pha 1 là một câu `I-0xx/n` ở `db/reconcile/`; `scripts/reconcile.sh` chạy nhóm `I-0xx` và nhóm quy ước `QD-XX` (bốn phép dạng lệnh viết lại thành SQL); `db-check` chứng minh: ngày bán mẫu đúng ⇒ 0 dòng, mỗi lỗi cài ⇒ đúng tập câu khai | Đã chốt 2026-09-30 (giao cho phiên) | — | P2-11 |
| ADR-067 | **Cổng pha 2 ký bằng một bước chạy lại được: ba scenario COMMIT thật, đọc lại ở kết nối khác, chấm YC năm kết cục** — `db/scenario/` diễn ba scenario mỗi bước một giao dịch trên database kiểm có dữ liệu mồi; bộ đối chiếu chạy lại trên ngày ấy; mỗi mã YC một dòng *đọc* và một dòng *sai* mang một trong năm kết cục có tên; tất cả là bước 7 của `db-check` | Đã chốt 2026-09-30 (giao cho phiên) | — | P2-13 |
| ADR-068 | **Lược đồ admin được dựng cho phần ĐÃ ĐỦ LUẬT, trước khi mảng bán hàng chạy thật** — sửa đổi ADR-031 đúng ở tầng lược đồ; pha 3–4 của admin và phần còn chờ lời chủ quán đứng yên; bước mang mã `P2A-XX`, thứ tự ở `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`, mô tả ở `work/backlog_AD_DB.md` | Đã chốt 2026-09-29 (chủ repo mở cổng; mã và sổ giao cho phiên) | — | P2A-01…P2A-09 |
| ADR-069 | **Mệnh đề và yêu cầu dữ liệu của mảng admin đi vào MỤC RIÊNG CÓ NHÃN trong ba owner sẵn có**, nối dãy mã `I-0xx` · `YC-XX`; câu *máy không làm* thành vế *không xảy ra được* có tên; chỗ chủ quán chưa nói thì mệnh đề khai là **không nói**, không lấp | Đã chốt 2026-09-30 (phiên đề xuất ở P2A-01; **chủ repo đồng ý** cùng ngày) | — | P2A-01 · P2A-02…P2A-08 |
| ADR-070 | **Phép so mã của bộ đối chiếu nhận một danh sách *mệnh đề chưa có lát* có tên, tự hết hạn** — danh sách ở `09-doi-chieu-bat-bien.md` §2.1, `scripts/reconcile.sh` đọc lúc chạy; mã có dòng thì `NOTE`, mọi mã khác vẫn `FAIL` | Đã chốt 2026-09-30 (giao cho phiên, T-123) | — | P2A-02…P2A-07 |
| ADR-071 | **Sổ nguyên liệu: một con số người gõ là MỘT dòng; tổng không có chỗ cất; con số là `numeric` đúng như gõ** — hai bảng (danh mục · con số ngày), mỗi con số mang người nhập, ngày và lúc gõ của riêng nó; tổng và hiệu số chỉ đọc ra bằng phép cộng; vết sửa dùng lại trigger sẵn có ở chế độ mềm; bước khoá chặn của `db-check` lùi qua các bước còn rỗng tới bước đầu tiên có dữ liệu | Đã chốt 2026-09-30 (giao cho phiên, P2A-02) | — | P2A-02 · P2A-04 · P2A-05 · P2A-06 · P2A-07 |
| ADR-072 | **Chấm công: một ô *có đi làm* là MỘT dòng của một người một ngày; không có dòng là không có ô; ô tick nhầm được HUỶ tại chỗ, không xoá và không đổi** — một bảng, mỗi ô mang người được chấm, ngày, người tick và lúc tick; khoá duy nhất trên (người, ngày) của các ô còn hiệu lực; ô đã huỷ ở lại cùng người huỷ, lúc huỷ và ghi chú; vai ghi tick và huỷ được, không sửa người hay ngày, không xoá; *người tick là chủ quán* giữ ở tầng 3, database không xét | Đã chốt 2026-09-30 (giao cho phiên, P2A-03) | — | P2A-03 · P2A-07 · P2A-08 |
| ADR-073 | **Tạm ứng và thưởng: HAI bảng, mỗi khoản một dòng; người duyệt là một dấu riêng chỉ tạm ứng có; vai ghi chỉ sửa được số tiền · người nhận · ngày; không cột nào nối sang két** — mỗi khoản mang người nhận, số tiền lớn hơn 0, ngày của khoản, người ghi và lúc ghi; *người duyệt là chủ quán* giữ ở tầng 3, database không xét; vết sửa ở chế độ mềm như mọi bảng (F-046); nối két chờ task `T-125` | Đã chốt 2026-09-30 (giao cho phiên, P2A-04) | — | P2A-04 · P2A-07 · P2A-08 · T-125 |
| ADR-074 | **Tiền RA khỏi két trong ngày là MỘT hạng tử của `I-021` — *chi từ két* — gồm mọi tạm ứng, mọi thưởng và khoản chi của loại mang nguồn két; nguồn tiền nằm trên LOẠI chi, không trên từng khoản; không cột *ngày bán của két* nào trước khi `U-072` có lời** — viết lại `I-021` · `I-028` · `I-029` · `YC-31`…`YC-33` theo lời đóng `U-066` · `U-067` và lời *trong ngày, trước lúc đếm két*; không migration nào cho tạm ứng và thưởng; câu đối chiếu của hạng tử chờ `U-072` và `F-048` | Đã chốt 2026-10-01 (giao cho phiên, T-125) | — | T-125 · P2A-05 · P2A-07 · ADR-073 |
| ADR-075 | **Khách trả nợ dần: mỗi lần trả là MỘT dòng `debt_collection` mang *số còn thiếu sau lần ấy*; các lần trả nối nhau thành chuỗi bằng khoá ngoại, nên trả vượt, rẽ nhánh và trả khi đã hết nợ đều bị database từ chối** — bỏ luật *một khoản nợ thu đủ một lần*; lần đầu nối vào số nợ của hoá đơn, lần sau nối vào số còn thiếu của lần trước; *đã trả xong* là có lần trả còn thiếu 0, không cột trạng thái | Đã chốt 2026-10-01 (giao cho phiên, T-126) | — | T-126 · ADR-059 · U-063 |
| ADR-076 | **Pha 3 có kế hoạch riêng** `master_plan/BE_master_plan_banh_cuon_ba_thanh.md`, mã bước `P3-01`…`P3-14`, sổ mô tả `work/backlog_BE.md` theo khuôn **ADR-051**; chẻ theo nhóm mệnh đề, không theo endpoint; admin ngoài pha 3 (**ADR-068**); `P3-01` chỉ nhận được sau khi **chủ repo ký chuyển pha** | Đã chốt 2026-10-01 (giao cho phiên, T-120) | — | T-120 · ADR-049 · ADR-051 · ADR-068 |
| **Giả định BA — cả năm ĐÃ ĐƯỢC THAY bằng quy tắc thật, 2026-09-02** ||||
| GĐ-01 | ~~Hai người cùng thao tác một bàn: người bấm sau thắng~~ | **Đã thay** 2026-09-02 → I-018 | ~~TRUNG BÌNH~~ | — |
| GĐ-02 | ~~Món hết sau khi khách đã chọn~~ | **Đã thay** 2026-09-02 → ADR-018 | — | — |
| GĐ-03 | ~~Khách nói đã chuyển khoản mà quầy chưa thấy báo có~~ | **Đã thay** 2026-09-02 | — | — |
| GĐ-04 | ~~Đơn đã hoàn thành cần điều chỉnh~~ | **Đã thay** 2026-09-02 → ADR-017 | — | — |
| GĐ-05 | ~~Thao tác nhầm ngoài ca *bấm nhầm một mẻ*: không có nút hoàn tác~~ | **Đã thay** 2026-09-02 → I-018 | ~~TRUNG BÌNH~~ | — |

**CẢ NĂM mục `GĐ` đã bị thay bằng quy tắc thật trong ngày 2026-09-02, nên mục *Giả định BA* hôm
nay không giữ giả định nào còn hiệu lực** — không có `GĐ` nào đang chặn một task System Design.
Vì thế không mục nào trong số chúng nằm ở `docs/product/99-unknowns.md`: chúng đã có lời chốt, chứ
không phải đang chờ một câu trả lời.

Hai mục CAO từng có (**GĐ-02**, **GĐ-03**) đã được **thay bằng quy tắc thật** ngày 2026-09-02, chứ
không phải bị hạ mức.

*Hai dòng GĐ-01 và GĐ-05 của bảng trên còn ghi `**Giả định**` · TRUNG BÌNH cho tới 2026-09-03,
trong khi thân hai mục ấy đã ghi `Trạng thái: Superseded` từ 2026-09-02 — một bảng chỉ mục nói
ngược thân mà nó trỏ tới. **Đã sửa 2026-09-03 (BA-13)**; cơ chế sinh ra nó ở `work/findings.md` **F-021**, và
`scripts/check-doc-status.sh` nay chấm đúng phép so ấy ở mọi lượt.*

---

## Template

### ADR-001 — Title

**Decision:**  
What was decided.

**Why:**  
Why this decision was made.

**Rejected alternatives:**  
What was considered and rejected.

**Applies to:**  
Which parts of the system this affects.

---

### ADR-001 — `master_plan/shop-facts.md` là nhà duy nhất của mọi dữ kiện quán

**Decision:**
Từ 2026-08-30, `master_plan/shop-facts.md` sở hữu **toàn bộ** dữ kiện quán: phạm vi bán, 5 kênh,
bảng giá thành phần, giá một suất bán, phụ thu, thành phần suất bán, 5 trạm, hai luồng bán, 12 quy
tắc nghiệp vụ, nhật ký chốt. Nó **tự đứng một mình và không chứa liên kết nào** — là điểm cuối,
mọi tài liệu khác trỏ về nó.

`master_plan/00-scope.md` rút thành **file trỏ**, không sở hữu gì, giữ lại chỉ để ~70 liên kết cũ
không gãy; nó mang bảng ánh xạ số mục cũ → mới. Chép bảng giá về đó là bug.

**Why:**
Chủ quán yêu cầu một file giới thiệu quán đọc được độc lập, không phải mở tài liệu khác (2026-08-30).
Đáp ứng yêu cầu đó bằng cách **chép** số vào `shop-facts.md` đã tạo ra hai bản của cùng một con số —
và hai bản lệch nhau **trong vòng một ngày**: giá suất trứng được chốt và ghi vào `shop-facts.md`
trong khi `00-scope.md` vẫn ghi "⚠ chưa chốt" (`work/findings.md` F-001).

Có hai cách thoát: bỏ tính độc lập, hoặc bỏ bản trùng. Tính độc lập là yêu cầu của chủ quán, nên
bỏ bản trùng — tức đảo chiều quyền sở hữu về đúng file đang giữ số.

**Rejected alternatives:**
- *Giữ hai bản, thêm cảnh báo bảo trì.* Đã thử — cảnh báo viết ngày 2026-08-30, lệch xảy ra cùng
  ngày. Trí nhớ con người không phải cơ chế.
- *Giữ hai bản, viết script so khớp.* Giải quyết triệu chứng chứ không phải nguyên nhân, và vẫn
  phải bảo trì hai bảng.
- *Xoá hẳn `00-scope.md`.* ~70 liên kết trong 14 file sẽ gãy im lặng; session cầm prompt BA cũ mở
  phải file không tồn tại mà không có manh mối đi đâu.
- *Để `00-scope.md` giữ số, hạ cấp bằng một dòng ghi chú.* Vẫn là hai bản — đúng cái vừa hỏng.

**Applies to:**
`CLAUDE.md` §2 · `master_plan/shop-facts.md` · `master_plan/00-scope.md` ·
`master_plan/prompt-fullstack.md` §3.1 · toàn bộ `prompt/BA/` (12 file).

---

### ADR-002 — Trạng thái hệ thống được **đẩy** vào mỗi phiên, không phải chờ phiên tự đọc

**Decision:**
Từ 2026-08-30, `scripts/brief.sh` chạy như hook `SessionStart` trong
`.claude/settings.json` và in trạng thái sống của repo — task In Progress, scope đang khai báo,
task Ready kế tiếp, finding Open, unknown Open, ADR mới nhất, commit gần đây, ngày sửa cuối của
từng file owner ở `CLAUDE.md` §2, và phần chưa commit — vào context **trước** chỉ thị đầu tiên
của phiên. `CLAUDE.md` §7 mô tả vòng đầy đủ: đầu phiên (brief tự đến) → trong phiên (ghi ngay,
kèm ngày, tách suy luận, rà pointer) → cuối phiên (bàn giao).

Hai ràng buộc cứng lên `brief.sh`:
1. **Chỉ trỏ, không chép.** Được in tên file, mã số, ngày, tiêu đề. Không được in một con số giá,
   một câu quy tắc, một danh sách kênh. Chép dữ kiện vào brief là tái phạm F-001.
2. **Không bao giờ chặn.** Mọi nhánh lỗi vẫn `exit 0`. Brief hỏng không được làm mất một phiên.

**Why:**
Dự án lớn dần, còn trí nhớ của một phiên thì không sống qua phiên sau. Phiên mới luôn bắt đầu
lạnh và sẽ hành động theo đúng thứ nó được đưa — nên thứ nó được đưa phải là trạng thái **hôm nay**,
không phải trạng thái của ngày tài liệu được viết.

`CLAUDE.md` §3.1 vốn đã bảo "chỉ nạp thứ task cần" — đúng về chi phí, nhưng không nói được **cái gì
vừa đổi**. Một phiên đọc `shop-facts.md` hôm qua và một phiên đọc hôm nay không có cách nào biết
mình đang cầm bản nào. Đó chính là hình dạng của F-001: hai chỗ nói hai điều, lệch trong vòng một
ngày, và cảnh báo viết cùng ngày không cứu được gì.

Bài học F-001 áp dụng nguyên vẹn ở đây: **cảnh báo dựa vào việc người ta nhớ đọc; hook thì không.**
Nên phần đắt nhất của vòng cập nhật — biết trạng thái hiện tại — được làm thành cơ chế. Phần còn
lại (ghi lúc phát hiện) vẫn là kỷ luật, vì không script nào biết bạn vừa học được gì.

**Rejected alternatives:**
- *Chỉ thêm một mục vào `CLAUDE.md` bảo "đầu phiên nhớ đọc trạng thái".* Đúng cái đã hỏng ở F-001 —
  một luật dựa vào trí nhớ. Không có gì chạy nó.
- *Tạo `work/journal.md` — nhật ký phiên viết tay.* Thêm một file phải bảo trì tay, và nó sẽ trở
  thành bản chép thứ hai của backlog + findings. Vi phạm §3.8 và F-001. Git log đã là nhật ký, chỉ
  cần đọc hộ.
- *Để brief in luôn vài dữ kiện hay dùng (giá, kênh) cho tiện.* Đó là bản chép thứ hai — đúng thứ
  ADR-001 vừa xoá. Brief trỏ, owner giữ.
- *Thêm dòng `Cập nhật lần cuối: YYYY-MM-DD` viết tay ở đầu mỗi file owner.* Người sửa file quên
  sửa dòng đó là chuyện thường, và một dòng ngày sai còn tệ hơn không có ngày. Ngày lấy từ
  `git log -1` không phụ thuộc ai nhớ gì.
- *Chạy brief ở hook `UserPromptSubmit`.* Trạng thái sẽ được bơm lại mỗi lượt, phình context mà
  hầu như không đổi. `SessionStart` (kèm resume/clear/compact) là đúng nhịp nó thay đổi.

**Applies to:**
`CLAUDE.md` §1 · §2 (cây thư mục) · §3.1 · §3.7 · §7 (mới) · §8 · `scripts/brief.sh` ·
`.claude/settings.json` · `README.md`.

---

### ADR-003 — Gate 3 chỉ chặn file git đang theo dõi; file chưa track chỉ được ghi chú

**Decision:**
Từ 2026-08-30, `scripts/check-scope.sh` tách hai loại thay đổi ngoài scope:

- file **git đang theo dõi** → `FAIL`, exit 1, gate đỏ như cũ;
- file **chưa track** (`??`) → một dòng `check-scope: note —` liệt kê tên file, exit 0.

Hành vi với file đã track không đổi một chút nào. `CLAUDE.md` §5 và
`quality/review-gate.md` Gate 3 mô tả đúng luật này.

**Why:**
`git status` nói một file **chưa được track**, không nói nó **có từ bao giờ**. Với một file đã
track, git có bản gốc để so, nên "file này vừa bị đổi trong lúc task chạy" là sự thật kiểm được.
Với file chưa track thì không có gì để so — script chỉ đoán, và nó đoán rằng mọi file chưa track
đều do task đang chạy tạo ra.

Ngày 2026-08-30, T-007 chạy prompt `prompt/maintenance/01-...md`. Ba file prompt trong thư mục đó
đã nằm sẵn trong cây **trước khi task bắt đầu** (brief đầu phiên liệt kê chúng ở mục UNCOMMITTED).
Gate đỏ, và cách duy nhất để xanh là nới `work/scope.txt` cho một thư mục mà task **không** sửa
file nào trong đó — tức khai một scope sai để làm hài lòng cái máy kiểm scope.

Đó là hỏng kiểu nguy hiểm nhất của một gate: **đỏ vì lý do sai**. Người dùng học được rằng gate
đỏ đôi khi vô nghĩa, và cách qua nó là nới scope. Sau vài lần, `work/scope.txt` biến thành thủ tục
và Gate 3 không còn bắt được thứ nó sinh ra để bắt — scope drift thật.

**Rejected alternatives:**
- *Giữ nguyên, ai gặp thì tự nới scope.* Đã thử đúng một lần và nó đẻ ra ngay một dòng scope sai
  sự thật. Luật dựa vào việc người ta chịu khó nới đúng chỗ là luật dựa vào trí nhớ (F-001).
- *Bỏ hẳn `--untracked-files=all`, không in gì.* Rẻ hơn, nhưng khi đó file mới do task tạo ra
  ngoài scope biến mất hoàn toàn khỏi output — kể cả một file `.md` nghi lễ mà `CLAUDE.md` §3.8
  cấm. Ghi chú giữ được cái nhìn thấy mà không phải trả giá bằng gate đỏ sai.
- *Commit các file prompt trước khi chạy chúng.* Chữa đúng ca này, không chữa loại lỗi: output
  tạm, file nháp, thư mục build đều rơi vào cùng bẫy, và không phải file nào cũng đáng commit.
- *Ghi mốc thời gian lúc khai scope rồi chỉ tính file mới hơn mốc đó.* Cần thêm trạng thái phải
  bảo trì (một file mốc, ai xoá, khi nào reset) cho một suy đoán vẫn không chắc. Máy móc nhiều hơn
  giá trị nó mang lại.

**Rủi ro đã chấp nhận:**
Một task tạo **file mới** ngoài scope nay không bị chặn, chỉ bị ghi chú. Ca cụ thể đáng lo là file
`.md` nghi lễ mà `CLAUDE.md` §3.8 cấm tạo. Bù lại: dòng `note:` luôn in ra và nói thẳng *"nếu file
này do chính task vừa tạo: đưa vào scope, hoặc xoá đi"*, và Gate 4 (đọc diff) vẫn phải đi qua.
Nếu có lần thứ hai một file mới lọt ra ngoài scope mà không ai thấy, ghi finding và siết lại — đúng
vòng phản hồi ở `quality/review-gate.md`.

**Applies to:**
`scripts/check-scope.sh` · `CLAUDE.md` §5 · `quality/review-gate.md` Gate 3 · `work/backlog.md`
T-010.

---

### ADR-004 — Nội dung commit do phiên viết, và có cơ chế chặn khi quên

**Decision:**
Từ 2026-08-30, `CLAUDE.md` §6.1 bắt mỗi turn kết thúc bằng một khối `git add` + `git commit` dán
chạy được ngay, và `scripts/check-commit-block.sh` thi hành luật đó: gọi từ `gate.sh --hook` sau
khi gate đã xanh, exit 2 (chặn kết thúc lượt) khi cây còn thay đổi git theo dõi mà lượt đó không
đưa ra khối commit nào. Ba giới hạn đi kèm là một phần của quyết định:

- **Chỉ nhắc, không tự commit.** Hook không chạy `git add`, không chạy `git commit`.
- **Chỉ file tracked kích hoạt.** File chưa track không, `work/scope.txt` không.
- **Một lần cho mỗi trạng thái cây.** Dấu vết ở `.git/lean-ai-commit-block`.

**Why:**
T-017 viết luật §6.1 và không có gì thi hành nó — đúng loại hỏng `work/findings.md` F-001 nói tới.
Bằng chứng có sẵn trong git log của chính repo này ngay hôm đó: `202e8c4 ádg`, `2692178 sdgf`,
`25f0f88 sdfg` — ba commit không có nội dung, vì việc soạn nội dung rơi vào lúc phiên đã kết thúc
và người còn lại không còn biết task nào, file nào, bằng chứng nào.

Chủ repo yêu cầu thêm hook ngày 2026-08-30, dù `CLAUDE.md` §3.8 nói chỉ dựng cơ chế sau lần sai
thứ hai. Ở đây lần sai không phải một lần: nó là ba commit liên tiếp, và cái mất đi — lý do của
một thay đổi — không lấy lại được sau khi phiên kết thúc.

Ba giới hạn trên đều để tránh **đỏ vì lý do sai** (bài học ADR-003):
- Tự commit sẽ lấy mất quyền quyết định cuối của người dùng (`CLAUDE.md` §6).
- File chưa track không nói được nó có từ bao giờ, đúng lý lẽ ADR-003.
- Không có luật "một lần cho mỗi trạng thái", một cây đang dở sẽ nhắc lại ở **mọi** lượt sau, kể
  cả lượt chỉ trả lời một câu hỏi. Nhắc thừa vài lần là cách nhanh nhất dạy người ta bỏ qua hook.

**Rejected alternatives:**
- *Thêm hook Stop thứ hai trong `.claude/settings.json`.* Thứ tự giữa hai hook không đảm bảo, mà
  thứ tự ở đây có nghĩa: gate đỏ thì đừng đòi commit message cho một thay đổi còn hỏng. Gắn vào
  cuối `gate.sh` là chỗ duy nhất nói được "sau khi xanh".
- *Hook tự tạo commit.* Nhanh hơn cho người dùng, nhưng §6 nói commit là quyết định của người
  dùng, và một commit tự động sinh ra từ máy sẽ có đúng chất lượng của `ádg`.
- *Chặn theo mọi thay đổi kể cả file chưa track.* Mọi file nháp, output tạm, prompt chưa commit
  sẽ đòi một khối commit — lặp lại đúng cái bẫy ADR-003 đã gỡ.
- *Không có dấu vết trạng thái, nhắc mỗi lượt.* Ít máy móc hơn một chút, đổi lại là nhắc lại vô
  ích ở mọi lượt sau khi người dùng chưa commit ngay. Dấu vết đặt trong `.git/` nên không phải
  bảo trì gì: không cần `.gitignore`, không bao giờ bị commit, mất theo bản clone.

**Rủi ro đã chấp nhận:**
Vì chỉ nhắc một lần cho mỗi trạng thái, một phiên cố tình bỏ qua lời nhắc sẽ không bị nhắc lại cho
tới khi cây đổi tiếp. Đổi lại là hook không bao giờ trở thành tiếng ồn. Nếu có lần thứ hai một
thay đổi đi vào git mà không có nội dung commit, ghi finding và siết lại.

**Applies to:**
`scripts/check-commit-block.sh` (mới) · `scripts/check-commit-block.test.sh` (mới) ·
`scripts/gate.sh` · `scripts/verify.sh` · `CLAUDE.md` §2 (cây thư mục) · §5 · §6.1 · §7.3 · §8 ·
`quality/review-gate.md` Gate 7 · `README.md` · `work/backlog.md` T-017, T-018.

---

### ADR-005 — Tài liệu cũng bị máy chấm: mọi pointer phải mở được, và lượt chỉ-đổi-tài-liệu không còn là lượt trống

**Decision:**
Từ 2026-08-30, `scripts/check-links.sh` (Gate 1b) chạy trong `gate.sh` ở **mọi** lượt, kể cả lượt
chỉ đổi tài liệu — chỗ mà `verify.sh` cố ý bỏ qua. Nó đọc mọi file `.md` thuộc nhóm **tài liệu chỉ
đường** và bắt đỏ khi một đường dẫn nêu trong đó không mở được. Bốn ranh giới là một phần của
quyết định:

- **Chấm tài liệu chỉ đường, không chấm sổ ghi chép.** Chấm: `CLAUDE.md` · `README.md` · `docs/` ·
  `quality/` · `master_plan/` · `prompt/BA/` · `.claude/`. Không chấm: `work/` và
  `prompt/maintenance/` — ở đó một đường đã chết được **trích dẫn làm bằng chứng** (F-007 kể đích
  danh bảy đường không tồn tại), nên chấm chúng là đánh thuế lên đúng việc ta muốn người ta làm.
- **Chỉ file git đang theo dõi mới làm đỏ.** File `.md` chưa track chỉ được in một dòng `note:` —
  cùng lý lẽ ADR-003.
- **Nội dung trong khối ``` không phải pointer.** Ở đó là ví dụ (`order/pricing.go`, `docs/x.md`).
- **Ngoại lệ có hạn.** `scripts/check-links.ignore` giữ những đường cố ý không tồn tại, mỗi dòng
  kèm chủ (số task, số ADR, hoặc "ví dụ"). Dòng nào **không còn khớp lỗi nào** thì gate đỏ: ignore
  hết hạn phải bị gỡ, để danh sách này không trở thành chỗ chôn nợ vô hình.

**Why:**
Repo này sản xuất **tài liệu**, không sản xuất code — và cho tới hôm nay, cổng máy chấm duy nhất
(`verify.sh`) in đúng một dòng cho mọi thay đổi tài liệu: *"verify: skipped — only documentation
changed."* Nghĩa là loại thay đổi chiếm gần như toàn bộ lịch sử repo không có gì chấm ngoài mắt
người. Bảy trong chín finding đang có (`work/findings.md` F-001, F-005, F-006, F-007, F-009…) đều
là lỗi **tài liệu**.

Ngưỡng §3.8 (hai lần) đã vượt cho đúng họ lỗi này: F-005 và F-006 rà **dữ kiện** đã đổi; F-007 là
lần thứ ba, và là loại khác — **pointer chết**. `master_plan/prompt-fullstack.md` khẳng định "nhà
thật của schema là `design/data_base/01`" trong khi `design/` chưa bao giờ tồn tại. Nặng hơn link
hỏng thường, vì file đó được dán vào prompt của agent **ngoài** repo: người đọc không có repo để
`ls`, nên hoặc dừng vì thiếu đầu vào, hoặc tự bịa nội dung bảy file rồi coi là đã có nguồn.

Bằng chứng script này chạy đúng: lần chạy đầu tiên, chưa có dòng ignore nào, nó dựng lại **đúng
bảy đường** F-007 tìm ra bằng tay — cộng hai đường cố ý không tồn tại, không hơn.

**Rejected alternatives:**
- *Chấm cả `work/`.* Cần khoảng mười dòng ignore vĩnh viễn ngay hôm nay, và mỗi finding viết ra sau
  này lại xin thêm một dòng. Cổng nào phạt người ghi lại lỗi thì sẽ được đổi lấy việc không ghi nữa.
- *Sửa bảy đường của `prompt-fullstack.md` cho gate xanh tự nhiên.* F-007 nói rõ: sửa được thì phải
  biết trước file đó **còn thuộc dự án nào và xuất cho ai** — ba khả năng (repo khác · tài liệu sẽ
  sinh ở pha sau · tàn dư) dẫn tới ba cách sửa khác nhau. Chọn bừa một cách là đoán hộ chủ repo,
  đúng thứ `CLAUDE.md` §3.5 cấm. Nợ đó nằm ở `check-links.ignore` mang tên T-019, và ngày T-019
  xong thì bảy dòng ignore hết hạn sẽ tự bắt đỏ cho tới khi bị gỡ.
- *Chạy như một `scripts/*.test.sh` bên trong `verify.sh`.* Rẻ hơn một dòng trong `gate.sh`, nhưng
  `verify.sh` bị bỏ qua đúng ở lượt chỉ đổi tài liệu — tức cổng sẽ ngủ đúng lúc cần nó nhất.
- *Kiểm cả URL ngoài (http).* Cần mạng, chậm, và đỏ vì một trang ngoài chết là đỏ vì lý do không ai
  sửa được trong repo (ADR-003).

**Rủi ro đã chấp nhận:**
Cổng chỉ biết đường dẫn **có mở được không**, không biết nó có trỏ đúng chỗ không: một link đổi từ
file đúng sang file sai mà cả hai đều tồn tại thì cổng vẫn xanh. Đó vẫn là việc của Gate 4 (đọc
diff) và §7.2 (đổi một dữ kiện thì `grep -rn` những gì trỏ vào nó).

**Applies to:**
`scripts/check-links.sh` (mới) · `scripts/check-links.ignore` (mới) · `scripts/check-links.test.sh`
(mới) · `scripts/gate.sh` · `CLAUDE.md` §2 (cây thư mục) · §5 · `quality/review-gate.md` Gate 1b ·
`README.md` · `work/findings.md` F-005, F-006, F-007 · `work/backlog.md` T-019.

---

### ADR-006 — Scope được chấm ở hai chỗ mới: brief kêu khi quên dọn, Gate 7 đọc nội dung khối commit

**Decision:**
Từ **2026-08-31** (T-016), hai cơ chế được dựng, cộng một chế độ phụ để chúng không sinh ra bản
sao thứ hai của ngữ nghĩa pattern:

- **`scripts/brief.sh` — cảnh báo "scope chưa dọn".** Khi `work/scope.txt` còn pattern **mà**
  `work/backlog.md` không có task nào ở *In Progress*, brief in một khối cảnh báo nêu đích danh
  `work/scope.txt` và **số pattern còn lại**. Có task *In Progress* thì brief giữ nguyên dòng cũ
  (*"a task is open…"*) — hai trạng thái phân biệt được, nên cảnh báo không thành tiếng ồn.
  Brief vẫn **không bao giờ đổi mã thoát** (CLAUDE.md §7.1).
- **`scripts/check-commit-block.sh` — Gate 7b, "trong khối commit có gì".** Gate 7 vốn chỉ hỏi
  *turn này có giao khối commit không*; nay nó đọc luôn các dòng `git add …` của khối (cộng index
  thật nếu có ai đã `git add` trong phiên) và nêu tên ba thứ: file **ngoài scope**, dạng
  `git add -A` / `git add .` mà §6.1 cấm, và `work/scope.txt` nằm trong khối.
- **`scripts/check-scope.sh --match <path>…`** — chế độ phụ: in ra những path nằm ngoài scope, rồi
  exit 0. Không đọc `git status`, không kết luận gì về trạng thái track. Có nó để Gate 7b hỏi được
  câu "file này có thuộc scope không" mà **không chép lại** cách so khớp pattern. Cách đọc pattern
  của Gate 3 không đổi một dòng.

**Why:**
Cùng một họ lỗi đã trả giá **bốn** lần (`work/findings.md` F-009, F-010) — ngưỡng §3.8 vượt gấp
đôi. Nhưng hai triệu chứng cần hai chỗ chấm khác nhau, vì chúng nổ ở hai thời điểm khác nhau:
scope quên dọn làm hại **phiên sau**, còn khối commit nhặt nhầm làm hại **ngay lúc dán**.

Chọn `brief.sh` cho triệu chứng thứ nhất vì ba lý do, theo thứ tự quan trọng:

1. **Nó là chỗ duy nhất trong ba ứng viên mà đầu ra chắc chắn tới được người đọc.** `brief.sh` là
   hook `SessionStart`, stdout của nó vào thẳng context trước câu lệnh đầu tiên (ADR-002). Đầu ra
   của `check-scope.sh`/`gate.sh` ở nhánh xanh chỉ đi ra stdout của một hook `Stop` exit 0 — nơi
   không quay lại phiên. Một cảnh báo không ai đọc là ceremony, đúng thứ §3.8 cấm.
2. **Đó là chỗ lời nói dối đang được in ra.** Dòng *"→ a task is open"* hôm nay khẳng định sai cho
   mọi phiên mới; sửa nó là xoá lỗi, không phải thêm cổng.
3. **Cả hai đầu vào đã nằm sẵn trong tay nó** — nó vốn đọc `## In Progress` và `work/scope.txt` để
   in hai mục ngay cạnh nhau. Không parse thêm, không file mới.

**Cảnh báo chứ không chặn, và chỗ đi chệch F-009 — nói thẳng ra:**
F-009 yêu cầu phần kiểm mới *"cảnh báo, không chặn"*. Ở `brief.sh` điều đó là miễn phí và được
giữ nguyên. Ở Gate 7b thì **không**: một hook `Stop` exit 0 không có kênh nào về tới phiên, nên
"cảnh báo" ở đó có nghĩa là in vào hư không. Gate 7b vì thế dùng **exit 2 — đúng mã thoát Gate 7
đã dùng sẵn** khi khối commit còn thiếu. Ba ranh giới giữ nó khỏi thành ADR-003 lần hai:

- Nó **không chấm thay đổi**. Gate 1, 1b, 3 đã xanh trước khi nó chạy; thứ bị trả lại là **đoạn
  văn bản bàn giao**, sửa trong một turn, không đụng một file nào.
- Nó nêu **đích danh** file hoặc dạng lệnh sai. Đỏ vì lý do người dùng thấy là đúng thì không dạy
  ai bỏ qua gate — đó mới là điều ADR-003 sợ.
- Nó nhắc **nhiều nhất một lần cho mỗi trạng thái cây** (luật 3 của Gate 7), nên không khoá được
  phiên. Ca A6 trong `check-commit-block.test.sh` giữ tính chất này.

**ADR-003 không bị lật.** Gate 3 vẫn không đỏ vì file chưa track — không một dòng nào của nó đổi.
Gate 7b chấm **danh sách file người ta vừa cố ý chọn**, không chấm cây làm việc: trạng thái track
không tham gia vào kết luận, nên một file chưa track nằm trong scope thì vẫn im (ca A8).

**Rejected alternatives:**
- *Đặt cảnh báo "scope chưa dọn" vào `check-scope.sh` hoặc `gate.sh`.* Bắt sớm hơn một phiên —
  đúng ngay cuối turn làm hỏng — nhưng chỉ nhìn thấy được khi ai đó chạy `./scripts/gate.sh` bằng
  tay. Muốn nó tới được phiên thì phải exit khác 0, tức là chặn, thứ Constraints cấm.
- *Chép lại cách so khớp pattern vào `check-commit-block.sh`.* Rẻ hơn `--match` chừng hai chục
  dòng, và hai bản sẽ trôi khỏi nhau đúng như hai bảng giá của F-001.
- *Chặn ngay ở `git add` bằng git hook.* Không đi theo bản clone, và §3.8 gọi chỗ chạy thứ ba là
  ceremony khi `SessionStart` và `Stop` đã có.
- *Bắt Gate 7b đọc index thay vì khối commit.* Phiên không chạy `git commit`; `git add` xảy ra ở
  terminal của người dùng **sau** khi hook đã chạy xong, nên index gần như luôn rỗng lúc đó. Khối
  commit là hình dạng duy nhất của "tập file vừa được cố ý chọn" mà hook nhìn thấy được. Index vẫn
  được chấm khi nó không rỗng — thêm nó không tốn gì (ca A7).

**Rủi ro đã chấp nhận:**
- Gate 7b đọc `git add` bằng **văn bản trong transcript**, nên một khối viết theo kiểu lạ (biến
  shell, `xargs`, xuống dòng giữa danh sách file) sẽ lọt. Nó bắt được đúng dạng §6.1 mô tả — và
  đó cũng là dạng cả bốn lần hỏng đã dùng.
- Cảnh báo "scope chưa dọn" chỉ đọc được *In Progress* của `work/backlog.md`. Task quên chuyển
  sang *In Progress* sẽ bị kêu oan; giá phải trả là một dòng, và lời kêu nói thẳng lối ra
  (*"mở lại nó ở In Progress, đừng xoá scope"*).

**Applies to:**
`scripts/brief.sh` · `scripts/brief.test.sh` (mới) · `scripts/check-scope.sh` (chế độ `--match`) ·
`scripts/check-commit-block.sh` · `scripts/check-commit-block.test.sh` · `CLAUDE.md` §5 · §7.1 ·
`work/findings.md` F-009, F-010 · `work/backlog.md` T-016 · ADR-002 · ADR-003.

---

### ADR-007 — Mục *Unknowns* có hình dạng máy đọc được, và brief đọc cấu trúc đó thay vì hình dạng dòng

**Decision:**
Từ **2026-08-31** (T-021), `docs/product/99-unknowns.md` có một hợp đồng, và
`scripts/brief.sh` đọc đúng hợp đồng đó:

- **Vùng đang mở** = phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối nằm dưới một
  tiêu đề `### Đang mở`. Mọi thứ dưới một tiêu đề `###` khác không được đọc.
- **Trong vùng đang mở, một gạch đầu dòng là một unknown đang mở.** Định danh `U-XXX` được tìm ở
  **bất cứ đâu** trong gạch đầu dòng ấy, nên in đậm ở đâu cũng được.
- **Văn xuôi trong vùng đang mở không sinh ra unknown**, và các dòng vắt của một gạch đầu dòng
  được **nối lại** thành một mục trước khi cắt ngắn để in.
- Hợp đồng được viết ở chính `docs/product/99-unknowns.md`, dưới tiêu đề `### Cách viết một câu ở đây` — tức
  là nằm trong vùng brief **không** đọc, nên ví dụ trong đó viết `U-` thoải mái.

**Why:**
`work/findings.md` **F-008**: bản cũ `grep -E '^\s*[-*]?\s*U-[0-9]'` chấm **hình dạng dòng**, nên
ngày 2026-08-30 nó hỏng cả hai chiều cùng lúc — giấu U-005 (một dấu `*` chen vào trước định danh)
và in U-004 đã đóng (một dòng văn xuôi tình cờ bắt đầu bằng `U-004`).

Đây là hỏng ở **đúng cơ chế ADR-002 dựa vào**: brief đẩy trạng thái vào mỗi phiên và cố ý `exit 0`
ở mọi đường lỗi, nên khi nó đọc sai thì **không có gì kêu lên** — phiên sau chỉ đơn giản tin bản
sai, và một câu hỏi nghiệp vụ bị giấu là một chỗ CLAUDE.md §3.5 bị vô hiệu.

T-020 đã vá **phía dữ liệu** (viết lại U-005, vắt lại câu văn) và để lại một luật *"viết `U-XXX`
sao cho `grep` bắt được"*. Luật đó dựa vào trí nhớ — đúng loại hỏng F-001 nói tới, và hình dạng
thứ ba sẽ lại trượt. Nới regex cho khớp thêm vài hình dạng cũng chỉ là bản nới của cùng luật đó.
Chỗ chữa tận gốc là **cho tài liệu một hình dạng, rồi chấm hình dạng ấy** — đúng cách mục
OPEN FINDINGS đã làm với `^### F-` + `**Status:**`, và mục đó chưa hỏng lần nào.

**Vì sao không bắt chước findings từng chữ:**
Mỗi finding là một mục `###` có `**Status:**` riêng, hợp lý vì một finding dài vài chục dòng. Một
unknown là **một gạch đầu dòng**; cho mỗi câu một tiêu đề `###` cộng một dòng `**Status:**` sẽ
biến một danh sách năm dòng thành năm mục, và phần *đã có lời giải* — nay là một bảng bảy dòng
gạch ngang — thành bảy mục nữa. Đó là ceremony §3.8 cấm. Lấy **nguyên tắc** của findings (cấu trúc
quyết định, trang trí không tham gia) mà không lấy **hình dạng** của nó.

**Rejected alternatives:**
- *Nới regex cho khớp cả `- **U-005`.* Rẻ nhất, và là thứ Goal của T-021 cấm thẳng: nó chỉ đóng
  hình dạng đã gặp, không đóng hình dạng thứ ba. Nó cũng không chữa được chiều thứ hai —
  một dòng văn xuôi bắt đầu bằng `U-004` vẫn khớp mọi regex đủ rộng để bắt được chiều thứ nhất.
- *Cho mỗi `U-XXX` một tiêu đề `###` + `**Status:**` như findings.* Đúng chữ của prompt T-021,
  nhưng xem đoạn trên — giá là biến một danh sách thành mười hai mục.
- *Tách unknown ra một file riêng, máy đọc được (YAML/JSON).* Bản sao thứ hai của cùng một tập
  dữ kiện, đúng thứ F-001 và ADR-001 cấm; và câu hỏi nghiệp vụ phải nằm cạnh tài liệu nghiệp vụ
  thì người mới đọc mới thấy.
- *Cho brief kêu lên khi mục Unknowns sai hình dạng.* Trái CLAUDE.md §7.1 — brief không bao giờ
  chặn — và §3.8: chưa trả giá hai lần cho **hình dạng sai**, mới trả giá cho **cách đọc sai**.

**Rủi ro đã chấp nhận:**
- **Một tiêu đề `###` mới chen vào giữa mục sẽ giấu các gạch đầu dòng dưới nó.** Đây là mặt trái
  trực tiếp của việc lấy tiêu đề làm ranh giới. Giá đã hạ xuống một mức: hợp đồng viết ngay trong
  `docs/product/99-unknowns.md` nên người sửa nhìn thấy, và `scripts/brief.test.sh` giữ ca U3b.
- **Brief vẫn im khi đọc ra rỗng.** `(none)` có thể nghĩa là "không còn câu nào" hoặc "hình dạng
  hỏng". Giữ nguyên vì §7.1 cấm brief chặn; ca U5 và U7 khoá hành vi `(none)` + `exit 0`.
- **Tiêu đề dài bị cắt ở 96 ký tự.** Brief là con trỏ, không phải bản sao (§7.1) — muốn đọc đủ
  thì mở `docs/product/99-unknowns.md`.

**Applies to:**
`scripts/brief.sh` · `scripts/brief.test.sh` · `docs/product/99-unknowns.md` · `CLAUDE.md` §4 ·
`work/findings.md` F-008 · `work/backlog.md` T-021 · ADR-002.

---

### ADR-008 — Lịch sử git đã chia sẻ thì sửa **tiến**, không viết lại; bản đồ hash sống trong `work/findings.md`

**Decision:**
Từ **2026-08-31**, một commit đã có mặt trên `origin` không được sửa lại — không `rebase`, không
`--amend`, không `filter-branch`, không `push --force` — kể cả khi subject của nó nói sai về chính
nó. Cách sửa là **sửa tiến**:

1. Ghi **bản đồ `hash → nội dung thật`** vào `work/findings.md`, trong finding sở hữu sự cố đó,
   dưới dạng bảng nêu đích danh hash, subject ghi trong log, nội dung thật, và *revert cái này thì
   mất gì*.
2. Commit tiếp theo dọn hậu quả **nêu đích danh hash sai** trong phần thân của nó.
3. Không xoá, không sửa dòng log nào.

Ngoại lệ duy nhất: chủ repo ra lệnh viết lại, rõ ràng, cho đúng commit đó. Phiên không tự quyết.

Với commit **chưa** push, luật này không áp dụng — `--amend` là cách đúng và rẻ hơn nhiều.

**Why:**
Hai sự cố buộc phải trả lời cùng một câu hỏi trong cùng một ngày:

- `0b3a337` (`work/findings.md` **F-009**) mang subject *"T-020: đơn mang đi được trả trước…"*
  nhưng nội dung là 1096 dòng của ba file `docs/` chưa track; T-020 thật là `1b1d5f5`. Hai commit
  trùng subject từng chữ.
- `0704139` (`work/findings.md` **F-011**) mang subject `dsfg` và gộp ba task T-016, T-021, T-009.

Cả hai đã nằm trên `origin/merge_first_time` khi được phát hiện. Viết lại chúng nghĩa là force-push
một nhánh người khác có thể đã fetch: người đó sẽ có hai lịch sử không hoà được, và thứ mất đi
(một `git pull` hỏng ở máy khác) đắt hơn hẳn thứ được (một dòng log đẹp hơn).

Điểm thứ hai, và là điểm quyết định: **thứ hỏng ở đây không phải log, mà là tri thức**. Người đọc
`0b3a337` cần biết nó thật ra chứa gì — đổi subject cũng không nói được điều đó, chỉ có bảng ở
finding mới nói được. Sửa lịch sử là giải pháp đắt hơn mà giải quyết ít hơn.

Chọn `work/findings.md` làm nhà của bản đồ vì ba lý do: nó đã là chủ của *"vấn đề lặp lại, bài học"*
(CLAUDE.md §2); nó không bị Gate 1b chấm link nên chép được cả đường đã chết làm bằng chứng (§5);
và `scripts/brief.sh` in Open findings cho mọi phiên mới (ADR-002), nên bản đồ tự đi tới người cần.

**Rejected alternatives:**
- *`git rebase -i` đổi subject rồi force-push.* Làm log sạch nhất, và là thứ bị loại thẳng: nhánh
  đã ở trên `origin`. Còn một điểm nữa — sau khi rebase, mọi hash dẫn trong `work/findings.md`,
  `work/backlog.md`, `docs/decisions.md` đều chết cùng lúc, nên "sửa lịch sử" kéo theo một lượt rà
  toàn repo. Chi phí thật lớn hơn nhiều so với vẻ ngoài.
- *`git revert 0b3a337` cho một dòng "Revert…" trong log.* Đúng ngữ nghĩa git và không viết lại
  lịch sử, nhưng ở đây nó gỡ luôn hai file mà chủ repo đã quyết **giữ** (F-009). Revert là công cụ
  gỡ **thay đổi**, còn thứ hỏng ở đây là **nhãn**.
- *`git notes` gắn ghi chú vào từng commit sai.* Đúng chỗ nhất về mặt kỹ thuật, và bị loại vì
  `git notes` không đi theo `git clone` hay `git push` mặc định. Một bản đồ mà bản clone sau không
  thấy thì đúng bằng không có — cùng lý lẽ với `git` hook ở F-011.
- *Không ghi gì, coi như log tự nói.* Đây chính là trạng thái đã tạo ra F-009: phiên sau đọc
  RECENT COMMITS thấy hai dòng "T-020" và tin cả hai.

**Rủi ro đã chấp nhận:**
- **Log vẫn hiển thị subject sai, vĩnh viễn.** `brief.sh` in RECENT COMMITS nên phiên nào cũng
  nhìn thấy nó trước khi nhìn thấy bản đồ. Bù lại: bản đồ nằm trong finding, và finding cũng được
  brief in ra; F-009 và F-011 đều nêu đích danh hash ngay dòng tiêu đề.
- **Bản đồ dựa vào việc người ta viết nó.** Không có cổng nào ép. Đây là giới hạn thật, và nó là
  lý do `work/findings.md` **F-011** mở **T-025** cho một `commit-msg` hook chặn ngay từ đầu vào —
  rẻ hơn nhiều so với việc dọn sau.

**Applies to:**
`work/findings.md` F-009, F-011 · `work/backlog.md` T-023, T-025 · `CLAUDE.md` §6, §6.1 ·
ADR-002 (brief in RECENT COMMITS) · ADR-004 (nội dung commit do phiên viết).

---

### ADR-009 — Nhu cầu sản xuất là một **trục riêng**, không phải một trạng thái của đơn

**Decision:**
Từ **2026-08-31**, sản phẩm mô tả *thứ bếp phải làm* bằng một trục riêng, đặt cạnh trục đơn hàng
chứ không nằm trong nó. Trục ấy có bốn khái niệm, và chúng không thay thế được cho nhau:

| Khái niệm | Đơn vị | Câu nó trả lời |
|---|---|---|
| **Nhu cầu** | một thành phần + nhân + lượng nhân | quán còn phải làm tổng cộng bao nhiêu |
| **Mẻ** | một lần bếp làm | lần này làm mấy cái, bằng thiết bị nào |
| **Đã làm xong** | một thành phần | bếp đã làm ra bao nhiêu |
| **Đã phục vụ** | một thành phần, gắn một bàn | khách đã nhận bao nhiêu |

Nhu cầu **cộng ngang qua nhiều bàn và nhiều đơn**: sáu bàn mỗi bàn một combo là *một* dòng nhu cầu
sáu quả trứng, không phải sáu dòng. Mẻ trả kết quả **về lại đúng bàn đã gọi**. Và *đã làm xong* ≠
*đã phục vụ* — nhưng con số "đã làm xong" hiện là **suy luận chưa xác nhận**, giữ ở
`master_plan/shop-facts.md` §7.2 (S-4), không được ghi như lời chủ quán.

*Cập nhật 2026-09-01 (T-036): **S-4 đã có lời giải và câu trên hết là suy luận.** Chủ quán xác
nhận bánh gấp xong **có nằm chờ**, nên "đã làm xong" là một con số thật, và **người đứng quầy bấm**
nó (`master_plan/shop-facts.md` §5.4, §7.1; §7.2 rỗng trở lại — **tới 2026-09-01, khi T-039 mở
**S-5** ở đúng chỗ ấy**). Từ nay được ghi như lời chủ quán,
kèm ngày. Chỗ **chưa** chốt đã dời sang một câu hẹp hơn — bấm theo từng cái hay cả mẻ,
`docs/product/99-unknowns.md` **U-017** — và chính nó là thứ phải nêu đích danh khi viết §3.4.*
*Cập nhật 2026-09-01 (T-037): **U-017 cũng đã đóng — bấm theo MẺ** (`shop-facts.md` §5.4). §3.4
nay không còn câu nào phải nêu là chưa chốt.*

Chỗ ở của từng phần: dữ kiện quán ở `master_plan/shop-facts.md` §5.4 (ADR-001 không đổi); hành vi
sản phẩm ở `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4, do **BA-12** viết; câu hỏi chưa ai trả lời ở *Unknowns*
U-008–U-011.

ADR này **không** quyết định màn hình, route, bảng dữ liệu hay tên trạng thái kỹ thuật. Đề xuất
`work/proposals/admin.admiadmin/admin1.md` có đủ cả bốn thứ đó; không thứ nào được nhận.

**Why:**
Chủ quán nói ngày **2026-08-31**: hai nồi tráng bánh, mỗi nồi ba quả trứng, nên sáu khách vào cùng
lúc thì làm **sáu quả một mẻ**; làm lần lượt từng suất là *mất thời gian và mất nhiệt*. Kèm theo
đó là danh sách những thứ người đứng quầy phải nhìn thấy cùng lúc — đếm được sáu tính tới
2026-08-31, và sáu là phép đếm của người viết, không phải ranh giới chủ quán chốt
(`master_plan/shop-facts.md` §5.4).

Điểm quyết định nằm ở một chỗ: **con số chủ quán cần không tồn tại trong mô hình lấy đơn làm gốc.**
"Tổng còn phải làm 14 cái bánh" không phải thuộc tính của đơn nào cả — nó là tổng cắt ngang mọi đơn
đang mở. Gắn trạng thái *đang làm / xong* vào từng dòng đơn thì diễn được *"dòng này xong"*, nhưng
con số quán thật sự dùng để chạy bếp thì không có chỗ nào ghi.

Điểm thứ hai: quán **đang** làm theo mẻ, bằng tay, hôm nay. Một thiết kế bắt bếp nhận việc theo
từng suất không phải là thiếu tính năng — nó bắt quán chạy chậm hơn hiện tại. Đây là lý do trục
này được ghi là **dữ kiện quán**, không phải một đề xuất cải tiến.

**Rejected alternatives:**
- *Thêm trạng thái "đang làm / đã xong" vào từng dòng đơn, rồi cộng lại khi cần vẽ màn hình.*
  Rẻ nhất, và hỏng đúng chỗ vừa nói. Cộng lại được, nhưng con số cộng ra **không có chỗ nào ghi
  ai đang làm nó** — mẻ trứng sáu quả không thuộc dòng đơn nào, nên nó không tồn tại trong mô
  hình. Chỉ diễn được kết quả, không diễn được việc.
- *Nhận nguyên khối cấu trúc `admin/live/`, `admin/production/`, cây trạng thái và mô hình dữ
  liệu của đề xuất.* Đó là tầng thiết kế. Repo này chưa chốt xong lát cắt nghiệp vụ (§3.2–§3.3,
  §4–§8 của `docs/product/0-ba/ban-hang/` còn trống). Nhận cấu trúc trước là để tầng dưới quyết thay tầng
  trên — đúng thứ chính đề xuất ấy cảnh báo ở mục 27 của nó.
- *Đợi BA-03…BA-09 xong rồi mới ghi.* Loại vì lời chủ quán không đợi được: nói ngày 2026-08-31,
  không ghi ngay là mất (`CLAUDE.md` §7.2). Trục ghi hôm nay, hành vi viết sau, hai việc khác nhau.
- *Ghi luôn "đã làm xong ≠ đã phục vụ" như lời chủ quán.* Chủ quán **không** nói câu đó; người tư
  vấn suy ra. Trộn nó vào §7.1 là đúng lỗi `work/findings.md` **F-004**, nên nó xuống §7.2 làm
  S-4 kèm câu kiểm chứng.
- *Mở một owner mới cho dữ kiện sản xuất.* Trái ADR-001 và `CLAUDE.md` §3.8: đây là dữ kiện quán,
  nhà của nó đã có.

**Rủi ro đã chấp nhận:**
- **Bốn câu hỏi mở cùng một lúc (U-008–U-011) cộng một chỗ suy ra (S-4).** BA-12 không tick hết
  được cho tới khi chủ quán trả lời. Chấp nhận: bốn câu hỏi có tên rẻ hơn bốn chỗ tự suy
  (`CLAUDE.md` §3.5), và cả năm đều hỏi được trong một lần gặp.
  *Cập nhật 2026-09-01 (T-036): cả năm đã đóng — U-008–U-011 ngày 2026-08-31, S-4 ngày 2026-09-01.
  Rủi ro này đã tiêu, và nó đúng như dự đoán: cả năm được hỏi trong hai lần gặp, không phải năm.
  Đổi lại, lời giải S-4 đẻ ra **U-017** (bấm theo từng cái hay cả mẻ) — BA-12 vẫn không tick hết
  được, chỉ khác là nay treo ở một câu chứ không phải năm.*
  *Cập nhật 2026-09-01 (T-037): **U-017 đóng nốt trong ngày — theo MẺ.** BA-12 hết bị chặn.*
- **Trục này làm nặng thêm mọi lát cắt viết sau nó.** BA-07 (vòng đời) và BA-09 (MVP) đều phải trả
  lời thêm một câu. Chấp nhận vì đây là thứ quán đang làm bằng tay mỗi sáng, không phải tính năng
  thêm vào.
- **Ghi trục trước khi biết ai bấm nút nào.** U-009 chưa có lời giải, nên §3.4 sẽ mô tả được *cái
  gì phải đếm được* mà chưa mô tả được *ai đếm*. Chấp nhận: thứ tự ngược lại đòi tự đặt luật.

**Applies to:**
`master_plan/shop-facts.md` §5.4, §7.1, §7.2 (S-4) · `docs/product/` §3.4 và *Unknowns*
U-008–U-011 · `work/backlog.md` BA-12, T-026 · `prompt/BA/12-production-control-L2.md` ·
`work/proposals/admin.admiadmin/admin1.md` · ADR-001 (nhà của dữ kiện quán, không đổi).

---

### ADR-010 — Gate 8 là hook của **git**, cài bằng `core.hooksPath`, và chỉ chặn cái rỗng nghĩa

**Decision:**
Từ **2026-08-31** (T-025), repo có một cổng thứ tám: `scripts/hooks/commit-msg`, hook của **git**
chứ không phải của Claude Code. Nó từ chối một commit khi subject không nói gì về chính nó, và bốn
giới hạn dưới đây là một phần của quyết định, không phải chi tiết cài đặt:

- **Hook nằm trong repo, bật bằng `core.hooksPath`.** `./scripts/install-hooks.sh` đặt
  `core.hooksPath = scripts/hooks` cho bản clone hiện tại. Không dùng `.git/hooks/`.
- **Luật hẹp, một câu:** bỏ tiền tố `T-XXX: ` nếu có (CLAUDE.md §6 cho phép L0 không mang mã task),
  phần mô tả còn lại phải có **≥ 2 từ và ≥ 8 ký tự**. `Fix typo` qua, `adg` chết.
  *(Sửa đổi 2026-09-28, **ADR-062**: thêm một luật thứ hai — subject không được trùng từng chữ
  một commit đã có trong lịch sử. Mọi giới hạn khác của ADR này giữ nguyên.)*
- **Subject > 72 ký tự chỉ bị NHẮC.** CLAUDE.md §6 nói ≤ 72, nhưng một subject 75 ký tự vẫn nói
  được nó là gì; chặn nó là *đỏ vì lý do sai* (ADR-003).
- **Đường thoát `--no-verify` được in ra ngay trong thông báo từ chối.**

Nội dung commit do git tự sinh — `Merge …`, `Revert …`, `fixup!`, `squash!`, `amend!` — không bị
chấm: chấm chúng là chặn một câu mà người dùng không hề viết ra.

**Why:**
ADR-004 mục *Rủi ro đã chấp nhận* đặt sẵn điều kiện kích hoạt: *"Nếu có lần thứ hai một thay đổi đi
vào git mà không có nội dung commit, ghi finding và siết lại."* Điều kiện đó đã chạm tới **năm**
lần (`202e8c4 ádg`, `2692178 sdgf`, `25f0f88 sdfg`, `0704139 dsfg`, `03ffda3 adg`), hai lần cuối
trong cùng ngày 2026-08-31 và đã push nên không sửa lại được (ADR-008). `work/findings.md` F-011 là
vế *ghi*; ADR này là vế *siết lại*.

Chỗ siết phải là **git**, không phải Claude Code. Gate 7 (`check-commit-block.sh`, ADR-004) đã chạy
đúng phần việc của nó và vẫn không cứu được: nó sống trong vòng đời **một lượt của phiên**, còn
người gõ `git commit -m dsfg` ở terminal không đi qua lượt nào. Bằng chứng mạnh nhất là `03ffda3`:
nó nuốt chính T-023 — task đang đi dọn hậu quả của cơ chế này — trong lúc T-023 đang chạy.

Luật giữ hẹp có lý do. Một hook chấm văn phong sẽ đỏ ở những commit thật sự nói được điều gì đó, và
bài học ADR-003 nói cái giá của *đỏ vì lý do sai*: người ta gỡ cổng chứ không sửa cái sai. Ngưỡng
2 từ / 8 ký tự là mức thấp nhất còn giết được cả năm subject đã có thật, mà `Fix typo` — một L0
hợp lệ đúng CLAUDE.md §6 — vẫn đi qua.

**Rejected alternatives:**
- *Đặt hook thẳng vào `.git/hooks/commit-msg`.* Đơn giản nhất, và sai đúng cái sai T-025 nêu tên:
  `.git/` không đi theo `git clone`, nên nó bảo vệ đúng một máy và biến mất ở mọi bản clone sau.
- *`pre-commit` thay vì `commit-msg`.* `pre-commit` chạy **trước** khi có nội dung commit, nên nó
  không đọc được subject — đúng thứ duy nhất cần chấm ở đây.
- *Hook tự soạn hoặc tự sửa nội dung commit.* ADR-004 đã loại một lần: §6 nói commit là quyết định
  của người dùng, và một subject máy sinh ra sẽ có đúng chất lượng của `ádg`.
- *Bắt buộc mọi commit phải có `T-XXX:`.* Lật CLAUDE.md §6, vốn cho phép L0 không mang mã task. Nó
  sẽ dạy người ta gõ một mã task bịa ra — tệ hơn không có mã.
- *Chặn cả subject > 72 ký tự.* Xem trên: đỏ vì lý do sai.
- *Không cài gì, chỉ viết luật vào CLAUDE.md §6.* Đó chính là trạng thái đã sinh ra năm commit kia,
  và là đúng loại hỏng `work/findings.md` F-001 nói tới: một luật dựa vào việc người ta nhớ.
- *Cho `gate.sh` gọi hook.* `gate.sh` cũng chỉ chạy trong vòng đời một lượt của phiên — lặp lại y
  nguyên lỗ hổng của Gate 7.

**Rủi ro đã chấp nhận:**
- **`core.hooksPath` là config local ⇒ mỗi bản clone vẫn phải chạy `install-hooks.sh` một lần.**
  Git không có cách nào bắt buộc điều đó, và một hook tự bật theo `git clone` sẽ là lỗ hổng bảo mật
  chứ không phải tính năng. Giảm nhẹ: `scripts/brief.sh` chấm `install-hooks.sh --check` và **kêu ở
  mỗi phiên** khi chưa cài (ADR-002 — trạng thái được **đẩy** vào phiên, không chờ ai đọc), và
  CLAUDE.md §6.2 viết ra lệnh cài. Cảnh báo, không chặn: brief không bao giờ đổi mã thoát (§7.1).
- **`core.hooksPath` THAY THẾ `.git/hooks/`, không cộng thêm.** Ai đang có hook riêng ở đó sẽ mất
  nó. `install-hooks.sh` nêu đích danh những hook sẽ ngừng chạy trước khi đổi.
- **`--no-verify` vẫn đi qua được.** Cố ý. Một cổng không có đường thoát sẽ bị gỡ khỏi máy chứ
  không được sửa (ADR-003). Nếu `--no-verify` thành thói quen thì đó là finding tiếp theo, không
  phải lý do bỏ đường thoát.
- **Ngưỡng 2 từ / 8 ký tự không chặn được một subject sai nhưng đủ dài** (`T-025: fix stuff`).
  Cổng này chặn *rỗng nghĩa*, không chấm *đúng sai* — chấm đúng sai là việc của Gate 7b và của
  người đọc diff.

**Applies to:**
`scripts/hooks/commit-msg` · `scripts/install-hooks.sh` · `scripts/commit-msg.test.sh` ·
`scripts/brief.sh` · `CLAUDE.md` §2, §6.2 · `work/findings.md` F-011 · `work/backlog.md` T-025 ·
ADR-002 (brief đẩy trạng thái) · ADR-003 (đừng đỏ vì lý do sai) · ADR-004 (nội dung commit do phiên
viết — ADR này là vế *siết lại* mà nó đặt sẵn điều kiện) · ADR-008 (sửa tiến, không viết lại).

---

### ADR-011 — Ba mặt dùng chung một miền nghiệp vụ, và **chỉ POS được ghi** tiến độ

**Decision:**
Từ **2026-08-31**, mặt quản trị của sản phẩm là **một** miền nghiệp vụ nhìn từ ba chỗ đứng — POS
(quầy) · bếp (năm màn trạm) · chủ quán (quản trị) — chứ không phải ba sản phẩm. Luật nghiệp vụ
sống ở miền, không sống trong màn hình: cùng một quy tắc *"chỉ người đứng quầy được huỷ đơn"* phải
chặn được lời gọi đến từ bất kỳ mặt nào.

Kèm theo, và đây là nửa quan trọng hơn: **POS là nơi duy nhất ghi ra tiến độ sản xuất và phục vụ;
màn hình trạm chỉ đọc.** Ba trạm `trang_banh`, `gap_banh`, `canh` **không có nút báo xong**. Ngoại
lệ duy nhất ở bếp là `don_ban` — bấm *đã dọn*, vì đó là bước cuối của một cái bàn, không phải bước
giữa của một món.

Hệ quả thứ ba, rút ra từ §6.13: **quyền gắn chỗ đứng, không gắn chức vụ**, nên hệ thống cần biết
*ai đang trực trạm nào, lúc này* — một cột `role` cố định trên bảng nhân viên **không** diễn được
luật ấy. Chủ quán đứng quầy thì có quyền của trạm `quay` **cộng thêm** quyền quản trị; chủ quán rời
quầy thì mất vế thứ nhất.

Đặc tả đầy đủ ở `docs/product/1-system-design/architecture.md`. ADR này **không** chốt tên bảng, tên cột hay endpoint.

**Why:**
Chủ quán chốt ngày **2026-08-31** (`master_plan/shop-facts.md` §5.4): *"bỏ qua bước này, POS sẽ tự
cập nhật được bao nhiêu cái cho từng bàn"* — trả lời cho câu *ai bấm "đã làm xong"*. Lý do là ba
đôi tay ở bếp đang bận; thêm một nút là thêm việc cho đúng người không rảnh. Câu trả lời ấy không
phải một tuỳ chọn giao diện: nó quyết định **ai được ghi vào đâu**, tức là một quyết định kiến trúc.

Vì sao một miền chứ không ba: bốn luật đắt nhất của quán — gộp phiên bàn (§6.1), duyệt trước khi
xuống bếp (§6.2), quyền huỷ (§6.13), hoàn tiền có vết (§6.4) — đều **cắt ngang** cả ba mặt. Tách
làm ba sản phẩm là chép bốn luật ấy làm ba bản, và ba bản sẽ lệch nhau (`work/findings.md` F-001,
đúng họ lỗi đã tốn hai lần trong repo này).

Vì sao `role` không đủ: `role` trả lời *người này là ai*; §6.13 hỏi *người này đang đứng đâu, lúc
này* — và câu thứ hai đổi nhiều lần trong một buổi sáng.

**Rejected alternatives:**
- *Giữ nút `Xong` ở màn trạm như `master_plan/prompt-fullstack.md` §3.6, §3.7 **từng** viết.* Đây
  là thiết kế đã có sẵn trong repo lúc ADR này được viết, và bị loại vì chủ quán đã bỏ nó ngày
  2026-08-31. Giữ lại nghĩa là làm ra một nút không ai bấm, rồi mọi con số phía sau nó đứng im.
  Mâu thuẫn ghi ở `work/findings.md` **F-013**; **T-031 đã sửa bản xuất khẩu ngày 2026-08-31**,
  nên §3.6 và §3.7 nay nói đúng luật này chứ không còn nói ngược.
- *Cho bếp bấm, nhưng "không bắt buộc".* Tệ hơn cả hai đường: con số vừa có vừa không, và không ai
  biết một bàn chưa có món là do bếp chưa làm hay do bếp quên bấm.
- *Ba ứng dụng riêng, mỗi mặt một cơ sở dữ liệu, đồng bộ với nhau.* Bốn luật cắt ngang ở trên biến
  thành bốn bài toán đồng bộ — cho một quán một địa điểm, chỉ vài bàn (số bàn ở
  `master_plan/shop-facts.md` §1, đừng chép về đây).
- *Gán quyền huỷ theo `role=quay`.* Rẻ nhất và sai luật: chủ quán có `role=owner` sẽ huỷ được từ
  bất kỳ đâu, đúng thứ §6.13 cấm — *"chức vụ không mở thêm cửa nào"*.
- *Chờ BA-12 xong rồi mới viết `docs/product/1-system-design/architecture.md`.* Loại vì chủ repo yêu cầu mặt admin ngay
  (2026-08-31), và phần lớn đặc tả **derive được** từ dữ kiện đã chốt. Chỗ nào chưa chốt thì tài
  liệu nêu đích danh là đang treo (§11 của nó) thay vì tự quyết.

**Rủi ro đã chấp nhận:**
- **`docs/product/1-system-design/architecture.md` viết trước khi `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 (BA-12) tồn tại.** Nếu BA-12 mô
  tả trục sản xuất khác đi, tài liệu kiến trúc phải sửa theo — nghiệp vụ vẫn là tầng trên. Đã hạ
  giá bằng cách không chốt lược đồ dữ liệu: §8 của nó chỉ **kể tên chỗ thiếu**, không đặt tên bảng.
- **"Chỉ POS ghi" dồn việc vào một người.** Người đứng quầy vừa duyệt, vừa thu tiền, vừa cập nhật
  đã phục vụ. Đó là lựa chọn của chủ quán, và nó đúng với chỗ đứng: quầy là nơi nhìn thấy cả bàn
  lẫn bếp. Rủi ro thật là lúc đông khách; chưa có dữ liệu thật để nói nó nặng tới đâu.
- **Khái niệm "đang trực trạm nào" chưa có trong 16 bảng.** Ghi ở `docs/product/1-system-design/architecture.md` §8 làm
  chỗ thiếu đã biết, không tự thiết kế quanh nó.
- **Ba câu còn mở (U-006, U-012, S-4) chạm thẳng vào mặt admin.** Tài liệu nêu đích danh và viết
  phần liên quan theo phương án hẹp nhất.
  *Cập nhật 2026-08-31 (T-033): U-006 và U-012 đã đóng, S-4 đã hỏi một lần và hỏng — chủ quán trả
  lời "tôi không hiểu", câu kiểm chứng mới ở `master_plan/shop-facts.md` §7.2. Rủi ro này giảm
  xuống còn một mục, và cách xử vẫn nguyên: phần liên quan viết theo phương án hẹp nhất.*
  *Cập nhật 2026-09-01 (T-036): **S-4 đóng nốt** — bảng quầy có **bốn** con số và **người đứng quầy
  bấm** "đã làm xong" (`master_plan/shop-facts.md` §5.4). Mặt admin/POS vì thế gánh thêm một thao
  tác, đúng chiều rủi ro "dồn việc vào quầy" ghi ở gạch đầu dòng đầu mục này. Chỗ hẹp còn lại là
  **U-017** (bấm theo từng cái hay cả mẻ); `docs/product/1-system-design/architecture.md` §3 phải viết bốn con số kèm câu
  "cách đếm chưa chốt", không được quay lại phương án ba con số.*
  *Cập nhật 2026-09-01 (T-037): **U-017 đóng — theo MẺ.** §3 bỏ được câu "cách đếm chưa chốt": bốn
  con số, con số thứ tư nhảy theo bậc mẻ. Vẫn không được quay lại phương án ba con số.*

**Applies to:**
`docs/product/1-system-design/architecture.md` (toàn bộ) · `master_plan/shop-facts.md` §5.4, §6.13, §6.14, §6.15 ·
`master_plan/prompt-fullstack.md` §3.5, §3.6, §3.7 (T-031 đã sửa §3.6 và §3.7 ngày 2026-08-31;
§3.5 không phải sửa — 16 bảng không chốt trạng thái nào của `order_tasks`) ·
`work/findings.md` F-013 · `work/backlog.md` T-029, T-031, BA-12 · ADR-009 (hai trục) ·
ADR-001 (nhà của dữ kiện quán, không đổi).

---

### ADR-012 — Nợ là một **phần riêng** có mục ở cả ba tầng, không phải hai ô trên phiên bàn

**Ngày:** 2026-08-31 · **Trạng thái:** Accepted · **Người quyết:** chủ repo (yêu cầu thẳng),
trên nền lời chủ quán *"khách không trả tiền cho nợ, POS đóng ghi ai nợ nợ bao nhiêu"*
(`master_plan/shop-facts.md` §6.14).

**Bối cảnh.**
Chủ quán chốt 2026-08-31 là **cho nợ**: khách rời quán chưa trả thì quầy vẫn đóng phiên, và lúc
đóng phải ghi **ai nợ** và **nợ bao nhiêu**. Câu ấy nói đủ về *lúc sinh ra* của khoản nợ, và
không nói gì về phần đời sau của nó. `docs/product/1-system-design/architecture.md` khi viết xong (T-029) rải nợ ở sáu
chỗ — §1.1, §4, §6.4, §7, §8, §11 — nhưng không có mục nào của riêng nó.

**Quyết định.**
Nợ được đối xử như một **phần riêng của hệ thống**, có mục riêng ở **FE**, **BE** và **DB**, đặc
tả ở `docs/product/1-system-design/architecture.md` §12. Không thêm hai ô *"ai nợ / bao nhiêu"* vào phiên bàn rồi coi là
xong.

**Vì sao.**
- **Hai vòng đời khác nhau.** Phiên bàn đóng xong là hết; khoản nợ sinh ra **lúc** phiên đóng rồi
  sống tiếp qua nhiều ngày cho tới khi có người trả. Nhét vòng đời dài vào bản ghi có vòng đời
  ngắn thì khoản nợ chết ngay tại chỗ nó sinh ra.
- **Không có mục riêng thì không thu lại được.** Không ai tra được *"hôm nay còn những ai nợ"*,
  nên tiền đã cho nợ trên thực tế là tiền mất.
- **Đối soát ngưỡng 0đ đòi hai con số.** `shop-facts.md` §6.10 bắt *lệch một đồng cũng phải tìm ra
  lý do*; muốn giải thích chỗ lệch thì phải có **nợ ghi trong ngày** và **nợ thu trong ngày** —
  hai con số chỉ tồn tại nếu nợ là một thứ đứng riêng.
- **Nợ là đường tiền thứ tư** (`docs/product/1-system-design/architecture.md` §7), cùng họ với duyệt · huỷ · hoàn. Ba việc
  kia đều có vết và có người đứng tên; nợ không có lý do gì được kém hơn.

**Phương án đã loại.**
- *Hai cột trên `table_sessions`.* Loại: không tra được danh sách nợ, không có chỗ ghi vết lúc thu,
  và sửa số nợ sẽ đè lên bản ghi của một phiên đã đóng.
- *Coi khoản nợ là một dòng thanh toán âm.* Loại: nó sẽ chảy vào báo cáo doanh thu như tiền đã
  chạm tay, đúng thứ `shop-facts.md` §6.14 cấm — nợ **không** phải tiền đã thu.
- *Chờ chủ quán trả lời nốt U-012 rồi mới làm.* Loại: vế còn treo là **kế toán** (doanh thu tính
  ngày nào), không phải **hình dạng**. Cất cả hai mốc thời gian — lúc ghi nợ và lúc thu nợ — thì
  chốt kiểu nào cũng dựng lại được báo cáo mà không sửa dữ liệu quá khứ.

**Hệ quả.**
- `docs/product/1-system-design/architecture.md` có **§12** mới; mục *Đọc gì tiếp* dời thành §13.
- §12.3 **cố ý vượt ranh giới §8** (*không đặt tên bảng, tên cột*) cho riêng phần nợ, theo yêu cầu
  thẳng của chủ repo. Nó là **đề xuất gửi sang pha 2**, không phải lược đồ đã chốt.
- Một chỗ **suy ra, chưa phải lời chủ quán**: người bấm *thu nợ* là người đang trực `quay`, suy từ
  §4 và §3.3. Chủ quán nói khác thì sửa §12.2 và §12.4 trước tiên.
- **U-012 chưa đóng.** Vế *"ghi ở đâu"* xong; *"ai ghi nhận"* và *"doanh thu ngày nào"* còn mở.

*Cập nhật 2026-08-31 (T-033) — sửa tiến, không viết lại hai dòng trên (ADR-008):* chủ quán đã đóng
nốt **U-012** trong cùng ngày. **Ai ghi nhận: POS** — trùng đúng chỗ suy ra ở dòng trước, nên §12.2
không phải sửa và chỗ ấy hết là suy luận. **Doanh thu tính ngày GHI NỢ**, không phải ngày thu tiền;
hệ quả là đối soát lệch ở **hai** ngày ngược chiều nhau và `docs/product/1-system-design/architecture.md` §6.4 nay mang
công thức đủ bốn dòng. Chi tiết ở `master_plan/shop-facts.md` §6.14.

**Ảnh hưởng tới:** `docs/product/1-system-design/architecture.md` §8, §11, §12, §13 · `docs/product/` §3.1.6 và
*Unknowns* U-012 · `quality/invariants.md` I-005 · `master_plan/shop-facts.md` §6.14 (chỉ đọc).


### ADR-013 — Nội dung mảng ADMIN đi vào **mục riêng có nhãn**, không chen vào mục của mảng bán hàng

**Decision:**
Từ 2026-09-02, mọi nội dung thuộc **mảng admin** — nguyên liệu · con người · tài chính — cập nhật
vào tài liệu nào cũng phải nằm ở **một mục riêng**, và **tên mục mang chữ `admin`**. Mục cũ của
mảng bán hàng chỉ được để lại **một dòng trỏ**, không giữ nội dung admin.

Ba mục ấy, tính tới hôm nay:

| Tài liệu | Mục admin | Mục ấy giữ gì |
|---|---|---|
| `docs/product/0-ba/admin/01-ranh-gioi.md` | **§1.6** | ranh giới nghiệp vụ của ba mảng |
| `docs/product/1-system-design/architecture.md` | **§14** | mặt kiến trúc, và bốn chỗ chạm với mảng bán hàng |
| `master_plan/shop-facts.md` | **§8** | dữ kiện quán của ba mảng |

Ba luật đi kèm:

- **Nhật ký không tách.** `master_plan/shop-facts.md` §7.1 vẫn là nhật ký chốt **đầy đủ** của cả
  hai mảng; dòng chốt admin ở lại đó, chỉ có cột *Ghi ở* trỏ về §8.
- **Đánh số tiếp, không chèn vào giữa.** Mục admin mới lấy số cuối của tài liệu
  (`docs/product/1-system-design/architecture.md` §14 đứng sau §13 vì `prompt/BA/08-mvp-scope-L1.md` đang trỏ §13).
- **`master_plan/shop-facts.md` §8 không được trỏ ra file nào** — ADR-001 giữ nguyên: tài liệu đó
  là điểm cuối, không có liên kết.

**Why:**
Chủ repo yêu cầu thẳng trong phiên 2026-09-02: *"khi cập nhật phần admin vào bất cứ tài liệu nào
hãy làm thêm 1 mục cho admin tách riêng ra, tôi cần biết mục này là thuộc phần nào"*.

Yêu cầu ấy có gốc kỹ thuật, không chỉ là sở thích. Cùng ngày, T-040 ghi lời chốt Đ-1 bằng cách viết
chen một khối dài về nguyên liệu và chấm công vào giữa `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4 — mục vốn tả ranh
giới của **mảng bán hàng**. Kết quả là một mục phục vụ hai lý do thay đổi: sửa nó vì lý do bán hàng
thì đụng phần admin, và ngược lại. Đó đúng là hình dạng lỗi `work/findings.md` **F-001** đã ghi cho
trường hợp hai bản của một sự thật — ở đây là hai sự thật trong một chỗ, hỏng theo cùng một cách.

Cái giá của việc không tách tăng theo thời gian: `work/admin-questions.md` §2 đang chờ **52 việc**
ADM. Mỗi việc viết chen vào một mục bán hàng là một chỗ nữa không tách lại được; tách bây giờ tốn
một lượt, tách sau tốn một lượt cho mỗi mục.

**Rejected alternatives:**
- *Gắn nhãn `[ADMIN]` trước từng đoạn, giữ nguyên chỗ.* Nhãn nằm trong lòng mục thì mục lục không
  thấy; người đọc vẫn phải quét cả mục mới biết đoạn nào của mảng nào — đúng cái đang hỏng.
- *Tách hẳn thành một file riêng dưới `docs/` chỉ dành cho mảng admin.* Vi phạm CLAUDE.md §2 (một sự thật một owner): ranh
  giới hệ thống đã có owner là `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4, kiến trúc đã có owner là
  `docs/product/1-system-design/architecture.md`. Thêm file thứ ba là tạo owner thứ hai cho cùng loại sự thật, và
  CLAUDE.md §3.8 cấm dựng tài liệu không ai yêu cầu.
- *Chờ tới khi có luật nghiệp vụ thật rồi mới tách.* Lúc ấy đã có nhiều mục phải tách, và mỗi lần
  tách muộn là một lần phải đọc lại xem câu nào thuộc mảng nào — thứ hôm nay còn biết chắc.
- *Đổi số mục để mục admin đứng cạnh mục liên quan.* Làm gãy pointer đang trỏ tới số cũ; ADR-008
  đã chốt hướng "sửa tiến, không viết lại".

**Applies to:**
`docs/product/0-ba/` §1.4 và **§1.6** · `docs/product/1-system-design/architecture.md` §10, §13 và **§14** ·
`master_plan/shop-facts.md` §7.1, §7.3 và **§8** · `work/admin-questions.md` §4 · mọi task
**ADM-01…ADM-52** sẽ mở sau này.

---

### ADR-014 — `docs/product.md` tách thành folder `docs/product/`, cắt theo **pha**, file cũ ở lại làm **lưu trữ không ai trỏ về**

**Trạng thái:** thiết kế đã chốt 2026-09-02, **đang thi hành**. **Lượt 1/5 xong 2026-09-02**
(DOC-1): `docs/product/` đã dựng theo pha, mười mục chuyển nguyên văn, `docs/product.md` thành bản
lưu có banner. **Lượt 2/5 xong 2026-09-02** (DOC-2): `scripts/brief.sh` đọc mục *Unknowns* ở
`docs/product/99-unknowns.md` — tiêu đề mục, chỗ đọc, nhãn *chỗ đọc đủ* và dòng *OWNER FILES* đều
đã sang nhà thật; bản lưu không còn xuất hiện ở chỗ nào trong `scripts/brief.sh`. **Lượt 3/5 xong
2026-09-03** (DOC-3, chia làm ba lượt con chạy theo thứ tự DOC-3b → DOC-3a → DOC-3c): pointer của
nhóm B (`prompt/BA/**`), nhóm A (tài liệu chỉ đường lõi) và vùng *Ready*/*In Progress* của
`work/backlog.md` đều đã sang nhà thật. **Lượt 4/5 xong 2026-09-03** (DOC-4): `CLAUDE.md` §2, §4
và §7.3 trỏ owner mới — bảng §2 ghi `docs/product/`, hai chỗ nói về câu hỏi mở ghi
`docs/product/99-unknowns.md` đúng file mà `scripts/brief.sh` đang đọc, và bản lưu chỉ còn được
nhắc **một câu, không link**, đúng là bản lưu. **Còn lại:** lượt 5 **vẫn chưa được phép chạy**.
Bảng đầy đủ ở *Bảng thi hành sau sửa đổi* cuối mục.

> **Đọc mục này từ dưới lên.** Trục cắt ban đầu là **mảng**; chủ repo đổi sang **pha** cùng
> ngày — khối *SỬA ĐỔI 2026-09-02* ở cuối mục là bản đang có hiệu lực. Phần thân dưới đây giữ
> nguyên câu chữ cũ vì chỗ nó **đoán lệch** là thứ đáng đọc; chỗ nào hai bên nói khác nhau,
> **khối sửa đổi thắng**.

**Decision:**
`docs/product.md` (1940 dòng) tách thành folder `docs/product/`. Trục cắt do chủ repo chọn
(2026-09-02) là **mảng**: bán hàng · admin · db · be · system design · fe.

Trục ấy **một mình chưa đủ**, vì hôm nay 1900 trong 1940 dòng đều là *bán hàng* (đo 2026-09-02:
admin 34 dòng ở §1.6; db · be · system design · fe **0 dòng**). Cắt đúng theo nó cho ra một file
1900 dòng và năm file rỗng — không gỡ được gì. Nên cấu trúc là **hai tầng**: tầng ngoài là mảng
(trục chủ repo chọn), tầng trong của mảng *bán hàng* là các mục §1–§8 đang có.

```text
docs/product/
  00-index.md              mục lục + luật ghi; không sở hữu sự thật nào
  ban-hang/
    01-actors-pham-vi.md   §1 trừ §1.6      (~160 dòng)
    02-kenh-ban.md         §2                (85)
    03-lat-cat.md          §3               (594)  ← vẫn to nhất, cắt tiếp khi §3.4 xong
    04-gia-thanh-toan.md   §4               (333)
    05-vong-doi.md         §5               (269)
    06-ngoai-le.md         §6                (90)
    07-pham-vi-mvp.md      §7               (184)
    08-scenario.md         §8
  admin/
    01-ranh-gioi.md        §1.6              (34) — mục admin của ADR-013 chuyển về đây
  system-design/  be/  db/  fe/
    00-chua-co-gi.md       nhà chờ sẵn, xem luật dưới
  99-unknowns.md           mục Unknowns — scripts/brief.sh đọc ĐÚNG file này
```

**Bốn file kỹ thuật giữ *yêu cầu sản phẩm* cho tầng đó, KHÔNG giữ thiết kế.** `db/`, `be/`,
`fe/`, `system-design/` nói *cái gì bắt buộc phải đúng ở tầng ấy* — ví dụ *"mọi thao tác chạm tiền
phải để lại vết đủ để đối soát truy ngược"*. Tên bảng, tên cột, khoá ngoại, API, route vẫn thuộc
`docs/product/1-system-design/architecture.md` và `master_plan/prompt-fullstack.md` §3.4–§3.7 (CLAUDE.md §2 không đổi một
dòng nào). Không có luật này thì folder mới thành owner thứ hai của kiến trúc — đúng F-001.

**`docs/product.md` ở lại làm LƯU TRỮ, và không gì được trỏ về nó** (chủ repo, 2026-09-02:
*"giữ lại trong trường hợp cần thì có thể xem lại, tuy nhiên không trỏ về, tuyệt đối không trỏ về,
chỉ refer thôi"*). Cụ thể:

- File cũ giữ nguyên nội dung, thêm banner đầu file: **ảnh chụp ngày tách, không sở hữu sự thật
  nào, không sửa ở đây**. Nó được **nhắc tới** như một bản lưu, không được **trỏ tới** như một owner.
- **464 chỗ đang trỏ `docs/product.md`** trong 33 file phải chuyển sang file mới trong cùng đợt thi
  hành. Đây là phần nặng nhất và là lý do việc này là **L3**.
- ⚠️ **Gate 1b không bảo vệ được luật này.** File cũ vẫn tồn tại nên mọi pointer cũ vẫn *mở được*
  ⇒ gate vẫn xanh trong khi cả repo đọc bản lưu. Cái chấm duy nhất là mắt người, cho tới khi việc
  này hỏng lần thứ hai (CLAUDE.md §3.8 mới cho dựng luật mới).

**Why:**
Chủ repo yêu cầu 2026-09-02: *"có lẽ chúng ta cần làm folder product và chia làm các file nhỏ liên
quan đến từng domain, như thế tôi cảm thấy dễ quản lý hơn"*. 1940 dòng trong một file là chỗ mà mỗi
task BA phải cuộn qua bảy mục không liên quan để tới mục của mình, và là chỗ hai phiên chạy song
song **chắc chắn** đụng nhau — F-014 đã xảy ra **năm** lần, lần nào cũng trên đúng file này.

Tách theo mảng còn trả trước một món nợ đang tới: chủ quán vừa mở ba mảng admin vào phạm vi
(ADR-013). 52 việc ADM sẽ đổ vào tài liệu; đổ vào một file 1940 dòng thì nó thành 3000 dòng và
không ai tách lại được nữa.

**Rejected alternatives:**
- *Giữ `docs/product.md` làm **file trỏ** như `master_plan/00-scope.md` (ADR-001).* Rẻ nhất — 464
  liên kết cũ không gãy — nhưng chủ repo bác thẳng: *"tuyệt đối không trỏ về"*. Lý do đứng được:
  file trỏ khiến hai cửa cùng dẫn tới một sự thật tồn tại lâu dài, và cửa cũ thì không bao giờ chết.
- *Cắt đúng một tầng theo mảng, không cắt tiếp mảng bán hàng.* Cho ra một file 1900 dòng — đo rồi,
  không gỡ được gì.
- *Cắt theo domain nghiệp vụ và đánh số mục lại từ đầu.* ~180 câu `docs/product.md §N` trong repo
  thành sai nghĩa mà `grep` không bắt được; giữ số §1–§8 làm tên file thì chúng vẫn đọc đúng.
- *Xoá hẳn file cũ.* Chủ repo muốn xem lại được.
- *Làm ngay trong phiên 2026-09-02.* Một phiên song song đang chạy **T-043** trên đúng
  `docs/product.md` (sửa lần cuối 13 giây trước lúc quyết định này được ghi). Tách file lúc ấy là
  xoá việc của họ.

**Applies to:**
`docs/product.md` → `docs/product/` · `scripts/brief.sh` (4 chỗ đọc thẳng đường dẫn, trong đó có
parser cấu trúc mục *Unknowns* — ADR-007) và `scripts/brief.test.sh` · `CLAUDE.md` §2 và §4 ·
`quality/invariants.md` (27 chỗ) · `work/backlog.md` (99 chỗ) · `docs/product/1-system-design/architecture.md` (14) ·
`docs/decisions.md` (17) · toàn bộ `prompt/BA/` và `prompt/maintenance/`.

**Thi hành — chia thành bốn lượt, không làm trong một lượt:**

| # | Mức | Việc | Xong là thế nào |
|---|:--:|---|---|
| 1 | L2 | Dựng `docs/product/`, chuyển nội dung sang, banner hoá file cũ | nội dung khớp từng dòng với bản cũ; gate xanh |
| 2 | **L2** | `scripts/brief.sh` đọc `99-unknowns.md`; sửa `brief.test.sh` | `./scripts/brief.sh` in đúng danh sách Open unknowns như trước khi tách |
| 3 | **L3** | Chuyển 464 pointer sang file mới, theo từng nhóm file | không file nào ngoài bản lưu còn trỏ `docs/product.md` |
| 4 | L1 | `CLAUDE.md` §2 và §4 trỏ owner mới | bảng §2 nói `docs/product/`, không nói file cũ |

Lượt 2 phải xong **trước** lượt 3: brief là thứ mọi phiên mới đọc đầu tiên, hỏng nó là hỏng mọi
phiên sau (ADR-002).

**SỬA ĐỔI 2026-09-02 — trục ngoài đổi từ MẢNG sang PHA (chủ repo quyết)**

Cùng ngày, sau khi đọc lại ADR này, chủ repo chốt: trục ngoài của folder là **pha**, không phải
mảng. **Mảng không bị bỏ** — nó tụt xuống làm tầng trong, đúng ADR-013.

Ba lý do, xếp theo sức nặng:

1. **Repo đã cắt theo pha từ đầu, chỉ là cắt bằng file chứ chưa bằng folder.** Bốn owner hiện tại
   xếp đúng theo pha, đọc banner đầu mỗi file là thấy: `master_plan/shop-facts.md` (dữ kiện thô,
   trước mọi pha) → `docs/product.md` (*"mỗi mục do một task BA chốt"* — pha 0) →
   `docs/product/1-system-design/architecture.md` (*"đặc tả, không phải mã… không nói tên hàm"* — pha 1) →
   `master_plan/prompt-fullstack.md` (kế hoạch pha 2–5). Danh sách **sáu pha** là luật đã có ở
   `master_plan/prompt-fullstack.md` §7, và nó **đã kèm sẵn luật chống chép** mà trục pha bắt buộc
   phải có: *"pha 0–1 không nhắc tên bảng; pha 2 không nhắc endpoint; pha 3 không nhắc component;
   pha 4 không đổi hợp đồng API"*. Chọn mảng là bắt cả repo học một trục thứ hai trong khi trục
   thứ nhất đang chạy đúng.
2. **Danh sách "mảng" ở bản gốc trên kia trộn hai loại.** *bán hàng · admin* là mảng; *db · be ·
   system design · fe* là **pha**. Một trục trộn hai loại thì câu hỏi *"dòng này viết vào folder
   nào"* không có câu trả lời máy móc, và mỗi phiên sẽ đoán một kiểu.
3. **ADR-013 vừa đặt mảng ở tầng trong đúng một ngày trước.** Admin là *một mục có nhãn trong mỗi
   tài liệu*, không phải một tài liệu riêng. Đưa mảng ra tầng ngoài là viết lại ADR-013 ngay sau
   khi ghi nó.

**Cây thư mục sau sửa đổi** (thay cây ở trên):

```text
docs/product/
  00-index.md                    mục lục + luật ghi; không sở hữu sự thật nào
  0-ba/                          pha 0 — BA
    ban-hang/
      01-actors-pham-vi.md       §1 trừ §1.6
      02-kenh-ban.md             §2
      03-lat-cat.md              §3        ← to nhất, cắt tiếp khi §3.4 xong
      04-gia-thanh-toan.md       §4
      05-vong-doi.md             §5
      06-ngoai-le.md             §6
      07-pham-vi-mvp.md          §7
      08-scenario.md             §8
    admin/
      01-ranh-gioi.md            §1.6 — mục admin của ADR-013 chuyển về đây
  99-unknowns.md                 mục Unknowns — scripts/brief.sh đọc ĐÚNG file này
```

**Không dựng folder rỗng** — điểm này *đổi* so với bản gốc, chỗ nói `00-chua-co-gi.md` làm nhà chờ.
Pha 1–5 chưa có nội dung thì chưa có folder; `00-index.md` liệt kê đủ sáu pha và nói pha nào chưa
mở. Một file tên *"chưa có gì"* là tài liệu nghi lễ, đúng thứ CLAUDE.md §3.8 cấm; và folder rỗng
không gỡ được dòng nào.

**Bốn thứ của bản gốc KHÔNG đổi:** file cũ ở lại làm lưu trữ và không ai được trỏ về · giữ số
§1–§8 làm tên file để ~180 câu `docs/product.md §N` vẫn đọc đúng · lượt 2 phải xong trước lượt 3 ·
Gate 1b vẫn không gác được luật "không trỏ về bản lưu", mắt người là cái chấm duy nhất.

**Bảng thi hành sau sửa đổi** — bốn lượt cũ giữ nguyên việc, đổi tên folder đích; thêm lượt 5:

| # | Mức | Việc | Prompt |
|---|:--:|---|---|
| 1 | L2 | Dựng `docs/product/` theo pha, chuyển nội dung, banner hoá file cũ | `prompt/maintenance/11-product-folder-pha-L2.md` |
| 2 | **L2** | `scripts/brief.sh` đọc file unknowns mới; sửa `scripts/brief.test.sh` | `prompt/maintenance/12-brief-unknowns-file-L2.md` |
| 3 | **L3** | Chuyển pointer sang file mới, theo từng nhóm file | `prompt/maintenance/13-pointer-migration-L3.md` |
| 4 | L1 | `CLAUDE.md` §2 và §4 trỏ owner mới | `prompt/maintenance/14-claude-md-owner-L1.md` |
| 5 | **L3 · ĐÃ CHỐT VÀ ĐÃ XONG 2026-09-03** | `docs/architecture.md` dọn vào `1-system-design/` | `prompt/maintenance/15-architecture-into-system-design-L3.md` |

Lượt 5 **chưa được phép chạy**: chủ repo mới chốt trục, chưa chốt việc `docs/architecture.md` có
dọn vào folder hay không. Prompt viết sẵn để lúc chốt là chạy được ngay; ai chạy nó mà không có
một câu chốt mới của chủ repo là làm sai ADR này.

**Số pointer phải đo lại, đừng tin con số 464 ở trên.** Đo 2026-09-02 sau BA-10: **491 dòng trong
35 file**, và nó còn tăng mỗi ngày chuỗi BA còn chạy. Lượt 3 phải đếm lại ngay trước khi bắt đầu.

**SỬA ĐỔI 2026-09-03 — chủ repo CHỐT ĐỒNG Ý dọn `docs/architecture.md` vào pha 1 (lượt 5 xong)**

Hai đoạn ngay trên nói lượt 5 *"chưa được phép chạy"* và bảng ghi *"CHƯA CHỐT"*. **Hôm nay điều
kiện ấy đã đủ.** Chủ repo được hỏi thẳng 2026-09-03 và trả lời **đồng ý**. Đây là câu chốt mà ba
điều kiện mở khoá của `prompt/maintenance/15-architecture-into-system-design-L3.md` đòi, và nó
được ghi ở đây đúng như điều kiện 1 yêu cầu.

**Decision:**
`docs/architecture.md` → **`docs/product/1-system-design/architecture.md`**, chuyển bằng `git mv`
để lịch sử file đi theo. Giữ nguyên **tên file** và nguyên **số mục §1–§14**.

- **Giữ tên file** vì nó biến cả lượt chuyển thành một phép đổi *tiền tố đường dẫn* thuần tuý —
  `git diff` chứng minh được bằng mắt, và mọi câu `… §N` quanh pointer vẫn đọc đúng.
- **Không thêm tiền tố số** (`01-architecture.md`) như `0-ba/ban-hang/`. Ở đó `01-`…`08-` khớp
  §1–§8 vì mỗi file giữ **một** mục; file này giữ **cả** §1–§14, nên một con số đằng trước sẽ nói dối.
- **Giữ số mục** vì ADR-012 (*Nợ* = §12) và ADR-013 (*admin* = §14) gọi tên mục bằng số; đánh số
  lại là làm sai hai ADR mà `grep` không bắt được.

**Ba điều kiện mở khoá — dẫn chứng bằng dòng thật, đo 2026-09-03:**

| ĐK | Bằng chứng |
|:--:|---|
| 1 — câu chốt của chủ repo | chính khối này; chủ repo trả lời **đồng ý** 2026-09-03 |
| 2 — bước 1–4 xong và đã commit | `bc5033c` (DOC-1) · `83fe8ff` (DOC-2) · `dc53768`/`fd64862`/`1a56b8e` (DOC-3a/b/c) · `ddec2f0` (DOC-4) |
| 3 — pha 1 có sản phẩm thật | file 592 dòng dọn vào **chính là** dòng nội dung đầu tiên của pha 1, đúng luật *"tạo thư mục của pha cùng lúc với dòng nội dung đầu tiên"* (`docs/product/00-index.md`, mục *Luật ghi*). Thư mục sinh ra có ruột, không phải nhà chờ rỗng mà bản sửa đổi trước đã cấm |

**Chuyển trong MỘT commit, không chia năm lượt như bảng thi hành dự tính — chủ repo chọn
2026-09-03.** Lý do là một điểm mà bảng thi hành không lường: lượt 3 dễ chia vì bản lưu **ở lại**
nên pointer cũ vẫn mở được và Gate 1b xanh suốt. Lượt này file **rời khỏi đường cũ**, nên mọi
pointer chưa chuyển đều chết ngay khi `git mv` chạy. Ba phương án và vì sao chọn phương án này:

- *Chia năm task con + `check-links.ignore` tạm.* Đúng chữ *"một task con = một commit"*, nhưng
  **hỏng đúng câu Acceptance quan trọng nhất của prompt — "mỗi task con revert được độc lập"**:
  lùi một task con giữa chừng thì pointer cũ quay lại trong khi dòng ignore đã gỡ ⇒ gate đỏ.
- *Để một file trỏ ở đường cũ* (kiểu `master_plan/00-scope.md`, ADR-001). Chạy được, nhưng dựng
  đúng thứ chủ repo đã bác cho bản lưu: *"tuyệt đối không trỏ về"* — hai cửa cùng dẫn tới một sự
  thật, và cửa cũ không bao giờ chết.
- ✅ **Một commit.** Gate xanh trước và sau, không lúc nào đỏ, không stub, không ignore tạm. Lùi là
  `git revert` đúng một commit. Ràng buộc *"đừng gộp"* viết cho lượt 3 với **464 pointer / 33 file**;
  ở đây là **40 dòng / 20 file** và là đổi tiền tố thuần tuý.

**Số đo 2026-09-03 — 48 dòng nêu `docs/architecture.md`, chia 40 chuyển / 8 ở lại:**

| Nhóm | Dòng | Xử lý |
|---|---:|---|
| `docs/decisions.md` | 22 | **20 chuyển**, 2 ở lại (xem dưới) |
| `prompt/BA/**` (11 file) | 11 | chuyển — đều là dòng khai nguồn đọc |
| `docs/product/0-ba/**` (5 file) | 6 | chuyển |
| `docs/product.md` (bản lưu) | 6 | **ở lại** |
| `CLAUDE.md` §2 · `scripts/brief.sh` · `docs/prompt-guideline.md` | 3 | chuyển |

**Tám dòng ở lại, và vì sao — đây là chỗ `grep` không quyết được, phải đọc thì của câu** (`work/findings.md` F-015, F-018):

1. **6 dòng bản lưu `docs/product.md`.** Banner của chính nó viết *"Không sửa ở đây"*; nó là ảnh
   chụp ngày 2026-09-02. Đổi đường dẫn trong một ảnh chụp là khai rằng ảnh ấy mang một đường
   **chưa tồn tại** vào ngày chụp — đúng lý lẽ đã dùng cho dòng 492 của `quality/invariants.md`.
2. **Hai dòng của chính ADR này** (bảng thi hành ô *lượt 5*, và đoạn *"lượt 5 chưa được phép
   chạy"*). Ở đó đường cũ là **chủ ngữ của câu** — nó nói *"`docs/architecture.md` dọn vào
   `1-system-design/`"*. Đổi nó thì câu thành *"`docs/product/1-system-design/architecture.md` dọn
   vào `1-system-design/`"*, vô nghĩa.

Cả tám dòng nay được `scripts/check-links.ignore` phủ bằng **hai dòng ngoại lệ có ghi lý do**, và
cái giá của chúng ghi ngay tại đó: dòng ngoại lệ phủ **mọi** lần đường cũ xuất hiện trong file ấy,
nên một pointer **mới** viết nhầm về đường cũ trong hai file đó sẽ không bị Gate 1b bắt.

**Chạy `grep` sau lượt này ra 12, không phải 8 — và cả 12 đều cố ý.** Tám dòng ở trên, cộng **bốn
dòng do chính khối sửa đổi này viết ra**: nó buộc phải nhắc tên đường cũ để kể được rằng cái gì đã
dọn đi đâu. Ghi ra để phiên sau đừng đi "sửa nốt cho sạch": một tài liệu kể lại một lượt chuyển
**luôn** làm số đếm lớn hơn số pointer còn sót, và chênh lệch ấy là bằng chứng chứ không phải nợ
(`work/findings.md` F-018 — đếm rộng hơn phạm vi thì con số đo hoạt động viết lách, không đo việc
còn lại). Thấy dòng thứ 13 thì **đọc thì của câu trước khi sửa**.

**`CLAUDE.md` §2 trỏ FILE, `scripts/brief.sh` in THƯ MỤC — cố ý, không phải lệch.** §2 trỏ thẳng
`docs/product/1-system-design/architecture.md` để **Gate 1b còn chấm được**: một đường kết thúc
bằng `/` bị `scripts/check-links.sh` bỏ qua hẳn (`work/findings.md` F-018, mục *Giá phải trả*).
Brief in thư mục vì mục *OWNER FILES* ở đó đo **ngày đổi gần nhất của cả pha**, và pha 1 sẽ có
thêm file. Hai bên cùng chỉ về một owner, chỉ khác độ mịn.

**`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` Ở LẠI `master_plan/` và KHÔNG sở hữu
gì.** Prompt bắt quyết dứt điểm chuyện này trong chính lượt này, vì để lửng là tạo owner thứ hai
cho pha 1 (`work/findings.md` F-001). Đã đọc và quyết:

- File ấy chứa **I1–I8**, mà owner của *Business invariants* theo `CLAUDE.md` §2 là
  `quality/invariants.md` — nơi đang giữ **I-001…I-018**. I1–I8 là **bản đầu, đã bị thay**:
  I1≈I-001, I2≈I-002, I3≈I-013, I4≈I-004, I7≈I-009, I8≈I-003. Dọn nó vào
  `docs/product/1-system-design/` là đặt một bản sao **cũ hơn** nằm cạnh owner thật — đúng F-001,
  và là kết cục tệ nhất trong mọi lựa chọn.
- Nó cũng chứa **SD-01…SD-07** ở dạng nháp; phần đã chín của cùng nội dung nằm trong
  `docs/product/1-system-design/architecture.md`.
- Nó ở lại đúng chỗ của nó: `CLAUDE.md` §2 nói *"Domain material for the current project lives in
  `master_plan/`"*. Nó là **đầu vào thô của pha 1**, không phải đầu ra.
- Banner nói rõ điều đó được thêm vào đầu file trong cùng đợt này, và
  `docs/product/00-index.md` mục *Pha 1* nhắc lại một câu để không ai đọc nhầm nó thành owner.

**Phương án lùi:** cả lượt là **một commit**, nên lùi là `git revert <mã commit của DOC-5>` — nó
trả `git mv` về chỗ cũ, trả 40 pointer về đường cũ, và gỡ hai dòng `check-links.ignore` cùng lúc,
nên gate xanh ngay sau khi revert mà không phải dọn tay. Đây chính là thứ mà phương án
*"chia năm task con"* không cho.

**Rủi ro còn lại, ghi ra để phiên sau khỏi dò:** Gate 1b **không** chấm đường dẫn kết thúc bằng
`/`, nên dòng `docs/product/1-system-design/` trong `scripts/brief.sh` và mọi câu trỏ thư mục là
vùng mù — bằng chứng duy nhất cho chúng là **chạy thử**, đã chạy trong lượt này.

**SỬA ĐỔI 2026-09-04 (P1-01) — câu giao "tên bảng · tên cột · khoá ngoại · API · route" cho hai tài liệu đã SAI; từ nay ADR-035 giữ câu ấy**

Câu trong mục *Decision* ở trên viết: *"Tên bảng, tên cột, khoá ngoại, API, route **vẫn thuộc**
`docs/product/1-system-design/architecture.md` và `master_plan/prompt-fullstack.md` §3.4–§3.7
(CLAUDE.md §2 không đổi một dòng nào)."* Câu ấy **ở lại nguyên văn** — sửa **tiến**, không viết lại
lịch sử (**ADR-008**) — và đây là chỗ nói nó sai ở đâu.

**Nó sai ở hai chỗ, đo 2026-09-03** (`work/findings.md` **F-023**):

| Nơi ADR này giao việc | Chính nó viết gì |
|---|---|
| `docs/product/1-system-design/architecture.md` | §8, câu cuối: *"Điều tài liệu này **cố ý KHÔNG làm**: không đặt tên bảng, không đặt tên cột, không vẽ khoá ngoại"* |
| `master_plan/prompt-fullstack.md` | banner đầu file: *"Schema · API · route · bất biến **CHƯA có nhà** — đừng đi tìm"* |

Và vế trong ngoặc — *"CLAUDE.md §2 không đổi một dòng nào"* — đúng theo nghĩa đen nhưng **dẫn
sai**: bảng §2 lúc ấy không có hàng nào cho ba thứ đó, nên câu này đọc thành *"§2 đã có câu trả
lời rồi"* trong khi §2 im lặng.

**Phần vẫn đúng, và là lý do câu ấy được viết ra:** mục đích của nó là chặn folder `docs/product/`
mới thành **owner thứ hai của kiến trúc** (F-001). Mục đích ấy đứng nguyên; chỉ **cái đích** nó
chỉ vào là sai. Bốn file `db/` `be/` `fe/` `system-design/` vẫn giữ *yêu cầu sản phẩm cho tầng đó,
không giữ thiết kế* — đúng như thân mục viết.

**Từ nay đọc ở đâu:** **ADR-035** (cùng file, 2026-09-04) — lược đồ là **pha 2**, hợp đồng API là
**pha 3**, route là **pha 4**, và *tầng bảo vệ* của từng invariant là **pha 1**; `CLAUDE.md` §2 có
bốn hàng cho chúng, ba hàng ghi thẳng *chưa có owner, sinh ra ở pha N*.

---

## Quyết định NGHIỆP VỤ — BA-10

ADR-001 tới ADR-014 đều là quyết định **về cách vận hành repo này**. Mục dưới đây là loại thứ hai:
**quyết định về cái quán**. Chúng do **chủ quán** chốt, không do phiên nào suy ra, và mỗi mục ghi
đích danh ngày chốt cùng chỗ giữ dữ kiện gốc (`master_plan/shop-facts.md` — CLAUDE.md §2).

**Luật đọc mục này, và nó là luật cứng:** một mục ở đây là **ADR** khi có lời người thật; là
**GĐ** (mục *Giả định BA* bên dưới) khi chưa ai trả lời. Không phiên nào được nâng một `GĐ` thành
`ADR` mà không có câu trả lời thật, và cũng không được hạ một câu **đã có lời chốt** xuống `GĐ` —
cả hai chiều đều là tự trả lời thay chủ quán (CLAUDE.md §3.5, `work/findings.md` F-004).

Bản đồ chứng minh không câu hỏi nào bị bỏ sót ở [§ Bản đồ](#ban-do) ngay dưới các ADR.

---

### ADR-015 — Năm kênh bán là danh sách ĐÓNG, và định danh khách khác nhau theo kênh

**Decision:**
Quán bán qua **đúng năm** kênh — `delivery` · `pickup` · `qr_table` · `staff_pos` ·
`phone_preorder` — và không có kênh thứ sáu. `phone_preorder` (đặt trước qua hotline) là **kênh
thứ năm riêng**, chốt 2026-08-24 và sửa tên 2026-08-29; nó **không gắn bàn**.

Định danh khách chia theo kênh:

- `qr_table` — khách **ẩn danh theo số bàn**: không khai tên, không khai số điện thoại.
- `delivery`, `pickup`, `phone_preorder` — **bắt buộc số điện thoại**; riêng `delivery` bắt buộc
  thêm **địa chỉ giao**. Hai trường ấy là bắt buộc thật, chủ quán xác nhận 2026-08-30 (**S-2**).

Khách đã đặt qua hotline rồi đổi ý tới ăn tại quán ⇒ **huỷ đơn đặt trước, khách quét QR gọi lại**
(**U-003**, chốt 2026-08-30). Không có đường "chuyển kênh" cho một đơn đang sống.

**Why:**
`master_plan/shop-facts.md` §2 và §6.5; nhật ký chốt §7.1 (2026-08-24, 2026-08-29, 2026-08-30).
Ẩn danh theo bàn đứng được vì **cái bàn đã là định danh đủ** để bưng đồ ra và để thu tiền — quán
không cần biết tên khách ngồi đó. Ba kênh không gắn bàn thì mất cái bàn, nên phải có một thứ khác
gọi được khách, và thứ ấy là số điện thoại.

**Rejected alternatives:**
- *`phone_preorder` chỉ là một đơn `staff_pos` không gắn bàn.* Bác 2026-08-29: nó có **giờ hẹn**
  bắt buộc (§6.5) và một đường tiếp nhận riêng, nên nó là kênh riêng. `work/findings.md` **F-005**
  là cái giá của việc bốn tài liệu còn nói *"bốn kênh"* sau ngày ấy.
- *Bắt khách `qr_table` khai số điện thoại.* Bác — quán không cần, và một ô bắt buộc không ai
  dùng là một ô khách bỏ dở giữa chừng.
- *Cho ca U-003 một đường "chuyển kênh" thay vì huỷ rồi gọi lại.* Bác — nó sinh ra một đơn thuộc
  **hai** kênh, và đối soát cuối ngày (§4.9) không cộng nổi một đơn như thế vào nguồn nào.

**Applies to:**
`docs/product/0-ba/ban-hang/02-kenh-ban.md` §2, §2.1–§2.4 · `quality/invariants.md` I-007, I-008 ·
`master_plan/shop-facts.md` §2, §6.5 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 2.

---

### ADR-016 — Máy POS ở quầy là CỬA GHI DUY NHẤT, và quyền gắn với CHỖ ĐỨNG chứ không gắn chức vụ

**Decision:**
Mọi thao tác làm đổi **tiền** hoặc đổi **trạng thái** đi qua đúng **một** cửa: máy POS đặt ở quầy.
Người đứng quầy là người bấm: **duyệt** đơn khách tự gửi (§6.2) · **huỷ** đơn (§6.13, **U-004**) ·
**hoàn tiền** (§6.4, **S-3**) · **ghi nợ** lúc đóng phiên và **thu nợ** về sau (§6.14, **U-012**) ·
**ghép bàn** (§6.16, **U-013**) · bấm *"đã làm xong"* và *"đã bưng ra bàn"* cho bảng bếp (§5.4 —
**U-009**, **U-017**, **U-021**) · bấm cho đơn giao sang `Đang giao` lúc đơn **rời quán**
(**U-023**) · giữ và nhập lại **sổ giấy** sau khi mất điện (§6.11, **U-025**).

**Hai ngoại lệ đã chốt đích danh tên người khác**, và chỉ hai: **người đi giao** bấm *đã giao + đã
thu tiền* tại chỗ khách (§6.7); **chủ quán** bấm đổi giá hoặc đổi thành phần suất trên mặt quản
trị (§6.17).

**Quyền gắn với chỗ đứng, không gắn chức vụ.** Chủ quán không đứng quầy thì **nhờ người đứng quầy
bấm** (**U-004**, chốt 2026-08-30); chủ quán đang đứng quầy thì bấm được, vì lúc ấy họ *là* người
đứng quầy (ADR-028).

**Why:**
Đây là câu trả lời lặp lại **năm lần cho năm câu hỏi khác nhau**, trong bốn ngày khác nhau
(2026-08-30 → 2026-09-02, `docs/product/99-unknowns.md` → *Đã có lời giải*). Một câu trả lời lặp
lại năm lần là một **luật về cách quán vận hành**, không phải năm lời chốt rời rạc. Nó có nền vật
lý: quán chỉ có **một** máy POS, đặt ở quầy (§6.13).

Nó cũng là điều kiện để **I-012** có nghĩa. Một cái vết chỉ truy ngược được về *một người* khi số
cửa ghi là hữu hạn và đã biết tên; hai cửa ghi không ràng buộc nhau thì "ai bấm" thành câu hỏi
không ai trả lời được sau ba ngày.

**Rejected alternatives:**
- *Gắn quyền vào **chức vụ** (chủ quán / nhân viên).* Bác 2026-08-30 (`work/backlog.md` T-006):
  chủ quán ngồi ở nhà thì không còn ai huỷ được đơn, trong khi người đang đứng quầy nhìn thấy
  khách ngay trước mặt.
- *Đặt nút bấm ở ba trạm bếp.* Bác 2026-08-31 (**U-009**): *"bỏ bước ấy đi"*. Bếp đang tráng bánh
  không rảnh tay bấm máy. `work/findings.md` **F-013** là cái giá của việc bản xuất khẩu còn giữ
  nút ấy sau khi chủ quán đã bỏ.
- *Cho mặt quản trị ghi tiến độ.* Bác — ADR-011: ba mặt dùng chung một miền nghiệp vụ, và **chỉ
  POS được ghi**.

**Applies to:**
`docs/product/0-ba/ban-hang/` §1.5, §2.4, §4.6, §4.8, §5.4 · `quality/invariants.md` I-012 · ADR-011 ·
`master_plan/shop-facts.md` §6.2, §6.4, §6.7, §6.13, §6.14, §6.16, §6.17.

---

### ADR-017 — Sửa và huỷ một đơn KHÔNG bị chặn bởi trạng thái; POS quyết từng ca

**Decision:**
Một đơn **sửa được ở bất kỳ trạng thái nào** (**U-022**, chốt 2026-09-02) và **huỷ được kể cả khi
đã `Hoàn thành`** (**U-027**, chốt 2026-09-02). Không có mốc trạng thái nào chặn; **POS quyết theo
tình hình thực tế**, từng ca một.

Ba hệ quả đi kèm, và chúng là phần dễ đọc sai nhất:

- **Sửa KHÔNG phải một chuyển tiếp trạng thái.** Đơn đang ở đâu vẫn ở đó; cái đổi là món, số suất,
  tuỳ chọn. Vì thế sửa không nằm dưới **I-016** và không cần một dòng nào trong bảng §5.2.
- **Huỷ thì LÀ một chuyển tiếp**, nên bảng §5.2 có thêm dòng `Hoàn thành → Huỷ`, và §5.6 mất ca
  thứ hai trong danh sách bị từ chối.
- **Huỷ một đơn đã `Hoàn thành` gần như luôn kéo theo tiền.** Hàng đã tới tay khách và tiền có thể
  đã thu ⇒ lần huỷ ấy đi kèm **hoàn tiền** theo ADR-020, rơi vào **ngày hoàn**. Huỷ không phải
  đường vòng tránh luật hoàn tiền.

Mọi lần sửa và mọi lần huỷ **để lại vết** (ADR-024).

**Why:**
Chủ quán được hỏi **hai lần, hai ngày, hai câu tách nhau** — *sửa tới trạng thái nào* (2026-09-02,
lượt một) rồi *huỷ tới trạng thái nào* (2026-09-02, lượt hai) — và trả lời cùng một câu. Đó là
luật, không phải hai lời chốt rời (`master_plan/shop-facts.md` §6.19).

Phải hỏi **hai lần** vì lượt một chỉ nói chữ *sửa*. Đọc chữ *sửa* thành *huỷ* là đúng thứ
`work/findings.md` **F-004** cấm, nên vế huỷ ở lại thành **U-027** và mất thêm một lượt. Ghi lại ở
đây vì cái giá ấy đáng nhớ hơn lời chốt.

**Rejected alternatives:**
- *"Đơn đã xác nhận thì chỉ được huỷ rồi tạo lại, không được sửa."* Bác 2026-09-02: §6.19 nói
  **sửa chính đơn ấy**. Huỷ-rồi-tạo-lại làm mất lịch sử của đơn và sinh ra hai bản ghi cho một
  việc, nên đối soát cuối ngày đếm đôi.
- *Chặn cứng ở `Hoàn thành` cho cả sửa lẫn huỷ.* Bác — chủ quán cố ý **không** dựng hàng rào ở
  đây, và sản phẩm không được tự dựng hộ.
- *Suy vế huỷ ra từ lời chốt về sửa, ngay trong lượt một.* Bác vì lý do quy trình (F-004), và đó
  là quyết định đúng: lời chốt thật hoá ra **rộng hơn** cái suy ra sẽ viết.

**Applies to:**
`docs/product/0-ba/ban-hang/` §5.2, §5.6, §6 dòng 13 · `quality/invariants.md` I-016 ·
`master_plan/shop-facts.md` §6.19 · thay **GĐ-04**.

---

### ADR-018 — Món hết sau khi khách đã chọn: POS bàn với khách, không có luật tự động

**Decision:**
Khi một món hết sau lúc khách đã chọn, hệ thống **không tự thay thế** bằng món khác và **không tự
huỷ** dòng ấy. **Người đứng quầy nói chuyện với khách**, và quyết định ra **tại lúc thoả thuận
xong** (chủ quán chốt 2026-09-02, `master_plan/shop-facts.md` §6.20).

**Why:**
Đây là câu **3** của bảng mười câu §10 kế hoạch gốc, và nó từng là **GĐ-02** — một giả định đoán
rằng quán có một luật xử lý cứng. Lời chủ quán cho thấy giả định ấy đoán quán **chặt hơn quán
thật**: chủ quán cố ý để chỗ này cho con người, vì món hết là chuyện thương lượng, không phải
chuyện tra bảng.

**Rejected alternatives:**
- *Tự động thay bằng món tương đương.* Bác — máy không biết khách chịu đổi sang cái gì, và một
  suất bị đổi ngầm là một suất khách không gọi.
- *Tự động huỷ dòng ấy rồi báo khách.* Bác — khách có thể muốn đổi chứ không muốn bỏ, và huỷ ngầm
  làm hoá đơn hụt đi so với thứ khách nhớ mình đã gọi.

**Applies to:**
`docs/product/0-ba/ban-hang/06-ngoai-le.md` §6 dòng 5, §6.3 · `master_plan/shop-facts.md` §6.20 · thay **GĐ-02**.

---

### ADR-019 — Khách không trả được thì quán CHO NỢ, phiên vẫn đóng, và doanh thu tính NGÀY GHI NỢ

**Decision:**
Khách rời quán mà chưa trả tiền thì **quán cho nợ** (**U-007**, chốt 2026-08-31). Quầy **vẫn đóng
phiên**, và lúc đóng POS **bắt buộc ghi ai nợ và nợ bao nhiêu**. Doanh thu tính vào **ngày ghi
nợ**, không phải ngày thu được tiền (**U-012**, chốt 2026-08-31); **thu nợ cũ** về sau làm két
thừa nhưng **không** làm tăng doanh thu ngày thu.

**Why:**
`master_plan/shop-facts.md` §6.14. Cho nợ là chuyện có thật ở quán quen, nên chặn nó bằng phần mềm
là chặn một việc quán vẫn làm. Tính doanh thu vào **ngày ghi nợ** giữ được luật lớn hơn: **doanh
thu một ngày đã đối soát không bao giờ đổi về sau** (ADR-022).

⚠️ **Luật này NGƯỢC CHIỀU với hoàn tiền** (ADR-020: tính vào **ngày hoàn**, không phải ngày bán
gốc). Hai luật ngược chiều nhau nhưng cùng phục vụ một mục đích — không bao giờ phải sửa lại con
số của một ngày đã chốt sổ. Gộp chúng thành một câu là làm sai một trong hai.

**Rejected alternatives:**
- *Giữ phiên mở tới lúc khách trả.* Bác — cái bàn kẹt lại và không ai ngồi được (**I-003**), trong
  khi khách đã về từ lâu.
- *Tính doanh thu vào ngày thu được tiền.* Bác — doanh thu của một ngày đã đối soát sẽ đổi về sau,
  và ngưỡng lệch **0đ** của §4.9 mất nghĩa ngay hôm đó.
- *Không cho nợ.* Bác 2026-08-31 — quán vẫn cho nợ dù phần mềm nói gì.

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.1.6, §4.7, §4.9, §4.10 · `quality/invariants.md` I-005, I-014 · ADR-012 ·
`master_plan/shop-facts.md` §6.14.

---

### ADR-020 — Hoàn tiền: CÓ, người đứng quầy vừa quyết vừa ghi vết, và tính vào NGÀY HOÀN

**Decision:**
Quán **có** hoàn tiền, và **không có luật cứng** về khi nào được hoàn — **người đứng quầy quyết
từng ca** theo tình hình thật (`master_plan/shop-facts.md` §6.4, chốt 2026-08-30). Cùng người ấy
**ghi vết**, không tách thành hai vai (**S-3**, chủ quán xác nhận 2026-08-30).

Mỗi lần hoàn để lại vết trả lời đủ **bốn** câu: hoàn **bao nhiêu** · cho **đơn nào** · **ai** bấm ·
**lý do** gì. Khoản hoàn trừ vào doanh thu **ngày hoàn**, không phải ngày bán gốc (**U-019** vế 2,
chốt 2026-09-01).

**Why:**
Chính vì **không có luật cứng** nên cái vết là thứ **duy nhất** giữ chỗ này khỏi thành lỗ thủng:
không có bảng điều kiện để đối chiếu thì phải có người đứng tên (**I-012**). Ô *lý do* bắt buộc ở
đây mà không bắt buộc ở thao tác khác cũng vì lẽ ấy.

Tính vào **ngày hoàn** cho ra hệ quả đáng giữ nhất của cả §4: **doanh thu một ngày đã đối soát
không bao giờ đổi về sau.** Đối soát ngưỡng 0đ (ADR-022) chỉ đứng được khi con số của hôm qua là
con số cuối cùng.

**Rejected alternatives:**
- *Trừ khoản hoàn vào **ngày bán gốc**.* Bác 2026-09-01 — nó viết lại doanh thu một ngày đã chốt
  sổ, nên mỗi lần hoàn là một lần phải đối soát lại quá khứ.
- *Dựng một bảng điều kiện "được hoàn khi…".* Bác — chủ quán cố ý không đặt luật ấy; tài liệu nào
  biến lời chốt này thành bảng điều kiện là hiểu ngược nó.
- *Tách người quyết và người ghi vết làm hai vai.* Bác 2026-08-30 (S-3) — quán không có đủ người,
  và tách ra thì cái vết chậm hơn cái quyết định.

**Applies to:**
`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.8, §4.9, §4.10 · `quality/invariants.md` I-012, I-014 ·
`master_plan/shop-facts.md` §6.4 · ADR-017 (huỷ đơn đã `Hoàn thành` đi qua đây).

---

### ADR-021 — Giờ hẹn bắt buộc với `pickup` VÀ `phone_preorder`; `delivery` có quản lý trạng thái giao

**Decision:**
**Giờ khách cần hàng là bắt buộc**, và bắt buộc với **cả hai** kênh có hẹn — `pickup` **và**
`phone_preorder`, không riêng `pickup` (`master_plan/shop-facts.md` §6.5, chốt 2026-08-30).

`delivery` **có** quản lý trạng thái giao, không chỉ ghi nhận đơn (§6.7, chốt 2026-08-30): trạng
thái `Đang giao` **chỉ tồn tại ở đơn giao tận nơi**, không có ở kênh khác. **POS bấm `Đang giao`
lúc đơn RỜI QUÁN**; mốc kết thúc do **người đi giao** bấm tại chỗ khách, cùng lúc với *đã thu
tiền* (**U-023**, chốt 2026-09-01).

**Phí ship 0đ và không có đơn tối thiểu** (§6.12) — đây là một trong bốn ranh giới đã chốt của
§6.12, không phải một con số chờ điền.

**Rejected alternatives:**
- *Giờ hẹn chỉ bắt buộc với `pickup`.* Bác — kế hoạch gốc §10 câu 6 viết như vậy vì viết trước
  ngày `phone_preorder` thành kênh riêng; `shop-facts.md` §6.5 nói **cả hai**, và §2 của
  `CLAUDE.md` cho `shop-facts.md` thắng.
- *`delivery` chỉ ghi nhận đơn, không có trạng thái giao.* Bác 2026-08-30 — quán cần biết đơn nào
  đang trên đường, vì tiền của đơn ấy chưa về két mà vẫn là doanh thu (ADR-022).
- *Cho `Đang giao` xuất hiện ở mọi kênh mang đi.* Bác — `pickup` và `phone_preorder` khách tự tới
  lấy, không có ai đi giao để bấm.

**Applies to:**
`docs/product/0-ba/ban-hang/` §2.1, §3.2.1, §5.2 · `quality/invariants.md` I-007 ·
`master_plan/shop-facts.md` §6.5, §6.7, §6.12.

---

### ADR-022 — Doanh thu một ngày cộng từ ĐỦ hai nguồn; đối soát BA nguồn, ngưỡng lệch 0đ

**Decision:**
Doanh thu một ngày cộng từ **đủ hai** nguồn bán — bán **tại bàn** và bán **mang đi** — và không
khoản nào đứng ở cả hai (**I-014**).

Đối soát cuối ngày dùng **ba** nguồn, chia theo **phương thức**, không cộng gộp:

| Nguồn | Đối chiếu phần nào |
|---|---|
| Sổ giấy | toàn bộ — bản ghi tay độc lập của cả ngày |
| Tiền trong két | phần khách trả **tiền mặt** |
| **Tin nhắn báo có** | phần khách **chuyển khoản** (**U-019**, chốt 2026-09-01) |

**Ngưỡng lệch là 0đ** — lệch một đồng cũng phải tìm ra lý do. Một lần thu **chia được nhiều phương
thức**, và POS ghi rõ bao nhiêu tiền mặt, bao nhiêu chuyển khoản (**U-020**, chốt 2026-09-01,
`shop-facts.md` §6.18, **I-015**).

Hai mốc ngày, ngược chiều nhau và cả hai đã chốt: **nợ** tính ngày **ghi nợ** (ADR-019) · **hoàn
tiền** tính ngày **hoàn** (ADR-020).

**Why:**
Nguồn thứ ba tồn tại vì **két không giữ tiền chuyển khoản**. Quán có hai phương thức mà chỉ một đi
qua két; so doanh thu với mỗi *sổ giấy + két* thì phần VietQR không có gì để đối chiếu.

Chia theo phương thức chứ không cộng gộp là phần đắt nhất của quyết định này: một chỗ **thiếu** ở
két có thể bị một chỗ **thừa** ở ngân hàng che mất, và lúc đó ngưỡng 0đ không còn nghĩa gì.

**Rejected alternatives:**
- *Đối soát bằng hai nguồn (sổ giấy + két).* Bác 2026-09-01 — phần VietQR không có gì đối chiếu.
- *Cộng gộp ba nguồn rồi so đúng một con số.* Bác — lệch bù trừ nhau, ngưỡng 0đ thành hình thức.
- *Ngưỡng chấp nhận vài nghìn cho "sai số đếm tiền".* Bác — đây là cổng chất lượng mạnh nhất của
  cả dự án; một ngưỡng dương biến mọi lỗi nhỏ thành vô hình.
- *Bắt khách chọn đúng một phương thức cho một lần thu.* Bác 2026-09-01 (U-020) — chữ *"hoặc"* ở
  `shop-facts.md` §1 là lựa chọn của khách, không phải luật loại trừ.

**Applies to:**
`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.6, §4.9, §4.10 · `quality/invariants.md` I-014, I-015 ·
`master_plan/shop-facts.md` §6.10, §6.18 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 12.

---

### ADR-023 — Chủ quán đổi giá được NGAY giữa giờ bán; mốc khoá giá là TỪNG DÒNG; thành phần suất phải chờ hết buổi

**Decision:**
Bốn chiều đổi menu **không** cùng một luật, và ranh giới đi giữa **tiền** và **thành phần**:

- **Ba chiều TIỀN** — sửa giá, sửa phụ thu, bật/tắt món — sửa được **ngay giữa giờ bán**, hiệu lực
  **từ lúc lưu**, không phải chờ hết buổi (**U-014**, chốt 2026-09-01).
- **Chiều THÀNH PHẦN SUẤT** — phải **chờ hết buổi bán** (**U-016**, chốt 2026-09-01). Nhưng máy
  **chỉ nhắc một câu rồi vẫn cho lưu** (**U-018**, chốt 2026-09-01): luật *chờ hết buổi* là luật
  cho **người**, không phải hàng rào của máy.

**Mốc khoá giá là TỪNG LƯỢT GỌI, và sau 2026-09-02 là TỪNG DÒNG.** Lượt gọi trước mốc đổi giá giữ
giá cũ, lượt gọi sau mốc áp giá mới ⇒ **một hoá đơn phiên bàn được phép mang HAI mức giá** cho
cùng một món, và đó là kết quả **đúng** (**U-015**, chủ quán chấp nhận 2026-09-01).

**Sửa một dòng thì ĐẶT LẠI mốc khoá giá của chính dòng ấy**: dòng vừa sửa lấy **giá đang hiệu lực
lúc sửa** (**U-026**, chốt 2026-09-02). Hai điều đọc kèm: (1) luật gốc không đổi — một lần **đổi
giá** không bao giờ tự với ngược vào dòng đã tạo; cái đặt lại mốc là **thao tác cố ý của người
đứng quầy** trên đúng dòng đó. (2) Vết của lần sửa phải ghi **cả giá cũ lẫn giá mới**, nếu không
thì đối soát §4.9 không giải thích được chỗ lệch.

**Why:**
`master_plan/shop-facts.md` §6.17, §4.5, §6.19. Ba chiều tiền chỉ chạm **đơn mới**, nên đổi giữa
buổi không hại ai; đổi **thành phần suất** thì chạm việc **đang nằm ở bếp** — một suất đang tráng
dở bỗng đổi công thức là một suất không ai biết nó gồm gì.

**Rejected alternatives:**
- *Bắt cả bốn chiều chờ hết buổi.* Bác 2026-09-01 — *"không phải chờ đến hết buổi"*; nhớ bốn chiều
  thành một mốc duy nhất là làm sai đúng chiều đắt nhất.
- *Máy CHẶN hẳn việc sửa thành phần suất giữa giờ bán.* Bác 2026-09-01 (U-018) — máy chỉ nhắc.
  `quality/invariants.md` **I-011** bản đầu viết theo giả định "máy chặn" và đã phải **viết lại**
  ngay hôm sau; đó là bằng chứng vì sao câu này phải hỏi chứ không được suy.
- *Khoá giá theo lúc **mở phiên**.* Bác — nó xoá mất ca hai mức giá mà chủ quán vừa nói là đúng.
- *Dòng vừa sửa **giữ** giá cũ của lượt gọi.* Bác 2026-09-02 (U-026).

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.3.1–§3.3.6, §4.4 · `quality/invariants.md` I-009, I-010, I-011, I-013 ·
`master_plan/shop-facts.md` §4.5, §6.17, §6.19.

---

### ADR-024 — Vết thao tác trong MVP là BẮT BUỘC, và phạm vi của nó là thao tác chạm TIỀN và chạm TRẠNG THÁI

**Decision:**
Câu **10** của §10 kế hoạch gốc — *"có cần lưu lịch sử thao tác của nhân viên ở MVP không?"* — trả
lời là **CÓ**, với một phạm vi đã khoanh:

- **Bắt buộc lưu vết:** mọi thao tác **chạm tiền** (danh sách tám thao tác ở **I-012**) và mọi lần
  **đổi trạng thái** một đơn, một phiên bàn, hay một việc trạm — kể cả lần **lùi** một mẻ (§5.4).
- **Mỗi vết trả lời bốn câu:** cái gì đổi · bao nhiêu · **ai** bấm · lúc **mấy giờ**. Hai chỗ đòi
  thêm: **hoàn tiền** phải có **lý do** (ADR-020), **sửa giá một dòng** phải có **cả giá cũ lẫn
  giá mới** (ADR-023).
- **KHÔNG thuộc MVP:** một nhật ký ghi **mọi** thao tác của nhân viên — mở màn hình, xem báo cáo,
  tìm kiếm. Nó không nằm trong mười bốn năng lực của §7.2, và đối soát cuối ngày không cần nó.

**Ai đã quyết, và ADR này gộp lời của ai.** Không có một câu trả lời duy nhất mang tên *"câu 10"*;
lời chốt nằm ở **ba** chỗ, cả ba đều là lời **chủ quán**: **S-3** (2026-08-30 — người đứng quầy vừa
quyết vừa **ghi vết** mỗi lần hoàn tiền) · **§6.10** (2026-08-30 — đối soát cuối ngày, ngưỡng lệch
**0đ**) · **U-019** (2026-09-01 — nguồn thứ ba của đối soát). BA-10 **gộp** ba lời ấy thành một
phạm vi và **không thêm gì**: phần *KHÔNG thuộc MVP* dưới đây là chỗ chưa ai hỏi, và nó được ghi ra
đúng như thế chứ không được chốt hộ.

**Why:**
Cái vết là **điều kiện tồn tại** của ngưỡng lệch 0đ (ADR-022). *"Lệch một đồng cũng phải tìm ra lý
do"* chỉ là một câu chữ nếu thao tác gây ra chỗ lệch không có tên người và không có giờ.

Phạm vi dừng ở *chạm tiền và chạm trạng thái* vì đó đúng là tập thao tác làm hai con số của buổi
tối lệch nhau. Mở rộng ra *mọi* thao tác thì thêm khối lượng mà không thêm một câu trả lời nào cho
buổi đối soát.

**Rejected alternatives:**
- *Không lưu vết gì ở MVP, để pha sau làm.* Bác — ngưỡng 0đ của §4.9 sập ngay ngày đầu chạy thật,
  và hai tuần đối soát đầu tiên là thứ không chạy lại được.
- *Lưu nhật ký toàn bộ thao tác của nhân viên.* **Không bác — chỉ là chưa ai chốt.** Ghi rõ ở đây
  để phiên sau không đọc ADR này thành *"đã quyết định là không bao giờ làm"*: nó nằm ở
  `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.5 (*chưa ai cần tới*), và muốn đưa vào thì đi đường §7.8, không phải sửa
  ADR này.

**Applies to:**
`docs/product/0-ba/ban-hang/` §4.8, §4.9, §5.4, §7.2 dòng 12 · `quality/invariants.md` I-012 · ADR-016
(một cửa ghi là điều kiện để "ai bấm" trả lời được).

---
### ADR-025 — Phụ thu suất trứng là ×5, vì quả trứng LÊN GIÁ THEO NHÂN (S-1)

**Decision:**
Phụ thu của một suất trứng là **×5**, không phải ×4 ⇒ **suất trứng nhân thường = 25.000**, không
phải 24.000 (**S-1**, chủ quán xác nhận **2026-08-30**). Lý do là quả trứng **cũng lên giá theo
nhân**, đúng như bốn cái bánh của suất.

Cùng họ và cùng ngày chốt: **giá một suất giò = 9.000 + tiền 4 cái bánh theo nhân** (chủ quán chốt
2026-08-29). Cả hai đều là *giá tính từ thành phần*, đúng quy tắc gốc **giá một suất = tổng giá
các thành phần** (`master_plan/shop-facts.md` §4.6 quy tắc 1).

**Bảng giá `shop-facts.md` §4.3 KHÔNG đổi một con số nào** khi S-1 được xác nhận — nó đã viết theo
×5 từ đầu. Cái đổi là **tư cách** của con số ấy: từ *suy ra* thành *đã chốt*.

**Why:**
S-1 nằm ở `master_plan/shop-facts.md` §7.2 (*chỗ suy ra chưa xác nhận*) cho tới 2026-08-30, tức nó
là **suy luận của phiên**, không phải lời chủ quán nói thẳng. Một con số tiền đứng ở tư cách suy ra
là chỗ nguy hiểm nhất trong cả tài liệu: nó **đúng hình dạng** một dữ kiện đã chốt và không có gì
phân biệt được, cho tới lúc thu sai tiền của khách.

Câu kiểm chứng hỏi được vì nó hỏi **về cái quán**: *"một suất trứng nhân thường bán 25.000 hay
24.000?"* — không hỏi *"phụ thu nhân với mấy?"*. Bài học ấy về sau thành luật chung ở §7.2 sau khi
**S-4** phải hỏi lại lần hai (`work/findings.md` F-004).

**Rejected alternatives:**
- *Phụ thu ×4 — quả trứng là một thành phần giá cố định.* Bác 2026-08-30 bởi chính chủ quán.
- *Để con số ở tư cách "suy ra" và đi tiếp.* Bác — mọi bảng giá và mọi ca kiểm ở §4.8 đứng trên
  nó; một con số tiền không được phép đứng ở tư cách suy ra.

**Applies to:**
`master_plan/shop-facts.md` §4.2, §4.3, §4.6, §7.1, §7.2 · `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.1–§4.3 ·
`quality/invariants.md` I-013 · toàn bộ `prompt/BA/` (pointer đã sửa cùng ngày, T-004).

---

### ADR-026 — Vòng đời công việc trạm BỎ `Đang làm` và giữ `Đã làm xong, còn ở bếp` thay vào

**Decision:**
Vòng đời **công việc trạm** (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4) **không có** trạng thái `Đang làm`. Trạng thái
giữa của nó là **`Đã làm xong, còn ở bếp`** — bếp làm ra rồi nhưng chưa bưng ra bàn.

⇒ Bảng ở quầy có **BỐN** con số cho một bàn, không phải ba: cần · chưa làm · **đã làm xong còn ở
bếp** · đã bưng ra bàn. Cả **hai** mốc — *đã làm xong* và *đã bưng ra bàn* — do **người đứng quầy
bấm trên POS** (ADR-016, U-009 + U-017 + U-021); ba trạm bếp không bấm gì.

Bấm nhầm *"đã làm xong"* một mẻ thì **lùi được**: `Đã làm xong, còn ở bếp` ⇒ `Chưa làm`, và
**không có mốc thời gian cứng** nào chặn (**U-024**, chốt 2026-09-01). Mỗi lần lùi để lại vết
(ADR-024).

**Why:**
Hai lời chốt cộng lại, và một mình lời nào cũng chưa đủ:

1. **U-009 (2026-08-31): chủ quán bỏ mọi nút bấm ở ba trạm bếp** — *"bỏ bước ấy đi"*. Sau lời ấy
   **không còn nguồn nào** nói được cho máy biết bếp *bắt đầu* làm lúc nào. Một trạng thái không ai
   cập nhật được thì **hại hơn là không có**: nó luôn sai và không ai biết nó sai.
2. **S-4 (2026-09-01): bánh gấp xong CÓ nằm chờ thật** — chờ đủ đĩa, chờ người rảnh tay bưng, chờ
   món khác của cùng bàn. Ba lý do ấy do **chủ quán tự kể ra**, không ai gợi ý. ⇒ *làm xong* và
   *ra bàn* là **hai** việc khác nhau, nên cái chỗ trống mà `Đang làm` bỏ lại **có một trạng thái
   thật để điền vào**.

Nói cách khác: `Đang làm` bị bỏ vì **không ai bấm được nó**, còn `Đã làm xong, còn ở bếp` được
giữ vì **nó có thật trong bếp**. Đây là quyết định BA-07 để lại và BA-10 ghi thành ADR.

**Rejected alternatives:**
- *Giữ `Đang làm` và để POS suy ra.* Bác — quầy không nhìn thấy bếp bắt đầu lúc nào, và §7.2 của
  `shop-facts.md` ghi rõ bài học: hỏi về **cái quán** thì được trả lời, hỏi về **cái bảng trong
  máy** thì không.
- *Gộp *làm xong* và *ra bàn* thành một mốc.* Bác 2026-09-01 bởi chính lời chủ quán (S-4 vế 1) —
  gộp lại thì bảng quầy còn ba con số và bánh nằm chờ trở thành vô hình.
- *Để ba trạm bếp tự bấm.* Bác 2026-08-31 (U-009). `work/findings.md` **F-013** là cái giá của
  việc `master_plan/prompt-fullstack.md` còn thiết kế nút ấy sau khi chủ quán đã bỏ.
- *Không cho lùi một mẻ đã bấm nhầm.* Bác 2026-09-01 (U-024) — *"tuỳ theo thực tế để POS quyết
  định"*. **I-016** không phải sửa một chữ khi §5.4 thêm dòng ấy: nó khoá luật *chỉ đi theo bảng*,
  không khoá một danh sách ca cố định.

**Applies to:**
`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4, §5.6 · `master_plan/shop-facts.md` §5.4 · `quality/invariants.md` I-016 ·
**BA-12** (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 dựng bảng quầy — đọc **S-5** ở `shop-facts.md` §7.2 trước, vì
*bấm "đã bưng ra bàn" theo đơn vị nào* mới chỉ là chỗ **suy ra**).

---

### ADR-027 — Ghép bàn là MỘT phiên và MỘT hoá đơn, và chỉ ghép được sang bàn TRỐNG

**Decision:**
Ghép bàn là chuyện có thật ở quán, và hệ thống làm nó bằng **một phiên gắn nhiều bàn**, ra **một**
hoá đơn (**U-006**, chốt 2026-08-31). Câu *"một bàn một phiên"* đọc lại thành *"một bàn thuộc
**nhiều nhất một** phiên chưa thanh toán"* (**I-001**).

**Người đứng quầy bấm ghép, trên POS**, và **chỉ ghép được khi bàn kia còn TRỐNG** (**U-013**,
chốt 2026-08-31).

**Why:**
`master_plan/shop-facts.md` §6.16. Vế thứ hai đóng luôn ca đáng sợ nhất mà câu hỏi này mở ra:
**không bao giờ có việc gộp hai hoá đơn đã có tiền trong đó.** Ca ấy bị đóng bằng một **quyết định
nghiệp vụ**, không phải bằng một thiết kế khéo — và đó là cách rẻ nhất để đóng nó.

**Rejected alternatives:**
- *Cho ghép hai bàn đều đang có phiên, rồi gộp hai hoá đơn.* Bác 2026-08-31 — gộp hai hoá đơn đã
  có lượt gọi và có thể đã thu một phần là chỗ **thu thiếu tiền** dễ xảy ra nhất trong cả sản phẩm.
- *Mỗi bàn giữ một hoá đơn riêng rồi cộng tay lúc thu.* Bác — **I-002** tính tiền theo **phiên**,
  không theo bàn và không theo lượt gọi.

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.1.7, §5.3 · `quality/invariants.md` I-001, I-002 ·
`master_plan/shop-facts.md` §6.16 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 4.

---

### ADR-028 — Năm trạm làm việc; chủ quán đứng quầy vẫn giữ vai chủ quán

**Decision:**
Nhân viên **có** phân vai theo trạm (**U-001**, chốt 2026-08-30). **Năm** trạm: **quầy** · **tráng
bánh** · **gấp bánh** · **lấy canh** và **dọn bàn** — hai trạm cuối do **chung một người** làm
(`master_plan/shop-facts.md` §3).

**Chủ quán thỉnh thoảng đứng quầy, và vẫn giữ vai chủ quán** (**U-002**, chốt 2026-08-30). Hai
quyền đi theo hai thứ khác nhau, và không được trộn:

- Quyền của **người đứng quầy** (duyệt, huỷ, hoàn tiền, ghi nợ, ghép bàn, bấm bảng bếp) đi theo
  **chỗ đứng** — ai đang ở quầy thì có, kể cả chủ quán (ADR-016).
- Quyền của **chủ quán** (đổi giá, đổi thành phần suất trên mặt quản trị) đi theo **con người** —
  đứng ở đâu cũng có, và người đứng quầy **không** tự có nó (ADR-023).

**Why:**
`master_plan/shop-facts.md` §3, nhật ký §7.1 ngày 2026-08-30. Phân biệt hai chiều gắn quyền là thứ
giữ cho **U-004** (*chủ quán không đứng quầy thì nhờ người đứng quầy bấm huỷ*) và **§6.17** (*chỉ
chủ quán đổi giá*) cùng đúng một lúc mà không mâu thuẫn.

**Rejected alternatives:**
- *Nhân viên không phân vai — ai cũng làm mọi việc.* Bác 2026-08-30 (U-001).
- *Coi chủ quán là "một nhân viên nữa có thêm quyền".* Bác — mặt quản trị biến mất và ADR-011 mất
  chỗ đứng: ba mặt của sản phẩm phân biệt nhau đúng bằng vai này.
- *Tách "lấy canh" và "dọn bàn" thành hai người.* Bác — quán không có đủ người; đây là dữ kiện,
  không phải lựa chọn thiết kế.

**Applies to:**
`docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.3, §1.5 · `master_plan/shop-facts.md` §3 · ADR-011, ADR-016 ·
`docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 6 (nổ việc cho **đúng năm trạm**).

---

### ADR-029 — Suất "đem về" của khách ĐANG NGỒI BÀN thuộc phiên bàn, không sinh đơn mang đi

**Decision:**
Đơn mang đi **không** dùng chung bảng gom việc với bàn (**U-010**, chốt 2026-08-31). Nhưng khách
**đang ngồi bàn** gọi thêm một suất **đem về** thì suất ấy thuộc **phiên bàn** đang mở, kèm note
**"đem về"** phải rõ ràng — nó **không** sinh ra một đơn mang đi riêng.

**Why:**
`master_plan/shop-facts.md` §6.15. Người khách ấy trả tiền **một lần**, cho **một** hoá đơn, đúng
lúc đóng phiên. Tách suất đem về ra thành đơn `pickup` riêng là tạo **hai đơn vị thanh toán cho
một người đang ngồi trước mặt** — và quầy sẽ quên một trong hai.

Note *"đem về"* phải rõ vì nó đổi **việc của bếp** (gói mang đi thay vì bày đĩa), dù không đổi gì
ở phần tiền.

**Rejected alternatives:**
- *Sinh một đơn `pickup` riêng cho suất đem về.* Bác 2026-08-31 — **I-006** và **I-002** cùng cấm:
  tính tiền theo phiên bàn, và suất đem về của khách ngồi bàn không phải một đơn vị thanh toán độc
  lập.
- *Cho đơn mang đi dùng chung bảng gom việc với bàn.* Bác — bảng bàn gom theo **bàn**, đơn mang đi
  không có bàn để gom vào.

**Applies to:**
`docs/product/0-ba/ban-hang/` §2.1, §3.1.4 · `quality/invariants.md` I-006, I-007 ·
`master_plan/shop-facts.md` §6.15.

---

### ADR-030 — Đơn trả trước nhận TIỀN MẶT hoặc VietQR, và POS xác nhận vào lúc NHẬN TIỀN

**Decision:**
Đơn trả trước nhận đúng **hai** phương thức — **tiền mặt** hoặc **VietQR** — không có phương thức
thứ ba (**U-005**, chốt 2026-08-31). **POS xác nhận vào lúc NHẬN TIỀN**, không phải lúc khách bấm
chọn *"trả trước"*.

**Người đứng quầy là người duy nhất nói được câu *"đã nhận tiền"***, vì mã **VietQR là mã TĨNH**:
không có báo có tự động chạy về máy, nên máy không tự biết tiền đã về.

**Why:**
`master_plan/shop-facts.md` §6.3. Khoảng cách giữa *khách bấm chọn trả trước* và *tiền thật sự về*
là chỗ đơn được đẩy xuống bếp trong khi chưa ai trả đồng nào. Mã tĩnh làm khoảng cách ấy không tự
đóng lại được, nên nó phải đóng bằng **một người**.

Đây cũng là gốc của lời chốt sau này ở **GĐ-03** (khách nói đã chuyển khoản mà quầy chưa thấy báo
có): quầy bàn với khách và chọn một trong hai đường đã có — ghi **nợ** (ADR-019) hoặc **chờ tin
nhắn** (ADR-022).

**Rejected alternatives:**
- *Coi "khách bấm trả trước" là đã trả.* Bác — mã tĩnh, không có báo có tự động; đây là ca thu
  thiếu tiền rẻ nhất để tạo ra và đắt nhất để phát hiện.
- *Dùng cổng thanh toán online có webhook báo có.* Bác — ngoài phạm vi (`docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.4),
  và nó đổi cách quán nhận tiền chứ không chỉ đổi phần mềm.

**Applies to:**
`docs/product/0-ba/ban-hang/` §4.6, §4.7, §6.3 · `quality/invariants.md` I-012, I-015 ·
`master_plan/shop-facts.md` §6.3 · GĐ-03 (đã thay bằng quy tắc, §6.21).

---

### ADR-031 — Ba mảng quản trị được PHÉP làm, nhưng đi SAU luồng bán hàng

**Decision:**
**Không** mảng nào trong ba mảng quản trị — **nguyên liệu · con người · tài chính** — phải chạy
cùng **bản bán hàng đầu tiên** (**U-030**, chủ quán chốt 2026-09-02). Nguyên văn: *"không mảng nào
cần chạy với bán hàng. Bán hàng xong chạy được thì để chạy trước."*

Đây là một quyết định về **THỨ TỰ**, không phải một lần loại bỏ. Ranh giới §1.6 vẫn **mở**: ba mảng
ấy vẫn *được phép làm* (chủ quán chốt 2026-09-01, xác nhận lại 2026-09-02).

**Phân vai với ADR-013, vì hai mục dễ bị đọc chồng lên nhau:** ADR-013 nói **viết** nội dung admin
**vào đâu** (mục riêng có nhãn ở mỗi tài liệu). ADR này nói ba mảng ấy **đứng đâu trong thời gian**.

**Why:**
Hai lý do độc lập cùng chỉ một hướng, và trước 2026-09-02 chỉ có lý do thứ nhất:

1. **Lý do của tài liệu:** `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 có một điều kiện vào cửa — *§1–§6 đã mô tả nó* —
   mà §2 tới §6 **chưa có một quy tắc nghiệp vụ nào** cho ba mảng ấy. Một hạng mục MVP không trỏ
   được về mô tả nào là một hạng mục không ai làm được.
2. **Lý do của chủ quán:** họ vừa nói thẳng là **không cần** chúng ở bản chạy đầu.

⇒ **Hệ quả cho việc xếp lịch:** ADM-01…ADM-52 ở `work/admin-questions.md` §2 nay có một mốc để xếp
quanh — không phải *"chưa biết bao giờ"* mà là *"sau khi luồng bán hàng chạy được"*.

**Rejected alternatives:**
- *Xếp ba mảng vào `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.4 (**đã quyết định không làm**).* Bác — chủ quán vừa mở
  ranh giới cho chúng **hai lần**; §7.4 sẽ nói ngược lại lời họ.
- *Xếp vào §7.5 (**chưa ai cần tới**).* Bác — **có** người cần, chỉ là cần **sau**.
- *Mở ADM-01…ADM-52 thành task ngay bây giờ.* Bác — một task mở trước khi có luật nghiệp vụ là
  một task sẽ phải viết lại; điều kiện vào cửa §7.2 **không đổi** vì lời chốt này.

**Applies to:**
`docs/product/0-ba/` §1.6, §7.6 · `docs/product/1-system-design/architecture.md` §14 · `master_plan/shop-facts.md` §8 ·
`work/admin-questions.md` §2 · ADR-013.

**SỬA ĐỔI 2026-09-29 (ADR-068):** chủ repo mở thi công **lược đồ** admin cho phần đã đủ luật, trước
khi luồng bán hàng chạy được. Chữ *"sau"* ở trên còn nguyên cho pha 3 · pha 4 của admin và cho mọi
phần còn chờ lời chủ quán.

---

### ADR-032 — Cổng "một mã, hai chỗ, hai trạng thái" chạy Ở MỌI LƯỢT, không nằm trong `verify.sh`

**Ngày:** 2026-09-03 · **Trạng thái:** Accepted · **Người quyết:** phiên BA-13

**Decision:**
Phép kiểm *"cùng một mã định danh xuất hiện ở hai chỗ với hai trạng thái khác nhau"* sống ở
`scripts/check-doc-status.sh`, được `scripts/gate.sh` gọi **vô điều kiện** ngay sau
`check-links.sh` (Gate 1c) — **không** đặt trong `scripts/*.test.sh`.

**Why:**
`work/backlog.md` BA-13 đề xuất hai chỗ: một `scripts/*.test.sh`, hoặc một bước trong
`check-links.sh`. Chỗ thứ nhất **không chạy được vào đúng lượt sinh ra lỗi**: `gate.sh` bỏ qua
`verify.sh` khi thay đổi chỉ chạm tài liệu (ADR-005), mà lỗi loại này **chỉ sinh ra trong lượt chỉ
đổi tài liệu** — đóng một unknown là sửa mấy file `.md`. Một cổng chấm tài liệu mà ngủ đúng vào
lượt tài liệu đổi thì nó không phải cổng, nó là một bài test chạy nhờ.

Không nhét vào `check-links.sh` vì file ấy trả lời một câu khác — *đường dẫn có mở được không* —
và trộn hai câu vào một script làm cả hai khó đọc. Một script riêng, một dòng riêng ở `gate.sh`,
một dòng riêng ở `CLAUDE.md` §5.

**Điều kiện dựng cổng đã đủ, không phải "cho chắc":** CLAUDE.md §3.8 đòi cùng một vấn đề trả giá
**hai** lần. `work/findings.md` F-015 đã đo hai lần — 2026-09-02 (ba chỗ, BA-10) và 2026-09-03
(chỗ thứ tư, BA-11) — và chính F-015 viết sẵn câu *"lần hai thì dựng cổng"*.

**Ba phép so, và vì sao KHÔNG có phép thứ tư:**
Phép A (mã `U-XXX` đã đóng bị kể như còn treo) · phép C (một chuyển tiếp bảng §5 ghi là hợp lệ bị
phủ định ngay cạnh) · phép D (dòng `GĐ-XXX` ở bảng tổng hợp vs `Trạng thái:` trong thân).
Phép **B** — *"mọi ngôn ngữ còn-mở phải trỏ tới một thứ đang mở"* — đã viết, chạy thử, và **bỏ**:
nó ra **11 báo động trên cây ngày 2026-09-03 và cả 11 đều giả**. Một cổng kêu sai 11 lần là cổng
bị gỡ (F-018). Ca mà phép B định phủ — câu hỏng **không mang mã nào** — đã được phép C phủ bằng
đường khác.

**Alternatives rejected:**
- *Chép câu `awk` của F-015 làm cổng.* Bác — chính F-015 đo lại và nó bắt **2/4** chỗ: một chỗ lọt
  vì tài liệu **gói dòng** làm cụm khoá bị cắt đôi giữa hai dòng, một chỗ lọt vì nó **không mang
  mã**. Một bộ lọc viết cùng lúc với các ca đã biết thì nó tả **các ca ấy**, không tả **loại lỗi**
  (F-017, F-018). Script này vì thế **gộp khối trước khi chấm**, không đọc theo dòng.
- *Chấm cả `work/` và `prompt/`.* Bác — ở đó một câu đã hỏng được **trích dẫn làm bằng chứng**,
  đúng lý do Gate 1b cũng ngoảnh mặt khỏi hai thư mục ấy. Chấm chúng là đánh thuế lên đúng việc ta
  muốn người ta làm.
- *Không có đường ngoại lệ.* Bác — `scripts/check-doc-status.ignore` giữ chỗ trích dẫn cố ý, và
  một dòng ignore **không còn khớp gì** thì gate ĐỎ (cùng luật với `check-links.ignore`): ignore
  hết hạn phải gỡ, không được nằm lại làm nợ vô hình.

**Cái giá, viết ra để đừng ai ngạc nhiên:**
Ba phép đều là **heuristic ngôn ngữ**, không phải chứng minh. Chúng bỏ sót được, và chúng báo giả
được — vế *"khối này có nói lời chốt không"* là thứ duy nhất tách một câu đang sai khỏi một mục kể
lại lịch sử, và nó dựa vào cách viết. Cổng này **không** thay bước `grep -rn` của CLAUDE.md §7.2;
nó chỉ bắt lại phần mà bước ấy quên.

**Applies to:**
`scripts/check-doc-status.sh` · `scripts/check-doc-status.test.sh` ·
`scripts/check-doc-status.ignore` · `scripts/gate.sh` · `CLAUDE.md` §5 ·
`work/findings.md` F-015, F-021, F-022 · ADR-005.

---

### ADR-033 — Pha 1 có kế hoạch riêng ở `master_plan/`, mã bước là `P1-XX`, và đầu ra đi vào file MỚI cạnh `architecture.md`

**Trạng thái:** Đã chốt 2026-09-03 (T-048). Chủ repo yêu cầu trong phiên: *"BA về cơ bản đã xong,
pha tiếp theo sẽ là system design, hãy làm master plan cho system design thật kĩ và cẩn thận từng
bước"*.

**Decision:**
Ba quyết định, và cả ba đều là quyết định về **hình dạng**, không phải về nội dung pha 1.

1. **Kế hoạch pha 1 là một file MỚI ở `master_plan/`:**
   `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`. Nó là *đầu vào* của pha, đúng chỗ mà
   `CLAUDE.md` §2 dành cho `master_plan/`, và nó **không sở hữu sự thật nào** — cùng vai với
   `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` ở pha 0.
2. **Mã của mỗi bước là `P1-01`…`P1-12`, không phải `SD-01`…**
3. **Đầu ra pha 1 đi vào file mới trong `docs/product/1-system-design/`, một chủ đề một file**;
   `architecture.md` giữ nguyên §1–§14 và chỉ được sửa **tại chỗ** ở những dòng sai.

Kèm hai luật cho bảng bước, vì chúng là chỗ kế hoạch pha 0 đã trả giá:

- **Bảng bước KHÔNG có cột *Trạng thái*.** Owner của *Tasks* là `work/backlog.md` (`CLAUDE.md` §2).
- **Mười hai bước KHÔNG đổ vào *Ready* cùng lúc**; mỗi bước tạo entry lúc nhận việc.
  *(Vế **entry** đã đổi 2026-09-04 — xem khối **SỬA ĐỔI** cuối mục này. Vế ***Ready*** thì không
  đổi một chữ nào, và nó mới là vế mang lý do.)*

**Why:**

*1 — vì sao một file mới, không sửa bản nháp.* `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md`
đã bị banner hoá 2026-09-03 (ADR-014, khối *SỬA ĐỔI*) với đúng một câu: **"Không sửa ở đây"**. Nó
giữ `I1`–`I8`, bản đã bị `I-001`…`I-018` thay. Viết kế hoạch mới **vào** nó là hồi sinh một bản sao
cũ hơn owner thật — đúng F-001, và là kết cục mà ADR-014 đã cân nhắc rồi bác.

*2 — vì sao `P1-XX` chứ không `SD-XX`.* Bản nháp ấy dùng `SD-01`…`SD-07` làm **mã quyết định** (§1)
**và** `SD-01`…`SD-10` làm **mã task** (§7) — hai nghĩa cho một mã, trong cùng một file, với nội
dung khác nhau (ví dụ `SD-02` là *"một phiên bàn là một đơn vị tính tiền"* ở §1 và *"chốt các
invariant liên quan đến tiền"* ở §7). Đặt thêm một nghĩa thứ ba là dựng đúng cái bẫy mà repo này đã
ghi **ba** lần trong ba ngày: F-015 (một mã, hai chỗ, hai trạng thái) · F-021 (bảng nói ngược thân)
· F-022 (hai mục đã chốt trả lời khác nhau). `P1-` còn đọc được ngay là *pha 1*, khớp trục **pha**
mà ADR-014 đã chọn cho `docs/product/`.

*3 — vì sao file mới chứ không viết thêm vào `architecture.md`.* Ba lý do, xếp theo sức nặng:
**(a)** số mục của nó bị ghim: ADR-012 gọi *Nợ* = §12, ADR-013 gọi *admin* = §14, nên chèn mục mới
vào giữa là làm sai hai ADR mà `grep` không bắt được — đúng lý lẽ ADR-014 đã dùng để giữ số §1–§8.
**(b)** nó đã 592 dòng, và `work/findings.md` **F-014** đã xảy ra **năm** lần trên đúng loại file
dùng chung như thế; pha 1 có ba bước chạy song song được (P1-04 · P1-05 · P1-06). **(c)** một file
một chủ đề là hình dạng mà `docs/product/0-ba/ban-hang/` đang chạy đúng.

*Hai luật kèm theo.* Cột *Trạng thái* trong kế hoạch pha 0 (§11) và dòng `- [x]` trong
`work/backlog.md` là **hai bản của một sự thật**, và bản trong kế hoạch không bao giờ được cập nhật
— F-001 ở dạng nhẹ nhất của nó. Còn *Ready* thì `scripts/brief.sh` cắt ở **sáu** mục: mười hai dòng
đổ vào đó đẩy bảy dòng ra khỏi tầm nhìn của mọi phiên mới, đúng cơ chế đã làm `U-011` và `BA-12`
vô hình (**F-012**).

**Rejected alternatives:**
- *Sửa thẳng vào bản nháp pha 1.* Bác — banner của nó viết *"Không sửa ở đây"*, và lý lẽ đầy đủ ở
  ADR-014 khối *SỬA ĐỔI 2026-09-03*.
- *Không viết kế hoạch, cứ mở task pha 1 theo nhu cầu.* Đó là cách pha 0 **không** chạy, và pha 0
  chạy được: `BA_initial_plan…md` §11 là thứ giữ thứ tự BA-01→BA-13 suốt mười ngày. Pha 1 có ba
  chỗ đang bị chặn (U-031 · U-032 · S-5) và hai chỗ đang sai (F-023 · F-024); không có bản đồ thì
  mỗi phiên tự đoán một thứ tự và cả năm chỗ đó đều có cơ hội bị bước qua.
- *Dùng lại `SD-XX` và chấp nhận trùng, vì bản nháp "không sở hữu gì".* Bác — *không sở hữu sự
  thật* không có nghĩa là *không ai đọc*: `docs/product/00-index.md` mục *Pha 1* vẫn kể tên nó, nên
  nó vẫn được mở ra đọc. Trùng mã không làm cổng nào đỏ; nó chỉ làm người đọc sai, tức là đúng loại
  lỗi đắt nhất của repo này.
- *Đổ cả mười hai bước vào `work/backlog.md` ngay hôm nay.* Bác — F-012, và thêm một lý do thực
  dụng: bước P1-07 và P1-09 chờ **BA-12**, nên entry viết hôm nay sẽ mang những dòng *Constraints*
  chết trước khi ai nhận việc (cùng họ với F-013 · F-017).

**Applies to:**
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` (mới) · `docs/product/00-index.md` bảng *Pha 1* ·
`work/backlog.md` (T-048, P1-01) · `work/findings.md` **F-023**, **F-024** (mới) ·
`docs/product/99-unknowns.md` **U-032** (mới) · ADR-014 (bản nháp ở lại `master_plan/`) ·
ADR-012 · ADR-013 (số mục §12, §14 bị ghim) · `docs/product/1-system-design/architecture.md` (chỉ
sửa tại chỗ, không đánh số lại).

**SỬA ĐỔI 2026-09-04 — mô tả của cả mười hai bước được viết TRƯỚC, ở một file riêng (ADR-034)**

Luật thứ hai ở trên gộp hai thứ vào một câu: *mô tả* và *dòng trạng thái*. Chủ repo yêu cầu
2026-09-04 một sổ task riêng cho pha 1, và lượt T-049 tách hai thứ ấy ra:

- **Mô tả** cả mười hai bước viết **trước**, ở `work/backlog_SD.md`.
- **Dòng trạng thái** vẫn chỉ tạo lúc nhận việc, vẫn ở `work/backlog.md` → *Ready*.

Lý do của luật cũ **không mất**: thứ phải giữ là danh sách *Ready* mà `scripts/brief.sh` in ra, và
nó vẫn được giữ nguyên. Chi tiết ở **ADR-034**.

---

### ADR-034 — Pha 1 có sổ task riêng `work/backlog_SD.md`, và nó giữ MÔ TẢ trong khi `work/backlog.md` giữ TRẠNG THÁI

**Trạng thái:** Đã chốt 2026-09-04 (T-049). Chủ repo yêu cầu trong phiên: *"make me a backlog_SD
file for design system based on at least master plan design system and
`docs/product/1-system-design/architecture.md` and other as well"*.

**Decision:**
Ba câu, và ranh giới giữa chúng là thứ quyết định file nào được sửa khi có việc mới:

| File | Sở hữu | Không được giữ |
|---|---|---|
| `work/backlog.md` | **trạng thái** mọi task, kể cả `P1-XX`: *Ready* · *In Progress* · *Done* | mô tả dài của `P1-XX` |
| `work/backlog_SD.md` | **mô tả** mười hai bước pha 1: vì sao có bước, hỏng thì mất gì, mười bước chạy thế nào, bẫy | một dòng trạng thái nào |
| `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 | **thứ tự · mức · đầu ra kiểm chứng được** | mô tả và trạng thái |

Kèm ba luật:

1. **Mô tả cả mười hai viết trước; dòng trạng thái chỉ tạo lúc nhận việc.** Đây là chỗ sửa vế
   *entry* của ADR-033 (khối *SỬA ĐỔI 2026-09-04* ở mục ấy).
2. **Bước xong thì entry ở lại `work/backlog_SD.md`** kèm một dòng *Xong ngày…*; dòng `- [x]` đi
   vào `work/backlog.md` → *Done*. Không có mục *đã xong* riêng ở sổ pha 1.
3. **Ranh giới giữa hai sổ là *pha*, không phải *độ dài*.** Task không thuộc pha 1 vẫn viết đủ ở
   `work/backlog.md`.

**Why:**

*1 — vì sao KHÔNG viết mười hai entry vào `work/backlog.md`.* File ấy đã **4.600+ dòng**, và mười
hai entry của pha 1 sẽ cộng thêm khoảng 800. Nặng hơn con số: nó là file mà **mọi** phiên đều sửa,
và `work/findings.md` **F-014** đã xảy ra **năm** lần trên đúng loại file dùng chung như thế — riêng
trong hai ngày 2026-09-03 và 2026-09-04, ba phiên (T-048, BA-12, T-049) cùng chạm nó.

*2 — vì sao KHÔNG để trạng thái ở file mới.* `scripts/brief.sh` đọc `work/backlog.md` để in
*Ready* · *In Progress* vào **mọi** phiên mới (**ADR-002**). Một dòng trạng thái viết ở
`work/backlog_SD.md` là một dòng **không phiên nào thấy** — đúng họ lỗi **F-012**, nơi một mục nằm
ngoài tầm brief trở thành vô hình kể từ dòng đầu tiên nó được viết ra. Sửa `brief.sh` để đọc thêm
một file là một task khác, có ca kiểm riêng; ADR này **không** làm việc đó.

*3 — vì sao viết trước cả mười hai, ngược với ADR-033.* Lý do gốc của luật cũ là **danh sách
*Ready* bị cắt ở sáu mục**, không phải chỗ cất mô tả. Tách hai thứ ra thì giữ được cả hai: brief
vẫn chỉ thấy những bước nhận được ngay, còn người đọc thấy hết đường đi của pha trong một file. Cái
được thêm là thứ pha 0 không có: BA chạy mười ngày với mười ba entry nằm rải trong một file 4.600
dòng, và không lúc nào đọc được *"pha này còn lại những gì"* trong một lần.

**Rejected alternatives:**
- *Để `work/backlog_SD.md` giữ luôn trạng thái.* Bác — brief mù với nó (lý do 2). Đây là phương án
  trông gọn nhất và hỏng nặng nhất.
- *Không tạo file mới, viết mười hai entry vào `work/backlog.md`.* Bác — lý do 1, và nó cũng làm
  bảng mục lục đầu file ấy phải kể thêm một dãy mã của một pha khác.
- *Đổi `scripts/brief.sh` cho đọc cả hai sổ trong cùng lượt này.* Bác — brief là thứ mọi phiên mới
  đọc đầu tiên; sửa nó là **L2** có ca kiểm riêng (`scripts/brief.test.sh`), gộp vào đây là trộn
  hai task. Nếu sau này pha 2–5 cũng có sổ riêng thì đó là lúc việc ấy đáng làm.
- *Gộp kế hoạch và sổ task làm một.* Bác — kế hoạch ở `master_plan/` là **đầu vào** của pha
  (`CLAUDE.md` §2), sổ task là việc đang chạy; gộp lại thì mỗi lần nhận việc phải sửa một file mà
  §2 xếp vào loại *domain material*, và bảng bước sẽ mọc lại cột *Trạng thái* mà ADR-033 vừa bỏ.

**SỬA ĐỔI 2026-09-04 (T-052) — luật 3 đọc *pha*, và cái thứ hai cần sổ riêng lại không phải một pha**

Luật 3 ở trên viết *"ranh giới giữa hai sổ là **pha**, không phải **độ dài**"*. Câu ấy đúng ở phần
nó bác — độ dài không phải tiêu chí — và **hẹp** ở phần nó khẳng định: nó lấy *pha* làm trục vì lúc
viết chỉ có một ứng viên. Mảng **admin** là ứng viên thứ hai, và nó **không** là một pha: nó là một
**mảng nghiệp vụ** chạy ngang qua nhiều pha. Đọc luật 3 theo nghĩa đen thì hai mươi chín việc `ADM`
phải viết vào `work/backlog.md` — đúng thứ lý do 1 của ADR này đã bác.

**Từ nay đọc ở đâu:** **ADR-036** (cùng file, 2026-09-04). Trục là **lane**, và *pha 1* là một
lane trong ba. Ba luật còn lại của ADR-034 — mô tả viết trước · trạng thái ở `work/backlog.md` ·
entry ở lại sau khi xong — **không đổi**, và ADR-036 áp dụng lại cả ba nguyên văn.

**Applies to:**
`work/backlog_SD.md` (mới) · `work/backlog.md` (bảng mục lục + dòng *Ready* của P1-01 + khối chỉ
đường thay cho entry P1-01 đã chuyển đi) · `CLAUDE.md` §2 hàng *Tasks* và cây thư mục ·
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 · **ADR-033** (khối *SỬA ĐỔI 2026-09-04*) ·
**ADR-002** (brief đẩy trạng thái) · `work/findings.md` **F-012** · **F-014**.

---

### ADR-035 — Ranh giới sở hữu chạy theo PHA: lược đồ ở pha 2, hợp đồng API ở pha 3, route ở pha 4; pha 1 sở hữu TẦNG BẢO VỆ

**Trạng thái:** Đã chốt 2026-09-04 (**P1-01**, bước 1/12 của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`
§6, ADR-033). Nó sửa một câu của **ADR-014** (khối *SỬA ĐỔI 2026-09-04* ở mục ấy) và đóng
`work/findings.md` **F-023**.

**Vấn đề nó giải quyết — ba tài liệu nói ba câu khác nhau về cùng một câu hỏi.** Đo 2026-09-03
(T-048), ghi thành F-023: ADR-014 **giao** tên bảng · tên cột · khoá ngoại · API · route cho hai
tài liệu; `docs/product/1-system-design/architecture.md` §8 **từ chối** ba thứ đầu (*"Điều tài liệu
này cố ý KHÔNG làm"*); banner `master_plan/prompt-fullstack.md` khai cả bốn thứ *"CHƯA có nhà"*;
và bảng `CLAUDE.md` §2 **im lặng** — không có hàng nào cho chúng.

**Decision:**
Sở hữu chạy theo **trục pha**, đúng trục mà bảng sáu pha (`master_plan/prompt-fullstack.md` §7) đã
dùng. Sáu hàng, và ba hàng giữa cố ý **chưa có owner**:

| Thứ | Ai sở hữu | Hôm nay nằm ở đâu |
|---|---|---|
| Mệnh đề bất biến `I-0xx` | **owner đã có** | `quality/invariants.md` — `I-001`…`I-020` (`CLAUDE.md` §2) |
| **Tầng bảo vệ** của từng `I-0xx` + phép đối chiếu | **pha 1** | `docs/product/1-system-design/` — file sinh ra ở **P1-04…P1-06** |
| **Yêu cầu hình dạng dữ liệu** viết bằng ngôn ngữ nghiệp vụ | **pha 1** | `docs/product/1-system-design/` — file sinh ra ở **P1-07** |
| **Lược đồ**: tên bảng, tên cột, khoá ngoại, quan hệ, thứ tự migration | **pha 2 · DB** | **chưa có owner** — sinh ra cùng `docs/product/2-db/` |
| **Hợp đồng API**: endpoint, quyền theo vai, chữ ký | **pha 3 · BE** | **chưa có owner** — sinh ra cùng `docs/product/3-be/` |
| **Route · component** | **pha 4 · FE** | **chưa có owner** — sinh ra cùng `docs/product/4-fe/` |

Kèm bốn luật, và không luật nào là hình thức:

1. **Một tài liệu của pha sớm hơn nêu tên bảng · endpoint · route là bug**, kể cả khi mọi cổng
   xanh — không cổng nào của repo này đọc được ranh giới ấy. Cái chấm là **P1-12** (bộ lọc trên
   mọi file pha 1) và mắt người.
2. **Hàng *chưa có owner* đổi thành tên file thật trong CÙNG thay đổi mở thư mục của pha ấy.**
   Không mở thư mục trước, không tạo file giữ chỗ (`docs/product/00-index.md` mục *Luật ghi*;
   ADR-014 khối *SỬA ĐỔI 2026-09-02* đã bác `00-chua-co-gi.md`).
3. **`master_plan/prompt-fullstack.md` §3.4–§3.7 không sở hữu thứ gì.** Đề xuất stack · 16 bảng ·
   API · route ở đó là **đầu vào để pha 2–4 đối chiếu**, không phải đầu ra đã chốt. Bản ấy viết
   **2026-08-31**, trước phần lớn quyết định của chủ quán, và banner của chính nó đã tự khai
   *"không phải nhà của sự thật nào"*.
4. **Pha 1 không sở hữu lược đồ, nên nó cũng không được phép sửa đề xuất ấy.** Gặp chỗ đề xuất
   thiếu ⇒ viết **yêu cầu** để pha 2 tự đối chiếu (P1-07), không sửa hộ.

**Why:**

- **Trục pha đã có, và đã kèm sẵn luật chống chép.** Bảng sáu pha §7 kết bằng đúng câu ranh giới
  cứng: *"pha 0–1 **không** nhắc tên bảng; pha 2 **không** nhắc endpoint; pha 3 **không** nhắc
  component; pha 4 **không** đổi hợp đồng API"*. Quyết định này **không dựng trục mới** — nó chép
  trục đang chạy vào owner, lần đầu. Đây cũng là lý lẽ ADR-014 khối *SỬA ĐỔI 2026-09-02* đã dùng
  để chọn pha thay vì mảng: bắt cả repo học một trục thứ hai là cái giá không ai trả.
- **Một hàng nói *chưa có* vẫn hơn một bảng im lặng.** Bảng §2 im lặng biến câu hỏi thành một chỗ
  trống mà ai đi qua cũng có quyền lấp; một hàng ghi *sinh ra ở pha 2* biến nó thành một việc có
  lịch và có người. Đây là điều kiện thứ ba mà F-023 → *Decision / Fix* đòi.
- **Chỗ này nằm đúng trên đường đi của pha 2, và cái giá đo được.** Phiên mở pha 2 đọc ADR-014,
  tới §8, thấy nó từ chối, rồi hoặc **bơm tên bảng vào `architecture.md`** — phá đúng câu §8 của
  chính nó và biến một tài liệu mà `docs/product/00-index.md` giới thiệu là *"đặc tả, không phải
  mã"* thành nửa lược đồ — hoặc **thi công đề xuất 16 bảng như một lược đồ đã chốt**, mà
  `architecture.md` §8 đã đo **sáu** thứ nó chưa có chỗ cất, trong đó có **vết hoàn tiền** và
  **khoản nợ**. Thiếu hai thứ ấy thì đối soát ngưỡng lệch **0đ** không thực hiện được (ADR-022 ·
  `master_plan/shop-facts.md` §6.10) — cổng chất lượng mạnh nhất của cả dự án.
- **Nó mở khoá mười bước còn lại của pha 1.** Mười trong mười một bước ở §6 kế hoạch ghi *Cần xong
  trước: P1-01*, và cổng P1-12 (*không tên bảng nào lọt vào file pha 1*) không có gì để chấm cho
  tới khi ranh giới này được viết ra.

**Rejected alternatives:**

- *Đọc ADR-014 theo nghĩa đen: giao lược đồ · API · route cho `architecture.md`.* Bác. §8 của
  chính file ấy cấm, và `docs/product/00-index.md` giới thiệu nó là *"đặc tả, không phải mã…
  không nói tên hàm, tên file hay thư viện"*. Chọn đường này là phải sửa **cả hai** câu ấy, tức
  viết lại ranh giới pha 0–1 của bảng sáu pha — một quyết định lớn hơn nhiều lần cái nó sửa, để
  đổi lấy một owner mà không ai xin.
- *Ghi `master_plan/prompt-fullstack.md` §3.5 là owner của lược đồ, vì nó là chỗ **duy nhất** hôm
  nay thật sự có 16 bảng.* Bác, và đây là đường nguy hiểm nhất vì nó **rẻ và trông đúng**. Ba lý
  do: nó là **bản xuất khẩu**, banner của chính nó viết *"không phải nhà của sự thật nào… là bản
  chép nên nó sẽ trôi"* (F-001); nó viết **2026-08-31**, trước hơn hai mươi lời chốt của chủ quán;
  và `architecture.md` §8 đã đo được **sáu** chỗ nó chưa cất được. Cụ thể hơn mọi thứ khác không
  có nghĩa là đã chốt.
- *Mở sẵn `docs/product/2-db/`, `3-be/`, `4-fe/` với một file giữ chỗ, để mỗi hàng §2 có một owner
  thật ngay hôm nay.* Bác. `docs/product/00-index.md` mục *Luật ghi* và ADR-014 khối *SỬA ĐỔI
  2026-09-02* đã bác đúng cái này một lần (`00-chua-co-gi.md`): một file tên *"chưa có gì"* là tài
  liệu nghi lễ (`CLAUDE.md` §3.8), và một thư mục rỗng không gỡ được dòng nào cho ai. Cái giá của
  việc bác: ba hàng §2 trỏ vào một đường **chưa tồn tại**, nên Gate 1b không chấm được chúng —
  ghi ra ở *Rủi ro còn lại* dưới đây.
- *Để lửng, chờ phiên mở pha 2 tự quyết.* Bác — đó **chính là** hiện trạng mà F-023 mô tả, và nó
  đã đứng đó từ 2026-09-02 tới 2026-09-04 mà không cổng nào đỏ.

**Rủi ro còn lại, ghi ra để phiên sau khỏi dò:**

- **Ba hàng *chưa có owner* là vùng mù của Gate 1b.** `scripts/check-links.sh` chỉ chấm đường dẫn
  có đuôi biết trước, nên `docs/product/2-db/` không bị chấm — cố ý, vì nó chưa tồn tại. Đổi lại,
  không cổng nào nhắc khi pha 2 mở ra mà quên đổi hàng ấy. Cái chấm là **luật 2** ở trên và mắt
  người.
- **Không cổng nào của repo đọc được ranh giới pha.** Một tên bảng viết vào file pha 1 đi qua cả
  năm cổng mà không cổng nào đỏ. P1-12 là phép rà duy nhất, và nó chạy **một lần, cuối pha**.

**Applies to:**
`CLAUDE.md` §2 (bốn hàng mới) · **ADR-014** khối *SỬA ĐỔI 2026-09-04* ·
`docs/product/1-system-design/architecture.md` §8 · `master_plan/prompt-fullstack.md` banner ·
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §3 và §8 · `work/findings.md` **F-023** (Fixed)
· mọi bước **P1-02…P1-12** · mọi việc của **pha 2–5**.

---

### ADR-036 — Mảng admin có sổ task riêng `work/backlog_AD.md`, và ranh giới giữa ba sổ nay là LANE chứ không phải pha

**Trạng thái:** Đã chốt 2026-09-04 (T-052). Chủ repo yêu cầu trong phiên: *"hãy làm backlog_AD cho
admin"*. Nó sửa **luật 3** của **ADR-034** (khối *SỬA ĐỔI 2026-09-04* ở mục ấy).

**Vấn đề nó giải quyết.** Hai mươi chín việc `ADM-01`…`ADM-53` — ba mảng nguyên liệu · con người ·
tài chính — sống trong `work/admin-questions.md` §2 dưới dạng **sáu cái bảng một dòng một việc**.
File ấy tự khai *"không sở hữu sự thật nào"* và banner của nó nói nó **sẽ bị xoá** khi mọi câu hỏi
đã chuyển đi. Nghĩa là danh sách việc của cả một mảng đang nằm trong một file có ngày hết hạn, ở độ
sâu một dòng — không có *vì sao có việc này*, không có *không làm thì mất gì*, không có chỗ chặn.

**Decision:**
Bốn file, bốn việc:

| File | Sở hữu | Không được giữ |
|---|---|---|
| `work/backlog.md` | **trạng thái** mọi task, kể cả `ADM-XX`: *Ready* · *In Progress* · *Done* | mô tả dài của `ADM-XX` |
| `work/backlog_AD.md` | **mô tả** hai mươi chín việc của mảng admin | một dòng trạng thái nào; câu hỏi cho chủ quán; dữ kiện quán |
| `work/admin-questions.md` | **câu hỏi** cho chủ quán và **chỗ chủ quán trả lời** (§3) | danh sách việc (§2 nay là một dòng chỉ đường) |
| owner ở `CLAUDE.md` §2 | lời giải: dữ kiện quán · luật nghiệp vụ · quyết định | — |

Kèm ba luật:

1. **Trục là LANE, không phải pha.** Ba lane có sổ riêng tính tới hôm nay: **pha 1** ở
   `work/backlog_SD.md` · **mảng admin** ở `work/backlog_AD.md` · **phần còn lại** ở
   `work/backlog.md`. Một lane được tách sổ khi nó có **một dãy mã riêng** và **một chuỗi việc đọc
   liền nhau**; hai điều kiện, và cả hai phải có.
2. **Ba luật của ADR-034 áp dụng lại nguyên văn**: mô tả viết trước · trạng thái chỉ ở
   `work/backlog.md` · việc xong thì entry ở lại kèm một dòng *Xong ngày…*.
3. **Entry ở sổ admin viết tại tầng nghiệp vụ.** Không tên bảng · endpoint · route · component
   (**ADR-035**). Chữ *"màn"* trong tên vài việc là tên gọi tắt của một **năng lực**, thừa kế từ
   `work/admin-questions.md` §2; nó không phải một route.

**Why:**

*1 — vì sao không để danh sách ở `work/admin-questions.md` §2.* File ấy có **ngày hết hạn** ghi
trong banner của chính nó. Một danh sách việc sống trong một file sẽ bị xoá là danh sách sẽ mất, và
mất im lặng — đúng hình dạng **F-001**, chỉ khác chiều: ở F-001 bản chép trôi khỏi bản gốc, ở đây
**bản gốc biến mất** và không còn bản nào.

*2 — vì sao không đổ hai mươi chín entry vào `work/backlog.md`.* Lý lẽ của ADR-034 nguyên vẹn, chỉ
đổi con số: file ấy đã **4.700+ dòng**, là file **mọi** phiên đều sửa, và **F-014** đã xảy ra năm
lần trên đúng loại file dùng chung ấy. Hai mươi chín entry cộng thêm khoảng 900 dòng.

*3 — vì sao trục là lane chứ không phải pha.* Mảng admin đi ngang **mọi** pha: nó có phần BA (luật
nghiệp vụ), phần system design (hình dạng dữ liệu, quyền), rồi DB · BE · FE. Xếp nó vào một pha là
xếp sai; để nó không có sổ vì nó không phải pha là để trục thắng nhu cầu. Trục **lane** phủ được cả
hai ứng viên đang có, và nó cũng là trục mà `work/admin-questions.md` §2 và **ADR-013** đã dùng khi
gọi tên *mảng*.

*4 — cái đo được ngay khi dựng sổ.* Viết mô tả cho cả hai mươi chín việc lộ ra hai điều mà danh
sách một dòng không thể lộ: **hai mươi ba việc bị chặn bởi câu hỏi chưa hỏi chủ quán**, và **năm
việc không còn phần nghiệp vụ nào** — luật của chúng đã chốt sẵn ở mảng bán hàng, phần còn lại
thuộc pha 2–4. Không có sổ thì cả hai con số ấy chỉ lộ ra vào lúc ai đó nhận nhầm một việc.

**Rejected alternatives:**
- *Viết mô tả thẳng vào `work/admin-questions.md` §2.* Bác — lý do 1 (file có ngày hết hạn), và nó
  còn trộn hai việc khác nhau trong một file: chỗ **hỏi** và chỗ **giữ việc**.
- *Không tạo sổ mới, đổ hai mươi chín entry vào `work/backlog.md`.* Bác — lý do 2.
- *Tách theo **pha** cho mảng admin: phần BA vào một sổ, phần system design vào sổ khác.* Bác — nó
  cắt một chuỗi việc đọc liền nhau thành nhiều mảnh, và người nhận việc phải ghép lại ở trong đầu.
  Chỗ mảng admin chạm pha 1 được xử bằng **một bảng sáu hàng** ở đầu `work/backlog_AD.md`, không
  bằng cách chia đôi sổ.
- *Chờ chủ quán trả lời hết 54 câu rồi mới dựng sổ.* Bác, và đây là đường trông cẩn thận nhất mà
  hỏng nặng nhất: **chính cái sổ** là thứ nói ra câu nào chặn việc nào. Không có nó thì 54 câu là
  một danh sách phẳng, không ai biết hỏi câu nào trước.
- *Cho `scripts/brief.sh` đọc cả ba sổ trong cùng lượt này.* Bác — cùng lý lẽ ADR-034 đã dùng:
  brief là thứ mọi phiên mới đọc đầu tiên, sửa nó là **L2** có ca kiểm riêng
  (`scripts/brief.test.sh`), gộp vào đây là trộn hai task. Cái giá của việc bác: một việc `ADM`
  không có dòng ở `work/backlog.md` là một việc brief không thấy — nên luật 1 của ADR-034 (trạng
  thái **chỉ** ở `work/backlog.md`) là thứ giữ cho cái giá ấy bằng không.

**Rủi ro còn lại, ghi ra để phiên sau khỏi dò:**
- **Ba sổ là ba chỗ phải nhớ.** Phiên mới đọc brief thấy trạng thái, nhưng phải biết mô tả nằm ở
  sổ nào. Cái chấm là bảng mục lục đầu `work/backlog.md` và hai khối chỉ đường trong đó — không
  cổng nào kiểm được chuyện này.
- **Không cổng nào đọc được ranh giới lane.** Một entry `ADM` viết vào `work/backlog.md`, hay một
  dòng trạng thái viết vào `work/backlog_AD.md`, đi qua cả năm cổng mà không cổng nào đỏ. Giống
  hệt vùng mù mà **ADR-035** ghi cho ranh giới pha, và cách chấm cũng giống: mắt người.

**Applies to:**
`work/backlog_AD.md` (mới) · `work/backlog.md` (bảng mục lục + khối chỉ đường + dòng *Ready* của
ADM-53) · `work/admin-questions.md` §2 · `CLAUDE.md` §2 hàng *Tasks* và cây thư mục · **ADR-034**
(khối *SỬA ĐỔI 2026-09-04*) · **ADR-013** (mục riêng có nhãn — không đổi) · **ADR-031** (ba mảng đi
sau bán hàng — không đổi) · **ADR-002** (brief đẩy trạng thái) · `work/findings.md` **F-001** ·
**F-012** · **F-014** · **F-028**.

---

<a id="ban-do"></a>
## Bản đồ — mọi câu hỏi BA nằm ở quyết định nào

Mục này tồn tại để trả lời đúng một câu: **có câu hỏi nghiệp vụ nào bị bỏ sót không.** Nó không giữ
sự thật nào của riêng nó; mọi ô đều trỏ về một mục ở trên hoặc một `GĐ` ở dưới.

### Mười câu của §10 kế hoạch gốc

`master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §10 liệt kê mười câu **phải chốt trước khi sang
System Design**. Tính tới **2026-09-02**, cả mười đều đã chốt.

| # | Câu hỏi | Đã chốt ở | Trạng thái |
|:--:|---|---|---|
| 1 | Ai xác nhận, huỷ và chỉnh sửa đơn? | **ADR-016** (xác nhận, huỷ) · **ADR-017** (sửa) | ✅ đủ ba vế |
| 2 | Đơn đã xác nhận được sửa hay chỉ huỷ/tạo lại? | **ADR-017** | ✅ |
| 3 | Món hết sau khi khách đặt thì xử lý thế nào? | **ADR-018** | ✅ (thay GĐ-02) |
| 4 | Khách không thanh toán được thì phiên bàn ở trạng thái nào? | **ADR-019** | ✅ |
| 5 | Có hoàn tiền không, ai được phép? | **ADR-020** | ✅ |
| 6 | Giờ khách cần hàng có bắt buộc không, với kênh nào? | **ADR-021** | ✅ cả `pickup` **và** `phone_preorder` |
| 7 | `delivery` chỉ ghi nhận đơn hay quản lý trạng thái giao? | **ADR-021** | ✅ có `Đang giao` |
| 8 | Doanh thu tính theo ngày nào, đơn huỷ/hoàn ra sao? | **ADR-022** (+ ADR-019, ADR-020 cho hai mốc ngày) | ✅ |
| 9 | Chủ quán đổi giá đang bán ngay được không? | **ADR-023** | ✅ |
| 10 | Có cần lưu lịch sử thao tác nhân viên ở MVP không? | **ADR-024** | ✅ có, phạm vi đã khoanh |

### Mọi Unknown đã mở từ BA-01 tới BA-09

Ba mươi câu, **U-001 → U-030**, mở bởi các prompt 01–08 cộng BA-09. Không câu nào còn mở
(`docs/product/99-unknowns.md`, mục *Đang mở* rỗng tính tới 2026-09-02).

| U | Câu hỏi (rút gọn) | Nằm ở |
|---|---|---|
| U-001 | Nhân viên có phân vai theo trạm không | **ADR-028** |
| U-002 | Chủ quán có phải là nhân viên không | **ADR-028** |
| U-003 | Đơn hotline rồi khách tới ăn tại quán | **ADR-015** |
| U-004 | Ai được bấm huỷ một đơn | **ADR-016** |
| U-005 | Đơn trả trước trả bằng gì, ai xác nhận, lúc nào | **ADR-030** |
| U-006 | Ghép bàn thì hệ thống phải làm gì | **ADR-027** |
| U-007 | Khách rời quán chưa trả tiền thì ai đóng phiên | **ADR-019** |
| U-008 | Một nồi làm được bao nhiêu; trứng và bánh tranh nồi | **ADR-009** *(dữ kiện năng lực nồi: `shop-facts.md` §5.4)* |
| U-009 | Ai bấm *đã làm xong* / *đã bưng ra bàn* | **ADR-026** · **ADR-016** |
| U-010 | Đơn mang đi có chung bảng gom việc với bàn không | **ADR-029** |
| U-011 | Máy có được tự chia mẻ không | **ADR-009** *(máy chỉ hiện tổng nhu cầu, người tự gom)* |
| U-012 | Nợ: ai ghi nhận, doanh thu tính ngày nào | **ADR-019** |
| U-013 | Ai bấm ghép bàn, ghép được khi bàn kia đang mở không | **ADR-027** |
| U-014 | Đổi giá ngay giữa giờ bán được không | **ADR-023** |
| U-015 | Phiên vắt qua mốc đổi giá thì hoá đơn ra sao | **ADR-023** |
| U-016 | Đổi thành phần suất giữa giờ bán được không | **ADR-023** |
| U-017 | Bấm *đã làm xong* theo từng cái, cả mẻ, hay cả bàn | **ADR-026** |
| U-018 | Máy chặn hẳn hay chỉ nhắc khi sửa thành phần suất | **ADR-023** |
| U-019 | Đối chiếu phần chuyển khoản bằng gì · hoàn tiền trừ ngày nào | **ADR-022** · **ADR-020** |
| U-020 | Khách trả một phần tiền mặt, một phần chuyển khoản | **ADR-022** |
| U-021 | Ai bấm *đã bưng ra bàn* | **ADR-026** · **ADR-016** |
| U-022 | Sửa một đơn được phép tới trạng thái nào | **ADR-017** |
| U-023 | Ai bấm cho đơn sang `Đang giao`, lúc nào | **ADR-021** |
| U-024 | Bấm nhầm một mẻ thì có đường lùi không | **ADR-026** |
| U-025 | Sổ giấy: ai giữ, ghi gì, nhập lại lúc nào | **ADR-016** |
| U-026 | Một dòng vừa sửa thì tính giá lúc nào | **ADR-023** |
| U-027 | Đơn đã `Hoàn thành` có huỷ được không | **ADR-017** |
| U-028 | *(hai phiên song song cùng lấy số này 2026-09-02; không câu hỏi nào mang số ấy hôm nay)* | — |
| U-029 | *(chưa bao giờ được cấp — dãy số nhảy vì cùng sự cố trên)* | — |
| U-030 | Mảng quản trị nào phải có ở bản chạy đầu tiên | **ADR-031** |

> **U-028 và U-029 là hai chỗ trống có thật trong dãy số, không phải hai câu hỏi bị mất.** Ngày
> 2026-09-02 hai phiên chạy song song **cùng lấy số U-028** — sự cố ghi trong `work/backlog.md`
> entry **T-042** (*"lần thứ sáu, và lần này CÓ thiệt hại"*) cùng với hai va chạm khác của cùng
> ngày, và ở `work/findings.md` **F-014**. Không câu hỏi nào mang số U-028 hay U-029 trong
> `docs/product/99-unknowns.md` hôm nay. Phiên sau **không** tái sử dụng hai số này: câu hỏi mới lấy **U-031**.

### Năm chỗ SUY RA — S-1 tới S-5

`master_plan/shop-facts.md` §7.2 giữ những chỗ được **suy ra** từ luật đã chốt chứ không phải lời
chủ quán nói thẳng. Bốn chỗ đã được xác nhận và lên §7.1; **S-5** vẫn còn là chỗ suy ra.

| S | Chỗ suy ra | Hỏi ngày | Nằm ở |
|---|---|---|---|
| S-1 | Phụ thu suất trứng ×5 hay ×4 | 2026-08-30 ✅ | **ADR-025** |
| S-2 | Số điện thoại và địa chỉ giao là hai trường bắt buộc | 2026-08-30 ✅ | **ADR-015** |
| S-3 | Ai ghi vết mỗi lần hoàn tiền | 2026-08-30 ✅ | **ADR-020** |
| S-4 | *"Đã làm xong, còn ở bếp"* có phải một con số riêng | 2026-08-31 (hỏng) → 2026-09-01 ✅ | **ADR-026** |
| S-5 | Bấm *"đã bưng ra bàn"* theo **đơn vị nào** | **chưa hỏi** | ⚠️ vẫn là chỗ **suy ra** — `shop-facts.md` §7.2, **BA-12** phải đọc trước khi dựng bảng quầy |

**S-5 không phải một `GĐ` và không phải một `U`.** Nó là chỗ *suy ra* — có một câu trả lời tạm
(theo **bàn**, vì một mẻ phục vụ nhiều bàn còn bưng thì bưng tới một bàn) nhưng chưa ai hỏi chủ
quán. Chỗ của nó là `master_plan/shop-facts.md` §7.2, và nó **không** vào mục *Unknowns* của
`docs/product/99-unknowns.md` (`work/findings.md` F-004: chỗ suy ra phải tách khỏi chỗ đã chốt).

---
## Giả định BA — ngoại lệ chưa có lời chốt

Mục này giữ **giả định tạm thời** cho những dòng mang dấu ⚠ trong `docs/product/0-ba/ban-hang/06-ngoai-le.md` §6. Một `GĐ`
**không phải** một quyết định: nó là chỗ ghi lại *nếu không ai trả lời thì hôm nay quán đang ngầm
làm thế nào*, kèm **mức rủi ro** nếu giả định ấy sai. Có lời chủ quán thì `GĐ` bị **thay** bằng
quy tắc trong owner của nó (`master_plan/shop-facts.md`), không phải sửa tại chỗ.

Mọi `GĐ` dưới đây mở ngày **2026-09-02**, do **BA-08** (`docs/product/0-ba/ban-hang/06-ngoai-le.md` §6).

**CẢ NĂM mục đã bị thay trong ngày 2026-09-02, và mục này nay không giữ giả định nào còn hiệu
lực.** Ba mục đầu bị thay ở lượt một (T-042 — GĐ-02, GĐ-03, GĐ-04), hai mục cuối ở lượt cuối
(T-045 — GĐ-01, GĐ-05). Tất cả giữ lại **có gạch ngang**, kèm lời chốt thật ở đầu, vì chỗ chúng
đoán **lệch** là thứ đáng đọc.

**Năm lần đoán, hai kiểu lệch — và kiểu thứ hai mới là kiểu nguy hiểm.**

- **Bốn lần đoán CHẶT HƠN quán thật** (GĐ-02, GĐ-03, GĐ-04, và một nửa GĐ-05): dựng ra một luật
  cứng ở nơi chủ quán cố ý **không** đặt luật nào. Kiểu này lộ ra ngay khi hỏi, vì câu trả lời
  mâu thuẫn thẳng với giả định.
- **Một lần đoán THIẾU** (GĐ-01, và nửa còn lại của GĐ-05): đoán **đúng** phần cơ chế — người bấm
  sau thắng, không có nút hoàn tác — nhưng bỏ mất thứ chủ quán coi là điều kiện đi kèm: **bản copy
  trước và sau, lý do, người sửa**. Kiểu này **không** lộ ra khi hỏi câu đã viết: hỏi *"ai thắng?"*
  thì được xác nhận là đoán đúng, và yêu cầu kia chỉ xuất hiện vì chủ quán tự nói thêm. ⇒ Một giả
  định được xác nhận **không** có nghĩa là đã đủ; nó chỉ có nghĩa là phần **đã hỏi** thì đúng.

⇒ Yêu cầu ấy nay là `master_plan/shop-facts.md` **§6.22** và `quality/invariants.md` **I-018**.

### GĐ-01 — ~~Hai người cùng thao tác trên một bàn~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 4 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** —
`master_plan/shop-facts.md` §6.22, `quality/invariants.md` I-018

> **Chủ quán chốt 2026-09-02:** *"đồng ý, nhưng cần note ai là người sửa. Hệ thống cần record sửa
> cái gì, có bản copy trước khi sửa là thế nào, sau khi sửa là thế nào, ai sửa — để đối chiếu."*
> Giả định bên dưới đoán **đúng cơ chế** (người bấm sau thắng) nhưng **thiếu điều kiện đi kèm**:
> lần ghi đè phải giữ **bản trước, bản sau và tên người sửa**. Đó không phải chi tiết kỹ thuật —
> không có bản trước thì một lượt gọi bị đè mất sẽ không ai truy ra, và đó là **thu thiếu tiền**.
> Đọc quy tắc ở `shop-facts.md` §6.22, đừng đọc phần dưới.

**Giả định.** Hai người cùng sửa một phiên bàn thì thao tác **tới POS sau** là thao tác có hiệu
lực; không có khoá, không có cảnh báo.

**Vì sao tạm chấp nhận được.** POS là **cửa duy nhất được ghi** (`docs/decisions.md` ADR-011) và
quán chỉ có **một** máy POS đặt ở quầy (`shop-facts.md` §6.13), nên hai lượt ghi thật sự đồng thời
là hiếm. Ca có thật là **khách quét QR trong lúc quầy đang bấm** cho cùng bàn ấy.

**Rủi ro nếu sai.** Một lượt gọi bị đè mất ⇒ **thu thiếu tiền** đúng kiểu `shop-facts.md` §6.1
cấm. Xếp TRUNG BÌNH chứ không CAO vì lượt gọi của khách và thao tác của quầy ghi vào **hai chỗ khác
nhau** của cùng một phiên, không đè lên nhau ở phần lớn ca.

**Câu phải hỏi chủ quán.** *"Khách đang quét QR gọi thêm đúng lúc quầy bấm tính tiền cho bàn ấy thì
ở quán xử lý thế nào?"*

### GĐ-02 — ~~Món hết sau khi khách đã chọn~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 5 · ~~**Rủi ro: CAO**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.20

> **Chủ quán chốt 2026-09-02:** *POS sẽ làm việc với khách và quyết định được đưa ra tại thời điểm
> thảo luận xong với khách hàng.* Giả định bên dưới **đoán gần đúng** (quầy gọi khách, khách quyết)
> nhưng đoán thiếu một nửa: nó viết như thể quán chọn sẵn một trong ba đường, còn lời chốt nói
> **không có đường chọn sẵn nào** — kết quả là cái hai bên thống nhất tại ca đó. Đọc quy tắc ở
> `shop-facts.md` §6.20, đừng đọc phần dưới. Giữ lại để thấy chỗ đoán lệch.

**Giả định.** Quầy **liên hệ khách** rồi làm theo ý khách: đổi sang thành phần khác, bỏ phần thiếu,
hoặc huỷ cả đơn. Máy không tự chọn giúp.

**Vì sao tạm chấp nhận được.** Không có quy tắc nào của quán cho phép **đổi ruột một suất** mà
không hỏi — đổi thành phần là quyền chủ quán và còn phải **chờ hết buổi** (`shop-facts.md` §6.17).
Nên "hỏi khách" là giả định hẹp nhất, không tự chế luật mới.

**Rủi ro nếu sai.** Xếp **CAO** vì quy mô: mọi suất đều kèm bánh (`shop-facts.md` §4.5), nên **hết
bánh cuốn là hết gần như mọi món** — giả định này không áp cho một đơn lẻ mà có thể áp cho **cả
buổi bán**. Chọn sai đường ở đây là chọn sai cho hàng chục đơn cùng lúc.

**Câu phải hỏi chủ quán.** *"Đang bán mà hết bánh, những bàn đã gọi rồi thì quán làm thế nào — báo
từng bàn, đổi món khác, hay trả tiền lại?"*

### GĐ-03 — ~~Khách nói đã chuyển khoản mà quầy chưa thấy báo có~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 9 · ~~**Rủi ro: CAO**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.21

> **Chủ quán chốt 2026-09-02:** *POS sẽ thảo luận với khách và đưa ra quyết định tại lúc đó.* Giả
> định bên dưới đoán **sai chiều**: nó chốt sẵn *"không giữ khách, ghi nợ"*, còn lời chốt để **cả
> hai** đường mở — ghi nợ, **hoặc** chờ tin nhắn — và giao việc chọn cho người đứng quầy. Đây đúng
> là chỗ một giả định nghe hợp lý đã suýt thành luật cứng. Đọc `shop-facts.md` §6.21.

**Giả định.** Quầy **không** giữ khách lại chờ tin nhắn. Phiên đóng theo đường **nợ** của
`shop-facts.md` §6.14 — ghi ai nợ, nợ bao nhiêu — và xoá khoản nợ khi tin nhắn báo có tới.

**Vì sao tạm chấp nhận được.** VietQR ở quán là mã **tĩnh**, máy không bao giờ tự biết tiền đã về;
câu *"đã nhận tiền"* chỉ do người bấm ở POS tạo ra (`shop-facts.md` §6.3). Quán **đã có** đúng một
đường cho *"tiền chưa vào tay mà khách phải đi"*, và đó là nợ — giả định này dùng lại đường có sẵn
thay vì đẻ trạng thái mới.

**Rủi ro nếu sai.** Xếp **CAO** vì nó chạm thẳng cổng chất lượng mạnh nhất của dự án: đối soát cuối
ngày ngưỡng **0đ** (`shop-facts.md` §6.10). Ghi nhầm một lần chuyển khoản thành nợ làm **hai** con
số sai cùng lúc — phần chuyển khoản so với tin nhắn, và tổng nợ ghi trong ngày.

**Câu phải hỏi chủ quán.** *"Khách bảo chuyển rồi mà điện thoại chưa có tin nhắn báo có thì quán
cho khách đi hay giữ lại chờ?"*

### GĐ-04 — ~~Đơn đã hoàn thành cần điều chỉnh~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 13 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.19

> **Chủ quán chốt 2026-09-02:** *quán đang ở trạng thái nào cũng sửa được, POS sẽ quyết định dựa
> trên tình hình thực tế.* Giả định bên dưới đoán **ngược hẳn** — nó viết *"đơn đã `Hoàn thành` thì
> không sửa nữa, xử bằng hoàn tiền"*, và rủi ro nó tự nêu (*"nếu quán thật vẫn sửa đơn đã xong"*)
> đúng là điều đã xảy ra. **Đây là giả định sai nhiều nhất trong năm mục**, và nó sai theo hướng
> chặt hơn quán thật — đúng thứ CLAUDE.md §3.5 cảnh báo. Đọc `shop-facts.md` §6.19.

**Giả định.** Đơn đã `Hoàn thành` thì **không sửa nội dung nữa**; sai sót xử bằng đường **hoàn
tiền** của §4.8 — quầy quyết từng ca, ghi vết, trừ vào doanh thu **ngày hoàn**.

**Vì sao tạm chấp nhận được.** Chủ quán mới chốt **sửa được** và **sửa trên POS**, chưa chốt **tới
trạng thái nào** (`shop-facts.md` §6.19, nửa còn mở của **U-022**). Bảng §5.2 hôm nay **không có**
dòng `Hoàn thành → Huỷ`, nên giả định này là đọc đúng chữ của tài liệu chứ không nới rộng lời chủ
quán (`work/findings.md` F-004).

**Rủi ro nếu sai.** Nếu quán thật vẫn sửa đơn đã xong, thì mọi lần sửa ấy hôm nay đi vòng qua hoàn
tiền — doanh thu rơi vào **ngày hoàn** thay vì ngày bán, và `shop-facts.md` §6.4 nói thẳng luật ấy
**ngược chiều** luật nợ. Sai ở đây làm lệch sổ **giữa hai ngày**, không mất tiền.

**Câu phải hỏi chủ quán.** *"Đơn đã làm xong đưa cho khách rồi mà phát hiện nhầm thì quán sửa lại
đơn ấy hay trả tiền lại cho khách?"*

### GĐ-05 — ~~Thao tác nhầm ngoài ca "bấm nhầm một mẻ"~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 14 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** —
`master_plan/shop-facts.md` §6.22, `quality/invariants.md` I-018

> **Chủ quán chốt 2026-09-02:** *"mọi thao tác nhầm khác — duyệt nhầm một đơn, huỷ nhầm, đóng phiên
> nhầm — không có nút hoàn tác, nhưng có nút cập nhật, và có bản copy trước cập nhật / sau cập nhật
> / lý do / ai là người sửa."* Giả định bên dưới đoán **đúng** vế *không có hoàn tác*, nhưng sai ở
> vế sau: nó viết *"cách xử là quầy làm bù bằng thao tác hợp lệ đang có"*, tức **không có gì mới**.
> Thật ra quán muốn một **nút cập nhật** kèm bản ghi bốn phần. Đọc `shop-facts.md` §6.22.

**Giả định.** Chỉ ca **bấm nhầm *"đã làm xong"* một mẻ** có đường lùi (chủ quán chốt 2026-09-01,
U-024). Mọi thao tác nhầm khác — duyệt nhầm một đơn, huỷ nhầm, đóng phiên nhầm — **không** có nút
hoàn tác; cách xử là quầy làm bù bằng thao tác hợp lệ đang có.

**Vì sao tạm chấp nhận được.** §5.1 nói **mọi chuyển tiếp ngoài bảng đều bị từ chối**, và chủ quán
mới mở đúng **một** đường lùi. Suy đường lùi ấy ra cho các thao tác khác là nới lời chủ quán rộng
hơn chữ của nó.

**Rủi ro nếu sai.** Ca đắt nhất là **đóng phiên nhầm**: phiên `Đã đóng` **không** quay lại
`Đang phục vụ` (§5.6, ca đã chốt), nên khách còn ngồi đó sẽ phải mở **phiên mới, hoá đơn mới** —
đúng thứ `shop-facts.md` §6.1 gọi là thu thiếu tiền, chỉ khác nguyên nhân.

**Câu phải hỏi chủ quán.** *"Quầy lỡ bấm đóng phiên một bàn khách vẫn đang ăn thì lúc đó làm thế
nào?"*

---

### ADR-037 — Lượt bán trên sổ giấy tính doanh thu NGÀY BÁN, nên một ngày còn lượt chưa nhập là ngày CHƯA đối soát xong

**Trạng thái:** Đã chốt 2026-09-04 (T-054), sau khi **chủ quán trả lời `U-032`** bằng đúng một từ:
*"bán"*. Nó **sửa câu hệ quả** của `quality/invariants.md` **I-014**, không sửa mệnh đề của I-014.

**Vấn đề nó giải quyết.**
`U-032` hỏi: một lượt bán ghi trên sổ giấy hôm mất điện, hôm sau mới gõ vào máy, thì doanh thu rơi
vào **ngày quán bán** hay **ngày gõ**. Câu ấy mở ngày 2026-09-03 (T-048) kèm một nhận xét mà lượt
này phải xử lý chứ không được lờ đi: **hai đường ra đều phá một thứ đang đứng.**

- Về **ngày gõ**: doanh thu của ngày mất điện **sai vĩnh viễn** — 30 suất quán thật sự bán hôm ấy
  nằm ở một ngày khác, và không bao giờ có ai sửa.
- Về **ngày bán**: doanh thu của một ngày **đã đối soát** đổi về sau ⇒ mất đúng câu mà I-014 đang
  giữ (*"doanh thu một ngày đã đối soát không đổi về sau"*), và ngưỡng lệch **0đ** của
  `master_plan/shop-facts.md` §6.10 — cổng chất lượng mạnh nhất của cả dự án (**ADR-022**) — trông
  như hết nghĩa.

Chủ quán chọn **ngày bán**. Việc còn lại của lượt này không phải chọn hộ, mà là trả lời: **ngưỡng
0đ sống bằng cách nào khi con số của một ngày đã qua có thể đổi.**

**Decision:**

1. **Doanh thu của lượt nhập bù rơi vào ngày quán bán** (`shop-facts.md` §6.11, chủ quán chốt
   2026-09-04). Cùng chiều với luật nợ ở §6.14: **tiền về lúc nào không đổi được ngày bán.**
2. **Một ngày còn lượt bán trên giấy chưa nhập là một ngày CHƯA đối soát xong.** Con số `N` —
   *"còn N lượt bán trên giấy chưa nhập"* — đã là một đòi hỏi của §6.11 từ 2026-09-02; ADR này nâng
   nó từ **một dòng bày ra** thành **điều kiện đóng sổ**: `N > 0` ⇒ ngày ấy chưa đóng.
3. ⇒ **Ngưỡng 0đ không đổi một chữ, và không có nút *"đóng ca dù lệch"*.** Ngày mất điện không
   *"lệch rồi được tha"*; nó **chưa tới lúc** được chấm. Chỗ lệch của nó có tên, có số, và có một
   việc cụ thể để hết lệch: gõ nốt chỗ giấy.
4. **I-014 mang một ngoại lệ có tên**, không phải mất câu hệ quả: *doanh thu một ngày đã đối soát
   không đổi về sau, **trừ** lượt bán trên sổ giấy chưa nhập*. Ngoại lệ đọc theo nghĩa hẹp nhất —
   chỉ lượt bán **đã xảy ra thật ở quán** và **có mặt trên sổ giấy**. Không ca nào khác được sửa
   doanh thu một ngày đã qua.

**Why.**
Cả hai đường của `U-032` đều mất một thứ, nên câu hỏi thật là **mất thứ nào thì sửa lại được**.
Đường *ngày gõ* mất **sự thật của một ngày** và mất vĩnh viễn: không ai đi tìm một chỗ sai mà mọi
con số đều tự khớp. Đường *ngày bán* mất **tính bất động của một con số đã chốt** — nhưng chỉ mất
trong khoảng thời gian có tên, có số đếm, và tự đóng lại khi `N` về 0. Cái thứ hai **quan sát
được**; cái thứ nhất thì không. Đối soát ngưỡng 0đ tồn tại để *"lệch 1 đồng cũng tìm ra lý do"*
(§6.10) — một ngày mất điện với `N = 30` **có** lý do, và lý do ấy đọc được ngay trên bảng.

Đây cũng là chỗ lời chủ quán ngày 2026-09-02 và ngày 2026-09-04 khớp vào nhau: *"nhập ngay khi có
thể, không có mốc giờ cứng"* chỉ đứng được nếu **không nhập xong thì chưa đóng sổ**. Nếu ngày ấy
đóng được lúc `N > 0`, câu *"nhập ngay khi có thể"* biến thành *"nhập lúc nào cũng được, không ai
đợi"* — và phần ghi tay sẽ là phần bị bỏ quên đầu tiên vào ngày bận nhất.

**Rejected alternatives:**
- *Doanh thu tính **ngày gõ**.* Bác — **chủ quán chốt ngược lại**, và nó làm doanh thu ngày mất điện
  sai vĩnh viễn.
- *Tính **ngày bán**, nhưng đóng sổ ngày ấy như thường và sửa số lặng lẽ khi nhập bù.* Bác — đây là
  đường **rẻ nhất và nguy hiểm nhất**: nó giữ được cả hai câu chữ (*"tính ngày bán"* và *"tối nào
  cũng đối soát xong"*) bằng cách cho một con số **đã chốt** đổi mà không ai chứng kiến. Ngưỡng 0đ
  khi đó chỉ còn là một dòng chữ trong tài liệu.
- *Giữ nguyên I-014 và coi ca nhập bù là **ngoại lệ vận hành**, không phải chuyện của bất biến.*
  Bác — một mệnh đề bất biến mà thực tế có một ca phá nó thì mệnh đề ấy **sai**, không phải *"gần
  đúng"*. `work/findings.md` **F-022** đã ghi đúng hình này: hai mục cùng chốt nói ngược nhau và chỉ
  lộ ra khi có người **diễn** một scenario.
- *Nới ngưỡng lệch cho riêng ngày mất điện.* Bác — thẳng vào luật 3 của
  `docs/product/1-system-design/architecture.md` §6.4 (*không có nút "đóng ca dù lệch"*) và vào
  **ADR-022**.

**Applies to:**
`quality/invariants.md` **I-014** (bảng ba dòng + câu hệ quả có ngoại lệ) ·
`master_plan/shop-facts.md` §6.11 · §7.1 ·
`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2 (hàng *nhập bù*) ·
`docs/product/1-system-design/01-ranh-gioi-he-thong.md` §3 (**PT-6**) ·
**ADR-022** (ngưỡng 0đ — không đổi) · **ADR-019** (luật nợ — cùng chiều).

**Chỗ hở đã lấp, 2026-09-06.** ADR này nói *ngày ấy chưa đóng sổ khi `N > 0`*; nó không nói **ai**
ngồi lại đối soát ngày ấy sau khi nhập xong, và **lúc nào** — đó là `U-037`
(`docs/product/99-unknowns.md`). Chủ quán trả lời: **POS hoặc chủ quán, vào cuối buổi bán hàng**
— nguyên văn *"pos hoặc chủ quán cuối buổi bán hàng."* Cùng người, cùng nhịp đã làm việc đối soát
hằng ngày ở `shop-facts.md` §6.10 — không phải một vai trò mới, không phải một mốc vận hành mới.
Ghi ở `master_plan/shop-facts.md` §6.27.

### ADR-038 — Quán không có "mở ca / đóng ca", nên tiền đầu két gắn vào NGÀY BÁN chứ không vào một biến cố ca

**Trạng thái:** Đã chốt 2026-09-04 (T-056), sau khi **chủ quán trả lời `A2`** bằng một câu:
*"cứ đến giờ là bán rồi tối đếm tiền"*, và `A3` · `A4` bằng hai câu về tiền trong két.

**Vấn đề nó giải quyết.**
`work/backlog_AD.md` **ADM-01** mở ra vì `master_plan/shop-facts.md` §6.10 chốt đối soát cuối ngày
ngưỡng lệch **0đ** mà không mục nào nói **con số tiền lẻ đầu két** ở đâu — đúng chỗ trống mà
`docs/product/1-system-design/architecture.md` §14.3 gọi tên: *"tiền đầu buổi và tiền nộp về chưa
nằm trong phép tính đối soát"*. Cách sửa **mặc định** cho một chỗ như thế là dựng một biến cố *mở
ca* để treo con số vào — và ADM-01 được viết đúng theo giả định ấy, với một *"mốc mở"* và một
*"mốc đóng"* trong mục **Goal** của nó.

Chủ quán ngày 2026-09-04 nói rằng biến cố ấy **không tồn tại ở quán**. Không ai bấm mở, không ai
bấm đóng; đến giờ thì bán, tối thì đếm tiền. Nên câu phải trả lời là: **con số tiền đầu két gắn vào
cái gì, khi không có ca để gắn vào.**

**Ba đường, và hai đường đầu đều sai theo một kiểu khác nhau:**

| Đường | Hỏng ở đâu |
|---|---|
| **Dựng một biến cố *mở ca* dù quán không có** | Bắt người đứng quầy bấm một nút không tương ứng với việc gì ngoài đời. Nút ấy sẽ bị bấm sai giờ, bấm hộ, hoặc quên bấm — và mỗi lần quên là một ngày **không có** tiền đầu két, tức một ngày đối soát lệch mà không ai biết vì sao. Đây là *máy quyết thay người*, ngược §5.4 (*"máy không gom, người gom"*) |
| **Bỏ tiền đầu két ra ngoài phép đối soát** | Phép so lệch **đúng bằng** tiền đầu két, **mọi ngày**. Ngưỡng 0đ — **ADR-022**, cổng chất lượng mạnh nhất của dự án — mất hết nghĩa, và người dùng học cách bỏ qua chỗ lệch. Đúng hậu quả ADM-01 đã viết ra trước khi có lời chủ quán |
| ✅ **Gắn tiền đầu két vào NGÀY BÁN** | mốc đã có định nghĩa riêng, ở pha 1, do một bước khác sở hữu |

**Decision:**

1. **Quán không có khái niệm *mở ca / đóng ca***, và không tài liệu nào của repo được dựng một
   biến cố như thế (`shop-facts.md` §6.23). Mốc vận hành **nhỏ nhất** quán có là **một ngày bán**.
2. **Đơn vị gom tiền là *một ngày bán*** — định nghĩa ở
   `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` (**P1-03**, pha 1). ADR này **không**
   định nghĩa lại nó và không được đọc như một định nghĩa thứ hai (`work/findings.md` **F-001**).
3. **Tiền đầu két là một dữ kiện CỦA MỘT NGÀY BÁN**, không phải của một biến cố: một ngày bán có
   đúng một con số tiền đầu két, mặc định cố định và **sửa được** (`shop-facts.md` §8.5).
4. **Phép đối soát §6.10 phải trừ tiền đầu két khỏi tiền mặt đếm trong két trước khi so với doanh
   thu tiền mặt** — mệnh đề này là `quality/invariants.md` **I-021**, và nó là điều kiện để ngưỡng
   0đ có nghĩa. Chia theo **phương thức** của §6.10 không đổi: tiền đầu két chỉ chạm phần **tiền
   mặt**, không chạm phần chuyển khoản.
5. **Không có nghiệp vụ nộp bớt tiền giữa buổi** (`A4`) ⇒ phép đối soát không phải cộng lại các
   lần rút giữa chừng. Đây là chỗ ADR này làm việc **ít đi**, và nó ít đi vì chủ quán nói vậy,
   không vì ai chọn cho gọn.

**Hệ quả cho ADM-01, và đây là hệ quả đáng ghi nhất.** Việc ấy được viết như một việc **thiếu luật**
(loại 1 của `work/backlog_AD.md`). Lời chủ quán không *trả lời* nó — nó **làm mất một nửa câu hỏi**:
không có mốc mở và mốc đóng nào để định nghĩa, vì quán không có hai mốc ấy. Nửa còn lại (tiền đầu
két) nay đã có luật ở §8.5 và I-021. ⇒ ADM-01 chuyển sang **loại 2** — luật đã đủ, phần còn lại
thuộc pha 2–4.

**Chỗ ADR này KHÔNG chốt, và một chỗ đã lấp sau đó:**
- ~~Con số tiền đầu két nhập vào máy là một tổng hay một bảng theo mệnh giá~~ — **U-038, đóng
  2026-09-06: CẢ HAI.** Nguyên văn: *"tổng của từng mệnh giá và tổng của tất cả các mệnh giá cộng
  lại với nhau."* Máy giữ một bảng theo mệnh giá **và** hiện tổng cộng; phép trừ của I-021 dùng
  tổng cộng, bảng mệnh giá là cách đếm/kiểm cuối ngày. Ghi ở `master_plan/shop-facts.md` §8.5.
- **Ai nhập con số ấy, và nhập lúc nào.** Chủ quán nói *ai bỏ tiền vào két* (chính chủ quán), không
  nói *ai gõ nó vào máy*. Không suy hộ (`CLAUDE.md` §3.5) — vẫn chưa có lời.
- **Tên bảng, tên cột, endpoint, route** — pha 2, 3, 4 (**ADR-035**).

### ADR-039 — Gate 1d chấm máy phần phổ biến nhất của ranh giới pha; `CLAUDE.md` thêm chủ cho quy ước code, cột *Cưỡng chế bởi*, và hết mâu thuẫn ở §8

**Trạng thái:** Đã chốt 2026-09-06 (T-059), sau khi chủ repo yêu cầu đọc kỹ một vòng rà soát
`CLAUDE.md` (bên ngoài, dạng hội thoại) cộng hai file nháp đưa kèm trong phiên — một bản viết lại
`CLAUDE.md` và một script gate mới — rồi cập nhật `CLAUDE.md` và thêm lệnh mới. Hai file nháp đó
nằm ngoài cấu trúc repo (không phải `work/proposals/`, chưa từng được git track); nội dung của
chúng đã hợp nhất vào `CLAUDE.md` và `scripts/` theo mô tả ở mục *Decision* dưới đây, nên hai file
gốc không còn lý do để giữ lại — xoá chúng không mất dữ kiện nào, chỉ chưa ai bấm xoá.

**Vấn đề nó giải quyết.**
`ADR-035` (2026-09-04) chốt ranh giới sở hữu chạy theo pha, và tự thừa nhận một lỗ hổng ngay trong
câu chữ của nó: *"no gate here can read that boundary. P1-12 and human eyes are the only check."*
Một LLM viết tài liệu pha 1 rất dễ trượt đúng chỗ này — nó *biết* schema, endpoint, route trông thế
nào, nên câu nó viết ra rất hợp lý dù sai chủ. Vòng rà soát cũng chỉ ra ba chỗ khác đã mục nát trong
`CLAUDE.md`: (1) không dòng nào sở hữu **quy ước code** (stack, cấu trúc thư mục, đặt tên, khung
test) dù pha 2 sắp mở và sẽ cần nó; (2) bảng nghĩa vụ ở §3 không phân biệt luật có script chặn với
luật chỉ trông chờ tự giác; (3) §8 tự mâu thuẫn — nói *"L0 xong sau bốn dòng"* trong khi khối
*Every level* mang **sáu** dòng, hai trong số đó (*Handed off*, *Report kèm link câu hỏi mở*) là
nghĩa vụ của backlog/scope mà một task L0 (không entry, không scope) không thể đáp ứng.

**Ba đường, và vì sao chọn đường thứ ba cho từng chỗ:**

| Chỗ hổng | Đường bị bác | Đường chọn |
|---|---|---|
| Ranh giới pha không ai canh | Không làm gì thêm — giữ nguyên "P1-12 và mắt người" | Cố ý bảo thủ, không định lượng hết: viết **Gate 1d**, một cổng bắt lớp vi phạm phổ biến nhất (từ khoá SQL, `GET/POST/... + /api/`, thẻ JSX) trong `docs/product/1-system-design/`, và **im lặng khi không chắc** — không thay P1-12, chỉ hẹp phần việc lại cho nó |
| Quy ước code chưa có chủ | Để trống tới khi pha 2 mở | Thêm dòng *chưa có owner* vào bảng §2.2 **ngay bây giờ**, cùng nhóm với schema — vì lỗ hổng chỉ lộ ra **sau khi** phiên đầu tiên đã bịa xong, lúc đó sửa là viết lại chứ không phải khai chủ |
| Luật tự giác và luật có script trộn lẫn trong một bảng | Giữ nguyên, tin rằng đọc kỹ sẽ phân biệt được | Thêm cột **Cưỡng chế bởi** — tách hai loại tường minh, vì đúng lúc context đầy và task dài là lúc luật *tự giác* rơi trước, và người đọc cần biết trước cái nào |
| §8 nói bốn dòng, có sáu | Đổi câu chữ cho khớp sáu dòng | Đổi khối **L0** cho khớp bốn dòng thật, và chuyển hai dòng backlog/scope xuống **L1 trở lên** — đúng chỗ chúng có nghĩa (L0 không có entry, không có scope) |

**Decision:**

1. **`scripts/check-phase-boundary.sh` (Gate 1d)** chạy trong `./scripts/gate.sh`, ngay sau
   `check-doc-status.sh` (Gate 1c) và trước `verify.sh` — cùng lý do ADR-032 đặt Gate 1c ở đó: lỗi
   này chỉ sống trong tài liệu pha 1, và một lượt chỉ đổi tài liệu là lượt `verify.sh` bỏ qua. Gate
   tự thoát sớm (exit 0) khi không có gì trong `docs/product/1-system-design/` đổi trong lượt này;
   chấm cả file **git đang theo dõi** (thay đổi chưa commit) lẫn file **chưa track** trong thư mục
   đó, cùng luật ADR-003 áp dụng cho từng loại. Một trích dẫn cố ý đi vào
   `scripts/check-phase-boundary.ignore`, mỗi dòng một chuỗi con kèm lý do — cùng khuôn với
   `check-links.ignore`.
2. **`CLAUDE.md` §2.2** ("chưa có chủ") có thêm dòng **quy ước code: stack, cấu trúc thư mục, đặt
   tên, khung test**, sinh ra cùng lúc với schema ở pha 2 — sửa một câu của **ADR-035**, vốn chỉ
   liệt kê ba dòng (schema, hợp đồng API, route/component) mà bỏ sót quy ước code.
3. **`CLAUDE.md` §3** có thêm cột **Cưỡng chế bởi**, ghi tên gate/hook cho nghĩa vụ có script chặn,
   và *"tự giác"* cho nghĩa vụ không có gì đỡ.
4. **`CLAUDE.md` §8** khối **L0** rút còn đúng bốn dòng (gate xanh, đọc diff, dữ kiện bền đã ghi,
   khối commit); *"backlog và scope khớp thực tế"* và *"báo cáo kèm link câu hỏi mở"* chuyển xuống
   **L1 trở lên**, nơi backlog entry và scope thật sự tồn tại.
5. **`CLAUDE.md` §6.1** khối commit thêm một dòng lệnh `git diff --name-only HEAD` để lấy danh sách
   file **từ git**, không từ trí nhớ của phiên — một phiên dài, nhiều file dễ nhớ sót hoặc nhớ thừa,
   còn máy thì không.
6. Số ghi ở CLAUDE.md §1 mở đầu bằng một dòng nói sản phẩm là gì (bán hàng + quản trị cho một quán
   ăn, chi tiết ở `master_plan/shop-facts.md`) — trước đó file này không câu nào nói, và một phiên
   cold nhận quy trình trước khi biết đang xây gì.

**Applies to:**
`CLAUDE.md` §1 · §2.2 · §3 · §5 · §6.1 · §8 · `scripts/gate.sh` · `scripts/check-phase-boundary.sh`
(mới) · `scripts/check-phase-boundary.test.sh` (mới) · **ADR-035** (sửa một câu).

**Chỗ ADR này KHÔNG chốt:**
- **Gate 1d không bắt hết mọi vi phạm ranh giới pha** — nó cố ý bảo thủ (từ khoá SQL, verb HTTP +
  `/api/`, thẻ JSX-giống). Một câu văn mô tả bảng hay endpoint bằng lời, không bằng cú pháp, vẫn lọt
  qua máy; P1-12 và mắt người vẫn là lớp cuối, không đổi so với ADR-035.
- **Nội dung thật của quy ước code** (stack cụ thể, tên thư mục) — dòng mới ở §2.2 chỉ khai **chủ**,
  không viết quy ước; nội dung đến ở pha 2, cùng `docs/product/2-db/` (ADR-035).
- **Không viết lại toàn bộ `CLAUDE.md` sang tiếng Việt hay đổi số mục** — bản nháp do chủ repo đưa
  có làm việc đó; ADR này áp dụng đúng phần sửa lỗi đã đo được (bốn chỗ ở trên) trên bản hiện hành,
  giữ nguyên số mục §1…§8 vì gần 200 chỗ khác trong repo
  trỏ `CLAUDE.md §X.Y` và không chỗ nào trỏ theo số dòng — đổi số mục sẽ không làm gate nào đỏ (Gate
  1b chỉ chấm đường dẫn, không chấm số mục) nhưng âm thầm làm sai ngữ cảnh của gần 200 trích dẫn đó.

### ADR-040 — Trả trước cho một đơn đặt trước NGÀY SAU tính doanh thu vào NGÀY GIAO, không phải ngày nhận tiền

**Trạng thái:** Đã chốt 2026-09-06, sau khi **chủ quán trả lời `U-036`** bằng một câu: *"quán nhận
đơn trước 1 ngày, doanh thu tính vào ngày đem hàng cho khách."*

**Vấn đề nó giải quyết.**
`U-036` mở ra ngày 2026-09-04 (P1-03, trong lúc định nghĩa *một ngày bán*) và hỏi đúng chiều ngược
của luật nợ ở `shop-facts.md` §6.14: nợ là tiền về **sau** một lần bán **đã xong** (⇒ tính vào ngày
bán); trả trước cho một đơn đặt trước ngày khác là tiền về **trước** một lần bán **chưa xong**, và
không luật nào chốt sẵn nó rơi vào ngày nào. Trước đó một bước, câu hỏi còn treo cả tiền đề: **quán
có nhận đặt trước cho một ngày sau không?**

Hai đường ra, và cả hai đều động vào ngưỡng lệch **0đ** (`shop-facts.md` §6.10, **ADR-022**) — đúng
hình dạng mà `U-032`/**ADR-037** đã gặp:

| Đường | Hỏng ở đâu |
|---|---|
| Tính vào **ngày nhận tiền** | Doanh thu được ghi cho một bữa ăn **chưa bán**; một lần khách huỷ hôm sau (hoàn theo §6.4, rơi vào ngày hoàn) để lại doanh thu ảo ở ngày đã nhận tiền |
| ✅ Tính vào **ngày giao/lấy hàng** | Đúng chiều với mọi luật *doanh thu tính ngày việc bán thật sự xảy ra* đã có (nợ, hoàn, sổ giấy) — nhưng để lại một khoản đã vào két mà chưa vào doanh thu, đúng một ngày |

**Decision:**

1. **Doanh thu của một khoản trả trước rơi vào NGÀY GIAO/LẤY hàng**, không phải ngày quán nhận
   tiền (`shop-facts.md` §6.26, chủ quán chốt 2026-09-06). Đây là chiều **đối xứng** của luật nợ ở
   §6.14 — cả hai đều lấy mốc theo **ngày việc bán thật sự xảy ra**, không theo ngày tiền đổi tay.
2. **Quán chỉ nhận đặt trước cho TỐI ĐA một ngày sau**, không xa hơn. Không có ca "trả trước hôm
   nay cho đơn ba ngày sau" — câu hỏi tiền đề của `U-036` đóng bằng giới hạn này.
3. **Một khoản trả trước nhận hôm nay cho đơn giao ngày mai nằm trong két hôm nay nhưng KHÔNG vào
   doanh thu hôm nay.** Công thức đối soát §6.4 (`docs/product/1-system-design/architecture.md`)
   cần thêm một dòng cho khoản này — đối xứng với dòng *nợ ghi trong ngày* nhưng ngược chiều: nợ là
   một khoản **thiếu** trong doanh thu hôm nay mà đã tính; trả trước là một khoản **thừa** trong két
   hôm nay mà chưa tính.

**Why.**
Nợ và trả trước là hai mặt của cùng một trục — *tiền và việc bán không xảy ra cùng lúc* — và trục ấy
đã có một chiều được chốt (nợ ⇒ ngày bán). Chốt chiều còn lại theo **cùng nguyên tắc** (ngày việc
bán, không phải ngày tiền) giữ cho I-014 chỉ có **một** ý tưởng thay vì hai ý tưởng ngược nhau tuỳ
chiều tiền chảy. Đường *ngày nhận tiền* phá đúng điều I-014 đang giữ — *doanh thu một ngày đã đối
soát không bao giờ đổi về sau* — theo một cách mới: nó ghi trước một khoản mà việc bán còn có thể
không xảy ra (khách huỷ), nên con số hôm nhận tiền phải chờ ngày mai mới biết có đúng không.

**Rejected alternatives:**
- *Doanh thu tính ngày nhận tiền.* Bác — chủ quán chốt ngược lại, và nó ghi doanh thu cho một bữa
  ăn chưa chắc xảy ra.
- *Không giới hạn khoảng cách nhận đặt trước.* Bác — chủ quán tự giới hạn **một ngày**; giữ nguyên
  giới hạn ấy thay vì suy rộng ra, đúng luật *"chính xác N chỉ khi N là quyết định"* (`CLAUDE.md`
  §7.2).

**Applies to:**
`master_plan/shop-facts.md` §6.26 · `quality/invariants.md` **I-014** (hàng thứ tư của bảng ngày) ·
`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2 (hàng *trả trước*) ·
`docs/product/1-system-design/architecture.md` §6.4 (công thức đối soát, dòng mới) · **ADR-037**
(cùng trục, chiều nợ).

**Chỗ ADR này KHÔNG chốt:** câu chữ và cơ chế của dòng mới trong công thức đối soát §6.4 — đó là
việc của bước đọc §2 của `02-thoi-gian-ngay-ban.md` (P1-04 trở đi), không phải của ADR này.

### ADR-041 — Đặt tên chủ cho PT-5 (Telegram) và PT-2 (một VPS), đóng một phần F-027

**Trạng thái:** Đã chốt 2026-09-07, sau khi chủ repo yêu cầu trong phiên: *"Telegram ... hãy thêm
thông tin vào hệ thống"* và *"một VPS hãy thêm thông tin vào hệ thống"*.

**Vấn đề nó giải quyết.**
`work/findings.md` **F-027** (mở 2026-09-04, P1-02) đo được rằng kế hoạch pha 1 kể tên **năm** phụ
thuộc ngoài, nhưng hai trong năm — **Telegram** và **một VPS** — không có owner nào trong `docs/`
hay `quality/`: chúng chỉ sống ở `master_plan/prompt-fullstack.md`, và ADR-035 đã chốt tài liệu đó
**không sở hữu thứ gì**. Pha 1 (`01-ranh-gioi-he-thong.md` §2) né vấn đề bằng cách ghi **PT-2** là
*"nơi hệ thống chạy"* và **PT-5** là *"đường báo đơn web về quầy"* — đúng theo ranh giới pha
(ADR-035), nhưng không đặt tên. F-027 tự khai rõ: chọn owner cho hai cái tên là quyết định của chủ
repo, không phải việc pha 1 tự quyết.

**Decision:**

1. **PT-5 = Telegram** — hệ thống báo đơn mới về quầy bằng bot Telegram. Ghi ở
   `master_plan/shop-facts.md` §1 (dòng *Báo đơn web mới về quầy*).
2. **PT-2 = một VPS** — toàn bộ hệ thống chạy trên đúng một VPS. Ghi ở `shop-facts.md` §1 (dòng
   *Hạ tầng vận hành*). Đây khớp với một trong bốn ràng buộc ẩn mà **P1-08** phải chốt chiến lược
   xử lý (*một instance · không hàng đợi · không cache · một VPS*, cũng nêu ở F-027) — quyết định
   này xác nhận vế **một VPS**, nhưng **không** xác nhận ba vế còn lại.
3. `docs/product/1-system-design/01-ranh-gioi-he-thong.md` **giữ nguyên cách viết trừu tượng** ở
   bảng §2 (không chép "Telegram" / "VPS" vào tài liệu pha 1) — chỉ đổi cột *Đã chốt ở* từ ⚠️ *"chưa
   có owner"* thành pointer về `shop-facts.md` §1 và ADR này. Ranh giới sở hữu theo pha (ADR-035)
   không đổi: tên công nghệ cụ thể là dữ kiện quán/hạ tầng, sống ở `shop-facts.md`, không sống
   trong tài liệu pha 1.

**Why.**
F-027 đã liệt hai đường và bác cả hai (chép tên vào pha 1 ⇒ phong một câu chưa ai chốt thành dữ
kiện kiến trúc; bỏ tên ⇒ thiếu đúng phụ thuộc đắt nhất). Đường thứ ba — chủ repo chốt tên ở
`shop-facts.md`, ghi quyết định ở đây, pha 1 chỉ trỏ vào — giữ được cả ranh giới pha lẫn tên đầy
đủ, không đường nào trong hai đường bị bác phải dùng.

**Chỗ ADR này KHÔNG chốt:**
- **Cấu hình cụ thể** — token bot, nhóm/chat Telegram nhận báo đơn, nhà cung cấp VPS, cấu hình máy
  chủ. Đó là việc của pha 3 (BE) và pha 5 (Deploy) khi hai phase ấy mở (ADR-035).
- **Ba ràng buộc ẩn còn lại của P1-08** (một instance · không hàng đợi · không cache) — F-027 vẫn
  **mở một phần** cho tới khi P1-08 tự chốt chúng; ADR này chỉ đóng vế đặt tên cho PT-2/PT-5.
- **Cơ chế** — máy làm sao gửi tin nhắn Telegram, làm sao chịu được khi VPS quá tải. Đó vẫn là
  việc của P1-08 và pha 3/5, không phải của ADR này (F-018: kể tên một cơ chế để từ chối nó không
  phải là thiết kế nó).

**Applies to:**
`master_plan/shop-facts.md` §1 (hai dòng mới) · §7.1 (dòng nhật ký) ·
`docs/product/1-system-design/01-ranh-gioi-he-thong.md` §2 (cột *Đã chốt ở* của PT-2/PT-5) · §4 ·
§5 · `work/findings.md` **F-027** (đóng một phần).

### ADR-042 — Mở bước thứ mười ba của pha 1 (P1-13), nhóm SẢN XUẤT THEO MẺ, đóng F-026

**Trạng thái:** Đã chốt 2026-09-07, sau khi chủ repo yêu cầu thẳng trong phiên: *"hãy làm thêm
nhóm trục sản xuất theo mẻ"*.

**Vấn đề nó giải quyết.**
`work/findings.md` **F-026** (mở 2026-09-03/04, đo lại 2026-09-06): kế hoạch pha 1 §6 chia mười
tám mệnh đề bất biến ban đầu thành ba nhóm — **P1-04** TIỀN, **P1-05** VÒNG ĐỜI, **P1-06**
MENU·GIÁ·VẾT. Cùng ngày kế hoạch ấy viết xong, **BA-12** thêm hai mệnh đề mới vào
`quality/invariants.md` — `I-019` (tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng
bàn, cả hai chiều) và `I-020` (số đã phục vụ của một bàn không bao giờ vượt số bàn ấy đã gọi) —
**sau** khi ba nhóm đã chia, nên không nhóm nào nhận chúng. Cổng chất lượng §9 vẫn đếm *"mười
tám"* trong khi `quality/invariants.md` giữ hai mươi mệnh đề, và cổng ấy tick xanh được đúng khi
hai mệnh đề chưa có tầng giữ nào — loại hỏng nó được dựng để chặn.

F-026 tự liệt ba đường và cố ý không tự chọn (quyết định thuộc chủ repo, `CLAUDE.md` §3.5):

| Đường | Vì sao không chọn / chọn |
|---|---|
| 1. Gấp `I-019`/`I-020` vào P1-05 (VÒNG ĐỜI) | **Bác.** Rẻ nhất, và `I-020` đọc gần giống một câu vòng đời. Nhưng `I-019` là một câu về **phép cộng** giữa nhiều bàn qua một khoá gom, không nói về vòng đời của bất kỳ thực thể nào — gấp vào sẽ buộc nó mượn một tầng nó không có |
| 2. ✅ Mở bước thứ mười ba, nhóm **SẢN XUẤT** | **Chọn.** Trung thực nhất với nội dung — cả hai mệnh đề đứng trên trục *sản xuất theo mẻ* (mẻ là đơn vị bấm, bàn là đơn vị đếm — chủ quán chốt 2026-09-01, đóng `U-017`). Đắt nhất: đổi tổng số bước pha 1 từ mười hai sang mười ba, kéo theo sửa mọi pointer đang viết *"mười hai bước"* |
| 3. Gấp vào P1-07 (yêu cầu hình dạng dữ liệu) | **Bác.** P1-07 viết **yêu cầu cho pha 2**, không điền **bảng ba cột** — trộn hai việc ấy làm bảng ba cột thiếu hai hàng mà không ai thấy |

**Decision:**

1. **Pha 1 có mười ba bước, không phải mười hai.** `P1-13` — Bảng ba cột, nhóm **SẢN XUẤT THEO
   MẺ**: `I-019` · `I-020` — nối vào cuối danh sách hiện có (`master_plan/SD_master_plan_banh_cuon_ba_thanh.md`
   §6). **`P1-01`…`P1-12` giữ nguyên ID**, không renumber — tránh vỡ mọi neo `#p1-0x` đang tồn tại
   trong repo (bảy khối rủi ro renumbering: `work/backlog_SD.md`, `prompt/SD/README.md`, các file
   prompt đã commit, `docs/product/00-index.md`…).
2. **`docs/product/1-system-design/03-bao-ve-invariant.md` có thêm §4**, viết theo đúng khuôn ba
   cột và năm tầng của §1/§2/§3 (kế hoạch §7, nay đọc là *bốn* bước dùng chung từ vựng, không phải
   ba).
3. **Cổng chất lượng §9 của kế hoạch bỏ số đếm cứng.** Câu *"Mười tám `I-0xx` đều có tầng bảo vệ"*
   đổi thành đối chiếu **danh sách mã** giữa `quality/invariants.md` và
   `03-bao-ve-invariant.md` — không đếm số lượng. Đây là sửa đúng lỗi F-026 mô tả: một con số đếm
   động đã tự hết đúng một lần (F-018 cùng loại), sửa theo hướng đếm-động sẽ chỉ lặp lại nó.
4. **Mọi pointer đang viết *"mười hai bước"* hoặc *"P1-01…P1-12"* như tổng số bước của pha 1 được
   sửa thành *"mười ba bước"* / *"P1-01…P1-13"`** trong các tài liệu **sống** (kế hoạch, sổ mô tả,
   README prompt, mục lục `docs/product/`). **Không sửa** các mục ghi log lịch sử (entry *Done* ở
   `work/backlog.md`, các file prompt đã chạy) — đó là bản ghi tại thời điểm nó đúng, sửa tiến
   không phải sửa lùi (ADR-008).

**Why.**
Đường 1 rẻ nhưng sai hình dạng: gấp một câu về phép cộng vào nhóm vòng đời làm mất khả năng nói
đúng cơ chế của nó (không có "vòng đời" nào cho một dòng nhu cầu tổng). Đường 3 nhầm lẫn hai loại
đầu ra khác nhau của pha 1 (yêu cầu hình dạng dữ liệu ≠ bảng ba cột). Đường 2 tốn nhất nhưng là chi
phí một lần — và nó sửa luôn nguyên nhân gốc mà F-026 chỉ ra: kế hoạch dùng một **số đếm tĩnh**
("mười tám", "mười hai bước") làm sự thật, trong khi tập nó đếm còn đổi. Cổng §9 sau ADR này đối
chiếu danh sách thay vì đếm số, nên một mệnh đề thứ hai mươi mốt sinh ra ngày mai sẽ tự động bị bắt
là "vắng mặt ở bảng ba cột" thay vì âm thầm lọt qua một con số đã cũ.

**Applies to:**
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 (tiêu đề, hàng P1-13, dòng song song, hàng
P1-07/P1-10) · §7 (tiêu đề) · §9 (câu đầu) ·
`docs/product/1-system-design/03-bao-ve-invariant.md` (banner + §4 mới) ·
`work/backlog_SD.md` (intro, luật 1/3, Mục lục, callout, entry P1-06, entry P1-13 mới) ·
`prompt/SD/README.md` (bảng mười ba bước, callout, tiêu đề từ vựng năm tầng) ·
`prompt/SD/P1-13-invariant-san-xuat-theo-me-L2.md` (mới) ·
`docs/product/00-index.md` (một dòng) · `work/findings.md` **F-026** (đóng).

---

### ADR-043 — Bản đã commit của `work/scope.txt` chỉ được chứa comment; pattern không bao giờ đi vào git

**Trạng thái:** Đường chốt 2026-09-03 (chủ repo, ngay trong phiên phát hiện `work/findings.md`
**F-020**); thi hành 2026-09-07 (T-047). Cơ chế thi hành được **ADR-063** thay ngày 2026-09-27:
file scope nay nằm ở `work/scope/`, git bỏ qua; `work/scope.txt` còn lại là stub chỉ-comment, nên
hình bất biến của ADR này vẫn đúng.

**Vấn đề nó giải quyết.**
`CLAUDE.md` §6 đã cấm bằng chữ từ trước: *"`work/scope.txt` is working state, not a deliverable —
do not commit patterns."* Luật có, nhưng không cổng nào gác nó, và nó đã hỏng **ba lần** bằng đúng
một cơ chế (`work/backlog.md` T-016 ghi hai lần đầu; F-020 là lần thứ ba, qua commit `12c77f8`,
T-031, 2026-08-31). Một khi pattern đã lọt vào một commit, phiên tuân thủ luật **không có đường hợp
lệ nào** để dọn: gỡ nó tạo một thay đổi *tracked* trên `work/scope.txt`, và commit thay đổi đó là
đúng cái §6 cấm và Gate 7b bắt — luật tự khoá chính nó.

**Ba đường, F-020 tự liệt và cố ý không tự chọn** (`CLAUDE.md` §3.5 — quyết định thuộc chủ repo):

| Đường | Vì sao không chọn / chọn |
|---|---|
| 1. Dọn một lần, không dựng cơ chế | **Bác.** Rẻ nhất, nhưng đây đã là lần dọn **thứ ba** cho cùng một lỗi (`work/backlog.md` T-016 ghi hai lần trước) — dọn một lần không làm nó thôi tái diễn |
| 2. ✅ Bản đã commit chỉ mang trạng thái nền (chỉ comment); Gate 3 + Gate 7b thi hành | **Chọn.** Không cần file mẫu thứ hai để so (tránh lặp `work/findings.md` F-001); định nghĩa "trạng thái nền" bằng chính parser đang đọc pattern, nên ngữ nghĩa pattern vẫn chỉ có một chủ (ADR-006) |
| 3. Dựng `work/scope.txt.example`, `.gitignore` bản thật | **Bác.** Đẻ ra `work/scope.txt.example` — một bản sao thứ hai của cùng nội dung, đúng loại lỗi F-001 — cộng một bước chép file mỗi clone mà không gì ép được, vượt quá giới hạn ADR-010 đã chấp nhận cho `install-hooks.sh` |

**Decision:**

1. **Hình bất biến:** bản `HEAD` của `work/scope.txt` chỉ được chứa comment. Pattern là trạng thái
   của phiên đang chạy, không bao giờ đi vào git.
2. **Gate 3** (`scripts/check-scope.sh`) thêm một phép chấm — không đổi cách đọc/khớp pattern đang
   chạy đúng (ADR-006 vẫn đứng): ĐỎ khi bản `work/scope.txt` ở `HEAD` mang pattern **mà cây làm việc
   VẪN còn giữ**; `note:` (không chặn) khi `HEAD` còn nợ nhưng cây làm việc đã sạch — dọn xong trong
   cây là xanh ngay trong chính lượt đó, không cần đợi tới sau khi commit; im lặng khi `HEAD` sạch.
3. **Gate 7b** (`scripts/check-commit-block.sh`, luật 3) đổi vị ngữ từ *"`work/scope.txt` có mặt
   trong khối commit không"* sang *"nội dung sẽ được `git add` có còn pattern không"* — áp cùng phép
   đếm ở điểm 2. Không có "ngoại lệ commit migration": một cổng không xác minh được loại commit, và
   tin một chữ trong báo cáo là đúng giá `work/findings.md` F-011 đã trả (chữ `ádg`).
4. **Pattern chết** (khớp không file nào đang đổi — một task khai đường dẫn file **sắp** tạo ra là
   hợp lệ) và **pattern lặp** không phải lỗi mới phải bắt: cách đọc pattern của Gate 3 không sai,
   task thi hành đường này **không được** "siết" nó (ADR-003 — đỏ vì lý do sai dạy người ta bỏ qua
   gate).
5. `CLAUDE.md` §5, §6, §6.1 sửa lại cho khớp: câu *"`work/scope.txt` is never in the block"* (tuyệt
   đối theo sự-có-mặt) sai dưới luật mới — đúng phải là *"không bao giờ mang pattern vào khối"* —
   file **chỉ-comment** trong khối là hợp lệ, và đó chính là bước đóng nợ CLAUDE.md §7.3 đòi.

**Why.**
Đường 2 tốn nhất trong ba đường (sửa hai script, viết test cho cả hai) nhưng là chi phí một lần và
sửa đúng nguyên nhân gốc: luật đã có từ đầu (§6), cái thiếu là cổng gác nó. Một hình bất biến định
nghĩa bằng chính parser đang chạy (không phải một file mẫu thứ hai) nghĩa là ngữ nghĩa pattern không
bao giờ trôi khỏi nhau giữa hai chỗ đọc nó — đúng bài học `work/findings.md` F-001. Vị ngữ "cây làm
việc vẫn giữ nguyên" (không phải "HEAD thuần") là chỗ dễ sai nhất: chấm bằng `HEAD` thuần sẽ khoá
đúng lượt đi dọn debt — không ai gỡ nổi nợ vì gỡ luôn khiến gate đỏ ngay khi vừa sửa.

**Rejected alternatives:** xem bảng ba đường ở trên.

**Applies to:**
`scripts/check-scope.sh` (phép chấm baseline mới) · `scripts/check-scope.test.sh` (file mới) ·
`scripts/check-commit-block.sh` (luật 3, vị ngữ mới) · `scripts/check-commit-block.test.sh` (hai ca
mới) · `CLAUDE.md` §5 mục 1 và mục 6, §6, §6.1 · `work/findings.md` **F-020** (đóng) ·
`prompt/maintenance/16-scope-txt-baseline-migration-L2.md` (mới).


---

### ADR-044 — I-021 vào nhóm TIỀN đã có, không mở nhóm thứ năm; hàng ấy có chủ là bước P1-14

**Trạng thái:** Đã chốt 2026-09-07 (chủ repo, trong phiên).

**Vấn đề nó giải quyết.**
`work/findings.md` **F-026** đóng **một nửa** ngày 2026-09-07: `I-019`/`I-020` đã có nhóm thứ tư
(**ADR-042**, bước `P1-13`). Mệnh đề mồ côi **thứ ba** thì không: `I-021` (*két cuối ngày − tiền
đầu két = doanh thu tiền mặt*) sinh ở **T-056**, 2026-09-04, cũng sau khi kế hoạch §6 chia ba nhóm,
và không bước nào nhận nó. Chỗ đau khác hai mệnh đề kia: `I-021` **đã bị trỏ vào** — ô `I-015` của
bảng ba cột nhóm TIỀN nêu tên nó để nói được vế *phần tiền mặt so với két*, nên từ 2026-09-06 bảng
ấy mang một hàng **bị trỏ tới mà không tồn tại**.

**Hai đường, chủ repo chọn đường 1:**

| Đường | Vì sao chọn / không chọn |
|---|---|
| 1. ✅ Vào **nhóm TIỀN đã có**, thêm một hàng vào §1 | **Chọn.** `I-021` là một phép cộng tiền của một **ngày bán**, đứng cùng chỗ với `I-014` và `I-015`, và đã bị `I-015` trỏ vào — nó không mở một trục mới nào cả |
| 2. Nhóm thứ năm riêng (KÉT · TIỀN MẶT), đối xứng với ADR-042 | **Bác.** Đối xứng về hình thức, sai về nội dung: `I-019`/`I-020` phải có nhóm riêng vì trục **sản xuất theo mẻ** không phải tiền cũng không phải vòng đời (ADR-042, §4.1); `I-021` thì không xa nhóm nào — một nhóm cho đúng một mệnh đề vốn thuộc nhóm bên cạnh chỉ làm bảng khó đọc thêm |

**Decision:**

1. **`I-021` là hàng thứ tám của §1 — nhóm TIỀN**, đủ ba ô như bảy hàng còn lại: tầng 1 cho *một
   ngày bán một con số tiền đầu két* và *tiền đầu két không nằm trong tập tiền đã thu*, tầng 3 cho
   *không đường nào rút tiền khỏi két giữa buổi* (`shop-facts.md` §8.5), **tầng 4** cho *con số két
   cuối ngày là số người đếm rồi nhập* — ô này nói thẳng **"máy không ngăn được"** kèm cái máy có
   giữ thay vào, đúng luật 3 của §0.
2. **Hàng ấy có chủ: bước mới `P1-14`**, không sửa lùi entry `P1-04` đã `Done` (**ADR-008**). Pha 1
   vì thế có **mười bốn bước**; `P1-01`…`P1-13` **giữ nguyên ID**, `P1-14` chỉ nối vào cuối — cùng
   lý do đã ghi ở ADR-042: renumber làm vỡ mọi neo đang tồn tại.
3. **`P1-14` không có file prompt riêng.** Luật lane `prompt/SD/` là *viết được prompt của một bước
   khi mọi bước ở cột **Cần xong trước** của nó đã `Done`* (T-051); ở đây tiền đề (`P1-04`) đã xong
   và bước được thi hành **ngay trong lượt chốt ADR này**, nên một file prompt sẽ được viết rồi tự
   đọc trong cùng một lượt — đúng loại tài liệu nghi lễ `CLAUDE.md` §3.8 cấm. `prompt/SD/README.md`
   ghi thẳng chỗ trống ấy và lý do, thay vì để người sau tưởng là bỏ sót.
4. **Cổng chất lượng §9 không đổi một chữ** — nó đã bỏ số đếm cứng ở ADR-042 và nay đối chiếu
   **danh sách mã**, nên hàng `I-021` xuất hiện là nó tự hết vắng mặt. Đây là bằng chứng đường sửa
   của ADR-042 đúng: cùng một dạng lỗi lặp lại lần thứ hai trong ba ngày, và lần này cổng **không**
   phải sửa theo.

**Why.**
Đường 2 nghe an toàn hơn vì nó lặp lại đúng cái vừa làm cho `I-019`/`I-020`, nhưng lặp hình thức
của một quyết định mà bỏ **lý do** của nó là cách nhanh nhất để sinh ra một bảng đúng luật mà vô
nghĩa. Lý do của ADR-042 là *trục nội dung khác hẳn ba nhóm có sẵn*; `I-021` không có lý do ấy —
nó là tiền, đúng nghĩa đen, và ô `I-015` đã cần nó đứng cạnh mình.

Phần đắt nhất của hàng mới **không** phải công thức, mà là chỗ nó **chỉ tới tầng 4**: hệ thống
không có đường nào biết trong két thật có bao nhiêu tiền. Một bảng ghi hàng này là *tầng 1* vì nhìn
thấy một phép trừ chính xác sẽ dạy pha 2 rằng chỗ này đã được máy giữ — đúng **rủi ro lớn nhất của
cả pha 1** mà kế hoạch §10 gọi tên, và đúng thứ ô cổng §9 thứ hai tồn tại để bắt.

**Ảnh hưởng:**
`docs/product/1-system-design/03-bao-ve-invariant.md` (khối mở đầu · tiêu đề §1 · **một hàng mới**
`I-021` · ô `I-015` sửa pointer · §1.3 viết lại · §1.4 hai hàng · **§1.5 mới**) ·
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 (tiêu đề, hàng `P1-14`, dòng chạy song song,
cột *Cần xong trước* của P1-07/P1-10) · §7 (tiêu đề) · `work/backlog.md` · `work/backlog_SD.md` ·
`prompt/SD/README.md` · `docs/product/00-index.md` (một dòng) · `prompt/AD/README.md` và
`work/backlog_AD.md` (hai pointer P1-13 quét sót, vẫn viết *"mười hai bước"*) ·
`work/findings.md` **F-026** (đóng hẳn).

### ADR-045 — Bốn ràng buộc kiến trúc ẩn có nhà ở pha 1, mỗi cái một dấu hiệu đo được; đóng nốt F-027

**Trạng thái:** Đã chốt 2026-09-08, bước **P1-08** (`master_plan/SD_master_plan_banh_cuon_ba_thanh.md`
§6). **ADR-041** (điểm 3) giao thẳng ba vế còn lại cho bước này chốt.

**Vấn đề nó giải quyết.**
`work/findings.md` **F-027** (mở 2026-09-04, P1-02) đo được rằng **bốn** ràng buộc quyết định hình
dạng của cả hệ thống — *một tiến trình · không hàng đợi · không bộ nhớ đệm · một chỗ chạy duy nhất*
— chỉ tồn tại ở `master_plan/prompt-fullstack.md` §6.8, một **bản xuất khẩu** mà **ADR-035** đã
chốt là **không sở hữu thứ gì**. **ADR-041** (2026-09-07) đặt tên chủ cho vế thứ tư và nói rõ nó
**không** chốt hộ ba vế kia. Cùng lúc, hai trong bốn ràng buộc ở bản xuất khẩu có kèm một dấu hiệu
xem lại (*confirm đơn > 500ms* · *menu > 200 món*) và hai cái còn lại **không có gì** — mà một ràng
buộc không có dấu hiệu thì hoặc được giữ mãi vì không ai dám bỏ, hoặc bị bỏ vì cảm tính.

**Decision:**

1. **Bốn ràng buộc có owner là pha 1**, ở `docs/product/1-system-design/05-realtime-va-du-phong.md`
   §2, mang mã cục bộ `RB-1`…`RB-4`. Chúng là **tính chất và giới hạn**, không phải cách triển
   khai: bảng §7 của `prompt-fullstack.md` xếp *"ràng buộc kiến trúc ẩn + dấu hiệu phải xem lại"*
   vào đầu ra bắt buộc của pha 1, và giữ nguyên cách chia ấy.
2. **Mỗi ràng buộc có đúng một dấu hiệu đo được**, kèm **ai đo và bằng cái gì đã có**. Hai dấu hiệu
   của bản xuất khẩu (500ms · 200 dòng suất bán) được **nhận** làm dấu hiệu chính thức — bước này
   không nghĩ ra con số mới ở chỗ đã có một con số dùng được. Hai dấu hiệu còn lại đặt mới, và cả
   hai cố ý đo bằng thứ **đã tồn tại**: nhật ký khởi động của hệ thống (`RB-1`), và dòng *"còn N
   lượt bán trên giấy chưa nhập"* của bảng đối soát cuối ngày (`RB-4`, `master_plan/shop-facts.md`
   §6.11).
3. **Dấu hiệu bật ⇒ mở lại quyết định, không tự động bỏ ràng buộc**, và bỏ thì ghi một ADR mới.
   Riêng `RB-1`: dấu hiệu bật **không** cho phép thêm tiến trình thứ hai ngay — chỗ chung giữ
   *"màn nào đang nối"* phải có **trước**, nếu không thì việc nới ràng buộc chính là dựng ra cái
   hỏng mà ràng buộc ấy sinh ra để chặn.
4. **Tên công nghệ vẫn không vào pha 1** (**ADR-035** · **ADR-041** điểm 3): §1.1 của file mới viết
   *tính chất* của đường đẩy (giữ kết nối mở trong bộ nhớ tiến trình) chứ không viết tên giao thức;
   tên của *chỗ chạy duy nhất* ở `master_plan/shop-facts.md` §1.

**Rejected alternatives:**

- **Chép bốn ràng buộc từ bản xuất khẩu vào pha 1 y nguyên, không đặt dấu hiệu.** Bác — đó đúng là
  trạng thái hôm nay, chỉ đổi chỗ ở: kế hoạch §6 đặt đầu ra kiểm chứng được của P1-08 bằng
  *"mỗi cái có một dấu hiệu đo được, không phải một lời hứa"*.
- **Giao cả bốn cho pha 5 (Deploy) và pha 3 (BE)** — đường 1 mà F-027 đã liệt. Bác: P1-08 chạy
  **trước** hai pha ấy, nên nó vẫn phải viết dấu hiệu cho những thứ chưa ai sở hữu; và ràng buộc
  *một tiến trình* không phải một lựa chọn triển khai, nó là hệ quả trực tiếp của cách đường đẩy
  giữ kết nối.
- **Đặt dấu hiệu bằng một phép đo phải dựng thêm mới đo được** (số kết nối đang mở, độ trễ trung
  bình mỗi phút). Bác: một dấu hiệu không ai đo là một dấu hiệu không tồn tại — cùng bài học với
  `work/findings.md` **F-012**, chỗ trống được che bằng một cái tên.
- **Chốt luôn cửa sổ thời gian gọi là *quán mất kết nối*.** Bác — nó quyết định lúc nào quán ngừng
  bán trên web, tức một đánh đổi của **quán** (`CLAUDE.md` §3.5). Mở `U-043` thay vì tự chọn.

**Chỗ ADR này KHÔNG chốt:**
- **Con số chu kỳ** của đường kéo dự phòng — pha 3 (file mới §1.2).
- **Cách chạy** ở chỗ duy nhất ấy: theo dõi, khởi động lại, triển khai — pha 5.
- **Cửa sổ thời gian** để gọi là *quán đang mất kết nối* — `docs/product/99-unknowns.md` **U-043**.
  *Đã có lời chủ quán **2026-09-16**: không có cửa sổ nào — máy **báo**, **POS quyết**, mở lại bằng
  **nút**; lời ấy lật luật 1 của §3 mà ADR này dựng ⇒ **ADR-047**, U-053 đã đóng 2026-09-25: chủ quán dùng 5G bấm tắt; U-061 đã đóng 2026-09-27: tuân I-008 cả trước lúc bấm.*
- **Câu chữ dòng thông báo** cho khách khi ba kênh tự bấm dừng — chưa chốt (`quality/invariants.md`
  **I-008**), hỏi khi dựng màn ở pha 4.

**Applies to:**
`docs/product/1-system-design/05-realtime-va-du-phong.md` (file mới) ·
`docs/product/00-index.md` (một dòng bảng *Pha 1*) ·
`docs/product/1-system-design/architecture.md` §5 (một dòng trỏ) · §13 (một hàng) ·
`01-ranh-gioi-he-thong.md` §5 · `02-thoi-gian-ngay-ban.md` §5 · `03-bao-ve-invariant.md` §5
(hàng **P1-08** của ba bảng *bước sau đọc gì*) · `work/findings.md` **F-027** (đóng nốt) ·
`docs/product/99-unknowns.md` (**U-043** mới) · **ADR-041** (vế thứ tư đã chốt từ trước).

### ADR-046 — Hoàn tiền chéo phương thức vào I-021 bằng hai hạng tử riêng, không đổi nghĩa *doanh thu tiền mặt*

**Trạng thái:** Đã chốt 2026-09-15, T-073. Nguồn là lời chủ quán 2026-09-08 đóng
`docs/product/99-unknowns.md` **U-044**: *"tuỳ vào tình hình thực tế, pos quyết định."*

**Vấn đề nó giải quyết.**
`master_plan/shop-facts.md` §6.4 nay chốt rằng hoàn tiền **trả lại bằng gì** cũng không có luật
cứng: khách đã chuyển khoản có thể được hoàn bằng tiền mặt lấy trong két, và ngược lại. `quality/invariants.md`
**I-021** viết từ 2026-09-04 đã tự khai hậu quả: có một đường tiền rời két giữa buổi thì phép trừ
*két cuối ngày − tiền đầu két* **thiếu một hạng tử**, và mệnh đề phải **viết lại**. Câu hỏi của ADR
này là hạng tử ấy vào công thức bằng hình dạng nào — vì có hơn một cách viết đúng số học, và chúng
khác nhau ở chỗ màn đối soát còn **tìm ra lý do** được hay không (§6.10).

**Decision:**

1. **Hai hạng tử riêng, đặt tên theo ca chéo**: trừ *hoàn trả bằng tiền mặt cho khoản đã thu bằng
   chuyển khoản*, cộng *hoàn trả bằng chuyển khoản cho khoản đã thu bằng tiền mặt*. Hoàn **cùng**
   phương thức không sinh hạng tử nào — nó đã nằm trong doanh thu tiền mặt như từ trước tới nay.
2. ***Doanh thu tiền mặt* giữ nguyên nghĩa**: một lần hoàn trừ vào doanh thu của **phương thức đã
   thu**, rơi vào **ngày hoàn** (§6.4, chốt 2026-09-01). Không con số doanh thu nào đổi định nghĩa
   vì ADR này.
3. **Vết hoàn tiền ghi thêm phương thức trả lại** — câu thứ năm cạnh *bao nhiêu · đơn nào · ai bấm ·
   lý do*. Đây là **suy ra**, không phải lời chủ quán (§6.4 ghi rõ *cách đọc*): không có nó thì hai
   hạng tử ở điểm 1 không mở ra được thành danh sách từng khoản (`architecture.md` §6.4 luật 2).
4. **Một lần hoàn thiếu phương thức trả lại ⇒ ngày ấy CHƯA đối soát xong, không phải *lệch*** —
   cùng hình dạng ngày chưa có tiền đầu két (I-021) và ngày còn `N > 0` lượt trên giấy (**ADR-037**).

**Rejected alternatives:**

- **Định nghĩa lại *doanh thu tiền mặt* theo phương thức TRẢ RA** (hoàn tiền mặt thì trừ vào doanh
  thu tiền mặt, bất kể đã thu bằng gì). Số học khớp, nhưng lần hoàn chéo **biến mất** vào trong một
  con số tổng — đúng thứ `architecture.md` §6.4 luật 2 cấm — và *doanh thu tiền mặt* thành một con
  số dòng tiền chứ không còn là doanh thu.
- **Coi hoàn tiền mặt là một *khoản rút giữa buổi***. Bác: chủ quán chốt quán **không** có nghiệp
  vụ nộp bớt tiền giữa buổi (§8.5, 2026-09-04); gộp hai thứ vào một chữ là mở cửa cho một nghiệp vụ
  chủ quán đã nói không tồn tại.
- **Cấm hoàn chéo phương thức cho gọn công thức.** Bác — lật ngược lời chủ quán vừa chốt
  (`CLAUDE.md` §3.5).
- **Chỉ ghi thêm một dòng cảnh báo cạnh mệnh đề cũ.** Bác — chính I-021 viết *"viết lại chứ không
  phải viết thêm"*.

**Chỗ ADR này KHÔNG chốt:**
- **Phía chuyển khoản đối chiếu một lần hoàn chuyển khoản với nguồn nào.** §6.10 đối chiếu phần
  chuyển khoản với **tin nhắn báo có** — tức tiền **vào**; một lần hoàn chuyển khoản là tiền **ra**,
  và chưa lời nào nói nó được đối chiếu với cái gì. Chưa chặn bước nào của pha 1; phải chốt trước
  khi dựng màn đối soát.
- **Con số trên màn đối soát trông thế nào** — pha 4.

**Applies to:**
`quality/invariants.md` **I-021** (viết lại) · `master_plan/shop-facts.md` §6.4 · §7.1 · §8.5 ·
`docs/product/1-system-design/architecture.md` §6.4 · `06-so-rui-ro.md` `RR-3` ·
`docs/product/99-unknowns.md` (**U-044** đóng).

---

### ADR-047 — Dừng nhận đơn web khi mất kết nối là quyết định của NGƯỜI, không của một cửa sổ thời gian

**Trạng thái:** Đã chốt 2026-09-16, T-078. Nguồn là lời chủ quán cùng ngày đóng
`docs/product/99-unknowns.md` **U-043**: *"hiên thông báo để pos quyết định nếu dừng cần có nut mở
lại"*.

**Vấn đề nó giải quyết.**
`docs/product/1-system-design/05-realtime-va-du-phong.md` §3 (viết 2026-09-08, **ADR-045**) chốt
**bốn câu luật** cho cơ chế mà `quality/invariants.md` **I-008** giao lại, và câu luật thứ nhất
viết thẳng: *phán quyết đứng ở phía hệ thống, không phía quán* — lý do là đúng lúc phải phán quyết
thì quán là bên đã mất tiếng nói. Bước ấy **không tự chọn** độ dài cửa sổ; nó mở `U-043` và để chủ
quán trả lời. Lời chủ quán về **không** trả lời con số: nó trả lời rằng **không có con số nào cả**,
vì người quyết dừng là **POS**, không phải một cái đồng hồ. Hai câu — luật 1 của §3 và câu
*"có mạng lại thì ba kênh kia mở lại ngay"* ở phần *Verification* của `I-008` — nay **mâu thuẫn với
lời chủ quán**, và ADR này ghi lại chuyện xử chúng thế nào.

**Decision:**

1. **Lời chủ quán thắng lời của tài liệu thiết kế.** Hai câu trên sửa theo lời chốt, trong cùng
   thay đổi đóng `U-043` (`CLAUDE.md` §2: một sự thật, một chủ — hai chỗ nói ngược nhau là bug sửa
   ngay, không phải task sau).
2. **Luật 1 của §3 tách làm hai vế, không bị xoá.** *Phát hiện* vẫn ở phía hệ thống và vẫn không
   chờ quán báo — lý do cũ vẫn đúng. *Quyết dừng* thì ở phía **POS**: máy hiện một thông báo ở
   quầy, POS quyết ba kênh khách tự bấm có dừng hay không.
3. **Mở lại là một nút người bấm.** Không có đường tự mở lại khi tín hiệu về — đây là lời chủ quán
   nói thẳng, không phải suy ra.
4. **`I-008` KHÔNG đổi một chữ ở mệnh đề.** Đơn tạo ra trong lúc quán mù vẫn là đơn không được phép
   tồn tại; thứ đổi là **cơ chế**, và cơ chế chưa bao giờ thuộc mệnh đề ấy.
5. **Chỗ lý do cũ để lại thành một câu hỏi có tên, không thành một luật tự chọn.** Ca quán **mất
   mạng hẳn** — POS không nhìn thấy thông báo và không bấm được gì — là đúng ca `I-008` sinh ra để
   chặn. **Cập nhật 2026-09-25:** U-053 đã có lời — chủ quán dùng 5G bấm tắt
   (`shop-facts.md` §6.11); U-061 đã đóng 2026-09-27: tuân I-008 cả trước lúc bấm.

**Rejected alternatives:**

- **Giữ nguyên luật 1 và đọc lời chủ quán như *chỉ nói về ca chập chờn*.** Bác: đó là đọc hộ chủ
  quán một điều kiện mà lời chốt không có (`CLAUDE.md` §3.5), và nó để hai câu ngược nhau cùng sống
  trong repo — đúng hình `work/findings.md` **F-001**.
- **Suy ra một đường lai: máy tự dừng sau X phút, POS được bấm mở lại sớm hơn.** Bác: chữ **X** ấy
  chính là con số chủ quán vừa từ chối đọc ra.
- **Xoá hẳn luật 1 vì nó đã sai.** Bác: lý do của nó vẫn đúng và vẫn cần người trả lời — xoá đi thì
  ca *quán mất mạng hẳn* biến mất khỏi tài liệu thay vì thành `U-053`.
- **Chờ `U-053` có lời rồi sửa cả hai chỗ một lần.** Bác: trong lúc chờ, hai câu đã biết là sai vẫn
  đang được đọc như thiết kế đã chốt.

**Chỗ ADR này KHÔNG chốt:**
- **Ai dừng khi quán mất mạng hẳn** — U-053 đã đóng 2026-09-25; chủ quán dùng 5G bấm tắt. U-061 đã đóng 2026-09-27: tuân I-008 cả trước lúc bấm.
- **Thông báo ở quầy trông thế nào, POS bấm ở đâu** — pha 4.
- **Máy dựa vào dấu hiệu nào để nói *đang mất kết nối*** — luật 2 của §3 (chạy trên chính đường
  việc và đơn đang đi) đứng nguyên; con số chu kỳ vẫn là **pha 3**.

**Applies to:**
`docs/product/1-system-design/05-realtime-va-du-phong.md` §3 · §4 · §5 ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §3 (bảng *bước sau*) ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §4 · §7 · §8 ·
`quality/invariants.md` **I-008** · `master_plan/shop-facts.md` §6.11 · §7.1 ·
`docs/product/99-unknowns.md` (**U-043** đóng, **U-053** đóng 2026-09-25; U-061 đã đóng 2026-09-27: tuân I-008 cả trước lúc bấm).

---

### ADR-048 — Pha 1 viết hộ pha sau thì VIẾT LẠI, không khai thành ngoại lệ

**Trạng thái:** Đã chốt 2026-09-20, T-079. Chủ repo chọn **đường 2** trong ba đường
`work/findings.md` **F-040** ghi sẵn, sau khi bước **P1-12** (2026-09-16) đo ranh giới pha lần đầu
trên cả tám file pha 1 và **không tự sửa** — nó là một phép đo.

**Vấn đề nó giải quyết.**
**ADR-035** (2026-09-04) chia quyền sở hữu theo pha: lược đồ ở **pha 2**, hợp đồng API ở **pha 3**,
route ở **pha 4**. `docs/product/1-system-design/architecture.md` viết **trước** ranh giới ấy
(`cf8bd83`, 2026-08-31), và lúc P1-01 dựng ranh giới thì **chỉ §8** được viết lại cho khớp. Ba chỗ
không ai quét còn lại: **§3.1** chỉ định sẵn hình dạng một ràng buộc database, **§4** mang một
`bảng.cột` **trong tiêu đề mục**, **§12.2** kê thẳng một **hợp đồng API bốn dòng**. Chỗ đắt là
§12.2: pha 2 và pha 3 sẽ đọc nó như **đầu vào đã chốt**, tức thừa kế một quyết định chưa ai ra —
đúng ca **F-023**, ngược chiều.

Ba đường ra đã ghi trong F-040: **(1)** khai thêm vào ngoại lệ §12.3 · **(2)** viết lại bằng ngôn
ngữ tầng · **(3)** mở pha 3 sớm.

**Decision:**

1. **Đường 2.** Cả ba chỗ viết lại bằng **ngôn ngữ tầng** — nói *cái gì phải đúng* và *tầng nào
   giữ*, không nói *bảng nào, cột nào, endpoint nào*. Nghĩa giữ nguyên từng vế, kể cả vế đắt nhất
   của §3.1 (*ràng buộc phải phủ cả trạng thái đang thu tiền*), vì đó là **hành vi**, không phải
   lược đồ.
2. **Đường 1 bị loại, và lý do là lý do chung.** Khai thêm vào ngoại lệ thì rẻ, nhưng nó biến một
   **ngoại lệ có tên** thành một **vùng miễn trừ** — và **F-041** vừa chứng minh chuyện ấy xảy ra
   thật: dòng ignore duy nhất của Gate 1d ghi lý do *"§12.3"* trong khi dòng nó che nằm ở **§12.2**,
   tức một ngoại lệ đã đứng tên cho một dòng ngoài mục mình suốt chín ngày mà không ai thấy.
3. **Đường 3 bị loại vì nó mở pha sai lý do.** `docs/product/3-be/` mở ra khi pha 3 **bắt đầu**,
   kèm một dòng chủ sở hữu ở `CLAUDE.md` §2 trong cùng thay đổi — không phải để chứa bốn dòng chưa
   ai chốt.
4. **§12.3 giữ nguyên tư cách ngoại lệ có tên.** Nó tự khai *trong thân mục* rằng nó cố ý vượt ranh
   giới và là **đề xuất gửi sang pha 2**. Sau lượt này câu khai ấy vừa khít phạm vi nó tuyên bố:
   đúng hai thứ (*tên bảng, tên cột*), đúng một mục, không còn gánh hộ một endpoint ở mục khác.
5. **Một ngoại lệ sống trong THÂN TÀI LIỆU, không sống trong file ignore.** `scripts/check-phase-boundary.ignore`
   nay **rỗng**. Ignore là chỗ khai *một dòng cố ý*, và mỗi mục ở đó phải khớp một chuỗi có thật —
   khi chuỗi biến mất thì mục phải bị gỡ (`CLAUDE.md` §5), nếu không nó âm thầm che cả những dòng
   sinh sau.
6. **Cổng được vá trong cùng thay đổi, kèm ca hồi quy.** `PAT_API` nới từ
   *động từ HTTP + `/`* thành *động từ HTTP + chữ hoặc `/`*, cộng hai ca:
   một ca đòi **đỏ** trên đúng bốn dòng §12.2 cũ, một ca đòi **xanh** trên văn xuôi pha 1 thường.
   Không có ca thứ hai thì lần nới sau sẽ khép lại để cho êm. Đây là lần thứ **ba** trong một tuần
   một script đọc văn bản bằng phép lọc hẹp hơn thứ nó phải hiểu (**F-035** · **F-039** · **F-041**),
   nên `CLAUDE.md` §3.8 — *luật chỉ dựng sau khi cùng một vấn đề đã tốn hai lần* — đã đủ điều kiện.

**Hệ quả.** Ô **10** của cổng chất lượng pha 1 tick ⇒ cổng **10/10**; `F-040` và `F-041` đóng. Đủ
mười ô **không** phải câu *"được, sang pha 2"* — ký chuyển pha vẫn là quyền chủ repo
(`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §8).

**Pointer sửa trong cùng thay đổi** (`CLAUDE.md` §7.2):
`docs/product/1-system-design/architecture.md` §3.1 · §4 · §12.2 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §7 (ô 10) · §8 ·
`scripts/check-phase-boundary.sh` · `scripts/check-phase-boundary.ignore` ·
`scripts/check-phase-boundary.test.sh` (ca 9 · ca 10) ·
`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §9 ·
`docs/work-flow-session/vi-du-mot-task-chay-that-P1-12.md` §10 ·
`work/backlog_AD.md` (hai pointer trỏ vào tiêu đề §4) ·
`work/findings.md` (**F-040** · **F-041** đóng).

### ADR-049 — Pha 2 có kế hoạch riêng ở `master_plan/`, mã bước là `P2-XX`, và đầu ra đi vào thư mục MỚI `docs/product/2-db/`

**Trạng thái:** Đã chốt 2026-09-20 (T-080). Chủ repo yêu cầu trong phiên: *"chuyển sang pha 2, hãy
làm master plan: mục tiêu của pha 2 là gì, làm thế nào để kiểm tra, các bước thực hiện pha 2, mục
tiêu các bước, cách kiểm tra"*. Nó **chép hình dạng** của **ADR-033** (kế hoạch pha 1) và **không**
sửa một câu nào của **ADR-035** hay **ADR-039** — hai ADR ấy đã đặt sẵn chỗ cho pha 2, quyết định
này chỉ dựng đường đi tới đó.

**Decision:**

1. **Kế hoạch pha 2 ở `master_plan/DB_master_plan_banh_cuon_ba_thanh.md`**, cạnh kế hoạch pha 1,
   và nó **không sở hữu sự thật nào**: thứ tự · mức · đầu ra kiểm chứng được là của nó; trạng thái
   là của `work/backlog.md`; lược đồ là của pha 2 khi pha 2 viết ra.
2. **Mã bước là `P2-01`…`P2-14`**, cùng hình với `P1-XX` (ADR-033). Không dùng `DB-XX`: bản nháp
   pha 1 đã cho thấy một tiền tố mang **hai** nghĩa (mã task và mã quyết định) là cái bẫy
   `work/findings.md` **F-015** · **F-021** · **F-022** ghi lại.
3. **Đầu ra vào thư mục mới `docs/product/2-db/`**, một chủ đề một file, và thư mục ấy **ra đời
   cùng dòng nội dung đầu tiên** — ở `P2-03`, không sớm hơn (`docs/product/00-index.md` → *Luật
   ghi*; **ADR-035** luật 2).
4. **Năm tầng bảo vệ của pha 1 dịch sang pha 2 thành năm thứ dựng được** — ràng buộc trong lược đồ ·
   ranh giới giao dịch · một đường ghi duy nhất · chỗ cất vết · một câu truy vấn ra 0 dòng — và
   **không được tự hạ tầng**: dựng không nổi ràng buộc cho một hàng *tầng 1* là một `F-XXX` gửi
   ngược pha 1, không phải lý do để hàng ấy tụt tầng (kế hoạch pha 2 §7).
5. **Mảng admin không nằm trong mười bốn bước**; nó chạy theo lane của nó (**ADR-036**). Hai chỗ
   giao nhau — *người và chỗ đứng theo thời điểm*, *quy ước dữ liệu* — được gọi tên trong kế hoạch
   §3 để không ai lấn.

**Why:**

- **Hình dạng đã chạy một pha và đã bắt được lỗi thật.** Kế hoạch pha 1 với sáu cột, từ vựng bắt
  buộc và cổng *mỗi ô một cách chứng minh* là thứ đã làm ô 10 của cổng pha 1 **không tick được**
  ngày 2026-09-16 thay vì tick trơn (**F-040** · **F-041**, đóng ở **ADR-048**). Chép hình dạng ấy
  rẻ hơn nhiều lần việc nghĩ ra một hình mới cho pha 2.
- **Pha 2 là pha đầu tiên đụng vào dữ liệu thật, nên chỗ sai đắt hơn hẳn.** Một quyết định pha 1
  viết sai thì sửa bằng cách sửa một đoạn văn; một lược đồ sai sau vài tuần quán chạy thật thì sửa
  bằng cách mang theo dữ liệu bán hàng thật qua một lần đổi lược đồ.
- **Cột *bước nào sinh ra nó* thay cho cột *hôm nay có chưa*.** Bảng §2 của kế hoạch pha 1 dùng cột
  trạng thái và cột ấy đã hết đúng mà không ai cập nhật — `work/findings.md` **F-033**. Một cột nói
  về **kế hoạch** thì không trôi; một cột nói về **trạng thái** trong một file không sở hữu trạng
  thái thì luôn trôi (**F-001**).
- **Gate 1d hôm nay mù với pha 2.** `scripts/check-phase-boundary.sh` chỉ đọc
  `docs/product/1-system-design/`, và bộ mẫu SQL của nó sẽ **đỏ** với đúng thứ pha 2 phải viết. Nên
  `P2-02` là một bước riêng trong bảng, không phải một ghi chú: không có nó, cả pha 2 viết endpoint
  mà không cổng nào đỏ — đúng hình **F-041**, lần này không có ai đứng đọc.

**Rejected alternatives:**

- *Không cần kế hoạch, cứ mở `docs/product/2-db/` rồi dựng lược đồ theo đề xuất 16 bảng.* Bác.
  `docs/product/1-system-design/architecture.md` §8 đã đo **tám** chỗ đề xuất ấy chưa có chỗ cất
  (vết hoàn tiền · nợ · vết thao tác · ai đang trực · note *đem về* · đã phục vụ · mẻ · lượt nhập
  bù). Thi công nó như một lược đồ đã chốt là rủi ro lớn nhất của cả pha (kế hoạch §10).
- *Gộp mười bốn bước thành bốn bước lớn theo bốn nhóm bảng của đề xuất.* Bác: biên nhận của một
  bước như thế là *"đã tạo xong nhóm bảng"*, thứ không chứng minh gì. Chẻ theo **nhóm mệnh đề** thì
  mỗi bước có sẵn phép chấm — cố tình dựng trạng thái sai và xem database có từ chối không.
- *Để mô tả dài của `P2-XX` ngay trong `work/backlog.md`.* Bác, cùng lý lẽ **ADR-034** và
  **ADR-036**: `scripts/brief.sh` cắt *Ready* ở sáu mục, nên mười bốn dòng đổ vào đó đẩy tám dòng
  ra khỏi tầm nhìn của mọi phiên mới (**F-012**).
- *Kéo lược đồ mảng admin vào cùng pha 2 cho đủ một lần.* Bác **tạm thời**: phần lớn lane admin
  đang chờ lời chủ quán, nên một lược đồ admin dựng hôm nay là một lược đồ đoán. Đây là chỗ kế
  hoạch **suy ra**, không phải lời chủ repo (kế hoạch §8) — chủ repo muốn ngược lại thì bảng §6 dài
  thêm, không bước nào đổi nghĩa.

**Ba chỗ quyết định này CHƯA chốt, và cố ý để lại cho chủ repo** (kế hoạch §8): lược đồ admin đi
cùng pha 2 hay đi theo lane của nó · ba hàng `CLAUDE.md` §2 đổi ở ba bước khác nhau hay đổi hết ở
lượt mở thư mục · nhà cho `work/findings.md` **F-034** (*mất hẳn bản ghi đã ghi*) là `P2-09`, pha 5,
hay một bước riêng.

**Pointer sửa trong cùng thay đổi** (`CLAUDE.md` §7.2): `CLAUDE.md` §2 (hàng *Schema* trỏ sang kế
hoạch pha 2) · `docs/product/00-index.md` (bảng *Sáu pha*) · `work/backlog.md` (T-080).

---

### ADR-050 — Năm tầng của pha 1 dịch sang pha 2 thành năm thứ DỰNG ĐƯỢC, mỗi thứ một phép chấm; và ba câu pha 2 không được viết ra

**Trạng thái:** Đã chốt 2026-09-22 (P2-01, bước 1/14 của pha 2 —
`master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §6). Nó **không lật** một câu nào của
**ADR-035** (ranh giới sở hữu theo pha) hay **ADR-049** (kế hoạch pha 2): ADR-049 điểm 4 đã nêu
**tên** năm thứ ấy, quyết định này viết **nghĩa đầy đủ** và **phép chấm** của từng thứ — phần
ADR-049 cố ý để lại cho bước đầu tiên của pha.

Nó cũng **không sở hữu tầng**. Tầng giữ từng `I-0xx` là của pha 1
(`docs/product/1-system-design/03-bao-ve-invariant.md`, **ADR-035**). Quyết định này chỉ trả lời
một câu: *pha 2 nợ cái gì cho mỗi tầng, và biên nhận trông như thế nào.*

**Decision:**

**1. Từ vựng bắt buộc — năm tầng, mỗi tầng ba ô.** Mọi bước của pha 2 dùng đúng bảng này; bước nào
thấy mình cần một ô thứ tư thì đó là một `F-XXX`, không phải một cách đọc riêng.

| Tầng ở pha 1 | Pha 2 **nợ** cái gì | **Chấm** bằng | **KHÔNG** phải biên nhận |
|:--:|---|---|---|
| **1** — cơ sở dữ liệu giữ | một **ràng buộc thật trong lược đồ**: khoá duy nhất (kể cả khoá duy nhất chỉ áp cho vài trạng thái), điều kiện kiểm, khoá ngoại bắt buộc | cố tình dựng trạng thái sai **bằng tay** ⇒ database **từ chối**, và **dán nguyên lời từ chối** | *"đã tạo xong bảng"* · một dòng bình luận nói rằng nó sẽ từ chối · một phép kiểm nằm ở tầng ứng dụng |
| **2** — một giao dịch giữ | một **ranh giới giao dịch viết ra**: bảng nào cùng sống hoặc cùng chết trong một lần ghi | cắt giữa chừng ⇒ **không nửa nào sống sót**, dán output | *"vì hai lệnh chạy liền nhau"* · một thứ tự ghi không ai cưỡng chế được |
| **3** — miền nghiệp vụ giữ | lược đồ **không mở đường ghi thứ hai** tới ô ấy: con số tổng **cộng lại từ chi tiết**, không đứng thành một ô ai cũng ghi được | **liệt kê mọi đường ghi** tới ô đó ⇒ phải đúng **một** | một quy ước *"chỉ ghi qua chỗ này"* mà lược đồ vẫn để ngỏ đường thứ hai |
| **4** — người + thủ tục giữ | một **chỗ cất vết**: ai · lúc nào · lý do · bản trước và bản sau — và vết **sống độc lập** với bản ghi nó nói về | **xoá bản ghi gốc** ⇒ vết **vẫn đọc được** sau nhiều ngày, dán output | một cột *"ghi chú"* · một vết chết theo bản ghi gốc · một bản ghi lịch sử không có **bản trước** |
| **5** — phép đối chiếu bắt sau khi hỏng | **đúng một câu truy vấn ra 0 dòng**, gom vào bộ chạy sau khi đóng quán (`P2-11`) | **cài một lỗi thật vào dữ liệu** ⇒ đúng câu ấy ra **khác 0** | một câu truy vấn chưa bao giờ đỏ · một phép đối chiếu vẫn còn viết bằng lời |

**2. Ba luật khi dịch** — không luật nào là hình thức:

1. **Không tự hạ tầng.** Dựng không nổi ràng buộc cho một hàng *tầng 1* thì đó là một `F-XXX` gửi
   ngược pha 1, **không** phải một lý do để hàng ấy tụt xuống tầng 3. Hạ tầng trong im lặng là đúng
   thứ kế hoạch pha 1 §10 gọi là rủi ro lớn nhất của pha ấy, chỉ khác chiều: pha 1 sợ **ghi tầng
   cao hơn sự thật**, pha 2 sợ **hạ tầng cho dễ dựng**.
2. **Mỗi mệnh đề vẫn phải có câu truy vấn của nó, kể cả khi ràng buộc đã đứng ở tầng 1.** Ràng buộc
   cũng bị người ta gỡ; câu truy vấn là thứ phát hiện ra điều đó. Luật này chép nguyên luật đọc số
   2 của `03-bao-ve-invariant.md` §0 — cùng câu, đổi chiều thi hành.
3. **Một câu truy vấn chưa bao giờ ra khác 0 là một câu truy vấn chưa được chứng minh.** Bộ đối
   chiếu phải được chạy **một lần trên dữ liệu có lỗi cài sẵn**. Đây là bản pha 2 của luật *"sửa
   lỗi thì phải có test đỏ trước, xanh sau"*, và không có nó thì cả bộ đối chiếu chỉ là một lời hứa
   xanh (`work/findings.md` **F-017** — một bộ lọc rỗng vì viết sai trông y hệt một bộ lọc rỗng vì
   không có lỗi).

**3. Ba câu pha 2 KHÔNG được viết ra, và viết gì thay vào.** Cột thứ ba là chỗ quyết định này khác
một lời cấm trơn: ranh giới chỉ giữ được khi bên bị cấm có câu để nói.

| Không được viết ở pha 2 | Đầu ra của | Pha 2 viết gì thay vào |
|---|---|---|
| endpoint · tên hàm · chữ ký API · quyền theo vai của một đường gọi | pha 3 · BE (**ADR-035**) | *"đường ghi tới ô này phải là **một**, và lược đồ không mở đường thứ hai"* |
| route · component · cái gì hiện ở màn nào | pha 4 · FE (**ADR-035**) | *"con số này phải **đọc ra được** bằng một phép cộng từ chi tiết"* |
| compose · backup theo lịch · cách phục hồi khi hỏng máy | pha 5 · Deploy | *"mỗi migration phải có **đường lùi chạy thật được**"* (`P2-09`) |

**4. Hai thứ pha 2 không mở lại.** Gặp chỗ **nghiệp vụ** chưa rõ ⇒ hỏi chủ quán, hoặc một `U-XXX`
(`CLAUDE.md` §3.5 — **không có mức L0**). Gặp một hàng **tầng** sai ⇒ một `F-XXX` gửi ngược pha 1,
**không** tự hạ tầng cho dễ dựng. Hai sổ, không bao giờ trộn.

**5. Bước này không mở `docs/product/2-db/`.** Thư mục ấy ra đời cùng **dòng nội dung đầu tiên** của
pha, ở `P2-03` (**ADR-035** luật 2 · `docs/product/00-index.md` → *Luật ghi*). Sau lượt chốt
ADR này, **không** file nào dưới `docs/product/2-db/` tồn tại.

**Why:**

- **Chữ *"phải do cơ sở dữ liệu giữ"* là một câu GỬI SANG pha 2, và nó chưa có người dịch.**
  `03-bao-ve-invariant.md` §0 luật đọc 4 nói thẳng: *"Mọi câu **"tầng 1"** ở đây là YÊU CẦU gửi pha
  2, không phải một ràng buộc đã có."* Chừng nào câu ấy chưa được dịch thành một hình dạng chấm
  được, mỗi lát trong năm lát lược đồ (`P2-04`…`P2-08`) sẽ tự hiểu nó một kiểu — và năm lát ấy được
  phép **chạy song song** (kế hoạch §6), tức năm cách hiểu sẽ gặp nhau ở `P2-13` chứ không sớm hơn.
- **Cột *KHÔNG phải biên nhận* tồn tại vì chỗ hỏng thật nằm ở đó.** Rủi ro không phải một bước quên
  dựng ràng buộc; rủi ro là một bước dựng xong rồi tự khai là đạt bằng *"đã tạo xong bảng"* — thứ
  không chứng minh gì (**ADR-049**, *Rejected alternatives*). Một thước chỉ đo được khi nó nói cả
  cái **không** tính.
- **Ba luật dịch đều là luật đã có ở nơi khác, và đều đã mất hiệu lực một lần.** Luật 2 là luật đọc
  số 2 của pha 1; luật 3 là hình dạng của **F-017**, thứ đã để một vòng rà tin vào một bộ lọc im
  lặng. Gom chúng vào một chỗ mà mọi bước pha 2 trích được rẻ hơn để mỗi bước tự nhớ.
- **Cổng §9 của kế hoạch cần một thước trước khi có cái để chấm.** Ô thứ ba của cổng đòi *"dán
  nguyên lời từ chối của database khi cố dựng trạng thái sai"*. Không có bảng ở điểm 1, ô ấy được
  tick bằng cảm giác — đúng thứ cổng pha 1 mất nhiều lượt để bỏ (`work/findings.md` **F-033**).
- **Hậu quả ở quán nếu bỏ bước này.** Một mệnh đề chạm tiền tụt tầng mà không ai thấy nghĩa là cái
  duy nhất chặn nó là người thao tác nhớ đúng luật, lúc đông khách. `I-001` tụt tầng ⇒ hai phiên
  chưa thanh toán trên một bàn ⇒ một hoá đơn không ai thu.

**Rejected alternatives:**

- *Để mỗi lát lược đồ tự quyết nghĩa của **tầng 1**, rồi thống nhất lại ở `P2-13`.* Bác: năm lát
  chạy song song, nên năm cách hiểu chỉ gặp nhau ở cuối pha — lúc mỗi lát đã có pointer trỏ vào và
  sửa phải sửa cả năm. Đây đúng hình `work/findings.md` **F-010** · **F-014** mô tả cho `work/scope.txt`,
  chỉ khác chỗ áp dụng.
- *Gộp bước này vào `P2-03` (quy ước dữ liệu) cho gọn.* Bác: `P2-01` đặt **thước**, `P2-03` dùng
  thước để chốt *tiền cất bằng gì*. Một lượt vừa đặt vừa dùng thước là lượt tự chấm mình — và chữ
  *"và"* nối hai danh từ khác nhau là dấu hiệu chẻ việc sai mà kế hoạch §6 gọi tên.
- *Viết kèm một lược đồ mẫu nhỏ để "dễ hình dung".* Bác, và đây là phương án nguy hiểm nhất vì nó
  hữu ích nhất trong ngắn hạn: một ví dụ `CREATE TABLE` trong ADR này sẽ được mười ba bước sau đọc
  như lược đồ đã chốt — đúng cách đề xuất 16 bảng ngày 2026-08-31 suýt trở thành lược đồ thật (kế
  hoạch §10 · `architecture.md` §8 đã đo **tám** chỗ đề xuất ấy chưa có chỗ cất).
- *Cho phép hạ tầng khi dựng không nổi ràng buộc, miễn là ghi lý do.* Bác: một ngoại lệ có lý do
  vẫn là một ngoại lệ, và pha 1 vừa trả giá cho đúng đường ấy — **ADR-048** chốt *pha 1 viết hộ pha
  sau thì **viết lại**, không khai thành ngoại lệ*. Hạ tầng là đổi một câu của pha 1, nên nó phải
  đi qua pha 1.

**Ba chỗ quyết định này CỐ Ý không chạm, vẫn thuộc chủ repo** (**ADR-049**, kế hoạch §8): lược đồ
admin đi cùng pha 2 hay theo lane của nó · ba hàng `CLAUDE.md` §2 đổi ở ba bước khác nhau hay đổi
hết ở lượt mở thư mục · nhà cho `work/findings.md` **F-034** (*mất hẳn bản ghi đã ghi*).

**Pointer sửa trong cùng thay đổi** (`CLAUDE.md` §7.2): `scripts/check-links.sh` (lane `prompt/DB/`
vào danh sách Gate 1b chấm — **F-007**) · `prompt/DB/` → `README.md` mới · `work/backlog.md`
(`P2-01` → *Done*, `P2-02` · `P2-03` → *Ready*) · `work/backlog_DB.md` (entry `P2-01` + *Mục lục*).

---

### ADR-051 — Lane pha 2 thí điểm: entry ở `work/backlog_DB.md` là hồ sơ thực thi DUY NHẤT của một bước, và trạng thái chỉ sống ở `work/backlog.md`

**Trạng thái:** Đã chốt 2026-09-25 — chủ repo đồng ý trong phiên đề xuất tinh gọn *"một hồ sơ thực
thi cho mỗi task, một nơi giữ trạng thái"* (T-083). Phạm vi là **thí điểm trên lane pha 2**
(`P2-03`…`P2-14`); lane pha 1, lane admin và task `T-XXX` giữ luật cũ cho tới khi thí điểm được
đánh giá.

**Context:**
Đo ngày 2026-09-25, trước quyết định này:

- Trạng thái của một bước pha 2 nằm ở **ba** chỗ: dòng `- [ ]`/`- [x]` ở `work/backlog.md`, cột
  *Trạng thái* (**Mở**/**Đóng**) ở *Mục lục* của `work/backlog_DB.md`, và dòng *✅ Xong ngày…* ở đầu
  entry. **Mức** của bước chép thêm ở cột *Mức* của *Mục lục*, trong khi owner của nó là kế hoạch
  §6 (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`).
- Hình ba chỗ ấy **đã trôi một lần thật**: `work/findings.md` **F-032** (2026-09-07) — *Mục lục*
  `work/backlog_SD.md` ghi **Đóng** cho hai bước thiếu dòng *✅ Xong ngày…*, gate xanh suốt vì không
  cổng nào canh mẫu `P1-XX`. F-032 chọn vá dòng thiếu; quyết định này bỏ luôn hình dạng cho lane pha 2
  — không còn hai chỗ thì không còn gì để lệch, và không phải dựng phép so thứ tư ở Gate 1c.
- Một bước có **hai** hồ sơ: entry (vì sao, hỏng thì mất gì, mười bước) và một file prompt ở
  `prompt/DB/` giữ *Acceptance* · *Verify* (luật *entry TRỎ, prompt GIỮ* — `work/backlog.md` →
  *Task Detail Template*).
- Commit của `P2-02` (`d57cf4f`) chạm **năm** file; **ba** là giấy tờ (file prompt, hai sổ backlog),
  **hai** là việc thật (script và bộ test của nó). `P2-01` (`0715382`) cùng hình.
- Luật 2 của `work/backlog_DB.md` viện dẫn **ADR-008** cho quy tắc *"prompt chỉ viết khi mọi bước
  phụ thuộc đã Done"*. ADR-008 nói về lịch sử git; quy tắc ấy là của **T-051**. Không gate nào bắt
  được, vì đường dẫn vẫn mở — một ví dụ sống của việc nhiều bản cùng nói một chuyện (**F-001**).

**Decision:**

1. **Một bước pha 2 có đúng một hồ sơ: entry của nó ở `work/backlog_DB.md`.** Entry có **ba nửa**,
   mỗi nửa một thời điểm viết:
   - *lúc lập kế hoạch* — Goal · vì sao · hỏng thì mất gì · cách hoàn thành · bẫy (các khối đang
     có);
   - *lúc nhận việc*, **chỉ khi mọi bước ở *Cần xong trước* đã `Done`** — khối **Nhận việc**: Phạm
     vi · Nghiệm thu · Kiểm chứng. Quy tắc thời điểm của T-051 **giữ nguyên**, chỉ đổi chỗ viết:
     Nghiệm thu viết sớm hơn là đoán (**F-013** · **F-017**);
   - *lúc đóng* — khối **Bàn giao**: kết quả, output gate, phần còn thiếu kèm link tới owner.
2. **File prompt riêng cho một bước không còn bắt buộc.** Lời gọi một phiên chỉ cần *"làm P2-XX theo
   entry của nó ở `work/backlog_DB.md`"*. Prompt **tái sử dụng được** vẫn viết ở `prompt/DB/`; hai
   file prompt đã có (`P2-01`, `P2-02`) ở lại làm bằng chứng, không chuyển nội dung.
3. **Trạng thái chỉ sống ở `work/backlog.md`.** Bỏ cột *Trạng thái* của *Mục lục*; dòng *✅ Xong
   ngày…* của `P2-01` · `P2-02` đổi thành khối **Bàn giao** cuối entry — giữ **kết quả**, không giữ
   **trạng thái**.
4. **Mức và thứ tự chỉ sống ở kế hoạch §6.** Bỏ cột *Mức* của *Mục lục* và chữ mức trong dòng đầu
   entry. Dòng đầu entry vẫn nói *cần xong trước* / *chặn* như **bản đọc nhanh**; lệch với §6 thì §6
   thắng và dòng entry là bug của lượt thấy nó.

**Rejected alternatives:**

- *Chuyển cả bốn sổ cùng lúc.* Bác: thí điểm trên một lane trước, đo lại, rồi mới áp rộng — đề xuất
  gốc tự đặt thứ tự ấy, và bốn sổ cùng đổi là bốn chỗ cùng hỏng nếu khuôn sai.
- *Viết sẵn Nghiệm thu cho mười hai bước còn lại ngay lượt này, "cho đủ khuôn".* Bác: phần lớn các
  bước ấy chưa hết chặn — Nghiệm thu viết lúc này là đúng loại câu đoán **F-013** · **F-017** ghi.
- *Bỏ luôn dòng* cần xong trước / chặn *ở đầu entry cho sạch bản chép.* Bác lúc này: phiên nhận việc
  cần biết ngay bước có nhận được không mà không mở thêm file; đổi lại, §6 được nói rõ là bên thắng.

**Hệ quả:**

- Một bước pha 2 xong chạm **hai** sổ thay vì ba chỗ giấy tờ (không còn file prompt, không còn
  *Mục lục* phải đổi). Đo lại sau `P2-03` · `P2-04` — mốc gốc là commit `d57cf4f`.
- **Chưa giải quyết ở đây:** vòng đời `work/scope.txt` và việc Gate 7b im lặng khi scope trống; nhãn
  PASS/FAIL/SKIP/NOTE của gate; phần *việc đã xong* chiếm phần lớn `work/backlog.md`; rút gọn
  `CLAUDE.md`. Mỗi việc một dòng *Ready* ở `work/backlog.md`, thứ tự theo đề xuất gốc — `CLAUDE.md`
  **sau cùng**, vì nó mô tả quy trình và rút trước là viết hai lần.
- **Đo lại 2026-09-28 (T-119, Claude Code; chủ repo chọn *"đánh giá thí điểm trước"* T-087).** Bảy
  bước đã xong từ khi thí điểm bắt đầu: `P2-03` · `P2-12` · `P2-04` · `P2-05` · `P2-06` · `P2-07` ·
  `P2-10`. Đếm của phiên đo, không phải con số chốt:
  - *Giấy tờ bắt buộc* — mốc `d57cf4f` là ba file (file prompt + hai sổ). Sau thí điểm: **không
    bước nào** có file prompt; commit của bước chạm đúng hai sổ ở `P2-04` · `P2-07` · `P2-10`, thêm
    kế hoạch pha 2 ở `P2-06`, chỉ `work/backlog_DB.md` ở `P2-03` · `P2-12`. `work/findings.md` ở
    `P2-04` · `P2-07` là finding thật, không tính là giấy tờ.
  - *Chỗ giữ trạng thái* — *Mục lục* không còn cột trạng thái hay mức; không entry nào còn dòng
    *✅ Xong ngày…* (hai dòng còn thấy là bước 9 của `P2-01` · `P2-02`, viết theo luật cũ). Còn **một**
    bản chép: kế hoạch pha 2 §4 hàng `F-043` ghi *"`P2-04` (xong)"*. Mục tiêu *"một nơi giữ trạng
    thái"* đạt.
  - *Ba nửa của entry* — cả bảy entry có khối *Nhận việc* và *Bàn giao*. Git **không chứng minh
    được** Nghiệm thu viết trước khi dựng: khối ấy và việc thật vào cùng một commit.
  - *Lỗi thí điểm không bắt được* — dấu *Done* của **ba trên bảy** bước rơi vào commit của task
    khác: `P2-03` · `P2-12` trong `598d7ee` (T-101), và `P2-05` — cả migration lẫn test — trong
    `71f8705` (T-104). Trạng thái vẫn ở một nơi, nhưng lịch sử git nói sai commit nào mang bước
    nào: đúng hình **F-025**. Thí điểm không nhắm tới lỗi này; T-085 (scope mỗi task một file, Gate
    7b chấm theo mã trong subject) nhắm tới nó và chưa đo được, vì nhánh của nó chưa gộp.
  - *Chỗ trỏ bị sót* — kế hoạch pha 2 §5 vẫn đòi một file prompt mỗi bước và vẫn viện dẫn ADR-008
    cho quy tắc của T-051; không nằm trong danh sách *Pointer sửa* bên dưới. T-119 sửa.
  - **Chưa quyết — của chủ repo:** áp khuôn *một entry, trạng thái một nơi* cho lane admin
    (`work/backlog_AD.md`) và task `T-XXX`, hay giữ thí điểm ở lane pha 2. T-087 viết `CLAUDE.md`
    theo quyết định ấy.

**Pointer sửa trong cùng thay đổi** (`CLAUDE.md` §7.2): `work/backlog_DB.md` (luật đầu file ·
*Mục lục* · mọi entry · khuôn cuối file) · `work/backlog.md` (*Task Detail Template* nói ngoại lệ
của lane pha 2) · `prompt/DB/README.md` (luật 1) · `docs/prompt-guideline.md` (đầu file).


---

### ADR-052 — Claude Code và Codex dùng chung luật, mỗi worktree một người sửa

**Trạng thái:** Đã chốt 2026-09-25 — chủ repo yêu cầu triển khai đề xuất tích hợp hai công cụ (T-088).

**Context:** Quy trình đang tập trung trong `CLAUDE.md`; brief và kiểm tra báo cáo
được nối vào hook Claude. Codex chưa có điểm vào. Lệnh gate chạy trực tiếp không
đọc transcript và không thực hiện Gate 7/7b.

**Decision:** Thêm `AGENTS.md` làm điểm vào trỏ tới luật chung ở `CLAUDE.md`.
Claude giữ hook hiện có; Codex gọi brief và gate trực tiếp, tự kiểm khối commit.
Quy tắc vận hành và bàn giao duy nhất nằm ở `CLAUDE.md` §7.4: một người sửa trên
mỗi worktree, bàn giao trong entry task hiện có, review dựa trên nguồn và diff.

**Rejected alternatives:** Sao chép toàn bộ luật thành hai bộ dễ gây lệch;
di chuyển toàn bộ luật lúc này chồng lên T-087; xây hệ thống điều phối và chuyển
lõi Gate 7 ngay vượt phạm vi tích hợp tối thiểu, trong khi T-085 đang chờ giải
quyết nguồn scope sau Done.

**Hệ quả:** Gate 1b kiểm tra thêm điểm vào Codex. Hai công cụ dùng chung nguồn
và task state nhưng mức tự động hoá khác nhau. T-085 vẫn giữ việc xử lý scope;
không tuyên bố kiểm tra bàn giao Codex đã được tự động hoá.

---

### ADR-053 — Pha 2 dựng trên nền gì và cái gì chứng minh nó còn đúng: DBMS chốt trước lát lược đồ đầu tiên, migration thắng tài liệu, mỗi quy ước dữ liệu một lệnh gác

**Trạng thái:** **Đã chốt** 2026-09-25. Viết theo yêu cầu chủ repo trong phiên (*"làm cho tôi 2
prompt: 1 là làm các cải tiến, 2 là thực hiện các điểm cần cải thiện db"*, rồi *"hãy đọc kĩ prompt
trên và thực hiện từng bước"*); task **T-096**, prompt
`prompt/maintenance/02-quy-trinh-db-tu-du-an-cu-L2.md`. **Luật 1 và luật 3** chỉ đổi thứ tự và đầu
ra kiểm chứng của kế hoạch pha 2, đúng việc chủ repo giao, nên được thi hành từ lượt này. **Luật 2**
đổi nghĩa một hàng của `CLAUDE.md` §2 vào lúc hàng ấy được viết ở `P2-04`, nên nó cần lời của **chủ
repo**. Lời ấy có ngày **2026-09-25**, trong cùng phiên, khi được hỏi *"tài liệu và code dựng
database nói khác nhau thì tin bên nào"*; nguyên văn: *"code dựng database nói khác nhau thắng"*.

**Cái được bảo ≠ cái suy ra** (`CLAUDE.md` §7.2): lời ấy chốt **ý 1** của luật 2 — file migration
thắng về tên · kiểu · ràng buộc. **Ý 2** (file `.md` giữ ý định, lý do, ánh xạ) và **ý 3** (lệch ⇒
một dòng `F-XXX`, không lặng lẽ sửa bên nào) là phần phiên viết suy ra để ý 1 thi hành được, theo
cách `README.md` cũ §2 làm. Chủ repo đã được giải thích cả ba ý trước khi trả lời và không bác ý
nào, nhưng cũng không nói riêng về ý 2 · 3; ai muốn đổi hai ý ấy thì hỏi chủ repo, không cần mở lại
ý 1.

**Context:**
Nguồn đối chiếu là năm file DB của dự án cũ ở `work/proposals/from_old_project/data_base/` (chủ yếu
`nghien-cuu.md` và `README.md`). Chúng là **bằng chứng của dự án cũ, không phải dữ kiện của quán
này** (`CLAUDE.md` §2, hàng *Proposals*). Không tên bảng nào của dự án ấy đi vào kế hoạch hay
backlog pha 2. Đối chiếu với kế hoạch pha 2 ngày 2026-09-25, có ba lỗ:

1. **Năm lát lược đồ có thể chạy trước khi biết DBMS.** Kế hoạch §6 cho `P2-04`…`P2-08` bắt đầu
   sau `P2-03` (vài lát cần thêm lát khác). Stack chỉ được chốt ở `P2-12`, nhưng `P2-12` không nằm
   trong *Cần xong trước* của lát nào, và §6 còn viết *"`P2-02` và `P2-12` độc lập với cả dãy"*.
   Trong khi đó *Đầu ra kiểm chứng được* của năm lát đòi *cố tình dựng trạng thái sai ⇒ database từ
   chối, dán output*, tức là cần một database thật. Bằng chứng của dự án cũ (`nghien-cuu.md` §1.3,
   §2.7) cho thấy lời giải phụ thuộc chính DBMS: hệ họ dùng không có chỉ mục duy nhất có điều kiện
   nên phải mô phỏng bằng cột sinh trả `NULL`, còn ràng buộc kiểm chỉ được thực thi từ phiên bản
   8.0.16. Một ràng buộc dựng trước khi chốt DBMS và phiên bản là ràng buộc có thể phải dựng lại.
2. **Khi đã có file migration, lược đồ có hai bản mà không luật nào nói bản nào thắng.** Tên bảng
   và tên cột nằm cả trong `docs/product/2-db/` lẫn trong file migration. Hàng *Schema* của
   `CLAUDE.md` §2 (đổi ở `P2-04`, kế hoạch §5) chưa nói gì về chuyện này. Dự án cũ đã trả giá ba lần
   (`nghien-cuu.md` §4.1–§4.3): tài liệu nhắc một cột không tồn tại, gọi một cột bằng tên khác với
   migration (`pin_code` so với `pin_hash`), và ghi *chưa seed bàn* khi seed đã có mười một bàn. Họ
   phải thêm luật *migration thắng tài liệu*, cùng một lệnh đọc thẳng file migration (`README.md`
   cũ §2, và phép D ở §3).
3. **Quy ước dữ liệu chỉ đòi hậu quả, không đòi lệnh gác.** Hàng `P2-03` ở kế hoạch §6 đòi *mỗi quy
   ước một dòng, mỗi dòng một hậu quả nếu làm khác*. Dự án cũ đã viết sẵn một câu truy vấn trên
   `information_schema` để chặn cột tiền không phải kiểu nguyên, ghi *"thêm vào CI"*, rồi không lệnh
   nào gọi tới nó (`nghien-cuu.md` §1.1). Chính họ kết luận: *"luật không có lệnh gác thì tự trôi"*.

Ba lỗ này là **một** quyết định: *pha 2 dựng trên nền gì, và cái gì chứng minh nền ấy còn đúng*.

**Decision:**

1. **DBMS và phiên bản được chốt trước lát lược đồ đầu tiên, bằng cách đưa `P2-12` vào *Cần xong
   trước* của `P2-04`…`P2-08`.** `P2-12` giữ nguyên nội dung (stack · thư mục · đặt tên · khung
   test), nhưng **mục đầu tiên** của nó là *chọn DBMS + phiên bản*, và câu kiểm của mục ấy là một
   lệnh in ra phiên bản đang chạy. Thứ tự mới là `P2-03` → `P2-12` → năm lát; `P2-02` vẫn độc lập.
   Kế hoạch vẫn **mười bốn** dòng. Lượt này **không chọn DBMS**: chọn stack là việc của `P2-12` và là
   quyết định chủ repo phải thấy (**ADR-039**).
2. **Luật chủ sở hữu khi đã có file migration.** Ba câu, áp từ lúc file migration **đầu tiên** tồn
   tại. Tên file và vị trí thư mục migration là đầu ra của `P2-12`, không viết ở đây.
   1. **Tên bảng, tên cột, kiểu và ràng buộc: file migration thắng.** Nó là thứ database chạy; chữ
      trong `.md` chỉ là bản đọc.
   2. **File `.md` của `docs/product/2-db/` giữ ý định, lý do, và ánh xạ sang `I-0xx`/`YC-xx`**:
      ràng buộc nào mang mệnh đề nào, cái gì hỏng nếu làm khác. File ấy được nhắc tên bảng, nhưng
      không chép lại kiểu và ràng buộc thành bản thứ hai (**F-001**).
   3. **Hai bản lệch nhau ⇒ một dòng `F-XXX`.** Không sửa migration cho khớp chữ, và cũng không
      lặng lẽ sửa chữ cho khớp migration. Một chỗ lệch hoặc là ý định đã đổi (một quyết định), hoặc
      là migration sai (một lỗi), và finding là chỗ phân xử — đúng cách `README.md` cũ §2 xử cặp
      *luật ↔ migration*.

   **Phép kiểm, mô tả bằng lời:** mọi tên bảng mà các file `.md` của `docs/product/2-db/` nhắc tới
   đều có trong file migration, và mọi tên bảng file migration tạo ra đều được một file `.md` nhắc
   tới. Hai danh sách tên, `comm -3` ra **rỗng**. **`P2-09`** là bước biến phép này thành lệnh và
   nối lệnh ấy vào một cổng chạy mỗi lượt (`./scripts/gate.sh`). Lệnh phải **in cả danh sách chưa
   lọc cạnh kết quả đã lọc** (**F-017**). Trước `P2-09`, lát nào tạo migration thì tự chạy phép so
   này bằng tay và dán output vào khối *Bàn giao* của mình.

   Khi `P2-04` đổi hàng *Schema* của `CLAUDE.md` §2 (kế hoạch §5), hàng ấy viết theo ba câu trên:
   file migration là nhà của tên · kiểu · ràng buộc; file lát ở `docs/product/2-db/` là nhà của ý
   định và ánh xạ.
3. **Mỗi quy ước dữ liệu của `P2-03` kèm một phép kiểm chạy được** (một câu truy vấn hoặc một
   lệnh), bên cạnh hậu quả nếu làm khác. Vì DBMS chưa chốt ở `P2-03`, phép kiểm viết trên thứ không
   phụ thuộc DBMS: câu truy vấn trên `information_schema` chuẩn SQL, hoặc một lệnh đọc file
   migration. `P2-12` chạy lại từng phép trên DBMS vừa chọn (cơ sở dữ liệu rỗng ⇒ 0 dòng); phép nào
   không chạy nổi là bug của `P2-12`. `P2-11` **gom** các phép ấy vào bộ đối chiếu thành một nhóm
   riêng mang mã quy ước của file `P2-03`, không trộn vào phép so danh sách mã `I-0xx`, và chứng minh
   từng phép **biết kêu** theo **ADR-050** luật 3.

**Rejected alternatives:**

- *(Lỗ 1) Tách "chọn DBMS + phiên bản" thành một bước riêng, hoặc thành một mục của `P2-12` có
  trạng thái riêng.* Bác vì năm lát cần nhiều hơn tên DBMS. Chúng viết ràng buộc vào file migration,
  mà **thư mục và cách đặt tên** của file ấy cũng là đầu ra của `P2-12`. Tách riêng DBMS thì lát vẫn
  phải chờ nốt phần ấy, hoặc tự đặt tên thư mục — đúng ca *phiên đầu tiên tự bịa quy ước* mà hàng §2
  của quy ước code sinh ra để chặn. Một mục có trạng thái riêng bên trong một bước thì
  `work/backlog.md` không chứa được, vì trạng thái đi theo bước (**ADR-051**). Còn một bước riêng
  đẩy kế hoạch lên **mười lăm** dòng, vượt khuyến nghị mười hai thêm một dòng nữa, chỉ để phần thư
  mục và khung test chạy song song với lát — trong khi lát cần đúng phần ấy trước khi viết dòng đầu
  tiên.
- *(Lỗ 1) Để nguyên, lát đầu tiên tự chọn DBMS.* Bác: chọn stack là quyết định chủ repo phải thấy
  (**ADR-039**), và một bước L2 không được quyết thay.
- *(Lỗ 2) Tài liệu thắng, migration phải sửa theo.* Bác: tài liệu không chạy. Dự án cũ đo ba lần chữ
  trôi khỏi migration, và không lần nào database sai theo chữ.
- *(Lỗ 2) Bỏ tên bảng khỏi `.md`, chỉ để migration.* Bác: mất chỗ giữ ý định và ánh xạ
  `I-0xx`/`YC-xx`, thứ `P2-11` và `P2-13` phải đọc. File migration không nói *vì sao*.
- *(Lỗ 2) Giao lệnh đối chiếu cho `P2-11`.* Bác: `P2-11` chấm **dữ liệu** sau khi đóng quán, còn
  phép này chấm **chữ so với lược đồ**. Chỗ lệch sinh ra mỗi khi một migration đổi, tức ở `P2-09`,
  bước sở hữu dãy migration. Giao cho `P2-11` là để lệnh ra đời muộn hai bước, trong khi lệch có thể
  đã có từ `P2-04`.
- *(Lỗ 3) Chỉ cần hậu quả, lệnh gác để `P2-11` viết.* Bác: đó đúng là hình của dự án cũ — câu truy
  vấn nằm trong tài liệu, lời hứa *thêm vào CI*, và không lệnh nào gọi. Phép kiểm phải ra đời
  **cùng** quy ước.

**Chỗ ADR này KHÔNG chốt:**
- **DBMS nào, phiên bản nào** — `P2-12`, chủ repo thấy. Bản ở `master_plan/prompt-fullstack.md` §3.4
  vẫn chỉ là đề xuất để đối chiếu (**ADR-035** luật 3).
- **Tên file và vị trí thư mục migration** — `P2-12`.
- **Lệnh đối chiếu viết thế nào** — `P2-09`. ADR này chỉ nói nó so cái gì và phải ra cái gì.

**Applies to:** `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §5 · §6 · §8 ·
`work/backlog_DB.md` entry `P2-03` · `P2-04`…`P2-08` · `P2-09` · `P2-11` · `P2-12`.

---

### ADR-054 — Claude quyết, Codex thi công: chia vai giữa hai công cụ

**Trạng thái:** Đã chốt 2026-09-27 — chủ repo yêu cầu (*"claude sẽ là người làm những việc quan
trọng là sếp và codex sẽ là nhân viên"*), đọc đề xuất
`work/proposals/claude-sep-codex-nhan-vien.md` rồi bảo *"hãy áp dụng luật này cho dự án này luôn"*.
Task **T-100**.

**Context:** ADR-052 cho hai công cụ dùng chung luật và *mỗi worktree một người sửa*, nhưng không
nói ai quyết, ai làm, ai duyệt. Lỗi đắt nhất của repo nằm ở khâu quyết định và bàn giao: sự thật bị
bịa (F-003, F-004) và commit mang nhầm nội dung (F-025, F-031). Chỉ Claude có hook `SessionStart`
và `Stop`, nên chỉ lượt của Claude có Gate 7/7b chấm khối commit.

**Decision:** Claude giữ mọi khâu mà sai thì tốn tiền hoặc sai sự thật nghiệp vụ — chọn task và đổi
trạng thái, chấm mức, Acceptance, scope, thiết kế, ADR, unknowns, `shop-facts.md`, `invariants.md`,
ghi lời chủ quán, duyệt, tích hợp, viết khối commit. Codex thi công theo **phiếu giao việc** trong
worktree và scope riêng, chạy gate, báo cáo có bằng chứng; không quyết câu hỏi nghiệp vụ, không sửa
trạng thái task hay các owner trên, không commit. Claude là integrator mà `CLAUDE.md` §7.4 đòi, tự
đọc diff thật và tự chạy lại gate. `git commit` vẫn là của chủ repo (ADR-004). Luật ở `CLAUDE.md`
§7.4 *Roles*; quy trình, lệnh và mẫu phiếu ở `docs/prompt-guideline.md` §6.1.

**Rejected alternatives:** Hai công cụ ngang hàng, ai nhận task nấy tự quyết (hiện trạng từ ADR-052)
— giữ nguyên chỗ hở ở khâu quyết định. Codex làm cả task kể cả ghi lời chủ quán — đúng loại việc mà
kết quả là sự thật nghiệp vụ, không gate nào bắt được. Viết một script điều phối — chưa có lỗi nào
lặp hai lần để biện minh (`CLAUDE.md` §3.8).

**Hệ quả:** Việc ghi lời chủ quán mà Codex đã làm ở T-090…T-099 từ nay thuộc Claude. Phần giao được
cho Codex hôm nay còn ít vì repo phần lớn là tài liệu; sẽ tăng từ `P2-04` khi có migration và code.
Codex không có hook, nên brief và gate phía Codex vẫn dựa vào phiếu — bù bằng bước duyệt của Claude.
Cờ `codex exec` có thể đổi giữa các bản.

**Sửa đổi 2026-09-27 (T-101):** chủ repo: *"khi làm task mới claude chỉ đạo codex làm nhưng cũng có
những task nhỏ thì tôi và codex sẽ tự làm nên những công việc đó codex có thể sửa 1 số file"*. Task
L0/L1 chủ repo giao thẳng cho Codex, không qua phiếu, thì chủ repo là người dẫn: Codex được đổi trạng
thái của chính task ấy, viết entry chi tiết, khai/gỡ scope, thêm `F-XXX` và thêm `U-XXX` đang mở.
**Suy ra, chưa được xác nhận** (`CLAUDE.md` §7.2): danh sách *"một số file"* là do phiên chọn — vẫn
để ngoài tay Codex `docs/decisions.md`, `shop-facts.md`, `invariants.md`, việc đóng unknown và
`git commit`, vì đó là chỗ sự thật nghiệp vụ bị bịa (F-003, F-004); chủ repo muốn nới thêm thì chỉ
cần một câu. Task hoá ra L2+ hoặc cần các owner ấy thì trả về Claude.

**Applies to:** `CLAUDE.md` §7.4 · `AGENTS.md` · `docs/prompt-guideline.md` §6.1.

---

### ADR-055 — DBMS là PostgreSQL 17

**Trạng thái:** **Đã chốt** 2026-09-27, **giao cho phiên**. Chủ repo, khi được hỏi *"chọn DBMS
cho `P2-12`"*, trả lời nguyên văn: *"DBMS cho P2-12: làm theo đề xuất của bạn"*. Đó là lời **giao
việc chọn trước khi thấy phương án**, không phải lời xác nhận một phương án cụ thể (`CLAUDE.md`
§7.2 — *cái được bảo ≠ cái suy ra*): chủ repo đọc ADR này rồi muốn đổi thì chỉ cần một câu, và lượt
đổi phải xong **trước** khi lát đầu tiên (`P2-04`) có migration. Task **P2-12**.

**Context:**
**ADR-053** luật 1 buộc chọn DBMS + phiên bản trước lát lược đồ đầu tiên. Đề xuất duy nhất có sẵn là
*"MySQL 8.4 LTS"* ở `master_plan/prompt-fullstack.md` §3.4 (2026-08-31). Đó là bản xuất khẩu, không
sở hữu gì (**ADR-035** luật 3), và được viết **trước** phần lớn lời chốt của chủ quán. Năm lát cần
ba thứ từ DBMS: (1) `I-001` — *một bàn tối đa một phiên còn nợ tiền* — là một **khoá duy nhất chỉ
áp cho vài trạng thái**; (2) mỗi migration hoặc chạy trọn, hoặc không để lại gì; (3) một kiểu mốc
thoả cả ba điều kiện của `QD-30`. Bằng chứng dự án cũ, không phải dữ kiện quán này:
`work/proposals/from_old_project/data_base/nghien-cuu.md` §1.3 — MySQL **không có** khoá duy nhất
có điều kiện, phải mô phỏng bằng cột sinh trả `NULL` rồi đặt `UNIQUE` lên cột ấy; và dự án cũ đã
viết điều kiện theo **một giá trị trạng thái**, nên ràng buộc nhả ra đúng lúc quầy bấm tính tiền.

**Decision:** PostgreSQL, phiên bản chính **17**, cho mọi môi trường. Quy ước chi tiết — cách chạy,
vai, kiểu, migration, khung test, thư mục — ở `docs/product/2-db/10-quy-uoc-code.md` `QC-01`…`QC-10`.
Ba lý do, mỗi lý do một nhu cầu ở trên:
1. **Khoá duy nhất có điều kiện là cú pháp gốc** (`CREATE UNIQUE INDEX … WHERE …`): điều kiện viết
   theo **nghĩa** — *bàn còn nợ tiền*, gồm cả *chờ thanh toán* — đọc thẳng được, không qua một cột
   sinh mà người đọc phải giải mã. Ràng buộc kiểm được thực thi từ trước tới nay, không phụ thuộc
   bản vá.
2. **DDL chạy trong giao dịch:** một migration hỏng ở câu thứ năm thì bốn câu trước cũng lùi. MySQL
   tự chốt từng câu DDL, nên migration hỏng giữa chừng để lại một lược đồ nửa vời mà công cụ đánh
   dấu *dirty*.
3. **`timestamptz`** cất một thời điểm tuyệt đối, phạm vi tới năm 294276, micro giây — thoả cả ba
   điều kiện của `QD-30`. Kiểu `TIMESTAMP` của MySQL hết hạn năm 2038.

**17** chứ không 18: bản chính mới nhất đã qua hơn một năm vá, hỗ trợ tới tháng 11/2029. Việc lên
18 sau này là một ADR mới (`QC-01`). Bộ kiểm (`scripts/db-check.sh`) đã chạy trên 17.11:
`QD-01`…`QD-61` và `QC-01`…`QC-10` ra 0 dòng trên cơ sở dữ liệu rỗng; một bảng cố tình sai làm đỏ
mười phép `QD` dạng SQL, hai phép `QC` và cả hai phép dạng lệnh có dữ liệu để soi (output ở *Bàn giao*
của `P2-12`, `work/backlog_DB.md`).

**Rejected alternatives:**
- **MySQL 8.4 LTS** (đề xuất §3.4). Chạy được, và dự án cũ đã dùng nó. Bị loại vì cả ba lý do trên:
  `I-001` phải mô phỏng bằng cột sinh — đúng chỗ dự án cũ viết sai điều kiện; DDL không lùi được;
  `TIMESTAMP` có hạn 2038, buộc mọi lát phải nhớ tránh một kiểu.
- **SQLite.** Một file, không cần server — hợp với quán một máy. Bị loại vì quán có **nhiều máy ghi
  đồng thời** (năm kênh, bốn trạm, POS), SQLite khoá cả file mỗi lần ghi, và việc giữ đúng khi
  hai máy cùng ghi một bàn là việc năm lát muốn giao cho database, không cho ứng dụng.
- **PostgreSQL 18.** Mới hơn, hỗ trợ lâu hơn một năm. Không có tính năng nào năm lát cần mà 17
  thiếu; chọn 17 để bản đầu tiên chạy trên bản đã vá lâu nhất.

**Hệ quả:**
- Câu *"MySQL 8.4"* ở `master_plan/prompt-fullstack.md` §3.4 nay sai. File ấy không sở hữu gì, nên
  không sửa nội dung; một dòng ở đầu §3.4 trỏ về đây.
- Các phần khác của §3.4 (Go, Next.js, golang-migrate, Node 24) **không** được ADR này chốt.
  `QC-05` dùng golang-migrate và `QC-09` dùng Go · Next.js như **đề xuất**; chủ repo chưa đọc lại
  chúng sau ngày 2026-08-31.
- Các câu kiểm `QD-XX` của `01-quy-uoc-du-lieu.md` nay viết bằng cú pháp PostgreSQL (vế ASCII của
  `QD-01`, vế `PUBLIC` của `QD-50`, vế kiểu văn bản của `QD-60`); nghĩa của chúng không đổi.

**Chỗ ADR này KHÔNG chốt:** máy chạy thật, sao lưu (**F-034**), cách backend kết nối (`QC-06`, pha
3).

**Applies to:** `docs/product/2-db/10-quy-uoc-code.md` · `docs/product/2-db/01-quy-uoc-du-lieu.md`
§0 · `compose.yaml` · `db/` · `scripts/db-check.sh` · `scripts/verify.sh` ·
`master_plan/prompt-fullstack.md` §3.4 (một dòng trỏ).

### ADR-056 — Hai vế thiếu tầng của F-036: nước chấm · canh ở tầng 2, ngừng bán ở tầng 3, và bảng bảo vệ đếm theo vế

**Trạng thái:** **Đã chốt** 2026-09-27, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-036** với lời nguyên văn *"đọc kĩ và sửa"* — F-036 ghi *"chọn đường là quyết định của chủ
repo"*, và câu ấy là lời **giao việc chọn**, không phải lời xác nhận một phương án cụ thể (`CLAUDE.md`
§7.2). Chủ repo đọc ADR này rồi muốn đổi thì chỉ cần một câu; lượt đổi phải xong trước khi `P2-07`
dựng lát nổ đơn. Task **T-103**.

**Context:**
Lượt diễn P1-11 (2026-09-08) tìm ra hai vế có mặt trong lời mệnh đề ở `quality/invariants.md`
nhưng không có tầng lẫn tập đối chiếu ở `docs/product/1-system-design/03-bao-ve-invariant.md`:
việc **cấp đơn** của trạm `canh` (`I-004`) và *món đã ngừng bán thì không kênh nào đặt mới được*
(`I-009`). Luật của cả hai đã đủ, không cần hỏi thêm ai: `master_plan/shop-facts.md` §5.3 (nước
chấm đúng một mỗi đơn; canh đúng số bát khách chọn, `U-046` · `U-048`) và
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.4 (ngừng bán chặn đơn mới ở cả năm kênh, không rút
đơn cũ). Cái còn thiếu là **tầng**, và tầng là việc của pha 1 (**ADR-035**).

**Decision:**
1. **Nước chấm · canh của `I-004`: tầng 2**, trong **cùng** giao dịch nổ đơn đã giữ vế *đủ việc*.
   Lần nổ sinh đúng một việc nước chấm và một việc canh mang đúng con số trên dòng *canh bánh
   cuốn*; phép nhân *suất × thành phần* không áp cho trạm `canh`.
2. **Ngừng bán: ở lại hàng `I-009`, tầng 3** — cửa tạo lượt gọi, cửa đã đọc menu tại mốc để khoá
   giá (`I-009` · `I-013`), đọc luôn món còn đang bán tại mốc ấy và **từ chối** dòng của món đã
   ngừng.
3. **Đơn vị của bảng bảo vệ là vế** (luật đọc thứ năm ở §0 của file ấy): mỗi vế một tầng và một tập.
   Ô 1 của cổng pha 1 chấm thêm vế, không chỉ mã.

**Rejected alternatives:**
- **Tầng 1 cho *không đơn nào có hơn một việc nước chấm*** (một khoá duy nhất). Rẻ, nhưng nó chỉ giữ
  nửa **thừa**; nửa **thiếu** — đúng nửa đắt, khách mang đi về nhà không có nước chấm — vẫn chỉ
  giao dịch nổ đơn giữ được. Hai cơ chế cho một vế thì phép đối chiếu vẫn phải đọc cả hai chiều;
  thêm khoá không đổi tầng cao nhất đang giữ vế (§0 luật 1).
- **Tầng 1 cho ngừng bán** (database từ chối dòng đơn mới trỏ vào món đã ngừng). Mạnh hơn, và vế
  này chạm tiền: đặt được món đã ngừng là thu tiền rồi phải hoàn (`shop-facts.md` §6.4). Bị loại
  vì luật ấy là một phép so **mốc** giữa dòng đơn và trạng thái menu, mà menu **đổi theo thời
  gian** — một món ngừng rồi bán lại thì nghĩa của mốc ra sao chưa ai chốt. Đúng lý do `I-010` và
  `I-016` chọn tầng 3: luật đổi được mà không cần một migration. Cái máy **có** giữ thay vào: mốc
  ngừng bán được **cất** (lược đồ `P2-05` đã có, vì `QD-50` cấm xoá), nên tập đối chiếu của vế này
  đọc được từ dữ liệu.
- **Chuyển vế ngừng bán sang `I-010`**, đọc *món đã ngừng* thành một ca của *tổ hợp không hợp lệ*
  (F-036 việc 1 nêu đường này). Bị loại: lời `I-009` tự liệt *ngừng bán hẳn* trong bốn chiều và có
  kịch bản riêng cho nó; `I-010` nói về tổ hợp **tuỳ chọn**. Chuyển sang thì phải sửa lời hai mệnh
  đề để giữ một vế — và cùng cửa, cùng luật *từ chối, không sửa hộ* vẫn áp như nhau.

**Hệ quả:**
- `P2-07` dựng lát nổ đơn với hai loại việc trạm `canh`; tập đối chiếu của hai vế ấy có sẵn ở hàng
  `I-004`.
- `P2-05` không cần migration mới cho ngừng bán: cửa tạo lượt gọi là pha 3. Test
  `db/tests/i009_snapshot_survives_menu_change.sql` in đúng câu *database không chặn dòng mới cho
  món đã ngừng* — câu ấy nay là **thiết kế**, không phải chỗ trống.
- Lượt rà theo vế tìm thêm năm hàng cùng hình (`I-003` · `I-008` · `I-010` · `I-015` · `I-017`),
  tất cả đã có luật đủ và chỉ thiếu **tập đối chiếu**; lấp cùng lượt. Năm là phép đếm của lượt này,
  không phải ranh giới (**F-003**).

**Applies to:** `docs/product/1-system-design/03-bao-ve-invariant.md` §0 · §1 · §2 · §3 ·
`quality/invariants.md` `I-004` · `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §9 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §6 · §7.


### ADR-057 — Yêu cầu khôi phục ở pha 1, cơ chế thực hiện ở pha vận hành

**Trạng thái:** Đã chốt 2026-09-27, chủ repo chọn hướng thứ ba của F-034 và cho phép Codex
sửa tài liệu, ghi quyết định, đóng finding (T-108); ngoại lệ phân vai chỉ áp dụng việc này.

**Context:** sao lưu và phục hồi chỉ được nhắc ở tài liệu không sở hữu sự thật; RR-9 không
có yêu cầu chính thức để giao cho bước triển khai.

**Decision:** `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8 sở hữu **YC-21**.
Pha 5 — Deploy/vận hành nhận thiết kế, thực hiện và kiểm chứng cơ chế, theo việc **T-109**
ở `work/backlog.md`. Không đưa công cụ hoặc lịch sao lưu vào pha 1, không giao cho migration
của P2-09 thay thế phục hồi dữ liệu. Khi mở owner pha vận hành, cập nhật CLAUDE.md §2 cùng lượt.

**Rejected alternatives:** mở thêm bước pha 1 thiết kế cơ chế sẽ lẫn ranh giới; giao hết
sang vận hành mà không có yêu cầu pha 1 sẽ giữ nguyên khoảng trống đầu vào.

**Hệ quả:** đóng F-034 ở lỗi thiếu owner và yêu cầu, không tuyên bố RR-9 đã được chặn.
Các tiêu chí chưa chốt và bằng chứng phục hồi phải được hoàn tất theo YC-21 trước bán thật;
không có con số mức mất dữ liệu hoặc thời gian phục hồi nào được quyết định trong ADR này.

**Applies to:** `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8 ·
`docs/product/1-system-design/06-so-rui-ro.md` RR-9 · `work/backlog_DB.md` P2-09 ·
`work/backlog.md` T-109.

### ADR-058 — `I-022` vào nhóm VÒNG ĐỜI, bốn vế ở tầng 1, và `YC-22` cho chỗ cất

**Trạng thái:** **Đã chốt** 2026-09-28, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-038** với lời nguyên văn *"hãy đọc kĩ và làm từng bước 1"* — F-038 ghi *"nhóm nào nhận nó là
quyết định của chủ repo"*, và câu giao việc ấy là lời **giao việc chọn**, không phải lời xác nhận
một nhóm cụ thể (`CLAUDE.md` §7.2, cùng cách đọc với **ADR-056**). Chủ repo đọc ADR này rồi muốn
đổi thì chỉ cần một câu; lượt đổi phải xong trước khi `T-111` dựng migration. Task **T-110**.

**Context:**
Lượt diễn P1-11 (2026-09-08) tìm ra một luật đã chốt của pha 0 chưa từng thành mệnh đề:
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.2.1 bước 3 · §3.2.4 — *thiếu một trường bắt buộc thì
đơn không tạo được*, với mức tối thiểu theo kênh và cách trao hàng ở `master_plan/shop-facts.md`
§6.5 (chủ quán chốt 2026-08-30). Luật đủ, không cần hỏi ai; thiếu **mệnh đề**, **tầng** và **dòng
yêu cầu**. Mệnh đề sinh sau khi kế hoạch pha 1 chia nhóm — đúng hình **F-026**, lần thứ tư, sau
`I-019`/`I-020` (**ADR-042**, nhóm mới) và `I-021` (**ADR-044**, nhóm có sẵn).

**Decision:**
1. **Mệnh đề `I-022`** ở `quality/invariants.md` — bốn vế *thiếu thì không tồn tại được* (số điện
   thoại · địa chỉ khi giao tận nơi · giờ khách cần hàng · cách trao hàng của đơn hotline), chiều
   ngược *trường nên có không chặn*, và câu *mệnh đề nói thiếu, không nói sai*.
2. **Nhóm VÒNG ĐỜI** (§2 của `docs/product/1-system-design/03-bao-ve-invariant.md`), không mở nhóm
   thứ năm: câu hỏi của `I-022` là *một đơn có được tồn tại hay không*, cùng loại với `I-001` ·
   `I-004` vế 1 · `I-006`, và bảng ấy đã có sẵn ranh giới ba kênh không gắn bàn qua `I-006`/`I-007`.
3. **Tầng 1** cho bốn vế và cho vế *Delivery là giao, Pickup là tới lấy*: cả năm là điều kiện đọc
   trên chính một đơn, không đổi theo thời gian. **Tầng 3** cho chiều ngược. Chỗ **tầng 4** nói
   thẳng: câu trả lời *giao hay lấy* của đơn hotline do người bấm.
4. **`architecture.md` §8 thêm một dòng** — nền 16 bảng chỉ đòi số điện thoại — và
   `04-yeu-cau-du-lieu.md` §1 thêm **`YC-22`** (luật một-đối-một của P1-07). Mã nhảy qua `YC-21`
   vì mã ấy đã thuộc §8 của file đó (**ADR-057**).

**Rejected alternatives:**
- **Gấp vào `I-007`** (đơn mang đi là đơn vị thanh toán độc lập). Cùng lát cắt, cùng ba kênh — nhưng
  `I-007` là câu về **tiền** và ở nhóm TIỀN; gấp vào là đúng cái nhầm đã giấu luật này từ BA-04
  (`work/findings.md` **F-038** *Vì sao vòng rà trước không bắt*).
- **Gấp vào `I-008`** (khi nào không đơn nào được tạo). `I-008` nói điều kiện của **quán** — giờ
  bán, tạm dừng, mất kết nối — áp cho cả năm kênh; `I-022` nói điều kiện của **chính đơn**, áp cho
  ba kênh, và giữ cả lúc sửa chứ không chỉ lúc tạo. Gấp vào thì phải viết lại lời `I-008`.
- **Mở nhóm thứ năm** (như **ADR-042**). Một mệnh đề không đủ làm một nhóm, và nó không có trục
  riêng như sản xuất theo mẻ.
- **Tầng 3** cho bốn vế (cửa tạo đơn kiểm). Yếu hơn không có lý do: luật không đổi theo thời gian
  và kênh khách tự bấm là chỗ dữ liệu vào **không qua tay người của quán**; lại phải giữ cả lúc
  sửa, không chỉ lúc tạo.

**Hệ quả:**
- `T-111` dựng một migration **mới** (`QC-05`) cho chỗ cất bốn trường và ràng buộc tầng 1, kèm
  test: năm kịch bản âm, ba kịch bản dương, một kịch bản sửa của `I-022`.
- Cổng pha 2 (`P2-13`) chấm `YC-22` cùng `YC-01`…`YC-20`.
- **Không** có luật định dạng số điện thoại hay độ đúng của địa chỉ; cần thì hỏi chủ quán qua
  `docs/product/99-unknowns.md`.

**Applies to:** `quality/invariants.md` `I-022` ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §2 ·
`docs/product/1-system-design/architecture.md` §8 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §1 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §6 ·
`docs/product/2-db/02-luoc-do-ban-hang.md` §5.

### ADR-059 — Khoản trả trước vào công thức đối soát bằng BA dòng, `I-021` thêm hạng tử cho nó, và `YC-23` cho chỗ cất

**Trạng thái:** **Đã chốt** 2026-09-28, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-037** với lời nguyên văn *"hãy đọc kĩ và làm"*. F-037 bước 4 ghi *"bày ở đâu trên bảng là việc
thiết kế"* và **không** cần hỏi chủ quán thêm: hướng đã chốt ở **ADR-040**. Câu giao việc là lời
**giao việc chọn**, không phải lời xác nhận một cách bày cụ thể (`CLAUDE.md` §7.2, cùng cách đọc
với **ADR-056** · **ADR-058**). Chủ repo đọc ADR này rồi muốn đổi thì chỉ cần một câu; lượt đổi
phải xong trước khi `P2-06` dựng lát đường tiền. Task **T-112**.

**Context:**
**ADR-040** chốt doanh thu của khoản trả trước rơi vào **ngày giao/lấy hàng**, và tự khai *"câu chữ
và cơ chế của dòng mới trong công thức đối soát §6.4 — việc của bước đọc §2 của
`02-thoi-gian-ngay-ban.md`"*. Không bước nào nhận (**F-037**, đo ở P1-11 ngày 2026-09-08). Hệ quả:
tiền vào két hoặc tài khoản **hôm nay**, doanh thu thuộc **hôm khác**, nên phép trừ `I-021` và phép
so phần chuyển khoản của `I-015` cùng lệch ở hai ngày, ngược chiều — một ô đỏ có lý do biết trước,
đường thẳng tới `RR-5`. Cả ADR-040 lẫn F-037 đều viết *"thêm **một** dòng"*.

**Decision:**
1. **Ba dòng, không phải một.** Khoản trả trước lệch ở **hai** ngày ngược chiều, đúng hình của nợ —
   và nợ có **hai** dòng. Công thức `architecture.md` §6.4 thêm:
   - **+ trả trước nhận trong ngày** — có tiền, doanh thu **chưa** tính ⇒ két thừa (chiều ngược của
     *nợ ghi trong ngày*);
   - **− trả trước thành doanh thu trong ngày** — phần đã trả trước của các hoá đơn **đóng hôm
     nay**: doanh thu tính hôm nay, tiền đã về lúc nhận ⇒ két thiếu (chiều ngược của *nợ cũ thu
     được hôm nay*);
   - **− trả lại trả trước trong ngày** — đơn đã trả trước bị huỷ hoặc bớt **trước khi đóng**: tiền
     rời quán mà không ngày nào có doanh thu của nó để trừ.

   Chữ *"một dòng"* của ADR-040 và F-037 là **phép đếm của người viết**, không phải lời chủ quán
   (`CLAUDE.md` §7.2) — lời chủ quán chỉ nói *doanh thu ngày nào*.
2. **Ba dòng không có điều kiện ngày**, giống hai dòng nợ: một khoản trả trước nhận và đóng **cùng
   ngày** hiện ở cả dòng *nhận* lẫn dòng *thành doanh thu* và tự triệt tiêu. Vì thế công thức **không
   dựa** vào giới hạn *đặt trước tối đa một ngày* (`shop-facts.md` §6.26): giới hạn ấy chỉ bó khoảng
   tiền nằm chờ, không phải điều kiện để công thức đúng.
3. **`I-021` thêm bốn hạng tử tiền mặt**: trả trước nhận bằng tiền mặt (+), phần tiền mặt của trả
   trước thành doanh thu (−), trả lại trả trước bằng tiền mặt (−) — và **nợ cũ thu bằng tiền mặt**
   (+). Hạng tử cuối không thuộc F-037: lượt đọc lại ô `I-021` (F-037 bước 3) tìm ra phép trừ ấy
   chưa từng có hạng tử cho khoản nợ được trả bằng tiền mặt, trong khi công thức §6.4 có dòng *nợ cũ
   thu được hôm nay* từ 2026-08-31. Cùng một lỗ, cùng một lần sửa; để nguyên là để `I-021` đỏ mỗi
   ngày có khách trả nợ bằng tiền mặt.
4. **Phần chuyển khoản so với tin nhắn báo có theo lúc TIỀN TỚI**, không theo mốc tính tiền. Hai mốc
   chỉ khác nhau ở khoản trả trước; đọc theo mốc tính tiền thì tin nhắn của hôm nhận tiền không có
   gì để khớp.
5. **Trả lại một khoản trả trước chưa thành doanh thu KHÔNG trừ vào doanh thu ngày nào** — *suy ra,
   không phải lời chủ quán nói thẳng*. Hai lời chốt đặt cạnh nhau buộc ra câu này: doanh thu tính vào
   ngày **đem hàng cho khách** (ADR-040), nên đơn huỷ trước khi trao chưa từng là doanh thu; còn luật
   *hoàn trừ vào doanh thu ngày hoàn* (`shop-facts.md` §6.4) nói về một lần **bán đã xong**. Đọc
   ngược lại thì tổng doanh thu của một đơn chưa bao giờ bán ra **âm**. Lần trả lại ấy vẫn là một
   lần hoàn theo nghĩa **vết** — đủ năm câu của `YC-01`, POS quyết từng ca, ghi phương thức trả lại.
   Chủ quán nói khác thì đó là một câu `U-XXX` mới, và dòng thứ ba của công thức gấp vào dòng hoàn
   tiền.
6. **`architecture.md` §8 thêm một chỗ thiếu** — nền 16 bảng không có chỗ cho lúc quán nhận tiền
   tách khỏi mốc tính tiền — và `04-yeu-cau-du-lieu.md` §1 thêm **`YC-23`** (luật một-đối-một của
   P1-07).

**Rejected alternatives:**
- **Một dòng, như ADR-040 viết.** Chỉ đỡ được **hôm nhận tiền**; hôm giao hàng két thiếu đúng bằng
  khoản ấy mà không dòng nào gọi tên — lỗi F-037 dời sang ngày hôm sau.
- **Hai dòng có điều kiện ngày** (*nhận hôm nay, đơn chưa đóng hôm nay* · *nhận hôm trước, đơn đóng
  hôm nay*). Ít dòng hơn trên bảng trong ngày thường, nhưng mỗi dòng mang một phép so hai ngày; đơn
  huỷ phải đi qua dòng hoàn tiền, kéo theo câu *hoàn trừ doanh thu* áp nhầm lên tiền chưa từng là
  doanh thu. Ba dòng không điều kiện đọc được từ ba danh sách từng khoản, không cần so ngày.
- **Tính doanh thu ngày nhận tiền.** Đã bác ở ADR-040 — chủ quán chốt ngược lại.

**Hệ quả:**
- `P2-06` (lát đường tiền) dựng thêm chỗ cất cho `YC-23`; nó **hết** bị F-037 chặn. `P2-11` có
  phép đối chiếu cho ba dòng.
- Kịch bản kiểm của `I-021` có ca trả trước và ca trả nợ bằng tiền mặt.
- **Không** có luật mới cho đơn đã trả trước mà khách **không tới lấy**: khoản ấy nằm ở dòng
  *nhận* hôm nhận tiền và không đi đâu cho tới khi POS đóng hoặc trả lại — công thức vẫn đúng từng
  ngày. Có cần một cảnh báo cho khoản nằm chờ quá lâu không là câu của chủ quán, chưa hỏi.

**Applies to:** `docs/product/1-system-design/architecture.md` §6.4 · §8 · `quality/invariants.md`
`I-014` · `I-021` · `docs/product/1-system-design/03-bao-ve-invariant.md` §1 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §1 ·
`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §4 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §6 · **ADR-040** · **ADR-046**.

### ADR-060 — `I-023` vào nhóm TIỀN, hai vế tầng 1, ba vế tầng 3, một giới hạn tầng 4, và `YC-24`

**Trạng thái:** **Đã chốt** 2026-09-28, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-042** với lời nguyên văn *"hãy đọc kĩ và làm"* — F-042 ghi việc của phiên nhận nó là *thêm
mệnh đề (hoặc nói rõ vì sao không cần) và chốt tầng*, và câu giao việc ấy là lời **giao việc
chọn**, không phải lời xác nhận một nhóm hay một tầng cụ thể (cùng cách đọc với **ADR-056** ·
**ADR-058**). Chủ repo đọc ADR này rồi muốn đổi thì chỉ cần một câu; lượt đổi phải xong trước khi
`T-114` dựng migration. Task **T-113**.

**Context:**
T-097 (2026-09-25) mang bài học của dự án cũ vào pha 2 và tìm ra một chỗ pha 1 chưa nói gì: kênh
`qr_table` gắn lượt gọi vào phiên bàn **theo mã dán ở bàn**, mà không mệnh đề, không hàng bảo vệ,
không dòng yêu cầu nào đòi mã ấy *không đoán được* hay *đổi được*. Nền 16 bảng
(`master_plan/prompt-fullstack.md` §3.5) đã có một mã ngẫu nhiên cho mỗi bàn — nhưng đó là một đề
xuất lược đồ, không phải một mệnh đề, và nó không có đường đổi, không giữ mã đã thay, lượt gọi
không ghi mã đã mang. Chủ quán **chưa** nói gì về mã QR của bàn (`grep` trên
`master_plan/shop-facts.md` 2026-09-28: không một dòng), nên mọi câu về *ai đổi, khi nào đổi* là
câu phải hỏi.

**Decision:**
1. **Mệnh đề `I-023`** ở `quality/invariants.md` — bốn vế: *bàn của lượt gọi do hệ thống tra từ
   mã* · *một mã, một bàn* · *không đoán được* · *đổi được, mã cũ chết ngay*. Mệnh đề **không**
   nói ai đổi, khi nào đổi, và mã sinh bằng gì.
2. **Nhóm TIỀN** (§1 của `docs/product/1-system-design/03-bao-ve-invariant.md`), không mở nhóm
   thứ năm: câu hỏi của `I-023` là *lượt gọi này đứng trên hoá đơn của ai* — cùng loại với `I-002`
   (tổng hoá đơn = mọi lượt gọi của phiên) và `I-013` (con số từ phía khách không bao giờ được
   dùng). Hỏng thì một bàn **trả tiền** cho thứ mình không gọi.
3. **Tầng**: *một mã một bàn* và *lần đổi có vết* — **tầng 1**, điều kiện đọc trên chính các bản
   ghi mã. *Bàn tra từ mã* và *mã cũ chết ngay* — **tầng 3**, ở cùng cửa tạo lượt gọi của `I-008`;
   trần của vế đầu là tầng 3 vì cơ sở dữ liệu không đọc được một số bàn **đến từ đâu**, đúng như
   `I-013`. *Không đoán được* — **tầng 3**, một cửa sinh mã; **chưa có tập đối chiếu** vì mã đoán
   được và mã không đoán được trông giống hệt nhau trong dữ liệu, nói thẳng theo §0 luật 5.
   **Tầng 4, nói thẳng**: người cầm **mã hiện hành** gọi được vào bàn ấy cho tới khi mã được đổi —
   rủi ro có tên `RR-10` ở `docs/product/1-system-design/06-so-rui-ro.md`.
4. **Mã cũ chết ngay lúc đổi là SUY RA**, không phải lời chủ quán: đổi mã chỉ có nghĩa nếu mã cũ
   hết dùng được, và quán không mất đường bán nào lúc tem mới chưa dán — khách gọi qua quầy đặt hộ
   (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.2).
5. **`U-062`** cho *ai được đổi mã, và quán đổi khi nào* — câu của chủ quán, không phải của pha 1.
   *(Đóng 2026-09-28, T-118: chủ quán đổi, khi quán bị hack — `master_plan/shop-facts.md` §6 quy
   tắc 2.)*
6. **`architecture.md` §8 thêm một dòng** và `04-yeu-cau-du-lieu.md` §1 thêm **`YC-24`** (luật
   một-đối-một của P1-07).

**Rejected alternatives:**
- **Gấp vào `I-013`** (giá do hệ thống tính lại). Cùng hình *không tin dữ liệu từ phía khách*,
  nhưng `I-013` nói **giá**; gấp vào thì phải viết lại lời của nó, và vế *đổi được* không có chỗ.
- **Gấp vào `I-001`** hay nhóm VÒNG ĐỜI. `I-001` nói *một bàn một phiên* — đổi mã đúng là không
  được chạm tới câu ấy, nhưng câu hỏi của `I-023` là tiền đứng sai hoá đơn, không phải bàn kẹt.
- **Nói rõ vì sao không cần mệnh đề** — lối thứ hai F-042 cho phép. Không chọn: quầy duyệt theo số
  bàn trên đơn, không biết ai cầm điện thoại, nên lớp người đang có không phủ ca *đơn chen vào một
  bàn đang có khách*.
- **Tầng 1 cho *mã cũ chết ngay*.** Điều kiện ấy so mốc tạo lượt gọi với mốc thay mã của một bản
  ghi khác — viết được thành ràng buộc, nhưng chọn cơ chế là việc pha 2; pha 1 ghi tầng **cao nhất
  thật sự đang giữ** (§0 luật 1), và cửa tạo lượt gọi là chỗ đã có. Pha 2 dựng cao hơn được thì
  tốt, không được dựng thấp hơn (**ADR-050** luật 1).

**Hệ quả:**
- `T-114` dựng một migration **mới** (`QC-05`) cho chỗ cất mã hiện hành, mã đã thay, vết đổi mã và
  mã đã mang của lượt gọi, kèm ràng buộc tầng 1 và test theo kịch bản của `I-023`; `P2-10` sinh mã
  cho dữ liệu mồi qua đúng một cửa sinh mã ấy.
- Cổng pha 2 (`P2-13`) chấm `YC-24` cùng các dòng khác.
- Quyền theo vai của thao tác đổi mã (pha 3) ~~chờ `U-062`~~ — `U-062` đóng 2026-09-28 (T-118):
  chỉ vai **chủ quán** được đổi mã.

**Applies to:** `quality/invariants.md` `I-023` ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §1 ·
`docs/product/1-system-design/architecture.md` §8 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §1 ·
`docs/product/1-system-design/06-so-rui-ro.md` RR-10 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §6 · §7 ·
`docs/product/99-unknowns.md` U-062 ·
`docs/product/2-db/02-luoc-do-ban-hang.md` §5.

### ADR-061 — `I-024` vào nhóm TIỀN, đồng nhất lần gửi bằng dấu chứ không bằng nội dung, hai vế tầng 1, ba vế tầng 3, và `YC-25`

**Trạng thái:** **Đã chốt** 2026-09-28, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-043** với lời nguyên văn *"hãy đoc kĩ và làm"* — F-043 ghi việc của phiên nhận nó là *thêm
mệnh đề và chốt tầng*, và câu giao việc ấy là lời **giao việc chọn**, không phải lời xác nhận một
nhóm hay một tầng cụ thể (cùng cách đọc với **ADR-058** · **ADR-060**). Chủ repo đọc ADR này rồi
muốn đổi thì chỉ cần một câu; lượt đổi phải xong trước khi `T-116` dựng migration. Task **T-115**.

**Context:**
T-097 (2026-09-25) mang bài học của dự án cũ vào pha 2 và tìm ra một chỗ pha 1 chưa nói gì: khách
bấm gửi hai lần, hay mạng chập chờn khiến máy gửi lại, thì hệ thống phải ghi **một** đơn — mà không
mệnh đề, không hàng bảo vệ, không dòng yêu cầu nào giữ vế ấy. Mọi chỗ nói *"hai lần"* ở pha 1 đều
nói về **tiền đếm hai lần**, không chỗ nào nói về **đơn tạo hai lần**. Lát bán hàng lõi (`P2-04`)
dựng xong không có khoá chống trùng nào và ghi đúng chỗ ấy thành *chỗ trống có tên*. Chủ quán
**chưa** nói gì về đơn trùng, và lượt này không cần hỏi: luật nguồn — mỗi đơn mang đi là một đơn vị
thanh toán (`I-007`), mỗi lượt gọi cộng vào hoá đơn phiên (`I-002`), khách gọi thêm là một lượt gọi
thật (`master_plan/shop-facts.md` §5.1), hai kênh của người quán nhập không qua duyệt (§6 quy tắc 2)
— đã đủ để viết mệnh đề.

**Decision:**
1. **Mệnh đề `I-024`** ở `quality/invariants.md` — năm vế: *một lần gửi, nhiều nhất một đơn* ·
   *mọi đơn đọc ra được lần gửi của nó* · *lần gửi lại nhận lại đúng đơn đã sinh* · *cùng dấu khác
   nội dung bị từ chối* · *nội dung giống hệt không phải là trùng*. Áp cho **cả năm** kênh, kể cả
   lượt gọi vào phiên bàn. Mệnh đề **không** nói dấu sinh bằng gì, cất ở đâu.
2. **Đồng nhất lần gửi bằng DẤU, không bằng nội dung.** Một lần gửi mang một dấu do phía gửi đặt
   **một lần**, lúc người bấm gửi, và giữ nguyên trên mọi lần gửi lại. Đây là lựa chọn quan trọng
   nhất của ADR này: so nội dung để đoán trùng thì **bỏ** một lượt gọi thêm có thật — thu thiếu —
   nên cách chữa ấy sinh ra đúng loại hỏng mà mệnh đề chống.
3. **Nhóm TIỀN** (§1 của `docs/product/1-system-design/03-bao-ve-invariant.md`), không mở nhóm
   thứ năm: câu hỏi của `I-024` là *một đơn vị tính tiền đếm một lần gửi bao nhiêu lần* — cùng loại
   với `I-002` (hoá đơn = mọi lượt gọi của phiên) và `I-007` (mỗi đơn mang đi một đơn vị thanh
   toán). Hỏng thì khách **trả tiền hai lần** cho một lần gọi.
4. **Tầng**: *một dấu một đơn* — **tầng 1**, không có hạn thời gian; *kiểm rồi mới ghi* ở tầng 3 thua
   đúng ca hai lần gửi lại tới gần như cùng lúc. *Không đơn nào thiếu dấu* — **tầng 1**, vì đơn không
   dấu là đường lách vế trên. *Gửi lại nhận lại đúng đơn*, *cùng dấu khác nội dung bị từ chối* và
   *giống hệt không phải là trùng* — **tầng 3**, ở cùng cửa tạo đơn của `I-008`; cửa ấy tra dấu
   **trước** mọi điều kiện của `I-008`, vì lần gửi lại không tạo đơn mới. **Tầng 4, nói thẳng**: hai
   ý định của người cho cùng một mong muốn là hai lần gửi thật, máy không phân biệt được — rủi ro
   có tên `RR-11` ở `docs/product/1-system-design/06-so-rui-ro.md`, nặng nhất ở hai kênh không qua
   duyệt.
5. **Hai vế là SUY RA**, không phải lời chủ quán: *lần gửi lại nhận lại đúng đơn* (một lời từ chối
   khiến khách đặt lại từ đầu, tức một lần gửi **mới** không vế nào chặn được) và *cùng dấu khác nội
   dung bị từ chối* (không thế thì gửi lại thành một đường sửa đơn không để vết của `I-018`).
6. **Không mở `U-XXX` nào.** Không vế nào đòi một dữ kiện quán chưa có; nếu chủ quán muốn quầy
   được **gộp** hai đơn giống nhau thay vì huỷ một, đó là một luật mới và mở `U-XXX` lúc ấy.
7. **`architecture.md` §8 thêm một dòng** và `04-yeu-cau-du-lieu.md` §1 thêm **`YC-25`** (luật
   một-đối-một của P1-07).

**Rejected alternatives:**
- **Đồng nhất bằng nội dung** (cùng món, cùng bàn hay cùng số điện thoại trong vài phút là trùng).
  Bỏ lượt gọi thêm có thật và đơn thứ hai có thật của cùng một khách — kịch bản đếm của `I-007` đã
  nói hai đơn tới lấy cách nhau mười phút là **hai** đơn. Và nó cần một ngưỡng *vài phút* — một dữ
  kiện quán không ai chốt.
- **Gấp vào `I-007`** hay `I-002`. Cùng câu hỏi về tiền, nhưng `I-007` nói **ranh giới** giữa hai
  loại đơn vị tính tiền và `I-002` nói **hoá đơn cộng từ gì**; câu *bao nhiêu đơn sinh từ một lần
  gửi* áp cho cả năm kênh, và gấp vào một trong hai thì bỏ sót nửa kia.
- **Nhóm VÒNG ĐỜI**, cạnh `I-022` (điều kiện để một đơn tồn tại). Cũng đọc được, nhưng nhóm ấy là
  nhóm **bàn kẹt, đơn kẹt**; đơn trùng không kẹt gì — nó chạy trơn tru tới tận lúc thu tiền hai lần.
- **Tầng 3 cho *một dấu một đơn*** — một cửa tạo đơn kiểm dấu rồi mới ghi. Thua khi hai lần gửi lại
  tới gần như cùng lúc (`work/proposals/from_old_project/data_base/nghien-cuu.md` §3.1, bằng chứng
  dự án cũ); pha 1 ghi tầng **cao nhất thật sự giữ được** (§0 luật 1), và điều kiện này đọc được trên
  chính các đơn, không đổi theo thời gian.
- **Một hạn thời gian cho dấu** (dấu chỉ duy nhất trong vài giờ). Cần một con số không ai chốt, và
  một dấu dùng lại sau hạn thì một lần gửi lại tới muộn thành đơn mới — đúng ca mệnh đề chống.

**Hệ quả:**
- `T-116` dựng một migration **mới** (`QC-05`) cho chỗ cất dấu lần gửi trên đơn và lượt gọi, kèm
  ràng buộc tầng 1 và test theo kịch bản của `I-024`; file của `P2-04` không sửa.
- Cổng pha 2 (`P2-13`) chấm `YC-25` cùng các dòng khác.
- Pha 3 dựng cửa tạo đơn tra dấu trước điều kiện của `I-008`; pha 4 dựng **một chỗ sinh dấu** ở phía
  gửi, đặt dấu lúc bấm và giữ nguyên qua mọi lần gửi lại.

**Applies to:** `quality/invariants.md` `I-024` ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §1 ·
`docs/product/1-system-design/architecture.md` §8 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §1 ·
`docs/product/1-system-design/06-so-rui-ro.md` RR-11 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §6 · §7 ·
`docs/product/2-db/02-luoc-do-ban-hang.md` §5.

### ADR-062 — Gate 8 chặn thêm một thứ: subject trùng từng chữ một commit đã có trong lịch sử

**Trạng thái:** **Đã chốt** 2026-09-28, **giao cho phiên**. Chủ repo giao `work/findings.md`
**F-031** với lời nguyên văn *"hãy đoc kĩ và làm"*. F-031 ghi rằng dựng cơ chế cho lỗi này *"là
quyết định của chủ repo"*; câu giao việc ấy là lời **giao việc chọn** (cùng cách đọc với
**ADR-058** · **ADR-060** · **ADR-061**), không phải lời xác nhận một luật cụ thể. Chủ repo đọc
ADR này rồi muốn đổi thì chỉ cần một câu. Task **T-117**. Sửa đổi **ADR-010** ở đúng vế *"chỉ chặn
cái rỗng nghĩa"*; mọi giới hạn khác của ADR-010 giữ nguyên.

**Context:**
`git log --format='%s' | sort | uniq -cd` (chạy lại 2026-09-28) vẫn cho đúng **năm** nhóm subject
bị dùng lại, không nhóm nào mới kể từ lần đo 2026-09-07 — bảng ở F-031. Ở mỗi nhóm nhiều nhất một
commit nói đúng về chính nó. Bốn trong năm nhóm là commit **sát nhau**, cách vài phút (`1b1d5f5` →
`0b3a337` 5 phút, `3f579f9` → `30abf8f` 11 phút, `b296268` → `510f092` 8 phút): message của commit
vừa làm bị chép lại. Gate 7 không đứng ở cửa terminal; Gate 8 đứng ở mọi cửa nhưng chỉ hỏi subject
có rỗng nghĩa không, nên cả năm nhóm đều lọt. `CLAUDE.md` §3.8 đòi hai lần để thêm luật — dạng lỗi
này có năm.

**Decision:**
1. `scripts/hooks/commit-msg` từ chối commit khi subject — sau khi cắt khoảng trắng hai đầu — **trùng
   từng chữ** subject của một commit **đi tới được từ `HEAD`**. So nguyên chuỗi, kể cả tiền tố
   `T-XXX:`; cùng mã task khác mô tả thì qua.
2. **`HEAD` cũng bị so**, vì đó là ca phổ biến nhất. Ngoại lệ duy nhất: `git commit --amend`. Khi
   amend, commit mới **thay** `HEAD` chứ không đứng cạnh nó, nên hook so với lịch sử **trước**
   `HEAD` — giữ nguyên subject thì qua, amend thành subject của một commit cũ hơn vẫn bị chặn.
   Git không báo amend cho hook, nên hook đọc dòng lệnh của tiến trình cha (và ông, nếu git chạy
   hook qua shell) để tìm `--amend`.
3. Những gì ADR-010 đã miễn vẫn miễn: `Merge …`, `Revert …`, `fixup!`, `squash!`, `amend!`. Repo
   chưa có commit nào, hay hook chạy ngoài repo git ⇒ không chặn.
4. Lời từ chối nêu **hash và ngày** của commit đã dùng subject ấy, F-031, và hai đường ra:
   `git commit --amend` (nếu đang định sửa commit vừa làm) và `git commit --no-verify`.
5. **Không sửa lịch sử** (ADR-008): năm nhóm cũ vẫn nằm nguyên; luật chỉ chặn nhóm thứ sáu.

**Rejected alternatives:**
- **Chỉ nhắc, không chặn.** Nhắc thì chạy ở terminal lúc người ta đang vội — đúng lúc năm nhóm kia
  ra đời. Khác với subject > 72 ký tự (vẫn nói được nó là gì), một subject trùng **nói sai** về
  commit của nó, nên chặn không phải *đỏ vì lý do sai* (ADR-003).
- **Bỏ `HEAD` khỏi phép so** để khỏi phải nhận ra amend. Đơn giản hơn, nhưng bỏ đúng bốn trong năm
  nhóm đã xảy ra.
- **So cả thân commit, hoặc so gần đúng** (khác vài chữ vẫn là trùng). So gần đúng sẽ chặn hai
  commit thật cùng task viết gần giống nhau — đỏ vì lý do sai; còn so thân thì không thêm gì: nhóm
  nào trùng thân cũng đã trùng subject.
- **Chỉ so với N commit gần nhất.** Nhóm 3 có một commit cách hai commit kia bảy tiếng; một con số N
  là một ngưỡng không ai chốt, còn so cả lịch sử của repo cỡ này tốn không đáng kể.
- **Đặt luật vào Gate 7b** (đọc khối commit của phiên). Gate 7b không đứng ở cửa terminal — đúng lỗ
  hổng ADR-010 đã nêu.

**Rủi ro đã chấp nhận:**
- **Nhận ra amend dựa vào `ps`.** Nếu `ps` không đọc được tiến trình cha, hook coi như không amend
  và một lần amend giữ nguyên subject sẽ bị chặn — đỏ vì lý do sai, nhưng lời từ chối in sẵn
  `--no-verify`. `scripts/commit-msg.test.sh` chấm cả hai ca amend bằng commit thật, nên nếu cách
  nhận ra này hỏng trên máy nào thì test đỏ trên máy ấy.
- **Chép subject rồi sửa một chữ vẫn qua.** Luật chặn *chép nguyên*, không chấm *đúng sai* — việc
  ấy vẫn là của Gate 7b và người đọc diff (giới hạn ADR-010 đã nhận).
- **`--no-verify` vẫn đi qua** và **hook vẫn phải cài mỗi bản clone** — hai giới hạn của ADR-010,
  không đổi.

**Applies to:** `scripts/hooks/commit-msg` · `scripts/commit-msg.test.sh` · `CLAUDE.md` §6.2 ·
`quality/review-gate.md` Gate 8 · `docs/work-flow-session/workflow-phien-lam-viec.md` ·
`work/findings.md` F-031.

### ADR-063 — Mỗi task một file scope, và Gate 7b chấm theo task trong subject

**Trạng thái:** Đã chốt 2026-09-27. Chủ repo: *"hãy mỗi 1 task tự tạo file scope riêng để không
bị xoá"*, rồi *"hãy làm theo đề xuất trên"* cho thiết kế Claude đề xuất trong cùng phiên (T-085).

**Context:** mọi phiên dùng chung một `work/scope.txt`. Ba lỗi cùng một gốc: một phiên gỡ hay
khôi phục file này là xoá scope của phiên khác (F-010, F-014 — lần mới nhất ngay 2026-09-27, khi
Gate 3 đỏ giữa chừng vì scope bị gỡ sạch); file bị git theo dõi nên pattern lọt vào commit ba lần
(F-020, ADR-043); và luật "gỡ scope lúc Done" làm Gate 7b mất thước đo đúng lúc giao khối commit
(T-085).

**Decision:**

1. Scope khai ở `work/scope/<MÃ-TASK>.txt`, một file mỗi task. `work/scope/.gitignore` bỏ qua mọi
   thứ trong thư mục trừ chính nó, nên file scope không vào commit bằng `git add` thường và
   không bị `git checkout --` hay `git stash` xoá.
2. Gate 3: một file đổi hợp lệ khi có ít nhất một file scope cho phép nó và chính file ấy không
   cấm nó. Gate 3 FAIL khi `work/scope.txt` còn pattern, và khi một file scope bị git theo dõi.
3. Gate 7b: mã đứng đầu subject của mỗi `git commit -m "<MÃ>: …"` trong turn chọn file scope để
   chấm; không mã nào có file ⇒ chấm theo hợp mọi file scope. File scope trong khối ⇒ kêu.
4. File scope giữ qua *Done* tới khi task đã commit, rồi mới xoá. Brief liệt kê từng file scope và
   cảnh báo file nào có mã không nằm ở *In Progress*.
5. `work/scope.txt` ở lại thành stub chỉ-comment để các tài liệu lịch sử nhắc tới nó vẫn mở được.

**Rejected alternatives:** giữ file chung và cho 7b đọc mục *Phạm vi* của hồ sơ task vừa Done —
phải phân tích văn xuôi markdown, và không chữa được lỗi phiên này xoá scope của phiên kia. Chấp
nhận mất lớp 7b — bỏ đúng lớp đã bắt F-009. Chỉ dùng worktree riêng cho mỗi phiên — đúng hướng
(CLAUDE.md §7.4) nhưng không cưỡng chế được, còn file scope riêng thì không tốn gì.

**Hệ quả:** hai phiên chung một cây không còn ghi đè scope của nhau, và phép baseline HEAD của
ADR-043 được thay bằng `.gitignore`. Giới hạn còn lại: Gate 3 dùng hợp các scope, vì git không
biết phiên nào sửa file nào — hai phiên cùng sửa một file vẫn không tách được; muốn tách hẳn thì
dùng worktree riêng. Một file scope bị bỏ quên sau commit chỉ nới Gate 3, không chặn ai; brief
nêu đích danh nó.

**Applies to:** `scripts/check-scope.sh` · `scripts/check-commit-block.sh` · `scripts/brief.sh` và
test của chúng · `work/scope/.gitignore` · `work/scope.txt` · `CLAUDE.md` §2 · §3 · §5 · §6 · §7 ·
§8 · `AGENTS.md` · `docs/prompt-guideline.md` §6 · `quality/review-gate.md`.

---

### ADR-064 — `CLAUDE.md` chỉ giữ luật và con trỏ; cơ chế ở header script, lý do ở ADR

**Trạng thái:** Đã chốt 2026-09-29 — giao cho phiên. Hướng *"rút về luật đang có; giải thích cơ chế
về header script và ADR"* là lời của dòng T-087, mở từ đề xuất tinh gọn chủ repo đồng ý 2026-09-25
(ADR-051 *Hệ quả*); chủ repo giao làm 2026-09-29 (*"hãy đọc kĩ và hoàn thành task trên"*). Cách
chia từng đoạn dưới đây là của phiên (Claude Code), chưa review độc lập.

**Context:** đo 2026-09-29, `CLAUDE.md` dài 607 dòng và nạp vào mọi phiên Claude Code lẫn Codex.
Phần dày nhất kể lại **cách cổng chạy** — §5 (84 dòng), §6.2 (32), §7.1 (43) — trong khi header của
`scripts/check-*.sh`, `scripts/brief.sh`, `scripts/hooks/commit-msg` đã giữ đúng những đoạn ấy.
Hai bản, và một bản đã trôi: §5 nói Gate 1d chỉ soát `docs/product/1-system-design/`, header nói
hai vùng (thêm `docs/product/2-db/` từ P2-02). `scripts/verify.sh` không có header nào, nên cơ chế
Gate 1 chỉ sống ở `CLAUDE.md`. Số mục của file được trỏ từ khắp repo (đếm cùng ngày: §2 hơn 240
lần, §3.5 hơn 110, §7.2 khoảng 80, §3.8 khoảng 75) nên không đổi được.

**Decision:**

1. `CLAUDE.md` giữ **luật** (phải làm gì, cấm gì, ai quyết) và **con trỏ** (owner nào giữ phần
   còn lại). **Cách một cổng chạy** thuộc header script của nó; **vì sao có luật** thuộc ADR hay
   finding mà luật trỏ tới.
2. Số mục §1…§8, ý 1…8 của §3, §6.1 · §6.2 · §7.1…§7.4 giữ nguyên số và nghĩa.
3. Bảng §2 giữ đủ hàng; mọi luật do chủ repo chốt bằng lời (ngôn ngữ trả lời · giải thích ngắn
   trước — T-105; chia vai Claude · Codex — ADR-054) giữ đủ ý, chỉ viết gọn câu.
4. Không đặt ngân sách dòng cứng: một con số không cổng nào đo là thêm một luật *tự giác*
   (§3). Ai thêm một đoạn cơ chế vào `CLAUDE.md` thì chuyển nó vào header ở lượt thấy nó.

**Luật đã đi đâu** (đối chiếu bản 607 dòng, commit `24d84ff`):

| Đoạn cũ | Giờ ở đâu |
|---|---|
| §5 bước 1–4, 6: điều kiện đỏ, ignore có hạn, đọc theo khối, luật Gate 7b | header `scripts/check-scope.sh` · `check-links.sh` · `check-doc-status.sh` · `check-phase-boundary.sh` · `check-commit-block.sh`; `CLAUDE.md` §5 giữ một dòng mỗi cổng + luật hành động (file chưa track của task mình, Codex tự kiểm khối commit, nhãn PASS/FAIL/SKIP/NOTE) |
| §5 bước 5: Gate 1 chạy gì, khi nào gọi `db-check.sh` | header **mới** của `scripts/verify.sh` |
| §6.2: luật chặn subject, lý do, lệnh cài | header `scripts/hooks/commit-msg`, ADR-010 · ADR-062; `CLAUDE.md` §6.2 giữ luật tóm tắt, đường thoát, lệnh cài |
| §7.1: ngưỡng cắt sáu/mười hai, các lúc hook chạy | header `scripts/brief.sh`; `CLAUDE.md` §7.1 giữ bốn luật đọc brief |
| §4: hợp đồng hình dạng câu hỏi mở | `docs/product/99-unknowns.md` → *Cách viết một câu ở đây* |
| §2: ngày mở `docs/product/2-db/`, lịch sử đổi hàng | ADR-035 · `work/backlog_DB.md`; câu *"chờ chủ repo xác nhận"* của kế hoạch pha 2 §5 giữ thành một con trỏ |
| §2: cây thư mục | bảng §2 và danh sách cổng ở §5 đã nêu đủ file; bỏ |
| §7.3: bốn gạch trùng checklist §8 | §8; §7.3 giữ luật link tới dòng của câu hỏi mở |

**Rejected alternatives:**

- *Rút về khoảng 120 dòng như đề xuất `work/proposals/updatee_sýstem.md`.* Bác: riêng bảng §2 và
  §8 đã gần 60 dòng, luật chia vai và luật ngôn ngữ là lời chủ repo — xuống 120 dòng phải bỏ luật,
  không chỉ bỏ cơ chế.
- *Tách `CLAUDE.md` thành nhiều file nạp theo nhu cầu.* Bác: luật phiên nào cũng cần thì phải nạp
  mọi phiên; file tách ra là file phiên không mở (§7.1 ra đời vì đúng lý do ấy).
- *Đánh số lại mục cho gọn.* Bác: hàng trăm con trỏ `CLAUDE.md §x` trong repo sẽ trỏ sai.

**Hệ quả:** `CLAUDE.md` từ 607 còn khoảng 410 dòng. Ngưỡng ≤ 300 phiên tự đặt ở Acceptance của
T-087 **không đạt**: đọc lại từng đoạn, phần còn lại là luật, và cắt tiếp là bỏ luật. Một phiên cần
biết *vì sao* một cổng đỏ phải mở header script — đổi lại, chỉ còn một bản của mỗi cơ chế. Quyết
định còn treo của T-119 (áp khuôn *một entry, trạng thái một nơi* cho lane admin và task `T-XXX`)
không đòi viết lại file này: `CLAUDE.md` trỏ về *Task Detail Template* của `work/backlog.md`, không
mô tả khuôn entry.

**Applies to:** `CLAUDE.md` · `scripts/verify.sh` (header) · `scripts/gate.sh` (header, con trỏ
`§2.2` cũ → §2).

---

### ADR-065 — Mỗi bước migration một bước lùi, và bước lùi chỉ gỡ chỗ còn rỗng

**Trạng thái:** **Đã chốt** 2026-09-29, **giao cho phiên**. Chủ repo giao `P2-09` với lời *"hãy
đọc kĩ và làm task trên"*; entry ấy đòi *mỗi bước có đường đi và đường lùi chạy thật được*, nhưng
không chọn cơ chế. Câu giao việc là lời **giao việc chọn**, không phải lời xác nhận cơ chế dưới
đây (`CLAUDE.md` §7.2, cùng cách đọc với **ADR-058**). Chủ repo muốn đổi thì một câu là đủ; lượt đổi
phải xong trước khi một bước migration nào chạy trên dữ liệu thật. Task **P2-09**.

**Context:**
`docs/product/2-db/10-quy-uoc-code.md` `QC-05` (phiên chọn 2026-09-27, `P2-12`) cấm file `.down.sql`,
với lý do đúng: *một file lùi của một lát lược đồ là một lệnh xoá bảng nằm sẵn cạnh dữ liệu bán
hàng thật* — đường mà `QD-50` đóng. Kế hoạch pha 2 §3 · §6 và entry `P2-09` lại đòi *mỗi migration
phải có đường lùi chạy thật được*, chứng minh bằng *chạy lùi một bước rồi xuôi lại ⇒ xanh*. Hai câu
cùng đúng về hai nỗi sợ khác nhau: một bước xuôi **sai về nghĩa** không có đường về, và một bước lùi
**xoá dữ liệu**. Thí nghiệm 2026-09-29 (database riêng) cho thêm một dữ kiện: bước xuôi **hỏng
giữa chừng** không cần file lùi — cả file là một giao dịch, nên lược đồ không đứng ở nửa bước; công
cụ chỉ đánh dấu *dirty* và chờ `force`.

**Decision:**
1. **Mỗi `.up.sql` có đúng một `.down.sql`**, gỡ đúng thứ bước xuôi dựng. *Đúng* đo bằng ảnh chụp
   `pg_dump --schema-only`: lược đồ sau khi lùi bước *N* giống từng dòng lược đồ trước khi xuôi bước
   *N*.
2. **Khoá chặn ở đầu mọi file lùi:** bảng sắp gỡ có dòng, hay cột ghi sắp gỡ có giá trị ⇒ `RAISE`,
   không gỡ gì. Nỗi sợ của `QC-05` cũ được giữ bằng khoá này thay vì bằng lệnh cấm.
3. **Lùi trên dữ liệu đã ghi là một migration mới đi tới** — luật *sửa lược đồ đã commit là một
   migration mới* của `QC-05` giữ nguyên.
4. **Bộ kiểm chứng minh ở mỗi lần chạy:** `scripts/db-check.sh` xuôi từng bước từ số không, lùi từng
   bước về số không (so ảnh chụp), xuôi lại cả dãy; rồi trên dữ liệu mồi, lùi một bước phải bị khoá
   chặn từ chối và `force` gỡ được dấu *dirty*.
5. **Phép so tên bảng của ADR-053 luật 2 thành Gate 1e** (`scripts/check-schema-names.sh`) trong
   `./scripts/gate.sh`, chạy mọi lượt vì chỉ đọc file; in hai danh sách đầy đủ trước `comm -3`
   (**F-017**).

**Rejected alternatives:**
- *Giữ luật chỉ đi tới; "đường lùi" = giao dịch + `force`.* Bác: chỉ phủ bước **hỏng giữa chừng**;
  bước chạy xong mà sai về nghĩa vẫn không có đường về, và đầu ra *lùi một bước rồi xuôi lại* của kế
  hoạch không chạy được.
- *File lùi không khoá chặn, chỉ dặn "đừng chạy trên máy thật".* Bác: đúng hình *luật không có lệnh
  gác thì tự trôi* (**ADR-053**); một lệnh gõ nhầm máy là mất dữ liệu bán hàng.
- *File lùi đặt ngoài `db/migrations/` (chỉ bộ kiểm dùng).* Bác: công cụ không thấy nó, nên đường lùi
  ở máy thật vẫn không có; hai bộ file cho một dãy là bản thứ hai (**F-001**).
- *Khoá chặn chỉ đếm dòng của bảng, kể cả với cột thêm vào bảng cũ.* Bác: một cột **có thể trống**
  chưa ai ghi vào thì gỡ không mất gì — đếm dòng của cả bảng sẽ chặn cả trường hợp ấy.

**Hệ quả:** `db-check` chậm thêm khoảng 17 giây (14 → 32 giây trên máy phát triển, 2026-09-29) vì mỗi
bước một lần gọi công cụ. Đường lùi thật sự dùng được ở máy thật chỉ trong khoảng ngắn sau khi triển
khai một bước, trước khi chỗ mới có dữ liệu; sau đó chỉ còn đường đi tới. Một lệnh lùi bị khoá chặn
để lại dấu *dirty* ở số của bước **dưới**, trong khi lược đồ vẫn ở bước trên —
`07-thu-tu-migration.md` §3 nói phải `force` về số nào. Không gì ở đây chạm **YC-21** (**ADR-057**):
đường lùi của lược đồ không phục hồi dữ liệu.

**Applies to:** `db/migrations/*.down.sql` · `compose.yaml` (service `migrate`) · `scripts/db-check.sh`
· `scripts/check-schema-names.sh` + test · `scripts/gate.sh` + test · `docs/product/2-db/10-quy-uoc-code.md`
`QC-05` · `docs/product/2-db/07-thu-tu-migration.md` · `CLAUDE.md` §2 · §5.

### ADR-066 — Bộ đối chiếu: một câu một TẬP, một lệnh sau khi đóng quán, chứng minh bằng ngày mẫu và lỗi cài

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên**. Chủ repo giao `P2-11` với lời *"hãy đọc
kĩ và làm"*; entry đòi *mỗi phép đối chiếu thành đúng một câu, gom thành một lệnh, chứng minh biết
kêu*, nhưng không chọn hình dạng. Câu giao việc là lời **giao việc chọn**, không phải lời xác nhận
các lựa chọn dưới đây (`CLAUDE.md` §7.2, cùng cách đọc với **ADR-065**). Task **P2-11**.

**Context:**
Cột phải của `docs/product/1-system-design/03-bao-ve-invariant.md` viết mỗi phép đối chiếu bằng lời,
và một ô chứa tới chín tập *"phải rỗng"* (`§0` luật 5: đơn vị là **vế**, không phải mã). Hai mươi tư
mã, chín mươi hai tập (đếm 2026-09-30). Một câu cho mỗi **mã** sẽ là một phép `UNION` chín nhánh:
khi nó kêu, không đọc ra tập nào hỏng, và một lỗi cài không chứng minh được nhánh nào biết kêu. Dữ
liệu mồi (`P2-10`) không có đơn nào, nên *"cả bộ trên dữ liệu mồi ⇒ 0 dòng"* đúng cả với một câu
kêu oan ở mọi đơn thật.

**Decision:**
1. **Đơn vị là TẬP.** Mỗi tập là một câu mang mã `I-0xx/n`, `n` là thứ tự của tập trong ô pha 1. Câu ở
   `db/reconcile/`, một file một mệnh đề; tập không có câu có một dòng ở
   `docs/product/2-db/09-doi-chieu-bat-bien.md` §2 với lý do và người nợ. Phép `comm -3` của kế hoạch
   so **mã** (`I-0xx`), như kế hoạch nói.
2. **Một lệnh, hai nhóm:** `scripts/reconcile.sh` chạy nhóm `I-0xx/n` và nhóm quy ước `QD-XX` trong
   một phiên kết nối chỉ đọc. Khối `sql` dưới `### QD-XX` của `01-quy-uoc-du-lieu.md` đọc thẳng từ
   tài liệu; bốn phép *dạng lệnh* của `db-check.sh` (`QD-02` · `QD-31(b)` · `QD-32` · `QD-40(b)`)
   viết lại thành câu SQL ở `db/reconcile/qd.sql`, đọc danh sách từ owner qua bảng tạm lúc chạy, để cả
   nhóm quy ước cũng chạy được trên database làm việc và cũng chứng minh được biết kêu trong một giao
   dịch. `db-check.sh` bước 1 thôi chạy khối `QD` (một phép, một chỗ chạy).
3. **Chứng minh ở mỗi lần `db-check`:** (a) lệnh trên dữ liệu mồi ⇒ 0 dòng; (b) một **ngày bán mẫu
   đúng** (`db/reconcile/proof/baseline.sql`) ⇒ 0 dòng ở mọi câu — chống kêu oan; (c) mỗi file lỗi
   cài **một** chỗ sai vào dữ liệu hay lược đồ (gỡ ràng buộc trước nếu tầng 1 giữ), trạng thái sau lỗi
   qua `SET CONSTRAINTS ALL IMMEDIATE`, và tập câu kêu **bằng đúng** tập khai ở dòng `-- kêu:` —
   chống câu điếc và câu kêu lan; (d) mỗi câu là mã đầu của ít nhất một file lỗi.
4. **Không viết câu cho tập không có phần tử nào tồn tại được trong lược đồ** — một câu không cài lỗi
   nào làm kêu được là một câu không bao giờ được chấm (kế hoạch pha 2 §7 luật 3). Tập ấy ghi *(B)* ở
   file 09 §2.

**Rejected alternatives:**
- *Một câu một mã, `UNION` các tập.* Bác: lý do ở *Context*; và một lỗi cài chỉ chứng minh **một**
  nhánh.
- *Chứng minh bằng cách cài lỗi riêng từng câu trên database rỗng.* Bác: không chứng minh câu không kêu
  oan trên một ngày đúng — lỗi đắt nhất của một ngưỡng 0đ (`I-021` mục *Why*).
- *Chấp nhận "câu đích kêu" thay vì "đúng tập khai kêu".* Bác: một câu kêu lan ở lỗi của mệnh đề khác
  là một câu mà chủ quán không đọc ra chỗ hỏng. Khi một lỗi thật làm kêu nhiều câu (gỡ ràng buộc kiểm
  thì `QD-21` kêu cùng), file lỗi khai đủ và nói vì sao.
- *Giữ bốn phép `QD` dạng lệnh ở `db-check.sh`.* Bác: chúng không chạy được trên database làm việc, và
  không chứng minh được biết kêu mà không `COMMIT` một lỗi vào database của bộ kiểm.

**Hệ quả:** `db-check` thêm khoảng nửa phút (85 câu × 86 lần trong một giao dịch). Hai mươi chín tập
chưa có câu — phần lớn vì dữ liệu tập cần chưa có chỗ cất (số tiền mặt đếm được, tin nhắn báo có, dấu
đã đối soát, khoảng tạm dừng, lần từ chối): đó là danh sách việc của pha 3 và của một quyết định của
chủ repo (`04-luoc-do-duong-tien.md` §5), không phải bộ đã đủ. Lệnh đọc **toàn bộ lịch sử**: một chỗ
sai cũ kêu mỗi tối tới khi được sửa có vết.

**Applies to:** `db/reconcile/` · `scripts/reconcile.sh` · `scripts/db-check.sh` ·
`docs/product/2-db/09-doi-chieu-bat-bien.md` · `docs/product/2-db/01-quy-uoc-du-lieu.md` §0 ·
`docs/product/2-db/10-quy-uoc-code.md` `QC-07` · `QC-08`.

### ADR-067 — Cổng pha 2 ký bằng một bước chạy lại được: ba scenario COMMIT thật, đọc lại ở kết nối khác, chấm YC năm kết cục

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên**. Chủ repo giao `P2-13` với lời *"hãy đọc
kĩ và làm"*; entry đòi *mỗi bước của ba scenario ghi/đọc được bằng dữ liệu thật, mỗi dòng YC hai câu,
mỗi ô cổng một output thật*, nhưng không chọn hình dạng. Câu giao việc là lời giao việc chọn, không
phải lời xác nhận các lựa chọn dưới đây (`CLAUDE.md` §7.2, cùng cách đọc với **ADR-065** · **ADR-066**).
Task **P2-13**.

**Context:**
Cổng pha 1 được ký bằng một lượt đọc: mỗi bước scenario trỏ vào một mục thiết kế
(`docs/product/1-system-design/07-cong-chat-luong-pha-1.md`). Pha 2 có thứ pha 1 không có — một
database chạy được — nên *"ghi được, đọc lại được"* chứng minh được bằng lệnh. Ba cách chấm sai dễ
nhất: diễn trong một giao dịch rồi ROLLBACK (ràng buộc hoãn chỉ được chấm một lần ở cuối, không phải ở
mỗi bước như cửa ghi thật); đọc lại trong cùng phiên đã ghi (bảng tạm và hàm tạm của lúc ghi che mất
chỗ thiếu); và chấm YC bằng hai nhãn *đạt / không đạt*, trong khi 04-yeu-cau-du-lieu.md §0 luật 2 nói
*"không xảy ra được" không có nghĩa là "database phải chặn"*.

**Decision:**
1. **Mỗi bước ở quán một giao dịch được COMMIT**, trên database kiểm riêng của `db-check` (có dữ liệu
   mồi), trong ngày bán giả định là *ngày mai*. Mốc của vết cập nhật đặt về giờ của bước — tiền lệ
   `db/reconcile/proof/i009_2.sql`. Hàm `pg_temp.sc_*` đứng thay cửa của pha 3, không quyết luật nào.
2. **Đọc lại ở một kết nối khác**, sau COMMIT, chỉ từ dữ liệu, neo vào ngày diễn; mỗi dòng *Kết quả mong
   đợi* kiểm bằng **quan hệ** (hoá đơn = tổng dòng, dòng mới − dòng cũ = số bánh × phần tăng giá gốc đọc
   từ vết) — **không chép con giá nào** (**ADR-001**). Phép cộng tay từ `shop-facts.md` ở file cổng.
3. **Bộ đối chiếu chạy lại trên ngày vừa diễn** ⇒ mọi câu rỗng: một buổi bán đúng không làm kêu câu nào.
4. **Chấm YC năm kết cục có tên** cho câu *dựng được trạng thái sai không*: TỪ CHỐI (lời database) ·
   KHÔNG CHỖ (lược đồ không có chỗ cho trạng thái ấy, in bằng chứng vắng mặt) · ĐI QUA (cái sai là chặn
   nhầm, việc hợp lệ ghi được) · GỌI TÊN (database không chặn, câu đối chiếu có lỗi cài chứng minh biết
   kêu gọi tên nó) · DỰNG ĐƯỢC / CHƯA TRẢ LỜI ĐƯỢC (kèm mã chỗ hở). Mỗi kết cục tự kiểm: một kết cục
   không còn đúng ⇒ FAIL, nên cổng đổi thì file chấm đổi cùng lượt.
5. **Tất cả là bước 7 của `scripts/db-check.sh`**, không phải một lượt chạy tay dán output: mã YC phải
   chấm đọc lúc chạy từ owner (các mã đứng trước §8 của `04-yeu-cau-du-lieu.md`), `comm -3` với mã có đủ
   hai dòng; mỗi `GỌI TÊN` phải trỏ tới một file lỗi cài còn đó và khai đúng mã.

**Rejected alternatives:**
- *Diễn trong một giao dịch ROLLBACK như ngày mẫu của P2-11.* Bác: lý do ở *Context*; ngày mẫu chứng
  minh bộ đối chiếu, không chứng minh từng bước ở quán ghi được.
- *Một lượt chạy tay, dán output vào file cổng.* Bác: output dán là bản chụp một ngày; lát sau đổi lược
  đồ thì ô đã ký vẫn xanh trên giấy (**F-001** · **F-033**).
- *Chấm YC hai nhãn đạt / không đạt.* Bác: gộp *database chặn* với *câu đối chiếu bắt* và với *lược đồ
  không có chỗ*, ba câu trả lời khác nhau cho người đọc cổng.
- *Kiểm con số tiền kỳ vọng trong SQL.* Bác: là bản chép thứ hai của `shop-facts.md` §4.

**Hệ quả:** `db-check` thêm khoảng hai mươi giây. Database kiểm sau bước 7 có một ngày bán thật đã
COMMIT — bước nào thêm sau bước 7 đọc database ấy phải biết điều đó. Test `i024` COMMIT một đơn qua
dblink trước bước 7, nên file đọc lại và file chấm neo mọi phép tìm vào ngày diễn, không giả định
database sạch.

**Applies to:** `db/scenario/` · `scripts/db-check.sh` · `docs/product/2-db/11-cong-chat-luong-pha-2.md` ·
`docs/product/2-db/10-quy-uoc-code.md` `QC-07` · `QC-08`.

---

### ADR-068 — Lược đồ admin được dựng cho phần ĐÃ ĐỦ LUẬT, trước khi mảng bán hàng chạy thật

**Trạng thái:** **Đã chốt** 2026-09-29. Điểm 1 là **lời chủ repo** trong phiên: *"tôi muốn làm luôn
db cho phần admin hãy kiểm tra xem đã dủ dữ liệu chưa nếu ròi hãy viết prompt để làm master pan,
back log"*, nhắc lại 2026-09-30 (*"tiếp tục"*) sau khi phiên báo lời ấy trái **ADR-031** và lời Đ-2.
Điểm 2 · 3 · 4 **giao cho phiên**: lời gốc không nêu phạm vi, mã bước hay chỗ đặt sổ (`CLAUDE.md`
§7.2). Task **T-122**.

**Context:**
**ADR-031** xếp ba mảng quản trị *sau* luồng bán hàng ở nghĩa thi công, và lời Đ-2 ngày 2026-09-20
(`work/backlog.md`, mục *Thứ tự làm giữa lane admin và các pha*) cho lane admin chạy song song pha 2
chỉ ở nghĩa **thu luật**. Từ đó tới 2026-09-30 hai việc đổi: chủ quán trả lời phần lớn các câu nhóm
B · C · D · E (`master_plan/shop-facts.md` §8.4 · §8.7 · §8.9 · §8.10), và mười bốn bước pha 2 của
mảng bán hàng đều `Done`. Lời đáp phủ không đều: sổ nguyên liệu, chấm công, tạm ứng, thưởng và khoản
chi có lời đủ để biết *phải ghi lại được gì*; lương, lãi/lỗ, nợ nhà cung cấp, quyền xem thì chưa.
Pha 1 lại chưa viết dòng yêu cầu dữ liệu hay invariant nào cho admin.

**Decision:**
1. **Được dựng lược đồ admin ngay**, không chờ luồng bán hàng chạy thật (lời chủ repo).
2. **Phạm vi đọc hẹp:** chỉ phần đã có lời chủ quán ở owner. Phần còn chờ lời **không** có bước và
   không có chỗ cất để sẵn. Pha 3 · pha 4 của admin không mở — chữ *"sau"* của ADR-031 còn nguyên
   cho chúng.
3. **Thứ tự pha không nhảy cóc:** bước đầu viết yêu cầu dữ liệu và invariant cho phần admin ấy vào
   chính các owner của pha 1, rồi mới tới lát lược đồ (**ADR-050**).
4. **Mã bước là `P2A-XX`**; thứ tự · mức · cổng ở `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`;
   mô tả dài ở `work/backlog_AD_DB.md`; trạng thái chỉ ở `work/backlog.md` (**ADR-002**).

**Rejected alternatives:**
- *Chờ đủ lời cho cả ba mảng rồi mới dựng.* Bác: trái lời chủ repo, và phần đã đủ luật không phụ
  thuộc phần chưa đủ.
- *Dựng luôn chỗ cất cho lương, lãi/lỗ, nợ nhà cung cấp "để sẵn".* Bác: một cột để sẵn là một luật
  nghiệp vụ không ai nói (`CLAUDE.md` §3.5); pha 3 sẽ đọc nó như đã chốt.
- *Nối thành `P2-15`… trong kế hoạch pha 2.* Bác: kế hoạch ấy đã ký cổng 12/12 cho mười bốn bước;
  thêm bước là mở lại một cổng đã ký, và §3 của nó nói rõ admin không thuộc mười bốn bước.
- *Dùng mã `ADM-XX` và ghi vào `work/backlog_AD.md`.* Bác: luật 5 của sổ ấy giữ nó ở tầng nghiệp vụ;
  một mã mang hai tầng là cái bẫy **F-015** · **F-021**.
- *Bỏ bước yêu cầu và invariant, dựng thẳng lát.* Bác: pha 2 thi hành tầng của pha 1; không có tầng
  thì mỗi lát tự quyết cái gì phải không xảy ra được, và cổng không có gì để chấm.

**Hệ quả:** `CLAUDE.md` §2 thêm hàng cho sổ mới; hàng *Schema* trỏ thêm kế hoạch mới. Lời Đ-2 có
vế thứ ba. Hai câu mới `U-065` · `U-066` chặn hai trong bốn lát.

**Applies to:** `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md` · `work/backlog_AD_DB.md` ·
`work/backlog.md` · ADR-031 · ADR-036 · ADR-049.

### ADR-069 — Mệnh đề và yêu cầu dữ liệu của mảng admin đi vào MỤC RIÊNG CÓ NHÃN trong ba owner sẵn có, nối dãy mã; *máy không làm* thành vế có tên

**Trạng thái:** **Đã chốt** 2026-09-30. Phiên (Claude Code, bước `P2A-01`) đề xuất; **chủ repo đồng
ý** cùng ngày, nguyên văn: *"tôi đồng ý với đề xuất"*. Lời ấy xác nhận **hình dạng** ở mục
*Decision*; nó **không** biến năm chỗ suy ra ở điểm 6 thành lời chủ quán — chúng vẫn là suy ra về
nghiệp vụ (`CLAUDE.md` §7.2). Nó thi hành điểm 3 của **ADR-068** và không lật quyết định nào.

**Context:**
**ADR-068** điểm 3 đòi bước đầu của lược đồ admin viết yêu cầu dữ liệu và invariant *vào chính các
owner của pha 1*. Ba owner ấy — `quality/invariants.md`,
`docs/product/1-system-design/03-bao-ve-invariant.md`,
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` — được viết cho mảng bán hàng và mỗi file có
luật riêng buộc vào mảng ấy: bốn nhóm mệnh đề có chủ từng nhóm, và luật *mỗi dòng §1 của file yêu
cầu khớp một-đối-một với `architecture.md` §8*. Lời chủ quán về admin lại có dạng khác lời về bán
hàng: phần lớn là bảng *máy làm / máy KHÔNG làm* (`master_plan/shop-facts.md` §8.4).

**Decision:**
1. **Mục riêng có nhãn, không chen vào mục của mảng bán hàng** (**ADR-013**): năm mệnh đề
   `I-025`…`I-029` nối cuối `quality/invariants.md`; tầng và phép đối chiếu của chúng là **§5 — nhóm
   QUẢN TRỊ** của `03-bao-ve-invariant.md`; tám dòng `YC-26`…`YC-33` là **§9** của
   `04-yeu-cau-du-lieu.md`. Luật một-đối-một với `architecture.md` §8 **không** áp cho §9.
2. **Nối dãy mã đang có**, không mở tiền tố riêng cho admin: mọi phép đọc mã — `scripts/reconcile.sh`,
   cổng chấm ngược dòng `YC` — đọc một dãy.
3. **Một dòng `YC` cho mỗi vế ở cột giữa bảng §2 của kế hoạch lược đồ admin**; vế đã có dòng từ
   trước (trực quầy theo thời điểm: `YC-04` · `YC-15`) thì **trỏ**, không viết dòng thứ hai.
4. **Câu *máy KHÔNG làm* thành vế *không xảy ra được* có tên** — không ngưỡng nhắc sắp hết, không
   định lượng suất, không kết luận thiếu, không khoản trừ vì chấm muộn. Những vế ấy **không có tập đối chiếu**: một chỗ
   cất thừa không phải một dòng dữ liệu sai, nên chúng kiểm bằng **đọc lược đồ** ở cổng của kế hoạch
   (ô 7), và bảng tầng nói thẳng điều đó (`03-bao-ve-invariant.md` §0 luật 5).
5. **Chỗ chủ quán chưa nói thì mệnh đề khai *không nói*, và trỏ mã của câu còn mở** — số mốc của một
   lần chấm công (**U-065**), nguồn tiền của khoản chi (**U-066**), nguồn tiền của tạm ứng và thưởng
   (**U-067**, mở ở bước này), nghĩa của *thời gian nhập* (**U-068**, mở ở bước này), đơn vị ghi
   (`work/admin-questions.md` câu `B12`). Không khoản nào của admin được nối vào phép trừ két của
   `I-021` chừng nào hai câu nguồn tiền còn mở.
6. **Năm chỗ suy ra được ghi tại chỗ**, trong mục *Why* của từng mệnh đề: một thứ đứng một lần trong
   danh mục; hiệu số âm không bị từ chối; số tiền của tạm ứng, thưởng và khoản chi lớn hơn 0; và
   *thời gian nhập* được giữ thành hai mốc.

**Why:**
- Mục riêng giữ cho một lần sửa admin không đọc nhầm một hàng bán hàng, và giữ nguyên *một nhóm, một
  chủ* của file tầng (`work/findings.md` **F-010** · **F-014**).
- Một dãy mã thì một mệnh đề admin thiếu câu đối chiếu tự bị bắt là *vắng mặt* — đúng cơ chế đã có
  (**F-018** · **F-026**). Giá của lựa chọn này lộ ngay: `work/findings.md` **F-052**.
- *Máy không làm* mà không thành vế có tên thì im lặng; một lát sau sẽ để sẵn một cột ngưỡng và pha 3
  đọc nó như luật đã chốt (kế hoạch lược đồ admin §9).
- Mệnh đề nói rõ chỗ nó **không** nói thì lát lược đồ biết chỗ nào phải để trống, thay vì lấp bằng
  một mặc định (`CLAUDE.md` §3.5).

**Rejected alternatives:**
- *Mở file invariant và file yêu cầu riêng cho admin.* Bác: **ADR-068** điểm 3 chỉ chính các owner
  sẵn có; hai nhà cho cùng một loại sự thật là thứ `CLAUDE.md` §2 cấm.
- *Tiền tố mã riêng (`IA-`, `YCA-`).* Bác: mọi phép đọc mã phải học thêm một hình dạng, và mệnh đề
  admin rơi khỏi phép so `comm -3` đang có.
- *Không viết mệnh đề cho chấm công và khoản chi vì lát của chúng còn chờ `U-065` · `U-066`.* Bác:
  phần đã có lời — mỗi lần chấm thuộc một người, không khoản trừ; mỗi khoản chi có loại, tiền hàng
  không đứng ở đó — không phụ thuộc hai câu ấy, và kế hoạch §5 đòi bốn mảng.
- *Biến lời `B20` (không ai ghi hỏng · đổ · cháy) thành vế "không có chức năng ghi".* Bác: §8.4 nói
  thẳng lời ấy là thực tế quán, chưa phải yêu cầu có hay không có chức năng.
- *Gộp năm mệnh đề thành một mệnh đề "sổ admin".* Bác: bốn lát chạy song song và mỗi lát phải trỏ
  được về mệnh đề của riêng nó.

**Applies to:** `quality/invariants.md` `I-025`…`I-029` ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §5 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9 · `docs/product/0-ba/admin/01-ranh-gioi.md`
§1.6 · `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md` · ADR-013 · ADR-050 · ADR-068.

### ADR-070 — Phép so mã của bộ đối chiếu nhận một danh sách *mệnh đề chưa có lát* có tên, tự hết hạn

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên** (Claude Code, task `T-123`; thi công:
Codex) — không phải lời chủ repo (`CLAUDE.md` §7.2); chủ repo đổi được. `work/findings.md` **F-052**
ghi đây là việc chủ repo chọn; lời giao ngày 2026-09-30 là *"đọc kĩ finding trên, yêu cầu codex làm
và bạn kiểm tra"* — nó giao việc chữa, **không** nêu đường nào. Phiên chọn phần mà cả hai đường của
finding đều cần, và để nguyên phần còn lại (xem *Không quyết ở đây*).

**Context:**
`scripts/reconcile.sh` so mã `### I-0xx` ở `quality/invariants.md` với mã có câu ở `db/reconcile/`;
lệch là `FAIL` (**ADR-066**, **F-018** · **F-026**). **ADR-069** nối năm mệnh đề admin vào cùng dãy
mã, và kế hoạch lược đồ admin §5 giao câu của chúng cho `P2A-07`, sau bốn lát. Giữa hai mốc ấy
`db-check` đỏ ở mọi lát vì lý do không thuộc về lát (**F-052**). Hai lát còn chờ lời chủ quán
(`I-027` — **U-065**, `I-029` — **U-066**), nên dù câu được viết ở lát hay ở `P2A-07`, vẫn có mệnh
đề đứng không câu trong một khoảng không ai định trước được.

**Decision:**
1. Phép so mã nhận một danh sách **mệnh đề chưa có lát**. Mã có dòng trong danh sách ⇒ `NOTE` gọi
   tên mã và người nợ; **mọi mã khác thiếu câu vẫn `FAIL`** như cũ.
2. Danh sách nằm ở **owner sẵn có** của *"tập nào chưa có câu, vì sao, ai nợ"* —
   `docs/product/2-db/09-doi-chieu-bat-bien.md` §2.1 — và script **đọc lúc chạy** (**F-001**). Không
   mở file `.ignore` thứ tư.
3. Mỗi dòng là **một mã**, có *vì sao* và *ai nợ*; thiếu một trong hai ⇒ `FAIL`.
4. **Tự hết hạn:** mã có dòng mà đã có câu, hoặc không còn ở `quality/invariants.md` ⇒ `FAIL` cho tới
   khi dòng bị gỡ — cùng luật với ba file `.ignore` của Gate 1b · 1c · 1d (`CLAUDE.md` §5).
5. Dòng `PASS` của phép so và dòng tổng kết in **cả hai con số** (mã có câu · mã chưa có lát);
   `db-check` in lại dòng `NOTE`. Một lần chạy xanh không được đọc thành *mọi mệnh đề đã được chấm*.
6. Bước nào viết câu cho một mệnh đề thì **gỡ dòng của nó trong cùng thay đổi**.

**Không quyết ở đây:** câu đối chiếu của một mệnh đề admin được viết **ở lát của nó** (đường (a) của
**F-052**) hay **dồn về `P2A-07`** (kế hoạch §5 hiện hành). Cột *ai nợ* hôm nay ghi `P2A-07` vì đó
là lời kế hoạch đang có; chủ repo chọn đường (a) thì chỉ đổi hàng `P2A-02`…`P2A-07` của kế hoạch và
cột ấy, cơ chế không đổi.

**Why:**
- Cổng đỏ vì lý do đã biết trước là cổng người ta học cách bỏ qua (**F-052**, *Impact*).
- Ngoại lệ có tên, có người nợ và tự hết hạn thì không thành chỗ chôn nợ (**F-041**).
- Một owner: file 09 đã giữ bảng *tập chưa có câu*; một danh sách thứ hai ở `scripts/` là hai nhà
  cho một loại sự thật (`CLAUDE.md` §2).

**Rejected alternatives:**
- *Chỉ đường (a), không danh sách.* Bác: `I-027` · `I-029` vẫn đỏ cho tới khi có lời cho **U-065** ·
  **U-066**.
- *Chỉ so mã cho các mệnh đề bán hàng (`I-001`…`I-024`).* Bác: một mệnh đề admin thiếu câu thành vô
  hình, đúng điều **ADR-069** điểm 2 muốn tránh.
- *Dời việc viết mệnh đề tới khi có câu.* Bác: lát cần mệnh đề trước để biết phải thi hành gì
  (**ADR-050**).

**Applies to:** `scripts/reconcile.sh` · `scripts/reconcile.test.sh` · `scripts/db-check.sh` ·
`docs/product/2-db/09-doi-chieu-bat-bien.md` §2.1 · `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`
§5 · ADR-066 · ADR-069 · `work/findings.md` F-052.

### ADR-071 — Sổ nguyên liệu: một con số người gõ là MỘT dòng; tổng không có chỗ cất; con số là `numeric` đúng như gõ

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên** (Claude Code, bước `P2A-02`; thi công:
Codex) — không phải lời chủ repo hay chủ quán (`CLAUDE.md` §7.2); chủ repo đổi được. Lời giao ngày
2026-09-30 là *"hãy đọc kĩ và hoàn thành task trên. yêu cầu codex làm bạn kiểm tra"*: nó giao việc
dựng lát, không nêu hình dạng nào. Nó thi hành `quality/invariants.md` `I-025` · `I-026` và không lật
quyết định nào; điểm 6 **sửa đổi** cách bộ kiểm chứng minh luật 2 của **ADR-065**, không đổi luật ấy.

**Context:**
`P2A-01` đã viết bốn dòng yêu cầu `YC-26`…`YC-29` và hai mệnh đề `I-025` · `I-026` cho sổ nguyên liệu
(**ADR-069**), cùng tầng giữ của từng vế ở `docs/product/1-system-design/03-bao-ve-invariant.md` §5.
Lát `P2A-02` phải chọn hình lược đồ thi hành chúng. Sáu chỗ không mệnh đề nào chọn hộ, và hai trong số
đó chỉ lộ ra khi đọc bộ kiểm: quy ước kiểu (`docs/product/2-db/10-quy-uoc-code.md` `QC-04`) chỉ cho
*số lượng* là số nguyên, còn danh mục của chủ quán mua theo cân; và bước khoá chặn của
`scripts/db-check.sh` giả định bước migration trên cùng luôn có dữ liệu mồi.

**Decision:**
1. **Hai bảng: danh mục, và con số ngày. Một con số người gõ là MỘT dòng** — của một thứ, một ngày,
   một loại (*mua vào* hoặc *đã dùng*) — mang **người nhập, ngày của con số và lúc gõ của riêng nó**.
   Khoá duy nhất trên (thứ, ngày, loại) là vế *một thứ, một ngày, một đáp số* của `I-026`. Tên bảng,
   cột, ràng buộc: file migration thắng (**ADR-053** luật 2); ý định ở
   `docs/product/2-db/12-luoc-do-nguyen-lieu.md`.
2. **Con số cất bằng `numeric` không khai độ chính xác, trong cột hậu tố `_measure`** — một vai trò
   mới ở `QD-03` và một dòng mới ở `QC-04`. Ràng buộc kiểm của lát giữ nó **không âm và hữu hạn**.
   *Không âm* là phiên chọn theo khuôn sẵn có của `QC-04` (*không âm là ràng buộc kiểm của lát*),
   không phải lời chủ quán: sửa một con số gõ nhầm đi bằng lần cập nhật có vết, không bằng số âm.
3. **Tổng đã nhập, tổng đã dùng và hiệu số KHÔNG có chỗ cất, và lát không dựng view hay hàm tổng
   nào.** Chúng đọc ra bằng một phép cộng trên các con số ngày — cùng hình bảng nhu cầu của `I-019`
   (`docs/product/2-db/05-luoc-do-san-xuat.md`). *Một chỗ tính tổng* (tầng 3 của `I-026`) là cửa đọc
   của pha 3.
4. **Danh mục: tên duy nhất đúng từng chữ, đơn vị mua trống được; không cột nào khác.** Không ngưỡng,
   không định lượng suất, không trạng thái *ngừng dùng*, không nhà cung cấp, không giá — test so danh
   sách cột của hai bảng **từng chữ**, nên thêm một cột là phải đổi mệnh đề trước.
5. **Vết sửa dùng lại trigger `record_revision_capture` sẵn có, ở chế độ mềm của nó**
   (`work/findings.md` **F-046**). Lát không tự làm nghiêm riêng cho hai bảng của mình.
6. **Bước khoá chặn của `scripts/db-check.sh` lùi TỪNG bước từ trên xuống**: bước mà chỗ cất còn rỗng
   thì lùi được (đúng luật 2 của **ADR-065**) và được gọi tên bằng một dòng `NOTE`; bước **đầu tiên**
   có dữ liệu phải từ chối; không bước nào từ chối ⇒ đỏ. Sau đó gỡ dấu *dirty*, xuôi lại tới đỉnh, và
   lược đồ phải giống hệt ảnh chụp trước bước ấy.

**Why:**
- *Điểm 1.* `I-025` đòi *ai · ngày nào · lúc nào* cho **từng con số**. Hai con số của một ngày có thể
  do hai người gõ ở hai lúc (người đi chợ buổi sáng, người ước lượng cuối buổi); một dòng mang hai cột
  chỉ có một người nhập và một lúc gõ, và con số thứ hai đến sau là một lần **sửa** dòng ấy — đi qua
  vết ở chế độ mềm, tức là có thể không để lại *ai*.
- *Điểm 2.* `shop-facts.md` §8.4: máy giữ **đúng con số người gõ**, không quy đổi đơn vị (`I-026`
  điều kiện biên, câu **B12** còn mở). Số nguyên buộc người gõ tự đổi nửa cân ra đơn vị nhỏ hơn —
  đúng phép quy đổi máy không được làm thay, nay đẩy sang người. Chủ quán chưa nói con số có lẻ hay
  không; `numeric` nhận cả hai nên không lấp hộ câu ấy.
- *Điểm 3.* Một con số tổng cất riêng là con số thứ hai cho cùng một câu hỏi (`I-026` *Why*). Một view
  trong schema thì các phép kiểm `QD-XX` đọc nó như một bảng (`QD-11` đòi khoá ngoại cho cột `_id`
  của nó) — nới các phép ấy để chứa một tiện ích của pha 3 là trả giá ở sai chỗ.
- *Điểm 4.* Rủi ro lớn nhất của kế hoạch lược đồ admin là *dựng rộng hơn lời* (kế hoạch §9).
- *Điểm 5.* Kế hoạch §3 điểm 3: lát admin **dùng lại** thứ pha 2 đã dựng, thấy thiếu thì gửi ngược
  một finding — finding ấy đã có. Hai chế độ vết trong một schema làm cùng một lệnh sửa có hai nghĩa
  tuỳ bảng.
- *Điểm 6.* Bước cũ lùi đúng một bước và đòi bị từ chối. Từ lát này, bước trên cùng có thể rỗng mãi
  (tạm ứng, khoản chi không bao giờ có dữ liệu mồi), nên bước cũ đỏ vì một lý do không thuộc về lát
  nào — cùng họ với **F-052**, ghi ở `work/findings.md` **F-053**.

**Rejected alternatives:**
- *Một dòng một ngày, hai cột mua vào · đã dùng.* Bác: lý do điểm 1.
- *Số nguyên (`integer`) theo dòng *số lượng* sẵn có của `QC-04`.* Bác: lý do điểm 2. *Số thực dấu
  phẩy động.* Bác: cộng dồn ra phần lẻ không ai gõ. *`numeric(p,s)`.* Bác: làm tròn im lặng con số
  vượt `s` — máy sửa con số người gõ mà không ai bấm gì.
- *Một view tổng trong schema.* Bác: lý do điểm 3.
- *Tên duy nhất không phân biệt hoa thường.* Bác: danh mục menu so đúng từng chữ; hai cách so cho hai
  danh mục là một bẫy. Chỗ hở (*Gạo* · *gạo*) có tên ở file lát §5.
- *Một cột trạng thái *ngừng dùng* cho danh mục.* Bác: chủ quán chưa nói gì về việc bỏ một thứ.
- *Làm nghiêm vết ngay trên hai bảng mới* (từ chối lần sửa không khai lý do). Hấp dẫn — bảng mới không
  có file test cũ nào phải sửa — nhưng bác: lý do điểm 5; nó gỡ cùng lượt với **F-046**.
- *Cho bước khoá chặn chèn một dòng giả vào bảng trên cùng.* Bác: bộ kiểm phải biết tên bảng của
  từng lát, và dòng giả ở lại database cho hai bước sau. *Gộp dữ liệu mồi `P2A-06` vào lát này.* Bác:
  không chữa được các lát không có dữ liệu mồi.

**Suy ra, không phải lời chủ quán** (`CLAUDE.md` §7.2): con số *không âm*; hai mã máy đọc của hai loại
con số; tên duy nhất *đúng từng chữ*. Không câu nào chặn việc dựng; không câu hỏi mới nào mở ra.

**Applies to:** `db/migrations/20260930100000_so_nguyen_lieu.up.sql` · `.down.sql` ·
`db/tests/i025_supply_numbers_entered_by_a_person.sql` · `db/tests/i026_supply_totals_from_day_entries.sql` ·
`docs/product/2-db/12-luoc-do-nguyen-lieu.md` · `docs/product/2-db/01-quy-uoc-du-lieu.md` `QD-03` ·
`docs/product/2-db/10-quy-uoc-code.md` `QC-04` · `docs/product/2-db/07-thu-tu-migration.md` §4 ·
`scripts/db-check.sh` bước 5 · ADR-050 · ADR-065 · ADR-069 · `work/findings.md` F-046 · F-053.

### ADR-072 — Chấm công: một ô *có đi làm* là MỘT dòng của một người một ngày; không có dòng là không có ô; ô tick nhầm được HUỶ tại chỗ, không xoá và không đổi

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên** (Claude Code, bước `P2A-03`; thi công:
Codex) — không phải lời chủ repo hay chủ quán (`CLAUDE.md` §7.2); chủ repo đổi được. Lời giao ngày
2026-09-30 là *"hãy đọc kĩ và hoàn thành. codex làm bạn kiểm tra"*: nó giao việc dựng lát, không nêu
hình dạng nào. Nó thi hành `quality/invariants.md` `I-027` (viết lại cùng lượt theo lời chủ quán đóng
`U-069`) và không lật quyết định nào.

**Context:**
Chủ quán chốt 2026-09-30: *chủ quán tick hết* ô *có đi làm*, *mỗi người mỗi ngày một ô*
(`master_plan/shop-facts.md` §8.7, lời đóng `U-065` · `U-069`). Dòng yêu cầu `YC-30` và mệnh đề `I-027`
đã viết lại theo lời ấy. Lát `P2A-03` phải chọn hình lược đồ thi hành chúng. Bốn chỗ không mệnh đề nào
chọn hộ: một ô *chưa tick* có là một dòng không; *người tick là chủ quán* giữ ở đâu; một ô tick nhầm
được gỡ bằng hình nào; và tên các cột cùng trỏ về người. *Sửa cùng ngày, trước khi commit:* bản đầu của
quyết định này khoá hẳn đường gỡ vì chủ quán chưa nói; chủ quán rồi đóng **U-070** bằng lời *"làm thêm
nút huỷ, và có phần note lại để sau đó có thể kiểm"*, và điểm 4 viết lại theo lời ấy.

**Decision:**
1. **Một bảng; một ô *có đi làm* là MỘT dòng** — của một người, một ngày — mang **người được chấm,
   ngày của ô, người tick và lúc tick**. **Không có dòng là không có ô**: lát không cất ô *chưa tick*,
   không có cột có/không. Khoá duy nhất trên (người được chấm, ngày) **của các ô chưa huỷ** là vế *một
   người một ngày nhiều nhất một ô còn hiệu lực*. Tên bảng, cột, ràng buộc: file migration thắng (**ADR-053** luật 2); ý định ở
   `docs/product/2-db/13-luoc-do-cham-cong.md`.
2. **Người tick là cột *ai bấm* sẵn có của pha 2** — tên và mặc định như mọi bảng khác của `P2-08`
   (lấy từ người thao tác của giao dịch); **người được chấm mang tên riêng** có tiền tố nói vai của nó.
3. **Vế *người tick là chủ quán* KHÔNG do database xét** — đúng tầng 3 đã chốt ở
   `docs/product/1-system-design/03-bao-ve-invariant.md` §5, cùng hình vế *người duyệt là chủ quán* của
   `I-028`. Database giữ *có người tick, và người ấy là người của quán*; test in thẳng rằng một ô do
   người không phải chủ quán tick **được nhận**; tập đối chiếu của vế ấy là việc của `P2A-07`.
4. **Huỷ một ô là ba dấu ghi NGAY TRÊN dòng của ô: lúc huỷ, người huỷ, ghi chú.** Ô đã huỷ **ở lại** —
   đúng chữ *để sau đó có thể kiểm* — và không còn tính vào khoá duy nhất, nên tick lại đúng người,
   đúng ngày ấy được nhận. Lần huỷ phải có **người huỷ** (người của quán) và không đứng trước lúc tick;
   **ghi chú để trống được**, có thì không được trắng, và chỉ đứng trên một ô đã huỷ. Vai ghi của hệ
   thống **chèn** được một ô và **ghi được ba dấu huỷ**; **không** sửa được người hay ngày của ô và
   **không** xoá được ô (`QD-50`). Trigger vết vẫn gắn lên bảng như mọi bảng (`QD-52`).
5. **Ngày của ô là một ngày người khai, không phải ngày của đồng hồ**; lúc tick là mốc hệ thống ghi.
   Lát không buộc hai thứ trùng nhau và không cấm ô cho một ngày đã qua.
6. **Không cột nào khác.** Không giờ tới, giờ về, buổi, dấu đi muộn, ngưỡng, khoản trừ, đơn giá công —
   test so danh sách cột **từng chữ**, nên thêm một cột là phải đổi mệnh đề trước.

**Why:**
- *Điểm 1.* Lời chủ quán là *tick vào ô có đi làm*: thứ được ghi là việc **có đi làm**. Một cột
  có/không sinh ra trạng thái thứ ba không ai nói tới — *đã ghi là không đi làm* — và `I-027` nói thẳng
  một ngày không có ô không phải một ngày nghỉ đã ghi (`C30` còn hở vế nghỉ có báo trước).
- *Điểm 2.* Một tên cho một vai trò (`QD-03`): ở mọi bảng của `P2-08`, cột *ai bấm* là người thao tác.
  Đặt người được chấm vào cột ấy thì cùng một tên có hai nghĩa tuỳ bảng.
- *Điểm 3.* Pha 2 *thi hành* tầng pha 1 đã chốt, không nâng tầng hộ (**ADR-035**). Nâng lên database
  cần một trigger đọc cờ chủ quán — một hàm nhắc tới ô chấm công, đúng thứ phép đọc lược đồ của `I-027`
  dùng để chứng minh *không đường nào đi từ một ô tới thứ khác*.
- *Điểm 4.* Lời chủ quán đòi lần huỷ *kiểm lại được*, nên ô huỷ không được biến mất, và người huỷ
  cùng lúc huỷ phải đọc ra **không phụ thuộc** vết chung — vết ấy ở chế độ mềm (`work/findings.md`
  **F-046**): sửa không khai lý do thì không để lại gì. Cùng hình lần lùi mẻ của `P2-07` · `P2-08`
  (lúc lùi, ai lùi ngay trên dòng của mẻ). Đổi ngày hay người của một ô **là** huỷ ô này và tick ô
  khác; để ngỏ quyền sửa hai cột ấy là mở một đường gỡ thứ hai không có ghi chú. Ghi chú không bắt
  buộc vì lời chỉ nói *có phần note*: siết sau bằng một migration một dòng thì rẻ; nới sau một ràng
  buộc đã chặn người dùng thì không.
- *Điểm 5.* Cùng hình hai mốc của `YC-08` · `YC-28`. Một ràng buộc so ngày với đồng hồ không viết được
  thành ràng buộc kiểm, và lời chủ quán không nói chủ quán tick lúc nào trong ngày hay có tick bù không.
- *Điểm 6.* Rủi ro lớn nhất của kế hoạch lược đồ admin là *dựng rộng hơn lời* (kế hoạch §9).

**Rejected alternatives:**
- *Một dòng cho mỗi (người, ngày) với cột có/không.* Bác: lý do điểm 1; và nó đòi ai đó sinh sẵn dòng
  cho mọi người mọi ngày.
- *Xoá hẳn ô tick nhầm.* Bác: trái lời *để sau đó có thể kiểm* và trái `QD-50`.
- *Một bảng riêng cho các lần huỷ.* Bác: một ô huỷ nhiều nhất một lần; ba cột trên dòng của ô đủ, và
  cùng hình lần lùi mẻ đã có.
- *Ghi chú huỷ bắt buộc.* Bác lúc này: lý do điểm 4; chờ **U-071**.
- *Cấm tick lại sau khi huỷ.* Bác: huỷ nhầm một ô đúng thì không còn cách nào ghi lại ngày công ấy.
- *Trigger từ chối người tick không phải chủ quán.* Bác: lý do điểm 3.
- *Để nguyên quyền sửa như mọi bảng, dựa vào vết.* Bác: lý do điểm 4.
- *Ràng buộc cấm ngày của ô ở tương lai.* Bác: lý do điểm 5; không có lời nào cho nó.
- *Nối ô với khoảng trực quầy của `P2-08`.* Bác: `shop-facts.md` §8.8 nói thẳng hai việc khác nhau.

**Suy ra, không phải lời chủ quán** (`CLAUDE.md` §7.2): không có dòng nghĩa là không có ô; ghi chú
huỷ **để trống được** và người huỷ **không bị xét** có phải chủ quán không (cả hai chờ **U-071**); huỷ
rồi **tick lại được**; một ô đã huỷ không có đường *bỏ huỷ* riêng — vai ghi sửa được ba dấu huỷ, và
lần sửa ấy chỉ để lại vết ở chế độ mềm (**F-046**); ô cho ngày đã qua được nhận; chủ quán cũng là một
người được chấm được (lát không cấm, không đòi). Không câu nào chặn việc dựng.

**Applies to:** `db/migrations/20260930110000_cham_cong.up.sql` · `.down.sql` ·
`db/tests/i027_attendance_one_box_per_worker_day.sql` · `docs/product/2-db/13-luoc-do-cham-cong.md` ·
`docs/product/2-db/07-thu-tu-migration.md` §1 · `quality/invariants.md` `I-027` ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` `YC-30` · ADR-035 · ADR-053 · ADR-065 · ADR-069 ·
`work/findings.md` F-046 · `docs/product/99-unknowns.md` U-071.

### ADR-073 — Tạm ứng và thưởng: HAI bảng, mỗi khoản một dòng; người duyệt là một dấu riêng chỉ tạm ứng có; vai ghi chỉ sửa được số tiền · người nhận · ngày; không cột nào nối sang két

**Trạng thái:** **Đã chốt** 2026-09-30, **giao cho phiên** (Claude Code, bước `P2A-04`; thi công:
Codex) — không phải lời chủ repo hay chủ quán (`CLAUDE.md` §7.2); chủ repo đổi được. Lời giao ngày
2026-09-30 là *"hãy đọc kĩ và làm, yêu cầu để codex làm bạn kiểm tra"*: nó giao việc dựng lát, không
nêu hình dạng nào. Nó thi hành `quality/invariants.md` `I-028` đúng như đang viết và không lật quyết
định nào.

**Context:**
`C28` · `C29` (`master_plan/shop-facts.md` §8.7): *có thưởng lễ Tết*; *có tạm ứng, chủ quán duyệt*.
`I-028` và hai dòng yêu cầu `YC-31` · `YC-32` đã nói một khoản gồm gì: của ai, bao nhiêu, lúc nào, ai
ghi, và — riêng tạm ứng — ai duyệt; nên bẫy *lời không đủ để biết một khoản tạm ứng gồm gì* của entry
`P2A-04` không xảy ra, không câu `U-XXX` nào phải mở để dựng. Lát `P2A-04` phải chọn hình lược đồ thi
hành chúng. Năm chỗ không mệnh đề nào chọn hộ: hai loại khoản ở chung một bảng hay hai; *lúc nào* là
một ngày hay một mốc giờ; một khoản đã ghi thì vai ghi sửa được những gì; chế độ mềm của vết
(`work/findings.md` **F-046**) có bị siết riêng cho hai bảng tiền này không; và lát đứng thế nào với
két khi `U-067` đã có lời (*từ két bán hàng*) mà mệnh đề chưa viết lại (task `T-125` ở
`work/backlog.md`).

**Decision:**
1. **Hai bảng, mỗi khoản là MỘT dòng** — một bảng cho tạm ứng, một bảng cho thưởng lễ Tết. Mỗi dòng
   mang **người nhận, số tiền, ngày của khoản, người ghi và lúc ghi**; bảng tạm ứng mang thêm **người
   duyệt**, bắt buộc. Bảng thưởng **không có** cột người duyệt và **không có** cột loại thưởng. Tên
   bảng, cột, ràng buộc: file migration thắng (**ADR-053** luật 2); ý định ở
   `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md`.
2. **Người nhận mang cùng tên cột với người được chấm của lát chấm công** (**ADR-072** điểm 2) — cùng
   một vai: *người làm mà dòng này nói về*. **Người ghi là cột *ai bấm* sẵn có**, mặc định lấy từ
   người thao tác của giao dịch. **Người duyệt là cột thứ ba, phải khai, không có mặc định.**
3. **Vế *người duyệt là chủ quán* KHÔNG do database xét** — đúng tầng 3 đã chốt ở
   `docs/product/1-system-design/03-bao-ve-invariant.md` §5. Database giữ *có người duyệt, và người ấy
   là người của quán*; test in thẳng rằng một khoản do người không phải chủ quán duyệt **được nhận**;
   tập đối chiếu của vế ấy là việc của `P2A-07`.
4. ***Lúc nào* là một NGÀY người khai, đứng riêng với lúc ghi** do hệ thống cấp — cùng hình hai mốc
   của `YC-08` · `YC-28` và **ADR-072** điểm 5. Lát không buộc hai thứ trùng nhau, không cấm khoản cho
   một ngày đã qua.
5. **Số tiền là số nguyên đồng, lớn hơn 0** (`QD-20` · `QD-21`; vế *lớn hơn 0* là của `I-028`).
   **Không có khoá duy nhất nào**: một người nhận được hai khoản trong cùng một ngày.
6. **Vai ghi của hệ thống chèn được một khoản, sửa được đúng ba cột `I-028` nêu tên — số tiền, người
   nhận, ngày — và không xoá được** (`QD-50`). Người duyệt, người ghi và lúc ghi của một khoản đã có
   **không sửa được** bằng vai ấy.
7. **Vết sửa dùng nguyên cơ chế của `P2-08`, ở chế độ mềm như mọi bảng** (`QD-52`, **F-046**): lát
   không dựng một cơ chế nghiêm riêng cho hai bảng này. Test in thẳng *sửa không khai lý do: 0 vết*.
8. **Không cột, khoá ngoại, hàm hay trigger nào nối một khoản sang hoá đơn, tiền đã thu, ngày bán
   hay két.** Hai bảng chỉ trỏ về người. Nối két là việc của task `T-125`, làm bằng migration mới sau
   khi `I-021` · `I-028` viết lại. Test so danh sách cột **từng chữ**, và so số dòng của mọi bảng
   khác trước và sau khi ghi.

**Why:**
- *Điểm 1.* Hai loại khoản **khác hình**: tạm ứng có người duyệt, thưởng thì `I-028` nói thẳng *không
  nói ai duyệt*. Gộp một bảng thì cột người duyệt phải để trống được, và vế *tạm ứng không tồn tại
  được khi không có người duyệt* thành một ràng buộc kiểm đọc mã loại thay vì một dấu bắt buộc; cột
  ấy cũng là **chỗ cất sẵn** cho câu *ai duyệt thưởng* chưa ai trả lời. Một cột loại thưởng là chỗ
  cất sẵn cho *thưởng ngày đông khách*, đúng thứ `YC-32` cấm. Cái giá: phần lương sau này đọc hai
  bảng thay vì một — một phép hợp, rẻ hơn gỡ một chỗ cất sẵn.
- *Điểm 2.* Một tên cho một vai trò (`QD-03`). Người duyệt không lấy mặc định từ người thao tác vì
  người gõ khoản vào máy và người cho phép khoản ấy là hai việc; mặc định sẽ làm vế *có người duyệt*
  luôn đúng mà không ai khai gì.
- *Điểm 3.* Pha 2 *thi hành* tầng pha 1 đã chốt, không nâng tầng hộ (**ADR-035**); cùng lý do
  **ADR-072** điểm 3.
- *Điểm 4.* Lời chủ quán không nói giờ đưa tiền. Một ngày là thứ người nhớ được khi ghi lại sau, và
  là thứ phép trừ két của `T-125` cần để gắn khoản vào một ngày bán — nhưng lát **không** gọi nó là
  ngày bán, vì gọi thế là nối két trước khi mệnh đề cho phép.
- *Điểm 5.* Không lời nào giới hạn số lần ứng trong một ngày; một khoá duy nhất sẽ từ chối lần đưa
  tiền thật thứ hai và đẩy người ghi tới chỗ cộng tay hai khoản làm một.
- *Điểm 6.* `I-028` kể đúng ba thứ sửa được. Đổi người duyệt của một khoản đã ghi là viết lại *ai đã
  cho phép* — không lời nào nói việc ấy có; để ngỏ thì chế độ mềm cho nó đi qua không vết. Khoá lại
  rẻ: mở ra sau bằng một migration một dòng.
- *Điểm 7.* Chủ repo đã chọn chế độ mềm 2026-09-28 giữa ba đường, và **F-046** đã ghi đường gỡ là
  **một** migration cho mọi bảng. Siết riêng ở đây là lật lựa chọn ấy cho một góc, và sinh cơ chế vết
  thứ hai. Hệ quả nói thẳng: vế *không sửa đè* của `I-028` hôm nay **thấp hơn** tầng pha 1 đã chốt,
  cùng khoản nợ với F-046 — nặng hơn ở đây vì đây là tiền.
- *Điểm 8.* `I-028` viết: *cho tới khi `T-125` xong, không khoản nào ở đây được nối vào phép trừ
  két*. Một cột ngày bán hay mốc tính tiền dựng sẵn sẽ bị các phép cộng ngang lát đọc thấy trước khi
  có luật.

**Rejected alternatives:**
- *Một bảng với cột loại và cột người duyệt để trống được.* Bác: lý do điểm 1.
- *Bảng thưởng có cột tên dịp lễ.* Bác: không lời nào đòi; thêm được sau khi có lời.
- *Trigger từ chối người duyệt không phải chủ quán.* Bác: lý do điểm 3.
- *Trigger riêng từ chối lần sửa không khai lý do trên hai bảng này.* Bác: lý do điểm 7 — đáng làm,
  nhưng là việc của đường gỡ F-046, cho mọi bảng một lượt.
- *Không cấp quyền sửa cột nào của khoản đã ghi.* Bác: `I-028` nói thẳng sửa số tiền, người nhận hay ngày **là**
  một lần cập nhật có vết — đường sửa có trong mệnh đề.
- *Cột trạng thái đã trừ lương · đã trả lại.* Bác: khoản ấy trừ hay cộng vào lương thế nào chờ
  `C26` · `C33`; trả lại tạm ứng là một luật chưa ai nói (`I-028` mục Why).
- *Cột ngày bán hoặc khoá ngoại sang phiên két.* Bác: lý do điểm 8.

**Suy ra, không phải lời chủ quán** (`CLAUDE.md` §7.2): *lúc nào* là một ngày chứ không phải một giờ;
khoản cho ngày đã qua được nhận; một người nhận được nhiều khoản trong một ngày; người duyệt, người
ghi, lúc ghi không sửa được bằng vai ghi; chủ quán cũng là một người nhận được (lát không cấm, không
đòi); thưởng không mang tên dịp lễ. Không câu nào chặn việc dựng.

**Applies to:** `db/migrations/20260930120000_khoan_cua_nguoi.up.sql` · `.down.sql` ·
`db/tests/i028_advance_and_bonus_name_a_worker.sql` ·
`docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md` · `docs/product/2-db/07-thu-tu-migration.md` §1 ·
`quality/invariants.md` `I-028` · `docs/product/1-system-design/04-yeu-cau-du-lieu.md` `YC-31` ·
`YC-32` · ADR-035 · ADR-053 · ADR-065 · ADR-069 · ADR-072 · `work/findings.md` F-046 · task `T-125`.

### ADR-074 — Tiền RA khỏi két trong ngày là MỘT hạng tử của `I-021`; nguồn tiền nằm trên LOẠI chi; không cột *ngày bán của két* trước khi `U-072` có lời

**Trạng thái:** **Đã chốt** 2026-10-01, **giao cho phiên** (Claude Code, task `T-125`) — không phải
lời chủ repo hay chủ quán (`CLAUDE.md` §7.2); chủ repo đổi được. Lời giao 2026-10-01 là *"P2A-05 …
hãy đọc kĩ và làm"*; phiên chỉ ra `P2A-05` bị chặn bởi `T-125`, chủ repo chọn *làm `T-125` trước*.
Task mức **L3**: đây là bản thiết kế, **chưa có dòng code nào**; chủ repo duyệt nó trước khi
`P2A-05` dựng lược đồ.

**Context:**
Chủ quán chốt 2026-09-30 (đóng `U-066` · `U-067`, `master_plan/shop-facts.md` §8.7 · §8.10): điện,
nước, wifi, xăng xe, tạm ứng và thưởng lấy **từ két bán hàng**. Lời ấy không nói tiền rời két lúc
nào; nếu lấy từ tiền cuối buổi đã mang về (`E49`) thì két đếm cuối ngày không đổi và `I-021` không
thiếu gì. Phiên hỏi; chủ repo trả lời 2026-10-01: **trong ngày, trước lúc đếm két** (§8.10, dòng
`E46`). Vậy điều kiện biên thứ hai của `I-021` — *chỉ hai đường làm két vơi trong buổi* — sai, và
chính nó đòi mệnh đề **viết lại, không viết thêm**. Câu thứ hai phiên hỏi — khoản ấy trừ vào két
của **ngày bán nào** khi lấy một hôm mà ghi hôm khác — chủ repo trả lời *chưa biết, phải hỏi*: mở
**U-072**. Hai điều kiện ngoài: số tiền mặt đếm cuối ngày **chưa có chỗ cất** (`work/findings.md`
**F-048**), nên phép trừ két chưa có câu đối chiếu nào chạy được; và lát tạm ứng/thưởng đã dựng
(**ADR-073**) với ngày khai và lúc ghi, không cột nào nối két.

**Decision:**
1. **Một hạng tử mới, đứng cuối công thức `I-021`: *chi từ két*** — trừ tiền lấy khỏi két trong
   ngày để trả một khoản chi, một khoản tạm ứng hay một khoản thưởng. Điều kiện biên thứ hai viết lại
   thành **ba** đường. Lời `A4` (*không nộp bớt giữa buổi*) đứng nguyên.
2. **Mọi khoản tạm ứng và thưởng vào hạng tử; không dấu nguồn tiền trên hai bảng ấy.** Lời đóng
   `U-067` không có ngoại lệ.
3. **Nguồn tiền nằm trên LOẠI chi, bắt buộc; khoản chi vào hạng tử khi loại của nó mang nguồn két.**
   Bốn loại của `E44` mang nguồn két. Một loại không khai nguồn thì không tồn tại được.
4. **Mỗi khoản rời két trừ vào ĐÚNG MỘT ngày bán; luật chọn ngày chờ `U-072`.** Lược đồ giữ **cả**
   ngày khai lẫn lúc ghi (đã có ở `P2A-04`; `P2A-05` dựng cùng hình) và **không** dựng cột *ngày bán
   của két*. Lời tới thì phép đọc chọn một trong hai mốc, không đổi lược đồ.
5. **Hạng tử là phép cộng đọc thẳng các khoản, không con số tổng nào được cất** — cùng hình mọi
   hạng tử khác của `I-021` và luật 2 của `docs/product/1-system-design/architecture.md` §6.4.
6. **Không migration nào trong task này**, và lời *nối két bằng migration mới* của **ADR-073** điểm 8
   không còn cần: hai bảng đã mang đủ thứ hạng tử đọc. Điểm 8 ấy giữ nguyên ý *không cột nào nối két
   trước luật*; ADR này là luật, và nó không đòi cột.
7. **Câu đối chiếu của hạng tử chưa viết.** Phép trừ két không có câu chạy được tới khi `F-048` có
   chỗ cất; tập *trừ vào đúng một ngày bán* chờ `U-072`. `P2A-07` ghi chúng là *vắng, chờ câu nào*.

**Why:**
- *Điểm 1.* Không có hạng tử thì mọi ngày có trả tiền điện hay đưa tạm ứng đều đỏ đúng bằng số ấy —
  đỏ vì một lý do ai cũng biết, đúng thứ `I-021` mục *Why* nói sẽ dạy người dùng bỏ qua ngưỡng 0đ.
  Một hạng tử chung cho ba loại thay vì ba hạng tử: cả ba cùng chiều, cùng phương thức (tiền mặt),
  không loại nào bù chéo với doanh thu; tách ra không cho thêm lý do lệch nào đọc được mà danh sách
  từng khoản chưa cho.
- *Điểm 3.* `E46` cho nguồn **theo loại** (*điện, nước, wifi, xăng xe trả từ két*) và nói thẳng loại
  khác *chưa nói nguồn*. Đặt nguồn trên từng khoản thì mỗi lần ghi phải chọn lại một câu chủ quán đã
  trả lời một lần, và một lần chọn nhầm làm két lệch mà không loại nào sai. Đặt trên loại thì câu
  *nguồn của loại mới* buộc phải hỏi đúng lúc thêm loại — chỗ duy nhất nó còn mở.
- *Điểm 4.* Hai lời đều hợp lý — ngày tiền rời két, hay ngày người ghi khai — và chọn sai thì két
  lệch ở **hai** ngày ngược chiều. Giữ cả hai mốc rẻ hơn mọi cột đoán trước; cùng lý do **ADR-073**
  điểm 4 và 8.
- *Điểm 6.* Một migration không có luật để thi hành là chỗ cất sẵn (`ADR-035`).

**Rejected alternatives:**
- *Giữ `I-021` nguyên, coi khoản chi là chuyện của tiền mang về.* Bác: trái lời 2026-10-01.
- *Ba hạng tử riêng cho khoản chi, tạm ứng, thưởng.* Bác: lý do điểm 1.
- *Dấu nguồn tiền trên từng khoản chi.* Bác: lý do điểm 3; mở lại được nếu chủ quán nói một loại có
  lúc trả từ két, có lúc không.
- *Cột ngày bán của két, lấy mặc định từ lúc ghi.* Bác: chọn hộ `U-072`.
- *Câu đối chiếu rỗng giữ chỗ.* Bác: **F-017**, và bẫy `P2A-07` *lát còn bị chặn thì ghi vắng*.

**Suy ra, không phải lời chủ quán** (`CLAUDE.md` §7.2): một hạng tử chung thay vì ba; nguồn trên
loại; *loại không khai nguồn thì không tồn tại*; chi lặt vặt bằng tiền riêng là tiền hàng nên không
vào hạng tử (đọc từ `E45` · `E46` · *Giới hạn lời đáp* §8.10). Lời *trong ngày, trước lúc đếm két*
là **chủ repo** trả lời trong phiên bằng cách chọn phương án; phiên chưa được nói đó là lời chủ quán
chuyển lại — ghi đúng như thế ở §8.10.

**Applies to:** `quality/invariants.md` `I-021` · `I-028` · `I-029` ·
`docs/product/1-system-design/03-bao-ve-invariant.md` §1 · §5 ·
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` `YC-31` · `YC-32` · `YC-33` · §9.1 ·
`docs/product/1-system-design/architecture.md` §6.4 · `docs/product/0-ba/admin/01-ranh-gioi.md` ·
`master_plan/shop-facts.md` §8.7 · §8.10 · `docs/product/99-unknowns.md` U-072 · ADR-035 · ADR-046 ·
ADR-059 · ADR-073 · `work/findings.md` F-017 · F-048 · task `P2A-05` · `P2A-07`.

### ADR-075 — Khách trả nợ dần: mỗi lần trả một dòng mang số còn thiếu, các lần trả nối thành chuỗi bằng khoá ngoại

**Trạng thái:** **Đã chốt** 2026-10-01, **giao cho phiên** (Claude Code, task `T-126`) — không phải
lời chủ repo hay chủ quán (`CLAUDE.md` §7.2); chủ repo đổi được. Lời giao 2026-10-01 là *"giao những
việc còn lại cho codex và bạn kiểm tra"*. Hình dạng thử trên `postgres:17` dùng một lần trong phiên
trước khi viết: năm ca sai bị từ chối, lần trả đủ một lần như cũ vẫn ghi được.

**Context:**
Chủ quán chốt 2026-09-30 (đóng `U-063`, `master_plan/shop-facts.md` §6.14): *"có. pos sẽ ghi lại tổng
số nợ và ngày giờ trả nợ với số tiền còn thiếu."* Lược đồ của `P2-06` chỉ nhận **một** lần thu, bằng
**đủ** số nợ: `debt_collection_one_per_debt_key UNIQUE (bill_id)` và điều kiện
`cash_vnd + transfer_vnd = debt_vnd`. Ba luật quanh nợ đứng nguyên cho từng lần trả: doanh thu tính
ngày ghi nợ, lần trả chỉ là tiền về, két ngày trả thừa đúng số nợ cũ thu được (§6.14, `I-014`).

**Decision:**
1. **Mỗi lần trả là một dòng `debt_collection`**, mang như hôm nay: hoá đơn, bản soi số nợ, tiền mặt,
   chuyển khoản, lúc trả (`booked_at` — *ngày giờ trả* của lời chủ quán), ngày bán của lần trả,
   người bấm. Số trả của một lần **lớn hơn 0**.
2. **Hai cột mới: *còn thiếu trước lần này* và *còn thiếu sau lần này*.** Cột sau là con số chủ quán
   gọi *số tiền còn thiếu*; một điều kiện kiểm buộc *sau = trước − tiền mặt − chuyển khoản* và
   *sau ≥ 0*. Cột trước **để trống ở lần trả đầu**, và khi trống thì *trước* đọc là số nợ của hoá
   đơn. Cột sau mặc định **0** (*trả đủ*): lần trả thiếu mà quên khai thì điều kiện kiểm từ chối, nên
   mặc định không ghi sai được.
3. **Chuỗi do database giữ, không do mã ứng dụng:** lần trả đầu duy nhất cho mỗi hoá đơn (chỉ mục
   duy nhất có điều kiện *cột trước trống*); lần sau có *(hoá đơn, còn thiếu trước)* là khoá ngoại tới
   *(hoá đơn, còn thiếu sau)* của một lần trả có thật; *(hoá đơn, còn thiếu trước)* duy nhất nên hai lần
   trả không nối vào cùng một chỗ. Còn thiếu giảm nghiêm ngặt, nên chuỗi không vòng và tổng đã trả
   không bao giờ vượt số nợ.
4. **Không cột trạng thái.** *Đã trả xong* = hoá đơn có một lần trả còn thiếu 0; *còn nợ bao nhiêu* =
   còn thiếu nhỏ nhất của chuỗi, hoặc số nợ khi chưa lần trả nào — cùng luật *trạng thái đọc từ việc
   có dòng* của `04-luoc-do-duong-tien.md` §2.
5. **Đối soát:** hạng tử *nợ cũ thu* của công thức `I-021` · `I-005/3` đọc mỗi lần trả **mức nợ giảm**
   (*còn thiếu trước − còn thiếu sau*) ở vế công thức, và tiền mặt + chuyển khoản ở vế tiền thực nhận
   — hai nhóm cột khác nhau như hôm nay đọc `debt_vnd`, nên lỗi cài gỡ điều kiện kiểm vẫn làm câu kêu.
6. **Migration mới, không sửa file cũ** (`QC`, **ADR-065**); dòng đã có là lần trả đủ một lần ⇒ trước
   trống, sau 0. Bước lùi có khoá chặn: hoá đơn nào có hơn một lần trả hay một lần trả còn thiếu khác 0
   thì từ chối lùi.

**Why:**
- *Điểm 2.* Chủ quán nói POS **ghi** số còn thiếu; cất nó rồi buộc bằng điều kiện kiểm là đúng lời mà
  không mở chỗ cho hai đáp số (`QD-22`). Một cột tự tính (generated) cũng giữ được phép trừ, nhưng
  nó chạy theo mọi lần sửa tiền, nên lỗi cài `i005_3` (gỡ điều kiện, sửa chuyển khoản) không còn làm
  `I-005/3` kêu — mất một bằng chứng bộ đối chiếu biết kêu.
- *Điểm 3.* Một trigger cộng tổng đã trả phải khoá dòng hoá đơn để hai lần trả cùng lúc không cùng
  lọt; khoá ngoại và khoá duy nhất làm việc ấy ở tầng 1 mà không cần mã nào nhớ khoá.
- *Mặc định 0 ở điểm 2.* Giữ nguyên mọi lần ghi *trả đủ một lần* đang có ở test, ngày mẫu và scenario
  — ít đường ghi phải đổi nhất, và không đường nào ghi sai được.

**Rejected alternatives:**
- *Giữ một dòng mỗi khoản nợ, cộng dồn số đã trả vào nó.* Bác: sửa đè mất *ngày giờ từng lần trả*
  chủ quán đòi.
- *Không cất số còn thiếu, đọc bằng phép trừ.* Bác: không chặn được trả vượt ở tầng 1 nếu không có
  trigger, và trái chữ *ghi lại* của lời chủ quán.
- *Trigger kiểm tổng.* Bác: lý do điểm 3.
- *Cột trạng thái chưa trả · trả một phần · trả xong.* Bác: đường ghi thứ hai cho một sự thật đọc
  được từ chuỗi.

**Suy ra, không phải lời chủ quán** (`CLAUDE.md` §7.2): mỗi lần trả một dòng; tách *trước · sau*;
chuỗi bằng khoá ngoại; mặc định 0; *đã trả xong* đọc từ chuỗi. Lời chủ quán chỉ có: trả dần được,
POS ghi tổng nợ, ngày giờ trả và số còn thiếu.

**Applies to:** `docs/product/1-system-design/04-yeu-cau-du-lieu.md` `YC-02` ·
`docs/product/2-db/04-luoc-do-duong-tien.md` §2 · §5 · `db/reconcile/i005.sql` ·
`db/tests/yc02_debt_paid_in_parts.sql` · `master_plan/shop-facts.md` §6.14 · U-063 · ADR-059 ·
ADR-065 · task `T-126`.

---

### ADR-076 — Pha 3 có kế hoạch riêng ở `master_plan/`, mã bước `P3-XX`, sổ `work/backlog_BE.md`, và không bước nào mở trước chữ ký chuyển pha của chủ repo

**Trạng thái:** **Đã chốt** 2026-10-01, **giao cho phiên** (Claude Code, task `T-120`; Codex thi công
hai file kế hoạch, Claude duyệt). Chủ repo yêu cầu 2026-09-29: *"phase db đã xong hãy kiểm tra lại và
làm viết prompt để thực hiện pha tiếp theo. pha tiếp theo cần master plan, backlog, hay làm tất cả các
bước cần thiết để thực hiện"*; ngày 2026-10-01 giao làm tiếp bản dở. Câu ấy là lời **giao việc**, không
phải lời xác nhận cách chia bước dưới đây (`CLAUDE.md` §7.2). Bản nháp 2026-09-29 tự đặt số
`ADR-065` — số ấy đã thuộc quyết định đường lùi migration của `P2-09`, nên quyết định này mang số 076.
Quyết định **chép hình dạng** của **ADR-049** (kế hoạch pha 2) và **ADR-051** (một entry là hồ sơ thực
thi, trạng thái một nơi), và không sửa câu nào của **ADR-035** (ranh giới sở hữu theo pha).

**Decision:**

1. **Kế hoạch pha 3 ở `master_plan/BE_master_plan_banh_cuon_ba_thanh.md`**, không sở hữu sự thật nào:
   thứ tự · mức · đầu ra kiểm chứng được là của nó; trạng thái là của `work/backlog.md`; hợp đồng API là
   của pha 3 khi pha 3 viết ra. Kế hoạch **không nêu tên endpoint nào** — hàng *Hợp đồng API* của
   `CLAUDE.md` §2 còn *chưa có owner*.
2. **Mã bước `P3-01`…`P3-14`**, cùng hình `P1-XX` · `P2-XX`. Mô tả dài ở **`work/backlog_BE.md`**, khuôn
   entry của **ADR-051**; khối *Nhận việc* để trống tới khi mọi bước phụ thuộc `Done`.
3. **Chẻ theo nhóm mệnh đề** (giá · tại bàn · mang đi · tiền · sản xuất · vết), không theo nhóm endpoint:
   mỗi lát mang danh sách vế tầng 2 · tầng 3 của `03-bao-ve-invariant.md` và chấm bằng **test từ chối
   qua cửa**. Đây là chỗ phiên **suy ra**, kế hoạch §8 ghi nó chờ chủ repo xác nhận.
4. **Đầu ra:** tài liệu vào `docs/product/3-be/`, ra đời ở `P3-04` cùng hàng §2 *Hợp đồng API*; code
   vào `be/` (`QC-08` · `QC-09`), ra đời ở `P3-03`.
5. **Mảng admin không nằm trong pha 3** — nguồn **ADR-068** (*"pha 3 · pha 4 của admin không mở"*).
6. **`P3-01` chỉ nhận được sau khi chủ repo ký chuyển pha.** Đo 2026-10-01: pha 2 xong cả mười bốn bước
   (2026-09-30), cổng tick 12/12 ở `docs/product/2-db/11-cong-chat-luong-pha-2.md` §7 — đủ ô **không**
   phải chữ ký. Không dòng `P3-XX` nào vào *Ready* trước chữ ký ấy (**F-012**); phiên không tự ký.

**Why:**

- **Hình dạng đã chạy hai pha.** Kế hoạch sáu cột, cổng mỗi ô một cách chứng minh, và một entry là hồ sơ
  duy nhất — không bước pha 2 nào cần file prompt riêng, trạng thái đứng một nơi (T-119).
- **Pha 3 là pha dễ bịa luật nhất.** Mỗi nhánh điều kiện trong code là một luật; buộc mỗi lát chấm ngược
  vế tầng 3 của mình và bắt cửa **từ chối kèm mã** khi luật chưa có là cách rẻ nhất để câu chưa hỏi
  không thành code.

**Rejected alternatives:**

- *Thi công danh sách đường gọi ở `master_plan/prompt-fullstack.md` §3.6 như hợp đồng đã chốt.* Bác: nó
  viết trước lược đồ pha 2 và thiếu dấu lần gửi, quyền theo chỗ đứng, nợ trả dần, hoàn tiền, vết.
- *Viết sẵn bảng tầng 2 · tầng 3 dịch sang code trong kế hoạch.* Bác: đó là đầu ra của `P3-01`; bản nháp
  ở kế hoạch sẽ được đọc như bản chốt (cùng lý lẽ *Rejected alternatives* thứ ba của **ADR-050**).
- *Giữ finding "pha 2 vừa cấm vừa đòi file lùi" của bản nháp.* Bác: mâu thuẫn ấy đã được giải ở `P2-09`
  bằng **ADR-065** trước khi bản nháp được gộp; ghi lại thành finding mở là ghi một chuyện đã xong.

**Còn để lại:** cách chẻ mười bốn bước (điểm 3) chờ chủ repo xác nhận; **hợp đồng thắng hay code thắng**
khi lệch là ADR của `P3-04`, không suy ra từ **ADR-053**.

**Applies to:** `master_plan/BE_master_plan_banh_cuon_ba_thanh.md` · `work/backlog_BE.md` · `CLAUDE.md` §2
(hàng sổ pha 3; hàng *Hợp đồng API* trỏ sang kế hoạch) · `docs/product/00-index.md` (hàng *Pha 3*) · kế
hoạch pha 2 (đoạn cuối) · `work/backlog.md` · task `T-120`.
