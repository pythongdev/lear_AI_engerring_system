#!/usr/bin/env bash
# VÌ SAO CÓ: chứng minh phép so type của QC-18 biết đỏ khi hợp đồng đổi;
#   T-330 (2026-11-16) kiểm node_modules rỗng/cài dở để tránh ENOENT.
#   T-344 (2026-11-17) kiểm lời dừng bảo mật của build và giới hạn chạy lại.
# ĐỌC GÌ: hợp đồng thật, schema.ts và fe/node_modules nếu có; các ca cài dùng npm giả.
# ĐỎ KHI NÀO: so type sai hoặc cài lại thiếu công cụ không báo FAIL rõ ràng.
# KHÔNG BẮT: lint/build thật hay mạng; không cài gói, không sửa fe/ và hợp đồng thật.
# EXIT: 0 = mọi ca đạt; 1 = test hỏng.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$TEMP_TREE/bin"
cat > "$TEMP_TREE/bin/npm" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FAKE_NPM_LOG"
if [ "${1:-}" = run ] && [ "${2:-}" = build ]; then
  attempt="$(awk '$0 == "run build" { n++ } END { print n+0 }' "$FAKE_NPM_LOG")"
  case "${FAKE_NPM_BUILD_MODE:-pass}" in
    security_once)
      if [ "$attempt" -eq 1 ]; then
        echo 'Error [SecurityFatalError]: Your version of Next.js is affected by a known security vulnerability.'
        echo 'Retry the same command to continue the original task.'
        exit 1
      fi
      ;;
    security_twice)
      echo 'Error [SecurityFatalError]: Your version of Next.js is affected by a known security vulnerability.'
      echo 'Retry the same command to continue the original task.'
      exit 1
      ;;
    security_only)
      echo 'Error [SecurityFatalError]: Your version of Next.js is affected by a known security vulnerability.'
      exit 1
      ;;
    retry_only)
      echo 'Retry the same command to continue the original task.'
      exit 1
      ;;
    other_error)
      echo 'next build: lỗi khác'
      exit 1
      ;;
  esac
fi
if [ "${1:-}" = ci ]; then
  case "$FAKE_NPM_MODE" in
    install)
      mkdir -p "$FAKE_FE_DIR/node_modules/.bin"
      cp "$FAKE_CLI_TEMPLATE" "$FAKE_FE_DIR/node_modules/.bin/openapi-typescript"
      chmod +x "$FAKE_FE_DIR/node_modules/.bin/openapi-typescript"
      ;;
    no_tool) ;;
    fail) exit 1 ;;
  esac
fi
SH
chmod +x "$TEMP_TREE/bin/npm"
cat > "$TEMP_TREE/openapi-typescript" <<'SH'
#!/usr/bin/env bash
if [ "${1:-}" = --version ]; then
  echo 'openapi-typescript mock'
  exit 0
fi
input="$1"
shift
output=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o|--output) output="$2"; shift 2 ;;
    *) shift ;;
  esac
done
cp "$FAKE_SCHEMA_SOURCE" "$output"
if rg -q '/__fe_check_regression:' "$input"; then
  printf '\n// regression route\n' >> "$output"
fi
SH
chmod +x "$TEMP_TREE/openapi-typescript"

make_fixture() {
  local dir="$1"
  mkdir -p "$dir/fe/src/lib/api"
  printf '%s\n' '{"scripts":{"gen:api":"openapi-typescript docs/product/3-be/openapi.yaml -o src/lib/api/schema.ts"},"dependencies":{"next":"16.4.2"}}' > "$dir/fe/package.json"
  printf '%s\n' '// schema fixture' > "$dir/fe/src/lib/api/schema.ts"
  : > "$dir/openapi.yaml"
}

run_install_case() {
  local label="$1" setup="$2" mode="$3" expected_rc="$4" expected_ci="$5" pattern="$6"
  local dir="$TEMP_TREE/$label" rc=0 out ci_count
  make_fixture "$dir"
  case "$setup" in
    empty) mkdir -p "$dir/fe/node_modules" ;;
    missing_cli)
      mkdir -p "$dir/fe/node_modules/.bin"
      printf '#!/usr/bin/env bash\nexit 0\n' > "$dir/fe/node_modules/.bin/other-tool"
      chmod +x "$dir/fe/node_modules/.bin/other-tool"
      ;;
    complete)
      mkdir -p "$dir/fe/node_modules/.bin"
      cp "$TEMP_TREE/openapi-typescript" "$dir/fe/node_modules/.bin/openapi-typescript"
      ;;
  esac
  : > "$dir/npm.log"
  out="$(PATH="$TEMP_TREE/bin:$PATH" FAKE_NPM_LOG="$dir/npm.log" FAKE_NPM_MODE="$mode" \
    FAKE_FE_DIR="$dir/fe" FAKE_CLI_TEMPLATE="$TEMP_TREE/openapi-typescript" \
    FAKE_SCHEMA_SOURCE="$dir/fe/src/lib/api/schema.ts" FE_CHECK_DIR="$dir/fe" \
    FE_CHECK_OPENAPI="$dir/openapi.yaml" "$ROOT/scripts/fe-check.sh" 2>&1)" || rc=$?
  ci_count="$(awk '$0 == "ci" { n++ } END { print n+0 }' "$dir/npm.log")"
  if [ "$rc" -ne "$expected_rc" ] || [ "$ci_count" -ne "$expected_ci" ] || [[ "$out" != *"$pattern"* ]] || [[ "$out" == *ENOENT* ]]; then
    printf 'fe-check.test: FAIL — %s: exit %s (muốn %s), npm ci %s lần (muốn %s)\n%s\n' \
      "$label" "$rc" "$expected_rc" "$ci_count" "$expected_ci" "$out"
    exit 1
  fi
  printf '  ok %s: exit %s, npm ci %s lần, %s\n' "$label" "$rc" "$ci_count" "$pattern"
}

run_install_case 'node_modules rỗng' empty install 0 1 'fe-check: PASS'
run_install_case 'thiếu riêng openapi-typescript' missing_cli install 0 1 'fe-check: PASS'
run_install_case 'cài đủ' complete install 0 0 'fe-check: PASS'
run_install_case 'npm ci thoát 0 nhưng vẫn thiếu' empty no_tool 1 1 'fe-check: FAIL — thiếu openapi-typescript trong fe/node_modules sau khi chạy npm ci; hãy chạy: cd fe && npm ci'
run_install_case 'npm ci thoát 1' empty fail 1 1 'fe-check: FAIL — thiếu openapi-typescript trong fe/node_modules sau khi chạy npm ci; hãy chạy: cd fe && npm ci (npm ci thoát mã 1)'

run_build_case() {
  local label="$1" mode="$2" expected_rc="$3" expected_builds="$4" expected_notes="$5" pattern="$6"
  local next_version="${7:-16.4.2}" dir="$TEMP_TREE/$label" rc=0 out command count build_count note_count exact_note_count
  make_fixture "$dir"
  if [ "$next_version" = 'không rõ' ]; then
    printf '%s\n' '{"scripts":{"gen:api":"openapi-typescript docs/product/3-be/openapi.yaml -o src/lib/api/schema.ts"}}' > "$dir/fe/package.json"
  fi
  local expected_note="NOTE fe-check — next build dừng một lần vì khuyến cáo bảo mật của Next.js (đang ghim next $next_version); đã chạy lại. Nâng next là một task riêng (QC-18, work/findings.md F-076)."
  mkdir -p "$dir/fe/node_modules/.bin"
  cp "$TEMP_TREE/openapi-typescript" "$dir/fe/node_modules/.bin/openapi-typescript"
  : > "$dir/npm.log"
  out="$(PATH="$TEMP_TREE/bin:$PATH" FAKE_NPM_LOG="$dir/npm.log" FAKE_NPM_MODE=install \
    FAKE_NPM_BUILD_MODE="$mode" FAKE_SCHEMA_SOURCE="$dir/fe/src/lib/api/schema.ts" \
    FE_CHECK_DIR="$dir/fe" FE_CHECK_OPENAPI="$dir/openapi.yaml" \
    "$ROOT/scripts/fe-check.sh" 2>&1)" || rc=$?
  build_count="$(awk '$0 == "run build" { n++ } END { print n+0 }' "$dir/npm.log")"
  note_count="$(printf '%s\n' "$out" | awk '/^NOTE fe-check / { n++ } END { print n+0 }')"
  exact_note_count="$(printf '%s\n' "$out" | awk -v wanted="$expected_note" '$0 == wanted { n++ } END { print n+0 }')"
  for command in 'run lint' 'run typecheck' 'test'; do
    count="$(awk -v wanted="$command" '$0 == wanted { n++ } END { print n+0 }' "$dir/npm.log")"
    if [ "$count" -ne 1 ]; then
      printf 'fe-check.test: FAIL — %s: %s gọi %s lần (muốn 1)\n%s\n' "$label" "$command" "$count" "$out"
      exit 1
    fi
  done
  if [ "$rc" -ne "$expected_rc" ] || [ "$build_count" -ne "$expected_builds" ] \
    || [ "$note_count" -ne "$expected_notes" ] || [ "$exact_note_count" -ne "$expected_notes" ] \
    || [[ "$out" != *"$pattern"* ]] \
    || { [[ "$mode" = security_once || "$mode" = security_twice ]] \
      && [[ "$out" != *SecurityFatalError* || "$out" != *'Retry the same command'* ]]; }; then
    printf 'fe-check.test: FAIL — %s: exit %s (muốn %s), build %s lần (muốn %s), NOTE %s dòng (muốn %s), NOTE đúng nguyên văn %s dòng\n%s\n' \
      "$label" "$rc" "$expected_rc" "$build_count" "$expected_builds" "$note_count" "$expected_notes" "$exact_note_count" "$out"
    exit 1
  fi
  printf '  ok %s: exit %s, build %s lần, NOTE %s dòng, lint/typecheck/test mỗi lệnh 1 lần\n' \
    "$label" "$rc" "$build_count" "$note_count"
}

run_build_case 'build dừng một lần rồi đạt' security_once 0 2 1 'Retry the same command'
run_build_case 'thiếu phiên bản next' security_once 0 2 1 'Retry the same command' 'không rõ'
run_build_case 'build dừng cả hai lần' security_twice 1 2 1 'fe-check: FAIL — next build vẫn lỗi sau một lần chạy lại'
run_build_case 'build lỗi khác' other_error 1 1 0 'next build: lỗi khác'
run_build_case 'chỉ có SecurityFatalError' security_only 1 1 0 'SecurityFatalError'
run_build_case 'chỉ có Retry the same command' retry_only 1 1 0 'Retry the same command'
run_build_case 'build đạt ngay' pass 0 1 0 'fe-check: PASS'

# Chèn một path vào mapping paths hiện có; không tạo khoá paths trùng.
perl -0777 -pe 's/^paths:\s*$/paths:\n  \/__fe_check_regression:\n    get:\n      operationId: feCheckRegression\n      responses:\n        "204":\n          description: FE gate regression/m or die "Không tìm thấy paths\n"' \
  docs/product/3-be/openapi.yaml > "$TEMP_TREE/openapi.yaml"
run_case() {
  local input="$1" expected="$2" pattern="$3" rc=0 out
  out="$(FE_CHECK_DIR="$old_fe_dir" FE_CHECK_OPENAPI="$input" FE_CHECK_ONLY=apigen \
    FAKE_SCHEMA_SOURCE="$old_fe_dir/src/lib/api/schema.ts" "$ROOT/scripts/fe-check.sh" 2>&1)" || rc=$?
  if [ "$rc" != "$expected" ] || [[ "$out" != *"$pattern"* ]]; then
    printf 'fe-check.test: FAIL — exit %s (muốn %s)\n%s\n' "$rc" "$expected" "$out"
    exit 1
  fi
  printf '  ok exit %s: %s\n' "$rc" "$pattern"
}
if [ -x "$ROOT/fe/node_modules/.bin/openapi-typescript" ]; then
  old_fe_dir="$ROOT/fe"
  echo 'fe-check.test: so hợp đồng bằng openapi-typescript đã cài'
else
  old_fe_dir="$TEMP_TREE/old/fe"
  make_fixture "$TEMP_TREE/old"
  cp "$ROOT/fe/src/lib/api/schema.ts" "$old_fe_dir/src/lib/api/schema.ts"
  mkdir -p "$old_fe_dir/node_modules/.bin"
  cp "$TEMP_TREE/openapi-typescript" "$old_fe_dir/node_modules/.bin/openapi-typescript"
  echo 'fe-check.test: so hợp đồng bằng CLI giả vì fe/node_modules chưa cài'
fi
run_case "$ROOT/docs/product/3-be/openapi.yaml" 0 'fe-check: apigen PASS'
run_case "$TEMP_TREE/openapi.yaml" 1 'fe-check: FAIL — type sinh lệch hợp đồng'
echo 'fe-check.test: OK'
