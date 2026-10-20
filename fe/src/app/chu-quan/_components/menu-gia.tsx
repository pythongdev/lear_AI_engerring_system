"use client";
// Trang chủ quán Menu & giá (P4-05) — trang thử chạm tiền, khuôn cho các màn sau: không cộng giá, không nút thêm · xoá
// (không có cửa — kế hoạch pha 4 §7); khung xương lần đọc đầu, "Đang cập nhật…" khi đọc lại mà vẫn giữ bản cũ.

import { useState } from "react";
import { useIsFetching } from "@tanstack/react-query";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { khoaMenuGia, tienGia, useDocLaiMenuGia, useMenuGia, useNhomGia, useThanhPhanGia, type MonGia } from "./du-lieu-menu-gia";
import { HopThoaiSuaCoLyDo } from "./hop-thoai-sua-co-ly-do";

type Bao = (message: string) => void;
function KhoiMonGia({ mon, bao }: { mon: MonGia; bao: Bao }) {
  const query = useThanhPhanGia(mon);
  const options = mon.option_groups.flatMap((g) => g.options);
  return <section aria-label={mon.item_name}><Card>
    <CardHeader><CardTitle><h2>{mon.item_name}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-4">
      <ul aria-label="Giá bán" className="space-y-2">{mon.prices.map((p, i) => <li key={i}>
        {p.option_ids.length ? p.option_ids.map((id) => options.find((o) => o.menu_option_id === id)?.option_name).join(" · ") : "Giá"}{" "}{tienGia(p.unit_price_vnd)}
      </li>)}</ul>
      {query.isPending && <p role="status">Đang đọc thành phần…</p>}
      {query.isError && <p role="alert">Chưa đọc được thành phần. Hãy đọc lại menu.</p>}
      {!query.isError && query.data && <ul aria-label="Thành phần" className="space-y-3">{query.data.map((tp) => <li key={tp.menu_component_id} className="space-y-2">
        <p>{tp.component_name} × {tp.quantity} · {tienGia(tp.base_price_vnd)}</p>
        <div className="flex flex-wrap gap-2">
          <HopThoaiSuaCoLyDo lenh={{ loai: "gia", id: tp.menu_component_id }} ten={tp.component_name} hienTai={tp.base_price_vnd} bao={bao} />
          <HopThoaiSuaCoLyDo lenh={{ loai: "so-luong", id: tp.menu_component_id, monId: mon.menu_item_id }} ten={tp.component_name} hienTai={tp.quantity} bao={bao} />
        </div>
      </li>)}</ul>}
      <HopThoaiSuaCoLyDo lenh={{ loai: "ngung", id: mon.menu_item_id }} ten={mon.item_name} bao={bao} />
    </CardContent>
  </Card></section>;
}
export function TrangMenuGia() {
  const menu = useMenuGia();
  const nhom = useNhomGia();
  const docLai = useDocLaiMenuGia();
  const dangDoc = useIsFetching({ predicate: (q) => khoaMenuGia.some((k) => q.queryKey[0] === k[0]) }) > 0;
  const [thongBao, bao] = useState<string | null>(null);
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Menu &amp; giá</h1>
    {menu.isPending && <div role="status" className="space-y-3"><p>Đang tải menu…</p><div aria-hidden className="h-40 animate-pulse rounded-xl bg-muted" /></div>}
    {menu.isError && <Alert role="alert"><AlertDescription>Chưa đọc được menu.{menu.data ? ` Đang hiện bản đọc trước, lúc ${new Date(menu.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử đọc lại."}</AlertDescription></Alert>}
    {nhom.isError && <Alert role="alert"><AlertDescription>Chưa đọc được nhóm lựa chọn.{nhom.data ? ` Đang hiện bản đọc trước, lúc ${new Date(nhom.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử đọc lại."}</AlertDescription></Alert>}
    <Button variant="outline" className="min-h-11" disabled={dangDoc} onClick={() => void docLai()}>Đọc lại menu</Button>
    {menu.data && dangDoc && <p role="status">Đang cập nhật…</p>}
    {thongBao && <p role="status">{thongBao}</p>}
    {menu.data?.items.length === 0 && <p>Chưa có món đang bán.</p>}
    {menu.data?.items.map((mon) => <KhoiMonGia key={mon.menu_item_id} mon={mon} bao={bao} />)}
    {nhom.data?.option_groups.map((g) => <section key={g.option_group_id} aria-label={`Nhóm ${g.name}`}><Card>
      <CardHeader><CardTitle><h2>Nhóm {g.name}</h2></CardTitle></CardHeader>
      <CardContent><ul className="space-y-3">{g.options.map((o) => <li key={o.menu_option_id} className="flex flex-wrap items-center justify-between gap-2">
        <span>{o.name} · {tienGia(o.surcharge_vnd)}{o.hidden_at !== null && " · Đã ẩn"}</span>
        <HopThoaiSuaCoLyDo lenh={{ loai: "phu-thu", id: o.menu_option_id }} ten={o.name} hienTai={o.surcharge_vnd} bao={bao} />
      </li>)}</ul></CardContent>
    </Card></section>)}
  </div>;
}
