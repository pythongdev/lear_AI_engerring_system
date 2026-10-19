"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { call, type ApiFailure, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

export type Viec = components["schemas"]["AssignedTask"];
export type TaoViec = components["schemas"]["CreateAssignedTask"];
export type SuaViec = components["schemas"]["UpdateAssignedTask"];
export type AnViec = components["schemas"]["HideAssignedTask"];
type DanhDau = components["schemas"]["MarkAssignedTask"];
export const daDoi = (f: ApiFailure) => f.kind === "rejected" && [
  "assigned_task_not_found", "assigned_task_hidden", "assigned_task_already_done", "assigned_task_not_done",
].includes(f.code);

export function useViec(assignee_person_id?: number) {
  const api = useApi();
  return useQuery({ queryKey: ["assigned-tasks", { assignee_person_id }], queryFn: async () => {
    const r = await call(api.GET("/assigned-tasks", { params: { query: { assignee_person_id } } }));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
}
function useGhi<B>(gui: (body: B) => Promise<ApiResult<Viec>>) {
  const qc = useQueryClient();
  return useMutation({ mutationFn: gui, retry: false, onSuccess: async (r) => {
    if (r.ok || daDoi(r.failure)) await qc.invalidateQueries({ queryKey: ["assigned-tasks"] });
  } });
}
export function useTaoViec() {
  const api = useApi();
  return useGhi((body: TaoViec) => call(api.POST("/assigned-tasks", { body })));
}
export function useSuaViec(assigned_task_id: number) {
  const api = useApi();
  return useGhi((body: SuaViec) => call(api.PUT("/assigned-tasks/{assigned_task_id}", { params: { path: { assigned_task_id } }, body })));
}
export function useAnViec(assigned_task_id: number) {
  const api = useApi();
  return useGhi((body: AnViec) => call(api.POST("/assigned-tasks/{assigned_task_id}/hiding", { params: { path: { assigned_task_id } }, body })));
}
export function useDanhDau(assigned_task_id: number) {
  const api = useApi();
  return useGhi((body: DanhDau) => call(api.POST("/assigned-tasks/{assigned_task_id}/marks", { params: { path: { assigned_task_id } }, body })));
}
export function loiGiaoViec(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Hãy đọc lại danh sách để kiểm tra; không gửi lại lúc này.";
  if (daDoi(f)) return "Trạng thái việc đã đổi. Đã yêu cầu đọc lại danh sách.";
  switch (f.code) {
    case "person_not_found": return "Người nhận không còn tồn tại. Hãy chọn người khác.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại ô này.";
    case "unauthenticated": return "Phiên đăng nhập đã kết thúc. Hãy đăng nhập lại.";
    default: return "Không lưu được. Mã: " + f.code;
  }
}
export function oLoiGiaoViec(f: ApiFailure) {
  if (f.kind !== "rejected" || daDoi(f)) return undefined;
  return f.code === "person_not_found" ? "assignee_person_id" : f.field;
}
