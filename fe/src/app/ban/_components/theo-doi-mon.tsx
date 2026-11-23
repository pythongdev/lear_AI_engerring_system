"use client";

import { useId, useState } from "react";
import Link from "next/link";
import { cotVanHanh, type ThuVanHanh } from "@/app/chu-quan/_components/cot-van-hanh";
import { DongMonDaGhi, tien } from "@/components/shared/dong-mon-da-ghi";
import type { ApiFailure } from "@/lib/api/client";
import type { components } from "@/lib/api/schema";
import { SITE_NAME } from "@/lib/seo";
import { useTheoDoi, type TienDoBan } from "./du-lieu-theo-doi";
import "./theo-doi-mon.css";

// Cùng luật nhãn với phieu-khach.tsx: nhãn chỉ có số thì đọc "Bàn N".
const nhanBan = (nhan: string) => /^\d+$/.test(nhan.trim()) ? `Bàn ${nhan.trim()}` : nhan;
const cacCot = ["Thịt", "Mộc nhĩ", "Trứng", "Chay", "Giò"] as const;
type Cot = typeof cacCot[number];
type So = "ordered" | "served" | "missing";
const tong = (items: ThuVanHanh[], field: So) => items.reduce((n, item) => n + item[field], 0);
const thuCot = (items: ThuVanHanh[], cot: Cot) => items.filter((item) => {
  const viTri = cotVanHanh(item);
  return cot === "Giò" ? viTri.cot === "Khác" && viTri.dong === "Giò" : viTri.cot === cot;
});

function SoBanh({ items, cot, field }: { items: ThuVanHanh[]; cot: Cot; field: So }) {
  const thu = thuCot(items, cot);
  const dong = cot === "Trứng" ? [...new Set(thu.map((item) => cotVanHanh(item).dong))] : [""];
  if (!dong.length) return <span className="td-khong">0</span>;
  return <>{dong.map((ten) => {
    const so = tong(thu.filter((item) => cot === "Giò" || cotVanHanh(item).dong === ten), field);
    return <div key={ten} className={so === 0 ? "td-khong" : undefined}>{so}{ten && ` ${ten}`}</div>;
  })}</>;
}

function DongCho({ dong }: { dong: components["schemas"]["PriceLine"] }) {
  return <li><div><strong>{dong.item_name}</strong>
    {dong.options.length > 0 && <p className="td-small td-muted">{dong.options.map((o) => o.option_name).join(" · ")}</p>}
    {dong.portions?.map((p, i) => <p key={i} className="td-small td-muted">{p.item_name} · {p.options.map((o) => o.option_name).join(" · ")} ×{p.quantity}</p>)}
  </div><span>×{dong.quantity}</span></li>;
}

export function TheoDoiMon({ ma, initialData, initialFailure }: {
  ma: string; initialData?: TienDoBan; initialFailure?: ApiFailure;
}) {
  const query = useTheoDoi(ma, initialData);
  const [moDon, setMoDon] = useState(false);
  const id = useId();
  const data = query.data;
  const failure = query.error?.failure ?? (!data ? initialFailure : undefined);
  const maCu = failure?.kind === "rejected" && failure.code === "qr_code_not_current";
  const session = data?.session;
  const menu = `/ban/${encodeURIComponent(ma)}`;
  const chuaGoi = data && (!session || (!session.lines.length && !session.pending_lines.length));
  const banh = session?.items.filter((item) => cacCot.some((cot) => thuCot([item], cot).length > 0)) ?? [];
  const ordered = tong(banh, "ordered"), served = tong(banh, "served");
  const luot = session?.orders_ahead;
  const choDuyet = !!session?.pending_lines.length && session.items.length === 0;
  const duMon = !!session?.items.length && session.items.every((item) => item.missing === 0);
  const cauLuot = typeof luot === "number"
    ? luot === 0 ? "Không còn lượt nào gọi trước bạn" : `Còn ${luot} lượt gọi trước bạn đang chờ món`
    : choDuyet ? "Quán chưa xác nhận món của bạn" : duMon ? "Bàn bạn đã nhận đủ món" : null;

  return <main className="theo-doi-mon" aria-label="Theo dõi món"><div className="td-shell">
    {maCu ? <section className="td-card"><p role="status">Bạn vui lòng quét lại mã trên bàn.</p></section> : <>
      <header className="td-header">
        <p className="td-brand">{SITE_NAME}</p>
        {data && <p className="td-context">{(session?.tables.length ? session.tables : [data.table_label]).map(nhanBan).join(" + ")}</p>}
        <h1>Theo dõi món</h1>
        {data && <p className="td-small td-muted">Cập nhật lúc {new Date(data.read_at).toLocaleTimeString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false })} · tự làm mới</p>}
      </header>
      {failure && <p role="alert">Chưa đọc được tiến độ mới.{data && " Đang giữ số của lần cập nhật trên."} Bạn vui lòng thử lại. <button className="td-button" onClick={() => void query.refetch()}>Đọc lại</button></p>}
      {!data && !failure && <p role="status">Đang đọc tiến độ món…</p>}
      {chuaGoi ? <section className="td-card"><p role="status">Bàn bạn chưa gọi món.</p><Link className="td-button" href={menu}>Xem thực đơn</Link></section> : session && <>
        {cauLuot && <section className="td-card td-queue" aria-label="Lượt gọi trước">
          <h2 aria-live="polite">{cauLuot}</h2>
          {typeof luot === "number" && <><p className="td-small td-muted">Chỉ để tham khảo — quán phục vụ theo ai tới trước ăn trước, đôi khi ưu tiên khách vội.</p>
            <p className="td-small td-muted">Tính chung lượt tại bàn, mang đi, giao hàng và đặt qua điện thoại.</p></>}
        </section>}
        {session.items.length > 0 && <section className="td-card" aria-label="Số bánh quán đã nhận">
          <h2>Số bánh quán đã nhận</h2>
          <label className="td-progress-label" htmlFor={`${id}-tien-do`}>{served} / {ordered} bánh đã ra</label>
          <progress id={`${id}-tien-do`} max={ordered || 1} value={served} />
          <table aria-label="Số bánh quán đã nhận" aria-describedby={`${id}-ghi-chu`}>
            <colgroup><col className="td-status-col" /><col /><col /><col className="td-egg-col" /><col /><col /><col className="td-money-col" /></colgroup>
            <thead><tr><th scope="col">Tiến độ</th>{cacCot.map((cot) => <th scope="col" key={cot}>{cot}</th>)}<th scope="col" className="td-money-col">Tiền bánh đã ra</th></tr></thead>
            <tbody>{([["ordered", "Đặt"], ["served", "Đã ra"], ["missing", "Còn thiếu"]] as const).map(([field, nhan], i) => <tr key={field} className={field === "missing" ? "td-missing" : undefined}>
              <th scope="row">{nhan}</th>{cacCot.map((cot) => <td key={cot}><SoBanh items={session.items} cot={cot} field={field} /></td>)}
              {i === 0 && <td rowSpan={3} className="td-money-col td-money">{tien(session.served_amount_vnd)}</td>}
            </tr>)}</tbody>
          </table>
          <p className="td-money-summary"><span>Tiền bánh đã ra:</span><strong className="td-money">{tien(session.served_amount_vnd)}</strong></p>
          <p id={`${id}-ghi-chu`} className="td-note td-muted">Số bánh gồm bánh cuốn (cái), trứng (quả) và giò (chiếc), không đếm canh. Canh chỉ nằm trong đơn đã đặt.</p>
        </section>}
        {session.pending_lines.length > 0 && <section className="td-card td-pending" aria-label="Chờ quán xác nhận">
          <h2>Chờ quán xác nhận</h2>
          <p className="td-small td-muted">{choDuyet ? "Món vừa gửi đang chờ quán nhận. Tiến độ và tổng tiền sẽ hiện sau khi quán xác nhận." : "Món vừa gửi đang chờ quán nhận, chưa nằm trong tiến độ và tổng tiền bên dưới."}</p>
          <ul>{session.pending_lines.map((dong, i) => <DongCho key={i} dong={dong} />)}</ul>
        </section>}
        <section className="td-card" aria-label="Đơn đã đặt">
          <h2>Đơn đã đặt</h2><p className="td-small td-muted">Các món quán đã nhận.</p>
          <button type="button" className="td-button" aria-expanded={moDon} aria-controls={`${id}-don`} onClick={() => setMoDon(!moDon)}>{moDon ? "Ẩn đơn đã đặt" : `Xem đơn đã đặt (${session.lines.length} dòng)`}</button>
          <div id={`${id}-don`} hidden={!moDon} className="td-lines"><DongMonDaGhi lines={session.lines} total={session.lines_total_vnd} /></div>
          <p className="td-total"><span>Tổng tiền đơn</span><strong className="td-money">{tien(session.lines_total_vnd)}</strong></p>
          <p className="td-small td-muted">Món chưa ra thì quầy chưa tính tiền.</p>
        </section>
        <nav aria-label="Gọi món tại bàn"><Link className="td-button" href={menu}>Gọi thêm món</Link></nav>
      </>}
    </>}
  </div></main>;
}
