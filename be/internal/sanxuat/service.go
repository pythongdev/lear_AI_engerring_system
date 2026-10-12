// Package sanxuat giữ các cửa sản xuất của quầy; trạm bếp chỉ đọc.
package sanxuat

import (
	"context"
	"encoding/json"
	"errors"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var BamMe = authz.Door{Code: "sanxuat/bam_me", Need: authz.NeedCounter}
var LuiMe = authz.Door{Code: "sanxuat/lui_me", Need: authz.NeedCounter}
var RaBan = authz.Door{Code: "sanxuat/ra_ban", Need: authz.NeedCounter}
var Chuyen = authz.Door{Code: "sanxuat/chuyen", Need: authz.NeedCounter}
var GhiLamSai = authz.Door{Code: "sanxuat/ghi_lam_sai", Need: authz.NeedCounter}
var HuyGhiLamSai = authz.Door{Code: "sanxuat/huy_ghi_lam_sai", Need: authz.NeedCounter}
var CuaNoDon = authz.Door{Code: "sanxuat/no_don", Need: authz.NeedCallingDoor}

type viec struct {
	ID           int64
	DonID        int64
	PhienID      *int64
	TrangThai    string
	TrangThaiDon string
	LamSai       bool
}

type mucRa struct {
	StationCode      string  `json:"station_code"`
	MenuComponentID  *int64  `json:"menu_component_id"`
	FillingOptionIDs []int64 `json:"filling_option_ids"`
	Quantity         int64   `json:"quantity"`
	// Hợp đồng đòi cả hai trường (menu_component_id được null — nước chấm; filling_option_ids không null).
	// Thiếu trường không được đọc thành nước chấm (T-144, duyệt độc lập phần S-5).
	coThanhPhan, coNhan bool
}

func (m *mucRa) UnmarshalJSON(b []byte) error {
	type tho mucRa
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(b, &raw); err != nil {
		return err
	}
	var x tho
	if err := json.Unmarshal(b, &x); err != nil {
		return err
	}
	*m = mucRa(x)
	_, m.coThanhPhan = raw["menu_component_id"]
	nhan, co := raw["filling_option_ids"]
	m.coNhan = co && string(nhan) != "null"
	return nil
}

type yeuCauRa struct {
	DiningTableID *int64  `json:"dining_table_id"`
	SalesOrderID  *int64  `json:"sales_order_id"`
	Items         []mucRa `json:"items"`
}

type capChuyen struct {
	From int64 `json:"from_station_job_id"`
	To   int64 `json:"to_station_job_id"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

// Mọi cửa khoá phiên trước đơn, rồi các đơn vị theo id. Chủ của station_job
// không đổi; lần chuyển chỉ đổi chủ của production_batch_item.
func khoaTap(ctx context.Context, repo repository, ids []int64) ([]viec, error) {
	if err := repo.khoaPhienCuaViec(ctx, ids); err != nil {
		return nil, err
	}
	if err := repo.khoaDonCuaViec(ctx, ids); err != nil {
		return nil, err
	}
	out, err := repo.khoaViec(ctx, ids)
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

// NoDon chạy sau khi cửa gọi đã ghi đủ dòng và khoá phiên trước đơn.
func NoDon(ctx context.Context, tx pgx.Tx, id int64) error {
	if err := vongdoi.ChuyenDon(ctx, tx, id, "in_progress"); err != nil {
		return err
	}
	if err := vongdoi.KiemChuyenViec("", "pending"); err != nil {
		return err
	}
	repo := newRepository(tx)
	if err := repo.noThanhPhan(ctx, id); err != nil {
		return err
	}
	return repo.noNuocCham(ctx, id)
}

// DocGom đọc bảng nhu cầu (nguon nil, lọc theo trạm nếu có) hoặc ứng viên chuyển của nguon.
func (s *Service) DocGom(ctx context.Context, tram string, nguon *int64) (json.RawMessage, error) {
	var out json.RawMessage
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		co, hop, ketQua, err := newRepository(tx).gom(ctx, tram, nguon)
		if err != nil {
			return err
		}
		if nguon != nil {
			if !co {
				return apierr.Error{Code: apierr.CodeStationJobNotFound}
			}
			if !hop {
				return apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
			}
		}
		out = ketQua
		return nil
	})
	return out, err
}

func (s *Service) BamMe(ctx context.Context, nguoi int64, ids []int64) (id int64, moc json.RawMessage, err error) {
	err = authz.Run(ctx, s.pool, nguoi, BamMe, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		ds, err := khoaTap(ctx, repo, ids)
		if err != nil {
			return err
		}
		for _, v := range ds {
			if v.TrangThai != "pending" || v.TrangThaiDon == "cancelled" {
				return apierr.Error{Code: apierr.CodeStationJobTransitionNotAllowed}
			}
		}
		if id, moc, err = repo.themMe(ctx); err != nil {
			return err
		}
		if err := repo.themPhanMe(ctx, id, ids); err != nil {
			return err
		}
		for _, v := range ds {
			if err := vongdoi.ChuyenViec(ctx, tx, v.ID, "made"); err != nil {
				return err
			}
		}
		return nil
	})
	return id, moc, err
}

func (s *Service) LuiMe(ctx context.Context, nguoi int64, id int64) (ids []int64, moc json.RawMessage, err error) {
	ids = []int64{}
	err = authz.Run(ctx, s.pool, nguoi, LuiMe, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		daLui, err := repo.khoaMe(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeProductionBatchNotFound}
			}
			return err
		}
		if daLui {
			return apierr.Error{Code: apierr.CodeProductionBatchAlreadyRolledBack}
		}
		if ids, err = repo.viecCuaMe(ctx, id); err != nil {
			return err
		}
		ds, err := khoaTap(ctx, repo, ids)
		if err != nil {
			return err
		}
		for _, v := range ds {
			if v.TrangThai == "served" {
				return apierr.Error{Code: apierr.CodeProductionBatchHasServedUnits}
			}
		}
		for _, v := range ds {
			if v.LamSai {
				return apierr.Error{Code: apierr.CodeStationJobHasWrongMakeNote}
			}
		}
		return vongdoi.CoVet(ctx, tx, LuiMe.Code, func() error {
			if moc, err = repo.luiMe(ctx, id); err != nil {
				return err
			}
			if err := repo.luiPhanMe(ctx, id); err != nil {
				return err
			}
			for _, v := range ds {
				if err := vongdoi.LuiViecCuaMe(ctx, tx, v.ID); err != nil {
					return err
				}
			}
			return nil
		})
	})
	return ids, moc, err
}

// donCuaPhan: các đơn Đang thực hiện của phần quầy chọn, đã khoá. Không suy ra phần từ mẻ hay từ món.
func donCuaPhan(ctx context.Context, repo repository, yc yeuCauRa) ([]int64, error) {
	var ids []int64
	if yc.DiningTableID != nil {
		co, err := repo.coBan(ctx, *yc.DiningTableID)
		if err != nil {
			return nil, err
		}
		if !co {
			return nil, apierr.Error{Code: apierr.CodeDiningTableNotFound}
		}
		if ids, err = repo.donDangLamCuaBan(ctx, *yc.DiningTableID); err != nil {
			return nil, err
		}
	} else {
		ban, err := repo.banCuaDon(ctx, *yc.SalesOrderID)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apierr.Error{Code: apierr.CodeSalesOrderNotFound}
		}
		if err != nil {
			return nil, err
		}
		if ban != nil {
			// Đơn có bàn thì phần của nó là bàn: bấm theo bàn, không theo đơn.
			return nil, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sales_order_id"}
		}
		ids = []int64{*yc.SalesOrderID}
	}
	if err := repo.khoaPhienCuaDon(ctx, ids); err != nil {
		return nil, err
	}
	// đơn vừa rời Đang thực hiện trước lúc khoá thì không còn cái nào để bưng
	return repo.khoaDonDangLam(ctx, ids)
}

func (s *Service) RaBan(ctx context.Context, nguoi int64, yc yeuCauRa) (daRa, xong []int64, err error) {
	daRa, xong = []int64{}, []int64{}
	err = authz.Run(ctx, s.pool, nguoi, RaBan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		dons, err := donCuaPhan(ctx, repo, yc)
		if err != nil {
			return err
		}
		for _, m := range yc.Items {
			ids, err := repo.chonDaLam(ctx, dons, m)
			if err != nil {
				return err
			}
			if int64(len(ids)) < m.Quantity {
				return apierr.Error{Code: apierr.CodeServedQuantityExceedsMade}
			}
			daRa = append(daRa, ids...)
		}
		ds, err := khoaTap(ctx, repo, daRa)
		if err != nil {
			return err
		}
		for _, v := range ds {
			// Đơn đã khoá trước khi chọn nên cái đã chọn còn ở made; kiểm lại sau khoá việc cho chắc.
			if v.TrangThai != "made" {
				return apierr.Error{Code: apierr.CodeServedQuantityExceedsMade}
			}
		}
		for _, v := range ds {
			if err := vongdoi.ChuyenViec(ctx, tx, v.ID, "served"); err != nil {
				return err
			}
		}
		daXet := make(map[int64]bool)
		for _, v := range ds {
			if v.PhienID == nil || daXet[v.DonID] {
				continue
			}
			daXet[v.DonID] = true
			het, err := repo.daRaHet(ctx, v.DonID)
			if err != nil {
				return err
			}
			if het {
				if err := vongdoi.ChuyenDon(ctx, tx, v.DonID, "completed"); err != nil {
					return err
				}
				xong = append(xong, v.DonID)
			}
		}
		return nil
	})
	return daRa, xong, err
}

// Chuyen: caps đã qua kiểm hình ở handler (mỗi cặp hai mã dương, ít nhất một cặp).
func (s *Service) Chuyen(ctx context.Context, nguoi int64, caps []capChuyen) ([]int64, error) {
	ids := make([]int64, 0, len(caps)*2)
	for _, cap := range caps {
		ids = append(ids, cap.From, cap.To)
	}
	out := []int64{}
	err := authz.Run(ctx, s.pool, nguoi, Chuyen, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		// Mẻ được khoá trước phiên/đơn/việc ở cả lùi và chuyển. Nhờ vậy chủ hiện tại
		// đọc sau khoá mẻ không đổi trong lúc lùi; không khoá vật trước rồi chờ việc.
		if err := repo.khoaMeNguon(ctx, ids); err != nil {
			return err
		}
		ds, err := khoaTap(ctx, repo, ids)
		if err != nil {
			return err
		}
		viecTheoID := make(map[int64]viec)
		for _, v := range ds {
			viecTheoID[v.ID] = v
		}
		for _, cap := range caps {
			nguon, dich := viecTheoID[cap.From], viecTheoID[cap.To]
			if nguon.TrangThaiDon != "cancelled" || nguon.TrangThai != "made" { // ADR-090 điểm 3: chỉ đã làm xong rời qua đổi chủ
				return apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
			}
			if nguon.LamSai {
				return apierr.Error{Code: apierr.CodeStationJobHasWrongMakeNote}
			}
			vat, err := repo.khoaPhanSong(ctx, nguon.ID)
			if err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
				}
				return err
			}
			if dich.ID == nguon.ID || dich.TrangThai != "pending" || dich.TrangThaiDon != "in_progress" {
				return apierr.Error{Code: apierr.CodeTransferTargetNotWaiting}
			}
			// Quầy chọn đích; chỉ đường đọc ứng viên so khoá gom (I-004 tầng 4).
			lan, err := repo.themChuyen(ctx, vat, nguon.ID, dich.ID)
			if err != nil {
				return err
			}
			if err := vongdoi.CoVet(ctx, tx, Chuyen.Code, func() error {
				return repo.doiChu(ctx, vat, dich.ID)
			}); err != nil {
				return err
			}
			if err := vongdoi.NhaNguonChuyen(ctx, tx, nguon.ID, lan); err != nil {
				return err
			}
			if err := vongdoi.ChuyenViec(ctx, tx, dich.ID, "made"); err != nil {
				return err
			}
			nguon.TrangThai = "pending"
			dich.TrangThai = "made"
			viecTheoID[nguon.ID] = nguon
			viecTheoID[dich.ID] = dich
			out = append(out, lan)
		}
		return nil
	})
	return out, err
}

func (s *Service) GhiLamSai(ctx context.Context, nguoi int64, viecID int64, note *string) (id int64, err error) {
	err = authz.Run(ctx, s.pool, nguoi, GhiLamSai, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		ds, err := khoaTap(ctx, repo, []int64{viecID})
		if err != nil {
			return err
		}
		v := ds[0]
		if v.TrangThaiDon != "cancelled" || (v.TrangThai != "made" && v.TrangThai != "served") {
			return apierr.Error{Code: apierr.CodeWrongMakeNoteNotAllowed}
		}
		if v.LamSai {
			return apierr.Error{Code: apierr.CodeStationJobHasWrongMakeNote}
		}
		id, err = repo.themLamSai(ctx, viecID, v.DonID, note)
		return err
	})
	return id, err
}

func (s *Service) HuyGhiLamSai(ctx context.Context, nguoi int64, id int64) (moc json.RawMessage, err error) {
	err = authz.Run(ctx, s.pool, nguoi, HuyGhiLamSai, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		daHuy, err := repo.khoaGhiLamSai(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeWrongMakeNoteNotFound}
			}
			return err
		}
		if daHuy {
			return apierr.Error{Code: apierr.CodeWrongMakeNoteAlreadyCancelled}
		}
		return vongdoi.CoVet(ctx, tx, HuyGhiLamSai.Code, func() error {
			moc, err = repo.huyLamSai(ctx, id)
			return err
		})
	})
	return moc, err
}
