package nguyenlieu

import (
	"context"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

func idPointer(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

// Các hàm này chỉ được gọi trong giao dịch authz.Run của cửa khoản chi.
// Mỗi câu ghi sổ vẫn nằm trong đúng cửa SQL của miền nguyên liệu.
// XemThu khoá thứ trong sổ rồi trả tên, dấu ngừng và đã có khoản con nối hay chưa.
func XemThu(ctx context.Context, tx pgx.Tx, id int64) (name string, stopped, linked bool, err error) {
	row, err := newRepository(tx).timThu(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", false, false, apierr.Error{Code: apierr.CodeSupplyItemNotFound}
	}
	return row.Name, row.Stopped, row.Linked, err
}

func TaoThu(ctx context.Context, tx pgx.Tx, name, unit string) (Thu, error) {
	repo := newRepository(tx)
	id, err := repo.them(ctx, name, unit)
	if err != nil {
		return Thu{}, err
	}
	moc, err := ngayban.DongHo(ctx, tx)
	if err != nil {
		return Thu{}, err
	}
	return repo.docThu(ctx, id, moc)
}
func DocThuTrongGiaoDich(ctx context.Context, tx pgx.Tx, id int64) (Thu, error) {
	moc, err := ngayban.DongHo(ctx, tx)
	if err != nil {
		return Thu{}, err
	}
	return newRepository(tx).docThu(ctx, id, moc)
}

func DoiTenTrongGiaoDich(ctx context.Context, tx pgx.Tx, id int64, name string) error {
	return newRepository(tx).doiTenThu(ctx, id, name)
}

func NgungTrongGiaoDich(ctx context.Context, tx pgx.Tx, id int64) error {
	return newRepository(tx).ngungThu(ctx, id)
}

func MoTrongGiaoDich(ctx context.Context, tx pgx.Tx, id int64) error {
	return newRepository(tx).moThu(ctx, id)
}

// DatMuaTrongGiaoDich dùng numeric của PostgreSQL để so giá trị, kể cả 12.5 = 12.50.
func DatMuaTrongGiaoDich(ctx context.Context, tx pgx.Tx, id int64, date, measure, reason string) error {
	if !DoLuongHopLe(measure) {
		return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "purchased_measure"}
	}
	_, stopped, _, err := XemThu(ctx, tx, id)
	if err != nil {
		return err
	}
	if stopped {
		return apierr.Error{Code: apierr.CodeSupplyItemStopped}
	}
	moc, err := ngayban.DongHo(ctx, tx)
	if err != nil {
		return err
	}
	future, err := newRepository(tx).ngayTuongLai(ctx, date, moc)
	if err != nil {
		return err
	}
	if future {
		return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "received_date"}
	}
	old, err := newRepository(tx).timMua(ctx, id, date, measure)
	if errors.Is(err, pgx.ErrNoRows) {
		_, err = newRepository(tx).ghi(ctx, YeuCau{ItemID: id, EntryDate: date, Kind: "purchased", Measure: measure})
		return err
	}
	if err != nil {
		return err
	}
	if old.SameMeasure {
		return nil
	}
	if reason == "" {
		return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "reason"}
	}
	return vongdoi.CoVet(ctx, tx, reason, func() error { return newRepository(tx).sua(ctx, old.ID, measure) })
}
