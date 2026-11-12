package testhelper_test

import (
	"context"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"banhcuon/be/internal/testhelper"
)

// databaseMau là database mà scripts/be-check.sh migrate từ số 0. Từ T-323 lát 2
// (docs/decisions.md ADR-144) không gói test nào chạy thẳng trên nó: mỗi gói nhận một
// bản sao riêng, để dữ liệu một gói để lại không làm đỏ gói khác (work/findings.md
// F-072, F-078 — đo 2026-11-12: một ca quầy mở ở tương lai làm đỏ thêm tám gói).
const databaseMau = "banhcuon"

func tenDatabase(t *testing.T, dsn string) string {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	conn, err := pgx.Connect(ctx, dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())
	var ten string
	if err := conn.QueryRow(ctx, "SELECT current_database()").Scan(&ten); err != nil {
		t.Fatal(err)
	}
	return ten
}

func TestQC16_GoiTestChayTrenDatabaseRiengKhongPhaiDatabaseMau(t *testing.T) {
	app := tenDatabase(t, testhelper.AppDSN(t))
	chu := tenDatabase(t, testhelper.OwnerDSN(t))
	if app != chu {
		t.Fatalf("hai chuỗi kết nối của một gói trỏ hai database khác nhau: app=%q, chủ=%q", app, chu)
	}
	if app == databaseMau {
		t.Fatalf("gói test đang chạy thẳng trên database mẫu %q; scripts/be-check.sh phải cấp cho mỗi gói một bản sao riêng (QC-16, ADR-144)", databaseMau)
	}
}
