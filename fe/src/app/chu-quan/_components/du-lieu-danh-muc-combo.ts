"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type KieuMenu = components["schemas"];
export const tienMenu = (so: number) => new Intl.NumberFormat("vi-VN").format(so) + " đ";

// Cùng khoá với useSanPham; chỉ vô hiệu hoá, dữ liệu luôn được đọc lại từ backend.
function useGhiMenu<B, R>(gui: (body: B) => Promise<ApiResult<R>>, khoa: "menu-categories" | "menu-combos") {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok) {
      await qc.invalidateQueries({ queryKey: [khoa] });
    } else if (r.failure.kind === "rejected") {
      const code = r.failure.code;
      if (code.endsWith("_not_found") || code.endsWith("_hidden") ||
        code === "menu_item_discontinued" || code === "menu_item_already_in_category") {
        const keys = new Set([khoa]);
        if (code.startsWith("menu_item_") || code.startsWith("menu_category_")) keys.add("menu-categories");
        await Promise.all([...keys].map((key) => qc.invalidateQueries({ queryKey: [key] })));
      }
    }
  } });
}

export function useThemDanhMuc() {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["CreateMenuCategory"]) => call(api.POST("/menu-categories", { body })), "menu-categories");
}
export function useDoiTenDanhMuc(menu_category_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["UpdateMenuCategory"]) => call(api.PUT("/menu-categories/{menu_category_id}", {
    params: { path: { menu_category_id } }, body,
  })), "menu-categories");
}
export function useAnDanhMuc(menu_category_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["HideMenuCategory"]) => call(api.POST("/menu-categories/{menu_category_id}/hiding", {
    params: { path: { menu_category_id } }, body,
  })), "menu-categories");
}
export function useXepDanhMuc(menu_item_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["AssignMenuItemCategory"]) => call(api.PUT("/menu-items/{menu_item_id}/category", {
    params: { path: { menu_item_id } }, body,
  })), "menu-categories");
}
export function useCombo() {
  const api = useApi();
  return useQuery({ queryKey: ["menu-combos"], queryFn: async () => {
    const r = await call(api.GET("/menu-combos"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useLapCombo() {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["CreateMenuCombo"]) => call(api.POST("/menu-combos", { body })), "menu-combos");
}
export function useDoiGiaCombo(menu_combo_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["UpdateMenuComboPrice"]) => call(api.PUT("/menu-combos/{menu_combo_id}/price", {
    params: { path: { menu_combo_id } }, body,
  })), "menu-combos");
}
export function useDatPhuThuCombo(menu_combo_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["SetMenuComboSurcharges"]) => call(api.PUT("/menu-combos/{menu_combo_id}/surcharges", {
    params: { path: { menu_combo_id } }, body,
  })), "menu-combos");
}
export function useAnCombo(menu_combo_id: number) {
  const api = useApi();
  return useGhiMenu((body: KieuMenu["HideMenuCombo"]) => call(api.POST("/menu-combos/{menu_combo_id}/hiding", {
    params: { path: { menu_combo_id } }, body,
  })), "menu-combos");
}

export function loiMenu(failure: ApiFailure) {
  if (failure.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách để kiểm tra.";
  switch (failure.code) {
    case "menu_category_name_taken": return "Tên danh mục bị trùng. Hãy chọn tên khác.";
    case "menu_category_hidden":
    case "menu_category_not_found": return "Danh mục không còn dùng được. Hãy chọn lại danh mục.";
    case "menu_item_not_found": return "Món không còn trong danh sách. Hãy chọn lại món.";
    case "menu_item_discontinued": return "Món đã ngừng bán. Hãy chọn lại món.";
    case "menu_item_already_in_category": return "Món đã ở danh mục này. Hãy đọc lại danh sách.";
    case "menu_combo_hidden": return "Combo đã bị ẩn. Hãy đọc lại danh sách.";
    case "menu_combo_not_found": return "Combo không còn trong danh sách. Hãy đọc lại danh sách.";
    case "menu_combo_price_in_sales_hours": return "Chỉ đổi giá combo ngoài giờ bán.";
    case "menu_combo_surcharge_in_sales_hours": return "Chỉ đặt phụ thu combo ngoài giờ bán.";
    case "menu_combo_item_not_found": return "Món không còn trong combo. Hãy đọc lại danh sách.";
    case "menu_option_not_found": return "Lựa chọn không còn. Hãy đọc lại danh sách.";
    case "option_combination_invalid": return "Lựa chọn không thuộc nhóm nào của món này. Hãy đọc lại danh sách.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + failure.code;
  }
}
export function oLoiMenu(failure: ApiFailure) {
  if (failure.kind !== "rejected") return undefined;
  return (failure.field ?? (failure.code === "menu_category_name_taken" ? "name" : undefined))?.replace(/\[(\d+)\]/g, ".$1");
}
