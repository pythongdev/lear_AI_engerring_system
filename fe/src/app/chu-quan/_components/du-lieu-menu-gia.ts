"use client";
// Menu & giá (P4-05): giá mỗi tổ hợp từ GET /menu, thành phần và giá gốc từ POST /price-quotes của từng món (hợp đồng
// không có đường đọc thành phần riêng), phụ thu từ GET /option-groups. Mọi số là số backend trả; màn chỉ định dạng.

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type MonGia = components["schemas"]["MenuItem"];
export type LenhGia =
  | { loai: "gia"; id: number }
  | { loai: "phu-thu"; id: number }
  | { loai: "so-luong"; id: number; monId: number }
  | { loai: "ngung"; id: number };
export const khoaMenuGia = [["menu"], ["price-quotes"], ["option-groups"]] as const;

export function useMenuGia() {
  const api = useApi();
  return useQuery({ queryKey: khoaMenuGia[0], retry: false, queryFn: async () => {
    const r = await call(api.GET("/menu"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useNhomGia() {
  const api = useApi();
  return useQuery({ queryKey: khoaMenuGia[2], retry: false, queryFn: async () => {
    const r = await call(api.GET("/option-groups"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useThanhPhanGia(mon: MonGia) {
  const api = useApi();
  const option_ids = mon.prices[0]?.option_ids;
  return useQuery({ queryKey: [...khoaMenuGia[1], mon.menu_item_id, option_ids], retry: false,
    queryFn: async () => {
      if (!option_ids) throw new Error("Món chưa có tổ hợp giá.");
      const r = await call(api.POST("/price-quotes", { body: {
        lines: [{ menu_item_id: mon.menu_item_id, quantity: 1, option_ids }],
      } }));
      if (!r.ok) throw r.failure;
      if (!r.data.lines[0]) throw new Error("Thiếu dòng tính thử.");
      return r.data.lines[0].components;
    } });
}
export function useLenhGia() {
  const api = useApi();
  return async (lenh: LenhGia, reason: string, so: number): Promise<ApiResult<unknown>> => {
    switch (lenh.loai) {
      case "gia": return call(api.PUT("/menu-components/{menu_component_id}/base-price", {
        params: { path: { menu_component_id: lenh.id } }, body: { base_price_vnd: so, reason },
      }));
      case "phu-thu": return call(api.PUT("/menu-options/{menu_option_id}/surcharge", {
        params: { path: { menu_option_id: lenh.id } }, body: { surcharge_vnd: so, reason },
      }));
      case "so-luong": return call(api.PUT("/menu-items/{menu_item_id}/components/{menu_component_id}", {
        params: { path: { menu_item_id: lenh.monId, menu_component_id: lenh.id } }, body: { quantity: so, reason },
      }));
      case "ngung": return call(api.POST("/menu-items/{menu_item_id}/discontinuation", {
        params: { path: { menu_item_id: lenh.id } }, body: { reason },
      }));
    }
  };
}
export function useDocLaiMenuGia() {
  const qc = useQueryClient();
  return async (ngung = false) => {
    const keys: readonly (readonly string[])[] = ngung ? [...khoaMenuGia, ["menu-categories"]] : khoaMenuGia;
    const results = await Promise.allSettled(keys.map((queryKey) =>
      qc.invalidateQueries({ queryKey }, { throwOnError: true })));
    return results.every((r) => r.status === "fulfilled");
  };
}
export function canDocLaiGia(f: ApiFailure) {
  return f.kind === "rejected" && (f.code.endsWith("_not_found") || f.code === "menu_item_discontinued");
}
export function loiMenuGia(f: ApiFailure) {
  if (f.kind === "no_response") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra.";
  if (f.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả.";
  if (f.code.endsWith("_not_found")) return "Dữ liệu không còn. Đang đọc lại menu.";
  switch (f.code) {
    case "menu_item_discontinued": return "Món đã ngừng bán. Đang đọc lại menu.";
    case "owner_only": return "Chỉ chủ quán được sửa menu và giá.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export const tienGia = (so: number) => so.toLocaleString("vi-VN") + "đ";
