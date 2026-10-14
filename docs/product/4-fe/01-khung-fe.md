# Khung frontend — cây route, nguồn dữ liệu mỗi màn, lớp gọi API, danh mục component

Pha 4 · bước `P4-02` · viết 2026-10-13 (Claude Code). Owner của hàng *Route, component* ở `CLAUDE.md` §2
(**ADR-035**). Thước của pha 4 — mỗi nhóm người dùng lấy dữ liệu thế nào, ghi xong làm gì, state ở đâu:
`docs/decisions.md` **ADR-102**; file này **áp** thước ấy vào từng route, không chép lại nó.

**File này sở hữu:** cây route của `fe/` · nguồn dữ liệu của từng màn · cách lớp gọi API đọc hợp đồng ·
danh mục component dùng chung.

**File này KHÔNG sở hữu:**
- **hợp đồng API** — đường gọi, thân, mã lỗi: [`../3-be/openapi.yaml`](../3-be/openapi.yaml), luật đọc ở
  [`../3-be/01-hop-dong-api.md`](../3-be/01-hop-dong-api.md);
- **ai được bấm gì** — [`../3-be/02-vai-va-quyen.md`](../3-be/02-vai-va-quyen.md);
- **dựng bằng gì, ghim bản nào** — `QC-09` · `QC-18` ở [`../2-db/10-quy-uoc-code.md`](../2-db/10-quy-uoc-code.md);
- **chữ hiện cho khách** — luật quán, mở `U-XXX` ở bước gặp nó (kế hoạch pha 4 §2).

---

## 1. Cây route

Mỗi màn thêm **một dòng** ở đây cùng lượt dựng nó, và nhóm người dùng của nó là một trong bốn nhóm của
**ADR-102** điểm 1. Thư mục là `fe/src/app/`.

| Route | Nhóm (ADR-102) | Là gì | Bước dựng |
|---|---|---|---|
| `/` | — | trang giữ chỗ của khung, không dữ liệu, không màn nghiệp vụ | `P4-02` |
| `/api/[...path]` | — | **tầng chuyển tiếp** cùng origin, không phải màn (§3.2) | `P4-02` |

## 2. Nguồn dữ liệu mỗi màn

Ô cổng §9 thứ ba của kế hoạch pha 4 đối chiếu từng màn với bảng này. Mỗi màn một dòng, viết ở bước dựng nó;
ô *Đọc lại sau ghi* và *Mất kết nối* chép đúng dòng nhóm của **ADR-102** điểm 1 trừ khi màn có lý do khác —
khi ấy ghi lý do.

| Màn (route) | Đường đọc của hợp đồng | Đường ghi | Đọc lại khi | Mất kết nối bày gì | Bước |
|---|---|---|---|---|---|
| *(chưa có màn nào — `P4-05` thêm dòng đầu tiên)* | | | | | |

## 3. Lớp gọi API

### 3.1 Một lớp, sinh từ hợp đồng

- **Type sinh, không gõ tay.** `fe/src/lib/api/schema.ts` sinh từ `openapi.yaml` bằng `npm run gen:api` trong `fe/`
  (openapi-typescript, cờ `--enum-values` để có danh sách mã lỗi lúc chạy). Hợp đồng đổi ⇒ chạy lại lệnh và
  commit file sinh cùng lượt; `scripts/fe-check.sh` (`P4-03`) làm cổng đỏ khi file sinh lệch hợp đồng.
- **`int64` sinh thành số JavaScript** (`number`). Chấp nhận vì mã và số tiền của một quán nằm xa giới hạn số
  nguyên an toàn (**ADR-102** điểm 5).
- **Mọi lời gọi đi qua `fe/src/lib/api/client.ts`** (openapi-fetch có kiểu theo đường gọi): `createApi` dựng
  client, `call` đổi kết quả thành `ApiResult`. Không màn nào tự viết `fetch` tới backend.
- **Ba hình thất bại** (`ApiFailure`), theo `01-hop-dong-api.md` §3 và **ADR-102** điểm 1 · 2:

  | `kind` | Khi nào | Màn làm gì |
  |---|---|---|
  | `rejected` | backend trả hình `Error` với một `code` có trong `ErrorCode` | chọn chữ **theo `code`**, không theo status; có `field` thì gắn vào đúng ô |
  | `no_response` | không có phản hồi của backend — mất mạng, hay tầng chuyển tiếp không nối được backend | lệnh ghi: *chưa rõ kết quả*, không mời gửi lại ngầm; đường đọc: giữ bản cũ kèm cảnh báo theo nhóm |
  | `unexpected` | có phản hồi nhưng lạ hình — mã không có trong hợp đồng, thân không phải `Error` | coi như lỗi hệ thống; mã lạ là dấu hợp đồng và code lệch ⇒ `F-XXX` |

- **Không thử lại** ở lớp này — lệnh ghi không thử lại ngầm, đường đọc không thử lại lời từ chối có `code`
  (**ADR-102** điểm 2). Thử lại đường đọc khi `no_response` là cấu hình của thư viện truy vấn, chốt ở `P4-05`.
- **Danh tính.** `createApi({ personId })` gửi `X-Person-Id` bằng chữ số thập phân ở mỗi lời gọi khi đã có người
  chọn tên, không gửi khi chưa chọn (`openapi.yaml` `PersonIdentity`, **U-075**). Tên đang chọn cất ở đâu là
  `P4-04`.
- **Test:** `fe/src/lib/api/client.test.ts` — lời từ chối mẫu `option_combination_invalid` kèm `field`, mã lạ,
  thân không phải JSON, mất kết nối, tầng chuyển tiếp không nối được backend, có và không có `X-Person-Id`.

### 3.2 Tầng chuyển tiếp cùng origin

Trình duyệt chỉ gọi server Next (**ADR-102** điểm 6): `/api/<đường gọi của hợp đồng>` → backend ở
`BANHCUON_BE_URL` (biến môi trường **phía server**, không tiền tố `NEXT_PUBLIC_`; mặc định
`http://127.0.0.1:8080`, cổng mặc định của `be/cmd/server`). File: `fe/src/app/api/[...path]/route.ts`.

- Chạy cho từng request, không cache; trả nguyên status, thân, `Content-Type`, `Cache-Control`, `Allow`.
- Chuyển `Accept`, `Content-Type`, `X-Person-Id`, `Last-Event-ID` — không header nào khác lên backend.
- Thân backend đi ra dưới dạng luồng, nén tắt (`fe/next.config.ts`) ⇒ `text/event-stream` không bị đệm.
- Đường dẫn lấy nguyên từ URL, không giải mã lại — `%2F` trong mã QR tới backend như cũ (`QC-12`).
- Không nối được backend ⇒ `502` kèm header `x-banhcuon-upstream-unreachable` (lớp gọi API đọc thành
  `no_response`). Backend không bao giờ đặt header ấy.
- Trình duyệt đi ⇒ lời gọi lên backend huỷ theo. Điều này và *luồng quầy đóng thì backend thấy đóng* là việc
  `P4-06` chứng minh trên app thật (**ADR-102** điểm 7).

Đo 2026-10-13 (Claude Code, `P4-02`, backend thật + `next start`): `GET /menu` qua Next ra cùng `shasum` với gọi
thẳng backend; `/counter/queue` không danh tính `401 unauthenticated`, có `X-Person-Id` thì backend đọc người
(`403 not_on_counter_duty`) — header tới nơi; `POST /price-quotes` lời từ chối kèm `field` đi nguyên; mã QR
`a%2Fb` ra cùng lời backend; `405` giữ `Allow`; sự kiện `hello` của luồng trạm tới sau 0,01 giây — không đệm;
backend tắt ⇒ `502` kèm header trên.

## 4. Danh mục component dùng chung

Primitive giao diện là shadcn/ui, thêm bằng CLI ghim của `fe/` (`npx shadcn add <tên>` trong `fe/`) vào
`fe/src/components/ui/`, **từng cái khi một màn cần** (**ADR-100**). Một thành phần được nâng lên dùng chung khi
có nơi dùng thứ hai (**ADR-102** điểm 8) và thêm một dòng ở đây cùng lượt.

| Component | Ở đâu | Làm gì | Ai dùng | Bước |
|---|---|---|---|---|
| *(chưa có — `P4-02` không thêm primitive nào)* | | | | |

## 5. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P4-03` | §3.1 lệnh sinh type để so lệch; §3.2 để biết tầng chuyển tiếp là chỗ duy nhất gọi `fetch` thẳng |
| `P4-04` | §3.1 `personId` của `createApi` — nối với tên đang chọn |
| `P4-05` | §1 · §2 thêm dòng màn đầu tiên; §3.1 cấu hình thư viện truy vấn; §4 primitive đầu tiên |
| `P4-06` | §3.2 ba điều phải chứng minh trên luồng thật |
