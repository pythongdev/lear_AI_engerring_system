package sanxuat

import (
	_ "embed"
	"errors"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var Chuyen = authz.Door{Code: "sanxuat/chuyen", Need: authz.NeedCounter}

//go:embed sql/chuyen/them.sql
var themChuyen string

//go:embed sql/chuyen/doi_chu.sql
var doiChu string

func (h handler) chuyen(w http.ResponseWriter, r *http.Request) {
	var yc struct {
		Transfers []struct {
			From int64 `json:"from_station_job_id"`
			To   int64 `json:"to_station_job_id"`
		} `json:"transfers"`
	}
	if !apierr.ReadJSON(w, r, &yc) {
		return
	}
	if len(yc.Transfers) == 0 {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "transfers"})
		return
	}
	ids := make([]int64, 0, len(yc.Transfers)*2)
	for _, cap := range yc.Transfers {
		if cap.From <= 0 || cap.To <= 0 {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "transfers"})
			return
		}
		ids = append(ids, cap.From, cap.To)
	}
	out := []int64{}
	err := authz.Run(r.Context(), h.pool, h.person(r), Chuyen, func(tx pgx.Tx) error {
		if err := khoaMeNguon(r.Context(), tx, ids); err != nil {
			return err
		}
		ds, err := khoaTap(r.Context(), tx, ids)
		if err != nil {
			return err
		}
		viecTheoID := make(map[int64]viec)
		for _, v := range ds {
			viecTheoID[v.ID] = v
		}
		for _, cap := range yc.Transfers {
			nguon, dich := viecTheoID[cap.From], viecTheoID[cap.To]
			if nguon.TrangThaiDon != "cancelled" || nguon.TrangThai != "made" { // ADR-090 điểm 3: chỉ đã làm xong rời qua đổi chủ
				return apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
			}
			if nguon.LamSai {
				return apierr.Error{Code: apierr.CodeStationJobHasWrongMakeNote}
			}
			var vat int64
			if err := tx.QueryRow(r.Context(), `SELECT id FROM production_batch_item WHERE live_station_job_id = $1 FOR UPDATE`, nguon.ID).Scan(&vat); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeTransferSourceNotAvailable}
				}
				return err
			}
			if dich.ID == nguon.ID || dich.TrangThai != "pending" || dich.TrangThaiDon != "in_progress" {
				return apierr.Error{Code: apierr.CodeTransferTargetNotWaiting}
			}
			// Quầy chọn đích; chỉ đường đọc ứng viên so khoá gom (I-004 tầng 4).
			var lan int64
			if err := tx.QueryRow(r.Context(), themChuyen, vat, nguon.ID, dich.ID).Scan(&lan); err != nil {
				return err
			}
			if err := vongdoi.CoVet(r.Context(), tx, Chuyen.Code, func() error {
				_, err := tx.Exec(r.Context(), doiChu, vat, dich.ID)
				return err
			}); err != nil {
				return err
			}
			if err := vongdoi.NhaNguonChuyen(r.Context(), tx, nguon.ID, lan); err != nil {
				return err
			}
			if err := vongdoi.ChuyenViec(r.Context(), tx, dich.ID, "made"); err != nil {
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
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusCreated, map[string]any{"station_job_transfer_ids": out})
}
