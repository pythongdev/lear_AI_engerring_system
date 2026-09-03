# 13b — DOC-3b: chuyển pointer nhóm B (`prompt/BA/**`) · L1

> Task con 2/3 của **DOC-3** (`prompt/maintenance/13-pointer-migration-L3.md`, lượt chia việc
> chạy 2026-09-02). **Chạy ĐẦU TIÊN trong ba task con** — xem *Vì sao đứng trước*.

## Vì sao đứng trước DOC-3a

**BA-11 và BA-12 vẫn nằm ở *Ready*** (`work/backlog.md`, xác nhận 2026-09-02: chúng **không** có
mục `- [x]` nào ở *Done*). Prompt của chúng là `prompt/BA/10-acceptance-scenarios-L2.md` và
`prompt/BA/12-production-control-L2.md`, và **khối `Scope` của cả hai đang ghi trần một dòng
`docs/product.md`** — tức là **bản lưu**.

Ai bắt BA-11 ngày mai sẽ khai báo scope trỏ vào bản lưu, rồi **ghi §8 vào bản lưu**. Lúc ấy:
ADR-014 (*"file cũ ở lại làm lưu trữ, không ai trỏ về"*) bị phá từ bên trong, `docs/product/0-ba/
ban-hang/08-scenario.md` vẫn rỗng, và **không cổng nào đỏ** — Gate 1b chỉ hỏi đường dẫn có mở
được không, mà bản lưu thì mở được.

Đó là hỏng **âm thầm**, và nó xảy ra vào ngày ai đó bắt BA-11 — không phải một ngày xa xôi.
Nhóm A hỏng nhẹ hơn nhiều: phiên đọc pointer cũ vẫn tới được **bản sao** đúng nội dung, hại ở chỗ
đọc nhầm nhà chứ không ghi nhầm nhà.

## Context

- **Đo lại 2026-09-02 (sau DOC-2):** nhóm B có **114 dòng** trong **13 file**. Không đồng nhất —
  chia làm ba loại, và **luật ánh xạ chỉ áp được cho loại 1**:

  | Loại | Dòng | Xử lý |
  |---|---:|---|
  | **1 · văn xuôi chỉ đường** | 72 | áp luật ánh xạ |
  | **2 · scope trần** — một dòng chỉ có `docs/product.md`, trong khối ```text | 12 | → `docs/product/` (xem *Constraints*) |
  | **3 · LỆNH chạy được** — `grep -n '...' docs/product.md` | 30 | **chỉ sửa 10 dòng** của 2 file còn sống |

- **42/114 dòng nằm TRONG khối ```** ⇒ **Gate 1b không chấm chúng** (`scripts/check-links.sh` cắt
  bỏ khối code trước khi rà). Toàn bộ loại 2 và loại 3 là vùng mù của cổng máy. Chỉ 72 dòng loại 1
  được gate đỡ.
- **11/13 file là prompt của task ĐÃ XONG** (BA-01…BA-10 đều `- [x]` ở *Done*). Chỉ
  `prompt/BA/10-acceptance-scenarios-L2.md` (BA-11) và `prompt/BA/12-production-control-L2.md` (BA-12) là còn sẽ chạy.

## Goal

Không prompt BA nào còn **chỉ** người đọc về `docs/product.md`; và hai prompt còn sẽ chạy
(BA-11, BA-12) **ghi và verify đúng file con**, không đụng bản lưu.

## Scope

```text
prompt/BA/
work/backlog.md
```

Ngoài phạm vi: nhóm A (DOC-3a) · vùng *Ready* của `work/backlog.md` (DOC-3c) · `CLAUDE.md` (DOC-4)
· `prompt/maintenance/**` (sổ lịch sử, CLAUDE.md §5) · nội dung `docs/product/**`.

## Constraints

- **Luật ánh xạ:** giống hệt bảng ở `prompt/maintenance/13a-pointer-nhom-A-L2.md` §*Constraints*.
  Không chép lại ở đây — một bảng, một chỗ (`work/findings.md` F-001).
- **Loại 2 — scope trần → `docs/product/`.** Mười hai dòng, mỗi file một dòng, trong khối
  ```text của mục `Scope`. Chúng là **pattern cho Gate 3**, không phải câu văn: `docs/product/`
  (có `/` cuối) cho phép mọi thứ dưới thư mục, đúng cú pháp `work/scope.txt`. **Đừng** ghi
  `docs/product/0-ba/ban-hang/04-….md` ở đây — một prompt BA thường ghi nhiều mục.
- **Loại 3 — LỆNH: chỉ sửa 2 file còn sống.** Quyết định của chủ repo, 2026-09-02:

  - **Sửa** 10 dòng lệnh trong `prompt/BA/10-acceptance-scenarios-L2.md` và `prompt/BA/12-production-control-L2.md`.
  - **Giữ nguyên** 20 dòng lệnh trong 11 prompt của task đã xong — chúng là **biên bản một lượt
    chạy đã kết thúc**, cùng lý lẽ CLAUDE.md §5 dùng cho nhóm E.

- **Đổi đường dẫn máy móc sẽ làm LỆNH SAI.** `grep -n 'x' docs/product.md` → `grep -n 'x'
  docs/product/` **không chạy** (grep một thư mục cần `-r`). Với mỗi lệnh trong 2 file còn sống,
  chọn **một** trong hai, rồi **chạy thử**:
  - trỏ đúng **file con** mà lệnh ấy thật sự nói về (ưu tiên — lệnh chặt hơn, kết quả đọc được), hoặc
  - `grep -rn '...' docs/product/` khi lệnh cố ý rà cả tài liệu.

  **Lệnh nào cũng phải chạy thử và dán kết quả**, vì Gate 1b không chấm chúng — không chạy thử thì
  không có bằng chứng nào cả (CLAUDE.md §5: *"tôi đã test" không phải bằng chứng*).
- **Cẩn thận với lệnh có kỳ vọng viết sẵn.** Nhiều lệnh kèm chú thích *"# phải rỗng"*, *"# = 3"*,
  *"# không có kết quả"*. Sau khi đổi đường dẫn, **kỳ vọng ấy phải vẫn đúng**. Nếu một lệnh đổi
  xong cho kết quả khác chú thích, đó là phát hiện thật — ghi vào `work/findings.md`, đừng lặng lẽ
  sửa con số cho khớp.
- **Không `sed -i` trên cả thư mục.** Ba loại dòng nằm lẫn nhau trong cùng một file.
- **`prompt/BA/**` khác `prompt/maintenance/**`.** Gate 1b **có** chấm `prompt/BA/` (ngoài khối
  code) và **không** chấm `prompt/maintenance/`. Đừng gộp hai thư mục.

## Acceptance

1. `prompt/BA/**` không còn dòng **văn xuôi** nào trỏ `docs/product.md` (72 → 0).
2. Mười hai dòng scope trần đều là `docs/product/`.
3. Trong 2 file còn sống, **không còn dòng lệnh nào** dùng `docs/product.md`; mỗi lệnh đã đổi được
   **chạy thử** và kết quả dán vào report, khớp chú thích kỳ vọng đi kèm.
4. Hai mươi dòng lệnh trong 11 prompt đã xong **không đổi một ký tự** — `git diff` chứng minh.
5. `./scripts/gate.sh` xanh.
6. Không câu chữ nào quanh pointer bị viết lại.

## Verify

```bash
# Bản portable — grep ở máy này là ugrep, KHÔNG in tiền tố "./" (F-017)

# 1 · văn xuôi còn sót (bỏ dòng lệnh và dòng scope trần)
grep -rn 'docs/product\.md' prompt/BA/ \
  | grep -vE ':[0-9]+: *(grep|awk|sed|wc|cat)' \
  | grep -vE ':[0-9]+: *docs/product\.md *$'          # phải rỗng

# 2 · scope trần đã đổi hết
grep -rnE '^ *docs/product\.md *$' prompt/BA/          # phải rỗng
grep -rcE '^ *docs/product/ *$' prompt/BA/ | grep -v ':0$' | wc -l   # = 12

# 3 · hai file còn sống sạch hoàn toàn
grep -n 'docs/product\.md' prompt/BA/10-acceptance-scenarios-L2.md \
                            prompt/BA/12-production-control-L2.md    # phải rỗng

# 4 · 11 prompt đã xong: chỉ được đổi văn xuôi, không đổi dòng lệnh
git diff -- prompt/BA/ | grep -E '^[-+] *(grep|awk|sed|wc|cat)' \
  | grep -v '10-acceptance\|12-production'             # phải rỗng

./scripts/gate.sh; echo "exit=$?"
```

## Phương án lùi

Một commit riêng (`DOC-3b: ...`) ⇒ `git revert <sha DOC-3b>`. Không dùng chung file nào với
DOC-3a hay DOC-3c.

## Unknowns

- Không có câu hỏi nghiệp vụ.
- **Vùng mù đã biết:** 42/114 dòng nằm trong khối ``` nên Gate 1b không chấm. Bằng chứng duy nhất
  cho loại 3 là **chạy thử từng lệnh**. Đừng dựng gate mới (CLAUDE.md §3.8).

## Report

- Đã thay đổi gì · đã verify thế nào, kết quả ra sao · còn vấn đề gì chưa giải quyết
- **Dán kết quả chạy thử của từng lệnh đã đổi** trong 2 file còn sống
