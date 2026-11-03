Codex đã kiểm xong, và kết luận là **hệ thống chưa sẵn sàng để chạy online thật cho quán**. Backend và database đã khá chắc ở phần mật khẩu, phiên đăng nhập, phân quyền và test cho dòng tiền. Nhưng giao diện chưa đi hết một vòng bán hàng, chưa có sao lưu, và toàn bộ cấu hình hiện có chỉ dành cho máy phát triển.

Tôi đã tự mở code để đối chiếu bốn điểm quan trọng nhất, và cả bốn đúng như Codex nói. Server Go chạy `ListenAndServe` mà không đặt timeout nào ([be/cmd/server/main.go:39](be/cmd/server/main.go#L39)). Bộ đọc JSON không giới hạn kích thước thân request ([be/internal/apierr/http.go:40](be/internal/apierr/http.go#L40)); chỉ riêng chỗ tải file đào tạo là có giới hạn. Repo không có Dockerfile hay cấu hình triển khai nào. Bộ đếm đăng nhập sai chỉ nằm trong bộ nhớ của tiến trình ([be/internal/taikhoan/service.go:30](be/internal/taikhoan/service.go#L30)), nên khởi động lại server là mất.

**Bảy việc phải xong trước khi online**, theo thứ tự quan trọng:

1. **Hoàn thiện các luồng bán qua giao diện.** Chưa kênh nào trong năm kênh chạy được từ đầu đến cuối. Phần soạn lượt gọi tại quầy và nhập đơn điện thoại còn chờ đợt hai của P4-07 (màn quầy nhận đơn). Màn cho khách gọi món qua QR, giao hàng và mang đi chưa ai làm, và trang `/` vẫn chỉ là trang giữ chỗ. Màn thu tiền, két và đối soát ngày cũng chưa có.
2. **Đóng hai finding đang chặn.** F-073 là chuyện thiếu mã việc trạm và mã mẻ, nên trạm chưa bấm mẻ được ([work/findings.md:5081](work/findings.md#L5081)). F-074 là chuyện hàng chờ ở quầy không hiện món, số lượng và tổng tiền, nên quầy đang duyệt đơn mà không biết khách gọi gì ([work/findings.md:5106](work/findings.md#L5106)).
3. **Làm sao lưu và khôi phục.** Việc này là T-109 (bảo toàn và phục hồi dữ liệu), vẫn đang chờ pha 5 ([work/backlog.md:92](work/backlog.md#L92)). Tiêu chí đã chốt từ trước: mất tối đa một giờ bán, phục hồi xong trước ca kế tiếp, giữ bản sao lưu một năm.
4. **Dựng cấu hình production.** Cần đóng gói bản build FE/BE, có HTTPS và reverse proxy, health check, tự khởi động lại, và volume dữ liệu bền.
5. **Tách bí mật và dữ liệu thử.** Mật khẩu database đang ghi cứng trong `compose.yaml` và SQL khởi tạo. Đường nạp dữ liệu mồi chỉ tự bỏ qua khi bảng `person` đã có dữ liệu, chứ không có hàng rào riêng nào chặn nó trên production.
6. **Chặn quá tải khi mở ra Internet.** Cần giới hạn kích thước request, giới hạn tốc độ gọi, và đặt timeout cho server. Riêng đăng ký và đặt lại mật khẩu thì mỗi lần băm Argon2 tốn khoảng 64 MiB RAM, nên dễ bị dội request đến cạn bộ nhớ.
7. **Nghiệm thu trên môi trường thật.** Cần chạy build production, test database và migration trên cả database trống lẫn bản sao của database có dữ liệu. Tài liệu migration đã ghi rằng bước 8 có thể hỏng trên database đã có dữ liệu ([docs/product/2-db/07-thu-tu-migration.md:182](docs/product/2-db/07-thu-tu-migration.md#L182)).

**Nên làm trước khi online:**

- Kết nối realtime ở quầy chỉ kiểm quyền lúc mở. Codex suy luận rằng nếu tài khoản bị khoá giữa chừng thì kết nối đang mở vẫn sống tiếp, nhưng chưa tái hiện được.
- Thêm access log, health route, tắt server êm (graceful shutdown) và cảnh báo khi có sự cố.
- Bổ sung các header bảo mật (CSP, HSTS) và thử gửi email đặt lại mật khẩu thật qua SMTP.

**Làm sau được:**

- Tên miền và câu mô tả hiện trên Google. Đây là phần còn mở của U-094 ([docs/product/99-unknowns.md:136](docs/product/99-unknowns.md#L136)) và không chặn bán hàng.

**Bốn câu chỉ bạn quyết được:**

- Với đơn giao tận nơi, mốc "ra bàn" tính từ lúc nào? Mục S-6 hiện chỉ là suy luận "lúc đơn rời quán", chủ quán chưa xác nhận ([master_plan/shop-facts.md:1502](master_plan/shop-facts.md#L1502)).
- Khi quán tạm dừng nhận đơn, khách sẽ thấy câu gì ([work/backlog_FE.md:549](work/backlog_FE.md#L549))?
- Có mở pha vận hành ngay để làm T-109 không, và ai chịu trách nhiệm sao lưu?
- Tên miền chính thức của quán là gì?

**Những gì chưa kiểm được.** Sandbox của Codex không ghi được thư mục tạm và không tới được Docker. Vì vậy test Go, test Vitest, `db-check`, `be-check` và bốn gate tĩnh đều không chạy được. Những dòng FAIL trong báo cáo của Codex là do quyền ghi tạm, không phải lỗi của code. Lúc trước tôi nói sẽ tự chạy phần này, nhưng tôi chưa chạy. Nếu bạn muốn, tôi chạy `make` các bước kiểm tra trên máy thật ngay.

Trong lúc Codex chạy, `work/backlog.md` và thư mục `docs/product/4-fe/thiet_ke/` có thay đổi. Đó là việc T-215 (bản thiết kế tĩnh trang chủ quán) của một phiên khác. Codex chạy ở chế độ chỉ đọc nên không ghi được gì, và lượt này cũng không tạo thay đổi nào cần commit.

Báo cáo đầy đủ của Codex nằm ở /private/tmp/claude-501/-Users-monghoaivu-Desktop-code-lean-ai-engineering-system/9f30ebd7-59f8-4c73-ac66-484582a0f702/scratchpad/review-online-bao-cao.md. Nếu muốn, bạn có thể biến bảy việc phải xong ở trên thành task trong backlog.