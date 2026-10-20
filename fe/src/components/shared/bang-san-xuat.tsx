"use client";
// Bảng sản xuất (P4-09): không một nút — màn trạm chỉ đọc (ADR-090). Luôn hiện mốc read_at; phân biệt hết việc với không
// đọc được (05-realtime-va-du-phong.md §1.3). Nút của quầy nằm ngoài thành phần này.

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { khoaHang, khoaPhan, type DuLieuSanXuat, type PhanSanXuat } from "./du-lieu-san-xuat";

function CacSo({ so }: { so: Pick<PhanSanXuat, "ordered" | "pending" | "made" | "served" | "missing"> }) {
  return <span>Gọi {so.ordered} · Chờ làm {so.pending} · Đã làm {so.made} · Đã ra {so.served} · Thiếu {so.missing}</span>;
}
export function BangSanXuat({ duLieu: { bang, menu, ban, tenHang, tenPhan } }: { duLieu: DuLieuSanXuat }) {
  const rows = bang.data?.rows ?? [];
  const tram = [...new Set(rows.map((h) => h.station_code))];
  return <div className="space-y-4">
    {bang.isPending && <div role="status"><p>Đang tải bảng…</p><div aria-hidden className="h-40 animate-pulse rounded-xl bg-muted" /></div>}
    {bang.isError && <Alert role="alert"><AlertDescription>{bang.data ? "Không đọc được bảng mới… Đang hiện bản đọc trước." : "Không đọc được bảng…"}</AlertDescription></Alert>}
    {menu.isError && <p role="alert">Không đọc được tên nhân. Đang hiện tên đã đọc hoặc mã nhân.</p>}
    {ban.isError && <p role="alert">Không đọc được nhãn bàn. Đang hiện nhãn đã đọc hoặc mã bàn.</p>}
    {bang.data && <p>Cập nhật lúc <time dateTime={bang.data.read_at}>{new Date(bang.data.read_at).toLocaleTimeString("vi-VN")}</time></p>}
    {bang.data && bang.isFetching && <p role="status">Đang cập nhật…</p>}
    {bang.data && rows.length === 0 && <p>Hết việc…</p>}
    {tram.map((code) => <section key={code} aria-label={`Trạm ${code}`}><Card>
      <CardHeader><CardTitle><h2>Trạm {code}</h2></CardTitle></CardHeader>
      <CardContent><ul className="space-y-4">{rows.filter((h) => h.station_code === code).map((h) => <li key={khoaHang(h)} className="space-y-2">
        <h3 className="font-semibold">{tenHang(h)}</h3><p><CacSo so={h} /></p>
        {h.parts.map((p) => <p key={khoaPhan(p)}>{tenPhan(p)} · <CacSo so={p} /></p>)}
      </li>)}</ul></CardContent>
    </Card></section>)}
  </div>;
}
export function BangTram({ duLieu }: { duLieu: DuLieuSanXuat }) {
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6"><h1 className="text-2xl font-semibold">Bảng trạm</h1><BangSanXuat duLieu={duLieu} /></div>;
}
