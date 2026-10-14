package taikhoan

import (
	"banhcuon/be/internal/apierr"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"golang.org/x/crypto/argon2"
	"strings"
	"unicode/utf8"
)

const passwordMemory uint32 = 64 * 1024

func hashPassword(password string) (string, error) {
	if utf8.RuneCountInString(password) < 8 {
		return "", apierr.Error{Code: apierr.CodePasswordTooShort}
	}
	salt := make([]byte, 16)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	hash := argon2.IDKey([]byte(password), salt, 3, passwordMemory, 1, 32)
	return fmt.Sprintf("$argon2id$v=19$m=%d,t=3,p=1$%s$%s", passwordMemory, base64.RawStdEncoding.EncodeToString(salt), base64.RawStdEncoding.EncodeToString(hash)), nil
}
func verifyPassword(password, encoded string) bool {
	parts := strings.Split(encoded, "$")
	if len(parts) != 6 || parts[1] != "argon2id" || parts[2] != "v=19" {
		return false
	}
	var m, t uint32
	var p uint8
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &m, &t, &p); err != nil || m < 8*uint32(p) || m > 256*1024 || t < 1 || t > 10 || p < 1 || p > 16 {
		return false
	}
	salt, err := base64.RawStdEncoding.DecodeString(parts[4])
	if err != nil || len(salt) < 8 || len(salt) > 64 {
		return false
	}
	want, err := base64.RawStdEncoding.DecodeString(parts[5])
	if err != nil || len(want) != 32 {
		return false
	}
	got := argon2.IDKey([]byte(password), salt, t, m, p, 32)
	return subtle.ConstantTimeCompare(got, want) == 1
}
func newToken() (string, []byte, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", nil, err
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	return token, tokenHash(token), nil
}
func tokenHash(token string) []byte { h := sha256.Sum256([]byte(token)); return h[:] }
