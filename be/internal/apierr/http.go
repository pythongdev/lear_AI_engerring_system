package apierr

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
)

func WriteError(w http.ResponseWriter, err error) {
	var e Error
	if !errors.As(err, &e) {
		var name string
		e, name = FromDB(err)
		if e.Code == CodeInternalError {
			log.Printf("lỗi hệ thống (tên từ chối %q): %v", name, err)
		}
	}
	Write(w, e)
}

func JSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func ReadID(w http.ResponseWriter, r *http.Request, field string) (int64, bool) {
	id, err := strconv.ParseInt(r.PathValue(field), 10, 64)
	if err != nil || id <= 0 {
		Write(w, Error{Code: CodeInvalidRequest, Field: field})
		return 0, false
	}
	return id, true
}

// ReadJSON bỏ trường lạ; lỗi kiểu chỉ về trường khi bộ đọc xác định được.
func ReadJSON(w http.ResponseWriter, r *http.Request, out any) bool {
	dec := json.NewDecoder(r.Body)
	if err := dec.Decode(out); err != nil {
		var field string
		var typed *json.UnmarshalTypeError
		if errors.As(err, &typed) {
			field = typed.Field
		}
		Write(w, Error{Code: CodeInvalidRequest, Field: field})
		return false
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		Write(w, Error{Code: CodeInvalidRequest})
		return false
	}
	return true
}
