package sanxuat

import (
	_ "embed"
	"encoding/json"
	"errors"
	"net/http"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var BamMe = authz.Door{Code: "sanxuat/bam_me", Need: authz.NeedCounter}
var LuiMe = authz.Door{Code: "sanxuat/lui_me", Need: authz.NeedCounter}

//go:embed sql/bam_me/them.sql
var themMe string

//go:embed sql/bam_me/them_phan.sql
var themPhan string

//go:embed sql/lui_me/lui.sql
var luiMe string

//go:embed sql/lui_me/lui_phan.sql
var luiPhan string

func (h handler) bamMe(w http.ResponseWriter, r *http.Request) {
	ids, ok := docTap(w, r)
	if !ok {
		return
	}
	var id int64
	var moc json.RawMessage
	err := authz.Run(r.Context(), h.pool, h.person(r), BamMe, func(tx pgx.Tx) error {
		ds, err := khoaTap(r.Context(), tx, ids)
		if err != nil {
			return err
		}
		for _, v := range ds {
			if v.TrangThai != "pending" || v.TrangThaiDon == "cancelled" {
				return apierr.Error{Code: apierr.CodeStationJobTransitionNotAllowed}
			}
		}
		if err := tx.QueryRow(r.Context(), themMe).Scan(&id, &moc); err != nil {
			return err
		}
		if _, err := tx.Exec(r.Context(), themPhan, id, ids); err != nil {
			return err
		}
		for _, v := range ds {
			if err := vongdoi.ChuyenViec(r.Context(), tx, v.ID, "made"); err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusCreated, map[string]any{"production_batch_id": id, "made_at": moc, "station_job_ids": ids})
}

func (h handler) luiMe(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "id")
	if !ok {
		return
	}
	ids := []int64{}
	var moc json.RawMessage
	err := authz.Run(r.Context(), h.pool, h.person(r), LuiMe, func(tx pgx.Tx) error {
		var daLui bool
		if err := tx.QueryRow(r.Context(), `SELECT is_rolled_back FROM production_batch WHERE id = $1 FOR UPDATE`, id).Scan(&daLui); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeProductionBatchNotFound}
			}
			return err
		}
		if daLui {
			return apierr.Error{Code: apierr.CodeProductionBatchAlreadyRolledBack}
		}
		rows, err := tx.Query(r.Context(), `SELECT station_job_id FROM production_batch_item WHERE production_batch_id = $1 ORDER BY station_job_id`, id)
		if err != nil {
			return err
		}
		ids, err = pgx.CollectRows(rows, pgx.RowTo[int64])
		if err != nil {
			return err
		}
		ds, err := khoaTap(r.Context(), tx, ids)
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
		return vongdoi.CoVet(r.Context(), tx, LuiMe.Code, func() error {
			if err := tx.QueryRow(r.Context(), luiMe, id).Scan(&moc); err != nil {
				return err
			}
			if _, err := tx.Exec(r.Context(), luiPhan, id); err != nil {
				return err
			}
			for _, v := range ds {
				if err := vongdoi.LuiViecCuaMe(r.Context(), tx, v.ID); err != nil {
					return err
				}
			}
			return nil
		})
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"production_batch_id": id, "rolled_back_at": moc, "station_job_ids": ids})
}
