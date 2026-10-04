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
- **Câu đối chiếu `I-029` là của bước này, không còn của `P2A-07`** (2026-10-01, Claude Code, lúc
  nhận `P2A-07`): lát dựng xong thì viết câu cùng lỗi cài theo khuôn `db/reconcile/i028.sql`, và gỡ
  dòng `I-029` ở `09-doi-chieu-bat-bien.md` §2.1 trong cùng thay đổi.
- **Phép trừ két đã chạy — khoản chi phải vào nó cùng lượt** (2026-10-05, Claude Code, `T-133`):
  câu `I-021/1` đọc hạng tử *chi từ két* qua hàm `pg_temp.ket_ngay` của `db/reconcile/prelude.sql`, hôm
  nay chỉ tạm ứng và thưởng. Khoản chi của loại mang nguồn két thêm vào hàm ấy, cùng luật *ngày khai
  khác ngày ghi thì chờ `U-072`*; thiếu nó thì `I-021/1` kêu mọi ngày có trả tiền điện, và dòng khoản
  chi của ngày mẫu làm lệch số đếm két ở `baseline.sql` — cộng nó vào khối số đếm cùng lượt.
- **Lát vào sau `P2A-09` thì tự chạy lượt rà ấy trên file của mình** (2026-10-01, Claude Code, T-130):
  ô 7 · 8 của cổng ghi lát này *vắng*; trước khi tick `Done`, chạy đủ các lượt lọc của
  [`P2A-09`](#p2a-09) trên `15-luoc-do-khoan-chi.md` và migration của lát, dán cặp *chưa lọc · đã
  lọc*, rồi đổi chữ *vắng* ở hai ô ấy thành kết quả.

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

**Nhận việc** — điền 2026-10-01 (Claude Code); `P2A-02` đã `Done` và đã commit (`a1aa9ca`); mức **L1**
(kế hoạch §5: không tiền, không dữ liệu thật — dữ liệu mồi chỉ vào database kiểm). Chủ repo yêu cầu
*"yêu cầu codex làm bạn kiểm tra"*; chia vai theo `CLAUDE.md` §7.4 và `docs/prompt-guideline.md` §6.1
mức L1: **Claude** viết nghiệm thu và scope, **Codex** thi công trong worktree riêng, Claude duyệt diff
thật và tự chạy lại. Lát `P2A-03` lúc nhận **chưa commit**; task này không dựa vào nó, nhưng worktree
của Codex được mồi bằng đúng các file migration chưa commit để bộ kiểm chạy cùng một dãy bước như clone
chính.

Cách đọc hai danh sách của §8.4 lúc nhận — **cách đọc của phiên, không phải lời chủ quán**
(`work/findings.md` **F-004**): hai tên **giống hệt nhau khi bỏ hoa thường** là **một** thứ (*gạo* ·
*Gạo*, *rau mùi tàu* · *Rau mùi tàu*), và mang đơn vị của bảng 2026-09-25; hai tên khác nhau dù chỉ
một chữ là **hai** thứ (*Mộc nhĩ* ≠ *nhân thịt mộc nhĩ*, *Gạo* ≠ *bột bánh cuốn*) — đó là lệnh *"không
tự hợp nhất các tên khác"* của owner. Cách đọc ấy khớp với câu **B12** ở `work/admin-questions.md`:
mười hai tên cũ B12 còn hỏi đơn vị đúng là mười bốn tên cũ trừ hai tên trùng.
- *Phạm vi:* `work/scope/P2A-06.txt` — `db/seed/seed.pl`, `scripts/db-check.sh`,
  `docs/product/2-db/08-du-lieu-moi.md`, `docs/product/2-db/09-doi-chieu-bat-bien.md` (hai hàng *chờ
  dữ liệu mồi*), `docs/product/00-index.md`, entry này, dòng trạng thái.
- *Nghiệm thu:*
  1. **Bộ dựng đọc cả hai danh sách của §8.4 lúc chạy**: danh sách nguyên văn trong ngoặc kép của đoạn
     *Danh mục nguyên liệu — chủ quán bắt đầu liệt kê 2026-09-06* và bảng có cột *Hàng mua vào*; `db/seed/seed.pl`
     không mang một tên hàng hay một đơn vị của quán, và `08-du-lieu-moi.md` không chép danh sách
     (`grep -i` *mộc nhĩ*, *găng tay* trên hai file ấy trả rỗng). *Sửa lúc duyệt 2026-10-01:* bản đầu
     đòi rỗng trên cả `db/`, nhưng chữ *mộc nhĩ* ở migration menu, test và ngày bán mẫu là tên **lựa
     chọn nhân** của menu (§4.4), có từ trước — nghiệm thu viết rộng quá, không phải lỗi thi công.
  2. **Tên trùng khi bỏ hoa thường là một dòng, tên khác nhau là hai dòng**: database có đúng
     *14 + 18 − 2 = 30* dòng `supply_item` trên owner hôm nay; *Gạo* và *Rau mùi tàu* mỗi tên một
     dòng mang đơn vị của bảng; *Mộc nhĩ* và *Nhân thịt mộc nhĩ* là hai dòng.
  3. **Thứ chưa có đơn vị thì đơn vị trống**: đúng mười hai dòng có `purchase_unit` rỗng (NULL), và
     là mười hai tên cũ; không dòng nào mang đơn vị do bộ dựng tự gán. Đơn vị của bảng lấy ô *Đơn vị
     mua*, bỏ phần ghi chú trong ngoặc (*túi (chủ quán nói "1 túi")* ⇒ *túi*).
  4. **Đối chiếu hai chiều trong `db-check`** (kế hoạch §5 hàng `P2A-06`): danh sách tên bộ dựng đọc
     từ owner và danh sách tên trong database qua `comm -3` ⇒ rỗng; dòng `PASS` in số thứ và số thứ
     chưa có đơn vị, đếm từ database; lệch ⇒ `FAIL` và in cả hai danh sách.
  5. **Owner đổi hình ⇒ FAIL, không dựng nửa chừng** (cùng cách `SHOP_FACTS` của `P2-10`), chạy thật
     trên bản sao hỏng: mất đoạn danh sách 2026-09-06 · mất bảng *Hàng mua vào* · một ô *Đơn vị mua*
     rỗng · một tên lặp trong cùng một danh sách ⇒ bộ dựng dừng, gọi tên chỗ hỏng; thêm một hàng vào
     bảng ⇒ database có 31 dòng.
  6. **Không mồi người, không mồi con số ngày**: sau dữ liệu mồi, `supply_day_entry` có 0 dòng; bộ
     dựng không thêm người nào cho lát này.
  7. **`08-du-lieu-moi.md` nói đủ**: hàng `supply_item` ở §1, cách đọc tên trùng và phần trong ngoặc
     ở §2 (phiên chọn, có ngày), bằng chứng ở §3, chỗ trống *đơn vị của mười hai tên cũ* ở §4 trỏ về
     câu B12; hai hàng `I-025` · `I-026` của `09-doi-chieu-bat-bien.md` thôi nói *chờ dữ liệu mồi*.
  8. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh ở worktree của Codex và ở clone chính.
- *Kiểm chứng:* `./scripts/db-check.sh` bước 4; các lần chạy trên bản sao hỏng dán ở *Bàn giao*.
- *Ngoài phạm vi, có tên:* đơn vị của mười hai tên cũ — lời chủ quán 2026-09-30 còn là **bản nháp ở
  `work/admin-questions.md` B12, chưa về owner**, nên bộ dựng **không** đọc nó; khi lời ấy về §8.4 thì
  lần dựng sau tự mang đơn vị mới nếu nó nằm trong bảng *Hàng mua vào*. Hàng *dữ liệu mồi* ở
  `12-luoc-do-nguyen-lieu.md` §5 — file đang mang thay đổi chưa commit của `P2A-03`, sửa sau khi lát
  ấy commit. Câu đối chiếu `I-025` · `I-026` — `P2A-07`.

**Bàn giao** — 2026-10-01 · thực hiện: **Codex** (bộ dựng, bước 4 của bộ kiểm, ba file tài liệu — theo
phiếu) · duyệt: **Claude Code** (thêm thụt lề cho phần in hai danh sách của `db-check`, câu *bản nháp
B12* ở `08-du-lieu-moi.md` §4, gói dòng đầu file ấy) · nhánh `chatgpt_involve`, trên `a306d29` · chưa
commit. Worktree của Codex (`../lean_wt/P2A-06`, nhánh `codex/P2A-06`) mồi thêm ba file chưa commit
của `P2A-03`; đã gỡ sau khi đưa về.

*Kết quả.* `perl db/seed/seed.pl` in thêm một khối `INSERT INTO supply_item` đọc từ §8.4 lúc chạy;
`perl db/seed/seed.pl --supply-names` in danh sách tên ấy. Cách gộp là phiên chọn ở
[`08-du-lieu-moi.md`](../docs/product/2-db/08-du-lieu-moi.md) §2, chưa có lời chủ repo.

*Codex làm gì, Claude duyệt ra sao.* Codex trả đúng năm file của phiếu và chạy thật năm ca bản sao
hỏng (exit 1, stdout rỗng, lời lỗi gọi chỗ hỏng; thêm một hàng ⇒ 31 tên), nhưng **không chạy được
database** vì sandbox chặn socket Docker, và gate trong worktree đỏ vì Claude mồi thiếu file tài liệu
của `P2A-03` (Gate 1b · 1c · 1e nói về `13-luoc-do-cham-cong.md`) — lỗi mồi worktree, không phải lỗi
thi công. Claude đọc diff thật, đưa về clone chính bằng patch, rồi tự chạy:

```text
$ ./scripts/db-check.sh        # exit=0
PASS dữ liệu mồi — 15 bàn · 15 mã QR hiện hành · 6 thành phần · 10 dòng menu · 2 nhóm tuỳ chọn · 10 trạm của thành phần · 30 hàng mua vào · 12 hàng chưa có đơn vị
PASS tên hàng mua vào — comm -3 rỗng (owner ↔ supply_item)
db-check: PASS — 11 bước xuôi · lùi · xuôi lại, 10 khối kiểm QC, 30 file test, dữ liệu mồi + §4.8, khoá chặn, đối chiếu: 85 câu trên dữ liệu mồi và ngày mẫu, 85 lỗi cài, ba scenario + đối chiếu trên ngày diễn, 24 mã YC
```

*Nghiệm thu → bằng chứng.* (1) đọc lúc chạy qua `section('### 8.4 ')` và `table('Hàng mua vào', …)`;
`grep -i` *mộc nhĩ* · *găng tay* trên `seed.pl` và `08-du-lieu-moi.md` rỗng. (2) SQL sinh ra có 30 dòng,
*Gạo* — *kg*, *Rau mùi tàu* — *túi*, *Mộc nhĩ* — *kg* tách khỏi *Nhân thịt mộc nhĩ* — NULL; dòng `PASS`
đếm 30 từ database. (3) mười hai dòng NULL, đúng mười hai tên cũ của B12; dòng `PASS` đếm 12 từ
database. (4) dòng `PASS tên hàng mua vào` ở trên; nhánh `FAIL` của phép so **chưa được chạy cố ý**
(cần cài lệch giữa SQL và `--supply-names`), chỉ đọc mã. (5) năm ca bản sao hỏng của Codex, lời lỗi dán ở
báo cáo: *không đọc được danh sách 2026-09-06* · *không thấy bảng có cột 'Hàng mua vào'* · *Đơn vị mua
rỗng ở 'Túi nóng'* · *tên lặp trong danh sách 2026-09-06* / *trong bảng Hàng mua vào* · 31 tên. (6) SQL
không có `INSERT INTO supply_day_entry`; số `INSERT INTO person` là 5, bằng HEAD. (7)(8) diff của ba file
tài liệu. (9) `db-check` trên, gate dưới khối commit.

*Còn lại.* Đơn vị của mười hai tên cũ chờ lời chủ quán về owner (bản nháp B12); hàng *dữ liệu mồi* ở
`12-luoc-do-nguyen-lieu.md` §5 còn nói *chưa có* — sửa sau khi `P2A-03` commit; `P2A-07` viết câu đối
chiếu `I-025` · `I-026` trên danh mục này.

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

**Nhận việc** — điền 2026-10-01 (Claude Code); mức **L2** (kế hoạch §5). *Cần xong trước* đọc theo
kế hoạch §5 dòng cuối: bước chung chạy trên lát đã `Done` — `P2A-02` · `P2A-04` · `P2A-06` đã commit,
`P2A-03` đã `Done` mà **chưa commit** (worktree của Codex mồi bằng trạng thái cây của clone chính, như
`P2A-04`); `P2A-05` chưa dựng (chờ chủ repo duyệt **ADR-074**) ⇒ `I-029` ghi *vắng*, người nợ đổi sang
`P2A-05`. Chủ repo yêu cầu *"codex sẽ thực hiện và bạn kiểm tra"*; chia vai theo `CLAUDE.md` §7.4.
Lúc nhận, Claude thấy ô `I-021` của pha 1 có **bảy** tập từ T-125 mà ánh xạ §1 còn đếm **sáu** —
câu `I-021/2` · `I-021/6` mang số của tập khác (**F-055**); việc này cần chữa trước khi `I-028` trỏ
sang tập *trừ vào đúng một ngày bán* của ô ấy, nên gộp vào bước này.

*Thiết kế — Claude chọn, lựa chọn của phiên, chưa có lời chủ repo.* Số `n` đếm các vế **có tập** của
ô *Phép đối chiếu* ở `03-bao-ve-invariant.md` §5, từ trái; vế pha 1 nói thẳng *chưa có tập* không
mang số (cùng luật đoạn cuối §1 của file 09).
- `I-025`: 1 đủ ba dấu → câu · 2 không chạm và cập nhật có vết → câu đọc **chuỗi vết đứt** (dưới).
- `I-026`: 1 tổng và cộng dồn · 2 hiệu số → §2 lý do (B): tổng và hiệu số không có chỗ cất
  (**ADR-071**) · 3 một đáp số → câu · 4 danh mục → câu, tên trùng theo phép bằng của cột.
- `I-027`: 1 người · ngày · người tick → câu · 2 một ô → câu · 3 huỷ → câu · 4 chủ quán tick →
  câu (tầng 3, không ràng buộc nào để gỡ: lỗi cài là một ô người không phải chủ quán tick).
- `I-028`: 1 đủ dấu (hai bảng) → câu · 2 có người duyệt → câu · 3 chủ quán duyệt → câu · 4 không sửa
  đè → câu đọc chuỗi vết đứt · 5 không phải tiền bán hàng → §2 lý do (B): không cột nào nối (**ADR-073**)
  · 6 rời két → §2 lý do (A), trỏ tập `I-021` mới, chờ **U-072** · **F-048**.
- **Chuỗi vết đứt** — cách đọc *đổi mà không có vết* dưới chế độ mềm (**F-046**): một dòng có ít nhất
  một vết mà bản sau của vết mới nhất khác dòng hiện tại, hoặc bản trước của một vết khác bản sau của
  vết liền trước. Dòng chưa từng có vết thì không câu nào thấy lần sửa không khai lý do — ghi vào §4.
- `I-021`: đánh số lại theo bảy tập — 1 → §2 · 2 (mới, trừ vào đúng một ngày bán) → §2 chờ **U-072** ·
  3 → `I-021/3` (câu cũ `I-021/2`) · 4 · 5 · 6 → §2 · 7 → `I-021/7` (câu cũ `I-021/6`).

- *Phạm vi:* `work/scope/P2A-07.txt` — `db/reconcile/` (câu, phần dùng chung, ngày bán mẫu, file lỗi
  cài), `scripts/db-check.sh` · `scripts/reconcile.sh` · `scripts/reconcile.test.sh` (chỉ khi cần),
  file 09 và ba file lát admin, entry này, dòng trạng thái, `work/findings.md`.
- *Nghiệm thu:*
  1. **Mỗi tập có câu ở thiết kế trên có đúng một khối `-- @@ I-0xx/n`** trong `db/reconcile/i025.sql`
     … `i028.sql`; `./scripts/reconcile.sh --codes` không còn `NOTE` cho `I-025`…`I-028`, chỉ còn `I-029`.
  2. **Ngày bán mẫu có dữ liệu admin thật cho mọi câu mới**: con số nguyên liệu mua vào và đã dùng, ít
     nhất một con số sửa có lý do; ô chấm công chủ quán tick, một ô huỷ có ghi chú rồi tick lại; khoản
     tạm ứng sửa có lý do — và mọi câu (cũ lẫn mới) vẫn **0 dòng** trên ngày ấy.
  3. **Mỗi câu mới có ít nhất một file lỗi cài**, tập câu kêu bằng đúng dòng `-- kêu:`; tập có ràng buộc
     tầng 1 thì lỗi gỡ ràng buộc ấy trước. Hai câu chuỗi vết đứt có lỗi cài là một lần sửa **không khai
     lý do** sau một lần sửa có vết.
  4. **`I-021` đánh số lại**: khối, file lỗi cài và mọi con trỏ ngoài `work/` dùng `I-021/3` · `I-021/7`;
     §1 · §2 · §4 của file 09 đếm bảy tập.
  5. **File 09**: §1 có bốn hàng mới và hàng `I-021` mới; §2 có hàng cho `I-026` tập 1 · 2, `I-028` tập
     5 · 6 và `I-021` tập 2; §2.1 chỉ còn `I-029`, người nợ `P2A-05`; §4 có hai cách đọc mới (chuỗi vết
     đứt, tên trùng theo phép bằng của cột); con số *đo lại* của §1 cập nhật.
  6. **Ba file lát admin** không còn ghi câu đối chiếu là việc chưa làm của `P2A-07`.
  7. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh — Claude tự chạy ở worktree **và** ở clone chính.
- *Kiểm chứng:* bước đối chiếu và chứng minh của `./scripts/db-check.sh`; `./scripts/reconcile.sh --codes`.
- *Ngoài phạm vi, có tên:* câu `I-029` — `P2A-05`; tập *trừ vào đúng một ngày bán* — **U-072**; siết
  chế độ mềm — **F-046**; diễn một ngày quản trị — `P2A-08`.

**Bàn giao** — 2026-10-01 · thực hiện: **Codex** (worktree `../lean_wt/P2A-07`, nhánh `codex/P2A-07`, trên
`c93f069`) · duyệt: **Claude Code** · nhánh `chatgpt_involve`, trên `719a430` · chưa commit. Diff được chép
vào clone chính **trước** lượt duyệt, không qua Claude; lượt chép bỏ sót hai lần xoá `proof/i021_2.sql` ·
`proof/i021_6.sql` (gate đỏ *câu không có lỗi cài*), đã gỡ trước khi Claude chạy gate lần cuối. Claude không
đọc báo cáo của Codex trong lượt này; lượt duyệt dựa trên diff thật và output dưới đây.

*Claude duyệt ra sao.* So từng file thay đổi của worktree với clone chính bằng `cmp`: khớp từng byte, trừ
`work/backlog.md` · `work/findings.md` (mang thêm phần của T-128 — đúng). Đọc mười hai khối `-- @@`, mười bốn
file lỗi cài, hàm `pg_temp.chuoi_vet_dut` ở `db/reconcile/prelude.sql`, phần thêm vào `baseline.sql`, file 09
và ba file lát. Gate chạy ở clone chính lúc không phiên nào khác dùng database (hai lần trước đỏ giả vì
**F-045**, nay đã chữa ở T-128):

```text
$ ./scripts/gate.sh            # exit=0
    reconcile: PASS — 75 câu I-0xx · 22 câu QD, mọi tập rỗng · 1 mệnh đề chưa có lát
    PASS ngày bán mẫu đúng (db/reconcile/proof/baseline.sql) — 97 câu chạy, mọi tập rỗng
    PASS mọi câu có lỗi cài nhắm vào nó — comm -3 rỗng (97 câu, 97 file lỗi)
PASS  Gate 1   db-check — 11 bước xuôi · lùi · xuôi lại, 10 khối kiểm QC, 30 file test, dữ liệu mồi + §4.8, khoá chặn, đối chiếu: 97 câu trên dữ liệu mồi và ngày mẫu, 97 lỗi cài, ba scenario + đối chiếu trên ngày diễn, 24 mã YC
PASS  gate     không cổng nào đỏ
$ ./scripts/reconcile.sh --codes
NOTE I-029 chưa có lát — ai nợ: `P2A-05` — docs/product/2-db/09-doi-chieu-bat-bien.md §2.1
PASS mã I-0xx — 28 mã có câu + 1 mã chưa có lát = 29 mã ở quality/invariants.md
```

*Nghiệm thu → bằng chứng.* (1) mười hai khối `I-025/1 · 2`, `I-026/3 · 4`, `I-027/1…4`, `I-028/1…4` đúng
thiết kế; `--codes` chỉ còn `NOTE I-029`. (2) `baseline.sql` thêm con số mua vào · đã dùng và một lần sửa con
số, ô chấm công huỷ có ghi chú rồi tick lại, khoản tạm ứng sửa; dòng *ngày bán mẫu đúng* trên — và
`i025_2` · `i028_4` tìm thấy dòng đã có vết nên các lần sửa ấy để lại vết. (3) mười hai dòng `PASS kêu
i025_1 … i028_4`, mỗi dòng đúng mã của `-- kêu:`; lỗi tầng 1 gỡ ràng buộc trước (vd. `i027_2` gỡ
`attendance_day_one_live_per_worker_day_key`); `i025_2` chứng minh nhánh *khe giữa hai vết*, `i028_4` nhánh
*bản sau mới nhất lệch dòng* — cả hai là lần sửa không khai lý do sau một lần có vết. (4) `PASS kêu i021_3 —
I-021/3` · `PASS kêu i021_7 — I-021/7`; `grep -rnE 'I-021/[26]([^0-9]|$)' db docs scripts quality
master_plan` rỗng. (5) file 09 §1 bốn hàng mới + hàng `I-021` bảy tập, đo lại *75 câu*; §2 hàng `I-026` tập
1 · 2, `I-028` tập 5 · 6, `I-021` tập 2; §2.1 chỉ `I-029`, người nợ `P2A-05`; §4 hai cách đọc mới. (6) ba
file lát ghi *đã có câu … (P2A-07, 2026-10-01)*. (7) gate trên; **chưa** chạy ở worktree — clone chính
khớp từng byte nên một lần chạy là đủ.

*Còn lại.* `I-029` — `P2A-05` (chờ chủ repo duyệt **ADR-074**); tập *trừ vào đúng một ngày bán* — **U-072**;
dòng chưa từng có vết thì không câu nào thấy lần sửa mất vết — **F-046**; ai được huỷ ô chấm công — **U-071**.
Worktree `../lean_wt/P2A-07` gỡ sau khi commit. Bước kế: `P2A-08`.

[↑ đầu file](#top)

---

<a id="p2a-08"></a>
### P2A-08 — Bốn file lát sẽ tự khai là xong, mà chưa ai diễn thử một ngày của chủ quán qua chúng

**Phụ thuộc** · bước 8/9 · **cần xong trước:** `P2A-01` → `P2A-07`.

**Goal:**
Xong rồi thì một ngày quản trị — nhập sổ nguyên liệu, chấm công, ghi khoản chi, duyệt tạm ứng —
ghi được và đọc lại được bằng dữ liệu thật, và ô 1–6 của cổng ở kế hoạch §7 có output. Ô 7 · 8
không ký ở đây: bằng chứng của chúng là phép lọc của `P2A-09`, chạy sau bước này (T-130).

**Nói một câu, việc phải làm là gì:**
Diễn ngày ấy theo cách `P2-13` đã diễn ba scenario bán hàng (**ADR-067**), chấm ngược từng dòng
`YC` của `P2A-01`, ký ô. Thêm mục vào `docs/product/2-db/11-cong-chat-luong-pha-2.md`.

**Không làm thì mất gì:** lược đồ đẹp mà không chạy nổi một ngày.

**Bẫy hay sửa nhầm nhất:**
- **Ngày quản trị chưa có scenario viết sẵn ở pha 1.** Các bước của nó lấy **từ lời chủ quán** ở
  `shop-facts.md` §8, mỗi bước trỏ về một dòng; bước nào không trỏ được thì không diễn.
- **Ô của lát còn bị chặn ghi *vắng, chờ câu nào***, không ghi *đạt*.
- **Chỗ không trả lời được thành `F-XXX`/`U-XXX`**, không thiết kế bù.

**Acceptance** — Claude Code viết 2026-10-01, trước khi giao Codex (lời chủ repo *"giao những việc còn
lại cho codex và bạn kiểm tra"*):
1. **Ngày quản trị là một file `db/scenario/s4_ngay_quan_tri.sql`**, chạy sau `s1`…`s3` trong cùng lượt
   diễn của bước 7 `db-check`, đúng khuôn `P2-13` (**ADR-067**): mỗi bước ở quán một khối `DO`, một giao
   dịch COMMIT, một dòng `NOTICE 'S4.n …'`, người thao tác khai qua `pg_temp.sc_buoc`. Mỗi bước có một
   dòng chú thích trỏ về **mục và dòng** của `master_plan/shop-facts.md` §8 (§8.4 · §8.7) đã chốt nó;
   bước nào không trỏ được thì không diễn. Tối thiểu: thêm một thứ mới vào danh mục; nhập con số mua
   vào và đã dùng của hai thứ, một thứ hai ngày; chủ quán tick ô *có đi làm* cho hai người, tick nhầm
   một ô rồi huỷ (có người huỷ, ghi chú); một khoản tạm ứng có người duyệt; một khoản thưởng. Số tiền,
   tên người là **dữ liệu diễn**, khai ở chú thích đầu file như `s2`.
2. **Bước *ghi khoản chi* không diễn**: `P2A-05` chưa `Done` (chờ chủ repo duyệt **ADR-074**) ⇒ file ghi
   một dòng chú thích *vắng, chờ ADR-074*, không dựng bảng hay dòng thay.
3. **Đọc lại ở kết nối khác**: `db/scenario/doc_lai.sql` thêm phần đọc lại ngày quản trị — mỗi bước một
   phép so với giá trị mong đợi viết tay (tổng, hiệu số của một thứ đọc bằng một phép cộng; ô đã huỷ
   đọc ra ai huỷ; tạm ứng đọc ra người duyệt); sai thì `RAISE EXCEPTION`, như các dòng có sẵn.
   Các dòng `TIỀN` của ba scenario bán hàng **không đổi**; nếu tạm ứng hay thưởng làm một con số két
   của ngày đổi thì **dừng và báo**, không sửa giá trị mong đợi của `s1`…`s3`.
4. **Bộ đối chiếu trên ngày vừa diễn vẫn rỗng** — dòng `PASS đối chiếu trên ngày vừa diễn` của `db-check`.
5. **Chấm `YC-26`…`YC-32`** trong `db/scenario/yc.sql`, mỗi mã một dòng *đọc* và một dòng *sai*, dùng đúng
   các kết cục đã có (`TỪ CHỐI` · `KHÔNG CHỖ` · `ĐI QUA` · `GỌI TÊN` · `DỰNG ĐƯỢC` · `CHƯA TRẢ LỜI ĐƯỢC`);
   `GỌI TÊN` trỏ tới lỗi cài có thật ở `db/reconcile/proof/`. Một vế không trả lời được ⇒ ghi kết cục
   thật và báo, không thiết kế bù.
6. **`db-check` đòi cả mã §9**: `yc_want` của bước 7 hôm nay chỉ đọc mã đứng trước §8 của
   `04-yeu-cau-du-lieu.md`, nên `YC-26`…`YC-33` không bị đòi. Nới nó đọc cả §9, **trừ** mã nằm trong một
   danh sách *YC chưa có lát* có tên ở mục mới của `11-cong-chat-luong-pha-2.md` (dạng
   `- YC-33 — chờ P2A-05 (ADR-074)`), cùng khuôn danh sách *mệnh đề chưa có lát* của
   `09-doi-chieu-bat-bien.md` §2.1 (**ADR-070**): mã trong danh sách được in `NOTE`; mã trong danh sách
   mà **đã** có đọc + sai ⇒ `FAIL` (danh sách tự hết hạn); mã trong danh sách không có ở owner ⇒ `FAIL`.
   Ba ca này có bằng chứng chạy thật (sửa tạm, chạy, trả lại).
7. **Mục mới `## 9. Ngày quản trị — P2A-08`** ở `docs/product/2-db/11-cong-chat-luong-pha-2.md`: bảng bước
   ↔ dòng `shop-facts.md`; bảng chấm `YC-26`…`YC-32`; danh sách *YC chưa có lát*; **ô 1–6** của kế hoạch
   §7 mỗi ô một output thật dán nguyên dòng, ô của `P2A-05` ghi *vắng, chờ ADR-074*; ô 7 · 8 ghi *của
   `P2A-09`*. §8 của file (bảng *bước sau đọc gì*) thêm dòng cho `P2A-09`. Không sửa §0…§7 ngoài chỗ ấy.
8. `./scripts/db-check.sh` và `./scripts/gate.sh` xanh, output cuối dán nguyên.

**Không làm trong bước này:** đổi migration, đổi lời chủ quán, đổi `YC` hay mệnh đề, lấp `F-046` · `F-048`,
dựng gì cho `P2A-05`.

**Bàn giao** — 2026-10-01 · thực hiện: **Codex** (worktree `../lean_wt/P2A-08`, nhánh `codex/P2A-08`, trên
`66789d6`) · duyệt và chạy database: **Claude Code**. Sandbox của Codex chặn Docker socket (`connect:
operation not permitted`), nên Codex nộp phần viết chưa chạy. Claude chạy `db-check` trong worktree: lần
đầu `FAIL đọc lại … record "a" is not assigned yet` — biến bản ghi `a` của phần đọc S4 trùng bí danh bảng
`attendance_day a`; Claude đổi tên thành `rec` (một chỗ), chạy lại ⇒ `db-check: PASS`. Claude viết lại
§9 phần đầu, §9.4 (ô 1–6 ký kèm output) và §9.5 (ba ca danh sách chạy thật qua toàn bộ `db-check`). File:
`db/scenario/s4_ngay_quan_tri.sql` (mới) · `db/scenario/doc_lai.sql` · `db/scenario/yc.sql` ·
`scripts/db-check.sh` · `docs/product/2-db/11-cong-chat-luong-pha-2.md` §9 · §8.

| Acceptance | Bằng chứng (Claude chạy) |
|---|---|
| 1 · 2 | `PASS ba scenario + ngày quản trị diễn qua lược đồ — 41 dòng bước`; S4.1…S4.9 mỗi bước một dòng `shop-facts.md` §8 (soát ba chỗ: §8.4 dòng 1552, §8.7 dòng 1858 · 1866); bước khoản chi ghi *vắng, chờ ADR-074* |
| 3 | `PASS đọc lại ba scenario + ngày quản trị ở kết nối khác`; `S4 tổng Gạo: mua 12 · dùng 13 · hiệu số -1`; `TIỀN ba scenario: S1 96000 · S2 95000 · S3 54000 · cộng 245000 đ` — bằng §4 |
| 4 | `PASS đối chiếu trên ngày vừa diễn — 75 câu I-0xx · 22 câu QD, mọi tập rỗng · 1 mệnh đề chưa có lát` |
| 5 | `PASS chấm YC — 31 mã`; mười hai vế admin ở `11-cong-chat-luong-pha-2.md` §9.2 |
| 6 | `NOTE YC-33 chưa có lát`; thêm tạm `YC-32` ⇒ `FAIL … dòng hết hạn`; thêm tạm `YC-99` ⇒ `FAIL … không có ở owner` (§9.5) |
| 7 | §9 đọc lại; Gate 1b · 1d PASS |
| 8 | `./scripts/gate.sh` ở clone chính sau khi gộp cả `T-126` · `T-131` ⇒ `PASS gate` |

**Còn lại:** ô 7 · 8 là của `P2A-09`; `P2A-05` vắng ở mọi ô. Bộ đối chiếu rỗng trên ngày có tạm ứng và
thưởng **vì** hạng tử *chi từ két* chưa có câu (ADR-074 điểm 7), không phải vì két đã trừ đúng. Chưa review
độc lập.

[↑ đầu file](#top)

---

<a id="p2a-09"></a>
### P2A-09 — File lát admin là cửa mới để pha 2 viết hộ pha 3

**Phụ thuộc** (kế hoạch §5 thắng khi lệch) · bước 9/9 · **cần xong trước:** `P2A-08`. Lát chưa
`Done` lúc nhận việc không giữ chân bước này (kế hoạch §5, *Chạy song song được*): rà trên lát đã
có, ghi lát kia *vắng* — xem *Lát vắng* dưới đây.

**Goal:**
Xong rồi thì không file lát admin nào mang endpoint, route, component hay luật *ai được xem gì*,
không lát nào cất thứ thuộc kế hoạch §6, mọi con trỏ sang chỗ mới còn đúng, và **ô 7 · 8 của cổng**
(kế hoạch §7) được ký kèm bằng chứng ở mục cổng mà `P2A-08` thêm vào
`docs/product/2-db/11-cong-chat-luong-pha-2.md`.

**Nói một câu, việc phải làm là gì:**
Chạy lại chín lệnh của `P2-14` (`work/backlog_DB.md` → P2-14, khối *Bàn giao*: A1…D) trên tập dưới
đây, **thêm** một lượt lọc cho §6, rà con trỏ hai chiều, ký hai ô. Đọc `work/findings.md` **F-049**
trước: Gate 1d hẹp hơn phép rà, nên output của nó không ký được ô 8 một mình.

**Không làm thì mất gì:** pha 3 đọc một dòng quyền xem lương do lát viết hộ như đã chốt; một cột
*"để sẵn cho sau này"* của phần §6 thành luật không ai nói (kế hoạch §9).

**Tập phải rà** (viết 2026-10-01 ở T-130, trước khi `P2A-05` · `P2A-08` xong — lúc nhận việc đếm lại
bằng `git log --name-only` của các commit `P2A-01`…`P2A-08`, và tập đếm được thắng danh sách này):
- *File lát:* `docs/product/2-db/12-luoc-do-nguyen-lieu.md` · `13-luoc-do-cham-cong.md` ·
  `14-luoc-do-khoan-cua-nguoi.md`, và `15-luoc-do-khoan-chi.md` nếu `P2A-05` đã `Done`.
- *Đoạn lượt admin thêm vào file có sẵn:* câu `I-025`…`I-029` của `09-doi-chieu-bat-bien.md`; mục cổng
  của `P2A-08` trong `11-cong-chat-luong-pha-2.md`; `YC-26`…`YC-33` của
  `docs/product/1-system-design/04-yeu-cau-du-lieu.md`; `I-025`…`I-029` của `03-bao-ve-invariant.md`
  và `quality/invariants.md`; phần `P2A-01` thêm vào `docs/product/0-ba/admin/01-ranh-gioi.md`.
- *Mã:* migration của các lát admin trong `db/migrations/`, `db/reconcile/i025.sql`…`i028.sql` cùng
  lỗi cài, test của các lát trong `db/tests/`, `db/seed/seed.pl`.

**Tập con trỏ, rà hai chiều:** `master_plan/shop-facts.md` §8 (§8.4 · §8.7 · §8.8 · §8.10) ·
`work/backlog_AD.md` · `docs/product/1-system-design/architecture.md` §14 ·
`docs/product/0-ba/admin/01-ranh-gioi.md` · hàng *Schema* của `CLAUDE.md` §2 ·
`docs/product/00-index.md` · danh sách file ở kế hoạch §4. Chiều đi: chỗ cũ trỏ sang lát thì đích
còn nói đúng cái được gán. Chiều về: lát trỏ về `YC` · `I-0xx` · mục `§` thì đích còn đúng.

**Lượt lọc §6 — `P2-14` không có lượt này.** Mỗi phần ở kế hoạch §6 một nhóm từ: lương · kỳ trả ·
đơn giá công; nợ nhà cung cấp; kiểm đếm cuối buổi; lãi · lỗ · giá vốn; tiền mang về nhà; nộp tiền;
thuế; quyền xem; giảm giá cả đơn · combo. Mỗi dòng trúng xếp vào một trong ba loại: *khai không
dựng* (bảng ngoài phạm vi của lát), *trỏ tới chỗ chặn*, hay *cất* — một bảng, cột, ràng buộc hay dòng
mồi giữ thứ ấy ⇒ vi phạm. Phần mã đọc thêm bằng mắt: tên bảng và cột của migration không lọc từ
tiếng Việt được (ô 7 đòi *cộng một lượt đọc bằng mắt*).

**Luật xếp một dòng nói về *quyền*** — cách đọc của phiên T-130 (Claude Code, 2026-10-01), theo cách
`P2-14` đã xếp dòng giao việc; chủ repo đổi được (`CLAUDE.md` §7.2):
1. Quyền của **vai database** — `GRANT` · `REVOKE`, vai `shop_app`, `QD-50` · `QD-52` — là pha 2, hợp lệ.
2. Câu **giao việc** cho pha 3 mà không nói ai được gì — *"cửa ghi pha 3 xét"*, *"chưa quyết quyền —
   pha 3"* — hợp lệ, cùng loại `P2-14` đã xếp cho các câu giao việc của `09-doi-chieu-bat-bien.md`.
3. Câu **trích** một mệnh đề hay dòng `YC` đã có owner (*`I-027` — người tick là chủ quán*) là trích,
   hợp lệ.
4. Câu nói **vai nghiệp vụ nào** — chủ quán, người đứng quầy, nhân viên — được xem, ghi hay duyệt gì
   qua ứng dụng, kể cả chép lại `C34` · `C35`, là viết hộ hàng *Hợp đồng API … quyền theo vai* của
   `CLAUDE.md` §2 ⇒ vi phạm.
5. Không xếp được vào bốn loại trên ⇒ hỏi chủ repo. Codex không tự xếp (**ADR-054**).

**Lát vắng.** Lát chưa `Done` lúc nhận việc ghi ở ô 7 · 8 là *vắng, rà lại khi lát xong* — không ghi
*đạt*. Lát ấy mang việc rà về entry của chính nó (`P2A-05`, bẫy cuối).

**Bẫy hay sửa nhầm nhất:**
- **In cả lệnh chưa lọc cạnh lệnh đã lọc** (**F-017**), và cài một dòng vi phạm vào **bản sao** cho
  từng lượt — kể cả lượt §6 — để chứng minh nó biết kêu.
- **Quyền xem là chỗ dễ lọt nhất**: `C34` · `C35` là lời chủ quán, nhưng thi hành chúng là pha 3.
- **Đừng sửa chỗ sai ngay trong lượt rà** — ghi `F-XXX` (luật của `P2-14`); không sửa Gate 1d trong
  lượt này (**F-049** có đường ra riêng). Ngoại lệ như `P2-14`: con trỏ lệch là bug của lượt, sửa ở
  file mang nó và nói ở *Bàn giao*.
- **Khối *Nhận việc* chưa có** (luật 2 của file): nó điền khi `P2A-08` đã `Done`, từ phần trên.

**Nhận việc** — điền 2026-10-01 (Claude Code), `P2A-08` đã `Done` cùng ngày (`7b5e3f6`); mức **L1**. Thi
công: Codex; xếp dòng loại 5 của *luật xếp dòng quyền*, sửa con trỏ và ký ô: Claude.
- *Phạm vi Codex:* chỉ `docs/product/2-db/11-cong-chat-luong-pha-2.md` (mục §9.6 mới và hai hàng ô 7 · 8
  của §9.4, ghi *chờ Claude ký*); bản sao để cài dòng thử đặt **ngoài** repo. Con trỏ lệch, dòng vi phạm,
  dòng *quyền* loại 5: **báo**, không sửa.
- *Nghiệm thu:*
  1. **Tập đếm lại** bằng `git log --name-only` của các commit mang subject `P2A-01:` … `P2A-08:`, bỏ file
     trong `work/` (sổ việc, không phải lát); in tập đếm được cạnh danh sách ở trên, tập đếm được thắng.
     `P2A-05` chưa `Done` ⇒ ghi *vắng, rà lại khi lát ấy xong*.
  2. **Chín lệnh A1…D của `P2-14`** (`work/backlog_DB.md` → P2-14 *Bàn giao*, chạy bằng `bash`, glob, không
     biến danh sách) trên các file tài liệu của tập — với file có sẵn chỉ tính đoạn admin thêm vào (in số
     dòng của đoạn). Mỗi lượt dán *chưa lọc · đã lọc*, và mỗi dòng còn lại được xếp loại bằng tên.
  3. **Lượt §6** — mỗi phần của kế hoạch §6 một nhóm từ (danh sách ở trên); mỗi dòng trúng xếp *khai không
     dựng* · *trỏ tới chỗ chặn* · *cất* (vi phạm). Dòng nói về quyền xếp theo luật bốn loại ở trên; không
     xếp được ⇒ loại 5, ghi ra cho Claude.
  4. **Phần mã** (migration admin, `db/reconcile/i025.sql`…`i028.sql` và lỗi cài, test admin, `db/seed/seed.pl`)
     qua A1…D và lượt §6; cộng một **bảng tên bảng · cột** của ba migration admin, mỗi tên một dòng xếp loại
     (*đọc bằng mắt* của ô 7).
  5. **Mỗi lượt biết kêu**: một dòng vi phạm cài vào bản sao của tập ⇒ lượt ấy trả đúng dòng cài.
  6. **Con trỏ hai chiều** trên tập con trỏ ở trên: số chỗ đã mở và danh sách chỗ lệch (file:dòng, trỏ gì,
     đích nói gì).
  7. `./scripts/gate.sh` xanh; `git diff` không đổi một dòng nghiệp vụ, lược đồ hay migration nào.

**Bàn giao** — 2026-10-01 · thực hiện: **Codex** (worktree `../lean_wt/P2A-09`, nhánh `codex/P2A-09`, trên
`481d1ab`) · duyệt, xếp loại 5, sửa con trỏ và ký: **Claude Code**. Codex làm đủ bảy dòng *Nhận việc*,
gate của nó xanh (*Gate 1d PASS*, chỉ tài liệu đổi). Claude đọc diff thật: §9.6 bản Codex dài 451 dòng
trong chính file cổng — trái tiền lệ ô 9 của `P2-14` — nên Claude rút §9.6 về một bảng gọn và đặt phần đo
nguyên văn dưới đây. Hai dòng loại 5 xếp loại 3 + 2 (lý do ở §9.6). Bảy con trỏ lệch sửa ở file mang chúng,
scope mở thêm đúng sáu file: `13-luoc-do-cham-cong.md` · `14-luoc-do-khoan-cua-nguoi.md` · `00-index.md` ·
`architecture.md` · `work/backlog_AD.md` (và `work/backlog_archive.md` không đổi). Ô 7 · 8 của §9.4 ký;
`P2A-05` vắng — nó mang việc rà về entry của mình. Chưa review độc lập.

*Phần đo của Codex, nguyên văn* (số dòng là của ảnh `481d1ab`; mục *Bảy chỗ dẫn lệch* ghi *không sửa
nguồn* là lời của lượt đo — Claude đã sửa cả bảy sau đó):

**Tập đếm lại, trước khi viết biên bản.** Chạy từ gốc repo:

```bash
git log --format='%h %s' --grep='^P2A-0[1-8]:'
git log --format= --name-only --grep='^P2A-0[1-8]:' | sed '/^$/d; /^work\//d' | sort -u
```

Output: **8 commit, 54 file ngoài work/**; có hai commit mang P2A-07, không có P2A-05.
Các commit: `45432a3`, `a1aa9ca`, `7fe884b`, `c93f069`, `719a430`, `b1a148c`, `66789d6`,
`7b5e3f6`. Tập đếm được thắng danh sách dự kiến ở entry:

| Danh sách dự kiến | Tập thực tế |
|---|---|
| Ba file lát 12, 13, 14 | Đủ cả ba; file 15 vắng |
| Các đoạn admin của file 09, 11, hai owner pha 1, invariant và ranh giới BA | Đủ; lấy bản hiện hành của cả mục admin, kể cả lời sửa sau commit P2A |
| Migration, đối chiếu 025–028, lỗi cài, test admin, bộ mồi | Đủ; mã được rà toàn file để không bỏ phần dùng chung |
| Không liệt kê trước | Thêm CLAUDE, decisions, index, unknowns, kế hoạch admin, file 01/07/08/10; i021, prelude, baseline, lỗi i021_3/i021_7, ba file scenario và db-check — tất cả có trong bảng dưới |

Với tài liệu có sẵn, lấy các dòng còn sống từ commit P2A bằng `git blame --line-porcelain`,
và mở rộng đủ mục admin hiện hành ở BA, hai owner pha 1, invariant và cổng. Ba file lát mới lấy
nguyên file. Bảng dưới là **số dòng gốc tại 481d1ab**, không phải số dòng của bản sao đã ghép.
Biên bản §9.6 và hai hàng ô 7 · 8 mới không tự tham gia tập đo của chính chúng.

<!-- P2A09-MANIFEST -->
| Tập | File | Dòng gốc đã lấy |
|---|---|---|
| docs | `CLAUDE.md` | 61 |
| code | `db/migrations/20260930100000_so_nguyen_lieu.down.sql` | 1-23 |
| code | `db/migrations/20260930100000_so_nguyen_lieu.up.sql` | 1-39 |
| code | `db/migrations/20260930110000_cham_cong.down.sql` | 1-21 |
| code | `db/migrations/20260930110000_cham_cong.up.sql` | 1-40 |
| code | `db/migrations/20260930120000_khoan_cua_nguoi.down.sql` | 1-23 |
| code | `db/migrations/20260930120000_khoan_cua_nguoi.up.sql` | 1-44 |
| code | `db/reconcile/i021.sql` | 1-25 |
| code | `db/reconcile/i025.sql` | 1-12 |
| code | `db/reconcile/i026.sql` | 1-17 |
| code | `db/reconcile/i027.sql` | 1-27 |
| code | `db/reconcile/i028.sql` | 1-36 |
| code | `db/reconcile/prelude.sql` | 1-86 |
| code | `db/reconcile/proof/baseline.sql` | 1-344 |
| code | `db/reconcile/proof/i021_3.sql` | 1-7 |
| code | `db/reconcile/proof/i021_7.sql` | 1-5 |
| code | `db/reconcile/proof/i025_1.sql` | 1-4 |
| code | `db/reconcile/proof/i025_2.sql` | 1-10 |
| code | `db/reconcile/proof/i026_3.sql` | 1-6 |
| code | `db/reconcile/proof/i026_4.sql` | 1-5 |
| code | `db/reconcile/proof/i027_1.sql` | 1-4 |
| code | `db/reconcile/proof/i027_2.sql` | 1-6 |
| code | `db/reconcile/proof/i027_3.sql` | 1-5 |
| code | `db/reconcile/proof/i027_4.sql` | 1-4 |
| code | `db/reconcile/proof/i028_1.sql` | 1-6 |
| code | `db/reconcile/proof/i028_2.sql` | 1-4 |
| code | `db/reconcile/proof/i028_3.sql` | 1-3 |
| code | `db/reconcile/proof/i028_4.sql` | 1-5 |
| code | `db/scenario/doc_lai.sql` | 1-282 |
| code | `db/scenario/s4_ngay_quan_tri.sql` | 1-120 |
| code | `db/scenario/yc.sql` | 1-854 |
| code | `db/seed/seed.pl` | 1-430 |
| code | `db/tests/i025_supply_numbers_entered_by_a_person.sql` | 1-217 |
| code | `db/tests/i026_supply_totals_from_day_entries.sql` | 1-89 |
| code | `db/tests/i027_attendance_one_box_per_worker_day.sql` | 1-217 |
| code | `db/tests/i028_advance_and_bonus_name_a_worker.sql` | 1-354 |
| docs | `docs/decisions.md` | 88-92,4529-4913 |
| docs | `docs/product/0-ba/admin/01-ranh-gioi.md` | 89-129 |
| docs | `docs/product/00-index.md` | 63-64,94-98 |
| docs | `docs/product/1-system-design/03-bao-ve-invariant.md` | 3,18-20,380-435 |
| docs | `docs/product/1-system-design/04-yeu-cau-du-lieu.md` | 13,40-41,212,237,281-314 |
| docs | `docs/product/2-db/01-quy-uoc-du-lieu.md` | 140,597 |
| docs | `docs/product/2-db/07-thu-tu-migration.md` | 37-39,42-43,119-122 |
| docs | `docs/product/2-db/08-du-lieu-moi.md` | 1,3-4,8-9,15-16,19-20,56,70,91,101-104,114-118,127 |
| docs | `docs/product/2-db/09-doi-chieu-bat-bien.md` | 50-51,75,79-82,86-89,128-131,133-136,149,161-163,165-167,189,195,209-220,233 |
| docs | `docs/product/2-db/10-quy-uoc-code.md` | 137,139,151,153,160-161 |
| docs | `docs/product/2-db/11-cong-chat-luong-pha-2.md` | 345,349-452 |
| docs | `docs/product/2-db/12-luoc-do-nguyen-lieu.md` | 1-133 |
| docs | `docs/product/2-db/13-luoc-do-cham-cong.md` | 1-126 |
| docs | `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md` | 1-115 |
| docs | `docs/product/99-unknowns.md` | 82-85,238-269 |
| docs | `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md` | 45-53,178,185-186 |
| docs | `quality/invariants.md` | 1129-1386 |
| code | `scripts/db-check.sh` | 1-494 |
<!-- /P2A09-MANIFEST -->

**Lệnh tái lập.** Chạy khối sau bằng `bash` từ gốc repo. Nó dựng ảnh đo và mọi dòng thử trong
`mktemp -d` ngoài repo, không đổi nguồn. Chín mẫu lấy **nguyên văn** từ khối Bàn giao P2-14
ở ảnh gốc; D gồm hai câu grep. Lệnh chưa lọc in cạnh lệnh lọc trong từng script sinh ra:
`set -- "$1"/*` rồi `cat "$@" | wc -l`. Không dùng biến chứa danh sách file.
Bảng nhóm S6 bên dưới giữ mẫu riêng cho từng phần, rồi hợp các mẫu thành một lượt.

```bash
p2a09_tmp=$(mktemp -d)
python3 - "$p2a09_tmp" <<'PY_REPLAY'
import base64, json, pathlib, re, shutil, subprocess, sys
out = pathlib.Path(sys.argv[1])
base = '481d1ab'
def source(f):
    return subprocess.check_output(['git', 'show', base + ':' + f], text=True)
doc = pathlib.Path('docs/product/2-db/11-cong-chat-luong-pha-2.md').read_text()
manifest = doc.split('<!-- P2A09-MANIFEST -->')[1].split('<!-- /P2A09-MANIFEST -->')[0]
line_map = {}
for group, f, spans in re.findall(r'^\| (docs|code) \| `([^`]+)` \| ([0-9,-]+) \|$', manifest, re.M):
    lines = source(f).splitlines()
    nums = []
    for span in spans.split(','):
        ends = list(map(int, span.split('-')))
        nums.extend(range(ends[0], ends[-1] + 1))
    dest = out / group / f.replace('/', '__')
    dest.parent.mkdir(exist_ok=True)
    dest.write_text(''.join(lines[n-1] + '\n' for n in nums))
    line_map[str(dest)] = (f, nums)
text = source('work/backlog_DB.md').split('### P2-14')[1]
block = text.split('```bash')[1].split('```')[0]
commands = dict(re.findall(r'^# (A[123]|B[123]|C[12]|D) —[^\n]*\n(.*?)(?=^# |\Z)', block, re.M | re.S))

patterns = ['lương|kỳ trả|đơn giá công', 'nợ nhà cung cấp', 'kiểm đếm', 'lãi|\\blỗ\\b|giá vốn', 'mang về nhà', 'nộp tiền', 'thuế', 'quyền|được xem|ai xem|C34|C35|F55', 'giảm giá.*(cả đơn|toàn đơn)|combo|món mới']
commands['S6'] = "grep -nEi '" + '|'.join(patterns) + "' \"$@\"\n"
for name, command in commands.items():
    pre = 'set -- "$1"/*\necho "TẬP: $# file · $(cat "$@" | wc -l) dòng chưa lọc"\n'
    (out / (name + '.sh')).write_text(pre + command)
for group in ['docs', 'code']:
    for name in commands:
        run = subprocess.run(['bash', str(out / (name + '.sh')), str(out / group)], capture_output=True, text=True)
        assert run.returncode in [0, 1] and not run.stderr, run.stderr
        print(group, name, run.stdout.splitlines()[0])
        hits = run.stdout.splitlines()[1:]
        print('đã lọc:', len(hits))
        for hit in hits:
            f, n, text = hit.split(':', 2)
            original, nums = line_map[f]
            print(original + ':' + str(nums[int(n)-1]) + ':' + text)

fixtures = json.loads(base64.b64decode('eyJBMSI6ICJQT1NUIC9wMmEwOS9wcm9iZSIsICJBMiI6ICJHRVQgcDJhMDlfcHJvYmUiLCAiQTMiOiAiZW5kcG9pbnQgcDJhMDlfcHJvYmUiLCAiQjEiOiAiUDJhMDlQcm9iZS50c3giLCAiQjIiOiAiYC9wMmEwOS9wcm9iZWAiLCAiQjMiOiAiY29tcG9uZW50IHAyYTA5X3Byb2JlIiwgIkMxIjogIjxQMmEwOVByb2JlIHZhbHVlPVwieFwiIC8+IiwgIkMyIjogImBQMmFQcm9iZWAiLCAiRCI6ICJgcHJvYmVDYWxsYCBgcHJvYmVfY2FsbCgpYCIsICJTNiI6ICJD4buZdCBj4bqldCBsxrDGoW5nIHbDoCBr4buzIHRy4bqjLCDEkcahbiBnacOhIGPDtG5nLCBu4bujIG5ow6AgY3VuZyBj4bqlcCwga2nhu4NtIMSR4bq/bSBjdeG7kWkgYnXhu5VpLCBsw6NpIGzhu5cgZ2nDoSB24buRbiwgdGnhu4FuIG1hbmcgduG7gSBuaMOgLCBu4buZcCB0aeG7gW4sIHRodeG6vywgcXV54buBbiB4ZW0sIGdp4bqjbSBnacOhIGPhuqMgxJHGoW4gdsOgIGNvbWJvLCBtw7NuIG3hu5tpLiJ9'))
for group in ['docs', 'code']:
    for name, line in fixtures.items():
        trial = out / 'trial'
        shutil.rmtree(trial, ignore_errors=True)
        shutil.copytree(out / group, trial)
        probe = trial / 'zz_probe'
        probe.write_text(line + '\n')
        run = subprocess.run(['bash', str(out / (name + '.sh')), str(trial)], capture_output=True, text=True)
        hits = [s.split(':1:', 1)[1] for s in run.stdout.splitlines() if str(probe) + ':1:' in s]
        expected = [line] if name != 'D' else [line, line.split(' ', 1)[1]]
        assert hits == expected, (group, name, hits)
        print('PASS', group, name, 'dòng cài khớp nguyên văn', len(hits))
# Chấm riêng từng nhóm S6: cùng dòng cài phải qua cả chín nhóm.
for i, pattern in enumerate(patterns, 1):
    run = subprocess.run(['grep', '-nEi', pattern, str(probe)], capture_output=True, text=True)
    assert run.stdout.rstrip() == '1:' + fixtures['S6']
    print('PASS S6.' + str(i), 'dòng cài')
PY_REPLAY
```

Chuỗi base64 chỉ chứa các **dòng vi phạm mẫu**, để không đặt chính mẫu endpoint/thẻ giao diện
vào vùng pha 2 đang được Gate 1d đo. Lệnh giải mã và đối chiếu nguyên văn ở trên là phép thử,
không phải ngoại lệ của cổng. Bản sao vẫn chứa nội dung thật sau giải mã.

**Output lọc trên tập thật.** Mỗi ô đã lọc là số dòng grep, chưa loại bằng nhận định của người;
D ghi riêng hai câu. Phân loại từng dòng còn lại ngay sau bảng.

| Lượt | Bắt gì | Chưa lọc (tài liệu / mã) | Đã lọc (tài liệu / mã) |
|---|---|---|---|
| A1 | endpoint, mẫu vùng pha 2 của P2-14 | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 |
| A2 | động từ + chữ, mẫu rộng vùng pha 1 | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 5 |
| A3 | từ vựng hợp đồng API | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 12 |
| B1 | route và file giao diện, mẫu P2-14 | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 |
| B2 | đường dẫn trong backtick | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 |
| B3 | từ vựng pha 4 | 18 file · 1403 dòng / 36 file · 3868 dòng | 1 / 15 |
| C1 | thẻ kể cả thuộc tính và thẻ đóng | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 |
| C2 | tên PascalCase trong backtick | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 |
| D | tên hàm ứng dụng / hàm có ngoặc | 18 file · 1403 dòng / 36 file · 3868 dòng | (0 · 5) / (0 · 0) |
| S6 | hợp chín nhóm từ của phần bị chặn | 18 file · 1403 dòng / 36 file · 3868 dòng | 38 / 11 |

| Nhóm §6 | Mẫu grep -nEi (chạy trên cùng tập, số chưa lọc như trên) | Đã lọc tài liệu / mã | Dòng thử |
|---|---|---|---|
| S6.1 | `lương&#124;kỳ trả&#124;đơn giá công` | 19 / 1 | PASS |
| S6.2 | `nợ nhà cung cấp` | 1 / 0 | PASS |
| S6.3 | `kiểm đếm` | 1 / 0 | PASS |
| S6.4 | `lãi&#124;\blỗ\b&#124;giá vốn` | 5 / 0 | PASS |
| S6.5 | `mang về nhà` | 1 / 0 | PASS |
| S6.6 | `nộp tiền` | 0 / 0 | PASS |
| S6.7 | `thuế` | 1 / 0 | PASS |
| S6.8 | `quyền&#124;được xem&#124;ai xem&#124;C34&#124;C35&#124;F55` | 12 / 5 | PASS |
| S6.9 | `giảm giá.*(cả đơn&#124;toàn đơn)&#124;combo&#124;món mới` | 1 / 5 | PASS |

S6.1 lương/kỳ trả/đơn giá; S6.2 nợ nhà cung cấp; S6.3 kiểm đếm; S6.4 lãi/lỗ/giá vốn;
S6.5 tiền mang về nhà; S6.6 nộp tiền; S6.7 thuế; S6.8 quyền xem; S6.9 giảm giá cả đơn/combo/món mới.
Tổng nhóm có thể lớn hơn hợp vì một dòng trúng nhiều nhóm. Mẫu lỗ có biên từ để không bắt chữ lỗi.
Lượt rộng đầu tiên bắt cả chữ lỗi; đã đọc và sửa mẫu rồi chạy lại, không dùng số của lượt ấy.

**Phân loại A1…D.** Các lượt không liệt kê dưới đây không trả dòng nào.

| Lượt · tập | File:dòng gốc | Xếp bằng tên |
|---|---|---|
| B3 · docs | `docs/product/1-system-design/04-yeu-cau-du-lieu.md`:310 | Giao việc cho pha 4; nhắc mốc nghiệp vụ YC-28, không đặt route/component hay màn cụ thể |
| D · docs | `docs/decisions.md`:4711 | Kiểu numeric hoặc hàm database; không phải hàm ứng dụng |
| D · docs | `docs/product/2-db/10-quy-uoc-code.md`:137 | Kiểu numeric hoặc hàm database; không phải hàm ứng dụng |
| D · docs | `docs/product/2-db/12-luoc-do-nguyen-lieu.md`:51, 70 | Kiểu numeric hoặc hàm database; không phải hàm ứng dụng |
| D · docs | `docs/product/2-db/13-luoc-do-cham-cong.md`:43 | Kiểu numeric hoặc hàm database; không phải hàm ứng dụng |
| A2 · code | `db/tests/i025_supply_numbers_entered_by_a_person.sql`:146, 153 | Lệnh xoá SQL trong phép thử quyền database (loại quyền 1) |
| A2 · code | `db/tests/i027_attendance_one_box_per_worker_day.sql`:176 | Lệnh xoá SQL trong phép thử quyền database (loại quyền 1) |
| A2 · code | `db/tests/i028_advance_and_bonus_name_a_worker.sql`:279, 286 | Lệnh xoá SQL trong phép thử quyền database (loại quyền 1) |
| A3 · code | `db/seed/seed.pl`:105, 107, 110, 111, 217, 218 | Biến cục bộ rest của Perl |
| A3 · code | `scripts/db-check.sh`:189, 190, 191, 196, 199, 207 | Biến body của bộ đọc khối kiểm; không phải nội dung HTTP |
| B3 · code | `db/reconcile/proof/baseline.sql`:75, 78, 94, 234, 236 | Tên cột thành phần món trong SQL bán hàng; không phải component giao diện |
| B3 · code | `db/scenario/doc_lai.sql`:75, 81, 83 | Tên cột thành phần món trong SQL bán hàng; không phải component giao diện |
| B3 · code | `db/scenario/yc.sql`:363, 366, 372, 384, 387, 424, 428 | Tên cột thành phần món trong SQL bán hàng; không phải component giao diện |

**Phân loại S6.** Ba nhãn của phép rà là *khai không dựng*, *trỏ tới chỗ chặn*, *cất*.
Dòng nói quyền tách theo luật riêng; từ trúng nhưng chỉ là mã bán hàng có sẵn được ghi rõ,
không gán nó thành một chỗ admin cất combo mới. Không có dòng *cất* thuộc phần admin bị chặn.

| Tập · file:dòng gốc | Xếp loại · lý do |
|---|---|
| docs · `docs/decisions.md`:4769 | Khai không dựng — không đơn giá công |
| docs · `docs/decisions.md`:4785 | Quyền loại 1 — lựa chọn cấp/thu quyền vai database |
| docs · `docs/decisions.md`:4801 | Quyền loại 1 — lựa chọn cấp/thu quyền vai database |
| docs · `docs/decisions.md`:4869 | Trỏ tới chỗ chặn — lương sau này/chờ lời |
| docs · `docs/decisions.md`:4898 | Quyền loại 1 — lựa chọn cấp/thu quyền vai database |
| docs · `docs/decisions.md`:4900 | Trỏ tới chỗ chặn — lương sau này/chờ lời |
| docs · `docs/product/0-ba/admin/01-ranh-gioi.md`:116 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `docs/product/0-ba/admin/01-ranh-gioi.md`:117 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `docs/product/0-ba/admin/01-ranh-gioi.md`:118 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `docs/product/0-ba/admin/01-ranh-gioi.md`:121 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `docs/product/0-ba/admin/01-ranh-gioi.md`:122 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `docs/product/1-system-design/03-bao-ve-invariant.md`:396 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `docs/product/1-system-design/04-yeu-cau-du-lieu.md`:299 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `docs/product/2-db/11-cong-chat-luong-pha-2.md`:374 | Quyền loại 3 — kịch bản YC-30, không suy quyền huỷ độc quyền |
| docs · `docs/product/2-db/12-luoc-do-nguyen-lieu.md`:19 | Quyền loại 2 — giao pha 3, chưa nói vai nào được gì |
| docs · `docs/product/2-db/12-luoc-do-nguyen-lieu.md`:117 | Quyền loại 2 — giao pha 3, chưa nói vai nào được gì |
| docs · `docs/product/2-db/12-luoc-do-nguyen-lieu.md`:118 | Khai không dựng — không kiểm đếm, nợ nhà cung cấp, giá vốn; trỏ kế hoạch §6 |
| docs · `docs/product/2-db/12-luoc-do-nguyen-lieu.md`:133 | Quyền loại 2 — giao pha 3, chưa nói vai nào được gì |
| docs · `docs/product/2-db/13-luoc-do-cham-cong.md`:73 | Quyền loại 1 — vai ghi database |
| docs · `docs/product/2-db/13-luoc-do-cham-cong.md`:91 | Quyền loại 1 — vai ghi database |
| docs · `docs/product/2-db/13-luoc-do-cham-cong.md`:111 | Trỏ tới chỗ chặn — C26/C33; không cất lương |
| docs · `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md`:66 | Quyền loại 1 — vai ghi database |
| docs · `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md`:78 | Quyền loại 1 — vai ghi database |
| docs · `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md`:99 | Trỏ tới chỗ chặn — C26/C33; không cất lương |
| docs · `docs/product/99-unknowns.md`:83 | Trỏ tới chỗ chặn — U-058 còn mở, lời hỏi không phải chỗ cất |
| docs · `quality/invariants.md`:1148 | Quyền loại 2 — mệnh đề không quyết ai được nhập |
| docs · `quality/invariants.md`:1251 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1259 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1306 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1312 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1331 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `quality/invariants.md`:1334 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `quality/invariants.md`:1342 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `quality/invariants.md`:1357 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1361 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| docs · `quality/invariants.md`:1367 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1369 | Trỏ tới chỗ chặn — lời chưa có/đầu vào cho phần sau, không dựng phép tính |
| docs · `quality/invariants.md`:1380 | Khai không dựng — lương đứng ngoài khoản chi; yêu cầu/giới hạn, không có bảng hay cột lương |
| code · `db/migrations/20260930110000_cham_cong.up.sql`:38 | Quyền loại 1 — quyền database, không chọn vai nghiệp vụ |
| code · `db/migrations/20260930120000_khoan_cua_nguoi.up.sql`:40 | Quyền loại 1 — quyền database, không chọn vai nghiệp vụ |
| code · `db/migrations/20260930120000_khoan_cua_nguoi.up.sql`:41 | Quyền loại 1 — quyền database, không chọn vai nghiệp vụ |
| code · `db/scenario/doc_lai.sql`:188 | Ngoài phần admin — combo bán hàng đã có, không cất combo mới của §6 |
| code · `db/scenario/yc.sql`:322 | Khai không dựng — ca YC-04 kiểm không cất quyền theo chức vụ cố định |
| code · `db/scenario/yc.sql`:521 | Ngoài phần admin — combo bán hàng đã có, không cất combo mới của §6 |
| code · `db/seed/seed.pl`:28 | Ngoài phần admin — combo bán hàng đã có, không cất combo mới của §6 |
| code · `db/seed/seed.pl`:29 | Ngoài phần admin — combo bán hàng đã có, không cất combo mới của §6 |
| code · `db/seed/seed.pl`:30 | Ngoài phần admin — combo bán hàng đã có, không cất combo mới của §6 |
| code · `db/tests/i028_advance_and_bonus_name_a_worker.sql`:313 | Khai không dựng — test so danh sách cột, không tạo cột lương |
| code · `scripts/db-check.sh`:104 | Quyền loại 1 — quyền database, không chọn vai nghiệp vụ |

**Đọc thêm dòng quyền, không chỉ tìm chữ quyền.** Dùng `rg -n 'chủ quán|người tick|người duyệt|được xem|C34|C35|shop_app|GRANT|REVOKE'`
trên ba file lát và mã tương ứng, rồi mở cả đoạn. Quyền loại 1 gồm hai migration có GRANT/REVOKE
và các phép thử dưới shop_app. Quyền loại 2 gồm file 12:19,117,133; file 13:19,126;
file 14:19,115 — chỉ giao việc. Quyền loại 3 gồm file 13:70 (`I-027`) và file 14:62
(`I-028`/`YC-31`), các câu đối chiếu i027:24–27, i028:24–27 và kịch bản mồi/test của đúng
mệnh đề ấy. BA và owner pha 1/invariant được đọc như nguồn nghiệp vụ, không phải hợp đồng ứng dụng.
Không thấy dòng chép C34/C35 vào lát để cấp quyền xem qua ứng dụng; **chưa kết luận sạch quyền**,
vì hai đoạn sau chạm ranh giới giữa loại 3 và loại 4. Giữ **loại 5, chờ Claude**, không tự chọn:

`docs/product/2-db/13-luoc-do-cham-cong.md:80` (nguyên văn đoạn 80–81):

```text
  cửa ghi phải khai đúng người thao tác và xét người ấy. Sửa tay bỏ qua cửa ghi là giới hạn đã biết.
- **Không ô nào sinh khoản trừ** là tầng 3, kiểm bằng đọc lược đồ như bảng §2. Lát không dựng
```

`docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md:72` (nguyên văn đoạn 72–73):

```text
- **Người duyệt là chủ quán** là tầng 3, database không xét. Cửa ghi pha 3 phải xét người duyệt
  và khai đúng người thao tác. Sửa tay bỏ qua cửa ghi là giới hạn đã biết.
```

Lý do để loại 5: cả hai vừa nhắc nội dung đã có ở I-027/I-028, vừa đặt nghĩa vụ xét một vai cụ thể
cho cửa ghi pha 3; trong chính đoạn không ghi mã trích. Claude quyết đó là dẫn mệnh đề theo loại 3
hay viết hộ quyền theo loại 4. Không thay hai đoạn trong lượt này.

**Đọc bằng mắt tên bảng · cột.** Lệnh lấy tên: mở ba file xuôi `db/migrations/20260930*.up.sql`,
đọc từng khai báo bảng và từng dòng có kiểu bigint/text/numeric/date/timestamptz; không lấy tên từ
bản mô tả. Output: **5 bảng, 32 cột, 37 tên**. Mỗi tên dưới đây một dòng, toàn bộ là chỗ cất đã được
giao, không có lương/kỳ trả, công nợ nhà cung cấp, kiểm đếm, giá vốn, thuế hay quyền xem ứng dụng.

| Tên bảng · cột | Xếp loại khi đọc bằng mắt |
|---|---|
| `supply_item` | Hợp lệ pha 2 — Danh mục YC-26 |
| `supply_item.id` | Hợp lệ pha 2 — Khoá dòng |
| `supply_item.name` | Hợp lệ pha 2 — Tên thứ mua vào |
| `supply_item.purchase_unit` | Hợp lệ pha 2 — Đơn vị mua, trống được |
| `supply_item.created_at` | Hợp lệ pha 2 — Lúc ghi |
| `supply_day_entry` | Hợp lệ pha 2 — Con số ngày YC-27/28; không tổng, ngưỡng hay lô |
| `supply_day_entry.id` | Hợp lệ pha 2 — Khoá dòng |
| `supply_day_entry.supply_item_id` | Hợp lệ pha 2 — Thứ trong danh mục |
| `supply_day_entry.entry_date` | Hợp lệ pha 2 — Ngày con số |
| `supply_day_entry.kind_code` | Hợp lệ pha 2 — Loại mua vào/đã dùng |
| `supply_day_entry.entered_measure` | Hợp lệ pha 2 — Con số người gõ |
| `supply_day_entry.person_id` | Hợp lệ pha 2 — Người ghi/tick, không cấp quyền ứng dụng |
| `supply_day_entry.created_at` | Hợp lệ pha 2 — Lúc ghi |
| `attendance_day` | Hợp lệ pha 2 — Ô ngày YC-30; không giờ tới/về, đơn giá hay khoản trừ |
| `attendance_day.id` | Hợp lệ pha 2 — Khoá dòng |
| `attendance_day.worker_person_id` | Hợp lệ pha 2 — Người được chấm/nhận khoản |
| `attendance_day.work_date` | Hợp lệ pha 2 — Ngày của ô |
| `attendance_day.person_id` | Hợp lệ pha 2 — Người ghi/tick, không cấp quyền ứng dụng |
| `attendance_day.created_at` | Hợp lệ pha 2 — Lúc ghi |
| `attendance_day.cancelled_at` | Hợp lệ pha 2 — Lúc huỷ |
| `attendance_day.cancelled_by_person_id` | Hợp lệ pha 2 — Người huỷ, không quyết quyền huỷ |
| `attendance_day.cancel_note` | Hợp lệ pha 2 — Ghi chú huỷ |
| `staff_advance` | Hợp lệ pha 2 — Khoản tạm ứng YC-31; không lương hay dấu nối két |
| `staff_advance.id` | Hợp lệ pha 2 — Khoá dòng |
| `staff_advance.worker_person_id` | Hợp lệ pha 2 — Người được chấm/nhận khoản |
| `staff_advance.amount_vnd` | Hợp lệ pha 2 — Tiền từng khoản, không phải đơn giá lương |
| `staff_advance.paid_date` | Hợp lệ pha 2 — Ngày của khoản, không phải kỳ lương |
| `staff_advance.approver_person_id` | Hợp lệ pha 2 — Người duyệt tạm ứng, theo I-028; không quyền xem |
| `staff_advance.person_id` | Hợp lệ pha 2 — Người ghi/tick, không cấp quyền ứng dụng |
| `staff_advance.created_at` | Hợp lệ pha 2 — Lúc ghi |
| `holiday_bonus` | Hợp lệ pha 2 — Khoản thưởng lễ Tết YC-32; không loại thưởng dự phòng |
| `holiday_bonus.id` | Hợp lệ pha 2 — Khoá dòng |
| `holiday_bonus.worker_person_id` | Hợp lệ pha 2 — Người được chấm/nhận khoản |
| `holiday_bonus.amount_vnd` | Hợp lệ pha 2 — Tiền từng khoản, không phải đơn giá lương |
| `holiday_bonus.paid_date` | Hợp lệ pha 2 — Ngày của khoản, không phải kỳ lương |
| `holiday_bonus.person_id` | Hợp lệ pha 2 — Người ghi/tick, không cấp quyền ứng dụng |
| `holiday_bonus.created_at` | Hợp lệ pha 2 — Lúc ghi |

Đã đọc cả ràng buộc và phần sau khai báo: khoá duy nhất, khoá về người/danh mục, dấu huỷ,
kiểm số tiền/con số, trigger vết và quyền vai database; không có đường lưu cho chín phần chặn.
Ba file lùi chỉ gỡ bảng rỗng, không tạo chỗ cất. Phần admin của seed: dòng 235–272 đọc danh mục
§8.4, phần xuất chỉ ghi tên/đơn vị; không có dữ liệu lương hay kiểm đếm. Baseline và S4 ghi con số
ngày, ô công, tạm ứng, thưởng để diễn; không tự dựng phần bị chặn. Đây là rà tĩnh, không tuyên bố
đã chạy lại database hay kiểm lại nghiệp vụ của các test.

**Dòng thử — output thật.** Mỗi lượt thêm một dòng vào một bản sao mới của cả tập rồi so nguyên văn:

| Tập bản sao | Chưa lọc | Output |
|---|---|---|
| Tài liệu | 19 file · 1404 dòng | PASS docs A1, A2, A3, B1, B2, B3, C1, C2, D, S6: dòng cài khớp nguyên văn |
| Mã | 37 file · 3869 dòng | PASS code A1, A2, A3, B1, B2, B3, C1, C2, D, S6: dòng cài khớp nguyên văn |
| Từng nhóm S6.1…S6.9 | 1 file thử · 1 dòng | PASS cả chín nhóm: cùng dòng cài được trả nguyên văn |

A1…C2 và S6 trả một kết quả của dòng cài; D trả hai (tên hàm và hàm có ngoặc). Kết quả gốc
không bị coi là dòng cài: phép so chỉ lấy đúng file zz_probe, dòng 1, rồi so toàn bộ nội dung.

**Con trỏ hai chiều.** Đã mở **10 vùng nguồn**: shop-facts §8.4, §8.7, §8.8, §8.10 (bốn);
backlog_AD; architecture §14; ranh giới BA §1.6; CLAUDE §2 hàng Schema; index; kế hoạch admin §4
(sáu). Chiều về mở **17 vùng đích**: bốn mục shop-facts trên; yêu cầu dữ liệu §9, §9.1;
I-025…I-029 (năm); bảo vệ invariant §5; đối chiếu §1, §2; lát người §0; quy ước dữ liệu §0;
kế hoạch admin §6. Đếm vùng đọc, không đếm số lần một link lặp lại.

| Chiều / nguồn | Đích đã đối chiếu | Kết quả |
|---|---|---|
| shop-facts §8.4 · §8.7 · §8.8 · §8.10 | YC-26…33, I-025…29; lát 12/13/14 và lát người | Nguồn lời còn đúng; không có link trực tiếp từ shop-facts sang ba lát mới; không bịa một link đã kiểm |
| backlog_AD | mục lời tương ứng trong shop-facts; YC-15, YC-30; lát người/chấm công | Không có link trực tiếp sang 12/13/14; hai lời giao cũ ở danh sách lệch bên dưới |
| architecture §14 | shop-facts §8.4, §8.7, §8.8; BA §1.6; YC-15 | Các mục tồn tại; lời “vẫn thiếu” ở 774 chưa chỉ sang chỗ đã dựng |
| BA §1.6, dòng 89–126 | yêu cầu dữ liệu §9, I-025…29, shop-facts §8 | Có mục và đúng nội dung; không phải hợp đồng API |
| CLAUDE:61; index:94–96 | ba file 12/13/14 | Đúng tên và đúng lát |
| index:97–101 | migration, dữ liệu mồi, đối chiếu, cổng | File tồn tại; index:98 còn mô tả người là chỗ trống. Hàng 101 chỉ giới thiệu cổng bán hàng §1–7, chưa dẫn mục admin §9; ghi giới hạn, không coi 24 YC của §5 là số sai |
| Kế hoạch §4 | ba file 12/13/14; 09/11 | Đúng; tên dự kiến của file 15 vắng có chủ đích, không báo link chết |
| Ba lát → YC/I/§ | 17 vùng đích trên | Mục/mã tồn tại; ánh xạ I-025/26 ↔ YC-26…29, I-027 ↔ YC-30, I-028 ↔ YC-31/32 đúng; I-029/YC-33 vắng lát |
| Ba lát → migration/test | ba bước xuôi/lùi và bốn test | File tồn tại; file 13:72 dẫn sai chữ của test, xem dưới |
| Lát khoản của người → task nối két | backlog T-125; I-028, YC-31/32 | Task đã viết lại mệnh đề, hai câu chờ viết còn cũ |

**Bảy chỗ dẫn lệch — nguyên văn, không sửa nguồn.** Các số dòng là của ảnh đầu vào và vẫn giữ
nguyên trong lượt này. Đây gồm lời dẫn thiếu cập nhật và một bằng chứng trích sai, không có
đường dẫn file bị mất (ngoài lát vắng đã nêu).

**Lệch 1 — `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md:79`**

```text
- **Chưa nối két**: chờ task `T-125` ở `work/backlog.md` viết lại mệnh đề và phép trừ két; lát này
  không thay việc ấy bằng một dấu nối dựng sẵn.
```

Trỏ work/backlog.md T-125 như việc chưa viết. Đích work/backlog.md:111 đã Done phần tài liệu; I-028:1299–1303 và YC-31/32:297–298 đã có vế két. Thiết kế còn chờ duyệt, luật ngày bán còn chờ U-072, không phải còn chờ viết mệnh đề.

**Lệch 2 — `docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md:96`**

```text
| Nối khoản vào két | không đường nối; mệnh đề chưa viết lại theo lời đóng câu hỏi nguồn tiền | task `T-125` ở `work/backlog.md`, trước migration nối két |
```

Cùng con trỏ T-125; “mệnh đề chưa viết lại” trái với I-028 và YC-31/32 hiện hành. Không suy từ đó rằng migration đã nối két.

**Lệch 3 — `docs/product/2-db/13-luoc-do-cham-cong.md:72`**

```text
| **`I-027` · `YC-30`** — không ô nào sinh khoản trừ | 3 | không chỗ cất khoản trừ, không đường nối tới khoản trừ; kiểm bằng đọc lược đồ, không phải điều kiện kiểm trên từng ô | test I-027 — *đọc lược đồ — 0 khoá ngoại ngoài hai khoá về người, 0 hàm nhắc tới ô, 0 trigger ngoài trigger vết* |
```

Trỏ bằng chứng test I-027 nhưng db/tests/i027_attendance_one_box_per_worker_day.sql:215 in “ngoài ba khoá về người”; migration có cả khoá người huỷ, không phải hai.

**Lệch 4 — `docs/product/00-index.md:98`**

```text
| Dữ liệu mồi — menu thật, bàn và mã QR, trạm của thành phần, danh mục hàng mua vào (P2A-06): sinh lúc chạy từ `master_plan/shop-facts.md` bởi `db/seed/seed.pl`, không cất con giá nào; các ca giá bắt buộc tính lại từ database; *người* là chỗ trống chờ `P2-08` (P2-10) | [2-db/08-du-lieu-moi.md](2-db/08-du-lieu-moi.md) |
```

Đích 08-du-lieu-moi.md:126 ghi người đã dựng ở P2-08; 06-luoc-do-nguoi-va-vet.md §1 có bảng người. Cụm “chỗ trống chờ P2-08” đã cũ.

**Lệch 5 — `docs/product/1-system-design/architecture.md:774`**

```text
| **§8**, hàng *Ai đang trực trạm nào* | ❌ **không mất hàng nào** | vẫn thiếu: lời chốt là **luật ghi**, chỗ cất vẫn là pha 2 (**ADR-035**) |
```

Lời dẫn hàng Ai đang trực trạm nào còn nói vẫn thiếu. Đích YC-15 đã có; 06-luoc-do-nguoi-va-vet.md §1 có khoảng trực quầy. Chỉ phần quầy đã dựng, không suy đã có mốc cho mọi trạm.

**Lệch 6 — `work/backlog_AD.md:932`**

```text
tiền mà không phải hỏi lại ai.

```

Lời giao ADM-22 còn tả mỗi buổi/vào-ra. Nguồn shop-facts §8.7:1866–1869 và đích YC-30:296, lát 13 §1 đã là mỗi người mỗi ngày một ô, không giữ giờ tới/về.

**Lệch 7 — `work/backlog_AD.md:1370`**

```text
| **hình dạng dữ liệu** của cái vết | — | ⏳ **P1-07** của pha 1 viết yêu cầu; pha 2 chốt lược đồ (**ADR-035**) |
```

Hàng giao hình dạng dữ liệu của vết vẫn chờ P1-07/pha 2. Đích yêu cầu dữ liệu đã có và 06-luoc-do-nguoi-va-vet.md §1–2 đã dựng người/vết; chế độ mềm còn nợ không đồng nghĩa chưa có lược đồ.

**Kiểm và bàn giao.** Chỉ hai hàng ô 7 · 8 của §9.4 và §9.6 này được sửa. Không thay nghiệp vụ,
lược đồ, migration hoặc nguồn con trỏ. Lượt `./scripts/gate.sh` sau thay đổi: Gate 3/1b/1c/1d/1e PASS;
Gate 1 verify SKIP vì chỉ đổi tài liệu. Gate 1d soát 1 file, không phát hiện mẫu vi phạm;
điều ấy không giải quyết hai đoạn quyền loại 5. Diff chỉ có hai hàng cổng và mục này; output cuối
nguyên văn ở báo cáo phiếu. Claude còn phân loại hai đoạn quyền, xử lý bảy chỗ dẫn lệch, review và ký ô.

[↑ đầu file](#top)
