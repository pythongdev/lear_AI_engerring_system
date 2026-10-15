package don

import (
	"context"
	"crypto/rand"
	"fmt"
	"time"

	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
)

// GhiNhapBu chỉ gọi từ cửa hoadon/nhap_bu đã kiểm quyền, hình và giá trong cùng giao dịch.
// Các ô thêm vẫn thuộc tao_luot_goi; không xét nhận đơn mới, không gọi vòng đời hay nổ việc.
func GhiNhapBu(ctx context.Context, tx pgx.Tx, tableID int64, sold time.Time, lh LienHe, items []DongGoi, kq gia.KetQua) (order int64, session *int64, err error) {
	repo := newRepository(tx)
	channel := "phone_preorder"
	var sessionID int64
	if tableID != 0 {
		channel = "staff_pos"
		sessionID, err = repo.themPhienGiay(ctx, tableID, sold)
		if err != nil {
			return 0, nil, err
		}
		session = &sessionID
	}
	// Dấu nội bộ cho cột NOT NULL của đơn; sổ/vị trí là định danh yêu cầu nhập bù.
	var b [16]byte
	if _, err = rand.Read(b[:]); err != nil {
		return 0, nil, err
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	submission := fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
	order, err = repo.themDon(ctx, channel, "completed", sessionID, tableID, submission, nil, lh)
	if err != nil {
		return 0, nil, err
	}
	for i, d := range kq.Lines {
		var takeaway *bool
		if tableID != 0 {
			takeaway = &items[i].IsTakeaway
		}
		if err := repo.ghiDong(ctx, order, d, takeaway, mocPG(sold)); err != nil {
			return 0, nil, err
		}
	}
	return order, session, nil
}
