package daotao_test

import (
	"banhcuon/be/internal/daotao"
	"bytes"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"mime/multipart"
	"net/http/httptest"
	"strings"
	"testing"
)

// Pool nil: mọi lời từ chối hình phải xảy ra trước quyền và database.
func TestQC14_HinhDaoTaoTruocQuyenVaDatabase(t *testing.T) {
	r := gin.New()
	daotao.Routes(r, daotao.NewService(nil, t.TempDir()))
	for _, c := range []struct{ method, path, body, field string }{
		{"GET", "/assigned-tasks/x/guides", "", "assigned_task_id"},
		{"POST", "/assigned-tasks/0/guides", "{}", "assigned_task_id"},
		{"GET", "/assigned-tasks/1/guides?include_hidden=", "", "include_hidden"},
		{"GET", "/assigned-task-guides/-1/file", "", "assigned_task_guide_id"},
		{"PUT", "/assigned-task-guides/x", "{}", "assigned_task_guide_id"},
		{"POST", "/assigned-task-guides/0/hiding", "{}", "assigned_task_guide_id"},
		{"PUT", "/assigned-task-guides/1", `{"body":"  ","reason":"x"}`, "body"},
		{"PUT", "/assigned-task-guides/1", `{"body":"x"}`, "reason"},
		{"POST", "/assigned-task-guides/1/hiding", "{}", "reason"},
		{"POST", "/training-records", "{}", "trainee_person_id"},
		{"POST", "/training-records", `{"trainee_person_id":-1,"rating":"pass"}`, "trainee_person_id"},
		{"POST", "/training-records", `{"trainee_person_id":1}`, "remark"},
		{"POST", "/training-records", `{"trainee_person_id":1,"remark":null,"rating":null}`, "remark"},
		{"POST", "/training-records", `{"trainee_person_id":1,"remark":" "}`, "remark"},
		{"POST", "/training-records", `{"trainee_person_id":1,"rating":8}`, "rating"},
		{"POST", "/training-records", `{"trainee_person_id":1,"rating":""}`, "rating"},
		{"PUT", "/training-records/0", "{}", "training_record_id"},
		{"POST", "/training-records/no/hiding", "{}", "training_record_id"},
		{"PUT", "/training-records/1", `{"remark":"x","rating":"pass"}`, "reason"},
		{"PUT", "/training-records/1", `{"reason":"x"}`, "remark"},
		{"POST", "/training-records/1/hiding", `{"reason":" "}`, "reason"},
		{"GET", "/training-records?trainee_person_id=", "", "trainee_person_id"},
		{"GET", "/training-records?trainee_person_id=0", "", "trainee_person_id"},
		{"GET", "/training-records?trainee_person_id=abc", "", "trainee_person_id"},
		{"GET", "/training-records?include_hidden=TRUE", "", "include_hidden"},
		{"POST", "/assigned-tasks/1/guides", "{}", ""},
	} {
		t.Run(c.method+c.path+c.field, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest(c.method, c.path, strings.NewReader(c.body)))
			var out struct{ Code, Field string }
			if e := json.Unmarshal(w.Body.Bytes(), &out); e != nil {
				t.Fatal(e)
			}
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != c.field {
				t.Fatalf("muốn 400 field=%s, nhận %d %s", c.field, w.Code, w.Body.String())
			}
		})
	}
	for _, c := range []struct {
		kind   string
		body   *string
		file   []byte
		field  string
		status int
	}{
		{"audio", nil, tepPNG, "kind", 400},
		{"text", nil, nil, "body", 400},
		{"text", ptr("x"), tepPNG, "file", 400},
		{"image", ptr(""), tepPNG, "body", 400},
		{"image", nil, nil, "file", 400},
		{"image", nil, []byte{}, "file", 400},
		{"image", nil, tepMP4, "file", 400},
		{"video", nil, tepPNG, "file", 400},
		{"image", nil, append(append([]byte{}, tepPNG...), make([]byte, 10<<20)...), "", 413},
	} {
		var b bytes.Buffer
		m := multipart.NewWriter(&b)
		if e := m.WriteField("kind", c.kind); e != nil {
			t.Fatal(e)
		}
		if c.body != nil {
			if e := m.WriteField("body", *c.body); e != nil {
				t.Fatal(e)
			}
		}
		if c.file != nil {
			f, e := m.CreateFormFile("file", "fake.txt")
			if e != nil {
				t.Fatal(e)
			}
			if _, e = f.Write(c.file); e != nil {
				t.Fatal(e)
			}
		}
		if e := m.Close(); e != nil {
			t.Fatal(e)
		}
		req := httptest.NewRequest("POST", "/assigned-tasks/1/guides", &b)
		req.Header.Set("Content-Type", m.FormDataContentType())
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		var out struct{ Code, Field string }
		if e := json.Unmarshal(w.Body.Bytes(), &out); e != nil {
			t.Fatal(e)
		}
		code := "invalid_request"
		if c.status == 413 {
			code = "file_too_large"
		}
		if w.Code != c.status || out.Code != code || out.Field != c.field {
			t.Fatalf("multipart %s: %d %s", c.kind, w.Code, w.Body.String())
		}
	}
}
func ptr(s string) *string { return &s }
