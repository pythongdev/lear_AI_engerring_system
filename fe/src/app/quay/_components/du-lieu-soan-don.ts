"use client";

import { useQuery } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";

export function useMenuSoan() {
  const api = useApi();
  return useQuery({ queryKey: ["menu"], queryFn: async () => {
    const r = await call(api.GET("/menu"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function loiSoanDon(f: ApiFailure) {
  if (f.kind === "no_response") return "Chưa xác nhận được kết quả… Bấm Gửi lại để kiểm tra cùng lượt gửi.";
  if (f.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả…";
  switch (f.code) {
    case "dining_table_needs_cleaning": return "Bàn đang chờ dọn. Phiếu vẫn được giữ lại.";
    case "menu_item_discontinued": return "Món đã ngừng bán. Hãy kiểm tra lại phiếu.";
    case "not_on_counter_duty": return "Bạn phải đứng quầy để gửi phiếu.";
    case "outside_selling_hours": return "Giờ cần hàng nằm ngoài giờ bán. Hãy kiểm tra lại.";
    default: return "Chưa gửi được phiếu. Mã: " + f.code;
  }
}
