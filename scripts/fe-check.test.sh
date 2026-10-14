#!/usr/bin/env bash
# VÌ SAO CÓ: chứng minh phép so type của QC-18 biết đỏ khi hợp đồng đổi.
# ĐỌC GÌ: hợp đồng thật và fe/node_modules có sẵn; bản hợp đồng tạm thêm route.
# ĐỎ KHI NÀO: bản thật không xanh hoặc bản thêm route không bị báo lệch.
# KHÔNG BẮT: lint/build hay mạng; không cài gói, không sửa fe/ và hợp đồng thật.
# EXIT: 0 = hai ca đạt hoặc thiếu node_modules (ghi rõ bỏ qua); 1 = test hỏng.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
if [ ! -d fe/node_modules ]; then
  echo 'fe-check.test: bỏ qua — fe/node_modules chưa cài (chạy ./scripts/fe-check.sh)'
  exit 0
fi
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# Chèn một path vào mapping paths hiện có; không tạo khoá paths trùng.
perl -0777 -pe 's/^paths:\s*$/paths:\n  \/__fe_check_regression:\n    get:\n      operationId: feCheckRegression\n      responses:\n        "204":\n          description: FE gate regression/m or die "Không tìm thấy paths\n"' \
  docs/product/3-be/openapi.yaml > "$TEMP_TREE/openapi.yaml"
run_case() {
  local input="$1" expected="$2" pattern="$3" rc=0 out
  out="$(FE_CHECK_DIR="$ROOT/fe" FE_CHECK_OPENAPI="$input" FE_CHECK_ONLY=apigen "$ROOT/scripts/fe-check.sh" 2>&1)" || rc=$?
  if [ "$rc" != "$expected" ] || [[ "$out" != *"$pattern"* ]]; then
    printf 'fe-check.test: FAIL — exit %s (muốn %s)\n%s\n' "$rc" "$expected" "$out"
    exit 1
  fi
  printf '  ok exit %s: %s\n' "$rc" "$pattern"
}
run_case "$ROOT/docs/product/3-be/openapi.yaml" 0 'fe-check: apigen PASS'
run_case "$TEMP_TREE/openapi.yaml" 1 'fe-check: FAIL — type sinh lệch hợp đồng'
echo 'fe-check.test: OK'
