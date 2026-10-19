"use client";

// Dữ liệu trang Topping (T-210): nhóm tuỳ chọn và lựa chọn đọc từ GET /option-groups; ghi xong chỉ vô hiệu hoá rồi đọc lại.
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type KieuTopping = components["schemas"];
export type NhomTopping = KieuTopping["OptionGroupAdmin"];
export type LuaChonTopping = KieuTopping["MenuOptionAdmin"];

export function useTopping() {
  const api = useApi();
  return useQuery({ queryKey: ["option-groups"], queryFn: async () => {
    const r = await call(api.GET("/option-groups"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
function useGhiTopping<B, R>(gui: (body: B) => Promise<ApiResult<R>>) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok || (r.failure.kind === "rejected" && /_not_found$|_hidden$|_not_hidden$|_name_taken$/.test(r.failure.code))) {
      await qc.invalidateQueries({ queryKey: ["option-groups"] });
    }
  } });
}
export function useThemLuaChon(option_group_id: number) {
  const api = useApi();
  return useGhiTopping((body: KieuTopping["NewMenuOption"]) => call(api.POST("/option-groups/{option_group_id}/options", {
    params: { path: { option_group_id } }, body,
  })));
}
export function useAnLuaChon(menu_option_id: number, an: boolean) {
  const api = useApi();
  return useGhiTopping((body: KieuTopping["HideMenuOption"]) => an
    ? call(api.POST("/menu-options/{menu_option_id}/hiding", { params: { path: { menu_option_id } }, body }))
    : call(api.POST("/menu-options/{menu_option_id}/unhiding", { params: { path: { menu_option_id } }, body })));
}
export function loiTopping(failure: ApiFailure) {
  if (failure.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách để kiểm tra.";
  switch (failure.code) {
    case "menu_option_name_taken": return "Nhóm này đã có lựa chọn cùng tên. Hãy chọn tên khác.";
    case "option_group_not_found": return "Nhóm không còn. Đã đọc lại danh sách.";
    case "menu_option_not_found": return "Lựa chọn không còn. Đã đọc lại danh sách.";
    case "menu_option_hidden": return "Lựa chọn đã ẩn rồi. Đã đọc lại danh sách.";
    case "menu_option_not_hidden": return "Lựa chọn đang hiện. Đã đọc lại danh sách.";
    case "menu_option_is_default": return "Đây là lựa chọn mặc định của nhóm nên không ẩn được.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + failure.code;
  }
}
export function oLoiTopping(failure: ApiFailure) {
  if (failure.kind !== "rejected") return undefined;
  return failure.field ?? (failure.code === "menu_option_name_taken" ? "name" : undefined);
}
