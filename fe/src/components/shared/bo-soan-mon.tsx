"use client";

import { useId } from "react";
import { useQueries } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { tien } from "./dong-mon-da-ghi";

type Mon = components["schemas"]["MenuItem"];
type Combo = components["schemas"]["MenuSaleCombo"];
type Nhom = components["schemas"]["MenuOptionGroup"];
type Suat = { mon: Combo["items"][number]; option_ids: number[] };
export type DongSoan = { quantity: number; is_takeaway: boolean } & (
  { mon: Mon; option_ids: number[]; combo?: never } |
  { combo: Combo; portions: Suat[]; mon?: never }
);
const coMat = (g: Nhom, ids: number[]) => !g.prerequisite_option_ids.length || g.prerequisite_option_ids.some((v) => ids.includes(v));
export function chonNhom(groups: Nhom[], ids: number[]) {
  let ketQua = ids;
  // Lặp tới khi đứng yên: nhóm có điều kiện có thể phụ thuộc nhóm đứng sau nó trong menu.
  for (let i = 0; i <= groups.length; i++) {
    const moi = groups.flatMap((g) => coMat(g, ketQua)
      ? g.options.filter((o) => ketQua.includes(o.menu_option_id) || (!g.options.some((x) => ketQua.includes(x.menu_option_id)) && o.is_default)).map((o) => o.menu_option_id)
      : []);
    if (JSON.stringify(moi) === JSON.stringify(ketQua)) break;
    ketQua = moi;
  }
  return ketQua;
}
export function soSuat(combo: Combo, quantity: number, cu: Suat[] = []): Suat[] {
  if (!Number.isInteger(quantity) || quantity < 1) return cu;
  return combo.items.flatMap((mon) => {
    const con = cu.filter((p) => p.mon.menu_item_id === mon.menu_item_id);
    return Array.from({ length: mon.quantity * quantity }, (_, k) => con[k] ?? { mon, option_ids: chonNhom(mon.option_groups, []) });
  });
}
export function dongGui(d: DongSoan): components["schemas"]["PriceLineRequest"] {
  if (!d.combo) return { menu_item_id: d.mon.menu_item_id, quantity: d.quantity, option_ids: [...d.option_ids] };
  const portions: components["schemas"]["PriceLinePortion"][] = [];
  for (const p of d.portions) {
    const ids = [...p.option_ids].sort((a, b) => a - b);
    const cu = portions.find((v) => v.menu_item_id === p.mon.menu_item_id && JSON.stringify(v.option_ids) === JSON.stringify(ids));
    if (cu) cu.quantity += 1;
    else portions.push({ menu_item_id: p.mon.menu_item_id, quantity: 1, option_ids: ids });
  }
  return { menu_combo_id: d.combo.menu_combo_id, quantity: d.quantity, portions };
}
export function loiCombo(code: string) {
  switch (code) {
    case "menu_combo_hidden": return "Combo đã ẩn. Hãy kiểm tra lại phiếu.";
    case "menu_combo_not_found": return "Không tìm thấy combo. Hãy kiểm tra lại phiếu.";
    case "combo_portions_mismatch": return "Số suất trong combo không khớp. Hãy kiểm tra lại phiếu.";
    case "menu_option_hidden": return "Có lựa chọn đã ẩn. Hãy kiểm tra lại phiếu.";
  }
}
// monLe: trang khách cần cả giá dòng món lẻ cho cột Giá; tiền vẫn do backend tính.
export function useGiaCombo(lines: DongSoan[], monLe = false) {
  const api = useApi();
  // Khoá kèm chỉ số dòng: hai dòng giống hệt nhau không thành truy vấn trùng.
  return useQueries({ queries: lines.map((d, i) => {
    const body = { lines: [dongGui(d)] };
    return { queryKey: ["gia-combo", i, body], enabled: (monLe || !!d.combo) && Number.isInteger(d.quantity) && d.quantity > 0, retry: false,
      queryFn: async () => {
        const r = await call(api.POST("/price-quotes", { body }));
        if (!r.ok) throw new Error(r.failure.kind === "rejected" ? loiCombo(r.failure.code) ?? `Chưa tính được giá. Mã: ${r.failure.code}` : "Chưa tính được giá…");
        const dong = r.data.lines[0];
        if (!dong || !Number.isFinite(dong.line_total_vnd)) throw new Error("Chưa tính được giá…");
        return dong.line_total_vnd;
      },
    };
  }) });
}
export function giaDong(dong: DongSoan) {
  if (dong.combo) return undefined;
  return dong.mon.prices.find((p) => p.option_ids.length === dong.option_ids.length && p.option_ids.every((id) => dong.option_ids.includes(id)));
}
export function LuaChon({ groups, ids, name, onChange }: { groups: Nhom[]; ids: number[]; name: string; onChange: (ids: number[]) => void }) {
  return groups.filter((g) => coMat(g, ids)).map((g) => <fieldset key={g.option_group_id} className="space-x-3">
    <legend>{g.option_group_name}</legend>
    {g.options.map((o) => <label key={o.menu_option_id} className="inline-flex min-h-11 items-center gap-2">
      <input type="radio" name={`${name}-${g.option_group_id}`} checked={ids.includes(o.menu_option_id)} onChange={() => onChange(chonNhom(groups,
        [...ids.filter((v) => !g.options.some((x) => x.menu_option_id === v)), o.menu_option_id]))} />{o.option_name}
    </label>)}
  </fieldset>);
}
export function BoSoanMon({ items, combos = [], lines, onChange, mangVe, quotes }: {
  items: Mon[]; combos?: Combo[]; lines: DongSoan[]; onChange: (lines: DongSoan[]) => void; mangVe: boolean; quotes: ReturnType<typeof useGiaCombo>;
}) {
  const id = useId();
  const sua = (i: number, dong: DongSoan) => onChange(lines.map((d, j) => j === i ? dong : d));
  return <div className="space-y-4">
    <div className="flex flex-wrap gap-2">{items.map((mon) => <Button type="button" key={mon.menu_item_id} onClick={() => onChange([...lines, {
      mon, quantity: 1, is_takeaway: false, option_ids: chonNhom(mon.option_groups, []),
    }])}>Thêm {mon.item_name}</Button>)}
      {combos.map((combo) => <Button type="button" key={combo.menu_combo_id} onClick={() => onChange([...lines, {
        combo, quantity: 1, is_takeaway: false, portions: soSuat(combo, 1),
      }])}>Thêm combo {combo.name}</Button>)}
    </div>
    {lines.map((dong, i) => <section key={i} aria-label={`Dòng ${i + 1}`} className="space-y-3 rounded-lg border p-4">
      <h2>{dong.combo ? dong.combo.name : dong.mon.item_name}</h2>
      {dong.combo ? dong.portions.map((p, k) => <fieldset key={k} className="space-y-2 rounded border p-3">
        <legend>{p.mon.item_name} suất {dong.portions.slice(0, k + 1).filter((s) => s.mon.menu_item_id === p.mon.menu_item_id).length}</legend>
        <LuaChon groups={p.mon.option_groups} ids={p.option_ids} name={`${id}-${i}-${k}`} onChange={(option_ids) => sua(i, {
          ...dong, portions: dong.portions.map((s, j) => j === k ? { ...s, option_ids } : s),
        })} />
      </fieldset>) : <LuaChon groups={dong.mon.option_groups} ids={dong.option_ids} name={`${id}-${i}`} onChange={(option_ids) => sua(i, { ...dong, option_ids })} />}
      <label className="block">Số lượng<Input type="number" min={1} step={1} value={Number.isNaN(dong.quantity) ? "" : dong.quantity} onChange={(e) => {
        const quantity = e.target.valueAsNumber;
        sua(i, dong.combo ? { ...dong, quantity, portions: soSuat(dong.combo, quantity, dong.portions) } : { ...dong, quantity });
      }} /></label>
      {mangVe && <label className="flex min-h-11 items-center gap-2"><input type="checkbox" checked={dong.is_takeaway} onChange={(e) => sua(i, { ...dong, is_takeaway: e.target.checked })} />Mang về</label>}
      {dong.combo ? <p>{quotes[i].isFetching ? "Đang tính giá…" : quotes[i].error ? quotes[i].error.message : quotes[i].data !== undefined ? `Giá dòng ${tien(quotes[i].data)}` : "Chưa tính được giá…"}</p>
        : <p>{giaDong(dong) ? `Giá đơn vị ${tien(giaDong(dong)!.unit_price_vnd)}` : "Chưa có giá cho tổ hợp đã chọn."}</p>}
      <Button type="button" variant="outline" onClick={() => onChange(lines.filter((_, j) => j !== i))}>Xoá dòng {i + 1}</Button>
    </section>)}
  </div>;
}
