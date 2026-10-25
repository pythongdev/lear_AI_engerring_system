#!/usr/bin/env bash
# Chỉ dùng cho database dev; cấu hình do Makefile truyền qua môi trường.
set -euo pipefail

backend=${BANHCUON_BE_URL:?thiếu BANHCUON_BE_URL}
backend=${backend%/}
if ! curl -sS --connect-timeout 3 --max-time 5 -o /dev/null "$backend/"; then
  echo 'backend chưa chạy — mở cửa sổ khác chạy `make be` rồi chạy lại' >&2
  exit 1
fi
: "${BANHCUON_DATABASE_URL:?thiếu BANHCUON_DATABASE_URL}"
: "${BANHCUON_SHOP_TZ:?thiếu BANHCUON_SHOP_TZ}"

query() {
  docker compose exec -T db psql -X -A -t -U shop_owner -d banhcuon \
    -v ON_ERROR_STOP=1 -c "$1" </dev/null
}

count=$(query 'SELECT count(*) FROM person WHERE is_owner = false')
if [[ "$count" != 4 ]]; then
  printf 'Cần đúng 4 người không phải chủ quán; database hiện có %s. Dừng tạo tài khoản.\n' "$count" >&2
  exit 1
fi
# to_json giữ tên nguyên vẹn kể cả dấu nháy, dấu | và ký tự xuống dòng.
people=$(query "SELECT id, to_json(display_name) FROM person WHERE is_owner = false ORDER BY id")

summary=''
record() {
  printf '%s: %s\n' "$1" "$2"
  summary+="$1 → $2"$'\n'
}

# Lỗi truy vấn phải dừng, không coi là tài khoản chưa có.
owner_count=$(query "SELECT count(*) FROM account WHERE username = 'chu'")
if [[ "$owner_count" != 0 ]]; then
  record chu 'đã có, bỏ qua'
else
  printf '%s\n' 'chuquan123' | (cd be && go run ./cmd/khoitao-chu-quan \
    -username chu -email chu@quan.test -display-name 'Chủ quán (dev)')
  record chu 'đã tạo'
fi

jar=$(mktemp)
trap 'rm -f "$jar"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
logged_in=false

post() {
  local result code
  result=$(curl -sS --connect-timeout 3 --max-time 30 -b "$jar" -c "$jar" \
    -H 'content-type: application/json' -d "$2" -w $'\n%{http_code}' "$backend$1")
  code=${result##*$'\n'}
  response=${result%$'\n'*}
  if [[ "$code" != 2[0-9][0-9] ]]; then
    printf 'POST %s thất bại (HTTP %s):\n%s\n' "$1" "$code" "$response" >&2
    exit 1
  fi
}

roles=('quay|quay1234|quay' 'trang|trang1234|trang_banh' 'gap|gap12345|gap_banh' 'canh|canh1234|canh_don_ban')
i=0
while IFS= read -r person; do
  pid=${person%%|*}
  name_json=${person#*|}
  IFS='|' read -r username password role <<< "${roles[$i]}"
  i=$((i + 1))
  account_count=$(query "SELECT count(*) FROM account WHERE username = '$username'")
  if [[ "$account_count" != 0 ]]; then
    record "$username" 'đã có, bỏ qua'
    continue
  fi
  if [[ "$logged_in" == false ]]; then
    post /sessions '{"username":"chu","password":"chuquan123"}'
    logged_in=true
  fi
  post /accounts "{\"username\":\"$username\",\"email\":\"$username@quan.test\",\"display_name\":$name_json,\"password\":\"$password\"}"
  if [[ "$response" =~ \"account_id\"[[:space:]]*:[[:space:]]*([0-9]+) ]]; then
    id=${BASH_REMATCH[1]}
  else
    printf 'Không đọc được account_id:\n%s\n' "$response" >&2
    exit 1
  fi
  post "/accounts/$id/approval" "{\"role_code\":\"$role\",\"person_id\":$pid}"
  if [[ ! "$response" =~ \"status\"[[:space:]]*:[[:space:]]*\"hoat_dong\" ]]; then
    printf 'Tài khoản chưa hoạt động:\n%s\n' "$response" >&2
    exit 1
  fi
  record "$username" 'đã tạo, hoat_dong'
done <<< "$people"

printf '\nTên đăng nhập → Trạng thái\n%s' "$summary"
