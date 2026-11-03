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
  return useMutation({ mutationKey: ["expense-write"], mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok) {
      await Promise.all([qc.invalidateQueries({ queryKey: [key] }), qc.invalidateQueries({ queryKey: [key === "expenses" ? "expense-categories" : "expenses"] })]);
    }
    else if (r.failure.kind === "rejected") {
      if (r.failure.code === "expense_category_not_found" || r.failure.code === "expense_item_not_found") await qc.invalidateQueries({ queryKey: ["expense-categories"] });
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
export function useThemKhoanCon() {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["CreateExpenseItem"]) => call(api.POST("/expense-items", { body })), "expense-categories");
}
export function useDoiTenLoai(id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["RenameExpense"]) => call(api.PUT("/expense-categories/{expense_category_id}", { params: { path: { expense_category_id: id } }, body })), "expense-categories");
}
export function useDoiTenKhoanCon(id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["RenameExpense"]) => call(api.PUT("/expense-items/{expense_item_id}", { params: { path: { expense_item_id: id } }, body })), "expense-categories");
}
export function useXoaLoai(id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["ExpenseReason"]) => call(api.DELETE("/expense-categories/{expense_category_id}", { params: { path: { expense_category_id: id } }, body })), "expense-categories");
}
export function useXoaKhoanCon(id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["ExpenseReason"]) => call(api.DELETE("/expense-items/{expense_item_id}", { params: { path: { expense_item_id: id } }, body })), "expense-categories");
}
export function useXoaKhoanChi(id: number) {
  const api = useApi();
  return useGhi((body: KieuKhoanChi["ExpenseReason"]) => call(api.DELETE("/expenses/{expense_id}", { params: { path: { expense_id: id } }, body })), "expenses");
}
export function loiKhoanChi(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra, không gửi lại.";
  switch (f.code) {
    case "expense_category_in_use": return "Mục còn khoản chi, kể cả ngoài khoảng ngày đang lọc. Hãy chuyển hoặc xoá khoản chi trước.";
    case "expense_item_in_use": return "Khoản con còn khoản chi, kể cả ngoài khoảng ngày đang lọc. Hãy chuyển hoặc xoá khoản chi trước.";
    case "expense_item_not_found": return "Không tìm thấy khoản con này. Đã yêu cầu đọc lại danh mục.";
    case "expense_item_name_taken": return "Tên khoản con bị trùng trong mục. Hãy chọn tên khác.";
    case "expense_category_name_taken": return "Tên loại chi bị trùng. Hãy chọn tên khác.";
    case "expense_category_not_found": return "Không tìm thấy loại chi này. Đã yêu cầu đọc lại loại chi.";
    case "expense_not_found": return "Không tìm thấy khoản chi này. Đã yêu cầu đọc lại khoản chi.";
    case "sale_day_reconciled": return "Ngày này đã đối soát két nên không thể thay đổi khoản chi.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại ô này.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiKhoanChi(f: ApiFailure) {
  if (f.kind !== "rejected") return undefined;
  if (f.code === "sale_day_reconciled") return "paid_date";
  return f.field ?? (f.code === "expense_category_name_taken" || f.code === "expense_item_name_taken" ? "name" : f.code === "expense_category_not_found" ? "expense_category_id" : undefined);
}
