import { Suspense } from "react";
import { TaiKhoanKhach } from "@/components/khach/tai-khoan";

export const metadata = { title: "Tài khoản khách" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><TaiKhoanKhach /></Suspense>;
}
