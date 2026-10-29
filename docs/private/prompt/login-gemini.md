# Prompt Gemini — trang đăng nhập khách có ảnh món ăn

Dán phần bên dưới vào Gemini. Nếu dùng Gemini trên web, đính kèm HTML đăng nhập, HTML menu tham chiếu và ảnh muốn dùng; Gemini không thể tự đọc đường dẫn trên máy bạn. Thư mục `docs/private/anh/anh-goc/` hiện chưa có ảnh (kiểm tra ngày 2026-10-29); bạn có thể đặt ảnh vào đó trước khi dùng prompt, hoặc đính kèm ảnh từ `docs/private/anh/`.

---

Bạn là người thiết kế UI/UX và lập trình giao diện cho **Bánh cuốn Bà Thanh Cao Bằng**. Hãy thiết kế trang **Đăng nhập dành cho khách** thật hấp dẫn với ảnh món ăn, có hai lựa chọn nổi bật: **Tiếp tục với Google** và **Đăng nhập bằng số điện thoại**. Tạo một bản HTML hoàn chỉnh có tương tác minh hoạ, ưu tiên điện thoại.

## 1. Tài liệu và phạm vi

- Bản đăng nhập để tham khảo: `docs/product/4-fe/thiet_ke/khach_hang/login/login-banh-cuon.html`.
- Tham chiếu phong cách: `docs/product/4-fe/thiet_ke/khach_hang/menu/gemini/meniu-anh-ngan.html`.
- Nguồn ảnh ưu tiên: `docs/private/anh/anh-goc/`. Xem ảnh thực tế rồi chọn ảnh bánh cuốn phù hợp, không đoán tên file.
- Nếu thư mục trên trống, có thể xem và chọn ảnh đang có trong `docs/private/anh/`, chẳng hạn `banh-cuon.png` hoặc `Vibrant Vietnamese Rice Roll Feast.png`. Nếu chỉ nhận file đính kèm thì dùng chính ảnh đính kèm.

Đây là bản thiết kế tĩnh để duyệt hình thức. Không sửa code ứng dụng, nghiệp vụ, API, backlog, file tham chiếu hoặc ảnh gốc. Nội dung quảng cáo và carousel trong HTML cũ chỉ là tham khảo hình thức, không phải yêu cầu phải giữ.

## 2. Hướng thiết kế

Tạo cảm giác ấm áp, ngon miệng, thân thiện và chỉn chu. Mặc định dark mode, dùng nền xanh đen `#0f172a`, nền thẻ `#1e293b`, chữ chính `#f8fafc`, chữ phụ `#94a3b8`, viền `#334155`, cam thương hiệu `#EA6A0C` và cam nhấn `#FF7A1A`. Font **Be Vietnam Pro**, có font hệ thống dự phòng. Giữ sự đồng bộ với menu về nút, khoảng cách và bo góc.

Ảnh món ăn là điểm nhấn đầu trang: chọn ảnh bánh cuốn rõ món, ánh sáng đẹp; dùng một ảnh lớn có chủ đích, tránh xếp nhiều ảnh nhỏ làm rối trang. Có thể phủ gradient tối nhẹ ở mép dưới để nối ảnh với nền và giữ chữ dễ đọc. Không dùng emoji thay ảnh món, ảnh stock không liên quan, ảnh nền lặp hoặc hiệu ứng phát sáng quá mạnh.

Trên điện thoại, ảnh chiếm khoảng 25–35% chiều cao màn hình đầu tiên; hai nút đăng nhập vẫn dễ tìm, không bị ảnh đẩy quá xa xuống dưới. Khi mở bàn phím, trang cuộn bình thường và ô đang nhập luôn tiếp cận được. Trên desktop có thể dùng bố cục hai cột: ảnh bên trái, form bên phải, giới hạn chiều rộng khoảng 1000px; không kéo form thành một dải quá rộng.

## 3. Nội dung và bố cục

Gắn `data-component` cho từng vùng để dễ yêu cầu chỉnh tiếp:

1. `LoginHeader`: nút “Về thực đơn” và tên quán; không tự vẽ logo thương hiệu giả nếu chưa có logo được cung cấp.
2. `FoodHero`: ảnh bánh cuốn hấp dẫn, lời chào ngắn “Mừng bạn ghé quán”. Không đặt chữ che phần món ăn quan trọng.
3. `LoginIntro`: tiêu đề “Đăng nhập”, dòng mô tả “Lưu thông tin giao hàng và xem lại đơn đã đặt”.
4. `LoginMethods`: nút **“Tiếp tục với Google”** có biểu tượng G dễ nhận diện, tiếp đến dòng phân cách “hoặc” và nút **“Đăng nhập bằng số điện thoại”** có icon điện thoại. Cả hai đều là nút lớn, dễ bấm; Google dùng mặt nút sáng để nổi bật trên nền tối, nút số điện thoại dùng sắc cam thương hiệu.
5. `PhoneLoginForm`: mặc định thu gọn; bấm nút số điện thoại thì mở ngay dưới lựa chọn đăng nhập và đưa focus vào ô số điện thoại. Có nhãn **“Số điện thoại”**, ô nhập số và nhãn **“Mật khẩu”**, ô mật khẩu kèm nút hiện/ẩn. Nút gửi **“Đăng nhập”**, có thao tác quay lại chọn phương thức. Giữ form gọn, phân cấp rõ ràng.
6. `GuestContinue`: dòng “Bạn vẫn có thể đặt món khi chưa đăng nhập” và link **“Xem thực đơn”**.

Không thêm ưu đãi, giảm giá, tích điểm, hạng thành viên, số lượng khách hàng, đánh giá, chứng nhận hoặc lời quảng cáo về quán chưa được cung cấp. Đăng nhập là tuỳ chọn, không viết rằng khách bắt buộc đăng nhập mới đặt được món. Không dựng thêm màn đăng ký hay khôi phục mật khẩu trong lần thiết kế này.

## 4. Tương tác minh hoạ

- Số điện thoại đăng nhập **kèm mật khẩu**, không phải OTP. Không thêm gửi SMS, mã xác thực, đếm ngược hoặc tự xác nhận số điện thoại. Hệ thống thật vẫn hỗ trợ nhập Gmail cùng mật khẩu; bản mẫu này chỉ tập trung hai lối vào được yêu cầu, không phải đề xuất xoá khả năng đó.
- JavaScript thuần: mở/đóng form, hiện/ẩn mật khẩu, kiểm tra hai ô không trống. Ô số điện thoại dùng `type="tel"`, `inputmode="tel"`, `autocomplete="username"`; mật khẩu dùng `autocomplete="current-password"`. Không tự đặt thêm quy tắc độ dài hay đầu số thành nghiệp vụ.
- Gửi form hợp lệ thì mô phỏng đang xử lý rồi hiện “Đây là bản xem thử, chưa đăng nhập tài khoản thật”. Không tạo phiên hay chuyển trang như thể đã xác thực thành công. Khi đang xử lý, chặn gửi lặp; lỗi giữ dữ liệu đã nhập và cho thử lại.
- Bấm Google cũng chỉ hiện thông báo minh hoạ rõ ràng. Không nạp Google Identity Services, gọi OAuth, mở cửa sổ giả yêu cầu chọn tài khoản hoặc thu thập tài khoản Google.
- Không gọi API, không gửi thông tin ra ngoài, không ghi số điện thoại hay mật khẩu vào localStorage, sessionStorage, URL hoặc console.
- Đặt thanh điều khiển demo ngoài giao diện dành cho khách để xem: mặc định, form số điện thoại, thiếu dữ liệu, đang xử lý, lỗi minh hoạ và Google chưa khả dụng. Thông báo trạng thái dùng `aria-live`; không trộn ghi chú kỹ thuật vào nội dung quảng bá.

## 5. Ảnh và yêu cầu kỹ thuật

- Một file HTML chứa CSS và JavaScript, mở trực tiếp trên trình duyệt; ảnh là tài nguyên cục bộ đi kèm. Không framework, không cần build. Có thể dùng Google Fonts, nhưng không phụ thuộc CDN CSS hay thư viện icon để bố cục hoạt động.
- Xem và chọn ảnh có thật. Giữ nguyên ảnh nguồn; dùng CSS `object-fit: cover`, chọn `object-position` hợp lý để không cắt mất món chính. Giữ tỷ lệ, không kéo méo, đặt kích thước hoặc `aspect-ratio` để tránh nhảy bố cục. Ảnh đầu trang không dùng lazy loading.
- File đầu ra nằm trong `docs/product/4-fe/thiet_ke/khach_hang/login/gemini/`. Nếu chọn `docs/private/anh/banh-cuon.png`, đường dẫn ảnh từ HTML là `../../../../../../private/anh/banh-cuon.png`. Nếu chọn ảnh trong `anh-goc/`, dùng cùng tiền tố rồi thêm `anh-goc/<tên-file-thật>`. Kiểm tra đường dẫn sau khi ghi; không ghi đường dẫn tuyệt đối của máy vào HTML.
- Nếu chỉ trả HTML qua chat, dùng tên file ảnh đính kèm làm đường dẫn tương đối, nói rõ cần đặt ảnh cạnh HTML. Không bịa URL ảnh hoặc dùng ảnh mạng thay thế. Nếu không nhận được ảnh nào, chừa vùng ảnh có thông báo thiếu ảnh trong phần demo và nêu rõ tài nguyên còn thiếu.
- Có `alt` mô tả ngắn đúng ảnh; nếu ảnh chỉ trang trí và nội dung kế bên đã đủ nghĩa, dùng `alt=""`. Khi ảnh lỗi, nền và bố cục vẫn giữ ổn định, không hiện biểu tượng ảnh vỡ lớn.
- Dùng được ở 320px, 390px, 430px và desktop, không tràn ngang, không khoá chiều cao khiến form bị cắt. Hỗ trợ safe area; không đặt thanh cố định che nút khi mở bàn phím.
- Ô nhập và chữ nội dung tối thiểu 16px, vùng bấm tối thiểu 44×44px, tương phản dễ đọc. Có label thật, focus bàn phím rõ; lỗi gắn với input qua `aria-describedby` và `aria-invalid`. Nút hiện mật khẩu có `type="button"` và nhãn thay đổi theo trạng thái.
- Tôn trọng `prefers-reduced-motion`; tránh carousel tự chạy và chuyển động trang trí liên tục.
- `<html lang="vi">`, meta viewport, `noindex,nofollow`, tiêu đề “Đăng nhập · Bánh cuốn Bà Thanh”.
- Link về menu từ vị trí HTML mới là `../../menu/menu.html`. Không dùng `href="#"` cho thao tác chưa có chức năng; dùng nút với thông báo minh hoạ hoặc bỏ thao tác đó.

## 6. Đầu ra

Nếu có quyền ghi repo, chỉ tạo `docs/product/4-fe/thiet_ke/khach_hang/login/gemini/login-gemini.html`, tạo thư mục nếu cần. Không ghi đè bản đăng nhập cũ. Nếu chỉ dùng chat, trả toàn bộ HTML trong một khối mã duy nhất, không chỉ mô tả ý tưởng hoặc mã rời.

Trước khi trả kết quả, kiểm tra đường dẫn ảnh và menu, mở form số điện thoại, hiện/ẩn mật khẩu, báo lỗi thiếu dữ liệu, chặn gửi lặp, thông báo Google minh hoạ, thao tác bàn phím và màn hình hẹp. Chỉ báo kiểm tra thực sự đã chạy; nếu chưa chạy trình duyệt thì nói rõ.

Trả lời bằng tiếng Việt ngắn gọn: file đầu ra, ảnh đã chọn, cách mở để xem và kết quả kiểm tra. Nếu đã ghi file thì không cần dán lại HTML.
