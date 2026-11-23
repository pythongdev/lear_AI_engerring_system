"use client";

import { useQuery } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type TienDoBan = components["schemas"]["TableProgress"];

class LoiTheoDoi extends Error {
  constructor(readonly failure: ApiFailure) {
    super("Chưa đọc được tiến độ món.");
  }
}

export function useTheoDoi(ma: string, initialData?: TienDoBan) {
  const api = useApi();
  return useQuery<TienDoBan, LoiTheoDoi>({
    queryKey: ["qr-codes", ma, "progress"],
    initialData,
    refetchInterval: 15_000,
    retry: false,
    queryFn: async () => {
      const r = await call(api.GET("/qr-codes/{code}/progress", { params: { path: { code: ma } } }));
      if (!r.ok) throw new LoiTheoDoi(r.failure);
      return r.data;
    },
  });
}
