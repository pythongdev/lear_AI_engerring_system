"use client";

import { useRef, useState } from "react";
import { LoaderCircle } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { DongMonDaGhi } from "@/components/shared/dong-mon-da-ghi";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { canDocLai, gio, loiHangCho, useBan, useDocLaiHangCho, useDonHen, useHangCho } from "./du-lieu-hang-cho";

function NutLenh({ id, loai, bao }: { id?: number; loai: "duyet" | "tu-choi" | "mo-lai" | "roi-quan"; bao: (s: string) => void }) {
  const api = useApi();
  const docLai = useDocLaiHangCho();
  const chot = useRef(false);
  const [ban, setBan] = useState(false);
  const [mo, setMo] = useState(false);
  const [loi, setLoi] = useState<string | null>(null);
  const nhan = loai === "roi-quan" ? `Rời quán đơn ${id}` : loai === "duyet" ? `Duyệt đơn ${id}` : loai === "tu-choi" ? `Từ chối đơn ${id}` : "Mở lại nhận đơn";
  async function gui() {
    if (chot.current) return;
    chot.current = true;
    setBan(true);
    setLoi(null);
    try {
      const r = loai === "mo-lai" ? await call(api.POST("/shop-blind/reopening")) :
        await call(api.POST(loai === "roi-quan" ? "/orders/{sales_order_id}/departure" : loai === "duyet" ? "/orders/{sales_order_id}/approval" : "/orders/{sales_order_id}/rejection", {
          params: { path: { sales_order_id: id! } },
        }));
      if (r.ok) {
        setMo(false);
        bao(loai === "roi-quan" ? `Đơn ${id} đã rời quán.` : loai === "mo-lai" ? "Đã mở lại nhận đơn." : `Đã ${loai === "duyet" ? "duyệt" : "từ chối"} đơn ${id}.`);
        if (!await docLai()) bao("Đã lưu nhưng chưa đọc lại được. Đang hiện bản đọc trước; hãy đọc lại.");
      } else {
        const message = loiHangCho(r.failure);
        if (loai === "tu-choi") setLoi(message); else bao(message);
        if (canDocLai(r.failure)) await docLai();
      }
    } finally { chot.current = false; setBan(false); }
  }
  const cho = <><LoaderCircle aria-hidden className="animate-spin" />Đang lưu…</>;
  if (loai !== "tu-choi") return <Button className="min-h-11" disabled={ban} onClick={() => void gui()} aria-label={nhan}>{ban ? cho : nhan}</Button>;
  return <Dialog open={mo} onOpenChange={(open) => { if (!chot.current) { setMo(open); setLoi(null); } }}>
    <DialogTrigger asChild><Button className="min-h-11" variant="outline" disabled={ban} aria-label={nhan}>{nhan}</Button></DialogTrigger>
    <DialogContent showCloseButton={false}>
      <DialogTitle>{nhan}</DialogTitle>
      <DialogDescription>Bạn có muốn từ chối đơn {id}?</DialogDescription>
      {loi && <Alert variant="destructive"><AlertDescription>{loi}</AlertDescription></Alert>}
      <div className="flex gap-2">
        <Button className="min-h-11" disabled={ban} onClick={() => void gui()}>{ban ? cho : "Từ chối"}</Button>
        <Button className="min-h-11" variant="outline" disabled={ban} onClick={() => setMo(false)}>Huỷ</Button>
      </div>
    </DialogContent>
  </Dialog>;
}

export function HangCho() {
  const hang = useHangCho();
  const ban = useBan();
  const hen = useDonHen();
  const docLai = useDocLaiHangCho();
  const [bao, setBao] = useState<string | null>(null);
  return <div className="space-y-4">
    <h1 className="text-2xl font-semibold">Hàng chờ quầy</h1>
    {bao && <p role="status">{bao}</p>}
    {hang.isPending && <p role="status" className="animate-pulse">Đang tải hàng chờ…</p>}
    {hang.isFetching && hang.data && <p role="status">Đang cập nhật…</p>}
    {hang.isError && <Alert variant="destructive"><AlertDescription>
      Chưa đọc được hàng chờ…{hang.data && ` Đang hiện bản đọc lúc ${gio(hang.data.read_at)}.`}
      <Button variant="outline" onClick={() => void docLai()}>Đọc lại</Button>
    </AlertDescription></Alert>}
    {hang.data?.paused_since && <Alert><AlertDescription>Đang tạm dừng nhận đơn từ {gio(hang.data.paused_since)}</AlertDescription></Alert>}
    {hang.data?.blind_since && <Alert><AlertDescription>
      Quán đang không thấy đơn từ {gio(hang.data.blind_since)}…
      <NutLenh loai="mo-lai" bao={setBao} />
    </AlertDescription></Alert>}
    {ban.isError && <Alert variant="destructive"><AlertDescription>Chưa đọc được nhãn bàn. <Button variant="outline" onClick={() => void ban.refetch()}>Đọc lại bàn</Button></AlertDescription></Alert>}
    {hang.data?.orders.length === 0 && <p>Không có đơn chờ xác nhận.</p>}
    {hang.data?.orders.map((don) => <section key={don.sales_order_id} aria-label={`Đơn ${don.sales_order_id}`} className="space-y-2 rounded-lg border p-4">
      <h2 className="font-semibold">Đơn {don.sales_order_id}</h2>
      <p>{don.channel_code === "qr_table" ? `QR · ${ban.data?.tables.find((b) => b.dining_table_id === don.dining_table_id)?.label ?? "Chưa đọc được nhãn bàn"}` : don.channel_code === "delivery" ? "Giao tận nơi" : "Khách tự đến lấy"}</p>
      <p>Tạo lúc {gio(don.created_at)}</p>
      {don.customer_phone && <p>{don.customer_phone}</p>}
      {don.customer_needed_at && <p>Cần lúc {gio(don.customer_needed_at)}</p>}
      <DongMonDaGhi lines={don.lines} total={don.total_vnd} />
      <div className="flex flex-wrap gap-2"><NutLenh loai="duyet" id={don.sales_order_id} bao={setBao} /><NutLenh loai="tu-choi" id={don.sales_order_id} bao={setBao} /></div>
    </section>)}
    <h2 className="text-xl font-semibold">Đơn đang làm</h2>
    {hang.data?.active_orders?.map((don) => <section key={don.sales_order_id} aria-label={`Đơn đang làm ${don.sales_order_id}`} className="space-y-2 rounded-lg border p-4">
      <h3>Đơn {don.sales_order_id}</h3>
      <p>{don.handover_code === "door_delivery" ? "Giao tận nơi" : "Khách tự đến lấy"}</p>
      <p>{don.status === "delivering" ? "Đang giao" : don.status === "in_progress" ? "Đang làm" : "Đã xác nhận"}</p>
      <p>{don.customer_name} {don.customer_phone}</p>
      {don.delivery_address && <p>{don.delivery_address}</p>}
      {don.contact_note && <p>{don.contact_note}</p>}
      {don.customer_needed_at && <p>Cần lúc {gio(don.customer_needed_at)}</p>}
      <DongMonDaGhi lines={don.lines} total={don.total_vnd} />
      {don.unserved_jobs > 0 && <p>{don.unserved_jobs} việc chưa ra bàn</p>}
      {don.handover_code === "door_delivery" && don.status === "in_progress" && <NutLenh loai="roi-quan" id={don.sales_order_id} bao={setBao} />}
    </section>)}
    <h2 className="text-xl font-semibold">Đơn hẹn</h2>
    {hen.isPending && <p role="status" className="animate-pulse">Đang tải đơn hẹn…</p>}
    {hen.isError && <Alert variant="destructive"><AlertDescription>Chưa đọc được đơn hẹn… {hen.data && "Đang hiện bản đọc trước."}<Button variant="outline" onClick={() => void hen.refetch()}>Đọc lại đơn hẹn</Button></AlertDescription></Alert>}
    {hen.data?.preorders.length === 0 && <p>Không có đơn hẹn.</p>}
    {hen.data?.preorders.map((don) => <section key={don.sales_order_id} aria-label={`Đơn hẹn ${don.sales_order_id}`} className="space-y-2 rounded-lg border p-4">
      <h3 className="font-semibold">Đơn hẹn {don.sales_order_id}</h3>
      <p>Cần lúc {gio(don.customer_needed_at)}</p>
      <p>{don.due_reminders.some((moc) => moc === 10) ? "Đã tới mốc nhắc 10 phút" : don.due_reminders.some((moc) => moc === 20) ? "Đã tới mốc nhắc 20 phút" : "Chưa tới mốc nhắc"}</p>
    </section>)}
  </div>;
}
