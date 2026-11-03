# Prompt menu vòng cung cho ChatGPT

Ba prompt dùng lần lượt. Prompt 1 tạo ảnh màn hình để duyệt thiết kế. Prompt 2 tách từng món thành ảnh
riêng, vì một ảnh phẳng không vuốt được. Prompt 3 ghép các ảnh đã tách thành menu vuốt được.

Ảnh đính kèm cho prompt 1 và 2, lấy trong `docs/private/anh/`:

- `banh-cuon.png`
- `Vibrant Vietnamese Rice Roll Feast.png`
- `Gemini_Generated_Image_su3m4lsu3m4lsu3m.png`
- `Golden Yolk Bánh Cuốn Feast.png`

Giá theo `master_plan/shop-facts.md` §4.3 và §4.4, cập nhật 2026-10-30.

## Prompt 1 — Ảnh màn hình menu

```text
Hãy tạo một ảnh dọc tỉ lệ 2:3, là toàn bộ màn hình điện thoại của menu gọi món cho quán "Bánh cuốn Bà Thanh Cao Bằng". Ảnh phủ kín khung hình, không vẽ thân điện thoại, không đặt trên nền khác.

Bạn là giám đốc sáng tạo của một studio thiết kế số hàng đầu. Tinh thần: buổi sáng sớm ở một quán bánh cuốn Cao Bằng, ánh nắng thấp xiên từ trái chiếu qua làn hơi nóng mỏng, mặt gỗ sẫm với thớ gỗ rõ, bóng đổ sâu mà mềm. Cảm giác điện ảnh, ấm và ngon miệng, nhưng khách vẫn đọc và bấm được ngay. Không giống mẫu app giao đồ ăn thông thường.

ẢNH THAM CHIẾU
Tôi đính kèm 4 ảnh. Lấy từ đó chất liệu thật của món: bánh cuốn trắng mỏng hơi trong, nhân thịt lộ qua lớp bánh, lòng đỏ trứng cam óng, đĩa sứ trắng, mặt gỗ ấm. Không chép dấu sao mờ ở góc ảnh, không chép các đống nguyên liệu rải trên bàn.

Bốn món trong ảnh này:
1. Bánh cuốn: đúng 1 cái bánh trên đĩa nhỏ. Tham chiếu ảnh banh-cuon.
2. Combo Đầy đủ: 3 cái bánh, 1 quả trứng, 1 chiếc giò trên một đĩa. Tham chiếu ảnh Vibrant Vietnamese Rice Roll Feast.
3. Suất giò: 4 cái bánh và 1 chiếc giò trên một đĩa. Tham chiếu ảnh Gemini_Generated_Image.
4. Suất trứng: 4 cái bánh và 1 quả trứng lòng đỏ óng trên một đĩa. Tham chiếu ảnh Golden Yolk.

Không đặt bát canh, chanh quất, đũa hay thìa cạnh các đĩa, vì suất ăn của quán không kèm sẵn những thứ đó. Số cái bánh phải đếm được và đúng như trên.

BỐ CỤC TỪ TRÊN XUỐNG

Đầu màn hình: tên quán bên trái, biểu tượng giỏ hàng có số 2 bên phải.

Giữa màn hình: một khối thông tin của món đang chọn, nằm giữa theo chiều ngang, chiếm khoảng 45% chiều cao ảnh, nền tối hơi trong trên mặt gỗ, không viền dày. Từ trên xuống gồm:
- Ảnh đĩa Combo Đầy đủ cỡ lớn.
- Tên "Combo Đầy đủ" và giá "30.000đ" cỡ chữ lớn nhất màn hình, giá màu cam #EA6A0C.
- Dòng "3 bánh cuốn · 1 trứng · 1 chiếc giò".
- Hàng lựa chọn "Nhân": Thịt (đang chọn), Thịt + mộc nhĩ, Mộc nhĩ, Chay.
- Hàng lựa chọn "Lượng nhân": Thường (đang chọn), Nhiều nhân.
- Hàng lựa chọn "Trứng": Chín (đang chọn), Tái, Vàng.
- Bộ tăng giảm "− 1 +", nút lớn màu cam "Mua", và nút viền "Xem chi tiết".

Một phần ba dưới màn hình: một chiếc mâm gỗ tròn rất lớn, tâm mâm nằm dưới mép ảnh, nên chỉ thấy phần trên của mâm như một vòng cung cong lên, rộng tràn sát hai mép ảnh. Đúng 4 đĩa món ăn nằm cách đều dọc theo vành mâm: hai đĩa giữa cao hơn, hai đĩa ngoài thấp hơn, tạo đường cong rõ rệt. Thứ tự từ trái sang phải: Bánh cuốn, Combo Đầy đủ, Suất giò, Suất trứng.

Đĩa thứ hai, Combo Đầy đủ, là món đang chọn: lớn hơn các đĩa khác một chút, có vòng sáng cam mảnh quanh đĩa. Bên dưới mỗi đĩa có:
- Tên món.
- Giá.
- Hai nút tròn nhỏ cạnh nhau: nút chữ "i" để xem chi tiết và nút dấu "+" để mua. Riêng nút "+" của Combo Đầy đủ có huy hiệu số 1.

Tên và giá của bốn đĩa:
- Bánh cuốn: 4.000đ
- Combo Đầy đủ: 30.000đ
- Suất giò: 25.000đ
- Suất trứng: 25.000đ

Giữa mâm và khối thông tin có chữ nhỏ "Vuốt để xem món" cùng hai mũi tên mảnh trái phải.

CHỮ VÀ MÀU
Chỉ dùng đúng các chữ tiếng Việt đã ghi trong yêu cầu này, giữ nguyên dấu, không thêm chữ nào khác, không thêm khuyến mãi hay đánh giá sao. Font sans-serif hiện đại, dễ đọc, giống Be Vietnam Pro. Chữ chính #f8fafc, chữ phụ #cbd5e1, điểm nhấn duy nhất là cam #EA6A0C. Mỗi nút phải tách biệt, đủ lớn để bấm bằng ngón tay, chữ không đè lên món ăn.

Không dùng hình 3D kiểu đồ chơi, không glow neon, không gradient tím, không lưới thẻ vuông, không khung điện thoại.
```

## Prompt 2 — Tách ảnh từng món

Gửi trong cùng cuộc trò chuyện sau khi đã ưng ảnh ở prompt 1. Lần đầu dùng khối dưới đây, sau đó gửi lần lượt
từng dòng trong danh sách món, mỗi lần một ảnh.

```text
Dựa đúng phong cách và ánh sáng của ảnh vừa duyệt, hãy tạo riêng từng đĩa món ăn để tôi ghép vào giao diện vuốt được.

Quy cách mỗi ảnh: PNG nền trong suốt, khổ vuông 1024×1024, nhìn thẳng từ trên xuống, đĩa nằm giữa ảnh và chiếm khoảng 85% khung, giữ bóng đổ mềm rất nhẹ dưới đĩa, ánh sáng từ trái. Không chữ, không nút, không vòng sáng, không mặt gỗ, không đũa thìa. Mọi ảnh dùng cùng một kiểu đĩa sứ trắng.

Bắt đầu với: Combo Đầy đủ, gồm đúng 3 cái bánh cuốn, 1 quả trứng, 1 chiếc giò.
```

Danh sách món cần tạo, mỗi dòng một lần gửi:

```text
Bánh cuốn: đúng 1 cái bánh cuốn.
Combo Đầy đủ: đúng 3 cái bánh cuốn, 1 quả trứng, 1 chiếc giò.
Suất giò: đúng 4 cái bánh cuốn, 1 chiếc giò.
Suất trứng: đúng 4 cái bánh cuốn, 1 quả trứng lòng đỏ óng.
Bánh trứng: đúng 1 quả trứng, không có bánh cuốn.
Giò: đúng 1 chiếc giò, không có bánh cuốn.
Canh bánh cuốn: 1 bát canh trong, rau mùi tàu thái nhỏ, không có giò, không có bánh cuốn. Dùng bát sứ trắng thay cho đĩa.
```

Cuối cùng, tạo nền:

```text
Tạo một ảnh dọc 2:3, cùng ánh sáng: mặt gỗ sẫm và chiếc mâm gỗ tròn rất lớn có tâm nằm dưới mép ảnh, chỉ thấy phần trên của mâm như vòng cung cong lên. Không món ăn, không chữ, không nút, không người. Giữ khoảng trống tối và yên ở giữa ảnh để đặt thông tin món.
```

## Prompt 3 — Ghép thành menu vuốt được

Đính kèm tất cả ảnh của prompt 2 và ảnh màn hình đã duyệt.

```text
Bạn là chuyên gia thiết kế chuyển động và lập trình giao diện. Hãy làm bản mẫu menu điện thoại cho "Bánh cuốn Bà Thanh Cao Bằng" theo đúng ảnh màn hình đính kèm, bằng một file HTML duy nhất chứa CSS và JavaScript, không framework, không gọi API, không cần build. Đặt ảnh món vào thư mục anh/ cạnh file, tên file không dấu theo tên món.

Mọi chữ, giá và nút là HTML thật, không nằm trong ảnh. Không dùng ảnh màn hình làm nền; chỉ dùng nó để đối chiếu thiết kế.

CÁCH HOẠT ĐỘNG
- Mâm luôn hiện tối đa 4 món trên vòng cung. Vị trí thứ hai từ trái là món đang chọn, lớn hơn và có vòng sáng cam.
- Vuốt trái thì món kế tiếp vào vị trí đang chọn, vuốt phải thì quay lại. Mỗi lần vuốt dịch đúng một món, các đĩa trượt dọc theo cung và xoay theo mâm. Danh sách lặp vòng. Có thêm nút trước, sau và phím mũi tên trái phải.
- Bấm vào một đĩa thì đĩa đó thành món đang chọn.
- Khối thông tin giữa màn hình đổi theo món đang chọn.
- Nút "i" hoặc "Xem chi tiết" mở màn hình chi tiết của món, có nút quay lại, giữ nguyên vị trí mâm và giỏ.
- Nút "+" trên mâm thêm 1 phần theo lựa chọn mặc định và hiện số lượng trên huy hiệu. Nút "Mua" trong khối thông tin thêm đúng số lượng ở bộ tăng giảm theo lựa chọn đang hiện.
- Vuốt không bao giờ thêm món vào giỏ. Thao tác bấm nút không được kích hoạt vuốt. Cuộn dọc không bị nhận nhầm thành vuốt ngang.
- Cùng món khác lựa chọn là các dòng riêng trong giỏ. Bấm giỏ mở bảng từ dưới lên: tăng, giảm, bỏ từng dòng, tổng tiền. Giỏ trống hiện "Bạn chưa chọn món". Dùng chữ "đã chọn", không báo đã đặt đơn thành công.

DỮ LIỆU MÓN, ĐÚNG THỨ TỰ
Giá gốc là giá nhân Chay. N là số phần nhận nhân.
1. Bánh cuốn: giá gốc 3.000đ, N = 1, gồm 1 cái bánh cuốn.
2. Combo Đầy đủ: giá gốc 26.000đ, N = 4, gồm 3 bánh cuốn, 1 trứng, 1 chiếc giò. Chọn trứng.
3. Suất giò: giá gốc 21.000đ, N = 4, gồm 4 bánh cuốn, 1 chiếc giò.
4. Suất trứng: giá gốc 20.000đ, N = 5, gồm 4 bánh cuốn, 1 trứng. Chọn trứng.
5. Bánh trứng: giá gốc 8.000đ, N = 1, gồm 1 quả trứng. Chọn trứng.
6. Giò: 9.000đ, không có lựa chọn nhân, gồm 1 chiếc giò.
7. Canh bánh cuốn: 0đ, hiển thị "Miễn phí", gồm 1 bát canh. Chỉ có nhóm Rau: Không rau, Ít rau (mặc định), Nhiều rau.

LỰA CHỌN VÀ GIÁ
- Nhân: Thịt (mặc định), Thịt + mộc nhĩ, Mộc nhĩ, Chay.
- Lượng nhân: Thường (mặc định), Nhiều nhân. Ẩn nhóm này khi chọn Chay.
- Trứng: Chín, Tái, Vàng. Bản mẫu chọn sẵn Chín.
- Giá = giá gốc + N × 1.000đ nếu nhân khác Chay + N × 1.000đ nữa nếu Nhiều nhân. Loại nhân và loại trứng không đổi giá.
- Kiểm tra: Bánh cuốn Thịt Thường 4.000đ; Combo Đầy đủ 30.000đ, Nhiều nhân 34.000đ; Suất giò 25.000đ, Chay 21.000đ; Suất trứng 25.000đ, Nhiều nhân 30.000đ.
- Không thêm ưu đãi, phí giao hàng hay món khác.

CHUYỂN ĐỘNG
- Mở màn hình: mâm xoay nhẹ vào vị trí trong 600ms, sau đó khối thông tin hiện dần trong 240ms. Không có màn hình chờ.
- Vuốt: đĩa bám theo ngón tay, khi thả thì về vị trí trong 320ms với cubic-bezier(.22,1,.36,1).
- Đổi món: khối thông tin mờ và trượt nhẹ 8px trong 180ms, đồng bộ với mâm, ảnh và giá đổi cùng lúc.
- Bấm: nút co xuống 0.96 trong 100ms. Thêm món: huy hiệu nảy nhẹ một lần.
- Hơi nóng: một lớp mờ rất nhẹ trên đĩa đang chọn, chỉ chạy khi trang đang hiển thị.
- Chỉ animate transform và opacity. Không parallax, không tự chạy mâm, không hiệu ứng làm chậm thao tác.
- Với prefers-reduced-motion: tắt xoay, hơi nóng và nảy, chỉ đổi món bằng mờ dần 120ms.

YÊU CẦU KỸ THUẬT
- Chạy tốt ở chiều rộng 320, 390, 430px và desktop, không tràn ngang. Máy thấp được cuộn dọc, chữ không nhỏ hơn 12px.
- Mọi vùng bấm tối thiểu 44×44px, có focus bàn phím rõ, có safe area ở đáy.
- Ảnh món có alt, tải sẵn các ảnh kế bên để không nhấp nháy khi vuốt.
- Một nguồn dữ liệu chung cho giá, giỏ và tổng tiền.

Trước khi trả kết quả, tự kiểm tra các giá ở mục Kiểm tra, vuốt hai chiều, lặp vòng, thêm cùng món khác nhân thành hai dòng, tăng, giảm, bỏ và giỏ trống. Trả toàn bộ mã trong một khối mã duy nhất để tôi lưu thành file HTML và mở xem ngay.
```
