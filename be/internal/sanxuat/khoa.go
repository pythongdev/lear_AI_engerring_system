package sanxuat

import (
	"context"

	"banhcuon/be/internal/apierr"
	"github.com/jackc/pgx/v5"
)

type viec struct {
	ID           int64
	DonID        int64
	PhienID      *int64
	TrangThai    string
	TrangThaiDon string
	LamSai       bool
}

// Mọi cửa khoá phiên trước đơn, rồi các đơn vị theo id. Chủ của station_job
// không đổi; lần chuyển chỉ đổi chủ của production_batch_item.
func khoaTap(ctx context.Context, tx pgx.Tx, ids []int64) ([]viec, error) {
	for _, query := range []string{
		`SELECT s.id FROM table_session s WHERE s.id IN (
		 SELECT o.table_session_id FROM sales_order o JOIN station_job j ON j.sales_order_id = o.id
		 WHERE j.id = ANY($1::bigint[])) ORDER BY s.id FOR UPDATE`,
		`SELECT o.id FROM sales_order o WHERE o.id IN (
		 SELECT j.sales_order_id FROM station_job j WHERE j.id = ANY($1::bigint[]))
		 ORDER BY o.id FOR UPDATE`,
	} {
		rows, err := tx.Query(ctx, query, ids)
		if err != nil {
			return nil, err
		}
		if _, err := pgx.CollectRows(rows, pgx.RowTo[int64]); err != nil {
			return nil, err
		}
	}
	rows, err := tx.Query(ctx, `SELECT j.id, j.sales_order_id, o.table_session_id, j.status, o.status,
	 EXISTS (SELECT 1 FROM wrong_make_note n WHERE n.live_station_job_id = j.id)
	 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
	 WHERE j.id = ANY($1::bigint[]) ORDER BY j.id FOR UPDATE OF j`, ids)
	if err != nil {
		return nil, err
	}
	out, err := pgx.CollectRows(rows, pgx.RowToStructByPos[viec])
	if err != nil {
		return nil, err
	}
	seen := make(map[int64]bool)
	for _, id := range ids {
		seen[id] = true
	}
	if len(out) != len(seen) {
		return nil, apierr.Error{Code: apierr.CodeStationJobNotFound}
	}
	return out, nil
}

// Mẻ được khoá trước phiên/đơn/việc ở cả lùi và chuyển. Nhờ vậy chủ hiện tại
// đọc sau khoá mẻ không đổi trong lúc lùi; không khoá vật trước rồi chờ việc.
func khoaMeNguon(ctx context.Context, tx pgx.Tx, ids []int64) error {
	rows, err := tx.Query(ctx, `SELECT b.id FROM production_batch b WHERE b.id IN (
	 SELECT i.production_batch_id FROM production_batch_item i
	 WHERE i.live_station_job_id = ANY($1::bigint[])) ORDER BY b.id FOR UPDATE`, ids)
	if err != nil {
		return err
	}
	_, err = pgx.CollectRows(rows, pgx.RowTo[int64])
	return err
}
