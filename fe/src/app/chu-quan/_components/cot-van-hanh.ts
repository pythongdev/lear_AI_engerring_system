// Ánh xạ theo tên đã chụp — suy ra của Claude 2026-10-21, chờ chủ repo.
import type { components } from "@/lib/api/schema";

export type ThuVanHanh = components["schemas"]["ServiceBoardItem"];
export const tenCot = ["Thịt", "Mộc nhĩ", "Trứng", "Chay", "Canh", "Khác"] as const;
export type CotVanHanh = typeof tenCot[number];

export function cotVanHanh(thu: ThuVanHanh): { cot: CotVanHanh; dong: string } {
  if (thu.component_name === "Bánh cuốn") {
    const nhan = thu.options.find((o) => o.option_group_name === "Nhân")?.option_name;
    if (nhan === "Thịt") return { cot: "Thịt", dong: "" };
    if (nhan === "Thịt + mộc nhĩ") return { cot: "Mộc nhĩ", dong: "" };
    if (nhan === "Chay") return { cot: "Chay", dong: "" };
  }
  if (thu.component_name.startsWith("Trứng ")) return { cot: "Trứng", dong: thu.component_name.slice(6).toLowerCase() };
  if (thu.component_name === "Canh bánh cuốn") return { cot: "Canh", dong: "" };
  return { cot: "Khác", dong: thu.component_name };
}
