"use client";

import { useQuery } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type BangVanHanh = components["schemas"]["ServiceBoard"];
export function useBangVanHanh() {
  const api = useApi();
  return useQuery({ queryKey: ["service-board"], queryFn: async (): Promise<BangVanHanh> => {
    const r = await call(api.GET("/service-board"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function loiVanHanh(f: ApiFailure) {
  if (f.kind === "rejected" && f.code === "unauthenticated") return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
  return `Hãy đọc lại. Mã: ${f.kind === "rejected" ? f.code : f.kind}.`;
}
