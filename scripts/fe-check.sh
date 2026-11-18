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
# T-330 (2026-11-16): node_modules rỗng/cài dở từng lọt qua phép kiểm thư mục,
#   làm spawnSync báo ENOENT; kiểm CLI cần dùng trước và sau npm ci.
# T-344 (2026-11-17): F-076 tái diễn với next 16.4.2. Next build có thể thoát 1
#   một lần sau khi build xong để báo khuyến cáo bảo mật; chỉ chạy lại đúng một
#   lần khi output có đủ hai dấu hiệu của lời dừng, và luôn hiện cảnh báo.
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
REQUIRED_FE_BINS=(openapi-typescript)
missing_fe_bin() {
  local name path
  for name in "${REQUIRED_FE_BINS[@]}"; do
    path="$FE_DIR/node_modules/.bin/$name"
    if [ ! -d "$FE_DIR/node_modules" ] || [ ! -x "$path" ] || ! "$path" --version >/dev/null 2>&1; then
      printf '%s\n' "$name"
      return
    fi
  done
}
case "${FE_CHECK_ONLY:-}" in
  '')
    missing_tool="$(missing_fe_bin)"
    if [ -n "$missing_tool" ]; then
      npm_rc=0
      (cd "$FE_DIR" && npm ci) || npm_rc=$?
      missing_after="$(missing_fe_bin)"
      if [ "$npm_rc" -ne 0 ] || [ -n "$missing_after" ]; then
        message="fe-check: FAIL — thiếu ${missing_after:-$missing_tool} trong fe/node_modules sau khi chạy npm ci; hãy chạy: cd fe && npm ci"
        if [ "$npm_rc" -ne 0 ]; then
          message+=" (npm ci thoát mã $npm_rc)"
        fi
        printf '%s\n' "$message"
        exit 1
      fi
    fi
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
  (cd "$FE_DIR" && npm run lint && npm run typecheck && npm test)
  if (cd "$FE_DIR" && npm run build) 2>&1 | tee "$TEMP_TREE/build.log"; then
    :
  elif grep -Fq 'SecurityFatalError' "$TEMP_TREE/build.log" \
    && grep -Fq 'Retry the same command' "$TEMP_TREE/build.log"; then
    next_version="$(node -e '
      try {
        const fs = require("node:fs");
        const version = JSON.parse(fs.readFileSync(process.argv[1], "utf8")).dependencies?.next;
        process.stdout.write(typeof version === "string" && version ? version : "không rõ");
      } catch { process.stdout.write("không rõ"); }
    ' "$FE_DIR/package.json")" || next_version='không rõ'
    printf 'NOTE fe-check — next build dừng một lần vì khuyến cáo bảo mật của Next.js (đang ghim next %s); đã chạy lại. Nâng next là một task riêng (QC-18, work/findings.md F-076).\n' "$next_version"
    if ! (cd "$FE_DIR" && npm run build); then
      echo 'fe-check: FAIL — next build vẫn lỗi sau một lần chạy lại'
      exit 1
    fi
  else
    exit 1
  fi
fi
echo 'fe-check: PASS'
