#!/usr/bin/env bash
# Chạy dev qua HTTPS trên IP Wi-Fi của Mac; chứng chỉ và khoá ở .dev/ (git bỏ qua).
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

ip="${1:-}"
if [[ -z "$ip" ]] && command -v ipconfig >/dev/null 2>&1; then
  ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
fi
if [[ -z "$ip" ]]; then
  echo 'Không tìm được IP Wi-Fi; chạy: make dev-iphone IP=<IP của Mac>' >&2
  exit 1
fi
if [[ ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "IP không hợp lệ: $ip" >&2
  exit 1
fi
IFS=. read -r a b c d <<< "$ip"
for octet in "$a" "$b" "$c" "$d"; do
  if [[ ! "$octet" =~ ^(0|[1-9][0-9]{0,2})$ ]] || (( 10#$octet > 255 )); then
    echo "IP không hợp lệ: $ip" >&2
    exit 1
  fi
done
if [[ "$a" != 10 && ! ( "$a" == 172 && "$b" -ge 16 && "$b" -le 31 ) && ! ( "$a" == 192 && "$b" == 168 ) ]]; then
  echo "Chỉ dùng IP mạng riêng của Mac (10.x, 172.16–31.x hoặc 192.168.x): $ip" >&2
  exit 1
fi
# Next 16 chỉ cho một dev server trên mỗi thư mục fe/, dù khác cổng (T-331).
if pgrep -f "$repo_root/fe/node_modules/.bin/next dev" >/dev/null 2>&1; then
  echo 'Đang có make dev chạy trên repo này; Next không cho chạy hai dev server cùng lúc.' >&2
  echo 'Tắt nó trước bằng: make stop-dev  — rồi chạy lại make dev-iphone.' >&2
  exit 1
fi
if ! command -v openssl >/dev/null 2>&1; then
  echo 'Thiếu openssl để tạo chứng chỉ HTTPS cục bộ.' >&2
  exit 1
fi

cert_rel="../.dev/iphone/$ip"
cert_dir="$repo_root/.dev/iphone/$ip"
ca_dir="$repo_root/.dev/iphone/ca"
public_dir="$repo_root/.dev/iphone-public"
key="$cert_dir/key.pem"
cert="$cert_dir/cert.pem"
ca_key="$ca_dir/ca.key"
ca_cert="$ca_dir/ca.crt"
umask 077
mkdir -p "$cert_dir" "$ca_dir" "$public_dir"
# Khoá riêng không bao giờ được hiện thành file chờ commit (T-331).
[[ -f "$repo_root/.dev/.gitignore" ]] || printf '*\n' > "$repo_root/.dev/.gitignore"
new_ca=0
if [[ ! -s "$ca_key" || ! -s "$ca_cert" ]] || ! openssl x509 -checkend 86400 -noout -in "$ca_cert" >/dev/null 2>&1; then
  openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 90 \
    -subj '/CN=Banhcuon iPhone Dev CA' \
    -addext 'basicConstraints=critical,CA:TRUE,pathlen:0' \
    -addext 'keyUsage=critical,keyCertSign,cRLSign' \
    -keyout "$ca_key" -out "$ca_cert" >/dev/null 2>&1
  chmod 600 "$ca_key"
  new_ca=1
fi
# Thư mục công khai chỉ có chứng chỉ CA dạng DER; không phục vụ khoá riêng qua HTTP.
openssl x509 -in "$ca_cert" -outform DER -out "$public_dir/ca.cer"
if [[ "$new_ca" == 1 || ! -s "$key" || ! -s "$cert" ]] ||
   ! openssl x509 -checkend 86400 -noout -in "$cert" >/dev/null 2>&1 ||
   ! openssl verify -CAfile "$ca_cert" "$cert" >/dev/null 2>&1; then
  openssl req -new -newkey rsa:2048 -sha256 -nodes -subj "/CN=$ip" \
    -keyout "$key" -out "$cert_dir/request.csr" >/dev/null 2>&1
  cat > "$cert_dir/leaf.ext" <<EXT
basicConstraints=critical,CA:FALSE
subjectAltName=IP:$ip
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
EXT
  openssl x509 -req -in "$cert_dir/request.csr" -CA "$ca_cert" -CAkey "$ca_key" \
    -CAcreateserial -days 30 -sha256 -extfile "$cert_dir/leaf.ext" \
    -out "$cert" >/dev/null 2>&1
  chmod 600 "$key"
fi

export BANHCUON_ORIGIN="https://$ip:3002"
export BANHCUON_DEV_BO_GIO_BAN=0
export BANHCUON_DEV_IP="$ip"
export BANHCUON_ADDR=:8082
export BANHCUON_BE_URL=http://127.0.0.1:8082
export PORT=3002
export FE_DEV_FLAGS="--hostname 0.0.0.0 --port 3002 --experimental-https --experimental-https-key $cert_rel/key.pem --experimental-https-cert $cert_rel/cert.pem"

printf 'Trang iPhone: https://%s:3002/chu-quan\n' "$ip"
printf 'Chứng chỉ CA công khai: %s/ca.cer; iPhone cần cài và bật tin cậy một lần.\n' "$public_dir"
printf 'Chạy backend và frontend ở cổng 8082/3002. Ctrl+C để dừng.\n'
if [[ -z "$(docker compose ps --status running -q db)" ]]; then
  make up
fi
exec make dev-iphone-serve
