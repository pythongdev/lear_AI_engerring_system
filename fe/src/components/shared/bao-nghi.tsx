"use client";

import { useId, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import type { Khung } from "@/lib/auth/khung";
import { congNgay, loiBaoNghi, useBaoNghi, type ThanBaoNghi } from "./du-lieu-bao-nghi";

const lichVietNam = new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Ho_Chi_Minh", year: "numeric", month: "2-digit", day: "2-digit" });
const ngayHien = (ngay: string) => ngay.split("-").reverse().join("/");
type TheKiem = { leave_date: string; submission_code?: string };

export function BaoNghi({ khung, personId, mo }: { khung: Khung; personId: number; mo: boolean }) {
  const homNay = lichVietNam.format(new Date());
  const { danhSach, gui, ghi } = useBaoNghi(khung, personId, mo, homNay);
  const chuQuan = khung === "/chu-quan";
  const [ngay, setNgay] = useState("");
  const [the, setThe] = useState<TheKiem | null>(null);
  const [choGuiLai, setChoGuiLai] = useState(false);
  const [dangGui, setDangGui] = useState(false);
  const [loi, setLoi] = useState<string | null>(null);
  const [bao, setBao] = useState<string | null>(null);
  const [oLoi, setOLoi] = useState<string | undefined>();
  const chot = useRef(false);
  const id = useId();
  const hopLe = !!ngay && ngay >= homNay;

  async function xacNhan() {
    if (!the || chot.current) return;
    chot.current = true; setDangGui(true); setLoi(null); setOLoi(undefined);
    try {
      const body: ThanBaoNghi = { leave_date: the.leave_date, submission_code: the.submission_code ?? crypto.randomUUID() };
      setThe(body);
      const r = await gui(body);
      if (!r.ok) {
        setLoi(loiBaoNghi(r.failure, true));
        const chuaRo = r.failure.kind !== "rejected";
        setChoGuiLai(chuaRo);
        if (!chuaRo) {
          setThe(null);
          setOLoi(r.failure.kind === "rejected" ? r.failure.field : undefined);
        }
        return;
      }
      setThe(null); setChoGuiLai(false); setNgay("");
      setBao(`Đã gửi báo nghỉ ngày ${ngayHien(body.leave_date)}.`);
    } finally { chot.current = false; setDangGui(false); }
  }

  async function ghiDong(ma: number, viec: "cancel" | "acknowledge") {
    if (chot.current) return;
    chot.current = true; setDangGui(true); setLoi(null); setBao(null);
    try {
      const r = await ghi(ma, viec);
      if (!r.ok) setLoi(loiBaoNghi(r.failure, false));
    } finally { chot.current = false; setDangGui(false); }
  }

  const tenDanhSach = chuQuan ? "Báo nghỉ của nhân viên" : "Báo nghỉ của tôi";
  return <div className="space-y-4">
    {bao && <p role="status">{bao}</p>}
    {loi && <p role="alert" id={`${id}-loi`}>{loi}</p>}
    {!chuQuan && <>
      <form aria-label="Soạn báo nghỉ" onSubmit={(e) => {
        e.preventDefault();
        if (!hopLe || the || dangGui) return;
        setLoi(null); setBao(null); setOLoi(undefined); setChoGuiLai(false);
        setThe({ leave_date: ngay });
      }}>
        <fieldset disabled={!!the || dangGui} className="space-y-3">
          <label className="block">Ngày nghỉ
            <input type="date" min={homNay} value={ngay} onChange={(e) => setNgay(e.target.value)}
              className="block min-h-11 w-full rounded border bg-background px-3 py-2"
              aria-invalid={oLoi === "leave_date" || undefined} aria-describedby={oLoi === "leave_date" ? `${id}-loi` : undefined} />
          </label>
          {ngay && ngay < homNay && <p>Chọn ngày từ hôm nay trở đi.</p>}
          <Button type="submit" className="min-h-11" disabled={!hopLe}>Xem lại báo nghỉ</Button>
        </fieldset>
      </form>
      {the && <section aria-label="Kiểm báo nghỉ trước khi gửi" className="space-y-2 rounded border p-3">
        <p>Ngày nghỉ: {ngayHien(the.leave_date)}</p>
        <p>Báo cho: Chủ quán</p>
        <p>Dự kiến: {the.leave_date >= congNgay(homNay, 3) ? "Báo trước" : "Đột xuất"}</p>
        <p>Loại chính thức do quán ghi khi nhận báo nghỉ.</p>
        <Button type="button" className="min-h-11" disabled={dangGui} onClick={() => void xacNhan()}>{choGuiLai ? "Gửi lại" : "Xác nhận báo nghỉ"}</Button>
        {!choGuiLai && <Button type="button" variant="outline" className="min-h-11" disabled={dangGui} onClick={() => setThe(null)}>Sửa lại</Button>}
      </section>}
    </>}
    <section aria-label={tenDanhSach} className="space-y-2">
      <h3 className="font-semibold">{tenDanhSach}</h3>
      {danhSach.isPending && <p role="status">Đang đọc báo nghỉ…</p>}
      {danhSach.isError && <div role="alert">
        <p>Chưa đọc được báo nghỉ.{danhSach.data && " Đang hiện bản cũ."}</p>
        <Button type="button" className="min-h-11" onClick={() => void danhSach.refetch()}>Đọc lại báo nghỉ</Button>
      </div>}
      {danhSach.data && (danhSach.data.leave_notices.length === 0 ? <p>Chưa có báo nghỉ.</p> : <ul aria-label={tenDanhSach} className="space-y-3">
        {danhSach.data.leave_notices.map((n) => <li key={n.leave_notice_id} className="space-y-1 rounded border p-3">
          {chuQuan && <p>{n.person_name}</p>}
          <p>Ngày {ngayHien(n.leave_date)}</p>
          <p>{n.notice_kind === "bao_truoc" ? "Báo trước" : "Đột xuất"}</p>
          <p>{n.cancelled_at ? "Đã huỷ" : n.acknowledged_at ? "Chủ quán đã biết" : "Chủ quán chưa xem"}</p>
          {chuQuan && !n.acknowledged_at && <Button type="button" className="min-h-11" disabled={dangGui} onClick={() => void ghiDong(n.leave_notice_id, "acknowledge")}>Đã biết</Button>}
          {n.can_cancel && <Button type="button" variant="outline" className="min-h-11" disabled={dangGui} onClick={() => void ghiDong(n.leave_notice_id, "cancel")}>{chuQuan ? "Huỷ" : "Huỷ báo nghỉ"}</Button>}
        </li>)}
      </ul>)}
    </section>
  </div>;
}
