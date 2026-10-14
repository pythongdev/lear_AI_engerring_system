# SEO nền của frontend

Báo cáo 2026-10-14 theo phiếu `T-189`. Cây route và quy ước thêm màn thuộc
[Khung frontend](01-khung-fe.md).

Trước thay đổi, frontend chỉ khai title và `lang="vi"`. Layout nay có title mặc định cùng mẫu title cho trang
con, mô tả và Open Graph tiếng Việt để máy tìm kiếm và nơi chia sẻ liên kết có thông tin nền. Chuỗi mô tả trong
code là **bản nháp chờ chủ quán duyệt — U-094**, chưa phải nội dung đã duyệt. Ngôn ngữ HTML vẫn là tiếng Việt.

Layout mặc định yêu cầu không lập chỉ mục và không theo liên kết vì phần lớn màn là nội bộ hoặc QR gắn bàn.
Chỉ trang nằm trong `PUBLIC_ROUTES` ở `fe/src/lib/seo.ts` mới được bật bằng `publicPageMetadata(path)`;
truyền đường dẫn ngoài danh sách sẽ báo lỗi. Hiện danh sách chỉ có `/`. Đây là chỉ dẫn cho máy tìm kiếm;
quyền truy cập vẫn do hệ thống xác thực và phân quyền đảm nhiệm.

Địa chỉ gốc lấy từ `BANHCUON_SITE_URL`, bỏ dấu `/` cuối, không dùng tiền tố `NEXT_PUBLIC_`. Khi có biến,
layout khai metadataBase và trang công khai có canonical. Thiếu biến thì cả hai đều vắng mặt, tránh tự đoán tên
miền. Biến được đọc lúc build, nên đổi biến cần build lại.

robots.txt cho phép thu thập `/`, chặn `/api/`, và chỉ dẫn tới sitemap khi có địa chỉ gốc. sitemap.xml sinh URL
tuyệt đối từ chính `PUBLIC_ROUTES`, không tự đặt ngày sửa nội dung. Thiếu địa chỉ gốc thì danh sách rỗng và
robots.txt không có dòng Sitemap.

Trang chủ render JSON-LD Restaurant ngay ở server bằng một hàm thuần. Dữ liệu chỉ có loại, tên, điện thoại và
URL khi đã cấu hình; không khai địa chỉ, giờ mở hay lịch theo ngày khi chưa đủ dữ kiện. Chuỗi JSON mã hoá dấu
`<` thành `\u003c` trước khi đưa vào thẻ script để nội dung không thể đóng thẻ sớm.

## Thêm một trang công khai

Thêm đường dẫn vào `PUBLIC_ROUTES`, rồi export metadata bằng `publicPageMetadata(path)` tại server component
của trang. Cùng lượt ấy thêm dòng vào bảng route của [Khung frontend §1](01-khung-fe.md#1-cây-route), render nội
dung ở server và bổ sung kiểm thử cho trang. Sitemap tự lấy danh sách chung nên không cần thêm một danh sách khác.

## Tự kiểm

Trong thư mục `fe/`, đặt `BANHCUON_SITE_URL` thành tên miền đã được duyệt trước khi chạy:

```sh
npm run build && npm start
```

Ở terminal khác, kiểm phản hồi:

```sh
curl -s http://localhost:3000/robots.txt
curl -s http://localhost:3000/sitemap.xml
curl -s http://localhost:3000/
```

Xem `<head>` của `/`: title, description, Open Graph, robots cho phép lập chỉ mục và canonical đúng tên miền.
Trong HTML phải có script `application/ld+json`. Build lại khi bỏ biến để kiểm canonical vắng mặt, sitemap
không có URL và robots.txt không có dòng Sitemap. Kiểm thử tự động ở `fe/src/lib/seo.test.ts` phủ cả hai nhánh.

## Còn chờ

Câu hỏi **U-094** ([`../99-unknowns.md`](../99-unknowns.md), mục *Đang mở*) còn chờ địa chỉ, ngày mở, tên miền và chủ quán duyệt chữ mô tả; chưa suy diễn các
thông tin này vào code. Ảnh Open Graph và favicon chưa có, cần ảnh của quán. Bước `P4-10` dựng trang khách phải
render nội dung công khai ở server, không chỉ đợi React Query tải trong trình duyệt.
