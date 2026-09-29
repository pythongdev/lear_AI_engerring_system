# Lệnh tắt cho database LÀM VIỆC trên máy phát triển (compose project `banhcuon`).
# Hướng dẫn từng bước: docs/guideline/chay-database-tren-may.md. Chỗ đặt file này:
# docs/product/2-db/10-quy-uoc-code.md QC-08.
#
# File này không mang cấu hình riêng: database, cổng, vai lấy từ compose.yaml; múi giờ
# đọc từ master_plan/shop-facts.md §1 lúc chạy, như scripts/db-check.sh (QC-06).
# Bộ kiểm (./scripts/db-check.sh) KHÔNG đi qua đây — nó dựng database riêng của nó.
#
#   make            danh sách lệnh
#   make setup      bật + tạo bảng + nạp dữ liệu mồi (lần đầu)
#   make psql       vào psql bên trong container

SHOP_TZ := $(shell grep -m1 '^| Múi giờ |' master_plan/shop-facts.md | grep -o '`[^`]*`' | head -1 | tr -d '`')
PSQL    := docker compose exec -e PGTZ=$(SHOP_TZ) db psql -X -U shop_owner -d banhcuon

.DEFAULT_GOAL := help
.PHONY: help setup up migrate seed psql shell status stop reset check-tz

help: ## Liệt kê các lệnh
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-9s %s\n", $$1, $$2}'

setup: up migrate seed ## Lần đầu: bật database, tạo bảng, nạp dữ liệu mồi

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

check-tz:
	@[ -n "$(SHOP_TZ)" ] || { echo "Không đọc được múi giờ ở master_plan/shop-facts.md §1 (dòng '| Múi giờ |')"; exit 1; }
