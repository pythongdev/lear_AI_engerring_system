package tongquan

import (
	"context"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"github.com/jackc/pgx/v5"
)

// KhaiNguoiCua: POS khai số người đang làm (ADR-121 điểm 2).
var KhaiNguoiCua = authz.Door{Code: "tongquan/khai_nguoi", Need: authz.NeedCounter}

type KhaiNguoiInput struct {
	WorkerCount *int32 `json:"worker_count"`
}

// KhaiNguoi là một lần khai đã ghi; lần mới nhất của ngày bán là con số hiện hành.
type KhaiNguoi struct {
	ID          int64     `json:"id"`
	SaleDate    string    `json:"sale_date"`
	WorkerCount int32     `json:"worker_count"`
	PersonID    int64     `json:"person_id"`
	PersonName  string    `json:"person_name"`
	DeclaredAt  time.Time `json:"declared_at"`
}

// NguoiDangLam: lần khai mới nhất của ngày bán hiện tại, nil khi chưa khai.
type NguoiDangLam struct {
	SaleDate    string     `json:"sale_date"`
	Declaration *KhaiNguoi `json:"declaration"`
}

func ngayHienTai(ctx context.Context, tx pgx.Tx) (string, time.Time, error) {
	moc, err := ngayban.DongHo(ctx, tx)
	if err != nil {
		return "", moc, err
	}
	ngay, err := newRepository(tx).ngay(ctx, moc)
	return ngay, moc, err
}

func (s *Service) Khai(ctx context.Context, nguoi int64, count int32) (out KhaiNguoi, err error) {
	err = authz.Run(ctx, s.pool, nguoi, KhaiNguoiCua, func(tx pgx.Tx) error {
		ngay, _, e := ngayHienTai(ctx, tx)
		if e != nil {
			return e
		}
		out, e = newRepository(tx).khai(ctx, ngay, count)
		return e
	})
	return
}

func (s *Service) DocNguoi(ctx context.Context, nguoi int64) (out NguoiDangLam, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		var e error
		out.SaleDate, _, e = ngayHienTai(ctx, tx)
		if e != nil {
			return e
		}
		out.Declaration, e = newRepository(tx).moiNhat(ctx, out.SaleDate)
		return e
	})
	return
}

// apDungNguoi bày con số POS khai và so với số tối thiểu (ADR-121 điểm 4 · 5).
func (out *TongQuan) apDungNguoi(d *KhaiNguoi, minimum *int32) {
	if d == nil {
		return
	}
	count := d.WorkerCount
	out.WorkersPresent = MucNguoi{Status: "available", Name: out.WorkersPresent.Name, WorkerCount: &count,
		PersonID: &d.PersonID, PersonName: &d.PersonName, DeclaredAt: &d.DeclaredAt}
	w := MucNguoi{Status: "unavailable", Name: out.Shortages.Workers.Name, Reason: "daily_minimum_missing"}
	if minimum != nil {
		missing := max(*minimum-count, 0)
		short := missing > 0
		w = MucNguoi{Status: "available", Name: w.Name, WorkerCount: &count, MinimumWorkers: minimum, Short: &short, MissingWorkers: &missing}
	}
	out.Shortages.Workers = w
}
