# Chiến lược loading — dữ liệu đang tới, lỗi, trống và mất kết nối

> Viết ngày **2026-10-13**: **Codex viết theo phiếu của Claude, chủ repo yêu cầu**.
> Đây là **tài liệu tham khảo**, KHÔNG là owner route/component/quy ước FE.
> Owner sinh ở pha 4 cùng `docs/product/4-fe/`, theo [CLAUDE.md §2](../../../../CLAUDE.md).
> **Khi lệch, owner thắng.** Mọi tên route FE, component, hook, adapter và query key là **đề xuất**.
> Đường gọi BE và hình dữ liệu theo hợp đồng; ví dụ code chưa phải ứng dụng chạy riêng.

Stack **chủ repo chọn 2026-10-13**: Next.js 16.4 App Router + TypeScript ở `fe/`, shadcn/ui đi cùng Tailwind CSS 4 và Radix, TanStack Query cho dữ liệu server, Zustand cho trạng thái client. Vị trí và nền stack theo [QC-08, QC-09](../../../product/2-db/10-quy-uoc-code.md). Phiên bản ghim, khung test và công cụ sinh type OpenAPI chưa chốt, để pha 4.

Dùng đúng **Mẫu S — shell tĩnh + client sống**, **Mẫu P — prefetch server + HydrationBoundary**, **Mẫu R — realtime** và provider tại [fe-01-rendering §2–§3](fe-01-rendering.md). Không tạo provider hoặc QueryClient thứ hai cho loading. Các cách áp dụng dưới đây là **đề xuất của Claude, pha 4 chốt**; số cấu hình kỹ thuật là đề xuất khởi đầu, không phải dữ kiện quán. Dữ liệu server chỉ ở cache Query, không sao chép vào Zustand. Giá theo
[hàm giá](../../../product/3-be/03-ham-gia.md); trạng thái chờ không phải lý do để FE tự tính giá.

## 1. Bốn trạng thái và lớp chỉ báo dữ liệu cũ

Mỗi vùng dữ liệu có đủ nhánh đang tải → lỗi → trống → có dữ liệu. Trước các nhánh đó, kiểm điều kiện bật query: chưa chọn tên hoặc chưa có tham số thì hiện hướng dẫn tương ứng, không hiện skeleton vô hạn. Danh tính chọn tên theo `PersonIdentity` trong
[OpenAPI](../../../product/3-be/openapi.yaml); Server Component không đọc lựa chọn trong browser.

| Trạng thái | Điều kiện trong vùng đã đủ đầu vào | Cách hiện đề xuất |
|---|---|---|
| Đang tải lần đầu | `isPending`, chưa có dữ liệu | Skeleton đúng hình vùng; nếu `fetchStatus === 'paused'`, báo đang chờ kết nối. |
| Lỗi lần đầu | `isError`, `data === undefined` | Thông báo lỗi; thử lại đường đọc ở màn có thao tác. |
| Trống | Đọc thành công, tập kết quả rỗng | Câu nói rõ phạm vi đang xem không có kết quả. |
| Có dữ liệu | Đọc thành công, có kết quả | Nội dung thật từ cache Query. |
| Cũ/đang đọc lại | Đã có dữ liệu và `isFetching`, hoặc lần đọc lại lỗi | Giữ nội dung; thêm chỉ báo nhỏ hoặc cảnh báo dữ liệu có thể cũ. |

Trạng thái cuối là lớp phủ lên cả dữ liệu rỗng lẫn có dữ liệu, không thay toàn vùng bằng skeleton. `isFetching` không có nghĩa là dữ liệu chắc chắn sai; `isStale` cũng không phải bằng chứng mất mạng. Nếu đọc lại lỗi, giữ lần đọc thành công trước và nói rõ lần cập nhật mới chưa thành công. Không trình bày một tập rỗng cũ như kết luận hiện tại “hết việc”.

```tsx
// Bên trong Client Component; query lấy từ useQuery, tên component là đề xuất.
if (query.isPending) {
  return query.fetchStatus === 'paused'
    ? <p role="status">Chưa đọc được dữ liệu, đang chờ kết nối.</p>
    : <DataRegionSkeleton />;
}
if (query.isError && query.data === undefined) {
  return <QueryProblem error={query.error} />;
}
return <section aria-busy={query.isFetching}>
  {query.isFetching && <p role="status">Đang đọc lại…</p>}
  {query.isError && <QueryProblem error={query.error} hasPreviousData />}
  {isEmpty(query.data)
    ? <EmptyRegion previousReadFailed={query.isError} />
    : <DataRegion data={query.data} />}
</section>;
```

`isEmpty` đọc đúng cấu trúc kết quả của từng API, không dùng `!data` hoặc bắt lỗi rồi trả `[]`.
Các component/adapters bỏ qua phần định nghĩa để tập trung vào thứ tự JSX; pha 4 sinh type
và triển khai theo [hợp đồng](../../../product/3-be/openapi.yaml). Trên màn trạm, tự đọc lại
và cách phân biệt rỗng/lỗi tuân theo [yêu cầu dự phòng §1](../../../product/1-system-design/05-realtime-va-du-phong.md), không thêm nút vận hành cho trạm.

## 2. Skeleton cho S/P/R; spinner cho lệnh ghi

Dùng [Skeleton của shadcn/ui](https://ui.shadcn.com/docs/components/radix/skeleton),
giữ cùng khung, độ rộng cột và vùng nội dung của bố cục thật để tránh xô lệch lúc dữ liệu tới.
Không vẽ tiền hay số lượng giả vào skeleton; có nhãn cho trình đọc màn hình,
ẩn các khối trang trí và tôn trọng lựa chọn giảm chuyển động.

```tsx
// fe/src/components/data-region-skeleton.tsx — vị trí đề xuất
import { Skeleton } from '@/components/ui/skeleton';
export function DataRegionSkeleton() {
  return <div role="status" aria-label="Đang đọc dữ liệu" className="space-y-3">
    <div aria-hidden="true" className="space-y-3">
      <Skeleton className="h-6 w-1/3 motion-reduce:animate-none" />
      <Skeleton className="h-24 w-full motion-reduce:animate-none" />
    </div>
  </div>;
}
```

Với **Mẫu S/R**, skeleton nằm ở nhánh client chưa có dữ liệu trong §1.
Với **Mẫu P**, dùng file quy ước Next.js dưới đây cho chờ ở cấp segment;
`<Suspense fallback={<DataRegionSkeleton />}>` bao riêng vùng server prefetch của file 1
để phần khung vẫn hiện. `loading.tsx` và Suspense không thay nhánh loading của `useQuery`
thông thường; query client vẫn cần §1 khi chưa hydrate được dữ liệu.

```tsx
// fe/src/app/<segment-de-xuat>/loading.tsx
import { DataRegionSkeleton } from '@/components/data-region-skeleton';
export default function Loading() { return <DataRegionSkeleton />; }
```

Khi gửi lệnh ghi, nội dung người dùng đang kiểm tra vẫn phải nhìn thấy.
Chỉ đặt spinner nhỏ và nhãn “Đang gửi…” trên nút, khóa nút trong lúc gửi;
không thay biểu mẫu hoặc cả bảng bằng skeleton. Sau khi BE xác nhận, nhãn đọc lại
phải phân biệt được với nhãn đang gửi để người dùng không tưởng lệnh đang được gửi lần nữa.

## 3. Mutation: chờ xác nhận, rồi đọc lại

**Không optimistic update cho thao tác chạm tiền/đơn**: không tự sửa số tiền, trạng thái đơn
hoặc xóa thẻ trước phản hồi thành công. Khi BE xác nhận, invalidate các key chịu ảnh hưởng.
Thao tác thuần UI như mở khung hay chọn tab có thể phản hồi ngay; không gọi đó là kết quả BE.
Quyền từng cửa đọc [owner vai và quyền](../../../product/3-be/02-vai-va-quyen.md).

Đề xuất khóa cả nút lẫn đường submit chung, gồm submit bằng bàn phím; guard đồng bộ chặn
hai lời gọi trước khi React kịp render trạng thái mới. Đây chỉ là chống bấm lặp ở UI.
Dấu lần gửi, phạm vi áp dụng và cách gửi lại phải theo
[hợp đồng §8](../../../product/3-be/01-hop-dong-api.md), không áp một cơ chế gửi lại cho mọi cửa.
Không sinh lại dấu trong callback retry. Lỗi mạng sau khi gửi là kết quả chưa xác định;
không thông báo đã thất bại chắc chắn, không tự gửi lại thao tác tiền.

```tsx
// Trong Client Component; useRef, useMutation, useQueryClient đã import.
const lock = useRef(false);
const client = useQueryClient();
const mutation = useMutation({
  mutationFn: sendCommand, // adapter đề xuất; request theo hợp đồng
  retry: false,
  onSuccess: async () => {
    await client.invalidateQueries({ queryKey: ['counter-queue'] });
    // Pha 4 bổ sung đầy đủ key chịu ảnh hưởng của chính cửa ghi.
  },
});
async function submit() {
  if (lock.current) return;
  lock.current = true;
  try { await mutation.mutateAsync(preparedRequest); }
  catch { /* Hiện mutation.error; không gửi lại tại đây. */ }
  finally { lock.current = false; }
}
// JSX đề xuất, dùng Button của shadcn/ui; SpinnerSmall là component minh họa.
<Button type="button" disabled={mutation.isPending} onClick={submit}>
  {mutation.isPending && <SpinnerSmall aria-hidden="true" />}
  {mutation.isPending ? 'Đang xử lý…' : actionLabel}
</Button>
```

`preparedRequest` là nội dung đã chuẩn bị theo hợp đồng, không phải nơi tự tính giá.
Trả Promise từ `onSuccess` giữ mutation pending trong lúc chờ invalidate;
đây là hành vi theo [TanStack Query](https://tanstack.com/query/v5/docs/framework/react/guides/invalidations-from-mutations).
Nếu BE đã xác nhận nhưng đọc lại lỗi, báo “đã ghi, chưa cập nhật được dữ liệu” theo thiết kế pha 4;
không biến lỗi đọc lại thành lời mời gửi lại lệnh ghi. Ví dụ này chưa xử lý toàn bộ UX đó.

Lớp API giữ `code` và `field` theo schema `Error`; ánh xạ câu hiển thị **theo `code`**,
không suy từ HTTP status hoặc chữ lỗi database, theo [hợp đồng §3](../../../product/3-be/01-hop-dong-api.md).
Có `field` thì gắn câu lỗi vào đúng ô form, giữ dữ liệu đã nhập và dùng `aria-describedby`;
field không ánh xạ được thì đưa vào lỗi chung. Lỗi mạng không có `ErrorCode` cần câu riêng,
không bịa mã nghiệp vụ. Bộ câu theo mã và cách focus ô lỗi còn để pha 4 duyệt.

## 4. Mất kết nối và chế độ suy giảm

Tách trạng thái transport khỏi trạng thái query và trạng thái nhận đơn từ BE.
Đề xuất giao diện luồng có ba nhãn, mở rộng cách hiển thị của hook ở **Mẫu R**, không tạo thêm luồng:

| Luồng | Hiển thị đề xuất | Hành vi đọc |
|---|---|---|
| Đang nối | Nhãn đang nối; vẫn hiện kết quả đọc nếu có | Query tải độc lập, không đợi SSE mới hiện dữ liệu. |
| Đã nối | Nhãn kết nối bình thường | `hello`/`changed` làm invalidate; `heartbeat` chỉ theo dõi luồng. |
| Mất | Banner còn nhìn thấy, kèm mốc đọc thành công gần nhất | Giữ dữ liệu cũ có cảnh báo, tiếp tục đường kéo và nối lại. |

Theo [owner realtime §3](../../../product/3-be/09-realtime-du-phong.md), đường kéo tự chạy
mỗi `poll_interval_seconds` **kể cả khi SSE còn sống**, như [fe-01 §6](fe-01-rendering.md).
Không gán `refetchInterval: false` chỉ vì đã nối; không đặt con số chu kỳ riêng.
Mốc `read_at` là mốc dữ liệu BE; heartbeat mới không biến dữ liệu chưa đọc lại thành dữ liệu mới.

Nhận `hello` khi nối lại thì invalidate toàn bộ nhóm query liên quan tới màn để đọc lại
kết quả đầy đủ, không vá bằng payload hoặc chờ sự kiện đã lỡ được phát lại.
Tab trở lại cũng đọc lại các query sống đang hiển thị. TanStack Query v5 theo dõi
`visibilitychange` qua focus manager; dùng `refetchOnWindowFocus: true` cùng `staleTime: 0`,
và `refetchOnReconnect: true` cho việc mạng trở lại. Nếu thay listener, chỉ đăng ký một lần
và có cleanup, không thêm listener thứ hai gây refetch trùng. Xem [tài liệu focus](https://tanstack.com/query/v5/docs/framework/react/guides/window-focus-refetching).

`refetchOnReconnect` báo mạng của trình duyệt, không thay callback nối lại SSE.
Có thể dùng `refetchIntervalInBackground: true` cho query sống như file 1, nhưng browser vẫn
có thể trì hoãn timer khi ngủ hoặc ở nền; cần đọc bù khi trở lại, không hứa chu kỳ tuyệt đối.
Ngưỡng thiếu heartbeat và cách báo dữ liệu quá cũ **chưa xác định**, ghi ở §7.

“Quán mù” và “tạm dừng nhận đơn” hiển thị theo dữ liệu BE như `blind_since`, `paused_since`
hoặc mã lỗi hợp đồng, đọc [owner realtime §2–§3](../../../product/3-be/09-realtime-du-phong.md).
FE không tự kết luận quán mù từ một lần `onerror`, cũng không tự kết luận đã mở lại từ `onopen`.
Dữ liệu trạng thái cũ phải có mốc/cảnh báo; mất cả đường đọc thì báo chưa kiểm tra được trạng thái.
Luồng quầy vẫn cần giữ mở như file 1; đường kéo không thay vai trò của luồng đó.
Cách gửi `X-Person-Id` qua transport SSE quầy vẫn **chưa xác định**, không tự đặt cookie/query param.

Thông báo đường suy giảm phải dựa vào [ranh giới hệ thống §2–§3](../../../product/1-system-design/01-ranh-gioi-he-thong.md)
và [yêu cầu realtime](../../../product/1-system-design/05-realtime-va-du-phong.md), không chép thành luật mới.
Không dựng hàng đợi lệnh offline để gửi tự động khi mạng về; không suy từ kết nối rằng lệnh đã ghi
hoặc tiền đã được xác nhận. API phục vụ một trạng thái UI chưa có thì ghi chưa xác định để Claude xử lý.

## 5. Mặc định TanStack Query đề xuất theo dữ liệu

Đây là **đề xuất khởi đầu, pha 4 đo rồi chỉnh**, không phải mặc định thư viện hay số liệu quán.
Áp tại options của query dùng provider file 1. Các khoảng thời gian dưới là mili giây;
`gcTime` chỉ dọn query không còn được dùng, không quyết định độ mới. Không dùng ISR/`'use cache'` cho dữ liệu sống.

| Loại | `staleTime` | `gcTime` | `retry` | `refetchOnWindowFocus` | `refetchInterval` |
|---|---|---|---|---|---|
| Dữ liệu sống: tiền/đơn/bàn/trạm | `0` | `300_000` | `false` | `true` | Có trường chu kỳ: lấy từ dữ liệu; không có: `false`, cần chốt cơ chế làm mới. |
| Menu–giá | `0` | `300_000` | `false` | `true` | `false`; tín hiệu báo đổi giá cho khách còn mở ở file 1. |
| Danh sách người | `0` | `300_000` | `false` | `true` | `false`; đọc lại khi mở vùng chọn tên. |
| Dữ liệu chủ quán | `0` | `300_000` | `false` | `true` | Theo trường chu kỳ nếu có, nếu không `false`; invalidate sau ghi. |

Tất cả các nhóm đề xuất `refetchOnReconnect: true`. Dữ liệu chạm tiền luôn bắt đầu với
`staleTime: 0`; không coi ngày bán cũ là bất biến để tự kéo dài cache.
Mốc và ngày bán theo [hợp đồng §6](../../../product/3-be/01-hop-dong-api.md).
`retry: false` tránh vòng thử lại ngầm ở bản khởi đầu; polling là cơ chế đọc định kỳ riêng.
Nếu pha 4 thêm retry có giới hạn cho lỗi mạng/5xx của query đọc, **không thử lại lỗi 4xx có `code`**;
lỗi nghiệp vụ cần xử lý theo mã. Quy tắc phân loại retry không thay quy tắc chọn câu hiển thị.
Mutation giữ `retry: false`; không kế thừa chính sách thử lại của query đọc.

```tsx
// Options bổ sung cho query có chu kỳ; dùng cùng queryKey/queryFn của file 1.
refetchInterval: (q) => q.state.data
  ? q.state.data.poll_interval_seconds * 1000 : bootstrapPollMs,
```

`bootstrapPollMs` chưa xác định, lấy theo owner realtime khi pha 4 nối cấu hình;
không để mất đường kéo chỉ vì lần đọc đầu lỗi. `staleTime: 0` không tự tạo timer.
Khi thay người, chính sách hủy query/dọn cache cần theo câu hỏi mở ở file 1;
`gcTime` không phải biện pháp kiểm quyền hoặc bảo vệ cache theo người.

## 6. Prefetch để giảm chờ, không giữ giá cũ

Dùng `<Link prefetch>` khi đích điều hướng hợp lý; `queryClient.prefetchQuery` khi hover,
focus hoặc khi mở vùng kế tiếp có thể đoán trước. Hai cơ chế lấy trước route và dữ liệu khác nhau;
đo để tránh tải lặp, không prefetch mọi màn. Ví dụ đề xuất trong Client Component:

```tsx
const warmMenu = () => client.prefetchQuery({ queryKey: ['menu'], queryFn: readMenu });
<Button onPointerEnter={() => void warmMenu()} onFocus={() => void warmMenu()}
  onClick={openNextRegion}>Xem menu</Button>
```

Prefetch chỉ đọc, không gọi mutation; key và adapter dùng chung với query hiển thị.
Không kéo dài `staleTime` của giá chỉ để né lần đọc sau prefetch; dữ liệu lấy trước vẫn có thể cũ.
Với Mẫu P, giữ ranh giới dữ liệu công khai không cần danh tính của file 1.
Thời điểm hoãn bằng `navigation()`/`prefetch()` và Partial Prefetching đọc
[tài liệu Next.js](nextjs-16-4-huong-dan-fe.md); chúng không thay invalidate hoặc đường kéo.

## 7. Câu hỏi còn mở

Các điểm **chưa xác định** sau dành cho Claude/pha 4, không thay đổi owner trong lượt này.

1. Ngưỡng thiếu heartbeat, tuổi dữ liệu cần cảnh báo và cách biểu đạt trên màn trạm/quầy là gì?
2. Chốt transport danh tính SSE, cấu hình kéo ban đầu và tín hiệu đổi menu cho khách thế nào, theo câu hỏi của file 1?
3. Với lệnh đã gửi nhưng mất phản hồi, từng cửa có API đọc nào để xác minh trước khi cho thao tác tiếp? Chỗ thiếu API giao lát nào?
4. Bộ câu theo `ErrorCode`, ánh xạ `field`, trạng thái đã ghi nhưng đọc lại lỗi và tiêu chí khóa thao tác cần Claude duyệt ra sao?
5. Giữ các cấu hình khởi đầu nào sau khi đo mạng/thời gian tải; chọn phiên bản ghim, khung test và công cụ sinh type nào?

## 8. Liên kết

[fe-01-rendering — mẫu S/P/R và provider](fe-01-rendering.md) · [Next.js 16.4](nextjs-16-4-huong-dan-fe.md)
· [Hợp đồng API](../../../product/3-be/01-hop-dong-api.md) · [OpenAPI](../../../product/3-be/openapi.yaml)
· [Realtime BE](../../../product/3-be/09-realtime-du-phong.md).
Bộ hướng dẫn: [fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [fe-03-state-management](fe-03-state-management.md) · [fe-04-shared-components](fe-04-shared-components.md); danh sách trang (fe-05-danh-sach-trang.md) viết sau.
