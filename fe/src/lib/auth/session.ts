"use client";
// Phiên đăng nhập ở frontend (P4-04): đọc `GET /sessions/current`, mở và kết thúc phiên. Mã phiên nằm trong
// cookie HttpOnly — code không đọc, không cất. Đổi người (đăng nhập, đăng xuất, phiên hết) xoá sạch cache
// của người trước rồi đọc lại (ADR-102; fe-03-state-management.md §4).
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { call, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";

import type { Session } from "./khung";

// Mã chỉ sống trong tab, không chứa danh tính hay mã phiên.
let maTab: string | undefined;
function tabHienTai() {
  return maTab ??= Array.from(crypto.getRandomValues(new Uint32Array(4)), (n) => n.toString(16).padStart(8, "0")).join("");
}

function baoDoiPhien() {
  if (typeof BroadcastChannel === "undefined") return;
  const kenh = new BroadcastChannel("banhcuon-phien");
  kenh.postMessage({ loai: "doi-phien", tab: tabHienTai() });
  kenh.close();
}

export function ngheDoiPhien(nhan: () => void) {
  if (typeof BroadcastChannel === "undefined") return () => {};
  const tab = tabHienTai();
  const kenh = new BroadcastChannel("banhcuon-phien");
  kenh.onmessage = ({ data }: MessageEvent<unknown>) => {
    if (typeof data === "object" && data !== null && "loai" in data &&
        data.loai === "doi-phien" && "tab" in data &&
        typeof data.tab === "string" && data.tab !== tab) nhan();
  };
  return () => kenh.close();
}

export const KHOA_PHIEN = ["sessions", "current"] as const;

/** `null` = chưa đăng nhập (401); lỗi khác giữ trong `ApiResult` để màn bày. */
export function usePhien() {
  const api = useApi();
  return useQuery({
    queryKey: KHOA_PHIEN,
    queryFn: async (): Promise<ApiResult<Session> | null> => {
      const r = await call(api.GET("/sessions/current"));
      if (!r.ok && r.failure.kind === "rejected" && r.failure.code === "unauthenticated") return null;
      return r;
    },
  });
}

export type DangNhapVao = { username: string; password: string; at_counter: boolean };

export function useDangNhap() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (vao: DangNhapVao) => call(api.POST("/sessions", { body: vao })),
    onSuccess: (r) => {
      if (!r.ok) return;
      // Xoá sạch cache của người trước; khung đọc lại phiên từ backend (không ghi tay cache — ADR-102 điểm 3).
      qc.clear();
      baoDoiPhien();
    },
  });
}

export function useDangXuat() {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => call(api.POST("/sessions/current/end")),
    onSettled: () => {
      qc.clear();
      baoDoiPhien();
    },
  });
}
