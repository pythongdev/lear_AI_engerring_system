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

[↑ đầu file](#top)

---

<a id="p2a-03"></a>
### P2A-03 — Nhân viên sẽ tự bấm chấm công, và chưa ai biết một lần bấm ghi lại mốc gì

**Phụ thuộc** · bước 3/9 · **cần xong trước:** `P2A-01` · **`U-065` có lời**
(`docs/product/99-unknowns.md`).

**Goal:**
Xong rồi thì đọc ra được *người này, ngày này, đã chấm công những mốc nào*, và người ấy là người
của lát `P2-08`, không phải một danh sách thứ hai.

**Nói một câu, việc phải làm là gì:**
Dựng lát chấm công đúng bằng lời `C31` cộng lời `U-065`. **Không** phải làm: ngưỡng đi muộn, khoản
trừ, tính công thành tiền — phần lương ở kế hoạch §6.

**Vì sao có task này:**
Chủ quán chốt cả ba mức của mảng con người (§8.7); mức 2 là chấm công, và mức 3 đứng trên nó.

**Không làm thì mất gì:**
- Khi công thức lương có lời, không có sổ công nào để nhân với đơn giá.
- Nhân viên được xem công của chính mình (`C35`) mà không có công nào để xem.

**Bị chặn — hỏi gì trước.** `U-065`. Bước này **không nhận được** cho tới khi câu ấy có lời, và
lời ấy phải thành dòng `YC` (bổ sung vào đầu ra của `P2A-01`) trước khi dựng. Mười bước chạy viết
lúc nhận việc, theo khuôn `P2A-02`.

**Bẫy hay sửa nhầm nhất:**
- **Đừng dùng mốc đổi người ở quầy làm chấm công.** §8.8 nói thẳng hai câu ấy khác nhau.
- **Đừng dựng cột *đi muộn*.** `C32`: đi muộn không trừ tiền, và ngưỡng phút chưa có.
- **Người khai mốc trực quầy là POS; người chấm công là chính nhân viên** — hai nguồn, đừng gộp.

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

[↑ đầu file](#top)

---

<a id="p2a-05"></a>
### P2A-05 — Hệ thống cộng được mọi đồng đi VÀO quán và chưa biết một đồng nào đi RA

**Phụ thuộc** · bước 5/9 · **cần xong trước:** `P2A-01` · **`U-066` có lời**.

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

**Bị chặn — hỏi gì trước.** `U-066`: khoản chi lấy từ két thì chạm phép đối soát cuối ngày
(`quality/invariants.md` **I-021**), lấy từ tiền riêng thì không. Hình dạng phụ thuộc lời ấy.

**Bẫy hay sửa nhầm nhất:**
- **Tiền hàng không vào đây.** §8.10 cấm cộng trùng giò, trứng, rau, quất với mua hàng.
- **Danh sách loại chi chưa đóng.** §8.10 cấm suy rằng quán không có khoản nào khác ⇒ loại chi
  thêm được, không phải một danh sách cứng trong lược đồ.
- **Chữ *cố định hằng tháng* không phải số tiền cố định.**

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
