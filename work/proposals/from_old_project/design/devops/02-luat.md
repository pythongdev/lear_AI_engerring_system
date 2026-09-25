# 02 — Luật DevOps (Docker + CI + VPS)

> Cập nhật **2026-08-19** · Lane sở hữu: **DEVOPS** · Dời từ `quality/04-devops.md` (`git log --follow`).
> Liên quan: [step.md — Bước 5, 6, 7](../../step.md) · [design/data_base/02-luat.md](../data_base/02-luat.md)

Mục tiêu không phải "hạ tầng đẹp". Mục tiêu là: **7h30 sáng quán đông, có sự cố, bạn biết trong 1 phút và quay lại bản cũ trong 30 giây.**

---

## 1. Makefile — cổng chất lượng duy nhất

Đặt ở gốc repo. Đây là thứ duy nhất bạn cần nhớ.

```make
.PHONY: check lint test-be test-fe db-test e2e up down logs backup

DSN ?= mysql://root:root@tcp(localhost:3306)/banhcuon

## Cổng chính — chạy trước mỗi lần merge
check: lint test-be test-fe

lint:
	cd code/be && golangci-lint run
	cd fe && npm run lint

test-be:
	cd code/be && go test ./... -race -cover

test-fe:
	cd fe && npm run typecheck && npm test

## Migration up → down → up → seed → assert
db-test:
	migrate -path code/be/migrations -database "$(DSN)" up
	migrate -path code/be/migrations -database "$(DSN)" down -all
	migrate -path code/be/migrations -database "$(DSN)" up
	mysql banhcuon < code/be/migrations/seed.sql
	mysql banhcuon -N -e "SELECT COUNT(*) FROM products" | grep -qx 8

e2e:
	docker compose up -d
	cd fe && npx playwright test
	docker compose down

up:      ; docker compose up -d
down:    ; docker compose down
logs:    ; docker compose logs -f --tail=100
backup:  ; ./deploy/backup.sh
```

`-race` là bắt buộc, không phải tuỳ chọn — nhiều trạm bấm song song.

---

## 2. Pre-commit hook — chặn rác trước khi vào repo

`.git/hooks/pre-commit` (nhớ `chmod +x`):

```bash
#!/bin/sh
set -e
echo "→ lint..."
make lint
```

Chỉ chạy `lint` (vài giây), không chạy `test` — hook chậm là hook bị bỏ qua bằng `--no-verify`.

---

## 3. CI — GitHub Actions

`.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]

jobs:
  backend:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.4
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: banhcuon
        options: >-
          --health-cmd="mysqladmin ping -h localhost"
          --health-interval=5s --health-retries=20
        ports: ['3306:3306']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: { go-version: '1.22' }

      - name: Cài migrate
        run: go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

      - name: Test migration up → down → up
        run: make db-test
        env:
          DSN: mysql://root:root@tcp(127.0.0.1:3306)/banhcuon

      - name: Kiểm tra cột tiền không phải float
        run: |
          mysql -h127.0.0.1 -uroot -proot banhcuon -N -e "
            SELECT CONCAT(table_name,'.',column_name) FROM information_schema.columns
            WHERE table_schema='banhcuon'
              AND (column_name LIKE '%price%' OR column_name LIKE '%total%'
                   OR column_name LIKE '%amount%')
              AND data_type NOT IN ('int','bigint','smallint');" > /tmp/bad.txt
          [ ! -s /tmp/bad.txt ] || { echo "Cột tiền dùng float:"; cat /tmp/bad.txt; exit 1; }

      - name: Kiểm tra mọi .up.sql có .down.sql
        run: |
          for f in code/be/migrations/*.up.sql; do
            [ -f "${f%.up.sql}.down.sql" ] || { echo "Thiếu down cho $f"; exit 1; }
          done

      - uses: golangci/golangci-lint-action@v6
        with: { working-directory: code/be }

      - run: cd code/be && go test ./... -race -coverprofile=cover.out

      - name: Coverage service/ ≥ 80%
        run: |
          cd code/be
          P=$(go tool cover -func=cover.out | grep -E 'service/.*total|total:' | tail -1 | awk '{print $3}' | tr -d '%')
          echo "coverage: $P%"
          awk -v p="$P" 'BEGIN { exit (p >= 80) ? 0 : 1 }'

  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm', cache-dependency-path: fe/package-lock.json }
      - run: cd fe && npm ci
      - run: cd fe && npm run gen:api && git diff --exit-code src/lib/api-types.ts
      - run: cd fe && npm run typecheck
      - run: cd fe && npm run lint
      - run: cd fe && npm test
```

**Quy tắc:** CI đỏ → không merge. Không có ngoại lệ "để mai sửa".

---

## 4. Log — không có thì không debug được sự cố ở quán

### a. Log có cấu trúc + `request_id`

Dùng `slog` JSON. Middleware gán `request_id` cho mỗi request và truyền qua `context` xuống tận DB layer.

```go
slog.InfoContext(ctx, "order created",
	"request_id", reqID,
	"order_id", orderID,
	"session_id", sessionID,
	"total", total,
	"items", len(items))
```

Khi nhân viên báo "đơn bàn 5 lúc 7h20 bị sai tiền", bạn phải tìm được đúng request đó:

```bash
docker compose logs be | grep '"session_id":42' | jq .
```

**Không log:** SĐT đầy đủ của khách, token bàn, mật khẩu/PIN, nội dung Authorization header.

### b. Log không được ăn hết ổ đĩa

VPS 2GB, ổ nhỏ. Bắt buộc giới hạn trong `docker-compose.prod.yml`:

```yaml
x-logging: &logging
  logging:
    driver: json-file
    options: { max-size: "10m", max-file: "5" }

services:
  be:  { <<: *logging, ... }
  db:  { <<: *logging, ... }
  fe:  { <<: *logging, ... }
```

Ổ đầy vì log là cách sập server ngớ ngẩn nhất và hay gặp nhất.

---

## 5. Healthcheck + biết khi sập

### a. Endpoint `/healthz`

```go
// ping DB thật, không chỉ trả 200
r.GET("/healthz", func(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c, 2*time.Second)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		c.JSON(503, gin.H{"status": "db down"}); return
	}
	c.JSON(200, gin.H{"status": "ok"})
})
```

Healthcheck chỉ trả `200 OK` mà không ping DB là healthcheck vô dụng — BE sống nhưng DB chết thì khách vẫn không đặt được món.

### b. Docker healthcheck + tự restart

```yaml
be:
  healthcheck:
    test: ["CMD", "wget", "-qO-", "http://localhost:8080/healthz"]
    interval: 30s
    timeout: 5s
    retries: 3
  restart: unless-stopped
```

### c. Báo động ra điện thoại

Không có cái này thì bạn chỉ biết sập khi nhân viên gọi điện.

Cách rẻ nhất — cron trên chính VPS (hoặc tốt hơn: trên máy khác):

```bash
# crontab: mỗi 5 phút trong giờ bán
*/5 6-11 * * * curl -fsS https://quan-cua-ban.vn/healthz > /dev/null || \
  curl -s "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id=$CHAT_ID -d text="⚠️ Web quán không phản hồi lúc $(date +%H:%M)"
```

Hoặc dùng Uptime Kuma / UptimeRobot (miễn phí) — chạy ngoài VPS nên biết cả khi VPS chết hẳn.

---

## 6. Deploy an toàn + rollback 30 giây

### a. Tag image theo git SHA, không dùng `latest`

```bash
SHA=$(git rev-parse --short HEAD)
docker build -t banhcuon-be:$SHA ./be
docker tag banhcuon-be:$SHA banhcuon-be:current
```

`latest` làm bạn không biết đang chạy bản nào và không rollback được.

### b. Quy trình deploy

```
1. make check          ← xanh mới đi tiếp
2. ./deploy/backup.sh  ← backup TRƯỚC khi động vào DB
3. Chạy migration trên staging, kiểm tra
4. docker compose pull && docker compose up -d
5. curl /healthz       ← xác nhận sống
6. Thử 1 đơn thật trên điện thoại
```

Deploy **sau 11h sáng**, khi quán đã đóng. Không bao giờ deploy lúc 6h–10h.

### c. Rollback

```bash
docker tag banhcuon-be:<SHA_CŨ> banhcuon-be:current
docker compose up -d be
```

Giữ 3 image cũ trên VPS. Nếu migration đã chạy và cần lùi DB → restore từ backup bước 2.

### d. Staging không cần VPS thứ hai

`docker-compose.staging.yml` chạy trên máy cá nhân, DB restore từ backup production:

```bash
gunzip < backups/backup-hom-qua.sql.gz | docker compose -f docker-compose.staging.yml exec -T db mysql banhcuon
docker compose -f docker-compose.staging.yml exec be ./migrate up
```

Đây là chỗ duy nhất bạn biết chắc migration chạy được trên **dữ liệu thật**, không phải dữ liệu seed.

---

## 7. Bí mật và cấu hình

| Quy tắc | Cách kiểm |
|---------|-----------|
| `.env` không bao giờ vào git | `.gitignore` có `.env`, chỉ commit `.env.example` |
| Mật khẩu DB production ≠ dev | Đọc `.env` trên VPS, không copy từ máy dev |
| JWT secret ≥ 32 byte random | `openssl rand -base64 32` |
| Đổi secret = mọi nhân viên phải đăng nhập lại | Đổi vào lúc đóng quán |
| Quét secret lỡ commit | `gitleaks detect` trong CI |

Thêm vào CI:

```yaml
- uses: gitleaks/gitleaks-action@v2
```

---

## 8. Bẫy thường gặp

| Lỗi | Hậu quả | Cách tránh |
|-----|---------|------------|
| Dùng tag `latest` | Không biết đang chạy bản nào, không rollback được | Tag theo git SHA |
| Không giới hạn log | Ổ đĩa đầy → VPS sập | `max-size: 10m, max-file: 5` |
| Healthcheck không ping DB | BE "khoẻ" nhưng khách không đặt được | `/healthz` ping DB thật |
| Deploy giờ bán | Sự cố lúc quán đông nhất | Deploy sau 11h |
| Không backup trước migration | Migration hỏng = mất dữ liệu | `./deploy/backup.sh` là bước 2 |
| Không có staging | Migration chỉ test trên seed, vỡ trên dữ liệu thật | Compose staging + backup production |
| Không log `request_id` | Không lần được sự cố cụ thể | `slog` + middleware gán ID |
| Không có báo động | Biết sập khi nhân viên gọi điện | Cron `curl /healthz` → Telegram |
| Commit `.env` | Lộ mật khẩu DB | `.gitignore` + `gitleaks` |
| `restart: no` | Container chết là chết luôn | `restart: unless-stopped` |

---

## Checklist DevOps — trước mỗi lần deploy production

- [ ] `make check` xanh, CI xanh
- [ ] Đã backup: `./deploy/backup.sh` và file mới có, size hợp lý
- [ ] Migration đã chạy thử trên staging với dữ liệu thật
- [ ] Image tag theo git SHA, image cũ vẫn còn trên VPS
- [ ] Deploy ngoài giờ bán (sau 11h)
- [ ] Sau deploy: `curl /healthz` = 200
- [ ] Sau deploy: đặt thử 1 đơn thật từ điện thoại, và thử 1 luồng POS
- [ ] Ghi lại git SHA vừa deploy (để biết rollback về đâu)
