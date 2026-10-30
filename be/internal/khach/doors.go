package khach

import "banhcuon/be/internal/authz"

var (
	DangKy       = authz.Door{Code: "khach/dang_ky", Need: authz.NeedPublic}
	DangNhap     = authz.Door{Code: "khach/dang_nhap", Need: authz.NeedPublic}
	DangXuat     = authz.Door{Code: "khach/dang_xuat", Need: authz.NeedCustomer}
	DoiMatKhau   = authz.Door{Code: "khach/doi_mat_khau", Need: authz.NeedCustomer}
	LuuGiao      = authz.Door{Code: "khach/luu_giao", Need: authz.NeedCustomer}
	DatLai       = authz.Door{Code: "khach/dat_lai", Need: authz.NeedPublic}
	YeuCauDatLai = authz.Door{Code: "khach/yeu_cau_dat_lai", Need: authz.NeedPublic}
	MoPhien      = authz.Door{Code: "khach/mo_phien", Need: authz.NeedCallingDoor}
	GhiMatKhau   = authz.Door{Code: "khach/ghi_mat_khau", Need: authz.NeedCallingDoor}
	KetThucPhien = authz.Door{Code: "khach/ket_thuc_phien", Need: authz.NeedCallingDoor}
)
