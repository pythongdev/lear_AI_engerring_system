"use client";

import { useId, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { chonNhom, dongGui, soSuat } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { doiSoLuong, guiDong, useGhiYeuThich, type Bo, type Dong, type DongGui, type Menu } from "./du-lieu";
import { LuaChonDanhSach } from "./lua-chon";
import { MoTaDong, tenDong } from "./the";

export type HopBo = { kind: "da_luu"; lines: Dong[] } | { kind: "rieng"; bo?: Bo };
type DongNhap = { dong: DongGui; available: boolean; selected: boolean };

// Mã dòng và số lượng không thuộc hình món; hai nguồn có cùng hình chỉ tạo một hàng.
function khoaHinh(d: DongGui) {
  const portions = new Map<string, { item: number; quantity: number; options: number[] }>();
  for (const p of d.portions ?? []) {
    const options = [...p.option_ids].sort((a, b) => a - b);
    const key = JSON.stringify([p.menu_item_id, options]);
    const cu = portions.get(key);
    if (cu) cu.quantity += p.quantity;
    else portions.set(key, { item: p.menu_item_id, quantity: p.quantity, options });
  }
  return JSON.stringify(d.menu_combo_id !== undefined
    ? { combo: d.menu_combo_id, portions: [...portions.values()].sort((a, b) => a.item - b.item || JSON.stringify(a.options).localeCompare(JSON.stringify(b.options))) }
    : { item: d.menu_item_id, options: [...(d.option_ids ?? [])].sort((a, b) => a - b) });
}

function taoDanhSach(menu: Menu, yeuThich: Dong[], bo?: Bo): DongNhap[] {
  const danhSach: DongNhap[] = [];
  function them(dong: DongGui, available: boolean, selected = false) {
    const cu = danhSach.find((v) => khoaHinh(v.dong) === khoaHinh(dong));
    if (cu) {
      if (selected) { cu.dong = dong; cu.available = available; cu.selected = true; }
      return;
    }
    danhSach.push({ dong, available, selected });
  }
  bo?.lines.forEach((d) => them(guiDong(d), d.available, true));
  menu.items.forEach((m) => them({ menu_item_id: m.menu_item_id, option_ids: chonNhom(m.option_groups, []), quantity: 1 }, true));
  menu.combos.forEach((c) => them(dongGui({ combo: c, quantity: 1, is_takeaway: false, portions: soSuat(c, 1) }), true));
  yeuThich.forEach((d) => them({ ...guiDong(d), quantity: 1 }, d.available));
  return danhSach;
}

export function HopSuaBo({ hop, menu, yeuThich, dong, moiDangNhap }: {
  hop: HopBo; menu: Menu; yeuThich: Dong[]; dong: () => void; moiDangNhap: () => void;
}) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap); const id = useId();
  const bo = hop.kind === "rieng" ? hop.bo : undefined;
  const [name, setName] = useState(bo?.name ?? "");
  const [choices, setChoices] = useState<DongNhap[]>(() => hop.kind === "rieng" ? taoDanhSach(menu, yeuThich, bo) :
    hop.lines.filter((d) => d.available).map((d) => ({ dong: guiDong(d), available: true, selected: true })));
  const [kiemTra, setKiemTra] = useState(false);
  const lines = choices.filter((v) => v.selected);
  const quoteLines = lines.filter((v) => v.available).map((v) => v.dong);
  const quote = useQuery({
    queryKey: ["price-quotes", "favourite-draft", quoteLines],
    enabled: hop.kind === "rieng" && quoteLines.length > 0 && quoteLines.length === lines.length,
    retry: false,
    queryFn: async () => {
      const r = await call(api.POST("/price-quotes", { body: { lines: quoteLines } }));
      if (!r.ok || r.data.lines.length !== quoteLines.length || !Number.isFinite(r.data.total_vnd) || r.data.lines.some((line) => !Number.isFinite(line.line_total_vnd))) throw new Error("Chưa tính được giá. Hãy thử lại.");
      return r.data;
    },
  });
  const ten = name.trim();
  const loiTen = !ten || [...ten].length > 60 ? "Tên bộ cần từ 1 đến 60 ký tự." : "";
  const loiDong = !lines.length ? "Hãy chọn ít nhất một món." : lines.length > 20 ? "Mỗi bộ chỉ có tối đa 20 dòng món." : lines.some((d) => !d.available)
    ? "Có món hết bán. Hãy bỏ dòng hết bán trước khi lưu bộ." : lines.some(({ dong: d }) => !Number.isInteger(d.quantity) || d.quantity < 1 || d.quantity > 99) ? "Số lượng phải từ 1 đến 99." : "";
  const sua = (i: number, d: DongGui) => setChoices((cu) => cu.map((v, j) => i === j ? { ...v, dong: d } : v));
  const suaLuaChon = (i: number, option_ids: number[]) => setChoices((cu) => {
    const moi = { ...cu[i], dong: { ...cu[i].dong, option_ids } };
    const trung = cu.findIndex((v, j) => j !== i && khoaHinh(v.dong) === khoaHinh(moi.dong));
    if (trung < 0) return cu.map((v, j) => j === i ? moi : v);
    const cuTrung = cu[trung];
    const quantity = cuTrung.selected && moi.selected ? cuTrung.dong.quantity + moi.dong.quantity : moi.selected ? moi.dong.quantity : cuTrung.dong.quantity;
    if (quantity > 99) return cu;
    return cu.map((v, j) => j === trung ? { ...v, selected: v.selected || moi.selected, dong: { ...v.dong, quantity } } : v).filter((_, j) => j !== i);
  });
  const title = hop.kind === "da_luu" ? "Lưu bộ yêu thích" : bo ? "Sửa bộ món riêng" : "Tạo bộ món riêng";
  async function luu() {
    setKiemTra(true);
    if (loiTen || loiDong) return;
    const body = { name: ten, lines: lines.map((d) => d.dong) };
    const ok = await ghi.gui(() => bo
      ? call(api.PUT("/customer-accounts/current/favourite-sets/{favourite_set_id}", { params: { path: { favourite_set_id: bo.favourite_set_id } }, body }))
      : call(api.POST("/customer-accounts/current/favourite-sets", { body: { kind: hop.kind, ...body } })));
    if (ok) dong();
  }
  return <Dialog open onOpenChange={(open) => { if (!open && !ghi.busy) dong(); }}>
    <DialogContent showCloseButton={false} className="max-h-[calc(100dvh-2rem)] min-w-0 overflow-y-auto">
      <DialogTitle>{title}</DialogTitle><DialogDescription>Chọn món bạn thích và lưu thành bộ món của mình.</DialogDescription>
      <form noValidate className="min-w-0 space-y-4" onSubmit={(e) => { e.preventDefault(); void luu(); }}>
        <fieldset disabled={ghi.busy} className="min-w-0 space-y-4">
          <label className="block space-y-2" htmlFor={`${id}-ten`}>{hop.kind === "da_luu" ? "Tên bộ" : "Tên bộ món"}</label>
          <Input id={`${id}-ten`} value={name} onChange={(e) => setName(e.target.value)} aria-invalid={kiemTra && !!loiTen} aria-describedby={kiemTra && loiTen ? `${id}-loi-ten` : undefined} autoComplete="off" />
          {kiemTra && loiTen && <p id={`${id}-loi-ten`} role="alert">{loiTen}</p>}
          {hop.kind === "rieng" && <fieldset className="min-w-0 space-y-2"><legend className="mb-2 font-semibold">Chọn món và số lượng</legend>
            <div className="min-w-0 divide-y divide-[var(--border)]">{choices.map(({ dong: d, available, selected }, i) => {
              const mon = menu.items.find((m) => m.menu_item_id === d.menu_item_id);
              const tenMon = tenDong(d, menu);
              return <section key={khoaHinh(d)} aria-label={`Lựa chọn ${tenMon}`} className="min-w-0 space-y-2 py-3">
                <div className="flex min-w-0 flex-wrap items-center justify-between gap-2">
                  <label className="flex min-w-0 flex-1 items-center gap-2"><input type="checkbox" className="size-4 shrink-0" checked={selected} disabled={!available && !selected || !selected && lines.length >= 20}
                    onChange={(e) => setChoices((cu) => cu.map((v, j) => j === i ? { ...v, selected: e.target.checked } : v))} />
                    <span className="min-w-0 break-words font-medium">{tenMon}</span></label>
                  <div className="flex shrink-0 items-center rounded-lg border border-[var(--border)]">
                    <Button type="button" variant="ghost" className="min-h-11" aria-label={`Giảm số lượng ${tenMon}`} disabled={!selected || !available || d.quantity <= 1} onClick={() => sua(i, doiSoLuong(d, d.quantity - 1, menu))}>−</Button>
                    <output aria-label={`Số lượng ${tenMon}`} className="min-w-6 text-center">{d.quantity}</output>
                    <Button type="button" variant="ghost" className="min-h-11" aria-label={`Tăng số lượng ${tenMon}`} disabled={!selected || !available || d.quantity >= 99} onClick={() => sua(i, doiSoLuong(d, d.quantity + 1, menu))}>＋</Button>
                  </div>
                </div>
                {!available && <p className="text-sm text-[var(--muted-foreground)]">Hết bán — bỏ chọn trước khi lưu</p>}
                {mon && available && mon.option_groups.length > 0 ? <LuaChonDanhSach groups={mon.option_groups} ids={d.option_ids ?? []} name={tenMon} onChange={(ids) => suaLuaChon(i, ids)} /> : <MoTaDong dong={d} menu={menu} />}
              </section>;
            })}</div>
          </fieldset>}
          {hop.kind === "da_luu" && lines.map(({ dong: d }, i) => <section key={i} aria-label={`Dòng ${i + 1}`} className="space-y-2 rounded-xl border border-[var(--border)] p-3">
            <h3 className="font-semibold">{tenDong(d, menu)}</h3><MoTaDong dong={d} menu={menu} /><p>Số lượng: {d.quantity}</p>
          </section>)}
          {kiemTra && loiDong && <p role="alert">{loiDong}</p>}
        </fieldset>
        {ghi.loi && <p role="alert">{ghi.loi}</p>}
        <div className={hop.kind === "rieng" ? "sticky bottom-0 z-10 space-y-3 border-t border-[var(--border)] bg-[var(--popover)] py-3" : "space-y-3"}>
        {hop.kind === "rieng" && <div className="space-y-1">
          <div className="flex flex-wrap items-center justify-between gap-2"><span>{lines.length ? `${lines.length} món · ${lines.reduce((n, v) => n + v.dong.quantity, 0)} phần` : "Chưa chọn món"}</span>
            <strong className="text-[var(--primary)]">{!lines.length ? "—" : !lines.every((v) => v.available) ? "Có món hết bán" : quote.error ? quote.error.message : quote.isPending || quote.isFetching ? "Đang tính giá…" : quote.data ? tien(quote.data.total_vnd) : "Chưa tính được giá."}</strong></div>
          {quote.error && <Button type="button" variant="outline" className="min-h-11" onClick={() => void quote.refetch()}>Thử lại giá</Button>}
        </div>}
        <div className="flex flex-wrap justify-end gap-2">
          <Button type="button" variant="outline" className="min-h-11" disabled={ghi.busy} onClick={dong}>Huỷ</Button>
          <Button type="submit" className="min-h-11" disabled={ghi.busy || hop.kind === "rieng" && !lines.length}>{ghi.busy ? "Đang lưu…" : hop.kind === "da_luu" ? "Lưu bộ" : "Lưu bộ món"}</Button>
        </div>
        </div>
      </form>
    </DialogContent>
  </Dialog>;
}
