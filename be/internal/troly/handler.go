package troly

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

// Routes đăng ký đường hỏi chỉ đọc, chọn công cụ theo phiên người làm.
func Routes(r *gin.Engine, lop *Lop, menu *gia.Service, noiBo *NguonNoiBo) {
	r.POST("/chat/turns", func(c *gin.Context) {
		invalid := func(field string) {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
		}
		var body map[string]json.RawMessage
		dec := json.NewDecoder(c.Request.Body)
		if err := dec.Decode(&body); err != nil {
			invalid("")
			return
		}
		if err := dec.Decode(new(any)); err != io.EOF {
			invalid("")
			return
		}
		var question *string
		if err := json.Unmarshal(body["question"], &question); err != nil || question == nil {
			invalid("question")
			return
		}
		var history []Tin
		if raw, ok := body["history"]; ok {
			var items []struct {
				Role *string `json:"role"`
				Text *string `json:"text"`
			}
			if err := json.Unmarshal(raw, &items); err != nil || items == nil {
				invalid("history")
				return
			}
			for _, item := range items {
				if item.Role == nil || item.Text == nil {
					invalid("history")
					return
				}
				history = append(history, Tin{Vai: *item.Role, Chu: *item.Text})
			}
		}
		nguoi, _ := middleware.Nguoi(c)
		congCu, err := noiBo.CongCu(c.Request.Context(), nguoi, menu)
		var result KetQua
		if err == nil {
			result, err = lop.Luot(c.Request.Context(), *question, history, congCu)
		}
		if err != nil {
			var e apierr.Error
			if !errors.As(err, &e) {
				e = apierr.Error{Code: apierr.CodeInternalError}
			}
			apierr.Write(c.Writer, e)
			return
		}
		type source struct {
			Tool   string `json:"tool"`
			ReadAt string `json:"read_at"`
		}
		out := struct {
			Answer         *string  `json:"answer"`
			Sources        []source `json:"sources"`
			DegradedReason *string  `json:"degraded_reason"`
		}{Sources: make([]source, 0, len(result.Nguon))}
		if result.SuyGiam != "" {
			out.DegradedReason = &result.SuyGiam
		} else {
			out.Answer = &result.Chu
		}
		for _, s := range result.Nguon {
			out.Sources = append(out.Sources, source{Tool: s.CongCu, ReadAt: s.DocLuc.Format(time.RFC3339Nano)})
		}
		c.JSON(http.StatusOK, out)
	})
}
