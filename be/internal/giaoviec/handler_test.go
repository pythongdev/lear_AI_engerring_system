package giaoviec_test

import (
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"

	"banhcuon/be/internal/giaoviec"
	"github.com/gin-gonic/gin"
)

// Pool nil chứng minh yêu cầu sai bị chặn trước khi cửa đụng database/quyền.
func TestQC14_HinhGiaoViecTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	giaoviec.Routes(r, giaoviec.NewService(nil))
	for _, c := range []struct{ method, path, body, field string }{
		{"POST", "/assigned-tasks", `{}`, "content"},
		{"POST", "/assigned-tasks", `{"content":"  ","assignee_person_id":1}`, "content"},
		{"POST", "/assigned-tasks", `{"content":"x"}`, "assignee_person_id"},
		{"POST", "/assigned-tasks", `{"content":"x","assignee_person_id":-1}`, "assignee_person_id"},
		{"PUT", "/assigned-tasks/1", `{"content":"x","assignee_person_id":1,"reason":"  "}`, "reason"},
		{"PUT", "/assigned-tasks/1", `{"content":"x","assignee_person_id":0,"reason":"x"}`, "assignee_person_id"},
		{"PUT", "/assigned-tasks/1", `{"assignee_person_id":1,"reason":"x"}`, "content"},
		{"GET", "/assigned-tasks/nope", "", "assigned_task_id"},
		{"PUT", "/assigned-tasks/0", `{}`, "assigned_task_id"},
		{"POST", "/assigned-tasks/-1/hiding", `{}`, "assigned_task_id"},
		{"POST", "/assigned-tasks/nope/marks", `{}`, "assigned_task_id"},
		{"POST", "/assigned-tasks/1/hiding", `{}`, "reason"},
		{"POST", "/assigned-tasks/1/hiding", `{"reason":"  "}`, "reason"},
		{"POST", "/assigned-tasks/1/marks", `{}`, "mark"},
		{"POST", "/assigned-tasks/1/marks", `{"mark":"done "}`, "mark"},
		{"POST", "/assigned-tasks/1/marks", `{"mark":"finished"}`, "mark"},
		{"GET", "/assigned-tasks?assignee_person_id=", "", "assignee_person_id"},
		{"GET", "/assigned-tasks?assignee_person_id=0", "", "assignee_person_id"},
		{"GET", "/assigned-tasks?assignee_person_id=abc", "", "assignee_person_id"},
		{"GET", "/assigned-tasks?include_hidden=", "", "include_hidden"},
		{"GET", "/assigned-tasks?include_hidden=TRUE", "", "include_hidden"},
		{"GET", "/assigned-tasks?include_hidden=1", "", "include_hidden"},
	} {
		t.Run(c.method+" "+c.path+" "+c.field, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(c.method, c.path, strings.NewReader(c.body)))
			var out struct{ Code, Field string }
			if err := json.Unmarshal(w.Body.Bytes(), &out); err != nil {
				t.Fatal(err)
			}
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
				t.Fatalf("muốn 400 invalid_request field=%s; nhận %d %s", c.field, w.Code, w.Body.String())
			}
		})
	}
}
