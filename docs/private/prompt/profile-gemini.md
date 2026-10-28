# Prompt Gemini — thiết kế lại trang thông tin khách hàng

Nếu Gemini có quyền đọc repo, dán prompt bên dưới. Nếu dùng Gemini trên web, đính kèm `profile.html` và hai file HTML tham chiếu ở mục 1; gửi thêm hai tài liệu mô tả nếu cần xem các trạng thái. Khi không có quyền ghi file, yêu cầu Gemini trả toàn bộ HTML trong một khối mã để lưu theo đường dẫn ở mục 6.

---

Bạn là người thiết kế UI/UX và lập trình giao diện cho quán **Bánh cuốn Bà Thanh Cao Bằng**. Hãy làm lại trang **Thông tin khách hàng / Hồ sơ của tôi** thành một bản HTML đẹp, dễ dùng trên điện thoại, đồng bộ với trang thực đơn và chi tiết món tham chiếu. Hãy tạo giao diện hoàn chỉnh có tương tác, không chỉ mô tả ý tưởng.

## 1. Đọc bản hiện tại và tham chiếu

- Trang cần làm lại: `docs/product/4-fe/thiet_ke/khach_hang/profile/profile.html`.
- Tham chiếu phong cách thực đơn: `docs/product/4-fe/thiet_ke/khach_hang/menu/gemini/meniu-anh-ngan.html`.
- Tham chiếu phong cách chi tiết món: `docs/product/4-fe/thiet_ke/khach_hang/product-detail/gemini/product-detail-gemini.html`.
- Mô tả bổ sung: `docs/product/4-fe/thiet_ke/khach_hang/profile/customer_profile.md` và `docs/product/4-fe/thiet_ke/khach_hang/profile/customer_profile_loading.md`.

Lấy `profile.html` làm nguồn chính về nội dung và tương tác cần giữ. Hai tài liệu Markdown có thông tin truy vết từ phiên bản cũ: không coi đường dẫn code, API, kết luận đã triển khai hay lỗi 404 trong đó là sự thật của hệ thống hiện tại. Chỉ dùng chúng để tham khảo các vùng giao diện và trạng thái tải. Không dựng backend hoặc suy ra hợp đồng API từ các tài liệu này.

## 2. Hướng thiết kế

Trang cần mang cảm giác ấm áp, gọn gàng, thân thiện như cùng một sản phẩm với hai trang tham chiếu. Dùng cam làm màu nhấn, nền trung tính, chữ rõ, khoảng cách thoáng và icon nhất quán. Học cách dùng font, màu, độ bo, viền và bóng từ bản tham chiếu, nhưng sắp xếp theo nhu cầu của một trang biểu mẫu.

Ưu tiên thao tác sửa thông tin rồi lưu. Phân cấp rõ tiêu đề, nhận diện khách, biểu mẫu, khám phá thêm và nút lưu; không để lối tắt lấn át biểu mẫu. Giảm chữ quá nhỏ và các khối trang trí dư thừa. Dùng SVG nội tuyến cho icon, tránh trộn emoji và ký tự tượng hình. Không dùng ảnh chân dung ngẫu nhiên, ảnh món hay banner lớn trên trang hồ sơ.

Được thay đổi bố cục, khoảng cách và cách trình bày, miễn giữ đầy đủ nội dung, chức năng và các tên vùng dưới đây. Mọi chữ cho khách đọc viết bằng tiếng Việt tự nhiên.

## 3. Những vùng và chức năng cần giữ

Gắn đúng `data-component` để tôi có thể chỉ ra vùng cần chỉnh:

1. `CustomerTopNav`: nút quay lại và tiêu đề “Thông tin khách hàng”. Có thể đặt nút sáng/tối ở đây như bản hiện tại. Quay lại phải có đường về thực đơn khi không có trang trước phù hợp.
2. `ProfileAvatarHeader`: avatar bằng chữ cái đầu, tên khách và lời chào ngắn. Tên trống thì hiển thị “Khách hàng”, chữ viết tắt “KH”. Nút camera giữ trạng thái vô hiệu hóa, có nhãn “Đổi ảnh chưa khả dụng”; không tạo luồng tải ảnh. Không thêm hạng thành viên, điểm hay quyền lợi.
3. `PersonalInfoForm`: giữ bốn trường và quy tắc minh hoạ của HTML hiện tại:
   - Họ và tên: bắt buộc, từ 2 đến 100 ký tự sau khi bỏ khoảng trắng đầu/cuối.
   - Số điện thoại: bắt buộc, đúng 10 chữ số, bắt đầu bằng 0; dùng bàn phím điện thoại.
   - Số nhà / Địa chỉ: bắt buộc, từ 5 đến 250 ký tự sau khi bỏ khoảng trắng đầu/cuối.
   - Email: tuỳ chọn, tối đa 150 ký tự; nếu nhập thì kiểm tra định dạng email.
   Label luôn hiện, không dùng placeholder thay label. Chỉ rõ trường bắt buộc và tuỳ chọn; báo lỗi ngay dưới đúng trường, giữ nội dung khách đã nhập và đưa focus về trường lỗi đầu tiên khi gửi không hợp lệ. Đây là quy tắc của bản mẫu, không phải quyết định nghiệp vụ mới.
4. `QuickNavGrid`: giữ bốn lối tắt **Thực đơn**, **Yêu thích**, **Đơn hàng**, **Đặt món**, có mô tả ngắn. “Đặt món” đi tới thực đơn; không đổi thành “Đặt bàn” hoặc tự tạo tính năng đặt bàn.
5. `SaveCTABar`: nút chính “Lưu thông tin”, thông báo chưa lưu / đang lưu / đã lưu / lỗi. Giữ dòng giải thích “Bản thiết kế minh hoạ · Chỉ lưu trên trình duyệt này”. Thiết kế nút dễ tiếp cận khi cuộn; nếu dính đáy thì đặt phía trên thanh điều hướng và chừa đủ chỗ để không che trường nhập, lỗi hoặc nội dung cuối trang.
6. `ClientBottomNav`: giữ các mục **Menu**, **Đơn hàng**, **Yêu thích**, **Theo dõi**, **Cá nhân**; đánh dấu “Cá nhân” đang được chọn bằng màu và `aria-current="page"`.

Không thêm đăng nhập, đăng xuất, đổi mật khẩu, OTP, liên kết Gmail, xoá tài khoản, quản lý nhiều địa chỉ, đặt bàn, tích điểm, ưu đãi hoặc chức năng nghiệp vụ khác. Nếu thấy cần thay đổi chức năng, ghi thành đề xuất cuối câu trả lời, không đưa vào HTML.

## 4. Tương tác và dữ liệu minh hoạ

Viết JavaScript thuần để biểu mẫu hoạt động thật trong phạm vi bản mẫu:

- Cho sửa bốn trường, kiểm tra hợp lệ, báo thay đổi chưa lưu. Cập nhật tên và chữ viết tắt ở phần nhận diện sau khi lưu thành công.
- Lưu trên `localStorage` bằng khoá riêng `customer-profile-gemini-demo-v1`. Chỉ ghi khi người dùng bấm lưu và biểu mẫu hợp lệ; không gọi API, không gửi thông tin ra ngoài, không ghi đè khoá của bản HTML gốc. Đọc lại dữ liệu khi mở trang; dữ liệu hỏng hoặc trình duyệt chặn lưu trữ không được làm hỏng trang.
- Khi đang lưu, khoá biểu mẫu và nút để tránh gửi lặp; xong thì mở lại. Thông báo thành công nói rõ đã lưu minh hoạ trên trình duyệt, không ám chỉ đã đồng bộ tài khoản.
- Lỗi lưu phải giữ dữ liệu đang nhập và cho thử lại. Thông báo dùng `role="status"` / `aria-live` thích hợp; lỗi trường có `aria-invalid` và `aria-describedby`.
- Mẫu dữ liệu hư cấu: Nguyễn An, `0912345678`, “123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh”; email để trống. Ghi rõ đây là dữ liệu minh hoạ trong phần điều khiển bản mẫu.

Đặt một thanh điều khiển demo ngoài khung điện thoại, tách khỏi giao diện khách hàng, để xem được các trạng thái: **Đang tải**, **Thông tin mẫu**, **Hồ sơ trống**, **Lỗi kiểm tra dữ liệu**, **Đang lưu**, **Lưu thành công**, **Lỗi lưu**. Các trạng thái giả lập không ghi đè dữ liệu đã lưu. Skeleton mô phỏng avatar, form, lối tắt và nút lưu; giữ thanh tiêu đề để vẫn quay lại được. “Hồ sơ trống” chỉ minh hoạ chưa nhập thông tin, không suy diễn lỗi 404 thành tạo tài khoản.

## 5. Yêu cầu hiển thị và kỹ thuật

- Một file HTML độc lập chứa CSS và JavaScript, mở trực tiếp bằng trình duyệt, không build, không framework. Ưu tiên CSS thuần; được dùng Google Fonts cho Be Vietnam Pro, có font hệ thống dự phòng. Không phụ thuộc ảnh mạng, thư viện icon hay backend.
- Có chế độ sáng và tối hoàn chỉnh; màu qua biến CSS. Cho chuyển chế độ bằng nút có nhãn rõ, nhớ lựa chọn nếu trình duyệt cho phép.
- Trên desktop: khung điện thoại khoảng 390–430px, căn giữa. Trên điện thoại: phủ chiều rộng màn hình, dùng được ở 320px mà không cuộn ngang; kiểm tra thêm 390px và 430px. Chừa `safe-area-inset-bottom` cho thanh dưới, xử lý bàn phím ảo để trường đang nhập vẫn nhìn thấy và cuộn tới được.
- Cỡ chữ nội dung và ô nhập tối thiểu 16px, nhãn phụ tối thiểu 12px; tương phản WCAG AA, vùng bấm tối thiểu 44×44px. Không dùng màu làm dấu hiệu duy nhất cho lỗi hoặc mục được chọn.
- Dùng HTML ngữ nghĩa, label liên kết đúng input, autocomplete đúng trường, focus bàn phím rõ. Tôn trọng `prefers-reduced-motion`; không dùng hiệu ứng sáng chạy hoặc hoạt ảnh trang trí liên tục.
- `<html lang="vi">`, meta viewport, `noindex,nofollow`, tiêu đề “Thông tin khách hàng · Bánh cuốn Bà Thanh”.
- Các link phải trỏ tới file thiết kế đang có. Vì file mới nằm sâu hơn một cấp trong `profile/gemini/`, dùng `../../menu/menu.html`, `../../favourite/favourite.html`, `../../customer_orders_tracking/order-tracking.html`; mục Cá nhân trỏ `profile-gemini.html`. Đơn hàng và Theo dõi cùng trỏ trang theo dõi như bản gốc. Không sao chép nguyên đường dẫn tương đối từ HTML gốc khi đặt file ở thư mục mới.

## 6. Đầu ra và tự kiểm tra

Nếu có quyền ghi repo, chỉ tạo `docs/product/4-fe/thiet_ke/khach_hang/profile/gemini/profile-gemini.html`, tạo thư mục nếu chưa có. Không sửa bản `profile.html` gốc, trang tham chiếu, code ứng dụng, API, tài liệu nghiệp vụ hoặc backlog. Nếu chỉ có chat, trả toàn bộ file HTML trong một khối mã duy nhất.

Trước khi hoàn tất, kiểm tra các trạng thái demo, sáng/tối, biểu mẫu hợp lệ và không hợp lệ, lưu và mở lại trang, trường hợp không dùng được localStorage, điều hướng tương đối, thao tác bàn phím và màn hình hẹp. Chỉ báo những kiểm tra thực sự đã chạy; phần chưa chạy phải nói rõ.

Trả lời bằng tiếng Việt ngắn gọn: file được tạo ở đâu, đã đổi gì về bố cục và phong cách, kết quả kiểm tra và đề xuất còn cần tôi chọn nếu có. Khi đã ghi file trong repo thì không dán lại HTML vào câu trả lời.
