"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type NguyenLieuKho = components["schemas"]["SupplyItem"];
export type DatTiLeKho = components["schemas"]["SetSupplyItemReminderRatio"];
export const khongConNguyenLieu = (f: ApiFailure) => f.kind === "rejected" && f.code === "supply_item_not_found";

export function useKho() {
  const api = useApi();
  return useQuery({ queryKey: ["supply-stock"], queryFn: async () => {
    const r = await call(api.GET("/supply-stock"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useDatTiLeKho(supply_item_id: number) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({ retry: false,
    mutationFn: (body: DatTiLeKho) => call(api.PUT("/supply-items/{supply_item_id}/reminder-ratio", { params: { path: { supply_item_id } }, body })),
    onSuccess: async (r) => {
      if (r.ok || khongConNguyenLieu(r.failure)) {
        await Promise.all([
          qc.invalidateQueries({ queryKey: ["supply-stock"] }),
          qc.invalidateQueries({ queryKey: ["supply-items"] }),
        ]);
      }
    },
  });
}
export function loiKho(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra, không gửi lại.";
  switch (f.code) {
    case "supply_item_not_found": return "Không tìm thấy nguyên liệu này. Đã yêu cầu đọc lại kho.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại ô này.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiKho(f: ApiFailure) {
  return f.kind === "rejected" && !khongConNguyenLieu(f) ? f.field : undefined;
}
