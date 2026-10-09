package sanxuat

import (
	_ "embed"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
)

var GhiLamSai = authz.Door{Code: "sanxuat/ghi_lam_sai", Need: authz.NeedCounter}
var HuyGhiLamSai = authz.Door{Code: "sanxuat/huy_ghi_lam_sai", Need: authz.NeedCounter}

//go:embed sql/ghi_lam_sai/them.sql
var themLamSai string

//go:embed sql/huy_ghi_lam_sai/huy.sql
var huyLamSai string

func (h handler) ghiLamSai(w http.ResponseWriter, r *http.Request) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(w, r, &raw) {
		return
	}
	var viecID int64
	if err := json.Unmarshal(raw["station_job_id"], &viecID); err != nil || viecID <= 0 {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "station_job_id"})
		return
	}
	var note *string
	if b, co := raw["note"]; co {
		if err := json.Unmarshal(b, &note); err != nil || note == nil || strings.TrimSpace(*note) == "" {
			apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "note"})
			return
		}
	}
	var id int64
	err := authz.Run(r.Context(), h.pool, h.person(r), GhiLamSai, func(tx pgx.Tx) error {
		ds, err := khoaTap(r.Context(), tx, []int64{viecID})
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
		return tx.QueryRow(r.Context(), themLamSai, viecID, v.DonID, note).Scan(&id)
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusCreated, map[string]any{"wrong_make_note_id": id, "station_job_id": viecID, "note": note})
}

func (h handler) huyGhiLamSai(w http.ResponseWriter, r *http.Request) {
	id, ok := apierr.ReadID(w, r, "id")
	if !ok {
		return
	}
	var moc json.RawMessage
	err := authz.Run(r.Context(), h.pool, h.person(r), HuyGhiLamSai, func(tx pgx.Tx) error {
		var daHuy bool
		if err := tx.QueryRow(r.Context(), `SELECT cancelled_at IS NOT NULL FROM wrong_make_note WHERE id = $1 FOR UPDATE`, id).Scan(&daHuy); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeWrongMakeNoteNotFound}
			}
			return err
		}
		if daHuy {
			return apierr.Error{Code: apierr.CodeWrongMakeNoteAlreadyCancelled}
		}
		return vongdoi.CoVet(r.Context(), tx, HuyGhiLamSai.Code, func() error {
			return tx.QueryRow(r.Context(), huyLamSai, id).Scan(&moc)
		})
	})
	if err != nil {
		apierr.WriteError(w, err)
		return
	}
	apierr.JSON(w, http.StatusOK, map[string]any{"wrong_make_note_id": id, "cancelled_at": moc})
}
