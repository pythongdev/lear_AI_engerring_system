package middleware

import (
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/platform/realtime"
	"github.com/gin-gonic/gin"
)

func Realtime(b *realtime.Broker) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Request = c.Request.WithContext(postgres.WithNotifications(c.Request.Context(), b.Publish))
		c.Next()
	}
}
