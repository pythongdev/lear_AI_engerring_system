package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
)

func TestI035_NguoiLamDinhDanhVaTaiQuay(t *testing.T) {
	f := rtSetup(t, time.Hour)
	const phone = "0912345678"
	email := "dinhdanh." + soKhach(t) + "@gmail.com"
	owner := &http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, f.ownerID)}
	st, b, _ := f.goiKhach("POST", "/accounts", map[string]any{"phone": phone, "email": email, "display_name": "Người làm ADR-131", "password": "mat-khau-moi"})
	if st != 201 {
		t.Fatalf("đăng ký: %d %v", st, b)
	}
	id := int64(b["account_id"].(float64))
	if st, b, _ = f.goiKhach("POST", fmt.Sprintf("/accounts/%d/approval", id), map[string]any{"role_code": "quay"}, owner); st != 200 {
		t.Fatalf("duyệt: %d %v", st, b)
	}
	for _, identifier := range []string{phone, "+84 912 345 678", strings.ToUpper(email)} {
		st, b, _ = f.goiKhach("POST", "/sessions", map[string]any{"identifier": identifier, "password": "mat-khau-moi", "tai_quay": true})
		if st != 201 || b["counter_duty_id"].(float64) <= 0 {
			t.Fatalf("đăng nhập trực quầy %s: %d %v", identifier, st, b)
		}
	}
	for _, in := range []map[string]any{{"username": "ten-cu", "password": "mat-khau-moi"}, {"identifier": "abc", "password": "mat-khau-moi"}} {
		if st, b, _ = f.goiKhach("POST", "/sessions", in); st != 400 || b["code"] != "identifier_invalid" {
			t.Fatalf("tên cũ/sai dạng: %d %v", st, b)
		}
	}
	for _, in := range []map[string]any{{"identifier": phone, "password": "sai"}, {"identifier": "khong-co." + email, "password": "sai"}} {
		if st, b, _ = f.goiKhach("POST", "/sessions", in); st != 401 || b["code"] != "login_failed" {
			t.Fatalf("không lộ tài khoản: %d %v", st, b)
		}
	}
	for _, tc := range []struct {
		body   map[string]any
		code   string
		status int
	}{
		{map[string]any{"display_name": "Trùng", "phone": "+84 912 345 678", "password": "mat-khau-moi"}, "phone_taken", 409},
		{map[string]any{"display_name": "Trùng", "email": strings.ToUpper(email), "password": "mat-khau-moi"}, "email_taken", 409},
		{map[string]any{"display_name": "Thiếu", "password": "mat-khau-moi"}, "contact_required", 400},
	} {
		if st, b, _ = f.goiKhach("POST", "/accounts", tc.body); st != tc.status || b["code"] != tc.code {
			t.Fatalf("%s: %d %v", tc.code, st, b)
		}
	}
	if st, b, _ = f.goiKhach("GET", "/accounts", nil, owner); st != 200 {
		t.Fatalf("danh sách: %d %v", st, b)
	}
	found := false
	for _, v := range b["accounts"].([]any) {
		a := v.(map[string]any)
		if int64(a["account_id"].(float64)) == id {
			found = true
			if a["phone"] != phone || a["email"] != email {
				t.Fatal(a)
			}
		}
	}
	if !found {
		t.Fatal("thiếu tài khoản trong danh sách")
	}
}

func TestI035_LichSuHaiKhachChiaTrang(t *testing.T) {
	f := rtSetup(t, time.Hour)
	a := &http.Cookie{Name: cookieKhach, Value: f.dangKyKhach(soKhach(t))}
	b := &http.Cookie{Name: cookieKhach, Value: f.dangKyKhach(soKhach(t))}
	first := f.donWeb(a)
	f.donWeb(b)
	last := f.donWeb(a)
	f.donWeb()
	firstID := f.id("SELECT id FROM shop.sales_order WHERE submission_code=$1", first)
	lastID := f.id("SELECT id FROM shop.sales_order WHERE submission_code=$1", last)
	st, out, _ := f.goiKhach("GET", "/customer-accounts/current/orders?limit=1", nil, a)
	if st != 200 {
		t.Fatalf("lịch sử: %d %v", st, out)
	}
	rows := out["orders"].([]any)
	if len(rows) != 1 || int64(rows[0].(map[string]any)["sales_order_id"].(float64)) != lastID || int64(out["next_before_id"].(float64)) != lastID {
		t.Fatal(out)
	}
	if len(rows[0].(map[string]any)["lines"].([]any)) != 1 || rows[0].(map[string]any)["total_vnd"].(float64) <= 0 {
		t.Fatal("thiếu dòng/tiền", out)
	}
	st, out, _ = f.goiKhach("GET", fmt.Sprintf("/customer-accounts/current/orders?before_id=%d&limit=1", lastID), nil, a)
	if st != 200 {
		t.Fatal(out)
	}
	rows = out["orders"].([]any)
	if len(rows) != 1 || int64(rows[0].(map[string]any)["sales_order_id"].(float64)) != firstID || out["next_before_id"] != nil {
		t.Fatal(out)
	}
	st, out, _ = f.goiKhach("GET", "/customer-accounts/current/orders", nil, b)
	if st != 200 || len(out["orders"].([]any)) != 1 || out["next_before_id"] != nil {
		t.Fatal(out)
	}
	for _, q := range []string{"limit=0", "limit=51", "limit=x", "limit=1.5", "limit=", "before_id=0", "before_id=-1", "before_id=x", "before_id="} {
		st, out, _ = f.goiKhach("GET", "/customer-accounts/current/orders?"+q, nil, a)
		if st != 400 || out["code"] != "invalid_request" || out["field"] != strings.Split(q, "=")[0] {
			t.Fatalf("query %s: %d %v", q, st, out)
		}
	}
}

func TestI035_KhachDangKyGiaoMatKhauVaOrigin(t *testing.T) {
	f := rtSetup(t, time.Hour)
	phone := soKhach(t)
	token := f.dangKyKhach(phone)
	c := &http.Cookie{Name: cookieKhach, Value: token}
	st, b, _ := f.goiKhach("POST", "/customer-accounts", map[string]any{"phone": phone, "display_name": "trùng", "password": "mat-khau-khach-1"})
	if st != 409 || b["code"] != "phone_taken" {
		t.Fatalf("trùng số: %d %v", st, b)
	}
	st, b, t2 := f.goiKhach("POST", "/customer-sessions", map[string]any{"identifier": "+84 " + phone[1:], "password": "mat-khau-khach-1"})
	if st != 201 || t2 == "" {
		t.Fatalf("đăng nhập: %d %v", st, b)
	}
	other := &http.Cookie{Name: cookieKhach, Value: t2}
	delivery := map[string]any{"delivery_name": "Tên nhận", "delivery_phone": "+84 912 345 678", "delivery_address": "Địa chỉ nhớ"}
	st, b, _ = f.goiKhach("PUT", "/customer-accounts/current/delivery-profile", delivery, c)
	if st != 200 {
		t.Fatalf("lưu giao: %d %v", st, b)
	}
	st, b, _ = f.goiKhach("GET", "/customer-sessions/current", nil, c)
	if st != 200 || b["phone"] != phone || b["email"] != nil || b["delivery_phone"] != "0912345678" {
		t.Fatal(b)
	}
	st, b, _ = f.goiKhach("PUT", "/customer-accounts/current/password", map[string]any{"current_password": "mat-khau-khach-1", "new_password": "mat-khau-khach-2"}, c)
	if st != 200 {
		t.Fatalf("đổi mật khẩu: %d %v", st, b)
	}
	if st, b, _ = f.goiKhach("GET", "/customer-sessions/current", nil, other); st != 401 {
		t.Fatalf("phiên khác còn sống: %d %v", st, b)
	}
	if st, b, _ = f.goiKhach("GET", "/customer-sessions/current", nil, c); st != 200 {
		t.Fatalf("phiên hiện tại bị khép: %d %v", st, b)
	}
	raw, _ := json.Marshal(delivery)
	req, _ := http.NewRequest("PUT", f.server.URL+"/customer-accounts/current/delivery-profile", bytes.NewReader(raw))
	req.Header.Set("Origin", "https://khac.test")
	req.AddCookie(c)
	res, e := http.DefaultClient.Do(req)
	if e != nil {
		t.Fatal(e)
	}
	res.Body.Close()
	if res.StatusCode != 403 {
		t.Fatalf("Origin khác: %d", res.StatusCode)
	}
	empty := map[string]any{"delivery_name": "", "delivery_phone": "", "delivery_address": ""}
	if st, b, _ = f.goiKhach("PUT", "/customer-accounts/current/delivery-profile", empty, c); st != 200 {
		t.Fatal(b)
	}
	st, b, _ = f.goiKhach("GET", "/customer-sessions/current", nil, c)
	if st != 200 || b["delivery_name"] != nil || b["delivery_phone"] != nil || b["delivery_address"] != nil {
		t.Fatal(b)
	}
	if st, b, _ = f.goiKhach("POST", "/customer-sessions/current/end", nil, c); st != 200 {
		t.Fatal(b)
	}
	if st, b, _ = f.goiKhach("GET", "/customer-sessions/current", nil, c); st != 401 {
		t.Fatal(b)
	}
}
