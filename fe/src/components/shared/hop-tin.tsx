"use client";

import Link from "next/link";
import { useEffect, useId, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import type { Khung } from "@/lib/auth/khung";
import { loiHopTin, useHopTin, type ThanGui, type Tin } from "./du-lieu-hop-tin";

const loaiViec = {
  canh: "Canh", don_ban: "Dọn bàn", trang_banh: "Tráng bánh", gap_banh: "Gấp bánh", khac: "Khác",
} satisfies Record<Tin["work_code"], string>;
const dinhDangGio = new Intl.DateTimeFormat("vi-VN", {
  timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric",
});
const gio = (moc: string) => dinhDangGio.format(new Date(moc));
const lopO = "block min-h-11 w-full rounded border bg-background px-3 py-2";
type TheKiem = { body: Omit<ThanGui, "submission_code"> & { recipient_person_id?: number }; nguoi: string; ban: string | null; submissionCode?: string };

export function HopTin({ khung, personId, mo }: { khung: Khung; personId: number; mo: boolean }) {
  const { tin, viec, nguoi, ban, gui } = useHopTin(khung, personId, mo);
  const caNhan = khung === "/tram";
  const [nguoiId, setNguoiId] = useState("");
  const [loai, setLoai] = useState<Tin["work_code"] | "">("");
  const [banId, setBanId] = useState("");
  const [noiDung, setNoiDung] = useState("");
  const [traLoi, setTraLoi] = useState<Tin | null>(null);
  const [the, setThe] = useState<TheKiem | null>(null);
  const [choGuiLai, setChoGuiLai] = useState(false);
  const [dangGui, setDangGui] = useState(false);
  const [loi, setLoi] = useState<string | null>(null);
  const [oLoi, setOLoi] = useState<string | undefined>();
  const [bao, setBao] = useState<string | null>(null);
  const chot = useRef(false);
  const oNhap = useRef<HTMLTextAreaElement>(null);
  const id = useId();
  useEffect(() => { if (mo) oNhap.current?.focus(); }, [mo]);
  const tenBan = (ma: number) => ban.data?.tables.find((b) => b.dining_table_id === ma)?.label ?? String(ma);
  const nguoiNhan = nguoi.data?.people.find((n) => n.person_id === Number(nguoiId) && n.person_id !== personId);
  const soKyTu = Array.from(noiDung).length;
  const hopLe = !!(loai && noiDung.trim() && soKyTu <= 500 && (caNhan || nguoiNhan));

  function xemLai() {
    if (!hopLe || !loai || the) return;
    setLoi(null); setOLoi(undefined); setBao(null);
    setThe({
      body: {
        work_code: loai, body: noiDung, dining_table_id: banId ? Number(banId) : null,
        reply_to_message_id: traLoi?.station_message_id ?? null,
        ...(!caNhan ? { recipient_person_id: Number(nguoiId) } : {}),
      },
      nguoi: caNhan ? "Quầy" : nguoiNhan!.display_name,
      ban: banId ? tenBan(Number(banId)) : null,
    });
  }

  async function xacNhan() {
    if (!the || chot.current) return;
    chot.current = true; setDangGui(true); setLoi(null); setOLoi(undefined);
    try {
      const p = the.submissionCode ? the : { ...the, submissionCode: crypto.randomUUID() };
      setThe(p);
      const r = await gui({ ...p.body, submission_code: p.submissionCode! });
      if (!r.ok) {
        setLoi(loiHopTin(r.failure));
        const chuaRo = r.failure.kind !== "rejected";
        setChoGuiLai(chuaRo);
        if (!chuaRo) {
          setThe(null);
          setOLoi(r.failure.kind === "rejected" ? r.failure.field : undefined);
        }
        return;
      }
      setThe(null); setChoGuiLai(false); setNoiDung(""); setTraLoi(null);
      setNguoiId(""); setBao("Đã gửi tin.");
    } finally { chot.current = false; setDangGui(false); }
  }

  const loiO = (field: string) => ({ "aria-invalid": oLoi === field || undefined, "aria-describedby": oLoi === field ? `${id}-loi` : undefined });
  return <div className="space-y-4">
    {tin.isPending && <p role="status">Đang đọc tin…</p>}
    {tin.isError && <div role="alert">
      <p>{tin.data ? "Chưa đọc được tin mới. Đang hiện bản cũ." : "Chưa đọc được tin."}</p>
      <Button type="button" className="min-h-11" onClick={() => void tin.refetch()}>Đọc lại tin</Button>
    </div>}
    {tin.data && <>
      <p className="text-sm">Cập nhật lúc {gio(tin.data.read_at)}</p>
      {tin.data.messages.length === 0 ? <p>Chưa có tin.</p> : <ul aria-label="Tin nhắn" className="space-y-3">
        {tin.data.messages.map((t) => <li key={t.station_message_id} className="space-y-1 rounded border p-3">
          <p className="font-semibold">{loaiViec[t.work_code]}</p>
          <p>Từ {t.sender_name} · {t.recipient_person_id === null ? "về quầy" : `tới ${t.recipient_name}`}</p>
          <p className="whitespace-pre-wrap break-words">{t.body}</p>
          {t.dining_table_id !== null && <p>Bàn {tenBan(t.dining_table_id)}</p>}
          <time dateTime={t.created_at} className="block text-sm">{gio(t.created_at)}</time>
          {khung === "/quay" && (["canh", "trang_banh", "gap_banh"].includes(t.work_code)
            ? <Link className="inline-flex min-h-11 items-center underline" href="/quay/san-xuat">Mở Sản xuất</Link>
            : t.work_code === "khac" && t.dining_table_id !== null
              ? <Link className="inline-flex min-h-11 items-center underline" href="/quay/goi-mon">Mở Gọi món</Link> : null)}
          <Button type="button" variant="outline" className="min-h-11" disabled={!!the} onClick={() => {
            setTraLoi(t); if (!caNhan) setNguoiId(String(t.sender_person_id)); oNhap.current?.focus();
          }}>Trả lời</Button>
        </li>)}
      </ul>}
    </>}
    {bao && <p role="status">{bao}</p>}
    {loi && <p role="alert" id={`${id}-loi`}>{loi}</p>}
    {nguoi.isError && !caNhan && <p role="alert">Chưa đọc được người nhận.</p>}
    {ban.isError && <p role="alert">Chưa đọc được danh sách bàn.</p>}
    <form aria-label="Soạn tin" onSubmit={(e) => { e.preventDefault(); xemLai(); }}>
      <fieldset disabled={!!the} className="space-y-3">
        {caNhan ? <p>Gửi về quầy</p> : <label className="block">Người nhận
          <select className={lopO} value={nguoiId} onChange={(e) => setNguoiId(e.target.value)} {...loiO("recipient_person_id")}>
            <option value="">Chọn người nhận</option>
            {nguoi.data?.people.filter((n) => n.person_id !== personId).map((n) => <option key={n.person_id} value={n.person_id}>{n.display_name}</option>)}
          </select>
        </label>}
        <label className="block">Loại việc
          <select className={lopO} value={loai} onChange={(e) => setLoai(e.target.value as typeof loai)} {...loiO("work_code")}>
            <option value="">Chọn loại việc</option>
            {Object.entries(loaiViec).map(([ma, ten]) => <option key={ma} value={ma}>{ten}</option>)}
          </select>
        </label>
        <label className="block">Bàn
          <select className={lopO} value={banId} onChange={(e) => setBanId(e.target.value)} {...loiO("dining_table_id")}>
            <option value="">Không gắn bàn</option>
            {ban.data?.tables.map((b) => <option key={b.dining_table_id} value={b.dining_table_id}>{b.label}</option>)}
          </select>
        </label>
        {traLoi && <div><p>Đang trả lời {traLoi.sender_name}</p>
          <Button type="button" variant="outline" className="min-h-11" onClick={() => setTraLoi(null)}>Bỏ trả lời</Button>
        </div>}
        <label className="block">Nội dung tin
          <textarea ref={oNhap} className={lopO} rows={3} value={noiDung} onChange={(e) => setNoiDung(e.target.value)} {...loiO("body")} />
        </label>
        {soKyTu > 500 && <p>Tối đa 500 ký tự</p>}
        <Button type="submit" className="min-h-11" disabled={!hopLe}>Xem lại trước khi gửi</Button>
      </fieldset>
    </form>
    {the && <section aria-label="Kiểm tin trước khi gửi" className="space-y-2 rounded border p-3">
      <p>Người nhận: {the.nguoi}</p>
      <p>Loại việc: {loaiViec[the.body.work_code]}</p>
      {the.ban !== null && <p>Bàn: {the.ban}</p>}
      <p className="whitespace-pre-wrap break-words">{the.body.body}</p>
      <Button type="button" className="min-h-11" disabled={dangGui} onClick={() => void xacNhan()}>{choGuiLai ? "Gửi lại" : "Xác nhận gửi"}</Button>
      {!choGuiLai && <Button type="button" variant="outline" className="min-h-11" disabled={dangGui} onClick={() => setThe(null)}>Sửa lại</Button>}
    </section>}
    <section aria-label="Việc được giao" className="space-y-2">
      <h3 className="font-semibold">Việc của tôi</h3>
      {viec.isPending && <p role="status">Đang đọc việc được giao…</p>}
      {viec.isError && <p role="alert">Chưa đọc được việc của tôi.{viec.data && " Đang hiện bản cũ."}</p>}
      {viec.data && (viec.data.assigned_tasks.length === 0 ? <p>Không có việc được giao.</p> : <ul aria-label="Việc của tôi" className="space-y-3">
        {viec.data.assigned_tasks.map((v) => <li key={v.assigned_task_id} className="space-y-1 rounded border p-3">
          <p className="whitespace-pre-wrap break-words">{v.content}</p>
          <p>{v.due_at ? `Hạn ${gio(v.due_at)}` : "Chưa có hạn"}</p>
          <p>Giao bởi {v.assigned_by_name}</p>
          <p>{v.done ? "Đã xong" : "Chưa xong"}</p>
          {v.guides.map((g, i) => <p key={i} className="whitespace-pre-wrap break-words">{g.body}</p>)}
        </li>)}
      </ul>)}
    </section>
  </div>;
}
