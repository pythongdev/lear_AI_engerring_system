# Bộ đối chiếu bất biến — mỗi tập "phải rỗng" của pha 1 thành một câu truy vấn chạy được

Pha 2 · bước `P2-11` · viết 2026-09-30 (Claude Code). Tên file đúng đề xuất của kế hoạch pha 2 §5.
Quyết định hình dạng (đơn vị là tập, một lệnh, chứng minh bằng ngày mẫu + lỗi cài): **ADR-066**.

**File này sở hữu:** tập nào của pha 1 thành câu nào; tập nào **chưa** có câu, vì sao, ai nợ; cách
chạy và cách chứng minh bộ câu biết kêu; các chỗ một câu đọc hẹp hơn tập của nó.

**File này KHÔNG sở hữu:**
- **lời của một phép đối chiếu** — cột phải của
  [`03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md) §1–§4. Pha 2 **thi hành**,
  không sửa; một tập sai là một `F-XXX` gửi ngược (đúng hình **F-044**);
- **lời của một mệnh đề** — `quality/invariants.md`;
- **câu truy vấn** — chúng nằm ở `db/reconcile/` (một file một mệnh đề, ví dụ `db/reconcile/i004.sql`;
  một khối `-- @@ I-0xx/n` một tập) và `db/reconcile/qd.sql`; file này không chép câu nào (**F-001**);
- **tên bảng · cột · ràng buộc** — file migration (**ADR-053** luật 2); **phép kiểm quy ước** — khối
  `sql` dưới từng `QD-XX` của [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md).

---

## 0. Cách chạy

```text
./scripts/reconcile.sh                   # database làm việc của compose.yaml, sau khi đóng quán
./scripts/reconcile.sh --project <tên>   # database của compose project khác
./scripts/reconcile.sh --codes           # chỉ so danh sách mã, không cần database
./scripts/db-check.sh                    # bộ kiểm: dựng từ số không, chạy lệnh trên + phần chứng minh §3
```

Lệnh in hai nhóm tách nhau (**ADR-053** luật 3): **nhóm `I-0xx/n`** — mỗi tập một dòng `PASS`
(0 dòng) hoặc `FAIL` kèm vài phần tử của tập; **nhóm `QD-XX`** — mọi khối `sql` dưới `### QD-XX` của
`01-quy-uoc-du-lieu.md`, đọc thẳng từ tài liệu, cộng năm câu của `db/reconcile/qd.sql` cho phần cần
danh sách đọc lúc chạy (`QD-02` · `QD-31/b` · `QD-32` · `QD-33/b` · `QD-40/b`). Trước mọi câu, lệnh so
`comm -3` danh sách mã `### I-0xx` ở `quality/invariants.md` với mã có câu, và mã `### QD-XX` với nhóm
quy ước: một mệnh đề mới chưa có câu làm lệnh **đỏ**, không cần ai nhớ cập nhật một con số
(**F-018** · **F-026**) — trừ mệnh đề có dòng hợp lệ ở §2.1, được in `NOTE` kèm người nợ
(**ADR-070**). Một câu không chạy được là `FAIL`, không phải bỏ qua.

Mọi danh sách mà câu cần đều **đọc lúc chạy** từ owner, không chép: giờ bán và múi giờ
(`shop-facts.md` §1), mã kênh (§2), mã trạm (§3), bảng chuyển trạng thái (`05-vong-doi.md` §5.2 ·
§5.3 · §5.4) đổi tên sang mã qua bảng ánh xạ `QD-40` của các file lát. Lệnh in số phần tử của từng
danh sách, và đỏ khi một danh sách rỗng (**F-017**).

---

## 1. Ánh xạ — tập nào thành câu nào

Số `n` của `I-0xx/n` là **thứ tự của tập** trong ô *Phép đối chiếu* của hàng ấy ở
`03-bao-ve-invariant.md`, đếm từ trái; tập có câu ghi mã câu, tập không có câu trỏ xuống §2. Đo lại
2026-09-30: **24** mã ở `quality/invariants.md`, **63** câu `I-0xx/n` (đếm lại bằng `--codes`, đừng
tin con số này — **F-003**).

| Mệnh đề | Tập → câu |
|---|---|
| `I-001` | 1 → `I-001/1` · 2 → `I-001/2` |
| `I-002` | 1 → `I-002/1` · 2 → `I-002/2` · 3 → `I-002/3` |
| `I-003` | 1 → `I-003/1` · 2 → `I-003/2` · 3 → §2 |
| `I-004` | 1 → `I-004/1` · 2 → `I-004/2` · 3 → `I-004/3` · 4 → `I-004/4` · 5 → §2 (**F-044**) · 6 → `I-004/6` · 7 → `I-004/7` |
| `I-005` | 1 → `I-005/1` · 2 → `I-005/2` · 3 → `I-005/3` |
| `I-006` | 1 → **`I-007/1`** (pha 1: *cùng một tập với `I-007`, không đối chiếu hai lần*) · 2 → `I-006/2` |
| `I-007` | 1 → `I-007/1` · 2 → `I-007/2` · 3 → `I-007/3` |
| `I-008` | 1 → `I-008/1` · 2 · 3 · 4 · 5 → §2 |
| `I-009` | 1 → `I-009/1` · 2 → `I-009/2` · 3 → `I-009/3` · 4 → `I-009/4` |
| `I-010` | 1 → `I-010/1` · 2 · 3 · 4 → §2 |
| `I-011` | 1 → `I-011/1` · 2 · 3 → §2 |
| `I-012` | 1 → `I-012/1` · 2 → §2 · 3 → `I-012/3` · 4 → `I-012/4` |
| `I-013` | 1 → `I-013/1` · 2 → `I-013/2` · 3 → §2 |
| `I-014` | 1 → `I-014/1` · 2 → `I-014/2` · 3 → §2 · 4 → `I-014/4` · 5 · 6 → §2 · 7 → `I-014/7` · 8 → `I-014/8` · 9 → §2 |
| `I-015` | 1 → `I-015/1` · 2 → `I-015/2` · 3 · 4 · 5 · 6 → §2 |
| `I-016` | 1 → `I-016/1` |
| `I-017` | 1 → `I-017/1` · 2 → `I-017/2` · 3 → §2 |
| `I-018` | 1 → `I-018/1` · 2 → §2 · 3 → `I-018/3` |
| `I-019` | 1 → `I-019/1` · 2 → §2 |
| `I-020` | 1 → `I-020/1` · 2 → `I-020/2` |
| `I-021` | 1 → §2 · 2 → `I-021/2` · 3 · 4 · 5 → §2 · 6 → `I-021/6` |
| `I-022` | 1 → `I-022/1` · 2 → `I-022/2` · 3 → `I-022/3` · 4 → `I-022/4` · 5 → `I-022/5` |
| `I-023` | 1…6 → `I-023/1`…`I-023/6` · 7 → §2 |
| `I-024` | 1 → `I-024/1` · 2 → `I-024/2` · 3 → `I-024/3` |

Vế mà pha 1 đã nói thẳng là **không có tập** (`I-022` vế ngược, `I-023` vế *không đoán được*, hai vế
của `I-024`) không có dòng nào ở đây: chúng là kịch bản của `quality/invariants.md`, không phải phép
đọc trên dữ liệu.

---

## 2. Tập chưa có câu — vì sao, ai nợ

Bốn lý do, không lý do nào là *"khó viết"*: **(A)** dữ liệu tập cần đọc **chưa có chỗ cất** trong
lược đồ; **(B)** tập **không có phần tử nào tồn tại được** trong hình lược đồ đã chọn — không cài
được lỗi nào để chứng minh một câu cho nó biết kêu, nên viết câu là viết một câu không bao giờ được
chấm (kế hoạch pha 2 §7 luật 3); **(C)** tập của pha 1 **sai** — `F-XXX`; **(D)** tập không phải một
tính chất của dữ liệu.

| Tập (thứ tự ở ô pha 1) | Trạng thái | Vì sao | Ai nợ |
|---|---|---|---|
| `I-003` tập 3 — bàn kẹt: đủ hai điều kiện mà không Trống | chưa có câu | (B) bàn **không** có cột trạng thái (`02-luoc-do-ban-hang.md` §3); *Trống* đọc ra từ chi tiết, nên "đủ điều kiện mà không Trống" không có dữ liệu nào để mâu thuẫn | — (đúng theo cấu tạo) |
| `I-004` tập 5 — việc Chưa làm của đơn đã Huỷ | chưa có câu | (C) tập không bao giờ rỗng: việc trạm không có trạng thái huỷ, không dòng nào bị xoá | pha 1 — **F-044** |
| `I-008` tập 2 — đơn tạo trong khoảng tạm dừng | chưa có câu | (A) lược đồ không cất khoảng *tạm dừng nhận đơn* | pha 3 — cửa tạo lượt gọi cần chỗ cất ấy; một migration mới |
| `I-008` tập 3 — đơn ba kênh khách tự bấm trong khoảng quán không nhìn thấy đơn | chưa có câu | (A) không cất khoảng mất kết nối ([`05-realtime-va-du-phong.md`](../1-system-design/05-realtime-va-du-phong.md) §3) | pha 3 |
| `I-008` tập 4 — đơn hai kênh nhân viên bị chặn nhầm | chưa có câu | (A) lần từ chối tạo đơn không để lại bản ghi | pha 3 |
| `I-008` tập 5 — đơn tạo trước khi điều kiện đóng mà bị chạm chỉ vì điều kiện ấy | chưa có câu | (A) cần khoảng tạm dừng/mất kết nối (tập 2 · 3) và lý do huỷ đọc được bằng máy | pha 3 |
| `I-010` tập 2 — tổ hợp khác tổ hợp khách gửi | chưa có câu | (A) không cất yêu cầu gốc (`03-luoc-do-menu-gia.md` §5) | pha 3 quyết có cất hay không |
| `I-010` tập 3 — yêu cầu bị từ chối vẫn sinh dòng | chưa có câu | (A) lần từ chối không để lại bản ghi | pha 3 |
| `I-010` tập 4 — dòng hợp lệ tại mốc bị đánh dấu hỏng vì menu đổi sau | chưa có câu | (B) lược đồ không có dấu *hỏng* hay *chặn* nào trên dòng đơn | — (đúng theo cấu tạo) |
| `I-011` tập 2 — lần đổi thành phần trong giờ bán không có bằng chứng lời nhắc | chưa có câu | (A) không cất lời nhắc | pha 3 |
| `I-011` tập 3 — lần đổi giá bị nhắc nhầm như đổi thành phần | chưa có câu | (A) như trên | pha 3 |
| `I-012` tập 2 — chỗ lệch của bảng đối soát không chỉ ra đúng một thao tác | chưa có câu | (A) cần số tiền mặt đếm được và tin nhắn báo có — chưa có chỗ cất (`04-luoc-do-duong-tien.md` §5) | **chủ repo** quyết bước nào nhận (`04-luoc-do-duong-tien.md` §5) |
| `I-013` tập 3 — kênh không có lượt kiểm ra đúng giá §4.8 | chưa có câu | (D) tính chất của bộ test theo kênh, không đọc được trên dữ liệu | pha 3 — test của cửa tính giá |
| `I-014` tập 3 — tổng báo cáo khác tổng hai nguồn | chưa có câu | (A) lược đồ không cất báo cáo; phép cộng hai nguồn là của chính `I-005/3` | pha 3 — con số báo cáo |
| `I-014` tập 5 — ngày *đã đối soát xong* mà còn lượt giấy chưa nhập / khoản không mốc | chưa có câu | (A) không cất dấu *đã đối soát xong* | chủ repo, cùng câu với `I-012` tập 2 |
| `I-014` tập 6 — con số dựng lại hôm nay khác con số đã đối soát hôm ấy | chưa có câu | (A) không cất con số đã đối soát | chủ repo, cùng câu với `I-012` tập 2 |
| `I-014` tập 9 — trả lại trả trước làm giảm doanh thu | chưa có câu | (A) đọc con số doanh thu của báo cáo; công thức của `I-005/3` đã tách dòng *trả lại* khỏi dòng *hoàn* | pha 3 — con số báo cáo |
| `I-015` tập 3 — phần không mang phương thức / ghi gộp | chưa có câu | (B) một lần thu là một dòng `bill`, mỗi phương thức một cột (`04-luoc-do-duong-tien.md` §1) | — (đúng theo cấu tạo) |
| `I-015` tập 4 — các phần rơi vào hai ngày | chưa có câu | (B) mọi phần trên một dòng, một `booked_at` | — (đúng theo cấu tạo) |
| `I-015` tập 5 — tổng chuyển khoản khác tin nhắn báo có | chưa có câu | (A) không cất tin nhắn báo có | chủ repo, cùng câu với `I-012` tập 2 |
| `I-015` tập 6 — tổng tiền mặt không khớp két | chưa có câu | trỏ sang `I-021` tập 1 — pha 1 nói *mệnh đề ấy là `I-021`* | như `I-021` tập 1 |
| `I-017` tập 3 — lần đóng phiên bị từ chối vì tiền | chưa có câu | (A) lần từ chối không để lại bản ghi | pha 3 |
| `I-018` tập 2 — lần ghi đè của hai người không dựng lại được bản người trước | chưa có câu | (A) vết chỉ có khi lần sửa khai lý do; không cất phiên thao tác nào | pha 3 — cùng việc với **F-046** |
| `I-019` tập 2 — hai dòng nhu cầu chung một khoá / một khoá tách hai dòng | chưa có câu | (B) không dòng nhu cầu nào được cất: bảng nhu cầu cộng lại từ `station_job` theo khoá gom (`05-luoc-do-san-xuat.md` §1) | pha 3 — hàm gom của màn bếp đọc đúng khoá; test của nó |
| `I-021` tập 1 — két − tiền đầu két khác vế phải công thức | chưa có câu | (A) số tiền mặt đếm được cuối ngày chưa có chỗ cất (`04-luoc-do-duong-tien.md` §5); mọi hạng tử vế phải đã đọc được (§3 bảng hạng tử) | **chủ repo** quyết bước nào nhận |
| `I-021` tập 3 — ngày chưa có tiền đầu két bị đọc là lệch | chưa có câu | (A) đọc kết quả của tập 1 | như tập 1 |
| `I-021` tập 4 — phép trừ chạy trên tổng gộp | chưa có câu | (A) đọc phép trừ của báo cáo | pha 3 |
| `I-021` tập 5 — con số doanh thu có cộng tiền đầu két | chưa có câu | (A) đọc con số của báo cáo; tiền đầu két ở bảng riêng, ngoài mọi cột tiền đã thu (**`I-021`** tầng 1) | pha 3 |
| `I-023` tập 7 — lần đổi mã chạm phiên đang mở | chưa có câu | (B) cửa `qr_code_issue` không chạm phiên hay lượt gọi, và phiên không mang mốc đổi trạng thái nào để so với lần đổi mã | — (đúng theo cấu tạo) |

### 2.1 Mệnh đề chưa có lát — cả mệnh đề chưa có câu

Ngày 2026-09-30, Claude chọn theo ADR-070; T-123 thi công: chỉ nhận dòng có đúng một mã
`I-0xx` trong backtick, trạng thái `chưa có lát`, đủ *vì sao* và *ai nợ* (không rỗng hoặc chỉ `—`).
Mã ở `quality/invariants.md` chưa có câu và có dòng hợp lệ được in `NOTE` kèm người nợ; mã thiếu
câu ngoài danh sách hoặc dòng sai hình làm lệnh đỏ.
Dòng có mã không thuộc invariant hoặc đã có câu cũng làm lệnh đỏ; bước viết câu phải gỡ dòng
của mệnh đề ấy trong cùng thay đổi.

| Mệnh đề | Trạng thái | Vì sao | Ai nợ |
|---|---|---|---|
| `I-025` | chưa có lát | lát đã dựng ở `P2A-02` (2026-09-30), câu và lỗi cài chưa viết — chờ dữ liệu mồi `P2A-06` | `P2A-07` |
| `I-026` | chưa có lát | lát đã dựng ở `P2A-02` (2026-09-30), câu và lỗi cài chưa viết — chờ dữ liệu mồi `P2A-06` | `P2A-07` |
| `I-027` | chưa có lát | lát chấm công (`P2A-03`) chưa dựng, còn chờ lời cho **U-065** | `P2A-07` |
| `I-028` | chưa có lát | lát khoản của người (`P2A-04`) chưa dựng | `P2A-07` |
| `I-029` | chưa có lát | lát khoản chi (`P2A-05`) chưa dựng, còn chờ lời cho **U-066** | `P2A-07` |

---

## 3. Chứng minh bộ câu biết kêu

`./scripts/db-check.sh` bước 6, trên database dựng từ số không + dữ liệu mồi (`08-du-lieu-moi.md`):

1. **Chính lệnh chạy sau khi đóng quán** chạy trên dữ liệu mồi ⇒ mọi câu **0 dòng**.
2. **Ngày bán mẫu đúng** — `db/reconcile/proof/baseline.sql`: phiên bàn QR + gọi thêm, nhóm ghép
   hai bàn ghi nợ rồi thu nợ sáng hôm sau, đơn giao trả trước đủ, đơn tới lấy có một lần hoàn chéo
   phương thức, đơn hotline huỷ và trả lại tiền trả trước, một thứ đã làm của đơn huỷ chuyển sang bàn
   chờ đúng thứ ấy, đổi mã QR, tiền đầu két, trực quầy; mọi lần sửa khai lý do, nên mọi lần chuyển
   trạng thái có vết. Qua mọi ràng buộc hoãn như lúc `COMMIT` ⇒ mọi câu **0 dòng**. Một câu xanh vì
   chưa có đơn nào không chứng minh nó không đỏ nhầm.
3. **Mỗi file lỗi** — `db/reconcile/proof/<mã>.sql`, một savepoint trên ngày mẫu: cài **một** chỗ sai
   vào **dữ liệu hay lược đồ** — tập có ràng buộc tầng 1 giữ thì lỗi **gỡ ràng buộc ấy trước**, đúng ca
   câu truy vấn sinh ra để bắt (`03-bao-ve-invariant.md` §0 luật 2). Trạng thái sau lỗi phải qua mọi
   ràng buộc còn lại (`SET CONSTRAINTS ALL IMMEDIATE`) — không có lỗi nào chỉ đứng được vì giao dịch
   chưa `COMMIT`. Tập câu kêu phải **bằng đúng** tập khai ở dòng đầu `-- kêu:` của file: thiếu là câu
   điếc, thừa là câu kêu oan. Không câu truy vấn nào bị sửa để nó đỏ.
4. `comm -3` giữa mọi mã câu và **mã đầu** của các file lỗi ⇒ rỗng: mỗi câu có ít nhất một lỗi nhắm
   vào nó.

Một lỗi làm kêu **nhiều** câu thì khai đủ, kèm một dòng vì sao — ví dụ gỡ ràng buộc kiểm của
`debt_collection` cũng làm các cột tiền của bảng ấy mất ràng buộc không âm, nên `QD-21` và `QD-22`
kêu cùng `I-005/3`: nhóm quy ước bắt đúng lần gỡ ràng buộc mà nhóm mệnh đề bắt hệ quả của nó.

---

## 4. Câu đọc hẹp hơn tập của nó, và cách đọc của phiên — 2026-09-30

Mỗi dòng là **lựa chọn của phiên**, chưa có lời chủ repo; đổi được, nhưng đổi ở đây trước khi câu
làm khác.

- **Vết ở chế độ mềm (F-046).** Lần sửa không khai lý do không để lại vết, nên các câu đọc từ vết —
  `I-009/1` · `I-016/1` · `I-017/2` · `I-018/1` · nhánh *sửa* của `I-011/1` và `I-021/6` · `QD-33/b` —
  không thấy nó. Ngược lại, lần đổi **giá** menu không khai lý do làm hàm *giá tại mốc* đọc giá hiện
  hành, nên `I-013/1` kêu ở mọi dòng cũ mang giá trước: tiếng kêu ấy đúng — nó chỉ ra một lần sửa
  mất vết — nhưng nó mang mã `I-013`, không mang mã `I-018`.
- **Thêm một dòng con không có vết.** Vết cập nhật chụp lần **sửa** một dòng đã có; lần **thêm** một
  dòng con vào một bản ghi đã có — thêm món vào đơn, thêm thành phần vào suất, thêm xấp mệnh giá vào
  tiền đầu két — không để lại *ai thêm*. `I-024/3`, `I-011/1`, `I-021/6` đọc đúng hình ấy và **kêu**
  cả ở lần thêm hợp lệ. Ghi thành **F-047** (`work/findings.md`).
- **`I-016/1` so với bảng §5 hôm nay**, không với bảng tại lúc chuyển: §5 chưa có lịch sử phiên bản
  đọc được bằng máy. Bảng đổi thì một lần chuyển cũ đúng luật cũ có thể kêu.
- **Lúc đóng phiên** là mốc `booked_at` của hoá đơn phiên — phiên không có cột mốc đóng
  (`I-003/2`, `I-002/3`).
- **`I-002/2`**: đơn Huỷ không vào tổng — trừ khi hoá đơn của phiên có một lần hoàn và số phải trả
  bằng đúng tổng **cả** đơn huỷ: đọc là đơn đã Hoàn thành rồi mới huỷ sau khi đóng (`shop-facts.md`
  §6.19), tiền đi đường hoàn.
- **`I-004/6`** in cả ca **không bàn nào chờ đúng thứ đã làm** — ca chưa có luật (**U-064**). Pha 1
  nói ca ấy chưa có tập; câu này đọc *chưa có luật* là *chưa đối soát xong*, không phải xanh.
- **`I-007/2`**: một lần thu gộp hiện ra là hoá đơn **thu nhiều hơn** chính đơn của nó. Hoá đơn thu
  **ít** hơn là `I-015`, không phải thu gộp.
- **`I-008/1`**: hai đầu giờ bán tính là **trong** giờ.
- **`I-021/2`** chỉ in ngày có **hơn một** con số tiền đầu két; ngày **chưa có** con số nào là *chưa
  đối soát xong* (tập 3 của pha 1, **ADR-037**), không phải lệch.
- **Toàn bộ lịch sử, không lọc theo ngày.** Một chỗ sai của hôm qua còn kêu mỗi tối cho tới khi được
  sửa có vết. Lọc theo một ngày bán là việc của màn đối soát — pha 3.
- **Kết nối qua `docker compose`** — database làm việc của máy phát triển. Kết nối tới database chạy
  thật là pha 5 (`work/backlog.md` T-109).

---

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-13` | §3 — lệnh và phần chứng minh chạy trong `./scripts/db-check.sh`; §2 là danh sách tập chưa được chấm, đọc trước khi tick cổng |
| `P2A-02`…`P2A-07` | Bước nào viết câu cho một mệnh đề thì **gỡ dòng của mệnh đề ấy ở §2.1 trong cùng thay đổi** |
| `P2-14` | §1 — mỗi mã `I-0xx` có câu; file này không nhắc đường gọi hay màn hình nào của pha 3 · pha 4 |
| pha 3 | §2 các dòng *pha 3* — mỗi chỗ cất mới là một migration, kèm câu và file lỗi mới ở `db/reconcile/`; §4 — **F-046** · **F-047** |
| chủ repo | §2 các dòng *chủ repo* — số tiền mặt đếm được, tin nhắn báo có, dấu đã đối soát xong: bước nào nhận (`04-luoc-do-duong-tien.md` §5) |
