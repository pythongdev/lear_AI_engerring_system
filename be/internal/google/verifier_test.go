package google

import (
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"math/big"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"
)

func TestI035_GoogleVerify(t *testing.T) {
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	other, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	now := time.Unix(1800000000, 0)
	var calls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		calls.Add(1)
		w.Header().Set("Cache-Control", "public, max-age=3600")
		_ = json.NewEncoder(w).Encode(map[string]any{"keys": []any{map[string]string{
			"kty": "RSA", "kid": "known", "alg": "RS256", "use": "sig",
			"n": base64.RawURLEncoding.EncodeToString(key.N.Bytes()), "e": base64.RawURLEncoding.EncodeToString(big.NewInt(int64(key.E)).Bytes()),
		}}})
	}))
	defer server.Close()
	v := New("client", Options{JWKSURL: server.URL, Now: func() time.Time { return now }})
	sign := func(h, p map[string]any, k *rsa.PrivateKey) string {
		t.Helper()
		hb, _ := json.Marshal(h)
		pb, _ := json.Marshal(p)
		raw := base64.RawURLEncoding.EncodeToString(hb) + "." + base64.RawURLEncoding.EncodeToString(pb)
		sum := sha256.Sum256([]byte(raw))
		sig, err := rsa.SignPKCS1v15(rand.Reader, k, crypto.SHA256, sum[:])
		if err != nil {
			t.Fatal(err)
		}
		return raw + "." + base64.RawURLEncoding.EncodeToString(sig)
	}
	for _, tc := range []struct {
		name     string
		field    string
		value    any
		valid    bool
		wrongKey bool
	}{
		{name: "valid", valid: true}, {name: "verified_string", field: "email_verified", value: "true", valid: true},
		{name: "second_issuer", field: "iss", value: "accounts.google.com", valid: true},
		{name: "clock_skew", field: "exp", value: now.Unix() - 59, valid: true},
		{name: "bad_signature", wrongKey: true}, {name: "wrong_alg", field: "alg", value: "HS256"},
		{name: "unknown_kid", field: "kid", value: "unknown"}, {name: "wrong_aud", field: "aud", value: "elsewhere"},
		{name: "wrong_iss", field: "iss", value: "https://evil.test"}, {name: "expired", field: "exp", value: now.Unix() - 61},
		{name: "expiry_boundary", field: "exp", value: now.Unix() - 60}, {name: "missing_exp", field: "exp", value: nil},
		{name: "unverified", field: "email_verified", value: false}, {name: "empty_sub", field: "sub", value: ""},
		{name: "blank_sub", field: "sub", value: "   "},
	} {
		t.Run(tc.name, func(t *testing.T) {
			h := map[string]any{"alg": "RS256", "kid": "known"}
			p := map[string]any{"sub": "subject", "email": "guest@gmail.com", "name": "Guest", "iss": "https://accounts.google.com", "aud": "client", "exp": now.Unix() + 600, "email_verified": true}
			if tc.field == "alg" || tc.field == "kid" {
				h[tc.field] = tc.value
			} else if tc.field != "" {
				p[tc.field] = tc.value
			}
			signingKey := key
			if tc.wrongKey {
				signingKey = other
			}
			before := calls.Load()
			got, err := v.Verify(context.Background(), sign(h, p, signingKey))
			if tc.valid {
				if err != nil || got != (Claims{"subject", "guest@gmail.com", "Guest"}) {
					t.Fatalf("claims=%+v err=%v", got, err)
				}
			} else if err == nil {
				t.Fatal("accepted invalid token")
			}
			if tc.name == "unknown_kid" && calls.Load()-before != 1 {
				t.Fatalf("unknown kid fetched %d times", calls.Load()-before)
			}
			if tc.name == "verified_string" && calls.Load() != before {
				t.Fatal("ignored max-age cache")
			}
		})
	}
	t.Run("cache_expired", func(t *testing.T) {
		now = now.Add(2 * time.Hour)
		before := calls.Load()
		_, err := v.Verify(context.Background(), sign(map[string]any{"alg": "RS256", "kid": "known"}, map[string]any{"sub": "s", "aud": "client", "iss": "accounts.google.com", "exp": now.Unix() + 10, "email_verified": true}, key))
		if err != nil || calls.Load()-before != 1 {
			t.Fatalf("refresh: %v calls=%d", err, calls.Load()-before)
		}
	})
	for _, token := range []string{"", "a.b", "e30.e30.???"} {
		if _, err := v.Verify(context.Background(), token); err == nil {
			t.Fatal("accepted malformed token")
		}
	}
}
