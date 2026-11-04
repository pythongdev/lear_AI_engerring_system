"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import type { Khung } from "@/lib/auth/khung";

export type ThanBaoNghi = components["schemas"]["CreateLeaveNotice"];
export function congNgay(ngay: string, soNgay: number) {
  const moc = new Date(`${ngay}T00:00:00Z`);
  moc.setUTCDate(moc.getUTCDate() + soNgay);
  return moc.toISOString().slice(0, 10);
}

export function useBaoNghi(khung: Khung, personId: number, mo: boolean, homNay: string) {
  const api = useApi();
  const qc = useQueryClient();
  const chuQuan = khung === "/chu-quan";
  const denNgay = congNgay(homNay, 30);
  const danhSach = useQuery({
    queryKey: chuQuan ? ["leave-notices", "range", homNay, denNgay] : ["leave-notices", "mine", personId],
    enabled: mo, retry: false,
    queryFn: async () => {
      const r = chuQuan
        ? await call(api.GET("/leave-notices", { params: { query: { from: homNay, to: denNgay } } }))
        : await call(api.GET("/leave-notices/mine"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  async function gui(body: ThanBaoNghi) {
    const r = await call(api.POST("/leave-notices", { body }));
    if (r.ok) void qc.invalidateQueries({ queryKey: ["leave-notices"] });
    return r;
  }
  async function ghi(id: number, viec: "cancel" | "acknowledge") {
    const params = { path: { leave_notice_id: id } };
    const r = viec === "cancel"
      ? await call(api.POST("/leave-notices/{leave_notice_id}/cancel", { params }))
      : await call(api.POST("/leave-notices/{leave_notice_id}/acknowledge", { params }));
    await qc.invalidateQueries({ queryKey: ["leave-notices"] });
    return r;
  }
  return { danhSach, gui, ghi };
}

export function loiBaoNghi(failure: ApiFailure, tao: boolean) {
  if (failure.kind !== "rejected") return tao
    ? "Chưa rõ báo nghỉ đã tới chưa. Bấm Gửi lại để gửi đúng báo nghỉ này."
    : "Chưa rõ kết quả. Đã đọc lại danh sách.";
  switch (failure.code) {
    case "leave_date_in_past": return "Ngày này đã qua. Chọn ngày từ hôm nay trở đi.";
    case "leave_notice_day_taken": return "Bạn đã báo nghỉ ngày này rồi.";
    case "leave_day_attendance_ticked": return "Ngày này đã chấm có đi làm. Báo chủ quán nếu cần đổi.";
    case "submission_code_conflict": return "Dấu gửi đã dùng cho báo nghỉ khác. Bấm Xem lại để gửi lần mới.";
    case "unauthenticated": return "Phiên đã hết. Hãy đăng nhập lại.";
    case "leave_notice_cancel_closed": return "Đã tới ngày nghỉ nên bạn không tự huỷ được. Báo chủ quán.";
    case "leave_notice_not_found": return "Không tìm thấy báo nghỉ này.";
    case "owner_only": return "Chỉ chủ quán ghi được việc này.";
    default: return tao ? `Chưa gửi được báo nghỉ (${failure.code}).` : `Chưa ghi được (${failure.code}).`;
  }
}
