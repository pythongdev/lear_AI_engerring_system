// I-019 tầng 3 (ADR-090 điểm 8): bảng nhu cầu, ứng viên chuyển và cửa đã ra bàn đọc khoá gom từ MỘT
// định nghĩa. sqlc không ghép đoạn câu giữa hai file, nên đoạn ấy nằm ở gom.sql và chon_da_lam.sql
// giữa hai dòng đánh dấu (T-163); test này giữ hai bản giống từng byte. Không cần database.
package sanxuat

import (
	"os"
	"strings"
	"testing"
)

func doanKhoaGom(t *testing.T, file string) string {
	t.Helper()
	b, err := os.ReadFile(file)
	if err != nil {
		t.Fatal(err)
	}
	s := string(b)
	const dau, cuoi = " -- khoá gom: đầu\n", " -- khoá gom: cuối\n"
	if strings.Count(s, dau) != 1 || strings.Count(s, cuoi) != 1 {
		t.Fatalf("%s: phải có đúng một dòng %q và một dòng %q", file, strings.TrimSpace(dau), strings.TrimSpace(cuoi))
	}
	i, j := strings.Index(s, dau), strings.Index(s, cuoi)
	if j < i {
		t.Fatalf("%s: dòng cuối đứng trước dòng đầu", file)
	}
	return s[i:j]
}

func TestI019_KhoaGomMotDinhNghia(t *testing.T) {
	gom, ra := doanKhoaGom(t, "sql/gom.sql"), doanKhoaGom(t, "sql/chon_da_lam.sql")
	if gom != ra {
		t.Fatalf("khoá gom lệch giữa sql/gom.sql và sql/chon_da_lam.sql (I-019 tầng 3: một định nghĩa):\n--- gom.sql\n%s\n--- chon_da_lam.sql\n%s", gom, ra)
	}
	for _, phan := range []string{"j.station_code", "c.menu_component_id", "filling_option_ids", "c.takes_filling"} {
		if !strings.Contains(gom, phan) {
			t.Fatalf("đoạn khoá gom thiếu %s — trạm + thành phần gốc + tập tuỳ chọn khi nhận nhân", phan)
		}
	}
}
