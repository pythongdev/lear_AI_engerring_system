<a id="top"></a>
# Thứ tự migration và đường lùi

Pha 2 · bước `P2-09` · viết 2026-09-29 (Claude Code). Quyết định: `docs/decisions.md` **ADR-065**.

**File này sở hữu:** thứ tự các bước migration và bước nào đứng trên bước nào · luật của **đường
lùi** (mỗi bước xuôi một bước lùi, và khoá chặn) · cách gỡ một lệnh migration hỏng · cách dựng lại
lược đồ từ số không · chỗ chứng minh từng điều ấy chạy thật.

**File này KHÔNG sở hữu:**
- **tên bảng, tên cột, kiểu, ràng buộc** — file migration thắng (**ADR-053** luật 2); file lát giữ
  ý định. Bảng ở §1 nhắc tên bảng để nói thứ tự, không chép gì khác;
- **công cụ, thư mục, khuôn tên file** — [`10-quy-uoc-code.md`](10-quy-uoc-code.md) `QC-05`;
- **sao lưu và phục hồi dữ liệu bán hàng** — yêu cầu **YC-21** ở
  [`04-yeu-cau-du-lieu.md`](../1-system-design/04-yeu-cau-du-lieu.md) §8 (**ADR-057**), cơ chế và
  nghiệm thu ở pha 5 qua **T-109** (`work/backlog.md`). §5 nói vì sao file này không thay được nó.

---

## 1. Thứ tự dựng — mười hai bước

Công cụ chạy các bước theo **tên file**, tức theo mốc giờ ở đầu tên (`QC-05`). Thứ tự dưới đây là
thứ tự ấy; cột *đứng trên* nói bước nào phải có trước, vì bước sau thêm cột, khoá ngoại hay ràng
buộc vào bảng của nó. Dựng lại từ số không là chạy đúng mười hai bước này, từ trên xuống; lùi là đi
ngược từ dưới lên, **từng bước một**.

| # | File (`db/migrations/`, bỏ đuôi) | Lát | Dựng gì | Đứng trên |
|:--:|---|---|---|---|
| 1 | `20260927120000_ban_hang_loi` | `P2-04` | năm bảng lõi: `dining_table` · `table_session` · `table_session_member` · `sales_order` · `order_line` | — |
| 2 | `20260927140000_menu_gia` | `P2-05` | bảy bảng menu và tuỳ chọn, hai bảng ảnh chụp (`order_line_component` · `order_line_option`), cột giá và món trên dòng đơn | 1 |
| 3 | `20260928090000_lien_he_don_mang_di` | `T-111` | cột liên hệ và cách trao hàng trên đơn | 1 |
| 4 | `20260928100000_dau_lan_gui` | `T-116` | dấu lần gửi trên đơn | 1 |
| 5 | `20260928110000_ma_qr_ban` | `T-114` | `qr_code`, cửa cấp mã, mã đã mang trên lượt gọi | 1 |
| 6 | `20260928120000_duong_tien` | `P2-06` | bảy bảng tiền, từ `bill` tới `opening_float_line`; cột tự tính trên phiên và đơn để hoá đơn trỏ vào | 1 |
| 7 | `20260928130000_san_xuat_theo_me` | `P2-07` | năm bảng sản xuất, từ `menu_component_station` tới `station_job_transfer` | 1 · 2 |
| 8 | `20260928140000_nguoi_va_vet` | `P2-08` | `person` · `counter_duty` · `paper_ledger` · `record_revision`; cột *ai bấm* trên bảng của bước 5 · 6 · 7; trigger vết trên **mọi** bảng | 5 · 6 · 7 |
| 9 | `20260930100000_so_nguyen_lieu` | `P2A-02` | `supply_item` · `supply_day_entry` và trigger vết của chúng | 8 |
| 10 | `20260930110000_cham_cong` | `P2A-03` | `attendance_day` và trigger vết; vai ghi tick và huỷ được một ô, không sửa người hay ngày, không xoá | 8 |
| 11 | `20260930120000_khoan_cua_nguoi` | `P2A-04` | `staff_advance` · `holiday_bonus` và trigger vết; vai ghi chỉ sửa người nhận, số tiền và ngày | 8 |
| 12 | `20261001120000_tra_no_dan` | `T-126` | hai cột còn thiếu và chuỗi từng lần trả trên `debt_collection` (**ADR-075**, lời đóng `U-063`) | 6 · 8 |

**Bước 8 gắn trigger vết lên mọi bảng của các bước 1…8** đang có lúc nó chạy. Một bước sau
thêm bảng mới thì chính bước ấy gắn trigger cho bảng của nó — phép kiểm `QD-52`
của [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md) đỏ khi thiếu — và file lùi của nó gỡ trigger
ấy cùng bảng.

**Thêm một bước:** tên file theo `QC-05`, mốc giờ **sau** mọi bước đã có; một `.up.sql` và một
`.down.sql`; thêm một hàng vào bảng trên trong cùng thay đổi. Không chèn một bước vào **giữa** dãy
đã commit: máy nào đã chạy bước sau sẽ không bao giờ chạy bước chèn.

---

## 2. Luật đường lùi — bốn câu

1. **Mỗi bước xuôi có đúng một bước lùi, và bước lùi gỡ đúng thứ bước xuôi dựng** — không hơn,
   không kém. *Đúng* nghĩa là đo được: lược đồ sau khi lùi bước *N* giống **từng dòng** ảnh chụp
   lược đồ trước khi xuôi bước *N* (§4).
2. **Đường lùi chỉ gỡ chỗ cất còn rỗng.** File lùi mở đầu bằng **khoá chặn**: bảng sắp gỡ có dù
   một dòng, hay cột ghi sắp gỡ có dù một giá trị ⇒ từ chối với lời *"đường lùi từ chối: … đang giữ
   N giá trị đã ghi"*, và không gỡ gì. Cột tự tính và ràng buộc không cất dữ liệu nên không cần chặn.
   Đây là cách `QD-50` (không xoá cứng) áp lên chính lược đồ: một lệnh lùi không bao giờ là một lệnh
   xoá dữ liệu bán hàng.
3. **Lùi trên dữ liệu đã ghi là một migration mới đi tới** — bước mới, mốc giờ mới, có file lùi của
   riêng nó. Nó quyết giữ gì, chuyển gì sang đâu; đó là một quyết định có lý do, không phải một lệnh
   gỡ (`QC-05`: sửa lược đồ đã commit là một migration mới).
4. **Đường lùi chưa chạy lần nào là đường lùi chưa được chứng minh.** Bộ kiểm chạy mọi file lùi ở
   **mỗi** lần chạy (§4), không chỉ lúc viết.

**Khoá chặn bước 12** (2026-10-01, `T-126`, **ADR-075**): chỉ lùi khi hình cũ giữ nguyên
được dữ liệu. Có `remaining_before_vnd IS NOT NULL`, `remaining_vnd <> 0`, hoặc một hoá đơn
có hơn một lần trả ⇒ từ chối trước khi gỡ gì. Bảng rỗng hoặc chỉ có mỗi hoá đơn một lần trả đủ
(trước trống, sau 0) thì lùi được: hai cột bỏ đi không mang thông tin ngoài hình cũ. Đây là
trường hợp riêng của luật 2 theo quyết định trên; dữ liệu trả dần đã ghi phải đi bằng migration mới.

---

## 3. Khi một lệnh migration hỏng giữa chừng

Mỗi file là **một giao dịch** (`QC-05`). Thí nghiệm 2026-09-29 trên database riêng: một bước xuôi
tạo một bảng, thêm một cột vào `bill`, rồi hỏng ở câu thứ ba ⇒

```text
error: migration failed: division by zero …
phiên bản:            20260929000000|t        ← dirty
bảng và cột mới:      không có | 0            ← hai câu trước đã được gỡ cùng lúc
up lần nữa:           error: Dirty database version 20260929000000. Fix and force version.
```

Nghĩa là: **lược đồ không bao giờ đứng ở nửa bước**, nhưng công cụ đánh dấu *dirty* và từ chối mọi
lệnh sau cho tới khi có người gỡ dấu. Cách gỡ — ba bước:

1. Đọc lỗi; sửa nguyên nhân (một bước xuôi chưa commit thì sửa file; đã commit thì viết bước mới).
2. `docker compose run --rm migrate force <số>` với **số của bước lược đồ đang đứng trước lệnh
   hỏng** — **không** phải số `version` đang in. Sau một lệnh xuôi hỏng, `version` in số của bước
   vừa hỏng; sau một lệnh **lùi** hỏng (ví dụ bị khoá chặn), `version` in số của bước **dưới** nó
   kèm *dirty*, trong khi lược đồ vẫn nguyên ở bước trên — `db-check` in đúng cảnh ấy
   (`sau lệnh hỏng: 20260928130000 (dirty)`, rồi `force 20260928140000`).
3. `docker compose run --rm migrate version` ⇒ đúng số ấy, không còn *dirty*; chạy lại lệnh.

**Lỗi đã biết sẽ gặp trên dữ liệu thật** *(phiên suy ra từ review độc lập 2026-09-29, chưa chạy)*:
bước 8 thêm các cột *ai bấm* `NOT NULL` với mặc định lấy từ người của giao dịch. Chạy bước ấy trên
bảng **đã có dòng** thì mặc định ra trống và lệnh hỏng — an toàn nhờ giao dịch, nhưng bị chặn.
Không lỗi hôm nay vì mọi database dựng từ số không. Bước **mới** nào thêm cột bắt buộc vào bảng đã
có dòng phải tự cấp giá trị cho dòng cũ trong chính bước ấy.

---

## 4. Dựng lại từ số không — và chỗ chứng minh

**Dựng lại** database làm việc trên máy: `docker compose down -v`, `docker compose up -d --wait db`,
`docker compose run --rm migrate` (lệnh tắt: `make reset` ở `Makefile`, nạp cả dữ liệu mồi). Database
mất sạch — chỉ dùng cho máy phát triển.

**Chứng minh** nằm trong `./scripts/db-check.sh` (`QC-07`), chạy mỗi khi `db/`, `compose.yaml`,
script ấy hay `docs/product/2-db/` đổi, trên một database **riêng và rỗng**:

| Đòi hỏi | Dòng `db-check` in |
|---|---|
| **(a)** xuôi từ số không, từng bước | `PASS xuôi <file>` — một dòng mỗi bước |
| **(b)** lùi từng bước về số không, lược đồ sau mỗi lần lùi giống hệt ảnh chụp trước bước ấy | `PASS lùi <file> — lược đồ giống hệt lúc trước bước ấy (N dòng)` — một dòng mỗi bước |
| **(c)** xuôi lại cả dãy, giống hệt lần xuôi đầu | `PASS xuôi lại — N bước từ số không, …` |
| khoá chặn biết kêu | sau dữ liệu mồi: bước rỗng lùi được (`NOTE khoá chặn`), bước đầu có dữ liệu từ chối và lược đồ không đổi; gỡ dirty rồi xuôi lại đỉnh, giống hệt trước bước 5 (`PASS khoá chặn — …` · `PASS force …`, kèm số bước rỗng) |

Ảnh chụp là `pg_dump --schema-only` của schema `shop` — gồm bảng, cột, ràng buộc, chỉ mục, hàm,
trigger **và quyền** — bỏ dòng chú thích và cặp dòng `\restrict` có khoá ngẫu nhiên mỗi lần chạy.

**Tên bảng giữa tài liệu và migration** (**ADR-053** luật 2): `./scripts/check-schema-names.sh`
(Gate 1e), chạy **mọi** lượt trong `./scripts/gate.sh`, kể cả lượt chỉ đổi tài liệu. Nó in cả hai
danh sách đầy đủ rồi kết quả `comm -3` (**F-017**); đọc cái gì và không bắt cái gì: header của
script. Lệch ⇒ một dòng `F-XXX`, không sửa migration cho khớp chữ.

---

## 5. Đường lùi của lược đồ không phải phục hồi dữ liệu

Đường lùi ở đây trả **lược đồ** về bước trước, và chỉ khi chỗ bị gỡ còn rỗng. Nó **không** đưa lại
một bản ghi nào đã mất: dựng lại từ số không cho ra một database **rỗng**, và **YC-21** nói thẳng
*dựng lại một cơ sở dữ liệu rỗng hoặc nhập dữ liệu mồi không đáp ứng yêu cầu này*. Chặn `RR-9` (mất
hẳn bản ghi đã ghi, [`06-so-rui-ro.md`](../1-system-design/06-so-rui-ro.md)) là sao lưu và phục
hồi thử, thiết kế và nghiệm thu ở pha 5 qua **T-109** (**ADR-057**). `P2-09` xanh không làm dòng
`RR-9` bớt ⛔.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| mọi lượt thêm migration | §1 *Thêm một bước* · §2 bốn câu · §3 lỗi đã biết |
| `P2-11` · `P2-13` | §4 — database nền dựng từ số không, cùng lệnh |
| pha 5 (**T-109**) | §3 cách gỡ lệnh hỏng khi triển khai một bước lên máy thật · §5 ranh giới với YC-21 |

[↑ đầu file](#top)
