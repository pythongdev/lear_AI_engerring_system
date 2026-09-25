# Các câu lệnh Git/GitHub phổ biến

## 1. Cấu hình ban đầu
```bash
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"
git config --list                    # Xem cấu hình
```

## 2. Khởi tạo & Clone
```bash
git init                             # Khởi tạo repo local
git clone <url>                      # Clone repo từ GitHub
git clone <url> <tên-thư-mục>        # Clone vào thư mục chỉ định
```

## 3. Làm việc với file
```bash
git status                           # Xem trạng thái
git add <file>                       # Thêm 1 file
git add .                            # Thêm tất cả file
git commit -m "message"              # Commit
git commit -am "message"             # Add + commit (file đã track)
```

## 4. Nhánh (Branch)
```bash
git branch                           # Liệt kê nhánh
git branch <tên-nhánh>               # Tạo nhánh mới
git checkout <tên-nhánh>             # Chuyển nhánh
git checkout -b <tên-nhánh>          # Tạo + chuyển nhánh
git switch <tên-nhánh>               # Chuyển nhánh (mới)
git merge <tên-nhánh>                # Merge nhánh vào nhánh hiện tại
git branch -d <tên-nhánh>            # Xóa nhánh
```

## 5. Remote & Push/Pull
```bash
git remote -v                        # Xem remote
git remote add origin <url>          # Thêm remote
git push origin <nhánh>              # Push lên GitHub
git push -u origin main              # Push lần đầu + set upstream
git push                             # Push sau khi đã set upstream
git pull                             # Kéo code về
git pull origin <nhánh>              # Pull nhánh cụ thể
git fetch                            # Fetch không merge
```

## 6. Lịch sử & So sánh
```bash
git log                              # Xem lịch sử commit
git log --oneline                    # Log gọn 1 dòng
git log --graph --oneline --all      # Log dạng đồ thị
git diff                             # So sánh thay đổi chưa add
git diff --staged                    # So sánh đã add
git show <commit-hash>               # Xem chi tiết commit
```

## 7. Hoàn tác (Undo)
```bash
git restore <file>                   # Bỏ thay đổi file
git restore --staged <file>          # Bỏ khỏi staging
git reset --soft HEAD~1              # Undo commit, giữ thay đổi
git reset --hard HEAD~1              # Undo commit, xóa thay đổi
git revert <commit-hash>             # Tạo commit đảo ngược
git checkout <commit-hash> -- <file> # Khôi phục file từ commit cũ
```

## 8. Stash (Lưu tạm)
```bash
git stash                            # Lưu tạm thay đổi
git stash list                       # Xem danh sách stash
git stash pop                        # Lấy lại + xóa stash
git stash apply                      # Lấy lại, giữ stash
git stash drop                       # Xóa stash
```

## 9. Tag
```bash
git tag                              # Liệt kê tag
git tag v1.0.0                       # Tạo tag
git tag -a v1.0.0 -m "message"       # Tag có chú thích
git push origin v1.0.0               # Push tag
git push --tags                      # Push tất cả tag
```

## 10. Xử lý conflict
```bash
# Sau khi sửa conflict thủ công:
git add <file-đã-sửa>
git commit -m "resolve conflict"
# Hoặc hủy merge:
git merge --abort
```

## 11. Xóa file/thư mục
```bash
git rm <file>                        # Xóa file khỏi repo
git rm -r <thư-mục>                  # Xóa thư mục
git rm --cached <file>               # Bỏ track, giữ file local
```

## 12. Một số lệnh hữu ích khác
```bash
git clean -fd                        # Xóa file/thư mục untracked
git cherry-pick <commit-hash>        # Áp dụng 1 commit cụ thể
git rebase <nhánh>                   # Rebase nhánh
git reflog                           # Xem lịch sử HEAD
```

## 💡 Quy trình cơ bản thường dùng
```bash
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin <url>
git push -u origin main
```

Bạn muốn mình giải thích chi tiết phần nào (ví dụ: rebase, merge vs rebase, xử lý conflict) không?