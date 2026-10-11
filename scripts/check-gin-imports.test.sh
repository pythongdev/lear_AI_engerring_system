#!/usr/bin/env bash
# Fixture chỉ đọc file; không biên dịch hay tải module.
set -euo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-gin-imports.sh"
TEMP_TREE="$(mktemp -d)"
trap 'rm -rf "$TEMP_TREE"' EXIT
check() {
  local name="$1" path="$2" expected="$3" pattern="$4" out rc=0
  mkdir -p "$TEMP_TREE/$name/$(dirname "$path")"
  cat > "$TEMP_TREE/$name/$path"
  out="$(GIN_IMPORTS_BE_DIR="$TEMP_TREE/$name" "$SCRIPT" 2>&1)" || rc=$?
  if [ "$rc" != "$expected" ] || [[ "$out" != *"$pattern"* ]]; then
    printf 'FAIL %s exit %s\n%s\n' "$name" "$rc" "$out"
    exit 1
  fi
  echo "  ok $name (exit $rc): $pattern"
}
for path in internal/menu/handler.go cmd/server/main.go internal/middleware/x.go internal/menu/x_test.go; do
  check "allowed_${path//\//_}" "$path" 0 'check-gin-imports: PASS' <<'GO'
package x
import "github.com/gin-gonic/gin"
GO
done
for path in internal/menu/service.go internal/menu/repository.go internal/apierr/x.go internal/menu/sub/handler.go; do
  check "denied_${path//\//_}" "$path" 1 "$path:2: import Gin" <<'GO'
package x
import "github.com/gin-gonic/gin"
GO
done
for alias in g _ .; do
  check "alias_$alias" internal/menu/service.go 1 'service.go:2: import Gin' <<GO
package x
import $alias "github.com/gin-gonic/gin/binding"
GO
done
check blocks internal/menu/service.go 1 'service.go:9: import Gin' <<'GO'
package x
import "fmt"
import (
  "strings"
  // "github.com/gin-gonic/gin"
)
import (
  /* comment */
  g "github.com/gin-gonic/gin"
)
GO
check ignored internal/menu/service.go 0 'check-gin-imports: PASS' <<'GO'
package x
// import "github.com/gin-gonic/gin"
/* import ("github.com/gin-gonic/gin/binding") */
var a = "github.com/gin-gonic/gin"
var b = `import "github.com/gin-gonic/gin"`
var c = "// import \"github.com/gin-gonic/gin\""
import (
  // "github.com/gin-gonic/gin"
  /* g "github.com/gin-gonic/gin/binding" */
  "fmt"
)
GO
check raw_import internal/menu/service.go 1 'service.go:2: import Gin' <<'GO'
package x
import `github.com/gin-gonic/gin`
GO
echo 'check-gin-imports.test: OK'
