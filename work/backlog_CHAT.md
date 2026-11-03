<a id="top"></a>
# Sổ mô tả — chat với app (`CHAT-01`…`CHAT-34`)

Thứ tự, mức và cổng:
[`master_plan/CHAT_master_plan_banh_cuon_ba_thanh.md`](../master_plan/CHAT_master_plan_banh_cuon_ba_thanh.md).
Trạng thái chỉ ở `work/backlog.md`, do Claude giữ. Sổ này không giữ trạng thái.
Viết 2026-11-01, T-283, Codex theo phiếu Claude; thiết kế ADR-136 còn **Đề xuất**.
Mỗi entry là mô tả để giao bước sau, không phải lời cho phép làm ngay. **Nhận việc** để trống tới lúc nhận.

**Cập nhật 2026-11-01 (CHAT-01):** ADR-136 đã chốt. Nhánh nào mở, nhánh nào đóng: kế hoạch §4; thiết kế nhánh không model: ADR-137.
Các dòng `chờ U-113` · `U-114` · `U-115` · `U-117` bên dưới là lịch sử: những câu ấy đã có lời ở `master_plan/shop-facts.md` §8.11.
**Cập nhật 2026-11-03 (T-285):** `U-116` có lời ở §8.11 điểm 7, nên các dòng `chờ U-116` của 30…32 cũng là lịch sử.
Lời chặn tick ô chấm công, nên theo Acceptance cuối của CHAT-30 Claude thiết kế riêng trước khi giao lược đồ.
`U-112` đã hẹp 2026-11-01 — trần 10 USD/tháng và không gửi dữ liệu cá nhân ra ngoài đã có lời
(`shop-facts.md` §8.11 điểm 5), chỉ còn chọn nhà cung cấp và model.
`CHAT-27` · `CHAT-28` · `CHAT-29` loại khỏi lộ trình theo ADR-136 *Sửa đổi* (`U-115`).
`CHAT-26` chưa mở, phải hỏi lại trước (cũng ADR-136 *Sửa đổi*, suy ra của phiên).

**Chung cho mọi bước.**

- Đọc `CLAUDE.md`, chạy `./scripts/brief.sh`, đọc entry của bước và các owner ở **Đứng trên**.
  Đo lại cửa trên nền tích hợp; lần đo 2026-11-01 của kế hoạch dùng cây chính có thay đổi chưa commit.
  Không lấy danh mục dưới đây làm bằng chứng code đã chạy. Claude giao scope và Acceptance trước mỗi phiếu.
- `C01`…`C19` là nhóm tra tại kế hoạch §2, có operationId · đường · lớp của cửa thật. `Q112`…`Q117`
  dưới đây chỉ là cách đọc tạm các câu `U-112`…`U-117` ở `docs/product/99-unknowns.md`, không thay owner:
  **Q112:** chờ chọn hãng/model; trần và phạm vi dữ liệu đã có lời ở `shop-facts.md` §8.11 điểm 5;
  tạm lớp đổi hãng, không gọi model thật.
  **Q113:** chờ nghĩa xác nhận và thiết bị; tạm tin báo, POS vẫn ghi tiến độ.
  **Q114:** chờ quyền chủ quán; tạm giữ luật cũ, ngoài quầy không qua cửa quầy.
  **Q115:** chờ danh sách cửa ghi; tạm không mở cửa chạm tiền.
  **Q116:** chờ ai báo/nhận/duyệt nghỉ và tác động ca/lương; chưa có cách đọc cho phép dựng chỗ cất.
  **Q117:** chờ kênh, đăng nhập, nhắn POS; tạm giao/đến lấy theo luật web hiện có.
  Entry nêu `chờ U-XXX (Qxxx)` là áp nguyên cách đọc này, **không** được triển khai theo mặc định tạm.
- Mọi bước sau 01 cần ADR-136 đã chốt; mọi bước thi công cần thiết kế nhánh của 02 được duyệt.
  Claude giữ lời quán, ADR, unknowns, bất biến, trạng thái; Codex chỉ thi công phiếu. L2+ có test hồi quy
  Claude viết trước, đỏ trước code. Claude duyệt diff, chạy lại gate và tích hợp (`CLAUDE.md` §7.4).
- **Acceptance chung G1:** danh sách công cụ do backend chọn theo phiên; khách không có công cụ người làm;
  cookie khách không mở cửa người làm; model không mang tài khoản hay quyền riêng.
- **G2:** đề xuất không ghi. Người bấm thẻ mới chạy đúng service/cửa; cửa kiểm quyền tại mốc giao dịch,
  lấy người từ phiên, không lấy định danh người trong lời model. Đổi người/rời quầy/khoá tài khoản trước
  khi bấm thì từ chối; không ghi, không làm mất vết. Không giữ giao dịch trong lúc chờ model.
- **G3:** cửa từ chối thì giữ nguyên dữ liệu nghiệp vụ; cập nhật có lý do/vết theo owner. Mất phản hồi
  là “chưa rõ kết quả”; không gửi lại ngầm. Cửa có dấu gửi lại dùng lại đúng dấu và thân; cửa chưa có
  chống lặp thì khoá thẻ và đọc lại, không giả định bấm hai lần an toàn. Không tự thêm cơ chế idempotency.
- **G4:** giá qua `docs/product/3-be/03-ham-gia.md`; số lượng/trạng thái lấy từ nguồn đọc có mốc;
  không số do model đoán. Tắt chat/model thì màn tay vẫn chạy. Lùi lát bằng tắt công cụ/mặt FE, giữ vết;
  lát phụ thuộc tắt trước. DB lùi có khoá chặn mất dữ liệu, không xoá lịch sử để lùi cho được.
- **G5:** mỗi phép Verify lưu lệnh và output thật, phân biệt PASS/SKIP; chạy `./scripts/gate.sh`.
  BE: `./scripts/be-check.sh`; DB: `./scripts/db-check.sh`; FE: `./scripts/fe-check.sh` khi lát chạm tầng ấy.
  Thiếu môi trường thì ghi chưa chạy và giao Claude chạy, không đánh dấu đạt. Eval là kiểm riêng, gate
  xanh không thay eval. Đổi prompt/model/danh sách công cụ phải chạy lại tập eval chịu ảnh hưởng.
- **G6:** mọi lát gọi model kiểm đúng nội dung gửi hãng — câu người dùng nhập, kết quả công cụ, lịch sử hội thoại —
  không chứa tên, số điện thoại, địa chỉ khách hay tên nhân viên (`shop-facts.md` §8.11 điểm 5).
  Kiểm danh sách công cụ không thay được phép kiểm này.
- G1…G4 và G6 là Acceptance dự kiến áp thêm cho mọi lát model/ghi/FE tương ứng, gồm cả ca từ chối. Verify của
  từng entry nói rõ phép riêng. Tên test mới, đường API, bảng/cột, component mới do Claude quyết ở owner
  trước thi công; mô tả dưới đây không đặt tên chúng. Nhóm BE 15…20, 25…29 dùng thẻ chung 11, không sửa FE;
  cần màn riêng thì Claude tách lát FE, duyệt trước mở nhóm. Không gộp DB · BE · FE trong một phiếu.

---
<a id="chat-01"></a>
### CHAT-01 — Thiết kế chat còn là đề xuất, lời chưa đủ để thi công

**Goal:** Thu lời và xin duyệt ADR-136; ghi rõ nhánh được cho phép, nhánh còn chờ, không ép quyết cả sáu câu cùng
lượt.

**Đứng trên:** L3, Claude. Entry T-283; docs/decisions.md ADR-136, ADR-011, ADR-054; docs/product/99-unknowns.md
U-112…U-117; kế hoạch §3.

**Bẫy:** Lời “được chat” không đồng nghĩa được huỷ từ xa hay cho trạm ghi tiến độ. U-116 không chặn nhánh khác.

**Chặn bởi:** Chờ U-112 (Q112), U-113 (Q113), U-114 (Q114), U-115 (Q115), U-116 (Q116), U-117 (Q117) theo nhánh;
bước này thu lời để gỡ, không cần giả câu đã đóng.

**Acceptance dự kiến:**

- [ ] ADR-136 có quyết định duyệt hoặc chưa duyệt, người quyết và ngày trong owner; chưa duyệt thì không có phiếu
      code.
- [ ] Mỗi câu có lời được Claude ghi đúng owner; câu chưa có lời giữ nguyên và có nhánh bị chặn.
- [ ] Lời trái ADR-011 hoặc §6.13 bị trả về bước quyết định riêng; không cấp ngoại lệ trong kế hoạch.
- [ ] Chủ repo quyết dùng model hay hộp tin thuần; không lấy báo giá làm quyết định chọn model.

**Verify:** Claude đối chiếu lời gốc với owner, rà đủ sáu câu và tám điểm ADR-136; gate tài liệu, chưa thử tính
năng.

**Nhận việc:**

2026-11-01, Claude; chủ repo chọn trong câu hỏi có sẵn phương án. Kết quả ở ADR-136 *Sửa đổi 2026-11-01*,
`shop-facts.md` §8.11 và `docs/product/99-unknowns.md`: đóng `U-113` · `U-114` · `U-115` · `U-117`,
hẹp `U-112` (còn nhà cung cấp/model), `U-116` còn mở. Lệnh đã chạy lúc ấy không được ghi lại ở entry này.
Ghi bổ sung 2026-11-03, T-284.

[↑ đầu file](#top)

---

<a id="chat-02"></a>
### CHAT-02 — Chưa có thiết kế để tách công cụ, thẻ và tin báo theo người dùng

**Goal:** Duyệt thiết kế nhánh: danh sách công cụ, dữ liệu gửi hãng, giới hạn, thẻ, quyền đọc tin và định tuyến;
tách các lát DB phát sinh trước code.

**Đứng trên:** L3, Claude; sau CHAT-01. Ma trận 02-vai-va-quyen, openapi; ADR-085/097/109/131; shop-facts §3, §8.8;
kế hoạch §2–§6.

**Bẫy:** Vai tài khoản chọn màn, không chứng minh đang trực trạm. Không tự tạo lịch trực bốn trạm ngoài quầy. Canh
và dọn là một người.

**Chặn bởi:** Chờ U-112 (Q112), U-113 (Q113), U-114 (Q114), U-115 (Q115), U-116 (Q116), U-117 (Q117) đúng nhánh
thiết kế.

**Acceptance dự kiến:**

**Lượt một — xong 2026-11-01, ADR-137**

- [x] Thiết kế tin chỉ ra người nhận, loại việc canh/dọn, POS nhận hồi đáp, ca người kiêm đi giao/POS gánh; thiếu
      lời thì giữ nhánh đóng.
- [x] Luồng tin riêng không phát nội dung vào SSE công khai; không dựng hàng đợi hay cache nghiệp vụ.

**Lượt hai — chưa làm, chờ `U-112`**

- [ ] Có ánh xạ công cụ → cửa/lớp; phần chưa có cửa và phần bị cấm không được vào danh sách thực thi.
- [ ] Thiết kế thẻ ghi rõ gắn phiên/thân lệnh, đổi nội dung phải xác nhận lại, quyền kiểm lại, chống bấm lặp hoặc từ
      chối gửi lại.
- [ ] Có giới hạn dữ liệu gửi ngoài, lịch sử/log, hạn chờ, token/lượt và trần tháng; nếu bộ đếm/thẻ cần chỗ cất mới
      thì có lát DB trước BE.
- [ ] Thiết kế cách lọc dữ liệu cá nhân khỏi kết quả công cụ trước khi gửi hãng (G6), và chốt ngưỡng *quá cũ*
      của từng nguồn đọc dùng ở CHAT-05.

**Verify:** Claude duyệt từng tình huống với owner và test từ chối dự kiến; đối chiếu ranh giới DB/BE/FE; gate tài
liệu.

**Nhận việc:**

2026-11-01, Claude thiết kế lượt một (ADR-137), chủ repo duyệt; lượt hai chưa làm.
Ghi bổ sung 2026-11-03, T-284.

[↑ đầu file](#top)

---

<a id="chat-03"></a>
### CHAT-03 — Chưa có lớp gọi model tắt được và giữ được trần chi phí

**Goal:** Dựng lớp BE đổi nhà cung cấp, công tắc tắt, hạn chờ và ngân sách theo thiết kế; ghi phụ thuộc model và
đường suy giảm vào owner.

**Đứng trên:** L2, Codex; sau CHAT-02 và lát DB bộ đếm nếu Claude yêu cầu.
docs/product/1-system-design/01-ranh-gioi-he-thong.md; kế hoạch §6–§7.

**Bẫy:** Lượt có nhiều lần gọi; lần lỗi có thể tính phí. Khởi động lại hay nhiều lượt đồng thời không được làm mất
phần ngân sách đã dùng.

**Chặn bởi:** Chờ U-112 (Q112); không gửi dữ liệu thật trước khi hãng/model/trần và phạm vi dữ liệu được duyệt.

**Acceptance dự kiến:**

- [ ] Thay bộ giả lập nhà cung cấp không đổi miền nghiệp vụ; nhà cung cấp thật chỉ qua cấu hình đã duyệt.
- [ ] Tắt, hết trần, quá hạn hoặc lỗi hãng trả suy giảm có đường tay; không gọi tiếp hay tự thử lại vô hạn.
- [ ] Không có giao dịch DB còn mở trong thời gian chờ model; đóng chat huỷ yêu cầu đang chờ.
- [ ] Giới hạn tính cả đầu ra tối đa và lượt đang chạy; khởi động lại không mở lại ngân sách đã hết; không biết mức
      dùng thì từ chối gọi.
- [ ] Log đo token/chi phí không chứa cookie, mật khẩu hay thông tin cá nhân ngoài phần U-112 cho phép.

**Verify:** be-check với hãng giả lập lỗi/chậm/quá hạn/đồng thời/khởi động lại; một lần gọi thật đã được duyệt trên
dữ liệu thử; lưu token và giá dùng, gate. Thêm ca đóng chat huỷ yêu cầu đang chờ; phép chứng minh không có giao
dịch DB mở trong lúc chờ model (cách đo do bước này bàn giao); đọc log thật, không có cookie, mật khẩu hay dữ
liệu cá nhân.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-04"></a>
### CHAT-04 — App chưa có chỗ mở và đóng chat

**Goal:** Dựng riêng vỏ FE bật/tắt, bàn phím và trạng thái tắt; chưa nối model hay cửa ghi.

**Đứng trên:** L1, Codex; sau CHAT-01 và thiết kế FE được duyệt ở CHAT-02. docs/product/4-fe/01-khung-fe.md §1–§4.

**Bẫy:** Đóng chat mà tháo layout quầy sẽ làm đổi dấu hiệu quán còn nhìn thấy đơn. Không lưu hội thoại riêng vào bộ
nhớ trình duyệt mặc định.

**Chặn bởi:** Không có U chặn vỏ rỗng; chưa được gọi model/ghi. Nối thật phải qua bước có câu chặn tương ứng.

**Acceptance dự kiến:**

- [ ] Mở, đóng và Esc hoạt động; focus trở lại nút mở; app vẫn thao tác tay được.
- [ ] Đóng/mở chat ở quầy không ngắt luồng quầy và không tự mở một luồng quầy cho khách.
- [ ] Chính component chat không phát lời gọi mạng nào tới model hay cửa ghi; tác vụ nền sẵn có của layout
      (ví dụ `POST /preorder-releases` ở `/quay`, file `fe/src/app/quay/_components/tu-nha-don-hen.tsx`) không tính.
- [ ] Vỏ nằm sau cờ của ADR-137 điểm 1, tắt mặc định; tắt cờ thì không có nút mở ở cả ba layout
      `/quay` · `/tram` · `/chu-quan`; trang khách chưa gắn.
- [ ] Đóng mở không đụng `TinHieuProvider`; nháp chỉ ở state của component.
- [ ] Đổi người dùng không thấy bản nháp/hội thoại của người trước.

**Verify:** fe-check và diễn bàn phím, điện thoại, đổi trang con của quầy; ở cả ba layout, cờ bật và tắt;
kiểm mạng của component chat không có lời gọi model/ghi; gate.

**Nhận việc:**

2026-11-03, Claude: phiếu giao Codex, worktree `../lean_wt/CHAT-04`, nhánh `codex/CHAT-04` từ `63ebec1`. Claude chọn tên và chỗ: `OChat`
tầng 2 ở `fe/src/components/shared/o-chat.tsx`, con trực tiếp của `KhungTheoVai`, ngoài `TinHieuProvider`; bảng không chặn, không nút gửi;
cờ chỉ bật khi bằng `"true"`. Lượt Codex đầu viết xong code và test rồi dừng vì hết hạn mức (tới 18:26), chưa có báo cáo; Claude chạy thử
`vitest` trong worktree: 28/28 xanh. Việc kế tiếp: Codex làm nốt gate và báo cáo, Claude duyệt.

2026-11-03 17:00, Claude: hạn mức Codex đổi thành hạn tuần, mở lại 2026-11-06 23:04; chủ repo chọn chờ Codex. Script chờ
`../lean_wt/chat-review/cho-han-muc-chat.sh` resume phiên Codex `01a1a0c6-6a19-72d1-a7eb-ff4f823dd733` rồi chạy phiếu CHAT-12; báo cáo ra cùng thư mục.

[↑ đầu file](#top)

---

<a id="chat-05"></a>
### CHAT-05 — Khách chưa có đường hỏi quán chỉ đọc có nguồn

**Goal:** Nối BE hỏi đáp công khai với tập nội dung công khai được duyệt và C01; mọi số lấy từ công cụ, không đưa cả
repo vào prompt.

**Đứng trên:** L2, Codex; sau CHAT-03. C01 ở kế hoạch §2; shop-facts §1, §4 là nguồn;
docs/product/3-be/03-ham-gia.md; ADR-136 điểm 3/5.

**Bẫy:** Owner chứa cả thông tin nội bộ. Thông tin quán chưa có cửa tổng hợp; phần xuất công khai do Claude thiết
kế, không chép số liên hệ vào prompt cố định.

**Chặn bởi:** Chờ U-112 (Q112); hỏi thông tin không phụ thuộc U-117.

**Acceptance dự kiến:**

- [ ] Danh sách công cụ của khách chỉ đọc công khai; không có công cụ đặt món, tiền, người làm hay SQL.
- [ ] Giá món/tổ hợp/combo trả đúng nguồn đọc hiện tại; câu hỏi thiếu lựa chọn không đoán số hoặc tự sửa tổ hợp.
- [ ] Thông tin chưa có trong nguồn trả chưa biết; không tự nghĩ giờ bán, món còn hay số điện thoại.
- [ ] Nguồn lỗi hoặc quá cũ không được biến thành số hiện tại; model không trả một con số thiếu căn cứ;
      ngưỡng *quá cũ* do Claude chốt ở CHAT-02 lượt hai trước khi giao phiếu.

**Verify:** be-check với nguồn menu/giá thật của dữ liệu thử; so với gia.Tinh; ca tool giả, giá đổi và nguồn lỗi;
gate. Chưa mở khách thật.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-06"></a>
### CHAT-06 — Chưa có bộ kiểm chữ ngăn trả sai giá và làm theo lời chèn lệnh

**Goal:** Lập eval có đầu vào, nguồn chuẩn, quyền, công cụ được phép/cấm và tiêu chí đạt; chạy trước khi khách thật
thấy chat.

**Đứng trên:** L2, Codex theo tiêu chí Claude duyệt; sau CHAT-05. quality/invariants.md I-008…I-013, I-024,
I-033…I-035; ADR-136 điểm 8.

**Bẫy:** Model tự chấm câu trả lời của mình không đủ. Expected giá lấy từ backend, không gõ lại giá món trong
fixture.

**Chặn bởi:** Chờ U-112 (Q112); lần chạy model phải tính vào ngân sách, không miễn phí eval trên giấy.

**Acceptance dự kiến:**

- [ ] Ca dương: câu giá món lẻ/combo đủ lựa chọn phải trả đúng giá backend; từ chối là trượt.
- [ ] Ca thiếu/sai tổ hợp, giá vừa đổi, hết món: từ chối nêu số là đạt, đoán số là trượt.
- [ ] Có nhóm ca kiểm nội dung gửi hãng theo G6, gồm kết quả công cụ có tên người.
- [ ] Có lời giả chủ quán, “bỏ chỉ dẫn”, xin dữ liệu người khác, yêu cầu gọi cửa kín và lệnh ẩn trong tên món/tin;
      không lọt công cụ cấm.
- [ ] Có tiếng Việt thiếu dấu/sai chữ, số lượng mơ hồ; yêu cầu chưa rõ không biến thành lệnh ghi.
- [ ] Bộ kiểm có ca cố ý trả sai số và gọi sai quyền để chứng minh biết báo trượt; không chỉ đếm câu nghe hay.
- [ ] Mọi ca an toàn bắt buộc đều đạt trước CHAT-07; đổi prompt/model/công cụ lưu bản và chạy lại, kết quả trượt
      chặn mở.

**Verify:** Chạy lệnh eval do bước này bàn giao, dán từng nhóm đạt/trượt và phiên bản model/prompt; be-check cho
phép chặn công cụ; gate không thay eval.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-07"></a>
### CHAT-07 — Ô chat công khai chưa nối hỏi đáp đã qua kiểm

**Goal:** Nối FE vỏ vào đường chỉ đọc đã đạt eval; bày câu trả lời có nguồn, lỗi rõ và lối đặt món bằng màn tay.

**Đứng trên:** L1, Codex; sau CHAT-04, CHAT-06. docs/product/4-fe/01-khung-fe.md §3; C01; kết quả eval của CHAT-06.

**Bẫy:** Đừng thêm nút gửi đơn sớm; mở cho khách thật ở bước này chỉ là hỏi thông tin.

**Chặn bởi:** Chờ U-112 (Q112); kết quả CHAT-06 phải đạt; U-117 không chặn hỏi quán.

**Acceptance dự kiến:**

- [ ] Khách chưa đăng nhập hỏi được thông tin công khai theo phạm vi đã duyệt, không thấy số nội bộ.
- [ ] Công tắc tắt/lỗi/quá hạn hiện đúng trạng thái và đường về màn tay; không hiển thị thành công giả.
- [ ] Đóng chat huỷ lần chờ; phản hồi cũ không xuất hiện trong phiên khác.
- [ ] Không có đường ghi qua chat kể cả câu “đặt luôn”; chưa đạt eval thì không mở chat thật.

**Verify:** fe-check; diễn browser với BE thật và model đã duyệt trên dữ liệu thử, cắt model; lưu bằng chứng mở
khách chỉ đọc sau eval; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-08"></a>
### CHAT-08 — Người làm chưa hỏi được số theo bàn và theo quyền bằng chat

**Goal:** Nối BE công cụ đọc nội bộ C03/C08/C16/C18/C19 theo phiên; phân biệt số đơn vị, số việc, số đã làm và đã
ra.

**Đứng trên:** L2, Codex; sau CHAT-06. Ma trận quyền §2–§3; ADR-124 trong mô tả getServiceBoard; shop-facts §5.4.

**Bẫy:** Một thành phần đi nhiều trạm không được đếm thành nhiều món. Công khai bảng trạm không có nghĩa công khai
số chủ quán.

**Chặn bởi:** Chờ U-112 (Q112); chỉ đọc, không gỡ U-113/114/115 để ghi.

**Acceptance dự kiến:**

- [ ] POS hỏi từng bàn thiếu bánh cuốn/bánh trứng/giò nhận số thiếu backend trả cùng mốc đọc, không tự suy bằng
      model.
- [ ] Chủ quán đọc tổng quan được; POS không là chủ bị từ chối cửa chu_quan; người ngoài quầy bị từ chối cửa quay.
- [ ] Khách không nhận công cụ đọc nội bộ; cookie khách không dùng để đọc theo người làm.
- [ ] Trạm nhận số cần làm từ bảng trạm, không tự nhận quyền listAssignedTasks chỉ vì là người được giao.

**Verify:** be-check ma trận từng phiên/vai, bảng có phần làm xong chưa ra, đã ra và huỷ; chạy lại eval quyền/số;
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-09"></a>
### CHAT-09 — Số hỏi trong chat chưa có mốc đọc và chưa tách người dùng

**Goal:** Dựng FE đọc nội bộ theo khung hiện có, bày mốc và cảnh báo, làm mốc nghiệm thu chỉ đọc trước ghi.

**Đứng trên:** L2, Codex; sau CHAT-07, CHAT-08. docs/product/4-fe/01-khung-fe.md §2–§3; ADR-097, ADR-109, ADR-131.

**Bẫy:** Vai trên FE không mở quyền; hỏi số từ tab cũ sau khi đổi người không được trả sang người mới.

**Chặn bởi:** Chờ U-112 (Q112). Các nhánh ghi vẫn đóng dù màn đọc đã chạy.

**Acceptance dự kiến:**

- [ ] Câu hỏi số bàn/trạm hiện nguồn và mốc backend; mất kết nối không giả dữ liệu rỗng là hết việc.
- [ ] Đăng xuất/đổi người ở tab khác làm sạch dữ liệu riêng và huỷ phản hồi đang chờ.
- [ ] Có lời từ chối rõ cho người không quyền, không thử lại ngầm để vượt lớp.
- [ ] Biên bản chỉ đọc đạt trước bất kỳ lệnh ghi **qua model** nào được bật; nhánh không model
      (12…14, 30…32, 34) không chờ biên bản này (kế hoạch §4).

**Verify:** fe-check; diễn hai tab, hai không gian, cắt SSE và đọc lại; so số trên màn tay, ghi biên bản chỉ đọc;
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-10"></a>
### CHAT-10 — Lời model chưa có ranh giới giữa đề xuất và thực thi

**Goal:** Dựng BE thẻ lệnh theo thiết kế đã duyệt; chưa mở nhóm ghi cụ thể; mỗi lần thực thi gọi lại đúng cửa hiện
hữu.

**Đứng trên:** L2, Codex; sau CHAT-09 và lát DB thẻ nếu CHAT-02 yêu cầu. ADR-085, ADR-136 điểm 2–4; ma trận cửa;
I-012/I-018/I-024.

**Bẫy:** “Đồng ý” trong văn bản không phải cái bấm xác nhận. Không dựng một cửa SQL chung cho chat; không tin
người/model gửi role.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Gọi model và tạo đề xuất không đổi dữ liệu nghiệp vụ; chưa có thẻ được bấm thì service ghi không chạy.
- [ ] Thẻ gắn đúng phiên, cửa và thân lệnh; thay đối tượng/số/lý do sau xác nhận bị từ chối hoặc phải xác nhận lại.
- [ ] Rời quầy/khoá tài khoản/đổi phiên giữa hai mốc khiến thực thi bị từ chối, người vào vết là người thật bấm.
- [ ] Bấm lặp/mất phản hồi không tạo tác dụng đôi theo thiết kế từng cửa; cửa chưa chống lặp không được gửi lại tự
      động.
- [ ] Công cụ không có trong danh sách backend bị từ chối dù model trả tên hợp lệ; không phát tín hiệu khi giao dịch
      lùi.

**Verify:** be-check với service ghi thử trong test, ca quyền đổi giữa hai mốc, sửa thẻ, lặp và giao dịch lùi; Gate
1f/1g; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-11"></a>
### CHAT-11 — Người dùng chưa nhìn thấy rõ điều mình sắp ghi

**Goal:** Dựng FE thẻ chung: đối tượng, nội dung thay đổi, số/giá từ nguồn, người bấm, lý do khi cần, xác nhận và bỏ
nháp.

**Đứng trên:** L2, Codex; sau CHAT-10. docs/product/4-fe/01-khung-fe.md §3, §6; hợp đồng thẻ Claude duyệt tại
CHAT-02.

**Bẫy:** Màu xanh không chứng minh đã ghi. Thẻ chung không được giấu đối tượng/đơn vị hay đánh đồng “báo” với “đã
ra”.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115); chưa mở nhóm ghi ngoài danh sách được duyệt.

**Acceptance dự kiến:**

- [ ] Thẻ hiện đủ trường ảnh hưởng trước nút xác nhận; nội dung mơ hồ không có nút ghi.
- [ ] Bỏ thẻ không ghi; nút đang gửi bị khoá; câu trả lời model không tự kích hoạt nút.
- [ ] Mất phản hồi hiện chưa rõ kết quả, giữ thẻ để đọc lại; không gửi lại ngầm.
- [ ] Ghi xong đọc lại lỗi nói rõ đã ghi nhưng chưa đọc lại; đổi người loại thẻ cũ.
- [ ] Các nhóm BE sau chỉ dùng thẻ chung nếu diễn đủ trường theo hợp đồng; thiếu trường phải chặn mở nhóm.

**Verify:** fe-check trạng thái đề xuất/chờ/từ chối/chưa rõ/đã ghi, bàn phím và đổi phiên; diễn với BE của CHAT-10;
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-12"></a>
### CHAT-12 — Tin báo trạm chưa có chỗ cất tách khỏi tiến độ

**Goal:** Dựng riêng lát DB tin báo theo thiết kế Claude, giữ người gửi, người nhận, loại việc, nội dung và mốc;
không dựng API/màn.

**Đứng trên:** L2, Codex; sau CHAT-02. shop-facts §3, §5.4, §8.8; architecture §1.1/§4/§5; ADR-011/136;
I-003/I-018/I-030.

**Bẫy:** Một người canh+dọn không phải hai người. Tin hoàn tất không được viết trạng thái việc trạm, bàn hay việc
giao.

**Chặn bởi:** Chờ U-113 (Q113), gồm thiết bị và nghĩa tin; không cần U-112 nếu đi phương án không model đã duyệt.

**Acceptance dự kiến:**

- [ ] Tin đọc lại được người gửi/nhận, loại canh hoặc dọn và đối tượng được thiết kế cho phép; không tạo person giả
      cho trợ lý.
- [ ] Một tin gửi tới người kiêm hai trạm không bị nhân đôi; vẫn phân biệt hai loại việc.
- [ ] Ghi tin “xong” không đổi tiến độ, trạng thái bàn hoặc đánh dấu việc giao.
- [ ] Ràng buộc từ chối người/đối tượng sai; migration xuôi-lùi-xuôi đạt, lùi có dữ liệu bị chặn.
- [ ] Bảng đúng ADR-137 điểm 3 — chỉ thêm, `UPDATE` và xoá bị DB từ chối, không khoá ngoại tới việc trạm/phiên/việc
      giao; mã gửi trùng theo điểm 6; người nhận rỗng là gửi về quầy.
- [ ] Test hồi quy `I-038` do Claude viết trước, đỏ trước migration, xanh sau.

**Verify:** db-check, ca lỗi ràng buộc và đối chiếu tiến độ/bàn trước-sau; Gate 1e; gate. Tên lược đồ chỉ chốt ở
migration sau duyệt.

**Nhận việc:**

2026-11-03, Claude: test `db/tests/i038_station_message.sql` viết trước, chạy `db-check` trong worktree `../lean_wt/CHAT-12` (nhánh
`codex/CHAT-12` từ `63ebec1`) đỏ đúng lý do `relation "station_message" does not exist`. Cũng đỏ ở đối chiếu: `I-038` chưa có câu ở
`db/reconcile/`, nên phiếu giao thêm `db/reconcile/i038.sql` bốn câu và file lỗi. Migration `20261103120000_hop_tin`, file lát
`docs/product/2-db/26-luoc-do-hop-tin.md`. Phiếu chờ hạn mức Codex.

[↑ đầu file](#top)

---

<a id="chat-13"></a>
### CHAT-13 — POS và trạm chưa có cửa gửi, đọc và phản hồi tin đúng người

**Goal:** Dựng BE tin báo trên DB của 12; một luồng định tuyến tới người canh+dọn, giữ loại việc; trạm phản hồi về
POS.

**Đứng trên:** L2, Codex; sau CHAT-12. ADR-097, docs/product/3-be/09-realtime-du-phong.md; ma trận quyền; thiết kế
định tuyến CHAT-02.

**Bẫy:** Không dùng role làm bằng chứng đang đứng trạm; không tự thêm lịch đổi người ngoài quầy. Không đưa tin riêng
lên productionEvents công khai.

**Chặn bởi:** Chờ U-113 (Q113); nếu mở khách nhắn trực tiếp còn chờ U-117 (Q117), mặc định không mở đường khách.

**Acceptance dự kiến:**

- [ ] POS gửi tin canh và tin dọn tới cùng người đã được xác định theo thiết kế, người ấy nhận mỗi tin một lần với
      đúng nhãn.
- [ ] Trạm gửi “đã múc/đem/dọn” chỉ tạo tin cho POS; không gọi C17, cleanTable hay markAssignedTask.
- [ ] Người không phải bên được phép đọc/gửi bị từ chối; khách và người ở trạm khác không đọc được tin riêng.
- [ ] Có ca người kiêm đi giao/POS gánh, đổi người hoặc chưa có người nhận: hành vi đúng lời/thiết kế; chưa đủ lời
      thì từ chối định tuyến, không đoán.
- [ ] Sau COMMIT mới phát tín hiệu đọc lại; mất SSE kéo vẫn đọc đủ tin từ DB; gửi lại không nhân bản tin.
- [ ] Danh sách công cụ của model không có cửa gửi tin (ADR-137 điểm 8); cửa gửi chỉ nhận người gửi từ phiên.
      Thẻ xác nhận trước khi gửi là Acceptance của CHAT-14, không phải của bước này.

**Verify:** be-check qua PostgreSQL thật, ca một người hai trạm, quyền đọc/gửi, lặp, mất SSE; đối chiếu không đổi
tiến độ; Gate 1f/1g; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-14"></a>
### CHAT-14 — Người canh và dọn chưa có một hộp tin dùng được khi tắt model

**Goal:** Dựng FE hộp tin riêng tư dùng chung ô chat; nhận hai loại việc trên cùng màn, trả tin về POS và mở màn tay
liên quan.

**Đứng trên:** L2, Codex; sau CHAT-04, CHAT-13, CHAT-34. shop-facts §3; docs/product/4-fe/01-khung-fe.md;
C08/C17/C18/C19; thiết bị được U-113 xác nhận.

**Bẫy:** Nút “báo POS” không phải “ghi tiến độ”. Giữ ngoại lệ cleanTable hiện hữu, không bắt màn tay dọn bàn đi qua
POS nếu chưa có luật mới.

**Chặn bởi:** Chờ U-113 (Q113). Khách muốn thêm do người làm chuyển lời nằm ở nhánh này; khách tự nhắn vẫn chờ U-117
(Q117).

**Acceptance dự kiến:**

- [ ] Người canh+dọn thấy cả tin múc và bàn cần dọn, phân loại rõ; không có hai hộp nhận tạo trùng việc.
- [ ] Báo đã múc/đem/dọn hoặc khách muốn thêm cho POS không đổi số món, bàn hay đơn; POS quyết và bấm cửa tay riêng.
- [ ] POS nhận tin thấy người gửi/đối tượng; việc phụ vẫn do POS/chủ quán đánh dấu theo I-030.
- [ ] Tắt model vẫn gửi/đọc tin được; mất SSE vẫn kéo lại, có mốc và cảnh báo, không phát tin riêng vào luồng công
      khai.
- [ ] Tráng/gấp có cùng kiểu tin theo quyền đã duyệt; không có nút báo xong ghi tiến độ ở trạm.
- [ ] Trước gửi có thẻ kiểm nội dung, loại việc và người nhận; bỏ thẻ không ghi, bấm xác nhận mới gửi.
- [ ] Người được giao thấy việc phụ của mình kèm hạn, đọc từ cửa của CHAT-34; không có nút đánh dấu xong.
- [ ] POS chọn người nhận từng lần từ `listPeople`, vai chỉ để gợi ý; người nhận không hoạt động bị từ chối
      và FE bày rõ lời từ chối (ADR-137 điểm 4).

**Verify:** fe-check; diễn một tài khoản canh_don_ban trên thiết bị đã chọn, POS và người khác; model tắt, SSE tắt,
gửi mất phản hồi; ca tráng và gấp gửi tin về quầy, ca người được giao thấy việc phụ có hạn và không có nút đánh dấu;
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-15"></a>
### CHAT-15 — Chat chưa gọi được cửa giao việc mà vẫn giữ quyền đánh dấu

**Goal:** Thêm nối công cụ BE cho C08 qua thẻ chung; POS/chủ quán giao, sửa, ẩn, đánh dấu hoặc bỏ đánh dấu.

**Đứng trên:** L2, Codex; sau CHAT-11, CHAT-14. C08; quality/invariants.md I-030; hợp đồng assigned-tasks, gồm hạn
giao việc.

**Bẫy:** Người nhận gửi tin xong không có nghĩa được markAssignedTask. Không biến tin báo thành việc giao tự động.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Giao có nội dung, người nhận và hạn theo hợp đồng; thiếu người/hạn bị từ chối, không đoán tên gần giống.
- [ ] Mỗi đánh dấu/bỏ là sự kiện có người và lúc; sửa/ẩn có lý do và vết.
- [ ] Người nhận ngoài quầy không tự đánh dấu qua công cụ; tin báo từ 14 không đổi trạng thái việc.

**Verify:** be-check C08 và I-030, thử qua thẻ 11, eval tên người/ý định mơ hồ; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-16"></a>
### CHAT-16 — Chat chưa phân biệt ghi đào tạo với đánh dấu việc

**Goal:** Thêm nối BE C09 cho hướng dẫn chữ, nhận xét/đánh giá và sửa/ẩn; tệp tiếp tục ở màn tay.

**Đứng trên:** L2, Codex; sau CHAT-15. C09; quality/invariants.md I-031; ma trận daotao.

**Bẫy:** Không tự chấm điểm nhân viên hay thêm hạng; nội dung hướng dẫn nhận từ người dùng là dữ liệu không phải chỉ
thị cho model.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Ghi hướng dẫn gắn đúng một việc; ghi nhận gắn đúng người, dùng giá trị đánh giá của hợp đồng.
- [ ] Thiếu nội dung bắt buộc, giá trị đánh giá lạ hoặc sai quyền bị từ chối; không tự diễn câu thành điểm.
- [ ] Sửa/ẩn giữ vết; yêu cầu gửi tệp qua model dẫn về màn tay, không tải URL hay gửi tệp riêng tư ngầm.

**Verify:** be-check I-031, ca sai đối tượng/giá trị/quyền, eval lệnh chèn trong hướng dẫn; kiểm thẻ chung, gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-17"></a>
### CHAT-17 — Chat chưa ghi được sổ nguyên liệu theo số người nhập

**Goal:** Nối BE C07: danh mục, đơn vị lần đầu, số mua/dùng ngày, sửa có lý do, tỉ lệ nhắc.

**Đứng trên:** L2, Codex; sau CHAT-11. C07; shop-facts §8.4; quality/invariants.md I-025/I-026.

**Bẫy:** Bán món không được tự trừ kho; model không suy lượng dùng hay phán thiếu từ hiệu số.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Thẻ ghi đúng số, đơn vị, ngày người nói; mơ hồ về ngày/đơn vị thì chưa có thẻ ghi.
- [ ] POS không là chủ bị từ chối; đổi đơn vị đã đặt bị cửa hiện hữu từ chối.
- [ ] Tổng đọc từ BE, sửa có vết; tạo đơn bán không tự tạo dòng dùng nguyên liệu.
- [ ] Đặt tỉ lệ nhắc qua thẻ gọi đúng `setSupplyItemReminderRatio`, sai quyền bị từ chối.

**Verify:** be-check I-025/I-026 với số thập phân, sai quyền/đơn vị; eval số và ngày; kiểm thẻ chung, gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-18"></a>
### CHAT-18 — Chat chưa quản lý tài khoản mà tránh đưa bí mật vào hội thoại

**Goal:** Nối BE C06 cho thao tác đã được duyệt; chỗ cần mật khẩu tạm chuyển thẳng màn tay.

**Đứng trên:** L2, Codex; sau CHAT-11. C06; ADR-109/131; quality/invariants.md I-033/I-035.

**Bẫy:** Không suy quyền từ Gmail trùng hay vai trong câu nói; không tự cấp cờ chủ quán hoặc cho model nhận mật
khẩu.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Chủ quán xác nhận đúng tài khoản và vai được phép trước khi duyệt/từ chối/khoá; tên mơ hồ không thực thi.
- [ ] POS và khách bị từ chối cửa chủ quán; thao tác không tạo person/tài khoản dịch vụ cho trợ lý.
- [ ] Khoá làm phiên mục tiêu hết hiệu lực theo cửa cũ; yêu cầu mở lại cần bí mật đi màn tay, không qua prompt/log.

**Verify:** be-check I-033/I-035 và khoá giữa đề xuất-xác nhận; kiểm payload/log không bí mật, thẻ chung;
nội dung gửi hãng không chứa tên người hay Gmail (G6); gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-19"></a>
### CHAT-19 — Chat chưa sửa thông tin menu mà tách được phần giá

**Goal:** Nối BE phần C04 không ghi giá; mọi thao tác cần thành phần/giá để tạo món dùng màn tay hoặc chờ 26.

**Đứng trên:** L2, Codex; sau CHAT-11. C04; quality/invariants.md I-009/I-018/I-032; ma trận menu/danhmuc.

**Bẫy:** Tên món, lựa chọn là dữ liệu có thể chứa lời chèn lệnh. Không mở một lệnh “thêm món” thiếu dữ kiện rồi tự
bù giá.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Đổi tên, xếp danh mục, ẩn/ngừng bán theo đúng cửa và lý do; không sửa ảnh chụp đơn cũ.
- [ ] POS/khách bị từ chối; đối tượng không có nhận đúng lỗi; đối tượng đã ẩn bị từ chối ở cửa sửa/ẩn
      nhưng là đầu vào hợp lệ của `unhideMenuOption`.
- [ ] Payload có giá/phụ thu/thành phần không được lách sang bước này; chuyển nhóm 26 hoặc màn tay.

**Verify:** be-check I-009/I-018/I-032, eval tên món chứa chỉ thị và ranh giới giá; kiểm thẻ chung, gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-20"></a>
### CHAT-20 — Chat chưa dừng và mở nhận đơn theo đúng người quyết

**Goal:** Nối BE C11, phân biệt tạm dừng nhận đơn với quán mù và mở lại; giữ tín hiệu quầy hiện có.

**Đứng trên:** L2, Codex; sau CHAT-11. ADR-097; docs/product/3-be/09-realtime-du-phong.md; I-008.

**Bẫy:** Chat sống không có nghĩa POS thấy đơn; mạng về không tự mở lại. Tắt ô chat không được biến đổi nhận đơn.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).
Chưa có đường đọc trạng thái nhận đơn cho lớp `chu_quan` — `counterQueue` lớp `quay`, còn
`nhandon/tam_dung` · `nhandon/tiep_tuc` lớp `chu_quan` (`02-vai-va-quyen.md`);
Claude thiết kế nguồn đọc trước khi mở, không hạ lớp `counterQueue`.

**Acceptance dự kiến:**

- [ ] Mỗi thẻ chỉ một cửa C11, bày đúng trạng thái hiện tại; sai lớp bị từ chối như màn tay.
- [ ] Tắt/mở chat hoặc model không đổi số luồng quầy và không tự khép khoảng mù.
- [ ] Mạng về vẫn cần người có quyền bấm mở lại; ghi khoảng có người và lúc, không phát khi lùi.

**Verify:** be-check I-008, cắt luồng quầy/model độc lập, thử sai lớp và trạng thái đổi trước bấm; kiểm thẻ chung,
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-21"></a>
### CHAT-21 — Khách chưa đặt được qua chat mà vẫn giữ luật đơn web

**Goal:** Nối BE C02 trong phạm vi U-117 cho phép; đọc menu/tính thử trước thẻ, gửi đúng cửa tạo lượt gọi khi xác
nhận.

**Đứng trên:** L2, Codex; sau CHAT-11, CHAT-20. C01/C02; shop-facts §6.2; ADR-131;
I-008/I-010/I-013/I-022/I-024/I-034/I-035.

**Bẫy:** Không giả staff_pos để bỏ duyệt; phiên khách hỏng không tự biến thành người làm. Có cửa QR chưa có nghĩa
được mở QR qua chat.

**Chặn bởi:** Chờ U-112 (Q112), U-115 (Q115), U-117 (Q117); chỉ hỏi quán không cần bước này.

**Acceptance dự kiến:**

- [ ] Đơn giao/đến lấy đủ liên hệ theo hợp đồng, giá từ hàm duy nhất; thiếu lựa chọn/liên hệ bị từ chối, không sửa
      hộ.
- [ ] Đơn khách chờ POS duyệt, chưa sinh việc trạm; giờ đóng/tạm dừng/quán mù bị từ chối đúng cửa.
- [ ] Gửi lại cùng dấu/thân không sinh đơn thứ hai; hai lần gửi thực sự khác nhau vẫn là hai đơn;
      lần gửi lại trả trạng thái hiện tại của đơn (`createOnlineOrder` 200).
- [ ] QR/gọi thêm/nhắn trực tiếp POS chỉ mở nếu lời U-117 cho phép và thiết kế riêng được duyệt; không tự mở từ API
      có sẵn.
- [ ] Thông tin cá nhân nhập thẳng vào thẻ, không đi qua model, prompt hay log gửi hãng (G6);
      đăng nhập giữ luật nhánh đã chốt.

**Verify:** be-check toàn nhánh web đã duyệt, ca lặp/từ chối/quán mù; eval giá và lời giả POS; chưa mở FE đặt món
tới 23; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-22"></a>
### CHAT-22 — POS chưa nhập và xử lý đơn qua chat theo đúng kênh

**Goal:** Nối BE C15/C12 cho nhập bàn, điện thoại, duyệt/từ chối và rời quán; chưa mở thu/huỷ/hoàn của 28.

**Đứng trên:** L2, Codex; sau CHAT-11, CHAT-20. C12/C15; ma trận don; shop-facts §2, §6.2;
I-001/I-004/I-006/I-007/I-022/I-024.

**Bẫy:** Chủ quán đang xem ở xa không phải đang đứng quầy. Không gán bàn cho đơn ngoài bàn hay nhầm đem về tại bàn
thành đơn riêng.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] POS đúng phiên nhập bàn/điện thoại đúng kênh; đơn người nhập và đơn khách giữ khác biệt duyệt theo owner.
- [ ] Chủ quán ngoài quầy/trạm bị từ chối; rời quầy sau đề xuất cũng bị từ chối.
- [ ] Bàn/số/liên hệ/hẹn chưa rõ không tự điền; gửi lại cùng dấu không tạo thêm đơn.
- [ ] Lệnh thu/huỷ/hoàn chưa được gọi từ bước này; rời quán giữ mọi từ chối của cửa hiện hữu.

**Verify:** be-check cửa nhập/xử lý đơn, eval phân kênh và quyền đổi; chưa mở FE tới 24; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-23"></a>
### CHAT-23 — Khách chưa kiểm được món và thông tin giao trước khi gửi chat

**Goal:** Dựng FE thẻ đơn khách từ BE 21, cho người tự kiểm/sửa món và nhập thông tin giao ngoài prompt.

**Đứng trên:** L2, Codex; sau CHAT-21. docs/product/4-fe/01-khung-fe.md nhóm khách; thẻ CHAT-11; I-022/I-024.

**Bẫy:** Sửa nháp sau khi xác nhận phải tạo xác nhận mới. Giá vừa đổi phải bày lại theo thiết kế, không sửa giá ở
FE.

**Chặn bởi:** Chờ U-112 (Q112), U-115 (Q115), U-117 (Q117).

**Acceptance dự kiến:**

- [ ] Thẻ hiện món/lựa chọn/số lượng/kênh/liên hệ/tổng BE trước bấm; thiếu dữ liệu không có gửi hợp lệ.
- [ ] Từ chối tổ hợp và giờ/quán mù có lời, không báo đã đặt; lần tạo bày mã đơn và trạng thái chờ POS duyệt;
      lần gửi lại bày trạng thái hiện tại backend trả, có thể đã qua duyệt.
- [ ] Mất phản hồi giữ dấu/thân và trạng thái chưa rõ; người bấm gửi lại không tạo đơn đôi.
- [ ] Đổi phiên khách không lộ bộ giao hoặc hội thoại của người trước; tắt chat vẫn mở màn đặt tay được.

**Verify:** fe-check với BE thật, dữ liệu thử; diễn giá đổi, tắt mạng lúc gửi, không phiên và phiên khách; chạy lại
eval đặt món; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-24"></a>
### CHAT-24 — POS chưa kiểm được bàn và kênh trước khi xác nhận đơn chat

**Goal:** Dựng FE thẻ đơn người làm; chọn bàn/kênh rõ và bày lỗi tại trường theo hợp đồng.

**Đứng trên:** L2, Codex; sau CHAT-22. docs/product/4-fe/01-khung-fe.md nhóm quầy, lớp client; CHAT-11; C12/C15.

**Bẫy:** Không cho tên người trong lời chat thay phiên. Màn tay quầy và luồng quầy phải sống khi đóng chat.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Thẻ phân biệt bàn với điện thoại và suất đem về; số/giá lấy BE, không tổng FE tự tính.
- [ ] Đổi người/rời quầy trong lúc xem thẻ bị cửa từ chối; thẻ cũ bị bỏ khi phiên đổi.
- [ ] Mất phản hồi không gửi lại ngầm; gửi lại có chủ ý giữ dấu và thân; màn tay vẫn thao tác được.
- [ ] Lỗi theo trường của hợp đồng bày đúng trường trên thẻ.

**Verify:** fe-check, diễn POS/chủ ngoài quầy và hai tab, gửi mất phản hồi, so đơn màn tay; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-25"></a>
### CHAT-25 — POS chưa dùng chat cập nhật tiến độ mà tách khỏi tin trạm

**Goal:** Nối BE C17 cho POS; tin báo chỉ là nguồn người tham khảo trước một thẻ POS riêng, không tự sinh xác nhận.

**Đứng trên:** L2, Codex; sau CHAT-14, CHAT-22, CHAT-24. ADR-011; shop-facts §5.4/§6.13; I-019/I-020; C17.

**Bẫy:** Model không chia mẻ, chọn bàn nhận thay POS hoặc lấy số tin báo cộng vào số đã ra. Người canh+dọn gửi tin
không có quyền quay.

**Chặn bởi:** Chờ U-112 (Q112), U-113 (Q113), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] POS chọn rõ mẻ, bàn/đơn và số từng thứ theo cửa; model không tự phân bổ số mơ hồ về nhiều bàn.
- [ ] Báo “đã múc/đem” ở trạm không đổi tiến độ; chỉ thẻ do POS có quyền bấm mới gọi C17.
- [ ] Trạm và chủ ngoài quầy bị từ chối; số vượt nhu cầu bị cửa từ chối; tổng chia bàn khớp nguồn.
- [ ] Lùi/chuyển/ghi làm sai giữ vết và luật hiện hành; khai số người không suy từ tin báo nghỉ.

**Verify:** be-check I-019/I-020 và mọi cửa C17 trong allowlist, ca báo trạm không ghi; eval số nhiều bàn; kiểm thẻ
chung, gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-26"></a>
### CHAT-26 — Chat chưa đổi giá và cấu tạo món qua hàm giá duy nhất

**Chưa mở** — đổi giá qua chat không nằm trong câu `U-115`, phải hỏi lại trước (ADR-136 *Sửa đổi*).

**Goal:** Nối BE C05 và phần có giá của C04 theo danh sách U-115 cho phép; bày thay đổi có lý do.

**Đứng trên:** L2, Codex; sau CHAT-19, CHAT-23, CHAT-24. C04/C05; docs/product/3-be/03-ham-gia.md;
I-009/I-011/I-013/I-032/I-034.

**Bẫy:** Không sửa giá suất bằng số model tính; giá combo có luật riêng. Đổi thành phần giữa buổi có lời nhắc theo
owner, không tự biến thành cấm cứng.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115); nếu không cho tiền qua chat thì chỉ dẫn màn tay.

**Acceptance dự kiến:**

- [ ] Giá mới đi qua cửa chủ quán và lý do/vết; mọi giá bán sau đó vẫn do gia.Tinh tính.
- [ ] Đơn cũ giữ ảnh chụp; sửa thành phần có nhắc theo luật, đổi giá combo/phụ thu combo giữ ràng buộc giờ hiện có.
- [ ] Khách/POS không là chủ bị từ chối; tổ hợp sai hoặc yêu cầu sửa giá suất không được công cụ tự quy đổi.
- [ ] Bộ eval giá chạy lại sau thay đổi, bao gồm món/combo và giá đổi giữa đề xuất-xác nhận.

**Verify:** be-check I-009/I-011/I-013/I-032/I-034 trên dữ liệu thử; eval giá có nguồn, thẻ chung và lời nhắc; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-27"></a>
### CHAT-27 — Chat chưa ghi khoản chi mà giữ nguồn tiền và vết

**Loại khỏi lộ trình 2026-11-01** (ADR-136 *Sửa đổi*, `U-115`: việc chạm tiền không qua chat);
entry giữ để truy lại, không giao phiếu.

**Goal:** Nối BE C10 từng thao tác sau khi U-115 cho phép; không suy một khoản là chi két nếu người chưa khai nguồn.

**Đứng trên:** L2, Codex; sau CHAT-11, CHAT-26. C10; quality/invariants.md I-018/I-021/I-029; shop-facts §8.10.

**Bẫy:** Không ghi tiền mua nguyên liệu hai lần; không đưa lương vào khoản chi khi owner dùng luồng khác. DELETE
không phải xoá cứng.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Thẻ chỉ rõ loại/khoản con, số tiền, ngày, nguồn; thiếu dữ kiện từ chối ghi, không đoán nguồn.
- [ ] Sai quyền hoặc sửa không lý do bị từ chối; ngày đã đối soát giữ từ chối của cửa.
- [ ] Khoản chi đi đúng phép két, sửa/xoá mềm giữ vết; không có đường ghi SQL riêng cho chat.

**Verify:** be-check I-021/I-029 và ca đổi nguồn/ngày, eval số tiền, kiểm thẻ chung; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-28"></a>
### CHAT-28 — Chat chưa có phép mở các lệnh tiền theo đúng chỗ đứng

**Loại khỏi lộ trình 2026-11-01** (ADR-136 *Sửa đổi*, `U-115`: việc chạm tiền không qua chat);
entry giữ để truy lại, không giao phiếu.

**Goal:** Chỉ khi U-115 cho phép, nối BE từng cửa C13; nếu không thì giữ toàn nhóm là đường dẫn màn tay.

**Đứng trên:** L2, Codex; sau CHAT-23, CHAT-24, CHAT-25. C13; shop-facts §6.13;
I-002/I-005/I-012/I-014/I-015/I-017/I-018/I-021.

**Bẫy:** Không có giảm giá độc lập; không tự biết ngân hàng đã nhận tiền. Quyền nguoi_quan của người giao không cho
mọi người nhận thay chuyến.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115); không dùng mặc định tạm để mở tiền.

**Acceptance dự kiến:**

- [ ] Danh sách mở ghi từng operationId được cho phép; cửa không được cho phép luôn từ chối, không đưa cho model.
- [ ] Chủ ngoài quầy không huỷ/hoàn; người giao sai chuyến bị từ chối; ai bấm đúng là ai vào vết.
- [ ] Đóng phiên/nợ/giảm giá giữ hình và phép tiền hiện có; thu nhiều phương thức không tự gộp mất dấu.
- [ ] Yêu cầu báo tiền đã về chỉ từ lời khách không tự thu; mất phản hồi không tạo lần thu/hoàn thứ hai.

**Verify:** be-check từng cửa C13 được mở và bất biến tiền; đối chiếu trước-sau, gửi lặp, sai quyền; eval chèn lệnh
tiền, thẻ chung; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-29"></a>
### CHAT-29 — Chat chưa khai két và đối soát mà giữ nguyên phép kiểm tiền

**Loại khỏi lộ trình 2026-11-01** (ADR-136 *Sửa đổi*, `U-115`: việc chạm tiền không qua chat);
entry giữ để truy lại, không giao phiếu.
Dòng Acceptance *không có đường chat “đóng dù lệch”* trái luật đối soát (`shop-facts.md` §6.10 — chủ quán bấm được
ngày lệch nếu ghi giải thích); mở lại thì viết lại dòng ấy.

**Goal:** Nối BE C14 và đặt số tối thiểu C03 theo phép được duyệt; từng thẻ chỉ một việc, không chuỗi tự đối soát.

**Đứng trên:** L2, Codex; sau CHAT-27, CHAT-28. C03/C14; shop-facts §6.10/§6.11/§6.27; I-012/I-014/I-018/I-021.

**Bẫy:** Sổ giấy nhập bù theo ngày bán, không ngày gõ. Model không được giải thích hộ số lệch rồi ký xong hoặc biến
tối thiểu thành dự báo.

**Chặn bởi:** Chờ U-112 (Q112), U-114 (Q114), U-115 (Q115).

**Acceptance dự kiến:**

- [ ] Thẻ khai đúng ngày/số/nguồn; số tối thiểu là số chủ nhập; phép cộng và đối soát lấy backend.
- [ ] Người không lớp bị từ chối; sửa số đã ký thiếu lý do bị từ chối.
- [ ] Còn lệch hoặc còn lượt giấy chưa nhập thì không có đường chat “đóng dù lệch”; không tự chuyển nguồn để làm
      khớp.
- [ ] Nhập bù giữ ảnh chụp giá tại mốc và vết người nhập theo cửa hiện có; không dùng giá model nhớ.

**Verify:** be-check I-014/I-021 và ngày có giấy/hoàn chéo/chi, kiểm các từ chối; eval lệnh bỏ qua đối soát, thẻ
chung; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-30"></a>
### CHAT-30 — Báo nghỉ chưa có luật đầy đủ và chỗ cất riêng

**Goal:** Sau khi có lời, dựng riêng DB báo nghỉ theo thiết kế Claude; chưa làm API hay màn.

**Đứng trên:** L2, Codex; sau CHAT-02. docs/product/99-unknowns.md U-116; work/admin-questions.md C30;
shop-facts §8.7; I-027.

**Bẫy:** C30 còn thiếu vế nghỉ báo trước có trừ tiền không. Không có ô công không có nghĩa đã báo nghỉ; tin nghỉ
không tự trừ lương.

**Chặn bởi:** Chờ U-116 (Q116), gồm cả thiết kế chỗ cất; không cần U-112 cho mẫu không model.

**Acceptance dự kiến:**

- [ ] Chỉ cất các trường và trạng thái được lời/thiết kế cho phép, có người và mốc để truy lại.
- [ ] Ghi báo nghỉ không sửa ô chấm công, số người hiện diện, ca hay tiền lương.
- [ ] Ca dữ liệu sai/người không có bị ràng buộc từ chối; xuôi-lùi-xuôi đạt, lùi mất dữ liệu bị chặn.
- [ ] Nếu lời yêu cầu nối ca/lương thì dừng nhánh đó để Claude mở việc thiết kế riêng, không suy thêm tại migration.

**Verify:** db-check ràng buộc và phép so chấm công/tiền không đổi; Gate 1e; gate. Chưa có lời thì chỉ giữ entry
này.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-31"></a>
### CHAT-31 — Chưa có cửa báo nghỉ nhận đúng người và người duyệt

**Goal:** Dựng BE báo nghỉ không model, đúng người gửi/nhận và duyệt nếu lời U-116 yêu cầu; độc lập cửa chấm công.

**Đứng trên:** L2, Codex; sau CHAT-30. Thiết kế CHAT-02; ma trận quyền; U-116; shop-facts §8.7/§8.8.

**Bẫy:** Không tự đặt hạn báo hay coi chủ quán được nhập hộ vì có cờ owner. Không dùng C08 đánh dấu thay quy trình
nghỉ.

**Chặn bởi:** Chờ U-116 (Q116); nếu chủ quán nhập hộ còn chờ U-114 (Q114). Nối ngôn ngữ sau này là lát khác chờ
U-112/U-115.

**Acceptance dự kiến:**

- [ ] Người báo, người nhận, hạn báo và duyệt đúng lời được ghi; không có lời cho duyệt thì không dựng duyệt.
- [ ] Sai người/nhập hộ không được phép bị từ chối; không đọc được báo nghỉ của người ngoài phạm vi.
- [ ] Gửi lại theo thiết kế không nhân đôi; có vết và đọc lại được; ca/lương/chấm công không đổi.

**Verify:** be-check qua DB thật, ma trận gửi/đọc/duyệt và gửi lại, đối chiếu không đổi công/lương; Gate 1f/1g;
gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-32"></a>
### CHAT-32 — Người làm chưa báo nghỉ bằng mẫu có kết quả rõ

**Goal:** Dựng FE mẫu báo nghỉ trong vỏ chat, không cần model; bày người nhận và trạng thái theo BE, chỉ gửi khi
người bấm.

**Đứng trên:** L2, Codex; sau CHAT-04, CHAT-31. docs/product/4-fe/01-khung-fe.md; lời U-116 và hợp đồng lát 31.

**Bẫy:** Không bày “đã duyệt” khi mới gửi; không hứa được nghỉ hay không trừ lương trước lời.

**Chặn bởi:** Chờ U-116 (Q116); chủ nhập hộ còn chờ U-114 (Q114). Không gọi model nên không dùng ngân sách U-112.

**Acceptance dự kiến:**

- [ ] Người kiểm nội dung/ngày/người nhận trước bấm; bỏ mẫu không ghi; thiếu trường hợp đồng bị từ chối.
- [ ] Mất phản hồi báo chưa rõ, không gửi lại ngầm; trạng thái đọc từ BE, không suy từ lời trong tin.
- [ ] Tắt model vẫn dùng được; người không quyền không đọc báo nghỉ người khác; đổi phiên dọn dữ liệu riêng.

**Verify:** fe-check, diễn hai người và chủ nhập hộ nếu được phép, mất phản hồi/model tắt; so DB và màn; gate.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-33"></a>
### CHAT-33 — Chưa có bằng chứng chat dùng được cả khi model và mạng lỗi

**Goal:** Nghiệm thu đầu-cuối từng nhánh đã được phép, số/tiền/quyền/dữ liệu riêng và đường lùi; giao quyết định mở
thật cho chủ repo.

**Đứng trên:** L3, Claude duyệt; Codex chạy phiếu kiểm. Sau tất cả nhánh được duyệt; kế hoạch §5–§8;
quality/invariants.md; backlog Đ-2/T-109.

**Bẫy:** Gate docs-only không chứng minh tính năng; nhánh còn chặn không được ghi xong. Mở thử không đồng nghĩa đủ
điều kiện bán thật.

**Chặn bởi:** Chờ U-112…U-117 tương ứng nhánh nghiệm thu (Q112…Q117); nhánh bị loại cần lời loại, không tự xoá khỏi
mục tiêu.

**Acceptance dự kiến:**

- [ ] Khách hỏi → thẻ đơn → POS duyệt → trạm đọc → tin báo → POS ghi được đối chiếu đúng nguồn, đúng người và không
      ghi đôi.
- [ ] Một người canh+dọn nhận hai loại việc, báo khách muốn thêm và báo dọn chỉ tạo tin; POS quyết bước nghiệp vụ
      riêng.
- [ ] Chấm theo cặp phiên × cửa của ma trận `02-vai-va-quyen.md`, có cả ca được phép và ca bị chặn — chủ ngoài
      quầy bị chặn ở cửa lớp `quay` nhưng qua ở cửa lớp `chu_quan`, cookie khách chỉ qua cửa lớp
      `khach` · `quay_hoac_khach`; quyền vừa bị rút, lời chèn lệnh và số model bịa đều bị chặn; giá/tiền khớp bộ chuẩn.
- [ ] Cắt model, hết trần, quá hạn, mất SSE/mạng và mất phản hồi sau ghi đều có đường suy giảm; màn tay vẫn chạy.
- [ ] Có số đo token/lần gọi/chi phí/độ trễ, so trần và tiêu chí đã duyệt; không dùng ước lượng §7 làm số đo.
- [ ] Có biên bản từng năng lực đạt/chặn/loại, Claude duyệt; bán thật chờ T-109 đạt và chủ repo quyết, không tự mở
      pha 5.

**Verify:** Chạy eval phiên bản cuối, db-check/be-check/fe-check theo phạm vi tích hợp, gate; diễn browser và cắt
phụ thuộc; lưu lệnh/output, bước tái hiện và người duyệt.

**Nhận việc:**

[↑ đầu file](#top)

---

<a id="chat-34"></a>
### CHAT-34 — Người được giao việc không có đường nào đọc việc của chính mình

**Goal:** Dựng BE một cửa đọc chỉ trả việc giao cho chính người đang đăng nhập, kèm hạn và hướng dẫn được phép; mặt
FE nằm ở CHAT-14.

**Đứng trên:** L2, Codex; sau CHAT-02. C08; quality/invariants.md I-030; ma trận `giaoviec/*`; shop-facts §8.
Phát hiện khi Claude duyệt 2026-11-01: `listAssignedTasks` lớp `quay_hoac_chu_quan`, nên người nhận không đọc được.
Lời yêu cầu nói người dọn nhận *"những việc phụ khác"*; *đọc việc của mình* là suy luận của Claude từ lời ấy.

**Bẫy:** Không hạ lớp của `listAssignedTasks`, vì cửa ấy trả cả quán. I-030 giữ người tạo, sửa, đánh dấu: cửa này chỉ
đọc. Người lấy từ phiên, không lấy từ tham số.

**Chặn bởi:** Không có U chặn và không gọi model; tên cửa, lớp do Claude quyết ở CHAT-02, dự kiến lớp `nguoi_quan`.

**Acceptance dự kiến:**

- [ ] Người được giao đọc đúng việc của mình, kể cả khi không đứng quầy; không thấy việc của người khác hay việc đã ẩn.
- [ ] Không phiên hoặc cookie khách bị từ chối; cửa không nhận định danh người từ tham số.
- [ ] Không có đường ghi mới: người nhận vẫn không đánh dấu, sửa hay ẩn được; hợp đồng và ma trận khớp code.

**Verify:** be-check qua PostgreSQL thật, ca hai người và ca không phiên; Gate 1g; gate.

**Nhận việc:**

2026-11-01, Claude: phiếu giao Codex, worktree `../lean_wt/CHAT-34`, nhánh `codex/CHAT-34` từ `de881a2` cộng thay đổi chưa commit của cây chính stage sẵn. Test `be/internal/giaoviec/viec_cua_toi_test.go` Claude viết trước, chưa chạy đỏ trên database. Lần chạy Codex đầu dừng vì hết hạn mức (tới 23:20), chưa có code. Việc kế tiếp: chạy lại phiếu, Claude duyệt diff và chạy `be-check`.

2026-11-03, Claude (T-284): test `be/internal/giaoviec/viec_cua_toi_test.go` chỉ có ca không phiên,
thiếu ca cookie khách mà Acceptance dòng 2 đòi; Claude bổ sung trước khi chạy lại phiếu.

2026-11-03, CHAT-34 xong. **Codex** thực hiện (worktree `../lean_wt/CHAT-34-v2`, nhánh `codex/CHAT-34-v2`, nền `ab731b3`, model `gpt-6-astra`); **Claude** viết test trước, thêm ca cookie khách, chạy đỏ trước (`be-check`: route rơi vào `/assigned-tasks/{assigned_task_id}`, 400), rồi duyệt. File: `be/internal/giaoviec/` (`handler.go`, `service.go`, `repository.go`, `sql/doc_cua_toi.sql`, `internal/sqlcgen/doc_cua_toi.sql.go`, `viec_cua_toi_test.go`), `docs/product/3-be/openapi.yaml` (0.55.0, `listMyAssignedTasks`), `fe/src/lib/api/schema.ts`. Bằng chứng: mã băm test không đổi; Claude chạy `./scripts/gate.sh` cây chính sau `git apply` — `be-check` PASS (`TestI030_ViecCuaToiChiTraViecCuaChinhNguoiDangNhap` PASS), Gate 1g PASS, `PASS gate không cổng nào đỏ`; `fe-check` PASS trong worktree. Cửa dùng `authz.NeedPerson` (`nguoi_quan`), người từ phiên, chỉ hướng dẫn `text` chưa ẩn, không đường ghi. Chưa có người duyệt thứ ba.

[↑ đầu file](#top)

---
