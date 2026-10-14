package testhelper

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/jackc/pgx/v5"
)

// sessionSQL (testdata/session.sql — SQL dựng test được Gate 1f miễn) tạo, nếu chưa có, tài khoản hoạt động cho một
// người và mở một phiên 7 ngày, bằng kết nối owner của database test, không qua cửa nào. Một câu nên tự nguyên tử;
// khoá tư vấn theo kết nối giữ hai lời gọi cùng người không giành nhau tạo tài khoản. Không mở giao dịch (QC-13).
func sessionSQL() (string, error) {
	_, self, _, _ := runtime.Caller(0)
	b, err := os.ReadFile(filepath.Join(filepath.Dir(self), "testdata", "session.sql"))
	return string(b), err
}

func SessionToken(ctx context.Context, person int64) (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	hash := sha256.Sum256([]byte(token))
	conn, err := pgx.Connect(ctx, os.Getenv("BANHCUON_TEST_OWNER_DSN"))
	if err != nil {
		return "", err
	}
	defer conn.Close(ctx)
	if _, err := conn.Exec(ctx, "SELECT pg_advisory_lock($1)", person); err != nil {
		return "", err
	}
	q, err := sessionSQL()
	if err != nil {
		return "", err
	}
	_, err = conn.Exec(ctx, q, person, hash[:])
	return token, err
}

// Session trả mã phiên thật (cookie banhcuon_phien) cho một người — thay header chọn tên đã gỡ (T-190).
func Session(t testing.TB, person int64) string {
	t.Helper()
	token, err := SessionToken(context.Background(), person)
	if err != nil {
		t.Fatal(err)
	}
	return token
}
