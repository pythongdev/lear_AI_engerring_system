"use client";

import Link from "next/link";
import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { hetPhien } from "@/lib/khach/session";
import { KhungKhach, LoiDocKhach } from "./khung";
import { KHOA, themVaoGio, useGiaCacNhom, type Dong, type Menu } from "./yeu-thich/du-lieu";
import { HopSuaBo, type HopBo } from "./yeu-thich/hop-bo";
import { Gia, TheBo, TheDong } from "./yeu-thich/the";

export function YeuThichKhach() {
  const api = useApi(); const [matPhien, setMatPhien] = useState(false);
  const doc = useQuery({ queryKey: KHOA, retry: false, queryFn: async () => {
    const r = await call(api.GET("/customer-accounts/current/favourites"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  const menu = useQuery({ queryKey: ["menu"], retry: false, queryFn: async () => {
    const r = await call(api.GET("/menu"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  const loiDoc = doc.error as ApiFailure | null; const loiMenu = menu.error as ApiFailure | null;
  const canDangNhap = matPhien || hetPhien(loiDoc) || hetPhien(loiMenu);
  const docLai = () => { void doc.refetch(); void menu.refetch(); };
  return <KhungKhach title="Yêu thích">
    <header className="space-y-2"><p className="text-xs tracking-widest text-[var(--muted-foreground)]">MÓN QUEN, LUÔN Ở ĐÂY</p>
      <h2 className="text-xl font-semibold">Hôm nay ăn món mình thích ♥</h2><p className="text-[var(--muted-foreground)]">Lưu món ngon, chọn lại thật nhanh cho bữa sau.</p>
    </header>
    {canDangNhap ? <section className="space-y-3"><p>Đăng nhập để xem và lưu món yêu thích của bạn.</p><Link className="underline" href="/khach/dang-nhap">Đăng nhập</Link></section> : <>
      {(doc.isPending || menu.isPending) && <p role="status">Đang tải món yêu thích…</p>}
      {loiDoc && <LoiDocKhach error={loiDoc} docLai={docLai} readAt={doc.dataUpdatedAt} />}
      {loiMenu && <LoiDocKhach error={loiMenu} docLai={docLai} readAt={menu.dataUpdatedAt} />}
      {(doc.data && menu.data) && <>
        {(doc.isFetching || menu.isFetching) && <p role="status">Đang cập nhật…</p>}
        <NoiDung data={doc.data} menu={menu.data} readAt={doc.dataUpdatedAt} menuReadAt={menu.dataUpdatedAt} moiDangNhap={() => setMatPhien(true)} docLai={docLai} />
      </>}
    </>}
  </KhungKhach>;
}

function NoiDung({ data, menu, readAt, menuReadAt, moiDangNhap, docLai }: {
  data: components["schemas"]["Favourites"]; menu: Menu; readAt: number; menuReadAt: number; moiDangNhap: () => void; docLai: () => void;
}) {
  const [tab, setTab] = useState("all"); const [moBo, setMoBo] = useState(false);
  const [hop, setHop] = useState<HopBo | null>(null); const [bao, setBao] = useState("");
  const queries = useGiaCacNhom([{ id: "tim", lines: data.lines }, ...data.sets.map((b) => ({ id: b.favourite_set_id, lines: b.lines }))], readAt, menuReadAt);
  const conBan = data.lines.filter((d) => d.available);
  const boRieng = data.sets.filter((b) => b.kind === "rieng"); const boLuu = data.sets.filter((b) => b.kind === "da_luu");
  function them(lines: Dong[], ten: string) { themVaoGio(lines, menu); setBao(`Đã thêm ${ten} vào giỏ hàng.`); }
  const theBo = (bo: components["schemas"]["FavouriteSet"]) => <TheBo key={bo.favourite_set_id} bo={bo} menu={menu}
    query={queries[data.sets.indexOf(bo) + 1]} moiDangNhap={moiDangNhap} them={them} sua={() => setHop({ kind: "rieng", bo })} />;
  return <>
    <section className="space-y-3 rounded-2xl border border-[var(--border)] bg-[var(--accent)] p-4 text-[var(--accent-foreground)]">
      <p className="text-xs tracking-wider">THEO KHẨU VỊ CỦA BẠN</p><h2 className="text-lg font-semibold">Một bộ món, đúng ý mình</h2>
      <p>Tự chọn món quen, đặt tên riêng và lưu lại cho lần sau.</p><Button className="min-h-11 w-full" onClick={() => setHop({ kind: "rieng" })}>Tạo bộ món riêng</Button>
    </section>
    <section aria-label="Bộ món của bạn" className="space-y-3">
      <div className="flex items-center justify-between gap-2"><h2 className="font-semibold">Bộ món của bạn</h2><span>{boRieng.length} bộ</span></div>
      {boRieng.length ? boRieng.map(theBo) : <p className="rounded-xl border border-dashed border-[var(--border)] p-4 text-[var(--muted-foreground)]">Chưa có bộ món riêng. Tạo bộ món đầu tiên để lần sau chọn món nhanh hơn.</p>}
    </section>
    <div className="flex flex-wrap items-center justify-between gap-2"><span>{data.lines.length} món yêu thích</span><Button variant="outline" className="min-h-11" onClick={() => setMoBo(true)}>Bộ đã lưu ({boLuu.length})</Button></div>
    <nav aria-label="Lọc món yêu thích" className="flex gap-2">{[["all", "Tất cả"], ["mon", "Món lẻ"], ["combo", "Combo"]].map(([value, label]) =>
      <Button key={value} variant={tab === value ? "secondary" : "outline"} className="min-h-11 flex-1" aria-pressed={tab === value} onClick={() => setTab(value)}>{label}</Button>)}</nav>
    <section aria-label="Món yêu thích" className="space-y-3">
      {data.lines.filter((d) => tab === "all" || (tab === "mon" ? d.menu_combo_id === null : d.menu_combo_id !== null)).map((d) =>
        <TheDong key={d.favourite_line_id} dong={d} query={queries[0]} index={conBan.indexOf(d)} menu={menu} moiDangNhap={moiDangNhap} them={them} />)}
      {!data.lines.length && <p>Bạn chưa lưu món yêu thích. <Link className="underline" href="/dat-mon">Xem thực đơn</Link></p>}
    </section>
    <footer className="space-y-3 border-t border-[var(--border)] pt-4">
      <div className="flex flex-wrap justify-between gap-2"><span>Tổng {conBan.length} dòng còn bán</span>{conBan.length > 0 ? <Gia query={queries[0]} /> : <span>Chưa có món còn bán</span>}</div>
      <Button className="min-h-12 w-full" disabled={!conBan.length} onClick={() => them(conBan, "các món yêu thích")}>Thêm tất cả vào giỏ</Button>
      <div className="flex flex-wrap items-center justify-between gap-2"><span className="text-sm text-[var(--muted-foreground)]">Giữ lại lựa chọn cho lần sau</span><Button variant="outline" className="min-h-11" disabled={!conBan.length} onClick={() => setHop({ kind: "da_luu", lines: data.lines })}>Lưu thành bộ</Button></div>
      <Button variant="ghost" className="min-h-11" onClick={docLai}>Đọc lại danh sách</Button>
    </footer>
    {bao && <p role="status">{bao} <Link className="underline" href="/dat-mon">Xem giỏ hàng</Link></p>}
    {hop && <HopSuaBo hop={hop} menu={menu} moiDangNhap={moiDangNhap} dong={() => setHop(null)} />}
    <Dialog open={moBo} onOpenChange={setMoBo}><DialogContent showCloseButton={false} className="max-h-[calc(100dvh-2rem)] overflow-y-auto">
      <DialogTitle>Bộ đã lưu</DialogTitle><DialogDescription>Các bộ món đã lưu từ danh sách yêu thích.</DialogDescription>
      {boLuu.length ? boLuu.map(theBo) : <p>Bạn chưa lưu bộ nào.</p>}
      {bao && <p role="status">{bao} <Link className="underline" href="/dat-mon">Xem giỏ hàng</Link></p>}
      <Button variant="outline" className="min-h-11" onClick={() => setMoBo(false)}>Đóng</Button>
    </DialogContent></Dialog>
  </>;
}
