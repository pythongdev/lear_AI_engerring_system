"use client";

import { Button } from "@/components/ui/button";
import { AnhSanPham } from "@/app/chu-quan/_components/anh-san-pham";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { doiSoLuong, guiDong, useGhiYeuThich, type Bo, type Dong, type DongGui, type GiaNhom, type Menu } from "./du-lieu";
import { LuaChonDanhSach } from "./lua-chon";

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
    ? <ul className="yt-description space-y-1">{d.portions?.map((p, i) => <li key={i}>{p.quantity} × {menu.items.find((m) => m.menu_item_id === p.menu_item_id)?.item_name ?? combo?.items.find((m) => m.menu_item_id === p.menu_item_id)?.item_name ?? "Món không còn trên thực đơn"}{p.option_ids.length > 0 && ` · ${tenLuaChon(p.menu_item_id, p.option_ids)}`}</li>)}</ul>
    : <p className="yt-description">{tenLuaChon(d.menu_item_id!, d.option_ids ?? [])}</p>;
}

export function Gia({ query, index }: { query: GiaNhom; index?: number }) {
  const value = index === undefined ? query.data?.total_vnd : query.data?.lines[index]?.line_total_vnd;
  return <div className="yt-price min-w-0"><p className="break-words font-semibold">{query.error ? query.error.message : query.isFetching || query.isPending ? "Đang tính giá…" : value !== undefined ? tien(value) : "Chưa tính được giá."}</p>
    {query.error && <Button type="button" variant="outline" className="mt-1 min-h-11" onClick={() => void query.refetch()}>Thử lại giá</Button>}</div>;
}

type ThaoTac = { menu: Menu; moiDangNhap: () => void; them: (lines: Dong[], ten: string) => void };
export function TheDong({ dong, query, index, menu, moiDangNhap, them }: ThaoTac & { dong: Dong; query: GiaNhom; index: number }) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap);
  const d = guiDong(dong); const ten = tenDong(d, menu);
  const mon = menu.items.find((m) => m.menu_item_id === dong.menu_item_id);
  const params = { path: { favourite_line_id: dong.favourite_line_id } };
  const sua = (quantity: number) => ghi.gui(() => call(api.PUT("/customer-accounts/current/favourites/{favourite_line_id}", { params, body: doiSoLuong(d, quantity, menu) })));
  return <article aria-label={ten} className="yt-card yt-item">
    <AnhSanPham ten={ten} combo={dong.menu_combo_id !== null} imageUrl={mon?.image_url} className="yt-art" />
    <div className="yt-item-copy min-w-0 space-y-2">
      <span className="yt-kind">{dong.menu_combo_id === null ? "Món lẻ" : "Combo"}</span>
      <h3 className="text-sm font-medium break-words">{ten}</h3>
      <div className="yt-item-price"><MoTaDong dong={d} menu={menu} />
        <Button variant="ghost" className="yt-heart" aria-label={`Bỏ yêu thích ${ten}`} disabled={ghi.busy}
          onClick={() => void ghi.gui(() => call(api.POST("/customer-accounts/current/favourites/{favourite_line_id}/removal", { params })))}>♥</Button>
        {dong.available ? <Gia query={query} index={index} /> : <p className="yt-muted">Hết bán</p>}
      </div>
    {dong.available && mon && mon.option_groups.length > 0 && <LuaChonDanhSach groups={mon.option_groups} ids={d.option_ids ?? []} name={ten} disabled={ghi.busy} onChange={(option_ids) => void ghi.gui(() => call(api.PUT("/customer-accounts/current/favourites/{favourite_line_id}", { params, body: { ...d, option_ids } })))} />}
    <div className="flex flex-wrap items-center justify-between gap-2">
      <div className="yt-stepper flex items-center">
        <Button variant="ghost" aria-label={`Giảm ${ten}`} disabled={ghi.busy || !dong.available || dong.quantity <= 1} onClick={() => void sua(dong.quantity - 1)}>−</Button>
        <output aria-label={`Số lượng ${ten}`} className="min-w-6 text-center">{dong.quantity}</output>
        <Button variant="ghost" aria-label={`Tăng ${ten}`} disabled={ghi.busy || !dong.available || dong.quantity >= 99} onClick={() => void sua(dong.quantity + 1)}>＋</Button>
      </div>
      {dong.available && <Button variant="outline" aria-label={`Thêm ${ten} vào giỏ`} onClick={() => them([dong], ten)}>＋ Giỏ</Button>}
    </div>
    {ghi.busy && <p role="status">Đang lưu…</p>}{ghi.loi && <p role="alert">{ghi.loi}</p>}{ghi.bao && <p role="status">{ghi.bao}</p>}
    </div>
  </article>;
}

export function TheBo({ bo, query, menu, moiDangNhap, them, sua }: ThaoTac & { bo: Bo; query: GiaNhom; sua: () => void }) {
  const api = useApi(); const ghi = useGhiYeuThich(moiDangNhap);
  const coMon = bo.lines.some((d) => d.available);
  return <article aria-label={bo.name} className="yt-card yt-set space-y-3 p-4">
    <span className="yt-badge">{bo.kind === "rieng" ? "♥ Bộ món riêng" : "Bộ đã lưu"}</span>
    <h3 className="text-[15px] font-semibold break-words">{bo.name}</h3>
    <ul className="yt-muted space-y-2">{bo.lines.map((d) => <li key={d.favourite_line_id}>
      <p>{d.quantity} × {tenDong(guiDong(d), menu)}{!d.available && <span> · Hết bán</span>}</p><MoTaDong dong={guiDong(d)} menu={menu} />
    </li>)}</ul>
    {bo.kind === "rieng" ? <div className="flex flex-wrap items-center justify-between gap-2"><span className="yt-muted">{bo.lines.reduce((n, d) => n + d.quantity, 0)} phần</span>{coMon && <Gia query={query} />}</div> : coMon && <Gia query={query} />}
    <div className="flex flex-wrap justify-end gap-2">
      {bo.kind === "rieng" && <Button variant="outline" className="min-h-11" disabled={ghi.busy} onClick={sua}>Sửa</Button>}
      <Button variant="outline" className="min-h-11" disabled={ghi.busy} onClick={() => void ghi.gui(() => call(api.POST("/customer-accounts/current/favourite-sets/{favourite_set_id}/removal", { params: { path: { favourite_set_id: bo.favourite_set_id } } })))}>Xoá</Button>
      {coMon && <Button className="min-h-11" onClick={() => them(bo.lines, bo.name)}>Thêm vào giỏ</Button>}
    </div>
    {ghi.busy && <p role="status">Đang lưu…</p>}{ghi.loi && <p role="alert">{ghi.loi}</p>}{ghi.bao && <p role="status">{ghi.bao}</p>}
  </article>;
}
