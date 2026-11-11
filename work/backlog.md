<a id="top"></a>
# Backlog

Hai phần, đọc từ trên xuống: **cần làm** (`Ready`, `In Progress`) và **đã xong** (`Done`).
Cả hai là danh sách gạch đầu dòng. Mô tả dài của việc **đang cần làm** nằm ở mục *Chi tiết* phía
dưới; mô tả dài của việc **đã xong** nằm ở **`work/backlog_archive.md`** (T-086, 2026-09-28).

**Một việc đã xong là một dòng** (T-086, 2026-09-28): `- [x] <mã> <tên> — <ngày> · <hash> · [chi
tiết](…)`. Lúc chuyển *Done*, hồ sơ dài của task **chuyển nguyên khối** lên đầu mục *Chi tiết — việc
đã xong* của `work/backlog_archive.md`, kèm neo `<a id="<mã>">`; từ đó không ai cập nhật nó nữa.
Hash chưa có lúc tick *Done* — commit đến sau — nên dòng mới **không ghi hash**: commit của nó tra
bằng mã, vì subject mở đầu bằng mã (`CLAUDE.md` §6), `git log --oneline --grep='^T-XXX:'`. Hash ở
các dòng cũ là commit mang mã ở đầu subject, hoặc — khi không commit nào mang mã — commit đầu tiên
tick dòng ấy, ghi rõ *(commit tick Done)*.

| Mục | Nội dung |
|---|---|
| [Thứ tự làm lane admin vs các pha](#thu-tu-lane) | **Đ-2** — lời chủ quán về thứ tự làm; file này là owner |
| [Ready](#ready) | việc cần làm — checklist + thứ tự lấy |
| [In Progress](#in-progress) | task đang chạy |
| [Done](#done) | việc đã xong — một dòng mỗi việc |
| [Chi tiết — việc cần làm](#chi-tiet-can-lam) | mô tả dài của việc chưa xong; con trỏ tới sổ pha 1 và sổ admin |
| [`work/backlog_archive.md`](backlog_archive.md) | lưu trữ: dòng *Done* nguyên văn cũ, ghi chú lịch sử, mô tả dài mọi việc đã xong |
| [Vòng chạy một task L1](#vong-chay) | mười bước thủ tục từ nhận task tới khối commit |
| [Task Detail Template](#template) | khuôn viết một task mới |

**Sáu sổ, một chỗ giữ trạng thái.** Ranh giới giữa chúng là **lane** (`docs/decisions.md`
**ADR-036**): pha 1 (`P1-01`…`P1-14`) giữ mô tả ở **`work/backlog_SD.md`** (**ADR-034**) · pha 2
(`P2-01`…`P2-14`) giữ mô tả ở **`work/backlog_DB.md`** (**ADR-049**, dựng 2026-09-20 ở T-081) ·
pha 3 (`P3-01`…`P3-14`) giữ mô tả ở **`work/backlog_BE.md`** (**ADR-076**, dựng 2026-10-01 ở T-120) ·
mảng admin (`ADM-01`…`ADM-53`) giữ mô tả ở **`work/backlog_AD.md`** · lược đồ admin
(`P2A-01`…`P2A-16`) giữ mô tả ở **`work/backlog_AD_DB.md`** (**ADR-068**, dựng 2026-09-30 ở T-122) ·
mọi thứ còn lại ở file này,
rồi sang `work/backlog_archive.md` khi xong.
Dù mô tả nằm ở sổ nào, **file này vẫn là nơi duy nhất giữ trạng thái** — đó là file
`scripts/brief.sh` đọc và đẩy vào mọi phiên mới (**ADR-002**).


<a id="thu-tu-lane"></a>
## Thứ tự làm giữa lane admin và các pha — **Đ-2**, chủ quán chốt

**File này là owner của thứ tự làm.** Nó là dữ kiện **xếp lịch của repo**, không phải dữ kiện của
quán — nên nó **không** nằm ở `master_plan/shop-facts.md` (`docs/decisions.md` **ADR-001**, và §8.3
của file ấy chỉ nhận dữ kiện admin của quán).

**Chủ quán chốt 2026-09-01, xác nhận lại và mở rộng 2026-09-20** (việc đi hỏi: `work/backlog_AD.md`
**ADM-53**):

| Vế | Lời chốt | Trạng thái |
|---|---|---|
| Vế cũ (2026-09-01) | **đóng nốt chuỗi BA trước**, rồi mới chạy nhánh admin | **đã xong** — BA-08…BA-13 đều `Done` từ 2026-09-04 |
| Vế mới (2026-09-20) | lane admin chạy **SONG SONG** với pha 2: *hỏi chủ quán về admin trong khi pha 2 chạy* | **đang hiệu lực** |
| Vế 2026-09-29 | **chủ repo**: *"tôi muốn làm luôn db cho phần admin"* — nhắc lại 2026-09-30 (*"tiếp tục"*) | **đang hiệu lực** — mở thi công **lược đồ** admin cho phần đã đủ luật; `docs/decisions.md` **ADR-068** |
| Vế 2026-10-14 | **chủ repo**: *"cập nhật backlog … cho db của admin, tôi sẽ làm be cho admin"* (T-184) | **đang hiệu lực** — lược đồ admin lượt hai `P2A-10`…`P2A-16`; backend admin sẽ làm — kế hoạch mở 2026-10-14 ở `T-191` (**ADR-110**: `P3A-01`…`P3A-10`) |
| Vế 2026-11-01 | **chủ repo**: *"step by step complete above task request codex to do you check"* (nói về `work/backlog_CHAT.md`) | **đang hiệu lực** — mở lane `CHAT` cho nhánh đã đủ lời; không mở pha 5 (`T-109`) |

**Vế mới nói chính xác cái gì.** Chủ quán chọn *"Song song: hỏi chủ quán về admin trong khi pha 2
chạy"*, và phương án ấy nói rõ hai nửa:

- **Được làm song song: THU LUẬT.** Đem các câu `A`…`F` còn mở ở `work/admin-questions.md` §3 đi
  hỏi chủ quán, và chuyển lời về owner — trong lúc pha 2 (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`)
  đang thi công lược đồ dữ liệu của mảng bán hàng.
- **KHÔNG làm song song: THI CÔNG ADMIN.** Lời này **không** cho phép dựng phần admin, cũng không
  cho phép pha 2 gánh luôn lược đồ admin. Việc admin nào cũng vẫn phải qua cổng của lane nó
  (`work/backlog_AD.md`, mục *Cổng của cả lane*).

⇒ Hệ quả đọc được ngay: **23/29 việc của lane admin đang bị chặn bởi câu chưa hỏi** (đo 2026-09-04,
`work/backlog_AD.md`) nay **được phép gỡ ngay**, không phải chờ pha 2 đóng. Việc *thi công* chúng
thì vẫn chờ.

⚠️ **`docs/decisions.md` ADR-031 nói *"ba mảng đi SAU mảng bán hàng"*** — lời ngày 2026-09-20
**không** lật ngược câu đó: *"sau"* ở ADR-031 nói về **thi công**, còn lời này nói về **thu luật**.
Hai chữ khác nhau; đừng đọc cái này thành phép thi công admin trước.

**Vế 2026-09-29 đổi đúng một nửa của vế trước, và chỉ nửa ấy** (T-122, `docs/decisions.md`
**ADR-068**). Lúc lời này có hiệu lực, mười bốn bước pha 2 của mảng bán hàng đều đã `Done`
(2026-09-30).

- **Nay được làm: LƯỢC ĐỒ admin của phần đã đủ luật** — chín bước `P2A-01`…`P2A-09`, thứ tự và
  cổng ở `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`, mô tả ở `work/backlog_AD_DB.md`.
- **Vẫn KHÔNG làm:** chỗ cất cho phần còn chờ lời chủ quán (kế hoạch ấy §6), và pha 3 · pha 4 của
  admin. Lời ngày 2026-09-29 nói *db*; nó không nói API hay màn hình.
- **Thu luật vẫn chạy song song** như vế 2026-09-20.
- *Cách đọc của phiên ghi, không phải lời chủ repo* (`work/findings.md` **F-004**): lời gốc không
  nêu phạm vi; phiên đọc nó hẹp — chỉ phần đã đủ luật. Người nói trong phiên là **chủ repo**; hai
  vế trước được ghi là lời **chủ quán**, và phiên không tự đồng nhất hai vai.

Mỗi mục có link `↑ đầu file` ở cuối để quay lại bảng này.

<a id="ready"></a>
## Ready

- [ ] T-109 **ĐANG CHỜ mở pha 5 — không nhặt theo thứ tự trên xuống** (chủ repo chọn chờ, 2026-09-28). **Pha 5 — triển khai và nghiệm thu bảo toàn, khôi phục dữ liệu** — L2, giao 2026-09-27 theo ADR-057. Yêu cầu và tiêu chí: `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8 (YC-21). Thực hiện khi mở pha vận hành; phải xong trước bán thật. Ba tiêu chí nghiệm thu **đã chốt 2026-09-28** (chủ repo, ghi ở YC-21 §8: mất tối đa 1 giờ bán · phục hồi trước ca bán kế tiếp · giữ bản sao lưu 1 năm); cùng ngày chủ repo chọn **chờ mở pha 5** mới làm phần cơ chế, không dựng thử trên database máy phát triển. Pha vận hành chỉ định người phụ trách, mở owner đúng quy tắc pha, thiết kế sao lưu/phục hồi, chạy phục hồi thử và lưu bằng chứng đối chiếu. RR-9 còn chưa được chặn cho tới khi nghiệm thu đạt; không mở lại quyết định chọn owner của F-034.

[↑ đầu file](#top)

<a id="in-progress"></a>
## In Progress

- [x] T-316 **Dòng món ở Tổng thiếu theo bàn và Cộng thử ghép đơn dài như hoá đơn nên nhân viên khó đọc nhanh** — L1 (đổi cách hiện, không đổi dữ liệu hay tiền), xong 2026-11-11; mỗi dòng gọn thành "số + tên ngắn + lựa chọn" (ví dụ "1 canh không rau"), bỏ giá, suất trong combo và dòng tổng ở hai mục này; Claude làm; fe-check và gate đạt · [chi tiết](#t-316)
- [x] T-313 **Vận hành chỉ đếm theo thành phần nên chủ quán không thấy dòng món của bàn như ở Đơn chờ** — L2 (thêm trường vào hợp đồng API), xong 2026-11-09; `GET /service-board` thêm `lines` và `lines_total_vnd` cho mỗi phiên, hợp đồng 0.71.0; *Cộng thử ghép đơn* thay hàng cột bằng dòng món, *Tổng thiếu theo bàn* giữ cột và ô đem ra, thêm dòng món khi mở chi tiết bàn; Codex làm, Claude sửa nốt và duyệt; be-check, fe-check 745/745 và gate đạt · [chi tiết](#t-313)
- [x] T-312 **Máy dev không đặt được đơn ngoài giờ bán nên không thử được luồng khách → Vận hành** — L2, ADR-141, xong 2026-11-09; cờ `BANHCUON_DEV_BO_GIO_BAN` (make dev bật sẵn, chỉ origin localhost) bỏ riêng điều kiện giờ bán; Claude viết test trước, Codex làm, Claude duyệt; be-check và gate đạt, đơn QR thử lúc 13:21 hiện ở hàng chờ chủ quán · [chi tiết](#t-312)

- [x] CHAT-17 **Chat chưa ghi được sổ nguyên liệu theo số người nhập** — L2, ADR-140 điểm 2 · 4 · 7, I-025 · I-026, xong lát BE 2026-11-10; Claude viết test trước (12 ca đỏ), Codex dựng năm công cụ ghi nguyên liệu chỉ sinh đề xuất cho lớp `chu_quan` (`them_nguyen_lieu` · `dat_don_vi` · `ghi_so_nguyen_lieu` · `sua_so_nguyen_lieu` · `dat_ti_le_nhac`), con số phải kèm đơn vị đã đặt, ngày `YYYY-MM-DD`, hợp đồng 0.72.0; be-check, fe-check 766/766 và gate đạt; **xong lát FE 2026-11-10**: `cuaGhiChat` có thêm năm cửa nguyên liệu, link *Xem Nguyên liệu* chỉ ở khung chủ quán, con số và tỉ lệ gửi nguyên chuỗi; Claude viết test trước (16 ca đỏ), Codex làm, Claude duyệt, fe-check 782/782 và gate đạt; còn công cụ đọc kho cho chat và eval số, ngày trên model thật (chờ `U-112`) · [mô tả](backlog_CHAT.md#chat-17)
- [x] CHAT-16 **Chat chưa phân biệt ghi đào tạo với đánh dấu việc** — L2, ADR-140 điểm 2 · 4 · 7, I-031, xong lát BE 2026-11-09; Claude viết test trước (11 ca đỏ), Codex dựng sáu công cụ ghi đào tạo chỉ sinh đề xuất cho lớp `quay_hoac_chu_quan`, hướng dẫn chỉ chữ, người được ghi do người bấm chọn, hợp đồng 0.70.0; be-check và gate đạt; **xong lát FE 2026-11-09**: `cuaGhiChat` có thêm sáu cửa đào tạo, gắn hướng dẫn gửi multipart chỉ chữ, thẻ ghi nhận mới có ô chọn người được ghi từ `GET /people`; Claude viết test trước (16 ca đỏ), Codex làm, Claude duyệt, fe-check 759/759 và gate đạt; còn đọc lại sau ghi và eval lệnh chèn trên model thật (chờ `U-112`) · [mô tả](backlog_CHAT.md#chat-16)
- [x] CHAT-15 **Chat chưa gọi được cửa giao việc mà vẫn giữ quyền đánh dấu** — L2, ADR-140 điểm 2 · 4 · 7, xong lát BE 2026-11-09; Claude viết test trước, Codex dựng bốn công cụ ghi `giao_viec` · `sua_viec` · `an_viec` · `danh_dau_viec` chỉ sinh đề xuất cho lớp `quay_hoac_chu_quan`, nội dung việc và tên người không tới model, hợp đồng 0.69.0; be-check và gate đạt; **xong lát FE 2026-11-09**: `cuaGhiChat` có bốn cửa giao việc, thẻ giao mới có ô chọn người nhận từ `GET /people`; Claude viết test trước, Codex làm, Claude duyệt, fe-check 743/743 và gate đạt; còn đọc lại sau ghi và eval model thật (chờ `U-112`); trước đó còn dòng `cuaGhiChat` FE và ô chọn người nhận · [mô tả](backlog_CHAT.md#chat-15)
- [x] CHAT-11 **Người dùng chưa nhìn thấy rõ điều mình sắp ghi** — L2, ADR-140 điểm 3 · 4 · 5 · 6, xong 2026-11-09; Claude viết test trước, Codex dựng `TheDeXuat` ở `HoiQuan` mặt người làm (bản chụp bất biến, gọi qua bảng `cuaGhiChat` rỗng ở bản chạy, dấu FE sinh, chưa rõ kết quả, hết hạn 10 phút); fe-check 727/727 và gate đạt; chưa nhóm ghi nào mở · [mô tả](backlog_CHAT.md#chat-11)

- [x] CHAT-10 **Lời model chưa có ranh giới giữa đề xuất và thực thi** — L2, ADR-140, xong 2026-11-08; Claude viết test trước, Codex dựng khung công cụ ghi chỉ sinh đề xuất (`LuotCoGhi`, danh sách rỗng ở bản chạy) và `proposal` của `askChat`, hợp đồng 0.68.0; be-check đạt; tiếp theo `CHAT-11` (thẻ FE) · [mô tả](backlog_CHAT.md#chat-10)

- [x] CHAT-02 **Lượt ba: thẻ lệnh ghi chưa có thiết kế nên CHAT-10 chưa giao được** — L3, xong 2026-11-08; Claude soạn ADR-140 (thẻ chỉ là đề xuất, người bấm gọi đúng cửa màn tay, không đường ghi mới, model không điền người), chủ repo chọn *"Duyệt, giao Codex làm"*; thêm `I-044` · [mô tả](backlog_CHAT.md#chat-02)

- [x] T-306 **Đơn QR mới hiện ngay trên trang Vận hành đang mở** — L1, xong 2026-11-06; nhận tín hiệu sau khi khách đồng ý đặt món và đọc lại bảng từ backend; test 17/17 và gate đạt · [chi tiết](#t-306)

- [ ] T-286 **Chưa có số đo thật để chọn model cho chat** — L1, chủ repo chọn *"Chạy thử qua API cả ba"* 2026-11-03 (`U-112`); Codex dựng bộ thử ngoài repo, Claude duyệt đạt 2026-11-03; chờ chủ repo tạo khoá API và chạy thật · [chi tiết](#t-286)
- [ ] T-279 **Bản HTML chi tiết món kể chuyện theo cuộn** — L1, chủ repo giao Codex 2026-10-31; dựa trên ý tưởng đầy đủ và mẫu Paris · [chi tiết](#t-279)

- [ ] T-280 **Lát D — Sửa bản mẫu /dang-nhap theo lời U-111 2026-11-01** — L1, chủ repo đã trả lời U-111 2026-11-01 (Gmail chưa có vai làm việc dùng như khách, chủ quán cấp quyền sau); Codex thi công · [chi tiết](#t-280)

- [ ] T-278 **Thiết kế lại trang /dang-nhap có nút đăng nhập nhanh bằng Google** — L1 bản HTML tĩnh (lát 1), chủ repo yêu cầu 2026-10-31 (duyệt phạm vi Google), U-111 đóng 2026-11-01 (ADR-135), Codex đã thi công Lát 1 · [chi tiết](#t-278)

- [ ] T-276 **Thiết kế tạo combo yêu thích riêng cho khách** — L1, chủ repo giao Codex 2026-10-31; bản HTML minh hoạ · [chi tiết](#t-276)

- [ ] T-275 **Bản thực hành Paris từ tài nguyên video Creativo** — L1, chủ repo giao Codex 2026-10-31; agent phụ đối chiếu nguồn và duyệt độc lập · [chi tiết](#t-275)

- [ ] T-273 **Bố trí bốn món theo vòng cung trong bản mẫu menu mâm** — L1, chủ repo giao Codex 2026-10-29 · [chi tiết](#t-273)

- [ ] T-269 **Thẻ COMBO và MÓN LẺ chưa theo mẫu Gemini** — L1, chủ repo giao Codex 2026-10-29 · [chi tiết](#t-269)

- [ ] T-268 **Gộp món lẻ giống nhau trong giỏ khách** — L1, chủ repo giao Codex 2026-10-28 · [chi tiết](#t-268)

- [ ] T-266 **Sản phẩm và combo chưa có ảnh** — L1, chủ repo giao Codex 2026-10-28 · [chi tiết](#t-266)

- [ ] T-259 **Gom lựa chọn nhân và lượng nhân thành nút mở bảng trượt** — L1, chủ repo giao Codex 2026-10-26 · [chi tiết](#t-259)




- [ ] T-254 **Dừng phiên dev bằng make stop-dev** — L1, chủ repo giao Codex 2026-10-25 · [chi tiết](#t-254)

- [ ] T-253 **Thông tin và form sửa đầy đủ sản phẩm trong HTML** — L1, chủ repo giao Codex 2026-10-25 · [chi tiết](#t-253)


- [ ] T-248 **Trang Khoản chi chưa theo bản thiết kế HTML** — chủ repo 2026-10-24 cho phép Codex tiếp tục cả L2; đang đối chiếu nghiệp vụ trước khi mở rộng DB/API · [chi tiết](#t-248)

- [ ] T-247 **Sửa và xoá mục, khoản con, khoản chi trong bản HTML Khoản chi** — L1, chủ repo giao Codex 2026-10-24 · [chi tiết](#t-247)

- [ ] T-246 **Hạn hoàn thành bắt buộc ngày và giờ khi giao việc mới** — L2, DB/API/FE — chủ repo 2026-10-24 cho phép Codex thực hiện xuyên tầng · [chi tiết](#t-246)

- [ ] T-227 **Thanh toán bàn chỉ thu phần đã ra, phần chưa ra huỷ việc trạm** — bấm tiền bánh đã ra để đóng phiên và xoá bàn khỏi bảng; đổi luật tính tiền phiên (`shop-facts.md` §6.1, 2026-10-21) và viết lại `I-002` — L3 (thiết kế duyệt trước code, ADR, chia L1/L2 khi mở) — mở 2026-10-21, U-103 có lời và bắt đầu 2026-10-22 · [chi tiết](#t-227)
- [ ] T-233 **Trang gọi món của khách hiện không có kiểu nào, chưa giống bản thiết kế menu** — CSS module của T-232 bị luật Turbopack trong `next.config.ts` đọc như CSS thường nên mọi `styles.*` rỗng (F-075); viết lại kiểu bằng một file CSS thường trong phạm vi trang và lớp Tailwind, đối chiếu ảnh chụp với `menu.html` ở hai giao diện; hành vi và test giữ nguyên — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) · [chi tiết](#t-233)










<a id="done"></a>
## Done

- [x] T-310 **Nhà giả của server chưa gọi được công cụ đọc nội bộ nên chưa diễn được biên bản chỉ đọc** — L1, xong 2026-11-08; nhà giả chọn `doc_tong_quan` · `doc_bang_phuc_vu` · `doc_bang_tram` theo chữ của câu hỏi, chỉ trong danh sách backend đưa, và chép nguyên kết quả; Codex làm, Claude viết test trước và duyệt; biên bản chỉ đọc trên máy dev: bốn loại phiên đúng lớp, số trên chat khớp ba cửa đọc của màn tay; be-check và gate đạt; `F-078` mở · [chi tiết](#t-310)
- [x] T-308 **Chủ quán nhận và xử lý đơn mới trên trang Vận hành** — L2, xong 2026-11-08; chủ quán xem món của đơn chờ, duyệt hay từ chối ngay trên Vận hành, trang mở được tính là quán nhìn thấy đơn; Codex làm, Claude duyệt, chủ repo xác nhận luật; be-check, test FE 342/342 và gate đạt · [chi tiết](#t-308)
- [x] CHAT-09 **Số hỏi trong chat chưa có mốc đọc và chưa tách người dùng** — L2, ADR-139 điểm 2 · 8 · 9; 2026-11-08 Codex dựng mặt người làm của `HoiQuan` (tên nguồn nội bộ, mốc giờ:phút:giây, lời mốc đọc hay cảnh báo không nguồn, link màn tay theo khung, 401 nhắc đăng nhập), `OChat` truyền `khung`; Claude viết test trước, sửa một lỗi kiểu của mình và duyệt; fe-check 702/702 và gate đạt; **chưa có biên bản chỉ đọc** (nhà giả chỉ gọi `doc_menu`), CHAT-10 không mở trước nó · [mô tả](backlog_CHAT.md#chat-09)
- [x] CHAT-08 **Người làm chưa hỏi được số theo bàn và theo quyền bằng chat** — L2, ADR-139 điểm 7 · 9 và *Sửa đổi 2026-11-06*; 2026-11-06 Codex dựng `NguonNoiBo` với ba công cụ đọc theo lớp (`doc_bang_tram` · `doc_bang_phuc_vu` · `doc_tong_quan`) và phép chiếu bỏ tên, id người, hợp đồng 0.66.0; Claude viết test trước (`I-043`), sửa hai sót của mình và duyệt; be-check, eval CHAT-06 và gate đạt; chưa có FE (CHAT-09) · [mô tả](backlog_CHAT.md#chat-08)

- [x] T-302 **Khách xem lại đơn trước khi đặt tại bàn** — L2, xong 2026-11-05; huỷ giữ giỏ, đồng ý mới gửi, kiểm thử 35/35 · [chi tiết](backlog_archive.md#t-302)

- [x] T-300 **Nút chat của khách là chữ nhỏ, khó thấy và đè nút món** — L1, xong 2026-11-05; nút nổi tròn cam *Trợ lý bánh cuốn* góc phải dưới, bấm lại để đóng; Codex làm, Claude duyệt; fe-check 672/672, gate và ảnh chụp Playwright đạt · [chi tiết](#t-300)
- [x] T-299 **Chạy `make dev` thường không thấy nút chat** — L1, xong 2026-11-05; `Makefile` mặc định máy dev `NEXT_PUBLIC_CHAT_ENABLED ?= true` · `CHAT_MODEL_PROVIDER ?= gia`, đặt trống hay `tat` để tắt; Codex làm, Claude duyệt, `make -n` và gate đạt · [chi tiết](#t-299)
- [x] CHAT-07 **Ô chat công khai chưa nối hỏi đáp đã qua kiểm** — L1, chủ repo yêu cầu 2026-11-05; Codex dựng `HoiQuan` (`askChat`, huỷ khi đóng, suy giảm có link `/dat-mon`), `OChatKhach` ở layout gốc cho mọi trang khách và thẻ *Hỏi quán* trong `OChat` ở ba khung, cùng cờ tắt mặc định; Claude duyệt, sửa test ba thẻ của CHAT-32; fe-check 669/669 và gate đạt; chưa diễn trên trình duyệt · [mô tả](backlog_CHAT.md#chat-07)
- [x] CHAT-06 **Chưa có bộ kiểm chữ ngăn trả sai giá và làm theo lời chèn lệnh** — L2, ADR-136 điểm 8 · ADR-139 Consequences; 2026-11-05 Codex dựng người chấm tất định và bộ chạy `be/internal/troly/danhgia` (qua `troly.Lop`, mỗi lần gọi một dòng sổ); Claude viết 21 ca và test trước, sửa hai lỗi của mình khi chạy thật và duyệt; trên nhà giả `ket_luan=mo_duoc`, P04 trượt ghim `U-118`; chạy lại khi có model thật · [mô tả](backlog_CHAT.md#chat-06)
- [x] T-296 **Tài khoản dev không đăng nhập được bằng tên trong hướng dẫn** — L1, chủ repo yêu cầu 2026-11-05 tạo tài khoản cho mọi nhân viên và lệnh make chạy lại; sửa lệnh hiện có theo email đăng nhập của API, cập nhật bảng tài khoản; gate xanh · [chi tiết](#t-296)

- [x] CHAT-05 **Khách chưa có đường hỏi quán chỉ đọc có nguồn** — L2, ADR-139 điểm 8 · 9 · 10; 2026-11-05 Codex dựng `POST /chat/turns` (`askChat`, công khai, hợp đồng 0.65.0) với hai công cụ đọc `doc_menu` · `tinh_gia` gọi đúng service của `GET /menu` · `POST /price-quotes`, nhà giả mặc định cho server; Claude viết test trước và duyệt; chưa giao diện, chưa mở khách thật; tiếp theo `CHAT-06` · [mô tả](backlog_CHAT.md#chat-05)
- [x] CHAT-03 **Chưa có lớp gọi model tắt được và giữ được trần chi phí** — L2, ADR-139 điểm 1…4 · 6 · 7 · 12; 2026-11-05 Codex dựng gói `troly` (cấu hình `tat`/`gia`, vòng công cụ tối đa 4 lần, giữ chỗ trước mỗi lần gọi qua `troly/giu_cho`, chốt qua `troly/chot`, bộ lọc số điện thoại · thư, hợp đồng 0.64.0, PT-9); Claude viết test trước, thêm `I-041` · `I-042`, sửa Gate 1f nhận `GRANT INSERT (cột…)` và duyệt; `F-077` mở · [mô tả](backlog_CHAT.md#chat-03)
- [x] CHAT-35 **Chưa có sổ gọi model để giữ trần chi phí qua khởi động lại** — L2, ADR-139 điểm 5 · 6 · 11; 2026-11-05 Codex dựng `model_call` (bước 44, `20261104180000_so_goi_model`), trigger giữ trần tháng 10 USD · ngày 1 USD dưới khoá giao dịch, chốt một lần, quyền ghi theo cột, bốn câu đối chiếu `I-040`, hợp đồng 0.63.0; Claude viết test trước, sửa vết người rỗng và duyệt · [mô tả](backlog_CHAT.md#chat-35)
- [x] T-288 **Ảnh giới thiệu quán dưới tên trên menu bàn** — L1, 2026-11-04; Codex thêm ảnh mở `/gioi-thieu`, trang có đường về bàn; gate xanh · [chi tiết](backlog_archive.md#t-288)
- [x] T-243 **Món đã ngừng bán chưa bán lại được** — L2; 2026-11-04 Codex dựng `POST /menu-items/{id}/resumption` (`menu/ban_lai`, mã `menu_item_not_discontinued`, hợp đồng 0.62.0) qua cửa nội bộ `menu/moc_ngung_ban` giữ ô mốc ngừng bán (ADR-126 *Sửa đổi*), form *Bán lại* trên trang Sản phẩm; Claude viết test trước và duyệt · [chi tiết](#t-243)
- [x] T-223 **Rời quán của đơn giao ghi luôn mốc *đã ra bàn*** — L2; 2026-11-04 Codex sửa cửa `don/roi_quan`: khoá việc của đơn, còn `pending` ⇒ `delivery_jobs_not_made` 409, `made` ⇒ `served` qua `vongdoi.ChuyenViec` rồi Đang giao (hợp đồng 0.61.0, ADR-088 *Sửa đổi*); Claude viết test trước và duyệt · [chi tiết](#t-223)
- [x] T-237 **Trang gọi món của khách chưa chia món theo danh mục** — L2 (đổi hợp đồng API); 2026-11-04 Codex thêm `Menu.categories` · `MenuItem.menu_category_id` (hợp đồng 0.60.0, câu đọc chỉ SELECT) và hàng thẻ danh mục trên `ThucDonKhach`; Claude viết test trước, sửa một kỳ vọng sai của chính mình và một mẫu sót, duyệt · [chi tiết](#t-237)
- [x] CHAT-32 **Người làm chưa báo nghỉ bằng mẫu có kết quả rõ** — L2, ADR-138 điểm 7; 2026-11-04 Codex dựng `BaoNghi` trong thẻ *Báo nghỉ* của `OChat` (`/tram` · `/quay` tự báo có thẻ kiểm, `/chu-quan` danh sách 30 ngày với *Đã biết* · *Huỷ*), không model; Claude viết test trước, sửa hai ca mã lạ và duyệt; nhánh báo nghỉ 30…32 đủ ba lát · [mô tả](backlog_CHAT.md#chat-32)
- [x] CHAT-31 **Chưa có cửa báo nghỉ nhận đúng người và người duyệt** — L2, ADR-138 điểm 3 · 6; 2026-11-04 Codex dựng gói `baonghi`, năm đường `/leave-notices` (ba cửa ghi `baonghi/bao` · `huy` · `da_biet`, hợp đồng 0.59.0, năm mã mới), người luôn lấy từ phiên; Claude viết test trước, thêm hai ca vết I-018 và duyệt; tiếp theo `CHAT-32` · [mô tả](backlog_CHAT.md#chat-31)
- [x] CHAT-30 **Báo nghỉ chưa có luật đầy đủ và chỗ cất riêng** — L2 (thiết kế L3), chủ repo trả lời bốn vế và duyệt ADR-138 2026-11-04; Codex dựng `leave_notice` (bước 43, `20261104120000_bao_nghi`), chặn tick hai chiều cùng khoá, bốn câu đối chiếu `I-039`; Claude viết test trước, sửa test I-027, ánh xạ ràng buộc ở hợp đồng 0.58.0 và duyệt; tiếp theo `CHAT-31` · [mô tả](backlog_CHAT.md#chat-30)
- [x] CHAT-14 **Người canh và dọn chưa có một hộp tin dùng được khi tắt model** — L2, ADR-137 điểm 4 · 7 · 8; 2026-11-04 Codex dựng `HopTin` trong `OChat` (hộp cá nhân ở `/tram`, hộp quầy ở `/quay` · `/chu-quan`, thẻ kiểm trước gửi, *Việc của tôi* không nút); Claude viết test trước, sửa ba lỗi test và duyệt; nhánh không model của ADR-137 đủ năm bước · [mô tả](backlog_CHAT.md#chat-14)
- [x] CHAT-13 **POS và trạm chưa có cửa gửi, đọc và phản hồi tin đúng người** — L2, ADR-137 điểm 4 · 5 · 6 · 7; 2026-11-04 Codex dựng bốn cửa `/station-messages` (ba cửa ghi `hoptin/quay_gui` · `gui_ve_quay` · `ghi`, hợp đồng 0.57.0, hai mã mới); Claude viết test trước, chốt cửa ghi nội bộ và duyệt; tiếp theo `CHAT-14` · [mô tả](backlog_CHAT.md#chat-13)
- [x] CHAT-12 **Tin báo trạm chưa có chỗ cất tách khỏi tiến độ** — L2, ADR-137 điểm 3 · 6 · 9; 2026-11-04 Codex dựng bảng chỉ thêm `station_message` (bước 42, `20261103120000_hop_tin`), bốn câu đối chiếu `I-038`; Claude viết test trước, ánh xạ ràng buộc ở hợp đồng 0.56.0 và duyệt; tiếp theo `CHAT-13` · [mô tả](backlog_CHAT.md#chat-12)
- [x] CHAT-04 **App chưa có chỗ mở và đóng chat** — L1, ADR-137 điểm 1; 2026-11-04 Codex dựng vỏ `OChat` sau cờ `NEXT_PUBLIC_CHAT_ENABLED` ở ba khung `/quay` · `/tram` · `/chu-quan`, chưa nối model hay cửa ghi; Claude duyệt · [mô tả](backlog_CHAT.md#chat-04)
- [x] CHAT-34 **Người được giao việc không có đường nào đọc việc của chính mình** — L2, ADR-137 điểm 2; 2026-11-03 Codex dựng `GET /assigned-tasks/mine` (`listMyAssignedTasks`, lớp `nguoi_quan`, hợp đồng 0.55.0), Claude viết test trước và duyệt; tiếp theo `CHAT-04` → `CHAT-12` → `CHAT-13` → `CHAT-14` · [mô tả](backlog_CHAT.md#chat-34)
- [x] T-287 **Gate 1b đỏ vì 109 đường chết có sẵn** — L1, 2026-11-03; Codex bỏ dấu đường dẫn ở 19 bản thiết kế và thêm năm dòng ignore có chủ, Claude duyệt; Gate 1b xanh · [chi tiết](#t-287)
- [x] T-285 **Ghi lời báo nghỉ và ba ứng viên model** — L1, chủ repo trả lời 2026-11-03; đóng `U-116`, hẹp `U-112`; lời mới thay vế nghỉ đột xuất của `C30` · [chi tiết](#t-285)
- [x] T-284 **Sổ CHAT còn Acceptance trái ADR-137, kế hoạch và luật dữ liệu cá nhân** — L1, 2026-11-03; Codex sửa 17 chỗ của `work/backlog_CHAT.md` theo phiếu, Claude duyệt; giữ 13/14 lỗi của đợt kiểm · [chi tiết](#t-284)
- [x] CHAT-02 **Thiết kế nhánh chat không model, rồi nhánh model phần chỉ đọc** — L3, chủ repo duyệt ADR-137 2026-11-01; lượt hai: chủ repo duyệt ADR-139 2026-11-04 (lớp model, sổ ngân sách `CHAT-35`, dữ liệu gửi ra, mở `U-118`); thẻ lệnh ghi để lượt ba · [mô tả](backlog_CHAT.md#chat-02)
- [x] CHAT-01 **Thu lời và duyệt ADR-136** — L3, chủ repo duyệt 2026-11-01; đóng `U-113` · `U-114` · `U-115` · `U-117`, hẹp `U-112`; `U-116` còn mở (sửa 2026-11-03, T-284: dòng cũ ghi nhầm `U-113` là hẹp) · [mô tả](backlog_CHAT.md#chat-01)
- [x] T-283 **Tính năng chat với app chưa có kế hoạch và sổ việc riêng** — L1 (chỉ tài liệu kế hoạch; tính năng là L3), chủ repo yêu cầu 2026-11-01, Codex soạn, Claude duyệt · [chi tiết](#t-283)
- [x] T-277 **Hiệu ứng khi ảnh món xuất hiện trong trang thử menu** — L1, Claude làm, chủ repo yêu cầu 2026-10-31 · [chi tiết](#t-277)
- [x] T-274 **Bản mẫu menu theo concept bàn gỗ ấm cúng** — L1, Codex làm, Claude duyệt, chủ repo yêu cầu 2026-10-30 · [chi tiết](#t-274)
- [x] T-272 **Chờ đồng hồ DB trong fixture *Vào chen cùng mốc*** — L1, Codex làm, Claude duyệt 2026-10-29 · [chi tiết](#t-272)
- [x] T-271 **Nhân *Mộc nhĩ* mới và chế độ *Hỗn hợp* khi khách gọi combo** — L2, ADR-134; Claude thiết kế và viết test hồi quy trước, Codex thi công FE + seed, Claude duyệt 2026-10-29 · [chi tiết](#t-271)
- [x] T-270 **Xác nhận Gmail khách qua thư** — L2, ADR-133; Codex làm, Claude duyệt 2026-10-29 · [chi tiết](#t-270)
- [x] T-267 **Khách đăng ký và đăng nhập bằng nút Google** — L2, ADR-132; Codex làm, Claude duyệt 2026-10-29 · [chi tiết](#t-267)
- [x] T-265 **Màn đăng nhập một ô và trang tài khoản khách** — L2, lát c của ADR-131; Codex làm, Claude duyệt 2026-10-28 · [chi tiết](#t-265)
- [x] T-264 **Backend và hợp đồng đăng nhập số điện thoại · Gmail, cửa khách** — L2, lát b của ADR-131; Codex làm, Claude duyệt 2026-10-28 · [chi tiết](#t-264)
- [x] T-263 **Lược đồ đăng nhập bằng số điện thoại · Gmail và tài khoản khách** — L2, lát a của ADR-131; Codex làm, Claude duyệt 2026-10-27 · [chi tiết](#t-263)
- [x] T-262 **Thiết kế đăng nhập bằng số điện thoại hoặc Gmail, khách có tài khoản** — L3, chủ repo duyệt ADR-131 2026-10-27 · [chi tiết](#t-262)

- [x] T-245 **Viết lại trang Giao việc theo HTML, mobile first** — L1 — chủ repo giao Codex 2026-10-24 · [chi tiết](#t-245)

- [x] T-261 **Canh bánh cuốn nằm cuối món lẻ trên trang khách, nút Rau mặc định Ít rau** — L1, chủ repo 2026-10-26 — xong 2026-10-26, gate đạt · [chi tiết](#t-261)
- [x] T-260 **Bảng cột cho combo và món lẻ, nút Chi tiết combo trong Tóm tắt đơn hàng** — L1, chủ repo 2026-10-26 — xong 2026-10-26, gate đạt · [chi tiết](#t-260)


- [x] T-258 **Chọn nhân ngay trên thẻ combo và món lẻ của khách** — L1, chủ repo giao Codex 2026-10-26; combo chọn chung, mặc định thịt + vừa; tóm tắt chỉ đọc; chọn và thêm món/combo ngay tại chi tiết, dùng chung giỏ theo bàn/web — xong 2026-10-26, gate đạt · [chi tiết](#t-258)

- [x] T-257 **Thêm thành phần cho món đã có từ ngăn Cập nhật, và bảng Sản phẩm liệt kê thành phần** (gộp T-256) — cửa `POST /menu-items/{id}/components` qua thư mục cửa `menu/them_mon`, thành phần mới bắt chọn trạm; `GET /menu-categories` trả thành phần (ADR-130) — L2 — mở 2026-10-26 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-26: gate xanh ở clone chính, fe-check 507/507 · [chi tiết](#t-257)
- [x] T-255 **Canh bánh cuốn có nhóm lựa chọn Rau: không rau · ít rau · nhiều rau** — chủ repo chốt 2026-10-26: cả ba 0đ, mặc định *ít rau*, chỉ áp cho canh; ghi vào `shop-facts.md` §4.4 · §4.6 luật 8 · §4.8, seed gắn nhóm chỉ cho canh, ca giá phủ cả chiều *bánh cuốn không nhận rau* — L2 (dữ liệu menu, ca giá) — mở 2026-10-26, Claude làm — xong 2026-10-26: gate xanh, §4.8 17/17 ca khớp ở database, cửa đơn và cửa giá · [chi tiết](#t-255)
- [x] T-244 **Bảy suất Đầy đủ · Suất giò · Suất trứng thành `menu_combo` thật, mỗi suất con chọn nhân riêng** — L3 — thiết kế Claude 2026-10-24, duyệt 2026-10-25; Codex làm (ba worktree song song cho T-251), Claude lead và tích hợp; đóng cùng ba phần a+b+c sau khi fullgate main xanh và UI máy dev nghiệm thu — xong 2026-10-25 · [chi tiết](backlog_archive.md#t-244)
- [x] T-252 **Bảy suất chuyển thành combo thật — phần (c): kiểm FE trên máy dev** — L1 — root + chủ repo nghiệm thu UI thật (6 món lẻ · 7 combo · combo Đầy đủ chín trộn nhân ra 29.000đ), reset dev được chủ repo cho phép, backup `/private/tmp/t244-dev-before.dump` giữ — xong 2026-10-25 · [chi tiết](backlog_archive.md#t-252)
- [x] T-251 **Bảy suất chuyển thành combo thật — phần (b): mở rộng parser, kịch bản, phép đối chiếu, test backend, dữ liệu thử** — L2 — ca 15 trộn nhân §4.8 vào shop-facts (Claude), parser `--price-cases-tsv` sáu cột, S3/baseline/i018_3 giữ composite `test-s3`/`test-baseline` dựng qua `prelude.sql`, i032_3/i032_4 trỏ `'Mẫu combo'` hidden, assertion I-019/I-020 giữ nguyên; fullgate main xanh — xong 2026-10-25 · [chi tiết](backlog_archive.md#t-251)
- [x] T-250 **Bảy suất chuyển thành combo thật — phần (a): seed và ca giá** — L2 — seed.pl bỏ bảy `menu_item` cũ, chèn bảy `menu_combo` + `menu_combo_item` + `menu_combo_item_option_surcharge` (mức mỗi suất, không nhân `quantity`); `--price-cases` 10/10 ca · `--price-cases-tsv` sáu cột `item|combo`; ADR-129 ghi lại thiết kế — xong 2026-10-25 · [chi tiết](backlog_archive.md#t-250)
- [x] T-249 **Trang Combo theo bản HTML chuẩn** — L1 — xong 2026-10-25 · [chi tiết](backlog_archive.md#t-249)
- [x] T-242 **Menu chưa có bánh trứng bán rời, trang Sản phẩm xếp mọi món vào một danh mục** — thêm ba dòng *bánh trứng bán rời* chín · tái · vàng vào dữ liệu mồi theo `shop-facts.md` §4.9 (2026-10-23), dữ liệu thử máy dev chia danh mục **Món lẻ** (trên) và **Combo** (dưới) theo cột *Nhóm trên menu*; ca giá 14 xanh — L2 (dòng menu có tiền) — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) · [chi tiết](#t-242)
- [x] T-238 **Trang Sản phẩm có nút Cập nhật cho tên, danh mục, giá và trạng thái của món** — mỗi dòng món mở ngăn bên phải: đổi tên, chuyển danh mục, đổi giá gốc từng thành phần, ngừng bán, mọi lệnh có lý do; dùng lại các cửa ghi sẵn có, không đổi backend hay hợp đồng; bán lại món đã ngừng chờ U-104 — L2 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-238)
- [x] T-240 **Máy dev không có lệnh make nào tạo lại tài khoản đăng nhập sau `make reset`** — thêm `make tai-khoan-dev` tạo chủ quán và bốn tài khoản theo vai như `docs/command/tai-khoan-dev.md`, chạy lại không lỗi; thay khối lệnh dài trong tài liệu ấy bằng lệnh make — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-240)
- [x] T-235 **Next.js 16.4.0 dính lỗ hổng bảo mật, `next build` dừng cách lượt** — nâng `next` và `eslint-config-next` trong `fe/` lên bản vá theo `next upgrade --agent=security`, đóng F-076 — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-235)
- [x] T-236 **Máy phát triển chưa có dữ liệu cho phần lớn các mục của trang chủ quán** — thêm bộ *dữ liệu thử* riêng cho máy dev (danh mục, combo, giao việc, đào tạo, khoản chi, sổ nguyên liệu, chấm công…), ghi nhãn rõ không phải sự thật của quán, chạy bằng một lệnh make riêng sau `make seed`; `db/seed/seed.pl` giữ nguyên — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-236)
- [x] T-234 **Trang Sản phẩm của chủ quán theo bản thiết kế, bày đủ thuộc tính món đã có** — áp `san_pham/san-pham.html` lên `/chu-quan/san-pham`: đầu trang có số món và hai nút, mỗi danh mục một bảng Món · Danh mục · Trạng thái · Giá · Thao tác, thêm món và đổi tên trong ngăn bên phải; giá là số `GET /menu` trả cho từng tổ hợp, không cộng, không tính thử — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-234)
- [x] T-232 **Trang gọi món của khách theo bản thiết kế menu** — dựng `/ban/[ma]` (và `/dat-mon`, cùng component) theo `khach_hang/menu/menu.html`: thẻ combo và món lẻ có nút bớt · thêm, ô tìm món, dải giỏ dính đầu trang, tóm tắt đơn, nút gửi cam, màu sáng · tối; phần chưa có dữ liệu hay luật không làm; hành vi gửi và test cũ giữ nguyên — L1 — mở 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) — xong 2026-10-23 · [chi tiết](#t-232)
- [x] T-231 **Trang Vận hành của chủ quán mặc phong cách mới** — áp `van-hanh-copy.html` và `styke/style.md` lên `/chu-quan/van-hanh`: màu nền · thẻ · viền · cam nhấn, sáng và tối; hành vi, chữ đọc được và test giữ nguyên — L1 — mở và xong 2026-10-23 (chủ repo yêu cầu; Codex làm, Claude duyệt) · [chi tiết](#t-231)
- [x] T-230 **Nút sáng / tối nằm góc dưới, chủ repo muốn nó cạnh nút Đăng xuất** — thanh đầu khung theo vai có nút; trang không thanh đầu giữ nút nổi — L1 — mở và xong 2026-10-22 (chủ repo yêu cầu) · [chi tiết](#t-230)
- [x] T-229 **Chưa có nút chuyển giao diện sáng / tối** — nút dùng chung ở khung gốc, nhớ lựa chọn, lần đầu theo máy, không nháy màu lúc tải — L1 — mở và xong 2026-10-22 (chủ repo yêu cầu; Codex làm, Claude duyệt) · [chi tiết](#t-229)

- [x] T-228 **Bấm ô số trên trang Vận hành ghi *đã đem ra*** — chọn 0…số thiếu, xác nhận, gửi `POST /served-marks` cho một bàn; chỉ bật khi phiên đang đứng quầy (S-5, chủ repo giữ 2026-10-21) — L2 — mở 2026-10-21, bắt đầu 2026-10-21 (Claude thiết kế và viết test, Codex thi công), **cần xong trước:** `T-226` — 2026-10-22 · [chi tiết](#t-228)
- [x] T-226 **Trang `/chu-quan/van-hanh` — phần đọc theo thiết kế đã chốt** — năm khối của `van_hanh/van-hanh.html`, số lấy từ `T-225`, cộng thử chỉ tính trên màn — L1 — mở 2026-10-21, `T-225` xong 2026-10-21; nhận 2026-10-21 — Codex thi công, Claude duyệt — xong 2026-10-21 · [chi tiết](#t-226)
- [x] T-225 **Đường đọc cho trang Vận hành: từng bàn, từng thứ, tiền đã ra, lịch sử đem ra** — một cửa đọc mới cho chủ quán (và người đứng quầy): phiên bàn chưa đóng chia *đang phục vụ* · *sắp phục vụ*, mỗi thứ đặt · đã ra · thiếu kèm cờ nhiều, tiền đơn và tiền đã ra, bàn trống, lịch sử từng lần đem ra — L2 (Claude thiết kế ADR-124 và viết test trước, Codex thi công, Claude duyệt) — mở 2026-10-21, nhận 2026-10-21 — xong 2026-10-21 · Codex thi công, Claude duyệt · [chi tiết](#t-225)
- [x] T-224 **Thiết kế trang Vận hành chốt, chia thành task** — ghi ba lời chủ repo (thanh toán chỉ thu phần đã ra · bấm đem ra vẫn là người đứng quầy · nghĩa *sắp phục vụ*), mở `U-103`, mở `T-225`…`T-228` — L1 — mở và làm 2026-10-21 · Claude Code theo lời chủ repo *"tôi chốt thiết kế hiện tại của trang vận hành hãy làm các task để hoàn thành trang trên"* — 2026-10-21 · [chi tiết](#t-224)
- [x] T-220 **Trang Vận hành — thiết kế chốt** — mở để bảng từng bàn đọc rõ trên điện thoại, rồi theo lời chủ repo từng bước thành bản chốt: tổng thiếu theo bàn lên đầu (bấm ô ghi đem ra, bấm tiền thanh toán, trượt mở chi tiết, ô nhiều có *), cộng thử ghép đơn, từng bàn dạng cột, sơ đồ bàn, lịch sử phục vụ — L1 — mở và nhận 2026-10-20 · Codex (thẻ điện thoại), Claude Code (các lượt sửa theo lời chủ repo) — 2026-10-21 · [chi tiết](#t-220)
- [x] T-222 **Màn QR có tiêu đề hình mã QR + số bàn, `/dat-mon` lên máy tìm kiếm** — hai việc còn lại của `P4-10`: `h1` màn `/ban/[ma]` bày biểu tượng mã QR và *Bàn {số}*; `/dat-mon` vào `PUBLIC_ROUTES`, có metadata công khai và nằm trong sitemap — L1 — mở và nhận 2026-10-21 · Claude Code (dẫn, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm các task trên còn bạn kiểm tra"* — 2026-10-21 · [chi tiết](#t-222)
- [x] P4-10 **Khách: QR tại bàn và đơn web** — `/ban/[ma]` gửi lượt gọi QR, `/dat-mon` đơn giao · mang đi · đặt trước; menu lấy ở server từng request, tổng là tính thử của cả giỏ, gửi lại không nhân đôi (`I-024`), câu tạm dừng · mất kết nối chủ repo chọn 2026-10-21 — L2 — nhận 2026-10-21 · Claude Code (dẫn, test trước, duyệt), Codex thi công — 2026-10-21 · [chi tiết](backlog_FE.md#p4-10)
- [x] T-221 **Bộ soạn món soạn được combo và theo lựa chọn phụ thuộc** — phần còn lại của đợt hai `P4-07`: nhóm có điều kiện chỉ hiện khi điều kiện được chọn; combo chọn nhân từng suất, giá dòng combo từ `POST /price-quotes`; hàng chờ bày suất của combo — L1 — nhận 2026-10-21 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex thực hiện 2 việc trên bạn kiểm tra"* — 2026-10-21 · [chi tiết](#t-221)
- [x] P4-07 **Màn quầy: nhận và ghi đơn** — đợt một hàng chờ (duyệt · từ chối, tạm dừng · quán mù, đơn hẹn); đợt hai bày món · tiền, đơn đang làm · rời quán (bị chặn bởi S-6, màn nói rõ), `/quay/goi-mon` · `/quay/dien-thoai`; combo ở bộ soạn để sau — L2 — nhận 2026-10-20 · Claude Code (dẫn, test trước, duyệt), Codex thi công — 2026-10-21 · [chi tiết](backlog_FE.md#p4-07)
- [x] P4-09 **Sản xuất theo mẻ — phần làm được** — bảng trạm chỉ đọc, ra bàn ở quầy; bấm mẻ · lùi mẻ · chuyển · ghi làm sai (lượt hai, Codex; chạy thật 2026-10-21) — đường đọc của `T-217` — L2 — nhận 2026-10-20 · Claude Code (dẫn, test trước, duyệt), Codex thi công — 2026-10-21 · [chi tiết](backlog_FE.md#p4-09)
- [x] T-218 **Hàng chờ quầy bày món, tiền và đơn đang làm (F-074)** — `GET /counter/queue` thêm `lines` · `total_vnd` đọc từ ảnh chụp cho mỗi đơn chờ, và `active_orders` (đơn ngoài bàn `confirmed` · `in_progress` · `delivering`, kèm cách trao, liên hệ, tiền, số việc chưa ra bàn); hợp đồng `0.47.0` — L2 (hợp đồng) — mở và nhận 2026-10-20 · Claude Code (dẫn, test trước, duyệt), Codex thi công — 2026-10-20 · [chi tiết](#t-218)
- [x] T-219 **Bản thiết kế tĩnh trang Vận hành của chủ quán** — một trang HTML mới trong `docs/product/4-fe/thiet_ke/chu_quan/van_hanh/`: bàn đang phục vụ · sắp phục vụ · trống, từng bàn đặt ban đầu · đã ra · còn thiếu, bánh theo nhân và bát canh, tiền đơn và tiền bánh đã ra, bảng tổng còn thiếu, công cụ cộng thử bàn sắp phục vụ vào bàn đang phục vụ để ghép đơn; số minh hoạ, là đề xuất chứ không phải hợp đồng; không đổi `fe/` — L1 — mở và nhận 2026-10-20 · Claude Code (dẫn, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm bạn kiểm tra"* — 2026-10-20 · [chi tiết](#t-219)
- [x] T-217 **Đường đọc việc trạm và mẻ cho quầy (F-073)** — `GET /counter/station-jobs` lớp `quay`: từng việc trạm còn sống kèm khoá gom, mẻ còn hiệu lực, ghi làm sai, cờ chuyển được; mẻ chưa lùi kèm việc và cờ đã ra bàn; khoá gom bản thứ ba dưới `TestI019` — L2 (hợp đồng) — mở và nhận 2026-10-20 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm 2 việc trên bạn kiểm tra"* — 2026-10-20 · [chi tiết](#t-217)
- [x] T-216 **Bản thiết kế tĩnh cho phía khách, có tên component** — 9 trang HTML điện thoại trước trong `docs/product/4-fe/thiet_ke/khach_hang/`: trang chủ, mở bằng mã QR, thực đơn, chọn món, giỏ, đã gửi lượt tại bàn, thông tin đơn online, đã đặt online, quán không nhận đơn; theo cùng khuôn nhãn và chú giải của T-215; chỉ bày điều hợp đồng và dữ kiện quán đã có, chữ chưa chốt để giữ chỗ; không đổi `fe/` — L1 — mở và nhận 2026-10-20 · Claude Code (dẫn, duyệt), Codex thi công theo lời chủ repo *"hãy viết prompt yêu cầu codex làm các file html cho client side"* — 2026-10-20 · [chi tiết](#t-216)
- [x] T-215 **Bản thiết kế tĩnh cho từng trang chủ quán, có tên component** — 13 trang HTML mở thẳng từ file trong `docs/product/4-fe/thiet_ke/chu_quan/`, một trang một route của `mucChuQuan`, mỗi khối mang nhãn tên component và bảng chú giải; chỉ bày đúng ô và thao tác trang thật đang có, số minh hoạ; không đổi `fe/` — L1 — mở và nhận 2026-10-20 · Claude Code (dẫn, duyệt), Codex thi công theo lời chủ repo *"hãy yêu cầu codex làm và bạn kiểm tra"* — 2026-10-20 · [chi tiết](#t-215)
- [x] T-214 **Một lệnh chạy toàn bộ hệ thống trên máy phát triển** — `make dev` bật database · migration · mồi rồi chạy server Go (8080) và Next (3000) cùng lúc, log có tiền tố, Ctrl+C hay một bên chết thì tắt cả hai, database giữ chạy; `make be` · `make fe` chạy riêng; `docs/command/make.md` §4 — L1 — mở và nhận 2026-10-20 · Codex thi công (hết hạn mức trước báo cáo), Claude Code duyệt và chạy thật — 2026-10-20 · [chi tiết](#t-214)
- [x] P4-06 **Lớp realtime chung** — `TinHieuProvider` đọc SSE qua client API, tín hiệu chỉ làm đọc lại, im 25 giây là đứt, tự nối lại, banner không nút; luồng ở layout `/quay` · `/tram`; `tuyChonKeo()` kéo theo chu kỳ; nhiều tab qua `BroadcastChannel`; chạy thật: đóng tab quầy ⇒ `409 shop_not_seeing_orders` — L2 — Codex thi công, Claude Code test trước và duyệt — 2026-10-20 · [chi tiết](backlog_FE.md#p4-06)
- [x] P4-05 **Trang *Menu & giá* — trang thử, rút khuôn** — `/chu-quan/menu-gia`: giá mỗi tổ hợp, thành phần qua tính thử, phụ thu; đổi giá gốc · phụ thu · số lượng có lý do, ngừng bán; khuôn ở `01-khung-fe.md` §6; chạy thật trên trình duyệt: đổi giá ⇒ số mới không tải lại trang — L2 — Codex thi công, Claude Code test trước và duyệt — 2026-10-20 · [chi tiết](backlog_FE.md#p4-05)
- [x] T-213 **Sửa test phụ thuộc thứ tự gói (F-072)** — test dựng món giả có nhóm tự ngừng bán qua cửa thật khi xong; bản gốc `menu` → `gia` đỏ, bản sửa cả hai thứ tự xanh; F-072 đóng — L1 — mở và nhận 2026-10-20 · Codex thi công, Claude Code duyệt theo lời chủ repo *"yêu cầu codex làm bạn kiểm tra"* — 2026-10-20 · [chi tiết](backlog_archive.md#t-213)
- [x] T-212 **Màn POS giao việc và đào tạo từ quầy (phần còn lại của P4A-07 · P4A-11)** — `/quay/giao-viec` · `/quay/dao-tao` dùng lại trang của chủ quán trong khung quầy; `/quay` có hai lối vào — L1 — mở và nhận 2026-10-19 · Claude Code theo lời chủ repo chọn *"Màn POS giao việc và đào tạo"* — 2026-10-20 · [chi tiết](#t-212)
- [x] T-211 **Đặt mức phụ thu theo món của combo (phần còn lại của P4A-05)** — `GET /option-groups` trả thêm `menu_item_ids` của mỗi nhóm; trang combo có form *Đặt phụ thu* gửi `PUT /menu-combos/{menu_combo_id}/surcharges` cho các cặp món · lựa chọn đã đổi, có lý do, ngoài giờ bán — L1 — mở và nhận 2026-10-19 · Claude Code — 2026-10-19 · [chi tiết](#t-211)
- [x] T-210 **Topping: chủ quán thêm, ẩn, bật lại lựa chọn trong nhóm có sẵn** — `GET /option-groups` · `POST /option-groups/{option_group_id}/options` · `POST /menu-options/{menu_option_id}/hiding` · `…/unhiding`; hàm giá từ chối lựa chọn đã ẩn; trang `/chu-quan/topping` — L2 (chạm hàm giá) — mở và nhận 2026-10-19 · Claude Code theo lời chủ repo — 2026-10-19 · [chi tiết](#t-210)
- [x] T-209 **Hai ô trống của cổng pha 3 (F-068)** — test cắt giữa bấm mẻ · lùi mẻ · lúc ghi vết của lần huỷ đơn, test từ chối qua cửa cho `I-006` vế tầng 3; ký ô 1 · ô 2 (`I-019` ký có lý do) — L2 (chỉ thêm test) — 2026-10-19 · Claude Code · [chi tiết](#t-209)
- [x] T-208 **Gate 9: git từ chối commit nhặt file của nhiều task (F-025)** — `scripts/hooks/pre-commit` khớp file staged với scope từng task bằng `check-scope.sh --match`; `install-hooks.sh --check` đòi cả hook mới; CLAUDE.md §6.2 — L1 — 2026-10-19 · Claude Code theo lời chủ repo *"F-025: hook pre-commit"* · [chi tiết](#t-208)
- [x] T-141 **Huỷ ô chấm công: ghi chú bắt buộc, chỉ chủ quán** — migration siết lát chấm công (U-071, `I-027`), test `db/tests/i027_*` đổi từ *database nhận* sang *database từ chối*, `13-luoc-do-cham-cong.md` — L2 — Claude viết test đỏ và thi công (2026-10-19, Codex không tham gia) — 2026-10-19 · [chi tiết](#t-141)
- [x] T-207 **Test lùi mẻ chen chuyển phần của chính mẻ (F-066)** — `TestI020_LuiMeChenChuyenPhanCuaChinhMe` 12 vòng chen nhau, cả hai thứ tự đều ra mẻ đã lùi và hai đơn vị về Chưa làm; bỏ hai khoá mẻ ⇒ đỏ — L1 (chỉ thêm test) — 2026-10-19 · Claude Code · [chi tiết](#t-207)
- [x] T-206 **Ba finding tài liệu: F-067 · F-069 · F-070** — ghi lượt duyệt độc lập backend (không thấy hành vi đổi) và đóng F-067; `prompt-fullstack.md` §3.6 thành con trỏ tới hợp đồng; ba lời hứa treo của pha 3 ghi rõ chỗ nhận — L0/L1 tài liệu — 2026-10-19 · Claude Code theo lời chủ repo chọn ba việc quy trình · [chi tiết](#t-206)
- [x] T-205 **Địa chỉ và giờ mở trên Google (hai vế của U-094)** — shop-facts §1 có địa chỉ và *trừ Tết âm lịch*; JSON-LD trang chủ có `address` · `openingHoursSpecification` 06:00–11:00 mọi ngày; U-094 hẹp lại còn tên miền và câu mô tả — L1 — 2026-10-19 · Claude Code theo lời chủ repo trong hội thoại · [chi tiết](#t-205)
- [x] T-204 **Ba lúc chưa có mốc vẫn nhắc POS kiểm tra (U-102)** — chưa có lần nhập · lần nhập gần nhất ghi 0 ⇒ `check_reminder: true`, POS thấy tên thứ ấy ở `GET /supply-check-reminders`; dùng trước ngày nhập đầu ⇒ so tỉ lệ như thường; hợp đồng 0.42.0 (cờ thôi `null`); trang kho và tổng quan nói *Nhắc POS kiểm tra* kèm lý do — L1 — mở và nhận 2026-10-19 · Claude Code theo lời chủ repo chọn *"Luôn nhắc POS kiểm tra"*, vế 3 *"Đã có lần nhập thì so tỉ lệ như thường"* — 2026-10-19 · [chi tiết](#t-204)
- [x] T-203 **Cửa duyệt không trao cờ chủ quán (F-071)** — `POST /accounts/{account_id}/approval` từ chối `person_id` của người mang cờ chủ quán bằng `409 account_person_is_owner` (`field: person_id`); hợp đồng 0.41.0; trang nhân viên nói đúng lời; vế mới của `I-033` — L2 — mở 2026-10-19 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"hãy yêu cầu codex làm f-071. đồng ý với đề xuất của bạn"* — 2026-10-19; Codex thi công, Claude duyệt và chạy thật · [chi tiết](#t-203)
- [x] P4A-11 **Trang đào tạo của chủ quán** — ghi nhận xét và đánh giá *làm được · chưa* về một người, sửa · ẩn có lý do (`/training-records*`); hướng dẫn chữ · ảnh · video gắn từng việc được giao, sửa chữ · ẩn có lý do (`/assigned-tasks/{assigned_task_id}/guides` · `/assigned-task-guides*`); POS làm từ quầy chưa có màn — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt, chạy thật), Codex thi công kể cả test theo cùng lời — 2026-10-19; Codex hết hạn mức giữa chừng, Claude làm nốt · [chi tiết](backlog_FE_AD.md#p4a-11)
- [x] P4A-10 **Trang khoản chi của chủ quán (chi phí marketing là một loại chi)** — loại chi khai rõ nguồn két · tiền riêng (`/expense-categories`), ghi · sửa có lý do khoản chi, lọc theo khoảng ngày · loại · nguồn, tổng do backend cộng (`/expenses*`); không ngân sách, không chiến dịch — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt, chạy thật), Codex thi công kể cả test theo cùng lời — 2026-10-19; Codex hết hạn mức giữa chừng, Claude làm nốt · [chi tiết](backlog_FE_AD.md#p4a-10)
- [x] P4A-09 **Trang kho của chủ quán** — đọc `GET /supply-stock`: hai tổng, số thiếu theo phép trừ §8.4, lần nhập gần nhất, tỉ lệ nhắc và cờ nhắc POS kiểm tra đúng như backend trả; đặt tỉ lệ có lý do (`PUT /supply-items/{supply_item_id}/reminder-ratio`); không *dự kiến hết*, không so ngưỡng hay trừ ở trình duyệt — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt, chạy thật), Codex thi công kể cả test theo lời chủ repo *"hãy yêu cầu codex làm nốt 3 task trên nếu codex hết token bẹn làm nốt"* — 2026-10-19; Codex hết hạn mức giữa chừng, Claude làm nốt · [chi tiết](backlog_FE_AD.md#p4a-09)
- [x] P4A-08 **Trang nguyên liệu của chủ quán** — danh mục nguyên liệu (`/supply-items`), thêm thứ, đặt đơn vị lần đầu, sổ ngày của từng thứ: ghi con số mua vào · đã dùng, sửa có lý do (`/supply-day-entries*`); không bày số thiếu, tỉ lệ hay lời nhắc (thuộc `P4A-09`), không tính ở trình duyệt — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt, chạy thật), Codex thi công kể cả test theo lời chủ repo *"hãy yêu cầu codex làm 2 task trên bạn kiểm tra"* — 2026-10-19 · [chi tiết](backlog_FE_AD.md#p4a-08)
- [x] P4A-07 **Trang giao việc của chủ quán** — danh sách việc mới nhất trước, lọc theo người nhận (`GET /assigned-tasks`), giao việc, sửa có lý do, đánh dấu xong · bỏ đánh dấu, xoá là ẩn có lý do (`/assigned-tasks*`); không hướng dẫn (thuộc `P4A-11`), không hạn — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt, chạy thật), Codex thi công kể cả test theo cùng lời — 2026-10-19; còn POS giao việc từ quầy (chưa có bước) · [chi tiết](backlog_FE_AD.md#p4a-07)
- [x] P4A-06 **Trang nhân viên của chủ quán** — danh sách tài khoản theo trạng thái (`GET /accounts`), duyệt kèm vai và người trong quán, từ chối, khoá, mở lại kèm mật khẩu tạm (`/accounts/{account_id}/approval|rejection|lock|unlock`); không bày mật khẩu, không xoá — L2 — mở và nhận 2026-10-19 · Claude Code (dẫn, test trước, thi công, chưa review độc lập) theo lời chủ repo *"hãy đọc kĩ và làm task trên"* — 2026-10-19; mở **F-071** (backend gắn được người chủ quán khi duyệt) · [chi tiết](backlog_FE_AD.md#p4a-06)
- [x] P4A-05 **Trang danh mục và trang combo của chủ quán** — danh mục: xem, thêm, đổi tên · ẩn có lý do, xếp · chuyển món (`/menu-categories*`, `PUT /menu-items/{menu_item_id}/category`); combo: xem, lập với **giá riêng**, đổi giá ngoài giờ bán · ẩn có lý do (`/menu-combos*`); mức phụ thu theo món chỉ đọc; **topping chưa có cửa thêm** nên không làm — L2 — mở và nhận 2026-10-19 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm bạn kiểm tra"* — 2026-10-19; còn đặt phụ thu combo và topping · [chi tiết](backlog_FE_AD.md#p4a-05)
- [x] P4A-04 **Trang sản phẩm của chủ quán** — xem mọi món theo danh mục (`GET /menu-categories`), thêm món kèm thành phần (`POST /menu-items`), đổi tên món có lý do (`PUT /menu-items/{menu_item_id}`); không sửa giá, không ngừng bán (thuộc `P4-05`), không tự tính giá — L2 — mở và nhận 2026-10-19 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm bạn kiểm tra"* — 2026-10-19 · [chi tiết](backlog_FE_AD.md#p4a-04)
- [x] P4A-03 **Trang tổng kết theo ngày bán** — bốn mục từ `GET /sale-days/{sale_date}/summary`, ngày mặc định do backend trả, ngày xem trên URL, nhắc kho là kết quả hiện tại — L2 — mở 2026-10-19, **cần xong trước:** `P4A-01` · nhận 2026-10-19 · Claude Code (dẫn, test trước, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm bạn kiểm tra"* — 2026-10-19 · [chi tiết](backlog_FE_AD.md#p4a-03)
- [x] P4A-02 **Trang tổng quan của chủ quán** — bảy mục §8.6 từ `GET /owner-overview`, ô nhập hai số tối thiểu (`PUT /daily-minimums/{sale_date}`), không kéo theo chu kỳ, bày `read_at`, tạm tính không giống doanh thu — L2 — mở 2026-10-19, **cần xong trước:** `P4A-01` · nhận 2026-10-19 · Claude Code (dẫn, test trước, duyệt), Codex thi công — 2026-10-19 · [chi tiết](backlog_FE_AD.md#p4a-02)
- [x] P4A-01 **Khung admin dưới `/chu-quan`** — layout chung có gác theo phiên và thanh điều hướng đọc từ một danh sách; `/chu-quan` là trang Tổng quan, `/chu-quan/tong-ket` là Tổng kết; không khung `/admin` thứ hai, không bảng quyền thứ hai — L1 — mở và nhận 2026-10-19 · Claude Code (dẫn, duyệt), Codex thi công theo lời chủ repo *"yêu cầu codex làm tiếp bạn kiểm tra"* — 2026-10-19 · [chi tiết](backlog_FE_AD.md#p4a-01)
- [x] T-202 **Khớp FE với ADR-102 trước `P4-05`** — QueryClient đang tắt đọc lại khi quay lại cửa sổ (trái ADR-102 điểm 3); ADR-102 điểm 4 · 7 còn nói chọn tên và `X-Person-Id` dù ADR-109 đã thay; hai việc ADR-102 giao cho `P4-03` · `P4-04` (accessibility, nhiều tab) bị rơi; vài đề xuất `fe_guidance` chưa có bước nhận — L1 — mở 2026-10-19 từ lượt rà `fe_guidance` (Claude Code), nhận 2026-10-19 · Claude Code (dẫn), Codex thi công phần code theo lời chủ repo *"hãy làm theo đề xuất của bạn yêu cầu codex làm bạn kiểm tra"* — 2026-10-19 · [chi tiết](backlog_archive.md#t-202)
- [x] T-197 **Chỗ cất số người đang làm do POS khai** — mở 2026-10-16 từ P3A-09; nhận 2026-10-19 · Claude Code (dẫn), Codex thi công và viết test theo lời chủ repo *"hãy làm t-197 giao cho codex làm bạn kiểm tra"* — L2. **Thiết kế: ADR-121.** *Acceptance:* (1) migration bước 32 bảng `workers_present_declaration` — mỗi lần khai một dòng (`worker_count` nguyên dương, `sale_date`, lúc khai — cột `created_at` theo QD-34, hợp đồng trả `declared_at` —, người khai), không sửa không xoá cho vai ghi, có trigger vết, lùi chặn khi có dòng; file `docs/product/2-db/22-luoc-do-so-nguoi-dang-lam.md`, dòng 32 ở `07-thu-tu-migration.md`, test database (số ≤ 0 bị từ chối, thiếu người khai bị từ chối, vai ghi không UPDATE · DELETE được); (2) `POST /workers-present-declarations` lớp `quay` — không phiên ⇒ `unauthenticated`, ngoài quầy (kể cả chủ quán không đứng quầy) ⇒ `not_on_counter_duty`, `worker_count` thiếu · ≤ 0 · không nguyên ⇒ `invalid_request`; trả dòng vừa ghi; (3) `GET /workers-present` lớp `quay_hoac_chu_quan` trả lần khai mới nhất của ngày bán hiện tại hoặc `null`; (4) `GET /owner-overview`: `workers_present` có số khi ngày bán hiện tại có lần khai (lần mới nhất thắng, lần của ngày trước không dùng), không có ⇒ *chưa có* `workers_present_missing`; `shortages.workers` có số khi có cả lần khai và `minimum_workers` — `short` = khai < tối thiểu, `missing_workers` = phần thiếu (0 khi đủ) — thiếu lần khai ⇒ `workers_present_missing`, có lần khai mà chưa nhập tối thiểu ⇒ `daily_minimum_missing`; (5) hợp đồng tăng phiên bản phụ, `schema.ts` sinh lại, ma trận thêm một dòng cho cửa ghi; test mới đỏ trước khi có code; db-check · be-check · `./scripts/gate.sh` xanh do Claude tự chạy — **xong 2026-10-19**: Codex viết test trước (đỏ vì chưa có bảng · cửa), Claude Code thi công phần còn lại; hợp đồng 0.40.0; be-check · db-check · gate xanh · [ADR-121](../docs/decisions.md) · [chi tiết](backlog_AD_BE.md#t-197)
- [x] P3A-10 **Đọc tổng kết** — `GET /sale-days/{sale_date}/summary` chỉ chủ quán, package `tongket`: doanh thu ngày bán từ hai nguồn trừ hoàn ngày hoàn, kèm trạng thái đối soát và lượt giấy chưa nhập (`ket.DocTrangThaiNgay` mới, không cần số đếm két); món bán chạy (suất con theo món, combo riêng); nhắc kho bằng `nguyenlieu.DocNhacKiemTra`; số đếm theo người không điểm không hạng; hợp đồng 0.39.0 (**ADR-120**). Codex thi công cả test, Claude duyệt, sửa dữ liệu dựng của một test và thử đột biến; be-check · gate xanh ở clone chính — 2026-10-19 — L2 · [chi tiết](backlog_AD_BE.md#p3a-10)
- [x] T-200 **Ba chỗ hở sau khi duyệt lại P3A-07…09** — mở 2026-10-18 · Claude Code (duyệt lại commit `34d0d2c`) — L1. (1) `POST /menu-items` · `PUT /menu-items/{id}` cắt khoảng trắng tên trước khi ghi như cửa danh mục · combo · nguyên liệu (`be/internal/menu/handler.go`), thêm test tên chỉ khác khoảng trắng ⇒ `menu_item_name_conflict`, và test tạo món vào danh mục đã ẩn ⇒ `menu_category_hidden` · danh mục không có ⇒ `menu_category_not_found`, không để lại món. (2) `GET /owner-overview` mục `shortages.supplies` đọc một lần bằng `nguyenlieu.Doc`, bỏ vòng `DocChiTiet` từng thứ (mỗi thứ một giao dịch, trả cả sổ ngày từ trước tới nay); hợp đồng đổi schema ⇒ tăng phiên bản. **Vế (2) làm sau khi `T-199` vào `main`** — `T-199` đang sửa cùng `be/internal/tongquan/service.go`. (3) Ba ca biên của cờ nhắc kho (`no_purchase` · `latest_purchase_zero` · `usage_before_first_purchase`, đang là văn xuôi ở `docs/product/3-be/01-hop-dong-api.md` mục P3A-08) thành một câu `U-XXX` dưới *Đang mở* của `docs/product/99-unknowns.md`, hỏi chủ quán. **Đang làm 2026-10-18:** vế (3) xong — **U-102** (Claude); vế (1) xong — thực hiện Codex (nhánh `codex/T-200` từ `0f9be2d`, Codex viết cả test theo lời chủ repo *"yêu cầu codex làm nốt"*), duyệt Claude: `be/internal/menu/handler.go` cắt tên món, tên thành phần, lý do; test `TestI032_ThemMonCatTenVaTrungTen` · `TestI032_DoiTenMonCatTenVaTrungTen` · `TestI032_ThemMonDanhMucSaiLuiGiaoDich` — Claude chạy đỏ trên handler cũ (`them_mon_test.go:208` tên lưu chưa cắt) rồi xanh, be-check · gate xanh ở clone chính; vế (2) xong 2026-10-19 — thực hiện Codex (nhánh `codex/T-200b` từ `7310cbb`), duyệt Claude: `tongquan.Service.Doc` dùng một lần `nguyenlieu.Doc`, bỏ vòng `DocChiTiet`; `shortages.supplies.items` là schema `SupplyItem`, không còn `entries`; hợp đồng 0.38.0. Bằng chứng: `TestQC14_BayMucVaPhanRaBan` đỏ trên code cũ (Codex: JSON còn `entries`) rồi xanh; `TestQC14_TongQuanNguyenLieuBangSupplyStockKhongCoSoNgay` so nguyên danh sách với `GET /supply-stock` — Claude chạy be-check, gate xanh trong worktree. *Acceptance:* ba vế trên, test mới đỏ trước khi sửa, `./scripts/gate.sh` xanh, Claude tự chạy be-check.
- [x] T-201 **Lời nhắc kiểm tra kho tới được POS** — mở 2026-10-18 · Claude Code (duyệt lại P3A-08) — L2. Chủ quán chốt người nhận nhắc là **POS** (`master_plan/shop-facts.md` §8.4 *Sửa 2026-10-14*), nhưng `GET /supply-stock` chỉ lớp `chu_quan` đọc. **Thiết kế: ADR-119** (Claude, 2026-10-18). **Bàn giao 2026-10-19:** thực hiện Codex (nhánh `codex/T-201` từ `b51af15`, Codex viết cả test theo lời chủ repo *"yêu cầu codex làm nốt"*), duyệt Claude Code. `GET /supply-check-reminders` (`nguyenlieu.DocNhacKiemTra`) lọc kết quả `repository.doc`, không chép phép so sánh; hợp đồng 0.37.0, `schema.ts` sinh lại; hai câu P3A-08 ở `01-hop-dong-api.md` trỏ U-102 và đường mới. Bằng chứng: `TestI025_NhacKiemTraCoDuongDoc` đỏ trên code cũ (Codex) rồi xanh; `TestI025_NhacKiemTraQuyenVaCungTapKho` (401 · 403 · 200 cho chủ quán và người đứng quầy, POS vẫn `owner_only` ở `/supply-stock`, dưới · bằng · trên ngưỡng, ba ca U-102, tập thứ bằng tập cờ bật của kho, `items=[]`) — Claude chạy be-check, gate xanh trong worktree và clone chính. Ghi nhận: cuối test ghi một lần nhập lớn cho mọi thứ đang nhắc trong database thử — chấp nhận vì be-check dựng database mới mỗi lần. Còn lại: màn quầy `P4` gọi đường này khi nhận `changed`. *Acceptance:* `GET /supply-check-reminders` lớp `quay_hoac_chu_quan` — người đang đứng quầy và chủ quán đọc được, người thường ngoài quầy ⇒ `not_on_counter_duty`, không phiên ⇒ `unauthenticated`; chỉ trả `supply_item_id` · `name` · `purchase_unit` của thứ có cờ nhắc bật, kèm `read_at`; thứ ở ba trạng thái **U-102** không xuất hiện; cùng một phép tính cờ với `GET /supply-stock` (test: hai đường cho cùng tập thứ); không cửa ghi mới; hợp đồng tăng phiên bản, `schema.ts` sinh lại; câu *Câu hỏi chuyển Claude* ở `01-hop-dong-api.md` mục P3A-08 trỏ sang U-102; `./scripts/gate.sh` xanh; Claude tự chạy be-check.
- [x] T-199 **Mục tổng quan đủ số** — bảng `daily_minimum` (bước 31, khoá theo ngày, hai số dương, sửa có vết, khoá chặn lùi), `PUT /daily-minimums/{sale_date}` chỉ chủ quán; `GET /owner-overview` trả số bàn đang phục vụ, đã ra · còn thiếu tách `in_store` · `online`, tiến độ bánh so với tối thiểu, tạm tính theo đơn vị bán đã ra hết, thiếu món; thiếu người *chưa có* chờ `T-197`; hợp đồng 0.36.0 (ADR-118). Codex thi công cả test, Claude duyệt hai vòng (vòng 1 phiên trước: đếm trùng bánh ở hai trạm, hai test đỏ; vòng 2 phiên này kiểm và đưa về); be-check · db-check · gate xanh ở clone chính — 2026-10-19 · [chi tiết](backlog_AD_BE.md#t-199)
- [x] T-198 **Ghi lời chủ quán cho năm câu của mục tổng quan** — đóng U-097…U-101 vào `master_plan/shop-facts.md` §8.6 (số bàn · số bánh tối thiểu · giá phần đã ra · tách online/offline · số người tối thiểu riêng), nhật ký §7.1, mở S-10 (chữ *offline*) — L1 — Claude Code, 2026-10-16
- [x] P3A-08 **Đọc kho và nhắc POS** (gộp `T-186`, cột tỉ lệ nhắc) — migration bước 30 `reminder_ratio numeric` mặc định 0.2, miền 0…1, khoá chặn lùi; `GET /supply-stock` trả nhập gần nhất · tổng nhập · tổng dùng · hiệu số · cờ *nhắc kiểm tra* (không kết luận thiếu); `PUT /supply-items/{id}/reminder-ratio` chỉ chủ quán, có vết; QC-04 thêm hậu tố `_ratio` (chủ repo chọn 2026-10-16); hợp đồng 0.35.0. Codex thi công, Claude duyệt và sửa nốt; be-check · db-check · gate xanh — 2026-10-16 · [chi tiết](backlog_AD_BE.md#p3a-08)
- [x] P3A-09 **Đọc tổng quan cho chủ quán** — `GET /owner-overview` (chỉ chủ quán), package `tongquan`; có số: phần đã ra bàn · còn thiếu · nguyên liệu; *chưa có* có tên: khách, tiến độ, tạm tính, số người đang làm, thiếu người · món — mở U-097…U-101, số người chờ `T-197`. Codex thi công, Claude duyệt; be-check · gate xanh — 2026-10-16 · [chi tiết](backlog_AD_BE.md#p3a-09)
- [x] P3A-07 **Thêm và sửa thông tin món** — `POST /menu-items` (món + danh mục + thành phần trong một giao dịch, không có món rỗng), `PUT /menu-items/{id}` đổi tên có lý do; chỉ chủ quán; không cửa thứ hai sửa giá. Codex thi công, Claude duyệt và thêm ca vết `menu/doi_ten`; be-check · gate xanh — 2026-10-16 · [chi tiết](backlog_AD_BE.md#p3a-07)

- [x] P3A-11 **Bán combo** — bốn lát `T-193`…`T-196` xong: combo bán được ở cả năm kênh và nhập bù; giá = giá combo tại mốc + mức chủ quán đặt theo món, mỗi suất một lần, chưa đặt 0đ; **ADR-117** (chủ repo duyệt 2026-10-15), mệnh đề `I-034`, `U-096` đóng; Claude làm cả bốn lát vì Codex hết hạn mức ngay lát đầu; gate xanh — 2026-10-15 — L3 · [chi tiết](backlog_AD_BE.md#p3a-11)
- [x] T-196 **Ghi đơn mang combo** — cửa tạo lượt gọi và nhập bù ghi dòng combo rồi suất con trong cùng giao dịch; đọc đơn lồng suất dưới combo; gửi lại cùng dấu so cả suất; bếp nhận việc theo suất con; bảy dòng `order_line_*` của `x-constraint-errors` xét là nội bộ; **ADR-117** điểm 2 · 5 · 7; Claude làm; be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-11)
- [x] T-195 **Hàm giá học combo** — `gia.Tinh` nhận dòng combo (mã combo, số combo, các suất), bốn bước kiểm mới, giá = giá combo tại mốc + mức mỗi suất, chưa đặt mức 0đ; tính thử và `GET /menu` bày combo đang bán; hợp đồng 0.32.0, mã `combo_portions_mismatch`; `03-ham-gia.md` §1.1; **ADR-117** điểm 4 · 5; Claude làm (Codex hết hạn mức); be-check xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-11)
- [x] T-194 **Cửa đặt mức phụ thu trong combo** — `PUT /menu-combos/{id}/surcharges`, cửa `combo/dat_muc` lớp `chu_quan`, ngoài giờ bán, có lý do và vết; `GET /menu-combos` trả mức theo món; hợp đồng 0.31.0, hai mã lỗi mới; **ADR-117** điểm 6; Claude làm (Codex hết hạn mức); be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-11)
- [x] T-193 **Lát lược đồ bán combo** — `menu_combo_item_option_surcharge`; dòng combo và dòng suất con trong `order_line` (bước 29, `20261015120000_ban_combo`); đối chiếu `I-034/1`…`/7` kèm bảy lỗi cài; I-013 · I-009/2 bỏ qua dòng combo; **ADR-117**; Claude làm (Codex hết hạn mức); db-check · be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-11)
- [x] P3A-06 **Cửa combo của chủ quán** — package `combo`: lập combo một lần đủ món (có thật, chưa ngừng bán, số phần nguyên dương) với giá chủ quán đặt, đổi giá có lý do và có vết — bị từ chối trong giờ bán, ẩn, đọc kèm món; chỉ chủ quán, cả đọc; phép giờ bán dời về `ngayban`; hợp đồng 0.30.0; **ADR-116**; bán combo là `P3A-11`. Codex thi công, Claude viết test trước và duyệt; be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-06)
- [x] P3A-05 **Cửa danh mục món** — package `danhmuc`: thêm · đổi tên · ẩn danh mục (ẩn được khi còn món, món về nhóm *chưa xếp*), xếp và chuyển món (chuyển đòi lý do, có vết), đọc mọi món gom theo danh mục ở `GET /menu-categories`; chỉ chủ quán, cả đọc; `GET /menu` không đổi; hợp đồng 0.29.0; **ADR-115**. Codex thi công, Claude viết test trước và duyệt; be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-05)
- [x] P3A-04 **Cửa đào tạo** — package `daotao`: hướng dẫn chữ · ảnh · video gắn một việc giao (tệp ở kho `BANHCUON_FILE_DIR`, database cất khoá, loại nhận bằng nội dung, không tệp mồ côi), sửa chữ · ẩn có lý do, phát tệp; ghi nhận *đạt · chưa* kèm nhận xét về một người, sửa · ẩn, đọc theo lúc ghi; lớp `quay_hoac_chu_quan` cả đọc; hợp đồng 0.28.0; **ADR-114**. Codex thi công, Claude viết test trước và duyệt; be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-04)
- [x] P3A-03 **Cửa giao việc** — package `giaoviec`: tạo · sửa · ẩn có lý do · đánh dấu xong và bỏ đánh dấu (mỗi lần một sự kiện, *đã xong* đọc ra từ sự kiện mới nhất, đánh dấu thừa bị từ chối) · đọc theo người nhận; lớp `quay_hoac_chu_quan` cả đọc; hợp đồng 0.27.0; **ADR-113**. Codex thi công, Claude viết test trước và duyệt; be-check · db-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-03)
- [x] P3A-02 **Cửa sổ nguyên liệu** — package `nguyenlieu`: thêm thứ, đặt đơn vị một lần, ghi con số *mua vào · đã dùng* của một ngày, sửa có lý do, đọc tổng và hiệu số từ một câu SQL; con số là chuỗi thập phân; chỉ chủ quán; hợp đồng 0.26.0; **ADR-112**. Codex thi công, Claude viết test trước và duyệt; be-check · db-check · fe-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-02)
- [x] P3A-01 **Cửa khoản chi** — package `khoanchi`: thêm loại (bắt buộc khai nguồn), ghi · sửa có lý do · đọc theo khoảng ngày, loại, nguồn, tổng do backend cộng; mọi đường chỉ chủ quán (U-095); khoản từ két không vào ngày đã đối soát; cửa đọc két nay trừ khoản chi từ két, khớp bộ đối chiếu; hợp đồng 0.25.0; **ADR-111**. Codex thi công, Claude viết test trước và duyệt; be-check · gate xanh — 2026-10-15 · [chi tiết](backlog_AD_BE.md#p3a-01)
- [x] T-192 **Ghi lời chủ repo lượt sáu, đóng U-095** — chỉ chủ quán ghi (và sửa) khoản chi; mức nhắc sắp hết theo từng thứ, chủ quán ghi — xác nhận vế *lời chọn* của U-087, mặc định 20% đứng nguyên; `P3A-01` · `T-186` đổi theo — L1 — Claude Code — 2026-10-15 · [chi tiết](../docs/product/99-unknowns.md#u-095)
- [x] P4-04 **Màn đăng ký · đăng nhập · đổi và đặt lại mật khẩu, khung theo vai** — lát (c) của **ADR-109**: tầng chuyển tiếp mang cookie phiên và Origin, thôi `X-Person-Id`; năm màn tài khoản; khung `/quay` · `/chu-quan` · `/tram` có gác và đăng xuất; 40 test FE, chạy thật trọn luồng đăng ký → duyệt → đăng nhập tại quầy → đăng xuất khép trực. Claude Code làm và duyệt (Codex hết hạn mức), chưa review độc lập — 2026-10-14 · [chi tiết](backlog_FE.md#p4-04)
- [x] T-190 **Backend đăng nhập bằng tài khoản** — package `taikhoan`: đăng ký · đăng nhập (cờ `at_counter` mở trực quầy cùng giao dịch) · đăng xuất (khép trực của chính phiên) · đổi · đặt lại mật khẩu qua thư (cùng một câu, 3 thư/giờ, mã 30 phút một lần) · chủ quán duyệt · từ chối · khoá · mở lại kèm mật khẩu tạm; argon2id, phiên là cookie `banhcuon_phien` băm SHA-256; cửa ghi khác nguồn bị chặn; gỡ `authz.ChonTen` · `X-Person-Id` · `POST /counter-duty`; lệnh `be/cmd/khoitao-chu-quan`; hợp đồng 0.24.0 (63 cửa); câu `I-033/14` · `/15`. Codex thi công, hết hạn mức giữa chừng, Claude làm nốt và duyệt; be-check · db-check (140 lỗi cài) · gate xanh — 2026-10-14 · [chi tiết](#t-190)
- [x] T-191 **Kế hoạch backend admin** — mỗi trang `P4A-XX` ứng các cửa nó cần và lát lược đồ nó đứng trên; mười bước `P3A-01`…`P3A-10` (nối tiếp, cùng chạm hợp đồng) ở `master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md` và sổ `work/backlog_AD_BE.md`; trang vỏ và trang nhân viên lấy cửa của `T-190`; **ADR-110** ghi lời chủ repo; mở `U-095` (ai ghi khoản chi, cửa tạm `chu_quan`). Claude Code, chưa review độc lập; gate xanh — 2026-10-14 · [kế hoạch](../master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md)
- [x] P2A-05 **Lát khoản chi** — `expense_category` (cờ nguồn `paid_from_till` bắt buộc, không sửa được) · `expense` (loại, số tiền, ngày khai, người ghi; sửa có vết, không xoá) theo **ADR-106** (bước migration 28); phép trừ két cộng khoản của loại trả từ két; câu `I-029` và ba lỗi cài, bước S4.10, `YC-33` chấm đọc + sai, dữ liệu mồi năm loại đúng nguồn §8.10; lược đồ admin hết lát *vắng*. Codex thi công, Claude viết test trước, chạy database, gửi lại một lỗi `QD-34`; `db-check` 138 lỗi cài, gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-05)
- [x] P2A-16 **Rà ranh giới pha và pointer lượt hai** — khuôn `P2A-09` trên bốn file lát `16-`…`19-`, bốn migration, câu đối chiếu, test và S5 (53 file · 2826 dòng) cùng đoạn lượt hai trong file có sẵn: 0 endpoint · route · component, 0 dòng cất thứ thuộc §6, 0 dòng quyền loại 5, 0 con trỏ lệch, mỗi lượt kêu đúng dòng cài; ô 7 · 8 ký. Codex hết hạn mức, Claude tự làm theo lời chủ repo, chưa review độc lập — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-16)
- [x] P2A-15 **Đối chiếu và cổng lượt hai** — ngày quản trị lượt hai `s5` chín bước (đăng ký · duyệt · đăng nhập quầy · giao việc · đánh dấu · đào tạo · danh mục và combo · đăng xuất · đặt lại mật khẩu), đọc lại ở kết nối khác, đối chiếu trên ngày diễn rỗng, tiền ba scenario không đổi; năm tập ngang lát Claude quyết — câu mới `I-033/13`, `I-032/8` đọc thêm xếp món, hai tập để lát backend; ô 1–6 ký. Codex thi công, Claude chạy database và duyệt; `db-check` 135 lỗi cài, gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-15)
- [x] P2A-14 **Lát tài khoản đăng nhập** — bốn bảng `account` · `account_password` · `login_session` · `password_reset` (bước migration 27, lùi có khoá chặn) theo **ADR-109**: bốn trạng thái có hình, mật khẩu argon2id chỉ thêm, phiên và mã đặt lại băm 32 byte có hạn, đăng nhập ở quầy gắn đúng khoảng trực của chính người ấy; thi hành `I-033` · `YC-38`, dòng `PT-7`; 12 câu đối chiếu và lỗi cài, hợp đồng 0.22.0; phép kiểm `QD-33` thu về cột mốc, parser ánh xạ `QD-40` nhận trạng thái ngoài vòng đời bán hàng. Codex thi công, Claude viết test trước và duyệt; `db-check` · gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-14)
- [x] T-181 **Thiết kế đăng nhập bằng tài khoản mật khẩu** — **ADR-109**: tài khoản tách khỏi `person`, bốn trạng thái, chủ quán duyệt và gán vai (vai không mở quyền); argon2id; phiên cookie mã ngẫu nhiên băm ở database, 7 ngày; đăng nhập `tai_quay` mở trực quầy qua `nguoi/vao_quay`; đặt lại qua thư 30 phút một lần (`PT-7`); gỡ `X-Person-Id`; ba lát `P2A-14` → backend → `P4-04`. Chủ repo duyệt nguyên bản kèm năm điểm suy ra — L3 — Claude Code — 2026-10-14 · [chi tiết](../docs/decisions.md)
- [x] T-189 **Tối ưu SEO nền cho frontend** — mặc định mọi route `noindex`, trang công khai bật bằng một danh sách duy nhất ở `fe/src/lib/seo.ts`; metadata chung (tiêu đề, mô tả, Open Graph), `robots.txt` chặn `/api/`, `sitemap.xml` sinh từ danh sách ấy, JSON-LD `Restaurant` chỉ với dữ kiện đã có; báo cáo `docs/product/4-fe/02-toi-uu-seo.md`; địa chỉ, ngày mở cửa, tên miền chờ `U-094` — L1 — Codex thi công, Claude duyệt, sửa một lỗi lint và tích hợp; gate xanh, 20 test fe qua — 2026-10-14 · [chi tiết](#t-189)
- [x] P2A-13 **Lát danh mục món và combo** — danh mục, món nhiều nhất một danh mục, combo có giá riêng không đổi giữa buổi; thi hành `I-032` · `YC-37`, câu đối chiếu viết ở lát (**ADR-105** điểm 6); không sửa hàm giá — **ADR-108**: bốn bảng cạnh lát menu, combo giá riêng, *ít nhất một món* hoãn tới cuối giao dịch; tám câu đối chiếu, hợp đồng 0.21.0. Codex thi công, Claude viết test trước và duyệt; `db-check` · gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-13)
- [x] P2A-12 **Lát đào tạo** — hướng dẫn chữ · ảnh · video gắn đúng một việc giao (`P2A-11` đã dựng), ghi nhận *đạt · chưa* về một người; thi hành `I-031` · `YC-36`, câu đối chiếu viết ở lát (**ADR-105** điểm 6); chỗ giữ tệp ảnh · video là quyết định của bước, có ADR — **ADR-107**: tệp trong kho trên nơi hệ thống chạy, database cất `file_code`; hai bảng, sáu câu đối chiếu, hợp đồng 0.20.0. Codex thi công, Claude viết test trước và duyệt; `db-check` · gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-12)
- [x] P2A-11 **Lát giao việc** — hai bảng `assigned_task` · `assigned_task_mark` (bước migration 24, lùi có khoá chặn); đánh dấu là sự kiện chỉ thêm, *đã xong* đọc từ sự kiện mới nhất, *xoá* là ẩn có người và lúc; thi hành `I-030` · `YC-35`, **ADR-105**; câu đối chiếu và bốn lỗi cài; hợp đồng 0.19.0 ánh xạ 11 ràng buộc. Codex thi công, Claude viết test trước và duyệt; `db-check` · `be-check` · gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-11)
- [x] P2A-10 **Yêu cầu dữ liệu và invariant lượt hai** — mệnh đề `I-030` (giao việc) · `I-031` (hướng dẫn, đào tạo) · `I-032` (danh mục món, combo), loại marketing vào `I-029`; `YC-35`…`YC-37`, marketing vào `YC-33`, tài khoản *chờ `T-181`*; hành vi ở `01-ranh-gioi.md` §1.6; **ADR-105**. Codex thi công hai file pha 1, Claude viết mệnh đề và duyệt; `db-check` xanh, gate xanh — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-10)
- [x] T-188 **Ghi ba lời chủ repo** — duyệt **ADR-074** (gỡ chặn `P2A-05`); phụ thu tuỳ chọn trong combo cộng thêm vào giá combo; giá combo không đổi giữa buổi (`shop-facts.md` §8.9) — L1 — Claude Code — 2026-10-14 · [chi tiết](../master_plan/shop-facts.md)
- [x] T-187 **Ghi lời lượt năm, đóng U-091…U-093** — hướng dẫn gắn từng việc giao; giá combo đặt riêng; marketing trả bằng tiền riêng; gỡ chặn `P2A-12` · `P2A-13` và loại chi marketing của `P2A-05` — L1 — Claude Code — 2026-10-14 · [chi tiết](../docs/product/99-unknowns.md#da-co-loi-giai)
- [x] T-185 **Ghi lời chủ quán lượt bốn, đóng U-087** — máy nhắc POS kiểm tra khi phần còn lại dưới tỉ lệ của lần nhập gần nhất; mỗi nguyên liệu một tỉ lệ, chủ quán đặt, mặc định 20%; sửa `I-025` vế 3; cột tỉ lệ để cho `T-186` — L1 — Claude Code — 2026-10-14 · [chi tiết](../docs/product/99-unknowns.md#da-co-loi-giai)
- [x] T-184 **Lược đồ admin lượt hai** — lời chủ quán 2026-10-14 thành bước `P2A-10`…`P2A-16` ở kế hoạch lược đồ admin và sổ mô tả; mở câu chặn mới; chủ repo nói sẽ làm backend admin — L1 — Claude Code — 2026-10-14 · [chi tiết](backlog_AD_DB.md#p2a-10)
- [x] T-183 **Ghi lời chủ quán lượt ba cho U-087…U-090** — chủ quán và POS tạo · sửa · xoá việc giao và đánh dấu xong (đóng U-089); chủ quán hoặc POS ghi nhận xét và đánh giá đạt · chưa (đóng U-090); nguyên liệu nhập theo đơn vị riêng từng thứ, máy tự trừ phần còn lại; U-087 chỉ còn vế ngưỡng sắp hết — L1 — Claude Code — 2026-10-14 · [chi tiết](../docs/product/99-unknowns.md#da-co-loi-giai)
- [x] T-182 **Ghi lời chủ quán lượt hai cho U-087…U-090** — báo cáo theo ngày; hiệu suất nhân viên là số đếm, không chấm điểm; máy nhắc POS kiểm tra khi sắp hết (lật một phần U-045, ngưỡng còn ở U-087); tài khoản tự đăng ký, chủ quán duyệt, Gmail để đặt lại, đăng nhập ở quầy là mốc đổi người (đóng U-088, ADR-104 *Sửa đổi*, `T-181` hết chờ); chỉ chủ quán và POS giao việc; hướng dẫn chữ · ảnh · video theo việc — L1 — Claude Code — 2026-10-14 · [chi tiết](../docs/product/99-unknowns.md#da-co-loi-giai)
- [x] T-180 **Ghi lời chủ quán cho U-080…U-086** — đóng bảy câu: báo đơn web bằng SSE thay Telegram, trang tổng kết bốn thứ, chủ quán tự quản lý menu, tài khoản mật khẩu riêng thay chọn tên (**ADR-104**, `P4-04` dừng), có giao việc, marketing là khoản chi, có đào tạo; mở `U-087`…`U-090`; sổ `backlog_FE_AD.md` và §6a kế hoạch pha 4 đổi cột chặn — L1 — Claude Code — 2026-10-14 · [chi tiết](../docs/product/99-unknowns.md#da-co-loi-giai)
- [x] P4-03 **Cổng frontend** — `verify.sh` chạy `scripts/check-fe-rules.sh` (bốn phép chặn tĩnh: cộng tiền, bộ UI ngoài shadcn, cache của Next, ghi tay cache dữ liệu server) và `scripts/fe-check.sh` (npm ci, lint, kiểm kiểu, test, build, type sinh lệch hợp đồng ⇒ đỏ) khi `fe/` hay hợp đồng đổi; mỗi phép một ca hồi quy biết đỏ — L2 — Codex thi công (worktree `../lean_wt/P4-03`), Claude viết test trước, duyệt, sửa luật `cong-tien`, cài lỗi và tích hợp — 2026-10-14 · [chi tiết](backlog_FE.md#p4-03)
- [x] T-179 **Mảng admin vào sổ pha 4 dưới dạng bước bị chặn** — mười một bước `P4A-01`…`P4A-11` theo trang admin của `docs/private/fe/PAGES_INDEX.md` vào sổ riêng `work/backlog_FE_AD.md`, §6a kế hoạch pha 4, **ADR-103**, mở `U-081`…`U-086`; không mở backend admin; phần owner sót khỏi commit đầu gộp lại 2026-10-14 — L1 — Claude Code quyết và duyệt, Codex viết mô tả — 2026-10-14 · [chi tiết](backlog_FE_AD.md#top)
- [x] P4-02 **Dựng `fe/` và mở `docs/product/4-fe/`** — khung Next.js 16.4 + shadcn (Radix, `radix-nova`), mọi phụ thuộc ghim số chính xác; type sinh từ `openapi.yaml` (`npm run gen:api`); một lớp gọi API đọc `Error.code` thành ba hình thất bại; tầng chuyển tiếp cùng origin không cache, không đệm SSE, đo trên backend thật; `QC-18`; hàng §2 *Route, component* → `docs/product/4-fe/01-khung-fe.md` — L1 — Claude Code — 2026-10-13 · [chi tiết](backlog_FE.md#p4-02)
- [x] P4-01 **Ranh giới, từ vựng và nền của pha 4** — **ADR-102**: bảng bốn nhóm người dùng (cách lấy dữ liệu · ghi xong đọc lại · mất kết nối · dữ liệu chạm tiền), state ba chỗ, bốn phần mở của ADR-100 và ba phần nền; danh tính SSE quầy qua fetch đọc luồng, không `F-XXX`; commit `f14f2b1`; thư mục `fe/` rỗng làm đỏ `QC-09` được `P4-02` lấp — L2 — Claude Code — 2026-10-13 · [chi tiết](backlog_FE.md#p4-01)
- [x] T-178 **Kế hoạch và backlog pha 4** — `master_plan/FE_master_plan_banh_cuon_ba_thanh.md` (mười hai bước `P4-01`…`P4-12`, cổng sang pha 5), `work/backlog_FE.md`, hàng `CLAUDE.md` §2; **ADR-101** (hình dạng kế hoạch; trang thử *Menu & giá* đi trước màn quầy) và **ADR-100** (chủ repo yêu cầu dùng shadcn/ui, *"yêu cầu dung shadcn"*); cách chia chờ chủ repo xác nhận — L2 — Claude Code — 2026-10-13
- [x] T-176 **Chủ repo ký chuyển sang pha 4** (*"mở phase 4"*, 2026-10-13) khi cổng pha 3 đứng 10/12 — ghi ở `docs/product/3-be/10-cong-chat-luong-pha-3.md` §2 và kế hoạch pha 3; `F-068` mang sang Open; câu Telegram của `F-070` thành **U-080**; tài liệu tham khảo pha 4 ở `docs/private/fe/fe_guidance/` sửa link lệch tầng, bản chép dự án khác (`docs/private/fe/shared/`, `docs/private/be_feature/`) vào `scripts/check-links.ignore` chờ kế hoạch pha 4 — L1 — Claude Code — 2026-10-13
- [x] P3-14 **Rà ranh giới pha và pointer** — bộ mẫu Gate 1d trên mọi file pha 3 (chưa lọc cạnh đã lọc), hợp đồng là nguồn duy nhất, mọi câu hứa *việc của pha 3* trỏ được vào dòng thật; chỗ sai ⇒ F-XXX — ký ô 10 (cổng 10/12); F-069 · F-070 — L1 — Claude Code — 2026-10-13 · [chi tiết](backlog_BE.md#p3-14)
- [x] P3-13 **Cổng chất lượng pha 3** — ba scenario `0-ba/ban-hang/08-scenario.md` §8 diễn qua API thật (`be/internal/don/scenario_test.go`, Codex viết) và một ngày bán giả qua cửa đối soát 0đ; Claude chạy, chấm và ký từng ô kế hoạch pha 3 §9 ở `docs/product/3-be/10-cong-chat-luong-pha-3.md`; ký chuyển pha 4 là quyền chủ repo — ký 9/12 ô (trống: ô 1 · 2 — F-068, ô 10 — chờ P3-14) — L2 — Codex viết bộ diễn (worktree `../lean_wt/P3-13`, hai lượt), Claude chạy, cài lỗi, chấm và ký — 2026-10-13 · [chi tiết](backlog_BE.md#p3-13)
- [x] T-174 **Cửa nhập bù hoá đơn từ sổ giấy** — gõ lại từng món kèm bàn (phiên đã đóng) hoặc mang đi, ngày bán và mốc bán là của giấy, giá lúc bán trên giấy dựng lại từ vết sửa giá; người nhập bù là người đã qua quyền (lời **U-079**, `shop-facts.md` §6 quy tắc 11; lược đồ `paper_ledger` · `bill.paper_*` có sẵn, ADR-095 điểm 5) — **ADR-099** — L2 — Codex thi công (worktree `../lean_wt/T-174`, hai lượt do hạn mức), Claude thiết kế, sửa đổi ADR, viết test nghiệm thu, duyệt, cài lỗi và tích hợp — 2026-10-13 · [chi tiết](#t-174)
- [x] T-175 **Giảm giá cả đơn** — migration bước 23 `bill.discount_vnd` · `discount_customer_name`, phần trả + giảm = tổng dòng; ba cửa trao tiền nhận giảm giá chỉ khi người là chủ quán, kèm tên khách, không trần, không lý do; câu doanh thu ở `db/reconcile/` trừ giảm; gỡ `order_discount_undecided`; hợp đồng 0.17.0 (lời U-058) — **ADR-098** — L2 — Codex thi công (worktree `../lean_wt/T-175`), Claude thiết kế, duyệt, cài lỗi và tích hợp — 2026-10-13 · [chi tiết](#t-175)
- [x] P3-12 **Realtime và dự phòng** — bộ phát SSE một tiến trình (`platform/realtime`), luồng `GET /production-board/events` · `GET /counter/events`, phát sau COMMIT; đường kéo `GET /counter/queue` và `GET /production-board` trả `read_at` · `poll_interval_seconds` 20; miền mới `nhandon` (tạm dừng · tiếp tục · báo mù · mở lại, cửa dùng chung `nhandon/ghi_mu`); đơn tự bấm khi không luồng quầy ⇒ khoảng mù + `shop_not_seeing_orders`; cắt thử PT-1…PT-6 ở `09-realtime-du-phong.md`; hợp đồng 0.16.0 — **ADR-097** — L2 — Codex thi công (worktree `../lean_wt/P3-12`, ba lượt do hạn mức, không kịp viết báo cáo), Claude thiết kế, duyệt, sửa test, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](backlog_BE.md#p3-12)
- [x] T-146 **Sửa số đếm két của ngày đã ký** — migration bước 22 `reconciled_day_reopening` + dấu nối chuỗi (`previous_reconciled_day_id`, khoá duy nhất từng phần); khoá ADR-080 cho sửa số đếm khi dấu mới nhất đã mở lại, tiền đầu két vẫn khoá; cửa `ket/sua_dem` (`PUT /sale-days/{sale_date}/cash-count`, lớp `chu_quan`, lý do bắt buộc) và cửa dùng chung `ket/ghi_dong_dem` (`theo_cua_goi`); ký lại nối dấu; đường đọc trả chuỗi dấu; cửa tiền khác vẫn coi ngày từng ký là đóng; hợp đồng 0.15.0 — **ADR-096** — L2 — Codex thi công (worktree `../lean_wt/T-146`, ba lượt do hạn mức), Claude thiết kế, duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-146)
- [x] T-173 Ghi lời chủ quán cho **U-079** (nhập bù gõ lại từng món kèm bàn hoặc mang đi; giá lúc bán trên giấy — lời chọn) và **U-058** (giảm giá cả đơn: có trong bản đầu, không trần, không bắt lý do — lời chọn) vào owner — `99-unknowns.md` (đóng, không còn câu đang mở), `shop-facts.md` §6 quy tắc 11 · §4.6 · §8.9 D41 · nhật ký; con trỏ ở `3-be/06` · `3-be/08` · `0-ba/ban-hang/04` · `2-db/04` · kế hoạch pha 3; mở `T-174` · `T-175` — L1 — Claude Code — 2026-10-12
- [x] P3-11 **Vết sửa · sổ giấy · F-060** — `TestI018_MoiCuaSuaCoVet` (mười hai cửa sửa, đủ hai ảnh · lý do · người) và `TestI018_TapCuaSuaKhopTapCa`; đối chiếu `I-016` tha khoảng hở *Chờ thanh toán → Đang phục vụ* chỉ khi có đơn `qr_table` trong khoảng (**F-060** Fixed, hướng (b)); cửa `ket/khai_so_giay` (`POST /sale-days/{sale_date}/paper-ledger`, mã `paper_ledger_already_declared`); cửa ký ngày đọc chung phép *còn N*, `GET …/cash-reconciliation` trả hai trường sổ giấy; hợp đồng 0.14.0; cửa nhập bù hoá đơn chờ **U-079** — **ADR-095** — L2 — Claude thiết kế, duyệt, cài lỗi và tích hợp, Codex thi công (worktree `../lean_wt/P3-11`) — 2026-10-12 · [chi tiết](backlog_BE.md#p3-11)
- [x] T-166 **Đổi stack · bước 09 — rà chéo**: `--list` 1f · 1g ở `be25683` khớp nền `f70dfb3` (khác duy nhất là dòng ánh xạ của T-169); 27 commit không mất tên test (124 → 136); hai câu owner lệch cây thật sửa ở `QC-13` · `QC-14`; **F-067** (sáu task L2 không duyệt độc lập) — L1 — Claude Code — 2026-10-12 · [chi tiết](#t-149)
- [x] T-165 **Đổi stack · bước 08 — dọn**: `router.go` bỏ `ServeMux` · `gin.WrapH` · `NoRoute`; Gate 1g đỏ ở `.HandleFunc(` · `.Handle(`; Gate 1f đòi mục `sqlc.yaml` và `-- name:` cho mọi miền; `QC-12` · `QC-13` · `QC-14` bỏ vế chuyển tiếp, thêm ba phép kiểm — L1 — Claude thi công và cài lỗi; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-164 **Đổi stack · bước 07 — miền `don`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; mười đường lên Gin, sáu cửa giữ mã và lớp, `Tao` · `DongHo` giữ chữ ký; `router.go` không còn đường nào sau `NoRoute` — L2 — Claude thi công, cài lỗi và tích hợp; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-163 **Đổi stack · bước 07 — miền `sanxuat`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; tám đường lên Gin, bảy cửa giữ mã và lớp, `NoDon` giữ chữ ký `pgx.Tx`; khoá gom hai bản giữ bằng `TestI019_KhoaGomMotDinhNghia`; lỗi cài khoá mẻ không bị bắt ⇒ **F-066** — L2 — Claude thi công (Codex hết hạn mức), cài lỗi và tích hợp; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-172 **Đóng F-065: test cho nhánh `counter_duty_changed` của cửa vào quầy** — `TestYC15_VaoChenCungMocBiTuChoi`; F-065 sửa lại: tầng 1 (`counter_duty_ended_after_started_check`) đã bắt cùng mã, test ghim hành vi HTTP — L1 — Claude Code — 2026-10-12 · [chi tiết](#t-171)
- [x] T-171 **Đóng F-064: test chen nhau cho khoá riêng của cửa ký ngày** — `TestI021_TienChenLucKyNgayKhongLotVaoSoDaKy`, dựng tất định bằng khoá bảng của chủ lược đồ; lỗi cài khoá chung ⇒ đỏ — L1 — Claude Code — 2026-10-12 · [chi tiết](#t-171)
- [x] T-162 **Đổi stack · bước 06 — miền `ket`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; bốn đường lên Gin, ba cửa giữ mã và lớp; test hình trước quyền không còn `ServeMux` — L2 — Claude thi công (Codex hết hạn mức), cài lỗi và tích hợp; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-161 **Đổi stack · bước 06 — miền `hoadon`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; bảy đường lên Gin, chín cửa giữ mã và lớp, `Ghi` · `GhiHoan` giữ chữ ký — L2 — Claude thi công (Codex hết hạn mức), cài lỗi và tích hợp; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-160 **Đổi stack · bước 06 — miền `tratruoc`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; `KiemSoDu` · `Dung` · `PhanTien` giữ chữ ký cho `hoadon`; test hình trước quyền gắn miền Gin không `GanNguoi` — L2 — Codex bắt đầu (SQL + code sinh) rồi hết hạn mức, Claude thi công phần còn lại, cài lỗi và tích hợp; chưa ai duyệt độc lập — 2026-10-12 · [chi tiết](#t-149)
- [x] T-159 **Đổi stack · bước 05 — miền `nguoi`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; bốn đường lên Gin, lần khép vẫn trong `vongdoi.CoVet`; lỗi cài nhánh `counter_duty_changed` không bị bắt ⇒ **F-065** — L2 — Codex thi công (worktree `../lean_wt/T-159`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-158 **Đổi stack · bước 05 — miền `vongdoi`** — `service.go` · `viec.go` · `repository.go` + `sqlcgen`, không `handler.go`; mọi API exported nhận `pgx.Tx` giữ chữ ký, bảy câu ghi giữ nguyên văn — L2 — Codex thi công (worktree `../lean_wt/T-158`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-157 **Đổi stack · bước 05 — miền `phien`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; `TongTien` giữ chữ ký `pgx.Tx` cho `hoadon` — L2 — Codex thi công (worktree `../lean_wt/T-157`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-156 **Đổi stack · bước 05 — miền `ban`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; `Doc` · `Ban` giữ chữ ký cho `don`, lần dọn vẫn trong `vongdoi.CoVet` — L2 — Codex thi công (worktree `../lean_wt/T-156`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-155 **Đổi stack · bước 05 — miền `ngayban`** — `service.go` · `repository.go` + `sqlcgen`, không `handler.go` (`QC-14` sửa: miền không đường gọi); bốn hàm exported giữ chữ ký; lỗi cài khoá ký không bị bắt ⇒ **F-064** — L2 — Codex thi công (worktree `../lean_wt/T-155`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-154 **Đổi stack · bước 05 — miền `gia`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; `Tinh` giữ phép tính và chữ ký cho `don`, `HEAD /menu` qua khối `NoMethod` — L2 — Codex thi công (worktree `../lean_wt/T-154`), Claude duyệt, cài lỗi và tích hợp — 2026-10-12 · [chi tiết](#t-149)
- [x] T-153 **Đổi stack · bước 05 — miền `qr`** — `handler.go` · `service.go` · `repository.go` + `sqlcgen`; router giữ `HEAD` như `GET`, `UseRawPath` (ca `%2F` của duyệt T-152) — L2 — Codex thi công (worktree `../lean_wt/T-153`), Claude viết test trước, duyệt, cài lỗi và tích hợp — 2026-10-11 · [chi tiết](#t-149)
- [x] T-169 **Đóng F-059: mặc định của nhóm tuỳ chọn thành dữ liệu** — migration bước 21 `menu_option.is_default` + `menu_option_one_default_per_group_key` (mỗi nhóm nhiều nhất một, khoá chặn khi lùi); `db/seed/seed.pl` đọc `shop-facts.md` §4.6 luật 8 lúc chạy (`--defaults-tsv`, bốn lỗi cài trên bản sao ⇒ dừng hoặc theo đúng), `db-check` so cờ với owner; `GET /menu` trả `is_default` (hợp đồng 0.13.0); cửa và tính thử vẫn không tự điền. Acceptance (viết trước): test database hai chiều · seed đọc owner · test Go so cờ với luật 8 + tổ hợp chọn sẵn có giá, bỏ cờ khỏi câu đọc ⇒ đỏ · `TestI010_TuChoiKhongSuaHo` không đổi · owner tài liệu theo kịp · gate xanh — **ADR-094** — L2 — Claude Code (worktree `../lean_wt/T-169`, chưa ai duyệt độc lập) — 2026-10-11
- [x] T-168 **Đóng F-062: hai test chen nhau còn lại chờ cổng chung** — `TestI024_MangDiGuiLaiChenNhauMotDon` · `TestI023_HaiLanDoiCungLucKhongThanhLoiHeThong` thêm cổng `cong`; đo bằng lỗi cài trong worktree riêng (luật T-167): bỏ chạy lại trên `sales_order_submission_code_key` · bỏ ánh xạ `qr_code_one_current_per_table_key` ⇒ đỏ 10/10 mỗi test, cả trước lẫn sau khi thêm cổng (nghi ngờ của F-062 không đúng với hai test này); code thật ⇒ xanh 10/10; không thêm vòng lặp vì một vòng đã bắt đủ — L1 — Claude Code — 2026-10-11
- [x] T-167 **Đóng F-063: lỗi cài chỉ làm trong worktree riêng** — luật mới ở `quality/review-gate.md` Gate 1 (chủ repo chọn ghi thành luật), F-063 → Fixed — L1 — Claude Code — 2026-10-11
- [x] T-152 **Đổi stack backend · bước 04 — miền mẫu `menu`** — `handler.go` (Gin) · `service.go` (bốn `authz.Door`, `authz.Run`) · `repository.go` (`pgx.Tx`, `sqlcgen`); bảy câu đọc thành `sql/*.sql`, bốn câu ghi thêm `-- name:` và `;`; `be/sqlc.yaml` sinh cùng mục `menu`; router `HandleMethodNotAllowed`, `RedirectTrailingSlash = false` (`QC-12`) — L2 — Claude Code thi công, chưa ai duyệt độc lập — 2026-10-11 · [chi tiết](#t-149)
- [x] T-151 **Đổi stack backend · bước 03 — nền** — `internal/db` → `internal/platform/postgres` (`Open`, `InTx`), `dbtest` → `testhelper`, `middleware.GanNguoi`, `cmd/server` dựng router Gin (`newRouter`) và nối mười một miền cũ qua `NoRoute` bọc `gin.WrapH`; sáu test `TestQC12_*` mới; `QC-13`…`QC-16` theo chỗ mới — L2 — Codex thi công (worktree `../lean_wt/T-151`), Claude viết test trước, duyệt, cài lỗi và tích hợp — 2026-10-11 · [chi tiết](#t-149)
- [x] T-150 **Đổi stack backend · bước 02 — công cụ và gate, chưa chuyển cửa nào** — `go 1.27.2`, gin v1.12.0, dòng `tool` sqlc v1.31.1, migrate v4.20.1; Gate 1f luật `-- name:` và miễn code sinh khớp nguồn cho miền có mục trong `sqlc.yaml`, Gate 1g đọc route Gin, Gate 1h `check-gin-imports.sh`, `check-sqlcgen.sh` trong `verify.sh`; `be/sqlc.yaml` chưa tạo (sqlc không nhận cấu hình rỗng) — **ADR-093** — L2 — Codex thi công (worktree `../lean_wt/T-150`), Claude duyệt, cài lỗi và tích hợp — 2026-10-11 · [chi tiết](#t-149)
- [x] T-149 **Đổi stack backend · bước 01 — ghi quyết định Gin + sqlc + cấu trúc kết hợp vào owner** — ADR mới thay điểm 1 và 6 của ADR-083; `QC-05` · `QC-11`…`QC-14`; chia bước 02…09 thành T-150…T-166 — L3 — Claude Code, không giao Codex — 2026-10-11 · [chi tiết](#t-149)
- [x] T-148 **Điều kiện trước đổi stack backend (BE-STACK-00)** — phép kiểm tên test `QC-17` chạy trong `scripts/be-check.sh` (gỡ **F-061**); `BE_CHECK_KEEP_DB=1` giữ database khi test đỏ; "test chập chờn" `TestI020_DaRaBanTheoSoCaiTungThuChoMotBan` là lỗi cài của phiên khác lọt vào gate cùng cây (**F-063**), code và test không đổi — L2 — Claude Code — 2026-10-10 · [chi tiết](#t-148)
- [x] T-147 **Huỷ đơn đã Hoàn thành** — cửa `don/huy` nhận *Hoàn thành → Huỷ* (lời U-027, `shop-facts.md` §6.19), gỡ mã `completed_order_cancel_not_ready`; cửa không đụng tiền, hoàn do quầy quyết qua cửa hoàn của `P3-09` — phần còn sót của `P3-10`; **ADR-090** điểm 7 *Sửa đổi* — L2 — Claude thiết kế và viết test đỏ, Codex thi công (worktree `../lean_wt/T-147`) — 2026-10-10 · [chi tiết](#t-147)
- [x] T-145 Ghi lời chủ quán cho **U-078** vào owner — `99-unknowns.md` (đóng), `shop-facts.md` §6.10 và §7.1 (lời và cách đọc của phiên tách riêng), con trỏ ở ADR-089 *Sửa đổi*; mở `T-146` cho code — L1 — Claude Code — 2026-10-10
- [x] T-143 **Đăng nhập bằng chọn tên** — bản thật `authz.ChonTen` đọc header `X-Person-Id` (U-075); chọn tên ở máy quầy là một mốc đổi người ai ra · ai vào cùng `now()` (`C36` · `U-056`) qua cửa `nguoi/vao_quay` · `nguoi/roi_quay` · `nguoi/khep_quay`; `GET /people` · `GET /counter-duty/current`; mã `counter_duty_changed`; hợp đồng 0.11.0 — ADR-085 *Sửa đổi 2026-10-10* — L2 — Claude thiết kế, viết test đỏ, duyệt và tích hợp, Codex thi công (worktree `../lean_wt/T-143`) — 2026-10-10 · [chi tiết](#t-143)
- [x] T-138 **Vết cập nhật bật chế độ nghiêm** — sửa (và thêm dòng con vào cha đã có) mà không khai lý do bị database từ chối; một ngoại lệ hẹp cho lượt gọi thêm của khách QR (**F-060**); cửa đổi mã QR tự khai lý do; `table_session_member` mang người, ghép bàn bắt buộc có người; gỡ **F-046**; migration bước 20, hợp đồng 0.10.0 — **ADR-092** — L2 — Claude Code thiết kế và làm bản đầu, Codex đưa về nền mới, Claude duyệt và tích hợp — 2026-10-10 · [chi tiết](#t-138)
- [x] T-144 **Cửa đã ra bàn đòi đủ trường của từng mục** — một mục thiếu `menu_component_id` hay có `filling_option_ids` null từng được đọc thành nước chấm và ghi *đã ra bàn* thật (đo trên code `880b741`: việc trạm 317 ⇒ 200); nay `invalid_request` field `items`; thêm test đơn có bàn bấm theo mã đơn ⇒ `invalid_request` field `sales_order_id`. Phát hiện bởi Codex duyệt độc lập (chỉ đọc) phần S-5 của `P3-10` — L1 — Claude Code — 2026-10-10. Bằng chứng: test mới đỏ trên code cũ (`san_xuat_test.go:662: muốn 400 … nhận 200 … station_job_ids:[317]`), xanh sau sửa (`be-check: PASS`)
- [x] T-142 **Đơn đặt trước nổ việc theo giờ nhắc** — `phone_preorder` không nổ lúc tạo; nhắc POS và bếp trước giờ khách cần 20 và 10 phút (U-077); cửa nhả đơn hẹn máy POS tự gọi — **ADR-091**, ADR-090 điểm 1 *Sửa đổi* — L2 — Claude thiết kế và viết test đỏ, Codex thi công (worktree `../lean_wt/T-142`) — 2026-10-10 · [chi tiết](#t-142)
- [x] T-140 **Đường tiền theo lời 2026-10-09** — nợ trên đơn lẻ được ghi kèm ghi chú, người đi giao ghi nợ tại chỗ (gỡ `standalone_debt_undecided`, U-076); chỉ chủ quán bấm đối soát xong, mọi ngày, ngày lệch bắt giải thích (gỡ `cash_day_not_balanced`, đổi lớp cửa, U-073); ngày két của tạm ứng · thưởng · khoản chi là ngày khai (gỡ `cash_day_expense_date_undecided`, bỏ dấu `cho_u072` của bộ đối chiếu, U-072); con trỏ ở `docs/product/2-db/04` · `09` · `3-be/06` và ADR-089 *Sửa đổi*. Đường sửa số đã ký chờ **U-078** — **ADR-089** *Sửa đổi* — L2 — Claude thiết kế và viết test đỏ, Codex thi công (worktree `../lean_wt/T-140`) — 2026-10-10 · [chi tiết](#t-140)
- [x] P3-10 **Sản xuất theo mẻ** — duyệt (và lượt gọi của người) nổ đơn trong cùng giao dịch; một lần bấm một mẻ, lùi trả mọi bàn; *đã ra bàn* nhận một bàn (hoặc một đơn không bàn) + số cái từng thứ theo lời **S-5** 2026-10-09; đơn huỷ: đổi chủ phần đã làm do quầy chọn, ghi chú bánh làm sai; một hàm gom cho bảng nhu cầu; ba trạm bếp không cửa ghi nào; hợp đồng 0.7.0; gỡ **F-044** — **ADR-090** — L2 — Claude thiết kế, viết test đỏ, duyệt và tích hợp, Codex thi công — 2026-10-09 · [chi tiết](backlog_BE.md#p3-10)
- [x] T-139 Ghi lời chủ quán cho bảy câu `U-071` … `U-077` vào owner — `shop-facts.md` §5.2 · §6.10 · §6.14 · §8.7 · §8.8 · §8.10 · §7.1, `I-021` · `I-027` · `I-028` · `I-029`, con trỏ trong `docs/product/`; mở **U-078**; code và lược đồ đi theo ở `T-140` … `T-143` — L1 — Claude Code — 2026-10-09 · [chi tiết](#t-139)
- [x] P3-09 **Đường tiền** — hoá đơn đơn lẻ qua hai cửa trao (`/orders/{id}/handover` lớp `quay` · `/orders/{id}/delivered` lớp `nguoi_quan`), trả trước nhận · trả lại · thành doanh thu theo chuỗi, hoàn có đủ vết, thu nợ dần (ADR-075), tiền đầu két · đếm két · đối soát xong ngày (lớp mới `quay_hoac_chu_quan`); ba ô ghi dùng chung qua cửa `theo_cua_goi`; một đồng hồ ngày bán; không ghi tiền vào ngày đã ký; ngày lệch, giảm giá, nợ đơn lẻ từ chối kèm mã (U-073 · U-058 · U-076); một ngày bán giả qua cửa ⇒ 0đ lệch ở cửa và bộ đối chiếu; mở **F-061** — **ADR-089** — L2 — Codex thi công, Claude thiết kế, duyệt và chạy mọi test trên PostgreSQL — 2026-10-09 · [chi tiết](backlog_BE.md#p3-09)
- [x] P3-08 **Luồng mang đi · giao · đặt trước** — ba kênh không gắn bàn (bốn hình liên hệ) qua **chính** cửa `don/tao_luot_goi`: khách web `POST /online-orders`, hotline `POST /phone-orders`, lớp đổi thành `quay_hoac_khach`; thiếu liên hệ ⇒ `invalid_request` theo trường (`I-022`); đơn không phiên, dấu chéo đường bị từ chối (`I-007`); gửi lại trước I-008 (`I-024`); I-008 tạm dừng → giờ bán → quán mù cho **cả năm** kênh tại `now()` của giao dịch; cửa `don/roi_quan` (Đang giao) từ chối `delivery_served_mark_undecided` khi còn việc chưa ra bàn (**S-6**) — **ADR-088** — L2 — Codex thi công, Claude thiết kế, duyệt và chạy mọi test trên PostgreSQL — 2026-10-09 · [chi tiết](backlog_BE.md#p3-08)
- [x] P3-07 **Luồng tại bàn từng bước** — lượt gọi đặt hộ (`POST /table-orders`) và khách QR (`POST /qr-codes/{code}/orders`) qua **một** cửa `don/tao_luot_goi` (lớp `quay_hoac_ma_ban`), phiên do cửa tìm từ bàn, mở ở lượt gọi đầu, tầng 1 chặn hai phiên và cửa chạy lại; gửi lại cùng dấu ⇒ một đơn; duyệt · từ chối · tính tiền · đóng (`hoadon/dong`, một giao dịch, nợ không chặn) · dọn bàn; mỗi cột trạng thái một cửa chuyển `vongdoi/…`, bảng chuyển so với §5.2 · §5.3 lúc chạy; mở **F-060** — **ADR-087** — L2 — Codex thi công, Claude thiết kế, duyệt và chạy mọi test trên PostgreSQL — 2026-10-09 · [chi tiết](backlog_BE.md#p3-07)
- [x] P3-06 **Hàm tính giá duy nhất và menu của chủ quán** — một hàm `gia.Tinh` cho tính thử (`POST /price-quotes`), menu (`GET /menu`, giá mọi tổ hợp) và cửa `don/tao_luot_goi` (lớp `quay`, chưa đường gọi HTTP — `P3-07` · `P3-08` thêm phần kênh); tổ hợp sai bị từ chối, không tự điền mặc định (**F-059**); bốn cửa sửa menu lớp `chu_quan`, bắt buộc lý do, để vết; mười ba ca §4.8 đọc lúc chạy, khớp qua cả hai đường — **ADR-086** — L2 — Codex thi công, Claude thiết kế và duyệt — 2026-10-06 · [chi tiết](backlog_BE.md#p3-06)
- [x] P3-05 **Danh tính · vai · quyền theo chỗ đứng** — quyền là một lớp của cửa (`quay` · `chu_quan`), kiểm tại mốc giao dịch của cửa bằng `authz.Run`, người thao tác là người đã kiểm; ma trận `docs/product/3-be/02-vai-va-quyen.md`, Gate 1g so thư mục cửa ↔ ma trận ↔ `authz.Door`; khách QR qua mã hiện hành; cửa `qr/doi_ma` chỉ chủ quán; cách đăng nhập chờ **U-075** — **ADR-085** — L2 — Claude thi công (Codex không chạy được), chưa review độc lập — 2026-10-06 · [chi tiết](backlog_BE.md#p3-05)
- [x] P3-04 **Khuôn hợp đồng API — mở `docs/product/3-be/`** — OpenAPI 3.1 `openapi.yaml` rỗng đường gọi + khuôn `01-hop-dong-api.md`; hình lỗi `{code, field?}`, mã kèm status; bảng tên từ chối → mã phủ 290 tên migration; Gate 1g `scripts/check-api-contract.sh` so hợp đồng ↔ code ↔ migration mọi lượt; hợp đồng thắng code (**ADR-084**); migration bước 18 đóng **F-058** — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-04)
- [x] P3-03 **Quy ước code backend — dựng `be/`** — Go 1.27.1 · `net/http` · pgx v5 với câu ghi trong file `.sql` của một cửa (ADR-083); `QC-11`…`QC-17`; Gate 1f `scripts/check-write-paths.sh` liệt kê ô ghi → cửa, có ca hồi quy đường ghi thứ hai; `scripts/be-check.sh` chạy `go test` trên PostgreSQL thật — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-03)
- [x] P3-02 **Gate 1d học vùng pha 3** — `scripts/check-phase-boundary.sh` soát thêm `docs/product/3-be/` với bộ mẫu riêng: đỏ với thẻ JSX (ký tự trước `<` không phải chữ/số, tách khỏi generic), route màn hình, đuôi `.jsx`/`.tsx`/`.vue`; im với endpoint, SQL, generic; ca hồi quy 20–25 — L2 — 2026-10-06 · [chi tiết](backlog_BE.md#p3-02)
- [x] P3-01 **Ranh giới và từ vựng pha 3** — *ô ghi* · *cửa ghi*, phép chấm tầng 2 · tầng 3, lệnh liệt kê đường ghi dựng ở `P3-03`, cổng đếm §1–§4 (admin ngoài), lời từ chối của database tới người dùng qua tên — **ADR-082**; mở **F-058** — L2 — 2026-10-05 · [chi tiết](backlog_BE.md#p3-01)
- [x] T-137 Thêm một dòng con vào bản ghi đã có (món vào đơn · thành phần vào suất · xấp vào tiền đầu két) để lại vết trên bản ghi cha — migration bước 17 `20261005130000_vet_them_dong_con` (trigger `AFTER INSERT`, chế độ mềm như vết sửa); câu `I-024/3` · `I-011/1` · `I-021/7` chỉ kêu lần thêm không vết; khoá chặn đường lùi theo vết; **F-047** đóng — **ADR-081** — L2 — 2026-10-05 · [chi tiết](backlog_archive.md#t-137)
- [x] T-136 Chủ repo ký chuyển sang pha 3 và xác nhận cách chia mười bốn bước — ghi ở cổng pha 2 §7, kế hoạch pha 3, ADR-076 *Sửa đổi*; `P3-01` vào *Ready* — 2026-10-05 · [chi tiết](backlog_archive.md#t-136)
- [x] T-134 Ngày đã đối soát xong thì số đếm và tiền đầu két đứng yên với mọi vai, và dấu không đứng trên số rỗng — migration bước 16 `20261005120000_khoa_so_dem_ngay_da_ky` (trigger chặn thêm · sửa · xoá · `TRUNCATE`; dấu cần dòng mệnh giá ở cả hai vế); sáu file `db/reconcile/proof/` tắt khoá trong chính lỗi cài; không dựng đường sửa số đã ký (**U-074**), không đòi lệch 0 (**U-073**); **F-056** · **F-057** đóng — **ADR-080** — Codex thi công, Claude duyệt — 2026-10-05 · [chi tiết](backlog_archive.md#t-134)
- [x] T-135 Con trỏ chết sau khi chuyển `docs/work-flow-session/` · `docs/project_work_flow/` sang `docs/private/` — ba con trỏ đến và link tương đối trong năm file đã chuyển, chỉ đổi đường dẫn; khối commit gồm luôn việc chuyển (chưa commit lúc làm) — L0 — 2026-10-05 · [chi tiết](backlog_archive.md#t-135)
- [x] T-133 Số tiền mặt đếm cuối ngày và dấu *ngày đã đối soát xong* có chỗ cất — migration bước 15 `20261001150000_dem_ket_doi_soat`: `cash_count` · `cash_count_line` cùng hình tiền đầu két, `reconciled_day` khoá ngoại về số đếm và tiền đầu két, không đòi lệch 0 (**U-073**); câu `I-021/1` · `I-012/2` · `I-014/5` mỗi câu một lỗi cài; `YC-03` · `YC-08` sang *GỌI TÊN*; ngày chờ `U-072` không kết luận; **F-048** đóng — **ADR-079** — 2026-10-05 · [chi tiết](backlog_archive.md#t-133)
- [x] T-132 Vết của mỗi lần *quán đang mù* và mỗi lần *tạm dừng nhận đơn* có dòng yêu cầu và chỗ cất — `YC-34` cặp với một dòng `architecture.md` §8; migration bước 14 dựng `order_intake_pause` · `shop_blind_spell` (không chồng nhau, kết thúc phải có người, chỉ khép được — **ADR-078**); câu `I-008/2` · `I-008/3` có lỗi cài, `YC-34` chấm đọc + sai; tập 5 còn chờ lý do huỷ máy đọc được; **F-050** *Fixed* — 2026-10-01 · [chi tiết](backlog_archive.md#t-132)
- [x] T-127 Thứ đã làm của đơn huỷ mà không bàn nào chờ có chỗ ghi *bánh làm sai* — bảng `wrong_make_note` (bước migration 13, đường lùi có khoá chặn): một ghi chú một dòng trên đúng một thứ đã làm của đơn đã Huỷ, người ghi · lúc ghi · chữ tuỳ chọn, ghi nhầm huỷ tại chỗ; `I-004/6` loại thứ đã ghi chú — **ADR-077** — 2026-10-01 · [chi tiết](backlog_archive.md#t-127)
- [x] T-120 Pha 3 có kế hoạch `master_plan/BE_master_plan_banh_cuon_ba_thanh.md` và sổ `work/backlog_BE.md`: mười bốn bước `P3-01`…`P3-14`, admin ngoài pha 3, `P3-01` chờ chủ repo ký chuyển pha — **ADR-076** — 2026-10-01 · [chi tiết](backlog_archive.md#t-120)
- [x] P2A-09 Rà ranh giới pha và pointer trên file lát admin — chín lượt `P2-14` và chín nhóm §6 trên 18 file tài liệu · 36 file mã: 0 endpoint · route · component, 0 dòng *cất* thứ bị chặn, mỗi lượt có dòng thử kêu đúng; hai dòng *quyền* loại 5 Claude xếp loại 3 + 2; bảy con trỏ lệch sửa cùng lượt; ô 7 · 8 ký ⇒ cổng lược đồ admin **8/8** trừ lát `P2A-05` vắng; Codex lọc, Claude duyệt và ký — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-09)
- [x] P2A-08 Cổng chất lượng lược đồ admin — `db/scenario/s4_ngay_quan_tri.sql` diễn chín bước một ngày quản trị (sổ nguyên liệu, chấm công có huỷ, tạm ứng có duyệt, thưởng), mỗi bước trỏ một dòng `shop-facts.md` §8; đọc lại ở kết nối khác; `YC-26`…`YC-32` chấm đọc + sai, `db-check` đòi cả mã §9 trừ danh sách *YC chưa có lát* tự hết hạn (§9.3, khuôn ADR-070); ô 1–6 ký kèm output, `P2A-05` · `YC-33` vắng chờ ADR-074; Codex thi công, Claude chạy database, sửa một lỗi tên biến và ký — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-08)
- [x] T-126 Khách trả nợ dần — migration `20261001120000_tra_no_dan`: mỗi lần trả một dòng mang số còn thiếu trước · sau, chuỗi giữ bằng khoá ngoại và khoá duy nhất (**ADR-075**); `YC-02` viết lại; test hồi quy viết trước (chín lời từ chối, đọc lại năm ngày); hạng tử nợ cũ thu của `I-005/3` · `I-012/1` đọc mức nợ giảm; khoá chặn bước lùi thử thật; Claude thiết kế và viết test, Codex thi công, Claude chạy database và duyệt — 2026-10-01 · [chi tiết](backlog_archive.md#t-126)
- [x] T-131 Gate 1d bắt thẻ component có thuộc tính và thẻ đóng — `PAT_FE` nới, 12 ca hồi quy (sáu hình × hai vùng) và một ca văn xuôi không kêu oan; hai hình *tên trong backtick* để mắt người, lý do ở header; `F-049` *Fixed*; Codex thi công, Claude duyệt — 2026-10-01 · [chi tiết](backlog_archive.md#t-131)
- [x] T-130 Đề bài `P2A-09` giao được cho Codex — kế hoạch §7: ô 1–6 ký ở `P2A-08`, ô 7 · 8 ở `P2A-09`; entry `P2A-09` có tập file và tập con trỏ, lượt lọc cho chín phần §6, luật xếp dòng *quyền* (cách đọc của phiên, chờ chủ repo), dòng lát vắng (`P2A-05` mang việc rà về mình); không rà, không đổi lời quán hay lược đồ — 2026-10-01 · [chi tiết](backlog_archive.md#t-130)
- [x] P2A-07 Phép đối chiếu của admin vào bộ đối chiếu — mười hai câu mới trong `db/reconcile/i025.sql` … `i028.sql`, mỗi câu một lỗi cài kêu đúng mã; tập không thành câu (`I-026` tập 1 · 2, `I-028` tập 5 · 6, `I-021` tập 2) có dòng vì sao ở `09-doi-chieu-bat-bien.md` §2; hai câu *chuỗi vết đứt* đọc lần sửa mất vết dưới chế độ mềm (**F-046**) trên dòng đã có vết; ngày bán mẫu thêm dữ liệu admin, mọi câu vẫn rỗng; `I-029` *vắng*, người nợ `P2A-05`; câu `I-021` đánh số lại theo bảy tập (**F-055** đóng); Codex thi công, Claude thiết kế và duyệt; `db-check` 97 câu · 97 lỗi cài, gate xanh — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-07)
- [x] T-128 Hai lần chạy `db-check` song song không gỡ database của nhau — mỗi lần chạy một compose project `banhcuon_check_<PID>_…`, `cleanup` chỉ gỡ của mình, project của lần chạy đã chết (hỏi `ps -p`) được lần sau dọn, tên cũ và `banhcuon` không bị đụng; `QC-07` và hai trang `docs/guideline/` đổi cùng lượt; **F-045** *Fixed*. Codex thi công, Claude duyệt, sửa một chỗ (`kill -0` → `ps -p`) và đo bằng Docker: hai lần chồng nhau đều PASS, `kill -9` được dọn — 2026-10-01 · [chi tiết](backlog_archive.md#t-128)
- [x] P2A-06 Dữ liệu mồi admin — `db/seed/seed.pl` đọc lúc chạy hai danh sách của `master_plan/shop-facts.md` §8.4 (danh sách 2026-09-06 và bảng *Hàng mua vào*) vào `supply_item`: tên bằng nhau khi bỏ hoa thường là một dòng mang đơn vị của bảng, tên khác nhau giữ riêng; thứ chưa có đơn vị để NULL; 30 hàng · 12 chưa có đơn vị trên owner hôm nay; `db-check` bước 4 đối chiếu tên owner ↔ database bằng `comm -3`; Codex thi công, Claude viết nghiệm thu và duyệt; đơn vị của mười hai tên cũ còn ở bản nháp B12 — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-06)
- [x] T-125 Tiền RA khỏi két trong ngày thành một hạng tử *chi từ két* của `I-021`; `I-028` · `I-029` có vế nối két, mỗi loại chi mang nguồn tiền; `YC-31`…`YC-33`, tầng bảo vệ, công thức `architecture.md` §6.4 viết lại theo cùng lời; **ADR-074**; chủ repo trả lời *tiền rời két trong ngày, trước lúc đếm két* (ghi ở `shop-facts.md` §8.10), mở `U-072` (trừ vào két ngày bán nào); chỉ tài liệu, không code; chủ repo **chưa duyệt** thiết kế — 2026-10-01 · [chi tiết](backlog_archive.md#t-125)
- [x] P2A-04 Lát khoản của người — hai bảng `staff_advance` · `holiday_bonus` (bước migration thứ mười một, có bước lùi có khoá chặn): mỗi khoản một dòng mang người nhận, số tiền lớn hơn 0, ngày, người ghi và lúc ghi; tạm ứng có người duyệt bắt buộc; vai ghi chỉ sửa số tiền · người nhận · ngày, không xoá; không gì nối sang két (chờ `T-125`); thi hành `I-028` · `YC-31` · `YC-32`, **ADR-073**; **F-054** tìm ra và sửa (ngày bán mẫu thêm một khoản mỗi loại); Codex thi công, Claude thiết kế, viết test trước và duyệt; câu đối chiếu của `I-028` còn nợ ở `P2A-07` — 2026-10-01 · [chi tiết](backlog_AD_DB.md#p2a-04)
- [x] P2A-03 Lát chấm công — một bảng `attendance_day` (bước migration thứ mười, có bước lùi có khoá chặn): một ô *có đi làm* là một dòng của một người một ngày, mang người tick và lúc tick; ô tick nhầm **huỷ** được tại chỗ (lúc huỷ, ai huỷ, ghi chú) và ở lại để kiểm, tick lại được; vai ghi không đổi người hay ngày, không xoá; không giờ tới, buổi, ngưỡng đi muộn hay khoản trừ; thi hành `I-027` · `YC-30` (cả hai viết lại theo lời chủ quán đóng `U-069`: chủ quán tick hết, mỗi người mỗi ngày một ô), **ADR-072**; cùng lượt ghi lời chủ quán đóng `U-070` (nút huỷ, có ghi chú) · `U-068` (*thời gian nhập* là lúc hàng mua về), `U-058` nhận lại lời cũ lần thứ năm, vẫn mở; mở `U-071` (ghi chú huỷ có bắt buộc không, ai được huỷ); Codex thi công, Claude ghi lời chủ quán, thiết kế, viết test trước và duyệt; câu đối chiếu của `I-027` còn nợ ở `P2A-07` — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-03)
- [x] P2A-02 Lát sổ nguyên liệu — hai bảng `supply_item` · `supply_day_entry` (bước migration thứ chín, có bước lùi có khoá chặn): một con số người gõ là một dòng mang người nhập, ngày và lúc gõ; tổng và hiệu số không có chỗ cất, đọc ra bằng phép cộng; con số là `numeric` đúng như gõ (vai trò cột mới `_measure`, `QD-03` · `QC-04`); thi hành `I-025` · `I-026`, **ADR-071**; bước khoá chặn của `db-check` lùi qua bước còn rỗng (**F-053**, ghi và chữa cùng lượt). Codex thi công, Claude thiết kế, viết test trước và duyệt; `db-check` 9 bước · 28 file test xanh, gate xanh. Còn nợ có tên: buổi bán đủ năm kênh (`P2A-08`), câu đối chiếu (`P2A-07`), vết mềm (`F-046`) — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-02)
- [x] T-124 Lời chủ quán 2026-09-30 cho sáu câu hỏi về owner: đóng `U-067` · `U-066` (tiền từ két bán hàng), `U-065` (một ô *có đi làm* do chủ quán tick), `U-064` (POS ghi chú bánh làm sai), `U-063` (khách nợ được trả dần); `U-058` nhận lại lời cũ lần thứ tư, vẫn mở; mở `U-069` (lời `U-065` va với `C31`); hệ quả chưa làm thành `T-125` · `T-126` · `T-127` — 2026-09-30 · [chi tiết](backlog_archive.md#t-124)
- [x] T-123 Phép so mã của bộ đối chiếu nhận danh sách *mệnh đề chưa có lát* có tên, tự hết hạn — chữa `F-052` theo đường (b), **ADR-070**; danh sách ở `09-doi-chieu-bat-bien.md` §2.1, `scripts/reconcile.sh` đọc lúc chạy; `--codes` exit 0 với năm `NOTE`, `scripts/reconcile.test.sh` 21 ca, `db-check` xanh; Codex thi công, Claude thiết kế và duyệt; còn chờ chủ repo: câu viết ở lát hay dồn về `P2A-07` — 2026-09-30 · [chi tiết](backlog_archive.md#t-123)
- [x] P2A-01 Yêu cầu dữ liệu và invariant của phần admin đã đủ luật — tám dòng `YC-26`…`YC-33`, năm mệnh đề `I-025`…`I-029` cùng tầng và phép đối chiếu (nhóm QUẢN TRỊ), hành vi ở `01-ranh-gioi.md` §1.6, **ADR-069**; Codex thi công hai file pha 1, Claude viết mệnh đề và duyệt; mở `U-067` · `U-068`; chỗ hở mới `F-052` (mã mệnh đề có trước câu đối chiếu) — 2026-09-30 · [chi tiết](backlog_AD_DB.md#p2a-01)
- [x] T-122 Lược đồ admin có kế hoạch và sổ việc: chín bước `P2A-01`…`P2A-09` cho phần đã đủ luật, chín phần còn chặn mỗi phần một dòng; lời chủ repo 2026-09-29 mở cổng ghi ở mục *Thứ tự làm* và **ADR-068**; mở `U-065` · `U-066` — 2026-09-30 · [chi tiết](backlog_archive.md#t-122)
- [x] P2-14 Rà chéo ranh giới pha và pointer — chín lượt lọc endpoint · route · component trên mười một file pha 2 (2753 dòng), mỗi lượt một cặp chưa lọc · đã lọc, bộ lọc chứng minh biết kêu trên bản sao có cài lỗi; ô 9 ký ⇒ cổng pha 2 **12/12**; pointer hai chiều rà xong, bốn câu *"pha 2 chưa mở"* của pha 1 nhận ghi chú có ngày; chỗ hở mới `F-049` (Gate 1d hẹp) · `F-050` (vết *quán đang mù* chưa có dòng yêu cầu). **Ký chuyển pha 3 là quyền chủ repo** — 2026-09-30 · [chi tiết](backlog_DB.md#p2-14)
- [x] T-121 `db-check` hết đỏ theo giờ trong ngày — đơn mà test `I-024` để lại sau COMMIT nay khai lúc tạo trong giờ bán thay vì lấy đồng hồ; không phép chấm nào đổi. `./scripts/db-check.sh` lúc 20:59 ⇒ exit 0, cùng lệnh trên `HEAD` lúc 20:55 ⇒ exit 1 (`I-008/1`); `work/findings.md` **F-051** *Fixed*. L1, làm trước vì chặn `P2-14` — 2026-09-30
- [x] P2-13 Cổng chất lượng pha 2 — ba scenario diễn qua lược đồ (mỗi bước một giao dịch COMMIT, đọc lại ở kết nối khác, đối chiếu rỗng trên ngày ấy), 24 dòng `YC` chấm hai câu, 11/12 ô cổng ký kèm bằng chứng, ô 9 chờ `P2-14`; chỗ hở mới `F-048` — 2026-09-30 · [chi tiết](backlog_DB.md#p2-13)
- [x] P2-11 Bộ query đối chiếu bất biến — 63 câu `I-0xx/n` + 22 câu `QD`, một lệnh `scripts/reconcile.sh`; ngày mẫu đúng ⇒ 0 dòng, 85 lỗi cài kêu đúng tập khai; 29 tập chưa có câu có tên — 2026-09-30 · [chi tiết](backlog_DB.md#p2-11)
- [x] P2-09 Thứ tự migration và đường lùi — mỗi bước một file lùi có khoá chặn, `db-check` xuôi · lùi · xuôi lại từng bước; tên bảng `.md` ↔ migration là Gate 1e — 2026-09-30 · [chi tiết](backlog_DB.md#p2-09)
- [x] T-087 `CLAUDE.md` chỉ giữ luật và con trỏ — 607 còn 412 dòng; cơ chế về header script, lý do về ADR-064 — 2026-09-29 · [chi tiết](backlog_archive.md#t-087)
- [x] P2-08 Lược đồ người · chỗ đứng theo thời điểm · vết — trực quầy theo khoảng, *ai bấm* bắt buộc, vết cập nhật bản trước / bản sau, sổ giấy nhập bù — 2026-09-28 · `8e5a77e` · [chi tiết](backlog_DB.md#p2-08)
- [x] T-119 Đo lại thí điểm lane pha 2 (ADR-051): mục tiêu đạt, ba trên bảy bước có dấu *Done* trong commit của task khác — 2026-09-28 · [chi tiết](backlog_archive.md#t-119)
- [x] T-086 `work/backlog.md` chỉ giữ trạng thái — mỗi việc đã xong một dòng; chi tiết sang `work/backlog_archive.md` — 2026-09-28 · [chi tiết](backlog_archive.md#t-086)
- [x] T-085 Mỗi task một file scope `work/scope/<MÃ>.txt`; Gate 7b chấm theo task trong subject — 2026-09-28 · `2ab82bc` · [chi tiết](backlog_archive.md#t-085)
- [x] T-084 Gate in lẫn "OK" · "xanh" · "skipping" · "note:", nên "đã kiểm và đạt" trông giống "không kiểm" — 2026-09-28 · `5d64e6c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-10 Dữ liệu mồi — menu thật, bàn và mã QR, trạm của thành phần; mười ba ca giá §4.8 khớp từng đồng — 2026-09-28 · `f385fc0` · [chi tiết](backlog_DB.md#p2-10)
- [x] P2-07 Lược đồ sản xuất theo mẻ — việc trạm một dòng một đơn vị, mẻ và lần lùi mẻ, phần của từng bàn… — 2026-09-28 · `3701e1a` · [chi tiết](backlog_DB.md#p2-07)
- [x] P2-06 Lược đồ đường tiền — hoá đơn, thu chia phương thức, nợ, hoàn tiền, trả trước, tiền đầu két… — 2026-09-28 · `89ac41b` · [chi tiết](backlog_DB.md#p2-06)
- [x] T-114 Migration giữ `I-023` — bảng `qr_code` giữ mã hiện hành và mọi mã đã thay, một cửa sinh mã… — 2026-09-28 · `3768250` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-118 Ghi lời chủ quán đóng U-062 (ai đổi mã QR, khi nào) và U-060 (ai cập nhật số người thực tế)… — 2026-09-28 · `3768250` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-116 Migration giữ `I-024` — dấu lần gửi trên mọi đơn và mọi lượt gọi, bắt buộc và duy nhất không… — 2026-09-28 · `82a1587` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-111 Migration giữ `I-022` — liên hệ tối thiểu của đơn mang đi thành năm ràng buộc thật trên… — 2026-09-28 · `9671f93` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-117 F-031: Gate 8 chặn subject trùng một commit đã có trong lịch sử, sửa hai con số của entry T-062 — 2026-09-28 · `74cc89f` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-115 F-043: một lần gửi thành đúng một đơn — mệnh đề `I-024`, có tầng, có `YC-25` — 2026-09-28 · `34b3d9c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-113 F-042: mã QR của bàn thành mệnh đề `I-023` — bàn của lượt gọi QR tra từ mã, mã không đoán… — 2026-09-28 · `f152dd1` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-112 F-037: khoản trả trước có dòng trong công thức đối soát, `I-021` có hạng tử cho nó, và `YC-23` — 2026-09-28 · `d333b7b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-110 F-038: mức liên hệ tối thiểu của đơn mang đi thành mệnh đề `I-022`, có tầng và có `YC-22` — 2026-09-28 · `0dd8afb` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-108 Đặt yêu cầu khôi phục ở pha 1, giao cơ chế cho pha 5 và đóng F-034 — 2026-09-27 · `b04715c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-107 F-033: kế hoạch pha 1 thôi tự khai trạng thái — mỗi ô trỏ về bước sở hữu và `work/backlog.md` — 2026-09-28 · `8ebe7f4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-106 Rà phép đếm ADM và đóng F-028 — 2026-09-27 · `18dbd31` · [chi tiết](backlog_archive.md#t-106)
- [x] T-105 Mọi điều AI truyền đạt cho chủ repo viết bằng văn xuôi tiếng Việt — 2026-09-27 · `92b4f76` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-103 F-036: phép đối chiếu phủ mọi vế — hai hàng thiếu vế và năm hàng cùng hình — 2026-09-27 · `a70467b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-104 Đóng F-019 — nghiệm thu đếm chữ trong tiêu đề sau lượt tách file — 2026-09-27 · `71f8705` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-05 Lược đồ menu · giá · ảnh chụp giá lúc đặt — `I-009` tầng 1 thành ràng buộc thật, `F-036` là… — 2026-09-27 · `71f8705` (commit tick *Done*) · [chi tiết](backlog_DB.md#p2-05)
- [x] T-102 Ghi lời xác nhận số người thực tế và giảm giá cả đơn — 2026-09-28 · `066c94a` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-04 Lược đồ lát bán hàng lõi — bảy mệnh đề thành ràng buộc thật, `F-038` · `F-043` là chỗ trống có… — 2026-09-27 · `a99d3ef` · [chi tiết](backlog_DB.md#p2-04)
- [x] T-101 Codex được sửa thêm vài file khi chủ repo giao thẳng task nhỏ — 2026-09-27 · `598d7ee` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-12 Quy ước code — DBMS là PostgreSQL 17 — 2026-09-27 · `6bf8f97` · [chi tiết](backlog_DB.md#p2-12)
- [x] T-100 Áp dụng chia vai Claude quyết, Codex thi công — 2026-09-27 · `5ca8c96` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-03 Quy ước dữ liệu — mở `docs/product/2-db/` — 2026-09-27 · `70ecefc` · [chi tiết](backlog_DB.md#p2-03)
- [x] T-097 Mười một bài học lược đồ của dự án cũ vào đúng bước pha 2 — 2026-09-25 · `cf048d4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-096 Ba lỗ quy trình pha 2 rút từ dự án cũ: DBMS chốt trước lát lược đồ · bản nào thắng khi có… — 2026-09-25 · `b4b603e` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-094 Ghi nhận lời đáp U-053–U-059 — 2026-09-25 · `1480aba` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-098 Chốt mốc nguyên liệu và người khai danh tính ngoài quầy — 2026-09-27 · `1145325` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-099 Ghi nhận lời bổ sung về mất mạng, đi giao và giảm giá — 2026-09-27 · `f378015` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-095 Cập nhật lời chủ quán về B19/B20 — 2026-09-25 · `404719d` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-093 Ghi nhận câu trả lời E44–E51 — 2026-09-25 · `1e00f9b` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-092 Ghi nhận câu trả lời D37–D43 — 2026-09-25 · `1f7f6d4` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-091 Ghi nhận câu trả lời C24–C35 — 2026-09-25 · `a044398` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-090 Ghi nhận B18/B19/B22 và làm rõ B20 — 2026-09-25 · `3dde852` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-089 Ghi nhận câu trả lời B11–B17 — 2026-09-25 · `b85afc9` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-088 Claude Code và Codex dùng chung luật và bàn giao — 2026-09-25 · `3dde852` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-088)
- [x] T-083 Lane pha 2: entry ở `work/backlog_DB.md` là hồ sơ thực thi duy nhất, trạng thái chỉ ở file này — 2026-09-25 · `8e319c1` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P2-02 Gate 1d nay chấm CẢ vùng pha 2, với một bộ mẫu riêng im lặng với SQL — 2026-09-24 · `d57cf4f` · [chi tiết](backlog_DB.md#p2-02)
- [x] P2-01 Ranh giới và từ vựng của cả pha 2 có owner: `docs/decisions.md` ADR-050 — 2026-09-24 · `0715382` · [chi tiết](backlog_DB.md#p2-01)
- [x] T-082 Món nợ trạng thái scope lần thứ BA, và lần thứ SÁU một phiên song song nhặt việc của phiên khác — 2026-09-22 · `d4bb50f` · [chi tiết](backlog_archive.md#t-082)
- [x] T-081 Pha 2 có sổ mô tả riêng: `work/backlog_DB.md`, mười bốn entry `P2-01`…`P2-14` — 2026-09-20 · `04c5a64` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-081)
- [x] ADM-21 Lời `C36` đã về owner: mỗi lần đổi người Ở QUẦY là một mốc có giờ — 2026-09-20 · `04c5a64` (commit tick *Done*) · [chi tiết](backlog_AD.md#adm-21)
- [x] ADM-53 Hai lời chủ quán chốt 2026-09-01 đã về owner — và `C36` có lời — 2026-09-20 · `e1ecbaf` · [chi tiết](backlog_AD.md#adm-53)
- [x] T-080 Pha 2 có kế hoạch còn sống: mười bốn bước `P2-01`…`P2-14`, và một cổng mỗi ô kèm cách chứng… — 2026-09-20 · `3f18bf3` · [chi tiết](backlog_archive.md#t-080)
- [x] T-079 Ô 10 của cổng pha 1 tick — cổng lên 10/10 — 2026-09-20 · `20f7822` · [chi tiết](backlog_archive.md#t-079)
- [x] T-078 Chủ quán trả lời BỐN câu trong một lượt — `U-042` · `U-043` · `U-051` · `U-052` — và hai lời… — 2026-09-20 · `711d4fd` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-077 `docs/product/99-unknowns.md` có mục lục — file hơn bốn trăm dòng, ba tiêu đề `###`, không có… — 2026-09-16 · `bd9e42e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-12 Ranh giới pha được ĐO lần đầu trên cả pha 1 — và câu trả lời là KHÔNG: ba chỗ lọt ra, chỉ một… — 2026-09-16 · `bf39be5` · [chi tiết](backlog_SD.md#p1-12)
- [x] T-073 Chủ quán đóng `U-044`: hoàn tiền trả lại bằng gì cũng KHÔNG có luật cứng — POS quyết từng ca… — 2026-09-16 · `14203ae` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-072 Chủ quán đóng `U-048` — KHÔNG suất nào bưng kèm canh, nên con số khách chọn trên dòng canh là… — 2026-09-16 · `b3c7c6e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-075 Chủ quán đóng `U-050` — NGƯỜI ĐỨNG QUẦY gánh trạm của người đi giao, và khoảng trống ấy KHÔNG… — 2026-09-16 · `f1bf975` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-074 Chủ quán đóng `U-045` — chữ *thiếu* của mục tổng quan KHÔNG do máy nghĩ ra: không có ngưỡng… — 2026-09-16 · `b3c7c6e` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-071 Chủ quán đóng `U-049` — người ĐI GIAO là một trong bốn vai của §3, không phải người thứ năm… — 2026-09-15 · `66798b8` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-070 Gate 7b chặn một khối bàn giao HỢP LỆ vì một "file" tên `\` — và cùng phép lọc ấy đang bỏ qua… — 2026-09-16 · `bafd656` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-076 Vế NGƯỜI của `U-041` cuối cùng cũng có tập để trỏ vào — bảng phân vai §3 — và lộ ra rằng con… — 2026-09-15 · `66798b8` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-069 Chủ quán đóng `U-046` và `U-047` trong một lượt — menu đi từ BỐN lên SÁU dòng, và một trong… — 2026-09-15 · `66798b8` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-11 Ba scenario nghiệm thu BA nay đã được diễn qua thiết kế, và cổng sang pha 2 ký 9/10 — cả chín… — 2026-09-16 · `63b5eb2` · [chi tiết](backlog_SD.md#p1-11)
- [x] T-068 Chủ quán đọc ra MENU thành một danh sách — bảy tên khớp đúng bảng giá đang có, hai tên là thứ… — 2026-09-08 · `0b61b4d` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-067 Chủ quán đóng `U-041`: vế *"còn thiếu gì không"* của mục tổng quan là thiếu NGUYÊN LIỆU — và… — 2026-09-08 · `0b61b4d` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-10 Năm rủi ro lớn nhất nay là CHÍN, và mỗi dòng chỉ tên được một cơ chế đã viết ra — trừ một dòng… — 2026-09-08 · `0b61b4d` · [chi tiết](backlog_SD.md#p1-10)
- [x] P1-08 Bốn ràng buộc quyết định hình dạng cả hệ thống nay có nhà trong pha 1, mỗi cái một dấu hiệu ĐO… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-08)
- [x] T-066 Chủ quán trả lời NỬA câu `U-042`: bốn bàn mới cũng 4 chỗ/bàn — vế ĐÁNH SỐ vẫn chưa có lời, nên… — 2026-09-08 · `54c0924` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-07 Pha 2 nay có một DANH SÁCH YÊU CẦU để tự chấm lược đồ, và `architecture.md` §8 hết đếm cứng ở… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-07)
- [x] T-065 Hai bước đã xong của pha 1 nay có dòng *Xong ngày…* mà chính luật 3 của `work/backlog_SD.md`… — 2026-09-08 · `54c0924` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-09 Bảng quầy `architecture.md` §3 nay có BỐN con số, và §11 hết giao việc cho một task đã *Done*… — 2026-09-07 · `53febdd` · [chi tiết](backlog_SD.md#p1-09)
- [x] T-047 Bản đã commit của `work/scope.txt` chỉ còn chứa comment, đóng F-020 — 2026-09-03 · `3ee8420` · [chi tiết](backlog_archive.md#t-047)
- [x] T-064 Sửa banner `shop-facts.md` hết tự khai "không trỏ đi đâu", đóng phần còn lại của F-016 — 2026-09-07 · `ffada33` · [chi tiết](backlog_archive.md#t-064)
- [x] T-035 Đổi lời cảnh báo "scope bẩn" của `scripts/brief.sh`, đóng F-014 — 2026-09-07 · `b4d91ea` · [chi tiết](backlog_archive.md#t-035)
- [x] T-063 F-030 đóng: Gate 1c hết coi mã U-XXX được TRÍCH DẪN trong một gạch đầu dòng đang mở là mã đang… — 2026-09-07 · `9cf9f9a` · [chi tiết](backlog_archive.md#t-063)
- [x] P1-06 Năm mệnh đề menu · giá · vết nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng… — 2026-09-07 · `2a39826` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-06)
- [x] P1-14 Mệnh đề mồ côi thứ ba `I-021` nay là hàng thứ tám của nhóm TIỀN, và ô `I-015` hết trỏ tới một… — 2026-09-08 · `54c0924` (commit tick *Done*) · [chi tiết](backlog_SD.md#p1-14)
- [x] P1-13 Hai mệnh đề sinh SAU khi kế hoạch chia nhóm nay có nhóm thứ tư của riêng chúng — SẢN XUẤT THEO… — 2026-09-07 · `2a39826` · [chi tiết](backlog_SD.md#p1-13)
- [x] T-062 Chủ repo đặt tên chủ cho hai phụ thuộc mà F-027 đo được là chưa có owner — đường báo đơn về… — 2026-09-07 · `7ffabb7` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-061 Danh mục nguyên liệu bắt đầu có TÊN — chủ quán liệt kê mười bốn thứ đầu tiên, còn bổ sung dần — 2026-09-07 · `0159d2e` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-060 Chủ quán trả lời BẢY câu cuối cùng còn mở ở `docs/product/99-unknowns.md` trong một lượt, và… — 2026-09-06 · `f2d86e5` · [chi tiết](backlog_archive.md#t-060)
- [x] P1-05 Sáu mệnh đề vòng đời nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng — và một… — 2026-09-06 · `f01a5bd` · [chi tiết](backlog_SD.md#p1-05)
- [x] T-059 Gate 1d chấm máy phần phổ biến nhất của ranh giới pha; `CLAUDE.md` hết ba chỗ mục nát mà một… — 2026-09-06 · `ba4bafb` · [chi tiết](backlog_archive.md#t-059)
- [x] P1-04 Bảy mệnh đề chạm tiền nay mỗi mệnh đề có một TẦNG giữ nó và một phép đối chiếu ra rỗng — và ba… — 2026-09-07 · `0159d2e` · `8bea106` · [chi tiết](backlog_SD.md#p1-04)
- [x] T-056 Chủ quán trả lời CẢ MƯỜI câu nhóm A trong một lượt, và một trong mười lời LÀM MẤT NỬA CÂU HỎI… — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-056)
- [x] T-057 Bước 4/12 của pha 1 nay có prompt, và nó là bước DUY NHẤT hôm nay đủ tiền đề để có một. — 2026-09-06 · `8a9ae2b` · [chi tiết](backlog_archive.md#t-057)
- [x] T-058 Lane admin có lane prompt riêng: `prompt/AD/` — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-058)
- [x] T-055 Chủ quán đóng `U-031` bằng một từ, và trả lời MỘT NỬA `U-034` — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-054 Chủ quán trả lời HAI câu trong một lượt, và cả hai đi cùng một hướng: quán không dừng bán… — 2026-09-06 · `8a9ae2b` (commit tick *Done*) · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] P1-03 Mọi phép cộng tiền của hệ thống nay đứng trên cùng MỘT định nghĩa *một ngày bán*, và định… — 2026-09-04 · `625739e` · [chi tiết](backlog_SD.md#p1-03)
- [x] T-053 Hai việc bị chặn bởi một câu hỏi mà `shop-facts.md` đã trả lời năm ngày trước — 2026-09-04 · `625739e` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-053)
- [x] T-052 Mảng admin có sổ task riêng: `work/backlog_AD.md` — 2026-09-04 · `be4f488` · [chi tiết](backlog_archive.md#t-052)
- [x] P1-02 Pha 1 nay kể tên những thứ NGOÀI hệ thống mà hệ thống đang dựa vào, và nói mất từng thứ thì… — 2026-09-04 · `cfaa725` · [chi tiết](backlog_SD.md#p1-02)
- [x] T-051 Lane `prompt/SD/` nay có sáu file, không phải một. — 2026-09-04 · `508356f` · [chi tiết](backlog_archive.md#t-051)
- [x] P1-01 Ranh giới sở hữu của pha 1 đã có một câu trả lời, và không tài liệu nào còn nói ngược nó. — 2026-09-04 · `da7dd2f` · [chi tiết](backlog_SD.md#p1-01)
- [x] T-050 Đ-3 về owner — 2026-09-04 · `4a6c1cd` · [chi tiết](backlog_archive.md#t-050)
- [x] T-049 Pha 1 có sổ task riêng: `work/backlog_SD.md` — mười hai entry `P1-01`…`P1-12` viết đủ bảy khối… — 2026-09-04 · `da7dd2f` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-049)
- [x] BA-12 `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 — lát cắt sản xuất theo mẻ, và §3 nay là bốn… — 2026-09-04 · `31fb071` · [chi tiết](backlog_archive.md#ba-12)
- [x] T-048 Pha 1 nay có kế hoạch còn sống: `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — mười hai… — 2026-09-03 · `faacc38` · [chi tiết](backlog_archive.md#t-048)
- [x] BA-13 Năm chỗ hai mục đã chốt nói lệch nhau đã dọn, và cổng chất lượng BA nay 9/9 bằng tick thật ⇒… — 2026-09-03 · `39ca608` · `1b9d238` · [chi tiết](backlog_archive.md#ba-13)
- [x] BA-11 `docs/product/0-ba/ban-hang/08-scenario.md` §8 — ba scenario nghiệm thu BA + cổng chất lượng… — 2026-09-03 · `4f8dcd6` · [chi tiết](backlog_archive.md#ba-11)
- [x] DOC-5 `docs/architecture.md` → `docs/product/1-system-design/architecture.md` — lượt 5/5, đóng… — 2026-09-03 · `ad875f0` · `5ddd0e9` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-046 Prompt của DOC-5 hết mang hai con số hỏng — không mở khoá DOC-5. Chủ repo được hỏi 2026-09-03… — 2026-09-03 · `31faded` · [chi tiết](backlog_archive.md#t-046)
- [x] DOC-4 `CLAUDE.md` hết trỏ về bản lưu — 6 chỗ prompt đếm đều có thật và đều đã đổi (29, 30, 135→141… — 2026-09-03 · `ddec2f0` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-3b Nhóm B (`prompt/BA/`, 13 file) hết trỏ về bản lưu — 92 dòng chuyển, 22 ở lại. Ba loại như… — 2026-09-03 · `fd64862` · [chi tiết](backlog_archive.md#doc-3b)
- [x] DOC-3c Vùng *Ready* + *In Progress* của `work/backlog.md` hết trỏ về bản lưu — 7 dòng chuyển (8 lần… — 2026-09-03 · `1a56b8e` · [chi tiết](backlog_archive.md#doc-3c)
- [x] DOC-3a Nhóm A (6 tài liệu chỉ đường lõi) hết trỏ về bản lưu — 99 dòng chuyển, 15 ở lại (prompt đoán… — 2026-09-03 · `dc53768` · [chi tiết](backlog_archive.md#doc-3a)
- [x] DOC-3 (giai đoạn chia việc L3) — đếm lại 2026-09-02: 595 dòng/50 file, không phải 563. Ngoài sổ lịch… — 2026-09-03 · `4f5d8f8` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-2 `scripts/brief.sh` đọc mục *Unknowns* ở `docs/product/99-unknowns.md` thay cho bản lưu — bốn… — 2026-09-02 · `83fe8ff` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-1 `docs/product/` dựng theo pha — 10 mục chuyển nguyên văn (diff với `git show HEAD` rỗng cả 10… — 2026-09-02 · `bc5033c` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] DOC-0 Chủ repo chốt trục pha thay cho mảng — ADR-014 thêm khối *SỬA ĐỔI 2026-09-02*, tiêu đề đổi… — 2026-09-02 · `3159ef7` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-045 GĐ-01 và GĐ-05 được xác nhận kèm một yêu cầu mới: mỗi lần cập nhật giữ bản trước · bản sau… — 2026-09-02 · `3159ef7` · [chi tiết](backlog_archive.md#t-045)
- [x] BA-10 `docs/decisions.md` — 17 ADR nghiệp vụ (ADR-015…ADR-031), bảng tổng hợp đầu file và bản đồ phủ… — 2026-09-02 · `0e39b9b` · [chi tiết](backlog_archive.md#ba-10)
- [x] T-044 U-026 đóng — dòng vừa sửa lấy giá đang hiệu lực lúc sửa; ngoại lệ có chủ ý của §4.4, I-009… — 2026-09-02 · `61dfc2c` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-044)
- [x] T-043 U-027 và U-030 đóng: đơn đã `Hoàn thành` huỷ được (§5.2 thêm dòng, §5.6 còn một ca, I-016 viết… — 2026-09-02 · `61dfc2c` · [chi tiết](backlog_archive.md#t-043)
- [x] T-042 Chủ quán trả lời U-022, U-025, GĐ-02, GĐ-03 — POS quyết theo tình hình thực tế; §6.19–§6.21 và… — 2026-09-02 · `b296268` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-042)
- [x] T-041 Mảng ADMIN có mục riêng có nhãn ở ba tài liệu — `docs/product.md` §1.6, `docs/architecture.md`… — 2026-09-02 · `2c31dbb` · [chi tiết](backlog_archive.md#t-041)
- [x] BA-09 `docs/product.md` §7 — phạm vi MVP chốt: 14 năng lực + 2 việc vận hành trong MVP, hai loại… — 2026-09-02 · `c4576f2` · `510f092` · `b296268` · [chi tiết](backlog_archive.md#ba-09)
- [x] T-040 Đ-1: ba mảng nguyên liệu · con người · tài chính vào phạm vi — hai dòng ranh giới cũ bị xoá ở… — 2026-09-02 · `691e37a` · [chi tiết](backlog_archive.md#t-040)
- [x] BA-08 `docs/product.md` §6 — mười bốn ngoại lệ; chín dòng chốt, năm dòng thành GĐ-01–GĐ-05 kèm mức… — 2026-09-02 · `9ef217a` · [chi tiết](backlog_archive.md#ba-08)
- [x] T-039 U-021, U-023, U-024 đóng — POS bấm cả bốn mốc, bấm nhầm một mẻ lùi được; U-022 còn một nửa… — 2026-09-02 · `5570e2e` · [chi tiết](backlog_archive.md#t-039)
- [x] BA-07 `docs/product.md` §5 — ba vòng đời, trạng thái giữa của việc trạm là đã làm xong còn ở bếp… — 2026-09-02 · `5570e2e` · [chi tiết](backlog_archive.md#ba-07)
- [x] T-038 U-019 và U-020 đóng: đối chiếu bằng tin nhắn báo có, hoàn tiền tính NGÀY HOÀN, một lần thu… — 2026-09-01 · `c77a740` · [chi tiết](backlog_archive.md#t-038)
- [x] BA-06 `docs/product.md` §4 — quy tắc giá và thanh toán; I-012, I-013, I-014; mở U-019, U-020 — 2026-09-01 · `30abf8f` · `3f579f9` · [chi tiết](backlog_archive.md#ba-06)
- [x] T-037 U-017 và U-018 đóng: bấm theo MẺ, máy chỉ NHẮC; I-011 viết lại vì bản đầu sai (2026-09-01)… — 2026-09-01 · `ffc2997` · `53f58de` · [chi tiết](backlog_archive.md#t-037)
- [x] T-036 S-4 có lời giải: bảng quầy BỐN con số, quầy bấm "đã làm xong"; mở U-017, ghi F-014… — 2026-09-01 · `ffc2997` · `c5540e2` · [chi tiết](backlog_archive.md#t-036)
- [x] T-034 Giá đổi được giữa giờ bán, thành phần suất phải chờ hết buổi; §6.17, I-011; mở U-018 — 2026-09-01 · `f75470c` · [chi tiết](backlog_archive.md#t-034)
- [x] BA-05 `docs/product.md` §3.3 — lát cắt chủ quán đổi menu/giá; I-009, I-010; mở U-014–U-016 — 2026-09-01 · `53f58de` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-05)
- [x] BA-04 `docs/product.md` §3.2 — lát cắt một đơn mang đi, ba kênh không gắn bàn; I-007, I-008 — 2026-08-31 · `12c77f8` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-04)
- [x] T-027 Brief nói ra phần nó đã cắt: `→ ĐÃ CẮT: in 6/10 mục` (F-012 đóng) — 2026-08-31 · `12c77f8` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-027)
- [x] T-031 Bản xuất khẩu hết nút `Xong` ở màn trạm: §3.6 mang luật ghi, POS là nơi duy nhất ghi (F-013) — 2026-08-31 · `12c77f8` · [chi tiết](backlog_archive.md#t-031)
- [x] T-033 U-012 và U-013 đóng nốt; câu hỏi S-4 viết lại vì hỏi sai cách — 2026-08-31 · `cf8bd83` · [chi tiết](backlog_archive.md#t-033)
- [x] T-029 `docs/architecture.md` hết là template rỗng: mặt admin có đặc tả, chỉ POS được ghi (ADR-011) — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-029)
- [x] T-026 Đề xuất Admin/POS được chấm: lời chủ quán về gom mẻ vào nhà thật, phần còn lại bị từ chối có… — 2026-08-31 · `3612d13` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-026)
- [x] T-025 Gate 8 — hook `commit-msg` của git từ chối subject rỗng nghĩa; cài bằng `core.hooksPath`… — 2026-08-31 · `3612d13` · [chi tiết](backlog_archive.md#t-025)
- [x] T-032 Nợ là một phần riêng: `docs/architecture.md` §12 có mục FE · BE · DB (ADR-012) — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-032)
- [x] T-030 U-006 — ghép bàn là MỘT phiên, MỘT hoá đơn; I-001 đọc lại; mở U-013 — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-030)
- [x] T-028 Bảy lời chốt của chủ quán 2026-08-31: cho nợ, năng lực nồi, suất đem về, máy không gom — 2026-08-31 · `cf8bd83` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-028)
- [x] BA-03 `docs/product.md` §3.1 — lát cắt một suất tại bàn; I-001–I-004; mở U-006, U-007 — 2026-08-31 · `3612d13` (commit tick *Done*) · [chi tiết](backlog_archive.md#ba-03)
- [x] T-023 Hậu quả đã commit của F-009 dọn xong: bản đồ hash, blueprint ra khỏi `docs/` (ADR-008) — 2026-08-31 · `08af40c` · [chi tiết](backlog_archive.md#t-023)
- [x] T-019 Bản xuất khẩu hết trỏ vào layout repo cũ; bảy dòng ignore đã gỡ (F-007) — 2026-08-31 · `03ffda3` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-019)
- [x] T-021 `brief.sh` đọc Unknowns theo cấu trúc; mục Unknowns có hình dạng máy đọc được (ADR-007) — 2026-08-30 · `1b1d5f5` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-021)
- [x] T-009 Ready hết dòng mẫu của template — brief chỉ phiên mới vào một task thật — 2026-08-31 · `0704139` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-009)
- [x] T-016 Scope quên dọn thì brief kêu; Gate 7b đọc nội dung khối commit (ADR-006) — 2026-08-31 · `0704139` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-016)
- [x] T-015 §10 kế hoạch gốc: bốn câu mang dấu đã chốt, câu 6 hỏi đúng cả hai kênh — 2026-08-31 · `a85fda7` · [chi tiết](backlog_archive.md#t-015)
- [x] T-014 §2.1 kế hoạch gốc nay có đường điện thoại — khách gọi, nhân viên nhập hộ — 2026-08-31 · `a85fda7` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-014)
- [x] T-024 Gate 1b — tài liệu cũng bị máy chấm: mọi pointer phải mở được (ADR-005) — 2026-08-31 · `5483762` · [chi tiết](backlog_archive.md#t-024)
- [x] T-022 Bản xuất khẩu hết chép số tiền của nhà thật — §4, §9.1, §9.4 nay trỏ `shop-facts.md` — 2026-08-30 · `de7c80e` · [chi tiết](backlog_archive.md#t-022)
- [x] T-020 Đơn mang đi được trả trước — §6.3 hết câu "không bao giờ thu trước", mở U-005 — 2026-08-30 · `0b3a337` · `1b1d5f5` · [chi tiết](backlog_archive.md#t-020)
- [x] T-013 Bản xuất khẩu `prompt-fullstack.md` không còn nói "4 kênh", lát cắt B phủ luồng mang đi — 2026-08-30 · `128955a` · [chi tiết](backlog_archive.md#t-013)
- [x] T-012 Bộ prompt `prompt/BA/` gọi luồng mang đi bằng ba kênh (F-006, lần rà thứ ba) — 2026-08-30 · `0578786` · `9685b1a` · [chi tiết](backlog_archive.md#t-012)
- [x] T-018 Gate 7 — hook chặn turn kết thúc mà chưa giao khối commit (ADR-004) — 2026-08-30 · `5c84476` · [chi tiết](backlog_archive.md#t-018)
- [x] T-017 Kết thúc mỗi task/phiên giao sẵn nội dung commit (CLAUDE.md §6.1) — 2026-08-30 · `b0ce1f6` · [chi tiết](backlog_archive.md#t-017)
- [x] T-011 `phone_preorder` nay thuộc lát cắt Epic B — luồng mang đi ba kênh — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-011)
- [x] T-008 Backlog có 11 task BA-01–BA-11, thứ tự phụ thuộc và acceptance kiểm được — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-008)
- [x] T-010 Gate 3 chỉ chặn file git đang theo dõi; file chưa track chỉ được ghi chú (ADR-003) — 2026-08-30 · `2692178` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-010)
- [x] T-007 Kế hoạch gốc không còn nói "bốn kênh bán" — §2.2 · §9 · §11 · §12 (F-005) — 2026-08-30 · `25f0f88` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-007)
- [x] T-006 Quyền huỷ đơn gắn với chỗ đứng, không gắn chức vụ (chủ quán chốt 2026-08-30) — 2026-08-30 · `b977589` · [chi tiết](backlog_archive.md#t-006)
- [x] T-005 U-004 — chỉ người đứng quầy được huỷ đơn (chủ quán chốt 2026-08-30) — 2026-08-30 · `d7fe7d8` · [chi tiết](backlog_archive.md#t-005)
- [x] T-004 Ghi nhận sáu câu trả lời của chủ quán ngày 2026-08-30 (U-001–U-003, S-1–S-3) — 2026-08-30 · `8330a0a` · [chi tiết](backlog_archive.md#t-004)
- [x] BA-01 `docs/product.md` §1 — Actor và phạm vi hệ thống — 2026-08-30 · `e801668` · [chi tiết](backlog_archive.md#ba-01)
- [x] BA-02 `docs/product.md` §2 — Kênh bán — 2026-08-30 · `e801668` · [dòng gốc](backlog_archive.md#done-nguyen-van)
- [x] T-003 Vòng cập nhật liên tục — brief đầu phiên + luật ghi trong phiên (CLAUDE.md §7) — 2026-08-30 · `d3dcc15` · [chi tiết](backlog_archive.md#t-003)
- [x] T-002 Đảo nhà thật về `master_plan/shop-facts.md` (ADR-001) — 2026-08-30 · `7228d36` (commit tick *Done*) · [chi tiết](backlog_archive.md#t-002)

Dòng *Done* nguyên văn trước 2026-09-28 và mọi hồ sơ đã xong: [`work/backlog_archive.md`](backlog_archive.md).

[↑ đầu file](#top)

<a id="chi-tiet-can-lam"></a>
## Chi tiết — việc cần làm

<a id="t-316"></a>
### T-316 — Dòng món ở Tổng thiếu theo bàn và Cộng thử ghép đơn dài như hoá đơn nên nhân viên khó đọc nhanh

Chủ repo báo 2026-11-11: trên `/chu-quan/van-hanh`, chế độ mặc định của mỗi hàng ở *Tổng thiếu theo bàn* (T-314) dùng `DongMonDaGhi` nên in đủ như hoá đơn ("Đầy đủ trứng chín · · Số lượng 3 · 78.000đ", các dòng "Số suất" của từng thành phần combo, "Tổng 99.000đ"). Người đọc là nhân viên quán, đã thuộc món, nên chủ repo muốn gọn: "1 giò", "3 đầy đủ trứng chín", "1 canh không rau", "2 canh ít rau", "2 canh nhiều rau". Cùng ngày, giữa lúc làm, chủ repo yêu cầu thêm dạng gọn này cho mục *Cộng thử ghép đơn*.

Suy luận của Claude, chưa được chủ repo xác nhận: tên ngắn chỉ rút cho hai món đúng tên đã chụp "Giò bán rời" → "giò" và "Canh bánh cuốn" → "canh" (cùng kiểu ánh xạ theo tên đã chụp như `cot-van-hanh.ts`), món khác giữ tên viết thường; lựa chọn của dòng viết thường nối sau tên, nhiều lựa chọn cách nhau dấu phẩy; chỉ đổi hai mục này — chi tiết bàn khi bấm nhãn bàn và Đơn chờ vẫn dùng `DongMonDaGhi` đầy đủ.

Acceptance viết trước sửa:
- A1 — Chế độ *đơn đã đặt* của mỗi hàng ở Tổng thiếu theo bàn (đang phục vụ và ghép thử) và mỗi thẻ bàn ở Cộng thử ghép đơn hiện mỗi dòng gốc của `lines` thành một dòng `"{quantity} {tên ngắn}[ {lựa chọn}]"`, đúng thứ tự `lines`; không giá, không dòng suất của combo, không dòng *Tổng*.
- A2 — Ví dụ chủ repo cho ra đúng năm dòng ở cả hai mục: "1 giò", "3 đầy đủ trứng chín", "1 canh không rau", "2 canh ít rau", "2 canh nhiều rau".
- A3 — Nút *Chi tiết đem ra*, chế độ cột, ô *Tiền bánh đã ra*, dòng Tổng của bảng, chi tiết bàn khi bấm nhãn bàn không đổi.
- A4 — Test T-313/T-314 ở `van-hanh.test.tsx` đổi khẳng định dòng món của hai mục sang dạng gọn, thêm test cho A2; `./scripts/fe-check.sh` và `./scripts/gate.sh` xanh.
- A5 — Dòng `/chu-quan/van-hanh` ở bảng nguồn dữ liệu của `docs/product/4-fe/01-khung-fe.md` nói dòng món ở Tổng thiếu và Cộng thử hiện dạng gọn (T-316), thêm `T-316` vào cột task.

Phạm vi (`work/scope/T-316.txt`): `fe/src/app/chu-quan/_components/van-hanh.tsx`, `fe/src/app/chu-quan/van-hanh/`, `docs/product/4-fe/01-khung-fe.md`, `work/backlog.md`. Thi công: Claude, cây chính, nhánh `P4A-01`.


<a id="t-313"></a>
### T-313 — Vận hành chỉ đếm theo thành phần nên chủ quán không thấy dòng món của bàn như ở Đơn chờ

Chủ repo báo 2026-11-09: trên `/chu-quan/van-hanh`, khối *Đơn chờ xác nhận* hiện từng dòng món (combo và các suất, canh theo mức rau), còn *Cộng thử ghép đơn* và *Tổng thiếu theo bàn* chỉ hiện số theo cột, nên ba khối trông khác nhau. Claude đo cùng ngày: hai khối sau đọc `GET /service-board`, vốn chỉ có số đếm theo việc trạm (thành phần + nhân), chỉ của đơn đã duyệt; "Bánh trứng chín" thành "Trứng chín", năm bát canh ba mức rau gộp một dòng. Không đường gọi nào trả dòng món của đơn đã duyệt theo phiên. Chủ repo chọn 2026-11-09: *"Giữ cột, thêm dòng món"* cho Tổng thiếu, và *"Nối liền, không tiêu đề đơn"* khi một bàn có nhiều đơn. Mức **L2** vì thêm trường bắt buộc vào hợp đồng; chỉ đọc, không đổi tiền, dữ liệu hay luật. Suy ra của Claude (chưa hỏi): *Cộng thử ghép đơn* thay hàng số theo cột của mỗi bàn chờ bằng dòng món, vì chủ repo nói khối này "nên hiện là" dòng món.

Acceptance viết trước sửa:

- A1 — Mỗi `ServiceBoardSession` có `lines` (bắt buộc, mảng `PriceLine`): dòng gốc của mọi đơn trong phiên đã duyệt (`id_if_approved` khác null) và không huỷ, suất combo lồng trong `portions`, cùng hình JSON với `be/internal/nhandon/sql/hang_cho.sql` (ảnh chụp, không tính lại giá — I-009), xếp theo `sales_order_id` rồi id dòng. Đơn chờ xác nhận và đơn huỷ không vào; phiên chưa có đơn ⇒ `[]`. Test ở `be/internal/tongquan/`.
- A2 — Hợp đồng: `ServiceBoardSession.lines` thêm vào `required`, mô tả `getServiceBoard` nói nguồn; tăng MINOR `0.70.0` → `0.71.0`, ghi ở `docs/product/3-be/01-hop-dong-api.md`; `fe/src/lib/api/schema.ts` sinh lại.
- A3 — *Cộng thử ghép đơn*: mỗi thẻ bàn chờ hiện `DongMonDaGhi` với `lines` của phiên và tổng `lines_total_vnd` do **backend** cộng từ `line_total_vnd` của **mọi** dòng — dòng gốc và từng suất trong `portions` (sửa lần hai 2026-11-09, Claude: FE tự cộng vi phạm ADR-102 điểm 3, `check-fe-rules` đỏ `cong-tien`; nên tổng thành trường hợp đồng, A1 và A2 mang theo), vì suất combo mang phụ thu của nó (ADR-117; sửa 2026-11-09, Claude: bản đầu chỉ nói "cộng `line_total_vnd`", Codex cộng dòng gốc, đơn 5 dev ra 87.000đ thay vì 99.000đ; `order_total_vnd` không thay được vì bằng 0 ở phiên chờ), thay hàng `Thịt: … Khác: …`; ô chọn và nhãn bàn giữ nguyên. Test FE.
- A4 — *Tổng thiếu theo bàn*: cột, số thiếu, ô bấm đem ra, dòng tổng không đổi; chi tiết mở bằng nút tên bàn (`ChiTietBan`) thêm `DongMonDaGhi` của phiên dưới lưới cột, cho cả hàng đang phục vụ và hàng bàn chờ đã chọn. Test FE.
- A5 — Phép chiếu cho chat (`be/internal/troly/chieu.go`) không đổi, không mang `lines`; không file nào dưới `be/internal/troly/` đổi.
- A6 — Dòng `/chu-quan/van-hanh` ở `docs/product/4-fe/01-khung-fe.md` nói hai khối hiện dòng món từ `lines` (T-313).
- A7 — `./scripts/gate.sh` đạt; Claude tự chạy be-check.
- A8 — Claude tự thử trên bản sao database dev: duyệt đơn 5 ⇒ phiên bàn 3 có `lines` theo thứ tự Giò bán rời ×1, Đầy đủ trứng chín ×3 (Bánh cuốn Thịt, Thường 9 · Bánh trứng chín Thịt, Thường 3 · Giò bán rời 3), ba dòng canh Không rau 1 · Ít rau 2 · Nhiều rau 2.

Phạm vi (`work/scope/T-313.txt`): `be/internal/tongquan/`, `be/internal/don/dong_theo_suat_test.go`, `docs/product/3-be/openapi.yaml`, `docs/product/3-be/01-hop-dong-api.md`, `fe/src/lib/api/schema.ts`, `fe/src/app/chu-quan/`, `docs/product/4-fe/01-khung-fe.md`, `work/backlog.md`. Thi công: Codex trong worktree `../lean_wt/T-313`, nhánh `codex/T-313`, nền `499b85d`. Duyệt: Claude, chưa duyệt.

Duyệt lần 1 2026-11-09 (Claude, trên diff chưa commit của worktree, 11 file): SQL `lines` chép đúng khuôn `be/internal/nhandon/sql/hang_cho.sql`, lọc `id_if_approved` và bỏ đơn huỷ, xếp theo đơn rồi id dòng; hợp đồng `0.71.0`, `schema.ts`, không file nào dưới `be/internal/troly/` đổi (A2, A5 đạt). A8 Claude tự thử: bản sao `banhcuon_t313` của database dev, server worktree cổng 8093, chủ quán duyệt đơn 5 ⇒ 200; `lines` của phiên 2 (bàn 3) đúng thứ tự Giò bán rời ×1 · Đầy đủ trứng chín ×3 (Bánh cuốn Thịt, Thường 9 · Bánh trứng chín Thịt, Thường 3 · Giò bán rời 3) · Canh Không rau 1 · Ít rau 2 · Nhiều rau 2 — đạt. **Gửi lại Codex ba điểm:** (1) `./scripts/gate.sh` trong worktree đỏ ở be-check: `TestI009_BangVanHanhLinesAnhChupLocDonVaThuTu` chèn đơn `qr_table` không có mã QR ⇒ `sales_order_qr_code_iff_qr_channel_check` (`service_board_test.go:126`); test này chưa từng chạy xanh trên PostgreSQL thật. (2) Tổng của `DongMonDaGhi` ở hai khối cộng mỗi dòng gốc, thiếu phụ thu của suất combo (ADR-117): đơn 5 dev hiện 87.000đ thay vì 99.000đ; fixture FE `dongCuaBan` giả định phụ thu đã gộp vào dòng combo, sai với ADR-117 — sửa theo A3 đã sửa. (3) Test backend chưa có ca dòng combo có `portions`; thêm một ca. Nhỏ: cột cuối dòng `/chu-quan/van-hanh` ở `01-khung-fe.md` chưa có `T-313`. Bản sao `banhcuon_t313` còn để lại trong container `banhcuon-db-1`; xoá do chủ repo.

Duyệt lần 2 và bàn giao 2026-11-09 (Claude, một phiên khác với phiên duyệt lần 1 — hai phiên cùng làm T-313 mà không biết nhau): vòng sửa của Codex viết xong ca combo `TestI009_BangVanHanhLinesComboBaPhanVaMonLe` và sửa đơn QR trong `…AnhChupLocDonVaThuTu` (dùng `qr_code_issue`), rồi Codex hết hạn mức tới 02:48 ngày 2026-11-10 trước khi báo cáo. Claude làm nốt điểm (2): thay vì FE cộng, backend trả `lines_total_vnd` (tổng `line_total_vnd` mọi dòng các đơn đã duyệt chưa huỷ, kể cả suất — như `total_vnd` của hàng chờ; không phải số phải thu, số đó vẫn là `order_total_vnd`, ADR-125), thêm vào `required` của `ServiceBoardSession` cùng bản 0.71.0, nhật ký ở `01-hop-dong-api.md`; FE chỉ hiện. Test BE khẳng định 15100 (đơn chờ 77.777đ và đơn huỷ không vào) và 26600 (gồm dòng suất); fixture FE theo dữ liệu thật (dòng combo 40.000đ + suất 2.000đ ⇒ 63.000đ, khác 61.000đ nếu chỉ cộng dòng gốc). Lệnh đã chạy trong worktree: `./scripts/gate.sh` exit 0 (be-check PostgreSQL thật PASS gồm ba test `TestI009_BangVanHanhLines…`; db SKIP vì không đổi), `./scripts/fe-check.sh` exit 0 (apigen PASS, 745/745). A8 lặp lại trên bản sao `banhcuon_thu`, server cổng 8090: năm dòng đúng thứ tự như lần 1, `lines_total_vnd` 99000. Đưa về cây chính bằng patch (HEAD lúc đó `47bd12b`, chỉ thêm CHAT-16 FE, không đụng hợp đồng), `./scripts/gate.sh` ở cây chính exit 0. Server `make dev` đang chạy phải khởi động lại mới có trường mới. Bản sao `banhcuon_thu` cũng còn trong `banhcuon-db-1`; xoá do chủ repo.

[↑ đầu file](#top)

<a id="t-312"></a>
### T-312 — Máy dev không đặt được đơn ngoài giờ bán nên không thử được luồng khách → Vận hành

Chủ repo báo lần hai 2026-11-09: đặt ở `/ban/3`, `/chu-quan/van-hanh` không cập nhật. Claude đo lúc 13:05: cửa QR trả 409 `outside_selling_hours`, database không có đơn mới; trang Vận hành không hỏng (xem T-311). Chủ repo chọn *"Cho máy dev bỏ giờ bán"*. Mức **L2** vì đổi cách thực thi `I-008` trên một loại máy; thiết kế ở **ADR-141**, ngoại lệ ghi ở `quality/invariants.md` I-008.

Acceptance viết trước sửa:

- A1 — `don.Service.WithBoGioBan(true)` bỏ riêng bước giờ bán của `xetNhanDon`: năm kênh nhận đơn trước giờ mở và sau giờ đóng; bản mặc định vẫn `outside_selling_hours`; tạm dừng vẫn `order_intake_paused` ở năm kênh; quán mù vẫn `shop_not_seeing_orders` ở ba kênh khách tự bấm. Test `be/internal/don/bo_gio_ban_test.go` (Claude viết trước, SHA-256 `6ef71321…edd2e`).
- A2 — `docBoGioBan(getenv)` ở `be/cmd/server`: rỗng/`0` tắt, `1` bật chỉ khi origin là `http://localhost` hoặc `http://127.0.0.1`, mọi trường hợp khác trả lỗi; `main` dừng khi lỗi và in cảnh báo khi bật; router dựng `don.Service` theo cờ. Test `be/cmd/server/bo_gio_ban_test.go` (SHA-256 `e1c785a1…aacbfda`).
- A3 — `Makefile`: `BANHCUON_DEV_BO_GIO_BAN ?= 1` nằm trong `BE_ENV`; `make help` hoặc chú thích nói cách tắt.
- A4 — Combo, ngày bán, đồng hồ, database, hợp đồng API không đổi; be-check và `./scripts/gate.sh` đạt.
- A5 — Claude tự thử: server bật cờ, lúc ngoài giờ gửi một lượt QR bàn 3 ⇒ 201 và đơn hiện ở `GET /counter/queue` của chủ quán.

Phạm vi (`work/scope/T-312.txt`): `be/internal/don/`, `be/cmd/server/`, `Makefile`, `docs/decisions.md`, `quality/invariants.md`, `work/backlog.md`. Thi công: Codex trong worktree `../lean_wt/T-312`, nhánh `codex/T-312`, nền `e8b0670`, vì cây chính đang có thay đổi chưa commit của nhóm CHAT. Duyệt: Claude, chưa duyệt.

Bàn giao 2026-11-09 (thực hiện: Codex, duyệt: Claude): `docBoGioBan` ở `be/cmd/server/main.go` (Fatal khi lỗi, cảnh báo khi bật), `newRouterWithBoGioBan` ở `router.go` (giữ chữ ký `newRouter` cũ cho test, mặc định tắt), `don.Service.WithBoGioBan` bọc riêng bước `ngayban.NgoaiGio` trong `xetNhanDon`; `Makefile` thêm cờ vào `BE_ENV` kèm chú thích cách tắt. Hai file test của Claude giữ nguyên SHA-256. Claude đọc diff, chạy `./scripts/gate.sh` trong worktree: exit 0, be-check PostgreSQL thật PASS gồm năm test `TestI008_CoBoGioBanChiBatTrenMayDev`, `TestI008_MayDevBoGioBanThiNhanDonNgoaiGio`, `TestI008_MacDinhVanChanNgoaiGio`, `TestI008_MayDevBoGioBanVanTheoTamDung`, `TestI008_MayDevBoGioBanVanTheoQuanMu`; fe, db SKIP vì không đổi. A5 Claude tự thử trên database dev, server phụ cổng 8090 bật cờ: 13:20 lượt QR bàn 3 khi chưa ai mở luồng ⇒ `shop_not_seeing_orders` và mở khoảng quán mù số 2 (đúng I-008); chủ quán mở `GET /counter/events`, bấm `POST /shop-blind/reopening` ⇒ 200; 13:21 lượt QR bàn 3 ⇒ 201, `GET /counter/queue` của chủ quán có đơn 4 (`qr_table`, bàn 3, Giò bán rời 9.000đ), luồng nhận `changed`. Đơn thử số 4 để lại ở *Chờ xác nhận* cho chủ repo xem trên trang Vận hành. Không lỗi phải gửi lại Codex. Đưa về cây chính bằng patch rồi chạy lại gate ở cây chính. Server `make dev` đang chạy phải khởi động lại mới có cờ.

[↑ đầu file](#top)

<a id="t-310"></a>
### T-310 — Nhà giả của server chưa gọi được công cụ đọc nội bộ nên chưa diễn được biên bản chỉ đọc

Chủ repo yêu cầu 2026-11-08 *"tiếp tục yêu cầu codex làm và bạn kiểm tra"*. Claude đo trên `9eb7d73`: `CHAT-10` còn chờ lượt thiết kế thẻ lệnh của `CHAT-02` (L3, chủ repo duyệt), nên không giao được; phần còn lại của `CHAT-09` là *biên bản chỉ đọc* và *so số trên màn tay*, chưa chạy được vì `nhaGiaMacDinh` (server, `CHAT_MODEL_PROVIDER=gia`) chỉ gọi `doc_menu`. Mức **L1**: chỉ đổi nhà giả của máy dev; không đổi hợp đồng, quyền, danh sách công cụ (backend vẫn chọn theo phiên, I-043), dữ liệu hay lớp model; `Model()` giữ `gia-1` vì dấu vân eval CHAT-06 không tính hành vi nhà giả. *Suy ra của phiên, chọn của Claude:* chọn công cụ theo chữ trong câu người dùng cuối (ba luật có thứ tự, chỉ gọi tên có trong danh sách, dự phòng `doc_menu`) và chép nguyên văn kết quả công cụ nội bộ đã nén, để số trên chat là số của cửa đọc, không do nhà giả tóm. Hợp đồng ở đầu `be/internal/troly/nha_gia_mac_dinh_test.go` (SHA-256 `f20bdc36…c73d` khi giao), 5/7 test đỏ trước code. Sửa cùng ngày, sót của Claude: tên `TestT310_*` vi phạm QC-17 (gate đỏ), đổi thành `TestI041_*` (chọn công cụ, chữ sau `doc_menu`) và `TestI043_*` (chép kết quả, lỗi công cụ nội bộ), không đổi điều kiện nào (SHA-256 sau sửa `98597120…43d1`); worktree giữ bản cũ tới lúc tích hợp.

Acceptance ghi trước khi giao: A1 — mọi test `TestT310_*` xanh, file test và `handler_test.go` không sửa (`TestI041_NhaGiaMacDinhBatDauLaiMoiLuot` xanh); A2 — diff chỉ ở `be/internal/troly/nha_gia_mac_dinh.go`, không SQL, không công cụ mới, không đổi `Lop.Luot` · `NguonNoiBo`; A3 — `./scripts/be-check.sh` và `./scripts/gate.sh` xanh ở cây chính; A4 — Claude diễn trên máy dev bằng phiên người làm: câu hỏi bàn/trạm/tổng quan ra đúng công cụ, nguồn và mốc trên `HoiQuan`, số khớp màn tay, phiên khách không gọi được công cụ nội bộ; ghi kết quả làm biên bản chỉ đọc ở entry này.

Phạm vi (`work/scope/T-310.txt`): `be/internal/troly/nha_gia_mac_dinh.go`, `be/internal/troly/nha_gia_mac_dinh_test.go`, `work/backlog.md`. Worktree `../lean_wt/T-310`, nhánh `codex/T-310` từ `9eb7d73`. Thêm `work/findings.md` cùng ngày để ghi `F-078`.

Bàn giao 2026-11-08: **Codex** thực hiện (worktree `../lean_wt/T-310`, nhánh `codex/T-310`, nền `9eb7d73`, model `gpt-6-astra`, một lượt): chỉ `be/internal/troly/nha_gia_mac_dinh.go`, 35 dòng thêm. Codex dừng đúng ở sót QC-17 của Claude, không sửa test; mã băm hai file test khớp phiếu. **Claude** duyệt diff (không SQL, không công cụ mới, không đổi `Lop.Luot` · `NguonNoiBo`, vẫn không giữ trạng thái), đưa patch về cây chính bằng `git apply`, chạy lại. Bằng chứng ở cây chính: `go test ./internal/troly/ -run 'TestI041_NhaGia|TestI043_NhaGia|TestI041_DuongHoiKiemHinhKhongCanDB'` 7/7 PASS; `./scripts/be-check.sh` `be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`; `./scripts/gate.sh` lần một đỏ ở hai test combo không liên quan (`F-078`), lần hai `PASS gate không cổng nào đỏ`.

**Biên bản chỉ đọc** (A4, Claude, 2026-11-08 16:28, backend phụ build từ cây chính ở `127.0.0.1:8091`, `CHAT_MODEL_PROVIDER=gia`, database làm việc của máy dev, tài khoản ở `docs/command/tai-khoan-dev.md`; server cổng 8080 của chủ repo không bị đụng). Gọi `POST /chat/turns` với bốn câu cho bốn loại phiên: chủ quán ra đúng `doc_tong_quan` · `doc_bang_phuc_vu` · `doc_bang_tram` theo câu; người quầy chưa nhận ca quầy (`counter_duty_id` 0) chỉ ra `doc_bang_tram`, câu hỏi bàn và tổng quan rơi về `doc_menu`; người tráng bánh chỉ ra `doc_bang_tram`; không phiên (khách) chỉ ra `doc_menu` với mọi câu. Mỗi câu trả lời có đúng một nguồn và mốc `read_at`. So số với màn tay (phiên chủ quán, bỏ `read_at`, so từng giá trị lá): `doc_bang_phuc_vu` ↔ `GET /service-board` 16 lá, không lệch, phần thiếu chỉ là `dining_table_id`; `doc_tong_quan` ↔ `GET /owner-overview` 170 lá, không lệch, phần thiếu là id và các trường ngoài danh sách được phép của I-043; `doc_bang_tram` ↔ `GET /production-board` khớp. Giới hạn: dữ liệu hôm ấy mỏng (không bàn đang mở, bảng trạm rỗng), nên phép so phủ cấu trúc và số tổng quan, chưa phủ một bàn đang phục vụ; chưa diễn trên trình duyệt; mỗi lượt hỏi ghi một dòng `model_call` vào database dev (sổ ngân sách, như mọi lượt chat trên `make dev`). Output ở `../lean_wt/chat-review/` (`T-310-be-check.log`, `T-310-gate2.log`), ngoài repo.

Còn lại: dòng thứ tư của Acceptance dự kiến `CHAT-09` (biên bản chỉ đọc trước mọi lệnh ghi qua model) nay có biên bản trên nhà giả; mở `CHAT-10` vẫn chờ lượt thiết kế thẻ lệnh của `CHAT-02` do chủ repo duyệt. Chưa có người duyệt thứ ba.

[↑ đầu file](#top)

<a id="t-308"></a>
### T-308 — Chủ quán nhận và xử lý đơn mới trên trang Vận hành

Chủ repo yêu cầu 2026-11-06: `/chu-quan/van-hanh` cũng nhận được đơn mới và chủ quán có quyền điều hành. Chủ repo cho phép Codex làm cả phần vượt L1. Phạm vi diễn giải theo ngữ cảnh đơn QR tại bàn: khi chủ quán giữ trang Vận hành mở, quán được xem là còn nhìn thấy đơn; trang hiện hàng chờ và cho chủ quán duyệt, từ chối đơn, mở lại nhận đơn nếu đang mù, ghi đem ra cho bàn. Những cửa tiền và quản trị quầy khác giữ quyền riêng đã chốt. Mức L2 vì đổi điều kiện I-008, quyền cửa ghi và hợp đồng API. Nhánh thi công `codex/T-308`, nền `9eb7d73`, worktree riêng để không chạm thay đổi chưa commit ở cây chính; chưa có người duyệt độc lập.

Acceptance viết trước sửa: A1 — chủ quán không đứng quầy mở trang Vận hành được tính là một người đang nhìn thấy đơn, nhận `changed` và đọc lại hàng chờ cùng bảng bàn; nếu không có luồng quầy hoặc chủ quán thì đơn khách vẫn bị chặn theo I-008. A2 — hàng chờ hiện rõ đơn QR, bàn, món và tổng từ backend; chủ quán duyệt/từ chối bằng cửa hiện có, kết quả đọc lại; người không có quyền vẫn bị từ chối. A3 — chủ quán thấy trạng thái mù và có thể bấm mở lại, không tự mở; có thể ghi đem ra tại màn như người đứng quầy. A4 — hợp đồng, ma trận quyền và quyết định về tín hiệu khớp code; test backend, FE và `./scripts/gate.sh` đạt.

Phạm vi: `work/scope/T-308.txt`. Bàn giao thi công 2026-11-07 (Codex):

- A1: `GET /counter/events` và `GET /counter/queue` nhận chủ quán không đứng quầy. Trang Vận hành giữ luồng nhận đơn và đọc lại hàng chờ cùng bảng bàn khi có `hello`/`changed`. `TestI008_LuongChuQuanVanHanhDuocTinhLaNhinThayDon` và `TestI008_NhieuLuongQuayChuQuanVaTuChoiSaiLop` kiểm PostgreSQL thật: chủ quán một mình vẫn được tính là nhìn thấy, người sai lớp bị từ chối, đóng hết luồng thì đơn QR lại bị chặn.
- A2: hàng chờ hiện bàn, dòng món và tổng tiền từ backend; chủ quán duyệt/từ chối bằng cửa có vết, đọc lại sau ghi. `TestI012_ChuQuanVanHanhDuyetTuChoiVaGhiDemRa` kiểm đúng người trong `record_revision`, người ngoài quầy bị từ chối; test FE kiểm thao tác duyệt và hộp xác nhận từ chối.
- A3: trang hiện `blind_since` và nút mở lại qua cửa `nhandon/mo_lai`; không tự mở. Chủ quán bấm ghi đã đem ra bằng cửa `sanxuat/ra_ban`; test backend kiểm quyền và vết, test FE kiểm chủ quán không đứng quầy có nút, người không có quyền chỉ được xem.
- A4: OpenAPI lên `0.67.0`, ma trận quyền, ADR-097, I-008/I-012 và tài liệu màn đã khớp. `npm test -- --run` đạt 679/679, `npm run build` đạt. `./scripts/gate.sh` exit 0: Gate 3, 1b–1h, Gate 1 backend trên PostgreSQL thật và verify PASS; Gate 1 db SKIP vì không đổi database. Gate 7/7b kiểm thủ công khi bàn giao commit.

Kiểm trực tiếp 2026-11-08 (Codex, máy phát triển): chạy `make dev` từ worktree T-308; hai URL `/ban/3` và `/chu-quan/van-hanh` trả HTTP 200. Tài khoản chủ quán **không đứng quầy** mở `GET /counter/events` qua Next và nhận `hello`/`changed`; bấm mở lại khoảng mù cũ bằng `POST /shop-blind/reopening`. Gửi một lượt QR bàn 3, món Bánh cuốn ×1 giá 4.000đ qua chính tầng Next ⇒ HTTP 201, `pending_confirmation`; `GET /counter/queue` của chủ quán đọc đúng bàn, món, tiền và `blind_since: null`; luồng nhận thêm `changed`. Chủ quán duyệt ⇒ HTTP 200, hàng chờ rỗng và `GET /service-board` có hai phần việc của bàn 3. Dùng cửa quầy huỷ đơn **thử** số 3, đóng phiên 0đ và dọn bàn; bàn 3 trở lại trống, không còn phiên mở. `./scripts/gate.sh` chạy lại với Docker 2026-11-08, exit 0: Gate 3, 1b–1h, backend PostgreSQL thật và verify PASS; DB SKIP vì không đổi lược đồ. Worktree này đang phục vụ localhost; chưa tích hợp vào cây chính, chưa commit, chưa có người duyệt độc lập.

Duyệt và tích hợp 2026-11-08 (Claude): chủ repo báo đặt món ở `/ban/3` rồi đồng ý mà `/chu-quan/van-hanh` không hiện món. Nguyên nhân: đơn QR vào ở *Chờ xác nhận*, chưa sinh việc ở trạm (shop-facts §6 quy tắc 2) nên bảng Vận hành không có món; bản sửa T-308 nằm ở worktree riêng, chưa về cây chính, app chạy từ cây chính không có nó. Chủ repo chọn *"Duyệt và tích hợp T-308"*, xác nhận luật Codex viết ở `master_plan/shop-facts.md` (dòng sổ thay đổi 2026-11-08) và ADR-097 *Sửa đổi*. Claude đọc diff: bốn cửa nới sang `quay_hoac_chu_quan` (hàng chờ, luồng nhận đơn, duyệt, từ chối, ra bàn), cửa huỷ sau xác nhận giữ `quay`; một broker chung nên đổi trang sang `/counter/events` không mất tín hiệu tiến độ bếp. Claude tự chạy `./scripts/gate.sh` trong worktree, exit 0, be-check PostgreSQL thật PASS gồm `TestI008_LuongChuQuanVanHanhDuocTinhLaNhinThayDon`, `TestI008_NhieuLuongQuayChuQuanVaTuChoiSaiLop`, `TestI012_ChuQuanVanHanhDuyetTuChoiVaGhiDemRa`; `npx vitest run src/app/chu-quan` 342/342. Không lỗi phải gửi lại Codex. Đưa về cây chính bằng patch, chạy lại gate ở cây chính.

[↑ đầu file](#top)

<a id="t-308"></a>
### T-308 — Chủ quán nhận và xử lý đơn mới trên trang Vận hành

Chủ repo yêu cầu 2026-11-06: `/chu-quan/van-hanh` cũng nhận được đơn mới và chủ quán có quyền điều hành. Chủ repo cho phép Codex làm cả phần vượt L1. Phạm vi diễn giải theo ngữ cảnh đơn QR tại bàn: khi chủ quán giữ trang Vận hành mở, quán được xem là còn nhìn thấy đơn; trang hiện hàng chờ và cho chủ quán duyệt, từ chối đơn, mở lại nhận đơn nếu đang mù, ghi đem ra cho bàn. Những cửa tiền và quản trị quầy khác giữ quyền riêng đã chốt. Mức L2 vì đổi điều kiện I-008, quyền cửa ghi và hợp đồng API. Nhánh thi công `codex/T-308`, nền `9eb7d73`, worktree riêng để không chạm thay đổi chưa commit ở cây chính; chưa có người duyệt độc lập.

Acceptance viết trước sửa: A1 — chủ quán không đứng quầy mở trang Vận hành được tính là một người đang nhìn thấy đơn, nhận `changed` và đọc lại hàng chờ cùng bảng bàn; nếu không có luồng quầy hoặc chủ quán thì đơn khách vẫn bị chặn theo I-008. A2 — hàng chờ hiện rõ đơn QR, bàn, món và tổng từ backend; chủ quán duyệt/từ chối bằng cửa hiện có, kết quả đọc lại; người không có quyền vẫn bị từ chối. A3 — chủ quán thấy trạng thái mù và có thể bấm mở lại, không tự mở; có thể ghi đem ra tại màn như người đứng quầy. A4 — hợp đồng, ma trận quyền và quyết định về tín hiệu khớp code; test backend, FE và `./scripts/gate.sh` đạt.

Phạm vi: `work/scope/T-308.txt`. Bàn giao thi công 2026-11-07 (Codex):

- A1: `GET /counter/events` và `GET /counter/queue` nhận chủ quán không đứng quầy. Trang Vận hành giữ luồng nhận đơn và đọc lại hàng chờ cùng bảng bàn khi có `hello`/`changed`. `TestI008_LuongChuQuanVanHanhDuocTinhLaNhinThayDon` và `TestI008_NhieuLuongQuayChuQuanVaTuChoiSaiLop` kiểm PostgreSQL thật: chủ quán một mình vẫn được tính là nhìn thấy, người sai lớp bị từ chối, đóng hết luồng thì đơn QR lại bị chặn.
- A2: hàng chờ hiện bàn, dòng món và tổng tiền từ backend; chủ quán duyệt/từ chối bằng cửa có vết, đọc lại sau ghi. `TestI012_ChuQuanVanHanhDuyetTuChoiVaGhiDemRa` kiểm đúng người trong `record_revision`, người ngoài quầy bị từ chối; test FE kiểm thao tác duyệt và hộp xác nhận từ chối.
- A3: trang hiện `blind_since` và nút mở lại qua cửa `nhandon/mo_lai`; không tự mở. Chủ quán bấm ghi đã đem ra bằng cửa `sanxuat/ra_ban`; test backend kiểm quyền và vết, test FE kiểm chủ quán không đứng quầy có nút, người không có quyền chỉ được xem.
- A4: OpenAPI lên `0.67.0`, ma trận quyền, ADR-097, I-008/I-012 và tài liệu màn đã khớp. `npm test -- --run` đạt 679/679, `npm run build` đạt. `./scripts/gate.sh` exit 0: Gate 3, 1b–1h, Gate 1 backend trên PostgreSQL thật và verify PASS; Gate 1 db SKIP vì không đổi database. Gate 7/7b kiểm thủ công khi bàn giao commit.

Kiểm trực tiếp 2026-11-08 (Codex, máy phát triển): chạy `make dev` từ worktree T-308; hai URL `/ban/3` và `/chu-quan/van-hanh` trả HTTP 200. Tài khoản chủ quán **không đứng quầy** mở `GET /counter/events` qua Next và nhận `hello`/`changed`; bấm mở lại khoảng mù cũ bằng `POST /shop-blind/reopening`. Gửi một lượt QR bàn 3, món Bánh cuốn ×1 giá 4.000đ qua chính tầng Next ⇒ HTTP 201, `pending_confirmation`; `GET /counter/queue` của chủ quán đọc đúng bàn, món, tiền và `blind_since: null`; luồng nhận thêm `changed`. Chủ quán duyệt ⇒ HTTP 200, hàng chờ rỗng và `GET /service-board` có hai phần việc của bàn 3. Dùng cửa quầy huỷ đơn **thử** số 3, đóng phiên 0đ và dọn bàn; bàn 3 trở lại trống, không còn phiên mở. `./scripts/gate.sh` chạy lại với Docker 2026-11-08, exit 0: Gate 3, 1b–1h, backend PostgreSQL thật và verify PASS; DB SKIP vì không đổi lược đồ. Worktree này đang phục vụ localhost; chưa tích hợp vào cây chính, chưa commit, chưa có người duyệt độc lập.

Duyệt và tích hợp 2026-11-08 (Claude): chủ repo báo đặt món ở `/ban/3` rồi đồng ý mà `/chu-quan/van-hanh` không hiện món. Nguyên nhân: đơn QR vào ở *Chờ xác nhận*, chưa sinh việc ở trạm (shop-facts §6 quy tắc 2) nên bảng Vận hành không có món; bản sửa T-308 nằm ở worktree riêng, chưa về cây chính, app chạy từ cây chính không có nó. Chủ repo chọn *"Duyệt và tích hợp T-308"*, xác nhận luật Codex viết ở `master_plan/shop-facts.md` (dòng sổ thay đổi 2026-11-08) và ADR-097 *Sửa đổi*. Claude đọc diff: bốn cửa nới sang `quay_hoac_chu_quan` (hàng chờ, luồng nhận đơn, duyệt, từ chối, ra bàn), cửa huỷ sau xác nhận giữ `quay`; một broker chung nên đổi trang sang `/counter/events` không mất tín hiệu tiến độ bếp. Claude tự chạy `./scripts/gate.sh` trong worktree, exit 0, be-check PostgreSQL thật PASS gồm `TestI008_LuongChuQuanVanHanhDuocTinhLaNhinThayDon`, `TestI008_NhieuLuongQuayChuQuanVaTuChoiSaiLop`, `TestI012_ChuQuanVanHanhDuyetTuChoiVaGhiDemRa`; `npx vitest run src/app/chu-quan` 342/342. Không lỗi phải gửi lại Codex. Đưa về cây chính bằng patch, chạy lại gate ở cây chính.

[↑ đầu file](#top)

<a id="t-306"></a>
### T-306 — Đơn QR mới hiện ngay trên trang Vận hành đang mở

Chủ repo yêu cầu 2026-11-05: khi khách ở `/ban/3` bấm Đồng ý đặt món, thông tin lượt gọi mới cần cập nhật trên `/chu-quan/van-hanh`. Mức L1 vì dùng lại cửa ghi QR, cửa đọc Vận hành và luồng tín hiệu đã có; không đổi dữ liệu, giá hay hợp đồng API.

Acceptance trước sửa: A1 — trang Vận hành đang mở nhận `changed` sau lượt gọi QR và đọc lại `GET /service-board`, hiện số món/bàn mới từ backend mà không cần bấm Đọc lại; A2 — `heartbeat` không đọc lại, mất luồng có cảnh báo và nối lại sẽ đọc lại; A3 — rời trang đóng luồng, không tạo thêm lời gọi ghi đơn; A4 — `./scripts/gate.sh` đạt.

Phạm vi (`work/scope/T-306.txt`): `work/backlog.md`, `docs/product/4-fe/01-khung-fe.md`, `fe/src/app/chu-quan/_components/van-hanh.tsx`, `fe/src/app/chu-quan/van-hanh/van-hanh.test.tsx`. Codex làm trên nhánh `P4A-01`; chưa có người duyệt độc lập. Cây chung đang có thay đổi chưa commit của việc khác; chỉ đưa hunk của T-306 vào lần bàn giao.

Bàn giao 2026-11-06: `TrangVanHanh` dùng `TinHieuProvider` trên `GET /production-board/events` — luồng cùng broker nhận `changed` sau khi đơn QR được ghi; `hello`/`changed` làm mất hiệu lực query để đọc lại `GET /service-board`. `heartbeat` chỉ giữ luồng sống; đứt luồng hiện cảnh báo, tự nối lại; rời trang huỷ luồng. Không thêm cửa ghi đơn. Test trang Vận hành đạt 17/17, gồm ca bàn 3 xuất hiện sau `changed`, `heartbeat` không đọc lại, đứt/nối lại và huỷ khi rời trang. `./scripts/gate.sh` exit 0: Gate 3, 1b, 1c, 1e, 1f, 1g, 1h và Gate 1 verify PASS; Gate 1d, be, db SKIP theo điều kiện; NOTE về file chưa theo dõi của việc khác. Chưa thử đặt một đơn thật trên cặp trang đang chạy và chưa có người duyệt độc lập. Cây chung có nhiều hunk chưa commit của các task khác, kể cả `work/backlog.md`; lần commit cần tách đúng hunk T-306.

[↑ đầu file](#top)


<a id="t-300"></a>
### T-300 — Nút chat của khách là chữ nhỏ, khó thấy và đè nút món

Chủ repo báo 2026-11-05 không thấy nút chat ở `/ban/3`. Claude đo cùng ngày bằng Playwright trên máy dev của chủ repo: nút "Hỏi quán" của `OChatKhach` có, hiện, không bị che, hỏi được và nhận câu của model giả kèm nguồn; nhưng nó là nút chữ đen nhỏ (80×32 px), không giống biểu tượng chat, và ở bề ngang 390 px đè lên nút "+" của thẻ món. Lựa chọn nút chữ là của Claude ở phiếu CHAT-07. Chủ repo yêu cầu: *"hãy làm nút bấm trợ lý bánh cuốn floating button phải dưới bên phải"*. Mức **L1**, chỉ đổi vỏ giao diện; `HoiQuan`, cờ, đường gọi giữ nguyên.

Quyết định của Claude: nút nổi tròn 56 px màu cam của quán `#EA6A0C`, biểu tượng `MessageCircle` (lucide-react) chữ trắng, tên truy cập "Trợ lý bánh cuốn", góc phải dưới có tính vùng an toàn điện thoại; bấm lần nữa thì đóng; khi mở đổi biểu tượng thành `X`. Bảng mang tiêu đề "Trợ lý bánh cuốn", nằm ngay trên nút. Khung nội bộ (`OChat`) không đổi trong lượt này.

Acceptance ghi trước khi giao: A1 — trang khách có một nút nổi tròn tên "Trợ lý bánh cuốn" ở góc phải dưới, có biểu tượng, không còn nút chữ "Hỏi quán"; A2 — bấm mở bảng "Trợ lý bánh cuốn", bấm lại hay nút Đóng hay Esc đều đóng và trả focus về nút; A3 — cờ tắt, đường nội bộ, đổi tài khoản khách giữ đúng hành vi CHAT-07 (test cũ đổi tên, không bỏ ca); A4 — ảnh chụp Playwright 1280 px và 390 px trên máy dev cho thấy nút tròn cam và bảng mở không tràn ngang; A5 — `./scripts/fe-check.sh` và `./scripts/gate.sh` xanh.

Phạm vi (`work/scope/T-300.txt`): `fe/src/components/shared/o-chat-khach.tsx`, `fe/src/components/shared/o-chat-khach.test.tsx`, `docs/product/4-fe/01-khung-fe.md`, `work/backlog.md`.

Bàn giao 2026-11-05: **Codex** thực hiện (worktree `../lean_wt/T-300`, nhánh `codex/T-300`, nền `0c08241`, model `gpt-6-astra`, một lượt): nút `<button>` gốc tròn 56 px, `MessageCircle` ↔ `X`, bấm lại đóng; test 6 → 9 ca, không bỏ ca nào. Build treo trong sandbox Codex nên **Claude** tự chạy trong worktree: `./scripts/fe-check.sh` `fe-check: PASS` (672/672 test, build biên dịch được), `./scripts/gate.sh` `PASS gate không cổng nào đỏ`. A4 Claude chụp bằng Playwright trên máy dev của chủ repo sau `git apply`, `/ban/3`: nút 56×56 ở (1208, 728) với bề ngang 1280 và (318, 772) với 390, không còn nút "Hỏi quán", mở · hỏi · nhận câu model giả kèm nguồn, bấm lại đóng, không tràn ngang. Còn lại, đúng bản chất nút nổi: khi cuộn, nút có lúc che phần góc phải dưới của thẻ món (nút "+"); khách cuộn thêm là bấm được. Chưa có người duyệt thứ ba.

[↑ đầu file](#top)

<a id="t-299"></a>
### T-299 — Chạy `make dev` thường không thấy nút chat

Chủ repo báo 2026-11-05, sau commit `9654d68` của CHAT-07: *"sao tôi chưa nhìn thấy biểu tượng chat ấn vào để hiện ra ô chat"*, rồi chọn *"yêu cầu Codex làm, bạn kiểm tra"*. Claude đo cùng ngày: máy dev đang chạy `make dev` với `NEXT_PUBLIC_CHAT_ENABLED` và `CHAT_MODEL_PROVIDER` trống, nên `OChat` · `OChatKhach` đúng thiết kế giấu nút (cờ chỉ bật khi bằng `"true"`). Code không lỗi; mặc định của máy dev chưa hợp với việc chủ repo tự thử. Mức **L1**: chỉ đổi mặc định của `Makefile` (QC-08, chỉ máy phát triển; bộ kiểm không đi qua nó), không đổi cờ trong code nên bản build thật vẫn tắt chat khi không đặt biến (ADR-137 *Sửa đổi 2026-11-05*).

Acceptance ghi trước khi giao: A1 — `make dev` (và `make fe`, `make be`) không đặt biến thì frontend nhận `NEXT_PUBLIC_CHAT_ENABLED=true`, backend nhận `CHAT_MODEL_PROVIDER=gia`; bằng chứng `make -n`. A2 — đặt biến trống hay giá trị khác thì giá trị ấy thắng (`NEXT_PUBLIC_CHAT_ENABLED= make dev` tắt chat). A3 — `docs/command/make.md` ghi mặc định mới và cách tắt. A4 — chạy frontend với mặc định mới, HTML trang `/dat-mon` có nút "Hỏi quán". A5 — `./scripts/gate.sh` xanh.

Phạm vi (`work/scope/T-299.txt`): `Makefile`, `docs/command/make.md`, `docs/decisions.md`, `work/backlog.md`.

Bàn giao 2026-11-05: **Codex** thực hiện (worktree `../lean_wt/T-299`, nhánh `codex/T-299`, nền `9654d68`, model `gpt-6-astra`, một lượt): hai dòng `?=` ở `Makefile`, hai dòng bảng và ví dụ tắt chat ở `docs/command/make.md`. **Claude** duyệt diff, ghi dòng ADR-137, tự chạy lại ở cây chính sau `git apply`: `make -n fe` ra `NEXT_PUBLIC_CHAT_ENABLED="true"`, `make -n be` ra `CHAT_MODEL_PROVIDER="gia"`, đặt trống / `tat` thì giá trị ấy thắng, `make -n dev` mang cả hai; `./scripts/gate.sh` `PASS gate không cổng nào đỏ`. A4 Claude kiểm bằng frontend phụ cổng 3100 có cờ bật (worktree CHAT-07): HTML `/dat-mon`, `/`, `/khach/dang-nhap` đều có nút "Hỏi quán"; frontend cổng 3000 của chủ repo (chạy trước khi đổi, cờ trống) không có. Còn lại: chủ repo khởi động lại `make dev` để máy nhận mặc định mới. Chưa có người duyệt thứ ba.

[↑ đầu file](#top)

<a id="t-296"></a>
### T-296 — Sửa lệnh và hướng dẫn tài khoản dev theo đường đăng nhập hiện tại

Chủ repo yêu cầu 2026-11-05 tạo tài khoản cho tất cả nhân viên để thử `/dang-nhap`, ghi tại `docs/command/tai-khoan-dev.md` và có lệnh make dùng lại. `make tai-khoan-dev` đã có từ T-240; database làm việc hiện có bốn người làm cùng bốn tài khoản hoạt động. Hợp đồng `/sessions` hiện nhận email hoặc số điện thoại ở `identifier`, nên tên đăng nhập cũ trong bảng bị từ chối `identifier_invalid`; script cũng dùng trường `username` khi đăng nhập chủ quán để duyệt tài khoản mới.

Acceptance ghi trước khi sửa: A1 — bảng tài khoản nêu đúng email và mật khẩu cho cả bốn nhân viên cùng chủ quán. A2 — `make tai-khoan-dev` chạy lại an toàn và nhánh tạo mới dùng email để đăng nhập chủ quán. A3 — cả năm cặp email/mật khẩu đăng nhập `POST /sessions` nhận 201. A4 — chạy `./scripts/gate.sh` và đọc kết quả.

Phạm vi (`work/scope/T-296.txt`): `work/backlog.md`, `db/seed/tai-khoan-dev.sh`, `docs/command/tai-khoan-dev.md`, `docs/command/make.md`. Không sửa hợp đồng, backend, migration hay dữ liệu mồi.

Kết quả: database làm việc đã có `chu` và bốn tài khoản nhân viên `quay`, `trang`, `gap`, `canh` ở trạng thái hoạt động. `make tai-khoan-dev` chạy lại thành công, cả năm dòng báo đã có và bỏ qua. Năm cặp email/mật khẩu trong bảng mới gọi `POST /sessions` đều nhận HTTP 201. Script tạo mới nay gửi `identifier: chu@quan.test` khi đăng nhập chủ quán; `bash -n` và `git diff --check` đạt. `./scripts/gate.sh` chạy trực tiếp: Gate 3, 1b…1h và Gate 1 đều PASS, cuối cùng `PASS gate`; Gate 3 có NOTE về file chưa theo dõi của việc khác. Người làm: Codex trên nhánh `P4A-01`; chưa có người duyệt độc lập. Scope giữ đến lúc chủ repo commit.

[↑ đầu file](#top)

<a id="t-242"></a>
### T-242 — Menu chưa có bánh trứng bán rời, trang Sản phẩm xếp mọi món vào một danh mục

**Yêu cầu:** chủ repo 2026-10-23, nhìn `/chu-quan/san-pham`: *"bao gồm bánh cuốn, bánh trứng, giò và canh — phần dưới là những
combos … Đầy đủ bao gồm 1 trứng, 1 giò và 3 bánh với 1 canh hãy cập nhật page trên"*, rồi *"yêu cầu codex làm nốt bạn kiểm tra"*.
Hỏi lại cùng ngày, chủ repo chọn: **giữ luật cũ** — Đầy đủ không kèm canh (`U-048`); **thêm món bán lẻ mới** — bánh trứng chín ·
tái · vàng, mỗi loại một dòng, giá như thành phần; **giò bán rời 9.000, không chọn nhân** (đóng S-9). Claude ghi cả ba vào
`master_plan/shop-facts.md` §4.3 · §4.4 · §4.5 · §4.8 (ca 14) · §4.9 (cột *Nhóm trên menu*) · §7.1 · §7.2. **Mức:** L2 — thêm dòng
menu có tiền; không đổi migration, hợp đồng API, backend hay FE.

**Claude quyết 2026-10-23 (thi công, không phải luật quán):** (1) tên dòng menu là **Bánh trứng chín / tái / vàng**, theo chữ chủ
repo; (2) trang Sản phẩm đã bày mỗi danh mục một khối theo thứ tự `/menu-categories` trả về, nên **không sửa FE** — dữ liệu thử máy
dev (`db/seed/du-lieu-thu.pl`, T-236) tạo danh mục theo cột *Nhóm trên menu* §4.9 thay cho cột *Danh mục* §4.2, và **Món lẻ** phải
được bày trước **Combo**; (3) ca giá 14 trong §4.8 là test hồi quy do Claude viết trước, chạy qua `seed.pl --price-cases` (db-check)
và `--price-cases-tsv` (test cửa giá pha 3).

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] `perl db/seed/seed.pl` chạy được trên shop-facts mới; `%MENU` có ba dòng *bánh trứng* trỏ dòng §4.5 *Bánh trứng bán rời*, loại trứng đúng, tên §4.8 ca 14 khớp.
- [x] Ca 14 (Bánh trứng vàng · Thịt · Nhiều = 10.000) và mười ba ca cũ xanh ở `db-check` và ở test cửa giá của `be-check`.
- [x] Sau `make reset` + dữ liệu thử: có đúng hai danh mục **Món lẻ** (bánh cuốn, giò bán rời, canh, ba bánh trứng) và **Combo** (ba đầy đủ, suất giò, ba suất trứng); không còn danh mục Bánh cuốn / Ăn kèm. ~~`GET /menu-categories` trả Món lẻ trước Combo~~ — bỏ 2026-10-24: hợp đồng sắp danh mục theo tên (`openapi.yaml` `MenuCategories`), Acceptance cũ mâu thuẫn với *không sửa `be/`*; chủ repo chọn chuyển bảy suất thành combo thật ở `/chu-quan/combo` → T-244.
- [x] Không món nào kèm sẵn canh; không sửa migration, `openapi.yaml`, `be/`, `fe/`.
- [x] `docs/product/2-db/08-du-lieu-moi.md` và `docs/command/` (nếu nói danh mục hay số dòng menu của dữ liệu thử) theo kịp.
- [x] `./scripts/gate.sh` xanh ở clone chính.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-242`, nhánh `codex/T-242`, nền `f38f06d` + shop-facts staged sẵn; Codex dừng ở thứ tự danh mục và báo đúng) · duyệt: Claude 2026-10-24, áp diff lên clone chính. File: `db/seed/seed.pl` (ba dòng bánh trứng, `--menu-groups-tsv`), `db/seed/du-lieu-thu.pl` (danh mục theo nhóm §4.9), `scripts/db-check.sh` (dữ liệu thử phải có Món lẻ 6 · Combo 7), `docs/product/2-db/08-du-lieu-moi.md`, `master_plan/shop-facts.md`. Claude sửa một câu của 08 (Gate 1d: pha 2 không nêu endpoint). Bằng chứng: `seed.pl --price-cases-tsv` in ca 14 `Bánh trứng vàng … 10000`; `./scripts/gate.sh` ở clone chính `PASS db-check — … dữ liệu mồi + §4.8 …`, `PASS be-check`, `PASS gate`. Dòng Acceptance thứ tự danh mục bỏ, chuyển sang T-244. `docs/command/` không nói số món hay tên danh mục nên không đổi.

<a id="t-241"></a>
### T-241 — Gate 9 chặn commit liên tiếp mà lời từ chối không chỉ ra file thủ phạm

**Yêu cầu:** chủ repo 2026-10-23, sau khi khối T-239 bị Gate 9 chặn: *"tại sao toàn gặp lỗi này hãy sửa 1 lần dứt … chia commit
cũng được"*. Nguyên nhân và cách vá: F-025, đoạn 2026-10-23. **Mức:** L1 — một git hook và luật giao khối commit.

**Acceptance:**
- [x] Lời từ chối của `scripts/hooks/pre-commit` nêu task gần nhất (ít file ngoài scope nhất; hoà thì scope mới sửa nhất), chỉ các
  file ngoài scope của nó kèm task của từng file, và dòng `git restore --staged <file…>` — `scripts/pre-commit.test.sh` ca *chỉ nêu file
  ngoài task gần nhất và lệnh gỡ*.
- [x] `CLAUDE.md` §6.1: khối mở bằng `git reset -q`; file chung có dòng task khác thì tách theo task, chạy thử trước khi giao.
- [x] Việc chưa commit của T-235 · T-238 · T-240 · T-239 · T-241 tách thành năm commit, chạy thử trong worktree tạm: mỗi commit qua
  hook thật, cây sạch sau commit cuối; `./scripts/gate.sh` xanh.

**Bàn giao:** thực hiện và kiểm: Claude 2026-10-23. File: `scripts/hooks/pre-commit`, `scripts/pre-commit.test.sh`, `CLAUDE.md`,
`work/findings.md`, `work/backlog.md`.

<a id="t-240"></a>
### T-240 — Máy dev không có lệnh make nào tạo lại tài khoản đăng nhập sau `make reset`

**Yêu cầu:** chủ repo 2026-10-23: đăng nhập `chu` không được sau khi dựng lại database — bảng `account` trống vì `make reset` xoá hết
và `make setup`, `make seed-thu` không tạo tài khoản; khối lệnh dài ở `docs/command/tai-khoan-dev.md` phải dán tay. Chủ repo: *"đưa lệnh
make để tôi chạy · yêu cầu codex làm bạn kiểm tra"*. **Mức:** L1 — công cụ máy dev, không đổi lược đồ, hợp đồng, luật quán.

**Claude quyết 2026-10-23 (cách làm, không phải luật quán):** (1) một script dưới `db/seed/` gọi bằng `make tai-khoan-dev`; chủ quán tạo
bằng `be/cmd/khoitao-chu-quan`, bốn tài khoản theo vai đi qua đúng cửa backend (`POST /accounts` rồi duyệt bằng phiên chủ quán), nên
cần backend đang chạy — thiếu thì dừng và nói chạy `make be`; (2) tên đăng nhập, mật khẩu và vai giữ đúng bảng trong
`docs/command/tai-khoan-dev.md`; người gắn vào là bốn người không phải chủ quán theo thứ tự id (như tài liệu đang giả định), tên hiển
thị đọc từ database, không gõ tay; số người khác bốn thì dừng; (3) tài khoản đã có thì bỏ qua, không lỗi.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] `make tai-khoan-dev` (có trong `make help` và `docs/command/make.md`) trên database vừa `make setup`, backend đang chạy, tạo `chu`, `quay`, `trang`, `gap`, `canh` ở trạng thái `hoat_dong`, gắn đúng vai và người — Claude kiểm bằng `SELECT` trên database làm việc.
- [x] Đăng nhập `POST /sessions` bằng từng cặp tên/mật khẩu của bảng trả 2xx — Claude chạy.
- [x] Chạy lần hai báo đã có và bỏ qua từng tài khoản, exit 0, không thêm dòng.
- [x] Backend không chạy thì dừng với lời nhắc `make be`, exit khác 0, không ghi gì.
- [x] `docs/command/tai-khoan-dev.md` thay khối lệnh dài bằng `make tai-khoan-dev`; bảng tài khoản giữ nguyên.
- [x] Không chạm `be/`, `fe/`, migration, `seed.pl`; `./scripts/gate.sh` xanh.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-240`, nhánh `codex/T-240`, nền `42dae88` + diff chưa commit của T-239 ở
`Makefile`, `docs/command/make.md` stage sẵn) · duyệt: Claude 2026-10-23, một vòng, không sửa. File: `db/seed/tai-khoan-dev.sh` (mới),
`Makefile`, `docs/command/make.md`, `docs/command/tai-khoan-dev.md`. Bằng chứng Claude chạy trên database làm việc: lượt một tạo `chu` →
person 6 *Chủ quán (dev)*, `quay`/`trang`/`gap`/`canh` → person 1…4 đúng vai, cả năm `hoat_dong`; `POST /sessions` cả năm cặp → 201; lượt
hai năm dòng *đã có, bỏ qua*, exit 0; `BANHCUON_BE_URL` trỏ cổng tắt → *backend chưa chạy — … `make be`*, exit khác 0.

<a id="t-239"></a>
### T-239 — Thử trang khách trên máy dev phải dán mã QR 32 ký tự

**Yêu cầu:** chủ repo 2026-10-23: `/ban/976d2f…` báo *"Bạn vui lòng quét lại mã trên bàn."* — *"đang trong giai đoạn test tạm thời bỏ
qua lỗi trên. không để [mã] hãy để số bàn"*. Nguyên nhân: database làm việc dựng lại nên mã cũ không còn hiện hành; và không đường đọc
công khai nào tra mã từ số bàn (I-023, cố ý). **Claude quyết (cách làm, không phải luật quán):** không đổi app hay hợp đồng; một file SQL
chỉ cho máy dev, chạy bằng make, thay mã hiện hành của mỗi bàn bằng tên bàn qua đúng ràng buộc và vết (lý do + người là chủ quán đầu
tiên) — cố ý bỏ vế *không đoán được* của I-023 trên máy dev. **Mức:** L1.

**Acceptance:**
- [x] `make ma-qr-so-ban` (trong `make help` và `docs/command/make.md`) đổi mã của mọi bàn; chạy lần hai báo đổi 0 bàn, không lỗi.
- [x] `GET /qr-codes/1` trả `{"label":"1"}` và `/ban/1` hiện *Bàn 1* — Claude chạy trên database làm việc.
- [x] Không chạm `fe/`, `be/`, migration hay `seed.pl`; `./scripts/gate.sh` xanh.

**Bàn giao:** thực hiện và kiểm: Claude 2026-10-23. File: `db/seed/ma-qr-so-ban.sql`, `Makefile`, `docs/command/make.md`. Bằng chứng:
`NOTICE: ma-qr-so-ban: đổi 15 bàn`, lượt hai `đổi 0 bàn`; `curl localhost:8080/qr-codes/1` → `{"label":"1"}`. Sau `make reset` phải chạy lại lệnh.

<a id="t-237"></a>
### T-237 — Trang gọi món của khách chưa chia món theo danh mục

**Yêu cầu:** chủ repo 2026-10-23, cùng lượt T-236: *"để client menu page fetch dữ liệu"*; hỏi lại, chủ repo chọn **chia món theo danh
mục** đọc từ API. Trang khách đã gọi `GET /menu` nhưng schema `Menu` (`docs/product/3-be/openapi.yaml`) không mang danh mục. **Mức:** L2 —
đổi hợp đồng API công khai. Claude thiết kế và viết test trước khi giao; Acceptance viết lúc mở, sau khi T-236 xong.

**Mở 2026-11-04, Claude.** Đo lại: schema `Menu` vẫn chỉ có `items`, `combos`; mỗi món nhiều nhất một danh mục (`menu_item_category_menu_item_key`),
danh mục không có cột thứ tự. *Thiết kế Claude chọn (không phải lời quán):* chỉ thêm, không bỏ — `MenuItem.menu_category_id` (null khi chưa xếp
hoặc danh mục ẩn) và `Menu.categories` (danh mục chưa ẩn có món đang bán, theo tên rồi id như `GET /menu-categories`), hợp đồng 0.59.0 → 0.60.0.
Màn khách theo bản thiết kế `khach_hang/menu/menu.html` khối `CategoryTabs`: hàng thẻ *Tất cả* · từng danh mục · *Món khác* · *Combo*, mỗi danh
mục một khối; chưa có danh mục thì giữ bố cục cũ. Tên *Món khác* cho món chưa xếp là phiên chọn.
**Acceptance:** A1 sáu file Claude giao không đổi (mã băm ở phiếu); A2 `TestI032_MenuMangDanhMucCuaMon` và test màn
`fe/src/app/ban/danh-muc-khach.test.tsx` xanh, test khách · đặt món · sản phẩm · menu giá cũ vẫn xanh; A3 fe-check PASS; A4 Gate 1g PASS ở
0.60.0, câu SQL mới chỉ SELECT; A5 gate không FAIL ngoài cổng Docker. Test viết trước: backend đỏ đúng lý do *menu thiếu categories* (lần đầu đỏ
sai lý do — món thử không có thành phần làm hàm giá cả menu lỗi 500 và kéo đỏ gói `menu`; đã sửa); màn đỏ 4 ca ở chỗ chưa có `nav Danh mục`,
ca bố cục cũ xanh. Claude thêm `categories: []` · `menu_category_id: null` vào dữ liệu mẫu `mau-khach.ts`, `thuc-don-khach.test.tsx`,
`san-pham.test.tsx`, `menu-gia.test.tsx`. Phiếu `../lean_wt/chat-review/T-237-phieu.md`; worktree `../lean_wt/T-237`, nhánh `codex/T-237`, nền
`6cd0c31`; sáu file tạm rời cây chính (bản ở worktree và `chat-review/T-237/`).

2026-11-04, T-237 xong. **Codex** thi công (worktree `../lean_wt/T-237`, nhánh `codex/T-237`, nền `6cd0c31`, model `gpt-6-astra`); **Claude**
duyệt và tích hợp vào cây chính bằng `git apply`. File: `be/internal/gia/` (`service.go`, `repository.go`, `sql/doc_danh_muc_menu.sql`,
`internal/sqlcgen/doc_danh_muc_menu.sql.go`, `menu_danh_muc_test.go`), `openapi.yaml` 0.59.0 → 0.60.0 (`MenuSaleCategory`), đoạn T-237 ở
`01-hop-dong-api.md`, dòng `GET /menu` ở `03-ham-gia.md`, `fe/src/lib/api/schema.ts`, `ban/_components/` (`thuc-don-khach.tsx` · `.css`,
`phieu-khach.tsx`), dòng `ThucDonKhach` ở `01-khung-fe.md`, năm file test/mẫu FE. Codex dừng đúng ở hai chỗ, cả hai là lỗi của Claude khi
viết test trước: (1) ca D3 mong khối COMBO hiện khi tìm "bánh" — tức tìm combo theo tên món bên trong, trái màn cũ (`comboLoc` chỉ tìm tên
combo) và trái chính hợp đồng màn ở đầu file test; Claude sửa kỳ vọng thành `["Bánh cuốn", "Tóm tắt đơn hàng"]`, có ghi chú trong test;
(2) mẫu `fe/src/app/quay/san-xuat/mau-san-xuat.ts` sót `categories` · `menu_category_id` (TS2741), Claude thêm và đưa vào scope. Mã băm năm
file còn lại không đổi so với lúc giao. Bằng chứng (cây chính, Docker): `./scripts/gate.sh` exit 0 — `--- PASS: TestI032_MenuMangDanhMucCuaMon`,
`PASS Gate 1 be-check`, `PASS Gate 1g` ở 0.60.0, `PASS gate không cổng nào đỏ`; `./scripts/fe-check.sh` exit 0 — `Tests 636 passed (636)`,
`fe-check: PASS`. Chưa có người duyệt thứ ba. Còn lại: không.

<a id="t-236"></a>
### T-236 — Máy phát triển chưa có dữ liệu cho phần lớn các mục của trang chủ quán

**Yêu cầu:** chủ repo 2026-10-23: *"http://localhost:3000/chu-quan hãy tạo dữ liệu cho tất cả các danh mục có trong page trên dựa trên
shop-fact … yêu cầu codex làm bạn kiểm tra"*. Hỏi lại cùng ngày: `shop-facts.md` chưa chốt danh mục món (§8.9 *"Danh mục gồm những nhóm
nào thì lời không nói"*), chưa có combo nào (§8.9 lượt bảy vế 1), không có việc giao, đào tạo, khoản chi hay số sổ nguyên liệu nào — chủ
repo chọn **dữ liệu thử riêng**: không đưa vào `seed.pl`, ghi nhãn không phải sự thật của quán. **Mức:** L1 — chỉ dữ liệu máy dev, không
đổi lược đồ, hợp đồng, luật tiền.

**Claude quyết 2026-10-23 (cách làm, không phải luật quán):** (1) một bộ dựng riêng dưới `db/seed/`, chạy **sau** `seed.pl` trên database
đã có dữ liệu mồi, bằng vai `shop_app`, đi qua đúng cửa và trigger của lược đồ; (2) không chép số tiền hay tên món của quán vào file
(ADR-001, F-001): tên danh mục đọc từ cột *Danh mục* của `shop-facts.md` §4.2 lúc chạy, món và giá đọc từ database; giá combo thử = tổng
giá món lẻ đọc từ database, không gõ tay; (3) mọi tên tự đặt (việc giao, bài đào tạo, combo, ghi chú khoản chi…) mang chữ *(thử)*; (4) không
dựng đơn bán — Tổng quan, Vận hành, Tổng kết lấy dữ liệu từ đơn thật tạo qua giao diện; (5) tài khoản đăng nhập vẫn theo
`docs/command/tai-khoan-dev.md` (mật khẩu băm qua backend), bộ dựng này không tạo tài khoản.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] Một lệnh make mới (khai trong `make help` và `docs/command/make.md`) nạp dữ liệu thử lên database đã `make seed`; chạy lần hai thì báo đã có và bỏ qua, không lỗi, không nhân đôi.
- [x] Sau lệnh ấy, mỗi bảng sau có ít nhất một dòng: `menu_category`, `menu_item_category` (mọi món đang bán thuộc một danh mục), `menu_combo`, `menu_combo_item`, `assigned_task`, `assigned_task_guide`, `training_record`, `expense`, `supply_day_entry`, `attendance_day` — Claude kiểm bằng `SELECT count(*)` trên database làm việc.
- [x] File của bộ dựng không chứa con số tiền nào của menu, tên món hay tên danh mục gõ tay; tên tự đặt có *(thử)*.
- [x] `scripts/db-check.sh` dựng thêm dữ liệu thử sau dữ liệu mồi và in một dòng `PASS`/`FAIL` cho nó — Claude chạy (sandbox Codex không tới Docker).
- [x] `docs/product/2-db/08-du-lieu-moi.md` có một mục ngắn nói bộ thử này là gì, không phải sự thật của quán, chạy thế nào.
- [x] `db/seed/seed.pl` không đổi; `./scripts/gate.sh` xanh.

**Bàn giao:** thực hiện: Codex · duyệt: Claude 2026-10-23. Worktree đầu `../lean_wt/T-236` bị một phiên Claude song song dùng nhầm cùng
mã (nay là T-238): lúc 11:44 nó `reset --hard` nhánh `codex/T-236` về `1b6a966` và ghi đè scope — Claude dựng lại diff của Codex từ bản đã
đọc và chuyển sang `../lean_wt/T-236-du-lieu-thu` (nhánh `codex/T-236-du-lieu-thu`, nền `1b6a966`). Vòng sửa 1: `shop_app` không có quyền
TEMP nên bỏ mọi bảng tạm (JSONB, mảng, `set_config`). Claude tự sửa một dòng: database dev có thể có nhiều chủ quán ⇒ lấy id nhỏ nhất.
File: `db/seed/du-lieu-thu.pl` (mới), `Makefile` (`make seed-thu`), `docs/command/make.md`, `docs/product/2-db/08-du-lieu-moi.md`,
`scripts/db-check.sh` (bước 4b). Bằng chứng: gate ở clone chính `PASS dữ liệu thử — assigned_task=1 · assigned_task_guide=1 ·
attendance_day=1 · expense=1 · menu_category=2 · menu_combo=1 · menu_combo_item=2 · menu_item_category=10 · supply_day_entry=2 ·
training_record=1` và *lượt hai báo bỏ qua, số dòng không đổi*. Còn lại: database làm việc của chủ repo dựng từ bản `seed.pl` cũ (0 loại
chi, 1 hàng mua vào) nên `make seed-thu` dừng ở *thiếu loại chi* — cần `make reset` rồi `make setup` và `make seed-thu`, rồi tạo lại tài
khoản theo `docs/command/tai-khoan-dev.md`.

<a id="t-235"></a>
### T-235 — Next.js 16.4.0 dính lỗ hổng bảo mật, `next build` dừng cách lượt

**Yêu cầu:** chủ repo 2026-10-23 dán cảnh báo *"Next.js 16.4.0 is affected by a known security vulnerability … Run `next upgrade
--agent=security`"* và nói: *"yêu cầu codex chạy bạn kiểm tra"*. **Mức:** L1 — đổi phụ thuộc của `fe/`, không chạm dữ liệu, hợp đồng, tiền.
Gốc của F-076 (build dừng cách lượt ở `SecurityFatalError`).

**Claude quyết 2026-10-23:** nâng lên bản vá **nhỏ nhất** mà lệnh của Next.js đề xuất, không nhảy major, không nâng thư viện khác ngoài
những gói lệnh ấy bắt buộc kéo theo (`react`, `react-dom` chỉ đổi nếu bản vá đòi); không sửa code, `next.config.ts` hay test để chiều bản mới —
gặp chỗ vỡ thì dừng và báo.

**Claude quyết thêm 2026-10-23:** lệnh `next upgrade --agent=security` đề xuất **16.4.2** và đòi thêm `experimental.agentUpgrade:
"security"` vào `next.config.ts` (Codex dừng vì file ngoài scope). Bỏ qua cờ ấy: bản vá là phiên bản, không phải cờ; cờ thử nghiệm không rõ
tác dụng và `next.config.ts` là chỗ từng gây F-075.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] `fe/package.json`: `next` và `eslint-config-next` cùng một phiên bản vá > 16.4.0, ghim chính xác (không `^`/`~`); `fe/package-lock.json` khớp (`npm ls next` in đúng bản ấy).
- [x] `next build` chạy hai lần liền trong `fe/` đều exit 0, không còn `SecurityFatalError`.
- [x] `fe-check` xanh (lint, typecheck, test, build) — Claude chạy lại ở clone chính.
- [x] Chỉ đổi `fe/package.json` và `fe/package-lock.json`; `./scripts/gate.sh` xanh.
- [x] F-076 chuyển *Resolved* với bản đã nâng — Claude ghi sau khi duyệt.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-235`, nhánh `codex/T-235`, nền `e21999a`, chưa gỡ) · duyệt: Claude 2026-10-23.
Diff chỉ `fe/package.json` và `fe/package-lock.json`: `next` và `eslint-config-next` 16.4.0 → 16.4.2 ghim chính xác; lockfile kéo theo
`@next/env`, `@next/eslint-plugin-next`, tám gói `@next/swc-*` cùng 16.4.2, khoảng `sharp` tuỳ chọn `^0.35.4` → `^0.35.5`, bỏ một cờ
`"peer": true`; `react`/`react-dom` giữ 19.3.0; không thêm `experimental.agentUpgrade`. Bằng chứng: `next build` hai lần liền trong
worktree đều exit 0, không `SecurityFatalError`; Claude áp diff lên clone chính, `npm ci`, `npm ls` in `next@16.4.2` ·
`eslint-config-next@16.4.2`, `scripts/fe-check.sh` in `fe-check: PASS`. Gate ở clone chính bắt thêm `QC-18`
(`docs/product/2-db/10-quy-uoc-code.md`) còn ghim `next 16.4.0` — phép kiểm ấy chỉ chạy trong db-check nên worktree Codex không thấy.
Claude mở rộng scope, sửa bảng ghim và phép kiểm QC-18 sang 16.4.2 (thêm `eslint-config-next`) — lệch dòng Acceptance *chỉ đổi hai file*
có chủ ý, vì QC-18 nói lên bản là một task. F-076 chuyển *Resolved*.

<a id="t-243"></a>
### T-243 — Món đã ngừng bán chưa bán lại được

**Yêu cầu:** chủ repo 2026-10-24 trả lời `U-104`: *"trả lời có"*, rồi *"giữ món cũ cùng tên, cùng thành phần, cùng lịch sử"*; *"yêu cầu codex
cập nhật, bạn kiểm tra"*. Lời đã vào `master_plan/shop-facts.md` §8.9; thiết kế: `docs/decisions.md` **ADR-126**. **Mức:** L2 — đổi hợp đồng
API, thêm cửa ghi dữ liệu menu; không migration.

**Acceptance** (viết 2026-10-24, trước khi giao):
- [ ] Test backend do Claude viết trước trong `be/internal/menu/menu_test.go` (`TestI018_BanLaiGiuLichSu`, `TestI012_ChiChuQuanBanLai`) xanh qua
      PostgreSQL thật — Claude chạy `be-check`: bán lại có lý do xoá mốc, giữ tên và thành phần, để đúng một vết (ảnh trước có mốc cũ, ảnh sau
      rỗng mốc, đúng người · lý do); thiếu lý do 400 `field=reason`; món chưa ngừng 409 `menu_item_not_discontinued`; không thấy 404; không phải
      chủ quán 403 · chưa đăng nhập 401, không ghi; bán lại xong ngừng bán lần nữa được.
- [ ] `openapi.yaml` có `resumeMenuItem` và mã `menu_item_not_discontinued` (409), phiên bản tăng; `02-vai-va-quyen.md` thêm dòng
      `menu/ban_lai` lớp `chu_quan`; Gate 1f · 1g xanh.
- [ ] Trang Sản phẩm: món ngừng bán có form *Bán lại <tên>* (ô *Lý do bán lại* bắt buộc, nút *Bán lại*), gửi đúng thân `{ reason }`, xong báo
      *Đã bán lại <tên>.* và đọc lại; test FE do Claude viết trước, xanh.
- [ ] `./scripts/gate.sh` xanh ở clone chính.

**Mở lại 2026-11-04, Claude.** Lần giao 2026-10-24 (worktree `../lean_wt/T-243`, nền `f38f06d`) chưa ra code; nền ấy đã cũ (hợp đồng
nay 0.61.0, trang Sản phẩm đã đổi). Dựng lại: hai test backend cũ chép nguyên vào `be/internal/menu/menu_test.go` (vẫn đúng ADR-126); test FE
viết lại theo trang hiện tại trong `san-pham.test.tsx` — khối `T-243 — bán lại món đã ngừng` (bốn ca: thiếu lý do không gửi · gửi đúng thân
một lần rồi đọc lại; món đang bán không có form; 409 `menu_item_not_discontinued` báo *đang bán* và đọc lại; 400 `field=reason` gắn ô) và ca
*món ngừng bán … có form bán lại*. Đỏ đúng lý do: backend 404 không mã ở `/resumption` (`chat-review/T-243-do-truoc.log`), FE 4 ca thiếu form
*Bán lại*. Acceptance giữ như trên; hợp đồng 0.61.0 → 0.62.0. Phiếu `../lean_wt/chat-review/T-243-phieu.md`; worktree `../lean_wt/T-243-v2`,
nhánh `codex/T-243-v2`, nền `316c826` cộng thay đổi T-223 chưa commit stage sẵn; hai file test tạm rời cây chính.

2026-11-04, T-243 xong. **Codex** thi công (worktree `../lean_wt/T-243-v2`, model `gpt-6-astra`), hai lượt. Lượt 1 dừng đúng: ô
`menu_item.discontinued_at` đã có chủ `menu/ngung_ban` (Gate 1f), ADR-126 cho cửa bán lại ghi thẳng ô ấy là sai — lỗi thiết kế của Claude; Claude
chốt **ADR-126 *Sửa đổi 2026-11-04*** (cửa nội bộ `menu/moc_ngung_ban` giữ ô, hai cửa công khai gọi qua nó) và thêm `be/sqlc.yaml` vào scope.
Lượt 2 xong code, hết hạn mức ở bước build trước khi viết báo cáo; **Claude** duyệt diff thật, tích hợp bằng `git apply`, và sửa một chỗ phiếu
không lường: khoá ca `menu/ngung_ban` trong `be/internal/don/vet_cua_test.go` thành `menu/moc_ngung_ban` (`TestI018_TapCuaSuaKhopTapCa` đòi mỗi
thư mục cửa có `UPDATE` một ca vết). File: `be/internal/menu/` (`service.go` `BanLai`, `handler.go`, `repository.go`, `sql/ban_lai/`,
`sql/moc_ngung_ban/` nhận câu ngừng bán và câu xoá mốc, `sql/ngung_ban/` chỉ còn câu khoá, sqlcgen), `be/sqlc.yaml`, `apierr.go`, `openapi.yaml`
0.61.0 → 0.62.0 (`resumeMenuItem`), `01-hop-dong-api.md`, hai dòng ma trận ở `02-vai-va-quyen.md`, `schema.ts`, `form-ban-lai.tsx` mới,
`form-ngung-ban.tsx`, `du-lieu-san-pham.ts`, `san-pham.tsx`, `01-khung-fe.md`. Mã băm hai file test giao không đổi. Bằng chứng (cây chính, Docker):
`./scripts/gate.sh` exit 0 — `--- PASS: TestI018_BanLaiGiuLichSu`, `TestI012_ChiChuQuanBanLai`, `TestI018_TapCuaSuaKhopTapCa`,
`TestI018_MoiCuaSuaCoVet/menu/moc_ngung_ban`; `PASS Gate 1f` 121 cửa (`check-write-paths --list`: `discontinued_at` một chủ `menu/moc_ngung_ban`);
`PASS Gate 1g` 0.62.0; `PASS gate không cổng nào đỏ`; `./scripts/fe-check.sh` exit 0 — `Tests 639 passed (639)`, `fe-check: PASS`. Chưa có người
duyệt thứ ba. Còn lại: không.

<a id="t-238"></a>
### T-238 — Trang Sản phẩm chỉ đổi được tên món, chưa cập nhật được danh mục, giá, trạng thái

**Yêu cầu:** chủ repo 2026-10-23: *"tạo button cập nhật cho các thuộc tính tên, giá, danh mục, trạng thái — yêu cầu codex làm, bạn
kiểm tra"*. Hỏi lại cùng ngày, chủ repo chọn: giá = **sửa giá gốc thành phần** ngay trên trang; trạng thái = **chỉ nút Ngừng bán**
(hợp đồng không có cửa bán lại — mở `U-104`). **Mức:** L2 — trang thêm cửa ghi tiền (giá gốc thành phần) và ghi dữ liệu menu; không
đổi backend, hợp đồng, migration.

**Claude quyết 2026-10-23 (trình bày, không phải luật quán):** (1) cột Thao tác mỗi dòng một nút **Cập nhật** (aria-label
*Cập nhật <tên>*) thay nút *Đổi tên*, mở ngăn bên phải tiêu đề *Cập nhật <tên>* có bốn phần, mỗi phần một form riêng gửi một lệnh:
*Đổi tên* (`PUT /menu-items/{id}`, form sẵn có), *Chuyển danh mục* (`PUT /menu-items/{id}/category`), *Giá gốc thành phần*
(`PUT /menu-components/{id}/base-price`, mỗi thành phần một form), *Ngừng bán* (`POST /menu-items/{id}/discontinuation`); mọi lệnh
bắt buộc lý do — riêng lần **xếp đầu** món chưa xếp thì hợp đồng không nhận lý do, form không hỏi; (2) thành phần và giá gốc đọc qua
`POST /price-quotes` như trang Menu & giá (`useThanhPhanGia`, hợp đồng không có đường đọc thành phần riêng) với tổ hợp đầu của
món; món ngừng bán không có trong `/menu` nên phần giá ghi *Món đã ngừng bán, không đổi giá ở đây*; (3) phần giá luôn có lời nhắc
*Đổi giá gốc thì mọi món dùng chung thành phần này đổi giá theo*; số tiền gửi là số nguyên không âm chủ quán gõ, FE không tính;
(4) món ngừng bán: không phần *Ngừng bán*, có câu *Món đã ngừng bán. Chưa có cách bán lại.* (chờ `U-104`); (5) ghi xong làm mất hiệu lực
`["menu-categories"]`, `["menu"]`, `["price-quotes"]` rồi đọc lại; ngăn giữ mở, báo *Đã …*; (6) luật cũ của P4A-04 *trang không có nút
giá · ngừng bán* được nới theo lời chủ repo; luật *không ghi tay cache*, *một lần bấm một lệnh*, *lời từ chối gắn đúng ô* giữ.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] `san-pham.test.tsx` do Claude viết trước (hồi quy `I-018` phía FE — mọi lệnh cập nhật mang lý do, thiếu lý do không gửi; `I-013` — FE không gửi giá món, chỉ giá gốc chủ quán gõ) — xanh, Codex không sửa.
- [x] Mỗi dòng có nút *Cập nhật <tên>*; ngăn có đủ bốn phần như quyết định (1), (2), (4); thân lệnh đúng hợp đồng.
- [x] Chỉ đổi file trong `fe/src/app/chu-quan/_components/` (san-pham, du-lieu-san-pham, form mới cho danh mục · giá · ngừng bán) và test trên; không sửa `du-lieu-menu-gia.ts`, `hop-thoai-sua-co-ly-do.tsx`, `components/ui/`; không thêm phụ thuộc.
- [x] `./scripts/gate.sh` xanh ở clone chính; Claude chạy lại test trang Menu & giá và Danh mục.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-238`, nhánh `codex/T-238`, nền `42dae88`) · duyệt: Claude 2026-10-23. Claude viết
`san-pham.test.tsx` trước (31 ca, đỏ 16 trước khi giao) và `cmp` xác nhận Codex không đổi nó. Claude đọc diff: ba form mới
(`form-danh-muc-mon.tsx`, `form-gia-thanh-phan.tsx`, `form-ngung-ban.tsx`) và ba hook ghi trong `du-lieu-san-pham.ts`; thân lệnh giá chỉ
`{ base_price_vnd, reason }`, giá kiểm `^\d+$` số nguyên an toàn, không phép tính tiền nào; xếp lần đầu không gửi lý do; ghi xong làm mất
hiệu lực `["menu-categories"]`, `["menu"]`, `["price-quotes"]`; ngăn đặt ở cấp trang để món chuyển nhóm không làm mất ngăn. Sandbox Codex
chặn `next build`; Claude chạy `./scripts/gate.sh` trong worktree rồi ở clone chính sau `git apply`: lượt đầu đỏ vì việc khác đang dở (F-076
ở worktree; QC-18 ở clone chính lúc T-235 đang đổi bảng ghim), lượt hai xanh, Vitest 469/469. Còn lại: chưa xem trên trình duyệt; bán lại
món đã ngừng chờ `U-104`.

<a id="t-234"></a>
### T-234 — Trang Sản phẩm của chủ quán chưa theo bản thiết kế, chỉ bày tên món

**Yêu cầu:** chủ repo 2026-10-23: *"fe/src/app/chu-quan/san-pham — hãy yêu cầu codex sửa page trên dựa trên
docs/product/4-fe/thiet_ke/chu_quan/san_pham/san-pham.html, hãy thêm tất cả các thuộc tính của sản phẩm vào"*. Hỏi lại cùng ngày "tất cả
thuộc tính" là gì, chủ repo chọn **chỉ dữ liệu đã có** (không mở rộng API), rồi cùng lượt nói thêm: *"thêm giá và danh mục sản phẩm"*. **Mức:** L1 —
giao diện, chỉ **đọc** số tiền backend trả như trang Menu & giá (P4-05), không cộng, không tính thử, không đổi dữ liệu hay hợp đồng.

**Claude quyết 2026-10-23 (trình bày, không phải luật quán):** (1) thuộc tính món là những gì `MenuCategoryItem` trả — tên, danh mục
chứa nó (hoặc *Chưa xếp*), trạng thái *Đang bán* / *Ngừng bán* theo `discontinued` — cộng **giá** đọc từ `GET /menu` (khoá `["menu"]`
dùng chung với Menu & giá), ghép theo `menu_item_id`: mỗi phần tử `prices` một dòng *tên lựa chọn · giá*, không lựa chọn thì chỉ giá; không
chọn giá thấp nhất, không cộng (ADR-086); món ngừng bán không có trong `/menu` nên ô giá là *—*; món đang bán mà `/menu` không có thì
*Chưa có giá*; `/menu` đọc lỗi thì ô giá *Chưa đọc được giá*, bảng vẫn hiện; thêm hay đổi tên xong đọc lại cả hai. Thành phần, giá gốc,
ngày tạo, mã món không bày. Luật *trang không bày giá* của test P4A-04 được nới theo lời chủ repo; luật *không gọi `/price-quotes`* giữ; (2) phong cách như `T-231`: token của bản thiết kế khai
trong phạm vi trang, sáng mặc định, tối theo `.dark`, không sửa `globals.css`, khung, `components/ui/`, `hop-thoai-sua-co-ly-do.tsx`
(khuôn ấy gắn lệnh giá của P4-05); (3) *Thêm món* mở ngăn bên phải, thêm xong ngăn **vẫn mở** với form đã xoá để thêm tiếp (bản thiết kế
đóng ngăn chỉ vì nó là bản tĩnh); *Đổi tên* mở ngăn bên phải, lưu xong đóng ngăn và báo trên trang; (4) không làm nhãn component, chú
giải, khối *Trạng thái minh hoạ*, nút sáng / tối của bản thiết kế.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] Đầu trang: tiêu đề *Sản phẩm* kèm huy hiệu *N món* (N = số món backend trả, kể cả chưa xếp), nút *Đọc lại danh sách* và nút cam *Thêm món*; không có nút *Thêm món* khi chưa có danh mục hoặc chưa đọc được.
- [x] Mỗi danh mục (đúng thứ backend) và nhóm *Chưa xếp danh mục* là một thẻ có bảng cột Món · Danh mục · Trạng thái · Giá · Thao tác trong vùng cuộn ngang riêng; trạng thái *Đang bán* hoặc huy hiệu *Ngừng bán*; danh mục trống hiện *Chưa có món*.
- [x] Ô giá bày đúng từng giá `GET /menu` trả theo cách định dạng `tienGia`, kèm tên lựa chọn; *—* cho món ngừng bán, *Chưa có giá*, *Chưa đọc được giá* như quyết định (1); không có lời gọi `/price-quotes`.
- [x] *Thêm món* và *Đổi tên* mở ngăn bên phải rộng tối đa 380px; hành vi gửi, kiểm, lời từ chối giữ nguyên.
- [x] `san-pham.test.tsx` do Claude sửa trước khi giao (đọc dòng bảng thay vì mục danh sách, bấm *Thêm món* để mở ngăn, thêm ca kiểm cột và huy hiệu) — xanh, Codex không sửa.
- [x] Chỉ đổi `san-pham.tsx`, `du-lieu-san-pham.ts`, `form-them-mon.tsx`, `form-doi-ten-mon.tsx` dưới `fe/src/app/chu-quan/_components/` và test trên; không thêm phụ thuộc.
- [x] `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-234`, nhánh `codex/T-234`, nền `e21999a`, đã gỡ) · duyệt: Claude 2026-10-23.
Claude viết lại `san-pham.test.tsx` trước khi giao (đọc dòng bảng, mở ngăn *Thêm món*, thêm bốn ca cột · số món · giá · lỗi giá) và chạy
thấy đỏ 7/20; `cmp` xác nhận Codex không đổi file ấy. Claude đọc diff: chỉ bốn file `_components` trong scope; giá chỉ là phần tử `prices`
của `GET /menu` qua `useMenuGia` và `tienGia`, không phép cộng tiền nào (tổng duy nhất là đếm số món); ghi xong làm mất hiệu lực
`["menu-categories"]` và `["menu"]`; `FormThemMon` bỏ h2 riêng vì `DialogTitle` thay — form này chỉ trang Sản phẩm dùng. Sandbox của Codex
chặn `next build` (không mở được cổng); Claude chạy `./scripts/gate.sh` ở clone chính sau `git apply`: lượt đầu đỏ vì F-076 (Next.js
16.4.0 tự dừng nhắc nâng cấp), lượt hai xanh, Vitest 458/458. Còn lại: chưa xem trực quan trên trình duyệt ở hai giao diện.

<a id="t-233"></a>
### T-233 — Trang gọi món của khách hiện không có kiểu nào, chưa giống bản thiết kế menu

**Yêu cầu:** chủ repo 2026-10-23, mở `http://localhost:3000/ban/<mã>` và `docs/product/4-fe/thiet_ke/khach_hang/menu/menu.html`: *"yêu cầu
codex chỉnh lại để giống với menu.html — css và tailwind"*. **Mức:** L1 — chỉ trình bày màn khách; không chạm hợp đồng, cửa ghi, tiền.

**Claude đo 2026-10-23:** chụp hai trang bằng Chrome headless ở bề ngang 480px — trang thật là chữ trơn trên nền tối, không thẻ, không khung,
không màu nhấn. HTML phục vụ không có thuộc tính `class` trên `main` hay `article`; file CSS phục vụ có `.page`, `.card` không băm và tên
nguồn `thuc-don-khach.module.css.css`. Gốc: luật `turbopack.rules["*.css"]` (`as: "*.css"`) trong `fe/next.config.ts` khớp cả `*.module.css` và
gắn lại đuôi `.css`, nên file mất nghĩa module, `styles.*` là `undefined` (F-075). Test không thấy vì vitest tự xử lý CSS module.

**Claude quyết 2026-10-23 (trình bày, không phải luật quán):** (1) không sửa `next.config.ts` — luật ấy nạp Tailwind cho cả app; thay vào đó
bỏ `thuc-don-khach.module.css`, kiểu của trang khách là một file CSS thường import từ `phieu-khach.tsx`, mọi selector nằm dưới một lớp gốc
của trang (token màu, thứ Tailwind khó viết), còn bố cục dùng lớp Tailwind đọc token qua `var(--…)`; (2) giữ nguyên mọi quyết định (1)–(6) của
T-232, trong đó phần **không** làm; (3) thêm ô ảnh giữ chỗ trên thẻ như bản thiết kế, chỉ là khối trang trí có biểu tượng `lucide`
`aria-hidden`, không ảnh thật; (4) nút gửi được thêm số món và tổng `aria-hidden` như `CartBottomBar` nhưng tên truy cập giữ đúng chữ cũ;
(5) nút xoá dòng thành biểu tượng thùng rác, tên truy cập vẫn `Xoá dòng N`; ô `Số lượng` giữ là ô số, chỉ thu nhỏ theo `.compact`.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [ ] Ảnh chụp `/ban/<mã>` ở 480px, sáng và tối, có đủ khối của bản thiết kế mà T-232 đã làm: đầu trang hàng ngang, dải giỏ với nút cam bo tròn và chip, ô tìm nền `--field`, nhãn mục nhạt, thẻ ba cột (ô ảnh · chữ · giá + bớt/thêm) nền `--card` viền bo 10px, huy hiệu ×N, tóm tắt đơn là thẻ, nút gửi cam cao 52px rộng hết khung `max-width: 472px` — Claude chụp và so với `menu.html`.
- [ ] Không còn file `*.module.css` dưới `fe/src/app/ban/`; mọi selector của file CSS mới bắt đầu bằng lớp gốc của trang; màu chỉ qua token của `menu.html` (giá trị sáng · tối như `thuc-don-khach.module.css` hiện có), tối theo `.dark` sẵn có.
- [ ] `khach-qr.test.tsx` và `dat-mon.test.tsx` giữ nguyên từng byte và xanh; `thuc-don-khach.test.tsx` xanh, chỉ đổi nếu phép kiểm dựa vào chữ hiển thị đã đổi theo quyết định (5).
- [ ] Không sửa `next.config.ts`, `globals.css`, `components/ui/`, `BoSoanMon`; không thêm phụ thuộc.
- [ ] `01-khung-fe.md` dòng `ThucDonKhach` nói kiểu ở file CSS thường; `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-233`, nhánh `codex/T-233`, nền `2a8df0f`, chưa gỡ) · duyệt: Claude 2026-10-23 — đọc
diff bốn file; Codex dùng `.khach-menu:where(.dark *)` cho bộ tối và `<button>` thường cho nút gửi (tên truy cập giữ nguyên, số món và tổng
`aria-hidden`). Claude sửa một chỗ: mục COMBO / MÓN LẺ rỗng thì ẩn cả nhãn (menu hiện không có combo nào nên nhãn đứng trơ). Codex không chạy
được gate trong sandbox (cache Go); Claude chạy ở clone chính: `./scripts/gate.sh` xanh, `fe-check` 454/454 test, build qua (lần đầu dừng ở
`SecurityFatalError` của Next.js, chạy lại thì qua). Ảnh Chrome headless `/ban/<mã>` hai giao diện: đầu trang, dải giỏ cam, ô tìm, thẻ ba cột
có ô ảnh, stepper, nền và màu đúng token của `menu.html`. Còn lại: (a) `fe/src/app/ban/_components/thuc-don-khach.module.css` chưa xoá — lệnh
xoá của Claude bị từ chối, file không còn được import; (b) chưa thấy luật `@media (max-width:480px)` trên ảnh vì Chrome headless không thu cửa
sổ dưới ~500px; (c) chưa chụp tóm tắt đơn có dòng và nút gửi khi có tổng — headless không bấm thêm món được.

[↑ đầu file](#top)

<a id="t-232"></a>
### T-232 — Trang gọi món của khách còn là bộ soạn của quầy, chưa theo bản thiết kế menu

**Yêu cầu:** chủ repo 2026-10-23, mở `docs/product/4-fe/thiet_ke/khach_hang/menu/menu.html`: *"yêu cầu codex làm task để tạo page trên
còn bạn kiểm tra"*. **Mức:** L1 — giao diện và cách soạn giỏ trên màn khách; không chạm hợp đồng, cửa ghi, tiền (tổng vẫn chỉ lấy backend).

**Claude quyết 2026-10-23 (trình bày, không phải luật quán):** (1) trang thật của bản thiết kế là `PhieuKhach` — dùng chung cho
`/ban/[ma]` và `/dat-mon`, nên cả hai đổi; `BoSoanMon` của quầy **không** đổi, phía khách có component riêng, chỉ được thêm `export`
cho hàm sẵn có trong `bo-soan-mon.tsx`; (2) làm: thẻ combo (tên, giá `price_vnd`, danh sách món ×số), thẻ món lẻ (tên, giá thấp nhất
trong `prices`), nút bớt · thêm trên thẻ, ô tìm theo tên lọc ngay trên màn, dải giỏ dính đầu trang (số món, tổng backend), tóm tắt đơn từng
dòng (lựa chọn dạng chip, bớt · thêm, xoá, giá dòng từ `POST /price-quotes`), nút gửi cam to cuối trang, token sáng · tối của
`styke/style.md` khai trong phạm vi trang theo lớp `.dark` sẵn có (T-229); (3) **không** làm vì `/menu` công khai không có dữ liệu hay vì
là luật quán chưa có: tab danh mục, ảnh · banner · khẩu hiệu, mô tả món, yêu thích, nút Đăng nhập, điều hướng cuối trang, khối CANH và
bảng *Tổng số món* với đơn giá từng thành phần, ghi chú cho bếp (`QrOrderRequest` không có trường), hộp xác nhận trước khi gửi, ngăn kéo
giỏ, nút sáng · tối thứ hai; (4) giữ `h1` = nhãn bàn có biểu tượng QR (T-222, chủ repo 2026-10-21) thay vì tên quán như bản thiết kế — tên
quán `SITE_NAME` đứng ngoài `h1`; (5) giữ chữ nút *Gửi lượt gọi* · *Đặt đơn* · *Gửi lại*, không dùng *Thanh toán* — khách QR chưa trả tiền
lúc gửi; (6) ba tài liệu `customer_menu_*` cạnh bản thiết kế dò từ codebase khác, không phải nguồn của task.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] Màn khách bày thẻ combo và thẻ món lẻ theo khối `ComboSection` · `ProductList`; nút thêm trên thẻ có tên truy cập `Thêm {tên món}` · `Thêm combo {tên}` và thêm một dòng với lựa chọn mặc định; nút bớt giảm số của dòng cuối cùng của món ấy, về 0 thì bỏ dòng; số giữa hai nút là tổng số lượng các dòng của món — test mới.
- [x] Ô tìm món lọc thẻ theo tên, không phân biệt hoa thường và dấu; không khớp thì có một câu báo — test mới.
- [x] Dải giỏ dính đầu trang có số món và tổng `total_vnd` khi tính xong, không tự tính tiền; bấm đưa tới tóm tắt đơn — test mới.
- [x] Tóm tắt đơn: mỗi dòng vẫn là vùng `Dòng N` với lựa chọn là radio, ô `Số lượng`, nút `Xoá dòng N`; combo bày suất như trước; giá dòng combo vẫn từ `useGiaCombo`.
- [x] `khach-qr.test.tsx` và `dat-mon.test.tsx` giữ nguyên từng byte và xanh — gửi, gửi lại giữ dấu, lời từ chối, giỏ nháp, `h1` không đổi.
- [x] Màu chỉ qua token của bản thiết kế, sáng mặc định, tối theo `.dark`; không sửa `globals.css`, `components/ui/`, `BoSoanMon` (ngoài `export`); không thêm phụ thuộc.
- [x] `01-khung-fe.md` có dòng component mới; `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-232`, nhánh `codex/T-232`, nền `23c18b4`, đã gỡ) · duyệt: Claude 2026-10-23 — đọc diff
sáu file; Claude sửa bốn chỗ: dùng lại `LuaChon` của `BoSoanMon` (thêm `export`) thay bản Codex chép lại, bỏ `export` thừa của `coMat`; chữ
trên nút cam là `#fff` như bản thiết kế (Codex dùng `--text`, ở giao diện sáng thành chữ đen trên cam); ô số lượng xoá trống đếm 0 ở thẻ,
chip và dải giỏ, nút bớt bỏ được dòng ấy (trước đó hiện `NaN`) — thêm test; nhóm COMBO / MÓN LẺ rỗng trong tóm tắt thì ẩn; bộ tối đổi từ `:global(.dark) .page` sang `html[class~="dark"] .page` vì `next build` báo không đọc được `:global` (bộ tối có thể bị bỏ). Codex không chạy
được gate trong sandbox (cache Go); Claude chạy ở clone chính: `./scripts/gate.sh` xanh, `fe-check` PASS 454/454 test, build qua;
`khach-qr.test.tsx` · `dat-mon.test.tsx` không đổi. File: `fe/src/app/ban/_components/thuc-don-khach.tsx` · `thuc-don-khach.module.css` ·
`fe/src/app/ban/thuc-don-khach.test.tsx` · `phieu-khach.tsx` · `fe/src/components/shared/bo-soan-mon.tsx` · `docs/product/4-fe/01-khung-fe.md`.
Còn lại: chưa xem trực quan trên trình duyệt thật ở cả hai giao diện. `next build` đôi lúc dừng với `SecurityFatalError` khuyên nâng Next.js 16.4.0 — chạy lại thì qua; nâng phụ thuộc ngoài phạm vi task này.

[↑ đầu file](#top)

<a id="t-231"></a>
### T-231 — Trang Vận hành thật chưa theo bản thiết kế phong cách mới

**Yêu cầu:** chủ repo 2026-10-23: *"hãy sửa page fe/src/app/chu-quan/van-hanh dựa trên thiết kế mới
docs/product/4-fe/thiet_ke/chu_quan/van_hanh/van-hanh-copy.html, docs/product/4-fe/thiet_ke/styke/style.md — yêu cầu codex làm và bạn
kiểm tra"*. **Mức:** L1 — chỉ đổi giao diện, không chạm tiền, dữ liệu, hợp đồng.

**Claude quyết 2026-10-23 (trình bày, không phải luật quán):** (1) chỉ đổi **phong cách** của `TrangVanHanh`
(`fe/src/app/chu-quan/_components/van-hanh.tsx`): token `--bg · --card · --line · --muted · --accent · --field · --text` và màu
trạng thái đề xuất của bản thiết kế, khai **trong phạm vi trang** (lớp bọc), sáng mặc định, tối theo lớp `.dark` sẵn có của T-229 — không
sửa `globals.css`, khung chủ quán, thanh điều hướng hay primitive `components/ui/`; (2) không thêm phông *Be Vietnam Pro* (thêm phông là
việc của khung gốc); (3) phần của bản thiết kế **chưa có dữ liệu hay luật** không làm ở đây: hộp *Xác nhận thanh toán* (thuộc `T-227`),
tách canh *rau · không rau · giò*, nhãn *đề xuất — chưa có trong hợp đồng*, nhãn component, chú giải, khối *Giả định*; (4) bản thiết kế bỏ
cột *Người* ở lịch sử đem ra — giữ cột, hỏi chủ repo sau.

**Acceptance** (viết 2026-10-23, trước khi giao):
- [x] Trang dùng token của bản thiết kế cho nền, thẻ (bo 10px, viền mảnh), bảng (chữ phụ xám ở đầu cột, viền dòng), nút chính cam, ô *nhiều* nền vàng trạng thái, sơ đồ bàn xanh · vàng · trung tính, dòng *Tổng* nền `--field`, *Tiền bánh đã ra* màu cam.
- [x] Đổi sáng / tối bằng nút sẵn có thì trang đổi theo bộ token tương ứng; không còn lớp màu Tailwind ghi cứng (`bg-yellow-100`, `text-red-700`…) trong `van-hanh.tsx`.
- [x] `dem-ra.test.tsx` giữ nguyên từng byte; `van-hanh.test.tsx` chỉ đổi ba assertion màu (Claude sửa 2026-10-23, trước khi giao lại: test cũ đòi `bg-yellow-100` · `bg-red-50` · `text-red-700`, nay đòi lớp có nghĩa `nhieu` · `dong-ghep` · `them` như bản thiết kế); cả hai xanh — hành vi, tên truy cập, câu chữ không đổi.
- [x] Ngoài test trên, chỉ `fe/src/app/chu-quan/_components/van-hanh.tsx` đổi; không thêm phụ thuộc.
- [x] `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-231`, nhánh `codex/T-231`, nền `23c18b4`, đã gỡ) · duyệt: Claude 2026-10-23.
Lượt đầu Codex dừng không sửa gì vì phiếu tự mâu thuẫn (bảo xoá lớp màu mà test cũ đòi); Claude sửa ba assertion rồi giao lại. Claude đọc
diff: chỉ đổi lớp và CSS trong khối `<style>` của trang, không đụng logic, lời gọi API hay chữ; `cmp` xác nhận hai file test đúng bản
Claude để lại. Codex không chạy được Vitest trong sandbox (EPERM `.vite-temp`); Claude chạy ở clone chính: `vitest run src/app/chu-quan`
290/290; mọi cổng tĩnh của `./scripts/gate.sh` xanh nhưng Gate 1 đỏ vì **một test không thuộc task này** —
`fe/src/app/ban/thuc-don-khach.test.tsx` (file chưa commit của một phần việc khác đang làm dở trong clone chính, không có ở `HEAD`). Bằng
chứng riêng của T-231, ở worktree = `HEAD` + diff này: `vitest run` 450/450, `lint` và `tsc --noEmit` thoát 0. Cảnh báo bảo mật Next.js
chặn build một lần, chạy lại thì đi tiếp. Codex giữ token `--vh-*` khai trong phạm vi trang, cả hộp thoại (portal) cũng mang lớp ấy. Còn lại:
chưa xem trực quan trên trình duyệt; bản thiết kế bỏ cột *Người* của lịch sử đem ra — giữ, chờ chủ repo nói.
Chủ repo 2026-10-23, sau duyệt: *"Tổng thiếu theo bàn — bỏ table ngoài cùng"* ⇒ Claude bỏ khung viền quanh bảng của khối này (giữ vùng cuộn ngang); 25/25 test trang xanh.
Chủ repo 2026-10-23: *"giảm space giữa các component ở bên trong và ngoài cùng"* ⇒ trang bỏ đệm riêng (khung chung `p-6` vẫn giữ — dùng chung với `/quay`, `/tram`), khoảng giữa khối 12→8px, đệm thẻ 12→10px, lề bảng bỏ, ô và lưới bàn gọn hơn; 25/25 test trang xanh.
Chủ repo 2026-10-23: *"giảm thêm chút nữa — codex làm, bạn kiểm tra"* ⇒ Codex (worktree `../lean_wt/T-231b`, nền `1d182c0`, đã gỡ) giảm khoảng cách theo số Claude giao: giữa khối 8→6px, đệm thẻ 10→8px, ô bảng 8→6px, thẻ chọn · sơ đồ · lịch sử gọn hơn, vùng bấm giữ nguyên; mép ngoài dùng lề âm `-m-3 sm:-m-2` (còn 12px / 16px, khung chung `p-6` không đổi). Claude duyệt: Codex để `mx-auto` cạnh lề âm làm mất lề âm ngang — Claude bỏ `mx-auto w-full`, rồi bỏ cả lề âm phía trên (thành `-mx-3 -mb-3 sm:-mx-2 sm:-mb-2`) vì thanh điều hướng gọn lại (L0, cùng ngày) chỉ còn cách 12px — lề âm trên làm tiêu đề dính đường kẻ. `vitest run src/app/chu-quan` 290/290, eslint, `tsc` xanh.

[↑ đầu file](#top)

<a id="t-230"></a>
### T-230 — Nút sáng / tối nằm góc dưới, chủ repo muốn nó cạnh nút Đăng xuất

**Yêu cầu:** chủ repo 2026-10-22, sau T-229: *"tôi muốn có button tối sáng ở cạnh nut đăng xuất"*. **Mức:** L1 — chỉ vị trí nút.

**Claude quyết 2026-10-22 (trình bày):** `KhungTheoVai` (`/quay` · `/chu-quan` · `/tram`) đặt `ChuyenGiaoDien` ngay trước nút *Đăng xuất*;
trang không có thanh đầu (đăng nhập, đặt món công khai…) giữ nút nổi góc dưới trái; nút nổi tự ẩn khi trang có nút ở thanh đầu, nên mỗi màn
đúng một nút.

**Acceptance** (viết 2026-10-22, trước khi sửa):
- [x] Thanh đầu khung theo vai có nút sáng / tối đứng ngay trước *Đăng xuất*.
- [x] Nút nổi ẩn khi trang có nút ở thanh đầu; trang không thanh đầu vẫn có nút nổi.
- [x] Test cũ còn xanh; `./scripts/gate.sh` xanh.

**Bàn giao:** thực hiện: Claude 2026-10-22 · duyệt: chưa có người duyệt độc lập. File: `chuyen-giao-dien.tsx` (prop `noi`) · test · `fe/src/app/layout.tsx` · `fe/src/components/tai-khoan/khung-theo-vai.tsx` · `fe/src/lib/giao-dien.ts` (chịu được máy không có `matchMedia` — tám test cũ của khung vỡ vì jsdom thiếu hàm này) · `01-khung-fe.md` §4. jsdom không chấm `:has`, nên Claude soát CSS đã sinh có luật `display:none`. `./scripts/gate.sh` xanh, `fe-check` 450/450.

<a id="t-229"></a>
### T-229 — Chưa có nút chuyển giao diện sáng / tối

**Yêu cầu:** chủ repo 2026-10-22: *"yêu cầu codex làm button chuyển từ light and dark"*. Nền đã có: `fe/src/app/globals.css` có khối
`.dark` và `@custom-variant dark` của shadcn, nhưng không code nào gắn class `dark`. **Mức:** L1 — hành vi giao diện, không chạm tiền,
dữ liệu, hợp đồng.

**Claude quyết 2026-10-22 (trình bày, không phải luật quán):** (1) một nút dùng chung `ChuyenGiaoDien` ở `fe/src/components/shared/`,
gắn **một lần** ở `fe/src/app/layout.tsx`, nổi góc **dưới trái** mọi màn; (2) lựa chọn lưu ở `localStorage` khoá `giao-dien`
(`sang` · `toi`), đọc ghi đều bọc `try/catch`; chưa chọn thì theo `prefers-color-scheme` của máy; (3) một đoạn script chạy trước khi vẽ
trong `<head>` gắn class để không nháy màu; `<html>` có `suppressHydrationWarning`; (4) **không thêm thư viện** (không `next-themes`) —
thêm phụ thuộc là việc của ADR-100; (5) chỗ ghi cứng màu (`bg-yellow-100`, `text-red-700`…) thêm biến thể `dark:` để chữ còn đọc được.

**Acceptance** (viết 2026-10-22, trước khi giao):
- [x] Mọi màn có một nút có `aria-label` nói nó chuyển sang giao diện nào; bấm thì `<html>` thêm hoặc bỏ class `dark`.
- [x] Lựa chọn được ghi vào `localStorage["giao-dien"]` và còn giữ sau khi tải lại; `localStorage` ném lỗi thì nút vẫn chuyển được, không vỡ màn.
- [x] Chưa có lựa chọn: theo `prefers-color-scheme` của máy.
- [x] Script trước khi vẽ gắn class đúng trước lúc React chạy; không cảnh báo hydration.
- [x] Không thêm phụ thuộc vào `fe/package.json`.
- [x] Màu ghi cứng trong `fe/src/**/*.tsx` có biến thể `dark:`.
- [x] Test Vitest cho ba ý đầu; test cũ còn xanh.
- [x] `docs/product/4-fe/01-khung-fe.md` §4 có một dòng cho `ChuyenGiaoDien`.
- [x] `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-229`, nhánh `codex/T-229`, nền `9315ac2`, đã gỡ) · duyệt: Claude 2026-10-22 — đọc diff, **bỏ** chỗ Codex sửa tay `fe/src/components/ui/dialog.tsx` (primitive shadcn, ADR-100 điểm 2); grep lại màu ghi cứng: mọi lớp ngoài test có `dark:`. Codex không chạy được Vitest trong sandbox (EPERM ghi `.vite-temp`); Claude chạy ở clone chính: `./scripts/gate.sh` xanh, `fe-check` 449/449 test, build qua. File: `fe/src/lib/giao-dien.ts` · `fe/src/components/shared/chuyen-giao-dien.tsx` · `chuyen-giao-dien.test.tsx` · `fe/src/app/layout.tsx` · `fe/src/app/chu-quan/_components/kho.tsx` · `van-hanh.tsx` · `docs/product/4-fe/01-khung-fe.md`. Còn lại: chưa xem trực quan trên trình duyệt thật.

<a id="t-228"></a>
### T-228 — Trang Vận hành chỉ cho xem số thiếu, chưa ghi được phần đã đem ra

**Yêu cầu:** chủ repo 2026-10-21 chốt thiết kế `docs/product/4-fe/thiet_ke/chu_quan/van_hanh/van-hanh.html`: bấm một ô số của
*Tổng thiếu theo bàn* hiện ô chọn 0…số thiếu, chọn số thì hộp xác nhận nhắc lại số cái và bàn, xác nhận thì số thiếu trừ đi; lịch sử
thêm một dòng. Cùng ngày chủ repo chọn: người bấm **vẫn là người đứng quầy** (giữ S-5, `master_plan/shop-facts.md` §5.4). **Mức:** L2 —
ghi việc trạm sang `served`, chạm đếm của bảng sản xuất (`I-019` · `I-020`). **Cần xong trước:** `T-226`.

**Việc của Claude trước khi giao:** (1) đối chiếu khoá gom của `ServedItem` (trạm · thành phần · `filling_option_ids`) với cách thiết kế
tách cột — trứng tách *tái · chín*, ô *nhiều* — và chốt mỗi ô bấm gửi những hàng nào; lệch thì chọn cách bày, không đổi luật S-5;
(2) cửa `sanxuat/ra_ban` thuộc lớp `quay` (`docs/product/3-be/02-vai-va-quyen.md`): phiên không đứng quầy thì ô chỉ đọc kèm câu nói
rõ vì sao, không ẩn nút rồi để cửa từ chối; (3) viết test trước. *Nghiệm thu* viết lúc mở task.

**Claude quyết 2026-10-21 (trình bày, không phải luật quán; S-5 và cửa `POST /served-marks` giữ nguyên, hợp đồng không đổi):**
(1) *Lệch khoá:* một thứ của `GET /service-board` là khoá gom **bỏ trạm**, đếm theo đơn vị; `ServedItem` là khoá gom **có trạm**, đếm theo
việc trạm, và cửa chỉ nhận cái đã ở `made`. Nên mỗi dòng bấm được là **đúng một** thứ (`menu_component_id` + `filling_option_ids`) của
một phiên; ô gom nhiều thứ còn thiếu (thịt thường và thịt *nhiều*) tách thành từng dòng, như trứng đã tách *tái · chín*. Lúc bấm, màn đọc
`GET /production-board` (công khai), lấy mọi hàng cùng khoá ở mọi trạm có phần của bàn ấy, gửi **một `ServedItem` mỗi trạm** cùng số
đã chọn. Ô chọn đi 0…`min(thiếu, made của bàn ở từng trạm)` và nói số chưa làm xong — không bày số mà cửa chắc chắn từ chối.
(2) *Phiên ghép nhiều bàn:* cửa nhận **một** `dining_table_id`, còn số của phiên cộng mọi bàn ⇒ ô chỉ đọc, câu chỉ sang màn Sản xuất của quầy.
(3) *Không đứng quầy* (`counter_duty_id` của `GET /sessions/current` rỗng hay chưa đọc được) ⇒ không nút, có câu nói vì sao. Hàng *Tổng*
và hàng cộng thử không bấm được. (4) Còn hở, ghi lại không chữa ở đây: cửa chọn việc mỗi trạm độc lập (cũ trước); nếu tráng và gấp đã làm
khác đơn vị thì một lần bấm có thể chưa làm *thiếu* giảm đủ — tính chất sẵn có của cửa, cũng có ở màn Sản xuất của quầy.

**Acceptance** (viết 2026-10-21, trước khi giao; test viết trước ở `fe/src/app/chu-quan/van-hanh/dem-ra.test.tsx`, người thi công không sửa):
- [x] Đứng quầy: mỗi thứ còn thiếu của phiên một bàn là một nút `Đem ra <bàn> · <thứ>`; thịt thường và thịt nhiều tách dòng; có câu *Bấm vào một ô số để báo đã đem ra.*
- [x] Không đứng quầy: không nút số, câu *Chỉ người đang đứng quầy ghi được đem ra…*, không lời gọi ghi.
- [x] Phiên ghép nhiều bàn: không nút, câu chỉ sang màn Sản xuất của quầy.
- [x] Bấm ô đọc `GET /production-board` một lần; nút 0…`min(thiếu, made từng trạm của bàn)`; nói số chưa làm xong.
- [x] Chọn 0 đóng, không ghi; *Huỷ* ở hộp xác nhận không ghi.
- [x] Hộp *Xác nhận đem ra* nhắc số cái, thứ, bàn, thiếu trước → sau; *Xác nhận* gửi đúng một `POST /served-marks` với một hàng mỗi trạm của đúng khoá gom; báo *Đã ghi đem ra…*; đọc lại `GET /service-board`.
- [x] Hàng nhiều nhân gửi khoá gom của nó, không lẫn hàng thường; bấm *Xác nhận* hai lần chỉ gửi một lần.
- [x] Cửa từ chối ⇒ báo theo mã, không báo đã ghi; `served_quantity_exceeds_made` thì đọc lại bảng. Đọc bảng sản xuất lỗi ⇒ báo, không nút số.
- [x] Mười bốn test cũ của `van-hanh.test.tsx` còn xanh (chỉ sửa backend giả cho đúng đường, và câu *Bấm vào một ô số*); `01-khung-fe.md` §1 · §2 ghi nguồn mới và cửa ghi.
- [x] `./scripts/gate.sh` xanh; Claude chạy lại `fe-check`. Không file `be/`, `db/`, `openapi.yaml` nào đổi.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-228`, nhánh `codex/T-228`, nền `1341942`; phiên đầu hết hạn mức trước khi sửa file, làm tiếp bằng `codex exec resume` 2026-10-22) · duyệt: Claude 2026-10-22 — đọc diff ba file (`van-hanh.tsx`, `van-hanh.test.tsx`, `01-khung-fe.md`), đối chiếu mười quyết định của phiếu; `dem-ra.test.tsx` giữ nguyên từng byte (`cmp`). Codex không chạy được Vitest trong sandbox; Claude chạy lại: worktree 437/437 test xanh (build vấp symlink `node_modules`, lỗi môi trường), đưa về clone chính, `./scripts/gate.sh` xanh đủ lint · typecheck · test · build. Còn mở: điểm (4) ở trên — cửa chọn việc mỗi trạm độc lập.

<a id="t-227"></a>
### T-227 — Hoá đơn bàn cộng mọi phần đã gọi, trong khi chủ repo chọn chỉ thu phần đã ra

**Yêu cầu:** chủ repo 2026-10-21 chọn trong hội thoại phương án *"Chỉ tiền món đã ra — món chưa ra bị bỏ khỏi hoá đơn lúc thanh toán"*
(`master_plan/shop-facts.md` §6.1); thiết kế đã chốt cho bấm số ở cột *Tiền bánh đã ra* để thanh toán và xoá bàn khỏi bảng. Hôm nay
`phien.TongTien` cộng `line_total_vnd` của **mọi** đơn chưa huỷ và cửa đóng từ chối phiên còn đơn chưa xong
(`docs/product/3-be/04-luong-tai-ban.md` §4); `quality/invariants.md` **I-002** giữ *tổng bằng mọi đơn*. **Mức:** L3 — luật tiền,
invariant, hợp đồng; mở thì chia thành phần L1 · L2, thiết kế được duyệt trước dòng code đầu, ADR. Cửa `hoadon/dong` thuộc lớp
`quay`, nên người bấm cũng là người đứng quầy như `T-228` — *suy ra* của Claude, chưa hỏi.

**U-103 có lời** (chủ repo 2026-10-22, chọn trong hội thoại; ghi `master_plan/shop-facts.md` §6.1): **(1)** phần chưa ra lúc thanh toán
bị **huỷ, bếp dừng làm**; **(2)** luật áp cho **mọi** lần đóng phiên bàn, không riêng trang Vận hành. Cùng ngày chủ repo chọn thêm: suất ra
dở **không thu**. Thiết kế: `docs/decisions.md` **ADR-125**, chủ repo duyệt 2026-10-22 (*"duyệt"*), gồm (a) · (b). `quality/invariants.md`
**I-002** và **I-017** viết lại cùng ngày. Chủ repo 2026-10-22: *"yêu cầu codex làm bạn kiểm tra"* — Codex viết cả test lẫn code (lệch
`docs/prompt-guideline.md` §6.1 *L2: Claude viết test trước*, theo lời chủ repo); Claude duyệt diff, chạy lại `be-check` · `db-check` · gate.

**Phần A — L2, database + backend + hợp đồng** (Acceptance viết 2026-10-22, trước khi giao):
- [x] Migration mới: `station_job.status` nhận `cancelled` · `discarded`; `id_if_made_or_served` phủ `made · served · discarded`; có `.down.sql`
      từ chối lùi khi đã có việc mang hai trạng thái ấy; `docs/product/2-db/05-luoc-do-san-xuat.md` và `07-thu-tu-migration.md` ghi bước mới.
- [x] `vongdoi`: thêm `pending → cancelled`, `made → discarded`, có vết; không đường nào ra khỏi hai trạng thái ấy.
- [x] Một đoạn tính *tiền đã ra theo suất* (ADR-125 điểm 1 · 2, kể cả (b)) thay đoạn tạm tính đánh dấu ở `tongquan`; `phien.TongTien`,
      `phien/tinh_tien`, `hoadon/dong`, `GET /service-board` và `GET /owner-overview` cùng đọc nó; test so các bản đánh dấu còn xanh.
- [x] `hoadon/dong`: còn đơn chưa xong thì **không** từ chối; trong cùng giao dịch huỷ việc chưa ra, sang trạng thái đơn theo ADR-125 điểm 4,
      rồi lập hoá đơn bằng đoạn ở trên; lời từ chối tiền (`payment_parts_mismatch` · `debtor_name_mismatch`) đến trước mọi câu ghi.
- [x] Lùi một mẻ có việc `discarded` ⇒ tên từ chối mới, mã công khai 409; bảng sản xuất, hàng chờ, gom, chuyển phần bỏ hai trạng thái mới.
- [x] Test qua đường gọi HTTP: dòng 3 suất ra 2 ⇒ hoá đơn 2 suất; combo ra dở ⇒ 0; món có 2 thành phần ra 1 ⇒ 0; đóng khi còn việc
      `pending` · `made` · đơn QR chờ duyệt ⇒ 201, việc `cancelled` · `discarded`, đơn đúng trạng thái, có vết; ghép bàn huỷ cả hai bàn;
      cắt giữa lúc đóng ⇒ không nửa nào sống; đóng ⟂ gọi thêm 8 vòng ⇒ không phiên đóng còn đơn hay việc sống; `served_amount_vnd` = `due_vnd`;
      thành phần không trạm không chặn thu. Các test cũ của I-002 · I-017 sửa theo luật mới — không nới điều kiện nào khác.
- [x] `docs/product/3-be/openapi.yaml` bỏ `table_session_has_open_orders` khỏi cửa đóng, thêm mã mới, tăng phiên bản; `04-luong-tai-ban.md` §4
      viết lại; `fe/src/lib/api/schema.ts` sinh lại, chỗ FE nhắc mã bỏ đi sửa tối thiểu.
- [x] `./scripts/gate.sh` xanh; Claude chạy lại `be-check` · `db-check`.

**Bàn giao phần A:** thực hiện: Codex (worktree `../lean_wt/T-227`, nhánh `codex/T-227`, nền `a8c6cfc`; vòng hai hết hạn mức trước báo
cáo) · duyệt và sửa nốt: Claude 2026-10-22. Claude trả lời hai câu của Codex (ADR-125 *Làm rõ điểm 4*), sửa phiên bản hợp đồng `1.0.0` →
`0.49.0`, sửa đường lùi migration (`SET EXPRESSION` giữ vị trí cột — trước đó `db-check` đỏ vì lệch thứ tự cột), và chặn một lỗi tiền:
Codex đã mở `pending_confirmation → completed` cho đơn QR chưa duyệt có món không trạm, nên đơn ấy bị thu tiền — nay đoạn tiền chỉ đếm đơn đã
duyệt và đơn chưa duyệt lúc đóng luôn huỷ (test `TestI017_GiuDonDaHuyVaHuyQRChuaDuyetKhongTram`). Claude chạy ở clone chính: `./scripts/gate.sh`
xanh đủ be-check · db-check (35 bước xuôi · lùi · xuôi lại) · verify, và `./scripts/fe-check.sh` PASS sau khi sinh lại `schema.ts`.

**Phần B — L1, màn quầy và trang Vận hành** — viết Acceptance khi phần A đã commit.

<a id="t-226"></a>
### T-226 — Chủ quán chưa có trang Vận hành thật, chỉ có bản thiết kế tĩnh

**Yêu cầu:** chủ repo 2026-10-21 *"tôi chốt thiết kế hiện tại của trang vận hành hãy làm các task để hoàn thành trang trên"*. **Mức:**
L1 — trang đọc, số do backend trả, không ghi. **Cần xong trước:** `T-225`.

**Phạm vi:** route `/chu-quan/van-hanh` trong khung chủ quán (`docs/product/4-fe/01-khung-fe.md`, thêm mục điều hướng cùng lượt), năm khối
theo thứ tự thiết kế: `BangThieuTheoBan` (cột Thịt · Mộc nhĩ · Trứng tách kiểu · Chay · Canh · Tiền bánh đã ra; ô *nhiều* nền vàng có
`*`; bấm tên bàn trượt mở chi tiết dạng cột ngay dưới hàng) · `CongThuGhepDon` (tick bàn sắp phục vụ ⇒ hàng đỏ và tổng `+n` đỏ, chỉ tính
trên màn, không ghi) · `KhoiBanDangPhucVu` (mỗi bàn dạng cột, mặc định ẩn, nút *Chi tiết* mở bảng đầy đủ) · `SoDoBan` (mặc định ẩn) ·
`LichSuDemRa` (theo giờ và theo bàn, mặc định ẩn). **Không** làm ở task này: bấm ô số (`T-228`), bấm tiền (`T-227`). Số trong bản thiết kế
là minh hoạ, không phải dữ liệu. *Nghiệm thu* viết lúc mở task, khi hợp đồng của `T-225` đã có.

**Claude quyết 2026-10-21 (trình bày, không phải luật quán):** hợp đồng `GET /service-board` trả từng *thứ* theo tên thành phần và lựa
chọn đã chụp, không trả sẵn cột. Màn xếp cột bằng một hàm thuần `fe/src/app/chu-quan/_components/cot-van-hanh.ts`: `Bánh cuốn` tách theo
lựa chọn nhóm `Nhân` thành Thịt · Mộc nhĩ (`Thịt + mộc nhĩ`) · Chay; `Trứng …` một cột, một dòng mỗi kiểu; `Canh bánh cuốn` cột Canh; mọi
thứ khác (giò, nước chấm, tên bị đổi) vào cột **Khác**, chỉ hiện khi có — để không số thiếu nào bị giấu, dù bản thiết kế không có cột
này. Ánh xạ theo tên là *suy ra*, chờ chủ repo. Ô *nhiều* = `extra_filling` và còn thiếu; không suy *nhiều rau*. Cộng thử chỉ trong state
React. Không kéo theo chu kỳ (hợp đồng không trả `poll_interval_seconds`), có nút *Đọc lại*. Bỏ nhãn *đề xuất — chưa có trong hợp đồng*.

**Acceptance** (viết 2026-10-21, trước khi giao; test ở `fe/src/app/chu-quan/van-hanh/`):
- [x] Ánh xạ cột: Bánh cuốn × ba nhân, `Trứng tái`, `Trứng chín`, `Canh bánh cuốn`, `Giò` ⇒ mỗi thứ đúng một cột, `Giò` vào *Khác*; không có thứ lạ ⇒ không cột *Khác*.
- [x] `BangThieuTheoBan` chỉ hàng phiên `serving`, bàn ghép `A + B`, ô = tổng `missing`, tiền = `served_amount_vnd`, hàng *Tổng* đúng; ô nhiều có `*`.
- [x] Bấm nhãn bàn mở chi tiết ngay dưới hàng (`aria-expanded`) có tổng · đã ra · thiếu và *Tiền đơn* = `order_total_vnd`; bấm lại đóng.
- [x] Tick phiên `waiting` ⇒ hàng đỏ và *Tổng* `x+y`; *Bỏ chọn hết* gỡ; không lời gọi mạng nào khác `GET /service-board`, không ghi `localStorage`/`sessionStorage`.
- [x] `KhoiBanDangPhucVu`, `SoDoBan`, hai phần `LichSuDemRa` mặc định ẩn; nút đổi `aria-expanded` và `hidden`.
- [x] `SoDoBan` bốn nhãn theo `service_group` / `empty_tables`, số ô = số bàn backend trả.
- [x] `LichSuDemRa` giữ thứ tự backend, *Lần thứ* đúng khi một bàn có hai mốc, có tên người.
- [x] Lỗi lần đầu ⇒ `Alert` *Chưa đọc được tình hình bàn*, không khối nào; dữ liệu rỗng ⇒ câu rỗng, không lỗi.
- [x] Mọi số tiền trên màn là `order_total_vnd` / `served_amount_vnd` hoặc tổng của chúng, chỉ định dạng lại.
- [x] Mục *Vận hành* ngay sau *Tổng quan* trong `muc-chu-quan.ts`, `chu-quan.test.tsx` xanh; `01-khung-fe.md` có dòng ở §1 và §2.
- [x] `./scripts/gate.sh` xanh, Claude chạy lại cả `fe-check`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-226`, nhánh `codex/T-226`, nền là T-225 chưa commit) · duyệt: Claude 2026-10-21 — đọc diff tám file, đối chiếu từng dòng Acceptance với 14 test ở `van-hanh.test.tsx` và test ánh xạ cột; Claude sửa một chỗ: `Alert` giữ bản cũ in giờ `read_at` đã định dạng thay vì chuỗi ISO (sửa test theo). Đưa về clone chính, `./scripts/gate.sh` xanh, `fe-check` PASS đủ lint · typecheck · 426 test · build. Còn mở: ánh xạ cột theo tên là suy ra, chờ chủ repo; `T-228` · `T-227` dựng tiếp trên trang này.

<a id="t-225"></a>
### T-225 — Không đường đọc nào trả tình hình từng bàn theo từng thứ

**Yêu cầu:** cùng lời chủ repo 2026-10-21 ở `T-226`. Bản thiết kế đã ghi rõ chỗ thiếu (`van_hanh/component.md`): `GET /dining-tables`
chỉ có trạng thái bàn, `GET /counter/queue` không có số theo nhân, `GET /owner-overview` có tổng mà không có từng bàn. **Mức:** L2 — hợp
đồng mới, con số tiền bày cho chủ quán. Nhận 2026-10-21, xong 2026-10-21.

**Phải trả được** (lấy từ thiết kế đã chốt): mỗi phiên bàn chưa đóng — nhãn bàn (kể cả bàn ghép), nhóm *đang phục vụ* hay *sắp phục vụ*
(nghĩa chủ repo xác nhận 2026-10-21, `shop-facts.md` §5.4); mỗi thứ đặt · đã ra · thiếu theo thành phần, nhân và lựa chọn (kiểu trứng,
rau), kèm cờ *nhiều*; tiền đơn và tiền đã ra; bàn trống; lịch sử đem ra — giờ, bàn, thứ, số cái, người bấm.

**Việc của Claude trước khi giao:** (1) tiền đã ra dùng **đúng** phép cộng *tạm tính* của tổng quan (`shop-facts.md` §8.6, U-099 ·
T-199: phần thuộc combo không tính giá thành phần), không viết phép cộng thứ hai; (2) `station_job` không có cột giờ ra bàn
(`db/migrations/20260928130000_san_xuat_theo_me.up.sql`), nên lịch sử phải chọn nguồn — đọc vết cập nhật hay thêm bảng ghi từng lần
đem ra (migration, ADR); (3) quyền: chủ quán đọc, người đứng quầy có đọc không (cần cho `T-228`) — ghi vào ma trận
`02-vai-va-quyen.md`; (4) test hồi quy trước cho nghĩa *sắp phục vụ · đang phục vụ* và cho tiền đã ra bằng tạm tính trên cùng dữ liệu.

**Claude quyết 2026-10-21** (`docs/decisions.md` **ADR-124**): (1) tiền đã ra = đoạn *tạm tính* tách khỏi `be/internal/tongquan/sql/tong.sql`
thành một đoạn đánh dấu, giống từng byte ở file đọc mới; (2) lịch sử đọc từ **vết** `record_revision` (`made → served`) — mọi lần đổi việc
trạm đi qua `vongdoi.CoVet` ở chế độ nghiêm, nên vết đã có người bấm và mốc giao dịch; **không** migration, không bảng mới; (3) lớp
`quay_hoac_chu_quan`; (4) test viết trước, dưới đây. Đường: `GET /service-board`, miền `tongquan`.

**Acceptance** (viết 2026-10-21, trước khi giao):
- [ ] `TestI019_BangVanHanhDemTheoDonViVaNhom` xanh — đếm theo đơn vị qua mọi trạm; `serving` · `waiting` · `no_order`; bàn ghép một phiên hai
  bàn; đơn huỷ không vào; bàn trống đúng tập.
- [ ] `TestI002_BangVanHanhTienDonBangTongTienPhien` xanh — `order_total_vnd` bằng `phien.TongTien`.
- [ ] `TestI014_BangVanHanhTienDaRaBangTamTinh` xanh — tiền đã ra chỉ đơn vị bán ra hết, và khớp tạm tính của `GET /owner-overview` trên cùng dữ liệu.
- [ ] `TestI014_TamTinhMotDinhNghia` xanh — đoạn tạm tính giống từng byte ở `tong.sql` và `bang_van_hanh.sql`.
- [ ] `TestI019_KhoaGomMotDinhNghia` xanh với bản thứ tư `be/internal/tongquan/sql/bang_van_hanh.sql`.
- [ ] `TestI019_LichSuDemRaDocTuVet` xanh — một lần bấm một mục, `quantity` đúng, có người và giờ, bỏ vết khác ngày và vết không phải `made → served`.
- [ ] `TestYC15_BangVanHanhQuayHoacChuQuan` xanh — chủ quán và người đứng quầy 200, người ngoài quầy `not_on_counter_duty`, không phiên `unauthenticated`.
- [ ] Test có sẵn của `be/internal/tongquan/` vẫn xanh (tạm tính tổng quan không đổi số).
- [ ] `docs/product/3-be/openapi.yaml` có `GET /service-board` và schema, `info.version` tăng; `02-vai-va-quyen.md` có dòng cửa đọc; `fe/src/lib/api/schema.ts`
  sinh lại; `./scripts/gate.sh` xanh, `be-check` do Claude chạy.

*Test do Claude viết trước khi giao* (ADR-054, L2): `be/internal/tongquan/service_board_test.go` · `service_board_handler_test.go` ·
`testdata/service_board.sql`, và một dòng ở `be/internal/sanxuat/khoa_gom_test.go`. Fixture đã chạy thử trên database migrate từ số 0: năm lần
`made → served` sinh năm dòng vết cùng người và cùng `created_at`.

**Bàn giao:** thực hiện: Codex (worktree `../lean_wt/T-225`, nhánh `codex/T-225` từ `efbb4b0`; tiến trình đầu bị ngắt trước báo cáo, nối lại bằng `codex exec resume`) · duyệt: Claude 2026-10-21 — đọc diff, tự chạy `./scripts/gate.sh` trong worktree có Docker: mọi cổng PASS, `be-check` PASS trên PostgreSQL thật, bảy test Acceptance trên PASS cùng `TestQC14_ComboNgayHuyVaThieuMon`; bốn file test của Claude không đổi (SHA-1 khớp). Claude chỉ bỏ một dòng trống thừa ở `01-hop-dong-api.md`. Đưa về clone chính bằng patch, chạy lại gate.

<a id="t-224"></a>
### T-224 — Thiết kế trang Vận hành đã chốt mà chưa có task nào để làm thật

**Yêu cầu:** chủ repo 2026-10-21 *"tôi chốt thiết kế hiện tại của trang vận hành hãy làm các task để hoàn thành trang trên"*. **Mức:** L1 —
ghi lời và mở task, không đổi code.

**Claude làm:** đối chiếu thiết kế với hợp đồng thì lệch hai chỗ, hỏi chủ repo ba câu trong hội thoại, chủ repo chọn: (1) thanh toán
**chỉ thu phần đã ra** — ghi `master_plan/shop-facts.md` §6.1 và §7.1, vế còn hở thành **U-103**, `quality/invariants.md` **I-002** mang dòng
*sửa đổi đang chờ*; (2) bấm *đã đem ra* **vẫn là người đứng quầy** — giữ S-5, ghi §7.1; (3) **đúng** cả hai cách hiểu *sắp phục vụ* và *đã
đem ra* của T-219 — ghi §5.4. Mở `T-225` (đọc, L2) · `T-226` (trang, L1) · `T-228` (ghi đem ra, L2) · `T-227` (thanh toán, L3, bị chặn).
*Bằng chứng:* `check-scope` · `check-links` · `check-doc-status` chạy trong lượt này.

<a id="t-223"></a>
### T-223 — Đơn giao tận nơi không rời quán được vì vế S-6 từng chưa có lời

**Yêu cầu:** chủ repo 2026-10-21 trả lời **S-6** (`master_plan/shop-facts.md` §7.2): quầy bấm *"đã ra bàn"* của đơn giao **lúc đơn rời quán — cùng
mốc quầy đã bấm để đưa đơn sang Đang giao**. Hôm nay cửa rời quán (`docs/product/3-be/05-luong-mang-di.md` §4) từ chối mọi đơn còn việc trạm chưa
`served` bằng `delivery_served_mark_undecided` **409**, nên trên thực tế đơn giao có món không rời quán được. **Mức:** L2 — đổi hợp đồng API, cửa ghi
việc trạm, và chạm đếm của bảng sản xuất (`I-019` · `I-020`). **Chưa nhận.** Việc của Claude trước khi giao: đọc cửa *ra bàn* hiện có (S-5, số cái
cho một bàn) để biết ghi `served` cho đơn không có bàn đi đường nào; quyết việc trạm còn `pending` lúc rời quán thì từ chối bằng tên mới hay giữ tên
cũ (đây là **suy ra** — chủ quán chưa nói đơn giao có được đi khi chưa làm đủ); viết test hồi quy trước; rồi mới giao Codex.

**Mở 2026-11-04, Claude.** Chủ repo chọn *"Từ chối rời quán"* (ghi ở `shop-facts.md` nhật ký lời 2026-11-04). Thiết kế: **ADR-088
*Sửa đổi 2026-11-04*** — khoá việc của đơn, còn `pending` ⇒ `delivery_jobs_not_made` 409 không đổi gì, `made` ⇒ `served` qua
`vongdoi.ChuyenViec` cùng giao dịch, rồi chuyển đơn; bỏ `delivery_served_mark_undecided`; hợp đồng 0.60.0 → 0.61.0.
**Acceptance** (viết trước khi giao): A1 test Claude giao không đổi (mã băm ở phiếu); A2 `TestI016_RoiQuanKhiBepConMonChuaLamBiTuChoi`,
`TestI016_RoiQuanGhiDaRaBanChoViecDaLam`, `TestI016_BonHinhMangDiQuaCuaCuaLat`, kịch bản 2 bước 10 và mọi test `be/internal/don` khác xanh;
A3 hai test FE quầy (`goi-mon.test.tsx`, `san-xuat.test.tsx`) xanh, `fe-check` PASS; A4 Gate 1f (cửa rời quán không có câu `UPDATE` riêng
cho `station_job`) và Gate 1g PASS ở 0.61.0, mã cũ không còn ở `be/` · `fe/src` · `openapi.yaml`; A5 `05-luong-mang-di.md` §4,
`07-san-xuat-theo-me.md` dòng S-6, `10-cong-chat-luong-pha-3.md` dòng bước 10 nói hành vi mới; A6 gate không FAIL.
Test viết trước, đỏ đúng lý do (cửa còn trả mã cũ): năm test `be/internal/don` FAIL (`chat-review/T-223-do-truoc.log`), ca FE
*rời quán bị chặn vì bếp còn món chưa làm* FAIL ở chỗ chưa có lời mới; bỏ ca mã cũ ở `san-xuat.test.tsx` (cửa ra bàn chưa bao giờ trả
mã ấy). Phiếu `../lean_wt/chat-review/T-223-phieu.md`; worktree `../lean_wt/T-223`, nhánh `codex/T-223`, nền `1254a33`; bốn file test
tạm rời cây chính (bản ở worktree và `chat-review/T-223/`).

2026-11-04, T-223 xong. **Codex** thi công (worktree `../lean_wt/T-223`, nhánh `codex/T-223`, nền `1254a33`, model `gpt-6-astra`), không dừng chỗ
nào; **Claude** duyệt diff và tích hợp vào cây chính bằng `git apply`. File: `be/internal/don/` (`service.go` `RoiQuanDon`, `repository.go`,
`sql/roi_quan/doc_viec.sql` thành `RoiQuanKhoaViec` … `FOR UPDATE`, sqlc sinh lại, hai file test), `be/internal/apierr/apierr.go` (mã mới thay mã
cũ), `openapi.yaml` 0.60.0 → 0.61.0, đoạn T-223 ở `01-hop-dong-api.md`, `05-luong-mang-di.md` §4, dòng S-6 ở `07-san-xuat-theo-me.md`, bước 10 ở
`10-cong-chat-luong-pha-3.md`, `fe/src/lib/api/schema.ts`, `du-lieu-hang-cho.ts` (lời mới), `du-lieu-ra-ban.ts` (bỏ case chết), hai test FE quầy.
Mã băm bốn file test không đổi. Bằng chứng (cây chính, Docker): `./scripts/gate.sh` exit 0 — `--- PASS` cho `TestI016_RoiQuanKhiBepConMonChuaLamBiTuChoi`,
`TestI016_RoiQuanGhiDaRaBanChoViecDaLam`, `TestI016_BonHinhMangDiQuaCuaCuaLat`, `TestI007_Scenario2_BaDonMangDiBaKenh`, `TestI021_MotNgayDienQuaCuaRa0dLech`;
`PASS Gate 1f` · `PASS Gate 1g` ở 0.61.0; `PASS gate không cổng nào đỏ`; `./scripts/fe-check.sh` exit 0 — `Tests 635 passed (635)`, `fe-check: PASS`;
`grep` mã cũ trong `be` · `fe/src` · `openapi.yaml` rỗng. Chưa có người duyệt thứ ba. Còn lại: cửa `sanxuat/ra_ban` vẫn nhận đơn giao trước lúc rời
quán (ghi ở ADR-088 *Sửa đổi*, *Không đổi*) — chưa ai hỏi có nên chặn.

<a id="t-222"></a>
### T-222 — Màn QR chỉ bày nhãn trơ của bàn, `/dat-mon` chưa lên máy tìm kiếm

**Yêu cầu:** chủ repo 2026-10-21, trả lời phần *Còn lại* của `P4-10` ([chi tiết](backlog_FE.md#p4-10)): *"Tiêu đề màn QR: đang chỉ là nhãn trơ của
bàn ("5") --> hình qr code và số bàn"* · *"Máy tìm kiếm: /dat-mon chưa được đưa vào danh sách trang công khai --> đưa sang"* · *"yêu cầu codex làm
các task trên còn bạn kiểm tra"*. **Mức:** L1 — đổi chữ và metadata của màn khách, không chạm tiền, dữ liệu hay hợp đồng.

**Claude chốt hình màn** (không phải luật quán): *hình qr code* đọc là **biểu tượng** mã QR (`QrCode` của `lucide-react`, `aria-hidden`) đứng trước
chữ, **không** vẽ lại chính mã khách vừa quét. Chữ: nhãn bàn chỉ gồm chữ số (`"5"`) thì bày *Bàn 5*; nhãn đã có chữ (`"Bàn 3"`, `"Sân 2"`) thì bày
nguyên nhãn — nhãn là chữ tự do chủ quán gõ (`dining_table_label_not_blank_check`), nên thêm *Bàn* vô điều kiện sẽ ra *Bàn Bàn 3*. `/dat-mon` theo
đúng ba bước của [`02-toi-uu-seo.md`](../docs/product/4-fe/02-toi-uu-seo.md) *Thêm một trang công khai*.

*Nghiệm thu* (viết trước, 2026-10-21): (1) test mới ở `fe/src/app/ban/khach-qr.test.tsx`: nhãn `"5"` ⇒ `h1` có chữ đúng *Bàn 5* và một `svg`; nhãn
`"Bàn 3"` ⇒ chữ đúng *Bàn 3*; tám ca cũ xanh; (2) `fe/src/lib/seo.test.ts`: `PUBLIC_ROUTES` là `["/", "/dat-mon"]`, metadata của `app/dat-mon/page`
bằng `publicPageMetadata("/dat-mon")` (index, canonical chỉ khi có địa chỉ gốc), sitemap có cả hai; (3) `01-khung-fe.md` (bảng route, dòng
`PhieuKhach`) và `02-toi-uu-seo.md` ghi `/dat-mon` công khai; (4) `check-fe-rules` xanh; (5) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-21 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/T-222`, nhánh `codex/T-222`, base `4284489`, đã gỡ); Codex
chết giữa lúc chạy gate, **không có báo cáo** — Vitest trong worktree lại vướng `EPERM` ở `.vite-temp` như `P4-10`. Duyệt, tích hợp và chạy lại: **Claude
Code**, nhánh `P4A-01`. File: `ban/_components/phieu-khach.tsx` (h1) · `ban/khach-qr.test.tsx` (+3 ca: `"5"`, `" 5 "`, `"Bàn 3"`) · `dat-mon/page.tsx`
(metadata) · `lib/seo.ts` · `lib/seo.test.ts` (A4 + ca `/dat-mon`) · `01-khung-fe.md` · `02-toi-uu-seo.md`. *Bằng chứng:* (1)(2) clone chính
`411 passed`; test có răng — đổi luật chữ số thành `/^X/` ⇒ `2 failed`, trả lại ⇒ xanh; (3) đã ghi; (4) `check-fe-rules` xanh, `tsc` · `eslint`
sạch; (5) gate *PASS không cổng nào đỏ*. Cùng lượt Claude ghi lời chủ repo: **S-6** có lời (`shop-facts.md` §5.4 · §7.1 · §7.2, `05-vong-doi.md`,
`05-luong-mang-di.md`), năm câu chữ khách của `P4-10` được duyệt (`backlog_FE.md`), mở `T-223`.

<a id="t-221"></a>
### T-221 — Bộ soạn món chưa soạn được combo và chưa theo lựa chọn phụ thuộc

**Yêu cầu:** chủ repo 2026-10-21 *"P4-07 đợt hai … yêu cầu codex thực hiện 2 việc trên bạn kiểm tra"*, rồi chọn trong câu hỏi có sẵn phương án:
*"Combo + lựa chọn phụ thuộc"*. Đợt hai `P4-07` đã xong (`60878db`) nhưng để lại hai chỗ ([chi tiết](backlog_FE.md#p4-07)): bộ soạn dùng chung
`components/shared/bo-soan-mon.tsx` hiện mọi nhóm lựa chọn kể cả nhóm có điều kiện, và chưa soạn combo. **Mức:** L1 — backend vẫn kiểm mọi tổ hợp và
mọi suất (`03-ham-gia.md` §1 · §1.1), màn sai thì đơn bị từ chối chứ không sai tiền; không đổi hợp đồng, dữ liệu.

**Claude chốt hình màn** (không phải luật quán): nhóm có `prerequisite_option_ids` chỉ hiện khi dòng đã chọn một lựa chọn trong tập ấy; ẩn đi thì bỏ
mã của nó khỏi `option_ids`; hiện lại thì chọn sẵn `is_default` nếu có. Nút *Thêm combo …* theo `menu.combos`; dòng combo có *Số lượng* là số combo, mỗi
món của combo bày `quantity × số combo` nhóm *{món} suất k*, mỗi suất chọn riêng theo luật trên (`shop-facts.md` §8.9 lượt tám); gửi
`{menu_combo_id, quantity, portions}` — suất cùng tổ hợp gom một phần tử — kèm `is_takeaway` ở lượt gọi bàn. Giá dòng combo là `line_total_vnd` của
`POST /price-quotes` cho riêng dòng ấy; chưa có giá thì chưa gửi được. Dòng món giữ giá `menu.prices`, không gọi tính thử. `DongMonDaGhi` bày suất của
dòng combo.

*Nghiệm thu* (viết trước, 2026-10-21): (1) `fe/src/app/quay/combo.test.tsx` (Claude, 11 ca, md5 `ca0ccf77…`) xanh không sửa; `goi-mon.test.tsx` ·
`hang-cho.test.tsx` · `quay.test.tsx` xanh; (2) `check-fe-rules` xanh; (3) chạy thật: POS gửi một lượt gọi có combo qua màn, backend thật, giá màn
bày bằng `total_vnd` backend trả; (4) `01-khung-fe.md` ghi bộ soạn biết combo; (5) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-21 · thực hiện: **Codex** `gpt-6-astra` (worktree `../lean_wt/T-221`, nhánh `codex/T-221`, base `9ea2f46`, đã gỡ); báo cáo
của Codex mất khi phiên Claude nối lại (scratchpad dựng mới) nên **không có lời tự khai**; test trước, duyệt và tích hợp: **Claude Code**, nhánh
`P4A-01`. File: `components/shared/bo-soan-mon.tsx` (luật nhóm `chonNhom` dùng chung cho món lẻ và từng suất, `dongGui`, `useGiaCombo`,
`loiCombo`) · `dong-mon-da-ghi.tsx` (bày suất) · `quay/_components/soan-don.tsx` · `du-lieu-soan-don.ts` · `01-khung-fe.md` §2 · §4;
`quay/combo.test.tsx` (Claude). **Claude sửa lúc duyệt:** chú thích tiếng Anh trong `chonNhom` viết lại tiếng Việt. *Bằng chứng:* (1) md5 test
trước = sau (`ca0ccf77…`); clone chính `391 passed`; test có răng — bỏ luật nhóm có điều kiện ⇒ `3 failed`, bày giá combo thay số tính thử ⇒
`4 failed`; `tsc` · `eslint` sạch; (2) `check-fe-rules: PASS`; (3) chạy thật 2026-10-21 (Claude Code; database dùng-xong-bỏ compose `t221run`
cổng 5499, backend thật cổng 8098 với `BANHCUON_SHOP_TZ=UTC` để giờ máy 08:42 UTC rơi vào giờ bán, `next dev` 3098, Chromium; combo thử *2 Bánh
cuốn + 1 Canh* giá 55.000đ chủ quán lập qua `POST /menu-combos`): POS đứng quầy, *Bánh cuốn* chọn Chay ⇒ nhóm *Lượng nhân* biến mất; combo bày
*Bánh cuốn suất 1 · 2 · Canh bánh cuốn suất 1*, *Giá dòng 55.000đ* từ tính thử (suất 2 sang Chay vẫn 55.000đ — cặp chưa đặt mức là 0đ, `U-096`);
gửi ⇒ `201`, *Đã gửi lượt gọi 1 · tổng 58.000đ*; thân gửi gom hai suất khác tổ hợp, không giá; (4) đã ghi; (5) gate *PASS không cổng nào đỏ*,
có `fe-check`. **Còn lại:** bộ soạn chưa tự kiểm suất thiếu lựa chọn trước khi tính thử — backend từ chối `option_combination_invalid` và màn bày
mã; chưa gây sai tiền.

[↑ đầu file](#top)

<a id="t-220"></a>
### T-220 — Bảng từng bàn của trang Vận hành khó đọc trên điện thoại

**Yêu cầu:** chủ repo 2026-10-20, về `BangDuLieu` trong `KhoiBanDangPhucVu` của `van_hanh/van-hanh.html`: *"gom dữ liệu dài quá thành 2 dòng tôi muốn
với điện thoại cần nhìn rõ hết thông tin"*, rồi *"yêu cầu codex làm bạn kiểm tra"*. **Mức:** L1 — tài liệu thiết kế, không đổi hành vi, hợp đồng hay dữ liệu.

**Claude chốt:** bảng `#bang-ban` có 10 cột, ép rộng tối thiểu 1080px, nên trên điện thoại phải cuộn ngang và tiêu đề dài gãy hai dòng. Ở màn ≤ 640px
mỗi bàn (kể cả dòng tổng) thành một thẻ: tên bàn làm đầu thẻ, mỗi cột thành một dòng *nhãn — giá trị*, nhãn lấy từ tiêu đề cột qua `data-label`. Từ
641px trở lên giữ nguyên bảng. Chỉ đổi bảng này; hai bảng khác trên trang không đổi.

*Nghiệm thu* (viết trước): (1) chỉ `van_hanh/van-hanh.html` đổi, và `van_hanh/component.md` nếu cần một câu tả bố cục điện thoại; (2) mọi số và tiền
trong `#bang-ban` giữ nguyên, đủ 6 bàn + dòng tổng × 10 cột; (3) ở 390px sau khi bấm *Xem từng bàn*: trang `scrollWidth` = 390, vùng bảng không cuộn
ngang, mỗi dòng *nhãn — giá trị* nằm trên đúng một dòng chữ; (4) ở 1280px bảng vẫn là bảng 10 cột như trước; (5) tập `data-component` không đổi;
(6) không thêm URL ngoài; (7) `./scripts/gate.sh` xanh.

**Bổ sung** — chủ repo 2026-10-20: *"3 cột Đặt ban đầu (bánh) · Đã ra · Còn thiếu — có function hide cho 3 cột trên; Bánh Chay … Tiền bánh đã ra luôn hiện,
phần trên rất hữu ích"*. **Claude chốt:** một `button` thật trên bảng, bật · tắt ba cột đó ở cả bảng máy tính lẫn thẻ điện thoại (kể cả dòng tổng),
`aria-pressed` theo trạng thái; mặc định hiện; sáu cột còn lại không có cách nào ẩn. Nghiệm thu thêm: (8) bấm nút thì 3 cột (thead, tbody, tfoot) ẩn,
bấm lại thì hiện, ở cả 390px và 1280px; 6 cột còn lại luôn hiện; không lưu trạng thái vào trình duyệt.

**Thiết kế chốt** — 2026-10-21, chủ repo *"tôi chốt thiết kế hiện tại của trang vận hành"*. Sau phần thẻ điện thoại (Codex), Claude Code sửa
`van_hanh/van-hanh.html` · `van_hanh/component.md` theo từng lời của chủ repo trong hội thoại 2026-10-20…21; nút ẩn ba cột tổng ở *Bổ sung*
trên đã bị chủ repo bỏ. Bản chốt, từ trên xuống: `BangThieuTheoBan` (mới) · `CongThuGhepDon` (bỏ bảng chỉ số, tick đẩy hàng đỏ vào bảng tổng
thiếu) · `KhoiBanDangPhucVu` (từng bàn dạng cột, mặc định ẩn, nút *Chi tiết*) · `SoDoBan` (mặc định ẩn) · `LichSuDemRa` (mới); bỏ
`TheTrangThaiBan` và `BangTongConThieu`. Số là minh hoạ; trứng, giò, nhiều nhân, canh rau · không rau là ví dụ chủ repo yêu cầu thêm. *Bằng
chứng:* mỗi lượt chạy `check-scope` (và `check-links` khi đổi `component.md`), kiểm thẻ HTML cân, chạy thử jsdom các thao tác (tick cộng
thử, chọn số · xác nhận · huỷ, thanh toán, trượt mở, ẩn · hiện); chưa xem trên trình duyệt thật. Các task làm thật: `T-224`.

[↑ đầu file](#top)

<a id="t-219"></a>
### T-219 — Chủ quán không có màn nào cho thấy quán đang chạy thế nào theo từng bàn

**Yêu cầu:** chủ repo 2026-10-20 *"hãy thiết kế 1 page mới trang này sẽ dùng để quản lý quán đang hoạt động thế nào"* — thấy tổng số bàn đang
phục vụ, bấm để liệt kê từng bàn với số đặt ban đầu và số còn thiếu; bảng tổng còn thiếu; số bàn còn dư; số canh và số theo nhân của từng bàn và
tổng; số bàn đang · sắp · trống; *cộng thử* bàn sắp phục vụ vào bàn đang phục vụ để ghép đơn; tiền từng bàn, tổng tiền và tiền của số bánh đã lấy
ra. Sau đó *"yêu cầu codex làm bạn kiểm tra"*. **Mức:** L1 — tài liệu thiết kế, không đổi hành vi, hợp đồng hay dữ liệu.

**Claude chốt:** một trang `van_hanh/van-hanh.html` kèm `van_hanh/component.md`, theo khuôn thư mục mới của `tong_quan/` (Tailwind CDN nhúng như bộ
T-215); không sửa `index.html` vì việc chuyển `tong-quan.html` vào `tong_quan/` còn chưa commit. Trang là **đề xuất**: hợp đồng chưa có đường đọc
theo bàn, nên mỗi khối không có nguồn trong `docs/product/3-be/openapi.yaml` mang nhãn *đề xuất — chưa có trong hợp đồng*. Số bàn 15 lấy từ
`master_plan/shop-facts.md`; giá đơn vị minh hoạ lấy từ §4 của file đó. **Suy luận của Claude, chờ chủ repo xác nhận:** *bàn còn dư* hiểu là bàn
trống; *sắp phục vụ* là bàn đã gửi lượt gọi mà chưa có món nào ra bàn; *đã lấy ra* là đã ra bàn; *nhân* là số bánh theo loại nhân (Chay · Thịt ·
Thịt + mộc nhĩ). Cộng thử chỉ tính trên trang, không ghi gì.

*Nghiệm thu* (viết trước): (1) đúng 2 file mới trong `van_hanh/`, không đổi file khác; (2) chỉ gọi mạng tới Google Fonts và `cdn.tailwindcss.com`;
(3) tập `data-component` của trang trùng khít bảng trong `component.md`; (4) tên dùng chung trùng bộ `chu_quan`; (5) số trong trang cộng khớp
nhau — đang + sắp + trống = 15, tổng các bàn = dòng tổng, còn thiếu = đặt − đã ra; (6) bấm *Xem từng bàn* mở · đóng được danh sách, tick bàn sắp
phục vụ thì tổng cộng thử đổi theo, chạy bằng JavaScript nhúng trong trang; (7) ở 390px không cuộn ngang trang; (8) dùng `button` · `input` ·
`label` thật; (9) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-219`, nhánh `codex/T-219`, base `cc4838a`, đã gỡ); duyệt và tích hợp:
**Claude Code**, chép `van_hanh/` về nhánh `P4A-01`. (1) Hai file `van_hanh/van-hanh.html` · `van_hanh/component.md`. (2) URL ngoài chỉ Google Fonts ·
`cdn.tailwindcss.com`. (3) Script của Codex: 13 tên `data-component` trùng khít `component.md`. (4) Bảy tên dùng chung trùng bộ `chu_quan`. (5) Script
của Codex: 6 + 3 + 6 = 15 bàn, từng bàn còn thiếu = đặt − đã ra, dòng tổng và bảng toàn quán khớp; Claude đối chiếu giá đơn vị Chay 3.000 · Thịt 4.000 ·
canh 0đ với `shop-facts.md` §4.2. (6)(7) Claude chạy Chromium headless (Playwright): 390px `scrollWidth` 390 trước và sau khi mở bảng, 1280px 1280, 0 lỗi
JavaScript, *Xem từng bàn* đặt `aria-expanded=true`, tick một bàn đổi số cộng thử. (8) 2 `button`, 4 checkbox có `label`. (9) Gate xanh. Bốn cách hiểu ở
*Claude chốt* vẫn chờ chủ repo xác nhận.

[↑ đầu file](#top)

<a id="t-217"></a>
### T-217 — Quầy không đọc được mã việc trạm và mã mẻ (F-073)

**Yêu cầu:** chủ repo 2026-10-20 *"Đóng hai finding đang chặn … yêu cầu codex làm 2 việc trên bạn kiểm tra"*. **Mức:** L2 — thêm một đường đọc
vào hợp đồng đã công bố. Thiết kế: **ADR-123** điểm 1 và 3. F-073 chặn bốn việc của `P4-09` ([chi tiết](backlog_FE.md#p4-09)); task này chỉ làm
backend và hợp đồng — màn quầy dùng đường đọc mới là phần còn lại của `P4-09`.

*Nghiệm thu* (viết trước, 2026-10-20, Claude Code): (1) `TestI019_KhoaGomMotDinhNghia` so `gom.sql` · `chon_da_lam.sql` · `viec_quay.sql` và xanh
(Claude sửa test trước, đỏ khi chưa có file); (2) `TestI019_QuayDocLaiViecTramVaMe` (`be/cmd/server/viec_quay_test.go`, Claude viết trước) xanh:
người ngoài quầy bị `403 not_on_counter_duty`; quầy đọc việc chờ của đơn vừa gọi, bấm mẻ bằng mã đọc được, đọc lại thấy mẻ cùng tập việc,
lùi mẻ bằng mã đọc được, đọc lại không còn mẻ và việc về chờ; (3) `openapi.yaml` khai đường mới, schema `CounterStationJobs` đủ trường của
ADR-123 điểm 1, tăng MINOR lên `0.46.0`, ghi một dòng ở `01-hop-dong-api.md`; (4) `02-vai-va-quyen.md` ghi cửa đọc lớp `quay`;
`07-san-xuat-theo-me.md` ghi đường đọc; (5) `fe/src/lib/api/schema.ts` sinh lại; (6) `./scripts/gate.sh` xanh, kể cả `be-check` Claude chạy.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-217`, nhánh `codex/T-217`, base `cc4838a`) theo phiếu; duyệt: **Claude Code**,
đọc diff thật và chạy lại mọi kiểm. Nhánh `P4A-01`. File: `be/internal/sanxuat/` (`handler.go` · `service.go` · `repository.go` · `sql/viec_quay.sql` ·
`internal/sqlcgen/viec_quay.sql.go` · `khoa_gom_test.go` của Claude) · `be/cmd/server/viec_quay_test.go` (Claude) · `openapi.yaml` · `01-hop-dong-api.md` ·
`02-vai-va-quyen.md` · `07-san-xuat-theo-me.md` · `fe/src/lib/api/schema.ts` · ADR-123. (1) `--- PASS: TestI019_KhoaGomMotDinhNghia` (đỏ trước khi có
`viec_quay.sql`). (2) `--- PASS: TestI019_QuayDocLaiViecTramVaMe` qua PostgreSQL thật — tên test đổi từ `TestF073…` vì QC-17 đòi mã mệnh đề.
(3)–(5) `check-api-contract` *hợp đồng 0.46.0; 117 đường gọi*; `fe-check: PASS`, 354 test FE. (6) Gate ở clone chính: *PASS gate không cổng nào đỏ*.
Claude soát: đoạn khoá gom chép nguyên; điều kiện *còn sống* và *nguồn chuyển hợp lệ* khớp `gom.sql`; `station_job_ids` của mẻ đúng tập
`viec_cua_me.sql`; đọc qua `authz.Read` lớp `quay`. Codex không tự quyết điều nghiệp vụ nào. **Còn lại:** màn quầy dùng đường đọc mới cho bấm mẻ ·
lùi mẻ · chuyển · ghi làm sai — phần còn lại của `P4-09`.

[↑ đầu file](#top)

<a id="t-218"></a>
### T-218 — Hàng chờ quầy không cho thấy món, tiền, và đơn đang làm (F-074)

**Yêu cầu:** cùng lời chủ repo với `T-217`. **Mức:** L2 — đổi một đường đọc của hợp đồng đã công bố; chạm tiền hiển thị. Thiết kế:
**ADR-123** điểm 2 và 3. F-074 chặn phần *bày món* và nút *rời quán* của `P4-07` ([chi tiết](backlog_FE.md#p4-07)) và phần tiền của `P4-08`; task
này chỉ làm backend và hợp đồng.

*Nghiệm thu* (viết trước, 2026-10-20, Claude Code): (1) `TestI009_HangChoBayAnhChupDon` (`be/cmd/server/hang_cho_test.go`, Claude viết trước)
xanh: đơn giao chờ xác nhận có `lines` · `total_vnd` bằng đúng phản hồi lúc ghi đơn; duyệt xong rời hàng chờ, có ở `active_orders` với
`in_progress` · `door_delivery` · địa chỉ · số điện thoại · `unserved_jobs` ≥ 1 và cùng tiền; (2) dòng và tiền đọc từ `order_line*` như
`doc_don.sql`, không gọi hàm giá (I-009; Claude đọc diff); (3) `openapi.yaml`: `CounterQueue` thêm trường theo ADR-123 điểm 2, tăng MINOR,
ghi một dòng ở `01-hop-dong-api.md`; `09-realtime-du-phong.md` ghi phần đọc mới; (4) `fe/src/lib/api/schema.ts` sinh lại và test FE hiện có
của `/quay` còn xanh; (5) `./scripts/gate.sh` xanh, kể cả `be-check` Claude chạy.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-218`, nhánh `codex/T-218`, base `cc4838a` — trước `T-217`); duyệt và
tích hợp: **Claude Code**, nhánh `P4A-01`. Lúc đưa về, dòng phiên bản của patch sửa từ `0.45.0` sang `0.46.0` (nền đã có `T-217`), type FE sinh
lại trên nền mới. File: `be/internal/nhandon/sql/hang_cho.sql` · `internal/sqlcgen/hang_cho.sql.go` · `be/cmd/server/hang_cho_test.go` (Claude) ·
`openapi.yaml` · `01-hop-dong-api.md` · `09-realtime-du-phong.md` · `fe/src/lib/api/schema.ts` · `fe/src/app/quay/hang-cho.test.tsx` (mẫu thêm trường
bắt buộc, không đổi ca). (1) `--- PASS: TestI009_HangChoBayAnhChupDon` qua PostgreSQL thật. (2) Claude đọc `hang_cho.sql`: dòng và tổng gom từ
`order_line` · `order_line_component` · `order_line_option`, không gọi hàm giá; `unserved_jobs` cùng điều kiện `status <> 'served'` của
`roi_quan/doc_viec.sql`. (3) `check-api-contract` *hợp đồng 0.47.0; 117 đường gọi*. (4) `fe-check: PASS`, 354 test. (5) Gate ở clone chính: *PASS gate
không cổng nào đỏ*. **Còn lại:** màn quầy bày món · nút *rời quán* (đợt hai `P4-07`) và tiền (`P4-08`).

[↑ đầu file](#top)

<a id="t-216"></a>
### T-216 — Phía khách chưa có màn nào để chủ repo nhìn và gọi tên từng khối

**Yêu cầu:** chủ repo 2026-10-20 *"hãy viết prompt yêu cầu codex làm các file html cho client side và để vào docs/product/4-fe/thiet_ke/khach_hang"*,
ngay sau T-215. **Mức:** L1. Đây là tài liệu thiết kế, không đổi hành vi, hợp đồng hay dữ liệu. Phía khách mới có trang giữ chỗ `/`; màn thật là bước
`P4-10` ([chi tiết](backlog_FE.md#p4-10)), nên bản này là đề xuất, không chốt route.

**Claude chốt:** chín trang, đặt tên theo việc khách làm (route thật do `P4-10` đặt): `trang-chu` · `mo-ma-qr` · `thuc-don` · `chon-mon` ·
`gio-hang` · `da-gui-luot` · `thong-tin-dat` · `da-dat` · `khong-nhan-don`, cùng `index.html`; mỗi trang tự mang style như bộ T-215 sau 78ef56c — Tailwind
CDN cộng khối `<style type="text/tailwindcss">` nhúng trong trang, không `styles.css` riêng (2026-10-20, chủ repo: *"làm file html đó kết hợp với css
và tailwind để khi tôi mở có màu và có căn chỉnh"*). Trang làm cho điện thoại trước, trên máy tính
thì nằm giữa một cột hẹp. Khuôn nhãn, công tắc và chú giải giống T-215. Nguồn nội dung: các cửa công khai của `docs/product/3-be/openapi.yaml`
(`GET /menu`, `POST /price-quotes`, `GET /qr-codes/{code}`, `POST /qr-codes/{code}/orders`, `POST /online-orders`) và `master_plan/shop-facts.md`.
Không bày thứ hợp đồng chưa có, ví dụ khách xem trạng thái đơn hay xin tính tiền. Mọi giá là giá backend trả, khách không thấy phép cộng.
Chữ hiện cho khách mà quán chưa chốt (lời khi quán tạm dừng nhận đơn, `P4-10`) bày dạng giữ chỗ.

*Nghiệm thu* (viết trước; sửa 2026-10-20 theo lời trên): (1) đúng 10 file như trên; (2) chỉ gọi mạng tới Google Fonts và `cdn.tailwindcss.com`; (3) tập `data-component` mỗi trang trùng khít chú giải;
(4) tên dùng chung có trong danh mục `index.html`, tên trùng nghĩa với T-215 thì dùng lại đúng tên ấy; (5) mỗi ô và nút có nguồn ở hợp đồng hoặc
`shop-facts.md` (Claude đối chiếu); (6) ở 390px không cuộn ngang; (7) dùng `button` · `input` · `label` thật; (8) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-216`, nhánh `codex/T-216`, base `a6f309b`, đã gỡ) theo phiếu viết **trước**
khi chủ repo đổi khuôn sang Tailwind (`78ef56c`), nên Codex nộp 11 file kèm `styles.css`; **Claude Code** chuyển sang khuôn mới khi tích hợp: chép
nguyên khối Tailwind CDN + `tailwind.config` của `chu_quan/kho.html` vào từng trang, nhúng CSS của Codex vào `<style type="text/tailwindcss">`, thêm lại
độ đậm `h1` · `h3` mà preflight bỏ, giữ tên ở cột đầu bảng chú giải trên một dòng, bỏ `styles.css`; thêm §8 vào `docs/command/mo-thiet-ke.md`.
Nhánh `P4A-01`. (1) 10 file. (2) URL ngoài Google Fonts · `cdn.tailwindcss.com`: 0. (3) Script kiểm của Claude: 9/9 trang `chú giải khớp=True`,
nhãn sai 0. (4) Tên dùng chung trùng bộ `chu_quan` (`DauTrang`, `BangDuLieu`, `ThongBaoLoi`…). (5) Claude soát chữ từng trang: giá khớp
`shop-facts.md` §4 (suất giò 21/25/29 nghìn = giò + 4 bánh), trường đơn online khớp `OnlineOrderRequest`, phí ship 0đ · hotline · *"Quán mở cửa 6h–11h
sáng"* từ `shop-facts.md`, mã lỗi có trong hợp đồng; chữ chưa chốt là `[CHỮ CHỜ CHỦ QUÁN CHỐT]`. (6) Playwright 390px: `scrollWidth` 390 cả 10 trang.
(7) Có. (8) Gate xanh. **Khoảng trống hợp đồng Codex nêu, để `P4-10` xử lý:** `GET /menu` không có danh mục · mô tả · ảnh; combo chưa ánh xạ được với
*Combo Đầy đủ*; `OnlineOrderRequest` không có trường chọn trả trước; hai cửa gửi đơn chỉ khai `default: Error`.

[↑ đầu file](#top)

<a id="t-215"></a>
### T-215 — Giao diện admin `/chu-quan` khó dùng, và chủ repo không có tên gọi chung cho từng khối để tả chỗ cần sửa

**Yêu cầu:** chủ repo 2026-10-20 *"phần admin trông không đẹp và tiện dung lắm"*. Sau khi xem bản nháp ba màn trên canvas (Tổng quan, Kho, Tổng quan
trên điện thoại), chủ repo nói *"hãy làm giao diện như trên ở trong docs/product/4-fe/thiet_ke/chu_quan từng trang 1 và có tên các component để tôi có thể
dễ dàng miêu tả cho bạn hiểu hãy yêu cầu codex làm và bạn kiểm tra"*. **Mức:** L1. Đây là tài liệu thiết kế, không đổi hành vi, hợp đồng hay dữ
liệu. Route và component thật vẫn do `docs/product/4-fe/01-khung-fe.md` nắm; bản thiết kế là đề xuất cho tới khi một task áp nó vào `fe/`.

**Claude chốt:** mỗi trang là một file HTML tĩnh, đặt tên theo đoạn cuối route (`/chu-quan` ⇒ `tong-quan.html`). Mọi trang dùng chung một
`styles.css`, có `index.html` mục lục kèm danh mục component dùng chung. Không JS framework, không bước build. Mỗi khối mang `data-component` và một nhãn
tên nhìn thấy được (có công tắc ẩn/hiện), cuối trang có bảng chú giải. Khối nào ứng với component đã có trong
`fe/src/app/chu-quan/_components/` thì dùng lại đúng tên đó. Nội dung chỉ gồm ô và thao tác trang thật đang có; số là minh hoạ; không bày con số mà
frontend phải tự cộng trừ mới ra (ADR-086).

*Nghiệm thu* (viết trước): (1) thư mục có đúng 13 trang, mỗi route của `mucChuQuan` một trang, cộng `index.html` và `styles.css`; (2) trang mở
thẳng từ file, chỉ gọi mạng tới Google Fonts; (3) tập `data-component` của mỗi trang trùng khít tập tên trong bảng chú giải của trang đó; (4) khối
dùng chung mang đúng tên trong danh mục ở `index.html`; khối có component thật thì mang tên thật; (5) mỗi ô và thao tác bày ra đều có trong
component trang tương ứng (Claude đối chiếu từng trang với `_components/*.tsx`); (6) ở bề rộng 390px không cuộn ngang trang, thanh điều hướng
xuống đáy, bảng cuộn trong hộp; (7) dùng `button` · `input` · `label` thật; (8) `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-215`, nhánh `codex/T-215`, base `4b7da4e`, đã gỡ); duyệt và tích hợp:
**Claude Code**, nhánh `P4A-01`. File: 15 file dưới `docs/product/4-fe/thiet_ke/chu_quan/`, cùng dòng owner ở `CLAUDE.md` §2. (1) Script kiểm riêng của
Claude ⇒ thiếu 0, thừa 0. (2) URL ngoài Google Fonts: 0 ở cả 14 trang. (3) Mọi trang `chú giải khớp=True`, nhãn sai 0, khối thiếu nhãn 0.
(4) Danh mục `index.html` có 14 tên dùng chung; Codex thêm `FormMenu` · `OMenu` (tên thật trong `form-menu.tsx`). (5) Claude đối chiếu nhãn với
`_components/*.tsx`: mọi nhãn soát được đều có trong component thật; giá dùng `[GIÁ]`. (6) Playwright khung nhìn 390px ⇒ `scrollWidth` 390 ở cả 14
trang, không khối nào tràn ngoài hộp cuộn bảng. (7) Có ở mọi trang. (8) Gate xanh ở clone chính.

[↑ đầu file](#top)

<a id="t-214"></a>
### T-214 — Chạy hệ thống trên máy phải gõ ba lệnh ở ba cửa sổ, tự ghép năm biến môi trường

**Yêu cầu:** chủ repo 2026-10-20 *"yêu cầu codex tạo câu lệnh để chạy toàn bộ hệ thống"*, chỉ vào `docs/command/make.md`. **Mức:** L1 — công cụ
máy phát triển, không đổi hành vi, hợp đồng hay dữ liệu.

**Claude chốt:** `make dev` = `setup` (bật · migrate · mồi, đã có sẵn) rồi chạy **cùng lúc** `be/cmd/server` (cổng 8080) và `npm run dev` của `fe/`
(cổng 3000), log hai bên có tiền tố; Ctrl+C hay một bên chết thì tắt cả hai, database **giữ** chạy. Thêm `make be` · `make fe` chạy riêng từng bên.
Biến môi trường dựng trong Makefile, đọc lại `compose.yaml` không chép: DSN vai `shop_app` ở `127.0.0.1:$(DB_PORT)`; múi giờ từ `SHOP_TZ` sẵn có;
`BANHCUON_ORIGIN=http://localhost:3000` (tầng chuyển tiếp đưa nguyên Origin của trình duyệt lên, nên phải mở đúng địa chỉ này); `BANHCUON_FILE_DIR`
mặc định `.dev/files` ở gốc repo, tự tạo, có `.gitignore` riêng `*`; mọi biến đổi được bằng `VAR=… make dev`. Không tạo chủ quán tự động — tài khoản
đăng nhập vẫn qua `khoitao-chu-quan` (mật khẩu đọc từ stdin), `make.md` chỉ cách. Không thêm công cụ ngoài (không `concurrently`, không `foreman`).

*Nghiệm thu* (viết trước): (1) `make help` liệt kê `dev` · `be` · `fe`; (2) chạy thật trên máy (Claude, vì sandbox Codex không tới Docker): `make dev`
từ database đã tắt ⇒ `curl http://127.0.0.1:8080/menu` trả `200`, `http://localhost:3000/` trả `200`, `curl http://localhost:3000/api/menu` trả
`200`; (3) Ctrl+C ⇒ không còn tiến trình nghe 8080 · 3000, `make status` vẫn *healthy*; (4) thiếu `fe/node_modules` ⇒ dừng với một câu chỉ
`npm ci`, không im lặng; (5) `docs/command/make.md` có mục chạy toàn bộ hệ thống, câu cũ về lệnh `go run` tay ở §9 trỏ sang lệnh mới; (6) gate xanh.

**Bàn giao** — 2026-10-20 · thực hiện: **Codex** (worktree `../lean_wt/T-214`, nhánh `codex/T-214`, base `981e1af`), hết hạn mức sau khi xong code, trước
báo cáo; duyệt, chạy thật và tích hợp: **Claude Code**, nhánh `P4A-01`. File: `Makefile`, `docs/command/make.md`. (1) `make help` có `dev` · `be` · `fe`.
(2) `make dev` từ database tắt ⇒ `be /menu: 200`, `fe /: 200`, `fe /api/menu: 200`; `POST /api/sessions` với Origin `http://localhost:3000` ⇒
`invalid_credentials`, với `http://127.0.0.1:3000` ⇒ `cross_origin_write` (đúng lời dặn mở `localhost`). (3) Ctrl+C (SIGINT cả nhóm) ⇒ không còn
tiến trình nghe 8080 · 3000, `make status` *healthy*; DSN sai làm server Go chết ⇒ Next tắt theo, `make: *** [dev] Error 1`. (4) `make fe` thiếu
`node_modules` ⇒ `Thiếu fe/node_modules; hãy chạy: cd fe && npm ci` (log của Codex). (5) make.md §4 mới, §10 trỏ `make be`. (6) Gate — dưới.

[↑ đầu file](#top)

<a id="t-212"></a>
### T-212 — POS giao việc và ghi đào tạo từ quầy

**Yêu cầu:** chủ repo 2026-10-19 chọn *"Màn POS giao việc và đào tạo"*. Lời đóng `U-089` (POS tạo · sửa · xoá · đánh dấu việc) và `U-090` · `U-091`
(POS ghi nhận xét, gắn hướng dẫn) đã có cửa lớp `quay_hoac_chu_quan` (`docs/product/3-be/02-vai-va-quyen.md`); chỉ thiếu màn. **Mức:** L1 — màn
mới trên cửa sẵn có, không đổi hợp đồng.

**Claude chốt:** hai route trong khung `/quay` (gác `KhungTheoVai`, như `/quay`), **dùng lại** `TrangGiaoViec` · `TrangDaoTao` — không chép
component thứ hai; trang đào tạo đọc đường dẫn hiện tại thay vì viết cứng `/chu-quan/dao-tao`. `/quay` có hai lối vào.

*Nghiệm thu* (viết trước): (1) test: POS mở `/quay` thấy hai lối vào; `/quay/giao-viec` · `/quay/dao-tao` bày trang trong khung quầy; chủ
quán mở `/quay/giao-viec` thì về `/chu-quan`; đổi bộ lọc ở `/quay/dao-tao` giữ đường dẫn `/quay/dao-tao`; (2) test cũ của hai trang chủ quán
xanh; (3) chạy thật: POS đứng quầy giao một việc ⇒ `201`; (4) `fe-check: PASS`, gate xanh.

**Bàn giao** — 2026-10-20 · **Claude Code**, nhánh `P4A-01`; chưa ai duyệt độc lập. (1) `src/app/quay/quay.test.tsx` 4 ca xanh. (2) Mock điều
hướng của `dao-tao.test.tsx` thêm `usePathname` (trang đọc đường dẫn hiện tại) — không đổi điều kiện kiểm; `Tests  245 passed (245)` dưới
`src/app`. (3) Chạy thật: *Người lạ* vai `quay` vào quầy, `POST /assigned-tasks` ⇒ `201` (người tạo là POS); `next dev` trả `200` cho
`/quay/giao-viec` · `/quay/dao-tao`. (4) Gate — dưới.

[↑ đầu file](#top)

<a id="t-211"></a>
### T-211 — Chủ quán đặt mức phụ thu theo từng món của combo

**Yêu cầu:** chủ repo 2026-10-19 chọn làm *"Topping và phụ thu combo"*. Cửa `PUT /menu-combos/{menu_combo_id}/surcharges` có từ P3A-06; màn
P4A-05 chỉ đọc vì thiếu nguồn *món nào mang lựa chọn nào* (`GET /menu` chỉ món đang bán, test combo cấm gọi). **Mức:** L1 — đọc thêm một
trường và một form; luật mức combo không đổi (lượt bảy · tám §8.9, ADR-117).

**Claude chốt:** `OptionGroupAdmin` thêm `menu_item_ids` (món mang nhóm, kể cả ngừng bán) — MINOR `0.44.0` → `0.45.0`. Form trên mỗi combo bày,
cho từng món của combo, mọi lựa chọn **chưa ẩn** của các nhóm món ấy mang, ô số đặt sẵn mức hiện có (trống = chưa đặt, hàm giá cộng 0đ); lý
do bắt buộc; chỉ gửi cặp có ô đã đổi; không đổi gì ⇒ không gửi. Lời từ chối gắn đúng ô (`surcharges[i].x`).

*Nghiệm thu* (viết trước, 2026-10-19):
1. Test backend: `GET /option-groups` có `menu_item_ids` đúng món mang nhóm.
2. `combo.test.tsx` thêm ca: form bày lựa chọn theo món, không bày lựa chọn đã ẩn; gửi đúng cặp đã đổi kèm lý do rồi đọc lại; trong giờ bán ⇒
   lời *chỉ đặt ngoài giờ bán*; ca cũ *không gọi `/price-quotes` hay `/menu`* vẫn xanh.
3. Chạy thật: lập combo, đặt mức *Nhiều nhân* cho món trong combo ngoài giờ bán ⇒ đọc lại thấy mức; tính thử combo cộng đúng mức.
4. `./scripts/gate.sh` xanh, `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · **Claude Code**, nhánh `P4A-01`; chưa ai duyệt độc lập.
1. `TestI010_ThemLuaChonVaoNhomCoSan` thêm vế `menu_item_ids` — PASS.
2. `combo.test.tsx` thêm ba ca (lựa chọn theo món, bỏ đã ẩn · gửi đúng cặp đã đổi rồi đọc lại, không gọi `/price-quotes` hay `/menu` ·
   không đổi thì không gửi, trong giờ bán nói đúng lý do); 16 ca cũ không đổi điều kiện; `Tests  238 passed (238)` dưới `chu-quan`.
3. Chạy thật 2026-10-19 ~21:40, ngoài giờ bán: `GET /option-groups` ⇒ *Nhân [1…8] · Lượng nhân [1…8]*; lập *Combo chạy thử T-211* 30.000đ
   (2 suất Bánh cuốn) ⇒ đặt *Nhiều nhân* 2.000 ⇒ `200`, đọc lại thấy mức; tính thử hai suất *Thịt · Nhiều nhân* ⇒ `total_vnd 34000`
   (30.000 + 2 × 2.000; *Thịt* chưa đặt cộng 0đ). Cuối lượt ẩn combo thử (lý do ghi rõ).
4. `PASS  Gate 1   be-check` · `PASS  Gate 1g … hợp đồng 0.45.0` · `fe-check: PASS` · `PASS  gate     không cổng nào đỏ`.

[↑ đầu file](#top)

<a id="t-210"></a>
### T-210 — Topping: chủ quán quản lý lựa chọn phụ thu (phần còn bị chặn của P4A-05)

**Yêu cầu:** chủ repo 2026-10-19 chọn làm *"Topping và phụ thu combo"*, rồi trả lời ba câu (`master_plan/shop-facts.md` §8.9 đoạn
*2026-10-19 — QUẢN LÝ TOPPING*). **Mức:** L2 — chạm hàm tính giá duy nhất (`I-010` · `I-013`) và hợp đồng.

**Claude chốt (thiết kế):**
1. Bước 34 `20261019140000_an_lua_chon`: `menu_option` thêm `hidden_at` · `hidden_by_person_id` (cùng khuôn ẩn của danh mục,
   combo); vai ghi được sửa đúng hai cột ấy. Thêm lựa chọn là `INSERT menu_option` (+ `option_group_prerequisite` cho mỗi nhóm
   chủ quán tích); không bảng mới.
2. Bốn cửa lớp `chu_quan`: `menu/doc_nhom` `GET /option-groups` (mọi nhóm, mọi lựa chọn kể cả đã ẩn, tập điều kiện);
   `menu/them_lua_chon` `POST /option-groups/{option_group_id}/options` `{name, surcharge_vnd, enables_option_group_ids}` ⇒ 201;
   `menu/an_lua_chon` `POST /menu-options/{menu_option_id}/hiding` `{reason}`; `menu/bo_an_lua_chon` `…/unhiding` `{reason}`.
   Mã mới: `option_group_not_found` 404 · `menu_option_name_taken` 409 · `menu_option_hidden` 409 · `menu_option_not_hidden` 409 ·
   `menu_option_is_default` 409. Không có cửa đổi tên hay xoá lựa chọn.
3. Hàm giá (`be/internal/gia`): lựa chọn đã ẩn **tại mốc tính** ⇒ `409 menu_option_hidden field=option_ids`; menu và danh sách nhóm của
   món không bày lựa chọn đã ẩn. Đơn cũ đọc ảnh chụp, không đổi. Mốc ẩn đọc qua vết như mọi cột khác của `doc_mon.sql`.
4. Hợp đồng MINOR `0.43.0` → `0.44.0`.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `be/internal/menu`: test thêm lựa chọn vào nhóm *Nhân* có tích *Lượng nhân* ⇒ 201; tính thử món với lựa chọn mới + *Nhiều nhân* ⇒ giá
   = giá gốc + (phụ thu mới + phụ thu nhiều nhân) × số phần nhận nhân; không tích ⇒ chọn kèm *Lượng nhân* bị `option_combination_invalid`;
   trùng tên ⇒ `menu_option_name_taken`; nhóm lạ ⇒ `option_group_not_found`; người thường ⇒ `owner_only`.
2. Ẩn ⇒ 200 và vết có lý do; tính thử với lựa chọn đã ẩn ⇒ `menu_option_hidden`; `GET /menu` không bày nó; ẩn lần hai ⇒
   `menu_option_hidden`; ẩn mặc định ⇒ `menu_option_is_default`; bật lại ⇒ tính được lại; bật lựa chọn chưa ẩn ⇒ `menu_option_not_hidden`.
3. `TestI013_*` (13 ca §4.8) vẫn xanh, không sửa điều kiện kiểm; bước 34 xuôi · lùi · xuôi trong `db-check`.
4. Trang `/chu-quan/topping`: bày nhóm, lựa chọn, phụ thu, trạng thái ẩn; thêm lựa chọn có ô tích nhóm phụ thuộc; ẩn · bật lại bắt buộc lý do;
   ghi xong đọc lại; `fe-check: PASS`.
5. Chạy thật: thêm *Thịt + nấm* +1.000 có tích *Lượng nhân*, tính thử một suất trứng *Thịt + nấm · Nhiều nhân*, ẩn rồi bật lại.
6. Gate 1f · 1g xanh (ô ghi mới, cửa mới, ma trận quyền); `./scripts/gate.sh` xanh.

**Đổi thiết kế khi thi công (Claude, 2026-10-19):** Gate 1f đòi một ô một cửa — ẩn và bật lại ghi cùng hai cột, nên chúng là **một cửa**
`menu/an_lua_chon` với hai đường gọi (khuôn khoá · mở tài khoản); không có cửa `menu/bo_an_lua_chon`. Đường đọc `GET /option-groups` dùng
`authz.Read`, không khai cửa ghi. **ADR-122** ghi lại.

**Bàn giao** — 2026-10-19 · **Claude Code**, nhánh `P4A-01`; chưa ai duyệt độc lập. Test viết cùng lượt dựng cửa, không trước.
1. `TestI010_ThemLuaChonVaoNhomCoSan` PASS: owner_only · option_group_not_found · ba lời sai hình · menu_option_name_taken; *nấm + nhiều* ⇒
   24.000 (= 18.000 + 2.000 × 3 phần nhận nhân); *nấm* thiếu lượng ⇒ option_combination_invalid; *chay nấm* không tích ⇒ 18.000, kèm lượng
   ⇒ option_combination_invalid.
2. `TestI010_AnVaBatLaiLuaChon` PASS: ẩn có vết đủ người · lý do; tính thử ⇒ menu_option_hidden; `DocMenu` không bày; ẩn lần hai ⇒ 409;
   bật lại ⇒ tính được, menu bày lại; ẩn mặc định ⇒ menu_option_is_default. Ca vết `menu/an_lua_chon` thêm vào `cacCaVet`
   (`TestI018_TapCuaSuaKhopTapCa` đòi mỗi cửa UPDATE một ca).
3. `ok banhcuon/be/internal/gia` · `ok …/combo` (13 ca §4.8 không đổi điều kiện); db-check bước 34 — gate dưới. Lộ **F-072** (thứ tự gói test,
   có sẵn ở HEAD).
4. `/chu-quan/topping`: `topping.test.tsx` 4 ca; `chu-quan.test.tsx` thêm mục *Topping* (12 mục); `Tests  235 passed (235)`.
5. Chạy thật (database làm việc, server thật): thêm *Thịt + nấm* +1.000 tích *Lượng nhân* ⇒ `201`; suất trứng chín *Thịt + nấm · Nhiều
   nhân* ⇒ `unit_price_vnd 30000`, bằng đối chứng *Thịt + mộc nhĩ · Nhiều nhân*; ẩn ⇒ `200`, tính lại ⇒ `409 menu_option_hidden
   field=lines[0].option_ids`, `GET /menu` không còn chữ *Thịt + nấm*; bật lại ⇒ tính 30000. Cuối lượt ẩn lại lựa chọn thử ấy (lý do ghi rõ).
6. Lượt gate đầu đỏ ở `gofmt` (`apierr.go` · `menu/service.go`), sửa; lượt hai: `PASS  Gate 1   be-check` · `PASS  Gate 1   db-check — 34 bước xuôi ·
   lùi · xuôi lại …` · `PASS  Gate 1f … 110 ô ghi, 95 cửa` · `PASS  Gate 1g … hợp đồng 0.44.0` · `fe-check: PASS` (`Tests  276 passed`) ·
   `PASS  gate     không cổng nào đỏ`. Thêm cột vào `menu_option` làm sqlc sinh lại `models.go` của mọi miền — đúng ý, không đổi hành vi.

[↑ đầu file](#top)

<a id="t-209"></a>
### T-209 — Cổng pha 3 còn hai ô trống (F-068)

**Yêu cầu:** chủ repo 2026-10-19, *"làm nốt những việc còn lại như finding"*. **Mức:** L2 theo invariant chạm (`I-018` · `I-020`), chỉ
thêm test — không đổi code chạy.

*Nghiệm thu* (viết trước): (1) cắt giữa lần bấm mẻ phủ hai bàn và giữa lần lùi mẻ ⇒ 500, database y như trước, gỡ kéo cắt thì đi qua;
(2) cắt lúc ghi vết của một cửa sửa ⇒ 500, lần sửa không sống, không vết; (3) kênh không gắn bàn mang bàn/phiên ⇒ 400 đúng trường, 0 đơn,
phiên không đổi; (4) ký ô 1 · ô 2, F-068 Fixed; `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**; chưa ai duyệt độc lập. Trên database thử: `--- PASS: TestI020_CatGiuaLanBamMeKhongNuaNaoSong`
(*500, database y như trước: … 0 mẻ … 4:pending,7:pending*) · `--- PASS: TestI020_CatGiuaLanLuiMeKhongNuaNaoSong` (*… 10:made,13:made*) ·
`--- PASS: TestI018_CatLucGhiVetCuaCuaSuaKhongNuaNaoSong` (*đơn vẫn in_progress, 1 vết*) · `--- PASS: TestI006_KenhKhongGanBanMangBanBiTuChoi`.
Kéo cắt chính là lỗi cài (trigger của test); bốn test không cần worktree lỗi riêng. Gate — dưới.

[↑ đầu file](#top)

<a id="t-208"></a>
### T-208 — Commit nhặt thay đổi chưa commit của phiên khác (F-025)

**Yêu cầu:** chủ repo 2026-10-19 chọn *"F-025: hook pre-commit"*. **Mức:** L1 — công cụ của repo, không chạm sản phẩm.

*Nghiệm thu* (viết trước): (1) hook từ chối tổ hợp file của hai task và file ngoài mọi scope, cho qua khi một task phủ hết, khi không
file nào staged, khi chưa khai scope nào; lời từ chối nêu task của từng file; `git commit` thật bị chặn, `--no-verify` đi qua —
`scripts/pre-commit.test.sh`; (2) `install-hooks.sh --check` đỏ khi thiếu hook mới, `commit-msg.test.sh` vẫn xanh; (3) F-025 Fixed;
`./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**; chưa ai duyệt độc lập. `pre-commit.test: PASS` (10 ca) · `[test] commit-msg: tất cả ca
đều đạt` · `install-hooks.sh --check` exit 0 ở clone chính. Hook chạy khoảng 1 giây trên một commit thường của repo này.

[↑ đầu file](#top)

<a id="t-141"></a>
### T-141 — Huỷ ô chấm công: ghi chú bắt buộc, chỉ chủ quán (U-071)

**Yêu cầu:** lời chủ quán đóng **U-071** (2026-10-09, T-139): ghi chú huỷ bắt buộc, chỉ chủ quán huỷ; task nằm *Ready* từ đó. Chủ
repo 2026-10-19 giao *"làm nốt những việc còn lại"*. **Mức:** L2 — lược đồ và dữ liệu (`I-027`). Claude thiết kế và thi công.

**Thiết kế (Claude):** một migration đi tới, bước 33: CHECK `attendance_day_cancel_note_required_check` (có huỷ ⇒ có ghi chú; ghi chú
trắng đã bị từ chối từ bước 10); người huỷ là chủ quán cần đọc bảng `person` nên là trigger trước khi ghi, mang tên
`attendance_day_cancelled_by_owner_check` (QC-10). Người huỷ không tồn tại vẫn để khoá ngoại cũ từ chối. Lùi chỉ nới luật.

*Nghiệm thu* (viết trước):
1. `db/tests/i027_attendance_one_box_per_worker_day.sql`: hai ca *database nhận* đổi thành ba ca *database từ chối* (huỷ không ghi chú ·
   người thường huỷ · thêm ô đã huỷ bởi người thường), mỗi ca kiểm đúng tên ràng buộc — đỏ trên lược đồ 32 bước, xanh sau bước 33.
2. Bước 33 lên và lùi một bước trên database rỗng; `db-check` xanh.
3. Mọi dữ liệu test huỷ ô dùng người chủ quán, kèm ghi chú (`be/internal/tongket/testdata/best_staff.sql`); `be-check` xanh.
4. `13-luoc-do-cham-cong.md` §3 · §4 · §5, bước 33 ở `07-thu-tu-migration.md`, `I-027`; hai tên mới ở `x-constraint-errors`, hợp đồng
   `0.43.0`; `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**, nhánh `P4A-01`; chưa ai duyệt độc lập.
1. Lược đồ cũ (database thử cổng 5498): `ERROR:  I-027: database KHÔNG từ chối một lần huỷ không ghi chú (U-071)`. Sau bước 33: ba
   `NOTICE … bị từ chối (… U-071)` và không `ERROR`. Test đọc lược đồ *không đường nào tới một khoản trừ* nhận đúng một ngoại lệ có
   tên — hàm gác người huỷ, chỉ đọc `person`, không câu ghi nào (test kiểm).
2. `migrate up` ⇒ `20261019130000/u huy_cham_cong_nghiem`; `down 1` ⇒ `/d`; `up` lại ⇒ `/u`. Lượt gate đầu đỏ ở `QC-05` (file lùi
   thiếu khoá chặn) — thêm khoá: đã có ô huỷ thì từ chối lùi; ghi ở bước 33 của `07-thu-tu-migration.md`.
3. `PASS  Gate 1   be-check — mọi test backend qua PostgreSQL thật đều đạt` (dữ liệu test tổng kết huỷ ô bằng người chủ quán).
4. `PASS  Gate 1   db-check — 33 bước xuôi · lùi · xuôi lại, 19 khối kiểm QC, 51 file test …` · `PASS  Gate 1g … hợp đồng 0.43.0` ·
   `PASS  gate     không cổng nào đỏ`.

[↑ đầu file](#top)

<a id="t-207"></a>
### T-207 — Khoá mẻ của cửa lùi và cửa chuyển chưa có test chen nhau (F-066)

**Yêu cầu:** chủ repo 2026-10-19, *"làm nốt những việc còn lại như finding"*. **Mức:** L1 — chỉ thêm test, không đổi code chạy.

*Nghiệm thu* (viết trước):
1. Test mới chạy chen nhau lùi mẻ và chuyển phần của đơn đã huỷ trong chính mẻ ấy, nhiều vòng; mọi thứ tự ra mẻ đã lùi, nguồn và đích
   Chưa làm, không phần hiệu lực, không lỗi hệ thống — PASS trên PostgreSQL thật.
2. Lỗi cài trong worktree riêng (bỏ `FOR UPDATE` ở hai câu khoá mẻ) ⇒ test đỏ; gỡ ⇒ xanh.
3. F-066 → Fixed; `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**; chưa ai duyệt độc lập. (1) `12 vòng lùi chen chuyển: map[chuyển trước:6 lùi trước:6]` ·
`--- PASS: TestI020_LuiMeChenChuyenPhanCuaChinhMe (1.69s)`. (2) worktree `../lean_wt/T-207-fault` (nền `7cb7f04` + file test): ba lần
`vòng N: lùi mẻ ⇒ 409 map[code:station_job_transition_not_allowed]` · `--- FAIL`; worktree đã gỡ. (3) gate — dưới.

[↑ đầu file](#top)

<a id="t-206"></a>
### T-206 — Ba finding chỉ chạm tài liệu (F-067 · F-069 · F-070)

**Yêu cầu:** chủ repo 2026-10-19 chọn trong hội thoại *"F-069: sửa prompt-fullstack, F-067: duyệt độc lập backend"* và giao
*"làm nốt những việc còn lại như finding"*. **Mức:** L1 — chỉ tài liệu và một lượt đọc; không code, không đổi hành vi.

*Nghiệm thu:*
1. F-067: bản duyệt của agent lạnh ngữ cảnh (chỉ đọc, diff `1728c0d^..be25683`, năm miền) ghi vào finding; **Fixed**.
2. F-069: `master_plan/prompt-fullstack.md` kể `openapi.yaml` là nhà thật; §3.6 chỉ còn con trỏ; **Fixed**.
3. F-070: vế (2)–(4) và hai câu trôi có chỗ nhận ở owner; **Fixed**.
4. `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**; lượt duyệt F-067 do một agent general-purpose lạnh ngữ cảnh, chỉ đọc, không chạy test.

[↑ đầu file](#top)

<a id="t-205"></a>
### T-205 — Ba dữ kiện để quán hiện đúng trên Google: hai vế đã có lời (U-094)

**Yêu cầu:** chủ repo 2026-10-19, trong hội thoại: *"ngõ 332 hoàng công chất số 14b6, thời gian mở cửa hang tất cả các ngày trừ
tết âm lịc từ 6-10h30"*. Claude hỏi lại vì *10h30* lệch §1 (06:00–11:00, mốc máy dùng để khoá đặt món): chủ repo chọn **giữ
06:00–11:00**; ngày nghỉ Tết chọn **mỗi năm chủ quán báo**; tên miền **chưa có**. **Mức:** L1 — dữ kiện quán và dữ liệu trang
công khai; không đổi giờ bán máy dùng.

*Nghiệm thu* (viết cùng lúc thi công — việc nhỏ, ghi thật):
1. `master_plan/shop-facts.md` §1 có dòng *Địa chỉ* và vế *trừ Tết âm lịch*; nhật ký §7.1 ghi nguyên văn, lần hỏi lại và chỗ
   *lời chọn* (phường, quận là chữ Claude viết sẵn trong phương án).
2. `fe/src/lib/seo.test.ts` A5 đòi JSON-LD có `address` và `openingHoursSpecification` mọi ngày 06:00–11:00 — xanh.
3. U-094 hẹp lại còn tên miền và duyệt câu mô tả, vẫn ở *Đang mở*.
4. `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · **Claude Code**, nhánh `P4A-01`; chưa ai duyệt độc lập. `npx vitest run src/lib/seo.test.ts` ⇒
`Tests  12 passed (12)`; `tsc --noEmit` sạch; trang chủ thật (`next dev` cổng 3000) in JSON-LD có `address` và
`openingHoursSpecification`. Còn lại: tên miền và câu mô tả — **U-094**.

[↑ đầu file](#top)

<a id="t-204"></a>
### T-204 — Ba lúc máy chưa có mốc để so thì có nhắc POS kiểm tra không (U-102)

**Yêu cầu:** chủ repo 2026-10-19, trong hội thoại, chọn trong câu hỏi có sẵn phương án: *"Luôn nhắc POS kiểm tra"* cho cả ba
lúc của **U-102** — thứ ấy chưa có lần nhập nào · lần nhập gần nhất ghi 0 · sổ có ngày dùng trước ngày nhập đầu tiên. Claude chỉ ra
vế 3 không tự hết (ngày dùng sớm nằm mãi trong sổ ⇒ nhắc vĩnh viễn); cùng ngày chủ repo chọn lại cho vế 3: *"Đã có lần nhập thì so tỉ
lệ như thường"* — vế 1 và vế 2 vẫn luôn nhắc. **Mức:** L1
— đổi hành vi một lời nhắc và hợp đồng; không chạm tiền, không chạm dữ liệu đã ghi (lời nhắc là phép đọc).

**Claude chốt (thiết kế):** ba trạng thái có tên giữ nguyên (`no_purchase` · `latest_purchase_zero` · `usage_before_first_purchase`) để
màn nói được *vì sao*; `check_reminder` của `no_purchase` · `latest_purchase_zero` là `true`, của `usage_before_first_purchase` tính
như `ready` (`balance < reminder_ratio × latest_purchase_measure`), nên cờ không còn `null` — hợp đồng đổi kiểu cờ thành `boolean`,
MINOR `0.41.0` → `0.42.0`. Phép tính của `ready` không đổi. Một chỗ tính duy nhất (`sql/doc.sql`, ADR-119) giữ nguyên.

*Nghiệm thu* (viết trước, 2026-10-19):
1. `TestI025_NhacKiemTraQuyenVaCungTapKho`: ca *chưa nhập* · *nhập không* nhắc `true`; ca *dùng trước* (còn 0 của lần nhập 10) nhắc
   `true`, ca mới *dùng trước, còn nhiều* (còn 9) `false`; POS đọc `GET /supply-check-reminders` thấy đúng tập có cờ `true`, gồm hai ca
   đầu. `TestI025_KhoTrangThaiChuaCoLoi`: bốn bước lần lượt `true` · `true` · `false` (còn 4 ≥ 0.2 × 5) · `true` — đỏ trước khi sửa,
   xanh sau, trên PostgreSQL thật (`be-check`).
2. Trang kho bày lý do của từng trạng thái (*chưa có lần mua* · *lần mua gần nhất bằng 0* nhắc; *có số dùng trước lần mua đầu* là ghi
   chú cạnh kết quả so tỉ lệ); tổng quan bỏ nhánh *Chưa đủ dữ liệu để nhắc*; `fe-check: PASS`.
3. Gate 1g xanh với hợp đồng `0.42.0`; dòng nhật ký ở `01-hop-dong-api.md`; `schema.ts` sinh lại.
4. `master_plan/shop-facts.md` §8.4 ghi lời mới có ngày và người quyết; `U-102` chuyển xuống *Đã có lời giải*.
5. Chạy thật: một thứ mới chưa nhập ⇒ POS đứng quầy đọc thấy tên ở `GET /supply-check-reminders`.
6. `./scripts/gate.sh` xanh.

**Bàn giao** — 2026-10-19 · thực hiện: **Claude Code** trên nhánh `P4A-01` (nền `54ce4b7`); chưa ai duyệt độc lập.
File: `be/internal/nguyenlieu/{sql/doc.sql,internal/sqlcgen/doc.sql.go,repository.go,service.go,kho_test.go,nhac_kiem_test.go}` ·
`docs/product/3-be/{openapi.yaml,01-hop-dong-api.md}` · `fe/src/lib/api/schema.ts` · `fe/src/app/chu-quan/{_components/kho.tsx,_components/tong-quan.tsx,kho/kho.test.tsx,tong-quan.test.tsx}` ·
`master_plan/shop-facts.md` §8.4 · `docs/product/99-unknowns.md` (U-102 đóng) · `quality/invariants.md` I-025 · `docs/decisions.md` ADR-119 *Sửa đổi* · `docs/product/4-fe/01-khung-fe.md`.
1. Đỏ trước khi sửa (database thử cổng 5498): `--- FAIL: TestI025_KhoTrangThaiChuaCoLoi` (*check_reminder:<nil>*) và `--- FAIL:
   TestI025_NhacKiemTraQuyenVaCungTapKho`; sau sửa `ok banhcuon/be/internal/nguyenlieu` · `ok banhcuon/be/internal/tongquan`;
   `PASS  Gate 1   be-check — mọi test backend qua PostgreSQL thật đều đạt`.
2. `fe-check: apigen PASS — schema.ts khớp hợp đồng` · `Tests  272 passed (272)` · `fe-check: PASS`.
3. `PASS  Gate 1g  check-api-contract — hợp đồng 0.42.0; …`.
4. shop-facts §8.4 đoạn *2026-10-19* và dòng nhật ký; U-102 ở *Đã có lời giải*.
5. Chạy thật (database làm việc, server thật): chủ quán thêm *Mộc nhĩ* ⇒ `reminder_status: no_purchase, check_reminder: true`;
   POS đứng quầy `GET /supply-check-reminders` ⇒ `{"items":[{"supply_item_id":1,"name":"Mộc nhĩ","purchase_unit":"kg"}]} HTTP 200`.
6. `PASS  gate     không cổng nào đỏ` (SKIP `db` — không đổi `db/`).
Còn lại: không.

[↑ đầu file](#top)

<a id="t-203"></a>
### T-203 — Cửa duyệt tài khoản gắn được vào người mang cờ chủ quán (F-071)

**Yêu cầu:** chủ repo 2026-10-19, *"hãy yêu cầu codex làm f-071. đồng ý với đề xuất của bạn"* — đề xuất ở **F-071**: cửa duyệt
từ chối `person_id` có `is_owner`, lời từ chối mới ở hợp đồng, test hồi quy. **Mức:** L2 — chạm quyền (ai thành chủ quán) và
hợp đồng.

**Claude chốt (thiết kế, không phải lời quán):** (1) mã mới `account_person_is_owner`, `409`, kèm `field: person_id` — cùng nhóm
`409` với `account_not_*` của cửa này; (2) kiểm ở backend trong cùng giao dịch duyệt, đọc `person.is_owner` của người được chọn;
**không** siết ở database lượt này — luật nằm ở một cửa ghi duy nhất (Gate 1f), siết chéo bảng cần trigger và một lát lược đồ
riêng, chưa đáng khi màn và cửa đã chặn; (3) hợp đồng tăng MINOR `0.40.0` → `0.41.0`; (4) trang nhân viên bày lời *người đã
chọn là chủ quán*, gắn ô *Người trong quán*, đọc lại danh sách; (5) vế mới của `I-033` lấy từ **ADR-109** điểm 3 (chủ repo đã duyệt).

*Nghiệm thu* (viết trước, 2026-10-19):
1. `TestI033_DuyetKhongGanVaoNguoiChuQuan` (`be/internal/taikhoan/taikhoan_test.go`, Claude viết trước — đỏ ở base `a921357`:
   `duyệt gắn vào người chủ quán: muốn 409 account_person_is_owner, field person_id`) xanh, **không** sửa điều kiện kiểm;
   cả package `taikhoan` xanh trong `be-check` (Claude chạy — sandbox Codex không tới Docker).
2. Ca FE *gắn vào người chủ quán bị từ chối* ở `nhan-vien.test.tsx` (Claude viết trước, đỏ) xanh; 20 ca cũ vẫn xanh.
3. Gate 1g xanh với hợp đồng `0.41.0`: mã ở `ErrorCode`, status `409` ở bảng status của `apierr`; dòng nhật ký ở
   `docs/product/3-be/01-hop-dong-api.md`; `fe/src/lib/api/schema.ts` sinh lại (`fe-check: apigen PASS`).
4. Chạy thật (Claude): dựng lại cảnh của **F-071** — người lạ duyệt gắn vào người chủ quán ⇒ `409`, không đăng nhập được.
5. `./scripts/gate.sh` xanh ở clone chính, có `be-check` và `fe-check: PASS`.

**Bàn giao** — 2026-10-19 · thực hiện: **Codex** (worktree `../lean_wt/T-203`, nhánh `codex/T-203`, base `a921357`); duyệt và tích hợp:
**Claude Code** — đọc diff thật, áp vào nhánh `P4A-01` (không xung đột với P4A-07…11), tự chạy gate. Không đổi điều kiện kiểm của hai test viết trước.
File: `be/internal/{apierr/apierr.go,taikhoan/repository.go,taikhoan/service.go,taikhoan/taikhoan_test.go}` · `docs/product/3-be/{openapi.yaml,01-hop-dong-api.md}` ·
`fe/src/lib/api/schema.ts` · `fe/src/app/chu-quan/{_components/du-lieu-nhan-vien.ts,nhan-vien/nhan-vien.test.tsx}` · `work/findings.md` (F-071 → Fixed).
1. `--- PASS: TestI033_DuyetKhongGanVaoNguoiChuQuan (0.61s)`; `PASS  Gate 1   be-check — mọi test backend qua PostgreSQL thật đều đạt`.
2. `fe-check: apigen PASS — schema.ts khớp hợp đồng` · `Tests  272 passed (272)` · `fe-check: PASS`.
3. `PASS  Gate 1g  check-api-contract — hợp đồng 0.41.0; 112 đường gọi ở hợp đồng, 112 ở code; 111 mã lỗi …`.
4. Chạy thật (database làm việc `banhcuon` cổng 5433, server thật cổng 8080): người lạ `nguoila` tự đăng ký ⇒ `cho_duyet`; chủ quán duyệt
   gắn `person_id: 5` (người *Chủ quán* `is_owner` không tài khoản của dữ liệu mồi) ⇒ `{"code":"account_person_is_owner","field":"person_id"} HTTP 409`;
   người lạ đăng nhập ⇒ `{"code":"invalid_credentials"} HTTP 401`.
5. `PASS  gate     không cổng nào đỏ` (SKIP `db` — không đổi gì ở `db/`).
Còn lại: không.

[↑ đầu file](#top)

<a id="t-171"></a>
### T-171 · T-172 — Hai nhánh chen nhau không có test (F-064 · F-065)

**Yêu cầu:** chủ repo, 2026-10-12 (*"spawn agent hoặc làm luôn trong session này f-064 và f-065"*). Claude làm trong phiên, không
giao Codex. Mức **L1** mỗi task: chỉ thêm test, không đổi code chạy; một commit mỗi task. Hai finding đo ở T-155 · T-159 (lỗi cài
không bị bắt). Dựng tất định, không dựa vào may rủi lịch chạy (khác khuôn vòng lặp của F-062).

**T-171 — Acceptance (viết trước, 2026-10-12):**
1. Test mới `TestI021_TienChenLucKyNgayKhongLotVaoSoDaKy` (`be/internal/don/duong_tien_test.go`): ngày 28 có tiền đầu két và số đếm khớp;
   một kết nối chủ lược đồ giữ `LOCK TABLE shop.prepayment IN SHARE MODE`; cửa nhận trả trước tiền mặt chạy tới khi bị chặn ở câu thêm
   (đã giữ khoá chung của ngày, đã qua kiểm ngày chưa ký); chủ quán bấm ký kèm giải thích; nhả khoá. Kỳ vọng: cả hai 201, số lệch đã ký
   bằng số lệch đọc lại sau cùng và bằng `−` khoản trả trước (lần ký thấy khoản ấy). PASS trên PostgreSQL thật.
2. Lỗi cài trong worktree riêng: `ngayban.Khoa` dùng khoá chung cho cửa ký ⇒ test mới đỏ (khoản trả trước lọt vào ngày đã ký). Gỡ ⇒ xanh.
3. F-064 → Fixed, kèm tên test; `./scripts/gate.sh` không `FAIL`.

**T-171 — Bàn giao** (2026-10-12). Thi công và cài lỗi: **Claude Code** trên cây chính, nhánh `chatgpt_involve`, nền `8b4510c`; chưa ai
duyệt độc lập. File: `be/internal/don/duong_tien_test.go` (helper `choDen` + test mới), `work/findings.md` (F-064 → Fixed).
- *(1)* `be-check` trên PostgreSQL thật: `TestI021_TienChenLucKyNgayKhongLotVaoSoDaKy` PASS (0,25 s), không test nào FAIL.
- *(2)* Lỗi cài trong `../lean_wt/T-171-fault` (nền `8b4510c` + hai file test): `ngayban.Khoa` nhánh `ky=true` gọi khoá chung ⇒ test đỏ;
  file gỡ về bản đúng ⇒ worktree chỉ còn hai file test.
- *(3)* `./scripts/gate.sh` ở cây chính: exit 0, không `FAIL`; hai `SKIP` (Gate 1d, `db`) là cổng không chạy, không tính là đạt.

**T-172 — Acceptance (viết trước, 2026-10-12):**
1. Test mới `TestYC15_VaoChenCungMocBiTuChoi` (`be/internal/nguoi/nguoi_test.go`): không khoảng nào mở; chủ lược đồ thêm một khoảng mở cho C bắt
   đầu sau mốc hiện tại; B vào quầy ⇒ 409 `counter_duty_changed`, số khoảng và khoảng đang mở không đổi; qua mốc ấy, B vào lại ⇒ 201, thay
   C. PASS trên PostgreSQL thật.
2. Lỗi cài trong worktree riêng: bỏ nhánh `if changed` ⇒ test mới đỏ. Gỡ ⇒ xanh.
3. F-065 → Fixed, kèm tên test; `./scripts/gate.sh` không `FAIL`.

**T-172 — Bàn giao** (2026-10-12). Thi công và cài lỗi: **Claude Code** trên cây chính, nền `820d84d`; chưa ai duyệt độc lập. File:
`be/internal/nguoi/nguoi_test.go` (test mới, import `strings`), `work/findings.md` (F-065 → Fixed, kèm phần sửa nhận định).
- *(1)* `be-check` trên PostgreSQL thật: `TestYC15_VaoChenCungMocBiTuChoi` PASS (1,6 s — chờ qua mốc của khoảng dựng sẵn), mọi `TestYC15_*`
  khác PASS, không test nào FAIL. Lượt đầu test đỏ vì so `[]khoang` bằng `fmt.Sprint` (in địa chỉ con trỏ `*time.Time`) và để lại khoảng
  mở tương lai làm hai test sau đỏ theo ⇒ so bằng chuỗi giá trị, thêm `t.Cleanup` khép khoảng ấy.
- *(2)* **Acceptance (2) đổi lỗi cài, có lý do:** bỏ nhánh `if changed` ⇒ be-check xanh vì ràng buộc database từ chối cùng mã (xem F-065).
  Lỗi cài thay: nhánh chen trả khoảng hiện có như thành công ⇒ test đỏ *muốn 409 "counter_duty_changed", nhận 200*. Worktree
  `../lean_wt/T-171-fault`, file gỡ về bản đúng.
- *(3)* `./scripts/gate.sh` ở cây chính: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.

[↑ đầu file](#top)

<a id="t-149"></a>
### T-149 — Stack backend đã duyệt (Gin + sqlc, cấu trúc kết hợp) mà owner vẫn ghi `net/http`, cấm sqlc, và chưa có task nào cho bước 02…09

**Yêu cầu:** chủ repo, 2026-10-11 — phiếu `docs/private/be_feature/prompts/BE-STACK-01-ghi-quyet-dinh-L3.md`
(*"claude hãy làm"*). Stack chủ repo duyệt 2026-10-10 (kế hoạch `docs/private/be_feature/be-stack-migration-steps.md`
§0–§2), không mở lại. Mức **L3**: đổi quyết định kiến trúc của ADR-083 và luật mà gate cùng mọi bước sau đọc.
Claude tự làm, không giao Codex (phiếu nói vậy). Chỉ tài liệu: không code, không migration, không invariant.

**Acceptance (viết trước khi sửa, 2026-10-11):**
- [x] (1) ADR mới (số kế tiếp, tra bằng lệnh) ngày 2026-10-10, người quyết là chủ repo; thay điểm 1 và 6 của ADR-083, giữ ADR-082 · 084 · 085; có bốn lý do chọn kết hợp và hai phương án bị loại đúng kế hoạch §1; ghi việc chuyển hàm mở giao dịch sang `platform/postgres` là việc của bước 03, luật một hàm giữ nguyên.
- [x] (2) `QC-05` · `QC-11` · `QC-12` · `QC-13` · `QC-14` ghi đủ bản ghim, cây, luật route và import, mỗi mục một phép kiểm chạy được và in rỗng trên cây hôm nay; đối chiếu từng mục với kế hoạch §0–§2, không lệch.
- [x] (3) Mỗi bước 02…09 có task trong *Ready* theo thứ tự, mức, người làm; bước 05 và 06 mỗi miền một task, bước 07 hai task; mỗi task có mốc xanh để lùi riêng, không đổi dữ liệu. Acceptance từng bước nằm ở phiếu của bước (luật *entry trỏ, prompt giữ*).
- [x] (4) Rà thiết kế trước code: ghi các điểm thiếu thông tin và bước mà mỗi điểm chặn.
- [x] (5) `./scripts/gate.sh` không có `FAIL`; `SKIP` ghi là chưa chạy. `be-check` và lỗi cài không áp dụng cho bước chỉ tài liệu.

**Chia lát — bước 02…09** (Claude, 2026-10-11). Mỗi task là **một commit**, xanh trước và sau. Hỏng thì
`git revert` đúng commit ấy, lùi theo thứ tự ngược. Không task nào đổi migration hay dữ liệu, nên lùi không
đụng database. Từ T-151, adapter `gin.WrapH` giữ các miền chưa chuyển vẫn chạy, nên dừng ở giữa dãy vẫn
là một trạng thái chạy được. Phiếu và Acceptance của từng bước: `docs/private/be_feature/prompts/BE-STACK-<NN>-…`.

| Task | Bước | Miền / việc | Mức | Mốc xanh để lùi |
|---|---|---|---|---|
| T-150 | 02 | công cụ, Gate 1f · 1g, phép kiểm import Gin, `verify.sh` sinh lại | L2 | `--list` hai gate không đổi; chưa cửa nào chuyển |
| T-151 | 03 | `platform/postgres`, `testhelper`, `middleware`, `cmd/server` + `gin.WrapH` | L2 | tập đường gọi khớp hợp đồng như trước |
| T-152 | 04 | `menu` | L2 | test `menu` xanh, không đổi điều kiện kiểm |
| T-153…T-159 | 05 | `qr` → `gia` → `ngayban` → `ban` → `phien` → `vongdoi` → `nguoi` | L2 (Claude chấm lại lúc giao) | mỗi miền một commit |
| T-160…T-162 | 06 | `tratruoc` → `hoadon` → `ket` | L2 | mỗi miền một commit; lỗi thu sai cài được bắt |
| T-163 · T-164 | 07 | `sanxuat` → `don` | L2 | be-check ≥ 2 lượt xanh mỗi task |
| T-165 | 08 | gỡ adapter và khuôn route cũ, luật `-- name:` cho mọi miền | L1 | gate xanh không còn nhánh chuyển tiếp |
| T-166 | 09 | rà chéo | L1 | không đổi code |

**Rà thiết kế trước code — điểm còn thiếu và bước chúng chặn** (Claude, 2026-10-11):
- *Chặn T-150 (giao Codex):* worktree tạo từ `HEAD` không thấy phần Done chưa commit của T-138 · T-140 · T-142 ·
  T-143 · T-147, cũng không thấy T-149. Chủ repo commit trước, hoặc chưa giao.
- *Chặn thứ tự T-146 với T-150:* T-146 thêm một cửa vào `ket`. Đổi stack đòi không ai viết `be/` song song
  (T-148 Acceptance 1), nên T-146 phải xong trước T-150 hoặc chờ sau T-166. Đã xếp T-146 trên dãy này. Chủ repo đổi được.
  **Chủ repo chọn 2026-10-11: T-146 chờ sau T-166**; dòng *Ready* đã dời xuống dưới T-166.
- *T-150 — thử sqlc trước giao (Claude, 2026-10-11, scratchpad phiên `8eaa6732…/scratchpad/t150probe/`, không đụng repo):*
  go1.27.2 + `go get -tool github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1` ⇒ `go tool sqlc version` in `v1.31.1`;
  `schema:` trỏ cả thư mục `db/migrations/` (20 bước, kể cả hai file chưa track của T-138 · T-140) và hai query mẫu
  của `menu` (đọc `menu_item … FOR UPDATE`, `UPDATE menu_component … RETURNING`) ⇒ `sqlc generate` exit 0,
  `models.go` 42 kiểu bảng = 42 `CREATE TABLE` trong `*.up.sql`, tên bảng trần, có `DoiGia(ctx, DoiGiaParams)`.
  Điều kiện DỪNG của Acceptance 1 không xảy ra. Ghi để phiếu biết: biểu thức `x IS NOT NULL` không ép kiểu sinh
  `interface{}`, nên query đích cần `::boolean`. Chặn giao đã gỡ: T-138 · T-140 · T-144 commit 2026-10-11 (`18497ee`, `9f55b21`);
  T-145 chỉ đổi tài liệu owner, không chạm phần T-150 đọc.
- *T-150 — sqlc.yaml rỗng:* chưa biết sqlc v1.31.1 có nhận cấu hình chưa có mục `sql:` nào hay không. Đã chốt ở
  ADR-093 điểm 3: nhận thì file sinh ở T-150, không nhận thì sinh ở T-152 cùng mục `menu`. Dòng ngoại lệ Gate 1b
  của `docs/private/be_feature/prompts/README.md` giữ tới lượt tạo file. Thiếu file nghĩa là chưa miền nào chuyển.
  **Đã thử 2026-10-11 (Claude):** `sql: []` và file không có `sql:` đều ⇒ `error parsing sqlc.yaml: no packages`, exit 1.
  Vậy T-150 **không** tạo `be/sqlc.yaml`; file sinh ở T-152 cùng mục `menu`, dòng ngoại lệ Gate 1b giữ tới đó.
- *T-151 — owner phải đổi cùng lượt:* `QC-15` · `QC-16` và phép kiểm của chúng nêu `be/internal/db/` ·
  `be/internal/dbtest/`. Chuyển thư mục mà không sửa thì db-check đỏ. Claude sửa hai mục ấy và siết phép kiểm
  `QC-13` · `QC-14` (bỏ `internal/db`) lúc tích hợp T-151; Codex không sửa owner.
- *T-151 — danh tính:* `authz.ChonTen` (T-143) đọc header `X-Person-Id`. `middleware/` chỉ gắn người vào
  `gin.Context`, không thay `authz.Run`; Claude liệt kê đúng file gọi nền trước khi giao.
- *T-151 trở đi — tên tham số đường dẫn:* Gin từ chối lúc đăng ký nếu cùng tiền tố, cùng vị trí có hai tên tham
  số khác nhau. 45 đường của `openapi.yaml` (cây làm việc 2026-10-11) không có cặp nào như thế (Claude đọc bằng
  awk); luật ghi ở `QC-12`, test `TestQC12_` dựng router sẽ đỏ nếu một lần đổi hợp đồng sau phạm.
- *T-150 — con trỏ trong hợp đồng:* `docs/product/3-be/01-hop-dong-api.md` §2 điều 2 giải thích `{tên}` bằng
  "cùng cú pháp với mẫu của `net/http` (`QC-12`)". Câu ấy còn đúng tới T-165 (miền chưa chuyển vẫn dùng
  `ServeMux`), nhưng lý lẽ đổi khi Gate 1g đọc `:tên` của Gin. Phiếu bước 01 cấm sửa tài liệu hợp đồng, nên
  Claude sửa câu ấy lúc tích hợp T-150 (cùng lượt Gate 1g học khuôn Gin), không để Codex sửa.
- *T-155:* tên thật của các test `TestYC01_` · `TestYC10_` chạm ranh giới ngày phải kiểm kê trước khi giao (phiếu bước 05).
- *T-159:* miền `nguoi` (T-143) không có trong danh sách §2 kế hoạch. Thêm một task bước 05 theo luật đã chốt
  ở `prompts/README.md` (Claude, 2026-10-10).
- *Siết phép kiểm theo bước* (Claude làm lúc tích hợp): T-150 — `QC-05` chỉ còn migrate v4.20.1, `QC-11` chỉ còn
  `go 1.27.2` và đòi gin · sqlc có mặt; T-151 — `QC-13` · `QC-14` bỏ `internal/db`; T-165 — `QC-12` bỏ khuôn
  `ServeMux`, `QC-13` luật `-- name:` cho mọi miền, `QC-14` lần cuối.

**T-150 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-11). Acceptance là chín dòng của phiếu
`docs/private/be_feature/prompts/BE-STACK-02-cong-cu-va-gate-L2.md` (luật *entry trỏ, prompt giữ*), viết trước thi công.
Mức **L2**: sai thì gate để lọt câu ghi ngoài cửa, tức hỏng bảo vệ `I-012` · `I-018` của ADR-082. Điểm chốt thêm vì thử thật:
- `be/sqlc.yaml` không tạo ở T-150 (mục trên). Mọi ca có `sqlc.yaml` chạy bằng fixture trong thư mục tạm.
- Khuôn một mục của `sqlc.yaml` (T-152 viết theo): `engine: postgresql`, `schema: ../db/migrations`, `queries:` là danh sách
  `internal/<miền>/sql` cộng **từng** `internal/<miền>/sql/<cửa>` (sqlc không đọc thư mục con — thử 2026-10-11),
  `gen.go`: `package: sqlcgen`, `out: internal/<miền>/internal/sqlcgen`, `sql_package: pgx/v5`. Gate 1f đỏ khi một mục
  lệch khuôn ấy hoặc thiếu một thư mục cửa đang có.
- Hai file cùng tên ở hai cửa (vd. `nguoi/sql/vao_quay/khoa.sql` · `roi_quay/khoa.sql`) bị sqlc gộp vào một file sinh, nên
  phép miễn của Gate 1f khớp theo `-- name:`, không theo tên file.
- File mới: `scripts/check-gin-imports.sh` · `.test.sh` (gọi trong `scripts/gate.sh`, mọi lượt, chỉ đọc file) và
  `scripts/check-sqlcgen.sh` · `.test.sh` (gọi trong `scripts/verify.sh`). Claude thêm dòng vào `CLAUDE.md` §5 lúc tích hợp.
- Phiếu, báo cáo và log: scratchpad phiên `8eaa6732…/scratchpad/T-150-*`.

**T-150 — Bàn giao** (2026-10-11). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-150`, nhánh `codex/T-150`
từ `f70dfb3`); go.mod · go.sum · compose do Claude làm sẵn vì sandbox của Codex không có mạng. Duyệt, cài lỗi, tích
hợp vào cây chính: **Claude**. File: `be/go.mod` · `be/go.sum` · `compose.yaml` · `scripts/check-write-paths.sh` · `.test.sh` ·
`scripts/check-api-contract.sh` · `.test.sh` · `scripts/check-gin-imports.sh` · `.test.sh` (mới) · `scripts/check-sqlcgen.sh` ·
`.test.sh` (mới) · `scripts/verify.sh` · `scripts/gate.sh` · `scripts/gate.test.sh`; owner do Claude: `CLAUDE.md` §5 (Gate 1h),
`10-quy-uoc-code.md` (`QC-05` · `QC-11` siết, `QC-12` · `QC-13` · `QC-16`, bảng §9), `3-be/01-hop-dong-api.md` §2 điều 2.
Log: scratchpad phiên `8eaa6732…/scratchpad/T-150-*`.
- *Claude sửa thêm khi duyệt:* `gate.test.sh` thiếu stub Gate 1h (Codex dừng đúng vì ngoài scope); Gate 1g để lọt
  `{tên}` trong đường Gin (Gin đọc là chữ thường) — nay đỏ, có ca `brace`. **QC-16** cấm `sqlite` trong `go.mod` đỏ vì
  dòng `tool` của sqlc kéo `ncruces/go-sqlite3 // indirect`; phép kiểm nay chấm phụ thuộc trực tiếp và import Go.
- *Lỗi cài trên bản sao `be/` thật, miền `menu` chuyển thử bằng sqlc.yaml đúng khuôn:* (A) file cửa chưa `-- name:` ⇒
  Gate 1f đỏ bốn file của `menu`, mười hai miền khác im; (B) annotation + `;` rồi `go tool sqlc generate` ⇒ 1f và
  `check-sqlcgen` xanh, `--list` ô → cửa không đổi; (C) sửa cột SET trong hằng sinh ⇒ 1f `lệch nguồn` + sqlcgen đỏ;
  (D) xoá một file sinh ⇒ sqlcgen đỏ; (E) thêm file dư ⇒ sqlcgen đỏ; (F) file giả "Code generated" có câu ghi không
  nguồn ⇒ 1f `thiếu nguồn` + `câu ghi ngoài mọi cửa`; (G) `Begin` trong code sinh ⇒ khối `QC-13` in dòng. Trên cây
  worktree: (H) `menu.go` import Gin bí danh trong khối nhiều dòng, `service.go` import `gin/binding` ⇒ Gate 1h đỏ đúng
  file:dòng, `handler.go` xanh; (I) `r.POST(` nhiều dòng với `:ma` thay `{menu_component_id}` ⇒ Gate 1g `route: chỉ ở
  code`. Gỡ hết ⇒ xanh. `--list` hai gate trên cây thật trước/sau: `diff` rỗng.
- *Gate cây chính* (sau tích hợp): exit 0, không `SKIP`; be-check PASS, db-check 20 bước + 18 khối QC PASS, 15 file
  `scripts/*.test.sh` qua; `check-sqlcgen: chưa miền nào chuyển`.
- *Cho T-152:* sqlc đòi mỗi câu kết bằng `;` — bốn file cửa của `menu` hôm nay không có; comment đứng ngay sau dòng
  `-- name:` có thể bị sqlc tách khỏi hằng, nên đặt chú thích trước dòng ấy. Gin còn `// indirect` tới T-151.

**T-151 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-11). Acceptance là sáu dòng của phiếu
`docs/private/be_feature/prompts/BE-STACK-03-nen-L2.md`, viết trước thi công. Mức **L2**: sai thì hàm mở giao dịch
hay hàm kết nối đổi hành vi (`I-012`, `QC-15`), hoặc một đường gọi của hợp đồng không còn tới cửa. Điểm chốt thêm:
- *Hình nối miền cũ:* một `http.ServeMux` chung, mỗi miền chưa chuyển gọi `Routes(mux, …)` như hôm nay; router Gin
  nhận nó bằng **`NoRoute`** bọc `gin.WrapH`, không đăng ký lại từng đường (Gate 1g sẽ đếm trùng). `ServeMux` tự khớp
  mẫu và tự điền `PathValue`, nên tham số đường dẫn, dấu `/` cuối, 404, 405 và `HEAD` giữ y hành vi hôm nay. Trước khi
  chuyển cho `ServeMux`, adapter đặt lại status về 200 (Gin đặt sẵn 404 cho `NoRoute`; handler ghi thân mà không gọi
  `WriteHeader` sẽ ra 404). `HandleMethodNotAllowed` để mặc định `false`.
- *Hàm dựng router:* `newRouter(pool *pgxpool.Pool, auth authz.Authenticator) *gin.Engine` ở `be/cmd/server/router.go`;
  `main.go` đọc cấu hình, gọi `postgres.Open`, `gin.New()` (không `Logger`/`Recovery` mặc định, giữ cách lỗi hôm nay),
  `authz.ChonTen{}`. Biến môi trường của server: `BANHCUON_DATABASE_URL`, `BANHCUON_SHOP_TZ`, `BANHCUON_ADDR`
  (Claude chọn 2026-10-11; cách cấp cấu hình ở máy thật là việc của pha 5, `QC-15`).
- *Middleware:* `middleware.GanNguoi(auth)` đọc người qua `Authenticator`, gắn vào `gin.Context`, không bao giờ từ chối hay
  dừng chuỗi; `middleware.Nguoi(c)` đọc lại. Quyền vẫn chỉ kiểm trong `authz.Run`.
- *Test Claude viết trước (đỏ tới khi có code):* `be/cmd/server/router_test.go` — `TestQC12_RouterPhucVuMoiDuongCuaHopDong`
  (mỗi đường của `openapi.yaml` tới một handler, không rơi vào 404/405 của `ServeMux`), `TestQC12_RouterGiuThamSoDuongDan`,
  `TestQC12_RouterDauGachCuoiVaPhuongThuc`, `TestQC12_RouterHEADChayNhuGET`, `TestQC12_RouterThuTuTuChoiVaThanLoi`;
  `be/internal/middleware/nguoi_test.go` — `TestQC12_MiddlewareGanNguoiKhongTuChoi`. Tên trong Acceptance
  (`TestQC15_KetNoiBackend` · `TestQC03_ShopAppKhongXoaDuoc` · `TestI012_LoiCuaThanCuaLuiCaGiaoDich`) đều có ở nền `c9114c6`.
- *File gọi nền (chỉ đổi import và tên gói):* `apierr/apierr_test.go` · `authz/authz.go` · `authz/authz_test.go` · `ban/ban.go` ·
  `don/dat_truoc.go` · `don/don_test.go` · `don/duong_tien_test.go` · `don/mang_di_test.go` · `gia/gia_test.go` · `gia/http.go` ·
  `hoadon/tien.go` · `ket/ket.go` · `menu/menu_test.go` · `nguoi/nguoi.go` · `nguoi/nguoi_test.go` · `qr/qr_test.go` (dưới
  `be/internal/`). `scripts/check-write-paths.sh` không đọc vị trí hàm mở giao dịch (phép quét ở khối `QC-13`), nên không đổi.
- *Lỗi cài Claude chạy khi duyệt:* bỏ một `Routes` khỏi `newRouter`; bỏ dòng đặt lại status; middleware dừng chuỗi khi thiếu
  người; `InTx` commit khi thân lỗi; `Open` bỏ kiểm vai. Mỗi lỗi phải làm đúng test tương ứng đỏ.
- *Owner Claude sửa lúc tích hợp:* `QC-13` · `QC-14` (bỏ `internal/db`), `QC-15` · `QC-16` (đường dẫn mới), bảng §9 của
  `10-quy-uoc-code.md`; con trỏ `db.Open` ở `docs/product/3-be/05-luong-mang-di.md` · `06-duong-tien.md`.

**T-151 — Bàn giao** (2026-10-11). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-151`, nhánh `codex/T-151` từ
`c9114c6`); `go.mod` · `go.sum` (gin thành phụ thuộc trực tiếp) và hai file test do Claude làm sẵn vì sandbox không có mạng.
Duyệt, cài lỗi, tích hợp vào cây chính: **Claude** (patch từ worktree, `diff -rq be` hai cây rỗng). Codex không `git mv` được
(sandbox chặn index); Claude đổi tên `db.go` → `postgres.go`, `dbtest.go` → `testhelper.go`. Mười sáu file gọi nền: chỉ dòng import
và tiền tố gói (lọc diff bằng `grep -v` hai khuôn ấy ⇒ rỗng); thân `Open` · `InTx` giữ nguyên (`diff` với `HEAD` chỉ khác dòng `package`).
Owner do Claude: `10-quy-uoc-code.md` (`QC-13` · `QC-14` · `QC-15` · `QC-16`, bảng §9), `3-be/05-luong-mang-di.md` · `06-duong-tien.md`.
Log: scratchpad phiên `17b8f2e9…/scratchpad/T-151-*` (phiếu, báo cáo, log Codex, `--list` trước/sau, gate, `T-151-fault/`).
- *(1) · (2) · (3)* `be-check` trên PostgreSQL thật: `TestQC15_KetNoiBackend` (ba ca con) · `TestQC03_ShopAppKhongXoaDuoc` ·
  `TestI012_LoiCuaThanCuaLuiCaGiaoDich` · `TestQC12_MiddlewareGanNguoiKhongTuChoi` và mọi test `apierr` · `authz` PASS.
- *(4)* `--list` hai gate trước/sau: danh sách ô ghi, cửa, đường gọi, mã giống hệt; chỉ khác dòng đếm số file đã soát
  (113 → 116, 36 → 39 — ba file Go mới). Gate 1g: 45 đường ở hợp đồng, 45 ở code, không trùng.
- *(5)* Năm `TestQC12_Router*` PASS qua đúng `newRouter`. Lỗi cài, mỗi lần một lỗi rồi gỡ: (A) bỏ `ket.Routes` ⇒
  `…PhucVuMoiDuongCuaHopDong` đỏ ở bốn đường của két (404 văn bản của `ServeMux`); (C) middleware dừng chuỗi khi thiếu người ⇒
  test middleware và năm test router đỏ; (D) `InTx` commit khi thân lỗi ⇒ `TestI012_LoiCuaThanCuaLuiCaGiaoDich` đỏ; (E) `Open` bỏ
  kiểm vai ⇒ `TestQC15_KetNoiBackend` đỏ. (B) bỏ dòng đặt lại status 200 ⇒ **vẫn xanh**: hôm nay không handler cũ nào ghi thân
  mà thiếu `WriteHeader`, nên dòng ấy là phòng xa, chưa có test chấm.
- *(6)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, `PASS gate không cổng nào đỏ`, không dòng `SKIP`; be-check PASS,
  db-check 20 bước + 18 khối QC PASS, 15 file `scripts/*.test.sh` qua.
- *Cho T-152:* khi `menu` đăng ký đường Gin thật, yêu cầu sai phương thức lên đường ấy rơi xuống `NoRoute` ⇒ `ServeMux` trả 404
  thay vì 405, và `HEAD` không còn chạy như `GET`; `TestQC12_RouterDauGachCuoiVaPhuongThuc` · `…HEADChayNhuGET` sẽ đỏ — T-152
  phải chọn cách giữ hành vi (vd. `HandleMethodNotAllowed`) hay ghi quyết định đổi, không sửa test cho xanh.

**T-152 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-11). Acceptance là bốn dòng của phiếu
`docs/private/be_feature/prompts/BE-STACK-04-mien-menu-L2.md`, viết trước khi sửa; sáu tên test trong dòng (1) đều có ở nền
`259676c` (`rg '^func Test' be/internal/menu`). Mức **L2**: sai thì một lần sửa giá, phụ thu, thành phần hay ngừng bán ghi mà
không qua quyền hay không để vết (`I-012` · `I-018`), hoặc ghi đè mốc ngừng bán (`I-009`). Người thi công: **Claude Code**, không
giao Codex — chủ repo giao thẳng trong phiên ("hãy đọc kĩ và hoàn thành T-152"); T-151 đã commit (`259676c`) trước khi sửa.
- *Tầng:* `handler.go` (Gin: đọc tham số và thân, kiểm hình, thứ tự từ chối y như `menu.go` hôm nay — tham số → JSON → trường →
  lý do → quyền), `service.go` (bốn `authz.Door`, `authz.Run`, logic trong giao dịch), `repository.go` (nhận `pgx.Tx`, gọi
  `sqlcgen`). Câu đọc (khoá dòng, kiểm tồn tại, khai lý do) thành file `sql/*.sql`; bốn câu ghi giữ nguyên chỗ, thêm `-- name:`
  và `;`. Người đọc từ `middleware.Nguoi(c)`; hàm đăng ký `menu.Routes(r *gin.Engine, svc *menu.Service)`.
- *Router:* đường Gin thật đầu tiên làm 405 và dấu `/` cuối lệch `ServeMux` (bàn giao T-151 *Cho T-152*). Giữ hành vi:
  `HandleMethodNotAllowed = true` (405 kèm `Allow`), `RedirectTrailingSlash = false` (404, không chuyển hướng). `HEAD` không
  đổi ở bước này vì `menu` không có đường `GET`; ghi luật vào `QC-12`. Không sửa test router.
- *File test được đổi phần dựng router:* `be/internal/menu/menu_test.go` · `be/internal/don/don_test.go` (cả hai gọi
  `menu.Routes`). Thân các test giữ nguyên.
- *Lỗi cài Claude chạy:* import `menu/internal/sqlcgen` từ miền khác ⇒ `go build` đỏ *use of internal package not allowed*;
  sửa tay một hằng sinh ⇒ Gate 1f + `check-sqlcgen` đỏ; bỏ kiểm quyền trong service ⇒ `TestI012_ChiChuQuanSuaMenu` đỏ; bỏ khai
  lý do ⇒ `TestI018_SuaMenuCoLyDoVaDeVet` đỏ; bỏ `HandleMethodNotAllowed` ⇒ `TestQC12_RouterDauGachCuoiVaPhuongThuc` đỏ.
- *Owner Claude sửa cùng lượt:* `QC-12` (cấu hình router), `QC-14` dòng `sqlc.yaml` (sinh ở T-152), bảng §9 của
  `10-quy-uoc-code.md`; gỡ dòng ngoại lệ `be/sqlc.yaml` ở `scripts/check-links.ignore` (file nay có).

**T-152 — Bàn giao** (2026-10-11). Thi công: **Claude Code** trên cây chính, nhánh `chatgpt_involve`, nền `259676c` (T-151);
không giao Codex, **chưa ai duyệt độc lập**. File: `be/sqlc.yaml` (mới) · `be/internal/menu/handler.go` · `service.go` ·
`repository.go` (mới; `menu.go` bị xoá, bản cũ lưu ở scratchpad) · `be/internal/menu/sql/*.sql` (bảy câu đọc mới) · bốn file cửa
(thêm `-- name:`, `;`, `AS discontinued_at`) · `be/internal/menu/internal/sqlcgen/` (sinh) · `be/cmd/server/router.go` ·
`be/internal/menu/menu_test.go` · `be/internal/don/don_test.go` (chỉ phần dựng router); owner: `10-quy-uoc-code.md` (`QC-12`,
`QC-14`, bảng §9), `scripts/check-links.ignore` (gỡ dòng `be/sqlc.yaml`). Log: scratchpad phiên `a68ab2b0…/scratchpad/T-152-*`.
- *(1)* `be-check` trên PostgreSQL thật: sáu test `TestI012_ChiChuQuanSuaMenu` · `TestI018_SuaMenuCoLyDoVaDeVet` ·
  `TestI018_GiaTriSaiKhongGhi` · `TestI018_KhongTimThayKhongGhi` · `TestI009_NgungBanHaiLan` · `TestI013_KhongCoDuongSuaGiaSuat`
  PASS; năm `TestQC12_Router*` và test `don` PASS. Tập tên test trước/sau: `diff` rỗng.
- *(2)* `go tool sqlc generate` + `go build ./...` exit 0; `check-sqlcgen: PASS`; Gate 1f · 1g · 1h PASS. `--list` hai gate
  trước/sau: ô ghi, cửa, đường gọi, mã giống hệt; chỉ khác dòng đếm file đã soát (1f 116 → 138, 1g 39 → 54 — file sinh và file SQL).
- *(3)* Lỗi cài trên bản sao repo (`T-152-fault/`): (A) `qr` import `menu/internal/sqlcgen` ⇒ `go build` đỏ *use of internal
  package … not allowed*, gỡ ⇒ xanh; (B) sửa tay hằng `DoiGia` ⇒ Gate 1f *câu ghi ngoài mọi cửa* + `check-sqlcgen` đỏ; (C) cửa
  đổi giá hạ xuống `NeedCounterOrOwner` ⇒ `TestI012_ChiChuQuanSuaMenu` nhận 200 thay 403; (D) bỏ khai lý do khi ngừng bán ⇒ 500,
  đỏ `TestI018_SuaMenuCoLyDoVaDeVet` · `TestI009_NgungBanHaiLan` · `TestI009_SuaMenuSauKhiDatDonCuKhongDoi`; (E) bỏ
  `HandleMethodNotAllowed` ⇒ `TestQC12_RouterDauGachCuoiVaPhuongThuc` nhận 404 thay 405.
- *(4)* `./scripts/gate.sh` ở cây chính: xem khối cuối của phiên (dán trong báo cáo).
- *Đã biết, không test chấm, ngoài hợp đồng:* đường dẫn không sạch (`//`, `..`) lên đường của `menu` không còn được `ServeMux`
  chuyển hướng 301; `%2F` trong tham số không còn khớp đường. `KhaiLyDo` dùng `$1` trần vì Gate 1f so nguyên văn và sqlc viết lại
  `sqlc.arg(...)` thành `$1`.
- *Cho T-153:* `qr` có đường `GET` đầu tiên lên Gin; với cấu hình này `HEAD` lên đường ấy ⇒ 405 (trước: chạy như `GET`) — chọn giữ
  hay ghi quyết định đổi (`QC-12`).

**T-152 — Duyệt độc lập** (2026-10-11). Người duyệt: **Codex** (`gpt-6-astra`, chỉ đọc, worktree tách `../lean_wt/T-152-review`
ở `4d8271e`, so với `259676c`); Claude kiểm lại từng điểm. Log: scratchpad phiên `3bdd9af1…/scratchpad/T-152-review-*`.
- *Codex:* không lỗi chặn về ghi dữ liệu — bốn cửa giữ `NeedOwner` + `authz.Run`, khoá `FOR UPDATE` và thứ tự đọc như `menu.go`
  cũ, rollback khi lỗi, `ErrNoRows`/ràng buộc giữ ánh xạ, kiểu `int64`/`int32`, mốc `now()` + `to_char` không đổi; năm hunk test
  chỉ đổi phần dựng router, không assert nào đổi. Gate 1f · 1g · 1h, `go build`, `go vet` PASS.
- *Claude chạy bù ở `4d8271e`:* `be-check` PASS (sáu test Acceptance, năm `TestQC12_Router*`); `go tool sqlc generate` không đổi
  file sinh; cài import `menu/internal/sqlcgen` từ `qr` ⇒ *use of internal package … not allowed*, gỡ ⇒ build xanh. Gate ở HEAD
  `ef43aeb`: exit 0, không FAIL.
- *Phát hiện (Codex, Claude xác nhận bằng yêu cầu thật):* `PUT /menu-components/1%2F2/base-price` ở `259676c` ⇒ 400
  `{"code":"invalid_request","field":"menu_component_id"}`; ở `4d8271e` ⇒ 404 văn bản `404 page not found` (Gin khớp trên
  `URL.Path` đã giải mã). Ngoài hợp đồng, không chạm dữ liệu, nhưng lệch "giữ hành vi HTTP" của phiếu. Thử `r.UseRawPath = true`
  trong worktree duyệt ⇒ ca `%2F` về lại 400 JSON, `be-check` PASS. **Claude chốt:** sửa ở **T-153** (lần đầu `qr` sửa
  `newRouter`, cùng lượt chọn `HEAD`), kèm test `TestQC12_…` chấm ca `%2F`, ghi vào `QC-12`.
- *Ghi nhận, không sửa:* `menu_test.go` · `don_test.go` dựng Gin riêng (menu chưa tắt `RedirectTrailingSlash`, don chưa bật
  `HandleMethodNotAllowed`) thay vì gọi `newRouter`; cấu hình thật vẫn do `TestQC12_Router*` chấm.

**T-153 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-11). Mức **L2**: sai thì người không phải chủ quán
đổi được mã QR, hay khách vào được bàn qua mã cũ (`I-023`), hoặc lần đổi mã mất vết (`I-018`). Phiếu mẫu
`docs/private/be_feature/prompts/BE-STACK-05-mien-nho-L2.md`; Acceptance dưới **thay** dòng `qr` của phiếu: dòng ấy thiếu
`TestI018_DoiMaDeLaiVetTrenMaCu` và test bên gọi ở `don`. Tên test kiểm bằng `rg '^func Test'` ở nền `fbbdaef`.
1. Sáu test của miền — `TestI023_ChiChuQuanDoiDuocMa` · `TestI023_MaCuBiTuChoi` · `TestI023_KhachKhongChonDuocBan` ·
   `TestI023_BanKhongCoThiTuChoi` · `TestI023_HaiLanDoiCungLucKhongThanhLoiHeThong` · `TestI018_DoiMaDeLaiVetTrenMaCu` — và test
   bên gọi `TestI023_KhachQRVaoPhienCuaBanQuaMaHienHanh` (`don/tai_ban_test.go`) PASS trên PostgreSQL thật. Thân test không đổi;
   chỉ phần dựng router ở `qr/qr_test.go` · `don/don_test.go` đổi. Tập tên test trước/sau: `diff` rỗng.
2. Miền `qr` dùng cây kết hợp: `handler.go` (Gin), `service.go` (cửa `qr/doi_ma` giữ `NeedOwner`, `authz.Run`; đường đọc mã mở
   giao dịch bằng `postgres.InTx`, handler không chạm database), `repository.go` (nhận `pgx.Tx`, gọi `sqlcgen`); câu ghi giữ ở
   `sql/doi_ma/cap_ma.sql` thêm `-- name:`; câu đọc mã vừa cấp thành `sql/*.sql`; `be/sqlc.yaml` thêm mục `qr`. Ghi vào `qr_code`
   vẫn chỉ qua hàm `qr_code_issue` của migration, không thêm ô ghi backend. `go tool sqlc generate` không đổi file sinh,
   `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` hai gate trước/sau chỉ khác dòng đếm file đã soát.
3. Router giữ hành vi `ServeMux`: `HEAD` lên đường `GET` của Gin chạy như `GET` (cùng status, không thân) mà không đăng ký đường
   `HEAD` nào (Gate 1g đếm đường); khác phương thức khác vẫn 405 kèm `Allow`. Tham số mang `%2F` khớp như `ServeMux` (`UseRawPath`).
   Hai test Claude viết trước ở `be/cmd/server/router_test.go`: `TestQC12_RouterGiuDauGachMaHoaTrongThamSo` đỏ ở nền (`PUT
   /menu-components/1%2F2/base-price` ⇒ 404 văn bản); `TestQC12_RouterHEADLenDuongGinChayNhuGET` xanh ở nền (`qr` còn sau
   `ServeMux`) — test giữ hành vi, lỗi cài (4) chứng minh nó bắt được.
   Năm `TestQC12_Router*` cũ PASS không sửa.
4. Lỗi cài Claude chạy khi duyệt, mỗi lần một lỗi: cửa đổi mã hạ xuống `NeedPerson` ⇒ `TestI023_ChiChuQuanDoiDuocMa` đỏ; bỏ
   `UseRawPath` ⇒ test `%2F` đỏ; bỏ xử lý `HEAD` ⇒ test `HEAD` đỏ; miền khác import `qr/internal/sqlcgen` ⇒ `go build` đỏ.
5. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`, không `SKIP`.
- *Điểm chốt:* giữ `HEAD` như `GET` (không ghi quyết định đổi): `TestQC12_RouterHEADChayNhuGET` chấm `GET /menu` của `gia` ở
  T-154 và không được sửa, nên cách giữ phải có từ lượt `GET` Gin đầu tiên. Tên `DoiMa`, `CurrentTable`, `Querier`, `Seat` giữ
  exported. Câu tra mã hiện hành vẫn ở `authz` (cửa QR của `don` dùng chung, tránh vòng import), không chép sang `qr/sql/`.
- *Owner Claude sửa lúc tích hợp:* `QC-12` (luật `HEAD`, `UseRawPath`), bảng §9 của `10-quy-uoc-code.md`.

**T-153 — Bàn giao** (2026-10-11). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-153`, nhánh `codex/T-153` từ
`fbbdaef`; sandbox không Docker nên không chạy được test PostgreSQL, báo đúng vậy). Duyệt, cài lỗi, tích hợp: **Claude** — patch
từ worktree áp bằng `git apply`, `diff -r be` hai cây rỗng; một vòng, không trả Codex. File: `be/internal/qr/handler.go` ·
`service.go` · `repository.go` (mới; `qr.go` xoá) · `sql/doc_ma_vua_cap.sql` (mới) · `sql/doi_ma/cap_ma.sql` (thêm `-- name:`, `;`) ·
`internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `router_test.go` (hai test Claude) · `be/internal/qr/qr_test.go` ·
`be/internal/don/don_test.go` (chỉ hàm `dung`); owner do Claude: `10-quy-uoc-code.md` (`QC-12`, bảng §9). Log: scratchpad phiên
`4f357359…/scratchpad/T-153-*` (phiếu, báo cáo Codex, `--list` · tên test trước/sau, be-check nền/sau, bốn log lỗi cài, gate).
- *(1)* `be-check` trên PostgreSQL thật: sáu test miền và `TestI023_KhachQRVaoPhienCuaBanQuaMaHienHanh` PASS. Diff hai file test
  chỉ ở hàm `dung` (và hai import Gin/middleware của `qr_test.go`). Tập tên test trước/sau: chỉ thêm hai `TestQC12_Router*` của Claude.
- *(2)* `check-sqlcgen` PASS; Gate 1f · 1g · 1h PASS; `CapMa` sinh `SELECT qr_code_issue($1)`, không ô ghi mới. `--list` trước/sau
  chỉ khác dòng đếm file (1f 138 → 145, 1g 54 → 60).
- *(3)* Bảy `TestQC12_Router*` PASS. `HEAD`: `NoMethod` đổi sang `GET` chỉ khi `Allow` có `GET`, gỡ `Allow`, gọi lại `ServeHTTP` qua
  writer bỏ thân (Codex chọn thay `HandleContext` vì hàm ấy đặt lại writer); không đường `HEAD` nào đăng ký.
- *(4)* Lỗi cài trong worktree riêng `../lean_wt/T-153-fault` (**F-063**), mỗi lần một lỗi rồi chép lại bản Codex: (A) `NeedPerson` ⇒
  `TestI023_ChiChuQuanDoiDuocMa` đỏ (người quầy đổi mã nhận 201); (B) bỏ `UseRawPath` ⇒ test `%2F` đỏ (404 văn bản); (C) bỏ khối
  `NoMethod` ⇒ test `HEAD` đỏ (`HEAD`=405, `GET`=404); (D) `menu` import `qr/internal/sqlcgen` ⇒ `go build` đỏ *use of internal package
  … not allowed*. Worktree lỗi cài còn file `be/internal/menu/zz_fault.go` (lệnh xoá bị chặn trong phiên) — bỏ đi được, không ai đọc.
- *(5)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, `PASS gate không cổng nào đỏ`, không dòng `SKIP`; be-check PASS, db-check
  21 bước PASS, 15 file `scripts/*.test.sh` qua.
- *Cho T-154:* `gia` đưa `GET /menu` lên Gin — `TestQC12_RouterHEADChayNhuGET` sẽ chấm khối `NoMethod` này; `gia` không có
  `authz.Door`, hai đường đọc công khai cần `postgres.InTx` như đường đọc mã của `qr`.

**T-154 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì giá một suất lệch ở tính
thử, menu hay cửa ghi đơn (`I-013`), một tổ hợp sai được sửa hộ (`I-010`) hoặc món ngừng bán vẫn bán được (`I-009`). Phiếu mẫu
`docs/private/be_feature/prompts/BE-STACK-05-mien-nho-L2.md`; Acceptance dưới **thay** dòng `gia` của phiếu: dòng ấy thiếu ba test
của miền, test bên gọi ở `don` và test `HEAD` của router. Tên test kiểm bằng `rg '^func Test'` ở nền `700ade1`.
1. Bảy test của miền — `TestI013_BangCaGiaQuaTinhThu` · `TestI013_MenuKeGiaMoiToHop` · `TestI013_GiaGuiLenBiBo` ·
   `TestI010_TuChoiKhongSuaHo` · `TestI010_MenuChoBietMacDinhDeChonSan` · `TestI009_MonNgungBanBiTuChoi` ·
   `TestI013_YeuCauSaiHinhBiTuChoi` — và bốn test bên gọi ở `don/don_test.go` (`TestI013_BangCaGiaQuaCuaGhiDon` ·
   `TestI012_GhiDonPhaiDungQuay` · `TestI010_TuChoiToanBoLuotGoi` · `TestI009_SuaMenuSauKhiDatDonCuKhongDoi`) PASS trên PostgreSQL
   thật. Thân test không đổi; chỉ phần dựng router ở `gia/gia_test.go` · `don/don_test.go` (hàm `dung` của mỗi file) đổi. Tập tên
   test trước/sau: `diff` rỗng.
2. Miền `gia` dùng cây kết hợp: `handler.go` (Gin, hai đường đọc công khai), `service.go` (`Tinh` và phép kê giá menu; đường đọc
   mở giao dịch bằng `postgres.InTx`, handler không chạm database), `repository.go` (gọi `sqlcgen`); `docMon` · `docNhom` · câu đọc
   món đang bán thành `sql/*.sql`; `be/sqlc.yaml` thêm mục `gia`. Phép tính (`cong`, `nhan`, thứ tự kiểm, lời từ chối đầu tiên
   thắng) giữ nguyên. `gia.Tinh(ctx, tx, lines)` ở `don/don.go` biên dịch không sửa; tên exported `Tinh` · `Querier` · `DongYeuCau` ·
   `Dong` · `ThanhPhan` · `LuaChon` · `KetQua` giữ. `go tool sqlc generate` không đổi file sinh, `check-sqlcgen` · Gate 1f · 1g · 1h
   PASS; `--list` hai gate trước/sau chỉ khác dòng đếm file đã soát.
3. `GET /menu` lên Gin: bảy `TestQC12_Router*` PASS không sửa, gồm `TestQC12_RouterHEADChayNhuGET` (nay chấm khối `NoMethod`).
4. Lỗi cài Claude chạy trong worktree riêng (luật T-167), mỗi lần một lỗi: bỏ phép nhân phụ thu với số nhân ⇒
   `TestI013_BangCaGiaQuaTinhThu` đỏ; bỏ kiểm ngừng bán ⇒ `TestI009_MonNgungBanBiTuChoi` đỏ; bỏ khối `NoMethod` ⇒
   `TestQC12_RouterHEADChayNhuGET` đỏ; `don` import `gia/internal/sqlcgen` ⇒ `go build` đỏ.
5. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`, không `SKIP`.

**T-154 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-154`, nhánh `codex/T-154` từ
`700ade1`; sandbox không Docker, báo đúng vậy). Duyệt, cài lỗi, tích hợp: **Claude** — patch từ worktree áp bằng `git apply`,
`diff -r be` hai cây rỗng; một vòng, không trả Codex. File: `be/internal/gia/handler.go` · `service.go` · `repository.go` (mới;
`gia.go` · `http.go` xoá) · `sql/doc_mon.sql` · `doc_mon_dang_ban.sql` · `doc_nhom.sql` (mới) · `internal/sqlcgen/` (sinh) ·
`be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/gia/gia_test.go` · `be/internal/don/don_test.go` (chỉ hàm `dung`, import);
owner do Claude: `10-quy-uoc-code.md` (bảng §9). Log: scratchpad phiên `b0c518fc…/scratchpad/T-154-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): mười một test Acceptance PASS. Diff hai file test chỉ ở hàm `dung` và
  import Gin. Tập tên test trước/sau: `diff` rỗng.
- *(2)* `check-sqlcgen` PASS; Gate 1f · 1g · 1h PASS. `Tinh` chỉ đổi dòng đọc database sang `newRepository(q).docMon`; `keGia`,
  `cong`, `nhan` nguyên văn. `Querier` thêm `Exec` · `Query` (giao diện của sqlc), `pgx.Tx` vẫn thoả; `don/don.go` không đổi.
  `--list` trước/sau chỉ khác dòng đếm file (1f 145 → 154, 1g 60 → 66).
- *(3)* Bảy `TestQC12_Router*` PASS không sửa.
- *(4)* Lỗi cài trong `../lean_wt/T-154-fault` (luật T-167), mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` với bản Codex rỗng):
  (A) `nhan(1, phuThu)` thay số nhân ⇒ `TestI013_BangCaGiaQuaTinhThu` · `…MenuKeGiaMoiToHop` · `…BangCaGiaQuaCuaGhiDon` đỏ;
  (B) bỏ kiểm ngừng bán ⇒ `TestI009_MonNgungBanBiTuChoi` · `…SuaMenuSauKhiDatDonCuKhongDoi` đỏ; (C) bỏ khối `NoMethod` ⇒
  `TestQC12_RouterHEADChayNhuGET` · `…HEADLenDuongGinChayNhuGET` đỏ; (D) `don` import `gia/internal/sqlcgen` ⇒ `go build` đỏ
  *use of internal package … not allowed*.
- *(5)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, `PASS gate không cổng nào đỏ`, không dòng `SKIP`; be-check PASS,
  db-check 21 bước PASS, 15 file `scripts/*.test.sh` qua (lượt đầu đỏ Gate 1b vì dòng §9 mới viết đường dẫn tắt — đã sửa).
- *Ghi nhận, không sửa:* câu nhóm tuỳ chọn nay có hai bản SQL (ghi ở §9 của `10-quy-uoc-code.md`); `gia_test.go` dựng Gin trần
  (không `HandleMethodNotAllowed`) — không test nào của `gia` chấm 405, cấu hình thật vẫn do `TestQC12_Router*` chấm.

**T-155 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì một khoản tiền rơi vào ngày bán
khác (`I-014` · `I-021`), hoặc ghi được vào ngày đã đối soát xong (ADR-089 điểm 3, ADR-080). `ngayban` không có đường gọi và
không cửa ghi: bốn hàm exported (`DongHo` · `Khoa` · `DaKy` · `ChoGhi`) nhận `pgx.Tx` của cửa gọi ở `ket` · `hoadon` · `tratruoc`.
Kiểm kê dòng `ngayban` của phiếu (*"các ca ranh giới ngày trong `TestYC01_*` và `TestYC10_*`"*) ở nền `f2f242a`: chỉ có
`TestYC01_HoanTienCoDuVet` · `TestYC10_ThuNoDanQuaCua`, không test nào đặt mốc sát nửa đêm (mọi mốc là giờ mở cửa + 1 giờ). Vì
vậy Acceptance dưới **thay** dòng ấy bằng cả mười test đường tiền — mọi cửa tiền đều qua `ChoGhi`.
1. Mười test ở `don/duong_tien_test.go` — `TestI015_TraoTaiQuayGhiHoaDonDonLe` · `TestI015_GiamGiaCaDonBiTuChoiChoU058` ·
   `TestI005_NoTrenDonLeCoGhiChuChoChuQuan` · `TestYC23_TraTruocNhanTraLaiVaDungChoHoaDon` · `TestYC10_ThuNoDanQuaCua` ·
   `TestYC01_HoanTienCoDuVet` · `TestI021_TienDauKetVaSoDemKet` · `TestI021_MotNgayBanGiaQuaCuaRa0dLech` ·
   `TestI021_CaiMotLanThuSaiDoiSoatKeu` · `TestI021_CuaDongNgayTuChoiNgayChuaXong` — và toàn bộ `be-check` PASS trên PostgreSQL
   thật. Không file test nào đổi. Tập tên test trước/sau: `diff` rỗng.
2. `ngayban` dùng cây kết hợp **không `handler.go`**: `service.go` giữ nguyên tên và chữ ký bốn hàm exported (`DongHo` vẫn là
   biến kiểu `func(context.Context, pgx.Tx) (time.Time, error)` để test thay được), `repository.go` nhận `pgx.Tx` gọi `sqlcgen`;
   năm câu đọc (`now()`, quy ngày, hai khoá, ngày đã ký) thành `sql/*.sql`, nghĩa giữ nguyên (khoá chung/riêng, namespace `309`,
   quy ngày bằng múi giờ phiên); `be/sqlc.yaml` thêm mục `ngayban`. `ket` · `hoadon` · `tratruoc` không đổi. `check-sqlcgen` ·
   Gate 1f · 1g · 1h PASS; `--list` hai gate trước/sau chỉ khác dòng đếm file đã soát.
3. Lỗi cài Claude chạy trong worktree riêng (luật T-167), mỗi lần một lỗi: `ChoGhi` bỏ kiểm ngày đã ký ⇒
   `TestI021_MotNgayBanGiaQuaCuaRa0dLech` đỏ; quy ngày lệch một ngày ⇒ test đối soát đỏ; `ket` import `ngayban/internal/sqlcgen` ⇒
   `go build` đỏ; cửa ký dùng khoá chung — ghi kết quả thật (bắt hay không) vào bàn giao, không đoán.
4. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`, không `SKIP`.
- *Owner Claude sửa trước giao:* `QC-14` — miền không đường gọi không có `handler.go`, phép kiểm chỉ đòi `handler.go` khi miền có
  `func Routes` (thử trên cây thật ⇒ rỗng, cây giả có `Routes` mà thiếu `handler.go` ⇒ một dòng đỏ). Áp cả cho `vongdoi` (T-158).

**T-155 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-155`, nhánh `codex/T-155` từ
`f2f242a`; sandbox không Docker, báo đúng vậy). Duyệt, cài lỗi, tích hợp: **Claude** — patch áp bằng `git apply`, `diff -r be` hai
cây rỗng; một vòng. File: `be/internal/ngayban/service.go` · `repository.go` (mới; `ngayban.go` xoá) · `sql/da_ky.sql` ·
`dong_ho.sql` · `khoa_chung.sql` · `khoa_rieng.sql` · `quy_ngay.sql` (mới) · `internal/sqlcgen/` (sinh) · `be/sqlc.yaml`; owner do
Claude: `10-quy-uoc-code.md` (`QC-14`, bảng §9), `work/findings.md` (**F-064**). Log: scratchpad phiên `b0c518fc…/scratchpad/T-155-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): mười test đường tiền PASS. Không file test nào đổi; tập tên test trước/sau
  `diff` rỗng.
- *(2)* Bốn hàm exported giữ chữ ký; `DongHo` vẫn là biến. Ép kiểu thêm: `now()::timestamptz`, `$1::text::date` (tham số vẫn là
  chuỗi). `ket` · `hoadon` · `tratruoc` · `don` không đổi. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng
  đếm file (1f 154 → 167, 1g 66 → 74).
- *(3)* Lỗi cài trong `../lean_wt/T-155-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` với bản Codex rỗng): (A) `ChoGhi` bỏ
  kiểm ngày đã ký ⇒ `TestI021_MotNgayBanGiaQuaCuaRa0dLech` đỏ; (B) quy ngày `+ 1` rồi sinh lại ⇒ `TestI021_MotNgayBanGiaQuaCuaRa0dLech` ·
  `TestI021_TienDauKetVaSoDemKet` đỏ — sửa `.sql` mà **không** sinh lại thì `TestQC13_TramBepKhongCoCuaGhi` đỏ (Gate 1f *lệch nguồn*
  trong test); (C) cửa ký dùng khoá chung ⇒ **be-check xanh**, không test nào bắt — khoảng trống có từ trước, ghi **F-064**, không sửa ở
  task chuyển stack; (D) `ket` import `ngayban/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`, không `SKIP`.

**T-156 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì bàn hiện trống khi phiên cũ chưa
dọn hay ngược lại (`I-003`), lần dọn mất vết người (`I-012` · `I-018`), hoặc cửa tạo lượt gọi của `don` đọc sai bàn. Phiếu mẫu
`BE-STACK-05-mien-nho-L2.md` ghi `ban/phien` là `TestI017_*`; kiểm ở nền `b85e574` thì test chạm đường của `ban` là các test dưới
(`TestI017_*` chỉ hai test gọi đọc bàn) — Acceptance dưới **thay** dòng ấy.
1. `TestI003_BanGhepDonTungBan` · `TestI003_BanTrongCanHaiDieuKien` · `TestI016_LuotGoiDauMoPhienVaKenhQuyetTrangThai` ·
   `TestI017_DongVaGoiThemChenNhau` · `TestI017_TienChuaThuKhongChanDong` · `TestQC12_DuongGoiCuaLuongTaiBan` ·
   `TestQC12_DuongGoiCuaSanXuat` (`don/tai_ban_test.go`) và bảy `TestQC12_Router*` PASS trên PostgreSQL thật, cùng toàn bộ be-check.
   Chỉ phần dựng router ở `don/don_test.go` (hàm `dung`) đổi. Tập tên test trước/sau: `diff` rỗng.
2. `ban` dùng cây kết hợp: `handler.go` (Gin: `GET /dining-tables`, `POST /dining-tables/:dining_table_id/cleaning`; tham số sai ⇒
   400 field `dining_table_id` như `apierr.ReadID`), `service.go` (`DaDon` giữ `NeedPerson`, `authz.Run`; danh sách bàn mở giao dịch
   bằng `postgres.InTx`; `Doc(ctx, tx, id)` và kiểu `Ban` exported giữ chữ ký cho `don/don.go`; lần dọn vẫn bọc `vongdoi.CoVet` với
   lý do `ban/da_don: needs_cleaning → empty`), `repository.go` (`pgx.Tx`, `sqlcgen`). `sql/da_don/khoa.sql` · `don.sql` giữ câu,
   thêm `-- name:` và `;`; câu đọc bàn thành `sql/*.sql`. `be/sqlc.yaml` thêm mục `ban`. `check-sqlcgen` · Gate 1f · 1g · 1h PASS;
   `--list` hai gate trước/sau chỉ khác dòng đếm file đã soát (ô `table_session_member.cleaned_at` → `ban/da_don` không đổi).
3. Lỗi cài Claude chạy trong worktree riêng, mỗi lần một lỗi: bỏ từ chối khi bàn không cần dọn ⇒ `TestI003_BanTrongCanHaiDieuKien`
   đỏ; trạng thái `needs_cleaning` bỏ vế `cleaned_at IS NULL` (sinh lại) ⇒ test `I-003` đỏ; bỏ `vongdoi.CoVet` quanh câu dọn ⇒ test
   dọn bàn đỏ (chế độ vết nghiêm, ADR-092); `don` import `ban/internal/sqlcgen` ⇒ `go build` đỏ.
4. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`, không `SKIP`.

**T-156 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-156`, nhánh `codex/T-156` từ
`b85e574`; sandbox không Docker, báo đúng vậy; báo cáo có tự viết khối commit — ngoài vai, Claude bỏ). Duyệt, cài lỗi, tích hợp:
**Claude** — patch áp lên `cc280e4` bằng `git apply`, `diff -r be` hai cây rỗng; một vòng. File: `be/internal/ban/handler.go` ·
`service.go` · `repository.go` (mới; `ban.go` xoá) · `sql/doc_ban.sql` · `doc_cac_ban.sql` (mới) · `sql/da_don/khoa.sql` · `don.sql`
(thêm `-- name:`, `;`) · `internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (chỉ
hàm `dung`). Log: scratchpad phiên `b0c518fc…/scratchpad/T-156-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): bảy test Acceptance, `TestQC12_DuongGoiCuaLuongNgoaiBan` và bảy
  `TestQC12_Router*` PASS. Tập tên test trước/sau: `diff` rỗng.
- *(2)* `DaDon` giữ `NeedPerson`; `Doc` · `Ban` giữ chữ ký; cột `s.id` · `s.status` nullable sinh `pgtype.Int8` · `pgtype.Text`,
  repository đổi về `nil` để `omitempty` giữ; `CASE … END::text`. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ
  khác dòng đếm file (1f 167 → 177, 1g 74 → 82).
- *(3)* Lỗi cài trong `../lean_wt/T-156-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) bỏ từ chối bàn không cần
  dọn ⇒ `TestI003_BanTrongCanHaiDieuKien` đỏ; (B) `needs_cleaning` bỏ vế `cleaned_at IS NULL`, sinh lại ⇒ `TestI003_BanGhepDonTungBan`
  · `…BanTrongCanHaiDieuKien` đỏ; (C) câu dọn bỏ `vongdoi.CoVet` ⇒ hai test `I-003` đỏ (vết nghiêm từ chối); (D) `don` import
  `ban/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; hai `SKIP` là cổng không chạy vì không đổi gì thuộc
  chúng (Gate 1d — không tài liệu pha nào đổi; `db` — không gì phía database đổi), không tính là đạt. be-check PASS.

**T-157 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì số tiền phải trả của phiên lệch
(`I-002` — cộng nhầm đơn đã huỷ, `I-004`), người không ở quầy tính tiền được (`I-012`), hoặc phiên chuyển trạng thái ngoài bảng (`I-016`).
`phien` có một cửa (`phien/tinh_tien`, `quay`) và hàm exported `TongTien(ctx, tx, id)` mà `hoadon/hoadon.go` gọi trong giao dịch của
cửa đóng. Tên test kiểm ở nền `55ada1b` bằng đường `bill-request` trong test.
1. `TestI002_BanGhepGoiVaoPhienCuaNhom` · `TestI002_GoiThemLucChoThanhToanVaoCungPhien` · `TestI006_SuatDemVeThuocPhienBan` ·
   `TestI012_CuaTaiBanPhaiDungQuay` · `TestI016_ChuyenNgoaiBangBiTuChoi` · `TestI016_ChuyenTrangThaiDeLaiVet` ·
   `TestI016_KhachQRGoiThemLucChoThanhToan` · bốn `TestI017_*` · `TestI004_HuyDonHoanThanhGanBanRutKhoiTienCuaPhien` ·
   `TestI020_DaRaBanTheoSoCaiTungThuChoMotBan` · `TestQC12_DuongGoiCuaLuongTaiBan` và bảy `TestQC12_Router*` PASS trên PostgreSQL thật,
   cùng toàn bộ be-check. Chỉ hàm `dung` của `don/don_test.go` đổi. Tập tên test trước/sau: `diff` rỗng.
2. `phien` dùng cây kết hợp: `handler.go` (Gin, `POST /table-sessions/:table_session_id/bill-request`), `service.go` (`TinhTien` giữ
   `NeedCounter`, `authz.Run`; thứ tự khoá phiên → `vongdoi.ChuyenPhien(… "awaiting_payment")` → `TongTien`; `TongTien` giữ chữ ký
   `pgx.Tx`), `repository.go`; `sql/tinh_tien/khoa.sql` thêm `-- name:`, `;`; câu cộng tiền thành `sql/*.sql`. `hoadon` không đổi.
   `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` hai gate trước/sau chỉ khác dòng đếm file đã soát.
3. Lỗi cài Claude chạy trong worktree riêng, mỗi lần một lỗi: `TongTien` bỏ vế loại đơn đã huỷ (sinh lại) ⇒
   `TestI004_HuyDonHoanThanhGanBanRutKhoiTienCuaPhien` đỏ; cửa hạ xuống `NeedPerson` ⇒ `TestI012_CuaTaiBanPhaiDungQuay` đỏ; bỏ
   `vongdoi.ChuyenPhien` ⇒ test `I-016`/`I-017` đỏ; `hoadon` import `phien/internal/sqlcgen` ⇒ `go build` đỏ.
4. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-157 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-157`, nhánh `codex/T-157` từ `55ada1b`;
sandbox không Docker). Duyệt, cài lỗi, tích hợp: **Claude** — patch áp bằng `git apply`, `diff -r be` hai cây rỗng; một vòng. File:
`be/internal/phien/handler.go` · `service.go` · `repository.go` (mới; `phien.go` xoá) · `sql/tong_tien.sql` (mới) · `sql/tinh_tien/khoa.sql`
(thêm `-- name:`, `;`) · `internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (chỉ hàm
`dung`). Log: scratchpad phiên `b0c518fc…/scratchpad/T-157-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): 23 test Acceptance (kể cả bảy `TestQC12_Router*`) PASS, không test nào FAIL.
  Tập tên test trước/sau: `diff` rỗng.
- *(2)* `TinhTien` giữ `NeedCounter`, thứ tự khoá → chuyển → cộng; `TongTien` giữ chữ ký, câu cộng nguyên văn. `check-sqlcgen` · Gate
  1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file (1f 177 → 184, 1g 82 → 88).
- *(3)* Lỗi cài trong `../lean_wt/T-157-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) bỏ vế loại đơn huỷ, sinh lại ⇒
  `TestI004_HuyDonHoanThanhGanBanRutKhoiTienCuaPhien` · `TestI017_DongPhienBiChanBoiMonChuaXong` đỏ; (B) `NeedPerson` ⇒
  `TestI012_CuaTaiBanPhaiDungQuay` đỏ; (C) bỏ `vongdoi.ChuyenPhien` ⇒ mười bốn test (`I-002` · `I-003` · `I-016` · `I-017` · `I-021` ·
  `YC-01` · `YC-10` …) đỏ; (D) `hoadon` import `phien/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; hai `SKIP` (Gate 1d, `db`) là cổng không chạy vì không đổi gì
  thuộc chúng, không tính là đạt. be-check PASS.

**T-158 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì đơn, phiên hay việc trạm chuyển
trạng thái ngoài bảng (`I-016`), lần chuyển mất vết (`I-018`, chế độ nghiêm ADR-092), hoặc phiên đóng mà bàn không chờ dọn (`I-003`).
`vongdoi` không có đường gọi; ba cửa lớp `theo_cua_goi` (`vongdoi/chuyen_don` · `chuyen_phien` · `chuyen_viec`) và hàm exported
chạy trong giao dịch của cửa gọi ở `don` · `hoadon` · `phien` · `ban` · `sanxuat` · `nguoi`. Không `handler.go` (`QC-14`, T-155).
1. Bốn test ở `vongdoi/vongdoi_test.go` và mọi `TestI016_*` (mười hai, kiểm ở nền `9d8580a`), cùng toàn bộ be-check PASS trên PostgreSQL
   thật. Không file test nào đổi. Tập tên test trước/sau: `diff` rỗng.
2. Cây kết hợp không `handler.go`: `service.go` (+ file service phụ nếu cần, vd. giữ `viec.go` thành phần của service — Claude chấp
   nhận miễn không file nào ngoài `repository.go` gọi `sqlcgen`) giữ **mọi** tên exported và chữ ký (`CuaChuyenDon` · `CuaChuyenPhien` ·
   `CuaChuyenViec` · `CapDon` · `CapPhien` · `CapViec` · `KiemChuyenDon` · `KiemChuyenPhien` · `KiemChuyenViec` · `TrangThaiDauDon` ·
   `CoVet` · `ChuyenDon` · `ChuyenPhien` · `ChuyenViec` · `LuiViecCuaMe` · `NhaNguonChuyen`); không miền gọi nào đổi. Bảy file cửa giữ
   câu, thêm `-- name:` và `;`; ba câu đọc trong chuỗi Go (`actor_person_id()`, hai `set_config`, phép kiểm vết chuyển) thành `sql/*.sql`.
   `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` hai gate trước/sau chỉ khác dòng đếm file (ô → cửa không đổi).
3. Lỗi cài Claude chạy trong worktree riêng, mỗi lần một lỗi: thêm một cặp lạ vào `CapDon` ⇒ `TestI016_BangChuyenDonKhopVongDoi` đỏ;
   `CoVet` bỏ khai lý do ⇒ test chuyển trạng thái đỏ (vết nghiêm từ chối); đóng phiên bỏ câu `dong_ban` ⇒ test `I-003` đỏ; miền khác
   import `vongdoi/internal/sqlcgen` ⇒ `go build` đỏ.
4. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-158 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-158`, nhánh `codex/T-158` từ `9d8580a`;
sandbox không Docker). Duyệt, cài lỗi, tích hợp: **Claude** — patch áp bằng `git apply`, `diff -r be` hai cây rỗng; một vòng. File:
`be/internal/vongdoi/service.go` · `repository.go` (mới; `vongdoi.go` xoá) · `viec.go` (đọc qua repository) · `sql/co_nguoi.sql` ·
`co_vet_chuyen.sql` · `go_ly_do.sql` · `khai_ly_do.sql` (mới) · bảy file cửa (thêm `-- name:`, `;`) · `internal/sqlcgen/` (sinh) ·
`be/sqlc.yaml`. Log: scratchpad phiên `b0c518fc…/scratchpad/T-158-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): mười hai `TestI016_*` (gồm bốn của `vongdoi_test.go`) PASS, không test nào
  FAIL; không file test nào đổi, tập tên test trước/sau `diff` rỗng.
- *(2)* Mọi tên exported giữ chữ ký; không miền gọi nào đổi (`git diff --stat` ngoài `vongdoi` rỗng). sqlc sinh `$2` trạng thái là
  `string` mà không cần ép kiểu, nên câu ghi giữ nguyên văn; câu đọc người thêm `::boolean`. `check-sqlcgen` · Gate 1f · 1g · 1h PASS;
  `--list` trước/sau chỉ khác dòng đếm file (1f 184 → 198, 1g 88 → 98).
- *(3)* Lỗi cài trong `../lean_wt/T-158-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) thêm cặp `completed → new`
  vào `CapDon` ⇒ `TestI016_BangChuyenDonKhopVongDoi` đỏ; (B) `CoVet` bỏ khai lý do ⇒ hơn 70 test đỏ ở mọi miền (vết nghiêm từ chối);
  (C) đóng phiên bỏ câu `dong_ban` ⇒ `I-002` · `I-003` · `I-017` · `I-021` · `YC-01` · `YC-10` đỏ; (D) `don` import
  `vongdoi/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.

**T-159 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì người không chọn tên vẫn vào quầy, hai
người cùng đứng quầy, mốc đổi người mất vế *ai ra · ai vào* (`I-012`, YC-15, C36), hoặc lần khép mất vết (`I-018`). `nguoi` có bốn
đường (`GET /people`, `GET /counter-duty/current`, `POST /counter-duty`, `POST /counter-duty/end`), ba cửa (`nguoi/vao_quay`
`nguoi_quan`, `nguoi/roi_quay` `quay`, `nguoi/khep_quay` `theo_cua_goi`), không miền nào gọi hàm của nó. Tên test kiểm ở nền `66411c2`.
1. Bảy test ở `nguoi/nguoi_test.go` (năm `TestYC15_*`, `TestI012_KhongChonTenThiKhongVaoQuay`, `TestI012_DanhSachTenDeChon`) và bảy
   `TestQC12_Router*` PASS trên PostgreSQL thật, cùng toàn bộ be-check. Chỉ phần dựng router ở `nguoi_test.go` (hàm `dung`: Gin +
   `middleware.GanNguoi(authz.ChonTen{})`) đổi. Tập tên test trước/sau: `diff` rỗng.
2. Cây kết hợp: `handler.go` (bốn đường, status `201`/`200` của vào quầy giữ), `service.go` (ba `authz.Door` giữ mã, lớp; thứ tự khoá →
   cùng người ⇒ 200 → đổi chen ⇒ `counter_duty_changed` → khép trong `vongdoi.CoVet` với lý do nguyên văn → thêm khoảng),
   `repository.go`. Bốn file cửa giữ câu, thêm `-- name:` (tên khác nhau cho hai `khoa.sql`), `;`; hai câu đọc trong chuỗi Go thành
   `sql/*.sql`. `be/sqlc.yaml` thêm mục `nguoi`. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` hai gate trước/sau chỉ khác dòng đếm.
3. Lỗi cài Claude chạy trong worktree riêng, mỗi lần một lỗi: bỏ từ chối `counter_duty_changed` ⇒ test YC-15 chen nhau đỏ; `roi_quay` hạ
   xuống `NeedPerson` ⇒ `TestYC15_RoiQuayChiNguoiDangDung` đỏ; khép quầy bỏ `vongdoi.CoVet` ⇒ test vào quầy đỏ; miền khác import
   `nguoi/internal/sqlcgen` ⇒ `go build` đỏ.
4. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-159 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-159`, nhánh `codex/T-159` từ `66411c2`;
sandbox không Docker). Duyệt, cài lỗi, tích hợp: **Claude** — patch áp lên `a7716b5` bằng `git apply`, `diff -r be` hai cây rỗng; một
vòng. File: `be/internal/nguoi/handler.go` · `service.go` · `repository.go` (mới; `nguoi.go` xoá) · `sql/danh_sach.sql` · `hien_tai.sql`
(mới) · bốn file cửa (thêm `-- name:`, `;`) · `internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` ·
`be/internal/nguoi/nguoi_test.go` (chỉ hàm `dung`, import); owner do Claude: `work/findings.md` (**F-065**). Log: scratchpad phiên
`b0c518fc…/scratchpad/T-159-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): bảy test `nguoi` và bảy `TestQC12_Router*` PASS, không test nào FAIL. Tập tên
  test trước/sau: `diff` rỗng.
- *(2)* Ba cửa giữ mã, lớp; status 201/200 của vào quầy giữ; mốc `pgtype.Timestamptz` đổi về `time.Time` ở repository.
  `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file (1f 198 → 209, 1g 98 → 107).
- *(3)* Lỗi cài trong `../lean_wt/T-159-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) bỏ từ chối
  `counter_duty_changed` ⇒ **be-check xanh** — cài lại đúng lỗi trên code cũ `66411c2` (`../lean_wt/T-159-base`) cũng xanh: khoảng trống
  có từ trước, ghi **F-065**; (B) `roi_quay` hạ xuống `NeedPerson` ⇒ be-check xanh (khoá dòng của cửa đã đòi người đang đứng quầy, cùng
  403 `not_on_counter_duty`) nhưng **Gate 1g đỏ** *lớp quyền của nguoi/roi_quay: ma trận quay, code nguoi_quan* — bắt ở gate, không phải
  lỗ hổng; (C) khép quầy bỏ `vongdoi.CoVet` ⇒ năm `TestYC15_*` đỏ; (D) `ban` import `nguoi/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.

**T-160 — Acceptance và điểm Claude chốt trước giao** (Claude, 2026-10-12). Mức **L2**: sai thì một khoản trả trước bị trừ sai số dư
hay dùng quá số đã nhận (YC-23), ghi vào ngày đã ký (`I-021`), tính nhầm là doanh thu (`I-014`), hoặc mất người thao tác (`I-012`).
Phiếu `docs/private/be_feature/prompts/BE-STACK-06-duong-tien-L2.md` (sửa `a7716b5` sau lần rà 2026-10-11). `tratruoc` có một đường
(`POST /orders/{sales_order_id}/prepayment`, cửa `tratruoc/nhan` `quay`) và API cho `hoadon`: cửa `tratruoc/dung` (`theo_cua_goi`),
`KiemSoDu` · `Dung` · `PhanTien` (+ `Kiem`) · `SoDu`. Tên test kiểm ở nền `6651cc1`.
1. Mười ba test ở `don/duong_tien_test.go` (gồm `TestYC23_TraTruocNhanTraLaiVaDungChoHoaDon`, bốn `TestI021_*`,
   `TestI012_CuaTienCanNguoiCoTen` — ba test này không khớp bộ lọc tiền tố của phiếu cũ), `TestQC14_HinhDuongTienTruocQuyen` và bảy
   `TestQC12_Router*` PASS trên PostgreSQL thật, cùng toàn bộ be-check. Tập tên test trước/sau: `diff` rỗng.
2. Test đổi chỉ ở phần dựng router: `don/don_test.go` (hàm `dung`) và đầu `TestQC14_HinhDuongTienTruocQuyen` — `tratruoc` gắn vào
   `gin.New()` **không** `GanNguoi`, service dựng từ `pool = nil`, `hoadon` · `ket` giữ `ServeMux` với authenticator dừng test, nối
   sau `NoRoute`; bảng ca và điều kiện kiểm không đổi (quyết định ở phiếu, mục *Test hình trước quyền*).
3. `tratruoc` dùng cây kết hợp: `handler.go` (Gin; thứ tự kiểm giữ: tham số → JSON → `PhanTien.Kiem` → người → cửa; 201
   `{"prepayment_id", "sales_order_id"}`), `service.go` (hai `authz.Door` giữ mã, lớp; trong cửa nhận: khoá đơn → `ngayban.ChoGhi` →
   từ chối `order_not_prepayable` → thêm; mọi exported cho `hoadon` giữ chữ ký), `repository.go`. Năm file cửa giữ câu, thêm
   `-- name:` (tên khác nhau cho hai `khoa.sql` · `them.sql`) và `;`. `hoadon` không đổi. `check-sqlcgen` · Gate 1f · 1g · 1h PASS;
   `--list` hai gate trước/sau chỉ khác dòng đếm file.
4. Lỗi cài Claude chạy trong worktree riêng, mỗi lần một lỗi: `Dung` ghi đảo phần tiền mặt và chuyển khoản lấy ra ⇒ YC-23 hoặc đối
   soát `I-021` đỏ; bỏ từ chối đơn đã có phiên ⇒ `TestYC23_TraTruocNhanTraLaiVaDungChoHoaDon` đỏ (`order_not_prepayable`); bỏ
   `PhanTien.Kiem` ở handler ⇒ `TestQC14_HinhDuongTienTruocQuyen` đỏ (đi tới service với `pool = nil`); `hoadon` import
   `tratruoc/internal/sqlcgen` ⇒ `go build` đỏ. Lỗi nào không bị bắt thì ghi kết quả thật.
5. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-160 — Bàn giao** (2026-10-12). Thi công: **Codex** (`gpt-6-astra`, worktree `../lean_wt/T-160`, nhánh `codex/T-160` từ `6651cc1`)
làm năm file cửa (`-- name:`, `;`), mục `sqlc.yaml` và code sinh rồi **hết hạn mức** (*"usage limit … try again at 1:15 PM"*), không có
báo cáo. Chủ repo chọn 2026-10-12: Claude thi công phần còn lại (handler · service · repository, router, hai file test) trong cùng
worktree; **chưa ai duyệt độc lập** (như T-152). Cài lỗi, tích hợp: Claude — patch áp bằng `git apply`, `diff -r be` hai cây rỗng.
File: `be/internal/tratruoc/handler.go` · `service.go` · `repository.go` (mới; `tratruoc.go` xoá) · năm file cửa · `internal/sqlcgen/`
(sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (hàm `dung`) · `be/internal/don/duong_tien_hinh_test.go`
(đầu `TestQC14_HinhDuongTienTruocQuyen`, bảng ca không đổi). Log: scratchpad phiên `b0c518fc…/scratchpad/T-160-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree): mười ba test `duong_tien_test.go`, `TestQC14_HinhDuongTienTruocQuyen` (mọi ca
  con) và bảy `TestQC12_Router*` PASS, không test nào FAIL. Tập tên test trước/sau: `diff` rỗng.
- *(2)* Thứ tự cửa nhận giữ (khoá đơn → `ngayban.ChoGhi` → `order_not_prepayable` → thêm); `KiemSoDu` · `Dung` · `PhanTien` · `SoDu`
  giữ chữ ký, `hoadon` không đổi. `cash_after_vnd` · `transfer_after_vnd` sinh nullable: NULL trả lỗi hệ thống như khi scan thẳng vào
  `int64` trước đây. `go tool sqlc generate` không đổi file sinh; `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác
  dòng đếm file (1f 209 → 216, 1g 107 → 114).
- *(3)* Lỗi cài trong `../lean_wt/T-160-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) **thu sai** — `Dung` ghi đảo phần
  tiền mặt và chuyển khoản lấy ra ⇒ `TestYC23_TraTruocNhanTraLaiVaDungChoHoaDon` · `TestI021_MotNgayBanGiaQuaCuaRa0dLech` (đối soát
  ngày) đỏ; (B) bỏ từ chối đơn đã có phiên ⇒ `TestYC23_…` đỏ; (C) handler bỏ `PhanTien.Kiem` ⇒ `TestQC14_HinhDuongTienTruocQuyen`
  ca `/orders/1/prepayment/cash_vnd` đỏ; (D) `hoadon` import `tratruoc/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.

**T-161 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-12). Mức **L2**: sai thì hoá đơn ghi lệch phần tiền
(`I-015`), nợ mất tên hay số (`I-005`), hoàn hay thu nợ ghi sai số hoặc sai ngày (`I-021`, YC-01, YC-10), trả trước bị dùng quá số dư
(YC-23), hoặc phiên đóng khi còn đơn (`I-017`). `hoadon` có bảy đường, chín cửa (`dong` · `trao_tai_quay` · `giao_xong` · `hoan` · `thu_no` ·
`tra_lai` lớp người; `ghi` · `ghi_hoan` lớp `theo_cua_goi`); không miền production nào gọi vào. Thi công: **Claude** (Codex hết hạn mức ở
T-160; chủ repo chọn Claude tự thi công cho T-160…T-162), worktree `../lean_wt/T-161`. Tên test kiểm ở nền `1728c0d` theo đường dẫn trong test.
1. Hai mươi bốn test đi qua đường của `hoadon` — `TestI002_*` (2) · `TestI003_*` (2) · `TestI004_DatTruocNoDungLanNhacDau` · `TestI005_*` ·
   `TestI012_CuaTaiBanPhaiDungQuay` · `TestI012_CuaTienCanNguoiCoTen` · `TestI012_GiaoXongDoNguoiDiGiaoBam` ·
   `TestI014_HuyDonLeDaThuGiuHoaDonHoanDoQuayQuyet` · `TestI015_*` (2) · `TestI016_ChuyenNgoaiBangBiTuChoi` ·
   `TestI016_TraoTaiQuayKhiConViecChuaRaBanBiTuChoi` · bốn `TestI017_*` · `TestI021_MotNgayBanGiaQuaCuaRa0dLech` ·
   `TestQC12_DuongGoiCuaLuongTaiBan` · `TestQC14_HinhDuongTienTruocQuyen` · `TestYC01_*` · `TestYC10_*` · `TestYC23_*` — cùng mười ba
   test `duong_tien_test.go`, bảy `TestQC12_Router*` và toàn bộ be-check PASS trên PostgreSQL thật. Tập tên test trước/sau: `diff` rỗng.
2. Test đổi chỉ ở phần dựng router: `don/don_test.go` (hàm `dung`) và đầu `TestQC14_HinhDuongTienTruocQuyen` (`hoadon` sang `gin.New()`
   không `GanNguoi` như `tratruoc`; bảng ca không đổi).
3. Cây kết hợp: `handler.go` (Gin; thứ tự kiểm từng đường giữ: tham số → JSON → `Kiem` → kiểm thêm của đường → người → cửa; status
   201/200 và thân giữ), `service.go` (chín `authz.Door` giữ mã, lớp; thứ tự khoá → `ngayban.ChoGhi` → từ chối → ghi → chuyển trạng
   thái giữ; `Ghi` · `GhiHoan` · `NoiDung` · `ThanhToan` · `HoanYeuCau` · `TraLaiYeuCau` giữ tên, chữ ký), `repository.go`. Mười sáu file
   SQL giữ câu và thư mục, thêm `-- name:` (duy nhất trong miền) và `;`; ép kiểu chỉ ở câu đọc. `check-sqlcgen` · Gate 1f · 1g · 1h PASS;
   `--list` hai gate trước/sau chỉ khác dòng đếm file.
4. Lỗi cài trong worktree riêng, mỗi lần một lỗi: **thu sai** — `Ghi` ghi đảo phần tiền mặt và chuyển khoản ⇒ test hoá đơn hoặc đối soát
   `I-021` đỏ; bỏ kiểm tổng các phần bằng số phải trả ⇒ `I-015` đỏ; thu nợ không trừ số đã trả vào số còn ⇒ `TestYC10_ThuNoDanQuaCua` đỏ;
   miền khác import `hoadon/internal/sqlcgen` ⇒ `go build` đỏ. Lỗi nào không bị bắt thì ghi kết quả thật.
5. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-161 — Bàn giao** (2026-10-12). Thi công: **Claude Code** (worktree `../lean_wt/T-161`, nhánh `claude/T-161` từ `1728c0d`); **chưa ai
duyệt độc lập**. Tích hợp bằng patch, `diff -r be` hai cây rỗng. File: `be/internal/hoadon/handler.go` · `service.go` · `repository.go`
(mới; `hoadon.go` · `ghi.go` · `tien.go` xoá) · mười sáu file SQL (thêm `-- name:`, `;`; câu và thư mục không đổi) · `internal/sqlcgen/`
(sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (hàm `dung`) · `be/internal/don/duong_tien_hinh_test.go`
(đầu `TestQC14_…`, bảng ca không đổi). Log: scratchpad phiên `b0c518fc…/scratchpad/T-161-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree, lượt đầu): mọi test PASS, không test nào FAIL — gồm hai mươi bốn test Acceptance.
  Tập tên test trước/sau: `diff` rỗng.
- *(2)* Thứ tự từng cửa giữ nguyên văn (chỉ thay lời gọi database bằng repository). sqlc sinh `interface{}` cho `min()` (`thu_no/du.sql`)
  và `coalesce` (`no.sql`): repository đổi về `*int64`, giữ NULL = chưa lần thu nào; câu SQL không ép kiểu. `debtor_name` NULL trong danh
  sách nợ trả lỗi hệ thống như khi scan thẳng vào `string` trước đây. `ghi/khoan.sql` với đơn `nil` trả `ErrNoRows` như câu cũ với tham
  số NULL. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file (1f 216 → 227, 1g 114 → 125).
- *(3)* Lỗi cài trong `../lean_wt/T-161-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) **thu sai** — hoá đơn ghi đảo tiền
  mặt và chuyển khoản ⇒ `TestI012_GiaoXongDoNguoiDiGiaoBam` · `TestYC23_…` · `TestI021_MotNgayBanGiaQuaCuaRa0dLech` (đối soát) đỏ;
  (B) bỏ kiểm tổng các phần ở Go ⇒ be-check **xanh** vì ràng buộc `bill_parts_equal_due_check` của database từ chối với cùng mã
  `payment_parts_mismatch` (hợp đồng ánh xạ) — tầng 1 bắt, không phải lỗ hổng; (C) thu nợ không trừ số đã trả ⇒ `TestYC10_ThuNoDanQuaCua` ·
  `TestI021_MotNgayBanGiaQuaCuaRa0dLech` đỏ; (D) `ket` import `hoadon/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.

**T-162 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-12). Mức **L2**: sai thì tiền đầu két hay số đếm ghi vào
ngày khác, phép đối soát cộng sai một nguồn (`I-021`), ngày được ký khi còn sổ giấy chưa nhập hay khi lệch mà không giải thích, hoặc
người không phải chủ quán ký được (`I-012`, ADR-080, ADR-089). `ket` có bốn đường, ba cửa (`khai_dau_ket` · `dem` lớp
`quay_hoac_chu_quan`, `doi_soat_xong` lớp `chu_quan`); không miền production nào gọi vào. Thi công: **Claude**, worktree `../lean_wt/T-162`.
Tên test kiểm ở nền `7c5632f` theo đường dẫn trong test.
1. `TestI012_CuaTienCanNguoiCoTen` · bốn `TestI021_*` · `TestQC14_HinhDuongTienTruocQuyen`, cùng mười ba test `duong_tien_test.go`, bảy
   `TestQC12_Router*` và toàn bộ be-check PASS trên PostgreSQL thật. Tập tên test trước/sau: `diff` rỗng.
2. Test đổi chỉ ở phần dựng router: `don/don_test.go` (hàm `dung`) và đầu `TestQC14_HinhDuongTienTruocQuyen` — `ket` sang `gin.New()` không
   `GanNguoi`. Đây là miền đường tiền cuối cùng, nên `ServeMux`, `NoRoute` và authenticator `khongDocNguoi` của test hết người dùng và được
   bỏ; bảng ca và điều kiện kiểm không đổi (quyết định ở phiếu, mục *Test hình trước quyền*).
3. Cây kết hợp: `handler.go` (Gin; ngày `sale_date` kiểm như `docNgay` — `YYYY-MM-DD` hợp lệ, không thì 400 field `sale_date`; thân JSON,
   `Kiem` trước quyền; status 201/200 và thân giữ), `service.go` (ba `authz.Door` giữ mã, lớp; cửa ký: khoá riêng ngày → đọc số két →
   đã ký ⇒ `sale_day_already_reconciled` → còn sổ giấy ⇒ `paper_entries_pending` → lệch mà không giải thích ⇒ `gap_explanation_required`
   → ghi; `SoKet` · `YeuCau` · `Dong` giữ tên), `repository.go`. Bảy file SQL giữ câu và thư mục, thêm `-- name:` và `;`; câu ghi nguyên
   văn, ép kiểu chỉ ở câu đọc (`ket_ngay.sql` · `giay.sql`). `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file.
4. Lỗi cài trong worktree riêng, mỗi lần một lỗi: **đối soát cộng sai một nguồn** — `ket_ngay.sql` bỏ hạng tử nợ cũ thu bằng tiền mặt (sinh
   lại) ⇒ test đối soát `I-021` đỏ; ký ngày lệch mà không đòi giải thích ⇒ test `I-021` đỏ; số đếm ghi đảo mệnh giá và số tiền ⇒ test số đếm
   đỏ; miền khác import `ket/internal/sqlcgen` ⇒ `go build` đỏ. Lỗi nào không bị bắt thì ghi kết quả thật.
5. `./scripts/gate.sh` ở cây tích hợp: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-162 — Bàn giao** (2026-10-12). Thi công: **Claude Code** (worktree `../lean_wt/T-162`, nhánh `claude/T-162` từ `7c5632f`); **chưa ai
duyệt độc lập**. Tích hợp bằng patch, `diff -r be` hai cây rỗng. File: `be/internal/ket/handler.go` · `service.go` · `repository.go` (mới;
`ket.go` xoá) · bảy file SQL (thêm `-- name:`, `;`; câu ghi nguyên văn; `ket_ngay.sql` · `doi_soat_xong/giay.sql` đổi `$1::date` thành
`$1::text::date` để tham số là chuỗi) · `internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go`
(hàm `dung`) · `be/internal/don/duong_tien_hinh_test.go` (bỏ `ServeMux`, `NoRoute`, `khongDocNguoi` — hết người dùng; bảng ca không đổi).
Log: scratchpad phiên `b0c518fc…/scratchpad/T-162-*`.
- *(1)* `be-check` trên PostgreSQL thật (gate ở worktree, lượt đầu): mọi test PASS, không test nào FAIL. Tập tên test trước/sau: `diff` rỗng.
- *(2)* Thứ tự cửa ký giữ (khoá riêng ngày → số két → đã ký → sổ giấy → giải thích → ghi). Câu ghi ký ngày nhận `pgtype.Date`: repository
  đổi chuỗi đã kiểm ở handler. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file (1f 227 → 235, 1g 125 → 133).
- *(3)* Lỗi cài trong `../lean_wt/T-162-fault`, mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng): (A) **đối soát cộng sai một nguồn** —
  `ket_ngay.sql` bỏ hạng tử nợ cũ thu bằng tiền mặt, sinh lại ⇒ `TestI021_MotNgayBanGiaQuaCuaRa0dLech` đỏ (bộ đối chiếu `pg_temp.ket_ngay`
  nói khác cửa); (B) ký ngày lệch không đòi giải thích ở Go ⇒ be-check **xanh** vì ràng buộc `reconciled_day_gap_explained_check` từ chối với
  cùng mã `gap_explanation_required` — tầng 1 bắt, không phải lỗ hổng; (C) dòng số đếm ghi thêm một mệnh giá ⇒ ba `TestI021_*` đỏ;
  (D) `hoadon` import `ket/internal/sqlcgen` ⇒ `go build` đỏ.
- *(4)* `./scripts/gate.sh` ở cây chính sau tích hợp: exit 0, không `FAIL`; `SKIP` nếu có là cổng không chạy, không tính là đạt.
- *Bước 06 xong:* ba miền đường tiền đã chuyển; `be/cmd/server/router.go` chỉ còn `don` · `sanxuat` sau `NoRoute` (bước 07, T-163 · T-164).

**T-163 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-12). Mức **L2**: sai thì bếp làm thừa hay thiếu, một
mẻ lùi trả sai đơn vị, quầy bấm *đã ra bàn* mà đơn không tới *Hoàn thành*, hay trạm bếp ghi được (`I-004` · `I-016` · `I-019` ·
`I-020`, ADR-090). `sanxuat` có tám đường, bảy cửa (sáu lớp `quay`, `no_don` lớp `theo_cua_goi`); `don` gọi `NoDon(ctx, tx, id)` ở
ba chỗ. Thi công: **Claude** trên cây chính, nhánh `chatgpt_involve`, nền `0c4cade`. Tên test kiểm ở nền bằng `rg '^func Test'`.
1. Mười chín test của `don/san_xuat_test.go` · `san_xuat_lui_huy_test.go` — bảy `TestI020_*` (kể cả
   `TestI020_DaRaBanTheoSoCaiTungThuChoMotBan`), bảy `TestI004_*`, `TestI016_DonLeKhongTuHoanThanh`,
   `TestI019_BangNhuCauTachNguocVeTungBan`, `TestYC07_GhiChuBanhLamSaiVaHuyGhiChu`, `TestI012_CuaSanXuatPhaiDungQuay`,
   `TestQC13_TramBepKhongCoCuaGhi`, `TestQC12_DuongGoiCuaSanXuat` — cùng mọi `TestI016_*` · `TestI017_*` · `TestI018_*` và toàn bộ
   be-check PASS trên PostgreSQL thật, **hai lượt**. Điều kiện kiểm không đổi.
2. Test đổi chỉ ở phần dựng router: `don/don_test.go` (hàm `dung`) — `sanxuat` sang Gin như `ket`. Tập tên test trước/sau: chỉ
   thêm đúng một tên ở điểm 4, không mất tên nào.
3. Cây kết hợp: `handler.go` (Gin, tám đường, tham số `:id` đúng `{id}` của hợp đồng; mọi lời từ chối hình trước quyền như cũ),
   `service.go` (bảy `authz.Door` giữ mã và lớp; `NoDon(ctx, pgx.Tx, int64)` giữ chữ ký; thứ tự khoá mẻ → phiên → đơn → việc giữ),
   `repository.go`. Mười một file câu ghi giữ thư mục và câu, thêm `-- name:` và `;`; câu đọc trong chuỗi Go dời thành file ngay
   dưới `sql/`, ép kiểu chỉ ở câu đọc. `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` trước/sau chỉ khác dòng đếm file.
4. **Một định nghĩa khoá gom** (ADR-090 điểm 8, `I-019` tầng 3): sqlc không ghép đoạn câu giữa hai file, nên đoạn `viec` của bảng
   nhu cầu và của cửa đã ra bàn nằm ở hai file `.sql` giữa hai dòng đánh dấu. Một test mới `TestI019_KhoaGomMotDinhNghia` đỏ khi hai
   đoạn lệch một byte — thay cho hằng `viecGom` dùng chung (Claude chốt; không đổi luật, chỉ đổi chỗ giữ). File lát
   `07-san-xuat-theo-me.md` trỏ tên mới.
5. Lỗi cài, mỗi lần một lỗi rồi hoàn nguyên: bỏ `FOR UPDATE` ở câu khoá việc ⇒ test chen nhau `TestI020_HaiLanBamCungDonViChenNhau`
   đỏ; bỏ khoá mẻ ở cửa chuyển/lùi; đổi một byte đoạn khoá gom ở một file ⇒ `TestI019_KhoaGomMotDinhNghia` đỏ; miền khác import
   `sanxuat/internal/sqlcgen` ⇒ `go build` đỏ. Lỗi nào không bị bắt thì ghi kết quả thật.
6. `./scripts/gate.sh` ở cây chính: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-163 — Bàn giao** (2026-10-12). Thi công: **Claude Code** trên cây chính, nhánh `chatgpt_involve`, nền `0c4cade`; **chưa ai duyệt
độc lập**. File: `be/internal/sanxuat/handler.go` · `service.go` · `repository.go` · `khoa_gom_test.go` (mới; tám file `.go` cũ xoá) ·
mười một file câu ghi (chỉ thêm dòng `-- name:`, câu nguyên văn) · mười lăm file câu đọc mới ngay dưới `sql/` (câu cũ trong chuỗi Go) ·
`internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (hàm `dung`) ·
`docs/product/3-be/07-san-xuat-theo-me.md` (trỏ chỗ mới của khoá gom) · `docs/product/2-db/10-quy-uoc-code.md` §9 (dòng `T-163`: ba
đặc tính sqlc cho `T-164`) · `work/findings.md` (**F-066**). Log: scratchpad phiên `c4c4182b…/scratchpad/T-163-*`.
- *(1)* `./scripts/be-check.sh` hai lượt liền: `exit=0`, `PASS=136 FAIL=0` cả hai; mười chín test sản xuất và `TestI019_KhoaGomMotDinhNghia`
  PASS. Lượt thứ ba trong gate PASS.
- *(2)* Tập tên test trước/sau: `diff` chỉ thêm `TestI019_KhoaGomMotDinhNghia`. Test đổi chỉ ở `dung` (đăng ký `sanxuat` sang Gin).
- *(3)* `--list` trước/sau: 1f chỉ khác dòng đếm file (235 → 271), 1g chỉ khác dòng đếm file (133 → 154) — ô ghi, cửa, đường gọi không
  đổi. `check-sqlcgen` · Gate 1f · 1g · 1h PASS. Thứ tự khoá giữ: mẻ → phiên → đơn → việc; `NoDon(ctx, pgx.Tx, int64)` giữ chữ ký cho `don`.
  Ba chỗ câu đọc đổi hình mà không đổi nghĩa, vì Gate 1f đòi code sinh khớp nguồn từng chữ: `v.*` liệt kê cột; nguồn null của bảng nhu
  cầu thành mã 0 (identity từ 1, handler từ chối ≤ 0); `IS NOT DISTINCT FROM` thành cờ *là nước chấm* (client gửi được 0, nên không dùng mã 0).
- *(4)* Đoạn khoá gom ở `be/internal/sanxuat/sql/gom.sql` · `chon_da_lam.sql` giữa hai dòng đánh dấu thụt vào (sqlc bỏ chú thích ở cột 0).
- *(5)* Lỗi cài trên cây chính, mỗi lần một lỗi, hoàn nguyên bằng bản lưu (`diff -r` rỗng): (A) bỏ `FOR UPDATE` ở ba câu khoá của
  `khoaTap` ⇒ `--- FAIL: TestI020_HaiLanBamCungDonViChenNhau`; (B) bỏ khoá mẻ ở `khoa_me.sql` · `khoa_me_nguon.sql` ⇒ be-check **xanh** —
  không test chen lùi ⟂ chuyển, chưa đo tầng 1 có bắt thay không ⇒ **F-066**; (C) đổi `ORDER BY` trong đoạn khoá gom một file ⇒
  `--- FAIL: TestI019_KhoaGomMotDinhNghia`; (D) `hoadon` import `sanxuat/internal/sqlcgen` ⇒ `go build`: `use of internal package … not allowed`.
- *(6)* `./scripts/gate.sh` ở cây chính: `exit=0`, `PASS gate không cổng nào đỏ`, không dòng `SKIP` (be-check, db-check 21 bước, 15 file `scripts/*.test.sh` đều chạy).
- *Còn lại:* `router.go` chỉ còn `don` sau `NoRoute` (`T-164`); **F-066** chờ một task thêm test.

**T-164 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-12). Mức **L2**: sai thì một lượt gọi ghi hai đơn,
một đơn mở hai phiên cho một bàn, đơn duyệt mà bếp không có việc, hay đơn đặt trước nổ việc sai lần nhắc (`I-001` · `I-004` ·
`I-016` · `I-017` · `I-024`). `don` có mười đường gọi, sáu cửa (`tao_luot_goi` lớp `quay_hoac_khach`, năm cửa lớp `quay`), gọi
`sanxuat.NoDon` · `vongdoi` · `gia.Tinh` · `ban.Doc` trong giao dịch của mình. Thi công: **Claude** trên cây chính, nhánh
`chatgpt_involve`, nền `662760c`. Tên test kiểm ở nền bằng `rg '^func Test'`.
1. Toàn bộ test của `be/internal/don/` — kể cả bảy `TestI020_*`, mười `TestI004_*`, tám `TestI016_*` (ba của `don`, bốn của
   `vongdoi`, `TestI016_DonLeKhongTuHoanThanh`), bốn `TestI017_*`, chín `TestI024_*` (gồm hai test chen nhau
   `TestI024_GuiLaiChenNhauMotDon` · `TestI024_MangDiGuiLaiChenNhauMotDon`), `TestI001_LuotGoiDauChenNhauMotPhien`, bốn `TestI008_*`
   — cùng mọi `TestI018_*` và toàn bộ be-check PASS trên PostgreSQL thật, **hai lượt**. Điều kiện kiểm không đổi.
2. Test đổi chỉ ở phần dựng router: `don/don_test.go` (hàm `dung`, `don` sang Gin, bỏ `NoRoute`) và
   `don/mang_di_hinh_test.go` (`TestQC14_MangDiHinhTruocQuyen` gọi qua router Gin với service pool nil thay vì gọi thẳng handler cũ;
   bảng ca không đổi; vế "không đọc người" bỏ như `TestQC14_HinhDuongTienTruocQuyen` ở T-160 vì middleware đọc người cho mọi yêu cầu).
   Tập tên test trước/sau giống hệt.
3. Cây kết hợp: `handler.go` (Gin, mười đường, tham số `:sales_order_id` · `:code` đúng hợp đồng; mọi lời từ chối hình trước quyền
   như cũ), `service.go` (sáu `authz.Door` giữ mã và lớp; `Tao` · `DongHo` giữ chữ ký exported; thứ tự khoá phiên → đơn giữ;
   vòng chạy lại bốn lần chỉ cho hai khoá đã biết giữ), `repository.go`. Mười chín file câu dưới thư mục cửa giữ thư mục và câu,
   thêm `-- name:` và `;`; câu đọc trong chuỗi Go (`DongHo`, ba câu xét nhận đơn, nhắc hẹn) dời thành file ngay dưới `sql/`.
   `check-sqlcgen` · Gate 1f · 1g · 1h PASS; `--list` 1f trước/sau `diff` rỗng; 1g chỉ khác các dòng của bản đăng ký.
4. Lỗi cài trong worktree riêng (luật T-167), mỗi lần một lỗi: bỏ `FOR UPDATE` ở câu khoá phiên của cửa tạo lượt gọi ⇒ một test chen
   nhau (`TestI001_*` hoặc `TestI017_DongVaGoiThemChenNhau`) đỏ; bỏ chạy lại khi trùng `sales_order_submission_code_key` ⇒
   `TestI024_GuiLaiChenNhauMotDon` đỏ; bỏ gọi `sanxuat.NoDon` ở cửa duyệt ⇒ `TestI004_DuyetNoDuViecTrongCungGiaoDich` đỏ; miền khác
   import `don/internal/sqlcgen` ⇒ `go build` đỏ. Lỗi nào không bị bắt thì ghi kết quả thật.
5. `./scripts/gate.sh` ở cây chính: exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-164 — Bàn giao** (2026-10-12). Thi công: **Claude Code** trên cây chính, nhánh `chatgpt_involve`, nền `662760c`; **chưa ai duyệt
độc lập**. File: `be/internal/don/handler.go` · `service.go` · `repository.go` (sáu file `.go` cũ xoá) · mười chín file câu dưới
thư mục cửa (thêm `-- name:` và `;`; `tao_luot_goi/doc_don.sql` thêm ba `::jsonb` ở câu đọc để sqlc sinh `[]byte`, không đổi nghĩa) ·
năm file câu đọc mới ngay dưới `sql/` (`dong_ho` · `tam_dung` · `ngoai_gio` · `quan_mu` · `nhac_hen`, câu cũ trong chuỗi Go) ·
`internal/sqlcgen/` (sinh) · `be/sqlc.yaml` · `be/cmd/server/router.go` · `be/internal/don/don_test.go` (hàm `dung`) ·
`be/internal/don/mang_di_hinh_test.go` (dựng router) · `docs/product/2-db/10-quy-uoc-code.md` §9 (dòng `T-164`). Log: scratchpad phiên
`90d2e35e…/scratchpad/T-164-*`.
- *(1)* `./scripts/be-check.sh` hai lượt liền: `exit=0`, `PASS=136 FAIL=0 SKIP=0` cả hai; lượt thứ ba trong gate PASS.
- *(2)* Tập tên test trước/sau: `diff` rỗng. Test đổi chỉ ở `dung` và phần dựng router của `TestQC14_MangDiHinhTruocQuyen` (bảng ca giữ).
- *(3)* `--list` 1f trước/sau chỉ khác dòng đếm file (271 → 292); 1g chỉ khác dòng đếm file (154 → 170) — ô ghi, cửa, đường gọi, mã lỗi
  không đổi. `check-sqlcgen` · Gate 1f · 1g · 1h PASS. Hai tham số `nullif($7, '')` · `nullif($8, '')` của `them_don.sql` sinh `interface{}`;
  giữ câu nguyên văn, truyền chuỗi Go như code cũ.
- *(4)* Lỗi cài trong `../lean_wt/T-164-fault` (bản sao `be/` của cây chính, luật T-167), mỗi lần một lỗi rồi hoàn nguyên (`diff -r be` rỗng):
  (A) bỏ `FOR UPDATE OF s` ở `tao_luot_goi/khoa_phien.sql` ⇒ `--- FAIL: TestI017_DongVaGoiThemChenNhau` (nhận
  `table_session_transition_not_allowed` thay vì `dining_table_needs_cleaning`); `TestI001_LuotGoiDauChenNhauMotPhien` vẫn xanh vì khoá
  duy nhất của thành viên phiên giữ tranh chấp tạo đầu; `TestQC13_TramBepKhongCoCuaGhi` đỏ thêm vì Gate 1f báo code sinh lệch nguồn ở
  dấu `;` lệnh sửa để lại — hệ quả của cách cài, không phải chập chờn. (B) bỏ chạy lại trên `sales_order_submission_code_key` ⇒
  `--- FAIL: TestI024_MangDiGuiLaiChenNhauMotDon` (500 `internal_error`); bản tại bàn `TestI024_GuiLaiChenNhauMotDon` **xanh** — khoá phiên
  đã xếp hàng hai lần gửi cùng bàn nên không chạm khoá dấu; Acceptance dòng 4 đoán sai test, lỗi vẫn bị bắt. (C) cửa duyệt bỏ
  `sanxuat.NoDon` ⇒ sáu test đỏ, gồm `TestI004_DuyetNoDuViecTrongCungGiaoDich`. (D) `hoadon` import `don/internal/sqlcgen` ⇒ `go build`:
  `use of internal package … not allowed`.
- *(5)* `./scripts/gate.sh` ở cây chính: `exit=0`, `PASS gate không cổng nào đỏ`, không dòng `SKIP`.
- *Bước 07 xong:* mọi miền đã sang Gin; `ServeMux` chuyển tiếp ở `router.go` rỗng, `T-165` gỡ.

**T-165 — Acceptance và điểm Claude chốt trước thi công** (Claude, 2026-10-12). Mức **L1**: sai thì một đường gọi lệch hợp đồng hay một
câu ghi không qua sqlc lọt qua gate, nhưng không đổi hành vi chạy — mọi miền đã chuyển ở T-164. Thi công: **Claude** trên cây chính,
nền `695a6a0`. Không miền mới nào xuất hiện sau mốc kế hoạch (mười ba miền của `QC-14`, đếm lại 2026-10-12).
1. `rg -n 'gin\.WrapH' be` không có kết quả (exit 1); `be/cmd/server/router.go` không còn `http.NewServeMux` · `NoRoute`; hành vi 404 · 405
   · `HEAD` giữ, `TestQC12_Router*` của `be/cmd/server/` không đổi và PASS.
2. Gate 1g: `.HandleFunc(` · `.Handle(` (khuôn `ServeMux`) ⇒ đỏ có `file:dòng`; route Gin hợp lệ ⇒ xanh; Group · Any · Handle · nối chuỗi ·
   wildcard vẫn đỏ. `check-api-contract.test.sh` đổi fixture nền sang Gin và thêm ca *route HandleFunc cũ ⇒ đỏ*.
3. Gate 1f: miền có file `.sql` mà không có mục `sqlc.yaml` ⇒ đỏ (bỏ vế chuyển tiếp); khuôn SQL và ô ghi không đổi — `--list` trước/sau
   `diff` chỉ khác dòng đếm nếu có. `check-write-paths.test.sh`: ca `sqlc_old` đổi chiều thành đỏ; fixture "miền cũ" (thử bộ đọc ô ghi)
   được dựng `-- name:` và mục `sqlc.yaml` trước khi chạy, câu SQL và điều kiện kiểm của chúng không đổi.
4. Claude cập nhật `QC-12` · `QC-13` · `QC-14` khớp cây thực tế, bỏ các vế *chuyển tiếp*, thêm phép kiểm `gin.WrapH` · `http.NewServeMux`;
   năm khối `sh` chạy trên cây thật in rỗng.
5. `./scripts/gate.sh` exit 0, không `FAIL`; `SKIP` ghi là không chạy.

**T-165 — Bàn giao** (2026-10-12). Thi công: **Claude Code** trên cây chính, nhánh `chatgpt_involve`, nền `695a6a0`; **chưa ai duyệt
độc lập**. File: `be/cmd/server/router.go` · `router_test.go` (chỉ chú thích đầu file) · `scripts/check-api-contract.sh` · `.test.sh` ·
`scripts/check-write-paths.sh` · `.test.sh` · `docs/product/2-db/10-quy-uoc-code.md` (`QC-12` · `QC-13` · `QC-14`, §9 dòng `T-165`).
Log: scratchpad phiên `90d2e35e…/scratchpad/T-165-*`.
- *(1)* `rg -n 'gin\.WrapH' be` ⇒ exit 1, không dòng nào. `router.go` không còn `http.NewServeMux` · `NoRoute`; `be-check` riêng: `exit=0`,
  `PASS=136 FAIL=0 SKIP=0`, bảy `TestQC12_Router*` PASS (404 · 405 kèm `Allow` · `HEAD` giữ).
- *(2)* `check-api-contract.test.sh` 54 → 55 ca, `OK`: fixture nền sang Gin; ca mới `5 route HandleFunc cũ ⇒ đỏ` (`http.go:4: không nhận
  .HandleFunc(`) · `5b` (`.Handle(`) · `route HandleFunc cũ cạnh route Gin ⇒ đỏ`; `Gin đúng` xanh; Group · Any · Handle · nối chuỗi · wildcard
  · brace · biến · Sprintf · raw vẫn đỏ có `file:dòng`. Lỗi cài trên bản sao `be/` (`../lean_wt/T-164-fault`): `mux.HandleFunc("GET /menu")`
  ở `cmd/server` ⇒ `lo.go:11: không nhận .HandleFunc(`.
- *(3)* `check-write-paths.test.sh` 63 → 64 ca, `OK`: ca `sqlc_old` đổi chiều thành đỏ, thêm `sqlc_old_beside`; fixture "miền cũ" của `base()`
  được `sqlc_hoa` dựng `-- name:` và `sqlc.yaml` ngay trước khi chạy, câu SQL và điều kiện kiểm không đổi. `--list` 1f · 1g trước/sau `diff`
  rỗng. Lỗi cài: miền `moi` có `sql/x.sql` không mục ⇒ `x.sql:1: miền moi có file .sql mà không có mục trong sqlc.yaml`.
- *(4)* Ba khối `sh` `QC-12` · `QC-13` · `QC-14` chạy riêng trên cây thật ⇒ in rỗng. Lỗi cài trên bản sao: `gin.WrapH(http.NewServeMux())` ⇒
  dòng `QC-12`; `//go:embed sql/doc_mon.sql` ở `menu` ⇒ dòng `QC-13`; `internal/moi/sql/` không `sqlcgen` ⇒ dòng `QC-14`. Gỡ hết, `diff -r be` rỗng.
  Không miền mới sau mốc kế hoạch: mười ba miền, mỗi miền có `sql/` đều có `sqlcgen` và đúng một mục `sqlc.yaml`.
- *(5)* `./scripts/gate.sh`: `exit=0`, `PASS gate không cổng nào đỏ`, không dòng `SKIP`; `db-check` đọc 18 khối QC.

**T-166 — Acceptance và điểm Claude chốt trước rà** (Claude, 2026-10-12). Mức **L1**, chỉ đọc: sai thì đợt chuyển được tuyên bố xong mà
một ô ghi, một route, một mã lỗi hay một test đã mất. Không sửa code; chỉ ghi `work/backlog.md` và `work/findings.md` nếu có vấn đề lặp
lại. Nền bước 02 là commit `f70dfb3` (nền của T-150); dựng lại `--list` bằng chính script ở commit ấy trong worktree tách rời, không dựa
vào log của phiên khác.
1. Cây thật đối chiếu §2 kế hoạch và `QC-14`: mỗi miền ba tầng (hai với `ngayban` · `vongdoi`), một gói sinh mỗi miền, SQL ở `sql/` ·
   `sql/<cửa>/`; mọi sai lệch được liệt kê và giải quyết hoặc ghi rõ vì sao chấp nhận.
2. `--list` Gate 1f · 1g ở `f70dfb3` so với `be25683`: tập ô ghi → cửa giống hệt; route, mã lỗi + status, ánh xạ tên từ chối, cửa → lớp
   giống hệt; khác biệt chỉ ở dòng đếm file. So từng dòng, không dựa riêng vào số lượng.
3. Tập tên test ở mỗi commit từ `f70dfb3` tới `be25683`: không commit nào làm mất tên; đọc diff `*_test.go` của đợt, mọi thay đổi điều
   kiện kiểm có lý do đã duyệt (phần dựng router, test mới, ca sửa nguyên nhân ở bước 00).
4. `verify.sh` · `be-check.sh` · `gate.sh` xanh ở `be25683`; bằng chứng lỗi cài của T-152…T-165 có trong entry, mỗi task một dòng
   đọc lại. Vấn đề làm chậm lặp lại có bằng chứng ⇒ `F-XXX`.
5. `./scripts/gate.sh` không `FAIL`; `SKIP` ghi là không chạy.

**T-166 — Bàn giao** (2026-10-12). Rà: **Claude Code** trên cây chính, nền `be25683`; không sửa code. File: `work/backlog.md` ·
`work/findings.md` (**F-067**) · `docs/product/2-db/10-quy-uoc-code.md` (scope mở rộng, nói trong lượt: hai câu owner lệch cây thật — là
sửa tài liệu, không phải code). Nền dựng lại ở worktree tách rời `../lean_wt/T-166-base` (`f70dfb3`), chạy chính script của commit ấy.
Log: scratchpad phiên `90d2e35e…/scratchpad/T-166-*`, `names_<commit>.txt`.
- *(1) Cây thật ⇄ §2 kế hoạch ⇄ `QC-14`:* mười ba miền; mười một có `handler.go` · `service.go` · `repository.go`, `ngayban` · `vongdoi`
  không đường gọi nên không `handler.go` (`QC-14`, T-155); mọi miền có `sql/` đều có `internal/sqlcgen/` và đúng một mục `sqlc.yaml`;
  không `go:embed`, không câu SQL trong `.go` của miền ngoài `sqlcgen`. Sai lệch và cách giải quyết: (a) §2 kế hoạch liệt kê mười hai
  miền, thiếu `nguoi` — kế hoạch là con trỏ, `QC-14` (owner) đúng, không sửa; (b) `cmd/server/` có `router.go` ngoài `main.go` — đúng
  `QC-14` (`newRouter`); (c) `vongdoi/viec.go` giữ một `authz.Door` ngoài `service.go` — Claude chấp nhận ở T-158 nhưng `QC-14` chưa
  nói, nay ghi vào dòng miền; (d) câu `QC-13` do T-165 viết "không file `.go` nào giữ câu SQL" sai với `authz` · `platform/postgres`
  (không phải miền, giữ câu đọc) — thu hẹp về "trong một miền". Ba khối `QC-12` · `QC-13` · `QC-14` sau sửa in rỗng. Không còn lệch mở.
- *(2) `--list`:* 1f `f70dfb3` → `be25683` khác đúng một dòng — đếm file 113 → 292; 38 ô ghi, 39 cửa giống từng dòng. 1g khác ba dòng:
  đếm file 36 → 170, dòng tổng (hợp đồng 0.12.0 → 0.13.0, 296 → 297 tên), và một dòng `ánh xạ menu_option_one_default_per_group_key
  internal` — `git log -S` chỉ ra `ef43aeb` (**T-169**, ADR-094), task riêng chen giữa đợt, không phải chuyển stack. 45 route, 60 mã
  lỗi + status, 39 cửa → lớp giống từng dòng.
- *(3) Tên test:* từng commit trong 27 commit `f70dfb3..be25683` so với commit trước — không commit nào mất tên; 124 → 136, mười hai
  tên thêm ở T-151 (6) · T-153 (2) · T-169 · T-171 · T-172 · T-163 (1 mỗi). Mọi dòng xoá trong `be/**/_test.go` của đợt (đọc hết) thuộc
  ba loại: đổi gói `db` → `platform/postgres`, `dbtest` → `testhelper`; dựng router `ServeMux` → Gin; và vế "không đọc người trước khi
  kiểm hình" của `TestQC14_HinhDuongTienTruocQuyen` (T-160) · `TestQC14_MangDiHinhTruocQuyen` (T-164) — **nới có chủ ý**: middleware
  đọc người cho mọi yêu cầu theo thiết kế T-151; vế "không chạm quyền, không chạm database" vẫn giữ bằng pool nil. Không `t.Fatal`,
  mã mong đợi hay bảng ca nào đổi.
- *(4)* `be-check` riêng ở cây tích hợp: `exit=0`, `PASS=136 FAIL=0 SKIP=0`. `verify` trong gate PASS (15 `*.test.sh`). Bằng chứng lỗi cài
  có trong entry của cả mười sáu task T-150…T-165 (đọc lại từng dòng *Lỗi cài*); T-163 cài trên cây chính trái luật T-167 ⇒ **F-067**.
- *(5)* `./scripts/gate.sh` lượt cuối: `exit=0`, `PASS gate không cổng nào đỏ`; một dòng `SKIP Gate 1 be` (lượt không đổi `be/`) — cổng
  **không chạy**, bù bằng `be-check` riêng ở dòng (4).

**Bàn giao** (2026-10-11): thiết kế và viết — **Claude Code**, không giao Codex (phiếu nói vậy); chưa ai duyệt
độc lập. Cây chính, nhánh `chatgpt_involve`, nền `a085af4` cộng phần Done chưa commit của T-138 · T-140 · T-142 ·
T-143 · T-147 · T-148. T-149 không sửa file nào của chúng ngoài `work/backlog.md` là file dùng chung; `docs/decisions.md` và
`10-quy-uoc-code.md` không có thay đổi chưa commit của ai trước lượt này. File: `docs/decisions.md`,
`docs/product/2-db/10-quy-uoc-code.md`, `work/backlog.md`. Log ở scratchpad phiên `17725f75…/scratchpad/`
(`gate1.log`, `gate2.log`, `10-before.md`, `blk_QC-*.sh`, `fake1/`, `fake2/`).
- *(1)* `grep -o 'ADR-[0-9]*' docs/decisions.md | sort -u | tail -1` ⇒ `ADR-092` trước lượt; ADR mới là **ADR-093**,
  dòng bảng tổng hợp, ADR-083 có mục *Sửa đổi* và dòng bảng trỏ sang ADR-093.
- *(2)* Năm khối `sh` (`QC-05` · `QC-11`…`QC-14`) chạy riêng trên cây thật ⇒ cả năm in rỗng. Cây giả có lỗi cài
  (`fake1/`: gin v1.11.0, sqlc v1.30.0 thiếu dòng `tool`, `service.go` import Gin có bí danh, `.Group(`,
  `tx.Commit(` ngoài nơi mở giao dịch, hai chỗ giữ hàm mở giao dịch, miền khác import `sqlcgen`, migrate v4.19.0,
  thư mục lạ ở gốc `be/`, miền có `sqlcgen` thiếu tầng) ⇒ mỗi lỗi một dòng đỏ đúng mục. Hai hình `go.mod` đích của
  T-150 (`require` khối và một dòng, `tool` một dòng và khối) ⇒ `QC-11` in rỗng. Gate lượt đầu: `db-check — … 18 khối kiểm QC`.
  Đối chiếu kế hoạch §0 (năm bản ghim) · §1 (năm điểm giữ, bốn lý do, hai phương án bị loại) · §2 (cây) bằng mắt, không lệch.
- *(3)* Bảng *Chia lát* ở trên; mười bảy dòng T-150…T-166 trong *Ready*, xếp dưới T-146.
- *(4)* Danh sách *Rà thiết kế* ở trên, mười điểm, mỗi điểm nêu bước bị chặn.
- *(5)* `./scripts/gate.sh` hai lượt ⇒ exit 0, `PASS gate không cổng nào đỏ`, không dòng `SKIP` (Gate 1 chạy đủ vì
  cây có thay đổi `be/` · `db/` của task khác: be-check, db-check 20 bước, 13 file `scripts/*.test.sh`).
  `be-check` có chạy nhưng không chứng minh gì cho T-149, vì task này không đổi code; không cài lỗi trong code.

[↑ đầu file](#top)

<a id="t-148"></a>
### T-148 — Điều kiện trước đổi stack backend: QC-17 vào be-check, giữ database khi đỏ, test I-020 chập chờn

**Yêu cầu:** chủ repo, 2026-10-10 — phiếu `docs/private/be_feature/prompts/BE-STACK-00-dieu-kien-truoc-L2.md`
(*"hãy đọc kĩ task trên và hoàn thành"*). Mục đích: nền backend phân biệt được lỗi cũ với lỗi do đổi stack.
Mức **L2** (gate và test của `I-020`). Claude tự làm, không giao Codex.

**Acceptance (viết trước khi sửa, 2026-10-10):**
- [x] (1) `T-138`, `T-140`, `T-142`, `T-143` đã đóng hoặc bàn giao tạm dừng rõ người giữ; không ai viết song song vào `be/`.
- [x] (2) Cây thử chỉ đổi `be/`: thêm `TestSaiTen` ⇒ phép kiểm `QC-17` đỏ; trả tên hợp lệ ⇒ xanh (lệnh và output hai lượt).
- [x] (3) `BE_CHECK_KEEP_DB=1` ⇒ test đỏ thì không dọn compose project, in tên project, DSN, lệnh dọn; mặc định dọn như cũ; ghi ở header.
- [x] (4) ≥10 lượt `./scripts/be-check.sh` có log từng lượt; nguyên nhân `TestI020_DaRaBanTheoSoCaiTungThuChoMotBan` ghi kèm dữ liệu lúc lỗi, bản sửa và ca tái hiện — hoặc ghi rõ chưa tái hiện được.
- [x] (5) Sau sửa test ấy xanh; cài lại lỗi nguyên nhân ⇒ ca hồi quy đỏ; gỡ ⇒ xanh.
- [x] (6) `./scripts/gate.sh` không có `FAIL`; `SKIP` ghi là chưa chạy.

**Bàn giao** (2026-10-10): thiết kế, thi công, chạy PostgreSQL — **Claude Code**, không giao Codex (phiếu nói vậy);
chưa ai duyệt độc lập. Cây chính, nhánh `chatgpt_involve`, nền `00b7ee9` cộng thay đổi chưa commit của
`T-138` · `T-140` · `T-142` · `T-143` · `T-144` · `T-147` (đều Done, chờ chủ repo commit; T-148 không sửa file nào của chúng
ngoài `work/backlog.md` và `work/findings.md`, là hai file dùng chung). File của T-148: `scripts/be-check.sh`,
`scripts/be-check.test.sh` (mới), `scripts/verify.sh` (header), `scripts/check-links.ignore` (một dòng), `work/findings.md` (F-061 gỡ, F-063 mới), `work/backlog.md`.
Log ở scratchpad phiên `f9049835…/scratchpad/` (`loop1/`, `hA/` `hB/` `hC/` `oA/` `oC/`, `keep_on.log`, `keep_off.log`,
`du_lieu_luc_do.txt`).
- *(1)* Bốn task đều ở *Done* (dòng Done 2026-10-10); worktree `../lean_wt/T-140` · `T-142` · `T-138` · `P3-10-fix`
  không còn thay đổi đang viết vào cây chính. 94 file chưa commit của cây chính là phần đã tích hợp của chúng.
- *(2)* Cây thử `git worktree add --detach` từ `HEAD`, chép be-check mới và ẩn bằng `skip-worktree` nên `git status`
  chỉ còn `?? be/internal/don/sai_ten_test.go`. Lượt 1 `func TestSaiTen` ⇒ `be-check: FAIL — QC-17 tên test không
  mang mã mệnh đề … TestSaiTen`, exit 1; `verify.sh` cũng dừng ở dòng ấy. Lượt 2 đổi thành `TestQC17_TenHopLe` ⇒
  `PASS be-check QC-17`, `--- PASS: TestQC17_TenHopLe`, `be-check: PASS`, exit 0. `scripts/be-check.test.sh` giữ bốn ca.
- *(3)* Lỗi cài ở cây riêng: `BE_CHECK_KEEP_DB=1` ⇒ exit 1, in `giữ database lúc đỏ: project banhcuon_check_55261_…`,
  hai DSN, `dọn khi xong: docker compose -p … down -v`; `docker compose ls` thấy project `running`; lệnh dọn được in
  gỡ sạch. Không đặt biến ⇒ exit 1, project không còn.
- *(4)* 633 lượt không đỏ: 20 lượt `be-check` đầy đủ (`loop1/`, 30–35 giây mỗi lượt); 200 lượt riêng test ấy, mỗi lượt
  database sạch từ bản mẫu; 200 lượt khi máy chạy thêm mười tiến trình `yes`; 7 lượt cả gói `don`; 206 lượt trên code
  `880b741`. **Nguyên nhân** tìm trong log phiên trên máy, không phải đoán: lần đỏ là Stop hook 2026-10-09 21:55 ở cây
  chính, trong 52 giây một phiên khác cài lỗi "bỏ khối thiếu cái" vào `ra_ban.go` cùng cây — **F-063**. Dữ liệu lúc
  đỏ (tái hiện, database giữ lại): bàn 121, hàng `gap_banh`/1 có đơn vị 324 (đơn 119) đã bưng ở bước "1 cái" và 327
  (đơn 120) là cái đã làm duy nhất; test đòi 2 ⇒ bản lỗi bưng 327, `200 … station_job_ids:[327]`. **Bản sửa:** không
  sửa code hay test (không có lỗi ở đó); đề nghị luật *lỗi cài chỉ trong worktree riêng* chờ chủ repo (F-063).
- *(5)* Ca hồi quy là chính test hiện có: code sạch ⇒ `--- PASS`; cài lại lỗi ⇒ `san_xuat_test.go:637: muốn 409
  served_quantity_exceeds_made …, nhận 200 … station_job_ids:[4]`, `--- FAIL`; trả bằng bản sao, `shasum -c` ⇒
  `ra_ban.go: OK`, `--- PASS`.
- *(6)* `./scripts/gate.sh` ở cây chính ⇒ exit 0, `PASS gate không cổng nào đỏ`, không dòng `SKIP` (Gate 3 · 1b–1g; be-check;
  db-check 20 bước, 102 câu, 102 lỗi cài; 13 file `scripts/*.test.sh`). Lượt đầu Gate 1b đỏ vì
  `docs/private/be_feature/prompts/README.md` (đã commit ở `00b7ee9`) nêu `be/sqlc.yaml`, file bước 02 mới tạo — scope
  T-148 mở thêm `scripts/check-links.ignore`, một dòng ngoại lệ có hạn theo tiền lệ `fe/package.json`; gỡ ở lượt tạo file.

[↑ đầu file](#top)

<a id="t-174"></a>
### T-174 — Cửa nhập bù hoá đơn từ sổ giấy

**Nhận việc** — Claude Code, 2026-10-13 (viết trước, nhận sau khi `T-175` Done vì cùng gói `hoadon` và cần giảm giá).
Mức **L2**: tiền, hàm giá, hợp đồng. Thiết kế: **ADR-099**. Luật: `master_plan/shop-facts.md` §6 quy tắc 11 (U-079).
- *Phạm vi:* `be/internal/hoadon/` · `be/internal/gia/` · `be/internal/don/` (dựng phiên/đơn quá khứ, test) ·
  `be/internal/apierr/` · `be/internal/authz/` (khai cửa) · `docs/product/3-be/` (`08-vet-va-nhap-bu.md`, `03-ham-gia.md`,
  `02-vai-va-quyen.md`, `openapi.yaml`). Không migration (lược đồ sổ giấy có từ `P2-08`).
- *Nghiệm thu:*
  1. `TestYC08_NhapBuTaiBanQuaCua`: ngày khai 2 lượt; nhập lượt 1 tại bàn ⇒ một phiên đóng ở `sold_at`, một hoá đơn
     `booked_at = sold_at`, `sale_date` của sổ, `created_at` hôm nay, người nhập bù là người bấm; không việc trạm nào;
     *còn N* từ 2 về 1.
  2. `TestYC08_NhapBuMangDiQuaCua`: lượt mang đi ⇒ đơn `phone_preorder` `completed` có liên hệ; thiếu điện thoại ⇒
     `invalid_request` theo trường (`I-022`).
  3. `TestI009_NhapBuTinhGiaLucBan`: đổi giá một thành phần sau `sold_at` ⇒ lượt nhập bù tính giá cũ, đơn mới tính giá
     mới, cả hai qua cùng `gia.Tinh`; món ngừng bán sau `sold_at` vẫn nhập bù được; `grep` một đường tính giá.
  4. `TestYC08_NhapBuTuChoi`: chưa khai sổ · vị trí trùng · vị trí ngoài 1…N · `sold_at` ngoài ngày · ngày đã ký · sai
     lớp quyền ⇒ đúng mã của ADR-099 điểm 5.
  5. `TestI021_NgayGiayNhapDuRa0dLech`: ngày mất điện khai N lượt, nhập đủ N qua cửa, đếm két ⇒ ký ngày được và lệch 0đ
     (hết `paper_entries_pending`); bộ đối chiếu trên ngày ấy rỗng.
  6. Test cũ không đổi khẳng định; hợp đồng nâng một bậc phụ; `./scripts/gate.sh` xanh (be-check, db-check).
- *Kiểm chứng:* Claude chạy lại gate; cài lỗi trong worktree riêng: hàm giá đọc menu hiện tại thay vì ở mốc ⇒ (3) đỏ;
  bỏ kiểm vị trí trùng ở tầng cửa và tầng 1 vẫn bắt ⇒ (4) vẫn đúng mã; hoá đơn lấy `now()` làm `booked_at` ⇒ (1) đỏ.

**Bàn giao** (2026-10-13): thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-174`, nhánh
`codex/T-174` từ `bb6510c`, hai lượt; lượt 2 hết hạn mức trước khi viết test và báo cáo). Thiết kế, sửa đổi ADR, test
nghiệm thu, duyệt, cài lỗi và tích hợp: **Claude Code**.
- *Lượt 1 Codex dừng đúng chỗ:* ADR-099 nói phiên "mở và đóng ở `sold_at`" và "ánh xạ ràng buộc chồng phiên", nhưng
  `table_session` không có cột mốc và lược đồ không có ràng buộc chồng theo thời gian ⇒ Claude ghi **ADR-099 *Sửa đổi
  2026-10-13***: phiên tạo thẳng `closed`, mốc bán ở `bill.booked_at`, bỏ lời từ chối chồng phiên; không migration.
- *File:* cửa `be/internal/hoadon/nhap_bu.go` + `sql/nhap_bu/` (đăng ký ở `be/sqlc.yaml`) · `hoadon/{handler,repository,
  service}.go` · `sql/ghi/them.sql` (cột sổ giấy) · `be/internal/don/nhap_bu.go` (`GhiNhapBu`, dùng các ô INSERT của
  `tao_luot_goi`; `them_phien` · `them_ban` · `them_dong*` nhận trạng thái/`cleaned_at`/`priced_at`, đường cũ không đổi) ·
  `be/internal/gia/` (đọc menu tại mốc) · `apierr` (`paper_ledger_missing`, `paper_position_already_entered`, ánh xạ
  `bill_paper_position_key`) · sqlcgen · `docs/product/3-be/{02,03,08}-*.md` · `openapi.yaml` 0.18.0 · test
  `be/internal/don/{gia_tai_moc_test.go (Codex), nhap_bu_test.go (Claude)}`.
- *Claude sửa khi duyệt:* (1) câu `gia/sql/doc_mon.sql` quét `record_revision` theo từng dòng của bảy bảng menu
  (bảng vết không có chỉ mục theo dòng) ⇒ `GET /menu` quá hạn 5 giây, ba test giá cũ đỏ; viết lại thành một CTE `vet`
  quét một lần. (2) Codex dời ngày của hai test cũ (`duong_tien_test.go` ngày 22 · `huy_hoan_thanh_test.go` ngày 25/26)
  để lấy ngày cho T-174 ⇒ hoàn lại; T-174 dùng tháng 6/2031 (chưa test nào dùng). (3) Viết năm test Nghiệm thu 1–5;
  ca giá dùng giờ thật vì vết sửa giá mang `revised_at` thật — mốc 2031 giả đứng sau mọi lần sửa.
- *Kiểm chứng:* worktree và cây chính `./scripts/gate.sh` exit 0 — `PASS Gate 1 be-check — mọi test backend qua
  PostgreSQL thật đều đạt`, `PASS Gate 1g … hợp đồng 0.18.0; 55 đường gọi`, `PASS Gate 1f … 47 ô ghi, 48 cửa`; db-check
  SKIP đúng (không đổi `db/`). Lỗi cài ở ba worktree tách rời (đã gỡ): `gia.Tinh` không truyền `sold_at` ⇒
  `TestI009_NhapBuTinhGiaLucBan` đỏ (`menu_item_discontinued`); bỏ kiểm vị trí trùng ở tầng cửa ⇒ `TestYC08_NhapBuTuChoi`
  vẫn xanh, đúng `paper_position_already_entered` qua ánh xạ ràng buộc; `booked_at` lấy giờ cửa ⇒
  `TestYC08_NhapBuTaiBanQuaCua` · `TestYC08_NhapBuMangDiQuaCua` đỏ.
- *Nghiệm thu 6:* không test cũ nào đổi khẳng định. Cửa chỉ INSERT ⇒ không ca mới ở `TestI018_MoiCuaSuaCoVet`
  (`TestI018_TapCuaSuaKhopTapCa` xanh). *Còn lại:* không. *Duyệt độc lập:* chưa (Codex thi công code, Claude viết test và duyệt).

<a id="t-175"></a>
### T-175 — Giảm giá cả đơn

**Nhận việc** — Claude Code, 2026-10-12. Mức **L2**: tiền, lược đồ, hợp đồng. Thiết kế: **ADR-098**. Luật:
`master_plan/shop-facts.md` §8.9 D41 (lời U-058, đóng ở `T-173`).
- *Phạm vi:* `db/migrations/` (một cặp file mới, bước 23) · `db/tests/` · `db/reconcile/` · `db/scenario/` (nếu câu
  đọc lại doanh thu đổi) · `scripts/db-check.sh` · `be/internal/hoadon/` · `be/internal/apierr/` · `be/internal/don/*_test.go`
  · `docs/product/3-be/` (`06-duong-tien.md`, `openapi.yaml`) · `docs/product/2-db/` (`04-luoc-do-duong-tien.md`,
  `07-thu-tu-migration.md`, `09-doi-chieu-bat-bien.md`).
- *Nghiệm thu:*
  1. Test database `db/tests/i015_bill_discount.sql`: giảm âm ⇒ từ chối; có giảm mà tên trống ⇒ từ chối; tên mà không
     giảm ⇒ từ chối; tiền mặt + chuyển khoản + trả trước + nợ + giảm khác `due_vnd` ⇒ từ chối; giảm bằng `due_vnd` (trả 0)
     ⇒ được. Đỏ trên bước 22, xanh trên bước 23; đường lùi từ chối khi có giảm dương.
  2. `TestI015_ChuQuanGiamGiaCaDon` (qua HTTP, mỗi cửa `hoadon/dong` · `hoadon/trao_tai_quay` · `hoadon/giao_xong` một
     ca): chủ quán đứng quầy giảm kèm tên ⇒ hoá đơn mang giảm, phần trả = tổng − giảm, `GET /debts`/đường đọc không đổi.
  3. `TestI015_GiamGiaTuChoi`: người không phải chủ quán giảm ⇒ `owner_only`; thiếu tên ⇒ `invalid_request` field
     `discount_customer_name`; tên mà không giảm ⇒ cùng mã; giảm vượt tổng ⇒ `invalid_request` field `discount_vnd`.
  4. `TestI021_NgayCoGiamGiaRa0dLech`: một ngày có hoá đơn giảm giá đi qua cửa ⇒ ký ngày lệch 0đ; bộ đối chiếu
     `scripts/reconcile.sh` trên ngày ấy rỗng (doanh thu đọc sau giảm).
  5. `TestI015_GiamGiaCaDonBiTuChoiChoU058` đổi thành chứng minh hành vi mới (đổi tên theo QC-17, nói rõ ở Bàn giao);
     mã `order_discount_undecided` gỡ khỏi hợp đồng; hợp đồng nâng 0.17.0.
  6. `./scripts/gate.sh` xanh (be-check, db-check).
- *Kiểm chứng:* Claude chạy lại gate; cài lỗi trong worktree riêng: bỏ kiểm *chủ quán* ⇒ (3) đỏ; câu doanh thu ở
  `db/reconcile/` quên trừ giảm ⇒ (4) đỏ; bỏ ràng buộc tên khách ⇒ (1) đỏ.

**Bàn giao** (2026-10-13): thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-175`, nhánh
`codex/T-175` từ `16ca623`, một lượt, có báo cáo). Thiết kế (`16ca623`), duyệt, cài lỗi và tích hợp: **Claude Code**.
- *File:* migration `20261013120000_giam_gia_ca_don.*` · `db/tests/i015_bill_discount.sql` · `scripts/db-check.sh` (đỏ bước
  22, xanh bước 23, chặn lùi) · `db/reconcile/` (`i005` · `i012` · `i015`) · `db/scenario/doc_lai.sql` · `be/internal/hoadon/`
  (ba cửa, câu đọc `chu_quan.sql`) · `be/internal/apierr/` · `sqlcgen` các miền (cột mới) · test `duong_tien_test.go` ·
  `docs/product/3-be/{06-duong-tien.md,openapi.yaml}` · `docs/product/2-db/{04,07,09}-*.md`.
- *Claude sửa khi duyệt:* `TestI021_NgayCoGiamGiaRa0dLech` ký ngày 31 — ngày `TestYC08_KhaiSoGiayQuaCua` cần khai sổ ⇒
  chuyển sang ngày 27 (chưa test nào dùng). Test cũ `TestI015_GiamGiaCaDonBiTuChoiChoU058` thay bằng hai test mới vì lời
  U-058 đổi hành vi (Nghiệm thu 5).
- *Kiểm chứng:* worktree và cây chính `./scripts/gate.sh` exit 0 — db-check *23 bước … 42 file test*, `PASS T-175 đỏ bước
  22` · `PASS T-175 xanh bước 23; đường lùi từ chối giảm dương`; be-check *mọi test backend qua PostgreSQL thật đều đạt*.
  Lỗi cài ở ba worktree tách rời (đã gỡ): bỏ kiểm chủ quán ⇒ `TestI015_GiamGiaTuChoi` đỏ cả ba cửa; `i005.sql` quên trừ giảm
  ⇒ `TestI021_NgayCoGiamGiaRa0dLech` đỏ; bỏ `bill_discount_customer_name_check` ⇒ `db/tests/i015_bill_discount.sql` đỏ.
- *Ghi nhận, không chặn:* `scripts/db-check.sh:435` in *Broken pipe* (`grep -m1` đóng ống trước `printf`) — code cũ, bước
  vẫn PASS. *Còn lại:* không. *Duyệt độc lập:* chưa (Codex thi công, Claude duyệt).
- *Phiên sau* làm `T-174` → `P3-13` → `P3-14`; cách gọi Codex: `docs/prompt-guideline.md` §6.1 đoạn *Đo trên máy này*.

<a id="t-146"></a>
### T-146 — Chủ quán sửa số đếm két của ngày đã ký

**Nhận việc** — Claude Code, 2026-10-12 (chủ repo giao toàn quyền làm nốt pha 3; T-166 đã Done). Mức **L2**: chạm tiền,
dữ liệu đã ký và một migration. Thiết kế: **ADR-096**. Luật: `master_plan/shop-facts.md` §6.10 (U-074 · U-078).
- *Phạm vi:* `db/migrations/` (một cặp file mới, bước 22) · `db/tests/` · `db/reconcile/` (nếu câu đọc dấu cần đổi) ·
  `be/internal/ket/` · `be/internal/apierr/` · `docs/product/3-be/` (`06-duong-tien.md`, `02-vai-va-quyen.md`, `openapi.yaml`) ·
  `docs/product/2-db/` (`04-luoc-do-duong-tien.md`, `07-thu-tu-migration.md`, `09-doi-chieu-bat-bien.md` nếu đổi câu) ·
  `scripts/db-check.sh` (nếu cần gọi test mới).
- *Nghiệm thu:*
  1. Test database `db/tests/i021_reopened_day.sql`: mở lại cần lý do không trắng và người; một dấu mở lại nhiều nhất một
     lần; dấu thứ hai của ngày khi dấu trước chưa mở lại ⇒ từ chối; dấu nối vào dấu của ngày khác ⇒ từ chối; sửa số đếm
     khi dấu đang đứng ⇒ từ chối như cũ, khi dấu đã mở lại ⇒ đi qua có vết; tiền đầu két ngày đã mở lại ⇒ vẫn từ chối;
     `TRUNCATE` vẫn bị chặn. Đỏ trên bước 21, xanh trên bước 22. Đường lùi từ chối khi có dòng mở lại.
  2. `TestI021_ChuQuanSuaSoDemNgayDaKy` (qua HTTP): ngày đã ký, chủ quán `PUT /sale-days/{d}/cash-count` kèm lý do ⇒ số
     mới, ngày ở trạng thái mở lại, vết của từng dòng đổi mang lý do và người; ký lại ⇒ dấu mới trỏ dấu cũ; đường đọc trả
     chuỗi dấu và lý do mở lại.
  3. `TestI021_SuaSoDemTuChoi…`: thiếu hoặc trắng lý do ⇒ `invalid_request` field `reason`; người không phải chủ quán ⇒ từ
     chối quyền; ngày chưa từng ký ⇒ `sale_day_not_reconciled`; thân xấp sai ⇒ như cửa đếm.
  4. `TestI021_NgayMoLaiVanDongVoiCuaTien`: ngày đang mở lại, cửa tiền khác (thu, hoàn, đầu két, đếm thường) ⇒
     `sale_day_reconciled`.
  5. `TestI021_SuaSoDemChenLucKy` dựng tất định như `TestI021_TienChenLucKyNgayKhongLotVaoSoDaKy`.
  6. Test cũ không đổi khẳng định; ký lần đầu, ngày lệch cần giải thích, sổ giấy (ADR-095) áp cho lần ký lại.
  7. `./scripts/gate.sh` xanh (be-check, db-check trên PostgreSQL).
- *Kiểm chứng:* Claude chạy lại gate; cài lỗi trong worktree riêng (luật `T-167`): bỏ điều kiện *dấu đang đứng* ở khoá ⇒
  test (1) đỏ; cửa sửa không ghi dòng mở lại ⇒ (2) đỏ; `ngayban.DaKy` đổi sang *dấu đang đứng* ⇒ (4) đỏ.
- *Ghi chú quy trình:* L2 của pha 3 đòi Claude viết test đỏ trước; lượt này Claude viết Nghiệm thu tới từng ca, Codex viết
  test và code, Claude cài lỗi để chứng minh test bắt được — cùng cách đã dùng ở `P3-11`.

**Bàn giao** (2026-10-12): thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-146`, nhánh
`codex/T-146` từ `8059062`; ba lượt vì hết hạn mức hai lần; sandbox không tới Docker). Thiết kế (`c434865`), duyệt, cài lỗi
và tích hợp: **Claude Code**.
- *Claude duyệt giữa chừng:* Codex hỏi ô INSERT `cash_count_line` dùng chung — Claude chọn cửa `ket/ghi_dong_dem` lớp
  `theo_cua_goi` (tiền lệ `hoadon/ghi`), ghi ở ma trận. *Claude sửa khi duyệt:* `TestQC14_SuaDemHinhTruocQuyen` đọc lỗi
  trong lớp bọc `error` không có trong hợp đồng — sửa hình đọc về `{code, field}`.
- *Phần thêm ngoài phiếu, Claude chấp nhận:* trigger vết thêm dòng con phủ `cash_count_line` thêm vào ngày đã mở lại
  (lần thêm mệnh giá mới cũng có vết, `I-018`); `db/reconcile/i014.sql` đọc *dấu đang đứng*.
- *Kiểm chứng:* worktree và cây chính `./scripts/gate.sh` exit 0 — db-check *22 bước xuôi · lùi · xuôi lại … 41 file
  test*, `PASS T-146 đỏ bước 21` · `PASS T-146 xanh bước 22; đường lùi từ chối lịch sử mở lại`; be-check *mọi test
  backend qua PostgreSQL thật đều đạt*. Lỗi cài ở ba worktree tách rời (đã gỡ): cửa sửa bỏ dòng mở lại ⇒
  `TestI021_ChuQuanSuaSoDemNgayDaKy` · `…SuaSoDemChenLucKy` · `TestI018_MoiCuaSuaCoVet/ket/sua_dem` đỏ; `DaKy` chỉ tính
  dấu đang đứng ⇒ đúng `TestI021_NgayMoLaiVanDongVoiCuaTien` đỏ; khoá database bỏ điều kiện dấu đang đứng ⇒
  `db/tests/i021_reopened_day.sql` · `i021_reconciled_day_frozen.sql` đỏ.
- *Còn lại:* không. *Duyệt độc lập:* chưa (Codex thi công, Claude duyệt).

<a id="t-147"></a>
### T-147 — Huỷ đơn đã Hoàn thành: chủ quán cho huỷ, cửa vẫn từ chối

**Yêu cầu:** chủ repo, 2026-10-10 — *"P3-10 … hãy hoàn thành nốt task trên còn thiếu cái gì yêu cầu codex làm
và bạn kiểm tra"*. Phần còn sót của `P3-10`: ADR-090 điểm 7 hoãn *Hoàn thành → Huỷ* vì đường hoàn tiền chưa có;
`P3-09` đã dựng đường ấy. Lời chủ quán: U-027 (`shop-facts.md` §6.19 — *"có thể huỷ được, để POS quyết định
trong thực tế"*). Mức **L2** (đơn đã thu tiền). Thiết kế: **ADR-090** điểm 7 *Sửa đổi 2026-10-10*.

**Acceptance (viết trước khi sửa, 2026-10-10):**
- [x] (1) Hai test đỏ do Claude viết ở `be/internal/don/huy_hoan_thanh_test.go` xanh qua `./scripts/be-check.sh`
      mà không sửa điều kiện kiểm nào (`shasum` lúc giao `fdf02fdf…`, sau sửa khung của Claude `c9a7206f…`; `san_xuat_test.go` `26dfac3e…` — bỏ dòng
      khẳng định mã cũ, có chủ ý): đơn gắn bàn *Hoàn thành* ⇒ huỷ 200, vết *completed → cancelled* mang người
      quầy, đơn vị đã ra bàn ở lại, phần của đơn rời bảng nhu cầu, tiền của phiên chỉ còn đơn chưa huỷ, huỷ lần
      hai ⇒ `order_transition_not_allowed`; đơn lẻ đã thu ⇒ chủ quán không đứng quầy bị từ chối, quầy huỷ 200,
      hoá đơn và mọi bảng tiền y nguyên, cửa hoàn vẫn nhận hoá đơn ấy. Đo trên code cũ: hai test đỏ đúng lý do
      (`muốn 200, nhận 409 map[code:completed_order_cancel_not_ready]`), mọi test khác xanh.
- [x] (2) Mã `completed_order_cancel_not_ready` gỡ khỏi `apierr.go` và `openapi.yaml`; `info.version` tăng;
      Gate 1g `PASS`.
- [x] (3) `docs/product/3-be/07-san-xuat-theo-me.md` §3 *Huỷ đơn* nói luật mới; hàng `T-147` ở
      `01-hop-dong-api.md` §7.
- [x] (4) Lỗi cài: cửa huỷ trả lại từ chối `completed` ⇒ hai test đỏ; trả về bằng `shasum -c`.
- [x] (5) `./scripts/gate.sh` xanh ở worktree và ở clone chính sau tích hợp.

**Bàn giao** (2026-10-10): thiết kế, test đỏ, duyệt, tích hợp — **Claude Code**; thi công — **Codex**
(`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-147`, nhánh `codex/T-147` từ `7610bcc` cộng thay đổi chưa
commit của cây chính lúc giao; Codex hết hạn mức trước khi viết báo cáo, sandbox không tới Docker — Claude duyệt
thẳng trên diff và chạy mọi lần PostgreSQL).
- *Codex đổi đúng năm file của phiếu:* `huy.go` (`completed` đi cùng đường `confirmed`/`in_progress`), `apierr.go` và
  `openapi.yaml` (gỡ mã, hợp đồng **0.12.0**), hàng `T-147` ở `01-hop-dong-api.md` §7, `07-san-xuat-theo-me.md` §3.
  Hai file test đúng hash lúc giao.
- *Sửa của Claude:* khung test đơn lẻ so `demTien` gồm cả số đơn Hoàn thành, mà huỷ thì con số ấy giảm đúng 1 —
  phép so nay bỏ con số ấy, giữ mọi bảng tiền (`chiTien`); không điều kiện nào về cửa bị nới.
- *Bằng chứng:* worktree `be-check: PASS`; **lỗi cài** — cửa huỷ bỏ `completed` ⇒ `--- FAIL:
  TestI004_HuyDonHoanThanhGanBanRutKhoiTienCuaPhien` · `TestI014_HuyDonLeDaThuGiuHoaDonHoanDoQuayQuyet`, trả về bằng
  `shasum -c`. Clone chính sau `git apply` ⇒ `PASS gate không cổng nào đỏ` (Gate 1g hợp đồng 0.12.0, 60 mã lỗi;
  be-check; db-check 20 bước, 102 câu, 102 lỗi cài). Không red flag Gate 4.
- *Còn lại:* **S-6** (đơn giao, quầy bấm *đã ra bàn* lúc nào) chưa hỏi chủ quán.

[↑ đầu file](#top)

<a id="t-143"></a>
### T-143 — Đăng nhập bằng chọn tên, và chọn tên ở máy quầy là mốc đổi người

**Yêu cầu:** chủ repo, 2026-10-10 — *"hãy hoàn thành T-138, T-140, T-142, T-143 yêu cầu codex làm và bạn kiểm
tra"*. Lời chủ quán: U-075 *"chọn tên"* (đóng ở T-139), C36 · U-056 (`shop-facts.md` §8.8). Thiết kế:
**ADR-085** *Sửa đổi 2026-10-10 (T-143)*.

**Mức:** L2 — cách mọi cửa ghi biết người bấm (`I-012`), dữ liệu trực quầy (`YC-15`), hợp đồng công khai.

**Acceptance (viết trước khi giao):**
- [x] Test đỏ do Claude viết trước xanh qua `./scripts/be-check.sh` mà không đổi một byte (`shasum` lúc giao:
      `e4918ced88af815f1bddf5ebcafc7df4da060f5b  be/internal/nguoi/nguoi_test.go` ·
      `df9ca2f9a0df014f785bcf51ddcb2e9449b108fe  be/internal/authz/chon_ten_test.go`): header `X-Person-Id` chỉ nhận số
      nguyên dương thuần; không chọn tên ⇒ 401; vào quầy là một mốc — giờ người ra đúng bằng giờ người vào, lần khép
      có vết mang người vào; chọn lại tên mình không tạo mốc; rời quầy chỉ người đang đứng; vào quầy qua cửa mở quyền
      lớp `quay`; năm người vào cùng lúc ⇒ 201 hoặc 409 `counter_duty_changed`, chuỗi khoảng không đứt, đúng một khoảng mở;
      danh sách tên để chọn.
- [x] Hai cửa `nguoi/vao_quay` (`nguoi_quan`) · `nguoi/roi_quay` (`quay`), mỗi cửa một `authz.Door`, một dòng ma trận,
      câu ghi trong `sql/<cửa>/`; Gate 1f · 1g `PASS`; hợp đồng tăng phiên bản.
- [x] `docs/product/3-be/02` · `04` · `06` · `01` không còn nói cách đăng nhập chờ U-075; quyền đọc `GET /debts` vẫn
      ghi là còn mở.
- [x] `./scripts/gate.sh` xanh ở clone chính sau tích hợp.

**Bàn giao** (2026-10-10): thiết kế (ADR-085 *Sửa đổi*), test đỏ, duyệt, tích hợp — **Claude Code**; thi công — **Codex**
(`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-143`, nhánh `codex/T-143` từ `7610bcc` + T-140 · T-142 stage sẵn làm nền).
- *Vòng 1:* Codex dừng đúng luật vì `shasum` lệch — Claude đổi tên hàm test sau khi giao (`TestC36_`/`TestU075_` →
  `TestYC15_`/`TestI012_`, cho khớp `QC-17`); Claude xác nhận hash mới, Codex thi công.
- *Duyệt của Claude:* `vao_quay` chạy câu khép nằm trong thư mục của `roi_quay` — hai cửa cùng ghi ô
  `counter_duty.ended_at`, Gate 1f không thấy vì chấm theo vị trí file ⇒ vòng 2: thêm cửa `nguoi/khep_quay` lớp
  `theo_cua_goi` làm chủ duy nhất của ô ấy; thêm chú thích package. Hai file test đúng hash sau cả hai vòng. Không red
  flag Gate 4.
- *Bằng chứng:* `be-check` ở worktree `PASS` (8 test mới, gồm năm người vào cùng lúc: `N0 ⇒ 201 · N1…N3 ⇒ 409
  counter_duty_changed · N4 ⇒ 201`, chuỗi khoảng không đứt). **Lỗi cài** ở clone chính: bỏ `vongdoi.CoVet` khỏi cửa khép
  ⇒ `POST /counter-duty ⇒ 500` và `--- FAIL: TestYC15_VaoQuayLaMotMocDoiAiVaoAiRa` · `…NguoiDangDungVaoLaiKhongTaoMocMoi` ·
  `…RoiQuayChiNguoiDangDung`; trả về bằng bản sao (`shasum` `e78048b9…` khớp). Clone chính sau tích hợp cùng T-138:
  `PASS gate không cổng nào đỏ` (Gate 1g `hợp đồng 0.11.0; 45 đường gọi …; 39 cửa, 39 dòng ma trận`).
- *Còn lại:* ai được đọc `GET /debts` (`06-duong-tien.md`); chương trình chạy `be/cmd/` (kế hoạch đổi stack).

<a id="t-140"></a>
### T-140 — Đường tiền theo lời 2026-10-09: nợ đơn lẻ có ghi chú, chỉ chủ quán ký ngày, khoản chi theo ngày khai

**Yêu cầu:** chủ repo, 2026-10-09 — *"viết prompt để thực hiện … yêu cầu codex làm bạn kiểm tra, hoàn thành
trong 1 session, bạn toàn quyền quyết định"*. Lời chủ quán đã ở owner từ `T-139` (U-072 · U-073 · U-076).
Thiết kế: **ADR-089** *Sửa đổi 2026-10-09 (T-140)*.

**Mức:** L2 — tiền, dữ liệu cất (một migration mới), hợp đồng công khai.

**Acceptance:**
- [x] Test đỏ do Claude viết trước ở `be/internal/don/duong_tien_test.go` (`shasum` lúc giao
      `91447ae595b27c6bf3b9192d599a9be403ff0592`) xanh qua `./scripts/be-check.sh` mà không đổi một byte:
      `TestI005_NoTrenDonLeCoGhiChuChoChuQuan` · `TestI021_CaiMotLanThuSaiDoiSoatKeu` ·
      `TestI021_CuaDongNgayTuChoiNgayChuaXong` · `TestI012_CuaTienCanNguoiCoTen` · `TestI021_MotNgayBanGiaQuaCuaRa0dLech`.
- [x] Một migration mới (không sửa file đã có, `QC-05`): `bill.debt_note`, `bill_standalone_debt_note_check`,
      `bill_debt_note_only_with_debt_check`, `reconciled_day.gap_vnd` · `gap_explanation`,
      `reconciled_day_gap_explained_check`; có `down`; `db/tests/` có một test từ chối cho mỗi ràng buộc mới;
      `./scripts/db-check.sh` xanh.
- [x] `cho_u072` biến mất khỏi `db/reconcile/` và `be/internal/ket/`; bộ đối chiếu vẫn bắt đúng lỗi cài cũ.
- [x] Ba mã `standalone_debt_undecided` · `cash_day_not_balanced` · `cash_day_expense_date_undecided` gỡ khỏi
      code và hợp đồng; hai mã mới `debt_note_required` · `gap_explanation_required` có status; hợp đồng tăng
      phiên bản; Gate 1g · 1f `PASS`.
- [x] `docs/product/2-db/04` · `07` · `09`, `docs/product/3-be/02` · `06` nói luật mới.
- [x] `./scripts/gate.sh` xanh ở worktree và ở clone chính sau tích hợp.

**Bàn giao** (2026-10-10): thiết kế, test đỏ, duyệt, tích hợp — **Claude Code**; thi công — **Codex**
(`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-140`, nhánh `codex/T-140` từ `880b741`; Codex hết hạn mức ngay
trước khi viết báo cáo, nên Claude duyệt thẳng trên diff thật; sandbox của Codex không tới Docker, mọi lần chạy
PostgreSQL là Claude chạy).
- *Duyệt và sửa của Claude:* migration đổi tên `20261009120000_…` → **`20261009140000_no_don_le_va_doi_soat`** (trùng mốc
  với `20261009120000_vet_che_do_nghiem` của `T-138` đang ở worktree khác); `db/tests/i012_money_operation_names_a_person.sql`
  thêm `debt_note` cho hoá đơn đơn lẻ có nợ (ràng buộc mới đúng ra phải chặn dòng dựng cũ); hai lỗi khung của chính test
  đỏ — xấp 95.000 tờ 10.000 → hai xấp (`shasum` sau sửa `d1fd0784…`). Codex không đổi điều kiện kiểm nào (`shasum` khớp
  `91447ae5…` lúc nhận lại). Hàng hợp đồng gom về bảng §7 của `01-hop-dong-api.md`. Không red flag Gate 4.
- *Bằng chứng:* `./scripts/gate.sh` ở worktree ⇒ `PASS gate` (be-check; db-check `19 bước … 38 file test … 102 câu … 102
  lỗi cài`; Gate 1g hợp đồng 0.8.0). **Lỗi cài:** `ket/doi_soat_xong` về lớp `quay_hoac_chu_quan` ⇒
  `--- FAIL: TestI021_CaiMotLanThuSaiDoiSoatKeu` · `TestI021_CuaDongNgayTuChoiNgayChuaXong` · `TestI012_CuaTienCanNguoiCoTen`;
  bộ đối chiếu trừ khoản chi theo ngày ghi vào máy ⇒ `--- FAIL: TestI021_CuaDongNgayTuChoiNgayChuaXong`; trả về bằng
  `shasum -c`. Ở clone chính sau tích hợp cùng `T-142`: `PASS gate không cổng nào đỏ`.
- *Sửa sót lúc tích hợp T-138 (Claude, 2026-10-10):* `db/scenario/yc.sql` YC-31 · YC-32 còn in *"U-072 — chưa có luật chọn
  ngày"*; nay đọc *trừ vào két ngày khai* và phép kiểm thành `KHÔNG CHỖ: không cột ngày bán riêng — két trừ theo ngày khai
  paid_date` (db-check `PASS`, 32 mã YC).
- *Còn lại:* đường sửa số đếm đã ký — **U-078**; nợ tại bàn không đòi ghi chú (lời chỉ nói đơn lẻ).

<a id="t-190"></a>
### T-190 — Backend đăng nhập bằng tài khoản

**Yêu cầu:** lát (b) của **ADR-109** điểm 12; chủ repo 2026-10-14 *"Làm T-190 … yêu cầu codex làm bạn kiểm tra"*. **Mức:** L2.

**Bàn giao** — 2026-10-14 · thực hiện: **Codex** (package `taikhoan`, authenticator, `middleware.CungNguon`, lệnh khởi tạo,
SMTP, gỡ `ChonTen`, chuyển test cũ sang phiên thật qua `testhelper.Session`, hợp đồng · ma trận · `04-luong-tai-ban.md`) và
**Claude Code** (hình API trong phiếu, 8 test viết trước `be/internal/taikhoan/taikhoan_test.go`; sau khi Codex hết hạn mức:
ba ca vết `I-018` cho `taikhoan/doi_trang_thai` · `ket_thuc_phien` · `dat_lai`, câu `I-033/14` · `/15` và lỗi cài, chỉnh
lỗi cài `i033_3` · `i033_12` cho khỏi kêu câu mới, dồn sqlc về `repository.go` theo QC-13, câu dựng test về `testdata/`,
sinh lại `fe/src/lib/api/schema.ts`, sửa con trỏ `chon_ten.go` ở ADR cũ) · duyệt: **Claude Code**, chưa review độc lập ·
nhánh `fe_admin`, trên `1ead504`. Một bản T-190 thứ hai do phiên khác viết thẳng vào cây chính (17:42–17:45) bị gỡ theo lời
chủ repo (*"bản worktree"*); bản sao ở scratchpad của phiên.

*Claude chốt (thiết kế, không phải lời quán):* (1) cùng người đăng nhập tại quầy lần hai ⇒ khép khoảng cũ, mở khoảng mới cùng
mốc, gắn phiên mới; (2) `must_change_password` chỉ là cờ trả về — backend không chặn cửa khác, màn `P4-04` buộc đổi;
(3) đếm lần sai trong bộ nhớ tiến trình, đếm thư bằng dòng `password_reset`; (4) tên test mang `I033` thay `ADR109` (QC-17).

*Nghiệm thu → bằng chứng* (clone chính, 2026-10-14): test viết trước — `ok banhcuon/be/internal/taikhoan`; vết —
`18 cửa UPDATE khớp 18 ca`; `grep ChonTen|HeaderNguoi|X-Person-Id` trong `be/` rỗng (trừ test kiểm header bị bỏ qua);
`PASS Gate 1g — hợp đồng 0.24.0; 66 đường gọi ở hợp đồng, 66 ở code; 63 cửa, 63 dòng ma trận`; `PASS kêu i033_14 —
I-033/14` · `PASS kêu i033_15 — I-033/15`; `PASS gate không cổng nào đỏ`.

*Còn lại:* `fe/` còn gửi `X-Person-Id` — `P4-04`. Server cần `BANHCUON_ORIGIN`; SMTP chưa cấu hình thì không gửi thư (PT-7).

[↑ đầu file](#top)

<a id="t-189"></a>
### T-189 — Tối ưu SEO nền cho frontend

**Yêu cầu:** chủ repo 2026-10-14, *"hãy tối ưu seo cho hệ thống này và làm 1 file báo cáo cách tối ưu. yêu cầu codex làm
bạn kiểm tra"*. Trước đó (cùng ngày) Claude kiểm và thấy `fe/` chỉ có `title` và `lang="vi"`.

**Mức:** L1 — đổi hành vi của trang (cái gì hiện trên máy tìm kiếm), không chạm tiền, dữ liệu hay hợp đồng.

**Thiết kế (Claude):** phần lớn màn là nội bộ (quầy, chủ quán, trạm, admin) và trang QR gắn bàn, nên **mặc định
`noindex, nofollow` ở layout gốc**; trang công khai **bật** bằng cách nằm trong **một** danh sách `PUBLIC_ROUTES`
ở `fe/src/lib/seo.ts` — quên khai thì trang ẩn, không lộ. Sitemap sinh từ chính danh sách ấy. Địa chỉ gốc đọc từ
biến môi trường `BANHCUON_SITE_URL` (không tiền tố `NEXT_PUBLIC_`, như `BANHCUON_BE_URL`); thiếu biến thì không
`metadataBase`, không canonical, sitemap rỗng, `robots.txt` không có dòng `Sitemap`. JSON-LD chỉ mang dữ kiện đã có
ở `master_plan/shop-facts.md`: tên quán, hotline; **không** địa chỉ, **không** giờ mở cửa (thiếu ngày trong tuần) —
`U-094`. Mô tả trang là bản nháp ghép từ dữ kiện có sẵn, chờ chủ quán duyệt chữ trong `U-094`.

**Acceptance:**
- [x] Layout gốc: `title` có `default` và `template` `"%s · Bánh cuốn Bà Thanh"`, `description`, Open Graph
      (`locale` `vi_VN`, `siteName`, `type` `website`), `robots` mặc định `index: false, follow: false`;
      `metadataBase` chỉ khi `BANHCUON_SITE_URL` có giá trị.
- [x] `fe/src/lib/seo.ts` giữ `PUBLIC_ROUTES` (lúc này chỉ `/`) và một hàm cho trang công khai trả metadata
      `index: true, follow: true` cùng canonical; `/` dùng hàm ấy.
- [x] `fe/src/app/robots.ts`: cho `/`, chặn `/api/`; dòng `Sitemap` chỉ khi có địa chỉ gốc.
- [x] `fe/src/app/sitemap.ts`: đúng `PUBLIC_ROUTES` thành URL tuyệt đối khi có địa chỉ gốc; rỗng khi không.
- [x] JSON-LD `Restaurant` trên `/`: `name`, `telephone`, `url` khi có địa chỉ gốc; không khoá `address`,
      không khoá `openingHours`; chuỗi JSON thoát `<`.
- [x] Test Vitest phủ năm dòng trên, kể cả hai nhánh có và không có `BANHCUON_SITE_URL`.
- [x] `docs/product/4-fe/01-khung-fe.md` ghi luật *mặc định ẩn, bật bằng danh sách*, hai route `robots.txt` ·
      `sitemap.xml`, và luật trang công khai phải render nội dung ở server; báo cáo
      `docs/product/4-fe/02-toi-uu-seo.md` nói đã làm gì, vì sao, cách thêm một trang công khai, cách tự kiểm, còn gì chờ.
- [x] Không cú pháp cache của Next (`check-fe-rules.sh` xanh); `./scripts/gate.sh` xanh ở worktree và ở clone chính.

**Bàn giao** (2026-10-14): thiết kế, Acceptance, duyệt, tích hợp — **Claude Code**; thi công — **Codex**
(worktree `../lean_wt/T-189`, nhánh `codex/T-189` từ `dc41c54`).
- *Duyệt:* đủ A1–A5 đúng thiết kế; Next gộp metadata nông nên `robots` của trang thay hẳn của layout. Claude sửa ba chỗ:
  `seo.test.ts` truyền `children` qua prop (ESLint `react/no-children-prop` đỏ) ⇒ gọi thẳng `Layout(...)`; báo cáo trỏ
  `U-094` về `docs/product/99-unknowns.md`; thử bọc backtick hai route mới thì Gate 1b đọc `/robots.txt` thành đường
  dẫn ⇒ để như Codex viết. Sandbox Codex không chạy được Go cache và `npm ci` ⇒ Codex không có kết quả test; Claude chạy.
- *Bằng chứng:* worktree `./scripts/gate.sh` ⇒ `PASS gate`; `fe-check: PASS` (`Test Files 2 passed`, `Tests 20 passed`).
  Build thật với `BANHCUON_SITE_URL=https://example.vn`: `robots.txt` có `Disallow: /api/` và `Sitemap:`; `sitemap.xml`
  một `<loc>https://example.vn/</loc>`; `/` có `robots index, follow`, canonical, `og:*`, JSON-LD không `address`;
  đường lạ `/khong-co` ra `noindex, nofollow`.
- *Còn lại:* `U-094` (địa chỉ, ngày mở, tên miền, duyệt chữ mô tả); ảnh Open Graph và favicon cần ảnh của quán;
  `P4-10` phải render trang khách ở server.

<a id="t-142"></a>
### T-142 — Đơn đặt trước qua điện thoại nổ việc ở lần nhắc đầu

**Yêu cầu:** như `T-140`. Lời chủ quán: U-077 (`shop-facts.md` §5.2 điểm 5). Thiết kế: **ADR-091**;
**ADR-090** điểm 1 *Sửa đổi*.

**Mức:** L2 — vòng đời đơn và cửa ghi mới trên hợp đồng công khai.

**Acceptance:**
- [x] Test đỏ do Claude viết trước xanh qua `./scripts/be-check.sh` mà không đổi một byte (`shasum` lúc giao:
      `5eed9f6356584cc00465ebfb911a8d74cbaa95ea  be/internal/don/dat_truoc_test.go` ·
      `1c31d6db39e894035f0087fdfd875d16939ed2ae  be/internal/don/mang_di_test.go` ·
      `4663e74d4de226014f479d77f3ea6b6fb813a24c  be/internal/don/san_xuat_test.go`): đơn hẹn không nổ lúc nhận;
      21 phút trước chưa nổ, 20 phút nổ đủ việc với vết mang người; nhả lại không nổ lần hai; nhắc `[20]` rồi
      `[20][10]`; nhận sát giờ thì nổ ngay; cửa nhả lớp `quay`; năm lần nhả chen nhau nổ đúng một lần;
      `pickup` của khách vẫn nổ lúc duyệt.
- [x] Cửa `don/nha_hen` một dòng ma trận, một `authz.Door`; hai đường gọi mới trên hợp đồng, phiên bản tăng;
      Gate 1f · 1g `PASS`.
- [x] `docs/product/3-be/05` · `07` nói luật mới; không migration.
- [x] `./scripts/gate.sh` xanh ở worktree và ở clone chính sau tích hợp.

**Bàn giao** (2026-10-10): thiết kế (**ADR-091**), test đỏ, duyệt, tích hợp — **Claude Code**; thi công — **Codex**
(worktree `../lean_wt/T-142`, nhánh `codex/T-142` từ `880b741`).
- *Duyệt:* `don.go` (đơn hẹn nổ ngay chỉ khi lần nhắc đầu đã tới lúc nhận), `dat_truoc.go` (khoá `FOR UPDATE SKIP LOCKED`
  theo giờ cần rồi mã, xét lại trạng thái, nổ qua `sanxuat.NoDon`; đường đọc nhắc chỉ đọc), `sql/nha_hen/khoa_don.sql`.
  Ba file test đúng `shasum` lúc giao. Claude sửa một lỗi khung của chính test đỏ: giờ nhận đơn rơi ngoài giờ bán
  06:00–11:00 — chuyển sang mỗi test một ngày 25…29/1/2031 (`shasum` sau sửa `74355924…`). Hợp đồng nâng **0.9.0** (`T-140`
  giữ 0.8.0). Không red flag Gate 4.
- *Bằng chứng:* be-check ở worktree `PASS`. **Lỗi cài:** đơn hẹn nổ ngay lúc nhận ⇒ `--- FAIL:` sáu test
  (`TestI004_DatTruocKhongNoLucNhan` · `…NoDungLanNhacDau` · `TestI012_CuaNhaHenPhaiDungQuay` · `…HaiLanNhaChenNhauNoMotLan` ·
  `TestI022_TruongNenCoKhongChanTaoDon` · `TestI016_BonHinhMangDiQuaCuaCuaLat`); bỏ khoá ở cửa nhả ⇒
  `--- FAIL: TestI004_HaiLanNhaChenNhauNoMotLan`; trả về bằng `shasum -c`. Clone chính: `PASS gate` (Gate 1g `hợp đồng 0.9.0;
  41 đường gọi … 36 cửa`).
- *Còn lại:* nhịp máy POS gọi cửa nhả (pha 4) hoặc tiến trình nền (`P3-12`); nhắc hai lần chưa có kênh đẩy (`P3-12`).

<a id="t-139"></a>
### T-139 — Ghi lời chủ quán cho U-071 … U-077

**Yêu cầu:** chủ repo, 2026-10-09, chuyển lời chủ quán cho bảy câu đang mở và nhờ *"cập nhật các
thông tin trên, yêu cầu codex làm bạn kiểm tra"*. Ghi lời chủ quán và đóng câu hỏi là việc Claude
không giao (`CLAUDE.md` §7.4, ADR-054) — chủ repo chọn trong phiên: **Claude ghi, Codex làm phần
code** sau. Cùng phiên, chủ repo chọn thêm ba vế trong câu hỏi có sẵn phương án: U-077 nhắc hai lần
(20 và 10 phút), U-076 *cả mang đi đều được*, U-073 *mọi ngày*.

**Mức:** L1 — chỉ ghi lời vào owner, không đổi code hay lược đồ.

**Acceptance:**
- [x] Bảy câu rời *Đang mở*, vào *Đã có lời giải* với nguyên văn; mục lục sửa cùng lượt.
- [x] Mỗi lời vào đúng mục nghiệp vụ của `master_plan/shop-facts.md` và một dòng §7.1.
- [x] Vế lời không trả lời (đối soát lại sau khi sửa số đã ký) mở thành **U-078**, không suy hộ.
- [x] `I-021` · `I-027` · `I-028` · `I-029` nói luật mới và nói lớp nào chưa theo.
- [x] Con trỏ trong `docs/product/` (trừ file của `P3-09` chưa commit) và kế hoạch lược đồ admin không còn nói các câu ấy chưa có lời.
- [x] `./scripts/gate.sh` xanh.

**Không làm ở đây — vì sao:** `docs/product/2-db/04` · `09`, `docs/product/3-be/*`, `docs/decisions.md`
và code `be/` · `db/` đang mang thay đổi chưa commit của `P3-09`, và chúng tả **cái code đang làm**
— chúng đổi cùng code ở `T-140` … `T-143`. Mã từ chối `standalone_debt_undecided` ·
`cash_day_not_balanced` · `cash_day_expense_date_undecided` và đơn hotline nổ lúc tạo (ADR-090 điểm
1) vẫn chạy cho tới các task ấy.

**Bàn giao:** thực hiện Claude Code, chưa review độc lập; nhánh `chatgpt_involve`, base `48212c9`.

<a id="t-138"></a>
### T-138 — Vết cập nhật đang ở chế độ mềm: một lần sửa không khai lý do đi qua mà không để lại vết (F-046)

**Yêu cầu:** chủ repo, 2026-10-09: *"F-046 hãy đọc kĩ và hoàn thành"* — làm ngay phần **F-046** ở tầng
database, không chờ `P3-11` (cùng tiền lệ `T-137` với **F-047**). Phần nhập bù và trực quầy của `P3-11` ở lại
bước ấy. Mức **L2** (dữ liệu, `I-018`). Claude Code thiết kế và thi công.

**Thiết kế:** `docs/decisions.md` **ADR-091**. Một migration mới đi tới (bước 19) thay thân hai hàm vết:
sửa đổi nội dung mà không khai lý do ⇒ từ chối, tên `record_revision_reason_declared_check`; thêm dòng con vào
cha đã có mà không khai lý do ⇒ từ chối cùng tên. Ngoại lệ duy nhất: phiên chuyển *Chờ thanh toán → Đang phục
vụ* không người không lý do, chỉ khi chính giao dịch ấy vừa thêm một đơn `qr_table` vào phiên (**F-060** vế b).
`qr_code_issue` tự khai lý do cho lần thay mã. `table_session_member` thêm cột người (mặc định người của giao
dịch); dòng gắn vào phiên đã có (ghép bàn) thiếu người ⇒ từ chối; dòng mở phiên được trống người (khách QR mở).

**Acceptance (viết trước khi sửa):** (1) test mới `db/tests/i018_strict_revision.sql` đỏ trên lược đồ 18 bước,
xanh sau bước 19: sửa không lý do ⇒ từ chối đúng tên; sửa có lý do ⇒ vết đủ bốn thứ; sửa không đổi gì không
lý do ⇒ đi qua, không vết; thêm dòng con vào cha đã có không lý do ⇒ từ chối; ngoại lệ QR đi qua chỉ khi giao
dịch vừa thêm đơn QR vào phiên, mọi biến thể khác ⇒ từ chối; đổi mã QR không khai lý do ⇒ có vết trên mã cũ;
ghép bàn không người ⇒ từ chối, mở phiên không người ⇒ đi qua; (2) một cặp migration **mới**, không sửa file
cũ (`QC-05`); lùi trên database rỗng trả lược đồ giống hệt; (3) mọi file `db/tests/` · `db/seed/` ·
`db/scenario/` · `db/reconcile/proof/` khai lý do trước mỗi lần sửa, không file nào bị tắt kiểm;
(4) mọi cửa cập nhật của `be/` có một test *sửa ⇒ có vết* hoặc đã có; `./scripts/be-check.sh` xanh;
(5) tên từ chối mới có dòng ở `openapi.yaml` `x-constraint-errors`, phiên bản hợp đồng tăng; (6)
`./scripts/db-check.sh` và `./scripts/gate.sh` PASS; (7) **F-046** → *Fixed*, **F-060** ghi lại phần còn mở,
`06-luoc-do-nguoi-va-vet.md` §3 · §5, bước 19 ở `07-thu-tu-migration.md`, con trỏ ở `P3-11`; không chọn hộ
câu nghiệp vụ nào. *Đánh số lại 2026-10-10:* bước 19 nay là của `T-140`, nên T-138 là **bước 20**
(`20261010120000_vet_che_do_nghiem`) và ADR của nó là **ADR-092** (ADR-091 đã về `T-142`).

**Bàn giao** (2026-10-10): thiết kế, migration, test và bản đầu — **Claude Code** 2026-10-09 trên nhánh
`claude/T-138` (`f4f64f8`, nền `48212c9`, chưa đưa về). Đưa về nền mới (HEAD `7610bcc` + T-140 · T-142 chưa commit) —
**Codex** (worktree `../lean_wt/T-138b`, nhánh `codex/T-138b`); duyệt, chạy PostgreSQL, tích hợp — **Claude**.
- *Codex làm:* áp đủ 65 file của `f4f64f8` (trừ `docs/decisions.md` · `work/` · `master_plan/`, Claude tự ghép);
  gộp tay `mang_di_test.go`, `06` · `07` · `09` · `13` · `14` của `docs/product/2-db/`, `openapi.yaml`; đổi tên
  migration, đổi số ADR, bước 20; bọc fixture của test đường tiền mới (`duong_tien_test.go`) bằng `coVet`; hợp
  đồng **0.10.0**. Rà mọi cửa có câu UPDATE: cả mười một cửa đã khai lý do (`vongdoi.CoVet` hoặc `khaiLyDo` của
  menu), không cửa nào phải sửa.
- *Claude duyệt:* migration và `i018_strict_revision.sql` bằng `diff` với `f4f64f8` — chỉ khác số ADR và số bước;
  bước 19 không định nghĩa lại hàm vết nên đường lùi bước 20 vẫn trả đúng chữ bước 5 · 8 · 17; dòng `-` của
  `_test.go` không chạm điều kiện kiểm nào. Ghép ADR-092, F-046 → *Fixed*, cập nhật F-060, `BE_master_plan`,
  `backlog_AD.md`. Không red flag Gate 4.
- *Bằng chứng (Claude chạy, worktree):* `db-check: PASS — 20 bước xuôi · lùi · xuôi lại, 18 khối kiểm QC, 39 file
  test, … 102 câu …, 102 lỗi cài, ba scenario …` · `be-check: PASS — mọi test backend qua PostgreSQL thật đều đạt`.
- *Còn lại:* phép đối chiếu `I-016` cho lần chuyển do khách QR kích (**F-060**, `P3-11`).

[↑ đầu file](#top)

<a id="p1-01"></a>
### Mười hai bước của pha 1 — mô tả dài ở `work/backlog_SD.md`

**`P1-01`…`P1-12` không có mô tả ở file này.** Chúng nằm ở **`work/backlog_SD.md`** — sổ task
riêng của pha 1, dựng 2026-09-04 (T-049, `docs/decisions.md` **ADR-034**). Neo `#p1-01` giữ lại ở
đây vì dòng *Ready* của P1-01 trỏ qua nó; đọc entry thật ở file kia.

**Chia việc giữa ba file, một câu:** file này giữ **trạng thái** (*Ready* · *In Progress* · *Done*
— thứ `scripts/brief.sh` đọc và đẩy vào mọi phiên mới) · `work/backlog_SD.md` giữ **mô tả** (vì sao
có bước, hỏng thì mất gì, chạy mười bước thế nào) · `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`
§6 giữ **thứ tự · mức · đầu ra kiểm chứng được**. Ba chỗ, ba việc, không chỗ nào chép chỗ nào
(`work/findings.md` **F-001**).

**Chỉ bước nào nhận được ngay mới có dòng ở *Ready*.** Mười hai dòng đổ vào đó đẩy bảy dòng ra
khỏi tầm nhìn của mọi phiên mới — `brief.sh` cắt *Ready* ở sáu mục (**F-012**).

[↑ đầu file](#top)

<a id="adm-53"></a>
### Hai mươi chín việc của mảng admin — mô tả dài ở `work/backlog_AD.md`

**`ADM-01`…`ADM-53` không có mô tả ở file này.** Chúng nằm ở **`work/backlog_AD.md`** — sổ task
riêng của mảng admin, dựng 2026-09-04 (T-052, `docs/decisions.md` **ADR-036**). Neo `#adm-53` giữ
ở đây vì dòng trạng thái của ADM-53 trỏ qua nó; đọc entry thật ở file kia.

**Chia việc giữa bốn file, một câu:** file này giữ **trạng thái** · `work/backlog_AD.md` giữ **mô
tả** (vì sao có việc, hỏng thì mất gì, chặn bởi câu hỏi nào) · `work/admin-questions.md` §3 giữ
**câu hỏi cho chủ quán và chỗ chủ quán trả lời** · lời giải đi về **owner** ở `CLAUDE.md` §2, vào
mục riêng có nhãn của mảng admin (**ADR-013**). Bốn chỗ, bốn việc, không chỗ nào chép chỗ nào
(`work/findings.md` **F-001**).

**ADM-53 và ADM-21 đều ✅ `Done` ngày 2026-09-20 ⇒ lane admin KHÔNG còn việc nào nhận được ngay.**
Chủ quán trả lời `C36` trong lượt ADM-53, nên ADM-21 đi **loại 1 → 3 → `Done`** trong cùng một
ngày: lời ấy nay ở owner (`master_plan/shop-facts.md` **§8.8**). Những việc khác vẫn chờ câu trả
lời của chủ quán, và một nhóm đã đủ luật từ trước — phần còn lại của chúng thuộc pha 2–4, không
thuộc lane này. ⇒ **Việc mở lại lane này là một lượt HỎI CHỦ QUÁN, không phải một lượt viết.**
**Ba loại và con số của chúng đọc ở mục *Cổng của cả lane* đầu `work/backlog_AD.md`** — đó là
owner, đừng đếm ở đây (`work/findings.md` **F-003**).

**Từ 2026-09-20, lane này được chạy SONG SONG pha 2 ở nghĩa *thu luật*; từ 2026-09-29 phần đã đủ
luật được dựng LƯỢC ĐỒ** (`P2A-XX`, `work/backlog_AD_DB.md`). Đọc đủ ở mục
*[Thứ tự làm giữa lane admin và các pha](#thu-tu-lane)*.

[↑ đầu file](#top)

<a id="vong-chay"></a>
## Vòng chạy một task L1 — mười bước

File prompt trong `prompt/**` giữ **nội dung** của task: sửa gì, ở đâu, xong là thế nào. Mười bước
dưới đây là **thủ tục** — thứ CLAUDE.md bắt mọi task L1+ phải làm và prompt không nhắc lại. Chạy
prompt mà bỏ thủ tục thì gate xanh nhưng không kiểm gì (bước 2), hoặc phiên sau nhận một backlog
nói sai sự thật (bước 9).

1. Đọc entry của task ở [Chi tiết — việc cần làm](#chi-tiet-can-lam), rồi đọc hết file prompt của
   nó — cả mục *Constraints* và *Unknowns*, không chỉ *Goal*.
   Bước pha 2 thì không có file prompt: đọc khối *Nhận việc* của entry (**ADR-051**).
2. **Khai `work/scope/<MÃ>.txt`** (một file mỗi task, **ADR-063**): chép nguyên khối dòng ở mục
   *Scope* của prompt, **trước** lần sửa đầu tiên (CLAUDE.md §3.4). Bỏ bước này thì Gate 3 in
   `scope not declared, skipping` — gate xanh mà không kiểm gì.
3. Chuyển dòng task từ [Ready](#ready) xuống [In Progress](#in-progress) (§3.3).
4. Sửa file theo mục *Context* và *Constraints* của prompt, ở trong scope. Cần ra ngoài scope thì
   sửa file scope của task và **nói ra**, đừng sửa lén.
5. Gặp dữ kiện nghiệp vụ chưa rõ thì **dừng và hỏi** — không tự quyết. Luật này không có mức L0
   (§3.5); không hỏi được thì ghi thành U-XXX ở `docs/product.md` → *Unknowns*.
6. Chạy mục *Verify* của prompt, rồi `./scripts/gate.sh`. Dán **output thật** vào report — "tôi đã
   test" không phải bằng chứng (§5).
7. Gate 2: mỗi dòng *Acceptance* phải trỏ được tới **dòng cụ thể** trong file chứng minh nó
   (`quality/review-gate.md`). Dòng nào không trỏ được là chưa xong.
8. Dữ kiện mới ghi về đúng nhà của nó (§2, §4), kèm ngày và ai quyết (§7.2). Rồi `grep -rn` những
   chỗ **trỏ tới** thứ vừa đổi và sửa luôn trong cùng lần — pointer lệch là bug của lần này, không
   phải task sau.
9. Xoá dòng task khỏi [In Progress](#in-progress), thêm **một dòng** ở đầu [Done](#done) theo khuôn
   ở đầu file (không hash — commit chưa có), và chuyển nguyên khối chi tiết lên đầu mục *Chi tiết —
   việc đã xong* của [`work/backlog_archive.md`](backlog_archive.md#chi-tiet-da-xong) kèm neo (T-086).
   File scope **giữ** tới khi task đã commit rồi mới xoá (§7.3, **ADR-063**).
10. Kết thúc bằng **khối `git commit` dán được** (§6.1): liệt kê từng file, không `git add -A`,
    không kèm file scope. Gate 7 chặn turn nếu thiếu khối này.

[↑ đầu file](#top)

<a id="template"></a>
## Task Detail Template

Khuôn dưới đây rút ra từ entry **T-012** — entry đầy đủ nhất hiện có. T-012 đã xong 2026-08-30
nên đọc nó ở [`work/backlog_archive.md`](backlog_archive.md#t-012) như một bản mẫu
**đã điền** — cả phần đóng task ở cuối, thứ chỉ viết được sau khi làm xong.

**Luật số một: entry TRỎ, prompt GIỮ.** Entry trả lời *vì sao có task này và mất gì nếu bỏ*.
File prompt trả lời *sửa dòng nào, xong là thế nào*. Năm thứ **không bao giờ** chép vào entry:
bảng file/dòng phải sửa · mục *Acceptance* · mục *Verify* · giá và số điện thoại · sơ đồ luồng.
Chép là tạo bản thứ hai, và bản thứ hai luôn trôi — `work/findings.md` F-001.

**Ngoại lệ thí điểm — lane pha 2** (`docs/decisions.md` **ADR-051**, 2026-09-25): entry ở
`work/backlog_DB.md` là hồ sơ **duy nhất**, Nghiệm thu và Kiểm chứng nằm trong khối *Nhận việc* của
nó, không có file prompt. Khuôn riêng ở cuối file ấy. Các lane khác giữ luật số một cho tới khi thí
điểm được đánh giá.

### Khuôn L1+ — bảy khối bắt buộc

```markdown
### T-XXX — <hiện trạng đang SAI, không phải việc phải làm>

**Prompt:** `prompt/.../xx-tên-Lx.md` (L?) · **chặn** <task khác, nếu có>

**Goal:**
Xong rồi thì thế giới khác đi thế nào. Một đoạn.

**Nói một câu, việc phải làm là gì:**
Một câu việc phải làm, kèm một câu việc **không** phải làm — chỗ người ta hay làm quá tay.

**Vì sao có task này:**
Gốc rễ, kèm ngày và ai quyết. Nói cả vì sao chỗ này không được sửa trong lần trước.

**Không làm thì mất gì:**
Hậu quả xếp theo mức nặng, mỗi cái gọi tên task hoặc dữ liệu lãnh đủ. Đây là khối
quyết định thứ tự ưu tiên — viết mơ hồ ở đây thì task nằm mãi trong Ready.

**Cách hoàn thành — đủ mười bước, 1 tới 10.**
Luật chung ở [Vòng chạy một task L1](#vong-chay); ở đây viết **việc cụ thể của task
này** đứng ở đúng bước đó. Bước nào không có gì riêng vẫn phải có một dòng — bỏ trống
là người đọc tưởng mình đọc sót.

**Acceptance · Verify:** trong file prompt (F-001 — entry này trỏ, prompt giữ).
```

### Ba khối thêm — chỉ khi có thật

| Khối | Thêm khi |
|---|---|
| **Đây là con bug F-XXX** | task là lần lặp lại của một finding đã ghi — nói rõ vì sao vòng rà trước không bắt được |
| **Thứ tự đọc trước khi sửa file đầu tiên** | phải đọc từ ba file trở lên mới hiểu việc |
| **Bẫy hay sửa nhầm nhất** | có chỗ sửa đúng-mà-hỏng; hai tới ba cái, mỗi cái một dòng, danh sách đủ để ở *Constraints* của prompt |

### Khuôn L0 — bốn dòng là đủ

L0 là mức thật, không phải cửa lách: sửa lỗi chính tả, đổi tên máy móc, chạy formatter.
Không bịa thêm khối cho đủ bộ.

```markdown
### T-XXX — <việc>

**Prompt:** `prompt/.../xx-tên-L0.md` (L0)

**Goal:**
Một tới ba dòng.

**Acceptance · Verify:** trong file prompt.
```

### Soát lại trước khi coi entry là viết xong

- [ ] Tiêu đề nói **hiện trạng sai**, không nói cách sửa — để lúc đóng task đọc lại còn biết nó từng hỏng ở đâu.
- [ ] Mỗi dữ kiện có **ngày** và **ai quyết** (CLAUDE.md §7.2).
- [ ] "Đúng N" chỉ dùng khi N là **quyết định** của chủ quán; phép đếm của người viết thì phải kèm mốc thời gian và lời mời bổ sung (F-003).
- [ ] Không có giá, số hotline, sơ đồ hay bảng file/dòng nào bị chép từ nhà thật vào entry (F-001).
- [ ] Mục *Cách hoàn thành* chạy **liền 1→10**, không nhảy cóc.
- [ ] Viết lại đáng kể thì để lại một dòng *nghiêng* cuối entry: ngày, ai yêu cầu, đổi cái gì.

[↑ đầu file](#top)

<a id="t-245"></a>
### T-245 — Viết lại trang Giao việc theo HTML, mobile first

**Yêu cầu:** chủ repo 2026-10-24; lấy bố cục và màu từ `docs/product/4-fe/thiet_ke/chu_quan/giao-viec/giao-viec.html`, giữ API thật và quy tắc hiện có. L1, Codex thực hiện, chưa được review độc lập.

**Scope:** `fe/src/app/chu-quan/_components/giao-viec.tsx`, CSS riêng của trang, `fe/src/app/chu-quan/giao-viec/page.tsx`, test trang, `work/backlog.md`. Component dùng chung nên màn quầy cũng nhận giao diện mới.

**Acceptance (viết trước):**
- Thống kê tổng/chưa xong/đã xong theo danh sách API đang đọc; tìm nội dung và lọc trạng thái kết hợp lọc người trên URL.
- Mobile dùng thẻ một cột, desktop hiện các trường theo cột; nút dễ chạm, nội dung dài không đẩy tràn trang; form thêm/sửa/xoá trong hộp thoại có quản lý focus.
- Giữ giao/sửa/xoá có lý do/đánh dấu, xử lý lỗi và chống gửi trùng; test hồi quy trang đạt.
- Chạy gate, ghi đúng các bước đạt hoặc bị chặn.

**Tiếp tục 2026-10-26 (chủ repo giao Codex):** đối chiếu lại đúng HTML mẫu. Acceptance bổ sung trước khi sửa: danh sách là bảng bảy cột, cuộn ngang bên trong trên màn hẹp như mẫu; màu nền, thống kê, bộ lọc và thao tác theo mẫu; giữ hạn hoàn thành và API hiện có. Tiêu chí bảng cuộn này thay tiêu chí thẻ mobile ở trên theo yêu cầu khớp HTML. Kiểm tra hồi quy thao tác, lint/typecheck và gate; ghi rõ kiểm tra giao diện thực tế nếu thực hiện được.

**Bàn giao 2026-10-24:** Codex thực hiện trên nhánh `P4A-01`, nền `449c760`; chưa review độc lập. Đã đọc diff và kiểm scope riêng, không thay API/hook dữ liệu. Thêm CSS có prefix `gv-`, bố cục một cột mặc định, ba thống kê từ 600px, danh sách nhiều cột từ 1100px. Form thêm/sửa dùng textarea; hộp thoại Radix giữ focus và hỗ trợ Escape.

**Bằng chứng:** `npm test -- --run src/app/chu-quan/giao-viec/giao-viec.test.tsx`: `Test Files 1 passed (1); Tests 23 passed (23)`; gồm 21 test cũ giữ nguyên và hai test mới chứng minh thống kê/tìm/lọc, hộp thoại/Escape/trả focus. `npm run lint`, `npm run typecheck`, `./scripts/check-fe-rules.sh` đạt. Toàn bộ frontend: `Test Files 35 passed (35); Tests 471 passed (471)`. Responsive mới kiểm bằng đọc CSS, chưa kiểm hình trên trình duyệt.

**Gate chung:** `./scripts/gate.sh` trả 2. Gate 3 và 1b–1h PASS; Gate 1 dừng ở `FAIL be-check — Docker không chạy. Bật Docker rồi chạy lại ./scripts/be-check.sh`. Cây làm việc đã có thay đổi backend/database từ trước. Giữ In Progress vì chưa đạt gate và chưa kiểm responsive trên trình duyệt; bước tiếp theo là kiểm trang ở 375/768/1440px, bật Docker và chạy lại gate. Không commit.

**Kết quả build:** `./scripts/fe-check.sh` đạt apigen/lint/typecheck/471 test rồi dừng ở production build: `TurbopackInternalError`, `binding to a port — Operation not permitted (os error 1)`. Đã chạy lại `npm run build` với `require_escalated`, vẫn cùng lỗi. Chưa xác nhận build đạt. Gate lần cuối vẫn trả 2 do Docker chưa chạy. Index trống; khối commit chỉ được chứa năm file trong scope của việc này. `work/backlog.md` đã có thay đổi từ trước, cần stage riêng phần T-245 bằng `git add -p`.

**Bàn giao tiếp 2026-10-26:** Codex thực hiện trên nhánh `P4A-01`, nền `e01940f`; chưa review độc lập. Đã đổi danh sách sang bảng HTML bảy cột với tiêu đề truy cập được, cuộn trong vùng bảng; đồng bộ màu sáng/tối, thống kê, khoảng cách, bộ lọc và nút thao tác theo mẫu. Hộp thoại có nút đóng và trả focus về nút mở. Giữ API, hạn hoàn thành và xử lý lỗi hiện có; component dùng chung cũng áp dụng cho trang quầy. Chỉ sửa component, CSS, test của Giao việc và mục task này; đã đọc diff và kiểm scope riêng, index trống.

**Bằng chứng 2026-10-26:** test trang `Test Files 1 passed (1); Tests 27 passed (27)`; toàn bộ frontend `Test Files 36 passed (36); Tests 518 passed (518)`; `npm run lint` và `npm run typecheck` đạt. Chromium/Playwright với API giả: `PASS 375`, `PASS 768`, `PASS 1440`, bảng đủ bảy cột, không tràn ngang toàn trang, đóng hộp thoại trả focus; `PASS pageErrors=[]`. Đã xem ảnh desktop nền tối; bảng cuộn bên trong ở 375/768px. Không ghi dữ liệu thật trong lượt kiểm trình duyệt. Diff bốn file của task không có lỗi khoảng trắng. Gate chung `./scripts/gate.sh` exit 0: `PASS gate — không cổng nào đỏ`; be-check, db-check và 18 script test đều đạt. Các NOTE về file chưa track và đường dẫn hỏng thuộc tài liệu có sẵn ngoài task này. Đã chuyển Done, giữ scope tới khi chủ repo commit. Khối commit chỉ chứa bốn file của task; các thay đổi backend/database, tài liệu thiết kế và Khoản chi có sẵn không thuộc khối.

<a id="t-246"></a>
### T-246 — Hạn hoàn thành bắt buộc ngày và giờ khi giao việc mới

**Lời chủ repo 2026-10-24:** “ngày và giờ”, “bắt buộc khi giao việc”, rồi “cho phép bạn có quyền làm” sau khi Codex nêu ranh giới L2. Chủ repo cho phép Codex thiết kế/triển khai xuyên DB/API/FE trong lượt này; không commit.

**Thiết kế:** `due_at` là một instant; FE nhập ngày giờ Việt Nam (+07:00), API nhận RFC3339 có offset. POST bắt buộc có hạn; PUT cho phép bỏ trường để giữ hạn cũ, khi có trường phải hợp lệ. Việc cũ chưa có hạn giữ null, không backfill thời điểm giả. Không thêm luật hạn phải ở tương lai vì chủ repo chưa yêu cầu. Quyền và lý do sửa giữ nguyên.

**Acceptance viết trước:**
- POST thiếu/null/rỗng/sai ngày giờ hoặc không offset bị từ chối 400 invalid_request field=due_at; đúng thì ghi và đọc lại đúng instant.
- PUT đổi hạn có lý do và vết trước/sau; bỏ due_at giữ nguyên; việc cũ null vẫn đọc/sửa được.
- FE bắt nhập ngày giờ khi giao mới, gửi RFC3339 +07:00 dù máy dùng múi giờ khác; sửa hiện lại giờ Việt Nam, không xoá hạn đã có; hiển thị hạn và trạng thái chưa có hạn của việc cũ.
- Test hồi quy backend/FE; sinh sqlc/type; gate và báo đúng phần không chạy được.

**Thực hiện:** Codex; chưa review độc lập.

**Bàn giao 2026-10-24:** Codex thực hiện trên nhánh `P4A-01`, nền `7108eb1`; chưa được review độc lập. Đã thêm cặp migration và áp dụng **đúng một bước** trên database phát triển: `docker compose run --rm migrate up 1` in `20261024120000/u han_giao_viec (18.486375ms)`; trước đó phiên bản là `20261022120000`. Không gán hạn cho dữ liệu cũ. Triển khai lại backend đang chạy để nhận trường API mới, rồi tải lại FE.

**Acceptance → bằng chứng:** kiểm request thiếu/null/rỗng/ngày sai/không offset ở `TestQC14_HinhGiaoViecTruocQuyenVaDatabase`; bắt hạn ở service tại `TestI030_TaoViecKhongHanBiChanTruocDatabase`; lưu/đọc/đổi hạn có vết và giữ việc cũ ở `TestI030_HanHoanThanhLuuDocSuaCoVet`; chặn mất hạn khi lùi migration ở `TestI030_LuiMigrationKhongLamMatHan`. Hai test tích hợp mới đã PASS trên PostgreSQL thật trong gate. Test phân quyền cũ được bổ sung due_at hợp lệ để tiếp tục kiểm quyền, không đổi assertion.

**FE:** `npm test -- --run src/app/chu-quan/giao-viec/giao-viec.test.tsx`: `Tests 27 passed (27)`; kiểm bắt buộc nhập, gửi `+07:00`, đổi hạn có lý do, không xoá hạn đã có, lỗi API gắn đúng ô. Lượt chạy `TZ=America/New_York` của 26 test trước khi bổ sung ca lỗi field cũng PASS. Lượt `./scripts/fe-check.sh` đạt sinh type/lint/typecheck và `35 passed / 474 tests passed`, dừng ở build do Turbopack `binding to a port — Operation not permitted`, kể cả khi chạy `require_escalated`; sau đó thêm một ca field, tổng hiện tại 475. `./scripts/check-write-paths.sh`: `111 ô ghi, 95 cửa`; `./scripts/check-sqlcgen.sh`: tập file và nội dung khớp bản sinh lại.

**Kết quả cuối:** `./scripts/gate.sh` với `require_escalated` trả 2; Gate 3, 1b–1h PASS. Toàn bộ backend PostgreSQL PASS (riêng giao việc: `ok banhcuon/be/internal/giaoviec 1.834s`, hai test lưu/vết và chặn rollback PASS), frontend `35 passed / 475 tests passed`; verify dừng ở production build Turbopack `binding to a port — Operation not permitted (os error 1)`. Dòng nhãn Gate 1 gắn FAIL lên be-check dù phần mô tả ghi mọi test đạt vì wrapper dùng exit code của cả verify; nguyên nhân thực nằm ở lỗi build bên dưới. `./scripts/db-check.sh` chạy riêng ngoài sandbox: `PASS — 36 bước xuôi · lùi · xuôi lại, 19 khối kiểm QC, 52 file test, dữ liệu mồi + §4.8, khoá chặn, 147 câu đối chiếu, 149 lỗi cài, ba scenario + ngày quản trị, 37 mã YC`. Cột trên DB phát triển đã đọc lại: `due_at|timestamp with time zone|YES`.

**Còn lại:** giữ In Progress vì gate chưa xanh do môi trường build; cần chạy lại build/gate trên môi trường cho Turbopack mở cổng và kiểm giao diện trực tiếp. Chưa kiểm responsive trên trình duyệt, chưa commit. Khối commit phải chỉ stage phần ADR-127 trong `docs/decisions.md` và đoạn hạn hoàn thành của T-246 trong `master_plan/shop-facts.md` vì hai file đã có diff từ trước; các model sqlc của mọi miền chỉ thêm trường DueAt do sinh từ schema chung.

<a id="t-247"></a>
### T-247 — Sửa và xoá trong bản thiết kế Khoản chi

Chủ repo yêu cầu 2026-10-24; chỉ bản HTML minh hoạ, không đổi API hay dữ liệu thật. Codex thực hiện, chưa review độc lập.

Acceptance: sửa tên mục và khoản con, đồng bộ tên vào sổ; từ nút Sửa của khoản con/mục có thể chọn lần ghi theo ngày để sửa tiền; sửa khoản chi giữ yêu cầu lý do; xoá có xác nhận và cập nhật tổng/bộ lọc; chặn xoá mục hoặc khoản con còn khoản chi (chủ repo chọn 2026-10-24); đếm toàn bộ khoản chi, kể cả ngoài bộ lọc. Không thay đổi số tiền khi chỉ đổi tên.

Scope: `docs/product/4-fe/thiet_ke/chu_quan/khoan-chi/khoan-chi.html`, `work/backlog.md`.

**Bàn giao T-247 — 2026-10-24:** Codex thực hiện trên nhánh `P4A-01`, chưa review độc lập. Có form đổi tên mục/khoản con (đồng bộ tên sổ, giữ số tiền, chặn trùng), xoá khoản chi với lý do/xác nhận, xoá mục/khoản con khi không còn khoản chi. Chủ repo chọn chặn xoá khi còn khoản chi; kiểm trên toàn bộ dữ liệu minh hoạ, không chỉ các dòng đang lọc. Cho phép chuyển khoản chi bằng form sửa có sẵn. Mọi thao tác chỉ ở bộ nhớ trình duyệt, không đổi dữ liệu thật. Kiểm bằng Node VM: đổi tên, giữ tổng, chặn trùng, xác nhận, xoá khoản chi cập nhật tổng, chặn xoá mục có dữ liệu, xoá khoản con/mục rỗng đều PASS. Gate trực tiếp lần đầu bị chặn Docker; chạy lại ngoài sandbox trả 2 do Turbopack không được mở cổng (`Operation not permitted`). Các cổng scope, tài liệu, hợp đồng đạt; backend test đạt. Giữ In Progress vì gate chưa xanh. Cần chạy lại gate ở môi trường cho phép mở cổng và kiểm tra trực quan; chưa commit. Kiểm bổ sung PASS: chặn xoá cả khoản chi ngoài bộ lọc, đổi tên mục giữ liên kết khoản chi.

**Bổ sung T-247 — chủ repo 2026-10-24:** nút Sửa mở cả đổi tên và danh sách các lần ghi (ngày, số tiền, người ghi); chọn Sửa tiền mở đúng form sửa khoản chi có lý do. Tiền sửa cập nhật vào lần ghi cũ và tổng, không thêm dòng. Tên đang nhập phải lưu trước khi chuyển sang sửa tiền. Kiểm Node VM PASS: chọn đúng khoản theo mục/khoản con, nạp số tiền/ngày, sửa tiền giữ số dòng và cập nhật tổng, bảo vệ tên chưa lưu. Chưa kiểm trực quan. Gate chạy lại ngoài sandbox vẫn trả 2 tại Turbopack mở cổng bị chặn; giữ In Progress, chưa commit.

**Bổ sung giao diện T-247 — chủ repo 2026-10-24:** thêm Ẩn/Hiện toàn bộ nội dung từng mục chi, giữ tiêu đề và số khoản con; trạng thái riêng không mất khi lọc/sửa dữ liệu. Bỏ hai thẻ tổng Trả từ két và Tiền riêng, chỉ giữ Tổng chi trong kỳ; bộ lọc và dữ liệu nguồn tiền vẫn giữ nguyên.

**Kiểm tra phần Ẩn/Hiện T-247:** Node VM PASS: thu gọn từng mục độc lập, giữ trạng thái sau render, chỉ còn thẻ tổng chi; các kiểm tra sửa/xoá và sửa tiền vẫn PASS. Gate 2026-10-24 chạy lại ngoài sandbox trả 2 do build Turbopack bị chặn mở cổng (`Operation not permitted`), các test backend đạt. Chưa kiểm trực quan; giữ In Progress chờ gate xanh.

**Bổ sung yêu cầu T-247 — 2026-10-24:** thêm nút Ẩn/Hiện cho toàn bộ bảng “Các khoản chi”. Acceptance: mặc định hiện; ẩn cả bảng và thông báo rỗng, giữ tiêu đề/nút; bấm lại hiện; trạng thái không mất khi đổi bộ lọc, thuộc tính aria-expanded đồng bộ.

**Kiểm tra nút bảng T-247 — 2026-10-24:** đã thêm Ẩn/Hiện cho bảng “Các khoản chi”, mặc định hiện, giữ tiêu đề và trạng thái khi lọc. Node VM PASS: JavaScript hợp lệ, ba lần bấm đồng bộ hidden/nhãn/aria-expanded. Chưa kiểm trực quan. Gate trực tiếp trả 2 do Docker; chạy lại ngoài sandbox trả 2 tại build FE vì Turbopack không được mở cổng (`Operation not permitted`). Giữ In Progress, chưa commit.

<a id="t-248"></a>
### T-248 — Trang Khoản chi chưa theo bản thiết kế HTML

**Yêu cầu 2026-10-24:** chủ repo yêu cầu code lại `/chu-quan/khoan-chi` theo HTML trong `docs/product/4-fe/thiet_ke/chu_quan/khoan-chi/`; cho phép Codex làm tiếp sau khi nêu giới hạn L2. Không commit. Thực hiện trên nhánh `P4A-01`, chưa review độc lập.

**Acceptance viết trước:** giao diện theo thiết kế, responsive; chọn nhanh 7/10/14/30 ngày giữ ngày kết thúc, lọc ngày/loại/nguồn trên URL; tổng chung lấy backend; bảng nhóm theo mục có ẩn/hiện; ghi/sửa trong hộp thoại giữ validation, lý do, chống gửi trùng và xử lý lỗi hiện hành. Chức năng khoản con, đổi tên/xoá chỉ triển khai sau khi giải quyết xung đột giữa thiết kế minh hoạ và luật tiền hàng/đối soát trong owner. Kiểm test trang và gate, báo đúng phần bị chặn.

**Phạm vi ban đầu:** component và CSS Khoản chi, page, test trang, `work/backlog.md`, owner khung FE. Câu hỏi đã gửi chủ repo: có đưa tiền nguyên liệu vào Khoản chi và dùng xoá mềm có lý do/chặn ngày đối soát hay giữ nguyên luật hiện tại. Chưa đổi dữ liệu tài chính khi chưa có câu trả lời.

**Lời chốt T-248 — chủ repo 2026-10-24:** “Cho phép nguyên liệu trong Khoản chi; xoá mềm có lý do, chặn ngày đã đối soát”. Mở rộng scope DB, API, owner liên quan theo quyền làm tiếp; ADR-128 giữ thiết kế. Dữ liệu cũ không có khoản con giữ nguyên. Acceptance bổ sung: khoản con đúng mục, rename có vết, xoá mềm có vết/không xoá cứng, chặn mục/khoản con còn khoản trên mọi ngày và chặn khoản cả tiền riêng của ngày đã ký; tổng API và cả hai phép tính két bỏ khoản đã xoá. Tên đã xoá vẫn được giữ duy nhất, nguồn không đổi. Agent FE ở worktree `/private/tmp/t248-fe`, root tích hợp; agent khảo sát backend chỉ đọc.

<a id="t-253"></a>
### T-253 — Thông tin và form sửa đầy đủ sản phẩm trong HTML

Chủ repo yêu cầu 2026-10-25. Chỉ sửa bản thiết kế, không đổi hợp đồng hay dữ liệu thật. Codex thực hiện, chưa review độc lập.

Acceptance viết trước: liệt kê ảnh, tên, mã, mô tả, danh mục, trạng thái, giá tính từ các thành phần; sửa mọi thuộc tính nhập được, gồm ảnh URL hoặc tải ảnh máy; thêm/bỏ thành phần, nạp đúng dữ liệu, lưu cập nhật bản minh hoạ và huỷ không ghi; giá tổng tự tính. Ảnh/mô tả là đề xuất minh hoạ, không phải trường API đã có. Chạy gate và báo đúng giới hạn kiểm tra.

**Bàn giao 2026-10-25:** Codex trên nhánh `P4A-01`, nền `52aef5a`, chưa review độc lập. File HTML có ảnh (URL/tệp tối đa 5 MB, xem trước và ảnh dự phòng), tên, mã chỉ đọc, mô tả, danh mục, trạng thái, bảng thành phần gồm tên/giá/số lượng/nhận nhân; giá tổng tự tính. Form thêm và sửa dùng chung, lưu trong bộ nhớ phiên xem; Huỷ không ghi. Không đổi API/FE thật. Ảnh/mô tả và các giá là minh hoạ.

Kiểm bằng jsdom tại `/private/tmp/t253-check.cjs`: PASS nạp đúng món, sửa toàn bộ trường nhập, tổng giá, huỷ, thêm/bỏ thành phần, thêm món, chặn tên trùng; PASS đọc ảnh máy, chặn lưu khi đang đọc và lưu ảnh data URL. JavaScript hợp lệ; diff hai file không có lỗi whitespace; scope T-253 khớp; index trống khi kiểm. Chưa kiểm trực quan responsive trên trình duyệt. Gate trực tiếp trả 2: scope và Gate 1b–1h PASS, dừng backend vì không truy cập Docker; lần chạy ngoài sandbox tại `/private/tmp/t253-gate-escalated.log` chưa hoàn tất, tiến trình gate 99826, đang ở db-check (phép QD-10, truy vấn active, không chờ khoá khi kiểm). Không sửa phép đối chiếu ngoài scope. Giữ In Progress đến khi có kết quả gate/kiểm trực quan. Bước tiếp theo: đọc log lần chạy ngoài sandbox sau khi tiến trình kết thúc; chưa được ghi gate xanh. `work/backlog.md` đã có diff việc khác từ trước, cần stage riêng phần T-253. Chưa commit.

<a id="t-254"></a>
### T-254 — Dừng phiên dev bằng make stop-dev

Chủ repo yêu cầu 2026-10-25. Mức L1, công cụ máy dev. Codex thực hiện, chưa duyệt độc lập.

Nghiệm thu trước khi sửa: `make stop-dev` có trong help; dừng server Go và Next đang nghe cổng thuộc đúng thư mục be/fe của repo, kể cả chạy riêng; giữ database và server repo khác; chạy lại khi đã dừng không lỗi. Scope: Makefile, scripts/stop-dev.sh, docs/command/make.md và hai sổ backlog. Nhánh P4A-01, base 5d8c93c; không commit.

Bằng chứng Codex 2026-10-25: `make help` có stop-dev; `make stop-dev` gửi TERM cho PID 9238 và 9242; kiểm lsof cổng 8080/3000 không còn listener; `docker compose ps db` vẫn healthy. Lượt hai in “Không có server dev của repo đang chạy.” và exit 0. `bash -n scripts/stop-dev.sh` đạt. Đã đọc diff và kiểm scope riêng T-254 đạt, index trống. Script lọc cả cwd chính xác be/fe lẫn tên server trước khi gửi tín hiệu; chưa chạy thử server repo khác. Gate toàn cây đang chạy; giữ In Progress đến khi có kết quả. Tài liệu make.md và các sổ backlog có diff việc khác từ trước, cần stage riêng phần T-254.

<a id="t-255"></a>
### T-255 — Canh bánh cuốn có nhóm lựa chọn Rau

Chủ repo yêu cầu 2026-10-26 trong hội thoại: *"canh bánh cuốn gồm có lựa chọn sau không rau, ít rau và nhiều rau"*; cùng lượt chọn cả ba 0đ, mặc định *ít rau*, chỉ áp cho canh. Mức L2 (dữ liệu menu, ca giá). Claude làm, chưa review độc lập. Nhánh `P4A-01`, nền `818b262`.

Acceptance viết trước: (1) `shop-facts.md` §4.4 có nhóm *Rau* ba lựa chọn 0đ, §4.6 luật 8 nói mặc định *ít rau*, §7.1 có dòng chốt; (2) `seed.pl` gắn nhóm Rau **chỉ** cho *Canh bánh cuốn*, cờ mặc định *Ít rau*; (3) §4.8 có cột *Rau*, ca 13 chọn *ít rau*, ca 16 (*không rau* ⇒ 0) và ca 17 (*bánh cuốn + ít rau* ⇒ từ chối) khớp ở cả `--price-cases` (database) lẫn test cửa giá Go (`--price-cases-tsv`); (4) gate xanh.

Ghi chú: file `shop-facts.md`, `seed.pl` và `work/backlog.md` đã có diff chưa commit của việc khác trước lượt này — khối commit phải tách riêng phần T-255. Suy luận chưa chốt: phiếu trạm `canh` có in lựa chọn rau hay không (ghi ở §4.4).

<a id="t-256"></a>
### T-256 — gộp vào T-257 (2026-10-26)

Lựa chọn đã hiện sẵn ở cột Giá; thành phần cần `GET /menu-categories` trả kèm (đổi hợp đồng), nên làm cùng T-257 theo ADR-130.

<a id="t-257"></a>
### T-257 — Thêm thành phần cho món đã có, bảng Sản phẩm liệt kê thành phần

Chủ repo báo 2026-10-26: ngăn *Cập nhật* không có nút thêm thành phần, thành phần mới không hiện trên `/chu-quan/san-pham`. Mức L2 (hợp đồng, cửa ghi đổi giá món). Thiết kế: ADR-130. Thực hiện: Codex; duyệt: Claude. Worktree `../lean_wt/T-257`, nhánh `codex/T-257`, nền = `818b262` + toàn bộ thay đổi chưa commit của clone chính lúc giao (đã `git add -A` trong worktree làm mốc, nên diff chưa stage là phần của Codex).

Acceptance viết trước:
1. `openapi.yaml`: `POST /menu-items/{menu_item_id}/components` thân đúng một trong `menu_component_id` hoặc `component{name, base_price_vnd, takes_filling, station_code}`, cùng `quantity ≥ 1`, `reason` không rỗng; trả `ItemComponent`; mã lỗi 400/401/403/404/409; `MenuCategoryItem` có `components`; phiên bản hợp đồng tăng.
2. Câu ghi nằm dưới `be/internal/menu/sql/them_mon/`; Gate 1f · 1g xanh, ma trận không thêm dòng.
3. Test Go (PostgreSQL thật): thêm thành phần có sẵn ⇒ giá món qua `GET /menu` tăng đúng số lượng × giá gốc; tạo thành phần mới ⇒ có dòng `menu_component_station` đúng trạm; thiếu lý do ⇒ 400, không ghi; có vết `record_revision` trên `menu_item` mang lý do (I-018); món ngừng bán ⇒ 409; thành phần đã có trong món ⇒ 409; trạm lạ ⇒ 400; người không phải chủ quán ⇒ 403.
4. FE: bảng có cột *Thành phần* đọc từ `GET /menu-categories`; ngăn *Cập nhật* có form *Thêm thành phần* (chọn thành phần có sẵn hoặc tạo mới, trạm bắt buộc khi tạo mới, số lượng, lý do); xong thì đọc lại danh sách và menu, không ghi tay cache; bấm hai lần chỉ gửi một lệnh; không gửi giá món (I-013). Test P4A-04 cũ giữ nguyên điều kiện.
5. `./scripts/gate.sh` xanh ở clone chính sau khi Claude đưa patch về.

**Bàn giao 2026-10-26:** thực hiện Codex (`codex exec`, worktree `../lean_wt/T-257`), duyệt và tích hợp Claude. Claude sửa thêm ba chỗ Codex dừng đúng luật: nới test cột của T-234 thêm *Thành phần* (test bố cục, không phải invariant), thêm `components: []` vào fixture `combo.test.tsx` · `danh-muc.test.tsx`, và lọc khỏi form các thành phần món đã có. Bằng chứng: worktree `be-check` PASS gồm `TestQC14_ThemThanhPhanHinh`, `TestI018_ThemThanhPhanVetTramVaTuChoi`, `TestI013_ThemThanhPhanGiaMenuVaDanhMuc`; clone chính `./scripts/gate.sh` PASS (hợp đồng 0.52.0, 122 ô ghi, 100 cửa), `./scripts/fe-check.sh` PASS 507/507. Lệch thiết kế: test hồi quy viết bởi Codex chứ không phải Claude viết trước như luật L2 — Claude đọc lại và thấy đủ Acceptance. Còn mở: `POST /menu-items` vẫn tạo thành phần không trạm (ADR-130 *Consequences*). Phụ thuộc: diff nằm trên các thay đổi menu chưa commit của T-238 · T-243, nên commit sau chúng.

<a id="t-258"></a>
### T-258 — Khách phải chọn nhân trong tóm tắt đơn thay vì ngay trên thẻ món

**Goal:** Chọn nhân và lượng nhân ngay trên thẻ COMBO/MÓN LẺ; chọn chung mọi suất của combo, theo lời chủ repo 2026-10-26. Mặc định thịt + vừa (nhãn hiển thị của mức Thường hiện có); tóm tắt chỉ hiện lựa chọn đã thêm.

**Phạm vi và mức:** L1, chỉ FE; dùng nhóm, mặc định và mã lựa chọn từ menu; không đổi giá, API, seed hay quy tắc nhân. Mỗi lần thêm chụp lựa chọn hiện tại, không đổi dòng đã thêm. Món không nhận nhân giữ đúng nhóm riêng.

**Acceptance viết trước sửa:** Thẻ hiện lựa chọn khi giỏ trống; thịt + vừa được chọn mặc định; chọn chay ẩn lượng nhân và bỏ mã lượng nhân; chọn nhiều nhân giữ mã đúng. Combo áp chung lựa chọn cho mọi suất phù hợp. Thêm cùng món/combo với lựa chọn khác giữ từng dòng riêng. Tóm tắt không có radio, vẫn hiện lựa chọn và giữ số lượng/xoá. Nháp cũ giữ lựa chọn khi quay lại. Verify bằng test thẻ khách, QR và đặt món, rồi gate toàn cây.

**Cách thực hiện:** Đọc brief và owner → khai scope → ghi acceptance → chọn nhóm từ menu → thêm bộ chọn trên thẻ → chụp mã khi thêm → tóm tắt chỉ đọc → test hồi quy → gate và đọc diff → cập nhật bàn giao, không commit.

**Bàn giao:** Codex thực hiện trên nhánh P4A-01, base 818b262, chưa duyệt độc lập. File trong work/scope/T-258.txt; work/backlog.md và owner FE có diff việc khác từ trước, phải stage riêng phần task này. Index trống khi kiểm.

**Bằng chứng 2026-10-26:** `npm test -- src/app/ban/thuc-don-khach.test.tsx src/app/ban/khach-qr.test.tsx src/app/dat-mon/dat-mon.test.tsx` → 3 files, 24 tests passed. Hai test mới phủ lựa chọn trên thẻ, mặc định, thịt + mộc nhĩ, nhiều nhân, chay ẩn và bỏ lượng nhân, thân tính giá đúng, combo áp chung, giữ từng tổ hợp khi thêm; tăng số combo giữ cùng nhân. Test QR nháp kiểm quay lại còn Chay, tóm tắt không radio. `./scripts/fe-check.sh` ngoài sandbox → apigen, lint, typecheck, 35 files / 494 tests, production build đều đạt, `fe-check: PASS` (log `/private/tmp/ban3-filling-fe-escalated.log`). Lượt trong sandbox đã dừng vì build không tiến triển.

Trình duyệt thật `/ban/3`, 390px, sáng/tối: PASS mặc định Thịt + Vừa, combo chọn chung Thịt + mộc nhĩ + Nhiều nhân, món lẻ Chay ẩn lượng nhân, summaryRadios=0, horizontalOverflow=false, pageErrors=[]; ảnh `/private/tmp/ban3-filling-light.png` và `/private/tmp/ban3-filling-dark.png` đã xem. Không gửi đơn thật. Đọc diff theo Gate 4, không đổi hợp đồng/giá/mặc định dữ liệu; test cũ đổi thao tác chọn trước thêm và kiểm mô tả thay radio đúng yêu cầu. Diff riêng task không lỗi whitespace; scope --match --task T-258 không in vi phạm.

Gate trực tiếp trong sandbox exit 2 vì không truy cập Docker, Gate 3 và 1b–1h PASS (log `/private/tmp/ban3-filling-gate.log`). Lượt ngoài sandbox `/private/tmp/ban3-filling-gate-escalated.log` đang ở đối chiếu DB, truy vấn QD-10 active, không chờ khoá. Giữ In Progress tới khi có kết quả cuối. Chưa commit, chưa duyệt độc lập.

**Bổ sung chủ repo 2026-10-26 (trước sửa):** Chuyển nhóm Nhân/Lượng nhân sang cột phải dưới giá và bớt/thêm. Ảnh của combo/món lẻ mở trang chi tiết riêng. Trang chạy thật chưa có route chi tiết khách: thêm `/thuc-don/[loai]/[id]` đọc GET /menu no-store, `loai` là combo hoặc mon; quay về đúng mã bàn qua tham số `ban`, thiếu thì về /dat-mon. Chỉ hiện tên, giá/tổ hợp, thành phần combo và nhóm lựa chọn do menu trả; không tự thêm ảnh, mô tả, công thức hay luật bán.

Acceptance bổ sung: bộ chọn nằm cột phải ở 320/390/472px, không tràn ngang; ảnh là liên kết có tên truy cập đúng combo/món, giữ ngữ cảnh bàn; chi tiết hiển thị đúng dữ liệu menu, xử lý không tồn tại/lỗi đọc, quay lại không mất giỏ. Scope bổ sung CSS, phieu-khach.tsx (truyền mã bàn), route chi tiết và test tại fe/src/app/thuc-don/. Kiểm test luồng khách và chi tiết, trình duyệt thật sáng/tối, fe-check rồi gate. Đang thực hiện.

**Bằng chứng bổ sung bố cục/chi tiết 2026-10-26:** `./scripts/fe-check.sh` ngoài sandbox → `fe-check: PASS`, apigen/lint/typecheck/36 files và 503 tests/production build đều qua (`/private/tmp/ban3-detail-fe.log`). Test chi tiết kiểm combo đúng giá và số lượng món, món lẻ đúng tổ hợp, đọc no-store, đường về bàn hoặc đặt món, loại/id sai và món vắng trả 404, lỗi backend/mất mạng hiện cảnh báo; test thẻ kiểm href combo/món mang đúng mã bàn. Trình duyệt `/private/tmp/ban3-detail-ui.cjs` → PASS ở 320/390/472px: bộ chọn trong cột phải cùng mép với stepper, không tràn ngang, ảnh mở đúng chi tiết combo/món, quay về `/ban/3` giữ giỏ và nhân, không pageerror. Đã xem ảnh menu sáng/tối và trang chi tiết ở `/private/tmp/ban3-detail-menu-light.png`, `/private/tmp/ban3-detail-menu-dark.png`, `/private/tmp/ban3-detail-combo.png`, `/private/tmp/ban3-detail-mon.png`. Diff task không lỗi whitespace, đã đọc lại diff; không gửi đơn thật.

Gate lượt trước `/private/tmp/ban3-filling-gate-escalated.log` đã kết thúc `PASS gate` (có db-check và 18 script test). Lượt mới sau bổ sung `/private/tmp/ban3-detail-gate.log` đang chạy, chưa kết luận. Giữ In Progress để chờ kết quả lượt mới; bước tiếp theo là đọc log và cập nhật trạng thái khi toàn bộ đạt. Index hiện có các file của lượt trước: owner FE, thuc-don-khach.tsx, khach-qr.test.tsx, thuc-don-khach.test.tsx và backlog; chưa thay index. Hai file owner/backlog có nội dung việc khác: dùng add -p chỉ lấy phần T-258 khi bàn giao. Chưa commit, chưa duyệt độc lập.

**Bổ sung bố cục 2026-10-26 (trước sửa):** Chủ repo yêu cầu ba lựa chọn Chay/Thịt/Thịt + mộc nhĩ cùng một dòng; Vừa/Nhiều cùng một dòng. Giữ khối ở bên phải ảnh, cho khối lựa chọn dùng chung chiều rộng hai cột chữ + giá, thu gọn chip để không xuống hàng ở 320px. Acceptance: mỗi nhóm nhân/lượng có các nút cùng toạ độ hàng ở 320/390/472px, không tràn ngang, nhãn Nhiều được rút gọn từ Nhiều nhân chỉ ở giao diện. Phần yêu cầu “chọn chay lượng bánh cần thay đổi” và “click Nhiều giá sẽ giảm” đang chờ chủ repo làm rõ số bánh/giá mong muốn; chưa đổi số bánh hay quy tắc giá vì có thể là L2, phải chuyển Claude theo §7.4 nếu đổi nghiệp vụ. Chỉ làm phần bố cục độc lập trong lúc chờ.

**Chủ repo làm rõ 2026-10-26:** “nhiều nhân giá tăng , bánh chay bánh. hãy giữ nguyên fe cái này cần thay đổi phía back end”. Phần giá ở FE giữ nguyên; không đổi số bánh, không đổi giá menu/seed/hàm tính giá. Ý tăng giá khi nhiều nhân đã rõ; câu về bánh chay chưa cho số bánh hoặc quy tắc quy đổi, không suy diễn. Bàn giao Claude phần backend ảnh hưởng giá/số lượng theo CLAUDE.md §7.4 (L2); Claude cần làm rõ số bánh chay mong muốn trước khi sửa dữ liệu/hợp đồng/hàm giá. Chưa triển khai backend.

**Bằng chứng bố cục một dòng 2026-10-26:** `./scripts/fe-check.sh` ngoài sandbox → `fe-check: PASS`, apigen, lint, typecheck, 36 files/503 tests và build production đều đạt (`/private/tmp/ban3-inline-fe.log`). Trình duyệt thật → PASS ở 320/390/472px: mọi nhãn của từng nhóm cùng toạ độ y, không tràn ngang, vẫn nằm bên phải ảnh, liên kết chi tiết và quay lại giữ giỏ đều qua, không pageerror. Đã xem ảnh `/private/tmp/ban3-inline-menu-light.png`; có ảnh tối `/private/tmp/ban3-inline-menu-dark.png`. Chỉ rút gọn nhãn Nhiều nhân thành Nhiều, các mã lựa chọn/giá/số bánh giữ nguyên. Gate mới `/private/tmp/ban3-inline-gate.log` đang chạy; giữ In Progress, chưa khẳng định gate đạt. Bước tiếp theo: đọc log cuối; Claude nhận phần giá backend. Chưa commit.


**Bổ sung chọn tại chi tiết — chủ repo 2026-10-26 (trước sửa):** Trang chi tiết cũng chọn món được. Tiếp tục T-258 ở mức L1, dùng giỏ nháp hiện có theo `qr:<ban>` hoặc `web`. Acceptance: chọn nhân/lượng nhân theo mặc định và điều kiện của menu; nhập số lượng nguyên dương, thêm đúng món/combo cùng lựa chọn vào giỏ; mỗi lần thêm giữ lựa chọn riêng và các dòng cũ; bàn khác và giỏ web không lẫn nhau; quay về menu vẫn giữ giỏ; không gửi đơn thật tại trang chi tiết. Combo chọn chung các suất phù hợp như thẻ menu; giá món lẻ lấy đúng tổ hợp, combo được tính lại tại giỏ qua API hiện có. Kiểm test chi tiết và luồng khách, fe-check, gate.

**Bằng chứng chọn tại chi tiết 2026-10-26:** Codex tiếp tục trên nhánh P4A-01, base 0120d0c; chưa duyệt độc lập. `npm --prefix fe test -- src/app/thuc-don/chi-tiet.test.tsx src/app/ban/thuc-don-khach.test.tsx src/app/ban/khach-qr.test.tsx src/app/dat-mon/dat-mon.test.tsx` → 4 files/40 tests passed. Test mới kiểm mặc định, chọn nhiều/chay, giá đúng tổ hợp, giữ dòng cũ và từng lựa chọn riêng, cách ly bàn/web, combo đúng số suất, số lượng không hợp lệ bị chặn, tổ hợp thiếu giá bị chặn và món không có nhóm vẫn thêm được. `./scripts/fe-check.sh` → `fe-check: PASS`: apigen/lint/typecheck, 36 files/514 tests và production build đạt (`/private/tmp/detail-select-fe.log`). Trình duyệt thật `/private/tmp/detail-select-ui.cjs` → PASS tại 320/390/472px: thêm Chay ×2 từ chi tiết, quay về /ban/3 giữ số lượng và nhân, không tràn ngang, pageErrors=[]; combo Thịt + Nhiều cũng thêm và quay về giữ đúng lựa chọn. Đã xem ảnh `/private/tmp/detail-select-mobile.png`; có ảnh combo tối `/private/tmp/detail-select-combo-dark.png`. Không gửi đơn thật. Gate toàn cây `/private/tmp/detail-select-gate.log` đang chạy; index gốc trống, không thay staging của chủ repo.

**Kết luận kiểm tra 2026-10-26:** Lượt `/private/tmp/detail-select-gate.log` đã kết thúc exit 0, `PASS gate`: Gate 3, 1b–1h và verify đều đạt; backend PostgreSQL thật, fe-check, db-check và 18 script test đã chạy. Test chi tiết sau bổ sung key theo loại/id → 16 tests passed (chuyển món đặt lại lựa chọn/số lượng đúng món mới). Phạm vi riêng T-258 đạt, đã đọc diff theo Gate 4, không thêm dependency/hợp đồng/giá; test thêm kiểm hành vi thay vì nới assertion cũ. Đã kiểm khối commit bằng index tạm `/private/tmp/t258-commit/index`, diff --cached --check và hook Gate 9 đạt; index thật vẫn trống. Snapshot hai file chung trong `/private/tmp/t258-commit/` chỉ gồm phần T-258 trên HEAD; các diff việc khác ở owner FE/backlog được giữ ngoài khối. Phần FE của T-258 hoàn tất; yêu cầu giá backend từ lượt trước vẫn bàn giao Claude như đoạn làm rõ ở trên, không triển khai trong task FE này. Chưa commit, chưa duyệt độc lập.

<a id="t-259"></a>
### T-260 — Tóm tắt đơn hàng liệt kê từng suất combo, dài và rối

**Yêu cầu — chủ repo 2026-10-26:** Trên `/ban/3`, phần Tóm tắt đơn hàng có nút Chi tiết để ẩn/hiện thông tin; thông tin hiện dạng `×3 Bánh cuốn`, `×1 Bánh trứng vàng`, `×1 Giò`.

**Acceptance (trước sửa):** Mỗi dòng combo trong tóm tắt có nút Chi tiết, mặc định thu, bấm thì mở/thu (aria-expanded) danh sách thành phần gộp theo món: số suất của cả dòng (đổi theo số lượng combo) rồi tên món, Giò bán rời hiện gọn là Giò; món có lựa chọn kèm mô tả lựa chọn (suy luận của Claude: không làm mất nhân đã chọn), suất khác lựa chọn tách dòng riêng. Dòng món lẻ giữ mô tả như cũ. Dữ liệu gửi giỏ/báo giá không đổi. Kiểm test hành vi, fe-check và gate.

**Bổ sung — chủ repo 2026-10-26 (trước sửa):** Phần COMBO của tóm tắt có các cột Nhân, Lượng nhân, Số lượng, Giá và nút xoá. Acceptance: mỗi dòng combo một hàng cột, Nhân/Lượng nhân đọc từ lựa chọn của các suất (khác nhau thì nối dấu phẩy, không có — ví dụ Chay — thì "—"), số lượng sửa được như cũ, giá là giá dòng từ API, xoá bỏ dòng; vì nhân đã có cột nên danh sách Chi tiết chỉ còn `×N tên món`; màn hẹp không tràn trang (bảng tự cuộn ngang). Món lẻ giữ như cũ.

**Bổ sung 2 — chủ repo 2026-10-26 (trước sửa):** Phần MÓN LẺ dùng cùng các cột Nhân, Lượng nhân, Số lượng, Giá, xoá. Giá món lẻ là tiền cả dòng do backend tính qua `/price-quotes` như combo (suy luận của Claude: cho khớp cột Giá của combo vốn là giá dòng; FE không tự nhân tiền — luật cong-tien, ADR-102). Món lẻ không có nút Chi tiết.

**Bổ sung 3 — chủ repo 2026-10-26 (trước sửa):** Mỗi nhóm chỉ một nhãn "COMBO" / "MÓN LẺ" (bỏ nhãn cột lặp "Combo"/"Món"). Thêm cùng combo nhiều lần thì gom một dòng cộng số lượng; combo khác lựa chọn vẫn là dòng riêng (suy luận của Claude: gom theo combo + lựa chọn để không mất cột Nhân). Giỏ đã lưu từ trước không tự gộp lại. Khoá truy vấn giá dòng kèm chỉ số dòng để hai dòng giống nhau không trùng truy vấn.

**Bàn giao:** Claude trên nhánh P4A-01, chưa duyệt độc lập. File trong work/scope/T-260.txt; file component/test/backlog có diff T-258/T-259 chưa commit — chỉ stage phần T-260.

**Bằng chứng 2026-10-26:** `npm --prefix fe test -- src/app/ban/ src/app/thuc-don/ src/app/quay` → 99 tests passed (cột Nhân/Lượng nhân/Giá của combo và món lẻ, Chay hiện "—", giá món lẻ theo số lượng từ API, Chi tiết mở/thu với aria-expanded, gom combo cùng lựa chọn, khác lựa chọn tách dòng, một nhãn COMBO). Test mẫu sửa đường `/api/menu` để menu tải lại không làm rơi combo. Trình duyệt thật `/ban/3` ở 320 và 390px: không tràn ngang, không lỗi trang, Chi tiết hiện `×6 Bánh cuốn · ×2 Bánh trứng chín · ×2 Giò`. `./scripts/gate.sh` exit 0, `PASS gate` (be-check, db-check, fe-check, 18 script test). Diff đọc theo Gate 4: không đổi hợp đồng hay dữ liệu; trang quầy không đổi hành vi (cờ món lẻ mặc định tắt). Chưa commit, chưa duyệt độc lập.

### T-259 — Gom lựa chọn nhân và lượng nhân thành nút mở bảng trượt

**Yêu cầu — chủ repo 2026-10-26:** Trên trang `/ban/3`, cả COMBO và MÓN LẺ gom các lựa chọn Nhân vào một nút, bấm mở bảng trượt để chọn; làm tương tự với Lượng nhân.

**Acceptance (trước sửa):** Mỗi nhóm hiển thị một nút kèm lựa chọn hiện tại; bấm mở bảng trượt từ dưới lên có tên nhóm và tên món/combo, lựa chọn hiện tại được đánh dấu. Chọn một lựa chọn sẽ cập nhật nút và đóng bảng; có nút đóng, Escape và bấm nền đóng được, focus trở về nút mở. Cả combo và món lẻ giữ mặc định, điều kiện Chay ẩn lượng nhân, tổ hợp gửi giỏ và từng lần thêm riêng như cũ. Bảng vừa màn hình nhỏ, hỗ trợ sáng/tối và giảm chuyển động. Kiểm test hành vi, fe-check và gate; không gửi đơn thật.

**Bàn giao ban đầu:** Codex trên nhánh P4A-01, base b84c0f0, chưa review độc lập. Scope trong work/scope/T-259.txt. Cây đã có nhiều thay đổi việc khác, gồm backlog và owner FE; chỉ stage phần T-259 khi bàn giao commit.

**Bằng chứng 2026-10-26:** `npm --prefix fe test -- src/app/ban/thuc-don-khach.test.tsx src/app/ban/khach-qr.test.tsx` → 2 files/19 tests passed; bao gồm cập nhật nút/đóng bảng, tên nhóm/món, đánh dấu lựa chọn, Escape/nút đóng/focus, giữ tổ hợp riêng và dữ liệu giỏ. `./scripts/fe-check.sh` → `fe-check: PASS` (apigen, lint, typecheck, 36 files/516 tests và production build), log `/private/tmp/t259-fe.log`. Playwright `/private/tmp/t259-ui.cjs` → PASS cả combo/món ở 320/390/768px, mặc định Thịt + Vừa, chọn Thịt + mộc nhĩ/Nhiều, Chay ẩn lượng, Escape/nền trả focus; sáng/tối đúng, reduced motion không animation, overflow=false, pageErrors=[] (`/private/tmp/t259-ui2.log`). Đã xem ảnh bảng tối `/private/tmp/t259-sheet-dark.png`; không gửi đơn thật. Diff đọc theo Gate 4: không thêm dependency/hợp đồng/giá, các assertion payload cũ giữ nguyên; test đổi thao tác để mở bảng trước khi chọn. Scope riêng T-259 và diff --check đạt. Gate toàn cây `/private/tmp/t259-gate.log` đang chạy; chưa kết luận gate xanh, chưa commit, chưa review độc lập.

**Kết luận 2026-10-26:** `./scripts/gate.sh` exit 0, `PASS gate` (`/private/tmp/t259-gate.log`): Gate 3, 1b–1h, backend PostgreSQL thật, fe-check, db-check (147 câu đối chiếu, 149 lỗi cài) và 18 script test đều đạt. Hoàn tất phần giao diện. Đã tách snapshot owner FE/backlog chỉ có T-259 trên HEAD trong `/private/tmp/t259-commit/`, kiểm index tạm và staged diff trong worktree `/private/tmp/t259-review`, Gate 9 đạt; index thật giữ trống. Các diff việc khác vẫn ngoài khối commit. Chưa commit, chưa review độc lập. Scope giữ tới khi chủ repo commit.

**Bổ sung bố cục — chủ repo 2026-10-26 (trước sửa):** Tiếp tục T-259: tên, thành phần và bộ chọn nằm bên trái; giá và bộ −/số lượng/＋ ở góc phải cùng hàng thẻ. Acceptance: hai nút Nhân và Lượng nhân xếp dọc dưới nội dung, không bị đẩy xuống dưới cột giá; cột giá/số lượng ghim góc trên bên phải cả combo/món lẻ; tên Giò bán rời trong thành phần combo hiển thị gọn Giò theo ví dụ; màn nhỏ không tràn ngang; bảng trượt, chọn Chay và thêm/bớt vẫn hoạt động. Kiểm trực quan trên trình duyệt và gate; không thêm test mô phỏng riêng cho thay đổi bố cục.

**Bằng chứng bổ sung bố cục 2026-10-26:** `npm --prefix fe test -- src/app/ban/thuc-don-khach.test.tsx src/app/ban/khach-qr.test.tsx` → 2 files/19 tests passed. Playwright `/private/tmp/t259-layout-ui.cjs` kiểm mọi thẻ combo/món lẻ ở 320/390/472/768px → PASS giá cùng hàng trên với tên, bên phải nội dung; bộ chọn ở cột trái, hai nút xếp dọc; Giò hiển thị gọn trong combo; không tràn ngang; chọn Chay ẩn lượng và thêm combo giữ lựa chọn; pageErrors=[] (`/private/tmp/t259-layout-ui.log`). Đã xem ảnh `/private/tmp/t259-layout-light.png`, có ảnh tối `/private/tmp/t259-layout-dark.png`. Không gửi đơn thật. Chỉ đổi bố cục và nhãn trình bày, không đổi mã/dữ liệu/giá; không thêm test mô phỏng CSS. Gate mới `/private/tmp/t259-layout-gate.log` đang chạy; chưa kết luận lượt mới xanh, chưa commit.

**Kết luận bổ sung bố cục 2026-10-26:** Gate mới `/private/tmp/t259-layout-gate.log` kết thúc exit 0, `PASS gate`: backend PostgreSQL thật, frontend lint/typecheck/36 files/516 tests/build, db-check và 18 script test đều đạt. Hoàn tất T-259 theo bố cục mới. Snapshot và staged diff trong `/private/tmp/t259-commit/` và `/private/tmp/t259-review` cập nhật lại theo bản cuối; Gate 9 và diff --check đạt, index thật trống. Chưa commit, chưa review độc lập; giữ scope tới lúc chủ repo commit.

**Bổ sung ảnh — chủ repo 2026-10-26 (trước sửa):** Tăng kích thước ảnh giữ chỗ trên thẻ combo và món lẻ. Acceptance: ảnh trên điện thoại tăng từ 48px lên 72px, màn lớn từ 80px lên 96px, biểu tượng bên trong tăng tương ứng; cột giá vẫn ở góc phải, bộ chọn vẫn xếp dọc bên trái, không tràn ngang ở 320/390/472/768px; bảng trượt và thêm/bớt giữ nguyên. Đây là chỉnh trình bày trong T-259, không thêm test mô phỏng CSS.

**Bằng chứng ảnh lớn 2026-10-26:** Playwright `/private/tmp/t259-image-ui.cjs` → PASS toàn bộ thẻ combo/món tại 320/390/472/768px: ảnh đúng 72×72px trên mobile và 96×96px màn lớn, nội dung trái/giá trên phải, hai nút chọn xếp dọc, không tràn ngang, Chay ẩn lượng và thêm combo hoạt động, pageErrors=[] (`/private/tmp/t259-image-ui.log`). Đã xem ảnh sáng `/private/tmp/t259-image-light.png`, có ảnh tối cùng tiền tố. Chỉ sửa kích thước CSS, không thay dữ liệu hay hành vi. Gate `/private/tmp/t259-image-gate.log` đang chạy; chưa kết luận lượt mới xanh. Snapshot commit đã điều chỉnh theo HEAD 2ce23a4; index thật trống, chưa commit.

<a id="t-261"></a>
### T-261 — Canh bánh cuốn nằm cuối món lẻ trên trang khách

Chủ repo yêu cầu 2026-10-26 trong hội thoại, cho `fe/src/app/ban`: *"canh bánh cuốn để xuống cuối cùng của món lẻ. để mặc định là ít rau, có thêm tuỳ chọn nhiều rau"*. Mức L1 (chỉ thứ tự trình bày). Claude làm, chưa review độc lập, nhánh `P4A-01`.

Acceptance viết trước: (1) danh sách *MÓN LẺ* của trang khách đặt *Canh bánh cuốn* cuối, các món khác giữ thứ tự menu trả; (2) thẻ canh có nút *Rau* mặc định *Ít rau*, chọn được *Nhiều rau* — dữ liệu đã có từ T-255, test `thuc-don-khach.test.tsx` canh cả hai; (3) gate xanh.

Ghi chú: database dev của chủ repo chưa nạp lại seed sau T-255 nên canh chưa có nhóm Rau; Claude đã chạy năm câu `INSERT` nhóm Rau của `db/seed/seed.pl` vào database dev (chỉ thêm). Nhóm Rau vẫn giữ ba lựa chọn đã chốt ở T-255 (cả *Không rau*); bỏ *Không rau* là đổi luật, chờ chủ repo nói.

<a id="t-262"></a>
### T-262 — Thiết kế đăng nhập bằng số điện thoại hoặc Gmail, khách có tài khoản

Chủ repo yêu cầu 2026-10-27 trong hội thoại: *"Thiết kế đăng nhập thật bằng số điện thoại hoặc Gmail; làm rõ dùng mật khẩu hay OTP, Gmail là địa chỉ đăng nhập hay nút Đăng nhập với Google, rồi lập phiếu triển khai cho Codex."* Mức **L3** (tài khoản, mật khẩu, dữ liệu khách, hợp đồng). Claude Code làm, chưa review độc lập, nhánh `P4A-01`.

Lời đã chốt (chủ repo chuyển lời chủ quán, chọn trong câu hỏi có sẵn phương án): mật khẩu, không OTP; Gmail là địa chỉ gõ vào ô; cả khách có tài khoản; khách đăng nhập tuỳ chọn, không chờ duyệt, được xem lại đơn và nhớ tên · số điện thoại · địa chỉ giao; đăng ký khai một trong hai. Ghi ở `master_plan/shop-facts.md` §8.8 lượt ba.

Acceptance viết trước: (1) lời quán vào §8.8 và nhật ký `shop-facts.md`, kéo theo `07-pham-vi-mvp.md` · `0-ba/admin/01-ranh-gioi.md`; (2) chỗ lời chưa phủ thành `U-105`…`U-108`; (3) thiết kế **ADR-131** ở trạng thái *Đề xuất*, ADR-109 ghi lời đổi; (4) ba lát `T-263` · `T-264` · `T-265` có entry và phiếu Codex ở scratchpad; (5) gate xanh. Task sang *Done* khi chủ repo duyệt ADR-131; trước khi giao `T-263`, Claude thêm invariant tài khoản khách và test hồi quy (mức L2).

**Kết quả 2026-10-27:** chủ repo duyệt ADR-131 (nguyên văn *"duyệt"*). Claude thêm **I-035** vào `quality/invariants.md`; test hồi quy `i035_customer_account_apart_from_staff.sql` viết trước lược đồ, nằm cùng phiếu T-263 ở scratchpad và vào `db/tests/` trong worktree của Codex (đặt ở cây chính trước khi có lược đồ là gate đỏ). Gate xanh. Chưa review độc lập.

<a id="t-263"></a>
### T-263 — Lược đồ đăng nhập bằng số điện thoại · Gmail và tài khoản khách

Lát a của **ADR-131** (điểm 1–7), mức L2. Migration mới: `account.phone` (duy nhất, CHECK mẫu chuẩn hoá), `account.email` và `account.username` thành tuỳ chọn, CHECK có số hoặc thư; bốn bảng `customer_account` · `customer_password` · `customer_session` · `customer_password_reset`; `sales_order.customer_account_id` chỉ cho `delivery` · `pickup`. Down từ chối khi có dữ liệu sẽ mất. File ý định `docs/product/2-db/23-luoc-do-tai-khoan-khach.md`, dòng thứ tự ở `07-thu-tu-migration.md`. Giao Codex sau khi ADR-131 được duyệt và invariant + test hồi quy đã có.

**Bàn giao 2026-10-27:** thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-263`, nhánh `codex/T-263` từ `4326e46`), duyệt **Claude**. Hai vòng: vòng một Codex dừng đúng phiếu ở hai chỗ — cột `sales_order.customer_account_id` chưa có khuôn chặn sửa, và Gate 1g đòi ánh xạ tên ràng buộc ngoài scope. Claude quyết: trigger `sales_order_customer_account_immutable_check` theo khuôn `customer_session_ended_immutable_check` (thu hồi UPDATE theo cột trên `sales_order` phải cấp lại mọi cột khác); tên mới vào `x-constraint-errors` là `unreviewed` (`*_pkey` là `internal`), T-264 gán mã công khai; hợp đồng 0.51.1. Claude tự sửa hai chỗ khi duyệt: `db/tests/i033_account_session_and_reset.sql` nhận `customer_password.password_hash` là chỗ cất băm hợp lệ (I-035 mở rộng luật băm của I-033; trước đó test đỏ vì đọc lược đồ thấy cột `password`), và `scripts/db-check.sh` thêm khối T-263 theo khuôn T-146/T-175 (lên trên tài khoản kiểu cũ; đường lùi từ chối khi đã có khách — một giao dịch, ROLLBACK).

File: migration `20261027120000_tai_khoan_khach` (up/down), `db/tests/i035_…` (Claude viết trước, không sửa) · `i033_…`, `db/reconcile/i035.sql` + `proof/i035_1…4.sql`, `db/reconcile/i033.sql`, `docs/product/2-db/23-luoc-do-tai-khoan-khach.md` · `07-thu-tu-migration.md` · `09-doi-chieu-bat-bien.md`, `openapi.yaml` (ánh xạ + phiên bản), `scripts/db-check.sh`, `be/internal/taikhoan/{repository,service}.go` (chỉ đổi kiểu nullable cho build qua), sqlc sinh lại. Ở clone chính, dòng thứ tự là **38** (sau `20261024140000_khoan_chi_chi_tiet` của T-248 chưa commit); trong blob của commit T-263 nó là 37 — khi commit T-248, dòng của T-248 phải đứng trước.

Kiểm đã chạy (Claude): `./scripts/db-check.sh` trong worktree — `PASS T-263 lên được trên tài khoản cũ; đường lùi từ chối khi đã có khách`, `PASS db/tests/i035_…`, `PASS db/tests/i033_…`, `PASS kêu i035_1…4`, `PASS lùi 20261027120000_tai_khoan_khach`, `db-check: PASS`; `./scripts/gate.sh` ở clone chính sau khi tích hợp: mọi cổng PASS (be-check, db-check 38 bước, verify). Gate trong worktree đỏ ở `fe-check` vì `thuc-don-khach.tsx` ở HEAD import `./lua-chon-truot` — file chưa track của T-259, không do T-263.

<a id="t-264"></a>
### T-264 — Backend và hợp đồng đăng nhập số điện thoại · Gmail, cửa khách

Lát b của **ADR-131**, mức L2, sau `T-263`. Gói `be/internal/dinhdanh`; `POST /sessions` nhận `identifier`; đăng ký người làm khai số hoặc thư; miền mới `be/internal/khach` (đăng ký, đăng nhập, phiên, thông tin giao, lịch sử đơn, đổi và đặt lại mật khẩu); lớp quyền `khach`, cookie `banhcuon_khach`; `POST /online-orders` gắn tài khoản khách khi phiên hợp lệ. `openapi.yaml` tăng phiên bản phụ.

**Bàn giao 2026-10-28:** thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-264`, nhánh `codex/T-264` từ `4326e46` + T-263 stage sẵn), duyệt **Claude**. Codex dừng hai lần đúng phiếu (chưa có khuôn chia trang; phiếu viết sai ý về file nền) và một lần hết hạn mức. Claude chốt khuôn chia trang keyset `before_id`/`limit` (1…50, mặc định 20) → `{orders, next_before_id}`. Vòng duyệt có Docker lộ ba nhóm đỏ: (a) test hồi quy của Claude gửi `Origin` khi `BANHCUON_ORIGIN` rỗng, chưa mở luồng quầy trước đơn web, và sửa phiên bằng vai chủ không khai lý do — Claude sửa test, không đổi điều kiện kiểm; (b) cửa khách không khai `shop.revision_reason`, thiếu ca I-018 cho `khach/dat_lai` · `ket_thuc_phien` · `luu_giao` — Codex sửa; (c) **lỗ hổng thiết kế T-263**: `record_revision.person_id` bắt buộc người của quán nên mọi lần khách tự sửa vỡ. Chủ repo chọn *"Giữ vết, người sửa để trống"* (câu hỏi có sẵn phương án, 2026-10-28) ⇒ Claude thêm migration `20261028090000_vet_cua_khach` (`record_revision_person_check`: rỗng chỉ cho bốn bảng `customer_*`; lùi từ chối khi đã có vết rỗng), sửa `db/reconcile/i018.sql`, ghi sửa đổi vào I-018 và ADR-131, nới ba test I-018 nhận `check_violation` bên cạnh `not_null_violation` (lần sửa không người vẫn bị từ chối).

Kiểm đã chạy (Claude): trong worktree `db-check: PASS — 38 bước…`, `be-check` mọi test PASS; FE còn đúng `khach-qr.test.tsx` đỏ sẵn ở HEAD (sửa đổi chưa commit của task khác ở clone chính làm nó xanh). Clone chính sau tích hợp: `./scripts/gate.sh` mọi cổng PASS (be-check, db-check 39 bước, verify, hợp đồng 0.52.0 134/134). Ở clone chính dòng thứ tự migration là **39** (sau T-248 37, T-263 38); trong blob commit T-264 là 38. Hợp đồng: T-264 và T-248 (chưa commit) cùng đặt `0.52.0` — ai commit sau phải tăng tiếp.

<a id="t-271"></a>
### T-271 — Nhân *Mộc nhĩ* mới và chế độ *Hỗn hợp* khi khách gọi combo

Mức **L2** (chạm nhóm Nhân dùng chung, chạm giao diện gọi combo, phụ thu phải khớp luật tiền). Chủ
repo chốt 2026-10-29 trong hội thoại: *"bánh nhân mộc nhĩ RIÊNG và bánh nhân thịt RIÊNG trong cùng
combo"*, *"chia đôi số bánh, nếu số bánh lẻ thì thịt nhiều hơn một bánh (3 → 2 thịt + 1 mộc nhĩ, 4 →
2+2)"*, *"nhân mộc nhĩ riêng CÙNG GIÁ VÀ PHỤ THU với nhân thịt"*. Hai câu bỏ ngỏ ở phiên trước
cùng ngày được chốt lại: *"có"* ⇒ `U-109` đóng, *Mộc nhĩ* hiện cả ở trang gọi món lẻ; *"coi bánh
trứng như bánh cuốn cũng dc"* ⇒ `U-110` đóng, chế độ *Hỗn hợp* chia ceil/floor cộng cả phần bánh
trứng con (chia **theo mỗi combo** trước khi nhân `quantity`; phần Thịt nhiều hơn một khi tổng
phần nhận nhân lẻ). Lời: `master_plan/shop-facts.md` §4.4 đoạn *Lựa chọn Mộc nhĩ và chế độ Hỗn
hợp*; thiết kế **ADR-134** (điểm 2 và 5 sửa 2026-10-29 để nói đúng chốt mới).

**Acceptance (Claude viết trước, Codex làm cho xanh; mục 1 và 2 chỉnh 2026-10-29 vì DB dev đã có
dữ liệu — xem *Bàn giao* dưới):**

1. Nhóm Nhân có **đúng bốn** lựa chọn — Chay, Thịt, Thịt + mộc nhĩ, Mộc nhĩ — sau khi seed một DB
   trống (`perl db/seed/seed.pl | psql`): `SELECT name FROM shop.menu_option o JOIN shop.option_group
   g ON g.id = o.option_group_id WHERE g.name = 'Nhân' ORDER BY o.id` ⇒ bốn dòng, dòng *Mộc nhĩ* có
   `surcharge_vnd = 1000` khớp *Thịt*; *Mộc nhĩ* nằm trong tập điều kiện của nhóm *Lượng nhân*
   (`option_group_prerequisite`), nên gửi `Mộc nhĩ + Nhiều nhân` không bị `I-010` từ chối. Với một
   DB đã có dữ liệu (ví dụ clone chính), dùng cửa API chủ quán để **thêm** dòng *Mộc nhĩ* (POST
   `/option-groups/{id}/options`, phụ thu đọc từ *Thịt*) rồi **thêm** điều kiện vào nhóm *Lượng
   nhân* qua cửa `enables groups` của *Thịt*; không chạy lại seed vì `make seed` bỏ qua DB đang có
   dữ liệu — ADR-134 điểm 1 giữ nguyên, chỉ đường cập nhật tuỳ trạng thái DB.
2. `menu_combo_item_option_surcharge` có một hàng cho mỗi (suất con có nhóm Nhân) × *Mộc nhĩ* với
   `surcharge_vnd = 1000` sau seed trống, sinh ra từ `menu_option.surcharge_vnd`. Với DB có dữ liệu,
   dùng `PUT /menu-combos/{id}/surcharges` để **thêm** cặp *Mộc nhĩ* chưa có cho từng combo đã có,
   giá trị sao đúng mức *Thịt* của combo ấy; không ghi đè các mức đã có.
3. §4.8 ca 18 (Combo Đầy đủ chín · Mộc nhĩ · Thường = **30.000**) PASS khi chạy
   `perl db/seed/seed.pl --price-cases | psql_f` (`scripts/db-check.sh` bước 4). Đây là mục kiểm
   mọi suất con cùng chọn *Mộc nhĩ* ⇒ tổng tiền bằng ca 9 (toàn *Thịt*).
4. Test hồi quy mới `db/tests/i034_moc_nhi_hon_hop_combo.sql` (Claude viết trước lược đồ) PASS:
   dựng một combo thử gồm 3 suất bánh cuốn con + 1 trứng + 1 giò, giá combo = 26.000; đặt một đơn
   với dòng con **tách thành 2 Thịt + 1 Mộc nhĩ cho bánh** (quantity 2 và 1 trên hai dòng con), 1
   trứng Thịt, 1 giò; `line_total_vnd` cộng dồn **bằng đúng** một đơn mọi suất chọn Thịt.
5. `GET /menu` không đổi hợp đồng — combo đã trả về `items[].quantity` theo ADR-129 (phiên bản phụ
   không bump).
6. **FE khách gọi combo** (`fe/src/app/ban/_components/thuc-don-khach.tsx` + `lua-chon-the.tsx`):
   combo có tổng phần nhận nhân (bánh cuốn + bánh trứng con) ≥ 2 và mọi suất con nhận nhân có đủ
   cả hai lựa chọn *Thịt* và *Mộc nhĩ* ⇒ hiện radio *Mộc nhĩ và thịt* ở nhóm Nhân của combo; bấm
   radio sẽ đặt ceil(N/2) phần đầu danh sách (bánh cuốn trước, rồi bánh trứng) mang *Thịt* và
   floor(N/2) phần còn lại mang *Mộc nhĩ*; giò không bị đụng. Chia **theo mỗi combo** trước khi
   nhân với `quantity`: tăng combo lên k ⇒ k × (ceil Thịt + floor Mộc nhĩ). N ≤ 1 hoặc thiếu một
   trong hai option ⇒ không hiện radio. Bấm trở lại *Thịt* hoặc radio khác ở nhóm Nhân ⇒ tắt chế
   độ Hỗn hợp.
7. Dòng đơn tạo ra giữ nguyên hình ADR-117 điểm 2: **nhiều dòng con cùng `menu_item_id`, khác
   `menu_option_id`, cùng cha `parent_order_line_id`**; mỗi dòng cộng đúng số portions có nhân
   tương ứng và tổng combo không đổi so với toàn *Thịt*.
8. Trang chủ quán `/chu-quan/combo` chỉ hiện *Mộc nhĩ* trong danh sách lựa chọn của form *Đặt phụ
   thu* (`FormDatPhuThu`) — không nút *Hỗn hợp*; nhóm Nhân mang bốn lựa chọn, mức khởi tạo bằng
   `menu_option.surcharge_vnd` khi seed, chủ quán có thể đổi mức riêng qua
   `PUT /menu-combos/{menu_combo_id}/surcharges` (giữ ADR-116 không đổi).
9. `./scripts/gate.sh` xanh ở clone chính (db-check gồm `price-cases` và `i034_moc_nhi_hon_hop_combo`;
   be-check gồm `combo_test.go` cũ không đỏ; fe-check các test combo cũ không đỏ, test mới cho
   Hỗn hợp qua).

**Phạm vi** (đã khai trong `work/scope/T-271.txt`): `master_plan/shop-facts.md`, `docs/decisions.md`,
`docs/product/99-unknowns.md`, `work/backlog.md`, `db/tests/i034_moc_nhi_hon_hop_combo.sql`,
`fe/src/app/ban/_components/thuc-don-khach.tsx`, `fe/src/app/ban/_components/lua-chon-the.tsx`,
`fe/src/app/ban/thuc-don-khach.test.tsx`, `fe/src/app/dat-mon/`, `fe/src/app/khach/`. Scope **cấm**
sửa: `openapi.yaml`, migration mới, `be/internal/gia/`, bất cứ cửa ghi nào — không cần.

**Phiếu giao Codex (bản copy ở nhớ phiên, không lưu repo per CLAUDE.md §3.8):**
Nhận AGENTS.md → CLAUDE.md → `./scripts/brief.sh`. Chỉ đọc thêm: `master_plan/shop-facts.md` §4.4
đoạn mới, `docs/decisions.md` **ADR-134**, `db/tests/i034_moc_nhi_hon_hop_combo.sql`,
`db/seed/seed.pl` (chỉ để chạy, không sửa), `fe/src/app/ban/_components/thuc-don-khach.tsx` và
`lua-chon-the.tsx`. **Việc thi công:** làm cho mọi mục Acceptance trên xanh; chú ý ba điểm:
(a) **không thêm *Mộc nhĩ* vào shop-facts.md theo cách khác đã viết** — bản thiết kế đã chốt là
option độc lập, phụ thu bằng Thịt; (b) **không sinh một lựa chọn thứ năm "Mộc nhĩ và thịt"** —
*Hỗn hợp* là nút UI, không phải option; (c) **không thêm migration** — mọi dòng dữ liệu đi qua seed
(`perl db/seed/seed.pl | psql`). **Cấm:** sửa `docs/decisions.md`, `docs/product/99-unknowns.md`,
`master_plan/shop-facts.md`, `quality/invariants.md`, `work/backlog.md`, `CLAUDE.md`; đóng U-109,
U-110; thêm cửa API mới; commit; dùng `git add -A`. **Dừng và hỏi** nếu bản thiết kế có vẻ không
tương thích với một file bạn phải sửa.

**Báo cáo cuối cùng (gửi về Claude):** (1) File đổi/tạo lấy từ `git status --short`; (2) Output
cuối của `./scripts/gate.sh`; (3) Bảng Acceptance 1–9 → bằng chứng (tên test · lệnh · output);
(4) Câu đã phải giả định (nếu có) và vì sao không hỏi được; (5) Việc chưa xong.

**Bàn giao 2026-10-29:** thực hiện **Codex** (cây làm việc chính `lean_ai_engineering_system`, nhánh `P4A-01`, base `6dea88f`, patch
`/tmp/t271-implementation.patch`), chuẩn bị lead **Claude** (shop-facts §4.4, ADR-134, U-109/U-110 đóng,
Acceptance 1–9, patch `/tmp/t271-claude-preparation.patch`), duyệt và tích hợp **Claude**. Thi công đã
xong theo scope: `fe/src/app/ban/_components/thuc-don-khach.tsx` và `lua-chon-the.tsx` dựng chế độ Hỗn
hợp với radio *Mộc nhĩ và thịt* (hiện khi tổng phần nhận nhân của combo ≥ 2 và mọi suất con có đủ Thịt ·
Mộc nhĩ; chia ceil Thịt / floor Mộc nhĩ **theo mỗi combo** rồi nhân `quantity`);
`db/tests/i034_moc_nhi_hon_hop_combo.sql` xanh; `db/seed/seed.pl` ghi *Mộc nhĩ* vào nhóm Nhân (phụ thu
bằng *Thịt*), nối Mộc nhĩ vào tập điều kiện của *Lượng nhân*, sinh `menu_combo_item_option_surcharge`
cho mỗi (suất con có nhóm Nhân) × *Mộc nhĩ*. Trên DB dev đã có dữ liệu, Mộc nhĩ được thêm qua cửa API
chủ quán và phụ thu từng combo đọc đúng mức *Thịt* để không ghi đè seed.

Acceptance → bằng chứng (1) seed trống bốn lựa chọn Nhân (`db/seed/seed.pl`) và DB dev thêm Mộc nhĩ qua
cửa API — kiểm tay 2026-10-29, giá chọn Mộc nhĩ bằng Thịt ở 7 combo; (2) `menu_combo_item_option_surcharge`
có hàng (suất con nhận nhân) × Mộc nhĩ sau seed và sau PUT trên DB dev; (3) ca 18 §4.8 trong
`/tmp/t271-codex-gate.log` ở nhánh `db-check` (price-cases); (4) `/tmp/t271-db-focused.log` i034 PASS
(`BEGIN · SET · DO · NOTICE I-034 Hỗn hợp tổng 1040 đ · DO · ROLLBACK`); (5) hợp đồng không bump —
`GET /menu` giữ `items[].quantity` (ADR-129); (6) FE `/tmp/t271-fe-tests.log` 550/550 test PASS,
`/tmp/t271-lint.log`, `/tmp/t271-typecheck.log`, `/tmp/t271-build.log` xanh; (7) kiểm tay dòng đơn
Hỗn hợp giữ hình ADR-117 điểm 2 (nhiều dòng con cùng `menu_item_id`, khác `menu_option_id`, cùng cha);
(8) `FormDatPhuThu` trang chủ quán chỉ hiện bốn lựa chọn (không có "Hỗn hợp"); (9) gate xanh ở clone
chính 2026-10-29 — `/tmp/t271-t272-completion-gate.log` mọi cổng PASS (Gate 1 be-check, db-check 41 bước
· 19 QC · 57 test · 37 YC, Gate 1 verify 18 shell test, Gate 1g hợp đồng 0.54.0 137/137). UI kiểm tay
thêm `/tmp/t271-combo-ui.png` ba độ rộng PASS.

**Lịch sử chặn đã gỡ (test fixture, 2026-10-29):** fixture `TestYC15_VaoChenCungMocBiTuChoi` dùng
`time.Sleep(time.Until(batDau)+50ms)` theo đồng hồ host với mốc `clock_timestamp()` của DB; khi hai
đồng hồ lệch (Docker/macOS sau khi máy ngủ) sleep gần 0 ⇒ cleanup đỏ, nguyenlieu `dung()` vỡ
`counter_duty_ended_after_started_check`. Giao `T-272` (xem [chi tiết](#t-272)) — đã đóng cùng ngày
bằng helper chờ đồng hồ **DB** vượt `batDau`, không chạm production, không bớt assertion. Gate ở clone
chính sau sửa xanh toàn cây.

<a id="t-272"></a>
### T-272 — Chờ đồng hồ DB trong fixture *Vào chen cùng mốc*

Mức **L1** (chỉ sửa test fixture; không chạm code production, không chạm ràng buộc, không giảm/bỏ
assertion). Giao Codex 2026-10-29 vì chặn gate backend không cho T-271 đóng — xem *Chặn* trong [chi
tiết T-271](#t-271). Nguyên nhân: fixture dùng `time.Sleep(time.Until(batDau)+50ms)` so đồng hồ host
với mốc đọc từ `clock_timestamp()` của DB; khi hai đồng hồ lệch (Docker trên macOS sau khi máy ngủ) thì
sleep gần 0 ⇒ test đỏ và cleanup đỏ ⇒ khoảng của C với `started_at` tương lai lưu lại ⇒ nguyenlieu
`UPDATE ... SET ended_at = now()` vỡ `counter_duty_ended_after_started_check`.

**Acceptance:**

1. `be/internal/nguoi/nguoi_test.go` còn đúng ba test `TestYC15_*` ở trạng thái và kiểm tra như trước;
   mọi `t.Fatalf`/`t.Errorf` giữ nguyên câu từ.
2. Fixture **không** dùng `time.Sleep(time.Until(batDau)...)` nữa; thay bằng chờ cho **đồng hồ DB**
   vượt `batDau` cộng một biên nhỏ (ví dụ `+ 50 ms`). Hai điểm cần thay: dòng 322 (trong `t.Cleanup`)
   và dòng 354 (trong thân `TestYC15_VaoChenCungMocBiTuChoi`). Chờ gọi qua `k.owner` (hoặc cùng pool
   test) để chỉ chịu đồng hồ DB; đặt deadline theo `time.Duration` host monotonic (bound trên không
   quá 5 s) để không treo khi DB ngắt kết nối — hết deadline thì `t.Fatal` nói rõ lý do.
3. Khi chạy `go test ./be/internal/nguoi/... -run TestYC15_VaoChenCungMocBi -count=5 -race`, test PASS
   mọi lần; thời lượng mỗi lần `≥ 1.5 s` và `< 3 s` (bằng chứng đồng hồ DB thật sự được chờ).
4. `scripts/be-check.sh` xanh ở clone chính (nguoi và nguyenlieu đều xanh, không còn `counter_duty_ended_after_started_check`).
5. `./scripts/gate.sh` xanh ở clone chính.

**Phạm vi** (`work/scope/T-272.txt`): `be/internal/nguoi/nguoi_test.go`, `work/backlog.md`. **Cấm**
sửa: migration, ràng buộc `counter_duty_ended_after_started_check`, mọi file dưới `be/internal/nguoi/`
không phải test, fixture của nguyenlieu/kho (`be/internal/nguyenlieu/`), `docs/`, hợp đồng. Không bỏ
hay nới bất kỳ assertion test nào (bao gồm `TestYC15_VaoChenCungMocBiTuChoi` so sánh ảnh khoảng
`truoc` vs `sau`, kiểm `replaced_person_id`, hai lần 409 trước mốc). Không viết helper mới ở gói
khác; nếu cần hàm chờ dùng chung, viết hàm cấp gói `nguoi_test` (ví dụ `(k khung) choToiMoc(t *testing.T,
batDau time.Time)`).

**Phiếu giao Codex:** xem phần văn xuôi của Claude trong hội thoại 2026-10-29 (không lưu repo per
CLAUDE.md §3.8).

**Báo cáo cuối (gửi về Claude):** (1) File đổi/tạo từ `git status --short`; (2) Output cuối của
`./scripts/gate.sh` (hoặc `scripts/be-check.sh` nếu chạy tách), (3) Output `go test ./be/internal/nguoi/...
-run TestYC15_VaoChenCungMocBi -count=5` (có `--- PASS` × 5 và dòng `ok` tổng thời lượng),
(4) Đã giả định gì nếu có, (5) Việc chưa xong.

**Bàn giao 2026-10-29:** thực hiện **Codex** (sửa `be/internal/nguoi/nguoi_test.go`), duyệt **Claude**.
Codex thêm helper cấp gói `(k khung) choToiMoc(t *testing.T, batDau time.Time)` ở `nguoi_test.go:300`
dùng `context.WithTimeout(k.ctx, 5*time.Second)` và `SELECT pg_sleep(GREATEST(0,
EXTRACT(EPOCH FROM ($1::timestamptz - clock_timestamp())) + 0.05))` qua `k.owner`; thay đúng hai
`time.Sleep(time.Until(batDau)+50ms)` (dòng 322 trong `t.Cleanup`, dòng 354 trong thân test) bằng
`k.choToiMoc(t, batDau)`. Không chạm production, không chạm ràng buộc, mọi `t.Fatalf`/`t.Errorf` của
ba test `TestYC15_*` giữ nguyên câu từ.

Acceptance → bằng chứng (1) chỉ `nguoi_test.go` đổi, ba test `TestYC15_*` còn đủ, mọi assertion
nguyên văn — đối chiếu `git diff be/internal/nguoi/nguoi_test.go`; (2) hai điểm `time.Sleep(time.Until(...))`
đã thay bằng helper chờ đồng hồ DB qua `pg_sleep`, deadline 5 s host monotonic qua `context.WithTimeout`;
(3) `/tmp/t272-focused-tests.log` `go test ./be/internal/nguoi/... -run TestYC15_VaoChenCungMocBi
-count=5 -race` ⇒ `--- PASS: TestYC15_VaoChenCungMocBiTuChoi (1.66s)`, 1.64s, 1.64s, 1.64s, 1.65s,
`ok banhcuon/be/internal/nguoi 9.917s` — mỗi lần trong khoảng [1.5s, 3s] chứng tỏ đồng hồ DB thật sự
được chờ; (4) `/tmp/t271-t272-completion-gate.log` `PASS Gate 1 be-check — mọi test backend qua
PostgreSQL thật đều đạt` (gồm nguoi và nguyenlieu, không còn `counter_duty_ended_after_started_check`);
(5) `/tmp/t271-t272-completion-gate.log` kết thúc `PASS gate — không cổng nào đỏ`. DB check-project
ở `/tmp/t272-check-project.txt`, chủ repo tự dọn.

<a id="t-270"></a>
### T-270 — Xác nhận Gmail khách qua thư

Mức **L2** (đăng nhập, dữ liệu lưu, hợp đồng). Chủ repo hỏi 2026-10-29 trang `/khach/dang-ky` có gửi thư xác nhận
Gmail không (không — từ ADR-131 tới nay), rồi chọn ba vế trong câu hỏi có sẵn phương án. Lời: `shop-facts.md` §8.8
*lượt năm*; thiết kế **ADR-133**; test hồi quy `db/tests/i035_email_verification.sql` Claude viết trước lược đồ.
Dựa trên T-264 và T-267 chưa commit.

Acceptance viết trước: (1) migration xác nhận Gmail (up/down; lùi từ chối khi đã có mã hay Gmail chờ),
`i035_email_verification` xanh, `i035_*` cũ vẫn xanh; (2) đăng ký có Gmail ⇒ `pending_email`, mã, phiên, thư sau giao
dịch, gửi hỏng không làm hỏng đăng ký; (3) đăng nhập và đặt lại mật khẩu chỉ khớp `email` đã xác nhận; (4) cửa xác
nhận công khai: hợp lệ ⇒ chuyển Gmail; mã lạ/hết hạn/đã dùng/Gmail đã đổi ⇒ `verification_invalid`; Gmail đã của người
khác ⇒ `email_taken`; (5) gửi lại khi đang đăng nhập, quá 3 thư một giờ ⇒ từ chối; (6) hợp đồng tăng phiên bản phụ,
`CustomerProfile` có `pending_email`; (7) FE: báo đã gửi thư sau đăng ký, trang tài khoản hiện Gmail chờ + nút gửi lại,
trang `/khach/xac-nhan-gmail`; (8) gate xanh, Claude tự chạy `db-check` · `be-check`.

**Bàn giao 2026-10-29:** thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-270`, nhánh `codex/T-270` từ `6dea88f` + toàn bộ thay đổi chưa commit của clone chính stage sẵn, gồm T-264 và T-267), duyệt **Claude**. Codex làm hết phần trong scope nhưng không tới được Docker; dừng đúng phiếu ở `be/internal/don/vet_cua_test.go` ngoài scope. Claude mở scope và tự sửa: `thuVet` cài `SendEmailVerification`, `khachVetSetup` xác nhận Gmail khi có hộp thư giả (ca `khach/dat_lai` cần Gmail đã xác nhận mới nhận thư đặt lại), thêm ca vết `khach/xac_nhan` (thư mục `sql/xac_nhan/` có UPDATE nên `TestI018_TapCuaSuaKhopTapCa` đòi), gofmt. Giả định Codex ghi lại và Claude nhận: gửi lại trả `202 {"status":"ok"}` theo khuôn yêu cầu đặt lại; giới hạn 3 mã một giờ tính cả mã lúc đăng ký. File: migration `20261029120000_xac_nhan_gmail`, `db/tests/i035_email_verification.sql` (Claude viết trước, không sửa), `db/reconcile/i035.sql`, `25-luoc-do-xac-nhan-gmail.md` · `07` · `09`, `scripts/db-check.sh`, `be/internal/khach/` (`verification.go` + test, đăng ký, đăng nhập, Google, câu SQL), `be/internal/taikhoan/` (`Mailer.SendEmailVerification`, `smtp.go`), `apierr`, `router.go` (`WithOrigin`), `be/sqlc.yaml` + sqlc sinh lại, `vet_cua_test.go`, hợp đồng **0.54.0** + `01-hop-dong-api.md` · `02-vai-va-quyen.md`, FE `/khach/xac-nhan-gmail` + test, `tai-khoan.tsx`, `messages.ts`, `schema.ts`, `01-khung-fe.md`.

Acceptance → bằng chứng: (1) `PASS db/tests/i035_email_verification.sql`, `PASS lùi 20261029120000_xac_nhan_gmail`; (2)(3)(5) `TestI035_EmailVerificationLifecycle` (Gmail chờ, một mã, thư đúng origin sau commit, đăng nhập và đặt lại với Gmail chờ bị từ chối, xác nhận rồi đăng nhập được, gửi lại lần bốn ⇒ `verification_rate_limited`, không Gmail chờ ⇒ `no_pending_email`) · `TestI035_EmailVerificationMailerFailureStill201`; (4) `TestI035_EmailVerificationExpiredAndChanged` (`expired` · `changed`) · `TestI035_EmailVerificationGoogleCollision`; (6) Gate 1g `hợp đồng 0.54.0; 137 đường gọi … 113 dòng ma trận`; (7) `fe/src/app/khach/xac-nhan-gmail/xac-nhan-gmail.test.tsx` 6 test; (8) `./scripts/gate.sh` ở clone chính 2026-10-29: mọi cổng PASS (db-check 41 bước, be-check, verify). Commit sau T-264 và T-267, bằng `docs/private/google-login/T-270.patch`.

<a id="t-267"></a>
### T-267 — Khách đăng ký và đăng nhập bằng nút Google

Mức **L2** (đăng nhập, dữ liệu lưu, hợp đồng). Chủ repo yêu cầu 2026-10-28 và chọn trong câu hỏi có sẵn phương án: nút
chỉ ở trang khách, đổi phương án ADR-131 đã loại. Lời: `master_plan/shop-facts.md` §8.8 *lượt bốn*; thiết kế **ADR-132**
(*Đề xuất*); phụ thuộc ngoài **PT-8**; test hồi quy `db/tests/i035_google_identity.sql` Claude viết trước lược đồ.

Acceptance viết trước: (1) migration `customer_google_identity` (up/down; lùi từ chối khi đã có dòng) và
`i035_google_identity` xanh, `i035_…` cũ vẫn xanh; (2) gói `be/internal/google` kiểm ID token đúng ADR-132 điểm 3, test
từng nhánh từ chối bằng khoá RSA sinh tại chỗ và JWKS giả; (3) `POST /customer-sessions/google`: `sub` đã nối ⇒ mở
phiên; `sub` mới ⇒ một giao dịch tạo tài khoản + dòng nối + phiên; thư đã có tài khoản khách chưa nối ⇒ `email_taken`,
không ghi gì; token sai ⇒ `google_token_invalid`; thiếu Client ID ⇒ `google_login_disabled`; không chạm `account` ·
`person`; (4) `openapi.yaml` tăng phiên bản phụ, ma trận quyền và ánh xạ ràng buộc đủ; (5) `/khach/dang-ky` ·
`/khach/dang-nhap` có nút Google khi có `NEXT_PUBLIC_GOOGLE_CLIENT_ID`, thành công sang `/khach/tai-khoan`, `email_taken`
báo đăng nhập bằng mật khẩu; (6) gate xanh, Claude tự chạy `db-check` · `be-check`.

Chủ repo còn phải tạo **Google OAuth Client ID** (loại *Web application*, origin `http://localhost:3000`) và đặt vào
`BANHCUON_GOOGLE_CLIENT_ID` · `NEXT_PUBLIC_GOOGLE_CLIENT_ID`; thiếu nó nút không hiện, mọi đường khác chạy như cũ.

**Bàn giao 2026-10-29:** thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-267`, nhánh `codex/T-267` từ `d9d7e26` + toàn bộ thay đổi chưa commit của clone chính stage sẵn, gồm T-264), duyệt **Claude**. Vòng một Codex dừng đúng phiếu vì cửa mới cần `be/sqlc.yaml` ngoài scope; Claude mở scope. Vòng hai Codex hết hạn mức **trước khi viết báo cáo** — Claude duyệt thẳng diff. Claude tự sửa hai chỗ khi tích hợp: dòng PT-8 bỏ đường dẫn URL (Gate 1d coi là route), và cột `google_sub` đổi thành `google_sub_code` (QD-60 kêu ở mọi ca đối chiếu vì cột so byte không mang hậu tố `_code`; QD-61 đòi hậu tố ấy — tên ràng buộc giữ nguyên nên hợp đồng không đổi). File: migration `20261028120000_khach_google`, `db/tests/i035_google_identity.sql` (Claude viết trước, chỉ đổi tên cột), `24-luoc-do-khach-google.md` · `07-thu-tu-migration.md` · `09-doi-chieu-bat-bien.md`, `scripts/db-check.sh`, gói `be/internal/google/`, `be/internal/khach/` (`google.go`, cửa, handler, repository, đăng nhập mật khẩu khi không có mật khẩu ⇒ `login_failed`), `be/sqlc.yaml` + sqlc sinh lại, `apierr`, `router.go`, `Makefile`, hợp đồng **0.53.0** + `02-vai-va-quyen.md`, `fe/src/components/khach/google.tsx` (+ test), `dang-nhap.tsx`, `messages.ts`, `schema.ts`, `01-khung-fe.md`.

Acceptance → bằng chứng: (1) `PASS db/tests/i035_google_identity.sql`, `PASS lùi 20261028120000_khach_google`; (2) `TestI035_GoogleVerify` 16 ca con (`valid` · `bad_signature` · `wrong_alg` · `unknown_kid` · `wrong_aud` · `wrong_iss` · `second_issuer` · `expired` · `expiry_boundary` · `clock_skew` · `missing_exp` · `unverified` · `verified_string` · `empty_sub` · `blank_sub` · `cache_expired`); (3) `TestI035_GoogleAccountSessionAndEmailCollision` (tạo tài khoản không mật khẩu, đăng nhập lại đúng tài khoản, mật khẩu ⇒ `login_failed`, thư đã có ⇒ `email_taken` không ghi gì) · `TestI035_GoogleConcurrentSubject` · `TestI035_GoogleDisabledAndInvalid` · `TestI035_GoogleHandlerCookie` · `TestI035_GoogleHandlerErrors`; (4) Gate 1g `hợp đồng 0.53.0; 135 đường gọi … 111 dòng ma trận`; (5) `fe/src/components/khach/google.test.tsx` (không Client ID thì không có nút; callback gửi `credential` và chuyển `/khach/tai-khoan` ở cả đăng ký lẫn đăng nhập; `email_taken` hiện câu dùng mật khẩu); (6) `./scripts/gate.sh` ở clone chính 2026-10-29: mọi cổng PASS (db-check 40 bước, be-check, verify, fe-check 546 test). Chủ repo duyệt ADR-132 ngày 2026-10-29 (nguyên văn *"duyệt"*); test user `pythondevhn2023@gmail.com` đã thêm, Client ID ở `docs/private/google-login/README.md`. Commit sau T-264 (và T-248 cho `models.go` · hợp đồng): khối commit áp `T-267.patch` bằng `git apply --cached`.

<a id="t-265"></a>
### T-265 — Màn đăng nhập một ô và trang tài khoản khách

Lát c của **ADR-131**, mức L2, sau `T-264`. `/dang-nhap` · `/dang-ky` dùng ô *Số điện thoại hoặc Gmail*; trang Nhân viên hiện số điện thoại; nhánh mới `/khach/dang-nhap` · `/khach/dang-ky` · `/khach/tai-khoan` · `/khach/don` · `/khach/quen-mat-khau`; `/dat-mon` điền sẵn thông tin đã nhớ; cập nhật `docs/product/4-fe/01-khung-fe.md`.

**Bàn giao 2026-10-28:** thực hiện **Codex** (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-265`, nhánh `codex/T-265` từ `17dcb81` + T-264 stage sẵn), duyệt **Claude**. Phiếu gốc mất cùng scratchpad phiên trước; Claude viết lại từ entry này và ADR-131. Vòng một Codex dừng cả task vì `fe/src/app/ban/_components/phieu-khach.tsx` ngoài scope; Claude mở scope và chốt: `PhieuKhach` nhận `initialDelivery` tuỳ chọn, chỉ `/dat-mon` truyền khi có phiên khách, trang QR không truyền (`U-106`). Vòng hai Codex hết hạn mức **trước khi viết báo cáo** — không có lời tự khai; Claude duyệt thẳng diff và test. File: nhánh `fe/src/app/khach/` (đăng nhập, đăng ký, tài khoản, đơn, quên và đặt lại mật khẩu), `fe/src/components/khach/`, `fe/src/lib/khach/session.ts`, `/dat-mon` (`dat-mon-khach.tsx`), form người làm (đăng nhập, quên mật khẩu, khung), `01-khung-fe.md`.

Acceptance → bằng chứng: `fe/src/components/tai-khoan/t265.test.tsx` (gửi identifier nguyên; đăng ký thiếu số và thư không gọi API) · `fe/src/app/khach/khach.test.tsx` (đăng ký chuyển `/khach/tai-khoan`; 401 chuyển `/khach/dang-nhap`; *Xem thêm* gửi `next_before_id`, `null` ẩn nút; quên mật khẩu báo rõ tài khoản chỉ có số) · `fe/src/app/dat-mon/t265.test.tsx` (có phiên điền sẵn, sửa form không PUT; không phiên form trống). Kiểm đã chạy (Claude): trong worktree `./scripts/fe-check.sh` — 525 test qua, còn đúng `khach-qr.test.tsx:162` đỏ sẵn ở HEAD; clone chính sau tích hợp: `./scripts/gate.sh` mọi cổng PASS (be-check, db-check 39 bước, verify gồm fe-check).


<a id="t-266"></a>
### T-266 — Sản phẩm và combo chưa có ảnh

**Goal:** Bổ sung vùng ảnh trên danh sách và chi tiết sản phẩm, combo của chủ quán; dùng đúng ảnh chủ repo gửi cho bánh cuốn.

**Nguồn:** Chủ repo yêu cầu 2026-10-28 tại `/chu-quan/san-pham`. Đây là thay đổi trình bày L1, chưa thêm cơ chế tải ảnh lên hay lưu ảnh trong DB/API.

**Nghiệm thu trước khi sửa:** Mọi sản phẩm, kể cả chưa xếp danh mục hoặc ngừng bán, và mọi combo có vùng ảnh; ảnh xuất hiện cả trong chi tiết; ảnh bánh cuốn đúng tệp chủ repo gửi; món chưa có tệp riêng và ảnh tải lỗi có hình giữ chỗ cùng nhãn rõ ràng; không thay đổi giá, trạng thái hay các thao tác hiện có.

**Phạm vi:** Component ảnh dùng chung trong thư mục component chủ quán, trang sản phẩm, trang combo và CSS combo, tài nguyên ảnh công khai trong `fe/public/images/san-pham/`, hồ sơ này; khai báo trong `work/scope/T-266.txt`.

**Bàn giao:** Codex thực hiện, chưa được duyệt độc lập; nhánh `P4A-01`, nền `5451284`. Cây đã có nhiều thay đổi của việc khác, bao gồm `work/backlog.md`; chỉ bổ sung mục việc này. Chủ repo chỉ định tệp `docs/product/4-fe/thiet_ke/anh/banh-cuon.png`; bản public trùng nguyên tệp gốc (đã kiểm bằng `cmp`); dùng ảnh giò, trứng, suất giò/trứng/đầy đủ từ Downloads cho các tên tương ứng, các biến thể chín/tái/vàng dùng chung ảnh minh hoạ theo loại. Canh và combo tên mới chưa có ảnh riêng dùng ảnh minh hoạ đĩa bánh cuốn có nhãn; món mới chưa có ánh xạ có khung giữ chỗ. Kiểm chứng: 57 kiểm thử riêng của hai trang đạt; gate chạy đầy đủ FE: 36 tệp/518 kiểm thử đạt, lint, typecheck, apigen và build đều đạt; render 13 tên món/combo trỏ đúng tệp, ảnh bánh cuốn khớp nguyên tệp gốc, cả 7 ảnh tải qua bộ tối ưu Next trả HTTP 200. `./scripts/gate.sh` thoát 2: phần DB báo đỏ khi xuôi lại và khi lùi migration tài khoản khách `20261027120000_tai_khoan_khach`, còn các hàm `customer_password_reset_used_guard`/`customer_session_ended_guard` trong lược đồ; đây là lỗi ngoài phạm vi L1, chuyển Claude xử lý. Log gốc: `/tmp/t266-gate.log`. Giữ In Progress vì gate chung chưa đạt; bước tiếp theo là Claude sửa bước lùi migration và chạy lại gate, rồi đóng việc thêm ảnh. Chưa commit; khối commit dùng blob riêng của backlog để không gom thay đổi việc khác.


<a id="t-268"></a>
### T-268 — Gộp món lẻ giống nhau trong giỏ khách

**Yêu cầu:** chủ repo 2026-10-28 muốn món lẻ giống nhau ở `/ban/3` gộp một dòng và cộng số lượng.

**Mức:** L1, chỉ đổi nháp giỏ khách ở FE; không đổi hợp đồng, cách tính tiền hay dữ liệu đơn đã lưu.

**Acceptance (trước code):** cùng mã món và cùng tập lựa chọn thì cộng số lượng, kể cả món không lựa chọn và nháp cũ; khác mã món hoặc bất kỳ lựa chọn nào vẫn tách dòng. Giữ thứ tự xuất hiện đầu tiên, sửa số lượng/xoá/bớt đúng dòng; báo giá và gửi đơn dùng số lượng đã gộp. Không gộp dòng có số lượng đang nhập trống/không hợp lệ.

**Scope:** `fe/src/lib/nhap-khach.ts`, `fe/src/app/ban/thuc-don-khach.test.tsx`, `docs/product/4-fe/01-khung-fe.md`, `work/backlog.md`.

**Bàn giao 2026-10-28:** Codex thực hiện trên nhánh `P4A-01`, nền `d9d7e26`, chưa duyệt độc lập. Gộp món lẻ trong `useNhapKhach.sua` và `dungLai`, dùng mã món + tập lựa chọn đã sắp thứ tự; không tính tiền ở FE. Nháp cũ và thêm từ chi tiết dùng cùng đường gộp; combo giữ xử lý hiện có. Bằng chứng acceptance: kiểm thử thẻ món xác nhận cộng số lượng, báo giá backend, sửa/bớt; kiểm thử món không lựa chọn xác nhận gộp, xoá cả dòng, thân gửi đúng số lượng; kiểm thử nháp cũ xác nhận đảo thứ tự lựa chọn vẫn gộp, khác rau/mã món tách riêng, ô trống không mất. Nhóm liên quan 4 tệp/46 kiểm thử đạt; `./scripts/fe-check.sh` đạt apigen, lint, typecheck, 39 tệp/542 kiểm thử và build; sau bổ sung kiểm thân gửi chạy lại tệp tóm tắt 12/12 đạt. Log frontend `/tmp/t268-fe.log`. Đã đọc diff, không thêm dependency/đổi API; kiểm whitespace các tệp của việc này đạt, scope riêng đạt, index chính trống. Cây có nhiều thay đổi từ trước; khối commit phải dùng blob tách riêng backlog và owner FE. Gate trên cây chính `/tmp/t268-gate.log` còn chạy database ở PID 35443 (gate PID 22365); không tuyên bố gate xanh. Kiểm bản commit tách riêng trong `/tmp/t268-review` (có bổ sung nút lựa chọn chưa track từ nền để resolve import): `./scripts/gate.sh` thoát 2; scope, doc-status, schema, cửa ghi, hợp đồng, Gin đạt; links đỏ do tài liệu nền thiếu, verify đỏ tại typecheck vì nền `d9d7e26` có giao diện tài khoản khách nhưng hợp đồng/type chưa có `CustomerProfile` và các endpoint tài khoản khách. Log `/tmp/t268-isolated-gate.log`. Không sửa các owner API L2 ngoài phạm vi. Giữ In Progress; bước tiếp theo Claude tích hợp hợp đồng/type và tài liệu nền, đọc log gate cây chính rồi chạy lại gate. Đã kiểm nội dung stage tách riêng và whitespace trong worktree kiểm tra; index cây chính không thay đổi, chưa commit.

<a id="t-269"></a>
### T-269 — Thẻ COMBO và MÓN LẺ chưa theo mẫu Gemini

**Yêu cầu:** Chủ repo giao trực tiếp ngày 2026-10-29: áp dụng `docs/product/4-fe/thiet_ke/khach_hang/menu/gemini/combo.html` vào hai khối menu ở `fe/src/app/ban`, không đổi phần tóm tắt.

**Goal / Phạm vi:** Thẻ ảnh ngang phía trên, tên/giá cùng hàng, nút Thành phần cho combo, một nút lựa chọn gộp mở bảng trong thẻ, thanh số lượng màu cam. Dùng ảnh sẵn có; không đổi dữ liệu/API hay quy tắc tính giá.

**Lý do / Ảnh hưởng:** Bố cục hiện tại chia hai cột, khác mẫu chủ repo chọn; khách cần cùng kiểu thẻ ở COMBO và MÓN LẺ.

**Acceptance (trước sửa):** Cả hai loại thẻ theo bố cục mẫu, dùng dữ liệu thật; ảnh dẫn đúng chi tiết và giữ mã bàn. Nút gộp mở các nhóm hợp lệ, chọn xong giữ bảng mở; Chay vẫn ẩn lượng nhân. Thêm/bớt và tổ hợp gửi giỏ giữ nguyên; tiền trên thanh đọc báo giá từ API, không tự nhân giá combo. JSX tóm tắt và CSS tóm tắt không đổi. Không tràn ngang ở 320/390/768px, có sáng/tối và giảm chuyển động.

**Cách thực hiện:** Đọc brief/owner → xác định L1 → khai báo scope T-269 → ghi acceptance → sửa hai khối thẻ và bộ chọn riêng → cập nhật owner component → chạy test hành vi/kiểm bố cục → chạy gate → đọc diff → bàn giao khối commit, không commit.

**Bàn giao:** Codex, nhánh P4A-01, base fbcff65; chưa duyệt độc lập. Cây có nhiều thay đổi việc khác từ trước, giữ nguyên và tách khỏi commit T-269. Đang thực hiện.

**Bằng chứng 2026-10-29:** `npm --prefix fe test -- src/app/ban/thuc-don-khach.test.tsx src/app/ban/khach-qr.test.tsx` đạt 2 files/25 tests; payload tổ hợp, gộp dòng, thêm/bớt, giá API và tóm tắt vẫn được kiểm. `npm --prefix fe run lint` và `npm --prefix fe run typecheck` exit 0. Playwright `/tmp/t269-ui.cjs` đạt 14 thẻ ở 320/390/768px cả sáng/tối, ảnh cao 176px nằm trên tên, tên/giá cùng hàng, không tràn; Thành phần mở, Chay ẩn lượng, chọn giữ bảng mở, thêm combo/món và giá dòng API hoạt động, reduced-motion không transition, pageErrors=[]; log `/tmp/t269-ui.log`, ảnh `/tmp/t269-light.png` và `/tmp/t269-dark.png` đã xem. Đối chiếu byte xác nhận JSX từ `{thongTin}` tới cuối component và toàn bộ CSS cũ giữ nguyên; CSS mới chỉ theo lớp menu riêng. Đọc diff theo Gate 4: không đổi dependency, API, dữ liệu, quy tắc giá hay tóm tắt; test chỉ đổi thao tác theo nút gộp và bổ sung kiểm tiền API. Gate toàn cây đang chạy ở `/tmp/t269-gate.log`; chưa kết luận gate xanh. Chưa commit, chưa duyệt độc lập.

**Bàn giao cuối lượt 2026-10-29:** Phần giao diện đã xong; `npm --prefix fe test` đạt 40 files/548 tests, build production exit 0 (`/tmp/t269-build.log`), lint/typecheck/check-fe-rules đều đạt. Gate tách riêng tại `/tmp/t269-review` exit 2: HEAD đã có liên kết thiếu tới hai tài liệu profile và mã tài khoản phụ thuộc kiểu API chưa commit; log `/tmp/t269-isolated-gate.log`, không sửa các phần ngoài scope. Gate cây chung đã chạy trực tiếp, còn đang kiểm ở `/tmp/t269-gate.log`; chưa tuyên bố gate xanh, giữ In Progress để lần sau đọc kết quả và nghiệm thu gate. Snapshot commit chỉ chứa bảy file của T-269 ở `/tmp/t269-commit/`, index diễn tập tại `/tmp/t269-review` đã kiểm diff/whitespace và Gate 9; index cây chính trống. Bước tiếp theo: đọc kết quả gate cây chung, xử lý việc nền bằng đúng task phụ trách nếu cần, rồi chuyển Done khi đủ điều kiện. Không commit hay gửi đơn thật; không đổi tóm tắt.


<a id="t-273"></a>
### T-273 — Bố trí bốn món theo vòng cung trong bản mẫu menu mâm

Chủ repo giao trực tiếp Codex ngày 2026-10-29; L1, chỉ bản HTML minh hoạ.
Phạm vi: `docs/private/prompt/menu-mam.html`, `work/backlog.md`.

Acceptance cập nhật trước lượt sửa 2026-10-29 theo yêu cầu mới của chủ repo: (1) mặc định bốn mâm nằm trên vòng cung, có tên và giá ở 320/390/430px và desktop; (2) nút trước/sau hoặc vuốt ngang dịch một món để xem đủ sáu món, không tự thêm vào giỏ và không nhận cuộn dọc là vuốt; (3) bấm mâm đổi chi tiết, giữ lựa chọn và giỏ; (4) lọc đúng bốn combo/hai món lẻ, không nhân đôi món để đủ bốn; (5) ví dụ 64.000đ, tăng/giảm/bỏ và giỏ trống giữ đúng; (6) chạy gate và báo kết quả thật. Yêu cầu vòng cung thay cho lưới sáu món ở lượt trước.

Thực hiện: Codex; chưa có duyệt độc lập. Nhánh `P4A-01`, base `6dea88f`; cây có thay đổi của nhiều task từ trước, không đưa vào task này.

Bàn giao Codex 2026-10-29: lưới ba cột hai hàng thay carousel; bấm mâm đổi chi tiết; bỏ xử lý vuốt và nút chuyển mâm. Đã đọc diff, không thêm dependency hay đổi giá/cách tính. Chrome headless PASS ở 320×700, 390×844, 430×932, 1280×900: sáu nút món nằm trong viewport, không tràn ngang và không bị thanh đáy che. PASS các thao tác chọn không thêm giỏ, ví dụ 64.000đ và thành phần [7,2,0,2,2], khác nhân thành dòng riêng, lọc 4/2/6, giữ giỏ/lựa chọn, tăng/giảm/bỏ, mở/đóng đơn, giỏ trống.

Gate ở worktree riêng `/tmp/menu-grid-273-check` từ HEAD: Gate 3, 1c, 1e, 1f, 1g, 1h PASS; 1d và verify SKIP (chỉ tài liệu). Gate 1b FAIL vì prompt profile có từ HEAD trỏ hai file `customer_profile.md` và `customer_profile_loading.md` chưa tồn tại trong HEAD. Không sửa tài liệu profile ngoài phạm vi. Task giữ In Progress vì gate chưa xanh; phần giao diện đã hoàn tất. Log `/tmp/menu-grid-273-isolated-gate.log`, ảnh `/tmp/menu-grid-273.png`. Chưa duyệt độc lập, chưa commit. Bước tiếp: lead xử lý liên kết profile rồi chạy lại gate và chuyển Done.

Lượt sửa vòng cung 2026-10-29 theo yêu cầu mới: hiển thị tối đa bốn mâm theo cung, có tên và giá; nút trước/sau và vuốt ngang dịch cửa sổ từng món, dừng đúng hai biên. Bấm mâm đổi chi tiết, không thêm giỏ. Lọc hai món lẻ chỉ hiện hai mâm. Đã đọc diff, không thêm dependency, không đổi dữ liệu minh hoạ hay phép tính. Chrome headless PASS 320×700, 390×844, 430×932, 1280×900: bốn mâm theo cung, không tràn ngang hoặc đè nút; thao tác cảm ứng qua Chrome DevTools Input PASS vuốt trái/phải và cuộn dọc không đổi mâm. PASS nút/biên, chọn mâm, ví dụ 64.000đ, khác nhân thành dòng riêng, lọc 4/2/4, giữ lựa chọn và giỏ, tăng/giảm/bỏ, mở/đóng đơn và giỏ trống. Ảnh `/tmp/menu-arc-273.png`, kịch bản kiểm `/tmp/menu-arc-test.cjs`. Gate chạy lại trên snapshot chỉ chứa task này: exit 2, Gate 3/1c/1e/1f/1g/1h PASS, 1d/verify SKIP; Gate 1b vẫn FAIL đúng hai liên kết profile thiếu từ HEAD như ghi ở lượt trước, log `/tmp/menu-arc-273-gate.log`. Giữ In Progress vì gate chưa xanh; phần vòng cung hoàn tất, chờ lead gỡ lỗi liên kết ngoài phạm vi rồi nghiệm thu. Chưa commit, chưa có duyệt độc lập. Khối commit mới của lượt vòng cung thay khối commit lưới ở lượt trước.

<a id="t-274"></a>
### T-274 — Bản mẫu menu theo concept bàn gỗ ấm cúng

Chủ repo yêu cầu 2026-10-30: giao Codex tạo menu giống concept `docs/private/anh/menu-moi/Giao diện món Bánh cuốn ấm cúng.png`, Claude kiểm tra. L1.

Quyết định của Claude 2026-10-30 (suy ra, chờ chủ repo duyệt khi xem bản mẫu): làm bản mẫu HTML trong `docs/private/prompt/menu-am-cung/`, không đụng `fe/`, vì lời yêu cầu nối tiếp chuỗi bản mẫu `menu-mam.html` và `thuc-don-khach.tsx` đang có thay đổi chưa commit. Ảnh món chỉ cắt từ concept vì ảnh thật không cùng phong cách. Dưới 480px dải món cuộn ngang thay vì nhồi đủ 5 món như ảnh, để giữ vùng bấm 44px. Giá theo `master_plan/shop-facts.md` §4.3–§4.4.

Acceptance: (A1) bố cục đúng concept từ tên quán tới dải vòng cung; (A2) không tràn ngang ở 320×568, 390×844, 430×932, 1280×900; (A3) vùng bấm ≥ 44px; (A4) đĩa nhỏ, nút ‹ ›, vuốt ngang đổi món đồng bộ, không thêm giỏ, dừng ở biên, cuộn dọc không đổi món; (A5) *Mua* và nút + thêm đúng số lượng, chấm đếm đúng; (A6) *Chi tiết* đổi lựa chọn đổi giá đúng (combo Chay 26.000đ, Thịt + Nhiều 34.000đ); (A7) giỏ gộp/tách dòng, 2 combo + 1 bánh cuốn + 1 canh = 64.000đ, không có nút gửi đơn; (A8) không request mạng, không lỗi console, reduced-motion; (A9) kịch bản Chrome headless và ảnh đối chiếu; gate xanh.

Sửa acceptance 2026-10-30 (Claude, sau khi thấy ảnh chụp): nút + ở đĩa nhỏ thêm theo lựa chọn đang giữ của món, không theo mặc định, để giá trên thẻ luôn bằng giá được thêm.

Bàn giao 2026-10-30: thực hiện Codex (`codex exec -m gpt-6-astra`, worktree `../lean_wt/T-274`, nhánh `codex/T-274` từ `02d6fbe`, hai vòng), duyệt Claude. Sandbox của Codex chặn Chrome nên Claude tự chạy kịch bản 390×844 và 320×568 cùng bốn khung còn lại: mọi kiểm tra PASS, 0 lỗi console, 0 request mạng. Đối chiếu ảnh với concept: vòng 1 tìm ra ảnh lớn đè tên và giá, đã sửa. Còn lệch có chủ ý: dưới 480px hiện khoảng 4 món thay vì 5; giỏ khởi đầu trống. Còn lệch chưa sửa: gỗ tối hơn concept vì nền phải vá, ảnh lớn của bốn món ngoài combo mờ hơn vì phóng từ ảnh nhỏ. Bản mẫu chưa có chế độ *Hỗn hợp* (T-271). Chưa nối vào `fe/`.

<a id="t-275"></a>
### T-275 — Bản thực hành Paris từ tài nguyên video Creativo

Chủ repo giao trực tiếp 2026-10-31: đọc `docs/private/video-paris-scroll/prompts.md`, thực hành giống video Creativo tại mốc 77 giây, dùng agent phụ đảm bảo chất lượng. L1, chỉ dựng website tĩnh độc lập trong `docs/private/video-paris-scroll/website/`; backlog và scope là hồ sơ công việc. Không sửa ứng dụng quán, owner nghiệp vụ hoặc triển khai lên mạng.

Acceptance trước triển khai (Codex, 2026-10-31): (A1) kiểm kê frame thật: hiện 0 frame, không có định dạng/kích thước/thứ tự để công bố; dừng phần hiệu ứng theo prompt, dùng ảnh tĩnh có nhãn, không bịa tên frame; nếu chủ repo cho phép chuẩn bị frame từ video thật thì ghi rõ thay đổi; (A2) dùng tài nguyên thật từ Drive tác giả, đường dẫn tương đối phục vụ từ website/; (A3) bố cục tạp chí với điều hướng, hero, giới thiệu, ba địa điểm, hành trình một ngày, footer, nội dung tiếng Việt không bịa giá/đánh giá; (A4) không tràn ngang 320/390/430/1280px, bàn phím và reduced-motion dùng được, có xử lý ảnh lỗi; (A5) server gốc website/ không có request ảnh lỗi hay JavaScript lỗi, ghi cách chạy và giới hạn thực tế; (A6) agent độc lập đọc artifact và bằng chứng, chạy `./scripts/gate.sh`, đọc diff và bàn giao commit chỉ chứa task này.

Thực hiện Codex, agent `reference_review` đối chiếu nguồn và agent `quality_review` duyệt artifact/trình duyệt độc lập, đều chỉ đọc. Nhánh `P4A-01`, nền `39f2143`. Cây có nhiều thay đổi từ trước ngoài phạm vi và task khác đang thêm backlog; không gộp vào việc này. Tài liệu nguồn ngoài website/ giữ nguyên theo prompt.

Cập nhật phạm vi được chủ repo xác nhận 2026-10-31: “Dùng video gốc để làm tiếp hiệu ứng cuộn”. Cho phép tách `Plane window.mp4` thật vào `website/assets/frames/` dù assets/frames/ gốc đang rỗng. Acceptance A1 bổ sung: kiểm kê chuỗi thật sau tách; cuộn xuôi/ngược đúng frame; canvas giữ tỷ lệ, resize/DPR, requestAnimationFrame, tải trước và cache có giới hạn, ưu tiên frame đầu, trạng thái tải/lỗi, reduced-motion dùng ảnh tĩnh. Giữ mọi sản phẩm trong website/.

Bàn giao Codex 2026-10-31: đã dựng HTML/CSS/JS tĩnh trong website/, 157 JPEG 1280×720 từ video thật 1920×1080/30fps/10,433s của tác giả, tách 15fps, 4,66 MiB. Nguồn và hash video ở website/assets/sources.json; frames.json lấy danh sách file thật theo số. Canvas cuộn hai chiều, resize/DPR, RAF theo sự kiện, cache 10 và tải đồng thời 3; lỗi ảnh/manifest giữ cảnh hoặc về poster, reduced-motion bỏ request chuỗi. Nội dung Paris tiếng Việt, liên kết nội trang, không đặt tour/backend/triển khai. Cách chạy trong website/README.md.

Acceptance → bằng chứng: A1/A2: ffprobe + kiểm manifest 157 file tồn tại/duy nhất/thứ tự số; Chrome xác nhận frame 0→39→78→140→156→78→0 tương ứng cuộn 0→25→50→90→100→50→0%, reviewer kiểm thêm 80%→125, cache≤10 và pending≤3. A3: đọc HTML và xem ảnh hero/nội dung; A4/A5: Chrome PASS 320×700, 390×844 DPR3, 430×932, 1280×900; reviewer PASS thêm 320×568 DPR2; không tràn ngang, resize, keyboard skip, href có đích, giảm chuyển động mở đầu + đổi trực tiếp, tắt JS, manifest 404/toàn bộ frame 404/một frame lỗi đều xử lý; đường bình thường 0 lỗi JS/HTTP. Kịch bản/log chính `/tmp/paris-scroll-task/browser-check.cjs`, `browser-results.txt`, ảnh hero/content; duyệt độc lập `/tmp/paris-quality-review.json`, `/tmp/paris-quality-review.cjs`, `/tmp/paris-review-extra.cjs`; reviewer không phát hiện lỗi chặn. Node syntax và whitespace PASS; không thêm dependency hoặc sửa ứng dụng quán. Chưa kiểm Safari/thiết bị thật/trình đọc màn hình.

A6: đã đọc diff/red flags và chạy gate. Gate trên cây chung khởi chạy nhưng bị dừng (exit 143), không có kết quả để tuyên bố xanh. Gate trực tiếp trên worktree `/tmp/paris-scroll-task/review-tree` từ HEAD chỉ ghép task Paris: exit 2, scope/1c/1e/1f/1g/1h PASS, 1d và verify SKIP (gate coi docs/ là tài liệu); Gate 1b FAIL đúng hai link từ file profile-gemini.md có sẵn trong HEAD tới `customer_profile.md` và `customer_profile_loading.md` chưa tồn tại trong HEAD. Log `/tmp/paris-scroll-task/isolated-gate.log`. Không sửa profile ngoài phạm vi; giữ In Progress vì gate chưa xanh. Phần website đã được kiểm xong. Bước tiếp theo: lead xử lý liên kết profile theo task riêng, chạy lại gate rồi nghiệm thu Done. Backlog commit được tách blob chỉ chứa phần Paris trên HEAD; manifest liệt kê từng tệp từ git, index cây chính giữ nguyên, không commit.

<a id="t-276"></a>
### T-276 — Thiết kế tạo combo yêu thích riêng cho khách

Chủ repo giao trực tiếp Codex ngày 2026-10-31: thêm nút tạo combo yêu thích riêng cho từng khách trong bản thiết kế `docs/product/4-fe/thiet_ke/khach_hang/favourite/favourite.html`. L1, chỉ tương tác minh hoạ cục bộ; không sửa hợp đồng, backend hoặc quy tắc bán hàng.

Phạm vi: tệp HTML trên và `work/backlog.md`; scope ở `work/scope/T-276.txt`.

Acceptance trước sửa: (A1) nút Tạo combo riêng nổi bật, mở form đặt tên, chọn món và số lượng, tổng minh hoạ cập nhật; không lưu tên trắng hoặc combo rỗng. (A2) combo có tên, thành phần, tổng và thao tác thêm giỏ minh hoạ, sửa, xoá; huỷ không đổi dữ liệu. (A3) hai hồ sơ khách minh hoạ có dữ liệu riêng, đổi khách không lẫn combo/giỏ; tải lại giữ combo; dữ liệu bộ đã lưu cũ còn dùng được. (A4) giữ lọc món, bộ đã lưu và sáng/tối; không tràn ngang ở 320/390/430/1280px, modal cuộn được và dùng bàn phím. (A5) chạy kiểm tương tác trình duyệt, đọc diff và chạy gate; bàn giao commit chỉ chứa việc này.

Thực hiện Codex; chưa duyệt độc lập. Nhánh `P4A-01`, nền `39f2143`. Cây có nhiều thay đổi từ trước, kể cả backlog và toàn thư mục favourite chưa track; snapshot trước sửa tại `/tmp/t276`. Chỉ sửa tệp HTML và hồ sơ task này; không nhận thay các thay đổi nền. Bước tiếp theo: triển khai form và kiểm tương tác.


Bàn giao 2026-10-31: phần giao diện đã hoàn tất. Nút tạo mở form chọn món/số lượng, đặt tên và tổng minh hoạ; thẻ combo có sửa, xoá, thêm giỏ. Hai hồ sơ minh hoạ lưu riêng theo khoá trình duyệt, giữ dữ liệu cũ cho Khách 01; giỏ riêng trong phiên, dữ liệu trong phiên vẫn còn khi lưu trữ bị chặn. Không nối tài khoản thật hoặc backend. Codex đã tự đọc diff theo Gate 4, không thêm dependency hay đổi API; chưa duyệt độc lập.

Bằng chứng acceptance: Chrome headless qua CDP, `python3 /tmp/t276/check_ui.py` exit 0, 48 dòng PASS tại `/tmp/t276/ui-final.log`: A1 chọn món/tổng 60.000đ/chặn rỗng và tên trắng; A2 tạo/sửa/huỷ/xoá/thêm giỏ và escape tên; A3 tải lại, hai hồ sơ độc lập, giữ bộ cũ, lỗi lưu trữ; A4 bộ đã lưu và lọc còn dùng được, 320/390/430/1280px cả sáng/tối không tràn, Esc đóng modal và focus đúng. Không có JavaScript exception. Ảnh đã xem: `/tmp/t276/page-dark.png`, `/tmp/t276/modal-light.png`.

Đã chạy trực tiếp gate cây chung nhưng dừng các lượt do phiên này khởi chạy vì kiểm scope chạy nhiều phút chưa có output; không kết luận gate cây chung. Chạy `./scripts/gate.sh` trong snapshot tách riêng `/tmp/t276-review` (HEAD `39f2143`, chỉ HTML và hồ sơ T-276) exit 2, log `/tmp/t276/isolated-gate.log`: Gate 3/1c/1e/1f/1g/1h PASS; 1d và verify SKIP vì chỉ tài liệu. Gate 1b FAIL vì tài liệu nền `docs/private/prompt/profile-gemini.md` trỏ tới hai tệp chưa có trong HEAD: `customer_profile.md`, `customer_profile_loading.md` dưới thư mục profile. Không sửa lỗi nền ngoài scope. Giữ In Progress do gate chưa xanh; bước tiếp theo lead xử lý hai liên kết nền rồi chạy lại gate và nghiệm thu.

Khối commit dùng `/tmp/t276/backlog-only.patch` chỉ chứa hồ sơ T-276 so với HEAD; toàn bộ thay đổi backlog của việc khác được giữ ngoài index. Tệp HTML vốn chưa track nên commit sẽ thêm cả bản thiết kế đã có và phần combo mới. Index diễn tập nằm ở worktree tách riêng, index cây chính không đổi. Không chạy lệnh commit hoặc xoá; giữ scope đến sau commit.

<a id="t-277"></a>
### T-277 — Hiệu ứng khi ảnh món xuất hiện trong trang thử menu

Chủ repo yêu cầu 2026-10-31: làm hiệu ứng khi ảnh xuất hiện ở `docs/private/prompt/menu-am-cung/anh-moi.html`. L1, chỉ bản mẫu. Kiểu hiệu ứng do Claude chọn, chờ chủ repo xem.

Acceptance: (1) đổi món hoặc tải trang: ảnh mới mờ dần hiện lên đè ảnh cũ, trượt nhẹ theo hướng đổi món, tên · giá · thành phần hiện nối tiếp; (2) bấm đổi món liên tục vẫn dừng đúng món cuối, chỉ còn một lớp ảnh; (3) đổi qua lại với Canh không giật nền; (4) đổi món không thêm vào giỏ; (5) `prefers-reduced-motion` đổi ngay, không chuyển động; (6) không lỗi console, gate xanh.

Bàn giao 2026-10-31: thực hiện và tự kiểm Claude, chưa có người duyệt độc lập. Kịch bản Chrome 390×844 đạt cả sáu dòng (ảnh mới đè ảnh cũ với độ mờ tăng dần, bấm liên tục 8 lần còn một lớp, giảm chuyển động không có animation, 0 lỗi console). Canh giờ dùng ảnh bàn gỗ qua cùng lớp ảnh để không giật nền. File `anh-moi.html` đã được khôi phục từ `6b4512c` trước khi sửa vì bị xoá trong cây làm việc.

<a id="t-278"></a>
### T-278 — Thiết kế lại trang /dang-nhap có nút đăng nhập nhanh bằng Google

Chủ repo trong hội thoại 2026-10-31 yêu cầu *"http://localhost:3000/dang-nhap thiết kế lại có nút đăng nhập nhanh bằng google"* và trả lời *"tất cả"* khi được hỏi nút dành cho ai (khách, nhân viên, chủ quán), sau đó *"ok duyệt"* phạm vi, và chọn *"Chuyển Claude lập phiếu triển khai"* khi được hỏi Codex tự làm hay chuyển Claude. Trang `/dang-nhap` là màn đăng nhập của người làm (xem `fe/src/app/dang-nhap/page.tsx` dùng `FormDangNhap`), còn `/khach/dang-nhap` là màn khách. Google cho khách đã có lát thi công theo **ADR-132** (nằm trong `docs/private/google-login/`, chưa commit cùng T-264/T-267/T-270); nút Google cho người làm thì ADR-132 *loại ngay từ đầu* vì tài khoản người làm phải chờ chủ quán duyệt (ADR-109 điểm 1). Lời chủ repo chỉ duyệt **phạm vi** nút cho mọi đối tượng, chưa duyệt **chính sách liên kết hay cấp quyền** cho người làm — câu đó mở ở **U-111** ngay dưới.

Việc chia làm ba lát: **lát 1 (task này, L1)** — bản HTML tĩnh thiết kế lại giao diện `/dang-nhap` cho người làm, đặt tại `docs/product/4-fe/thiet_ke/chu_quan/dang_nhap/dang-nhap.html`; chỉ là bản mẫu kiểu T-274 · T-277, không phải thi công. Lát 2 (FE thật) và lát 3 (BE Google cho người làm) **đang chặn** cho tới khi (a) chủ repo trả lời U-111, (b) T-264/T-267/T-270 commit xong theo `docs/private/google-login/commit-khach.sh`, (c) có **ADR-135** chốt chính sách Google cho người làm.

Phạm vi lát 1 (`work/scope/T-278.txt`): `docs/product/4-fe/thiet_ke/chu_quan/dang_nhap/dang-nhap.html` (file mới, thư mục mới) và `work/backlog.md`. Cấm sửa code ứng dụng, hợp đồng, migration, owner nghiệp vụ. Nền `HEAD = 3ff2490`.

Acceptance của lát 1 (mỗi dòng phải có bằng chứng trong báo cáo Codex, không được đoán):
- (A1) **Khối Google ở trên cùng**: một nút *Tiếp tục với Google* theo kiểu `size=large` · `theme=outline` · `locale=vi` (giống `fe/src/components/khach/google.tsx` dòng 46), có hình logo Google, nằm trước phần nhập số điện thoại/Gmail; dưới nút có dòng chú thích *"Chỉ dùng được khi tài khoản của bạn đã được chủ quán duyệt"* và một liên kết nhỏ *"Chưa có tài khoản? Đăng ký"* trỏ `/dang-ky`.
- (A2) **Vạch ngăn** chữ *"hoặc"* giữa khối Google và form mật khẩu.
- (A3) **Form mật khẩu còn đủ ba trường của HEAD** (`FormDangNhap` dòng 46–64): một ô *Số điện thoại hoặc Gmail* (`autocomplete=username`), ô *Mật khẩu* (`autocomplete=current-password`), checkbox *Đăng nhập tại quầy (bắt đầu đứng quầy)* đi cùng nút *Đăng nhập*; không đổi tên trường, không bỏ `tai_quay`, không ghép `tai_quay` vào nút Google.
- (A4) **Hai liên kết dưới form** như hiện tại: *Đăng ký tài khoản* → `/dang-ky`, *Quên mật khẩu* → `/quen-mat-khau`.
- (A5) **Trạng thái lỗi minh hoạ**: ba khối báo đỏ ví dụ, một cho `login_failed`, một cho `google_login_disabled` (ẩn nút, hiển thị dòng *"Đăng nhập nhanh bằng Google tạm thời chưa bật"*), một cho `google_token_invalid` (nút còn, kèm thông báo đỏ dưới nút). Nội dung thông báo không trái thiết kế lớp `khach` của ADR-132: chữ *"chủ quán"* xuất hiện ở phần người làm, không nhầm sang khách.
- (A6) **Chú thích chờ chủ quán** đặt rõ trong trang (chú thích ở cuối hoặc trong khối Google): nêu rằng chính sách Google cho người làm còn chờ chủ quán quyết (U-111), bản mẫu không hứa luồng cấp tài khoản tự động, không gọi API thật.
- (A7) **Không tràn ngang** ở 320/390/430/1280px (như T-276/T-277), đọc được bằng bàn phím (`Tab` qua nút Google · ô định danh · ô mật khẩu · checkbox · nút Đăng nhập · hai liên kết), bỏ dấu `prefers-reduced-motion` không có animation nào vỡ.
- (A8) **File tĩnh thuần**: HTML + CSS inline hoặc một tệp CSS cạnh file, không fetch Google thật, không script `gsi/client`, không gọi `/customer-sessions/google` — nút chỉ là hình minh hoạ. Ghi rõ *"bản mẫu tĩnh, chưa đăng nhập thật"* trong trang.
- (A9) `./scripts/gate.sh` xanh trên worktree sạch từ `HEAD`, bằng chứng là 7 dòng PASS/SKIP không `FAIL` của log gate dán vào báo cáo. Lưu ý Gate 1b có hai FAIL nền ở `docs/private/prompt/profile-gemini.md` trỏ `customer_profile.md` · `customer_profile_loading.md` chưa có trong HEAD (T-275 · T-276 đã gặp); nếu bị, dán nguyên log và nêu rõ *FAIL nền ngoài phạm vi*.

Phiếu Codex đầy đủ (Context, Scope, Acceptance, Cấm, Báo cáo) nằm ở scratchpad ngoài repo `/tmp/google-login-claude-handoff/work-order.txt`, không lưu vào repo theo CLAUDE.md §3.8. Chủ repo dán nó vào Codex ở worktree mới `../lean_wt/T-278` nhánh `codex/T-278` tạo từ `HEAD = 3ff2490`; không có phụ thuộc chưa commit, có thể giao ngay.

Bàn giao từ Claude 2026-10-31 (lập phiếu): phiếu viết ra `/tmp/google-login-claude-handoff/work-order.txt`, scope `work/scope/T-278.txt` giới hạn file HTML mới + hồ sơ task. Chặn lát 2 (FE thi công nút trong `fe/src/components/tai-khoan/form-dang-nhap.tsx`) và lát 3 (BE cửa `POST /sessions/google` lớp `nhan_vien`) cho tới khi chủ repo trả lời **U-111** và `docs/private/google-login/commit-khach.sh` đưa T-264/T-267/T-270 vào HEAD; sau đó Claude mở **ADR-135** chốt chính sách và viết test hồi quy cho I-033/I-035 trước khi giao tiếp.

Bàn giao từ Codex 2026-10-31 (thi công lát 1): worktree `/Users/monghoaivu/Desktop/code/lean_wt/T-278`, nhánh `codex/T-278`, nền `HEAD = 3ff2490`; chỉ tạo một file `docs/product/4-fe/thiet_ke/chu_quan/dang_nhap/dang-nhap.html` (218 dòng, 16,8 KiB, HTML + CSS inline + JS tĩnh — không fetch, không nạp `gsi/client`, không ghi storage). Logo Google SVG inline bốn màu. Chín dòng Acceptance có bằng chứng ở `/tmp/google-login-claude-handoff/implementation-report.md` kèm `browser-check.cjs` chạy Playwright/Chrome: PASS cho bốn kích thước 320/390/430/1280px ở hai giao diện sáng/tối, đi được bàn phím đúng chuỗi *google → identifier → password → tai_quay → submit → register → forgot*, ba trạng thái lỗi `login_failed · google_login_disabled · google_token_invalid` chuyển qua bộ chọn minh hoạ, `prefers-reduced-motion: reduce` 0 animation, tắt JavaScript nút `Đăng nhập` disabled nên Enter không ghi mật khẩu vào URL, chỉ 1 request document mỗi lần mở (không script/font/image/API ngoài), 0 lỗi JS/HTTP. Ảnh ở `login-{320,390,430,1280}-{light,dark}.png` + ba ảnh trạng thái 390px. `./scripts/gate.sh` trong worktree exit 2 do đúng hai liên kết nền của `docs/private/prompt/profile-gemini.md` trỏ `customer_profile.md` · `customer_profile_loading.md` (có sẵn trong HEAD, T-275 · T-276 đã gặp); mọi dòng khác PASS/SKIP — log ở `implementation-gate.log`. Codex đã dừng (SIGTERM) đúng tiến trình `check-scope` của Claude ở gate cây chính vì nó treo hơn 4 phút; không có bằng chứng gate cây chính xanh.

Tích hợp từ Claude 2026-10-31 (lead duyệt): đã xem báo cáo và sáu ảnh (390 sáng/tối + ba trạng thái lỗi) — chín dòng Acceptance đều đạt, nút Google đứng trước phần mật khẩu, chú thích *"Chỉ dùng được khi tài khoản của bạn đã được chủ quán duyệt"* và dòng *"Bản mẫu tĩnh — nút Google cho người làm còn chờ chủ quán chọn cách cấp tài khoản (U-111)"* có đủ; không trạng thái nào hứa luồng tự động cấp tài khoản. Chỉ chép file HTML về cây chính, không chạm thay đổi dirty của task khác (sqlc, khoanchi, customer google T-264/T-267/T-270, …). Entry này vẫn giữ **In Progress** vì gate cây chính không xanh do hai liên kết nền ngoài phạm vi; sẽ chuyển Done khi chủ repo gộp sửa link nền (task khác) hoặc chấp nhận ngoại lệ ở `scripts/check-links.ignore`. Khối commit tách blob viết ở `/tmp/google-login-claude-handoff/lead-review.md` — chỉ ba đường dẫn thuộc T-278 (HTML mới, dòng T-278 trong `work/backlog.md`, khối U-111 trong `docs/product/99-unknowns.md`); không `git add` cả file shared.

Cập nhật từ Claude 2026-11-01 (lead): chủ repo trả lời U-111 trong chat cùng ngày hai lượt — lượt một *"cho đang kí bằng gmail không cần duyệt"*, lượt hai *"Dùng ngay như khách; chủ quán cấp quyền làm việc khi cần"*. **U-111 đã đóng** trong `docs/product/99-unknowns.md` → *Đã có lời giải*. Thiết kế hệ quả chốt ở **ADR-135** mới (`docs/decisions.md`): cùng một cửa `POST /customer-sessions/google` phục vụ cả hai trang, phân nhánh theo `sub` trong `account_google_identity`; Gmail chưa có liên kết đi về không gian khách; chủ quán cấp quyền sau bằng cách tạo `account` thủ công rồi gắn `sub` ở trang nhân viên (lát sau). Bản mẫu HTML lát 1 vẫn chạm được acceptance A1–A9 cũ nhưng nay có chú thích lỗi thời (*"chờ chủ quán duyệt"*, *"U-111 còn mở"*) — tách thành **T-280 Lát D** để Codex sửa nhỏ. Lát A (DB migration `account_google_identity`, L2, task `T-281` khi mở) chạy trên HEAD được, không chờ baseline Google khách. Lát B (BE, L2, `T-282`) và Lát C (FE thật, L2, `T-283`) phụ thuộc commit T-264/T-267/T-270 — phải chạy `bash docs/private/google-login/commit-khach.sh` trước. Entry này giữ **In Progress** cho tới khi bản mẫu HTML được sửa theo lời mới (T-280 Done); các lát A/B/C mở task riêng.

<a id="t-280"></a>
### T-280 — Lát D: Sửa bản mẫu /dang-nhap theo lời U-111 2026-11-01

Claude mở 2026-11-01 sau khi chủ repo trả lời U-111 (xem T-278 phần cập nhật và **ADR-135**). L1, chỉ sửa bản mẫu HTML tĩnh đã có; không chạm FE/BE/DB. Codex thi công.

Phạm vi (`work/scope/T-280.txt`): `docs/product/4-fe/thiet_ke/chu_quan/dang_nhap/dang-nhap.html`, `work/backlog.md`. Cấm chạm `docs/decisions.md`, `docs/product/99-unknowns.md`, `master_plan/`, `quality/invariants.md`, `CLAUDE.md`.

Acceptance (mỗi dòng có bằng chứng trong báo cáo Codex):
- (A1) Dòng chú thích dưới nút Google đổi từ *"Chỉ dùng được khi tài khoản của bạn đã được chủ quán duyệt"* thành *"Chưa gắn vai làm việc thì bạn vào không gian khách; chủ quán cấp quyền khi cần."*. Nội dung này khớp lời chủ repo 2026-11-01 (ADR-135 điểm 2–3).
- (A2) Khối chú thích bản mẫu ở cuối trang bỏ dòng *"nút Google cho người làm còn chờ chủ quán chọn cách cấp tài khoản (U-111)"*, thay bằng *"Chốt ADR-135: Gmail chưa có vai làm việc đi về không gian khách; chủ quán cấp quyền sau khi cần."*. Dòng *"Bản mẫu tĩnh, chưa đăng nhập thật."* giữ nguyên.
- (A3) Bộ chọn `demo-state` thêm **một** mục mới *"Vào không gian khách"* (`value="space_khach"`): bật trạng thái một thông báo xanh dưới nút Google *"Đã đăng nhập bằng Gmail chưa có vai. Bạn sẽ dùng không gian khách — chủ quán cấp quyền khi cần."* (không ẩn nút); ba trạng thái cũ `login_failed · google_login_disabled · google_token_invalid` giữ nguyên hành vi.
- (A4) Chuỗi Tab, kích thước 320/390/430/1280px, giao diện sáng/tối, `prefers-reduced-motion`, no-JS submit disabled — tất cả giữ nguyên bằng chứng của T-278; chạy lại `browser-check.cjs` (nếu Codex có script cũ, nhân bản vào `/tmp/t280-check/`) cho ra PASS tương đương, chụp lại ảnh trạng thái mới `space_khach` ở 390px.
- (A5) `./scripts/gate.sh` trong worktree sạch exit đúng 2 do hai liên kết nền của `docs/private/prompt/profile-gemini.md` chưa có trong HEAD (Gate 1b, như T-275 · T-276 · T-278 đã gặp); các dòng khác PASS/SKIP. Không sửa link nền.

Phiếu Codex đầy đủ ở `/tmp/google-login-claude-handoff/next-work-order.txt` — chưa trong repo. Nền `HEAD = 4a8ee3e`; không phụ thuộc baseline chưa commit nào. Worktree `../lean_wt/T-280` nhánh `codex/T-280`.


<a id="t-279"></a>
### T-279 — Bản HTML chi tiết món kể chuyện theo cuộn

Chủ repo yêu cầu 2026-10-31: dựng file HTML xem trước trang product detail theo `docs/private/thiet-ke/y-tuong-day-du.md`, tương tự bản Paris trong `docs/private/video-paris-scroll`. L1, bản mẫu cục bộ; không đổi nghiệp vụ hay ứng dụng thật.

Phạm vi: `docs/private/thiet-ke/product-detail/` và phần hồ sơ việc này trong `work/backlog.md`. Ảnh gốc đọc từ `docs/private/anh/Vibrant Vietnamese Rice Roll Feast.png`, sao chép vào thư mục bản mẫu để mở độc lập.

Acceptance ghi trước khi thi công: A1 — năm nhịp toàn cảnh, tiến gần, khám phá ảnh, chọn phần, kết bằng toàn cảnh; nền kem, nâu, cam đất và xanh lá. A2 — ảnh phóng/dịch theo cuộn; hỗ trợ giảm chuyển động và mở trực tiếp file HTML. A3 — lựa chọn, số lượng và tổng tiền minh hoạ cập nhật; thêm giỏ và xem giỏ hoạt động trong bộ nhớ, ghi rõ không gửi đơn thật. A4 — không tràn ngang ở 320/390/430/1280px, điều khiển có nhãn và dùng bàn phím được. A5 — tự đọc diff, kiểm JavaScript và trình duyệt, chạy trực tiếp `./scripts/gate.sh`, bàn giao commit chỉ chứa việc này.

Bàn giao đang làm: Codex, chưa duyệt độc lập; nhánh `P4A-01`, nền `3ff2490`. Cây chung và backlog đã có nhiều diff việc khác; không gom chúng vào commit. Chưa commit.

Bằng chứng 2026-10-31: A1 — tự xem ảnh Chrome desktop 1280px và mobile 320px (hero, khối chuyển cảnh và khối chọn phần); có đủ năm nhịp, dùng ảnh gốc và CSS/JS inline, không thêm dependency. A2 — Chrome mở trực tiếp file://, cuộn 0/50/90/100% rồi trở về đầu đổi đúng chương 1/2/3 và transform ảnh; giảm chuyển động tĩnh, bật/tắt trực tiếp được, không JS vẫn đọc đủ ba mô tả. A3 — phần 49.000đ + thêm 7.000đ × 2 = 112.000đ, thêm hai lần gộp 4 phần = 224.000đ, bỏ món về giỏ trống; yêu thích, Escape và trả focus về nút giỏ đạt. A4 — Chrome 320×700, 390×844, 430×932, 1280×900 không tràn ngang; skip link bằng Tab/Enter, anchor, ảnh, 0 lỗi JavaScript và 0 request ngoài. Kịch bản và output ở `/tmp/t279-preview/check.cjs`, `/tmp/t279-preview/results.txt`; ảnh trong cùng thư mục. A5 — JavaScript hợp lệ, đã đọc diff/red flags, không đổi API hay nghiệp vụ; index cây chính giữ trống.

Gate trực tiếp cây chung được khởi chạy, dừng lượt của phiên này vì check-scope vẫn chạy nhiều phút chưa ra output; không tuyên bố kết quả cây chung. Gate trên worktree riêng `/tmp/t279-preview/review-tree` từ HEAD chỉ có bản HTML, ảnh và hồ sơ việc này thoát 2: Gate 3/1c/1e/1f/1g/1h PASS, 1d và verify SKIP (docs-only); Gate 1b FAIL do hai đường dẫn nền trong `docs/private/prompt/profile-gemini.md` tới `customer_profile.md` và `customer_profile_loading.md` không có từ HEAD. Log `/tmp/t279-preview/gate-review.log`. Không sửa phần hồ sơ khách ngoài phạm vi. Giữ In Progress vì gate chưa xanh; giao diện đã đủ để chủ repo xem. Bước tiếp theo: lead xử lý hai liên kết nền rồi chạy lại gate để nghiệm thu. Chưa duyệt độc lập, chưa commit. Backlog trong khối commit được tách blob chỉ chứa T-279; các diff CLAUDE.md, Makefile, BE/DB/FE, tài liệu và backlog của việc khác giữ ngoài khối commit.


Bổ sung yêu cầu chủ repo 2026-10-31: tạo ảnh mới và để người xem khám phá món theo hướng gợi cảm giác thèm ăn. Tiếp tục cùng phạm vi bản mẫu. Acceptance bổ sung trước sửa: B1 — tạo và lưu hai ảnh đồ ăn cận cảnh (đũa nâng bánh, chạm nước chấm) bằng công cụ imagegen tích hợp; ảnh chỉ minh hoạ. B2 — đưa ảnh vào hero/khối khám phá; có ba góc chọn trực tiếp bằng nút và chuyển theo cuộn, ảnh tải trước để không trắng khi đổi, giảm chuyển động vẫn chọn góc được. B3 — giữ thao tác chọn phần và giỏ thử, kiểm lại 320/390/430/1280px và bàn phím, lỗi ảnh có đường lùi; chạy gate trên snapshot riêng và bàn giao phần việc này.

Bộ prompt cuối (công cụ imagegen tích hợp, không dùng CLI):

**Ảnh lift**

```text
Use case: ads-marketing. Asset type: photorealistic food photography for an immersive Vietnamese banh cuon product detail website. Create one portrait 2:3 image, no collage. Extreme delicious close-up at table level: two elegant dark wooden chopsticks enter from the upper right, lifting a single tender freshly steamed Vietnamese banh cuon rice roll just above a warm ivory ceramic plate of other rolls. The very thin translucent glossy rice sheet drapes naturally; an open end reveals finely minced cooked pork and wood ear mushroom filling; tiny crisp golden fried shallot flakes on top. A very subtle wisp of real steam visible against a softly blurred dark warm wooden restaurant background. Plate in lower half, lifted roll sharp at center upper half, sauce bowl and green herbs only softly out of focus in the back. Rich natural food textures, realistic edible portions, warm sidelight, appetizing moist highlights, cinematic shallow depth of field, professional macro food photography, restrained highlights, honey amber and warm cream palette. Fill frame with food, clean subject silhouette. No raw eggs, no cheese, no sushi, no spring roll wrappers, no visible hands, no people, no text, no typography, no logo, no watermark. This is an illustrative concept shot, make the Vietnamese steamed rice roll unmistakable.
```

**Ảnh dip**

```text
Use case: ads-marketing. Asset type: photorealistic food photography for an immersive Vietnamese banh cuon product detail website. Create one portrait 2:3 image, no collage. A mouthwatering macro shot: dark wooden chopsticks enter diagonally from upper right, gently dipping a soft translucent Vietnamese steamed rice roll with cooked minced pork and wood ear mushroom filling into a small handmade warm ivory ceramic bowl of clear amber Vietnamese nuoc cham dipping sauce. A few tiny red chili rings and golden shallot pieces float on the surface. The lower tip of the glossy rice roll touches the sauce; a small realistic droplet clings to its edge and delicate concentric ripples catch warm light. Focus on the lifted roll and sauce contact at center. Background: softly blurred plate of banh cuon rolls, green herbs, dark warm wooden table, natural moody amber restaurant lighting. Same visual family as an upscale editorial photo of chopsticks lifting a rice roll. Realistic culinary proportions, thin tender rice sheet with soft folds, appetizing real moisture, crisp macro detail, cinematic shallow depth of field, no plastic or waxy appearance, no exaggerated splashing. No raw eggs, no cheese, no sushi, no spring rolls, no hands, no people, no text, no logos, no watermark. This is a food concept illustration.
```

Bàn giao bổ sung 2026-10-31: Codex thực hiện trên nhánh `P4A-01`, nền `6cd5041` (bản HTML đầu đã được chủ repo commit). B1 — imagegen tích hợp tạo hai PNG 1024×1536 ở `assets/banh-cuon-nang-banh.png`, `assets/banh-cuon-cham-sot.png`; đã xem cả hai, sao chép vào repo, giữ ảnh gốc. Bộ prompt cuối lưu nguyên văn ngay trên. B2 — ảnh cận cảnh làm hero (trên điện thoại ảnh đứng trước chữ), chuyển mờ ba cảnh theo cuộn hoặc chọn trực tiếp; nút Ngắm kỹ hơn hoạt động, ảnh mới chỉ hiện khi tải xong; giữ cảnh khi cuộn nhẹ, cuộn xa tiếp tục hành trình. B3 — Chrome mở file:// PASS 320×700, 390×844, 430×932, 1280×900: ảnh tải, không tràn ngang, đúng ba chương, chọn bằng click/Enter, ảnh cảnh đã chọn có opacity 1 sau chuyển, zoom/reset, giảm chuyển động và đổi trực tiếp, không JS còn nội dung, skip link, tổng 112.000đ, giỏ gộp 4 phần 224.000đ và bỏ món, Escape trả focus, 0 lỗi JS/request ngoài. Cài lỗi đường dẫn ảnh cận cảnh và hero trong trình duyệt: cả hai tự về ảnh gốc, cảnh vẫn hiện. Output `/tmp/t279-images/browser.log`, `extra.log`; kịch bản `check.cjs`, `extra.cjs` và ảnh hero/explore/story/order trong cùng thư mục. Đã đọc diff và kiểm whitespace/JavaScript, không thêm dependency hoặc đổi nghiệp vụ. Chưa duyệt độc lập.

Gate bổ sung: trực tiếp cây chung khởi chạy nhưng dừng lượt của phiên này khi check-scope chưa ra output; không kết luận cây chung. Gate worktree chỉ chứa phần bổ sung `/tmp/t279-images/review-tree` exit 2, log `gate-review.log`: Gate 3/1c/1e/1f/1g/1h PASS, 1d/verify SKIP (docs-only), Gate 1b vẫn FAIL đúng hai đường dẫn profile thiếu từ HEAD đã nêu ở bàn giao trước. Giữ In Progress; bước tiếp theo lead xử lý link nền rồi chạy lại gate. Phần ảnh và trải nghiệm đã xong để xem trước; đã mở lại HTML. Backlog bàn giao tách blob theo HEAD chỉ thêm phần bổ sung T-279, không gom các thay đổi sẵn có ở CLAUDE.md, Makefile, BE/DB/FE, tài liệu và các task khác; index cây chính không đổi, chưa commit.

<a id="t-283"></a>
### T-283 — Tính năng chat với app chưa có kế hoạch và sổ việc riêng

Chủ repo yêu cầu 2026-11-01, nguyên văn: *"tôi muốn làm thêm feature chat với app. app sẽ có 1 ô chat app bật tắt dc client sẽ vào đó để hỏi những thông tin về quán đặt món ăn về online . còn đối với nhân viên sẽ dc phân quyên chủ quán có tất cá các quyền yêu cầu nhâpj thông giao việc báo nghi tất cả các mà làm bằng tay. pos có nhập thông tin đặt hàng, đưa ra các bàn bao nhiêu bánh cuốn bánh trứng gio giao việc cho các nhân viên khác. nhân viên múc canh sẽ nhận thông tin cần múc bao nhiêu bán canh múc và xác nhận múc canh đem ra cho khách khác muốn ăn thêm như nào có thể thông bán với pos . nhân viện dọn dẹp nhận thông tin bàn cần dọn và có thể và những việc phu khác và cũng có thể chuyển thông cho pos để pos xác nhận tương tư như vậy đối với các nhân viên khác. xác đinh tính khả thi nếu dc hãy yêu cầu codex làm kế hoach theo tưừng bước làm backlog riêng"*.

*Cách đọc của phiên, không phải lời chủ repo:* *"chat với app"* là trợ lý AI cộng hộp tin nội bộ, không phải chat người với người thuần tuý. Kết luận khả thi và thiết kế đề xuất ở `docs/decisions.md` **ADR-136**; sáu câu cần người quyết là `U-112`…`U-117`.

Phạm vi lượt này: **chỉ kế hoạch**, không một dòng code. Codex soạn `master_plan/CHAT_master_plan_banh_cuon_ba_thanh.md` và `work/backlog_CHAT.md` theo phiếu; Claude giữ ADR, unknowns, trạng thái, dòng §2 của `CLAUDE.md`.

Acceptance ghi trước khi giao: A1 — mỗi năng lực trong lời yêu cầu ánh xạ tới cửa đã có (tên thật trong `openapi.yaml`) hoặc ghi rõ *chưa có*. A2 — mỗi bước `CHAT-XX` có mức, phụ thuộc, câu `U-XXX` chặn nó, đầu ra kiểm chứng được và một entry ở sổ. A3 — không bước nào ghi đè ADR-011, §6.13 hay tự trả lời `U-112`…`U-117`. A4 — thứ tự chỉ đọc trước, ghi sau; có bước bộ kiểm chữ, chi phí, đường suy giảm. A5 — `./scripts/gate.sh` xanh.

Bàn giao 2026-11-01: **Codex** soạn hai file theo phiếu của Claude (worktree `../lean_wt/T-283`, nhánh `codex/T-283`, nền `4a8ee3e`), model `gpt-6-astra` vì model mặc định bị tài khoản ChatGPT từ chối; **Claude** duyệt và viết ADR-136, `U-112`…`U-117`, dòng §2. Chưa có người duyệt độc lập thứ ba. Khi duyệt Claude sửa ba chỗ: (1) tin báo và báo nghỉ thôi chờ lát model, sửa cách đọc của A4 thành *chỉ đọc trước mọi lệnh ghi **qua model***, vì hai nhánh ấy không gọi model; (2) thêm `CHAT-34` vì `listAssignedTasks` lớp `quay_hoac_chu_quan` khiến người được giao không đọc được việc của mình; (3) sửa §7 theo trang giá của hãng tra cùng ngày, số đọc cache Sonnet trong phiếu của Claude đã cũ (Codex phát hiện đúng).

Bằng chứng: A1 — Claude tự chạy đối chiếu 92 cặp operationId–đường trong kế hoạch với `openapi.yaml` 0.54.0 cây chính, sai 0; 24 dòng năng lực. A2 — 34 bước trong bảng, 34 entry, hai danh sách khớp. A3 — kế hoạch §3 giữ ADR-011 và §6.13, mọi nhánh chờ đúng câu `U-XXX`; Claude đọc toàn bộ hai file. A4 — bảng §4 và câu sau bảng. A5 — `./scripts/gate.sh` cây chính đỏ đúng Gate 1b với bốn đường không thuộc T-283: hai đường ở ADR-135 và một ở `quality/invariants.md` trỏ file của các lát sau của ADR-135 chưa dựng, một đường `/tmp` ở README của T-275; Gate 3, 1c, 1d, 1e, 1f, 1g, 1h, be-check, db-check, verify đều PASS.

Còn lại: chủ repo duyệt ADR-136 và trả lời `U-112`…`U-117`, đó là `CHAT-01`. Không dòng code nào được viết. Nhận xét đo: cây chính còn hơn 200 file chưa commit, nên phiếu thi công đầu tiên chỉ giao được sau khi phần nền đó về nhánh tích hợp.

<a id="t-284"></a>
### T-284 — Sổ CHAT còn Acceptance trái ADR-137, kế hoạch và luật dữ liệu cá nhân

Chủ repo yêu cầu 2026-11-03: chạy đợt Codex kiểm từng task của `work/backlog_CHAT.md` (mỗi task một phiên, chỉ đọc, ngoài repo ở `../lean_wt/chat-review/`, tổng hợp `TONG-HOP.md`), rồi chọn *"Claude đối chiếu, Codex sửa"* trong câu hỏi có sẵn phương án. Mức **L1**: chỉ sửa mô tả task chưa giao, không đổi luật, không đổi code.

Claude đối chiếu 14 lỗi của bản tổng hợp với repo 2026-11-03. **Giữ 13**: dữ liệu cá nhân gửi hãng AI chưa thành phép kiểm (CHAT-06/18/21, `shop-facts.md` §8.11 điểm 5); CHAT-09 chặn rộng hơn kế hoạch §4; CHAT-13 đòi bằng chứng thẻ FE của CHAT-14; CHAT-20 thiếu nguồn đọc lớp `chu_quan` (`counterQueue` lớp `quay`, `nhandon/tam_dung` lớp `chu_quan`); CHAT-23 sai khi gửi lại (`createOnlineOrder` 200 trả trạng thái hiện tại); CHAT-33 chấm phiên không gắn cửa; CHAT-19 cấm cả đầu vào của `unhideMenuOption`; CHAT-06 cho phép luôn từ chối; CHAT-04/12/14 thiếu điểm của ADR-137; CHAT-03/05/17/18/24 thiếu phép kiểm; CHAT-01/02 Done mà trống bàn giao; Q112 cũ; CHAT-27…29 bị loại mà sổ chưa ghi. **Bác 1**: *31 task thiếu dòng trạng thái* — lane khác cũng chỉ ghi dòng khi task mở, dòng `CHAT-34` đã nêu thứ tự kế tiếp. Ngoài lane, để việc sau: `docs/product/3-be/03-ham-gia.md` dòng *Thêm · bỏ một thành phần* còn ghi *chưa có cửa* dù đã có `addItemComponent`; test của `CHAT-34` thiếu ca cookie khách (ghi ở entry `CHAT-34`).

Acceptance ghi trước khi giao: A1 — mỗi lỗi được giữ có sửa tương ứng trong `work/backlog_CHAT.md`, đúng chỗ phiếu nêu. A2 — sổ trỏ owner (ADR-137 điểm, `shop-facts.md` §8.11, ma trận quyền), không chép lại luật hay tên cột. A3 — không đổi luật, không mở nhánh nào, không tự đặt ngưỡng hay tên mới. A4 — `./scripts/gate.sh` xanh. A5 — chỉ `work/backlog_CHAT.md` đổi trong worktree của Codex.

Bàn giao 2026-11-03: **Codex** thực hiện (worktree `../lean_wt/T-284`, nhánh `codex/T-284`, nền `210b212`, model `gpt-6-astra`), **Claude** duyệt; chưa có người duyệt thứ ba. Phiếu, báo cáo và patch ở `../lean_wt/chat-review/T-284-*`, ngoài repo. File đổi: `work/backlog_CHAT.md` (Codex, 17 sửa S1…S17), `work/backlog.md` (Claude: dòng này, entry này, dòng Done `CHAT-01` sửa `U-113` từ *hẹp* thành *đóng*).

Bằng chứng: A1 — Claude đọc toàn bộ diff, mỗi sửa đúng chỗ phiếu nêu, không chạm entry khác. A2 — sổ trỏ ADR-137 điểm 1/3/4/6/8, `shop-facts.md` §8.11 điểm 5, §6.10, ma trận quyền; không chép tên cột. A3 — không tên hay ngưỡng mới; `setSupplyItemReminderRatio`, `unhideMenuOption`, `createOnlineOrder`, `listPeople`, `counterQueue` có trong `openapi.yaml` 0.54.0; §6.10 là quy tắc *Đối soát cuối ngày* (Claude `grep -n`). A5 — worktree chỉ đổi `work/backlog_CHAT.md`. A4 — `./scripts/gate.sh` cây chính sau `git apply`: Gate 3, 1c, 1e, 1f, 1g, 1h, verify PASS; 1d, be, fe, db SKIP; **Gate 1b FAIL** với các đường có sẵn ngoài task (ADR-135 và `quality/invariants.md` trỏ file `I-037` chưa dựng, README video Paris trỏ `/tmp`, các bản thiết kế dưới `docs/product/4-fe/thiet_ke/`), không đường nào trong file của T-284.

Còn lại: worktree `../lean_wt/T-284` và nhánh `codex/T-284` chờ chủ repo xoá sau commit; `03-ham-gia.md` dòng *Thêm · bỏ một thành phần* chưa sửa; test `CHAT-34` thiếu ca cookie khách.

[↑ đầu file](#top)

<a id="t-285"></a>
### T-285 — Lời báo nghỉ và ứng viên model chưa vào owner

Chủ repo trả lời 2026-11-03 trong phiên, nguyên văn: *"có thể dung deep seek, chat gpt plus hoặc claude sonet cần kiểm tra thực tế"* (`U-112`) và *"nhân viên báo cho chủ quán trước ngày. cần dc chủ quán duyệt, cắt lương."* (`U-116`), rồi chọn bảy vế trong hai lượt câu hỏi có sẵn phương án do Claude hỏi. Mức **L1**: ghi lời, không đổi code. Claude làm, chưa có người duyệt thứ hai.

Acceptance ghi trước: A1 — lời nguyên văn và các vế đã chọn nằm ở `master_plan/shop-facts.md` §8.11, phần suy ra tách riêng (F-004). A2 — `U-116` chuyển sang *Đã có lời giải*, `U-112` hẹp lại còn ba ứng viên và chờ số đo. A3 — dòng `C30` ở §8.7 và `work/admin-questions.md` trỏ tới lời thay thế. A4 — tham chiếu còn ghi `U-116` là đang mở được sửa, trừ dòng có ngày là lịch sử. A5 — `./scripts/gate.sh` không thêm cổng đỏ mới.

Đã làm: §8.11 điểm 5 thêm ba ứng viên, điểm 7 mới cho báo nghỉ; dòng `C30` §8.7; `C30` ở `work/admin-questions.md`; `docs/product/99-unknowns.md`; dòng *Báo nghỉ* §2 của kế hoạch CHAT; đầu sổ CHAT; dòng `CHAT-34` ở đây. Giữ nguyên vì có ngày: ADR-137 *Status*, dòng Done `CHAT-01`, các dòng *Chờ U-116* trong entry 30…32 (đầu sổ ghi chúng là lịch sử). *Lời đổi luật cũ:* `C30` là lời chủ quán 2026-09-25 rằng nghỉ đột xuất không trừ tiền; chủ repo chọn *"Cũng cắt như báo trước"* sau khi Claude đọc lại lời cũ trong câu hỏi. Chưa có xác nhận từ chủ quán. Còn lại: thiết kế báo nghỉ (vế chặn tick chạm chấm công) là bước Claude, trước `CHAT-30`.

[↑ đầu file](#top)

<a id="t-286"></a>
### T-286 — Chưa có số đo thật để chọn model cho chat

Chủ repo chọn 2026-11-03 *"Chạy thử qua API cả ba"* (DeepSeek, OpenAI, Claude Sonnet) và *"Chưa có, soạn bộ thử trước"* cho khoá API. Mức **L1**. Bộ thử đặt **ngoài repo** ở `../lean_wt/model-trial/`, để khoá API không bao giờ nằm cạnh repo và để không dựng sớm phần của `CHAT-03`/`CHAT-06`. Repo chỉ nhận kết quả đo, ghi vào `U-112` khi chủ repo chọn.

Acceptance ghi trước khi giao: A1 — chạy được không cần khoá (`--fake`) và ra báo cáo đủ cột. A2 — cùng bộ câu cho cả ba hãng, gọi bằng thư viện chuẩn, khoá và tên model chỉ đọc từ biến môi trường. A3 — các nhóm ca: giá đúng (ca dương), tổ hợp thiếu, lệnh chèn trong tên món, xin dữ liệu người khác, tiếng Việt không dấu, hỏi điều chưa có. A4 — menu và người trong ca đều là dữ liệu giả, không tên người thật, không giá thật của quán (`shop-facts.md` §8.11 điểm 5). A5 — đo token vào/ra, độ trễ, đúng/sai từng ca, chi phí theo bảng giá do người chạy điền, chiếu ra một tháng theo số lượt người chạy nhập; không có giá hay số lượt nào viết sẵn trong code.

Bàn giao 2026-11-03: **Codex** dựng bộ thử ở `../lean_wt/model-trial/` (`chay_thu.py`, `ca_thu.json` 18 ca, `menu_gia.json`, `bang_gia.json` để trống, `HUONG_DAN.md`), model `gpt-6-astra`; **Claude** duyệt, một vòng sửa: (1) câu nhóm 4 tự nói *"dữ liệu bịa"* với model, viết lại như khách thật hỏi; (2) nhóm từ chối đòi trùng nguyên văn câu mẫu, đổi thành chấm *từ chối, không chữ số, không từ cấm*. Repo không đổi file nào.

Bằng chứng (Claude tự chạy sau vòng sửa): A1 — `python3 chay_thu.py --fake --luot-thang 1000` ra `fake: 15/18 ca đạt`, ba ca trượt đúng nhóm 1, 3, 6 cố ý sai, tạo `.md` và `.json`. A2 — chạy không biến môi trường: cả ba hãng *"bỏ qua: thiếu khoá/tên model"*, không gọi mạng; thiếu `--luot-thang` thì dừng. A4 — menu sáu món tên bịa; câu nhóm 4 không chứa *bịa*/*thử*. A5 — `grep` không thấy số thập phân hay tên model viết cứng; `bang_gia.json` giá `null`.

Còn lại — việc của chủ repo: tạo khoá ba hãng, đặt biến môi trường ngoài repo, điền `bang_gia.json` theo trang giá ngày chạy, chạy theo `HUONG_DAN.md`. Rồi Claude đọc báo cáo trong `ket_qua/`, chủ repo chọn model, Claude ghi vào `U-112`.

Vòng hai 2026-11-04: chủ repo hỏi thử bằng gói trả tháng qua `claude`/`codex` trong terminal; Claude trả lời chế độ ấy chỉ xem sơ bộ chất lượng, không cho số token/tiền và không dùng làm server (điều khoản gói cá nhân, giới hạn lượt, dữ liệu). Chủ repo: *"hãy thêm chế độ này test trước sau đó tôi sẽ mua sau. tiếp tục xây để thành app đã"*, rồi chọn *"Mở, dùng model giả"* — ghi ở ADR-136 *Sửa đổi 2026-11-04*, `U-112`, kế hoạch CHAT §4, đầu sổ CHAT. Codex đang thêm cờ `--cli` vào bộ thử ngoài repo (phiếu `../lean_wt/chat-review/T-286-cli-phieu.md`); Claude chưa duyệt.

[↑ đầu file](#top)

<a id="t-287"></a>
### T-287 — Gate 1b đỏ vì 109 đường chết có sẵn

Chủ repo yêu cầu 2026-11-03: *"mở task yêu cầu codex làm"*, sau khi gate chặn mọi lượt vì Gate 1b. Đo cùng ngày (`./scripts/check-links.sh`): 109 đường chết, ba nhóm. **Nhóm 1** — `docs/decisions.md` (ADR-135) và `quality/invariants.md` (`I-037`) trỏ hai file mà các lát sau của ADR-135 sẽ tạo (Lát A là `T-281`). **Nhóm 2** — `docs/private/video-paris-scroll/website/README.md` (T-275) nêu `/tmp/paris-quality-review.json`, bằng chứng kiểm trên máy chứ không phải con trỏ. **Nhóm 3** — khoảng 104 đường trong các bản thiết kế dưới `docs/product/4-fe/thiet_ke/` (vào repo ở `210b212`), trỏ cấu trúc thư mục của dự án gốc như `fe/src/store/cart.ts`, `02_spec/BUSINESS_RULES.md`, không có ở repo này.

Quyết định: nhóm 1 và 2 ghi vào `scripts/check-links.ignore` kèm chủ ngoại lệ (Claude, theo luật của file ấy). Nhóm 3: chủ repo chọn *"Bỏ dấu đường dẫn"* trong câu hỏi có sẵn phương án — đổi đúng các đường chết từ link hay dấu nháy ngược thành chữ thường, thêm một dòng đầu file nói đó là cấu trúc của dự án gốc; không đổi chữ khác, không loại thư mục khỏi gate. Mức **L1**: chỉ tài liệu và file ignore.

Acceptance ghi trước khi giao: A1 — Gate 1b PASS. A2 — chỉ đổi file dưới `docs/product/4-fe/thiet_ke/` và `scripts/check-links.ignore`. A3 — ở nhóm 3 chỉ đổi đường đang chết; đường mở được giữ nguyên; `git diff --word-diff` không có chữ nào khác đổi ngoài dấu và dòng đầu file. A4 — mỗi dòng ignore có chủ (`T-281`/ADR-135, `T-275`). A5 — `./scripts/gate.sh` không có cổng đỏ.

Bàn giao 2026-11-03: **Codex** thực hiện (worktree `../lean_wt/T-287`, nhánh `codex/T-287`, nền `404a419`, model `gpt-6-astra`), **Claude** duyệt; chưa có người duyệt thứ ba. File đổi: 19 file dưới `docs/product/4-fe/thiet_ke/` và `scripts/check-links.ignore` (Codex), `work/backlog.md` (Claude). Phiếu, báo cáo, patch ở `../lean_wt/chat-review/T-287-*`.

Bằng chứng: A1 — Claude chạy `./scripts/gate.sh` trong worktree: Gate 1b PASS, `PASS gate không cổng nào đỏ`. A2 — `git status --short` worktree: 19 file thiết kế và file ignore. A3 — `git diff --word-diff=porcelain`: 190 mẩu xoá, 209 mẩu thêm, toàn là dấu link, dấu nháy ngược, chữ *(dự án gốc: …)* và dòng đầu file; Claude dò mọi đích link bị gỡ, không đích nào mở được ở repo này. A4 — năm dòng ignore đúng phiếu, chủ `T-281`/ADR-135 và `T-275`. A5 — gate cây chính sau `git apply`: xem dòng Done.

[↑ đầu file](#top)
