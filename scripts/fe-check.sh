#!/usr/bin/env bash
# VÌ SAO CÓ: Gate 1 phải kiểm frontend và type sinh đúng hợp đồng (QC-18).
# ĐỌC GÌ: FE_CHECK_DIR (mặc định fe), FE_CHECK_OPENAPI (mặc định
#   docs/product/3-be/openapi.yaml), tương đối gốc repo hoặc tuyệt đối.
#   Cờ sinh lấy từ scripts.gen:api của package.json; CLI ở node_modules cục bộ.
# ĐỎ KHI NÀO: npm ci/lint/typecheck/test/build lỗi, sinh lỗi hoặc schema.ts lệch.
# KHÔNG BẮT: nghiệp vụ, hành vi trên trình duyệt thật. Bước so chỉ ghi mktemp,
#   không ghi fe/. Các bước npm thông thường vẫn tạo cache/build như khi chạy tay.
#   FE_CHECK_ONLY=apigen chỉ so type; không tự cài gói, phù hợp test không mạng.
#   gen:api phải là CLI trực tiếp với đối số đơn giản; không thực thi shell từ JSON.
# EXIT: 0 = đạt hoặc thiếu package.json; khác 0 = bước đầu tiên hỏng.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
FE_DIR="${FE_CHECK_DIR:-fe}"
OPENAPI="${FE_CHECK_OPENAPI:-docs/product/3-be/openapi.yaml}"
[[ "$OPENAPI" = /* ]] || OPENAPI="$ROOT/$OPENAPI"
if [ ! -f "$FE_DIR/package.json" ]; then
  echo "fe-check: bỏ qua — không có $FE_DIR/package.json"
  exit 0
fi
FE_DIR="$(cd "$FE_DIR" && pwd)"
case "${FE_CHECK_ONLY:-}" in
  '')
    [ -d "$FE_DIR/node_modules" ] || (cd "$FE_DIR" && npm ci)
    ;;
  apigen) ;;
  *) echo 'fe-check: FAIL — FE_CHECK_ONLY chỉ nhận apigen'; exit 1 ;;
esac
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# So trước để lệch hợp đồng được báo ngay, trước các bước tốn thời gian.
node - "$FE_DIR" "$OPENAPI" "$TEMP_TREE/schema.ts" <<'JS'
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const [dir, input, output] = process.argv.slice(2);
const command = JSON.parse(fs.readFileSync(path.join(dir, 'package.json'), 'utf8')).scripts?.['gen:api'];
// Chấp nhận khuôn CLI hiện tại, fail đóng nếu owner chuyển sang lệnh shell khác.
if (typeof command !== 'string' || !/^[\w./:= -]+$/.test(command)) {
  console.error('fe-check: FAIL — gen:api phải là lệnh CLI trực tiếp, đối số không chứa shell/quote');
  process.exit(1);
}
const args = command.trim().split(/\s+/);
const cli = args.shift();
const out = args.indexOf('-o') >= 0 ? args.indexOf('-o') : args.indexOf('--output');
if (cli !== 'openapi-typescript' || !args[0] || args[0].startsWith('-') || out < 1 || !args[out + 1]
    || args[out + 1] !== 'src/lib/api/schema.ts'
    || args.filter(x => x === '-o' || x === '--output' || x.startsWith('--output=')).length !== 1) {
  console.error('fe-check: FAIL — gen:api không khớp khuôn input -o src/lib/api/schema.ts');
  process.exit(1);
}
args[0] = input;
args[out + 1] = output;
const result = spawnSync(path.join(dir, 'node_modules/.bin/openapi-typescript'), args, { cwd: dir, stdio: 'inherit' });
if (result.error) console.error(`fe-check: FAIL — ${result.error.message}`);
process.exit(result.status ?? 1);
JS
if ! diff -u "$FE_DIR/src/lib/api/schema.ts" "$TEMP_TREE/schema.ts" > "$TEMP_TREE/diff"; then
  sed -n '1,80p' "$TEMP_TREE/diff"
  echo 'fe-check: FAIL — type sinh lệch hợp đồng; sửa bằng: cd fe && npm run gen:api'
  exit 1
fi
echo 'fe-check: apigen PASS — schema.ts khớp hợp đồng'
if [ "${FE_CHECK_ONLY:-}" != apigen ]; then
  (cd "$FE_DIR" && npm run lint && npm run typecheck && npm test && npm run build)
fi
echo 'fe-check: PASS'
