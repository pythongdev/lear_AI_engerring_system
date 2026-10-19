"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type K = components["schemas"];
export const daDoi = (f: ApiFailure) => f.kind === "rejected" && [
  "training_record_hidden", "training_record_not_found", "assigned_task_guide_not_text",
  "assigned_task_guide_hidden", "assigned_task_guide_not_found", "assigned_task_not_found",
].includes(f.code);
export function useGhiNhan(nguoi: number | undefined, an: boolean) {
  const api = useApi();
  return useQuery<K["TrainingRecords"], ApiFailure>({ queryKey: ["training-records", { nguoi, an }], queryFn: async () => {
    const r = await call(api.GET("/training-records", { params: { query: { trainee_person_id: nguoi, ...(an ? { include_hidden: true } : {}) } } }));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
export function useHuongDan(viec: number | undefined, an: boolean) {
  const api = useApi();
  return useQuery<K["AssignedTaskGuides"], ApiFailure>({ queryKey: ["assigned-task-guides", viec, { an }], enabled: viec !== undefined, queryFn: async () => {
    const r = await call(api.GET("/assigned-tasks/{assigned_task_id}/guides", { params: {
      path: { assigned_task_id: viec! }, query: an ? { include_hidden: true } : {},
    } }));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
function useGhi<B, R>(key: string, gui: (body: B) => Promise<ApiResult<R>>) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok || daDoi(r.failure)) await qc.invalidateQueries({ queryKey: [key] });
  } });
}
export function useThemGhiNhan() {
  const api = useApi();
  return useGhi("training-records", (body: K["CreateTrainingRecord"]) => call(api.POST("/training-records", { body })));
}
export function useSuaGhiNhan(training_record_id: number) {
  const api = useApi();
  return useGhi("training-records", (body: K["UpdateTrainingRecord"]) => call(api.PUT("/training-records/{training_record_id}", { params: { path: { training_record_id } }, body })));
}
export function useAnGhiNhan(training_record_id: number) {
  const api = useApi();
  return useGhi("training-records", (body: K["HideTrainingItem"]) => call(api.POST("/training-records/{training_record_id}/hiding", { params: { path: { training_record_id } }, body })));
}
export function useGanHuongDan(assigned_task_id: number) {
  const api = useApi();
  return useGhi("assigned-task-guides", (data: { kind: K["CreateAssignedTaskGuide"]["kind"]; body?: string; file?: File }) => {
    const form = new FormData();
    form.set("kind", data.kind);
    if (data.kind === "text") form.set("body", data.body!);
    else form.set("file", data.file!);
    return call(api.POST("/assigned-tasks/{assigned_task_id}/guides", {
      params: { path: { assigned_task_id } }, body: { kind: data.kind }, bodySerializer: () => form,
    }));
  });
}
export function useSuaHuongDan(assigned_task_guide_id: number) {
  const api = useApi();
  return useGhi("assigned-task-guides", (body: K["UpdateAssignedTaskGuide"]) => call(api.PUT("/assigned-task-guides/{assigned_task_guide_id}", { params: { path: { assigned_task_guide_id } }, body })));
}
export function useAnHuongDan(assigned_task_guide_id: number) {
  const api = useApi();
  return useGhi("assigned-task-guides", (body: K["HideTrainingItem"]) => call(api.POST("/assigned-task-guides/{assigned_task_guide_id}/hiding", { params: { path: { assigned_task_guide_id } }, body })));
}
export function loiDaoTao(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại để kiểm tra, không gửi lại.";
  if (daDoi(f)) return "Dữ liệu đã đổi hoặc không còn tồn tại. Đã yêu cầu đọc lại.";
  switch (f.code) {
    case "person_not_found": return "Không tìm thấy người này. Hãy chọn người khác.";
    case "assigned_task_hidden": return "Việc này đã ẩn, không gắn thêm hướng dẫn được.";
    case "file_too_large": return "Tệp quá lớn: ảnh tối đa 10 MiB, video tối đa 100 MiB.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại ô này.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiDaoTao(f: ApiFailure) {
  if (f.kind !== "rejected") return undefined;
  return f.code === "person_not_found" ? "trainee_person_id" : f.code === "file_too_large" ? "file" : f.field;
}
