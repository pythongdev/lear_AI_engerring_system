"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { call, type ApiFailure } from "@/lib/api/client";
import type { components } from "@/lib/api/schema";
import { useApi } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";

export const KHOA_KHACH = ["customer-sessions", "current"] as const;
export function hetPhien(loi: ApiFailure | null | undefined) {
  return !!loi && "status" in loi && loi.status === 401;
}
export function usePhienKhach() {
  const api = useApi();
  return useQuery<components["schemas"]["CustomerProfile"] | null, ApiFailure>({ queryKey: KHOA_KHACH, queryFn: async () => {
    const r = await call(api.GET("/customer-sessions/current"));
    if (!r.ok) {
      if (hetPhien(r.failure)) return null;
      throw r.failure;
    }
    return r.data;
  }, retry: false });
}
// Chỉ dọn dữ liệu khách, không kết thúc hay chuyển hướng phiên người làm cùng trình duyệt.
export function useDonPhienKhach() {
  const qc = useQueryClient();
  return async () => {
    const predicate = (q: { queryKey: readonly unknown[] }) => String(q.queryKey[0]).startsWith("customer-");
    await qc.cancelQueries({ predicate });
    qc.removeQueries({ predicate });
    useNhapKhach.getState().sua("web", []);
  };
}
export function useChuyenDangNhap(canChuyen: boolean) {
  const router = useRouter();
  const qc = useQueryClient();
  useEffect(() => {
    if (!canChuyen) return;
    qc.removeQueries({ queryKey: ["customer-accounts"] });
    router.replace("/khach/dang-nhap");
  }, [canChuyen, qc, router]);
}
