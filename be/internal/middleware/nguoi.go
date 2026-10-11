// Package middleware gắn người vào ngữ cảnh HTTP, không kiểm quyền và không thay
// authz.Run: quyền được kiểm trong giao dịch của cửa (ADR-085).
package middleware

import (
	"banhcuon/be/internal/authz"
	"github.com/gin-gonic/gin"
)

const khoaNguoi = "banhcuon.middleware.nguoi"

func GanNguoi(auth authz.Authenticator) gin.HandlerFunc {
	return func(c *gin.Context) {
		if id, ok := auth.PersonID(c.Request); ok {
			c.Set(khoaNguoi, id)
		}
		c.Next()
	}
}

func Nguoi(c *gin.Context) (int64, bool) {
	value, _ := c.Get(khoaNguoi)
	id, ok := value.(int64)
	return id, ok
}
