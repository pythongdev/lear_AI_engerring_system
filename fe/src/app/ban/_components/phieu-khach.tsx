"use client";

import { useRef, useState } from "react";
import { QrCode } from "lucide-react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { dongGui, giaDong, useGiaCombo } from "@/components/shared/bo-soan-mon";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { dungLai, useNhapKhach } from "@/lib/nhap-khach";
import { SITE_NAME } from "@/lib/seo";
import { ThucDonKhach } from "./thuc-don-khach";
import styles from "./thuc-don-khach.module.css";
import { loiKhach } from "./loi-khach";

type Phieu = { loai: "qr"; ma: string; body: components["schemas"]["QrOrderRequest"] }
  | { loai: "web"; body: components["schemas"]["OnlineOrderRequest"] };

export function PhieuKhach({ ma, nhan, initialMenu }: {
  ma?: string; nhan?: string; initialMenu: components["schemas"]["Menu"];
}) {
  const api = useApi();
  const qc = useQueryClient();
  const web = ma === undefined;
  const khoaNhap = web ? "web" : `qr:${ma}`;
  const nhap = useNhapKhach((s) => s.gio[khoaNhap]);
  const sua = useNhapKhach((s) => s.sua);
  const menu = useQuery({ queryKey: ["menu"], initialData: initialMenu, queryFn: async () => {
    const r = await call(api.GET("/menu"));
    if (!r.ok) throw new Error("Chưa đọc được menu.");
    return r.data;
  } });
  const lines = dungLai(nhap, menu.data);
  const quotes = useGiaCombo(lines);
  // Bộ soạn dùng cả ở quầy; khách chỉ thấy lời trung tính cho lỗi không phải lỗi combo đã có chữ.
  const quotesKhach = quotes.map((q) => q.isError ? { ...q, error: new Error(q.error.message.includes("Mã:") ? "Chưa tính được giá. Bạn vui lòng thử lại." : q.error.message) } : q);
  const duMon = lines.length > 0 && lines.every((d) => Number.isInteger(d.quantity) && d.quantity > 0 && (d.combo || giaDong(d)));
  const bodyGia = { lines: lines.map(dongGui) };
  const tong = useQuery({ queryKey: ["price-quotes", "khach", khoaNhap, bodyGia, menu.dataUpdatedAt], enabled: duMon,
    queryFn: async () => {
      const r = await call(api.POST("/price-quotes", { body: bodyGia }));
      if (!r.ok) throw new Error(r.failure.kind === "rejected" ? loiKhach(r.failure) : "Chưa tính được tổng. Bạn vui lòng thử lại.");
      return r.data;
    },
  });
  const [cach, setCach] = useState<"delivery" | "pickup" | "">("");
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
  const duThongTin = !web || !!(cach && sdt.trim() && (cach === "delivery" ? diaChi.trim() : gioCan));
  const hopLe = duMon && duThongTin && tong.isSuccess && !tong.isFetching;

  async function gui() {
    if (chot.current || (!phieu.current && !hopLe)) return;
    chot.current = true;
    setDangGui(true);
    setLoi(null);
    setBao(null);
    try {
      if (!phieu.current) {
        const submission_code = crypto.randomUUID();
        const dong = lines.map(dongGui);
        phieu.current = web ? { loai: "web", body: {
          submission_code, channel_code: cach as "delivery" | "pickup", customer_phone: sdt,
          delivery_address: cach === "delivery" ? diaChi : null,
          customer_needed_at: gioCan ? `${gioCan}:00+07:00` : null,
          customer_name: ten.trim() ? ten : null, contact_note: ghiChu.trim() ? ghiChu : null, lines: dong,
        } } : { loai: "qr", ma: ma!, body: {
          submission_code,
          // OpenAPI không required is_takeaway, mặc định false. Type sinh đánh dấu required vì default;
          // phiếu khách phải bỏ trường này trên dây theo hợp đồng và phiếu P4-10.
          lines: dong as components["schemas"]["QrOrderRequest"]["lines"],
        } };
      }
      const p = phieu.current;
      const r = p.loai === "qr"
        ? await call(api.POST("/qr-codes/{code}/orders", { params: { path: { code: p.ma } }, body: p.body }))
        : await call(api.POST("/online-orders", { body: p.body }));
      if (!r.ok) {
        setLoi(loiKhach(r.failure));
        const chuaRo = r.failure.kind !== "rejected";
        setChoGuiLai(chuaRo);
        if (!chuaRo) phieu.current = null;
        return;
      }
      setBao(p.loai === "qr" ? `Đã gửi lượt gọi · tổng ${tien(r.data.total_vnd)}` : `Đã đặt đơn ${r.data.sales_order_id} · tổng ${tien(r.data.total_vnd)}`);
      phieu.current = null;
      setChoGuiLai(false);
      sua(khoaNhap, []);
      if (web) { setCach(""); setSdt(""); setDiaChi(""); setGioCan(""); setTen(""); setGhiChu(""); }
      try { await qc.invalidateQueries({ queryKey: ["menu"] }, { throwOnError: true }); }
      catch { setLoi("Đã lưu nhưng chưa đọc lại được menu. Bạn vui lòng đọc lại menu."); }
    } finally { chot.current = false; setDangGui(false); }
  }
  return <main className={styles.page}><div className={styles.phone}>
    <header data-component="MenuHeader"><small>{SITE_NAME}</small>
    <h1 className="flex items-center gap-2 text-2xl font-semibold">
      {!web && <QrCode aria-hidden="true" />}
      {web ? "Đặt món" : /^\d+$/.test(nhan?.trim() ?? "") ? `Bàn ${nhan!.trim()}` : nhan}
    </h1></header>
    {bao && <p role="status">{bao}</p>}
    {loi && <p role="alert">{loi}</p>}
    {menu.isError && <p role="alert">Chưa đọc được menu. Đang hiện bản đọc lúc {new Date(menu.dataUpdatedAt).toLocaleTimeString("vi-VN")}. <Button onClick={() => void menu.refetch()}>Đọc lại menu</Button></p>}
    <form onSubmit={(e) => { e.preventDefault(); void gui(); }} className="space-y-4">
      <fieldset disabled={dangGui || choGuiLai} className="space-y-4">
        <ThucDonKhach items={menu.data.items} combos={menu.data.combos} lines={lines} onChange={(ds) => sua(khoaNhap, ds)} quotes={quotesKhach}
          total={duMon && tong.isSuccess && !tong.isFetching ? tong.data.total_vnd : undefined}
          thongTin={web && <>
          <fieldset className="flex flex-wrap gap-4"><legend>Cách nhận hàng</legend>
            <label className="inline-flex min-h-11 items-center gap-2"><input type="radio" name="cach" checked={cach === "delivery"} onChange={() => setCach("delivery")} />Giao tận nơi</label>
            <label className="inline-flex min-h-11 items-center gap-2"><input type="radio" name="cach" checked={cach === "pickup"} onChange={() => setCach("pickup")} />Đến lấy</label>
          </fieldset>
          <label className="block">Số điện thoại<Input type="tel" required value={sdt} onChange={(e) => setSdt(e.target.value)} /></label>
          {cach === "delivery" && <label className="block">Địa chỉ giao<Input required value={diaChi} onChange={(e) => setDiaChi(e.target.value)} /></label>}
          <label className="block">Giờ cần hàng<Input type="datetime-local" required={cach === "pickup"} value={gioCan} onChange={(e) => setGioCan(e.target.value)} /></label>
          <p>Giờ quán: Asia/Ho_Chi_Minh (UTC+07:00).</p>
          <label className="block">Tên<Input value={ten} onChange={(e) => setTen(e.target.value)} /></label>
          <label className="block">Ghi chú<Input value={ghiChu} onChange={(e) => setGhiChu(e.target.value)} /></label>
        </>}
          tong={duMon && (tong.isFetching ? <p role="status">Đang tính tổng…</p> : tong.isError
        ? <p role="alert">{tong.error.message} <Button type="button" onClick={() => void tong.refetch()}>Tính lại</Button></p>
        : tong.isSuccess && <p>Tổng tạm tính {tien(tong.data.total_vnd)}</p>)} />
      </fieldset>
      <Button data-component="CartBottomBar" className={styles.submit} type="submit" disabled={dangGui || (!choGuiLai && !hopLe)}>{dangGui ? "Đang gửi…" : choGuiLai ? "Gửi lại" : web ? "Đặt đơn" : "Gửi lượt gọi"}</Button>
    </form>
  </div></main>;
}
