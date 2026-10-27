package taikhoan

import (
	"banhcuon/be/internal/taikhoan/internal/sqlcgen"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"strconv"
)

// Chỉ file này gọi sqlc (QC-13); service đọc kiểu qua các tên dưới, giao dịch do authz mở ở service.
type (
	account            = sqlcgen.DocTaiKhoanRow
	loginSession       = sqlcgen.LoginSession
	ketThucPhienParams = sqlcgen.KetThucPhienParams
	moPhienParams      = sqlcgen.MoPhienParams
	taoMaParams        = sqlcgen.TaoMaParams
	themTaiKhoanParams = sqlcgen.ThemTaiKhoanParams
)

type repository struct{ *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{sqlcgen.New(tx)} }
func nullableID(id int64) pgtype.Int8    { return pgtype.Int8{Int64: id, Valid: id != 0} }

// requiredText giữ chuỗi rỗng là giá trị để CHECK cũ vẫn từ chối, không đổi thành NULL.
func requiredText(s string) pgtype.Text { return pgtype.Text{String: s, Valid: true} }
func nullableText(s string) pgtype.Text { return pgtype.Text{String: s, Valid: s != ""} }
func (r repository) password(ctx context.Context, id int64, hash string, setter int64) error {
	return r.GhiMatKhau(ctx, sqlcgen.GhiMatKhauParams{AccountID: id, PasswordHash: hash, SetByPersonID: nullableID(setter), MustChangePassword: setter != 0})
}
func (r repository) state(ctx context.Context, id int64, status string, person int64, role string, actor int64) error {
	return r.DoiTrangThai(ctx, sqlcgen.DoiTrangThaiParams{ID: id, Status: status, PersonID: nullableID(person), RoleCode: nullableText(role), DecidedByPersonID: nullableID(actor)})
}

// actor khai người thao tác của giao dịch cho vết sửa (I-018) khi cửa chưa có người lúc mở.
func (r repository) actor(ctx context.Context, id int64) error {
	return r.KhaiNguoiThaoTac(ctx, strconv.FormatInt(id, 10))
}

// nguoiCuaPhien đọc người của một phiên còn hiệu lực, ngoài giao dịch của cửa (Authenticator).
func nguoiCuaPhien(ctx context.Context, db sqlcgen.DBTX, hash []byte) (int64, error) {
	id, err := sqlcgen.New(db).NguoiCuaPhien(ctx, hash)
	return id.Int64, err
}

// personIsOwner giữ người không tồn tại cho kiểm tra khoá ngoại khi gắn tài khoản.
func (r repository) personIsOwner(ctx context.Context, id int64) (bool, error) {
	p, err := r.DocNguoi(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	return p.IsOwner, err
}
