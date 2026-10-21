"use client";

import { useId } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import type { components } from "@/lib/api/schema";
import { tien } from "./dong-mon-da-ghi";

type Mon = components["schemas"]["MenuItem"];
export type DongSoan = { mon: Mon; quantity: number; option_ids: number[]; is_takeaway: boolean };
export function giaDong(dong: DongSoan) {
  return dong.mon.prices.find((p) => p.option_ids.length === dong.option_ids.length && p.option_ids.every((id) => dong.option_ids.includes(id)));
}
export function BoSoanMon({ items, lines, onChange, mangVe }: {
  items: Mon[]; lines: DongSoan[]; onChange: (lines: DongSoan[]) => void; mangVe: boolean;
}) {
  const id = useId();
  const sua = (i: number, thay: Partial<DongSoan>) => onChange(lines.map((d, j) => j === i ? { ...d, ...thay } : d));
  return <div className="space-y-4">
    <div className="flex flex-wrap gap-2">{items.map((mon) => <Button type="button" key={mon.menu_item_id} onClick={() => onChange([...lines, {
      mon, quantity: 1, is_takeaway: false, option_ids: mon.option_groups.flatMap((g) => g.options.filter((o) => o.is_default).map((o) => o.menu_option_id)),
    }])}>Thêm {mon.item_name}</Button>)}</div>
    {lines.map((dong, i) => <section key={i} aria-label={`Dòng ${i + 1}`} className="space-y-3 rounded-lg border p-4">
      <h2>{dong.mon.item_name}</h2>
      {dong.mon.option_groups.map((g) => <fieldset key={g.option_group_id} className="space-x-3">
        <legend>{g.option_group_name}</legend>
        {g.options.map((o) => <label key={o.menu_option_id} className="inline-flex min-h-11 items-center gap-2">
          <input type="radio" name={`${id}-${i}-${g.option_group_id}`} checked={dong.option_ids.includes(o.menu_option_id)} onChange={() => sua(i, {
            option_ids: [...dong.option_ids.filter((v) => !g.options.some((x) => x.menu_option_id === v)), o.menu_option_id],
          })} />{o.option_name}
        </label>)}
      </fieldset>)}
      <label className="block">Số lượng<Input type="number" min={1} step={1} value={Number.isNaN(dong.quantity) ? "" : dong.quantity} onChange={(e) => sua(i, { quantity: e.target.valueAsNumber })} /></label>
      {mangVe && <label className="flex min-h-11 items-center gap-2"><input type="checkbox" checked={dong.is_takeaway} onChange={(e) => sua(i, { is_takeaway: e.target.checked })} />Mang về</label>}
      <p>{giaDong(dong) ? `Giá đơn vị ${tien(giaDong(dong)!.unit_price_vnd)}` : "Chưa có giá cho tổ hợp đã chọn."}</p>
      <Button type="button" variant="outline" onClick={() => onChange(lines.filter((_, j) => j !== i))}>Xoá dòng {i + 1}</Button>
    </section>)}
  </div>;
}
