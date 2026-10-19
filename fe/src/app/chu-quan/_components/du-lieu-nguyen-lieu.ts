"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type KieuNguyenLieu = components["schemas"];
export function useNguyenLieu() {
  const api = useApi();
  return useQuery({ queryKey: ["supply-items"], queryFn: async () => {
    const r = await call(api.GET("/supply-items"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useSoNguyenLieu(supply_item_id: number) {
  const api = useApi();
  return useQuery<KieuNguyenLieu["SupplyItemDetail"], ApiFailure>({
    queryKey: ["supply-items", supply_item_id], queryFn: async () => {
      const r = await call(api.GET("/supply-items/{supply_item_id}", { params: { path: { supply_item_id } } }));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
}
function useGhi<B, R>(gui: (body: B) => Promise<ApiResult<R>>) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok || (r.failure.kind === "rejected" && ["supply_item_unit_already_set", "supply_day_entry_not_found", "supply_item_not_found"].includes(r.failure.code))) {
      await qc.invalidateQueries({ queryKey: ["supply-items"] });
    }
  } });
}
export function useThemNguyenLieu() {
  const api = useApi();
  return useGhi((body: KieuNguyenLieu["CreateSupplyItem"]) => call(api.POST("/supply-items", { body })));
}
export function useDatDonVi(supply_item_id: number) {
  const api = useApi();
  return useGhi((body: KieuNguyenLieu["SetSupplyItemPurchaseUnit"]) => call(api.PUT("/supply-items/{supply_item_id}/purchase-unit", { params: { path: { supply_item_id } }, body })));
}
export function useGhiConSo() {
  const api = useApi();
  return useGhi((body: KieuNguyenLieu["CreateSupplyDayEntry"]) => call(api.POST("/supply-day-entries", { body })));
}
export function useSuaConSo(supply_day_entry_id: number) {
  const api = useApi();
  return useGhi((body: KieuNguyenLieu["UpdateSupplyDayEntry"]) => call(api.PUT("/supply-day-entries/{supply_day_entry_id}", { params: { path: { supply_day_entry_id } }, body })));
}
export function loiNguyenLieu(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra, không gửi lại.";
  switch (f.code) {
    case "supply_item_name_taken": return "Tên nguyên liệu bị trùng. Hãy chọn tên khác.";
    case "supply_item_not_found": return "Không tìm thấy nguyên liệu này";
    case "supply_item_unit_already_set": return "Nguyên liệu đã có đơn vị. Đã yêu cầu đọc lại.";
    case "supply_day_entry_not_found": return "Không tìm thấy con số này. Đã yêu cầu đọc lại sổ.";
    case "supply_day_entry_already_recorded": return "Đã có con số cho nguyên liệu, ngày và loại này. Hãy dùng Sửa ở dòng đã có.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiNguyenLieu(f: ApiFailure) {
  return f.kind === "rejected" ? f.field ?? (f.code === "supply_item_name_taken" ? "name" : undefined) : undefined;
}
