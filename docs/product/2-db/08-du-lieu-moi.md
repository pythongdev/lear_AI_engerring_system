# Dữ liệu mồi — menu thật, bàn, trạm của thành phần

Pha 2 · bước `P2-10` · viết 2026-09-28 (Claude Code). Tên file đúng đề xuất của kế hoạch pha 2 §5.

**Dữ liệu mồi không nằm trong một file dữ liệu nào.** Nó được **sinh lúc chạy** bởi
[`db/seed/seed.pl`](../../../db/seed/seed.pl), đọc thẳng
[`master_plan/shop-facts.md`](../../../master_plan/shop-facts.md) rồi in ra SQL. Không file nào dưới
`db/` hay `docs/product/2-db/` mang một con giá, một mức phụ thu, một số lượng thành phần hay số bàn
của quán — kể cả file này (**ADR-001**, `work/findings.md` **F-001**). Chủ quán đổi giá ở owner ⇒
lần dựng sau mang giá mới, không có bản thứ hai nào để trôi.

**File này KHÔNG sở hữu:**
- **giá, thành phần suất, phụ thu, danh sách món, số bàn, trạm** — `master_plan/shop-facts.md` §1 ·
  §3 · §4 · §5.3;
- **chỗ cất** — các file lát: [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md) (bàn, mã QR),
  [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md) (bảy bảng menu),
  [`05-luoc-do-san-xuat.md`](05-luoc-do-san-xuat.md) (trạm của thành phần); tên · kiểu · ràng buộc
  thắng ở file migration (**ADR-053** luật 2);
- **hàm tính giá** — pha 3. Phép cộng ở §3 chỉ chứng minh dữ liệu **đủ** cho hàm ấy.

---

## 0. Cách chạy

`./scripts/db-check.sh` (`QC-07`) dựng dữ liệu mồi ở **bước 4**, sau mọi test (các test chạy trên
database rỗng), rồi tính lại các ca giá của `shop-facts.md` §4.8. Vào database làm việc — **một lần**,
ngay sau khi chạy migration trên database rỗng; bộ SQL không chạy lại được trên chính nó (tên món,
tên bàn là khoá duy nhất):

```text
docker compose up -d --wait db && docker compose run --rm migrate
perl db/seed/seed.pl | docker compose exec -T db psql -X -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon
```

Bộ SQL là **một giao dịch** và ghi bằng vai **`shop_app`** (`QC-03`) — vai hệ thống dùng, không phải
vai dựng lược đồ: dữ liệu mồi đi đúng đường quyền mà dữ liệu thật sẽ đi.

---

## 1. Dựng gì, tra ở đâu

| Bảng | Đọc từ owner | Cách đọc |
|---|---|---|
| `dining_table` | §1 dòng *Số bàn* | một bàn mỗi số, tên `1`…*N* — §1 chốt bàn mang tên theo số, không khu, không tên khác |
| `qr_code` | — | mỗi bàn một mã, sinh **qua** `qr_code_issue` (`I-023`, `02-luoc-do-ban-hang.md` §2 hàng `I-023`), không chèn thẳng |
| `menu_component` | §4.2 | một hàng một họ thành phần; giá gốc là cột *Chay* (§4.6 luật 2); *nhận nhân* khi ba cột giá không bằng nhau |
| `option_group` · `menu_option` | §4.4 bảng đầu | tên nhóm là chữ đậm của cột *Nhóm tuỳ chọn*; phụ thu là cột *Món lẻ* — mức cho **mỗi** phần nhận nhân (§4.4 câu dưới bảng, §4.6 luật 5) |
| `option_group_prerequisite` | §4.4 cột *Nhóm tuỳ chọn*, cụm *khi … ≠ …* | tập điều kiện = mọi lựa chọn của nhóm được nhắc, trừ lựa chọn sau dấu ≠ (§4.6 luật 3) |
| `menu_item` | §4.9 cột *Chủ quán gọi tên* | mỗi hàng một dòng menu; tên hiển thị ở §2 |
| `menu_item_component` | §4.5 cột *Bếp làm ra* | *số · loại từ · tên*, nối bằng ` + `; tên nối về họ thành phần của §4.2 |
| `menu_item_option_group` | §4.4 · §4.8 ca 12 | mọi nhóm của §4.4 gắn cho dòng menu có **ít nhất một** phần nhận nhân; dòng không có phần nào (giò bán rời, canh) không mang nhóm nào |
| `menu_component_station` | §5.3 khối ví dụ · §3 | mỗi dòng *trạm │ thứ* nối *thứ* về họ thành phần; dòng không nối được (nước chấm) là việc cấp đơn, không thuộc thành phần nào |

**Kiểm chéo hai owner lúc đọc.** Ba cột giá của §4.2 phải bằng *giá chay + phụ thu §4.4* của từng
tổ hợp nhân · lượng nhân; lệch ⇒ bộ dựng dừng và in hai con số. Đây là cùng một luật (§4.6 luật 1 ·
2 · 5) viết ở hai bảng, và lúc hai bảng cãi nhau thì không phiên nào được chọn hộ bên đúng.

**Owner đổi hình ⇒ FAIL, không dựng nửa chừng.** Bộ dựng dừng (exit 1, in chỗ hỏng) khi: một hàng
§4.9 chưa có trong bảng ánh xạ của nó hoặc bảng ánh xạ có hàng mà §4.9 không còn; một phần ở §4.5
không nối được về §4.2; một thành phần không xuống trạm nào; một ô tiền không đọc được thành số.

---

## 2. Phiên chọn 2026-09-28 — chưa có lời chủ repo

Đổi được bằng một lần sửa bộ dựng kèm lý do ở đây, trước khi code pha 3 dựa vào nó.

- **Ba loại trứng là ba thành phần**, cùng giá vì cùng một hàng §4.2 (gỡ hàng *trứng chín / tái /
  vàng* ở `03-luoc-do-menu-gia.md` §5). Lý do: khoá gom của bếp là *thành phần + loại nhân + lượng
  nhân* (`05-luoc-do-san-xuat.md` §1); một thành phần *trứng* duy nhất thì trứng tái và trứng chín
  cùng nhân sẽ gộp vào một mẻ, trong khi §5.3 in *Trứng tái ×2* thành một dòng riêng. Bị loại: *một
  thành phần, loại trứng là một nhóm tuỳ chọn* — §4.4 không có nhóm ấy, và dựng thêm một nhóm là
  thêm một luật mà owner không viết.
  **Chủ repo xác nhận 2026-09-30**, nguyên văn: *"ba loại trứng này là 3 quả khác nhau. 1 suất
  trứng khách có thể gọi suất trứng tái, trứng chín hoặc trứng vàng"* — gạch này không còn là phiên
  chọn. Hai gạch dưới vẫn là phiên chọn.
- **Trạm của trứng chín và trứng vàng đọc theo trứng tái.** Khối §5.3 chỉ in trứng tái; §3 ghi trạm
  `trang_banh` *làm trứng* không phân loại, nên bộ dựng gán trạm theo **họ** thành phần, không theo
  từng loại. Đây là **suy ra**, không phải lời chủ quán.
- **Tên dòng menu** lấy lời chủ quán ở §4.9 (*đầy đủ trứng chín*…), viết hoa chữ đầu; hai dòng lấy
  tên ở §4.3 vì lời §4.9 ngắn hơn một tên món: *Giò bán rời* (chủ quán gọi *giò*, trùng tên thành
  phần) và *Bánh cuốn*. Bảng ánh xạ ở đầu `db/seed/seed.pl` chỉ giữ **tên**, không con số nào, và
  được đối chiếu hai chiều với §4.9 mỗi lần chạy.
- **Kỳ vọng của các ca giá đọc thẳng từ bảng §4.8**, không gõ lại; tên món của ca nối về dòng menu
  qua cùng bảng ánh xạ.

---

## 3. Bằng chứng

`./scripts/db-check.sh`, 2026-09-28, trên database rỗng dựng từ số 0: dựng xong mọi bảng ở §1 (số dòng từng bảng in
ở output), mỗi bàn đúng một mã hiện hành; rồi **mọi** ca của §4.8 khớp từng đồng — ca 11 ra *từ chối*, ca 13 ra một dòng 0đ vẫn có
mặt. Output nguyên văn dán ở `work/backlog_DB.md` → `P2-10` *Bàn giao*.

**Biết kêu** — cùng lệnh, chạy trên một bản sao hỏng của owner (biến môi trường `SHOP_FACTS`, chỉ để
thử; mặc định luôn là owner):

| Làm hỏng | Kết quả |
|---|---|
| §4.5 suất giò bớt một bánh | ca 8 **lệch**, `db-check: FAIL` — dữ liệu mồi sai thì ca giá đỏ, **không** sửa ca |
| §4.2 một ô giá không còn bằng chay + phụ thu §4.4 | bộ dựng dừng, in hai con số |
| §4.9 thêm một món chưa ánh xạ | bộ dựng dừng, gọi tên món |
| §5.3 bỏ dòng giò | bộ dựng dừng: *Giò không xuống trạm nào* |

---

## 4. Chỗ trống có tên

| Chỗ trống | Hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| **Người** — bốn vai, chủ quán (`shop-facts.md` §3) | **dựng 2026-09-28 (`P2-08`)**: một người cho mỗi dòng bảng *Vai* của §3, đọc lúc chạy, cộng chủ quán (`is_owner`); tên hiển thị là **tên vai** — quán chưa khai tên ai. Chủ quán là người thao tác lúc cấp mã QR (U-062). *Ai đứng trạm nào* không mồi: chỉ quầy có mốc đổi, và POS khai lúc bán thật | `P2-08` — xong; tên người thật là việc của quán |
| **Số chỗ ngồi của bàn** (§1) | không cột nào cất; dữ liệu mồi không dựng | — cần thì một migration mới |
| **Ô giá ⚠ của giò bán rời** (`S-9`, §7.2) | dựng đúng ô owner đang ghi; ca 12 khớp ô ấy. Chủ quán đọc ô khác ⇒ owner đổi, dữ liệu mồi đổi theo | chủ quán |
| **Bắt buộc chọn một nhân** và **mặc định Thịt · Thường** (§4.4 · §4.6 luật 7 · 8) | không cất (`03-luoc-do-menu-gia.md` §5); các ca của §4.8 đều ghi rõ lựa chọn nên không cần mặc định | pha 3 |
| **Lượt chỉ sửa `shop-facts.md`** không gọi bộ kiểm | cổng coi file `.md` là tài liệu và bỏ qua `verify.sh`, nên đổi giá ở owner **không** tự chạy lại các ca giá | lượt sửa giá chạy tay `./scripts/db-check.sh` |
| **Dựng lại trên database đã có dữ liệu** | không làm được — chỉ vào database rỗng | `P2-09` (thứ tự dựng lại từ số không) |

---

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-11` | bộ đối chiếu chạy trên database **sau bước 4** của `db-check.sh` ⇒ phải ra 0 dòng trên dữ liệu mồi |
| `P2-13` | ba scenario dựng đơn trên menu này, không tự gõ món |
| `P2-08` | **xong 2026-09-28** — §4 hàng *Người*; [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) |
| pha 3 | §2 — ba loại trứng là ba thành phần; hàm tính giá phải ra đúng mọi ca của §4.8 như §3 |
