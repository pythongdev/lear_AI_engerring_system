package taikhoan

import "banhcuon/be/internal/authz"

var (
	DangKy       = authz.Door{Code: "taikhoan/dang_ky", Need: authz.NeedPublic}
	DangNhap     = authz.Door{Code: "taikhoan/dang_nhap", Need: authz.NeedPublic}
	DangXuat     = authz.Door{Code: "taikhoan/dang_xuat", Need: authz.NeedPerson}
	DatLai       = authz.Door{Code: "taikhoan/dat_lai", Need: authz.NeedPublic}
	DoiMatKhau   = authz.Door{Code: "taikhoan/doi_mat_khau", Need: authz.NeedPerson}
	DoiTrangThai = authz.Door{Code: "taikhoan/doi_trang_thai", Need: authz.NeedCallingDoor}
	Duyet        = authz.Door{Code: "taikhoan/duyet", Need: authz.NeedOwner}
	GhiMatKhau   = authz.Door{Code: "taikhoan/ghi_mat_khau", Need: authz.NeedCallingDoor}
	KetThucPhien = authz.Door{Code: "taikhoan/ket_thuc_phien", Need: authz.NeedCallingDoor}
	Khoa         = authz.Door{Code: "taikhoan/khoa", Need: authz.NeedOwner}
	KhoiTao      = authz.Door{Code: "taikhoan/khoi_tao", Need: authz.NeedPublic}
	MoKhoa       = authz.Door{Code: "taikhoan/mo_khoa", Need: authz.NeedOwner}
	TuChoi       = authz.Door{Code: "taikhoan/tu_choi", Need: authz.NeedOwner}
	YeuCauDatLai = authz.Door{Code: "taikhoan/yeu_cau_dat_lai", Need: authz.NeedPublic}
)
