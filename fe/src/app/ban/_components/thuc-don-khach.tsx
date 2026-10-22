"use client";

import { useId, useRef, useState, type ReactNode } from "react";
import { Input } from "@/components/ui/input";
import { chonNhom, LuaChon, soSuat, giaDong, type DongSoan, useGiaCombo } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import type { components } from "@/lib/api/schema";
import styles from "./thuc-don-khach.module.css";

type Mon = components["schemas"]["MenuItem"];
type Combo = components["schemas"]["MenuSaleCombo"];
const timTen = (ten: string) => ten.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/gi, "d").toLowerCase();

// Ô số lượng bị xoá trống là NaN; đếm như 0 để thẻ và dải giỏ không hiện NaN.
const so = (d: DongSoan) => Number.isFinite(d.quantity) ? d.quantity : 0;
export function ThucDonKhach({ items, combos = [], lines, onChange, quotes, total, thongTin, tong }: {
  items: Mon[]; combos?: Combo[]; lines: DongSoan[]; onChange: (lines: DongSoan[]) => void;
  quotes: ReturnType<typeof useGiaCombo>; total?: number; thongTin: ReactNode; tong: ReactNode;
}) {
  const id = useId();
  const summary = useRef<HTMLElement>(null);
  const [tim, setTim] = useState("");
  const sua = (i: number, dong: DongSoan) => onChange(lines.map((d, j) => j === i ? dong : d));
  const monLoc = items.filter((m) => timTen(m.item_name).includes(timTen(tim)));
  const comboLoc = combos.filter((c) => timTen(c.name).includes(timTen(tim)));
  function stepper(ten: string, matches: (d: DongSoan) => boolean, them: () => void, combo = false) {
    const count = lines.filter(matches).reduce((n, d) => n + so(d), 0);
    const cuoi = lines.findLastIndex(matches);
    return <div className={styles.stepper}>
      <button type="button" aria-label={`Bớt ${ten}`} disabled={cuoi < 0} onClick={() => {
        const dong = lines[cuoi];
        const quantity = so(dong) - 1;
        if (quantity <= 0) onChange(lines.filter((_, i) => i !== cuoi));
        else sua(cuoi, dong.combo ? { ...dong, quantity, portions: soSuat(dong.combo, quantity, dong.portions) } : { ...dong, quantity });
      }}>−</button>
      <output>{count}</output>
      <button type="button" aria-label={`Thêm ${combo ? "combo " : ""}${ten}`} onClick={them}>＋</button>
    </div>;
  }
  function giaMon(mon: Mon) {
    if (!mon.prices.length) return null;
    const min = Math.min(...mon.prices.map((p) => p.unit_price_vnd));
    return <p className={styles.price}>{mon.prices.every((p) => p.unit_price_vnd === min) ? "" : "từ "}{tien(min)}</p>;
  }
  return <>
    <div data-component="MiniCartStrip" className={styles.mini}>
      <button type="button" onClick={() => { summary.current?.scrollIntoView({ block: "start" }); summary.current?.focus(); }}>{lines.reduce((n, d) => n + so(d), 0)} món</button>
      <div className={styles.chips}>{lines.map((d, i) => <span key={i}>{d.combo ? d.combo.name : d.mon.item_name} ×{so(d)}</span>)}</div>
      <span className={styles.price}>{total === undefined ? "" : tien(total)}</span>
    </div>
    <input data-component="SearchBar" className={styles.search} type="search" aria-label="Tìm món nhanh" placeholder="Tìm món nhanh" value={tim} onChange={(e) => setTim(e.target.value)} />
    {!monLoc.length && !comboLoc.length && <p>Không có món nào khớp.</p>}
    <section data-component="ComboSection">
      <h2 className={styles.label}>COMBO</h2>
      {comboLoc.map((combo) => <article className={styles.card} data-component="ComboCard" key={combo.menu_combo_id}>
        <div><h3>{combo.name}</h3><ul>{combo.items.map((m) => <li key={m.menu_item_id}><span className={styles.badge}>×{m.quantity}</span> {m.item_name}</li>)}</ul></div>
        <div><p className={styles.price}>{tien(combo.price_vnd)}</p>{stepper(combo.name, (d) => d.combo?.menu_combo_id === combo.menu_combo_id, () => onChange([...lines, { combo, quantity: 1, is_takeaway: false, portions: soSuat(combo, 1) }]), true)}</div>
      </article>)}
    </section>
    <section data-component="ProductList">
      <h2 className={styles.label}>MÓN LẺ</h2>
      {monLoc.map((mon) => <article className={styles.card} data-component="ProductCard" key={mon.menu_item_id}>
        <h3>{mon.item_name}</h3><div>{giaMon(mon)}{stepper(mon.item_name, (d) => d.mon?.menu_item_id === mon.menu_item_id, () => onChange([...lines, { mon, quantity: 1, is_takeaway: false, option_ids: chonNhom(mon.option_groups, []) }]))}</div>
      </article>)}
    </section>
    {thongTin}
    <section ref={summary} tabIndex={-1} className={styles.summary} data-component="OrderSummary">
      <h2>Tóm tắt đơn hàng</h2>
      {[true, false].filter((comboGroup) => lines.some((d) => !!d.combo === comboGroup)).map((comboGroup) => <div key={String(comboGroup)}>
        <h3 className={styles.label}>{comboGroup ? "COMBO" : "MÓN LẺ"}</h3>
    {lines.map((dong, i) => (!!dong.combo === comboGroup) && <section key={i} aria-label={`Dòng ${i + 1}`} className="space-y-3 rounded-lg border p-4">
      <h3>{dong.combo ? dong.combo.name : dong.mon.item_name}</h3>
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
      {dong.combo ? <p>{quotes[i].isFetching ? "Đang tính giá…" : quotes[i].error ? quotes[i].error.message : quotes[i].data !== undefined ? `Giá dòng ${tien(quotes[i].data)}` : "Chưa tính được giá…"}</p>
        : <p>{giaDong(dong) ? `Giá đơn vị ${tien(giaDong(dong)!.unit_price_vnd)}` : "Chưa có giá cho tổ hợp đã chọn."}</p>}
      <button type="button" onClick={() => onChange(lines.filter((_, j) => j !== i))}>Xoá dòng {i + 1}</button>
    </section>)}
      </div>)}
      {tong}
    </section>
  </>;
}
