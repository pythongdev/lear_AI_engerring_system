package qr

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/qr-codes/:code", h.banCuaKhach)
	r.POST("/dining-tables/:dining_table_id/qr-code", h.doiMa)
}

type handler struct{ svc *Service }

// Khách mang mã, không mang bàn; kiểm định danh bàn trước khi tra mã.
func (h handler) banCuaKhach(c *gin.Context) {
	if c.Request.URL.Query().Has("dining_table_id") {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return
	}
	seat, err := h.svc.BanCuaKhach(c.Request.Context(), c.Param("code"))
	if err != nil {
		writeErr(c.Writer, err)
		return
	}
	writeJSON(c.Writer, http.StatusOK, map[string]any{"label": seat.Label})
}

func (h handler) doiMa(c *gin.Context) {
	banID, err := strconv.ParseInt(c.Param("dining_table_id"), 10, 64)
	if err != nil || banID <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
		return
	}
	nguoi, _ := middleware.Nguoi(c)
	out, err := h.svc.DoiMa(c.Request.Context(), nguoi, banID)
	if err != nil {
		writeErr(c.Writer, err)
		return
	}
	writeJSON(c.Writer, http.StatusCreated, out)
}

// writeErr: lời từ chối có mã đi thẳng; lỗi của database dịch qua TÊN (ADR-082 điểm 5), tên được
// ghi lại, câu nguyên văn không tới người dùng.
func writeErr(w http.ResponseWriter, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(w, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("qr: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(w, e)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
