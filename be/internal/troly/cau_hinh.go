// Package troly chứa hợp đồng gọi model cục bộ theo ADR-139.
package troly

import (
	"fmt"
	"strconv"
)

type CauHinh struct {
	NhaCungCap        string
	TranThangMicroUSD int64
}

func DocCauHinh(getenv func(string) string) (CauHinh, error) {
	c := CauHinh{NhaCungCap: getenv("CHAT_MODEL_PROVIDER"), TranThangMicroUSD: 10_000_000}
	if c.NhaCungCap == "" {
		c.NhaCungCap = "tat"
	}
	if c.NhaCungCap != "tat" && c.NhaCungCap != "gia" {
		return CauHinh{}, fmt.Errorf("CHAT_MODEL_PROVIDER chỉ nhận tat hoặc gia")
	}
	if raw := getenv("CHAT_BUDGET_MONTHLY_MICROUSD"); raw != "" {
		v, err := strconv.ParseInt(raw, 10, 64)
		if err != nil || v <= 0 || v > 10_000_000 {
			return CauHinh{}, fmt.Errorf("CHAT_BUDGET_MONTHLY_MICROUSD phải là số nguyên từ 1 đến 10000000")
		}
		c.TranThangMicroUSD = v
	}
	return c, nil
}
