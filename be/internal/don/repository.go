package don

import (
	"context"
	"encoding/json"
	"time"

	"banhcuon/be/internal/don/internal/sqlcgen"
	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func mocPG(t time.Time) pgtype.Timestamptz { return pgtype.Timestamptz{Time: t, Valid: true} }

func chuPG(s *string) pgtype.Text {
	if s == nil {
		return pgtype.Text{}
	}
	return pgtype.Text{String: *s, Valid: true}
}

func chuGo(t pgtype.Text) *string {
	if !t.Valid {
		return nil
	}
	return &t.String
}

func soGo(n pgtype.Int8) *int64 {
	if !n.Valid {
		return nil
	}
	return &n.Int64
}

func (r repository) dongHo(ctx context.Context) (time.Time, error) {
	moc, err := r.q.DongHo(ctx)
	return moc.Time, err
}

func (r repository) tamDung(ctx context.Context, moc time.Time) (bool, error) {
	return r.q.TamDung(ctx, mocPG(moc))
}

func (r repository) ngoaiGio(ctx context.Context, moc time.Time) (bool, error) {
	return r.q.NgoaiGio(ctx, mocPG(moc))
}

func (r repository) quanMu(ctx context.Context, moc time.Time) (bool, error) {
	return r.q.QuanMu(ctx, mocPG(moc))
}

// docDon đọc đơn theo dấu, kèm mã QR đã gọi và cờ mang về của từng dòng (để so lần gửi lại).
func (r repository) docDon(ctx context.Context, submission string) (DaTao, string, []bool, error) {
	row, err := r.q.DocDon(ctx, submission)
	if err != nil {
		return DaTao{}, "", nil, err
	}
	out := DaTao{SalesOrderID: row.ID, TableSessionID: row.TableSessionID, DiningTableID: row.DiningTableID,
		ChannelCode: row.ChannelCode, Status: row.Status, TotalVnd: row.Column7}
	out.LienHe = LienHe{HandoverCode: row.HandoverCode, CustomerPhone: row.CustomerPhone,
		DeliveryAddress: chuGo(row.DeliveryAddress), CustomerName: chuGo(row.CustomerName), ContactNote: chuGo(row.ContactNote)}
	// PostgreSQL kết xuất mốc JSON theo múi giờ phiên kết nối (hợp đồng §6).
	if err := json.Unmarshal(row.Column13, &out.LienHe.CustomerNeededAt); err != nil {
		return DaTao{}, "", nil, err
	}
	if err := json.Unmarshal(row.Column8, &out.Lines); err != nil {
		return DaTao{}, "", nil, err
	}
	var takeaways []bool
	err = json.Unmarshal(row.Column9, &takeaways)
	return out, row.Code, takeaways, err
}

func (r repository) khoaPhien(ctx context.Context, tableID int64) (int64, string, error) {
	row, err := r.q.KhoaPhien(ctx, tableID)
	return row.ID, row.Status, err
}

func (r repository) themPhien(ctx context.Context) (int64, error) { return r.q.ThemPhien(ctx, "open") }

func (r repository) themBan(ctx context.Context, sessionID, tableID int64) error {
	return r.q.ThemBan(ctx, sqlcgen.ThemBanParams{TableSessionID: sessionID, DiningTableID: tableID})
}

func (r repository) themDon(ctx context.Context, channel, status string, sessionID, tableID int64, submission string, qrID *int64, lh LienHe) (int64, error) {
	var qr pgtype.Int8
	if qrID != nil {
		qr = pgtype.Int8{Int64: *qrID, Valid: true}
	}
	var can pgtype.Timestamptz
	if lh.CustomerNeededAt != nil {
		can = mocPG(*lh.CustomerNeededAt)
	}
	return r.q.ThemDon(ctx, sqlcgen.ThemDonParams{ChannelCode: channel, Status: status, Column3: sessionID, Column4: tableID,
		SubmissionCode: submission, QrCodeID: qr, Column7: lh.HandoverCode, Column8: lh.CustomerPhone,
		DeliveryAddress: chuPG(lh.DeliveryAddress), CustomerNeededAt: can, CustomerName: chuPG(lh.CustomerName), ContactNote: chuPG(lh.ContactNote)})
}

// themDong ghi một dòng đã tính giá; takeaway nil là đơn ngoài bàn (cột mang về để mặc định).
func (r repository) themDong(ctx context.Context, donID int64, d gia.Dong, takeaway *bool) (int64, error) {
	return r.themDongTaiMoc(ctx, donID, d, takeaway, pgtype.Timestamptz{})
}
func (r repository) themDongTaiMoc(ctx context.Context, donID int64, d gia.Dong, takeaway *bool, at pgtype.Timestamptz) (int64, error) {
	n := int32(len(d.Components))
	if takeaway == nil {
		return r.q.ThemDongMangDi(ctx, sqlcgen.ThemDongMangDiParams{SalesOrderID: donID, Quantity: d.Quantity,
			MenuItemID: d.MenuItemID, ItemName: d.ItemName, UnitPriceVnd: d.UnitPriceVnd, ComponentCount: n, Column7: at})
	}
	return r.q.ThemDong(ctx, sqlcgen.ThemDongParams{SalesOrderID: donID, Quantity: d.Quantity, MenuItemID: d.MenuItemID,
		ItemName: d.ItemName, UnitPriceVnd: d.UnitPriceVnd, ComponentCount: n, IsTakeaway: *takeaway, Column8: at})
}

func (r repository) themThanhPhan(ctx context.Context, dongID int64, viTri, n int32, c gia.ThanhPhan) error {
	return r.q.ThemThanhPhan(ctx, sqlcgen.ThemThanhPhanParams{OrderLineID: dongID, Position: viTri, LineComponentCount: n,
		MenuComponentID: c.MenuComponentID, ComponentName: c.ComponentName, Quantity: c.Quantity,
		TakesFilling: c.TakesFilling, BasePriceVnd: c.BasePriceVnd})
}

func (r repository) themLuaChon(ctx context.Context, dongID int64, o gia.LuaChon) error {
	return r.q.ThemLuaChon(ctx, sqlcgen.ThemLuaChonParams{OrderLineID: dongID, MenuOptionID: o.MenuOptionID,
		OptionGroupName: o.OptionGroupName, OptionName: o.OptionName, SurchargeVnd: o.SurchargeVnd})
}

// Ba câu của cửa duyệt hoặc từ chối: đọc phiên của đơn, khoá phiên, khoá đơn.
func (r repository) docPhienDon(ctx context.Context, tuChoi bool, id int64) (*int64, error) {
	if tuChoi {
		n, err := r.q.TuChoiDocPhien(ctx, id)
		return soGo(n), err
	}
	n, err := r.q.DuyetDocPhien(ctx, id)
	return soGo(n), err
}

func (r repository) khoaPhienDon(ctx context.Context, tuChoi bool, sessionID int64) (string, error) {
	if tuChoi {
		return r.q.TuChoiKhoaPhien(ctx, sessionID)
	}
	return r.q.DuyetKhoaPhien(ctx, sessionID)
}

func (r repository) khoaDon(ctx context.Context, tuChoi bool, id int64) (string, error) {
	if tuChoi {
		return r.q.TuChoiKhoaDon(ctx, id)
	}
	return r.q.DuyetKhoaDon(ctx, id)
}

func (r repository) huyDocPhien(ctx context.Context, id int64) (*int64, error) {
	n, err := r.q.HuyDocPhien(ctx, id)
	return soGo(n), err
}

type donHen struct {
	id     int64
	status string
}

// nhaHenKhoaDon khoá các đơn đặt trước tới lần nhắc đầu, bỏ qua đơn đang bị khoá; đọc hết trước khi trả.
func (r repository) nhaHenKhoaDon(ctx context.Context, moc time.Time) ([]donHen, error) {
	rows, err := r.q.NhaHenKhoaDon(ctx, mocPG(moc))
	out := make([]donHen, len(rows))
	for i, row := range rows {
		out[i] = donHen{row.ID, row.Status}
	}
	return out, err
}

func (r repository) nhacHen(ctx context.Context) ([]NhacHen, error) {
	rows, err := r.q.NhacHen(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]NhacHen, len(rows))
	for i, row := range rows {
		out[i] = NhacHen{SalesOrderID: row.ID, Status: row.Status}
		// Giữ độ lệch múi giờ của phiên PostgreSQL như hợp đồng §6.
		if err := json.Unmarshal(row.NeededAt, &out[i].CustomerNeededAt); err != nil {
			return nil, err
		}
	}
	return out, nil
}

func (r repository) roiQuanKhoaDon(ctx context.Context, id int64) (string, *string, error) {
	row, err := r.q.RoiQuanKhoaDon(ctx, id)
	return row.Status, chuGo(row.HandoverCode), err
}

func (r repository) roiQuanDocViec(ctx context.Context, id int64) (bool, error) {
	return r.q.RoiQuanDocViec(ctx, id)
}

// Nhập bù dùng cùng các ô INSERT của tao_luot_goi, tạo thẳng phiên đã đóng.
func (r repository) themPhienGiay(ctx context.Context, tableID int64, sold time.Time) (int64, error) {
	id, err := r.q.ThemPhien(ctx, "closed")
	if err != nil {
		return 0, err
	}
	err = r.q.ThemBan(ctx, sqlcgen.ThemBanParams{TableSessionID: id, DiningTableID: tableID, SessionClosed: true, CleanedAt: mocPG(sold)})
	return id, err
}

func (r repository) themDongGiay(ctx context.Context, id int64, d gia.Dong, takeaway *bool, sold time.Time) (int64, error) {
	return r.themDongTaiMoc(ctx, id, d, takeaway, mocPG(sold))
}
