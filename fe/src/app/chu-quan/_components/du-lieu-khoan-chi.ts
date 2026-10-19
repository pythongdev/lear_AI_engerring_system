"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type KieuKhoanChi = components["schemas"];
export function useLoaiChi() {
  const api = useApi();
  return useQuery({ queryKey: ["expense-categories"], queryFn: async () => {
    const r = await call(api.GET("/expense-categories"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useKhoanChi(from: string | undefined, to: string | undefined, loai: string | null, nguon: string | null) {
  const api = useApi();
  return useQuery<KieuKhoanChi["Expenses"], ApiFailure>({
    queryKey: ["expenses", { from, to, loai, nguon }], enabled: from !== undefined && to !== undefined,
    queryFn: async () => {
      const r = await call(api.GET("/expenses", { params: { query: {
        from: from!, to: to!, ...(loai ? { expense_category_id: Number(loai) } : {}),
        ...(nguon === "ket" || nguon === "rieng" ? { paid_from_till: nguon === "ket" } : {}),
      } } }));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
}
function useGhi<B, R>(gui: (body: B) => Promise<ApiResult<R>>, key: string) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok) await qc.invalidateQueries({ queryKey: [key] });
    else if (r.failure.kind === "rejected") {
      if (r.failure.code === "expense_category_not_found") await qc.invalidateQueries({ queryKey: ["expense-categories"] });
      if (r.failure.code === "expense_not_found") await qc.invalidateQueries({ queryKey: ["expenses"] });
    }
  } });
}
export function useThemLoaiChi() {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["CreateExpenseCategory"]) => call(api.POST("/expense-categories", { body })), "expense-categories");
}
export function useGhiKhoanChi() {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["WriteExpense"]) => call(api.POST("/expenses", { body })), "expenses");
}
export function useSuaKhoanChi(expense_id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["UpdateExpense"]) => call(api.PUT("/expenses/{expense_id}", { params: { path: { expense_id } }, body })), "expenses");
}
export function loiKhoanChi(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra, không gửi lại.";
  switch (f.code) {
    case "expense_category_name_taken": return "Tên loại chi bị trùng. Hãy chọn tên khác.";
    case "expense_category_not_found": return "Không tìm thấy loại chi này. Đã yêu cầu đọc lại loại chi.";
    case "expense_not_found": return "Không tìm thấy khoản chi này. Đã yêu cầu đọc lại khoản chi.";
    case "sale_day_reconciled": return "Ngày này đã đối soát két nên không ghi được khoản trả từ két vào ngày ấy.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại ô này.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiKhoanChi(f: ApiFailure) {
  if (f.kind !== "rejected") return undefined;
  if (f.code === "sale_day_reconciled") return "paid_date";
  return f.field ?? (f.code === "expense_category_name_taken" ? "name" : f.code === "expense_category_not_found" ? "expense_category_id" : undefined);
}
