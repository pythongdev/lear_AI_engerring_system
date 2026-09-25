Tôi đề xuất **giữ các lớp kiểm soát nghiệp vụ, nhưng giảm số nơi phải cập nhật khi làm một task**. Mục tiêu là: người đọc tìm được nguồn đúng, AI biết giới hạn, kết quả có bằng chứng, và phiên sau tiếp tục được ngay.

Đây là phương án đề xuất; chưa thay đổi quy tắc hiện hành của repo.

### 1. Mỗi loại thông tin chỉ có một nơi cập nhật

| Thành phần | Vai trò sau khi tinh gọn |
|---|---|
| `CLAUDE.md` | Chỉ dẫn ngắn: đọc gì, nhận việc thế nào, điều cấm, kiểm tra và bàn giao |
| `master_plan/` | Mục tiêu từng pha, thứ tự và phụ thuộc; không giữ tiến độ |
| `work/backlog.md` | Nơi duy nhất giữ trạng thái task |
| `work/backlog_DB.md` và các backlog pha | Hồ sơ task: mục tiêu, scope, acceptance, verify, kết quả |
| `docs/product/` | Đặc tả chính thức, tổ chức theo pha như hiện tại |
| `docs/decisions.md` | Những lựa chọn quan trọng và lý do |
| `quality/invariants.md` | Những điều luôn phải đúng |
| `work/findings.md` | Vấn đề có giá trị lâu dài, cần xử lý hoặc phòng ngừa |
| `scripts/` | Kiểm tra tự động |

**Thay đổi quan trọng nhất:** đưa Acceptance và Verify về hồ sơ task. Prompt thực thi chỉ cần yêu cầu AI đọc task đó, không giữ một bản nội dung riêng.

Các prompt có giá trị tái sử dụng vẫn giữ. Prompt chỉ phục vụ một task không cần trở thành một hồ sơ phải duy trì lâu dài.

### 2. Một task chỉ cần một hồ sơ ngắn

Ví dụ cấu trúc:

```markdown
## P2-XX — Tên kết quả cần đạt

Mục tiêu:
Một kết quả cụ thể.

Nguồn:
Liên kết tới nghiệp vụ, quyết định và invariant liên quan.

Phụ thuộc:
Các task hoặc câu trả lời cần có trước.

Phạm vi:
Các file hoặc vùng được sửa.

Nghiệm thu:
- Điều kiện quan sát được.
- Trường hợp cần từ chối hoặc bảo vệ.

Kiểm chứng:
Lệnh hoặc kịch bản dùng để kiểm tra.

Bàn giao:
Kết quả kiểm tra; phần còn thiếu nếu chưa hoàn thành.
```

Trạng thái chỉ nằm trong backlog chính. **Bỏ cột Mở/Đóng và dòng xác nhận hoàn thành ở backlog pha**, vì chúng tạo thêm thao tác đồng bộ.

Kết quả nghiệp vụ hoặc thiết kế vẫn ghi vào owner tương ứng; hồ sơ task dẫn đến kết quả ấy.

### 3. Rút quy trình xuống năm bước

```text
Đọc brief và task
        ↓
Kiểm tra đầu vào, khai báo scope
        ↓
Thực hiện
        ↓
Chạy gate + đối chiếu nghiệm thu
        ↓
Cập nhật trạng thái và bàn giao
```

Trong lúc làm, chỉ phát sinh thêm hồ sơ khi có lý do rõ ràng:

| Tình huống | Hành động |
|---|---|
| Thiếu câu trả lời nghiệp vụ | Ghi unknown; dừng phần phụ thuộc |
| Chọn giữa các phương án có hệ quả lâu dài | Ghi ADR |
| Phát hiện vấn đề đáng phòng ngừa về sau | Ghi finding |
| Lỗi nhỏ sửa ngay trong phạm vi task | Sửa và kiểm tra, không cần thêm hồ sơ |

Như vậy, **ADR và finding là công cụ giải quyết vấn đề, không phải thủ tục kết thúc mỗi task**.

### 4. Giữ mức kiểm soát theo rủi ro, giảm thủ tục cho việc nhỏ

Giữ L0–L3 để tránh phải thay đổi toàn bộ hệ thống phân loại:

| Mức | Yêu cầu |
|---|---|
| L0 | Sửa, kiểm tra phù hợp, báo kết quả |
| L1 | Hồ sơ task ngắn, scope, acceptance, gate |
| L2 | Thêm invariant liên quan và bằng chứng kiểm tra hành vi |
| L3 | Review thiết kế trước; chia thành task L1/L2 |

Với sửa tài liệu giải thích không thay đổi quy định, dùng luồng nhẹ. Với thay đổi tiền, quyền, dữ liệu hoặc hợp đồng, vẫn phải kiểm chứng chặt dù chỉ sửa một dòng.

### 5. Làm cho gate rõ nghĩa hơn

Giữ một lệnh vào duy nhất:

```bash
./scripts/gate.sh
```

Nhưng báo cáo nên phân biệt rõ:

- **PASS:** đã kiểm tra và đạt.
- **FAIL:** có lỗi phải sửa.
- **SKIP:** không áp dụng hoặc chưa có kiểm tra tương ứng.
- **NOTE:** thông tin cần đọc, không tự chứng minh có lỗi.

Ưu tiên kiểm tra phạm vi thay đổi, liên kết, trạng thái mâu thuẫn, ranh giới pha và test liên quan. Không viết thêm gate chỉ để bảo vệ một thông tin có thể bỏ khỏi hệ thống.

**Gate xanh không đồng nghĩa task hoàn thành.** Task chỉ Done khi acceptance có bằng chứng và phần thiếu được xử lý hoặc ghi nhận đúng phạm vi.

### 6. Xử lý scope như trạng thái tạm thời

`scope.txt` hiện dễ bị mắc kẹt giữa “đã làm xong” và “chưa commit”. Nên tách hai khái niệm:

- **Scope:** phạm vi của công việc đang thực hiện.
- **Thay đổi chưa commit:** trạng thái do Git cung cấp.

Task hoàn thành thì gỡ scope của task. Không giữ scope chỉ để nhắc chờ commit; brief có thể đọc Git để báo việc chưa commit.

Nếu thường xuyên có nhiều phiên AI làm đồng thời, dùng **worktree riêng cho mỗi task**. Nếu làm tuần tự, giữ một scope đơn giản là đủ. Không cần xây cơ chế phối hợp nhiều phiên vào mọi lượt làm việc.

### 7. Triển khai từng bước, không viết lại toàn bộ repo

Tôi đề xuất thứ tự:

1. **Rút gọn `CLAUDE.md`:** giữ luật đang có, chuyển giải thích lịch sử sang nơi tra cứu.
2. **Thí điểm hồ sơ task gọn với một task mới:** chưa chuyển hàng loạt backlog cũ.
3. **Đổi prompt thành điểm vào task**, bỏ các trường trạng thái trùng lặp.
4. **Sửa vòng đời scope và brief**, kiểm tra việc bàn giao qua một phiên mới.
5. Sau vài task, đánh giá rồi mới áp dụng rộng.

Đo hiệu quả bằng ba câu hỏi: một task phải cập nhật bao nhiêu nơi, phiên mới mất bao lâu để xác định việc tiếp theo, và có bao nhiêu lỗi do tài liệu lệch nhau. Việc tinh gọn đạt yêu cầu khi các chi phí này giảm mà bằng chứng nghiệm thu vẫn đầy đủ.

**Ưu tiên đầu tiên nên là “một hồ sơ thực thi cho mỗi task, một nơi giữ trạng thái”.** Đây là thay đổi giảm nhiều thao tác nhất mà vẫn giữ được kỷ luật nghiệp vụ và kiểm chứng.