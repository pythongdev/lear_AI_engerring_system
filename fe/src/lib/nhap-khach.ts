"use client";

import { create } from "zustand";
import type { DongSoan } from "@/components/shared/bo-soan-mon";
import type { components } from "@/lib/api/schema";

type DongNhap = { quantity: number } & (
  { menu_item_id: number; option_ids: number[]; menu_combo_id?: never } |
  { menu_combo_id: number; portions: { menu_item_id: number; option_ids: number[] }[]; menu_item_id?: never }
);
// Gộp cả khi ghi nháp và khi đọc nháp cũ; thứ tự mã lựa chọn không có ý nghĩa.
function gopMonLe(lines: DongNhap[]): DongNhap[] {
  const result: DongNhap[] = [];
  const positions = new Map<string, number>();
  for (const line of lines) {
    if (line.menu_item_id === undefined || !Number.isSafeInteger(line.quantity) || line.quantity <= 0) {
      result.push(line);
      continue;
    }
    const key = JSON.stringify([line.menu_item_id, [...line.option_ids].sort((a, b) => a - b)]);
    const index = positions.get(key);
    if (index === undefined) {
      positions.set(key, result.length);
      result.push({ ...line });
    } else {
      result[index] = { ...result[index], quantity: result[index].quantity + line.quantity };
    }
  }
  return result;
}

type NhapKhach = {
  gio: Record<string, DongNhap[]>;
  sua: (khoa: string, lines: DongSoan[]) => void;
  xoaHet: () => void;
};
export const useNhapKhach = create<NhapKhach>((set) => ({
  gio: {},
  sua: (khoa, lines) => set((state) => ({ gio: { ...state.gio, [khoa]: gopMonLe(lines.map((d): DongNhap => d.combo
    ? { menu_combo_id: d.combo.menu_combo_id, quantity: d.quantity, portions: d.portions.map((p) => ({ menu_item_id: p.mon.menu_item_id, option_ids: [...p.option_ids] })) }
    : { menu_item_id: d.mon.menu_item_id, quantity: d.quantity, option_ids: [...d.option_ids] })) } })),
  xoaHet: () => set({ gio: {} }),
}));

export function dungLai(nhap: DongNhap[] | undefined, menu: components["schemas"]["Menu"]): DongSoan[] {
  return gopMonLe(nhap ?? []).flatMap((d): DongSoan[] => {
    if (d.menu_combo_id !== undefined) {
      const combo = menu.combos.find((c) => c.menu_combo_id === d.menu_combo_id);
      if (!combo) return [];
      const portions = d.portions.flatMap((p) => {
        const mon = combo.items.find((m) => m.menu_item_id === p.menu_item_id);
        return mon ? [{ mon, option_ids: [...p.option_ids] }] : [];
      });
      return [{ combo, quantity: d.quantity, is_takeaway: false, portions }];
    }
    const mon = menu.items.find((m) => m.menu_item_id === d.menu_item_id);
    return mon ? [{ mon, quantity: d.quantity, is_takeaway: false, option_ids: [...d.option_ids] }] : [];
  });
}
