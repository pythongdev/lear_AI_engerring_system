# Các khối giao diện của trang Tổng quan

Bản thiết kế nằm ở [tong-quan.html](tong-quan.html). Trang mở trực tiếp từ file,
không kết nối hệ thống. Nội dung và số liệu được đối chiếu với toàn bộ chữ chủ
repo cung cấp từ `/chu-quan` ngày 16/11/2026 lúc 16:21:23 (giờ Việt Nam). Trang
thật có thể đổi số liệu theo thời gian. Đường dẫn và các khối giao diện thật
vẫn do [01-khung-fe.md](../../../01-khung-fe.md) cùng `fe/` nắm.

Trên máy tính, thanh điều hướng nằm bên trái, nội dung nằm bên phải. Trang bày
ngày bán, mốc đọc và số bàn đang phục vụ; tiếp đó là *Đã ra* rồi *Còn thiếu*.
Mỗi nhóm có mốc nguồn riêng, mười một dòng tại quán đúng thứ tự, kể cả những
tên xuất hiện hai lần, và nhóm giao hàng trực tuyến đang trống. Sau đó là tiến
độ bán, tiền bán tạm tính và số người đang làm. Lý do chưa có số liệu được giữ
đúng nghĩa, không thay bằng một con số tự tính.

Phần *Còn thiếu gì* bày đủ ba mục: cả ba mươi nguyên liệu hiện ngay trong bảng,
trạng thái thiếu người, và mười món với số khách đặt và đã ra. Bảng nguyên liệu
không gắn thêm đơn vị cho các mục mà nguồn không có đơn vị. Biểu mẫu số tối
thiểu ở cuối trang là bản mẫu tĩnh, không lưu dữ liệu. Trên điện thoại, các
khối xếp một cột và điều hướng chuyển xuống đáy màn hình.

Chữ hiển thị trên trang dùng tiếng Việt. Công tắc *Hiện tên các khối* mặc định
tắt; khi bật, mỗi khối hiện một tên tiếng Việt dễ đọc. Thuộc tính
`data-component` vẫn giữ mã kỹ thuật để đối chiếu với mã nguồn. Bảng mã ở cuối
trang mặc định đóng và chỉ mở khi cần tra cứu.
