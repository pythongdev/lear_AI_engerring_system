"use client";

import Link from "next/link";
import { useId, useRef, useState, type ReactNode } from "react";
import { Input } from "@/components/ui/input";
import { chonNhom, LuaChon, soSuat, giaDong, type DongSoan, useGiaCombo } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import type { components } from "@/lib/api/schema";
import { Package, Trash2, UtensilsCrossed } from "lucide-react";

type Mon = components["schemas"]["MenuItem"];
type Combo = components["schemas"]["MenuSaleCombo"];
type Nhom = Mon["option_groups"][number];
// Chỉ đổi nhãn trình bày; mã lựa chọn và giá trị mặc định vẫn lấy từ menu.
const nhanNhom = (groups: Nhom[]) => groups.map((g) => ({ ...g, options: g.options.map((o) => ({
  ...o, option_name: g.option_group_name === "Lượng nhân" && o.option_name === "Thường" ? "Vừa" : g.option_group_name === "Lượng nhân" && o.option_name === "Nhiều nhân" ? "Nhiều" : o.option_name,
})) }));
const moTa = (groups: Nhom[], ids: number[]) => nhanNhom(groups).flatMap((g) => g.options.filter((o) => ids.includes(o.menu_option_id)).map((o) => o.option_name)).join(" · ");
// Khi tăng số combo trong tóm tắt, suất mới giữ lựa chọn của combo đã thêm.
function suatKhach(combo: Combo, quantity: number, cu: ReturnType<typeof soSuat>) {
  return soSuat(combo, quantity, cu).map((p) => {
    const mau = cu.find((v) => v.mon.menu_item_id === p.mon.menu_item_id);
    return !cu.includes(p) && mau ? { ...p, option_ids: [...mau.option_ids] } : p;
  });
}
const timTen = (ten: string) => ten.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/gi, "d").toLowerCase();

// Ô số lượng bị xoá trống là NaN; đếm như 0 để thẻ và dải giỏ không hiện NaN.
const so = (d: DongSoan) => Number.isFinite(d.quantity) ? d.quantity : 0;
export function ThucDonKhach({ items, combos = [], lines, onChange, quotes, total, thongTin, tong, maBan }: {
  maBan?: string; items: Mon[]; combos?: Combo[]; lines: DongSoan[]; onChange: (lines: DongSoan[]) => void;
  quotes: ReturnType<typeof useGiaCombo>; total?: number; thongTin: ReactNode; tong: ReactNode;
}) {
  const chiTiet = (loai: "combo" | "mon", ma: number) => `/thuc-don/${loai}/${ma}${maBan === undefined ? "" : `?ban=${encodeURIComponent(maBan)}`}`;
  const id = useId();
  const summary = useRef<HTMLElement>(null);
  const [tim, setTim] = useState("");
  const [luaChon, setLuaChon] = useState<Record<string, number[]>>({});
  const nhomCombo = (combo: Combo) => Array.from(new Map(combo.items.flatMap((m) => m.option_groups).map((g) => [g.option_group_id, g])).values());
  const daChon = (key: string, groups: Nhom[]) => chonNhom(groups, luaChon[key] ?? []);
  const boChon = (key: string, groups: Nhom[]) => <div className="choices col-start-2 col-end-4 text-right">
    <LuaChon groups={nhanNhom(groups)} ids={daChon(key, groups)} name={`${id}-${key}`} onChange={(ids) => setLuaChon((cu) => ({ ...cu, [key]: ids }))} />
  </div>;
  const sua = (i: number, dong: DongSoan) => onChange(lines.map((d, j) => j === i ? dong : d));
  const monLoc = items.filter((m) => timTen(m.item_name).includes(timTen(tim)));
  const comboLoc = combos.filter((c) => timTen(c.name).includes(timTen(tim)));
  function stepper(ten: string, matches: (d: DongSoan) => boolean, them: () => void, combo = false) {
    const count = lines.filter(matches).reduce((n, d) => n + so(d), 0);
    const cuoi = lines.findLastIndex(matches);
    return <div className="stepper inline-flex items-center gap-[6px] whitespace-nowrap">
      <button type="button" aria-label={`Bớt ${ten}`} disabled={cuoi < 0} onClick={() => {
        const dong = lines[cuoi];
        const quantity = so(dong) - 1;
        if (quantity <= 0) onChange(lines.filter((_, i) => i !== cuoi));
        else sua(cuoi, dong.combo ? { ...dong, quantity, portions: suatKhach(dong.combo, quantity, dong.portions) } : { ...dong, quantity });
      }}>−</button>
      <output className="min-w-6 text-center text-[14px]">{count}</output>
      <button type="button" aria-label={`Thêm ${combo ? "combo " : ""}${ten}`} onClick={them}>＋</button>
    </div>;
  }
  function giaMon(mon: Mon) {
    if (!mon.prices.length) return null;
    const min = Math.min(...mon.prices.map((p) => p.unit_price_vnd));
    return <p className="mb-[6px] whitespace-nowrap text-[14px] text-[var(--accent)]">{mon.prices.every((p) => p.unit_price_vnd === min) ? "" : "từ "}{tien(min)}</p>;
  }
  return <>
    <div data-component="MiniCartStrip" className="sticky top-0 z-5 flex h-[50px] items-center gap-2 border-b border-[var(--line)] bg-[var(--bg)]">
      <button className="shrink-0 rounded-[20px] border-0 bg-[var(--accent)] px-[9px] py-1 text-[11px] whitespace-nowrap text-[#fff]" type="button" onClick={() => { summary.current?.scrollIntoView({ block: "start" }); summary.current?.focus(); }}>{lines.reduce((n, d) => n + so(d), 0)} món</button>
      <div className="chips flex min-w-0 flex-1 gap-[6px] overflow-auto">{lines.map((d, i) => <span className="rounded-2xl bg-[var(--field)] px-2 py-1 text-[10px] whitespace-nowrap" key={i}>{d.combo ? d.combo.name : d.mon.item_name} ×{so(d)}</span>)}</div>
      <span className="mb-[6px] whitespace-nowrap text-[14px] text-[var(--accent)]">{total === undefined ? "" : tien(total)}</span>
    </div>
    <input data-component="SearchBar" className="my-[14px] h-[34px] w-full rounded-lg border-0 bg-[var(--field)] px-3" type="search" aria-label="Tìm món nhanh" placeholder="🔍   Tìm món nhanh..." value={tim} onChange={(e) => setTim(e.target.value)} />
    {!monLoc.length && !comboLoc.length && <p>Không có món nào khớp.</p>}
    {comboLoc.length > 0 && <section data-component="ComboSection">
      <h2 className="mt-3 mb-2 text-[12px] text-[var(--muted)]">COMBO</h2>
      {comboLoc.map((combo) => <article className="card mb-3 grid min-h-[142px] grid-cols-[80px_minmax(0,1fr)_110px] gap-3 rounded-[10px] border border-[var(--line)] bg-[var(--card)] p-3" data-component="ComboCard" key={combo.menu_combo_id}>
        <Link href={chiTiet("combo", combo.menu_combo_id)} aria-label={`Xem chi tiết combo ${combo.name}`} className="thumb grid h-20 place-items-center rounded-lg bg-[var(--field)] text-[var(--muted)]"><Package aria-hidden="true" size={26} /></Link>
        <div className="min-w-0"><h3 className="mb-[5px] text-[14px] leading-[1.4] font-medium wrap-anywhere">{combo.name}</h3><ul className="text-[11px] text-[var(--muted)]">{combo.items.map((m) => <li className="mb-[3px] flex items-center gap-[6px]" key={m.menu_item_id}><span className="rounded-[5px] bg-[var(--badge)] px-[5px] py-px text-[10px] whitespace-nowrap text-[var(--accent)]">×{m.quantity}</span> {m.item_name}</li>)}</ul></div>
        <div className="text-right"><p className="mb-[6px] whitespace-nowrap text-[14px] text-[var(--accent)]">{tien(combo.price_vnd)}</p>{stepper(combo.name, (d) => d.combo?.menu_combo_id === combo.menu_combo_id, () => onChange([...lines, { combo, quantity: 1, is_takeaway: false, portions: soSuat(combo, 1).map((p) => ({ ...p, option_ids: chonNhom(p.mon.option_groups, daChon(`combo-${combo.menu_combo_id}`, nhomCombo(combo))) })) }]), true)}</div>
        {nhomCombo(combo).length > 0 && boChon(`combo-${combo.menu_combo_id}`, nhomCombo(combo))}
      </article>)}
    </section>}
    {monLoc.length > 0 && <section data-component="ProductList">
      <h2 className="mt-3 mb-2 text-[12px] text-[var(--muted)]">MÓN LẺ</h2>
      {monLoc.map((mon) => <article className="card mb-3 grid min-h-[142px] grid-cols-[80px_minmax(0,1fr)_110px] gap-3 rounded-[10px] border border-[var(--line)] bg-[var(--card)] p-3" data-component="ProductCard" key={mon.menu_item_id}>
        <Link href={chiTiet("mon", mon.menu_item_id)} aria-label={`Xem chi tiết món ${mon.item_name}`} className="thumb grid h-20 place-items-center rounded-lg bg-[var(--field)] text-[var(--muted)]"><UtensilsCrossed aria-hidden="true" size={26} /></Link>
        <h3 className="mb-[5px] text-[14px] leading-[1.4] font-medium wrap-anywhere">{mon.item_name}</h3><div className="text-right">{giaMon(mon)}{stepper(mon.item_name, (d) => d.mon?.menu_item_id === mon.menu_item_id, () => onChange([...lines, { mon, quantity: 1, is_takeaway: false, option_ids: daChon(`mon-${mon.menu_item_id}`, mon.option_groups) }]))}</div>
        {mon.option_groups.length > 0 && boChon(`mon-${mon.menu_item_id}`, mon.option_groups)}
      </article>)}
    </section>}
    {thongTin}
    <section ref={summary} tabIndex={-1} className="summary mt-3 scroll-mt-16 rounded-[10px] border border-[var(--line)] bg-[var(--card)] p-3" data-component="OrderSummary">
      <h2 className="text-[14px] font-medium">Tóm tắt đơn hàng</h2>
      {[true, false].filter((comboGroup) => lines.some((d) => !!d.combo === comboGroup)).map((comboGroup) => <div key={String(comboGroup)}>
        <h3 className="mt-3 mb-2 text-[12px] text-[var(--muted)]">{comboGroup ? "COMBO" : "MÓN LẺ"}</h3>
    {lines.map((dong, i) => (!!dong.combo === comboGroup) && <section key={i} aria-label={`Dòng ${i + 1}`} className="border-b border-[var(--line)] py-3">
      <div className="flex items-center gap-[6px]">
        <h3 className="min-w-0 flex-1 text-[13px] wrap-anywhere">{dong.combo ? dong.combo.name : dong.mon.item_name}</h3>
        <label className="shrink-0"><span className="sr-only">Số lượng</span><Input className="quantity" type="number" min={1} step={1} value={Number.isNaN(dong.quantity) ? "" : dong.quantity} onChange={(e) => {
          const quantity = e.target.valueAsNumber;
          sua(i, dong.combo ? { ...dong, quantity, portions: suatKhach(dong.combo, quantity, dong.portions) } : { ...dong, quantity });
        }} /></label>
        <div className="max-w-[100px] text-[10px] text-[var(--muted)]">
          {dong.combo ? <p>{quotes[i].isFetching ? "Đang tính giá…" : quotes[i].error ? quotes[i].error.message : quotes[i].data !== undefined ? `Giá dòng ${tien(quotes[i].data)}` : "Chưa tính được giá…"}</p>
            : <p>{giaDong(dong) ? `Giá đơn vị ${tien(giaDong(dong)!.unit_price_vnd)}` : "Chưa có giá cho tổ hợp đã chọn."}</p>}
        </div>
        <button className="shrink-0 border-0 p-0 text-[var(--muted)]" type="button" aria-label={`Xoá dòng ${i + 1}`} onClick={() => onChange(lines.filter((_, j) => j !== i))}><Trash2 size={14} aria-hidden="true" /></button>
      </div>
      <div className="mt-2 text-[11px] text-[var(--muted)]">
        {dong.combo ? dong.portions.map((p, k) => <p key={k}>
          {p.mon.item_name} suất {dong.portions.slice(0, k + 1).filter((v) => v.mon.menu_item_id === p.mon.menu_item_id).length}
          {p.option_ids.length > 0 ? `: ${moTa(p.mon.option_groups, p.option_ids)}` : ""}
        </p>) : <p>{moTa(dong.mon.option_groups, dong.option_ids)}</p>}
      </div>
    </section>)}
      </div>)}
      <div className="mt-3 border-t border-[var(--line)] pt-[10px] text-[13px]">{tong}</div>
    </section>
  </>;
}
