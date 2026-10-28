"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { z } from "zod";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { useDonPhienKhach } from "@/lib/khach/session";
import { KhungKhach } from "./khung";
import { FormKhach, batBuoc, matKhau } from "./form";

export const CAU_GUI_KHACH = "Nếu Gmail này gắn với một tài khoản khách, mã đặt lại đã được gửi tới đó (hạn 30 phút).";
const request = z.object({ email: batBuoc });
const reset = z.object({ token: batBuoc, new_password: matKhau });
export function QuenMatKhauKhach() {
  const api = useApi();
  return <KhungKhach title="Quên mật khẩu">
    <p>Tài khoản chỉ có số điện thoại hiện chưa có cách lấy lại mật khẩu.</p>
    <FormKhach schema={request} defaults={{ email: "" }} fields={[{ name: "email", label: "Gmail của tài khoản", type: "email", autoComplete: "email" }]}
      submit={(body) => call(api.POST("/customer-password-reset-requests", { body }))} success={() => CAU_GUI_KHACH} label="Gửi mã đặt lại" />
    <Link href="/khach/dat-lai-mat-khau">Đã có mã trong thư</Link><p><Link href="/khach/dang-nhap">Quay lại đăng nhập</Link></p>
  </KhungKhach>;
}
export function DatLaiMatKhauKhach() {
  const api = useApi(); const params = useSearchParams(); const don = useDonPhienKhach();
  return <KhungKhach title="Đặt lại mật khẩu">
    <FormKhach schema={reset} defaults={{ token: params.get("token") ?? "", new_password: "" }} fields={[
      { name: "token", label: "Mã đặt lại", autoComplete: "one-time-code" },
      { name: "new_password", label: "Mật khẩu mới (ít nhất 8 ký tự)", type: "password", autoComplete: "new-password" },
    ]} submit={(body) => call(api.POST("/customer-password-resets", { body }))} success={async () => {
      await don(); return "Đã đặt mật khẩu mới. Mọi phiên cũ đã kết thúc — đăng nhập lại.";
    }} label="Đặt mật khẩu mới" />
    <Link href="/khach/dang-nhap">Quay lại đăng nhập</Link>
  </KhungKhach>;
}
