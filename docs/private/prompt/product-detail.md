Hãy thiết kế lại trang chi tiết món ăn trong file:
docs/product/4-fe/thiet_ke/khach_hang/product-detail/product-detail.html

Lấy phong cách giao diện từ file menu tham chiếu:
docs/product/4-fe/thiet_ke/khach_hang/menu/gemini/meniu-anh-ngan.html

Mục tiêu: hai trang trông như cùng một ứng dụng, đồng bộ font chữ, màu sắc, bo góc, khoảng cách và cách trình bày nút. Trang chi tiết phải mở mặc định ở DARK MODE, dùng màu cam làm màu hành động chính.

1. Phong cách thiết kế
- Dùng font “Be Vietnam Pro” giống trang menu.
- Lấy bảng màu dark mode của menu:
  + Nền tổng thể: #0f172a.
  + Nền thẻ và khối nội dung: #1e293b.
  + Chữ chính: #f8fafc.
  + Chữ phụ: #94a3b8.
  + Đường viền: #334155.
  + Cam thương hiệu: #EA6A0C.
  + Cam nhấn sáng trong dark mode: #FF7A1A.
  + Cam khi hover: #d05b05.
- Nút “Thêm vào giỏ” có nền cam, chữ rõ, bo góc và chiều cao tương tự nút chính trong menu.
- Tùy chọn đang chọn dùng viền cam và nền cam trong suốt nhẹ.
- Các nút phụ có nền tối, viền nhẹ; nút tăng số lượng nhấn bằng màu cam.
- Thiết kế gọn, dễ đọc, ưu tiên ảnh món ăn và thao tác gọi món. Tránh hiệu ứng phát sáng mạnh hoặc trang trí rườm rà.

2. Bố cục trang chi tiết
Giữ các khối nội dung đang có, nhưng sắp xếp và tạo kiểu lại:
- Header có nút quay lại, tiêu đề “Chi tiết món”, nút giỏ hàng kèm số lượng.
- Ảnh hoặc hình minh họa món ăn nổi bật, cân đối trên điện thoại.
- Nhãn tình trạng, tên “Bánh cuốn nhân thịt”, giá và đơn vị, mô tả món.
- Khối “Thêm chút ngon” với hai topping hiện có: Chả lụa và Hành phi.
- Khối chọn số lượng với nút giảm, số lượng và nút tăng.
- Thanh hành động bám đáy có phép tính tiền và nút “Thêm vào giỏ” kèm tổng tiền.
- Điều hướng cuối trang giữ các mục và đường dẫn hiện có.

Không sao chép danh sách món, thanh tìm kiếm, thông tin Bàn 3 hoặc luồng “Gửi lượt gọi” từ trang menu sang trang chi tiết. File menu chỉ là mẫu tham chiếu về hình thức.

3. Giữ nguyên nội dung và tương tác
- Giữ giá món 35.000đ, Chả lụa +10.000đ và Hành phi +5.000đ; đây là dữ liệu minh họa.
- Tổng tiền = (giá món + tổng giá topping được chọn) × số lượng.
- Số lượng tối thiểu là 1; vô hiệu hóa nút giảm khi đang là 1.
- Chọn topping hoặc đổi số lượng phải cập nhật tổng tiền ngay.
- Giữ thao tác thêm vào giỏ, badge số lượng, thông báo thêm thành công và hộp thoại xem giỏ minh họa.
- Giữ các trạng thái xem thử: còn hàng, đang tải, lỗi/không tìm thấy, hết hàng và không có topping.
- Giữ nút đổi sáng/tối trong phần điều khiển demo, nhưng mặc định khi mở trang phải là dark mode.
- Khi hết hàng, vô hiệu hóa thao tác thêm món.
- Giỏ chỉ lưu trong bộ nhớ trang; không thêm backend, lưu trữ lâu dài hoặc chức năng gửi đơn.
- Không tự thêm lựa chọn nhân, lượng nhân, nghiệp vụ hay nội dung mới từ trang menu.

4. Responsive và khả năng sử dụng
- Trên điện thoại, trang chiếm toàn bộ chiều rộng; trên desktop, hiển thị trong khung điện thoại khoảng 390–430px giống mẫu menu.
- Không tràn ngang; nội dung cuối trang không bị thanh hành động che.
- Nút thao tác chính có vùng chạm tối thiểu 44px.
- Có trạng thái focus rõ, nhãn hỗ trợ cho nút biểu tượng và độ tương phản dễ đọc.
- Đặt điều khiển demo và ghi chú dữ liệu minh họa bên ngoài phần giao diện dành cho khách.

Đầu ra:
Trả về toàn bộ mã HTML hoàn chỉnh trong một file, gồm CSS và JavaScript, có thể lưu và mở để xem thử. Có thể dùng Tailwind CDN và Google Fonts giống file menu. Không chỉ trả lời bằng mô tả hoặc đoạn mã rời. Kiểm tra các tương tác và phép tính trước khi trả kết quả.