#!/usr/bin/env bash
# Test cho Gate 1g (scripts/check-api-contract.sh, P3-04, ADR-084, ADR-082 điểm 5).
#
# Chạy tay:  ./scripts/check-api-contract.test.sh
# verify.sh tự chạy mọi scripts/*.test.sh.
#
# Mỗi ca dựng một hợp đồng, một cây be/ và một thư mục migration tạm, trỏ script vào
# đó bằng API_CONTRACT_FILE · API_CONTRACT_BE_DIR · API_CONTRACT_MIG_DIR — không đụng
# cây thật. Mỗi cách hợp đồng và code lệch nhau phải đỏ (ADR-082 điểm 7 luật 3: phép
# chấm chưa bao giờ đỏ là phép chấm chưa được chứng minh). Claude viết các ca này
# TRƯỚC khi có script (docs/prompt-guideline.md §6.1).

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-api-contract.sh"
TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT
fails=0

run() { # run <ca> [cờ…] → in "<exit>|<output một dòng>"
  local c="$1" out rc; shift
  out="$(API_CONTRACT_FILE="$c/openapi.yaml" API_CONTRACT_BE_DIR="$c/be" \
    API_CONTRACT_MIG_DIR="$c/mig" "$SCRIPT" "$@" 2>&1)"
  rc=$?
  printf '%s|%s' "$rc" "$(printf '%s' "$out" | tr '\n' ' ')"
}

check() { # check <tên ca> <exit mong đợi> <chuỗi phải có trong output> <kết quả run>
  local name="$1" want_rc="$2" want_txt="$3" got="$4"
  local rc="${got%%|*}" out="${got#*|}"
  if [ "$rc" = "$want_rc" ] && [[ "$out" == *"$want_txt"* ]]; then
    echo "  ok   $name (exit $rc)"
  else
    echo "  FAIL $name — mong đợi exit $want_rc + \"$want_txt\", nhận exit $rc: $out"
    fails=$((fails + 1))
  fi
}

put() { # put <đường dẫn> — ghi stdin vào file, tạo thư mục cha
  mkdir -p "$(dirname "$1")"
  cat > "$1"
}

edit() { # edit <file> <perl biểu thức s///> — sửa tại chỗ
  perl -0pi -e "$2" "$1"
}

base() { # base <tên ca> → in đường dẫn ca: hợp đồng rỗng đường gọi, khớp code và migration
  local c="$TMPROOT/$1"
  put "$c/mig/20260101000000_a.up.sql" <<'EOF'
-- CONSTRAINT ghost_check CHECK (x) — chú thích, không phải tên
CREATE TABLE sales_order (
  id bigint,
  total_vnd bigint NOT NULL,
  CONSTRAINT sales_order_pkey PRIMARY KEY (id),
  CONSTRAINT sales_order_total_check
    CHECK (total_vnd >= 0)
);
CREATE TABLE order_line (
  id bigint,
  sales_order_id bigint,
  CONSTRAINT order_line_pkey PRIMARY KEY (id),
  CONSTRAINT order_line_order_fkey FOREIGN KEY (sales_order_id) REFERENCES sales_order (id)
);
CREATE UNIQUE INDEX order_line_one_per_order_key ON order_line (sales_order_id);
CREATE INDEX order_line_order_idx ON order_line (sales_order_id);
EOF
  put "$c/mig/20260101000000_a.down.sql" <<'EOF'
DROP TABLE order_line;
CONSTRAINT down_only_check CHECK (false)
EOF
  put "$c/mig/20260102000000_b.up.sql" <<'EOF'
ALTER TABLE sales_order ADD CONSTRAINT sales_order_old_check CHECK (true);
ALTER TABLE sales_order DROP CONSTRAINT sales_order_old_check;
CREATE FUNCTION guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.total_vnd > 10 THEN
    RAISE EXCEPTION 'quá; dừng' USING ERRCODE = 'check_violation',
      CONSTRAINT = 'sales_order_guard_check';
  END IF;
  RETURN NEW;
END $$;
EOF
  put "$c/openapi.yaml" <<'EOF'
openapi: 3.1.0
info:
  title: Thử
  version: 0.1.0
# Mỗi lát thêm đường gọi của mình.
paths: {}
components:
  schemas:
    ErrorCode:
      type: string
      enum:
        - internal_error
        - invalid_request
      x-http-status:
        internal_error: 500
        invalid_request: 400
    Error:
      type: object
      required: [code]
      properties:
        code:
          $ref: '#/components/schemas/ErrorCode'
x-constraint-errors:
  order_line_one_per_order_key: unreviewed
  order_line_order_fkey: unreviewed
  order_line_pkey: internal
  sales_order_guard_check: unreviewed
  sales_order_pkey: internal
  sales_order_total_check: unreviewed
EOF
  put "$c/be/internal/apierr/ma.go" <<'EOF'
package apierr

type Code string

const (
	CodeInternalError  Code = "internal_error"
	CodeInvalidRequest Code = "invalid_request"
)

var statusOf = map[Code]int{
	CodeInternalError:  500,
	CodeInvalidRequest: 400,
}

// constraintCodes: chỉ dòng có mã công khai ở hợp đồng.
var constraintCodes = map[string]Code{}
EOF
  put "$c/be/internal/apierr/ma_test.go" <<'EOF'
package apierr

const CodeTestOnly Code = "test_only"

func x() { mux.HandleFunc("POST /chi-trong-test", nil) }
EOF
  printf '%s' "$c"
}

with_route() { # with_route <ca> — một đường gọi ở cả hợp đồng và code
  local c="$1"
  edit "$c/openapi.yaml" 's/^paths: \{\}$/paths:\n  \/orders\/{id}:\n    get:\n      responses: {}\n    post:\n      responses: {}/m'
  put "$c/be/internal/order/http.go" <<'EOF'
package order

func Routes(mux *http.ServeMux) {
	mux.HandleFunc("GET /orders/{id}", get)
	mux.HandleFunc(
		"POST /orders/{id}", post)
}
EOF
}

echo "check-api-contract.test:"

c="$(base base)"
check "1 cây khớp ⇒ xanh, in số mỗi phía" 0 "check-api-contract: PASS" "$(run "$c")"
check "1b đếm tên ở migration và dòng ánh xạ" 0 "6 tên từ chối ở migration, 6 dòng ánh xạ" "$(run "$c")"
check "1c in đường gọi của cả hai phía, kể cả khi rỗng" 0 "0 đường gọi ở hợp đồng, 0 ở code" "$(run "$c")"

c="$(base route_both)"; with_route "$c"
check "2 cùng đường gọi hai phía ⇒ xanh" 0 "2 đường gọi ở hợp đồng, 2 ở code" "$(run "$c")"

c="$(base route_code_only)"
put "$c/be/internal/order/http.go" <<'EOF'
package order

func Routes(mux *http.ServeMux) { mux.HandleFunc("POST /orders", create) }
EOF
check "3 đường gọi chỉ ở code ⇒ đỏ" 1 "chỉ ở code: POST /orders" "$(run "$c")"

c="$(base route_contract_only)"; with_route "$c"
edit "$c/be/internal/order/http.go" 's/\tmux.HandleFunc\(\n\t\t"POST \/orders\/\{id\}", post\)\n//'
check "4 đường gọi chỉ ở hợp đồng ⇒ đỏ" 1 "chỉ ở hợp đồng: POST /orders/{id}" "$(run "$c")"

c="$(base route_no_method)"
put "$c/be/internal/order/http.go" <<'EOF'
package order

func Routes(mux *http.ServeMux) { mux.Handle("/orders", h) }
EOF
check "5 đường gọi không nêu phương thức ⇒ đỏ" 1 "không nêu phương thức" "$(run "$c")"

c="$(base route_dynamic)"
put "$c/be/internal/order/http.go" <<'EOF'
package order

func Routes(mux *http.ServeMux) { mux.HandleFunc(pattern, h) }
EOF
check "6 mẫu đường gọi không phải chuỗi trần ⇒ đỏ" 1 "không đọc được mẫu đường gọi" "$(run "$c")"

c="$(base name_missing)"
edit "$c/openapi.yaml" 's/^  sales_order_total_check: unreviewed\n//m'
check "7 tên ở migration chưa có dòng ánh xạ ⇒ đỏ" 1 "chưa có dòng ánh xạ: sales_order_total_check" "$(run "$c")"

c="$(base name_stale)"
edit "$c/openapi.yaml" 's/^x-constraint-errors:\n/x-constraint-errors:\n  sales_order_old_check: unreviewed\n/m'
check "8 dòng ánh xạ cho tên đã bị gỡ ⇒ đỏ" 1 "không có trong migration: sales_order_old_check" "$(run "$c")"

c="$(base raise_missing)"
edit "$c/openapi.yaml" 's/^  sales_order_guard_check: unreviewed\n//m'
check "9 tên lời từ chối của trigger chưa có dòng ⇒ đỏ" 1 "chưa có dòng ánh xạ: sales_order_guard_check" "$(run "$c")"

c="$(base raise_dynamic)"
edit "$c/mig/20260102000000_b.up.sql" "s/CONSTRAINT = 'sales_order_guard_check'/CONSTRAINT = TG_TABLE_NAME || '_guard_check'/"
check "10 tên lời từ chối ghép lúc chạy ⇒ đỏ" 1 "tên lời từ chối không đọc được" "$(run "$c")"

c="$(base index_dropped)"
put "$c/mig/20260103000000_c.up.sql" <<'EOF'
DROP INDEX order_line_one_per_order_key;
EOF
check "11 chỉ mục duy nhất đã gỡ mà còn dòng ⇒ đỏ" 1 "không có trong migration: order_line_one_per_order_key" "$(run "$c")"

c="$(base table_dropped)"
put "$c/mig/20260103000000_c.up.sql" <<'EOF'
DROP TABLE order_line;
EOF
edit "$c/openapi.yaml" 's/^  order_line_\w+: \w+\n//mg'
check "12 bảng đã gỡ kéo theo tên của nó ⇒ xanh khi gỡ dòng" 0 "3 tên từ chối ở migration, 3 dòng ánh xạ" "$(run "$c")"

c="$(base renamed)"
put "$c/mig/20260103000000_c.up.sql" <<'EOF'
ALTER TABLE sales_order RENAME CONSTRAINT sales_order_total_check TO sales_order_total_nonneg_check;
EOF
check "13 tên đổi ⇒ dòng theo tên cũ đỏ" 1 "chưa có dòng ánh xạ: sales_order_total_nonneg_check" "$(run "$c")"

c="$(base bad_value)"
edit "$c/openapi.yaml" 's/^  sales_order_total_check: unreviewed$/  sales_order_total_check: total_negative/m'
check "14 giá trị không phải mã của enum ⇒ đỏ" 1 "không phải mã của ErrorCode: total_negative" "$(run "$c")"

c="$(base public_row)"
edit "$c/openapi.yaml" 's/^        - invalid_request\n/        - invalid_request\n        - total_negative\n/m; s/^        invalid_request: 400\n/        invalid_request: 400\n        total_negative: 409\n/m; s/^  sales_order_total_check: unreviewed$/  sales_order_total_check: total_negative/m'
edit "$c/be/internal/apierr/ma.go" 's/\tCodeInvalidRequest Code = "invalid_request"\n/\tCodeInvalidRequest Code = "invalid_request"\n\tCodeTotalNegative  Code = "total_negative"\n/; s/\tCodeInvalidRequest: 400,\n/\tCodeInvalidRequest: 400,\n\tCodeTotalNegative:  409,\n/; s/map\[string\]Code\{\}/map[string]Code{\n\t"sales_order_total_check": CodeTotalNegative,\n}/'
check "15 một dòng có mã, hai phía khớp ⇒ xanh" 0 "1 dòng mang mã công khai" "$(run "$c")"

c="$(base public_row_go_missing)"
cp "$TMPROOT/public_row/openapi.yaml" "$c/openapi.yaml"
cp "$TMPROOT/public_row/be/internal/apierr/ma.go" "$c/be/internal/apierr/ma.go"
edit "$c/be/internal/apierr/ma.go" 's/\t"sales_order_total_check": CodeTotalNegative,\n//'
check "16 dòng có mã ở hợp đồng mà code thiếu ⇒ đỏ" 1 "bảng ánh xạ của code thiếu: sales_order_total_check → total_negative" "$(run "$c")"

c="$(base public_row_go_extra)"
edit "$c/be/internal/apierr/ma.go" 's/map\[string\]Code\{\}/map[string]Code{\n\t"order_line_order_fkey": CodeInvalidRequest,\n}/'
check "17 code ánh xạ một tên mà hợp đồng không ⇒ đỏ" 1 "bảng ánh xạ của code thừa: order_line_order_fkey → invalid_request" "$(run "$c")"

c="$(base go_const_missing)"
edit "$c/be/internal/apierr/ma.go" 's/\tCodeInvalidRequest Code = "invalid_request"\n//; s/\tCodeInvalidRequest: 400,\n//'
check "18 mã ở hợp đồng không có hằng trong code ⇒ đỏ" 1 "mã chỉ ở hợp đồng: invalid_request" "$(run "$c")"

c="$(base go_const_extra)"
edit "$c/be/internal/apierr/ma.go" 's/\tCodeInvalidRequest Code = "invalid_request"\n/\tCodeInvalidRequest Code = "invalid_request"\n\tCodeForbidden      Code = "forbidden"\n/; s/\tCodeInvalidRequest: 400,\n/\tCodeInvalidRequest: 400,\n\tCodeForbidden:      403,\n/'
check "19 hằng mã trong code mà hợp đồng không có ⇒ đỏ" 1 "mã chỉ ở code: forbidden" "$(run "$c")"

c="$(base status_diff)"
edit "$c/be/internal/apierr/ma.go" 's/\tCodeInvalidRequest: 400,/\tCodeInvalidRequest: 422,/'
check "20 status của một mã lệch ⇒ đỏ" 1 "status của invalid_request: hợp đồng 400, code 422" "$(run "$c")"

c="$(base status_missing)"
edit "$c/openapi.yaml" 's/^        invalid_request: 400\n//m'
check "21 mã không có status ở hợp đồng ⇒ đỏ" 1 "mã không có status ở hợp đồng: invalid_request" "$(run "$c")"

c="$(base no_internal)"
edit "$c/openapi.yaml" 's/^        - internal_error\n//m; s/^        internal_error: 500\n//m'
edit "$c/be/internal/apierr/ma.go" 's/\tCodeInternalError  Code = "internal_error"\n//; s/\tCodeInternalError:  500,\n//'
check "22 enum không có internal_error ⇒ đỏ" 1 "ErrorCode phải có internal_error" "$(run "$c")"

c="$(base openapi_30)"
edit "$c/openapi.yaml" 's/^openapi: 3.1.0$/openapi: 3.0.3/m'
check "23 không phải OpenAPI 3.1 ⇒ đỏ" 1 "openapi phải là 3.1" "$(run "$c")"

c="$(base no_version)"
edit "$c/openapi.yaml" 's/^  version: 0.1.0\n//m'
check "24 thiếu info.version ⇒ đỏ" 1 "info.version phải là MAJOR.MINOR.PATCH" "$(run "$c")"

c="$(base no_contract)"
rm "$c/openapi.yaml"
check "25 có be/ mà không có hợp đồng ⇒ đỏ" 1 "không có hợp đồng" "$(run "$c")"

c="$TMPROOT/empty"; mkdir -p "$c"
check "26 không be/ không hợp đồng ⇒ skipping" 0 "skipping" "$(run "$c")"

c="$(base listing)"; with_route "$c"
check "27 --list in đường gọi từng phía" 0 "hợp đồng	GET /orders/{id}" "$(run "$c" --list)"
check "27b --list in tên và giá trị ánh xạ" 0 "ánh xạ	sales_order_total_check	unreviewed" "$(run "$c" --list)"

# 28: đổi hợp đồng so với HEAD mà không tăng phiên bản ⇒ đỏ; tăng ⇒ xanh; lùi ⇒ đỏ.
c="$(base bump)"
git -C "$c" init -q && git -C "$c" config user.email t@t && git -C "$c" config user.name t
git -C "$c" add -A >/dev/null && git -C "$c" commit -qm init >/dev/null
check "28a hợp đồng giống HEAD ⇒ xanh" 0 "check-api-contract: PASS" "$(run "$c")"
edit "$c/openapi.yaml" 's/^  title: Thử$/  title: Thử lại/m'
check "28b đổi hợp đồng không tăng phiên bản ⇒ đỏ" 1 "hợp đồng đổi so với HEAD mà info.version vẫn 0.1.0" "$(run "$c")"
edit "$c/openapi.yaml" 's/^  version: 0.1.0$/  version: 0.2.0/m'
check "28c tăng phiên bản ⇒ xanh" 0 "check-api-contract: PASS" "$(run "$c")"
edit "$c/openapi.yaml" 's/^  version: 0.2.0$/  version: 0.0.9/m'
check "28d lùi phiên bản ⇒ đỏ" 1 "info.version 0.0.9 không lớn hơn 0.1.0 ở HEAD" "$(run "$c")"

# 29–37: ma trận vai × cửa (P3-05, ADR-085) — thư mục cửa · dòng ma trận · khai báo
# authz.Door phải là cùng một tập, lớp hai phía bằng nhau. Viết trước khi sửa script.
with_door() { # with_door <ca> — một cửa khớp ở cả ba chỗ
  local c="$1"
  put "$c/be/internal/authz/authz.go" <<'EOF'
package authz

type Need string

const (
	NeedCounter Need = "quay"
	NeedOwner   Need = "chu_quan"
)

type Door struct {
	Code string
	Need Need
}
EOF
  put "$c/be/internal/qr/sql/doi_ma/cap_ma.sql" <<'EOF'
SELECT qr_code_issue($1);
EOF
  put "$c/be/internal/qr/cua.go" <<'EOF'
package qr

var DoiMa = authz.Door{Code: "qr/doi_ma", Need: authz.NeedOwner}
EOF
  put "$c/be/internal/qr/cua_test.go" <<'EOF'
package qr

var cuaThu = authz.Door{Code: "test/chi_trong_test", Need: authz.NeedCounter}
EOF
  put "$c/02-vai-va-quyen.md" <<'EOF'
# Ma trận thử

| Cửa | Lớp | Nguồn |
|---|---|---|
| `qr/doi_ma` | `chu_quan` | U-062 |
EOF
}

c="$(base door_ok)"; with_door "$c"
check "29 cửa khớp thư mục · ma trận · khai báo ⇒ xanh" 0 "1 cửa, 1 dòng ma trận, 1 khai báo authz.Door" "$(run "$c")"
check "29b --list in dòng ma trận" 0 "ma trận	qr/doi_ma	chu_quan" "$(run "$c" --list)"

c="$(base door_no_row)"; with_door "$c"
edit "$c/02-vai-va-quyen.md" 's/^\| `qr\/doi_ma`.*\n//m'
check "30 thư mục cửa không có dòng ma trận ⇒ đỏ" 1 "cửa không có dòng ma trận: qr/doi_ma" "$(run "$c")"

c="$(base door_row_only)"; with_door "$c"
edit "$c/02-vai-va-quyen.md" 's/^(\| `qr\/doi_ma`.*\n)/$1| `don\/huy` | `quay` | §6.13 |\n/m'
check "31 dòng ma trận không có thư mục cửa ⇒ đỏ" 1 "dòng ma trận không có cửa: don/huy" "$(run "$c")"

c="$(base door_no_decl)"; with_door "$c"
edit "$c/be/internal/qr/cua.go" 's/^var DoiMa.*\n//m'
check "32 cửa không khai authz.Door (khai trong _test.go không tính) ⇒ đỏ" 1 "cửa không khai authz.Door: qr/doi_ma" "$(run "$c")"

c="$(base door_need_diff)"; with_door "$c"
edit "$c/be/internal/qr/cua.go" 's/authz.NeedOwner/authz.NeedCounter/'
check "33 lớp ở ma trận khác lớp ở code ⇒ đỏ" 1 "lớp quyền của qr/doi_ma: ma trận chu_quan, code quay" "$(run "$c")"

c="$(base door_need_unknown)"; with_door "$c"
edit "$c/02-vai-va-quyen.md" 's/`chu_quan`/`ai_cung_duoc`/'
check "34 lớp ở ma trận không phải lớp của authz ⇒ đỏ" 1 "lớp không có trong authz: ai_cung_duoc" "$(run "$c")"

c="$(base door_row_twice)"; with_door "$c"
edit "$c/02-vai-va-quyen.md" 's/^(\| `qr\/doi_ma`.*\n)/$1$1/m'
check "35 một cửa hai dòng ma trận ⇒ đỏ" 1 "cửa có hơn một dòng ma trận: qr/doi_ma" "$(run "$c")"

c="$(base door_decl_no_dir)"; with_door "$c"
rm -r "$c/be/internal/qr/sql"
edit "$c/02-vai-va-quyen.md" 's/^\| `qr\/doi_ma`.*\n//m'
check "36 khai authz.Door mà không có thư mục cửa ⇒ đỏ" 1 "khai authz.Door mà không có cửa: qr/doi_ma" "$(run "$c")"

c="$(base door_no_matrix)"; with_door "$c"
rm "$c/02-vai-va-quyen.md"
check "37 có cửa mà không có file ma trận ⇒ đỏ" 1 "không có ma trận" "$(run "$c")"

if [ "$fails" -eq 0 ]; then
  echo "check-api-contract.test: OK"
else
  echo "check-api-contract.test: FAIL — $fails ca"
  exit 1
fi
