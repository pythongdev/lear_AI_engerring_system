package middleware

import (
	"banhcuon/be/internal/apierr"
	"github.com/gin-gonic/gin"
	"net/http"
)

func CungNguon(origin string) gin.HandlerFunc {
	return func(c *gin.Context) {
		switch c.Request.Method {
		case http.MethodGet, http.MethodHead, http.MethodOptions:
		default:
			if sent := c.GetHeader("Origin"); sent != "" && sent != origin {
				apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeCrossOriginWrite})
				c.Abort()
				return
			}
		}
		c.Next()
	}
}
