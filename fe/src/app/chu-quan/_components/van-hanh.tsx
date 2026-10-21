"use client";

import { Fragment, useId, useState, type ReactNode } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import type { ApiFailure } from "@/lib/api/client";
import { cotVanHanh, tenCot, type CotVanHanh, type ThuVanHanh } from "./cot-van-hanh";
import { useBangVanHanh, loiVanHanh, type BangVanHanh } from "./du-lieu-van-hanh";

type Phien = BangVanHanh["sessions"][number];
const nhanBan = (p: Phien) => p.tables.map((b) => b.label).join(" + ");
const gio = (s: string) => new Date(s).toLocaleTimeString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour12: false });
const cong = (items: ThuVanHanh[], field: "ordered" | "served" | "missing") => items.reduce((n, i) => n + i[field], 0);
const thuCot = (items: ThuVanHanh[], cot: CotVanHanh) => items.filter((i) => cotVanHanh(i).cot === cot);
const tongTien = (ps: Phien[], field: "order_total_vnd" | "served_amount_vnd") => ps.reduce((n, p) => n + p[field], 0);
const khung = "space-y-4 rounded-lg border bg-card p-4 sm:p-6";

function VungBang({ ten, children }: { ten: string; children: ReactNode }) {
  return <div role="region" aria-label={ten} tabIndex={0} className="max-w-full overflow-x-auto rounded-md border">{children}</div>;
}
function AnHien({ ten, children, chiTiet = false }: { ten: string; children: ReactNode; chiTiet?: boolean }) {
  const [mo, setMo] = useState(false);
  const id = useId();
  return <div className="space-y-3">
    <Button variant="outline" aria-label={`${mo ? "Ẩn" : chiTiet ? "Chi tiết" : "Hiện"} ${ten}`} aria-expanded={mo} aria-controls={id} onClick={() => setMo(!mo)}>
      {mo ? "Ẩn" : chiTiet ? "Chi tiết" : "Hiện"}
    </Button>
    <div id={id} hidden={!mo}>{children}</div>
  </div>;
}
function SoCot({ items, cot, field = "missing", them = [] }: { items: ThuVanHanh[]; cot: CotVanHanh; field?: "ordered" | "served" | "missing"; them?: ThuVanHanh[] }) {
  const goc = thuCot(items, cot), phu = thuCot(them, cot);
  const cacDong = cot === "Trứng" || cot === "Khác"
    ? [...new Set([...goc, ...phu].map((i) => cotVanHanh(i).dong))] : [""];
  if (!cacDong.length) return <>0</>;
  return <>{cacDong.map((dong) => {
    const a = goc.filter((i) => cotVanHanh(i).dong === dong), b = phu.filter((i) => cotVanHanh(i).dong === dong);
    const nhieu = [...a, ...b].some((i) => i.extra_filling && i.missing > 0);
    const themSo = cong(b, field);
    return <div key={dong} className={nhieu ? "rounded bg-yellow-100 px-1 text-yellow-950" : ""}>
      {cong(a, field)}{themSo > 0 && <span className="font-semibold text-red-700">+{themSo}</span>}{dong && ` ${dong}`}{nhieu && "*"}
    </div>;
  })}</>;
}
function ChiTietBan({ phien, cot }: { phien: Phien; cot: readonly CotVanHanh[] }) {
  return <div className="space-y-3 p-3">
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">{cot.map((c) => <div key={c} className="space-y-1 rounded border p-3">
      <h4 className="font-semibold">{c}</h4>
      {([['ordered', 'tổng'], ['served', 'đã ra'], ['missing', 'thiếu']] as const).map(([field, label]) => <div key={field}><span>{label}</span><SoCot items={phien.items} cot={c} field={field} /></div>)}
    </div>)}</div>
    <p>Tiền đơn: {tien(phien.order_total_vnd)}</p>
  </div>;
}
function HangThieu({ phien, cot, them }: { phien: Phien; cot: readonly CotVanHanh[]; them: boolean }) {
  const [mo, setMo] = useState(false);
  const id = useId();
  return <>
    <tr className={them ? "bg-red-50 text-red-800" : ""}>
      <th scope="row"><Button variant="ghost" aria-expanded={mo} aria-controls={id} onClick={() => setMo(!mo)}>{nhanBan(phien)}</Button></th>
      {cot.map((c) => <td key={c}><SoCot items={phien.items} cot={c} /></td>)}
      <td>{tien(phien.served_amount_vnd)}</td>
    </tr>
    {mo && <tr id={id}><td colSpan={cot.length + 2}><ChiTietBan phien={phien} cot={cot} /></td></tr>}
  </>;
}
function BangThieuTheoBan({ serving, chon, cot }: { serving: Phien[]; chon: Phien[]; cot: readonly CotVanHanh[] }) {
  return <section aria-label="Tổng thiếu theo bàn" className={khung}>
    <h2 className="text-xl font-semibold">Tổng thiếu theo bàn</h2>
    <VungBang ten="Bảng tổng thiếu"><table className="w-full text-left [&_th]:p-3 [&_td]:p-3">
      <thead><tr><th scope="col">Bàn</th>{cot.map((c) => <th scope="col" key={c}>{c}</th>)}<th scope="col">Tiền bánh đã ra</th></tr></thead>
      <tbody>{!serving.length && <tr><td colSpan={cot.length + 2}>Chưa bàn nào đang phục vụ.</td></tr>}
        {serving.map((p) => <HangThieu key={p.table_session_id} phien={p} cot={cot} them={false} />)}
        {chon.map((p) => <HangThieu key={p.table_session_id} phien={p} cot={cot} them />)}
      </tbody>
      <tfoot className="border-t font-semibold"><tr><th scope="row">Tổng</th>{cot.map((c) => <td key={c}><SoCot items={serving.flatMap((p) => p.items)} them={chon.flatMap((p) => p.items)} cot={c} /></td>)}
        <td>{tien(tongTien(serving, "served_amount_vnd"))}{tongTien(chon, "served_amount_vnd") > 0 && <span className="text-red-700">+{tien(tongTien(chon, "served_amount_vnd"))}</span>}</td>
      </tr></tfoot>
    </table></VungBang><p className="text-sm">* nhiều nhân</p>
  </section>;
}
function CongThuGhepDon({ waiting, chon, doi, cot }: { waiting: Phien[]; chon: number[]; doi: (ids: number[]) => void; cot: readonly CotVanHanh[] }) {
  return <section aria-label="Cộng thử ghép đơn" className={khung}>
    <h2 className="text-xl font-semibold">Cộng thử ghép đơn</h2>
    {!waiting.length && <p>Chưa bàn nào sắp phục vụ.</p>}
    <div className="grid gap-3 sm:grid-cols-2">{waiting.map((p) => <div key={p.table_session_id} className="space-y-2 rounded border p-3">
      <label className="flex items-center gap-3"><Checkbox checked={chon.includes(p.table_session_id)} onCheckedChange={(checked) => doi(checked ? [...chon, p.table_session_id] : chon.filter((id) => id !== p.table_session_id))} />{nhanBan(p)} · {tien(p.order_total_vnd)}</label>
      <div className="flex flex-wrap gap-3">{cot.map((c) => <div key={c}>{c}: <SoCot items={p.items} cot={c} field="ordered" /></div>)}</div>
    </div>)}</div>
    <p role="status">Đã chọn {chon.length} bàn.</p><Button variant="outline" onClick={() => doi([])}>Bỏ chọn hết</Button>
  </section>;
}
function KhoiBanDangPhucVu({ serving, cot }: { serving: Phien[]; cot: readonly CotVanHanh[] }) {
  const hang = (ps: Phien[], nhan: string) => {
    const items = ps.flatMap((p) => p.items);
    return <tr><th scope="row">{nhan}</th>
      {([['ordered', 'Đặt'], ['served', 'Đã ra'], ['missing', 'Còn thiếu']] as const).map(([field, label]) => <td data-label={label} key={field}>{cong(items, field)}</td>)}
      {cot.map((c) => <td data-label={`${c} đặt / đã ra`} key={c}><div className="flex justify-end gap-1"><SoCot items={items} cot={c} field="ordered" /><span> / </span><SoCot items={items} cot={c} field="served" /></div></td>)}
      <td data-label="Tiền đơn">{tien(tongTien(ps, "order_total_vnd"))}</td><td data-label="Tiền bánh đã ra">{tien(tongTien(ps, "served_amount_vnd"))}</td>
    </tr>;
  };
  return <section aria-label="Bàn đang phục vụ" className={khung}>
    <h2 className="text-xl font-semibold">Bàn đang phục vụ</h2><p>{serving.length} bàn đang phục vụ</p>
    {serving.map((p) => <div key={p.table_session_id}><h3 className="font-semibold">{nhanBan(p)}</h3><AnHien ten={nhanBan(p)}><ChiTietBan phien={p} cot={cot} /></AnHien></div>)}
    <AnHien ten="bàn đang phục vụ" chiTiet><VungBang ten="Bảng đầy đủ"><table className="bang-day-du w-full text-left [&_th]:p-3 [&_td]:p-3">
      <thead><tr>{["Bàn", "Đặt", "Đã ra", "Còn thiếu", ...cot.map((c) => `${c} đặt / đã ra`), "Tiền đơn", "Tiền bánh đã ra"].map((c) => <th scope="col" key={c}>{c}</th>)}</tr></thead>
      <tbody>{serving.map((p) => <Fragment key={p.table_session_id}>{hang([p], nhanBan(p))}</Fragment>)}</tbody>
      <tfoot>{hang(serving, `Tổng ${serving.length} bàn`)}</tfoot>
    </table></VungBang></AnHien>
  </section>;
}
function SoDoBan({ data }: { data: BangVanHanh }) {
  const trangThai = { serving: ["Đang phục vụ", "bg-green-100 text-green-950"], waiting: ["Sắp phục vụ", "bg-yellow-100 text-yellow-950"], no_order: ["Đã mở, chưa gọi", ""], empty: ["Còn trống", "bg-gray-100 text-gray-800"] } as const;
  const ban = [...data.sessions.flatMap((p) => p.tables.map((b) => ({ ...b, nhom: p.service_group }))), ...data.empty_tables.map((b) => ({ ...b, nhom: "empty" as const }))].sort((a, b) => a.dining_table_id - b.dining_table_id);
  return <section aria-label="Sơ đồ bàn" className={khung}><h2 className="text-xl font-semibold">Sơ đồ bàn</h2><AnHien ten="sơ đồ bàn">
    <ul aria-label="Các bàn" className="grid grid-cols-3 gap-3 sm:grid-cols-5">{ban.map((b) => <li key={b.dining_table_id} className={`rounded border p-3 ${trangThai[b.nhom][1]}`}><strong>{b.label}</strong><p>{trangThai[b.nhom][0]}</p></li>)}</ul>
  </AnHien></section>;
}
function LichSuDemRa({ history }: { history: BangVanHanh["serve_history"] }) {
  // Mỗi mốc thời gian khác nhau của cùng mã bàn là một lần, tính từ cũ nhất.
  const moc = new Map<number, number[]>();
  for (const h of history) {
    const ds = moc.get(h.dining_table_id) ?? [];
    const t = Date.parse(h.served_at);
    if (!ds.includes(t)) ds.push(t);
    moc.set(h.dining_table_id, ds);
  }
  for (const ds of moc.values()) ds.sort((a, b) => a - b);
  const lan = (h: typeof history[number]) => moc.get(h.dining_table_id)!.indexOf(Date.parse(h.served_at)) + 1;
  return <section aria-label="Lịch sử phục vụ" className={khung}><h2 className="text-xl font-semibold">Lịch sử phục vụ</h2>
    {!history.length && <p>Chưa có lần đem ra nào hôm nay.</p>}
    <h3 className="font-semibold">Lịch sử đem ra</h3><AnHien ten="lịch sử đem ra"><VungBang ten="Bảng lịch sử đem ra"><table className="w-full text-left [&_th]:p-3 [&_td]:p-3">
      <thead><tr>{["Giờ", "Bàn", "Món", "Số cái", "Người", "Lần thứ (của bàn)"].map((c) => <th scope="col" key={c}>{c}</th>)}</tr></thead>
      <tbody>{history.map((h, i) => <tr key={i}><td>{gio(h.served_at)}</td><td>{h.table_label}</td><td>{h.component_name}</td><td>{h.quantity}</td><td>{h.person_name}</td><td>{lan(h)}</td></tr>)}</tbody>
    </table></VungBang></AnHien>
    <h3 className="font-semibold">Lịch sử theo bàn</h3><AnHien ten="lịch sử theo bàn"><div className="space-y-4">{[...new Set(history.map((h) => h.table_label))].map((ban) => <div key={ban}><h4 className="font-semibold">{ban}</h4><ul>{history.filter((h) => h.table_label === ban).map((h, i) => <li key={i}>Lần {lan(h)} · {gio(h.served_at)} · {h.component_name} · {h.quantity} cái · {h.person_name}</li>)}</ul></div>)}</div></AnHien>
  </section>;
}
function NoiDung({ data }: { data: BangVanHanh }) {
  const [chon, doi] = useState<number[]>([]);
  const [banTruoc, doiBanTruoc] = useState(data);
  const waiting = data.sessions.filter((p) => p.service_group === "waiting");
  // Điều chỉnh cùng render khi bản đọc đổi để lựa chọn cũ không sống lại ở lần đọc sau.
  if (data !== banTruoc) {
    doiBanTruoc(data);
    doi(chon.filter((id) => waiting.some((p) => p.table_session_id === id)));
  }
  const serving = data.sessions.filter((p) => p.service_group === "serving").sort((a, b) => Math.min(...a.tables.map((t) => t.dining_table_id)) - Math.min(...b.tables.map((t) => t.dining_table_id)));
  const cot = tenCot.filter((c) => c !== "Khác" || data.sessions.some((p) => p.items.some((i) => cotVanHanh(i).cot === "Khác")));
  return <>
    <BangThieuTheoBan serving={serving} chon={waiting.filter((p) => chon.includes(p.table_session_id))} cot={cot} />
    <CongThuGhepDon waiting={waiting} chon={chon} doi={doi} cot={cot} />
    <KhoiBanDangPhucVu serving={serving} cot={cot} /><SoDoBan data={data} /><LichSuDemRa history={data.serve_history} />
  </>;
}
export function TrangVanHanh() {
  const query = useBangVanHanh();
  return <div className="mx-auto w-full min-w-0 max-w-7xl space-y-6 p-4 sm:p-6">
    <header className="space-y-2"><h1 className="text-2xl font-semibold">Vận hành</h1>{query.data && <p>Ngày bán: {query.data.sale_date} · Giờ đọc: <time dateTime={query.data.read_at}>{gio(query.data.read_at)}</time></p>}</header>
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại</Button>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc tình hình bàn…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được tình hình bàn. {loiVanHanh(query.error as unknown as ApiFailure)}{query.data && ` Đang hiện bản đọc trước, lúc ${gio(query.data.read_at)}.`}</AlertDescription></Alert>}
    {query.data && <>{query.isFetching && <p role="status">Đang đọc lại tình hình bàn…</p>}<NoiDung data={query.data} /></>}
    <style>{`
      @media (max-width: 640px) {
        .bang-day-du, .bang-day-du tbody, .bang-day-du tfoot { display: block; width: 100%; }
        .bang-day-du thead { display: none; }
        .bang-day-du tr { display: block; border-bottom: 1px solid var(--border); padding: .5rem; }
        .bang-day-du th { display: block; text-align: left; }
        .bang-day-du td { display: flex; justify-content: space-between; gap: .5rem; }
        .bang-day-du td::before { content: attr(data-label); font-weight: 500; }
      }
    `}</style>
  </div>;
}
