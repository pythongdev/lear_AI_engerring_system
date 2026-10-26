"use client";

import { useId, useState } from "react";
import { chonNhom, giaDong, LuaChon, soSuat, type DongSoan } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { Input } from "@/components/ui/input";
import { dungLai, useNhapKhach } from "@/lib/nhap-khach";
import type { components } from "@/lib/api/schema";

export function ChonMonChiTiet({ menu, mon, combo, groups, maBan }: {
  menu: components["schemas"]["Menu"];
  mon?: components["schemas"]["MenuItem"];
  combo?: components["schemas"]["MenuSaleCombo"];
  groups: components["schemas"]["MenuOptionGroup"][];
  maBan?: string;
}) {
  const name = useId();
  const [ids, setIds] = useState(() => chonNhom(groups, []));
  const [quantity, setQuantity] = useState(1);
  const [bao, setBao] = useState("");
  const dong: DongSoan | undefined = combo
    ? { combo, quantity, is_takeaway: false, portions: [] }
    : mon ? { mon, quantity, is_takeaway: false, option_ids: ids } : undefined;
  const gia = dong && giaDong(dong);
  const hopLe = !!dong && Number.isSafeInteger(quantity) && quantity > 0 && (!!combo || !!gia);
  const nhom = groups.map((g) => ({ ...g, options: g.options.map((o) => ({ ...o,
    option_name: g.option_group_name === "Lượng nhân" && o.option_name === "Thường" ? "Vừa" : g.option_group_name === "Lượng nhân" && o.option_name === "Nhiều nhân" ? "Nhiều" : o.option_name,
  })) }));
  return <section className="mt-6 rounded-xl border border-[var(--line)] bg-[var(--card)] p-3">
    <h2 className="mb-3 font-semibold">Chọn món</h2>
    <LuaChon groups={nhom} ids={ids} name={name} onChange={(moi) => { setIds(moi); setBao(""); }} />
    <label className="mt-3 block">Số lượng<Input type="number" min={1} step={1} value={Number.isNaN(quantity) ? "" : quantity} onChange={(e) => { setQuantity(e.target.valueAsNumber); setBao(""); }} /></label>
    {mon && <p className="mt-3 text-[var(--accent)]">{gia ? `Giá đơn vị ${tien(gia.unit_price_vnd)}` : "Chưa có giá cho tổ hợp đã chọn."}</p>}
    <button type="button" disabled={!hopLe} className="mt-4 flex min-h-12 w-full items-center justify-center rounded-xl bg-[var(--accent)] px-3 text-white disabled:opacity-50" onClick={() => {
      if (!hopLe || !dong) return;
      const khoa = maBan === undefined ? "web" : `qr:${maBan}`;
      const state = useNhapKhach.getState();
      const them: DongSoan = combo ? { quantity, is_takeaway: false, combo, portions: soSuat(combo, quantity).map((p) => ({ ...p, option_ids: chonNhom(p.mon.option_groups, ids) })) } : dong;
      state.sua(khoa, [...dungLai(state.gio[khoa], menu), them]);
      setBao(`Đã thêm ${quantity} ${combo ? combo.name : mon!.item_name} vào giỏ hàng.`);
    }}>Thêm vào giỏ</button>
    {bao && <p role="status" className="mt-3">{bao}</p>}
  </section>;
}
