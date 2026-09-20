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
- **Sâu tới đâu là quyết định riêng: nguyên liệu ĐÃ chốt 2026-09-04, con người ĐÃ chốt
  2026-09-20, tài chính thì chưa.** Mức của hai mảng đã chốt ở hai khối có nhãn bên dưới; mảng
  **tài chính** làm tới mức nào vẫn chưa được ghi vào owner nào.
- **Mảng nào vào MVP là câu của §7 (BA-09)**, không phải câu của mục này. Ranh giới nói *được phép
  làm*; §7 nói *làm ngay bây giờ*. Hai câu khác nhau và không được trộn.

**Bốn ranh giới ở `shop-facts.md` §6.12 KHÔNG bị lời chốt này chạm tới** — kênh bán thứ sáu, đơn
tối thiểu và bậc phí ship, số tài khoản cứng trong sản phẩm, món ngoài bảng giá. Cả bốn vẫn là *đã
quyết định không làm*, và thêm bất kỳ thứ nào vẫn phải xin phép chủ quán.

**Mức sâu của mảng NGUYÊN LIỆU — chủ quán chốt 2026-09-01, xác nhận lại 2026-09-04.** Mảng nguyên
liệu làm ở mức **sổ ghi tay điện tử**: người nhập con số, máy giữ và cộng lại; **máy không tự trừ
tồn theo công thức** mỗi lần bán một suất. Hai hệ quả về **hành vi** — thứ mục này sở hữu:

- **Không thao tác bán hàng nào ở §2–§6 làm đổi con số nguyên liệu.** Bán một suất, huỷ một đơn,
  hoàn một lần tiền — không việc nào trong số đó được tự động cộng trừ kho. Đường duy nhất để một
  con số nguyên liệu đổi là **có người nhập nó**.
- **Có một mục tổng, nhập theo ngày, do chủ quán tự nhập** (*"có mục tổng lưu trữ hàng ngày tôi sẽ
  nhập số liệu"*, 2026-09-04). *"Số liệu"* ấy là **HAI con số** — đồ mua vào trong ngày, và đồ đã
  dùng trong ngày, để chủ quán tự biết thừa/thiếu (chủ quán chốt 2026-09-06, đóng **U-034** ở
  [99-unknowns.md](../../99-unknowns.md)). Danh mục cụ thể — thứ nào, đơn vị gì — **vẫn chưa chốt**.

Dữ kiện đầy đủ của lời chốt này — gồm cả cửa mở lại nó — ở `master_plan/shop-facts.md` **§8.4**.

**Mức sâu của mảng CON NGƯỜI — chủ quán chốt 2026-09-01, xác nhận lại 2026-09-20.** Mảng con người
làm tới **cả ba mức**: *ai đang trực trạm nào* · *chấm công* · *tính lương trên máy*. Dữ kiện đầy
đủ — ba mức ấy nói chính xác cái gì, và cái gì **không** đi kèm — ở `master_plan/shop-facts.md`
**§8.7**; mục này **không** nhắc lại lời chốt bằng lời của mình (`work/findings.md` **F-001**). Hệ
quả về **hành vi** — thứ mục này sở hữu:

- **Mảng con người có mặt ở cả ba mức không làm đổi một luật bán hàng nào của §2–§6.** Nó là một
  mảng đứng riêng, đọc vào bảng vai của `master_plan/shop-facts.md` §3; nó không thêm trạm, không
  thêm vai, không đổi luật huỷ đơn hay hoàn tiền.
- **Lời chốt này chốt MỨC, không chốt con số.** Đơn giá công, kỳ trả lương, quyền xem bảng lương —
  không câu nào có lời (`work/admin-questions.md` §3, các câu `C23`…`C35`). Đọc sự im lặng ấy thành
  *"chưa quyết"*, đừng đọc thành *"không làm"*.
- **Mức *ai đang trực trạm nào* nay có luật, nhưng chỉ cho TRẠM QUẦY** — câu `C36` có lời ngày
  2026-09-20 và lời ấy đã về owner cùng ngày (`work/backlog_AD.md` **ADM-21**). Dữ kiện đầy đủ ở
  `master_plan/shop-facts.md` **§8.8**; mục này không nhắc lại nó bằng lời của mình (**F-001**).

**Hệ quả về HÀNH VI của lời `C36` — thứ mục này sở hữu, viết 2026-09-20:**

- **Quyền huỷ đơn và hoàn tiền lần đầu tiên đứng được trên một dữ kiện thật.** §2–§6 và
  `docs/product/1-system-design/architecture.md` §4 chốt quyền gắn **chỗ đứng** chứ không gắn chức
  vụ; tới trước ngày này không có gì ghi ai đang đứng đâu. Luật quyền **không đổi một chữ** — cái
  đổi là nó hết rỗng.
- **Lời chốt này KHÔNG thêm một thao tác nào vào luồng bán hàng của §2–§6.** Ghi mốc đổi người là
  việc của mảng con người; không đơn nào, không phiên bàn nào, không nút nào ở §2–§6 đổi vì nó.
- **Phạm vi là trạm `quay`. Bốn trạm còn lại chưa có lời** ⇒ `U-055`
  ([99-unknowns.md](../../99-unknowns.md)). **Ai khai cái mốc** ⇒ `U-056`. **Hai cửa ghi ngoài
  quầy** — người đi giao và chủ quán đổi giá ⇒ `U-057`. Đọc sự im lặng ấy thành *"chưa quyết"*,
  đừng đọc thành *"không làm"*, và đừng đọc thành *"cả năm trạm"*.

Mảng **tài chính** vẫn chưa có lời chốt mức sâu tương ứng.

**Luật viết cho mọi lần cập nhật admin sau này:** nội dung admin vào **mục riêng có nhãn**, không
chen vào mục của mảng bán hàng — `docs/decisions.md` **ADR-013**.

