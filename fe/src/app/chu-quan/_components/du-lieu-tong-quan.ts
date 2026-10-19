"use client";
// Đọc tổng quan và ghi hai số tối thiểu (P4A-02). Ghi xong chỉ làm mất hiệu lực rồi đọc lại — không ghi tay cache
// (ADR-102 điểm 2). Không kéo theo chu kỳ: hợp đồng không trả poll_interval_seconds cho chủ quán.

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type TongQuan = components["schemas"]["OwnerOverview"];
export type SoToiThieu = components["schemas"]["DailyMinimumInput"];
const khoaTongQuan = ["owner-overview"] as const;

export function useTongQuan() {
  const api = useApi();
  return useQuery({
    queryKey: khoaTongQuan,
    queryFn: async (): Promise<TongQuan> => {
      const r = await call(api.GET("/owner-overview"));
      // Ném lỗi để Query giữ bản đọc thành công trước đó trong cache.
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
}

export function useLuuToiThieu(sale_date: TongQuan["sale_date"]) {
  const api = useApi();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (body: SoToiThieu) => call(api.PUT("/daily-minimums/{sale_date}", {
      params: { path: { sale_date } }, body,
    })),
    onSuccess: async (r) => {
      if (r.ok) await qc.invalidateQueries({ queryKey: khoaTongQuan });
    },
  });
}

export function loiGhi(failure: ApiFailure): string {
  if (failure.kind === "no_response") return "Chưa rõ kết quả lưu vì không nhận được phản hồi. Hãy đọc lại tổng quan để kiểm tra.";
  if (failure.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả lưu.";
  switch (failure.code) {
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy nhập số nguyên từ 1 trở lên.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "owner_only": return "Chỉ chủ quán được nhập số tối thiểu.";
    default: return "Backend từ chối lưu số tối thiểu. Mã: " + failure.code;
  }
}
