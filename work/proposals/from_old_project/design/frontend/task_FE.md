# Sổ task — lane FE

> Cập nhật **2026-08-18** · Lane sở hữu: **FE** · Sổ **task** của riêng lane này.
> Sổ **finding** của lane: [finding_FE.md](finding_FE.md). Sổ của lane khác: xem
> [CLAUDE.md §2](../../CLAUDE.md) — lane chưa tách vẫn dùng [/task.md](../../task.md).
> **File này đo *xong / chưa*, không đo *đúng / sai*** — cái đang sai đi sổ finding ([§7](../../CLAUDE.md)).
> **Không chép lý do vào đây.** Bảng task chỉ giữ: việc · thứ tự · biên nhận · trạng thái.
> *Vì sao* từng dòng tồn tại: dòng nào **đóng một finding** thì lý do ở mục `### F-FE-xx` của
> [finding_FE.md](finding_FE.md); dòng nào **xây cái mới** thì ở mục [Giải thích từng task](#giải-thích-từng-task--task-này-thực-ra-làm-gì) bên dưới ([§2.1](../../CLAUDE.md)).

## Làm gì tiếp

```bash
grep -n '^| \*\*T-FE-' design/frontend/task_FE.md | grep -v '~~' | head -1   # dòng chưa xong đầu tiên
```

Lấy dòng đó **nếu cột *Cần xong trước* đã xong**; chưa xong thì lùi về dòng nó chờ.
Task xong mở đầu bằng `| ~~**T-FE-` nên tự bị bỏ qua.

## Ranh giới với /task.md

**Sổ này KHÔNG nhận 9 dòng FE đang sống ở sổ chung**: `T-23` … `T-30` (dựng app → 3 luồng E2E) và `T-65`
(luật hiện/ẩn *Lượng nhân*). Chúng ở lại [/task.md](../../task.md) cho tới khi có một task NON-CODE dời hẳn.
Lý do: dời chúng sang đây là **sửa file của lane khác** ([§2.4](../../CLAUDE.md)), và nửa vời thì đẻ ra
hai sổ cùng giữ một sự thật — đúng thứ [§2](../../CLAUDE.md) cấm.

⇒ **Luật đọc:** thứ tự thi công thật = `/task.md` (T-23…T-30) **hợp** file này. Cột *Cần xong trước* dưới đây
trỏ thẳng sang mã `T-xx` của sổ chung khi cần, và đó là con trỏ hợp lệ — không phải chép.

**ID:** `T-FE-xx`, đánh số trong file này, độc lập với `T-xx` của sổ chung. Số kế tiếp:

```bash
grep -o 'T-FE-[0-9]*' design/frontend/task_FE.md | sort -u | tail -1
```

## Bảng task

Toàn bộ 19 dòng sinh ra từ một lần đối chiếu `design/frontend/` với **Next.js 16.3** ngày `2026-08-18`
(gốc: [finding_FE.md §Nguồn chung](finding_FE.md)). **Chưa dòng nào được làm.**

**Biên nhận đang là biên nhận vay.** `npm run build` / `tsc --noEmit` chưa chạy được — `fe/` không có
`package.json` ([F-59](../../finding.md#f-59)). Dòng nào cột *Biên nhận* ghi 📄 là **lệnh đọc lại** vay của
lane NON-CODE ([04 §Biên nhận](04-yeu-cau.md)); ghi 🟢 là lệnh thật, và **chỉ chạy được sau `T-23`**.

### Nhóm A — sửa chữ, làm được ngay, không cần `T-23`

| ID | Việc | Chạm | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì |
|---|---|---|---|---|---|
| **T-FE-01** 🔺 | Đăng ký hai sổ mới của lane vào bản đồ: một dòng ở [CLAUDE.md §2](../../CLAUDE.md) (bảng *một sự thật một nhà*) + một dòng ở [README.md §1](README.md) (bảng *ghi vào file nào*) | `CLAUDE.md`, `design/frontend/README.md` | — | 📄 `grep -c 'task_FE\|finding_FE' CLAUDE.md` ≥ 1 **và** `wc -l CLAUDE.md` ≤ 175 | Hai sổ tồn tại mà bản đồ không biết ⇒ session sau vẫn ghi task FE vào `/task.md`, ba tháng sau hai sổ không sổ nào thắng |
| **T-FE-02** 🔺 | Chốt **FE nằm ở `fe/` hay `code/fe/`** sau khi BE dời sang `code/be/`, sửa `.gitignore` theo (đóng [F-FE-08](finding_FE.md#f-fe-08)) | `.gitignore`, `design/frontend/03-hien-trang.md` | — | 📄 `git check-ignore -v <đường-dẫn-đã-chốt>/.next/x` ra đúng 1 dòng | `next build` đẻ `.next/` **không bị ignore** ⇒ hàng chục nghìn file build lọt vào commit đầu tiên của FE |
| **T-FE-03** | Sửa lệnh `create-next-app` ở `01 §4.1` (thêm `--yes`, xử `--agents-md`) + ghi 3 ngưỡng Node ≥ 20.9 / TS ≥ 5.1 / trình duyệt 111+ (đóng [F-FE-05](finding_FE.md#f-fe-05)) | `design/frontend/01-thiet-ke.md`, `02-luat.md` | — | 📄 `grep -c '\-\-yes' design/frontend/01-thiet-ke.md` = 1 **và** `grep -c 'Safari 16.4' design/frontend/02-luat.md` = 1 | `T-23` treo ở prompt tương tác, trông y như mạng chậm; và `fe/CLAUDE.md` do máy sinh mọc cạnh bản đồ repo |
| **T-FE-04** | Thêm `proxy.ts` vào cây route `01 §4.2` + mẫu `await params` + 1 dòng bẫy ở `02 §8` (đóng [F-FE-03](finding_FE.md#f-fe-03), [F-FE-06](finding_FE.md#f-fe-06)) | `design/frontend/01-thiet-ke.md`, `02-luat.md` | — | 📄 `grep -c 'proxy.ts' design/frontend/01-thiet-ke.md` ≥ 1 **và** `grep -c 'await params' design/frontend/*.md` ≥ 1 | Người lạ gõ thẳng `/admin/reports` vào được giao diện chủ quán; mọi mẫu route động copy trên mạng đều sai |
| **T-FE-05** | Sửa mẫu Zustand `persist` ở `01 §4.4`: `skipHydration: true` + `rehydrate()` trong effect, kèm 1 câu *vì sao* ở `02 §6` (đóng [F-FE-04](finding_FE.md#f-fe-04)) | `design/frontend/01-thiet-ke.md`, `02-luat.md` | — | 📄 `grep -c 'skipHydration' design/frontend/01-thiet-ke.md` = 1 | Giỏ hàng nháy một cái rồi rỗng sau reload. Khách không báo lỗi, khách bỏ đi |
| **T-FE-06** | Bỏ `axios` khỏi `01 §4.1`, chốt `openapi-fetch` + sửa sơ đồ `02 §2` cho khớp (đóng [F-FE-07](finding_FE.md#f-fe-07)) | `design/frontend/01-thiet-ke.md`, `02-luat.md` | — | 📄 `grep -c axios design/frontend/*.md` = 0 | Hợp đồng API có nhà thứ hai viết tay; BE đổi tên trường mà FE không đỏ — đúng thứ `02 §2` hứa sẽ chặn |
| **T-FE-07** | Chốt **ranh giới RSC ↔ Client theo nhóm route** (khách = Server Component; `staff`/`admin` = TanStack Query + SSE), viết thành mục mới ở `01` | `design/frontend/01-thiet-ke.md` | T-FE-06 | 📄 Mỗi nhóm trong 4 nhóm route ở `§4.2` có đúng 1 dòng khai *dữ liệu lấy ở đâu*; `grep -c` = 4 | Mọi trang thành Client Component ⇒ trang `t/[token]` vượt ngưỡng 200KB và menu quá 3s trên Slow 3G — hai ngưỡng `02 §7` đã chốt |
| **T-FE-08** | Chốt **có/không bật Cache Components**; nếu có: `cacheComponents` + `partialPrefetching`, `use cache` **chỉ** cho menu/settings, `instant = false` cho `staff`/`admin` | `design/frontend/01-thiet-ke.md`, `02-luat.md` | T-FE-07 | 📄 Có mục *Cache* trong `01` nói rõ **món nào được cache, món nào không**, kèm câu chốt về `is_available` | Cache nhầm `is_available` ⇒ khách đặt món đã hết, bếp không làm được, và **không lệnh nào báo đỏ** |

### Nhóm B — chạm `fe/`, phải chờ `T-23` dựng app

| ID | Việc | Chạm | Cần xong trước | Đầu ra kiểm chứng được | Hỏng thì mất gì |
|---|---|---|---|---|---|
| **T-FE-09** | `next.config.ts`: `images.remotePatterns` + `qualities`, quyết dứt điểm chuyện IP nội bộ (đóng [F-FE-01](finding_FE.md#f-fe-01)) | `fe/next.config.ts` | `T-23`, T-FE-02 | 🟢 Một ảnh món thật hiện được ở `next dev` (dán ảnh chụp hoặc mã `200` của URL `/_next/image`) | Menu không có ảnh — với quán ăn thì ảnh **là** menu. Lỗi trả `400`, người debug đi tìm ở Go BE trước |
| **T-FE-10** | Nối ESLint chạy thật vào `package.json` + `make test-fe` (đóng [F-FE-02](finding_FE.md#f-fe-02)) | `fe/package.json`, `Makefile` ⚠️+DEVOPS | `T-23` | 🟢 Viết cố ý 1 `fetch()` không `await` ⇒ lệnh **đỏ**; xoá đi ⇒ xanh. **Dán cả hai output** ([§3](../../CLAUDE.md)) | 4 luật ở `02 §1` thành trang trí, và không lệnh nào báo rằng chúng là trang trí |
| **T-FE-11** | `output: 'standalone'` + graceful shutdown (drain 10–30s cho `SIGTERM`) | `fe/next.config.ts`, `deploy/` ⚠️+DEVOPS | `T-23` | 🟢 `docker image ls` cho FE trước/sau; `make up` rồi `curl` trang chủ ra `200` | Image FE phình, và deploy cắt ngang request đang chạy — mà luật là **không deploy trong giờ bán**, tức mọi deploy đều sau 11h, không ai thấy |
| **T-FE-12** | `next/font` với `subsets: ['vietnamese']` cho font toàn app | `fe/src/app/layout.tsx` | `T-23` | 🟢 `curl -s localhost:3000 \| grep -c 'vietnamese'` ≥ 1 | Chữ có dấu rơi về font hệ thống, nhảy layout trên điện thoại rẻ — đúng máy của khách |
| **T-FE-13** | Route handler `POST /api/revalidate` (bảo vệ bằng secret) gọi `revalidateTag('menu', 'max')` | `fe/src/app/api/revalidate/route.ts` | T-FE-08, `T-23` | 🟢 `curl -X POST` kèm secret ⇒ `200`; không secret ⇒ `401`; sau đó menu đổi trong 1 lần tải lại | Không có nó thì cache menu chỉ hết hạn theo giờ ⇒ *"món hết"* hiện sai suốt khoảng đó |
| **T-FE-14** | Reset trạng thái popup/dialog do `<Activity>` giữ lại khi bật Cache Components | `fe/src/app/staff/pos/**` (≤ 3 file) | T-FE-08, `T-28` | 🟢 E2E: mở popup chọn nhân ở bàn 5 → thoát → mở ở bàn 7 ⇒ popup **rỗng** | Nhân viên bấm nhanh 3 chạm là **gọi nhầm nhân cho bàn khác**; hoá đơn vẫn đúng nên rất lâu mới lộ |
| **T-FE-15** | Error boundary tiếng Việt bằng `catchError` (`next/error`) + nút `Thử lại` gọi `retry()` | `fe/src/app/**/error-boundary.tsx` (≤ 3 file) | `T-23` | 🟢 Test *"mất mạng khi gửi đơn"* ở [02 §5](02-luat.md) xanh, và bấm `Thử lại` fetch lại thật | Nhân viên thấy `Error 500` và không biết phải làm gì — đúng dòng cuối bảng bẫy `02 §8` |
| **T-FE-16** | Chấm đỏ **mất kết nối** trên màn hình trạm: trạng thái SSE tự quản + tự reconnect (cân nhắc `useOffline`, ghi rõ nó **không** phủ SSE) | `fe/src/app/staff/station/**` (≤ 3 file) | `T-28` | 🟢 Ngắt mạng ⇒ chấm đỏ hiện < 10s; nối lại ⇒ chấm tắt và việc mới về | Màn hình trống, nhân viên tưởng hết việc trong khi SSE đã chết ⇒ **mất đơn**. `02 §5` gọi đây là bắt buộc |
| **T-FE-17** | `app/manifest.ts` + `display: 'standalone'` cho tablet trạm/POS | `fe/src/app/manifest.ts` | `T-23` | 🟢 Thêm vào màn hình chính trên 1 tablet thật ⇒ mở ra **không còn thanh địa chỉ** | Mất ~10% chiều cao màn hình cho thanh địa chỉ, và nút bị che — đúng ô đầu bảng `02 §4` |
| **T-FE-18** | Bật React Compiler (`reactCompiler` + thử `turbopackRustReactCompiler`), **đo build time trước/sau rồi mới chốt** | `fe/next.config.ts`, `fe/package.json` | `T-23` | 🟢 Hai con số `time npm run build` trước/sau, dán cả hai; giữ nếu chấp nhận được | Không có nó cũng chạy được — bỏ qua nếu build chậm hơn đáng kể. Đây là dòng dễ bỏ nhất trong sổ |
| **T-FE-19** 🟢 | Thêm `instant()` (`@next/playwright`) vào 1 trong 3 luồng E2E | `fe/e2e/*.spec.ts` | `T-30`, T-FE-08 | 🟢 Test đỏ khi cố tình đẩy 1 `<Suspense>` lên cao | Ưu tiên thấp nhất sổ. 3 test nghiệp vụ ở `T-30` giá trị hơn nhiều |

**Ký hiệu:** 🔺 chặn dòng khác · 🟢 (cột ID) ưu tiên thấp, bỏ được · 📄 biên nhận **vay** của NON-CODE ·
🟢 (cột biên nhận) lệnh thật · ⚠️+DEVOPS chạm file lane khác ⇒ khai lane theo `04 §3` ·
`~~T-FE-xx~~ ✅` đã xong.

## Giải thích từng task — task này thực ra làm gì

> Mục này **chỉ giữ** lý do của những dòng **không đóng finding nào**. Dòng có đóng finding
> (T-FE-02…T-FE-06, T-FE-09, T-FE-10) thì lý do đã có nhà ở mục `### F-FE-xx` của
> [finding_FE.md](finding_FE.md) — chép lại ở đây là đẻ nhà thứ hai ([§2.1](../../CLAUDE.md)).

| ID | Task này thực ra làm gì · owner nhìn gì thì tin là xong |
|---|---|
| **T-FE-01** | Hai sổ này vừa ra đời nhưng [CLAUDE.md §2](../../CLAUDE.md) — bảng *một sự thật một nhà* — vẫn ghi *"lane chưa tách → task.md"* cho FE. Bản đồ không biết thì session sau vẫn đi đường cũ. Làm đúng như lane BA đã làm: thêm **một dòng**, không thêm mục, vì trần 175 dòng ở [§12](../../CLAUDE.md) là thật. **Xong khi:** mở CLAUDE.md §2, dòng *sổ task* và *sổ finding* có nhánh `FE → design/frontend/task_FE.md`. **Trả lại nếu:** CLAUDE.md vượt 175 dòng. |
| **T-FE-07** | Đây là **quyết định kiến trúc**, không phải task viết lách, và nó chặn `T-25`…`T-29` — làm sau khi đã viết màn hình thì phải viết lại. Nội dung: khách (`(shop)/`, `t/[token]/`) đọc dữ liệu **ở server**, không tải thư viện fetch xuống máy khách; `staff/`/`admin/` giữ nguyên TanStack Query + SSE vì chúng cần polling 20s và cập nhật lạc quan, còn tablet của quán thì không quan tâm bundle. Ranh giới này chính là thứ đạt được hai ngưỡng `02 §7` đã chốt. **Xong khi:** mỗi nhóm route ở `§4.2` có đúng một dòng khai *dữ liệu lấy ở đâu*. **Trả lại nếu:** câu trả lời là *"tuỳ trang"* — tuỳ trang nghĩa là chưa quyết. |
| **T-FE-08** | Next 16 lật mặc định: **mọi thứ dynamic**, cache là opt-in. Task chốt **có bật hay không**, và nếu bật thì cache **chỉ** menu + settings. Cache giá ở đây an toàn — an toàn **nhờ** ràng buộc *FE không bao giờ gửi giá, BE luôn tính lại, giỏ gọi `/orders/quote` trước checkout* ([04 §Luật 1, 3](04-yeu-cau.md)): giá cũ chỉ sai chữ hiển thị, không sai tiền thu. Nhưng `is_available` thì **không** an toàn, và đó là lý do `T-FE-13` tồn tại. **Xong khi:** mục *Cache* nói rõ món nào cache, món nào không, và câu chốt về `is_available`. **Trả lại nếu:** bật cache mà không có câu nào về `is_available`. |
| **T-FE-11** | `output: 'standalone'` đóng gói FE thành một bản chạy được gọn, hợp với bối cảnh **một VPS** đã chốt ở [§6.8 của prompt](../../project_preparation/prompt-fullstack.md). Vế thứ hai đừng bỏ: khi dừng, server cần được `SIGTERM` và **chờ 10–30 giây** cho request đang chạy xong. **Xong khi:** có hai con số kích thước image trước/sau và một lần `make up` + `curl` ra `200`. |
| **T-FE-12** | Một dòng cấu hình, hai phút, và không ai nhớ ra: font phải khai `subsets: ['vietnamese']`, nếu không chữ có dấu rơi về font hệ thống. Trang menu toàn tiếng Việt có dấu nên nó nhảy layout thấy rõ, đúng trên máy yếu của khách. |
| **T-FE-13** | Nửa FE của một mối nối 2 lane. Chủ quán bấm *"hết hàng"* ở Admin → yêu cầu đi thẳng vào Go BE, **Next không biết gì** → menu đã cache vẫn khai còn hàng. Task này dựng cái cửa để BE gọi vào. **Nửa BE phải là một dòng riêng trong [/task.md](../../task.md)** ([§8](../../CLAUDE.md)) — thiếu nó thì cửa này có mà không ai gõ. **Xong khi:** gọi có secret ra `200`, không secret ra `401`. |
| **T-FE-14** | Bẫy đi kèm `T-FE-08`: bật Cache Components thì Next giữ route ở chế độ ẩn thay vì huỷ, nên `useState` và giá trị form **không còn tự reset** khi rời trang rồi quay lại. Rơi đúng vào luồng *đặt hộ 1 suất trong 3 lần chạm*. Cách chặn tốt nhất không phải thêm code dọn dẹp mà là **suy trạng thái dialog từ URL**. **Trả lại nếu:** sửa bằng `useEffect` dọn tay ở từng chỗ — sẽ sót. |
| **T-FE-15** | `02 §5` đã ra đề: mọi lỗi phải có thông báo tiếng Việt kèm hành động, và 409 phải đọc là *"Việc này đã xong rồi"*. Next 16.3 cho công cụ đúng hình: `catchError` dựng boundary có `retry()` **fetch lại được cả phần render ở server**, và không nuốt nhầm `notFound()`/`redirect()` như `error.tsx` cũ. |
| **T-FE-16** | Dòng **quan trọng nhất nhóm B**. `02 §5` viết thẳng: *"nhân viên nhìn màn hình trống và tưởng hết việc, trong khi SSE đã chết, là kịch bản mất đơn"*. Cảnh báo một cái: hook `useOffline` của Next **không** phủ SSE và không phủ TanStack Query — nó chỉ lo điều hướng và Server Action của chính Next, và còn là tính năng experimental. Trạng thái kết nối SSE phải **tự quản**. **Trả lại nếu:** chấm đỏ chỉ dựa vào `navigator.onLine` — wifi quán có sóng mà không có internet vẫn báo `true`. |
| **T-FE-17** | Ô đầu bảng `02 §4` hỏi *"nút có bị che bởi thanh địa chỉ không"*. Cách trả lời rẻ nhất là làm nó biến mất: khai `manifest.ts` với `display: 'standalone'`, thêm vào màn hình chính của tablet. **Xong khi:** thử trên tablet thật của quán, không phải trên DevTools. |
| **T-FE-18** | React Compiler tự memo hoá component, hợp với màn hình trạm vì nó vẽ lại mỗi 20 giây cộng mỗi lần SSE đẩy việc. Nhưng nó chạy qua Babel nên **build chậm hơn**. Task này là **một phép đo rồi mới quyết**, không phải một quyết định đã có sẵn. **Trả lại nếu:** bật mà không có hai con số build time. |
| **T-FE-19** | Chống hồi quy: một trang hôm nay hiện ngay, tháng sau ai đó thêm component đọc `cookies()` vào header dùng chung là nó chậm lại mà không test nào đỏ. Helper `instant()` bắt đúng ca đó. Ưu tiên thấp nhất sổ — chỉ làm khi 3 luồng ở `T-30` đã xanh và ổn định. |

## Đối chiếu finding → task

| Finding | Task nào đóng nó |
|---|---|
| [F-FE-01](finding_FE.md#f-fe-01) — `next/image` đổi 4 mặc định, chặn ảnh từ IP nội bộ | `T-FE-09` |
| [F-FE-02](finding_FE.md#f-fe-02) — `next lint` bị xoá, `next build` không lint | `T-FE-10` |
| [F-FE-03](finding_FE.md#f-fe-03) — không có `proxy.ts`, `staff`/`admin` không ai chặn | `T-FE-04` |
| [F-FE-04](finding_FE.md#f-fe-04) — Zustand `persist` thiếu `skipHydration` | `T-FE-05` |
| [F-FE-05](finding_FE.md#f-fe-05) — lệnh `create-next-app` treo ở prompt | `T-FE-03` |
| [F-FE-06](finding_FE.md#f-fe-06) — `params`/`cookies()` là Promise, tài liệu không nói | `T-FE-04` (mẫu đầy đủ chờ `T-FE-08` chốt Suspense) |
| [F-FE-07](finding_FE.md#f-fe-07) — `axios` chống với type sinh từ OpenAPI | `T-FE-06` |
| [F-FE-08](finding_FE.md#f-fe-08) — BE dời sang `code/be/`, FE docs vẫn `fe/`, `.gitignore` lệch | `T-FE-02` |

Finding của lane FE mà **không task nào nhận** ⇒ lỗi của file này, sửa ngay tại mục trên ([§7](../../CLAUDE.md)).

## Quy tắc dùng file này

1. **Một task tại một thời điểm** ([§3](../../CLAUDE.md)). Xong thì gạch `~~`, đánh ✅, ghi ngày + biên nhận **ngay trong dòng đó**.
2. **Không mở sổ finding trong file này.** Thấy cái đang sai ⇒ [finding_FE.md](finding_FE.md) nếu lane FE phải sửa, còn lại về sổ của lane sở hữu ([§7](../../CLAUDE.md)).
3. **Dòng nào chạm file ngoài `design/frontend/` và ngoài `fe/`** (T-FE-01, T-FE-02, T-FE-10, T-FE-11) thì session đó khai lane theo [04 §3](04-yeu-cau.md) — không phải cứ mã `T-FE-` là khai lane FE.
4. **Biên nhận 📄 phải ghi rõ là vay.** Đánh ✅ mà lặng lẽ dùng biên nhận vay là khai sai biên nhận ([04 §Biên nhận](04-yeu-cau.md), [F-59](../../finding.md#f-59)).
5. Vượt kích cỡ task ([§9](../../CLAUDE.md): 1 lane · ≤ 3 file · 1 biên nhận · vừa một session) ⇒ **chẻ trước khi làm**, đánh số mới ở đây.
