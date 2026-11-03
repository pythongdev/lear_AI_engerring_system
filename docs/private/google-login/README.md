# Đăng nhập khách bằng Google — trạng thái và các bước còn lại (T-267)

Ghi ngày **2026-10-29** bởi Claude Code theo yêu cầu chủ repo. Đây là sổ tay việc cần làm, không phải nơi giữ
luật: thiết kế ở [ADR-132](../../decisions.md), lời chủ repo ở [shop-facts §8.8 lượt bốn](../../../master_plan/shop-facts.md),
trạng thái task ở [backlog](../../../work/backlog.md) mục T-267.

## Đã xong chưa?

**Code đã xong nhưng task chưa đóng hẳn.** Phần code nằm trong cây làm việc và `./scripts/gate.sh` xanh toàn bộ ngày
2026-10-29 (db-check 40 bước, be-check gồm các test Google, fe-check 546 test, hợp đồng 0.53.0). Client ID cũng đã tạo.
Còn bốn việc: thêm test user, thử thật trên trình duyệt, chủ repo duyệt ADR-132, và commit — commit phải đi **sau
T-264**, vì thư mục `be/internal/khach/` của T-264 cũng chưa commit.

## Thông tin Google Cloud

Tài khoản `pythondevhn2023@gmail.com`, project **`banh-cuon-ba-thanh`** (Project ID trùng tên), không gắn billing.
Consent screen (Google Auth Platform) ở trạng thái **Testing**, User type **External**, app name *Bánh cuốn Bà Thanh*,
support email và developer contact là chính tài khoản ấy, chỉ scope mặc định. OAuth client **`banhcuon-web-dev`**
loại Web application, Authorized JavaScript origin duy nhất `http://localhost:3000`, redirect URI để trống.

Client ID (công khai theo thiết kế của Google — nó nằm trong trang web gửi cho trình duyệt, nên ghi ở đây được):

```text
137422118286-l9nvspa53anfh06fiibpbk77tnhni2e0.apps.googleusercontent.com
```

Client Secret **không** được chép ra và không cần: luồng ID token của ADR-132 không dùng nó.

## Các bước còn lại, theo thứ tự

1. ~~**Thêm test user.**~~ **Xong 2026-10-29** (phiên Remote Control): trang Audience ghi *"1 user (1 test, 0 other) /
   100 user cap"* — `pythondevhn2023@gmail.com` là test user. Lần đầu panel quay "Loading" không lưu; lần sau lưu được,
   có lẽ vì project đã tạo được một lúc. Ở chế độ Testing, chỉ email này đăng nhập được bằng Google — muốn thêm người
   thử thì thêm ở Audience → *+ Add users* (tối đa 100).

2. **Thử thật.** *Kiểm phía máy, Claude chạy 2026-10-29 với phiên dev đã bật kèm Client ID:* gửi token rác tới
   `POST /customer-sessions/google` ⇒ `{"code":"google_token_invalid"}` (backend đã nhận Client ID — chưa có thì là
   `google_login_disabled`); database dev có bảng `customer_google_identity` (0 dòng); trang `/khach/dang-ky` có nút
   *Tiếp tục với Google* và script `gsi/client`, Client ID nằm trong mã JS gửi xuống trình duyệt; máy tải được khoá ký
   của Google (HTTP 200). **Còn lại phần chỉ người làm được:** bấm nút và chọn tài khoản test user. Lệnh bật dev, ở thư
   mục repo:

   ```bash
   make dev BANHCUON_GOOGLE_CLIENT_ID=137422118286-l9nvspa53anfh06fiibpbk77tnhni2e0.apps.googleusercontent.com NEXT_PUBLIC_GOOGLE_CLIENT_ID=137422118286-l9nvspa53anfh06fiibpbk77tnhni2e0.apps.googleusercontent.com
   ```

   Mở `http://localhost:3000/khach/dang-ky` (hoặc `/khach/dang-nhap`). Cần thấy: nút *Tiếp tục với Google* phía trên
   form; bấm, chọn tài khoản → về `/khach/tai-khoan`, tên và Gmail lấy từ Google; đăng xuất rồi bấm lại → vào **cùng**
   tài khoản. Nếu Gmail ấy đã đăng ký bằng mật khẩu trước đó, màn phải báo *"Gmail này đã có tài khoản đặt bằng mật
   khẩu…"* — đúng thiết kế, không phải lỗi. Google nói client mới có thể cần 5 phút đến vài giờ: nút báo lỗi origin
   ngay lúc đầu thì đợi rồi thử lại.

3. ~~**Duyệt ADR-132.**~~ **Xong 2026-10-29** — chủ repo nói *"duyệt"*, ADR-132 thành *Đã chốt*.

4. **Commit: chạy `bash docs/private/google-login/commit-t267-t270.sh`** (dựng lại 2026-11-01). T-264 đã vào ở `02d6fbe`.
   Script ghi T-267 rồi T-270 từ hai cây đã kiểm trên HEAD `de881a2`, tự dừng nếu HEAD đã đổi hay thiếu file scope.
   `commit-khach.sh`, `T-267.patch`, `T-270.patch` đã cũ, đừng dùng. **T-248 commit sau** phải nâng hợp đồng lên **0.55.0** trở lên.

5. **Dọn — chỉ sau khi script chạy xong.** Lần trước các lệnh dọn chạy trước commit nên bản vá ở
   `../lean_wt/` và file scope đã mất; Claude dựng lại. Sau commit:

   ```bash
   git worktree remove --force ../lean_wt/T-270
   git worktree remove --force ../lean_wt/T-264
   git worktree remove --force ../lean_wt/khach-commits
   git branch -D codex/T-264
   git branch -D codex/T-270
   rm work/scope/T-264.txt work/scope/T-267.txt work/scope/T-270.txt
   ```

   Thư mục này (`docs/private/google-login/`) giữ hay xoá tuỳ chủ repo; nó không nằm trong commit nào.

## Xác nhận Gmail khách qua thư (T-270, ADR-133)

Code xong, `./scripts/gate.sh` ở clone chính xanh 2026-10-29 (db-check 41 bước gồm `i035_email_verification`,
be-check gồm `TestI035_EmailVerification*`, hợp đồng 0.54.0). Khách đăng ký bằng Gmail + mật khẩu ⇒ dùng được ngay,
Gmail **chờ xác nhận**; thư mang link `http://localhost:3000/khach/xac-nhan-gmail?ma=…` sống 24 giờ; trang tài khoản hiện
*Gmail đang chờ xác nhận* + nút *Gửi lại thư xác nhận* (tối đa 3 thư một giờ). Chỉ Gmail đã xác nhận mới dùng để đăng
nhập và nhận thư đặt lại mật khẩu. Gmail từ nút Google vào thẳng, không cần thư.

**Muốn nhận thư thật ở máy dev** phải cấu hình SMTP (đường PT-7). Chưa cấu hình thì máy chỉ ghi log *"chưa cấu hình
SMTP"*, đăng ký vẫn chạy, Gmail cứ chờ. Ví dụ với Gmail SMTP — cần **App Password** của tài khoản Google (Google
Account → Security → 2-Step Verification → App passwords), không dùng mật khẩu thường:

```bash
make dev BANHCUON_GOOGLE_CLIENT_ID=<client-id> NEXT_PUBLIC_GOOGLE_CLIENT_ID=<client-id> \
  BANHCUON_SMTP_HOST=smtp.gmail.com BANHCUON_SMTP_PORT=587 \
  BANHCUON_SMTP_FROM="Bánh cuốn Bà Thanh <pythondevhn2023@gmail.com>" \
  BANHCUON_SMTP_USER=pythondevhn2023@gmail.com BANHCUON_SMTP_PASSWORD=<app-password>
```

*Đã thử 2026-10-29:* biến đặt trên dòng lệnh `make` được GNU make đưa vào môi trường của tiến trình con, nên các
biến `BANHCUON_SMTP_*` tới backend dù không nằm trong `BE_ENV`. Mật khẩu ứng dụng không bao giờ ghi vào file trong repo.

## Khi đưa lên mạng thật (chưa làm bây giờ)

Cần tên miền chính thức — câu hỏi `U-094` trong `docs/product/99-unknowns.md`, chủ repo trả lời 2026-10-19 *"Chưa có
tên miền"*. Khi có: thêm `https://<tên miền>` vào Authorized JavaScript origins của `banhcuon-web-dev` (hoặc tạo client
riêng cho production), đặt hai biến môi trường trên máy chủ, rồi chuyển consent screen sang **In production** để mọi
khách đăng nhập được, không chỉ test user.
