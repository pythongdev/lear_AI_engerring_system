// T-312 (ADR-141, Claude viết TRƯỚC code, 2026-11-09): cờ BANHCUON_DEV_BO_GIO_BAN chỉ bật được trên máy dev.
// docBoGioBan đọc cờ lúc khởi động; main dừng hẳn (log.Fatal) khi nó trả lỗi. Codex không sửa điều kiện kiểm nào.
package main

import "testing"

func TestI008_CoBoGioBanChiBatTrenMayDev(t *testing.T) {
	for _, ca := range []struct {
		co, origin string
		bat, loi   bool
	}{
		{"", "http://localhost:3000", false, false},
		{"", "https://banhcuonbathanh.vn", false, false},
		{"0", "https://banhcuonbathanh.vn", false, false},
		{"1", "http://localhost:3000", true, false},
		{"1", "http://127.0.0.1:3000", true, false},
		{"1", "https://banhcuonbathanh.vn", false, true},
		{"1", "http://localhost.banhcuonbathanh.vn", false, true},
		{"1", "", false, true},
		{"true", "http://localhost:3000", false, true},
		{" 1", "http://localhost:3000", false, true},
	} {
		env := map[string]string{"BANHCUON_DEV_BO_GIO_BAN": ca.co, "BANHCUON_ORIGIN": ca.origin}
		bat, err := docBoGioBan(func(k string) string { return env[k] })
		if (err != nil) != ca.loi || bat != ca.bat {
			t.Fatalf("cờ %q, origin %q ⇒ bật=%v lỗi=%v; cần bật=%v lỗi=%v", ca.co, ca.origin, bat, err, ca.bat, ca.loi)
		}
	}
}
