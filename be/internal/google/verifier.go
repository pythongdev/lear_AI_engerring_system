// Package google verifies Google ID tokens without third-party JWT dependencies.
package google

import (
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"math/big"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Claims struct{ Sub, Email, Name string }
type Verifier interface {
	Verify(context.Context, string) (Claims, error)
}

var ErrInvalid = errors.New("invalid Google ID token")

const CertsURL = "https://www.googleapis.com/oauth2/v3/certs"

type Options struct {
	JWKSURL string
	Now     func() time.Time
	Client  *http.Client
}
type verifier struct {
	clientID, url string
	now           func() time.Time
	client        *http.Client
	mu            sync.Mutex
	keys          map[string]*rsa.PublicKey
	expires       time.Time
}

func New(clientID string, opts Options) Verifier {
	if opts.JWKSURL == "" {
		opts.JWKSURL = CertsURL
	}
	if opts.Now == nil {
		opts.Now = time.Now
	}
	if opts.Client == nil {
		opts.Client = &http.Client{Timeout: 10 * time.Second}
	}
	return &verifier{clientID: clientID, url: opts.JWKSURL, now: opts.Now, client: opts.Client}
}
func (v *verifier) Verify(ctx context.Context, token string) (Claims, error) {
	var out Claims
	parts := strings.Split(token, ".")
	if len(parts) != 3 || len(token) > 65536 || v.clientID == "" {
		return out, ErrInvalid
	}
	var h struct{ Alg, Kid string }
	if decode(parts[0], &h) != nil || h.Alg != "RS256" || h.Kid == "" {
		return out, ErrInvalid
	}
	key, err := v.key(ctx, h.Kid)
	if err != nil {
		return out, ErrInvalid
	}
	signature, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return out, ErrInvalid
	}
	digest := sha256.Sum256([]byte(parts[0] + "." + parts[1]))
	if rsa.VerifyPKCS1v15(key, crypto.SHA256, digest[:], signature) != nil {
		return out, ErrInvalid
	}
	var p struct {
		Sub, Email, Name, Iss, Aud string
		Exp                        int64
		EmailVerified              json.RawMessage `json:"email_verified"`
	}
	if decode(parts[1], &p) != nil || p.Aud != v.clientID ||
		(p.Iss != "accounts.google.com" && p.Iss != "https://accounts.google.com") ||
		p.Exp <= 0 || p.Exp <= v.now().Unix()-60 || strings.TrimSpace(p.Sub) == "" ||
		(string(p.EmailVerified) != "true" && string(p.EmailVerified) != `"true"`) {
		return out, ErrInvalid
	}
	return Claims{Sub: p.Sub, Email: p.Email, Name: p.Name}, nil
}
func decode(s string, dst any) error {
	b, err := base64.RawURLEncoding.DecodeString(s)
	if err != nil {
		return err
	}
	return json.Unmarshal(b, dst)
}
func (v *verifier) key(ctx context.Context, kid string) (*rsa.PublicKey, error) {
	v.mu.Lock()
	defer v.mu.Unlock()
	refreshed := false
	if v.keys == nil || !v.now().Before(v.expires) {
		if err := v.refresh(ctx); err != nil {
			return nil, err
		}
		refreshed = true
	}
	if key := v.keys[kid]; key != nil {
		return key, nil
	}
	// A fresh fetch already counts as the one refresh for an unknown kid.
	if !refreshed {
		if err := v.refresh(ctx); err != nil {
			return nil, err
		}
	}
	if key := v.keys[kid]; key != nil {
		return key, nil
	}
	return nil, ErrInvalid
}
func (v *verifier) refresh(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, v.url, nil)
	if err != nil {
		return err
	}
	resp, err := v.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return ErrInvalid
	}
	var jwks struct {
		Keys []struct{ Kty, Kid, Alg, Use, N, E string }
	}
	if json.NewDecoder(io.LimitReader(resp.Body, 1<<20)).Decode(&jwks) != nil {
		return ErrInvalid
	}
	keys := make(map[string]*rsa.PublicKey)
	for _, k := range jwks.Keys {
		if k.Kty != "RSA" || k.Kid == "" || (k.Alg != "" && k.Alg != "RS256") || (k.Use != "" && k.Use != "sig") {
			continue
		}
		n, en := base64.RawURLEncoding.DecodeString(k.N)
		e, ee := base64.RawURLEncoding.DecodeString(k.E)
		if en != nil || ee != nil || len(n) < 256 || len(e) == 0 || len(e) > 4 {
			continue
		}
		exponent := new(big.Int).SetBytes(e).Int64()
		if exponent < 3 || exponent > 2147483647 || exponent%2 == 0 {
			continue
		}
		keys[k.Kid] = &rsa.PublicKey{N: new(big.Int).SetBytes(n), E: int(exponent)}
	}
	if len(keys) == 0 {
		return ErrInvalid
	}
	ttl := int64(0)
	for _, d := range strings.Split(resp.Header.Get("Cache-Control"), ",") {
		k, value, ok := strings.Cut(strings.TrimSpace(d), "=")
		if ok && strings.EqualFold(k, "max-age") {
			if n, e := strconv.ParseInt(strings.Trim(value, `"`), 10, 32); e == nil && n >= 0 {
				ttl = n
			}
		}
	}
	v.keys, v.expires = keys, v.now().Add(time.Duration(ttl)*time.Second)
	return nil
}
