package troly

import "regexp"

var thu = regexp.MustCompile(`(?i)[a-z0-9.!#$%&'*+/=?^_` + "`" + `{|}~-]+@[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)+`)
var dienThoai = regexp.MustCompile(`(?:\+84|0)(?:[ .-]*[0-9]){9,10}`)

func anRieng(s string) string {
	s = thu.ReplaceAllString(s, "[đã ẩn]")
	return dienThoai.ReplaceAllString(s, "[đã ẩn]")
}
