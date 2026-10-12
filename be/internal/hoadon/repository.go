package hoadon

import (
	"context"
	"errors"
	"fmt"
	"time"

	"banhcuon/be/internal/hoadon/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service hoặc của cửa gọi; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) khoaPhien(ctx context.Context, id int64) (string, error) {
	return r.q.KhoaPhien(ctx, id)
}

func (r repository) khoaDonCuaPhien(ctx context.Context, id int64) ([]string, error) {
	return r.q.KhoaDonCuaPhien(ctx, pgtype.Int8{Int64: id, Valid: true})
}

// Đơn không có thì không có khoản: cùng lời từ chối như khi không dòng nào (sales_order_id = NULL).
func (r repository) khoaKhoanTraTruoc(ctx context.Context, don *int64) (int64, error) {
	if don == nil {
		return 0, pgx.ErrNoRows
	}
	return r.q.KhoaKhoanTraTruoc(ctx, *don)
}

func (r repository) themHoaDon(ctx context.Context, b NoiDung) (int64, error) {
	return r.q.ThemHoaDon(ctx, sqlcgen.ThemHoaDonParams{TableSessionID: so(b.Phien), SalesOrderID: so(b.Don), DueVnd: b.Due,
		CashVnd: b.Cash, TransferVnd: b.Transfer, PrepaidCashVnd: b.PrepaidCash, PrepaidTransferVnd: b.PrepaidTransfer,
		DiscountVnd: b.Discount, DiscountCustomerName: chu(b.DiscountCustomerName), DebtVnd: b.Debt, DebtorName: chu(b.Debtor), BookedAt: moc(b.Moc), DebtNote: chu(b.DebtNote)})
}

func (r repository) themHoan(ctx context.Context, bill, prepayment *int64, amount int64, method string, source *string, reason string, m time.Time) (int64, error) {
	return r.q.ThemHoan(ctx, sqlcgen.ThemHoanParams{BillID: so(bill), PrepaymentID: so(prepayment), AmountVnd: amount,
		MethodCode: method, SourceMethodCode: chu(source), Reason: reason, BookedAt: moc(m)})
}

type donKhoa struct {
	phien        *int64
	status, kenh string
	trao         *string
}

// giao chọn câu của cửa giao_xong; ngược lại là câu của trao_tai_quay. Hai câu cùng nội dung, mỗi cửa một file.
func (r repository) khoaDon(ctx context.Context, id int64, giao bool) (donKhoa, error) {
	if giao {
		row, err := r.q.KhoaDonGiao(ctx, id)
		return donKhoa{so64(row.TableSessionID), row.Status, row.ChannelCode, chuCo(row.HandoverCode)}, err
	}
	row, err := r.q.KhoaDonTrao(ctx, id)
	return donKhoa{so64(row.TableSessionID), row.Status, row.ChannelCode, chuCo(row.HandoverCode)}, err
}

func (r repository) tongDon(ctx context.Context, id int64, giao bool) (int64, error) {
	if giao {
		return r.q.TongDonGiao(ctx, id)
	}
	return r.q.TongDonTrao(ctx, id)
}

func (r repository) conViecChuaRaBan(ctx context.Context, id int64) (bool, error) {
	return r.q.ConViecChuaRaBan(ctx, id)
}

func (r repository) khoaHoaDonHoan(ctx context.Context, id int64) (int64, error) {
	return r.q.KhoaHoaDonHoan(ctx, id)
}

func (r repository) khoaKhoanTraLai(ctx context.Context, id int64) (int64, error) {
	return r.q.KhoaKhoanTraLai(ctx, id)
}

func (r repository) khoaHoaDonNo(ctx context.Context, id int64) (int64, error) {
	return r.q.KhoaHoaDonNo(ctx, id)
}

// conNo là min() của các lần thu: chưa lần nào thì NULL.
func (r repository) conNo(ctx context.Context, id int64) (*int64, error) {
	v, err := r.q.ConNo(ctx, id)
	if err != nil {
		return nil, err
	}
	return soTuDong(v)
}

func (r repository) themThuNo(ctx context.Context, id, debt, cash, transfer int64, before *int64, remaining int64, m time.Time) (int64, error) {
	return r.q.ThemThuNo(ctx, sqlcgen.ThemThuNoParams{BillID: id, DebtVnd: debt, CashVnd: cash, TransferVnd: transfer,
		RemainingBeforeVnd: so(before), RemainingVnd: remaining, BookedAt: moc(m)})
}

func (r repository) danhSachNo(ctx context.Context) ([]map[string]any, error) {
	rows, err := r.q.DanhSachNo(ctx)
	if err != nil {
		return nil, err
	}
	debts := []map[string]any{}
	for _, row := range rows {
		// Hoá đơn có nợ luôn có tên người nợ (Ghi chặn); NULL là lỗi hệ thống như khi đọc thẳng vào string.
		if !row.DebtorName.Valid {
			return nil, errors.New("hoadon: hoá đơn có nợ mà không có tên người nợ")
		}
		remain, err := soTuDong(row.RemainingVnd)
		if err != nil || remain == nil {
			return nil, fmt.Errorf("hoadon: số nợ còn lại không đọc được: %v", err)
		}
		debts = append(debts, map[string]any{"bill_id": row.ID, "debtor_name": row.DebtorName.String, "debt_vnd": row.DebtVnd,
			"remaining_vnd": *remain, "debt_note": chuCo(row.DebtNote)})
	}
	return debts, nil
}

func so(v *int64) pgtype.Int8 {
	if v == nil {
		return pgtype.Int8{}
	}
	return pgtype.Int8{Int64: *v, Valid: true}
}

func so64(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

func chu(v *string) pgtype.Text {
	if v == nil {
		return pgtype.Text{}
	}
	return pgtype.Text{String: *v, Valid: true}
}

func chuCo(v pgtype.Text) *string {
	if !v.Valid {
		return nil
	}
	return &v.String
}

func moc(t time.Time) pgtype.Timestamptz { return pgtype.Timestamptz{Time: t, Valid: true} }

// soTuDong đổi cột bigint mà sqlc không suy được kiểu (min, coalesce) về *int64.
func soTuDong(v any) (*int64, error) {
	switch x := v.(type) {
	case nil:
		return nil, nil
	case int64:
		return &x, nil
	default:
		return nil, fmt.Errorf("hoadon: kiểu số lạ %T", v)
	}
}

func (r repository) chuQuanGiamGia(ctx context.Context, nguoi int64) (bool, error) {
	return r.q.ChuQuanGiamGia(ctx, nguoi)
}
