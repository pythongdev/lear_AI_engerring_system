// Test đỏ của bản Authenticator thật — chọn tên (T-143; U-075; ADR-085 Sửa đổi 2026-10-10). Claude viết
// trước; Codex làm cho xanh mà không sửa điều kiện kiểm nào.
package authz_test

import (
	"net/http/httptest"
	"testing"

	"banhcuon/be/internal/authz"
)

func TestI012_ChonTenDocNguoiTuHeader(t *testing.T) {
	var _ authz.Authenticator = authz.ChonTen{}
	ca := []struct {
		header string
		id     int64
		ok     bool
	}{
		{"", 0, false},
		{"abc", 0, false},
		{"0", 0, false},
		{"-7", 0, false},
		{" 7", 0, false},
		{"7.0", 0, false},
		{"7", 7, true},
		{"9223372036854775807", 9223372036854775807, true},
	}
	for _, c := range ca {
		r := httptest.NewRequest("GET", "/", nil)
		if c.header != "" {
			r.Header.Set(authz.HeaderNguoi, c.header)
		}
		id, ok := authz.ChonTen{}.PersonID(r)
		t.Logf("%s: %q ⇒ (%d, %t)", authz.HeaderNguoi, c.header, id, ok)
		if id != c.id || ok != c.ok {
			t.Fatalf("%q: muốn (%d, %t)", c.header, c.id, c.ok)
		}
	}
	if authz.HeaderNguoi != "X-Person-Id" {
		t.Fatalf("header của người đã chọn tên phải là X-Person-Id, nhận %q", authz.HeaderNguoi)
	}
}
