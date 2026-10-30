// Package dinhdanh chuẩn hoá định danh theo ADR-131.
package dinhdanh

import (
	"banhcuon/be/internal/apierr"
	"regexp"
	"strings"
	"unicode"
)

type Loai string

const (
	DienThoai Loai = "phone"
	Thu       Loai = "email"
)

var phone = regexp.MustCompile(`^0[1-9][0-9]{8,9}$`)

func ChuanHoa(s string) (Loai, string, error) {
	s = strings.TrimSpace(s)
	if strings.Contains(s, "@") {
		s = strings.ToLower(s)
		parts := strings.Split(s, "@")
		if len(parts) == 2 && parts[0] != "" && parts[1] != "" {
			return Thu, s, nil
		}
	} else {
		s = strings.Map(func(r rune) rune {
			if unicode.IsSpace(r) || strings.ContainsRune(".-()", r) {
				return -1
			}
			return r
		}, s)
		if strings.HasPrefix(s, "+84") {
			s = "0" + s[3:]
		} else if strings.HasPrefix(s, "84") && (len(s) == 11 || len(s) == 12) {
			s = "0" + s[2:]
		}
		if phone.MatchString(s) {
			return DienThoai, s, nil
		}
	}
	return "", "", apierr.Error{Code: apierr.CodeIdentifierInvalid}
}

// LienHe kiểm từng ô và không cho thư đi vào ô điện thoại, hoặc ngược lại.
func LienHe(phone, email string) (string, string, error) {
	if strings.TrimSpace(phone) == "" && strings.TrimSpace(email) == "" {
		return "", "", apierr.Error{Code: apierr.CodeContactRequired}
	}
	for _, v := range []struct {
		p *string
		k Loai
	}{{&phone, DienThoai}, {&email, Thu}} {
		if strings.TrimSpace(*v.p) == "" {
			*v.p = ""
			continue
		}
		k, s, e := ChuanHoa(*v.p)
		if e != nil || k != v.k {
			return "", "", apierr.Error{Code: apierr.CodeIdentifierInvalid, Field: string(v.k)}
		}
		*v.p = s
	}
	return phone, email, nil
}
