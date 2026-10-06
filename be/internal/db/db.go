// Package db giữ cấu hình kết nối và ranh giới giao dịch của backend.
package db

import (
	"context"
	"errors"
	"fmt"

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
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)
	if err := fn(tx); err != nil {
		return err
	}
	return tx.Commit(ctx)
}
