package troly

import (
	"context"
	"encoding/json"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/sanxuat"
	"banhcuon/be/internal/tongquan"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// NguonNoiBo dùng chung các service đọc của màn tay.
type NguonNoiBo struct {
	pool     *pgxpool.Pool
	tongQuan *tongquan.Service
	sanXuat  *sanxuat.Service
}

func MoiNguonNoiBo(pool *pgxpool.Pool) *NguonNoiBo {
	return &NguonNoiBo{pool: pool, tongQuan: tongquan.NewService(pool), sanXuat: sanxuat.NewService(pool)}
}

// CongCuGhi luôn rỗng, kể cả receiver nil: bản chạy chưa mở nhóm ghi nào (ADR-140).
func (*NguonNoiBo) CongCuGhi(context.Context, int64) ([]CongCuGhi, error) {
	return nil, nil
}

// CongCu đóng từng giao dịch kiểm lớp trước khi trả danh sách cho lượt gọi model.
func (n *NguonNoiBo) CongCu(ctx context.Context, nguoi int64, menu *gia.Service) ([]CongCu, error) {
	cc := CongCuCongKhai(menu)
	if n == nil || nguoi <= 0 {
		return cc, nil
	}
	qua := make(map[authz.Need]bool)
	for _, lop := range []authz.Need{authz.NeedPerson, authz.NeedCounterOrOwner, authz.NeedOwner} {
		err := authz.ReadAs(ctx, n.pool, authz.Caller{PersonID: nguoi}, lop, func(pgx.Tx, authz.Granted) error { return nil })
		if err == nil {
			qua[lop] = true
			continue
		}
		var e apierr.Error
		if errors.As(err, &e) {
			switch e.Code {
			case apierr.CodeUnauthenticated, apierr.CodeNotOnCounterDuty, apierr.CodeOwnerOnly:
				continue
			}
		}
		return nil, err
	}
	if !qua[authz.NeedPerson] {
		return cc, nil
	}
	cc = append(cc, CongCu{Ten: "doc_bang_tram", MoTa: "Đọc bảng công việc của trạm.", Chay: func(ctx context.Context, raw json.RawMessage) (json.RawMessage, error) {
		var body struct {
			StationCode json.RawMessage `json:"station_code"`
		}
		if len(raw) != 0 {
			if err := json.Unmarshal(raw, &body); err != nil {
				return nil, err
			}
		}
		var code string
		if body.StationCode != nil {
			var value *string
			if err := json.Unmarshal(body.StationCode, &value); err != nil {
				return nil, err
			}
			if value == nil {
				return nil, errors.New("station_code phải là chuỗi")
			}
			code = *value
		}
		out, err := n.sanXuat.DocGom(ctx, code, nil)
		if err != nil {
			return nil, err
		}
		return out, nil
	}})
	if qua[authz.NeedCounterOrOwner] {
		cc = append(cc, CongCu{Ten: "doc_bang_phuc_vu", MoTa: "Đọc tình hình phục vụ theo bàn.", Chay: func(ctx context.Context, _ json.RawMessage) (json.RawMessage, error) {
			out, err := n.tongQuan.DocBang(ctx, nguoi)
			if err != nil {
				return nil, err
			}
			return ChieuBangPhucVu(out)
		}})
	}
	if qua[authz.NeedOwner] {
		cc = append(cc, CongCu{Ten: "doc_tong_quan", MoTa: "Đọc tổng quan của chủ quán.", Chay: func(ctx context.Context, _ json.RawMessage) (json.RawMessage, error) {
			out, err := n.tongQuan.Doc(ctx, nguoi)
			if err != nil {
				return nil, err
			}
			return ChieuTongQuan(out)
		}})
	}
	return cc, nil
}
