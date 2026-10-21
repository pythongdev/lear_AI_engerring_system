"use client";

import Link from "next/link";
import { useRef, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { LoaderCircle } from "lucide-react";
import { BoSoanMon, giaDong, type DongSoan } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { useBan } from "./du-lieu-hang-cho";
import { loiSoanDon, useMenuSoan } from "./du-lieu-soan-don";

type Phieu = { loai: "ban"; body: components["schemas"]["TableOrderRequest"]; nhan: string }
  | { loai: "dien-thoai"; body: components["schemas"]["PhoneOrderRequest"] };

export function SoanDon({ dienThoai = false }: { dienThoai?: boolean }) {
  const api = useApi();
  const qc = useQueryClient();
  const menu = useMenuSoan();
  const ban = useBan(!dienThoai);
  const [banId, setBanId] = useState("");
  const [lines, setLines] = useState<DongSoan[]>([]);
  const [cach, setCach] = useState<"door_delivery" | "shop_pickup" | "">("");
  const [sdt, setSdt] = useState("");
  const [diaChi, setDiaChi] = useState("");
  const [gioCan, setGioCan] = useState("");
  const [ten, setTen] = useState("");
  const [ghiChu, setGhiChu] = useState("");
  const [bao, setBao] = useState<string | null>(null);
  const [loi, setLoi] = useState<string | null>(null);
  const [dangGui, setDangGui] = useState(false);
  const [choGuiLai, setChoGuiLai] = useState(false);
  const chot = useRef(false);
  const phieu = useRef<Phieu | null>(null);
  const duMon = lines.length > 0 && lines.every((d) => Number.isInteger(d.quantity) && d.quantity > 0 && giaDong(d));
  const hopLe = duMon && (dienThoai ? !!(cach && sdt.trim() && gioCan && (cach !== "door_delivery" || diaChi.trim())) : !!banId);

  async function gui() {
    if (chot.current || (!phieu.current && !hopLe)) return;
    chot.current = true;
    setDangGui(true);
    setLoi(null);
    setBao(null);
    try {
      if (!phieu.current) {
        const submission_code = crypto.randomUUID();
        const dong = lines.map((d) => ({ menu_item_id: d.mon.menu_item_id, quantity: d.quantity, option_ids: [...d.option_ids] }));
        phieu.current = dienThoai ? { loai: "dien-thoai", body: {
          submission_code, handover_code: cach as "door_delivery" | "shop_pickup", customer_phone: sdt,
          delivery_address: cach === "door_delivery" ? diaChi : null,
          customer_needed_at: `${gioCan}:00+07:00`, customer_name: ten.trim() ? ten : null, contact_note: ghiChu.trim() ? ghiChu : null,
          lines: dong,
        } } : { loai: "ban", nhan: ban.data?.tables.find((b) => b.dining_table_id === Number(banId))?.label ?? "", body: {
          submission_code, dining_table_id: Number(banId), lines: dong.map((d, i) => ({ ...d, is_takeaway: lines[i].is_takeaway })),
        } };
      }
      const p = phieu.current;
      const r = p.loai === "ban" ? await call(api.POST("/table-orders", { body: p.body })) : await call(api.POST("/phone-orders", { body: p.body }));
      if (!r.ok) {
        setLoi(loiSoanDon(r.failure));
        const chuaRo = r.failure.kind !== "rejected";
        setChoGuiLai(chuaRo);
        if (!chuaRo) phieu.current = null;
        return;
      }
      setBao(p.loai === "ban" ? `Đã gửi lượt gọi ${p.nhan} · tổng ${tien(r.data.total_vnd)}` : `Đã tạo đơn ${r.data.sales_order_id} · tổng ${tien(r.data.total_vnd)}`);
      phieu.current = null;
      setChoGuiLai(false);
      setLines([]);
      if (dienThoai) { setCach(""); setSdt(""); setDiaChi(""); setGioCan(""); setTen(""); setGhiChu(""); }
      const results = await Promise.allSettled(["menu", "dining-tables", "counter/queue", "preorder-reminders"].map((key) => qc.invalidateQueries({ queryKey: [key] }, { throwOnError: true })));
      if (results.some((r) => r.status === "rejected")) setLoi("Đã lưu nhưng chưa đọc lại được. Hãy đọc lại dữ liệu.");
    } finally { chot.current = false; setDangGui(false); }
  }
  const khoa = dangGui || choGuiLai;
  return <div className="space-y-4">
    <h1 className="text-2xl font-semibold">{dienThoai ? "Đơn điện thoại" : "Gọi món tại bàn"}</h1>
    <Link href="/quay" className="underline">Về hàng chờ</Link>
    {bao && <p role="status">{bao}</p>}
    {loi && <Alert variant="destructive"><AlertDescription>{loi}</AlertDescription></Alert>}
    {menu.isPending && <p role="status" className="animate-pulse">Đang tải menu…</p>}
    {menu.isFetching && menu.data && <p role="status">Đang cập nhật…</p>}
    {menu.isError && <Alert variant="destructive"><AlertDescription>Chưa đọc được menu.{menu.data && ` Đang hiện bản đọc lúc ${new Date(menu.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`} <Button onClick={() => void menu.refetch()}>Đọc lại menu</Button></AlertDescription></Alert>}
    {!dienThoai && ban.isPending && <p role="status">Đang tải bàn…</p>}
    {!dienThoai && ban.isError && <Alert variant="destructive"><AlertDescription>Chưa đọc được bàn. <Button onClick={() => void ban.refetch()}>Đọc lại bàn</Button></AlertDescription></Alert>}
    <form onSubmit={(e) => { e.preventDefault(); void gui(); }} className="space-y-4">
      <fieldset disabled={khoa} className="space-y-4">
        {!dienThoai ? ban.data && <label className="block">Bàn
          <select className="ml-2 min-h-11 rounded border px-3" value={banId} onChange={(e) => setBanId(e.target.value)}>
            <option value="">Chọn bàn</option>
            {ban.data?.tables.map((b) => <option key={b.dining_table_id} value={b.dining_table_id}>{b.label}</option>)}
          </select>
        </label> : <>
          <fieldset className="space-x-4"><legend>Cách trao</legend>
            <label className="inline-flex min-h-11 items-center gap-2"><input type="radio" name="cach-trao" checked={cach === "door_delivery"} onChange={() => setCach("door_delivery")} />Giao tận nơi</label>
            <label className="inline-flex min-h-11 items-center gap-2"><input type="radio" name="cach-trao" checked={cach === "shop_pickup"} onChange={() => setCach("shop_pickup")} />Khách tự đến lấy</label>
          </fieldset>
          <label className="block">Số điện thoại<Input type="tel" required value={sdt} onChange={(e) => setSdt(e.target.value)} /></label>
          {cach === "door_delivery" && <label className="block">Địa chỉ giao<Input required value={diaChi} onChange={(e) => setDiaChi(e.target.value)} /></label>}
          <label className="block">Giờ cần hàng<Input type="datetime-local" required value={gioCan} onChange={(e) => setGioCan(e.target.value)} /></label>
          <p>Giờ quán: Asia/Ho_Chi_Minh (UTC+07:00).</p>
          <label className="block">Tên khách<Input value={ten} onChange={(e) => setTen(e.target.value)} /></label>
          <label className="block">Ghi chú<Input value={ghiChu} onChange={(e) => setGhiChu(e.target.value)} /></label>
        </>}
        {menu.data && <BoSoanMon items={menu.data.items} lines={lines} onChange={setLines} mangVe={!dienThoai} />}
      </fieldset>
      <Button type="submit" disabled={dangGui || (!choGuiLai && !hopLe)} className="min-h-11">
        {dangGui ? <><LoaderCircle aria-hidden className="animate-spin" />Đang gửi…</> : choGuiLai ? "Gửi lại" : dienThoai ? "Gửi đơn điện thoại" : "Gửi lượt gọi"}
      </Button>
    </form>
  </div>;
}
