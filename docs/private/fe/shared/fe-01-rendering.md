# Chọn cách render — ba mẫu S/P/R cho FE của quán

> Viết ngày **2026-10-13**: **Codex viết theo phiếu của Claude, chủ repo yêu cầu**.
> Đây là **tài liệu tham khảo**, KHÔNG là owner route/component/quy ước FE.
> Owner sinh ở pha 4 cùng `docs/product/4-fe/`, theo [CLAUDE.md §2](../../../../CLAUDE.md).
> **Khi lệch, owner thắng.** Mọi tên route FE, component, hook và query key dưới đây là **đề xuất**.
> Đường gọi BE lấy từ hợp đồng, không phải đề xuất route FE. File này chỉ chọn cách render theo nhóm; danh sách từng trang dành cho file 5, không được chốt ở đây.

## 1. Điểm xuất phát và nhóm người dùng

Stack: Next.js 16.4 App Router + TypeScript ở `fe/`; UI bằng **shadcn/ui**, đi kèm
Tailwind CSS 4 và Radix; dữ liệu server bằng **TanStack Query**, trạng thái client bằng **Zustand** — nguồn: **chủ repo chọn 2026-10-13**. Vị trí code và nền stack theo
[QC-08, QC-09](../../../product/2-db/10-quy-uoc-code.md).
Phiên bản ghim, khung test và công cụ sinh type OpenAPI **chưa chốt**, để pha 4.
Lựa chọn này cập nhật phần thư viện còn để mở trong [tài liệu Next.js](../nextjs-16-4-huong-dan-fe.md).

Các ranh giới cache, giá, danh tính và lỗi bên dưới là **đề xuất của Claude, pha 4 chốt**,
đặt ngày 2026-10-13 theo phiếu. Dữ liệu server chỉ sống trong cache TanStack Query; Zustand **không bao giờ** giữ bản sao dữ liệu server. Giỏ/nháp đơn chỉ giữ lựa chọn,
không giữ số tiền tự tính. Theo [hàm giá](../../../product/3-be/03-ham-gia.md), FE không
tính giá, không gửi giá; giá hiển thị lấy từ `GET /menu` hoặc `POST /price-quotes`.

| Nhóm màn | Nhu cầu để chọn render | Nguồn ranh giới |
|---|---|---|
| Khách | QR tại bàn, đặt online; không danh tính người quán. Có thể lấy trước dữ liệu công khai. | [Actor §1.1](../../../product/0-ba/ban-hang/01-actors-pham-vi.md), `security` từng operation trong [OpenAPI](../../../product/3-be/openapi.yaml). |
| Người quán | Quầy, trạm; dữ liệu sống. Chọn tên cho thao tác cần người; không biến mọi đường đọc trạm thành đường cần danh tính. | [Actor §1.2](../../../product/0-ba/ban-hang/01-actors-pham-vi.md), [vai và quyền](../../../product/3-be/02-vai-va-quyen.md). |
| Chủ quán | Sửa menu/giá, mã QR, tạm dừng nhận đơn, ngày bán/đối soát; mặc định đọc dữ liệu phía client. | [Actor §1.3](../../../product/0-ba/ban-hang/01-actors-pham-vi.md), [vai và quyền](../../../product/3-be/02-vai-va-quyen.md). |

Đây là cách gom nhu cầu giao diện, không phải ma trận quyền hay cam kết có đủ API quản trị.
[Bản chụp tính năng BE](../../be_feature/be_feature_hien_tai.md) giúp tìm domain;
[hợp đồng](../../../product/3-be/openapi.yaml) thắng bản chụp khi lệch.

## 2. Bảng chọn mẫu — đề xuất của Claude, pha 4 chốt

| Điều kiện chọn | Mẫu ổn định để file sau gọi lại | Phần server / phần client |
|---|---|---|
| Màn người quán/chủ quán; cần lựa chọn người đang bấm hoặc chưa cần SSE | **Mẫu S — shell tĩnh + client sống**, mặc định | Server dựng khung; Client Component gọi `useQuery`. |
| Dữ liệu công khai, không cần danh tính, muốn có dữ liệu trong lần render đầu | **Mẫu P — prefetch server + HydrationBoundary** | Server lấy trước theo request; client tiếp quản cache và đọc lại. Ví dụ menu, nhãn bàn từ mã QR. |
| Màn theo dõi sống có đường SSE tương ứng trong hợp đồng | **Mẫu R — realtime** | Mẫu S cộng một luồng SSE ở vùng sống lâu; tín hiệu làm query liên quan mất hiệu lực để đọc lại. |

Mẫu P không áp dụng chỉ vì một API là GET. Phải kiểm `security` của operation; `GET /counter/queue` và `/counter/events` cần danh tính theo
[OpenAPI](../../../product/3-be/openapi.yaml). Màn trạm chọn R theo nhu cầu sống dù đường đọc công khai.

## 3. Nền chung: provider và vòng đời QueryClient

Ví dụ dùng API TanStack Query v5. Các module và import nội bộ đều là **đề xuất**, chưa tồn tại.
Type và hàm gọi API sẽ sinh/viết từ hợp đồng ở pha 4; các khối dưới minh họa ranh giới, không phải ứng dụng có thể chạy riêng. `readMenu`, `readCounterQueue`, `readProductionBoard`
là adapter đề xuất: gọi đúng API, dùng `cache: 'no-store'`, trả type theo OpenAPI, và ném lỗi đã phân biệt lỗi mạng với `Error` của hợp đồng.

```tsx
// fe/src/lib/query-client.ts — module chung, không có 'use client'
import { QueryClient } from '@tanstack/react-query';

const makeQueryClient = () => new QueryClient({
  defaultOptions: { queries: { staleTime: 0 } },
});
let browserClient: QueryClient | undefined;
export function getQueryClient() {
  if (typeof window === 'undefined') return makeQueryClient();
  return (browserClient ??= makeQueryClient());
}
```

Server tạo mới mỗi lần gọi, vì vậy không chia sẻ cache giữa các request; mẫu P gọi một lần trong vùng prefetch của request. Browser giữ singleton để render lại không tạo cache rỗng.
Cách tách này theo [hướng dẫn SSR của TanStack Query](https://tanstack.com/query/v5/docs/framework/react/guides/advanced-ssr).

```tsx
// fe/src/app/providers.tsx
'use client';
import type { ReactNode } from 'react';
import { QueryClientProvider } from '@tanstack/react-query';
import { getQueryClient } from '@/lib/query-client';

export function Providers({ children }: { children: ReactNode }) {
  return <QueryClientProvider client={getQueryClient()}>{children}</QueryClientProvider>;
}
```

Layout server đề xuất đặt `Providers` quanh vùng cần query; đặt khung tĩnh bên ngoài vùng tải.
`staleTime: 0` chỉ đánh dấu dữ liệu có thể cũ, **không tự tạo nhịp refetch** và không bảo đảm
giá đổi lập tức xuất hiện. Cần invalidate/refetch theo §6 và chốt đường báo đổi menu ở §8.

## 4. Mẫu S — shell tĩnh + client sống

Khung server không đọc dữ liệu theo người. Client nhận lựa chọn tên sau khi browser sẵn sàng, rồi mới bật query cần danh tính. Khối client này nằm dưới `Providers` của layout.

```tsx
// Server Component, tên đề xuất
import { CounterClient } from '@/features/counter-client';
export default function CounterShell() {
  return <main><h1>Quầy</h1><CounterClient /></main>;
}
```

```tsx
// fe/src/features/counter-client.tsx
'use client';
import { useQuery } from '@tanstack/react-query';
import { useChosenPersonId, readCounterQueue } from '@/lib/counter';
import { CounterView, QueryProblem } from '@/components/data-views';

export function CounterClient() {
  const personId = useChosenPersonId(); // chưa sẵn sàng thì trả null
  const query = useQuery({
    queryKey: ['counter-queue', personId], // đề xuất; tách cache theo người
    queryFn: ({ signal }) => readCounterQueue(personId!, { signal }),
    enabled: personId !== null,
  });
  if (personId === null) return <p>Chọn tên để tiếp tục.</p>;
  if (query.isPending) return <p role="status">Đang đọc dữ liệu…</p>;
  if (query.isError) return <QueryProblem error={query.error} />;
  return <CounterView data={query.data} />;
}
```

Adapter quầy gửi `X-Person-Id` theo `PersonIdentity`; đây là **chọn tên, không phải đăng nhập**.
`QueryProblem` đề xuất chọn câu từ `ErrorCode`, không suy từ HTTP status hay chữ database, theo [hợp đồng §3](../../../product/3-be/01-hop-dong-api.md).
Mẫu S ở đây chỉ minh họa cách render; màn quầy thực tế cần thêm R để giữ luồng.

## 5. Mẫu P — lấy trước dữ liệu công khai

Server lấy menu theo request, chuyển cache qua `dehydrate`; `MenuClient` dùng cùng key.
Dùng `Suspense` để tách phần đọc động khỏi shell khi bật Cache Components như
[tài liệu Next.js](../nextjs-16-4-huong-dan-fe.md) mô tả.

```tsx
// Server Component; mọi tên nội bộ là đề xuất
import { Suspense } from 'react';
import { dehydrate, HydrationBoundary } from '@tanstack/react-query';
import { getQueryClient } from '@/lib/query-client';
import { readMenu } from '@/lib/menu-api';
import { MenuClient } from '@/features/menu-client';

async function PrefetchedMenu() {
  const client = getQueryClient(); // mới trong request này
  await client.prefetchQuery({ queryKey: ['menu'], queryFn: readMenu });
  return <HydrationBoundary state={dehydrate(client)}>
    <MenuClient />
  </HydrationBoundary>;
}
export default function MenuShell() {
  return <main><h1>Menu</h1><Suspense fallback={<p>Đang đọc menu…</p>}>
    <PrefetchedMenu />
  </Suspense></main>;
}
```

```tsx
// fe/src/features/menu-client.tsx
'use client';
import { useQuery } from '@tanstack/react-query';
import { readMenu } from '@/lib/menu-api';
import { MenuView, QueryProblem } from '@/components/data-views';
export function MenuClient() {
  const query = useQuery({ queryKey: ['menu'], queryFn: readMenu });
  if (query.isPending) return <p>Đang đọc menu…</p>;
  if (query.isError) return <QueryProblem error={query.error} />;
  return <MenuView data={query.data} />;
}
```

Prefetch lỗi có thể để client tải lại; vẫn cần nhánh pending/error. Với QR, key đề xuất phải chứa mã đang đọc và adapter gọi `GET /qr-codes/{code}` theo [hợp đồng](../../../product/3-be/openapi.yaml).
Không bọc giá bằng `'use cache'`, không đặt thời gian sống dài: giá đổi phải hiện ngay sau
khi đọc lại. Cơ chế để mọi màn khách biết giá vừa đổi **chưa xác định**, cần pha 4 chốt.

## 6. Mẫu R — tín hiệu đọc lại và đường kéo dự phòng

Theo [owner realtime §3](../../../product/3-be/09-realtime-du-phong.md), `hello` và `changed`
đều dẫn tới đọc lại; `heartbeat` phục vụ theo dõi luồng. Không dùng payload sự kiện vá cache,
không `setQueryData` từ SSE. Hook đề xuất dưới minh họa **luồng trạm công khai**:

```tsx
'use client';
import { useEffect, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
export function useProductionEvents(eventsUrl: string) {
  const client = useQueryClient();
  const [connected, setConnected] = useState(false);
  useEffect(() => {
    setConnected(false);
    const source = new EventSource(eventsUrl); // URL GET /production-board/events
    const reread = () => { void client.invalidateQueries({ queryKey: ['production-board'] }); };
    const hello = () => { setConnected(true); reread(); };
    const heartbeat = () => setConnected(true);
    source.addEventListener('hello', hello);
    source.addEventListener('changed', reread);
    source.addEventListener('heartbeat', heartbeat);
    source.onerror = () => setConnected(false);
    return () => source.close();
  }, [client, eventsUrl]);
  return connected;
}
```

Mount hook một lần trong vùng sống của màn; URL là cấu hình pha 4, chưa chốt origin/proxy.
`connected` chỉ là trạng thái transport cục bộ, không phải dữ liệu nghiệp vụ trong Zustand.
Payload không chỉ ra domain thay đổi; đề xuất invalidate các nhóm key có thể bị ảnh hưởng trong màn, kể cả menu/bàn nếu màn đang dùng chúng, không đoán từ payload.
Query vẫn tự kéo theo `poll_interval_seconds` của đường đọc, kể cả khi SSE mất:

```tsx
const query = useQuery({
  queryKey: ['production-board'],
  queryFn: readProductionBoard,
  refetchInterval: (q) => q.state.data
    ? q.state.data.poll_interval_seconds * 1000 : bootstrapPollMs,
  refetchIntervalInBackground: true,
});
```

`bootstrapPollMs` là cấu hình đề xuất **chưa xác định**, pha 4 lấy theo owner realtime, không đặt con số riêng ở từng màn. Hiển thị mất luồng, lỗi đọc và mốc `read_at`;
không biến lỗi đọc thành danh sách rỗng. Chi tiết theo [yêu cầu dự phòng §1](../../../product/1-system-design/05-realtime-va-du-phong.md).
Mốc/ngày bán và dấu lần gửi đọc [hợp đồng §6, §8](../../../product/3-be/01-hop-dong-api.md);
refetch không được tự phát lại thao tác ghi.

**Riêng quầy:** theo [owner realtime §2–§3](../../../product/3-be/09-realtime-du-phong.md),
luồng quầy mở là điều kiện nhận đơn tự bấm; quán “mù” khi không còn luồng quầy.
Đề xuất giữ luồng mở suốt ca ở vùng không bị tháo khi đổi phần nội dung, và báo rõ khi mất luồng.
Đường kéo không thay điều kiện này; nối lại không tự gọi cửa mở lại nhận đơn.
`EventSource` native không gửi header tùy ý; [API constructor](https://developer.mozilla.org/en-US/docs/Web/API/EventSource/EventSource)
không có tùy chọn header. Cách mang `X-Person-Id` cho `/counter/events` theo
[`PersonIdentity`](../../../product/3-be/openapi.yaml) **chưa xác định**; không tự chọn query param/cookie.

## 7. Ranh giới Server/Client và cache Next.js

Đề xuất của Claude: dữ liệu tiền, đơn, bàn, trạm không dùng ISR/`revalidate` hoặc `'use cache'`.
Cache HTML/RSC độc lập có thể giữ bản cũ dù TanStack Query đã invalidate; cache Query là nơi duy nhất quản lý dữ liệu server phía FE. Hydration chỉ chuyển dữ liệu ban đầu, không làm nó bất biến.
Cache Components và Partial Prefetching giúp tách khung, hoãn phần động; chúng không thay
SSE/refetch. `ensureStatic` gần như không dùng cho các nhóm màn này; không đặt ở layout
bao trùm dữ liệu sống. Chi tiết API theo [tài liệu Next.js](../nextjs-16-4-huong-dan-fe.md).

Server Component không đọc Zustand/localStorage, không biết người đang bấm. Client Component
cũng có thể render ban đầu ở server: chỉ đọc browser storage sau mount/hydration, giữ lần render
đầu nhất quán. Hook chọn tên phải tuân thủ ranh giới này; cách lưu lựa chọn còn để pha 4 chốt.
Ẩn nút phía client không cấp quyền; [owner quyền](../../../product/3-be/02-vai-va-quyen.md) quyết định.

## 8. Câu hỏi còn mở

Các điểm **chưa xác định** dưới đây dành cho Claude/pha 4, không tự sửa owner trong lượt này.

1. Chọn transport nào mang `X-Person-Id` cho SSE quầy, và URL/origin/proxy/CORS nào cho FE gọi BE?
2. Màn khách nhận tín hiệu đổi menu/giá thế nào để đọc lại ngay? Nếu muốn cache thêm, cơ chế vô hiệu hóa nào bảo đảm không giữ giá cũ?
3. Chốt mapping tín hiệu → query key, cấu hình kéo ban đầu, phát hiện thiếu heartbeat và xử lý browser ngủ/tab nền thế nào?
4. Lưu lựa chọn tên và dọn cache theo người khi đổi tên thế nào? Owner FE nào nhận các thiết kế S/P/R này?
5. Ghim phiên bản thư viện, khung test và công cụ sinh type nào? API thiếu cho nhu cầu phát sinh phải giao lát BE nào, thay vì FE tự dựng dữ liệu?

## 9. Liên kết

[Tài liệu Next.js 16.4](../nextjs-16-4-huong-dan-fe.md) · [Hợp đồng API](../../../product/3-be/01-hop-dong-api.md)
· [OpenAPI](../../../product/3-be/openapi.yaml) · [Hàm giá](../../../product/3-be/03-ham-gia.md)
· [Realtime BE](../../../product/3-be/09-realtime-du-phong.md).
Bộ hướng dẫn: [fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [fe-03-state-management](fe-03-state-management.md) · [fe-04-shared-components](fe-04-shared-components.md); danh sách trang (fe-05-danh-sach-trang.md) viết sau.
