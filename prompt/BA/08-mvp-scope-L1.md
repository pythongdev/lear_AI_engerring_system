# 08 — Phạm vi MVP (L1) · BA-09

> L1: mục này không tự đặt ra luật nghiệp vụ mới, chỉ khoanh vùng cái đã chốt ở BA-01–BA-08.
> Nếu trong lúc làm phát hiện phải chốt một luật mới → dừng, đó là dấu hiệu task bị lẫn level.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §9 (làm / chưa làm),
  §13 (rủi ro đi sớm vào kỹ thuật).
- Nguồn số: `master_plan/shop-facts.md` §2 (**5 kênh**), **§6.12 (bảng "Ngoài phạm vi" — 4 dòng đã chốt)**.
- Nguồn quy tắc: `master_plan/shop-facts.md` §3 (5 trạm), §6.12 (ranh giới đã chốt),
  §6.5–§6.6 (đối soát cuối ngày, sổ giấy dự phòng).
- Đích: `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.
- Đã chốt trước đó: §1–§6.

## Goal

`docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7 chốt danh sách năng lực có trong MVP và danh sách rõ ràng những thứ **không**
làm ở giai đoạn đầu, để mọi task sau này có chỗ đối chiếu khi bị đề nghị mở rộng.

## Scope

Được sửa:
- `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7

Không được sửa:
- §1–§6, §8 của `docs/product/0-ba/ban-hang/`
- `docs/decisions.md`, `quality/invariants.md`, `docs/product/1-system-design/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product/
work/backlog.md
```

## Constraints

- Danh sách "làm" phải bám đúng §9 kế hoạch gốc. Không tự thêm năng lực nghe hợp lý
  (loyalty, khuyến mãi, đặt bàn trước, đánh giá món, tách/gộp bàn, tích điểm...).
  Không nguồn nào nhắc tới chúng ⇒ mặc định là **ngoài MVP**.
- **Bốn dòng ở `shop-facts.md` §6.12 là ranh giới đã chốt, không phải chỗ trống chờ điền**, chép nguyên
  ý vào phần "Ngoài MVP" kèm chữ *quyền chủ quán*: kênh bán **thứ sáu** · **đơn tối thiểu / bậc
  phí ship** · số tài khoản ngân hàng cứng trong sản phẩm · **món ngoài bảng giá**.
  Khác biệt quan trọng: mấy thứ này ngoài MVP vì **chủ quán đã quyết không làm**, không phải vì
  "để sau" — viết đúng lý do đó.
- Hạng mục "Điều phối công việc tới các trạm" phải khoanh đúng **5 trạm** ở `shop-facts.md` §3,
  không mở rộng thành "cấu hình trạm tuỳ ý".
- Hai hạng mục vận hành phải nằm trong MVP vì `shop-facts.md` §6.10–§6.11 coi chúng là bắt buộc:
  **đối soát doanh thu cuối ngày với sổ giấy và tiền két**, và **quy trình sổ giấy khi mất
  điện/mất mạng**. Chúng là việc của quán, không phải tính năng phần mềm — ghi rõ như vậy.
- Mỗi mục trong danh sách "làm" phải trỏ được về một mục đã mô tả ở §1–§6. Mục nào không trỏ
  được → hoặc là thừa, hoặc là §1–§6 còn thiếu; ghi vào Report, không tự viết bù.
- Phần "không làm" phải ghi kèm lý do ngắn, để sau này không ai mở lại bằng cảm tính.
- Không liệt kê hạng mục kỹ thuật (kiến trúc BE/FE, schema, endpoint, Docker/CI) như một
  năng lực MVP — chúng thuộc System Design, chỉ được nhắc trong phần "chưa chi tiết ở BA phase".

## Acceptance

- §7 có hai danh sách tách bạch: "Trong MVP" và "Ngoài MVP (giai đoạn đầu không làm)".
- Danh sách "Trong MVP" phủ đủ 14 hạng mục ở §9 kế hoạch gốc. Hạng mục "Bốn kênh bán" ghi lại
  thành **năm** kênh theo `shop-facts.md` §2, kèm một dòng nói rõ kế hoạch gốc viết lúc chưa có
  `phone_preorder`.
- Mỗi hạng mục trong "Trong MVP" có tham chiếu tới mục §1–§6 mô tả nó.
- Mỗi hạng mục "Ngoài MVP" có một câu lý do.
- Có câu khẳng định: yêu cầu ngoài danh sách MVP không được làm trong giai đoạn này mà phải
  vào `work/backlog.md`.
- "Ngoài MVP" nêu đích danh ít nhất: khuyến mãi/giảm giá, tích điểm, tách/gộp bàn, đặt bàn trước,
  và **đủ 4 dòng ở `shop-facts.md` §6.12** với lý do là *chủ quán đã quyết*, không phải *để sau*.
- Đối soát cuối ngày và quy trình sổ giấy có mặt trong "Trong MVP".
- Không có hạng mục nào là công việc kỹ thuật thuần (schema, endpoint, CI).

## Verify

```bash
./scripts/gate.sh
grep -nEi 'schema|endpoint|docker|ci/cd|framework' docs/product.md   # chỉ được xuất hiện trong "chưa chi tiết ở BA phase", không nằm trong danh sách MVP
git status --porcelain
```
Gate 2: đối chiếu từng dòng của §9 kế hoạch gốc với §7 tài liệu; thiếu dòng nào = chưa đạt.

## Unknowns

- Báo cáo doanh thu "cơ bản" gồm những chỉ số nào?
- "Quản lý nhân viên cơ bản" ở MVP gồm những thao tác nào?
- "Cơ chế dự phòng khi realtime không hoạt động" ở mức nghiệp vụ nghĩa là quán làm gì?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết (đặc biệt: hạng mục MVP nào chưa có mô tả ở §1–§6)
