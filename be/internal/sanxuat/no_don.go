// Package sanxuat giữ các cửa sản xuất của quầy; trạm bếp chỉ đọc.
package sanxuat

import (
	"context"
	_ "embed"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var CuaNoDon = authz.Door{Code: "sanxuat/no_don", Need: authz.NeedCallingDoor}

//go:embed sql/no_don/thanh_phan.sql
var noThanhPhan string

//go:embed sql/no_don/nuoc_cham.sql
var noNuocCham string

// NoDon chạy sau khi cửa gọi đã ghi đủ dòng và khoá phiên trước đơn.
func NoDon(ctx context.Context, tx pgx.Tx, id int64) error {
	if err := vongdoi.ChuyenDon(ctx, tx, id, "in_progress"); err != nil {
		return err
	}
	if err := vongdoi.KiemChuyenViec("", "pending"); err != nil {
		return err
	}
	if _, err := tx.Exec(ctx, noThanhPhan, id); err != nil {
		return err
	}
	_, err := tx.Exec(ctx, noNuocCham, id)
	return err
}
