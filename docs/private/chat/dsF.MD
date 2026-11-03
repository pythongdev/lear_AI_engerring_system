Chưa có dòng code chat nào trong app. Tôi sẽ không tạo một khối "chat" gộp tất cả, mà tách phần theo hai quyết định đã chốt: hộp tin nội bộ là một domain backend riêng, còn ô chat là một component dùng chung ở frontend. Phần trợ lý AI chưa có thiết kế, vì câu hỏi dùng model nào vẫn còn mở.

Phần cây dưới đây không gọi model, đã có thiết kế trong ADR-137 và làm được ngay. Tên `hoptin`, các đường API và bảng `station_message` đã chốt; riêng thư mục `components/chat/` là đề xuất của tôi:

```text
be/internal/giaoviec/          thêm GET /assigned-tasks/mine (CHAT-34)
db/migrations/                 thêm cặp up/down cho bảng station_message (CHAT-12)
be/internal/hoptin/            domain mới: handler, service, repository, sql (CHAT-13)
be/cmd/server/router.go        gắn Routes của hoptin
docs/product/3-be/openapi.yaml thêm các cửa mới, hợp đồng lên phiên bản
fe/src/components/chat/        vỏ ô chat và hộp tin (CHAT-04, CHAT-14)
fe/src/app/quay|tram|chu-quan/layout.tsx  gắn ô chat sau cờ NEXT_PUBLIC_CHAT_ENABLED
```

Hộp tin được tách riêng vì nó phải chạy được cả khi tắt model. Bảng tin cũng cố ý không có khoá ngoại tới tiến độ, bàn hay việc giao, nên gửi tin không thể làm đổi tiến độ. Ô chat không có trang riêng mà gắn vào layout của quầy, trạm và chủ quán, nên đóng hay mở nó không ảnh hưởng màn làm việc; trang khách chưa gắn.

Sau này, lớp gọi model và danh sách công cụ theo phiên sẽ nằm ở một domain riêng, tôi dự định đặt là `be/internal/chat/`; tên này chưa chốt. Domain đó không có câu SQL ghi nào, mà chỉ gọi service của các domain sẵn có dưới chính phiên người đang chat, đúng ADR-136. Vì vậy các màn tay và luật hiện tại không phải viết lại, và các gate vẫn giữ nguyên nguyên tắc mỗi việc một cửa ghi.

Tôi sẽ làm theo thứ tự `CHAT-34` → `CHAT-04` → `CHAT-12` → `CHAT-13` → `CHAT-14`, tức là làm phần backend và dữ liệu trước phần hộp tin trên giao diện. Với mỗi lát L2, tôi viết test hồi quy trước, Codex thi công trong worktree riêng, rồi tôi đọc diff thật và tự chạy lại gate trước khi đưa bạn khối commit. `CHAT-04` là L1 nên chỉ cần Acceptance viết trước, không bắt buộc test hồi quy.

Việc đang dở là `CHAT-34`, tức đường đọc "việc của tôi": worktree `../lean_wt/CHAT-34` đã có, và test `viec_cua_toi_test.go` đã viết nhưng chưa chạy. Lần chạy Codex đầu dừng vì hết hạn mức nên chưa có code tính năng. Worktree này tách từ `de881a2` cộng với các thay đổi chưa commit của cây chính lúc đó, trong khi cây chính vẫn còn khoảng 165 file chưa commit. Nếu đẩy nhiều lát song song thì sẽ khó tích hợp, nên tôi làm lần lượt từng lát, và cây chính càng được commit sớm thì tích hợp càng nhẹ.

Còn hai câu hỏi đang chặn phần còn lại:

- **U-112**, chọn nhà cung cấp và model cho trợ lý, chặn toàn bộ nhánh AI: [docs/product/99-unknowns.md:168](docs/product/99-unknowns.md#L168)
- **U-116**, luật báo nghỉ (ai báo, ai duyệt, có chạm ca và lương không), chặn nhánh báo nghỉ: [docs/product/99-unknowns.md:172](docs/product/99-unknowns.md#L172)

Đợt Codex kiểm tra sổ việc vẫn có thể phát hiện lỗi ở các task này, nên tôi sẽ đối chiếu `TONG-HOP.md` trước khi giao lát kế tiếp. Lượt này tôi chỉ đọc, không sửa file nào nên không có khối commit.