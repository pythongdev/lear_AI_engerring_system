package sanxuat

import (
	"encoding/json"
	"net/http"
	"slices"
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/production-batches", h.bamMe)
	r.POST("/production-batches/:id/rollback", h.luiMe)
	r.POST("/served-marks", h.raBan)
	r.POST("/station-job-transfers", h.chuyen)
	r.POST("/wrong-make-notes", h.ghiLamSai)
	r.POST("/wrong-make-notes/:id/cancellation", h.huyGhiLamSai)
	r.GET("/production-board", h.bang)
	r.GET("/station-jobs/:id/transfer-candidates", h.ungVien)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 {
	id, _ := middleware.Nguoi(c)
	return id
}

// docID giữ lời từ chối của apierr.ReadID: không phải số nguyên dương ⇒ 400, field là tên tham số.
func docID(c *gin.Context) (int64, bool) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "id"})
		return 0, false
	}
	return id, true
}

// Đọc tập quầy chọn, không suy ra từ bàn hoặc mẻ; null cũng không phải một mã.
func docTap(c *gin.Context) ([]int64, bool) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(c.Writer, c.Request, &raw) {
		return nil, false
	}
	var ids []int64
	err := json.Unmarshal(raw["station_job_ids"], &ids)
	seen := make(map[int64]bool)
	hop := err == nil && len(ids) > 0
	for _, id := range ids {
		if id <= 0 || seen[id] {
			hop = false
		}
		seen[id] = true
	}
	if !hop {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "station_job_ids"})
		return nil, false
	}
	return ids, true
}

func (h handler) bamMe(c *gin.Context) {
	ids, ok := docTap(c)
	if !ok {
		return
	}
	id, moc, err := h.svc.BamMe(c.Request.Context(), nguoi(c), ids)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"production_batch_id": id, "made_at": moc, "station_job_ids": ids})
}

func (h handler) luiMe(c *gin.Context) {
	id, ok := docID(c)
	if !ok {
		return
	}
	ids, moc, err := h.svc.LuiMe(c.Request.Context(), nguoi(c), id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"production_batch_id": id, "rolled_back_at": moc, "station_job_ids": ids})
}

// docRa đọc lời S-5 (chủ quán 2026-10-09): số cái từng thứ cho MỘT bàn, hoặc một đơn không bàn.
func docRa(c *gin.Context) (yeuCauRa, bool) {
	var yc yeuCauRa
	if !apierr.ReadJSON(c.Writer, c.Request, &yc) {
		return yc, false
	}
	if (yc.DiningTableID == nil) == (yc.SalesOrderID == nil) ||
		(yc.DiningTableID != nil && *yc.DiningTableID <= 0) || (yc.SalesOrderID != nil && *yc.SalesOrderID <= 0) {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return yc, false
	}
	hop := len(yc.Items) > 0
	daCo := make(map[string]bool)
	for i := range yc.Items {
		m := &yc.Items[i]
		if m.FillingOptionIDs == nil {
			m.FillingOptionIDs = []int64{}
		}
		slices.Sort(m.FillingOptionIDs)
		khoa, _ := json.Marshal([]any{m.StationCode, m.MenuComponentID, m.FillingOptionIDs})
		if m.StationCode == "" || m.Quantity <= 0 || daCo[string(khoa)] || !m.coThanhPhan || !m.coNhan ||
			len(slices.Compact(slices.Clone(m.FillingOptionIDs))) != len(m.FillingOptionIDs) {
			hop = false
		}
		daCo[string(khoa)] = true
	}
	if !hop {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "items"})
		return yc, false
	}
	return yc, true
}

func (h handler) raBan(c *gin.Context) {
	yc, ok := docRa(c)
	if !ok {
		return
	}
	daRa, xong, err := h.svc.RaBan(c.Request.Context(), nguoi(c), yc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"station_job_ids": daRa, "completed_order_ids": xong})
}

func (h handler) chuyen(c *gin.Context) {
	var yc struct {
		Transfers []capChuyen `json:"transfers"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &yc) {
		return
	}
	if len(yc.Transfers) == 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "transfers"})
		return
	}
	for _, cap := range yc.Transfers {
		if cap.From <= 0 || cap.To <= 0 {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "transfers"})
			return
		}
	}
	out, err := h.svc.Chuyen(c.Request.Context(), nguoi(c), yc.Transfers)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"station_job_transfer_ids": out})
}

func (h handler) ghiLamSai(c *gin.Context) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(c.Writer, c.Request, &raw) {
		return
	}
	var viecID int64
	if err := json.Unmarshal(raw["station_job_id"], &viecID); err != nil || viecID <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "station_job_id"})
		return
	}
	var note *string
	if b, co := raw["note"]; co {
		if err := json.Unmarshal(b, &note); err != nil || note == nil || strings.TrimSpace(*note) == "" {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "note"})
			return
		}
	}
	id, err := h.svc.GhiLamSai(c.Request.Context(), nguoi(c), viecID, note)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"wrong_make_note_id": id, "station_job_id": viecID, "note": note})
}

func (h handler) huyGhiLamSai(c *gin.Context) {
	id, ok := docID(c)
	if !ok {
		return
	}
	moc, err := h.svc.HuyGhiLamSai(c.Request.Context(), nguoi(c), id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"wrong_make_note_id": id, "cancelled_at": moc})
}

func (h handler) bang(c *gin.Context) {
	out, err := h.svc.DocGom(c.Request.Context(), c.Request.URL.Query().Get("station_code"), nil)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, out)
}

func (h handler) ungVien(c *gin.Context) {
	id, ok := docID(c)
	if !ok {
		return
	}
	out, err := h.svc.DocGom(c.Request.Context(), "", &id)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, out)
}
