"use client";

import { Button } from "@/components/ui/button";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { doiSoLuong, guiDong, useGhiYeuThich, type Bo, type Dong, type DongGui, type GiaNhom, type Menu } from "./du-lieu";

export function tenDong(d: DongGui, menu: Menu) {
  return (d.menu_combo_id !== undefined ? menu.combos.find((m) => m.menu_combo_id === d.menu_combo_id)?.name
    : menu.items.find((m) => m.menu_item_id === d.menu_item_id)?.item_name) ?? "Món không còn trên thực đơn";
}

export function MoTaDong({ dong: d, menu }: { dong: DongGui; menu: Menu }) {
  const combo = menu.combos.find((c) => c.menu_combo_id === d.menu_combo_id);
  const tenLuaChon = (id: number, ids: number[]) => {
    const mon = menu.items.find((m) => m.menu_item_id === id) ?? combo?.items.find((m) => m.menu_item_id === id);
    return ids.map((v) => mon?.option_groups.flatMap((g) => g.options).find((o) => o.menu_option_id === v)?.option_name ?? "Lựa chọn không còn trên thực đơn").join(" · ");
  };
  return d.menu_combo_id !== undefined
    ? <ul className="space-y-1 text-sm text-[var(--muted-foreground)]">{d.portions?.map((p, i) => <li key={i}>{p.quantity} × {menu.items.find((m) => m.menu_item_id === p.menu_item_id)?.item_name ?? combo?.items.find((m) => m.menu_item_id === p.menu_item_id)?.item_name ?? "Món không còn trên thực đơn"}{p.option_ids.length > 0 && ` · ${tenLuaChon(p.menu_item_id, p.option_ids)}`}</li>)}</ul>
    : <p className="text-sm text-[var(--muted-foreground)]">{tenLuaChon(d.menu_item_id!, d.option_ids ?? [])}</p>;
}

export function Gia({ query, index }: { query: GiaNhom; index?: number }) {
  const value = index === undefined ? query.data?.total_vnd : query.data?.lines[index]?.line_total_vnd;
  return <p className="font-semibold text-[var(--primary)]">{query.error ? query.error.message : query.isFetching || query.isPending ? "Đang tính giá…" : value !== undefined ? tien(value) : "Chưa tính được giá."}</p>;
}

type ThaoTac = { menu: Menu; moiDangNhap: () => void; them: (lines: Dong[], ten: string) => void };
export function TheDong({ dong, query, index, menu, moiDangNhap, them }: ThaoTac & { dong: Dong; query: GiaNhom; index: number }) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap);
  const d = guiDong(dong); const ten = tenDong(d, menu);
  const params = { path: { favourite_line_id: dong.favourite_line_id } };
  const sua = (quantity: number) => ghi.gui(() => call(api.PUT("/customer-accounts/current/favourites/{favourite_line_id}", { params, body: doiSoLuong(d, quantity, menu) })));
  return <article aria-label={ten} className="space-y-3 rounded-2xl border border-[var(--border)] bg-[var(--card)] p-4">
    <div className="flex items-start justify-between gap-2"><div className="min-w-0 space-y-1">
      <span className="text-xs text-[var(--muted-foreground)]">{dong.menu_combo_id === null ? "Món lẻ" : "Combo"}</span>
      <h3 className="font-semibold break-words">{ten}</h3><MoTaDong dong={d} menu={menu} />
    </div><Button variant="ghost" className="min-h-11 text-[var(--destructive)]" aria-label={`Bỏ yêu thích ${ten}`} disabled={ghi.busy}
      onClick={() => void ghi.gui(() => call(api.POST("/customer-accounts/current/favourites/{favourite_line_id}/removal", { params })))}>♥</Button></div>
    {dong.available ? <Gia query={query} index={index} /> : <p className="text-[var(--muted-foreground)]">Hết bán</p>}
    <div className="flex flex-wrap items-center justify-between gap-2">
      <div className="flex items-center rounded-lg border border-[var(--border)]">
        <Button variant="ghost" className="min-h-11" aria-label={`Giảm ${ten}`} disabled={ghi.busy || !dong.available || dong.quantity <= 1} onClick={() => void sua(dong.quantity - 1)}>−</Button>
        <output aria-label={`Số lượng ${ten}`} className="min-w-6 text-center">{dong.quantity}</output>
        <Button variant="ghost" className="min-h-11" aria-label={`Tăng ${ten}`} disabled={ghi.busy || !dong.available || dong.quantity >= 99} onClick={() => void sua(dong.quantity + 1)}>＋</Button>
      </div>
      {dong.available && <Button className="min-h-11" onClick={() => them([dong], ten)}>Thêm vào giỏ</Button>}
    </div>
    {ghi.busy && <p role="status">Đang lưu…</p>}{ghi.loi && <p role="alert">{ghi.loi}</p>}{ghi.bao && <p role="status">{ghi.bao}</p>}
  </article>;
}

export function TheBo({ bo, query, menu, moiDangNhap, them, sua }: ThaoTac & { bo: Bo; query: GiaNhom; sua: () => void }) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap);
  const coMon = bo.lines.some((d) => d.available);
  return <article aria-label={bo.name} className="space-y-3 rounded-2xl border border-[var(--border)] bg-[var(--card)] p-4">
    <span className="rounded-full bg-[var(--accent)] px-2 py-1 text-xs text-[var(--accent-foreground)]">{bo.kind === "rieng" ? "♥ Bộ món riêng" : "Bộ đã lưu"}</span>
    <h3 className="font-semibold break-words">{bo.name}</h3>
    <ul className="space-y-2">{bo.lines.map((d) => <li key={d.favourite_line_id}>
      <p>{d.quantity} × {tenDong(guiDong(d), menu)}{!d.available && <span> · Hết bán</span>}</p><MoTaDong dong={guiDong(d)} menu={menu} />
    </li>)}</ul>
    {coMon && <Gia query={query} />}
    <div className="flex flex-wrap gap-2">
      {bo.kind === "rieng" && <Button variant="outline" className="min-h-11" disabled={ghi.busy} onClick={sua}>Sửa</Button>}
      <Button variant="outline" className="min-h-11" disabled={ghi.busy} onClick={() => void ghi.gui(() => call(api.POST("/customer-accounts/current/favourite-sets/{favourite_set_id}/removal", { params: { path: { favourite_set_id: bo.favourite_set_id } } })))}>Xoá</Button>
      {coMon && <Button className="min-h-11" onClick={() => them(bo.lines, bo.name)}>Thêm vào giỏ</Button>}
    </div>
    {ghi.busy && <p role="status">Đang lưu…</p>}{ghi.loi && <p role="alert">{ghi.loi}</p>}{ghi.bao && <p role="status">{ghi.bao}</p>}
  </article>;
}
