# 03 — Đưa bài học lược đồ của dự án cũ vào đúng bước pha 2 (L1) · T-XXX

> Viết 2026-09-25, theo yêu cầu chủ repo: *"làm cho tôi 2 prompt: 1 là làm các cải tiến, 2 là thực
> hiện các điểm cần cải thiện db"*. Đây là **prompt 2**: các điểm **nội dung** DB. Prompt 1
> (`02-quy-trinh-db-tu-du-an-cu-L2.md`, cùng thư mục) phải `Done` **trước**, vì nó đổi *Cần xong
> trước* và yêu cầu mỗi quy ước P2-03 có lệnh gác. Prompt này viết tiếp vào chính các entry ấy.
>
> Mã task, mã finding: lấy mã kế tiếp **lúc nhận việc** bằng grep ở `work/backlog.md` và
> `work/findings.md`, vì phiên song song có thể đã lấy mã (**F-025**).

## Context

- **Nguồn đối chiếu (không sở hữu gì):** `work/proposals/from_old_project/data_base/nghien-cuu.md`,
  bản đối chiếu lược đồ của dự án cũ với MySQL manual, Square và các pattern có tên. Mọi mục trích
  dưới đây là **bằng chứng của dự án cũ**, không phải dữ kiện quán này (`CLAUDE.md` §2, hàng
  *Proposals*).
- **Chưa có lược đồ.** Pha 2 mới xong P2-01, P2-02, và P2-03 là bước *Ready*. Vì vậy "thực hiện"
  ở đây nghĩa là: mỗi bài học vào **đúng entry** của bước sẽ dựng nó, dưới dạng một bước làm, một
  bẫy hoặc một đầu ra kiểm chứng. Nếu pha 1 thiếu mệnh đề cho nó, thì nó thành **một `F-XXX` gửi
  ngược** (**ADR-050**: pha 2 không tự đặt luật, không tự hạ tầng).
- Owner cần đọc: `master_plan/shop-facts.md` §4.6 (luật phụ thu và luật *Lượng nhân*), §2 (kênh
  `qr_table`), §1 (Telegram báo đơn web); `quality/invariants.md` (danh sách `I-0xx`);
  `docs/product/1-system-design/01-ranh-gioi-he-thong.md` (đường suy giảm của phụ thuộc Telegram);
  `docs/product/0-ba/ban-hang/06-ngoai-le.md` (hết bánh giữa buổi); `work/findings.md` **F-036**.

Bảng việc. Cột *Bằng chứng cũ* trỏ vào mục của `nghien-cuu.md`:

| # | Bài học | Bằng chứng cũ | Vào đâu |
|:--:|---|---|---|
| 1 | **Collation theo vai trò cột.** Văn bản cho người đọc thì so và sắp xếp đúng tiếng Việt; định danh máy đọc và chuỗi băm thì so từng byte, phân biệt hoa thường. Đổi sau khi có dữ liệu là dựng lại cả bảng | §2.2 | P2-03, chủ đề mới |
| 2 | **Kiểu mốc thời gian**: giới hạn năm 2038 của một số kiểu, và kết nối của môi trường test phải cùng múi giờ với môi trường chạy thật (dự án cũ lệch 7 tiếng chỉ trong test) | §1.7, §4.4 | P2-03, chủ đề *mốc*; P2-12, khung test |
| 3 | **Quan hệ số học giữa các cột tiền trong cùng một bản ghi** (thành tiền = đơn giá × số lượng, …) phải do database giữ: ràng buộc kiểm hoặc cột tự tính. Tổng đi qua nhiều bản ghi vẫn thuộc P2-11 | §2.7 | P2-03, chủ đề *tiền* |
| 4 | **Phụ thu là công thức, không phải các con số chép tay.** `shop-facts.md` §4.6 luật 5 nói ×1 · ×4 · ×5 là *hệ quả*. Dự án cũ chép thành nhiều dòng lặp, nên đổi phụ thu mà sót một dòng thì một món bán sai giá và không lệnh nào báo | §2.4 | P2-05, đầu ra kiểm chứng + bẫy |
| 5 | **Luật "Lượng nhân chỉ khi nhân ≠ Chay" phụ thuộc vào một TẬP lựa chọn.** Một tham chiếu tới một lựa chọn đơn không diễn tả nổi, và nửa luật còn lại rơi xuống code | §2.5 | P2-05, bẫy (`I-010`) |
| 6 | **Ảnh chụp tuỳ chọn trên dòng đơn giữ cả mã gốc**, không chỉ giữ tên. Đổi tên hiển thị là báo cáo gãy làm đôi | §2.6 | P2-05, bẫy |
| 7 | **"Tạm hết trong buổi" khác "ngừng bán hẳn"**: người bật/tắt khác nhau, tần suất khác nhau. Gộp một cờ thì bật lại món tạm hết làm sống lại món đã bỏ | §2.9 | P2-05. Đọc F-036 và `06-ngoai-le.md` **trước**; xem Constraints |
| 8 | **Điều kiện "một bàn tối đa một phiên chưa thanh toán" phải theo NGHĨA** (bàn còn nợ tiền), không theo một giá trị trạng thái. Dự án cũ chặn `= 'open'` và ràng buộc nhả ra đúng lúc quầy tính tiền | §1.3; `02-luat.md` §2 cũ | P2-04, bẫy |
| 9 | **Mã QR của bàn phải không đoán được và đổi được.** Dự án cũ sinh bằng một hàm dựa trên thời gian: có một mã là suy ra mười mã kia, rồi gọi món ghi nợ vào hoá đơn bàn khác | §2.1 | **F-XXX gửi pha 1** (không có `I-0xx` nào); P2-10, bẫy trỏ tới F ấy |
| 10 | **Một lần gửi đơn thành đúng một đơn**, kể cả khi khách bấm hai lần hoặc mạng chập chờn. Lời giải chuẩn là một khoá chống trùng duy nhất, do database giữ, không kiểm-rồi-ghi ở code | §3.1 | **F-XXX gửi pha 1**; P2-04, một dòng *chỗ trống có tên* |
| 11 | **Báo đơn qua Telegram có thể rơi mất mà không để lại dấu vết**, vì ghi xong mới gửi | §2.10 | Chỉ **đọc** `01-ranh-gioi-he-thong.md`. Đường suy giảm đã phủ thì không làm gì; chưa phủ thì **F-XXX gửi pha 1** |

## Goal

Mỗi bài học trong bảng trên có **đúng một** chỗ đứng trong repo, ở entry của bước pha 2 sẽ dựng nó
hoặc ở một finding gửi ngược pha 1, để phiên nhận P2-03, P2-04, P2-05, P2-10 và P2-12 gặp nó trong
hồ sơ của chính bước ấy, không cần đọc lại `work/proposals/`.

## Scope

Được sửa:
- `work/backlog_DB.md`: phần *Cách hoàn thành*, *Bẫy hay sửa nhầm nhất* và *Không làm thì mất gì*
  của P2-03, P2-04, P2-05, P2-10, P2-12. **Không** điền khối *Nhận việc* (**ADR-051**)
- `master_plan/DB_master_plan_banh_cuon_ba_thanh.md`: §6 cột *Đầu ra kiểm chứng được* của P2-05
  (dòng 4) và §8 bảng *Đang chặn* (thêm các `F-XXX` mới cùng bước bị chạm)
- `work/findings.md`: hai hoặc ba finding mới (dòng 9, 10, có thể 11) theo template của file, cộng
  một hàng ở bảng tổng hợp
- `work/backlog.md`: dòng task T-XXX

Không được sửa:
- `quality/invariants.md`, `docs/product/1-system-design/`: thêm mệnh đề và tầng là việc của phiên
  nhận finding ở pha 1, không phải lượt này
- `master_plan/shop-facts.md`, `docs/product/99-unknowns.md`: chỉ được thêm `U-XXX` vào
  `99-unknowns.md` nếu dòng 7 gặp đúng trường hợp ở Constraints
- `docs/product/2-db/`: chưa tồn tại, P2-03 mở nó
- `work/proposals/`, `CLAUDE.md`, `docs/decisions.md`

Dòng chép vào `work/scope.txt` (thêm khối của mình, đừng ghi đè khối phiên khác):
```text
work/backlog_DB.md
master_plan/DB_master_plan_banh_cuon_ba_thanh.md
work/findings.md
work/backlog.md
```

## Constraints

- **Không viết tên bảng, tên cột, kiểu dữ liệu hay cú pháp của một DBMS cụ thể** vào kế hoạch hoặc
  backlog. Nói *vai trò* ("định danh máy đọc", "chuỗi băm", "khoá chống trùng duy nhất"), không nói
  `ascii_bin`, `CHAR(36)`, `RANDOM_BYTES`. DBMS chưa chốt (prompt 1), và tên bảng là đầu ra của
  P2-04 (**ADR-035**). Có thể trỏ `nghien-cuu.md` §x.y cho người muốn xem cú pháp cũ.
- **Không chép một con giá hay một hệ số phụ thu nào.** Dòng 4 và 5 **trỏ** `shop-facts.md` §4.6
  (**ADR-001**, **F-001**). Đầu ra mới của P2-05 nói hình dạng phép thử, ví dụ *"đổi phụ thu ở owner
  một lần ⇒ dựng lại dữ liệu mồi ⇒ mọi suất đổi giá theo đúng công thức"*, không nói con số.
- **Dòng 7 có thể là luật nghiệp vụ chưa ai chốt.** Đọc `shop-facts.md` và `06-ngoai-le.md`: quán
  có thao tác *tạm hết trong buổi* riêng với *ngừng bán hẳn* không? Owner **có** nói ⇒ bẫy của P2-05
  trỏ vào đó. Owner **không** nói ⇒ ghi một `U-XXX` đúng khuôn của `99-unknowns.md` (*Cách viết một
  câu ở đây*, một bullet dưới `### Đang mở`) và bẫy P2-05 trỏ vào U ấy. **Không** tự định nghĩa hai
  cờ (`CLAUDE.md` §3.5, không có mức L0). Nếu chạm `99-unknowns.md`, thêm nó vào `work/scope.txt` và
  nói ra trong báo cáo.
- **Dòng 9, 10, 11 là finding, không phải thiết kế.** Mỗi finding nói: *pha 1 chưa có mệnh đề nào
  giữ X; hỏng thì mất tiền ở đâu; bước pha 2 nào đang phải để trống vì nó*. Không đề xuất tầng bảo
  vệ; tầng là của pha 1. Kiểm trước bằng `grep -n` trong `quality/invariants.md` và
  `docs/product/1-system-design/`. Đã có mệnh đề phủ thì **không** mở finding, và báo cáo ghi rõ mã
  `I-0xx` đã phủ.
- **Mỗi bài học ở đúng một chỗ.** Một bài học xuất hiện ở hai entry (ví dụ dòng 2 ở cả P2-03 và
  P2-12) thì một chỗ nói luật, chỗ kia chỉ **trỏ** sang (**F-001**).
- Viết trích dẫn bằng chính lời của repo này, không dán nguyên đoạn `nghien-cuu.md`. Mỗi bẫy tối đa
  ba dòng, cùng giọng với các bẫy đang có trong `work/backlog_DB.md`.
- Đọc `git status` trước khi sửa. `work/backlog.md` đang mang thay đổi chưa commit của T-094,
  T-095. Không stage và không gộp phần đó (**F-025**, `CLAUDE.md` §6.1).

## Acceptance

- Mỗi dòng 1–11 của bảng Context có **một** vị trí trong diff (entry + mục, hoặc mã `F-XXX`), hoặc
  một câu trong báo cáo nói vì sao không cần (ví dụ dòng 11 đã được `01-ranh-gioi-he-thong.md` phủ,
  kèm `file:dòng`). Báo cáo có bảng *dòng → vị trí*.
- P2-03 có chủ đề *văn bản và định danh* (dòng 1), và chủ đề *tiền* nói quan hệ số học trong cùng
  bản ghi (dòng 3). Nếu prompt 1 đã chạy, mỗi chủ đề mới cũng có phép kiểm của nó.
- Kế hoạch §6 dòng P2-05 và entry P2-05 có cùng một đầu ra mới cho dòng 4, lời khớp nhau.
- `work/findings.md` có các finding mới theo đúng template (Problem · Impact · Decision / Fix ·
  Related task), trạng thái *Open*, và kế hoạch §8 liệt kê chúng cùng bước bị chạm.
- Ca phải bị từ chối, không ra dòng nào ở các dòng thêm mới: tên bảng/cột của dự án cũ, một con giá,
  hoặc tên kiểu dữ liệu của một DBMS cụ thể (xem lệnh ở *Verify*).

## Verify

```bash
git diff --stat
git diff -U0 master_plan/ work/backlog_DB.md work/findings.md \
  | grep -nE '^\+.*(\b(orders|order_items|table_sessions|payments|products|qr_token|open_key|is_active|is_available)\b|[0-9]\.000|utf8mb4|ascii_bin|CHAR\(|INT UNSIGNED|RANDOM_BYTES|UUID\()'
# lệnh chưa lọc cạnh lệnh đã lọc (F-017): phải thấy các dòng thêm mới ở đây
git diff -U0 master_plan/ work/backlog_DB.md work/findings.md | grep -c '^+'
grep -n '^### F-' work/findings.md | tail -4
./scripts/gate.sh
```

Lệnh lọc thứ hai ra **rỗng**, trừ các dòng trích có ghi rõ nguồn `work/proposals/`. Lệnh đếm thứ ba
ra **khác 0**.

## Unknowns

- Dòng 7 (*tạm hết* và *ngừng bán*) có thể cần lời chủ quán. Cách xử ở Constraints: ghi `U-XXX`,
  không đoán.
- Không còn unknown nào chặn các dòng khác. Dòng 9 và 10 là câu hỏi cho **pha 1** (thiếu mệnh đề),
  không phải cho chủ quán.

## Report (AI trả lời sau khi làm)

- Bảng *dòng 1–11 → vị trí* (entry + mục, hoặc `F-XXX`, hoặc lý do không cần)
- Đã verify thế nào: dán output của từng lệnh ở *Verify*
- Còn gì chưa giải quyết, mỗi `F-XXX`/`U-XXX` mới kèm link `file:dòng` grep trong lượt báo cáo
  (`CLAUDE.md` §7.3)
- Khối `git add` / `git commit` dán được, liệt kê từng file, không có phần của T-094/T-095
