package tongquan

import (
	"context"
	_ "embed"
	"encoding/json"
	"os"
	"reflect"
	"testing"

	"github.com/jackc/pgx/v5"
)

// T-347 (Claude viết trước khi giao; Codex làm cho xanh, KHÔNG sửa file này hay testdata/bang_van_hanh_truoc_t347.sql).
// Viết lại sql/bang_van_hanh.sql để nhanh hơn không được đổi một byte kết quả: testdata/bang_van_hanh_truoc_t347.sql là bản
// câu đọc ở 2e0b751, đóng băng; test chạy bản ấy và file sql/ hiện hành trên cùng fixture, cùng giao dịch, rồi so JSON.
// Giao dịch giữ now() cố định nên read_at của hai bản trùng nhau.

//go:embed testdata/bang_van_hanh_truoc_t347.sql
var bangVanHanhTruocT347 string

func docTho(t *testing.T, ctx context.Context, tx pgx.Tx, cau, ngay string) any {
	t.Helper()
	var raw []byte
	if err := tx.QueryRow(ctx, cau, ngay).Scan(&raw); err != nil {
		t.Fatalf("ngày %s: %v", ngay, err)
	}
	var out any
	if err := json.Unmarshal(raw, &out); err != nil {
		t.Fatal(err)
	}
	return out
}

func TestI019_BangVanHanhKetQuaKhongDoiT347(t *testing.T) {
	ctx, tx, _, _, _, _ := bangFixture(t)
	// Lịch sử nhiều ngày: sao các vết made → served của fixture (kể cả của phiên S4 đã đóng) sang hai ngày khác,
	// sát ranh ngày, như TestI019_LichSuDemRaRanhNgayVet.
	if _, err := tx.Exec(ctx, `
INSERT INTO record_revision(target_table_code,target_row,before_image,after_image,reason,person_id,created_at)
SELECT r.target_table_code,r.target_row,r.before_image,r.after_image,'test-t347-history',r.person_id,m.moc
FROM record_revision r CROSS JOIN (VALUES
 (timestamptz '2187-06-01 23:59:59'), (timestamptz '2187-06-02 00:00:00')
) AS m(moc)
WHERE r.target_table_code='station_job' AND r.reason='test-t225-fixture'
  AND r.before_image->>'status'='made' AND r.after_image->>'status'='served';`); err != nil {
		t.Fatal(err)
	}
	moi, err := os.ReadFile("sql/bang_van_hanh.sql")
	if err != nil {
		t.Fatal(err)
	}
	var homNay string
	if err := tx.QueryRow(ctx, `SELECT now()::date::text`).Scan(&homNay); err != nil {
		t.Fatal(err)
	}
	for _, ngay := range []string{homNay, "2187-06-01", "2187-06-02", "2187-06-03", "2000-01-01"} {
		cu, sau := docTho(t, ctx, tx, bangVanHanhTruocT347, ngay), docTho(t, ctx, tx, string(moi), ngay)
		if !reflect.DeepEqual(cu, sau) {
			a, _ := json.MarshalIndent(cu, "", " ")
			b, _ := json.MarshalIndent(sau, "", " ")
			t.Fatalf("ngày %s: bảng vận hành đổi kết quả sau khi viết lại\n--- trước T-347\n%s\n--- hiện hành\n%s", ngay, a, b)
		}
	}
	// Bằng chứng fixture phủ đúng chỗ dễ sai: lịch sử của ngày hôm nay có mục từ phiên đã đóng (bàn E của S4).
	var coS4 bool
	if err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM jsonb_array_elements(($1::jsonb)->'serve_history') h
		WHERE h->>'table_label' = 'test-t225-E' AND (h->>'quantity')::int = 2)`, mustJSON(t, docTho(t, ctx, tx, string(moi), homNay))).Scan(&coS4); err != nil {
		t.Fatal(err)
	}
	if !coS4 {
		t.Fatal("fixture phải có mục lịch sử canh ×2 của phiên đã đóng trong ngày — nếu thiếu, test không phủ ca lọc theo phiên")
	}
}

func mustJSON(t *testing.T, v any) string {
	t.Helper()
	b, err := json.Marshal(v)
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}
