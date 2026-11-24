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
import "./yeu-thich/yeu-thich.css";

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
  return <KhungKhach title="Yêu thích" vien={false}>
    <div className="yt-theme yt-page min-w-0 space-y-6">
    <header className="space-y-2"><p className="yt-eyebrow">MÓN QUEN, LUÔN Ở ĐÂY</p>
      <h2 className="text-xl font-semibold">Hôm nay ăn món mình thích ♥</h2><p className="yt-muted">Lưu món ngon, chọn lại thật nhanh cho bữa sau.</p>
    </header>
    {canDangNhap ? <section className="space-y-3"><p>Đăng nhập để xem và lưu món yêu thích của bạn.</p><Link className="underline" href="/khach/dang-nhap">Đăng nhập</Link></section> : <>
      {(doc.isPending || menu.isPending) && <p role="status">Đang tải món yêu thích…</p>}
      {loiDoc && <LoiDocKhach error={loiDoc} docLai={docLai} readAt={doc.dataUpdatedAt} />}
      {loiMenu && <LoiDocKhach error={loiMenu} docLai={docLai} readAt={menu.dataUpdatedAt} />}
      {(doc.data && menu.data) && <>
        {(doc.isFetching || menu.isFetching) && <p role="status">Đang cập nhật…</p>}
        <NoiDung data={doc.data} menu={menu.data} readAt={doc.dataUpdatedAt} menuReadAt={menu.dataUpdatedAt} moiDangNhap={() => setMatPhien(true)} />
      </>}
    </>}
    </div>
  </KhungKhach>;
}

function NoiDung({ data, menu, readAt, menuReadAt, moiDangNhap }: {
  data: components["schemas"]["Favourites"]; menu: Menu; readAt: number; menuReadAt: number; moiDangNhap: () => void;
}) {
  const [tab, setTab] = useState("all"); const [moBo, setMoBo] = useState(false);
  const [hop, setHop] = useState<HopBo | null>(null); const [bao, setBao] = useState("");
  const queries = useGiaCacNhom([{ id: "tim", lines: data.lines }, ...data.sets.map((b) => ({ id: b.favourite_set_id, lines: b.lines }))], readAt, menuReadAt);
  const conBan = data.lines.filter((d) => d.available);
  const soMonLe = data.lines.filter((d) => d.menu_combo_id === null).length;
  const soCombo = data.lines.length - soMonLe;
  const boRieng = data.sets.filter((b) => b.kind === "rieng"); const boLuu = data.sets.filter((b) => b.kind === "da_luu");
  function them(lines: Dong[], ten: string) { themVaoGio(lines, menu); setBao(`Đã thêm ${ten} vào giỏ hàng.`); }
  const theBo = (bo: components["schemas"]["FavouriteSet"]) => <TheBo key={bo.favourite_set_id} bo={bo} menu={menu}
    query={queries[data.sets.indexOf(bo) + 1]} moiDangNhap={moiDangNhap} them={them} sua={() => setHop({ kind: "rieng", bo })} />;
  return <>
    <section className="yt-create space-y-3">
      <p className="yt-eyebrow">THEO KHẨU VỊ CỦA BẠN</p><h2 className="text-lg font-semibold">Một bộ món, đúng ý mình</h2>
      <p className="yt-muted">Tự chọn món quen, đặt tên riêng và lưu lại cho lần sau.</p><Button className="min-h-11 w-full" onClick={() => setHop({ kind: "rieng" })}>Tạo món yêu thích</Button>
    </section>
    <section aria-label="Bộ món của bạn" className="space-y-3">
      <div className="flex flex-wrap items-center justify-between gap-2"><h2 className="text-sm font-semibold">Bộ món của bạn</h2><span className="yt-muted">{boRieng.length} bộ</span></div>
      {boRieng.length ? boRieng.map(theBo) : <p className="yt-empty">Chưa có bộ món riêng. Tạo bộ món đầu tiên để lần sau chọn món nhanh hơn.</p>}
    </section>
    <div className="flex flex-wrap items-center justify-between gap-2"><span className="yt-muted">{data.lines.length} món yêu thích</span><Button variant="outline" onClick={() => setMoBo(true)}>Bộ đã lưu ({boLuu.length})</Button></div>
    <nav aria-label="Lọc món yêu thích" className="yt-tabs flex flex-wrap gap-2">{([["all", "Tất cả", data.lines.length], ["mon", "Món lẻ", soMonLe], ["combo", "Combo", soCombo]] as const).map(([value, label, count]) =>
      <Button key={value} variant={tab === value ? "secondary" : "outline"} className="min-w-0 flex-1 whitespace-nowrap" aria-pressed={tab === value} onClick={() => setTab(value)}>{label} ({count})</Button>)}</nav>
    <section aria-label="Món yêu thích" className="space-y-3">
      {data.lines.filter((d) => tab === "all" || (tab === "mon" ? d.menu_combo_id === null : d.menu_combo_id !== null)).map((d) =>
        <TheDong key={d.favourite_line_id} dong={d} query={queries[0]} index={conBan.indexOf(d)} menu={menu} moiDangNhap={moiDangNhap} them={them} />)}
      {!data.lines.length && <p>Bạn chưa lưu món yêu thích. <Link className="underline" href="/dat-mon">Xem thực đơn</Link></p>}
    </section>
    <footer className="yt-footer space-y-3">
      <div className="flex flex-wrap justify-between gap-2"><span>{conBan.reduce((n, d) => n + d.quantity, 0)} phần đã chọn</span>{conBan.length > 0 ? <Gia query={queries[0]} /> : <span>Chưa có món còn bán</span>}</div>
      <Button className="min-h-12 w-full" disabled={!conBan.length} onClick={() => them(conBan, "các món yêu thích")}>Thêm tất cả vào giỏ</Button>
      <div className="flex flex-wrap items-center justify-between gap-2"><span className="yt-muted">Giữ lại lựa chọn cho lần sau</span><Button variant="outline" disabled={!conBan.length} onClick={() => setHop({ kind: "da_luu", lines: data.lines })}>Lưu thành bộ</Button></div>
    </footer>
    {bao && <p role="status">{bao} <Link className="underline" href="/dat-mon">Xem giỏ hàng</Link></p>}
    {hop && <HopSuaBo hop={hop} menu={menu} yeuThich={data.lines} moiDangNhap={moiDangNhap} dong={() => setHop(null)} />}
    <Dialog open={moBo} onOpenChange={setMoBo}><DialogContent showCloseButton={false} className="yt-theme yt-dialog max-h-[calc(100dvh-2rem)] min-w-0 overflow-y-auto">
      <DialogTitle>Bộ đã lưu</DialogTitle><DialogDescription>Các bộ món đã lưu từ danh sách yêu thích.</DialogDescription>
      {boLuu.length ? boLuu.map(theBo) : <p>Bạn chưa lưu bộ nào.</p>}
      {bao && <p role="status">{bao} <Link className="underline" href="/dat-mon">Xem giỏ hàng</Link></p>}
      <Button variant="outline" className="min-h-11" onClick={() => setMoBo(false)}>Đóng</Button>
    </DialogContent></Dialog>
  </>;
}
