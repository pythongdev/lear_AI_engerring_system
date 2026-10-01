<a id="top"></a>
# Backlog — lược đồ dữ liệu của mảng QUẢN TRỊ (admin)

Mô tả dài của chín bước `P2A-01`…`P2A-09`. Dựng 2026-09-30 (T-122) theo lời chủ repo ngày
2026-09-29: *"tôi muốn làm luôn db cho phần admin"*. Vì sao nó là một sổ riêng và mang mã riêng:
`docs/decisions.md` **ADR-068**. Hình dạng chép của `work/backlog_DB.md` (**ADR-049** · **ADR-051**).

> **File này giữ MÔ TẢ, không giữ TRẠNG THÁI.** Bước nào *Ready*, *In Progress* hay *Done* đọc ở
> `work/backlog.md` (`docs/decisions.md` **ADR-002**).
>
> **Nó không giữ thứ tự, mức, hay đầu ra kiểm chứng được** — ba thứ đó ở
> [`master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md`](../master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md)
> §5. Chép về đây là tạo bản thứ hai (`work/findings.md` **F-001**).
>
> **Nó không giữ một dòng lược đồ nào, và không giữ lời chủ quán.** Không tên bảng, không tên
> cột. Lời chủ quán ở `master_plan/shop-facts.md` §8; câu còn mở ở `work/admin-questions.md` §3 và
> `docs/product/99-unknowns.md`; việc ở tầng nghiệp vụ (`ADM-XX`) ở `work/backlog_AD.md`.

## Luật của file này — bốn câu

1. **Chỉ bước nhận được ngay mới có dòng ở `work/backlog.md` → *Ready*** (`work/findings.md`
   **F-012**). Hôm dựng sổ: đúng một bước, `P2A-01`.
2. **Entry là hồ sơ thực thi duy nhất của bước** (**ADR-051**). Khối **Nhận việc** (Nghiệm thu ·
   Kiểm chứng) chỉ điền khi mọi thứ ở *Cần xong trước* đã `Done` hoặc đã có lời — sớm hơn là câu
   đoán (**F-013** · **F-017**). Vì vậy hôm dựng sổ **không entry nào có khối ấy**, kể cả `P2A-01`:
   nó điền lúc một phiên nhận việc.
3. **Bước xong thì entry ở lại đây** và nhận khối **Bàn giao**.
4. **Phần còn bị chặn không có entry.** Danh sách của chúng ở kế hoạch §6. Câu chặn có lời ⇒ thêm
   bước mới **nối tiếp** dãy mã, cả ở kế hoạch §5 lẫn ở đây, trong cùng thay đổi.

## Mục lục

| Bước | Entry |
|---|---|
| P2A-01 | [Yêu cầu dữ liệu và invariant của phần admin đã đủ luật](#p2a-01) |
| P2A-02 | [Lát sổ nguyên liệu](#p2a-02) |
| P2A-03 | [Lát chấm công](#p2a-03) |
| P2A-04 | [Lát khoản của người — tạm ứng, thưởng](#p2a-04) |
| P2A-05 | [Lát khoản chi](#p2a-05) |
| P2A-06 | [Dữ liệu mồi admin](#p2a-06) |
| P2A-07 | [Phép đối chiếu của admin vào bộ đối chiếu](#p2a-07) |
| P2A-08 | [Cổng chất lượng — một ngày quản trị](#p2a-08) |
| P2A-09 | [Rà ranh giới pha và pointer](#p2a-09) |

---

<a id="p2a-01"></a>
### P2A-01 — Pha 2 thi hành tầng bảo vệ của pha 1, mà pha 1 chưa viết một dòng nào cho admin

**Phụ thuộc** (kế hoạch §5 thắng khi lệch) · bước 1/9 · **cần xong trước:** không có.

**Goal:**
Xong rồi thì mỗi thứ admin đã đủ luật có một dòng yêu cầu nói *phải ghi lại được gì* và *cái gì
phải không xảy ra được*, và mỗi điều *không xảy ra được* đáng giữ có một mệnh đề có mã, có tầng
giữ, có phép đối chiếu. Bốn lát sau chỉ việc thi hành.

**Nói một câu, việc phải làm là gì:**
Viết dòng `YC` và mệnh đề `I-0xx` mới cho đúng các vế ở cột giữa bảng §2 của kế hoạch. **Không**
phải làm: không viết cho vế nào ở cột phải hay ở §6; không một tên bảng.

**Vì sao có task này:**
`docs/product/1-system-design/04-yeu-cau-du-lieu.md` và `quality/invariants.md` được viết cho mảng
bán hàng. Lược đồ bán hàng dựng được vì mỗi ràng buộc trỏ về một mệnh đề; lược đồ admin hôm nay
không có gì để trỏ về.

**Không làm thì mất gì:**
- Mỗi lát tự nghĩ ra cái nó bảo vệ ⇒ bốn lát, bốn cách hiểu chữ *sổ ghi tay điện tử*.
- Cổng `P2A-08` không có dòng `YC` nào để chấm ngược.
- Một ràng buộc dựng mà không có mệnh đề đứng sau là một luật nghiệp vụ không ai nói.

**Cách hoàn thành — đủ mười bước.**

1. Đọc `master_plan/shop-facts.md` §8.4 · §8.7 · §8.8 · §8.10; kế hoạch §2 và §6; ADR-050;
   `docs/product/1-system-design/03-bao-ve-invariant.md` để lấy khuôn tầng và phép đối chiếu;
   `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6.
2. **Đo lại bảng §2 của kế hoạch** ở owner: vế nào đã đổi từ 2026-09-30 thì sửa bảng ấy trước.
3. Khai `work/scope/P2A-01.txt`; chuyển bước sang *In Progress*; điền khối **Nhận việc**.
4. Với mỗi vế đủ luật: kiểm hành vi nghiệp vụ đã có ở `01-ranh-gioi.md` §1.6 chưa; chưa thì thêm
   vào **mục riêng có nhãn của admin** (ADR-013), trỏ về `shop-facts.md`, không chép lời.
5. Viết dòng `YC` mới, nối số sau dòng cuối đang có, mỗi dòng hai câu và một cột nguồn.
6. Với mỗi câu *không xảy ra được*: quyết nó có thành mệnh đề `I-0xx` không. Có ⇒ viết vào
   `quality/invariants.md`, rồi tầng giữ và phép đối chiếu vào `03-bao-ve-invariant.md`.
7. Vế nào viết tới nửa chừng thì thiếu lời ⇒ **dừng vế ấy**, ghi `U-XXX`, để trống.
8. `grep -rn` các con trỏ: `work/backlog_AD.md` và kế hoạch có chỗ nào nói *"chưa có yêu cầu"* thì
   sửa cùng lượt. `./scripts/gate.sh`.
9. Tick *Done*; điền **Bàn giao**; đưa `P2A-02` và `P2A-04` lên *Ready* (hai lát không có câu chặn).
10. Khối commit, liệt kê từng file.

**Bẫy hay sửa nhầm nhất:**
- **Đừng viết yêu cầu cho thứ chủ quán nói là thực tế của quán chứ không phải việc của máy.** Ví
  dụ `B20`: §8.4 ghi rõ lời ấy chưa thành yêu cầu có hay không có chức năng ghi.
- **Đừng biến *"máy không làm"* thành im lặng.** Bảng *máy KHÔNG làm* của §8.4 là nguồn của các
  câu *không xảy ra được* — không ngưỡng, không tự trừ theo suất bán.
- **Đừng đánh số `YC` hay `I` từ trí nhớ.** Đọc mã cuối ở owner trong chính lượt ấy.
- **Bước này sửa owner mà theo `CLAUDE.md` §7.4 chỉ Claude được sửa** (`quality/invariants.md`).

**Nhận việc** — điền 2026-09-30 (Claude Code), không có bước nào phải xong trước; mức **L2** (kế hoạch §5).
Chủ repo yêu cầu *Codex hoàn thành, Claude kiểm tra*; chia vai theo `CLAUDE.md` §7.4: **Claude** viết
mệnh đề, câu hỏi mở, hành vi nghiệp vụ, quyết định thiết kế; **Codex** thi công hai file pha 1 theo
phiếu giao việc, trong worktree riêng; Claude duyệt diff thật và chạy lại gate.
- *Phạm vi:* `work/scope/P2A-01.txt` — ba owner của pha 1 và của invariant, `01-ranh-gioi.md`,
  `99-unknowns.md`, `decisions.md`, `00-index.md`, kế hoạch lược đồ admin, entry này, dòng trạng thái,
  `work/findings.md`. Worktree của Codex chỉ mở hai file `03-bao-ve-invariant.md` ·
  `04-yeu-cau-du-lieu.md`.
- *Nghiệm thu:*
  1. **Bảng §2 của kế hoạch được đo lại ở owner** trước khi viết; vế nào đổi thì sửa bảng trước.
  2. **Mỗi vế ở cột giữa §2 có đúng một dòng `YC`** hai câu (*Ghi được* · *Không xảy ra được*), nối số
     sau dòng cuối đang có; vế đã có dòng từ trước thì trỏ, không viết dòng thứ hai.
  3. **Mỗi dòng `YC` mới trỏ về một mục `shop-facts.md` đã có lời**; không dòng nào chỉ dựa trên một
     câu còn mở.
  4. **Mỗi câu *không xảy ra được* đáng giữ là một vế của một mệnh đề `I-0xx` mới** có *Invariant* ·
     *Why* · *Verification*; chỗ suy ra ghi là suy ra.
  5. **Mỗi vế của mỗi mệnh đề mới có một tầng, và một tập đối chiếu hoặc một câu nói thẳng vì sao
     chưa có tập** (`03-bao-ve-invariant.md` §0 luật 5).
  6. **Hành vi nghiệp vụ tương ứng có ở `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6**, trong mục
     riêng có nhãn, trỏ về `shop-facts.md`, không chép lời.
  7. **Không tên bảng, tên cột, endpoint, route** trong phần thêm mới; không dòng nào viết cho một vế
     ở cột phải §2 hay ở §6.
  8. Vế thiếu lời ⇒ dừng vế ấy, có mã `U-XXX`, để trống.
- *Kiểm chứng:* lệnh đếm và bảng đối chiếu dán ở *Bàn giao*; `./scripts/gate.sh` xanh ở worktree của
  Codex **và** chạy lại ở clone chính. Test hồi quy cho mệnh đề mới **chưa viết được** ở bước này —
  chưa có lược đồ nào để chạy; mục *Verification* của từng mệnh đề là kịch bản mà lát `P2A-02`…`P2A-05`
  phải chạy thật.

**Bàn giao** — 2026-09-30 · thực hiện: **Codex** (hai file pha 1, theo phiếu) và **Claude Code** (mệnh đề,
câu hỏi mở, hành vi, ADR, finding) · duyệt: **Claude Code** · nhánh `chatgpt_involve`, trên `008524a` ·
chưa commit.

*Kết quả.* Tám dòng yêu cầu `YC-26`…`YC-33` ở
[`04-yeu-cau-du-lieu.md`](../docs/product/1-system-design/04-yeu-cau-du-lieu.md) §9; năm mệnh đề
`I-025`…`I-029` ở `quality/invariants.md`; tầng và phép đối chiếu của chúng ở
[`03-bao-ve-invariant.md`](../docs/product/1-system-design/03-bao-ve-invariant.md) §5; hành vi ở
`docs/product/0-ba/admin/01-ranh-gioi.md` §1.6; hình dạng ở `docs/decisions.md` **ADR-069** (chủ repo
đồng ý 2026-09-30). Hai câu
mới cho chủ quán — **U-067** (tiền tạm ứng, thưởng lấy từ đâu) và **U-068** (nghĩa của *thời gian
nhập*) — không chặn chỗ cất nào. Một finding mở: **F-052**.

*Codex làm gì, Claude duyệt ra sao.* Codex chạy trong worktree riêng, scope đúng hai file pha 1, và
trả về đúng hai file ấy. Claude đọc diff thật, chạy lại gate trong worktree (xanh, Gate 1d soát 2
file), rồi đưa về clone chính bằng `git apply`. Báo cáo của Codex nêu năm chỗ thiết kế trong phiếu
không khớp nguồn; Claude nhận bốn và tự sửa vì lỗi nằm ở thiết kế, không ở thi công: (1) `I-027` viết
rộng hơn lời — cấm cả ngưỡng phút đi muộn và kéo ngày nghỉ vào — nay thu về đúng *chấm muộn không
sinh khoản trừ*, kéo theo `YC-30`, hàng `I-027` và khối chấm công của `01-ranh-gioi.md`; (2) tập đối
chiếu của `I-025` không bắt được một thao tác bán hàng *sinh* con số mới đủ dấu — nay nói thẳng là
chưa có tập; (3) hàng `I-028` thiếu vế *người nhận thuộc tập người của quán* và ca thiếu số tiền; (4)
`I-029` tự mâu thuẫn giữa *danh sách không có loại tiền hàng* và *máy không ngăn được người thêm
loại* — nay ghi là chỗ người giữ. Chỗ thứ năm (hai mốc của `YC-28` chưa chắc biểu đạt *giờ* hàng về)
giữ nguyên thiết kế, thêm một câu ở §9.1 và đã có **U-068**.

*Nghiệm thu → bằng chứng* (đo 2026-09-30 ở clone chính, sau khi sửa):

| Nghiệm thu | Bằng chứng |
|---|---|
| 1. đo lại bảng §2 | `git log -1 --format=%ad --date=short -- master_plan/shop-facts.md work/admin-questions.md` ⇒ `2026-09-28`, trước ngày viết kế hoạch ⇒ không vế nào đổi cột. Một vế thêm vào cột phải: nguồn tiền tạm ứng, thưởng (**U-067**) |
| 2. một vế một dòng `YC` | chín vế ở cột giữa: tám dòng mới, vế *trực quầy theo thời điểm* trỏ `YC-04` · `YC-15`. `grep -Ec` hàng `YC-26…33` ⇒ **8**; nhãn *Ghi được* ⇒ **8**; nhãn *Không xảy ra được* ⇒ **8** |
| 3. trỏ về lời đã chốt | `YC-26`…`YC-29` → `shop-facts.md` §8.4 (dòng 1500) · `YC-30` → `C31` · `C32` (1824 · 1825) · `YC-31` → `C29` (1822) · `YC-32` → `C28` (1821) · `YC-33` → `E44` · `E45` (1935 · 1936). Câu còn mở chỉ đứng ở §9.1, không là nguồn của dòng nào |
| 4. mệnh đề có đủ ba mục | năm tiêu đề `### I-025`…`### I-029`, mỗi cái có *Invariant* · *Why* · *Verification*; năm chỗ suy ra ghi ở mục *Why* và ở **ADR-069** điểm 6 |
| 5. mỗi vế một tầng, một tập | `grep -Ec` hàng `I-025…029` ở file tầng ⇒ **5**; `comm -3` giữa mã `### I-0xx` của `quality/invariants.md` và mã hàng của file tầng ⇒ **rỗng** (29 mã hai bên). Sáu vế *chưa có tập* đều nói lý do tại chỗ |
| 6. hành vi ở `01-ranh-gioi.md` | bốn khối có nhãn dưới câu *Hành vi của phần admin đã đủ luật…*, mỗi khối trỏ mục `shop-facts.md`, không chép lời |
| 7. không tên bảng · cột · endpoint | `git diff -U0` phần thêm mới, lọc tên `snake_case` trong backtick ⇒ **rỗng**; Gate 1d: *2 file .md đã soát, không câu nào đặt tên thứ pha sau sở hữu* |
| 8. vế thiếu lời ⇒ dừng, có mã | `U-065` · `U-066` (đã có) · `U-067` · `U-068` (mở ở lượt này) · câu `B12` · `C30` · `C32` — bảng §9.1 của file yêu cầu và §5.2 của file tầng |

*Chưa làm được, và vì sao.* **Test hồi quy cho năm mệnh đề chưa tồn tại** — chưa có lược đồ admin để
chạy; mục *Verification* là kịch bản các lát phải chạy thật. `./scripts/reconcile.sh --codes` **đỏ**
cho năm mã mới (**F-052**); gate của lượt này không gọi nó vì không đổi gì dưới `db/`.

*Việc kế tiếp.* `P2A-02` và `P2A-04` lên *Ready*. **Trước khi nhận một trong hai, chủ repo chọn đường
ra của F-052** — không thì `db-check` của lát đỏ vì lý do không thuộc về lát. `P2A-03` chờ **U-065**,
`P2A-05` chờ **U-066**.

[↑ đầu file](#top)

---

<a id="p2a-02"></a>
### P2A-02 — Chủ quán sẽ gõ hai con số mỗi ngày cho mỗi thứ, và chưa có chỗ nào nhận chúng

**Phụ thuộc** · bước 2/9 · **cần xong trước:** `P2A-01`.

**Goal:**
Xong rồi thì danh mục hàng mua vào, và hai con số *mua vào* · *đã dùng* của từng thứ từng ngày, có
chỗ cất; tổng đã nhập, tổng đã dùng và hiệu số của một thứ đọc ra được bằng một phép cộng.

**Nói một câu, việc phải làm là gì:**
Dựng lát lược đồ sổ nguyên liệu: một migration có bước lùi, một file lát trong
`docs/product/2-db/`, test cho từng ràng buộc. **Không** phải làm: nợ nhà cung cấp, lượng kiểm đếm
cuối buổi, quy đổi đơn vị, ngưỡng, giá vốn — kế hoạch §6.

**Vì sao có task này:**
Mức *sổ ghi tay điện tử* đã chốt từ 2026-09-01 và chủ quán đã nói rõ ghi gì, ai nhập, nhịp nào,
cộng dồn từ đâu (`shop-facts.md` §8.4). Mục tổng quan của chủ quán (§8.6) đọc thẳng từ sổ này.

**Không làm thì mất gì:**
- Hàng *còn thiếu gì* của mục tổng quan không có nguồn.
- Con số vẫn nằm ở sổ giấy, và mỗi tháng chủ quán cộng tay.

**Cách hoàn thành — đủ mười bước.**

1. Đọc `shop-facts.md` §8.4 trọn mục; các dòng `YC` và mệnh đề của `P2A-01` cho nguyên liệu;
   `docs/product/2-db/01-quy-uoc-du-lieu.md` · `10-quy-uoc-code.md` · `07-thu-tu-migration.md` ·
   `06-luoc-do-nguoi-va-vet.md` (người nhập và vết dùng lại ở đây).
2. Khai scope; *In Progress*; điền **Nhận việc**.
3. Thiết kế trên giấy trước: mỗi mệnh đề tầng 1 thành ràng buộc nào; con số nào **cất**, con số
   nào **đọc ra** (tổng và hiệu số là đọc ra).
4. Viết migration và bước lùi có khoá chặn (ADR-065).
5. Viết test: mỗi mệnh đề một ca *cố tình dựng sai ⇒ database từ chối*.
6. Viết file lát: ý định, lý do, ánh xạ mệnh đề và `YC`, chỗ cố ý để trống.
7. `./scripts/db-check.sh` rồi `./scripts/gate.sh`; dán output.
8. Sửa hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md`; `grep -rn` con trỏ.
9. Tick *Done*; **Bàn giao**; đưa `P2A-06` lên *Ready*.
10. Khối commit.

**Bẫy hay sửa nhầm nhất:**
- **Đừng cất tổng cộng dồn.** Một con số cất hai nơi là hai con số.
- **Đừng bắt mọi thứ phải có đơn vị.** Một phần danh mục chưa có đơn vị và §8.4 cấm tự gán.
- **Đừng nối sổ này vào dòng đơn bán.** Máy không quy một suất bán ra lượng nguyên liệu.
- **Nhóm số điện, số nước đứng ngoài cặp mua/dùng** (§8.4) — không nhét vào danh mục.
- **Danh mục thêm dần, không xoá cứng** — quy ước dữ liệu đã có luật, dùng lại.

**Nhận việc** — điền 2026-09-30 (Claude Code); `P2A-01` đã `Done` và đã commit (`45432a3`); mức **L2**
(kế hoạch §5). Chủ repo yêu cầu *"yêu cầu codex làm bạn kiểm tra"*; chia vai theo `CLAUDE.md` §7.4 và
`docs/prompt-guideline.md` §6.1 mức L2: **Claude** thiết kế (`docs/decisions.md` **ADR-071**), viết hai
file test hồi quy **trước** và hai dòng quy ước mới; **Codex** viết migration, file lát và sửa bước 5
của bộ kiểm cho test xanh, trong worktree riêng; Claude duyệt diff thật và tự chạy lại test.
- *Phạm vi:* `work/scope/P2A-02.txt` — `db/migrations/`, hai file test, file lát mới, bốn file đã có
  của `docs/product/2-db/` (quy ước dữ liệu · quy ước code · thứ tự migration · bộ đối chiếu),
  `docs/product/00-index.md`, `scripts/db-check.sh`, `CLAUDE.md` (hàng *Schema*), `docs/decisions.md`,
  entry này, dòng trạng thái, `work/findings.md`.
- *Nghiệm thu:*
  1. **Mỗi vế tầng 1 của `I-025` · `I-026` có ràng buộc thật**: cố tình dựng trạng thái sai ⇒ database
     từ chối, lời từ chối in nguyên văn — con số thiếu người nhập · thiếu ngày · thiếu giá trị; người
     nhập không phải người của quán; thứ không có trong danh mục; con số thứ hai cùng thứ, cùng ngày,
     cùng loại; tên trùng trong danh mục.
  2. **Kịch bản dương và kịch bản sửa của `I-025` chạy thật**: hai con số đọc lại được kèm người
     nhập, ngày và lúc gõ; sửa 7 → 8 có khai lý do ⇒ đọc ra cả 7 lẫn 8, lý do, người sửa.
  3. **Kịch bản của `I-026` chạy thật, đúng con số của mệnh đề**: 15 · 13 · 2; sau khi sửa 15 · 15 · 0;
     ngày thứ ba mua thêm mà tổng không đặt lại; hiệu số âm **được nhận**.
  4. **Tổng và hiệu số đọc ra bằng một phép cộng** trên các con số ngày; **không chỗ nào cất** tổng,
     ngưỡng, định lượng một suất hay kết luận thiếu — test so danh sách cột của hai bảng từng chữ.
  5. **Không gì nối sổ với bán hàng**: không khoá ngoại, không hàm, không trigger ngoài trigger vết;
     một đơn được tạo, thu tiền, hoàn thành ⇒ sổ không đổi.
  6. **`YC-26`**: một thứ chưa có đơn vị mua vẫn tồn tại được; đơn vị chỉ có khoảng trắng bị từ chối.
  7. **Không xoá cứng**: vai ghi của hệ thống không xoá được con số hay một thứ trong danh mục.
  8. **Có bước lùi có khoá chặn**; vòng xuôi · lùi · xuôi lại của bộ kiểm giống hệt cho cả chín bước;
     mọi khối `QC-XX` và nhóm `QD-XX` xanh trên hai bảng mới.
  9. **Tên bảng ở file lát và ở migration khớp** (Gate 1e); file lát không nhắc thứ pha sau sở hữu
     (Gate 1d); hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát mới.
  10. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh ở clone chính.
- *Kiểm chứng:* `db/tests/i025_supply_numbers_entered_by_a_person.sql` ·
  `db/tests/i026_supply_totals_from_day_entries.sql` trong `./scripts/db-check.sh`; Claude tự chạy lại
  ở worktree của Codex **và** ở clone chính, dán output ở *Bàn giao*.
- *Ngoài phạm vi, có tên:* buổi bán **đủ năm kênh** của mục *Verification* `I-025` — cổng `P2A-08`;
  câu đối chiếu của hai mệnh đề — `P2A-07`; dữ liệu mồi danh mục — `P2A-06`.

**Bàn giao** — 2026-09-30 · thực hiện: **Codex** (migration và bước lùi, file lát, bước 5 của bộ kiểm,
ba file tài liệu đã có — theo phiếu) và **Claude Code** (thiết kế **ADR-071**, hai file test viết
trước, hai dòng quy ước `QD-03` · `QC-04`, **F-053**) · duyệt: **Claude Code** · nhánh
`chatgpt_involve`, trên `fb3fff3` · chưa commit.

*Kết quả.* Hai bảng `supply_item` · `supply_day_entry` ở
`db/migrations/20260930100000_so_nguyen_lieu.up.sql` (bước thứ chín, có bước lùi có khoá chặn); ý
định và ánh xạ ở [`12-luoc-do-nguyen-lieu.md`](../docs/product/2-db/12-luoc-do-nguyen-lieu.md). Một
con số người gõ là một dòng mang người nhập, ngày và lúc gõ của riêng nó; tổng và hiệu số không có
chỗ cất. Con số là `numeric` đúng như gõ — vai trò cột mới `_measure`.

*Codex làm gì, Claude duyệt ra sao.* Codex chạy trong worktree riêng, không sửa hai file test, trả
về đúng các file trong scope, và **nói thẳng** sandbox của nó không gọi được Docker nên chưa kiểm
chứng gì trên database. Claude đọc diff thật, tự chạy `./scripts/db-check.sh` trong worktree (xanh
ngay lần đầu, không vòng sửa nào), đưa về clone chính bằng `git apply`, rồi chạy lại cả
`./scripts/gate.sh` và `./scripts/db-check.sh` ở đó.

*Nghiệm thu → bằng chứng* (đo 2026-09-30 ở clone chính; mỗi trích dẫn là dòng `NOTICE` hay dòng cổng
in nguyên văn):

| Nghiệm thu | Bằng chứng |
|---|---|
| 1. vế tầng 1 bị từ chối | test `i025_…`: *không có người nhập* ⇒ `null value in column "person_id"` · *không có ngày* ⇒ `"entry_date"` · *không có con số* ⇒ `"entered_measure"` · người lạ ⇒ `supply_day_entry_person_fkey` · thứ lạ ⇒ `supply_day_entry_supply_item_fkey`; test `i026_…`: con số thứ hai ⇒ `supply_day_entry_one_kind_per_item_day_key` (cả *mua vào* lẫn *đã dùng*) · trùng tên ⇒ `supply_item_name_key` |
| 2. kịch bản dương và sửa của `I-025` | `YC-28 con số — test-gạo · purchased · 10: test-chủ quán nhập, ngày của con số 2026-09-21, có lúc gõ: t` (ba dòng, hai người nhập) · `I-025 sửa con số — trước 7, sau 8, lý do "test-cân lại cuối buổi", test-chủ quán sửa` |
| 3. kịch bản của `I-026` | `tổng đã nhập 15, tổng đã dùng 13, hiệu số 2 (ngày thứ ba mua thêm, tổng không đặt lại)` · `tổng đã nhập 15, tổng đã dùng 15, hiệu số 0` · `đã dùng vượt tổng đã nhập — nhận, hiệu số -4` |
| 4. không chỗ cất tổng, ngưỡng, định lượng | `I-025 đọc lược đồ — supply_item: created_at,id,name,purchase_unit` · `supply_day_entry: created_at,entered_measure,entry_date,id,kind_code,person_id,supply_item_id` — test so từng chữ, lệch là đỏ |
| 5. không gì nối sổ với bán hàng | `0 khoá ngoại sang đơn · phiên · mẻ · tiền, 0 hàm nhắc tới sổ, 0 trigger ngoài trigger vết` · `sau một đơn tạo · thu tiền · hoàn thành — sổ nguyên liệu không đổi (3 con số)` |
| 6. `YC-26` | `"test-hành tây", đơn vị mua: (trống)` · đơn vị trắng ⇒ `supply_item_purchase_unit_not_blank_check` · tên trắng ⇒ `supply_item_name_not_blank_check` |
| 7. không xoá cứng | `permission denied for table supply_day_entry` · `permission denied for table supply_item` (vai `shop_app`) |
| 8. bước lùi, vòng xuôi · lùi · xuôi lại, quy ước | `PASS lùi 20260930100000_so_nguyen_lieu — lược đồ giống hệt lúc trước bước ấy (1134 dòng)` · `PASS xuôi lại — 9 bước từ số không … (1189 dòng)` · `PASS QC-04 (sql) — 0 dòng` · nhóm `QD-XX` 19 mã, không `FAIL` nào |
| 9. tên bảng, ranh giới pha, con trỏ | Gate 1e: *33 bảng ở migration, 33 bảng tài liệu nhắc, comm -3 rỗng* · Gate 1d: *5 file .md đã soát, không câu nào đặt tên thứ pha sau sở hữu* · hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát |
| 10. cổng xanh ở clone chính | `db-check: PASS — 9 bước xuôi · lùi · xuôi lại, 10 khối kiểm QC, 28 file test, dữ liệu mồi + §4.8, khoá chặn, đối chiếu: 85 câu trên dữ liệu mồi và ngày mẫu, 85 lỗi cài, ba scenario + đối chiếu trên ngày diễn, 24 mã YC` · `PASS gate không cổng nào đỏ` |

*Tìm ra trong lượt này.* Bước khoá chặn của bộ kiểm sẽ đỏ oan ở mọi lát admin — `work/findings.md`
**F-053**, đã sửa cùng lượt (ADR-071 điểm 6).

*Chưa làm được, và vì sao.* (1) **Buổi bán đủ năm kênh** của mục *Verification* `I-025` chưa diễn:
test chỉ chạy một đơn tới lấy và phần đọc lược đồ — việc của cổng `P2A-08`. (2) **Câu đối chiếu**
của `I-025` · `I-026` chưa viết; hai dòng ở `09-doi-chieu-bat-bien.md` §2.1 còn đó, người nợ `P2A-07`.
(3) **Sửa một con số không khai lý do vẫn đi qua mà không có vết** — test in thẳng *"0 vết mới
(F-046)"*; vế *không có đường sửa đè* của `I-025` hôm nay thấp hơn tầng pha 1 đã chốt, cùng nợ với
**F-046**. (4) Ba chỗ **suy ra** của ADR-071 (con số không âm, hai mã máy đọc, tên so đúng từng chữ)
chưa có lời chủ repo.

*Việc kế tiếp.* `P2A-06` (dữ liệu mồi admin) lên *Ready*. `P2A-04` vẫn *Ready*; nó dùng lại bước 5
mới của bộ kiểm mà không phải sửa gì.

[↑ đầu file](#top)

---

<a id="p2a-03"></a>
### P2A-03 — Chủ quán sẽ tick một ô *có đi làm* cho từng người mỗi ngày, và chưa có chỗ nào nhận ô ấy

*Tên cũ của bước, tới 2026-09-30:* "Nhân viên sẽ tự bấm chấm công, và chưa ai biết một lần bấm ghi lại
mốc gì" — viết theo `C31`; đổi khi `U-069` có lời.

**Phụ thuộc** · bước 3/9 · **cần xong trước:** `P2A-01` · `U-069` — **đã có lời 2026-09-30**
(`docs/product/99-unknowns.md`): *chủ quán tick hết*, *mỗi người mỗi ngày một ô*; lời ấy thay `C31` ở
vế người đánh dấu. Trước đó `U-065` đã đóng bằng lời *"chủ quán tự tick vào ô có đi làm"* (T-124).

**Goal:**
Xong rồi thì đọc ra được *người này, ngày này, có đi làm, ai đã tick*, và người ấy là người của lát
`P2-08`, không phải một danh sách thứ hai.

**Nói một câu, việc phải làm là gì:**
Dựng lát chấm công đúng bằng lời đóng `U-065` · `U-069`. **Không** phải làm: giờ tới, giờ về, ô theo
buổi, ngưỡng đi muộn, khoản trừ, tính công thành tiền — phần lương ở kế hoạch §6. *Đường gỡ một ô
tick nhầm lúc nhận việc còn ngoài phạm vi (`U-070`); chủ quán đóng câu ấy cùng ngày và nó vào phạm vi —
đọc* Bàn giao *, lượt hai.*

**Vì sao có task này:**
Chủ quán chốt cả ba mức của mảng con người (§8.7); mức 2 là chấm công, và mức 3 đứng trên nó.

**Không làm thì mất gì:**
- Khi công thức lương có lời, không có sổ công nào để nhân với đơn giá.
- Nhân viên được xem công của chính mình (`C35`) mà không có công nào để xem.

**Cách hoàn thành.** Mười bước theo khuôn `P2A-02`; bước 0 thêm vào là ghi lời chủ quán cho `U-069`
vào owner và viết lại `I-027` · `YC-30` theo lời ấy **trước** khi dựng.

**Bẫy hay sửa nhầm nhất:**
- **Đừng dùng mốc đổi người ở quầy làm chấm công.** §8.8 nói thẳng hai câu ấy khác nhau.
- **Đừng dựng cột *đi muộn* hay giờ tới.** `C32`: đi muộn không trừ tiền, ngưỡng phút chưa có; lời
  `U-069` là một ô cho cả ngày.
- **Người được chấm và người tick là hai người khác nhau trên cùng một ô** — đừng gộp vào một cột.
- **Gỡ một ô là HUỶ, không phải xoá hay sửa.** Lời đóng `U-070`: nút huỷ, có ghi chú để kiểm lại ⇒ ô
  đã huỷ ở lại. Đừng bắt buộc ghi chú, đừng xét người huỷ — `U-071` còn mở.

**Nhận việc** — điền 2026-09-30 (Claude Code); `P2A-01` đã `Done` và đã commit (`45432a3`); mức **L2**
(kế hoạch §5). Bước này **bị chặn** bởi `U-069` lúc nhận; phiên hỏi chủ repo bằng hai câu có sẵn
phương án, chủ repo chọn *"Chủ quán tick hết"* · *"Một ô cho cả ngày"* và xác nhận đó là **lời chủ
quán**. Chủ repo yêu cầu *"codex làm bạn kiểm tra"*; chia vai theo `CLAUDE.md` §7.4 và
`docs/prompt-guideline.md` §6.1 mức L2: **Claude** ghi lời chủ quán vào owner (đóng `U-069`, mở
`U-070`), viết lại `I-027` · `YC-30` và tầng giữ, thiết kế (`docs/decisions.md` **ADR-072**), viết
file test hồi quy **trước**; **Codex** viết migration, file lát và ba dòng tài liệu đã có, trong
worktree riêng; Claude duyệt diff thật và tự chạy lại test.
- *Phạm vi:* `work/scope/P2A-03.txt` — `db/migrations/`, file test, file lát mới, hai file đã có của
  `docs/product/2-db/` (thứ tự migration · bộ đối chiếu), `docs/product/00-index.md`, các owner nhận
  lời chủ quán (`docs/product/99-unknowns.md` · `master_plan/shop-facts.md` · `quality/invariants.md` ·
  hai file pha 1 · `docs/product/0-ba/admin/01-ranh-gioi.md` · kế hoạch lược đồ admin), `CLAUDE.md`
  (hàng *Schema*), `docs/decisions.md`, entry này, dòng trạng thái, `work/findings.md`.
- *Nghiệm thu:*
  1. **Lời chủ quán nằm ở owner trước khi dựng**: `U-069` ở mục đã có lời giải kèm nguyên văn lời
     chọn; `shop-facts.md` §8.7 có mục bổ sung; `I-027` · `YC-30` · hàng tầng giữ viết lại theo lời ấy;
     không file nào ngoài `work/` còn nhắc `U-069` như một câu đang mở.
  2. **Mỗi vế tầng 1 của `I-027` có ràng buộc thật**: cố tình dựng trạng thái sai ⇒ database từ chối,
     lời từ chối in nguyên văn — ô không gắn người · người không phải người của quán · ô không có
     ngày · ô không có người tick · người tick không phải người của quán · ô thứ hai cùng người cùng ngày.
  3. **Kịch bản dương của `I-027` chạy thật, đúng con số của mệnh đề**: chủ quán tick cho hai người
     ngày 2026-09-21 và một người ngày 2026-09-22 ⇒ đọc lại đúng ai, ngày nào, ai tick, có lúc tick.
  4. **Vế tầng 3 được nói thẳng, không giấu**: test in rằng database **nhận** một ô do người không
     phải chủ quán tick.
  5. **Ô đã tick không có đường đổi hay gỡ**: vai ghi của hệ thống tick được; sửa ngày của một ô và
     xoá một ô đều bị từ chối.
  6. **Không chỗ nào cất giờ tới, buổi, ngưỡng đi muộn hay khoản trừ; không đường nào đi từ một ô tới
     thứ khác** — test so danh sách cột từng chữ; không khoá ngoại ngoài hai khoá về người, không hàm,
     không trigger ngoài trigger vết.
  7. **Có bước lùi có khoá chặn**; vòng xuôi · lùi · xuôi lại của bộ kiểm giống hệt cho cả mười bước;
     mọi khối `QC-XX` và nhóm `QD-XX` xanh trên bảng mới.
  8. **Tên bảng ở file lát và ở migration khớp** (Gate 1e); file lát không nhắc thứ pha sau sở hữu
     (Gate 1d); hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát mới.
  9. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh ở clone chính.
- *Kiểm chứng:* `db/tests/i027_attendance_one_box_per_worker_day.sql` trong `./scripts/db-check.sh`;
  Claude tự chạy lại ở worktree của Codex **và** ở clone chính, dán output ở *Bàn giao*.
- *Ngoài phạm vi, có tên:* câu đối chiếu của `I-027` (ba tập: đủ dấu · một ô · chủ quán tick) —
  `P2A-07`; diễn một ngày quản trị có bước chấm công — cổng `P2A-08`; đường gỡ một ô — chờ `U-070`.

**Bàn giao** — 2026-09-30 · thực hiện: **Codex** (migration và bước lùi, file lát, ba file tài liệu đã
có — theo phiếu) và **Claude Code** (lời chủ quán vào owner, `I-027` · `YC-30` và tầng giữ viết lại,
**ADR-072**, file test viết trước) · duyệt: **Claude Code** · nhánh `chatgpt_involve`, trên `a1aa9ca` ·
chưa commit.

*Kết quả.* Một bảng `attendance_day` ở `db/migrations/20260930110000_cham_cong.up.sql` (bước thứ mười,
có bước lùi có khoá chặn); ý định và ánh xạ ở
[`13-luoc-do-cham-cong.md`](../docs/product/2-db/13-luoc-do-cham-cong.md). Một ô *có đi làm* là một
dòng của một người một ngày, mang người tick và lúc tick; không có dòng là không có ô. Vai ghi của hệ
thống chỉ chèn được: ô đã tick không đổi, không xoá được cho tới khi `U-070` có lời.

*Codex làm gì, Claude duyệt ra sao.* Codex chạy trong worktree riêng có sẵn mười file của Claude, trả
về đúng sáu file trong phiếu, và **nói thẳng** sandbox của nó không gọi được Docker nên chưa kiểm gì
trên database. Claude so từng byte mười file của mình (giữ nguyên, kể cả file test), đọc diff thật,
tự chạy `./scripts/db-check.sh` trong worktree (xanh ngay lần đầu, không vòng sửa nào), đưa sáu file
về clone chính, rồi chạy lại `./scripts/gate.sh` ở đó.

*Nghiệm thu → bằng chứng* (đo 2026-09-30 ở clone chính; mỗi trích dẫn là dòng `NOTICE` hay dòng cổng
in nguyên văn):

| Nghiệm thu | Bằng chứng |
|---|---|
| 1. lời chủ quán ở owner trước khi dựng | `U-069` ở mục đã có lời giải của `docs/product/99-unknowns.md`; mục *Bổ sung 2026-09-30 — U-069* ở `shop-facts.md` §8.7; `grep -rn "U-069" docs master_plan quality` ⇒ không dòng nào gọi nó là câu đang mở; Gate 1c: *3298 khối, 68 mã U-XXX, 21 chuyển tiếp hợp lệ* |
| 2. vế tầng 1 bị từ chối | test `i027_…`: *ô không gắn người nào* ⇒ `null value in column "worker_person_id"` · *người không phải người của quán* ⇒ `attendance_day_worker_person_fkey` · *ô không có ngày* ⇒ `"work_date"` · *ô không có người tick* ⇒ `"person_id"` · *người tick không phải người của quán* ⇒ `attendance_day_person_fkey` · *ô thứ hai cùng người, cùng ngày* ⇒ `attendance_day_one_per_worker_day_key` |
| 3. kịch bản dương của `I-027` | `YC-30 ô có đi làm — test-người tráng bánh, ngày 2026-09-21: test-chủ quán tick, có lúc tick: t` (ba dòng) · `I-027 đọc lại — test-người tráng bánh có đi làm 2 ngày, test-người gấp bánh 1 ngày` |
| 4. vế tầng 3 nói thẳng | `I-027 tầng 3 — ô do người KHÔNG phải chủ quán tick: database nhận (1 ô như thế); cửa ghi và phép đối chiếu giữ vế này` |
| 5. ô đã tick không đổi, không gỡ | `I-027 vai shop_app tick được một ô` · `I-027 ô đã tick không đổi được (shop_app): permission denied for table attendance_day` · `QD-50 ô không xoá được (shop_app): permission denied for table attendance_day` |
| 6. không giờ tới, buổi, ngưỡng, khoản trừ | `I-027 đọc lược đồ — attendance_day: created_at,id,person_id,work_date,worker_person_id` · `0 khoá ngoại ngoài hai khoá về người, 0 hàm nhắc tới ô, 0 trigger ngoài trigger vết` — test so từng chữ, lệch là đỏ |
| 7. bước lùi, vòng xuôi · lùi · xuôi lại, quy ước | `PASS lùi 20260930110000_cham_cong — lược đồ giống hệt lúc trước bước ấy (1189 dòng)` · `PASS xuôi lại — 10 bước từ số không … (1216 dòng)` · mười khối `QC-XX` và nhóm `QD-XX` không `FAIL` nào |
| 8. tên bảng, ranh giới pha, con trỏ | Gate 1e: *34 bảng ở migration, 34 bảng tài liệu nhắc, comm -3 rỗng* · Gate 1d: *5 file .md đã soát, không câu nào đặt tên thứ pha sau sở hữu* · Gate 1b xanh · hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát |
| 9. cổng xanh ở clone chính | `PASS Gate 1 db-check — 10 bước xuôi · lùi · xuôi lại, 10 khối kiểm QC, 29 file test, dữ liệu mồi + §4.8, khoá chặn, đối chiếu: 85 câu trên dữ liệu mồi và ngày mẫu, 85 lỗi cài, ba scenario + đối chiếu trên ngày diễn, 24 mã YC` · `PASS gate không cổng nào đỏ` |

*Chưa làm được, và vì sao.* (1) **Câu đối chiếu** của `I-027` (ba tập: đủ dấu · một ô · chủ quán tick)
chưa viết; dòng ở `09-doi-chieu-bat-bien.md` §2.1 còn đó, người nợ `P2A-07`. Cho tới lúc ấy vế *người
tick là chủ quán* **không có gì giữ**: database nhận, cửa ghi pha 3 chưa có. (2) **Đường gỡ một ô tick
nhầm** không có — chờ `U-070`. (3) **Dòng `YC-30` chưa vào bộ chấm YC** của `db-check` (bộ ấy vẫn in
*24 mã*, tức chưa chấm dòng admin nào) — việc của cổng `P2A-08`. (4) Bốn chỗ **suy ra** của ADR-072
(không dòng là không ô; khoá sửa lẫn xoá; nhận ô cho ngày đã qua; chủ quán cũng được chấm) chưa có lời
chủ repo. (5) Lời chủ quán cho `U-069` được ghi từ việc chủ repo **chọn trong phương án phiên soạn
sẵn**, không phải nguyên văn chủ quán gõ — đã ghi đúng như thế ở owner.

**Bàn giao, lượt hai** — 2026-09-30, cùng phiên, **trước khi commit** · thực hiện và tự kiểm: **Claude
Code** (phần thêm nhỏ, không viết phiếu cho Codex). Sau lượt một, chủ repo chuyển nguyên văn ba lời chủ
quán và chọn **gộp vào cùng commit** của bước này:

- **`U-070` đóng** — *"làm thêm nut huỷ, và có phần note lại để sau đó có thể kiểm"*. Lát đổi theo:
  migration (chưa commit nên sửa tại chỗ) thêm ba dấu huỷ `cancelled_at` · `cancelled_by_person_id` ·
  `cancel_note`; khoá duy nhất thành chỉ mục một phần `attendance_day_one_live_per_worker_day_key` (chỉ
  đếm ô chưa huỷ); vai ghi được cập nhật đúng ba cột ấy. `I-027` thêm vế thứ năm, `YC-30`, hàng tầng
  giữ, `01-ranh-gioi.md`, ADR-072 điểm 4 và file lát viết lại theo. **Các dòng 5 · 6 và tên khoá ở dòng
  2 của bảng lượt một bị thay bởi bảng dưới.**
- **`U-068` đóng** — *"lúc hàng mùa về"* (chuẩn hoá: *mua về*): *thời gian nhập* là lúc hàng mua về.
  Không đổi lược đồ: sổ nguyên liệu đã giữ ngày của con số; ghi ở `shop-facts.md` §8.4, `I-025` (chú
  thích), `04-yeu-cau-du-lieu.md` §9.1, `12-luoc-do-nguyen-lieu.md`.
- **`U-058` vẫn mở** — nhận lại đúng lời cũ lần thứ năm; ba vế còn thiếu chưa có lời.
- **`U-071` mở** — ghi chú huỷ có bắt buộc không, ai được bấm huỷ. Không chặn lát.

| Nghiệm thu (lượt hai) | Bằng chứng — `./scripts/db-check.sh` ở clone chính |
|---|---|
| huỷ rồi đọc lại | `YC-30 ô đã huỷ — test-người gấp bánh, ngày 2026-09-23: test-chủ quán huỷ, có lúc huỷ: t, ghi chú "test-tick nhầm người, hôm ấy nghỉ"; ô vẫn còn để kiểm lại` — cả tick lẫn huỷ chạy dưới vai `shop_app` |
| tick lại sau khi huỷ; vẫn một ô còn hiệu lực | `I-027 tick lại sau khi huỷ — nhận: … có 1 ô còn hiệu lực, 1 ô đã huỷ` · ô thứ hai ⇒ `attendance_day_one_live_per_worker_day_key` |
| lần huỷ sai bị từ chối | không người huỷ ⇒ `attendance_day_cancelled_by_iff_cancelled_check` · người huỷ lạ ⇒ `attendance_day_cancelled_by_person_fkey` · ghi chú trắng, ghi chú trên ô chưa huỷ ⇒ `attendance_day_cancel_note_only_when_cancelled_check` · huỷ trước lúc tick ⇒ `attendance_day_cancelled_after_created_check` |
| chỗ database không giữ, nói thẳng | `I-027 tầng 3 · U-071 — huỷ KHÔNG ghi chú, do người KHÔNG phải chủ quán: database nhận (1 ô như thế)` |
| không đổi, không xoá | `I-027 ô đã tick không đổi được người hay ngày (shop_app): permission denied` · `QD-50 ô không xoá được, kể cả ô đã huỷ (shop_app): permission denied` |
| danh sách cột | `attendance_day: cancel_note,cancelled_at,cancelled_by_person_id,created_at,id,person_id,work_date,worker_person_id` · `0 khoá ngoại ngoài ba khoá về người, 0 hàm nhắc tới ô, 0 trigger ngoài trigger vết` |
| migration và quy ước | `PASS lùi 20260930110000_cham_cong — lược đồ giống hệt lúc trước bước ấy (1189 dòng)` · `PASS xuôi lại — 10 bước từ số không … (1226 dòng)` · mười khối `QC-XX` đều `PASS` |

**Cổng KHÔNG xanh trọn ở lượt hai, và lý do không thuộc bước này.** Trong lúc làm, một phiên khác nhận
`P2A-04` **ngay trong cây làm việc này**: file test `db/tests/i028_…` của nó đã nằm ở clone chính khi
migration của nó còn ở worktree `../lean_wt/P2A-04`, nên `db-check` đỏ ở đúng file ấy; hai bộ kiểm chạy
cùng lúc còn gỡ database của nhau (`work/findings.md` **F-045**), làm phần sau của lần chạy đỏ giả.
Phần của bước này trong cùng lần chạy — mười bước migration, mười khối `QC`, test `i027` — xanh như
bảng trên. Để có một lần chạy trọn không va ai, Claude chép cây làm việc sang thư mục tạm **bỏ file
test `i028`**, đổi tên compose project của bộ kiểm trong bản chép, và chạy `./scripts/db-check.sh` ở đó:
mọi dòng `PASS` — `PASS khoá chặn — … đã lùi qua 2 bước rỗng và xuôi lại`, `reconcile: PASS — 63 câu
I-0xx · 22 câu QD, mọi tập rỗng`, ba scenario, chấm YC — **trừ** `QC-05 (sh): Could not access 'HEAD'`,
vì bản chép không có `.git`; ở clone chính `QC-05` xanh. Một lần chạy `./scripts/gate.sh` xanh trọn ở
clone chính **còn nợ**, chạy được khi phiên `P2A-04` đưa migration của nó về. Worktree của
phiên kia còn mang **bản cũ** của migration chấm công (chưa có ba dấu huỷ): lúc nó đưa về, migration ở
clone chính là bản đúng.

*Chưa làm được, thêm vào danh sách lượt một.* (6) Không có đường *bỏ huỷ* riêng: vai ghi sửa được ba
dấu huỷ, lần sửa ấy chỉ có vết ở chế độ mềm (**F-046**). (7) Lời `U-068` không nói *lúc hàng mua về* là
ngày hay giờ; lược đồ giữ ngày.

*Việc kế tiếp.* `P2A-04` (tạm ứng và thưởng) đang *In Progress* ở phiên khác; `P2A-07` nay có ba lát để
viết câu, và `I-027` có thêm tập *vế huỷ*.

[↑ đầu file](#top)

---

<a id="p2a-04"></a>
### P2A-04 — Tạm ứng và thưởng là tiền thật đã đưa cho người làm, và không dòng nào ghi lại

**Phụ thuộc** · bước 4/9 · **cần xong trước:** `P2A-01`.

**Goal:**
Xong rồi thì mỗi khoản tạm ứng và mỗi khoản thưởng đọc lại được sau nhiều ngày: của ai, bao
nhiêu, lúc nào, ai duyệt.

**Nói một câu, việc phải làm là gì:**
Dựng lát cho hai loại khoản ấy, mỗi khoản là một lần có ngày và có người. **Không** phải làm: cách
khoản ấy trừ vào hay cộng vào lương; thưởng ngày đông khách (`C28` còn mở vế ấy).

**Vì sao có task này:**
`C29`: có tạm ứng, chủ quán duyệt. `C28`: có thưởng lễ Tết. Cả hai là tiền rời tay chủ quán.

**Không làm thì mất gì:**
- Cuối kỳ không ai nhớ đã ứng cho ai bao nhiêu.
- Phần lương sau này không có khoản nào để trừ.

**Cách hoàn thành.** Mười bước theo khuôn `P2A-02`; đọc thêm lát đường tiền
`docs/product/2-db/04-luoc-do-duong-tien.md` để **không** trộn khoản này vào tiền bán hàng.

**Bẫy hay sửa nhầm nhất:**
- **Kế hoạch §8 điểm 3 là chỗ SUY RA:** tạm ứng dựng được trước công thức lương. Lúc nhận việc mà
  thấy lời chủ quán không đủ để biết *một khoản tạm ứng gồm gì* thì dừng và mở `U-XXX`.
- **Tiền tạm ứng lấy từ đâu chưa ai nói.** Không nối khoản này vào két hay đối soát cuối ngày.
- **Đây là tiền ⇒ sửa phải để lại vết**, dùng cơ chế vết của `P2-08`; đọc `work/findings.md`
  **F-046** trước.

**Nhận việc** — điền 2026-09-30 (Claude Code); `P2A-01` đã `Done` và đã commit (`45432a3`); mức **L2**
(kế hoạch §5). Bẫy thứ nhất đã soát lúc nhận: `I-028` · `YC-31` · `YC-32` nói đủ *một khoản gồm gì* —
của ai, bao nhiêu, lúc nào, ai ghi, và ai duyệt với tạm ứng — nên **không** câu `U-XXX` nào phải mở để
dựng. Chủ repo yêu cầu *"yêu cầu để codex làm bạn kiểm tra"*; chia vai theo `CLAUDE.md` §7.4 và
`docs/prompt-guideline.md` §6.1 mức L2: **Claude** thiết kế (`docs/decisions.md` **ADR-073**), viết
file test hồi quy **trước**; **Codex** viết migration và bước lùi, file lát và ba dòng tài liệu đã có,
trong worktree riêng; Claude duyệt diff thật và tự chạy lại test. Lát `P2A-03` lúc ấy **chưa commit**,
nên worktree của Codex được mồi bằng đúng trạng thái cây của clone chính.
- *Phạm vi:* `work/scope/P2A-04.txt` — `db/migrations/`, file test, file lát mới, hai file đã có của
  `docs/product/2-db/` (thứ tự migration · bộ đối chiếu), `docs/product/00-index.md`, `CLAUDE.md`
  (hàng *Schema*), `docs/decisions.md`, entry này, dòng trạng thái, `work/findings.md`.
- *Nghiệm thu:*
  1. **Mỗi vế tầng 1 của `I-028` có ràng buộc thật, ở cả hai loại khoản**: cố tình dựng trạng thái sai
     ⇒ database từ chối, lời từ chối in nguyên văn — khoản không có người nhận · người nhận không phải
     người của quán · không có số tiền · số tiền 0đ · số âm · không có ngày · không có người ghi; và
     riêng tạm ứng: không có người duyệt · người duyệt không phải người của quán.
  2. **Kịch bản dương của `I-028` chạy thật**: chủ quán duyệt tạm ứng cho một người ⇒ đọc lại được
     của ai, bao nhiêu, ngày nào, ai duyệt, ai ghi, có lúc ghi; hai khoản thưởng lễ Tết đọc lại được
     của ai, bao nhiêu, ngày nào, ai ghi.
  3. **Kịch bản sửa của `I-028` chạy thật, bằng vai ghi của hệ thống**: đổi số tiền có khai lý do ⇒
     đọc ra cả số cũ lẫn số mới, lý do, người sửa; đổi ngày và người nhận cũng để lại vết.
  4. **Chế độ mềm được nói thẳng, không giấu**: test in số vết của một lần sửa không khai lý do.
  5. **Vế tầng 3 được nói thẳng**: test in rằng database **nhận** một khoản tạm ứng do người không
     phải chủ quán duyệt.
  6. **Vai ghi chỉ sửa được số tiền · người nhận · ngày**: đổi người duyệt, người ghi hay lúc ghi bị
     từ chối; xoá một khoản bị từ chối.
  7. **Không gì nối một khoản với tiền bán hàng hay két**: test so danh sách cột của hai bảng từng
     chữ; không khoá ngoại ngoài các khoá về người, không hàm, không trigger ngoài trigger vết; sau
     mọi lần ghi và sửa, không bảng nào khác của schema đổi số dòng.
  8. **Không chỗ cất sẵn** cho người duyệt thưởng, loại thưởng hay thưởng ngày đông khách (`YC-32`),
     cho việc trừ vào lương hay trả lại tạm ứng.
  9. **Có bước lùi có khoá chặn**; vòng xuôi · lùi · xuôi lại của bộ kiểm giống hệt cho cả mười một
     bước; mọi khối `QC-XX` và nhóm `QD-XX` xanh trên hai bảng mới.
  10. **Tên bảng ở file lát và ở migration khớp** (Gate 1e); file lát không nhắc thứ pha sau sở hữu
      (Gate 1d); hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát mới.
  11. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh ở clone chính.
- *Kiểm chứng:* `db/tests/i028_advance_and_bonus_name_a_worker.sql` trong `./scripts/db-check.sh`;
  Claude tự chạy lại ở worktree của Codex **và** ở clone chính, dán output ở *Bàn giao*.
- *Ngoài phạm vi, có tên:* câu đối chiếu của `I-028` (năm tập ở `03-bao-ve-invariant.md` §5) —
  `P2A-07`; nối khoản vào phép trừ két — task `T-125`; diễn một ngày quản trị có bước tạm ứng — cổng
  `P2A-08`; siết chế độ mềm của vết — đường gỡ **F-046**.

**Bàn giao** — 2026-10-01 · thực hiện: **Codex** (migration và bước lùi, file lát, ba file tài liệu đã
có — theo phiếu) và **Claude Code** (thiết kế **ADR-073**, file test viết trước, hàng *Schema* của
`CLAUDE.md`, hai dòng của ngày bán mẫu và **F-054**) · duyệt: **Claude Code** · nhánh `chatgpt_involve`,
trên `a1aa9ca` · chưa commit. Worktree của Codex (`../lean_wt/P2A-04`, nhánh `codex/P2A-04`) mồi bằng
trạng thái chưa commit của clone chính, đã gỡ sau khi đưa về.

*Kết quả.* Hai bảng `staff_advance` · `holiday_bonus` ở
`db/migrations/20260930120000_khoan_cua_nguoi.up.sql` (bước thứ mười một, có bước lùi có khoá chặn); ý
định và ánh xạ ở [`14-luoc-do-khoan-cua-nguoi.md`](../docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md).
Mỗi khoản một dòng mang người nhận, số tiền lớn hơn 0, ngày, người ghi và lúc ghi; tạm ứng mang thêm
người duyệt bắt buộc. Vai ghi sửa được đúng số tiền, người nhận và ngày; không xoá được. Không gì nối
sang két hay doanh thu.

*Codex làm gì, Claude duyệt ra sao.* Codex trả về đúng sáu file của phiếu, không sửa file test (băm
trước và sau giống hệt), và **nói thẳng** sandbox của nó không gọi được Docker nên chưa kiểm gì trên
database. Claude so cây worktree với bản chụp nền (chỉ sáu file ấy đổi), đọc diff thật và tự chạy bộ
kiểm. Lần chạy đầu đỏ giả vì một phiên khác dùng chung compose project (**F-045**); chạy lại với tên
project riêng thì test `I-028` xanh nhưng phép số âm `qd21_so_am` đỏ thật — **F-054**, Claude sửa bằng
hai dòng ở ngày bán mẫu. Trong lúc ấy phiên của `P2A-03` sửa tiếp cùng cây (đóng `U-070`), nên sáu
file được đưa về bằng sửa từng chỗ, không chép đè.

*Nghiệm thu → bằng chứng* (đo 2026-10-01 ở clone chính; mỗi trích dẫn là dòng `NOTICE` hay dòng cổng
in nguyên văn):

| Nghiệm thu | Bằng chứng |
|---|---|
| 1. vế tầng 1 bị từ chối, cả hai loại | test `i028_…`: *tạm ứng không có người duyệt* ⇒ `null value in column "approver_person_id"` · người duyệt lạ ⇒ `staff_advance_approver_person_fkey` · không người nhận ⇒ `"worker_person_id"` · người nhận lạ ⇒ `staff_advance_worker_person_fkey` · `holiday_bonus_worker_person_fkey` · không số tiền ⇒ `"amount_vnd"` · 0đ và số âm ⇒ `staff_advance_positive_amount_check` · `holiday_bonus_positive_amount_check` · không ngày ⇒ `"paid_date"` · không người ghi ⇒ `"person_id"` · người ghi lạ ⇒ `holiday_bonus_person_fkey` |
| 2. kịch bản dương | `YC-31 tạm ứng — của test-người tráng bánh, 500000 đồng, ngày 2026-09-21: test-chủ quán duyệt, test-chủ quán ghi, có lúc ghi: t` · hai dòng `YC-32 thưởng lễ Tết — … 300000 đồng … 200000 đồng, ngày 2026-09-25: test-chủ quán ghi, có lúc ghi: t` |
| 3. kịch bản sửa bằng vai ghi | `sửa khoản (staff_advance) — tiền trước 500000, sau 700000 … lý do "test-gõ nhầm số tiền", test-chủ quán sửa` · `(holiday_bonus) — … ngày trước 2026-09-25, sau 2026-09-26` · `… đổi người nhận: t; lý do "test-ghi nhầm người nhận"` |
| 4. chế độ mềm nói thẳng | `I-028 chế độ mềm — sửa số tiền không khai lý do: 0 vết mới (F-046)` |
| 5. tầng 3 nói thẳng | `I-028 tầng 3 — tạm ứng do người KHÔNG phải chủ quán duyệt: database nhận (1 khoản như thế)` |
| 6. vai ghi chỉ sửa ba cột | `người duyệt của khoản đã ghi không đổi được (shop_app): permission denied` · `người ghi của khoản tạm ứng không đổi được` · `người ghi và lúc ghi của khoản thưởng không đổi được` · `QD-50 khoản tạm ứng không xoá được` · `QD-50 khoản thưởng không xoá được` |
| 7. không nối tiền bán hàng hay két | `không phải tiền bán hàng — sau 5 khoản tạm ứng và 3 khoản thưởng, không bảng nào khác của schema đổi số dòng` · `0 khoá ngoại ngoài các khoá về người, 0 hàm nhắc tới hai bảng, 0 trigger ngoài trigger vết` |
| 8. không chỗ cất sẵn | `staff_advance: amount_vnd,approver_person_id,created_at,id,paid_date,person_id,worker_person_id` · `holiday_bonus: amount_vnd,created_at,id,paid_date,person_id,worker_person_id — không người duyệt, không loại thưởng, không chỗ cho thưởng ngày đông khách` — so từng chữ |
| 9. bước lùi, vòng xuôi · lùi · xuôi lại, quy ước | `PASS lùi 20260930120000_khoan_cua_nguoi — lược đồ giống hệt lúc trước bước ấy (1226 dòng)` · `PASS xuôi lại — 11 bước từ số không … (1289 dòng)` · mười khối `QC-XX` PASS · `PASS từ chối qd21_so_am — QD-21 nội dung: 25 cột tiền …` |
| 10. tên bảng, ranh giới pha, con trỏ | Gate 1e: *36 bảng ở migration, 36 bảng tài liệu nhắc, comm -3 rỗng* · Gate 1d: *7 file .md đã soát* · Gate 1b xanh · hàng *Schema* của `CLAUDE.md` §2 và `docs/product/00-index.md` có file lát |
| 11. cổng xanh ở clone chính | `PASS Gate 1 db-check — 11 bước xuôi · lùi · xuôi lại, 10 khối kiểm QC, 30 file test, … 85 câu trên dữ liệu mồi và ngày mẫu, 85 lỗi cài …` · `PASS gate không cổng nào đỏ` |

*Chưa làm được, và vì sao.* (1) **Câu đối chiếu** của `I-028` (năm tập) chưa viết; dòng ở
`09-doi-chieu-bat-bien.md` §2.1 còn đó, người nợ `P2A-07`. Cho tới lúc ấy vế *người duyệt là chủ quán*
**không có gì giữ**. (2) **Sửa số tiền không khai lý do vẫn đi qua mà không có vết** (**F-046**) — với
tiền đưa cho người làm đây là chỗ hở nặng nhất của lát. (3) **Chưa nối két**: tiền ấy lấy từ két bán
hàng (`U-067`) nhưng phép đối soát cuối ngày chưa trừ nó — task `T-125`. (4) Sáu chỗ **suy ra** của
ADR-073 chưa có lời chủ repo. (5) `YC-31` · `YC-32` chưa vào bộ chấm YC của `db-check` — cổng `P2A-08`.

*Việc kế tiếp.* `P2A-06` (dữ liệu mồi admin) lên đầu *Ready*; `P2A-05` còn chờ `T-125`.

[↑ đầu file](#top)

---

<a id="p2a-05"></a>
### P2A-05 — Hệ thống cộng được mọi đồng đi VÀO quán và chưa biết một đồng nào đi RA

**Phụ thuộc** · bước 5/9 · **cần xong trước:** `P2A-01` · task `T-125` (**xong 2026-10-01**) ·
**chủ repo duyệt `docs/decisions.md` ADR-074** — T-125 mức L3, thiết kế phải được duyệt trước code.
*2026-09-30 (T-124):* `U-066` đã đóng — điện, nước, wifi, xăng xe trả *từ két bán hàng*.
*2026-10-01 (T-125):* tiền ấy rời két *trong ngày, trước lúc đếm két*; `I-029` có vế thứ tư — mỗi
**loại** chi mang nguồn tiền, bắt buộc; `YC-33` đòi đọc ra nguồn của loại và lúc ghi của khoản.

**Goal:**
Xong rồi thì mỗi khoản chi ngoài tiền hàng và lương đọc lại được — loại, số tiền, ngày, ai ghi —
và tổng chi một khoảng ngày đọc ra được bằng một phép cộng.

**Nói một câu, việc phải làm là gì:**
Dựng lát khoản chi cho các loại chủ quán đã kể ở `E44`. **Không** phải làm: lãi/lỗ, phân bổ chi
phí tháng vào ngày, thuế, tiền mang về nhà, tiền người giao nộp — kế hoạch §6.

**Vì sao có task này:**
Chủ quán muốn xem lãi/lỗ (`E47`); vế *chi* của phép tính ấy chưa có chỗ nào cất.

**Không làm thì mất gì:**
- Lãi/lỗ sau này chỉ có vế thu.
- Khoản chi hằng tháng nằm trong tin nhắn và trí nhớ.

**Bị chặn — hỏi gì trước.** Không câu hỏi nào chặn lược đồ. `U-072` (khoản rời két trừ vào két của
ngày bán nào) còn mở nhưng **không** chặn: lát giữ cả ngày khai lẫn lúc ghi (**ADR-074** điểm 4).
Thứ chặn là lượt chủ repo duyệt **ADR-074**.

**Bẫy hay sửa nhầm nhất:**
- **Tiền hàng không vào đây.** §8.10 cấm cộng trùng giò, trứng, rau, quất với mua hàng.
- **Danh sách loại chi chưa đóng.** §8.10 cấm suy rằng quán không có khoản nào khác ⇒ loại chi
  thêm được, không phải một danh sách cứng trong lược đồ.
- **Chữ *cố định hằng tháng* không phải số tiền cố định.**
- **Cột tiền mới ⇒ một dòng ở ngày bán mẫu, cùng thay đổi.** `db/reconcile/proof/qd21_so_am.sql` thử
  `-1` trên một dòng thật của mọi bảng có cột `_vnd`; bảng rỗng ở `db/reconcile/proof/baseline.sql` làm
  `db-check` đỏ (`work/findings.md` **F-054**, 2026-10-01).
- **Không cột *ngày bán của két*, không dấu nguồn trên từng khoản** — nguồn ở **loại**; ngày bán chờ
  `U-072` (**ADR-074** điểm 3 · 4). Bốn loại của `E44` mang nguồn két; loại thêm sau phải khai nguồn.

[↑ đầu file](#top)

---

<a id="p2a-06"></a>
### P2A-06 — Mọi phép kiểm của lát nguyên liệu sẽ chạy trên một danh mục chưa ai dựng từ danh mục thật

**Phụ thuộc** · bước 6/9 · **cần xong trước:** `P2A-02`.

**Goal:**
Xong rồi thì database kiểm có đúng danh mục hàng mua vào của `shop-facts.md` §8.4, sinh lúc chạy.

**Nói một câu, việc phải làm là gì:**
Mở rộng dữ liệu mồi theo cách `P2-10` đã làm (`docs/product/2-db/08-du-lieu-moi.md`): đọc owner
lúc chạy, không cất danh sách thứ hai.

**Không làm thì mất gì:** `P2A-07` · `P2A-08` chạy trên danh mục bịa.

**Bẫy hay sửa nhầm nhất:**
- **§8.4 có hai danh sách tên** (2026-09-06 và 2026-09-25) và cấm tự hợp nhất tên giữa chúng.
- **Thứ chưa có đơn vị ⇒ đơn vị trống.**
- **Không mồi người, không mồi con số ngày** — chúng là dữ liệu của lượt diễn ở `P2A-08`.

[↑ đầu file](#top)

---

<a id="p2a-07"></a>
### P2A-07 — Mệnh đề admin có phép đối chiếu viết bằng lời, và chưa câu nào chạy được

**Phụ thuộc** · bước 7/9 · **cần xong trước:** các lát đã nhận được trong `P2A-02` → `P2A-05` ·
`P2A-06`.

**Goal:**
Xong rồi thì lệnh đối chiếu sau khi đóng quán chạy cả phép của admin, và mỗi phép được chứng minh
biết kêu.

**Nói một câu, việc phải làm là gì:**
Thêm câu vào bộ của `P2-11` theo đúng luật của nó (`docs/decisions.md` **ADR-066**,
`docs/product/2-db/09-doi-chieu-bat-bien.md`): một tập một câu, một lỗi cài cho mỗi câu.

**Không làm thì mất gì:** một ràng buộc admin bị gỡ mà không ai biết.

**Bẫy hay sửa nhầm nhất:**
- **Lát còn bị chặn thì ghi *vắng*, không viết câu rỗng giữ chỗ.**
- **Một câu rỗng vì viết sai trông y hệt một câu rỗng vì dữ liệu đúng** (**F-017**) ⇒ lỗi cài là
  bắt buộc.

[↑ đầu file](#top)

---

<a id="p2a-08"></a>
### P2A-08 — Bốn file lát sẽ tự khai là xong, mà chưa ai diễn thử một ngày của chủ quán qua chúng

**Phụ thuộc** · bước 8/9 · **cần xong trước:** `P2A-01` → `P2A-07`.

**Goal:**
Xong rồi thì một ngày quản trị — nhập sổ nguyên liệu, chấm công, ghi khoản chi, duyệt tạm ứng —
ghi được và đọc lại được bằng dữ liệu thật, và tám ô cổng ở kế hoạch §7 có output.

**Nói một câu, việc phải làm là gì:**
Diễn ngày ấy theo cách `P2-13` đã diễn ba scenario bán hàng (**ADR-067**), chấm ngược từng dòng
`YC` của `P2A-01`, ký ô. Thêm mục vào `docs/product/2-db/11-cong-chat-luong-pha-2.md`.

**Không làm thì mất gì:** lược đồ đẹp mà không chạy nổi một ngày.

**Bẫy hay sửa nhầm nhất:**
- **Ngày quản trị chưa có scenario viết sẵn ở pha 1.** Các bước của nó lấy **từ lời chủ quán** ở
  `shop-facts.md` §8, mỗi bước trỏ về một dòng; bước nào không trỏ được thì không diễn.
- **Ô của lát còn bị chặn ghi *vắng, chờ câu nào***, không ghi *đạt*.
- **Chỗ không trả lời được thành `F-XXX`/`U-XXX`**, không thiết kế bù.

[↑ đầu file](#top)

---

<a id="p2a-09"></a>
### P2A-09 — File lát admin là cửa mới để pha 2 viết hộ pha 3

**Phụ thuộc** · bước 9/9 · **cần xong trước:** `P2A-08`.

**Goal:**
Xong rồi thì không file lát admin nào mang endpoint, route, component hay luật *ai được xem gì*,
và mọi con trỏ từ `shop-facts.md` §8, `work/backlog_AD.md`, `architecture.md` §14 sang chỗ mới
còn đúng.

**Nói một câu, việc phải làm là gì:**
Chạy lại phép rà của `P2-14` trên các file mới; đọc `work/findings.md` **F-049** trước (Gate 1d
hẹp hơn phép rà).

**Không làm thì mất gì:** pha 3 đọc một dòng quyền xem lương do lát viết hộ như đã chốt.

**Bẫy hay sửa nhầm nhất:**
- **In cả lệnh chưa lọc cạnh lệnh đã lọc** (**F-017**).
- **Quyền xem là chỗ dễ lọt nhất**: `C34` · `C35` là lời chủ quán, nhưng thi hành chúng là pha 3.

[↑ đầu file](#top)
