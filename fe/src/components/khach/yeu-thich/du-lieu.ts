"use client";

import { useRef, useState } from "react";
import { useQueries, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { hetPhien } from "@/lib/khach/session";
import { dungLai, useNhapKhach } from "@/lib/nhap-khach";
import { dongGui, soSuat } from "@/components/shared/bo-soan-mon";

export type Menu = components["schemas"]["Menu"];
export type Dong = components["schemas"]["FavouriteLine"];
export type Bo = components["schemas"]["FavouriteSet"];
export type DongGui = components["schemas"]["PriceLineRequest"];
export const KHOA = ["customer-accounts", "current", "favourites"] as const;

// Chỉ lấy hình dòng gửi; không đưa mã dòng, cờ hay trường null vào lệnh ghi/tính giá.
export function guiDong(d: Dong): DongGui {
  return d.menu_combo_id !== null
    ? { menu_combo_id: d.menu_combo_id, quantity: d.quantity, portions: d.portions.map((p) => ({ menu_item_id: p.menu_item_id, quantity: p.quantity, option_ids: [...p.option_ids] })) }
    : { menu_item_id: d.menu_item_id!, option_ids: [...d.option_ids], quantity: d.quantity };
}

export function soanDong(d: DongGui, menu: Menu) {
  return dungLai(d.menu_combo_id !== undefined
    ? [{ menu_combo_id: d.menu_combo_id, quantity: d.quantity, portions: (d.portions ?? []).flatMap((p) =>
      Array.from({ length: p.quantity }, () => ({ menu_item_id: p.menu_item_id, option_ids: [...p.option_ids] }))) }]
    : [{ menu_item_id: d.menu_item_id!, option_ids: d.option_ids ?? [], quantity: d.quantity }], menu)[0];
}

export function doiSoLuong(d: DongGui, quantity: number, menu: Menu): DongGui {
  const soan = soanDong(d, menu);
  if (soan?.combo) return dongGui({ ...soan, quantity, portions: soSuat(soan.combo, quantity, soan.portions) });
  return { ...d, quantity };
}

export function themVaoGio(lines: Dong[], menu: Menu) {
  const state = useNhapKhach.getState();
  const them = lines.filter((d) => d.available).flatMap((d) => {
    const soan = soanDong(guiDong(d), menu);
    return soan ? [soan] : [];
  });
  state.sua("web", [...dungLai(state.gio.web, menu), ...them]);
}

export function loiYeuThich(f: ApiFailure) {
  if (f.kind === "no_response") return "Kết quả chưa rõ vì mất phản hồi. Hãy đọc lại danh sách trước khi thử lại.";
  if (f.kind === "unexpected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách trước khi thử lại.";
  switch (f.code) {
    case "favourite_limit_reached": return "Đã chạm giới hạn món yêu thích hoặc bộ món. Hãy bớt món hoặc xoá bớt bộ rồi thử lại.";
    case "favourite_line_not_found": return "Món yêu thích này không còn trong danh sách. Hãy đọc lại.";
    case "favourite_set_not_found": return "Bộ món này không còn trong danh sách. Hãy đọc lại.";
    case "menu_item_not_found":
    case "menu_item_discontinued": return "Món này không còn bán. Hãy đọc lại và chọn món khác.";
    case "menu_combo_not_found":
    case "menu_combo_hidden": return "Combo này không còn bán. Hãy đọc lại và chọn combo khác.";
    case "menu_option_not_found":
    case "menu_option_hidden": return "Có lựa chọn không còn bán. Hãy chọn lại món.";
    case "option_combination_invalid": return "Lựa chọn của món chưa hợp lệ. Hãy kiểm tra các nhóm lựa chọn.";
    case "combo_portions_mismatch": return "Các suất chưa khớp số lượng combo. Hãy chọn lại combo.";
    case "invalid_request": return "Thông tin chưa hợp lệ. Hãy kiểm tra tên bộ, món và số lượng từ 1 đến 99.";
    default: return "Chưa thực hiện được yêu cầu. Hãy đọc lại danh sách rồi thử lại.";
  }
}

export function useGhiYeuThich(moiDangNhap: () => void) {
  const qc = useQueryClient();
  const lock = useRef(false);
  const [busy, setBusy] = useState(false);
  const [loi, setLoi] = useState("");
  const [bao, setBao] = useState("");
  async function gui(lenh: () => Promise<ApiResult<unknown>>) {
    if (lock.current) return false;
    lock.current = true; setBusy(true); setLoi(""); setBao("");
    try {
      const r = await lenh();
      if (!r.ok) {
        if (hetPhien(r.failure)) moiDangNhap();
        else setLoi(loiYeuThich(r.failure));
        return false;
      }
      await qc.invalidateQueries({ queryKey: KHOA });
      setBao(qc.getQueryState(KHOA)?.status === "error" ? "Đã lưu nhưng chưa đọc lại được danh sách. Bấm Đọc lại để cập nhật." : "Đã lưu thay đổi.");
      return true;
    } finally { lock.current = false; setBusy(false); }
  }
  return { gui, busy, loi, bao };
}

export function useGiaCacNhom(groups: { id: string | number; lines: Dong[] }[], readAt: number, menuReadAt: number) {
  const api = useApi();
  return useQueries({ queries: groups.map((group) => {
    const lines = group.lines.filter((d) => d.available).map(guiDong);
    return {
      queryKey: ["price-quotes", "favourites", group.id, readAt, menuReadAt, lines],
      enabled: lines.length > 0,
      retry: false,
      queryFn: async () => {
        const r = await call(api.POST("/price-quotes", { body: { lines } }));
        if (!r.ok) throw new Error("Chưa tính được giá. Hãy đọc lại danh sách.");
        if (r.data.lines.length !== lines.length || !Number.isFinite(r.data.total_vnd) || r.data.lines.some((d) => !Number.isFinite(d.line_total_vnd))) {
          throw new Error("Chưa tính được giá. Hãy đọc lại danh sách.");
        }
        return r.data;
      },
    };
  }) });
}
export type GiaNhom = ReturnType<typeof useGiaCacNhom>[number];
