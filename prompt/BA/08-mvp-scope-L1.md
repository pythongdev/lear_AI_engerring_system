# 08 — Phạm vi MVP (L1) · BA-09

> L1: mục này không tự đặt ra luật nghiệp vụ mới, chỉ khoanh vùng cái đã chốt ở BA-01–BA-08.
> Nếu trong lúc làm phát hiện phải chốt một luật mới → dừng, đó là dấu hiệu task bị lẫn level.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §9 (làm / chưa làm),
  §13 (rủi ro đi sớm vào kỹ thuật).
- Nguồn dữ kiện: `master_plan/shop-facts.md` §2 (4 kênh), §3 (5 trạm), §6.5–§6.6
  (đối soát cuối ngày, sổ giấy dự phòng).
- Đích: `docs/product.md` §7.
- Đã chốt trước đó: §1–§6.

## Goal

`docs/product.md` §7 chốt danh sách năng lực có trong MVP và danh sách rõ ràng những thứ **không**
làm ở giai đoạn đầu, để mọi task sau này có chỗ đối chiếu khi bị đề nghị mở rộng.

## Scope

Được sửa:
- `docs/product.md` §7

Không được sửa:
- §1–§6, §8 của `docs/product.md`
- `docs/decisions.md`, `quality/invariants.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
work/backlog.md
```

## Constraints

- Danh sách "làm" phải bám đúng §9 kế hoạch gốc. Không tự thêm năng lực nghe hợp lý
  (loyalty, khuyến mãi, đặt bàn trước, đánh giá món, tách/gộp bàn, tích điểm...).
  `shop-facts.md` không nhắc tới bất kỳ thứ nào trong số đó ⇒ mặc định là **ngoài MVP**.
- Hạng mục "Điều phối công việc tới các trạm" phải khoanh đúng **5 trạm** ở `shop-facts.md` §3,
  không mở rộng thành "cấu hình trạm tuỳ ý".
- Hai hạng mục vận hành phải nằm trong MVP vì `shop-facts.md` §6.5–§6.6 coi chúng là bắt buộc:
  **đối soát doanh thu cuối ngày với sổ giấy và tiền két**, và **quy trình sổ giấy khi mất
  điện/mất mạng**. Chúng là việc của quán, không phải tính năng phần mềm — ghi rõ như vậy.
- Mỗi mục trong danh sách "làm" phải trỏ được về một mục đã mô tả ở §1–§6. Mục nào không trỏ
  được → hoặc là thừa, hoặc là §1–§6 còn thiếu; ghi vào Report, không tự viết bù.
- Phần "không làm" phải ghi kèm lý do ngắn, để sau này không ai mở lại bằng cảm tính.
- Không liệt kê hạng mục kỹ thuật (kiến trúc BE/FE, schema, endpoint, Docker/CI) như một
  năng lực MVP — chúng thuộc System Design, chỉ được nhắc trong phần "chưa chi tiết ở BA phase".

## Acceptance

- §7 có hai danh sách tách bạch: "Trong MVP" và "Ngoài MVP (giai đoạn đầu không làm)".
- Danh sách "Trong MVP" phủ đủ 14 hạng mục ở §9 kế hoạch gốc.
- Mỗi hạng mục trong "Trong MVP" có tham chiếu tới mục §1–§6 mô tả nó.
- Mỗi hạng mục "Ngoài MVP" có một câu lý do.
- Có câu khẳng định: yêu cầu ngoài danh sách MVP không được làm trong giai đoạn này mà phải
  vào `work/backlog.md`.
- "Ngoài MVP" nêu đích danh ít nhất: khuyến mãi/giảm giá, tích điểm, tách/gộp bàn, đặt bàn trước.
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
