package authz

import (
	"net/http"
	"strconv"
)

// HeaderNguoi mang định danh tên đã chọn theo U-075, không mang bí mật xác thực.
const HeaderNguoi = "X-Person-Id"

// ChonTen tin tên người dùng chọn theo U-075: không mật khẩu, không có bí mật nào để giữ.
type ChonTen struct{}

func (ChonTen) PersonID(request *http.Request) (int64, bool) {
	value := request.Header.Get(HeaderNguoi)
	for _, digit := range value {
		if digit < '0' || digit > '9' {
			return 0, false
		}
	}
	personID, err := strconv.ParseInt(value, 10, 64)
	if err != nil || personID <= 0 {
		return 0, false
	}
	return personID, true
}
