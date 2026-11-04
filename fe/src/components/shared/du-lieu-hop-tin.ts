"use client";

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import type { Khung } from "@/lib/auth/khung";
import { tuyChonKeo } from "@/lib/realtime/tin-hieu";

export type Tin = components["schemas"]["StationMessage"];
export type ThanGui = components["schemas"]["SendStationMessageToCounter"]
  | components["schemas"]["SendStationMessage"];

export function useHopTin(khung: Khung, personId: number, mo: boolean) {
  const api = useApi();
  const qc = useQueryClient();
  const caNhan = khung === "/tram";
  const tin = useQuery({
    queryKey: ["station-messages", caNhan ? "mine" : "counter", personId],
    enabled: mo, retry: false, ...tuyChonKeo(),
    queryFn: async () => {
      const r = await call(api.GET(caNhan ? "/station-messages/mine" : "/station-messages/counter"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  const viec = useQuery({
    queryKey: ["assigned-tasks", "mine", personId], enabled: mo, retry: false,
    queryFn: async () => {
      const r = await call(api.GET("/assigned-tasks/mine"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  const nguoi = useQuery({
    queryKey: ["people"], enabled: mo && !caNhan, retry: false,
    queryFn: async () => {
      const r = await call(api.GET("/people"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  const ban = useQuery({
    queryKey: ["dining-tables"], enabled: mo, retry: false,
    queryFn: async () => {
      const r = await call(api.GET("/dining-tables"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });

  // Không dùng mutation cache để giữ nháp, thân hay dấu gửi.
  async function gui(body: ThanGui) {
    const r = "recipient_person_id" in body
      ? await call(api.POST("/station-messages", { body }))
      : await call(api.POST("/station-messages/to-counter", { body }));
    if (r.ok) void qc.invalidateQueries({ queryKey: ["station-messages"] });
    return r;
  }
  return { tin, viec, nguoi, ban, gui };
}

export function loiHopTin(failure: ApiFailure) {
  if (failure.kind !== "rejected") return "Chưa rõ tin đã tới chưa. Bấm Gửi lại để gửi đúng tin này.";
  switch (failure.code) {
    case "message_recipient_invalid": return "Người này chưa có tài khoản đang hoạt động hoặc là chính bạn. Chọn người khác.";
    case "not_on_counter_duty": return "Bạn không đứng quầy nên chưa gửi tin từ quầy được.";
    case "dining_table_not_found": return "Bàn này không còn. Chọn lại bàn.";
    case "station_message_not_found": return "Không tìm thấy tin đang trả lời. Bỏ trả lời rồi gửi lại.";
    case "submission_code_conflict": return "Dấu gửi đã dùng cho tin khác. Bấm Xem lại để gửi lần mới.";
    case "invalid_request": return `Tin chưa đúng hình (ô ${failure.field ?? "không xác định"}).`;
    case "unauthenticated": return "Phiên đã hết. Hãy đăng nhập lại.";
    default: return `Chưa gửi được tin (${failure.code}).`;
  }
}
