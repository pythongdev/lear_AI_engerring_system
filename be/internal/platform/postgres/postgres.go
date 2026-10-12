// Package postgres giữ cấu hình kết nối và ranh giới giao dịch của backend.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func Open(ctx context.Context, dsn, shopTZ string) (*pgxpool.Pool, error) {
	if shopTZ == "" {
		return nil, errors.New("múi giờ quán không được rỗng")
	}
	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, err
	}
	cfg.ConnConfig.RuntimeParams["timezone"] = shopTZ
	cfg.AfterConnect = func(ctx context.Context, conn *pgx.Conn) error {
		var role string
		var super bool
		if err := conn.QueryRow(ctx, "SELECT current_user, rolsuper FROM pg_roles WHERE rolname = current_user").Scan(&role, &super); err != nil {
			return err
		}
		if role != "shop_app" || super {
			return fmt.Errorf("backend cần shop_app không superuser, nhận %s (superuser=%t)", role, super)
		}
		return nil
	}
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	return pool, nil
}

// InTx là ranh giới giao dịch mở ở cửa (ADR-082 điểm 2).
func InTx(ctx context.Context, pool *pgxpool.Pool, fn func(pgx.Tx) error) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)
	deadline, _ := ctx.Deadline()
	if err := fn(boundedTx{Tx: tx, deadline: deadline}); err != nil {
		return err
	}
	var at time.Time
	publish, _ := ctx.Value(notificationKey{}).(func(time.Time))
	writing, _ := ctx.Value(writeKey{}).(bool)
	if writing && publish != nil {
		if err := tx.QueryRow(ctx, "SELECT now()").Scan(&at); err != nil {
			return err
		}
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}
	if writing && publish != nil {
		publish(at)
	}
	return nil
}
