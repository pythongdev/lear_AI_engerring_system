package khach

import (
	"banhcuon/be/internal/khach/internal/sqlcgen"
	"context"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type repository struct{ *sqlcgen.Queries }

func repo(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func text(s string) pgtype.Text { return pgtype.Text{String: s, Valid: s != ""} }
func pointer(s pgtype.Text) *string {
	if !s.Valid {
		return nil
	}
	return &s.String
}
func (r repository) create(ctx context.Context, in Registration) (int64, error) {
	return r.ThemTaiKhoan(ctx, sqlcgen.ThemTaiKhoanParams{Phone: text(in.Phone), Email: text(in.Email), DisplayName: in.DisplayName})
}
func (r repository) password(ctx context.Context, id int64, h string) error {
	return r.GhiMatKhau(ctx, sqlcgen.GhiMatKhauParams{CustomerAccountID: id, PasswordHash: h})
}
func (r repository) session(ctx context.Context, id int64, h []byte) error {
	return r.MoPhien(ctx, sqlcgen.MoPhienParams{CustomerAccountID: id, TokenHash: h})
}
func (r repository) end(ctx context.Context, id, only, except int64, reason string) error {
	return r.coVet(ctx, reason, func() error {
		return r.KetThucPhien(ctx, sqlcgen.KetThucPhienParams{CustomerAccountID: id, Column2: only, Column3: except, EndReason: text(reason)})
	})
}
func (r repository) delivery(ctx context.Context, id int64, in Delivery) error {
	return r.coVet(ctx, LuuGiao.Code, func() error {
		return r.LuuGiao(ctx, sqlcgen.LuuGiaoParams{ID: id, DeliveryName: text(in.Name), DeliveryPhone: text(in.Phone), DeliveryAddress: text(in.Address)})
	})
}
func (r repository) resetCode(ctx context.Context, id int64, h []byte) error {
	return r.TaoMa(ctx, sqlcgen.TaoMaParams{CustomerAccountID: id, TokenHash: h})
}
func (r repository) profile(ctx context.Context, id int64) (Profile, error) {
	a, e := r.Doc(ctx, id)
	return Profile{a.ID, a.DisplayName, pointer(a.Phone), pointer(a.Email), pointer(a.DeliveryName), pointer(a.DeliveryPhone), pointer(a.DeliveryAddress)}, e
}
func (r repository) orders(ctx context.Context, id, before int64, limit int32) ([]sqlcgen.DonRow, error) {
	return r.Don(ctx, sqlcgen.DonParams{CustomerAccountID: pgtype.Int8{Int64: id, Valid: true}, Column2: before, Column3: limit})
}

// coVet khai và gỡ lý do sát câu sửa như cửa người làm. Khách không có person:
// luôn khai lý do, không gán shop.actor_person_id và không dùng CoVet của vongdoi
// (hàm ấy cố ý bỏ lý do khi không có actor cho các cửa QR).
func (r repository) coVet(ctx context.Context, reason string, fn func() error) error {
	if err := r.KhaiLyDo(ctx, reason); err != nil {
		return err
	}
	if err := fn(); err != nil {
		return err
	}
	return r.KhaiLyDo(ctx, "")
}
func (r repository) useReset(ctx context.Context, id int64) error {
	return r.coVet(ctx, DatLai.Code, func() error { return r.DungMa(ctx, id) })
}
