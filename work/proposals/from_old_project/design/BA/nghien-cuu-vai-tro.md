# BA làm gì trong một dự án full-stack — bản tra cứu ngoài repo

> Cập nhật **2026-08-19** · Lane sở hữu: **NON-CODE** (thư mục `design/BA/` chưa được khai vào
> bảng lane ở [CLAUDE.md §1](../../CLAUDE.md) — đó là việc owner chốt, xem mục 6).
> **File này không giữ sự thật nào về dự án.** Nó giữ đúng một thứ chưa có nhà ở đâu khác:
> **vai trò BA theo chuẩn ngoài** (BABOK/IIBA + mô tả công việc thực tế), và **chỗ nào của vai trò
> đó repo này đã có người làm rồi**. Mọi con số / phạm vi / giá của quán nằm ở
> [project_preparation/00-scope.md](../../project_preparation/00-scope.md) — ở đây chỉ đặt link.

## 1. Định nghĩa gọn

BA (Business Analyst — *chuyên viên phân tích nghiệp vụ*) là người **biến nhu cầu kinh doanh thành
yêu cầu kiểm chứng được**, rồi giữ cho yêu cầu đó không trôi trong suốt vòng đời sản phẩm.
BA **không** sở hữu quyết định sản phẩm (đó là Product Owner / owner), **không** viết code, và
**không** thay QA ký nghiệm thu — BA cung cấp *cơ sở* để ba bên kia quyết được.

Ranh giới hay bị nhầm nhất — BA ↔ PO: PO hướng ra ngoài (khách hàng, ROI, thứ tự ưu tiên, quyền
quyết định); BA hướng vào trong (chi tiết hằng ngày, đặc tả, truy vết). Nhiều nơi một người kiêm cả
hai; khi tách, BA thường đóng vai *proxy PO* cho đội dev.

## 2. Sáu nhóm việc chuẩn (BABOK v3, 30 task)

Đây là khung nghề nghiệp chính thức của IIBA — dùng làm **danh sách kiểm**, không phải quy trình
bắt buộc chạy đủ:

| # | Nhóm (Knowledge Area) | Task | Câu hỏi nhóm này trả lời |
|---|------------------------|------|--------------------------|
| 3 | Business Analysis Planning & Monitoring | 3.1 Plan BA Approach · 3.2 Plan Stakeholder Engagement · 3.3 Plan BA Governance · 3.4 Plan BA Information Management · 3.5 Identify BA Performance Improvements | Lần này phân tích theo cách nào, ai duyệt, tài liệu để đâu |
| 4 | Elicitation & Collaboration | 4.1 Prepare for Elicitation · 4.2 Conduct Elicitation · 4.3 Confirm Elicitation Results · 4.4 Communicate BA Information · 4.5 Manage Stakeholder Collaboration | Moi yêu cầu ra từ ai, bằng cách gì, xác nhận lại thế nào |
| 5 | Requirements Life Cycle Management | 5.1 Trace · 5.2 Maintain · 5.3 Prioritize · 5.4 Assess Changes · 5.5 Approve Requirements | Một yêu cầu đổi thì cái gì gãy theo, ai được duyệt đổi |
| 6 | Strategy Analysis | 6.1 Analyze Current State · 6.2 Define Future State · 6.3 Assess Risks · 6.4 Define Change Strategy | Đang thế nào → muốn thành thế nào → rủi ro gì |
| 7 | Requirements Analysis & Design Definition | 7.1 Specify & Model · 7.2 Verify · 7.3 Validate · 7.4 Define Requirements Architecture · 7.5 Define Design Options · 7.6 Analyze Value & Recommend Solution | Viết yêu cầu ra thành mô hình đọc được, kiểm nó đúng và đáng làm |
| 8 | Solution Evaluation | 8.1 Measure Solution Performance · 8.2 Analyze Performance Measures · 8.3 Assess Solution Limitations · 8.4 Assess Enterprise Limitations · 8.5 Recommend Actions | Làm xong rồi có ăn thua không, chặn ở đâu |

Hai chữ hay bị dùng lẫn, BABOK tách rõ:
**Verify** = yêu cầu *viết có đủ chất lượng không* (rõ, không nhập nhằng, test được).
**Validate** = yêu cầu đó *có mang lại giá trị kinh doanh không* (đúng thứ cần làm).
Một yêu cầu viết rất đẹp cho một tính năng không ai dùng: verify đạt, validate trượt.

## 3. BA làm gì ở từng giai đoạn của dự án full-stack

| Giai đoạn | BA làm | Đầu ra để lại |
|-----------|--------|----------------|
| Khởi động | Xác định nhu cầu, khảo sát khả thi, viết business case, gom bên liên quan | Phạm vi + lý do làm, danh sách bên liên quan |
| Phân tích | Phỏng vấn / workshop, vẽ quy trình hiện tại (BPMN, flow), viết yêu cầu, xếp ưu tiên | BRD / SRS, danh sách yêu cầu đã xếp hạng, luật nghiệp vụ |
| Thiết kế | Ngồi với kiến trúc sư + designer, soi thiết kế **ngược lại** yêu cầu | Ma trận truy vết (RTM), biên bản đối chiếu thiết kế |
| Lập trình | Trả lời câu hỏi của dev, quản lý thay đổi yêu cầu, giữ hai đầu business ↔ kỹ thuật nói cùng thứ tiếng | Ghi chú làm rõ, hồ sơ đổi yêu cầu |
| Kiểm thử | Soi phần mềm ngược yêu cầu, dựng kịch bản đúng đời thật, chạy UAT | Kịch bản test / tiêu chí chấp nhận, báo cáo UAT |
| Triển khai | Kế hoạch go-live, tài liệu + đào tạo người dùng, thu phản hồi | Tài liệu hướng dẫn, kế hoạch triển khai |
| Vận hành | Theo dõi số liệu, gom phản hồi, đề xuất cải tiến, xếp ưu tiên vòng sau | Báo cáo hiệu quả, danh sách cải tiến |

Riêng với **full-stack**, phần việc BA nặng nhất nằm ở **mối nối**, đúng chỗ
[CLAUDE.md §8](../../CLAUDE.md) gọi là "chỗ hỏng nhất":

- **Nghiệp vụ ↔ DB:** một khái niệm nghiệp vụ ("phiên bàn", "món có nhân") phải ra được thực thể
  + ràng buộc, không để hai bên gọi cùng một thứ bằng hai tên.
- **Nghiệp vụ ↔ API:** mỗi luật tính tiền / chuyển trạng thái phải chỉ được ra **một** endpoint hoặc
  một hàm chịu trách nhiệm — nếu không, luật sẽ mọc bản sao ở FE.
- **Nghiệp vụ ↔ UI:** mỗi màn hình phải trả lời được "user story nào", "ai bấm", "sai thì hiện gì".
- **Nghiệp vụ ↔ vận hành:** giờ mở cửa, tồn kho, ca làm, quyền nhân viên — thứ không lộ ra ở UI
  nhưng quyết định phần lớn ca lỗi.

## 4. Bộ tài liệu BA thường đẻ ra

| Tài liệu | Trả lời | Ai đọc |
|----------|---------|--------|
| **BRD** (Business Requirement Document) | Cần gì, **vì sao** cần — mức cao, khách ký duyệt | Owner, khách |
| **SRS / FRD** | Hệ thống phải **làm gì**: chức năng + phi chức năng + use case | Dev, QA |
| **Use case / User story** | Ai làm gì để được gì (`Là <vai>, tôi muốn <X>, để <Y>`) | Dev, QA |
| **Acceptance Criteria** | Điều kiện **test được** để coi là xong | QA, dev |
| **Business rules** | Luật không được phá, độc lập với màn hình | Cả đội |
| **Process flow / BPMN** | Luồng nghiệp vụ, chỗ rẽ nhánh, chỗ hỏng | Cả đội |
| **Wireframe** | Bố cục thô để chốt luồng trước khi vẽ đẹp | FE, owner |
| **RTM** (Requirements Traceability Matrix) | Yêu cầu ↔ thiết kế ↔ code ↔ test, **hai chiều** | BA, QA |

RTM là thứ dễ bỏ nhất và đắt nhất khi thiếu: không có truy vết hai chiều thì không trả lời được
"yêu cầu này đã code chưa" lẫn "đổi chỗ này thì gãy yêu cầu nào".

## 5. Chiếu vào repo này — phần lớn vai trò BA **đã có nhà**

Đây là lý do không nên bê nguyên bộ tài liệu BA vào đây ([CLAUDE.md §2.1](../../CLAUDE.md): chép =
đẻ nhà thứ hai):

| Việc của BA | Repo này đã để ở đâu |
|-------------|----------------------|
| BRD — phạm vi, giá, kênh bán đã chốt | [project_preparation/00-scope.md](../../project_preparation/00-scope.md) |
| Business rules không được phá | [README.md](../../README.md) + `02-luat.md` của từng lane |
| SRS — hệ thống phải làm gì, xây thế nào | [step.md](../../step.md) + `01-thiet-ke.md` của từng lane |
| Acceptance criteria | cột *Đầu ra kiểm chứng được* trong [task.md](../../task.md) + biên nhận lane ([§1](../../CLAUDE.md)) |
| Xếp ưu tiên, thứ tự làm | [task.md](../../task.md) (🔺, đường găng, `⚑n`) |
| Assess changes / cái gì đang sai | [finding.md](../../finding.md) |
| Truy vết yêu cầu ↔ hiện thực | mục *Đối chiếu finding → task* cuối [task.md](../../task.md) + `03-hien-trang.md` từng lane |
| Hợp đồng giữa hai lane | `code/be/api/openapi.yaml`, migration + test tích hợp ([§8](../../CLAUDE.md)) |

**Ba khoảng trống thật sự chưa có nhà** — đây mới là chỗ một lane BA đáng tồn tại:

1. **Quy trình nghiệp vụ ngoài phần mềm**: một đơn đi từ lúc khách quét QR tới lúc bưng ra bàn và
   thu tiền, gồm cả bước con người làm (bếp, quầy, ca sáng). Repo hiện chỉ mô tả phần máy chạy.
2. **Vai + quyền**: ai được huỷ đơn, ai sửa giá, ai đóng phiên bàn — rải rác trong luật lane, chưa
   có một bảng vai × hành động.
3. **Đo sau khi chạy** (BABOK nhóm 8): chưa có định nghĩa "chạy tốt nghĩa là gì" — thời gian từ đặt
   tới xong, tỷ lệ đơn lỗi, số lần phải đặt hộ vì QR không dùng được.

## 6. Câu chưa chốt (owner quyết)

`design/BA/` hiện là thư mục rỗng, **chưa** có tên trong bảng lane ở [CLAUDE.md §1](../../CLAUDE.md).
Đây là *chưa có X* nên theo [§7](../../CLAUDE.md) nó là **task, không phải finding**. Ba đường:

- **(a)** BA không thành lane — ba khoảng trống ở mục 5 chia về `00-scope.md` (quy trình + vai/quyền)
  và `quality/` (thước đo). Rẻ nhất, không thêm nhà mới.
- **(b)** BA thành lane NON-CODE con, đủ bộ `01`–`04` như ba lane kia, biên nhận = lệnh đọc lại ([§8](../../CLAUDE.md)).
- **(c)** Giữ đúng file này làm bản tra cứu, chưa mở lane, đến khi có việc BA thật sự.

Kế hoạch 12 bước để đi hết phần việc BA (kèm biên nhận từng bước): [ke-hoach.md](ke-hoach.md).

## Nguồn

- [IIBA — BABOK Guide, danh sách task theo 6 knowledge area](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/tasks/)
- [IIBA — Requirements Analysis and Design Definition](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/7-requirements-analysis-and-design-definition/)
- [IIBA — Requirements Life Cycle Management (truy vết, ưu tiên, duyệt đổi)](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/5-requirements-life-cycle-management/)
- [IIBA — Elicitation and Collaboration](https://www.iiba.org/knowledgehub/business-analysis-body-of-knowledge-babok-guide/4-elicitation-and-collaboration/)
- [IIBA — Product Owner vs. Business Analyst](https://www.iiba.org/business-analysis-blogs/product-owner-vs-business-analyst/)
- [Scale Factory — Vai trò BA theo từng giai đoạn SDLC](https://scalefactory.com/explained-the-role-of-a-business-analyst-in-the-software-development-lifecycle/)
- [Softermii — BA trong phát triển phần mềm](https://www.softermii.com/blog/business-analyst-in-it)
- [Apriorit — BA roles & responsibilities in software development](https://www.apriorit.com/white-papers/387-outsourcing-business-analyst)
- [thebusinessanalystjobdescription.com — BRD vs SRS vs FRS](https://thebusinessanalystjobdescription.com/brd-vs-srs-vs-frs-detailed-comparison/)
- [BACs.vn — Tổng hợp các loại tài liệu BA cần chuẩn bị (tiếng Việt)](https://www.bacs.vn/vi/blog/nghe-nghiep/tong-hop-cac-loai-tai-lieu-business-analyst-can-chuan-bi-34197.html)
- [BACs.vn — 10 trách nhiệm hàng đầu của một Business Analyst (tiếng Việt)](https://www.bacs.vn/vi/blog/ky-nang/10-trach-nhiem-hang-dau-cua-mot-business-analyst-nha-phan-tich-nghiep-vu-1868.html)
