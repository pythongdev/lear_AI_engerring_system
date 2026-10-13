# Quản lý state — dữ liệu nằm ở đâu, ai ghi và khi nào xóa

> Viết ngày **2026-10-13**: **Codex viết theo phiếu của Claude, chủ repo yêu cầu**.
> Đây là **tài liệu tham khảo**, KHÔNG là owner route/component/quy ước FE.
> Owner sinh ở pha 4 cùng `docs/product/4-fe/`, theo [CLAUDE.md §2](../../../../CLAUDE.md).
> **Khi lệch, owner thắng.** Tên route FE, component, store, adapter và query key là **đề xuất**.
> OperationId/đường BE lấy từ hợp đồng; code minh họa chưa phải ứng dụng chạy riêng.

Stack **chủ repo chọn 2026-10-13**: Next.js 16.4 App Router + TypeScript ở `fe/`, shadcn/ui cùng Tailwind CSS 4 và Radix, TanStack Query cho dữ liệu server, Zustand cho client. Vị trí/nền stack theo [QC-08, QC-09](../../../product/2-db/10-quy-uoc-code.md). Phiên bản ghim, khung test và công cụ sinh type OpenAPI **chưa chốt**, để pha 4. Thiết kế phân chia state dưới đây là **đề xuất của Claude, pha 4 chốt**.

Dùng **Mẫu S — shell tĩnh + client sống**, **Mẫu P — prefetch server + HydrationBoundary**, **Mẫu R — realtime** và provider của [file rendering](fe-01-rendering.md). Options query, retry, loading và mutation theo [file loading §1–§5](fe-02-loading.md); file này không định nghĩa lại provider hoặc bảng mặc định.

## 1. Bốn chỗ ở — một dữ liệu một chỗ ở

| Loại dữ liệu | Chỗ ở duy nhất | Ai ghi / khi nào xóa hoặc thay |
|---|---|---|
| Mọi kết quả BE: menu, báo giá, bàn, quầy, trạm, người, nợ, đối soát | Cache TanStack Query | Adapter nhận phản hồi BE; invalidate để đọc lại, dọn theo vòng đời Query và khi đổi người. Phản hồi mutation ở MutationCache, không đẩy sang Zustand. |
| Lựa chọn tên trên máy, nháp đi qua nhiều màn, tùy chọn UI dùng chung | Zustand | Action từ thao tác client; xóa lựa chọn hoặc nháp có chủ ý, kết thúc nháp theo §5. |
| Bộ lọc, tab, ngày bán đang xem, id đang mở cần chia sẻ/tải lại | URL: `searchParams`, `params` | Điều hướng ghi; đọc lại từ URL, bỏ tham số khi người dùng đặt lại bộ lọc. |
| Nháp một form, trạng thái mở hộp thoại chỉ ở một vùng | `useState` hoặc state của form | Form/người dùng ghi; reset khi hủy/hoàn tất hoặc đổi đối tượng sau khi xử lý nháp đang sửa. |

Ngày bán trong URL là **lựa chọn để đọc**, khác ngày bán BE đã gắn với một bản ghi. Dữ liệu query có thể được lọc qua `select` hay tính cách trình bày tại render; không cất bản lọc sang store. Form sửa dữ liệu giữ **ý định sửa** tách biệt với bản BE, không là cache thứ hai. Một trường nháp đã thuộc store nhiều màn thì form đọc/ghi qua action; không đồng bộ hai bản bằng effect.

`params`/`searchParams` của Server Component theo [tài liệu Next.js](nextjs-16-4-huong-dan-fe.md); client đọc URL bằng hook App Router. Parse và kiểm đầu vào trước khi gọi API; tham số không hợp lệ không được âm thầm biến thành ngày hiện tại. Không đưa thông tin liên hệ hay dấu lần gửi lên URL.

## 2. Query key factory theo domain BE — đề xuất

Domain lấy từ [bản chụp BE](../../be_feature/be_feature_hien_tai.md); nhóm `tags` trong [OpenAPI](../../../product/3-be/openapi.yaml), nếu có, chỉ để đọc Swagger, không phải luật. Hợp đồng thắng bản chụp. Object gom theo domain nhưng giữ prefix đã dùng trong file 1–2; gom object không tạo thêm cache. Key chứa mọi đầu vào làm thay đổi kết quả, bao gồm người cho đường cần danh tính. Không thêm tham số API chỉ để khớp cấu trúc key.

```ts
// fe/src/lib/query-keys.ts — đề xuất; PriceQuoteRequest sinh từ OpenAPI ở pha 4
import type { PriceQuoteRequest } from '@/lib/api-types';
export const keys = {
  nguoi: {
    list: () => ['people'] as const, // listPeople
    duty: () => ['counter-duty'] as const, // getCurrentCounterDuty
  },
  menu: { read: () => ['menu'] as const }, // getMenu
  gia: { quote: (body: PriceQuoteRequest) => ['price-quotes', body] as const }, // quotePrices
  ban: { list: () => ['dining-tables'] as const }, // getDiningTables
  qr: { table: (code: string) => ['qr-table', code] as const }, // getTableByQrCode
  don: { reminders: () => ['preorder-reminders'] as const }, // getPreorderReminders
  nhandon: { queue: (personId: string) => ['counter-queue', personId] as const }, // counterQueue
  sanxuat: {
    board: () => ['production-board'] as const, // getProductionBoard
    candidates: (id: string) => ['transfer-candidates', id] as const, // getTransferCandidates
  },
  hoadon: { debts: () => ['debts'] as const }, // listDebts
  ket: {
    day: (saleDate: string) => ['cash-reconciliation', saleDate] as const, // getCashReconciliation
  },
};
```

Key là cấu trúc JSON ổn định, không chứa function/Date hoặc object bị sửa tại chỗ. Giữ thứ tự dòng của request báo giá; không tự chuẩn hóa nội dung lần gửi lại. `getProductionBoard` không có tham số trạm trong hợp đồng: trạm đang xem lọc ở UI, không tách cache thành nhiều bản cùng dữ liệu. Type/id trên dây phải theo công cụ sinh type được chọn. `don` chưa có GET chi tiết đơn; `phien`/`tratruoc` chưa có GET chi tiết riêng. Không dựng queryFn giả cho phản hồi lệnh ghi; dữ liệu trả về vẫn thuộc Query, khả năng đọc lại còn mở ở §8.

## 3. Mutation và SSE làm mất hiệu lực key nào

Bảng là **đề xuất phạm vi đọc lại**, không chép tác động nghiệp vụ hay lớp quyền của từng cửa.
Chỉ chạy sau BE xác nhận; không optimistic tiền/đơn. Dưới đây ghi **prefix query key**:
`invalidateQueries({ queryKey: ['counter-queue'] })` bao mọi người; key có tham số có thể thu hẹp
khi biết chắc đối tượng. Invalidate đánh dấu cache cũ và mặc định đọc lại query đang hoạt động.

| Lệnh ghi — operationId có trong hợp đồng | Prefix phải invalidate đề xuất |
|---|---|
| `createTableOrder`, `createQrOrder`, `createOnlineOrder`, `createPhoneOrder` | `counter-queue`, `dining-tables`, `production-board`, `preorder-reminders`, `transfer-candidates` |
| `approveOrder`, `rejectOrder`, `cancelOrder`, `releasePreorders`, `departOrder` | `counter-queue`, `dining-tables`, `production-board`, `preorder-reminders`, `transfer-candidates` |
| `makeProductionBatch`, `rollbackProductionBatch`, `markServed`, `transferStationJobs`, `writeWrongMakeNote`, `cancelWrongMakeNote` | `production-board`, `transfer-candidates`, `dining-tables`, `counter-queue`, `preorder-reminders` |
| `requestBill`, `cleanTable` | `dining-tables`, `counter-queue`, `production-board` |
| `closeSession`, `handoverOrder`, `deliverOrder` | `dining-tables`, `counter-queue`, `production-board`, `preorder-reminders`, `transfer-candidates`, `debts`, `cash-reconciliation` |
| `receivePrepayment`, `returnPrepayment`, `refundBill`, `collectDebt` | `debts`, `cash-reconciliation`, `counter-queue`; phần chi tiết tiền chưa có đường đọc riêng |
| `declareOpeningFloat`, `recordCashCount`, `correctReconciledCashCount`, `createPaperEntry`, `declarePaperLedger`, `reconcileSaleDay` | `cash-reconciliation`, `debts` |
| `changeComponentPrice`, `changeOptionSurcharge`, `changeItemComponent`, `discontinueMenuItem` | `menu`, `price-quotes` |
| `issueQrCode` | `qr-table` (mọi mã đang cache) |
| `enterCounterDuty`, `endCounterDuty` | `counter-duty`, `counter-queue`; kiểm lại kết nối quầy theo danh tính |
| `pauseIntake`, `resumeIntake`, `declareBlind`, `reopenBlind` | `counter-queue` |

Nguồn chữ ký từng cửa: [OpenAPI](../../../product/3-be/openapi.yaml); luồng nháp đọc
[tại bàn](../../../product/3-be/04-luong-tai-ban.md) và [mang đi](../../../product/3-be/05-luong-mang-di.md).
Không suy ngày của key đối soát từ đồng hồ máy; khi chưa biết các ngày bị ảnh hưởng thì invalidate cả prefix.
Phản hồi mutation chỉ là kết quả tại lần ghi ấy; invalidation không làm nó thành ảnh chụp chi tiết hiện tại.

| Luồng / operationId | Sự kiện | Prefix invalidate đề xuất |
|---|---|---|
| `GET /counter/events` / `counterEvents` | `hello`, `changed` | `counter-queue`, `counter-duty`, `dining-tables`, `production-board`, `transfer-candidates`, `preorder-reminders`, `menu`, `price-quotes`, `qr-table`, `debts`, `cash-reconciliation` đang dùng ở màn quầy |
| `GET /production-board/events` / `productionEvents` | `hello`, `changed` | `production-board`, `transfer-candidates`; thêm nhóm phụ đang hiển thị nếu màn có dùng, không mở thêm luồng |
| Cả hai luồng trên | `heartbeat` | Không invalidate dữ liệu; chỉ theo dõi transport. |

Theo [owner realtime §3](../../../product/3-be/09-realtime-du-phong.md), payload không phân loại domain.
Vì vậy mapping bao rộng, không suy key từ dữ liệu sự kiện, không dùng `setQueryData` để vá cache SSE.
Giữ đường kéo **kể cả khi luồng còn sống**, cùng hành vi nối lại/tab trở lại tại [file loading §4](fe-02-loading.md).
Không dùng luồng quầy để cấp tín hiệu công khai cho khách; cơ chế báo đổi menu phía khách chưa xác định.

## 4. Store chọn tên và fetcher — Zustand v5, đề xuất

Mỗi store một file nhỏ. Store chọn tên giữ **lựa chọn trên máy**, không chứa object `Person`,
cờ quyền, ca trực hay danh sách người. `displayName` dưới đây là nhãn của lần chọn, có thể cũ,
chỉ để nhận ra lựa chọn đã lưu; tên hiện hành/quyền hiển thị từ query `listPeople`.
Đây là metadata của thao tác chọn, không dùng làm bản sao hồ sơ server hay bằng chứng quyền.

```ts
// fe/src/stores/chosen-person.ts — đề xuất, chỉ dùng phía client
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';
type Choice = { personId: string; displayName: string };
type PersonState = {
  choice: Choice | null;
  choose: (choice: Choice | null) => void;
};
export const useChosenPerson = create<PersonState>()(persist(
  (set) => ({ choice: null, choose: (choice) => set({ choice }) }),
  {
    name: 'chosen-person', storage: createJSONStorage(() => localStorage),
    partialize: (s) => ({ choice: s.choice }), skipHydration: true,
  },
));
// Trong React: selector lấy đúng phần cần, không gọi useChosenPerson() lấy cả store.
const personId = useChosenPerson((s) => s.choice?.personId ?? null);
```

Dùng [create](https://zustand.docs.pmnd.rs/reference/apis/create) và
[persist](https://zustand.docs.pmnd.rs/reference/middlewares/persist); sau mount gọi
`useChosenPerson.persist.rehydrate()` ở một điểm khởi tạo client. Chỉ bật query cần danh tính
sau khi hydration xong và lựa chọn đã kiểm lại. Kiểm hình storage khi đọc, lỗi thì yêu cầu chọn tên;
chi tiết migrate/version và storage không dùng được để pha 4 chốt. Không đọc store từ Server Component.

Đề xuất đổi người qua một action điều phối: khóa thao tác mới, xử lý mutation còn đang gửi,
dừng luồng cũ, hủy query cũ (`cancelQueries` với adapter nhận signal), rồi `queryClient.clear()`
và thay lựa chọn, mount lại vùng dữ liệu/luồng bằng người mới. Clear tránh giữ dữ liệu người trước;
clear **không hủy lệnh ghi đã tới BE**. Chưa rõ kết quả lệnh thì không âm thầm đổi người/xóa dấu gửi.
Đổi lại key/invalidating riêng theo người có thể tiết kiệm cache công khai, nhưng pha 4 phải duyệt phạm vi.

```ts
// Fetcher đề xuất, gọi trong browser sau hydration; URL truyền từ adapter theo OpenAPI.
export async function apiFetch(url: string, needsPerson: boolean, init: RequestInit = {}) {
  const headers = new Headers(init.headers);
  headers.delete('X-Person-Id');
  if (needsPerson) {
    const id = useChosenPerson.getState().choice?.personId;
    if (!id) throw new Error('Chưa chọn tên'); // lỗi client, không bịa ErrorCode
    headers.set('X-Person-Id', id);
  }
  return fetch(url, { ...init, headers, cache: 'no-store' });
}
```

`needsPerson` do adapter lấy từ `security` từng operation, không do UI tùy ý cấp quyền.
Query cần danh tính phải chụp cùng person id cho key và request; hủy/chặn request cũ khi đổi người,
không để key người A nhận kết quả người B. Mẫu trên chỉ minh họa `getState()` ngoài React.
Adapter đầy đủ phải kiểm `response.ok`, giải `Error.code`/`field` theo [hợp đồng §3](../../../product/3-be/01-hop-dong-api.md).
`X-Person-Id` là chọn tên, không phải đăng nhập; định dạng theo `PersonIdentity`, quyền theo
[owner quyền](../../../product/3-be/02-vai-va-quyen.md). Transport SSE quầy vẫn là câu hỏi của file 1.

## 5. Store nháp/giỏ — lựa chọn không có giá

Đề xuất chia nháp theo ngữ cảnh tại bàn, QR, mang đi, điện thoại, online; đây là nhãn UI,
không tự thêm kênh API. Id nháp định vị cả ngữ cảnh/đối tượng, tránh đổ giỏ bàn này sang bàn khác.
Mã bàn/QR đang mở lấy từ URL; chỉ chụp vào request lúc gửi, không đồng bộ sang một store khác.

```ts
// fe/src/stores/order-draft.ts — đề xuất; không persist ở bản khởi đầu
import { create } from 'zustand';
import type { PriceLineRequest } from '@/lib/api-types';
type Line = Pick<PriceLineRequest, 'menu_item_id' | 'quantity' | 'option_ids'>;
type DraftState = {
  linesByDraft: Record<string, Line[]>;
  replace: (draftId: string, lines: Line[]) => void;
  drop: (draftId: string) => void;
};
export const useOrderDraft = create<DraftState>()((set) => ({
  linesByDraft: {},
  replace: (id, lines) => set((s) => ({ linesByDraft: { ...s.linesByDraft,
    [id]: lines.map((l) => ({ menu_item_id: l.menu_item_id, quantity: l.quantity,
      option_ids: [...l.option_ids] })) } })),
  drop: (id) => set((s) => {
    const next = { ...s.linesByDraft }; delete next[id]; return { linesByDraft: next };
  }),
}));
```

Chỉ lấy selector `useOrderDraft((s) => s.linesByDraft[draftId])`; dùng mảng rỗng hằng ở ngoài
selector nếu chưa có nháp, không tạo mảng/object mới trong selector mỗi lần render.
Đây là phần dòng món tối thiểu; lựa chọn đem về/liên hệ/cách trao của form bổ sung theo schema
của [luồng tại bàn](../../../product/3-be/04-luong-tai-ban.md) và [luồng mang đi](../../../product/3-be/05-luong-mang-di.md), không suy luật từ nhãn UI.

```tsx
// Trong Client Component, dưới provider file 1; body là nội dung nháp bất biến.
const body = { lines };
const quote = useQuery({
  queryKey: keys.gia.quote(body),
  queryFn: ({ signal }) => quotePrices(body, { signal }), // POST /price-quotes, chỉ tính thử
  enabled: lines.length > 0,
});
```

`quotePrices` là adapter đề xuất cho operationId cùng tên. Đổi nội dung nháp đổi key;
không hiển thị giá nháp trước như giá nháp mới, không chép `quote.data` vào store.
Giá hiển thị từ `/price-quotes` hoặc `/menu`; FE không tính tổng, không gửi giá theo
[hàm giá](../../../product/3-be/03-ham-gia.md). Options query giữ bảng của file 2.

Khi bấm gửi, bộ điều phối nháp sinh dấu lần gửi và đóng băng **toàn bộ request + đích gọi**;
giữ ít nhất tới khi BE trả lời, theo [hợp đồng §8](../../../product/3-be/01-hop-dong-api.md).
Envelope này là ý định client, có thể ở một store submission nhỏ; không chứa giá hay phản hồi BE.
Thành công thì bỏ đúng nháp đã gửi và envelope; nếu cho sửa trong lúc gửi phải tách phiên nháp mới.
Lỗi/mất phản hồi thì giữ nội dung và dấu để xử lý, không tự tạo dấu khác hoặc xóa trong `finally`.
Thời điểm bỏ envelope sau lỗi xác định và khôi phục sau reload **chưa xác định**; không tự persist đơn/tiền.

Store UI chỉ thêm khi có nhu cầu nhiều màn: ví dụ chế độ hiển thị theo máy. Trạm/tab cần chia sẻ
thì ở URL; không đồng thời ở store UI. Không persist mặc định. Xóa khi người dùng reset lựa chọn;
nháp chỉ xóa khi thành công hoặc người dùng bỏ nháp sau khi đã xử lý lần gửi chưa rõ kết quả.

## 6. Những việc không làm; ngày bán và thời gian

Không copy query vào Zustand, không `useEffect` đồng bộ hai chiều, không lưu dữ liệu tiền vào
localStorage, không tính tổng tiền ở FE. Hydration storage sau mount là bước khởi tạo, không phải
đồng bộ query/store. Không dùng Zustand làm cache ngầm cho dữ liệu chỉ trả từ mutation.

FE hiển thị mốc/ngày bán theo [hợp đồng §6](../../../product/3-be/01-hop-dong-api.md) và
[owner ngày bán](../../../product/1-system-design/02-thoi-gian-ngay-ban.md); không suy ngày bán
bằng `new Date()` trên máy. Ngày chọn trên URL là đầu vào đọc, không ghi đè ngày BE đã xác định.
Nguồn “ngày bán hiện tại” nếu màn cần mà API chưa cung cấp phù hợp là **chưa xác định**.

## 7. Form — đề xuất chưa chốt

React Hook Form + Zod với component `Form` của shadcn/ui là **đề xuất chưa chốt**;
chủ repo mới chọn shadcn/ui, TanStack Query, Zustand. Chọn phiên bản/tích hợp ở pha 4:
[tài liệu shadcn hiện hành](https://ui.shadcn.com/docs/forms/react-hook-form) minh họa `Field`,
nên cần đối chiếu khả năng dùng bộ `Form` ở bản ghim, không tự đổi stack từ ví dụ web.
Form giữ input và lỗi cục bộ, chỉ kiểm hình theo hợp đồng; BE quyết luật và giá.
Khởi tạo nháp sửa một lần, giữ khi query refetch; không effect reset form theo mỗi response.
Lỗi theo `code`, gắn `field` khi có, mutation theo [file loading §3](fe-02-loading.md).

## 8. Câu hỏi còn mở

Các điểm **chưa xác định** dành cho Claude/pha 4, không sửa owner trong lượt này.

1. Chốt clear cache/đổi người, mutation còn gửi, hydration và lựa chọn tên trên nhiều tab thế nào?
2. Envelope gửi lại sống qua reload ra sao; sau từng lỗi xác định, khi nào cho sửa/bỏ nháp và dấu cũ?
3. Đường đọc chi tiết đơn, phiên, trả trước/hoá đơn và nguồn ngày bán hiện tại cần lát BE nào bổ sung?
4. Chốt tập key trên từng màn, tín hiệu đổi giá cho khách và transport SSE quầy thế nào?
5. Chọn bản ghim, công cụ sinh type (gồm int64), test và tích hợp React Hook Form/Zod/`Form` nào?

## 9. Liên kết

[fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [Next.js 16.4](nextjs-16-4-huong-dan-fe.md)
· [Hợp đồng API](../../../product/3-be/01-hop-dong-api.md) · [OpenAPI](../../../product/3-be/openapi.yaml)
· [Bản chụp domain BE](../../be_feature/be_feature_hien_tai.md).
Bộ hướng dẫn: [fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [fe-03-state-management](fe-03-state-management.md) · [fe-04-shared-components](fe-04-shared-components.md); danh sách trang (fe-05-danh-sach-trang.md) viết sau.
