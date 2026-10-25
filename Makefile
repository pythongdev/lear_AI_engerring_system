# Lệnh chạy hệ thống và database LÀM VIỆC trên máy phát triển
# (compose project `banhcuon`), cùng Swagger UI đọc hợp đồng API.
# Hướng dẫn từng bước: docs/guideline/chay-database-tren-may.md; bảng tra lệnh:
# docs/command/make.md. Chỗ đặt file này:
# docs/product/2-db/10-quy-uoc-code.md QC-08.
#
# Mặc định phát triển khớp compose.yaml và db/init/; múi giờ
# đọc từ master_plan/shop-facts.md §1 lúc chạy, như scripts/db-check.sh (QC-06).
# Bộ kiểm (./scripts/db-check.sh) KHÔNG đi qua đây — nó dựng database riêng của nó.
#
#   make            danh sách lệnh
#   make dev        bật database rồi chạy backend và frontend
#   make setup      bật + tạo bảng + nạp dữ liệu mồi (lần đầu)
#   make psql       vào psql bên trong container

SHOP_TZ := $(shell grep -m1 '^| Múi giờ |' master_plan/shop-facts.md | grep -o '`[^`]*`' | head -1 | tr -d '`')
PSQL    := docker compose exec -e PGTZ=$(SHOP_TZ) db psql -X -U shop_owner -d banhcuon

DB_PORT ?= 5433
BANHCUON_DATABASE_URL ?= postgres://shop_app:shop_app_dev@127.0.0.1:$(DB_PORT)/banhcuon?sslmode=disable
BANHCUON_SHOP_TZ ?= $(SHOP_TZ)
BANHCUON_ORIGIN ?= http://localhost:3000
BANHCUON_FILE_DIR ?= $(CURDIR)/.dev/files
BANHCUON_BE_URL ?= http://127.0.0.1:8080
export DB_PORT
BE_ENV = BANHCUON_DATABASE_URL="$(BANHCUON_DATABASE_URL)" BANHCUON_SHOP_TZ="$(BANHCUON_SHOP_TZ)" BANHCUON_ORIGIN="$(BANHCUON_ORIGIN)" BANHCUON_FILE_DIR="$(BANHCUON_FILE_DIR)"
BE_RUN = cd be && $(BE_ENV) go run ./cmd/server
FE_RUN = cd fe && BANHCUON_BE_URL="$(BANHCUON_BE_URL)" npm run dev

# Bash 3.2: monitor mode tạo nhóm riêng; tắt monitor trong nhóm để con cùng nhóm.
# Bộ đọc log nằm trong nhóm đó. Theo dõi PID server, không chờ pipe log đóng.
define DEV_RUN
set -m; \
be_pid=; fe_pid=; \
cleanup() { \
  trap "" INT TERM; \
  for pid in $$be_pid $$fe_pid; do kill -TERM -- -$$pid 2>/dev/null || :; done; \
  sleep 1; \
  for pid in $$be_pid $$fe_pid; do kill -KILL -- -$$pid 2>/dev/null || :; done; \
  wait 2>/dev/null || :; \
}; \
trap cleanup EXIT; trap "exit 130" INT; trap "exit 143" TERM; \
(set +m; { $(BE_RUN); } > >(while IFS= read -r line || [ -n "$$line" ]; do printf "[be] %s\n" "$$line"; done) 2>&1) & be_pid=$$!; \
(set +m; { $(FE_RUN); } > >(while IFS= read -r line || [ -n "$$line" ]; do printf "[fe] %s\n" "$$line"; done) 2>&1) & fe_pid=$$!; \
while kill -0 "$$be_pid" 2>/dev/null && kill -0 "$$fe_pid" 2>/dev/null; do sleep 0.2; done; \
if ! kill -0 "$$be_pid" 2>/dev/null; then wait "$$be_pid"; else wait "$$fe_pid"; fi
endef

.DEFAULT_GOAL := help
.PHONY: help setup up migrate seed seed-thu tai-khoan-dev ma-qr-so-ban psql shell status stop reset swagger swagger-stop check-tz dev be fe check-go check-fe dev-files

help: ## Liệt kê các lệnh
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-12s %s\n", $$1, $$2}'

dev: check-tz check-go check-fe dev-files ## Bật database rồi chạy backend + frontend; Ctrl+C tắt cả hai
	$(MAKE) setup
	@bash -c '$(DEV_RUN)'

be: check-tz check-go dev-files ## Chạy server Go (cần database đã bật)
	$(BE_RUN)

fe: check-fe ## Chạy giao diện Next ở cổng 3000
	$(FE_RUN)

check-go:
	@command -v go >/dev/null 2>&1 || { echo "Thiếu lệnh go; hãy cài Go rồi chạy lại."; exit 1; }

check-fe:
	@command -v npm >/dev/null 2>&1 || { echo "Thiếu lệnh npm; hãy cài Node.js và npm rồi chạy lại."; exit 1; }
	@[ -d fe/node_modules ] || { echo "Thiếu fe/node_modules; hãy chạy: cd fe && npm ci"; exit 1; }

dev-files:
	@mkdir -p "$(CURDIR)/.dev" && printf '*\n' > "$(CURDIR)/.dev/.gitignore" && mkdir -p "$(BANHCUON_FILE_DIR)"

setup: ## Lần đầu: bật database, tạo bảng, nạp dữ liệu mồi
	$(MAKE) up
	$(MAKE) migrate
	$(MAKE) seed

up: ## Bật database (cổng 127.0.0.1:5433), chờ tới khi sẵn sàng
	docker compose up -d --wait db

migrate: ## Chạy các migration chưa chạy ở db/migrations/
	docker compose run --rm migrate

seed: check-tz ## Nạp dữ liệu mồi — tự bỏ qua nếu database đã có dữ liệu
	@if [ "$$($(PSQL) -tA -c 'SELECT count(*) FROM person' </dev/null)" != "0" ]; then \
	  echo "seed: database đã có dữ liệu — bỏ qua. Muốn nạp lại: make reset"; \
	else \
	  perl db/seed/seed.pl | docker compose exec -T -e PGTZ=$(SHOP_TZ) db \
	    psql -X -q -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon >/dev/null && echo "seed: đã nạp dữ liệu mồi"; \
	fi

seed-thu: check-tz ## Nạp dữ liệu thử máy dev sau make seed — đã có danh mục thì bỏ qua
	@sql="$$(perl db/seed/du-lieu-thu.pl)" && \
	  printf '%s\n' "$$sql" | docker compose exec -T -e PGTZ=$(SHOP_TZ) db \
	    psql -X -q -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon

tai-khoan-dev: check-tz check-go ## Tạo tài khoản thử máy dev — tài khoản đã có thì bỏ qua
	@BANHCUON_DATABASE_URL="$(BANHCUON_DATABASE_URL)" BANHCUON_SHOP_TZ="$(BANHCUON_SHOP_TZ)" \
	  BANHCUON_BE_URL="$(BANHCUON_BE_URL)" bash db/seed/tai-khoan-dev.sh

ma-qr-so-ban: check-tz ## Chỉ máy dev: mã QR của mỗi bàn thành số bàn — mở /ban/<số bàn>
	docker compose exec -T -e PGTZ=$(SHOP_TZ) db \
	  psql -X -q -v ON_ERROR_STOP=1 -U shop_owner -d banhcuon < db/seed/ma-qr-so-ban.sql

psql: check-tz ## Vào psql bên trong container (\q để thoát)
	$(PSQL)

shell: ## Vào shell bash bên trong container
	docker compose exec db bash

status: ## Xem container database có đang chạy không
	docker compose ps db

stop: ## Tắt database, GIỮ dữ liệu
	docker compose stop db

reset: ## XOÁ SẠCH dữ liệu rồi dựng lại từ đầu (setup)
	docker compose rm -sfv db
	$(MAKE) setup

swagger: ## Bật Swagger UI cho hợp đồng API — http://127.0.0.1:8081/docs/
	docker compose up -d swagger
	@echo "Swagger UI: http://127.0.0.1:$${SWAGGER_PORT:-8081}/docs/  (Try it out gọi server Go ở cổng 8080 của máy)"

swagger-stop: ## Tắt Swagger UI
	docker compose stop swagger

check-tz:
	@[ -n "$(SHOP_TZ)" ] || { echo "Không đọc được múi giờ ở master_plan/shop-facts.md §1 (dòng '| Múi giờ |')"; exit 1; }
