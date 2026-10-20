"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { tuyChonKeo } from "@/lib/realtime/tin-hieu";

export const khoaHangCho = [["counter/queue"], ["dining-tables"], ["preorder-reminders"]] as const;
export function useHangCho() {
  const api = useApi();
  return useQuery({ queryKey: khoaHangCho[0], ...tuyChonKeo(), queryFn: async () => {
    const r = await call(api.GET("/counter/queue"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useBan() {
  const api = useApi();
  return useQuery({ queryKey: khoaHangCho[1], queryFn: async () => {
    const r = await call(api.GET("/dining-tables"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useDonHen() {
  const api = useApi();
  return useQuery({ queryKey: khoaHangCho[2], ...tuyChonKeo(),
    // Hợp đồng nhắc hẹn không trả poll_interval_seconds: dùng nhịp dự phòng của lớp chung.
    refetchInterval: () => tuyChonKeo().refetchInterval({ state: { data: undefined } }),
    queryFn: async () => {
      const r = await call(api.GET("/preorder-reminders"));
      if (!r.ok) throw r.failure;
      return r.data;
    } });
}
export function useDocLaiHangCho() {
  const qc = useQueryClient();
  return async () => {
    const results = await Promise.allSettled(khoaHangCho.map((queryKey) =>
      qc.invalidateQueries({ queryKey }, { throwOnError: true })));
    return results.every((r) => r.status === "fulfilled");
  };
}
export function loiHangCho(f: ApiFailure) {
  if (f.kind === "no_response") return "Chưa xác nhận được kết quả… Hãy đọc lại để kiểm tra.";
  if (f.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả.";
  switch (f.code) {
    case "order_transition_not_allowed": return "Đơn đã được xử lý ở nơi khác. Đang đọc lại.";
    case "sales_order_not_found": return "Không còn tìm thấy đơn. Đang đọc lại.";
    case "not_on_counter_duty": return "Bạn phải đứng quầy để thực hiện việc này.";
    case "shop_not_blind": return "Quán đã mở lại nhận đơn. Đang đọc lại.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    default: return "Chưa thực hiện được. Mã: " + f.code;
  }
}
export function canDocLai(f: ApiFailure) {
  return f.kind === "rejected" && ["order_transition_not_allowed", "sales_order_not_found", "shop_not_blind"].includes(f.code);
}
export const gio = (moc: string) => new Date(moc).toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" });
