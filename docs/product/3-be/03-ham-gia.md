<a id="top"></a>
# Hàm tính giá — một hàm, ba đường gọi, một cửa tạo lượt gọi

Pha 3 · bước `P3-06` · viết 2026-10-06 (Claude Code). Vì sao thiết kế thế này và cái bị loại:
`docs/decisions.md` **ADR-086**.

**File này sở hữu:** cách backend **đọc** luật giá — hàm nào tính, đọc bảng nào, kiểm theo thứ tự nào,
ai gọi nó — và bảng ca test của hàm ấy; cùng danh sách chỗ trống của lát.

**File này KHÔNG sở hữu:**
- **giá, phụ thu, thành phần, danh sách món, luật cấu tạo giá** — `master_plan/shop-facts.md` §4.2–§4.9.
  Không một con giá nào của quán nằm ở đây hay trong `be/` (**F-001**);
- **tầng bảo vệ** của `I-009` · `I-010` · `I-011` · `I-013` —
  [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md);
- **chỗ cất** menu và ảnh chụp — migration, ý định ở [`../2-db/03-luoc-do-menu-gia.md`](../2-db/03-luoc-do-menu-gia.md);
- **đường gọi, chữ ký, mã lỗi** — [`openapi.yaml`](openapi.yaml); **lớp quyền của cửa** —
  [`02-vai-va-quyen.md`](02-vai-va-quyen.md).

---

## 1. Một hàm

`gia.Tinh` ở `be/internal/gia/` là **chỗ duy nhất** cộng giá. Nó nhận các dòng *món · số suất · mã lựa
chọn* — **không** một trường giá nào — đọc menu **trong giao dịch của người gọi**, tại `now()` của giao
dịch ấy, và trả mỗi dòng: tên món, đơn giá, thành tiền, ảnh chụp thành phần và tuỳ chọn đã tính.

Công thức là luật 1 và luật 5 của `shop-facts.md` §4.6, đọc trên dữ liệu: đơn giá = tổng *số lượng ×
giá gốc* của các thành phần của suất, cộng *số phần nhận nhân* × tổng phụ thu của các lựa chọn đã chọn.
Số phần nhận nhân đọc ra từ thành phần (`takes_filling`), không cất ở đâu — nên hệ số ×1 · ×4 · ×5 của
§4.4 là kết quả, không phải dữ liệu.

**Kiểm theo đúng thứ tự**, từng dòng theo thứ tự gửi, lời từ chối đầu tiên thắng, `field` chỉ về
`lines[i].<trường>`:

| # | Điều kiện | Mã | Nguồn |
|:--:|---|---|---|
| 1 | không dòng nào | `invalid_request` (`lines`) | `01-hop-dong-api.md` §3 |
| 2 | số suất < 1 | `invalid_request` (`quantity`) | — |
| 3 | món không tồn tại | `menu_item_not_found` | — |
| 4 | món đã ngừng bán tại mốc giao dịch | `menu_item_discontinued` | `I-009` tầng 3 · **ADR-056** |
| 5 | một mã lựa chọn không tồn tại | `menu_option_not_found` | — |
| 6 | tổ hợp sai (dưới) | `option_combination_invalid` | `I-010` · §4.6 luật 3 · 7 |

**Tổ hợp đúng** khi: không mã nào lặp; mỗi lựa chọn thuộc một nhóm mà món **mang**; mỗi nhóm **có
mặt** có **đúng một** lựa chọn; nhóm **không có mặt** không có lựa chọn nào. Nhóm có mặt khi món mang
nó **và** nó không có điều kiện, hoặc ít nhất một lựa chọn trong tập điều kiện của nó được chọn
(`option_group_prerequisite` — *Lượng nhân chỉ có khi nhân ≠ Chay* là hai dòng, đọc theo tập).

**Từ chối, không sửa hộ, không tự điền.** Cửa không bao giờ thêm, bỏ hay đổi một lựa chọn để yêu cầu
thành hợp lệ (`I-010`) — kể cả mặc định *Thịt · Thường* của luật 8: dữ liệu chưa có chỗ cất mặc định,
nên dòng thiếu nhân bị từ chối (**F-059**).

## 2. Ba đường gọi

| Đường | Là gì | Ghi gì |
|---|---|---|
| `POST /price-quotes` | **tính thử** — khách, quầy, ai cũng gọi được; trường giá gửi kèm bị bỏ (`I-013`) | không |
| `GET /menu` | món đang bán, nhóm tuỳ chọn, và **giá của mọi tổ hợp hợp lệ** — mỗi giá tính bằng `gia.Tinh`. FE nhận kết quả, không nhận công thức (`01-hop-dong-api.md` §5) | không |
| cửa `don/tao_luot_goi` | **ghi một lượt gọi** — gọi `gia.Tinh` trong giao dịch của cửa **trước** mọi câu ghi, rồi chép đúng kết quả vào dòng đơn và ảnh chụp | `sales_order` · `order_line` · `order_line_component` · `order_line_option` |

Vì cả ba gọi cùng một hàm, con số khách thấy ở tính thử và con số quầy ghi vào đơn chỉ khác được khi
menu đổi giữa hai lần gọi — và khi ấy con số trên đơn là con số đúng **tại mốc lượt gọi của nó**
(`I-009`: mốc khoá là từng lượt gọi; một phiên vắt qua lần đổi giá mang hai mức giá là đúng).

**Cửa tạo lượt gọi là MỘT cho cả năm kênh** (**ADR-086** điểm 2). Lát này dựng phần **giá** của nó và một
lối vào: người đứng quầy đặt hộ vào một phiên bàn đã có (`staff_pos`, trạng thái `new` —
`05-vong-doi.md` §5.2 dòng đầu), lớp `quay`, **chưa có đường gọi HTTP**. Phần kênh vào **chính cửa này**
ở `P3-07` · `P3-08` (§4).

## 3. Bảng ca test — đọc lúc chạy, không gõ lại

Test của ba đường gọi đọc ca giá từ `shop-facts.md` §4.8 **lúc chạy**:

```sh
perl db/seed/seed.pl --price-cases-tsv   # số ca · dòng menu · số suất · nhóm=lựa chọn|… · giá hoặc REJECT
```

Cùng bộ đọc với `--price-cases` của `P2-10` (dữ liệu mồi tính lại §4.8 bằng SQL), nên hai pha đọc một
bảng bằng một chương trình. Test nạp menu thật bằng `perl db/seed/seed.pl`, rồi chạy **mọi** ca qua tính
thử, qua menu **và** qua cửa ghi đơn; ca bị từ chối phải bị từ chối ở cả ba, bốn bảng đơn đứng nguyên.
Ca của test sửa menu dùng menu **giả** riêng (`test-…`), không chạm menu thật mà các ca §4.8 đọc.

| Test | Chứng minh |
|---|---|
| `be/internal/gia/gia_test.go` | §4.8 qua tính thử và qua menu; giá gửi lên bị bỏ; năm hình tổ hợp sai; món ngừng bán; yêu cầu sai hình |
| `be/internal/don/don_test.go` | §4.8 qua cửa ghi đơn = con số tính thử; quyền của quầy; một dòng sai ⇒ cả lượt gọi bị từ chối; sửa menu sau khi đặt ⇒ đơn cũ đứng nguyên, lượt gọi mới cùng phiên ăn giá mới; món ngừng bán bị cửa từ chối |
| `be/internal/menu/menu_test.go` | bốn cửa của chủ quán: chỉ chủ quán, bắt buộc lý do, mỗi lần sửa một vết mang người và lý do, không đường gọi nào nhận giá suất |

## 4. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **Mặc định *Thịt · Thường*** (§4.6 luật 8) | không có chỗ cất; dòng thiếu nhân bị từ chối | **F-059** — trước khi pha 4 dựng màn gọi món |
| **Đường gọi HTTP của cửa tạo lượt gọi**, mở phiên từ lượt gọi đầu, lối vào của khách QR | chưa có; cửa nhận lượt gọi của quầy vào phiên đã có | `P3-07` |
| **Bốn kênh ngoài bàn**, liên hệ tối thiểu (`I-022`) | chưa có lối vào | `P3-08` |
| **Giờ bán · tạm dừng · quán mù** (`I-008`) trước khi tạo lượt gọi | cửa chưa xét | `P3-08` · `P3-12` |
| **Dấu lần gửi trùng** (`I-024`) — gửi lại nhận lại đúng đơn | cửa chưa xét; dòng `sales_order_submission_code_key` còn `unreviewed` | `P3-07` |
| **Lời nhắc *đang trong giờ bán*** trước khi đổi thành phần suất (`I-011`) | máy giữ vết (người · lúc · cái gì); lời nhắc chưa có | pha 4, đọc nguồn giờ bán của cửa `I-008` |
| **Thêm · bỏ một thành phần của suất**, đổi tên món, bán lại món đã ngừng | chưa có cửa; bỏ một thành phần còn vướng *không xoá* (`QD-50`) | khi chủ quán cần — một lát sau, kèm ADR nếu cần đổi lược đồ |
| **Yêu cầu gốc của khách** (vế *"tổ hợp khác tổ hợp khách gửi"* của đối chiếu `I-010`) | không cất: cửa từ chối chứ không sửa, nên tổ hợp đã ghi **là** tổ hợp đã gửi | — |

[↑ đầu file](#top)
