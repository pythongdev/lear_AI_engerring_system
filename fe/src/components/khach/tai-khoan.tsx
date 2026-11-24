"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ChevronDown, ClipboardList, Heart } from "lucide-react";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Bao } from "@/components/tai-khoan/khung-form";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { hetPhien, useChuyenDangNhap, useDonPhienKhach, usePhienKhach } from "@/lib/khach/session";
import { KhungKhach, LoiDocKhach } from "./khung";
import { FormKhach, matKhau, batBuoc } from "./form";
import "./yeu-thich/yeu-thich.css";
import "./tai-khoan.css";

const delivery = z.object({ delivery_name: z.string(), delivery_phone: z.string(), delivery_address: z.string() });
const password = z.object({ current_password: batBuoc, new_password: matKhau });
export function TaiKhoanKhach() {
  const api = useApi(); const router = useRouter(); const phien = usePhienKhach(); const don = useDonPhienKhach();
  const [busy, setBusy] = useState(false); const lock = useRef(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [loi, setLoi] = useState<ApiFailure | null>(null);
  const [suaGiao, setSuaGiao] = useState(false);
  const [luuGiao, setLuuGiao] = useState(false);
  const [moMatKhau, setMoMatKhau] = useState(false);
  useChuyenDangNhap(phien.data === null || hetPhien(loi));
  const p = phien.data;
  const ten = p?.display_name.trim() || "";
  // Chỉ từ bắt đầu bằng chữ cái: "Khách thử (dev)" ⇒ "KT", không phải "T(".
  const chuCai = ten.split(/\s+/).filter((tu) => /^\p{L}/u.test(tu)).slice(-2).map((tu) => tu[0]).join("").toLocaleUpperCase("vi-VN") || "KH";
  async function docLai() {
    try {
      const r = await phien.refetch();
      setNotice(r.isError ? "Đã lưu nhưng chưa đọc lại được thông tin. Bấm Đọc lại để cập nhật." : "Đã lưu thông tin giao.");
      setSuaGiao(false);
    } finally { setLuuGiao(false); }
  }
  async function guiLai() {
    if (lock.current) return; lock.current = true; setBusy(true); setLoi(null); setNotice(null);
    try {
      const r = await call(api.POST("/customer-accounts/current/email-verification"));
      if (!r.ok) {
        if (r.failure.kind === "rejected" && r.failure.code === "verification_rate_limited") {
          setNotice("Đã gửi nhiều lần, thử lại sau một giờ.");
        } else setLoi(r.failure);
        return;
      }
      setNotice(`Đã gửi thư xác nhận tới ${p?.pending_email}. Mở thư và bấm link trong 24 giờ.`);
    } finally { lock.current = false; setBusy(false); }
  }
  async function thoat() {
    if (lock.current) return; lock.current = true; setBusy(true); setLoi(null);
    try {
      const r = await call(api.POST("/customer-sessions/current/end"));
      if (!r.ok && !hetPhien(r.failure)) { setLoi(r.failure); return; }
      await don(); router.replace("/khach/dang-nhap");
    } finally { lock.current = false; setBusy(false); }
  }
  return <KhungKhach title="Tài khoản của tôi" vien={false}>
    <div className="yt-theme tk-page space-y-6">
    {phien.isPending && <p role="status">Đang tải tài khoản…</p>}
    {phien.error && <LoiDocKhach error={phien.error} docLai={() => void phien.refetch()} readAt={phien.dataUpdatedAt} />}
    {p && <>
      <header className="space-y-4">
        <div className="space-y-2"><p className="yt-eyebrow">MỘT CHÚT VỀ BẠN</p>
          <p className="yt-muted">Lưu thông tin, đặt món thuận tiện hơn.</p></div>
        <section aria-label="Thông tin hồ sơ" className="tk-identity">
          <div className="tk-avatar" aria-hidden="true">{chuCai}</div>
          <div className="min-w-0 space-y-1"><h2 className="text-lg font-semibold">{ten || "Khách hàng"}</h2>
            <p className="yt-muted">{p.phone || p.email || "Chưa có"}</p></div>
        </section>
      </header>
      <section aria-label="Thông tin cá nhân" className="yt-card tk-section space-y-3">
        <h2 className="tk-section-title">Thông tin cá nhân</h2>
        <div className="tk-details space-y-2"><p>Tên: {ten || "Chưa có"}</p>
          <p>Số điện thoại: {p.phone || "Chưa có"}</p><p>Gmail: {p.email || "Chưa có"}</p></div>
        {p.pending_email && <section aria-label="Xác nhận Gmail" className="tk-verification space-y-2">
          <p>Gmail {p.pending_email} đang chờ xác nhận</p>
          <p className="yt-muted">Đã gửi thư xác nhận tới {p.pending_email}. Mở thư và bấm link trong 24 giờ.</p>
          <Button disabled={busy} onClick={() => void guiLai()}>Gửi lại thư xác nhận</Button>
        </section>}
      </section>
      {notice && <Bao loai="tin">{notice}</Bao>}
      <section aria-label="Thông tin giao đã nhớ" className="yt-card tk-section space-y-4">
        <h2 className="tk-section-title">Thông tin giao đã nhớ</h2>
        {suaGiao ? <div id="tk-delivery-edit" className="space-y-4">
          <p className="yt-muted">Chỉ nhớ một bộ thông tin. Để trống cả ba ô rồi lưu để xoá bộ đã nhớ.</p>
          <FormKhach schema={delivery} defaults={{ delivery_name: p.delivery_name ?? "", delivery_phone: p.delivery_phone ?? "", delivery_address: p.delivery_address ?? "" }}
            fields={[{ name: "delivery_name", label: "Tên người nhận", autoComplete: "name" }, { name: "delivery_phone", label: "Số điện thoại người nhận", type: "tel", autoComplete: "tel" }, { name: "delivery_address", label: "Địa chỉ giao", autoComplete: "street-address" }]}
            submit={async (body) => {
              setLuuGiao(true);
              const r = await call(api.PUT("/customer-accounts/current/delivery-profile", { body }));
              if (!r.ok) setLuuGiao(false);
              return r;
            }} success={docLai} label="Lưu thông tin giao" protectedForm />
          <Button variant="outline" disabled={luuGiao} onClick={() => setSuaGiao(false)}>Huỷ</Button>
        </div> : <>
          {p.delivery_name || p.delivery_phone || p.delivery_address
            ? <div className="tk-details space-y-2"><p>Tên người nhận: {p.delivery_name || "Chưa có"}</p>
              <p>Số điện thoại người nhận: {p.delivery_phone || "Chưa có"}</p><p>Địa chỉ giao: {p.delivery_address || "Chưa có"}</p></div>
            : <p className="yt-muted">Chưa có thông tin giao</p>}
          <Button className="w-full" onClick={() => { setNotice(null); setSuaGiao(true); }}>Cập nhật thông tin</Button>
        </>}
      </section>
      <section aria-label="Của tôi" className="space-y-3"><h2 className="tk-section-title">Của tôi</h2>
        <div className="tk-grid">
          <Link href="/khach/yeu-thich" className="yt-card tk-tile tk-featured"><Heart aria-hidden="true" />
            <span><strong>Yêu thích</strong>{" "}<small>Những món bạn đã lưu</small></span></Link>
          <Link href="/khach/don" className="yt-card tk-tile"><ClipboardList aria-hidden="true" />
            <span><strong>Đơn đã đặt</strong>{" "}<small>Xem lại các đơn đã đặt</small></span></Link>
        </div>
      </section>
      <section aria-label="Đổi mật khẩu" className="yt-card tk-section space-y-4">
        <h2><Button variant="ghost" className="tk-password-toggle w-full justify-between" aria-expanded={moMatKhau}
          aria-controls="tk-password" onClick={() => setMoMatKhau(!moMatKhau)}>{moMatKhau ? "Ẩn đổi mật khẩu" : "Đổi mật khẩu"}<ChevronDown aria-hidden="true" className={moMatKhau ? "rotate-180" : ""} /></Button></h2>
        <div id="tk-password" hidden={!moMatKhau}><FormKhach schema={password} defaults={{ current_password: "", new_password: "" }} fields={[
          { name: "current_password", label: "Mật khẩu hiện tại", type: "password", autoComplete: "current-password" },
          { name: "new_password", label: "Mật khẩu mới (ít nhất 8 ký tự)", type: "password", autoComplete: "new-password" },
        ]} submit={(body) => call(api.PUT("/customer-accounts/current/password", { body }))} success={async () => {
          const r = await phien.refetch(); return r.isError ? "Đã đổi mật khẩu nhưng chưa đọc lại được tài khoản." : "Đã đổi mật khẩu. Các phiên khác đã kết thúc; phiên này vẫn được giữ.";
        }} label="Đổi mật khẩu" protectedForm /></div>
      </section>
      {loi && <Bao loai="loi">{loiTaiKhoan(loi)}</Bao>}
      <Button variant="outline" disabled={busy} onClick={() => void thoat()}>{busy ? "Đang đăng xuất…" : "Đăng xuất"}</Button>
    </>}
    </div>
  </KhungKhach>;
}
