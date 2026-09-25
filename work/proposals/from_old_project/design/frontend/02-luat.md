# 02 — Luật Frontend (Next.js 16 + TypeScript)

> Cập nhật **2026-08-19** · Lane sở hữu: **FE** · Dời từ `quality/03-frontend.md` (`git log --follow`).
> Sự thật FE khác: [thiết kế](01-thiet-ke.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md) — cả bốn đã có đủ; ghi vào file nào xem [README.md §1](README.md).
> Ngoài thư mục này: [design/backend/02-luat.md](../backend/02-luat.md) (hợp đồng API) · [quality/04-devops.md](../../quality/04-devops.md)

FE của hệ thống này phục vụ **ba loại người dùng trên ba loại thiết bị khác nhau**. Chất lượng không chỉ là "không lỗi JS" — mà là nhân viên bấm trúng nút khi tay dính bột, và khách quét QR trên 4G yếu vẫn đặt được món.

---

## 1. Chặn ở compile-time trước

### `fe/tsconfig.json`

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noUnusedLocals": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

`noUncheckedIndexedAccess` là cái đáng giá nhất: `products[0]` trở thành `Product | undefined`, buộc bạn xử lý mảng rỗng. Menu rỗng vì API lỗi mà UI crash trắng màn hình là kịch bản có thật.

### `fe/eslint.config.mjs`

```js
export default [
  ...next,
  {
    rules: {
      "@typescript-eslint/no-explicit-any": "error",   // any = tắt TypeScript
      "@typescript-eslint/no-floating-promises": "error", // quên await fetch
      "react-hooks/exhaustive-deps": "error",
      "no-console": ["warn", { allow: ["error"] }],
    },
  },
];
```

`no-floating-promises` bắt lỗi quên `await` — nguyên nhân phổ biến của "bấm nút không thấy gì xảy ra".

---

## 2. Types sinh từ OpenAPI, không gõ tay

Đây là biện pháp hiệu quả nhất của cả tầng FE.

```
code/be/api/openapi.yaml
        │
        │  npx openapi-typescript ../code/be/api/openapi.yaml -o src/lib/api-types.ts
        ▼
fe/src/lib/api-types.ts   ← KHÔNG sửa tay, file sinh tự động
        │
        ▼
fe/src/lib/api.ts         ← client bọc fetch, dùng types ở trên
```

Thêm vào `fe/package.json`:

```json
{
  "scripts": {
    "gen:api": "openapi-typescript ../code/be/api/openapi.yaml -o src/lib/api-types.ts",
    "typecheck": "tsc --noEmit"
  }
}
```

CI chạy `npm run gen:api` rồi `git diff --exit-code src/lib/api-types.ts`. Có diff = ai đó đổi API mà chưa sinh lại types → CI đỏ.

**Kết quả:** BE đổi `total` thành `total_amount` → FE đỏ ngay lúc build, không phải đợi khách bấm checkout mới biết.

---

## 3. Ba luồng E2E — không nhiều hơn

Playwright, chạy trên `docker-compose` dev với DB seed.

```ts
// e2e/1-khach-qr.spec.ts
test('khách quét QR → gọi món → quầy thấy đơn', async ({ page }) => {
  await page.goto('/t/TOKEN_BAN_5');
  await page.getByText('Đầy đủ chín').click();
  await page.getByLabel('Thịt').click();
  await page.getByLabel('Thường').click();
  await expect(page.getByTestId('gia-tam-tinh')).toHaveText('30.000đ');
  await page.getByRole('button', { name: 'Gửi đơn' }).click();
  await expect(page.getByText('Đã gửi, chờ quầy xác nhận')).toBeVisible();
  // POS quầy thấy đơn pending
});

// e2e/2-tram-bep.spec.ts
test('trạm tráng bấm xong → trạm gấp thấy việc', ...);

// e2e/3-thanh-toan.spec.ts
test('gọi món 3 lần → checkout → tổng tiền khớp → bàn về free', ...);
```

Ba test này bắt ~90% lỗi tích hợp FE/BE. Nhiều hơn thì mỗi lần đổi UI phải sửa cả chục file test, và bạn sẽ ngừng chạy chúng.

**Quy tắc chọn selector:** dùng `getByRole` / `getByText` (giống cách người dùng nhìn), chỉ dùng `data-testid` cho số liệu như giá và tổng tiền. Đừng dùng class CSS — đổi Tailwind là vỡ test.

---

## 4. Test trên thiết bị thật của quán

Đây là phần hay bị bỏ qua nhất và gây đau nhất khi live.

### Ba cấu hình bắt buộc thử

| Màn hình | Người dùng | Thử gì |
|----------|-----------|--------|
| **360×640** (điện thoại rẻ) | Khách quét QR | Nút "Thêm vào giỏ" có bị che bởi thanh địa chỉ trình duyệt không |
| **768×1024** (tablet) | POS quầy, màn hình trạm | Một màn hình thấy được bao nhiêu việc mà không cuộn |
| **Slow 3G throttle** | Khách ngoài quán dùng 4G yếu | Menu có ảnh — load bao lâu, có skeleton không |

Chrome DevTools → Device Toolbar + Network throttle "Slow 3G".

### Nguyên tắc UI theo loại người dùng

Từ [01-thiet-ke.md mục 4.3](01-thiet-ke.md), biến thành thứ kiểm tra được:

| Người dùng | Nguyên tắc | Cách kiểm |
|-----------|-----------|-----------|
| Khách | Đặt được món trong ≤ 4 lần chạm | Đếm số lần chạm trong test E2E |
| Nhân viên trạm | Nút "Xong" ≥ 64×64px | Tay dính bột, bấm bằng đốt ngón tay |
| Nhân viên trạm | Chữ ≥ 20px, tương phản cao | Đứng cách tablet 1m vẫn đọc được |
| Quầy | Không có thao tác nào cần cuộn ngang | Test ở 768px |
| Tất cả | Trạng thái loading rõ ràng | Bấm 2 lần vì tưởng chưa ăn = 2 đơn |

### Chống bấm đúp ở FE

Mọi nút gửi request phải disable trong lúc chờ:

```tsx
<button disabled={pending} onClick={submit}>
  {pending ? 'Đang gửi…' : 'Gửi đơn'}
</button>
```

FE disable là lớp thứ nhất, idempotency key ở BE (xem [design/backend/02-luat.md](../backend/02-luat.md)) là lớp thứ hai. Cần cả hai — mạng chập chờn thì FE có thể reload mất state.

---

## 5. Xử lý lỗi — mạng quán không ổn định

Quán dùng wifi rẻ, 4G chập chờn. Mọi lời gọi API phải trả lời được ba câu hỏi:

| Tình huống | UI phải làm gì |
|-----------|----------------|
| Đang chờ | Skeleton hoặc spinner, nút disable |
| Lỗi mạng | Thông báo tiếng Việt rõ ràng + nút "Thử lại" |
| Lỗi 409 (việc đã có người làm) | "Việc này đã xong rồi" — không phải "Error 409" |
| Lỗi 5xx | "Hệ thống đang lỗi, gọi quầy" |
| Mất kết nối SSE | Tự reconnect + hiện chấm đỏ "mất kết nối" |

Chấm báo mất kết nối trên màn hình trạm là bắt buộc — nhân viên nhìn màn hình trống và tưởng hết việc, trong khi thực ra SSE đã chết, là kịch bản mất đơn.

### Test bắt buộc

```ts
test('mất mạng khi gửi đơn → hiện lỗi + nút thử lại', async ({ page, context }) => {
  await context.setOffline(true);
  await page.getByRole('button', { name: 'Gửi đơn' }).click();
  await expect(page.getByText('Không gửi được')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thử lại' })).toBeVisible();
});
```

---

## 6. Giỏ hàng — nơi dễ mất dữ liệu

Giỏ dùng Zustand + localStorage ([01-thiet-ke.md mục 4.4](01-thiet-ke.md)). Ba thứ phải test:

1. **Reload trang không mất giỏ** — khách chọn 5 món rồi trình duyệt reload.
2. **Giá trong giỏ phải gọi `/orders/quote` lại trước khi checkout** — không tin giá lưu trong localStorage từ hôm qua.
3. **Món bị tắt (`is_available = false`) phải bị loại khỏi giỏ** với thông báo, không âm thầm bỏ.

```ts
test('giỏ giữ sau reload', ...);
test('món hết hàng bị loại khỏi giỏ kèm thông báo', ...);
```

---

## 7. Hiệu năng — chỉ cần 3 con số

Không cần Lighthouse CI. Đo tay một lần ở tuần 6 và tuần 8:

| Chỉ số | Ngưỡng | Vì sao |
|--------|--------|--------|
| Menu load xong trên Slow 3G | < 3s | Khách đứng chờ ở quán, 5s là bỏ |
| Bundle trang `/t/[token]` | < 200KB gzip | Trang khách quét QR, tải trên 4G |
| Ảnh món | WebP, ≤ 100KB/ảnh | 8 món × 500KB = 4MB, không chấp nhận được |

Dùng `next/image` cho mọi ảnh món — nó tự resize và chuyển WebP.

---

## 8. Bẫy thường gặp

| Lỗi | Hậu quả | Cách tránh |
|-----|---------|------------|
| Gõ tay type của API | FE/BE lệch, lỗi runtime | Sinh từ `openapi.yaml` |
| Dùng `any` cho response | Mất hết lợi ích TypeScript | `no-explicit-any: error` |
| Không disable nút khi đang gửi | Khách bấm 2 lần → 2 đơn | `disabled={pending}` |
| Tin giá lưu trong localStorage | Giá cũ, checkout lệch | Gọi `/orders/quote` trước checkout |
| Nút nhỏ trên màn hình trạm | Nhân viên bấm trượt, tay dính bột | Nút ≥ 64px |
| Không hiện trạng thái mất SSE | Màn hình trống, tưởng hết việc | Chấm đỏ + tự reconnect |
| Hiện "Error 500" cho nhân viên | Không ai biết phải làm gì | Thông báo tiếng Việt + hành động cụ thể |
| Ảnh món không nén | Menu load 10s trên 4G | `next/image`, WebP ≤ 100KB |
| Test dùng selector CSS | Đổi Tailwind là vỡ hết test | `getByRole` / `getByText` / `data-testid` |

---

## Checklist FE — chạy trước mỗi lần merge

- [ ] `npm run typecheck` (`tsc --noEmit`) không lỗi
- [ ] `npm run lint` không lỗi
- [ ] `npm run gen:api` không tạo diff (types khớp `openapi.yaml`)
- [ ] Màn hình mới đã thử ở 360px và 768px
- [ ] Mọi nút gửi request có trạng thái loading + disable
- [ ] Mọi lỗi API có thông báo tiếng Việt, không hiện mã lỗi thô
- [ ] Nếu đổi luồng chính → 3 test Playwright vẫn xanh
