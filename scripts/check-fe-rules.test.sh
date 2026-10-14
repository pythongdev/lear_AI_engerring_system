#!/usr/bin/env bash
# Hồi quy của scripts/check-fe-rules.sh (P4-03). Claude viết trước khi có script; mỗi luật
# một ca đỏ và một ca xanh gần giống. Fixture chỉ đọc file; không cần Node.
set -euo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-fe-rules.sh"
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
check() {
  local name="$1" path="$2" expected="$3" pattern="$4" out rc=0
  mkdir -p "$TEMP_TREE/$name/$(dirname "$path")"
  cat > "$TEMP_TREE/$name/$path"
  out="$(FE_RULES_DIR="$TEMP_TREE/$name" "$SCRIPT" 2>&1)" || rc=$?
  if [ "$rc" != "$expected" ] || [[ "$out" != *"$pattern"* ]]; then
    printf 'FAIL %s exit %s (muốn %s, chứa: %s)\n%s\n' "$name" "$rc" "$expected" "$pattern" "$out"
    exit 1
  fi
  echo "  ok $name (exit $rc): $pattern"
}

# --- cây rỗng và file sinh --------------------------------------------------------------
check empty src/x.ts 0 'check-fe-rules: PASS' <<'TS'
export const a = 1;
TS
check generated_schema_skipped src/lib/api/schema.ts 0 'check-fe-rules: PASS' <<'TS'
const total = price * qty; setQueryData(k, v); import "@mui/material";
TS
check node_modules_skipped node_modules/x/index.js 0 'check-fe-rules: PASS' <<'TS'
const total = price * qty;
TS

# --- cong-tien ---------------------------------------------------------------------------
check money_mul src/cart.ts 1 'src/cart.ts:2: cong-tien' <<'TS'
export function f(item: { price: number }, qty: number) {
  const total = item.price * qty;
  return total;
}
TS
check money_reduce src/sum.tsx 1 'src/sum.tsx:1: cong-tien' <<'TS'
const sum = lines.reduce((s, l) => s + l.amount_vnd, 0);
TS
check money_plus_assign src/a.ts 1 'src/a.ts:2: cong-tien' <<'TS'
let subtotal = 0;
subtotal += surcharge;
TS
check money_minus src/b.ts 1 'src/b.ts:1: cong-tien' <<'TS'
const due = totalVnd - discountVnd;
TS
check money_ok_index src/c.ts 0 'check-fe-rules: PASS' <<'TS'
const next = index + 1;
const half = width / 2;
TS
# Tên tiền khớp theo đoạn của định danh (camelCase, snake_case), không theo chuỗi con:
# "fee" trong feedback, "tien" trong patient, "gia" trong giaiDoan không phải tiền.
check money_ok_word_parts src/parts.ts 0 'check-fe-rules: PASS' <<'TS'
const a = feedbackCount + 1;
const b = patientIndex - 1;
const c = coffeeSize * 2;
const d = giaiDoan + 1;
TS
check money_segment_snake src/seg.ts 1 'src/seg.ts:1: cong-tien' <<'TS'
const due = line.unit_price_vnd * qty;
TS
check money_ok_display src/d.tsx 0 'check-fe-rules: PASS' <<'TS'
export const Row = ({ line }: P) => <span>{formatVnd(line.amount_vnd)}</span>;
TS
check money_ok_comment src/e.ts 0 'check-fe-rules: PASS' <<'TS'
// total = price * qty — frontend không làm phép này
/* subtotal += surcharge */
const x = 1;
TS
check money_ok_string src/f.ts 0 'check-fe-rules: PASS' <<'TS'
const label = "price + phụ thu";
const path = "/price-quotes";
TS

# --- bo-ui-ngoai (ADR-100) ---------------------------------------------------------------
check ui_mui src/g.tsx 1 'src/g.tsx:1: bo-ui-ngoai' <<'TS'
import Button from "@mui/material/Button";
TS
check ui_antd_require src/h.js 1 'src/h.js:1: bo-ui-ngoai' <<'TS'
const { Table } = require("antd");
TS
check ui_chakra_dynamic src/i.ts 1 'src/i.ts:1: bo-ui-ngoai' <<'TS'
const m = await import("@chakra-ui/react");
TS
check ui_package_json package.json 1 'package.json' <<'JSON'
{
  "dependencies": {
    "next": "16.4.0",
    "@mantine/core": "8.0.0"
  }
}
JSON
check ui_package_json_rule package.json 1 'bo-ui-ngoai' <<'JSON'
{ "devDependencies": { "react-bootstrap": "2.10.0" } }
JSON
check ui_ok_shadcn src/j.tsx 0 'check-fe-rules: PASS' <<'TS'
import { Button } from "@/components/ui/button";
import { Dialog } from "radix-ui";
import { Plus } from "lucide-react";
TS
check ui_ok_package_json package.json 0 'check-fe-rules: PASS' <<'JSON'
{ "dependencies": { "radix-ui": "1.8.1", "lucide-react": "1.56.0", "shadcn": "4.21.4" } }
JSON
check ui_ok_comment src/k.tsx 0 'check-fe-rules: PASS' <<'TS'
// không dùng "@mui/material" — ADR-100
export const k = 1;
TS

# --- cache-next (ADR-102 điểm 3a) --------------------------------------------------------
check cache_use_cache src/app/menu/page.tsx 1 'src/app/menu/page.tsx:1: cache-next' <<'TS'
"use cache";
export default async function Page() { return null; }
TS
check cache_use_cache_single src/l.ts 1 'src/l.ts:2: cache-next' <<'TS'
export async function load() {
  'use cache: remote'
  return 1;
}
TS
check cache_unstable src/m.ts 1 'src/m.ts:1: cache-next' <<'TS'
import { unstable_cache } from "next/cache";
TS
check cache_life src/n.ts 1 'src/n.ts:2: cache-next' <<'TS'
async function f() {
  cacheLife("hours");
}
TS
check cache_revalidate_export src/app/o/page.tsx 1 'src/app/o/page.tsx:1: cache-next' <<'TS'
export const revalidate = 60;
TS
check cache_force_static src/app/p/page.tsx 1 'src/app/p/page.tsx:1: cache-next' <<'TS'
export const dynamic = "force-static";
TS
check cache_force_cache src/q.ts 1 'src/q.ts:1: cache-next' <<'TS'
const r = await fetch(url, { cache: "force-cache" });
TS
check cache_next_revalidate src/r.ts 1 'src/r.ts:1: cache-next' <<'TS'
const r = await fetch(url, { next: { revalidate: 30 } });
TS
check cache_ok_no_store src/s.ts 0 'check-fe-rules: PASS' <<'TS'
const r = await fetch(url, { cache: "no-store" });
export const dynamic = "force-dynamic";
TS
check cache_ok_comment src/t.ts 0 'check-fe-rules: PASS' <<'TS'
// không "use cache" ở đây (ADR-102 điểm 3)
/* export const revalidate = 60; */
export const t = 1;
TS

# --- ghi-tay-cache (ADR-102 điểm 2 · 3b) -------------------------------------------------
check write_set_query_data src/u.ts 1 'src/u.ts:2: ghi-tay-cache' <<'TS'
export function onOk(qc: QueryClient, data: Menu) {
  qc.setQueryData(["menu"], data);
}
TS
check write_set_queries_data src/v.ts 1 'src/v.ts:1: ghi-tay-cache' <<'TS'
queryClient.setQueriesData({ queryKey: ["queue"] }, () => []);
TS
check write_ok_invalidate src/w.ts 0 'check-fe-rules: PASS' <<'TS'
await qc.invalidateQueries({ queryKey: ["menu"] });
qc.clear();
TS
check write_ok_comment src/x.ts 0 'check-fe-rules: PASS' <<'TS'
// không qc.setQueryData — ghi xong thì đọc lại
export const x = 1;
TS

echo 'check-fe-rules.test: OK'
