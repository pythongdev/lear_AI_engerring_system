"use client";
// Đọc tài khoản và người; duyệt · từ chối · khoá · mở lại tài khoản (P4A-06, ADR-109). Ghi xong chỉ làm mất hiệu lực rồi
// đọc lại — không ghi tay cache, không gửi lại ngầm (ADR-102 điểm 2). Hợp đồng không trả mật khẩu của ai; trang chỉ GỬI
// mật khẩu tạm lúc mở lại (ADR-109 điểm 9).

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type TaiKhoan = components["schemas"]["Accounts"]["accounts"][number];
export type Nguoi = components["schemas"]["Person"];
export type Duyet = { role_code: string; person_id?: number };
export type MoLai = { temporary_password: string };
type KetQua = components["schemas"]["AccountResult"];

// Bốn vai trạm duyệt được (shop-facts.md §3); `owner` chỉ lệnh khởi tạo đặt được (ADR-109 điểm 3, Sửa đổi).
export const vaiTram = [
  { ma: "quay", ten: "Người đứng quầy" },
  { ma: "trang_banh", ten: "Người tráng bánh" },
  { ma: "gap_banh", ten: "Người gấp bánh" },
  { ma: "canh_don_ban", ten: "Người canh & dọn" },
] as const;
export const tenVai = (ma: string | null) => ma === "owner" ? "Chủ quán" : vaiTram.find((v) => v.ma === ma)?.ten ?? ma;

export function useTaiKhoan() {
  const api = useApi();
  return useQuery({ queryKey: ["accounts"], queryFn: async () => {
    const r = await call(api.GET("/accounts"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useNguoi() {
  const api = useApi();
  return useQuery({ queryKey: ["people"], queryFn: async () => {
    const r = await call(api.GET("/people"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}

// Duyệt có thể tạo người mới, nên đọc lại cả `people`; trạng thái đã đổi ở máy khác cũng đọc lại.
function useGhiTaiKhoan<B>(gui: (body: B) => Promise<ApiResult<KetQua>>) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok || (r.failure.kind === "rejected" &&
      (r.failure.code.startsWith("account_not_") || r.failure.code === "invalid_request"))) {
      await Promise.all(["accounts", "people"].map((key) => qc.invalidateQueries({ queryKey: [key] })));
    }
  } });
}
const duong = (account_id: number) => ({ params: { path: { account_id } } });

export function useDuyet(account_id: number) {
  const api = useApi();
  return useGhiTaiKhoan((body: Duyet) => call(api.POST("/accounts/{account_id}/approval", { ...duong(account_id), body })));
}
export function useTuChoi(account_id: number) {
  const api = useApi();
  return useGhiTaiKhoan(() => call(api.POST("/accounts/{account_id}/rejection", duong(account_id))));
}
export function useKhoa(account_id: number) {
  const api = useApi();
  return useGhiTaiKhoan(() => call(api.POST("/accounts/{account_id}/lock", duong(account_id))));
}
export function useMoLai(account_id: number) {
  const api = useApi();
  return useGhiTaiKhoan((body: MoLai) => call(api.POST("/accounts/{account_id}/unlock", { ...duong(account_id), body })));
}

export function loiNhanVien(failure: ApiFailure) {
  if (failure.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách để kiểm tra.";
  switch (failure.code) {
    case "account_not_pending":
    case "account_not_active":
    case "account_not_locked": return "Trạng thái tài khoản đã đổi. Đã đọc lại danh sách.";
    case "password_too_short": return "Mật khẩu tạm cần ít nhất 8 ký tự.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ — người đã chọn có thể vừa có tài khoản. Đã đọc lại danh sách.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được thực hiện thao tác này.";
    default: return "Không lưu được. Mã: " + failure.code;
  }
}
export function oLoiNhanVien(failure: ApiFailure) {
  if (failure.kind !== "rejected") return undefined;
  return failure.field ?? (failure.code === "password_too_short" ? "temporary_password" : undefined);
}
