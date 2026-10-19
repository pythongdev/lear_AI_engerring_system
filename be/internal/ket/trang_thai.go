package ket

import (
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"context"
	"github.com/jackc/pgx/v5"
)

type TrangThaiNgay struct {
	Status              *string `json:"status"`
	PaperEntriesPending int64   `json:"paper_entries_pending"`
}

// DocTrangThaiNgay dùng cho đường tổng kết đã kiểm quyền; không cần đếm két
// hoặc tiền đầu ngày. Không đổi hành vi DocSo hay bất kỳ cửa ghi nào.
func (s *Service) DocTrangThaiNgay(ctx context.Context, ngay string) (out TrangThaiNgay, err error) {
	err = postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		if e := ngayban.Khoa(ctx, tx, ngay, false); e != nil {
			return e
		}
		repo := newRepository(tx)
		var e error
		_, out.PaperEntriesPending, e = repo.soGiay(ctx, ngay)
		if e != nil {
			return e
		}
		dau, e := repo.docDau(ctx, ngay)
		if e != nil {
			return e
		}
		if len(dau) > 0 {
			status := "reconciled"
			if dau[len(dau)-1].Reopening != nil {
				status = "reopened"
			}
			out.Status = &status
		}
		return nil
	})
	return
}
