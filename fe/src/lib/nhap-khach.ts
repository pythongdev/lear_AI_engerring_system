"use client";

import { create } from "zustand";
import type { DongSoan } from "@/components/shared/bo-soan-mon";
import type { components } from "@/lib/api/schema";

type DongNhap = { quantity: number } & (
  { menu_item_id: number; option_ids: number[]; menu_combo_id?: never } |
  { menu_combo_id: number; portions: { menu_item_id: number; option_ids: number[] }[]; menu_item_id?: never }
);
type NhapKhach = {
  gio: Record<string, DongNhap[]>;
  sua: (khoa: string, lines: DongSoan[]) => void;
  xoaHet: () => void;
};
export const useNhapKhach = create<NhapKhach>((set) => ({
  gio: {},
  sua: (khoa, lines) => set((state) => ({ gio: { ...state.gio, [khoa]: lines.map((d): DongNhap => d.combo
    ? { menu_combo_id: d.combo.menu_combo_id, quantity: d.quantity, portions: d.portions.map((p) => ({ menu_item_id: p.mon.menu_item_id, option_ids: [...p.option_ids] })) }
    : { menu_item_id: d.mon.menu_item_id, quantity: d.quantity, option_ids: [...d.option_ids] }) } })),
  xoaHet: () => set({ gio: {} }),
}));

export function dungLai(nhap: DongNhap[] | undefined, menu: components["schemas"]["Menu"]): DongSoan[] {
  return (nhap ?? []).flatMap((d): DongSoan[] => {
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
