# §1.6 — Mảng QUẢN TRỊ (admin)

> Nguyên văn `docs/product.md` §1.6, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §1.6: ~180 câu trong repo trỏ theo số cũ.
> Mục có nhãn của mảng admin — `docs/decisions.md` **ADR-013**.

<!-- ==== nguyên văn docs/product.md §1.6, tách 2026-09-02 ==== -->
### 1.6 Mảng QUẢN TRỊ (admin) — ranh giới riêng của ba mảng mới

**Mục này là chỗ duy nhất của tài liệu này nói về mảng quản trị.** §1.4 là ranh giới của mảng **bán
hàng** — đơn, bàn, giá, bếp, thu tiền. Mục này là ranh giới của mảng **chạy quán**: nguyên liệu,
con người, tài chính. Tách ra vì hai mảng đổi vì hai lý do khác nhau; trộn lại thì mỗi lần sửa một
mảng là một lần đọc nhầm mảng kia.

**Ba mảng nằm TRONG phạm vi — chủ quán chốt 2026-09-01, xác nhận lại 2026-09-02.**

| Mảng | Gồm những gì |
|---|---|
| **Nguyên liệu** | thứ quán mua vào, nhập, dùng, hao hụt, còn lại |
| **Con người** | ai làm, ai trực trạm nào, công, lương |
| **Tài chính** | tiền vào tiền ra ngoài tiền hàng — chi phí, lãi lỗ, quỹ |

Tới 2026-09-01, §1.4 còn một dòng cuối trong danh sách *KHÔNG chịu trách nhiệm*: *"Không quản lý
nguyên liệu, tồn kho, chấm công hay kế toán"*. Lời chốt **lật ngược đúng câu ấy**, nên dòng đó bị
**xoá**, không phải chuyển chỗ. `docs/product/1-system-design/architecture.md` §14 giữ mặt kiến trúc của cùng lời chốt, và
`master_plan/shop-facts.md` §8 là nhà thật của dữ kiện ba mảng này.

**Mở ranh giới chưa phải là có luật.** Ba mảng nay **được phép** có mặt, và hôm nay chỉ có thế:

- Tài liệu này **chưa có một quy tắc nghiệp vụ nào** cho chúng — §2 tới §6 vẫn chỉ nói về việc bán
  hàng. Đọc sự im lặng đó thành *"chưa quyết"*, đừng đọc thành *"không làm"*.
- **Sâu tới đâu là quyết định riêng và chưa nằm ở đây.** Mảng nguyên liệu làm tới mức nào, mảng con
  người làm tới mức nào — hai câu ấy chưa được ghi vào owner nào; việc chuyển chúng về còn nằm
  trong `work/backlog.md`.
- **Mảng nào vào MVP là câu của §7 (BA-09)**, không phải câu của mục này. Ranh giới nói *được phép
  làm*; §7 nói *làm ngay bây giờ*. Hai câu khác nhau và không được trộn.

**Bốn ranh giới ở `shop-facts.md` §6.12 KHÔNG bị lời chốt này chạm tới** — kênh bán thứ sáu, đơn
tối thiểu và bậc phí ship, số tài khoản cứng trong sản phẩm, món ngoài bảng giá. Cả bốn vẫn là *đã
quyết định không làm*, và thêm bất kỳ thứ nào vẫn phải xin phép chủ quán.

**Luật viết cho mọi lần cập nhật admin sau này:** nội dung admin vào **mục riêng có nhãn**, không
chen vào mục của mảng bán hàng — `docs/decisions.md` **ADR-013**.

