package db_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"banhcuon/be/internal/db"
	"banhcuon/be/internal/dbtest"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

func TestQC15_KetNoiBackend(t *testing.T) {
	appDSN, ownerDSN, shopTZ := dbtest.AppDSN(t), dbtest.OwnerDSN(t), dbtest.ShopTZ(t)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	t.Run("vai_va_mui_gio", func(t *testing.T) {
		pool, err := db.Open(ctx, appDSN, shopTZ)
		if err != nil {
			t.Fatal(err)
		}
		defer pool.Close()
		var role, tz, defaultTZ string
		var super bool
		if err := pool.QueryRow(ctx, "SELECT current_user, rolsuper FROM pg_roles WHERE rolname = current_user").Scan(&role, &super); err != nil {
			t.Fatal(err)
		}
		if role != "shop_app" || super {
			t.Fatalf("vai=%s, superuser=%t", role, super)
		}
		if err := pool.QueryRow(ctx, "SHOW TimeZone").Scan(&tz); err != nil {
			t.Fatal(err)
		}
		owner, err := pgx.Connect(ctx, ownerDSN)
		if err != nil {
			t.Fatal(err)
		}
		defer owner.Close(ctx)
		if err := owner.QueryRow(ctx, "SHOW TimeZone").Scan(&defaultTZ); err != nil {
			t.Fatal(err)
		}
		t.Logf("vai=%s, superuser=%t; múi giờ quán=%s; backend=%s; kết nối không đặt=%s", role, super, shopTZ, tz, defaultTZ)
		if tz != shopTZ {
			t.Fatalf("backend=%q, quán=%q", tz, shopTZ)
		}
		if defaultTZ != "UTC" && defaultTZ != "Etc/UTC" {
			t.Fatalf("kết nối không đặt múi giờ nhận %q", defaultTZ)
		}
	})
	t.Run("tu_choi_owner", func(t *testing.T) {
		pool, err := db.Open(ctx, ownerDSN, shopTZ)
		if pool != nil {
			pool.Close()
		}
		if err == nil {
			t.Fatal("Open không từ chối shop_owner")
		}
	})
	t.Run("tu_choi_mui_gio_rong", func(t *testing.T) {
		pool, err := db.Open(ctx, "DSN không hợp lệ để chứng minh kiểm trước kết nối", "")
		if pool != nil {
			pool.Close()
		}
		if err == nil || err.Error() != "múi giờ quán không được rỗng" {
			t.Fatalf("Open nhận múi giờ rỗng: %v", err)
		}
	})
}

func TestQC03_ShopAppKhongXoaDuoc(t *testing.T) {
	appDSN, ownerDSN, shopTZ := dbtest.AppDSN(t), dbtest.OwnerDSN(t), dbtest.ShopTZ(t)
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	owner, err := pgx.Connect(ctx, ownerDSN)
	if err != nil {
		t.Fatal(err)
	}
	defer owner.Close(ctx)
	var table string
	if err := owner.QueryRow(ctx, "SELECT tablename FROM pg_tables WHERE schemaname = 'shop' ORDER BY tablename LIMIT 1").Scan(&table); err != nil {
		t.Fatal(err)
	}
	target := pgx.Identifier{"shop", table}.Sanitize()
	count := func() int64 {
		t.Helper()
		var n int64
		if err := owner.QueryRow(ctx, "SELECT count(*) FROM "+target).Scan(&n); err != nil {
			t.Fatal(err)
		}
		return n
	}
	before := count()
	pool, err := db.Open(ctx, appDSN, shopTZ)
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	_, err = pool.Exec(ctx, "DELETE FROM "+target)
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) || pgErr.Code != "42501" {
		t.Fatalf("muốn SQLSTATE 42501, nhận %v", err)
	}
	t.Logf("%s", pgErr)
	if after := count(); after != before {
		t.Fatalf("số dòng đổi: trước=%d, sau=%d", before, after)
	}
}
