package combo_test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/combo"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

func TestQC14_HinhCapNhatAnhCombo(t *testing.T) {
	r := gin.New()
	combo.Routes(r, combo.NewService(nil))
	for _, tc := range []struct {
		name, path, reason, file, want, code string
		status                               int
	}{
		{"mã sai", "/menu-combos/0/image", "sửa ảnh", "abc", "menu_combo_id", "invalid_request", 400},
		{"thiếu lý do", "/menu-combos/1/image", "", "abc", "reason", "invalid_request", 400},
		{"thiếu tệp", "/menu-combos/1/image", "sửa ảnh", "", "file", "invalid_request", 400},
		{"nội dung sai dù tên png", "/menu-combos/1/image", "sửa ảnh", "abc", "file", "invalid_request", 400},
		{"svg giả png", "/menu-combos/1/image", "sửa ảnh", "<svg></svg>", "file", "invalid_request", 400},
		{"hơn 5 MiB", "/menu-combos/1/image", "sửa ảnh", strings.Repeat("x", (5<<20)+1), "", "file_too_large", 413},
	} {
		t.Run(tc.name, func(t *testing.T) {
			var body bytes.Buffer
			form := multipart.NewWriter(&body)
			form.WriteField("reason", tc.reason)
			if tc.file != "" {
				f, _ := form.CreateFormFile("file", "anh.png")
				f.Write([]byte(tc.file))
			}
			form.Close()
			req := httptest.NewRequest("PUT", tc.path, &body)
			req.Header.Set("Content-Type", form.FormDataContentType())
			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)
			var out struct{ Code, Field string }
			_ = json.Unmarshal(w.Body.Bytes(), &out)
			if w.Code != tc.status || out.Code != tc.code || out.Field != tc.want {
				t.Fatalf("muốn %d %s field=%s, nhận %d %s", tc.status, tc.code, tc.want, w.Code, w.Body.String())
			}
		})
	}
}

func TestI018_AnhComboCoQuyenCoVetVaDocCongKhai(t *testing.T) {
	k := dung(t)
	chu := k.chu
	thuong := k.quay
	mon := k.mon(t, "test-món ảnh")
	tp := k.so(t, "INSERT INTO shop.menu_component (name, base_price_vnd, takes_filling) VALUES ($1, 10000, false) RETURNING id", "test-thành phần ảnh · "+t.Name())
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, "INSERT INTO shop.menu_item_component (menu_item_id, menu_component_id, quantity) VALUES ($1,$2,1)", mon, tp)
		return err
	}); err != nil {
		t.Fatal(err)
	}
	id := k.lap(t, "test-combo ảnh · "+t.Name(), 45000, phan{mon, 1})
	kho := t.TempDir()
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	combo.Routes(r, combo.NewService(pool).WithFileDir(kho))
	gia.Routes(r, gia.NewService(pool))
	srv := httptest.NewServer(r)
	defer srv.Close()

	upload := func(actor int64, data []byte, reason string) (int, map[string]any) {
		t.Helper()
		var body bytes.Buffer
		form := multipart.NewWriter(&body)
		form.WriteField("reason", reason)
		f, _ := form.CreateFormFile("file", "anh.png")
		f.Write(data)
		form.Close()
		req, _ := http.NewRequestWithContext(k.ctx, "PUT", fmt.Sprintf("%s/menu-combos/%d/image", srv.URL, id), &body)
		req.Header.Set("Content-Type", form.FormDataContentType())
		if actor != 0 {
			req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, actor)})
		}
		res, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		defer res.Body.Close()
		var out map[string]any
		_ = json.NewDecoder(res.Body).Decode(&out)
		return res.StatusCode, out
	}
	read := func() (int, []byte, http.Header) {
		t.Helper()
		res, err := http.Get(fmt.Sprintf("%s/menu-combos/%d/image", srv.URL, id))
		if err != nil {
			t.Fatal(err)
		}
		defer res.Body.Close()
		data, _ := io.ReadAll(res.Body)
		return res.StatusCode, data, res.Header
	}
	if status, raw, _ := read(); status != 404 || !strings.Contains(string(raw), "menu_combo_image_missing") {
		t.Fatalf("món chưa có ảnh: %d %s", status, raw)
	}
	png := []byte("\x89PNG\r\n\x1a\nfirst")
	k.datGio(t, k.mo+time.Hour) // Đổi ảnh được cả trong giờ bán.
	if status, out := upload(chu, png, "ảnh mới"); status != 200 || out["menu_combo_id"] != float64(id) || out["image_url"] != fmt.Sprintf("/menu-combos/%d/image", id) {
		t.Fatalf("lưu ảnh: %d %v", status, out)
	}
	if status, raw, headers := read(); status != 200 || !bytes.Equal(raw, png) || headers.Get("Content-Type") != "image/png" || headers.Get("Cache-Control") != "no-store" {
		t.Fatalf("đọc công khai: %d %q %v", status, raw, headers)
	}
	if status, out := upload(0, png, "ảnh mới"); status != 401 || out["code"] != "unauthenticated" {
		t.Fatalf("không phiên: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("không phiên làm đổi ảnh: %d %q", status, raw)
	}
	if status, out := upload(thuong, png, "ảnh mới"); status != 403 || out["code"] != "owner_only" {
		t.Fatalf("không phải chủ: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("không phải chủ làm đổi ảnh: %d %q", status, raw)
	}
	if status, out := upload(chu, []byte("not an image"), "ảnh mới"); status != 400 || out["field"] != "file" {
		t.Fatalf("sai loại: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("sai loại làm đổi ảnh: %d %q", status, raw)
	}
	if status, out := upload(chu, bytes.Repeat([]byte("x"), (5<<20)+1), "ảnh mới"); status != 413 || out["code"] != "file_too_large" {
		t.Fatalf("quá cỡ: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("quá cỡ làm đổi ảnh: %d %q", status, raw)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("từ chối phải giữ ảnh cũ: %d %q", status, raw)
	}
	// Cả chủ quán và thực đơn khách đọc đường ảnh từ backend.
	doc := k.goi(t, "GET", "/menu-combos", chu, nil)
	canDat(t, doc, http.StatusOK)
	for _, path := range []string{"/menu-combos", "/menu"} {
		if path == "/menu" {
			response, err := http.Get(srv.URL + path)
			if err != nil {
				t.Fatal(err)
			}
			if err := json.NewDecoder(response.Body).Decode(&doc.body); err != nil {
				t.Fatal(err)
			}
			response.Body.Close()
			if response.StatusCode != http.StatusOK {
				t.Fatalf("menu: %v", doc.body)
			}
		}
		found := false
		for _, raw := range doc.body["combos"].([]any) {
			row := raw.(map[string]any)
			if row["menu_combo_id"] == float64(id) {
				found = true
				if row["image_url"] != fmt.Sprintf("/menu-combos/%d/image", id) {
					t.Fatalf("%s thiếu đường ảnh: %v", path, row)
				}
			}
		}
		if !found {
			t.Fatalf("%s thiếu combo ảnh", path)
		}
	}
	var code string
	if err := k.owner.QueryRow(k.ctx, "SELECT image_code FROM shop.menu_combo WHERE id=$1", id).Scan(&code); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(kho + "/" + code); err != nil {
		t.Fatal(err)
	}
	var count int
	if err := k.owner.QueryRow(k.ctx, "SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_combo' AND target_row=$1 AND reason='ảnh mới' AND person_id=$2", id, chu).Scan(&count); err != nil || count != 1 {
		t.Fatalf("vết ảnh: %d %v", count, err)
	}
	if status, out := upload(chu, []byte("bad"), "không đổi"); status != 400 || out["field"] != "file" {
		t.Fatalf("tệp sai sau khi có ảnh: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("ảnh trước phải giữ: %d %q", status, raw)
	}
	// Combo đã ẩn: lưu ảnh bị từ chối, GET vẫn giữ ảnh hiện hành.
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/menu-combos/%d/hiding", id), chu, map[string]any{"reason": "ẩn combo ảnh"}), http.StatusOK)
	if status, out := upload(chu, []byte("\x89PNG\r\n\x1a\nnew"), "ảnh sau ẩn"); status != 409 || out["code"] != "menu_combo_hidden" {
		t.Fatalf("combo ẩn: %d %v", status, out)
	}
	if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
		t.Fatalf("combo ẩn phải giữ ảnh: %d %q", status, raw)
	}
}
