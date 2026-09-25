# Sổ finding — lane FE

> Cập nhật **2026-08-19** · Lane sở hữu: **FE** · Sổ **finding** của riêng lane này.
> Sổ **task** của lane: [task_FE.md](task_FE.md). Lane chưa tách vẫn dùng [/finding.md](../../finding.md).
> **File này đo *đúng / sai*, không đo *xong / chưa*** — việc chưa tới lượt xây đi sổ task ([§7](../../CLAUDE.md)).
> Mức, trạng thái, luật đóng: dùng nguyên khuôn ở [/finding.md §Quy ước](../../finding.md) — **không chép về đây** ([§2.1](../../CLAUDE.md)).
> Sự thật FE khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu](04-yeu-cau.md) · [ghi vào file nào](README.md).

## Cửa vào — dòng nào được nằm ở sổ này

Hai câu hỏi, phải trả lời **có** cả hai:

1. **Đang sai ngay bây giờ?** Chạy hết [task_FE.md](task_FE.md) + [/task.md](../../task.md) y như nó viết —
   dòng này còn không? **Còn** ⇒ finding. **Mất** ⇒ task. Câu mở đầu bằng *"chưa có X"* gần như luôn là task ([F-65](../../finding.md#f-65)).
2. **Lane FE là lane phải sửa?** Nhà của finding là sổ của lane **sở hữu vùng phải sửa**, không phải lane phát hiện.
   Sai ở `deploy/Caddyfile` ⇒ sổ chung (DEVOPS chưa tách); ở `code/be/api/openapi.yaml` ⇒ lane BE.

**ID:** `F-FE-xx`, đánh số tăng dần trong file này, độc lập với `F-xx` của sổ chung. Số kế tiếp:

```bash
grep -o 'F-FE-[0-9]*' design/frontend/finding_FE.md | sort -u | tail -1
```

## Nguồn chung của bảy dòng đầu

`F-FE-01` … `F-FE-07` **cùng một nguyên nhân gốc**: [01-thiet-ke.md](01-thiet-ke.md) và [02-luat.md](02-luat.md)
được viết ngày **2026-08-14** dựa trên mô hình Next.js **trước 16**, trong khi `@latest` hôm nay là
**Next 16.3** (tài liệu `lastUpdated 2026-08-07`). `fe/` còn **0 file** ([F-30](../../finding.md#f-30))
nên chưa dòng nào nổ — chúng sẽ nổ **đúng lúc `T-23` chạy `create-next-app`**, tức lúc đắt nhất để phát hiện.

`F-FE-08` **không** chung gốc đó: nó sinh ra từ đợt dời `be/` → `code/be/` ngày `2026-08-18`, và nó
**chặn cả bảy dòng kia**, vì bảy dòng kia đều nói về một thư mục chưa ai chốt tên.

Đây là finding chứ không phải task vì áp phép thử [§7](../../CLAUDE.md): chạy hết kế hoạch y như nó viết,
tám dòng này **vẫn còn** — không bước nào trong [/task.md](../../task.md) nói tới chúng, nên chúng không tự mất đi.

## Bảng tổng hợp

| ID | Mức | Finding | Trạng thái | Chặn việc gì | Context |
|---|---|---|---|---|---|
| [F-FE-01](#f-fe-01) | 🟠 | `02-luat §7` khai *"dùng `next/image` cho mọi ảnh món"* như việc đã xong; Next 16 đổi 4 mặc định của `next/image`, một trong đó **chặn hẳn** ảnh phục vụ từ Go BE ở `localhost`/IP nội bộ | 🔓 MỞ | `T-25`, `T-27`, `T-29` | **Nạp:** [02-luat §7](02-luat.md) · **Đóng đúng:** `next.config.ts` có `images.remotePatterns` + `qualities`, và một ảnh món hiện được ở dev · **Bẫy:** lỗi trả về `400 Bad Request`, trông y hệt lỗi BE |
| [F-FE-02](#f-fe-02) | 🟠 | Checklist `02-luat` và `T-23` dựa vào `npm run lint`; Next 16 **xoá `next lint`** và `next build` **không còn tự lint** ⇒ lint có thể không bao giờ chạy mà CI vẫn xanh | 🔓 MỞ | `T-23`, `T-30` | **Nạp:** [02-luat §1 + Checklist](02-luat.md) · **Đóng đúng:** `make test-fe` chạy ESLint thật, và cố tình vi phạm `no-floating-promises` thì nó **đỏ** |
| [F-FE-03](#f-fe-03) | 🟠 | Cây route ở `01 §4.2` không có chỗ nào chặn người lạ vào `staff/**` và `admin/**`; nhà của việc đó ở Next 16 là **`proxy.ts`** (tên mới của `middleware.ts`) và không file FE nào nhắc tới nó | 🔓 MỞ | `T-28`, `T-29` | **Nạp:** [01-thiet-ke §4.2](01-thiet-ke.md) · **Đã chốt:** BE vẫn là lớp chặn thật (JWT); đây là lớp thứ hai · **Đóng đúng:** gõ thẳng `/admin/reports` khi chưa đăng nhập ⇒ bị đẩy về `/staff/login` |
| [F-FE-04](#f-fe-04) | 🟠 | Code mẫu giỏ hàng ở `01 §4.4` dùng `persist` **không có `skipHydration`** ⇒ server render giỏ rỗng, client rehydrate từ `localStorage` ⇒ hydration mismatch | 🔓 MỞ | `T-26`, `T-27` | **Nạp:** [01-thiet-ke §4.4](01-thiet-ke.md) · **Đóng đúng:** mẫu có `skipHydration: true` + `rehydrate()` trong effect, và test *"giỏ giữ sau reload"* ở [02 §6](02-luat.md) xanh · **Bẫy:** lỗi chỉ hiện ở `next build`, dev không nổ |
| [F-FE-05](#f-fe-05) | 🟡 | Lệnh `create-next-app` ở `01 §4.1` **treo ở prompt tương tác** trên CLI 16 (thiếu `--yes`), và 3 trong 5 flag của nó nay đã là mặc định | 🔓 MỞ | `T-23` | **Nạp:** [01-thiet-ke §4.1](01-thiet-ke.md) · **Đóng đúng:** lệnh chạy hết trong một session không tương tác · **Bẫy:** agent treo trông giống mạng chậm |
| [F-FE-06](#f-fe-06) | 🟡 | `01 §4.2` mô tả 4 route động (`menu/[slug]`, `t/[token]`, `orders/[code]`, `station/[code]`) mà không nói `params`/`searchParams`/`cookies()`/`headers()` ở Next 16 **đều là Promise** | 🔓 MỞ | `T-25`, `T-27`, `T-28` | **Nạp:** [01-thiet-ke §4.2](01-thiet-ke.md) · **Đóng đúng:** một dòng luật trong `02-luat` + mẫu `await params` trong `01` · **Bẫy:** mọi mẫu Next 14 trên mạng đều sai chỗ này |
| [F-FE-07](#f-fe-07) | 🟡 | Hai quyết định trong cùng thư mục chống nhau: `01 §4.1` cài **axios**, `02 §2` chốt **type sinh từ `openapi.yaml`** — axios không nhận type theo path nên phải bọc tay, tức đẻ nhà thứ hai cho cùng một sự thật | 🔓 MỞ | `T-24` | **Nạp:** [01-thiet-ke §4.1](01-thiet-ke.md) + [02-luat §2](02-luat.md) · **Đóng đúng:** một client duy nhất, type đến thẳng từ `openapi.yaml`, không có lớp bọc tay ở giữa |
| [F-FE-08](#f-fe-08) | 🟠 | `be/` đã dời sang **`code/be/`**, nhưng cả 5 file `design/frontend/` và `.gitignore` vẫn nói **`fe/`** — chưa ai chốt FE sẽ nằm ở `fe/` hay `code/fe/` | 🔓 MỞ | `T-23`, và cả `F-FE-01`…`F-FE-07` | **Nạp:** [03-hien-trang.md](03-hien-trang.md) + [/.gitignore](../../.gitignore) · **Đo:** `git ls-files | grep -c '^code/be/'` > 0 và `grep -c 'fe/.next' .gitignore` = 1 · **Đóng đúng:** một câu chốt đường dẫn + `.gitignore` khớp · **Bẫy:** `fe/` không tồn tại trên đĩa nên `ls` không báo gì |

---

## F-FE-01

**Mệnh đề đang sai.** [02-luat §7](02-luat.md) viết *"Dùng `next/image` cho mọi ảnh món — nó tự resize và
chuyển WebP"*, và [02 §8](02-luat.md) liệt kê *"ảnh món không nén"* như bẫy đã có cách tránh. Câu đó đúng với
Next 15, sai với Next 16 ở **bốn mặc định**:

| Mặc định | Trước | Next 16 | Hậu quả ở dự án này |
|---|---|---|---|
| `images.dangerouslyAllowLocalIP` | không có | **`false`** | Ảnh món phục vụ từ Go BE ở `localhost:8080` hoặc IP LAN ⇒ **`400 Bad Request`** |
| `images.qualities` | `[1..100]` | **`[75]`** | `quality` khác 75 bị ép về 75; gọi thẳng REST API với quality khác ⇒ `400` |
| `images.minimumCacheTTL` | 60s | **14400s (4h)** | Chủ quán đổi ảnh món, 4 tiếng sau ảnh mới mới lên |
| prop `priority` | dùng được | **deprecated**, thay bằng `preload` | Ảnh đầu trang menu mất tối ưu LCP một cách im lặng |

Thêm hai dòng nữa: `images.domains` đã deprecated (dùng `remotePatterns`), và giá trị `16` bị bỏ khỏi
`images.imageSizes` mặc định.

**Hỏng thành cái gì ở quán.** Menu không có ảnh — mà với quán ăn thì ảnh **là** menu. Và vì lỗi trả về
`400 Bad Request` từ route tối ưu ảnh của Next, người debug sẽ đi tìm ở Go BE trước, ở đó không có gì sai cả.

**Đóng đúng.** `next.config.ts` khai `images.remotePatterns` trỏ đúng host ảnh của BE, `qualities` khai rõ
các mức được dùng, và **quyết định dứt khoát một trong hai**: (a) BE phục vụ ảnh qua đúng domain thật sau Caddy
⇒ không cần `dangerouslyAllowLocalIP`; (b) chấp nhận bật `dangerouslyAllowLocalIP: true` **chỉ cho môi trường dev**,
kèm một dòng ghi rõ đây là rủi ro SSRF đã biết. Cộng một ảnh món thật hiện được ở `next dev`. Task: `T-FE-04`.

## F-FE-02

**Mệnh đề đang sai.** Checklist cuối [02-luat.md](02-luat.md) có dòng *"`npm run lint` không lỗi"*, và
[02 §1](02-luat.md) dựng cả một `eslint.config.mjs` với 4 luật — trong đó `no-floating-promises` được ghi rõ là
thứ bắt *"bấm nút không thấy gì xảy ra"*. Next 16 **xoá hẳn lệnh `next lint`**, và `next build` **không còn chạy lint**.

Nghĩa là nếu `package.json` do `create-next-app` sinh ra để `"lint": "next lint"` (mẫu cũ) thì lệnh **gãy**;
còn nếu không ai nối ESLint vào `make test-fe` thì `next build` xanh trong khi lint **chưa từng chạy lần nào**.

**Hỏng thành cái gì ở quán.** Bốn luật ở `02 §1` là bốn thứ chặn lỗi thật (`any`, quên `await`, deps của hook,
`console.log` lọt lên máy thật). Chúng thành trang trí, và không lệnh nào báo rằng chúng đang là trang trí — đúng
kiểu mục ruỗng âm thầm mà [§6.7 của prompt](../../project_preparation/prompt-fullstack.md) cảnh báo.

**Đóng đúng.** ESLint gọi trực tiếp trong `package.json` (codemod có sẵn:
`npx @next/codemod@canary next-lint-to-eslint-cli .`), nối vào `make test-fe`, **và** một lần chứng minh
nó đỏ được: viết cố ý một `fetch()` không `await`, chạy lệnh, dán output đỏ. Task: `T-FE-05`.

## F-FE-03

**Mệnh đề đang sai.** [01 §4.2](01-thiet-ke.md) vẽ đủ 4 nhóm route và [01 §4.5](01-thiet-ke.md) nhớ đặt
`robots: { index: false }` cho `t/`, `staff/`, `admin/` — tức đã nghĩ tới việc *giấu* ba nhóm này. Nhưng
**giấu khỏi Google không phải là chặn người**: không file nào trong thư mục này nói ai chặn một người gõ
thẳng `/admin/reports` vào thanh địa chỉ.

Ở Next 16 nhà của việc đó là **`proxy.ts`** — tên mới của `middleware.ts`, chạy trên Node runtime;
`middleware.ts` vẫn còn nhưng đã deprecated và sẽ bị xoá. Cả hai cái tên đều **không xuất hiện** trong
`design/frontend/`.

**Hỏng thành cái gì ở quán.** BE có JWT nên dữ liệu không rò — API sẽ trả 401. Nhưng người lạ vẫn **vào được
giao diện admin**, thấy sơ đồ bàn rỗng, thấy nút "Tạm dừng nhận đơn", thấy form settings. Với chủ quán, đó là
"phần mềm của tôi ai vào cũng được", và niềm tin đó khó lấy lại hơn là sửa lỗi.

**Đóng đúng.** Một `proxy.ts` chặn `staff/**` + `admin/**` khi không có phiên hợp lệ, **và** cách kiểm bằng
tay: đăng xuất, gõ thẳng `/admin/reports`, phải bị đẩy về `/staff/login`. Ghi rõ trong `01 §4.2` rằng đây là
**lớp thứ hai** — lớp thật vẫn là JWT ở BE, FE không được là chỗ duy nhất chặn. Task: `T-FE-03`.

## F-FE-04

**Mệnh đề đang sai.** Code mẫu giỏ hàng ở [01 §4.4](01-thiet-ke.md) kết thúc bằng
`{ name: 'banhcuon-cart' }`. Với App Router, HTML dựng ở server (nơi **không có** `localStorage`) rồi hydrate
ở client (nơi **có**) ⇒ hai lần render đầu ra khác nhau ⇒ React báo hydration mismatch và có thể vứt cả cây DOM
đang có, làm nháy màn hình hoặc mất trạng thái.

Phần `makeKey` phải sort `optionIds` ở ngay dưới đó là **đúng** và đã bắt trúng một bẫy thật — giữ nguyên,
finding này không đụng tới nó.

**Hỏng thành cái gì ở quán.** Khách chọn 5 món, trang nháy một cái, giỏ về rỗng hoặc về trạng thái cũ.
Khách không báo lỗi, khách **bỏ đi**. Và đây đúng là ca [02 §6](02-luat.md) đã dựng test cho
(*"reload trang không mất giỏ"*) — tức yêu cầu đã có, chỉ mẫu code là sai.

**Đóng đúng.** Mẫu ở `01 §4.4` thêm `skipHydration: true` và một `useEffect` gọi
`useCart.persist.rehydrate()`, cộng một dòng ở `02-luat` nói **vì sao** (đừng để session sau tưởng là thừa rồi bỏ đi).
Bằng chứng: test *"giỏ giữ sau reload"* chạy trên `next build && next start`, không phải trên `next dev`.
Task: `T-FE-06`.

## F-FE-05

**Mệnh đề đang sai.** Lệnh ở [01 §4.1](01-thiet-ke.md):

```
npx create-next-app@latest . --typescript --tailwind --app --src-dir --eslint
```

Trên CLI của Next 16, `--typescript`, `--tailwind`, `--app` **đã là mặc định**, và CLI vẫn **hỏi tương tác**
(*"Would you like to use the recommended Next.js defaults?"*) nếu không có `--yes`. Có thêm ba flag mới đáng biết:
`--react-compiler`, `--biome`, và `--agents-md` (mặc định bật — nó **tự sinh `AGENTS.md` và `CLAUDE.md` trong `fe/`**,
tức đẻ file vào vùng mà [§2.4](../../CLAUDE.md) đã có chủ, và `T-76` vừa mới dọn `fe/` về 0 file).

**Hỏng thành cái gì.** Session chạy `T-23` treo ở prompt và trông y như mạng chậm; hoặc chạy xong thì `fe/`
mọc thêm `CLAUDE.md` cạnh `/CLAUDE.md` — hai file cùng tên, một cái là bản đồ repo, một cái do máy sinh.

**Đóng đúng.** Sửa lệnh trong `01 §4.1` (thêm `--yes`, cân nhắc `--no-agents-md`), và ghi thêm ba ngưỡng tối
thiểu của Next 16 mà thư mục này chưa có ở đâu: **Node ≥ 20.9** (đang dùng 24 LTS ✓) · **TypeScript ≥ 5.1**
(16.3 dùng được TS 7 cho `next build`) · **trình duyệt Chrome/Edge/Firefox 111+, Safari 16.4+** — dòng cuối
thuộc về [02 §4](02-luat.md), cạnh bảng *"360×640 điện thoại rẻ"*, vì nó là ngưỡng **máy của khách**.
Task: `T-FE-02`.

## F-FE-06

**Mệnh đề đang sai.** `01 §4.2` liệt kê 4 route động và không nói gì về cách đọc tham số. Ở Next 16, truy cập
đồng bộ đã **bị xoá**, không phải deprecated: `params`, `searchParams`, `cookies()`, `headers()`, `draftMode()`
đều là Promise, phải `await`.

Riêng `t/[token]` đáng gọi tên: token bàn nằm trong URL, và mọi thứ trang đó làm đều bắt đầu bằng việc đọc nó.

**Hỏng thành cái gì.** Không compile — nên nó **không** phải loại lỗi giết dự án. Nó chỉ ăn thời gian, và ăn
đúng vào lúc session đang copy một mẫu Next 14 trên mạng rồi loay hoay không hiểu vì sao mẫu chính thống lại sai.

**Đóng đúng.** Một mẫu `await params` trong `01 §4.2` + một dòng trong `02-luat §8` (bảng bẫy thường gặp).
Nếu `T-FE-09` được chốt là **có** bật Cache Components thì mẫu đó phải đi xa hơn một bước — `await params`
**bên trong `<Suspense>`**, không phải ở đầu component — và khi đó dòng này đóng chung với `T-FE-09`.
Task: `T-FE-03`.

## F-FE-07

**Mệnh đề đang sai.** Trong cùng thư mục, hai file chốt hai thứ chống nhau:

- [01 §4.1](01-thiet-ke.md) cài `axios`.
- [02 §2](02-luat.md) chốt **type sinh từ `code/be/api/openapi.yaml`**, gọi đó là *"biện pháp hiệu quả nhất của cả tầng FE"*,
  và vẽ sơ đồ `api-types.ts` → `api.ts` (*"client bọc fetch"* — chú ý: **fetch**, không phải axios).

Axios không biết gì về `openapi.yaml`: nó trả `any`, nên phải viết tay một lớp bọc gán type cho từng endpoint.
Lớp bọc đó chính là **nhà thứ hai** cho hợp đồng API — và [§2.1](../../CLAUDE.md) đã nói nhà thứ hai luôn trôi
trong im lặng. Đổi `total` → `total_amount` ở BE thì `api-types.ts` đỏ, còn lớp bọc tay thì không, trừ khi
người viết nhớ sửa cả hai.

**Hỏng thành cái gì.** Đúng cái mà `02 §2` hứa sẽ chặn: *"BE đổi tên trường → FE đỏ ngay lúc build, không phải
đợi khách bấm checkout mới biết"*. Lời hứa đó chỉ đúng nếu **không có** lớp bọc tay ở giữa.

**Đóng đúng.** Một client duy nhất, type đi thẳng từ `openapi.yaml` — `openapi-fetch` là cặp chính thức của
`openapi-typescript` đã chọn (`client.GET('/products/{slug}')` được kiểm cả path, query, body, response).
Bỏ `axios` khỏi `01 §4.1`. Bằng chứng đóng: đổi tên một trường trong `openapi.yaml`, chạy `npm run gen:api`,
`tsc --noEmit` phải **đỏ** — dán output. Task: `T-FE-08`.

## F-FE-08

**Mệnh đề đang sai.** Đo được bằng ba lệnh:

```bash
git ls-files | grep -c '^code/be/'                     # > 0 — BE đã ở code/be/
git ls-files | grep -c '^fe/\|^code/fe/'               # 0  — FE chưa có ở đâu cả
grep -n 'fe/' .gitignore                               # còn 'fe/.next/', 'fe/out/'
grep -rn '`fe/' design/frontend/*.md | wc -l           # 5 file vẫn viết fe/
```

BE đã dời sang `code/be/` (thấy trong [02-luat §2](02-luat.md): `code/be/api/openapi.yaml`), nhưng
FE thì **chưa ai chốt** — [03-hien-trang.md](03-hien-trang.md), [04-yeu-cau.md](04-yeu-cau.md) và
[01-thiet-ke.md](01-thiet-ke.md) đều còn viết `fe/`, kể cả trong lệnh đo `git ls-files fe/ | wc -l`.
Lệnh đó hôm nay ra `0`, và sẽ **vẫn ra `0`** kể cả sau khi `T-23` dựng xong app ở `code/fe/` — tức
biên nhận của cả thư mục ([README §3 phép D](README.md)) đang **hỏng mà vẫn xanh**.

**Vì sao là finding chứ không phải task.** Đây không phải *"chưa có thư mục FE"* (cái đó là `T-23`).
Đây là **hai nguồn đang nói hai đường về cùng một đường dẫn**, và chạy hết kế hoạch y như nó viết thì
mâu thuẫn đó vẫn còn nguyên.

**Hỏng thành cái gì.** Hai đường, cả hai đều im lặng:

1. `T-23` chạy `create-next-app` ở `code/fe/` ⇒ `.gitignore` vẫn ignore `fe/.next/`, **không** ignore
   `code/fe/.next/` ⇒ commit đầu tiên của FE nuốt trọn thư mục build. Repo **chưa có remote**
   ([F-25](../../finding.md#f-25)) nên không ai chặn hộ.
2. Phép D của [README §3](README.md) — *"con số duy nhất cả thư mục này dựa vào"* — đo sai thư mục,
   nên nó sẽ mãi báo `0` và **mọi khẳng định trong `design/frontend/` giữ nguyên quyền được tin sẵn**
   kể cả khi code đã chạy khác. Đúng thứ [§2.2](../../CLAUDE.md) gọi là tài liệu thắng code.

**Đóng đúng.** Một câu chốt đường dẫn (ở [03-hien-trang.md](03-hien-trang.md), vì đây là sự thật
*hiện có gì*), `.gitignore` sửa theo, **và** 4 lệnh `git ls-files fe/` rải trong thư mục này trỏ đúng
chỗ. Bằng chứng: `git check-ignore -v <đường-dẫn>/.next/x` ra đúng một dòng. Task: `T-FE-02`.

**Cần ai.** Owner hoặc lane NON-CODE — `.gitignore` và cấu trúc thư mục gốc **không thuộc lane FE**
([§2.4](../../CLAUDE.md)). Lane FE chỉ được đề xuất và chờ.

---

## Ba dòng KHÔNG thuộc sổ này — ghi ở đây để khỏi mất, không phải để làm ở đây

| Việc | Nhà thật | Vì sao không nằm đây |
|---|---|---|
| Caddy `reverse_proxy` mặc định **có buffer** ⇒ SSE bị đệm, màn hình trạm không nhận việc, mà `make check` vẫn xanh. Cần `flush_interval -1` | [/finding.md](../../finding.md) — lane **DEVOPS**, chưa tách sổ | Nhà của finding là lane **phải sửa**, không phải lane phát hiện ([§7](../../CLAUDE.md)). File phải sửa là `deploy/Caddyfile` |
| BE gọi webhook `revalidate` của FE mỗi khi đổi menu / `availability` | [/task.md](../../task.md) — lane **BE** | Việc bắc cầu 2 lane ⇒ **hai task**, nối bằng cột *Cần xong trước* ([§8](../../CLAUDE.md)). Nửa FE là `T-FE-10` |
| `T-23` … `T-30`, `T-65` — 9 dòng task FE đang sống ở sổ chung | [/task.md](../../task.md) | Dời chúng sang đây là sửa file lane khác. Ranh giới + cách dời: [task_FE.md §Ranh giới](task_FE.md#ranh-giới-với-taskmd) |

## Luật đóng của lane này

Dùng nguyên 5 luật đóng ở [/finding.md](../../finding.md) + [quality/finding_guiline.md](../../quality/finding_guiline.md).
Ba điều nhắc lại vì lane FE vướng nhất:

1. **Biên nhận đang là biên nhận vay.** `npm run build` / `tsc --noEmit` **chưa chạy được** — `fe/` không có
   `package.json` ([F-59](../../finding.md#f-59), [F-30](../../finding.md#f-30)). Tới khi `T-23` xong, đóng
   finding ở đây dùng **lệnh đọc lại** ([§8](../../CLAUDE.md)) và **phải ghi rõ là vay**.
2. **Từ lúc `T-23` xong, `fe/` thắng cả bốn file tài liệu** ([README §3 phép D](README.md)). Finding nào còn
   `🔓 MỞ` lúc đó phải **kiểm lại bằng code** trước khi tin mô tả của chính nó.
3. **Đóng phải để lại một dòng `**Bài học giữ lại:**`** — luật nào đổi để nó không tái phát. Bảy dòng trên
   cùng một bài học đang chờ được rút; rút được rồi thì nó thuộc về [02-luat.md](02-luat.md), không phải về đây.
