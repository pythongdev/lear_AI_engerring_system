// Package anh dùng chung kho tệp và khuôn tải ảnh cho món và combo.
package anh

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"banhcuon/be/internal/apierr"
)

func Duong(kho, code string) string { return filepath.Join(kho, filepath.FromSlash(code)) }

func Cat(kho, loai string, data []byte, ext string) (string, error) {
	if kho == "" {
		return "", errors.New("thiếu kho tệp ảnh")
	}
	var random [16]byte
	if _, err := rand.Read(random[:]); err != nil {
		return "", err
	}
	code := "images/" + loai + "/" + hex.EncodeToString(random[:]) + ext
	dir := filepath.Join(kho, "images", loai)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return "", err
	}
	f, err := os.CreateTemp(dir, ".upload-")
	if err != nil {
		return "", err
	}
	defer os.Remove(f.Name())
	if _, err = io.Copy(f, bytes.NewReader(data)); err != nil {
		f.Close()
		return "", err
	}
	if err = f.Close(); err != nil {
		return "", err
	}
	if err = os.Rename(f.Name(), Duong(kho, code)); err != nil {
		return "", err
	}
	return code, nil
}

// DocTaiLen giữ khuôn T-307: kiểm kích thước và chữ ký nội dung, không tin tên/Content-Type từ máy khách.
func DocTaiLen(w http.ResponseWriter, r *http.Request) (data []byte, ext, reason string, err error) {
	r.Body = http.MaxBytesReader(w, r.Body, (5<<20)+(1<<20))
	err = r.ParseMultipartForm(1 << 20)
	if r.MultipartForm != nil {
		defer r.MultipartForm.RemoveAll()
	}
	if err != nil {
		var large *http.MaxBytesError
		if errors.As(err, &large) {
			err = apierr.Error{Code: apierr.CodeFileTooLarge}
		} else {
			err = apierr.Error{Code: apierr.CodeInvalidRequest}
		}
		return
	}
	files := r.MultipartForm.File["file"]
	if len(files) != 1 || files[0].Size == 0 {
		err = apierr.Error{Code: apierr.CodeInvalidRequest, Field: "file"}
		return
	}
	if files[0].Size > 5<<20 {
		err = apierr.Error{Code: apierr.CodeFileTooLarge}
		return
	}
	if v := r.MultipartForm.Value["reason"]; len(v) == 1 {
		reason = strings.TrimSpace(v[0])
	}
	if reason == "" {
		err = apierr.Error{Code: apierr.CodeInvalidRequest, Field: "reason"}
		return
	}
	f, err := files[0].Open()
	if err != nil {
		return
	}
	defer f.Close()
	data, err = io.ReadAll(io.LimitReader(f, (5<<20)+1))
	if err != nil {
		return
	}
	if len(data) > 5<<20 {
		err = apierr.Error{Code: apierr.CodeFileTooLarge}
		return
	}
	switch http.DetectContentType(data) {
	case "image/jpeg":
		ext = ".jpg"
	case "image/png":
		ext = ".png"
	case "image/webp":
		ext = ".webp"
	default:
		err = apierr.Error{Code: apierr.CodeInvalidRequest, Field: "file"}
	}
	return
}

func Doc(kho, loai string, code *string, missing apierr.Code) (*os.File, string, error) {
	if code == nil || *code == "" {
		return nil, "", apierr.Error{Code: missing}
	}
	if !strings.HasPrefix(*code, "images/"+loai+"/") || filepath.Base(*code) != strings.TrimPrefix(*code, "images/"+loai+"/") {
		return nil, "", errors.New("khoá ảnh không hợp lệ")
	}
	f, err := os.Open(Duong(kho, *code))
	if errors.Is(err, os.ErrNotExist) {
		return nil, "", apierr.Error{Code: missing}
	}
	if err != nil {
		return nil, "", err
	}
	switch filepath.Ext(*code) {
	case ".jpg":
		return f, "image/jpeg", nil
	case ".png":
		return f, "image/png", nil
	case ".webp":
		return f, "image/webp", nil
	default:
		f.Close()
		return nil, "", errors.New("đuôi ảnh không hợp lệ")
	}
}
