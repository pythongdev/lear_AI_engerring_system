// Package testhelper đọc cấu hình database riêng do bộ kiểm dựng.
package testhelper

import (
	"os"
	"testing"
)

func env(t testing.TB, name string) string {
	t.Helper()
	value := os.Getenv(name)
	if value == "" {
		t.Fatalf("thiếu %s: chạy qua ./scripts/be-check.sh (QC-16)", name)
	}
	return value
}

func AppDSN(t testing.TB) string   { t.Helper(); return env(t, "BANHCUON_TEST_APP_DSN") }
func OwnerDSN(t testing.TB) string { t.Helper(); return env(t, "BANHCUON_TEST_OWNER_DSN") }
func ShopTZ(t testing.TB) string   { t.Helper(); return env(t, "BANHCUON_SHOP_TZ") }
