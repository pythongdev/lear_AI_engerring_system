# Cấu trúc monolith Go — bản tra cứu ngoài repo + phương án đã loại

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** ([CLAUDE.md §1](../../CLAUDE.md)).
> **File này không giữ luật nào của dự án.** Luật đã chốt nằm ở
> [01-thiet-ke.md §3.0](01-thiet-ke.md) (cấu trúc) và [§3.9](01-thiet-ke.md) (computer vision);
> ràng buộc khi làm việc ở [04-yeu-cau.md](04-yeu-cau.md). **Lệch ⇒ hai file kia thắng.**
>
> Nó giữ đúng hai thứ chưa có nhà ở đâu khác:
> **(a) bằng chứng ngoài repo** cho hai quyết định ngày 2026-08-18, và
> **(b) các phương án đã cân nhắc rồi loại, kèm lý do loại** — thứ mà sáu tháng nữa
> sẽ có người đề xuất lại, và nếu không ghi thì cả cuộc tranh luận phải chạy lại từ đầu.
>
> Đây là **ảnh chụp hiểu biết tại thời điểm quyết định**, không phải tài liệu sống. Nguồn ngoài
> có thể đổi; đổi thì mở [finding](../../finding.md), đừng sửa lén dòng ở đây.

---

## 1. Hai câu hỏi phải trả lời

1. `code/be/internal/` chia theo **tầng kỹ thuật** (`handler/`, `service/`, `store/`) hay theo
   **module nghiệp vụ** (`menu/`, `order/`, `shop/`)?
2. Computer vision — sẽ thêm sau — chạy **trong** binary Go hay ở **tiến trình riêng**?

Bối cảnh lúc quyết định, đo được chứ không ước lượng: `code/be/` có **9 file `.go`**, đồ thị import là
`cmd/server → handler → {config, menu, store}` và `store → menu`. Tức repo đang **nửa module-first**
(`menu/` là module thuần, không phụ thuộc ai) **nửa layer-first** (`handler/` + `store/` toàn cục).
`T-08` sắp dựng `internal/service/` — đóng đinh vế layer-first thêm một tầng nữa.

**Đây là thời điểm rẻ nhất để chọn.** Chi phí dời ở kích cỡ này gần bằng 0; sau khi có
`order` + `table` + `staff` + `report` + `vision` thì nó là một cuộc di dời lớn.

## 2. Go không có "standard layout" — và cái được gọi là chuẩn thì không phải

Điểm quan trọng nhất, vì nó loại bỏ nguồn tham chiếu mà phần lớn bài blog đang dùng:

- Repo [`golang-standards/project-layout`](https://github.com/golang-standards/project-layout)
  **không** được Go team bảo chứng. **Russ Cox** (tech lead của Go) nói công khai đây *không phải*
  layout chuẩn, rằng phần lớn repo Go **đơn giản hơn nhiều** và **không dùng `pkg/`**.
- **`pkg/` bị bác riêng.** Nó thêm một đoạn đường dẫn mà không thêm nghĩa nào; **Brad Fitzpatrick**
  xác nhận thư viện chuẩn đã **bỏ `pkg/` từ Go 1.4**, còn cộng đồng chép lại từ các dự án đời đầu
  như Kubernetes.
- Đồng thuận trong các bài rà soát lại: layout đó **hợp lý cho monorepo lớn nhiều team**, và
  **có hại khi làm template khởi đầu** cho một dự án bình thường.

**Tài liệu chính thức** — [go.dev/doc/modules/layout](https://go.dev/doc/modules/layout) — không đưa
một cây cố định; nó cho layout **mọc dần theo kích cỡ**, qua 7 mức. Mức "server project", đúng loại
của `code/be/`, chỉ nói ba điều:

```
go.mod        ở gốc module
internal/     TOÀN BỘ logic — đây là biên giới DUY NHẤT Go toolchain thật sự cưỡng chế
cmd/<binary>/ mỗi binary một thư mục
```

**Hệ quả cho dự án này:** `code/be/` đã đúng khuôn chính thức ở mức thư mục gốc **từ trước**. Câu hỏi 1
không phải là "có theo chuẩn không" — không có chuẩn nào để theo — mà là **chia bên trong `internal/`
thế nào**, thứ tài liệu chính thức cố ý không trả lời.

## 3. Chia theo tầng vs theo module — chi phí biên, không phải thẩm mỹ

Cả hai đều "sạch" khi vẽ ra giấy. Khác nhau ở **chi phí thêm domain thứ n**:

| | Layer-first | Module-first |
|---|---|---|
| Thêm 1 domain | sửa **3** package, mỗi package phình thêm | thêm **1** thư mục, không ai phải đụng |
| Đọc một tính năng | nhảy qua 3 thư mục xa nhau | một thư mục |
| Biên giới | **không có** — mọi handler thấy mọi store | Go cưỡng chế được (kiểu không xuất khẩu) |
| Xoá một tính năng | mò 3 chỗ, dễ sót | xoá 1 thư mục |
| Điểm bắt đầu đau | ~5 domain trở lên | gần như không |

Luật của modular monolith, gói gọn từ các nguồn 2026: **mỗi module sở hữu domain của nó, giấu chi
tiết lưu trữ của nó, và mọi tương tác xuyên module đi qua composition root**; giao tiếp là **gọi hàm
qua interface + dependency injection**, không phải HTTP/gRPC nội bộ.

Một cảnh báo đi kèm, và nó đúng với quy mô của quán bánh cuốn: *"modular monolith nên **mọc vào**
cấu trúc của nó, đừng ép nó vào một cấu trúc từ ngày đầu"*. Vì thế cây ở [§3.0](01-thiet-ke.md) có
`table/`, `staff/`, `report/`, `vision/` — nhưng chúng là **chỗ trống đã đặt tên**, không phải thư
mục rỗng phải tạo ngay.

## 4. Năm anti-pattern được ghi nhận — và cách repo này né

| Anti-pattern | Gốc | Ở repo này |
|---|---|---|
| **Chia module quá sớm** | tách khi chưa biết domain | mới tạo 3 module có code thật; 4 module còn lại chỉ là tên trong tài liệu |
| **Trừu tượng quá sớm** | interface khi mới có 1 implementation | `menu`/`shop` **không** có interface; chỉ `order/port.go` có, vì ở đó có 2 module thật cần nối |
| **Gọi HTTP giữa hai package cùng binary** | bắt chước microservice | cấm ở [§3.0](01-thiet-ke.md), luật *"trong monolith thì đó là lời gọi hàm"* |
| **Trừu tượng rò rỉ** | module ngầm biết ruột của nhau | `store` của mọi module là kiểu **không xuất khẩu** — compiler chặn, không phải lời hứa |
| **Mô hình domain yếu** | coi modular là chuyện kỹ thuật thuần | biên giới cắt theo *nghiệp vụ quán* (thực đơn / đơn / quán / bàn / nhân sự), không theo kiểu dữ liệu |

Câu đáng nhớ nhất của nhóm nguồn này: *"cứ viết code rồi xem cái gì đáng trừu tượng hoá"* —
trì hoãn quyết định kiến trúc cho tới khi **vấn đề tự lộ ra**, đừng quyết theo nhu cầu tưởng tượng.

## 5. Computer vision — cái giá của `gocv`/cgo là đo được

Phương án hiển nhiên nhất là [`gocv`](https://github.com/hybridgroup/gocv) (binding OpenCV cho Go,
có DNN + CUDA + OpenVINO). Nó **chạy được**, nhưng bốn cái giá dưới đây đều có người trả rồi:

1. **`import "C"` giết phần lớn cái làm Go dễ chịu.** Mọi máy build phải có C toolchain; build biến
   thành script nhiều bước với `CGO_CFLAGS`/`CGO_LDFLAGS` và đường dẫn thư viện theo từng nền tảng;
   cross-compile mất.
2. **Image Docker cỡ GB.** OpenCV rất lớn và **không thể compile riêng phần contrib** mà không
   compile cả OpenCV; các báo cáo dựng multi-stage đều xoay quanh việc kéo image từ ~2GB xuống.
3. **Vênh phiên bản là chuyện thường trực** — dòng issue gocv × OpenCV dài và lặp lại.
4. **Crash ở tầng C giết cả tiến trình.** Với binary này, "cả tiến trình" nghĩa là **màn hình bếp và
   luồng đặt đơn chết theo con detector**. Đây là vế nặng nhất: nó biến một lỗi thị giác máy tính
   thành một sự cố bán hàng.

Đổi lại gần như không được gì, vì hệ sinh thái model vẫn ở Python.

## 6. Bốn phương án CV đã cân nhắc — và vì sao loại ba

| Phương án | Ưu | Vì sao **loại** / **chọn** |
|---|---|---|
| **a. `gocv` trong binary API** | một tiến trình, không IPC | ❌ Loại — cả 4 cái giá ở §5, nặng nhất là vế "crash C giết luồng đặt đơn" |
| **b. FFI thuần Go, không cgo** (ONNX Runtime qua FFI, zerfoo…) | giữ được cross-compile, binary tự chứa, GPU thành năng lực **lúc chạy** chứ không phải phụ thuộc **lúc build** | ❌ Loại **bây giờ**, giữ cho sau — hệ sinh thái còn non so với Python, và nó chỉ đáng khi model đã ổn định. Quyết định §3.9 **cố ý để đường này mở**: đổi sang nó = thay một adapter |
| **c. Nhúng Python qua IPC Unix domain socket** (kiểu `pyproc`) | gọi Python từ Go không cần cgo, không cần dựng microservice | ❌ Loại — vẫn buộc vòng đời tiến trình Python vào tiến trình Go, và vẫn phải cài Python + model **trong image của API**. Được cái tiện, mất cái cách ly, mà cách ly mới là thứ đang cần |
| **d. Server riêng, Python, monolith gọi qua một interface** | model, GPU, thư viện CV nằm hoàn toàn ngoài binary Go; crash không lan; scale riêng; đổi runtime = thay adapter | ✅ **Chọn** (owner chốt 2026-08-18) |

**Ranh giới làm cho (d) vẫn là monolith, không phải microservices:** monolith giữ **trạng thái +
nghiệp vụ**; `cv-service` **không giữ sự thật nào** — nhận ảnh, trả kết quả, xoá đi dựng lại lúc nào
cũng được mà không mất dữ liệu. Thứ phân biệt hai kiến trúc không phải **số container**, mà là
**số nơi giữ sự thật**. Một `go.mod`, hai binary Go (`server`, `worker`), một database.

Chuẩn hoá model bằng **ONNX** (train ở Python, chạy ở đâu cũng được) là thứ giữ phương án (b) còn
sống — không có nó thì "sau này chạy thẳng trong Go" chỉ là câu nói.

## 7. Vì sao inference phải là **job**, không phải request

Suy luận mất từ vài giây tới hàng chục giây, **vượt timeout của gateway**. Khuôn được dùng lại
khắp nơi: API nhận ảnh → trả `job_id` **ngay** → client hỏi trạng thái (ở repo này là nghe kênh SSE
đã có sẵn ở [§3.7](01-thiet-ke.md)).

Hai chi tiết đi kèm, mỗi cái chặn một kiểu hỏng im lặng:

- **Ghi job trong cùng transaction với nghiệp vụ** (transactional outbox). Không có nó thì hoặc ảnh
  đã nhận mà job mất, hoặc job có mà nghiệp vụ rollback — cả hai đều **không báo lỗi**. Ở quy mô một
  quán, bảng job + worker poll **là** bản outbox rẻ nhất; Kafka/RabbitMQ là chi phí chưa có ai trả.
- **Ảnh không nằm trong database.** Object storage (hoặc thư mục + volume) giữ file; DB giữ đường
  dẫn + hash + metadata. Đây là khuôn chuẩn của mọi workload AI: nơi lưu **nóng** cho thứ đang chạy,
  object storage cho thứ đã xong.

## 8. Cái đã bị bỏ qua có chủ ý

- **`pkg/`** — §2.
- **Tách CV thành microservice "đầy đủ" có DB riêng** — nó stateless; cho nó một DB là đẻ nhà thứ hai
  cho cùng một sự thật ([CLAUDE.md §2.1](../../CLAUDE.md)).
- **Interface cho mọi service** — chỉ `order/port.go` có, vì chỉ ở đó nó mua được thứ thật (test
  `order` chạy không cần database, và `order` không phải import `shop`).
- **`internal/app/` làm tầng điều phối** (có nguồn đề xuất) — với 3 module thì `cmd/server/main.go`
  đã đủ làm composition root; thêm một tầng nữa lúc này là chính cái anti-pattern "trừu tượng sớm".

## 9. Biên nhận đọc lại — file này lệch với luật đã chốt thì nó là bug

Không có compiler cho văn xuôi ([CLAUDE.md §8](../../CLAUDE.md)), nên ba lệnh dưới, chạy từ gốc repo:

```bash
# a. hai quyết định file này biện hộ phải còn nguyên ở nhà thật — cả hai phải RA HIT
grep -c 'Chia theo module nghiệp vụ, không theo tầng kỹ thuật' design/backend/04-yeu-cau.md   # = 1
grep -c 'không import thư viện computer vision nào' design/backend/04-yeu-cau.md              # = 1

# b. file này không được đẻ luật riêng — mọi câu "phải/cấm" phải trỏ về 01 hoặc 04
grep -nE '^\*\*(Luật|Cấm)' design/backend/nghien-cuu-cau-truc.md    # phải rỗng

# c. ngày header vs commit cuối (§10)
git log -1 --format=%ad --date=short -- design/backend/nghien-cuu-cau-truc.md
```

## Nguồn

Truy cập 2026-08-18. Nguồn ngoài **không** phải sự thật của dự án — đọc để hiểu vì sao, đừng chép
số liệu từ đó vào tài liệu dự án.

**Layout Go**
- [Organizing a Go module](https://go.dev/doc/modules/layout) — tài liệu chính thức, 7 mức layout
- [golang-standards/project-layout](https://github.com/golang-standards/project-layout) — repo bị bàn cãi
- [golang-standards/project-layout Is Not a Standard. Russ Cox Said So](https://dev.to/gabrielanhaia/golang-standardsproject-layout-is-not-a-standard-russ-cox-said-so-4kjh)
- [Go Project Layout: What Actually Works](https://alnah.io/post/go-project-layout/)

**Modular monolith**
- [essentialols/go-modular-monolith-guide](https://github.com/essentialols/go-modular-monolith-guide) — bảng anti-pattern ở §4 lấy từ đây
- [Designing a Modular Monolith in Go: Structure, Boundaries, and Practical Patterns](https://daveamit.com/posts/2026-02-13-modular-monolith/)
- [powerman/go-monolith-example](https://github.com/powerman/go-monolith-example)

**Computer vision + cgo**
- [hybridgroup/gocv](https://github.com/hybridgroup/gocv) · [issue #837 — multi-stage Dockerfile](https://github.com/hybridgroup/gocv/issues/837)
- [Dockerising GoCV: Overcoming the Challenges of OpenCV in Go](https://medium.com/@kurtesy_/opencv-for-go-is-a-lot-tricky-9c58464a9127)
- [Zero CGo: Why We Chose Pure Go for ML Inference](https://zerfoo.feza.ai/docs/blog/zero-cgo-pure-go-ml-inference/)
- [YuminosukeSato/pyproc](https://github.com/YuminosukeSato/pyproc) — gọi Python từ Go qua Unix domain socket
- [Go in the AI/ML Landscape: A Practical Guide](https://medium.com/@vladimirvivien/go-in-the-ai-ml-landscape-a-practical-guide-d36d44f360d2)

**Job bất đồng bộ + outbox**
- [Architecting a Go Backend with Event-Driven Design and the Outbox Pattern](https://medium.com/@steffankharmaaiarvi/architecting-a-go-backend-with-event-driven-design-and-the-outbox-pattern-3928bf315e0a)
- [Go Microservices for AI/ML Orchestration](https://www.glukhov.org/app-architecture/integration-patterns/go-microservices-for-ai-ml-orchestration-patterns/)
- [AI Workloads Storage Architecture](https://hammerspace.com/ai-workloads-storage-architecture-performance-patterns-for-training-inference-and-llms/)
