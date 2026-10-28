"use client";

import { useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Bao } from "@/components/tai-khoan/khung-form";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { hetPhien, useChuyenDangNhap, useDonPhienKhach, usePhienKhach } from "@/lib/khach/session";
import { KhungKhach, LoiDocKhach } from "./khung";
import { FormKhach, matKhau, batBuoc } from "./form";

const delivery = z.object({ delivery_name: z.string(), delivery_phone: z.string(), delivery_address: z.string() });
const password = z.object({ current_password: batBuoc, new_password: matKhau });
export function TaiKhoanKhach() {
  const api = useApi(); const router = useRouter(); const phien = usePhienKhach(); const don = useDonPhienKhach();
  const [busy, setBusy] = useState(false); const lock = useRef(false);
  const [loi, setLoi] = useState<ApiFailure | null>(null);
  useChuyenDangNhap(phien.data === null || hetPhien(loi));
  const p = phien.data;
  async function docLai() {
    const r = await phien.refetch();
    return r.isError ? "Đã lưu nhưng chưa đọc lại được thông tin. Bấm Đọc lại để cập nhật." : "Đã lưu thông tin giao.";
  }
  async function thoat() {
    if (lock.current) return; lock.current = true; setBusy(true); setLoi(null);
    try {
      const r = await call(api.POST("/customer-sessions/current/end"));
      if (!r.ok && !hetPhien(r.failure)) { setLoi(r.failure); return; }
      await don(); router.replace("/khach/dang-nhap");
    } finally { lock.current = false; setBusy(false); }
  }
  return <KhungKhach title="Tài khoản của tôi">
    {phien.isPending && <p role="status">Đang tải tài khoản…</p>}
    {phien.error && <LoiDocKhach error={phien.error} docLai={() => void phien.refetch()} readAt={phien.dataUpdatedAt} />}
    {p && <>
      <section aria-label="Thông tin cá nhân" className="space-y-2"><h2 className="text-lg font-semibold">{p.display_name}</h2>
        <p>Số điện thoại: {p.phone || "Chưa có"}</p><p>Gmail: {p.email || "Chưa có"}</p>
      </section>
      <section aria-label="Thông tin giao đã nhớ" className="space-y-3"><h2 className="font-semibold">Thông tin giao đã nhớ</h2>
        <p>Chỉ nhớ một bộ thông tin. Để trống cả ba ô rồi lưu để xoá bộ đã nhớ.</p>
        <FormKhach schema={delivery} defaults={{ delivery_name: p.delivery_name ?? "", delivery_phone: p.delivery_phone ?? "", delivery_address: p.delivery_address ?? "" }}
          fields={[{ name: "delivery_name", label: "Tên người nhận", autoComplete: "name" }, { name: "delivery_phone", label: "Số điện thoại người nhận", type: "tel", autoComplete: "tel" }, { name: "delivery_address", label: "Địa chỉ giao", autoComplete: "street-address" }]}
          submit={(body) => call(api.PUT("/customer-accounts/current/delivery-profile", { body }))} success={docLai} label="Lưu thông tin giao" protectedForm />
      </section>
      <section aria-label="Đổi mật khẩu" className="space-y-3"><h2 className="font-semibold">Đổi mật khẩu</h2>
        <FormKhach schema={password} defaults={{ current_password: "", new_password: "" }} fields={[
          { name: "current_password", label: "Mật khẩu hiện tại", type: "password", autoComplete: "current-password" },
          { name: "new_password", label: "Mật khẩu mới (ít nhất 8 ký tự)", type: "password", autoComplete: "new-password" },
        ]} submit={(body) => call(api.PUT("/customer-accounts/current/password", { body }))} success={async () => {
          const r = await phien.refetch(); return r.isError ? "Đã đổi mật khẩu nhưng chưa đọc lại được tài khoản." : "Đã đổi mật khẩu. Các phiên khác đã kết thúc; phiên này vẫn được giữ.";
        }} label="Đổi mật khẩu" protectedForm />
      </section>
      {loi && <Bao loai="loi">{loiTaiKhoan(loi)}</Bao>}
      <Button variant="outline" disabled={busy} onClick={() => void thoat()}>{busy ? "Đang đăng xuất…" : "Đăng xuất"}</Button>
    </>}
  </KhungKhach>;
}
