package gia

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"

	"banhcuon/be/internal/apierr"
	"github.com/gin-gonic/gin"
)

// Routes đăng ký hai đường đọc không cần danh tính; mỗi yêu cầu đọc trong một giao dịch.
func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/price-quotes", h.tinhThu)
	r.GET("/menu", h.docMenu)
}

type handler struct{ svc *Service }

func (h handler) tinhThu(c *gin.Context) {
	w, r := c.Writer, c.Request
	var yc struct {
		Lines []DongYeuCau `json:"lines"`
	}
	dec := json.NewDecoder(r.Body)
	// Không DisallowUnknownFields: giá gửi lên và mọi trường lạ đều bị bỏ qua (I-013).
	if err := dec.Decode(&yc); err != nil {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	out, err := h.svc.TinhThu(r.Context(), yc.Lines)
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, out)
}

func (h handler) docMenu(c *gin.Context) {
	out, err := h.svc.DocMenu(c.Request.Context())
	if err != nil {
		writeErr(c.Writer, err)
		return
	}
	writeJSON(c.Writer, out)
}

// writeErr giữ lời từ chối có mã; lỗi hệ thống chỉ ghi log, không gửi câu database xuống dây.
func writeErr(w http.ResponseWriter, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(w, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("gia: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(w, e)
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(v)
}
