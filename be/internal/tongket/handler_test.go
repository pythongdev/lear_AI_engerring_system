package tongket_test

import (
	"banhcuon/be/internal/tongket"
	"github.com/gin-gonic/gin"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestQC14_NgaySaiTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	tongket.Routes(r, tongket.NewService(nil))
	for _, day := range []string{"2026-02-30", "2026-2-01", "0000-01-01", "abc"} {
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest("GET", "/sale-days/"+day+"/summary", nil))
		if w.Code != 400 || !strings.Contains(w.Body.String(), `"code":"invalid_request"`) || !strings.Contains(w.Body.String(), `"field":"sale_date"`) {
			t.Fatalf("%s: %d %s", day, w.Code, w.Body.String())
		}
	}
}
