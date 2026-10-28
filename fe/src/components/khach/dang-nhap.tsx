"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { z } from "zod";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { useDonPhienKhach } from "@/lib/khach/session";
import { KhungKhach } from "./khung";
import { FormKhach, batBuoc, matKhau } from "./form";

const login = z.object({ identifier: batBuoc, password: batBuoc });
const register = z.object({ display_name: batBuoc, phone: z.string(), email: z.string(), password: matKhau })
  .refine((v) => !!(v.phone.trim() || v.email.trim()), { path: ["phone"], message: "Nhập số điện thoại hoặc Gmail." });

export function DangNhapKhach({ dangKy = false }: { dangKy?: boolean }) {
  const api = useApi(); const router = useRouter(); const don = useDonPhienKhach();
  async function xong() { await don(); router.replace("/khach/tai-khoan"); }
  return <KhungKhach title={dangKy ? "Đăng ký tài khoản khách" : "Đăng nhập dành cho khách"}>
    <p className="text-muted-foreground">Nhớ thông tin giao và xem lại đơn đã đặt. Bạn vẫn có thể đặt món khi chưa đăng nhập.</p>
    {dangKy ? <FormKhach schema={register} defaults={{ display_name: "", phone: "", email: "", password: "" }} fields={[
      { name: "display_name", label: "Tên", autoComplete: "name" }, { name: "phone", label: "Số điện thoại", type: "tel", autoComplete: "tel" },
      { name: "email", label: "Gmail", type: "email", autoComplete: "email" }, { name: "password", label: "Mật khẩu (ít nhất 8 ký tự)", type: "password", autoComplete: "new-password" },
    ]} submit={(body) => call(api.POST("/customer-accounts", { body }))} success={xong} label="Đăng ký" />
      : <FormKhach schema={login} defaults={{ identifier: "", password: "" }} fields={[
        { name: "identifier", label: "Số điện thoại hoặc Gmail", autoComplete: "username" },
        { name: "password", label: "Mật khẩu", type: "password", autoComplete: "current-password" },
      ]} submit={(body) => call(api.POST("/customer-sessions", { body }))} success={xong} label="Đăng nhập" />}
    {dangKy && <p>Khai ít nhất số điện thoại hoặc Gmail.</p>}
    <nav className="flex flex-wrap gap-4 text-sm">
      <Link href={dangKy ? "/khach/dang-nhap" : "/khach/dang-ky"}>{dangKy ? "Đã có tài khoản — đăng nhập" : "Đăng ký tài khoản"}</Link>
      <Link href="/khach/quen-mat-khau">Quên mật khẩu</Link>
    </nav>
  </KhungKhach>;
}
