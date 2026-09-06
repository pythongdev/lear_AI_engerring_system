# Prompt AD — lane QUẢN TRỊ (admin) · Bánh cuốn Bà Thanh Cao Bằng

Bộ prompt của **mảng admin** — ba nhánh *nguyên liệu · con người · tài chính*, cộng một buổi bán và
một nền dùng chung. Một file một việc, mã việc là **`ADM-XX`**, đúng mã mà `work/backlog_AD.md`
dùng — không đặt mã mới, không đánh số lại (`docs/decisions.md` **ADR-036**).

Viết theo `docs/prompt-guideline.md`. Kiểm kết quả theo `quality/review-gate.md`.

## Ba lane prompt, đừng lẫn

| Lane | Nội dung |
|---|---|
| `prompt/BA/` | pha 0 · BA — hành vi nghiệp vụ của mảng **bán hàng** |
| `prompt/SD/` | pha 1 · System design — *cái gì bảo vệ cái gì*, mười hai bước `P1-XX` |
| **`prompt/AD/`** | **lane admin — mảng quản trị, mã việc `ADM-XX`** |
| `prompt/maintenance/` | sửa chính cái repo này, không thuộc lane nào |

Ranh giới giữa ba sổ task là **LANE**, không phải pha (**ADR-036**), và thư mục này là lane prompt
tương ứng với sổ `work/backlog_AD.md`.

**Gate 1b chấm thư mục này** kể từ 2026-09-04 (T-058, cùng lượt tạo ra nó): mọi đường dẫn viết ở
đây phải mở được — `scripts/check-links.sh`, danh sách *CHẤM FILE NÀO*. Một lane prompt **không**
nằm trong danh sách ấy là một lane pointer không cổng nào đọc, đúng thứ `work/findings.md`
**F-007** dựng gate này để bắt.

⚠️ **Hệ quả khi viết prompt ở đây:** đường dẫn của một file **đầu ra chưa tồn tại** không được viết
đủ cả thư mục lẫn tên file trong một dấu nháy ngược — Gate 1b đỏ ngay khi file prompt được
`git add`. Viết **tên file trần** cạnh thư mục chứa nó, thành hai mẩu. Luật này và vết xe đổ của nó
ở `prompt/SD/README.md`.

## Bốn nguồn input, không phải một

| Nguồn | Cho cái gì | Ai là nhà thật |
|---|---|---|
| `work/backlog_AD.md` | **mô tả dài** của hai mươi chín việc: vì sao có nó, không làm thì mất gì, chạy thế nào, cái gì đang chặn | sổ task lane admin — **không** giữ trạng thái, **không** giữ sự thật |
| `work/backlog.md` | **trạng thái** *Ready* · *In Progress* · *Done* của mọi việc | owner của Tasks (**ADR-002** · **ADR-034**) |
| `work/admin-questions.md` §3 | **câu hỏi cho chủ quán**, và **chỗ chủ quán viết câu trả lời** | file nháp, tự khai là sẽ bị xoá — không sở hữu sự thật nào |
| owner ở `CLAUDE.md` §2 | dữ kiện quán · luật nghiệp vụ · quyết định · invariant | `master_plan/shop-facts.md` §8 · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · `docs/product/1-system-design/architecture.md` §14 · `docs/decisions.md` · `quality/invariants.md` |

Prompt ở đây **trỏ** về bốn nguồn ấy và không chép lại chúng — bản thứ hai của một sự thật luôn
trôi (**F-001**).

## Vì sao thư mục này chỉ có MỘT prompt, và đó không phải nợ

Đo ngày **2026-09-04**: hai mươi chín việc của lane chia làm ba loại (`work/backlog_AD.md`, mục
*Cổng của cả lane* — đếm lại ở đó, đừng tin con số trong câu này, **F-003**).

| Loại | Nghĩa | Có prompt được không |
|---|---|---|
| **1 — thiếu LUẬT** | phải hỏi chủ quán trước | **không.** Viết mười bước cho một việc chưa có luật là tự quyết thay chủ quán — `CLAUDE.md` §3.5, luật **không có mức L0** |
| **2 — luật ĐÃ ĐỦ, thiếu THI CÔNG** | phần nghiệp vụ đã chốt sẵn ở mảng bán hàng; phần còn lại thuộc pha 2–4 hoặc `P1-07` | **không cần.** Prompt của nó là prompt của pha nhận nó, không phải của lane này |
| **3 — việc của chính lane** | nhận được ngay, không chờ ai | **có** — và hôm nay đúng **một** việc: `ADM-53` |

Đây là luật 6 đầu `work/backlog_AD.md`, và nó là bài học **T-051** ngày 2026-09-04 đọc sang lane
này: một mục *Constraints* viết **trước** khi biết đầu ra của tiền đề là một **câu chết**
(`work/findings.md` **F-013** · **F-017**). Ở lane admin còn nặng hơn một bậc — tiền đề đang thiếu
không phải là đầu ra của một bước kỹ thuật, mà là **lời của chủ quán**. Một prompt viết trước lời
ấy không chỉ chết: nó *quyết hộ*, và người đọc nó sau này không phân biệt được đâu là điều chủ quán
nói, đâu là điều prompt đoán.

Nên **điều kiện viết được prompt của một việc ở đây là: mọi câu ở cột *Mở khoá bằng* của nó đã có
lời, và lời ấy đã về owner.** Không phải "đã hỏi" — **đã về owner** (`CLAUDE.md` §7.2).

## Hai mươi chín việc — việc nào có prompt, việc nào mở khoá bằng gì

Đo **2026-09-04**. Cột *Mở khoá bằng* chép mã chặn từ `work/backlog_AD.md`; khi hai bảng khác nhau
thì **`work/backlog_AD.md` đúng** và bảng này là bug phải sửa. Mã `A5`, `B21`, `C36`… là câu hỏi ở
`work/admin-questions.md` §3; `U-XXX` ở `docs/product/99-unknowns.md`; `P1-XX` là bước pha 1 ở
`work/backlog_SD.md`; `Đ-2` · `Đ-4` là hai lời chủ quán chưa về owner.

| Việc | Mức | Loại | Prompt | Mở khoá bằng |
|---|:--:|:--:|---|---|
| **A — một buổi bán** | | | | |
| ADM-01 ca bán | L2 | 1 | chưa viết được | `A2` `A3` `A4` · **P1-03 đi trước** |
| ADM-02 thứ tự bưng | L1 | 1 | chưa viết được | `A5` `A6` · **P1-09 đi trước** |
| ADM-03 sức chứa | L1 | 1 | chưa viết được | `A7` `A8` `A9` |
| ADM-04 tổng quan buổi bán | L1 | 1 | chưa viết được | `A10` · `F52` `F53` · **P1-09 đi trước** |
| **B — nguyên liệu** | | | | |
| ADM-10 danh mục | L1 | 1 | chưa viết được | `B11` `B12` · `U-034` |
| ADM-11 phiếu nhập | L2 | 1 | chưa viết được | `B13` `B14` `B15` `B16` `B17` · `U-034` |
| ADM-12 hao hụt | L2 | 1 | chưa viết được | `B18` (vế còn lại) `B19` `B20` · `U-034` |
| ADM-13 tồn ước tính | L1 | 1 | chưa viết được | `B21` · `U-034` |
| ADM-14 nối nút tạm dừng | L1 | 1 | chưa viết được | `B21` · ADM-13 |
| ADM-15 công nợ nhà cung cấp | L2 | 1 | chưa viết được | `B16` · ADM-11 |
| **C — con người** | | | | |
| ADM-20 hồ sơ | L1 | 1 | chưa viết được | `C23` `C24` `C25` · **Đ-4** |
| ADM-21 ai đang trực trạm | L2 | 1 | chưa viết được | **`C36`** — câu đòn bẩy lớn nhất của cả lane |
| ADM-22 chấm công | L2 | 1 | chưa viết được | `C30` `C31` `C32` · **Đ-4** |
| ADM-23 bảng lương | L3 | 1 | chưa viết được | `C24` `C26` `C27` `C28` `C29` `C33` · ADM-22 · **Đ-4** |
| ADM-24 quyền xem lương | L2 | 1 | chưa viết được | `C34` `C35` `F55` · ADM-23 |
| **D — sản phẩm** | | | | |
| ADM-30 sửa giá thành phần | L2 | 2 | không cần — phần thi công đi theo prompt của pha nhận nó | vế quyền: `D40` |
| ADM-31 bật/tắt món | L1 | 2 | không cần | — |
| ADM-32 thêm món | L2 | 1 | chưa viết được | `D37` `D38` `D42` · một lời **mở lại ranh giới** |
| ADM-33 ảnh và thứ tự | L1 | 1 | chưa viết được | `D43` |
| **E — tài chính** | | | | |
| ADM-40 doanh thu ngày | L2 | 2 | không cần cho phần nghiệp vụ | vế còn lại: `E47` |
| ADM-41 đối soát cuối ngày | L3 | 2 nửa trên | không cần cho phần đã chốt; nửa dưới đi cùng ADM-01 · ADM-44 | `A3` `A4` |
| ADM-42 sổ chi | L2 | 1 | chưa viết được | `E44` `E45` `E46` · ADM-11 |
| ADM-43 lãi/lỗ | L2 | 1 | chưa viết được | `E47` · ADM-42 · ADM-23 · ADM-11 |
| ADM-44 quỹ và két | L3 | 1 | chưa viết được | `A3` `A4` `E49` · ADM-01 |
| ADM-45 bán chạy | L1 | 1 | chưa viết được | `E48` |
| **F — nền dùng chung** | | | | |
| ADM-50 vết thao tác | L3 | 2 | không cần cho phần nghiệp vụ; hình dạng dữ liệu do **P1-07** viết | vế *ai*: `C36` |
| ADM-51 phân quyền | L2 | 1 | chưa viết được | `C34` `C35` `F52` `F53` `F55` |
| ADM-52 nhập bù | L2 | 2 nửa trên | chưa viết được cho nửa dưới | `F54` (`U-032` đã đóng 2026-09-04 — đọc lại ở owner) |
| **ADM-53 đưa Đ-2 và Đ-4 về owner** | **L1** | **3** | ✅ [`ADM-53-hai-loi-ve-owner-L1.md`](ADM-53-hai-loi-ve-owner-L1.md) | — nhận được ngay |

⚠️ **Bảng này là ảnh chụp, không phải owner.** Nhóm A đang được chủ quán trả lời trong ngày
2026-09-04 và các nhánh khác sẽ theo; mỗi lần một nhóm câu có lời, **cột *Prompt* của những việc nó
mở khoá phải được sửa trong cùng lượt** đưa lời ấy về owner (`CLAUDE.md` §7.2 — pointer trỏ vào một
sự thật đã dịch chuyển là bug của lượt đó, không phải task sau). Trước khi tin một hàng ở đây, mở
`work/backlog_AD.md` và `work/admin-questions.md` §3.

## `ADM-53` mở khoá nhiều nhất, nên nó là việc đầu tiên

Nó không chỉ đưa hai lời về owner. Nó là chỗ **hỏi được `C36`** — câu quyết định ADM-21 và vế *ai*
của ADM-50 — và là chỗ trả lời câu chưa ai trả lời: **lane admin chạy song song pha 1, hay chờ pha
1 xong**. Chừng nào câu ấy chưa có lời, mỗi phiên sau tự đoán một câu.

## Cách dùng một prompt ở đây

1. **Gate 0** — mở prompt, đọc mục *Scope*, **thêm** khối scope của mình vào `work/scope.txt`.
   Có phiên khác đang chạy thì **thêm**, đừng ghi đè (**F-010** · **F-014**).
2. Chuyển dòng việc ở `work/backlog.md` xuống *In Progress*. Việc nào chưa có dòng *Ready* thì
   **không** tự tạo — chưa có dòng nghĩa là nó chưa nhận được (luật 1 của `work/backlog_AD.md`).
3. Dán toàn bộ nội dung prompt vào session mới (context sạch).
4. Mục *Unknowns* không rỗng ⇒ **dừng và hỏi**. Ở lane này *Unknowns* hầu hết là câu của **chủ
   quán**, không phải câu kỹ thuật: không có lời thì không có phương án hẹp nào để chọn, chỉ có
   đoán (`CLAUDE.md` §3.5).
5. **Gate 1 + 1b + 1c + 3** — `./scripts/gate.sh` (chạy tự động qua Stop hook).
6. **Gate 2** — soi từng dòng *Acceptance*, chỉ ra bằng chứng.
7. Xong ⇒ tick *Done* ở `work/backlog.md`, thêm dòng *Xong ngày…* vào entry ở `work/backlog_AD.md`,
   dọn khối scope của mình, và giao khối `git commit` dán được (`CLAUDE.md` §6.1).

## Khi bạn viết prompt cho một việc vừa mở khoá

Sáu khối của `docs/prompt-guideline.md`, cộng *Unknowns* và *Report*. Bốn thứ đã tốn tiền để học,
chép từ `prompt/SD/README.md` vì chúng không đổi theo lane:

- **Context dẫn bằng dòng thật**, có số mục, ở owner — không kể lại nội dung của nó (**F-001**).
- **Scope có phần *Không được sửa* dài hơn phần *Được sửa*.**
- **Verify in cả lệnh chưa lọc cạnh lệnh đã lọc** — một bộ lọc rỗng vì viết sai trông y hệt một bộ
  lọc rỗng vì không có lỗi (**F-017**).
- **Không dùng một con số đếm động làm điều kiện nghiệm thu** (**F-018**), và lọc theo **khối** chứ
  không theo **dòng** khi câu cần lọc có thể gói dòng (**F-015**).

Và ba thứ riêng của lane này:

- **Ranh giới pha vẫn áp dụng nguyên vẹn** (**ADR-035**): không tên bảng · tên cột · endpoint ·
  route · component trong bất kỳ đầu ra nào của lane này. Chữ *"màn"* trong tên vài việc — *màn
  tổng quan buổi bán*, *màn đối soát* — là tên gọi tắt của một **năng lực**, không phải một route,
  và không ai được đọc nó thành một route (luật 5 của `work/backlog_AD.md`).
- **Sáu chỗ lane này chạm pha 1, và ở cả sáu chỗ pha 1 đi trước** — bảng đầy đủ ở
  `work/backlog_AD.md`, mục *Sáu chỗ lane này CHẠM pha 1*. Không cổng nào của repo đọc được bảng
  ấy; cái chấm là mắt người.
- **Lời chủ quán về owner TRƯỚC, prompt viết SAU.** Thứ tự ngược lại đẻ ra một prompt mang lời chốt
  trong thân nó — bản thứ hai của một sự thật, và là bản mà người đọc tin vì nó nằm ngay trước mắt
  (**F-001**).
