package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type notificationKey struct{}
type writeKey struct{}

// WithNotifications nối bộ phát của tiến trình vào mọi cửa trong lượt HTTP.
func WithNotifications(ctx context.Context, publish func(time.Time)) context.Context {
	return context.WithValue(ctx, notificationKey{}, publish)
}
func WriteContext(ctx context.Context) context.Context {
	return context.WithValue(ctx, writeKey{}, true)
}
func ReadTime(ctx context.Context, pool *pgxpool.Pool) (time.Time, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	var at time.Time
	err := pool.QueryRow(ctx, "SELECT now()").Scan(&at)
	return at, err
}
