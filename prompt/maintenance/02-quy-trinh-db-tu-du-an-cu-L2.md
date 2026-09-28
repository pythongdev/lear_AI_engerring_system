# 02 — Ba lỗ quy trình của pha 2 mà dự án cũ đã trả giá (L2) · T-XXX

> Viết 2026-09-25, theo yêu cầu chủ repo: *"làm cho tôi 2 prompt: 1 là làm các cải tiến, 2 là thực
> hiện các điểm cần cải thiện db"*. Đây là **prompt 1**: ba cải tiến **quy trình**. Prompt 2
> (`03-noi-dung-db-tu-du-an-cu-L1.md`, cùng thư mục) đưa các điểm **nội dung** DB vào các bước pha 2.
> **Chạy prompt này trước**: nó đổi cột *Cần xong trước* và thêm một luật chủ sở hữu, còn prompt 2
> viết vào chính các entry ấy.
>
> Mã task: lấy mã `T-XXX` kế tiếp **lúc nhận việc** bằng `grep -oE 'T-[0-9]{3}' work/backlog.md | sort -u | tail -1`,
> vì phiên song song có thể đã lấy mã (`work/findings.md` **F-025**).

## Context

- **Nguồn đối chiếu (không sở hữu gì):** `work/proposals/from_old_project/data_base/` gồm năm file
  DB của dự án cũ. `design/data_base/` là bản sao giống từng byte. Chúng là **bằng chứng**, không
  phải fact (`CLAUDE.md` §2, hàng *Proposals*). Ba chỗ dưới đây được rút ra từ những file đó.
- **Kế hoạch pha 2:** `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §5 (bản đồ file, ba hàng
  §2 đổi ở ba bước), §6 (bảng mười bốn bước), §8 (chỗ suy ra), §9 (cổng).
- **Hồ sơ thực thi:** `work/backlog_DB.md`, gồm các entry P2-03, P2-04…P2-08, P2-09, P2-11, P2-12.
  Trạng thái chỉ nằm ở `work/backlog.md` (**ADR-051**).
- **Quyết định đang đứng:** **ADR-035** (ranh giới sở hữu theo pha), **ADR-039** (quy ước code sinh
  ở pha 2), **ADR-049** (hình dạng kế hoạch), **ADR-050** (năm tầng dịch sang pha 2), **ADR-051**.

**Lỗ 1: năm lát lược đồ có thể chạy trước khi biết hệ quản trị CSDL nào.**
P2-04…P2-08 chỉ cần P2-03 xong trước, nhưng acceptance của chúng đòi *"cố tình dựng trạng thái sai
⇒ database từ chối, dán output"*, tức là cần một database thật. Stack chỉ được chốt ở P2-12, và
P2-12 không nằm trong *Cần xong trước* của năm lát. Bằng chứng từ dự án cũ
(`nghien-cuu.md` §1.3, §2.7): lời giải phụ thuộc chính DBMS. MySQL không có partial unique index
nên phải dùng cột sinh trả `NULL`, còn `CHECK` chỉ được thực thi từ 8.0.16. Một lát dựng trước khi
chốt DBMS sẽ phải dựng lại.

**Lỗ 2: sau P2-09, lược đồ sẽ có hai bản mà không luật nào nói bản nào thắng.**
P2-09 chạy migration thật, nên tên bảng và cột nằm cả trong `docs/product/2-db/` lẫn trong file
migration. Hàng *Schema* ở `CLAUDE.md` §2 chưa nói gì về chuyện này. Dự án cũ đã trả giá ba lần
(`nghien-cuu.md` §4.1–§4.3): tài liệu nhắc cột `is_active` không tồn tại, gọi `pin_code` trong khi
migration là `pin_hash`, và ghi "chưa seed bàn" khi seed đã có 11 bàn. Họ phải thêm luật *"migration
thắng tài liệu"* cùng một lệnh đọc thẳng file migration (`README.md` cũ §2 và §3, phép D).

**Lỗ 3: quy ước dữ liệu chỉ đòi "hậu quả", không đòi "lệnh gác".**
Acceptance của P2-03 là *"mỗi quy ước một dòng, mỗi dòng một hậu quả nếu làm khác"*. Dự án cũ đã
viết sẵn câu truy vấn `information_schema` chặn cột tiền kiểu số thực, ghi "thêm vào CI", rồi không
lệnh nào gọi tới nó (`nghien-cuu.md` §1.1, dự kiến F-78). Họ tự kết luận: *"luật không có lệnh gác
thì tự trôi"*.

## Goal

Pha 2 không thể dựng một ràng buộc thật trước khi biết nó chạy trên DBMS nào. Khi đã có file
migration, ai đọc cũng biết bản nào thắng cho tên bảng và cột, và có một lệnh phát hiện hai bản lệch
nhau. Mỗi quy ước dữ liệu của P2-03 phải kèm một phép kiểm chạy được.

## Scope

Được sửa:
- `docs/decisions.md`: **một** ADR mới gom cả ba lỗ (chúng là một quyết định: *pha 2 dựng trên nền
  gì và cái gì chứng minh nó còn đúng*), cộng một dòng ở bảng tổng hợp đầu file
- `master_plan/DB_master_plan_banh_cuon_ba_thanh.md`: §6 (cột *Cần xong trước*, cột *Đầu ra kiểm
  chứng được* của P2-03), §5 (bảng ba hàng §2), §8 (xoá chỗ suy ra nào ADR này đã chốt)
- `work/backlog_DB.md`: các dòng *Phụ thuộc*, *Cách hoàn thành* và *Bẫy* của P2-03, P2-04…P2-08,
  P2-09, P2-11, P2-12. **Không** điền khối *Nhận việc* (**ADR-051**: chỉ điền khi mọi bước ở *Cần
  xong trước* đã `Done`)
- `work/backlog.md`: dòng task T-XXX, và dòng *Ready* của P2-03 nếu mô tả ngắn của nó đổi

Không được sửa:
- `CLAUDE.md`: hàng *Schema* đổi ở P2-04 như kế hoạch §5 đã định. ADR này chỉ nói *khi đổi thì
  viết gì*, và thêm câu đó vào bước 8 của entry P2-04
- `docs/product/`: `2-db/` chỉ ra đời ở P2-03. Pha 1 không bị đụng
- `quality/invariants.md`, `master_plan/shop-facts.md`
- `work/proposals/`: bằng chứng, không sửa
- `scripts/`: lệnh đối chiếu hai bản lược đồ **được mô tả** trong entry P2-09/P2-11; nó được viết
  khi có file migration thật, không phải lượt này

Dòng chép vào `work/scope.txt` (thêm khối của mình, đừng ghi đè khối của phiên khác):
```text
docs/decisions.md
master_plan/DB_master_plan_banh_cuon_ba_thanh.md
work/backlog_DB.md
work/backlog.md
```

## Constraints

- **Không chọn DBMS trong lượt này.** Chọn stack là việc của P2-12, và là quyết định mà chủ repo
  phải thấy (**ADR-039**). Lượt này chỉ quyết **thứ tự**: DBMS phải được chốt trước khi lát đầu tiên
  dựng ràng buộc. Có hai đường, ADR ghi cả phương án bị loại kèm lý do:
  (a) thêm P2-12 vào *Cần xong trước* của P2-04…P2-08;
  (b) tách phần *chọn DBMS + phiên bản* thành một mục đầu của P2-12, hoặc một bước riêng. Phần thư
  mục, đặt tên và khung test vẫn chạy song song.
  Nếu chọn (b) mà thêm một bước mới, kế hoạch lên mười lăm dòng. Phải ghi rõ con số ấy và lý do,
  giống cách §6 đã ghi vì sao mười bốn dòng vượt khuyến nghị mười hai.
- **Luật chủ sở hữu khi đã có migration** phải trả lời được ba câu, mỗi câu một dòng:
  1. tên bảng, tên cột, kiểu và ràng buộc thì bản nào thắng;
  2. file `.md` của `docs/product/2-db/` còn giữ gì (gợi ý: ý định, lý do, ánh xạ sang `I-0xx`/`YC-xx`);
  3. hai bản lệch nhau thì làm gì (gợi ý: một dòng `F-XXX`, **không** sửa migration cho khớp chữ, đúng
     như `README.md` cũ §2).
  Kèm theo phải có **một phép kiểm được mô tả bằng lời**: mọi tên bảng mà file `.md` nhắc tới đều có
  trong file migration, và ngược lại. P2-09 hoặc P2-11 là bước biến nó thành lệnh. Tên file và vị trí
  thư mục migration **không** được viết ra ở đây, vì chúng là đầu ra của P2-12.
- **Không chép bài học cũ thành fact.** Mọi câu trích từ `work/proposals/` phải ghi rõ là bằng chứng
  của dự án cũ, không phải dữ kiện của quán này. Không một tên bảng cũ nào (`orders`,
  `table_sessions`, …) được đi vào kế hoạch hay backlog như tên sẽ dùng. Pha 2 chưa có owner lược
  đồ; viết tên bảng lúc này là viết hộ P2-04 (`CLAUDE.md` §2, **ADR-035**).
- **Một pointer sửa là grep mọi chỗ trỏ tới nó** (`CLAUDE.md` §7.2). Đổi *Cần xong trước* thì bảng
  §6 của kế hoạch và dòng *Phụ thuộc* của từng entry phải khớp trong **cùng** thay đổi, vì kế hoạch
  §6 thắng khi hai chỗ lệch.
- Đọc `git status` trước khi sửa. `work/backlog.md` đang mang thay đổi chưa commit của phiên khác
  (T-094, T-095). Không stage và không gộp phần đó (**F-025**, `CLAUDE.md` §6.1).

## Acceptance

- `docs/decisions.md` có một ADR mới, trạng thái rõ, ngày 2026-09-xx, ghi người quyết. Nó trả lời
  ba lỗ, mỗi lỗ kèm phương án bị loại. Dòng bảng tổng hợp khớp *Trạng thái* trong thân (Gate 1c
  chấm việc này).
- Kế hoạch §6: không lát nào trong P2-04…P2-08 còn có thể bắt đầu trước khi DBMS được chốt. Đọc cột
  *Cần xong trước* là thấy.
- Entry P2-04…P2-08 trong `work/backlog_DB.md` có dòng *Phụ thuộc* khớp từng chữ với kế hoạch §6.
- Kế hoạch §6, cột *Đầu ra kiểm chứng được* của P2-03, cùng bước 4 và 7 của entry P2-03, đòi **mỗi
  quy ước một phép kiểm chạy được** (một câu truy vấn hoặc một lệnh), và nói phép kiểm ấy được gom
  vào bộ của P2-11.
- Entry P2-04 bước 8 có câu: khi đổi hàng *Schema* của `CLAUDE.md` §2 thì viết theo luật chủ sở hữu
  của ADR mới.
- Entry P2-09 hoặc P2-11 (chỉ một trong hai, ADR nói cái nào) có một dòng *Đầu ra*: lệnh đối chiếu
  tên bảng giữa file `.md` và file migration ra **rỗng**, và **in cả lệnh chưa lọc cạnh lệnh đã lọc**
  (**F-017**).
- Ca phải bị từ chối: `grep -nE '\b(orders|order_items|table_sessions|payments|products|qr_token|open_key)\b'`
  trên các dòng lượt này thêm vào kế hoạch và backlog ⇒ **không** ra dòng nào ngoài câu trích có ghi
  nguồn `work/proposals/`.

## Verify

```bash
git diff --stat
git diff master_plan/DB_master_plan_banh_cuon_ba_thanh.md work/backlog_DB.md | grep -n 'Cần xong trước'
grep -n 'P2-04\|P2-05\|P2-06\|P2-07\|P2-08' master_plan/DB_master_plan_banh_cuon_ba_thanh.md | head -20
git diff -U0 master_plan/ work/backlog_DB.md | grep -nE '^\+.*\b(orders|order_items|table_sessions|payments|products|qr_token|open_key)\b'
./scripts/gate.sh
```

## Unknowns

- Chủ repo có muốn chốt luôn DBMS (bản đề xuất trong `master_plan/prompt-fullstack.md` §3.4 là
  MySQL 8.4 LTS) không, hay giữ việc chọn ở P2-12? Lượt này **không** cần câu trả lời để chạy, vì nó
  chỉ đổi thứ tự. Nhưng nếu chủ repo trả lời ngay trong phiên thì ghi vào ADR mới kèm ngày và
  nguyên văn.
- Luật chủ sở hữu khi có migration đổi nghĩa một hàng của `CLAUDE.md` §2. Đó là quyết định của
  **chủ repo**. Nếu phiên không hỏi được thì ADR ghi *Trạng thái: Đề xuất* và kế hoạch §8 ghi nó là
  chỗ suy ra đang chờ xác nhận, không ghi như đã chốt.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì, từng file
- Đã verify thế nào: dán output của từng lệnh ở *Verify*
- Còn gì chưa giải quyết, mỗi mã kèm link `file:dòng` grep trong lượt báo cáo (`CLAUDE.md` §7.3)
- Khối `git add` / `git commit` dán được, liệt kê từng file, không có phần của T-094/T-095
