"use client";
// Đọc món theo danh mục, thêm món và đổi tên món (P4A-04). Ghi xong chỉ làm mất hiệu lực rồi đọc lại — không ghi tay
// cache, không gửi lại ngầm (ADR-102 điểm 2). Giá hiển thị lấy từ GET /menu, do backend tính (ADR-086).

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type DanhSachMon = components["schemas"]["MenuCategoryList"];
export type Mon = components["schemas"]["MenuCategoryItem"];
export type ThemMon = components["schemas"]["MenuItemCreate"];
export type DoiTenMon = components["schemas"]["MenuItemRename"];
type KetQua = components["schemas"]["MenuItemIdentity"];
const khoa = ["menu-categories"] as const;

export function useSanPham() {
  const api = useApi();
  return useQuery({ queryKey: khoa, queryFn: async (): Promise<DanhSachMon> => {
    const r = await call(api.GET("/menu-categories"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}

function useDocLaiSauGhi() {
  const qc = useQueryClient();
  return async (r: ApiResult<KetQua>) => {
    if (r.ok || (r.failure.kind === "rejected" &&
      ["menu_category_hidden", "menu_category_not_found", "menu_item_not_found"].includes(r.failure.code))) {
      await Promise.all([
        qc.invalidateQueries({ queryKey: khoa }),
        qc.invalidateQueries({ queryKey: ["menu"] }),
      ]);
    }
  };
}

export function useThemMon() {
  const api = useApi();
  const onSuccess = useDocLaiSauGhi();
  return useMutation({ mutationFn: (body: ThemMon) => call(api.POST("/menu-items", { body })), retry: false, onSuccess });
}

export function useDoiTenMon(menu_item_id: number) {
  const api = useApi();
  const onSuccess = useDocLaiSauGhi();
  return useMutation({ mutationFn: (body: DoiTenMon) => call(api.PUT("/menu-items/{menu_item_id}", {
    params: { path: { menu_item_id } }, body,
  })), retry: false, onSuccess });
}

export function loiSanPham(failure: ApiFailure) {
  if (failure.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách để kiểm tra.";
  switch (failure.code) {
    case "menu_item_name_conflict": return "Tên món bị trùng. Hãy chọn tên khác.";
    case "menu_component_name_conflict": return "Tên thành phần bị trùng với thành phần đã có. Hãy đặt tên khác.";
    case "menu_item_not_found": return "Món không còn trong danh sách. Hãy đọc lại danh sách.";
    case "menu_category_hidden":
    case "menu_category_not_found": return "Danh mục không còn dùng được. Hãy chọn lại danh mục.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được sửa món.";
    default: return "Không lưu được món. Mã: " + failure.code;
  }
}

export function oBiTuChoi(failure: ApiFailure) {
  if (failure.kind !== "rejected") return undefined;
  return failure.code === "menu_item_name_conflict" ? "name" : failure.field?.replace(/\[(\d+)\]/g, ".$1");
}
