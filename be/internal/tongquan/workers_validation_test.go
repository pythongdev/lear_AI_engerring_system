package tongquan_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/tongquan"
	"github.com/gin-gonic/gin"
)

// Pool nil: hình sai phải bị chặn trước quyền và mọi truy cập database.
func TestQC14_WorkersPresentKiemHinhTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	tongquan.Routes(r, tongquan.NewService(nil))
	for _, body := range []string{`{}`, `{"worker_count":null}`, `{"worker_count":0}`, `{"worker_count":-1}`, `{"worker_count":1.5}`, `{"worker_count":2147483648}`, `{"worker_count":"3"}`, `{"worker_count":true}`} {
		t.Run(body, func(t *testing.T) {
			req := httptest.NewRequest("POST", "/workers-present-declarations", strings.NewReader(body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)
			var out struct{ Code, Field string }
			if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
				t.Fatalf("status=%d body=%s: %v", w.Code, w.Body.String(), err)
			}
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != "worker_count" {
				t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
			}
		})
	}
}
