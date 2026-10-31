# Thực hành video: website Paris chuyển động theo cuộn

Chủ repo yêu cầu ngày 2026-10-31; Codex chuẩn bị thư mục thực hành riêng.
Đây là tài liệu học và chỗ chứa sản phẩm thực hành, không phải thiết kế hay
quyết định của hệ thống bán hàng trong repo.

## Bắt đầu ở đây

Video của Creativo giới thiệu quy trình dựng trang du lịch Paris: tạo ảnh,
tạo và ghép video, tách thành chuỗi ảnh rồi dùng AI dựng giao diện có chuyển
động theo thao tác cuộn. Nguồn là [video YouTube](https://www.youtube.com/watch?v=nPxMF2YV77I)
và [bộ tài nguyên tác giả chia sẻ](https://drive.google.com/drive/folders/1xGDm_8QRT2nS4lIT8Pvsrx9nOoSnDoIo).

**Giới hạn đã kiểm tra:** đọc được tiêu đề, mô tả chính thức và danh sách file
trong Drive ngày 2026-10-31. YouTube không trả được phụ đề; chưa đối chiếu toàn
bộ lời nói và thao tác trong video. Các bước dưới đây triển khai lại quy trình
trong mô tả; prompt là bản tự soạn để thực hành, không phải prompt chép từ video.
Không có thông số FPS, thời lượng, model hay mốc phút nào được nhận là của tác giả.

Thư mục hiện có hướng dẫn và chỗ để file; **chưa có website chạy được hoặc
ảnh/video đã tạo**. Bắt đầu bằng tải tài nguyên ở bước 1, rồi làm từng bước.

## Cấu trúc thư mục

```text
video-paris-scroll/
├── README.md            Hướng dẫn theo thứ tự
├── prompts.md           Prompt mẫu, đánh số trùng các bước bên dưới
├── resources.json       Nguồn video, Drive và ID các tài nguyên đã thấy
├── assets/
│   ├── images/          Ảnh gốc và ảnh tạo mới
│   ├── videos/          Video nguồn và bản ghép
│   └── frames/          Chuỗi khung hình sau khi tách video
└── website/             Mã website thực hành, độc lập với ứng dụng chính
```

Các file `.gitkeep` chỉ giúp Git giữ thư mục rỗng. Khi có sản phẩm thật, đặt vào
đúng thư mục tương ứng. Không cần sửa backend, database hay frontend của quán.

## Các bước thực hành

### 1. Chuẩn bị tài nguyên

Mở Drive của tác giả. Khi kiểm tra, thư mục có `Image 1`, `Image 2`, `Image 3`
và `Plane window.mp4`. Tải ba ảnh vào `assets/images/`, giữ đuôi `.jpg` của ảnh;
tải video vào `assets/videos/`. Liên kết từng file nằm trong `resources.json`.

Có thể dùng ngay ảnh nguồn để học luồng dựng trang, rồi mới thử tạo ảnh của
riêng mình. Các công cụ bên ngoài cần thao tác trong tài khoản của bạn; tài liệu
này không khẳng định hạn mức miễn phí hiện tại của chúng.

### 2. Tạo ảnh với ChatGPT

Dùng prompt 2 trong [prompts.md](prompts.md). Lưu ảnh được chọn vào
`assets/images/`. Giữ một bố cục và phong cách thống nhất giữa các ảnh để dễ
tạo chuyển cảnh. Nếu dùng ảnh từ Drive thì có thể bỏ qua bước tạo mới.

### 3. Tạo chuyển động với Flow

Đưa ảnh đã chọn vào Flow, dùng prompt 3 và xuất video vào `assets/videos/`.
Kiểm tra chủ thể không méo, chuyển động camera không giật và hai đầu cảnh có
thể nối được. Đây là tiêu chí thực hành tự đề xuất, không phải thông số đã
xác minh trong video.

### 4. Ghép video với Clipchamp

Nhập các clip vào Clipchamp, sắp theo trình tự muốn kể, cắt đoạn lỗi rồi xuất
bản ghép vào `assets/videos/paris-merged.mp4`. Xem hết bản ghép trước khi tách
ảnh; lỗi ở đây sẽ xuất hiện lại khi cuộn trang.

### 5. Tách video thành chuỗi ảnh với Ezgif

Đưa bản ghép vào chức năng tách khung hình của Ezgif, xuất ảnh rồi giải nén
vào `assets/frames/`. Ghi lại số ảnh, đuôi ảnh và quy tắc tên file thực tế để
đưa cho IDE. Không dùng thứ tự chuỗi thông thường nếu tên file là `1, 2, 10`;
cần thứ tự số hoặc tên có số 0 ở đầu.

Bắt đầu với một đoạn ngắn để kiểm tra độ mượt và dung lượng, sau đó điều chỉnh
số khung hình theo máy và điện thoại thực tế. Không coi mọi frame của một video
dài là bắt buộc phải tải cùng lúc.

### 6. Dựng chuyển động theo cuộn trong Antigravity

Mở **riêng thư mục này** trong IDE, dùng prompt 6. Yêu cầu IDE đọc tên và số
frame thực tế trước khi viết code vào `website/`. Cơ chế cần đạt là: cuộn tới
đâu thì hiện khung hình tương ứng tới đó; cuộn ngược thì chạy ngược.

Làm cho đoạn chuyển động chạy được trước khi thêm nhiều khối nội dung. Nếu
chưa có frame, dừng ở ảnh tĩnh có nhãn minh hoạ; không báo đã hoàn thành hiệu ứng.

### 7. Tạo bố cục với Google AI Studio

Dùng prompt 7 và ảnh tham chiếu của bạn để tạo bố cục. Xuất kết quả rồi nhờ IDE
ghép vào `website/`, giữ đoạn chuyển động đã chạy ở bước 6. Không dán đè toàn
bộ dự án nếu việc đó làm mất hiệu ứng đã kiểm tra.

### 8. Viết nội dung với ChatGPT

Dùng prompt 8 để tạo bản nháp nội dung. Kiểm tra và thay thông tin minh hoạ
trước khi sử dụng thật. Bài thực hành theo chủ đề Paris; chưa chuyển các nội
dung này thành giá, dịch vụ hay nghiệp vụ của quán.

### 9. Đưa ảnh lên Cloudinary nếu cần

Mô tả video có bước lưu ảnh bằng Cloudinary. Với bản học chạy trên máy, có thể
giữ ảnh cục bộ. Nếu muốn làm theo bước hosting ảnh, tải ảnh lên bằng giao diện
Cloudinary, lấy URL phân phối công khai và yêu cầu IDE thay đường dẫn tương ứng.
Không đưa API secret vào mã giao diện hoặc commit.

### 10. Kiểm tra bản thực hành

Đọc hướng dẫn chạy do IDE tạo trong `website/`. Nếu kết quả là HTML/CSS/JS tĩnh,
chạy lệnh này từ gốc repo sau khi đã có `website/index.html`:

```bash
python3 -m http.server 8091 --bind 127.0.0.1 --directory docs/private/video-paris-scroll/website
```

Mở `http://127.0.0.1:8091/`; nhấn `Ctrl+C` để tắt. Nếu AI Studio sinh một dự án
cần build, dùng lệnh của chính dự án đó thay cho server tĩnh này.

1. Cuộn xuống và lên: frame đổi đúng chiều, đầu và cuối không bị trống.
2. Kiểm tra tải lần đầu và khi thiếu ảnh: có trạng thái chờ hoặc ảnh thay thế.
3. Xem ở chiều rộng 390px và 1280px: chữ đọc được, không tràn ngang.
4. Bật chế độ giảm chuyển động: trang vẫn đọc được và không ép chạy hiệu ứng.
5. Dùng bàn phím tới các liên kết; kiểm tra nút điều hướng có đích thật.
6. Mở DevTools: không có lỗi JavaScript hay request ảnh thất bại.

Đó là tiêu chí kiểm tra cho bản thực hành đề xuất ở đây; chưa phải kết quả đã
chạy hoặc nghiệm thu một website.
