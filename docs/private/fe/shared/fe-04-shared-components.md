# Danh mục shared component — kiểm trước khi dựng, cập nhật khi dùng chung

> Viết ngày **2026-10-13**: **Codex viết theo phiếu của Claude, chủ repo yêu cầu**.
> Đây là **tài liệu tham khảo**, KHÔNG là owner route/component/quy ước FE.
> Owner sinh ở pha 4 cùng `docs/product/4-fe/`, theo [CLAUDE.md §2](../../../../CLAUDE.md).
> **Khi lệch, owner thắng.** Mọi tên route FE, component, hook, props và query key dưới đây là **đề xuất**.
> Danh mục chưa chứng minh component đã tồn tại. Không tạo `fe/` từ tài liệu này.

Stack **chủ repo chọn 2026-10-13**: Next.js 16.4 App Router + TypeScript ở `fe/`,
shadcn/ui cùng Tailwind CSS 4 và Radix, TanStack Query cho dữ liệu server, Zustand cho client.
Vị trí/nền stack theo [QC-08, QC-09](../../../product/2-db/10-quy-uoc-code.md).
Phiên bản ghim, khung test, công cụ sinh type OpenAPI **chưa chốt**, để pha 4.
Các thiết kế bên dưới là **đề xuất của Claude, pha 4 chốt**.

Dùng mẫu S/P/R và provider của [fe-01-rendering](fe-01-rendering.md), trạng thái dữ liệu và mutation
của [fe-02-loading](fe-02-loading.md), chỗ ở state/key của [fe-03-state-management](fe-03-state-management.md).
Danh mục này không định nghĩa lại chúng. Trước khi dựng mới, tìm theo việc component làm;
khi component thực sự được dùng chung, thêm/cập nhật một dòng với props, nơi dùng và phụ thuộc.
Khi owner pha 4 ra đời, danh mục tham khảo theo owner đó, không trở thành nơi quyết định song song.

## 1. Ba tầng và chiều import — đề xuất

```text
fe/src/
  components/ui/                    # tầng 1: primitive shadcn/ui từ CLI
  components/shared/                # tầng 2: nghiệp vụ dùng ở >= 2 nhóm màn
  app/<route-de-xuat>/_components/   # tầng 3: riêng một màn, đặt cạnh route
```

**Tầng 1** không sửa tay logic tương tác, focus hay accessibility do primitive cung cấp.
Tùy biến qua biến thể `cva`, class và token theme; nhu cầu nghiệp vụ đặt ở wrapper tầng trên.
Không fetch, không đọc Zustand, không quyết quyền hay diễn giải mã lỗi trong tầng 1.
**Tầng 2** là ứng viên dùng chung giữa các nhóm màn; chỉ nâng component thật lên đây khi có
nơi dùng thứ hai. Những dòng chưa đủ nơi dùng vẫn là đề xuất, không dựng sẵn để “cho đủ”.
**Tầng 3** giữ cách ghép màn và thao tác riêng; màn thứ hai cần cùng hành vi thì xét nâng tầng.

Import theo chiều **tầng 3 → tầng 2 → tầng 1**, không ngược; tầng 3 có thể dùng trực tiếp
primitive tầng 1. Tầng 2 không import route hoặc component riêng của route.
Type sinh và hook domain là phụ thuộc nền được gọi tên rõ, không là cách vòng qua luật import.
Component của màn trạm phải chỉ đọc: không nút chọn tên, tải lại, đóng banner, xác nhận hay gửi lệnh.
Nguồn: [realtime pha 1 §1, ADR-011](../../../product/1-system-design/05-realtime-va-du-phong.md).
Bấm mẻ/ra bàn đặt ở giao diện quầy theo [sản xuất §1–§3](../../../product/3-be/07-san-xuat-theo-me.md),
không chuyển các nút đó sang trạm chỉ vì tái sử dụng một khung chung.

## 2. Primitive dự kiến dùng — đề xuất, chưa cài

Các lệnh dưới là **gợi ý**, chạy trong FE khi pha 4 cho phép khởi tạo; kiểm lại
[CLI shadcn](https://ui.shadcn.com/docs/cli), registry và bản ghim trước khi chạy.
`latest` không phải phiên bản đã duyệt. Chọn nền Radix theo stack, không nhận nền mặc định khác
một cách ngầm định. Thêm theo nhu cầu, không chạy cả bảng hoặc ghi đè code đã tùy biến.

| Primitive dự kiến | Dùng cho gì trong quán — đề xuất | Lệnh thêm gợi ý |
|---|---|---|
| Button | Gửi/xác nhận trên quầy, chủ quán, khách; không dùng ở màn trạm | `npx shadcn@latest add button` |
| Card | Khung món, phần dữ liệu quầy/trạm; bản trạm không có action | `npx shadcn@latest add card` |
| Badge | Nhãn trạng thái có chữ, không chỉ màu | `npx shadcn@latest add badge` |
| Dialog | Form hoặc chi tiết cần thao tác; không ở trạm | `npx shadcn@latest add dialog` |
| AlertDialog | Xác nhận lệnh trên màn thao tác; lý do theo §4 | `npx shadcn@latest add alert-dialog` |
| Sheet | Vùng nháp/chi tiết trên quầy hoặc khách | `npx shadcn@latest add sheet` |
| Drawer | Nháp món trên thiết bị khách nhỏ; chọn sau khi đo | `npx shadcn@latest add drawer` |
| Tabs | Chuyển vùng xem trên màn thao tác; không yêu cầu trạm bấm tab | `npx shadcn@latest add tabs` |
| Table | Dữ liệu đối soát/quầy; bảng trạm chỉ đọc | `npx shadcn@latest add table` |
| Form | Form có nhãn/lỗi; React Hook Form + Zod chưa chốt | `npx shadcn@latest add form` — kiểm registry/bản ghim trước |
| Input | Nội dung người dùng nhập trên màn thao tác | `npx shadcn@latest add input` |
| Label, Textarea | Nhãn và ô lý do/nội dung dài | `npx shadcn@latest add label textarea` |
| Select | Chọn một giá trị trong form hoặc bộ lọc | `npx shadcn@latest add select` |
| RadioGroup | Chọn một lựa chọn theo dữ liệu menu, không tự suy luật | `npx shadcn@latest add radio-group` |
| Checkbox | Lựa chọn boolean theo schema; không thay RadioGroup tùy tiện | `npx shadcn@latest add checkbox` |
| Skeleton | Khung tải đúng bố cục thật của vùng dữ liệu | `npx shadcn@latest add skeleton` |
| Sonner/toast | Phản hồi ngắn trên màn thao tác; không thay banner lỗi ở trạm | `npx shadcn@latest add sonner` |
| Tooltip | Chú giải bổ sung ở màn thao tác; không giấu thông tin trạm sau hover | `npx shadcn@latest add tooltip` |
| ScrollArea | Vùng dài trên màn thao tác; bố cục trạm không phụ thuộc cuộn tay | `npx shadcn@latest add scroll-area` |
| Separator | Phân vùng nội dung | `npx shadcn@latest add separator` |
| Command | Tìm/chọn tên hoặc món ở màn thao tác, không là nút điều khiển trạm | `npx shadcn@latest add command` |
| Alert | Banner kết nối/lỗi dạng luôn nhìn thấy, bản trạm không nút đóng | `npx shadcn@latest add alert` |

`Form` là hướng đề xuất của file 3, chưa phải thư viện bổ sung đã được chủ repo chọn.
[Tài liệu form hiện hành](https://ui.shadcn.com/docs/forms/react-hook-form) minh họa `Field`;
khả năng dùng bộ `Form` ở bản ghim cần pha 4 kiểm, không coi lệnh gợi ý là bằng chứng đã chạy.

## 3. Shared component — danh mục đề xuất

“Người quán” được tách quầy/trạm trong cột nơi dùng để tránh truyền nhầm quyền thao tác.
Props bên dưới dùng alias type sinh từ [OpenAPI](../../../product/3-be/openapi.yaml);
tên alias cuối cùng phụ thuộc công cụ pha 4. Hook chưa tồn tại đều mang tên **đề xuất**.
Component nhận props chỉ trình bày; component nối dữ liệu phải nêu hook cụ thể, không tự mở query/SSE thứ hai.

| Tên — tất cả là đề xuất | Việc | Props chính đề xuất | Nhóm màn dùng | Phụ thuộc store/query đề xuất |
|---|---|---|---|---|
| **Đề xuất `PersonPicker`** | Chọn tên, không giả màn đăng nhập | `selectedPersonId`, `onChoose`, `disabled` | Người quán: quầy; chủ quán; không trạm | `usePeopleQuery` đọc `GET /people` (`listPeople`); action điều phối ghi store người ở file 3 |
| **Đề xuất `ConnectionStatus`** | Thanh trạng thái luồng và lần đọc gần nhất | `transport`, `readAt`, `readError` | Quầy, trạm, chủ quán khi có luồng phù hợp | Nhận trạng thái từ controller của file 2; không tự nối SSE |
| **Đề xuất `ConnectionBanner`** | Báo đang nối/mất luồng, dữ liệu có thể cũ | `transport`, `lastReadAt`, `queryFailed` | Quầy, trạm, chủ quán | Props như file 2; không nút đóng hoặc retry ở trạm |
| **Đề xuất `IntakeBanner`** | Hiện quán mù/tạm dừng từ BE | `pausedSince`, `blindSince`, `readAt`, `audience` | Quầy; chủ quán/khách chỉ khi có nguồn dữ liệu hợp lệ | Quầy lấy `counterQueue`; nguồn chủ quán/khách ngoài ngữ cảnh quầy và câu chữ khách **chưa xác định**, không tự gọi API cần quyền |
| **Đề xuất `MoneyText`** | Định dạng đồng từ số nguyên BE trả, không cộng tiền | `value: MoneyVnd`, `className` | Khách, quầy, chủ quán | Chỉ props; theo [hợp đồng §5](../../../product/3-be/01-hop-dong-api.md), không store/localStorage |
| **Đề xuất `QueryProblem`** | Tra bảng `ErrorCode → câu`; lỗi mạng là nhánh riêng | `error`, `fieldTarget?`, `hasPreviousData?` | Khách, quầy, trạm, chủ quán | Props; bảng câu dùng chung, câu cụ thể **chưa xác định**, pha 4 viết; không suy HTTP status |
| **Đề xuất `ReasonConfirmDialog`** | Xác nhận và nhập lý do khi request đòi | `open`, `title`, `reason`, `onReasonChange`, `onConfirm`, `pending`, `error` | Quầy, chủ quán tùy cửa; không trạm | State form cục bộ; mutation do màn truyền callback; cửa hợp lệ xem §4 |
| **Đề xuất `OrderStatusBadge`** | Nhãn đơn theo schema của phản hồi đang dùng | `status`, `sourceSchema` | Quầy; khách/chủ quán nếu có dữ liệu hợp lệ | Props từ Query; enum đầy đủ **chưa xác định** (§4), không suy từ thao tác vừa bấm |
| **Đề xuất `TableStateBadge`** | Nhãn bàn theo `DiningTable.state` | `state: DiningTable['state']` | Quầy, chủ quán khi có nhu cầu | Props; query `getDiningTables`, không tự tính trạng thái bàn |
| **Đề xuất `StationWorkSummary`** | Nhãn/phần việc trạm theo dữ liệu bảng sản xuất | `row: ProductionRow`, `readAt` | Quầy, trạm | Props từ `getProductionBoard`; hiện trường trả về, không dựng enum việc còn thiếu (§4) |
| **Đề xuất `DataRegion`** | Bốn trạng thái và lớp dữ liệu cũ của file 2 | `queryState`, `isEmpty`, `skeleton`, `renderData`, `renderError` | Khách, quầy, trạm, chủ quán | Nhận trạng thái Query; bản trạm render lỗi không có nút |
| **Đề xuất `DataRegionSkeleton`** | Skeleton khớp bố cục vùng dùng chung | `layout`, `className` | Khách, quầy, trạm, chủ quán | Không store/query; bố cục riêng một màn để tầng 3, không ép chung |
| **Đề xuất `MenuSelection`** | Bộ chọn món/tuỳ chọn, báo giá BE | `lines`, `onLinesChange`, `menu`, `quoteState`, `disabled` | Quầy (gồm nhập điện thoại), khách QR/online | Props từ `getMenu`, hook `usePriceQuoteQuery` gọi `POST /price-quotes`; nháp ở file 3, không giữ giá |
| **Đề xuất `StaffPageShell`** | Khung người quán: người đang đứng, quầy/trạm, kết nối | `mode`, `personLabel`, `counterDuty`, `stationLabel`, `connection`, `children` | Quầy, trạm, chủ quán khi phù hợp | Props từ store lựa chọn và query `getCurrentCounterDuty`; phân biệt người chọn tên với người đang trực, không tự đồng nhất |
| **Đề xuất `CustomerPageShell`** | Khung khách và vị trí thông báo | `title`, `tableLabel?`, `notice?`, `children` | Khách QR, online | Props; nhãn bàn từ `getTableByQrCode`; không đọc store người quán |
| **Đề xuất `MutationSubmitButton`** | Khóa/chỉ báo khi gửi, gọi bộ điều phối lần gửi | `pending`, `disabled`, `label`, `onSubmit` | Khách, quầy, chủ quán; không trạm | Mutation/controller của màn giữ dấu gửi khi cửa áp dụng; nút không sinh dấu mỗi click hoặc retry |

Các dòng khung chuyên cho khách/người quán là ứng viên dùng lại trong các luồng tương ứng;
chỉ nâng lên tầng 2 khi chứng minh nhu cầu dùng chung theo §1, không tạo wrapper rỗng từ bảng.
`StaffPageShell` ở chế độ trạm không render picker, menu, link điều hướng dạng thao tác,
nút đổi trạm, nút theme, nút tải lại hoặc vùng action được truyền tùy ý. Dữ liệu quầy/trạm
vẫn được đọc tự động theo [file 1 §6](fe-01-rendering.md) và [file 2 §4](fe-02-loading.md).
Cách thiết lập trạm trước khi đưa màn vào vận hành **chưa xác định**, không nhét vào màn chỉ đọc.

## 4. Kiểm trạng thái và cửa có lý do từ hợp đồng

Cách kiểm đã dùng: tìm `operationId`, theo `requestBody` → `$ref` → schema, đọc `required`
và `properties` (kể cả `allOf`). Với nhãn, đi từ schema phản hồi tới đúng trường `status`/`state`
và `enum`. Không lấy enum ở một phản hồi hẹp làm danh sách chung cho cả domain.
Có thể tìm vị trí bằng lệnh đọc sau, rồi mở vùng xung quanh; kết quả tìm không thay việc theo `$ref`:

```sh
rg -n 'operationId:|requestBody:|required:|reason:|enum:|status:|state:' docs/product/3-be/openapi.yaml
```

| Đối chiếu trong OpenAPI ngày viết | Hệ quả cho component đề xuất |
|---|---|
| `DiningTable.properties.state` có enum `empty`, `in_session`, `needs_cleaning` | Type/nhãn bàn lấy đúng trường này; màu và câu tiếng Việt pha 4 duyệt. |
| `PreorderReminder.properties.status` có enum `confirmed`, `in_progress`; `OrderCancelled.properties.status` có enum `cancelled` | Chỉ dùng trong phạm vi đúng schema, không hợp chúng thành enum đơn tổng quát. |
| `TableOrder.status`, `TakeawayOrder.status`, `OrderTransition.status` hiện là string, chưa có enum | Bộ nhãn đơn đầy đủ **chưa xác định**; đề nghị Claude bổ sung hợp đồng khi cần, không tự tạo enum FE. |
| `ProductionBoard` trả `ProductionRow`/`ProductionPart`; `pending`, `made`, `served` là trường số lượng, không là enum `status` | Hiện phần việc bằng trường BE trả; nhãn trạng thái việc đơn lẻ **chưa xác định**, không biến tên cột đếm thành enum. |

Bảng sau chỉ ánh xạ chỗ nhập lý do, không là ma trận quyền hay bản chép luật nghiệp vụ.
Quyền tra [owner vai và quyền](../../../product/3-be/02-vai-va-quyen.md).

| OperationId đã kiểm | Request schema có `reason` bắt buộc | Nơi ghép hộp lý do đề xuất |
|---|---|---|
| `changeComponentPrice` | `ComponentPriceChange` | Form đổi giá của chủ quán |
| `changeOptionSurcharge` | `OptionSurchargeChange` | Form đổi phụ thu của chủ quán |
| `changeItemComponent` | `ItemComponentChange` | Form thành phần của chủ quán |
| `discontinueMenuItem` | `MenuDiscontinuationRequest` | Xác nhận ngừng bán |
| `refundBill` | `RefundRequest` | Thao tác hoàn của quầy |
| `returnPrepayment` | `PrepaymentReturnRequest` | Thao tác trả lại của quầy |
| `correctReconciledCashCount` | `CashCountCorrectionRequest`, qua `allOf` | Form sửa số đếm của chủ quán |

`cancelOrder` và `cancelWrongMakeNote` **không khai requestBody lý do** trong hợp đồng hiện tại;
không thêm ô bắt buộc hay gửi `reason` chỉ vì tên thao tác có chữ “huỷ”. Nếu cần hộp xác nhận
không lý do, dùng AlertDialog riêng theo thiết kế pha 4. `gap_explanation` của
`ReconciliationRequest` là trường khác, không đổi tên thành `reason` hoặc ghép luật vào component chung.
Mọi kiểm hình lý do theo schema tương ứng; component không tự áp một giới hạn chữ cho mọi cửa.

## 5. Props, hook và accessibility — đề xuất

Props dữ liệu dùng type sinh từ OpenAPI; type UI như layout/mode tách khỏi enum nghiệp vụ.
Tầng 2 nhận dữ liệu qua props hoặc một hook query có tên rõ như `usePeopleQuery`;
không vừa nhận props vừa fetch cùng dữ liệu. Hook dùng factory của file 3 và options file 2.
Không fetch trong tầng 1, không copy query sang Zustand, không tính tổng trong component tiền.
Ví dụ ranh giới type cho một nhãn bàn, không chép lại union trạng thái:

```tsx
// fe/src/components/shared/table-state-badge.tsx — đề xuất
import { Badge } from '@/components/ui/badge';
import type { DiningTable } from '@/lib/api-types';
import { tableStateText } from '@/lib/display-text'; // bảng câu pha 4 duyệt
export function TableStateBadge({ state }: { state: DiningTable['state'] }) {
  return <Badge variant="outline">{tableStateText[state]}</Badge>;
}
```

Bảng câu lỗi có type `Record<ErrorCode, string>` hoặc cấu trúc tương đương, dùng chung cho
`QueryProblem` và lỗi form; bảng câu do pha 4 viết, không đưa chữ database ra UI.
Lỗi mạng/giá trị ngoài hợp đồng có cách hiện dự phòng **chưa xác định**, không tự đặt mã API.
Đối chiếu hình lỗi [hợp đồng §3](../../../product/3-be/01-hop-dong-api.md).

Mọi ô nhập có nhãn; lỗi gắn với ô bằng `aria-describedby`; dialog có tiêu đề/mô tả,
focus vào vị trí phù hợp khi mở và trả về nơi gọi khi đóng. Không phá quản lý focus của primitive.
Trên màn thao tác, điều khiển dùng được bằng bàn phím; màu trạng thái đi kèm chữ/icon có nhãn.
**Đề xuất cỡ chạm tối thiểu 44 × 44 CSS px** cho điều khiển trên máy quầy/thiết bị cảm ứng;
đo lại trên thiết bị thật ở pha 4. Đây là kích thước UI đề xuất, không phải dữ kiện quán.
Màn trạm dù là màn cảm ứng vẫn không có nút; ưu tiên chữ dễ đọc và thông tin luôn nhìn thấy.
Không dùng tooltip, toast biến mất hay yêu cầu vuốt/cuộn để giữ thông tin thiết yếu ở trạm.

Skeleton có nhãn tải cho trình đọc màn hình, phần trang trí `aria-hidden`; refetch chỉ báo nhỏ,
không nháy skeleton. Banner mất luồng không tự chiếm focus hoặc đọc lại liên tục theo heartbeat.
Hộp xác nhận giữ nội dung khi lỗi; nút gửi có guard đồng bộ tại controller như file 2,
không chỉ dựa vào `disabled`. Dấu lần gửi theo [hợp đồng §8](../../../product/3-be/01-hop-dong-api.md)
và envelope file 3; không áp dấu này cho mọi mutation, không optimistic tiền/đơn.

## 6. Theme qua token — đề xuất

Màu dùng CSS variables của shadcn/ui như `--background`, `--foreground`, `--primary`,
`--muted`, `--destructive`, `--border`, `--ring`; ánh xạ utility theo
[hướng dẫn theme](https://ui.shadcn.com/docs/theming). Khoảng cách/kích thước dùng token CSS variables
bổ sung của dự án, nối vào theme Tailwind CSS 4; không giả đó là token có sẵn của shadcn.
Biến thể `cva` chọn cách trình bày, không chứa luật chuyển trạng thái hay kiểm quyền.
Tên và giá trị token nghiệp vụ chưa chốt; không gán màu bằng chuỗi rải rác trong từng màn.

Dark mode có cần cho màn trạm **chưa xác định**. Pha 4 cần kiểm ánh sáng, độ tương phản,
cỡ chữ và chuyển động trên thiết bị thật; không tự thêm nút chuyển theme vào trạm.
Nếu chốt theme theo máy thì nơi thiết lập và persist theo ranh giới state của file 3.

## 7. Câu hỏi còn mở

Các điểm **chưa xác định** dành cho Claude/pha 4, không sửa owner trong lượt này.

1. Có cần bổ sung enum trạng thái đơn/việc trạm vào OpenAPI trước khi dựng bộ nhãn đầy đủ không?
2. Bảng câu theo `ErrorCode`, nhãn trạng thái, lời cho khách khi ngừng nhận đơn và nguồn đọc phù hợp chốt thế nào?
3. Cách thiết lập trạm ngoài màn chỉ đọc, dark mode và bộ token/cỡ chữ trên thiết bị thật là gì?
4. Những ứng viên nào thực sự có nơi dùng thứ hai; owner pha 4 sẽ ghi danh mục và đường import ở đâu?
5. Chốt bản ghim CLI/Radix, khả năng dùng `Form`, công cụ sinh type và phép kiểm component/a11y nào?

## 8. Liên kết

[fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [fe-03-state-management](fe-03-state-management.md)
· [Next.js 16.4](../nextjs-16-4-huong-dan-fe.md) · [OpenAPI](../../../product/3-be/openapi.yaml)
· [Sản xuất theo mẻ](../../../product/3-be/07-san-xuat-theo-me.md) · [Realtime BE](../../../product/3-be/09-realtime-du-phong.md).
Bộ hướng dẫn: [fe-01-rendering](fe-01-rendering.md) · [fe-02-loading](fe-02-loading.md) · [fe-03-state-management](fe-03-state-management.md) · [fe-04-shared-components](fe-04-shared-components.md); danh sách trang (fe-05-danh-sach-trang.md) viết sau.
