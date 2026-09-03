# BA — Kế hoạch ban đầu dự án Bánh cuốn Bà Thanh Cao Bằng

> Giai đoạn BA ban đầu. Mục tiêu là chốt nghiệp vụ và phạm vi ở mức đủ để bước sang System Design.
> Chưa đi vào chi tiết BE, FE, DB, endpoint, component hay cấu trúc source code.

## 1. Mục tiêu BA

Xác định rõ:

- Hệ thống phục vụ những ai.
- Quán bán hàng qua những kênh nào.
- Một đơn hàng đi qua những bước nghiệp vụ nào.
- Tiền được tính, thu và đối soát như thế nào ở mức nghiệp vụ.
- Những quy tắc nào bắt buộc phải luôn đúng.
- Những trường hợp ngoại lệ nào cần xử lý.
- Phạm vi MVP và những thứ chưa làm ở giai đoạn đầu.

---

## 2. Phạm vi nghiệp vụ

### 2.1 Người dùng chính

1. Khách hàng
   - Đặt ship.
   - Đặt trước để tới lấy.
   - Quét QR tại bàn.
   - Gọi điện đặt trước — khách nói, **không tự bấm**; nhân viên nhập hộ.
2. Nhân viên quán
   - Nhận/xác nhận đơn.
   - Đặt món hộ khách.
   - Nhập hộ đơn đặt trước qua điện thoại — khác "Đặt món hộ khách" ở trên (đó là đặt hộ **tại
     quầy**); khi nhận máy phải hỏi: giao tận nơi hay tới lấy, và cần hàng lúc mấy giờ.
   - Thực hiện công việc tại các trạm.
   - Thu tiền.
   - Dọn bàn.
3. Chủ quán
   - Quản lý menu.
   - Quản lý giá và trạng thái bán.
   - Quản lý nhân viên/bàn.
   - Xem báo cáo.

Đơn qua điện thoại là kênh `phone_preorder`; ai duyệt và nhân viên phải hỏi gì lúc nhận máy:
`master_plan/shop-facts.md` §5.2.

### 2.2 Các kênh bán

Quán bán qua **đúng năm kênh, không có kênh thứ sáu**. Tên kênh, ai bấm, kênh nào gắn số bàn
và mỗi kênh khác nhau ở điểm nghiệp vụ nào: `master_plan/shop-facts.md` §2 — nhà duy nhất của
dữ kiện quán (ADR-001). Kế hoạch này là khung, cố ý **không** chép lại bảng kênh.

---

## 3. Ba lát cắt nghiệp vụ chính

Không bắt đầu bằng màn hình hay module. Bắt đầu bằng những luồng có thể chạy từ đầu đến cuối.

### Epic A — Một suất tại bàn

Khách quét QR → chọn món → gửi đơn → quầy xác nhận → các trạm thực hiện → món được mang ra → khách có thể gọi thêm → thu tiền → đóng phiên bàn → dọn bàn → bàn trở lại trạng thái trống.

**Mục tiêu BA:** chứng minh được toàn bộ vòng đời của một khách ăn tại quán.

### Epic B — Một đơn mang đi

Ba kênh không gắn bàn đi chung **một** lát cắt: `delivery`, `pickup`, `phone_preorder`
(`master_plan/shop-facts.md` §5.2).

Khách chọn món trên web, hoặc gọi điện để nhân viên nhập hộ (`phone_preorder`) → nhập thông tin liên hệ cần thiết → đặt hàng → quán nhận thông báo → quầy xác nhận đơn khách tự gửi → chuẩn bị/đóng gói → khách tới lấy hoặc quán giao tận nơi → hoàn thành đơn.

**Mục tiêu BA:** chứng minh được đường đi độc lập của đơn không gắn với bàn.

### Epic C — Chủ quán thay đổi menu/giá

Chủ quán thay đổi menu hoặc giá → đơn mới sử dụng thông tin mới → đơn cũ vẫn giữ nguyên thông tin tại thời điểm đặt.

**Mục tiêu BA:** xác định nguyên tắc lịch sử đơn hàng và tránh thay đổi dữ liệu quá khứ.

---

## 4. Luồng nghiệp vụ cần chốt

### 4.1 Ăn tại bàn

1. Bàn được mở.
2. Khách quét QR hoặc nhân viên đặt hộ.
3. Khách chọn món.
4. Đơn được gửi.
5. Quầy xác nhận.
6. Công việc được phân tới các trạm.
7. Các trạm hoàn thành phần việc.
8. Món được mang ra bàn.
9. Khách có thể gọi thêm.
10. Các lượt gọi tiếp tục thuộc cùng phiên bàn.
11. Quầy tính tổng toàn bộ phiên.
12. Khách thanh toán.
13. Phiên bàn đóng.
14. Bàn được dọn.
15. Bàn trở lại trạng thái sẵn sàng.

### 4.2 Mang đi — `delivery`, `pickup`, `phone_preorder`

1. Khách chọn món trên web (`delivery`, `pickup`), hoặc khách gọi điện và nhân viên nhập hộ (`phone_preorder`).
2. Với `phone_preorder`, nhân viên hỏi ngay lúc nhận máy: giao tận nơi hay khách tới lấy, và cần lúc mấy giờ.
3. Khách cung cấp thông tin liên hệ cần thiết.
4. Hệ thống xác định tổng tiền.
5. Đơn được tạo.
6. Quán nhận thông báo.
7. Quầy xác nhận đơn khách tự gửi; đơn nhân viên nhập hộ không cần bước này.
8. Quán chuẩn bị món và đóng gói.
9. Đơn kết thúc theo một trong hai nhánh — khách tới lấy, hoặc quán giao tận nơi; `phone_preorder` đi nhánh nào là theo câu trả lời ở bước 2.

Chi tiết luồng — ai duyệt, thu tiền lúc nào, bảy điểm khác luồng tại bàn: `master_plan/shop-facts.md` §5.2.

### 4.3 Đặt hộ tại quầy

1. Nhân viên chọn bàn.
2. Nhân viên chọn món.
3. Đơn được tạo vào phiên bàn.
4. Quầy xác nhận ngay.
5. Đơn đi vào quy trình chuẩn bị.
6. Khách tiếp tục gọi thêm nếu cần.

---

## 5. Quy tắc nghiệp vụ cấp cao

Các quy tắc dưới đây phải được chốt ở BA trước khi thiết kế kỹ thuật:

1. Một bàn chỉ có một phiên chưa thanh toán.
2. Nhiều lần gọi món tại cùng bàn thuộc cùng một phiên.
3. Tính tiền trên toàn bộ phiên bàn, không tính thành nhiều hóa đơn riêng.
4. Đơn QR phải được quầy xác nhận trước khi thực hiện.
5. Giá phải được xác định tại thời điểm đặt hàng.
6. Thay đổi menu/giá không được làm thay đổi đơn cũ.
7. Tổ hợp món/option không hợp lệ phải bị từ chối.
8. Đơn mang đi — `delivery`, `pickup`, `phone_preorder` — không sử dụng phiên bàn.
9. Bàn chỉ trở thành trống sau khi phiên được đóng và bàn được dọn.
10. Ngoài giờ bán không nhận đơn.
11. Chủ quán có thể tạm dừng nhận đơn bất kể đang trong giờ bán.
12. Mọi thao tác ảnh hưởng đến tiền hoặc trạng thái đơn phải có thể kiểm chứng lại.

---

## 6. Tiền và giá — chỉ chốt nghiệp vụ

### Giá

- Giá bán được xác định từ menu và các lựa chọn của khách.
- Khách không được tự quyết định giá.
- Tổng tiền phải được xác định lại khi đơn được tạo.
- Đơn cũ phải giữ nguyên giá đã áp dụng.

### Thanh toán

Các phương thức hiện tại:

- Tiền mặt.
- VietQR tĩnh.

Đối với ăn tại bàn:

> Nhiều đơn → một phiên bàn → một lần thanh toán.

Đối với đơn mang đi (`delivery`, `pickup`, `phone_preorder`):

> Mỗi đơn là một đơn vị nghiệp vụ độc lập.

---

## 7. Trạng thái nghiệp vụ cấp cao

Chưa định nghĩa trạng thái kỹ thuật chi tiết; chỉ xác định vòng đời nghiệp vụ.

### Đơn

`Mới → Chờ xác nhận → Đã xác nhận → Đang thực hiện → Hoàn thành`

Có nhánh ngoại lệ:

`→ Hủy`

### Phiên bàn

`Mở → Đang phục vụ → Chờ thanh toán → Đã đóng → Bàn cần dọn → Trống`

### Công việc trạm

`Chưa làm → Đang làm → Hoàn thành`

---

## 8. Ngoại lệ BA cần xử lý

Giai đoạn BA cần thống nhất cách quán xử lý ít nhất các tình huống:

- Khách gửi nhầm đơn QR.
- Quầy từ chối đơn QR.
- Khách gọi thêm sau khi quầy bắt đầu thu tiền.
- Hai người cùng thao tác trên một bàn.
- Món hết sau khi khách đã chọn.
- Chủ quán tạm dừng nhận đơn.
- Khách hủy đơn.
- Nhân viên hủy đơn.
- Thanh toán thất bại hoặc chưa xác nhận được.
- Khách rời bàn nhưng chưa thanh toán.
- Mất mạng trong lúc quán đang phục vụ.
- Mất điện hoặc thiết bị POS gặp sự cố.
- Đơn đã hoàn thành nhưng cần điều chỉnh.
- Nhân viên thao tác nhầm trạng thái.

Ở BA phase chỉ cần chốt **quán muốn xử lý thế nào**; cách hệ thống kỹ thuật thực hiện sẽ thuộc System Design/DB/BE/FE.

---

## 9. Phạm vi MVP

### Làm trong giai đoạn đầu

- Menu và giá.
- Năm kênh bán (`master_plan/shop-facts.md` §2).
- Đặt món.
- Quản lý phiên bàn.
- Xác nhận đơn.
- Điều phối công việc tới các trạm.
- Thu tiền.
- Đóng/dọn bàn.
- Quản lý menu cơ bản.
- Quản lý nhân viên cơ bản.
- Quản lý bàn.
- Báo cáo doanh thu cơ bản.
- Thông báo đơn.
- Cơ chế dự phòng khi realtime không hoạt động.

### Chưa cần chi tiết ở BA phase

- Kiến trúc BE.
- Kiến trúc FE.
- Database schema.
- API endpoint.
- Component UI.
- Docker/CI/CD.
- Cấu trúc package/module.
- Implementation framework.

---

## 10. Quyết định BA cần chốt trước khi sang System Design

Bốn câu — **1, 5, 6, 7** — đã có lời giải trong `master_plan/shop-facts.md` và mang dấu **đã chốt**
ngay tại câu; đọc lời giải ở nguồn, **đừng mở lại thành câu hỏi và đừng biến chúng thành `GIẢ ĐỊNH`**.
Câu 1 chỉ chốt một phần. Sáu câu còn lại vẫn đang mở.

1. Ai có quyền xác nhận, hủy và chỉnh sửa đơn? — *xác nhận* và *hủy* **đã chốt 2026-08-30** → `master_plan/shop-facts.md` §6.2 · §6.13; phần **chỉnh sửa đơn vẫn còn mở**.
2. Đơn đã xác nhận có được sửa hay chỉ được hủy/tạo lại?
3. Khi món hết sau khi khách đặt, quán xử lý thay thế/hủy như thế nào?
4. Khi khách không thanh toán được, phiên bàn giữ ở trạng thái nào?
5. Có cho phép hoàn tiền không, và ai được phép? — **đã chốt 2026-08-30** → `master_plan/shop-facts.md` §6.4.
6. Giờ khách cần hàng có bắt buộc không, và với những kênh nào? — **đã chốt 2026-08-30** → `master_plan/shop-facts.md` §6.5: bắt buộc với **cả `pickup` và `phone_preorder`**, không riêng `pickup`.
7. Delivery hiện chỉ cần ghi nhận đơn hay có quản lý trạng thái giao hàng? — **đã chốt 2026-08-30** → `master_plan/shop-facts.md` §6.7; phạm vi giữ nguyên ở `delivery`, trạng thái "đang giao" chỉ có ở đơn giao tận nơi.
8. Báo cáo doanh thu tính theo ngày nào và xử lý đơn hủy/hoàn tiền ra sao?
9. Chủ quán có được thay đổi giá đang bán ngay lập tức không?
10. Có cần lưu lịch sử thao tác của nhân viên ở MVP không?

Nếu chưa có câu trả lời, ghi thành `GIẢ ĐỊNH` và đánh dấu mức rủi ro; không tự biến giả định thành business truth.

---

# 11. Master Task — BA

| ID | Pha · Tầng | Việc | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì | Trạng thái |
|---|---|---|---|---|---|---|
| BA-01 | 0 · BA | Xác định người dùng và phạm vi hệ thống | — | Danh sách actor + phạm vi được duyệt | Làm sai đối tượng sử dụng | ⬜ |
| BA-02 | 0 · BA | Chốt năm kênh bán và mục tiêu từng kênh | BA-01 | Bảng kênh bán + luồng chính | Sai mô hình bán hàng | ⬜ |
| BA-03 | 0 · BA | Mô tả lát cắt một suất tại bàn | BA-02 | Luồng từ gọi món đến đóng bàn | Thu thiếu tiền hoặc bàn kẹt | ⬜ |
| BA-04 | 0 · BA | Mô tả lát cắt một đơn mang đi — `delivery`, `pickup`, `phone_preorder` | BA-02 | Luồng từ đặt đến hoàn thành | Đơn khách không đi hết quy trình | ⬜ |
| BA-05 | 0 · BA | Mô tả lát cắt thay đổi menu/giá | BA-02 | Luồng trước/sau khi đổi giá | Sai lịch sử đơn cũ | ⬜ |
| BA-06 | 0 · BA | Chốt quy tắc giá và thanh toán | BA-03, BA-04 | Danh sách quy tắc giá/tiền | Thu sai tiền | ⬜ |
| BA-07 | 0 · BA | Chốt vòng đời đơn, phiên bàn và công việc | BA-03 | Sơ đồ trạng thái nghiệp vụ | Đơn hoặc bàn bị kẹt | ⬜ |
| BA-08 | 0 · BA | Chốt các ngoại lệ quan trọng | BA-03–BA-07 | Danh sách tình huống + cách quán xử lý | Sự cố giờ cao điểm | ⬜ |
| BA-09 | 0 · BA | Chốt phạm vi MVP và phần chưa làm | BA-01–BA-08 | Scope được duyệt | Scope creep | ⬜ |
| BA-10 | 0 · BA | Chốt các câu hỏi còn thiếu và giả định | BA-01–BA-09 | Decision/Assumption list | AI tự đoán business truth | ⬜ |
| BA-11 | 0 · BA | Kiểm tra ba lát cắt chạy được từ đầu đến cuối | BA-03–BA-10 | 3 scenario nghiệm thu nghiệp vụ | Thiết kế đẹp nhưng không chạy được | ⬜ |

---

# 12. Cổng chất lượng BA

Chỉ sang System Design khi:

- [ ] Có đủ **năm** kênh bán rõ ràng, đúng tên ở `master_plan/shop-facts.md` §2.
- [ ] Có 3 lát cắt nghiệp vụ từ đầu đến cuối.
- [ ] Có quy tắc giá và tiền.
- [ ] Có vòng đời đơn và phiên bàn.
- [ ] Có các ngoại lệ quan trọng.
- [ ] Có danh sách quyết định chưa rõ/giả định.
- [ ] Không còn business rule quan trọng bị suy đoán.
- [ ] Một người không biết code có thể đọc luồng và giải thích quán phải làm gì.
- [ ] Ba scenario nghiệm thu BA có thể được diễn lại bằng nghiệp vụ:
  - Khách QR tại bàn → gọi nhiều lần → thanh toán một lần.
  - Khách đặt mang đi — `delivery`, `pickup`, `phone_preorder` → quán tiếp nhận (xác nhận với đơn khách tự gửi) → hoàn thành.
  - Chủ quán đổi giá → đơn mới dùng giá mới, đơn cũ không đổi.

> *Ghi chú 2026-08-30 — hai lần sửa cùng ngày, T-007 rồi T-011:*
>
> **T-007 — con số kênh.** §2.2, §9, dòng BA-02 ở §11 và ô đầu của checklist trên đây từng
> ghi con số **bốn**; kênh thứ năm `phone_preorder` được chủ quán chốt **2026-08-24** và sửa tên
> **2026-08-29**, nên cả bốn chỗ đã được sửa thành năm theo `master_plan/shop-facts.md` §2 · §7.1.
>
> **T-011 — luồng của chính kênh đó.** Sửa con số không làm kênh đó có luồng: `phone_preorder`
> vẫn không thuộc lát cắt nào. §3 Epic B, §4.2, dòng BA-04 ở §11, scenario thứ hai của checklist
> trên đây, §5 quy tắc 8 và §6 mục Thanh toán đều chỉ kể `ship/pickup`. Sáu chỗ đó nay nói luồng
> **mang đi** gồm cả ba kênh không gắn bàn, theo `master_plan/shop-facts.md` §5.2 — luồng chủ
> quán chốt **2026-08-30** (`shop-facts.md` §7.1). Số lát cắt không đổi: vẫn ba, Epic B mở rộng
> chứ không sinh Epic D. Vì sao hai lần rà trước không chặn được lần này: `work/findings.md`
> **F-006**.

---

# 13. Rủi ro lớn nhất của BA

**Rủi ro:** đi vào BE/FE/DB quá sớm khi nghiệp vụ chưa chốt.

**Cách chặn:** BA chỉ chốt `ai làm gì → theo luồng nào → quy tắc nào → ngoại lệ nào → tiêu chí nghiệm thu nào`; mọi quyết định về cách code để System Design trở đi.

---

# 14. Đầu ra BA

Sau khi hoàn thành BA, dự án chỉ cần có các tài liệu cấp cao:

- `docs/product/` — nghiệp vụ và phạm vi đã chốt.
- `docs/decisions.md` — các quyết định/giả định quan trọng.
- `work/backlog.md` — master task cấp cao.
- `work/findings.md` — vấn đề/finding nếu phát hiện.
- `quality/invariants.md` — các bất biến quan trọng đã phát hiện ở BA.

Chưa cần tạo tài liệu BE/FE/DB chi tiết.

---

## Nguyên tắc sử dụng bộ khung Lean AI Engineering

Bám theo 6 nguyên tắc của `lear_AI_engerring_system`:

1. One fact, one owner.
2. One task, one outcome.
3. Meaningful change có acceptance criteria.
4. Meaningful change phải được verify.
5. AI không tự phát minh business truth.
6. Ceremony phải tỷ lệ với risk.

BA là **Level 3 — Architectural planning** vì nó quyết định phạm vi, business behavior và các ràng buộc ảnh hưởng toàn hệ thống. Tuy nhiên ở giai đoạn này chỉ cần ceremony đủ để khóa nghiệp vụ; chưa cần triển khai chi tiết kỹ thuật.
