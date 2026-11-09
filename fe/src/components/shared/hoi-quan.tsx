"use client";

import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import type { Khung } from "@/lib/auth/khung";
import { loiTaiKhoan } from "@/lib/auth/messages";

type TraLoi = components["schemas"]["ChatTurnResponse"];
type Luot = { question: string; response: TraLoi };
const gio = new Intl.DateTimeFormat("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit" });
const gioNoiBo = new Intl.DateTimeFormat("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit", second: "2-digit" });
const tenNguon: Record<string, string> = { doc_menu: "Thực đơn", tinh_gia: "Bảng giá" };
const tenNguonNoiBo: Record<string, string> = {
  ...tenNguon,
  doc_bang_tram: "Bảng trạm",
  doc_bang_phuc_vu: "Bảng phục vụ",
  doc_tong_quan: "Tổng quan",
};
const manTay: Record<Khung, { href: string; ten: string }> = {
  "/tram": { href: "/tram", ten: "Xem Bảng trạm" },
  "/quay": { href: "/quay/san-xuat", ten: "Xem Sản xuất" },
  "/chu-quan": { href: "/chu-quan/van-hanh", ten: "Xem Vận hành" },
};
const suyGiam: Record<string, string> = {
  tat: "Trợ lý đang tắt.",
  het_ngan_sach: "Trợ lý đã dùng hết lượt hỏi của hôm nay.",
  qua_han: "Trợ lý trả lời quá lâu nên đã dừng.",
  qua_so_lan: "Trợ lý chưa tìm được câu trả lời.",
  loi_hang: "Trợ lý đang gặp lỗi.",
};
function loiHoi(loi: ApiFailure, khung?: Khung) {
  if (loi.kind === "no_response") return "Không kết nối được tới quán. Thử lại sau.";
  if (khung && loi.kind === "rejected" && loi.status === 401 && loi.code === "unauthenticated") return loiTaiKhoan(loi);
  if (loi.kind === "rejected" && loi.status === 400 && loi.code === "invalid_request") return "Câu hỏi chưa đúng hình.";
  return `Chưa hỏi được (${loi.kind === "rejected" ? loi.code : loi.status}).`;
}

export function HoiQuan({ mo, khung }: { mo: boolean; khung?: Khung }) {
  const api = useApi();
  const nguon = khung ? tenNguonNoiBo : tenNguon;
  const dinhDangGio = khung ? gioNoiBo : gio;
  const duongVe = khung ? manTay[khung] : { href: "/dat-mon", ten: "Xem thực đơn" };
  const linkManTay = <a href={duongVe.href} className="underline">{duongVe.ten}</a>;
  const [cau, setCau] = useState("");
  const [luot, setLuot] = useState<Luot[]>([]);
  const [dangHoi, setDangHoi] = useState(false);
  const [loi, setLoi] = useState<string | null>(null);
  const oNhap = useRef<HTMLTextAreaElement>(null);
  const soLuot = useRef(0);
  const cho = useRef<AbortController | null>(null);

  const [moTruoc, setMoTruoc] = useState(mo);
  if (mo !== moTruoc) {
    setMoTruoc(mo);
    if (!mo) setDangHoi(false);
  }

  useEffect(() => {
    if (mo) oNhap.current?.focus();
    return () => {
      soLuot.current += 1;
      cho.current?.abort();
      cho.current = null;
    };
  }, [mo]);

  const question = cau.trim();
  const quaDai = Array.from(question).length > 500;
  async function hoi() {
    if (!mo || !question || quaDai || cho.current) return;
    const controller = new AbortController();
    cho.current = controller;
    const lan = ++soLuot.current;
    setDangHoi(true); setLoi(null);
    const history = luot.filter((l) => l.response.degraded_reason === null && l.response.answer)
      .slice(-6).flatMap((l) => [
        { role: "user" as const, text: l.question },
        { role: "assistant" as const, text: l.response.answer! },
      ]);
    const r = await call(api.POST("/chat/turns", { body: { question, history }, signal: controller.signal }));
    if (controller.signal.aborted || lan !== soLuot.current) return;
    cho.current = null;
    setDangHoi(false);
    if (!r.ok) { setLoi(loiHoi(r.failure, khung)); return; }
    setLuot((truoc) => [...truoc, { question, response: r.data }]);
    setCau("");
  }

  return <div className="min-w-0 space-y-3 break-words">
    <div role="log" aria-live="polite" aria-label="Hội thoại" className="space-y-3">
      {luot.map((l, i) => <div key={i} className="space-y-1 whitespace-pre-wrap">
        <p>{l.question}</p>
        {l.response.degraded_reason !== null ? <p role="status">
          {suyGiam[l.response.degraded_reason] ?? `Trợ lý chưa trả lời được (${l.response.degraded_reason}).`}{" "}
          {linkManTay}
        </p> : l.response.answer && <>
          <p>{l.response.answer}</p>
          {l.response.sources.length > 0 && <p className="text-sm text-muted-foreground">Nguồn: {l.response.sources.map((s) => `${nguon[s.tool] ?? s.tool} (${khung ? "đọc lúc " : ""}${dinhDangGio.format(new Date(s.read_at))})`).join(", ")}</p>}
          {khung && <p className="text-sm text-muted-foreground">
            {l.response.sources.length > 0
              ? "Số chỉ đúng tại mốc đọc; màn tay có thể đã đổi."
              : "Câu này không kèm nguồn đọc nào của quán; đừng dựa vào số trong câu."}{" "}
            {linkManTay}
          </p>}
        </>}
      </div>)}
      {dangHoi && <div><p>{question}</p><p role="status">Đang hỏi…</p></div>}
    </div>
    {loi && <p role="alert">{loi}{" "}{linkManTay}</p>}
    <form className="space-y-2" onSubmit={(e) => { e.preventDefault(); void hoi(); }}>
      <p className="text-sm">{khung
        ? "Trợ lý chỉ đọc số mà tài khoản của bạn xem được trên màn tay, không ghi gì."
        : "Trợ lý chỉ trả lời về món và giá, không nhận đặt món."}</p>
      <label className="block">Câu hỏi
        <textarea ref={oNhap} value={cau} readOnly={dangHoi} onChange={(e) => setCau(e.target.value)}
          aria-invalid={quaDai || undefined}
          className="block min-h-11 w-full rounded border bg-background px-3 py-2"
          onKeyDown={(e) => {
            if (e.key === "Enter" && !e.shiftKey && !e.nativeEvent.isComposing) { e.preventDefault(); void hoi(); }
          }} />
      </label>
      {quaDai && <p role="alert">Câu hỏi tối đa 500 ký tự.</p>}
      <Button type="submit" disabled={!question || quaDai || dangHoi}>Hỏi</Button>
    </form>
  </div>;
}
