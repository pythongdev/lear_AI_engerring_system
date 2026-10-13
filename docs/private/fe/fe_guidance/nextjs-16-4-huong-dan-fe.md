# Next.js 16.4 — tài liệu tham khảo để bắt đầu FE ở pha 4

> Viết ngày **2026-10-13** bởi **Codex theo phiếu của Claude, chủ repo yêu cầu**.
> Nguồn Next.js duy nhất: [blog Next.js 16.4](https://nextjs.org/blog/next-16-4),
> phát hành **2026-10-06**, qua bản Claude tải và chép lại ngày 2026-10-13.
> Đây là **tài liệu tham khảo**, KHÔNG là owner của route, component hay quy ước FE nào.
> Owner route/component chưa có; sinh ở pha 4 cùng `docs/product/4-fe/`, theo
> [CLAUDE.md §2](../../../../CLAUDE.md). Khung test FE và lựa chọn phiên bản ghim chốt ở pha 4
> theo [quy ước code, QC-09](../../../product/2-db/10-quy-uoc-code.md);
> phiên bản cụ thể được ghim trong file `package.json` trong `fe/`, quy ước test bổ sung vào owner quy ước code.
> **Khi lệch, owner thắng.** Các đề xuất bên dưới không cho phép phiên AI tự chốt thay Claude/chủ repo.

## 1. Next.js 16.4 có gì theo nguồn đã cung cấp

### Cache Components

Nguồn khuyến nghị mô hình Cache Components cho mọi ứng dụng từ 16.4; ứng dụng mới do
`create-next-app` từ 16.4 tạo bật sẵn, và mô hình sẽ thành mặc định ở Next.js 17.
Hai cờ là `cacheComponents: true` và `partialPrefetching: true` trong `next.config.ts`.
Partial Prefetching được giới thiệu ở 16.3, nay được coi là một phần của mô hình này.

`'use cache'` được nguồn ví như `Cache-Control` ở cấp component; `cacheLife('hours')`
từ `next/cache` là ví dụ khai thời gian sống. UI được cache ở trình duyệt khi điều hướng
client, và có thể ở server khi render hoặc trước lúc build. Mô hình này thay hành vi
cache ngầm của App Router cũ. Component đọc dữ liệu theo request, chẳng hạn người hiện tại,
đặt trong `<Suspense>`. Nguồn cũng nhắc `params` là Promise. Ví dụ thời gian sống theo giờ
trong nguồn chỉ minh hoạ API, không phải thời gian cache được chọn cho quán.

### `ensureStatic`

Đây là route segment config mới, khai trên page hoặc layout bằng
`export const ensureStatic = 'navigation'`, hoặc giá trị `'prefetch'`, `'shell'`.
`'navigation'` chặt nhất: build thất bại nếu page có nội dung dynamic, để điều hướng
không render lúc request. `'prefetch'` giới hạn prefetch tường minh chỉ lấy nội dung static;
`'shell'` giới hạn nội dung static khi route lần đầu được phát hiện.
Đặt ở layout thì áp cho mọi page bên trong; có thể chuyển cấu hình xuống layout con
khi có page cần dynamic. Nguồn nói nhiều ứng dụng động sẽ không cần tính năng này.

### `navigation()` và `prefetch()`

Hai API mới thuộc `next/cache`. `<Link prefetch>` và `useRouter().prefetch()` prerender UI
đã cache trước khi điều hướng. `await navigation()` trong component loại nội dung cache
đó khỏi prefetch, hoãn tới điều hướng thật; component đặt trong `<Suspense>`.
`await prefetch()` loại nội dung cache khỏi shell của route, hoãn tới prefetch tường minh.
Hai API có thời điểm hoãn khác nhau, không nên dùng thay nhau chỉ vì tên gần giống.

### Công cụ cho agent

Lệnh `next upgrade --agent` được nguồn minh hoạ đầy đủ là
`npx next@canary upgrade --agent=latest`: agent chọn bản đích, đi theo hướng dẫn migration,
chạy codemod và kiểm tra. `experimental.agentUpgrade` nhận `'security'`, `'latest'` hoặc
`false`, nhắc nâng cấp khi chạy `next dev`/`next build`; mặc định là `'security'`.

`experimental.agentFeedback: true` cho agent soạn nháp báo lỗi framework, cần người duyệt
trước khi gửi, cần Telemetry bật và không chạy trong CI. Cài đặt khuyến nghị của
`create-next-app` bật sẵn mục này. Đây không phải quyền tự gửi báo cáo từ repo.

Nguồn giới thiệu skills áp dụng Cache Components và Partial Prefetching tại
[hướng dẫn AI agents](https://nextjs.org/docs/app/guides/ai-agents), cùng skill
`next-bundle-optimizer`: cài bằng `npx skills add vercel/next.js --skill next-bundle-optimizer`,
sau đó gọi `/next-bundle-optimizer`. Chỉ mục docs cho LLM là
[/docs/llms.txt](https://nextjs.org/docs/llms.txt). Các URL này là con trỏ từ nguồn,
chưa được phiên viết tài liệu này truy cập để bổ sung tính năng.

### Cải tiến tự có và React 19.3

Không cần cấu hình thêm để nhận disk cache Turbopack nhỏ hơn 20–25% nhờ Zstandard và LZ4,
lazy server HMR chỉ compile cập nhật server khi request cần, và Turbopack shared runtime
cho các route dùng chung một chunk runtime. Bundle production nhỏ hơn nhờ tên class
CSS Module ngắn hơn và export mangling.

Theo nguồn, React 19.3 có View Transitions và Fragment Refs ổn định, cùng API `browser()`
mới; nguồn trỏ [bài React 19.3](https://react.dev/blog/2026/09/09/react-19-3).
Bản chép không mô tả cách dùng chi tiết nên tài liệu này không suy diễn thêm API đó.

### Các thử nghiệm

Các mục sau giữ nhãn experimental của nguồn; số đo là số nguồn công bố, không phải kết quả đo ở repo:

- Rust React Compiler cần `reactCompiler: true` cùng `experimental.turbopackRustReactCompiler: true`; nguồn nêu giảm bộ nhớ 30% và thời gian compile 15%.
- `experimental.turbopackGc: true` dọn cache compile không còn dùng.
- `experimental.turbopackLazyDynamicImports: true` chỉ compile dynamic import phía client khi trình duyệt yêu cầu; một số `next/dynamic` vẫn compile sớm.
- `experimental.turbopackPluginRuntimeStrategy: 'workerThreads'` hiện tự lùi về child process trên Node.js ≥ 24.13.1 do lỗi Node được nguồn ghi là `nodejs/node#65100`.
- `experimental.turbopackAdditionalRoots: { linkedPackages: { path: ... } }` theo symlink ngoài project root, phục vụ tích hợp tay global virtual store của pnpm/Bun/Nub/aube.
- Turbopack Bundle Analyzer có trang tóm tắt route lớn nhất, bảng sắp xếp, snapshot và diff, đánh dấu module trên critical render path. Bản chép không nêu cờ bật riêng cho mục này.

Nguồn còn nêu hai đường nâng cấp: `npx next@canary upgrade --agent=latest` hoặc
`npm install next@latest`. Đây là lệnh được nguồn giới thiệu, không phải quyết định đổi
phiên bản của dự án; nhãn `latest` không cố định ở 16.4.

## 2. Áp vào dự án này

### Khởi tạo và cấu hình — đề xuất, chưa chốt

[QC-08 và QC-09](../../../product/2-db/10-quy-uoc-code.md) đặt frontend ở `fe/`, có
file `package.json` trong `fe/`, dùng Next.js + TypeScript trên Node 24 LTS. Phiên mở pha 4 cần chốt
bản patch, công cụ quản lý gói và khung test trước khi dựng; không tạo package ở gốc
chỉ để bộ kiểm hiện tại tìm thấy. QC-09 lưu ý bộ kiểm Node hiện còn tìm package ở gốc,
vì vậy pha 4 cần nối phép kiểm với vị trí FE thật.

Lệnh sau là **gợi ý thao tác từ kiến thức nền, kiểm lại docs/CLI trước khi chạy**,
không phải lệnh được trích từ bản nguồn 16.4. Chạy từ gốc repo, sau khi pha 4 duyệt
App Router và bản khởi tạo; lựa chọn thư viện trong trình hỏi đáp vẫn phải theo quyết định pha 4:

```sh
npx create-next-app@16.4 fe --typescript --app
```

`@16.4` chỉ giới hạn dòng khởi tạo, chưa ghim một patch cụ thể. Sau khởi tạo, đối chiếu
file `package.json` trong `fe/` và lockfile với bản đã duyệt. Cấu hình `next.config.ts` khởi đầu
**đề xuất** dưới đây dùng đúng hai cờ mô hình cache của nguồn, chưa đặt chính sách cache cho dữ liệu:

```ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  cacheComponents: true,
  partialPrefetching: true,
};

export default nextConfig;
```

Đề xuất không bật thêm cờ experimental để chưa phải nhận thêm biến số khi dựng nền FE.
Riêng `turbopackPluginRuntimeStrategy` lùi về child process trên Node ≥ 24.13.1,
nên với các bản Node đó không có lợi ích worker threads để bật cờ này.
Cần rà cấu hình do trình khởi tạo sinh, đặc biệt `agentFeedback`, trước khi nhận vào repo.

### Type và lỗi đi từ hợp đồng

Sinh type từ [openapi.yaml](../../../product/3-be/openapi.yaml), theo
[luật đọc hợp đồng](../../../product/3-be/01-hop-dong-api.md); công cụ sinh type do pha 4 chọn.
**Hợp đồng thắng code.** FE không tự đặt mã lỗi hoặc lấy danh sách API trong prompt cũ.
Đọc khuôn `Error` và `ErrorCode` ngay trong hợp đồng: `code` bắt buộc, `field` có thể vắng;
chữ cho người dùng là việc pha 4 thiết kế theo mã, không suy từ HTTP status hay chữ lỗi database.
Đề xuất có phép kiểm type sinh lại không lệch hợp đồng, để thay đổi API được phát hiện sớm.

### Tiền, giá và hệ quả cho cache

FE **không tính giá, không gửi giá**; hiển thị kết quả BE trả, theo
[hàm giá](../../../product/3-be/03-ham-gia.md) và
[hợp đồng API §5](../../../product/3-be/01-hop-dong-api.md).
Không dùng ví dụ cache theo giờ của Next.js làm chính sách cho giá của quán.

**Suy luận áp dụng của Codex ngày 2026-10-13, quyết định cuối thuộc pha 4:** dữ liệu chạm tiền,
đơn và trạng thái bàn/trạm là dữ liệu sống; không bọc `'use cache'` dài hạn.
Kết quả cũ có thể làm người thao tác nhìn sai tình hình dù BE vẫn kiểm khi ghi.
Pha 4 cần chốt cách đọc lại, làm mất hiệu lực cache và xử lý mất kết nối cho từng loại dữ liệu,
cả cache UI lẫn cache dữ liệu nếu chọn thư viện quản lý truy vấn.

### Chọn độ tĩnh và thời điểm prefetch

**Nhận định áp dụng, chưa phải quy ước FE:** phần lớn màn của quán như quầy, trạm, quản trị
là động nên `ensureStatic` hiếm có ích. Chỉ có thể cân nhắc cho trang công khai thuần tĩnh
nếu pha 4 thực sự có nhu cầu đó; tài liệu này không đặt ra trang hay route nào.
Không đặt `ensureStatic` ở layout bao trùm rồi vô tình ép phần động phải tĩnh.

**Đề xuất áp dụng:** rà `<Link prefetch>` ở nơi đi tới màn tải dữ liệu nặng vì prefetch
có thể làm việc trước khi người dùng cần. Nếu phần UI đã cache quá nặng, cân nhắc
`navigation()` trong `<Suspense>` để hoãn tới điều hướng thật, rồi đo lại.
`prefetch()` phù hợp thời điểm prefetch tường minh theo nguồn, không thay cho chính sách
làm mới dữ liệu sống và không tự bảo đảm dữ liệu tiền còn mới.

### Danh tính, quyền, CORS và cổng — quan sát hiện trạng

Code server chọn `authz.ChonTen{}` tại
[be/cmd/server/main.go:33](../../../../be/cmd/server/main.go#L33);
router gắn `GanNguoi` tại [be/cmd/server/router.go:37](../../../../be/cmd/server/router.go#L37).
Middleware gọi `auth.PersonID(c.Request)` rồi gắn danh tính vào context tại
[be/internal/middleware/nguoi.go:12](../../../../be/internal/middleware/nguoi.go#L12),
không tự kiểm quyền; chú thích đầu file nói quyền được kiểm trong giao dịch của cửa.
Đối chiếu mục `components.securitySchemes.PersonIdentity` trong [openapi.yaml](../../../product/3-be/openapi.yaml), cơ chế hiện tại là
chọn tên và gửi header `X-Person-Id`, không phải phiên đăng nhập bằng cookie hay mật khẩu.
Định dạng giá trị và trường hợp áp dụng đọc `securitySchemes.PersonIdentity` cùng `security`
của từng operation; không tự áp header cho tất cả đường gọi.
Quyền phải đọc [owner vai và quyền](../../../product/3-be/02-vai-va-quyen.md), không suy từ việc
FE có ẩn nút hay không. Tài liệu này không chép ma trận quyền.

Trong hai thư mục code được giao đọc, chưa thấy middleware CORS hoặc thiết lập
`Access-Control-*`; router đăng ký middleware `GanNguoi` tại
[be/cmd/server/router.go:37](../../../../be/cmd/server/router.go#L37).
**Cấu hình CORS cho FE triển khai: chưa xác định**; không suy rộng rằng tầng proxy bên ngoài
cũng không có CORS. Server lấy `BANHCUON_ADDR`, mặc định `:8080`, tại
[be/cmd/server/main.go:23](../../../../be/cmd/server/main.go#L23).
Hợp đồng hiện không khai `servers`; vì vậy chưa lấy được URL kết nối FE từ mục đó.
**Đề xuất pha 4:** chốt cùng origin/proxy hay gọi khác origin, rồi kiểm đường gọi thực tế,
bao gồm header danh tính và kết nối realtime, trước khi viết lớp gọi API.

### Thư viện để pha 4 xem xét — đề xuất, chưa chốt

[prompt-fullstack.md §3.4](../../../../master_plan/prompt-fullstack.md) có tiêu đề cũ “Stack đã chốt”,
nhưng banner của chính mục nói phần còn lại chỉ là đề xuất; QC-09 cũng nhắc phải đọc lại.
Các ứng viên FE bên dưới **chưa được tài liệu này thông qua**:

- Tailwind 4 cho phần trình bày.
- Zustand cho trạng thái phía client.
- TanStack Query cho truy vấn và cache dữ liệu.
- Zod cho kiểm tra dữ liệu.
- SSE cho kết nối realtime; đây là cơ chế, không phải tên thư viện. Cách tích hợp FE phải theo hợp đồng API hiện hành.

Các vai trò thư viện ở trên là gợi ý áp dụng, không có nghĩa FE cần dùng tất cả.
App Router cũng là hướng đề xuất của §3.4, cần được pha 4 ghi nhận trước khi dùng lệnh khởi tạo.

## 3. Checklist cho phiên AI mở pha 4

1. Đọc `AGENTS.md`, `CLAUDE.md`, chạy `./scripts/brief.sh`; đọc task, scope và owner liên quan mà brief chỉ tới. Kiểm tra nhánh, thay đổi sẵn có và vai trò người quyết định; không tự đặt mã task mới từ tài liệu này.
2. Đọc hàng Route, component trong `CLAUDE.md` §2 và QC-08/QC-09. Claude mở owner pha 4 cùng nội dung đầu tiên theo quy tắc ranh giới pha; không coi tên hay ví dụ trong tài liệu private là quyết định.
3. Đọc `01-hop-dong-api.md`, `openapi.yaml`, `02-vai-va-quyen.md`, `03-ham-gia.md` trong `docs/product/3-be/`. Theo pointer owner khi cần luật; kiểm lại code kết nối BE hiện tại, không lấy snapshot tài liệu này thay hợp đồng.
4. Trước khi viết code, trình Claude/chủ repo chốt phiên bản ghim, trình quản lý gói, khung test và cách gate chạy trong `fe/`; ghi quy ước và phép kiểm thành QC mới hoặc cập nhật QC liên quan trong owner quy ước code. Chốt cả công cụ sinh type, thư viện được nhận, mô hình gọi API/danh tính, cache và realtime trong owner phù hợp; không tự cấp số QC ở đây.
5. Khi scope triển khai đã được giao, khởi tạo `fe/` có file `package.json` trong `fe/`, ghim bản đã duyệt, rà cấu hình agent/Telemetry, sinh type từ hợp đồng. Dựng route/component theo owner pha 4, không theo ví dụ private hay prompt cũ.
6. Chạy kiểm tra FE đã được chốt, kiểm type và hành vi gọi BE, rồi chạy `./scripts/gate.sh` và đọc từng PASS/FAIL/SKIP/NOTE. Gate xanh nhưng bỏ qua Node không chứng minh FE đã được kiểm; xử lý việc nối bộ kiểm trong scope được Claude giao.
7. Đọc lại diff, bàn giao bằng chứng và phần chưa quyết cho Claude theo phiếu việc. Không tự commit hoặc sửa owner ngoài quyền được giao.

## 4. Câu hỏi còn mở — cần chủ repo/Claude quyết

Các câu dưới đây chỉ ghi tại tài liệu tham khảo này; không tạo U-XXX hay thay trạng thái
câu hỏi trong owner. Chúng hỏi cách triển khai FE, không mở lại luật nghiệp vụ đã có.

1. Pha 4 chọn patch nào của Next.js/React/Node 24, trình quản lý gói và lockfile nào; có nhận App Router cùng cấu hình Cache Components đề xuất không?
2. Khung test FE, phép kiểm type sinh và cách nối file `package.json` trong `fe/` vào gate sẽ được chốt thế nào; dùng công cụ nào sinh type từ OpenAPI?
3. Những thư viện đề xuất nào được nhận, và ranh giới trạng thái client với dữ liệu BE đặt ở đâu?
4. FE gọi BE qua cùng origin/proxy hay khác origin; cấu hình CORS, URL theo môi trường và cách giữ/truyền lựa chọn danh tính trên FE ra sao?
5. Chính sách cache, đọc lại sau thao tác và tích hợp realtime/mất kết nối được ghi ở owner FE nào, với tiêu chí dữ liệu mới ra sao?
6. Có nhu cầu trang công khai thuần tĩnh đủ để cân nhắc `ensureStatic` không; phần UI nặng nào cần hoãn prefetch sau khi đo?
7. Có giữ `agentFeedback`/Telemetry và lời nhắc nâng cấp agent không; ai duyệt báo lỗi và việc đổi phiên bản?
