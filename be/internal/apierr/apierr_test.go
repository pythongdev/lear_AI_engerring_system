package apierr_test

import (
	"bufio"
	"context"
	"errors"
	"os"
	"regexp"
	"sort"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/dbtest"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// Hợp đồng nằm ngoài module; test chạy trong thư mục của gói (be/internal/apierr).
const contractPath = "../../../docs/product/3-be/openapi.yaml"

// F-058: lời từ chối của trigger tới pgx mang tên QC-10, và apierr dịch nó qua tên.
func TestQC10_LoiTuChoiTriggerMangTen(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	conn, err := pgx.Connect(ctx, dbtest.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(ctx)
	tx, err := conn.Begin(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(ctx)
	exec := func(sql string, args ...any) {
		t.Helper()
		if _, err := tx.Exec(ctx, sql, args...); err != nil {
			t.Fatalf("%s: %v", sql, err)
		}
	}
	var person int64
	if err := tx.QueryRow(ctx, "INSERT INTO shop.person (display_name) VALUES ('Người thử') RETURNING id").Scan(&person); err != nil {
		t.Fatal(err)
	}
	exec("SELECT set_config('shop.actor_person_id', $1::bigint::text, true)", person)
	// Ngày đã ký: tiền đầu két và số đếm đều có dòng mệnh giá, rồi dấu đối soát xong.
	exec("INSERT INTO shop.opening_float (sale_date) VALUES ('2026-01-01')")
	exec("INSERT INTO shop.opening_float_line (opening_float_id, denomination_vnd, amount_vnd) SELECT id, 10000, 50000 FROM shop.opening_float WHERE sale_date = '2026-01-01'")
	exec("INSERT INTO shop.cash_count (sale_date) VALUES ('2026-01-01')")
	exec("INSERT INTO shop.cash_count_line (cash_count_id, denomination_vnd, amount_vnd) SELECT id, 10000, 50000 FROM shop.cash_count WHERE sale_date = '2026-01-01'")
	exec("INSERT INTO shop.reconciled_day (sale_date) VALUES ('2026-01-01')")
	// Ngày chưa ký mà số đếm không có dòng mệnh giá.
	exec("INSERT INTO shop.opening_float (sale_date) VALUES ('2026-01-02')")
	exec("INSERT INTO shop.opening_float_line (opening_float_id, denomination_vnd, amount_vnd) SELECT id, 10000, 50000 FROM shop.opening_float WHERE sale_date = '2026-01-02'")
	exec("INSERT INTO shop.cash_count (sale_date) VALUES ('2026-01-02')")

	cases := []struct {
		name, sql, sqlstate, constraint string
		code                            apierr.Code
	}{
		{"ghi_so_ngay_da_ky",
			"INSERT INTO shop.cash_count_line (cash_count_id, denomination_vnd, amount_vnd) SELECT id, 20000, 20000 FROM shop.cash_count WHERE sale_date = '2026-01-01'",
			"23001", "cash_count_line_reconciled_day_locked_check", apierr.CodeSaleDayReconciled},
		{"dau_tren_so_dem_rong",
			"INSERT INTO shop.reconciled_day (sale_date) VALUES ('2026-01-02')",
			"23514", "reconciled_day_cash_count_has_lines_check", apierr.CodeCashDayIncomplete},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			exec("SAVEPOINT thu")
			defer exec("ROLLBACK TO SAVEPOINT thu")
			_, err := tx.Exec(ctx, c.sql)
			var pg *pgconn.PgError
			if !errors.As(err, &pg) {
				t.Fatalf("database không từ chối: %v", err)
			}
			t.Logf("lời từ chối nguyên văn: %s (SQLSTATE %s, constraint %q)", pg.Message, pg.Code, pg.ConstraintName)
			if pg.Code != c.sqlstate || pg.ConstraintName != c.constraint {
				t.Fatalf("mong SQLSTATE %s + %q, nhận %s + %q", c.sqlstate, c.constraint, pg.Code, pg.ConstraintName)
			}
			got, name := apierr.FromDB(err)
			if got.Code != c.code || name != c.constraint {
				t.Fatalf("FromDB: mong %s + %q (ADR-089), nhận %+v + %q", c.code, c.constraint, got, name)
			}
		})
	}
}

// Mọi tên database có thể trả về trong lời từ chối có đúng một dòng ở x-constraint-errors — đọc từ
// database sống, nên bắt cả tên Gate 1g không đọc được từ file (ràng buộc đặt tên ngầm).
func TestQC10_MoiTenTuChoiCoDongTrongHopDong(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	conn, err := pgx.Connect(ctx, dbtest.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(ctx)
	rows, err := conn.Query(ctx, `
		SELECT c.conname FROM pg_constraint c
		JOIN pg_namespace n ON n.oid = c.connamespace
		WHERE n.nspname = 'shop' AND c.contype IN ('p', 'u', 'f', 'c', 'x')
		UNION
		SELECT i.relname FROM pg_index x
		JOIN pg_class i ON i.oid = x.indexrelid
		JOIN pg_namespace n ON n.oid = i.relnamespace
		WHERE n.nspname = 'shop' AND x.indisunique
		  AND NOT EXISTS (SELECT 1 FROM pg_constraint c
		                  WHERE c.conindid = x.indexrelid AND c.contype IN ('p', 'u', 'x'))
		UNION
		SELECT m[1] FROM pg_proc p
		JOIN pg_namespace n ON n.oid = p.pronamespace
		CROSS JOIN LATERAL regexp_matches(p.prosrc, 'CONSTRAINT\s*=\s*''([^'']+)''', 'gi') AS m
		WHERE n.nspname = 'shop'`)
	if err != nil {
		t.Fatal(err)
	}
	live, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		t.Fatal(err)
	}
	inContract := contractRows(t)
	var onlyDB, onlyContract []string
	seen := map[string]bool{}
	for _, n := range live {
		seen[n] = true
		if !inContract[n] {
			onlyDB = append(onlyDB, n)
		}
	}
	for n := range inContract {
		if !seen[n] {
			onlyContract = append(onlyContract, n)
		}
	}
	sort.Strings(onlyDB)
	sort.Strings(onlyContract)
	t.Logf("database sống: %d tên; x-constraint-errors: %d dòng", len(live), len(inContract))
	if len(onlyDB) > 0 || len(onlyContract) > 0 {
		t.Fatalf("lệch — chỉ ở database: %v; chỉ ở hợp đồng: %v", onlyDB, onlyContract)
	}
}

func contractRows(t *testing.T) map[string]bool {
	t.Helper()
	f, err := os.Open(contractPath)
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	row := regexp.MustCompile(`^  ([a-z0-9_]+):`)
	out := map[string]bool{}
	in := false
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		line := sc.Text()
		switch {
		case line == "x-constraint-errors:":
			in = true
		case in && regexp.MustCompile(`^\S`).MatchString(line) && line[0] != '#':
			in = false
		case in:
			if m := row.FindStringSubmatch(line); m != nil {
				out[m[1]] = true
			}
		}
	}
	if err := sc.Err(); err != nil {
		t.Fatal(err)
	}
	if len(out) == 0 {
		t.Fatalf("không đọc được dòng nào của x-constraint-errors ở %s", contractPath)
	}
	return out
}
