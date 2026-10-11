// Test hàm dựng router (T-151, QC-12). Viết TRƯỚC khi có router — Claude viết, Codex làm cho xanh
// mà không sửa điều kiện kiểm nào. Mọi yêu cầu đi qua đúng newRouter mà main.go dùng, trên PostgreSQL
// thật (QC-16): miền chưa chuyển chạy sau adapter gin.WrapH, nên hành vi phải y như ServeMux hôm nay.
package main

import (
	"bufio"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"regexp"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
)

const hopDong = "../../../docs/product/3-be/openapi.yaml"

func dungRouter(t *testing.T) *gin.Engine {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	return newRouter(pool, authz.ChonTen{})
}

func goi(r http.Handler, method, path, body string, header map[string]string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	for k, v := range header {
		req.Header.Set(k, v)
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

// thanLoi đọc thân lỗi theo hình chung {code, field?} và đỏ khi có khoá nào khác.
func thanLoi(t *testing.T, w *httptest.ResponseRecorder) (string, string) {
	t.Helper()
	if ct := w.Header().Get("Content-Type"); !strings.HasPrefix(ct, "application/json") {
		t.Fatalf("Content-Type=%q, thân=%q", ct, w.Body.String())
	}
	var m map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &m); err != nil {
		t.Fatalf("thân lỗi không phải JSON: %v — %q", err, w.Body.String())
	}
	for k := range m {
		if k != "code" && k != "field" {
			t.Fatalf("thân lỗi có khoá lạ %q: %q", k, w.Body.String())
		}
	}
	code, _ := m["code"].(string)
	field, _ := m["field"].(string)
	return code, field
}

func kiemLoi(t *testing.T, w *httptest.ResponseRecorder, status int, code, field string) {
	t.Helper()
	if w.Code != status {
		t.Fatalf("status=%d, muốn %d — thân=%q", w.Code, status, w.Body.String())
	}
	c, f := thanLoi(t, w)
	if c != code || f != field {
		t.Fatalf("lỗi={%q, %q}, muốn {%q, %q}", c, f, code, field)
	}
}

type duong struct{ method, path string }

// duongHopDong đọc các đường gọi của openapi.yaml theo khuôn 01-hop-dong-api.md §2: khoá đường thụt
// hai dấu cách, phương thức thụt bốn.
func duongHopDong(t *testing.T) []duong {
	t.Helper()
	f, err := os.Open(hopDong)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	reDuong := regexp.MustCompile(`^  (/[^:]*):\s*$`)
	rePT := regexp.MustCompile(`^    (get|post|put|patch|delete):\s*$`)
	var out []duong
	cur := ""
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		line := sc.Text()
		if strings.HasPrefix(line, "  ") && !strings.HasPrefix(line, "   ") && !reDuong.MatchString(line) {
			cur = ""
		}
		if m := reDuong.FindStringSubmatch(line); m != nil {
			cur = m[1]
			continue
		}
		if !strings.HasPrefix(line, " ") {
			cur = ""
			continue
		}
		if m := rePT.FindStringSubmatch(line); m != nil && cur != "" {
			out = append(out, duong{strings.ToUpper(m[1]), cur})
		}
	}
	if err := sc.Err(); err != nil {
		t.Fatal(err)
	}
	if len(out) < 40 {
		t.Fatalf("chỉ đọc được %d đường gọi từ %s — khuôn hợp đồng đổi?", len(out), hopDong)
	}
	return out
}

var thamSo = regexp.MustCompile(`\{[a-z_]+\}`)

// Mỗi đường gọi của hợp đồng phải tới một handler của miền qua router. Thân rỗng, không người:
// handler trả lỗi JSON của hợp đồng (400 · 401 · 404 …), không bao giờ là 404/405 văn bản của
// ServeMux — tức miền chưa được nối vào router. Không yêu cầu nào ghi được vì thiếu thân hoặc người.
func TestQC12_RouterPhucVuMoiDuongCuaHopDong(t *testing.T) {
	r := dungRouter(t)
	for _, d := range duongHopDong(t) {
		path := thamSo.ReplaceAllString(d.path, "1")
		w := goi(r, d.method, path, "", nil)
		if w.Code == http.StatusMethodNotAllowed || !strings.HasPrefix(w.Header().Get("Content-Type"), "application/json") {
			t.Errorf("%s %s (%s): status=%d, Content-Type=%q, thân=%q — đường gọi chưa nối vào router",
				d.method, d.path, path, w.Code, w.Header().Get("Content-Type"), w.Body.String())
		}
	}
}

// Tham số đường dẫn tới đúng tên: id sai hình ⇒ invalid_request nêu đúng trường; id đúng hình ⇒ đi
// tiếp tới quyền (unauthenticated), tức handler đọc được giá trị qua adapter.
func TestQC12_RouterGiuThamSoDuongDan(t *testing.T) {
	r := dungRouter(t)
	than := `{"base_price_vnd": 1000, "reason": "test"}`
	kiemLoi(t, goi(r, "PUT", "/menu-components/abc/base-price", than, nil), 400, "invalid_request", "menu_component_id")
	kiemLoi(t, goi(r, "PUT", "/menu-components/5/base-price", than, nil), 401, "unauthenticated", "")
	thanTP := `{"quantity": 1, "reason": "test"}`
	kiemLoi(t, goi(r, "PUT", "/menu-items/abc/components/5", thanTP, nil), 400, "invalid_request", "menu_item_id")
	kiemLoi(t, goi(r, "PUT", "/menu-items/5/components/abc", thanTP, nil), 400, "invalid_request", "menu_component_id")
	kiemLoi(t, goi(r, "PUT", "/menu-items/5/components/6", thanTP, nil), 401, "unauthenticated", "")
}

// Dấu / cuối và phương thức lạ giữ hành vi của ServeMux hôm nay: không khớp mẫu ⇒ 404, khớp đường
// mà khác phương thức ⇒ 405 kèm Allow. Không chuyển hướng.
func TestQC12_RouterDauGachCuoiVaPhuongThuc(t *testing.T) {
	r := dungRouter(t)
	if w := goi(r, "POST", "/menu-items/5/discontinuation/", "", nil); w.Code != http.StatusNotFound {
		t.Fatalf("dấu / cuối: status=%d, muốn 404 — thân=%q", w.Code, w.Body.String())
	}
	if w := goi(r, "GET", "/menu/", "", nil); w.Code != http.StatusNotFound {
		t.Fatalf("GET /menu/: status=%d, muốn 404", w.Code)
	}
	if w := goi(r, "GET", "/khong-co-duong-nay", "", nil); w.Code != http.StatusNotFound {
		t.Fatalf("đường lạ: status=%d, muốn 404", w.Code)
	}
	w := goi(r, "GET", "/menu-items/5/discontinuation", "", nil)
	if w.Code != http.StatusMethodNotAllowed {
		t.Fatalf("GET lên đường chỉ POST: status=%d, muốn 405 — thân=%q", w.Code, w.Body.String())
	}
	if allow := w.Header().Get("Allow"); !strings.Contains(allow, "POST") {
		t.Fatalf("405 thiếu Allow chứa POST: %q", allow)
	}
}

// HEAD lên đường GET chạy như GET (ServeMux khớp HEAD với mẫu GET): cùng status, không thân.
func TestQC12_RouterHEADChayNhuGET(t *testing.T) {
	r := dungRouter(t)
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	get, err := http.Get(srv.URL + "/menu")
	if err != nil {
		t.Fatal(err)
	}
	get.Body.Close()
	head, err := http.Head(srv.URL + "/menu")
	if err != nil {
		t.Fatal(err)
	}
	head.Body.Close()
	if get.StatusCode != http.StatusOK || head.StatusCode != get.StatusCode {
		t.Fatalf("GET /menu=%d, HEAD /menu=%d; muốn cả hai 200", get.StatusCode, head.StatusCode)
	}
}

// Thứ tự từ chối theo hợp đồng hiện có (menu.go: hình yêu cầu kiểm trước quyền) và thân lỗi đúng
// hình {code, field?}: JSON hỏng ⇒ 400 không nêu trường, trước cả unauthenticated; header người sai
// hình ⇒ unauthenticated; người không tồn tại ⇒ unauthenticated (kiểm trong giao dịch của cửa).
func TestQC12_RouterThuTuTuChoiVaThanLoi(t *testing.T) {
	r := dungRouter(t)
	kiemLoi(t, goi(r, "PUT", "/menu-components/abc/base-price", "{", nil), 400, "invalid_request", "menu_component_id")
	kiemLoi(t, goi(r, "PUT", "/menu-components/5/base-price", "{", nil), 400, "invalid_request", "")
	than := `{"base_price_vnd": 1000, "reason": "test"}`
	kiemLoi(t, goi(r, "PUT", "/menu-components/5/base-price", than, map[string]string{authz.HeaderNguoi: "abc"}), 401, "unauthenticated", "")
	kiemLoi(t, goi(r, "PUT", "/menu-components/5/base-price", than, map[string]string{authz.HeaderNguoi: "999999999"}), 401, "unauthenticated", "")
}
