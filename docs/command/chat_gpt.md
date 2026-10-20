# Các câu lệnh Codex CLI trong terminal

Đối chiếu với `codex --help` của bản `codex-cli 0.157.0` (2026-10-20). Bản khác
có thể thêm/bớt lệnh — chạy `codex <lệnh> --help` để xem đúng bản đang cài.

## 1. Cài đặt, phiên bản, cập nhật
```bash
npm install -g @openai/codex         # Cài Codex CLI
codex --version                      # Xem phiên bản
codex update                         # Cập nhật lên bản mới nhất
codex doctor                         # Chẩn đoán cài đặt, cấu hình, đăng nhập
codex --help                         # Xem mọi lệnh
codex <lệnh> --help                  # Xem chi tiết một lệnh
```

## 2. Đăng nhập / đăng xuất
```bash
codex login                          # Đăng nhập bằng tài khoản ChatGPT (mở trình duyệt)
codex login --device-auth            # Đăng nhập bằng mã thiết bị (máy không có trình duyệt)
codex login status                   # Xem đang đăng nhập hay chưa, bằng cách nào
printenv OPENAI_API_KEY | codex login --with-api-key   # Đăng nhập bằng API key
codex logout                         # Đăng xuất, xoá thông tin đăng nhập đã lưu
```

## 3. Mở phiên làm việc (tương tác)
```bash
codex                                # Mở phiên mới ở thư mục hiện tại
codex "sửa lỗi build"                # Mở phiên kèm câu lệnh đầu tiên
codex -C <thư-mục>                   # Chọn thư mục làm việc
codex -m <model>                     # Chọn model
codex -i ảnh.png "giải thích ảnh"    # Đính kèm ảnh
codex --search                       # Bật tìm kiếm web
codex --worktree                     # Chạy phiên trong một git worktree mới
codex --add-dir <thư-mục>            # Cho ghi thêm một thư mục ngoài workspace
codex -p <profile>                   # Dùng profile cấu hình $CODEX_HOME/<profile>.config.toml
```

## 4. Quyền chạy lệnh (sandbox, phê duyệt)
```bash
codex -s read-only                   # Chỉ đọc
codex -s workspace-write             # Được ghi trong workspace
codex -s danger-full-access          # Toàn quyền (cẩn thận)
codex -a on-request                  # Model tự quyết khi nào xin phép
codex -a never                       # Không bao giờ hỏi
codex --approve-for-me               # Tự duyệt qua review tự động (sandbox workspace-write)
codex --dangerously-bypass-approvals-and-sandbox   # Bỏ hết sandbox và xác nhận — RẤT NGUY HIỂM
```

## 5. Tiếp tục / quản lý phiên cũ
```bash
codex resume                         # Chọn phiên cũ để tiếp tục
codex resume --last                  # Tiếp tục phiên gần nhất
codex resume <id-hoặc-tên>           # Tiếp tục một phiên cụ thể
codex fork --last                    # Tách nhánh từ phiên gần nhất
codex queue                          # Xếp hàng một tin nhắn cho phiên đang có
codex archive <id-hoặc-tên>          # Lưu trữ phiên
codex unarchive <id-hoặc-tên>        # Bỏ lưu trữ
codex delete <id-hoặc-tên>           # Xoá vĩnh viễn phiên
codex agents                         # Duyệt mọi phiên agent trên daemon cục bộ
```

## 6. Chạy không tương tác (script, CI)
```bash
codex exec "chạy ./scripts/gate.sh và báo kết quả"   # Chạy một lần rồi thoát (alias: codex e)
echo "prompt" | codex exec -          # Đọc prompt từ stdin
codex exec resume --last "tiếp tục"   # Tiếp tục phiên gần nhất không tương tác
codex review                          # Review code không tương tác
codex apply                           # Áp diff mới nhất Codex tạo vào working tree (alias: codex a)
```

## 7. MCP server và plugin
```bash
codex mcp list                       # Liệt kê MCP server
codex mcp get <tên>                  # Xem một server
codex mcp add <tên> -- <lệnh>        # Thêm server
codex mcp remove <tên>               # Gỡ server
codex mcp login <tên>                # Đăng nhập server (OAuth)
codex mcp logout <tên>               # Đăng xuất server
codex plugin --help                  # Quản lý plugin
```

## 8. Cấu hình, tính năng, tiện ích khác
```bash
codex -c model="o3"                  # Ghi đè một giá trị trong ~/.codex/config.toml
codex --enable <tính-năng>           # Bật feature flag (--disable để tắt)
codex features                       # Xem các feature flag
codex completion zsh                 # Sinh script tự hoàn thành cho zsh
codex sandbox --help                 # Chạy lệnh trong sandbox của Codex
codex cloud                          # [Thử nghiệm] Duyệt task Codex Cloud, áp thay đổi về máy
codex app                            # Mở ứng dụng Desktop
```

## 9. Lệnh gạch chéo trong phiên tương tác
Gõ `/` trong phiên để xem đủ danh sách của bản đang cài. Hay dùng:
```text
/model      đổi model            /approvals  đổi chế độ phê duyệt
/status     xem phiên, token     /diff       xem git diff
/review     review thay đổi      /compact    tóm gọn ngữ cảnh
/new        phiên mới            /init       tạo AGENTS.md
/mention    đính kèm file        /logout     đăng xuất
/quit       thoát (hoặc Ctrl+C hai lần)
```
