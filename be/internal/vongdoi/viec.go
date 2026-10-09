package vongdoi

import (
	"context"
	_ "embed"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
)

var CuaChuyenViec = authz.Door{Code: "vongdoi/chuyen_viec", Need: authz.NeedCallingDoor}

//go:embed sql/chuyen_viec/khoa.sql
var khoaViec string

//go:embed sql/chuyen_viec/chuyen.sql
var chuyenViec string

func CapViec() [][2]string {
	return [][2]string{{"", "pending"}, {"pending", "made"}, {"made", "served"}, {"made", "pending"}}
}
func KiemChuyenViec(tu, den string) error {
	if !coCap(CapViec(), tu, den) {
		return apierr.Error{Code: apierr.CodeStationJobTransitionNotAllowed}
	}
	return nil
}

// Cửa gọi khoá phiên, đơn và tập việc theo thứ tự trước khi chuyển.
func ChuyenViec(ctx context.Context, tx pgx.Tx, id int64, den string) error {
	return doiViec(ctx, tx, id, den, 0, false)
}

// LuiViecCuaMe trả đơn vị của mẻ vừa lùi về pending, kể cả khi đơn đã huỷ: mẻ lùi là mẻ không có
// thật, giữ đơn vị ở made để lại thứ không ai làm mà cửa chuyển sẽ đem cho bàn khác (ADR-090 Sửa
// đổi 2026-10-09). Chỉ cặp made → pending; ghi chú bánh làm sai do cửa lùi chặn trước.
func LuiViecCuaMe(ctx context.Context, tx pgx.Tx, id int64) error {
	return doiViec(ctx, tx, id, "pending", 0, true)
}

// NhaNguonChuyen chỉ nhả đơn vị đã huỷ có vết chuyển vừa ghi, sau khi vật đã đổi chủ.
// Chỉ nguồn made (ADR-090 điểm 3): cái đã ra tới bàn khách không đổi chủ.
func NhaNguonChuyen(ctx context.Context, tx pgx.Tx, id, transferID int64) error {
	return doiViec(ctx, tx, id, "pending", transferID, false)
}

func doiViec(ctx context.Context, tx pgx.Tx, id int64, den string, transferID int64, luiMe bool) error {
	var tu, don string
	if err := tx.QueryRow(ctx, khoaViec, id).Scan(&tu, &don); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeStationJobNotFound}
		}
		return err
	}
	if transferID != 0 {
		var hop bool
		err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM station_job_transfer t
		 JOIN production_batch_item i ON i.id = t.production_batch_item_id
		 WHERE t.id = $1 AND t.from_station_job_id = $2 AND i.station_job_id = t.to_station_job_id
		 AND NOT i.batch_rolled_back)`, transferID, id).Scan(&hop)
		if err != nil {
			return err
		}
		if !hop || don != "cancelled" || tu != "made" {
			return apierr.Error{Code: apierr.CodeStationJobTransitionNotAllowed}
		}
	} else {
		if don == "cancelled" && !(luiMe && tu == "made") {
			return apierr.Error{Code: apierr.CodeStationJobTransitionNotAllowed}
		}
		if err := KiemChuyenViec(tu, den); err != nil {
			return err
		}
	}
	return CoVet(ctx, tx, CuaChuyenViec.Code+": "+tu+" → "+den, func() error {
		_, err := tx.Exec(ctx, chuyenViec, id, den)
		return err
	})
}
