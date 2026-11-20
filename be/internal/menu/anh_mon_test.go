package menu_test

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

	"banhcuon/be/internal/menu"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
)

func TestQC14_HinhCapNhatAnhMon(t *testing.T) {
	r := gin.New()
	menu.Routes(r, menu.NewService(nil))
	for _, tc := range []struct{ path, reason, file, want string }{
		{"/menu-items/0/image", "sửa ảnh", "abc", "menu_item_id"},
		{"/menu-items/1/image", "", "abc", "reason"},
		{"/menu-items/1/image", "sửa ảnh", "", "file"},
		{"/menu-items/1/image", "sửa ảnh", "abc", "file"},
	} {
		t.Run(tc.want+tc.file, func(t *testing.T) {
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
			if w.Code != 400 || out.Code != "invalid_request" || out.Field != tc.want {
				t.Fatalf("muốn invalid_request field=%s, nhận %d %s", tc.want, w.Code, w.Body.String())
			}
		})
	}
}

func TestI018_AnhMonCoQuyenCoVetVaDocCongKhai(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ ảnh", true)
	thuong := k.nguoi(t, "nhân viên ảnh", false)
	m := k.menuGia(t)
	kho := t.TempDir()
	pool, err := postgres.Open(k.ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	menu.Routes(r, menu.NewService(pool).WithFileDir(kho))
	srv := httptest.NewServer(r)
	defer srv.Close()

	uploadAt := func(itemID, actor int64, data []byte, reason string) (int, map[string]any) {
		t.Helper()
		var body bytes.Buffer
		form := multipart.NewWriter(&body)
		form.WriteField("reason", reason)
		f, _ := form.CreateFormFile("file", "anh.png")
		f.Write(data)
		form.Close()
		req, _ := http.NewRequestWithContext(k.ctx, "PUT", fmt.Sprintf("%s/menu-items/%d/image", srv.URL, itemID), &body)
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
	upload := func(actor int64, data []byte, reason string) (int, map[string]any) {
		return uploadAt(m.mon, actor, data, reason)
	}
	read := func() (int, []byte, http.Header) {
		t.Helper()
		res, err := http.Get(fmt.Sprintf("%s/menu-items/%d/image", srv.URL, m.mon))
		if err != nil {
			t.Fatal(err)
		}
		defer res.Body.Close()
		data, _ := io.ReadAll(res.Body)
		return res.StatusCode, data, res.Header
	}
	if status, raw, _ := read(); status != 404 || !strings.Contains(string(raw), "menu_item_image_missing") {
		t.Fatalf("món chưa có ảnh: %d %s", status, raw)
	}
	if res, err := http.Get(fmt.Sprintf("%s/menu-items/%d/image", srv.URL, int64(900000000000))); err != nil {
		t.Fatal(err)
	} else {
		defer res.Body.Close()
		if res.StatusCode != 404 {
			t.Fatalf("món không có, GET: %d", res.StatusCode)
		}
	}
	png := []byte("\x89PNG\r\n\x1a\nfirst")
	if status, out := upload(0, png, "ảnh mới"); status != 401 || out["code"] != "unauthenticated" {
		t.Fatalf("không phiên: %d %v", status, out)
	}
	if status, out := upload(thuong, png, "ảnh mới"); status != 403 || out["code"] != "owner_only" {
		t.Fatalf("không phải chủ: %d %v", status, out)
	}
	if status, out := upload(chu, []byte("not an image"), "ảnh mới"); status != 400 || out["field"] != "file" {
		t.Fatalf("sai loại: %d %v", status, out)
	}
	if status, out := upload(chu, bytes.Repeat([]byte("x"), (5<<20)+1), "ảnh mới"); status != 413 || out["code"] != "file_too_large" {
		t.Fatalf("quá cỡ: %d %v", status, out)
	}
	if status, out := upload(chu, png, "ảnh mới"); status != 200 || out["menu_item_id"] != float64(m.mon) {
		t.Fatalf("lưu ảnh: %d %v", status, out)
	}
	if status, raw, headers := read(); status != 200 || !bytes.Equal(raw, png) || headers.Get("Content-Type") != "image/png" || headers.Get("Cache-Control") != "no-store" {
		t.Fatalf("đọc công khai: %d %q %v", status, raw, headers)
	}
	var code string
	if err := k.owner.QueryRow(k.ctx, "SELECT image_code FROM shop.menu_item WHERE id=$1", m.mon).Scan(&code); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(kho + "/" + code); err != nil {
		t.Fatal(err)
	}
	var count int
	if err := k.owner.QueryRow(k.ctx, "SELECT count(*) FROM shop.record_revision WHERE target_table_code='menu_item' AND target_row=$1 AND reason='ảnh mới' AND person_id=$2", m.mon, chu).Scan(&count); err != nil || count != 1 {
		t.Fatalf("vết ảnh: %d %v", count, err)
	}
	if status, out := upload(chu, []byte("bad"), "không đổi"); status != 400 || out["field"] != "file" {
		t.Fatalf("tệp sai sau khi có ảnh: %d %v", status, out)
	}
	for _, tc := range []struct {
		name      string
		id, actor int64
		data      []byte
		reason    string
		status    int
		code      string
	}{
		{"khong_phai_chu", m.mon, thuong, png, "đổi ảnh", 403, "owner_only"},
		{"sai_loai_noi_dung", m.mon, chu, []byte("not image"), "đổi ảnh", 400, "invalid_request"},
		{"qua_5_MiB", m.mon, chu, bytes.Repeat([]byte("x"), (5<<20)+1), "đổi ảnh", 413, "file_too_large"},
		{"thieu_ly_do", m.mon, chu, png, "", 400, "invalid_request"},
		{"mon_khong_co", 900000000000, chu, png, "đổi ảnh", 404, "menu_item_not_found"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			status, out := uploadAt(tc.id, tc.actor, tc.data, tc.reason)
			if status != tc.status || out["code"] != tc.code {
				t.Fatalf("từ chối: %d %v", status, out)
			}
			var now string
			if err := k.owner.QueryRow(k.ctx, "SELECT image_code FROM shop.menu_item WHERE id=$1", m.mon).Scan(&now); err != nil || now != code {
				t.Fatalf("khoá ảnh cũ đổi: %q %v", now, err)
			}
			if status, raw, _ := read(); status != 200 || !bytes.Equal(raw, png) {
				t.Fatalf("byte ảnh cũ đổi: %d %q", status, raw)
			}
		})
	}
}
