Vậy bạn dùng prompt độc lập dưới đây. Gemini không cần đọc HTML hay ảnh; phần hình món ăn sẽ dùng minh hoạ để bạn duyệt bố cục và cách vuốt trước.

```text
Bạn là chuyên gia UI/UX và lập trình giao diện. Hãy tạo một bản thiết kế menu mới cho “Bánh cuốn Bà Thanh Cao Bằng” bằng HTML, CSS và JavaScript.

Tôi không thể đính kèm HTML hoặc ảnh. Hãy dùng mô tả dưới đây làm đầu vào đầy đủ, không yêu cầu tôi cung cấp thêm file.

MỤC TIÊU

Menu trên điện thoại có một chiếc mâm bày sẵn món ăn ở trung tâm. Khách vuốt trái/phải để xem món hoặc combo tiếp theo. Thông tin và lựa chọn của món đang xem hiện ngay bên dưới. Phía cuối màn hình luôn có phần tổng hợp lượng bánh khách đang chọn.

Đây là bản mẫu để duyệt thiết kế, không kết nối hệ thống bán hàng thật.

1. MÂM MÓN ĂN

Thiết kế một chiếc mâm nhìn từ trên xuống hoặc hơi nghiêng, trên đó bày món ăn hấp dẫn:
- Bánh cuốn trắng mềm.
- Bánh cuốn trứng.
- Giò ăn kèm.
- Bát canh.

Mỗi món lẻ hoặc combo có một cách bày mâm tương ứng. Combo phải thể hiện được nhiều thành phần trên cùng mâm.

Vì không có ảnh, hãy tự dựng minh hoạ bằng SVG nội tuyến và CSS. Hình cần nhận diện được món, có bóng đổ nhẹ và bố cục đẹp. Không dùng emoji thay món ăn, không phụ thuộc ảnh mạng. Không cần giả làm ảnh chụp.

Mâm phải là điểm nhấn lớn nhất của giao diện. Chừa một phần mâm trước/sau ở hai bên để khách hiểu có thể vuốt tiếp.

2. BỐ CỤC ĐIỆN THOẠI

Từ trên xuống:
- Header gọn: tên quán, thông tin “Bàn 03” minh hoạ.
- Bộ lọc: “Tất cả”, “Combo”, “Món lẻ”.
- Vùng mâm có thể vuốt ngang.
- Tên món, giá, mô tả và lựa chọn.
- Thanh tổng hợp cố định ở đáy màn hình.

Dưới mâm có chỉ báo vị trí và gợi ý “Vuốt để xem món”. Có nút trước/sau để dùng bằng chuột và bàn phím.

Vuốt trái xem món tiếp theo, vuốt phải quay lại. Không tự động chạy. Vuốt không làm thêm món vào đơn. Chuyển động mâm và thông tin phải đồng bộ.

3. DỮ LIỆU MINH HOẠ

Dùng dữ liệu dưới đây chỉ để chạy bản mẫu, không coi đây là bảng giá chính thức.

Combo “Suất giò”:
- Giá 21.000đ/combo.
- Gồm 3 bánh cuốn, 1 phần giò, 1 bát canh.

Combo “Đầy đủ trứng chín”:
- Giá 30.000đ/combo.
- Gồm 3 bánh cuốn, 1 bánh trứng chín, 1 phần giò, 1 bát canh.

Combo “Đầy đủ trứng tái”:
- Giá 30.000đ/combo.
- Gồm 3 bánh cuốn, 1 bánh trứng tái, 1 phần giò, 1 bát canh.

Combo “Đầy đặn”:
- Giá 42.000đ/combo.
- Gồm 3 bánh cuốn, 1 bánh trứng chín, 1 bánh trứng tái, 1 phần giò, 1 bát canh.

Món lẻ:
- Bánh cuốn: 4.000đ/cái.
- Giò: 9.000đ/phần.

Không tự thêm ưu đãi, giảm giá, phí giao hàng hoặc món khác.

4. THÔNG TIN VÀ CHỌN MÓN

Với mỗi món hoặc combo, hiển thị:
- Tên.
- Giá và đơn vị bán.
- Mô tả ngắn.
- Danh sách thành phần kèm số lượng nếu là combo.
- Nút thêm vào đơn và điều chỉnh số lượng.

Với bánh cuốn và combo có bánh cuốn, minh hoạ hai nhóm lựa chọn:
- Nhân: “Thịt” hoặc “Thịt mộc nhĩ”.
- Lượng nhân: “Vừa” hoặc “Nhiều”.

Hai nhóm lựa chọn này chỉ phục vụ thử giao diện, không thay đổi giá trong bản mẫu. Ghi chú đó trong phần giới thiệu bản demo, không chèn vào luồng chọn món.

Nếu cùng món nhưng khác lựa chọn thì giữ thành những dòng riêng trong đơn. Khi quay lại một mâm, không làm mất đơn đang chọn.

5. TỔNG HỢP LƯỢNG BÁNH Ở ĐÁY

Thanh đáy luôn dễ nhìn, có:
- Tiêu đề “Bạn đã chọn”.
- Tổng số bánh cuốn, bánh trứng chín, bánh trứng tái.
- Giò và canh hiển thị riêng, đúng đơn vị.
- Tổng tiền.
- Nút “Xem đơn”.

Phải cộng cả thành phần trong combo và món lẻ.

Ví dụ: chọn 2 combo “Đầy đủ trứng chín” và 1 bánh cuốn lẻ thì kết quả là:
- 7 bánh cuốn.
- 2 bánh trứng chín.
- 2 phần giò.
- 2 bát canh.
- Tổng tiền 64.000đ.

Không cộng giá các thành phần combo thêm một lần nữa.

Khi có nhiều nội dung, thanh đáy thu gọn hợp lý, không chiếm hết không gian xem mâm. Bấm “Xem đơn” mở bảng từ dưới lên:
- Hiển thị các combo và món lẻ đã chọn.
- Hiển thị lựa chọn nhân và lượng nhân.
- Cho phép tăng, giảm hoặc bỏ từng dòng.
- Có mục tổng hợp thành phần, giữ phân biệt các lựa chọn nhân.
- Hiển thị tổng tiền.
- Có nút đóng để tiếp tục chọn.

Số lượng và tổng tiền phải cập nhật đồng bộ ngay sau mọi thay đổi. Chưa chọn gì thì hiện “Bạn chưa chọn món”.

Dùng từ “đang chọn” hoặc “đã chọn”, không báo đã mua hay đặt đơn thành công.

6. PHONG CÁCH

- Ấm áp, ngon miệng, hiện đại, dễ dùng bằng một tay.
- Nền xanh đen #0f172a.
- Nền khối #1e293b.
- Chữ chính #f8fafc, chữ phụ #94a3b8.
- Màu cam thương hiệu #EA6A0C.
- Font Be Vietnam Pro, có font hệ thống dự phòng.
- Mâm có sắc gỗ hoặc màu vật liệu ấm, nổi bật trên nền tối.
- Không dùng quá nhiều khung thẻ, gradient hay hiệu ứng phát sáng.

Màn hình đầu tiên nên thấy được mâm, tên món, giá, thao tác thêm và thanh tổng hợp. Trên điện thoại thấp, cho phép cuộn dọc tự nhiên, không thu chữ quá nhỏ.

7. YÊU CẦU KỸ THUẬT

- Trả một file HTML hoàn chỉnh, chứa CSS, JavaScript và SVG nội tuyến.
- Mở trực tiếp bằng trình duyệt, không cần cài đặt hoặc build.
- Không dùng framework, không gọi API.
- Phân biệt thao tác vuốt ngang với cuộn dọc.
- Bấm nút chọn nhân hoặc tăng giảm không được vô tình chuyển mâm.
- Hoạt động ở chiều rộng 320px, 390px, 430px và desktop.
- Thanh đáy hỗ trợ safe area, không che nội dung cuối trang.
- Vùng bấm tối thiểu 44×44px, có focus bàn phím rõ.
- Hỗ trợ prefers-reduced-motion.
- Dùng một nguồn dữ liệu chung để tính đơn, tổng thành phần và tổng tiền.

Trước khi trả kết quả, kiểm tra ví dụ 64.000đ ở trên, thao tác vuốt, lọc danh mục, thêm món khác lựa chọn, tăng giảm, bỏ món và trạng thái giỏ trống.

Hãy trả toàn bộ mã HTML trong một khối mã duy nhất để tôi lưu thành menu-mam.html và mở xem ngay.
```