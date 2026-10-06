// Package don giữ cửa tạo lượt gọi; P3-06 dựng phần tính giá và ảnh chụp, P3-07/P3-08 thêm kênh.
// Chưa có đường gọi HTTP. Quyền và giao dịch nằm ở chính cửa (QC-13 · I-012).
package don

import (
	"context"
	_ "embed"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TaoLuotGoi = authz.Door{Code: "don/tao_luot_goi", Need: authz.NeedCounter}

//go:embed sql/tao_luot_goi/them_don.sql
var themDon string

//go:embed sql/tao_luot_goi/them_dong.sql
var themDong string

//go:embed sql/tao_luot_goi/them_thanh_phan.sql
var themThanhPhan string

//go:embed sql/tao_luot_goi/them_lua_chon.sql
var themLuaChon string

type YeuCauTaiQuay struct {
	SubmissionCode                string
	TableSessionID, DiningTableID int64
	Lines                         []gia.DongYeuCau
}

type DaTao struct {
	SalesOrderID int64
	TotalVnd     int64
	Lines        []gia.Dong
}

// Tao tính toàn bộ trước câu ghi đầu tiên. Lỗi của bất kỳ dòng nào lùi nguyên lượt gọi.
func Tao(ctx context.Context, pool *pgxpool.Pool, personID int64, yc YeuCauTaiQuay) (DaTao, error) {
	var out DaTao
	err := authz.Run(ctx, pool, personID, TaoLuotGoi, func(tx pgx.Tx) error {
		kq, err := gia.Tinh(ctx, tx, yc.Lines)
		if err != nil {
			return err
		}
		if err := tx.QueryRow(ctx, themDon, yc.TableSessionID, yc.DiningTableID, yc.SubmissionCode).Scan(&out.SalesOrderID); err != nil {
			return err
		}
		for _, d := range kq.Lines {
			var dongID int64
			n := len(d.Components)
			if err := tx.QueryRow(ctx, themDong, out.SalesOrderID, d.Quantity, d.MenuItemID, d.ItemName, d.UnitPriceVnd, n).Scan(&dongID); err != nil {
				return err
			}
			for i, c := range d.Components {
				if _, err := tx.Exec(ctx, themThanhPhan, dongID, i+1, n, c.MenuComponentID, c.ComponentName, c.Quantity, c.TakesFilling, c.BasePriceVnd); err != nil {
					return err
				}
			}
			for _, o := range d.Options {
				if _, err := tx.Exec(ctx, themLuaChon, dongID, o.MenuOptionID, o.OptionGroupName, o.OptionName, o.SurchargeVnd); err != nil {
					return err
				}
			}
		}
		out.TotalVnd, out.Lines = kq.TotalVnd, kq.Lines
		return nil
	})
	if err != nil {
		return DaTao{}, err
	}
	return out, nil
}
