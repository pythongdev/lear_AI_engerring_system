# Paris, qua một ô cửa

Bản thực hành HTML/CSS/JavaScript tĩnh, độc lập với ứng dụng quán, Codex thực hiện theo yêu cầu chủ repo ngày 2026-10-31. Chưa triển khai lên mạng.

## Chạy trên máy

Từ gốc repo:

```bash
python3 -m http.server 8091 --bind 127.0.0.1 --directory docs/private/video-paris-scroll/website
```

Mở <http://127.0.0.1:8091/>. Nhấn `Ctrl+C` trong terminal để tắt. Không cần cài package, build hoặc backend. Mở qua HTTP để trình duyệt đọc được `frames.json`.

## Tài nguyên và tham chiếu

Đối chiếu các storyboard mẫu ở đầu và cuối [video Creativo](https://www.youtube.com/watch?v=nPxMF2YV77I&t=77s), chưa đối chiếu toàn bộ lời nói/phụ đề. Giữ ý tưởng hero xanh đêm, cửa sổ máy bay, xuyên mây đến Eiffel; nội dung phía dưới viết lại bằng tiếng Việt trên nền sáng theo `prompts.md`. Không sao chép các khối quảng cáo agency hoặc số liệu template trong demo.

Khi bắt đầu, `assets/frames/` ở thư mục thực hành chỉ có `.gitkeep`: **0 frame**. Chủ repo đã xác nhận trong hội thoại ngày 2026-10-31: **“Dùng video gốc để làm tiếp hiệu ứng cuộn”**, cho phép tạo chuỗi ảnh thật trong `website/assets/`. Thư mục nguồn bên ngoài `website/` giữ nguyên.

Nguồn là [Plane window.mp4 của tác giả](https://drive.google.com/file/d/1RLaJ1CCpT7VqC7zUPRhYogBfB3x9p8gW/view): 1920×1080, 30 fps, khoảng 10,433 giây. Đã tách **157 ảnh JPEG 1280×720**, tên thật `paris-0001.jpg` đến `paris-0157.jpg`, thứ tự theo hậu tố số, 15 fps, tổng khoảng **4,66 MiB**. `frames.json` liệt kê đúng các file đã tạo, không tạo tên frame tại thời điểm chạy. Không tải hoặc phát video tự động.

Hai ảnh tĩnh là bản thu nhỏ của Image 2 (mây) và Image 3 (Eiffel) từ bộ nguồn tác giả. URL, kích thước và SHA-256 video nằm trong [assets/sources.json](assets/sources.json). Hình ảnh AI mang tính minh hoạ; watermark Veo từ video được giữ nguyên. Việc nguồn có thể tải công khai không được coi là một giấy phép sử dụng thương mại.

Lệnh tách sau khi tải video nguồn, chạy từ `website/` với FFmpeg:

```bash
ffmpeg -i /duong-dan-that/Plane-window.mp4 -vf 'fps=15,scale=1280:-2' -q:v 5 assets/frames/paris-%04d.jpg
```

Lệnh này chỉ mô tả cách tạo lại tài nguyên hiện có. Nếu dùng video khác, cần kiểm kê và cập nhật manifest theo danh sách file thật; không thay video mà giữ nguyên số lượng frame cũ.

## Cách hoạt động

Đoạn hero ghim canvas trong viewport; tiến độ cuộn trong chính đoạn đó quyết định chỉ số ảnh. Cuộn ngược chạy ngược. `requestAnimationFrame` chỉ chạy khi cuộn, resize hoặc ảnh tải xong, không chạy vòng lặp khi trang đứng yên. Ảnh giữ tỷ lệ và cắt cân giữa theo kiểu `cover`.

Tải tối đa 3 ảnh đồng thời, cache tối đa 10 ảnh đã tải, ưu tiên frame đầu rồi các frame quanh vị trí hiện tại. Không tải trước toàn bộ chuỗi. Ngoài cache có tối đa 3 ảnh đang tải và một ảnh đang hiển thị; với kích thước hiện tại, phần pixel giải mã có trần xấp xỉ 52 MiB, chưa tính bộ đệm canvas và bộ nhớ riêng của trình duyệt. DPR tối đa 2, cạnh canvas tối đa 2560 pixel.

Trong lúc tải, giữ cảnh gần nhất và báo trạng thái. Nếu một frame lỗi, giữ cảnh có sẵn; nếu không tải được chuỗi/manifest thì chuyển về ảnh tĩnh và rút ngắn hero. Khi `prefers-reduced-motion: reduce`, không request manifest hoặc frame, chỉ hiện ảnh Eiffel và đầy đủ nội dung. Đổi cài đặt ngay khi đang xem cũng có hiệu lực. Không có JavaScript, trang vẫn hiện ảnh thay thế và các liên kết nội dung.

## Kiểm tra

Chrome headless đã chạy thực tế ngày 2026-10-31. Hai agent thực hiện riêng phần đối chiếu nguồn và duyệt mã/trình duyệt; agent duyệt không sửa artifact, không phát hiện lỗi chặn nghiệm thu trong phạm vi website.

- Đạt bố cục, không tràn ngang ở 320×700, 390×844, 430×932, 1280×900; reviewer kiểm bổ sung 320×568. DPR 1, 2 và 3 đã được kiểm (canvas vẫn giới hạn DPR 2).
- Đạt cuộn hai chiều: các mốc 0%, 25%, 50%, 90%, 100%, 50%, 0% hiển thị chỉ số frame 0, 39, 78, 140, 156, 78, 0. Reviewer kiểm thêm mốc 80% → frame 125.
- Đạt preload/cache: lần mở mới chỉ tải nhóm quanh frame đầu, cache ≤ 10, đang tải ≤ 3; resize giữ canvas hợp lệ, cạnh không quá 2560 pixel.
- Đạt bàn phím Tab → liên kết bỏ qua → Enter tới giới thiệu; mọi liên kết nội trang có đích, không có URL máy cục bộ hoặc tài nguyên web bên ngoài trong script/style/image.
- Đạt giảm chuyển động: không request manifest/frame khi mở đầu ở chế độ này; đổi trực tiếp sang chuyển động rồi về ảnh tĩnh hoạt động đúng. Tắt JavaScript vẫn đọc được ảnh và nội dung.
- Đạt lỗi chủ động: manifest 404, tất cả frame 404 và một frame giữa chuỗi 404 đều có nội dung thay thế/trạng thái phù hợp, không lỗi JavaScript không được xử lý. Ở đường chạy bình thường: 0 lỗi JavaScript và 0 HTTP lỗi.
- Đạt kiểm manifest 157 tên duy nhất, đúng file thật/thứ tự số; `node --check app.js` và kiểm whitespace đạt.

Log/script/screenshot của vòng chính ở `/tmp/paris-scroll-task/`, reviewer ở `/tmp/paris-quality-review.json`, `/tmp/paris-quality-review.cjs` và `/tmp/paris-review-extra.cjs`. Đây là bằng chứng kiểm trên máy hiện tại, không phải dependency để chạy trang.

Chưa kiểm Safari, điện thoại vật lý hoặc trình đọc màn hình. Gate toàn repo được ghi trong phần bàn giao task Paris của backlog; gate coi file dưới docs/ là tài liệu nên các kiểm thử trình duyệt riêng phía trên mới là bằng chứng cho hiệu ứng.

Gate trên bản tách riêng từ HEAD chỉ ghép task này: exit 2 vì hai liên kết profile thiếu đã có trong HEAD, ngoài phạm vi website. Scope và các kiểm dữ liệu/hợp đồng đọc tệp đạt; verify bị SKIP do đường dẫn docs/. Không tuyên bố gate toàn repo xanh. Chi tiết và bước tiếp theo nằm ở mục T-275 của backlog.
