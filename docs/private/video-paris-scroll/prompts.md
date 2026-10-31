# Prompt mẫu để thực hành

Codex tự soạn ngày 2026-10-31 theo chuỗi công cụ trong mô tả video Creativo.
Không phải bản chép prompt từ video. Thay phần trong dấu `<...>` bằng dữ liệu
thật; không gửi nguyên chỗ giữ chỗ cho công cụ.

## 2. ChatGPT — tạo ảnh

```text
Tạo ảnh điện ảnh về Paris dùng cho trang giới thiệu du lịch. Chủ thể chính
là tháp Eiffel, ánh sáng chiều ấm, kiến trúc rõ, màu tự nhiên. Chừa vùng
ít chi tiết để đặt tiêu đề trên giao diện. Không chữ, không logo. Tỷ lệ ngang.
Đây là ảnh mở đầu cho một chuyển động camera chậm; bố cục cần ổn định và
chủ thể không bị cắt. Tạo một phiên bản trước để tôi duyệt.
```

Nếu dùng ảnh nguồn, thay yêu cầu tạo ảnh mới bằng yêu cầu phân tích bố cục và
đề xuất hướng chuyển động; không cần tái tạo ảnh đã có.

## 3. Flow — tạo video từ ảnh

```text
Use the uploaded image as the visual reference. Create a slow cinematic
camera move toward the Eiffel Tower. Preserve the architecture, lighting,
colors and perspective. Keep the movement continuous, with no abrupt cuts,
no added text and no morphing buildings. The clip will be converted into
frames for a scroll-controlled website.
```

## 6. Antigravity hoặc IDE — dựng chuyển động

```text
Làm việc trong thư mục video-paris-scroll đang mở. Chỉ tạo hoặc sửa file
trong website/. Không sửa ứng dụng của quán hay tài liệu ngoài thư mục này.

Trước tiên, đọc danh sách file thật trong assets/frames/ và báo số frame,
định dạng, kích thước và cách sắp theo thứ tự số. Nếu thư mục còn rỗng,
dừng phần hiệu ứng và nêu tài nguyên cần bổ sung; không bịa tên frame.

Tạo bản HTML/CSS/JavaScript tĩnh tối giản: một canvas hiển thị chuỗi ảnh theo
tiến độ cuộn của đoạn hero. Cuộn ngược chạy ngược. Giữ tỷ lệ ảnh, xử lý
resize và màn hình có mật độ điểm ảnh cao. Dùng requestAnimationFrame,
giới hạn tải trước và bộ nhớ đệm để không giữ mọi ảnh độ phân giải lớn cùng
lúc. Có trạng thái đang tải và ảnh thay thế khi tải lỗi; ưu tiên hiển thị
frame đầu ngay khi sẵn sàng. Với prefers-reduced-motion, hiện ảnh tĩnh và
nội dung đầy đủ. Bổ sung tiêu đề và liên kết chuyển xuống phần nội dung.

Khi chạy server với website/ là thư mục gốc, trình duyệt không truy cập
được ../assets/. Hãy sao chép đúng các tài nguyên cần dùng vào website/assets/
và dùng URL tương đối trong website/. Không nhúng đường dẫn tuyệt đối máy tôi.
Không thêm backend, đăng nhập hoặc đặt tour thật. Ghi cách chạy và những
kiểm tra đã thực hiện. Chưa triển khai website lên mạng.
```

## 7. Google AI Studio — bố cục

```text
Thiết kế landing page du lịch Paris với phong cách tạp chí, nền sáng, chữ
lớn và khoảng trắng thoáng. Dùng ảnh tham chiếu tôi đính kèm. Các phần gồm:
điều hướng, hero chuyển động theo cuộn, giới thiệu Paris, ba địa điểm nổi bật,
gợi ý hành trình và footer. Hỗ trợ điện thoại trước, không tràn ngang.

Hero sẽ được ghép với canvas chuyển frame có sẵn. Chừa một vùng tích hợp
rõ ràng, không thay nó bằng video tự chạy. Liên kết có đích thật trong trang;
không tạo nút đặt tour, form gửi dữ liệu hoặc số liệu khách hàng giả.
Xuất mã giao diện và chỉ rõ cách chạy. Ưu tiên HTML/CSS/JavaScript tĩnh.
```

Prompt ghép kết quả dành cho IDE sau khi xuất từ AI Studio:

```text
Đọc bản bố cục vừa xuất tại <đường dẫn thật>. Ghép các khối nội dung vào
website/, giữ nguyên cơ chế cuộn canvas đã chạy. Dùng tài nguyên thật và
kiểm tra lại đường dẫn trong gốc server website/. Không ghi đè file ngoài
thư mục thực hành. Kiểm tra điện thoại, bàn phím và giảm chuyển động.
```

## 8. ChatGPT — nội dung

```text
Viết bản nháp tiếng Việt cho landing page giới thiệu du lịch Paris: một
tiêu đề ngắn, một câu dẫn, ba đoạn giới thiệu địa điểm và gợi ý hành trình
một ngày. Giọng tự nhiên, dễ đọc. Không bịa giá tour, giờ mở cửa, giải thưởng,
đánh giá khách hàng hoặc cam kết dịch vụ. Nếu cần dữ kiện chưa có nguồn,
ghi rõ cần kiểm tra. Đây là trang thực hành, không nhận đặt tour.
```
