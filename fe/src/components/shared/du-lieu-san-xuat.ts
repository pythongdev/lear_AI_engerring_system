"use client";
// Dữ liệu bảng sản xuất (P4-09) dùng chung cho trạm và quầy: GET /production-board kéo theo chu kỳ backend, tên nhân từ
// GET /menu, nhãn bàn từ GET /dining-tables — cả ba công khai. Số là số backend; màn không tự tính tiến độ.

import { useQuery } from "@tanstack/react-query";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { tuyChonKeo } from "@/lib/realtime/tin-hieu";

type S = components["schemas"];
export type HangSanXuat = S["ProductionRow"];
export type PhanSanXuat = HangSanXuat["parts"][number];
export const khoaBang = ["production-board"] as const;
export const khoaSanXuat = [khoaBang, ["menu"], ["dining-tables"]] as const;
export function useSanXuat() {
  const api = useApi();
  const bang = useQuery({ queryKey: khoaBang, retry: false, ...tuyChonKeo(), queryFn: async () => {
    const r = await call(api.GET("/production-board"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  const menu = useQuery({ queryKey: ["menu"], retry: false, queryFn: async () => {
    const r = await call(api.GET("/menu"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  const ban = useQuery({ queryKey: ["dining-tables"], retry: false, queryFn: async () => {
    const r = await call(api.GET("/dining-tables"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  const options = menu.data?.items.flatMap((m) => m.option_groups.flatMap((g) => g.options)) ?? [];
  const tenHang = (h: Pick<HangSanXuat, "component_name" | "filling_option_ids">) => [h.component_name, ...h.filling_option_ids.map((id) =>
    options.find((o) => o.menu_option_id === id)?.option_name ?? `Nhân ${id}`)].join(" · ");
  const tenPhan = (p: Pick<PhanSanXuat, "dining_table_id" | "sales_order_id">) => p.dining_table_id !== null
    ? ban.data?.tables.find((b) => b.dining_table_id === p.dining_table_id)?.label ?? `Bàn ${p.dining_table_id}`
    : `Đơn ${p.sales_order_id}`;
  return { bang, menu, ban, tenHang, tenPhan };
}
export type DuLieuSanXuat = ReturnType<typeof useSanXuat>;
export const khoaHang = (h: Pick<HangSanXuat, "station_code" | "menu_component_id" | "filling_option_ids">) => JSON.stringify([h.station_code, h.menu_component_id, h.filling_option_ids]);
export const khoaPhan = (p: Pick<PhanSanXuat, "dining_table_id" | "sales_order_id">) => p.dining_table_id !== null ? `ban-${p.dining_table_id}` : `don-${p.sales_order_id}`;
