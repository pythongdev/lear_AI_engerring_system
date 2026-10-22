# Guideline phong cách giao diện

> **Thiết kế tĩnh — đề xuất, không phải hợp đồng.** Viết ngày **2026-10-22**, theo yêu cầu của **chủ repo**. Nguồn phong cách là [menu.html](../khach_hang/menu/menu.html), bản trong working tree tại lúc viết. Route và component thật thuộc [khung frontend](../../01-khung-fe.md). Guideline dùng cho các bản thiết kế trong [khách hàng](../khach_hang/) và [chủ quán](../chu_quan/).
>
> Tên món, giá, số lượng, nhãn bàn, tổng tiền và câu chữ nghiệp vụ trong mẫu dưới đây **chỉ là minh hoạ của nguồn**, không xác nhận dữ kiện hay luật kinh doanh. Các tên `data-component` là nhãn khối của bản thiết kế.

## 1. Tinh thần chung

Nền trung tính, thẻ phẳng có viền mảnh, điểm nhấn cam; chữ phụ xám và phần thao tác tách rõ khỏi nội dung. Mẫu mặc định tối, có nút chuyển sáng. Dùng cùng hệ màu, chữ, viền và trạng thái cho trang mới; chọn khối phù hợp với nội dung của trang.

**Suy ra (đề xuất áp dụng chung):** giữ thứ bậc nền → thẻ → trường nhập và dành màu cam cho thao tác chính, lựa chọn hiện tại, số liệu cần nhấn. Trang chủ quán có thể dùng vùng làm việc rộng hơn, nhưng nguồn không cho token chiều rộng desktop hay bố cục sidebar; không coi khung điện thoại là yêu cầu cho mọi trang.

## 2. Design tokens lấy từ nguồn

Chỉ màu có tên biến CSS trong nguồn. Các tên class/selector dưới đây là nơi sử dụng giá trị, không phải bộ token mới được đặt thêm. Đơn vị kích thước là `px` trừ khi ghi khác.

### Màu tối và sáng

| Token | Tối (`:root`) | Sáng (`:root[data-theme=light]`) | Dùng cho |
|---|---|---|---|
| `--bg` | `#000000` | `#FFFFFF` | Nền khung chính, vùng sticky |
| `--card` | `#1F2937` | `#F3F4F6` | Thẻ, tóm tắt, dialog, thông báo |
| `--line` | `#2D3748` | `#E5E7EB` | Viền và đường phân cách |
| `--muted` | `#9CA3AF` | `#6B7280` | Chữ phụ, placeholder, tab chưa chọn |
| `--accent` | `#FF7A1A` | `#EA6A0C` | Nút chính, giá, lựa chọn, focus |
| `--field` | `#374151` | `#E5E7EB` | Input, chip, nền ảnh, nút giảm |
| `--text` | `#F9FAFB` | `#111827` | Chữ mặc định |
| `--page` | `#0a0a0a` | `#F3F4F6` | Nền ngoài khung, điều hướng cuối |
| `--notch` | `#0f172a` | `#E5E7EB` | Viền điện thoại và notch |
| `--banner` | `#3a2310` | `#FDE8D4` | Nền banner |
| `--banner-ink` | `#7c4a23` | `#C2702F` | Chữ/ảnh minh hoạ giữa banner |
| `--badge` | `#3a2a18` | `#FDECDC` | Nền badge |

Các màu cố định sau không đổi theo theme:

| Selector | Giá trị thật | Dùng cho |
|---|---|---|
| `.primary`, nút cuối stepper, lựa chọn nhân đã chọn | `#fff` | Chữ trên cam |
| `.heart` | nền `#ffffffcc`, chữ `#6b7280` | Nút yêu thích |
| `.heart[aria-pressed=true]` | `#ef4444` | Tim đã chọn |
| `.saved` | `#22c55e` | Nhãn lưu minh hoạ |
| `.checkout .count` | `#ff9a4d` | Nền số lượng trên nút thanh toán |
| `dialog::backdrop` | `#000b` | Lớp phủ sau dialog |
| `button`, `.compact.stepper button` | `transparent` | Nền trong suốt |

Nguồn không dùng `rgb()`/`rgba()` hay thuộc tính `opacity`. **Suy ra từ hex alpha:** `#ffffffcc` là trắng với alpha 80%; `#000b` là đen với alpha khoảng 73,33%. Đây là độ trong suốt của màu nền, không phải độ mờ toàn bộ component.

### Chữ

| Nơi dùng | Cỡ / độ đậm / chiều cao dòng |
|---|---|
| `body` | `12px/1.45 'Be Vietnam Pro',system-ui,sans-serif`; không khai báo riêng weight |
| `button,input,textarea` | `font:inherit; color:inherit` rồi ghi đè theo selector |
| `h1` | `20px`, `600`; mobile `19px` |
| `h2,h3` | `14px`, `500`; `.card h3` line-height `1.4`, mobile `13px` |
| `.status`, `.header small`, nút mini, thẻ yêu thích, danh sách thành phần, chi tiết, mô tả, ghi chú | `11px` |
| Chip, badge, lựa chọn nhân, tạm tính, bảng | `10px` |
| `th`, một số ô bảng, điều hướng cuối | `9px`; `th` có weight `400` |
| Tab, label, badge đếm trên nút thanh toán | `12px` |
| `.order-line .name`, `.total`, nút thanh toán drawer | `13px` |
| Giá trong controls, số lượng stepper | `14px` |
| Nút thanh toán chính | `15px` |
| Banner, tiêu đề dialog, tổng trong dialog xác nhận (inline) | `16px` |
| Nút stepper | `17px`; bản compact `12px`, output compact `11px` |
| Tổng trong drawer (inline) | `18px` |
| Emoji ảnh yêu thích / ảnh thẻ | `20px` / `26px` |
| Tim yêu thích | `13px` |

Không có thẻ nạp webfont, `@font-face` hoặc `@import`. Tên Be Vietnam Pro chỉ được khai báo; font hiển thị phụ thuộc font có sẵn rồi fallback về `system-ui,sans-serif`. Không coi việc mở file là đã tải được Be Vietnam Pro.

### Khoảng cách, hình khối và lớp hiển thị

Nguồn dùng các số trực tiếp, không khai báo thang spacing. Bảng này gom các nhóm chính; khối CSS nguyên văn ở §3 chứa cả giá trị riêng của từng chi tiết.

| Nhóm | Giá trị trong nguồn |
|---|---|
| Gutter khung | `.phone` padding `0 15px 16px`, margin `24px auto`; mobile hai bên `10px`, margin `0 auto` |
| Gap | Row `8px`; header-actions/chips `6px`; rail/card/actions dialog `12px`; tabs `17px` → mobile `14px`; fillings `4px`; stepper `6px`, compact `3px` |
| Padding | Button `6px 10px`; card/summary/notice `12px`; card mobile `10px`; banner `10px 12px`; dialog `18px`; textarea `10px` |
| Nhịp dọc | Card margin-bottom `12px`; search margin `14px 0`; label `12px 0 8px`; banner `8px 0`; checkout margin-top `12px`; drawer-footer padding-top `24px` |
| Bo góc nhỏ | Badge `5px`; tim/count `6px`; button/textarea `7px`; search/thumb/favourite/canh/bottom-nav/notice `8px` |
| Bo góc lớn | Banner/card/summary `10px`; checkout/dialog/notch `12px`; chip `16px`; nút mini `20px`; khung phone `24px` |
| Bo góc đặc biệt | Tab `0`; phone mobile `0`; drawer `12px 0 0 12px` |
| Viền | Thường `1px solid var(--line)`; phone dùng `var(--notch)`; primary/notice dùng accent; nhánh con border-left `2px`; tab active border-bottom `3px` |
| Focus | `outline:2px solid var(--accent); outline-offset:3px` |
| Bóng đổ | Không có `box-shadow` hoặc `text-shadow` được khai báo |
| Lớp và chuyển động | Sticky `z-index:5`; notice `z-index:20`; drawer `slide-in .22s ease-out`; hover `brightness(1.15)` |

## 3. Cách nạp CSS để chép sang trang khác

Nguồn không dùng Tailwind, không cấu hình Tailwind, không nạp CDN/CSS ngoài. CSS nằm trong một thẻ `<style>` ở `<head>`, JavaScript nằm cuối `<body>`. Dùng viewport như nguồn:

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

Khối sau chép nguyên CSS từ nguồn. Đặt trong `<style>` của bản thiết kế mới để dùng các class ở §4; các selector `body`, `button`, `table`, `dialog` có tác dụng toàn trang.

```css
:root { color-scheme:dark; --bg:#000000; --card:#1F2937; --line:#2D3748; --muted:#9CA3AF; --accent:#FF7A1A; --field:#374151; --text:#F9FAFB; --page:#0a0a0a; --notch:#0f172a; --banner:#3a2310; --banner-ink:#7c4a23; --badge:#3a2a18}
:root[data-theme=light] { color-scheme:light; --bg:#FFFFFF; --card:#F3F4F6; --line:#E5E7EB; --muted:#6B7280; --accent:#EA6A0C; --field:#E5E7EB; --text:#111827; --page:#F3F4F6; --notch:#E5E7EB; --banner:#FDE8D4; --banner-ink:#C2702F; --badge:#FDECDC}
* { box-sizing:border-box}
body { margin:0; background:var(--page); color:var(--text); font:12px/1.45 'Be Vietnam Pro',system-ui,sans-serif}
button,input,textarea { font:inherit; color:inherit}
button { cursor:pointer; border:1px solid var(--line); border-radius:7px; background:transparent; padding:6px 10px}
button:hover { filter:brightness(1.15)}
:focus-visible { outline:2px solid var(--accent); outline-offset:3px}
h1,h2,h3,p { margin:0}
h1 { font-size:20px; font-weight:600}
h2,h3 { font-size:14px; font-weight:500}
.muted { color:var(--muted)}
.price { color:var(--accent); white-space:nowrap}
.primary { background:var(--accent); border-color:var(--accent); color:#fff}
.plain { border:0; padding:0}
.row { display:flex; align-items:center; justify-content:space-between; gap:8px}
.phone { max-width:472px; margin:24px auto; background:var(--bg); border:1px solid var(--notch); border-radius:24px; padding:0 15px 16px; overflow:clip}
.status { height:30px; font-size:11px; position:relative}
.status:after { content:''; width:150px; height:16px; border-radius:12px; background:var(--notch); position:absolute; top:5px; left:50%; transform:translateX(-50%)}
.sticky { position:sticky; top:0; z-index:5; background:var(--bg)}
.header { min-height:58px; border-bottom:1px solid var(--line)}
.header small { font-size:11px; color:var(--muted)}
.header-actions { display:flex; gap:6px}
.mini { height:50px; gap:8px; border-bottom:1px solid var(--line)}
.mini>button { border-radius:20px; white-space:nowrap; font-size:11px; padding:4px 9px}
.chips { display:flex; gap:6px; overflow:auto; scrollbar-width:none; flex:1}
.chip { background:var(--field); border-radius:16px; white-space:nowrap; font-size:10px; padding:4px 8px}
.banner { height:96px; background:var(--banner); border-radius:10px; margin:8px 0; display:flex; flex-direction:column; justify-content:end; padding:10px 12px; gap:18px}
.banner div { text-align:center; color:var(--banner-ink); font-size:16px}
.search { background:var(--field); border:0; border-radius:8px; width:100%; height:34px; padding:0 12px; margin:14px 0}
input::placeholder,textarea::placeholder { color:var(--muted)}
.tabs { display:flex; gap:17px; border-bottom:1px solid var(--line); overflow:auto; white-space:nowrap}
.tabs button { border:0; border-radius:0; color:var(--muted); padding:10px 0; font-size:12px}
.tabs .active { color:var(--accent); border-bottom:3px solid var(--accent)}
.label { font-size:12px; color:var(--muted); margin:12px 0 8px}
.rail { display:flex; gap:12px; overflow:auto}
.favourite { flex:0 0 112px; border:1px solid var(--line); background:var(--card); border-radius:8px; overflow:hidden; font-size:11px}
.fav-image { height:56px; background:var(--field); display:grid; place-items:center; position:relative; font-size:20px}
.heart { position:absolute; right:4px; top:4px; background:#ffffffcc; color:#6b7280; border:0; padding:1px 5px; border-radius:6px; font-size:13px}
.heart[aria-pressed=true] { color:#ef4444}
.fav-copy { padding:4px 6px}
.fav-copy p { margin-top:3px}
.card { display:grid; grid-template-columns:80px minmax(0,1fr) 110px; gap:12px; padding:12px; border:1px solid var(--line); background:var(--card); border-radius:10px; margin-bottom:12px; min-height:142px}
.thumb { height:80px; background:var(--field); border-radius:8px; display:grid; place-items:center; font-size:26px; position:relative}
.thumb>.plain { font-size:26px}
.card-copy { display:flex; flex-direction:column; align-items:start; min-width:0}
.card h3 { line-height:1.4; margin-bottom:5px}
.dishes { list-style:none; padding:0; margin:0; color:var(--muted); font-size:11px}
.dishes li { display:flex; gap:6px; align-items:center; margin-bottom:3px}
.badge { background:var(--badge); color:var(--accent); padding:1px 5px; border-radius:5px; font-size:10px; white-space:nowrap}
.detail { color:var(--accent); font-size:11px; margin-top:auto; padding-top:8px}
.controls>.price { font-size:14px; margin-bottom:6px}
.stepper { display:inline-flex; align-items:center; gap:6px; white-space:nowrap}
.stepper button { width:30px; height:30px; padding:0; background:var(--field); border:0; font-size:17px}
.stepper button:last-child { background:var(--accent); color:#fff}
.stepper output { min-width:24px; text-align:center; font-size:14px}
.fillings { display:flex; flex-direction:column; gap:4px; margin-top:12px}
.fillings button { padding:4px 3px; font-size:10px; color:var(--muted); white-space:nowrap}
.fillings button[aria-pressed=true] { background:var(--accent); border-color:var(--accent); color:#fff}
.description { color:var(--muted); font-size:11px}
.product { cursor:pointer}
.soup-card { min-height:100px}
.summary { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:12px; margin-top:12px}
.summary .label { font-size:11px; margin-top:16px}
summary { cursor:pointer; list-style:none}
summary::-webkit-details-marker { display:none}
.disclosure:after { content:'⌄ Hiện'; color:var(--muted); font-size:11px; margin-left:auto}
details[open]>.disclosure:after { content:'⌄ Ẩn'}
.order-line { display:flex; align-items:center; gap:6px}
.order-line .name { flex:1; font-size:13px}
.compact.stepper { gap:3px}
.compact.stepper button { width:23px; height:23px; background:transparent; border:1px solid var(--line); color:var(--muted); font-size:12px}
.compact.stepper output { min-width:19px; font-size:11px}
.order-line>.price { font-size:10px; color:var(--muted)}
.trash { border:0; padding:0; font-size:11px; color:var(--muted)}
.subitems { border-left:2px solid var(--line); padding-left:10px; margin:8px 0 0 10px}
.subitems .order-line { margin:3px 0}
.subitems .name { font-size:11px; color:var(--muted)}
.subitems .trash { margin-left:40px}
.subtotal { text-align:right; color:var(--muted); font-size:10px; margin:5px 0 8px}
.total { border-top:1px solid var(--line); padding-top:10px; margin-top:12px; font-size:13px}
.canh { border:1px solid var(--line); border-radius:8px; padding:8px; margin-top:12px}
.canh .row { margin-top:4px; font-size:11px}
.canh output { color:var(--accent)}
.table-wrap { overflow:auto}
table { border-collapse:collapse; width:100%; font-size:10px; margin:6px 0 12px; text-align:left; white-space:nowrap}
th { font-weight:400; color:var(--muted); font-size:9px}
td,th { padding:3px 3px 3px 0}
td:nth-child(2),td:nth-child(3) { color:var(--accent); font-size:9px}
td:nth-child(4) { color:var(--muted); font-size:9px}
td:last-child,th:last-child { text-align:right}
.note { border-top:1px solid var(--line); padding-top:8px; font-size:11px}
.saved { color:#22c55e; font-size:10px}
textarea { width:100%; resize:vertical; min-height:40px; border:0; background:var(--field); border-radius:7px; padding:10px; margin-top:8px; font-size:11px}
.checkout { width:100%; height:52px; border-radius:12px; margin-top:12px; font-size:15px}
.checkout .count { background:#ff9a4d; border-radius:6px; font-size:12px; padding:3px 9px}
.bottom-nav { display:flex; justify-content:space-between; background:var(--page); border:1px solid var(--line); border-radius:8px; margin-top:10px; padding:8px 7px; font-size:9px; color:var(--muted)}
.bottom-nav a { color:inherit; text-decoration:none}
.bottom-nav a:first-child { color:var(--accent)}
dialog { width:min(380px,calc(100% - 24px)); max-height:calc(100dvh - 32px); border:1px solid var(--line); border-radius:12px; background:var(--card); color:var(--text); padding:18px; overscroll-behavior:contain}
dialog::backdrop { background:#000b}
dialog h2 { font-size:16px; margin-bottom:18px}
dialog .row { margin:10px 0}
dialog .actions { display:flex; gap:12px; margin-top:16px}
dialog .actions button { flex:1; min-height:34px}
dialog .radio { display:flex; align-items:center; gap:10px; margin:16px 0}
dialog .radio .muted { margin-left:auto; font-size:11px}
input[type=radio] { accent-color:var(--accent)}
.modal-hero { height:90px; background:var(--field); display:grid; place-items:center; margin:-18px -18px 14px; color:var(--muted)}
.drawer { margin:0 0 0 auto; height:100dvh; max-height:100dvh; border-radius:12px 0 0 12px; width:min(380px,100%)}
.drawer[open] { display:flex; flex-direction:column; animation:slide-in .22s ease-out}
.drawer h2 { margin:0}
.drawer header { border-bottom:1px solid var(--line); padding-bottom:12px}
.drawer-footer { margin-top:auto; padding-top:24px}
.drawer .order-line { margin:18px 0 2px}
.drawer .price { margin:6px 0}
.drawer .checkout { height:36px; font-size:13px}
.drawer .continue { width:100%; margin-top:8px; border:0}
.notice { position:fixed; bottom:20px; left:50%; transform:translateX(-50%); background:var(--card); border:1px solid var(--accent); border-radius:8px; padding:12px; z-index:20; width:max-content; max-width:90vw}
.notice:empty { display:none}
@keyframes slide-in { from { transform:translateX(100%)}
to { transform:translateX(0)}
}
@media(max-width:480px) { .phone { margin:0 auto; border-radius:0; padding-left:10px; padding-right:10px}
.card { grid-template-columns:64px minmax(0,1fr) 100px; gap:8px; padding:10px}
.thumb { height:64px}
.card h3 { font-size:13px}
.tabs { gap:14px}
.header h1 { font-size:19px}
.subitems .trash { margin-left:16px}
}
@media(prefers-reduced-motion:reduce) { .drawer[open] { animation:none}
}
```

Nút theme cần cả markup và JavaScript dưới đây (chép nguyên nguồn). CSS mặc định tối; script đặt `data-theme` trên phần tử gốc và nhớ lựa chọn bằng khoá `menu-theme`. Khi storage không dùng được, mẫu vẫn chuyển theme trong phiên và khởi tạo tối.

```html
<button id="theme-toggle" aria-label="Chuyển giao diện sáng" title="Chuyển sáng / tối">☀️</button>
```

```js
const themeBtn = document.querySelector('#theme-toggle');
const applyTheme = t => { document.documentElement.dataset.theme = t; themeBtn.textContent = t === 'light' ? '🌙' : '☀️'; themeBtn.setAttribute('aria-label', t === 'light' ? 'Chuyển giao diện tối' : 'Chuyển giao diện sáng'); };
try { applyTheme(localStorage.getItem('menu-theme') || 'dark'); } catch { applyTheme('dark'); }
themeBtn.addEventListener('click', () => { const t = document.documentElement.dataset.theme === 'light' ? 'dark' : 'light'; applyTheme(t); try { localStorage.setItem('menu-theme', t); } catch {} });
```

## 4. Mẫu component

Các đoạn dưới chép nguyên dòng hoặc phần tử từ nguồn. Những đoạn có `${...}` là **template literal JavaScript**, dùng cùng dữ liệu và helper tương ứng, không dán thẳng thành HTML để chạy. Có thể chép toàn bộ nguồn khi cần bản demo hoạt động; riêng CSS/class không tạo hành vi cho `data-open`, `data-close`, `data-step`. Nội dung nghiệp vụ trong đoạn trích giữ nguyên để đối chiếu, chỉ có ý nghĩa minh hoạ.

### Header và thanh giỏ nhỏ

Header có tiêu đề, chữ phụ và nhóm nút sát nhau. Header cùng thanh giỏ nằm trong `.sticky`; giỏ nhỏ gồm nút chính, dải chip cuộn ngang và số tiền nhấn cam.

```html
<div class="sticky"><header class="header row" data-component="MenuHeader"><div><h1>Quán Bánh Cuốn</h1><small>Bàn 03</small></div><div class="header-actions"><button id="theme-toggle" aria-label="Chuyển giao diện sáng" title="Chuyển sáng / tối">☀️</button><button data-demo>⎆ Đăng nhập</button></div></header>
<div class="mini row" data-component="MiniCartStrip"><button class="primary" data-open="cart">3 món</button><div class="chips"><span class="chip">Combo Đầy Đặn ×1</span><span class="chip">Bánh cuốn thịt ×1</span><span class="chip">Canh ×1</span></div><span class="price">77.000đ</span></div></div>
```

### Banner, tìm kiếm, tab và dải thẻ yêu thích

Banner là mảng màu ấm, chưa có ảnh thật. Search dùng nền field, không viền. Tab chọn dùng chữ cam và gạch chân; chip chỉ là nhãn, không phải tab tương tác. Rail giữ thẻ rộng cố định và cho cuộn ngang.

```html
<section class="banner" data-component="RestaurantBanner"><div>🥟 ảnh quán</div><p>Bánh cuốn tươi — ngon mỗi ngày</p></section>
<input class="search" data-component="SearchBar" type="search" aria-label="Tìm món nhanh" placeholder="🔍   Tìm món nhanh...">
<nav class="tabs" data-component="CategoryTabs" aria-label="Danh mục"><button class="active" aria-pressed="true">Tất cả</button><button aria-pressed="false">Bánh cuốn</button><button aria-pressed="false">Đồ uống</button><button aria-pressed="false">Combo</button><button aria-pressed="false">Tráng miệng</button></nav>
<section data-component="FavouritesRail" id="favourites"><h2 class="label">YÊU THÍCH</h2><div class="rail" id="favourites-list"></div></section>
```

```html
<article class="favourite"><div class="fav-image">🍜${heart(true)}</div><div class="fav-copy">${name}<p class="price">${price}</p></div></article>
```

### Thẻ món, badge, nút và bộ đếm

Thẻ có ba cột: ảnh, nội dung, controls. `.card-copy` cho nội dung co lại; nút chi tiết đẩy xuống cuối. Badge nhỏ nằm cạnh thành phần; các nút lựa chọn dùng `aria-pressed`. Thẻ món lẻ dùng cùng `.card`, thêm `.product` hoặc `.soup-card` và phần `.description`.

```html
<article class="card" data-component="ComboCard"><div class="thumb">🍱${heart()}</div><div class="card-copy"><h3>${name}</h3><ul class="dishes">${dishes.map(([dish,qty]) => `<li><span class="badge">×${qty}</span>${dish}</li>`).join('')}</ul><button class="plain detail" data-open="combo">Chi tiết</button></div><div class="controls"><p class="price">${price}</p>${step(n)}${fillings()}</div></article>
```

```html
<article class="card ${n ? 'product' : 'soup-card'}" data-component="ProductCard" ${n ? 'data-product' : ''}><div class="thumb"><button class="plain" ${action} aria-label="${name}">${emoji}</button>${heart()}</div><div class="card-copy"><h3><button class="plain" ${action}>${name}</button></h3><p class="description">${desc}</p><button class="plain detail" ${action}>Chi tiết</button></div><div class="controls"><p class="price">${price}</p>${step(n)}${n ? fillings() : ''}</div></article>
```

Các helper nguyên văn để tạo stepper, tim và lựa chọn:

```js
const step = (n, compact = false) => `<span class="stepper ${compact ? 'compact' : ''}"><button data-step="-1" aria-label="Giảm số lượng">−</button><output aria-live="polite">${n}</output><button data-step="1" aria-label="Tăng số lượng">＋</button></span>`;
const heart = (on = false) => `<button class="heart" aria-label="Yêu thích" aria-pressed="${on}">${on ? '♥' : '♡'}</button>`;
const fillings = () => '<div class="fillings" aria-label="Chọn nhân"><button aria-pressed="true">Nhân thịt</button><button aria-pressed="false">Nhân thịt mộc nhĩ</button></div>';
```

### Tóm tắt, bảng, ghi chú và nút cuối trang

Tóm tắt nằm trong thẻ, dùng `details/summary` để mở/thu; `.subitems` đánh dấu nội dung con bằng viền trái. Dòng đơn dùng stepper compact. Bảng có wrapper cuộn ngang. Nút thanh toán là một hàng lớn có count và tổng; điều hướng cuối dùng nền page. Cả hai nằm trong luồng trang, không fixed.

```js
const line = (name, n, price = '') => `<div class="order-line"><span class="name">${name}</span>${step(n,true)}${price ? `<span class="price">${price}</span>` : ''}<button class="trash" aria-label="Xóa ${name}">🗑</button></div>`;
```

```html
<section class="summary" data-component="OrderSummary" id="summary"><details open><summary class="row disclosure"><h2>Tóm tắt đơn hàng</h2><span class="badge">Bàn 03</span></summary>
<h3 class="label">COMBO</h3><div id="summary-combo"></div><span class="badge">Nhân thịt</span><details open class="combo-breakdown"><summary class="detail">⌃ Ẩn chi tiết</summary><div class="subitems" id="subitems"></div></details><p class="subtotal">Subtotal: 42.000đ</p>
<details open><summary class="row label disclosure">TỔNG SỐ MÓN (5 LOẠI)</summary><div class="table-wrap"><table><thead><tr><th>Món</th><th>Nhân</th><th>SL</th><th>Đơn giá</th><th>Thành tiền</th></tr></thead><tbody id="dish-totals"></tbody></table></div></details>
<div class="note"><div class="row"><label for="note" class="muted">GHI CHÚ</label><span class="saved">✓ Đã lưu</span></div><textarea id="note" placeholder="ít hành, mang thêm tương ớt..."></textarea></div></details></section>
<button class="checkout primary row" data-component="CartBottomBar" data-open="confirm"><span class="count">3</span><span>Thanh toán</span><span>77.000đ</span></button>
<nav class="bottom-nav" data-component="ClientBottomNav" aria-label="Điều hướng cuối trang"><a href="#menu">🏠 Menu</a><span>🧾 Đơn</span><a href="#favourites">♥ Thích</a><span>📡 Theo dõi</span><span>⚙ Cài đặt</span></nav>
```

Đây là các trích đoạn riêng của khối tóm tắt, không phải một tài liệu HTML hoàn chỉnh; lấy đầy đủ phần đóng/mở khối từ nguồn khi ghép.

### Dialog, drawer và thông báo

Dialog dùng nền thẻ và backdrop đen trong suốt. Drawer bám bên phải viewport, có header, các dòng đơn và footer đẩy xuống cuối. Thông báo nổi ở đáy viewport, dùng `role="status"` và `aria-live="polite"`.

```html
<dialog id="confirm" aria-labelledby="confirm-title"><h2 id="confirm-title">Xác nhận đặt hàng</h2><div class="row"><span>1× Combo Đầy Đặn</span><span class="price">42.000đ</span></div><div class="row"><span>1× Bánh cuốn thịt</span><span class="price">35.000đ</span></div><div class="row"><span>1× Canh (có rau)</span><span class="price">0đ</span></div><div class="row total"><span>Tổng cộng</span><span class="price" style="font-size:16px">77.000đ</span></div><textarea id="kitchen-note" aria-label="Ghi chú cho bếp (tuỳ chọn)" placeholder="Ghi chú cho bếp (tuỳ chọn)"></textarea><div class="actions"><button data-close>Hủy</button><button class="primary" data-place>Đặt hàng</button></div></dialog>
<dialog id="cart" class="drawer" aria-labelledby="cart-title"><header><div class="row"><h2 id="cart-title">Giỏ hàng</h2><button class="price" data-view>▤ Xem đơn</button><button class="plain" data-close aria-label="Đóng giỏ hàng">✕</button></div><p class="muted" style="font-size:11px">Khách · Bàn 03</p></header><div class="row"><h3>Tóm tắt đơn hàng</h3><span class="chip">3 món</span></div><div id="cart-lines"></div><div class="drawer-footer"><div class="row total"><span class="muted">Tổng cộng</span><span class="price" style="font-size:18px">77.000đ</span></div><button class="checkout primary" data-open="confirm">Thanh toán</button><button class="continue muted" data-close>Tiếp tục chọn món</button></div></dialog>
<div class="notice" role="status" aria-live="polite"></div>
```

## 5. Bố cục và responsive

Khung `.phone` rộng tối đa `472px`, căn giữa trên nền page; đây là bản mô phỏng điện thoại ngay cả trên màn hình rộng. `box-sizing:border-box` áp dụng toàn trang. `.status` cao `30px` kèm notch trang trí `150×16px`; header cao tối thiểu `58px`, mini cart cao `50px`. Phần sticky bám `top:0`, còn banner, search, danh sách, tóm tắt và nút cuối tiếp tục theo luồng dọc.

Lưới thẻ là `80px minmax(0,1fr) 110px`, gap `12px`; ảnh cao `80px`. Thẻ thường cao tối thiểu `142px`, `.soup-card` là `100px`. Thẻ yêu thích rộng cố định `112px`, ảnh cao `56px`. Danh sách chính không chuyển thành lưới nhiều thẻ trên desktop.

Tại `max-width:480px`, khung bỏ bo góc và margin dọc, gutter còn `10px`; thẻ đổi sang `64px minmax(0,1fr) 100px`, gap `8px`, padding `10px`, ảnh cao `64px`. Header còn `19px`, tiêu đề thẻ `13px`, gap tab `14px`; nút xoá trong nhánh con giảm margin-left từ `40px` xuống `16px`. Không có breakpoint khác cho chiều rộng.

Chip, tab, rail và bảng dùng `overflow:auto`; chip ẩn thanh cuộn bằng `scrollbar-width:none`. Dialog rộng `min(380px,calc(100% - 24px))`, cao tối đa `calc(100dvh - 32px)`; drawer rộng `min(380px,100%)`, cao `100dvh`. Notice rộng theo nội dung, tối đa `90vw`, cách đáy `20px`.

**Suy ra (đề xuất áp dụng chung):** giữ gutter, nhịp thẻ và cách cuộn vùng hẹp khi chuyển sang màn khác. Nguồn không chứng minh rằng mọi nội dung dài hay mọi viewport rất hẹp đều vừa; cần kiểm tra tên dài và các cột thao tác ở trang mới. Không tự suy ra sidebar hay breakpoint desktop từ mẫu này.

## 6. Trạng thái tương tác và giới hạn mẫu

| Trạng thái | Có trong nguồn |
|---|---|
| Hover | Mọi button dùng `filter:brightness(1.15)`; không có hover riêng cho thẻ |
| Được chọn | Tab dùng `.active` + `aria-pressed`; fillings dùng `aria-pressed=true` với nền cam; tim chuyển `♡`/`♥` và màu đỏ; radio dùng `accent-color` |
| Active khi nhấn | Không khai báo pseudo-class `:active`; `.active` là trạng thái tab đang chọn |
| Focus | `:focus-visible` có outline cam; dialog mở bằng `showModal()`, đóng bằng nút, Escape hoặc click ngoài và trả focus về trigger khi còn tồn tại |
| Mở/thu | `details[open]` đổi nhãn Hiện/Ẩn; `.combo-breakdown` đổi chữ bằng JavaScript |
| Drawer mở | Trượt từ phải trong `.22s ease-out`; tắt animation khi `prefers-reduced-motion:reduce` |
| Thông báo | `.notice:empty` ẩn; thông báo demo tự xoá sau `2600ms` |
| Disabled | Không có thuộc tính `disabled` hay style `:disabled`; bộ đếm chặn số âm bằng JavaScript, không vô hiệu hoá nút giảm |
| Loading | Không có spinner, skeleton, trạng thái đang gửi hay tiến trình tải |
| Lưu/hoàn tất | Nhãn “✓ Đã lưu” là markup cố định; đặt hàng chỉ hiện thông báo bản minh hoạ, không gửi đơn |

Tìm kiếm chưa có handler lọc; tab chỉ đổi trạng thái chọn. Các bộ đếm và tổng tiền độc lập trong bản minh hoạ, không phải cơ chế tính đơn. Phần xử lý dialog khoá cuộn body khi mở và khôi phục khi đóng. Không suy diễn các hành vi demo này thành hợp đồng sản phẩm.

## 7. Nên và không nên

Các quy tắc sau là **suy ra — đề xuất áp dụng chung** từ mẫu:

| Nên | Không nên |
|---|---|
| Dùng biến màu và kiểm tra cả hai theme | Gán màu tối cố định cho bề mặt mới rồi bỏ quên theme sáng |
| Giữ thẻ phẳng, viền mảnh và phân cấp chữ | Thêm gradient, bóng nổi hoặc nhiều màu nhấn rồi gọi đó là phong cách nguồn |
| Giữ focus rõ, nhãn cho nút icon, trạng thái `aria-pressed` | Chỉ đổi màu mà bỏ trạng thái có thể đọc bằng công cụ hỗ trợ |
| Dùng mẫu phù hợp nội dung trang khách hoặc chủ quán | Ép mọi trang vào notch và chiều rộng mô phỏng điện thoại |
| Ghi riêng mọi bổ sung như loading/disabled là đề xuất mới | Gọi giá trị hoặc trạng thái không có trong nguồn là token đã xác nhận |
| Thay dữ liệu minh hoạ bằng nội dung đúng owner khi triển khai | Lấy giá, món, bộ đếm hay chữ “Đã lưu” của mockup làm sự thật |

## 8. Checklist cho trang mới

- [ ] Có ghi rõ bản thiết kế tĩnh, dữ liệu minh hoạ; route/component thật theo khung frontend.
- [ ] Màu dùng đúng biến của nguồn và đã xem cả tối lẫn sáng.
- [ ] Font có fallback; cỡ chữ, spacing, bo góc và viền đối chiếu được với CSS nguồn.
- [ ] Component chọn từ mẫu; mọi giá trị hay cấu trúc bổ sung đều ghi rõ là đề xuất/suy ra.
- [ ] Kiểm tra ở hai phía breakpoint `480px`, gồm tên dài, vùng cuộn và dialog/drawer.
- [ ] Nút icon có nhãn, focus nhìn thấy, trạng thái chọn đồng bộ và đóng dialog trả focus đúng.
- [ ] Không mô tả disabled/loading, gửi đơn, tính tổng hay lưu dữ liệu như khả năng đã có của mẫu.
