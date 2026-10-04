# Danh sách tính năng backend

Tổng hợp ngày **2026-10-05** bởi Codex theo yêu cầu chủ repo, từ
[backlog BE](../../../work/backlog_BE.md) và [backlog chung](../../../work/backlog.md).
Đây là bản tra cứu theo tính năng, không phải hợp đồng API hay nơi giữ luật nghiệp vụ.
Khi có khác biệt, đọc nguồn được dẫn ở từng nhóm và owner được nguồn chỉ tới.

**Cách đọc:** “Có trong kế hoạch” nghĩa là backlog mô tả việc cần xây dựng, không có nghĩa
BE đã chạy. Tại thời điểm đọc, backlog BE ghi pha 3 chờ chữ ký chuyển pha; backlog chung
chưa ghi bước P3 nào Done. Các task BA/DB Done chỉ chứng minh phần luật/lược đồ tương ứng.
Danh sách dưới đây bao phủ nội dung nhìn thấy trong hai backlog; những entry chỉ có tiêu đề
lịch sử hoặc dẫn sang sổ khác không đủ để suy ra toàn bộ thao tác chi tiết.

## 1. Đăng nhập, danh tính và quyền truy cập

Nguồn: [bước danh tính và quyền](../../../work/backlog_BE.md#p3-05),
[bước vết sửa và trực quầy](../../../work/backlog_BE.md#p3-11).

| Tính năng | Nội dung / mức xác nhận từ nguồn |
|---|---|
| Đăng nhập nhân viên (login) | Có trong kế hoạch. Cách đăng nhập còn phải làm rõ khi nhận bước; không suy ra mật khẩu, PIN hay OTP. |
| Đăng xuất (logout) | Ví dụ chủ repo yêu cầu đưa vào danh sách; hai backlog chưa mô tả cơ chế hay nghiệm thu. Cần làm rõ cùng phần đăng nhập. |
| Kiểm tra quyền thao tác | Dựa vào chỗ đứng tại thời điểm bấm; có ma trận vai × thao tác. |
| Chặn thao tác quầy của người không đứng quầy | Có trong kế hoạch, kiểm qua cửa BE. |
| Ghi nhận người thực hiện thao tác tiền | Mỗi thao tác chạm tiền phải truy được ai bấm. |
| Khách truy cập bàn bằng QR | Dùng mã QR hiện hành, giới hạn đúng bàn; từ chối mã cũ hoặc truy cập bàn khác. |
| Đổi mã QR bàn | Có cửa đổi mã QR của chủ quán trong kế hoạch. |
| Bắt đầu / kết thúc khoảng trực quầy | Ghi mốc đổi người đứng quầy; đây là nghiệp vụ trực quầy, không đồng nghĩa login/logout. |

## 2. Menu và tính giá

Nguồn: [bước menu và giá](../../../work/backlog_BE.md#p3-06).

| Tính năng | Nội dung trong kế hoạch |
|---|---|
| Quản lý menu của chủ quán | Sửa thành phần menu theo luật nguồn; không tự định nghĩa thêm bộ thao tác CRUD. |
| Tính thử giá đơn | Dùng cùng hàm tính giá với lúc ghi đơn. |
| Tính giá khi đặt món | BE tự tính; bỏ giá do phía khách gửi lên. |
| Kiểm tra tổ hợp món / suất | Từ chối tổ hợp cấm, không tự sửa hộ. |
| Lưu giá tại thời điểm đặt | Đổi menu/giá sau đó không làm đổi đơn cũ. |
| Chặn đặt món ngừng bán | Kiểm tra tại cửa BE. |
| Kiểm soát thay đổi thành phần trong giờ bán | Không âm thầm áp thay đổi trái luật. |
| Thay đổi giá trong giờ bán | Backlog chung có lịch sử chốt khả năng đổi giá; chi tiết đọc owner mà bước menu dẫn tới. |

## 3. Bàn, phiên ăn và gọi món

Nguồn: [bước luồng tại bàn](../../../work/backlog_BE.md#p3-07).
Lịch sử ghép bàn và huỷ đơn được ghi ở [backlog chung](../../../work/backlog.md#done)
qua các việc chốt ghép bàn, quyền huỷ và vòng đời.

| Tính năng | Nội dung / giới hạn |
|---|---|
| Mở phiên ăn tại bàn | Mở phiên theo ràng buộc của bàn. |
| Khách gọi món qua QR | Lượt gọi ở trạng thái chờ duyệt. |
| Nhân viên đặt món hộ khách | Có trong luồng tại bàn. |
| Duyệt đơn | Cho lượt gọi đi tiếp theo vòng đời đã chốt. |
| Gọi suất đem về trong phiên tại bàn | Xử lý suất đem về gắn với phiên. |
| Chuyển trạng thái đơn | Tuân thủ bảng chuyển trạng thái ở nguồn nghiệp vụ. |
| Huỷ đơn | Backlog chung ghi quyền huỷ gắn với người đứng quầy; không tự thêm quyền cho vai khác. |
| Ghép bàn | Backlog chung ghi một phiên, một hoá đơn; chi tiết thao tác BE chưa được entry P3-07 tách riêng. |
| Đóng phiên ăn | Thực hiện nguyên tử, không để nửa giao dịch sống. |
| Dọn bàn | Có trong luồng tại bàn. |
| Chống tạo đơn trùng khi gửi lại | Cùng dấu lần gửi không nhân đôi đơn; cùng dấu nhưng khác nội dung bị từ chối. |

## 4. Đơn mang đi, giao hàng và đặt trước

Nguồn: [bước các kênh ngoài bàn](../../../work/backlog_BE.md#p3-08).

| Tính năng | Nội dung / giới hạn |
|---|---|
| Tạo đơn độc lập ngoài bàn | Phủ các kênh ngoài bàn theo nguồn kênh bán mà backlog dẫn tới. |
| Nhận đơn mang đi | Có trong nhóm luồng ngoài bàn. |
| Nhận đơn giao hàng | Có trong nhóm luồng ngoài bàn. |
| Nhập đơn đặt trước qua điện thoại | Nhân viên nhập hộ theo lịch sử kênh bán ở backlog chung. |
| Kiểm tra thông tin liên hệ | Đủ mức liên hệ tối thiểu của từng kênh. |
| Kiểm tra giờ nhận đơn | Chặn tạo đơn ngoài giờ bán, dùng nguồn thời gian của hệ thống. |
| Tạm dừng / mở lại nhận đơn | Kiểm tra khoảng tạm dừng; backlog chung ghi phần dữ liệu đã dựng ở việc ngừng nhận đơn. |
| Chống gửi lại thành nhiều đơn | Áp dụng dấu lần gửi cho đơn ngoài bàn. |
| Theo dõi vòng đời đơn ngoài bàn | Mỗi kênh phải đi hết vòng đời; mốc “đã ra bàn” của đơn giao còn chờ lời giải được dẫn trong entry. |

## 5. Thanh toán, nợ và đối soát

Nguồn: [bước đường tiền](../../../work/backlog_BE.md#p3-09),
[backlog chung](../../../work/backlog.md#in-progress) cho việc cất số tiền đếm cuối ngày,
và [lịch sử đã xong](../../../work/backlog.md#done) cho dữ liệu trả nợ dần.

| Tính năng | Nội dung / giới hạn |
|---|---|
| Thu tiền đơn hàng | Thao tác có người thực hiện. |
| Thanh toán chia nhiều phương thức | Một đơn có thể thu bằng nhiều phương thức theo luật nguồn. |
| Thu tiền trả trước | Có trong kế hoạch đường tiền. |
| Ghi nợ khách hàng | Ghi nhận phần nợ theo nguồn nghiệp vụ. |
| Thu nợ | Không ghi thành doanh thu bán mới. |
| Thu nợ trả dần | Dùng chuỗi lần trả với số còn thiếu trước/sau; phần lược đồ đã có task Done. |
| Hoàn tiền | Có trong kế hoạch đường tiền. |
| Ghi tiền đầu két | Có trong kế hoạch đường tiền. |
| Giảm giá cả đơn | Còn chờ câu hỏi giảm giá được dẫn ở entry; phần bị chặn phải từ chối kèm mã. |
| Đối soát cuối ngày | Gọi bộ truy vấn đối chiếu, kiểm số chênh lệch tiền. |
| Ghi số tiền mặt đếm cuối ngày | Backlog chung đang có task In Progress dựng chỗ cất; chưa được coi là BE hoàn thành. |
| Ghi nhận ngày đã đối soát xong | Cùng task In Progress về số tiền đếm cuối ngày. |
| Truy nguồn thao tác gây lệch | Gắn người thực hiện và đối chiếu các đường tiền. |

## 6. Sản xuất, việc trạm và phục vụ

Nguồn: [bước sản xuất theo mẻ](../../../work/backlog_BE.md#p3-10),
[bước realtime](../../../work/backlog_BE.md#p3-12),
[backlog chung](../../../work/backlog.md#done) cho dữ liệu ghi chú bánh làm sai.

| Tính năng | Nội dung / giới hạn |
|---|---|
| Sinh việc trạm khi duyệt đơn | Duyệt đơn và sinh đủ việc trạm trong cùng giao dịch. |
| Ghi tiến độ sản xuất theo mẻ | Một lần bấm là một mẻ, POS ghi tiến độ. |
| Cung cấp việc cho ba trạm bếp | Trạm chỉ đọc, không có cửa ghi. |
| Ghi phần đã làm / đã phục vụ | POS ghi; phần chia về bàn phải khớp hai chiều. |
| Phân bổ về từng bàn | Không phục vụ vượt số đã gọi. |
| Ghi “đã bưng” | Đơn vị của lần bấm còn chờ lời giải được dẫn trong entry. |
| Ghi chú bánh làm sai của đơn huỷ | Dùng phần dữ liệu đã dựng; người đứng quầy quyết phần không bàn nào chờ. |
| Huỷ ghi chú bánh làm sai | Ghi nhầm có thể huỷ tại chỗ, giữ dòng và vết. |
| Cấp dữ liệu bảng quầy | Backlog chung ghi bảng quầy có bốn con số; phải đọc owner được dẫn để biết ý nghĩa, không suy ra công thức tại đây. |

## 7. Lịch sử sửa, nhập bù và kết nối

Nguồn: [bước vết sửa](../../../work/backlog_BE.md#p3-11),
[bước realtime và dự phòng](../../../work/backlog_BE.md#p3-12).

| Tính năng | Nội dung trong kế hoạch |
|---|---|
| Lưu lịch sử cập nhật | Có người sửa, lý do, bản trước và bản sau. |
| Từ chối sửa thiếu lý do | Bật chế độ vết nghiêm trong lượt triển khai được chỉ định. |
| Xử lý vết khi thêm dòng con | Entry yêu cầu xử lý khoảng thiếu vết này; cách làm do lead chọn khi triển khai. |
| Nhập bù lượt bán từ sổ giấy | Giữ hai mốc theo yêu cầu mà backlog dẫn tới. |
| Đẩy việc mới tới trạm | Không cần tải lại để nhận việc mới. |
| Báo đơn mới cho quầy | Có thông báo qua đường realtime. |
| Chặn tạo đơn khi quán mất kết nối | Kiểm phần mất kết nối của luật nhận đơn. |
| Ghi khoảng quán mất khả năng quan sát | Backlog chung ghi đã có dữ liệu cho khoảng “quán đang mù”. |
| Khôi phục trạng thái đọc sau nối lại | Bắt lại trạng thái mà không mất việc. |
| Chạy đường dự phòng khi phụ thuộc ngoài lỗi | Từng phụ thuộc phải được cắt thử theo đường suy giảm đã viết. |

## 8. Nhóm quản trị có dấu vết trong backlog chung

**Các mục này ngoài kế hoạch BE pha 3 hiện tại.** Backlog chung chứng minh phần luật hoặc
lược đồ được nêu dưới đây, chưa chứng minh có API quản trị. Danh sách chỉ giữ mức chi tiết
có trong hai nguồn người dùng chỉ định; muốn phân rã thêm cần đọc sổ admin và owner tương ứng.

Nguồn: [lịch sử các lát admin](../../../work/backlog.md#done),
[lát khoản chi đang chờ](../../../work/backlog.md#ready),
[ranh giới lane admin](../../../work/backlog.md#adm-53).

| Nhóm tính năng | Nội dung thấy trong backlog / giới hạn |
|---|---|
| Danh mục nguyên liệu | Có danh mục và tên nguyên liệu; thao tác BE chưa mô tả trong backlog pha 3. |
| Sổ nguyên liệu theo ngày | Ghi con số do người nhập, ngày và thời điểm; tổng/hiệu số tính khi đọc. |
| Theo dõi nguyên liệu thiếu | Backlog chung ghi phần thiếu do người khai, không có ngưỡng để máy tự suy ra. |
| Chấm công theo ngày | Một ô có đi làm cho mỗi người mỗi ngày, có người tick và thời điểm. |
| Huỷ chấm công tick nhầm | Giữ dòng huỷ để kiểm, có thể tick lại; quyền huỷ và tính bắt buộc của ghi chú còn cần đọc câu hỏi ở owner. |
| Ghi tạm ứng nhân viên | Có người nhận, số tiền, ngày, người ghi và người duyệt bắt buộc trong lát dữ liệu. |
| Ghi thưởng | Có người nhận, số tiền, ngày và người ghi trong lát dữ liệu. |
| Quản lý khoản chi ngoài tiền hàng và lương | Phân loại và nguồn tiền; lát dữ liệu còn chờ duyệt thiết kế và câu hỏi về ngày bán của két. |
| Tổng quan quản trị nguyên liệu, con người, tài chính | Ba mảng nằm trong phạm vi theo lịch sử backlog; không đủ mô tả để khẳng định công thức báo cáo hoặc API. |

## 9. Năng lực kỹ thuật hỗ trợ tính năng

Đây là công việc nền và nghiệm thu, không phải thao tác người dùng độc lập.

| Năng lực | Nguồn |
|---|---|
| Xác định ranh giới tầng nghiệp vụ, cửa ghi và cách dịch lời từ chối DB | [Bước ranh giới BE](../../../work/backlog_BE.md#p3-01) |
| Kiểm tra tài liệu BE không viết hộ FE | [Bước cổng ranh giới pha](../../../work/backlog_BE.md#p3-02) |
| Khung Go, kết nối PostgreSQL, múi giờ, vai DB và test thật | [Bước quy ước code BE](../../../work/backlog_BE.md#p3-03) |
| Khuôn hợp đồng API, định dạng tiền/thời gian, mã lỗi và phiên bản | [Bước hợp đồng API](../../../work/backlog_BE.md#p3-04) |
| Nghiệm thu scenario qua API và bằng chứng cho cổng pha 3 | [Bước cổng chất lượng](../../../work/backlog_BE.md#p3-13) |
| Rà ranh giới pha và con trỏ trước bàn giao | [Bước rà cuối pha](../../../work/backlog_BE.md#p3-14) |
| Sao lưu và khôi phục dữ liệu | [Backlog Ready](../../../work/backlog.md#ready): công việc vận hành chờ pha 5, không thuộc lát BE pha 3. |

## 10. Những mục chưa đủ nguồn để coi là feature đã chốt

Đăng xuất được liệt kê vì chủ repo nêu ví dụ; hai backlog chưa mô tả hành vi. Tương tự,
không tự thêm đăng ký tài khoản, quên/đổi mật khẩu, refresh token, CRUD nhân viên,
tính lương tự động, quản lý kho tự động, khuyến mại hay tích hợp cổng thanh toán.
Không có mô tả ở hai backlog không có nghĩa các mục này bị loại khỏi sản phẩm;
chỉ có nghĩa bản tổng hợp hiện tại chưa có bằng chứng để xác nhận chúng.
