package troly

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"math/big"
	"strings"
	"time"
	"unicode/utf8"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var cuaGiuCho = authz.Door{Code: "troly/giu_cho", Need: authz.NeedPublic}
var cuaChot = authz.Door{Code: "troly/chot", Need: authz.NeedPublic}
var hetNganSach = errors.New("het_ngan_sach")

type Lop struct {
	pool                  *pgxpool.Pool
	cauHinh               CauHinh
	nha                   NhaCungCap
	HanMoiLan, HanMoiLuot time.Duration
}

func MoiLop(pool *pgxpool.Pool, c CauHinh, n NhaCungCap) *Lop {
	return &Lop{pool: pool, cauHinh: c, nha: n, HanMoiLan: 20 * time.Second, HanMoiLuot: 45 * time.Second}
}

// Tính bằng số nguyên, làm tròn lên sau khi cộng; không để giá hoặc mức dùng tràn int64.
func tinhTien(vao, ra, giaVao, giaRa int64) (int64, bool) {
	if vao < 0 || ra < 0 || giaVao < 0 || giaRa < 0 {
		return 0, false
	}
	n := new(big.Int).Mul(big.NewInt(vao), big.NewInt(giaVao))
	n.Add(n, new(big.Int).Mul(big.NewInt(ra), big.NewInt(giaRa)))
	n.Add(n, big.NewInt(999999))
	n.Div(n, big.NewInt(1000000))
	return n.Int64(), n.IsInt64()
}
func soByte(g GoiModel) int64 {
	n := len(g.HeThong)
	for _, t := range g.LichSu {
		n += len(t.Vai) + len(t.Chu)
	}
	for _, t := range g.CongCu {
		n += len(t)
	}
	for _, b := range g.Buoc {
		n += len(b.LoiGoi.Ten) + len(b.LoiGoi.ThamSo) + len(b.KetQua) + len(b.Loi)
	}
	return int64(n)
}
func (l *Lop) giuCho(ctx context.Context, tien int64) (id int64, err error) {
	err = authz.RunAs(ctx, l.pool, authz.Caller{}, cuaGiuCho, func(tx pgx.Tx, _ authz.Granted) error {
		r := newRepository(tx)
		var e error
		id, e = r.giuCho(ctx, l.nha.Ma(), l.nha.Model(), tien)
		if e != nil {
			return e
		}
		// INSERT đã lấy khoá của trigger; giữ khoá tới sau phép đọc tổng này và COMMIT.
		tong, e := r.tongThang(ctx)
		if e != nil {
			return e
		}
		if tong > l.cauHinh.TranThangMicroUSD {
			return hetNganSach
		}
		return nil
	})
	return
}
func (l *Lop) chot(id, tien int64, ph PhanHoi) error {
	// Không kế thừa huỷ hoặc hạn của lượt: dòng giữ chỗ vẫn phải được chốt.
	ctx, huy := context.WithTimeout(context.Background(), 5*time.Second)
	defer huy()
	return authz.RunAs(ctx, l.pool, authz.Caller{}, cuaChot, func(tx pgx.Tx, _ authz.Granted) error {
		return newRepository(tx).chot(ctx, id, tien, ph)
	})
}
func (l *Lop) Luot(ctx context.Context, cau string, lichSu []Tin, congCu []CongCu) (KetQua, error) {
	return l.LuotCoGhi(ctx, cau, lichSu, congCu, nil)
}

func laDoiTuongJSON(raw json.RawMessage) bool {
	var doiTuong map[string]json.RawMessage
	return json.Unmarshal(raw, &doiTuong) == nil && doiTuong != nil
}

func (l *Lop) LuotCoGhi(ctx context.Context, cau string, lichSu []Tin, congCu []CongCu, congCuGhi []CongCuGhi) (KetQua, error) {
	var kq KetQua
	if strings.TrimSpace(cau) == "" || !utf8.ValidString(cau) || utf8.RuneCountInString(cau) > 500 {
		return kq, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "question"}
	}
	if len(lichSu) > 12 {
		return kq, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "history"}
	}
	for _, t := range lichSu {
		if (t.Vai != "user" && t.Vai != "assistant") || !utf8.ValidString(t.Chu) {
			return kq, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "history"}
		}
	}
	tenCongCu := make([]string, 0, len(congCu)+len(congCuGhi))
	for _, c := range congCu {
		tenCongCu = append(tenCongCu, c.Ten)
	}
	for _, c := range congCuGhi {
		tenCongCu = append(tenCongCu, c.Ten)
	}
	daCo := make(map[string]bool, len(tenCongCu))
	for _, ten := range tenCongCu {
		if daCo[ten] {
			return kq, fmt.Errorf("tên công cụ trùng: %s", ten)
		}
		daCo[ten] = true
	}
	suy := func(ma string) (KetQua, error) { kq.Chu = ""; kq.SuyGiam = ma; return kq, nil }
	if l.cauHinh.NhaCungCap == "tat" || l.cauHinh.NhaCungCap == "" {
		return suy("tat")
	}
	if l.cauHinh.NhaCungCap != "gia" || l.nha == nil || l.nha.Ma() != "gia" {
		return suy("loi_hang")
	}
	gv, gr, ok := l.nha.Gia()
	if !ok || gv < 0 || gr < 0 {
		return suy("loi_hang")
	}
	ctx, huy := context.WithTimeout(ctx, l.HanMoiLuot)
	defer huy()
	g := GoiModel{HeThong: HeThong, TranDauRa: 800, CongCu: tenCongCu}
	for _, t := range lichSu {
		g.LichSu = append(g.LichSu, Tin{Vai: t.Vai, Chu: anRieng(t.Chu)})
	}
	g.LichSu = append(g.LichSu, Tin{Vai: "user", Chu: anRieng(cau)})
	for lan := 0; lan < 4; lan++ {
		if ctx.Err() != nil {
			return suy("qua_han")
		}
		tien, ok := tinhTien(soByte(g), 800, gv, gr)
		if !ok || tien <= 0 {
			return suy("loi_hang")
		}
		id, err := l.giuCho(ctx, tien)
		if err != nil {
			var pg *pgconn.PgError
			if errors.Is(err, hetNganSach) || (errors.As(err, &pg) && (pg.ConstraintName == "model_call_month_budget_check" || pg.ConstraintName == "model_call_day_budget_check")) {
				return suy("het_ngan_sach")
			}
			if ctx.Err() != nil {
				return suy("qua_han")
			}
			return kq, err
		}
		lanCtx, dung := context.WithTimeout(ctx, l.HanMoiLan)
		ph, goiErr := l.nha.Goi(lanCtx, saoGoi(g))
		quaHan := lanCtx.Err() != nil
		dung()
		saiMuc := false
		if ph.BietMucDung {
			that, hopLe := tinhTien(ph.TokenVao, ph.TokenRa, gv, gr)
			if !hopLe || ph.TokenVao > math.MaxInt32 || ph.TokenRa > math.MaxInt32 {
				saiMuc = true
				ph.BietMucDung = false
			} else {
				tien = that
			}
		}
		if !ph.BietMucDung {
			ph.TokenVao = 0
			ph.TokenRa = 0
		}
		if err := l.chot(id, tien, ph); err != nil {
			return kq, err
		}
		if quaHan || ctx.Err() != nil {
			return suy("qua_han")
		}
		if goiErr != nil || saiMuc {
			return suy("loi_hang")
		}
		if ph.GoiCongCu == nil {
			kq.Chu = ph.Chu
			return kq, nil
		}
		if ph.Chu != "" || ph.GoiCongCu.Ten == "" || !json.Valid(ph.GoiCongCu.ThamSo) {
			return suy("loi_hang")
		}
		b := BuocCongCu{LoiGoi: *ph.GoiCongCu, Loi: "cong_cu_khong_co"}
		for _, c := range congCuGhi {
			if c.Ten != b.LoiGoi.Ten {
				continue
			}
			b.Loi = "loi_cong_cu"
			if c.DeXuat == nil || c.OperationID == "" {
				break
			}
			deXuat, e := c.DeXuat(ctx, append(json.RawMessage(nil), b.LoiGoi.ThamSo...))
			if e != nil || !laDoiTuongJSON(deXuat.Than) {
				break
			}
			if deXuat.ThamSoDuong == nil {
				deXuat.ThamSoDuong = json.RawMessage(`{}`)
			} else if !laDoiTuongJSON(deXuat.ThamSoDuong) {
				break
			}
			deXuat.CongCu = c.Ten
			deXuat.OperationID = c.OperationID
			kq.Chu = CauDeXuat
			kq.DeXuat = &deXuat
			kq.Nguon = []Nguon{{CongCu: c.Ten, DocLuc: time.Now()}}
			return kq, nil
		}
		if lan == 3 {
			return suy("qua_so_lan")
		}
		for _, c := range congCu {
			if c.Ten != b.LoiGoi.Ten {
				continue
			}
			if c.Chay == nil {
				b.Loi = "loi_cong_cu"
				break
			}
			ketQua, e := c.Chay(ctx, append(json.RawMessage(nil), b.LoiGoi.ThamSo...))
			if e != nil || !json.Valid(ketQua) {
				b.Loi = "loi_cong_cu"
			} else {
				b.Loi = ""
				b.KetQua = append(json.RawMessage(nil), ketQua...)
				kq.Nguon = append(kq.Nguon, Nguon{CongCu: c.Ten, DocLuc: time.Now()})
			}
			break
		}
		g.Buoc = append(g.Buoc, b)
	}
	return suy("qua_so_lan")
}
