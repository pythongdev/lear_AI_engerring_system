package tongket

import (
	"context"
	_ "embed"
	"encoding/json"
	"os"
	"reflect"
	"regexp"
	"sort"
	"testing"
	"time"
)

// T-347 (Claude viết trước khi giao; Codex làm cho xanh, KHÔNG sửa file này hay testdata/doc_truoc_t347.sql).
// Viết lại sql/doc.sql để nhanh hơn không được đổi một byte kết quả: testdata/doc_truoc_t347.sql là bản câu đọc ở 2e0b751,
// đóng băng; test chạy bản ấy và file sql/ hiện hành trên cùng fixture, cùng giao dịch, ở mọi ngày fixture nhắc tới
// cộng ngày trước và sau (ranh ngày của doanh thu, đơn quầy, huỷ, hoàn), rồi so JSON.

//go:embed testdata/doc_truoc_t347.sql
var docTruocT347 string

var ngayTrongFixture = regexp.MustCompile(`21[0-9]{2}-[0-9]{2}-[0-9]{2}`)

func TestI014_TongKetKetQuaKhongDoiT347(t *testing.T) {
	moi, err := os.ReadFile("sql/doc.sql")
	if err != nil {
		t.Fatal(err)
	}
	// best_staff.sql chạy sau summary.sql như các test có sẵn (nó dùng người do fixture đầu dựng).
	for _, fx := range []struct {
		ten  string
		sqls []string
	}{{"summary.sql", []string{revenueFixture}}, {"summary.sql+best_staff.sql", []string{revenueFixture, bestStaffFixture}}} {
		t.Run(fx.ten, func(t *testing.T) {
			ctx := context.Background()
			tx := fixtureTx(t)
			ngay := map[string]bool{}
			for _, sql := range fx.sqls {
				runFixture(t, tx, sql)
				for _, d := range ngayTrongFixture.FindAllString(sql, -1) {
					ngay[d] = true
				}
			}
			for _, d := range keys(ngay) {
				moc, err := time.Parse("2006-01-02", d)
				if err != nil {
					t.Fatal(err)
				}
				for _, lech := range []int{-1, 0, 1} {
					ngay[moc.AddDate(0, 0, lech).Format("2006-01-02")] = true
				}
			}
			if len(ngay) == 0 {
				t.Fatal("fixture không nhắc ngày nào — test không phủ gì")
			}
			cacNgay := make([]string, 0, len(ngay))
			for d := range ngay {
				cacNgay = append(cacNgay, d)
			}
			sort.Strings(cacNgay)
			coDuLieu := 0
			for _, d := range cacNgay {
				var rawCu, rawMoi []byte
				if err := tx.QueryRow(ctx, docTruocT347, d).Scan(&rawCu); err != nil {
					t.Fatalf("trước T-347, ngày %s: %v", d, err)
				}
				if err := tx.QueryRow(ctx, string(moi), d).Scan(&rawMoi); err != nil {
					t.Fatalf("hiện hành, ngày %s: %v", d, err)
				}
				var cu, sau map[string]any
				if err := json.Unmarshal(rawCu, &cu); err != nil {
					t.Fatal(err)
				}
				if err := json.Unmarshal(rawMoi, &sau); err != nil {
					t.Fatal(err)
				}
				if !reflect.DeepEqual(cu, sau) {
					t.Fatalf("ngày %s: tổng kết đổi kết quả sau khi viết lại\n--- trước T-347\n%s\n--- hiện hành\n%s", d, rawCu, rawMoi)
				}
				if s, ok := cu["staff"].([]any); ok && len(s) > 0 {
					coDuLieu++
				} else if b, ok := cu["best_sellers"].(map[string]any); ok && len(b["items"].([]any))+len(b["combos"].([]any)) > 0 {
					coDuLieu++
				}
			}
			if coDuLieu == 0 {
				t.Fatalf("%s: không ngày nào có món bán chạy hay nhân viên — test không phủ phép nối hoá đơn với đơn", fx.ten)
			}
		})
	}
}

func keys(m map[string]bool) []string {
	out := make([]string, 0, len(m))
	for k := range m {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}
