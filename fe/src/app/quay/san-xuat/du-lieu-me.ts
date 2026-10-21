"use client";
import { useQuery } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { tuyChonKeo } from "@/lib/realtime/tin-hieu";

export type ViecTram = components["schemas"]["CounterStationJobs"]["jobs"][number];
export const khoaViecTram = ["counter/station-jobs"] as const;
export function useViecTram() {
  const api = useApi();
  return useQuery({ queryKey: khoaViecTram, retry: false, ...tuyChonKeo(), queryFn: async () => {
    const r = await call(api.GET("/counter/station-jobs"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function canDocLai(f: ApiFailure) {
  return f.kind === "rejected" && (f.code.endsWith("_not_found") || ["station_job_transition_not_allowed",
    "transfer_source_not_available", "transfer_target_not_waiting", "wrong_make_note_not_allowed"].includes(f.code));
}
export function loiMe(f: ApiFailure): string {
  if (f.kind === "no_response") return "Chưa xác nhận được kết quả. Hãy đọc lại bảng để kiểm tra trước khi ghi tiếp.";
  if (f.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả.";
  if (canDocLai(f)) return "Dữ liệu không còn hoặc trạng thái đã đổi. Đang đọc lại bảng.";
  switch (f.code) {
    case "production_batch_has_served_units": return "Mẻ đã ra bàn, không thể lùi.";
    case "station_job_has_wrong_make_note": return "Việc đã có ghi chú làm sai.";
    case "production_batch_already_rolled_back": return "Mẻ đã lùi.";
    case "not_on_counter_duty": return "Bạn chưa đứng quầy. Hãy đứng quầy trước khi thao tác.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    default: return "Không thực hiện được. Mã: " + f.code;
  }
}
