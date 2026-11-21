package yeuthich

import "banhcuon/be/internal/authz"

var (
	Doc    = authz.Door{Need: authz.NeedCustomer}
	ThaTim = authz.Door{Code: "yeuthich/tha_tim", Need: authz.NeedCustomer}
	SuaTim = authz.Door{Code: "yeuthich/sua_tim", Need: authz.NeedCustomer}
	BoTim  = authz.Door{Code: "yeuthich/bo_tim", Need: authz.NeedCustomer}
	TaoBo  = authz.Door{Code: "yeuthich/tao_bo", Need: authz.NeedCustomer}
	SuaBo  = authz.Door{Code: "yeuthich/sua_bo", Need: authz.NeedCustomer}
	XoaBo  = authz.Door{Code: "yeuthich/xoa_bo", Need: authz.NeedCustomer}
)
