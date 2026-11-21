"use client";

import { useId, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { chonNhom, dongGui, LuaChon, soSuat } from "@/components/shared/bo-soan-mon";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { doiSoLuong, guiDong, useGhiYeuThich, type Bo, type Dong, type DongGui, type Menu } from "./du-lieu";
import { MoTaDong, tenDong } from "./the";

export type HopBo = { kind: "da_luu"; lines: Dong[] } | { kind: "rieng"; bo?: Bo };
type DongNhap = { dong: DongGui; available: boolean };

export function HopSuaBo({ hop, menu, dong, moiDangNhap }: { hop: HopBo; menu: Menu; dong: () => void; moiDangNhap: () => void }) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap); const id = useId();
  const bo = hop.kind === "rieng" ? hop.bo : undefined;
  const [name, setName] = useState(bo?.name ?? "");
  const [lines, setLines] = useState<DongNhap[]>(() => (hop.kind === "da_luu" ? hop.lines.filter((d) => d.available) : bo?.lines ?? []).map((d) => ({ dong: guiDong(d), available: d.available })));
  const [kiemTra, setKiemTra] = useState(false);
  const ten = name.trim();
  const loiTen = !ten || [...ten].length > 60 ? "Tên bộ cần từ 1 đến 60 ký tự." : "";
  const loiDong = !lines.length ? "Hãy chọn ít nhất một món." : lines.length > 20 ? "Mỗi bộ chỉ có tối đa 20 dòng món." : lines.some((d) => !d.available)
    ? "Có món hết bán. Hãy bỏ dòng hết bán trước khi lưu bộ." : lines.some(({ dong: d }) => !Number.isInteger(d.quantity) || d.quantity < 1 || d.quantity > 99) ? "Số lượng phải từ 1 đến 99." : "";
  const sua = (i: number, d: DongGui) => setLines((cu) => cu.map((v, j) => i === j ? { ...v, dong: d } : v));
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
    <DialogContent showCloseButton={false} className="max-h-[calc(100dvh-2rem)] overflow-y-auto">
      <DialogTitle>{title}</DialogTitle><DialogDescription>Chọn món bạn thích và lưu thành bộ món của mình.</DialogDescription>
      <form noValidate className="space-y-4" onSubmit={(e) => { e.preventDefault(); void luu(); }}>
        <fieldset disabled={ghi.busy} className="min-w-0 space-y-4">
          <label className="block space-y-2" htmlFor={`${id}-ten`}>{hop.kind === "da_luu" ? "Tên bộ" : "Tên bộ món"}</label>
          <Input id={`${id}-ten`} value={name} onChange={(e) => setName(e.target.value)} aria-invalid={kiemTra && !!loiTen} aria-describedby={kiemTra && loiTen ? `${id}-loi-ten` : undefined} autoComplete="off" />
          {kiemTra && loiTen && <p id={`${id}-loi-ten`} role="alert">{loiTen}</p>}
          {hop.kind === "rieng" && <fieldset className="space-y-2"><legend className="mb-2 font-semibold">Chọn món và số lượng</legend>
            <div className="flex flex-wrap gap-2">
              {menu.items.map((m) => <Button key={m.menu_item_id} type="button" variant="outline" className="min-h-11" disabled={lines.length >= 20} onClick={() => setLines([...lines, { available: true, dong: { menu_item_id: m.menu_item_id, option_ids: chonNhom(m.option_groups, []), quantity: 1 } }])}>Thêm {m.item_name}</Button>)}
              {menu.combos.map((c) => <Button key={c.menu_combo_id} type="button" variant="outline" className="min-h-11" disabled={lines.length >= 20} onClick={() => setLines([...lines, { available: true, dong: dongGui({ combo: c, quantity: 1, is_takeaway: false, portions: soSuat(c, 1) }) }])}>Thêm combo {c.name}</Button>)}
            </div>
          </fieldset>}
          {lines.map(({ dong: d, available }, i) => {
            const mon = menu.items.find((m) => m.menu_item_id === d.menu_item_id);
            return <section key={i} aria-label={`Dòng ${i + 1}`} className="space-y-2 rounded-xl border border-[var(--border)] p-3">
              <h3 className="font-semibold">{tenDong(d, menu)}</h3>
              {!available && <p>Hết bán</p>}
              {hop.kind === "rieng" && available && mon ? <LuaChon groups={mon.option_groups} ids={d.option_ids ?? []} name={`${id}-${i}`} onChange={(option_ids) => sua(i, { ...d, option_ids })} /> : <MoTaDong dong={d} menu={menu} />}
              {hop.kind === "rieng" ? <>
                <label className="block">Số lượng<Input type="number" min={1} max={99} step={1} disabled={!available} value={Number.isNaN(d.quantity) ? "" : d.quantity} onChange={(e) => {
                  const quantity = e.target.valueAsNumber;
                  // Tránh dựng số suất ngoài giới hạn; giá trị sai vẫn hiện để khách sửa.
                  sua(i, Number.isInteger(quantity) && quantity >= 1 && quantity <= 99 ? doiSoLuong(d, quantity, menu) : { ...d, quantity });
                }} /></label>
                <Button type="button" variant="outline" className="min-h-11" onClick={() => setLines(lines.filter((_, j) => j !== i))}>Bỏ dòng {i + 1}</Button>
              </> : <p>Số lượng: {d.quantity}</p>}
            </section>;
          })}
          {kiemTra && loiDong && <p role="alert">{loiDong}</p>}
        </fieldset>
        {ghi.loi && <p role="alert">{ghi.loi}</p>}
        <div className="flex flex-wrap justify-end gap-2">
          <Button type="button" variant="outline" className="min-h-11" disabled={ghi.busy} onClick={dong}>Huỷ</Button>
          <Button type="submit" className="min-h-11" disabled={ghi.busy}>{ghi.busy ? "Đang lưu…" : hop.kind === "da_luu" ? "Lưu bộ" : "Lưu bộ món"}</Button>
        </div>
      </form>
    </DialogContent>
  </Dialog>;
}
